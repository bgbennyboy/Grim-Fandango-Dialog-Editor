{
******************************************************
  Grim Fandango Dialog Editor
  Copyright (c) 2006 Bgbennyboy
  Http://quick.mixnmojo.com
******************************************************
}

program GrimFandango_DialogEditor;

uses
  Forms,
  frmMain in 'frmMain.pas' {formMain};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Grim Fandango Dialog Editor';
  Application.CreateForm(TformMain, formMain);
  Application.Run;
end.
