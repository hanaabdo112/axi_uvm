 import uvm_pkg::*;
`include "uvm_macros.svh"

import axi4_test_pkg::*;
`include "axi4_if.sv"

module axi4_top;

// Instantiate the AXI4 interface
    axi4_if #(
        .DATA_WIDTH(32),
        .ADDR_WIDTH(16), 
        .MEMORY_DEPTH(1024)
    ) axi4_vif();

    axi4 #(
        .DATA_WIDTH(32),
        .ADDR_WIDTH(16),
        .MEMORY_DEPTH(1024)
    ) DUT (
        // Clock and Reset
        .ACLK(axi4_vif.ACLK),
        .ARESETn(axi4_vif.ARESETn),
        
        // Write Address Channel
        .AWADDR(axi4_vif.AWADDR),
        .AWLEN(axi4_vif.AWLEN),
        .AWSIZE(axi4_vif.AWSIZE),
        .AWVALID(axi4_vif.AWVALID),
        .AWREADY(axi4_vif.AWREADY),
        
        // Write Data Channel
        .WDATA(axi4_vif.WDATA),
        .WVALID(axi4_vif.WVALID),
        .WLAST(axi4_vif.WLAST),
        .WREADY(axi4_vif.WREADY),
        
        // Write Response Channel
        .BRESP(axi4_vif.BRESP),
        .BVALID(axi4_vif.BVALID),
        .BREADY(axi4_vif.BREADY),
        
        // Read Address Channel
        .ARADDR(axi4_vif.ARADDR),
        .ARLEN(axi4_vif.ARLEN),
        .ARSIZE(axi4_vif.ARSIZE),
        .ARVALID(axi4_vif.ARVALID),
        .ARREADY(axi4_vif.ARREADY),
        
        // Read Data Channel
        .RDATA(axi4_vif.RDATA),
        .RRESP(axi4_vif.RRESP),
        .RVALID(axi4_vif.RVALID),
        .RLAST(axi4_vif.RLAST),
        .RREADY(axi4_vif.RREADY)
    );

    // Clock generation
    always #10 axi4_vif.ACLK = ~axi4_vif.ACLK;

    initial begin
        // Initialize clock and reset
        axi4_vif.ACLK = 0;
        // axi4_vif.ARESETn = 0;
        
        // // Apply reset
        // #20 axi4_vif.ARESETn = 1;
        
        // Set the virtual interface in config database
        uvm_config_db#(virtual axi4_if#(32, 16, 1024))::set(null, "*", "vif", axi4_vif);
        
        // Start the UVM test
        run_test("axi4_test");
    end

endmodule