Unit USplit;

interface

uses
  SysUtils
  ,Classes // TString;
  ;


type
	TSplitArray = array of String;

function Split(const Source, Delimiter: String): TSplitArray;  

implementation

//-----------------------------------------------------------------------
// D�coupage d'une cha�ne en un tableau de cha�nes suivant un d�limiteur
//
// Param�tres :
// Source ........... Cha�ne � d�couper
// Delimiter ........ Suite de d�limiteurs � utiliser
//
// Retourne :
// Un tableau de cha�nes contenant les sous-cha�nes (sans les d�limiteurs)
// Le tableau peut �tre vide
//-----------------------------------------------------------------------

function Split(const Source, Delimiter: String): TSplitArray;
var
    iCount: Integer;
    iPos: Integer;
    iLength: Integer;
    sTemp: String;
    aSplit: TSplitArray;

begin
    sTemp := Source;
    iCount := 0;
    iLength := Length(Delimiter) - 1;
    
    repeat
      iPos := Pos(Delimiter, sTemp);
      if iPos = 0 then
        break
      else begin
        Inc(iCount);
        SetLength(aSplit, iCount);
        aSplit[iCount - 1] := Copy(sTemp, 1, iPos - 1);
        Delete(sTemp, 1, iPos + iLength);
        end;
    until False;

    if Length(sTemp) > 0 then begin
      Inc(iCount);
      SetLength(aSplit, iCount);
      aSplit[iCount - 1] := sTemp;
    end;
    
    Result := aSplit;
end;



end.