//name of the unit
unit About;

{$mode objfpc}{$H+}

interface

//each one imports a especific group of predefined functions and procedures
uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls;

type

  { TForm2 }

  TForm2 = class(TForm)
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
  private

  public

  end;

//global variable form2
var
  Form2: TForm2;

implementation

{$R *.lfm}

{ TForm2 }

end.

