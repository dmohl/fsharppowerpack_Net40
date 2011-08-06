#! /bin/sh -e

. ./config.sh
BUILD=obj/Debug/cli/2.0/

cd FSharp.Core
mkdir -p "$OUTPUTDIR/"
mkdir -p "$BUILD/"

resgen /useSourcePath /compile FSCore.resx,$BUILD/FSCore.resources 

export MONO_PATH=$FSLIB:$MONO_PATH

$MONO $PROTO -I $FSLIB -o:$BUILD/FSharp.Core.dll -g --debug:full --noframework --baseaddress:0x05000000 --define:CODE_ANALYSIS --define:DEBUG --define:NO_STRONG_NAMES --define:RUNTIME --define:DEBUG --define:TRACE --define:FX_FSLIB_STRUCTURAL_EQUALITY --define:FX_FSLIB_IOBSERVABLE --define:FX_FSLIB_LAZY --define:FX_FSLIB_TUPLE --doc:$OUTPUTDIR/FSharp.Core.xml  --optimize- --resource:$BUILD/FSCore.resources --versionfile:../../source-build-version -r:$MONOLIB2/mscorlib.dll -r:System.dll --target:library --nowarn:9,35,40,44,51,57,58,60,62,65,76,77,56,1204,69,65,54,61,75 --warn:3 --warnaserror:76 --fullpaths --flaterrors  --warnon:1182 --compiling-fslib --optimize --maxerrors:20 --extraoptimizationloops:1  --delaysign --version:2.0.0.0 --times --no-jit-optimize --jit-tracking --simpleresolution prim-types-prelude.fsi prim-types-prelude.fs SR.fs prim-types.fsi prim-types.fs local.fsi local.fs array2.fsi array2.fs option.fsi option.fs collections.fsi collections.fs seq.fsi seq.fs string.fsi string.fs list.fsi list.fs array.fsi array.fs array3.fsi array3.fs map.fsi map.fs set.fsi set.fs reflect.fsi reflect.fs event.fsi event.fs math/n.fsi math/n.fs math/z.fsi math/z.fs ../../utils/sformat.fsi ../../utils/sformat.fs printf.fsi printf.fs quotations.fsi quotations.fs nativeptr.fsi nativeptr.fs control.fsi control.fs fslib-extra-pervasives.fsi fslib-extra-pervasives.fs ../../assemblyinfo/assemblyinfo.FSharp.Core.dll.fs

cp "$BUILD/FSharp.Core.dll" "$OUTPUTDIR/FSharp.Core.dll"
cp "$BUILD/FSharp.Core.sigdata" "$OUTPUTDIR/FSharp.Core.sigdata"
cp "$BUILD/FSharp.Core.optdata" "$OUTPUTDIR/FSharp.Core.optdata"

echo "F# library is built ($OUTPUTDIR/FSharp.Core.dll)"
