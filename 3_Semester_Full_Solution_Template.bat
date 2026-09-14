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
echo  Clean Architecture : Projekt-skelet
echo ============================================
echo.

call :AskProjectName
call :AskMicroservice

call :CreateProjectFolder
call :CreateSolution

echo.
if %MICROSERVICE%==1 (
    call :CreateMicroServiceBlazorProject
	call :CreateMicroServiceBlazorTests
	call :CreateMicroServiceSharedKernelLib
	call :CreateMicroServiceBuildingBlocksLib
	call :CreateMicroServiceContractsLib
	call :AddInitialProjectsToSolution
	call :AddInitialProjectReferences
	call :AddInitialFolderStructure
	call :AddInitialDummyFiles
	call :ShowInitialProjectOverview
	
	echo Opretter microservice
    call :CreateMicroService   
)
if %MICROSERVICE%==0 (
    call :CreateMonolitDomainClassLib
    call :CreateMonolitFacadeClassLib
    call :CreateMonolitApplicationClassLib
    call :CreateMonolitInfrastructureClassLib
    call :CreateMonolitBlazorWASMProject
	call :CreateMonolitApiProject
    call :CreateMonolitDomainLibTests
    call :CreateMonolitApplicationLibTests
	call :CreateMonolitBlazorTests
    call :AddMonolitProjectsToSolution
    call :AddMonolitProjectsReferences
    call :AddMonolitNuGetPackages
    call :AddMonolitFolderStructure
    call :AddMonolitDummyFiles
    call :AddMonolitStartFiles
    call :BuildSolution
    call :ShowMonolitOverview
)

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

:AskMicroservice
choice /C JN /M "Skal der bruges microservice skabelon:"

if errorlevel 2 (
    set MICROSERVICE=0
) else (
    set MICROSERVICE=1
    call :AskServiceName
)
exit /b


:AskServiceName
set /p MICROSERVICE_NAME="Indtast navn paa microservice (f.eks. BookingService): "
if "%MICROSERVICE_NAME%"=="" (
    echo FEJL: microservice navn maa ikke vaere tomt.
    pause
    exit /b 1
)
REM Tjek for mellemrum
echo %MICROSERVICE_NAME%| findstr /C:" " >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo FEJL: microservice navn maa ikke indeholde mellemrum.
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


REM =================================================================================================================================================
REM MicroService
REM =================================================================================================================================================

:CreateMicroServiceBlazorProject
echo Blazor (Blazor Webassembly ingen afhaengigheder)
dotnet new 	blazorwasm -n %PROJ_NAME%.Web -o src\%PROJ_NAME%.Web -f net10.0 -p true
del src\%PROJ_NAME%.Web\Components\Pages\Weather.razor 2>nul
del src\%PROJ_NAME%.Web\Components\Pages\Counter.razor 2>nul
exit /b

:CreateMicroServiceBlazorTests
echo Blazor Tests (bunit)
dotnet new bunit --framework xunitv3 -n %PROJ_NAME%.Web.Tests -o tests\%PROJ_NAME%.Web.Tests
del tests\%PROJ_NAME%.Web.Tests\Counter.razor 2>nul
del tests\%PROJ_NAME%.Web.Tests\CounterCSharpTest.cs 2>nul
del tests\%PROJ_NAME%.Web.Tests\CounterRazorTests.razor 2>nul
exit /b

:CreateMicroServiceSharedKernelLib
echo SharedKernelLib (classlib - refererer Api + Application + Domain + Infrastructure)
dotnet new classlib -n %PROJ_NAME%.SharedKernelLib -o src\Shared\%PROJ_NAME%.SharedKernelLib -f net10.0
del src\Shared\%PROJ_NAME%.SharedKernelLib\Class1.cs 2>nul
exit /b

:CreateMicroServiceBuildingBlocksLib
echo BuildingBlocksLib (classlib - refererer Api + Infrastructure)
dotnet new classlib -n %PROJ_NAME%.BuildingBlocksLib -o src\Shared\%PROJ_NAME%.BuildingBlocksLib -f net10.0
del src\Shared\%PROJ_NAME%.BuildingBlocksLib\Class1.cs 2>nul
exit /b

:CreateMicroServiceContractsLib
echo ContractsLib (classlib - refererer Api + Application + Infrastructure)
dotnet new classlib -n %PROJ_NAME%.ContractsLib -o src\Shared\%PROJ_NAME%.ContractsLib -f net10.0
del src\Shared\%PROJ_NAME%.ContractsLib\Class1.cs 2>nul
exit /b

:CreateMicroServiceDomainClassLib
echo [1/7] DomainLib (classlib - ingen afhaengigheder)
dotnet new classlib -n %MICROSERVICE_NAME%.DomainLib -o src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.DomainLib -f net10.0
del src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.DomainLib\Class1.cs 2>nul
exit /b

:CreateMicroServiceFacadeClassLib
echo [2/7] FacadeLib (classlib - ingen afhaengigheder)
dotnet new classlib -n %MICROSERVICE_NAME%.FacadeLib -o src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.FacadeLib -f net10.0
del src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.FacadeLib\Class1.cs 2>nul
exit /b

:CreateMicroServiceApplicationClassLib
echo [3/7] ApplicationLib (classlib - refererer Domain + Facade)
dotnet new classlib -n %MICROSERVICE_NAME%.ApplicationLib -o src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.ApplicationLib -f net10.0
del src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.ApplicationLib\Class1.cs 2>nul
exit /b

:CreateMicroServiceInfrastructureClassLib
echo [4/7] InfrastructureLib (classlib - refererer Domain + Facade + Application)
dotnet new classlib -n %MICROSERVICE_NAME%.InfrastructureLib -o src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.InfrastructureLib -f net10.0
del src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.InfrastructureLib\Class1.cs 2>nul
exit /b

:CreateMicroServiceApi
echo [5/7] Api (webapi - refererer Facade + Infrastructure + Application)
dotnet new webapi -n %MICROSERVICE_NAME%.Api -o src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.Api -f net10.0 --use-controllers
del src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.Api\Controllers\WeatherForecastController.cs 2>nul
del src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.Api\WeatherForecast.cs 2>nul
exit /b

:CreateMicroServiceDomainLibTests
echo [6/7] DomainLib.Tests (xunit.v3)
dotnet new xunit3 -n %MICROSERVICE_NAME%.DomainLib.Tests -o tests\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.DomainLib.Tests -f net10.0
del tests\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.DomainLib.Tests\UnitTest1.cs 2>nul
exit /b

:CreateMicroServiceApplicationLibTests
echo [7/7] Application.Tests (xunit.v3)
dotnet new xunit3 -n %MICROSERVICE_NAME%.ApplicationLib.Tests -o tests\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.ApplicationLib.Tests -f net10.0
del tests\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.ApplicationLib.Tests\UnitTest1.cs 2>nul
exit /b


:CreateMicroService
call :CreateMicroServiceDomainClassLib
call :CreateMicroServiceFacadeClassLib
call :CreateMicroServiceApplicationClassLib
call :CreateMicroServiceInfrastructureClassLib
call :CreateMicroServiceApi
call :CreateMicroServiceDomainLibTests
call :CreateMicroServiceApplicationLibTests
call :AddMicroServiceProjectsToSolution
call :AddMicroServiceProjectsReferences
call :AddMicroServiceNuGetPackages
call :AddMicroServiceFolderStructure
call :AddMicroServiceDummyFiles
call :AddMicroServiceStartFiles
call :BuildSolution
call :ShowMicroServiceOverview
call :AskAnotherMicroService
exit /b

:AddInitialProjectsToSolution
echo.
echo Tilfojer initial projekter til solution...
dotnet sln add src\%PROJ_NAME%.Web\%PROJ_NAME%.Web.csproj
dotnet sln add src\Shared\%PROJ_NAME%.SharedKernelLib\%PROJ_NAME%.SharedKernelLib.csproj
dotnet sln add src\Shared\%PROJ_NAME%.BuildingBlocksLib\%PROJ_NAME%.BuildingBlocksLib.csproj
dotnet sln add src\Shared\%PROJ_NAME%.ContractsLib\%PROJ_NAME%.ContractsLib.csproj
dotnet sln add tests\%PROJ_NAME%.Web.Tests\%PROJ_NAME%.Web.Tests.csproj
exit /b

:AddMicroServiceProjectsToSolution
echo.
echo Tilfojer microservice projekter til solution...
dotnet sln add src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.DomainLib\%MICROSERVICE_NAME%.DomainLib.csproj
dotnet sln add src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.FacadeLib\%MICROSERVICE_NAME%.FacadeLib.csproj
dotnet sln add src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.ApplicationLib\%MICROSERVICE_NAME%.ApplicationLib.csproj
dotnet sln add src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.InfrastructureLib\%MICROSERVICE_NAME%.InfrastructureLib.csproj
dotnet sln add src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.Api\%MICROSERVICE_NAME%.Api.csproj
dotnet sln add tests\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.DomainLib.Tests\%MICROSERVICE_NAME%.DomainLib.Tests.csproj
dotnet sln add tests\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.ApplicationLib.Tests\%MICROSERVICE_NAME%.ApplicationLib.Tests.csproj
exit /b


:AddInitialProjectReferences
echo.
echo Opsaetter initial projekt-referencer (Dependency Rule)...

REM Blazor.Tests -> Blazor Web
dotnet add tests\%PROJ_NAME%.Web.Tests\%PROJ_NAME%.Web.Tests.csproj reference src\%PROJ_NAME%.Web\%PROJ_NAME%.Web.csproj
exit /b

:AddMicroServiceProjectsReferences
echo.
echo Opsaetter projekt-referencer (Dependency Rule)...

REM Application -> Domain + Facade
dotnet add src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.ApplicationLib\%MICROSERVICE_NAME%.ApplicationLib.csproj reference src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.DomainLib\%MICROSERVICE_NAME%.DomainLib.csproj
dotnet add src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.ApplicationLib\%MICROSERVICE_NAME%.ApplicationLib.csproj reference src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.FacadeLib\%MICROSERVICE_NAME%.FacadeLib.csproj

REM Infrastructure -> Domain + Facade + Application
dotnet add src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.InfrastructureLib\%MICROSERVICE_NAME%.InfrastructureLib.csproj reference src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.DomainLib\%MICROSERVICE_NAME%.DomainLib.csproj
dotnet add src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.InfrastructureLib\%MICROSERVICE_NAME%.InfrastructureLib.csproj reference src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.FacadeLib\%MICROSERVICE_NAME%.FacadeLib.csproj
dotnet add src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.InfrastructureLib\%MICROSERVICE_NAME%.InfrastructureLib.csproj reference src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.ApplicationLib\%MICROSERVICE_NAME%.ApplicationLib.csproj

REM API -> Facade + Infrastructure + Application
dotnet add src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.Api\%MICROSERVICE_NAME%.Api.csproj reference src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.FacadeLib\%MICROSERVICE_NAME%.FacadeLib.csproj
dotnet add src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.Api\%MICROSERVICE_NAME%.Api.csproj reference src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.InfrastructureLib\%MICROSERVICE_NAME%.InfrastructureLib.csproj
dotnet add src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.Api\%MICROSERVICE_NAME%.Api.csproj reference src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.ApplicationLib\%MICROSERVICE_NAME%.ApplicationLib.csproj

REM Domain.Tests -> Domain
dotnet add tests\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.DomainLib.Tests\%MICROSERVICE_NAME%.DomainLib.Tests.csproj reference src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.DomainLib\%MICROSERVICE_NAME%.DomainLib.csproj

REM Application.Tests -> Domain + Facade + Application
dotnet add tests\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.ApplicationLib.Tests\%MICROSERVICE_NAME%.ApplicationLib.Tests.csproj reference src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.DomainLib\%MICROSERVICE_NAME%.DomainLib.csproj
dotnet add tests\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.ApplicationLib.Tests\%MICROSERVICE_NAME%.ApplicationLib.Tests.csproj reference src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.FacadeLib\%MICROSERVICE_NAME%.FacadeLib.csproj
dotnet add tests\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.ApplicationLib.Tests\%MICROSERVICE_NAME%.ApplicationLib.Tests.csproj reference src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.ApplicationLib\%MICROSERVICE_NAME%.ApplicationLib.csproj

REM API -> SharedKernel
dotnet add src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.Api\%MICROSERVICE_NAME%.Api.csproj reference src\Shared\%PROJ_NAME%.SharedKernelLib\%PROJ_NAME%.SharedKernelLib.csproj

REM Application -> SharedKernel
dotnet add src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.ApplicationLib\%MICROSERVICE_NAME%.ApplicationLib.csproj reference src\Shared\%PROJ_NAME%.SharedKernelLib\%PROJ_NAME%.SharedKernelLib.csproj

REM Domain -> SharedKernel
dotnet add src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.DomainLib\%MICROSERVICE_NAME%.DomainLib.csproj reference src\Shared\%PROJ_NAME%.SharedKernelLib\%PROJ_NAME%.SharedKernelLib.csproj

REM Infrastructure -> SharedKernel
dotnet add src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.InfrastructureLib\%MICROSERVICE_NAME%.InfrastructureLib.csproj reference src\Shared\%PROJ_NAME%.SharedKernelLib\%PROJ_NAME%.SharedKernelLib.csproj

REM API -> BuildingBlocks
dotnet add src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.Api\%MICROSERVICE_NAME%.Api.csproj reference src\Shared\%PROJ_NAME%.BuildingBlocksLib\%PROJ_NAME%.BuildingBlocksLib.csproj

REM Infrastructure -> BuildingBlocks
dotnet add src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.InfrastructureLib\%MICROSERVICE_NAME%.InfrastructureLib.csproj reference src\Shared\%PROJ_NAME%.BuildingBlocksLib\%PROJ_NAME%.BuildingBlocksLib.csproj

REM API -> Contracts
dotnet add src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.Api\%MICROSERVICE_NAME%.Api.csproj reference src\Shared\%PROJ_NAME%.ContractsLib\%PROJ_NAME%.ContractsLib.csproj

REM Application -> Contracts
dotnet add src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.ApplicationLib\%MICROSERVICE_NAME%.ApplicationLib.csproj reference src\Shared\%PROJ_NAME%.ContractsLib\%PROJ_NAME%.ContractsLib.csproj

REM Infrastructure -> Contracts
dotnet add src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.InfrastructureLib\%MICROSERVICE_NAME%.InfrastructureLib.csproj reference src\Shared\%PROJ_NAME%.ContractsLib\%PROJ_NAME%.ContractsLib.csproj

exit /b


:AddMicroServiceNuGetPackages
echo.
echo Installerer Entiry Framework NuGet-pakker...

REM Infrastructure: EF Core 10
dotnet add src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.InfrastructureLib\%MICROSERVICE_NAME%.InfrastructureLib.csproj package Microsoft.EntityFrameworkCore
dotnet add src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.InfrastructureLib\%MICROSERVICE_NAME%.InfrastructureLib.csproj package Microsoft.EntityFrameworkCore.SqlServer
dotnet add src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.InfrastructureLib\%MICROSERVICE_NAME%.InfrastructureLib.csproj package Microsoft.EntityFrameworkCore.Tools

REM Api: OpenApi + Scalar
dotnet add src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.Api\%MICROSERVICE_NAME%.Api.csproj package Microsoft.AspNetCore.OpenApi
dotnet add src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.Api\%MICROSERVICE_NAME%.Api.csproj package Microsoft.OpenApi -v 2.11.0
dotnet add src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.Api\%MICROSERVICE_NAME%.Api.csproj package Scalar.AspNetCore

REM Tests: xunit3-template giver allerede xunit.v3 — tilfoej kun Moq til Application.Tests
dotnet add tests\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.ApplicationLib.Tests\%MICROSERVICE_NAME%.ApplicationLib.Tests.csproj package Moq
exit /b

:AddMicroServiceFolderStructure
REM === Mappestruktur ===
echo.
echo Opretter mappestruktur...

REM DomainLib
mkdir src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.DomainLib\Entities 2>nul
mkdir src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.DomainLib\Enums 2>nul

REM FacadeLib
mkdir src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.FacadeLib\Commands 2>nul
mkdir src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.FacadeLib\Commands\DTOs 2>nul
mkdir src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.FacadeLib\Commands\Interfaces 2>nul
mkdir src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.FacadeLib\Queries 2>nul
mkdir src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.FacadeLib\Queries\DTOs 2>nul
mkdir src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.FacadeLib\Queries\Interfaces 2>nul

REM ApplicationLib
mkdir src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.ApplicationLib\Handlers 2>nul
mkdir src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.ApplicationLib\Repositories 2>nul
mkdir src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.ApplicationLib\Extensions 2>nul

REM InfrastructureLib
mkdir src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.InfrastructureLib\Persistence 2>nul
mkdir src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.InfrastructureLib\Persistence\EF_Configurations 2>nul
mkdir src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.InfrastructureLib\Repositories 2>nul
mkdir src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.InfrastructureLib\QueryHandlers 2>nul
mkdir src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.InfrastructureLib\Extensions 2>nul
exit /b

:AddInitialFolderStructure
REM === Mappestruktur til Shared folder ===
echo.
echo Opretter Mappestruktur for Shared folder...

REM SharedKernel
mkdir src\Shared\%PROJ_NAME%.SharedKernelLib\Exceptions 2>nul
mkdir src\Shared\%PROJ_NAME%.SharedKernelLib\ValueObjects 2>nul
mkdir src\Shared\%PROJ_NAME%.SharedKernelLib\Results 2>nul

REM BuildingBlocks
mkdir src\Shared\%PROJ_NAME%.BuildingBlocksLib\DependencyInjection 2>nul

REM Contracts
mkdir src\Shared\%PROJ_NAME%.ContractsLib\Events 2>nul
mkdir src\Shared\%PROJ_NAME%.ContractsLib\Requests 2>nul
mkdir src\Shared\%PROJ_NAME%.ContractsLib\Responses 2>nul
exit /b

:AddInitialDummyFiles
REM === Dummy.cs i shared folder ===
echo.
echo Tilfojer dummy.cs i shared folder...

REM SharedKernel
(
echo namespace Shared.%PROJ_NAME%.SharedKernelLib.ValueObjects;
echo.
echo // Placeholder - erstattes med faktisk kode
) > src\Shared\%PROJ_NAME%.SharedKernelLib\ValueObjects\dummy.cs

(
echo namespace Shared.%PROJ_NAME%.SharedKernelLib.Results;
echo.
echo // Placeholder - erstattes med faktisk kode
) > src\Shared\%PROJ_NAME%.SharedKernelLib\Results\dummy.cs

REM BuildingBlocks
(
echo namespace Shared.%PROJ_NAME%.BuildingBlocksLib.DependencyInjection;
echo.
echo // Placeholder - erstattes med faktisk kode
) > src\Shared\%PROJ_NAME%.BuildingBlocksLib\DependencyInjection\dummy.cs

REM Contracts
(
echo namespace Shared.%PROJ_NAME%.ContractsLib.Events;
echo.
echo // Placeholder - erstattes med faktisk kode
) > src\Shared\%PROJ_NAME%.ContractsLib\Events\dummy.cs

(
echo namespace Shared.%PROJ_NAME%.ContractsLib.Requests;
echo.
echo // Placeholder - erstattes med faktisk kode
) > src\Shared\%PROJ_NAME%.ContractsLib\Requests\dummy.cs

(
echo namespace Shared.%PROJ_NAME%.ContractsLib.Responses;
echo.
echo // Placeholder - erstattes med faktisk kode
) > src\Shared\%PROJ_NAME%.ContractsLib\Responses\dummy.cs


echo Tilfojer dummy.cs i Blazor Test projekt...

REM BlazorTest
(
echo namespace %PROJ_NAME%.Web.Tests;
echo.
echo // Placeholder - erstattes med faktisk kode
) > tests\%PROJ_NAME%.Web.Tests\dummy.cs
exit /b


:AddMicroServiceDummyFiles
REM === Dummy.cs i tomme mapper ===
echo.
echo Tilfojer dummy.cs i tomme mapper...

REM DomainLib
(
echo namespace %MICROSERVICE_NAME%.DomainLib.Entities;
echo.
echo // Placeholder - erstattes med faktisk kode
) > src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.DomainLib\Entities\dummy.cs
(
echo namespace %MICROSERVICE_NAME%.DomainLib.Enums;
echo.
echo // Placeholder - erstattes med faktisk kode
) > src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.DomainLib\Enums\dummy.cs

REM FacadeLib
(
echo namespace %MICROSERVICE_NAME%.FacadeLib.Commands.DTOs;
echo.
echo // Placeholder - erstattes med faktisk kode
) > src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.FacadeLib\Commands\DTOs\dummy.cs
(
echo namespace %MICROSERVICE_NAME%.FacadeLib.Commands.Interfaces;
echo.
echo // Placeholder - erstattes med faktisk kode
) > src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.FacadeLib\Commands\Interfaces\dummy.cs
(
echo namespace %MICROSERVICE_NAME%.FacadeLib.Queries.DTOs;
echo.
echo // Placeholder - erstattes med faktisk kode
) > src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.FacadeLib\Queries\DTOs\dummy.cs
(
echo namespace %MICROSERVICE_NAME%.FacadeLib.Queries.Interfaces;
echo.
echo // Placeholder - erstattes med faktisk kode
) > src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.FacadeLib\Queries\Interfaces\dummy.cs

REM ApplicationLib
(
echo namespace %MICROSERVICE_NAME%.ApplicationLib.Handlers;
echo.
echo // Placeholder - erstattes med faktisk kode
) > src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.ApplicationLib\Handlers\dummy.cs
(
echo namespace %MICROSERVICE_NAME%.ApplicationLib.Repositories;
echo.
echo // Placeholder - erstattes med faktisk kode
) > src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.ApplicationLib\Repositories\dummy.cs
(
echo namespace %MICROSERVICE_NAME%.ApplicationLib.Repositories;
echo.
echo // Placeholder - erstattes med faktisk kode
) > src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.ApplicationLib\Extensions\dummy.cs


REM InfrastructureLib
(
echo namespace %MICROSERVICE_NAME%.InfrastructureLib.Persistence.EF_Configurations;
echo.
echo // Placeholder - erstattes med faktisk kode
) > src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.InfrastructureLib\Persistence\EF_Configurations\dummy.cs
(
echo namespace %MICROSERVICE_NAME%.InfrastructureLib.Repositories;
echo.
echo // Placeholder - erstattes med faktisk kode
) > src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.InfrastructureLib\Repositories\dummy.cs
(
echo namespace %MICROSERVICE_NAME%.InfrastructureLib.QueryHandlers;
echo.
echo // Placeholder - erstattes med faktisk kode
) > src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.InfrastructureLib\QueryHandlers\dummy.cs
(
echo namespace %MICROSERVICE_NAME%.InfrastructureLib.QueryHandlers;
echo.
echo // Placeholder - erstattes med faktisk kode
) > src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.InfrastructureLib\Extensions\dummy.cs

REM DomainLib.Tests
(
echo namespace %MICROSERVICE_NAME%.DomainLib.Tests;
echo.
echo // Placeholder - erstattes med faktisk kode
) > tests\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.DomainLib.Tests\dummy.cs

REM ApplicationLib.Tests
(
echo namespace %MICROSERVICE_NAME%.ApplicationLib.Tests;
echo.
echo // Placeholder - erstattes med faktisk kode
) > tests\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.ApplicationLib.Tests\dummy.cs

REM Api
(
echo namespace %MICROSERVICE_NAME%.Api.Controllers;
echo.
echo // Placeholder - erstattes med faktisk kode
) > src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.Api\Controllers\dummy.cs

exit /b


:AddMicroServiceStartFiles
echo.
echo Opretter starter-filer...

REM DomainException
(
echo namespace Shared.%PROJ_NAME%.SharedKernelLib.Exceptions;
echo.
echo public class DomainException : Exception
echo {
echo     public DomainException^(string message^) : base^(message^) { }
echo }
) > src\Shared\%PROJ_NAME%.SharedKernelLib\Exceptions\DomainException.cs

REM NotFoundException
(
echo namespace Shared.%PROJ_NAME%.SharedKernelLib.Exceptions;
echo.
echo public class NotFoundException : Exception
echo {
echo     public NotFoundException^(string message^) : base^(message^) { }
echo }
) > src\Shared\%PROJ_NAME%.SharedKernelLib\Exceptions\NotFoundException.cs
exit /b


:AskAnotherMicroService
choice /C JN /M "Skal der tilfojes flere MicroServices:"

if errorlevel 2 (
    exit /b
) else (
    call :AskServiceName
    goto :CreateMicroService
)


REM ================================================================================================================================================
REM Monolit
REM ================================================================================================================================================


:CreateMonolitDomainClassLib
echo [1/9] DomainLib (classlib - ingen afhaengigheder)
dotnet new classlib -n %PROJ_NAME%.DomainLib -o src\%PROJ_NAME%.DomainLib -f net10.0
del src\%PROJ_NAME%.DomainLib\Class1.cs 2>nul
exit /b

:CreateMonolitFacadeClassLib
echo [2/9] FacadeLib (classlib - ingen afhaengigheder)
dotnet new classlib -n %PROJ_NAME%.FacadeLib -o src\%PROJ_NAME%.FacadeLib -f net10.0
del src\%PROJ_NAME%.FacadeLib\Class1.cs 2>nul
exit /b

:CreateMonolitApplicationClassLib
echo [3/9] ApplicationLib (classlib - refererer Domain + Facade)
dotnet new classlib -n %PROJ_NAME%.ApplicationLib -o src\%PROJ_NAME%.ApplicationLib -f net10.0
del src\%PROJ_NAME%.ApplicationLib\Class1.cs 2>nul
exit /b

:CreateMonolitInfrastructureClassLib
echo [4/9] InfrastructureLib (classlib - refererer Domain + Facade + Application)
dotnet new classlib -n %PROJ_NAME%.InfrastructureLib -o src\%PROJ_NAME%.InfrastructureLib -f net10.0
del src\%PROJ_NAME%.InfrastructureLib\Class1.cs 2>nul
exit /b

:CreateMonolitBlazorWASMProject
echo [5/9] Blazor (Blazor Webassembly ingen afhaengigheder)
dotnet new 	blazorwasm -n %PROJ_NAME%.Web -o src\%PROJ_NAME%.Web -f net10.0 -p true
del src\%PROJ_NAME%.Web\Components\Pages\Weather.razor 2>nul
del src\%PROJ_NAME%.Web\Components\Pages\Counter.razor 2>nul
exit /b

:CreateMonolitApiProject
echo [6/9] Web Api (Web Api refererer Facade + Infrastructure + Application)
dotnet new webapi -n %PROJ_NAME%.Api -o src\%PROJ_NAME%.Api -f net10.0 --use-controllers
del src\%PROJ_NAME%.Api\Controllers\WeatherForecastController.cs 2>nul
del src\%PROJ_NAME%.Api\WeatherForecast.cs 2>nul
exit /b

:CreateMonolitDomainLibTests
echo [7/9] DomainLib.Tests (xunit.v3)
dotnet new xunit3 -n %PROJ_NAME%.DomainLib.Tests -o tests\%PROJ_NAME%.DomainLib.Tests -f net10.0
del tests\%PROJ_NAME%.DomainLib.Tests\UnitTest1.cs 2>nul
exit /b

:CreateMonolitApplicationLibTests
echo [8/9] Application.Tests (xunit.v3)
dotnet new xunit3 -n %PROJ_NAME%.ApplicationLib.Tests -o tests\%PROJ_NAME%.ApplicationLib.Tests -f net10.0
del tests\%PROJ_NAME%.ApplicationLib.Tests\UnitTest1.cs 2>nul
exit /b

:CreateMonolitBlazorTests
echo [9/9] Blazor Tests (bunit)
dotnet new bunit --framework xunitv3 -n %PROJ_NAME%.Web.Tests -o tests\%PROJ_NAME%.Web.Tests
del tests\%PROJ_NAME%.Web.Tests\Counter.razor 2>nul
del tests\%PROJ_NAME%.Web.Tests\CounterCSharpTest.cs 2>nul
del tests\%PROJ_NAME%.Web.Tests\CounterRazorTests.razor 2>nul
exit /b

:AddMonolitProjectsToSolution
echo.
echo Tilfojer projekter til solution...
dotnet sln add src\%PROJ_NAME%.DomainLib\%PROJ_NAME%.DomainLib.csproj
dotnet sln add src\%PROJ_NAME%.FacadeLib\%PROJ_NAME%.FacadeLib.csproj
dotnet sln add src\%PROJ_NAME%.ApplicationLib\%PROJ_NAME%.ApplicationLib.csproj
dotnet sln add src\%PROJ_NAME%.InfrastructureLib\%PROJ_NAME%.InfrastructureLib.csproj
dotnet sln add src\%PROJ_NAME%.Web\%PROJ_NAME%.Web.csproj
dotnet sln add src\%PROJ_NAME%.Api\%PROJ_NAME%.Api.csproj
dotnet sln add tests\%PROJ_NAME%.DomainLib.Tests\%PROJ_NAME%.DomainLib.Tests.csproj
dotnet sln add tests\%PROJ_NAME%.ApplicationLib.Tests\%PROJ_NAME%.ApplicationLib.Tests.csproj
dotnet sln add tests\%PROJ_NAME%.Web.Tests\%PROJ_NAME%.Web.Tests.csproj
exit /b



:AddMonolitProjectsReferences
echo.
echo Opsaetter projekt-referencer (Dependency Rule)...

REM Application -> Domain + Facade
dotnet add src\%PROJ_NAME%.ApplicationLib\%PROJ_NAME%.ApplicationLib.csproj reference src\%PROJ_NAME%.DomainLib\%PROJ_NAME%.DomainLib.csproj
dotnet add src\%PROJ_NAME%.ApplicationLib\%PROJ_NAME%.ApplicationLib.csproj reference src\%PROJ_NAME%.FacadeLib\%PROJ_NAME%.FacadeLib.csproj

REM Infrastructure -> Domain + Facade + Application
dotnet add src\%PROJ_NAME%.InfrastructureLib\%PROJ_NAME%.InfrastructureLib.csproj reference src\%PROJ_NAME%.DomainLib\%PROJ_NAME%.DomainLib.csproj
dotnet add src\%PROJ_NAME%.InfrastructureLib\%PROJ_NAME%.InfrastructureLib.csproj reference src\%PROJ_NAME%.FacadeLib\%PROJ_NAME%.FacadeLib.csproj
dotnet add src\%PROJ_NAME%.InfrastructureLib\%PROJ_NAME%.InfrastructureLib.csproj reference src\%PROJ_NAME%.ApplicationLib\%PROJ_NAME%.ApplicationLib.csproj

REM Api -> Facade + Infrastructure + Application
dotnet add src\%PROJ_NAME%.Api\%PROJ_NAME%.Api.csproj reference src\%PROJ_NAME%.FacadeLib\%PROJ_NAME%.FacadeLib.csproj
dotnet add src\%PROJ_NAME%.Api\%PROJ_NAME%.Api.csproj reference src\%PROJ_NAME%.InfrastructureLib\%PROJ_NAME%.InfrastructureLib.csproj
dotnet add src\%PROJ_NAME%.Api\%PROJ_NAME%.Api.csproj reference src\%PROJ_NAME%.ApplicationLib\%PROJ_NAME%.ApplicationLib.csproj

REM Domain.Tests -> Domain
dotnet add tests\%PROJ_NAME%.DomainLib.Tests\%PROJ_NAME%.DomainLib.Tests.csproj reference src\%PROJ_NAME%.DomainLib\%PROJ_NAME%.DomainLib.csproj

REM Application.Tests -> Domain + Facade + Application
dotnet add tests\%PROJ_NAME%.ApplicationLib.Tests\%PROJ_NAME%.ApplicationLib.Tests.csproj reference src\%PROJ_NAME%.DomainLib\%PROJ_NAME%.DomainLib.csproj
dotnet add tests\%PROJ_NAME%.ApplicationLib.Tests\%PROJ_NAME%.ApplicationLib.Tests.csproj reference src\%PROJ_NAME%.FacadeLib\%PROJ_NAME%.FacadeLib.csproj
dotnet add tests\%PROJ_NAME%.ApplicationLib.Tests\%PROJ_NAME%.ApplicationLib.Tests.csproj reference src\%PROJ_NAME%.ApplicationLib\%PROJ_NAME%.ApplicationLib.csproj

REM Web.Tests -> Blazor
dotnet add tests\%PROJ_NAME%.Web.tests\%PROJ_NAME%.Web.Tests.csproj reference src\%PROJ_NAME%.Web\%PROJ_NAME%.Web.csproj
exit /b



:AddMonolitNuGetPackages
echo.
echo Installerer Entiry Framework NuGet-pakker...

REM Infrastructure: EF Core 10
dotnet add src\%PROJ_NAME%.InfrastructureLib\%PROJ_NAME%.InfrastructureLib.csproj package Microsoft.EntityFrameworkCore
dotnet add src\%PROJ_NAME%.InfrastructureLib\%PROJ_NAME%.InfrastructureLib.csproj package Microsoft.EntityFrameworkCore.SqlServer
dotnet add src\%PROJ_NAME%.InfrastructureLib\%PROJ_NAME%.InfrastructureLib.csproj package Microsoft.EntityFrameworkCore.Tools

REM Api: OpenApi + Scalar
dotnet add src\%PROJ_NAME%.Api\%PROJ_NAME%.Api.csproj package Microsoft.AspNetCore.OpenApi
dotnet add src\%PROJ_NAME%.Api\%PROJ_NAME%.Api.csproj package Microsoft.OpenApi -v 2.11.0
dotnet add src\%PROJ_NAME%.Api\%PROJ_NAME%.Api.csproj package Scalar.AspNetCore

REM Tests: xunit3-template giver allerede xunit.v3 — tilfoej kun Moq til Application.Tests
dotnet add tests\%PROJ_NAME%.ApplicationLib.Tests\%PROJ_NAME%.ApplicationLib.Tests.csproj package Moq
exit /b




:AddMonolitFolderStructure
REM === Mappestruktur ===
echo.
echo Opretter mappestruktur...

REM DomainLib
mkdir src\%PROJ_NAME%.DomainLib\Entities 2>nul
mkdir src\%PROJ_NAME%.DomainLib\ValueObjects 2>nul
mkdir src\%PROJ_NAME%.DomainLib\Enums 2>nul
mkdir src\%PROJ_NAME%.DomainLib\Exceptions 2>nul

REM FacadeLib
mkdir src\%PROJ_NAME%.FacadeLib\Commands 2>nul
mkdir src\%PROJ_NAME%.FacadeLib\Commands\DTOs 2>nul
mkdir src\%PROJ_NAME%.FacadeLib\Commands\Interfaces 2>nul
mkdir src\%PROJ_NAME%.FacadeLib\Queries 2>nul
mkdir src\%PROJ_NAME%.FacadeLib\Queries\DTOs 2>nul
mkdir src\%PROJ_NAME%.FacadeLib\Queries\Interfaces 2>nul

REM ApplicationLib
mkdir src\%PROJ_NAME%.ApplicationLib\Handlers 2>nul
mkdir src\%PROJ_NAME%.ApplicationLib\Repositories 2>nul

REM InfrastructureLib
mkdir src\%PROJ_NAME%.InfrastructureLib\Persistence 2>nul
mkdir src\%PROJ_NAME%.InfrastructureLib\Persistence\EF_Configurations 2>nul
mkdir src\%PROJ_NAME%.InfrastructureLib\Repositories 2>nul
mkdir src\%PROJ_NAME%.InfrastructureLib\QueryHandlers 2>nul
exit /b



:AddMonolitDummyFiles
REM === Dummy.cs i tomme mapper ===
echo.
echo Tilfojer dummy.cs i tomme mapper...

REM DomainLib
(
echo namespace %PROJ_NAME%.DomainLib.Entities;
echo.
echo // Placeholder - erstattes med faktisk kode
) > src\%PROJ_NAME%.DomainLib\Entities\dummy.cs
(
echo namespace %PROJ_NAME%.DomainLib.ValueObjects;
echo.
echo // Placeholder - erstattes med faktisk kode
) > src\%PROJ_NAME%.DomainLib\ValueObjects\dummy.cs
(
echo namespace %PROJ_NAME%.DomainLib.Enums;
echo.
echo // Placeholder - erstattes med faktisk kode
) > src\%PROJ_NAME%.DomainLib\Enums\dummy.cs

REM FacadeLib
(
echo namespace %PROJ_NAME%.FacadeLib.Commands.DTOs;
echo.
echo // Placeholder - erstattes med faktisk kode
) > src\%PROJ_NAME%.FacadeLib\Commands\DTOs\dummy.cs
(
echo namespace %PROJ_NAME%.FacadeLib.Commands.Interfaces;
echo.
echo // Placeholder - erstattes med faktisk kode
) > src\%PROJ_NAME%.FacadeLib\Commands\Interfaces\dummy.cs
(
echo namespace %PROJ_NAME%.FacadeLib.Queries.DTOs;
echo.
echo // Placeholder - erstattes med faktisk kode
) > src\%PROJ_NAME%.FacadeLib\Queries\DTOs\dummy.cs
(
echo namespace %PROJ_NAME%.FacadeLib.Queries.Interfaces;
echo.
echo // Placeholder - erstattes med faktisk kode
) > src\%PROJ_NAME%.FacadeLib\Queries\Interfaces\dummy.cs

REM ApplicationLib
(
echo namespace %PROJ_NAME%.ApplicationLib.Handlers;
echo.
echo // Placeholder - erstattes med faktisk kode
) > src\%PROJ_NAME%.ApplicationLib\Handlers\dummy.cs
(
echo namespace %PROJ_NAME%.ApplicationLib.Repositories;
echo.
echo // Placeholder - erstattes med faktisk kode
) > src\%PROJ_NAME%.ApplicationLib\Repositories\dummy.cs

REM InfrastructureLib
(
echo namespace %PROJ_NAME%.InfrastructureLib.Persistence.EF_Configurations;
echo.
echo // Placeholder - erstattes med faktisk kode
) > src\%PROJ_NAME%.InfrastructureLib\Persistence\EF_Configurations\dummy.cs
(
echo namespace %PROJ_NAME%.InfrastructureLib.Repositories;
echo.
echo // Placeholder - erstattes med faktisk kode
) > src\%PROJ_NAME%.InfrastructureLib\Repositories\dummy.cs
(
echo namespace %PROJ_NAME%.InfrastructureLib.QueryHandlers;
echo.
echo // Placeholder - erstattes med faktisk kode
) > src\%PROJ_NAME%.InfrastructureLib\QueryHandlers\dummy.cs

REM DomainLib.Tests
(
echo namespace %PROJ_NAME%.DomainLib.Tests;
echo.
echo // Placeholder - erstattes med faktisk kode
) > tests\%PROJ_NAME%.DomainLib.Tests\dummy.cs

REM ApplicationLib.Tests
(
echo namespace %PROJ_NAME%.ApplicationLib.Tests;
echo.
echo // Placeholder - erstattes med faktisk kode
) > tests\%PROJ_NAME%.ApplicationLib.Tests\dummy.cs

REM BlazorTest
(
echo namespace %PROJ_NAME%.Web.Tests;
echo.
echo // Placeholder - erstattes med faktisk kode
) > tests\%PROJ_NAME%.Web.Tests\dummy.cs
exit /b



:AddMonolitStartFiles
echo.
echo Opretter starter-filer...

REM DomainException
(
echo namespace %PROJ_NAME%.DomainLib.Exceptions;
echo.
echo public class DomainException : Exception
echo {
echo     public DomainException^(string message^) : base^(message^) { }
echo }
) > src\%PROJ_NAME%.DomainLib\Exceptions\DomainException.cs

REM NotFoundException
(
echo namespace %PROJ_NAME%.DomainLib.Exceptions;
echo.
echo public class NotFoundException : Exception
echo {
echo     public NotFoundException^(string message^) : base^(message^) { }
echo }
) > src\%PROJ_NAME%.DomainLib\Exceptions\NotFoundException.cs
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

:ShowInitialProjectOverview
echo.
echo ============================================
echo  %PROJ_NAME% projekt-skelet oprettet!
echo ============================================
echo.
echo  Struktur:
echo    src\Shared\%PROJ_NAME%.SharedKernelLib\               ^(ingen afhaengigheder^)
echo    src\Shared\%PROJ_NAME%.BuildingBlocksLib\             ^(ingen afhaengigheder^)
echo    src\Shared\%PROJ_NAME%.ContractsLib\                  ^(ingen afhaengigheder^)
echo    src\%PROJ_NAME%.Web\                                  ^(ingen afhaengigheder^)
echo.
echo.
echo  Starter-filer:
echo    Shared\%PROJ_NAME%.SharedKernelLib\Exceptions\      ^(DomainException + NotFoundException^)
echo.
exit /b

:ShowMicroServiceOverview
echo.
echo ============================================
echo  %MICROSERVICE_NAME% Microservice-skelet oprettet!
echo ============================================
echo.
echo  Struktur:
echo    src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.DomainLib\                ^(SharedKernel^)
echo    src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.FacadeLib\                ^(ingen afhaengigheder^)
echo    src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.ApplicationLib\           ^(refererer Domain + Facade + SharedKernel + Contracts^)
echo    src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.InfrastructureLib\        ^(refererer Domain + Facade + Application + SharedKernel + BuildingBlocks + Contracts^)
echo    src\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.Api\                      ^(refererer Facade + Infrastructure + Application + SharedKernel + BuildingBlocks + Contracts^)
echo    tests\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.DomainLib.Tests\        ^(refererer Domain^)
echo    tests\%MICROSERVICE_NAME%\%MICROSERVICE_NAME%.ApplicationLib.Tests\   ^(refererer Domain + Facade + Application^)
echo.
echo  NuGet-pakker:
echo    Infrastructure: EF Core 10      ^(SqlServer^)
echo    Tests:          xunit.v3 + Moq
echo	Api:			Scalar + OpenApi 2.11.0
echo.
echo.
echo  Naeste skridt:
echo    1. Aaben %PROJ_NAME%.slnx i Visual Studio
echo    2. Implementer dine Value Objects i %MICROSERVICE_NAME%\Domain\ValueObjects\
echo    3. Implementer dine AggregateRoot og Entities i %MICROSERVICE_NAME%\Domain\Entities\
echo    4. Indsaet reference til scalar i %MICROSERVICE_NAME%.Api\program.cs (app.MapScalarApiReference();)
echo    5. Hvis Aspire onskes skal dette tilfojes via Aspire Orchestrator Support i Visual Studio
echo    6. Opret multi startup profil hvis dette onskes
echo.
exit /b

:ShowMonolitOverview
echo.
echo ============================================
echo  %PROJ_NAME% Projekt-skelet oprettet!
echo ============================================
echo.
echo  Struktur:
echo    src\%PROJ_NAME%.DomainLib\                  ^(ingen afhaengigheder^)
echo    src\%PROJ_NAME%.FacadeLib\                  ^(ingen afhaengigheder^)
echo    src\%PROJ_NAME%.ApplicationLib\             ^(refererer Domain + Facade^)
echo    src\%PROJ_NAME%.InfrastructureLib\          ^(refererer Domain + Facade + Application^)
echo	src\%PROJ_NAME%.Web\						^(ingen afhaengigheder^)
echo    src\%PROJ_NAME%.Api\                        ^(refererer Facade + Infrastructure + Application^)
echo    tests\%PROJ_NAME%.DomainLib.Tests\          ^(refererer Domain^)
echo    tests\%PROJ_NAME%.ApplicationLib.Tests\     ^(refererer Domain + Facade + Application^)
echo	tests\%PROJ_NAME%.Web.Tests\				^(refererer Blazor^)
echo.
echo  NuGet-pakker:
echo    Infrastructure: EF Core 10      ^(SqlServer^)
echo    Tests:          xunit.v3 + Moq
echo	Api:			Scalar + OpenApi 2.11.0
echo.
echo  Starter-filer:
echo    Domain\Exceptions\      ^(DomainException + NotFoundException^)
echo.
echo  Naeste skridt:
echo    1. Aaben %PROJ_NAME%.slnx i Visual Studio
echo    2. Implementer dine Value Objects i Domain\ValueObjects\
echo    3. Implementer dine AggregateRoot og Entities i Domain\Entities\
echo.
pause
exit /b