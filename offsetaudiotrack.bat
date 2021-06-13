@echo off
IF [%1]==[/?] GOTO :help
IF "%1"=="" GOTO :help
IF "%2"=="" GOTO :help

set FULL=%1
set OFFSET=%2
set FILE=%~dpn1
set TRACK_MICRO="%FILE%_2.mp3"
set TRACK_MICDE="%FILE%_2d.mp3"
set TRACK_AUDIO="%FILE%_3.mp3"
set TRACK_MERGE="%FILE%_4.mp3"
set FILE_OUT="%FILE%_out.mp4"
set FFMPEG_LOGLEVEL= -v quiet -stats

del /Q %TRACK_MICRO%
del /Q %TRACK_MICDE%
del /Q %TRACK_AUDIO%
del /Q %TRACK_MERGE%
del /Q %FILE_OUT%
cls

@REM Default channel for combined audio is 1, it will be ignored

@REM Default channel for the microphone audio is 2
set CHAN_MICRO=2
IF "%3"=="" GOTO skipP3
set CHAN_MICRO=%3
:skipP3

@REM Default channel for the desktop audio is 3
set CHAN_AUDIO=3
IF "%4"=="" GOTO skipP4
set CHAN_AUDIO=%4
:skipP4

echo Extracting the microphone track...
ffmpeg -i %FULL% -map 0:%CHAN_MICRO% %TRACK_MICRO% -ac 1 %FFMPEG_LOGLEVEL%
cls

if %OFFSET:~0,1% EQU - (goto trim) else (goto delay)

:trim
set /a offpos="-%OFFSET%/1000"
echo Trimming from the microphone track by %offpos%ms
ffmpeg -i %TRACK_MICRO% -af "atrim=%offpos%" %TRACK_MICDE% %FFMPEG_LOGLEVEL%
goto merge

:delay
set /a offsec="%OFFSET%"
echo Delaying the microphone track by %offsec%ms
ffmpeg -i %TRACK_MICRO% -af "adelay=%offsec%|%offsec%" %TRACK_MICDE% %FFMPEG_LOGLEVEL%
goto merge

:merge
del /Q %TRACK_MICRO%
cls

echo Extracting the audio track...
ffmpeg -i %FULL% -map 0:%CHAN_AUDIO% %TRACK_AUDIO% %FFMPEG_LOGLEVEL%

cls
echo Mixing...
ffmpeg -i %TRACK_MICDE% -i %TRACK_AUDIO% -filter_complex amix=inputs=2:duration=longest %TRACK_MERGE% %FFMPEG_LOGLEVEL%

del /Q %TRACK_MICDE%
del /Q %TRACK_AUDIO%
cls

echo Creating final output...
ffmpeg -i %FULL% -i %TRACK_MERGE% -c:v copy -map 0:v:0 -map 1:a:0 %FILE_OUT% %FFMPEG_LOGLEVEL%

del /Q %TRACK_MERGE%
cls

echo Saved output to %FILE_OUT%
goto end

:help
echo How to use this script :
echo offsetaudiotrack  ^<file.mp4^> ^<ms^> [microphone_track] [audio_track]

:end