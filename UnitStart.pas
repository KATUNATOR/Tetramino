unit UnitStart;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, jpeg, ExtCtrls;

type
  TFormStart = class(TForm)
    imgTetra: TImage;
    imgPlay: TImage;
    imgHelp: TImage;
    imgExit: TImage;
    procedure imgPlayClick(Sender: TObject);
    procedure imgHelpClick(Sender: TObject);
    procedure imgExitClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormStart: TFormStart;

implementation

uses UnitGame, UnitHelp;

{$R *.dfm}

//------------------------------------------------------------------------------
//  ИГРАТь
//------------------------------------------------------------------------------
procedure TFormStart.imgPlayClick(Sender: TObject);
begin
  FormStart.Hide;         //спрятать Стартовую форму
  FormGame.Show;          //показать Игровую форму
  FormGame.mniSize.Click; //запустить пункт меню Игровой формы: Настройки-Буквы
end;

//------------------------------------------------------------------------------
//  СПРАВКА
//------------------------------------------------------------------------------
procedure TFormStart.imgHelpClick(Sender: TObject);
begin
  formhelp.visible:=True; //показать спраку
end;

//------------------------------------------------------------------------------
//  ВЫХОД
//------------------------------------------------------------------------------
procedure TFormStart.imgExitClick(Sender: TObject);
begin
  Close; //закрыть Стартовую форму
end;

end.
