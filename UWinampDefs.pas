unit UWinampDefs;

interface

uses
  windows;

const
	WINAMP_SHIFT = 100;
  WINAMP_CTRL  = 110;

  //--------------------------------------------------------------------


const

  // Close Winamp 40001 

	WINAMP_OPTIONS_PREFS  = 40012;  // Toggle preferences screen
	WINAMP_OPTIONS_AOT    = 40019; // toggles always on top (for main window only, not playlist)
	// 40022 - Toggle Repeat mode [Use IPC_SETREPEAT instead]
	// 40023 - Toggle Shuffle mode [Use IPC_GETSHUFFLE instead]
	WINAMP_FILE_PLAY      = 40029;   // Open File dialog

	WINAMP_OPTIONS_EQ     = 40036; // toggles the EQ window
  // Set time display mode to 'elapsed' 40037
  // Set time display mode to 'remaining' 40038
	WINAMP_OPTIONS_PLEDIT = 40040; // toggles the playlist window

	WINAMP_HELP_ABOUT     = 40041; // pops up the about box :)
  // 40339 - same
  
	WINAMP_CONTEXT        = 40043; // pops up right click menu and waits for answer before returning

  // 5 main buttons, without shift or ctrl
	WINAMP_BTN_1          = 40044;
	WINAMP_BTN_2          = 40045;
	WINAMP_BTN_3          = 40046;
	WINAMP_BTN_4          = 40047;
	WINAMP_BTN_5          = 40048;

	WINAMP_VOLUMEUP       = 40058;	// Up 1%
	WINAMP_VOLUMEDOWN     = 40059;  // Down 1%

	WINAMP_FFWD5S         = 40060; // fast forwards 5 seconds // right
	WINAMP_REW5S          = 40061; // rewinds 5 seconds // left

  // Toggle Windowshade 40064
  // Fast-rewind 5 seconds 40144
  {
 Amp_Command_BUTTON1_SHIFT            =    40145;
 Amp_Command_BUTTON3_SHIFT            =    40146;
 Amp_Command_BUTTON4_SHIFT            =    40147;
 Amp_Command_BUTTON5_SHIFT            =    40148;
 Amp_Command_BUTTON1_CTRL             =    40154;
 Amp_Command_BUTTON2_CTRL             =    40155;
 Amp_Command_BUTTON3_CTRL             =    40156;
 Amp_Command_BUTTON4_CTRL             =    40157;
 Amp_Command_BUTTON5_CTRL             =    40158;
  }

  // Fast-forward 5 seconds 40148 (= Shift + Button 5)
  // Start of playlist 40154 (= Ctrl + button 1)
  // Open URL dialog 40155 (= Crtl + button 2)
  // Stop after current track 40157 (= Ctrl + Button 4)
  // Go to end of playlist 40158 (= Ctrl + Button 5)
  // Opens load presets dialog 40172
  // Opens auto-load presets dialog 40173
  // Load default preset 40174
  // Opens save preset dialog 40175
  // Opens auto-load save preset 40176
  // Opens delete preset dialog 40178
  // Opens delete an auto load preset dialog 40180
  // Toggle easymove 40186
  // Open file info box 40188
  // Toggle title Autoscrolling 40189
  // Open visualization options 40190
  // Open visualization plug-in options 40191
  WINAMP_VISU_EXEC = 40192;  // Execute current visualization plug-in
  // Open jump to time dialog 40193
  // Open jump to file dialog 40194
  WINAMP_JUMP_TO_FILE = 40194;
  // Moves back 10 tracks in playlist 40197
  // Open skin selector 40219
  // Configure current visualization plug-in 40221
  // Load a preset from EQ 40253
  // Save a preset to EQF 40254

	WINAMP_MAINWINTOGGLE  = 40258; // Toggle main window visible

  // Toggle Playlist Windowshade 40266
  // Reload the current skin 40291
  // Toggle minibrowser 40298
  WINAMP_BOOKMARKS_EDIT   = 40320;// Show the edit bookmarks 40320
  WINAMP_BOOKMARK_CURRENT = 40321;  // Adds current track as a bookmarks

  WINAMP_PLAYCD1        = 40323;	// Play CD
	WINAMP_MINIMIZE       = 40334; // Minimize Winamp

  // 40344 - 'Add media to library' pop up
  // 40347 -  Winamp.com online help
  // 40359 - 'Create playlist' pop up
  // 40360 - 'Import playlist' pop up
  // 40361 - 'Export playlist' pop up

  WINAMP_MEDIALIB_SHOW  = 40371;	// Media Library - Show
  // 40372 - Media lib - Preferences
  // 40374 - Media lib - Playlists - Imported playlists
  // 40376 - Media Lib - Local media
  // 40377 - Media lib - Playlists
  // 40378 - same
  // 40379 - same
  // 40385 - same

  // 40394 - Preferences - Winamp pro

  // 40409 - (last tested)



const
	// -- Z --
	WINAMP_PREV      = WINAMP_BTN_1;
	WINAMP_PLAYFIRST = WINAMP_BTN_1 + WINAMP_CTRL;	// Go to top of play list
	// WINAMP_BTN_1 + WINAMP_SHIFT;	// Rewind 5 secs [Similar to WINAMP_REW5S]

	// -- X --
	WINAMP_PLAY      = WINAMP_BTN_2;
	// WINAMP_BTN_2 + WINAMP_SHIFT; // Open File window [Same as WINAMP_FILE_PLAY]
	// WINAMP_BTN_2 + WINAMP_CTRL; // Open URL window [New]

	// -- C --
	WINAMP_PAUSE     = WINAMP_BTN_3;

	// -- V --
	WINAMP_STOP      = WINAMP_BTN_4;
	WINAMP_FADE      = WINAMP_BTN_4 + WINAMP_SHIFT;
	WINAMP_STOPAFTER = WINAMP_BTN_4 + WINAMP_CTRL;

	// -- B --
	WINAMP_NEXT      = WINAMP_BTN_5;
	WINAMP_PLAYLAST    = WINAMP_BTN_5 + WINAMP_CTRL; // Go to end of playlist
	// WINAMP_BTN_5 + WINAMP_SHIFT; // Forward 5 secs [Similar to WINAMP_FFWD5S]

//------------------------------------------------------------

// Details to be found here :
// http://nunzioweb.com/daz/winamp/sdk/winamp/wa_ipc.h

  IPC_GETVERSION =   0;
  // Retrieves the version of Winamp running. Version will be 0x20yx for 2.yx.
  // This is a good way to determine if you did in fact find the right window, etc.

  IPC_PLAYFILE   = 100;
  // cds.dwData := IPC_PLAYFILE;
  // cds.lpData := PChar('file.mp3');
  // cds.cbData := strlen(cds.lpData) + 1; // include space for null char
  // SendMessage(hwnd_winamp, WM_COPYDATA, 0, LongInt(@cds));

  IPC_DELETE     = 101;  // CLEARS WINAMPs INTERNAL PLAYLIST
  IPC_STARTPLAY  = 102;  // Starts playback. A lot like hitting 'play' in Winamp, but not exactly the same

  IPC_CHDIR      = 103;
  // sent as a WM_COPYDATA, with IPC_CHDIR as the dwData, and the directory to change to
  // as the lpData.
  //
  // cds.dwData := IPC_CHDIR;
  // cds.lpData := PChar('c:\download');
  // cds.cbData := strlen(cds.lpData) + 1; // include space for null char
  // SendMessage(hwnd_winamp, WM_COPYDATA, 0, LongInt(@cds));

  IPC_ISPLAYING  = 104;  // Returns the status of playback.
                         // If 'ret' is 1, Winamp is playing.
                         // If 'ret' is 3, Winamp is paused. Otherwise, playback is stopped

	IPC_GETOUTPUTTIME  = 105;
  // If value is 0, returns the position in milliseconds of playback.
  // If value is 1, returns current track length in seconds. Returns -1 if not playing or if an error occurs

  IPC_JUMPTOTIME     = 106; // Seeks within the current track. The offset is specified in 'data', in milliseconds.
                            // (requires Winamp 1.60+)
                            // Returns -1 if not playing, 1 on eof, or 0 if successful

  IPC_GETMODULENAME  = 109;

  IPC_WRITEPLAYLIST  = 120; // Writes out the current playlist
                            // to Winampdir\winamp.m3u, and returns
                            // the current position in the playlist.
                            // (requires Winamp 1.666+)

  IPC_SETPLAYLISTPOS = 121; // Sets the playlist position to the position specified in tracks in 'data'.
                            // (requires Winamp 2.0+)

  IPC_SETVOLUME      = 122; // Sets the volume to 'data', which can be between 0 (silent) and 255 (maximum).
                            // (requires Winamp 2.0+)

  IPC_SETPANNING     = 123; // Sets the panning to 'data', which can be between 0 (all left) and 255 (all right).
                            // (requires Winamp 2.0+)
                            // SendMessage(hwnd_winamp,WM_USER,panning,IPC_SETPANNING);
                            // ** This now appears to work from -127 (left) to 127 (right)
                            // ** If you pass panning as -666 then it will return the current position.

	IPC_GETLISTLENGTH  = 124; // Returns length of the current playlist, in tracks.
                            // (requires Winamp 2.0+)

  IPC_GETLISTPOS     = 125; // Returns the position in the current playlist, in tracks (requires Winamp 2.05+).
                            // (requires Winamp 2.05+)

  IPC_GETINFO        = 126; // Retrieves info about the current playing track.
                            // Returns samplerate (i.e. 44100) if 'data' is set to 0,
                            // bitrate if 'data' is set to 1,
                            // and number of channels if 'data' is set to 2.
                            // (requires Winamp 2.05+)
  {

** int inf=SendMessage(hwnd_winamp,WM_WA_IPC,mode,IPC_GETINFO);
**
** IPC_GETINFO returns info about the current playing song. The value
** it returns depends on the value of 'mode'.
** Mode      Meaning
** ------------------
** 0         Samplerate (i.e. 44100)
** 1         Bitrate  (i.e. 128)
** 2         Channels (i.e. 2)
** 3 (5+)    Video LOWORD=w HIWORD=h
** 4 (5+)    > 65536, string (video description)
}

  IPC_GETEQDATA      = 127;
                            // (requires Winamp 2.05+)
{
** IPC_GETEQDATA queries the status of the EQ.
** The value returned depends on what 'pos' is set to:
** Value      Meaning
** ------------------
** 0-9        The 10 bands of EQ data. 0-63 (+20db - -20db)
** 10         The preamp value. 0-63 (+20db - -20db)
** 11         Enabled. zero if disabled, nonzero if enabled.
** 12         Autoload. zero if disabled, nonzero if enabled.
}

  IPC_SETEQDATA      = 128;
                            // (requires Winamp 2.05+)
{
** SendMessage(hwnd_winamp,WM_WA_IPC,pos,IPC_GETEQDATA);
** SendMessage(hwnd_winamp,WM_WA_IPC,value,IPC_SETEQDATA);
** IPC_SETEQDATA sets the value of the last position retrieved
** by IPC_GETEQDATA. This is pretty lame, and we should provide
** an extended version that lets you do a MAKELPARAM(pos,value).
** someday...

  new (2.92+):
    if the high byte is set to 0xDB, then the third byte specifies
    which band, and the bottom word specifies the value.
}


  IPC_ADDBOOKMARK    = 129; // Adds the specified file to the Winamp bookmark list
                            // (requires Winamp 2.4+)

  IPC_INSTALLPLUGIN  = 130; // not implemented, but if it was you could do a WM_COPYDATA with
                            // a path to a .wpz, and it would install it.
  IPC_RESTARTWINAMP  = 135; // (requires Winamp 2.2+)

//  IPC_SETSKIN = 200; // Plug ins only
  // Sets the current skin. 'value' points to a string that describes what skin to load,
  // which can either be a directory or a .zip file. If no directory name is specified,
  // the default Winamp skin directory is assumed.

  IPC_GETSKIN = 201;
  // Retrieves the current skin directory and/or name. 'ret' is a pointer to the Skin name (or NULL if error),
  // and if 'value' is non-NULL, it must point to a string 260 bytes long,
  // which will receive the pathname to where the skin bitmaps are stored (which can be either a skin directory,
  // or a temporary directory when zipped skins are used) (Requires Winamp 2.04+).

{IPC_EXECPLUG = 202 Selects and executes a visualization plug-in. 'data' points to a string which defines which plug-in to execute. The string can be in the following formats:

    vis_whatever.dll Executes the default module in vis_whatever.dll in your plug-ins directory.
    vis_whatever.dll,1 executes the second module in vis_whatever.dll
    C:\path\vis_whatever.dll,1 executes the second module in vis_whatever.dll in another directory
}
  IPC_GETPLAYLISTFILE  = 211;  // Retrieves pathname of current track
// (requires Winamp 2.04+, only usable from plug-ins (not external apps))
// char *name=SendMessage(hwnd_winamp,WM_WA_IPC,index,IPC_GETPLAYLISTFILE);
// IPC_GETPLAYLISTFILE gets the filename of the playlist entry [index].
// returns a pointer to it. returns NULL on error.

  IPC_GETPLAYLISTTITLE = 212; // Retrieves (and returns a pointer in 'ret') a string that contains the title of a playlist entry (indexed by 'data'). Returns NULL if error, or if 'data' is out of range.
// (requires Winamp 2.04+, only usable from plug-ins (not external apps))
  
{
IPC_GETHTTPGETTER 240
/* retrieves a function pointer to a HTTP retrieval function.
** if this is unsupported, returns 1 or 0.
** the function should be:
** int (*httpRetrieveFile)(HWND hwnd, char *url, char *file, char *dlgtitle);
** if you call this function, with a parent window, a URL, an output file, and a dialog title,
** it will return 0 on successful download, 1 on error.
*/
}

  IPC_MBOPEN = 241; // Opens an new URL in the minibrowser.
                    // If the URL is NULL it will open the Minibrowser window
                    // (requires Winamp 2.05+)

  IPC_INETAVAILABLE =  242;
  // checks to see if a net connection is available (1 if Yes)
  // (requires Winamp 2.05+)

  IPC_UPDTITLE = 243; // Asks Winamp to update the information about the current title
                      // (requires Winamp 2.2+)

  IPC_CHANGECURRENTFILE = 245; // Sets the current playlist item (requires Winamp 2.05+)

  // 246 Retrives the current Minibrowser URL into the buffer.  (requires Winamp 2.2+)

 	IPC_REFRESHPLCACHE = 247;	//  Flushes the playlist cache buffer
                            // (requires Winamp 2.2+)
                            // (send this if you want it to go refetch titles for tracks)

  // IPC_MBBLOCK=248 Blocks the Minibrowser from updates if value is set to 1 (requires Winamp 2.4+)
  // IPC_MBOPENREAL=249 Opens an new URL in the minibrowser (like 241) except that it will work even if 248 is set to 1  (requires Winamp 2.4+)
  IPC_GETSHUFFLE = 250; // Returns the status of the shuffle option (1 if set) (requires Winamp 2.4+)
  IPC_GETREPEAT  = 251; // Returns the status of the repeat option (1 if set) (requires Winamp 2.4+)
  IPC_SETSHUFFLE = 252; // Sets the status of the suffle option (1 to turn it on) (requires Winamp 2.4+)
  IPC_SETREPEAT  = 253; // Sets the status of the repeat option (1 to turn it on)(requires Winamp 2.4+)

  IPC_ENABLEDISABLE_ALL_WINDOWS = 259;
// (requires Winamp 2.9+)
// SendMessage(hwnd_winamp,WM_WA_IPC,enable?0:0xdeadbeef,IPC_ENABLEDISABLE_ALL_WINDOWS);
// sending with 0xdeadbeef as the param disables all winamp windows,
// any other values will enable all winamp windows.

//--------------------------------------------------------------------------

  IPC_GETWND = 260;
// (requires Winamp 2.9+)
//  HWND h=SendMessage(hwnd_winamp,WM_WA_IPC,IPC_GETWND_xxx,IPC_GETWND);
//  returns the HWND of the window specified.
//  #define IPC_GETWND_EQ 0 // use one of these for the param
//  #define IPC_GETWND_PE 1
//  #define IPC_GETWND_MB 2
//  #define IPC_GETWND_VIDEO 3
  IPC_GETWND_EQ    = 0;
  IPC_GETWND_PE    = 1;
  IPC_GETWND_MB    = 2;
  IPC_GETWND_VIDEO = 3;
//--------------------------------------------------------------------------

  IPC_ISWNDVISIBLE = 261; // returns 1 if specified window is visible
                          // same param as IPC_GETWND

//--------------------------------------------------------------------------

  IPC_ADJUST_OPTIONSMENUPOS = 280; //  moves where winamp expects the Options menu in the main menu. Useful if you wish to insert a menu item above the options/skins/vis menus.(requires Winamp 2.9+)
  IPC_GET_HMENU = 281;
  IPC_GET_EXTENDED_FILE_INFO = 290; //pass a pointer to the following struct in wParam
  {
  typedef struct
      [
      char *filename;
      char *metadata;
      char *ret;
      int retlen;
      ] extendedFileInfoStruct;
  }

IPC_GETINIFILE = 334; // returns a pointer in the remote memory to the full file path of winamp.ini
IPC_GETINIDIRECTORY = 335; // returns a pointer in the remote memory to the directory where winamp.ini can be found
IPC_ISFULLSTOP = 400; // returns nonzero if it's full, zero if it's just a new track

IPC_GET_IVIDEOOUTPUT = 500;
  //function VIDEO_MAKETYPE(A, B, C, D: Byte): UINT;
  // ((A) | ((B)<<8) | ((C)<<16) | ((D)<<24)) }
const
  VIDUSER_SET_INFOSTRING = $1000;
  VIDUSER_GET_VIDEOHWND  = $1001;
  VIDUSER_SET_VFLIP      = $1002;

IPC_IS_PLAYING_VIDEO = 501; // returns >1 if playing, 0 if not, 1 if old version (so who knows):)

IPC_BURN_CD = 511; // (requires Winamp 5.0


  IPC_CB_ONSHOWWND = 600;
  IPC_CB_ONHIDEWND = 601;
  IPC_CB_GETTOOLTIP = 602;
  { wParam = ... }
    IPC_CB_WND_EQ    = 0; { use one of these for the wParam }
    IPC_CB_WND_PE    = 1;
    IPC_CB_WND_MB    = 2;
    IPC_CB_WND_VIDEO = 3;
    IPC_CB_WND_MAIN  = 4;


  IPC_CB_MISC = 603;
  { wParam = ... }
    IPC_CB_MISC_TITLE     = 0;
    IPC_CB_MISC_VOLUME    = 1; { volume/pan }
    IPC_CB_MISC_STATUS    = 2;
    IPC_CB_MISC_EQ        = 3;
    IPC_CB_MISC_INFO      = 4;
    IPC_CB_MISC_VIDEOINFO = 5;


  IPC_CB_CONVERT_STATUS = 604;
    { wParam value goes from 0 to 100 (percent) }
  IPC_CB_CONVERT_DONE   = 605;


  IPC_ADJUST_FFWINDOWSMENUPOS = 606; { TODO : check }
    { (requires Winamp 2.9+)
      iNewPos:= SendMessage(hwndWinamp,
                    WM_WA_IPC,
                    (WPARAM)AdjustOffset,
                    IPC_ADJUST_FFWINDOWSMENUPOS);

      Moves where winamp expects the freeform windows in the menubar
      windows main menu. Useful if you wish to insert a menu item
      above extra freeform windows. }


IPC_ISDOUBLESIZE = 608; // returns 1 on doublesize mode


  IPC_ADJUST_FFOPTIONSMENUPOS = 609; { TODO : check }
    { (requires Winamp 2.9+)

      iNewPos:= SendMessage(hwndWinamp,
                    WM_WA_IPC,
                    (WPARAM)AdjustOffset,
                    IPC_ADJUST_FFOPTIONSMENUPOS);

      Moves where winamp expects the freeform preferences item in the
      menubar windows main menu. Useful if you wish to insert a
      menu item above preferences item. }

  IPC_GETTIMEDISPLAYMODE = 610; // returns 0 if displaying elapsed time or 1 if displaying remaining time

IPC_SETVISWND = 611;
    { wParam is hWnd, setting this allows you to receive
      ID_VIS_NEXT/PREVOUS/RANDOM/FS wm_commands }
ID_VIS_NEXT       = 40382;
ID_VIS_PREV       = 40383;
ID_VIS_RANDOM     = 40384;
ID_VIS_FS         = 40389;
ID_VIS_CFG        = 40390;
ID_VIS_MENU       = 40391;



IPC_GETVISWND = 612; // returns the vis cmd handler hwnd
IPC_ISVISRUNNING = 613; // 1 if Vis plugin is running

IPC_SETIDEALVIDEOSIZE = 614;
    { Sent by winamp to winamp, trap it if you need it.
      nWidth:= HIWORD(wParam),
      nHeight:= LOWORD(wParam) }

IPC_GETSTOPONVIDEOCLOSE = 615;
IPC_SETSTOPONVIDEOCLOSE = 616;

//--------------------------------------------------------------------

type
  TTransAccelStruct = packed record
    hWnd: HWND;
    uMsg: UINT;
    wParam: WPARAM;
    lParam: LPARAM;
  end; { TTransAccelStruct }

const
  IPC_TRANSLATEACCELERATOR = 617;

//--------------------------------------------------------------------

type
{ Send this as wParam to an IPC_PLCMD, IPC_MBCMD, IPC_VIDCMD }
  PWindowCommand = ^TWindowCommand;
  TWindowCommand = packed record
    uCmd: UINT;
    X, Y: Integer;
    iAlign: Integer;
  end; { TWindowCommand }


const
  IPC_CB_ONTOGGLEAOT = 618;
  IPC_GETPREFSWND = 619;

  IPC_SET_PE_WIDTHHEIGHT = 620;
    { wParam is a pointer to a POINT structure that holds width & height }


  IPC_GETLANGUAGEPACKINSTANCE = 621;

  IPC_CB_PEINFOTEXT = 622;
    { wParam is a string, ie: "04:21/45:02" }

  IPC_CB_OUTPUTCHANGED = 623;
    { output plugin was changed in config }


//--------------------------------------------------------------------

IPC_GETOUTPUTPLUGIN = 625; // gets the filename of the output plugin

IPC_SETDRAWBORDERS = 626;
IPC_DISABLESKINCURSORS = 627;
IPC_CB_VISRANDOM = 628; // wParam is status of random
IPC_CB_RESETFONT = 629;

IPC_IS_FULLSCREEN = 630; // returns 1 if video or vis is in fullscreen mode
IPC_SET_VIS_FS_FLAG = 631;
    { a vis should send this message with 1/as param to notify
      winamp that it has gone to or has come back from fullscreen mode }

IPC_SHOW_NOTIFICATION = 632;
IPC_GETSKININFO = 633;

IPC_GET_MANUALPLADVANCE = 634; // returns the status of the Manual Playlist Advance (1 if set)
IPC_SET_MANUALPLADVANCE = 635;  // sets the status of the Manual Playlist Advance option (1 to turn it on)
IPC_IS_WNDSHADE = 638; // returns 1 if wnd is set to winshade mode, or 0 if it is not
IPC_SETRATING = 639; // sets the current item's rating (0..5)
IPC_GETRATING = 640; // gets the current item's rating (0..5)
IPC_PUSH_DISABLE_EXIT = 647; // disables program exit
IPC_POP_DISABLE_EXIT = 648; // enables program exit
IPC_IS_EXIT_ENABLED = 649; // returns 0 if exit is disabled, 1 otherwise
IPC_IS_AOT = 650; // returns status of always on top flag. note: this may not match the actual TOPMOST window flag while another fullscreen application is focused
IPC_GETREGISTEREDVERSION = 770; // opens the preferences dialog and shows the Winamp Pro option

IPC_ISMAINWNDVISIBLE = 900; // returns 1 when main window is visible

IPC_SETPLEDITCOLORS = 920;
    { SendMessage(hwndWinamp,
          WM_WA_IPC,
          WPARAM(@SetPLColorsStruct),
          IPC_SETPLEDITCOLORS); }
type
  PSetPLColorsStruct = ^TSetPLColorsStruct;
  TSetPLColorsStruct = packed record
    nNumElems: UINT;
    pElems: PUINT;
    hBitmap: HBITMAP;
      { set if you want to override }
  end; { TSetPLColorsStruct }


implementation


end.
