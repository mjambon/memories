(**
   Incremental Forgetful Bloom filter

   @author Martin Jambon
*)

type t
  (** Type of an incremental forgetful Bloom filter (IFBF) *)

val create : int -> t
  (** [create m] creates an IFBF of length [m] bits, with a maximum of [m/2]
      bits being set (to 1) at any given time. *)

val put : t -> int array -> int -> unit
  (** [put x n a] takes an element hashed into [k] indices given 
      as a sorted array [a] and flips [n] of these bits to 1 in the IFBF [x],
      or as many as possible.
  *)

val mem : t -> int array -> int
  (** [mem x a] returns how many consecutive bits are set for the indices [a]
      starting from the position of the sweeper. *)

val full_mem : t -> int array -> bool
  (** [full_mem x a] returns true iff all the bits are set. *)

val print : t -> unit
  (** prints the bit array to stdout *)
