`timescale 1ns / 1ps

module dual_clock_fifo_tb;
    // Clock and reset signals
    reg clk1, clk2, reset;
    reg [7:0] data_in;
    reg write_en, read_en;
    wire [7:0] data_out;
    wire full, empty;

    // Instantiate the FIFO module
    dual_clock_fifo uut (
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
    always #50 clk1 = ~clk1; // 10 kHz clock (100 ns period)
    always #30 clk2 = ~clk2; // Higher frequency clock (adjust as needed)

    // Test stimulus
    initial begin
        // Initialize signals
        clk1 = 0;
        clk2 = 0;
        reset = 1;
        write_en = 0;
        read_en = 0;
        data_in = 8'b0;

        // Reset sequence
        #100 reset = 0;

        // Write some data into FIFO
        #100 write_en = 1; data_in = 8'b10101010;
        #100 write_en = 0;

        // Read data from FIFO
        #200 read_en = 1;
        #100 read_en = 0;

        // End simulation
        #500 $finish;
    end

    // Dump waveforms
    initial begin
        $dumpfile("sim/dual_clock_fifo.vcd");
        $dumpvars(0, dual_clock_fifo_tb);
    end
endmodule
