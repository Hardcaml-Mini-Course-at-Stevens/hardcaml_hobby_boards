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
  let adder_out = June17.Adder.hierarchical scope {a=switches.:[7,0]; b=switches.:[15,8]} in
  let sum = reg spec (uresize ~width:16 (adder_out.sum)) in
  Leds.complete board (sum);
  board
;;
