// ������� �����: ������� �.�, Mail: peexe@mail.ru
// F2 - ����� ����; ESC - �����.
Program Sneiks;
Uses
 Windows;

Const
 Re = 10;                // ������ ��������� ����/����� � ����.
 MaxLength = 100;        // ������������ ����� �����.
 Prep = 50;              // �-�� �����������.
 mSp = 30;               // ���� �������� ��. 
 WM_KEYDOWN = $0100;     // ������ ������ Messages).

Var
 ElS: Array [0..MaxLength] of TPoint; // ������ ��� �����.
 ElP: Array of Array of Byte;         // ������� ���� ����.
 Wc: TWndClassEx;        // ����� ����.
 Msg: TMsg;              // ���������.
 H: HWND;                // ������������� ����.
 R,Rt: TRect;            // ������� ������� ������� (������) � ����.
 SC: HDC;                // ��������� ��� ���������.
 Napr: Integer = 1;      // ����������� �������� ����� (� �����).
 N1,N2,N3,N4: Boolean;   // ����������� ����������� �����.
 X: Integer = 10;        // ��������� ������ ������ ����� �.
 Y: Integer = 10;        // ��������� ������ ������ ����� �.
 Sp: Integer = 100;      // �������� �������� ����� (��� ������ = 100��).
 L: Integer = 3;         // ����� ����� (��� ������ = 3).
 EnTime: Boolean = True; // �������� ���./����.
 Width, Height: Integer; // ������, ������ ������� ����.
 Bm: Integer;            // ��� �������� "���".

// ������������� ���� ����.
Procedure InitElP;
Var
 i,j: Integer;
begin
 Randomize;
 Width:= R.Right Div Re;        // ������ ������ �������.
 Height:= R.Bottom Div Re;      // ������ ������ �������.
 SetLength(ElP, Width, Height); // ��������� ������� �������.
 For i:= 0 To Width - 1 Do
 For j:= 0 To Height - 1 Do
  begin
   ElP[i,j]:= $00;              // ���������� �������� ������� �
   ElP[i,0]:= $AA;              // ��������� � �� ����� �������
   ElP[i,Height-1]:= $AA;       // $AA - ������:-).
   ElP[0,j]:= $AA;
   ElP[Width-1,j]:= $AA;
  end;
end;

// ������������� ������� �����.
Procedure InitElS;
Var
 i: Integer;
begin
 For i:= 0 To MaxLength - 1 Do  // ����������
  begin
   ElS[i].X:= -1000;            // -1000 ���� �� ����������
   ElS[i].Y:= -1000;            // ������������ �������� �����.
  end;
end;

// ��������� �������� �����������.
Procedure Stenki;
Var
 i,Rx,Ry: Integer;
begin
 Randomize;
 i:= 0;
 While i < Prep Do
  begin
   Rx:= Random(Width-2)+1;      // ����. ���������.
   Ry:= Random(Height-2)+1;
   if ElP[Rx,Ry] <> $AA Then    // �������� ���� ������ � ������.
    begin
     ElP[Rx,Ry]:= $AA;
     Inc(i);                    // ������� �����������.
    end;
  end;
end;

// ��������� ��������� "���" ��� �����.
Procedure RandomElP;
Var
 i,Ri,Rj: Integer;
 P: Boolean;
begin
 Randomize;
 P:= True;
 Repeat
  Ri:= Random(Width-2)+1;       // ����. ���������.
  Rj:= Random(Height-2)+1;
  For i:= 0 To MaxLength - 1 Do // �������� ���� �� ������������� �� ����� �
   if (ElS[i].X = Ri) And (ElS[i].Y = Rj) Then P:= False;
 Until (ElP[Ri,Rj] <> $AA) And P; // �� ������.
 ElP[Ri,Rj]:= $FF;                // $FF - "���".
end;

// ������� ��������� ������� �����.
// Xo, Yo - ���������� "������" �����.
Procedure CalkSneik(Xo, Yo: Integer);
Var
 i: Integer;
begin
 ElS[0].X:= Xo;           // ������� ������ � ������.
 ElS[0].Y:= Yo;
 For i:= L DownTo 1 Do
  begin
   ElS[i].X:= ElS[i-1].X; // ������������ ��������� �������� �����.
   ElS[i].Y:= ElS[i-1].Y;
  end;
end;

// �������  /  ��������. 
Procedure Win_Over;
Var
 LogFont: TLogFont;
 Font: THandle;
begin
 Rt.Left:= R.Left;
 Rt.Top:= 300;                       // ������� ������.
 Rt.Right:= R.Right;
 Rt.Bottom:= R.Bottom;
 SetTextColor(SC, RGB(255,0,0));     // ����� �������.
 LogFont.lfheight:= 80;              // ������ �����.
 LogFont.lfwidth:= 40;
 LogFont.lfweight:= 0;
 LogFont.lfEscapement:= 0;
 LogFont.lfcharset:= 0;
 LogFont.lfoutprecision:= OUT_DEFAULT_PRECIS;
 LogFont.lfquality:= DEFAULT_QUALITY;
 LogFont.lfpitchandfamily:= FF_DONTCARE;
 Font:= CreateFontIndirect(LogFont);
 SelectObject(SC, Font);
 if L >= MaxLength Then
  DrawText(SC, 'You Win!', 8, Rt, DT_CENTER)  // �����.
  Else DrawText(SC, 'Game Over!', 10, Rt, DT_CENTER);
 DeleteObject(Font); 
end;

// ��������� ��������� ����� � ���� � �������� ��������.
Procedure CompareElPxElS;
Var
 i,Xo,Yo: Integer;
begin
 Xo:= ElS[0].X;
 Yo:= ElS[0].Y;
 if ElP[Xo,Yo] = $FF Then  // ���� "������" � "���" ��
  begin
   ElP[Xo,Yo]:= 0;                // ������� ������� ����.
   if L < MaxLength Then Inc(L)   // ����������� ����� ���� ������ ���.
    Else EnTime:= False;          // ����. �������.
   RandomElP;                     // ���������� ���.
   Dec(Sp);                       // ����������� ��������.
   if Sp <= mSp Then Sp:= mSp;
  end; //i:=4 ������ ��� ������ ��� �� ����� ������� ���� ����� ����).
 For i:= 4 To MaxLength - 1 Do
  if (ElS[i].X = Xo) And (ElS[i].Y = Yo) Then EnTime:= False; // ����� ���� ����.
 if ElP[Xo,Yo] = $AA Then EnTime:= False; // ���� "������" � ����� - ����.
end;

// ������� ��������� ��������.
Procedure Schotchik;
begin
 if N1 And (Napr = 2) Then Napr:= 1;  //  �����������
 if N2 And (Napr = 1) Then Napr:= 2;  //     ��
 if N3 And (Napr = 4) Then Napr:= 3;  //   ��������.
 if N4 And (Napr = 3) Then Napr:= 4;
 N1:= False; N2:= False; N3:= False; N4:= False;
 Case Napr Of                         // ����� ����������� ��������.
  1: begin Inc(X); N1:= True; end;
  2: begin Dec(X); N2:= True; end;
  3: begin Inc(Y); N3:= True; end;
  4: begin Dec(Y); N4:= True; end;
 end;
 CalkSneik(X, Y);   // ������� ������ �����.
 CompareElPxElS;    // ���������.
end;

// ��������� ���������.
Procedure DrowPole;
Var
 i,j: Integer;
begin   // ������ ����.
 Bm:= Bm + 25;              // �������� ��������.
 if Bm >= 255 Then Bm:= 0;
 SelectObject(SC, GetStockObject(DC_BRUSH));
 For i:= 0 To Width - 1 Do
  For j:= 0 To Height - 1 Do
   begin
    if ElP[i,j] = $AA Then  // ������.
     begin
      SetDCBrushColor(SC, RGB(255,255,255)); // ������ �����.
      Rectangle(SC, i*Re, j*Re, i*Re + Re, j*Re + Re);
     end;
    if ElP[i,j] = $FF Then  // ���.
     begin
      SetDCBrushColor(SC, RGB(255-Bm,0,Bm));   // ������ ���.
      Rectangle(SC, i*Re, j*Re, i*Re + Re, j*Re + Re);
     end;
   end; // ������ �����.
 For i:= 0 To L Do
  begin
   if i = 1 Then SetDCBrushColor(SC, RGB(255,0,0)) // ������ �������.
            Else SetDCBrushColor(SC, RGB(0,255,0));// ����������� ������.
   if i = L Then SetDCBrushColor(SC, RGB(0,0,0));  // ��������� ������.
   Rectangle(SC, ElS[i].X*Re, ElS[i].Y*Re, ElS[i].X*Re + Re, ElS[i].Y*Re + Re);
  end;
 if Not(EnTime) Then Win_Over;   //���. �������.
end;

// ������.
Procedure TimerProc; stdcall;
begin
 if EnTime Then  // ���./����.
  begin
   Schotchik;    // ������������.
   DrowPole;     // ������.
  end;
end;

// �����.
Procedure NewGame;
begin
 N1:= False; N2:= False; N3:= False; N4:= False;
 Bm:= 0;                            // ���. ���. ��������.
 L:= 3;
 X:= 10;
 Y:= 10;
 Napr:= 1;
 Sp:= 100;
 InitElP;                           // �������������� �������.
 InitElS;
 Stenki;                            // ��������� �����������.
 RandomElP;                         // ���������� "���".
 EnTime:= True;
 SetDCBrushColor(SC, RGB(0,0,0));   // ������� ���.
 Rectangle(SC, R.Left, R.Top, R.Right, R.Bottom);
end;

// �-�� ��������� ��������� ����.
Function WndProc(W, M, Wp, Lp:Integer):Integer; stdcall;
Begin
 Result:= 0;
 Case M of
  WM_KEYDOWN:   // ������ �������.
   begin
    Case Wp Of
     VK_F2: NewGame;
     VK_ESCAPE: PostQuitMessage(0);  // �����.
     VK_RIGHT: Napr:= 1;             // ��������� �����������.
     VK_LEFT: Napr:= 2;
     VK_DOWN: Napr:= 3;
     VK_UP: Napr:= 4;
    end; 
   end;
  Else Result:= DefWindowProc(W, M, Wp, Lp);
 end;
end;

// ������.)
Begin
Wc.cbSize:= SizeOf(Wc);  // ��������� ����� ����.
Wc.style:= CS_PARENTDC;
Wc.lpfnWndProc:= @WndProc;
Wc.cbClsExtra:= 0;
Wc.cbWndExtra:= 0;
Wc.hCursor:= LoadCursor(0, IDC_ARROW);
Wc.hbrBackground:= CreateSolidBrush(RGB(0, 0, 0));
Wc.lpszClassName:= '_W';
RegisterClassEx(Wc);     // ������������ �����.
GetWindowRect(GetDesktopWindow, R); // ����� ������ ������.
// ������ ����.
H:= CreateWindowEx(0,'_W','0',WS_VISIBLE or WS_POPUP, R.Left, R.Top, R.Right, R.Bottom, 0, 0, 0, Nil);
// ������������� �� ����� �����.
SetWindowPos(H, HWND_TOPMOST, R.left, R.top, R.Right, R.Bottom, SWP_SHOWWINDOW);
ShowCursor(False);                 // ������� ������.
ShowWindow(H, SW_SHOW);            // �������� ����.
SetTimer(H, 777, Sp, @TimerProc);  // ������������� ������.
SC:= GetDC(H);                     // ��������� ���� ��� ���.
InitElP;                           // �������������� �������.
InitElS;
Stenki;                            // ��������� �����������.
RandomElP;                         // ���������� "���".
While GetMessage(Msg, 0, 0, 0) Do
 begin
  TranslateMessage(Msg);           // ���� ��������� ��������� ����.
  DispatchMessage(Msg);
 end;
ReleaseDC(H, SC);                  // ��������� ���. ��� ������.
end.
