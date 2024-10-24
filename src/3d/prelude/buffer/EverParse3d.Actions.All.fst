module EverParse3d.Actions.All
friend EverParse3d.Actions.Base
friend EverParse3d.InputStream.All
friend EverParse3d.InputStream.Buffer

let _ = EverParse3d.Actions.BackendFlagValue.backend_flag_value

module IB = EverParse3d.InputBuffer
module P = EverParse3d.Prelude

let ___PUINT8 = IB.puint8

let action_field_ptr
      #nz #wk (#k:P.parser_kind nz wk) (#t:Type) (#p:P.parser k t) (u:unit)
   = fun ctxt input startPosition _ ->
       let open LowParse.Slice in
       IB.offset input.EverParse3d.InputStream.Buffer.Aux.buf (LowParse.Low.ErrorCode.uint64_to_uint32 startPosition) input.EverParse3d.InputStream.Buffer.Aux.perm_of

let action_field_ptr_after
      #nz #wk (#k:P.parser_kind nz wk) (#t:Type) (#p:P.parser k t) n
   = false_elim ()

let action_field_ptr_after_with_setter _ = false_elim ()

let action_field_pos_32
      #nz #wk (#k:P.parser_kind nz wk) (#t:Type) (#p:P.parser k t) (u:unit)
   = fun ctxt input startPosition _ ->
       [@inline_let]
       let res = LowParse.Low.ErrorCode.uint64_to_uint32 startPosition in
       assert (FStar.UInt32.v res == FStar.UInt64.v startPosition); // sanity-check: no modulo here
       res
