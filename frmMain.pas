{
******************************************************
  Grim Fandango Dialog Editor
  Copyright (c) 2006 Bgbennyboy
  Http://quick.mixnmojo.com
******************************************************
}

unit frmMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, FileParser, ExtCtrls, JvExControls, JvComponent,
  JvSpeedButton, XPMan, JvExStdCtrls, JvRichEdit, JclShell, JclSysInfo;

type
  TformMain = class(TForm)
    RichEditDialog: TRichEdit;
    OpenDialog1: TOpenDialog;
    Panel1: TPanel;
    btnOpen: TJvSpeedButton;
    btnSave: TJvSpeedButton;
    XPManifest1: TXPManifest;
    btnSaveText: TJvSpeedButton;
    SaveDialog1: TSaveDialog;
    MemoLog: TJvRichEdit;
    btnLoadText: TJvSpeedButton;
    procedure btnLoadTextClick(Sender: TObject);
    procedure MemoLogURLClick(Sender: TObject; const URLText: string;
      Button: TMouseButton);
    procedure btnSaveClick(Sender: TObject);
    procedure btnSaveTextClick(Sender: TObject);
    procedure btnOpenClick(Sender: TObject);
  private
    procedure ParseFile;
    procedure CheckText;
    Procedure Log(LogText: string);
    function CheckHeader: boolean;
  public
    { Public declarations }
  end;

var
  formMain: TformMain;
  TheFile: TFileParser;

implementation

{$R *.dfm}

procedure TformMain.Log(LogText: string);
begin
  MemoLog.Lines.Add(LogText);
end;

procedure TformMain.btnLoadTextClick(Sender: TObject);
begin
  OpenDialog1.Filter:='Text Files|*.txt';
  OpenDialog1.InitialDir:='';
  if OpenDialog1.Execute = false then exit;

  RichEditDialog.Clear;
  RichEditDialog.Lines.LoadFromFile(OpenDialog1.FileName);
  MemoLog.Lines.Clear;
  Log('Imported text file "' + OpenDialog1.FileName + '"');
  CheckText;
end;

procedure TformMain.btnOpenClick(Sender: TObject);
begin
  OpenDialog1.Filter:='Grim.Tab|*.tab';
  OpenDialog1.InitialDir:=GetProgramFilesFolder + '\Lucasarts\Grim\';
  if OpenDialog1.Execute = false then
    exit;

  TheFile:=TFileParser.Create(OpenDialog1.FileName, $DD);
  try
    MemoLog.Lines.Clear;
    Log('Opened file "' + OpenDialog1.FileName + '"');
    if CheckHeader = false then
    begin
      Log('Not a valid .tab file!');
      exit;
    end;

    ParseFile;
  finally
    TheFile.Free;
  end;

end;

procedure TformMain.btnSaveClick(Sender: TObject);
type
  TBuffer = array of byte;
var
  memstream: tmemorystream;
  Buffer: ^TBuffer;
  BufferSize: longint;
  Size: integer;
  SaveFile: TFileStream;
  n: integer;
  BufferPtr: PAnsiChar;
  HeaderString: Ansistring;
begin
  if RichEditDialog.Lines.Count = 0 then exit;

  SaveDialog1.Filter:='Grim.Tab|*.tab';
  SaveDialog1.DefaultExt:='.tab';
  if SaveDialog1.Execute = false then exit;


  SaveFile:=TFilestream.Create(SaveDialog1.FileName, fmcreate);
  try
    memstream:=tmemorystream.Create;
    try
      RichEditDialog.Lines.SaveToStream(memstream);
      memstream.Position:=0;

      Size:=memstream.Size;
      GetMem(Buffer,size);
      try
        BufferSize := Size;
        memstream.Read(Buffer^, Buffersize);

        BufferPtr:=@Buffer^;
        for n:=0 to BufferSize-1 do
        begin
		      Byte(BufferPtr[n]):=Byte(BufferPtr[n]) xor $DD;
        end;

        //Write header first
        Headerstring:='RCNE';
        SaveFile.Write(Pointer(HeaderString)^, length(HeaderString));
        SaveFile.Write(Buffer^, BufferSize);
        Log('Saved file "' + SaveDialog1.FileName + '"');
      finally
        FreeMem(Buffer, size);
      end;

    finally
      memstream.Free;
    end;

  finally
    SaveFile.Free;
  end;
end;

procedure TformMain.btnSaveTextClick(Sender: TObject);
begin
  if RichEditDialog.Lines.Count = 0 then exit;

  SaveDialog1.Filter:='Text Files|*.txt';
  SaveDialog1.DefaultExt:='.txt';
  if SaveDialog1.Execute = false then exit;

  RichEditDialog.Lines.SaveToFile(SaveDialog1.FileName);
  Log('Saved "' + SaveDialog1.FileName + '"');
end;

function TformMain.CheckHeader: boolean;
begin
  thefile.Position:=0;
  if thefile.Size < 4 then
    result:=false
  else
  if thefile.ReadDWord = 1162756946 then
    result:=true
  else
    result:=false;
end;

procedure TformMain.CheckText;
var
  i: integer;
begin
  if RichEditDialog.Lines.Count = 0 then exit;

  richeditdialog.WordWrap:=false;
  Log('Checking file contents...');
  Application.ProcessMessages;
  
  for I := RichEditDialog.Lines.Count downto 0 do
  begin
    if RichEditDialog.Lines[i] = '' then
    begin
      Log('Cleanup: Removed empty line: ' + inttostr(i + 1));
      RichEditDialog.Lines.Delete(i);
      //Log(richeditdialog.Lines[i]);
    end  
  end;
  
  
  for I := 0 to RichEditDialog.Lines.Count - 1 do
  begin
    if pos(#9, RichEditDialog.Lines[i]) = 0 then
      //if i < RichEditDialog.Lines.Count - 1 then //not the last line which is junk chars (only in unpatched)
        Log('Warning: Tab character not found on line ' + inttostr(i + 1));
  end;

  Log('...file check complete.');
  richeditdialog.WordWrap:=true;
end;

procedure TformMain.MemoLogURLClick(Sender: TObject; const URLText: string;
  Button: TMouseButton);
begin
  shellexec(0, 'open', URLText,'', '', SW_SHOWNORMAL);
end;

procedure TformMain.ParseFile;
type
  TBuffer = array of byte;
var
  memstream: tmemorystream;
  Buffer: ^TBuffer;
  BufferSize: longint;
  Size: integer;
begin
  thefile.Position:=4; //4 byte header
  size:=thefile.Size - 4;

  memstream:=tmemorystream.Create;
  GetMem(Buffer,size);
  try
    BufferSize := Size;

    thefile.ReadBuffer(Buffer^, Buffersize);
    memstream.write(Buffer^, Buffersize);

    memstream.Position:=0;
    richeditDialog.Lines.LoadFromStream(memstream);

    //44 byes at end junk
  finally
    memstream.Free;
    FreeMem(Buffer, size);
  end;
end;



end.
