
cd FSharp.PowerPack
C:\Windows\Microsoft.NET\Framework\v4.0.30319\msbuild /p:TargetFramework=Silverlight /p:SilverlightVersion=2.0 %1 %2 %3 %4 %5 %6 %7 %8 %9
cd ..

cd FSharp.PowerPack.Compatibility
C:\Windows\Microsoft.NET\Framework\v4.0.30319\msbuild /p:TargetFramework=Silverlight %1 %2 %3 %4 %5 %6 %7 %8 %9
cd ..

cd FSharp.PowerPack.Linq
C:\Windows\Microsoft.NET\Framework\v4.0.30319\msbuild /p:TargetFramework=Silverlight %1 %2 %3 %4 %5 %6 %7 %8 %9
cd ..

cd FSharp.PowerPack.Unittests
C:\Windows\Microsoft.NET\Framework\v4.0.30319\msbuild /p:TargetFramework=Silverlight %1 %2 %3 %4 %5 %6 %7 %8 %9
cd ..
