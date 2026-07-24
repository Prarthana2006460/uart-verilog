# UART Verilog Echo Project

This project implements a UART transmitter, receiver, and echo loopback system using Verilog.

## Features

- UART TX and RX modules
- 8-N-1 UART communication
- 25 MHz clock
- 115200 baud rate
- Echo loopback: received characters are transmitted back
- Vivado simulation testbench

## Files

- `UART_TX.v` — UART transmitter
- `UART_RX.v` — UART receiver
- `uart_echo.v` — UART echo top module
- `uart_echo_tb.v` — Simulation testbench

## Simulation Result

The testbench sends characters such as `h`, `a`, and `y`. The receiver correctly receives and echoes the same characters back.

## Tools Used

- Verilog HDL
- Xilinx Vivado
