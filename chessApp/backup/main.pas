//name of the unit
unit Main;

{$mode objfpc}{$H+}

interface
//each one imports a especific group of predefined functions and procedures
uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Menus, ExtCtrls,
  DefaultTranslator, StdCtrls, About;

type

  { TForm1 }

  //bidimensional array of chess boards
  TchessBoard = array[1..8, 1..8] of integer;

  TForm1 = class(TForm)
    guilhermeGranchoItem: TMenuItem;
    pointsLItem: TLabel;
    pointsDItem: TLabel;
    timerDItem: TLabel;
    timerLItem: TLabel;
    MainMenu1: TMainMenu;
    GameItem: TMenuItem;
    maurizioMongeItem: TMenuItem;
    Timer1: TTimer;
    unlimitedItem: TMenuItem;
    fiveMinItem: TMenuItem;
    tenMinItem: TMenuItem;
    undoItem: TMenuItem;
    redBlackItem: TMenuItem;
    PaintBox1: TPaintBox;
    StylesItem: TMenuItem;
    HelpItem: TMenuItem;
    NewItem: TMenuItem;
    ExitItem: TMenuItem;
    StandardItem: TMenuItem;
    AboutItem: TMenuItem;
    //procedures of the events used
    procedure AboutItemClick(Sender: TObject);
    procedure ExitItemClick(Sender: TObject);
    procedure fiveMinItemClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure guilhermeGranchoItemClick(Sender: TObject);
    procedure maurizioMongeItemClick(Sender: TObject);
    procedure PaintBox1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure PaintBox1Paint(Sender: TObject);
    procedure redBlackItemClick(Sender: TObject);
    procedure StandardItemClick(Sender: TObject);
    procedure tenMinItemClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure undoItemClick(Sender: TObject);
    procedure unlimitedItemClick(Sender: TObject);
  private

  public


  end;

var //global variables
  Form1: TForm1;//form1
  chessPieceImages: array [1..12] of TPortableNetworkGraphic;
  //the array that contains the chess piece images
  board: array[1..8, 1..8] of integer;
  //the bidimensional array that representais and saves the information of the state of the chess board
  aux,//the integer that saves the chess pice in memory
  play,//the integer that saves the player turn
  lastX,//the integer that saves X coordenate of where the player previously clicked
  lastY,//the integer that saves Y coordenate of where the player previously clicked
  horizontalCoordinate,//the integer that saves X coordenate of where the player last clicked
  verticalCoordinate,//the integer that saves Y coordenate of where the player last clicked
  punctuation,//the integer that saves the pontuation of the game
  timerMinL,//the integer that saves the minutes left for the white player
  timerSecD,//the integer that saves the seconds left for the black player
  timerSecL,//the integer that saves the seconds left for the white player
  timerMinD: integer;//the integer that saves the minutes left for the black player
  oldBoard: array[1..500] of TChessBoard;
  //array that saves in the limit 500 chess boards states
  gameHistoricX: array [1..500, 1..2] of
  integer;//array that saves the plays X coordenates so that when clicked undo the previos plays also get highlithed
  gameHistoricY: array [1..500, 1..2] of
  integer;//array that saves the plays Y coordenates so that when clicked undo the previos plays also get highlithed

implementation

{$R *.lfm}

{ TForm1 }

//procedure that loads each picture used for the chess pieces and atributes them a number, it's used a parameter in this procedure so that the player can change the style of the pieces
procedure loadImages(style: string);
begin
  chessPieceImages[1].LoadFromFile('styles/' + style + '/rl.png');
  chessPieceImages[2].LoadFromFile('styles/' + style + '/nl.png');
  chessPieceImages[3].LoadFromFile('styles/' + style + '/bl.png');
  chessPieceImages[4].LoadFromFile('styles/' + style + '/ql.png');
  chessPieceImages[5].LoadFromFile('styles/' + style + '/kl.png');
  chessPieceImages[6].LoadFromFile('styles/' + style + '/pl.png');
  chessPieceImages[7].LoadFromFile('styles/' + style + '/rd.png');
  chessPieceImages[8].LoadFromFile('styles/' + style + '/nd.png');
  chessPieceImages[9].LoadFromFile('styles/' + style + '/bd.png');
  chessPieceImages[10].LoadFromFile('styles/' + style + '/qd.png');
  chessPieceImages[11].LoadFromFile('styles/' + style + '/kd.png');
  chessPieceImages[12].LoadFromFile('styles/' + style + '/pd.png');
end;

//procedure that inicialize the array that represents the chess board giving a number to each bidimensional valeu of the array
procedure inicialBoard;

var
  counter1, counter2: integer;//counter for the cycles for

begin

  //sets the first row of the black pieces
  for counter1 := 1 to 8 do
    for counter2 := 1 to 8 do
    begin
      if (counter2 = 1) then
      begin
        if (counter1 = 1) or (counter1 = 8) then
          board[counter1, counter2] := 7;
        if (counter1 = 2) or (counter1 = 7) then
          board[counter1, counter2] := 8;
        if (counter1 = 3) or (counter1 = 6) then
          board[counter1, counter2] := 9;
        if (counter1 = 4) then
          board[counter1, counter2] := 10;
        if (counter1 = 5) then
          board[counter1, counter2] := 11;
      end;

      //sets the black pawns
      if (counter2 = 2) then
        board[counter1, counter2] := 12;

      //sets the first row of the white pieces
      if (counter2 = 8) then
      begin
        if (counter1 = 1) or (counter1 = 8) then
          board[counter1, counter2] := 1;
        if (counter1 = 2) or (counter1 = 7) then
          board[counter1, counter2] := 2;
        if (counter1 = 3) or (counter1 = 6) then
          board[counter1, counter2] := 3;
        if (counter1 = 4) then
          board[counter1, counter2] := 4;
        if (counter1 = 5) then
          board[counter1, counter2] := 5;
      end;

      //sets the white pawns
      if (counter2 = 7) then
        board[counter1, counter2] := 6;

      //sets every place with no chess pieces
      if (counter2 >= 3) and (counter2 <= 6) then
        board[counter1, counter2] := 0;
    end;

end;

//procedure that draws the paintbox in the form1
procedure TForm1.PaintBox1Paint(Sender: TObject);
var
  Bitmap: TBitmap;//bitmap used
  rectangleHeight,//the squares height according to the size of the paint box
  rectangleWidth,//the squares width according to the size of the paint box
  counter1, counter2,//counters for the cycles for
  pointsL,//points of the white player
  pointsD: integer;//points of the dark player
begin
  //Initializes each player points
  pointsD := 0;
  pointsL := 0;
  Bitmap := TBitmap.Create;
  //Initializes the Bitmap Size
  Bitmap.Height := PaintBox1.Height;
  Bitmap.Width := PaintBox1.Width;
  //Draw the background in white
  Bitmap.Canvas.Pen.Color := clWhite; //Line Color
  Bitmap.Canvas.Brush.Color := clWhite; //Fill Color
  Bitmap.Canvas.Rectangle(0, 0, PaintBox1.Width, PaintBox1.Height);
  // Draws squares
  Bitmap.Canvas.Pen.Color := clBlack; //Line Color
  //calculates the rectangle dimensions according to the paint box dimensions
  rectangleHeight := PaintBox1.Height div 8;
  rectangleWidth := PaintBox1.Width div 8;
  //double for cycle that goes through all the chess board
  for counter1 := 1 to 8 do
    for counter2 := 1 to 8 do
    begin
      //creates the chess board colors in the correct order
      if ((counter1 mod 2 <> 0) and (counter2 mod 2 <> 0)) or
        ((counter1 mod 2 = 0) and (counter2 mod 2 = 0)) then
        Bitmap.Canvas.Brush.Color := clWhite
      else
        Bitmap.Canvas.Brush.Color := clGreen;
      //identifies the last movement of the chess piece and assinalates it with a blue color
      if ((counter1 = lastX) and (counter2 = lastY)) or
        ((counter1 = verticalCoordinate) and (counter2 = horizontalCoordinate)) or
        ((gameHistoricX[play, 1] = counter1) and (gameHistoricY[play, 1] = counter2)) or
        ((gameHistoricX[play, 2] = counter1) and
        (gameHistoricY[play, 2] = counter2))
      then//uses the historic of plays to identify the previous plays when clicked undo
        Bitmap.Canvas.Brush.Color := clBlue;//assinalates it with a blue color
      //draws the squares
      Bitmap.Canvas.Rectangle(rectangleWidth * (counter1 - 1) + 2,
        rectangleHeight * (counter2 - 1) + 2, rectangleWidth * counter1,
        rectangleHeight * counter2);
      //draws the chess pieces in place
      Bitmap.Canvas.StretchDraw(Rect(rectangleWidth * (counter1 - 1) +
        2, rectangleHeight * (counter2 - 1) + 2, rectangleWidth *
        counter1, rectangleHeight * counter2),
        chessPieceImages[board[counter1, counter2]]);
      //verificates every position of the board to calculate the number of points of each player
      case board[counter1, counter2] of
        1: pointsL := pointsL + 5;
        2: pointsL := pointsL + 3;
        3: pointsL := pointsL + 3;
        4: pointsL := pointsL + 10;
        6: pointsL := pointsL + 1;
        7: pointsD := pointsD + 5;
        8: pointsD := pointsD + 3;
        9: pointsD := pointsD + 3;
        10: pointsD := pointsD + 10;
        12: pointsD := pointsD + 1;
      end;
    end;
  //calculates who is wining and by how much
  punctuation := pointsL - pointsD;
  //shows who is winning and by how much
  if punctuation = 0 then//if no one as an advantage
  begin
    pointsDItem.Caption := '0';
    pointsLItem.Caption := '0';
  end;
  if punctuation < 0 then//if the player with the black chess pieces is winning
  begin
    pointsDItem.Caption := '+' + IntToStr(-punctuation);
    pointsLItem.Caption := '0';
  end;
  if punctuation > 0 then//if the player with the white chess pieces is winning
  begin
    pointsLItem.Caption := '+' + IntToStr(punctuation);
    pointsDItem.Caption := '0';
  end;
  //saves the board in a array
  oldBoard[play] := board;
  PaintBox1.Canvas.Draw(0, 0, Bitmap);//draw the bit map
  Bitmap.Free; //Free the memory used by the object Bitmap
end;

// procedure used to change the style of the pieces when the player clicks the option style>Red and Black in the game menu
procedure TForm1.redBlackItemClick(Sender: TObject);
begin
  //load the chess piece images images with the red and black style
  loadImages('redBlack');
  //redraws the chess board
  PaintBox1.invalidate;
end;

// procedure used to change the style of the pieces when the player clicks the option style>standard in the game menu
procedure TForm1.StandardItemClick(Sender: TObject);
begin
  //load the chess piece images images with the standard style
  loadImages('standard');
  //redraws the chess board
  PaintBox1.invalidate;
end;

//procedure used to set the global variables for a 10 minutes game and reset the chess board
procedure TForm1.tenMinItemClick(Sender: TObject);

var
  counter1, counter2: integer;

begin
  //puts the timers to 10 minutes
  timerMinD := 10;
  timerSecD := 0;
  timerMinL := 10;
  timerSecL := 0;
  //resets the global variables
  aux := 0;
  play := 1;
  horizontalCoordinate := 0;
  verticalCoordinate := 0;
  lastX := 0;
  lastY := 0;
  //the points display go back to zero
  pointsDItem.Caption := '0';
  pointsLItem.Caption := '0';
  //reset the historic of plays
  for counter1 := 1 to 500 do
    for counter2 := 1 to 2 do
    begin
      gameHistoricX[counter1, counter2] := 0;
      gameHistoricY[counter1, counter2] := 0;
      gameHistoricX[counter1, counter2] := 0;
      gameHistoricY[counter1, counter2] := 0;
    end;
  //resets the chess board
  inicialBoard;
  //redwras the chess board
  PaintBox1.invalidate;
end;

//procedure that controls the timers of each player and it's used every second
procedure TForm1.Timer1Timer(Sender: TObject);
begin

  //calculates the time of the white chess pieces
  if not (((timerMinL = 0) and (timerSecL = 0)) or
    ((timerMinD = 0) and (timerSecD = 0))) then
  begin
    if play mod 2 <> 0 then
    begin
      //calculates the seconds
      timerSecL := timerSecL - 1;
      //calculates the minutes
      if timerSecL = -1 then
        timerMinL := timerMinL - 1;
      //reset the seconds when a minute has passed
      if -1 = timerSecL then
        timerSecL := 59;
    end
    else
      //calculates the time of the black chess pieces
    begin
      //calculates the seconds
      timerSecD := timerSecD - 1;
      //calculates the minutes
      if timerSecD = -1 then
        timerMinD := timerMinD - 1;
      //reset the seconds when a minute has passed
      if -1 = timerSecD then
        timerSecD := 59;
    end;
  end;

  //shows the time of each player
  timerLItem.Caption := IntToStr(timerMinL) + ':' + IntToStr(timerSecL);
  timerDItem.Caption := IntToStr(timerMinD) + ':' + IntToStr(timerSecD);

end;

//procedure used when the player clicks in the Undo button in the game menu
procedure TForm1.undoItemClick(Sender: TObject);

begin
  //if the game can go back
  if play - 1 <> 0 then
  begin
    //eliminates the historic of plays as th player goes back in the game
    gameHistoricX[play, 2] := 0;
    gameHistoricY[play, 2] := 0;
    gameHistoricX[play, 1] := 0;
    gameHistoricY[play, 1] := 0;
    //the play count goes back
    play := play - 1;
    //the old chess board is loaded
    board := oldBoard[play];
    //the global variables are reseted
    horizontalCoordinate := 0;
    verticalCoordinate := 0;
    lastX := 0;
    lastY := 0;
    aux := 0;
    //the paint box is redrwaed
    PaintBox1.invalidate;
  end;

end;

//procedure used to creat a unlimited game, when the player clicks the option unlimited in the game menu
procedure TForm1.unlimitedItemClick(Sender: TObject);

var
  counter1, counter2: integer;

begin
  //resests the global variables and puts the timers with 0 minutes
  timerMinD := 0;
  timerSecD := 0;
  timerMinL := 0;
  timerSecL := 0;
  aux := 0;
  play := 1;
  horizontalCoordinate := 0;
  verticalCoordinate := 0;
  lastX := 0;
  lastY := 0;
  //the points display go back to zero
  pointsDItem.Caption := '0';
  pointsLItem.Caption := '0';
  //reset the historic of plays
  for counter1 := 1 to 500 do
    for counter2 := 1 to 2 do
    begin
      gameHistoricX[counter1, counter2] := 0;
      gameHistoricY[counter1, counter2] := 0;
      gameHistoricX[counter1, counter2] := 0;
      gameHistoricY[counter1, counter2] := 0;
    end;
  //calls the procedure that puts the chess pieces in the inicial positions
  inicialBoard;
  //the paint box is redrwaed
  PaintBox1.invalidate;
end;

//procedure that is performed when the form1 is destroid
procedure TForm1.FormDestroy(Sender: TObject);
var
  i: integer;//counter for the cycle for
begin
  for i := 1 to 12 do//free the memory of the chess piece images
    chessPieceImages[i].Free;
end;

procedure TForm1.guilhermeGranchoItemClick(Sender: TObject);
begin
  loadImages('guilhermeGrancho');
  PaintBox1.invalidate;
end;

// procedure used to change the style of the pieces when the player clicks the option style>Maurizio Monge in the game menu
procedure TForm1.maurizioMongeItemClick(Sender: TObject);
begin
  loadImages('maurizioMonge');
  PaintBox1.invalidate;
end;

//procedure of the event that is used every time someone clicks on the paintbox
procedure TForm1.PaintBox1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);

var
  counter: integer;

begin

  //calculates the coordenates of where the player clicked in chess board using the pixels coordenates of that place
  horizontalCoordinate := 8 * Y div PaintBox1.Height + 1;
  verticalCoordinate := 8 * X div PaintBox1.Width + 1;

  //if there is not a chess piece in memory
  if aux = 0 then
  begin
    //saves the chess piece that the player clicked
    aux := board[verticalCoordinate, horizontalCoordinate];
    //saves the coordenates of where the player clicked
    lastX := verticalCoordinate;
    lastY := horizontalCoordinate;
    //saves the first click in the historic so that after the game has the historic of plays during the game
    gameHistoricX[play, 1] := lastX;
    gameHistoricY[play, 1] := lastY;
  end
  else
  //if there is a chess in memory that correspondes with the color of the chess pieces turn and if the player clicked in a different place from where he had previously clicked
  if (((play mod 2 = 0) and (aux >= 7)) or ((play mod 2 <> 0) and (aux <= 6))) and
    (aux <> board[verticalCoordinate, horizontalCoordinate]) then
  begin
    if ((aux = 1) or (aux = 7)) and ((verticalCoordinate = lastX) or
      (horizontalCoordinate = lastY)) then
    begin
      board[verticalCoordinate, horizontalCoordinate] := aux;
      board[lastX, lastY] := 0;
    end;
    if ((aux = 2) or (aux = 8)) and
      ((((verticalCoordinate = lastX + 1) or (verticalCoordinate = lastX - 1)) and
      ((horizontalCoordinate = lastY + 2) or (horizontalCoordinate = lastY - 2))) or
      (((verticalCoordinate = lastX + 2) or (verticalCoordinate = lastX - 2)) and
      ((horizontalCoordinate = lastY + 1) or (horizontalCoordinate = lastY - 1)))) then
    begin
      board[verticalCoordinate, horizontalCoordinate] := aux;
      board[lastX, lastY] := 0;
    end;

    for counter := 1 to 7 do
    begin
      if (((aux = 3) or (aux = 9)) and
        (((verticalCoordinate = lastX + counter) and
        (horizontalCoordinate = lastY + counter)) or
        ((verticalCoordinate = lastX - counter) and
        (horizontalCoordinate = lastY - counter)) or
        ((verticalCoordinate = lastX + counter) and
        (horizontalCoordinate = lastY - counter)) or
        ((verticalCoordinate = lastX - counter) and
        (horizontalCoordinate = lastY + counter)))) then
      begin
        board[verticalCoordinate, horizontalCoordinate] := aux;
        board[lastX, lastY] := 0;
      end;
      if (((aux = 4) or (aux = 10)) and
        (((verticalCoordinate = lastX + counter) and
        (horizontalCoordinate = lastY + counter)) or
        ((verticalCoordinate = lastX - counter) and
        (horizontalCoordinate = lastY - counter)) or
        ((verticalCoordinate = lastX + counter) and
        (horizontalCoordinate = lastY - counter)) or
        ((verticalCoordinate = lastX - counter) and
        (horizontalCoordinate = lastY + counter)) or
        ((verticalCoordinate = lastX + counter) and (horizontalCoordinate = lastY)) or
        ((horizontalCoordinate = lastY + counter) and (verticalCoordinate = lastX)) or
        ((verticalCoordinate = lastX - counter) and (horizontalCoordinate = lastY)) or
        ((horizontalCoordinate = lastY - counter) and (verticalCoordinate = lastX))))
      then
      begin
        board[verticalCoordinate, horizontalCoordinate] := aux;
        board[lastX, lastY] := 0;
      end;
    end;

    if (((aux = 5) or (aux = 11)) and
      (((verticalCoordinate = lastX + 1) and (horizontalCoordinate = lastY)) or
      ((horizontalCoordinate = lastY + 1) and (verticalCoordinate = lastX)) or
      ((verticalCoordinate = lastX - 1) and (horizontalCoordinate = lastY)) or
      ((horizontalCoordinate = lastY - 1) and (verticalCoordinate = lastX)) or
      ((verticalCoordinate = lastX + 1) and (horizontalCoordinate = lastY + 1)) or
      ((verticalCoordinate = lastX - 1) and (horizontalCoordinate = lastY - 1)) or
      ((verticalCoordinate = lastX + 1) and (horizontalCoordinate = lastY - 1)) or
      ((verticalCoordinate = lastX - 1) and (horizontalCoordinate = lastY + 1)))) then
    begin
      board[verticalCoordinate, horizontalCoordinate] := aux;
      board[lastX, lastY] := 0;
    end;
    if (((aux = 12) and (((horizontalCoordinate = lastY + 2) and
      (2 = lastY) and (verticalCoordinate = lastX)) or
      ((horizontalCoordinate = lastY + 1) and (verticalCoordinate = lastX)))) or
      ((aux = 6) and (((horizontalCoordinate = lastY - 2) and
      (7 = lastY) and (verticalCoordinate = lastX)) or
      ((horizontalCoordinate = lastY - 1) and (verticalCoordinate = lastX))))) then
    begin
      board[verticalCoordinate, horizontalCoordinate] := aux;
      board[lastX, lastY] := 0;
    end;
    //identifies the castles when the king moves 2 houses in the chess board and moves the rook
    if (aux = 5) and (lastX + 2 = verticalCoordinate) then//rigth white castle
    begin
      board[8, 8] := 0;//eliminates the rook from is old place
      board[6, 8] := 1;//puts the rook in the correct place according to the castle
    end;
    if (aux = 5) and (lastX - 2 = verticalCoordinate) then//left white castle
    begin
      board[1, 8] := 0;//eliminates the rook from is old place
      board[4, 8] := 1;//puts the rook in the correct place according to the castle
    end;
    if (aux = 11) and (lastX - 2 = verticalCoordinate) then//left black castle
    begin
      board[1, 1] := 0;//eliminates the rook from is old place
      board[4, 1] := 7;//puts the rook in the correct place according to the castle
    end;
    if (aux = 11) and (lastX + 2 = verticalCoordinate) then//rigth black castle
    begin
      board[8, 1] := 0;//eliminates the rook from is old place
      board[6, 1] := 7;//puts the rook in the correct place according to the castle
    end;
    //identifies the passent play
    if ((aux = 6) or (aux = 12)) and ((lastX - 1 = verticalCoordinate) or
      (lastX + 1 = verticalCoordinate)) and
      (board[verticalCoordinate, horizontalCoordinate] = 0) then
      //eats the correct pawn
      if (aux = 12) then//if the black player makes the move
        board[verticalCoordinate, horizontalCoordinate - 1] := 0
      else//if the white player makes the move
        board[verticalCoordinate, horizontalCoordinate + 1] := 0;
    //white autopromotion to queen
    if (aux = 6) and (horizontalCoordinate = 1) then
      aux := 4;
    //black autopromotion to queen
    if (aux = 12) and (horizontalCoordinate = 8) then
      aux := 10;
    //the chess piece on the place where the player previously clicked desapiercs
    //board[lastX, lastY] := 0;
    //the chess piece in memory is placed where the player last clicked
    //board[verticalCoordinate, horizontalCoordinate] := aux;
    //the chess piece is erased from the memory
    aux := 0;
    //saves the last click in the historic so that after the game has the historic of plays during the game
    gameHistoricX[play, 2] := verticalCoordinate;
    gameHistoricY[play, 2] := horizontalCoordinate;
    //the player turn changes
    play := play + 1;
    //the chess board is redrawed
    PaintBox1.invalidate;
  end
  else
    //the chess piece is erased from the memory if the conditions above fail
    aux := 0;

end;

//procedure that is called when the form1 is created
procedure TForm1.FormCreate(Sender: TObject);
var
  i: integer;//counter for the cycle for
begin

  //inicializes some of the global variables
  aux := 0;
  play := 1;
  horizontalCoordinate := 0;
  verticalCoordinate := 0;
  lastX := 0;
  lastY := 0;
  timerMinD := 0;
  timerSecD := 0;
  timerMinL := 0;
  timerSecL := 0;
  //sets the points of each player back to 0
  pointsDItem.Caption := '0';
  pointsLItem.Caption := '0';
  //shows the time of each player
  timerLItem.Caption := IntToStr(timerMinL) + ':' + IntToStr(timerSecL);
  timerDItem.Caption := IntToStr(timerMinD) + ':' + IntToStr(timerSecD);
  //counter that loads the chess piece images so that it can be used
  for i := 1 to 12 do
  begin
    chessPieceImages[i] := TPortableNetworkGraphic.Create;
  end;
  //inicializes the chess piece images in the standard style
  loadImages('standard');
  //puts the chess pieces in the correct inicial position
  inicialBoard;
end;

//procedure that closes the application when the player clicks on Exit in the game menu
procedure TForm1.ExitItemClick(Sender: TObject);
begin
  Application.Terminate;
end;

//procedure used to set the global variables for a 5 minutes game and reset the chess board
procedure TForm1.fiveMinItemClick(Sender: TObject);

var
  counter1, counter2: integer;

begin
  //timers to 5 minutes
  timerMinD := 5;
  timerSecD := 0;
  timerMinL := 5;
  timerSecL := 0;
  //resets global variables
  aux := 0;
  play := 1;
  horizontalCoordinate := 0;
  verticalCoordinate := 0;
  lastX := 0;
  lastY := 0;
  //the points display go back to zero
  pointsDItem.Caption := '0';
  pointsLItem.Caption := '0';
  //reset the historic of plays
  for counter1 := 1 to 500 do
    for counter2 := 1 to 2 do
    begin
      gameHistoricX[counter1, counter2] := 0;
      gameHistoricY[counter1, counter2] := 0;
      gameHistoricX[counter1, counter2] := 0;
      gameHistoricY[counter1, counter2] := 0;
    end;
  //resets the chess board
  inicialBoard;
  //redrwas the chess board
  PaintBox1.invalidate;
end;

//procedure that opens form2 when the player clicks on the option About on the game menu
procedure TForm1.AboutItemClick(Sender: TObject);
begin
  Form2.ShowModal;
end;

end.
