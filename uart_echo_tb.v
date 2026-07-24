`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.07.2026 11:40:44
// Design Name: 
// Module Name: uart_echo_tb
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

module uart_echo_tb;

    parameter CLKS_PER_BIT = 217;
    parameter CLK_PERIOD   = 40;

    reg       clk;
    reg       reset;
    reg       pc_start;
    reg [7:0] pc_data;

    wire       pc_busy;
    wire       pc_to_fpga;
    wire       fpga_to_pc;
    wire [7:0] received_data;
    wire       received_valid;

    // Simulated PC transmitter
    UART_TX #(
        .CLKS_PER_BIT(CLKS_PER_BIT)
    ) PC_TX (
        .clk(clk),
        .reset(reset),
        .start(pc_start),
        .data_in(pc_data),
        .tx(pc_to_fpga),
        .busy(pc_busy)
    );

    // FPGA echo design
    uart_echo #(
        .CLKS_PER_BIT(CLKS_PER_BIT)
    ) DUT (
        .clk(clk),
        .reset(reset),
        .uart_rx_pin(pc_to_fpga),
        .uart_tx_pin(fpga_to_pc)
    );

    // Simulated PC receiver
    UART_RX #(
        .CLKS_PER_BIT(CLKS_PER_BIT)
    ) PC_RX (
        .clk(clk),
        .reset(reset),
        .rx(fpga_to_pc),
        .data_out(received_data),
        .data_valid(received_valid)
    );

    initial clk = 1'b0;
    always #(CLK_PERIOD / 2) clk = ~clk;

    task SEND_TO_FPGA;
        input [7:0] data;
        begin
            @(negedge clk);
            pc_data  = data;
            pc_start = 1'b1;

            @(negedge clk);
            pc_start = 1'b0;

            wait (pc_busy == 1'b1);
            wait (pc_busy == 1'b0);

            // Wait for the echoed byte before sending another.
            @(posedge received_valid);

            #1;
            if (received_data == data)
                $display("PASS: %c echoed correctly", data);
            else
                $display("FAIL: sent %h, received %h", data, received_data);
        end
    endtask

    initial begin
        reset    = 1'b1;
        pc_start = 1'b0;
        pc_data  = 8'h00;

        #200;
        reset = 1'b0;

        SEND_TO_FPGA("h"); // 
        SEND_TO_FPGA("i");
        SEND_TO_FPGA("i"); 
        SEND_TO_FPGA("!");
         SEND_TO_FPGA("!"); // !

        #1000;
        $finish;
    end

endmodule