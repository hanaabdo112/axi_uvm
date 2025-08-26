package axi4_scoreboard_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"
import axi4_sequence_item_pkg::*;

class axi4_scoreboard #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 16,
    parameter MEMORY_DEPTH = 1024
    ) extends uvm_scoreboard;

   `uvm_component_utils(axi4_scoreboard#(DATA_WIDTH, ADDR_WIDTH, MEMORY_DEPTH))

    virtual axi4_if       #(DATA_WIDTH, ADDR_WIDTH, MEMORY_DEPTH) vif;
    axi4_sequence_item    #(DATA_WIDTH, ADDR_WIDTH, MEMORY_DEPTH) req;
    uvm_analysis_export   #(axi4_sequence_item#(DATA_WIDTH, ADDR_WIDTH, MEMORY_DEPTH)) axp;
    uvm_tlm_analysis_fifo #(axi4_sequence_item#(DATA_WIDTH, ADDR_WIDTH, MEMORY_DEPTH)) fifo;

    logic [DATA_WIDTH-1:0] Assoc_Array [bit[ADDR_WIDTH-1:0]] ;

    function new(string name = "axi4_scoreboard", uvm_component parent = null);
        super.new(name, parent);
        req  = new("req");
        axp  = new("axp", this);
        fifo = new("fifo", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("AXI4_SCOREBOARD", "Scoreboard built", UVM_LOW);

         if(!uvm_config_db#(virtual axi4_if#(DATA_WIDTH, ADDR_WIDTH, MEMORY_DEPTH))::get(this, "", "vif", vif)) begin
            `uvm_fatal("MONITOR", "Failed to get interface")
        end
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        axp.connect(fifo.analysis_export);
    endfunction


    task run_phase(uvm_phase phase);
        forever begin
            fifo.get(req);    
            // Handle completed write transactions (AWVALID & AWREADY & WVALID & WREADY)
            if(req.is_write && req.WVALID && req.WREADY) begin
                Assoc_Array[req.AWADDR] = req.WDATA;
                `uvm_info("SCOREBOARD",$sformatf("Write completed: Addr=0x%0h, Data=0x%0h", 
                    req.AWADDR, req.WDATA), UVM_MEDIUM)
            end
            
            // Handle completed read reqactions (ARVALID & ARREADY & RVALID & RREADY)
            if(req.is_read && req.RVALID && req.RREADY) begin
                logic [DATA_WIDTH-1:0] expected = Assoc_Array[req.ARADDR];
                
                if(req.RDATA !== expected) begin
                    `uvm_error("SCOREBOARD", 
                        $sformatf("Read mismatch! Addr: 0x%0h, Expected: 0x%0h, Got: 0x%0h",
                        req.ARADDR, expected, req.RDATA))
                end else begin
                    `uvm_info("SCOREBOARD", 
                        $sformatf("Read verified: Addr=0x%0h, Data=0x%0h", 
                        req.ARADDR, req.RDATA), UVM_MEDIUM)
                end
            end
        end
    endtask

endclass

endpackage