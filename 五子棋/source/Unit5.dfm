object Form5: TForm5
  Left = 0
  Top = 0
  Caption = #20116#23376#26827' - TStringGrid + GDI+'
  ClientHeight = 640
  ClientWidth = 620
  Color = clBtnFace
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'Microsoft YaHei'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  TextHeight = 21
  object PanelBottom: TPanel
    Left = 0
    Top = 592
    Width = 620
    Height = 48
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    ExplicitTop = 591
    ExplicitWidth = 616
    object lblStatus: TLabel
      Left = 330
      Top = 14
      Width = 64
      Height = 21
      Caption = #40657#26827#22238#21512
    end
    object btnNewGame: TButton
      Left = 16
      Top = 8
      Width = 90
      Height = 33
      Caption = #26032#23616
      TabOrder = 0
      OnClick = btnNewGameClick
    end
    object btnUndo: TButton
      Left = 116
      Top = 8
      Width = 90
      Height = 33
      Caption = #24724#26827
      TabOrder = 1
      OnClick = btnUndoClick
    end
    object chkAI: TCheckBox
      Left = 220
      Top = 15
      Width = 100
      Height = 21
      Caption = #20154#26426#23545#25112
      TabOrder = 2
      OnClick = chkAIClick
    end
  end
  object GridBoard: TStringGrid
    Left = 0
    Top = 0
    Width = 620
    Height = 592
    Align = alClient
    ColCount = 15
    DefaultDrawing = False
    DoubleBuffered = True
    FixedCols = 0
    RowCount = 15
    FixedRows = 0
    GridLineWidth = 0
    Options = []
    ParentDoubleBuffered = False
    ScrollBars = ssNone
    TabOrder = 1
    OnDrawCell = GridBoardDrawCell
    OnMouseUp = GridBoardMouseUp
    ExplicitWidth = 616
    ExplicitHeight = 591
  end
  object AITimer: TTimer
    Enabled = False
    Interval = 300
    OnTimer = AITimerTimer
    Left = 576
    Top = 8
  end
end
