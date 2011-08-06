#!/bin/sh
# This script is for use with CLIs on Unix, e.g. Mono

if [ -e mono.snk ]; then
  # A mono.snk exists so re-sign FSharp.Core.dll and GAC install
  echo -- Resigning FSharp.Core.dll with mono.snk
  sn -q -R bin/FSharp.Core.dll mono.snk
else
  # Advise on the options for making the DLLs locatable on Mono.
  echo "In order to add FSharp.Core.dll to the Mono GAC the DLL needs to be"
  echo "re-signed with the mono.snk key. The mono.snk key is available from"
  echo "the 'Mono Sources'."
  echo ""
  echo "  http://www.mono-project.com/"
  echo "  http://github.com/mono/mono/raw/master/mcs/class/mono.snk" 
  echo ""
  echo "For example, run:"
  echo "  wget -O mono.snk http://github.com/mono/mono/raw/master/mcs/class/mono.snk" 
  echo ""
  echo "Then re-run this script."
  echo ""
  echo "An alternative to installing the DLLs in the Mono GAC is to add the"
  echo "FSharp bin directory to the MONO_PATH variable. For more information"
  echo "on 'How Mono Finds Assemblies' see http://www.mono-project.com/Gacutil"
  exit 0
fi

# GAC installing FSharp DLLs
echo -- Installing FSharp DLLS into the GAC
gacutil -i bin/FSharp.Core.dll

# On some linux systems, these can be run directly
chmod ugo+rx bin/fsc.exe
chmod ugo+rx bin/fsi.exe

