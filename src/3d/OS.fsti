module OS

val dirname : string -> Tot string

(* The filename without its path *)

val basename : string -> Tot string

val concat : string -> string -> Tot string

(* The filename without its extension *)

val remove_extension: string -> Tot string

(* The extension of the filename, including its leading . *)

val extension: string -> Tot string


val file_exists: string -> FStar.All.ML bool

val file_contents: string -> FStar.All.ML string
