module CBOR.Pulse.Raw.Read
include CBOR.Pulse.Raw.Match
open CBOR.Pulse.Raw.Iterator
open CBOR.Pulse.Raw.Format.Serialized
open CBOR.Spec.Raw.Base
open Pulse.Lib.Pervasives
open Pulse.Lib.Trade

module PM = Pulse.Lib.SeqMatch.Util
module S = Pulse.Lib.Slice
module R = Pulse.Lib.Reference
module SZ = FStar.SizeT
module U64 = FStar.UInt64
module Trade = Pulse.Lib.Trade.Util

```pulse
fn cbor_match_tagged_get_payload
  (c: cbor_raw)
  (#pm: perm)
  (#r: Ghost.erased raw_data_item { Tagged? r })
  requires cbor_match pm c r
  returns res: cbor_raw
  ensures exists* pm' .
    cbor_match pm' res (Tagged?.v r) **
    trade
      (cbor_match pm' res (Tagged?.v r))
      (cbor_match pm c r)
{
  cbor_match_cases c;
  match c {
    CBOR_Case_Serialized_Tagged cs -> {
      Trade.rewrite_with_trade
        (cbor_match pm c r)
        (cbor_match_serialized_tagged cs pm r);
      let res = cbor_match_serialized_tagged_get_payload cs;
      Trade.trans _ _ (cbor_match pm c r);
      res
    }
    CBOR_Case_Tagged ct -> {
      cbor_match_eq_tagged pm ct r;
      Trade.rewrite_with_trade
        (cbor_match pm c r)
        (cbor_match_tagged ct pm r cbor_match);
      cbor_match_tagged_elim ct pm r;
      Trade.trans _ _ (cbor_match pm c r);
      let res = !ct.cbor_tagged_ptr;
      Trade.elim_hyp_l _ _ (cbor_match pm c r);
      res
    }
  }
}
```

```pulse
ghost
fn cbor_match_array_elim
  (c: cbor_array)
  (p: perm)
  (r: raw_data_item { Array? r })
  requires
    cbor_match_array c p r cbor_match
  ensures exists* s . 
    pts_to c.cbor_array_ptr #(p `perm_mul` c.cbor_array_array_perm) s **
    PM.seq_list_match s (Array?.v r) (cbor_match (p `perm_mul` c.cbor_array_payload_perm)) **
    trade
      (pts_to c.cbor_array_ptr #(p `perm_mul` c.cbor_array_array_perm) s **
        PM.seq_list_match s (Array?.v r) (cbor_match (p `perm_mul` c.cbor_array_payload_perm)))
      (cbor_match_array c p r cbor_match) **
    pure (c.cbor_array_length_size == (Array?.len r).size /\
      SZ.v (S.len c.cbor_array_ptr) == U64.v (Array?.len r).value
    )
{
  unfold (cbor_match_array c p r cbor_match);
  with s . assert (pts_to c.cbor_array_ptr #(p `perm_mul` c.cbor_array_array_perm) s);
  ghost
  fn aux (_: unit)
    requires emp ** (pts_to c.cbor_array_ptr #(p `perm_mul` c.cbor_array_array_perm) s **
        PM.seq_list_match s (Array?.v r) (cbor_match (p `perm_mul` c.cbor_array_payload_perm)))
    ensures cbor_match_array c p r cbor_match
  {
    fold (cbor_match_array c p r cbor_match)
  };
  Trade.intro _ _ _ aux
}
```

```pulse
fn cbor_array_item
  (fits: squash (SZ.fits_u64))
  (c: cbor_raw)
  (i: U64.t)
  (#pm: perm)
  (#r: Ghost.erased raw_data_item { Array? r })
requires
    (cbor_match pm c r **
      pure (U64.v i < List.Tot.length (Array?.v r))
    )
returns res: cbor_raw
ensures exists* p' y .
      cbor_match p' res y **
      trade
        (cbor_match p' res y)
        (cbor_match pm c r) **
      pure (
        U64.v i < List.Tot.length (Array?.v r) /\
        List.Tot.index (Array?.v r) (U64.v i) == y
      )
{
  cbor_match_cases c;
  match c {
    CBOR_Case_Serialized_Array c' -> {
      Trade.rewrite_with_trade
        (cbor_match pm c r)
        (cbor_match_serialized_array c' pm r);
      let res = cbor_serialized_array_item c' i;
      Trade.trans _ _ (cbor_match pm c r);
      res
    }
    CBOR_Case_Array c' -> { 
      assert_norm (cbor_match pm (CBOR_Case_Array c') (Array (Array?.len r) (Array?.v r)) ==
        cbor_match_array c' pm (Array (Array?.len r) (Array?.v r)) cbor_match
      );
      Trade.rewrite_with_trade
        (cbor_match pm c r)
        (cbor_match_array c' pm r cbor_match);
      cbor_match_array_elim c' pm r;
      Trade.trans _ _ (cbor_match pm c r);
      S.pts_to_len c'.cbor_array_ptr;
      PM.seq_list_match_length (cbor_match (pm `perm_mul` c'.cbor_array_payload_perm)) _ _;
      let res = S.op_Array_Access c'.cbor_array_ptr (SZ.uint64_to_sizet i);
      Trade.elim_hyp_l _ _ (cbor_match pm c r);
      PM.seq_list_match_index_trade (cbor_match (pm `perm_mul` c'.cbor_array_payload_perm)) _ _ (U64.v i);
      Trade.trans _ _ (cbor_match pm c r);
      res
    }
  }
}
```

let cbor_array_iterator_match
= cbor_raw_iterator_match
    cbor_match
    cbor_serialized_array_iterator_match

```pulse
fn cbor_array_iterator_init
  (fits: squash (SZ.fits_u64))
  (c: cbor_raw)
  (#pm: perm)
  (#r: Ghost.erased raw_data_item { Array? r })
requires
    (cbor_match pm c r)
returns res: cbor_array_iterator
ensures exists* p .
      cbor_array_iterator_match p res (Array?.v r) **
      trade
        (cbor_array_iterator_match p res (Array?.v r))
        (cbor_match pm c r)
{
  cbor_match_cases c;
  match c {
    CBOR_Case_Serialized_Array c' -> {
      Trade.rewrite_with_trade
        (cbor_match pm c r)
        (cbor_match_serialized_array c' pm r);
      let i' = cbor_serialized_array_iterator_init c';
      with p . assert (cbor_serialized_array_iterator_match p i' (Array?.v r));
      Trade.trans
        (cbor_serialized_array_iterator_match p i' (Array?.v r))
        (cbor_match_serialized_array c' pm r)
        (cbor_match pm c r);
      let i : cbor_array_iterator = CBOR_Raw_Iterator_Serialized i';
      Trade.rewrite_with_trade
        (cbor_serialized_array_iterator_match p i' (Array?.v r))
        (cbor_array_iterator_match p i (Array?.v r));
      Trade.trans
        (cbor_array_iterator_match p i (Array?.v r))
        (cbor_serialized_array_iterator_match p i' (Array?.v r))
        (cbor_match pm c r);
      i
    }
    CBOR_Case_Array c' -> {
      assert_norm (cbor_match pm (CBOR_Case_Array c') (Array (Array?.len r) (Array?.v r)) ==
        cbor_match_array c' pm (Array (Array?.len r) (Array?.v r)) cbor_match
      );
      Trade.rewrite_with_trade
        (cbor_match pm c r)
        (cbor_match_array c' pm r cbor_match);
      cbor_match_array_elim c' pm r;
      with s . assert (pts_to c'.cbor_array_ptr #(pm `perm_mul` c'.cbor_array_array_perm) s);
      Trade.trans
        (pts_to c'.cbor_array_ptr #(pm `perm_mul` c'.cbor_array_array_perm) s **
          PM.seq_list_match s (Array?.v r) (cbor_match (pm `perm_mul` c'.cbor_array_payload_perm)))
        (cbor_match_array c' pm r cbor_match)
        (cbor_match pm c r);
      let res = cbor_raw_iterator_init_from_slice cbor_match cbor_serialized_array_iterator_match c'.cbor_array_ptr;
      Trade.trans _ _ (cbor_match pm c r);
      with p . assert (cbor_raw_iterator_match cbor_match cbor_serialized_array_iterator_match p res (Array?.v r));
      fold (cbor_array_iterator_match p res (Array?.v r));
      res
    }
  }
}
```

```pulse
fn cbor_array_iterator_is_empty
  (c: cbor_array_iterator)
  (#pm: perm)
  (#r: Ghost.erased (list raw_data_item))
requires
    cbor_array_iterator_match pm c r
returns res: bool
ensures
    cbor_array_iterator_match pm c r **
    pure (res == Nil? r)
{
  unfold (cbor_array_iterator_match pm c r);
  let res = cbor_raw_iterator_is_empty
    cbor_match
    cbor_serialized_array_iterator_match
    cbor_serialized_array_iterator_is_empty
    c;
  fold (cbor_array_iterator_match pm c r);
  res
}
```

```pulse
fn cbor_array_iterator_next
  (sq: squash SZ.fits_u64)
  (pi: R.ref cbor_array_iterator)
  (#pm: perm)
  (#i: Ghost.erased cbor_array_iterator)
  (#l: Ghost.erased (list raw_data_item))
requires
    R.pts_to pi i **
    cbor_array_iterator_match pm i l **
    pure (Cons? l)
returns res: cbor_raw
ensures exists* a p i' q .
    cbor_match p res a **
    R.pts_to pi i' **
    cbor_array_iterator_match pm i' q **
    trade
      (cbor_match p res a ** cbor_array_iterator_match pm i' q)
      (cbor_array_iterator_match pm i l) **
    pure (Ghost.reveal l == a :: q)
{
  unfold (cbor_array_iterator_match pm i l);
  let res = cbor_raw_iterator_next
    cbor_match
    cbor_serialized_array_iterator_match
    (cbor_serialized_array_iterator_next sq)
    pi;
  with i' . assert (R.pts_to pi i');
  fold (cbor_array_iterator_match pm i' (List.Tot.tl l));
  res
}
```

```pulse
ghost
fn cbor_match_map_elim
  (c: cbor_map)
  (p: perm)
  (r: raw_data_item { Map? r })
  requires
    cbor_match_map p c r
  ensures exists* s . 
    pts_to c.cbor_map_ptr #(p `perm_mul` c.cbor_map_array_perm) s **
    PM.seq_list_match s (Map?.v r) (cbor_match_map_entry (p `perm_mul` c.cbor_map_payload_perm)) **
    trade
      (pts_to c.cbor_map_ptr #(p `perm_mul` c.cbor_map_array_perm) s **
        PM.seq_list_match s (Map?.v r) (cbor_match_map_entry (p `perm_mul` c.cbor_map_payload_perm)))
      (cbor_match_map p c r) **
    pure (c.cbor_map_length_size == (Map?.len r).size /\
      SZ.v (S.len c.cbor_map_ptr) == U64.v (Map?.len r).value
    )
{
  unfold (cbor_match_map p c r);
  with s . assert (pts_to c.cbor_map_ptr #(p `perm_mul` c.cbor_map_array_perm) s);
  ghost
  fn aux (_: unit)
    requires emp ** (pts_to c.cbor_map_ptr #(p `perm_mul` c.cbor_map_array_perm) s **
        PM.seq_list_match s (Map?.v r) (cbor_match_map_entry (p `perm_mul` c.cbor_map_payload_perm)))
    ensures cbor_match_map p c r
  {
    fold (cbor_match_map p c r)
  };
  Trade.intro _ _ _ aux
}
```

let cbor_map_iterator_match
= cbor_raw_iterator_match
    cbor_match_map_entry
    cbor_serialized_map_iterator_match

```pulse
fn cbor_map_iterator_init
  (fits: squash (SZ.fits_u64))
  (c: cbor_raw)
  (#pm: perm)
  (#r: Ghost.erased raw_data_item { Map? r })
requires
    (cbor_match pm c r)
returns res: cbor_map_iterator
ensures exists* p .
      cbor_map_iterator_match p res (Map?.v r) **
      trade
        (cbor_map_iterator_match p res (Map?.v r))
        (cbor_match pm c r)
{
  cbor_match_cases c;
  match c {
    CBOR_Case_Serialized_Map c' -> {
      Trade.rewrite_with_trade
        (cbor_match pm c r)
        (cbor_match_serialized_map c' pm r);
      let i' = cbor_serialized_map_iterator_init c';
      with p . assert (cbor_serialized_map_iterator_match p i' (Map?.v r));
      Trade.trans
        (cbor_serialized_map_iterator_match p i' (Map?.v r))
        (cbor_match_serialized_map c' pm r)
        (cbor_match pm c r);
      let i : cbor_map_iterator = CBOR_Raw_Iterator_Serialized i';
      Trade.rewrite_with_trade
        (cbor_serialized_map_iterator_match p i' (Map?.v r))
        (cbor_map_iterator_match p i (Map?.v r));
      Trade.trans
        (cbor_map_iterator_match p i (Map?.v r))
        (cbor_serialized_map_iterator_match p i' (Map?.v r))
        (cbor_match pm c r);
      i
    }
    CBOR_Case_Map c' -> {
      assert_norm (cbor_match pm (CBOR_Case_Map c') (Map (Map?.len r) (Map?.v r)) ==
        cbor_match_map0 c' pm (Map (Map?.len r) (Map?.v r)) cbor_match
      );
      Trade.rewrite_with_trade
        (cbor_match pm c r)
        (cbor_match_map0 c' pm r cbor_match);
      cbor_match_map0_map_trade c' pm r;
      Trade.trans _ _ (cbor_match pm c r);
      cbor_match_map_elim c' pm r;
      with s . assert (pts_to c'.cbor_map_ptr #(pm `perm_mul` c'.cbor_map_array_perm) s);
      Trade.trans
        (pts_to c'.cbor_map_ptr #(pm `perm_mul` c'.cbor_map_array_perm) s **
          PM.seq_list_match s (Map?.v r) (cbor_match_map_entry (pm `perm_mul` c'.cbor_map_payload_perm)))
        (cbor_match_map pm c' r)
        (cbor_match pm c r);
      let res = cbor_raw_iterator_init_from_slice cbor_match_map_entry cbor_serialized_map_iterator_match c'.cbor_map_ptr;
      Trade.trans _ _ (cbor_match pm c r);
      with p . assert (cbor_raw_iterator_match cbor_match_map_entry cbor_serialized_map_iterator_match p res (Map?.v r));
      fold (cbor_map_iterator_match p res (Map?.v r));
      res
    }
  }
}
```

```pulse
fn cbor_map_iterator_is_empty
  (c: cbor_map_iterator)
  (#pm: perm)
  (#r: Ghost.erased (list (raw_data_item & raw_data_item)))
requires
    cbor_map_iterator_match pm c r
returns res: bool
ensures
    cbor_map_iterator_match pm c r **
    pure (res == Nil? r)
{
  unfold (cbor_map_iterator_match pm c r);
  let res = cbor_raw_iterator_is_empty
    cbor_match_map_entry
    cbor_serialized_map_iterator_match
    cbor_serialized_map_iterator_is_empty
    c;
  fold (cbor_map_iterator_match pm c r);
  res
}
```

```pulse
fn cbor_map_iterator_next
  (sq: squash SZ.fits_u64)
  (pi: R.ref cbor_map_iterator)
  (#pm: perm)
  (#i: Ghost.erased cbor_map_iterator)
  (#l: Ghost.erased (list (raw_data_item & raw_data_item)))
requires
    R.pts_to pi i **
    cbor_map_iterator_match pm i l **
    pure (Cons? l)
returns res: cbor_map_entry
ensures exists* a p i' q .
    cbor_match_map_entry p res a **
    R.pts_to pi i' **
    cbor_map_iterator_match pm i' q **
    trade
      (cbor_match_map_entry p res a ** cbor_map_iterator_match pm i' q)
      (cbor_map_iterator_match pm i l) **
    pure (Ghost.reveal l == a :: q)
{
  unfold (cbor_map_iterator_match pm i l);
  let res = cbor_raw_iterator_next
    cbor_match_map_entry
    cbor_serialized_map_iterator_match
    (cbor_serialized_map_iterator_next sq)
    pi;
  with i' . assert (R.pts_to pi i');
  fold (cbor_map_iterator_match pm i' (List.Tot.tl l));
  res
}
```
