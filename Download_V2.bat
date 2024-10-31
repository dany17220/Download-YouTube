@echo off & setlocal EnableDelayedExpansion
title "Youtube DOWNLOADER"
:: définie UTF-8
chcp 65001 >nul 
ping localhost -n 3 >nul
if defined ProgramFiles(x86) (set bit=64) else (set bit=32)

:: Définition des variables
set "FICHIER_YT=C:\yt-dlp\yt-dlp.exe"
set "FICHIER_FFMPEG=C:\yt-dlp\ffmpeg.exe"
set "FICHIER_FFMPEG_ZIP=C:\yt-dlp\FFMPEG.zip"
set "FICHIER_FFPLAY=C:\yt-dlp\ffplay.exe"
set "FICHIER_FFPROBE=C:\yt-dlp\ffprobe.exe"
set "DOSSIER=C:\yt-dlp"
set "GITHUB_REPO=yt-dlp"
set "NOM_FICHIER=yt-dlp.exe"
set "URL_YT=https://api.github.com/repos/yt-dlp/yt-dlp/releases/latest"
set "DOWNLOAD_YT=https://github.com/yt-dlp/yt-dlp/releases/download/%GITHUB_DATE%/yt-dlp.exe"
set "DOWNLOAD_FFMPEG=https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip"
set "choix="
set "LIEN="
set "DEST_DOSSIER="
set "VERSION="

:check
echo: Vérification de base...
ping 1.1.1.1 -n 1 -w 1000 > nul
if errorlevel 1 (Echo.Could not Ping 1.1.1.1, Attempting backup pings.) else (goto internet_trouver)
ping 8.8.8.8 -n 1 -w 2000 > nul
if errorlevel 1 (Echo.Could not Ping 8.8.8.8, Attempting backup pings.) else (goto internet_trouver)
ping github.com -n 1 -w 2000 > nul
if errorlevel 1 (Echo.Could not Ping github.com, Exiting Script && timeout 5 > nul && exit) else (goto internet_trouver)
:internet_trouver
for %%# in (powershell.exe) do @if "%%~$PATH:#"=="" (echo.Could not find Powershell. && pause && exit)
echo: Powershell trouvé.
:: verif si le dossier yt-dlp est présent
if not exist "%DOSSIER%" (
    mkdir "c:\yt-dlp"
)

:verif_yt
if not exist "%FICHIER_YT%" (
    echo: yt-dlp non trouvé.
    ping localhost -n 5>nul 
    call :DOWNLOAD_YT
    goto verif_ffmpeg
) else (
    goto verif_ffmpeg
)

:verif_ffmpeg
if not exist "%FICHIER_FFMPEG%" (
    call :DOWNLOAD_FFMPEG
)

if not exist "%FICHIER_FFPLAY%" (
    call :DOWNLOAD_FFMPEG
)

if not exist "%FICHIER_FFPROBE%" (
    call :DOWNLOAD_FFMPEG
) else (
    goto main_menu
)

if exist "%FICHIER_FFMPEG_ZIP%" (
    goto extract_ffmpeg
)

:main_menu
:: Menu Principal
mode con cols=70 lines=15
cls
echo: 
echo: 
echo: ////////////////////////////////////////////////////////////////////
echo: /////                    YOUTUBE DOWNLOADER                    /////
echo: ////////////////////////////////////////////////////////////////////
echo:                               [1] MP3
echo:                               [2] MP4
echo:                               [3] Réparation
echo:                               [4] Quitter
echo:
echo: Credit : Dany.mp5
echo:
:: Choix avec vérification des réponses.
set "errorlevel="
choice /c 1234 /n /m "Chossissez une option : "
if %errorlevel%==4 exit
if %errorlevel%==3 goto :troubleshoot
if %errorlevel%==2 call :demande_lien_mp4 & goto :mp4
if %errorlevel%==1 call :demande_lien_mp3 & goto :mp3

:: Si c'est aucune des réponses, alors retour au menu.
cls
echo: Choix invalide. Veuillez réessayer.
pause
goto :main_menu

:demande_lien
mode con cols=76 lines=3
set /P lien=Collez votre lien youtube.com : 
call :demande_dest
exit /b 

:demande_dest

for /f "usebackq" %%D in (`powershell -command "(new-object -com Shell.Application).BrowseForFolder(0, 'Sélectionnez un dossier', 0).self.path"`) do set "DEST_DOSSIER=%%D"
exit /b


:yt_date
:: Stocker la date de la dernière release dans une variable
for /f "delims=" %%A in ('powershell -NoProfile -Command "(Invoke-WebRequest -Uri '%URL_YT%' -UseBasicParsing | ConvertFrom-Json).published_at.Substring(0,10)"') do set "GITHUB_DATE=%%A"

:: Remplacer les - par des .
set "GITHUB_DATE=%GITHUB_DATE:-=.%" 
exit /b 

:download_yt
mode con cols=74 lines=6
call :yt_date
:: téléchargement yt-dlp.exe
cls
echo: Téléchargement de la dernière version de YT-DLP...
powershell -c "Invoke-WebRequest -Uri 'https://github.com/yt-dlp/yt-dlp/releases/download/%GITHUB_DATE%/yt-dlp.exe' -OutFile 'C:\yt-dlp\yt-dlp.exe'">nul
:: vérifie le téléchargement.
if exist "%FICHIER_YT%" (
    exit /b
) else (
    cls
    echo Échec du téléchargement de yt-dlp. Veuillez relancer le script.
    pause
    exit
)

:download_ffmpeg
:: téléchargement ffmpeg
cls
mode con cols=74 lines=6
echo: Téléchargement de la dernière version de FFMPEG.
powershell -c "Invoke-WebRequest -Uri '%DOWNLOAD_FFMPEG%' -OutFile '%FICHIER_FFMPEG_ZIP%'"
:extract_ffmpeg
mkdir "%DOSSIER%\FFMPEG"
tar xf "%FICHIER_FFMPEG_ZIP%" -C "%DOSSIER%\FFMPEG"
for /r "%DOSSIER%" %%f in (*.exe) do (
    if /i not "%%~nxf"=="yt-dlp.exe" (
        copy "%%f" "%DOSSIER%">nul 
    )

)
del /s /q %FICHIER_FFMPEG_ZIP%>nul
rmdir /s /q %DOSSIER%\FFMPEG>nul
exit /b


:DOWNLOAD_YT_reussi

color 0A

echo ======================================================
echo.
echo       Félicitations ! L'opération a réussi !
echo.
echo ======================================================
exit /b

:troubleshoot
call :download_yt
call :download_ffmpeg
echo: Réparation terminé.
ping localhost -n 5 >nul
goto main_menu



::---------------------------------------------------------------------------------------------------------------------------------------------------
::---------------------------------------------------------------------------------------------------------------------------------------------------
::---------------------------------------------------------------------------------------------------------------------------------------------------
::---------------------------------------------------------------------------------------------------------------------------------------------------
::---------------------------------------------------------------------------------------------------------------------------------------------------
::---------------------------------------------------------------------------------------------------------------------------------------------------
::---------------------------------------------------------------------------------------------------------------------------------------------------
::---------------------------------------------------------------------------------------------------------------------------------------------------
::---------------------------------------------------------------------------------------------------------------------------------------------------


:: téléchargement en MP4
:mp4
call :demande_lien
mode con cols=158 lines=30
cd "C:\yt-dlp"
C:\yt-dlp\yt-dlp.exe %lien% -P "%DEST_DOSSIER%" -f "bv*[ext=mp4]+ba[ext=m4a]/b[ext=mp4] / bv*+ba/b"
explorer %DEST_DOSSIER%
call :download_reussi
goto :main_menu

:: téléchargement en MP3
:mp3
call :demande_lien
mode con cols=158 lines=30
cd "C:\yt-dlp"
C:\yt-dlp\yt-dlp.exe %lien% -P "%DEST_DOSSIER%" -f "ba/b" --recode-video mp3
explorer %DEST_DOSSIER%
call :download_reussi
goto :main_menu