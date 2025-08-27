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

    // Track when a write has occurred and which addresses were written
    bit any_write_seen;
    bit first_write_seen;
    bit [ADDR_WIDTH-1:0] first_write_addr;
    bit [ADDR_WIDTH-1:0] last_awaddr;
    bit                  last_awaddr_valid;
    bit [ADDR_WIDTH-1:0] last_araddr;
    bit                  last_araddr_valid;
    bit written_by_addr [bit[ADDR_WIDTH-1:0]];

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

        any_write_seen = 1'b0;
        first_write_seen = 1'b0;
        first_write_addr = '0;
        last_awaddr_valid = 1'b0;
        last_araddr_valid = 1'b0;
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

        // Track address handshakes
        if (vif.AWVALID && vif.AWREADY) begin
            last_awaddr       = vif.AWADDR;
            last_awaddr_valid = 1'b1;
        end
        if (vif.ARVALID && vif.ARREADY) begin
            last_araddr       = vif.ARADDR;
            last_araddr_valid = 1'b1;
        end

        // Detect write data beat; mark address as written (single-beat writes assumed)
        if (vif.WVALID && vif.WREADY) begin
            if (last_awaddr_valid) begin
                written_by_addr[last_awaddr] = 1'b1;
                if (!first_write_seen) begin
                    first_write_seen = 1'b1;
                    first_write_addr = last_awaddr;
                end
            end
            any_write_seen     = 1'b1;
            last_awaddr_valid  = 1'b0;
        end

        // Derive operation type for scoreboard with gating
        req.is_write = (vif.AWVALID && vif.AWREADY) || (vif.WVALID && vif.WREADY);

        // Only consider read data for the first address that was written
        bit read_data_hs = (vif.RVALID && vif.RREADY);
        bit read_allowed = first_write_seen && last_araddr_valid && (last_araddr == first_write_addr);
        req.is_read  = read_data_hs && read_allowed;

         ap.write(req);
           
        end
    endtask
endclass

endpackage