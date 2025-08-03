`timescale 1ns / 1ps

module i2c_slave(
    input i_clk,
    input reset_n,
    input rw,
    input sda_in_s,
    input [6:0] i2c_address,
    output reg sda_out_s,
    output reg sda_out_en_s,
    input scl_in_s,
    output reg [7:0] i2c_Data
);

parameter I2C_IDLE = 3'b000,
          I2C_START = 3'b001,
          I2C_ADDR_SHIFT = 3'b010,
          I2C_RW = 3'b011,
          I2C_DATA_SHIFT = 3'b100,
          I2C_ADDR_DATA_ACK = 3'b101,
          I2C_STOP = 3'b110,
          I2C_REPEAT_START = 3'b111;

reg [2:0] i2c_SM_main_s;
reg [4:0] bit_count;
reg [17:0] shift_reg;
reg [6:0] addr_reg;
reg [7:0] data_reg;
reg scl_q;
reg sda_q;
reg addr_ack;

// Clocked process for edge detection on scl and sda signals
always @(posedge i_clk or negedge reset_n) begin
    if (~reset_n) begin
        scl_q <= 1'b0;
        sda_q <= 1'b0;
    end else begin
        scl_q <= scl_in_s;
        sda_q <= sda_in_s;
    end
end

// Main state machine process
always @(posedge i_clk or negedge reset_n) begin
    if (~reset_n) begin
        i2c_SM_main_s <= I2C_IDLE;
        bit_count <= 4'b0000;
        sda_out_s <= 1'b1;
        sda_out_en_s <= 1'b0;
        addr_ack <= 1'b0;
        data_reg <= 8'h00;
    end else begin
        case (i2c_SM_main_s)
            I2C_IDLE: begin
                i2c_SM_main_s <= I2C_START;
            end

            I2C_START: begin
                if (sda_in_s == 0 && scl_in_s == 1) begin
                    i2c_SM_main_s <= I2C_ADDR_SHIFT;
                end
            end

            I2C_ADDR_SHIFT: begin
                addr_reg[bit_count] <= sda_in_s;
                if (bit_count == 6) begin
                    bit_count <= 0;
                    i2c_SM_main_s <= I2C_RW;
                end else begin
                    bit_count <= bit_count + 1;
                end
            end

            I2C_RW: begin
                if (scl_q) begin
                    if (rw) begin
                        sda_out_en_s <= 1'b1;
                        sda_out_s <= data_reg[bit_count];
                    end else begin
                        data_reg[bit_count] <= sda_in_s;
                        sda_out_s <= 1'b1;
                        sda_out_en_s <= 1'b0;
                    end
                    if (bit_count == 0) begin
                        bit_count <= 0;
                        i2c_Data <= data_reg;
                        i2c_SM_main_s <= I2C_DATA_SHIFT;
                    end else begin
                        bit_count <= bit_count + 1;
                    end
                end
            end

            I2C_ADDR_DATA_ACK: begin
                sda_out_s <= 1'b0;
                sda_out_en_s <= 1'b1;
                if (scl_q && addr_ack) begin
                    addr_ack <= 1'b0;
                    i2c_SM_main_s <= I2C_DATA_SHIFT;
                end
            end

            I2C_STOP: begin
                sda_out_s <= 1'b1;
                sda_out_en_s <= 1'b0;
                i2c_SM_main_s <= I2C_IDLE;
            end
        endcase
    end
end

endmodule
