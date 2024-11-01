module dual_clock_fifo #(
    parameter DATA_WIDTH = 8,       // Width of data bus
    parameter FIFO_DEPTH = 16       // Depth of the FIFO
) (
    input wire clk1,                // Sampling clock (10 kHz)
    input wire clk2,                // Core clock
    input wire reset,               // Asynchronous reset
    input wire [DATA_WIDTH-1:0] data_in, // Data input
    input wire write_en,            // Write enable
    input wire read_en,             // Read enable
    output reg [DATA_WIDTH-1:0] data_out, // Data output
    output wire full,               // FIFO full flag
    output wire empty               // FIFO empty flag
);

    // Calculating the address width based on FIFO depth
    localparam ADDR_WIDTH = $clog2(FIFO_DEPTH);

    // Internal memory and pointers
    reg [DATA_WIDTH-1:0] fifo_mem [0:FIFO_DEPTH-1];
    reg [ADDR_WIDTH-1:0] write_ptr = 0;
    reg [ADDR_WIDTH-1:0] read_ptr = 0;
    reg [ADDR_WIDTH:0] count = 0; // Extended width for counting

    // Write logic (synchronized with clk1)
    always @(posedge clk1 or posedge reset) begin
        if (reset) begin
            write_ptr <= 0;
        end else if (write_en && !full) begin
            fifo_mem[write_ptr] <= data_in;
            write_ptr <= write_ptr + 1;
        end
    end

    // Read logic (synchronized with clk2)
    always @(posedge clk2 or posedge reset) begin
        if (reset) begin
            read_ptr <= 0;
        end else if (read_en && !empty) begin
            data_out <= fifo_mem[read_ptr];
            read_ptr <= read_ptr + 1;
        end
    end

    // Count management and flags
    always @(posedge clk1 or posedge clk2 or posedge reset) begin
        if (reset) begin
            count <= 0;
        end else begin
            case ({write_en && !full, read_en && !empty})
                2'b10: count <= count + 1; // Increment on write
                2'b01: count <= count - 1; // Decrement on read
                default: count <= count;    // No change
            endcase
        end
    end

    // Full and empty flag assignments
    assign full = (count == FIFO_DEPTH);
    assign empty = (count == 0);

endmodule
