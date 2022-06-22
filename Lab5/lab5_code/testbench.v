`timescale 1ns / 1ps

`define CYCLE_TIME 10	
`define MAX_COUNT 64

module TestBench;

//Internal Signals
reg         CLK;
reg         RST;
integer     count;
integer     i;
//integer     handle;
wire [32-1:0] pc_pre, pc, pc_next0;
wire [32-1:0] instruction;

//control signal
wire branch_select;

/**** ID stage ****/
wire [32-1:0] pc_next0_s2, instruction_s2, rsData, rtData, signExtended;

//control signal
wire MemtoReg, regDst, regWrite, branch, ALUsrc, Jump, MemRead, MemWrite;
wire [2-1:0] BranchType;
wire [3-1:0] ALUop;

/**** EX stage ****/
wire [32-1:0] pc_next0_s3, leftShifted, pc_next1_s3;
wire [32-1:0] rsData_s3, rtData_s3, MUX_ALUsrc, ALUresult;
wire zero;
wire [32-1:0] signExtended_s3;
wire [4-1:0] ALUcontrol;
wire [32-1:0] Instruction_s3;
wire [5-1:0] writeReg1;

//control signal
wire MemtoReg_s3, regDst_s3, regWrite_s3, branch_s3, ALUsrc_s3, MemRead_s3, MemWrite_s3;
wire [3-1:0] ALUop_s3;

/**** MEM stage ****/
wire [32-1:0] pc_next1_s4;
wire zero_s4;
wire [32-1:0] ALUresult_s4, ReadData;
wire [5-1:0] writeReg1_s4;

//control signal
wire MemtoReg_s4, regWrite_s4, branch_s4, MemRead_s4, MemWrite_s4;

/**** WB stage ****/
wire [32-1:0] ReadData_s5, ALUresult_s5, toReg;
wire [5-1:0] writeReg1_s5;

//control signal
wire MemtoReg_s5, regWrite_s5;

// New Add
wire pc_stall, ID_stall; 
wire MemtoReg_s2, regDst_s2, regWrite_s2, branch_s2, ALUsrc_s2, MemRead_s2, MemWrite_s2;
wire [3-1:0] ALUop_s2;
wire MemtoReg_s33, regWrite_s33, branch_s33, MemRead_s33, MemWrite_s33;
wire [2-1:0] ForwardA, ForwardB;
wire [32-1:0] ALU_rs, ALU_rt, ALU_rt_s4;
wire [32-1:0] instruction_s4;
wire Branch_new, Branch_new_s4;
wire [2-1:0] BranchType_s2, BranchType_s3, BranchType_s33, BranchType_s4;
wire IF_flush, ID_flush, EX_flush;

//Greate tested modle  
Pipe_CPU_1 cpu(
    .clk_i(CLK),
    .rst_i(RST),
    .pc_pre(pc_pre), .pc(pc), .pc_next0(pc_next0), .instruction(instruction), .branch_select(branch_select),
    .pc_next0_s2(pc_next0_s2), .instruction_s2(instruction_s2), .rsData(rsData), .rtData(rtData), .signExtended(signExtended), 
    .MemtoReg(MemtoReg), .regDst(regDst), .regWrite(regWrite), .branch(branch), .ALUsrc(ALUsrc), .Jump(Jump), .MemRead(MemRead), .MemWrite(MemWrite), 
    .BranchType(BranchType), .ALUop(ALUop), .pc_next0_s3(pc_next0_s3), .leftShifted(leftShifted), .pc_next1_s3(pc_next1_s3), 
    .rsData_s3(rsData_s3), .rtData_s3(rtData_s3), .MUX_ALUsrc(MUX_ALUsrc), .ALUresult(ALUresult), 
    .zero(zero), .signExtended_s3(signExtended_s3), .ALUcontrol(ALUcontrol), .Instruction_s3(Instruction_s3), .writeReg1(writeReg1), 
    .MemtoReg_s3(MemtoReg_s3), .regDst_s3(regDst_s3), .regWrite_s3(regWrite_s3), .branch_s3(branch_s3), .ALUsrc_s3(ALUsrc_s3), .MemRead_s3(MemRead_s3), .MemWrite_s3(MemWrite_s3),
    .ALUop_s3(ALUop_s3), .pc_next1_s4(pc_next1_s4), .zero_s4(zero_s4), .ALUresult_s4(ALUresult_s4), .ReadData(ReadData),
    .writeReg1_s4(writeReg1_s4), .MemtoReg_s4(MemtoReg_s4), .regWrite_s4(regWrite_s4), .branch_s4(branch_s4), .MemRead_s4(MemRead_s4), .MemWrite_s4(MemWrite_s4), 
    .ReadData_s5(ReadData_s5), .ALUresult_s5(ALUresult_s5), .toReg(toReg), .writeReg1_s5(writeReg1_s5),
    .MemtoReg_s5(MemtoReg_s5), .regWrite_s5(regWrite_s5), 
    .pc_stall(pc_stall),.ID_stall(ID_stall), .MemtoReg_s2(MemtoReg_s2), .regDst_s2(regDst_s2), .regWrite_s2(regWrite_s2), .branch_s2(branch_s2), 
    .ALUsrc_s2(ALUsrc_s2), .MemRead_s2(MemRead_s2), .MemWrite_s2(MemWrite_s2),
    .ALUop_s2(ALUop_s2), .MemtoReg_s33(MemtoReg_s33), .regWrite_s33(regWrite_s33), .branch_s33(branch_s33), 
    .MemRead_s33(MemRead_s33), .MemWrite_s33(MemWrite_s33), .ForwardA(ForwardA), .ForwardB(ForwardB), 
    .ALU_rs(ALU_rs), .ALU_rt(ALU_rt), .ALU_rt_s4(ALU_rt_s4), .instruction_s4(instruction_s4), .Branch_new(Branch_new), .BranchType_s2(BranchType_s2), 
    .BranchType_s3(BranchType_s3), .BranchType_s33(BranchType_s33), .BranchType_s4(BranchType_s4),
    .Branch_new_s4(Branch_new_s4), .IF_flush(IF_flush), .ID_flush(ID_flush), .EX_flush(EX_flush)
    );


 
//Main function

always #(`CYCLE_TIME/2) CLK = ~CLK;	

initial begin
    //handle = $fopen("P4_Result.dat");
    CLK = 0;
    RST = 0;
    count = 0;
   
    // instruction memory
    for(i=0; i<32; i=i+1)
    begin
        cpu.IM.instruction_file[i] = 32'b0;
    end

    $readmemb("CO_P5_test_2.txt", cpu.IM.instruction_file);  //Read instruction from "CO_P4_test_1.txt"   
    
    // data memory
    for(i=0; i<128; i=i+1)
    begin
        cpu.DM.Mem[i] = 8'b0;
    end
    
    #(`CYCLE_TIME)      RST = 1;
    #(`CYCLE_TIME*`MAX_COUNT)   $stop;
    //#(`CYCLE_TIME*20)	$fclose(handle); $stop;
end

//Print result to "CO_P4_Result.dat"
always@(posedge CLK) begin
    

    //print result to transcript 
	$display("################################## clk_count =%-3d#####################################",count);
    $display("=======================================Register=======================================");
	
    $display("r0 =%-5d, r1 =%-5d, r2 =%-5d, r3 =%-5d, r4 =%-5d, r5 =%-5d, r6 =%-5d, r7 =%-5d\n",
    cpu.RF.Reg_File[0], cpu.RF.Reg_File[1], cpu.RF.Reg_File[2], cpu.RF.Reg_File[3], cpu.RF.Reg_File[4], 
    cpu.RF.Reg_File[5], cpu.RF.Reg_File[6], cpu.RF.Reg_File[7],
    );
    $display("r8 =%-5d, r9 =%-5d, r10=%-5d, r11=%-5d, r12=%-5d, r13=%-5d, r14=%-5d, r15=%-5d\n",
    cpu.RF.Reg_File[8], cpu.RF.Reg_File[9], cpu.RF.Reg_File[10], cpu.RF.Reg_File[11], cpu.RF.Reg_File[12], 
    cpu.RF.Reg_File[13], cpu.RF.Reg_File[14], cpu.RF.Reg_File[15],
    );
    $display("r16=%-5d, r17=%-5d, r18=%-5d, r19=%-5d, r20=%-5d, r21=%-5d, r22=%-5d, r23=%-5d\n",
    cpu.RF.Reg_File[16], cpu.RF.Reg_File[17], cpu.RF.Reg_File[18], cpu.RF.Reg_File[19], cpu.RF.Reg_File[20], 
    cpu.RF.Reg_File[21], cpu.RF.Reg_File[22], cpu.RF.Reg_File[23],
    );
    $display("r24=%-5d, r25=%-5d, r26=%-5d, r27=%-5d, r28=%-5d, r29=%-5d, r30=%-5d, r31=%-5d\n",
    cpu.RF.Reg_File[24], cpu.RF.Reg_File[25], cpu.RF.Reg_File[26], cpu.RF.Reg_File[27], cpu.RF.Reg_File[28], 
    cpu.RF.Reg_File[29], cpu.RF.Reg_File[30], cpu.RF.Reg_File[31]
    );

    $display("========================================Memory========================================");
    $display("m0 =%-5d, m1 =%-5d, m2 =%-5d, m3 =%-5d, m4 =%-5d, m5 =%-5d, m6 =%-5d, m7 =%-5d\n\nm8 =%-5d, m9 =%-5d, m10=%-5d, m11=%-5d, m12=%-5d, m13=%-5d, m14=%-5d, m15=%-5d\n\nm16=%-5d, m17=%-5d, m18=%-5d, m19=%-5d, m20=%-5d, m21=%-5d, m22=%-5d, m23=%-5d\n\nm24=%-5d, m25=%-5d, m26=%-5d, m27=%-5d, m28=%-5d, m29=%-5d, m30=%-5d, m31=%-5d\n",							 
            cpu.DM.memory[0], cpu.DM.memory[1], cpu.DM.memory[2], cpu.DM.memory[3],
            cpu.DM.memory[4], cpu.DM.memory[5], cpu.DM.memory[6], cpu.DM.memory[7],
            cpu.DM.memory[8], cpu.DM.memory[9], cpu.DM.memory[10], cpu.DM.memory[11],
            cpu.DM.memory[12], cpu.DM.memory[13], cpu.DM.memory[14], cpu.DM.memory[15],
            cpu.DM.memory[16], cpu.DM.memory[17], cpu.DM.memory[18], cpu.DM.memory[19],
            cpu.DM.memory[20], cpu.DM.memory[21], cpu.DM.memory[22], cpu.DM.memory[23],
            cpu.DM.memory[24], cpu.DM.memory[25], cpu.DM.memory[26], cpu.DM.memory[27],
            cpu.DM.memory[28], cpu.DM.memory[29], cpu.DM.memory[30], cpu.DM.memory[31]
            );
	count = count + 1;
end
  
endmodule

