object Form1: TForm1
  Left = 0
  Top = 0
  Caption = '中国象棋 - TPaintBox + GDI+'
  ClientHeight = 720
  ClientWidth = 620
  Color = clBtnFace
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'Microsoft YaHei'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 21
  object PanelBottom: TPanel
    Left = 0
    Top = 672
    Width = 620
    Height = 48
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    object lblStatus: TLabel
      Left = 330
      Top = 14
      Width = 100
      Height = 21
      Caption = '红方走棋'
    end
    object btnNewGame: TButton
      Left = 16
      Top = 8
      Width = 90
      Height = 33
      Caption = '新局'
      TabOrder = 0
      OnClick = btnNewGameClick
    end
    object btnUndo: TButton
      Left = 116
      Top = 8
      Width = 90
      Height = 33
      Caption = '悔棋'
      TabOrder = 1
      OnClick = btnUndoClick
    end
    object chkAI: TCheckBox
      Left = 220
      Top = 15
      Width = 100
      Height = 21
      Caption = '人机对战'
      TabOrder = 2
      OnClick = chkAIClick
    end
  end
  object PaintBoard: TPaintBox
    Left = 0
    Top = 0
    Width = 620
    Height = 672
    Align = alClient
    OnMouseUp = PaintBoardMouseUp
    OnPaint = PaintBoardPaint
  end
  object AITimer: TTimer
    Enabled = False
    Interval = 400
    OnTimer = AITimerTimer
    Left = 576
    Top = 8
  end
end