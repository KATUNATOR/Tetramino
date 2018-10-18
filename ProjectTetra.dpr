program ProjectTetra;

uses
  Forms,
  UnitGame in 'UnitGame.pas' {FormGame},
  UnitStart in 'UnitStart.pas' {FormStart},
  UnitHelp in 'C:\Users\Администратор\Desktop\UnitHelp.pas' {FormHelp};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFormStart, FormStart);
  Application.CreateForm(TFormGame, FormGame);
  Application.CreateForm(TFormHelp, FormHelp);
  Application.Run;
end.
