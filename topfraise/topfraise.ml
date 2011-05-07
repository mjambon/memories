open Printf

let filter_length_in_bytes = 1024
let bits_per_element = 64
let acceptable_bits_per_element = 56
let increment = 8

let make_phrase_stream ic =
  let a = ref "" in
  let b = ref "" in
  Stream.from (
    fun i ->
      try
        let s = input_line ic in
        let phrase = (!a, !b, s) in
        a := !b;
        b := s;
        Some phrase
      with End_of_file -> None
  )

let hash s =
  let num_md5 =
    bits_per_element / 16 + (if bits_per_element mod 16 = 0 then 0 else 1)
  in
  let buf = Buffer.create (16 * num_md5) in
  let prev = ref s in
  for i = 1 to num_md5 do
    let md5 = Digest.string !prev in
    Buffer.add_string buf md5;
    prev := md5
  done;
  let random_bytes = Buffer.contents buf in
  let indices = Array.make bits_per_element 0 in
  for start = 0 to bits_per_element - 1 do
    let n = ref 0 in
    for i = 0 to 7 do
      let pos = (start + i) mod (String.length random_bytes) in
      n := (!n lsl 8) lor (Char.code random_bytes.[pos])
    done;
    let index = !n land max_int in
    indices.(start) <- index
  done;
  indices

let process_phrase oc filter s =
  let h = hash s in
  let old_len = Remind.put filter h increment in
  let new_len = Remind.mem filter h in
  if old_len < acceptable_bits_per_element
    && new_len >= acceptable_bits_per_element then
      fprintf oc "%s\n" s

let process_words oc filter (a, b, c) =
  let ab = a ^ " " ^ b in
  let abc = ab ^ " " ^ c in
  process_phrase oc filter a;
  process_phrase oc filter ab;
  process_phrase oc filter abc

let () =
  let filter = Remind.create (8 * filter_length_in_bytes) in
  let stream = make_phrase_stream stdin in
  Stream.iter (process_words stdout filter) stream
