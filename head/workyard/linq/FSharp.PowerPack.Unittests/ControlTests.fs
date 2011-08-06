﻿namespace FSharp.PowerPack.Unittests
open NUnit.Framework
open System
open System.IO
open System.Threading

#nowarn "40"


module ControlTestUtilities = 

    let syncObj = new obj()
    let reportFailure s = 
      lock syncObj (fun () ->
         Assert.Fail (sprintf "FAILURE: %s failed" s)
      )
    let biggerThanTrampoliningLimit = 10000

    let boxed(a:Async<'b>) : Async<obj> = async { let! res = a in return box res }
        
    type VStringRef(s) = 
        [<VolatileField>]
        let mutable contents : string = s 
        
        member x.Contents 
            with get () = contents
            and set v = contents <- v
        
    let (!) (x : VStringRef) = x.Contents
    let (:=) (x : VStringRef) s = x.Contents <- s
    let ref s = VStringRef(s)

    // Useful class: put "checkpoints" in the code.
    // Check they are called in the right order.
    type Path(str) =
        let mutable current = 0
        member p.Check n = check (str + " #" + string (current+1)) n (current+1)
                           current <- n

    type Color = Blue | Red | Yellow

    type Message =  Color * AsyncResultCell<Color option>

open ControlTestUtilities

[<TestFixture>]
type public ZZZ_ControlTests() =
    let writeAllBytes (path:string,bytes:byte[]) =
#if FX_NO_FILEWRITEALL
        use s = System.IO.File.OpenWrite(path)
        s.Write(bytes,0,bytes.Length)
#else
        System.IO.File.WriteAllBytes(path, bytes)
#endif
    let writeAllText(path:string,contents:string) =
#if FX_NO_FILEWRITEALL
        use s = new System.IO.StreamWriter(path)
        s.Write(contents)
#else
        System.IO.File.WriteAllText(path, contents)
#endif


    [<TestFixtureSetUp>]
    member this.TestFixtureSetUp() = 
        System.AppDomain.CurrentDomain.UnhandledException.AddHandler(
               fun _ (args:System.UnhandledExceptionEventArgs) ->
                  lock syncObj (fun () ->
                        reportFailure ((args.ExceptionObject :?> System.Exception).ToString())
                     )
        )
  
    [<Test>]
    member this.AsyncOpenReadTests() = 

        // There should be no effects before running, e.g. no attempt to open the file
        do System.IO.File.AsyncOpenRead "non exist ... file " |> ignore
        do System.IO.File.AsyncOpenWrite "non exist ... file 2" |> ignore

              
        
        check 
            "c32398u1: AsyncOpenRead/AsyncRead"
            (let _ = writeAllBytes("tmp.bin", "abcdefg"B)
             Async.RunSynchronously 
                 (async { use! is = System.IO.File.AsyncOpenRead "tmp.bin" 
                          return! is.AsyncRead 5 }))
            "abcde"B

        do 
            let n = 10000000
            let bytes = Array.init n (fun i -> byte i)
            check 
                "c32398u1: AsyncOpenRead/AsyncRead"
                (let _ = writeAllBytes("tmp.bin", bytes)
                 Async.RunSynchronously 
                     (async { use! is = System.IO.File.AsyncOpenRead "tmp.bin" 
                              return! is.AsyncRead n }))
                bytes

        do 
            let n = 10000000
            let bytes = Array.init n (fun i -> byte i)
            check 
                "c32398u1: AsyncOpenRead/AsyncRead"
                (let _ = writeAllBytes("tmp.bin", bytes)
                 Async.RunSynchronously 
#if FX_NO_FILE_OPTIONS
                     (async { use! is = System.IO.File.AsyncOpen("tmp.bin",mode=FileMode.Open)
#else
                     (async { use! is = System.IO.File.AsyncOpen("tmp.bin",mode=FileMode.Open,options=FileOptions.Asynchronous)
#endif
                              return! is.AsyncRead n }))
                bytes

    [<Test>]
    member this.AsyncOpenReadWriteTest1() = 
        check 
            "c32398u2: AsyncOpenRead/AsyncRead"
            (let _ = writeAllBytes("tmp.bin", "abcdefg"B)
             Async.RunSynchronously 
                  (async { use! is = System.IO.File.AsyncOpenRead "tmp.bin" 
                           return! is.AsyncRead 7 }))
            "abcdefg"B

    [<Test>]
    member this.AsyncOpenReadWriteTest2() = 
        check 
            "c32398u3: AsyncOpenRead/AsyncRead"
            (let _ = writeAllBytes("tmp.bin", "abcdefg"B)
             Async.RunSynchronously 
                 (async { let buffer = Array.zeroCreate<byte>(7)
                          use! is = System.IO.File.AsyncOpenRead "tmp.bin" 
                          let! count = is.AsyncRead(buffer,0,7) 
                          return count, buffer }))
            (7, "abcdefg"B)


    [<Test>]
    member this.AsyncOpenReadWriteTest3() = 
        check 
            "c32398u4: AsyncOpenRead/AsyncRead/AsyncOpenWrite/AsyncWrite"
            (let _ = writeAllBytes("tmp.bin", "abcdefg"B)
             Async.RunSynchronously 
                 (async { do! async { let buffer = "qer"B
                                      use! is = System.IO.File.AsyncOpenWrite "tmp.bin" 
                                      do! is.AsyncWrite(buffer,0,3)  }
                          let buffer = Array.zeroCreate<byte>(7)
                          use! is = System.IO.File.AsyncOpenRead "tmp.bin" 
                          let! count = is.AsyncRead(buffer,0,7) 
                          return count, buffer }))
            (7, "qerdefg"B)

    [<Test>]
    member this.AsyncOpenTextTest() = 
        check 
            "c32398u5: AsyncOpenText"
            (let _ = writeAllText("tmp.txt", "abcdefg")
             Async.RunSynchronously 
                  (async { use! is = System.IO.File.AsyncOpenText "tmp.txt" 
                           return is.ReadToEnd() }))
            "abcdefg"

#if FX_NO_WINDOWSFORMS
#else
    [<Test>]
    member this.AsyncWorkerTest16() = 

        let p = Path "test16 - basic worker"
        let worker = async {
            do p.Check 1
            do! Async.Sleep 400
            do p.Check 3
        }
        AsyncWorker(worker).RunAsync() |> ignore
        System.Threading.Thread.Sleep 200
        p.Check 2
        System.Threading.Thread.Sleep 400
        System.Windows.Forms.Application.DoEvents()
        p.Check 4

    [<Test>]
    member this.AsyncWorkerTest17() = 
        let p = Path "test17 - worker and completed event"
        let work = async {
            do p.Check 1
            do! Async.Sleep 300
            do p.Check 3
            return 4
        }
        let worker = AsyncWorker(work)
        worker.Completed.Add(fun n -> p.Check n)
        worker.RunAsync() |> ignore
        System.Threading.Thread.Sleep 100
        p.Check 2
        System.Threading.Thread.Sleep 400
        System.Windows.Forms.Application.DoEvents()
        p.Check 5

    [<Test>]
    member this.AsyncWorkerTest18() = 
        // Worker and canceled event (using group.TriggerCancel)
        let p = Path "test18 - worker & group.TriggerCancel"
        let work = async {
            do p.Check 1
            do System.Threading.Thread.Sleep 200
            do p.Check 3
            let! _ = async { return 1 } 
            do ()
        }
        let group = new System.Threading.CancellationTokenSource()
        let worker = AsyncWorker(work, group.Token)
        worker.Canceled.Add(fun e -> p.Check 4)
        worker.RunAsync() |> ignore
        System.Threading.Thread.Sleep 100
        p.Check 2
        group.Cancel()
        System.Windows.Forms.Application.DoEvents()
        System.Threading.Thread.Sleep 500
        System.Windows.Forms.Application.DoEvents()
        System.Threading.Thread.Sleep 500
        p.Check 5

    [<Test>]
    member this.AsyncWorkerTest19() = 
        // Worker and canceled event (using worker.CancelAsync)
        let p = Path "test19 - worker & worker.CancelAsync"
        let work = async {
            do p.Check 1
            do System.Threading.Thread.Sleep 200
            do p.Check 3
            let! _ = async { return 1 } 
            do ()
        }
        let group = new System.Threading.CancellationTokenSource()
        let worker = AsyncWorker(work)
        worker.Canceled.Add(fun e -> p.Check 4)
        worker.RunAsync() |> ignore
        System.Threading.Thread.Sleep 100
        p.Check 2
        worker.CancelAsync("hello")
        System.Threading.Thread.Sleep 500
        System.Windows.Forms.Application.DoEvents()
        p.Check 5


    [<Test>]
    member this.AsyncWorkerTest20() = 
        // Worker and exceptions event
        let p = Path "test20 - worker and exceptions"
        let work = async {
            do p.Check 1
            do failwith "hello world"
        }
        let group = new System.Threading.CancellationTokenSource()
        let worker = AsyncWorker(work, group.Token)
        worker.Canceled.Add(fun _ -> p.Check -1)
        worker.Completed.Add(fun _ -> p.Check -1)
        worker.Error.Add(fun e -> test "test20" (e.Message = "hello world"); p.Check 2)
        worker.RunAsync() |> ignore
        System.Threading.Thread.Sleep 50
        System.Windows.Forms.Application.DoEvents()
        System.Threading.Thread.Sleep 50
        p.Check 3

    [<Test>]
    member this.AsyncWorkerTest21() = 
        // Worker and report progress
        let p = Path "test21 - worker & report progress"
        let rec work = async {
            for i in 1 .. 49 do
                do worker.ReportProgress i
                do printfn "report %d" i
                do System.Threading.Thread.Sleep 1
          }
        and worker: AsyncWorker<_> = AsyncWorker(work)
        worker.ProgressChanged.Add(fun n -> p.Check n)
        worker.RunAsync() |> ignore
        for i in 1 .. 150 do
            System.Threading.Thread.Sleep 10
            System.Windows.Forms.Application.DoEvents()
        p.Check 50

(*
    [<Test>]
    member this.AsyncWorkerTest21() = 
        let form = new System.Windows.Forms.Form()
        form.Load.Add(fun _ ->
            test16(); 
            // ToDo: 7/25/2008: Disabled because of probable timing issue.  QA needs to re-enable post-CTP.
            // Tracked by bug FSharp 1.0:2891
            //test17(); 
            test18(); 
            test19(); 
            test20(); 
            test21()
            System.Windows.Forms.Application.Exit())
        System.Windows.Forms.Application.Run(form)
        // Set the synchronization context back to its original value
        System.Threading.SynchronizationContext.SetSynchronizationContext(null);
*)

#endif
    [<Test>]
    member this.AsyncResultCellTests() = 

        
        let doWait(e1 : WaitHandle) (e2 : WaitHandle) s1 s2 =
            if e2.WaitOne() then
                if e1.WaitOne() then
                    (!s1) + (!s2)
                else "e2WaitFailed"
            else "e1WaitFailed"
        
        do 
            for i in 1..50 do
                check
                    (sprintf "hdfegdfyw6732: AsyncResultCell %d" i)
                    (let cell = new AsyncResultCell<string>()
                     use e1 = new ManualResetEvent(false)
                     let s1 = ref ""
                     use e2 = new ManualResetEvent(false)
                     let s2 = ref ""
                     async { 
                        do! Async.Sleep(100)
                        let! result = cell.AsyncResult 
                        //printfn "Here we are!(1)"
                        s1 := result; e1.Set() |> ignore 
                     } |> Async.Start
                     async { 
                        let! result = cell.AsyncResult 
                        //printfn "Here we are!(2)"
                        s2 := result; e2.Set() |> ignore 
                     } |> Async.Start
                     ThreadPool.QueueUserWorkItem(fun _ -> cell.RegisterResult(AsyncOk "hello")) |> ignore
                     doWait e1 e2 s1 s2
                    )
                    "hellohello"


        
        do 
            for i in 1..50 do
                check
                    (sprintf "hdfegdfyw6732: AsyncResultCell w/exception %d" i)
                    (let cell = new AsyncResultCell<string>()
                     use e1 = new ManualResetEvent(false)
                     let s1 = ref ""
                     use e2 = new ManualResetEvent(false)
                     let s2 = ref ""
                     let asyncToRun s (e:ManualResetEvent)=
                        async {
                            try 
                                let! result = cell.AsyncResult in 
                                s := result 
                            with 
                            |   ex -> s := ex.Message
                            e.Set() |> ignore 
                        }
                     asyncToRun s1 e1 |> Async.Start
                     asyncToRun s2 e2 |> Async.Start
                     ThreadPool.QueueUserWorkItem(fun _ -> cell.RegisterResult(System.Exception("exn") |> AsyncException))  |> ignore
                     doWait e1 e2 s1 s2        
                    )
                    "exnexn"

        do check
            "hdfegdfyw6732: AsyncResultCell + set result before wait starts"
            (let cell = new AsyncResultCell<string>()
             use e1 = new ManualResetEvent(false)
             let s1 = ref ""
             use e2 = new ManualResetEvent(false)
             let s2 = ref ""
             cell.RegisterResult(AsyncOk "hello") 
             async { let! result = cell.AsyncResult in s1 := result; e1.Set() |> ignore } |> Async.Start
             async { let! result = cell.AsyncResult in s2 := result; e2.Set() |> ignore } |> Async.Start
             doWait e1 e2 s1 s2
            )
            "hellohello"
            
        do check
            "hdfegdfyw6732: AsyncResultCell w/exception + set result before wait starts"
            (let cell = new AsyncResultCell<string>()
             use e1 = new ManualResetEvent(false)
             let s1 = ref ""
             use e2 = new ManualResetEvent(false)
             let s2 = ref ""
             let asyncToRun s (e:ManualResetEvent) =
                async {
                    try 
                        let! result = cell.AsyncResult in 
                        s := result 
                    with 
                    |  e -> s := e.Message
                    e.Set() |> ignore 
                }
             cell.RegisterResult(Exception("exn") |> AsyncException) 
             asyncToRun s1 e1 |> Async.Start
             asyncToRun s2 e2 |> Async.Start
             doWait e1 e2 s1 s2
            )
            "exnexn"

    [<Test>]
    member this.AsyncResultCellAgents() = 

        let complement = function
            | (Red, Yellow) | (Yellow, Red) -> Blue
            | (Red, Blue) | (Blue, Red) -> Yellow
            | (Yellow, Blue) | (Blue, Yellow) -> Red
            | (Blue, Blue) -> Blue
            | (Red, Red) -> Red
            | (Yellow, Yellow) -> Yellow


        let chameleon (meetingPlace : MailboxProcessor<Message>) initial = 
            let rec loop c meets = async  {
                    let resultCell = new AsyncResultCell<_>()
                    meetingPlace.Post (c, resultCell)
                    let! reply = resultCell.AsyncResult
                    match reply with     
                    | Some(newColor) -> return! loop newColor (meets + 1)
                    | None -> return meets
                }
            loop initial 0
            

        let meetingPlace chams n = MailboxProcessor.Start(fun (processor : MailboxProcessor<Message>)->
            let rec fadingLoop total = 
                async   {
                    if total <> 0 then
                        let! (_, reply) = processor.Receive()
                        reply.RegisterResult (AsyncOk None)
                        return! fadingLoop (total - 1)
                    else
                        printfn "Done"
                }
            let rec mainLoop curr = 
                async   {
                    if (curr > 0) then
                        let! (color1, reply1) = processor.Receive()
                        let! (color2, reply2) = processor.Receive()
                        let newColor = complement (color1, color2)
                        reply1.RegisterResult(AsyncOk(Some(newColor)))
                        reply2.RegisterResult(AsyncOk(Some(newColor)))
                        return! mainLoop (curr - 1)
                    else
                        return! fadingLoop chams
                }
            mainLoop n
            ) 
            


        let meetings = 100000
        
        let colors = [Blue; Red; Yellow; Blue]    
        let mp = meetingPlace (colors.Length) meetings
        let meets = 
                colors 
                    |> List.map (chameleon mp) 
                    |> Async.Parallel 
                    |> Async.RunSynchronously 

        check "Chamenos" (Seq.sum meets) (meetings*2)

    [<Test>]
    member this.AsyncResultCellLightweightAgents() = 
        let complement = function
            | (Red, Yellow) | (Yellow, Red) -> Blue
            | (Red, Blue) | (Blue, Red) -> Yellow
            | (Yellow, Blue) | (Blue, Yellow) -> Red
            | (Blue, Blue) -> Blue
            | (Red, Red) -> Red
            | (Yellow, Yellow) -> Yellow

        let chameleon (meetingPlace : MailboxProcessor<Message>) initial = 
            let rec loop c meets = async  {
                    let resultCell = new AsyncResultCell<_>()
                    meetingPlace.Post (c, resultCell)
                    let! reply = resultCell.AsyncResult
                    match reply with     
                    | Some(newColor) -> return! loop newColor (meets + 1)
                    | None -> return meets
                }
            loop initial 0
            

        let meetingPlace chams n = MailboxProcessor.Start(fun (processor : MailboxProcessor<Message>)->
            let rec fadingLoop total = 
                async   {
                    if total <> 0 then
                        let! (_, reply) = processor.Receive()
                        reply.RegisterResult (AsyncOk None)
                        return! fadingLoop (total - 1)
                    else
                        printfn "Done"
                }
            let rec mainLoop curr = 
                async   {
                    if (curr > 0) then
                        let! (color1, reply1) = processor.Receive()
                        let! (color2, reply2) = processor.Receive()
                        let newColor = complement (color1, color2)
                        reply1.RegisterResult(AsyncOk(Some(newColor)), reuseThread=true)
                        reply2.RegisterResult(AsyncOk(Some(newColor)), reuseThread=true)
                        return! mainLoop (curr - 1)
                    else
                        return! fadingLoop chams
                }
            mainLoop n
            ) 



        let meetings = 100000
        
        let colors = [Blue; Red; Yellow; Blue]    
        let mp = meetingPlace (colors.Length) meetings
        let meets = 
                colors 
                    |> List.map (chameleon mp) 
                    |> Async.Parallel 
                    |> Async.RunSynchronously 

        check "Chamenos" (Seq.sum meets) (meetings*2)

