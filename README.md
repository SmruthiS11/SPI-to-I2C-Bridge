# SPI-to-I2C-Bridge

## Overview
SPI (Serial Peripheral Interface) is a synchronous, full-duplex communication protocol commonly used for short-distance, high-speed data transfer. It typically uses four main signals: MOSI, MISO, SCLK, and CS. I2C (Inter-Integrated Circuit) is another widely used synchronous communication protocol, but it is half-duplex and requires only two wires for communication: SDA (data) and SCL (clock). This makes I2C more pin-efficient, especially when connecting multiple devices on the same bus.
In many embedded systems, peripherals such as sensors, ADCs, or memory devices may support only SPI or only I2C, but not both. This incompatibility can limit system integration. The purpose of this SPI-to-I2C Bridge is to solve this problem by enabling communication between SPI-only and I2C-only devices. The bridge receives data over SPI, processes it internally, and forwards it over I2C, allowing seamless data exchange between devices using different communication protocols. This project demonstrates how such a bridge can be implemented in hardware using Verilog, making it suitable for FPGA-based systems.

## File Structure
The repository contains the following file stucture : 
### `SPI_master_with_cs.v`
SPI master implementation with chip-select support
### `SPI_slave.v`
SPI slave module
### `SPI_top.v`
Top level SPI module
### `i2c_master.v`
I2C Master controller
### `i2c_slave.v`
I2C Slave module
### `i2c_top.v`
Top level I2C module
### `spi_i2c_bridge.v`
SPI to I2C bridge logic
### `PISO.v`
Parallel In Serial Out shift register
### `sipo.v`
Serial In Parallel Out shift register
### `bridge_tb.sv`
Testbench for bridge verification
### `constraints.sdc`
Timing and Design constraints
### Reports
#### `area.rpt`, `power.rpt`, `timing.rpt`
Area, Power and Timing reports

## Tools Used (Cadence)
- Simulation Tool : ncverilog
- Code Coverage Check in ncverilog : Incisive Metrics Center (IMC)
- Sythesis Tool : Genus
