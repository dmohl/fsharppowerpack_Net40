// (c) Microsoft Corporation 2005-2009. 

[<CompilationRepresentation(CompilationRepresentationFlags.ModuleSuffix)>]
module Microsoft.FSharp.Compatibility.OCaml.Arg

let Clear  x = ArgType.Clear x
let Float  x = ArgType.Float x
let Int    x = ArgType.Int x
let Rest   x = ArgType.Rest x
let Set    x = ArgType.Set x
let String x = ArgType.String x
let Unit   x = ArgType.Unit x

type spec = ArgType
type argspec = (string * spec * string) 

exception Bad of string
exception Help of string
let parse_argv cursor argv specs other usageText =
    ArgParser.ParsePartial(cursor, argv, List.map (fun (a,b,c) -> ArgInfo(a,b,c)) specs, other, usageText)

#if FX_NO_COMMAND_LINE_ARGS
#else
let parse specs other usageText = 
    ArgParser.Parse(List.map (fun (a,b,c) -> ArgInfo(a,b,c)) specs, other, usageText)
#endif
let usage specs usageText = 
    ArgParser.Usage(List.map (fun (a,b,c) -> ArgInfo(a,b,c)) specs, usageText)
