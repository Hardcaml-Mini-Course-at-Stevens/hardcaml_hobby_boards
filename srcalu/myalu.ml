(* open! Core
open Hardcaml
open Signal
let alu ~op ~a ~b =
  mux
    op
    ([ a +: b
     ; a -: b
     ; a *: b
     ; sll a ~by:1
     ; srl a ~by:1
     ; a &: b
     ; a |: b
     ; a ^: b
     ; ~:a
     ; a <: b
     ; a ==: b
     ; zero 6
     ]
     |> List.map ~f:(uresize ~width:6))
;; *)

open! Core
open Hardcaml
open Signal
module I = struct
  type 'a t = {
    op: 'a [@bits 4];
    a: 'a [@bits 6];
    b: 'a [@bits 6]
  }
  [@@deriving hardcaml ~rtlmangle:"$"]
end
module O = struct
  type 'a t = {
    result: 'a [@bits 6]
  }
  [@@deriving hardcaml ~rtlmangle:"$"]
end
let create _scope (i:Signal.t I.t) : Signal.t O.t = {result = mux
    i.op
    ([ i.a +: i.b
     ; i.a -: i.b
     ; i.a *: i.b
     ; sll i.a ~by:1
     ; srl i.a ~by:1
     ; i.a &: i.b
     ; i.a |: i.b
     ; i.a ^: i.b
     ; ~:(i.a)
     ; i.a <: i.b
     ; i.a ==: i.b
     ; zero 6
     ]
     |> List.map ~f:(uresize ~width:6))}
let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~name:"alu" ~scope create
;;