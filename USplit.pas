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
// Découpage d'une chaîne en un tableau de chaînes suivant un délimiteur
//
// Paramètres :
// Source ........... Chaîne à découper
// Delimiter ........ Suite de délimiteurs à utiliser
//
// Retourne :
// Un tableau de chaînes contenant les sous-chaînes (sans les délimiteurs)
// Le tableau peut être vide
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