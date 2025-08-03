`timescale 1ns / 1ps

module sipo (
    input wire clk,         // Clock signal
    input wire reset,       // Reset signal (active high)
    input wire serial_in,   // Serial data input
    output reg [7:0] parallel_out, // Parallel data output
    output reg data_valid   // Flag indicating data is ready
);

reg [2:0] bit_count; // Counter for tracking the number of bits received

always @(posedge clk or posedge reset) begin
    if (reset) begin
        parallel_out <= 8'b0;   // Reset parallel output to 0
        bit_count <= 3'b0;      // Reset bit counter to 0
        data_valid <= 1'b0;     // Clear data valid flag
    end else begin
        // Shift in the new bit
        parallel_out <= {parallel_out[6:0], serial_in};
        bit_count <= bit_count + 1;

        // Check if 8 bits have been received
        if (bit_count == 3'b111) begin
            data_valid <= 1'b1; // Set data valid flag
        end else begin

            data_valid <= 1'b0; // Clear flag until 8 bits are received
        end
    end
end

endmodule
