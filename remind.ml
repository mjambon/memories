type t = {
  s : string;
  m : int; (* number of bits in the array, i.e. 8 * String.length s *)

  max_bits_set : int; 
  mutable bits_set : int;
  mutable sweep_pos : int;
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
  let pos = x.sweep_pos in
  x.sweep_pos <- (pos + 1) mod x.m;
  if not (clear_bit x.s pos) then
    clear x

let rec right_search a i j ai aj x =
  (*Printf.printf "i=%i j=%i ai=%i aj=%i\n" i j ai aj;*)
  let k = i + (j - i) / 2 in
  let ak = a.(k) in
  if x >= ak then
    if k > i then right_search a k j ak aj x
    else
      if x = ak && x < aj then k
      else j
  else right_search a i k ai ak x

(*
  Find index of the rightmost occurrence of x in sorted array a
  in which elements can be repeated.
  If not found, return the index of the element closest to x
  and greater than x.
*)
let search a x =
  let len = Array.length a in
  if len = 0 then
    invalid_arg "search: empty array";
  let i = 0 in
  let j = len - 1 in
  let ai = a.(i) in
  let aj = a.(j) in
  if x <= ai then 0
  else if x > aj then 0
  else
    right_search a i j ai aj x

let test_search () = (
  assert (search [| 0 |] 0 = 0);
  assert (search [| 0; 0 |] 0 = 0);
  assert (search [| 0; 10; 10; 20 |] 10 = 2);
  assert (search [| 0; 10; 10; 10; 20 |] 10 = 3);
  assert (search [| 0; 10 |] 50 = 0);
  assert (search [| 0; 10 |] (-50) = 0);
  assert (search [| 0; 10 |] 5 = 1);
  assert (search [| 0; 10; 20 |] 15 = 2);
  assert (search [| 0; 10; 10 |] 5 = 1);
  assert (search [| 0; 10; 20; 20 |] 15 = 2);
)

let normalize x a0 =
  let a = Array.map (fun i -> i mod x.m) a0 in
  Array.sort compare a;
  a

let put x a0 k =
  if a0 = [| |] then
    invalid_arg "Remind.put: empty array";
  if k <= 0 then
    invalid_arg "Remind.put: 3rd argument must be positive";
  let a = normalize x a0 in
  let start = search a x.sweep_pos in
  let remaining = ref k in
  let alen = Array.length a in
  try
    for pos = start to start + alen - 1 do
      if !remaining = 0 then
        raise Exit
      else
        let pos = pos mod alen in
        let i = a.(pos) in
        if set_bit x.s i then (
          decr remaining;
          if x.bits_set >= x.max_bits_set then
            clear x
          else
            x.bits_set <- x.bits_set + 1
        )
    done
  with Exit -> ()

let mem x a0 =
  if a0 = [| |] then
    invalid_arg "Remind.mem: empty array";
  let a = normalize x a0 in
  let start = search a x.sweep_pos in
  let acc = ref 0 in
  let alen = Array.length a in
  (try
     for pos = start to start + alen - 1 do
       let pos = pos mod alen in
       let i = a.(pos) in
       if get_bit x.s i then
         incr acc
       else
         raise Exit
     done;
   with Exit -> ()
  );
  !acc

let full_mem x a0 =
  mem x a0 = Array.length a0

let create m =
  if m <= 0 then
    invalid_arg "Memories.create";
  let len = m/8 in
  let len = if 8 * len < m then len + 1 else len in
  {
    s = String.make len '\000';
    m = m;

    max_bits_set = m/2 + m mod 2;
    bits_set = 0;
    sweep_pos = 0;
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
