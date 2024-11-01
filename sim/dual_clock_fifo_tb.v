`timescale 1ns / 1ps

module dual_clock_fifo_tb;
    // Parameters
    localparam DATA_WIDTH = 8;
    localparam FIFO_DEPTH = 16;

    // Testbench signals
    reg clk1, clk2, reset;
    reg [DATA_WIDTH-1:0] data_in;
    reg write_en, read_en;
    wire [DATA_WIDTH-1:0] data_out;
    wire full, empty;

    // Instantiate the FIFO module
    dual_clock_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .FIFO_DEPTH(FIFO_DEPTH)
    ) uut (
        .clk1(clk1),
        .clk2(clk2),
        .reset(reset),
        .data_in(data_in),
        .write_en(write_en),
        .read_en(read_en),
        .data_out(data_out),
        .full(full),
        .empty(empty)
    );

    // Clock generation
    always #50000 clk1 = ~clk1; // 10 kHz clock: Period = 100 µs = 50000 ns
    always #20000 clk2 = ~clk2; // Core clock: Period = 40 µs = 20000 ns (25 kHz)

    // Testbench procedure
    initial begin
        // Initialize signals
        clk1 = 0;
        clk2 = 0;
        reset = 1;
        write_en = 0;
        read_en = 0;
        data_in = 0;

        // Reset sequence
        #100000 reset = 0; // Release reset after 100 µs

        // Write data into the FIFO
        #100000 write_en = 1; data_in = 8'hAA; // Write 0xAA
        #100000 data_in = 8'h55;               // Write 0x55
        #100000 write_en = 0;                  // Stop writing

        // Read data from the FIFO
        #200000 read_en = 1;                   // Start reading
        #100000 read_en = 0;                   // Stop reading

        // End the simulation
        #500000 $finish;
    end

    // VCD file generation for waveform analysis
    initial begin
        $dumpfile("sim/dual_clock_fifo.vcd");
        $dumpvars(0, dual_clock_fifo_tb);
    end
endmodule
