THIS REPOSITORY IS AND WILL REMAIN UNMAINTAINED. PLEASE DON'T SUBMIT
PULL REQUESTS. YOU ARE ENCOURAGED TO FORK THE PROJECT AND MAINTAIN IT
WITH YOUR EMPLOYER'S SUPPORT AND WITH THE HELP OF INTERESTED USERS.

# Forgetful Bloom filters

## Introduction

From http://en.wikipedia.org/wiki/Bloom_filter :

*The Bloom filter, conceived by Burton Howard Bloom in 1970, is a
space-efficient probabilistic data structure that is used to test
whether an element is a member of a set. False positives are possible,
but false negatives are not. Elements can be added to the set, but not
removed (though this can be addressed with a counting filter). The
more elements that are added to the set, the larger the probability of
false positives.*

The practical use of standard Bloom filters is to test whether an
element is not in the set. This is meant to save a more expensive
lookup and is worth using when most queried elements are not in the
set.

Here we are interested in the opposite, that is whether an element was
added to the set and remembered reliably.

This is a fairly useless data structure as it is.
It is interesting however for its simplicity and its philosophical
resemblance with human memories:

* Each cell is like a neuron, i.e. a storage unit holding a piece of
  information that is meaningless when isolated.
* The number of cells, much like neurons in the human brain, does not
  increase over time.
* Many memories are forgotten after a while, in particular those which
  remain unused.


## Algorithm

We assume a mutable bit array of fixed length m initially set with zeros.

Notations:

m: length of the bit array

k: number of array indices associated with each element

E: set of all possible elements (type of the elements)

f: E -> [0,m-1]^k
   multi-hash function that maps an element to k array indices

r: fraction of bits set to 1 at a given time, among the m bits of the array

Operations:

put: E -> unit

     For x in E, put(x) sets the bits given by f(x) to 1 like in a
     classic Bloom filter. Additionally, if r is greater than the
     predetermined threshold rmax, a number of bits of the
     array are cleared (set to 0) until r equals rmax.

mem: E -> [0,k]

     For x in E, return the number of bits set to 1 for the indices
     given by f(x).

The higher the value returned by mem, the more likely it is that a
given element was ever added to the set. Unlike with a classic Bloom
filter this probability is not null once the array is full (r reached
rmax).

Implementation: memories.mli, memories.ml

## Weighted memories

The number k of slots per element does not have to be fixed. We can
use more slots for elements that we want to remember more durably.


## Incremental forgetful Bloom filter

This is an extension of the previous algorithm.

We call sweeper the pointer that clears bits each time a bit is set somewhere
else. The sweeper progresses sequentially along the bit array.

The technique consists in adding the same element slice by slice
(e.g. 64 bits added 8 by 8) faster than the sweeper so that
eventually we reach a point where all the bits for that element are
set. When this happens, we can consider that this element is frequent
enough.

Implementation: remind.mli, remind.ml

Usage:

Given a randomized set of elements (such as words or phrases) of
different frequencies, we want to identify the most frequent
elements. It is achieved by representing each element as an array of
indices as for a regular Bloom filter. For each element of the corpus,
we add it to the filter (Remind.put) and check whether all the bits
are set (Remind.full_mem). If all the bits are set, we consider this
element to be frequent enough and we place it aside.

We would want to use that in a case of large number of elements such that
it would be too expensive to maintain a counter for each of them
either because it would take too much space or because random access
to the disk would be too slow.

An example is to iterate over all the phrases of 1, 2 or 3 words of a
large corpus and to select such phrases which are frequent enough to
be considered of interest for some application.

