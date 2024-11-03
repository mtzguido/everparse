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

module CDDL.Pulse
open Pulse.Lib.Pervasives
open Pulse.Lib.Stick
open CBOR.Spec
include CBOR.Pulse
open CDDL.Spec


module R = Pulse.Lib.Reference

module U64 = FStar.UInt64

module U8 = FStar.UInt8

noextract [@@noextract_to "krml"]
let cbor_read_with_typ_success_postcond
  (t: typ)
  (va: Ghost.erased (Seq.seq U8.t))
  (c: cbor_read_t)
  (v: raw_data_item)
  (rem: Seq.seq U8.t)
: Tot prop
=
    cbor_read_success_postcond va c v rem /\
    t v == true

module A = Pulse.Lib.Array

let cbor_read_with_typ_success_post
  (t: typ)
  (a: A.array U8.t)
  (p: perm)
  (va: Ghost.erased (Seq.seq U8.t))
  (c: cbor_read_t)
: Tot vprop
= exists* v rem.
    raw_data_item_match 1.0R c.cbor_read_payload v **
    A.pts_to c.cbor_read_remainder #p rem **
    ((raw_data_item_match 1.0R c.cbor_read_payload v ** A.pts_to c.cbor_read_remainder #p rem) @==>
      A.pts_to a #p va) **
    pure (cbor_read_with_typ_success_postcond t va c v rem)

noextract [@@noextract_to "krml"]
let cbor_read_with_typ_error_postcond
  (t: typ)
  (va: Ghost.erased (Seq.seq U8.t))
: Tot prop
= forall v suff .
    Ghost.reveal va == serialize_cbor v `Seq.append` suff ==>
    t v == false

let cbor_read_with_typ_error_postcond_intro_typ_fail
  (t: typ)
  (va: Ghost.erased (Seq.seq U8.t))
  (c: cbor_read_t)
  (v: raw_data_item)
  (rem: Seq.seq U8.t)
: Lemma
    (requires (
        cbor_read_success_postcond va c v rem /\
        t v == false
    ))
    (ensures (
        cbor_read_with_typ_error_postcond t va
    ))
= serialize_cbor_with_test_correct v rem (fun v' rem' -> t v' == true)

let cbor_read_with_typ_error_post
  (t: typ)
  (a: A.array U8.t)
  (p: perm)
  (va: Ghost.erased (Seq.seq U8.t))
: Tot vprop
= A.pts_to a #p va ** pure (cbor_read_with_typ_error_postcond t va)

let cbor_read_with_typ_post
  (t: typ)
  (a: A.array U8.t)
  (p: perm)
  (va: Ghost.erased (Seq.seq U8.t))
  (res: cbor_read_t)
: Tot vprop
= if res.cbor_read_is_success
  then cbor_read_with_typ_success_post t a p va res
  else cbor_read_with_typ_error_post t a p va

module SZ = FStar.SizeT

inline_for_extraction noextract
let mk_cbor_read_error
    (res: cbor_read_t)
: Tot cbor_read_t
= {res with cbor_read_is_success = false}

inline_for_extraction noextract [@@noextract_to "krml"]
```pulse
fn cbor_read_with_typ
  (#t: typ)
  (ft: impl_typ t)
  (a: A.array U8.t)
  (sz: SZ.t)
  (#va: Ghost.erased (Seq.seq U8.t))
  (#p: perm)
requires
    (A.pts_to a #p va ** pure (
      (SZ.v sz == Seq.length va \/ SZ.v sz == A.length a)
    ))
returns res: cbor_read_t
ensures cbor_read_with_typ_post t a p va res
{
    let res = cbor_read a sz;
    if (res.cbor_read_is_success) {
        rewrite (cbor_read_post a p va res) as (cbor_read_success_post a p va res);
        unfold (cbor_read_success_post a p va res);
        let test = ft res.cbor_read_payload;
        if (test) {
            fold (cbor_read_with_typ_success_post t a p va res);
            rewrite (cbor_read_with_typ_success_post t a p va res) as (cbor_read_with_typ_post t a p va res);
            res
        } else {
            with v . assert (raw_data_item_match 1.0R res.cbor_read_payload v);
            with vrem . assert (A.pts_to res.cbor_read_remainder #p vrem);
            cbor_read_with_typ_error_postcond_intro_typ_fail t va res v vrem;
            elim_stick0 ()
                #(raw_data_item_match 1.0R res.cbor_read_payload v ** A.pts_to res.cbor_read_remainder #p vrem);
            fold (cbor_read_with_typ_error_post t a p va);
            let res = mk_cbor_read_error res;
            rewrite (cbor_read_with_typ_error_post t a p va) as (cbor_read_with_typ_post t a p va res);
            res
        }
    } else {
        rewrite (cbor_read_post a p va res) as (cbor_read_error_post a p va);
        unfold (cbor_read_error_post a p va);
        fold (cbor_read_with_typ_error_post t a p va);
        rewrite (cbor_read_with_typ_error_post t a p va) as (cbor_read_with_typ_post t a p va res);
        res
    }
}
```
noextract [@@noextract_to "krml"]
let cbor_read_deterministically_encoded_with_typ_success_postcond
  (t: typ)
  (va: Ghost.erased (Seq.seq U8.t))
  (c: cbor_read_t)
  (v: raw_data_item)
  (rem: Seq.seq U8.t)
: Tot prop
=
    cbor_read_deterministically_encoded_success_postcond va c v rem /\
    t v == true

noextract [@@noextract_to "krml"]
let cbor_read_deterministically_encoded_with_typ_error_postcond
  (t: typ)
  (va: Ghost.erased (Seq.seq U8.t))
: Tot prop
= forall v suff .
    (Ghost.reveal va == serialize_cbor v `Seq.append` suff /\
        data_item_wf deterministically_encoded_cbor_map_key_order v == true
    ) ==>
    t v == false

let cbor_read_deterministically_encoded_with_typ_error_postcond_intro_typ_fail
  (t: typ)
  (va: Ghost.erased (Seq.seq U8.t))
  (c: cbor_read_t)
  (v: raw_data_item)
  (rem: Seq.seq U8.t)
: Lemma
    (requires (
        cbor_read_deterministically_encoded_success_postcond va c v rem /\
        t v == false
    ))
    (ensures (
        cbor_read_deterministically_encoded_with_typ_error_postcond t va
    ))
= serialize_cbor_with_test_correct v rem (fun v' rem' -> data_item_wf deterministically_encoded_cbor_map_key_order v' == true /\ t v' == true)

let cbor_read_deterministically_encoded_with_typ_success_post
  (t: typ)
  (a: A.array U8.t)
  (p: perm)
  (va: Ghost.erased (Seq.seq U8.t))
  (res: cbor_read_t)
: Tot vprop
=   exists* v rem.
        raw_data_item_match 1.0R res.cbor_read_payload v **
        A.pts_to res.cbor_read_remainder #p rem **
        ((raw_data_item_match 1.0R res.cbor_read_payload v ** A.pts_to res.cbor_read_remainder #p rem) @==>
        A.pts_to a #p va) **
        pure (cbor_read_deterministically_encoded_with_typ_success_postcond t va res v rem)

let cbor_read_deterministically_encoded_with_typ_error_post
  (t: typ)
  (a: A.array U8.t)
  (p: perm)
  (va: Ghost.erased (Seq.seq U8.t))
: Tot vprop
= A.pts_to a #p va ** pure (cbor_read_deterministically_encoded_with_typ_error_postcond t va)

let cbor_read_deterministically_encoded_with_typ_post
  (t: typ)
  (a: A.array U8.t)
  (p: perm)
  (va: Ghost.erased (Seq.seq U8.t))
  (res: cbor_read_t)
: Tot vprop
= if res.cbor_read_is_success
  then cbor_read_deterministically_encoded_with_typ_success_post t a p va res
  else cbor_read_deterministically_encoded_with_typ_error_post t a p va

module SZ = FStar.SizeT

inline_for_extraction noextract [@@noextract_to "krml"]
```pulse
fn cbor_read_deterministically_encoded_with_typ
  (#t: typ)
  (ft: impl_typ t)
  (a: A.array U8.t)
  (sz: SZ.t)
  (#va: Ghost.erased (Seq.seq U8.t))
  (#p: perm)
requires
    (A.pts_to a #p va ** pure (
      (SZ.v sz == Seq.length va \/ SZ.v sz == A.length a)
    ))
returns res: cbor_read_t
ensures cbor_read_deterministically_encoded_with_typ_post t a p va res
{
    let res = cbor_read_deterministically_encoded a sz;
    if (res.cbor_read_is_success) {
        rewrite (cbor_read_deterministically_encoded_post a p va res) as (cbor_read_deterministically_encoded_success_post a p va res);
        unfold (cbor_read_deterministically_encoded_success_post a p va res);
        let test = ft res.cbor_read_payload;
        if (test) {
            fold (cbor_read_deterministically_encoded_with_typ_success_post t a p va res);
            fold (cbor_read_deterministically_encoded_with_typ_post t a p va res);
            res
        } else {
            with v . assert (raw_data_item_match 1.0R res.cbor_read_payload v);
            with vrem . assert (A.pts_to res.cbor_read_remainder #p vrem);
            cbor_read_deterministically_encoded_with_typ_error_postcond_intro_typ_fail t va res v vrem;
            elim_stick0 ()
                #(raw_data_item_match 1.0R res.cbor_read_payload v ** A.pts_to res.cbor_read_remainder #p vrem);
            let res = mk_cbor_read_error res;
            fold (cbor_read_deterministically_encoded_with_typ_error_post t a p va);
            fold (cbor_read_deterministically_encoded_with_typ_post t a p va res);
            res
        }
    } else {
        rewrite (cbor_read_deterministically_encoded_post a p va res) as (cbor_read_deterministically_encoded_error_post a p va);
        unfold (cbor_read_deterministically_encoded_error_post a p va);
        fold (cbor_read_deterministically_encoded_with_typ_error_post t a p va);
        fold (cbor_read_deterministically_encoded_with_typ_post t a p va res);
        res
    }
}
```

noextract
let cbor_map_get_with_typ_post_found
    (t: typ)
    (vkey: raw_data_item)
    (vmap: raw_data_item)
    (vvalue: raw_data_item)
: Tot prop
= Map? vmap /\
  list_ghost_assoc vkey (Map?.v vmap) == Some vvalue /\
  t vvalue == true


let cbor_map_get_with_typ_post
  (t: typ)
  (p: perm)
  (vkey: raw_data_item)
  (vmap: raw_data_item)
  (map: cbor)
  (res: cbor_map_get_t)
: Tot vprop
= match res with
  | NotFound ->
    raw_data_item_match p map vmap ** pure (
        Map? vmap /\
        begin match list_ghost_assoc vkey (Map?.v vmap) with
        | None -> True
        | Some v -> t v == false
        end
    )
  | Found value ->
    exists* vvalue.
        raw_data_item_match p value vvalue **
        (raw_data_item_match p value vvalue @==> raw_data_item_match p map vmap) **
        pure (cbor_map_get_with_typ_post_found t vkey vmap vvalue)

let cbor_map_get_post_eq_found
  (p: perm)
  (vkey: raw_data_item)
  (vmap: raw_data_item)
  (map: cbor)
  (res: cbor_map_get_t)
  (fres: cbor)
: Lemma
  (requires (res == Found fres))
  (ensures (
    cbor_map_get_post p vkey vmap map res ==
        cbor_map_get_post_found p vkey vmap map fres
  ))
= ()

```pulse
ghost
fn manurewrite
    (pre post: vprop)
requires
    pre ** pure (pre == post)
ensures
    post
{
    rewrite pre as post
}

```

```pulse
ghost
fn cbor_map_get_found_elim
  (p: perm)
  (vkey: Ghost.erased raw_data_item)
  (vmap: Ghost.erased raw_data_item)
  (map: cbor)
  (res: cbor_map_get_t)
  (fres: cbor)
requires
    cbor_map_get_post p vkey vmap map res **
    pure (res == Found fres)
ensures
    cbor_map_get_post_found p vkey vmap map fres
{
    manurewrite (cbor_map_get_post p vkey vmap map res) (cbor_map_get_post_found p vkey vmap map fres)
    // rewrite ... as ... fails: WHY WHY WHY??
}
```

inline_for_extraction noextract [@@noextract_to "krml"]
```pulse
fn cbor_map_get_with_typ
  (#t: typ)
  (ft: impl_typ t)
  (key: cbor)
  (map: cbor)
  (#pkey: perm)
  (#vkey: Ghost.erased raw_data_item)
  (#pmap: perm)
  (#vmap: Ghost.erased raw_data_item)
requires
    (raw_data_item_match pkey key vkey ** raw_data_item_match pmap map vmap ** pure (
      Map? vmap /\
      (~ (Tagged? vkey \/ Array? vkey \/ Map? vkey))
    ))
returns res: cbor_map_get_t
ensures
    (raw_data_item_match pkey key vkey ** cbor_map_get_with_typ_post t pmap vkey vmap map res ** pure (
      Map? vmap /\
      Found? res == begin match list_ghost_assoc (Ghost.reveal vkey) (Map?.v vmap) with
      | None -> false
      | Some v -> t v
      end
    ))
{
    let res = cbor_map_get key map;
    if (Found? res) {
        let fres = Found?._0 res;
        manurewrite (cbor_map_get_post pmap vkey vmap map res) (cbor_map_get_post_found pmap vkey vmap map fres);
        unfold (cbor_map_get_post_found pmap vkey vmap map fres);
        let test = ft fres;
        if (test) {
            fold (cbor_map_get_with_typ_post t pmap vkey vmap map (Found fres));
            res
        } else {
            elim_stick0 ();
            fold (cbor_map_get_with_typ_post t pmap vkey vmap map NotFound);
            NotFound
        }
    } else {
        rewrite (cbor_map_get_post pmap vkey vmap map res) as (cbor_map_get_post_not_found pmap vkey vmap map);
        unfold (cbor_map_get_post_not_found pmap vkey vmap map);
        fold (cbor_map_get_with_typ_post t pmap vkey vmap map NotFound);
        res
    }
}
```

inline_for_extraction noextract [@@noextract_to "krml"]
let impl_matches_map_group
    (#b: Ghost.erased (option raw_data_item))
    (g: map_group b)
=
    c: cbor ->
    (#p: perm) ->
    (#v: Ghost.erased raw_data_item) ->
    stt bool
        (
            raw_data_item_match p c v **
            pure (opt_precedes (Ghost.reveal v) b /\ Map? v)
        )
        (fun res -> 
            raw_data_item_match p c v **
            pure (opt_precedes (Ghost.reveal v) b /\ Map? v /\ res == matches_map_group g (Map?.v v))
        )

inline_for_extraction noextract [@@noextract_to "krml"]
```pulse
fn impl_t_map
    (#b: Ghost.erased (option raw_data_item))
    (#g: map_group b)
    (ig: (impl_matches_map_group (g)))
: impl_typ #b (t_map g)
=
    (c: cbor)
    (#p: perm)
    (#v: Ghost.erased raw_data_item)
{
    let ty = cbor_get_major_type c;
    if (ty = cbor_major_type_map) {
        ig c;
    } else {
        false
    }
}
```

inline_for_extraction noextract [@@noextract_to "krml"]
let impl_matches_map_entry_zero_or_more
    (#b: Ghost.erased (option raw_data_item))
    (g: map_group b)
=
    c: cbor_map_entry ->
    (#p: perm) ->
    (#v: Ghost.erased (raw_data_item & raw_data_item)) ->
    stt bool
        (
            raw_data_item_map_entry_match p c v **
            pure (opt_precedes (Ghost.reveal v) b)
        )
        (fun res -> 
            raw_data_item_map_entry_match p c v **
            pure (opt_precedes (Ghost.reveal v) b /\
            res == List.Tot.existsb (pull_rel matches_map_group_entry' (Ghost.reveal v)) g.zero_or_more)
        )

(* FIXME: WHY WHY WHY does this one not work?

inline_for_extraction noextract [@@noextract_to "krml"]
```pulse
fn impl_matches_map_entry_zero_or_more_nil
    (b: Ghost.erased (option raw_data_item))
: impl_matches_map_entry_zero_or_more #b map_group_empty
=
    (c: cbor_map_entry)
    (#p: perm)
    (#v: Ghost.erased (raw_data_item & raw_data_item))
{
    false
}
```

*)
inline_for_extraction noextract [@@noextract_to "krml"]
```pulse
fn impl_matches_map_entry_zero_or_more_nil'
    (b: Ghost.erased (option raw_data_item))
    (c: cbor_map_entry)
    (#p: perm)
    (#v: Ghost.erased (raw_data_item & raw_data_item))
requires
        (
            raw_data_item_map_entry_match p c v **
            pure (opt_precedes (Ghost.reveal v) b)
        )
returns res: bool
ensures
        (
            raw_data_item_map_entry_match p c v **
            pure (opt_precedes (Ghost.reveal v) b /\
            res == List.Tot.existsb (pull_rel matches_map_group_entry' (Ghost.reveal v)) (map_group_empty #b).zero_or_more)
        )
{
    false
}
```

inline_for_extraction noextract [@@noextract_to "krml"]
let impl_matches_map_entry_zero_or_more_nil
    (b: Ghost.erased (option raw_data_item))
: Tot (impl_matches_map_entry_zero_or_more (map_group_empty #b))
= impl_matches_map_entry_zero_or_more_nil' b

inline_for_extraction noextract [@@noextract_to "krml"]
```pulse
fn impl_matches_map_entry_zero_or_more_cons
    (#b: Ghost.erased (option raw_data_item))
    (e: map_group_entry b)
    (f_fst: impl_typ e.fst)
    (f_snd: impl_typ e.snd)
    (#g: map_group b)
    (f_g: impl_matches_map_entry_zero_or_more g)
: impl_matches_map_entry_zero_or_more #b (map_group_cons_zero_or_more e false g)
=
    (c: cbor_map_entry)
    (#p: perm)
    (#v: Ghost.erased (raw_data_item & raw_data_item))
{
    assert (pure (
        List.Tot.existsb (pull_rel matches_map_group_entry' (Ghost.reveal v)) (map_group_cons_zero_or_more e false g).zero_or_more == (
          matches_map_group_entry e (Ghost.reveal v) ||
          List.Tot.existsb (pull_rel matches_map_group_entry' (Ghost.reveal v)) g.zero_or_more
    )));
    unfold (raw_data_item_map_entry_match p c v);
    let test_fst = f_fst (cbor_map_entry_key c);
    if (test_fst) {
        let test_snd = f_snd (cbor_map_entry_value c);
        fold (raw_data_item_map_entry_match p c v);
        if (test_snd) {
            true
        } else {
            f_g c;
        }
    } else {
        fold (raw_data_item_map_entry_match p c v);
        f_g c;
    }
}
```

inline_for_extraction noextract [@@noextract_to "krml"]
```pulse
fn impl_matches_map_group_no_restricted
    (#b: Ghost.erased (option raw_data_item))
    (#g: map_group b)
    (ig: (impl_matches_map_entry_zero_or_more (g)))
    (h_ig: squash (
        (Nil? g.one /\ Nil? g.zero_or_one)
    ))
: impl_matches_map_group #b g
=
    (c: cbor)
    (#p: perm)
    (#v: Ghost.erased raw_data_item)
{
    let i0 = cbor_map_iterator_init c;
    let mut pi = i0;
    let mut pres = true;
    let done0 = cbor_map_iterator_is_done i0;
    let mut pcont = not done0;
    while (let cont = !pcont ; cont)
    invariant cont . exists* (i: cbor_map_iterator_t) (l: list (raw_data_item & raw_data_item)) (res: bool) . (
        pts_to pcont cont **
        pts_to pres res **
        pts_to pi i **
        cbor_map_iterator_match p i l **
        (cbor_map_iterator_match p i l @==> raw_data_item_match p c v) **
        pure (
            list_ghost_forall_exists matches_map_group_entry' (Map?.v v) g.zero_or_more ==
                (res && list_ghost_forall_exists matches_map_group_entry' l g.zero_or_more) /\
            opt_precedes l (Ghost.reveal b) /\
            cont == (res && Cons? l)
        )
    )
    {   
        let x = cbor_map_iterator_next pi;
        stick_trans ();
        let res = ig x;
        with vx gi l . assert (pts_to pi gi ** raw_data_item_map_entry_match p x vx ** cbor_map_iterator_match p gi l ** ((raw_data_item_map_entry_match p x vx ** cbor_map_iterator_match p gi l) @==> raw_data_item_match p c v)) ;
        stick_consume_l ()
            #(raw_data_item_map_entry_match p x vx)
            #(cbor_map_iterator_match p gi l);
        pres := res;
        if (res) {
            let i = !pi;
            rewrite each gi as i; // FIXME: HOW HOW HOW to do that once the issue with the use of stick_consume_l above is solved and the `with` above is removed?
            let done = cbor_map_iterator_is_done i;
            pcont := not done;
        } else {
            pcont := false;
        }
    };
    elim_stick0 ();
    !pres
}
```

inline_for_extraction noextract [@@noextract_to "krml"]
let impl_parse
    (#source: typ)
    (#target: Type)
    (#target_prop: target -> prop)
    (parse: parser_spec source target target_prop)
    (#impl: Type)
    (r: impl -> target -> vprop)
: Type
= 
    (c: cbor) ->
    (#p: perm) ->
    (#v: Ghost.erased raw_data_item) ->
    stt impl
    (raw_data_item_match p c v **
        pure (source v)
    )
    (fun w -> exists* x .
        raw_data_item_match p c v **
        r w x **
        pure (source v /\
            parse v == x
        )
    )

let cbor_read_with_parser_success_postcond
  (#source: typ)
  (#target: Type)
  (#target_prop: target -> prop)
  (parse: parser_spec source target target_prop)
  (va: Ghost.erased (Seq.seq U8.t))
  (w: target)
: Tot prop
= exists c v rem .
    cbor_read_with_typ_success_postcond source va c v rem /\
    parse v == w

let cbor_parse_object_success_post
  (#source: typ)
  (#target: Type)
  (#target_prop: target -> prop)
  (parse: parser_spec source target target_prop)
  (#impl: Type)
  (r: impl -> target -> vprop)
  (va: Ghost.erased (Seq.seq U8.t))
  (c: impl)
: Tot vprop
= exists* v .
    r c v **
    pure (cbor_read_with_parser_success_postcond parse va v)

let cbor_parse_object_error_post
  (t: typ)
  (va: Ghost.erased (Seq.seq U8.t))
: Tot vprop
= pure (cbor_read_with_typ_error_postcond t va)

let cbor_parse_object_post
  (#source: typ)
  (#target: Type)
  (#target_prop: target -> prop)
  (parse: parser_spec source target target_prop)
  (#impl: Type)
  (r: impl -> target -> vprop)
  (va: Ghost.erased (Seq.seq U8.t))
  (res: option impl)
: Tot vprop
= match res with
  | Some w -> cbor_parse_object_success_post parse r va w
  | None -> cbor_parse_object_error_post source va

inline_for_extraction noextract [@@noextract_to "krml"]
```pulse
fn cbor_parse_object
  (#source: typ)
  (ft: impl_typ source)
  (#target: Type)
  (#target_prop: target -> prop)
  (#parse: parser_spec source target target_prop)
  (#impl: Type0)
  (#r: impl -> target -> vprop)
  (ip: impl_parse parse r)
  (a: A.array U8.t)
  (sz: SZ.t)
  (#va: Ghost.erased (Seq.seq U8.t))
  (#p: perm)
requires
    (A.pts_to a #p va ** pure (
      (SZ.v sz == Seq.length va \/ SZ.v sz == A.length a)
    ))
returns res: option impl
ensures
    A.pts_to a #p va **
    cbor_parse_object_post parse r va res
{
    let tmp = cbor_read_with_typ ft a sz;
    if (tmp.cbor_read_is_success) {
        rewrite (cbor_read_with_typ_post source a p va tmp) as (cbor_read_with_typ_success_post source a p va tmp);
        unfold (cbor_read_with_typ_success_post source a p va tmp);
        let w = ip tmp.cbor_read_payload;
        elim_stick0 ();
        let res = Some w;
        fold (cbor_parse_object_success_post parse r va w);
        rewrite (cbor_parse_object_success_post parse r va w) as (cbor_parse_object_post parse r va res);
        res
    } else {
        rewrite (cbor_read_with_typ_post source a p va tmp) as (cbor_read_with_typ_error_post source a p va);
        unfold (cbor_read_with_typ_error_post source a p va);
        fold (cbor_parse_object_error_post source va);
        rewrite (cbor_parse_object_error_post source va) as (cbor_parse_object_post parse r va None);
        None #impl
    }
}
```

// Right-to-left serialization

let impl_serialize_post
  (#source: typ)
  (#target: Type)
  (#target_prop: target -> prop)
  (#parse: parser_spec source target target_prop)
  (serialize: serializer_spec parse)
  (pos: SZ.t)
  (x: target)
  (va' : Seq.seq U8.t)
  (res: SZ.t)
: Tot prop
= SZ.v pos <= Seq.length va' /\
  (SZ.v res < SZ.v pos <==> (
    target_prop x /\
    Seq.length (serialize_cbor (serialize x)) <= SZ.v pos
  )) /\
  (SZ.v res < SZ.v pos ==>
    Seq.slice va' (SZ.v res) (SZ.v pos) == serialize_cbor (serialize x)
  )

inline_for_extraction noextract [@@noextract_to "krml"]
let impl_serialize
  (#source: typ)
  (#target: Type)
  (#target_prop: target -> prop)
  (#parse: parser_spec source target target_prop)
  (serialize: serializer_spec parse)
  (#impl: Type0)
  (r: impl -> target -> vprop)
: Type
= (a: A.array U8.t) ->
  (pos: SZ.t) ->
  (x: impl) ->
  (#v: Ghost.erased target) ->
  (#va: Ghost.erased (Seq.seq U8.t)) ->
  stt SZ.t
    (A.pts_to a va ** r x v ** pure (
      (SZ.v pos < A.length a)
    ))
    (fun res -> exists* va' .
        r x v **
        A.pts_to a va' ** pure (impl_serialize_post serialize pos v va' res)
    )
