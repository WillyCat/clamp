unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons
  ,UWinAmp, ComCtrls, ExtCtrls
  ;

type
  TForm1 = class(TForm)
    GroupBox2: TGroupBox;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    BitBtn1: TBitBtn;
    BitBtn4: TBitBtn;
    BitBtn5: TBitBtn;
    GroupBox3: TGroupBox;
    BitBtn7: TBitBtn;
    RichEdit1: TRichEdit;
    StatusBar1: TStatusBar;
    Timer1: TTimer;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    BitBtn6: TBitBtn;
    procedure FormCreate(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure BitBtn4Click(Sender: TObject);
    procedure BitBtn5Click(Sender: TObject);
    procedure BitBtn7Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure BitBtn6Click(Sender: TObject);

  private
    { Déclarations privées }
		procedure ShowWinAmpInfos;

  public
    { Déclarations publiques }

  end;

var
  Form1: TForm1;
  wa : TWinAmp;



implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
	wa := TWinAMP.Create;
//  Memo1.Clear;
  RichEdit1.Clear;

  ShowWinAmpInfos;
end;

//-----------------------------------------------------------------

procedure TForm1.ShowWinAmpInfos;
var
  hwnd : integer;
  b : Boolean;
	iStatus : integer;
  sStatus : String;
  sStr : String;
begin

	wa.Init;
	hwnd := wa.GetWinHandle;

	//--------------------------------

  if hwnd <> 0 then
    b := true
  else
    b := false;

  bitbtn1.enabled := b;
  bitbtn2.enabled := b;
  bitbtn3.enabled := b;
  bitbtn4.enabled := b;
  bitbtn5.enabled := b;
  bitbtn7.enabled := b;  

  //--------------------------------

  if hwnd <> 0 then
		sStr := inttostr(hwnd)
  else
  	sStr := '';

	StatusBar1.Panels[1].Text := sStr;

  //--------------------------------

  if hwnd <> 0 then
  begin
    iStatus := wa.GetCurrentStatus;
    case iStatus of
      WINAMP_STATUS_PLAYING : sStatus := 'Playing';
      WINAMP_STATUS_STOPPED : sStatus := 'Stopped';
      WINAMP_STATUS_PAUSED  : sStatus := 'Pause';
    end;
	end
  else
  	sStatus := 'Winamp not running';
	StatusBar1.Panels[0].Text := sStatus;

  //--------------------------------

  if hwnd <> 0 then
		sStr := wa.sVersion + Format(' (0x%x)', [wa.iRawVersion])
  else
  	sStr := '';

  StatusBar1.Panels[2].Text := sStr;

  //--------------------------------

  if hwnd <> 0 then
  begin
    wa.PlayListRead;
    if wa.plLength > 0 Then
      sStr := IntToStr(wa.plPosition+1) + ' / ' + IntToStr(wa.plLength)
    else
      sStr := '';
  end
  else
  	sStr := '';

  Label1.Caption := sStr;

  //--------------------------------

  if hwnd <> 0 Then
  begin
    wa.GetCurrentFileInfos;
    Label2.Caption := inttostr(wa.CurrentFile.iSampleRate) + ' KHz';
    Label3.Caption := inttostr(wa.CurrentFile.iBitRate) + ' KBps';
    Label4.Caption := inttostr(wa.CurrentFile.iChannels) + ' channel(s)';
    Label5.Caption := wa.CurrentFile.sTitle;

    if RichEdit1.Lines[0] <> wa.CurrentFile.sTitle then
    begin
	    RichEdiT1.Clear;
  	  RichEdit1.Lines.Add(wa.CurrentFile.sTitle);
    end;
	end
  else
  begin
    Label2.Caption := '';
    Label3.Caption := '';
    Label4.Caption := '';
    Label5.Caption := '';
  end;

  //--------------------------------

  if hwnd <> 0 Then
  begin
	  wa.GetCurrentPosition;
    sStr := wa.sPosition + ' / ' + wa.CurrentFile.sLength;
  end
  else
  	sStr := '';

  Label6.Caption := sStr;
end;

//-----------------------------------------------------------------

procedure TForm1.BitBtn1Click(Sender: TObject);
begin
	wa.Next;
end;

//-----------------------------------------------------------------

procedure TForm1.BitBtn2Click(Sender: TObject);
begin
	wa.Prev;
end;

//-----------------------------------------------------------------

procedure TForm1.BitBtn3Click(Sender: TObject);
begin
	wA.Play;
end;

//-----------------------------------------------------------------

procedure TForm1.BitBtn4Click(Sender: TObject);
begin
	wa.Pause;
end;

//-----------------------------------------------------------------

procedure TForm1.BitBtn5Click(Sender: TObject);
begin
	wa.Stop;
end;


procedure TForm1.BitBtn7Click(Sender: TObject);
begin
	wa.PlayListClear;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
	ShowWinAmpInfos;
end;


procedure TForm1.BitBtn6Click(Sender: TObject);
var
	sFilename  : String;
  openDialog1 : TOpenDialog;
  bMultiple : Boolean;
  i : integer;
begin
	bMultiple := TRUE;

	openDialog1 := TOpenDialog.Create(self);

	//openDialog1.InitialDir := GetCurrentDir;

  openDialog1.Options := [ofFileMustExist];

  if bMultiple then
		openDialog1.Options := [ofAllowMultiSelect];

	openDialog1.Filter  :=  'MP3 files|*.mp3|Wave files|*.wav';
	openDialog1.FilterIndex := 1;

  if OpenDialog1.Execute then
	begin
  	if bMultiple then
			for i := 0 to openDialog1.Files.Count-1 do
  	  begin
      	sFilename := openDialog1.Files[i];
				wa.PlayListAdd(sFilename);
    	end
    else
    begin
			sFilename := openDialog1.FileName;
			wa.PlayListAdd(sFilename);
    end;
	end;

//	sFilename := 'C:\Ressources\Audio\Music\CD106\12 The Ritchie Family - Best Disco In Town 1.mp3';

	openDialog1.Free;
end;

end.
