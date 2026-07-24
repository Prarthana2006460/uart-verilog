`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.07.2026 11:29:04
// Design Name: 
// Module Name: echo_uart
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


// uart_echo.v
`timescale 1ns / 1ps

module uart_echo #(
    parameter CLKS_PER_BIT = 217
)(
    input  wire clk,
    input  wire reset,
    input  wire uart_rx_pin,
    output wire uart_tx_pin
);

    wire [7:0] rx_data;
    wire       rx_valid;
    wire       tx_busy;

    reg [7:0] tx_data;
    reg       tx_start;

    reg [7:0] pending_data;
    reg       pending_valid;

    UART_RX #(
        .CLKS_PER_BIT(CLKS_PER_BIT)
    ) RX (
        .clk(clk),
        .reset(reset),
        .rx(uart_rx_pin),
        .data_out(rx_data),
        .data_valid(rx_valid)
    );

    UART_TX #(
        .CLKS_PER_BIT(CLKS_PER_BIT)
    ) TX (
        .clk(clk),
        .reset(reset),
        .start(tx_start),
        .data_in(tx_data),
        .tx(uart_tx_pin),
        .busy(tx_busy)
    );

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            tx_data       <= 8'h00;
            tx_start      <= 1'b0;
            pending_data  <= 8'h00;
            pending_valid <= 1'b0;
        end
        else begin
            tx_start <= 1'b0;

            // Send a stored received character when TX is free.
            if (!tx_busy && pending_valid) begin
                tx_data       <= pending_data;
                tx_start      <= 1'b1;
                pending_valid <= 1'b0;
            end

            // Store the latest received character.
            if (rx_valid) begin
                pending_data  <= rx_data;
                pending_valid <= 1'b1;
            end
        end
    end

endmodule