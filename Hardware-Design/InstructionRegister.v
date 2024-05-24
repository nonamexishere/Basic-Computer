`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ITU Computer Engineering Department
// Engineers: Mustafa Bozdoğan, Enes Saçak
// Project Name: BLG222E Project 1 Simulation
//////////////////////////////////////////////////////////////////////////////////
module InstructionRegister(LH, Write, I, IROut, Clock);
    input wire LH;
    input wire Write, Clock;
    input wire [7:0] I;
    output reg [15:0] IROut;
    always @(posedge Clock) begin
        if (Write == 1)
            case(LH)
                1'b0: begin
                        IROut[7:0] = I;
                    end
                1'b1: begin
                        IROut[15:8] = I;
                    end
            endcase
    end    
endmodule
