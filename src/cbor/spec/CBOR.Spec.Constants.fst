module CBOR.Spec.Constants

module U8 = FStar.UInt8

inline_for_extraction
noextract
let major_type_t : eqtype = (x: U8.t { U8.v x < pow2 3 })

[@@CMacro]
let cbor_major_type_simple_value : major_type_t = 7uy

[@@CMacro]
let cbor_major_type_uint64 : major_type_t = 0uy

[@@CMacro]
let cbor_major_type_neg_int64 : major_type_t = 1uy

inline_for_extraction
noextract
let major_type_uint64_or_neg_int64 : eqtype = (x: major_type_t { x == cbor_major_type_uint64 \/ x == cbor_major_type_neg_int64 })

[@@CMacro]
let cbor_major_type_byte_string : major_type_t = 2uy

[@@CMacro]
let cbor_major_type_text_string : major_type_t = 3uy

inline_for_extraction
noextract
let major_type_byte_string_or_text_string : eqtype = (x: major_type_t { x == cbor_major_type_byte_string \/ x == cbor_major_type_text_string })

[@@CMacro]
let cbor_major_type_array : major_type_t = 4uy

[@@CMacro]
let cbor_major_type_map : major_type_t = 5uy

[@@CMacro]
let cbor_major_type_tagged : major_type_t = 6uy

(* Simple values *)

[@@CMacro]
let min_simple_value_long_argument = 32uy

[@@CMacro]
let max_simple_value_additional_info = 23uy

inline_for_extraction
noextract
let simple_value_wf
  (x: U8.t)
: Tot bool
= x `U8.lte` max_simple_value_additional_info || min_simple_value_long_argument `U8.lte` x

inline_for_extraction
noextract
let simple_value : eqtype =
  (x: U8.t { simple_value_wf x == true } )
