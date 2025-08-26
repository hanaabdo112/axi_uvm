package axi4_agent_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"
import axi4_sequencer_pkg::*;
import axi4_driver_pkg::*;
import axi4_monitor_pkg::*;

class axi4_agent #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 16,
    parameter MEMORY_DEPTH = 1024
    ) extends uvm_agent;

`uvm_component_utils(axi4_agent#(DATA_WIDTH, ADDR_WIDTH, MEMORY_DEPTH))

axi4_driver#(DATA_WIDTH, ADDR_WIDTH, MEMORY_DEPTH) driver;
axi4_sequencer#(DATA_WIDTH, ADDR_WIDTH, MEMORY_DEPTH) sequencer;
axi4_monitor#(DATA_WIDTH, ADDR_WIDTH, MEMORY_DEPTH) monitor;

 function new (string name = "axi4_agent" , uvm_component parent = null);
     super.new(name , parent);
  endfunction

   function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("AXI4_AGENT", "Agent built", UVM_LOW);

        driver    = axi4_driver#(DATA_WIDTH, ADDR_WIDTH, MEMORY_DEPTH)::type_id::create("driver", this);
        sequencer = axi4_sequencer#(DATA_WIDTH, ADDR_WIDTH, MEMORY_DEPTH)::type_id::create("sequencer", this);
        monitor   = axi4_monitor#(DATA_WIDTH, ADDR_WIDTH, MEMORY_DEPTH)::type_id::create("monitor", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction

endclass

endpackage
