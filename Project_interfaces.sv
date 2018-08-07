`timescale 1 ns / 1 ns

//DR+PC_offset9
`define LD 4'b0010
`define LDI 4'b1010
`define LEA 4'b1110

//SR+PC_offset9
`define ST 4'b0011
`define STI 4'b1011

//DR+BaseR+PC_offset6
`define LDR 4'b0110

//SR+BaseR+PC_offset6
`define STR 4'b0111

//NZP+PC_offset9
`define BR 4'b0000

//BaseR
`define JMP 4'b1100

//DR+SR+SR1
`define ADD 4'b0001
`define AND 4'b0101
`define NOT 4'b1001

interface LC3_top_if(input bit clock);

logic reset, instrmem_rd, complete_instr, complete_data, Data_rd;
logic [15:0] pc, Instr_dout, Data_addr,  Data_dout, Data_din;

clocking cb @(posedge clock);
default input #1 output #0;

// Signals related to Instructions
input pc;
input instrmem_rd;
output Instr_dout;
output complete_instr; //if high, fetch moves to decode stage.

//signals related to DRAM

output complete_data;//if high, memory access states can change.
output Data_dout;
input Data_din;
input Data_rd; // 1 for read , 0 for write
input Data_addr;

endclocking:cb

modport TEST (clocking cb, output reset);

endinterface

interface controller_probe_if(
input bit                       clk,
input logic 				    reset,
input logic 				    complete_data,
input logic 				    complete_instr,
input logic 		[15:0]		IR,
input logic 		[2:0]		NZP,
input logic 		[2:0]	   	psr,
input logic 		[15:0]		IR_Exec,
input logic 		[15:0]		IMem_dout,
input logic 			       	enable_updatePC,
input logic 			       	enable_fetch,
input logic 			       	enable_decode,
input logic 			       	enable_execute,
input logic 				    enable_writeback,
input logic 			       	br_taken,
input logic 			       	bypass_alu_1,
input logic 				    bypass_alu_2,
input logic 				    bypass_mem_1,
input logic 				    bypass_mem_2,
input logic 		[1:0]		mem_state);

  logic                 golden_check = 0;
  logic 	  		    golden_enable_updatePC=0;
  logic 				golden_enable_fetch=0;
  logic 				golden_enable_decode=0;
  logic 				golden_enable_execute=0;
  logic 				golden_enable_writeback=0;
  logic 				golden_br_taken;
  logic 				golden_bypass_alu_1=0;
  logic 				golden_bypass_alu_2=0;
  logic 				golden_bypass_mem_1=0;
  logic 				golden_bypass_mem_2=0;
  logic [1:0]		    golden_mem_state;
  
  clocking cb @(posedge clk);
			input  			complete_data;
			input  			complete_instr;
			input  			IR;
            input  			NZP;
            input  			psr;
            input  			IR_Exec;
            input  			IMem_dout;
            input  			enable_updatePC;
            input  			enable_fetch;
			input  			enable_decode;
			input  			enable_execute;
			input  			enable_writeback;
			input  			br_taken;
			input  			bypass_alu_1;
			input  			bypass_alu_2;
			input  			bypass_mem_1;
			input  			bypass_mem_2;
			input  			mem_state;
			input  			reset;
			endclocking



 //reset property

 property reset_pos;
 @(posedge clk)
   ( (reset == 1'b0) |-> ( (enable_fetch == 1) && (enable_updatePC== 1)) ##1 enable_decode==1 ##1 enable_execute==1 ##1 enable_writeback==1 );
 endproperty

 

 LC3_reset: cover property (reset_pos);

 /*property reset_neg;
 @(negedge clk)
  ( (reset ==1'b1) |-> enable_updatePC==1)
 endproperty 

 assert property (reset_neg);

 LC3_reset_1: cover property (reset_neg);*/
 

 // BRANCH TAKEN
      
     
   property p_br_taken_jmp;
     @(posedge clk) disable iff( ! (IR_Exec[15:12] == `BR)&& (!reset)) (|(NZP & psr ) |-> (br_taken == 1'b1));
   endproperty

  // assert property (p_br_taken_jmp);

  CTRL_br_taken_jmp: cover property (p_br_taken_jmp);
  
   
  
   property p_enable_fetch_1;
    @( posedge clk )
	(( IR[15:12] == `LD || IR[15:12] == `LDI || IR[15:12] == `LDR  || IR[15:12] == `ST || IR[15:12] == `STR || IR[15:12] == `STI ) )|=> enable_fetch== 0;
   endproperty

   assert property (p_enable_fetch_1);

   CTRL_enable_fetch_1:  cover property (p_enable_fetch_1);  

 
   property enable_fetch_2;
    @(posedge clk)
        disable iff (IMem_dout[15:12] == `BR ||IMem_dout[15:12] == `JMP || IR_Exec[15:12] == `BR || IR_Exec[15:12] == `JMP )	
        (IR[15:12] == `LD || IR[15:12] == `LDR  || IR[15:12] == `ST  || IR[15:12] == `STR ) |=> ##2 enable_fetch==1'b1;    
   endproperty

   assert property(enable_fetch_2);
    
   CTRL_enable_fetch_2:  cover property (enable_fetch_2);
  
    property enable_fetch_3;
    @(posedge clk)
	disable iff (IMem_dout[15:12] == `BR ||IMem_dout[15:12] == `JMP || IR_Exec[15:12] == `BR || IR_Exec[15:12] == `JMP )
      ( IR[15:12] == `LDI || IR[15:12] == `STI ) |-> ##3 enable_fetch == 1'b1;
	 
 
   endproperty
   assert property (enable_fetch_3);
   CTRL_enable_fetch_3:  cover property (enable_fetch_3);
  
    
  
  
   property enable_decode_1;
    @(posedge clk)
     disable iff (IMem_dout[15:12] == `BR ||IMem_dout[15:12] == `JMP || IR_Exec[15:12] == `BR || IR_Exec[15:12] == `JMP )
	(( IR[15:12] == `LD || IR[15:12] == `LDI || IR[15:12] == `LDR  || IR[15:12] == `ST || IR[15:12] == `STR ||  IR[15:12] == `STI ) )|-> ##1 enable_decode== 0;
	
	 
  endproperty

  assert property (enable_decode_1);
  CTRL_enable_decode_1:  cover property (enable_decode_1);
 

 
  property enable_decode_2;
    @(posedge clk)
	
	  disable iff (IMem_dout[15:12] == `BR ||IMem_dout[15:12] == `JMP || IR_Exec[15:12] == `BR || IR_Exec[15:12] == `JMP )
	 ( IR[15:12] == `LD || IR[15:12] == `LDR  || IR[15:12] == `ST  || IR[15:12] == `STR ) |-> ##2 enable_decode==1'b1;
	 	 
  endproperty


  assert property (enable_decode_2);
  CTRL_enable_decode_2:  cover property (enable_decode_2);
  

  property enable_decode_3;
  @(posedge clk)
  disable iff (IMem_dout[15:12] == `BR ||IMem_dout[15:12] == `JMP || IR_Exec[15:12] == `BR || IR_Exec[15:12] == `JMP )	 
	  ( IR[15:12] == `LDI || IR[15:12] == `STI ) |-> ##3 enable_decode == 1'b1;
	   
  endproperty
  
  assert property (enable_decode_3);
  
  CTRL_enable_decode_3:  cover property (enable_decode_3);
  
  
   property enable_execute_1;
    @(posedge clk)
    disable iff (IMem_dout[15:12] == `BR ||IMem_dout[15:12] == `JMP || IR_Exec[15:12] == `BR || IR_Exec[15:12] == `JMP )	 
	(( IR[15:12] == `LD || IR[15:12] == `LDI || IR[15:12] == `LDR  || IR[15:12] == `ST || IR[15:12] == `STR ||  IR[15:12] == `STI ) )|-> ##1 enable_execute== 0;
	 
	 
   endproperty
   assert property (enable_execute_1);
   CTRL_enable_execute_1:  cover property (enable_execute_1);
  
   property enable_execute_2;
    @(posedge clk)
      disable iff (IMem_dout[15:12] == `BR ||IMem_dout[15:12] == `JMP || IR_Exec[15:12] == `BR || IR_Exec[15:12] == `JMP )	 	
      ( IR[15:12] == `LD || IR[15:12] == `LDR  || IR[15:12] == `ST  || IR[15:12] == `STR ) |-> ##2 enable_execute==1'b1;

	  
	 
  endproperty
  assert property (enable_execute_2);
  CTRL_enable_execute_2:  cover property (enable_execute_2);
 
   property enable_execute_3;
   @(posedge clk)
   disable iff (IMem_dout[15:12] == `BR ||IMem_dout[15:12] == `JMP || IR_Exec[15:12] == `BR || IR_Exec[15:12] == `JMP )	
   ( IR[15:12] == `LDI || IR[15:12] == `STI ) |-> ##3 enable_execute == 1'b1;
	  	 
   endproperty

  assert property (enable_execute_3);
  CTRL_enable_execute_3:  cover property (enable_execute_3);
  
   property enable_writeback_1;
    @(posedge clk)
    disable iff (IMem_dout[15:12] == `BR ||IMem_dout[15:12] == `JMP || IR_Exec[15:12] == `BR || IR_Exec[15:12] == `JMP )	
   (( IR[15:12] == `LD || IR[15:12] == `LDI || IR[15:12] == `LDR  || IR[15:12] == `ST || IR[15:12] == `STR ||  IR[15:12] == `STI ) )|=> enable_writeback== 0;
	 
	 
  endproperty

  assert property (enable_writeback_1);

  CTRL_enable_writeback_1:  cover property (enable_writeback_1);

 
    property enable_writeback_2;
    @(posedge clk)
	disable iff (IMem_dout[15:12] == `BR ||IMem_dout[15:12] == `JMP || IR_Exec[15:12] == `BR || IR_Exec[15:12] == `JMP )
	 ( IR[15:12] == `LD || IR[15:12] == `LDR   ) |=> ##2 enable_writeback==1'b1;
	 
  endproperty
  assert property (enable_writeback_2);
  CTRL_enable_writeback_2:  cover property (enable_writeback_2);
  
    property enable_writeback_3;
    @(posedge clk)
	 disable iff (IMem_dout[15:12] == `BR ||IMem_dout[15:12] == `JMP || IR_Exec[15:12] == `BR || IR_Exec[15:12] == `JMP )
	  (  IR[15:12] == `ST  || IR[15:12] == `STR || IR[15:12] == `LDI  ) |=> ##3 enable_writeback == 1'b1;
	 
  endproperty
  assert property (enable_writeback_3);
  CTRL_enable_writeback_3:  cover property (enable_writeback_3);
  
    property enable_writeback_4;
    @(posedge clk)
	disable iff (IMem_dout[15:12] == `BR ||IMem_dout[15:12] == `JMP || IR_Exec[15:12] == `BR || IR_Exec[15:12] == `JMP )
	    IR[15:12] == `STI |=> ##4 enable_writeback==1'b1;
	 
  endproperty
  assert property (enable_writeback_4);
  CTRL_enable_writeback_4:  cover property (enable_writeback_4);
  

  //CHECK FOR JMP AND check the condition for DR == SR1 for other operations
    property bypass_alu_1_1;         
    @(posedge clk)
	( ( IR[15:12] ==  `ADD || IR[15:12] == `AND || IR[15:12] == `NOT ) && ( IR_Exec[15:12] == `ADD  || IR_Exec[15:12] ==  `AND ||  IR_Exec[15:12] == `NOT ||  IR_Exec[15:12] ==  `LEA ) && ( IR_Exec[11:9] == IR[8:6]) )  |->  bypass_alu_1 == 1'b1;
	
  endproperty 
  assert property (bypass_alu_1_1);
  CTRL_bypass_alu_1_1: cover property (bypass_alu_1_1);
  

  
   property bypass_alu_1_2;         
    @(posedge clk)
	
	( ( IR[15:12] == `LDR  ) && ( IR_Exec[15:12] == `ADD  || IR_Exec[15:12] ==  `AND||  IR_Exec[15:12] == `NOT || IR_Exec[15:12]== `LEA ) && ( IR_Exec[11:9] == IR[8:6]) ) |->  bypass_alu_1 == 1'b1;
	
  endproperty 
  assert property (bypass_alu_1_2);
  CTRL_bypass_alu_1_2: cover property (bypass_alu_1_2);
  
    
  
   property bypass_alu_1_3;         
    @(posedge clk)

	( ( IR[15:12] == `STR ) && ( IR_Exec[15:12] == `ADD  || IR_Exec[15:12] ==  `AND||  IR_Exec[15:12] == `NOT || IR_Exec[15:12]== `LEA ) && ( IR_Exec[11:9] == IR[8:6]) ) |->  bypass_alu_1 == 1'b1;

  endproperty 
  assert property (bypass_alu_1_3);
  CTRL_bypass_alu_1_3: cover property (bypass_alu_1_3);
  
  
  
   property bypass_alu_1_4;         
    @(posedge clk)
	
	( ( IR[15:12] == `JMP ) && ( IR_Exec[15:12] == `ADD  || IR_Exec[15:12] ==  `AND||  IR_Exec[15:12] == `NOT || IR_Exec[15:12]== `LEA )  && ( IR_Exec[11:9] == IR[8:6]) ) |-> bypass_alu_1 == 1'b1;
  endproperty 
  assert property (bypass_alu_1_4);
  CTRL_bypass_alu_1_4: cover property (bypass_alu_1_4);
  
  
  
    property bypass_alu_2_1;
    @(posedge clk)
	( ( IR[15:12] ==  `ADD || IR[15:12] == `AND|| IR[15:12] == `NOT ) && ( IR_Exec[15:12] == `ADD  || IR_Exec[15:12] ==  `AND||  IR_Exec[15:12] == `NOT ||  IR_Exec[15:12] ==  `LEA ) && (IR_Exec[11:9]==IR[2:0] &&  IR[5]==1'b0))  |-> bypass_alu_2 == 1'b1;
  endproperty 
  assert property (bypass_alu_2_1);
  CTRL_bypass_alu_2_1: cover property (bypass_alu_2_1);

       
   property bypass_alu_2_2;
    @(posedge clk)
   (( IR[15:12] == `STR )  && ( IR_Exec[15:12] == `ADD  || IR_Exec[15:12] ==  `AND||  IR_Exec[15:12] == `NOT || IR_Exec[15:12]== `LEA) && (IR_Exec[11:9]==IR[11:9] )) |-> bypass_alu_2 == 1'b1;
   endproperty 
  assert property (bypass_alu_2_2);
  CTRL_bypass_alu_2_2: cover property (bypass_alu_2_2);
  

   property bypass_alu_2_3;
    @(posedge clk)
   ( (( IR[15:12] == `STI )|| ( IR[15:12] == `ST ) ) && (( IR_Exec[15:12] == `ADD  || IR_Exec[15:12] ==  `AND||  IR_Exec[15:12] == `NOT || IR_Exec[15:12]== `LEA ) && ( IR_Exec[11:9]==IR[11:9])) ) |-> bypass_alu_2 == 1'b1;
  endproperty 
  assert property(bypass_alu_2_3);
  CTRL_bypass_alu_2_3: cover property (bypass_alu_2_3);

   property bypass_alu_2_4;
    @(posedge clk)
   (( IR[15:12] == `STR )  && ( IR_Exec[15:12] == `ADD  || IR_Exec[15:12] ==  `AND||  IR_Exec[15:12] == `NOT || IR_Exec[15:12]== `LEA) && (IR_Exec[11:9]==IR[8:6] )) |-> bypass_alu_1 == 1'b1;
   endproperty 
  assert property (bypass_alu_2_4);
  CTRL_bypass_alu_2_4: cover property (bypass_alu_2_4);
  



  
   property bypass_mem_1_1;
    @(posedge clk)
	 (IR[15:12] == `ADD || IR[15:12] == `AND || IR[15:12] == `NOT ) && (IR_Exec[15:12]== `LD||IR_Exec[15:12]== `LDR||IR_Exec[15:12]== `LDI ) && (IR_Exec[11:9]==IR[8:6])  |-> bypass_mem_1 == 1'b1;
	
	 
 	 
  endproperty
  assert property(bypass_mem_1_1);
  CTRL_bypass_mem_1:  cover property (bypass_mem_1_1);
  
 
   property bypass_mem_2_2;
    @(posedge clk)
	( (IR[15:12] == `ADD || IR[15:12] == `AND || IR[15:12] == `NOT ) && (IR_Exec[15:12]==`LD||IR_Exec[15:12]==`LDR||IR_Exec[15:12]==`LDI ) && (IR_Exec[11:9]==IR[2:0] &&  IR[5]==1'b0)) |-> bypass_mem_2 == 1'b1;
	
	 
	 
  endproperty
 
 assert property(bypass_mem_2_2); //change  
  CTRL_bypass_mem_2:  cover property (bypass_mem_2_2);

  
  
  property mem_state1;
  @(posedge clk)

    disable iff (!( IR_Exec[15:12] == `LDI || IR_Exec[15:12] == `STI  ))
   (mem_state == 2'b11) |-> ##1 (mem_state == 2'b01);
  
  endproperty

 assert property (mem_state1); //change  
  CTRL_mem_state_3_1: cover property (mem_state1);
  

  property mem_state2;
  @(posedge clk)
   disable iff (!( IR_Exec[15:12] == `LD || IR_Exec[15:12] == `LDR  ))
   (mem_state == 2'b11 ) |-> ##1 (mem_state == 2'b00);
  
  endproperty
  assert property (mem_state2);
  CTRL_mem_state_3_0: cover property (mem_state2);
  
   
  property mem_state3;
  @(posedge clk)
     disable iff (!( IR_Exec[15:12] == `ST || IR_Exec[15:12] == `STR  ))
   (mem_state == 2'b11 ) |-> ##1 (mem_state == 2'b10 );
  
  endproperty
  assert property (mem_state3);
  CTRL_mem_state_3_2: cover property (mem_state3);
  
 
  property mem_state4;
  @(posedge clk)
    disable iff (!(complete_data ))           
   (mem_state == 2'b10) |-> ##1 (mem_state == 2'b11);
  
  endproperty
  assert property (mem_state4);
  CTRL_mem_state_2_3: cover property (mem_state4);
  
 
  property mem_state5;
  @(posedge clk)
    
    disable iff (!(complete_data && IR_Exec[15:12] == `LDI )) 
   (mem_state == 2'b01) |-> ##1 (mem_state ==2'b00);
  
  endproperty
  assert property (mem_state5);
  CTRL_mem_state_1_0: cover property (mem_state5);


  property mem_state6;
  @(posedge clk)
   
 disable iff (!(complete_data && IR_Exec[15:12] == `STI ))
   (mem_state == 2'b01) |-> ##1 (mem_state ==2'b10);
  
  endproperty
  assert property(mem_state6);
  CTRL_mem_state_1_2: cover property (mem_state6);
  
  property mem_state7;
  @(posedge clk)
  
   (mem_state == 2'b00) |-> ##1 (mem_state ==2'b11);
  
  endproperty
  assert property (mem_state7);
  CTRL_mem_state_0_3: cover property (mem_state7);
  


   property mem_state_LDI;
  @(posedge clk)
  
   (IR[15:12] == `LDI ) |=> (mem_state ==2'b01) ##1 mem_state==2'b00 ##1 mem_state==2'b11;
  
  endproperty
  assert property (mem_state_LDI);

  CTRL_mem_state_ldi: cover property (mem_state_LDI);

   
  property mem_state_STI;
  @(posedge clk)
  
   (IR[15:12] == `STI ) |=>  (mem_state ==2'b01) ##1 mem_state==2'b10 ##1 mem_state==2'b11; 
  
  endproperty
  assert property(mem_state_STI);
  CTRL_mem_state_sti: cover property (mem_state_STI);  

  
endinterface


/***********************************Execute***********************************/
interface LC3_exe_if(
input bit clk,
input logic reset, 
input logic bypass_alu_1, 
input logic bypass_alu_2, 
input logic bypass_mem_1,
input logic  bypass_mem_2,
input logic enable_execute, 
input logic Mem_Control_in, 
input logic Mem_Control_out,
input logic [15:0] IR,npc_in, 
input logic [15:0] VSR1, 
input logic [15:0] VSR2, 
input logic [15:0] Mem_Bypass_Val,
input logic [15:0]  aluout, 
input logic [15:0] pcout, 
input logic [15:0] IR_Exec,
input logic [15:0] M_Data,
input logic [5:0] E_Control,
input logic [2:0] dr, 
input logic [2:0] sr1, 
input logic [2:0] sr2, 
input logic [2:0] NZP,
input logic[1:0] W_Control_in,
input logic[1:0] W_Control_out);

logic [1:0]golden_pcselect1;
logic golden_pcselect2;
logic[15:0]golden_offset11;
logic [15:0]golden_offset6;
logic [15:0]golden_offset9;
 logic golden_Mem_Control_out;  
 logic [15:0]  golden_aluout;
 logic [15:0] golden_aluin1,golden_aluin2;
 logic [15:0] golden_pcout;
 logic [15:0] golden_IR_Exec;
 logic [15:0] golden_M_Data;
 logic [2:0] golden_dr;
 logic [2:0] golden_sr1; 
 logic [2:0] golden_sr2; 
 logic [2:0] golden_NZP;
 logic[1:0] golden_W_Control_out;
  


endinterface

/***********************Decode***************************/

interface LC3_dec_if(
input bit clk,
input logic reset,
input logic [15:0]IR,
input logic [15:0] npc_out,
input logic [5:0] E_Control,
input logic [1:0]W_Control,
input logic Mem_Control,
input logic [15:0]npc_in,
input logic[15:0]Instr_dout,
input logic enable_decode);

logic [15:0]golden_IR;
logic [15:0] golden_npc_out;
logic [5:0] golden_E_Control;
logic [1:0]golden_W_Control;
logic golden_Mem_Control;

 
 endinterface 
/*************************Fetch***************************/

interface fetchinterface(
 input bit clk,
 input logic [15:0] taddr,
 input logic [15:0]pc,
 input logic [15:0]npc_out, 
 input logic reset,
 input logic br_taken,
 input logic enable_updatePC,
 input logic enable_fetch,
 input logic instrmem_rd);
 
 reg [15:0] golden_pc;
 reg goldeninstrmem_rd;
 reg [15:0] golden_npc;
 property resetf;
    @(posedge clk) 
	( reset==1'b1 |-> pc == 16'h3000 ) ;
	endproperty
 
  LC3_probe_rstf: cover property (resetf);

 endinterface
/**********************Writeback*************************/
interface LC3_wb_if(
input bit clk,
input logic reset,
input logic[15:0] aluout,
input logic[15:0] pcout,
input logic[15:0] memout,
input logic[15:0] npc,
input logic[15:0] VSR1,
input logic[15:0] VSR2,
input logic[1:0] W_Control,
input logic[2:0] sr1,
input logic[2:0] sr2,
input logic[2:0] dr,
input logic[2:0] psr,
input logic enable_writeback);

logic[15:0]golden_VSR1,golden_VSR2;
logic[2:0]golden_psr;
logic[15:0]golden_DR_in;
logic [15:0]golden_RegFile [0:7]; 


endinterface

/******************Mem_access**************************/
interface LC3_mem_access_if(

input logic [15:0] M_Data,
input logic [15:0] M_Addr,
input logic M_Control,
input logic [1:0]mem_state,
input logic[15:0]DMem_dout,
input logic[15:0]DMem_addr,
input logic[15:0]DMem_din,
input logic DMem_rd,
input logic [15:0]memout);

logic[15:0] golden_DMem_addr,golden_DMem_din,golden_memout;
logic golden_DMem_rd; 

endinterface
 
  
 

 
