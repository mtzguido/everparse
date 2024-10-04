(*
   Copyright 2023 Microsoft Research

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*)

module CBOR.Spec.Type
include CBOR.Spec.Constants

module U8 = FStar.UInt8
module U64 = FStar.UInt64
module FS = FStar.FiniteSet.Base
module FSA = FStar.FiniteSet.Ambient
module U = CBOR.Spec.Util

(* The generic data model *)

val cbor: eqtype

val cbor_map: eqtype

val cbor_map_get: cbor_map -> cbor -> Tot (option cbor)

let cbor_map_equal (m1 m2: cbor_map) : Tot prop =
  (forall k . cbor_map_get m1 k == cbor_map_get m2 k)

val cbor_map_ext: (m1: cbor_map) -> (m2: cbor_map) -> Lemma
  (ensures (cbor_map_equal m1 m2 <==> m1 == m2))
  [SMTPat (cbor_map_equal m1 m2)]

val cbor_map_set_keys: (m: cbor_map) -> FS.set cbor

val cbor_map_set_keys_mem: (m: cbor_map) -> (k: cbor) -> Lemma
  (FS.mem k (cbor_map_set_keys m) <==> Some? (cbor_map_get m k))
  [SMTPat (FS.mem k (cbor_map_set_keys m))]

val cbor_map_length (m: cbor_map) : Pure nat
  (requires True)
  (ensures (fun n -> n == FS.cardinality (cbor_map_set_keys m)))

val cbor_map_empty: cbor_map

val cbor_map_get_empty: (k: cbor) -> Lemma
  (ensures (cbor_map_get cbor_map_empty k == None))
  [SMTPat (cbor_map_get cbor_map_empty k)]

let cbor_map_set_keys_empty : squash (cbor_map_set_keys cbor_map_empty == FS.emptyset) =
  assert (cbor_map_set_keys cbor_map_empty `FS.equal` FS.emptyset)

let cbor_map_length_empty: squash (cbor_map_length cbor_map_empty == 0) = ()

val cbor_map_singleton: cbor -> cbor -> cbor_map

val cbor_map_get_singleton: (k: cbor) -> (v: cbor) -> (k': cbor) -> Lemma
  (ensures (cbor_map_get (cbor_map_singleton k v) k' == (if k = k' then Some v else None)))
  [SMTPat (cbor_map_get (cbor_map_singleton k v) k')]

let cbor_map_set_keys_singleton (k: cbor) (v: cbor) : Lemma
  (ensures (cbor_map_set_keys (cbor_map_singleton k v) == FS.singleton k))
  [SMTPat (cbor_map_set_keys (cbor_map_singleton k v))]
= assert (cbor_map_set_keys (cbor_map_singleton k v) `FS.equal` FS.singleton k)

let cbor_map_length_singleton (k: cbor) (v: cbor) : Lemma
  (ensures (cbor_map_length (cbor_map_singleton k v) == 1))
= ()

val cbor_map_filter:
  (cbor -> cbor -> bool) ->
  cbor_map ->
  cbor_map

val cbor_map_get_filter: (f: (cbor -> cbor -> bool)) -> (m: cbor_map) -> (k: cbor) -> Lemma
  (ensures (cbor_map_get (cbor_map_filter f m) k == begin match cbor_map_get m k with
  | None -> None
  | Some v -> if f k v then Some v else None
  end))
  [SMTPat (cbor_map_get (cbor_map_filter f m) k)]

val cbor_map_union: cbor_map -> cbor_map -> cbor_map

val cbor_map_get_union: (m1: cbor_map) -> (m2: cbor_map) -> (k: cbor) -> Lemma
  (ensures (cbor_map_get (cbor_map_union m1 m2) k == begin match cbor_map_get m1 k with
    | None -> cbor_map_get m2 k
    | v -> v
    end
  ))
  [SMTPat (cbor_map_get (cbor_map_union m1 m2) k)]

let cbor_map_set_keys_union (m1 m2: cbor_map) : Lemma
  (ensures (cbor_map_set_keys (cbor_map_union m1 m2) == (cbor_map_set_keys m1 `FS.union` cbor_map_set_keys m2)))
  [SMTPat (cbor_map_set_keys (cbor_map_union m1 m2))]
= assert (cbor_map_set_keys (cbor_map_union m1 m2) `FS.equal` (cbor_map_set_keys m1 `FS.union` cbor_map_set_keys m2))

let cbor_map_disjoint (m1 m2: cbor_map) : Tot prop =
  forall k . ~ (Some? (cbor_map_get m1 k) /\ Some? (cbor_map_get m2 k))

let cbor_map_length_disjoint_union (m1 m2: cbor_map) : Lemma
  (requires (cbor_map_disjoint m1 m2))
  (ensures (
    cbor_map_length (cbor_map_union m1 m2) == cbor_map_length m1 + cbor_map_length m2
  ))
= 
  assert (FS.intersection (cbor_map_set_keys m1) (cbor_map_set_keys m2) `FS.equal` FS.emptyset);
  assert (FS.cardinality (FS.union (cbor_map_set_keys m1) (cbor_map_set_keys m2)) == FS.cardinality (cbor_map_set_keys m1) + FS.cardinality (cbor_map_set_keys m2))

type cbor_case =
  | CSimple: (v: simple_value) -> cbor_case
  | CInt64: (typ: major_type_uint64_or_neg_int64) -> (v: U64.t) -> cbor_case
  | CString: (typ: major_type_byte_string_or_text_string) -> (v: Seq.seq U8.t { FStar.UInt.fits (Seq.length v) U64.n }) -> cbor_case // Section 3.1: "a string containing an invalid UTF-8 sequence is well-formed but invalid", so we don't care about UTF-8 specifics here.
  | CArray: (v: list cbor { FStar.UInt.fits (List.Tot.length v) U64.n }) -> cbor_case
  | CMap: (c: cbor_map { FStar.UInt.fits (cbor_map_length c) U64.n }) -> cbor_case
  | CTagged: (tag: U64.t) -> (v: cbor) -> cbor_case

val unpack: cbor -> cbor_case

val pack: cbor_case -> cbor

val unpack_pack: (c: cbor_case) -> Lemma
  (ensures (unpack (pack c) == c))
  [SMTPat (pack c)]

val pack_unpack: (c: cbor) -> Lemma
  (ensures (pack (unpack c) == c))
  [SMTPat (unpack c)]

(** Parsing *)

val cbor_parse : (x: Seq.seq U8.t) -> Pure (option (cbor & nat))
  (requires True)
  (ensures (fun res -> match res with
  | None -> True
  | Some (_, n) -> n <= Seq.length x
  ))

val cbor_parse_prefix
  (x y: Seq.seq U8.t)
: Lemma
  (requires (match cbor_parse x with
  | Some (_, n) -> Seq.length y >= n /\ Seq.slice x 0 n == Seq.slice y 0 n
  | _ -> False
  ))
  (ensures (
    cbor_parse x == cbor_parse y
  ))

(** Deterministic parsing and serialization *)

val cbor_det_serialize: (x: cbor) -> Tot (Seq.seq U8.t)

val cbor_det_parse (x: Seq.seq U8.t) : Pure (option (cbor & nat))
  (requires True)
  (ensures (fun res -> match res with
  | None -> True
  | Some (y, n) -> n <= Seq.length x /\ cbor_parse x == res /\ cbor_det_serialize y == Seq.slice x 0 n // unique binary representation
  ))

let cbor_det_parse_inj
  (x1 x2: Seq.seq U8.t)
: Lemma
  (requires (match cbor_det_parse x1, cbor_det_parse x2 with
  | Some (y1, n1), Some (y2, n2) -> y1 == y2
  | _ -> False
  ))
  (ensures (match cbor_det_parse x1, cbor_det_parse x2 with
  | Some (y1, n1), Some (y2, n2) -> y1 == y2 /\ n1 == n2 /\ Seq.slice x1 0 n1 == Seq.slice x2 0 n2
  | _ -> False
  ))
= let Some (y1, n1) = cbor_det_parse x1 in
  let Some (y2, n2) = cbor_det_parse x2 in
  assert (Seq.slice x1 0 n1 == Seq.slice x2 0 n2);
  assert (Seq.length (Seq.slice x1 0 n1) == Seq.length (Seq.slice x2 0 n2))

val cbor_det_parse_prefix
  (x y: Seq.seq U8.t)
: Lemma
  (requires (match cbor_det_parse x with
  | Some (_, n) -> Seq.length y >= n /\ Seq.slice x 0 n `Seq.equal` Seq.slice y 0 n
  | _ -> False
  ))
  (ensures (
    cbor_det_parse x == cbor_det_parse y
  ))

val cbor_det_serialize_parse (x: cbor) : Lemma
  (let s = cbor_det_serialize x in
    cbor_det_parse s == Some (x, Seq.length s)
  )

let cbor_det_serialize_parse'
  (x: cbor)
  (y: Seq.seq U8.t)
: Lemma
  (let s = cbor_det_serialize x in
    cbor_det_parse (s `Seq.append` y) == Some (x, Seq.length s)
  )
= let s = cbor_det_serialize x in
  cbor_det_serialize_parse x;
  cbor_det_parse_prefix s (s `Seq.append` y)

let cbor_det_serialize_inj_strong
  (x1 x2: cbor)
  (y1 y2: Seq.seq U8.t)
: Lemma
  (requires (cbor_det_serialize x1 `Seq.append` y1 == cbor_det_serialize x2 `Seq.append` y2))
  (ensures (x1 == x2 /\ y1 == y2))
= cbor_det_serialize_parse' x1 y1;
  cbor_det_serialize_parse' x2 y2;
  Seq.lemma_append_inj
    (cbor_det_serialize x1)
    y1
    (cbor_det_serialize x2)
    y2

let cbor_det_serialize_inj
  (x1 x2: cbor)
: Lemma
  (requires (cbor_det_serialize x1 == cbor_det_serialize x2))
  (ensures (x1 == x2))
= Seq.append_empty_r (cbor_det_serialize x1);
  Seq.append_empty_r (cbor_det_serialize x2);
  cbor_det_serialize_inj_strong x1 x2 Seq.empty Seq.empty
