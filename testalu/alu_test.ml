open! Core
open! Hardcaml
open! Hardcaml_waveterm
open Myalu
(* open Alu *)
module Sim = Cyclesim.With_interface (I) (O)
let test () =
  let scope = Scope.create ~flatten_design:true ~auto_label_hierarchical_ports:true () in
  let sim = Sim.create (hierarchical scope) in
  let waves, sim = Hardcaml_waveterm_cyclesim.Waveform.create sim in
  let i=Cyclesim.inputs sim in
  let o=Cyclesim.outputs sim in
  i.op := Bits.of_unsigned_int ~width:4 1;
  i.a := Bits.of_unsigned_int ~width:6 1;
  i.b := Bits.of_unsigned_int ~width:6 2;
  Cyclesim.cycle sim;
  i.op := Bits.of_unsigned_int ~width:4 2;
  i.a := Bits.of_unsigned_int ~width:6 2;
  i.b := Bits.of_unsigned_int ~width:6 4;
  Cyclesim.cycle sim;
let result = Bits.to_unsigned_int !(o.result) in
print_s [%message "" (result:int) (!(o.result):Bits.Hex.t)];
assert (result = 8);
waves
let%expect_test "Test ALU" = let waves = test () in
  Waveform.expect_exact waves ~wave_width:2;
  [%expect_exact {|((result 8) ("!(o.result)" 6'h08))

┌Signals───────────┐┌Waves───────────────────────────────────────────────────────────────┐
│                  ││──────┬─────                                                        │
│a                 ││ 01   │02                                                           │
│                  ││──────┴─────                                                        │
│                  ││──────┬─────                                                        │
│b                 ││ 02   │04                                                           │
│                  ││──────┴─────                                                        │
│                  ││──────┬─────                                                        │
│op                ││ 1    │2                                                            │
│                  ││──────┴─────                                                        │
│                  ││──────┬─────                                                        │
│result            ││ 3F   │08                                                           │
│                  ││──────┴─────                                                        │
└──────────────────┘└────────────────────────────────────────────────────────────────────┘
19a496a53c8ae06ed18df9f144f659c2
|}]