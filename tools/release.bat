@SET SOURCE_DIR=..
@SET TARGET=RavenBot
@SET TARGET_DIR=RavenBot
@SET ZIP_7Z_FILE=7z\7z.exe
@SET VER=v2_5
@SET ARCHIVE_FILE_NAME=%TARGET%_%VER%.zip

rmdir /Q /S %TARGET_DIR%\
mkdir %TARGET_DIR%

xcopy %SOURCE_DIR%\Bots %TARGET_DIR%\Bots\ /E /Y
xcopy %SOURCE_DIR%\images %TARGET_DIR%\images\ /E /Y
xcopy ..\RavenBot.au3 %TARGET_DIR%\
xcopy ..\COCBot.dll %TARGET_DIR%\
xcopy ..\RavenBot.exe %TARGET_DIR%\

::============================================
:: Archive zip file..
::============================================
del /F/Q/S ..\release\%ARCHIVE_FILE_NAME%
%ZIP_7Z_FILE% a -tzip ..\release\%ARCHIVE_FILE_NAME% %TARGET_DIR%\

rmdir /Q /S %TARGET_DIR%\

pause