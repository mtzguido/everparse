module LParse.Tot.List
include LParse.Spec.List
include LParse.Tot.Combinators

inline_for_extraction
let parse_list #k #t = tot_parse_list #k #t

