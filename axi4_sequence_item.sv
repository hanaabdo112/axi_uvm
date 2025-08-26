package axi4_sequence_item_pkg;

 import uvm_pkg::*;
`include "uvm_macros.svh"

class axi4_sequence_item #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 16,
    parameter MEMORY_DEPTH = 1024
) extends uvm_sequence_item;

   `uvm_object_utils(axi4_sequence_item#(DATA_WIDTH, ADDR_WIDTH, MEMORY_DEPTH))
    
    // Write channel fields
    rand logic [ADDR_WIDTH-1:0] AWADDR;
    rand logic [7:0]            AWLEN;
         logic [2:0]            AWSIZE;
         logic                  AWVALID;
         logic                  AWREADY;

    rand logic [DATA_WIDTH-1:0] WDATA;
         logic                  WVALID;
         logic                  WLAST;
         logic                  WREADY;

         logic [1:0]            BRESP;
         logic                  BVALID;
         logic                  BREADY;

         logic [ADDR_WIDTH-1:0] ARADDR;
         logic [7:0]            ARLEN;
         logic [2:0]            ARSIZE;
         logic                  ARVALID;
         logic                  ARREADY;

         logic [DATA_WIDTH-1:0] RDATA;
         logic [1:0]            RRESP;
         logic                  RVALID;
         logic                  RLAST;
         logic                  RREADY;

         // Control fields
         rand bit                  is_write;
         rand bit                  is_read;
    
    constraint valid_operation {
        is_write != is_read;
        AWVALID  == is_write;
        WVALID   == is_write;
        ARVALID  == is_read;
    }

    //constraints
    constraint awaddr_c { AWADDR inside {[0:MEMORY_DEPTH-1]}; }

    constraint awlen_c  { (AWLEN + AWADDR) < 1024; }
 
    // constraint wdata_c {
    //     WDATA.size() == AWLEN + 1; // Ensure WDATA size matches AWLEN
    //  }
    
//     constraint data_c { 
//     foreach(WDATA[i]) { 
//       WDATA[i] dist { 
//         32'h0000_0000 :/ 10, 
//         [32'h0000_0001:32'h7FFF_FFFF] :/ 60, 
//         [32'h8000_0000:32'hFFFF_FFFF] :/ 30 
//       }; 
//     } 
//   }

    function new(string name = "axi4_sequence_item");
        super.new(name);
    endfunction

endclass

endpackage