open! Core
open! Hardcaml
open! Hardcaml_waveterm
open June17
open Adder
module Sim = Cyclesim.With_interface (I) (O)
(* let%expect_test "test1+1" = print_endline "hello";
  [%expect {| hello |}] *)
let test () = 
  let scope = Scope.create ~flatten_design:true ~auto_label_hierarchical_ports:true () in
  let sim = Sim.create (hierarchical scope) in
  let waves, sim = Hardcaml_waveterm_cyclesim.Waveform.create sim in
  let i=Cyclesim.inputs sim in
  let o=Cyclesim.outputs sim in
  i.a := Bits.of_unsigned_int ~width:8 20;
  i.b := Bits.of_unsigned_int ~width:8 40;
  Cyclesim.cycle sim;
  i.a := Bits.of_unsigned_int ~width:8 10;
  i.b := Bits.of_unsigned_int ~width:8 30;
  Cyclesim.cycle sim;
  i.a := Bits.of_unsigned_int ~width:8 5;
  i.b := Bits.of_unsigned_int ~width:8 45;
  Cyclesim.cycle sim;
  let sum = Bits.to_unsigned_int !(o.sum) in
  print_s [%message "" (sum:int) (!(o.sum):Bits.Hex.t)];
  assert (sum=50);
  waves
let%expect_test "Test simple adder" = let waves = test () in
  
  Waveform.expect_exact waves ~wave_width:2;
  [%expect_exact {|((sum 50) ("!(o.sum)" 8'h32))

┌Signals───────────┐┌Waves───────────────────────────────────────────────────────────────┐
│                  ││──────┬─────┬─────                                                  │
│a                 ││ 14   │0A   │05                                                     │
│                  ││──────┴─────┴─────                                                  │
│                  ││──────┬─────┬─────                                                  │
│b                 ││ 28   │1E   │2D                                                     │
│                  ││──────┴─────┴─────                                                  │
│                  ││──────┬─────┬─────                                                  │
│sum               ││ 3C   │28   │32                                                     │
│                  ││──────┴─────┴─────                                                  │
└──────────────────┘└────────────────────────────────────────────────────────────────────┘
dda2b9c0008687aa8e6e80cee99f10d5
|}]