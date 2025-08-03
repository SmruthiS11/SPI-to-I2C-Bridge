`timescale 1ns / 1ps

// top module for I2C

module i2c_top(
    input i_clk,
    input reset_n,
    input rw, // 1: Read, 0: Write
    input [6:0] i2c_address,
    input [7:0] i2c_wData,
    output [7:0] i2c_Data,
    output wire [7:0] i2c_rData
);

// Internal wire declaration
wire SDA1, SDA2;
wire SCL;
wire data_ack, addr_ack;
wire sda_out_en_m, sda_out_en_s;


i2c_master i2c_m (
    .i_clk(i_clk),
    .reset_n(reset_n),
    .rw(rw),
    .sda_in_m(SDA1),
    .i2c_address(i2c_address),
    .sda_out_m(SDA2),
    .sda_out_en_m(sda_out_en_m),
    .scl_out_m(SCL),
    .addr_ack(addr_ack),
    .data_ack(data_ack),
    .i2c_wData(i2c_wData),
    .i2c_rData(i2c_rData)
);

// Instantiate I2C Slave
i2c_slave i2c_s (
    .i_clk(i_clk),
    .reset_n(reset_n),
    .rw(rw),
    .sda_in_s(SDA2),
    .i2c_address(i2c_address),
    .sda_out_s(SDA1),
    .sda_out_en_s(sda_out_en_s),
    .scl_in_s(SCL),
    .i2c_Data(i2c_Data)
);

endmodule
