@echo off
REM ============================================================================
REM  Clean Architecture — Projekt-skelet
REM  Kursus: Datamatiker 2. og 3. Semester
REM
REM  Kør denne fil i en tom mappe. Den opretter:
REM    - Solution med 5 src-projekter og 2 testprojekter
REM    - Korrekte projekt-referencer (Dependency Rule)
REM    - NuGet-pakker (EF Core 10, Scalar, xunit.v3, Moq)
REM    - Mappestruktur i hvert projekt
REM ============================================================================

echo.
echo ============================================
echo  Assignment : Projekt-skelet
echo ============================================
echo.

call :AskProjectName
call :CreateProjectFolder
call :CreateSolution
call :CreatePrensentationBlazorProject
call :CreateApi
call :CreateSharedClassLib
call :AddProjectsToSolution
call :AddProjectsReferences
call :AddAPINuGetPackages
call :AddFolderStructure
call :AddDummyFiles
call :AddLaunchFile
call :RemoveHttpFile
call :AddHttpFile
call :BuildSolution
call :ShowOverview
exit /b




:AskProjectName
set /p PROJ_NAME="Indtast projektnavn (f.eks. MinKlinik): "

if "%PROJ_NAME%"=="" (
    echo FEJL: Projektnavn maa ikke vaere tomt.
    pause
    exit /b 1
)

REM Tjek for mellemrum
echo %PROJ_NAME%| findstr /C:" " >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo FEJL: Projektnavn maa ikke indeholde mellemrum.
    pause
    exit /b 1
)
exit /b

:CreateProjectFolder
echo.
echo Opretter projekt: %PROJ_NAME%
echo.

REM === Opret og gå ind i projektmappe ===
if exist %PROJ_NAME% (
    echo FEJL: Mappen %PROJ_NAME% eksisterer allerede.
    pause
    exit /b 1
)
mkdir %PROJ_NAME%
cd %PROJ_NAME%
exit /b

:CreateSolution
dotnet new sln -n %PROJ_NAME%
if %ERRORLEVEL% NEQ 0 (
    echo FEJL: Kunne ikke oprette solution. Er .NET 10 SDK installeret?
    pause
    exit /b 1
)
exit /b

:CreatePrensentationBlazorProject
echo [1/3] Blazor (Blazor Webassembly - ingen afhaengigheder)
dotnet new 	blazorwasm -n %PROJ_NAME%.Web -o %PROJ_NAME%.Web -f net10.0 -p true
del %PROJ_NAME%.Web\Pages\Weather.razor 2>nul
del %PROJ_NAME%.Web\Pages\Counter.razor 2>nul
exit /b

:CreateApi
echo [2/3] Api (webapi - ingen afhaengigheder)
dotnet new webapi -n %PROJ_NAME%.Api -o %PROJ_NAME%.Api -f net10.0 --use-controllers
del %PROJ_NAME%.Api\Controllers\WeatherForecastController.cs 2>nul
del %PROJ_NAME%.Api\WeatherForecast.cs 2>nul
exit /b

:CreateSharedClassLib
echo [3/3] SharedLib (classlib - refererer API + Presentation)
dotnet new classlib -n %PROJ_NAME%.SharedLib -o %PROJ_NAME%.SharedLib -f net10.0
del %PROJ_NAME%.SharedLib\Class1.cs 2>nul
exit /b

:AddProjectsToSolution
echo.
echo Tilfojer projekter til solution...
dotnet sln add %PROJ_NAME%.Web\%PROJ_NAME%.Web.csproj
dotnet sln add %PROJ_NAME%.Api\%PROJ_NAME%.Api.csproj
dotnet sln add %PROJ_NAME%.SharedLib\%PROJ_NAME%.SharedLib.csproj
exit /b


:AddProjectsReferences
echo.
echo Opsaetter projekt-referencer (Dependency Rule)...

REM SharedLib -> Web + Api
dotnet add %PROJ_NAME%.Web\%PROJ_NAME%.Web.csproj reference %PROJ_NAME%.SharedLib\%PROJ_NAME%.SharedLib.csproj
dotnet add %PROJ_NAME%.Api\%PROJ_NAME%.Api.csproj reference %PROJ_NAME%.SharedLib\%PROJ_NAME%.SharedLib.csproj
exit /b


:AddAPINuGetPackages
echo.
echo Installerer Entiry Framework NuGet-pakker...

REM Api: OpenApi + Scalar
dotnet add %PROJ_NAME%.Api\%PROJ_NAME%.Api.csproj package Microsoft.AspNetCore.OpenApi
dotnet add %PROJ_NAME%.Api\%PROJ_NAME%.Api.csproj package Microsoft.OpenApi -v 2.11.0
dotnet add %PROJ_NAME%.Api\%PROJ_NAME%.Api.csproj package Scalar.AspNetCore
exit /b

:AddFolderStructure
REM === Mappestruktur ===
echo.
echo Opretter mappestruktur...

REM SharedLib
mkdir %PROJ_NAME%.SharedLib\DTOs 2>nul
exit /b

:AddDummyFiles
REM === Dummy.cs i tomme mapper ===
echo.
echo Tilfojer dummy.cs i tomme mapper...

REM SharedLib
(
echo namespace %PROJ_NAME%.SharedLib.DTOs;
echo.
echo // Placeholder - erstattes med faktisk kode
) > %PROJ_NAME%.SharedLib\DTOs\dummy.cs

(
echo namespace %PROJ_NAME%.Api.controllers;
echo.
echo // Placeholder - erstattes med faktisk kode
) > %PROJ_NAME%.Api\Controllers\dummy.cs

exit /b

:AddLaunchFile
REM === sln Launch file ===
echo.
echo Opretter launch fil...

(
echo [
echo  {
echo    "Name": "Samlet solution",
echo    "Projects": [
echo     {
echo       "Path": "%PROJ_NAME%.Api\\%PROJ_NAME%.Api.csproj",
echo       "Action": "Start"
echo     },
echo     {
echo       "Path": "%PROJ_NAME%.Web\\%PROJ_NAME%.Web.csproj",
echo       "Action": "Start"
echo     }
echo    ]
echo  }
echo ]
) > %PROJ_NAME%.slnLaunch
exit /b

:RemoveHttpFile
REM === fjern nuværende http fil ===
echo.
echo Fjerner http fil

del %PROJ_NAME%.Api\%PROJ_NAME%.Api.http 2>nul
exit /b

:AddHttpFile
REM === opretter ny http file ===
echo.
echo Opretter ny http fil

(
echo @test.Api_HostAddress = http://localhost:5294
echo.
echo.
echo ###
) > %PROJ_NAME%.Api\%PROJ_NAME%.Api.http
exit /b


:BuildSolution
echo.
echo Bygger solution...
dotnet build
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ADVARSEL: Build fejlede. Tjek fejlmeddelelserne ovenfor.
) else (
    echo.
    echo Build OK!
)
exit /b

:ShowOverview
echo.
echo ============================================
echo  %PROJ_NAME% Projekt-skelet oprettet!
echo ============================================
echo.
echo  Struktur:
echo    %PROJ_NAME%.Web\                  ^(ingen afhaengigheder^)
echo    %PROJ_NAME%.Api\                  ^(ingen afhaengigheder^)
echo    %PROJ_NAME%.SharedLib\             ^(refererer Web + Api^)

echo.
echo  NuGet-pakker:
echo    Api: OpenApi
echo    Api: Scalar
echo.
echo.
echo  Naeste skridt:
echo    1. Aaben %PROJ_NAME%.slnx i Visual Studio
echo  	2. Indsaet reference til scalar i %PROJ_NAME%.Api\program.cs (app.MapScalarApiReference();)
echo.
pause
exit /b