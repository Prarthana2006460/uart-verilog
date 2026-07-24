`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.06.2026 11:13:18
// Design Name: 
// Module Name: UART_tx
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

module UART_TX #(
    parameter CLKS_PER_BIT = 217
)(
    input  wire       clk,
    input  wire       reset,
    input  wire       start,
    input  wire [7:0] data_in,

    output reg        tx,
    output reg        busy
);

    localparam IDLE      = 3'd0;
    localparam START_BIT = 3'd1;
    localparam DATA_BITS = 3'd2;
    localparam STOP_BIT  = 3'd3;
    localparam CLEANUP   = 3'd4;

    reg [2:0]  state;
    reg [15:0] clk_count;
    reg [2:0]  bit_index;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state     <= IDLE;
            tx        <= 1'b1;
            busy      <= 1'b0;
            clk_count <= 16'd0;
            bit_index <= 3'd0;
        end
        else begin
            case (state)

                IDLE: begin
                    tx        <= 1'b1;
                    busy      <= 1'b0;
                    clk_count <= 16'd0;
                    bit_index <= 3'd0;

                    if (start) begin
                        busy  <= 1'b1;
                        state <= START_BIT;
                    end
                end

                START_BIT: begin
                    tx <= 1'b0;

                    if (clk_count < CLKS_PER_BIT - 1)
                        clk_count <= clk_count + 1'b1;
                    else begin
                        clk_count <= 16'd0;
                        bit_index <= 3'd0;
                        tx        <= data_in[0];
                        state     <= DATA_BITS;
                    end
                end

                DATA_BITS: begin
                    if (clk_count < CLKS_PER_BIT - 1)
                        clk_count <= clk_count + 1'b1;
                    else begin
                        clk_count <= 16'd0;

                        if (bit_index < 3'd7) begin
                            bit_index <= bit_index + 1'b1;
                            tx        <= data_in[bit_index + 1'b1];
                        end
                        else begin
                            tx    <= 1'b1;
                            state <= STOP_BIT;
                        end
                    end
                end

                STOP_BIT: begin
                    tx <= 1'b1;

                    if (clk_count < CLKS_PER_BIT - 1)
                        clk_count <= clk_count + 1'b1;
                    else begin
                        clk_count <= 16'd0;
                        state     <= CLEANUP;
                    end
                end

                CLEANUP: begin
                    busy  <= 1'b0;
                    state <= IDLE;
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule
