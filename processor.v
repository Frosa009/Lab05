//=========================================================================
// Name & Email must be EXACTLY as in Gradescope roster!
// Name: 
// Email: 
// 
// Assignment name: 
// Lab section: 
// TA: 
// 
// I hereby certify that I have not received assistance on this assignment,
// or used code, from ANY outside source other than the instruction team
// (apart from what was provided in the starter file).
//
//=========================================================================

`timescale 1ns / 1ps

module processor #(parameter WORD_SIZE=32,MEM_FILE="init.coe") (
    input clk,
    input rst,   
	 // Debug signals 
    output reg[WORD_SIZE-1:0] prog_count, 
    output reg[5:0] instr_opcode,
    output reg[4:0] reg1_addr,
    output reg[WORD_SIZE-1:0] reg1_data,
    output reg[4:0] reg2_addr,
    output reg[WORD_SIZE-1:0] reg2_data,
    output reg[4:0] write_reg_addr,
    output reg[WORD_SIZE-1:0] write_reg_data 
);

// ----------------------------------------------
// Insert solution below here
// ----------------------------------------------

reg[WORD_SIZE-1:0] progC;
reg[5:0] instrOP;
reg[4:0] reg1A;
reg[WORD_SIZE-1:0] reg1D;
reg[4:0] reg2A;
reg[WORD_SIZE-1:0] reg2D;
reg[4:0] writeRA;
reg[WORD_SIZE-1:0] writeRD; 

wire [WORD_SIZE-1:0] pc_in;
wire [WORD_SIZE-1:0] pc_out; 
wire [WORD_SIZE-1:0] pc_add_4; 
wire [WORD_SIZE-1:0] instr; 
wire [WORD_SIZE-1:0] read_data1; 
wire [WORD_SIZE-1:0] read_data2; 
wire [WORD_SIZE-1:0] mem_data; 
wire [WORD_SIZE-1:0] reg_write_data; 
wire [WORD_SIZE-1:0] pc_offset; 
wire [WORD_SIZE-1:0] alusrc_mux; 
wire [WORD_SIZE-1:0] alu_result; 
wire [WORD_SIZE-1:0] write_reg; 
wire [WORD_SIZE-1:0] branch_addr; 
wire [WORD_SIZE-1:0] imme;
wire [4:0] write_reg1; 
wire [4:0] write_reg2;
wire [1:0] alu_op;
wire [3:0] alu_out;
wire reg_dst;
wire branch;
wire mem_read;
wire mem_to_reg;
wire mem_write;
wire alu_src;
wire reg_write;
wire zero;

assign write_reg1 = instr[20:16];
assign write_reg2 = instr[15:11];
assign imme = {{16{instr[15]}}, instr[15:0]};
assign branch_zero = zero & branch;

gen_register PC(
    .clk(clk),
    .rst(rst),
    .write_en(1'b1),
    .data_in(pc_in),
    .data_out(pc_out)
);

cpumemory #(.FILENAME(MEM_FILE)) instr_mem_data_mem(
    .clk(clk),
    .rst(rst),
    .instr_read_address(pc_out[9:2]),
    .instr_instruction(instr),
    .data_mem_write(mem_write),
    .data_address(alu_result[7:0]),
    .data_write_data(read_data2),
    .data_read_data(mem_data)
);

alu pc_add(
    .alu_control_in(`ALU_ADD),
    .channel_a_in(pc_out),
    .channel_b_in(4),
    .alu_result_out(pc_add_4)
);

control_unit control_unit(
    .instr_op(instr[31:26]),
    .reg_dst(reg_dst),
    .branch(branch),
    .mem_read(),
    .mem_to_reg(mem_to_reg),
    .alu_op(alu_op),
    .mem_write(mem_write),
    .alu_src(alu_src),
    .reg_write(reg_write)
);

mux_2_1 mux_reg_dst(
    .select_in(reg_dst),
    .datain1({{27{1'b0}}, write_reg1}),
    .datain2({{27{1'b0}}, write_reg2}),
    .data_out(write_reg)
);

cpu_registers Register(
    .clk(clk),
    .rst(rst),
    .reg_write(reg_write),
    .read_register_1(instr[25:21]),
    .read_register_2(instr[20:16]),
    .write_register(write_reg[4:0]),
    .write_data(reg_write_data),
    .read_data_1(read_data1),
    .read_data_2(read_data2)
);

mux_2_1 mux_alusrc(
    .select_in(alu_src),
    .datain1(read_data2),
    .datain2(imme),
    .data_out(alusrc_mux)
);

alu_control alu_control(
    .alu_op(alu_op),
    .instruction_5_0(instr[5:0]),
    .alu_out(alu_out)
);

alu alu(
    .alu_control_in(alu_out),
    .channel_a_in(read_data1),
    .channel_b_in(alusrc_mux),
    .zero_out(zero),
    .alu_result_out(alu_result)
);

alu alu_branch(
    .alu_control_in(`ALU_ADD),
    .channel_a_in(pc_add_4),
    .channel_b_in(imme),
    .alu_result_out(branch_addr)
);

mux_2_1 mux_branch(
    .select_in(branch_zero),
    .datain1(pc_add_4),
    .datain2(branch_addr),
    .data_out(pc_in)
);

mux_2_1 mux_to_reg(
    .select_in(mem_to_reg),
    .datain1(alu_result),
    .datain2(mem_data),
    .data_out(reg_write_data)
);

always @(*) begin
   /* progC <= {pc_out[31:2], 2'b00};
    instrOP <= instr[31:26];
    reg1A <= instr[25:21];
    reg1D <= read_data1;
    reg2A <= instr[20:16];
    reg2D <= read_data2;
    writeRA <= write_reg[4:0];
    writeRD <= reg_write_data;    

    prog_count <= progC;
    instr_opcode <= instrOP;
    reg1_addr <= reg1A;
    reg1_data <= reg1D;
    reg2_addr <= reg2A;
    reg2_data <= reg2D;
    write_reg_addr <= writeRA;
    write_reg_data <= writeRD;*/
    
    prog_count <= {pc_out[31:2], 2'b00};
    instr_opcode <= instr[31:26];
    reg1_addr <= instr[25:21];
    reg1_data <= read_data1;
    reg2_addr <= instr[20:16];
    reg2_data <= read_data2;
    write_reg_addr <= write_reg[4:0];
    write_reg_data <= reg_write_data;  
end

    /*prog_count <= {pc_out[31:2], 2'b00};
    instr_opcode <= instr[31:26];
    reg1_addr <= instr[25:21];
    reg1_data <= read_data1;
    reg2_addr <= instr[20:16];
    reg2_data <= read_data2;
    write_reg_addr <= write_reg[4:0];
    write_reg_data <= reg_write_data; 
*/
endmodule
