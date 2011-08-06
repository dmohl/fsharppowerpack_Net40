#! /bin/sh -e

. ./config.sh
BUILD=obj/Proto/cli/2.0/

cd FSharp.Build-proto
mkdir -p $BUILD
mkdir -p $PROTODIR

$MONO $LKG/FsSrGen.exe  ${ROOT}/FSharp.Build/FSBuild.txt $BUILD/FSBuild.fs $BUILD/FSBuild.resx

resgen /useSourcePath /compile $BUILD/FSBuild.resx,$BUILD/FSBuild.resources

$MONO $FSC -I $MONOLIB2 -o:$BUILD/FSharp.Build-proto.dll -g --noframework --define:DEBUG --define:NO_STRONG_NAMES --define:BUILDING_WITH_LKG --define:FX_FSLIB_STRUCTURAL_EQUALITY --define:FX_FSLIB_IOBSERVABLE --define:FX_FSLIB_LAZY --define:FX_FSLIB_TUPLE --doc:$BUILD/FSharp.Build-proto.xml --optimize+ --resource:$BUILD/FSBuild.resources --versionfile:../../source-build-version -r:"$FSLIB/FSharp.Core.dll" -r:"$MONOLIB/Microsoft.Build.Engine.dll" -r:"$MONOLIB/Microsoft.Build.Framework.dll" -r:$MONOLIB/Microsoft.Build.Tasks.v3.5.dll -r:"$MONOLIB/Microsoft.Build.Utilities.v3.5.dll" -r:"$MONOLIB2/mscorlib.dll" -r:"System.Core.dll" -r:"System.dll" --target:library --nowarn:69,65,54,61,75 --warn:3 --warnaserror:76 --fullpaths --flaterrors  --times --simpleresolution $BUILD/FSBuild.fs ../../utils/CompilerLocationUtils.fs ../FSharp.Build/CreateFSharpManifestResourceName.fsi ../FSharp.Build/CreateFSharpManifestResourceName.fs ../FSharp.Build/Fsc.fsi ../FSharp.Build/Fsc.fs

$MONO $LKG/FsLex.exe --unicode -o lex.fs --lexlib Internal.Utilities.Text.Lexing ../lex.fsl
$MONO $LKG/FsLex.exe --unicode -o illex.fs --lexlib Internal.Utilities.Text.Lexing  ../../absil/illex.fsl

cp "$BUILD/FSharp.Build-proto.dll" "$PROTODIR/FSharp.Build-proto.dll"


cd ../FSharp.Compiler-proto
mkdir -p "$BUILD/"

$MONO $LKG/FsSrGen.exe ../FSComp.txt  $BUILD/FSComp.fs  $BUILD/FSComp.resx

resgen /useSourcePath /compile obj/Proto/cli/2.0/FSComp.resx,$BUILD/FSComp.resources ../FSStrings.resx,$BUILD/FSStrings.resources
# /r:"Fsharp.Core.dll" /r:"$MONOLIB/Microsoft.Build.Engine.dll" /r:"$MONOLIB/Microsoft.Build.Framework.dll" /r:"$MONOLIB/Microsoft.Build.Tasks.v3.5.dll" /r:"$MONOLIB/Microsoft.Build.Utilities.v3.5.dll" /r:"$MONOLIB2/mscorlib.dll" /r:"System.Core.dll" /r:"System.dll"

$MONO $LKG/FsLex.exe --unicode -o lex.fs --lexlib Internal.Utilities.Text.Lexing  ../lex.fsl
$MONO $LKG/FsLex.exe --unicode -o illex.fs --lexlib Internal.Utilities.Text.Lexing  ../../absil/illex.fsl

$MONO $LKG/FsYacc.exe --open Microsoft.FSharp.Compiler --module Microsoft.FSharp.Compiler.Parser -o pars.fs --internal --lexlib Internal.Utilities.Text.Lexing --parslib Internal.Utilities.Text.Parsing  ../pars.fsy

$MONO $LKG/FsYacc.exe --open Microsoft.FSharp.Compiler.AbstractIL --module Microsoft.FSharp.Compiler.AbstractIL.Internal.AsciiParser -o ilpars.fs --internal --lexlib Internal.Utilities.Text.Lexing --parslib Internal.Utilities.Text.Parsing  ../../absil/ilpars.fsy

$MONO $FSC -o:$BUILD/FSharp.Compiler-proto.dll -g --noframework --define:DEBUG  --define:NO_STRONG_NAMES --define:TRYING_TO_FIX_4577 --define:BUILDING_PROTO --define:BUILDING_WITH_LKG --define:COMPILER --define:INCLUDE_METADATA_READER --define:INCLUDE_METADATA_WRITER --define:FX_FSLIB_STRUCTURAL_EQUALITY --define:FX_FSLIB_IOBSERVABLE --define:FX_FSLIB_LAZY --define:FX_FSLIB_TUPLE --doc:$PROTODIR/FSharp.Compiler-proto.xml --optimize+ --resource:$BUILD/FSComp.resources --resource:$BUILD/FSStrings.resources --versionfile:../../source-build-version -r:"$FSLIB/FSharp.Core.dll" -r:"$MONOLIB/Microsoft.Build.Engine.dll" -r:"$MONOLIB/Microsoft.Build.Framework.dll" -r:"$MONOLIB/Microsoft.Build.Tasks.v3.5.dll" -r:"$MONOLIB/Microsoft.Build.Utilities.v3.5.dll" -r:"$MONOLIB2/mscorlib.dll" -r:"System.dll" --target:library --nowarn:35,44,62,9,60,86,47,1203,69,65,54,61,75 --warn:3 --warnaserror:76 --fullpaths --flaterrors  --warnon:1182 --times --simpleresolution $BUILD/FSComp.fs ../../assemblyinfo/assemblyinfo.FSharp.Compiler.dll.fs ../../utils/sformat.fsi ../../utils/sformat.fs ../sr.fsi ../sr.fs ../../utils/prim-lexing.fsi ../../utils/prim-lexing.fs ../../utils/prim-parsing.fsi ../../utils/prim-parsing.fs ../../utils/resizearray.fsi ../../utils/resizearray.fs ../../utils/HashMultiMap.fsi ../../utils/HashMultiMap.fs ../../utils/TaggedCollections.fsi ../../utils/TaggedCollections.fs ../../utils/filename.fsi ../../utils/filename.fs ../FlatList.fs ../../absil/illib.fs ../../absil/zmap.fsi ../../absil/zmap.fs ../../absil/zset.fsi ../../absil/zset.fs ../../absil/bytes.fsi ../../absil/bytes.fs ../../absil/ildiag.fsi ../../absil/ildiag.fs ../ReferenceResolution.fs ../../absil/il.fsi ../../absil/il.fs ../../absil/ilx.fsi ../../absil/ilx.fs ../../absil/ilascii.fsi ../../absil/ilascii.fs ../../absil/ilprint.fsi ../../absil/ilprint.fs ../../absil/ilmorph.fsi ../../absil/ilmorph.fs ../../absil/ilsupp.fsi ../../absil/ilsupp.fs ilpars.fs illex.fs ../../absil/ilbinary.fsi ../../absil/ilbinary.fs ../lib.fs ../range.fsi ../range.fs ../ErrorLogger.fs ../InternalCollections.fsi ../InternalCollections.fs ../../absil/ilread.fsi ../../absil/ilread.fs ../../absil/ilwrite.fsi ../../absil/ilwrite.fs ../../absil/ilreflect.fs ../../utils/CompilerLocationUtils.fs ../PrettyNaming.fs ../../ilx/ilxsettings.fs ../../ilx/pubclo.fsi ../../ilx/pubclo.fs ../../ilx/cu_erase.fs ../InternalFileSystemUtils.fsi ../InternalFileSystemUtils.fs ../unilex.fsi ../unilex.fs ../layout.fsi ../layout.fs ../ast.fs pars.fs ../lexhelp.fsi ../lexhelp.fs lex.fs ../sreflect.fsi ../sreflect.fs ../QueueList.fs ../tast.fs ../env.fs ../tastops.fsi ../tastops.fs ../pickle.fsi ../pickle.fs ../lexfilter.fs ../import.fsi ../import.fs ../infos.fs ../augment.fsi ../augment.fs ../typrelns.fs ../patcompile.fsi ../patcompile.fs ../outcome.fsi ../outcome.fs ../csolve.fsi ../csolve.fs ../formats.fsi ../formats.fs ../nameres.fsi ../nameres.fs ../unsolved.fs ../creflect.fsi ../creflect.fs ../check.fsi ../check.fs ../tc.fsi ../tc.fs ../opt.fsi ../opt.fs ../detuple.fsi ../detuple.fs ../tlr.fsi ../tlr.fs ../lowertop.fs ../ilxgen.fsi ../ilxgen.fs ../TraceCall.fs ../build.fsi ../build.fs ../fscopts.fsi ../fscopts.fs ../vs/IncrementalBuild.fsi ../vs/IncrementalBuild.fs

cp "$BUILD/FSharp.Compiler-proto.dll" "$PROTODIR/FSharp.Compiler-proto.dll"



# Build fsc-proto.exe
cd ../Fsc-proto/

mkdir -p obj/Proto/cli/2.0

$MONO $LKG/FsSrGen.exe  ../FSCstrings.txt  $BUILD/FSCstrings.fs  $BUILD/FSCstrings.resx

resgen /compile $BUILD/FSCstrings.resx,$BUILD/FSCstrings.resources

$MONO $FSC -o:$BUILD/fsc-proto.exe -g --noframework --define:DEBUG  --define:NO_STRONG_NAMES --define:BUILDING_PROTO --define:BUILDING_WITH_LKG --define:COMPILER --define:FX_FSLIB_STRUCTURAL_EQUALITY --define:FX_FSLIB_IOBSERVABLE --define:FX_FSLIB_LAZY --define:FX_FSLIB_TUPLE --doc:$PROTODIR/fsc-proto.xml --optimize+ --platform:x86 --resource:$BUILD/FSCstrings.resources --versionfile:../../source-build-version -r:$PROTODIR/FSharp.Compiler-proto.dll -r:"$FSLIB/FSharp.Core.dll" -r:"$MONOLIB2/mscorlib.dll" -r:"System.Core.dll" -r:"System.dll" -r:"System.Runtime.Remoting.dll" -r:"System.Windows.Forms.dll" --target:exe --nowarn:62,69,65,54,61,75 --warn:3 --warnaserror:76 --fullpaths --flaterrors  --stackReserveSize:4096000 --times --simpleresolution $BUILD/FSCstrings.fs ../../utils/filename.fsi ../../utils/filename.fs ../fsc.fs ../fscmain.fs

cp $BUILD/fsc-proto.exe $PROTODIR/fsc-proto.exe
echo "F# proto is built ($PROTODIR/fsc-proto.exe)"

# For testing:
# MONO_PATH="$MONOLIB:$FSLIB" mono fsc-proto.exe -I $FSLIB file.fs
