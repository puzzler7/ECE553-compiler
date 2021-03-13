functor TigerLrValsFun(structure Token : TOKEN)
 : sig structure ParserData : PARSER_DATA
       structure Tokens : Tiger_TOKENS
   end
 = 
struct
structure ParserData=
struct
structure Header = 
struct
structure A = Absyn


end
structure LrTable = Token.LrTable
structure Token = Token
local open LrTable in 
val table=let val actionRows =
"\
\\001\000\001\000\000\000\000\000\
\\001\000\001\000\146\000\005\000\146\000\007\000\146\000\009\000\146\000\
\\011\000\146\000\013\000\146\000\015\000\035\000\016\000\034\000\
\\017\000\033\000\018\000\032\000\025\000\146\000\026\000\146\000\
\\030\000\146\000\031\000\146\000\034\000\146\000\035\000\146\000\
\\037\000\146\000\038\000\146\000\042\000\146\000\043\000\146\000\
\\044\000\146\000\000\000\
\\001\000\001\000\147\000\005\000\147\000\007\000\147\000\009\000\147\000\
\\011\000\147\000\013\000\147\000\015\000\035\000\016\000\034\000\
\\017\000\033\000\018\000\032\000\025\000\147\000\026\000\147\000\
\\030\000\147\000\031\000\147\000\034\000\147\000\035\000\147\000\
\\037\000\147\000\038\000\147\000\042\000\147\000\043\000\147\000\
\\044\000\147\000\000\000\
\\001\000\001\000\148\000\005\000\148\000\007\000\148\000\009\000\148\000\
\\011\000\148\000\013\000\148\000\015\000\035\000\016\000\034\000\
\\017\000\033\000\018\000\032\000\025\000\148\000\026\000\148\000\
\\030\000\148\000\031\000\148\000\034\000\148\000\035\000\148\000\
\\037\000\148\000\038\000\148\000\042\000\148\000\043\000\148\000\
\\044\000\148\000\000\000\
\\001\000\001\000\149\000\005\000\149\000\007\000\149\000\009\000\149\000\
\\011\000\149\000\013\000\149\000\015\000\035\000\016\000\034\000\
\\017\000\033\000\018\000\032\000\025\000\149\000\026\000\149\000\
\\030\000\149\000\031\000\149\000\034\000\149\000\035\000\149\000\
\\037\000\149\000\038\000\149\000\042\000\149\000\043\000\149\000\
\\044\000\149\000\000\000\
\\001\000\001\000\150\000\005\000\150\000\007\000\150\000\009\000\150\000\
\\011\000\150\000\013\000\150\000\015\000\035\000\016\000\034\000\
\\017\000\033\000\018\000\032\000\025\000\150\000\026\000\150\000\
\\030\000\150\000\031\000\150\000\034\000\150\000\035\000\150\000\
\\037\000\150\000\038\000\150\000\042\000\150\000\043\000\150\000\
\\044\000\150\000\000\000\
\\001\000\001\000\151\000\005\000\151\000\007\000\151\000\009\000\151\000\
\\011\000\151\000\013\000\151\000\015\000\035\000\016\000\034\000\
\\017\000\033\000\018\000\032\000\025\000\151\000\026\000\151\000\
\\030\000\151\000\031\000\151\000\034\000\151\000\035\000\151\000\
\\037\000\151\000\038\000\151\000\042\000\151\000\043\000\151\000\
\\044\000\151\000\000\000\
\\001\000\001\000\175\000\005\000\175\000\007\000\175\000\009\000\175\000\
\\010\000\019\000\011\000\175\000\012\000\190\000\013\000\175\000\
\\014\000\175\000\015\000\175\000\016\000\175\000\017\000\175\000\
\\018\000\175\000\019\000\175\000\020\000\175\000\021\000\175\000\
\\022\000\175\000\023\000\175\000\024\000\175\000\025\000\175\000\
\\026\000\175\000\027\000\175\000\030\000\175\000\031\000\175\000\
\\034\000\175\000\035\000\175\000\037\000\175\000\038\000\175\000\
\\042\000\175\000\043\000\175\000\044\000\175\000\000\000\
\\001\000\001\000\176\000\005\000\176\000\007\000\176\000\009\000\176\000\
\\010\000\173\000\011\000\176\000\013\000\176\000\014\000\176\000\
\\015\000\176\000\016\000\176\000\017\000\176\000\018\000\176\000\
\\019\000\176\000\020\000\176\000\021\000\176\000\022\000\176\000\
\\023\000\176\000\024\000\176\000\025\000\176\000\026\000\176\000\
\\027\000\176\000\030\000\176\000\031\000\176\000\034\000\176\000\
\\035\000\176\000\037\000\176\000\038\000\176\000\042\000\176\000\
\\043\000\176\000\044\000\176\000\000\000\
\\001\000\002\000\018\000\003\000\017\000\004\000\016\000\008\000\015\000\
\\009\000\050\000\016\000\014\000\029\000\013\000\032\000\012\000\
\\033\000\011\000\036\000\010\000\040\000\009\000\041\000\008\000\000\000\
\\001\000\002\000\018\000\003\000\017\000\004\000\016\000\008\000\015\000\
\\016\000\014\000\029\000\013\000\032\000\012\000\033\000\011\000\
\\036\000\010\000\040\000\009\000\041\000\008\000\000\000\
\\001\000\002\000\044\000\000\000\
\\001\000\002\000\057\000\000\000\
\\001\000\002\000\076\000\000\000\
\\001\000\002\000\076\000\012\000\105\000\028\000\104\000\000\000\
\\001\000\002\000\077\000\000\000\
\\001\000\002\000\078\000\000\000\
\\001\000\006\000\092\000\027\000\091\000\000\000\
\\001\000\006\000\118\000\000\000\
\\001\000\006\000\126\000\019\000\125\000\000\000\
\\001\000\008\000\093\000\000\000\
\\001\000\009\000\082\000\000\000\
\\001\000\009\000\098\000\000\000\
\\001\000\009\000\117\000\000\000\
\\001\000\010\000\019\000\000\000\
\\001\000\011\000\086\000\015\000\035\000\016\000\034\000\017\000\033\000\
\\018\000\032\000\019\000\031\000\020\000\030\000\021\000\029\000\
\\022\000\028\000\023\000\027\000\024\000\026\000\025\000\025\000\
\\026\000\024\000\000\000\
\\001\000\012\000\023\000\000\000\
\\001\000\013\000\087\000\000\000\
\\001\000\013\000\123\000\000\000\
\\001\000\015\000\035\000\016\000\034\000\017\000\033\000\018\000\032\000\
\\019\000\031\000\020\000\030\000\021\000\029\000\022\000\028\000\
\\023\000\027\000\024\000\026\000\025\000\025\000\026\000\024\000\
\\030\000\081\000\000\000\
\\001\000\015\000\035\000\016\000\034\000\017\000\033\000\018\000\032\000\
\\019\000\031\000\020\000\030\000\021\000\029\000\022\000\028\000\
\\023\000\027\000\024\000\026\000\025\000\025\000\026\000\024\000\
\\034\000\110\000\000\000\
\\001\000\015\000\035\000\016\000\034\000\017\000\033\000\018\000\032\000\
\\019\000\031\000\020\000\030\000\021\000\029\000\022\000\028\000\
\\023\000\027\000\024\000\026\000\025\000\025\000\026\000\024\000\
\\035\000\080\000\000\000\
\\001\000\015\000\035\000\016\000\034\000\017\000\033\000\018\000\032\000\
\\019\000\031\000\020\000\030\000\021\000\029\000\022\000\028\000\
\\023\000\027\000\024\000\026\000\025\000\025\000\026\000\024\000\
\\035\000\128\000\000\000\
\\001\000\019\000\088\000\000\000\
\\001\000\019\000\090\000\000\000\
\\001\000\019\000\133\000\000\000\
\\001\000\027\000\079\000\000\000\
\\001\000\027\000\116\000\000\000\
\\001\000\037\000\073\000\000\000\
\\001\000\038\000\101\000\000\000\
\\001\000\039\000\114\000\000\000\
\\137\000\015\000\035\000\016\000\034\000\017\000\033\000\018\000\032\000\
\\019\000\031\000\020\000\030\000\021\000\029\000\022\000\028\000\
\\023\000\027\000\024\000\026\000\025\000\025\000\026\000\024\000\000\000\
\\138\000\000\000\
\\139\000\000\000\
\\140\000\000\000\
\\141\000\014\000\022\000\027\000\021\000\000\000\
\\142\000\017\000\033\000\018\000\032\000\000\000\
\\143\000\017\000\033\000\018\000\032\000\000\000\
\\144\000\000\000\
\\145\000\000\000\
\\152\000\015\000\035\000\016\000\034\000\017\000\033\000\018\000\032\000\
\\019\000\031\000\020\000\030\000\021\000\029\000\022\000\028\000\
\\023\000\027\000\024\000\026\000\000\000\
\\153\000\015\000\035\000\016\000\034\000\017\000\033\000\018\000\032\000\
\\019\000\031\000\020\000\030\000\021\000\029\000\022\000\028\000\
\\023\000\027\000\024\000\026\000\025\000\025\000\000\000\
\\154\000\015\000\035\000\016\000\034\000\017\000\033\000\018\000\032\000\
\\019\000\031\000\020\000\030\000\021\000\029\000\022\000\028\000\
\\023\000\027\000\024\000\026\000\025\000\025\000\026\000\024\000\000\000\
\\155\000\015\000\035\000\016\000\034\000\017\000\033\000\018\000\032\000\
\\019\000\031\000\020\000\030\000\021\000\029\000\022\000\028\000\
\\023\000\027\000\024\000\026\000\025\000\025\000\026\000\024\000\
\\031\000\111\000\000\000\
\\156\000\015\000\035\000\016\000\034\000\017\000\033\000\018\000\032\000\
\\019\000\031\000\020\000\030\000\021\000\029\000\022\000\028\000\
\\023\000\027\000\024\000\026\000\025\000\025\000\026\000\024\000\000\000\
\\157\000\015\000\035\000\016\000\034\000\017\000\033\000\018\000\032\000\
\\019\000\031\000\020\000\030\000\021\000\029\000\022\000\028\000\
\\023\000\027\000\024\000\026\000\025\000\025\000\026\000\024\000\000\000\
\\158\000\000\000\
\\159\000\015\000\035\000\016\000\034\000\017\000\033\000\018\000\032\000\
\\019\000\031\000\020\000\030\000\021\000\029\000\022\000\028\000\
\\023\000\027\000\024\000\026\000\025\000\025\000\026\000\024\000\000\000\
\\160\000\000\000\
\\161\000\000\000\
\\162\000\000\000\
\\163\000\015\000\035\000\016\000\034\000\017\000\033\000\018\000\032\000\
\\019\000\031\000\020\000\030\000\021\000\029\000\022\000\028\000\
\\023\000\027\000\024\000\026\000\025\000\025\000\026\000\024\000\000\000\
\\164\000\000\000\
\\165\000\000\000\
\\166\000\000\000\
\\167\000\005\000\113\000\015\000\035\000\016\000\034\000\017\000\033\000\
\\018\000\032\000\019\000\031\000\020\000\030\000\021\000\029\000\
\\022\000\028\000\023\000\027\000\024\000\026\000\025\000\025\000\
\\026\000\024\000\000\000\
\\168\000\000\000\
\\169\000\002\000\059\000\000\000\
\\170\000\005\000\099\000\015\000\035\000\016\000\034\000\017\000\033\000\
\\018\000\032\000\019\000\031\000\020\000\030\000\021\000\029\000\
\\022\000\028\000\023\000\027\000\024\000\026\000\025\000\025\000\
\\026\000\024\000\000\000\
\\171\000\000\000\
\\172\000\002\000\018\000\003\000\017\000\004\000\016\000\008\000\015\000\
\\016\000\014\000\029\000\013\000\032\000\012\000\033\000\011\000\
\\036\000\010\000\040\000\009\000\041\000\008\000\000\000\
\\173\000\000\000\
\\173\000\008\000\051\000\000\000\
\\174\000\000\000\
\\177\000\039\000\020\000\000\000\
\\178\000\000\000\
\\179\000\007\000\083\000\015\000\035\000\016\000\034\000\017\000\033\000\
\\018\000\032\000\019\000\031\000\020\000\030\000\021\000\029\000\
\\022\000\028\000\023\000\027\000\024\000\026\000\025\000\025\000\
\\026\000\024\000\000\000\
\\180\000\000\000\
\\181\000\000\000\
\\182\000\042\000\043\000\043\000\042\000\044\000\041\000\000\000\
\\183\000\000\000\
\\184\000\000\000\
\\185\000\000\000\
\\186\000\000\000\
\\187\000\000\000\
\\188\000\000\000\
\\189\000\000\000\
\\190\000\000\000\
\\191\000\005\000\131\000\000\000\
\\192\000\000\000\
\\193\000\002\000\109\000\000\000\
\\194\000\015\000\035\000\016\000\034\000\017\000\033\000\018\000\032\000\
\\019\000\031\000\020\000\030\000\021\000\029\000\022\000\028\000\
\\023\000\027\000\024\000\026\000\025\000\025\000\026\000\024\000\000\000\
\\195\000\015\000\035\000\016\000\034\000\017\000\033\000\018\000\032\000\
\\019\000\031\000\020\000\030\000\021\000\029\000\022\000\028\000\
\\023\000\027\000\024\000\026\000\025\000\025\000\026\000\024\000\000\000\
\\196\000\015\000\035\000\016\000\034\000\017\000\033\000\018\000\032\000\
\\019\000\031\000\020\000\030\000\021\000\029\000\022\000\028\000\
\\023\000\027\000\024\000\026\000\025\000\025\000\026\000\024\000\000\000\
\\197\000\015\000\035\000\016\000\034\000\017\000\033\000\018\000\032\000\
\\019\000\031\000\020\000\030\000\021\000\029\000\022\000\028\000\
\\023\000\027\000\024\000\026\000\025\000\025\000\026\000\024\000\000\000\
\"
val actionRowNumbers =
"\010\000\007\000\074\000\045\000\
\\026\000\041\000\042\000\063\000\
\\079\000\011\000\010\000\010\000\
\\010\000\009\000\044\000\043\000\
\\072\000\010\000\010\000\010\000\
\\012\000\067\000\010\000\010\000\
\\010\000\010\000\010\000\010\000\
\\010\000\010\000\010\000\010\000\
\\010\000\010\000\082\000\081\000\
\\080\000\079\000\038\000\013\000\
\\015\000\016\000\036\000\031\000\
\\029\000\064\000\021\000\076\000\
\\058\000\070\000\025\000\061\000\
\\057\000\024\000\075\000\008\000\
\\027\000\033\000\051\000\050\000\
\\005\000\004\000\003\000\001\000\
\\002\000\006\000\049\000\048\000\
\\047\000\046\000\078\000\010\000\
\\087\000\034\000\071\000\017\000\
\\020\000\010\000\010\000\010\000\
\\059\000\010\000\022\000\068\000\
\\073\000\062\000\010\000\039\000\
\\014\000\010\000\013\000\090\000\
\\030\000\054\000\053\000\077\000\
\\060\000\070\000\065\000\056\000\
\\084\000\083\000\040\000\090\000\
\\091\000\037\000\023\000\018\000\
\\010\000\010\000\069\000\067\000\
\\013\000\028\000\010\000\019\000\
\\013\000\032\000\052\000\066\000\
\\086\000\085\000\092\000\010\000\
\\013\000\088\000\010\000\093\000\
\\035\000\090\000\055\000\010\000\
\\089\000\094\000\000\000"
val gotoT =
"\
\\001\000\005\000\002\000\134\000\008\000\004\000\012\000\003\000\
\\013\000\002\000\014\000\001\000\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\004\000\038\000\005\000\037\000\006\000\036\000\010\000\035\000\
\\011\000\034\000\000\000\
\\000\000\
\\001\000\043\000\008\000\004\000\012\000\003\000\013\000\002\000\
\\014\000\001\000\000\000\
\\001\000\044\000\008\000\004\000\012\000\003\000\013\000\002\000\
\\014\000\001\000\000\000\
\\001\000\045\000\008\000\004\000\012\000\003\000\013\000\002\000\
\\014\000\001\000\000\000\
\\001\000\047\000\003\000\046\000\008\000\004\000\012\000\003\000\
\\013\000\002\000\014\000\001\000\000\000\
\\000\000\
\\000\000\
\\000\000\
\\001\000\050\000\008\000\004\000\012\000\003\000\013\000\002\000\
\\014\000\001\000\000\000\
\\001\000\051\000\008\000\004\000\012\000\003\000\013\000\002\000\
\\014\000\001\000\000\000\
\\001\000\052\000\008\000\004\000\012\000\003\000\013\000\002\000\
\\014\000\001\000\000\000\
\\013\000\054\000\014\000\053\000\000\000\
\\015\000\056\000\000\000\
\\001\000\058\000\008\000\004\000\012\000\003\000\013\000\002\000\
\\014\000\001\000\000\000\
\\001\000\059\000\008\000\004\000\012\000\003\000\013\000\002\000\
\\014\000\001\000\000\000\
\\001\000\060\000\008\000\004\000\012\000\003\000\013\000\002\000\
\\014\000\001\000\000\000\
\\001\000\061\000\008\000\004\000\012\000\003\000\013\000\002\000\
\\014\000\001\000\000\000\
\\001\000\062\000\008\000\004\000\012\000\003\000\013\000\002\000\
\\014\000\001\000\000\000\
\\001\000\063\000\008\000\004\000\012\000\003\000\013\000\002\000\
\\014\000\001\000\000\000\
\\001\000\064\000\008\000\004\000\012\000\003\000\013\000\002\000\
\\014\000\001\000\000\000\
\\001\000\065\000\008\000\004\000\012\000\003\000\013\000\002\000\
\\014\000\001\000\000\000\
\\001\000\066\000\008\000\004\000\012\000\003\000\013\000\002\000\
\\014\000\001\000\000\000\
\\001\000\067\000\008\000\004\000\012\000\003\000\013\000\002\000\
\\014\000\001\000\000\000\
\\001\000\068\000\008\000\004\000\012\000\003\000\013\000\002\000\
\\014\000\001\000\000\000\
\\001\000\069\000\008\000\004\000\012\000\003\000\013\000\002\000\
\\014\000\001\000\000\000\
\\000\000\
\\000\000\
\\000\000\
\\004\000\070\000\005\000\037\000\006\000\036\000\010\000\035\000\
\\011\000\034\000\000\000\
\\000\000\
\\008\000\073\000\014\000\072\000\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\001\000\083\000\008\000\004\000\012\000\003\000\013\000\002\000\
\\014\000\001\000\016\000\082\000\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\001\000\047\000\003\000\087\000\008\000\004\000\012\000\003\000\
\\013\000\002\000\014\000\001\000\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\001\000\092\000\008\000\004\000\012\000\003\000\013\000\002\000\
\\014\000\001\000\000\000\
\\001\000\093\000\008\000\004\000\012\000\003\000\013\000\002\000\
\\014\000\001\000\000\000\
\\001\000\094\000\008\000\004\000\012\000\003\000\013\000\002\000\
\\014\000\001\000\000\000\
\\000\000\
\\001\000\047\000\003\000\095\000\008\000\004\000\012\000\003\000\
\\013\000\002\000\014\000\001\000\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\001\000\098\000\008\000\004\000\012\000\003\000\013\000\002\000\
\\014\000\001\000\000\000\
\\000\000\
\\007\000\101\000\008\000\100\000\014\000\072\000\000\000\
\\001\000\104\000\008\000\004\000\012\000\003\000\013\000\002\000\
\\014\000\001\000\000\000\
\\008\000\105\000\014\000\072\000\000\000\
\\009\000\106\000\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\001\000\083\000\008\000\004\000\012\000\003\000\013\000\002\000\
\\014\000\001\000\016\000\110\000\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\009\000\113\000\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\001\000\117\000\008\000\004\000\012\000\003\000\013\000\002\000\
\\014\000\001\000\000\000\
\\001\000\118\000\008\000\004\000\012\000\003\000\013\000\002\000\
\\014\000\001\000\000\000\
\\000\000\
\\015\000\119\000\000\000\
\\008\000\120\000\014\000\072\000\000\000\
\\000\000\
\\001\000\122\000\008\000\004\000\012\000\003\000\013\000\002\000\
\\014\000\001\000\000\000\
\\000\000\
\\008\000\125\000\014\000\072\000\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\001\000\127\000\008\000\004\000\012\000\003\000\013\000\002\000\
\\014\000\001\000\000\000\
\\008\000\128\000\014\000\072\000\000\000\
\\000\000\
\\001\000\130\000\008\000\004\000\012\000\003\000\013\000\002\000\
\\014\000\001\000\000\000\
\\000\000\
\\000\000\
\\009\000\132\000\000\000\
\\000\000\
\\001\000\133\000\008\000\004\000\012\000\003\000\013\000\002\000\
\\014\000\001\000\000\000\
\\000\000\
\\000\000\
\\000\000\
\"
val numstates = 135
val numrules = 61
val s = ref "" and index = ref 0
val string_to_int = fn () => 
let val i = !index
in index := i+2; Char.ord(String.sub(!s,i)) + Char.ord(String.sub(!s,i+1)) * 256
end
val string_to_list = fn s' =>
    let val len = String.size s'
        fun f () =
           if !index < len then string_to_int() :: f()
           else nil
   in index := 0; s := s'; f ()
   end
val string_to_pairlist = fn (conv_key,conv_entry) =>
     let fun f () =
         case string_to_int()
         of 0 => EMPTY
          | n => PAIR(conv_key (n-1),conv_entry (string_to_int()),f())
     in f
     end
val string_to_pairlist_default = fn (conv_key,conv_entry) =>
    let val conv_row = string_to_pairlist(conv_key,conv_entry)
    in fn () =>
       let val default = conv_entry(string_to_int())
           val row = conv_row()
       in (row,default)
       end
   end
val string_to_table = fn (convert_row,s') =>
    let val len = String.size s'
        fun f ()=
           if !index < len then convert_row() :: f()
           else nil
     in (s := s'; index := 0; f ())
     end
local
  val memo = Array.array(numstates+numrules,ERROR)
  val _ =let fun g i=(Array.update(memo,i,REDUCE(i-numstates)); g(i+1))
       fun f i =
            if i=numstates then g i
            else (Array.update(memo,i,SHIFT (STATE i)); f (i+1))
          in f 0 handle General.Subscript => ()
          end
in
val entry_to_action = fn 0 => ACCEPT | 1 => ERROR | j => Array.sub(memo,(j-2))
end
val gotoT=Array.fromList(string_to_table(string_to_pairlist(NT,STATE),gotoT))
val actionRows=string_to_table(string_to_pairlist_default(T,entry_to_action),actionRows)
val actionRowNumbers = string_to_list actionRowNumbers
val actionT = let val actionRowLookUp=
let val a=Array.fromList(actionRows) in fn i=>Array.sub(a,i) end
in Array.fromList(List.map actionRowLookUp actionRowNumbers)
end
in LrTable.mkLrTable {actions=actionT,gotos=gotoT,numRules=numrules,
numStates=numstates,initialState=STATE 0}
end
end
local open Header in
type pos = int
type arg = unit
structure MlyValue = 
struct
datatype svalue = VOID | ntVOID of unit ->  unit
 | STRING of unit ->  (string) | INT of unit ->  (int)
 | ID of unit ->  (string) | args of unit ->  (A.exp list)
 | recfields of unit ->  ( ( Symbol.symbol * A.exp * A.pos )  list)
 | typeorlid of unit ->  (Symbol.symbol)
 | hackybrackthing of unit ->  ({ id:Symbol.symbol,exp:A.exp } )
 | lvalue of unit ->  (A.var) | fundec of unit ->  (A.fundec)
 | vardec of unit ->  (A.dec)
 | tyfields of unit ->  ({ name:Symbol.symbol,escape:bool ref,typ:Symbol.symbol,pos:A.pos }  list)
 | typeid of unit ->  (Symbol.symbol) | ty of unit ->  (A.ty)
 | tydec of unit ->  ({ id:Symbol.symbol,ty:A.ty } )
 | dec of unit ->  (A.dec) | decs of unit ->  (A.dec list)
 | exps of unit ->  ( ( A.exp * A.pos )  list)
 | program of unit ->  (A.exp) | exp of unit ->  (A.exp)
end
type svalue = MlyValue.svalue
type result = A.exp
end
structure EC=
struct
open LrTable
infix 5 $$
fun x $$ y = y::x
val is_keyword =
fn (T 31) => true | (T 32) => true | (T 33) => true | (T 39) => true
 | (T 35) => true | (T 36) => true | (T 37) => true | (T 41) => true
 | (T 42) => true | (T 43) => true | (T 27) => true | (T 28) => true
 | (T 29) => true | (T 30) => true | (T 34) => true | (T 38) => true
 | (T 40) => true | _ => false
val preferred_change : (term list * term list) list = 
(nil
,nil
 $$ (T 29))::
(nil
,nil
 $$ (T 30))::
(nil
,nil
 $$ (T 7))::
nil
val noShift = 
fn (T 0) => true | _ => false
val showTerminal =
fn (T 0) => "EOF"
  | (T 1) => "ID"
  | (T 2) => "INT"
  | (T 3) => "STRING"
  | (T 4) => "COMMA"
  | (T 5) => "COLON"
  | (T 6) => "SEMICOLON"
  | (T 7) => "LPAREN"
  | (T 8) => "RPAREN"
  | (T 9) => "LBRACK"
  | (T 10) => "RBRACK"
  | (T 11) => "LBRACE"
  | (T 12) => "RBRACE"
  | (T 13) => "DOT"
  | (T 14) => "PLUS"
  | (T 15) => "MINUS"
  | (T 16) => "TIMES"
  | (T 17) => "DIVIDE"
  | (T 18) => "EQ"
  | (T 19) => "NEQ"
  | (T 20) => "LT"
  | (T 21) => "LE"
  | (T 22) => "GT"
  | (T 23) => "GE"
  | (T 24) => "AND"
  | (T 25) => "OR"
  | (T 26) => "ASSIGN"
  | (T 27) => "ARRAY"
  | (T 28) => "IF"
  | (T 29) => "THEN"
  | (T 30) => "ELSE"
  | (T 31) => "WHILE"
  | (T 32) => "FOR"
  | (T 33) => "TO"
  | (T 34) => "DO"
  | (T 35) => "LET"
  | (T 36) => "IN"
  | (T 37) => "END"
  | (T 38) => "OF"
  | (T 39) => "BREAK"
  | (T 40) => "NIL"
  | (T 41) => "FUNCTION"
  | (T 42) => "VAR"
  | (T 43) => "TYPE"
  | (T 44) => "UMINUS"
  | _ => "bogus-term"
local open Header in
val errtermvalue=
fn _ => MlyValue.VOID
end
val terms : term list = nil
 $$ (T 44) $$ (T 43) $$ (T 42) $$ (T 41) $$ (T 40) $$ (T 39) $$ (T 38)
 $$ (T 37) $$ (T 36) $$ (T 35) $$ (T 34) $$ (T 33) $$ (T 32) $$ (T 31)
 $$ (T 30) $$ (T 29) $$ (T 28) $$ (T 27) $$ (T 26) $$ (T 25) $$ (T 24)
 $$ (T 23) $$ (T 22) $$ (T 21) $$ (T 20) $$ (T 19) $$ (T 18) $$ (T 17)
 $$ (T 16) $$ (T 15) $$ (T 14) $$ (T 13) $$ (T 12) $$ (T 11) $$ (T 10)
 $$ (T 9) $$ (T 8) $$ (T 7) $$ (T 6) $$ (T 5) $$ (T 4) $$ (T 0)end
structure Actions =
struct 
exception mlyAction of int
local open Header in
val actions = 
fn (i392,defaultPos,stack,
    (()):arg) =>
case (i392,stack)
of  ( 0, ( ( _, ( MlyValue.exp exp1, exp1left, exp1right)) :: rest671)
) => let val  result = MlyValue.program (fn _ => let val  (exp as exp1
) = exp1 ()
 in (exp)
end)
 in ( LrTable.NT 1, ( result, exp1left, exp1right), rest671)
end
|  ( 1, ( ( _, ( _, NIL1left, NIL1right)) :: rest671)) => let val  
result = MlyValue.exp (fn _ => (A.NilExp))
 in ( LrTable.NT 0, ( result, NIL1left, NIL1right), rest671)
end
|  ( 2, ( ( _, ( MlyValue.INT INT1, INT1left, INT1right)) :: rest671))
 => let val  result = MlyValue.exp (fn _ => let val  (INT as INT1) = 
INT1 ()
 in (A.IntExp(INT))
end)
 in ( LrTable.NT 0, ( result, INT1left, INT1right), rest671)
end
|  ( 3, ( ( _, ( MlyValue.STRING STRING1, STRING1left, STRING1right))
 :: rest671)) => let val  result = MlyValue.exp (fn _ => let val  (
STRING as STRING1) = STRING1 ()
 in (A.StringExp(STRING, STRING1left))
end)
 in ( LrTable.NT 0, ( result, STRING1left, STRING1right), rest671)
end
|  ( 4, ( ( _, ( MlyValue.lvalue lvalue1, lvalue1left, lvalue1right))
 :: rest671)) => let val  result = MlyValue.exp (fn _ => let val  (
lvalue as lvalue1) = lvalue1 ()
 in (A.VarExp(lvalue))
end)
 in ( LrTable.NT 0, ( result, lvalue1left, lvalue1right), rest671)
end
|  ( 5, ( ( _, ( MlyValue.exp exp2, _, exp2right)) :: ( _, ( _, 
PLUSleft, _)) :: ( _, ( MlyValue.exp exp1, exp1left, _)) :: rest671))
 => let val  result = MlyValue.exp (fn _ => let val  exp1 = exp1 ()
 val  exp2 = exp2 ()
 in (A.OpExp({left=exp1, oper=A.PlusOp, pos=PLUSleft, right=exp2}))

end)
 in ( LrTable.NT 0, ( result, exp1left, exp2right), rest671)
end
|  ( 6, ( ( _, ( MlyValue.exp exp2, _, exp2right)) :: ( _, ( _, 
MINUSleft, _)) :: ( _, ( MlyValue.exp exp1, exp1left, _)) :: rest671))
 => let val  result = MlyValue.exp (fn _ => let val  exp1 = exp1 ()
 val  exp2 = exp2 ()
 in (A.OpExp({left=exp1, oper=A.MinusOp, pos=MINUSleft, right=exp2}))

end)
 in ( LrTable.NT 0, ( result, exp1left, exp2right), rest671)
end
|  ( 7, ( ( _, ( MlyValue.exp exp2, _, exp2right)) :: ( _, ( _, 
TIMESleft, _)) :: ( _, ( MlyValue.exp exp1, exp1left, _)) :: rest671))
 => let val  result = MlyValue.exp (fn _ => let val  exp1 = exp1 ()
 val  exp2 = exp2 ()
 in (A.OpExp({left=exp1, oper=A.TimesOp, pos=TIMESleft, right=exp2}))

end)
 in ( LrTable.NT 0, ( result, exp1left, exp2right), rest671)
end
|  ( 8, ( ( _, ( MlyValue.exp exp2, _, exp2right)) :: ( _, ( _, 
DIVIDEleft, _)) :: ( _, ( MlyValue.exp exp1, exp1left, _)) :: rest671)
) => let val  result = MlyValue.exp (fn _ => let val  exp1 = exp1 ()
 val  exp2 = exp2 ()
 in (A.OpExp({left=exp1, oper=A.DivideOp, pos=DIVIDEleft, right=exp2})
)
end)
 in ( LrTable.NT 0, ( result, exp1left, exp2right), rest671)
end
|  ( 9, ( ( _, ( MlyValue.exp exp2, _, exp2right)) :: ( _, ( _, LTleft
, _)) :: ( _, ( MlyValue.exp exp1, exp1left, _)) :: rest671)) => let
 val  result = MlyValue.exp (fn _ => let val  exp1 = exp1 ()
 val  exp2 = exp2 ()
 in (A.OpExp({left=exp1, oper=A.LtOp, pos=LTleft, right=exp2}))
end)
 in ( LrTable.NT 0, ( result, exp1left, exp2right), rest671)
end
|  ( 10, ( ( _, ( MlyValue.exp exp2, _, exp2right)) :: ( _, ( _, 
NEQleft, _)) :: ( _, ( MlyValue.exp exp1, exp1left, _)) :: rest671))
 => let val  result = MlyValue.exp (fn _ => let val  exp1 = exp1 ()
 val  exp2 = exp2 ()
 in (A.OpExp({left=exp1, oper=A.NeqOp, pos=NEQleft, right=exp2}))
end)
 in ( LrTable.NT 0, ( result, exp1left, exp2right), rest671)
end
|  ( 11, ( ( _, ( MlyValue.exp exp2, _, exp2right)) :: ( _, ( _, 
LEleft, _)) :: ( _, ( MlyValue.exp exp1, exp1left, _)) :: rest671)) =>
 let val  result = MlyValue.exp (fn _ => let val  exp1 = exp1 ()
 val  exp2 = exp2 ()
 in (A.OpExp({left=exp1, oper=A.LeOp, pos=LEleft, right=exp2}))
end)
 in ( LrTable.NT 0, ( result, exp1left, exp2right), rest671)
end
|  ( 12, ( ( _, ( MlyValue.exp exp2, _, exp2right)) :: ( _, ( _, 
GTleft, _)) :: ( _, ( MlyValue.exp exp1, exp1left, _)) :: rest671)) =>
 let val  result = MlyValue.exp (fn _ => let val  exp1 = exp1 ()
 val  exp2 = exp2 ()
 in (A.OpExp({left=exp1, oper=A.GtOp, pos=GTleft, right=exp2}))
end)
 in ( LrTable.NT 0, ( result, exp1left, exp2right), rest671)
end
|  ( 13, ( ( _, ( MlyValue.exp exp2, _, exp2right)) :: ( _, ( _, 
GEleft, _)) :: ( _, ( MlyValue.exp exp1, exp1left, _)) :: rest671)) =>
 let val  result = MlyValue.exp (fn _ => let val  exp1 = exp1 ()
 val  exp2 = exp2 ()
 in (A.OpExp({left=exp1, oper=A.GeOp, pos=GEleft, right=exp2}))
end)
 in ( LrTable.NT 0, ( result, exp1left, exp2right), rest671)
end
|  ( 14, ( ( _, ( MlyValue.exp exp2, _, exp2right)) :: ( _, ( _, 
EQleft, _)) :: ( _, ( MlyValue.exp exp1, exp1left, _)) :: rest671)) =>
 let val  result = MlyValue.exp (fn _ => let val  exp1 = exp1 ()
 val  exp2 = exp2 ()
 in (A.OpExp({left=exp1, oper=A.EqOp, pos=EQleft, right=exp2}))
end)
 in ( LrTable.NT 0, ( result, exp1left, exp2right), rest671)
end
|  ( 15, ( ( _, ( MlyValue.exp exp2, _, exp2right)) :: ( _, ( _, 
AND1left, _)) :: ( _, ( MlyValue.exp exp1, exp1left, _)) :: rest671))
 => let val  result = MlyValue.exp (fn _ => let val  exp1 = exp1 ()
 val  exp2 = exp2 ()
 in (
A.IfExp({test=exp1, then'=exp2, else'=SOME(A.IntExp(0)), pos=AND1left})
)
end)
 in ( LrTable.NT 0, ( result, exp1left, exp2right), rest671)
end
|  ( 16, ( ( _, ( MlyValue.exp exp2, _, exp2right)) :: ( _, ( _, 
OR1left, _)) :: ( _, ( MlyValue.exp exp1, exp1left, _)) :: rest671))
 => let val  result = MlyValue.exp (fn _ => let val  exp1 = exp1 ()
 val  exp2 = exp2 ()
 in (
A.IfExp({test=exp1, then'=A.IntExp(1), else'=SOME(exp2), pos=OR1left})
)
end)
 in ( LrTable.NT 0, ( result, exp1left, exp2right), rest671)
end
|  ( 17, ( ( _, ( MlyValue.exp exp3, _, exp3right)) :: _ :: ( _, ( 
MlyValue.exp exp2, _, _)) :: _ :: ( _, ( MlyValue.exp exp1, _, _)) :: 
( _, ( _, IF1left, _)) :: rest671)) => let val  result = MlyValue.exp
 (fn _ => let val  exp1 = exp1 ()
 val  exp2 = exp2 ()
 val  exp3 = exp3 ()
 in (A.IfExp({test=exp1, then'=exp2, else'=SOME(exp3), pos=IF1left}))

end)
 in ( LrTable.NT 0, ( result, IF1left, exp3right), rest671)
end
|  ( 18, ( ( _, ( MlyValue.exp exp2, _, exp2right)) :: _ :: ( _, ( 
MlyValue.exp exp1, _, _)) :: ( _, ( _, IF1left, _)) :: rest671)) =>
 let val  result = MlyValue.exp (fn _ => let val  exp1 = exp1 ()
 val  exp2 = exp2 ()
 in (A.IfExp({test=exp1, then'=exp2, else'=NONE, pos=IF1left}))
end)
 in ( LrTable.NT 0, ( result, IF1left, exp2right), rest671)
end
|  ( 19, ( ( _, ( MlyValue.exp exp2, _, exp2right)) :: _ :: ( _, ( 
MlyValue.exp exp1, _, _)) :: ( _, ( _, WHILE1left, _)) :: rest671)) =>
 let val  result = MlyValue.exp (fn _ => let val  exp1 = exp1 ()
 val  exp2 = exp2 ()
 in (A.WhileExp({test=exp1, body=exp2, pos=WHILE1left}))
end)
 in ( LrTable.NT 0, ( result, WHILE1left, exp2right), rest671)
end
|  ( 20, ( ( _, ( MlyValue.exp exp3, _, exp3right)) :: _ :: ( _, ( 
MlyValue.exp exp2, _, _)) :: _ :: ( _, ( MlyValue.exp exp1, _, _)) ::
 _ :: ( _, ( MlyValue.ID ID1, _, _)) :: ( _, ( _, (FORleft as FOR1left
), _)) :: rest671)) => let val  result = MlyValue.exp (fn _ => let
 val  (ID as ID1) = ID1 ()
 val  exp1 = exp1 ()
 val  exp2 = exp2 ()
 val  exp3 = exp3 ()
 in (
A.ForExp({var=Symbol.symbol ID, escape=ref true, lo=exp1, hi=exp2, body=exp3, pos=FORleft})
)
end)
 in ( LrTable.NT 0, ( result, FOR1left, exp3right), rest671)
end
|  ( 21, ( ( _, ( _, _, END1right)) :: ( _, ( MlyValue.exps exps1, _,
 _)) :: _ :: ( _, ( MlyValue.decs decs1, _, _)) :: ( _, ( _, (LETleft
 as LET1left), _)) :: rest671)) => let val  result = MlyValue.exp (fn
 _ => let val  (decs as decs1) = decs1 ()
 val  (exps as exps1) = exps1 ()
 in (A.LetExp({decs=decs, body=A.SeqExp(exps), pos=LETleft}))
end)
 in ( LrTable.NT 0, ( result, LET1left, END1right), rest671)
end
|  ( 22, ( ( _, ( MlyValue.exp exp1, _, exp1right)) :: ( _, ( _, 
ASSIGNleft, _)) :: ( _, ( MlyValue.lvalue lvalue1, lvalue1left, _)) ::
 rest671)) => let val  result = MlyValue.exp (fn _ => let val  (lvalue
 as lvalue1) = lvalue1 ()
 val  (exp as exp1) = exp1 ()
 in (A.AssignExp({var=lvalue, exp=exp, pos=ASSIGNleft}))
end)
 in ( LrTable.NT 0, ( result, lvalue1left, exp1right), rest671)
end
|  ( 23, ( ( _, ( _, _, RPAREN1right)) :: ( _, ( _, LPAREN1left, _))
 :: rest671)) => let val  result = MlyValue.exp (fn _ => (A.SeqExp([])
))
 in ( LrTable.NT 0, ( result, LPAREN1left, RPAREN1right), rest671)
end
|  ( 24, ( ( _, ( _, _, RPAREN1right)) :: ( _, ( MlyValue.exps exps1,
 _, _)) :: ( _, ( _, LPAREN1left, _)) :: rest671)) => let val  result
 = MlyValue.exp (fn _ => let val  (exps as exps1) = exps1 ()
 in (A.SeqExp(exps))
end)
 in ( LrTable.NT 0, ( result, LPAREN1left, RPAREN1right), rest671)
end
|  ( 25, ( ( _, ( _, _, RPAREN1right)) :: ( _, ( MlyValue.args args1,
 _, _)) :: _ :: ( _, ( MlyValue.ID ID1, (IDleft as ID1left), _)) :: 
rest671)) => let val  result = MlyValue.exp (fn _ => let val  (ID as 
ID1) = ID1 ()
 val  (args as args1) = args1 ()
 in (A.CallExp({func=Symbol.symbol ID, args=args, pos=IDleft}))
end)
 in ( LrTable.NT 0, ( result, ID1left, RPAREN1right), rest671)
end
|  ( 26, ( ( _, ( MlyValue.exp exp1, _, exp1right)) :: _ :: ( _, ( 
MlyValue.hackybrackthing hackybrackthing1, (hackybrackthingleft as 
hackybrackthing1left), _)) :: rest671)) => let val  result = 
MlyValue.exp (fn _ => let val  (hackybrackthing as hackybrackthing1) =
 hackybrackthing1 ()
 val  (exp as exp1) = exp1 ()
 in (
A.ArrayExp({typ=(#id hackybrackthing), size=(#exp hackybrackthing), init=exp, pos=hackybrackthingleft})
)
end)
 in ( LrTable.NT 0, ( result, hackybrackthing1left, exp1right), 
rest671)
end
|  ( 27, ( ( _, ( _, _, RBRACE1right)) :: ( _, ( MlyValue.recfields 
recfields1, _, _)) :: _ :: ( _, ( MlyValue.typeid typeid1, (typeidleft
 as typeid1left), _)) :: rest671)) => let val  result = MlyValue.exp
 (fn _ => let val  (typeid as typeid1) = typeid1 ()
 val  (recfields as recfields1) = recfields1 ()
 in (A.RecordExp({fields=recfields, typ=typeid, pos=typeidleft}))
end)
 in ( LrTable.NT 0, ( result, typeid1left, RBRACE1right), rest671)
end
|  ( 28, ( ( _, ( _, (BREAKleft as BREAK1left), BREAK1right)) :: 
rest671)) => let val  result = MlyValue.exp (fn _ => (
A.BreakExp(BREAKleft)))
 in ( LrTable.NT 0, ( result, BREAK1left, BREAK1right), rest671)
end
|  ( 29, ( ( _, ( MlyValue.exp exp1, _, exp1right)) :: ( _, ( _, (
MINUSleft as MINUS1left), _)) :: rest671)) => let val  result = 
MlyValue.exp (fn _ => let val  (exp as exp1) = exp1 ()
 in (
A.OpExp({left=A.IntExp(0), oper=A.MinusOp, pos=MINUSleft, right=exp}))

end)
 in ( LrTable.NT 0, ( result, MINUS1left, exp1right), rest671)
end
|  ( 30, ( ( _, ( MlyValue.exp exp1, _, exp1right)) :: _ :: ( _, ( 
MlyValue.ID ID1, (IDleft as ID1left), _)) :: rest671)) => let val  
result = MlyValue.recfields (fn _ => let val  (ID as ID1) = ID1 ()
 val  (exp as exp1) = exp1 ()
 in ([(Symbol.symbol ID, exp, IDleft)])
end)
 in ( LrTable.NT 14, ( result, ID1left, exp1right), rest671)
end
|  ( 31, ( ( _, ( MlyValue.recfields recfields1, _, recfields1right))
 :: _ :: ( _, ( MlyValue.exp exp1, _, _)) :: _ :: ( _, ( MlyValue.ID 
ID1, (IDleft as ID1left), _)) :: rest671)) => let val  result = 
MlyValue.recfields (fn _ => let val  (ID as ID1) = ID1 ()
 val  (exp as exp1) = exp1 ()
 val  (recfields as recfields1) = recfields1 ()
 in ([(Symbol.symbol ID, exp, IDleft)] @ recfields)
end)
 in ( LrTable.NT 14, ( result, ID1left, recfields1right), rest671)
end
|  ( 32, ( rest671)) => let val  result = MlyValue.recfields (fn _ =>
 ([]))
 in ( LrTable.NT 14, ( result, defaultPos, defaultPos), rest671)
end
|  ( 33, ( ( _, ( MlyValue.exp exp1, exp1left, exp1right)) :: rest671)
) => let val  result = MlyValue.args (fn _ => let val  (exp as exp1) =
 exp1 ()
 in ([exp])
end)
 in ( LrTable.NT 15, ( result, exp1left, exp1right), rest671)
end
|  ( 34, ( ( _, ( MlyValue.args args1, _, args1right)) :: _ :: ( _, ( 
MlyValue.exp exp1, exp1left, _)) :: rest671)) => let val  result = 
MlyValue.args (fn _ => let val  (exp as exp1) = exp1 ()
 val  (args as args1) = args1 ()
 in ([exp] @ args)
end)
 in ( LrTable.NT 15, ( result, exp1left, args1right), rest671)
end
|  ( 35, ( rest671)) => let val  result = MlyValue.args (fn _ => ([]))
 in ( LrTable.NT 15, ( result, defaultPos, defaultPos), rest671)
end
|  ( 36, ( ( _, ( MlyValue.ID ID1, ID1left, ID1right)) :: rest671)) =>
 let val  result = MlyValue.typeorlid (fn _ => let val  (ID as ID1) = 
ID1 ()
 in (Symbol.symbol ID)
end)
 in ( LrTable.NT 13, ( result, ID1left, ID1right), rest671)
end
|  ( 37, ( ( _, ( _, _, RBRACK1right)) :: ( _, ( MlyValue.exp exp1, _,
 _)) :: _ :: ( _, ( MlyValue.typeorlid typeorlid1, typeorlid1left, _))
 :: rest671)) => let val  result = MlyValue.hackybrackthing (fn _ =>
 let val  (typeorlid as typeorlid1) = typeorlid1 ()
 val  (exp as exp1) = exp1 ()
 in ({id=typeorlid, exp=exp})
end)
 in ( LrTable.NT 12, ( result, typeorlid1left, RBRACK1right), rest671)

end
|  ( 38, ( ( _, ( MlyValue.typeorlid typeorlid1, (typeorlidleft as 
typeorlid1left), typeorlid1right)) :: rest671)) => let val  result = 
MlyValue.lvalue (fn _ => let val  (typeorlid as typeorlid1) = 
typeorlid1 ()
 in (A.SimpleVar(typeorlid, typeorlidleft))
end)
 in ( LrTable.NT 11, ( result, typeorlid1left, typeorlid1right), 
rest671)
end
|  ( 39, ( ( _, ( MlyValue.ID ID1, _, ID1right)) :: _ :: ( _, ( 
MlyValue.lvalue lvalue1, (lvalueleft as lvalue1left), _)) :: rest671))
 => let val  result = MlyValue.lvalue (fn _ => let val  (lvalue as 
lvalue1) = lvalue1 ()
 val  (ID as ID1) = ID1 ()
 in (A.FieldVar(lvalue, Symbol.symbol ID, lvalueleft))
end)
 in ( LrTable.NT 11, ( result, lvalue1left, ID1right), rest671)
end
|  ( 40, ( ( _, ( MlyValue.hackybrackthing hackybrackthing1, (
hackybrackthingleft as hackybrackthing1left), hackybrackthing1right))
 :: rest671)) => let val  result = MlyValue.lvalue (fn _ => let val  (
hackybrackthing as hackybrackthing1) = hackybrackthing1 ()
 in (
A.SubscriptVar(A.SimpleVar(#id hackybrackthing, hackybrackthingleft), #exp hackybrackthing, hackybrackthingleft)
)
end)
 in ( LrTable.NT 11, ( result, hackybrackthing1left, 
hackybrackthing1right), rest671)
end
|  ( 41, ( ( _, ( MlyValue.hackybrackthing hackybrackthing1, _, 
hackybrackthing1right)) :: _ :: ( _, ( MlyValue.lvalue lvalue1, (
lvalueleft as lvalue1left), _)) :: rest671)) => let val  result = 
MlyValue.lvalue (fn _ => let val  (lvalue as lvalue1) = lvalue1 ()
 val  (hackybrackthing as hackybrackthing1) = hackybrackthing1 ()
 in (A.FieldVar(lvalue, #id hackybrackthing, lvalueleft))
end)
 in ( LrTable.NT 11, ( result, lvalue1left, hackybrackthing1right), 
rest671)
end
|  ( 42, ( ( _, ( MlyValue.exp exp1, exp1left, exp1right)) :: rest671)
) => let val  result = MlyValue.exps (fn _ => let val  (exp as exp1) =
 exp1 ()
 in ([(exp, exp1left)])
end)
 in ( LrTable.NT 2, ( result, exp1left, exp1right), rest671)
end
|  ( 43, ( ( _, ( MlyValue.exps exps1, _, exps1right)) :: _ :: ( _, ( 
MlyValue.exp exp1, exp1left, _)) :: rest671)) => let val  result = 
MlyValue.exps (fn _ => let val  (exp as exp1) = exp1 ()
 val  (exps as exps1) = exps1 ()
 in ([(exp, exp1left)] @ exps)
end)
 in ( LrTable.NT 2, ( result, exp1left, exps1right), rest671)
end
|  ( 44, ( ( _, ( MlyValue.decs decs1, _, decs1right)) :: ( _, ( 
MlyValue.dec dec1, dec1left, _)) :: rest671)) => let val  result = 
MlyValue.decs (fn _ => let val  (dec as dec1) = dec1 ()
 val  (decs as decs1) = decs1 ()
 in (
let
                  fun concat (newdec, []) = [newdec]
                    | concat (newdec, dechead::declist) = case (newdec, dechead, declist) of
                      (A.FunctionDec(ndecflist), A.FunctionDec(hdecflist), declist) => A.FunctionDec(ndecflist @ hdecflist) :: declist
                    | (A.TypeDec(ndectlist), A.TypeDec(hdectlist), declist) => A.TypeDec(ndectlist @ hdectlist) :: declist
                    | (newdec, dechead, declist) => newdec :: (dechead::declist)
                in
                  concat (dec, decs)
                end
)
end)
 in ( LrTable.NT 3, ( result, dec1left, decs1right), rest671)
end
|  ( 45, ( rest671)) => let val  result = MlyValue.decs (fn _ => ([]))
 in ( LrTable.NT 3, ( result, defaultPos, defaultPos), rest671)
end
|  ( 46, ( ( _, ( MlyValue.tydec tydec1, (tydecleft as tydec1left), 
tydec1right)) :: rest671)) => let val  result = MlyValue.dec (fn _ =>
 let val  (tydec as tydec1) = tydec1 ()
 in (A.TypeDec([{name=(#id tydec), ty=(#ty tydec), pos=tydecleft}]))

end)
 in ( LrTable.NT 4, ( result, tydec1left, tydec1right), rest671)
end
|  ( 47, ( ( _, ( MlyValue.vardec vardec1, vardec1left, vardec1right))
 :: rest671)) => let val  result = MlyValue.dec (fn _ => let val  (
vardec as vardec1) = vardec1 ()
 in (vardec)
end)
 in ( LrTable.NT 4, ( result, vardec1left, vardec1right), rest671)
end
|  ( 48, ( ( _, ( MlyValue.fundec fundec1, fundec1left, fundec1right))
 :: rest671)) => let val  result = MlyValue.dec (fn _ => let val  (
fundec as fundec1) = fundec1 ()
 in (A.FunctionDec([fundec]))
end)
 in ( LrTable.NT 4, ( result, fundec1left, fundec1right), rest671)
end
|  ( 49, ( ( _, ( MlyValue.ty ty1, _, ty1right)) :: _ :: ( _, ( 
MlyValue.typeid typeid1, _, _)) :: ( _, ( _, TYPE1left, _)) :: rest671
)) => let val  result = MlyValue.tydec (fn _ => let val  (typeid as 
typeid1) = typeid1 ()
 val  (ty as ty1) = ty1 ()
 in ({id=typeid, ty=ty})
end)
 in ( LrTable.NT 5, ( result, TYPE1left, ty1right), rest671)
end
|  ( 50, ( ( _, ( MlyValue.typeid typeid1, (typeidleft as typeid1left)
, typeid1right)) :: rest671)) => let val  result = MlyValue.ty (fn _
 => let val  (typeid as typeid1) = typeid1 ()
 in (A.NameTy(typeid, typeidleft))
end)
 in ( LrTable.NT 6, ( result, typeid1left, typeid1right), rest671)
end
|  ( 51, ( ( _, ( _, _, RBRACE1right)) :: ( _, ( MlyValue.tyfields 
tyfields1, _, _)) :: ( _, ( _, LBRACE1left, _)) :: rest671)) => let
 val  result = MlyValue.ty (fn _ => let val  (tyfields as tyfields1) =
 tyfields1 ()
 in (A.RecordTy(tyfields))
end)
 in ( LrTable.NT 6, ( result, LBRACE1left, RBRACE1right), rest671)
end
|  ( 52, ( ( _, ( MlyValue.typeid typeid1, typeidleft, typeid1right))
 :: _ :: ( _, ( _, ARRAY1left, _)) :: rest671)) => let val  result = 
MlyValue.ty (fn _ => let val  (typeid as typeid1) = typeid1 ()
 in (A.ArrayTy(typeid, typeidleft))
end)
 in ( LrTable.NT 6, ( result, ARRAY1left, typeid1right), rest671)
end
|  ( 53, ( ( _, ( MlyValue.typeorlid typeorlid1, typeorlid1left, 
typeorlid1right)) :: rest671)) => let val  result = MlyValue.typeid
 (fn _ => let val  (typeorlid as typeorlid1) = typeorlid1 ()
 in (typeorlid)
end)
 in ( LrTable.NT 7, ( result, typeorlid1left, typeorlid1right), 
rest671)
end
|  ( 54, ( ( _, ( MlyValue.typeid typeid1, _, typeid1right)) :: _ :: (
 _, ( MlyValue.ID ID1, (IDleft as ID1left), _)) :: rest671)) => let
 val  result = MlyValue.tyfields (fn _ => let val  (ID as ID1) = ID1
 ()
 val  (typeid as typeid1) = typeid1 ()
 in (
[{name=Symbol.symbol ID, escape=ref true, typ=typeid, pos=IDleft}])

end)
 in ( LrTable.NT 8, ( result, ID1left, typeid1right), rest671)
end
|  ( 55, ( ( _, ( MlyValue.tyfields tyfields1, _, tyfields1right)) ::
 _ :: ( _, ( MlyValue.typeid typeid1, _, _)) :: _ :: ( _, ( 
MlyValue.ID ID1, (IDleft as ID1left), _)) :: rest671)) => let val  
result = MlyValue.tyfields (fn _ => let val  (ID as ID1) = ID1 ()
 val  (typeid as typeid1) = typeid1 ()
 val  (tyfields as tyfields1) = tyfields1 ()
 in (
[{name=Symbol.symbol ID, escape=ref true, typ=typeid, pos=IDleft}] @ tyfields
)
end)
 in ( LrTable.NT 8, ( result, ID1left, tyfields1right), rest671)
end
|  ( 56, ( rest671)) => let val  result = MlyValue.tyfields (fn _ => (
[]))
 in ( LrTable.NT 8, ( result, defaultPos, defaultPos), rest671)
end
|  ( 57, ( ( _, ( MlyValue.exp exp1, _, exp1right)) :: ( _, ( _, 
ASSIGNleft, _)) :: ( _, ( MlyValue.ID ID1, _, _)) :: ( _, ( _, 
VAR1left, _)) :: rest671)) => let val  result = MlyValue.vardec (fn _
 => let val  (ID as ID1) = ID1 ()
 val  (exp as exp1) = exp1 ()
 in (
A.VarDec({name=Symbol.symbol ID, escape=ref true, typ=NONE, init=exp, pos=ASSIGNleft})
)
end)
 in ( LrTable.NT 9, ( result, VAR1left, exp1right), rest671)
end
|  ( 58, ( ( _, ( MlyValue.exp exp1, _, exp1right)) :: ( _, ( _, 
ASSIGNleft, _)) :: ( _, ( MlyValue.typeid typeid1, typeidleft, _)) ::
 _ :: ( _, ( MlyValue.ID ID1, _, _)) :: ( _, ( _, VAR1left, _)) :: 
rest671)) => let val  result = MlyValue.vardec (fn _ => let val  (ID
 as ID1) = ID1 ()
 val  (typeid as typeid1) = typeid1 ()
 val  (exp as exp1) = exp1 ()
 in (
A.VarDec({name=Symbol.symbol ID, escape=ref true, typ=SOME(typeid, typeidleft), init=exp, pos=ASSIGNleft})
)
end)
 in ( LrTable.NT 9, ( result, VAR1left, exp1right), rest671)
end
|  ( 59, ( ( _, ( MlyValue.exp exp1, _, exp1right)) :: _ :: _ :: ( _, 
( MlyValue.tyfields tyfields1, _, _)) :: _ :: ( _, ( MlyValue.ID ID1,
 _, _)) :: ( _, ( _, (FUNCTIONleft as FUNCTION1left), _)) :: rest671))
 => let val  result = MlyValue.fundec (fn _ => let val  (ID as ID1) = 
ID1 ()
 val  (tyfields as tyfields1) = tyfields1 ()
 val  (exp as exp1) = exp1 ()
 in (
{name=Symbol.symbol ID, params=tyfields, result=NONE, body=exp, pos=FUNCTIONleft}
)
end)
 in ( LrTable.NT 10, ( result, FUNCTION1left, exp1right), rest671)
end
|  ( 60, ( ( _, ( MlyValue.exp exp1, _, exp1right)) :: _ :: ( _, ( 
MlyValue.typeid typeid1, typeidleft, _)) :: _ :: _ :: ( _, ( 
MlyValue.tyfields tyfields1, _, _)) :: _ :: ( _, ( MlyValue.ID ID1, _,
 _)) :: ( _, ( _, (FUNCTIONleft as FUNCTION1left), _)) :: rest671)) =>
 let val  result = MlyValue.fundec (fn _ => let val  (ID as ID1) = ID1
 ()
 val  (tyfields as tyfields1) = tyfields1 ()
 val  (typeid as typeid1) = typeid1 ()
 val  (exp as exp1) = exp1 ()
 in (
{name=Symbol.symbol ID, params=tyfields, result=SOME(typeid, typeidleft), body=exp, pos=FUNCTIONleft}
)
end)
 in ( LrTable.NT 10, ( result, FUNCTION1left, exp1right), rest671)
end
| _ => raise (mlyAction i392)
end
val void = MlyValue.VOID
val extract = fn a => (fn MlyValue.program x => x
| _ => let exception ParseInternal
	in raise ParseInternal end) a ()
end
end
structure Tokens : Tiger_TOKENS =
struct
type svalue = ParserData.svalue
type ('a,'b) token = ('a,'b) Token.token
fun EOF (p1,p2) = Token.TOKEN (ParserData.LrTable.T 0,(
ParserData.MlyValue.VOID,p1,p2))
fun ID (i,p1,p2) = Token.TOKEN (ParserData.LrTable.T 1,(
ParserData.MlyValue.ID (fn () => i),p1,p2))
fun INT (i,p1,p2) = Token.TOKEN (ParserData.LrTable.T 2,(
ParserData.MlyValue.INT (fn () => i),p1,p2))
fun STRING (i,p1,p2) = Token.TOKEN (ParserData.LrTable.T 3,(
ParserData.MlyValue.STRING (fn () => i),p1,p2))
fun COMMA (p1,p2) = Token.TOKEN (ParserData.LrTable.T 4,(
ParserData.MlyValue.VOID,p1,p2))
fun COLON (p1,p2) = Token.TOKEN (ParserData.LrTable.T 5,(
ParserData.MlyValue.VOID,p1,p2))
fun SEMICOLON (p1,p2) = Token.TOKEN (ParserData.LrTable.T 6,(
ParserData.MlyValue.VOID,p1,p2))
fun LPAREN (p1,p2) = Token.TOKEN (ParserData.LrTable.T 7,(
ParserData.MlyValue.VOID,p1,p2))
fun RPAREN (p1,p2) = Token.TOKEN (ParserData.LrTable.T 8,(
ParserData.MlyValue.VOID,p1,p2))
fun LBRACK (p1,p2) = Token.TOKEN (ParserData.LrTable.T 9,(
ParserData.MlyValue.VOID,p1,p2))
fun RBRACK (p1,p2) = Token.TOKEN (ParserData.LrTable.T 10,(
ParserData.MlyValue.VOID,p1,p2))
fun LBRACE (p1,p2) = Token.TOKEN (ParserData.LrTable.T 11,(
ParserData.MlyValue.VOID,p1,p2))
fun RBRACE (p1,p2) = Token.TOKEN (ParserData.LrTable.T 12,(
ParserData.MlyValue.VOID,p1,p2))
fun DOT (p1,p2) = Token.TOKEN (ParserData.LrTable.T 13,(
ParserData.MlyValue.VOID,p1,p2))
fun PLUS (p1,p2) = Token.TOKEN (ParserData.LrTable.T 14,(
ParserData.MlyValue.VOID,p1,p2))
fun MINUS (p1,p2) = Token.TOKEN (ParserData.LrTable.T 15,(
ParserData.MlyValue.VOID,p1,p2))
fun TIMES (p1,p2) = Token.TOKEN (ParserData.LrTable.T 16,(
ParserData.MlyValue.VOID,p1,p2))
fun DIVIDE (p1,p2) = Token.TOKEN (ParserData.LrTable.T 17,(
ParserData.MlyValue.VOID,p1,p2))
fun EQ (p1,p2) = Token.TOKEN (ParserData.LrTable.T 18,(
ParserData.MlyValue.VOID,p1,p2))
fun NEQ (p1,p2) = Token.TOKEN (ParserData.LrTable.T 19,(
ParserData.MlyValue.VOID,p1,p2))
fun LT (p1,p2) = Token.TOKEN (ParserData.LrTable.T 20,(
ParserData.MlyValue.VOID,p1,p2))
fun LE (p1,p2) = Token.TOKEN (ParserData.LrTable.T 21,(
ParserData.MlyValue.VOID,p1,p2))
fun GT (p1,p2) = Token.TOKEN (ParserData.LrTable.T 22,(
ParserData.MlyValue.VOID,p1,p2))
fun GE (p1,p2) = Token.TOKEN (ParserData.LrTable.T 23,(
ParserData.MlyValue.VOID,p1,p2))
fun AND (p1,p2) = Token.TOKEN (ParserData.LrTable.T 24,(
ParserData.MlyValue.VOID,p1,p2))
fun OR (p1,p2) = Token.TOKEN (ParserData.LrTable.T 25,(
ParserData.MlyValue.VOID,p1,p2))
fun ASSIGN (p1,p2) = Token.TOKEN (ParserData.LrTable.T 26,(
ParserData.MlyValue.VOID,p1,p2))
fun ARRAY (p1,p2) = Token.TOKEN (ParserData.LrTable.T 27,(
ParserData.MlyValue.VOID,p1,p2))
fun IF (p1,p2) = Token.TOKEN (ParserData.LrTable.T 28,(
ParserData.MlyValue.VOID,p1,p2))
fun THEN (p1,p2) = Token.TOKEN (ParserData.LrTable.T 29,(
ParserData.MlyValue.VOID,p1,p2))
fun ELSE (p1,p2) = Token.TOKEN (ParserData.LrTable.T 30,(
ParserData.MlyValue.VOID,p1,p2))
fun WHILE (p1,p2) = Token.TOKEN (ParserData.LrTable.T 31,(
ParserData.MlyValue.VOID,p1,p2))
fun FOR (p1,p2) = Token.TOKEN (ParserData.LrTable.T 32,(
ParserData.MlyValue.VOID,p1,p2))
fun TO (p1,p2) = Token.TOKEN (ParserData.LrTable.T 33,(
ParserData.MlyValue.VOID,p1,p2))
fun DO (p1,p2) = Token.TOKEN (ParserData.LrTable.T 34,(
ParserData.MlyValue.VOID,p1,p2))
fun LET (p1,p2) = Token.TOKEN (ParserData.LrTable.T 35,(
ParserData.MlyValue.VOID,p1,p2))
fun IN (p1,p2) = Token.TOKEN (ParserData.LrTable.T 36,(
ParserData.MlyValue.VOID,p1,p2))
fun END (p1,p2) = Token.TOKEN (ParserData.LrTable.T 37,(
ParserData.MlyValue.VOID,p1,p2))
fun OF (p1,p2) = Token.TOKEN (ParserData.LrTable.T 38,(
ParserData.MlyValue.VOID,p1,p2))
fun BREAK (p1,p2) = Token.TOKEN (ParserData.LrTable.T 39,(
ParserData.MlyValue.VOID,p1,p2))
fun NIL (p1,p2) = Token.TOKEN (ParserData.LrTable.T 40,(
ParserData.MlyValue.VOID,p1,p2))
fun FUNCTION (p1,p2) = Token.TOKEN (ParserData.LrTable.T 41,(
ParserData.MlyValue.VOID,p1,p2))
fun VAR (p1,p2) = Token.TOKEN (ParserData.LrTable.T 42,(
ParserData.MlyValue.VOID,p1,p2))
fun TYPE (p1,p2) = Token.TOKEN (ParserData.LrTable.T 43,(
ParserData.MlyValue.VOID,p1,p2))
fun UMINUS (p1,p2) = Token.TOKEN (ParserData.LrTable.T 44,(
ParserData.MlyValue.VOID,p1,p2))
end
end
