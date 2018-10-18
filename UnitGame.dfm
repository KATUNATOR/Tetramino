object FormGame: TFormGame
  Left = 601
  Top = 296
  Width = 212
  Height = 166
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  Caption = #1058#1077#1090#1088#1072
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = mmBase
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object lblN: TLabel
    Left = 32
    Top = 40
    Width = 117
    Height = 23
    Caption = #1057#1090#1088#1086#1095#1082#1080' (N) :'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object lblM: TLabel
    Left = 24
    Top = 72
    Width = 123
    Height = 23
    Caption = #1057#1090#1086#1083#1073#1094#1099' (M) :'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object sgIn: TStringGrid
    Left = 0
    Top = 32
    Width = 33
    Height = 33
    ColCount = 1
    DefaultColWidth = 30
    DefaultRowHeight = 30
    FixedCols = 0
    RowCount = 1
    FixedRows = 0
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goEditing, goAlwaysShowEditor]
    TabOrder = 1
    Visible = False
    OnKeyPress = sgInKeyPress
    OnSetEditText = sgInSetEditText
  end
  object sg: TStringGrid
    Left = 0
    Top = 0
    Width = 33
    Height = 33
    ColCount = 6
    DefaultColWidth = 30
    DefaultRowHeight = 30
    FixedCols = 0
    RowCount = 6
    FixedRows = 0
    ScrollBars = ssNone
    TabOrder = 0
    OnClick = sgClick
    OnDrawCell = sgDrawCell
  end
  object btnOkSize: TBitBtn
    Left = 0
    Top = 0
    Width = 193
    Height = 32
    TabOrder = 2
    Visible = False
    OnClick = btnOkSizeClick
    Kind = bkOK
  end
  object btnOkLetter: TBitBtn
    Left = 0
    Top = 0
    Width = 193
    Height = 32
    TabOrder = 3
    Visible = False
    OnClick = btnOkLetterClick
    Kind = bkOK
  end
  object edtN: TEdit
    Left = 152
    Top = 40
    Width = 40
    Height = 21
    TabOrder = 4
    Visible = False
  end
  object edtM: TEdit
    Left = 152
    Top = 72
    Width = 40
    Height = 21
    TabOrder = 5
    Visible = False
  end
  object mmBase: TMainMenu
    Left = 248
    Top = 8
    object NGame: TMenuItem
      Caption = #1048#1075#1088#1072
      object mniNewGame: TMenuItem
        Caption = #1053#1086#1074#1072#1103' '#1080#1075#1088#1072
        OnClick = mniNewGameClick
      end
      object mniReset: TMenuItem
        Caption = #1047#1072#1085#1086#1074#1086
        OnClick = mniResetClick
      end
      object mniAutoRes: TMenuItem
        Caption = #1040#1074#1090#1086#1088#1077#1096#1077#1085#1080#1077
        OnClick = mniAutoResClick
      end
      object mniBack: TMenuItem
        Caption = #1053#1072#1079#1072#1076' '#1074' '#1084#1077#1085#1102
        OnClick = mniBackClick
      end
    end
    object NSettings: TMenuItem
      Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1080
      object mniSize: TMenuItem
        Caption = #1056#1072#1079#1084#1077#1088
        OnClick = mniSizeClick
      end
      object mniLetters: TMenuItem
        Caption = #1041#1091#1082#1074#1099
        OnClick = mniLettersClick
      end
    end
    object NHepl: TMenuItem
      Caption = #1057#1087#1088#1072#1074#1082#1072
      OnClick = NHeplClick
    end
  end
  object xpmnfst1: TXPManifest
    Left = 216
    Top = 8
  end
end
