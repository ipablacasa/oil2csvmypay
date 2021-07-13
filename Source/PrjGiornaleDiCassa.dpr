program PrjGiornaleDiCassa;

uses
  Vcl.Forms,
  FrmMain in 'FrmMain.pas' {FrmPrincipale};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmPrincipale, FrmPrincipale);
  Application.Run;
end.
