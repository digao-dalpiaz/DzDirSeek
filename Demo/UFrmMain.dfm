object FrmMain: TFrmMain
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'DzDirSeek Demo'
  ClientHeight = 546
  ClientWidth = 761
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 16
    Width = 26
    Height = 13
    Caption = 'Path:'
  end
  object Label4: TLabel
    Left = 120
    Top = 256
    Width = 56
    Height = 13
    Caption = 'Files found:'
  end
  object LbCount: TLabel
    Left = 184
    Top = 256
    Width = 12
    Height = 13
    Caption = '---'
  end
  object EdDir: TEdit
    Left = 16
    Top = 32
    Width = 689
    Height = 21
    TabOrder = 0
    Text = 'C:\'
  end
  object BtnPath: TButton
    Left = 712
    Top = 30
    Width = 33
    Height = 25
    Caption = '...'
    TabOrder = 1
    TabStop = False
    OnClick = BtnPathClick
  end
  object CkSorted: TCheckBox
    Left = 512
    Top = 216
    Width = 97
    Height = 17
    Caption = 'Sort results'
    TabOrder = 7
  end
  object CkSubDir: TCheckBox
    Left = 16
    Top = 64
    Width = 161
    Height = 17
    Caption = 'Include sub-directories'
    Checked = True
    State = cbChecked
    TabOrder = 2
  end
  object GroupBox1: TGroupBox
    Left = 16
    Top = 96
    Width = 481
    Height = 145
    TabOrder = 4
    object Label2: TLabel
      Left = 16
      Top = 16
      Width = 51
      Height = 13
      Caption = 'Inclusions:'
    end
    object Label3: TLabel
      Left = 248
      Top = 16
      Width = 53
      Height = 13
      Caption = 'Exclusions:'
    end
    object EdInc: TMemo
      Left = 16
      Top = 32
      Width = 217
      Height = 97
      Lines.Strings = (
        '*.exe'
        '*.dll')
      ScrollBars = ssVertical
      TabOrder = 0
    end
    object EdExc: TMemo
      Left = 248
      Top = 32
      Width = 217
      Height = 97
      Lines.Strings = (
        'Windows\*'
        'Users\*'
        'ProgramData\*')
      ScrollBars = ssVertical
      TabOrder = 1
    end
  end
  object CkUseMasks: TCheckBox
    Left = 24
    Top = 88
    Width = 73
    Height = 17
    Caption = 'Use Masks'
    Checked = True
    State = cbChecked
    TabOrder = 3
  end
  object RgResultKind: TRadioGroup
    Left = 512
    Top = 88
    Width = 233
    Height = 89
    Caption = 'Result kind'
    ItemIndex = 0
    Items.Strings = (
      'Complete'
      'Relative'
      'Only name')
    TabOrder = 5
  end
  object EdResult: TMemo
    Left = 16
    Top = 288
    Width = 729
    Height = 241
    Color = clInfoBk
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Consolas'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 11
  end
  object BtnSeek: TButton
    Left = 16
    Top = 248
    Width = 75
    Height = 25
    Caption = 'Seek'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 10
    OnClick = BtnSeekClick
  end
  object CkHiddenFiles: TCheckBox
    Left = 624
    Top = 192
    Width = 121
    Height = 17
    Caption = 'Search Hidden Files'
    TabOrder = 8
  end
  object CkSystemFiles: TCheckBox
    Left = 624
    Top = 216
    Width = 129
    Height = 17
    Caption = 'Search System Files'
    TabOrder = 9
  end
  object CkDirItem: TCheckBox
    Left = 512
    Top = 192
    Width = 97
    Height = 17
    Caption = 'Include Dir Item'
    TabOrder = 6
  end
  object DS: TDzDirSeek
    Left = 424
    Top = 56
  end
end
