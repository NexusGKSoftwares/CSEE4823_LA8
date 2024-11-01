module dual_clock_fifo (
    input wire clk1,          // Sampling clock
    input wire clk2,          // Core clock
    input wire reset,         // Asynchronous reset
    input wire [7:0] data_in, // 8-bit data input
    input wire write_en,      // Write enable
    input wire read_en,       // Read enable
    output reg [7:0] data_out,// 8-bit data output
    output reg full,          // FIFO full flag
    output reg empty          // FIFO empty flag
);

    // Parameters
    parameter FIFO_DEPTH = 16; // Adjust depth as needed
    parameter ADDR_WIDTH = 4;  // Address width (log2(FIFO_DEPTH))

    // Internal signals
    reg [7:0] fifo_mem [0:FIFO_DEPTH-1]; // FIFO memory
    reg [ADDR_WIDTH-1:0] write_ptr = 0;  // Write pointer
    reg [ADDR_WIDTH-1:0] read_ptr = 0;   // Read pointer
    reg [ADDR_WIDTH:0] count = 0;        // Count for tracking occupancy

    // Write operation (synchronized with clk1)
    always @(posedge clk1 or posedge reset) begin
        if (reset) begin
            write_ptr <= 0;
            full <= 0;
        end else if (write_en && !full) begin
            fifo_mem[write_ptr] <= data_in;
            write_ptr <= write_ptr + 1;
            if (write_ptr + 1 == read_ptr) full <= 1; // Check for full condition
            else full <= 0;
        end
    end

    // Read operation (synchronized with clk2)
    always @(posedge clk2 or posedge reset) begin
        if (reset) begin
            read_ptr <= 0;
            empty <= 1;
        end else if (read_en && !empty) begin
            data_out <= fifo_mem[read_ptr];
            read_ptr <= read_ptr + 1;
            if (read_ptr + 1 == write_ptr) empty <= 1; // Check for empty condition
            else empty <= 0;
        end
    end

    // Occupancy tracking
    always @(posedge clk1 or posedge clk2 or posedge reset) begin
        if (reset) count <= 0;
        else if (write_en && !full && !(read_en && !empty)) count <= count + 1;
        else if (read_en && !empty && !(write_en && !full)) count <= count - 1;
    end
endmodule
