`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ITU Computer Engineering Department
// Engineers: Mustafa Bozdoğan, Enes Saçak
// Project Name: BLG222E Project 1 Simulation
//////////////////////////////////////////////////////////////////////////////////
module ArithmeticLogicUnitSystem(RF_OutASel, RF_OutBSel, RF_FunSel, RF_RegSel, RF_ScrSel, 
                                        ALU_FunSel, ALU_WF, ARF_OutCSel, ARF_OutDSel, ARF_FunSel, 
                                            ARF_RegSel, IR_LH, IR_Write, Mem_WR, Mem_CS, MuxASel, MuxBSel, MuxCSel, Clock);

    input wire [2:0] RF_OutASel, RF_OutBSel, RF_FunSel;
    input wire [3:0] RF_RegSel, RF_ScrSel;
    input wire [4:0] ALU_FunSel;
    input wire ALU_WF; 
    input wire [1:0] ARF_OutCSel, ARF_OutDSel;
    input wire [2:0] ARF_FunSel, ARF_RegSel;
    input wire IR_LH, IR_Write, Mem_WR, Mem_CS;
    input wire [1:0] MuxASel, MuxBSel;
    input wire MuxCSel;
    input wire Clock;

    reg [15:0] MuxAOut, MuxBOut;
    reg [7:0] MuxCOut;

    wire [15:0] OutA, OutB;

    wire [15:0] ALUOut;
    wire [3:0] FlagsOut;

    wire [15:0] OutC, Address;

    wire [15:0] IROut;

    wire [7:0] MemOut;

    Memory MEM(.Address(Address), .CS(Mem_CS), .WR(Mem_WR), .Data(MuxCOut), .Clock(Clock), .MemOut(MemOut));

    RegisterFile RF(.I(MuxAOut), .OutASel(RF_OutASel), .OutBSel(RF_OutBSel), 
                    .FunSel(RF_FunSel), .RegSel(RF_RegSel), .ScrSel(RF_ScrSel), 
                    .Clock(Clock), .OutA(OutA), .OutB(OutB));

    ArithmeticLogicUnit ALU(.A(OutA), .B(OutB), .FunSel(ALU_FunSel), .WF(ALU_WF), 
                            .Clock(Clock), .ALUOut(ALUOut), .FlagsOut(FlagsOut));

    AddressRegisterFile ARF(.I(MuxBOut), .OutCSel(ARF_OutCSel), .OutDSel(ARF_OutDSel), 
                    .FunSel(ARF_FunSel), .RegSel(ARF_RegSel), .Clock(Clock), 
                    .OutC(OutC), .OutD(Address));

    InstructionRegister IR(.I(MemOut), .Write(IR_Write), .LH(IR_LH), 
                            .Clock(Clock), .IROut(IROut));


    always @(*) begin
        case(MuxASel)
            2'b00: MuxAOut = ALUOut;
            2'b01: MuxAOut = OutC;
            2'b10: MuxAOut = {8'h00, MemOut};
            2'b11: MuxAOut = {8'h00, IROut[7:0]};
        endcase
    end

    always @(*) begin
        case(MuxBSel)
            2'b00: MuxBOut = ALUOut;
            2'b01: MuxBOut = OutC;
            2'b10: MuxBOut = {8'h00, MemOut};
            2'b11: MuxBOut = {8'h00, IROut[7:0]};
        endcase
    end

    always @(*) begin
        case(MuxCSel)
            1'b0: MuxCOut = ALUOut[7:0];
            1'b1: MuxCOut = ALUOut[15:8];
        endcase
    end
endmodule