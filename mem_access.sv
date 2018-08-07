`timescale 1 ns / 1 ns

class mem_access;

virtual LC3_mem_access_if mem_access_int;

function new(virtual LC3_mem_access_if mem_access_int);
this.mem_access_int = mem_access_int;
endfunction
/*logic[15:0] DMem_addr,DMem_din,memout;
logic DMem_rd; */

task goldenref_mem_access();

forever begin
@(mem_access_int.DMem_dout, mem_access_int.M_Addr, mem_access_int.DMem_dout, mem_access_int.M_Data,mem_access_int.mem_state);
mem_access_int.golden_memout = mem_access_int.DMem_dout; 

if(mem_access_int.mem_state == 0)
 begin 
  if(mem_access_int.M_Control == 0)
  mem_access_int.golden_DMem_addr = mem_access_int.M_Addr;
  else if (mem_access_int.M_Control == 1)
   mem_access_int.golden_DMem_addr = mem_access_int.DMem_dout;
  mem_access_int.golden_DMem_din = 0;
  mem_access_int.golden_DMem_rd = 1;  
  end
  
else if(mem_access_int.mem_state == 2)
 begin
	if(mem_access_int.M_Control == 0)
	mem_access_int.golden_DMem_addr = mem_access_int.M_Addr;
	else if(mem_access_int.M_Control == 1)
	mem_access_int.golden_DMem_addr = mem_access_int.DMem_dout;
   mem_access_int.golden_DMem_din = mem_access_int.M_Data;
   mem_access_int.golden_DMem_rd = 0;
 end

else if(mem_access_int.mem_state == 1)
 begin 
    mem_access_int.golden_DMem_addr = mem_access_int.M_Addr;
	mem_access_int.golden_DMem_din = 0;
	mem_access_int.golden_DMem_rd = 1;
 end
 
else if(mem_access_int.mem_state == 3)
 begin
	mem_access_int.golden_DMem_addr = 16'hz;
	mem_access_int.golden_DMem_din = 16'hz;
	mem_access_int.golden_DMem_rd = 1'hz;
 end
 
 end
endtask: goldenref_mem_access

task checker_mem_access();

forever begin
#10ns
  if(mem_access_int.golden_DMem_addr != mem_access_int.DMem_addr)
  $display($time," Error in Mem Access stage data_addr!DUT Value = %b && Golden Reference Value = %b Value of mem_state = %h",mem_access_int.DMem_addr, mem_access_int.golden_DMem_addr ,mem_access_int.mem_state);
/*	 else
	$display($time, " PASS in Mem Access stage data_addr!DUT Value = %b && Golden Reference Value = %b",mem_access_int.DMem_addr, mem_access_int.golden_DMem_addr);*/
    
  if(mem_access_int.golden_DMem_din != mem_access_int.DMem_din)
   $display($time," Error in Mem Access stage data_din!DUT Value = %b && Golden Reference Value = %b Value of mem_state = %h",mem_access_int.DMem_din,mem_access_int.golden_DMem_din,mem_access_int.mem_state);
 /* else
   $display($time, " PASS in Mem Access stage data_din!DUT Value = %b && Golden Reference Value = %b",mem_access_int.DMem_din,mem_access_int.golden_DMem_din);*/
  
  if(mem_access_int.golden_DMem_rd != mem_access_int.DMem_rd)
   $display($time, " Error in Mem Access stage data_read!DUT Value = %b && Golden Reference Value = %b Value of mem_state = %h",mem_access_int.DMem_rd,mem_access_int.golden_DMem_rd,mem_access_int.mem_state );
 /* else
   $display($time, " PASS in Mem Access stage data_read!DUT Value = %b && Golden Reference Value = %b",mem_access_int.DMem_rd,mem_access_int.golden_DMem_rd);*/
  
  if(mem_access_int.golden_memout != mem_access_int.memout)
  $display($time," Error in Mem Access stage memout!DUT Value = %b && Golden Reference Value = %b Value of mem_state = %h",mem_access_int.memout,mem_access_int.golden_memout,mem_access_int.mem_state);
 /* else
   $display($time, " PASS in Mem Access stage memout!DUT Value = %b && Golden Reference Value = %b",mem_access_int.memout,mem_access_int.golden_memout);*/
end
endtask:checker_mem_access
endclass:mem_access
