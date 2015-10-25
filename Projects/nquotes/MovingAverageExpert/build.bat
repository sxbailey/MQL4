@echo off

rem set a compiler path
set CSharpCompiler=c:\Windows\Microsoft.NET\Framework\v4.0.30319\csc.exe
rem example for Mono C# compiler :
rem set CSharpCompiler=call "c:\Program Files\Mono-2.10.8\bin\dmcs.bat"

%CSharpCompiler% /target:library /reference:..\..\..\libraries\nquotes\nquotes.dll /reference:System.dll /reference:System.Drawing.dll *.cs Properties\AssemblyInfo.cs
copy /Y *.dll ..\..\..\Experts\

pause
