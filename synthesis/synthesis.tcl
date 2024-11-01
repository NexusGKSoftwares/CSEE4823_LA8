read_verilog src/dual_clock_fifo.v
synth -top dual_clock_fifo
write_verilog synthesis/dual_clock_fifo_nl.v
