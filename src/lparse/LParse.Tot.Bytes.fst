module LParse.Tot.Bytes
include LParse.Spec.Bytes
include LParse.Tot.Combinators
include LParse.Tot.Int

inline_for_extraction
let parse_all_bytes = tot_parse_all_bytes
