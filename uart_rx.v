
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.06.2026 11:49:05
// Design Name: 
// Module Name: uart_rx
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

`timescale 1ns / 1ps

module UART_RX #(
    parameter CLKS_PER_BIT = 217
)(
    input  wire       clk,
    input  wire       reset,
    input  wire       rx,

    output reg [7:0]  data_out,
    output reg        data_valid
);

    localparam IDLE      = 3'd0;
    localparam START_BIT = 3'd1;
    localparam DATA_BITS = 3'd2;
    localparam STOP_BIT  = 3'd3;
    localparam CLEANUP   = 3'd4;

    reg [2:0]  state;
    reg [15:0] clk_count;
    reg [2:0]  bit_index;
    reg [7:0]  rx_shift;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state      <= IDLE;
            clk_count  <= 16'd0;
            bit_index  <= 3'd0;
            rx_shift   <= 8'd0;
            data_out   <= 8'd0;
            data_valid <= 1'b0;
        end
        else begin
            data_valid <= 1'b0;

            case (state)

                IDLE: begin
                    clk_count <= 16'd0;
                    bit_index <= 3'd0;

                    if (rx == 1'b0)
                        state <= START_BIT;
                end

                START_BIT: begin
                    if (clk_count < (CLKS_PER_BIT / 2) - 1)
                        clk_count <= clk_count + 1'b1;
                    else begin
                        clk_count <= 16'd0;

                        if (rx == 1'b0)
                            state <= DATA_BITS;
                        else
                            state <= IDLE;
                    end
                end

                DATA_BITS: begin
                    if (clk_count < CLKS_PER_BIT - 1)
                        clk_count <= clk_count + 1'b1;
                    else begin
                        clk_count           <= 16'd0;
                        rx_shift[bit_index] <= rx;

                        if (bit_index < 3'd7)
                            bit_index <= bit_index + 1'b1;
                        else begin
                            bit_index <= 3'd0;
                            state     <= STOP_BIT;
                        end
                    end
                end

                STOP_BIT: begin
                    if (clk_count < CLKS_PER_BIT - 1)
                        clk_count <= clk_count + 1'b1;
                    else begin
                        clk_count <= 16'd0;

                        // Accept data only if the stop bit is valid.
                        if (rx == 1'b1) begin
                            data_out   <= rx_shift;
                            data_valid <= 1'b1;
                        end

                        state <= CLEANUP;
                    end
                end

                CLEANUP: state <= IDLE;

                default: state <= IDLE;
            endcase
        end
    end

endmodule
      