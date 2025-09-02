@echo off
REM ---------------------------------------------------------------
REM  program	copy_backup.bat
REM  author	Monktar Bello, Acompany DBA, 6/6/2022
REM  purpose the backup once done, this batch write a signal which the linux box can start its task
REM  note	Must be run by SQL Job or as sqlsvc01 account
REM  params	Param1 = FULL, DIFF, or LOG (case sensitive)
REM ---------------------------------------------------------------

REM !!!space between string_name and operator and string_value!!!
SET SCRIPTS=D:\DBA\
SET ID=ready_for_short_term
SET ERRFILE=%SCRIPTS%\%ID%_%1_ERROR.FLG
SET LOGFILE=%SCRIPTS%\%ID%_%1.log
SET MY_STATUS=OK
SET DEST_DIR=D:\SQLBackups\
SET SIG_FILE=%DEST_DIR%\%ID%_%1.txt


REM Delete errfile so no false flags thrown
IF EXIST %ERRFILE%   DEL %ERRFILE%

	
IF EXIST %DEST_DIR%  (
	SET MY_STATUS=Backup folder exits
	
	GOTO DRIVE_OK
	) ELSE (
	SET MY_STATUS=Backup folder is missing
	GOTO MY_ERROR
	)

GOTO END
	
:DRIVE_OK
	IF EXIST %SIG_FILE% ( 
		SET MY_STATUS=signal file was not deleted
		GOTO MY_ERROR
		)
	
	REM Copy Logins/Roles script to backup server, and keep a log of actions
	XCOPY D:\DR  %DEST_DIR%\DR   /c/d/i/s/e/y  >> %LOGFILE%
	IF ERRORLEVEL 1  (
		SET MY_STATUS=%ERRORLEVEL% during DR task.
		GOTO MY_ERROR
	) ELSE (
	
		REM if fall here that means the folder exists. "ready_for_short_term.txt" is deleted by the job on linux box in charge to copy the backup
		ECHO %1_%ID% >>  %SIG_FILE%
		IF ERRORLEVEL 1  (
			SET MY_STATUS=Error_level is %ERRORLEVEL%. It could not write the signal file.
			GOTO MY_ERROR
		) ELSE (
			ECHO %DATE% %TIME% %1 signal succeeded and DR copied >> %LOGFILE%
		)
	)
		
	GOTO END


:MY_ERROR
	ECHO %DATE% %TIME% %SIG_FILE% Error: %MY_STATUS%. >> %ERRFILE%	
	ECHO %DATE% %TIME% %SIG_FILE% Error: %MY_STATUS%. >> %LOGFILE%
	
	GOTO END
	
:END
	REM Log the end time
	ECHO %DATE% %TIME% %1 signal completed >> %LOGFILE%

	REM Very important... use an exit command or the calling SQL Job will hang waiting for completion it never sees.
	EXIT

REM --------------------------------- end file -----------------------------------------
