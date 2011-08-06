#! /bin/sh -e

. ./config.sh
BUILD=obj/Debug/cli/2.0/

cd FSharp.Build
mkdir -p "$BUILD/"
$MONO $LKG/FsSrGen.exe FSBuild.txt $BUILD/FSBuild.fs $BUILD/FSBuild.resx 

resgen /useSourcePath /compile $BUILD/FSBuild.resx,$BUILD/FSBuild.resources 

export MONO_PATH="$FSLIB:$MONO_PATH"

$MONO $PROTO -o:$BUILD/FSharp.Build.dll -g --debug:full --noframework --define:CODE_ANALYSIS --define:DEBUG --define:NO_STRONG_NAMES --define:DEBUG --define:TRACE --define:FX_FSLIB_STRUCTURAL_EQUALITY --define:FX_FSLIB_IOBSERVABLE --define:FX_FSLIB_LAZY --define:FX_FSLIB_TUPLE --doc:$OUTPUTDIR/FSharp.Build.xml --optimize- --resource:$BUILD/FSBuild.resources --versionfile:../../source-build-version -r:$OUTPUTDIR/FSharp.Core.dll -r:"$MONOLIB/Microsoft.Build.Engine.dll" -r:"$MONOLIB/Microsoft.Build.Framework.dll" -r:$MONOLIB/Microsoft.Build.Tasks.v3.5.dll -r:"$MONOLIB/Microsoft.Build.Utilities.v3.5.dll" -r:$MONOLIB2/mscorlib.dll -r:"System.Core.dll" -r:System.dll --target:library --nowarn:69,65,54,61,75 --warn:3 --warnaserror:76 --fullpaths --flaterrors  --times --no-jit-optimize --jit-tracking --simpleresolution $BUILD/FSBuild.fs ../../assemblyinfo/assemblyinfo.FSharp.Build.dll.fs ../../utils/CompilerLocationUtils.fs Fsc.fsi Fsc.fs CreateFSharpManifestResourceName.fsi CreateFSharpManifestResourceName.fs

cp "$BUILD/FSharp.Build.dll" "$OUTPUTDIR/FSharp.Build.dll"

cd ../FSharp.Compiler

mkdir -p $BUILD/

$MONO $LKG/FsSrGen.exe ../FSComp.txt $BUILD/FSComp.fs  $BUILD/FSComp.resx 

resgen /useSourcePath /compile $BUILD/FSComp.resx,$BUILD/FSComp.resources ../FSStrings.resx,$BUILD/FSStrings.resources 

$MONO $LKG/FsLex.exe --unicode -o lex.fs --lexlib Internal.Utilities.Text.Lexing  ../lex.fsl
$MONO $LKG/FsLex.exe --unicode -o illex.fs --lexlib Internal.Utilities.Text.Lexing  ../../absil/illex.fsl 

$MONO $LKG/FsYacc.exe --open Microsoft.FSharp.Compiler --module Microsoft.FSharp.Compiler.Parser -o pars.fs --internal --lexlib Internal.Utilities.Text.Lexing --parslib Internal.Utilities.Text.Parsing  ../pars.fsy 
$MONO $LKG/FsYacc.exe --open Microsoft.FSharp.Compiler.AbstractIL --module Microsoft.FSharp.Compiler.AbstractIL.Internal.AsciiParser -o ilpars.fs --internal --lexlib Internal.Utilities.Text.Lexing --parslib Internal.Utilities.Text.Parsing  ../../absil/ilpars.fsy 

$MONO $PROTO -o:$BUILD/FSharp.Compiler.dll -g --debug:full --noframework --baseaddress:0x06800000 --define:CODE_ANALYSIS --define:DEBUG --define:NO_STRONG_NAMES --define:TRYING_TO_FIX_4577 --define:COMPILER --define:INCLUDE_METADATA_READER --define:INCLUDE_METADATA_WRITER --define:EXTENSIBLE_DUMPER --define:DEBUG --define:TRACE --define:FX_FSLIB_STRUCTURAL_EQUALITY --define:FX_FSLIB_IOBSERVABLE --define:FX_FSLIB_LAZY --define:FX_FSLIB_TUPLE --doc:$OUTPUTDIR/FSharp.Compiler.xml --optimize- --resource:$BUILD/FSComp.resources --resource:$BUILD/FSStrings.resources --versionfile:../../source-build-version -r:$OUTPUTDIR/FSharp.Core.dll -r:$MONOLIB/Microsoft.Build.Engine.dll -r:$MONOLIB/Microsoft.Build.Framework.dll -r:$MONOLIB/Microsoft.Build.Tasks.v3.5.dll -r:$MONOLIB/Microsoft.Build.Utilities.v3.5.dll -r:$MONOLIB2/mscorlib.dll -r:System.dll --target:library --nowarn:44,62,9,1203,69,65,54,61,75 --warn:3 --warnaserror:76 --fullpaths --flaterrors  /warnon:1182 --times --no-jit-optimize --jit-tracking --simpleresolution $BUILD/FSComp.fs ../../assemblyinfo/assemblyinfo.FSharp.Compiler.dll.fs ../ExtensibleDumper.fsi ../ExtensibleDumper.fs ../../utils/sformat.fsi ../../utils/sformat.fs ../sr.fsi ../sr.fs ../../utils/prim-lexing.fsi ../../utils/prim-lexing.fs ../../utils/prim-parsing.fsi ../../utils/prim-parsing.fs ../../utils/resizearray.fsi ../../utils/resizearray.fs ../../utils/HashMultiMap.fsi ../../utils/HashMultiMap.fs ../../utils/TaggedCollections.fsi ../../utils/TaggedCollections.fs ../../utils/filename.fsi ../../utils/filename.fs ../FlatList.fs ../../absil/illib.fs ../../absil/zmap.fsi ../../absil/zmap.fs ../../absil/zset.fsi ../../absil/zset.fs ../../absil/bytes.fsi ../../absil/bytes.fs ../../absil/ildiag.fsi ../../absil/ildiag.fs ../ReferenceResolution.fs ../../absil/il.fsi ../../absil/il.fs ../../absil/ilx.fsi ../../absil/ilx.fs ../../absil/ilascii.fsi ../../absil/ilascii.fs ../../absil/ilprint.fsi ../../absil/ilprint.fs ../../absil/ilmorph.fsi ../../absil/ilmorph.fs ../../absil/ilsupp.fsi ../../absil/ilsupp.fs ilpars.fs illex.fs ../../absil/ilbinary.fsi ../../absil/ilbinary.fs ../lib.fs ../range.fsi ../range.fs ../ErrorLogger.fs ../InternalCollections.fsi ../InternalCollections.fs ../../absil/ilread.fsi ../../absil/ilread.fs ../../absil/ilwrite.fsi ../../absil/ilwrite.fs ../../absil/ilreflect.fs ../../utils/CompilerLocationUtils.fs ../PrettyNaming.fs ../../ilx/ilxsettings.fs ../../ilx/pubclo.fsi ../../ilx/pubclo.fs ../../ilx/cu_erase.fsi ../../ilx/cu_erase.fs ../InternalFileSystemUtils.fsi ../InternalFileSystemUtils.fs ../unilex.fsi ../unilex.fs ../layout.fsi ../layout.fs ../ast.fs pars.fs ../lexhelp.fsi ../lexhelp.fs lex.fs ../sreflect.fsi ../sreflect.fs ../QueueList.fs ../tast.fs ../env.fs ../tastops.fsi ../tastops.fs ../pickle.fsi ../pickle.fs ../lexfilter.fs ../import.fsi ../import.fs ../infos.fs ../augment.fsi ../augment.fs ../outcome.fsi ../outcome.fs ../nameres.fsi ../nameres.fs ../typrelns.fs ../patcompile.fsi ../patcompile.fs ../csolve.fsi ../csolve.fs ../formats.fsi ../formats.fs ../unsolved.fs ../creflect.fsi ../creflect.fs ../check.fsi ../check.fs ../tc.fsi ../tc.fs ../opt.fsi ../detuple.fsi ../opt.fs ../detuple.fs ../tlr.fsi ../tlr.fs ../lowertop.fs ../ilxgen.fsi ../ilxgen.fs ../TraceCall.fs ../build.fsi ../build.fs ../fscopts.fsi ../fscopts.fs ../vs/IncrementalBuild.fsi ../vs/IncrementalBuild.fs ../vs/Reactor.fsi ../vs/Reactor.fs ../vs/service.fsi ../vs/service.fs

cp "$BUILD/FSharp.Compiler.dll" "$OUTPUTDIR/FSharp.Compiler.dll"

cd ../FSharp.Compiler.Server.Shared
mkdir -p "$BUILD/"

$MONO $LKG/FsSrGen.exe ../fsiserver/FSServerShared.txt $BUILD/FSServerShared.fs  $BUILD/FSServerShared.resx 
resgen /useSourcePath /compile $BUILD/FSServerShared.resx,$BUILD/FSServerShared.resources 

$MONO $PROTO -o:$BUILD/FSharp.Compiler.Server.Shared.dll -g --debug:full --noframework --define:CODE_ANALYSIS --define:DEBUG --define:NO_STRONG_NAMES --define:DEBUG --define:TRACE --define:FX_FSLIB_STRUCTURAL_EQUALITY --define:FX_FSLIB_IOBSERVABLE --define:FX_FSLIB_LAZY --define:FX_FSLIB_TUPLE --doc:$OUTPUTDIR/FSharp.Compiler.Server.Shared.xml --optimize- --resource:$BUILD/FSServerShared.resources --versionfile:../../source-build-version -r:$OUTPUTDIR/FSharp.Core.dll -r:$MONOLIB2/mscorlib.dll -r:System.dll -r:System.Runtime.Remoting.dll --target:library --nowarn:69,65,54,61,75 --warn:3 --warnaserror:76 --fullpaths --flaterrors  --times --no-jit-optimize --jit-tracking --simpleresolution $BUILD/FSServerShared.fs ../../assemblyinfo/assemblyinfo.FSharp.Compiler.Server.Shared.dll.fs ../fsiserver/fsiserver.fs 

cp "$BUILD/FSharp.Compiler.Server.Shared.dll" "$OUTPUTDIR/FSharp.Compiler.Server.Shared.dll"

cd ../FSharp.Compiler.Interactive.Settings
mkdir -p "$BUILD/"

$MONO $LKG/FsSrGen.exe ../FSInteractiveSettings.txt $BUILD/FSInteractiveSettings.fs  $BUILD/FSInteractiveSettings.resx

resgen /useSourcePath /compile $BUILD/FSInteractiveSettings.resx,$BUILD/FSInteractiveSettings.resources 

$MONO $PROTO -o:$BUILD/FSharp.Compiler.Interactive.Settings.dll -g --debug:full --noframework --define:CODE_ANALYSIS --define:DEBUG --define:NO_STRONG_NAMES --define:DEBUG --define:TRACE --define:FX_FSLIB_STRUCTURAL_EQUALITY --define:FX_FSLIB_IOBSERVABLE --define:FX_FSLIB_LAZY --define:FX_FSLIB_TUPLE --doc:$OUTPUTDIR/FSharp.Compiler.Interactive.Settings.xml --optimize- --resource:$BUILD/FSInteractiveSettings.resources --versionfile:../../source-build-version -r:$OUTPUTDIR/FSharp.Core.dll -r:$MONOLIB2/mscorlib.dll -r:System.dll --target:library --nowarn:69,65,54,61,75 --warn:3 --warnaserror:76 --fullpaths --flaterrors  --times --no-jit-optimize --jit-tracking --simpleresolution $BUILD/FSInteractiveSettings.fs ../../assemblyinfo/assemblyinfo.FSharp.Compiler.Interactive.Settings.dll.fs ../fsiaux.fsi ../fsiaux.fs ../fsiattrs.fs

cp "$BUILD/FSharp.Compiler.Interactive.Settings.dll" "$OUTPUTDIR/FSharp.Compiler.Interactive.Settings.dll"


cd ../Fsc
mkdir -p "$BUILD/"

$MONO $LKG/FsSrGen.exe ../FSCstrings.txt $BUILD/FSCstrings.fs  $BUILD/FSCstrings.resx 

resgen /useSourcePath /compile $BUILD/FSCstrings.resx,$BUILD/FSCstrings.resources 

$MONO $PROTO -o:$BUILD/fsc.exe -g --debug:full --noframework --define:CODE_ANALYSIS --define:DEBUG --define:NO_STRONG_NAMES --define:COMPILER --define:DEBUG --define:TRACE --define:FX_FSLIB_STRUCTURAL_EQUALITY --define:FX_FSLIB_IOBSERVABLE --define:FX_FSLIB_LAZY --define:FX_FSLIB_TUPLE --doc:$OUTPUTDIR/fsc.xml --optimize- --platform:x86 --resource:$BUILD/FSCstrings.resources --versionfile:../../source-build-version -r:$OUTPUTDIR/FSharp.Compiler.dll -r:$OUTPUTDIR/FSharp.Core.dll -r:$MONOLIB2/mscorlib.dll -r:System.dll -r:System.Runtime.Remoting.dll -r:System.Windows.Forms.dll --target:exe --nowarn:62,44,69,65,54,61,75 --warn:3 --warnaserror:76 --fullpaths --flaterrors  --warnon:1182 --times --no-jit-optimize --jit-tracking --simpleresolution $BUILD/FSCstrings.fs ../../assemblyinfo/assemblyinfo.fsc.exe.fs ../fsc.fs ../fscmain.fs 

cp "$BUILD/fsc.exe" "$OUTPUTDIR/fsc.exe"

cd ../fsi
mkdir -p "$BUILD/"
$MONO $LKG/FsSrGen.exe FSIstrings.txt  $BUILD/FSIstrings.fs  $BUILD/FSIstrings.resx

resgen /useSourcePath /compile $BUILD/FSIstrings.resx,$BUILD/FSIstrings.resources 

$MONO $PROTO -o:$BUILD/fsi.exe -g --debug:full --noframework --baseaddress:0x0A000000 --define:CODE_ANALYSIS --define:DEBUG --define:NO_STRONG_NAMES --define:COMPILER --define:DEBUG --define:TRACE --define:FX_FSLIB_STRUCTURAL_EQUALITY --define:FX_FSLIB_IOBSERVABLE --define:FX_FSLIB_LAZY --define:FX_FSLIB_TUPLE --doc:$OUTPUTDIR/fsi.xml --optimize- --platform:x86 --resource:$BUILD/FSIstrings.resources --versionfile:../../source-build-version -r:$OUTPUTDIR/FSharp.Compiler.dll -r:$OUTPUTDIR/FSharp.Compiler.Interactive.Settings.dll -r:$OUTPUTDIR/FSharp.Compiler.Server.Shared.dll -r:$OUTPUTDIR/FSharp.Core.dll -r:$MONOLIB2/mscorlib.dll -r:System.Core.dll -r:System.dll -r:System.Drawing.dll -r:System.Windows.Forms.dll -r:WindowsBase.dll --target:exe --nowarn:62,44,69,65,54,61,75 --warn:3 --warnaserror:76 --fullpaths --flaterrors  --warnon:1182 --times --no-jit-optimize --jit-tracking --simpleresolution $BUILD/FSIstrings.fs ../../assemblyinfo/assemblyinfo.fsi.exe.fs ../InternalCollections.fsi ../InternalCollections.fs console.fs fsi.fs

cp "$BUILD/fsi.exe" "$OUTPUTDIR/fsi.exe"
echo "F# compiler is built"
echo "fsc: $OUTPUTDIR/fsc.exe"
echo "fsi: $OUTPUTDIR/fsi.exe"
