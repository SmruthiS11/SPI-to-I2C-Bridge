`timescale 1ns / 1ps
module i2c_master(
    input i_clk,
    input reset_n,
    input rw,
    input sda_in_m,
    input [6:0] i2c_address,
    output reg sda_out_m,
    output reg sda_out_en_m,
    output reg scl_out_m,
    output reg addr_ack,
    output reg data_ack,
    input [7:0] i2c_wData,
    output reg [7:0] i2c_rData
);

parameter I2C_IDLE = 3'b000;
parameter I2C_START = 3'b001;
parameter I2C_CLOCK_LOW = 3'b010;
parameter I2C_DATA_SHIFT = 3'b011;
parameter I2C_CLOCK_HIGH = 3'b100;
parameter I2C_STOP = 3'b101;

reg [2:0] i2c_SM_main_m;
reg [4:0] bit_count;
reg [17:0] shift_reg;
reg data_continue;

always @(posedge i_clk or negedge reset_n) begin
    if (~reset_n) begin
        i2c_SM_main_m <= I2C_IDLE;
        bit_count <= 5'b00000;
        sda_out_m <= 1'b1;
        sda_out_en_m <= 1'b0;
        scl_out_m <= 1'b1;
        data_continue <= 1'b1;
    end
    else begin
        case (i2c_SM_main_m)
            I2C_IDLE: begin
                i2c_SM_main_m <= I2C_START;
            end
            I2C_START: begin
                i2c_SM_main_m <= I2C_CLOCK_LOW;
                if (rw) begin
                    shift_reg <= {i2c_address[6:0], 1'b0, 1'b1, 8'h00, 1'b1};
                end
                else begin
                    shift_reg <= {1'b1, i2c_wData, 1'b1, 1'b0, i2c_address[6:0]};
                end
            end
            I2C_CLOCK_LOW: begin
                scl_out_m <= 1'b0;
                i2c_SM_main_m <= I2C_DATA_SHIFT;
            end
            I2C_DATA_SHIFT: begin
                sda_out_m <= shift_reg[0];
                shift_reg <= {1'b0, shift_reg[17:1]};
                i2c_SM_main_m <= I2C_CLOCK_HIGH;
            end
            I2C_CLOCK_HIGH: begin
                scl_out_m <= 1'b1;
                bit_count <= bit_count + 1;
                if (bit_count == 8) begin
                    addr_ack <= sda_in_m;
                end
                else if (bit_count == 18) begin
                    data_ack <= sda_in_m;
                end
                if (bit_count == 18) begin
                    i2c_SM_main_m <= I2C_STOP;
                end
                else if (bit_count != 17) begin
                    i2c_rData <= {i2c_rData[6:0], sda_in_m};
                    i2c_SM_main_m <= I2C_CLOCK_LOW;
                end
            end
            I2C_STOP: begin
                sda_out_m <= 1'b1;
                i2c_SM_main_m <= I2C_IDLE;
            end
        endcase
    end
end

endmodule
