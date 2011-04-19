(**
   Forgetful Bloom filter

   @author Martin Jambon
*)

type t
  (** Type of a forgetful Bloom filter (FBF) *)

val create : max_bits_set:int -> int -> t
  (** [create ~max_bits_set m] creates an FBF
      of length [m] bits, with a maximum of [max_bits_set]
      being set to 1 at any given time. *)

val put : t -> int array -> unit
  (** [put x a] takes an element hashed into indices [a]
      and puts it into the FBF [x]. *)

val mem : t -> int array -> int
  (** [mem x a] returns how many bits are set for the indices [a]. *)

val print : t -> unit
  (** prints the bit array to stdout *)
