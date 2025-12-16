unit colortext;

interface

procedure ResetColor;
procedure SetRed;
procedure SetGreen;
procedure SetYellow;
procedure SetBlue;
procedure SetMagenta;
procedure SetCyan;
procedure SetWhite;

implementation

procedure ResetColor;
begin
  write(#27'[0m');
end;

procedure SetRed;
begin
  write(#27'[31m');
end;

procedure SetGreen;
begin
  write(#27'[32m');
end;

procedure SetYellow;
begin
  write(#27'[33m');
end;

procedure SetBlue;
begin
  write(#27'[34m');
end;

procedure SetMagenta;
begin
  write(#27'[35m');
end;

procedure SetCyan;
begin
  write(#27'[36m');
end;

procedure SetWhite;
begin
  write(#27'[37m');
end;

end.
