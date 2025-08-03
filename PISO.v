`timescale 1ns / 1ps

module PISO (
    input wire clk,           // Clock signal
    input wire reset,         // Reset signal (active high)
    input wire load,          // Load signal to load parallel data into the shift register
    input wire [7:0] parallel_in, // 8-bit parallel data input
    output reg serial_out,    // Serial data output
    output reg data_valid     // Flag indicating data is shifting out
);

reg [7:0] shift_reg;          // Internal shift register
reg [2:0] bit_count;          // Counter for tracking number of bits shifted out

always @(posedge clk or posedge reset) begin
    if (reset) begin
        shift_reg <= 8'b0;      // Reset shift register to 0
        serial_out <= 1'b0;     // Clear serial output
        bit_count <= 3'b0;      // Reset bit counter to 0
        data_valid <= 1'b0;     // Clear data valid flag
    end else if (load) begin
        // Load parallel data into shift register
        shift_reg <= parallel_in;
        bit_count <= 3'b0;      // Reset bit counter for new data load
        data_valid <= 1'b1;     // Set data valid flag
    end else if (data_valid) begin
        // Shift out data one bit at a time
        serial_out <= shift_reg[7];
        shift_reg <= {shift_reg[6:0], 1'b0}; // Shift left
        bit_count <= bit_count + 1;

        // Clear data_valid when all bits are shifted out
        if (bit_count == 3'b111) begin
            data_valid <= 1'b0; // Clear data valid flag
        end
    end
end

endmodule

