// (c) Microsoft Corporation 2005-2009. 
namespace Microsoft.FSharp.Control

    open System
    open System.Threading
    open Microsoft.FSharp.Control

    /// Represents the reified result of an asynchronous computation
    [<NoEquality; NoComparison>]
    type AsyncResult<'T>  =
        |   AsyncOk of 'T
        |   AsyncException of exn
        |   AsyncCanceled of OperationCanceledException

        static member Commit(res:AsyncResult<'T>) = 
            Async.FromContinuations (fun (cont,econt,ccont) -> 
                   match res with 
                   | AsyncOk v -> cont v 
                   | AsyncException exn -> econt exn 
                   | AsyncCanceled exn -> ccont exn)

    /// When using .NET 4.0 you can replace this type by Task<'T>
    [<Sealed>]
    type AsyncResultCell<'T>() =
        let mutable result = None
        // The continuation for the result, if any
        let mutable savedConts = []
        
        let syncRoot = new obj()
                

        // Record the result in the AsyncResultCell.
        // Ignore subsequent sets of the result. This can happen, e.g. for a race between 
        // a cancellation and a success.
        member x.RegisterResult (res:AsyncResult<'T>,?reuseThread) =
            let grabbedConts = 
                lock syncRoot (fun () ->
                    if result.IsSome then  
                        []
                    else
                        result <- Some res;
                        // Invoke continuations in FIFO order 
                        // Continuations that Async.FromContinuations provide do QUWI/SynchContext.Post, 
                        // so the order is not overly relevant but still.                        
                        List.rev savedConts)
            // Run continuations outside the lock
            let reuseThread = defaultArg reuseThread false
            match grabbedConts with
            |   [] -> ()
            |   [cont] when reuseThread -> cont res
            |   otherwise ->
#if FX_NO_SYNC_CONTEXT
                    let postOrQueue cont = ThreadPool.QueueUserWorkItem(fun _ -> cont res) |> ignore
#else
                    let synchContext = System.Threading.SynchronizationContext.Current
                    let postOrQueue =
                        match synchContext with
                        |   null -> fun cont -> ThreadPool.QueueUserWorkItem(fun _ -> cont res) |> ignore
                        |   sc -> fun cont -> sc.Post((fun _ -> cont res), state=null)
#endif                        
                    grabbedConts |> List.iter postOrQueue

        /// Get the reified result 
        member private x.AsyncPrimitiveResult =
            Async.FromContinuations(fun (cont,_,_) -> 
                let grabbedResult = 
                    lock syncRoot (fun () ->
                        match result with
                        | Some res -> 
                            result
                        | None ->
                            // Otherwise save the continuation and call it in RegisterResult
                            savedConts <- cont::savedConts
                            None)
                // Run the action outside the lock
                match grabbedResult with 
                | None -> ()
                | Some res -> cont res) 
                           

        /// Get the result and commit it
        member x.AsyncResult =
            async { let! res = x.AsyncPrimitiveResult
                    return! AsyncResult.Commit(res) }


    [<AutoOpen>]
    module FileExtensions =

        let UnblockViaNewThread f =
            async { do! Async.SwitchToNewThread ()
                    let res = f()
                    do! Async.SwitchToThreadPool ()
                    return res }


        type System.IO.File with
            static member AsyncOpenText(path)   = UnblockViaNewThread (fun () -> System.IO.File.OpenText(path))
            static member AsyncAppendText(path) = UnblockViaNewThread (fun () -> System.IO.File.AppendText(path))
            static member AsyncOpenRead(path)   = UnblockViaNewThread (fun () -> System.IO.File.OpenRead(path))
            static member AsyncOpenWrite(path)  = UnblockViaNewThread (fun () -> System.IO.File.OpenWrite(path))
#if FX_NO_FILE_OPTIONS
            static member AsyncOpen(path,mode,?access,?share,?bufferSize) =
#else
            static member AsyncOpen(path,mode,?access,?share,?bufferSize,?options) =
#endif
                let access = match access with Some v -> v | None -> System.IO.FileAccess.ReadWrite
                let share = match share with Some v -> v | None -> System.IO.FileShare.None
#if FX_NO_FILE_OPTIONS
#else
                let options = match options with Some v -> v | None -> System.IO.FileOptions.None
#endif
                let bufferSize = match bufferSize with Some v -> v | None -> 0x1000
                UnblockViaNewThread (fun () -> 
#if FX_NO_FILE_OPTIONS
                    new System.IO.FileStream(path,mode,access,share,bufferSize))
#else
                    new System.IO.FileStream(path,mode,access,share,bufferSize, options))
#endif

            static member OpenTextAsync(path)   = System.IO.File.AsyncOpenText(path)
            static member AppendTextAsync(path) = System.IO.File.AsyncAppendText(path)
            static member OpenReadAsync(path)   = System.IO.File.AsyncOpenRead(path)
            static member OpenWriteAsync(path)  = System.IO.File.AsyncOpenWrite(path)
#if FX_NO_FILE_OPTIONS
            static member OpenAsync(path,mode,?access,?share,?bufferSize) = 
                System.IO.File.AsyncOpen(path, mode, ?access=access, ?share=share,?bufferSize=bufferSize)
#else
            static member OpenAsync(path,mode,?access,?share,?bufferSize,?options) = 
                System.IO.File.AsyncOpen(path, mode, ?access=access, ?share=share,?bufferSize=bufferSize,?options=options)
#endif

    [<AutoOpen>]
    module StreamReaderExtensions =
        type System.IO.StreamReader with

            member s.AsyncReadToEnd () = FileExtensions.UnblockViaNewThread (fun () -> s.ReadToEnd())
            member s.ReadToEndAsync () = s.AsyncReadToEnd ()

#if FX_NO_WEB_REQUESTS
#else
    [<AutoOpen>]
    module WebRequestExtensions =
        open System
        open System.Net
        open Microsoft.FSharp.Control.WebExtensions

        let callFSharpCoreAsyncGetResponse (req: System.Net.WebRequest) = req.AsyncGetResponse()
        
        type System.Net.WebRequest with
            member req.AsyncGetResponse() = callFSharpCoreAsyncGetResponse req // this calls the FSharp.Core method
            member req.GetResponseAsync() = callFSharpCoreAsyncGetResponse req // this calls the FSharp.Core method
#endif
     
#if FX_NO_WEB_CLIENT
#else
    [<AutoOpen>]
    module WebClientExtensions =
        open System.Net
        open Microsoft.FSharp.Control.WebExtensions
        
        let callFSharpCoreAsyncDownloadString (req: System.Net.WebClient) address = req.AsyncDownloadString address

        type WebClient with
            member this.AsyncDownloadString address = callFSharpCoreAsyncDownloadString this address
#endif

