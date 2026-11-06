unit ChnCalendarGrid;

interface

uses
  System.SysUtils, System.Classes, System.Types, System.UITypes, System.Math,
  System.DateUtils,
  Winapi.Windows, Winapi.Messages,
  Winapi.GDIPAPI, Winapi.GDIPOBJ,vcl.StdCtrls,
  Vcl.Controls, Vcl.Grids, Vcl.Graphics, Vcl.Forms,
  Vcl.Imaging.PngImage, Vcl.Imaging.jpeg,
  ChnCalendarUse, NCalendar;

type
  TCalendarImageLayout = (cilStretch, cilCenter, cilTile, cilFit);
  TCalendarStyle       = (csClassic, csModern);

  TCalendarDayDrawEvent = procedure(Sender: TObject; ADate: TDateTime;
    ACol, ARow: Integer; const ARect: TRect; ACanvas: TCanvas;
    var ADefaultDraw: Boolean) of object;

  TChnCalendarGrid = class(TDrawGrid)
  private
    FBackgroundPicture : TPicture;
    FBackgroundColor   : TColor;
    FBackgroundAlpha   : Byte;
    FBackgroundLayout  : TCalendarImageLayout;

    FStyle             : TCalendarStyle;

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

    FTodayBorderColor  : TColor;
    FSelectFillColor   : TColor;
    FHeaderBorderColor : TColor;

    // 日期数字上下间距（现代风格使用，仅第 2~6 行受影响）
    FDayNumberTopMargin    : Integer;
    FDayNumberBottomMargin : Integer;

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
    procedure SetStyle(AValue: TCalendarStyle);
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
    procedure SetTodayBorderColor(AValue: TColor);
    procedure SetSelectFillColor(AValue: TColor);
    procedure SetHeaderBorderColor(AValue: TColor);
    procedure SetDayNumberTopMargin(AValue: Integer);
    procedure SetDayNumberBottomMargin(AValue: Integer);
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
    procedure DrawDayCellClassic(ACanvas: TCanvas; ADate: TDateTime;
      ACol, ARow: Integer; const ARect: TRect; const ASubStr: string;
      AIsFest, AIsTerm, AIsOther, AIsWeekend, AIsToday, AIsSel: Boolean);
    procedure DrawDayCellModern(ACanvas: TCanvas; ADate: TDateTime;
      ACol, ARow: Integer; const ARect: TRect; const ASubStr: string;
      AIsFest, AIsTerm, AIsOther, AIsWeekend, AIsToday, AIsSel: Boolean);
    procedure DrawGridLines(ACanvas: TCanvas);
    procedure FillRectAlpha(ACanvas: TCanvas; const ARect: TRect;
      AColor: TColor; AAlpha: Byte);

    procedure DrawAntiAliasCircle(ACanvas: TCanvas; const ARect: TRect;
      AColor: TColor; AWidth: Integer; AFilled: Boolean);

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

  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;

    procedure PrevMonth;
    procedure NextMonth;
    procedure PrevYear;
    procedure NextYear;
    procedure GoToToday;

    { 跳转到指定日期：自动切换到目标月并选中该日。
      返回 True 表示日期合法且已定位；False 表示日期无效（不做任何改变）。 }
    function  GoToTheDate(ADate: TDateTime): Boolean;

    // 便捷函数：一次设置两个间距（像素单位）；不影响第 1 行的顶部间距
    procedure SetDayNumberMargins(ATop, ABottom: Integer);

  published
    property BackgroundPicture: TPicture
      read FBackgroundPicture write SetBackgroundPicture;
    property BackgroundColor: TColor
      read FBackgroundColor write SetBackgroundColor default clWhite;
    property BackgroundAlpha: Byte
      read FBackgroundAlpha write SetBackgroundAlpha default 255;
    property BackgroundLayout: TCalendarImageLayout
      read FBackgroundLayout write SetBackgroundLayout default cilStretch;

    property Style: TCalendarStyle
      read FStyle write SetStyle default csModern;

    property HeaderColor: TColor
      read FHeaderColor write SetHeaderColor default $00F7F7F7;
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
    property GridLineColor: TColor
      read FGridLineColor write SetGridLineColor default $00E8E8E8;

    property TodayBorderColor: TColor
      read FTodayBorderColor write SetTodayBorderColor default clRed;
    property SelectFillColor: TColor
      read FSelectFillColor write SetSelectFillColor default $00DC8040;
    property HeaderBorderColor: TColor
      read FHeaderBorderColor write SetHeaderBorderColor default $00D0D0D0;

    property DayNumberTopMargin: Integer
      read FDayNumberTopMargin write SetDayNumberTopMargin default 10;
    property DayNumberBottomMargin: Integer
      read FDayNumberBottomMargin write SetDayNumberBottomMargin default 14;

    property HolidayColor: TColor
      read FHolidayColor write SetHolidayColor default clRed;
    property SolarTermColor: TColor
      read FSolarTermColor write SetSolarTermColor default clGreen;
    property LunarColor: TColor
      read FLunarColor write SetLunarColor default $00707030;

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

const
  CDefaultDayNumberTopMargin = 10;

{ ==================== GDI+ 辅助 ==================== }

function ColorRefToARGB(AColor: TColor): ARGB;
var
  C: COLORREF;
begin
  C := ColorToRGB(AColor);
  Result := Winapi.GDIPAPI.MakeColor(255, GetRValue(C), GetGValue(C), GetBValue(C));
end;

{ ==================== 构造 / 析构 ==================== }

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

  FStyle             := csModern;
  FBackgroundColor   := clWhite;
  FBackgroundAlpha   := 255;
  FBackgroundLayout  := cilStretch;

  FHeaderColor         := $00F7F7F7;
  FDayTextColor        := clBlack;
  FWeekendTextColor    := clRed;
  FOtherMonthTextColor := clGray;
  FTodayColor          := $0090F0A0;
  FSelectedColor       := $00F0C080;
  FOtherMonthColor     := clWhite;
  FHolidayColor        := clRed;
  FSolarTermColor      := clGreen;
  FLunarColor          := $00707030;
  FGridLineColor       := $00E8E8E8;

  FTodayBorderColor    := clRed;
  FSelectFillColor     := $00DC8040;
  FHeaderBorderColor   := $00D0D0D0;

  FDayNumberTopMargin    := CDefaultDayNumberTopMargin;
  FDayNumberBottomMargin := 14;

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

{ ==================== 属性 setter ==================== }

procedure TChnCalendarGrid.SetBackgroundPicture(AValue: TPicture);
begin FBackgroundPicture.Assign(AValue); end;

procedure TChnCalendarGrid.SetBackgroundColor(AValue: TColor);
begin if FBackgroundColor <> AValue then begin FBackgroundColor := AValue; Invalidate; end; end;

procedure TChnCalendarGrid.SetBackgroundAlpha(AValue: Byte);
begin if FBackgroundAlpha <> AValue then begin FBackgroundAlpha := AValue; Invalidate; end; end;

procedure TChnCalendarGrid.SetBackgroundLayout(AValue: TCalendarImageLayout);
begin if FBackgroundLayout <> AValue then begin FBackgroundLayout := AValue; Invalidate; end; end;

procedure TChnCalendarGrid.SetStyle(AValue: TCalendarStyle);
begin if FStyle <> AValue then begin FStyle := AValue; Invalidate; end; end;

procedure TChnCalendarGrid.SetHeaderColor(AValue: TColor);
begin if FHeaderColor <> AValue then begin FHeaderColor := AValue; Invalidate; end; end;

procedure TChnCalendarGrid.SetHeaderFont(AValue: TFont);
begin FHeaderFont.Assign(AValue); Invalidate; end;

procedure TChnCalendarGrid.SetDayFont(AValue: TFont);
begin FDayFont.Assign(AValue); Invalidate; end;

procedure TChnCalendarGrid.SetSubFont(AValue: TFont);
begin FSubFont.Assign(AValue); Invalidate; end;

procedure TChnCalendarGrid.SetDayTextColor(AValue: TColor);
begin if FDayTextColor <> AValue then begin FDayTextColor := AValue; Invalidate; end; end;

procedure TChnCalendarGrid.SetWeekendTextColor(AValue: TColor);
begin if FWeekendTextColor <> AValue then begin FWeekendTextColor := AValue; Invalidate; end; end;

procedure TChnCalendarGrid.SetOtherMonthTextColor(AValue: TColor);
begin if FOtherMonthTextColor <> AValue then begin FOtherMonthTextColor := AValue; Invalidate; end; end;

procedure TChnCalendarGrid.SetTodayColor(AValue: TColor);
begin if FTodayColor <> AValue then begin FTodayColor := AValue; Invalidate; end; end;

procedure TChnCalendarGrid.SetSelectedColor(AValue: TColor);
begin if FSelectedColor <> AValue then begin FSelectedColor := AValue; Invalidate; end; end;

procedure TChnCalendarGrid.SetOtherMonthColor(AValue: TColor);
begin if FOtherMonthColor <> AValue then begin FOtherMonthColor := AValue; Invalidate; end; end;

procedure TChnCalendarGrid.SetHolidayColor(AValue: TColor);
begin if FHolidayColor <> AValue then begin FHolidayColor := AValue; Invalidate; end; end;

procedure TChnCalendarGrid.SetSolarTermColor(AValue: TColor);
begin if FSolarTermColor <> AValue then begin FSolarTermColor := AValue; Invalidate; end; end;

procedure TChnCalendarGrid.SetLunarColor(AValue: TColor);
begin if FLunarColor <> AValue then begin FLunarColor := AValue; Invalidate; end; end;

procedure TChnCalendarGrid.SetGridLineColor(AValue: TColor);
begin if FGridLineColor <> AValue then begin FGridLineColor := AValue; Invalidate; end; end;

procedure TChnCalendarGrid.SetTodayBorderColor(AValue: TColor);
begin if FTodayBorderColor <> AValue then begin FTodayBorderColor := AValue; Invalidate; end; end;

procedure TChnCalendarGrid.SetSelectFillColor(AValue: TColor);
begin if FSelectFillColor <> AValue then begin FSelectFillColor := AValue; Invalidate; end; end;

procedure TChnCalendarGrid.SetHeaderBorderColor(AValue: TColor);
begin if FHeaderBorderColor <> AValue then begin FHeaderBorderColor := AValue; Invalidate; end; end;

procedure TChnCalendarGrid.SetDayNumberTopMargin(AValue: Integer);
begin
  if AValue < 0 then AValue := 0;
  if FDayNumberTopMargin <> AValue then
  begin
    FDayNumberTopMargin := AValue;
    Invalidate;
  end;
end;

procedure TChnCalendarGrid.SetDayNumberBottomMargin(AValue: Integer);
begin
  if AValue < 0 then AValue := 0;
  if FDayNumberBottomMargin <> AValue then
  begin
    FDayNumberBottomMargin := AValue;
    Invalidate;
  end;
end;

procedure TChnCalendarGrid.SetShowLunar(AValue: Boolean);
begin if FShowLunar <> AValue then begin FShowLunar := AValue; Invalidate; end; end;

procedure TChnCalendarGrid.SetShowHoliday(AValue: Boolean);
begin if FShowHoliday <> AValue then begin FShowHoliday := AValue; Invalidate; end; end;

procedure TChnCalendarGrid.SetShowSolarTerm(AValue: Boolean);
begin if FShowSolarTerm <> AValue then begin FShowSolarTerm := AValue; Invalidate; end; end;

procedure TChnCalendarGrid.SetSelectedDate(AValue: TDateTime);
var
  NewSel: TDateTime;
begin
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

{ ==================== 导航 ==================== }

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

{ ==================== 新增：GoToTheDate ==================== }

function TChnCalendarGrid.GoToTheDate(ADate: TDateTime): Boolean;
var
  Y, M, D    : Word;
  Target     : TDateTime;
  Verify     : TDateTime;
begin
  Result := False;

  // TDateTime 为 0 表示未初始化，视为无效
  if ADate = 0 then Exit;

  // 归一化到整日（忽略时间部分）
  Target := Trunc(ADate);

  // 校验 DecodeDate 是否成功
  try
    DecodeDate(Target, Y, M, D);
  except
    Exit;
  end;

  // 年范围校验（与农历计算支持范围兼容）
  if (Y < 1) or (Y > 9999) then Exit;

  // 二次校验：EncodeDate 回算对比，拦截 2 月 30 日等非法日期
  try
    Verify := EncodeDate(Y, M, D);
  except
    Exit;
  end;
  if Trunc(Verify) <> Target then Exit;

  // 交由 SelectedDate 处理切月与刷新；用户事件、Invalidate 均会自动触发
  SelectedDate := Target;

  Result := True;
end;

procedure TChnCalendarGrid.SetDayNumberMargins(ATop, ABottom: Integer);
begin
  if ATop < 0 then ATop := 0;
  if ABottom < 0 then ABottom := 0;
  if (FDayNumberTopMargin <> ATop) or (FDayNumberBottomMargin <> ABottom) then
  begin
    FDayNumberTopMargin := ATop;
    FDayNumberBottomMargin := ABottom;
    Invalidate;
  end;
end;

{ ==================== 布局 ==================== }

procedure TChnCalendarGrid.SyncGridSize;
var
  I, CW, CH, LastW, LastH: Integer;
begin
  if FSyncing then Exit;
  if (ClientWidth <= 0) or (ClientHeight <= 0) then Exit;

  FSyncing := True;
  try
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

{ ==================== 日期辅助 ==================== }

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

{ ==================== GDI+ 抗锯齿圆 ==================== }

procedure TChnCalendarGrid.DrawAntiAliasCircle(ACanvas: TCanvas;
  const ARect: TRect; AColor: TColor; AWidth: Integer; AFilled: Boolean);
var
  Graphics : TGPGraphics;
  Pen      : TGPPen;
  Brush    : TGPSolidBrush;
  R        : TGPRectF;
  ClrARGB  : ARGB;
begin
  if (ARect.Right <= ARect.Left) or (ARect.Bottom <= ARect.Top) then Exit;

  ClrARGB := ColorRefToARGB(AColor);

  Graphics := TGPGraphics.Create(ACanvas.Handle);
  try
    Graphics.SetSmoothingMode(SmoothingModeAntiAlias);
    Graphics.SetPixelOffsetMode(PixelOffsetModeHalf);

    R.X      := ARect.Left;
    R.Y      := ARect.Top;
    R.Width  := ARect.Right  - ARect.Left;
    R.Height := ARect.Bottom - ARect.Top;

    if AFilled then
    begin
      Brush := TGPSolidBrush.Create(ClrARGB);
      try
        Graphics.FillEllipse(Brush, R);
      finally
        Brush.Free;
      end;
    end;

    if AWidth > 0 then
    begin
      Pen := TGPPen.Create(ClrARGB, AWidth);
      try
        Pen.SetLineCap(LineCapRound, LineCapRound, DashCapRound);
        Graphics.DrawEllipse(Pen, R);
      finally
        Pen.Free;
      end;
    end;
  finally
    Graphics.Free;
  end;
end;

{ ==================== 绘制主流程 ==================== }

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
  if FStyle = csClassic then
  begin
    ACanvas.Brush.Style := bsSolid;
    ACanvas.Brush.Color := FHeaderColor;
    ACanvas.FillRect(ARect);
  end;

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
  SubStr          : string;
  IsToday, IsSel, IsOther, IsWeekend : Boolean;
  HasLunar, HasFest, HasTerm : Boolean;
  DefaultDraw     : Boolean;
begin
  if (ARect.Right <= ARect.Left) or (ARect.Bottom <= ARect.Top) then Exit;

  DecodeDate(ADate, Y, M, D);
  IsOther   := (Y <> YearOf(FCurrentMonth)) or (M <> MonthOf(FCurrentMonth));
  IsToday   := Trunc(ADate) = Trunc(Date);
  IsSel     := Trunc(ADate) = Trunc(FSelectedDate);
  IsWeekend := (ACol = 0) or (ACol = 6);

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

  DefaultDraw := True;
  if Assigned(FOnDrawDayCell) then
    FOnDrawDayCell(Self, ADate, ACol, ARow, ARect, ACanvas, DefaultDraw);
  if not DefaultDraw then Exit;

  if FStyle = csClassic then
    DrawDayCellClassic(ACanvas, ADate, ACol, ARow, ARect, SubStr,
      HasFest, HasTerm, IsOther, IsWeekend, IsToday, IsSel)
  else
    DrawDayCellModern(ACanvas, ADate, ACol, ARow, ARect, SubStr,
      HasFest, HasTerm, IsOther, IsWeekend, IsToday, IsSel);
end;

procedure TChnCalendarGrid.DrawDayCellClassic(ACanvas: TCanvas; ADate: TDateTime;
  ACol, ARow: Integer; const ARect: TRect; const ASubStr: string;
  AIsFest, AIsTerm, AIsOther, AIsWeekend, AIsToday, AIsSel: Boolean);
var
  DayStr  : string;
  TextColor, SubColor : TColor;
  TW, TH, X, Yy : Integer;
begin
  if AIsOther then
    FillRectAlpha(ACanvas, ARect, FOtherMonthColor, 80);
  if AIsToday then
    FillRectAlpha(ACanvas, ARect, FTodayColor, 90);
  if AIsSel then
    FillRectAlpha(ACanvas, ARect, FSelectedColor, 110);

  if AIsOther then
    TextColor := FOtherMonthTextColor
  else if AIsWeekend then
    TextColor := FWeekendTextColor
  else
    TextColor := FDayTextColor;

  DayStr := IntToStr(DayOf(ADate));

  ACanvas.Brush.Style := bsClear;
  ACanvas.Font.Assign(FDayFont);
  ACanvas.Font.Color := TextColor;
  TW := ACanvas.TextWidth(DayStr);
  ACanvas.TextOut(ARect.Right - TW - 4, ARect.Top + 2, DayStr);

  if ASubStr <> '' then
  begin
    if AIsFest then SubColor := FHolidayColor
    else if AIsTerm then SubColor := FSolarTermColor
    else SubColor := FLunarColor;

    ACanvas.Font.Assign(FSubFont);
    ACanvas.Font.Color := SubColor;
    TW := ACanvas.TextWidth(ASubStr);
    TH := ACanvas.TextHeight(ASubStr);
    X  := ARect.Left + ((ARect.Right - ARect.Left) - TW) div 2;
    Yy := ARect.Bottom - TH - 4;
    ACanvas.TextOut(X, Yy, ASubStr);
  end;
end;

procedure TChnCalendarGrid.DrawDayCellModern(ACanvas: TCanvas; ADate: TDateTime;
  ACol, ARow: Integer; const ARect: TRect; const ASubStr: string;
  AIsFest, AIsTerm, AIsOther, AIsWeekend, AIsToday, AIsSel: Boolean);
const
  SubBottomPad = 4;
var
  CellW, CellH            : Integer;
  TopMargin               : Integer;
  NumTop, NumBottom, NumH : Integer;
  CX, CY, CD              : Integer;
  CircleRect, OuterRect   : TRect;
  DayTextColor, SubColor  : TColor;
  DayStr, SubStr          : string;
  TW, TH, SW, SH          : Integer;
  SubTop                  : Integer;
begin
  CellW := ARect.Right - ARect.Left;
  CellH := ARect.Bottom - ARect.Top;
  if (CellW <= 0) or (CellH <= 0) then Exit;

  // 第一行顶部间距固定为默认值，其他行使用可调属性
  if ARow = 1 then
    TopMargin := CDefaultDayNumberTopMargin
  else
    TopMargin := FDayNumberTopMargin;

  SH := 0;
  if ASubStr <> '' then
  begin
    ACanvas.Font.Assign(FSubFont);
    SH := ACanvas.TextHeight(ASubStr);
  end;

  NumTop := ARect.Top + TopMargin;
  if ASubStr <> '' then
    NumBottom := ARect.Bottom - SH - SubBottomPad - FDayNumberBottomMargin
  else
    NumBottom := ARect.Bottom - FDayNumberBottomMargin;

  if NumBottom < NumTop then NumBottom := NumTop;
  NumH := NumBottom - NumTop;
  if NumH < 1 then NumH := 1;

  CX := (ARect.Left + ARect.Right) div 2;
  CY := NumTop + NumH div 2;

  ACanvas.Font.Assign(FDayFont);
  TH := ACanvas.TextHeight('0');
  CD := TH + 12;
  if CD > CellW - 4 then CD := CellW - 4;
  if CD > NumH - 2 then CD := NumH - 2;
  if CD < 16 then CD := 16;

  CircleRect := Rect(CX - CD div 2, CY - CD div 2,
                     CX + CD div 2, CY + CD div 2);

  if AIsSel then
  begin
    DrawAntiAliasCircle(ACanvas, CircleRect, FSelectFillColor, 0, True);
    if AIsToday then
    begin
      OuterRect := CircleRect;
      InflateRect(OuterRect, 2, 2);
      DrawAntiAliasCircle(ACanvas, OuterRect, FTodayBorderColor, 2, False);
    end;
  end
  else if AIsToday then
  begin
    DrawAntiAliasCircle(ACanvas, CircleRect, FTodayBorderColor, 2, False);
  end;

  if AIsSel then
    DayTextColor := clWhite
  else if AIsToday then
    DayTextColor := FTodayBorderColor
  else if AIsOther then
    DayTextColor := FOtherMonthTextColor
  else if AIsWeekend then
    DayTextColor := FWeekendTextColor
  else
    DayTextColor := FDayTextColor;

  DayStr := IntToStr(DayOf(ADate));
  ACanvas.Brush.Style := bsClear;
  ACanvas.Font.Assign(FDayFont);
  ACanvas.Font.Color := DayTextColor;
  TW := ACanvas.TextWidth(DayStr);
  TH := ACanvas.TextHeight(DayStr);
  ACanvas.TextOut(CX - TW div 2, CY - TH div 2, DayStr);

  if ASubStr <> '' then
  begin
    if AIsFest then SubColor := FHolidayColor
    else if AIsTerm then SubColor := FSolarTermColor
    else SubColor := FLunarColor;

    SubStr := ASubStr;
    ACanvas.Font.Assign(FSubFont);
    ACanvas.Font.Color := SubColor;
    SW := ACanvas.TextWidth(SubStr);
    SH := ACanvas.TextHeight(SubStr);
    SubTop := ARect.Bottom - SH - SubBottomPad;
    ACanvas.TextOut(CX - SW div 2, SubTop, SubStr);
  end;
end;

procedure TChnCalendarGrid.DrawGridLines(ACanvas: TCanvas);
var
  I: Integer;
  R: TRect;
begin
  if FStyle = csModern then
  begin
    R := CellRect(0, 0);
    if R.Bottom > 0 then
    begin
      ACanvas.Pen.Style := psSolid;
      ACanvas.Pen.Width := 1;
      ACanvas.Pen.Color := FHeaderBorderColor;
      ACanvas.MoveTo(0, R.Bottom - 1);
      ACanvas.LineTo(ClientWidth, R.Bottom - 1);
    end;
    Exit;
  end;

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

  if (FAlphaBmp.Width <> 1) or (FAlphaBmp.Height <> 1) or
     (FAlphaBmp.PixelFormat <> pf32bit) then
  begin
    FAlphaBmp.PixelFormat := pf32bit;
    FAlphaBmp.SetSize(1, 1);
  end;

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

{ ==================== 农历 & 节日 ==================== }

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
      1:
        begin
          if ALunarDay = 1  then Exit('春节');
          if ALunarDay = 15 then Exit('元宵');
        end;
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

{ ==================== 鼠标 / 键盘 ==================== }

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
