open! Core
open Hardcaml
open Signal

include struct
  open Hardcaml_hobby_boards
  module Board = Board
  module Utils = Utils
  include Nexys_a7_100t
end

let create () =
  let board = Board.create () in
  let spec = Utils.sync_reg_spec (Clock_and_reset.create board) in
  let switches = Switches.create board in
  let scope = Board.scope board in
  let alu_out = Myalu.hierarchical scope {op=switches.:[3,0]; a=switches.:[9,4]; b=switches.:[15,10]} in
  let result = reg spec (uresize ~width:16 (alu_out.result)) in
  Leds.complete board (result);
  board
;;
