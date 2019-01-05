Unit UMixer;

Interface

uses
  MMSystem
  ,Windows  // zeroMemory
  ;


type
 TMixerLineSourceType = (lsDigital, lsLine, lsMicrophone, lsCompactDisk, lsTelephone,
                         lsWaveOut, lsAuxiliary, lsAnalog, lsLast);

function SetMixerLineSourceMute(AMixerLineSourceType: TMixerLineSourceType; bMute: Boolean): Boolean;
function GetWaveVolume(var LVol: WORD; var RVol: WORD): Boolean;
function SetWaveVolume(const LVol, RVol: WORD): Boolean;

Implementation

function GetWaveVolume(var LVol: WORD; var RVol: WORD): Boolean;
var
  WaveOutCaps: TWAVEOUTCAPS;
  Volume: DWORD;
begin
  Result := False;
  if WaveOutGetDevCaps(WAVE_MAPPER, @WaveOutCaps, SizeOf(WaveOutCaps)) = MMSYSERR_NOERROR then
    if WaveOutCaps.dwSupport and WAVECAPS_VOLUME = WAVECAPS_VOLUME then
    begin
      Result := WaveOutGetVolume(WAVE_MAPPER, @Volume) = MMSYSERR_NOERROR;
      LVol   := LoWord(Volume);
      RVol   := HiWord(Volume);
    end;
end;


{
  The waveOutGetDevCaps function retrieves the capabilities of
  a given waveform-audio output device.

  The waveOutGetVolume function retrieves the current volume level
  of the specified waveform-audio output device.
}


function SetWaveVolume(const LVol, RVol: WORD): Boolean;
var
  WaveOutCaps: TWAVEOUTCAPS;
  dwVol : DWord;
begin

  dwVol := MakeLong (LVol, RVol);

  Result := False;
  if WaveOutGetDevCaps(WAVE_MAPPER, @WaveOutCaps, SizeOf(WaveOutCaps)) = MMSYSERR_NOERROR then
    if WaveOutCaps.dwSupport and WAVECAPS_VOLUME = WAVECAPS_VOLUME then
      Result := WaveOutSetVolume(WAVE_MAPPER, dwVol) = MMSYSERR_NOERROR;
end;

// Setzt die Lautstärke für das Mikrofon
// Set the volume for the microphone

function SetMicrophoneVolume(bValue: Word): Boolean;
var                          {0..65535}
  hMix: HMIXER;
  mxlc: MIXERLINECONTROLS;
  mxcd: TMIXERCONTROLDETAILS;
  vol: TMIXERCONTROLDETAILS_UNSIGNED;
  mxc: MIXERCONTROL;
  mxl: TMixerLine;
  intRet: Integer;
  nMixerDevs: Integer;
begin
  // Check if Mixer is available
  // Überprüfen, ob ein Mixer vorhanden
  nMixerDevs := mixerGetNumDevs();
  if (nMixerDevs < 1) then
  begin
    Result := False;
    Exit;
  end;

  Result := True;

  // open the mixer
  intRet := mixerOpen(@hMix, 0, 0, 0, 0);
  if intRet = MMSYSERR_NOERROR then
  begin
    mxl.dwComponentType := MIXERLINE_COMPONENTTYPE_SRC_MICROPHONE;
    mxl.cbStruct := SizeOf(mxl);

    // get line info
    intRet := mixerGetLineInfo(hMix, @mxl, MIXER_GETLINEINFOF_COMPONENTTYPE);

    if intRet = MMSYSERR_NOERROR then
    begin
      ZeroMemory(@mxlc, SizeOf(mxlc));
      mxlc.cbStruct := SizeOf(mxlc);
      mxlc.dwLineID := mxl.dwLineID;
      mxlc.dwControlType := MIXERCONTROL_CONTROLTYPE_VOLUME;
      mxlc.cControls := 1;
      mxlc.cbmxctrl := SizeOf(mxc);

      mxlc.pamxctrl := @mxc;
      intRet := mixerGetLineControls(hMix, @mxlc, MIXER_GETLINECONTROLSF_ONEBYTYPE);

      if intRet = MMSYSERR_NOERROR then
      begin
      {
       // Microphone Name
          Label1.Caption := mxlc.pamxctrl.szName;

        // Min/Max Volume
        Label2.Caption := IntToStr(mxc.Bounds.dwMinimum) + '->' + IntToStr(mxc.Bounds.dwMaximum);
      }
        ZeroMemory(@mxcd, SizeOf(mxcd));
        mxcd.dwControlID := mxc.dwControlID;
        mxcd.cbStruct := SizeOf(mxcd);
        mxcd.cMultipleItems := 0;
        mxcd.cbDetails := SizeOf(Vol);
        mxcd.paDetails := @vol;
        mxcd.cChannels := 1;

        // vol.dwValue := mxlc.pamxctrl.Bounds.lMinimum; Set min. Volume / Minimum setzen
        // vol.dwValue := mxlc.pamxctrl.Bounds.lMaximum; Set max. Volume / Maximum setzen
        vol.dwValue := bValue;

        intRet := mixerSetControlDetails(hMix, @mxcd,
          MIXER_SETCONTROLDETAILSF_VALUE);
        if intRet <> MMSYSERR_NOERROR then
          Result := False; // ShowMessage('SetControlDetails Error');
      end
      else
        Result := False; // ShowMessage('GetLineInfo Error');
    end;
    intRet := mixerClose(hMix);
  end;
end;

{
procedure TForm1.Button1Click(Sender: TObject);
begin
  SetMicrophoneVolume(30000);
end;
}

{********************************************************}


// Enable/disable "Mute Microphone Volume"
// Ton für Mikrofon ein/ausschalten

function SetMicrophoneVolumeMute(bMute: Boolean): Boolean;
var
  hMix: HMIXER;
  mxlc: MIXERLINECONTROLS;
  mxcd: TMIXERCONTROLDETAILS;
  vol: TMIXERCONTROLDETAILS_UNSIGNED;
  mxc: MIXERCONTROL;
  mxl: TMixerLine;
  intRet: Integer;
  nMixerDevs: Integer;
  mcdMute: MIXERCONTROLDETAILS_BOOLEAN;
begin
  // Check if Mixer is available
  // Überprüfen, ob ein Mixer vorhanden ist
  nMixerDevs := mixerGetNumDevs();
  if (nMixerDevs < 1) then
  begin
    Result := False;
    Exit;
  end;

  Result := true;

  // open the mixer
  // Mixer öffnen
  intRet := mixerOpen(@hMix, 0, 0, 0, 0);
  if intRet = MMSYSERR_NOERROR then
  begin
    mxl.dwComponentType := MIXERLINE_COMPONENTTYPE_SRC_MICROPHONE;
    mxl.cbStruct        := SizeOf(mxl);

    // mixerline info
    intRet := mixerGetLineInfo(hMix, @mxl, MIXER_GETLINEINFOF_COMPONENTTYPE);

    if intRet = MMSYSERR_NOERROR then
    begin
      ZeroMemory(@mxlc, SizeOf(mxlc));
      mxlc.cbStruct := SizeOf(mxlc);
      mxlc.dwLineID := mxl.dwLineID;
      mxlc.dwControlType := MIXERCONTROL_CONTROLTYPE_MUTE;
      mxlc.cControls := 1;
      mxlc.cbmxctrl := SizeOf(mxc);
      mxlc.pamxctrl := @mxc;

      // Get the mute control
      // Mute control ermitteln
      intRet := mixerGetLineControls(hMix, @mxlc, MIXER_GETLINECONTROLSF_ONEBYTYPE);

      if intRet = MMSYSERR_NOERROR then
      begin
        ZeroMemory(@mxcd, SizeOf(mxcd));
        mxcd.cbStruct := SizeOf(TMIXERCONTROLDETAILS);
        mxcd.dwControlID := mxc.dwControlID;
        mxcd.cChannels := 1;
        mxcd.cbDetails := SizeOf(MIXERCONTROLDETAILS_BOOLEAN);
        mxcd.paDetails := @mcdMute;

        mcdMute.fValue := Ord(bMute);

        // set, unset mute
        // Stumsschalten ein/aus
        intRet := mixerSetControlDetails(hMix, @mxcd,
          MIXER_SETCONTROLDETAILSF_VALUE);
          {
          mixerGetControlDetails(hMix, @mxcd,
                                 MIXER_GETCONTROLDETAILSF_VALUE);
          Result := Boolean(mcdMute.fValue);
          }
        Result := intRet = MMSYSERR_NOERROR;

        if intRet <> MMSYSERR_NOERROR then
          result := False; //ShowMessage('SetControlDetails Error');
      end
      else
        result := False; // ShowMessage('GetLineInfo Error');
    end;

    intRet := mixerClose(hMix);
  end;
end;

{
procedure TForm1.Button1Click(Sender: TObject);
begin
  SetMicrophoneVolumeMute(False);
end;
}

{********************************************************}

// Enable/disable "Mute" for several mixer line sources.

function SetMixerLineSourceMute(AMixerLineSourceType: TMixerLineSourceType; bMute: Boolean): Boolean;
var
  hMix: HMIXER;
  mxlc: MIXERLINECONTROLS;
  mxcd: TMIXERCONTROLDETAILS;
  vol: TMIXERCONTROLDETAILS_UNSIGNED;
  mxc: MIXERCONTROL;
  mxl: TMixerLine;
  intRet: Integer;
  nMixerDevs: Integer;
  mcdMute: MIXERCONTROLDETAILS_BOOLEAN;
begin
  Result := False;
  // Check if Mixer is available
  // Überprüfen, ob ein Mixer vorhanden ist
  nMixerDevs := mixerGetNumDevs();
  if (nMixerDevs < 1) then
  begin
    Result := False;
    Exit;
  end;

  Result := true;

  // open the mixer
  // Mixer öffnen
  intRet := mixerOpen(@hMix, 0, 0, 0, 0);
  if intRet = MMSYSERR_NOERROR then
  begin
    ZeroMemory(@mxl, SizeOf(mxl));
    case AMixerLineSourceType of
      lsDigital: mxl.dwComponentType :=MIXERLINE_COMPONENTTYPE_SRC_DIGITAL;
      lsLine: mxl.dwComponentType := MIXERLINE_COMPONENTTYPE_SRC_LINE;
      lsMicrophone: mxl.dwComponentType :=MIXERLINE_COMPONENTTYPE_SRC_MICROPHONE;
      lsCompactDisk: mxl.dwComponentType :=MIXERLINE_COMPONENTTYPE_SRC_COMPACTDISC;
      lsTelephone: mxl.dwComponentType :=MIXERLINE_COMPONENTTYPE_SRC_TELEPHONE;
      lsWaveOut: mxl.dwComponentType :=MIXERLINE_COMPONENTTYPE_SRC_WAVEOUT;
      lsAuxiliary: mxl.dwComponentType :=MIXERLINE_COMPONENTTYPE_SRC_AUXILIARY;
      lsAnalog : mxl.dwComponentType :=MIXERLINE_COMPONENTTYPE_SRC_ANALOG;
      lsLast: mxl.dwComponentType :=MIXERLINE_COMPONENTTYPE_SRC_LAST;
    end;

    // mixerline info
    mxl.cbStruct := SizeOf(mxl);
    intRet := mixerGetLineInfo(hMix, @mxl, MIXER_GETLINEINFOF_COMPONENTTYPE);

    if intRet = MMSYSERR_NOERROR then
    begin
      ZeroMemory(@mxlc, SizeOf(mxlc));
      mxlc.cbStruct := SizeOf(mxlc);
      mxlc.dwLineID := mxl.dwLineID;
      mxlc.dwControlType := MIXERCONTROL_CONTROLTYPE_MUTE;
      mxlc.cControls := 1;
      mxlc.cbmxctrl := SizeOf(mxc);
      mxlc.pamxctrl := @mxc;

      // Get the mute control
      // Mute control ermitteln
      intRet := mixerGetLineControls(hMix, @mxlc, MIXER_GETLINECONTROLSF_ONEBYTYPE);

      if intRet = MMSYSERR_NOERROR then
      begin
        ZeroMemory(@mxcd, SizeOf(mxcd));
        mxcd.cbStruct := SizeOf(TMIXERCONTROLDETAILS);
        mxcd.dwControlID := mxc.dwControlID;
        mxcd.cChannels := 1;
        mxcd.cbDetails := SizeOf(MIXERCONTROLDETAILS_BOOLEAN);
        mxcd.paDetails := @mcdMute;

        mcdMute.fValue := Ord(bMute);

        // set, unset mute
        // Stumsschalten ein/aus
        intRet := mixerSetControlDetails(hMix, @mxcd, MIXER_SETCONTROLDETAILSF_VALUE);
        {
        mixerGetControlDetails(hMix, @mxcd, MIXER_GETCONTROLDETAILSF_VALUE);
        Result := Boolean(mcdMute.fValue);
        }
        Result := intRet = MMSYSERR_NOERROR;

      end
      else
        Result := False; // ShowMessage('GetLineInfo Error');
    end;
    intRet := mixerClose(hMix);
  end;
end;
{
// Example Call; Beispielaufruf:

procedure TForm1.Button1Click(Sender: TObject);
begin
  // Ton ausschalten
  SetMixerLineSourceMute(lsLine, True);
end;
}

end.
