
`define TRANSACTION
`define INTERFACE
`define COVERAGE

`ifdef TRANSACTION
`include  "Transaction.sv";
`endif

`ifdef INTERFACE
`include  "Project_interfaces.sv"
`endif

`ifdef COVERAGE
`include  "cover_group.sv"
`endif


class Driver;

Transaction trans_obj;
mailbox mbx_obj;
int num_transactions;
event t_event;
static int i=0;
coverage cov_obj;
virtual LC3_top_if mod_LC3_Top;
virtual controller_probe_if if_controller;

function new(virtual controller_probe_if if_controller, mailbox mbx_obj, event t_event , virtual LC3_top_if mod_LC3_Top, int num_transactions, ref coverage cov_obj );
this.mbx_obj = mbx_obj;
this.t_event = t_event;
this.mod_LC3_Top = mod_LC3_Top;
this.num_transactions = num_transactions;
this.cov_obj = cov_obj;
this.if_controller= if_controller;
endfunction

task set_reset();
$display("reset applied");
@(posedge mod_LC3_Top.cb);
mod_LC3_Top.reset =  1'b1;

repeat(3) @(posedge mod_LC3_Top.cb);
mod_LC3_Top.reset =  1'b0;
$display("reset finished");
endtask

task set_Drive_Params(ref logic [15:0] Instr_dout, ref bit complete_data, ref bit [15:0] Data_dout, ref bit complete_instr  );

if(mod_LC3_Top.cb.instrmem_rd==1) begin
mod_LC3_Top.Instr_dout<=Instr_dout;
//$display($time,"The Driven Instrucion  is %b",Instr_dout);         //Amaresh
end
mod_LC3_Top.cb.complete_instr<= 1'b1;

mod_LC3_Top.cb.complete_data <= complete_data;
//$display($time,"The Driven completedata is %b",complete_data);         //Amaresh

mod_LC3_Top.cb.Data_dout <=Data_dout;

mod_LC3_Top.cb.complete_instr <=complete_instr;
//$display($time,"The Driven complete_instr is %b",complete_instr);         //Amaresh
endtask:set_Drive_Params


task Drive_run();
begin set_reset();

while(mbx_obj.num()!=0) begin
if(mod_LC3_Top.cb.instrmem_rd==1) 
 mbx_obj.get(trans_obj);

//$display($time,"Driver done   %d", ++i);
set_Drive_Params(trans_obj.Instr_dout, trans_obj.complete_data, trans_obj.Data_dout , trans_obj.complete_instr);
cov_obj.coverage_sample();
->t_event;
 @(mod_LC3_Top.cb);
 end
 $finish;
 end
 endtask


 endclass
