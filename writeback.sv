`timescale 1 ns / 1 ns
class writeback;

virtual LC3_wb_if wb_int;

function new(virtual LC3_wb_if wb_int);
this.wb_int = wb_int;
endfunction

/*logic[15:0]VSR1,VSR2;
logic[2:0]psr;
logic[15:0]DR_in;
logic [7:0]RegFile; */

task goldenref_writeback();
fork
forever begin
@(posedge wb_int.clk);
if(wb_int.reset)
 begin
 wb_int.golden_psr = 0;
 end
end 
                          /****************VSR Calculation*****************/
forever begin
@(wb_int.golden_RegFile[wb_int.sr1], wb_int.golden_RegFile[wb_int.sr2])
wb_int.golden_VSR1 = wb_int.golden_RegFile[wb_int.sr1];
wb_int.golden_VSR2 = wb_int.golden_RegFile[wb_int.sr2];  
end
 
forever begin
@(posedge wb_int.clk);
 if(!wb_int.reset)
  begin 
  
	/****************DR_in Calculation*****************/
    if(wb_int.W_Control == 2'b00)
	 wb_int.golden_DR_in = wb_int.aluout;
	else if(wb_int.W_Control == 2'b01)
	 wb_int.golden_DR_in = wb_int.memout;
    else if(wb_int.W_Control == 2'b10)
	 wb_int.golden_DR_in = wb_int.pcout;

	/*****************PSR Calculation*****************/ 
	if(wb_int.enable_writeback != 0)
	 begin 	
		wb_int.golden_RegFile[wb_int.dr] = wb_int.golden_DR_in[15:0];
		if(wb_int.golden_DR_in[15]==1)
		 wb_int.golden_psr = 3'b100;
		else if(wb_int.golden_DR_in == 0)
                wb_int.golden_psr = 3'b010;
		else if(wb_int.golden_DR_in[15] == 0  && wb_int.golden_DR_in != 0)	
	     wb_int.golden_psr = 3'b001;
	 end
	end
end	
join
endtask: goldenref_writeback	

task checker_writeback();
fork



forever begin
#10ns
 if(wb_int.psr != wb_int.golden_psr)
 $display($time," Error in Writeback stage psr! DUT Value = %b Golden Reference Value = %b", wb_int.psr,wb_int.golden_psr);
 /* else
  $display($time," PASS in Writeback stage psr! DUT Value = %b Golden Reference Value = %b", wb_int.psr,wb_int.golden_psr);*/
  
  if(wb_int.VSR1 != wb_int.golden_VSR1)
 $display($time," Error in Writeback stage VSR1! DUT Value = %b Golden Reference Value = %b, src1 value is %b", wb_int.VSR1,wb_int.golden_VSR1,wb_int.sr1);
 /*else
 $display($time, " PASS in Writeback stage VSR1!DUT Value = %b Golden Reference Value = %b", wb_int.VSR1,wb_int.golden_VSR1);*/
  
  if(wb_int.VSR2 != wb_int.golden_VSR2)
   $display($time," Error in Writeback stage VSR2! DUT Value = %b Golden Reference Value = %b Value of sr2 = %b", wb_int.VSR2,wb_int.golden_VSR2, wb_int.sr2);
/*	 else
 	$display($time, " PASS in Writeback stage VSR2!DUT Value = %b Golden Reference Value = %b", wb_int.VSR2,wb_int.golden_VSR2);*/
end 
join
endtask:checker_writeback 

endclass:writeback  
	 
		 
