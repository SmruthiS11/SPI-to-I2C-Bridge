`timescale 1ns / 1ps

module spi_i2c_bridge(
    input i_Rst_L,           // Active-low reset
    input i_Clk,             // System clock
    input spi_clk,           // SPI clock
    input spi_mosi,          // SPI Master Out Slave In
    input i2c_clk,           // I2C clock
    output i2c_sda,          // I2C Serial Data Line
    output i2c_scl,          // I2C Serial Clock Line
    input [6:0] i2c_address, // I2C address for communication
    output [7:0] o_rx_byte,  // Received byte from SPI
    output rx_dv             // Data valid signal from SPI
);

    // Internal connections
    wire [7:0] sipo_parallel_out;    // Output of SIPO
    wire sipo_data_valid;            // Flag indicating SIPO has complete data
    wire piso_serial_out;            // Output of PISO for I2C SDA line
    reg [7:0] buffer;                // Buffer to hold data from SPI to PISO
    
    // SPI and I2C Control Signals
    reg spi_data_ready;              // Flag to signal data is ready for I2C
    wire i2c_rw = 1'b0;              // Fixed as write mode for simplicity
    
    // Instantiate SPI Master/Slave Module (SPI_top)
    SPI_top spi_inst (
        .i_Rst_L(i_Rst_L),
        .i_Clk(i_Clk),
        .o_Counter(),
        .o_RX_DV(rx_dv),
        .o_RX_Byte(o_rx_byte)
    );
    
    // Instantiate SIPO for receiving data from SPI
    sipo sipo_inst (
        .clk(spi_clk),
        .reset(i_Rst_L),
        .serial_in(spi_mosi),
        .parallel_out(sipo_parallel_out),
        .data_valid(sipo_data_valid)
    );

    // Buffer the data when SIPO indicates data is ready
    always @(posedge i_Clk or negedge i_Rst_L) begin
        if (!i_Rst_L) begin
            buffer <= 8'b0;
            spi_data_ready <= 1'b0;
        end else if (sipo_data_valid) begin
            buffer <= sipo_parallel_out;
            spi_data_ready <= 1'b1;
        end else begin
            spi_data_ready <= 1'b0;
        end
    end

    // Instantiate PISO for sending data to I2C
    PISO piso_inst (
        .clk(i2c_clk),
        .reset(i_Rst_L),
        .load(spi_data_ready),       // Load data to PISO when SPI data is ready
        .parallel_in(buffer),        // Load buffer data into PISO
        .serial_out(piso_serial_out),
        .data_valid()                // Not required in this case
    );

    // Instantiate I2C Master Module (i2c_top)
    i2c_top i2c_inst (
        .i_clk(i_Clk),
        .reset_n(i_Rst_L),
        .rw(i2c_rw),                 // Set to write mode
        .i2c_address(i2c_address),
        .i2c_wData(buffer),
        .i2c_Data(),
        .i2c_rData()
    );

    // Output assignment
    assign i2c_sda = piso_serial_out; // Connect PISO output to I2C SDA
    assign i2c_scl = i2c_clk;         // Connect I2C clock

endmodule
