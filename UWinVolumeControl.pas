// Windows Volume Control
// From Torry's Delphi Pages
// http://www.swissdelphicenter.ch/torry/showcode.php?id=630

unit UWinVolumeControl;

interface

uses
  Windows;

function GetWaveVolume(var LVol: DWORD; var RVol: DWORD): Boolean;
function SetWaveVolume(const AVolume: DWORD): Boolean;

implementation

uses
  MMSystem;

function GetWaveVolume(var LVol: DWORD; var RVol: DWORD): Boolean;
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


function SetWaveVolume(const AVolume: DWORD): Boolean;
var
  WaveOutCaps: TWAVEOUTCAPS;
begin
  Result := False;
  if WaveOutGetDevCaps(WAVE_MAPPER, @WaveOutCaps, SizeOf(WaveOutCaps)) = MMSYSERR_NOERROR then
    if WaveOutCaps.dwSupport and WAVECAPS_VOLUME = WAVECAPS_VOLUME then
      Result := WaveOutSetVolume(WAVE_MAPPER, AVolume) = MMSYSERR_NOERROR;
end;

{
  AVolume:
  The low-order word contains the left-channel volume setting,
  and the high-order word contains the right-channel setting.
  A value of 65535 represents full volume, and a value of 0000 is silence.
  If a device does not support both left and right volume control,
  the low-order word of dwVolume specifies the volume level,
  and the high-order word is ignored.
}

end.
 