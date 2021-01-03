`ifndef DCACHE_SRAM_V
`define DCACHE_SRAM_V

`include "MUX32.v"

module dcache_sram
(
    clk_i,
    rst_i,
    enable_i,

    // about read or test if hit or not
    addr_i,
    tag_i,
    hit_o,
    tag_o,
    data_o,

    // about write
    data_i,
    write_i
);

// I/O Interface from/to controller
input              clk_i;
input              rst_i;
input    [3:0]     addr_i;
input    [24:0]    tag_i; // [24]: valid bit, [23]: dirty bit
input    [255:0]   data_i;
input              enable_i;
input              write_i;

output   [24:0]    tag_o;
output   [255:0]   data_o;
output             hit_o; // hit_o is "don't-care" if write_i


// Memory
reg      [24:0]    tag [0:15][0:1]; // [24]: valid bit, [23]: dirty bit
reg      [255:0]   data[0:15][0:1];
reg                to_be_replaced[0:15];

integer            i, j;

wire    hit[0:1];
wire    select;
assign  hit[0]  = tag[addr_i][0][24] & (tag[addr_i][0][22:0] == tag_i[22:0]);
assign  hit[1]  = tag[addr_i][1][24] & (tag[addr_i][1][22:0] == tag_i[22:0]);
assign  select  = (hit[0]) ? 0 :
                  (hit[1]) ? 1 : to_be_replaced[addr_i];

wire    [255:0]  debug;
assign  debug = data[0][0];

// Read Data
// TODO: tag_o=? data_o=? hit_o=?
assign  hit_o   = hit[0] | hit[1];
assign  tag_o   = tag[addr_i][select];
assign  data_o  = data[addr_i][select];


// Write Data
// 1. Write hit
// 2. Read miss: Read from memory
always@(posedge clk_i or posedge rst_i) begin
    if (rst_i) begin
        for (i=0;i<16;i=i+1) begin
            for (j=0;j<2;j=j+1) begin
                tag[i][j] <= 25'b0;
                data[i][j] <= 256'b0;
            end
            to_be_replaced[i] <= 1'b0;
        end
    end
    if (enable_i) begin
        // TODO: Handle your write of 2-way associative cache + LRU here
        if (write_i) begin
            // forcefully write the data
            data[addr_i][select] <= data_i;
            tag[addr_i][select][22:0] <= tag_i[22:0];
            tag[addr_i][select][23] <= 1; // dirty
            tag[addr_i][select][24] <= 1; // valid
            to_be_replaced[addr_i] <= ~select;
        end
        else if (hit_o) begin
            // hit
            to_be_replaced[addr_i] <= hit[1];
        end
    end
end

endmodule

`endif
