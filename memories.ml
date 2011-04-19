type t = {
  s : string;
  m : int; (* number of bits in the array, i.e. 8 * String.length s *)

  max_bits_set : int; 
  mutable bits_set : int;
  mutable pos : int;
}

let get_bit s i =
  let c = Char.code s.[i/8] in
  c land (1 lsl (i mod 8)) <> 0

let set_bit s i =
  let j = i/8 in
  let c = Char.code s.[j] in
  let c' = c lor (1 lsl (i mod 8)) in
  if c' <> c then (
    s.[j] <- Char.chr c';
    true
  )
  else
    false

let clear_bit s i =
  let j = i/8 in
  let c = Char.code s.[j] in
  let c' = (c land (lnot (1 lsl (i mod 8)))) in
  if c' <> c then (
    s.[j] <- Char.chr c';
    true
  )
  else
    false

let rec clear x =
  let pos = x.pos in
  x.pos <- (pos + 1) mod x.m;
  if not (clear_bit x.s pos) then
    clear x

let put x a =
  for pos = 0 to Array.length a - 1 do
    let i = a.(pos) mod x.m in
    if set_bit x.s i then 
      if x.bits_set >= x.max_bits_set then
        clear x
      else
        x.bits_set <- x.bits_set + 1
  done

let mem x a =
  let acc = ref 0 in
  for pos = 0 to Array.length a - 1 do
    let i = a.(pos) mod x.m in
    if get_bit x.s i then
      incr acc
  done;
  !acc

let create ~max_bits_set m =
  if not (max_bits_set > 0 && m >= max_bits_set) then
    invalid_arg "Memories.create";
  let len = m/8 in
  let len = if 8 * len < m then len + 1 else len in
  {
    s = String.make len '\000';
    m = m;

    max_bits_set = max_bits_set; 
    bits_set = 0;
    pos = 0;
  }

let print x =
  for i = 0 to x.m - 1 do
    print_char (if get_bit x.s i then '1' else '0');
    if (i + 1) mod 64 = 0 then
      print_char '\n'
    else
      if (i + 1) mod 8 = 0 then
        print_char ' '
  done
