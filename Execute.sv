`timescale 1 ns / 1 ns

class execute;

virtual LC3_exe_if exe_int;

function new( virtual LC3_exe_if exe_int);
 this.exe_int = exe_int;
endfunction

/*logic [1:0]pcselect1;
logic pcselect2;
logic [5:0]offset6;
logic [8:0]offset9;
 logic Mem_Control_out;  
 logic [15:0]  aluout;
 logic [15:0] aluin1,aluin2;
 logic [15:0] pcout;
 logic [15:0] IR_Exec;
 logic [15:0] M_Data;
 logic [2:0] dr;
 logic [2:0] sr1; 
 logic [2:0] sr2; 
 logic [2:0] NZP;
 logic[1:0] W_Control_out;*/

task goldenref_execute();


fork 
forever begin
@(posedge exe_int.clk);
if(exe_int.reset)
 begin
  exe_int.golden_dr = 0;
  exe_int.golden_sr1 = 0;
  exe_int.golden_sr2 = 0;
  exe_int.golden_M_Data = 0;
  exe_int.golden_IR_Exec = 0;
  exe_int.golden_NZP = 0;
  exe_int.golden_Mem_Control_out = 0;
  exe_int.golden_W_Control_out = 0;
  exe_int.golden_aluout = 0;
  exe_int.golden_pcout = 0;
 end
end 

forever begin
@(posedge exe_int.clk);
 if(!exe_int.reset)
  begin
	if(exe_int.enable_execute != 0)
	 begin
		exe_int.golden_pcselect2 = exe_int.E_Control[1];
		exe_int.golden_pcselect1 = exe_int.E_Control[3:2];
		if(exe_int.IR[15:12] == 4'b0110 || exe_int.IR[15:12] == 4'b0111) 
		exe_int.golden_offset6 = {{10{exe_int.IR[5]}},exe_int.IR[5:0]};
		else if(exe_int.IR[15:12] == 4'b0010 || exe_int.IR[15:12] == 4'b1010||exe_int.IR[15:12] == 4'b1110 || exe_int.IR[15:12] == 4'b0011 || exe_int.IR[15:12] == 4'b1011 || exe_int.IR[15:12] == 4'b0000)
		exe_int.golden_offset9 = {{7{exe_int.IR[8]}},exe_int.IR[8:0]};
		else 
		exe_int.golden_offset11 = {{5{exe_int.IR[10]}}, exe_int.IR[10:0]};
		
		exe_int.golden_W_Control_out = exe_int.W_Control_in;
		exe_int.golden_Mem_Control_out = exe_int.Mem_Control_in;
		exe_int.golden_IR_Exec = exe_int.IR;
		
		/************NZP Calculation*****************/
		
		if(exe_int.IR[15:12] == 4'b0000)
		 exe_int.golden_NZP = exe_int.IR[11:9];
		else if(exe_int.IR[15:12] == 4'b1100)
		 exe_int.golden_NZP = 	3'b111;
		else
		 exe_int.golden_NZP = 3'b000;
		 
		
	    /****************DR Calculation*****************/
		if(exe_int.IR[15:12] == 4'b0001 || exe_int.IR[15:12] == 4'b0101 || exe_int.IR[15:12] == 4'b1001 || exe_int.IR[15:12] == 4'b0010 || exe_int.IR[15:12] == 4'b0110 || exe_int.IR[15:12] == 4'b1010 || exe_int.IR[15:12] == 4'b1110)
		 exe_int.golden_dr = exe_int.IR[11:9];
		else
		 exe_int.golden_dr = 0;
		 
		if(exe_int.bypass_alu_1 == 0 && exe_int.bypass_mem_1 == 0)
		 exe_int.golden_aluin1 = exe_int.VSR1;
		else if(exe_int.bypass_alu_1 == 0 && exe_int.bypass_mem_1 == 1)
		  exe_int.golden_aluin1 = exe_int.Mem_Bypass_Val;
		else if(exe_int.bypass_mem_1 == 0 && exe_int.bypass_alu_1 == 1)
		  exe_int.golden_aluin1 = exe_int.golden_aluout;
		  
		if(exe_int.bypass_alu_2 == 0 && exe_int.bypass_mem_2 == 0)
		  begin 
		  if(exe_int.IR[5] == 0)
		  exe_int.golden_aluin2 = exe_int.VSR2;
		  else
		  exe_int.golden_aluin2 = {{11{exe_int.IR[4]}},exe_int.IR[4:0]};
		  end 
		else if(exe_int.bypass_mem_2 == 0 && exe_int.bypass_alu_2 == 1)
		   exe_int.golden_aluin2 = exe_int.golden_aluout;
		else if(exe_int.bypass_alu_2 == 0 && exe_int.bypass_mem_2 == 1)
			exe_int.golden_aluin2 = exe_int.Mem_Bypass_Val;

		/************ALU_OUT Calculation*****************/
		if(exe_int.IR[15:12] == 4'b0001 || exe_int.IR[15:12] == 4'b0101 || exe_int.IR[15:12] == 4'b1001)
		begin 
			
		if(exe_int.IR[15:12] == 4'b0001)
		  exe_int.golden_aluout = exe_int.golden_aluin1 + exe_int.golden_aluin2;
		else if(exe_int.IR[15:12] == 4'b0101)
		  exe_int.golden_aluout = exe_int.golden_aluin1 & exe_int.golden_aluin2;
		else if(exe_int.IR[15:12] == 4'b1001)
		  exe_int.golden_aluout = ~(exe_int.golden_aluin1);

		exe_int.golden_pcout = exe_int.golden_aluout; 
		end
	
 		/************PCOUT Calculation*****************/ 
	     	if(exe_int.IR[15:12] == 4'b0010 || exe_int.IR[15:12] == 4'b0110 || exe_int.IR[15:12] == 4'b1010 || exe_int.IR[15:12] == 4'b1110 || exe_int.IR[15:12] == 4'b0011|| exe_int.IR[15:12] == 4'b0111||exe_int.IR[15:12] == 4'b1011||exe_int.IR[15:12] == 4'b0000||exe_int.IR[15:12] == 4'b1100)
		begin	
		if(exe_int.golden_pcselect2 == 0 && exe_int.golden_pcselect1 == 1)
		 exe_int.golden_pcout = exe_int.golden_aluin1 + exe_int.golden_offset9 ;
		else if(exe_int.golden_pcselect2 == 0 && exe_int.golden_pcselect1 == 2)
		 exe_int.golden_pcout = exe_int.golden_aluin1 + exe_int.golden_offset6  ;
		else if(exe_int.golden_pcselect2 == 0 && exe_int.golden_pcselect1 == 3)
		 exe_int.golden_pcout = exe_int.golden_aluin1;
		else if(exe_int.golden_pcselect2 == 0 && exe_int.golden_pcselect1 == 0) 
  	 	 exe_int.golden_pcout = exe_int.golden_aluin1 + exe_int.golden_offset11;

		else if(exe_int.golden_pcselect2 == 1 && exe_int.golden_pcselect1 == 1)
		 exe_int.golden_pcout = exe_int.npc_in + exe_int.golden_offset9 - 1;
		else if(exe_int.golden_pcselect2 == 1 && exe_int.golden_pcselect1 == 2)
		 exe_int.golden_pcout = exe_int.npc_in + exe_int.golden_offset6 - 1;
		else if(exe_int.golden_pcselect2 == 1 && exe_int.golden_pcselect1 == 3)
		 exe_int.golden_pcout = exe_int.npc_in - 1;
		else if(exe_int.golden_pcselect2 == 1 && exe_int.golden_pcselect1 == 0)
		 exe_int.golden_pcout = exe_int.npc_in +exe_int.golden_offset11 - 1;
		 
		exe_int.golden_aluout=exe_int.golden_pcout;
		end
		 


		/************M_Data Calculation*****************/

		 exe_int.golden_M_Data = exe_int.VSR2;
		 if(exe_int.bypass_alu_2 == 1)
		   exe_int.golden_M_Data = exe_int.golden_aluin2;
		   
		end
    else if(exe_int.enable_execute == 0)
	exe_int.golden_NZP = 3'b000;
	end
	
 end


 
 forever begin
 @(exe_int.IR);
  
  if(!exe_int.reset)
  begin
	
	  	/***********SR1,SR2 Calculation*****************/ 
		exe_int.golden_sr1[2:0] = exe_int.IR[8:6];
		if(exe_int.IR[15:12] == 4'b0001 || exe_int.IR[15:12] == 4'b0101 || exe_int.IR[15:12] == 4'b1001)
		 exe_int.golden_sr2[2:0] = exe_int.IR[2:0];
		else if(exe_int.IR[15:12] == 4'b0011 || exe_int.IR[15:12] == 4'b0111 || exe_int.IR[15:12] == 4'b1011)
		 exe_int.golden_sr2[2:0] = exe_int.IR[11:9];
		else 
		  exe_int.golden_sr2[2:0] = 0;
		
		
	
 end
end 
join
 
endtask: goldenref_execute	
		  
task checker_execute();

fork
forever begin
#10ns

 if(exe_int.sr1 != exe_int.golden_sr1)
  $display($time, " Error in Execute stage sr1! DUT Value = %b && Golden Reference Value = %b",exe_int.sr1,exe_int.golden_sr1);
  //else
  // $display($time, " PASS in Execute stage sr1! DUT Value = %b && Golden Reference Value = %b",exe_int.sr1,exe_int.golden_sr1);

 if(exe_int.sr2 != exe_int.golden_sr2)
 $display($time, " Error in Execute stage sr2! DUT Value = %b && Golden Reference Value = %b",exe_int.sr2,exe_int.golden_sr2);
/*else
 $display($time, " PASS in Execute stage sr2! DUT Value = %b && Golden Reference Value = %b",exe_int.sr2,exe_int.golden_sr2);*/

   if(exe_int.aluout != exe_int.golden_aluout)
    $display($time, " Error in Execute stage aluout! DUT Value = %b && Golden Reference Value = %b",exe_int.aluout,exe_int.golden_aluout);
 /*else
	$display($time, " PASS in Execute stage aluout!DUT Value = %b && Golden Reference Value = %b",exe_int.aluout,exe_int.golden_aluout);*/
	
	if(exe_int.pcout != exe_int.golden_pcout)
	$display($time, " Error in Execute stage pcout!DUT Value = %b && Golden Reference Value = %b ",exe_int.pcout,exe_int.golden_pcout);
 /*else
	$display($time, " PASS in Execute stage pcout!DUT Value = %b && Golden Reference Value = %b",exe_int.pcout,exe_int.golden_pcout);*/

   if(exe_int.W_Control_out != exe_int.golden_W_Control_out)
   $display($time, " Error in Execute stage W_Control_out!DUT Value = %b && Golden Reference Value = %b",exe_int.W_Control_out,exe_int.golden_W_Control_out);
/*	 else
	$display($time, " PASS in Execute stage W_Control_out!DUT Value = %b && Golden Reference Value = %b",exe_int.W_Control_out,exe_int.golden_W_Control_out);*/
   
   if(exe_int.Mem_Control_out != exe_int.golden_Mem_Control_out)
    $display($time, " Error in Execute stage Mem_Control! DUT Value = %b && Golden Reference Value = %b",exe_int.Mem_Control_out,exe_int.golden_Mem_Control_out );
/*	else
	$display($time, " PASS in Execute stage Mem_Control_out! DUT Value = %b && Golden Reference Value = %b",exe_int.Mem_Control_out,exe_int.golden_Mem_Control_out );*/
   
   if(exe_int.M_Data != exe_int.golden_M_Data)
    $display($time, " Error in Execute stage M_Data!DUT Value = %b && Golden Reference Value = %b",exe_int.M_Data,exe_int.golden_M_Data);
/*	else
	$display($time, " PASS in Execute M_Data!DUT Value = %b && Golden Reference Value = %b",exe_int.M_Data,exe_int.golden_M_Data);*/
   
   if(exe_int.dr != exe_int.golden_dr)
    $display($time, " Error in Execute stage dr!DUT Value = %b && Golden Reference Value = %b",exe_int.dr,exe_int.golden_dr);
/*	else
	$display($time, " PASS in Execute stage dr!DUT Value = %b && Golden Reference Value = %b",exe_int.dr,exe_int.golden_dr);*/
   
   if(exe_int.NZP != exe_int.golden_NZP)
   $display($time, " Error in Execute stage NZP!DUT Value = %b && Golden Reference Value = %b",exe_int.NZP,exe_int.golden_NZP);
/*	else
 	$display($time, " PASS in Execute stage NZP!DUT Value = %b && Golden Reference Value = %b",exe_int.NZP,exe_int.golden_NZP);*/
   
   if(exe_int.IR_Exec != exe_int.golden_IR_Exec)
   $display($time, " Error in Execute stage IR_Exec! DUT Value = %b && Golden Reference Value = %b",exe_int.IR_Exec ,exe_int.golden_IR_Exec);
/*	else
	$display($time, " PASS in Execute stage IR_Exec! DUT Value = %b && Golden Reference Value = %b",exe_int.IR_Exec ,exe_int.golden_IR_Exec);*/
end
join


endtask : checker_execute
endclass:execute	
   

 		
		 
		 
