unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, math;

type
  TForm1 = class(TForm)
    btn1: TButton;
    label1: TLabel;
    btn2: TButton;
    btn3: TButton;
    tv1: TTreeView;
    lbl1: TLabel;
    btn4: TButton;
    Button1: TButton;
    btn5: TButton;
    lbl2: TLabel;
    procedure btn1Click(Sender: TObject);
    procedure btn2Click(Sender: TObject);
    procedure btn3Click(Sender: TObject);
    procedure btn4Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure btn5Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

const
  N = 10;

type
  TPNode = ^PNode;

  PNode = record
    Info, number: integer;
    Pleft, Pright: TPNode;
  end;

  mnoj = set of 0..255;

var
  Form1: TForm1;
  num: Integer;
  tree: TPNode;
  kek: TTreeNode;
  buf: array[0..255] of string;
  buf1: array[0..255] of string;
  buf2: array[0..255] of string;
  array_coord: array[0..255, 0..2] of Integer;
  // |elem|   0,0 ...
  // ------
  // | x  |   0,1 ...
  // ------
  // | y  |   0,2 ...
  counter: integer;
  mnojestvo: mnoj;

  j: byte;

implementation

{$R *.dfm}

procedure AddToTree(var phead: TPNode; x, number: integer);
var
  flag: boolean;
begin
  flag := True;
  if phead = nil then
  begin
    new(phead);
    phead^.Info := x;
    phead^.number := number;
    phead^.Pleft := nil;
    phead^.Pright := nil;
    flag := False;
  end;
  if flag = True then
  begin
    if x < phead^.Info then
      AddToTree(phead^.Pleft, x, number)
    else
      AddToTree(phead^.Pright, x, number);
  end;
end;

procedure writeTree(phead: TPnode);
begin
  if phead <> nil then
  begin
    writetree(phead^.Pleft);
    write(phead^.Info: 4);
    writetree(phead^.Pright);
  end;
end;

function height12(phead: TPnode): integer;
var
  l, r: integer;
begin
  if phead <> nil then
  begin
    l := height12(phead^.Pleft);
    r := height12(phead^.Pright);
    if l > r then
      height12 := l + 1
    else
      height12 := r + 1
  end
  else
    height12 := 0;
end;

function getpath(phead: TPNode): string;
begin
  if phead <> nil then
  begin
    if height12(phead^.Pleft) > height12(phead^.Pright) then
      getpath := IntToStr(phead^.info) + ' ' + getpath(phead^.Pleft)
    else
      getpath := IntToStr(phead^.info) + ' ' + getpath(phead^.Pright)
  end
  else
    getpath := '';
end;

procedure TreeFree(var aPNode: TPNode);
begin
  if aPNode = nil then
    Exit;
  TreeFree(aPNode^.PLeft);
  {Рекурсивный вызов для освобождения памяти в левой ветви.}
  TreeFree(aPNode^.PRight);
  {Рекурсивный вызов для освобождения памяти в правой ветви.}
  Dispose(aPNode); {Освобождение памяти, занятой для текущего узла.}
  aPNode := nil; {Обнуление указателя на текущий узел.}
end;

procedure PrintTree(treenode: TTreeNode; root: TPNode);
var
  newnode: TTreeNode;
begin
  if Assigned(root) then
    with Form1 do
    begin
      newnode := tv1.Items.AddChild(treenode, inttostr(root^.info));
      PrintTree(newnode, root^.PLeft);
      PrintTree(newnode, root^.PRight);
    end;
end;

function TreeDepth(tree: TPNode): byte;
begin
  if tree = nil then
    TreeDepth := 0
  else
    TreeDepth := 1 + max(TreeDepth(tree^.Pleft), TreeDepth(tree^.pright));
end;

procedure drawdot(x, y, m: Integer; canvas: TCanvas);
begin
  if m = 0 then
    canvas.Pixels[x, y] := clRed
  else
    canvas.Pixels[x, y] := clGreen;

end;

//прямой

procedure TreeWritelnD(const aPNode: TPNode);
begin
  if aPNode = nil then
  begin
    buf[j] := '0';
    Inc(j);
    Exit;
  end;

  buf[j] := '(' + inttostr(aPNode^.info) + ')';
  Inc(j);
  Include(mnojestvo, aPnode^.Info);
  TreeWritelnD(aPNode^.PLeft);
  buf[j] := IntToStr(aPnode^.info);
  Inc(j);
  TreeWritelnD(aPNode^.PRight);
  buf[j] := IntToStr(aPnode^.info);
  Inc(j);
end;

//обратный

procedure TreeWritelnR(const aPNode: TPNode);
var
  lol: Byte;
begin
  if aPNode = nil then
  begin
    buf1[j] := '0';
    Inc(j);
    Exit;
  end;
  buf1[j] := IntToStr(aPnode^.info);
  Inc(j);
  TreeWritelnR(aPNode^.PLeft);

  buf1[j] := '(' + IntToStr(aPnode^.info) + ')';
  Inc(j);
  Include(mnojestvo, aPnode^.Info);

  TreeWritelnR(aPNode^.PRight);
  buf1[j] := IntToStr(aPnode^.info);
  Inc(j);

end;

//симметричный

procedure TreeWritelnS(const aPNode: TPNode);
begin
  if aPNode = nil then
  begin
    buf2[j] := '0';
    Inc(j);
    Exit;
  end;
  buf2[j] := IntToStr(aPnode^.info);
  Inc(j);
  TreeWritelnS(aPNode^.PLeft);

  buf2[j] := IntToStr(aPnode^.info);
  Inc(j);

  TreeWritelnS(aPNode^.PRight);

  buf2[j] := '(' + IntToStr(aPnode^.info) + ')';
  Inc(j);
  Include(mnojestvo, aPnode^.Info);

end;

procedure DrawTree(Tree: TPNOde; Rect: TRect; Canvas: TCanvas);
const
  Radius = 20;
var
  M, H, D: Word;
var
  R: TRect;
begin
  if Tree <> nil then
  begin
    M := (Rect.Left + Rect.Right) div 2;
    H := Rect.Top;
    D := Abs(Rect.Bottom - Rect.Top) div TreeDepth(Tree);
    with Canvas do
    begin
      Pen.Color := $000000;
      Pen.Width := 2;
      Brush.Color := clWhite;
      LineTo(M, H);
      Ellipse(M - Radius, H - Radius, M + Radius, H + Radius);
      TextOut(M - (Radius div 2) + 2, H - (Radius div 2) + 2,
        IntToStr(Tree.info));
    end;
    Canvas.MoveTo(M, H + radius);
    if Tree^.Pleft <> nil then
    begin
      R.Left := Rect.Left;
      R.Right := M;
      R.Top := H + D;
      R.Bottom := Rect.Bottom;
      //Sleep(500);
      DrawTree(Tree^.Pleft, R, Canvas);
    end;
    Canvas.MoveTo(M, H + radius);
    if Tree^.Pright <> nil then
    begin
      R.Left := M;
      R.Right := Rect.Right;
      R.Top := H + D;
      R.Bottom := Rect.Bottom;
      //Sleep(500);
      DrawTree(Tree^.Pright, R, Canvas);
    end;
  end;
end;

procedure lightnigh1(Tree: TPNode; Rect: Trect; Canvas: TCanvas; mode: Integer);
const
  Radius = 20;
var
  M, H, D: Word;
var
  R: TRect;
begin

  if Tree <> nil then
  begin
    M := (Rect.Left + Rect.Right) div 2;
    H := Rect.Top;
    D := Abs(Rect.Bottom - Rect.Top) div TreeDepth(Tree);
    with Canvas do
    begin
      Pen.Color := $000000;
      Pen.Width := 2;

      Brush.Color := clGreen;
      Ellipse(M - Radius, H - Radius, M + Radius, H + Radius);
      Sleep(500);

      Brush.Color := clWhite;
      Ellipse(M - Radius, H - Radius, M + Radius, H + Radius);
      TextOut(M - (Radius div 2) + 2, H - (Radius div 2) + 2,
        IntToStr(Tree.info));
      Form1.Update;

    end;
    if tree.Pleft <> nil then
    begin
      R.Left := Rect.Left;
      R.Right := M;
      R.Top := H + D;
      R.Bottom := Rect.Bottom;
      Sleep(500);
      lightnigh1(Tree^.Pleft, R, Canvas, mode);
      with Canvas do
      begin
        Pen.Color := $000000;
        Pen.Width := 2;

        Brush.Color := clRed;
        Ellipse(M - Radius, H - Radius, M + Radius, H + Radius);
        Sleep(500);

        Brush.Color := clWhite;
        Ellipse(M - Radius, H - Radius, M + Radius, H + Radius);
        TextOut(M - (Radius div 2) + 2, H - (Radius div 2) + 2,
          IntToStr(Tree.info));
        Form1.Update;

      end;
    end
    else
      with Canvas do
      begin
        Pen.Color := $000000;
        Pen.Width := 2;

        Brush.Color := clYellow;
        Ellipse(M - Radius, H - Radius, M + Radius, H + Radius);
        Sleep(500);

        Brush.Color := clWhite;
        Ellipse(M - Radius, H - Radius, M + Radius, H + Radius);
        TextOut(M - (Radius div 2) + 2, H - (Radius div 2) + 2,
          IntToStr(Tree.info));
        Form1.Update;

      end;

    if tree.Pright <> nil then
    begin
      R.Left := M;
      R.Right := Rect.Right;
      R.Top := H + D;
      R.Bottom := Rect.Bottom;
      Sleep(500);
      lightnigh1(Tree^.Pright, R, Canvas, mode);
      with Canvas do
      begin
        Pen.Color := $000000;
        Pen.Width := 2;

        Brush.Color := clRed;
        Ellipse(M - Radius, H - Radius, M + Radius, H + Radius);
        Sleep(500);

        Brush.Color := clWhite;
        Ellipse(M - Radius, H - Radius, M + Radius, H + Radius);
        TextOut(M - (Radius div 2) + 2, H - (Radius div 2) + 2,
          IntToStr(Tree.info));
        Form1.Update;

      end;
    end
    else
      with Canvas do
      begin
        Pen.Color := $000000;
        Pen.Width := 2;

        Brush.Color := clYellow;
        Ellipse(M - Radius, H - Radius, M + Radius, H + Radius);
        Sleep(500);

        Brush.Color := clWhite;
        Ellipse(M - Radius, H - Radius, M + Radius, H + Radius);
        TextOut(M - (Radius div 2) + 2, H - (Radius div 2) + 2,
          IntToStr(Tree.info));
        Form1.Update;

      end;

  end;

end;

procedure lightnigh2(Tree: TPNode; Rect: Trect; Canvas: TCanvas; mode: Integer);
const
  Radius = 20;
var
  M, H, D: Word;
var
  R: TRect;
begin

  if Tree <> nil then
  begin
    M := (Rect.Left + Rect.Right) div 2;
    H := Rect.Top;
    D := Abs(Rect.Bottom - Rect.Top) div TreeDepth(Tree);
    with Canvas do
    begin
      Pen.Color := $000000;
      Pen.Width := 2;

      Brush.Color := clRed;
      Ellipse(M - Radius, H - Radius, M + Radius, H + Radius);
      Sleep(500);

      Brush.Color := clWhite;
      Ellipse(M - Radius, H - Radius, M + Radius, H + Radius);
      TextOut(M - (Radius div 2) + 2, H - (Radius div 2) + 2,
        IntToStr(Tree.info));
      Form1.Update;

    end;
    if tree.Pleft <> nil then
    begin
      R.Left := Rect.Left;
      R.Right := M;
      R.Top := H + D;
      R.Bottom := Rect.Bottom;
      Sleep(500);
      lightnigh2(Tree^.Pleft, R, Canvas, mode);
      with Canvas do
      begin
        Pen.Color := $000000;
        Pen.Width := 2;

        Brush.Color := clGreen;
        Ellipse(M - Radius, H - Radius, M + Radius, H + Radius);
        Sleep(500);

        Brush.Color := clWhite;
        Ellipse(M - Radius, H - Radius, M + Radius, H + Radius);
        TextOut(M - (Radius div 2) + 2, H - (Radius div 2) + 2,
          IntToStr(Tree.info));
        Form1.Update;

      end;
    end
    else
      with Canvas do
      begin
        Pen.Color := $000000;
        Pen.Width := 2;

        Brush.Color := clYellow;
        Ellipse(M - Radius, H - Radius, M + Radius, H + Radius);
        Sleep(500);

        Brush.Color := clWhite;
        Ellipse(M - Radius, H - Radius, M + Radius, H + Radius);
        TextOut(M - (Radius div 2) + 2, H - (Radius div 2) + 2,
          IntToStr(Tree.info));
        Form1.Update;

      end;
    with Canvas do
    begin
      Pen.Color := $000000;
      Pen.Width := 2;
      Brush.Color := clGreen;
      Ellipse(M - Radius, H - Radius, M + Radius, H + Radius);
      Sleep(500);

      Brush.Color := clWhite;
      Ellipse(M - Radius, H - Radius, M + Radius, H + Radius);
      TextOut(M - (Radius div 2) + 2, H - (Radius div 2) + 2,
        IntToStr(Tree.info));
      Form1.Update;

    end;
    if tree.Pright <> nil then
    begin
      R.Left := M;
      R.Right := Rect.Right;
      R.Top := H + D;
      R.Bottom := Rect.Bottom;
      Sleep(500);
      lightnigh2(Tree^.Pright, R, Canvas, mode);
      with Canvas do
      begin
        Pen.Color := $000000;
        Pen.Width := 2;

        Brush.Color := clRed;
        Ellipse(M - Radius, H - Radius, M + Radius, H + Radius);
        Sleep(500);

        Brush.Color := clWhite;
        Ellipse(M - Radius, H - Radius, M + Radius, H + Radius);
        TextOut(M - (Radius div 2) + 2, H - (Radius div 2) + 2,
          IntToStr(Tree.info));
        Form1.Update;

      end;
    end
    else
      with Canvas do
      begin
        Pen.Color := $000000;
        Pen.Width := 2;

        Brush.Color := clYellow;
        Ellipse(M - Radius, H - Radius, M + Radius, H + Radius);
        Sleep(500);

        Brush.Color := clWhite;
        Ellipse(M - Radius, H - Radius, M + Radius, H + Radius);
        TextOut(M - (Radius div 2) + 2, H - (Radius div 2) + 2,
          IntToStr(Tree.info));
        Form1.Update;

      end;

  end;
end;

procedure lightnigh3(Tree: TPNode; Rect: Trect; Canvas: TCanvas; mode: Integer);
const
  Radius = 20;
var
  M, H, D: Word;
var
  R: TRect;
begin

  if Tree <> nil then
  begin
    M := (Rect.Left + Rect.Right) div 2;
    H := Rect.Top;
    D := Abs(Rect.Bottom - Rect.Top) div TreeDepth(Tree);
    with Canvas do
    begin
      Pen.Color := $000000;
      Pen.Width := 2;
      Brush.Color := clRed;
      Ellipse(M - Radius, H - Radius, M + Radius, H + Radius);
      Sleep(500);

      Brush.Color := clWhite;
      Ellipse(M - Radius, H - Radius, M + Radius, H + Radius);
      TextOut(M - (Radius div 2) + 2, H - (Radius div 2) + 2,
        IntToStr(Tree.info));
      Form1.Update;

    end;
    if tree.Pleft <> nil then
    begin
      R.Left := Rect.Left;
      R.Right := M;
      R.Top := H + D;
      R.Bottom := Rect.Bottom;
      Sleep(500);
      lightnigh3(Tree^.Pleft, R, Canvas, mode);
      with Canvas do
      begin
        Pen.Color := $000000;
        Pen.Width := 2;

        Brush.Color := clRed;
        Ellipse(M - Radius, H - Radius, M + Radius, H + Radius);
        Sleep(500);

        Brush.Color := clWhite;
        Ellipse(M - Radius, H - Radius, M + Radius, H + Radius);
        TextOut(M - (Radius div 2) + 2, H - (Radius div 2) + 2,
          IntToStr(Tree.info));
        Form1.Update;

      end;
    end
    else
      with Canvas do
      begin
        Pen.Color := $000000;
        Pen.Width := 2;

        Brush.Color := clYellow;
        Ellipse(M - Radius, H - Radius, M + Radius, H + Radius);
        Sleep(500);

        Brush.Color := clWhite;
        Ellipse(M - Radius, H - Radius, M + Radius, H + Radius);
        TextOut(M - (Radius div 2) + 2, H - (Radius div 2) + 2,
          IntToStr(Tree.info));
        Form1.Update;

      end;

    if tree.Pright <> nil then
    begin
      R.Left := M;
      R.Right := Rect.Right;
      R.Top := H + D;
      R.Bottom := Rect.Bottom;
      Sleep(500);
      lightnigh3(Tree^.Pright, R, Canvas, mode);
      with Canvas do
      begin
        Pen.Color := $000000;
        Pen.Width := 2;

        Brush.Color := clRed;
        Ellipse(M - Radius, H - Radius, M + Radius, H + Radius);
        Sleep(500);

        Brush.Color := clWhite;
        Ellipse(M - Radius, H - Radius, M + Radius, H + Radius);
        TextOut(M - (Radius div 2) + 2, H - (Radius div 2) + 2,
          IntToStr(Tree.info));
        Form1.Update;

      end;
    end
    else
      with Canvas do
      begin
        Pen.Color := $000000;
        Pen.Width := 2;

        Brush.Color := clYellow;
        Ellipse(M - Radius, H - Radius, M + Radius, H + Radius);
        Sleep(500);

        Brush.Color := clWhite;
        Ellipse(M - Radius, H - Radius, M + Radius, H + Radius);
        TextOut(M - (Radius div 2) + 2, H - (Radius div 2) + 2,
          IntToStr(Tree.info));
        Form1.Update;

      end;

    with Canvas do
    begin
      Pen.Color := $000000;
      Pen.Width := 2;

      Brush.Color := clGreen;
      Ellipse(M - Radius, H - Radius, M + Radius, H + Radius);
      Sleep(500);

      Brush.Color := clWhite;
      Ellipse(M - Radius, H - Radius, M + Radius, H + Radius);
      TextOut(M - (Radius div 2) + 2, H - (Radius div 2) + 2,
        IntToStr(Tree.info));
      Form1.Update;

    end;
  end;
end;

procedure TForm1.btn1Click(Sender: TObject);
var
  k: Integer;
  lel: TComponent;
  rectangle: TRect;
begin
  Form1.Repaint;
  k := height12(tree);
  label1.Caption := IntToStr(k);

  rectangle := Rect(20, 20, 657, 529);
  Form1.Canvas.MoveTo(((rectangle.Left + rectangle.Right) div 2),
    rectangle.Top);
  DrawTree(tree, rectangle, Canvas);
  //mnojestvo := mnojestvo - mnojestvo;
  //TreeWritelnD(tree);
  //lightnigh1(tree, rectangle, Canvas, 0);
  //Sleep(1000);
 //mnojestvo := mnojestvo - mnojestvo;
  //TreeWritelnS(tree);
  //lightnigh2(tree, rectangle, Canvas, 0);
  //mnojestvo := mnojestvo - mnojestvo;
  //TreeWritelnR(tree);
  //lightnigh3(tree, rectangle, Canvas, 0);
end;

procedure TForm1.btn2Click(Sender: TObject);
var
  fileofnode: Textfile;
  x: Integer;
  i: byte;
begin
  AssignFile(fileofnode, 'Node.txt');
  reset(fileofnode);
  i := 0;
  while not eof(fileofnode) do
  begin
    readln(fileofnode, x);
    AddToTree(tree, x, i);
    Inc(i);
  end;
end;

procedure TForm1.btn3Click(Sender: TObject);
var
  aowner: TComponent;
  rectangl: TRect;
begin
  treefree(tree);
  rectangl := Rect(0, 0, 657, 529);
  Canvas.fillrect(rectangl);
  lbl2.Caption := '';
end;

procedure TForm1.btn4Click(Sender: TObject);
var
  i: Byte;
  kek: string;
  rectangle: TRect;
begin
  j := 0;
  kek := '';
  rectangle := Rect(20, 20, 657, 529);
  Form1.Canvas.MoveTo(((rectangle.Left + rectangle.Right) div 2),
    rectangle.Top);
  mnojestvo := mnojestvo - mnojestvo;
  TreeWritelnD(tree);
  for i := 0 to 255 do
  begin
    kek := kek + buf[i] + ' ';
  end;
  lbl2.Caption := kek;
  lbl2.Update;
  lightnigh1(tree, rectangle, Canvas, 0);
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  i: Byte;
  kek: string;
  rectangle: TRect;
begin
  j := 0;
  kek := '';
  rectangle := Rect(20, 20, 657, 529);
  Form1.Canvas.MoveTo(((rectangle.Left + rectangle.Right) div 2),
    rectangle.Top);
  mnojestvo := mnojestvo - mnojestvo;
  TreeWritelnR(tree);
  for i := 0 to 255 do
  begin
    kek := kek + buf1[i] + ' ';
  end;
  lbl2.Caption := kek;
  lbl2.Update;
  lightnigh2(tree, rectangle, Canvas, 0);
end;

procedure TForm1.btn5Click(Sender: TObject);
var
  i: Byte;
  kek: string;
  rectangle: TRect;
begin
  j := 0;
  kek := '';
  rectangle := Rect(20, 20, 657, 529);
  Form1.Canvas.MoveTo(((rectangle.Left + rectangle.Right) div 2),
    rectangle.Top);
  mnojestvo := mnojestvo - mnojestvo;
  TreeWritelnS(tree);
  for i := 0 to 255 do
  begin
    kek := kek + buf2[i] + ' ';
  end;
  lbl2.Caption := kek;
  lbl2.Update;
  lightnigh3(tree, rectangle, Canvas, 0);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  lbl2.Caption := '';
end;

end.

