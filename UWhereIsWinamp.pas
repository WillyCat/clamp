unit UWhereIsWinamp;

interface

uses
   Windows      // RegQueryValue
  ,SysUtils     // StrAlloc
  ,Registry
  ;
  
  function _WhereIsWinamp : String;
  function GetAmpExePath : string;

implementation

//--------------------------------------------------------------------

// Tries to find where active version of winamp.exe resides
// Returns '' upon failure
// Returns full pathname (C:\ .... \ winamp.exe)

 const
      BufferSize = {$IFDEF Win32} 540 {$ELSE} 80 {$ENDIF};

function _WhereIsWinamp : String;
  var
      Buffer : PChar;
      sBuffer : String;
//      StringPosition : PChar;
      ReturnedData: Longint;
			i : integer;
begin
	Result := '';
  Buffer := StrAlloc(BufferSize);
  try
    ReturnedData := BufferSize;

    StrPCopy(Buffer, 'Applications\Winamp.exe\shell\open\command');
    RegQueryValue(hKey_Classes_Root, Buffer, Buffer, ReturnedData);   // <Buffer> = <"c:\....\" "%1">

    // If entry is not found, ReturnedData = BufferSize
    // If entry is empty, Strlen(buffer) = 0

    if (ReturnedData <> BufferSize) and (StrLen(Buffer) > 0) then
    begin
    	sBuffer := String (Buffer);

      i := 2;
      While (sBuffer[i] <> '"') do
      begin
      	Result := Result + sBuffer[i];
        Inc (i);
      end;

    end;
  finally
    StrDispose (Buffer);
	end;

	if Result = '' then
	  Result := 'C:\Program Files\Winamp\winamp.exe';
    // Germany // sExePathName := 'C:\Programme\Winamp\winamp.exe';
end;

//-----------------------------------------------------------------------------

function GetAmpExePath : string;
 procedure delchar(var str : string;ch : char);
 var
  i : integer;
 begin
  i :=0;
  repeat
   inc(i);
   if str[i] = ch then delete(str,i,1);
  until i >= length(str);
 end;

var
 reg : TRegistry;
begin  
 reg := TRegistry.Create;
 Result := '';
 if reg.KeyExists('SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\Winamp.exe') then
  begin
   Reg.RootKey := HKEY_LOCAL_MACHINE;
   reg.OpenKeyReadOnly('SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\Winamp.exe');
   Result := reg.ReadString('');
   reg.CloseKey;
   reg.Free;
   Exit;
  end;

 Reg.RootKey := HKEY_LOCAL_MACHINE;
 if reg.KeyExists('SOFTWARE\Classes\Winamp.File\shell\Play\command') then
  begin
   reg.OpenKeyReadOnly('SOFTWARE\Classes\Winamp.File\shell\Play\command');
   Result := reg.ReadString('');
   Delete(Result,Length(Result)-5,5);
   DelChar(result,'"');
   reg.CloseKey;
   reg.Free;
   Exit;
  end;

 Reg.RootKey := HKEY_Local_Machine;
 if reg.KeyExists('SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Winamp') then
  begin
   reg.OpenKeyReadOnly('SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Winamp');
   Result := reg.ReadString('UninstallString');
   Delete(Result,Length(Result)-10,10);
   DelChar(result,'"');
   reg.CloseKey;
   reg.Free;
   Exit;
  end;
  
 Reg.RootKey := HKEY_CLASSES_ROOT;
 if reg.KeyExists('Applications\Winamp.File\shell\Play\command') then
  begin
   reg.OpenKeyReadOnly('Applications\Winamp.File\shell\Play\command');
   Result := reg.ReadString('');
   Delete(Result,Length(Result)-5,5);
   DelChar(result,'"');
   reg.CloseKey;
   reg.Free;
   Exit;
  end;
  
 //if Result = '' then
 //RaiseError('Could NOT Locate the winamp executable!'+#13+'did you install it properly ?');

 // Note from a German user :
 // HKEY_CURRENT_USER\Software\Winamp
 // The Value is: Default (at me is it C:\Programme\Winamp)

 reg.CloseKey;
 reg.Free;
end;

end.
