Program Saper;

Uses
 Windows;

Type
 TElement = Packed Record
  Mina: Boolean;
  Schot: Integer;
  Visibl: Boolean;
  MinaUst: Boolean;
 end;

Const
 NxM = 40;
 MinCount = 300;
 RElem = 17;
 clBlack =  $000000;
 clMaroon = $000080;
 clGreen =  $008000;
 clNavy =   $800000;
 clTeal =   $808000;
 clGray =   $808080;
 clSilver = $C0C0C0;
 clRed =    $0000FF;
 clBlue =   $FF0000;
 clWhite =  $FFFFFF;

Var
 Wc: TWndClassEx;
 Hw: HWND;
 Msg: TMsg;
 Pole: Array [1..NxM, 1..NxM] of TElement;
 SDC, VideoBuff: HDC;
 Bmp: HBITMAP;
 IGame: Integer = 0;
 Flag, Flag1: Boolean;

Procedure ClearPole;
var
 i, j: Integer;
begin
 For i:= 1 To NxM Do
  For j:= 1 To NxM Do
   begin
    Pole[i,j].Mina:= False;
    Pole[i,j].Schot:= 0;
    Pole[i,j].Visibl:= False;
    Pole[i,j].MinaUst:= False;
   end;
end;

Procedure RandomMine;
var
 Mi, i, j: Integer;
begin
 Mi:= 0;
 Repeat
  Randomize;
  i:= Random(NxM) + 1;
  j:= Random(NxM) + 1;
  if Not(Pole[i,j].Mina) Then
   begin
    Pole[i,j].Mina:= True;
    Inc(Mi);
   end;
 Until Mi = MinCount;
end;

Procedure SchotMin;
var
 Mv, i, j: Integer;
begin
 For i:= 1 To NxM Do
  For j:= 1 To NxM Do
   begin
    if Not(Pole[i,j].Mina) Then
     begin
      Mv:= 0;
      if (i > 1) And Pole[i-1,j].Mina Then Inc(Mv);
      if (i < NxM) And Pole[i+1,j].Mina Then Inc(Mv);
      if (j > 1) And Pole[i,j-1].Mina Then Inc(Mv);
      if (j < NxM) And Pole[i,j+1].Mina Then Inc(Mv);
      if (i > 1) And (j > 1) And Pole[i-1,j-1].Mina Then Inc(Mv);
      if (i < NxM) And (j < NxM) And Pole[i+1,j+1].Mina Then Inc(Mv);
      if (j > 1) And (i < NxM) And Pole[i+1,j-1].Mina Then Inc(Mv);
      if (j < NxM) And (i > 1) And Pole[i-1,j+1].Mina Then Inc(Mv);
      Pole[i,j].Schot:= Mv;
     end;
   end;
end;

Procedure OpenPole(i,j: Integer);
begin
 if Pole[i,j].Mina Or Pole[i,j].Visibl Then Exit;
 Pole[i,j].Visibl:= True;
 if Pole[i,j].Schot <> 0 Then Exit;
 if (i > 1) And Not(Pole[i-1,j].Mina) Then OpenPole(i-1,j);
 if (i < NxM) And Not(Pole[i+1,j].Mina) Then OpenPole(i+1,j);
 if (j > 1) And Not(Pole[i,j-1].Mina) Then OpenPole(i,j-1);
 if (j < NxM) And Not(Pole[i,j+1].Mina) Then OpenPole(i,j+1);
 if (i > 1) And (j > 1) And Not(Pole[i-1,j-1].Mina) Then OpenPole(i-1,j-1);
 if (i < NxM) And (j < NxM) And Not(Pole[i+1,j+1].Mina) Then OpenPole(i+1,j+1);
 if (j > 1) And (i < NxM) And Not(Pole[i+1,j-1].Mina) Then OpenPole(i+1,j-1);
 if (j < NxM) And (i > 1) And Not(Pole[i-1,j+1].Mina) Then OpenPole(i-1,j+1);
end;

Function IntToStr(Value: Integer): String;
Asm
 XOR ECX, ECX
 PUSH ECX
 ADD ESP, -0Ch
 PUSH EBX
 LEA EBX, [ESP + 15 + 4]
 PUSH EDX
 CMP EAX, ECX
 PUSHFD
 JGE @@1
 NEG EAX
@@1:
 MOV CL, 10
@@2:
 DEC EBX
 CDQ
 IDIV ECX
 ADD DL, 30h
 MOV [EBX], DL
 TEST EAX, EAX
 JNZ @@2
 POPFD
 JGE @@3
 DEC EBX
 MOV byte ptr [EBX], '-'
@@3:
 POP EAX
 MOV EDX, EBX
 CALL System.@LStrFromPChar
 POP EBX
 ADD ESP, 10h
end;

Procedure PlayerWin;
var
 i, j, k: Integer;
begin
 k:= 0;
 For i:= 1 To NxM Do
  For j:= 1 To NxM Do
   begin
    if Pole[i,j].Mina And Pole[i,j].MinaUst And Not(Pole[i,j].Visibl) Then Inc(k);
   end;
 if k = MinCount Then
  begin
   IGame:= 334;
   MessageBox(Hw,'Вы выиграли.','Сапёр',MB_OK);
  end;
end;

Procedure DrowPole;
var
 i, j: Integer;
 R: TRect;
 LogFont: TLogFont;
 Font: Thandle;
begin
 if IGame = 500 Then
  begin
   SelectObject(VideoBuff,GetStockObject(DC_BRUSH));
   SetDCBrushColor(VideoBuff, clBlack);
   SelectObject(VideoBuff,GetStockObject(DC_PEN));
   SetDCPenColor(VideoBuff, clGray);
   Rectangle(VideoBuff,0,0,NxM * RElem,NxM * RElem);
   BitBlt(SDC, 0, 0, NxM * RElem,NxM * RElem, VideoBuff, 0, 0, SRCCOPY);
   Exit;
  end;
 if IGame = 334 Then Exit;
 For i:= 1 To NxM Do
  For j:= 1 To NxM Do
   begin
   if Pole[i,j].Visibl Then
    begin
     if Pole[i,j].Mina Then
      begin
       SelectObject(VideoBuff,GetStockObject(DC_BRUSH));
       SetDCBrushColor(VideoBuff, clWhite);
       SelectObject(VideoBuff,GetStockObject(DC_PEN));
       SetDCPenColor(VideoBuff, clGray);
       Rectangle(VideoBuff,(i-1)*RElem,(j-1)*RElem,(i-1)*RElem+RElem,(j-1)*RElem+RElem);
       SelectObject(VideoBuff,GetStockObject(DC_BRUSH));
       SetDCBrushColor(VideoBuff, clRed);
       SelectObject(VideoBuff,GetStockObject(DC_PEN));
       SetDCPenColor(VideoBuff, clWhite);
       Ellipse(VideoBuff,(i-1)*RElem+2,(j-1)*RElem+2,(i-1)*RElem+RElem-2,(j-1)*RElem+RElem-2);
      end;
     if Pole[i,j].Schot > 0 Then
      begin
       SelectObject(VideoBuff,GetStockObject(DC_BRUSH));
       SetDCBrushColor(VideoBuff, clWhite);
       SelectObject(VideoBuff,GetStockObject(DC_PEN));
       SetDCPenColor(VideoBuff, clGray);
       Rectangle(VideoBuff,(i-1)*RElem,(j-1)*RElem,(i-1)*RElem+RElem,(j-1)*RElem+RElem);
       SetBkMode(VideoBuff, TRANSPARENT);
       Case Pole[i,j].Schot of
         1: SetTextColor(VideoBuff,clBlue);
         2: SetTextColor(VideoBuff,clGreen);
         3: SetTextColor(VideoBuff,clRed);
         4: SetTextColor(VideoBuff,clNavy);
         5: SetTextColor(VideoBuff,clMaroon);
         6: SetTextColor(VideoBuff,clTeal);
         7: SetTextColor(VideoBuff,clBlack);
         8: SetTextColor(VideoBuff,clGray);
       end;
       R.Left:= (i-1)*RElem+4;
       R.Top:= (j-1)*RElem+1;
       R.Right:= (i-1)*RElem+100;
       R.Bottom:= (j-1)*RElem+100;
       SelectObject(VideoBuff,GetStockObject(SYSTEM_FIXED_FONT));
       DrawText(VideoBuff,PAnsiChar(IntToStr(Pole[i,j].Schot)),1,R,DT_LEFT);
      end;
     if Not(Pole[i,j].Mina) And (Pole[i,j].Schot = 0) Then
      begin
       SelectObject(VideoBuff,GetStockObject(DC_BRUSH));
       SetDCBrushColor(VideoBuff, clWhite);
       SelectObject(VideoBuff,GetStockObject(DC_PEN));
       SetDCPenColor(VideoBuff, clGray);
       Rectangle(VideoBuff,(i-1)*RElem,(j-1)*RElem,(i-1)*RElem+RElem,(j-1)*RElem+RElem);
      end;
     end
    Else
    begin
     SelectObject(VideoBuff,GetStockObject(DC_BRUSH));
     SetDCBrushColor(VideoBuff, clSilver);
     SelectObject(VideoBuff,GetStockObject(DC_PEN));
     SetDCPenColor(VideoBuff, clGray);
     Rectangle(VideoBuff,(i-1)*RElem,(j-1)*RElem,(i-1)*RElem+RElem,(j-1)*RElem+RElem);
    end;
    if Not(Pole[i,j].Visibl) And Pole[i,j].MinaUst Then
     begin
      SelectObject(VideoBuff,GetStockObject(DC_BRUSH));
      SetDCBrushColor(VideoBuff, clBlue);
      SelectObject(VideoBuff,GetStockObject(DC_PEN));
      SetDCPenColor(VideoBuff, clSilver);
      Ellipse(VideoBuff,(i-1)*RElem+2,(j-1)*RElem+2,(i-1)*RElem+RElem-2,(j-1)*RElem+RElem-2);
     end;
    if (IGame = 333)And Pole[i,j].MinaUst And Not(Pole[i,j].Mina) Then
     begin
      SelectObject(VideoBuff,GetStockObject(DC_BRUSH));
      SetDCBrushColor(VideoBuff, clBlue);
      SelectObject(VideoBuff,GetStockObject(DC_PEN));
      SetDCPenColor(VideoBuff, clSilver);
      Ellipse(VideoBuff,(i-1)*RElem+2,(j-1)*RElem+2,(i-1)*RElem+RElem-2,(j-1)*RElem+RElem-2);
      SelectObject(VideoBuff,CreatePen(PS_SOLID,3,clRed));
      MoveToEx(VideoBuff,(i-1)*RElem+2,(j-1)*RElem+2,Nil);
      LineTo(VideoBuff,(i-1)*RElem+RElem-3,(j-1)*RElem+RElem-3);
     end;
    if Pole[i,j].Schot = -1 Then
     begin
      SelectObject(VideoBuff,GetStockObject(DC_BRUSH));
      SetDCBrushColor(VideoBuff, clBlack);
      SelectObject(VideoBuff,GetStockObject(DC_PEN));
      SetDCPenColor(VideoBuff, clBlack);
      Rectangle(VideoBuff,(i-1)*RElem,(j-1)*RElem,(i-1)*RElem+RElem,(j-1)*RElem+RElem);
      SelectObject(VideoBuff,GetStockObject(DC_BRUSH));
      SetDCBrushColor(VideoBuff, clRed);
      Ellipse(VideoBuff,(i-1)*RElem+2,(j-1)*RElem+2,(i-1)*RElem+RElem-2,(j-1)*RElem+RElem-2);
     end;
   end;
 if IGame = 333 Then
  begin
   LogFont.lfheight:= 80;
   LogFont.lfwidth:= 40;
   LogFont.lfweight:= 0;
   LogFont.lfEscapement:= 0;
   LogFont.lfcharset:= 0;
   LogFont.lfoutprecision:= OUT_DEFAULT_PRECIS;
   LogFont.lfquality:= DEFAULT_QUALITY;
   LogFont.lfpitchandfamily:= FF_ROMAN;
   Font:= CreateFontIndirect(LogFont);
   Selectobject(VideoBuff, Font);
   R.Left:= 50;
   R.Top:= 250;
   R.Right:= 800;
   R.Bottom:= 800;
   DrawText(VideoBuff,'Game Over!',10,R,1);
   Deleteobject(Font);
   Windows.Beep(256,256);
   IGame:= 334;
  end;
 BitBlt(SDC, 0, 0, NxM * RElem,NxM * RElem, VideoBuff, 0, 0, SRCCOPY);
 PlayerWin;
end;

Procedure SaperMenu;
begin
if IGame = 334 Then
 begin
  ClearPole;
  RandomMine;
  SchotMin;
  IGame:= 0;
  DrowPole;
 end;
if IGame = 500 Then IGame:= 0
   Else IGame:= 500;
DrowPole;
end;

Procedure OpenPoleEND;
var
 i,j: Integer;
begin
 if IGame = 334 Then Exit;
 For i:= 1 To NxM Do
  For j:= 1 To NxM Do
   begin
    if Pole[i,j].Mina And Not(Pole[i,j].MinaUst) Then Pole[i,j].Visibl:= True;
   end;
 IGame:= 333;
end;

Procedure MouseLdown(i,j: Integer);
var
 x,y: Integer;
begin
 if  IGame = 500 Then Exit;
 x:= (i Div RElem) + 1;
 y:= (j Div RElem) + 1;
 if Pole[x,y].Mina Then begin Pole[x,y].Schot:=-1; OpenPoleEND; end
  Else OpenPole(x, y);
end;

Procedure MouseRdown(i,j: Integer);
var
 x,y: Integer;
begin
 if  IGame = 500 Then Exit;
 x:= (i Div RElem) + 1;
 y:= (j Div RElem) + 1;
 if Not(Pole[x,y].Visibl) And Not(Pole[x,y].MinaUst) Then Pole[x,y].MinaUst:= True
    Else Pole[x,y].MinaUst:= False;
end;

Procedure MouseMdown(i,j: Integer);
var
 x,y,Mv: Integer;
begin
 x:= (i Div RElem) + 1;
 y:= (j Div RElem) + 1;
 if (Pole[x,y].Visibl) And (Pole[x,y].Schot > 0) Then
  begin
   Mv:= 0;
   if (x > 1) And Pole[x-1,y].MinaUst Then Inc(Mv);
   if (x < NxM) And Pole[x+1,y].MinaUst Then Inc(Mv);
   if (y > 1) And Pole[x,y-1].MinaUst Then Inc(Mv);
   if (y < NxM) And Pole[x,y+1].MinaUst Then Inc(Mv);
   if (x > 1) And (y > 1) And Pole[x-1,y-1].MinaUst Then Inc(Mv);
   if (x < NxM) And (y < NxM) And Pole[x+1,y+1].MinaUst Then Inc(Mv);
   if (y > 1) And (x < NxM) And Pole[x+1,y-1].MinaUst Then Inc(Mv);
   if (y < NxM) And (x > 1) And Pole[x-1,y+1].MinaUst Then Inc(Mv);
   if Mv = Pole[x,y].Schot Then
    begin
     if (x > 1)And Not(Pole[x-1,y].MinaUst) Then
     if Not(Pole[x-1,y].Visibl) And Pole[x-1,y].Mina Then
      begin Pole[x-1,y].Schot:=-1; OpenPoleEND; end
        Else OpenPole(x-1, y);
     if (x < NxM) And Not(Pole[x+1,y].MinaUst) Then
     if Not(Pole[x+1,y].Visibl) And Pole[x+1,y].Mina Then
      begin Pole[x+1,y].Schot:=-1; OpenPoleEND; end
        Else OpenPole(x+1, y);
     if (y > 1) And Not(Pole[x,y-1].MinaUst) Then
     if Not(Pole[x,y-1].Visibl) And Pole[x,y-1].Mina Then
      begin Pole[x,y-1].Schot:=-1; OpenPoleEND; end
        Else OpenPole(x, y-1);
     if (y < NxM) And Not(Pole[x,y+1].MinaUst) Then
     if Not(Pole[x,y+1].Visibl) And Pole[x,y+1].Mina Then
      begin Pole[x,y+1].Schot:=-1; OpenPoleEND; end
        Else OpenPole(x, y+1);
     if(x > 1) And (y > 1) Then
     if Not(Pole[x-1,y-1].MinaUst) And Not(Pole[x-1,y-1].Visibl) And Pole[x-1,y-1].Mina Then
      begin Pole[x-1,y-1].Schot:=-1; OpenPoleEND; end
        Else OpenPole(x-1,y-1);
     if (x < NxM) And (y < NxM) Then
     if Not(Pole[x+1,y+1].MinaUst) And Not(Pole[x+1,y+1].Visibl) And Pole[x+1,y+1].Mina Then
      begin Pole[x+1,y+1].Schot:=-1; OpenPoleEND; end
        Else OpenPole(x+1,y+1);
     if (y > 1) And (x < NxM) Then
     if Not(Pole[x+1,y-1].MinaUst) And Not(Pole[x+1,y-1].Visibl) And Pole[x+1,y-1].Mina Then
      begin Pole[x+1,y-1].Schot:=-1; OpenPoleEND; end
        Else OpenPole(x+1,y-1);
     if (y < NxM) And (x > 1) Then
     if Not(Pole[x-1,y+1].MinaUst) And Not(Pole[x-1,y+1].Visibl) And Pole[x-1,y+1].Mina Then
      begin Pole[x-1,y+1].Schot:=-1; OpenPoleEND; end
        Else OpenPole(x-1,y+1);
    end;
  end;
end;

Function WindowProc(Hw: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
begin
 Result:= 0;
 Case Msg of
  $0002:
   begin
    ReleaseDC(Hw, SDC);
    DeleteDC(VideoBuff);
    DeleteObject(Bmp);
    PostQuitMessage(0);
    Result:= 0;
    Exit;
   end;
  $0100:
   begin
    if wParam = 27 Then SaperMenu;
    if wParam = VK_F2 Then
     begin
      ClearPole;
      RandomMine;
      SchotMin;
      IGame:= 0;
      DrowPole;
     end;
   end;
  $0201:
   begin
    MouseLdown(LOWORD(lParam),HIWORD(lParam));
    DrowPole;
    Flag1:= True;
   end;
  $0202: Flag1:= False;
  $0204:
   begin
    MouseRdown(LOWORD(lParam),HIWORD(lParam));
    DrowPole;
    Flag:= True;
   end;
  $0205: Flag:= False;
  $0014: BitBlt(SDC, 0, 0, NxM * RElem,NxM * RElem, VideoBuff, 0, 0, SRCCOPY);
  Else
   Result:= DefWindowProc(Hw, Msg, wParam, lParam);
 end;
 if Flag And Flag1 Then
     begin
      MouseMdown(LOWORD(lParam),HIWORD(lParam));
      DrowPole;
     end;
end;

Begin
 Wc.cbSize:= SizeOf(Wc);
 Wc.style:= CS_HREDRAW or CS_VREDRAW;
 Wc.lpfnWndProc:= @WindowProc;
 Wc.hInstance:= hInstance;
 Wc.hCursor:= LoadCursor(0, IDC_ARROW);
 Wc.hbrBackground:= $10;
 Wc.lpszClassName:= 'WinSaper';
 RegisterClassEx(Wc);
 Hw:= CreateWindowEx(0, 'WinSaper', 'Сапёр', WS_SYSMENU or WS_MINIMIZEBOX,
                     100, 50, NxM*RElem+6, NxM*RElem+26, 0, 0, hInstance, nil);
 ShowWindow(Hw, SW_SHOWNORMAL);
 SDC:= GetDC(Hw);
 VideoBuff:= CreateCompatibleDC(SDC);
 Bmp:= CreateCompatibleBitmap(SDC, NxM * RElem, NxM * RElem);
 SelectObject(VideoBuff, Bmp);
 ClearPole;
 RandomMine;
 SchotMin;
 DrowPole;
 While GetMessage(Msg, 0, 0, 0) do
  begin
   TranslateMessage(Msg);
   DispatchMessage(Msg);
  end;
 Halt(Msg.wParam);
End.
