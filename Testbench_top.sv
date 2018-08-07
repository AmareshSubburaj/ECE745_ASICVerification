`include "Driver.sv"
`include "Generator.sv"
`include "TopLevelLC3.v"
`include "fetch.sv"
`include "mem_access.sv"
`include "decode.sv"
`include "Controller.sv"
`include "Execute.sv"
`include "writeback.sv"
//`include "cover_group.sv" 

`timescale 1 ns / 1 ns

module LC3_test_top;
bit  clk=1;

parameter clock_cycle =10;

always #(clock_cycle/2) clk=~clk;

parameter num_transactions = 1000000;


LC3_top_if if_LC3_Top(clk);

LC3 dut(
  .clock(if_LC3_Top.clock),
  .reset(if_LC3_Top.reset),
  .pc(if_LC3_Top.pc),
  .instrmem_rd(if_LC3_Top.instrmem_rd),
  .Instr_dout(if_LC3_Top.Instr_dout),
  .Data_addr(if_LC3_Top.Data_addr),
  .complete_instr(if_LC3_Top.complete_instr),
  .complete_data(if_LC3_Top.complete_data),
  .Data_din(if_LC3_Top.Data_din),
  .Data_dout(if_LC3_Top.Data_dout),
  .Data_rd(if_LC3_Top.Data_rd)
  );

controller_probe_if if_Controller	(
					.clk(clk),
					.reset(dut.Ctrl.reset),
					.complete_data(dut.Ctrl.complete_data),
					.complete_instr(dut.Ctrl.complete_instr),
					.IR(dut.Ctrl.IR),
          			.NZP(dut.Ctrl.NZP),
         			 .psr(dut.Ctrl.psr),
          			.IR_Exec(dut.Ctrl.IR_Exec),
          			.IMem_dout(dut.Ctrl.Instr_dout),
         			.enable_updatePC(dut.Ctrl.enable_updatePC),
         		    .enable_fetch(dut.Ctrl.enable_fetch),
				 	.enable_decode(dut.Ctrl.enable_decode),
					.enable_execute(dut.Ctrl.enable_execute),
					.enable_writeback(dut.Ctrl.enable_writeback),
					.br_taken(dut.Ctrl.br_taken),
					.bypass_alu_1(dut.Ctrl.bypass_alu_1),
					.bypass_alu_2(dut.Ctrl.bypass_alu_2),
					.bypass_mem_1(dut.Ctrl.bypass_mem_1),
					.bypass_mem_2(dut.Ctrl.bypass_mem_2),
					.mem_state(dut.Ctrl.mem_state)
				);

fetchinterface finterface(.clk(clk), .reset(dut.Fetch.reset), .enable_updatePC(dut.Fetch.enable_updatePC), 
					.enable_fetch(dut.Fetch.enable_fetch), .pc(dut.Fetch.pc), .npc_out(dut.Fetch.npc_out), 
					.instrmem_rd(dut.Fetch.instrmem_rd), .taddr(dut.Fetch.taddr), .br_taken(dut.Fetch.br_taken)
				);


LC3_dec_if dec_int( .clk(clk), .reset(dut.Dec.reset), .enable_decode(dut.Dec.enable_decode), 
					.Instr_dout(dut.Dec.dout), .E_Control(dut.Dec.E_Control), //.F_Control(F_Control), 
					.npc_in(dut.Dec.npc_in), //.psr(psr), 
					.Mem_Control(dut.Dec.Mem_Control), .W_Control(dut.Dec.W_Control), 
					.IR(dut.Dec.IR), .npc_out(dut.Dec.npc_out)
	      		);      


LC3_exe_if exe_int(		
					.clk(clk), .reset(dut.Ex.reset), .E_Control(dut.Ex.E_Control), .bypass_alu_1(dut.Ex.bypass_alu_1), 
					.bypass_alu_2(dut.Ex.bypass_alu_2), .IR(dut.Ex.IR), .npc_in(dut.Ex.npc), .W_Control_in(dut.Ex.W_Control_in), 
					.Mem_Control_in(dut.Ex.Mem_Control_in), .VSR1(dut.Ex.VSR1), .VSR2(dut.Ex.VSR2), 
					.bypass_mem_1(dut.Ex.bypass_mem_1), .bypass_mem_2(dut.Ex.bypass_mem_2), .Mem_Bypass_Val(dut.Ex.Mem_Bypass_Val),
					.enable_execute(dut.Ex.enable_execute), .W_Control_out(dut.Ex.W_Control_out), 
					.Mem_Control_out(dut.Ex.Mem_Control_out), .aluout(dut.Ex.aluout), .pcout(dut.Ex.pcout), 
					.sr1(dut.Ex.sr1), .sr2(dut.Ex.sr2), .dr(dut.Ex.dr), .M_Data(dut.Ex.M_Data), .NZP(dut.Ex.NZP), .IR_Exec(dut.Ex.IR_Exec)

			);


LC3_wb_if wb_int(  .clk(clk), .reset(dut.WB.reset), .enable_writeback(dut.WB.enable_writeback), 
					.W_Control(dut.WB.W_Control), .aluout(dut.WB.aluout), .memout(dut.WB.memout), .pcout(dut.WB.pcout), 
					.npc(dut.WB.npc), .sr1(dut.WB.sr1), .sr2(dut.WB.sr2), .dr(dut.WB.dr), .VSR1(dut.WB.d1), .VSR2(dut.WB.d2), .psr(dut.WB.psr)

			);

LC3_mem_access_if mem_access_int(.mem_state(dut.MemAccess.mem_state), .M_Control(dut.MemAccess.M_Control), .M_Data(dut.MemAccess.M_Data), .M_Addr(dut.MemAccess.M_Addr), 
					.memout(dut.MemAccess.memout), .DMem_addr(dut.MemAccess.Data_addr), .DMem_din(dut.MemAccess.Data_din), .DMem_dout(dut.MemAccess.Data_dout), 
					.DMem_rd(dut.MemAccess.Data_rd)); 

Generator Gen_obj;
mailbox mbx_obj;
Driver Driver_obj;
event t_event;
//Define objects of other classes here.

Controller controller_obj;
fetch Fetch_obj;
decode Decode_obj;
mem_access Mem_access_obj;
execute Execute_obj;
writeback Writeback_obj;
coverage cov_obj;


task construct_objects();
mbx_obj = new();
controller_obj = new (if_Controller, if_LC3_Top );
Gen_obj =  new( mbx_obj,  t_event ,  num_transactions);
cov_obj = new ( exe_int, if_LC3_Top,wb_int);
Driver_obj = new(if_Controller, mbx_obj,  t_event , if_LC3_Top ,  num_transactions , cov_obj );
Fetch_obj = new(finterface);
Decode_obj = new(dec_int);
Mem_access_obj = new(mem_access_int);
Execute_obj = new(exe_int);
Writeback_obj = new(wb_int);
//cov_obj = new ( exe_int, if_LC3_Top,wb_int);

endtask



initial begin
construct_objects();

fork

Gen_obj.Generator_run();
Driver_obj.Drive_run();
Fetch_obj.goldenreffetch();
Fetch_obj.checkerfunc();

Decode_obj.goldenref_decode();
Decode_obj.checker_decode();
Execute_obj.goldenref_execute();
Execute_obj.checker_execute();

Writeback_obj.goldenref_writeback();
Writeback_obj.checker_writeback();

Mem_access_obj.goldenref_mem_access();
Mem_access_obj.checker_mem_access();

//cov_obj.coverage_sample();
  
controller_obj.goldenrefmodel();
controller_obj.checkerfunc();


join


end

endmodule

