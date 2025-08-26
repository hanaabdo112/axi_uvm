package axi4_sequencer_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"
import axi4_sequence_item_pkg::*;

class axi4_sequencer #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 16,
    parameter MEMORY_DEPTH = 1024
    ) extends uvm_sequencer #(axi4_sequence_item#(DATA_WIDTH, ADDR_WIDTH, MEMORY_DEPTH));
    
    `uvm_component_utils(axi4_sequencer#(DATA_WIDTH, ADDR_WIDTH, MEMORY_DEPTH))

    function new(string name = "axi4_sequencer", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("AXI4_SEQUENCER", "Sequencer built", UVM_LOW);
    endfunction

endclass
endpackage