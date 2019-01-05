unit UWinAmp;

interface

uses
	Windows	// SendMessage
  ,Messages	// WM_COMMAND
  ,SysUtils	// IntoToStr
  ,StrUtils	// LeftStr
  ,ShellApi // ShellExecute
  ,Classes  // ssShift
  ,USplit
  ,UWhereIswinamp
  ,UWinampDefs
//  ,UKeyboardOutput
//  ,UPostKey
  ;

//--------------------------------------------------------------------

type TPlayListItem = record
	sFilename : String;
end;

type TFileInfo = record
	sTitle      : String;
  iSampleRate : integer;
  iBitRate    : integer;
  iChannels   : integer;
  iLength     : integer;
  sLength     : String;
  sPathname   : String;
end;

type TEq = record
	Band     : array[0..9] of integer;
  PreAmp   : Integer;
  Enabled  : Boolean;
  AutoLoad : Boolean;
end;

type TVisu = record
    hwndVideo   : integer;  // Video display window
    bRunning : boolean;
end;

type TPlayList = array of TPlayListItem;

type TWinAmp = class(TObject)
	public
  	_wParam : cardinal;
    _iCr : integer;

    iErrorCode : integer;

    sClass : AnsiString;

  	// --- Version ---
    iRawVersion : integer;
    sVersion : String;

    // --- Titre en cours ---
    CurrentFile : TFileInfo;
    iPosition : integer;
    sPosition : String;

    // --- Equalizer ---
    Eq : TEq;

    // --- Visu ---
    Visu : TVisu;

    // --- PlayList ---
  	pl : TPlayList;
    plPosition : integer; // Elément en cours (0..plLength-1)
    plLength   : integer; // Nb éléments dans la playlist (0 si vide)

    sInstallDir : String;

    constructor Create(sClassParm : String);

  	procedure Init;
    procedure visu_init;
    procedure WaitForWinampToStart;

    // --- Winamp itself ---
  	function Start : Boolean;
    procedure Restart;
    procedure Quit;
    procedure VideoFullScreen;
    procedure BringToFront;

    // --- Status ---
  	procedure Play;
    procedure PauseToggle;
    procedure PauseSet (bOnOff : bool);
    procedure Stop;
    procedure Fade;	// Stop smoothly
    procedure StopAfter;	// Stop after current song
    procedure QuitAfter;    
		procedure FForward;
    procedure Rewind;
    procedure GetCurrentFileInfos;
    function  GetCurrentStatus : integer;
    procedure GetCurrentPosition;
    procedure JumpTotime (iMilliSec : integer);

    // --- Playlist management ---
  	procedure Next;
   	procedure Prev;
		procedure PlayListClear;
//    procedure PlayListRead;
		procedure PlayListPosSet (iPos : integer);
		function  PlayListPosGet : integer;
		function  PlayListLengthGet : integer;
    procedure PlayListAdd(sFilename : String);
//    procedure Replay;
		procedure PlayFirst;
    procedure PlayLast;
    function PlayListSaveToFile(FileName:string) : integer;

    // --- Volume control ---
    procedure VolumeSet (iLevel : integer);
    function  VolumeGet : integer;
    procedure VolumeUp;
    procedure VolumeDown;

    // --- Shuffle ---
    function ShuffleGet : Boolean;
    procedure ShuffleSet (bNewState : Boolean);

    {
    // --- Random ---
    function RandomGet : Boolean;
    procedure RandomSet (bNewState : Boolean);
    }
    procedure PlayCD;
    procedure JumpToFileWindow_Open;

    // --- Repeat ---
    function RepeatGet : Boolean;
    procedure RepeatSet (bNewState : Boolean);

    // --- Always on top ---
    procedure AlwaysOnTopToggle;

    // -- Bookmarks --
    procedure BookmarkFile (sFilename : string);
    procedure BookmarkCurrent;
    procedure BookmarksEdit;

    // --- Winamp Pop up windows ---
    procedure ShowAbout;
    procedure ShowPrefs;
    procedure ShowmEDIAlIBRARY;
    procedure ShowOpenFile;

    // -- Winamp display ---
    procedure EqShowHide;
    procedure EqDataGet;
		procedure EqDataSet;    
    procedure EqStatusSet (bValue : Boolean);
    procedure PlayListShowHide;
    procedure MainWindowShowHide;

    // -- Rating --
    function RatingGet : Integer;
    procedure RatingSet(iRating :Integer);

    // -- Visualization --
    procedure VisuExec(bStatus : boolean);

		// Plus ins only
//    procedure SkinSet (sPathname : String);
		function SkinGet : String;
		function OutputPluginGet : String;    

    procedure ChangeCurrentFile (sFilename : String);
		function IniPathnameGet : String;
		function IniDirGet  : String;

    function GetWinHandle : integer;

    function Msg (iMsg : cardinal) : cardinal;

    procedure Minimize;


    procedure SendKey (c : char);

//function AmpSendMsg(MsgConst : Word; var Value : integer) : integer;
function GetWinampInstallDirectory : string;
function getWinampExePathname : string;
function getPid : THandle;



    procedure SetWinampInstallDirectory (sDir : String);

	protected
		hwnd        : integer;  // Handle of main window
    hwndEQ      : integer;  // Equalizer window handle
    hwndBrowser : integer;  // Minibrowser
    hwndPE      : integer;  // Playlist Editor

		procedure SendCommand (iCmd : integer);
		procedure SendUser (lParam : integer);
//    procedure SendKey (wChar : integer);
    function  getInt (iMsg : integer) : integer;
    function  getInt_Ex (iMsg, iParam : integer) : integer;
    procedure setInt (iMsg, iValue : integer);
    function  getStr(MsgConst, Value : Integer): String;
    function  getPtr(MsgConst, Value : Integer): Pointer;
		function  FormatMinSec(iSecs : integer) : String;
    procedure EqParmSet (pos, value : integer);

    function  GetCurrentTrackTitle : String;
    function  GetCurrentTrackTitle_old : String;
  end;


const
	WINAMP_STATUS_PLAYING = 1;
	WINAMP_STATUS_STOPPED = 0;
	WINAMP_STATUS_PAUSED  = 3;

  WM_WA_IPC = WM_USER;

//--------------------------------------------------------------------

implementation

//--------------------------------------------------------------------

// Winamp's 'restart' command

procedure TWinamp.Restart;
begin
	SendCommand (IPC_RESTARTWINAMP);
end;

procedure TWinamp.SetWinampInstallDirectory (sDir : String);
begin
  sInstallDir := sDir;

  if RightStr (sInstallDir, 1) <> '\' then
    sInstallDir := sInstallDir + '\';
end;

//----------------------------------------------------------------------------------

// Start winamp
//
// Returns False if winamp is not running now
// Returns True if winamp is running now (either just launched or was already running)

function TWinAmp.Start : Boolean;
var
//  sExeFileName : String;
  sExePathname, sArgs : String;
//  tmp: PChar;
//  res: LPTSTR;
  iCr : integer;
begin
  iErrorCode := 0;
  Result := True;

  //
  // If winamp is already running, no need for a start
  //
	if hwnd <> 0 then
  begin
    iErrorCode := 100;
  	Exit;
  end;

{
  // Method #1
  // FindExecutable() needs an existing mp3 file
  // so we cannot use it because we don't know where to find one...
//var
//  tmp: PChar;
//  res: LPTSTR;

  tmp := StrAlloc(255);
  res := StrAlloc(255);

  if FindExecutable('C:\xxx.mp3', tmp, res) > 32 then
  begin
  	sExePathname := String (res);	// with path i.e. 'C:\Program Files\Winamp\Winamp.exe'
    sExeFileName := ExtractFileName(res); // without path i.e. 'Winamp.exe'
  end;

  StrDispose(tmp);
  StrDispose(res);
}

//	sExePathname := WhereIsWinamp;
//	sExePathname := GetAmpExePath;
  sExePathname := GetWinampExePathname;

  if sExePathname = '' then
  begin
    iErrorCode := 200;
    Result := False;
  	Exit;
  end;

//	ShellExecute (hwnd,'open',  'none.mp3', nil,  nil, SW_SHOWNORMAL);
//  WinExec ('winmp.exe', SW_SHOWNORMAL);

  // WinExec needs quotes if pathname contains spaces
  // "h:\program files\winamp\winamp.exe /CLASS 1234" => incorrect
  // h:\program files\winamp\winamp.exe /CLASS 1234 => incorrect
  // "h:\program files\winamp\winamp.exe" /CLASS 1234 => correct
  sExePathname := '"' + sExePathname + '"';

  sArgs := '';
  if sClass <> '' then
    if sClass <> 'Winamp v1.x' then
    begin
//      sExePathname := sExePathname + ' /CLASS ' + sClass;
      sArgs := ' /CLASS ' + sClass;
    end;

  //iCr := WinExec (PChar(sExePathName), SW_SHOWNORMAL);
  iCr := ShellExecute(0, 'Open', PChar(sExePathname), PChar(sArgs), nil, SW_SHOWDEFAULT);

  // Success : 33

  if iCr <= 31 then
  begin
    iErrorCode := iCr;
    // Error
    Result := False;
    Exit;
  end;

  WaitForWinampToStart;

  Init;
end;

//----------------------------------------------------------------------------------

procedure TWinAmp.Quit;
begin
	if hwnd = 0 then
  	Exit;

	PostMessage (hwnd, WM_CLOSE , 0 ,0);
end;

//--------------------------------------------------------------------

// Private
// Envoi d'une commande à WinAmp

procedure TWinAmp.SendCommand (iCmd : integer);
begin
	if hwnd <> 0 then
	  SendMessage(hwnd, WM_COMMAND,wParam(iCmd),0);
end;

procedure TWinAmp.SendUser (lParam : integer);
begin
	if hwnd <> 0 then
		SendMessage(hwnd,WM_USER,0,lParam);
end;

function TWinAmp.getInt (iMsg : integer) : integer;
begin
	if hwnd <> 0 then
		Result := SendMessage(hwnd,WM_USER,0,lParam(iMsg))
  else
    result := 0;
end;

function TWinAmp.getInt_Ex (iMsg, iParam : integer) : integer;
begin
	if hwnd <> 0 then
		Result := SendMessage(hwnd,WM_USER,wParam(iParam),lParam(iMsg))
  else
    result := 0;
end;

procedure TWinAmp.setInt (iMsg, iValue : integer);
begin
	if hwnd <> 0 then
  	SendMessage(hwnd,WM_USER,wParam(iValue),lParam(iMsg));
end;

function TWinAmp.getPtr(MsgConst, Value : Integer): Pointer;
var
 i : integer;
 ptr : Pointer;
begin
 i := Sendmessage(hwnd, WM_USER, wParam(Value), lParam(MsgConst));
 ptr := Pointer(i);
 Result := ptr;
end;

function TWinAmp.getPid : THandle;
var
  hPid : THandle;
begin
  Result := 0;
  
  if hWnd = 0 then
    Exit;

  GetWindowThreadProcessId(hwnd, hPid);
  result := hPid;
end;

// Dans un plug-in, getPtr suffit
// Ici, on est dans un process différent et l'adresse retournée
// n'est pas dans le même espace d'adressage
// son utilisation directe génère une violation mémoire
// Il existe des fonctions pour lire l'espace d'adressage d'autres process
// (sous réserve des droits correspondants)
// C'est ce que fait cette fonction.

function TWinAmp.getStr(MsgConst, Value : Integer): String;
var
  ptr : Pointer;
  hPid : THandle;
  lpWinamp : THandle;
  bCR : LongBool;
  Buffer : PChar;
  dwBufferSize : DWord;
  dwBytesRead : DWord;
begin
  result := '';

  ptr := getPtr(MsgConst, Value);
  if ptr = nil then
    Exit;

  // ptr is a pointer within winamp process adresses

  // Get ID from hWnd
  GetWindowThreadProcessId(hwnd, hPid) ;
  if hpid = 0 then   // Could not find PID (?)
  begin
    Exit;
  end;

//  hPid := 2008;
  //hPid:=2516;

  lpWinamp := OpenProcess(PROCESS_VM_READ, FALSE, hPid);
  if lpwinamp = 0 then
  begin
    Exit;
  end;

  dwBufferSize := 260;
  //setLength (buffer, 260);
  Buffer := StrAlloc(260);
  bCr := ReadProcessMemory(lpWinamp, ptr, Buffer, dwBufferSize, dwBytesRead) ;

  if bCR then // Success
  begin
    result := strPas(Buffer);
  end;

  CloseHandle(lpWinamp);
  strDispose (Buffer);
end;

procedure TWinamp.SendKey(c : char);
begin
	if hwnd <> 0 then
  begin

		//SendMessage(hwnd,WM_CHAR,VkKeyScan(c),0);
//PostKeyExHWND(hwndPE, VkKeyScan('R'), [ssShift, ssCtrl], false);
{
    PostKeyExHWND(hwndPE, VkKeyScan('R'), [ssShift, ssCtrl], false);
//    PostKeyExHWND(hwnd, VkKeyScan('L'), [], false);
    SendMessage(hwnd,WM_CHAR,VkKeyScan('L'),0);
}
  end;
end;

//--------------------------------------------------------------------

constructor TWinAmp.Create(sClassParm : String);
begin
//	inherited;
  sClass := sClassParm;
	Init;
end;

//--------------------------------------------------------------------

function TWinamp.RatingGet : integer;
begin
  result := getInt(IPC_GETRATING);
end;

procedure TWinAmp.Ratingset (iRating : integer);
begin
  setInt (IPC_SETRATING, iRating);
end;

procedure TWinAmp.VideoFullScreen;
var
//  x,y,iWidth,iHeight : integer;
//  hand2:THandle;
  bCode, bAlt : Byte;
//  lParam: LongInt;
begin
//  SendKey

  bCode := $D; //VK_RETURN;
  bAlt := $12; // VK_MENU (ALT)

//  hand2:=getactivewindow;
  SetForegroundWindow(Visu.hwndVideo);
  keybd_event(bAlt, 0, 0, 0);  // ALT
  keybd_event(bCode, 0, 0, 0);
  keybd_event(bCode, 0, KEYEVENTF_KEYUP, 0);
  keybd_event(bAlt, 0, KEYEVENTF_KEYUP, 0);
end;

procedure TWinAmp.BringToFront;
//var
//  hand2:THandle;
begin
//  hand2:=getactivewindow;
  SetForegroundWindow(hwnd);
end;


//--------------------------------------------------------------------
// VIS
//--------------------------------------------------------------------

procedure TWinAmp.Visu_init;
var
  iRunning : integer;
begin
  // Get VIS window handle
  //hwndVideo   := FindWindow ('BaseWindow_RootWnd', 'Video');
  visu.hwndVideo := getInt_Ex ( IPC_GETWND, IPC_GETWND_VIDEO);

  // Determine if it is currently running
  {
  // Not working
  if visu.hwndVideo <> 0 then
    visu.bVisible  := getInt_Ex ( IPC_ISWNDVISIBLE, IPC_GETWND_VIDEO)
  else
    visu.bVisible := false;
  }

  iRunning := getInt(IPC_ISVISRUNNING);
  visu.bRunning := (iRunning <> 0);
end;

//--------------------------------------------------------------------

procedure TWinAmp.WaitForWinampToStart;
begin
  if sClass = '' then
    sClass := 'Winamp v1.x';

  repeat
    Sleep (100);  // en ms
    hwnd := FindWindow(PChar(sClass), Nil);
  until hwnd <> 0;
end;

procedure TWinAmp.Init;
begin
  if sClass = '' then
    sClass := 'Winamp v1.x';

  hwnd := FindWindow(PChar(sClass), Nil);
  if hwnd = 0 then
  	Exit;
  // Parms : (class name, window name)

  {

  hwndPE      :=findWindow('Winamp PE',nil);     // Classic skin
  If hwndPE = 0 Then
    hwndPE = FindWindow("BaseWindow_RootWnd", "Playlist Editor")  // Modern skin

  hwndEQ      :=findWindow('Winamp EQ',nil);     // EQ = Equalizer
  hwndBrowser :=findWindow('Winamp MB',nil);     // MB = Mini browser
  }

  // Playlist Editor (PE)
  {
    // non working methods
    hwndPE := FindWindow('Winamp PE',nil);     // Classic skin
    hwndPE := SendMessage(hwnd,WM_COMMAND,IPC_GETWND_PE,IPC_GETWND);
    hwndPE := FindWindow('BaseWindow_RootWnd', 'Playlist Editor');  // Modern skin
  }
  hwndPE := getInt_Ex ( IPC_GETWND, IPC_GETWND_PE);

  // Mini Browser (MB)
  hwndBrowser := getInt_Ex ( IPC_GETWND, IPC_GETWND_MB);

  // Equalizer (EQ)
  hwndEQ := getInt_Ex ( IPC_GETWND, IPC_GETWND_EQ);

  // Video (VIDEO)
  Visu_Init;

  iRawVersion := getInt(IPC_GETVERSION);

  // Version 5.XX
  // Exemple :
  // 5005 ==> 5.05
  // 5009 ==> 5.5092
  // 5009 ==> 5.5093
  // 5020 ==> 5.2
  if iRawVersion >= $5000 then
  begin
    sVersion := '5.';
   	sVersion := sVersion + Format('%2.2x', [iRawVersion - $5000]);
  end
  else
    // Version 2.XX
    // $2707 => V 2.77
    // $2800 => V 2.8
    if iRawVersion >= $2000 then
    begin
    	case iRawVersion of
      	$2707 : sVersion := '2.77';
        $2800 : sVersion := '2.8';
        else    sVersion := '2';
      end;
    end;

  // Here, might be 1.X or 2.X
end;

//--------------------------------------------------------------------

function TWinAmp.SkinGet : String;
begin
  result := getStr (IPC_GETSKIN,0);
end;

function TWinAmp.OutputPluginGet : String;
begin
  result := getStr (IPC_GETOUTPUTPLUGIN,0);
end;


function TWinAmp.IniPathnameGet : String;
begin
  result := getStr (IPC_GETINIFILE,0);
end;

function TWinAmp.IniDirGet : String;
begin
  result := getStr (IPC_GETINIDIRECTORY,0);
end;

//--------------------------------------------------------------------
//                    EQUALIZER MANAGEMENT
//--------------------------------------------------------------------

// Get All Equalizer Values
//
//** Value      Meaning
//** ------------------
//** 0-9        The 10 bands of EQ data. 0-63 (+20db - -20db)
//** 10         The preamp value. 0-63 (+20db - -20db)
//** 11         Enabled. zero if disabled, nonzero if enabled.
//** 12         Autoload. zero if disabled, nonzero if enabled.

procedure TWinAmp.EqDataGet;
var
	pos : integer;
begin
	if hwnd = 0 then
  	Exit;

	for pos := 0 to 9 do
//		Eq.Band[pos] := SendMessage(hwnd,WM_USER,wParam(pos),IPC_GETEQDATA);  // The 10 bands of EQ data. 0-63 (+20db - -20db)
		Eq.Band[pos] := getInt_Ex(IPC_GETEQDATA,pos);  // The 10 bands of EQ data. 0-63 (+20db - -20db)

	Eq.PreAmp   := SendMessage(hwnd,WM_USER,10,IPC_GETEQDATA);         // PreAmp value (+20db - -20db)
	Eq.Enabled  := (SendMessage(hwnd,WM_USER,11,IPC_GETEQDATA) <> 0);  // Status (ON / OFF)
	Eq.AutoLoad := (SendMessage(hwnd,WM_USER,12,IPC_GETEQDATA) <> 0);  // AutoLoad (ON / OFF)

end;

// Set an equalizer parameter

procedure TWinAmp.EqParmSet (pos, value : integer);
begin
	SendMessage(hwnd,WM_USER, wparam(pos),IPC_GETEQDATA);
	SendMessage(hwnd,WM_USER, wparam(value),IPC_SETEQDATA);
end;

// Set Equalizer status (ON / OFF)

procedure TWinAmp.EqStatusSet (bValue : Boolean);
begin
	EqParmSet (11, Ord(bValue));
end;

// Set All Equalizer values

procedure TWinAmp.EqDataSet;
var
	pos : integer;
begin

	for pos := 0 to 9 do
  	EqParmSet (pos, Eq.Band[pos]);

  EqParmSet (10, Eq.PreAmp);
  EqParmSet (11, Ord(Eq.Enabled));
  EqParmSet (12, Ord(Eq.AutoLoad));
end;

//--------------------------------------------------------------------

// Get repeat status

function TWinAmp.RepeatGet : Boolean;
var
	res : integer;
begin
	Result := False;

	if hwnd = 0 then
  	Exit;

	res := getInt(IPC_GETREPEAT);
  Result := (res = 1);
end;

// Set repeat status

procedure TWinAmp.RepeatSet (bNewState : Boolean);
begin
  setInt (IPC_SETREPEAT, Ord(bNewState));
end;

//--------------------------------------------------------------------

// Get shuffle status

function TWinAmp.ShuffleGet : Boolean;
var
	res : integer;
begin
	Result := False;

	if hwnd = 0 then
  	Exit;

	res := getInt(IPC_GETSHUFFLE);
  Result := (res = 1);
end;

// Set shuffle status

procedure TWinAmp.ShuffleSet (bNewState : Boolean);
begin
  setInt (IPC_SETSHUFFLE, Ord(bNewState));
end;

//--------------------------------------------------------------------

{
function TWinAmp.RandomGet : Boolean;
var
	res : integer;
begin
	if hwnd = 0 then
  	Exit;

	res := SendMessage(hwnd,WM_USER,0,IPC_GETRANDOM);
  Result := (res = 1);
end;

procedure TWinAmp.RandomSet (bNewState : Boolean);
begin
	if hwnd = 0 then
  	Exit;

	SendMessage(hwnd,WM_USER,Ord(bNewState),IPC_SETRANDOM);
end;
}

//--------------------------------------------------------------------

// Set volume level

procedure TWinamp.VolumeSet (iLevel : integer);
begin
  setInt (IPC_SETVOLUME, iLevel);
end;

// Get volume level

function TWinamp.VolumeGet : integer;
begin
  Result := getInt_Ex (IPC_SETVOLUME, -666);
end;

// Set volume up

procedure TWinamp.VolumeUp;
begin
	SendCommand(WINAMP_VOLUMEUP);
end;

// Set volume down

procedure TWinamp.VolumeDown;
begin
	SendCommand(WINAMP_VOLUMEDOWN);
end;

//--------------------------------------------------------------------

procedure TWinamp.FForward;
begin
	SendCommand(WINAMP_FFWD5S);
end;

procedure TWinamp.Rewind;
begin
	SendCommand(WINAMP_REW5S);
end;

//--------------------------------------------------------------------

//
// Not working
// Memory fault because Winamp cannot read caller's local address
//

procedure TWinamp.ChangeCurrentFile (sFilename : String);
var
  i, iLen : integer;
  buffer: PChar;
begin
  if hwnd = 0 then
  	Exit;
	iLen := Length(sFilename);
	GetMem(buffer, iLen + 1);

  for i := 0 to iLen-1 do
  	buffer[i] := sFilename[i+1];
  buffer[iLen] := #0;

  _wParam := wParam (Buffer);

	SendMessage(hwnd,WM_USER,_wParam,IPC_CHANGECURRENTFILE);

	SendMessage(hwnd,WM_USER,0,IPC_UPDTITLE);

//  FreeMem (buffer);
end;

//=========================================================
// PLAYLIST MANAGEMENT
//=========================================================

// Positionne à un des éléments de la play list
// si iPos = -999 , à positionner au hasard
// iPos doit etre entre 0 et wa.PlayListLengthGet-1

procedure TWinAmp.PlayListPosSet (iPos : integer);
begin
  if iPos = -999 then
  begin
    Randomize;
    iPos := Random (PlayListLengthGet);
    //writeln(PlayListLengthGet);
    //writeln (inttostr(ipos));
  end;

  setInt (IPC_SETPLAYLISTPOS, iPos);
end;

procedure TWinAmp.JumpTotime (iMilliSec : integer);
begin
  setInt (IPC_JUMPTOTIME, iMilliSec);
end;

//--------------------------------------------------------------------

// Reads current playlist position (0 = first, n-1 = last)
// Returns -1 if fails

function TWinAmp.PlayListPosGet : integer;
begin
	Result := -1;

	if hwnd = 0 then
  	Exit;

	plPosition := getInt(IPC_GETLISTPOS);
  Result := plPosition;
end;

// Reads playlist length (n)
// Returns -1 if fails

function TWinAmp.PlayListLengthGet : integer;
begin
	Result := -1;

	if hwnd = 0 then
  	Exit;

	plLength := getInt(IPC_GETLISTLENGTH);
  Result :=  plLength;
end;

//--------------------------------------------------------------------

// Add a file to end of play list
// (like drag'n' drop')
// Note: Must provide full pathname
// If sfilename is a m3u file, will add the content, not the file itself

procedure TWinAmp.PlayListAdd(sFilename : String);
const
	IPC_PLAYFILE = 100;
var
	aCopyData: TCopyDataStruct;
begin
	if hwnd = 0 then
  	Exit;

  with aCopyData do
  begin
    dwData := IPC_PLAYFILE;
    cbData := StrLen(PChar(sFilename)) + 1;
    lpData := PChar(sFilename)
  end;

	SendMessage(hWnd, WM_COPYDATA, 0, Longint(@aCopyData));
end;

//--------------------------------------------------------------------

{
// Récupère le nombre d'éléments dans la play list

procedure TWinAmp.PlayListRead;
begin
	if hwnd = 0 then
  	Exit;

	plLength := PlayListLengthGet;

  SetLength (pl, plLength);

  PlayListPosGet;
end;
}

//--------------------------------------------------------------------

// Clears playlist

procedure TWinAmp.PlayListClear;
begin
  setInt (IPC_DELETE, 0);
end;

//=========================================================
// CURRENT STATUS MANAGEMENT
//=========================================================

//
// Returns :
// WINAMP_STATUS_XXX
//

function TWinAmp.GetCurrentStatus : integer;
var
	res : integer;
begin
	if hwnd = 0 then
  begin
  	Result := -1;
  	Exit;
  end;

	res := getInt(IPC_ISPLAYING);
  Result := res;
end;

procedure TWinAmp.AlwaysOnTopToggle;
begin
  SendCommand (WINAMP_OPTIONS_AOT);
end;

// Next track

procedure TWinAmp.Next;
begin
  SendCommand (WINAMP_NEXT);
end;

// Previous track

procedure TWinAmp.Prev;
begin
  SendCommand (WINAMP_PREV);
end;

// Display 'About' box

procedure TWinAmp.ShowAbout;
begin
  SendCommand (WINAMP_HELP_ABOUT);
end;

// Display 'Media Library'

procedure TWinAmp.ShowMediaLibrary;
begin
  SendCommand (WINAMP_MEDIALIB_SHOW);
end;

// Display 'Prefs' box

procedure TWinAmp.ShowPrefs;
begin
  SendCommand (WINAMP_OPTIONS_PREFS);
end;

// Display 'Open file' box

procedure TWinAmp.ShowOpenFile;
begin
  SendCommand (WINAMP_FILE_PLAY);
end;

// Note: WINAMP_PLAYLAST does not works if Shuffle mode set to on

procedure TWinAmp.PlayLast;
begin
	if ShuffleGet then
  begin
  	ShuffleSet (FALSE);
	  SendCommand (WINAMP_PLAYLAST);
  	ShuffleSet (TRUE);
  end
  else
	  SendCommand (WINAMP_PLAYLAST);
end;

// Note: WINAMP_PLAYFIRST does not works if Shuffle mode set to on
// All this can also be achieved with : SendUser (IPC_STARTPLAY);

procedure TWinAmp.PlayFirst;
begin
	if ShuffleGet then
  begin
  	ShuffleSet (FALSE);
	  SendCommand (WINAMP_PLAYFIRST);
  	ShuffleSet (TRUE);
  end
  else
	  SendCommand (WINAMP_PLAYFIRST);
end;

//--------------------------------------------------------------------------------------------------

// Show/Hide equalizer
// Note: does not work with modern skins

procedure TWinAmp.EqShowHide;
begin
  SendCommand (WINAMP_OPTIONS_EQ);
end;

//--------------------------------------------------------------------------------------------------

// Show/Hide playlist

procedure TWinAmp.PlayListShowHide;
begin
  SendCommand (WINAMP_OPTIONS_PLEDIT);
end;

// Show/Hide main window

procedure TWinAmp.MainWindowShowHide;
begin
  SendCommand (WINAMP_MAINWINTOGGLE);
end;

// Plays current song from the beginning

procedure TWinAmp.Play;
begin
  SendCommand (WINAMP_PLAY);
end;

// Pause (on/off)

procedure TWinAmp.PauseToggle;
begin
  SendCommand (WINAMP_PAUSE);
end;

procedure TWinamp.PauseSet (bOnOff : bool);
var
  bPaused : bool;
begin
  // Etat courant
  bPaused := ( Getcurrentstatus =  WINAMP_STATUS_PAUSED );

  if bPaused <> bOnOff then
    PauseToggle;

end;

// Stop Playing (without fade)

procedure TWinAmp.Stop;
begin
  SendCommand (WINAMP_STOP);
end;

// Stop laying with fade

procedure TWinAmp.Fade;
begin
  SendCommand (WINAMP_FADE);
end;

// Stop after this track

procedure TWinAmp.StopAfter;
begin
  SendCommand (WINAMP_STOPAFTER);
end;

// Quit after playing
// CLAmp remains alive while Winamp is playing (Status 1)

procedure TWinAmp.QuitAfter;
begin
  StopAfter;  // To avoid jumping to next track when current is completed

  while GetCurrentStatus = 1 do
  begin
    Sleep(10);  // Sleep(milli secs)
  end;

  Quit;
end;

//--------------------------------------------------------------------

function TWinAmp.GetWinHandle;
begin
	Result := hwnd;
end;

//--------------------------------------------------------------------

//
//  Note: not working - pointer cannot be read from an external app
//


//--------------------------------------------------------------------

// Method used starting v11 : Query Track title from playlist
function
TWinAmp.GetCurrentTrackTitle : String;
var
  i : Integer;
  sStr : String;
begin
  i := PlayListPosGet;
  sStr := getStr (IPC_GETPLAYLISTTITLE,i);
  // notice: windows charset !!
  Result := sStr;
end;

// Method used from v1 to v 10 : analyze window's title
// Problems with this method :
// - when winamp just launched, title is just "winamp v X.XX"
//   so it is only reliable when track is being played
// - subject to problem is winamp changes window's title (not reliable)
// - Quand il n'y a pas de fichier courant (play list vide),
//   la fenêtre garde comme titre le dernier morceau joué.
function
TWinAmp.GetCurrentTrackTitle_old : String;
var
	lpString  : pAnsiChar;
  nMaxCount : integer;
	sWindowText : String;
  sTitle   : String;
  i : Integer;
  sHeader  : String;
begin
  // Windows's name
  // --------------
  // Possible patterns :
  //
  // <X>.<Sp><Title><Sp>-<Sp>Winamp
  // <X>.<Sp><Title><Sp>-<Sp>Winamp<Sp>[Stopped]
  // or
  // Winamp 5.08
  // Winamp 5.093
  // (just after launch)

  nMaxCount := 1024;
  GetMem(lpString, nMaxCount);
  GetWindowText (hwnd, lpString, nMaxCount);
  sWindowText := StrPas(lpString);
  FreeMem (lpString);

  if pos('-', sWindowText) = 0 then
  begin
    sTitle := '';
  end
  else
  begin
    sTitle := sWindowText;

    // Strip text after title
    i := Pos(' - Winamp', sTitle);
    if i <> 0 Then
      sTitle := LeftStr(sTitle, i-1);

    // Skip text before title
    PlayListPosGet;
    sHeader := IntToStr (plPosition + 1) + '.' + ' ';
    if (Pos (sHeader, sTitle) = 1) then
      sTitle := RightStr (sTitle, Length (sTitle) - Length (sHeader));

    // notice: windows charset !!
  end;

  Result := sTitle;
end;

//--------------------------------------------------------------------

// Infos sur le fichier actuellement ouvert
// (Reste dispo même si STOP)


procedure TWinAmp.GetCurrentFileInfos;
const
	SAMPLE_RATE = 0;
  BITRATE = 1;
  CHANNELS = 2;
var
  i : Integer;
begin
	if hwnd = 0 then
  	Exit;

  CurrentFile.sLength     := '0:00';
  CurrentFile.sTitle      := '';
  CurrentFile.iSampleRate := 0;
  CurrentFile.iBitRate    := 0;
  CurrentFile.iChannels   := 0;

  i := getInt(IPC_GETLISTPOS);
  CurrentFile.sPathname := getStr (IPC_GETPLAYLISTFILE,i);

  // 1 = playing , 3 = pause
  if not ((Getcurrentstatus = 1) or (Getcurrentstatus =  WINAMP_STATUS_PAUSED)) then
  begin
    Exit;
  end;

	CurrentFile.iLength     := SendMessage(hwnd, WM_USER, 1,  IPC_GETOUTPUTTIME);
  if (CurrentFile.iLength <> -1) then	// -1 = No current file or reading a stream
  begin
		CurrentFile.sLength     := FormatMinSec(CurrentFile.iLength);
  end;

  CurrentFile.sTitle := GetCurrentTrackTitle;

  //
  // Informations on current file
  //

  CurrentFile.iSampleRate := SendMessage(hwnd, WM_USER, SAMPLE_RATE, IPC_GETINFO);
  CurrentFile.iBitRate    := SendMessage(hwnd, WM_USER, BITRATE,     IPC_GETINFO);
  CurrentFile.iChannels   := SendMessage(hwnd, WM_USER, CHANNELS,    IPC_GETINFO);

end;

//--------------------------------------------------------------------

// Gets current reading position
//
// Sets sPosition property to XX:XX (min:sec)
// or '' if fails

procedure TWinAmp.GetCurrentPosition;
//var
//	t : Cardinal;
begin
	if hwnd = 0 then
  	Exit;

  sPosition := '';

  iPosition := getInt( IPC_GETOUTPUTTIME );
  iPosition := iPosition div 1000;

  // -1 if stopped

  if iPosition < 0 then
  	Exit;

  sPosition := FormatMinSec(iPosition);
end;

//--------------------------------------------------------------------

// Private

// Time format
//
// Input
// iSecs ... # secs
//
// Output
// X:YY

function TWinAmp.FormatMinSec(iSecs : integer) : String;
var
  imin, isec : Integer;
  s : String;
begin
  imin := iSecs div 60;
  isec := iSecs mod 60;

  s := s + IntToStr(iMin);
  s := s + ':';
  if iSec < 10 Then
  	s := s + '0';
  s := s + IntToStr(iSec);

  Result := s;
end;

//--------------------------------------------------------------------

function TWinAmp.Msg (iMsg : cardinal) : cardinal;
begin
	Result := 0;

	SendCommand (iMsg);
end;

//--------------------------------------------------------------------

procedure TWinAmp.Minimize;
begin
	SendCommand (WINAMP_MINIMIZE);
end;

procedure TWinAmp.PlayCD;
begin
	SendCommand (WINAMP_PLAYCD1);
end;

procedure TWinAmp.VisuExec (bStatus : boolean);
begin
  if bStatus <> Visu.bRunning then
  begin
  	SendCommand (WINAMP_VISU_EXEC);
    Visu_Init;
  end;
end;

//--------------------------------------------------------------------

// Open the "Jump to file" window

procedure TWinAmp.JumpToFileWindow_Open;
begin
	SendCommand (WINAMP_JUMP_TO_FILE);
end;

//--------------------------------------------------------------------

procedure TWinAmp.BookmarkFile(sFilename : String);
var
	aCopyData: TCopyDataStruct;
begin
	if hwnd = 0 then
  	Exit;

  with aCopyData do
  begin
    dwData := IPC_ADDBOOKMARK;
    cbData := StrLen(PChar(sFilename)) + 1;
    lpData := PChar(sFilename)
  end;

	SendMessage(hWnd, WM_COPYDATA, 0, Longint(@aCopyData));
end;

procedure TWinAmp.BookmarkCurrent;
begin
  SendCommand (WINAMP_BOOKMARK_CURRENT);
end;

procedure TWinAmp.BookmarksEdit;
begin
  SendCommand (WINAMP_BOOKMARKS_EDIT);
end;

//--------------------------------------------------------------------

{
function TWinAmp.AmpSendMsg(MsgConst : Word; var Value : integer) : integer;
begin
  result := Sendmessage(hwnd,WM_USER,Value,MsgConst);
end;
}
function TWinAmp.GetWinampInstallDirectory : string;
begin
  if sInstallDir = '' then
    sInstallDir := extractfilepath(getampexePath);

  Result := sInstallDir;
end;

function TWinAmp.GetWinampExePathname : string;
begin
  if sInstallDir = '' then
    Result := getampexePath
  else
    Result := sInstallDir + 'winamp.exe';
end;

//--------------------------------------------------------------------------

//
// Return value :
//  0 .... OK
// -1 .... Can't find winamp install dir
// -2 .... Can't delete <install_dir>\winamp.m3u
// -3 .... Winamp did not generate winamp.m3u
// -4 .... Cannot write requested file

function TWinAmp.PlayListSaveToFile(FileName:string) : integer;
 Var
//  I : Integer;
  fn : string;
  winampdir : string;
begin

  result := 0;

  winampdir := GetWinampInstallDirectory;
  if winampdir = '' then
  begin
    result := -1;
    Exit;
  end;

  // remove an old winamp.m3u if any
  fn := winampdir+'Winamp.M3U';
  if FileExists(fn) then
  begin
    DeleteFile(fn);
    if FileExists(fn) then
    begin
      result := -2;
      Exit;
    end;
  end;

  // Generates winamp.m3u in winamp directory
  SendUser (IPC_WRITEPLAYLIST);

  // copy it to requested file
  if not FileExists(fn) then
  begin
    result := -3;
    Exit;
  end
  else
  begin
    if not copyfile(PChar(fn),PChar(FileName),True) then
    begin
      result := -4;
      Exit;
    end;

    DeleteFile(fn);
  end;
end;

//----------------------------------------------------------------------------

end.
