

type pos = int
type lexresult = Tokens.token

val lineNum = ErrorMsg.lineNum
val linePos = ErrorMsg.linePos
fun err(p1,p2) = ErrorMsg.error p1

val nestingDepth = ref 0
val str = ref ""
val inStr = ref 0
val strStart = ref 0

fun eof() = let val pos = hd(!linePos) 
	val _ = (if !inStr = 1 then 
		(inStr:=0; (ErrorMsg.error pos "unclosed string") )
	else 
		if !nestingDepth > 0 then (nestingDepth:=0;(ErrorMsg.error pos "unclosed comment")) else ())
in Tokens.EOF(pos,pos) end

fun asciiToString(x) = if x < 128 then SOME (Char.toString(Char.chr(x))) else NONE
%% 
%s STRING COMMENT ;
%%
<INITIAL>\" => (YYBEGIN STRING; str := ""; inStr := 1; strStart := yypos; continue());
<INITIAL>"/*" => (YYBEGIN COMMENT; nestingDepth := !nestingDepth + 1; continue());
<COMMENT>"/*" => (nestingDepth := !nestingDepth + 1; continue());
<COMMENT>\013?\n => (lineNum := !lineNum+1; linePos := yypos :: !linePos; continue());
<COMMENT>"*/" => (nestingDepth := !nestingDepth - 1; if !nestingDepth = 0 then YYBEGIN INITIAL else (); continue());
<COMMENT>. => (continue());
<STRING>\\n => (str := !str ^ "\n"; continue());
<STRING>\\t => (str := !str ^ "\t"; continue());
<STRING>\\[0-9]{3} => ((case asciiToString(valOf (Int.fromString(String.substring(yytext, 1, 3)))) of NONE => (ErrorMsg.error yypos ("illegal ascii in string"))
			  | SOME  x => str := !str ^ x); continue());
<STRING>\\\" => (str := !str ^ "\""; continue());
<STRING>\\\\ => (str := !str ^ "\\"; continue());
<STRING>\\[\n\t\013 ]+\\ => (continue());
<STRING>\" => (YYBEGIN INITIAL; inStr := 0; Tokens.STRING(!str, !strStart, yypos+1));
<STRING>\013?\n => ((ErrorMsg.error yypos ("unescaped newline in string")); continue());
<STRING>\t => ((ErrorMsg.error yypos ("unescaped tab character in string")); continue());
<STRING>\b => ((ErrorMsg.error yypos ("unescaped backspace character in string")); continue());
<STRING>\\ => ((ErrorMsg.error yypos ("illegal escape in string")); continue());
<STRING>. => (str := !str ^ yytext; continue());
<INITIAL>while => (Tokens.WHILE(yypos,yypos+5));
<INITIAL>for  => (Tokens.FOR(yypos,yypos+3));
<INITIAL>to => (Tokens.TO(yypos,yypos+2));
<INITIAL>break => (Tokens.BREAK(yypos,yypos+5));
<INITIAL>let => (Tokens.LET(yypos,yypos+3));
<INITIAL>in => (Tokens.IN(yypos,yypos+2));
<INITIAL>end => (Tokens.END(yypos,yypos+3));
<INITIAL>function => (Tokens.FUNCTION(yypos,yypos+8));
<INITIAL>var => (Tokens.VAR(yypos,yypos+3));
<INITIAL>type => (Tokens.TYPE(yypos,yypos+4));
<INITIAL>array => (Tokens.ARRAY(yypos,yypos+5));
<INITIAL>if => (Tokens.IF(yypos,yypos+2));
<INITIAL>then => (Tokens.THEN(yypos,yypos+4));
<INITIAL>else => (Tokens.ELSE(yypos,yypos+4));
<INITIAL>do => (Tokens.DO(yypos,yypos+2));
<INITIAL>of => (Tokens.OF(yypos,yypos+2));
<INITIAL>nil => (Tokens.NIL(yypos,yypos+3));
<INITIAL>[a-zA-Z][a-zA-Z0-9_]* => (Tokens.ID(yytext, yypos, yypos+size(yytext)));
<INITIAL>[0-9]+ => (Tokens.INT(valOf (Int.fromString yytext), yypos, yypos+size(yytext)));
<INITIAL>":=" => (Tokens.ASSIGN(yypos, yypos+2));
<INITIAL>"|" => (Tokens.OR(yypos, yypos+1));
<INITIAL>"&" => (Tokens.AND(yypos, yypos+1));
<INITIAL>">=" => (Tokens.GE(yypos, yypos+2));
<INITIAL>">" => (Tokens.GT(yypos, yypos+1));
<INITIAL>"<=" => (Tokens.LE(yypos, yypos+2));
<INITIAL>"<" => (Tokens.LT(yypos, yypos+1));
<INITIAL>"<>" => (Tokens.NEQ(yypos, yypos+2));
<INITIAL>"=" => (Tokens.EQ(yypos, yypos+1));
<INITIAL>"/" => (Tokens.DIVIDE(yypos, yypos+1));
<INITIAL>"*" => (Tokens.TIMES(yypos, yypos+1));
<INITIAL>"-" => (Tokens.MINUS(yypos, yypos+1));
<INITIAL>"+" => (Tokens.PLUS(yypos, yypos+1));
<INITIAL>"." => (Tokens.DOT(yypos, yypos+1));
<INITIAL>"{" => (Tokens.LBRACE(yypos, yypos+1));
<INITIAL>"}" => (Tokens.RBRACE(yypos, yypos+1));
<INITIAL>"[" => (Tokens.LBRACK(yypos, yypos+1));
<INITIAL>"]" => (Tokens.RBRACK(yypos, yypos+1));
<INITIAL>"(" => (Tokens.LPAREN(yypos, yypos+1));
<INITIAL>")" => (Tokens.RPAREN(yypos, yypos+1));
<INITIAL>";" => (Tokens.SEMICOLON(yypos, yypos+1));
<INITIAL>":" => (Tokens.COLON(yypos, yypos+1));
<INITIAL>(\013?\n)|(\013?\010) => (lineNum := !lineNum+1; linePos := yypos :: !linePos; continue());
<INITIAL>[\013\t ]* => (continue());
<INITIAL>","	=> (Tokens.COMMA(yypos,yypos+1));
<INITIAL>.       => (ErrorMsg.error yypos ("illegal character " ^ yytext); continue());

