    #r "System.Core.dll"

    #load "PSeq.fsi"
    #load "PSeq.fs"

    open Microsoft.FSharp.Collections

    let isPrime n = 
        let upperBound = int (sqrt (float n))
        let hasDivisor =     
            [2..upperBound]
            |> List.exists (fun i -> n % i = 0)
        not hasDivisor
            
    let nums = [|1..500000|]

    let finalDigitOfPrimes = 
        nums 
        |> PSeq.filter isPrime
        |> PSeq.groupBy (fun i -> i % 10)
        |> PSeq.map (fun (k, vs) -> (k, Seq.length vs))
        |> PSeq.toArray

   let averageOfFinalDigit = 
        nums 
        |> PSeq.filter isPrime
        |> PSeq.groupBy (fun i -> i % 10)
        |> PSeq.map (fun (k, vs) -> (k, Seq.length vs))
        |> PSeq.averageBy (fun (k,n) -> float n)
    