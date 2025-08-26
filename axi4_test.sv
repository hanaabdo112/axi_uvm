package axi4_test_pkg;

 import uvm_pkg::*;
`include "uvm_macros.svh"

import axi4_env_pkg::*;
import axi4_sequence_pkg::*;

class axi4_test extends uvm_test;

`uvm_component_utils(axi4_test)

    axi4_env#(32, 16, 1024) env;
    axi4_sequence#(32, 16, 1024) sequ;

    // axi4_env#(DATA_WIDTH, ADDR_WIDTH, MEMORY_DEPTH) env;
    // axi4_sequence#(DATA_WIDTH, ADDR_WIDTH, MEMORY_DEPTH) sequ;

    function new(string name = "axi4_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("AXI4_TEST", "Test built", UVM_LOW);

        // env  = axi4_env#(DATA_WIDTH, ADDR_WIDTH, MEMORY_DEPTH)::type_id::create("env", this);
        // sequ = axi4_sequence#(DATA_WIDTH, ADDR_WIDTH, MEMORY_DEPTH)::type_id::create("sequ");

         env = axi4_env#(32, 16, 1024)::type_id::create("env", this);
        sequ = axi4_sequence#(32, 16, 1024)::type_id::create("sequ");
    endfunction


//    task run_phase(uvm_phase phase);
//         phase.raise_objection(this);
//           fork
//             begin
//                sequ.start(env.agent.sequencer);
//                #10ns; 
//             end
//             begin
//                `uvm_info("TEST", "Starting AXI4 test sequence", UVM_LOW); 
//             end
//           join
//              phase.drop_objection(this);
//     endtask

   task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        sequ.start(env.agent.sequencer);
        #1000ns;
        phase.drop_objection(this);
    endtask

endclass

endpackage