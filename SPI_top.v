`timescale 1ns / 1ps

module SPI_top(
    input i_Rst_L,     // Active-low reset
    input i_Clk,       // System clock
    output [7:0] o_Counter,  // Output counter value for observation
    output o_RX_DV,    // Data Valid from Master
    output [7:0] o_RX_Byte // Received Byte from Master
    );
    // SPI connections
    wire w_SPI_Clk;
    wire w_SPI_MOSI;
    wire w_SPI_MISO;
    wire w_SPI_CS_n;

    // Flags
    wire w_TX_Ready;
    reg r_TX_DV;
    reg [7:0] r_TX_Byte;
    wire [7:0] w_RX_Byte;
    wire w_RX_DV;

    // Counter
    reg [7:0] counter;
    
    // Instantiate SPI Master
    SPI_master_with_cs master_inst (
        .i_Rst_L(i_Rst_L),
        .i_Clk(i_Clk),
        .i_TX_Count(1), // Sending 1 byte per CS low
        .i_TX_Byte(r_TX_Byte),
        .i_TX_DV(r_TX_DV),
        .o_TX_Ready(w_TX_Ready),
        .o_RX_Count(),
        .o_RX_DV(w_RX_DV),
        .o_RX_Byte(w_RX_Byte),
        .o_SPI_Clk(w_SPI_Clk),
        .i_SPI_MISO(w_SPI_MISO),
        .o_SPI_MOSI(w_SPI_MOSI),
        .o_SPI_CS_n(w_SPI_CS_n)
    );

    // Instantiate SPI Slave
    SPI_slave slave_inst (
        .i_Rst_L(i_Rst_L),
        .i_Clk(i_Clk),
        .o_RX_DV(o_RX_DV),
        .o_RX_Byte(o_RX_Byte),
        .i_TX_DV(w_TX_Ready),
        .i_TX_Byte(counter),
        .i_SPI_Clk(w_SPI_Clk),
        .o_SPI_MISO(w_SPI_MISO),
        .i_SPI_MOSI(w_SPI_MOSI),
        .i_SPI_CS_n(w_SPI_CS_n)
    );

    // Counter logic
    always @(posedge i_Clk or negedge i_Rst_L) begin
        if (!i_Rst_L) begin
            counter <= 8'b0;
        end else if (w_TX_Ready) begin
            counter <= counter + 1;
        end
    end

    // Transmit control
    always @(posedge i_Clk or negedge i_Rst_L) begin
        if (!i_Rst_L) begin
            r_TX_DV <= 1'b0;
            r_TX_Byte <= 8'b0;
        end else begin
            if (w_TX_Ready) begin
                r_TX_DV <= 1'b1;
                r_TX_Byte <= counter;
            end else begin
                r_TX_DV <= 1'b0;
            end
        end
    end

    // Output connections
    assign o_Counter = counter;
    assign o_RX_DV = w_RX_DV;
    assign o_RX_Byte = w_RX_Byte;
endmodule
