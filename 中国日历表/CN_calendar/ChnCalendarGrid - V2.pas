unit ChnCalendarGrid;

interface

uses
  System.SysUtils, System.Classes, System.Types, System.UITypes, System.Math,
  System.DateUtils,
  Winapi.Windows, Winapi.Messages,Vcl.StdCtrls,
  Vcl.Controls, Vcl.Grids, Vcl.Graphics, Vcl.Forms,
  Vcl.Imaging.PngImage, Vcl.Imaging.jpeg,
  ChnCalendarUse, NCalendar;

type
  TCalendarImageLayout = (cilStretch, cilCenter, cilTile, cilFit);

  TCalendarDayDrawEvent = procedure(Sender: TObject; ADate: TDateTime;
    ACol, ARow: Integer; const ARect: TRect; ACanvas: TCanvas;
    var ADefaultDraw: Boolean) of object;

  TChnCalendarGrid = class(TDrawGrid)
  private
    FBackgroundPicture : TPicture;
    FBackgroundColor   : TColor;
    FBackgroundAlpha   : Byte;
    FBackgroundLayout  : TCalendarImageLayout;

    FHeaderColor       : TColor;
    FHeaderFont        : TFont;
    FDayFont           : TFont;
    FSubFont           : TFont;
    FDayTextColor      : TColor;
    FWeekendTextColor  : TColor;
    FOtherMonthTextColor : TColor;
    FTodayColor        : TColor;
    FSelectedColor     : TColor;
    FOtherMonthColor   : TColor;
    FHolidayColor      : TColor;
    FSolarTermColor    : TColor;
    FLunarColor        : TColor;
    FGridLineColor     : TColor;

    FShowLunar         : Boolean;
    FShowHoliday       : Boolean;
    FShowSolarTerm     : Boolean;

    FCurrentMonth      : TDateTime;
    FSelectedDate      : TDateTime;

    FOnSelectedDateChanged : TNotifyEvent;
    FOnMonthChanged        : TNotifyEvent;
    FOnDrawDayCell         : TCalendarDayDrawEvent;

    FBuffer            : TBitmap;
    FAlphaBmp          : TBitmap;
    FSyncing           : Boolean;

    procedure SetBackgroundPicture(AValue: TPicture);
    procedure SetBackgroundColor(AValue: TColor);
    procedure SetBackgroundAlpha(AValue: Byte);
    procedure SetBackgroundLayout(AValue: TCalendarImageLayout);
    procedure SetHeaderColor(AValue: TColor);
    procedure SetHeaderFont(AValue: TFont);
    procedure SetDayFont(AValue: TFont);
    procedure SetSubFont(AValue: TFont);
    procedure SetDayTextColor(AValue: TColor);
    procedure SetWeekendTextColor(AValue: TColor);
    procedure SetOtherMonthTextColor(AValue: TColor);
    procedure SetTodayColor(AValue: TColor);
    procedure SetSelectedColor(AValue: TColor);
    procedure SetOtherMonthColor(AValue: TColor);
    procedure SetHolidayColor(AValue: TColor);
    procedure SetSolarTermColor(AValue: TColor);
    procedure SetLunarColor(AValue: TColor);
    procedure SetGridLineColor(AValue: TColor);
    procedure SetShowLunar(AValue: Boolean);
    procedure SetShowHoliday(AValue: Boolean);
    procedure SetShowSolarTerm(AValue: Boolean);
    procedure SetSelectedDate(AValue: TDateTime);
    procedure SetCurrentMonth(AValue: TDateTime);

    procedure FontChanged(Sender: TObject);
    procedure PictureChanged(Sender: TObject);

    function  GetFirstCellDate: TDateTime;
    function  CellDate(ACol, ARow: Integer): TDateTime;
    function  FindCellByDate(ADate: TDateTime; out ACol, ARow: Integer): Boolean;

    procedure SyncGridSize;
    procedure DrawTo(ACanvas: TCanvas);
    procedure DrawBackground(ACanvas: TCanvas);
    procedure DrawBackgroundImage(ACanvas: TCanvas);
    procedure DrawHeaderCell(ACanvas: TCanvas; ACol: Integer; const ARect: TRect);
    procedure DrawDayCell(ACanvas: TCanvas; ADate: TDateTime;
      ACol, ARow: Integer; const ARect: TRect);
    procedure DrawGridLines(ACanvas: TCanvas);
    procedure FillRectAlpha(ACanvas: TCanvas; const ARect: TRect;
      AColor: TColor; AAlpha: Byte);

    function  GetFestivalText(ADate: TDateTime; ALunarMonth, ALunarDay: Integer;
      AIsLeap: Boolean): string;
    function  LunarMonthName(AMonth: Integer; AIsLeap: Boolean): string;

  protected
    procedure Paint; override;
    procedure Resize; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure WMMouseWheel(var Msg: TWMMouseWheel); message WM_MOUSEWHEEL;
    // 不再重写 CreateWnd，由 Resize 处理布局

  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;

    procedure PrevMonth;
    procedure NextMonth;
    procedure PrevYear;
    procedure NextYear;
    procedure GoToToday;

  published
    property BackgroundPicture: TPicture
      read FBackgroundPicture write SetBackgroundPicture;
    property BackgroundColor: TColor
      read FBackgroundColor write SetBackgroundColor default clWhite;
    property BackgroundAlpha: Byte
      read FBackgroundAlpha write SetBackgroundAlpha default 255;
    property BackgroundLayout: TCalendarImageLayout
      read FBackgroundLayout write SetBackgroundLayout default cilStretch;

    property HeaderColor: TColor
      read FHeaderColor write SetHeaderColor default $00F0E8DD;
    property HeaderFont: TFont read FHeaderFont write SetHeaderFont;
    property DayFont: TFont read FDayFont write SetDayFont;
    property SubFont: TFont read FSubFont write SetSubFont;

    property DayTextColor: TColor
      read FDayTextColor write SetDayTextColor default clBlack;
    property WeekendTextColor: TColor
      read FWeekendTextColor write SetWeekendTextColor default clRed;
    property OtherMonthTextColor: TColor
      read FOtherMonthTextColor write SetOtherMonthTextColor default clGray;
    property TodayColor: TColor
      read FTodayColor write SetTodayColor default $0090F0A0;
    property SelectedColor: TColor
      read FSelectedColor write SetSelectedColor default $00F0C080;
    property OtherMonthColor: TColor
      read FOtherMonthColor write SetOtherMonthColor default clWhite;
    property HolidayColor: TColor
      read FHolidayColor write SetHolidayColor default clRed;
    property SolarTermColor: TColor
      read FSolarTermColor write SetSolarTermColor default clGreen;
    property LunarColor: TColor
      read FLunarColor write SetLunarColor default $00707030;
    property GridLineColor: TColor
      read FGridLineColor write SetGridLineColor default $00E0E0E0;

    property ShowLunar: Boolean
      read FShowLunar write SetShowLunar default True;
    property ShowHoliday: Boolean
      read FShowHoliday write SetShowHoliday default True;
    property ShowSolarTerm: Boolean
      read FShowSolarTerm write SetShowSolarTerm default True;

    property SelectedDate: TDateTime
      read FSelectedDate write SetSelectedDate;
    property CurrentMonth: TDateTime
      read FCurrentMonth write SetCurrentMonth;

    property OnSelectedDateChanged: TNotifyEvent
      read FOnSelectedDateChanged write FOnSelectedDateChanged;
    property OnMonthChanged: TNotifyEvent
      read FOnMonthChanged write FOnMonthChanged;
    property OnDrawDayCell: TCalendarDayDrawEvent
      read FOnDrawDayCell write FOnDrawDayCell;
  end;

procedure Register;

implementation

constructor TChnCalendarGrid.Create(AOwner: TComponent);
var
  D: TDateTime;
begin
  inherited Create(AOwner);

  DoubleBuffered := True;
  ScrollBars     := ssNone;
  FixedCols      := 0;
  FixedRows      := 0;
  DefaultDrawing := False;
  ColCount       := 7;
  RowCount       := 7;
  Options        := Options - [goEditing, goTabs, goRowMoving,
                               goColMoving, goRowSelect, goAlwaysShowEditor];
  BorderStyle    := bsSingle;
  Color          := clWhite;

  // ★ 关键修复 1：给控件一个非零默认大小，避免 ClientWidth/Height 为 0 时布局异常
  if Width  < 280 then Width  := 280;
  if Height < 200 then Height := 200;

  FBuffer := TBitmap.Create;
  FBuffer.PixelFormat := pf24bit;

  FAlphaBmp := TBitmap.Create;
  FAlphaBmp.PixelFormat := pf32bit;
  FAlphaBmp.SetSize(1, 1);

  FBackgroundPicture := TPicture.Create;
  FBackgroundPicture.OnChange := PictureChanged;

  FHeaderFont := TFont.Create;
  FHeaderFont.Name  := 'Microsoft YaHei UI';
  FHeaderFont.Size  := 10;
  FHeaderFont.Style := [fsBold];
  FHeaderFont.OnChange := FontChanged;

  FDayFont := TFont.Create;
  FDayFont.Name  := 'Microsoft YaHei UI';
  FDayFont.Size  := 16;
  FDayFont.Style := [fsBold];
  FDayFont.OnChange := FontChanged;

  FSubFont := TFont.Create;
  FSubFont.Name := 'Microsoft YaHei UI';
  FSubFont.Size := 8;
  FSubFont.OnChange := FontChanged;

  FBackgroundColor     := clWhite;
  FBackgroundAlpha     := 255;
  FBackgroundLayout    := cilStretch;
  FHeaderColor         := $00F0E8DD;
  FDayTextColor        := clBlack;
  FWeekendTextColor    := clRed;
  FOtherMonthTextColor := clGray;
  FTodayColor          := $0090F0A0;
  FSelectedColor       := $00F0C080;
  FOtherMonthColor     := clWhite;
  FHolidayColor        := clRed;
  FSolarTermColor      := clGreen;
  FLunarColor          := $00707030;
  FGridLineColor       := $00E0E0E0;

  FShowLunar     := True;
  FShowHoliday   := True;
  FShowSolarTerm := True;

  D := Date;
  FCurrentMonth := EncodeDate(YearOf(D), MonthOf(D), 1);
  FSelectedDate := D - Frac(D);
end;

destructor TChnCalendarGrid.Destroy;
begin
  FBuffer.Free;
  FAlphaBmp.Free;
  FBackgroundPicture.Free;
  FHeaderFont.Free;
  FDayFont.Free;
  FSubFont.Free;
  inherited;
end;

{ ---------- setters ---------- }

procedure TChnCalendarGrid.SetBackgroundPicture(AValue: TPicture);
begin
  FBackgroundPicture.Assign(AValue);
end;

procedure TChnCalendarGrid.SetBackgroundColor(AValue: TColor);
begin
  if FBackgroundColor <> AValue then
  begin
    FBackgroundColor := AValue;
    Invalidate;
  end;
end;

procedure TChnCalendarGrid.SetBackgroundAlpha(AValue: Byte);
begin
  if FBackgroundAlpha <> AValue then
  begin
    FBackgroundAlpha := AValue;
    Invalidate;
  end;
end;

procedure TChnCalendarGrid.SetBackgroundLayout(AValue: TCalendarImageLayout);
begin
  if FBackgroundLayout <> AValue then
  begin
    FBackgroundLayout := AValue;
    Invalidate;
  end;
end;

procedure TChnCalendarGrid.SetHeaderColor(AValue: TColor);
begin
  if FHeaderColor <> AValue then
  begin FHeaderColor := AValue; Invalidate; end;
end;

procedure TChnCalendarGrid.SetHeaderFont(AValue: TFont);
begin FHeaderFont.Assign(AValue); Invalidate; end;

procedure TChnCalendarGrid.SetDayFont(AValue: TFont);
begin FDayFont.Assign(AValue); Invalidate; end;

procedure TChnCalendarGrid.SetSubFont(AValue: TFont);
begin FSubFont.Assign(AValue); Invalidate; end;

procedure TChnCalendarGrid.SetDayTextColor(AValue: TColor);
begin
  if FDayTextColor <> AValue then
  begin FDayTextColor := AValue; Invalidate; end;
end;

procedure TChnCalendarGrid.SetWeekendTextColor(AValue: TColor);
begin
  if FWeekendTextColor <> AValue then
  begin FWeekendTextColor := AValue; Invalidate; end;
end;

procedure TChnCalendarGrid.SetOtherMonthTextColor(AValue: TColor);
begin
  if FOtherMonthTextColor <> AValue then
  begin FOtherMonthTextColor := AValue; Invalidate; end;
end;

procedure TChnCalendarGrid.SetTodayColor(AValue: TColor);
begin
  if FTodayColor <> AValue then
  begin FTodayColor := AValue; Invalidate; end;
end;

procedure TChnCalendarGrid.SetSelectedColor(AValue: TColor);
begin
  if FSelectedColor <> AValue then
  begin FSelectedColor := AValue; Invalidate; end;
end;

procedure TChnCalendarGrid.SetOtherMonthColor(AValue: TColor);
begin
  if FOtherMonthColor <> AValue then
  begin FOtherMonthColor := AValue; Invalidate; end;
end;

procedure TChnCalendarGrid.SetHolidayColor(AValue: TColor);
begin
  if FHolidayColor <> AValue then
  begin FHolidayColor := AValue; Invalidate; end;
end;

procedure TChnCalendarGrid.SetSolarTermColor(AValue: TColor);
begin
  if FSolarTermColor <> AValue then
  begin FSolarTermColor := AValue; Invalidate; end;
end;

procedure TChnCalendarGrid.SetLunarColor(AValue: TColor);
begin
  if FLunarColor <> AValue then
  begin FLunarColor := AValue; Invalidate; end;
end;

procedure TChnCalendarGrid.SetGridLineColor(AValue: TColor);
begin
  if FGridLineColor <> AValue then
  begin FGridLineColor := AValue; Invalidate; end;
end;

procedure TChnCalendarGrid.SetShowLunar(AValue: Boolean);
begin
  if FShowLunar <> AValue then
  begin FShowLunar := AValue; Invalidate; end;
end;

procedure TChnCalendarGrid.SetShowHoliday(AValue: Boolean);
begin
  if FShowHoliday <> AValue then
  begin FShowHoliday := AValue; Invalidate; end;
end;

procedure TChnCalendarGrid.SetShowSolarTerm(AValue: Boolean);
begin
  if FShowSolarTerm <> AValue then
  begin FShowSolarTerm := AValue; Invalidate; end;
end;

procedure TChnCalendarGrid.SetSelectedDate(AValue: TDateTime);
var
  NewSel: TDateTime;
begin
  // ★ 关键修复 2：先把浮点日期归一化为整日，避免精度带来的隐式 Range check
  NewSel := AValue - Frac(AValue);
  if FSelectedDate <> NewSel then
  begin
    FSelectedDate := NewSel;
    if (YearOf(NewSel) <> YearOf(FCurrentMonth)) or
       (MonthOf(NewSel) <> MonthOf(FCurrentMonth)) then
    begin
      FCurrentMonth := EncodeDate(YearOf(NewSel), MonthOf(NewSel), 1);
      if Assigned(FOnMonthChanged) then FOnMonthChanged(Self);
    end;
    Invalidate;
    if Assigned(FOnSelectedDateChanged) then FOnSelectedDateChanged(Self);
  end;
end;

procedure TChnCalendarGrid.SetCurrentMonth(AValue: TDateTime);
var
  Y, M, D: Word;
  NewMonth: TDateTime;
begin
  DecodeDate(AValue, Y, M, D);
  NewMonth := EncodeDate(Y, M, 1);
  if Trunc(FCurrentMonth) <> Trunc(NewMonth) then
  begin
    FCurrentMonth := NewMonth;
    Invalidate;
    if Assigned(FOnMonthChanged) then FOnMonthChanged(Self);
  end;
end;

procedure TChnCalendarGrid.FontChanged(Sender: TObject);
begin Invalidate; end;

procedure TChnCalendarGrid.PictureChanged(Sender: TObject);
begin Invalidate; end;

{ ---------- 导航 ---------- }

procedure TChnCalendarGrid.PrevMonth;
var Y, M, D: Word;
begin
  DecodeDate(FCurrentMonth, Y, M, D);
  if M = 1 then begin Dec(Y); M := 12; end else Dec(M);
  CurrentMonth := EncodeDate(Y, M, 1);
end;

procedure TChnCalendarGrid.NextMonth;
var Y, M, D: Word;
begin
  DecodeDate(FCurrentMonth, Y, M, D);
  if M = 12 then begin Inc(Y); M := 1; end else Inc(M);
  CurrentMonth := EncodeDate(Y, M, 1);
end;

procedure TChnCalendarGrid.PrevYear;
var Y, M, D: Word;
begin
  DecodeDate(FCurrentMonth, Y, M, D);
  CurrentMonth := EncodeDate(Y - 1, M, 1);
end;

procedure TChnCalendarGrid.NextYear;
var Y, M, D: Word;
begin
  DecodeDate(FCurrentMonth, Y, M, D);
  CurrentMonth := EncodeDate(Y + 1, M, 1);
end;

procedure TChnCalendarGrid.GoToToday;
begin
  SelectedDate := Date;
end;

{ ---------- 布局 ---------- }

procedure TChnCalendarGrid.SyncGridSize;
var
  I, CW, CH, LastW, LastH: Integer;
begin
  if FSyncing then Exit;
  if (ClientWidth <= 0) or (ClientHeight <= 0) then Exit;

  FSyncing := True;
  try
    // ★ 关键修复 3：末列宽/末行高必须 >= 0，避免负数传入 TCustomGrid.SetColWidths
    //    （历史上当 ClientWidth 在 [1..6] 时，CW 被钳到 1，末列会算出负数）
    CW := ClientWidth div 7;
    if CW < 1 then CW := 1;
    LastW := ClientWidth - CW * 6;
    if LastW < 0 then LastW := 0;

    for I := 0 to 5 do
      if ColWidths[I] <> CW then ColWidths[I] := CW;
    if ColWidths[6] <> LastW then ColWidths[6] := LastW;

    CH := ClientHeight div 7;
    if CH < 1 then CH := 1;
    LastH := ClientHeight - CH * 6;
    if LastH < 0 then LastH := 0;

    for I := 0 to 5 do
      if RowHeights[I] <> CH then RowHeights[I] := CH;
    if RowHeights[6] <> LastH then RowHeights[6] := LastH;
  finally
    FSyncing := False;
  end;
end;

procedure TChnCalendarGrid.Resize;
begin
  inherited;
  SyncGridSize;
  Invalidate;
end;

{ ---------- 日期辅助 ---------- }

function TChnCalendarGrid.GetFirstCellDate: TDateTime;
var
  Y, M, D: Word;
  FirstOfMonth: TDateTime;
  DOW: Integer;
begin
  DecodeDate(FCurrentMonth, Y, M, D);
  FirstOfMonth := EncodeDate(Y, M, 1);
  DOW := DayOfWeek(FirstOfMonth);
  Result := FirstOfMonth - (DOW - 1);
end;

function TChnCalendarGrid.CellDate(ACol, ARow: Integer): TDateTime;
begin
  Result := GetFirstCellDate + (ARow - 1) * 7 + ACol;
end;

function TChnCalendarGrid.FindCellByDate(ADate: TDateTime;
  out ACol, ARow: Integer): Boolean;
var
  Diff: Integer;
  First: TDateTime;
begin
  First := GetFirstCellDate;
  Diff := Trunc(ADate) - Trunc(First);
  Result := (Diff >= 0) and (Diff < 42);
  if Result then
  begin
    ARow := Diff div 7 + 1;
    ACol := Diff mod 7;
  end
  else
  begin
    ACol := -1;
    ARow := -1;
  end;
end;

{ ---------- 绘制 ---------- }

procedure TChnCalendarGrid.Paint;
begin
  if (ClientWidth <= 0) or (ClientHeight <= 0) then
  begin
    inherited;
    Exit;
  end;

  SyncGridSize;

  if (FBuffer.Width <> ClientWidth) or (FBuffer.Height <> ClientHeight) then
    FBuffer.SetSize(ClientWidth, ClientHeight);

  DrawTo(FBuffer.Canvas);
  Canvas.Draw(0, 0, FBuffer);
end;

procedure TChnCalendarGrid.DrawTo(ACanvas: TCanvas);
var
  Col, Row: Integer;
  R: TRect;
  D: TDateTime;
begin
  DrawBackground(ACanvas);

  for Col := 0 to 6 do
  begin
    R := CellRect(Col, 0);
    DrawHeaderCell(ACanvas, Col, R);
  end;

  for Row := 1 to 6 do
    for Col := 0 to 6 do
    begin
      R := CellRect(Col, Row);
      D := CellDate(Col, Row);
      DrawDayCell(ACanvas, D, Col, Row, R);
    end;

  DrawGridLines(ACanvas);
end;

procedure TChnCalendarGrid.DrawBackground(ACanvas: TCanvas);
var
  R: TRect;
begin
  ACanvas.Brush.Style := bsSolid;
  ACanvas.Brush.Color := FBackgroundColor;
  R := Rect(0, 0, ClientWidth, ClientHeight);
  ACanvas.FillRect(R);

  if (FBackgroundPicture <> nil) and
     (FBackgroundPicture.Graphic <> nil) and
     (not FBackgroundPicture.Graphic.Empty) and
     (FBackgroundAlpha > 0) then
    DrawBackgroundImage(ACanvas);
end;

procedure TChnCalendarGrid.DrawBackgroundImage(ACanvas: TCanvas);
var
  SrcBmp : TBitmap;
  BF     : TBlendFunction;
  G      : TGraphic;
  PicW, PicH, W, H, X, Y : Integer;
  ScaleX, ScaleY : Double;
  Quad   : PRGBQuad;

  procedure Blend(Dx, Dy, DW, DH: Integer);
  begin
    if (DW <= 0) or (DH <= 0) then Exit;
    Winapi.Windows.AlphaBlend(ACanvas.Handle, Dx, Dy, DW, DH,
      SrcBmp.Canvas.Handle, 0, 0, SrcBmp.Width, SrcBmp.Height, BF);
  end;

begin
  G := FBackgroundPicture.Graphic;
  PicW := G.Width;
  PicH := G.Height;
  if (PicW <= 0) or (PicH <= 0) then Exit;

  SrcBmp := TBitmap.Create;
  try
    SrcBmp.PixelFormat := pf32bit;
    SrcBmp.SetSize(PicW, PicH);

    if not (G is TPngImage) then
    begin
      SrcBmp.Canvas.Brush.Style := bsSolid;
      SrcBmp.Canvas.Brush.Color := FBackgroundColor;
      SrcBmp.Canvas.FillRect(Rect(0, 0, PicW, PicH));
    end;
    SrcBmp.Canvas.Draw(0, 0, G);

    // ★ 关键修复 4：用 PRGBQuad 遍历，避开 PByteArray 的 [0..32767] 静态上界，
    //    否则 8K 背景图（Width*4+3 > 32767）必定 Range check error。
    if not (G is TPngImage) then
    begin
      for Y := 0 to SrcBmp.Height - 1 do
      begin
        Quad := PRGBQuad(SrcBmp.ScanLine[Y]);
        for X := 0 to SrcBmp.Width - 1 do
        begin
          Quad.rgbReserved := 255;
          Inc(Quad);
        end;
      end;
    end;

    FillChar(BF, SizeOf(BF), 0);
    BF.BlendOp             := AC_SRC_OVER;
    BF.BlendFlags          := 0;
    BF.SourceConstantAlpha := FBackgroundAlpha;
    BF.AlphaFormat         := AC_SRC_ALPHA;

    case FBackgroundLayout of
      cilStretch:
        Blend(0, 0, ClientWidth, ClientHeight);

      cilCenter:
        Blend((ClientWidth - PicW) div 2, (ClientHeight - PicH) div 2, PicW, PicH);

      cilTile:
        begin
          Y := 0;
          while Y < ClientHeight do
          begin
            X := 0;
            while X < ClientWidth do
            begin
              Blend(X, Y, PicW, PicH);
              Inc(X, PicW);
            end;
            Inc(Y, PicH);
          end;
        end;

      cilFit:
        begin
          ScaleX := ClientWidth / PicW;
          ScaleY := ClientHeight / PicH;
          if ScaleX < ScaleY then ScaleY := ScaleX else ScaleX := ScaleY;
          W := Round(PicW * ScaleX);
          H := Round(PicH * ScaleY);
          if W < 1 then W := 1;
          if H < 1 then H := 1;
          Blend((ClientWidth - W) div 2, (ClientHeight - H) div 2, W, H);
        end;
    end;
  finally
    SrcBmp.Free;
  end;
end;

procedure TChnCalendarGrid.DrawHeaderCell(ACanvas: TCanvas; ACol: Integer;
  const ARect: TRect);
const
  WeekNames: array[0..6] of string = ('日','一','二','三','四','五','六');
var
  S: string;
  TW, TH, X, Y: Integer;
  TxtColor: TColor;
begin
  ACanvas.Brush.Style := bsSolid;
  ACanvas.Brush.Color := FHeaderColor;
  ACanvas.FillRect(ARect);

  S := WeekNames[ACol];
  if (ACol = 0) or (ACol = 6) then
    TxtColor := FWeekendTextColor
  else
    TxtColor := FDayTextColor;

  ACanvas.Font.Assign(FHeaderFont);
  ACanvas.Font.Color := TxtColor;
  ACanvas.Brush.Style := bsClear;

  TW := ACanvas.TextWidth(S);
  TH := ACanvas.TextHeight(S);
  X  := ARect.Left + ((ARect.Right - ARect.Left) - TW) div 2;
  Y  := ARect.Top  + ((ARect.Bottom - ARect.Top) - TH) div 2;
  ACanvas.TextOut(X, Y, S);
end;

procedure TChnCalendarGrid.DrawDayCell(ACanvas: TCanvas; ADate: TDateTime;
  ACol, ARow: Integer; const ARect: TRect);
var
  Y, M, D         : Word;
  LY, LM, LD      : Integer;
  IsLeap          : Boolean;
  DayStr, SubStr  : string;
  IsToday, IsSel, IsOther, IsWeekend : Boolean;
  TextColor, SubColor : TColor;
  HasLunar, HasFest, HasTerm : Boolean;
  TW, TH, X, Yy   : Integer;
  DefaultDraw     : Boolean;
begin
  // ★ 关键修复 5：退化矩形直接跳过（例如末列宽被 SyncGridSize 钳成 0 时）
  if (ARect.Right <= ARect.Left) or (ARect.Bottom <= ARect.Top) then Exit;

  DecodeDate(ADate, Y, M, D);
  IsOther   := (Y <> YearOf(FCurrentMonth)) or (M <> MonthOf(FCurrentMonth));
  IsToday   := Trunc(ADate) = Trunc(Date);
  IsSel     := Trunc(ADate) = Trunc(FSelectedDate);
  IsWeekend := (ACol = 0) or (ACol = 6);

  if IsOther then
    FillRectAlpha(ACanvas, ARect, FOtherMonthColor, 80);
  if IsToday then
    FillRectAlpha(ACanvas, ARect, FTodayColor, 90);
  if IsSel then
    FillRectAlpha(ACanvas, ARect, FSelectedColor, 110);

  HasLunar := GetLunarFromDay(Y, M, D, LY, LM, LD, IsLeap);
  HasFest  := False;
  HasTerm  := False;
  SubStr   := '';

  if HasLunar and FShowHoliday then
  begin
    SubStr := GetFestivalText(ADate, LM, LD, IsLeap);
    HasFest := SubStr <> '';
  end;

  if (SubStr = '') and FShowSolarTerm then
  begin
    var JQ := GetJieQiFromDay(Y, M, D);
    if JQ >= 0 then
    begin
      SubStr := GetJieQiFromNumber(JQ);
      HasTerm := SubStr <> '';
    end;
  end;

  if (SubStr = '') and HasLunar and FShowLunar then
  begin
    if LD = 1 then
      SubStr := LunarMonthName(LM, IsLeap)
    else
      SubStr := GetLunarDayFromNumber(LD);
  end;

  if IsOther then
    TextColor := FOtherMonthTextColor
  else if IsWeekend then
    TextColor := FWeekendTextColor
  else
    TextColor := FDayTextColor;

  DayStr := IntToStr(D);
  DefaultDraw := True;

  if Assigned(FOnDrawDayCell) then
    FOnDrawDayCell(Self, ADate, ACol, ARow, ARect, ACanvas, DefaultDraw);

  if DefaultDraw then
  begin
    ACanvas.Brush.Style := bsClear;

    ACanvas.Font.Assign(FDayFont);
    ACanvas.Font.Color := TextColor;
    TW := ACanvas.TextWidth(DayStr);
    TH := ACanvas.TextHeight(DayStr);
    ACanvas.TextOut(ARect.Right - TW - 4, ARect.Top + 2, DayStr);

    if SubStr <> '' then
    begin
      if HasFest then
        SubColor := FHolidayColor
      else if HasTerm then
        SubColor := FSolarTermColor
      else
        SubColor := FLunarColor;

      ACanvas.Font.Assign(FSubFont);
      ACanvas.Font.Color := SubColor;
      TW := ACanvas.TextWidth(SubStr);
      TH := ACanvas.TextHeight(SubStr);
      X  := ARect.Left + ((ARect.Right - ARect.Left) - TW) div 2;
      Yy := ARect.Bottom - TH - 2;
      ACanvas.TextOut(X, Yy, SubStr);
    end;
  end;
end;

procedure TChnCalendarGrid.DrawGridLines(ACanvas: TCanvas);
var
  I: Integer;
  R: TRect;
begin
  ACanvas.Pen.Style := psSolid;
  ACanvas.Pen.Width := 1;
  ACanvas.Pen.Color := FGridLineColor;

  for I := 0 to 6 do
  begin
    R := CellRect(I, 0);
    if R.Right > 0 then
    begin
      ACanvas.MoveTo(R.Right, 0);
      ACanvas.LineTo(R.Right, ClientHeight);
    end;
  end;

  for I := 0 to 6 do
  begin
    R := CellRect(0, I);
    if R.Bottom > 0 then
    begin
      ACanvas.MoveTo(0, R.Bottom);
      ACanvas.LineTo(ClientWidth, R.Bottom);
    end;
  end;
end;

procedure TChnCalendarGrid.FillRectAlpha(ACanvas: TCanvas; const ARect: TRect;
  AColor: TColor; AAlpha: Byte);
var
  BF: TBlendFunction;
  C : COLORREF;
  P : PRGBQuad;
begin
  if AAlpha = 0 then Exit;
  if (ARect.Right <= ARect.Left) or (ARect.Bottom <= ARect.Top) then Exit;

  if AAlpha >= 255 then
  begin
    ACanvas.Brush.Style := bsSolid;
    ACanvas.Brush.Color := AColor;
    ACanvas.FillRect(ARect);
    Exit;
  end;

  // ★ 关键修复 6：完全绕过 TBitmap.Canvas.Pixels，改为直接写 DIB 的 ScanLine。
  //    Pixels 对 1x1 pf32bit 的内部索引在部分 Delphi 版本会触发 Range check。
  if FAlphaBmp.PixelFormat <> pf32bit then
    FAlphaBmp.PixelFormat := pf32bit;
  FAlphaBmp.SetSize(1, 1);

  C := ColorToRGB(AColor);
  P := PRGBQuad(FAlphaBmp.ScanLine[0]);
  P.rgbBlue     := GetBValue(C);
  P.rgbGreen    := GetGValue(C);
  P.rgbRed      := GetRValue(C);
  P.rgbReserved := $FF;

  FillChar(BF, SizeOf(BF), 0);
  BF.BlendOp             := AC_SRC_OVER;
  BF.BlendFlags          := 0;
  BF.SourceConstantAlpha := AAlpha;
  BF.AlphaFormat         := 0;

  Winapi.Windows.AlphaBlend(ACanvas.Handle,
    ARect.Left, ARect.Top, ARect.Right - ARect.Left, ARect.Bottom - ARect.Top,
    FAlphaBmp.Canvas.Handle, 0, 0, 1, 1, BF);
end;

{ ---------- 农历 & 节日 ---------- }

function TChnCalendarGrid.LunarMonthName(AMonth: Integer; AIsLeap: Boolean): string;
const
  Names: array[1..12] of string =
    ('正','二','三','四','五','六','七','八','九','十','冬','腊');
begin
  if (AMonth < 1) or (AMonth > 12) then Exit('');
  if AIsLeap then
    Result := '闰' + Names[AMonth] + '月'
  else
    Result := Names[AMonth] + '月';
end;

function TChnCalendarGrid.GetFestivalText(ADate: TDateTime;
  ALunarMonth, ALunarDay: Integer; AIsLeap: Boolean): string;
var
  Y, M, D       : Word;
  Y2, M2, D2    : Word;
  LY2, LM2, LD2 : Integer;
  L2            : Boolean;
begin
  Result := '';

  if not AIsLeap then
  begin
    case ALunarMonth of
      1:  if ALunarDay = 1  then Exit('春节');
      15:  if ALunarDay = 15 then Exit('元宵');
      5:  if ALunarDay = 5  then Exit('端午');
      7:  if ALunarDay = 7  then Exit('七夕');
      8:  if ALunarDay = 15 then Exit('中秋');
      9:  if ALunarDay = 9  then Exit('重阳');
      12: if ALunarDay = 8  then Exit('腊八');
    end;

    if ALunarMonth = 12 then
    begin
      DecodeDate(ADate + 1, Y2, M2, D2);
      if GetLunarFromDay(Y2, M2, D2, LY2, LM2, LD2, L2) then
        if (LM2 = 1) and (LD2 = 1) and (not L2) then
          Exit('除夕');
    end;
  end;

  DecodeDate(ADate, Y, M, D);
  case M of
    1:  if D = 1  then Exit('元旦');
    2:  if D = 14 then Exit('情人节');
    3:  if D = 8  then Exit('妇女节');
    4:  if D = 1  then Exit('愚人节');
    5:
      begin
        if D = 1 then Exit('劳动节');
        if D = 4 then Exit('青年节');
      end;
    6:  if D = 1  then Exit('儿童节');
    7:  if D = 1  then Exit('建党节');
    8:  if D = 1  then Exit('建军节');
    9:  if D = 10 then Exit('教师节');
    10: if D = 1  then Exit('国庆节');
    12: if D = 25 then Exit('圣诞节');
  end;
end;

{ ---------- 鼠标 / 键盘 ---------- }

procedure TChnCalendarGrid.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  Col, Row: Longint;
  D: TDateTime;
begin
  inherited;
  if Button <> mbLeft then Exit;

  Col := -1; Row := -1;
  MouseToCell(X, Y, Col, Row);
  if (Col < 0) or (Col > 6) or (Row < 1) or (Row > 6) then Exit;

  D := CellDate(Col, Row);
  SelectedDate := D;
end;

procedure TChnCalendarGrid.KeyDown(var Key: Word; Shift: TShiftState);
var
  NewDate: TDateTime;
begin
  inherited;
  NewDate := FSelectedDate;
  case Key of
    VK_LEFT  : NewDate := NewDate - 1;
    VK_RIGHT : NewDate := NewDate + 1;
    VK_UP    : NewDate := NewDate - 7;
    VK_DOWN  : NewDate := NewDate + 7;
    VK_PRIOR :
      begin
        if ssCtrl in Shift then PrevYear else PrevMonth;
        Exit;
      end;
    VK_NEXT :
      begin
        if ssCtrl in Shift then NextYear else NextMonth;
        Exit;
      end;
    VK_HOME : begin GoToToday; Exit; end;
  else
    Exit;
  end;
  SelectedDate := NewDate;
end;

procedure TChnCalendarGrid.WMMouseWheel(var Msg: TWMMouseWheel);
begin
  if Msg.WheelDelta < 0 then NextMonth else PrevMonth;
  Msg.Result := 0;
end;

procedure Register;
begin
  RegisterComponents('ChnCalendar', [TChnCalendarGrid]);
end;

end.
