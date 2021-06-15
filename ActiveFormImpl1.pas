unit ActiveFormImpl1;

{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ActiveX, AxCtrls, ActiveFormProj1_TLB, StdVcl, StdCtrls, Printers,
  ExtCtrls;

type
  TActiveFormX = class(TActiveForm, IActiveFormX, IObjectSafety)
    Shape1: TShape;
    Button1: TButton;
    Memo1: TMemo;
    Button2: TButton;
    Memo2: TMemo;
    Edit1: TEdit;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);



  private
    { Private declarations }
    FEvents: IActiveFormXEvents;
    procedure ActivateEvent(Sender: TObject);
    procedure ClickEvent(Sender: TObject);
    procedure CreateEvent(Sender: TObject);
    procedure DblClickEvent(Sender: TObject);
    procedure DeactivateEvent(Sender: TObject);
    procedure DestroyEvent(Sender: TObject);
    procedure KeyPressEvent(Sender: TObject; var Key: Char);
    procedure PaintEvent(Sender: TObject);
    function SplitString4(Value:String; Delimiter:String):TStrings;
    
  protected
    { Protected declarations }
    procedure DefinePropertyPages(DefinePropertyPage: TDefinePropertyPage); override;
    procedure EventSinkChanged(const EventSink: IUnknown); override;
    function Get_Active: WordBool; safecall;
    function Get_AlignDisabled: WordBool; safecall;
    function Get_AutoScroll: WordBool; safecall;
    function Get_AutoSize: WordBool; safecall;
    function Get_AxBorderStyle: TxActiveFormBorderStyle; safecall;
    function Get_Caption: WideString; safecall;
    function Get_Color: OLE_COLOR; safecall;
    function Get_DoubleBuffered: WordBool; safecall;
    function Get_DropTarget: WordBool; safecall;
    function Get_Enabled: WordBool; safecall;
    function Get_Font: IFontDisp; safecall;
    function Get_HelpFile: WideString; safecall;
    function Get_KeyPreview: WordBool; safecall;
    function Get_PixelsPerInch: Integer; safecall;
    function Get_PrintScale: TxPrintScale; safecall;
    function Get_Scaled: WordBool; safecall;
    function Get_ScreenSnap: WordBool; safecall;
    function Get_SnapBuffer: Integer; safecall;
    function Get_Visible: WordBool; safecall;
    function Get_VisibleDockClientCount: Integer; safecall;
    procedure _Set_Font(var Value: IFontDisp); safecall;
    procedure Set_AutoScroll(Value: WordBool); safecall;
    procedure Set_AutoSize(Value: WordBool); safecall;
    procedure Set_AxBorderStyle(Value: TxActiveFormBorderStyle); safecall;
    procedure Set_Caption(const Value: WideString); safecall;
    procedure Set_Color(Value: OLE_COLOR); safecall;
    procedure Set_DoubleBuffered(Value: WordBool); safecall;
    procedure Set_DropTarget(Value: WordBool); safecall;
    procedure Set_Enabled(Value: WordBool); safecall;
    procedure Set_Font(const Value: IFontDisp); safecall;
    procedure Set_HelpFile(const Value: WideString); safecall;
    procedure Set_KeyPreview(Value: WordBool); safecall;
    procedure Set_PixelsPerInch(Value: Integer); safecall;
    procedure Set_PrintScale(Value: TxPrintScale); safecall;
    procedure Set_Scaled(Value: WordBool); safecall;
    procedure Set_ScreenSnap(Value: WordBool); safecall;
    procedure Set_SnapBuffer(Value: Integer); safecall;
    procedure Set_Visible(Value: WordBool); safecall;
    procedure AddData(const Param1: WideString); safecall;
    procedure Init; safecall;
    procedure Print; safecall;
    procedure PrintTotSum;
    procedure PrintRouteSum;

    {안전한 activex로 인식되도록 하기위해서}
    function ObjectSafetyGetInterfaceSafetyOptions(const IID: TIID;  pdwSupportedOptions, pdwEnabledOptions: PDWORD): HResult; stdcall;
    function IObjectSafety.GetInterfaceSafetyOptions =  ObjectSafetyGetInterfaceSafetyOptions;
    function ObjectSafetySetInterfaceSafetyOptions(const IID: TIID; dwOptionSetMask, dwEnabledOptions: DWORD): HResult; stdcall;
    function IObjectSafety.SetInterfaceSafetyOptions = ObjectSafetySetInterfaceSafetyOptions;

  public
    { Public declarations }
    procedure Initialize; override;

  end;

var
  PrintDialog : TPrintDialog;
  myPrinter   : TPrinter;
  CurRow      : Integer;
  nIdx        : Integer;
  FontName    : String;
  PosX        : Integer;
  PosY        : Integer;
  IncX        : Integer;

  Fields      : TStrings;
  PageRowCnt  : Integer;
  ColPosX     : Array of Integer;
  tmpStr      : String;

  { 합계를 위한 변수 }
  arr_x   : array[0..2] of Integer = (0, 105, 452);
  tot_snd : Array of Int64;
  tot_rcv : Array of Int64;
  prt_hds : Array of String;

  ARect : TRect;

implementation

uses ComObj, ComServ;

{$R *.DFM}

{ TActiveFormX }

function TActiveFormX.ObjectSafetyGetInterfaceSafetyOptions(const IID: TIID; pdwSupportedOptions, pdwEnabledOptions: PDWORD): HResult;
begin
  Result := S_OK;
end;

function TActiveFormX.ObjectSafetySetInterfaceSafetyOptions(const IID: TIID; dwOptionSetMask, dwEnabledOptions: DWORD): HResult;
begin
  Result := S_OK;
end;


procedure TActiveFormX.DefinePropertyPages(DefinePropertyPage: TDefinePropertyPage);
begin
  { Define property pages here.  Property pages are defined by calling
    DefinePropertyPage with the class id of the page.  For example,
      DefinePropertyPage(Class_ActiveFormXPage); }
end;

procedure TActiveFormX.EventSinkChanged(const EventSink: IUnknown);
begin
  FEvents := EventSink as IActiveFormXEvents;
  inherited EventSinkChanged(EventSink);
end;

procedure TActiveFormX.Initialize;
begin
  inherited Initialize;
  OnActivate := ActivateEvent;
  OnClick := ClickEvent;
  OnCreate := CreateEvent;
  OnDblClick := DblClickEvent;
  OnDeactivate := DeactivateEvent;
  OnDestroy := DestroyEvent;
  OnKeyPress := KeyPressEvent;
  OnPaint := PaintEvent;
end;

function TActiveFormX.Get_Active: WordBool;
begin
  Result := Active;
end;

function TActiveFormX.Get_AlignDisabled: WordBool;
begin
  Result := AlignDisabled;
end;

function TActiveFormX.Get_AutoScroll: WordBool;
begin
  Result := AutoScroll;
end;

function TActiveFormX.Get_AutoSize: WordBool;
begin
  Result := AutoSize;
end;

function TActiveFormX.Get_AxBorderStyle: TxActiveFormBorderStyle;
begin
  Result := Ord(AxBorderStyle);
end;

function TActiveFormX.Get_Caption: WideString;
begin
  Result := WideString(Caption);
end;

function TActiveFormX.Get_Color: OLE_COLOR;
begin
  Result := OLE_COLOR(Color);
end;

function TActiveFormX.Get_DoubleBuffered: WordBool;
begin
  Result := DoubleBuffered;
end;

function TActiveFormX.Get_DropTarget: WordBool;
begin
  Result := DropTarget;
end;

function TActiveFormX.Get_Enabled: WordBool;
begin
  Result := Enabled;
end;

function TActiveFormX.Get_Font: IFontDisp;
begin
  GetOleFont(Font, Result);
end;

function TActiveFormX.Get_HelpFile: WideString;
begin
  Result := WideString(HelpFile);
end;

function TActiveFormX.Get_KeyPreview: WordBool;
begin
  Result := KeyPreview;
end;

function TActiveFormX.Get_PixelsPerInch: Integer;
begin
  Result := PixelsPerInch;
end;

function TActiveFormX.Get_PrintScale: TxPrintScale;
begin
  Result := Ord(PrintScale);
end;

function TActiveFormX.Get_Scaled: WordBool;
begin
  Result := Scaled;
end;

function TActiveFormX.Get_ScreenSnap: WordBool;
begin
  Result := ScreenSnap;
end;

function TActiveFormX.Get_SnapBuffer: Integer;
begin
  Result := SnapBuffer;
end;

function TActiveFormX.Get_Visible: WordBool;
begin
  Result := Visible;
end;

function TActiveFormX.Get_VisibleDockClientCount: Integer;
begin
  Result := VisibleDockClientCount;
end;

procedure TActiveFormX._Set_Font(var Value: IFontDisp);
begin
  SetOleFont(Font, Value);
end;

procedure TActiveFormX.ActivateEvent(Sender: TObject);
begin
  if FEvents <> nil then FEvents.OnActivate;
end;

procedure TActiveFormX.ClickEvent(Sender: TObject);
begin
  if FEvents <> nil then FEvents.OnClick;
end;

procedure TActiveFormX.CreateEvent(Sender: TObject);
begin
  if FEvents <> nil then FEvents.OnCreate;
end;

procedure TActiveFormX.DblClickEvent(Sender: TObject);
begin
  if FEvents <> nil then FEvents.OnDblClick;
end;

procedure TActiveFormX.DeactivateEvent(Sender: TObject);
begin
  if FEvents <> nil then FEvents.OnDeactivate;
end;

procedure TActiveFormX.DestroyEvent(Sender: TObject);
begin
  if FEvents <> nil then FEvents.OnDestroy;
end;

procedure TActiveFormX.KeyPressEvent(Sender: TObject; var Key: Char);
var
  TempKey: Smallint;
begin
  TempKey := Smallint(Key);
  if FEvents <> nil then FEvents.OnKeyPress(TempKey);
  Key := Char(TempKey);
end;

procedure TActiveFormX.PaintEvent(Sender: TObject);
begin
  if FEvents <> nil then FEvents.OnPaint;
end;

procedure TActiveFormX.Set_AutoScroll(Value: WordBool);
begin
  AutoScroll := Value;
end;

procedure TActiveFormX.Set_AutoSize(Value: WordBool);
begin
  AutoSize := Value;
end;

procedure TActiveFormX.Set_AxBorderStyle(Value: TxActiveFormBorderStyle);
begin
  AxBorderStyle := TActiveFormBorderStyle(Value);
end;

procedure TActiveFormX.Set_Caption(const Value: WideString);
begin
  Caption := TCaption(Value);
end;

procedure TActiveFormX.Set_Color(Value: OLE_COLOR);
begin
  Color := TColor(Value);
end;

procedure TActiveFormX.Set_DoubleBuffered(Value: WordBool);
begin
  DoubleBuffered := Value;
end;

procedure TActiveFormX.Set_DropTarget(Value: WordBool);
begin
  DropTarget := Value;
end;

procedure TActiveFormX.Set_Enabled(Value: WordBool);
begin
  Enabled := Value;
end;

procedure TActiveFormX.Set_Font(const Value: IFontDisp);
begin
  SetOleFont(Font, Value);
end;

procedure TActiveFormX.Set_HelpFile(const Value: WideString);
begin
  HelpFile := String(Value);
end;

procedure TActiveFormX.Set_KeyPreview(Value: WordBool);
begin
  KeyPreview := Value;
end;

procedure TActiveFormX.Set_PixelsPerInch(Value: Integer);
begin
  PixelsPerInch := Value;
end;

procedure TActiveFormX.Set_PrintScale(Value: TxPrintScale);
begin
  PrintScale := TPrintScale(Value);
end;

procedure TActiveFormX.Set_Scaled(Value: WordBool);
begin
  Scaled := Value;
end;

procedure TActiveFormX.Set_ScreenSnap(Value: WordBool);
begin
  ScreenSnap := Value;
end;

procedure TActiveFormX.Set_SnapBuffer(Value: Integer);
begin
  SnapBuffer := Value;
end;

procedure TActiveFormX.Set_Visible(Value: WordBool);
begin
  Visible := Value;
end;

procedure TActiveFormX.Button1Click(Sender: TObject);
begin
  PrintTotSum();
end;

function TActiveFormX.SplitString4(Value:String; delimiter:String):TStrings;
var
  S:TStrings;
  srcStr, tmpStr : string;
  b : boolean;
  posInt : integer;
begin
  S := TStringList.Create();

  if pos(delimiter, Value) < 1 then begin
    S.add(Value);
  end else begin
    srcStr := Value;
    b := true;

    while b do begin
      posInt := pos(delimiter, srcStr);
      tmpStr := copy(srcStr, 1, posInt-1);
      S.Add(tmpStr);

      srcStr := copy(srcStr, posInt + length(delimiter), length(srcStr) - posInt - length(delimiter) + 1);

      if pos(delimiter, srcStr) < 1 then begin
        S.Add(srcStr);
        b := false;
      end;
    end;
  end;

  result := S;
end;


procedure TActiveFormX.AddData(const Param1: WideString);
begin
  Memo1.Lines.Add(Param1);
end;

procedure TActiveFormX.Init;
begin
  Memo1.Lines.Clear;
end;

procedure TActiveFormX.Print;
begin
  if memo1.Lines.Count = 0 then begin
    ShowMessage('출력 자료가 존재하지 않습니다.');
  end;
  if memo1.Lines[0] = '1' then begin
    {총운임집계표}
    Memo1.Lines.Delete(0);
    PrintTotSum();
  end else if memo1.Lines[0] = '2' then begin
    {노선집계표}
    Memo1.Lines.Delete(0);
    PrintRouteSum();
  end else begin
    ShowMessage('출력 가능한 자료가 아닙니다. Value = ' + memo1.Lines[0] );
  end;
end;

procedure TActiveFormX.PrintTotSum;
var
  i :integer;
begin
  PageRowCnt := 30;
  SetLength(tot_snd, 20);
  SetLength(tot_rcv, 20);
  SetLength(prt_hds, 4);

  for i := 0 to 19 do begin
    tot_snd[i] := 0;
    tot_rcv[i] := 0;
  end;


  if Memo1.Lines.Count < 1 then begin
    ShowMessage('출력 내용이 존재하지 않습니다.');
    exit;
  end;

  prt_hds[0] := Copy(Memo1.Lines[0], 3, 200);
  Memo1.Lines.Delete(0);
  prt_hds[1] := Copy(Memo1.Lines[0], 3, 200);
  Memo1.Lines.Delete(0);
  prt_hds[2] := Copy(Memo1.Lines[0], 3, 200);
  Memo1.Lines.Delete(0);
  prt_hds[3] := Copy(Memo1.Lines[0], 3, 200);
  Memo1.Lines.Delete(0);

  PrintDialog := TPrintDialog.Create(Memo1);
  if printDialog.Execute then begin

    // Use the Printer function to get access to the global TPrinter object.
    // All references below are to the TPrinter object.
    myPrinter := Printer();
    with myPrinter do begin
      Canvas.font.name := Memo1.Font.Name;
      Canvas.Font.Style := Memo1.Font.Style;
      //SetMyPrinter();
      BeginDoc;
      SetMapMode(Canvas.Handle, MM_LOMETRIC);

      {문서헤더 출력}
      Canvas.Font.Height   := 250;

      tmpStr := Trim(prt_hds[0]);
      ARect := Rect(0, -650, 3400, -925 );
      DrawText(canvas.Handle, PChar(tmpStr), Length(tmpStr), ARect, DT_SINGLELINE or DT_BOTTOM or DT_CENTER);

      tmpStr := Trim(prt_hds[1]);
      ARect := Rect(0, -1100, 3400, -1375 );
      DrawText(canvas.Handle, PChar(tmpStr), Length(tmpStr), ARect, DT_SINGLELINE or DT_BOTTOM or DT_CENTER);

      tmpStr := Trim(prt_hds[2]);
      ARect := Rect(0, -1550, 3400, -1825 );
      DrawText(canvas.Handle, PChar(tmpStr), Length(tmpStr), ARect, DT_SINGLELINE or DT_BOTTOM or DT_CENTER);

      //Canvas.MoveTo(0,    -2650);
      //Canvas.LineTo(3400, -2650);
      //Canvas.LineTo(3400, 0);

      CurRow := 0;
      while Memo1.Lines.Count > CurRow do begin
        if curRow mod pageRowCnt = 0 then begin
          // new page
          myPrinter.NewPage;

          //nvas.MoveTo(0,    -2550);
          //nvas.LineTo(3400, -2550);
          //nvas.LineTo(3400, 0);

          // print page header
          Canvas.Font.Height   := 80;
          posY := 0;
          posX := 0;
          canvas.textout(posX, posY, prt_hds[3]);
          Dec(posY, Canvas.Font.Height + 50);

          // print column header
          Canvas.Font.Height   := 35;

          incX := 250;

          canvas.textout(arr_x[0],            posY, '  No');
          canvas.textout(arr_x[1],            posY, '영업소명');
          canvas.textout(arr_x[2],            posY, format('%14s', ['발송합계']));
          canvas.textout(arr_x[2] + incX * 1, posY, format('%14s', ['연계합계']));
          canvas.textout(arr_x[2] + incX * 2, posY, format('%12s', ['연계현불']));
          canvas.textout(arr_x[2] + incX * 3, posY, format('%12s', ['연계착불']));
          canvas.textout(arr_x[2] + incX * 4, posY, format('%12s', ['연계현택']));
          canvas.textout(arr_x[2] + incX * 5, posY, format('%12s', ['연계착택']));
          canvas.textout(arr_x[2] + incX * 6, posY, format('%14s', ['직송합계']));
          canvas.textout(arr_x[2] + incX * 7, posY, format('%12s', ['직송현불']));
          canvas.textout(arr_x[2] + incX * 8, posY, format('%12s', ['직송착불']));
          canvas.textout(arr_x[2] + incX * 9, posY, format('%12s', ['직송현택']));
          canvas.textout(arr_x[2] + incX * 10, posY, format('%12s', ['직송착택']));
          canvas.textout(arr_x[2] + incX * 11, posY, format('%10s', ['발송비율(%)']));

          Dec(posY, Canvas.Font.Height + 10);
          canvas.textout(arr_x[2] + incX * 0, posY, format('%14s', ['도착합계']));
          canvas.textout(arr_x[2] + incX * 1, posY, format('%14s', ['연계도착']));
          canvas.textout(arr_x[2] + incX * 6, posY, format('%14s', ['직송도착']));
          canvas.textout(arr_x[2] + incX *11, posY, format('%10s', ['도착비율(%)']));

          Dec(posY, Canvas.Font.Height);
        end;

        // 데이터 출력

        try

        fields := SplitString4(Copy(Memo1.Lines[curRow], 3, 500), '|');
        if fields.Count < 14 then begin
          continue;
        end;

        Dec(posY, Canvas.Font.Height + 16);

        if  curRow mod 2 = 0 then begin
          canvas.textout(arr_x[0],      posY, format('%4s>', [inttoStr(trunc(curRow/2) + 1)]));
        end;

        canvas.textout(arr_x[2] + incX * 0, posY, fields[ 1]);
        canvas.textout(arr_x[1],            posY, fields[ 0]);
        canvas.textout(arr_x[2] + incX * 1, posY, fields[ 2]);
        canvas.textout(arr_x[2] + incX * 2, posY, fields[ 3]);
        canvas.textout(arr_x[2] + incX * 3, posY, fields[ 4]);
        canvas.textout(arr_x[2] + incX * 4, posY, fields[ 5]);
        canvas.textout(arr_x[2] + incX * 5, posY, fields[ 6]);

        canvas.textout(arr_x[2] + incX * 6, posY, fields[ 7]);
        canvas.textout(arr_x[2] + incX * 7, posY, fields[ 8]);
        canvas.textout(arr_x[2] + incX * 8, posY, fields[ 9]);
        canvas.textout(arr_x[2] + incX * 9, posY, fields[10]);
        canvas.textout(arr_x[2] + incX *10, posY, fields[11]);

        if StrToInt64(fields[13]) <> 0 then begin
          canvas.textout(arr_x[2] + incX *11, posY, format('%10f', [StrToInt64(fields[12]) * 100.0 / StrToInt64(fields[13])]));
        end else begin
          canvas.textout(arr_x[2] + incX *11, posY, format('%10f', [0.00]));
        end;

        // 누적값 계산
        if  curRow mod 2 = 0 then begin
          tot_snd[ 1] := tot_snd[ 1] + StrToInt64(StringReplace(fields[ 1], ',', '', [rfReplaceAll]));
          tot_snd[ 2] := tot_snd[ 2] + StrToInt64(StringReplace(fields[ 2], ',', '', [rfReplaceAll]));
          tot_snd[ 3] := tot_snd[ 3] + StrToInt64(StringReplace(fields[ 3], ',', '', [rfReplaceAll]));
          tot_snd[ 4] := tot_snd[ 4] + StrToInt64(StringReplace(fields[ 4], ',', '', [rfReplaceAll]));
          tot_snd[ 5] := tot_snd[ 5] + StrToInt64(StringReplace(fields[ 5], ',', '', [rfReplaceAll]));
          tot_snd[ 6] := tot_snd[ 6] + StrToInt64(StringReplace(fields[ 6], ',', '', [rfReplaceAll]));
          tot_snd[ 7] := tot_snd[ 7] + StrToInt64(StringReplace(fields[ 7], ',', '', [rfReplaceAll]));
          tot_snd[ 8] := tot_snd[ 8] + StrToInt64(StringReplace(fields[ 8], ',', '', [rfReplaceAll]));
          tot_snd[ 9] := tot_snd[ 9] + StrToInt64(StringReplace(fields[ 9], ',', '', [rfReplaceAll]));
          tot_snd[10] := tot_snd[10] + StrToInt64(StringReplace(fields[10], ',', '', [rfReplaceAll]));
          tot_snd[11] := tot_snd[11] + StrToInt64(StringReplace(fields[11], ',', '', [rfReplaceAll]));
          tot_snd[12] := tot_snd[12] + StrToInt64(StringReplace(fields[12], ',', '', [rfReplaceAll]));
          tot_snd[13] := tot_snd[13] + StrToInt64(StringReplace(fields[13], ',', '', [rfReplaceAll]));
        end else begin
          tot_rcv[ 1] := tot_rcv[ 1] + StrToInt64(StringReplace(fields[ 1], ',', '', [rfReplaceAll]));
          tot_rcv[ 2] := tot_rcv[ 2] + StrToInt64(StringReplace(fields[ 2], ',', '', [rfReplaceAll]));
          tot_rcv[ 3] := tot_rcv[ 3] + StrToInt64(StringReplace(fields[ 3], ',', '', [rfReplaceAll]));
          tot_rcv[ 4] := tot_rcv[ 4] + StrToInt64(StringReplace(fields[ 4], ',', '', [rfReplaceAll]));
          tot_rcv[ 5] := tot_rcv[ 5] + StrToInt64(StringReplace(fields[ 5], ',', '', [rfReplaceAll]));
          tot_rcv[ 6] := tot_rcv[ 6] + StrToInt64(StringReplace(fields[ 6], ',', '', [rfReplaceAll]));
          tot_rcv[ 7] := tot_rcv[ 7] + StrToInt64(StringReplace(fields[ 7], ',', '', [rfReplaceAll]));
          tot_rcv[ 8] := tot_rcv[ 8] + StrToInt64(StringReplace(fields[ 8], ',', '', [rfReplaceAll]));
          tot_rcv[ 9] := tot_rcv[ 9] + StrToInt64(StringReplace(fields[ 9], ',', '', [rfReplaceAll]));
          tot_rcv[10] := tot_rcv[10] + StrToInt64(StringReplace(fields[10], ',', '', [rfReplaceAll]));
          tot_rcv[11] := tot_rcv[11] + StrToInt64(StringReplace(fields[11], ',', '', [rfReplaceAll]));
          tot_rcv[12] := tot_rcv[12] + StrToInt64(StringReplace(fields[12], ',', '', [rfReplaceAll]));
          tot_rcv[13] := tot_rcv[13] + StrToInt64(StringReplace(fields[13], ',', '', [rfReplaceAll]));

          Dec(posY, Canvas.Font.Height + 10);
        end;

        finally
        fields.Free;
        end;

        curRow := curRow + 1;

        if curRow mod pageRowCnt = 0 then begin
          // page footer 출력
          Dec(posY, Canvas.Font.Height);
          canvas.textout(arr_x[1],            posY, '발송');
          canvas.textout(arr_x[2] + incX * 0, posY, format('%14s', [FormatFloat('#,', tot_snd[ 1])]));
          canvas.textout(arr_x[2] + incX * 1, posY, format('%14s', [FormatFloat('#,', tot_snd[ 2])]));
          canvas.textout(arr_x[2] + incX * 2, posY, format('%12s', [FormatFloat('#,', tot_snd[ 3])]));
          canvas.textout(arr_x[2] + incX * 3, posY, format('%12s', [FormatFloat('#,', tot_snd[ 4])]));
          canvas.textout(arr_x[2] + incX * 4, posY, format('%12s', [FormatFloat('#,', tot_snd[ 5])]));
          canvas.textout(arr_x[2] + incX * 5, posY, format('%12s', [FormatFloat('#,', tot_snd[ 6])]));

          canvas.textout(arr_x[2] + incX * 6, posY, format('%14s', [FormatFloat('#,', tot_snd[ 7])]));
          canvas.textout(arr_x[2] + incX * 7, posY, format('%12s', [FormatFloat('#,', tot_snd[ 8])]));
          canvas.textout(arr_x[2] + incX * 8, posY, format('%12s', [FormatFloat('#,', tot_snd[ 9])]));
          canvas.textout(arr_x[2] + incX * 9, posY, format('%12s', [FormatFloat('#,', tot_snd[10])]));
          canvas.textout(arr_x[2] + incX *10, posY, format('%12s', [FormatFloat('#,', tot_snd[11])]));

          if tot_snd[13] <> 0 then begin
            canvas.textout(arr_x[2] + incX *11, posY, format('%10f', [tot_snd[12] * 100.0 / tot_snd[13]]));
          end else begin
            canvas.textout(arr_x[2] + incX *11, posY, format('%10f', [0.00]));
          end;

          Dec(posY, Canvas.Font.Height + 16);
          canvas.textout(arr_x[1],            posY, '도착');
          canvas.textout(arr_x[2] + incX * 0, posY, format('%14s', [FormatFloat('#,', tot_rcv[ 1])]));
          canvas.textout(arr_x[2] + incX * 1, posY, format('%14s', [FormatFloat('#,', tot_rcv[ 2])]));
          canvas.textout(arr_x[2] + incX * 2, posY, format('%12s', [FormatFloat('#,', tot_rcv[ 3])]));
          canvas.textout(arr_x[2] + incX * 3, posY, format('%12s', [FormatFloat('#,', tot_rcv[ 4])]));
          canvas.textout(arr_x[2] + incX * 4, posY, format('%12s', [FormatFloat('#,', tot_rcv[ 5])]));
          canvas.textout(arr_x[2] + incX * 5, posY, format('%12s', [FormatFloat('#,', tot_rcv[ 6])]));

          canvas.textout(arr_x[2] + incX * 6, posY, format('%14s', [FormatFloat('#,', tot_rcv[ 7])]));
          canvas.textout(arr_x[2] + incX * 7, posY, format('%12s', [FormatFloat('#,', tot_rcv[ 8])]));
          canvas.textout(arr_x[2] + incX * 8, posY, format('%12s', [FormatFloat('#,', tot_rcv[ 9])]));
          canvas.textout(arr_x[2] + incX * 9, posY, format('%12s', [FormatFloat('#,', tot_rcv[10])]));
          canvas.textout(arr_x[2] + incX *10, posY, format('%12s', [FormatFloat('#,', tot_rcv[11])]));

          if tot_rcv[13] <> 0 then begin
            canvas.textout(arr_x[2] + incX *11, posY, format('%10f', [tot_rcv[12] * 100.0 / tot_rcv[13]]));
          end else begin
            canvas.textout(arr_x[2] + incX *11, posY, format('%10f', [0.00]));
          end;
        end; // if curRow mod pageRowCnt = 0 then begin

      end; // end of while



      if curRow mod pageRowCnt > 0 then begin
        // page footer 출력

        Dec(posY, Canvas.Font.Height * 2 + 10);
        canvas.textout(arr_x[1],            posY, '발송');
        canvas.textout(arr_x[2] + incX * 0, posY, format('%14s', [FormatFloat('#,', tot_snd[ 1])]));
        canvas.textout(arr_x[2] + incX * 1, posY, format('%14s', [FormatFloat('#,', tot_snd[ 2])]));
        canvas.textout(arr_x[2] + incX * 2, posY, format('%12s', [FormatFloat('#,', tot_snd[ 3])]));
        canvas.textout(arr_x[2] + incX * 3, posY, format('%12s', [FormatFloat('#,', tot_snd[ 4])]));
        canvas.textout(arr_x[2] + incX * 4, posY, format('%12s', [FormatFloat('#,', tot_snd[ 5])]));
        canvas.textout(arr_x[2] + incX * 5, posY, format('%12s', [FormatFloat('#,', tot_snd[ 6])]));
        canvas.textout(arr_x[2] + incX * 6, posY, format('%14s', [FormatFloat('#,', tot_snd[ 7])]));
        canvas.textout(arr_x[2] + incX * 7, posY, format('%12s', [FormatFloat('#,', tot_snd[ 8])]));
        canvas.textout(arr_x[2] + incX * 8, posY, format('%12s', [FormatFloat('#,', tot_snd[ 9])]));
        canvas.textout(arr_x[2] + incX * 9, posY, format('%12s', [FormatFloat('#,', tot_snd[10])]));
        canvas.textout(arr_x[2] + incX *10, posY, format('%12s', [FormatFloat('#,', tot_snd[11])]));

        if tot_snd[13] <> 0 then begin
          canvas.textout(arr_x[2] + incX *11, posY, format('%10f', [tot_snd[12] * 100.0 / tot_snd[13]]));
        end else begin
          canvas.textout(arr_x[2] + incX *11, posY, format('%10f', [0.00]));
        end;

        Dec(posY, Canvas.Font.Height + 10);

        canvas.textout(arr_x[1],            posY, '도착');
        canvas.textout(arr_x[2] + incX * 0, posY, format('%14s', [FormatFloat('#,', tot_rcv[ 1])]));
        canvas.textout(arr_x[2] + incX * 1, posY, format('%14s', [FormatFloat('#,', tot_rcv[ 2])]));
        canvas.textout(arr_x[2] + incX * 2, posY, format('%12s', [FormatFloat('#,', tot_rcv[ 3])]));
        canvas.textout(arr_x[2] + incX * 3, posY, format('%12s', [FormatFloat('#,', tot_rcv[ 4])]));
        canvas.textout(arr_x[2] + incX * 4, posY, format('%12s', [FormatFloat('#,', tot_rcv[ 5])]));
        canvas.textout(arr_x[2] + incX * 5, posY, format('%12s', [FormatFloat('#,', tot_rcv[ 6])]));

        canvas.textout(arr_x[2] + incX * 6, posY, format('%14s', [FormatFloat('#,', tot_rcv[ 7])]));
        canvas.textout(arr_x[2] + incX * 7, posY, format('%12s', [FormatFloat('#,', tot_rcv[ 8])]));
        canvas.textout(arr_x[2] + incX * 8, posY, format('%12s', [FormatFloat('#,', tot_rcv[ 9])]));
        canvas.textout(arr_x[2] + incX * 9, posY, format('%12s', [FormatFloat('#,', tot_rcv[10])]));
        canvas.textout(arr_x[2] + incX *10, posY, format('%12s', [FormatFloat('#,', tot_rcv[11])]));

        if tot_rcv[13] <> 0 then begin
          canvas.textout(arr_x[2] + incX *11, posY, format('%10f', [tot_rcv[12] * 100.0 / tot_rcv[13]]));
        end else begin
          canvas.textout(arr_x[2] + incX *11, posY, format('%10f', [0.00]));
        end;
      end;

      EndDoc;
      ShowMessage('총운임집계표 출력작업을 완료하였습니다. 출력행수 = ' + IntToStr(CurRow));


    end; // with myPrinter do begin
  end; // end of if printDialog.Execute then begin
end;

procedure TActiveFormX.PrintRouteSum;
begin
  pageRowCnt := 25;
  SetLength(prt_hds, 4);

  if Memo1.Lines.Count < 1 then begin
    ShowMessage('출력 내용이 존재하지 않습니다.');
    exit;
  end;

  prt_hds[0] := Copy(Memo1.Lines[0], 3, 200);
  Memo1.Lines.Delete(0);
  prt_hds[1] := Copy(Memo1.Lines[0], 3, 200);
  Memo1.Lines.Delete(0);
  prt_hds[2] := Copy(Memo1.Lines[0], 3, 200);
  Memo1.Lines.Delete(0);
  prt_hds[3] := Copy(Memo1.Lines[0], 3, 200);
  Memo1.Lines.Delete(0);


  PrintDialog := TPrintDialog.Create(memo2);
  if printDialog.Execute then begin
    myPrinter := Printer();
    with myPrinter do begin
      Canvas.Font.Name := Memo2.Font.Name;
      Canvas.Font.Style := Memo2.Font.Style;
      //SetMyPrinter;
      BeginDoc();
      SetMapMode(Canvas.Handle, MM_LOMETRIC);
      
      {문서헤더출력}
      Canvas.Font.Height   := 250;

      tmpStr := Trim(prt_hds[0]);
      ARect := Rect(0, -650, 3400, -925 );
      DrawText(canvas.Handle, PChar(tmpStr), Length(tmpStr), ARect, DT_SINGLELINE or DT_BOTTOM or DT_CENTER);

      tmpStr := Trim(prt_hds[1]);
      ARect := Rect(0, -1100, 3400, -1375 );
      DrawText(canvas.Handle, PChar(tmpStr), Length(tmpStr), ARect, DT_SINGLELINE or DT_BOTTOM or DT_CENTER);

      tmpStr := Trim(prt_hds[2]);
      ARect := Rect(0, -1550, 3400, -1825 );
      DrawText(canvas.Handle, PChar(tmpStr), Length(tmpStr), ARect, DT_SINGLELINE or DT_BOTTOM or DT_CENTER);

      //canvas.MoveTo(0,    -2500);
      //canvas.LineTo(3400, -2500);
      //canvas.LineTo(3400, 0);

      CurRow := 0;


      while Memo1.Lines.Count > curRow do begin
        if curRow mod pageRowCnt = 0 then begin

          NewPage;
          canvas.MoveTo(0,    -2550);
          canvas.LineTo(3400, -2550);
          canvas.LineTo(3400, 0);

          // print page header
          Canvas.Font.Height   := 80;
          posY := 0;
          posX := 0;
          canvas.textout(posX, posY, prt_hds[3]);
          Dec(posY, Canvas.Font.Height + 70);


          // print column header
          Canvas.Font.Height   := 35;
          incX := 260;

          canvas.textout(posX,            posY, ' 순번');
          canvas.textout(posX + 120,      posY, '노선코드');

          canvas.textout(posX + 300,      posY, format('%s', ['기점']));
          canvas.textout(posX + 700,      posY, format('%s', ['종점']));
          canvas.textout(posX + 1100,     posY, format('%s', ['운행차주명']));

          canvas.textout(posX + 1500,                posY, format('%12s', ['적재운임']));
          canvas.textout(posX + 1500 + incX * 1,     posY, format('%12s', ['화물운임']));
          canvas.textout(posX + 1500 + incX * 2,     posY, format('%12s', ['택배운임']));
          canvas.textout(posX + 1500 + incX * 3,     posY, format('%12s', ['노선수수료']));
          canvas.textout(posX + 1500 + incX * 4 - 50,     posY, format('%12s', ['지원수수료']));

          canvas.textout(posX + 2720,     posY, format('%s', ['노선유형']));
          canvas.textout(posX + 2950,     posY, format('%s', ['계좌번호']));
          canvas.textout(posX + 3285,     posY, format('%s', ['예금주']));

          Dec(posY, Canvas.Font.Height + 60);
        end;

        // 데이터 출력
        fields := SplitString4(Copy(Memo1.Lines[curRow], 3, 500), '|');
        canvas.textout(posX,            posY, format('%4s)', [inttoStr(curRow + 1)]));
        canvas.textout(posX + 120,      posY, fields[ 0]);

        canvas.textout(posX + 300, posY, fields[ 1]);
        canvas.textout(posX + 700, posY, fields[ 2]);


        canvas.textout(posX + 1450, posY, fields[ 4]);
        canvas.textout(posX + 1050, posY, fields[ 3]);


        canvas.textout(posX + 1450 + incX * 1, posY, fields[ 5]);
        canvas.textout(posX + 1450 + incX * 2, posY, fields[ 6]);
        canvas.textout(posX + 1450 + incX * 3, posY, fields[ 7]);
        canvas.textout(posX + 1450 + incX * 4 + 40, posY, fields[ 8]);

        canvas.textout(posX + 2750, posY, fields[ 9]);
        canvas.textout(posX + 2900, posY, fields[10]);
        canvas.textout(posX + 3285, posY, fields[11]);

        Dec(posY, Canvas.Font.Height + 58);
        curRow := curRow + 1;

        fields.Free;
      end;

      EndDoc();
      ShowMessage('노선집계표 출력작업을 완료하였습니다. 출력행수 = ' + IntToStr(CurRow));
    end;
  end;
end;



procedure TActiveFormX.Button2Click(Sender: TObject);
begin
  PrintRouteSum();
end;

initialization
  TActiveFormFactory.Create(
    ComServer,
    TActiveFormControl,
    TActiveFormX,
    Class_ActiveFormX,
    1,
    '',
    OLEMISC_SIMPLEFRAME or OLEMISC_ACTSLIKELABEL,
    tmApartment);
end.
