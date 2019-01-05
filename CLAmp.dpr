program CLAmp;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  UWinAmp,
  Classes,
  StrUtils,
  USplit in 'USplit.pas',
  UWhereIsWinamp in 'UWhereIsWinamp.pas',
  UWinampDefs in 'UWinampDefs.pas',
  UMixer in 'UMixer.pas';

var
  wa : TWinAmp;
  bSkipNext : Boolean;
  bSkipNextNext : Boolean;

procedure usage;
begin
  writeln ('CLAMP - Command Line Winamp - Version 1.14');
//  writeln ('CLAMP - Command Line Winamp - Special version for Matthias von Herrmann');
  writeln ('http://membres.lycos.fr/clamp/');
  writeln ('tools@caramail.com');
  writeln ('');
  writeln ('Program Control');
  Writeln ('---------------');
 	writeln ('/START ............ Start Winamp');
 	writeln ('/QUIT ............. Exit Winamp');
 	writeln ('/RESTART .......... Restart Winamp');
 	writeln ('/TOFRONT .......... Bring Winamp window to front');
  writeln ('');
  writeln ('General Control');
  Writeln ('---------------');
 	writeln ('/PLAY ............. Play (current file) - Quits Stopped or Pause mode');
 	writeln ('/STOP ............. Stop playing');
 	writeln ('/STOPFADE ......... Stop playing with fadeout');
 	writeln ('/STOPAFTER ........ Stop after current track');
 	writeln ('/PAUSE ............ Toggle pause mode (Synonym: /PLAYPAUSE)');
 	writeln ('/PAUSE ON|OFF ..... Sets pause mode ON or OFF (Synonym: /PLAYPAUSE)');
 	writeln ('/NEXT ............. Play next song');
 	writeln ('/PREV ............. Play previous song');
 	writeln ('/FWD .............. Forward 5 seconds (Synonym: /FORWARD)');
 	writeln ('/REW .............. Rewind 5 seconds (Synonym: /REWIND)');
	writeln ('/JUMP <time> ...... Seeks within current track - <time> in millisecs');
	writeln ('/QUITAFTER ........ Close winamp upon completion of current track');  
  writeln ('');
  writeln ('Winamp Modes');
  Writeln ('------------');
 	writeln ('/REPEAT ........... Toggle repeat mode (Synonym: /SWREPEAT)');
 	writeln ('/REPEAT ON|OFF .... Set repeat ON or OFF (Same as /REPEAT=0 or /REPEAT=1)');
 	writeln ('/RANDOM ........... Toggle random mode');
 	writeln ('/RANDOM ON|OFF .... Set random ON or OFF (Same as /RANDOM=0 or /RANDOM=1)');
  writeln ('');
  writeln ('PlayList Control');
  Writeln ('----------------');
 	writeln ('/PLADD <file> ..... Add file(s) at end of playlist (Synonym: /LOAD)');
 	writeln ('/PLCLEAR .......... Clear Playlist (Synonym: /CLEAR)');
 	writeln ('/PLWIN ............ Show/Hide PlayList window');
 	writeln ('/PLPOS ............ Query Playlist position (Synonym: GETPLPOS)');
 	writeln ('/PLSET <pos> ...... Set Playlist position (Synonym: SETPLPOS)');
 	writeln ('/PLSET RANDOM ..... Set Playlist position to a random line');  
 	writeln ('/LOADNEW <file> ... Same as /PLCLEAR /PLADD <file>');
 	writeln ('/PLFIRST .......... Play first item of playlist');
 	writeln ('/PLLAST ........... Play last item of playlist');
 	writeln ('/PLSAVE <file> .... Save current playlist as a M3U file');
  writeln ('');
  writeln ('Winamp Volume Control');
  Writeln ('---------------------');
 	writeln ('/VOLUP [value] .... Volume up');
 	writeln ('/VOLDN [value] .... Volume down (Synonym: /VOLDOWN)');
 	writeln ('/VOLMAX ........... Set volume to maximum');
 	writeln ('/VOLMIN ........... Volume off (Synonym: /VOLOFF)');
 	writeln ('/VOLSET <value> ... Volume set (0-255 / MIN / MAX / OFF) (Synonym: /VOLUME)');
 	writeln ('/VOLGET ........... Get current volume level');
  writeln ('');
  writeln ('Windows Volume Control');
  Writeln ('----------------------');
 	writeln ('/<CHANNEL> <COMMAND>');
  Writeln ('CHANNEL ........... WAV');
  Writeln ('COMMAND');
  writeln ('  MUTE ON|OFF ..... Mute');
  writeln ('  VOLGET .......... Get volume level (Left, Right)');
  writeln ('  VOLSET <values> . Set volume');
  writeln ('');
  writeln ('Infos');
  Writeln ('-----');
 	writeln ('/POS .............. Query current position in file / Total Length');
 	writeln ('/POSITION ......... Query current position in file');
 	writeln ('/TITLE ............ Query current track title');
  writeln ('/PATHNAME ......... Pathname of current track''s file');
 	writeln ('/STATE ............ Query current state (PLAYING;PAUSED;STOPPED;NOT RUNNING)');
 	writeln ('/STATUS ........... Synonym for STATE');
 	writeln ('/VER .............. Prints WinAmp version');
 	writeln ('/TRACKINFO <info> . Prints an information among: LENGTH, POS, BITRATE, SAMPLERATE, CHANNELS ');
 	writeln ('/PLINFO <info> .... Prints an information among: LENGTH, POS');
  writeln ('');
  writeln ('Rating');
  Writeln ('------');
 	writeln ('/RATING ........... Display current track rating (1-5 or 0 if missing)');
 	writeln ('/RATING=X ......... Set current track rating');  
  writeln ('');
  writeln ('Winamp interactive windows');
  Writeln ('--------------------------');
 	writeln ('/ABOUT ............ Open Winamp About window');
 	writeln ('/PREFS ............ Open Winamp Preferences window');
 	writeln ('/OPEN ............. Open Winamp Open File window');
 	writeln ('/MEDIALIB ......... Open Winamp Media Library window');
 	writeln ('/VIDEOFULLSCREEN .. Toggles video window full screen mode');  
  writeln ('');
  writeln ('Equalizer control');
  Writeln ('-----------------');
 	writeln ('/EQWIN ............ Show/Hide Eq window (Works with Classic skins only)');
 	writeln ('/EQINFO ........... Query Eq parameters (10 bands, Preamp, Status, Autoload)');
 	writeln ('/EQSET <parms> .... Set Eq parameters (Same format as EQINFO)');    
 	writeln ('/EQSTATUS ......... Toggle Eq status (ON / OFF)');
 	writeln ('/EQSTATUS ON|OFF .. Set Eq ON or OFF');
  writeln ('');
  writeln ('Winamp display');
  Writeln ('--------------');
 	writeln ('/ONTOP ............ Toggle "Always On Top" Option');
 	writeln ('/MAINWIN .......... Toggle Main window');
 	writeln ('/MINIMIZE ......... Minimize window');
  writeln ('');
  writeln ('Visualizer');
  Writeln ('----------');
 	writeln ('/VISUEXEC ......... Toggle visualization plug-in dsiplayed / hidden');
 	writeln ('/VISUEXEC ON|OFF .. Open/Close visualization plug-in');
 	writeln ('/VISUEXEC STATUS .. ON if visible, OFF if hidden');
  writeln ('');
  writeln ('Bookmarks management');
  Writeln ('--------------------');
 	writeln ('/BOOKMARK <file> .. Add file to bookmarks');
 	writeln ('/BOOKMARK CURRENT . Add current track to bookmarks');
 	writeln ('/BOOKMARKS_EDIT ... Open bookmarks window');
  writeln ('');
  writeln ('Skin management');
  Writeln ('---------------');
 	writeln ('/SKINGET .......... Get name of current skin');
  writeln ('');
  writeln ('Winamp process');
  Writeln ('--------------');
 	writeln ('/CLASS <class> .... Class name');
 	writeln ('/PID .............. Display Winamp process id');
  writeln ('');
  writeln ('Install');
  Writeln ('-------');
 	writeln ('/INSTALLDIR ....... Display Winamp install directory as considered by CLAmp');
 	writeln ('/INSTALLDIR=XXX.... Assume Winamp install directory as indicated');
 	writeln ('/INIFILE .......... Display ini file used at winamp start');
 	writeln ('/INIDIR ........... Display ini directory');
  writeln ('');
  writeln ('Output plug-in');
  Writeln ('--------------');
 	writeln ('/OUTPUTPLUGIN ..... Display name of active output plug-in (same as /OPGET)');
  writeln ('');
  writeln ('Misc');
  Writeln ('----');
 	writeln ('/CDPLAY ........... Play CD');
 	writeln ('/JUMPTOFILE ....... Open the ''Jump to file'' window');

  {
  WACommand Line
ok 	writeln ('/STOPFADE ......... Stop playback with fadeout');
 	writeln ('/STOPAFTER ......... Stop playback after current track');
 	writeln ('/PLAYPAUSE ......... Same as PAUSE');
 	writeln ('/CD <n> ......... Play CD # <n>');
 	writeln ('/VOL=<value> ......... Same as /VOLSET but on a 0-100 scale');
 	writeln ('/JUMPTO ......... Opens Winamp "Jump to file" window');
  }

  {
CLEVER 1.0: CommandLine EVEnt Renderer for WinAmp 2.x
WinAmp must already be running in order to Clever to work.
Usage: clever <command> <options-if-needed>
Standard commands: prev | rewind | play | pause | stop | forward | next
And more:
OK  playpause            Start playing / pause song
OK  load     <filename>  Add specified file to pl (mp3 or playlist)
ok  loadnew  <filename>  Change to specified file (mp3 or playlist)
ok  loadplay <filename>  Changes pl or file and starts to play it
OK  volume <number>      Set volume (0-255)
OK  volup / voldn        Increase / Decrease volume
ok  clear                Clears current playlist
ok  status               Displays status of Winamp
ok  getplpos             Displays the playlist position starting from 1
ok  swshuffle            Changes shuffle state. Displays new state
ok  swrepeat             Changes repeat state. Displays new state
ok  getshuffle           Displays shuffle state
ok  getrepeat            Displays repeat state
ok  position             Time elapsed on the current playing song
  timeleft             Time left on the current playing song
  }


//  ExitLevel := 1;
	Halt (0);
end;

//----------------------------------------------------------------------

function GetValue (i : integer; sArg, sCmd : String) : integer;
var
  sParm : String;
  c : Char;
begin
	Result := 999;

	if Copy (sArg, 1, 7) = (sCmd + '=') then
  begin
  	if sArg = (sCmd + '=1') then
    begin
			Result := 1;
      Exit;
    end;

  	if sArg = (sCmd + '=0') then
    begin
			Result := 0;
      Exit;
    end;

    WriteLn ('Incorrect '+sCmd+' value');
    Halt (1);

  end;

  if i = ParamCount then // No more args
  begin
  	Result := -1;
    Exit;
  end;

  sParm := ParamStr(i+1);
  c := sParm[1];

  if (c = '-') or (c = '/') then
  begin
  	Result := -1;
    Exit;
  end;

  bSkipNext := True;
  sParm := UpperCase (sParm);

  if (sParm = 'ON') or (sParm = '=1') then
  begin
  	Result := 1;
    Exit;
  end;

  if (sParm = 'OFF') or (sParm = '=0') then
  begin
  	Result := 0;
    Exit;
  end;

  if (sParm = 'STATUS') then
  begin
  	Result := 99;
    Exit;
  end;

  WriteLn ('Incorrect '+sCmd+' value');
  Halt (1);
end;

//----------------------------------------------------------------------

function min (a,b : integer) : integer;
begin
	Result := a;

  if b < a then
  	Result := b;
end;

procedure process_EqSet (i : integer; sArg : String);
var
	pos, n : Integer;
  sValuesString : String;
	sa : TSplitArray;
  iValue : Integer;
begin
	if i = ParamCount then
  begin
  	Writeln ('EQSET needs values');
    Halt (1);
  end;

  sValuesString := ParamStr (i + 1);
  bSkipNext := True;

  sa := Split (sValuesString, ':');

  n := min (Length (sa), 13);

  iValue := 0;

  for pos := 0 to (n-1) do
  begin
  	Try
    	iValue := StrToInt (sa[pos]);
    Except
      Writeln ('Wrong parameters for EQSET');
      Halt (1);
    End;

  	case pos of
    	0 .. 9 : wa.Eq.Band[pos] := iValue;
      10     : wa.eq.PreAmp    := iValue;
      11     : wa.eq.Enabled   := (iValue <> 0);
      12     : wa.eq.AutoLoad  := (iValue <> 0);
    end;
  end;

  wa.EqDataSet;
end;

//----------------------------------------------------------------------

procedure process_Repeat (i : integer; sArg : String);
var
	iCr : Integer;
	bNewState : Boolean;
begin
	bNewState := True;	// Anything, just to make compiler happy
	iCr := GetValue (i, sArg, 'REPEAT');

  case iCr of
  	-1 : bNewState := not wa.RepeatGet;
  	 1 : bNewState := True;
  	 0 : bNewState := False;
    99 :     // STATUS
      begin
        case wa.RepeatGet of
        True  : WriteLn ('ON');
        False : WriteLn ('OFF');
        end;
        Exit;
      end;
  end;

  wa.RepeatSet (bNewState);
end;

procedure process_EqStatus (i : integer; sArg : String);
var
	iCr : Integer;
	bNewState : Boolean;
begin
	bNewState := True;	// Anything, just to make compiler happy

	iCr := GetValue (i, sArg, 'EQSTATUS');

	wa.EqDataGet;

  case iCr of
  	-1 : bNewState := not wa.Eq.Enabled;
  	 1 : bNewState := True;
  	 0 : bNewState := False;
    99 :     // STATUS
      begin
        case wa.Eq.Enabled of
        True  : WriteLn ('ON');
        False : WriteLn ('OFF');
        end;
        Exit;
      end;
  end;

  wa.EqStatusSet (bNewState);
end;

procedure process_VisuExec (i : integer; sArg : String);
var
	iCr : Integer;
	bNewState : boolean;
begin
	bNewState := True;	// Anything, just to make compiler happy
	iCr := GetValue (i, sArg, 'VISUEXEC');

  case iCr of
  	-1 : bNewState := not wa.Visu.bRunning;
  	 1 : bNewState := True;
  	 0 : bNewState := False;
    99 :     // STATUS
      begin
        case wa.Visu.bRunning of
        True  : WriteLn ('ON');
        False : WriteLn ('OFF');
        end;
        Exit;
      end;
  end;

  wa.VisuExec (bNewState);
end;

//----------------------------------------------------------------------

procedure
process_TrackInfo (i : integer; sCmd : String);
var
  sParm : String;
  c : Char;
begin
  if i = ParamCount then // No more args
  begin
    Exit;
  end;

  sParm := ParamStr(i+1);
  c := sParm[1];

  if (c = '-') or (c = '/') then
  begin
    Exit;
  end;

  bSkipNext := True;
  sParm := UpperCase (sParm);

  if (sParm = 'LENGTH') then
  begin
    wa.GetCurrentFileInfos;
    Writeln (wa.CurrentFile.sLength);
  end;

  if (sParm = 'POS') then
  begin
    wa.GetCurrentPosition;
    Writeln (wa.sPosition);
  end;

  if (sParm = 'SAMPLERATE') then
  begin
    wa.GetCurrentFileInfos;
    Writeln (wa.CurrentFile.iSampleRate);
  end;

  if (sParm = 'BITRATE') then
  begin
    wa.GetCurrentFileInfos;
    Writeln (wa.CurrentFile.iBitRate);
  end;

  if (sParm = 'CHANNELS') then
  begin
    wa.GetCurrentFileInfos;
    Writeln (wa.CurrentFile.iChannels);
  end;

end;


//----------------------------------------------------------------------

procedure
process_PLInfo (i : integer; sCmd : String);
var
  sParm : String;
  c : Char;
  iRes : Integer;
begin
  if i = ParamCount then // No more args
  begin
    Exit;
  end;

  sParm := ParamStr(i+1);
  c := sParm[1];

  if (c = '-') or (c = '/') then
  begin
    Exit;
  end;

  bSkipNext := True;
  sParm := UpperCase (sParm);

  if sParm = 'LENGTH' then
  begin
    iRes := wa.PlayListLengthGet;

    if iRes = -1 then
    begin
      Writeln ('Information not available [21]');
      Exit
    end;

    Writeln (IntToStr(iRes));
  end;

  if sParm = 'POS' then
  begin
    iRes := wa.PlayListPosGet;

    if iRes = -1 then
    begin
      Writeln ('Information not available [22]');
      Exit
    end;

    Writeln (IntToStr(iRes+1));
  end;
end;
//----------------------------------------------------------------------

procedure process_Random (i : integer; sArg : String);
var
	iCr : Integer;
	bNewState : Boolean;
begin
	bNewState := True;	// Anything, just to make compiler happy
	iCr := GetValue (i, sArg, 'RANDOM');

  case iCr of
  	-1 : bNewState := not wa.ShuffleGet;
  	 1 : bNewState := True;
  	 0 : bNewState := False;
    99 :     // STATUS
      begin
        case wa.ShuffleGet of
        True  : WriteLn ('ON');
        False : WriteLn ('OFF');
        end;
        Exit;
      end;
  end;

  wa.ShuffleSet (bNewState);
end;

//----------------------------------------------------------------------

{
procedure
ExpandFilenamePattern (tsFilename : TStrings; sFilenamePattern : String);
var
  intFound: Integer;
  SearchRec: TSearchRec;
begin
  tsFilename.Clear;
  intFound := FindFirst(sFilenamePattern, faAnyFile, SearchRec);
  while intFound = 0 do
  begin
    tsFilename.Add(SearchRec.Name);
    intFound := FindNext(SearchRec);
  end;
  FindClose(SearchRec);
end;
}

//----------------------------------------------------------------------

{
sFilenamePattern :
*.mp3
c:\xx\yy.mp3

}

procedure Process_PLADD_files (sPathnamePattern : String);
var
  sFileName, sPathname : String;
  sDir,sFilenamePattern : String;
  sPattern : String;
  SearchRec: TSearchRec;
  nFound : integer;
//  i : integer;
	intFound : integer;
begin

  // Extract pathname (without filename)
  // 'c:\music\x.mp3' --> 'c:\music\'
  // 'c:\music\'      --> 'c:\music\'
  // '*.mp3'          --> ''
  sDir := ExtractFilePath(sPathnamePattern);

  if (sDir = '') then
  begin
    sDir := GetCurrentDir + '\';
  end;

  if (not DirectoryExists(sDir)) then
  begin
    Writeln (sDir + ' is not a directory');
    Halt (1);
  end;

  // Extract filename (or pattern) (without path)
  // 'c:\music\x.mp3' --> 'x.mp3'
  // 'c:\music\*.mp3' --> '*.mp3'
  // 'c:\music\'      --> ''
  sFilenamePattern := ExtractFileName(sPathnamePattern);
  if (sFilenamePattern = '') then
  begin
    Writeln (sPathnamePattern + ' is not a filename or a filename pattern');
    Halt (1);
  end;

  sPattern := sDir + sFilenamePattern;

  nFound := 0;
  intFound := FindFirst(sPattern, faAnyFile, SearchRec);
  while intFound = 0 do
  begin
    If (SearchRec.Name[1] <> '.') then  // Skip anything starting with a dot ('.', '..', or files with a leading dot)
    begin
      If (SearchRec.Attr and faDirectory > 0) then {it is a directory, not a file}
      begin
      end
      else  // it is a file
      begin
        Inc (nFound);
        sFileName := SearchRec.Name;
        sPathname := sDir + sFilename;
        wa.PlayListAdd(sPathname);
        intFound := FindNext(SearchRec);
      end;
    end;
  end;
  FindClose(SearchRec);

  if nFound < 1 then
  begin
    Writeln ('No match found for ' + sFilenamePattern + ' in ' + sDir);
    Halt (1);
  end;
end;

//----------------------------------------------------------------------

procedure Process_PLADD_http (sURL : String);
begin
  wa.PlayListAdd(sURL);
end;

//----------------------------------------------------------------------

// Indique si un pathname est un chemin réseau ou non

{
function isHTTP (str : String) : Boolean;
var
  iLen : Integer;
begin
  Result := false;

  iLen := Length (str);

  if ((iLen > 7) and (LeftStr (str, 7) = 'http://')) then
    Result := true;

  if ((iLen > 8) and (LeftStr (str, 8) = 'https://')) then
    Result := true;

  if ((iLen > 7) and (LeftStr (str, 7) = 'rtsp://')) then
    Result := true;

  if ((iLen > 6) and (LeftStr (str, 6) = 'mms://')) then
    Result := true;
end;
}

// Il y a différents protocoles et il est illusoire de les lister tous
// Le pattern à reconnaitre est :
// <network protocol> : / / <URI>
// Il suffit donc de reconnaitre '://'
// Pos retourne 0 si la sous-chaine est absente,
// sa position (commençant à 1) sinon.

function isURL (str : String) : Boolean;
var
  iPos : Integer;
begin
  iPos := Pos('://',str);
  Result := (iPos <> 0);
end;

//----------------------------------------------------------------------

procedure Process_PLADD (sFilenamePattern : String);
begin
  if (isURL (sFilenamePattern)) then
    Process_PLADD_http (sFilenamePattern)
  else
    Process_PLADD_files (sFilenamePattern);
end;

//----------------------------------------------------------------------

function WindowsSound(i : integer) : boolean;
var
  wRVol, wLVol : Word;
  sWavCmd, sWavArg : String;
  iLevel : Integer;
  sParm : String;
begin
  Result := False;

  if (i = ParamCount) then
  begin
    Writeln ('/WAV expects arguments');
    Exit;
  end;

  bSkipNext := True;
  sWavCmd := UpperCase(ParamStr(i+1));

  if sWavCmd = 'VOLGET' then
  begin
    GetWaveVolume (wLVol, wRVol);
    writeln (IntToStr(wLVol) + ' ' + IntToStr(wRVol));
    Result := true;
    Exit;
  end;

  if (sWavCmd = 'VOLSET') then
  begin
    if (i+1) = ParamCount then // No more args
    begin
      WriteLn ('VOLSET expects an argument');
      exit;
    end;

    sParm := ParamStr(i+2);

    if (UpperCase(sParm) = 'MIN') or (UpperCase(sParm) = 'OFF') then iLevel := 0
    else
    if UpperCase(sParm) = 'MAX' then iLevel := 65535
    else
      Try
        iLevel := StrToInt (sParm);
      Except
        iLevel := -1;
      end;

    if (iLevel < 0) or (iLevel > 65535)  then
    begin
      Writeln ('Expected VOLSET arg is 0 - 65535');
      Exit;
    end;

    if not SetWaveVolume (iLevel, iLevel) then
      Writeln ('Volume setting failed.');

    bSkipNext := True;
    bSkipNextNext := True;
    Result := True;
    Exit;
  end;

  if sWavCmd = 'MUTE' then
  begin
    SetMixerLineSourceMute (lsWaveOut, true);

    if ((i+1) = ParamCount)
    then
    begin
      Writeln ('/WAV MUTE expects an argument');
      Result := False;
      exit;
    end;

    sWavArg := UpperCase(ParamStr(i+2));

    if (sWavArg <> 'ON') and (sWavArg <> 'OFF') then
    begin
      Writeln ('Syntax: /WAV MUTE ON|OFF');
      Halt (1);
    end;

    SetMixerLineSourceMute (lsWaveOut, sWavArg = 'ON');

    bskipNext := True;
    bSkipNextNext := True;
    Result := True;
    exit;
  end;  // MUTE
end;

//----------------------------------------------------------------------

procedure StartIfNeeded;
begin
  if wa.GetWinHandle = 0 then
    if not wa.Start then
    begin
      Writeln ('Can''t start Winamp');
      Halt (1);
    end;
end;

procedure Main;
var
	i,eqi,voli, iPos : integer;
  c : char;
  sCmd : String;
  bRecognized : Boolean;
  sParm : String;
  iLEvel : integer;
  sTmp : String;
  iMsg : cardinal;
  iCr : integer;
  sClass : String;
begin
  //
  //   Recherche si l'option /CLASS est utilisée
  //   et son paramètre
  //   Stocke dans sClass
  //

  sClass := '';
  for i := 1 to ParamCount do
  begin
    sTmp := ParamStr(i);
    sTmp := UpperCase (sTmp);

    if (sTmp = '/CLASS') or (sTmp = '-CLASS') then
      if i < ParamCount then
        sClass := ParamStr(i+1)
      else
      begin
        Writeln ('CLASS expects an argument');
        Halt (1);
      end;
  end;

	wa := TWinAmp.Create (sClass);

  // Launch winamp if not already running
  // V 3.xx not detected causes re launch
  // Quite ugly but how to detect something... we cannot detect ?

  {
	if wa.GetWinHandle = 0 then
  	wa.Start;
  }
	bSkipNext := False;
	bSkipNextNext := False;

  //---------------------------------------
  // Arguments
  //---------------------------------------

  if ParamCount = 0 then
  begin
  	Writeln ('No option');
  	Halt (1);
  end;

  for i := 1 to ParamCount do
  begin
    if bSkipNextNext then
    begin
      bSkipNextNext := False;
      continue;
    end;

  	if bSkipNext then
    begin
    	bSkipNext := False;
      continue;
    end;

    c := ParamStr(i)[1];
    if (c <> '-') and (c <> '/') then
    begin
      Writeln ('Syntax error');
      Halt(1);
    end;

    sCmd := UpperCase (Copy (ParamStr(i), 2, Length(ParamStr(i))-1));

    bRecognized := False;

    if (sCmd = '?')
    or (sCmd = 'HELP') then
      usage;

    if sCmd = 'START' then
    begin
      bRecognized := True;
      if not wa.Start then
      begin
        if wa.iErrorCode = 200 then
          Writeln ('Winamp not found')
        else
          Writeln ('Unable to start "'+wa.getWinampExePathname+'" (error ' + IntToStr(wa.iErrorCode) + ')');

        Halt (1);
      end;

      // Winamp running

      if wa.iErrorCode = 100 then
        Writeln ('Info : Winamp is already running');
    end;

    if sCmd = 'PATHNAME' then
    begin
      bRecognized := True;
      StartIfNeeded;

      wa.GetCurrentFileInfos;

      Writeln (wa.CurrentFile.sPathname);

    end;

    // TEST
    if sCmd = 'VIDEOFULLSCREEN' then
    begin
      bRecognized := True;
      wa.VideoFullScreen;
    end;

    if sCmd = 'TOFRONT' then
    begin
      bRecognized := True;
      wa.BringToFront;
    end;

    if sCmd = 'SKINGET' then
    begin
      bRecognized := True;
      StartIfNeeded;
      writeln(wa.skinget);
    end;

    if (sCmd = 'OPGET')
    or (sCmd = 'OUTPUTPLUGIN')
    then
    begin
      bRecognized := True;
      StartIfNeeded;
      writeln(wa.OutputPluginGet);
    end;

    if sCmd = 'INIFILE' then
    begin
      bRecognized := True;
      writeln(wa.IniPathnameGet);
    end;

    if sCmd = 'INIDIR' then
    begin
      bRecognized := True;
      writeln(wa.IniDirGet);
    end;

    if sCmd = 'PID' then
    begin
      bRecognized := True;
      writeln(wa.getPid);
    end;

    if sCmd = 'RESTART' then
    begin
      bRecognized := True;
      wa.ReStart;
    end;

    if sCmd = 'CDPLAY' then
    begin
      bRecognized := True;
      StartIfNeeded;
      wa.PlayCD;
    end;

    if sCmd = 'QUIT' then
    begin
      bRecognized := True;
      wa.Quit;
    end;

    if sCmd = 'VER' then
    begin
      bRecognized := True;
      StartIfNeeded;
      Writeln (wa.sVersion);
    end;

    if sCmd = 'TITLE' then
    begin
      bRecognized := True;
      StartIfNeeded;

      wa.GetCurrentFileInfos;

      Writeln (wa.CurrentFile.sTitle);
    end;

    {
    if sCmd = 'SKIN' then
    begin
      bRecognized := True;
      Writeln (wa.skinGet);
    end;
    }

    if sCmd = 'MAINWIN' then
    begin
      bRecognized := True;
      StartIfNeeded;

      wa.MainWindowShowHide;
    end;

    if sCmd = 'INSTALLDIR' then
    begin
      bRecognized := True;
      StartIfNeeded;
      sTmp := wa.GetWinampInstallDirectory;
      if sTmp = '' then
        WriteLn ('Not found')
      else
        WriteLn (stmp);
    end;

    if LeftStr (sCmd, 11) = 'INSTALLDIR=' then
    begin
      bRecognized := True;
      StartIfNeeded;
      sTmp := Midstr (sCmd, 12, Length(sCmd) - 11);
      wa.SetWinampInstallDirectory (sTmp);
    end;

    if sCmd = 'RATING' then
    begin
      bRecognized := True;
      StartIfNeeded;
      iPos := wa.RatingGet;
      if iPos = -1 then
        Writeln ('Error')
      else
        WriteLn (IntToStr(iPos));
    end;

    if LeftStr (sCmd, 7) = 'RATING=' then
    begin
      bRecognized := True;
      StartIfNeeded;
      sTmp := Midstr (sCmd, 8, Length(sCmd) - 7);
      iPos := StrToIntDef (sTmp, -1);
      if (iPos = -1) or (iPos > 5) or (iPos < 0) then
      begin
        Writeln ('Incorrect rating');
        halt (1);
      end;
      wa.RatingSet (iPos);
    end;

    if sCmd = 'MINIMIZE' then
    begin
      bRecognized := True;
      StartIfNeeded;

      wa.Minimize;
    end;

    if sCmd = 'WAV' then
    begin
      bRecognized := WindowsSound (i);

      if not bRecognized then
      begin
        Writeln ('Unrecognized /WAV command');
        Halt (1);
      end;

    end;

    if sCmd = 'EQSET' then
    begin
      bRecognized := True;
      StartIfNeeded;

      process_EqSet (i, sCmd);
    end;

    if sCmd = 'EQINFO' then
    begin
      bRecognized := True;
      StartIfNeeded;

      wa.EqDataGet;

      sTmp := '';
      for eqi := 0 to 9 do
        sTmp := sTmp + IntToStr(wa.Eq.Band[eqi]) + ':';

      sTmp := sTmp +  IntToStr(wa.Eq.Preamp);
      sTmp := sTmp +  ':';
      if wa.eq.enabled then
        sTmp := sTmp +  '1'
      else
        sTmp := sTmp +  '0';
      sTmp := sTmp +  ':';
      if wa.eq.autoload then
        sTmp := sTmp +  '1'
      else
        sTmp := sTmp +  '0';

      Writeln (sTmp);
    end;

    if (sCmd = 'FWD')
    or (sCmd = 'FORWARD') then
    begin
      bRecognized := True;
      StartIfNeeded;

      wa.FForward;
    end;

    if (sCmd = 'REW')
    or (sCmd = 'REWIND')
    or (sCmd = 'REV') then
    begin
      bRecognized := True;
      StartIfNeeded;

      wa.Rewind;
    end;

    if sCmd = 'PLAY' then
    begin
      bRecognized := True;
      StartIfNeeded;

      wa.Play;
    end;

    if sCmd = 'REPLAY' then
    begin
      bRecognized := True;
      // Don't know how to do that
    end;

    if sCmd = 'PLLAST' then
    begin
      bRecognized := True;
      StartIfNeeded;

      wa.PlayLast;
    end;

    if sCmd = 'PLFIRST' then
    begin
      bRecognized := True;
      StartIfNeeded;

      wa.PlayFirst;
    end;

    if sCmd = 'STOP' then
    begin
      bRecognized := True;
      StartIfNeeded;

      wa.Stop;
    end;

    if sCmd = 'STOPFADE' then
    begin
      bRecognized := True;
      StartIfNeeded;

      wa.Fade;
    end;

    if sCmd = 'STOPAFTER' then
    begin
      bRecognized := True;
      StartIfNeeded;

      wa.StopAfter;
    end;

    if sCmd = 'QUITAFTER' then
    begin
      bRecognized := True;
      StartIfNeeded;

      wa.QuitAfter;
    end;

    if (sCmd = 'PLAYPAUSE') then
    begin
      bRecognized := True;
      StartIfNeeded;

      if (i < ParamCount)
      and
      (
      (UpperCase(ParamStr(i+1)) = 'ON')
      or
      (UpperCase(ParamStr(i+1)) = 'OFF')
      )
      then
      begin
        case wa.GetCurrentStatus of
         -1 : // No winamp
            begin
            end;
          0 : // Stopped
            if UpperCase(ParamStr(i+1)) = 'OFF' then
              wa.Play;
          1 : // Playing
            if UpperCase(ParamStr(i+1)) = 'ON' then
              wa.PauseToggle;
          3 : // Paused
            if UpperCase(ParamStr(i+1)) = 'OFF' then
              wa.PauseToggle;
        end;
        bSkipNext := True;
      end
      else  // No option provided
      begin
        case wa.GetCurrentStatus of
         -1 : // No winamp
            begin
            end;
          0 : // Stopped
            wa.Play;
          1 : // Playing
            wa.PauseToggle;
          3 : // Paused
            wa.PauseToggle;
        end;
      end;
    end;

    if (sCmd = 'PAUSE')
    then
    begin
      bRecognized := True;
      StartIfNeeded;

      if (i < ParamCount)
      and
      (
      (UpperCase(ParamStr(i+1)) = 'ON')
      or
      (UpperCase(ParamStr(i+1)) = 'OFF')
      )
      then
      begin
        wa.PauseSet (UpperCase(ParamStr(i+1)) = 'ON');
        bSkipNext := True;
      end
      else
        wa.PauseToggle;
    end;

    if sCmd = 'NEXT' then
    begin
      bRecognized := True;
      StartIfNeeded;
      wa.Next;
    end;

    if sCmd = 'PREV' then
    begin
      bRecognized := True;
      StartIfNeeded;

      wa.Prev;
    end;

    if sCmd = 'ABOUT' then
    begin
      bRecognized := True;
      StartIfNeeded;

      wa.ShowAbout;
    end;

    if sCmd = 'MEDIALIB' then
    begin
      bRecognized := True;
      StartIfNeeded;

      wa.ShowMediaLibrary;
    end;

    if sCmd = 'PREFS' then
    begin
      bRecognized := True;
      StartIfNeeded;

      wa.ShowPrefs;
    end;

    if sCmd = 'OPEN' then
    begin
      bRecognized := True;
      StartIfNeeded;

      wa.ShowOpenFile;
    end;

    if sCmd = 'ONTOP' then
    begin
      bRecognized := True;
      StartIfNeeded;

      wa.AlwaysOnTopToggle;
    end;

    if sCmd = 'EQWIN' then
    begin
      bRecognized := True;
      StartIfNeeded;

      wa.EqShowHide;
    end;

    if (sCmd = 'PLWIN') or (sCmd = 'PL') then
    begin
      bRecognized := True;
      StartIfNeeded;

      wa.PlayListShowHide;
    end;

    if sCmd = 'SWREPEAT' then
    begin
      bRecognized := True;
      StartIfNeeded;
      process_Repeat (i, 'REPEAT');
    end;

    if Copy(sCmd, 1, 6) = 'REPEAT' then
    begin
      bRecognized := True;
      StartIfNeeded;
      process_Repeat (i, sCmd);
    end;

    if sCmd = 'GETREPEAT' then
    begin
      bRecognized := True;
      StartIfNeeded;
      case wa.RepeatGet of
      True  : WriteLn ('ON');
      False : WriteLn ('OFF');
      end;
    end;

    if sCmd = 'GETSHUFFLE' then
    begin
      bRecognized := True;
      StartIfNeeded;
      case wa.ShuffleGet of
      True  : WriteLn ('ON');
      False : WriteLn ('OFF');
      end;
    end;

    if Copy(sCmd, 1, 8) = 'EQSTATUS' then
    begin
      bRecognized := True;
      StartIfNeeded;
      process_EqStatus (i, sCmd);
    end;

    if Copy(sCmd, 1, 6) = 'RANDOM' then
    begin
      bRecognized := True;
      StartIfNeeded;
      process_Random (i, sCmd);
    end;

    if Copy(sCmd, 1, 8) = 'VISUEXEC' then
    begin
      bRecognized := True;
      StartIfNeeded;
      process_VisuExec (i, sCmd);
    end;

    if sCmd = 'TRACKINFO' then
    begin
      bRecognized := True;
      StartIfNeeded;
      process_TrackInfo (i, sCmd);
    end;

    if sCmd = 'JUMPTOFILE' then
    begin
      bRecognized := True;
      StartIfNeeded;
      wa.JumpToFileWindow_Open;
    end;

    if sCmd = 'PLINFO' then
    begin
      bRecognized := True;
      StartIfNeeded;
      process_PLInfo (i, sCmd);
    end;

    //
    // Undocumented option
    // Usage : /MSG <number>
    // Send message to winamp
    //
    if (sCmd = 'MSG')
    then
    begin
      bRecognized := True;
      StartIfNeeded;

      if i = ParamCount then // No more args
      begin
        WriteLn ('MSG expects an argument');
        Halt(1);
      end;

      iMsg := StrToIntDef (ParamStr(i+1), 0);

      if iMsg = 0 then
      begin
        WriteLn ('Incorrect MSG argument');
        Halt(1);
      end;

      wa.Msg(iMsg);

      bSkipNext := True;
    end;

    //
    // Undocumented option
    // Usage : /KEY <number>
    // Send key press to winamp
    //
    if sCmd = 'KEY' then
    begin
      bRecognized := True;
      StartIfNeeded;

      if i = ParamCount then // No more args
      begin
        WriteLn ('KEY expects an argument');
        Halt(1);
      end;

      wa.SendKey ('R');

      bSkipNext := True;
    end;


    if (sCmd = 'JUMP')
    then
    begin
      bRecognized := True;
      StartIfNeeded;

      if i = ParamCount then // No more args
      begin
        WriteLn ('JUMP expects an argument');
        Halt(1);
      end;

      iMsg := StrToIntDef (ParamStr(i+1), 0);

      if iMsg = 0 then
      begin
        WriteLn ('Incorrect JUMP argument');
        Halt(1);
      end;

      wa.JumpToTime(iMsg);

      bSkipNext := True;
    end;

    if (sCmd = 'CLASS')
    then
    begin
      bRecognized := True;

      if i = ParamCount then // No more args
      begin
        WriteLn ('CLASS expects an argument');
        Halt(1);
      end;

      wa.sClass := ParamStr(i+1);
      wa.Init;

      StartIfNeeded;

      bSkipNext := True;
    end;

    if (sCmd = 'PLSAVE') then
    begin
      bRecognized := True;
      StartIfNeeded;
      bSkipNext := True;

      if i = ParamCount then // No more args
      begin
        WriteLn ('PLSAVE expects an argument');
        Halt(1);
      end;

      iCr := wa.PlayListSaveToFile(ParamStr(i+1));

      if iCr < 0 then  // Failure
      begin
        if iCr = -1 then
          WriteLn ('Can''t find Winamp install directory');
        if iCr = -2 then
          WriteLn ('Can''t delete files in Winamp install directory - This is needed to perform PLSAVE');
        if iCr = -3 then
          WriteLn ('Winamp was not able to generate playlist');
        if iCr = -4 then
          WriteLn ('Could not write to ' + ParamStr(i+1));
        Halt(1);
      end;

    end;

    if (sCmd = 'PLADD')
    or (sCmd = 'LOAD')
    or (sCmd = 'LOADNEW')
    or (sCmd = 'LOADPLAY')
    then
    begin
      bRecognized := True;
      StartIfNeeded;

      if i = ParamCount then // No more args
      begin
        WriteLn ('PLADD expects an argument');
        Halt(1);
      end;

      if (sCmd = 'LOADNEW') or (sCmd = 'LOADPLAY') then
        wa.PlayListClear;

      Process_PLADD (ParamStr(i+1));

      if sCmd = 'LOADPLAY' then
        wa.Play;

      bSkipNext := True;
    end;

    if (sCmd = 'BOOKMARKS_EDIT')
    then
    begin
      bRecognized := True;
      StartIfNeeded;
      wa.BookmarksEdit;      
    end;

    if (sCmd = 'BOOKMARK')
    then
    begin
      bRecognized := True;
      StartIfNeeded;

      if i = ParamCount then // No more args
      begin
        WriteLn ('BOOKMARK expects an argument');
        Halt(1);
      end;

      if UpperCase (ParamStr(i+1)) = 'CURRENT' then
        wa.BookmarkCurrent
      else
        wa.BookmarkFile (ParamStr(i+1));

      bSkipNext := True;
    end;

    if (sCmd = 'PLCLEAR')
    or (sCmd = 'CLEAR') then
    begin
      bRecognized := True;
      StartIfNeeded;
      wa.PlayListClear;
    end;

    if sCmd = 'VOLUP' then
    begin
      bRecognized := True;
      StartIfNeeded;

      iLevel := 1;
      if i < ParamCount then // More args
      begin
        sParm := ParamStr(i+1);
        Try
          iLevel := StrToInt (sParm);
          bSkipNext := True;
        Except
          iLevel := 1;
        end;
      end;

      for Voli := 1 to iLevel do
        wa.VolumeUp;
    end;

    if (sCmd = 'VOLDN')
    or (sCmd = 'VOLDOWN') then
    begin
      bRecognized := True;
      StartIfNeeded;

      iLevel := 1;
      if i < ParamCount then // More args
      begin
        sParm := ParamStr(i+1);
        Try
          iLevel := StrToInt (sParm);
          bSkipNext := True;
        Except
          iLevel := 1;
        end;
      end;

      for voli := 1 to iLevel do
        wa.VolumeDown;
    end;

    if (sCmd = 'VOLSET')
    or (sCmd = 'VOLUME') then
    begin
      bRecognized := True;
      StartIfNeeded;

      if i = ParamCount then // No more args
      begin
        WriteLn ('VOLSET expects an argument');
        Halt(1);
      end;
      sParm := ParamStr(i+1);

      if (UpperCase(sParm) = 'MIN') or (UpperCase(sParm) = 'OFF') then iLevel := 0
      else
      if UpperCase(sParm) = 'MAX' then iLevel := 255
      else
        Try
          iLevel := StrToInt (sParm);
        Except
          iLevel := -1;
        end;

      if (iLevel >= 0) and (iLevel <= 255)  then
        wa.VolumeSet (iLevel)
      else
      begin
        Writeln ('VOLSET scale is 0 - 255');
        Halt(1);
      end;
      bSkipNext := True;
    end;

    if LeftStr (sCmd, 4) = 'VOL=' then
    begin
      bRecognized := True;
      StartIfNeeded;

      sTmp := Midstr (sCmd, 5, Length(sCmd) - 4);

      Try
        iLevel := StrToInt (sTmp);
      Except
        iLevel := -1;
      end;

      if (iLevel >= 0) and (iLevel <= 100)  then
        wa.VolumeSet (Trunc(iLevel*2.55))
      else
      begin
        Writeln ('VOL scale is 0 - 100');
        Halt(1);
      end;
      bSkipNext := True;
    end;

    if (sCmd = 'PLSET')
    or (sCmd = 'SETPLPOS') then
    begin
      bRecognized := True;
      StartIfNeeded;

      if i = ParamCount then // No more args
      begin
        WriteLn (sCmd + ' expects an argument');
        Halt(1);
      end;
      sParm := ParamStr(i+1);

      if UpperCase(sParm) = 'RANDOM' then
        iPos := -999
      else
      begin
        Try
          iPos := StrToInt (sParm);
          Dec (iPos);
        Except
          iPos := -1;
        end;

        if iPos >= wa.PlayListLengthGet then
        begin
          Writeln ('Current playlist is only ' + InttoStr(wa.PlayListLengthGet) + ' item(s) long.');
          Halt(1);
        end;

        if iPos < 0 then
        begin
          Writeln (sCmd + ' option must be >= 1');
          Halt(1);
        end;
      end;

      wa.PlayListPosSet (iPos);
      bSkipNext := True;
    end;

    if sCmd = 'VOLMAX' then
    begin
      bRecognized := True;
      StartIfNeeded;
      wa.VolumeSet (255);
    end;

    if sCmd = 'VOLMIN' then
    begin
      bRecognized := True;
      StartIfNeeded;
      wa.VolumeSet (0);
    end;

    if sCmd = 'VOLGET' then
    begin
      bRecognized := True;
      StartIfNeeded;

      iLevel := wa.VolumeGet;
        
      Writeln (IntToStr(iLevel));
    end;

    if (sCmd = 'PLPOS') or (sCmd = 'GETPLPOS') then
    begin
      bRecognized := True;
      StartIfNeeded;

      wa.PlayListPosGet;
      wa.PlayListLengthGet;

      if wa.plLength = 0 then
        Writeln ('0/0')
      else
        Writeln (IntToStr(wa.plPosition + 1) + '/' + IntToStr(wa.plLength));
    end;

    if sCmd = 'POS' then
    begin
      bRecognized := True;
      StartIfNeeded;

      wa.GetCurrentPosition;
      wa.GetCurrentFileInfos;

      Writeln (wa.sPosition + ' / ' + wa.CurrentFile.sLength);
    end;

    if sCmd = 'POSITION' then
    begin
      bRecognized := True;
      StartIfNeeded;

      wa.GetCurrentPosition;

//        wa.GetCurrentFileInfos;

      Writeln (wa.sPosition);
    end;

    if sCmd = 'TIMELEFT' then
    begin
      bRecognized := True;
      StartIfNeeded;
// TODO
    end;

    if (sCmd = 'STATE') or (sCmd = 'STATUS') then
    begin
      bRecognized := True;

      if wa.GetWinHandle = 0 then
        Writeln ('NOT RUNNING')
      else
        case wa.GetCurrentStatus of
         -1 : Writeln ('ABSENT');
          0 : Writeln ('STOPPED');
          1 : Writeln ('PLAYING');
          3 : Writeln ('PAUSED');
        end;
    end;

    if not bRecognized then
    begin
      Writeln ('Unknown option ' + sCmd + ' (Use /? for help)');
      Halt(1);
    end;

  end;

end;

//------------------------------------------------------------------------

// --- MAIN ---

begin
  { TODO -oUser -cConsole Main : placez le code ici }

  TRy
  	Try
		  Main;
    Finally
    	wa.Free;
    end;
  Except
  	Halt (1);
  End;
end.

//------------------------------------------------------------------------
