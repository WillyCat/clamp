unit UPostKey;

interface

uses
	Windows	// SendMessage
  ,Messages	// WM_COMMAND
  ,Classes // TShiftstate
  ;

type
  TShiftKeyInfo = record
    shift: Byte;
    vkey: Byte;
  end;
  byteset = set of 0..7;

const
  shiftkeys: array [1..3] of TShiftKeyInfo =
    ((shift: Ord(ssCtrl); vkey: VK_CONTROL),
    (shift: Ord(ssShift); vkey: VK_SHIFT),
    (shift: Ord(ssAlt); vkey: VK_MENU));
    
procedure PostKeyExHWND(hWindow: HWnd; key: Word; const shift: TShiftState;
  specialkey: Boolean);
  
implementation

procedure PostKeyExHWND(hWindow: HWnd; key: Word; const shift: TShiftState;
  specialkey: Boolean);
{************************************************************
 * Procedure PostKeyEx
 *
 * Parameters:
 *  hWindow: target window to be send the keystroke
 *  key    : virtual keycode of the key to send. For printable
 *           keys this is simply the ANSI code (Ord(character)).
 *  shift  : state of the modifier keys. This is a set, so you
 *           can set several of these keys (shift, control, alt,
 *           mouse buttons) in tandem. The TShiftState type is
 *           declared in the Classes Unit.
 *  specialkey: normally this should be False. Set it to True to
 *           specify a key on the numeric keypad, for example.
 *           If this parameter is true, bit 24 of the lparam for
 *           the posted WM_KEY* messages will be set.
 * Description:
 *  This procedure sets up Windows key state array to correctly
 *  reflect the requested pattern of modifier keys and then posts
 *  a WM_KEYDOWN/WM_KEYUP message pair to the target window. Then
 *  Application.ProcessMessages is called to process the messages
 *  before the keyboard state is restored.
 * Error Conditions:
 *  May fail due to lack of memory for the two key state buffers.
 *  Will raise an exception in this case.
 * NOTE:
 *  Setting the keyboard state will not work across applications
 *  running in different memory spaces on Win32 unless AttachThreadInput
 *  is used to connect to the target thread first.
 *Created: 02/21/96 16:39:00 by P. Below
 ************************************************************}
type
  TBuffers = array [0..1] of TKeyboardState;
var
  pKeyBuffers: ^TBuffers;
  lParam: LongInt;
begin
  (* check if the target window exists *)
  if IsWindow(hWindow) then
  begin
    (* set local variables to default values *)
    pKeyBuffers := nil;
    lParam := MakeLong(0, MapVirtualKey(key, 0));

    (* modify lparam if special key requested *)
    if specialkey then
      lParam := lParam or $1000000;

    (* allocate space for the key state buffers *)
    New(pKeyBuffers);
    try
      (* Fill buffer 1 with current state so we can later restore it.
         Null out buffer 0 to get a "no key pressed" state. *)
      GetKeyboardState(pKeyBuffers^[1]);
      FillChar(pKeyBuffers^[0], SizeOf(TKeyboardState), 0);

      (* set the requested modifier keys to "down" state in the buffer*)
      if ssShift in shift then
        pKeyBuffers^[0][VK_SHIFT] := $80;
      if ssAlt in shift then
      begin
        (* Alt needs special treatment since a bit in lparam needs also be set *)
        pKeyBuffers^[0][VK_MENU] := $80;
        lParam := lParam or $20000000;
      end;
      if ssCtrl in shift then
        pKeyBuffers^[0][VK_CONTROL] := $80;
      if ssLeft in shift then
        pKeyBuffers^[0][VK_LBUTTON] := $80;
      if ssRight in shift then
        pKeyBuffers^[0][VK_RBUTTON] := $80;
      if ssMiddle in shift then
        pKeyBuffers^[0][VK_MBUTTON] := $80;

      (* make out new key state array the active key state map *)
      SetKeyboardState(pKeyBuffers^[0]);
      (* post the key messages *)
      if ssAlt in Shift then
      begin
        PostMessage(hWindow, WM_SYSKEYDOWN, key, lParam);
        PostMessage(hWindow, WM_SYSKEYUP, key, lParam or $C0000000);
      end
      else
      begin
        PostMessage(hWindow, WM_KEYDOWN, key, lParam);
        PostMessage(hWindow, WM_KEYUP, key, lParam or $C0000000);
      end;
      (* process the messages *)
//      Application.ProcessMessages;

      (* restore the old key state map *)
      SetKeyboardState(pKeyBuffers^[1]);
    finally
      (* free the memory for the key state buffers *)
      if pKeyBuffers <> nil then
        Dispose(pKeyBuffers);
    end; { If }
  end;
end; { PostKeyEx }

end.
