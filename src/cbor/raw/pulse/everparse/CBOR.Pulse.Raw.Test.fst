module CBOR.Pulse.Raw.Test
open LowParse.Spec.Base
open CBOR.Spec.Raw.Format
open CBOR.Pulse.Raw.Format
open LowParse.Pulse.Util
open LowParse.Pulse.Base
open Pulse.Lib.Slice
module SZ = FStar.SizeT

```pulse
fn test (#pm: perm) (#v: Ghost.erased bytes) (s: slice byte)
  requires pts_to s #pm v ** pure (exists off . validator_success test_parse 0sz v off)
  returns _: SZ.t
  ensures pts_to s #pm v
{
  test_jump s 0sz
}
```

```pulse
fn test1 (#pm: perm) (#v: Ghost.erased bytes) (s: slice byte)
  requires pts_to s #pm v
  returns _: SZ.t
  ensures pts_to s #pm v
{
  validate_nonempty (validate_header ()) s 0sz
//  validate_nonempty (validate_initial_byte) s 0sz
}
```

```pulse
fn test2 (#pm: perm) (#v: Ghost.erased initial_byte) (s: slice byte)
  requires pts_to_serialized serialize_initial_byte s  #pm v
  returns _: major_type_t
  ensures pts_to_serialized serialize_initial_byte s #pm v
{
  let x = leaf_reader_of_reader read_initial_byte s;
  x.major_type
}
```

```pulse
fn test3 (#pm: perm) (#v: Ghost.erased header) (s: slice byte)
  requires pts_to_serialized serialize_header s  #pm v
  returns _: major_type_t
  ensures pts_to_serialized serialize_header s #pm v
{
  let x = read_header () s;
  (dfst x).major_type
}
```
