package axi4_monitor_pkg;

 import uvm_pkg::*;
`include "uvm_macros.svh"

 import axi4_sequence_item_pkg::*;

 class axi4_monitor #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 16,
    parameter MEMORY_DEPTH = 1024
    ) extends uvm_monitor;

   `uvm_component_utils(axi4_monitor#(DATA_WIDTH, ADDR_WIDTH, MEMORY_DEPTH))

    virtual axi4_if   #(DATA_WIDTH, ADDR_WIDTH, MEMORY_DEPTH) vif;
    uvm_analysis_port #(axi4_sequence_item#(DATA_WIDTH, ADDR_WIDTH, MEMORY_DEPTH)) ap;

    function new(string name = "axi4_monitor", uvm_component parent = null);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("AXI4_MONITOR", "Monitor built", UVM_LOW);
        
        if(!uvm_config_db#(virtual axi4_if#(DATA_WIDTH, ADDR_WIDTH, MEMORY_DEPTH))::get(this, "", "vif", vif)) begin
            `uvm_fatal("MONITOR", "Failed to get interface")
        end
    endfunction

    task run_phase(uvm_phase phase);
       
        forever begin
            axi4_sequence_item#(DATA_WIDTH, ADDR_WIDTH, MEMORY_DEPTH) req;
            req = axi4_sequence_item#(DATA_WIDTH, ADDR_WIDTH, MEMORY_DEPTH)::type_id::create("req");
            @(posedge vif.ACLK);

            // Write Address Channel
        req.AWADDR  = vif.AWADDR;
        req.AWLEN   = vif.AWLEN;
        req.AWSIZE  = vif.AWSIZE;
        req.AWVALID = vif.AWVALID;
        req.AWREADY = vif.AWREADY;

        // Write Data Channel
        req.WDATA   = vif.WDATA;
        req.WVALID  = vif.WVALID;
        req.WLAST   = vif.WLAST;
        req.WREADY  = vif.WREADY;

        // Write Response Channel
        req.BRESP   = vif.BRESP;
        req.BVALID  = vif.BVALID;
        req.BREADY  = vif.BREADY;

        // Read Address Channel
        req.ARADDR  = vif.ARADDR;
        req.ARLEN   = vif.ARLEN;
        req.ARSIZE  = vif.ARSIZE;
        req.ARVALID = vif.ARVALID;
        req.ARREADY = vif.ARREADY;

        // Read Data Channel
        req.RDATA   = vif.RDATA;
        req.RRESP   = vif.RRESP;
        req.RVALID  = vif.RVALID;
        req.RLAST   = vif.RLAST;
        req.RREADY  = vif.RREADY;

         ap.write(req);
           
        end
    endtask
endclass

endpackage