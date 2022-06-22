// // 109550018 郭昀
// module Hazard(
// 	RSaddr_i,
// 	RTaddr_i,
// 	RSaddr_s3_i,
// 	RTaddr_s3_i,
// 	RSaddr_s4_i,
// 	RTaddr_s4_i,
// 	Branch_i,
// 	MemRead_i,
// 	Branch_s3_i,
// 	MemRead_s3_i,
// 	MemRead_s4_i,
// 	BranchType,
// 	Stall_o
// );

// // I/O ports
// input [4:0] RSaddr_i, RSaddr_s3_i, RSaddr_s4_i;
// input [4:0] RTaddr_i, RTaddr_s3_i, RTaddr_s4_i;
// input MemRead_i, MemRead_s3_i, MemRead_s4_i, Branch_i, Branch_s3_i;
// input [2-1:0] BranchType;
// output reg Stall_o;

// // Main function
// always @(*) begin
// 	Stall_o <= 0;

// 	if (((RSaddr_i == RTaddr_s3_i) | (RTaddr_i == RTaddr_s3_i)) & MemRead_i)
// 		Stall_o <= 1;

// 	if (((RSaddr_i == RSaddr_s3_i) | (RTaddr_i == RSaddr_s3_i)
// 	   | (RSaddr_i == RTaddr_s3_i) | (RTaddr_i == RTaddr_s3_i)) & MemRead_s3_i & Branch_i)
// 		Stall_o <= 1;

// 	if (((RSaddr_i == RSaddr_s4_i) | (RTaddr_i == RSaddr_s4_i)
// 	   | (RSaddr_i == RTaddr_s4_i) | (RTaddr_i == RTaddr_s4_i)) & MemRead_s4_i & Branch_i)
// 		Stall_o <= 1;

	
// end

// endmodule

module Hazard(
	MemRead_s3, 
    RegisterRs, 
    RegisterRt, 
    RegisterRt_s3,
	branch, 
	pc_stall, 
	ID_stall, 
	IF_flush, 
	ID_flush, 
	EX_flush
);

// I/O ports
input [4:0] RegisterRs, RegisterRt, RegisterRt_s3;
input MemRead_s3, branch;
output reg pc_stall, ID_stall, IF_flush, ID_flush, EX_flush;

// Main function
always @(*) begin
	{ pc_stall, ID_stall, IF_flush, ID_flush, EX_flush } = 5'b00000;

	if (MemRead_s3 && ((RegisterRt_s3 == RegisterRs) || (RegisterRt_s3 == RegisterRt))) 
		{ pc_stall, ID_stall, ID_flush } = 3'b111;
	
		
	if (branch)
		{ IF_flush, ID_flush, EX_flush } = 3'b111;
end

endmodule