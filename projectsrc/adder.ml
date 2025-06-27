open! Core
open Hardcaml
open Signal
module I = struct
  type 'a t = {
    a: 'a [@bits 8];
    b: 'a [@bits 8]
  }
  [@@deriving hardcaml ~rtlmangle:"$"]
end
module O = struct
  type 'a t = {
    sum: 'a [@bits 8]
  }
  [@@deriving hardcaml ~rtlmangle:"$"]
end
let create _scope (i:Signal.t I.t) : Signal.t O.t = {sum = i.a +: i.b}
let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~name:"adder" ~scope create
;;