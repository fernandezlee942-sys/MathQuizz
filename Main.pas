program MathQuiz;
uses sysutils,asciiart,colortext;

const
  MAXQ = 10;
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

  TScoreRecord = record
    username: string;
    score: integer;
    end;

var
  user: TUser;
  questions: array[1..MAXQ] of TQuestion;
  skor, nyawa: integer;
  menu: char;
  f: text;

  // its for the ascii dont use crt for whtever reasons
  procedure ClearScreen;
  begin
    write(#27'[2J');  // clear visible screen
    write(#27'[3J');  // clear scrollback (important)
    write(#27'[H');   // cursor to top-left
  end;


  function UsernameExists(const name: string): boolean;
  var
    f: text;
    line, u: string;
    posi: integer;

  begin
    UsernameExists := false;
    if not FileExists(DATAUSER) then 
      exit;
    
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


  procedure SignUp;
  var f: text;
  begin
    SetCyan;
    write('Username baru : ');
    SetYellow;
    readln(user.username);
    if UsernameExists(user.username) then
      begin
        writeln('Username sudah ada!');
        write('Tekan ');
        SetGreen;
        write('ENTER');
        SetYellow;
        writeln(' untuk kembali ke menu utama');
        ResetColor;
        readln;
        ClearScreen;
        exit;
      end;
    SetCyan;
    write('Password baru : ');
    SetYellow;
    readln(user.password);
    ResetColor;
    assign(f, DATAUSER);
    append(f);
    // buat pindah ke plg bawah file txt
    writeln(f, user.username, ',', user.password);
    close(f);
    writeln('Sign up berhasil!');
    write('Tekan ');
    SetGreen;
    write('ENTER');
    SetYellow;
    writeln(' untuk kembali ke menu utama');
    ResetColor;
    readln;
    ClearScreen;
  end;


  function Login: boolean;
  var
    f: text;
    line, u, p: string;
    posi: integer;

  begin
    Login := false;

    SetCyan;
    write('Username : ');
    SetYellow;
    readln(user.username);

    // check if username exists first
    if not UsernameExists(user.username) then
      begin
        SetRed;
        writeln('Username belum terdaftar!');
        ResetColor;
        exit;
      end;

    SetCyan;
    write('Password : ');
    SetYellow;
    readln(user.password);
    ResetColor;

    assign(f, DATAUSER);
    reset(f);
    while not eof(f) do
    begin
      readln(f, line);
      posi := pos(',', line);
      u := copy(line, 1, posi - 1);
      p := copy(line, posi + 1, length(line));

      if u = user.username then
        begin
          if p = user.password then
            Login := true;
          break;
        end;
    end;
    close(f);

    if not Login then
      begin
        SetRed;
        writeln('Password salah!');
        ResetColor;
        exit;
      end;
  end;


  procedure GenerateRandomQuestion(var Q: TQuestion);
  var
    a, b, hasil, i, val, range, op, pos: integer;
    used: array[1..4] of boolean;
    
  begin
    op := Random(3) + 1;
    for i := 1 to 4 do
      used[i] := false;

    case op of
      1: 
      begin
        a := Random(99) + 1;
        b := Random(99) + 1;
        if Random(2) = 0 then
          a := -a;
        if Random(2) = 0 then
          b := -b;
        hasil := a + b;
        range := 4;
        Q.soal := IntToStr(a) + ' + ' + IntToStr(b) + ' = ?';
      end;
      
      2:
      begin
        a := Random(33) + 1;
        b := Random(33) + 1;
        if Random(2) = 0 then
          a := -a;
        if Random(2) = 0 then
          b := -b;
        hasil := a * b;
        range := 24;
        Q.soal := IntToStr(a) + ' x ' + IntToStr(b) + ' = ?';
      end;
      
      3:
      begin
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

              // same parity for + and ×
              if op <> 3 then
                if Odd(val) xor Odd(hasil) then
                  continue;
              
              // not equal to correct answer
              if val = hasil then
                continue;
              
              // prevent duplicate choices
              // in Monkee language, if the choice value generated at this point is present in one of the used posistion than it will repeat the val generation
              if ((used[1] and (Q.pilihan[1] = IntToStr(val))) or (used[2] and (Q.pilihan[2] = IntToStr(val))) or (used[3] and (Q.pilihan[3] = IntToStr(val))) or (used[4] and (Q.pilihan[4] = IntToStr(val)))) then
                continue;
              break;
            until false;

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


  procedure PlayQuiz;
  var i, pilih: integer;

  begin
      skor := 0;
      nyawa := 5;
      Randomize;
      LoadQuestion;

      for i := 1 to MAXQ do
        begin
          ClearScreen;
          SetGreen;
          writeln('Soal ', i, ' dari ', MAXQ);
          SetCyan;
          writeln('Nyawa: ', nyawa, ' | Skor: ', skor);
          writeln;
          SetRed;
          writeln(questions[i].soal);
          SetMagenta;
          write('1. ');
          SetBlue;
          writeln(questions[i].pilihan[1]);
          SetMagenta;
          write('2. ');
          SetBlue;
          writeln(questions[i].pilihan[2]);
          SetMagenta;
          write('3. ');
          SetBlue;
          writeln(questions[i].pilihan[3]);
          SetMagenta;
          write('4. ');
          SetBlue;
          writeln(questions[i].pilihan[4]);
          ResetColor;
          write('Jawaban (1-4): ');
          SetMagenta;
          readln(pilih);
          ResetColor;

          if pilih = questions[i].jawaban then
            begin
              SetGreen;
              writeln('Benar!');
              ResetColor;
              skor := skor + 10;
            end
            else
            begin
              SetRed;
              writeln('Salah!');
              ResetColor;
              nyawa := nyawa - 1;
            end;

          if nyawa = 0 then 
            break;
          SetYellow;
          write('Tekan ');
          SetGreen;
          write('ENTER');
          SetYellow;
          writeln(' Untuk Lanjut');
          ResetColor;
          readln;  
      end;

    SaveScore;

    ClearScreen;
    SetYellow;
    writeln('================================');
    writeln('        KUIS TELAH SELESAI       ');
    writeln('================================');
    writeln;
    ResetColor;
    write('Terima kasih, ');
    SetYellow;
    writeln(user.username);
    ResetColor;
    write('Skor akhir kamu : ');
    SetYellow;
    writeln(skor);
    writeln;

    if skor >= 80 then
      writeln('Mantap! Kamu jago matematika!')
    else
      begin
      SetYellow;
      writeln('Ayo latihan lagi ya!');
      end;
    ResetColor;
    write('High Score : ');
    SetBlue;
    write(GetHighScore(user.username));
    ResetColor;
    writeln;
    SetYellow;
    write('Tekan ');
    SetGreen;
    write('Enter');
    SetYellow;
    writeln(' untuk keluar...');
    ResetColor;
    readln;
    ClearScreen;
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
        write('Tekan ');
        SetGreen;
        write('ENTER ');
        ResetColor;
        writeln('Untuk Kembali ke Menu Utama');
        readln();
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
      // i buat bantu perbesar array
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
    
    write('===== ');
    SetBlue;
    write('Top 5 Global Scores');
    ResetColor;
    writeln(' =====');
  
    //dynamic array starts from 0

    for i := 0 to 4 do
      begin 
        if i < length(scores) then
        // tindak pencegahan klo data yg ada blom ampe 5
          begin
            SetRed;
            write(i+1);
            ResetColor;
            write('. ');
            SetBlue;
            write(scores[i].username); 
            ResetColor;
            write(' : ');
            SetMagenta;
            writeln(scores[i].score);
            ResetColor;
          end
        else
          writeln(i+1, '. - : 0');
      end;
    writeln('===============================');
    write('Tekan ');
    SetGreen;
    write('ENTER ');
    ResetColor;
    writeln('Untuk Kembali ke Menu Utama');
    readln();
    ClearScreen;
  end;


begin
  if not FileExists(DATAUSER) then
  begin
    assign(f, DATAUSER);
    rewrite(f);
    close(f);
  end;

  repeat
    ClearScreen;
    ShowAscii(1);
    SetBlue;
    write('1. ');
    SetYellow;
    writeln ('Login');
    SetBlue;
    write('2. ');
    SetYellow;
    writeln('Sign Up');
    SetBlue;
    write('3. ');
    SetYellow;
    writeln('Show Highscore Board');
    SetBlue;
    write('4. ');
    SetYellow;
    writeln('Keluar');
    ResetColor;
    write('Pilih : ');
    SetBlue;
    readln(menu);
    writeln();
    ResetColor;

      case menu of
      '1': if Login then
              PlayQuiz 
           else
              begin
                writeln('Login gagal');
                write('Tekan ');
                SetGreen;
                write('ENTER');
                SetYellow;
                writeln(' untuk kembali ke menu utama');
                ResetColor;
                readln;
                ClearScreen;
              end;
      '2': SignUp;
      '3': ShowTop5Scores;
      '4': begin
            ClearScreen;
            ShowAscii(2);
           end;
      end;
  until menu = '4';
end.