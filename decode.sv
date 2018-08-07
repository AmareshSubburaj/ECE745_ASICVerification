`timescale 1 ns / 1 ns

class decode;

virtual LC3_dec_if dec_int;

function new( virtual LC3_dec_if dec_int);
 this.dec_int = dec_int;
endfunction

/*logic [15:0]IR;
logic [15:0] npc_out;
logic [5:0] E_Control;
logic [1:0]W_Control;
logic Mem_Control;*/

task goldenref_decode();
forever begin
@(posedge dec_int.clk);
if(dec_int.reset == 1)
	begin
	 dec_int.golden_IR = 0;
	 dec_int.golden_E_Control = 0;
	 dec_int.golden_Mem_Control = 0;
	 dec_int.golden_W_Control = 0;
	 dec_int.golden_npc_out = 0; 
	end
else if(dec_int.reset == 0)
 begin
  if(dec_int.enable_decode == 1)
   begin
    dec_int.golden_IR =  dec_int.Instr_dout;
    dec_int.golden_npc_out = dec_int.npc_in;
   
	
	/*****************Writeback_control*********************/
    if(dec_int.Instr_dout[15:12] == 4'b0001 || dec_int.Instr_dout[15:12] == 4'b0101 || dec_int.Instr_dout[15:12] == 4'b1001 || dec_int.Instr_dout[15:12] == 4'b0000 || dec_int.Instr_dout[15:12] == 4'b1100 ||dec_int.Instr_dout[15:12]==4'b0011||dec_int.Instr_dout[15:12] == 4'b0111 ||dec_int.Instr_dout[15:12] == 4'b1011)
		dec_int.golden_W_Control = 0;
    else if(dec_int.Instr_dout[15:12] == 4'b0010 || dec_int.Instr_dout[15:12] == 4'b0110||dec_int.Instr_dout[15:12] == 4'b1010)
		dec_int.golden_W_Control = 1;
    else if(dec_int.Instr_dout[15:12] == 4'b1110)
		dec_int.golden_W_Control = 2;
	
	/*****************Memory_control*********************/
	if(dec_int.Instr_dout[15:12] == 4'b0010 || dec_int.Instr_dout[15:12] == 4'b0110 || dec_int.Instr_dout[15:12] == 4'b0011 || dec_int.Instr_dout[15:12] == 4'b0111)
		dec_int.golden_Mem_Control = 0;
	else if(dec_int.Instr_dout[15:12] == 4'b1010 || dec_int.Instr_dout[15:12] == 4'b1011)
		dec_int.golden_Mem_Control = 1;
	else
		dec_int.golden_Mem_Control = 0;
		
	/*****************Execute control********************/	
	if(dec_int.Instr_dout[15:12] == 4'b0001 && dec_int.Instr_dout[5] == 0 )
	 dec_int.golden_E_Control = 6'b000001;
	else if(dec_int.Instr_dout[15:12] == 4'b0001 && dec_int.Instr_dout[5] == 1)
	  dec_int.golden_E_Control = 6'b000000;
	else if(dec_int.Instr_dout[15:12] == 4'b0101 && dec_int.Instr_dout[5] == 0)
	  dec_int.golden_E_Control = 6'b010001;
	else if(dec_int.Instr_dout[15:12] == 4'b0101 && dec_int.Instr_dout[5] == 1)
	  dec_int.golden_E_Control = 6'b010000;
	else if(dec_int.Instr_dout[15:12] == 4'b1001)
		dec_int.golden_E_Control = 6'b100000;
	else if(dec_int.Instr_dout[15:12] == 4'b0000)
		 dec_int.golden_E_Control = 6'b000110;
	else if(dec_int.Instr_dout[15:12] == 4'b1100)
		 dec_int.golden_E_Control = 6'b001100;
	else if(dec_int.Instr_dout[15:12] == 4'b0010)
		 dec_int.golden_E_Control = 6'b000110;		 
	else if(dec_int.Instr_dout[15:12] == 4'b0110)
		 dec_int.golden_E_Control = 6'b001000;
	else if(dec_int.Instr_dout[15:12] == 4'b1010)
		 dec_int.golden_E_Control = 6'b000110;
	else if(dec_int.Instr_dout[15:12] == 4'b1110)
		 dec_int.golden_E_Control = 6'b000110;
	else if(dec_int.Instr_dout[15:12] == 4'b0011)
		 dec_int.golden_E_Control = 6'b000110;
	else if(dec_int.Instr_dout[15:12] == 4'b0111)
		 dec_int.golden_E_Control = 6'b001000;
	else if(dec_int.Instr_dout[15:12] == 4'b1011)
		 dec_int.golden_E_Control = 6'b000110;
    end
  end 
end 
endtask: goldenref_decode

task checker_decode();
forever begin

 #10ns
  if(dec_int.IR != dec_int.golden_IR)
   $display($time, " Error in Decode stage IR! DUT Value = %b && Golden Reference Value = %b",dec_int.IR ,dec_int.golden_IR);
 //  else
   // $display($time, " PASS in Decode IR output! DUT Value = %b && Golden Reference Value = %b",dec_int.IR ,dec_int.golden_IR);
 
  if(dec_int.npc_out != dec_int.golden_npc_out)
    $display($time, " Error in Decode stage npc_out! DUT Value = %b && Golden Reference Value = %b",dec_int.npc_out,dec_int.golden_npc_out);
 //else
   // $display($time, " PASS in Decode stage npc_out! DUT Value = %b && Golden Reference Value = %b",dec_int.npc_out,dec_int.golden_npc_out);

  if(dec_int.E_Control != dec_int.golden_E_Control)
   $display($time, " Error in Decode stage E_Control! DUT Value = %b && Golden Reference Value = %b",dec_int.E_Control,dec_int.golden_E_Control);
  //else
 //	$display($time, " PASS in Decode stage E_Control! DUT Value = %b && Golden Reference Value = %b",dec_int.E_Control,dec_int.golden_E_Control);
 
  if(dec_int.Mem_Control != dec_int.golden_Mem_Control)
   $display($time, "Error in Decode stage E_Control! DUT Value = %b && Golden Reference Value = %b",dec_int.Mem_Control,dec_int.golden_Mem_Control);
 //else
 //	$display($time, " PASS in Decode stage Mem_Control!DUT Value = %b && Golden Reference Value = %b",dec_int.Mem_Control,dec_int.golden_Mem_Control);
  
  if(dec_int.W_Control != dec_int.golden_W_Control)
   $display($time, " Error in Decode stage W_Control!DUT Value = %b && Golden Reference Value = %b",dec_int.W_Control,dec_int.golden_W_Control);
  //else
	//$display($time, " PASS in Decode stage W_Control!DUT Value = %b && Golden Reference Value = %b",dec_int.W_Control,dec_int.golden_W_Control);
end
endtask: checker_decode
endclass: decode  

