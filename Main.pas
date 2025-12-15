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

function UsernameExists(const name: string): boolean;
var
  f: text;
  line, u: string;
  posi: integer;
begin
  UsernameExists := false;
  if not FileExists(DATAUSER) then exit;
  assign(f, DATAUSER);
  reset(f);
  while not eof(f) do
  begin
    readln(f, line);
    posi := pos(',', line);
    if posi = 0 then continue;
    u := copy(line, 1, posi - 1);
    if u = name then
    begin
      UsernameExists := true;
      break;
    end;
  end;
  close(f);
end;

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

type
  TScoreRecord = record
    username: string;
    score: integer;
  end;

procedure ShowTop5Scores;
var
  f: text;
  line, u, sstr: string;
  posi, s, i, j: integer;
  scores: array of TScoreRecord;
  temp: TScoreRecord;
begin
  if not FileExists(DATASCORE) then
  begin
    writeln('Belum ada skor tersimpan.');
    exit;
  end;
  // Baca semua skor
  SetLength(scores, 0);
  assign(f, DATASCORE);
  reset(f);
  while not eof(f) do
  begin
    readln(f, line);
    posi := pos(',', line);
    if posi = 0 then continue;
    u := copy(line, 1, posi - 1);
    sstr := copy(line, posi + 1, length(line));
    s := StrToIntDef(sstr, 0);
    i := length(scores);
    SetLength(scores, i + 1);
    scores[i].username := u;
    scores[i].score := s;
  end;
  close(f);
  for i := 0 to length(scores) - 2 do
    for j := i + 1 to length(scores) - 1 do
      if scores[i].score < scores[j].score then
      begin
        temp := scores[i];
        scores[i] := scores[j];
        scores[j] := temp;
      end;
  writeln('===== Top 5 Global Scores =====');
//dynamic array starts from 0
  for i := 0 to 4 do
  begin 
    if i < length(scores) then
      writeln(i+1, '. ', scores[i].username, ' : ', scores[i].score)
    else
      writeln(i+1, '. - : 0');
  end;
  writeln('===============================');
  writeln;
end;


// its for the ascii dont use crt for whtever reasons
procedure ClearScreen;
var i: integer;
begin
  for i := 1 to 50 do writeln;
end;


procedure SignUp;
var f: text;
begin
  write('Username baru : ');
  readln(user.username);
  if UsernameExists(user.username) then
  begin
    writeln('Username sudah ada!');
    writeln('Tekan ENTER...');
    readln;
    exit;
  end;
  write('Password baru : ');
  readln(user.password);
  assign(f, DATAUSER);
  append(f);
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

procedure GenerateRandomQuestion(var Q: TQuestion);
var
  a, b, hasil, i, val, range, op, pos: integer;
  used: array[1..4] of boolean;
begin
  op := Random(3) + 1;
  for i := 1 to 4 do used[i] := false;

  case op of
    1: begin
      a := Random(99) + 1;
      b := Random(99) + 1;
      if Random(2) = 0 then a := -a;
      if Random(2) = 0 then b := -b;
      hasil := a + b;
      range := 4;
      Q.soal := IntToStr(a) + ' + ' + IntToStr(b) + ' = ?';
    end;
    2: begin
      a := Random(33) + 1;
      b := Random(33) + 1;
      if Random(2) = 0 then a := -a;
      if Random(2) = 0 then b := -b;
      hasil := a * b;
      range := 24;
      Q.soal := IntToStr(a) + ' x ' + IntToStr(b) + ' = ?';
    end;
    3: begin
      b := Random(12) + 1;
      hasil := Random(21) - 10;
      a := hasil * b;
      range := 3;
      Q.soal := IntToStr(a) + ' : ' + IntToStr(b) + ' = ?';
    end;
  end;

  pos := Random(4) + 1;
  Q.jawaban := pos;
  Q.pilihan[pos] := IntToStr(hasil);
  used[pos] := true;

  for i := 1 to 4 do
  begin
    if not used[i] then
    begin
      repeat
        val := hasil + (Random(range * 2 + 1) - range);
        if op <> 3 then
          if (val mod 2) <> (hasil mod 2) then
            continue;
      until val <> hasil;
      Q.pilihan[i] := IntToStr(val);
      used[i] := true;
    end;
  end;
end;


procedure LoadQuestion;
var i: integer;
begin
  for i := 1 to MAXQ do
    GenerateRandomQuestion(questions[i]);
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
  Randomize;
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
    writeln('3. Show Highscore Board');
    writeln('4. Keluar');
    write('Pilih: ');
    readln(menu);

    case menu of
  '1': if Login then PlayQuiz else begin writeln('Login gagal'); readln; end;
  '2': SignUp;
  '3': ShowTop5Scores;
  '4': ShowAscii(2);
  
    end;
  until menu = '4';
end.