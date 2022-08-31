(* Coursera Programming Languages, Homework 3, Provided Code *)

exception NoAnswer

datatype pattern = Wildcard
		 | Variable of string
		 | UnitP
		 | ConstP of int
		 | TupleP of pattern list
		 | ConstructorP of string * pattern

datatype valu = Const of int
	      | Unit
	      | Tuple of valu list
	      | Constructor of string * valu

fun g f1 f2 p =
    let 
	val r = g f1 f2 
    in
	case p of
	    Wildcard          => f1 ()
	  | Variable x        => f2 x
	  | TupleP ps         => List.foldl (fn (p,i) => (r p) + i) 0 ps
	  | ConstructorP(_,p) => r p
	  | _                 => 0
    end

(**** for the challenge problem only ****)

datatype typ = Anything
	     | UnitT
	     | IntT
	     | TupleT of typ list
	     | Datatype of string

(**** you can put all your code here ****)

(* problem 1 *)
fun only_capitals str_list = 
	List.filter (fn a => Char.isUpper(String.sub(a, 0))) str_list

(* problem 2 *)
fun longest_string1 str_list = 
	let
	  fun helper(str1, str2) = 
		if String.size str1 <= String.size str2
		then str2
		else str1
	in
	  List.foldl helper "" str_list
	end

(* problem 3 *)
fun longest_string2 str_list = 
	let
	  fun helper(str1, str2) = 
		if String.size str1 < String.size str2
		then str2
		else str1
	in
	  List.foldl helper "" str_list
	end

(* problem 4 *)
fun longest_string_helper f str_list = 
	let
	  fun helper(str1, str2) = 
	  	if f((String.size str1), (String.size str2))
		then str1
		else str2
	in
	  List.foldl helper "" str_list
	end

val longest_string3 = longest_string_helper (fn (a, b) => a > b)

val longest_string4 = longest_string_helper (fn (a, b) => a >= b)

(* problem 5 *)
val longest_capitalized = longest_string1 o only_capitals

(* problem 6 *)
val rev_string = String.implode o rev o String.explode

(* problem 7 *)
fun first_answer f list = 
	let
	  fun helper arr = 
	  	case arr of
			 [] => raise NoAnswer
		   | element::arr_rst => 
		   		case element of
					  SOME v => v
					| _ => helper arr_rst
	in
	  helper (List.map f list)
	end

(* problem 8 *)
fun all_answers f list = 
	let
	  fun helper arr = 
	  	case arr of
			 [] => SOME []
		   | element::arr_rst => 
				(
					let
					  val tmp = (helper arr_rst)
					in
					  case tmp of
						 NONE => NONE
					   | SOME res_rst => (
								case element of
								SOME v => SOME (v @ res_rst)
								| _ => NONE
					   	 	  )
					end
				)
	in
	  helper (List.map f list)
	end

(* problem 9 *)
(* a *)
fun sum arr = 
	case arr of
	   [] => 0
	 | a::arr_rst => a + (sum arr_rst)

fun count_wildcards pattern = 
	case pattern of
	   Wildcard => 1
	 | Variable _ => 0
	 | UnitP => 0
	 | ConstP _ => 0
	 | TupleP arr => sum (List.map count_wildcards arr)
	 | ConstructorP (str, p) => count_wildcards p

(* b *)
fun count_wild_and_variable_lengths pattern = 
	case pattern of
	   Wildcard => 1
	 | Variable s => String.size s
	 | UnitP => 0
	 | ConstP _ => 0
	 | TupleP arr => sum (List.map count_wild_and_variable_lengths arr)
	 | ConstructorP (str, p) => count_wild_and_variable_lengths p

(* c *)
fun count_some_var_curry str pattern = 
	case pattern of
	   Wildcard => 0
	 | Variable s => if s = str then 1 else 0
	 | UnitP => 0
	 | ConstP _ => 0
	 | TupleP arr => sum (List.map (count_some_var_curry str) arr)
	 | ConstructorP (str1, p) => count_some_var_curry str p

fun count_some_var(str, pattern) = count_some_var_curry str pattern

(* problem 10 *)
fun fold_helper list = 
	let
	  fun f(a, b) = a @ b
	in
	  List.foldl f [] list
	end

fun get_var_names pattern = 
	case pattern of
	 Variable s => [s]
	 | TupleP arr => fold_helper (List.map get_var_names arr)
	 | ConstructorP (str, p) => get_var_names p
	 | _ => []

fun check_pat pattern = 
	let
	  val arr = get_var_names pattern
	  (* 统计出现次数 *)
	  fun cnt arr x = 
	  	case arr of
			 [] => 0
		   | a::arr_rst => 
				if x = a then (1 + (cnt arr_rst x)) else (cnt arr_rst x)
	  (* 判断出现次数是否大于1 *)
	  fun judge arr = 
	  	case arr of
			 [] => true
		   | a::arr_rst => (a = 1) andalso (judge arr_rst)
	in
	  judge (List.map (cnt arr) arr)
	end

(* problem 11 *)
fun match(valu, pattern) = 
	case (valu, pattern) of
	   (v, Wildcard) => SOME []
	 | (v, Variable s) => SOME [(s, v)]
	 | (Unit, UnitP) => SOME []
	 | (Const s1, ConstP s2) => if s1 = s2 then SOME [] else NONE
	 | (Tuple vs, TupleP ps) => 
	 	(
			if (List.length vs) = (List.length ps)
			(* 需要加括号 *)
			then all_answers match (ListPair.zip(vs, ps))
			else NONE
		 )
	 | (Constructor(s2,v), ConstructorP(s1,p)) => 
	 	(
			if s1 = s2
			then match(v, p)
			else NONE
		 )
	 | _ => NONE

(* problem 12 *)
fun first_match value pattern_list = 
	let
	  fun match_helper valu pattern = match(valu, pattern)
	in
	  SOME (first_answer (match_helper value) pattern_list) handle NoAnswer => NONE
	end

(* problem 13 *)
datatype typ = Anything (* any type of value is okay *)
			 | UnitT (* type for Unit *)
			 | IntT (* type for integers *)
			 | TupleT of typ list (* tuple types *)
			 | Datatype of string (* some named datatype *)
			 | Nothing (* for NONE *)

(* 将两个type合并到最宽松的type *)
fun merge_two_type(typ1, typ2) = 
	case (typ1, typ2) of
	     (_, Nothing) => typ1
	   | (Anything, _) => typ2
	   | (_, Anything) => typ1
	   | (TupleT list1, TupleT list2) =>
		(
			if (List.length list1) = (List.length list2)
			then 
				(* 需要先let *)
				(
					let
					  val tmp = ListPair.zip(list1, list2)
					in
					  TupleT (List.map merge_two_type tmp)
					end
				)
			else Nothing
		)
	   | (IntT, IntT) => IntT
	   | (UnitT, UnitT) => UnitT
	   | (Datatype data_type1, Datatype data_type2) => 
	 	(
			if data_type1 = data_type2
			then Datatype data_type1
			else Nothing
		)
	   | _ => Nothing

(* 获得pattern对应的type *)
fun get_type origin_list current_list pattern_ = 
	let
	  (* pattern为Wildcard或ConstructorP, 特殊处理 *)
	  fun type_helper origin_list current_list pattern_ = 
		case pattern_ of
	   		Wildcard => 
			(
				case current_list of
					[] => Anything
				| (name, data_type, type_)::current_list_rst => (Datatype data_type)
			)
	 	  | ConstructorP (str, p) => 
			(
				case current_list of
					[] => Datatype str
				  | (name, data_type, type_)::current_list_rst => 
					(
						if (name = str) andalso 
							(
								let
								val t1 = get_type origin_list origin_list p
								val t2 = merge_two_type(type_, t1)
								in
								(* 重要, 表示可以兼容 *)
								not (t2 = Nothing)
								end
							)
						then (Datatype data_type)
						else (get_type origin_list current_list_rst pattern_)
					)
			)
	 	  | _ => Nothing
		in
			case pattern_ of
				Wildcard => type_helper origin_list current_list pattern_
			  | Variable s => Anything
			  | UnitP => UnitT
			  | ConstP _ => IntT
			  | TupleP pattern_list => TupleT (List.map (get_type origin_list origin_list) pattern_list)
			  | ConstructorP (str, p) => type_helper origin_list current_list pattern_
		end

(* 获得pattern_list中每个pattern的type *)
fun get_type_list list pattern_list = 
	List.map (get_type list list) pattern_list

(* 合并typelist *)
fun merge_list(list, res) = 
	case list of
	   [] => res
	 | type_::list_rst => merge_list(list_rst, merge_two_type(type_, res))

fun typecheck_patterns(list, pattern_list) = 
	let
	  val type_list = get_type_list list pattern_list
	  val res = merge_list(type_list, Nothing)
	in
	  if res = Nothing
	  then NONE
	  else SOME res
	end