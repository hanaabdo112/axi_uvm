package axi4_sequence_pkg;

`include "uvm_macros.svh"
 import uvm_pkg::*;

import axi4_sequence_item_pkg::*;

class axi4_sequence #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 16,
    parameter MEMORY_DEPTH = 1024
) extends uvm_sequence #(axi4_sequence_item#(DATA_WIDTH, ADDR_WIDTH, MEMORY_DEPTH));
    
    `uvm_object_utils(axi4_sequence#(DATA_WIDTH, ADDR_WIDTH, MEMORY_DEPTH))

    function new(string name = "axi4_sequence");
        super.new(name);
    endfunction

    task body();
        axi4_sequence_item#(DATA_WIDTH, ADDR_WIDTH, MEMORY_DEPTH) req;
        repeat(50) begin
            req = axi4_sequence_item#(DATA_WIDTH, ADDR_WIDTH, MEMORY_DEPTH)::type_id::create("req");
            start_item(req);
            assert(req.randomize());
            //`uvm_info(get_type_name(), $sformatf("DATA RANDOMIZED: %s", req.sprint()), UVM_LOW);
            finish_item(req);
        end
    endtask

endclass

endpackage