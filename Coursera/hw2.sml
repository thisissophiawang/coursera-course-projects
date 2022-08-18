(* Dan Grossman, Coursera PL, HW2 Provided Code *)

(* if you use this function to compare two strings (returns true if the same
   string), then you avoid several of the functions in problem 1 having
   polymorphic types that may be confusing *)
fun same_string(s1 : string, s2 : string) =
    s1 = s2

(* put your solutions for problem 1 here *)

(* you may assume that Num is always used with values 2, 3, ..., 10
   though it will not really come up *)
datatype suit = Clubs | Diamonds | Hearts | Spades
datatype rank = Jack | Queen | King | Ace | Num of int 
type card = suit * rank

datatype color = Red | Black
datatype move = Discard of card | Draw 

exception IllegalMove

(* put your solutions for problem 2 here *)
(* problem 1.a *)
fun all_except_option(str: string, str_list: string list) = 
   let
      (* 从str_list中删除str, 然后据此判断是否输出NONE *)
      fun filter(str_list) = 
         case str_list of
            [] => []
            | str1::str_list1 => 
               (if same_string(str, str1)
               then
                  str_list1
               else
                  str1::filter(str_list1))
     val res = filter(str_list)
   in
     if res = str_list then NONE else SOME res
   end

(* problem 1.b *)
fun get_substitutions1(strll, str) = 
   case strll of
      [] => []
      | strl::strll_rest =>
         (case all_except_option(str, strl) of
            NONE => [] @ get_substitutions1(strll_rest, str)
            | SOME list => list @ get_substitutions1(strll_rest, str)
         )

(* problem 1.c *)
fun get_substitutions2(strll, str) = 
   let
     fun helper(strll, res) = 
      case strll of
         [] => res
         | strl::strll_rest =>
            (case all_except_option(str, strl) of
               NONE => helper(strll_rest, res)
               | SOME list => helper(strll_rest, res @ list)
            )
   in
     helper(strll, [])
   end

(* problem 1.d *)
fun similar_names(strll, full_name) = 
   let
     val first_name = case full_name of {first=fir, middle=mid, last=las} => fir
     val middle_name = case full_name of {first=fir, middle=mid, last=las} => mid
     val last_name = case full_name of {first=fir, middle=mid, last=las} => las
     val names = get_substitutions2(strll, first_name)
     fun helper(names, res) =
      case names of
         [] => res
         | name::rst => helper(rst, res @ [{first=name, middle=middle_name, last=last_name}])
   in
     helper(names, [full_name])
   end

(* problem 2.a *)
fun card_color(card) = 
   case card of
      (Clubs, rank) => Black
      | (Diamonds, rank) => Red
      | (Hearts, rank) => Red
      | (Spades, rank) => Black

(* problem 2.b *)
fun card_value(card) = 
   case card of
      (_, Num i) => i
      | (_, Ace) => 11
      | (_, _) => 10

(* problem 2.c *)
fun remove_card(cs, c, e) = 
   let
      fun helper(cs, res) = 
         case cs of
            [] => res
            | c1::cs_rest =>
               if c1 = c
               then res @ cs_rest
               else helper(cs_rest, res @ [c1])
      val res = helper(cs, [])
   in
     (* 没有改变表示没有c *)
     if res = cs
     then raise e
     else res
   end

(* problem 2.d *)
fun all_same_color(cards) = 
   case cards of
      [] => true
      | card::[] => true
      | card1::(card2::cards_rst) => (card_color(card1) = card_color(card2)) andalso all_same_color(card2::cards_rst)

(* problem 2.e *)
fun sum_cards(cards) = 
   let
     fun helper(cards, res) = 
      case cards of 
         [] => res
         | card::cards_rst => helper(cards_rst, card_value(card) + res)
   in
     helper(cards, 0)
   end

(* problem 2.f *)
fun score(held_cards, goal) = 
   let
     val sum = sum_cards(held_cards)
     val pre_score =
      if sum > goal
      then 
         (sum - goal) * 3
      else 
         goal - sum
   in
     if all_same_color(held_cards)
     then
      pre_score div 2 
     else
      pre_score
   end

(* problem 2.g *)
fun officiate(card_list, move_list, goal) = 
   let
     fun helper(card_list, held_list, move_list, sum) = 
      if sum > goal
      then
         score(held_list, goal)
      else
         case move_list of
            [] => score(held_list, goal)
            (* 丢弃card *)
            | (Discard card)::move_list_rst => 
               helper(card_list, remove_card(held_list, card, IllegalMove), move_list_rst, sum -  card_value(card))
            | Draw::move_list_rst =>
               case card_list of 
                  [] => score(held_list, goal)
                  | card::card_list_rst => 
                     helper(card_list_rst, held_list @ [card], move_list_rst, sum + card_value(card))
   in
     helper(card_list, [], move_list, 0)
   end

(* problem 3.a *)
fun sum_cards_challenge(cards) = 
   let
     (* for a in arr, get a + num *)
     fun add_list(arr, num) = 
      case arr of 
         [] => []
         | a::arr_rst => (a + num)::add_list(arr_rst, num)
     (* ace = 1 or 11 *)
     fun helper(cards, res) = 
      case cards of 
         [] => res
         | (suit, Ace)::cards_rst => helper(cards_rst, add_list(res, 1) @ add_list(res, 11))
         | card::cards_rst => helper(cards_rst, add_list(res, card_value(card)))
   in
     helper(cards, [0])
   end

fun score_challenge(held_cards, goal) = 
   let
     fun helper1(sum, goal) = 
      if sum > goal
      then 
         (sum - goal) * 3
      else 
         goal - sum
      fun helper2(sum_arr, res) = 
         case sum_arr of
            [] => res
            | sum::sum_arr_rst => helper2(sum_arr_rst, Int.min(helper1(sum, goal), res))
      val flag = all_same_color(held_cards)
      val sum_arr = sum_cards_challenge(held_cards)
      val res = helper2(sum_arr, 100000)
   in
     if flag
     then 
      res div 2 
     else 
      res
   end

fun officiate_challenge(card_list, move_list, goal) = 
   let
     fun helper1(sum) = 
      if sum > goal
      then 
         (sum - goal) * 3
      else 
         goal - sum
     fun helper2(held_list, sum) = 
      let
        val res = helper1(sum)
      in
        if all_same_color(held_list)
        then
         res div 2 
        else
         res
      end
     fun helper3(card_list, held_list, move_list, sum) = 
         if sum > goal
         then
            helper2(held_list, sum)
         else
            case move_list of
               [] => helper2(held_list, sum)
               (* 丢弃card *)
               | (Discard card)::move_list_rst => 
                  helper3(card_list, remove_card(held_list, card, IllegalMove), move_list_rst, sum - card_value(card))
               (* 抽卡 *)
               | Draw::move_list_rst =>
                  case card_list of 
                     [] => helper2(held_list, sum)
                     | card::card_list_rst => 
                        case card of
                          (suit, Ace) => Int.min(helper3(card_list_rst, held_list @ [(suit, Ace)], move_list_rst, sum + 1), helper3(card_list_rst, held_list @ [(suit, Ace)], move_list_rst, sum + 11))
                        | card1 => helper3(card_list_rst, held_list @ [card1], move_list_rst, sum + card_value(card1))

   in
     helper3(card_list, [], move_list, 0)
   end

(* problem 3.b *)
fun careful_player(card_list, goal) = 
   let
     (* 找到值为v的card *)
     fun find_card(card_list, v) = 
      case card_list of
         [] => NONE
       | card::card_list_rst =>
         if card_value(card) = v
         then
            SOME card
         else
            find_card(card_list_rst, v)
     fun helper(card_list, held_list, move_list, sum) = 
      if sum - goal = 0
      then
         move_list
      else
         (* 超过10则直接丢弃, 否则判断是否应该先丢弃再拿 *)
         if goal - sum > 10
         then
            (* 判断是否可以丢弃 *)
            case card_list of 
               [] => move_list @ [Draw]
               | card::card_list_rst => 
                  helper(card_list_rst, card::held_list, move_list @ [Draw], sum + card_value(card))
         else
            case card_list of
               [] => move_list
             | card::card_list_rst => 
               let
                  (* 应该丢弃的卡片value *)
                  (* sum - v + card_value(card) = goal *)
                  val v = sum - goal + card_value(card)
                  (* 可以丢弃的卡片 *)
                  val card_discard = find_card(card_list, v)
               in
                  (* 如果可以得到0, 则直接返回, 否则丢弃卡片 *)
                  if v = 0
                  then
                     move_list @ [Draw]
                  else
                     (* 如果没有可以删除的卡片, 则判断能否丢弃, 不能丢弃则直接返回; 否则先丢弃, 然后再拿 *)
                     case card_discard of
                        NONE =>
                           (* 如果有卡片丢弃, 则直接丢弃, 否则判断是否可拿 *)
                           (case held_list of
                              card1::held_list_rst => helper(card_list, held_list_rst, move_list @ [Discard card1], sum - card_value(card1))
                            | [] => 
                                 (* 如果超过goal, 则不拿, 否则拿 *)
                                 (if sum + card_value(card) > goal
                                 then
                                    move_list
                                 else
                                    helper(card_list_rst, [card], move_list @ [Draw], sum + card_value(card))))
                      | SOME card2 => move_list @ [Discard card2, Draw]
               end
   in
     helper(card_list, [], [], 0)
   end