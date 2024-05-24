`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ITU Computer Engineering Department
// Engineers: Mustafa Bozdoğan, Enes Saçak
// Project Name: BLG222E Project 1 Simulation
//////////////////////////////////////////////////////////////////////////////////
module Register(FunSel, E, I, Q, Clock);
    input wire [2:0] FunSel;
    input wire E, Clock;
    input wire [15:0] I;
    output reg [15:0] Q;
always @(posedge Clock) begin
    if(E == 1)
        case(FunSel)
            3'b000: Q = Q - 1;
            3'b001: Q = Q + 1;
            3'b010: Q = I;
            3'b011: Q = 16'h0;
            3'b100: Q = {{8'd0}, I[7:0]};
            3'b101: Q[7:0] = I[7:0];
            3'b110: Q[15:8] = I[7:0];
            3'b111: Q = {{8{I[7]}}, I[7:0]};
        endcase
    end                
endmodule
