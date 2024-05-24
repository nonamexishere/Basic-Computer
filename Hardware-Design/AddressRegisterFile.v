`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ITU Computer Engineering Department
// Engineers: Mustafa Bozdoğan, Enes Saçak
// Project Name: BLG222E Project 1 Simulation
//////////////////////////////////////////////////////////////////////////////////
module AddressRegisterFile(I, OutCSel, OutDSel, FunSel, RegSel, OutC, OutD, Clock);
    input wire [15:0] I;
    input wire [1:0] OutCSel;
    input wire [1:0] OutDSel;
    input wire [2:0] FunSel;
    input wire [2:0] RegSel;
    input wire Clock;	
    output reg [15:0] OutC;
    output reg [15:0] OutD;
    
    wire [15:0] Q1, Q2, Q3;

    Register PC(.I(I), .FunSel(FunSel), .E(!RegSel[2]), .Q(Q1), .Clock(Clock));
    Register AR(.I(I), .FunSel(FunSel), .E(!RegSel[1]), .Q(Q2), .Clock(Clock));
    Register SP(.I(I), .FunSel(FunSel), .E(!RegSel[0]), .Q(Q3), .Clock(Clock));

    always @(*) begin
        case(OutCSel)
            2'b00: OutC = Q1;
            2'b01: OutC = Q1;
            2'b10: OutC = Q2;
            2'b11: OutC = Q3;
        endcase
        case(OutDSel)
            2'b00: OutD = Q1;
            2'b01: OutD = Q1;
            2'b10: OutD = Q2;
            2'b11: OutD = Q3;
        endcase
    end
endmodule
