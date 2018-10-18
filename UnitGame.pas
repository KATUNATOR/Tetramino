unit UnitGame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, StdCtrls, Menus, Buttons, XPMan;

type
  TFormGame = class(TForm)
    sg: TStringGrid;       //������� ��� ����
    sgIn: TStringGrid;     //������� ��� ��������� ����
    mmBase: TMainMenu;     //����
    NGame: TMenuItem;      //����-����
    mniNewGame: TMenuItem; //����-����-����� ����
    mniAutoRes: TMenuItem; //����-����-�����������
    mniReset: TMenuItem;   //����-����-������
    mniBack: TMenuItem;    //����-����-����� � ����
    NSettings: TMenuItem;  //����-���������
    mniSize: TMenuItem;    //����-���������-������
    mniLetters: TMenuItem; //����-���������-�����
    NHepl: TMenuItem;      //����-�������
    btnOkSize: TBitBtn;    //������ ������������� ��������
    btnOkLetter: TBitBtn;  //������ ������������� ����
    edtN: TEdit;           //���� ���������� ������� (N)
    edtM: TEdit;           //���� ���������� �������� (M)
    lblN: TLabel;          //������� ���������� ������� (N)
    lblM: TLabel;          //������� ���������� �������� (M)
    xpmnfst1: TXPManifest; //��������� ��� ������������ ����������
    procedure sgDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure sgClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure mniNewGameClick(Sender: TObject);
    procedure mniResetClick(Sender: TObject);
    procedure mniAutoResClick(Sender: TObject);
    procedure mniSizeClick(Sender: TObject);
    procedure mniLettersClick(Sender: TObject);
    procedure sgInKeyPress(Sender: TObject; var Key: Char);
    procedure sgInSetEditText(Sender: TObject; ACol, ARow: Integer;
      const Value: String);
    procedure btnOkLetterClick(Sender: TObject);
    procedure btnOkSizeClick(Sender: TObject);
    procedure mniBackClick(Sender: TObject);
    procedure NHeplClick(Sender: TObject);

  private
    { Private declarations }
  public

    { Public declarations }
  end;

var
  FormGame: TFormGame;

implementation

uses UnitStart, UnitHelp;

{$R *.dfm}

type
  // ������ ��� ��������� ������������ (������ ������)
  TPer = array[0..18] of byte;

  // ������ ��� ����� ������
  // ������ 6 ��������� ��������� 3 �������� ������������ ����� �������
  TF=record
    i1:   Integer;
    j1:   Integer;
    i2:   Integer;
    j2:   Integer;
    i3:   Integer;
    j3:   Integer;
    jmin: Integer; // ����� ����� ��������
    jmax: Integer; // ����� ������ ��������
    imax: Integer; // ����� ������ ��������
    t:    Integer; // ��� ������ (�� 1 �� 5)
  end;

  // ������ ��� ������ � ���� 19-�� �����
  TFig=array[0..18] of TF;

  // ������ � ����������� ������
  TMatFig=record
    k: Byte; // ���� ������ (�� 1 �� 19)
    l: Byte; // �����, ������������� ���� ������ (�� 1 �� 5)
    i: Byte; // (���������� i ��� ������� ��������)
    j: Byte; // (���������� j ��� ������� ��������)
  end;

  // ������ � ���� ����� ����� � ������
  TLetType=record
    inf: Byte;      // ���� �� �����/���
    count: Integer; // ������� ����� ���� �������
  end;

  // ������
  TMas=array of array of integer;

  // ������ �� ������� ������� (����)
  TMat=record
    af: TMas; // ������� � ��������
    al: TMas; // ������� � �������
    f: array of TMatFig; // ������ � ������������ ��������
    l: array[0..4] of TLetType; // ������ � ������ ����� ��� ����
    t: array[0..4] of TLetType; // ������ � ������� ��� ����� �����
    fcount: Integer; // ������� ����� ��������
  end;

  // ������ � ������ �� ����
  TClick=record
    a: TMas; // ������� � ����������� ����������, ��� ��� ����
    i:array[0..3] of Integer; // ���������� i ��� ������� �����
    j:array[0..3] of Integer; // ���������� j ��� ������� �����
    count:           Integer; // ������� ������ ����
  end;

var
  now,res:  TMat;         // ������� ����, ���� ��� ������ �������
  cl:       TClick;       // ����� �� ����
  fig:      TFig;         // ��� ������ �� 1 �� 19
  n:        Integer = 6;  // ���-�� �������
  m:        Integer = 6;  // ���-�� ��������
  rcount:   Integer;      // ���-�� ��������� �����������
  lcount:   Integer;      // ���-�� ���� �� ����
  rnow:     Integer;      // ������� ��������� ��� �����������
  fLet:     Boolean;      // ���� �������� ���� ��� �����������
  fStop:    Boolean;      // ���� ��� ������ �� �������� �����������

//------------------------------------------------------------------------------
//  ��� ������ (�� 1 �� 19) �� ����� (�� 1 �� 5)
//------------------------------------------------------------------------------

{
//---1

1

   11
   11

//---2

2

   2222

3

   2
   2
   2
   2

//---3

4

   33
    33

5

    33
   33

6

    3
   33
   3

7

   3
   33
    3

//---4

8

    4
   444

9

   4
   44
   4

10

   444
    4

11

    4
   44
    4

//---5

12

     5
   555

13

   55
    5
    5

14

   555
   5

15

   5
   5
   55

16

   5
   555

17

   55
   5
   5

18

   555
     5

19

    5
    5
   55
}

//------------------------------------------------------------------------------
// ������������� ���� ����� (�� 1 �� 19)
//------------------------------------------------------------------------------
procedure IniFig(var fig:TFig);
//��������� �� ��������������� ��������������� �����
var
  f:file of TF;
  i,j:Integer;
begin
  Assign(f,'data\figs.dat');
  Reset(f);
  for i:=0 to 18 do
    read(f,fig[i]);
  Close(f);
end;

//------------------------------------------------------------------------------
// ������������� ������
//------------------------------------------------------------------------------
procedure IniClick(var cl:TClick);
var
  x:byte;
begin
  SetLength(cl.a,n,m);
  cl.count:=0;
  for x:=0 to 3 do
  begin
    //������� ����� �� �������
    cl.a[cl.i[x],cl.j[x]]:=0;
    //����������� ��������� �� �����
    FormGame.sg.Cells[cl.j[x],cl.i[x]]:=FormGame.sg.Cells[cl.j[x],cl.i[x]];
    //��������� ���������
    cl.i[x]:=0;
    cl.j[x]:=0;
  end;
end;

//------------------------------------------------------------------------------
// ��������� ����� ������������ (�� 0 �� 18)
//------------------------------------------------------------------------------
procedure IniPer(var mas:TPer);
var
  i,j,num:Byte;
begin
  //������ � ������������������� �� 0 �� 18
  for i:=0 to 18 do
    mas[i]:=i;

  //������ ������� ��������� ������ 19 ���
  for i:=0 to 18 do
  begin
    Randomize;
    j:=Random(19);
    num:=mas[i];
    mas[i]:=mas[j];
    mas[j]:=num;
  end;
end;

//------------------------------------------------------------------------------
// ������������� ������� ����
//------------------------------------------------------------------------------
procedure IniMat(var mat:TMat; n,m:byte);
var
  i,j:integer;
begin

//������������� �������� ���� ��� ������ ����

  FormGame.sg.ColCount:=m;
  FormGame.sg.RowCount:=n;

  FormGame.sg.Width:=m*(formgame.sg.DefaultColWidth+1)+5;
  FormGame.sg.Height:=n*(formgame.sg.DefaultRowHeight+2)+5;

  formgame.Width:=FormGame.sg.Left+FormGame.sg.Width+15;
  FormGame.Height:=FormGame.sg.Top+FormGame.sg.Height+55;
  if FormGame.Width<200 then FormGame.Width:=200;

//��������� ��������� ������� ���� (������)

  SetLength(mat.af,n,m);
  for i:=0 to n-1 do
    for j:=0 to m-1 do
    begin
      mat.af[i,j]:=0;
      //����������� ��������� �� �����
      FormGame.sg.Cells[j,i]:=FormGame.sg.Cells[j,i];
    end;

  for i:=0 to 4 do
  begin
    mat.l[i].inf:=0;
    mat.l[i].count:=0;
    mat.t[i].inf:=0;
    mat.t[i].count:=0;
  end;

  SetLength(mat.f,0);
  mat.fcount:=0;
end;

//------------------------------------------------------------------------------
// ������������� ���������� �������
//------------------------------------------------------------------------------
procedure IniRandom(var mat:TMat; n,m:byte);
//�� �������� ���� (res) �� ������������ �������� �������� ������������ �����
var
  i,j,r,lc,t:Integer;
  let:array [0..4] of Byte;
  fin: Text;
  f:file of TMatFig;
  fg:TMatFig;
begin

//��������� ��������� ������� ���� (�����)

  setlength(mat.al,n,m);
  for i:=0 to n-1 do
    for j:=0 to m-1 do
    begin
      mat.al[i,j]:=0;
    end;

  for i:=0 to 4 do
    let[i]:=0;

  //���-�� ������������ ����
  lc:=0;

  //��������� �������������� ������������ ���� (res)
  AssignFile(f,'data\input.dat');
  Reset(f);

  //���������� ����� ������ ����������� ������ � ����
  while not Eof(f) do
  begin
    read(f,fg);

    t:=fig[fg.k-1].t;
    i:=fg.i;
    j:=fg.j;
    //��������� l ���, �.�. ����������� ������������� ��������� ����� ��� ����

    //���� ��� ����� ���� ����� ��� �� ��������� �����, �� �����������
    if let[t-1]=0 then
    begin
      Inc(lc);
      let[t-1]:=lc;
    end;

    //��������� ���������� ������������ ����� �� ����� �� 4 �������� ������
    r:=Random(4);
    case r of
      1:  begin i:=i+fig[fg.k-1].i1; j:=j+fig[fg.k-1].j1; end;
      2:  begin i:=i+fig[fg.k-1].i2; j:=j+fig[fg.k-1].j2; end;
      3:  begin i:=i+fig[fg.k-1].i3; j:=j+fig[fg.k-1].j3; end;
    end;

    //���������� ������� ����
    mat.al[i,j]:=let[t-1];
  end;       

  //��������� ����
  Close(f);

  //��������� �� ����� ���� � �������
  for i:=0 to n-1 do
    for j:=0 to m-1 do
    begin
      case now.al[i,j] of
        1: FormGame.sg.Cells[j,i]:='A';
        2: FormGame.sg.Cells[j,i]:='B';
        3: FormGame.sg.Cells[j,i]:='C';
        4: FormGame.sg.Cells[j,i]:='D';
        5: FormGame.sg.Cells[j,i]:='E';
        0: FormGame.sg.Cells[j,i]:='';
      end;
    end;

  //��������� ��� �� ���� � ������������ � �������������� ������ �� �����

  Assign(fin,'data\input.txt');
  Rewrite(fin);
  Writeln(fin,n,' ',m);

  for i:=0 to n-1 do
  begin
    for j:=0 to m-1 do
      write(fin,mat.al[i,j],' ');
    Writeln(fin);
  end;

  Close(fin);
end;

//------------------------------------------------------------------------------
// �������� �� ������
//------------------------------------------------------------------------------
function CheckFig(mas:TMas; i,j,k,inf:integer):Boolean;
begin
  CheckFig:=False;

  //�� ������� �� �� ����� �������?
  if j+fig[k].jmin>-1 then
    //�� ������� �� �� ������ �������?
    if j+fig[k].jmax<m then
      //�� ������� �� �� ������ �������?
      if i+fig[k].imax<n then
        //��������� �� �������� ������� ��������?
        if mas[i,j]=inf then
          //��������� �� �������� ������ ��������?
          if mas[i+fig[k].i1,j+fig[k].j1]=inf then
            //��������� �� �������� ������ ��������?
            if mas[i+fig[k].i2,j+fig[k].j2]=inf then
              //��������� �� �������� ��������� ��������?
              if mas[i+fig[k].i3,j+fig[k].j3]=inf then
                //������ ����� ���� ���������
                Checkfig:=True;
end;

//------------------------------------------------------------------------------
// �������� �� �����
//------------------------------------------------------------------------------
function CheckLet(mat:TMat; i,j,k:integer):Byte;
var
  let,count:Integer;
begin
  checklet:=0;

  let:=0;
  count:=0;

  //���� �� ����� � ������� ��������?
  if mat.al[i,j]<>0 then
  begin
    Inc(count);
    let:=mat.al[i,j];
  end;

  //���� �� ����� �� ������ ��������?
  if mat.al[i+fig[k].i1,j+fig[k].j1]<>0 then
  begin
    Inc(count);
    let:=mat.al[i+fig[k].i1,j+fig[k].j1];
  end;

  //���� �� ����� � ������� ��������?
  if mat.al[i+fig[k].i2,j+fig[k].j2]<>0 then
  begin
    Inc(count);
    let:=mat.al[i+fig[k].i2,j+fig[k].j2];
  end;

  //���� �� ����� � ��������� ��������?
  if mat.al[i+fig[k].i3,j+fig[k].j3]<>0 then
  begin
    Inc(count);
    let:=mat.al[i+fig[k].i3,j+fig[k].j3];
  end;

  //������ ���� ����� �� ������?
  if count=1 then
    //�� ������ �� ��� ����� ��� ������ ����� ������?
    if ((mat.t[fig[k].t-1].inf=let) and (mat.l[let-1].inf=fig[k].t)) or
     //��� �� ����� �� ���� ��� ������ ������ ������?
     ((mat.t[fig[k].t-1].count=0) and (mat.l[let-1].count=0)) then
      //������ ����� ���� ���������
      checklet:=let;
end;

//------------------------------------------------------------------------------
// ����������/�������� ������
//------------------------------------------------------------------------------
procedure NewFig(var mat:TMat; i,j,k:integer; set_reset:Boolean);
// set_reset: true-��������, false-�������
var
  val,c:Integer;
begin
  if set_reset then
  begin
    //��������� ������ � ����������� ������
    inc(mat.fcount);
    Inc(mat.t[fig[k].t-1].count);
    c:=mat.fcount;
    SetLength(mat.f,c);
    mat.f[c-1].k:=k+1;
    mat.f[c-1].i:=i;
    mat.f[c-1].j:=j;

    //�������� �������� ������ �� ���� ���������� ��� ��� �������
    val:=c;
  end
  else
  begin
    //������� ������ � ��������� ������
    Dec(mat.fcount);
    c:=mat.fcount;
    SetLength(mat.f,c);
    Dec(mat.t[fig[k].t-1].count);

    //�������� �������� ������ �� ���� "0"
    val:=0;
  end;

  //��������� ������ ��������� �������� ������ �� ����
  mat.af[i,j]:=val;
  mat.af[i+fig[k].i1,j+fig[k].j1]:=val;
  mat.af[i+fig[k].i2,j+fig[k].j2]:=val;
  mat.af[i+fig[k].i3,j+fig[k].j3]:=val;

  //���������� ��������� �� �����
  FormGame.sg.Cells[j,i]:=FormGame.sg.Cells[j,i];
  FormGame.sg.Cells[j+fig[k].j1,i+fig[k].i1]:=FormGame.sg.Cells[j+fig[k].j1,i+fig[k].i1];
  FormGame.sg.Cells[j+fig[k].j2,i+fig[k].i2]:=FormGame.sg.Cells[j+fig[k].j2,i+fig[k].i2];
  FormGame.sg.Cells[j+fig[k].j3,i+fig[k].i3]:=FormGame.sg.Cells[j+fig[k].j3,i+fig[k].i3];
end;

//------------------------------------------------------------------------------
// ����������/�������� �����
//------------------------------------------------------------------------------
procedure NewLet(var mat:TMat; k,let:integer; set_reset:Boolean);
// set_reset: true-��������, false-�������
begin
  if set_reset then
  begin
    //��������� ������ � ����������� �����
    Inc(mat.l[let-1].count);
    mat.l[let-1].inf:=fig[k].t;
    mat.t[fig[k].t-1].inf:=let;
    mat.f[mat.fcount-1].l:=let;
  end
  else
  begin
    //������� ������ � ��������� ������
    Dec(mat.l[let-1].count);
  end;
end;

//------------------------------------------------------------------------------
// ������� ���������
//------------------------------------------------------------------------------
procedure OutRes(mat:TMat; var rcount:integer; var fstop:Boolean);
var
  s:string;
  i,j:Byte;
  f: file of TMatFig;
  fout: Text;
begin
  if fLet then
  begin
    //��� ����������
    s:='results\'+inttostr(rcount);
    Inc(rcount);
  end
  else
  begin
    //��� �������
    s:='data\input';
    //���������� �����
    fStop:=True;
  end;

  //������� ���� ��� ������
  Assign(fout,s+'.txt');
  rewrite(fout);

  //�������� ������� ���� � ���������
  for i:=0 to n-1 do
  begin
    for j:=0 to m-1 do
      write(fout,mat.af[i,j],' ');
    writeln(fout);
  end;

  //�������� ����� ��� ����� � ���� ��� ����
  for i:=0 to 4 do
  begin
    write(fout,now.t[i].inf,' ');
    write(fout,now.t[i].count,' ');
    write(fout,now.l[i].inf,' ');
    write(fout,now.l[i].count,' ');
  end;

  //������� ����
  close(fout);

  //������� �������������� ���� ��� ������
  assign(f,s+'.dat');
  rewrite(f);

  //�������� ��� ������ �� ����
  for i:=0 to mat.fcount-1 do
    write(f,mat.f[i]);

  //������� ����
  close(f);
end;

//------------------------------------------------------------------------------
// �����������
//------------------------------------------------------------------------------
procedure GetRes(var mat:TMat; i,j:Byte);
var
  k,p,let,lf,fl:Byte;
  per: TPer;
begin
  if i<n then
    if j<m then
      //���� ������ �� ������ ������ �������
      if mat.af[i,j]=0 then
      begin
        //������� ������������ � �������� �����
        iniPer(per);
        for p:=0 to 18 do
        begin
          k:=per[p];
          //������� k-�� ������
          if (CheckFig(mat.af,i,j,k,0)) and (not fStop) then
          begin
            //��������, ����� ���� �������� �� ����� ������� (�����������)
            if fLet then
            begin
              let:=CheckLet(mat,i,j,k);
              if let<>0 then
              //�������� ������
              begin
                NewFig(mat,i,j,k,True);
                NewLet(mat,k,let,True);
              end
              //�� ������, ������ ������� ���������
              else
                Continue;
            end
            //����� ������ ��������� �������
            else
              NewFig(mat,i,j,k,True);

            //��������� �� ���� ��������� ���������?
            if mat.fcount=(n*m div 4) then
              //������� ���������
              OutRes(mat,rcount,fStop)
            else
              //������� ��������� ��������� ������ ��������
              GetRes(mat,i,j+1);

            //���������� �� �������� ������� ���� �� �������/����

            if fLet then
              NewLet(mat,k,let,False);

            NewFig(mat,i,j,k,False);

            //������� ������ ��������
          end;
        end;
      end
      //��������� �� ������� ������
      else
        GetRes(mat,i,j+1)
    //��������� �� ������� ����
    else
      GetRes(mat,i+1,0);
end;

//------------------------------------------------------------------------------
// ��������� ���������
//------------------------------------------------------------------------------
procedure LoadRes(var mat:TMat; var rnow:integer);
var
  i,j:Integer;
  s:string;
  fin:text;
  f:file of TMatFig;
begin
  if rcount=0 then
  begin
    ShowMessage('������� �� ������� ;�');
    Exit;
  end;

  //���� ���������� �������� ������������� ���������� ������ �� ����������,
  //�� ������������ � ������� ���������� � ���� �� �����
  if rnow>rcount then rnow:=1;

  s:='results\'+inttostr(rnow);
  Inc(rnow);

  now.fcount:=n*m div 4;
  SetLength(now.f, now.fcount);

  //������ �� ��������������� ����� ���� ������� � ����
  assign(f,s+'.dat');
  reset(f);
  for i:=0 to now.fcount-1 do
    read(f,now.f[i]);
  close(f);

  //������ ���� � ���������
  Assign(fin,s+'.txt');
  reset(fin);
  for i:=0 to n-1 do
    for j:=0 to m-1 do
    begin
      read(fin,now.af[i,j]);
      FormGame.sg.Cells[j,i]:=FormGame.sg.Cells[j,i];
    end;
  //������ ����� ������� � ������� � ���� � ������ �������
  for i:=0 to 4 do
  begin
    read(fin,now.t[i].inf);
    read(fin,now.t[i].count);
    read(fin,now.l[i].inf);
    read(fin,now.l[i].count);
  end;
  close(fin);
end;

//------------------------------------------------------------------------------
// ���������� ������� ����
//------------------------------------------------------------------------------
procedure TFormGame.sgDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  i,j,k:Integer;
begin
  j:=ACol;
  i:=ARow;

  with sg do
    with Canvas do
    begin
      //�������� � �������
      if now.af[i,j]>0 then
      begin
        k:=now.f[now.af[i,j]-1].k-1;

        //� ����������� �� ���� ���������� ����
        case fig[k].t of
          1: Brush.Color:=clYellow;
          2: Brush.Color:=clAqua;
          3: Brush.Color:=clRed;
          4: Brush.Color:=clLime;
          5: Brush.Color:=clPurple;
        end;

        FillRect(Rect);
        TextOut(Rect.Left+2, Rect.Top+2, cells[j,i]);

        //��������� ����� � ��������� ��� ���������� ������ �������
        with pen do
        begin
          Color:=clblack;
          width:=3;
        end;

        if i<>0 then
          //���� ������ ������ ������
          if now.af[i,j]<>now.af[i-1,j] then
          begin
            moveto(Rect.Left,Rect.Top);
            LineTo(Rect.Right,Rect.Top);
          end;

        if i<>n-1 then
          //���� ����� ������ ������
          if now.af[i,j]<>now.af[i+1,j] then
          begin
            moveto(Rect.Left,Rect.Bottom);
            LineTo(Rect.Right,Rect.Bottom);
          end;

        if j<>0 then
          //���� ����� ������ ������
          if now.af[i,j]<>now.af[i,j-1] then
          begin
            moveto(Rect.Left,Rect.Top);
            LineTo(Rect.Left,Rect.Bottom);
          end;

        if j<>n-1 then
          //���� ������ ������ ������
          if now.af[i,j]<>now.af[i,j+1] then
          begin
            moveto(Rect.Right,Rect.Top);
            LineTo(Rect.Right,Rect.Bottom);
          end;
      end
      else
        //������ ��������, �� ���������
        if cl.a[i,j]=1 then
        begin
          //��������� �����
          Brush.Color:=clGray;
          FillRect(Rect);
          TextOut(Rect.Left+2, Rect.Top+2, cells[j,i]);
        end;
    end;
end;

//------------------------------------------------------------------------------
// ���� �� ����
//------------------------------------------------------------------------------
procedure TFormGame.sgClick(Sender: TObject);
var
  i,j,k,ii,jj,x,l,let,inf:Integer;
begin
  i:=sg.Row;
  j:=sg.Col;
  inf:=now.af[i,j];

  //����� �� ��������?
  if inf=0 then
  begin
    //�� ���� �� ��� �������� �������� ������?
    if cl.a[i,j]=0 then
    begin
      cl.a[i,j]:=1;
      sg.Cells[j,i]:=sg.Cells[j,i];
      Inc(cl.count);

      cl.i[cl.count-1]:=i;
      cl.j[cl.count-1]:=j;

      //���� ���� 4-�� � ��������������
      if cl.count=4 then
      begin
        ii:=cl.i[0];
        jj:=cl.j[0];

        //����������� ������� �������� � ���������� �������
        for x:=1 to 3 do
          if (cl.i[x]<ii) or ((cl.i[x]=ii) and (cl.j[x]<jj)) then
          begin
            ii:=cl.i[x];
            jj:=cl.j[x];
          end;

        //������� �������� ����� �������, ��� � ����������
        for k:=0 to 18 do
          //������, � ��������� ������ ���� "1", � �� ���� ����� ��������
          if CheckFig(cl.a,ii,jj,k,1) then
            begin
              //�������� �����
              let:=CheckLet(now,ii,jj,k);
              if let<>0 then
                begin
                  NewFig(now,ii,jj,k,True);
                  NewLet(now,k,let,True);
                  if now.fcount=n*m div 4 then
                    ShowMessage('������!!!');
                  Break;
                end;
            end;

        //������� �����
        IniClick(cl);
      end;
    end;  
  end
  //�������� ������ �������, ������ ������� �
  else
  begin
    ii:=now.f[inf-1].i;
    jj:=now.f[inf-1].j;
    k:=now.f[inf-1].k-1;
    l:=now.f[inf-1].l;;

    for i:=inf-1 to now.fcount-2 do
      now.f[i]:=now.f[i+1];

    for i:=0 to n-1 do
      for j:=0 to m-1 do
        if now.af[i,j]>inf then
          Dec(now.af[i,j]);

    NewLet(now,k,l,False);
    NewFig(now,ii,jj,k,False);
  end;
end;

//------------------------------------------------------------------------------
// FORM CREATE
//------------------------------------------------------------------------------
procedure TFormGame.FormCreate(Sender: TObject);
begin
  IniFig(fig);
  //���������� �������
  mniNewGame.Click;
end;

//------------------------------------------------------------------------------
// ����-����-����� ����
//------------------------------------------------------------------------------
procedure TFormGame.mniNewGameClick(Sender: TObject);
begin
  rcount:=0;
  rnow:=1;

  //���������� ���� (res) ��� �����������
  fLet:=False;
  fStop:=False;
  IniMat(res,n,m);

  //����������� ��� ����� ����, ������ ��������� ������� �� ����
  GetRes(res,0,0);

  //���������� ���� (now), ��������� ���� �� ������� ��������� �������, ������
  fLet:=True;
  fStop:=False;
  IniMat(now,n,m);
  IniRandom(now,n,m);
  IniClick(cl);
end;

//------------------------------------------------------------------------------
// ����-����-������
//------------------------------------------------------------------------------
procedure TFormGame.mniResetClick(Sender: TObject);
begin
  rnow:=1;
  rcount:=0;

  //������� ���� � ������
  IniMat(now,n,m);
  IniClick(cl);
end;

//------------------------------------------------------------------------------
// ����-����-�����������
//------------------------------------------------------------------------------
procedure TFormGame.mniAutoResClick(Sender: TObject);
begin
  //���� ����������� ��� �� �������������
  if now.fcount < (n*m div 4) then
  begin
    rcount:=0;
    rnow:=1;
    GetRes(now,0,0);
  end;

  //�������� �����������
  LoadRes(now,rnow);
end;

//------------------------------------------------------------------------------
// ����-����-����� � ����
//------------------------------------------------------------------------------
procedure TFormGame.mniBackClick(Sender: TObject);
begin
  //�������� ������� �����
  FormGame.Hide;
  //�������� ��������� �����
  FormStart.Show;
end;

//------------------------------------------------------------------------------
// ����-���������-������
//------------------------------------------------------------------------------
procedure TFormGame.mniSizeClick(Sender: TObject);
begin
  //������� ����, ��������� ������ "��"
  FormGame.Menu:=nil;
  edtN.Visible:=True;
  edtm.Visible:=True;
  lblN.Visible:=True;
  lblM.Visible:=true;
  btnOkSize.Visible:=True;
  sg.Visible:=false;

  Width:=210;
  Height:=140;

  edtn.text:=inttostr(n);
  edtm.text:=inttostr(m);
end;

//------------------------------------------------------------------------------
// ����-���������-������: ��
//------------------------------------------------------------------------------
procedure TFormGame.btnOkSizeClick(Sender: TObject);
var
  nn,mm:Integer;
begin
  if edtN.Text <> '' then
    nn:=StrToInt(edtN.text);

  if edtM.Text <> '' then
    mm:=StrToInt(edtm.text);

  //�������� ���� �������
  if edtN.Text = '' then
    ShowMessage('������� N!')
  else if edtM.Text = '' then
    ShowMessage('������� M!')
  else if nn<=0 then
    ShowMessage('������� (N) ������ ���� �� ������ 2!')
  else if mm<=0 then
    ShowMessage('��������� (M) ������ ���� �� ������ 2!')
  else if nn>12 then
    ShowMessage('������� (N) ������ ���� �� ������ 12!')
  else if mm>12 then
    ShowMessage('��������� (M) ������ ���� �� ������ 12!')
  else if nn*mm <> Abs(nn*mm div 4)*4 then
    ShowMessage('���������� �������� (N*M) ������ ���� ������ 4-�!!!')
  else
  begin
    n:=StrToInt(edtN.text);
    m:=StrToInt(edtM.text);
  end;

  edtN.Visible:=False;
  edtm.Visible:=False;
  lblN.Visible:=False;
  lblM.Visible:=False;
  btnOkSize.Visible:=False;
  sg.Visible:=True;

  FormGame.Menu:=mmBase;

  //���������� ������� ��� ������ ������� ����
  FormGame.mniNewGame.Click;
end;

//------------------------------------------------------------------------------
// ����-���������-�����
//------------------------------------------------------------------------------
procedure TFormGame.mniLettersClick(Sender: TObject);
var
  i,j:integer;
begin
  //������� ����, ��������� ������ "��"
  FormGame.Menu:=nil;
  sgin.ColCount:=sg.ColCount;
  sgin.RowCount:=sg.RowCount;

  //����������� ���� � ���� � �������
  for i:=0 to n-1 do
    for j:=0 to m-1 do
      if now.al[i,j]=0 then
        sgIn.Cells[j,i]:=''
      else
        sgIn.Cells[j,i]:=IntToStr(now.al[i,j]);

  sgin.Width:=sg.Width;
  sgin.Height:=sg.Height;

  btnOkLetter.Visible:=True;
  btnOkLetter.Width:=sg.Width;

  sgIn.Visible:=true;
  sg.Visible:=False;
end;

//------------------------------------------------------------------------------
// ����-���������-�����: ���� �� 1 �� 5
//------------------------------------------------------------------------------
procedure TFormGame.sgInKeyPress(Sender: TObject; var Key: Char);
begin
  //������ �� ���� �������� ����� [1,2,3,4,5]
  If not (Key in ['1'..'5', #8]) then
    Key:=#0;
end;

//------------------------------------------------------------------------------
// ����-���������-�����: ���� �� ������ 1-�� �����
//------------------------------------------------------------------------------
procedure TFormGame.sgInSetEditText(Sender: TObject; ACol, ARow: Integer;
  const Value: String);
begin
  //������ �� ���� ������ ��� ����� �����
  if Value<>'' then
    if StrToInt(sgIn.Cells[ACol,ARow])>5 then
      sgin.Cells[ACol,ARow]:=Value[1];
end;

//------------------------------------------------------------------------------
// ����-���������-�����: ��
//------------------------------------------------------------------------------
procedure TFormGame.btnOkLetterClick(Sender: TObject);
var
  i,j:Integer;
  f:textfile;
begin
  lcount:=0;

  //������� ���� � ����
  for i:=0 to n-1 do
    for j:=0 to m-1 do
    begin
      if sgin.Cells[j,i] <> '' then
        inc(lcount);
    end;

  //�������� �� ������������ ���-�� ����������� ���� � �������
  if lcount=n*m div 4 then
  begin
    //���������� ����
    for i:=0 to n-1 do
      for j:=0 to m-1 do
      begin
        if sgin.cells[j,i]<>'' then
          now.al[i,j]:=StrToInt(sgin.cells[j,i])
        else
          now.al[i,j]:=0;

        case now.al[i,j] of
          1: FormGame.sg.Cells[j,i]:='A';
          2: FormGame.sg.Cells[j,i]:='B';
          3: FormGame.sg.Cells[j,i]:='C';
          4: FormGame.sg.Cells[j,i]:='D';
          5: FormGame.sg.Cells[j,i]:='E';
          0: FormGame.sg.Cells[j,i]:='';
        end;
      end;
    Application.ProcessMessages;
  end
  else
    ShowMessage('���������� ���� ������ ���� ����� ���������� �����! (N*M/4)');

  FormGame.Menu:=mmBase;
  sgIn.Visible:=False;
  sg.Visible:=True;
  btnOkLetter.Visible:=False;
  IniMat(now,n,m);
end;

procedure TFormGame.NHeplClick(Sender: TObject);
begin
  formhelp.visible:=true;
end;

end.
