@echo off

REM ============================
REM CONFIGURACOES
REM ============================
set PYTHON_EXE=C:\Users\FERNANDO\AppData\Local\Python\pythoncore-3.14-64\python.exe
set PROJECT_DIR=C:\Users\FERNANDO\Desktop\AWS\Lake-House-Pos-Fernando
set LOGDIR=C:\Users\FERNANDO\Desktop\AWS\Lake-House-Pos-Fernando\logs

set AWS_PROFILE=etl_engenharia_dados

REM ============================
REM PREPARACAO
REM ============================
if not exist "%LOGDIR%" mkdir "%LOGDIR%"

REM DATA E HORA PARA LOG (PADRAO QUE FUNCIONA) 
for /f "tokens=1-3 delims=/- " %%a in ("%date%") do (
  set DD=%%a
  set MM=%%b
  set YYYY=%%c
)

for /f "tokens=1-3 delims=:." %%a in ("%time%") do (
  set HH=%%a
  set MI=%%b
  set SS=%%c
)

set HH=%HH: =0%

set LOGFILE=%LOGDIR%\pipeline_pos_%YYYY%-%MM%-%DD%_%HH%%MI%.log

REM ============================
REM EXECUCAO
REM ============================
echo ===== INICIO %date% %time% ===== >> "%LOGFILE%"

"%PYTHON_EXE%" "%PROJECT_DIR%\ETL\legado\legado_upload.py" >> "%LOGFILE%" 2>&1
if errorlevel 1 goto erro

"%PYTHON_EXE%" "%PROJECT_DIR%\ETL\raw\legado_to_raw.py" >> "%LOGFILE%" 2>&1
if errorlevel 1 goto erro

"%PYTHON_EXE%" "%PROJECT_DIR%\ETL\trusted\raw_to_trusted.py" >> "%LOGFILE%" 2>&1
if errorlevel 1 goto erro

"%PYTHON_EXE%" "%PROJECT_DIR%\ETL\curated\run_ctas_athena.py" >> "%LOGFILE%" 2>&1
if errorlevel 1 goto erro

echo ===== FIM %date% %time% - SUCESSO ===== >> "%LOGFILE%"
exit /b 0

:erro
echo ===== FIM %date% %time% - ERRO ===== >> "%LOGFILE%"
exit /b 1