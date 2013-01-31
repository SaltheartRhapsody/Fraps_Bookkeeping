#cs
AutoIt Version: 3.3.8.1
 Author:	Saltheart
 Date:		12/28/2012

 Script Function:
   Generic Script for Recording/Bookkeeping PC games with Fraps.  It handels the grouping of sets of fraps output (*.avi) files into logical file names and directory structures,
   specifically for ease of use with virtualdub.
 Use:
   Modify the two Global variables ($SourceFolder and $GameFolder) in the *.ini, and make sure it is in the same working directory as the *.exe.  Bind the functions to your desired hotkeys 
   below in the hotkey section.  The idea being that you will start recording at the start of a match, then stop at the end... then use the hotkeys to either save or purge the recorded material.
   Due to the watchdog loop, you need not restart the script for the next match, simply hit the record key again as you normally would.
   
   Current Default Hotkeys:
   Purge: Numpad 7
   Archive: Numpad 9
   Exit Script: Numpad 2
   
   Example file stucture might be:
   
   Y:\Fraps\Recordings\
		 Hawken\
 			   Hawken_12_28_2012\
					 Match_1\
						   segment_1.avi
						   segment_2.avi
						   ...
					 ...
			   ...
		 ...	
			
#ce

#include <File.au3>
#include <Array.au3>
; Initializations 
Global $Record = 0
Global $SourceFolder = IniRead("Record_config.ini", "Initializations", "SourceFolder", "NotFound")  ; Modify this to be your Fraps dump folder, subsiquent game dirs will be created here (must end in \ for windows machines)
Global $GameFolder = IniRead("Record_config.ini", "Initializations", "GameFolder", "NotFound") ; Modify this to be the desired game folder you're recording for, this will be the root dir for said game
   

; Create various subdirs if needed - Helper Function
Func FolderPreamble()
   
   ; Initializations
   $Date = @MON & "-" & @MDAY & "-" & @YEAR
   Global $DatedSubdir = $SourceFolder & $GameFolder & "\" & $GameFolder & "-" & $Date ; exported to global variable
   
   ; Create game root dir if it doesnt exist
   If Not FileExists($SourceFolder & $GameFolder) Then
		 DirCreate($SourceFolder & $GameFolder)
   EndIf
	  
   ; Create date-indexed subdir if it doesnt exist
   If Not FileExists($DatedSubdir) Then
		 DirCreate($DatedSubdir)
   EndIf
		 
EndFunc

; Exit Function -- Helper Function
Func End()
   Exit
EndFunc

; Archive dump dir -- output to game root dir in new indexted subdir
Func Archive()
   	  
	  ; Initializations
	  $MatchCount = 0;

	  FolderPreamble()	; create directory tree if needed
	  
	  ; Create match-indexed subdir
	  $FolderArray = _FileListToArray($DatedSubdir, "Match_*", 2)
	  If @error = 4 Then ; return 4 to @error -> No Files/Folders Found
		 $MatchCount = 1
		 $MatchDir = $DatedSubdir & "\Match_" & $MatchCount
		 DirCreate($MatchDir)
	  Else
		 $MatchCount = $FolderArray[0] + 1
		 $MatchDir = $DatedSubdir & "\Match_" & $MatchCount
		 DirCreate($MatchDir)
	  EndIf
	  
	  ; move files from dump dir to match-indexed dir and rename for easy virtualdub appending
	  $FilesArray = _FileListToArray($SourceFolder, "*.avi", 1)
	  If @error = 4 Then ; return 4 to @error -> No Files/Folders Found
		 MsgBox(0, "", "Error: You do not seem to have recorded anything! Check disk space and config options for this script.")
	  Else
		 ; move and rename files
		 $FileCount = $FilesArray[0]
		 For $i = 1 To $FileCount Step 1
			FileMove($SourceFolder & $FilesArray[$i], $MatchDir & "\segment_" & $i & ".avi")
		 Next
	  EndIf
EndFunc

; Purge dump dir -- Delete all *.avi files in dump dir
Func Purge()
   FileDelete( $SourceFolder & "*.avi")
EndFunc

; Bind functions to Hotkeys. Edit these to any keys you want to use to control the script
HotKeySet('{NUMPAD9}', 'Archive')
HotKeySet('{NUMPAD7}', 'Purge')
HotKeySet('{NUMPAD2}', 'End')

; Watchdog loop - Will keep the script running in the background until exited
While 1
   Sleep(1)
WEnd
