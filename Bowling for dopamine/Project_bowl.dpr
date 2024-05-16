{$APPTYPE CONSOLE}
program Project_bowl;
uses
  System.SysUtils,
  System.Generics.Collections,
  U_Utils_Functional in 'U_Utils_Functional.pas';

{  Bowling Scoring challenge

 Produce total score.

  Each game, or �line� of bowling, includes ten turns, or �frames� for the bowler.
  In each frame, the bowler gets up to two tries to knock down all the pins.
  - (a,b)

  If in two tries, he fails to knock them all down, his score for that frame is the total number of pins knocked down in his two tries.
  - (a,b)      ->  a+b | a+b < 10

  If in two tries he knocks them all down, this is called a �spare� and his score for the frame is ten plus the number of pins knocked down on his next throw (in his next turn).
  - (a,b)(c,_) -> 10+c | a+b = 10

  If on his first try in the frame he knocks down all the pins, this is called a �strike�. His turn is over, and his score for the frame is ten plus the simple total of the pins knocked down in his next two rolls.
  - (x,_)(c,d) -> 10+c+d

  If he gets a spare or strike in the last (tenth) frame, the bowler gets to throw one or two more bonus balls, respectively. These bonus throws are taken as part of the same turn. If the bonus throws knock down all the pins, the process does not repeat: the bonus throws are only used to calculate the score of the final frame.
  - frame 11 = frame 10

  The game score is the total of all frame scores.
}

const
    N = 5;

    Test_Data : array [1..N] of string =
              (
                 'X. X. X. X. X. X. X. X. X. X. X. X.' ,   //  (12 rolls: 12 strikes) = 10 frames * 30 points = 300
                 '9- 9- 9- 9- 9- 9- 9- 9- 9- 9- .. ..' ,   //  (20 rolls: 10 pairs of 9 and miss) = 10 frames * 9 points = 90
                 '5/ 5/ 5/ 5/ 5/ 5/ 5/ 5/ 5/ 5/ 5. ..' ,   //  (21 rolls: 10 pairs of 5 and spare, with a final 5) = 10 frames * 15 points = 150
                 '-- -- -- -- -- -- -- -- -- 5- .. ..' ,   //   5
                 '1- 2- 3/ X. -4 -5 9/ -- X. 1/ 4. ..'     //   1  3  23  37  41  46  56  56  76  90
              );


function ard(  c:char):byte; begin if c='-' then exit(0) else exit(ord(c)-ord('0')) end;
function add(c,d:char):byte; begin exit(ard(c)+ard(d))   end;


type
    frame = UFP.Tuple<char,char>;


function Bonus(f:TList<frame>; i,n:integer):integer;
begin
    result := 0;
    if n=0 then exit;

    var a  := f[i].fst;
    var b  := f[i].snd;

    if a = 'X' then exit( 10 + Bonus(f,i+1,n-1) );             // add 10, check if another frame is needed

    if n = 1   then exit( ard(a) );                            // add the single number

    if b = '/' then exit(10);                                  // n=2, but no other frames needed

    result := add(a,b);
end;


function Score(f:TList<frame>; i:integer):integer;
begin
    result := 0;
    var a  := f[i].fst;
    var b  := f[i].snd;

    if a='X' then exit( 10 + Bonus(f, i+1, 2) );

    if b='/' then exit( 10 + Bonus(f, i+1, 1) );

    result := add(a,b);
end;



begin
    {massage original data};
    writeln;

    for var test in Test_Data do
    begin
        var games_arr := test.split([' ']);

        var frames := UFP.Array_Map<string,frame> ( games_arr,
                                                    function(s:string):frame
                                                         begin
                                                             result.fst := s[1];
                                                             result.snd := s[2];
                                                         end
                                                   );

        write('> ');
        for var f in frames do write(f.fst,f.snd,'  ');
        writeln; writeln;

        var p:= 0;
        for var i in [0..9] do begin
            p := p + Score( frames, i);
            write(p:4);
        end;

        writeln; writeln; writeln;
    end;

    readln;
end.
