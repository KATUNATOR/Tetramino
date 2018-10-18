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
//  ������
//------------------------------------------------------------------------------
procedure TFormStart.imgPlayClick(Sender: TObject);
begin
  FormStart.Hide;         //�������� ��������� �����
  FormGame.Show;          //�������� ������� �����
  FormGame.mniSize.Click; //��������� ����� ���� ������� �����: ���������-�����
end;

//------------------------------------------------------------------------------
//  �������
//------------------------------------------------------------------------------
procedure TFormStart.imgHelpClick(Sender: TObject);
begin
  formhelp.visible:=True; //�������� ������
end;

//------------------------------------------------------------------------------
//  �����
//------------------------------------------------------------------------------
procedure TFormStart.imgExitClick(Sender: TObject);
begin
  Close; //������� ��������� �����
end;

end.
