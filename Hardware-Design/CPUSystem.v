`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ITU Computer Engineering Department
// Engineers: Mustafa Bozdo?an, Enes Saçak
// Project Name: BLG222E Project 1 Simulation
//////////////////////////////////////////////////////////////////////////////////

module CPUSystem(Clock, Reset, T, rst);
    input wire Clock;
    input wire Reset;
    output reg [7:0] T;
    output reg rst;
    reg [2:0] RF_OutASel, RF_OutBSel, RF_FunSel;
    reg [3:0] RF_RegSel, RF_ScrSel;
    reg [4:0] ALU_FunSel;
    reg ALU_WF; 
    reg [1:0] ARF_OutCSel, ARF_OutDSel;
    reg [2:0] ARF_FunSel, ARF_RegSel;
    reg IR_LH, IR_Write, Mem_WR, Mem_CS;
    reg [1:0] MuxASel, MuxBSel;
    reg MuxCSel;
    reg [5:0] OPCODE;
    reg [1:0] RSEL;
    reg [7:0] Address;
    reg S;
    reg [2:0] DSTREG, SREG1, SREG2;

    ArithmeticLogicUnitSystem _ALUSystem(.RF_OutASel(RF_OutASel), .RF_OutBSel(RF_OutBSel), .RF_FunSel(RF_FunSel), .RF_RegSel(RF_RegSel), .RF_ScrSel(RF_ScrSel), 
                                        .ALU_FunSel(ALU_FunSel), .ALU_WF(ALU_WF), .ARF_OutCSel(ARF_OutCSel), .ARF_OutDSel(ARF_OutDSel), .ARF_FunSel(ARF_FunSel), 
                                            .ARF_RegSel(ARF_RegSel), .IR_LH(IR_LH), .IR_Write(IR_Write), .Mem_WR(Mem_WR), .Mem_CS(Mem_CS), .MuxASel(MuxASel), .MuxBSel(MuxBSel), .MuxCSel(MuxCSel), .Clock(Clock));

    task GET_SREG1; // we mentioned about tasks in our report there is a complex process behind it but this makes our code shorter
        input [2:0] SREG1, SREG2, DSTREG;
        input [7:0] T;
        input [5:0] OPCODE;
        begin
            case(SREG1)
                3'b000: ARF_OutCSel = 2'b00;
                3'b001: ARF_OutCSel = 2'b00;
                3'b010: ARF_OutCSel = 2'b11;
                3'b011: ARF_OutCSel = 2'b10;
            endcase
            RF_FunSel = 3'b010;
            if (SREG1 == SREG2 && !SREG1[2]) RF_ScrSel = 4'b0011;
            else if (!SREG1[2]) begin
                RF_ScrSel = 4'b0111;
                MuxASel = 2'b01;
            end
            if (SREG1[2]) begin // SREG1 is already there, load SREG2
                if (!SREG2[2]) RF_ScrSel = 4'b1011; // LOAD S2
                GET_SREG2(SREG1, SREG2, DSTREG, T, OPCODE); 
            end
        end
    endtask
    
    task GET_SREG2; // we mentioned about tasks in our report there is a complex process behind it but this makes our code shorter
        input [2:0] SREG1, SREG2, DSTREG;
        input [7:0] T;
        input [5:0] OPCODE;
        begin
            if (SREG1 == SREG2) EXECUTE_ALU(OPCODE, T, SREG1, SREG2, DSTREG);
            else begin
                if (OPCODE > 11 && OPCODE != 14 && OPCODE != 24) begin
                    if (T[2]) begin // SREG1 is already there
                        case(SREG2) // SREG2 is in ARF
                            3'b000: begin
                                ARF_OutCSel = 2'b00;
                                RF_FunSel = 3'b010;
                            end
                            3'b001: begin
                                ARF_OutCSel = 2'b00;
                                RF_FunSel = 3'b010;
                            end
                            3'b010: begin
                                ARF_OutCSel = 2'b11;
                                RF_FunSel = 3'b010;
                            end
                            3'b011: begin
                                ARF_OutCSel = 2'b10;
                                RF_FunSel = 3'b010;
                            end
                        endcase
                        if (SREG2[2]) EXECUTE_ALU(OPCODE, T, SREG1, SREG2, DSTREG); // SREG2 is already there
                        if (!SREG2[2]) MuxASel = 2'b01; // SREG2 is in ARF
                    end
                    else if (T[3] && !(SREG1[2] || SREG2[2])) begin // both of them comes from ARF
                        case(SREG2)
                            3'b000: begin
                                ARF_OutCSel = 2'b00;
                                RF_FunSel = 3'b010;
                            end
                            3'b001: begin
                                ARF_OutCSel = 2'b00;
                                RF_FunSel = 3'b010;
                            end
                            3'b010: begin
                                ARF_OutCSel = 2'b11;
                                RF_FunSel = 3'b010;
                            end
                            3'b011: begin
                                ARF_OutCSel = 2'b10;
                                RF_FunSel = 3'b010;
                            end
                        endcase
                        RF_ScrSel = 4'b1011;
                        MuxASel = 2'b01;
                    end
                    else if (T[3] && (SREG1[2] ^ SREG2[2])) begin
                        RF_ScrSel = 4'b1111;
                        EXECUTE_ALU(OPCODE, T, SREG1, SREG2, DSTREG); // only one of them comes from ARF
                    end
                    else if (T[4] && !(SREG1[2] || SREG2[2])) begin
                        EXECUTE_ALU(OPCODE, T, SREG1, SREG2, DSTREG); // both of them comes from ARF
                        RF_ScrSel = 4'b1111;
                    end
                end
                else begin
                    EXECUTE_ALU(OPCODE, T, SREG1, SREG2, DSTREG);
                    RF_ScrSel = 4'b1111;
                end
            end
        end
    endtask

    task EXECUTE_ALU; // we mentioned about tasks in our report there is a complex process behind it but this makes our code shorter
        input [5:0] OPCODE;
        input [7:0] T;
        input [2:0] SREG1, SREG2, DSTREG;
        begin
            RF_ScrSel = 4'b1111;
            case(SREG1)
                3'b000: RF_OutASel = 3'b100;
                3'b001: RF_OutASel = 3'b100;
                3'b010: RF_OutASel = 3'b100;
                3'b011: RF_OutASel = 3'b100;
                3'b100: RF_OutASel = 3'b000;
                3'b101: RF_OutASel = 3'b001;
                3'b110: RF_OutASel = 3'b010;
                3'b111: RF_OutASel = 3'b011;
            endcase
            case(SREG2)
                3'b000: RF_OutBSel = 3'b101;
                3'b001: RF_OutBSel = 3'b101;
                3'b010: RF_OutBSel = 3'b101;
                3'b011: RF_OutBSel = 3'b101;
                3'b100: RF_OutBSel = 3'b000;
                3'b101: RF_OutBSel = 3'b001;
                3'b110: RF_OutBSel = 3'b010;
                3'b111: RF_OutBSel = 3'b011;
            endcase
            case(OPCODE)
                6'h07: ALU_FunSel = 5'b11011;
                6'h08: ALU_FunSel = 5'b11100;
                6'h09: ALU_FunSel = 5'b11101;
                6'h0a: ALU_FunSel = 5'b11110;
                6'h0b: ALU_FunSel = 5'b11111;
                6'h0c: ALU_FunSel = 5'b10111;
                6'h0d: ALU_FunSel = 5'b11000;
                6'h0f: ALU_FunSel = 5'b11001;
                6'h10: ALU_FunSel = 5'b11010;
                6'h15: ALU_FunSel = 5'b10100;
                6'h16: ALU_FunSel = 5'b10101;
                6'h17: ALU_FunSel = 5'b10110;
                6'h18: ALU_FunSel = 5'b10000;
                6'h19: ALU_FunSel = 5'b10100;
                6'h1a: ALU_FunSel = 5'b10110;
                6'h1b: ALU_FunSel = 5'b10111;
                6'h1c: ALU_FunSel = 5'b11000;
                6'h1d: ALU_FunSel = 5'b11001;
            endcase
            END_OPERATION(DSTREG, OPCODE);
        end
    endtask

    task END_OPERATION; // we mentioned about tasks in our report there is a complex process behind it but this makes our code shorter
        input [2:0] DSTREG;
        input [5:0] OPCODE;
        begin
            case(DSTREG)
                3'b000: ARF_RegSel = 3'b011;
                3'b001: ARF_RegSel = 3'b011;
                3'b010: ARF_RegSel = 3'b110;
                3'b011: ARF_RegSel = 3'b101;
                3'b100: RF_RegSel = 4'b0111;
                3'b101: RF_RegSel = 4'b1011;
                3'b110: RF_RegSel = 4'b1101;
                3'b111: RF_RegSel = 4'b1110;
            endcase
            RF_ScrSel = 4'b1111;
            if (DSTREG[2]) begin
                RF_FunSel = 3'b010; 
                MuxASel = 2'b00;
            end
            if (!DSTREG[2]) begin
                ARF_FunSel = 3'b010; 
                MuxBSel = 2'b00;
            end
        end
    endtask
    always @(*) begin // Reset everything when Reset == 0
        if (!Reset) begin
            ARF_RegSel = 3'b011;
            RF_RegSel = 4'b0000;
            RF_ScrSel = 4'b0000;
            ARF_FunSel = 3'b011;
            RF_FunSel = 3'b011;
            IR_Write = 1'b0;
            Mem_CS = 1'b0;
            Mem_WR = 1'b0;
            ALU_WF = 1'b0;
            T = 1;
        end
    end
    initial begin
        _ALUSystem.RF.R1.Q = 10;
        _ALUSystem.RF.R2.Q = 41;
        _ALUSystem.RF.R3.Q = 257;
        _ALUSystem.RF.R4.Q = 37;
        _ALUSystem.RF.S1.Q = 0;
        _ALUSystem.RF.S2.Q = 0;
        _ALUSystem.RF.S3.Q = 0;
        _ALUSystem.RF.S4.Q = 0;
        _ALUSystem.ARF.PC.Q = 0;
        _ALUSystem.ARF.AR.Q = 121;
        _ALUSystem.ARF.SP.Q = 35;
        IR_Write = 1'b0;
        Mem_CS = 1'b0;
        Mem_WR = 1'b0;
        ALU_WF = 1'b0;
        T = 1;
        rst = 1;
    end 
    always @(posedge Clock) begin
        if (rst) begin
            T = 1;
            RF_RegSel = 4'b1111;
            RF_ScrSel = 4'b1111;
            ARF_RegSel = 3'b111;
            ALU_WF = 0;
            Mem_CS = 1;
            rst = 0;
        end
        else begin
            if (!T[7]) T = T << 1;
            else if (T[7]) T = 1;
        end
    end
    always @(*) begin
        if (Reset) begin
            if (T[0]) begin
                RF_RegSel = 4'b1111;
                RF_ScrSel = 4'b1111;
                ARF_OutDSel = 2'b00;
                Mem_WR = 0;
                Mem_CS = 0;
                IR_LH = 0;
                IR_Write = 1;
                ARF_FunSel = 3'b001;
                ARF_RegSel = 3'b011;
                ALU_WF = 0;
            end
            else if (T[1]) begin
                ARF_OutDSel = 2'b00;
                IR_LH = 1;
                ARF_FunSel = 3'b001;
                ARF_RegSel = 3'b011;
                IR_Write = 1;
            end
        end
    end
    always @(*) begin
        OPCODE = _ALUSystem.IROut[15:10];
        RSEL = _ALUSystem.IROut[9:8];
        Address = _ALUSystem.IROut[7:0];
        S = _ALUSystem.IROut[9];
        DSTREG = _ALUSystem.IROut[8:6];
        SREG1 = _ALUSystem.IROut[5:3];
        SREG2 = _ALUSystem.IROut[2:0];
    end
    always @(*) begin
        if (T[2]) begin
            IR_Write = 0;
            ARF_RegSel = 3'b111;
        end
        case(OPCODE) 
            6'h00, 6'h01, 6'h02: begin
                if (OPCODE == 6'h00 || (OPCODE == 6'h01 && _ALUSystem.ALU.Z == 0) || (OPCODE == 6'h02 && _ALUSystem.ALU.Z == 1)) begin
                    if (T[2]) begin
                        IR_Write = 0;
                        MuxASel = 2'b01;
                        RF_ScrSel = 4'b0111;
                        ARF_OutCSel = 2'b01;
                        RF_FunSel = 3'b010;
                    end
                    else if (T[3]) begin  
                        MuxASel = 2'b11;
                        RF_ScrSel = 4'b1011;
                        RF_FunSel = 3'b111;
                    end
                    else if (T[4]) begin
                        RF_ScrSel = 4'b1111;
                        RF_OutASel = 3'b100;
                        RF_OutBSel = 3'b101;
                        ALU_FunSel = 5'b10100;
                        MuxBSel = 2'b00;
                        ARF_FunSel = 3'b010;
                        ARF_RegSel = 3'b011;
                        rst = 1;
                    end
                end
            end
            6'h03: begin
                if (T[2]) begin
                    ARF_RegSel = 3'b110;
                    RF_ScrSel = 4'b1111;
                    ARF_FunSel = 3'b001;    // increasing sp by one before we read the value
                end
                if (T[3]) begin
                    ARF_OutDSel = 2'b11;
                    Mem_CS = 0;
                    Mem_WR = 0;
                    MuxASel = 2'b10;
                    RF_RegSel = ((4'b1000 >> RSEL) ^ 4'b1111); // loading the LSBits of correct Rx with M[SP + 1]
                    RF_FunSel = 3'b101;
                end
                if (T[4]) begin
                    RF_FunSel = 3'b110; //loading the MSBits of same Rx with M[SP + 2]
                    ARF_RegSel = 3'b111;
                    rst = 1;
                end
            end
            6'h04: begin
                if (T[2]) begin
                    ARF_RegSel = 3'b110;
                    RF_ScrSel = 4'b1111; 
                    ARF_FunSel = 3'b000; // decreasing the SP
                    Mem_CS = 0;
                    Mem_WR = 1;
                    ARF_OutDSel = 2'b11;
                    MuxCSel = 1'b1; // writing the M[SP] with MSBits of correct Rx
                    RF_OutASel = {1'b0, RSEL};
                    ALU_FunSel = 5'b10000;
                end
                if (T[3]) begin
                    MuxCSel = 1'b0; //writing the M[SP - 1] with LSBits of same Rx
                    rst = 1;
                end
            end
            6'h05, 6'h06, 6'h18: begin
                if (T[2]) begin
                    RF_ScrSel = 4'b1111;
                    if (SREG1 == DSTREG && OPCODE != 6'h18) begin
                        case(SREG1)
                            3'b000: ARF_RegSel = 3'b011;
                            3'b001: ARF_RegSel = 3'b011;
                            3'b010: ARF_RegSel = 3'b110;
                            3'b011: ARF_RegSel = 3'b101;
                            3'b100: RF_RegSel = 4'b0111;
                            3'b101: RF_RegSel = 4'b1011;
                            3'b110: RF_RegSel = 4'b1101;
                            3'b111: RF_RegSel = 4'b1110;
                        endcase
                        if (SREG1[2] && OPCODE == 6'h05) RF_FunSel = 3'b001;
                        if (SREG1[2] && OPCODE == 6'h06) RF_FunSel = 3'b000;
                        if (!SREG1[2] && OPCODE == 6'h05) ARF_FunSel = 3'b000;
                        if (!SREG1[2] && OPCODE == 6'h06) ARF_FunSel = 3'b001;
                        rst = 1;
                    end
                    else if (SREG1 == DSTREG && OPCODE == 6'h18) begin
                        ARF_RegSel = 3'b111;
                        RF_ScrSel = 4'b1111; // just in case
                        RF_RegSel = 4'b1111;
                        rst = 1;
                    end
                    else begin
                        if(SREG1[2]) begin
                            RF_OutASel = {1'b0, SREG1[1:0]}; // to choose the correct Rx
                            ALU_FunSel = 5'b10000;
                            ALU_WF = S;  // ALU_WF is dependent on S
                            END_OPERATION(DSTREG, OPCODE); // we mentioned about tasks in our report there is a complex process behind it but this makes our code shorter
                            if (OPCODE == 6'h18) rst = 1; // if the opcode is h18 we just have to move the value we can end here if it is not h18 have have to go to next cycle to increase our value
                        end
                        else begin
                            case(SREG1)
                                3'b000: ARF_OutCSel = 2'b00; 
                                3'b001: ARF_OutCSel = 2'b00; 
                                3'b010: ARF_OutCSel = 2'b11; 
                                3'b011: ARF_OutCSel = 2'b10;
                            endcase
                            END_OPERATION(DSTREG, OPCODE); // we mentioned about tasks in our report there is a complex process behind it but this makes our code shorter
                            if (OPCODE == 6'h18) rst = 1; // if the opcode is h18 we just have to move the value we can end here if it is not h18 have have to go to next cycle to increase our value
                        end
                    end
                end
                else if (T[3]) begin
                    case(DSTREG)
                        3'b000: ARF_RegSel = 3'b011;
                        3'b001: ARF_RegSel = 3'b011;
                        3'b010: ARF_RegSel = 3'b110;
                        3'b011: ARF_RegSel = 3'b101;
                        3'b100: RF_RegSel = 4'b0111;
                        3'b101: RF_RegSel = 4'b1011;
                        3'b110: RF_RegSel = 4'b1101;
                        3'b111: RF_RegSel = 4'b1110;
                    endcase
                    if (SREG1[2] && OPCODE == 6'h05) RF_FunSel = 3'b001;
                    if (SREG1[2] && OPCODE == 6'h06) RF_FunSel = 3'b000;
                    if (!SREG1[2] && OPCODE == 6'h05) ARF_FunSel = 3'b000;
                    if (!SREG1[2] && OPCODE == 6'h06) ARF_FunSel = 3'b001;
                    rst = 1;
                end
            end
            6'h07, 6'h08, 6'h09, 6'h0a, 6'h0b, 6'h0e: begin
                ALU_WF = S;
                if (T[2]) begin
                    GET_SREG1(SREG1, SREG2, DSTREG, T, OPCODE); // we mentioned about tasks in our report there is a complex process behind it but this makes our code shorter
                    if (SREG1[2]) rst = 1; // if SREG1 is in Register File we can restart our clock cycle here
                end
                else if (T[3]) begin
                    GET_SREG2(SREG1, SREG2, DSTREG, T, OPCODE); // we mentioned about tasks in our report there is a complex process behind it but this makes our code shorter
                    rst = 1;
                end
            end
            6'h0c, 6'h0d, 6'h0f, 6'h10, 6'h15, 6'h16, 6'h17, 6'h19, 6'h1a, 6'h1b, 6'h1c, 6'h1d: begin
                ALU_WF = S;
                if (T[2]) begin
                    GET_SREG1(SREG1, SREG2, DSTREG, T, OPCODE); // we mentioned about tasks in our report there is a complex process behind it but this makes our code shorter
                    if (SREG1[2] && SREG2[2]) rst = 1; // if both SREG1 and SREG2 is in Register file we can restart our clock cycle in T[2]
                end
                else if (T[3]) begin
                    GET_SREG2(SREG1, SREG2, DSTREG, T, OPCODE); // we mentioned about tasks in our report there is a complex process behind it but this makes our code shorter
                    if (SREG1[2] ^ SREG2[2]) rst = 1; // if one of our SREGs in ARF and the other one is in RF we can restart our clock cycle in T[3]
                end
                else if (T[4]) begin
                    GET_SREG2(SREG1, SREG2, DSTREG, T, OPCODE); // we mentioned about tasks in our report there is a complex process behind it but this makes our code shorter
                    rst = 1; // if both SREG1 and SREG2 is in ARF we can restart our clock cycle in T[4]
                end
            end
            6'h11, 6'h14: begin
                if (DSTREG[2]) begin
                    MuxASel = 2'b11;
                    if (OPCODE == 6'h11) RF_FunSel = 3'b110;
                    else RF_FunSel = 3'b101;
                    RF_RegSel = ((4'b1000 >> DSTREG[1:0]) ^ 4'b1111); 
                end
                else begin
                    MuxBSel = 2'b11;
                    if (OPCODE == 6'h11) ARF_FunSel = 3'b110;
                    else ARF_FunSel = 3'b101;
                    if (DSTREG[1:0] == 2'b00 || DSTREG[1:0] == 2'b01) ARF_RegSel = 3'b011; 
                    else if (DSTREG[1:0] == 2'b10) ARF_RegSel = 3'b110;
                    else if (DSTREG[1:0] == 2'b11) ARF_RegSel = 3'b101;
                end
                rst = 1;
            end
            6'h12: begin
                if (T[2]) begin
                    ARF_OutDSel = 2'b10;
                    ARF_RegSel = 3'b101;
                    ARF_FunSel = 3'b001;
                    Mem_WR = 0;
                    Mem_CS = 0;
                    MuxASel = 2'b10;
                    RF_FunSel = 3'b101;
                    RF_RegSel = ((4'b1000 >> RSEL) ^ 4'b1111); // to load the correct Rx
                end
                if (T[3]) begin
                    ARF_OutDSel = 2'b10;
                    MuxASel = 2'b10;
                    RF_FunSel = 3'b110;
                    rst = 1;
                end
            end
            6'h13: begin
                if (T[2]) begin
                    ARF_RegSel = 3'b101;
                    ARF_FunSel = 3'b001;
                    ALU_FunSel = 5'b10000;
                    RF_OutASel = {1'b0, RSEL};
                    MuxCSel = 1'b0;
                    Mem_CS = 0;
                    Mem_WR = 1;
                    ARF_OutDSel = 2'b10;
                end
                if (T[3]) begin
                    MuxCSel = 1'b1;
                    rst = 1;
                end
            end
            6'h1e: begin
                if (T[2]) begin
                    ARF_OutCSel = 2'b00;
                    MuxASel = 2'b01;
                    RF_FunSel = 3'b010;
                    RF_ScrSel = 4'b0111; // storing the PC value in S1
                end
                else if (T[3]) begin
                    RF_OutASel = 3'b100;
                    RF_ScrSel = 4'b1111;
                    ALU_FunSel = 5'b10000;
                    MuxCSel = 1'b1;
                    Mem_WR = 1; // writing the MSB bits of PC to M[SP]
                    Mem_CS = 0;
                    ARF_FunSel = 3'b000; // decreasing SP by one since an address in memory can only hold 8-bits
                    ARF_RegSel = 3'b110;
                    ARF_OutDSel = 2'b11;
                end
                else if (T[4]) begin
                    ARF_RegSel = 3'b110;
                    MuxCSel = 1'b0; // writing the LSB bits of PC to M[SP - 1]
                end
                else if (T[5]) begin
                    RF_OutASel = {1'b0, RSEL};
                    Mem_CS = 1;
                    MuxBSel = 2'b00;
                    ARF_RegSel = 3'b011;    // writing the selected RSEL's value over PC
                    ARF_FunSel = 3'b010;
                    rst = 1;
                end
            end
            6'h1f: begin
                if (T[2]) begin
                    ARF_OutDSel = 2'b11;
                    Mem_WR = 0;
                    Mem_CS = 0;
                    MuxBSel = 2'b10;
                    ARF_FunSel = 3'b101; // loading the LSB of PC with M[SP]
                    ARF_RegSel = 3'b011; 
                end
                else if (T[3]) begin
                    ARF_FunSel = 3'b001;
                    ARF_RegSel = 3'b110;  // increasing SP by 1
                end
                else if (T[4]) begin
                    ARF_FunSel = 3'b110;
                    ARF_RegSel = 3'b011;  // loading the MSB of PC with M[SP + 1]
                    rst = 1;
                end
            end
            6'h20: begin
                if (T[2]) begin
                    MuxASel = 2'b11;
                    RF_FunSel = 3'b100;     // loading the selected register with LSB 8-bit of IROut
                    RF_RegSel = ((4'b1000 >> RSEL) ^ 4'b1111); // to choose the correct register's enable
                    RF_ScrSel = 4'b1111;
                    rst = 1;
                end
            end
            6'h21: begin
                if (T[2]) begin
                    ARF_OutCSel = 2'b10;
                    MuxASel = 2'b01;
                    RF_FunSel = 3'b010;
                    RF_ScrSel = 4'b0111;  // loading S1 with AR
                end
                if (T[3]) begin
                    MuxASel = 2'b11;
                    RF_FunSel = 3'b100;
                    RF_ScrSel = 4'b1011;  // loading S2 with OFFSET (LSB 8-bit of IROut i guess)
                end
                if (T[4]) begin
                    RF_OutASel = 3'b100;
                    RF_OutBSel = 3'b101;
                    ALU_FunSel = 5'b10100;  
                    MuxBSel = 2'b00;
                    ARF_FunSel = 3'b010;
                    ARF_RegSel = 3'b101;  // adding them together and writing over AR
                end
                if (T[5]) begin
                    RF_OutASel = {1'b0, RSEL};
                    ALU_FunSel = 5'b10000;
                    MuxCSel = 1'b0;
                    Mem_CS = 0;
                    Mem_WR = 1;
                    ARF_FunSel = 3'b001; // writing it's LSB 8-bit in M[AR + OFFSET] and increasing AR + OFFSET by one since we can only hold 8-bit in some address
                    ARF_OutDSel = 2'b10;
                end
                if (T[6]) begin
                    MuxCSel = 1'b1;         //writing the remainin 8-bit(MSB) to M[AR + OFFSET + 1]
                    ARF_RegSel = 3'b111;
                    rst = 1;
                end
            end
        endcase
    end
endmodule