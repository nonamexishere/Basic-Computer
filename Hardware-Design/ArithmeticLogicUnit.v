`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ITU Computer Engineering Department
// Engineers: Mustafa Bozdoğan, Enes Saçak
// Project Name: BLG222E Project 1 Simulation
//////////////////////////////////////////////////////////////////////////////////
module ArithmeticLogicUnit(A, B, FunSel, FlagsOut, WF, ALUOut, Clock);
    input wire [15:0] A;
    input wire [15:0] B;
    input wire [4:0] FunSel;
    input wire WF, Clock;
    output reg [15:0] ALUOut;
    output reg [3:0] FlagsOut;

    reg Z;
    reg C;
    reg N;
    reg O;
    
    always @(*) begin
        Z = FlagsOut[3];
        C = FlagsOut[2];
        N = FlagsOut[1];
        O = FlagsOut[0];
        case(FunSel)
            5'b00000: ALUOut = {8'h00, A[7:0]}; // A 8-bit
            5'b00001: ALUOut = {8'h00, B[7:0]}; // B 8-bit
            5'b00010: ALUOut = {8'h00, ~A[7:0]}; // NOT A 8-bit
            5'b00011: ALUOut = {8'h00, ~B[7:0]}; // NOT B 8-bit
            5'b00100: begin // A + B 8-bit addition
                {C, ALUOut[7:0]} = {1'b0, A[7:0]} + {1'b0, B[7:0]};
                ALUOut = {8'h00, ALUOut[7:0]};
                O = ((A[7] & B[7]) & ~ALUOut[7]) | ((~A[7] & ~B[7]) & ALUOut[7]);
            end
            5'b00101: begin // A + B + Carry 8-bit addition with carry
                {C, ALUOut[7:0]} = {1'b0, A[7:0]} + {1'b0, B[7:0]} + FlagsOut[2];
                ALUOut = {8'h00, ALUOut[7:0]};
                O = ((A[7] & B[7]) & ~ALUOut[7]) | ((~A[7] & ~B[7]) & ALUOut[7]);
            end
            5'b00110: begin // A - B 8-bit subtraction
                ALUOut[8:0] = {1'b0, A[7:0]} + {1'b0, ~B[7:0]} + 1;
                C = ~ALUOut[8];
                ALUOut = {8'h00, ALUOut[7:0]};
                O = ((A[7] & ~B[7]) & ~ALUOut[7]) | ((~A[7] & B[7]) & ALUOut[7]);
            end
            5'b00111: ALUOut = {8'h00, (A[7:0] & B[7:0])}; // A AND B 8-bit AND
            5'b01000: ALUOut = {8'h00, (A[7:0] | B[7:0])}; // A OR B 8-bit OR
            5'b01001: ALUOut = {8'h00, (A[7:0] ^ B[7:0])}; // A XOR B 8-bit XOR
            5'b01010: ALUOut = {8'h00, ~(A[7:0] & B[7:0])}; // A NAND B 8-bit NAND
            5'b01011: {ALUOut[15:8], C, ALUOut[7:0]} = {8'h00, A[7:0], 1'b0}; // 8-bit Logical Shift Left
            5'b01100: {ALUOut, C} = {8'h00, A[7:0], 1'b0} >> 1; // 8-bit Logical Shift Right
            5'b01101: {ALUOut, C} = {8'h00, A[7], A[7:0]}; // 8-bit Arithmetic Shift Right
            5'b01110: {ALUOut[15:8], C, ALUOut[7:0]} = {8'h00, A[7:0], FlagsOut[2]}; // 8-bit Circular Shift Left
            5'b01111: {ALUOut, C} = {8'h00, FlagsOut[2], A[7:0]}; // 8-bit Circular Shift Right
            5'b10000: ALUOut = A; // 16-bit A
            5'b10001: ALUOut = B; // 16-bit B
            5'b10010: ALUOut = ~A; // 16-bit NOT A
            5'b10011: ALUOut = ~B; // 16-bit NOT B
            5'b10100: begin // A + B 16-bit addition
                {C, ALUOut} = {1'b0, A} + {1'b0, B};
                O = (A[15] & B[15] & ~ALUOut[15]) | (~A[15] & ~B[15] & ALUOut[15]);
            end
            5'b10101: begin // A + B + Carry 16-bit addition with carry
                {C, ALUOut} = {1'b0, A} + {1'b0, B} + FlagsOut[2];
                O = (A[15] & B[15] & ~ALUOut[15]) | (~A[15] & ~B[15] & ALUOut[15]);
            end
            5'b10110: begin // A - B 16-bit subtraction
                {C, ALUOut} = {1'b0, A} + {1'b0, ~B} + 1;
                C = ~C;
                O = (A[15] & ~B[15] & ~ALUOut[15]) | (~A[15] & B[15] & ALUOut[15]);
            end
            5'b10111: ALUOut = A & B; // A AND B 16-bit AND
            5'b11000: ALUOut = A | B; // A OR B 16-bit OR
            5'b11001: ALUOut = A ^ B; // A XOR B 16-bit XOR
            5'b11010: ALUOut = ~(A & B); // A NAND B 16-bit NAND
            5'b11011: {C, ALUOut} = {1'b0, A} << 1; // 16-bit Logical Shift Left
            5'b11100: {ALUOut, C} = {A, 1'b0} >> 1; // 16-bit Logical Shift Right
            5'b11101: {ALUOut, C} = {A[15], A}; // 16-bit Arithmetic Shift Right
            5'b11110: {C, ALUOut} = {A, FlagsOut[2]}; // 16-bit Circular Shift Left
            5'b11111: {ALUOut, C} = {FlagsOut[2], A}; // 16-bit Circular Shift Right
        endcase
        Z = (ALUOut == 16'h0000);
        if (FunSel[4] == 1 && FunSel != 5'b11101) N = ALUOut[15];
        if (FunSel[4] == 0 && FunSel != 5'b01101) N = ALUOut[7];
    end
    always @(posedge Clock) begin
        if(WF == 1) FlagsOut = {Z, C, N, O};
    end
endmodule  
