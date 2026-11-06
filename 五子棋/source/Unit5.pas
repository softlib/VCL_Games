unit Unit5;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.Grids, Vcl.StdCtrls, Vcl.ExtCtrls, System.Generics.Collections,
  Winapi.GDIPAPI, Winapi.GDIPOBJ;

const
  BoardSize  = 15;
  CellEmpty  = 0;
  CellBlack  = 1;
  CellWhite  = 2;

type
  TPlayer = (plNone, plBlack, plWhite);

  TForm5 = class(TForm)
    GridBoard: TStringGrid;
    PanelBottom: TPanel;
    lblStatus: TLabel;
    btnNewGame: TButton;
    btnUndo: TButton;
    chkAI: TCheckBox;
    AITimer: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure GridBoardDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure GridBoardMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure btnNewGameClick(Sender: TObject);
    procedure btnUndoClick(Sender: TObject);
    procedure chkAIClick(Sender: TObject);
    procedure AITimerTimer(Sender: TObject);
  private
    FBoard: array[0..BoardSize - 1, 0..BoardSize - 1] of Byte;
    FCurrentPlayer: TPlayer;
    FGameOver: Boolean;
    FAIMode: Boolean;
    FHistory: TList<Integer>;

    procedure InitBoard;
    procedure UpdateStatus;
    procedure UpdateCellSize;

    procedure PlacePiece(ACol, ARow: Integer; APlayer: TPlayer);
    procedure UndoOne;
    function  CheckWin(ACol, ARow, APiece: Byte): Boolean;
    function  EvaluatePoint(ACol, ARow, APiece: Byte): Integer;

    function  IsHumanTurn: Boolean;
    function  IsAITurn: Boolean;
    procedure AIMove;
  end;

var
  Form5: TForm5;

implementation

{$R *.dfm}

const
  Directions: array[0..3] of TPoint = (
    (X: 1; Y: 0),
    (X: 0; Y: 1),
    (X: 1; Y: 1),
    (X: 1; Y: -1)
  );

function MinInt(A, B: Integer): Integer; inline;
begin
  if A < B then Result := A else Result := B;
end;

{ TForm5 }

procedure TForm5.FormCreate(Sender: TObject);
begin
  FHistory := TList<Integer>.Create;
  FAIMode := False;
  FGameOver := False;
  FCurrentPlayer := plBlack;

  DoubleBuffered := True;
  GridBoard.DoubleBuffered := True;
  GridBoard.DefaultDrawing := False;
  GridBoard.FixedCols := 0;
  GridBoard.FixedRows := 0;
  GridBoard.RowCount := BoardSize;
  GridBoard.ColCount := BoardSize;
  GridBoard.ScrollBars := ssNone;
  GridBoard.GridLineWidth := 0;
  GridBoard.Options := [];
  GridBoard.TabStop := False;

  UpdateCellSize;
  InitBoard;
end;

procedure TForm5.FormDestroy(Sender: TObject);
begin
  FHistory.Free;
end;

procedure TForm5.FormResize(Sender: TObject);
begin
  UpdateCellSize;
  GridBoard.Invalidate;
end;

procedure TForm5.UpdateCellSize;
var
  i, cw, ch, remW, remH: Integer;
begin
  if (GridBoard.ClientWidth <= 0) or (GridBoard.ClientHeight <= 0) then Exit;
  cw := GridBoard.ClientWidth div BoardSize;
  ch := GridBoard.ClientHeight div BoardSize;
  if cw < 10 then cw := 10;
  if ch < 10 then ch := 10;
  remW := GridBoard.ClientWidth - cw * BoardSize;
  remH := GridBoard.ClientHeight - ch * BoardSize;
  for i := 0 to BoardSize - 1 do
  begin
    GridBoard.ColWidths[i] := cw;
    GridBoard.RowHeights[i] := ch;
  end;
  if remW > 0 then
    GridBoard.ColWidths[BoardSize - 1] := GridBoard.ColWidths[BoardSize - 1] + remW;
  if remH > 0 then
    GridBoard.RowHeights[BoardSize - 1] := GridBoard.RowHeights[BoardSize - 1] + remH;
end;

procedure TForm5.InitBoard;
begin
  FillChar(FBoard, SizeOf(FBoard), 0);
  FHistory.Clear;
  FCurrentPlayer := plBlack;
  FGameOver := False;
  AITimer.Enabled := False;
  UpdateStatus;
  GridBoard.Invalidate;
end;

procedure TForm5.UpdateStatus;
begin
  if FGameOver then
    lblStatus.Caption := '游戏结束'
  else if FCurrentPlayer = plBlack then
    lblStatus.Caption := '黑棋回合'
  else
    lblStatus.Caption := '白棋回合';
end;

{ ---------- 绘制 ---------- }

procedure TForm5.GridBoardDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  G: TGPGraphics;
  BackgroundBrush: TGPSolidBrush;
  GridPen: TGPPen;
  PieceBrush: TGPLinearGradientBrush;
  PiecePen: TGPPen;
  CX, CY, Radius, Size: Integer;
  Piece: Byte;
begin
  if (ACol < 0) or (ACol >= BoardSize) or (ARow < 0) or (ARow >= BoardSize) then Exit;

  G := TGPGraphics.Create(GridBoard.Canvas.Handle);
  try
    G.SetSmoothingMode(SmoothingModeAntiAlias);

    // 1. 单元格木色背景
    BackgroundBrush := TGPSolidBrush.Create(MakeColor(255, 222, 184, 135));
    try
      G.FillRectangle(BackgroundBrush,
        MakeRect(Rect.Left, Rect.Top, Rect.Width, Rect.Height));
    finally
      BackgroundBrush.Free;
    end;

    // 2. 格线（单元格十字，相邻格自然衔接成棋盘线）
    GridPen := TGPPen.Create(MakeColor(160, 120, 80, 40), 1);
    try
      CX := Rect.Left + Rect.Width div 2;
      CY := Rect.Top + Rect.Height div 2;
      G.DrawLine(GridPen, CX, Rect.Top, CX, Rect.Bottom);
      G.DrawLine(GridPen, Rect.Left, CY, Rect.Right, CY);
    finally
      GridPen.Free;
    end;

    // 3. 棋子（径向近似：用对角线性渐变模拟高光）
    Piece := FBoard[ACol, ARow];
    if Piece <> CellEmpty then
    begin
      CX := Rect.Left + Rect.Width div 2;
      CY := Rect.Top + Rect.Height div 2;
      Radius := MinInt(Rect.Width, Rect.Height) div 2 - 3;
      if Radius < 3 then Radius := 3;
      Size := Radius * 2;

      if Piece = CellBlack then
      begin
        PieceBrush := TGPLinearGradientBrush.Create(
          MakeRect(CX - Radius, CY - Radius, Size, Size),
          MakeColor(255, 110, 110, 110),
          MakeColor(255, 0, 0, 0),
          LinearGradientModeForwardDiagonal);
        PiecePen := TGPPen.Create(MakeColor(255, 0, 0, 0), 1);
        try
          G.FillEllipse(PieceBrush, CX - Radius, CY - Radius, Size, Size);
          G.DrawEllipse(PiecePen,  CX - Radius, CY - Radius, Size, Size);
        finally
          PieceBrush.Free;
          PiecePen.Free;
        end;
      end
      else
      begin
        PieceBrush := TGPLinearGradientBrush.Create(
          MakeRect(CX - Radius, CY - Radius, Size, Size),
          MakeColor(255, 255, 255, 255),
          MakeColor(255, 200, 200, 200),
          LinearGradientModeForwardDiagonal);
        PiecePen := TGPPen.Create(MakeColor(255, 120, 120, 120), 1);
        try
          G.FillEllipse(PieceBrush, CX - Radius, CY - Radius, Size, Size);
          G.DrawEllipse(PiecePen,  CX - Radius, CY - Radius, Size, Size);
        finally
          PieceBrush.Free;
          PiecePen.Free;
        end;
      end;
    end;
  finally
    G.Free;
  end;
end;

{ ---------- 鼠标落子 ---------- }

procedure TForm5.GridBoardMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  Col, Row: Longint;
begin
  if FGameOver then Exit;
  if Button <> mbLeft then Exit;
  if not IsHumanTurn then Exit;

  GridBoard.MouseToCell(X, Y, Col, Row);
  if (Col < 0) or (Col >= BoardSize) or (Row < 0) or (Row >= BoardSize) then Exit;
  if FBoard[Col, Row] <> CellEmpty then Exit;

  PlacePiece(Col, Row, FCurrentPlayer);
end;

procedure TForm5.PlacePiece(ACol, ARow: Integer; APlayer: TPlayer);
var
  Piece: Byte;
begin
  if APlayer = plBlack then Piece := CellBlack else Piece := CellWhite;
  FBoard[ACol, ARow] := Piece;
  FHistory.Add(ACol * BoardSize + ARow);
  GridBoard.Invalidate;

  if CheckWin(ACol, ARow, Piece) then
  begin
    FGameOver := True;
    UpdateStatus;
    if Piece = CellBlack then
      ShowMessage('黑棋获胜！')
    else
      ShowMessage('白棋获胜！');
    Exit;
  end;

  if FHistory.Count >= BoardSize * BoardSize then
  begin
    FGameOver := True;
    UpdateStatus;
    ShowMessage('平局！');
    Exit;
  end;

  if FCurrentPlayer = plBlack then
    FCurrentPlayer := plWhite
  else
    FCurrentPlayer := plBlack;

  UpdateStatus;

  if IsAITurn then
    AITimer.Enabled := True;
end;

{ ---------- 胜负判断 ---------- }

function TForm5.CheckWin(ACol, ARow, APiece: Byte): Boolean;
var
  d, Count: Integer;
  C, R: Integer;
begin
  Result := False;
  for d := 0 to 3 do
  begin
    Count := 1;

    C := ACol + Directions[d].X;
    R := ARow + Directions[d].Y;
    while (C >= 0) and (C < BoardSize) and (R >= 0) and (R < BoardSize)
      and (FBoard[C, R] = APiece) do
    begin
      Inc(Count);
      Inc(C, Directions[d].X);
      Inc(R, Directions[d].Y);
    end;

    C := ACol - Directions[d].X;
    R := ARow - Directions[d].Y;
    while (C >= 0) and (C < BoardSize) and (R >= 0) and (R < BoardSize)
      and (FBoard[C, R] = APiece) do
    begin
      Inc(Count);
      Dec(C, Directions[d].X);
      Dec(R, Directions[d].Y);
    end;

    if Count >= 5 then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

{ ---------- AI ---------- }

function TForm5.IsHumanTurn: Boolean;
begin
  Result := (not FAIMode) or (FCurrentPlayer = plBlack); // 人执黑
end;

function TForm5.IsAITurn: Boolean;
begin
  Result := FAIMode and (FCurrentPlayer = plWhite);      // AI 执白
end;

function TForm5.EvaluatePoint(ACol, ARow, APiece: Byte): Integer;
var
  d, Count, Blocked: Integer;
  C, R: Integer;
begin
  Result := 0;
  for d := 0 to 3 do
  begin
    Count := 1;
    Blocked := 0;

    C := ACol + Directions[d].X;
    R := ARow + Directions[d].Y;
    while (C >= 0) and (C < BoardSize) and (R >= 0) and (R < BoardSize) do
    begin
      if FBoard[C, R] = APiece then Inc(Count)
      else
      begin
        if FBoard[C, R] <> CellEmpty then Inc(Blocked);
        Break;
      end;
      Inc(C, Directions[d].X);
      Inc(R, Directions[d].Y);
    end;

    C := ACol - Directions[d].X;
    R := ARow - Directions[d].Y;
    while (C >= 0) and (C < BoardSize) and (R >= 0) and (R < BoardSize) do
    begin
      if FBoard[C, R] = APiece then Inc(Count)
      else
      begin
        if FBoard[C, R] <> CellEmpty then Inc(Blocked);
        Break;
      end;
      Dec(C, Directions[d].X);
      Dec(R, Directions[d].Y);
    end;

    if Count >= 5 then
      Inc(Result, 100000)             // 五连
    else if Count = 4 then
    begin
      if Blocked = 0 then Inc(Result, 10000)   // 活四
      else if Blocked = 1 then Inc(Result, 5000); // 冲四
    end
    else if Count = 3 then
    begin
      if Blocked = 0 then Inc(Result, 1000)    // 活三
      else if Blocked = 1 then Inc(Result, 100); // 眠三
    end
    else if Count = 2 then
    begin
      if Blocked = 0 then Inc(Result, 100)     // 活二
      else if Blocked = 1 then Inc(Result, 10);  // 眠二
    end
    else
      Inc(Result, 1);
  end;
end;

procedure TForm5.AIMove;
var
  C, R, Score, BestScore, BestC, BestR: Integer;
  AIPiece, HumanPiece: Byte;
  Found: Boolean;

  function FindForcedMove(Piece: Byte; out OutC, OutR: Integer): Boolean;
  var
    CC, RR: Integer;
  begin
    Result := False;
    for CC := 0 to BoardSize - 1 do
      for RR := 0 to BoardSize - 1 do
        if FBoard[CC, RR] = CellEmpty then
          if EvaluatePoint(CC, RR, Piece) >= 100000 then
          begin
            OutC := CC;
            OutR := RR;
            Result := True;
            Exit;
          end;
  end;

begin
  if FCurrentPlayer = plBlack then
  begin
    AIPiece := CellBlack;
    HumanPiece := CellWhite;
  end
  else
  begin
    AIPiece := CellWhite;
    HumanPiece := CellBlack;
  end;

  // 1) AI 能立即获胜
  if FindForcedMove(AIPiece, BestC, BestR) then
  begin
    PlacePiece(BestC, BestR, FCurrentPlayer);
    Exit;
  end;

  // 2) 立即封堵人类五连
  if FindForcedMove(HumanPiece, BestC, BestR) then
  begin
    PlacePiece(BestC, BestR, FCurrentPlayer);
    Exit;
  end;

  // 3) 综合评分选点（进攻略强于防守）
  BestScore := -1;
  BestC := -1;
  BestR := -1;
  Found := False;
  for C := 0 to BoardSize - 1 do
    for R := 0 to BoardSize - 1 do
      if FBoard[C, R] = CellEmpty then
      begin
        Score := Round(EvaluatePoint(C, R, AIPiece) * 1.2)
               + EvaluatePoint(C, R, HumanPiece);
        if (not Found) or (Score > BestScore) then
        begin
          BestScore := Score;
          BestC := C;
          BestR := R;
          Found := True;
        end;
      end;

  if Found then
    PlacePiece(BestC, BestR, FCurrentPlayer);
end;

procedure TForm5.AITimerTimer(Sender: TObject);
begin
  AITimer.Enabled := False;
  if (not FGameOver) and IsAITurn then
    AIMove;
end;

{ ---------- 悔棋 ---------- }

procedure TForm5.UndoOne;
var
  Last, C, R: Integer;
begin
  if FHistory.Count = 0 then Exit;
  Last := FHistory.Last;
  FHistory.Delete(FHistory.Count - 1);
  C := Last div BoardSize;
  R := Last mod BoardSize;
  FBoard[C, R] := CellEmpty;
  if FCurrentPlayer = plBlack then
    FCurrentPlayer := plWhite
  else
    FCurrentPlayer := plBlack;
end;

procedure TForm5.btnUndoClick(Sender: TObject);
begin
  AITimer.Enabled := False; // 取消待执行的 AI
  if FHistory.Count = 0 then Exit;

  if FAIMode then
  begin
    if Odd(FHistory.Count) then
      UndoOne                     // 最后一步是玩家：只撤一步
    else
    begin
      UndoOne;                    // 撤 AI
      UndoOne;                    // 撤玩家
    end;
  end
  else
    UndoOne;

  FGameOver := False;
  UpdateStatus;
  GridBoard.Invalidate;
end;

{ ---------- 按钮 ---------- }

procedure TForm5.btnNewGameClick(Sender: TObject);
begin
  if MessageDlg('确定开始新局？', mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;
  InitBoard;
end;

procedure TForm5.chkAIClick(Sender: TObject);
begin
  FAIMode := chkAI.Checked;
  if FAIMode and (not FGameOver) and IsAITurn then
    AITimer.Enabled := True;
end;

{ ---------- GDI+ 初始化 ---------- }

var
  GdiplusToken: ULONG_PTR = 0;

initialization
  begin
    var SI: TGdiplusStartupInput;
    SI.GdiplusVersion := 1;
    SI.DebugEventCallback := nil;
    SI.SuppressBackgroundThread := False;
    SI.SuppressExternalCodecs := False;
    GdiplusStartup(GdiplusToken, @SI, nil);
  end;

finalization
  if GdiplusToken <> 0 then
    GdiplusShutdown(GdiplusToken);

end.