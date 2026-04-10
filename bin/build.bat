@echo off
setlocal

set bin=./node_modules/.bin
set dist=./dist

set MODE=
set ENV=

:parse_args
if "%~1"=="" goto end_parse
if "%~1"=="-m" (
    set MODE=%~2
    shift
    shift
    goto parse_args
)
if "%~1"=="-e" (
    set ENV=%~2
    shift
    shift
    goto parse_args
)
echo unknown argument: %~1
exit /b 1
:end_parse

REM build es and split bundle
call %bin%/vite build -c ./build/config.es.ts
REM build umd
REM TODO: split bundle
call %bin%/vite build -c ./build/config.umd.ts
call %bin%/tsc --declaration --emitDeclarationOnly --outDir ./dist --project tsconfig.json

copy tsconfig.json .\dist
copy typings.d.ts .\dist

REM get script directory
set "SCRIPT_DIR=%~dp0"

REM define source and target file paths
set "source_file=%SCRIPT_DIR%..\dist\typings.d.ts"
set "target_file=%SCRIPT_DIR%..\dist\index.d.ts"

REM check source file exists
if not exist "%source_file%" (
    echo Error: Source file '%source_file%' does not exist or path is incorrect.
    exit /b 1
)

REM check target directory exists
for %%F in ("%target_file%") do set "target_dir=%%~dpF"
if not exist "%target_dir%" (
    echo Error: Target directory '%target_dir%' does not exist.
    exit /b 1
)

REM append source file content to target file
type "%source_file%" >> "%target_file%"
