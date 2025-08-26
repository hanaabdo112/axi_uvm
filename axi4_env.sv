package axi4_env_pkg;

 import uvm_pkg::*;
`include "uvm_macros.svh"

import axi4_agent_pkg::*;
import axi4_scoreboard_pkg::*;
import axi4_coverage_pkg::*; 

class axi4_env #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 16,
    parameter MEMORY_DEPTH = 1024
) extends uvm_env;

`uvm_component_utils(axi4_env#(DATA_WIDTH, ADDR_WIDTH, MEMORY_DEPTH))

    axi4_agent#(DATA_WIDTH, ADDR_WIDTH, MEMORY_DEPTH) agent;
    axi4_scoreboard#(DATA_WIDTH, ADDR_WIDTH, MEMORY_DEPTH) scoreboard;
    axi4_coverage#(DATA_WIDTH, ADDR_WIDTH, MEMORY_DEPTH) cov;

    function new(string name = "axi4_env", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("AXI4_ENV", "Environment built", UVM_LOW);

        agent      = axi4_agent#(DATA_WIDTH, ADDR_WIDTH, MEMORY_DEPTH)::type_id::create("agent", this);
        scoreboard = axi4_scoreboard#(DATA_WIDTH, ADDR_WIDTH, MEMORY_DEPTH)::type_id::create("scoreboard", this);
        cov        = axi4_coverage#(DATA_WIDTH, ADDR_WIDTH, MEMORY_DEPTH)::type_id::create("cov", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        agent.monitor.ap.connect(scoreboard.axp);
        agent.monitor.ap.connect(cov.axp);  
    endfunction

endclass

endpackage