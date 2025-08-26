package axi4_coverage_pkg;

 import uvm_pkg::*;
`include "uvm_macros.svh"

 import axi4_sequence_item_pkg::*;

class axi4_coverage #( 
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 16,
    parameter MEMORY_DEPTH = 1024
    ) extends uvm_component;
     `uvm_component_utils(axi4_coverage#(DATA_WIDTH, ADDR_WIDTH, MEMORY_DEPTH))

    uvm_analysis_export   #(axi4_sequence_item#(DATA_WIDTH, ADDR_WIDTH, MEMORY_DEPTH)) axp;
    uvm_tlm_analysis_fifo #(axi4_sequence_item#(DATA_WIDTH, ADDR_WIDTH, MEMORY_DEPTH)) fifo;

    covergroup cov ;
     coverpoint req.AWADDR {
            bins addr_0 = {0};
            bins addr_low = {[1:255]};
            bins addr_mid = {[256:767]};
            bins addr_high = {[768:1023]};
     }

      coverpoint req.AWLEN {
            bins len_0 = {0};
      }

       coverpoint req.AWSIZE {
            bins word = {2};
       }
     endgroup

      axi4_sequence_item    #(DATA_WIDTH, ADDR_WIDTH, MEMORY_DEPTH) req;

      function new(string name = "axi4_coverage", uvm_component parent = null);
        super.new(name, parent);
        cov = new();
      endfunction

      function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("AXI4_COVERAGE", "Coverage collector built", UVM_LOW);
         axp  = new("axp", this);
         fifo = new("fifo", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        //super.connect_phase(phase);
        axp.connect(fifo.analysis_export);
    endfunction

    task run_phase(uvm_phase phase);
        forever begin
            fifo.get(req); 
            cov.sample();
        end
    endtask
endclass
endpackage