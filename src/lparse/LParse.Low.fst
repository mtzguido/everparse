module LParse.Low
include LParse.Low.Base
include LParse.Low.Combinators
include LParse.Low.Int
include LParse.Low.List
include LParse.Low.FLData
include LParse.Low.Array
include LParse.Low.Bytes
include LParse.Low.VLData
include LParse.Low.Enum
include LParse.Low.Option
include LParse.Low.Sum
include LParse.Low.Tac.Sum
include LParse.Low.IfThenElse
include LParse.Low.VCList
include LParse.Low.BCVLI
include LParse.Low.DER
include LParse.Low.VLGen

let inversion_tuple2 (a b: Type) : Lemma (inversion (tuple2 a b)) [SMTPat (tuple2 a b)] = allow_inversion (tuple2 a b)
