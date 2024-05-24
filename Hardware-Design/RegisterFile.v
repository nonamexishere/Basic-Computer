`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ITU Computer Engineering Department
// Engineers: Mustafa Bozdoğan, Enes Saçak
// Project Name: BLG222E Project 1 Simulation
//////////////////////////////////////////////////////////////////////////////////
module RegisterFile(I, OutASel, OutBSel, FunSel, RegSel, ScrSel, OutA, OutB, Clock);
    input wire [15:0] I;
    input wire [2:0] OutASel;
    input wire [2:0] OutBSel;
    input wire [2:0] FunSel;
    input wire [3:0] RegSel;
    input wire [3:0] ScrSel;
    input wire Clock;
    output reg [15:0] OutA;
    output reg [15:0] OutB;
    
    wire[15:0] Q1, Q2, Q3, Q4, Q5, Q6, Q7, Q8;
    
    Register R1(.FunSel(FunSel), .I(I), .E(!RegSel[3]), .Q(Q1), .Clock(Clock));
    Register R2(.FunSel(FunSel), .I(I), .E(!RegSel[2]), .Q(Q2), .Clock(Clock));
    Register R3(.FunSel(FunSel), .I(I), .E(!RegSel[1]), .Q(Q3), .Clock(Clock));
    Register R4(.FunSel(FunSel), .I(I), .E(!RegSel[0]), .Q(Q4), .Clock(Clock));
    Register S1(.FunSel(FunSel), .I(I), .E(!ScrSel[3]), .Q(Q5), .Clock(Clock));
    Register S2(.FunSel(FunSel), .I(I), .E(!ScrSel[2]), .Q(Q6), .Clock(Clock));
    Register S3(.FunSel(FunSel), .I(I), .E(!ScrSel[1]), .Q(Q7), .Clock(Clock));
    Register S4(.FunSel(FunSel), .I(I), .E(!ScrSel[0]), .Q(Q8), .Clock(Clock));
    
    always @(*) begin
        case(OutASel)
            3'b000: OutA = Q1;
            3'b001: OutA = Q2;
            3'b010: OutA = Q3;
            3'b011: OutA = Q4;
            3'b100: OutA = Q5;
            3'b101: OutA = Q6;
            3'b110: OutA = Q7;
            3'b111: OutA = Q8;
        endcase
        
        case(OutBSel)
            3'b000: OutB = Q1;
            3'b001: OutB = Q2;
            3'b010: OutB = Q3;
            3'b011: OutB = Q4;
            3'b100: OutB = Q5;
            3'b101: OutB = Q6;
            3'b110: OutB = Q7;
            3'b111: OutB = Q8;
        endcase
    end
endmodule