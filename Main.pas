program MathQuiz;
uses sysutils,asciiart;

const
  MAXQ = 5;
  DATAUSER = 'user.txt';
  DATASCORE = 'score.txt';

type
  TUser = record
    username, password: string;
  end;

  TQuestion = record
    soal: string;
    pilihan: array[1..4] of string;
    jawaban: integer;
  end;

var
  user: TUser;
  questions: array[1..MAXQ] of TQuestion;
  skor, nyawa: integer;
  menu: char;


// its for the ascii dont use crt for whtever reasons
function GetHighScore(const targetUser: string): integer;
var
  f: text;
  line, u: string;
  s, posi, high: integer;
begin
  high := 0;
  assign(f, DATASCORE);
  reset(f);
  while not eof(f) do
  begin
    readln(f, line);
    posi := pos(',', line);
    u := copy(line, 1, posi - 1);
    s := StrToInt(copy(line, posi + 1, length(line)));

    if u = targetUser then
      if s > high then
        high := s;
  end;
  close(f);
  GetHighScore := high;
end;


procedure ClearScreen;
var i: integer;
begin
  for i := 1 to 50 do writeln;
end;


procedure SignUp;
var f: text;
begin
  assign(f, DATAUSER);
  append(f);
  write('Username baru : '); readln(user.username);
  write('Password baru : '); readln(user.password);
  writeln(f, user.username, ',', user.password);
  close(f);
  writeln('Sign up berhasil!');
  writeln('Tekan ENTER...');
  readln;
end;

function Login: boolean;
var
  f: text;
  line, u, p: string;
  posi: integer;
begin
  Login := false;
  write('Username : '); readln(user.username);
  write('Password : '); readln(user.password);

  assign(f, DATAUSER);
  reset(f);
  while not eof(f) do
  begin
    readln(f, line);
    posi := pos(',', line);
    u := copy(line, 1, posi - 1);
    p := copy(line, posi + 1, length(line));
    if (u = user.username) and (p = user.password) then
    begin
      Login := true;
      break;
    end;
  end;
  close(f);
end;

procedure LoadQuestion;
begin
  questions[1].soal := '6 x 7 = ?';
  questions[1].pilihan[1] := '42';
  questions[1].pilihan[2] := '36';
  questions[1].pilihan[3] := '48';
  questions[1].pilihan[4] := '40';
  questions[1].jawaban := 1;

  questions[2].soal := '81 : 9 = ?';
  questions[2].pilihan[1] := '7';
  questions[2].pilihan[2] := '8';
  questions[2].pilihan[3] := '9';
  questions[2].pilihan[4] := '10';
  questions[2].jawaban := 3;

  questions[3].soal := '12 x 5 = ?';
  questions[3].pilihan[1] := '50';
  questions[3].pilihan[2] := '55';
  questions[3].pilihan[3] := '60';
  questions[3].pilihan[4] := '65';
  questions[3].jawaban := 3;

  questions[4].soal := '64 : 8 = ?';
  questions[4].pilihan[1] := '6';
  questions[4].pilihan[2] := '7';
  questions[4].pilihan[3] := '8';
  questions[4].pilihan[4] := '9';
  questions[4].jawaban := 3;

  questions[5].soal := '9 x 8 = ?';
  questions[5].pilihan[1] := '64';
  questions[5].pilihan[2] := '72';
  questions[5].pilihan[3] := '81';
  questions[5].pilihan[4] := '70';
  questions[5].jawaban := 2;
end;

procedure SaveScore;
var f: text;
begin
  assign(f, DATASCORE);
  if FileExists(DATASCORE) then
    append(f)
  else
    rewrite(f);
  writeln(f, user.username, ',', skor);
  close(f);
end;


procedure PlayQuiz;
var i, pilih: integer;
begin
  skor := 0;
  nyawa := 3;

  LoadQuestion;

  for i := 1 to MAXQ do
  begin
    ClearScreen;
    writeln('Soal ', i, ' dari ', MAXQ);
    writeln('Nyawa: ', nyawa, ' | Skor: ', skor);
    writeln;
    writeln(questions[i].soal);
    writeln('1. ', questions[i].pilihan[1]);
    writeln('2. ', questions[i].pilihan[2]);
    writeln('3. ', questions[i].pilihan[3]);
    writeln('4. ', questions[i].pilihan[4]);
    write('Jawaban (1-4): ');
    readln(pilih);

    if pilih = questions[i].jawaban then
    begin
      writeln('Benar!');
      skor := skor + 10;
    end
    else
    begin
      writeln('Salah!');
      nyawa := nyawa - 1;
    end;

    if nyawa = 0 then break;
    writeln('Tekan ENTER...');
    readln;
  end;

  SaveScore;

  ClearScreen;
  writeln('================================');
  writeln('        KUIS TELAH SELESAI       ');
  writeln('================================');
  writeln;
  writeln('Terima kasih, ', user.username);
  writeln('Skor akhir kamu : ', skor);
  writeln;

  if skor >= 40 then
    writeln('Mantap! Kamu jago matematika!')
  else
    writeln('Ayo latihan lagi ya!');
    
    writeln('High score: ', GetHighScore(user.username));
  writeln;
  writeln('Tekan ENTER untuk keluar...');
  readln;
end;

begin
  if not FileExists(DATAUSER) then
  begin
    assign(output, DATAUSER);
    rewrite(output);
    close(output);
  end;

  repeat
    ShowAscii(1);
    writeln('1. Login');
    writeln('2. Sign Up');
    writeln('3. Keluar');
    write('Pilih: ');
    readln(menu);

    case menu of
  '1': if Login then PlayQuiz else begin writeln('Login gagal'); readln; end;
  '2': SignUp;
  '3': ShowAscii(2);
  
    end;
  until menu = '3';
end.