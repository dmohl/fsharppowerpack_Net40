# You might need to adjust these variables
MONO=mono
MONOLIB=/usr/lib/mono/3.5/
MONOLIB2=/usr/lib/mono/2.0/
FSC=/usr/lib/fsharp/fsc.exe
FSLIB=/usr/lib/fsharp/

# Example path for MacOS:
#MONOLIB=/Library/Frameworks/Mono.framework/Versions/2.8/lib/mono/3.5/
#MONOLIB2=/Library/Frameworks/Mono.framework/Versions/2.8/lib/mono/2.0/


# No need to change anything here
cd fsharp
ROOT=$(pwd)
LKG=$ROOT/../../lkg/FSharp-2.0.50726.900/bin/
PROTODIR=../../../Proto/cli/2.0/bin/
PROTO=$PROTODIR/fsc-proto.exe
OUTPUTDIR=../../../Debug/cli/2.0/bin/
