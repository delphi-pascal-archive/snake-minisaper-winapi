// Написал прогу: Боровик А.В, Mail: peexe@mail.ru
// F2 - Новая игра; ESC - Выход.
Program Sneiks;
Uses
 Windows;

Const
 Re = 10;                // Размер елементов поля/червя в пикс.
 MaxLength = 100;        // Максимальная длина червя.
 Prep = 50;              // К-во препятствий.
 mSp = 30;               // Макс скорость мс. 
 WM_KEYDOWN = $0100;     // Вместо модуля Messages).

Var
 ElS: Array [0..MaxLength] of TPoint; // Массив для червя.
 ElP: Array of Array of Byte;         // Матрица поля игры.
 Wc: TWndClassEx;        // Класс окна.
 Msg: TMsg;              // Сообщения.
 H: HWND;                // Идентификатор окна.
 R,Rt: TRect;            // Размеры игровой области (экрана) в пикс.
 SC: HDC;                // Указатель для рисования.
 Napr: Integer = 1;      // Направление движения червя (в право).
 N1,N2,N3,N4: Boolean;   // Направления ограничения червя.
 X: Integer = 10;        // Начальная ячейка старта червя Х.
 Y: Integer = 10;        // Начальная ячейка старта червя У.
 Sp: Integer = 100;      // Скорость движения червя (при старте = 100мс).
 L: Integer = 3;         // Длина червя (при старте = 3).
 EnTime: Boolean = True; // Движение вкл./выкл.
 Width, Height: Integer; // Ширина, высота матрици поля.
 Bm: Integer;            // Для мерцания "еды".

// Инициализация поля игры.
Procedure InitElP;
Var
 i,j: Integer;
begin
 Randomize;
 Width:= R.Right Div Re;        // Расчёт ширины матрици.
 Height:= R.Bottom Div Re;      // Расчёт высоты матрици.
 SetLength(ElP, Width, Height); // Установка размера матрици.
 For i:= 0 To Width - 1 Do
 For j:= 0 To Height - 1 Do
  begin
   ElP[i,j]:= $00;              // Перебераем елементы матрици и
   ElP[i,0]:= $AA;              // заполняем её по краям стенкой
   ElP[i,Height-1]:= $AA;       // $AA - стенка:-).
   ElP[0,j]:= $AA;
   ElP[Width-1,j]:= $AA;
  end;
end;

// Инициализация массива червя.
Procedure InitElS;
Var
 i: Integer;
begin
 For i:= 0 To MaxLength - 1 Do  // Перебераем
  begin
   ElS[i].X:= -1000;            // -1000 чтоб не рисовались
   ElS[i].Y:= -1000;            // незаполненые елементы червя.
  end;
end;

// Случайное создание препятствий.
Procedure Stenki;
Var
 i,Rx,Ry: Integer;
begin
 Randomize;
 i:= 0;
 While i < Prep Do
  begin
   Rx:= Random(Width-2)+1;      // Случ. генерация.
   Ry:= Random(Height-2)+1;
   if ElP[Rx,Ry] <> $AA Then    // Проверка есть стенка в ячейке.
    begin
     ElP[Rx,Ry]:= $AA;
     Inc(i);                    // Счётчик препятствий.
    end;
  end;
end;

// Случайная генерация "еды" для червя.
Procedure RandomElP;
Var
 i,Ri,Rj: Integer;
 P: Boolean;
begin
 Randomize;
 P:= True;
 Repeat
  Ri:= Random(Width-2)+1;       // Случ. генерация.
  Rj:= Random(Height-2)+1;
  For i:= 0 To MaxLength - 1 Do // Проверка чтоб не сгенерировать на черве и
   if (ElS[i].X = Ri) And (ElS[i].Y = Rj) Then P:= False;
 Until (ElP[Ri,Rj] <> $AA) And P; // на стенке.
 ElP[Ri,Rj]:= $FF;                // $FF - "еда".
end;

// Главная процедура расчёта червя.
// Xo, Yo - Координаты "головы" червя.
Procedure CalkSneik(Xo, Yo: Integer);
Var
 i: Integer;
begin
 ElS[0].X:= Xo;           // Передаём начало в массив.
 ElS[0].Y:= Yo;
 For i:= L DownTo 1 Do
  begin
   ElS[i].X:= ElS[i-1].X; // Рассчитываем остальные елементы червя.
   ElS[i].Y:= ElS[i-1].Y;
  end;
end;

// Выиграш  /  проиграш. 
Procedure Win_Over;
Var
 LogFont: TLogFont;
 Font: THandle;
begin
 Rt.Left:= R.Left;
 Rt.Top:= 300;                       // Позиция текста.
 Rt.Right:= R.Right;
 Rt.Bottom:= R.Bottom;
 SetTextColor(SC, RGB(255,0,0));     // Текст красный.
 LogFont.lfheight:= 80;              // Создаём шрифт.
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
  DrawText(SC, 'You Win!', 8, Rt, DT_CENTER)  // Вывод.
  Else DrawText(SC, 'Game Over!', 10, Rt, DT_CENTER);
 DeleteObject(Font); 
end;

// Процедура сравнения червя и поля и принятия действий.
Procedure CompareElPxElS;
Var
 i,Xo,Yo: Integer;
begin
 Xo:= ElS[0].X;
 Yo:= ElS[0].Y;
 if ElP[Xo,Yo] = $FF Then  // Если "вехали" в "еду" то
  begin
   ElP[Xo,Yo]:= 0;                // очищаем текущее поле.
   if L < MaxLength Then Inc(L)   // увеличиваем длину если меньше мах.
    Else EnTime:= False;          // Стоп. Выигрыш.
   RandomElP;                     // Генерируем еду.
   Dec(Sp);                       // Увеличиваем скорость.
   if Sp <= mSp Then Sp:= mSp;
  end; //i:=4 потому что врядле кто то круче завернёт чтоб сесть себя).
 For i:= 4 To MaxLength - 1 Do
  if (ElS[i].X = Xo) And (ElS[i].Y = Yo) Then EnTime:= False; // Сьели сами себя.
 if ElP[Xo,Yo] = $AA Then EnTime:= False; // Если "вехали" в стену - СТОП.
end;

// Счётчик координат движения.
Procedure Schotchik;
begin
 if N1 And (Napr = 2) Then Napr:= 1;  //  Ограничения
 if N2 And (Napr = 1) Then Napr:= 2;  //     на
 if N3 And (Napr = 4) Then Napr:= 3;  //   движения.
 if N4 And (Napr = 3) Then Napr:= 4;
 N1:= False; N2:= False; N3:= False; N4:= False;
 Case Napr Of                         // Выбор направлений движения.
  1: begin Inc(X); N1:= True; end;
  2: begin Dec(X); N2:= True; end;
  3: begin Inc(Y); N3:= True; end;
  4: begin Dec(Y); N4:= True; end;
 end;
 CalkSneik(X, Y);   // Считаем массив червя.
 CompareElPxElS;    // Сравнивем.
end;

// Процедура рисования.
Procedure DrowPole;
Var
 i,j: Integer;
begin   // Рисуем поле.
 Bm:= Bm + 25;              // Скорость мерцания.
 if Bm >= 255 Then Bm:= 0;
 SelectObject(SC, GetStockObject(DC_BRUSH));
 For i:= 0 To Width - 1 Do
  For j:= 0 To Height - 1 Do
   begin
    if ElP[i,j] = $AA Then  // Стенка.
     begin
      SetDCBrushColor(SC, RGB(255,255,255)); // Рисуем белым.
      Rectangle(SC, i*Re, j*Re, i*Re + Re, j*Re + Re);
     end;
    if ElP[i,j] = $FF Then  // Еда.
     begin
      SetDCBrushColor(SC, RGB(255-Bm,0,Bm));   // Рисуем еду.
      Rectangle(SC, i*Re, j*Re, i*Re + Re, j*Re + Re);
     end;
   end; // Рисуем червя.
 For i:= 0 To L Do
  begin
   if i = 1 Then SetDCBrushColor(SC, RGB(255,0,0)) // Первый красный.
            Else SetDCBrushColor(SC, RGB(0,255,0));// Последующие зелёные.
   if i = L Then SetDCBrushColor(SC, RGB(0,0,0));  // Последний чёрный.
   Rectangle(SC, ElS[i].X*Re, ElS[i].Y*Re, ElS[i].X*Re + Re, ElS[i].Y*Re + Re);
  end;
 if Not(EnTime) Then Win_Over;   //Рис. надпись.
end;

// Таймер.
Procedure TimerProc; stdcall;
begin
 if EnTime Then  // Вкл./Выкл.
  begin
   Schotchik;    // Рассчитываем.
   DrowPole;     // Рисуем.
  end;
end;

// Новая.
Procedure NewGame;
begin
 N1:= False; N2:= False; N3:= False; N4:= False;
 Bm:= 0;                            // Уст. нач. значений.
 L:= 3;
 X:= 10;
 Y:= 10;
 Napr:= 1;
 Sp:= 100;
 InitElP;                           // Инициализируем массивы.
 InitElS;
 Stenki;                            // Генерация припятствий.
 RandomElP;                         // Генерируем "еду".
 EnTime:= True;
 SetDCBrushColor(SC, RGB(0,0,0));   // Очистим рис.
 Rectangle(SC, R.Left, R.Top, R.Right, R.Bottom);
end;

// Ф-нц обработки сообщений окну.
Function WndProc(W, M, Wp, Lp:Integer):Integer; stdcall;
Begin
 Result:= 0;
 Case M of
  WM_KEYDOWN:   // Нажата клавиша.
   begin
    Case Wp Of
     VK_F2: NewGame;
     VK_ESCAPE: PostQuitMessage(0);  // Выход.
     VK_RIGHT: Napr:= 1;             // Установка направлений.
     VK_LEFT: Napr:= 2;
     VK_DOWN: Napr:= 3;
     VK_UP: Napr:= 4;
    end; 
   end;
  Else Result:= DefWindowProc(W, M, Wp, Lp);
 end;
end;

// Начало.)
Begin
Wc.cbSize:= SizeOf(Wc);  // Заполняем класс окна.
Wc.style:= CS_PARENTDC;
Wc.lpfnWndProc:= @WndProc;
Wc.cbClsExtra:= 0;
Wc.cbWndExtra:= 0;
Wc.hCursor:= LoadCursor(0, IDC_ARROW);
Wc.hbrBackground:= CreateSolidBrush(RGB(0, 0, 0));
Wc.lpszClassName:= '_W';
RegisterClassEx(Wc);     // Регистрируем класс.
GetWindowRect(GetDesktopWindow, R); // Узнаём размер экрана.
// Создаём окно.
H:= CreateWindowEx(0,'_W','0',WS_VISIBLE or WS_POPUP, R.Left, R.Top, R.Right, R.Bottom, 0, 0, 0, Nil);
// Разворачиваем на ввесь экран.
SetWindowPos(H, HWND_TOPMOST, R.left, R.top, R.Right, R.Bottom, SWP_SHOWWINDOW);
ShowCursor(False);                 // Убираем курсор.
ShowWindow(H, SW_SHOW);            // Показуем окно.
SetTimer(H, 777, Sp, @TimerProc);  // Устанавливаем таймер.
SC:= GetDC(H);                     // Указываем окно для рис.
InitElP;                           // Инициализируем массивы.
InitElS;
Stenki;                            // Генерация припятствий.
RandomElP;                         // Генерируем "еду".
While GetMessage(Msg, 0, 0, 0) Do
 begin
  TranslateMessage(Msg);           // Цикл обработки сообщений окну.
  DispatchMessage(Msg);
 end;
ReleaseDC(H, SC);                  // Разрушаем рис. при выходе.
end.
