package axi4_driver_pkg;

 import uvm_pkg::*;
`include "uvm_macros.svh"

 import axi4_sequence_item_pkg::*;

 class axi4_driver #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 16,
    parameter MEMORY_DEPTH = 1024
    ) extends uvm_driver #(axi4_sequence_item#(DATA_WIDTH, ADDR_WIDTH, MEMORY_DEPTH));

    `uvm_component_utils(axi4_driver#(DATA_WIDTH, ADDR_WIDTH, MEMORY_DEPTH))

    virtual axi4_if    #(DATA_WIDTH, ADDR_WIDTH, MEMORY_DEPTH) vif;
    axi4_sequence_item #(DATA_WIDTH, ADDR_WIDTH, MEMORY_DEPTH) req;

    function new(string name = "axi4_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("AXI4_DRIVER", "Driver built", UVM_LOW);
        
        if(!uvm_config_db#(virtual axi4_if#(DATA_WIDTH, ADDR_WIDTH, MEMORY_DEPTH))::get(this, "", "vif", vif)) begin
            `uvm_fatal("DRIVER", "Failed to get interface")
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
       vif.ARESETn <= 1'b1;
        forever begin
            seq_item_port.get_next_item(req);
            if(req.is_write) begin
                single_write(req.AWADDR, req.WDATA);
            end else begin
                // Call single_read with proper arguments
                logic [DATA_WIDTH-1:0] read_data;
                single_read(req.ARADDR, read_data);
            end
            seq_item_port.item_done();
        end
    endtask

///////////////////////////////////////////////////////////////////////////////////////////////////////////////

    // Task for single write transaction
   virtual task single_write(input logic [ADDR_WIDTH-1:0] addr, input logic [DATA_WIDTH-1:0] data);
        @(negedge vif.ACLK);
        vif.AWADDR = addr;
        vif.AWLEN = 0;  // Single transfer
        vif.AWSIZE = 2; // 4 bytes (32 bits)
        vif.AWVALID = 1;
        
        // Wait for address ready
        while(!vif.AWREADY) @(negedge vif.ACLK);
        @(negedge vif.ACLK);
        vif.AWVALID = 0;
        vif.BREADY = 1;
        // Data phase
        vif.WDATA = data;
        vif.WVALID = 1;
        vif.WLAST = 1;
        
        // Wait for data ready
        while(!vif.WREADY) @(negedge vif.ACLK);
        @(negedge vif.ACLK);
        vif.WVALID = 0;
        vif.WLAST = 0;
        
        // Response phase
       
        while(!vif.BVALID) @(negedge vif.ACLK);
        if(vif.BRESP != 2'b00) begin
             `uvm_error("DRIVER", $sformatf("Write transaction failed at address 0x%h, response: %b", addr, vif.BRESP))
        end
        @(negedge vif.ACLK);
        vif.BREADY = 0;
        
       `uvm_info("DRIVER", $sformatf("Single write completed at address 0x%h, data: 0x%h", addr, data), UVM_MEDIUM)
    endtask


    // Task for single read transaction
    virtual task single_read(input logic [ADDR_WIDTH-1:0] addr, output logic [DATA_WIDTH-1:0] data);
        @(negedge vif.ACLK);
        vif.ARADDR = addr;
        vif.ARLEN = 0;  // Single transfer
        vif.ARSIZE = 2; // 4 bytes (32 bits)
        vif.ARVALID = 1;
        
        vif.RREADY = 1;
        // Wait for address ready
        while(!vif.ARREADY) @(negedge vif.ACLK);
        @(negedge vif.ACLK);
        vif.ARVALID = 0;
        
        // Data phase
        
        while(!vif.RVALID) @(negedge vif.ACLK);
        @(negedge vif.ACLK);
        data = vif.RDATA;
        if(vif.RRESP != 2'b00) begin
            `uvm_error("DRIVER", $sformatf("Read transaction failed at address 0x%h, response: %b", addr, vif.RRESP))
        end
        @(posedge vif.ACLK);
        vif.RREADY = 0;
        
          `uvm_info("DRIVER", $sformatf("Single read completed at address 0x%h, data: 0x%h", addr, data), UVM_MEDIUM)
    endtask

endclass
endpackage