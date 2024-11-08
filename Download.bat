@echo off & setlocal EnableDelayedExpansion
title "Youtube DOWNLOADER"
:: définie UTF-8
chcp 65001 >nul 
if defined ProgramFiles(x86) (set bit=64) else (set bit=32)

:: Définition des variables
set "VERSION=1.1"
set "DOSSIER=C:\yt-dlp"
:: yt-dlp
set "FICHIER_YT=%DOSSIER%\yt-dlp.exe"
set "GITHUB_REPO=yt-dlp"
set "NOM_FICHIER=yt-dlp.exe"
set "URL_YT=https://api.github.com/repos/yt-dlp/yt-dlp/releases/latest"
set "DOWNLOAD_YT=https://github.com/yt-dlp/yt-dlp/releases/download/%GITHUB_DATE%/yt-dlp.exe"
:: FFMPEG
set "FICHIER_FFMPEG=%DOSSIER%\ffmpeg.exe"
set "FICHIER_FFMPEG_ZIP=%DOSSIER%\FFMPEG.zip"
set "FICHIER_FFPLAY=%DOSSIER%\ffplay.exe"
set "FICHIER_FFPROBE=%DOSSIER%\ffprobe.exe"
set "DOWNLOAD_FFMPEG=https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip"
:: Dépendance
set "DOSSIER_DEP=%DOSSIER%\Dépendancies"
set "FICHIER_DEP_BATBOX=%DOSSIER_DEP%\batbox.exe"
set "FICHIER_DEP_BOX=%DOSSIER_DEP%\box.bat"
set "FICHIER_DEP_BUTTON=%DOSSIER_DEP%\button.bat"
set "FICHIER_DEP_GETINPUT=%DOSSIER_DEP%\GetInput.exe"
set "FICHIER_DEP_GETLEN=%DOSSIER_DEP%\Getlen.bat"
:: reset
set "choix="
set "LIEN="
set "DEST_DOSSIER="
set "VERIF_LIMIT="

:argument
:: version
if /i "%~1" == "-v" (
    goto :version
)

:check
echo: Vérification de base...
ping 1.1.1.1 -n 1 -w 1000 > nul
if errorlevel 1 (
    Echo: Impossible de ping 1.1.1.1, Tentative de résolution.
) else (
    goto internet_trouver
)
ping 8.8.8.8 -n 1 -w 2000 > nul
if errorlevel 1 (
    Echo: Impossible de ping 8.8.8.8, Tentative de résolution.
) else (
    goto internet_trouver
)
ping github.com -n 1 -w 2000 > nul
if errorlevel 1 (
    Echo: Could not Ping github.com, Exiting Script
    timeout 5 > nul 
    exit
) else (
    goto internet_trouver
)

:internet_trouver
curl.exe -V > nul
if errorlevel 1 (
    echo Impossible de trouver curl. Veuillez l'installer. 
    pause 
    exit
)
echo: Curl trouvé.
for %%# in (powershell.exe) do @if "%%~$PATH:#"=="" (
    echo: Impossible de trouver Powershell.
    pause
    exit
)
echo: Powershell trouvé.
timeout 1 >nul

:download_yt
:: verif si le dossier yt-dlp est présent
if not exist "%DOSSIER%" (
    echo: création du dossier yt-dlp.
    mkdir "%DOSSIER%"
)


:verif_dependance
:: vérifie la présence des dépendances.
if not exist "%DOSSIER_DEP%" (
    echo: création du dossier yt-dlp.
    mkdir "%DOSSIER_DEP%"
    call :download_dependance
    goto verif_yt
)

if not exist "%FICHIER_DEP_BATBOX%" (
    call :download_dependance
)

if not exist "%FICHIER_DEP_BOX%" (
    call :download_dependance
)

if not exist "%FICHIER_DEP_BUTTON%" (
    call :download_dependance
)

if not exist "%FICHIER_DEP_GETINPUT%" (
    call :download_dependance
)

if not exist "%FICHIER_DEP_GETLEN%" (
    call :download_dependance
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
mode con cols=70 lines=17
cd /d %DOSSIER_DEP%
cls
echo: 
echo: 
echo:                         [31mYOUTUBE [0mDOWNLOADER        
call Button 23 5 A0 "MP3" 40 5 E0 "MP4" 19 10 70 "Troubleshoot" 40 10 80 "Quit" X _Var_Box _Var_Hover
echo:
echo:
echo:
echo:
echo: Credit : Dany.mp5
:: Choix avec vérification des réponses.
set "errorlevel="
GetInput /M %_Var_Box% /H %_Var_Hover%
if %errorlevel%==4 exit
if %errorlevel%==3 goto :troubleshoot
if %errorlevel%==2 goto :mp4
if %errorlevel%==1 goto :mp3

:: Si c'est aucune des réponses, alors retour au menu.
cls
echo: Choix invalide. Veuillez réessayer.
pause
goto :main_menu

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
curl "https://github.com/yt-dlp/yt-dlp/releases/download/%GITHUB_DATE%/yt-dlp.exe" -o "%FICHIER_YT%" -L ^
     --progress-bar 
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
curl "%DOWNLOAD_FFMPEG%" -o "%FICHIER_FFMPEG_ZIP%" -L ^
     --progress-bar 
goto extract_ffmpeg

:extract_ffmpeg
mkdir "%DOSSIER%\FFMPEG"
tar xf "%FICHIER_FFMPEG_ZIP%" -C "%DOSSIER%\FFMPEG"
for /r "%DOSSIER%\FFMPEG" %%f in (*.exe) do (
    if /i not "%%~nxf"=="yt-dlp.exe" (
        copy "%%f" "%DOSSIER%">nul 
    )

)
del /s /q %FICHIER_FFMPEG_ZIP%>nul
rmdir /s /q %DOSSIER%\FFMPEG>nul
exit /b

:download_dependance
cls
curl "https://raw.githubusercontent.com/dany17220/Download-YouTube/refs/heads/main/Dépendancies/Box.bat" -o "%DOSSIER_DEP%\box.bat" -L -s
echo: [[92mGood[0m]: Box.bat
curl "https://raw.githubusercontent.com/dany17220/Download-YouTube/refs/heads/main/Dépendancies/Button.bat" -o "%DOSSIER_DEP%\button.bat" -L -s
echo: [[92mGood[0m]: Button.bat
curl "https://github.com/dany17220/Download-YouTube/raw/refs/heads/main/Dépendancies/GetInput.exe" -o "%DOSSIER_DEP%\GetInput.exe" -L -s
echo: [[92mGood[0m]: GetInput.exe
curl "https://raw.githubusercontent.com/dany17220/Download-YouTube/refs/heads/main/Dépendancies/Getlen.bat" -o "%DOSSIER_DEP%\Getlen.bat" -L -s
echo: [[92mGood[0m]: Getlen.bat
curl "https://github.com/dany17220/Download-YouTube/raw/refs/heads/main/Dépendancies/batbox.exe" -o "%DOSSIER_DEP%\batbox.exe" -L -s
echo: [[92mGood[0m]: batbox.exe
exit /b

:troubleshoot
call :download_yt
call :download_ffmpeg
call :download_dependance
pause
cls
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
%DOSSIER%\yt-dlp.exe %lien% -P "%DEST_DOSSIER%" -f "bv*[ext=mp4]+ba[ext=m4a]/b[ext=mp4] / bv*+ba/b"
explorer %DEST_DOSSIER%
goto :main_menu

:: téléchargement en MP3
:mp3
call :demande_lien
mode con cols=158 lines=30
%DOSSIER%\yt-dlp.exe %lien% -P "%DEST_DOSSIER%" -f "ba/b" --recode-video mp3
explorer %DEST_DOSSIER%
goto :main_menu

:demande_dest
for /f "usebackq" %%D in (`powershell -command "(new-object -com Shell.Application).BrowseForFolder(0, 'Sélectionnez un dossier', 0).self.path"`) do set "DEST_DOSSIER=%%D"
if /i "%DEST_DOSSIER%" == "" (
    cls
    echo:[31mVous n'avez pas choisis votre dossier de destination. Veuillez réessayer.[0m
    echo:                [31mAppuyez sur une touche pour continuer...[0m
    pause>nul
    goto demande_dest
) else (
    echo: non
)
exit /b 


:demande_lien
mode con cols=76 lines=3
set /P lien=Collez votre lien [91mYouTube[0m : 
if /i "%lien:~0,23%" == "https://www.youtube.com" (
    call :demande_dest
) else if /i "%lien:~0,17%" == "https://youtu.be/" (
    call :demande_dest
) else (
    cls
    echo:[31mVotre lien n'est pas valide. Veuillez réessayer.[0m
    echo:                [31mAppuyez sur une touche pour continuer...[0m
    pause>nul
    goto demande_lien
)

:version
echo: %VERSION%
exit /b

:motd 
