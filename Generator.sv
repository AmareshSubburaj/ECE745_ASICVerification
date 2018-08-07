`ifndef TRANSACTION
`include  "Transaction.sv"
`endif

class Generator;

Transaction trans_obj;
mailbox mbx_obj;


event t_driven;

int num_transactions;

function new(mailbox mbx_obj, event t_driven , int num_transactions);
this.mbx_obj=mbx_obj;
this.t_driven = t_driven;
this.num_transactions = num_transactions;
endfunction

task Generator_run( );



trans_obj = new();
trans_obj.Instr_dout ={16'b1010000000000000};
trans_obj.complete_instr = 1'b1;
trans_obj.complete_data = 1'b1;
mbx_obj.put(trans_obj);
wait(t_driven.triggered);

trans_obj = new();
trans_obj.Instr_dout ={16'b0101001000100000};
trans_obj.complete_instr = 1'b1;
trans_obj.complete_data = 1'b1;
mbx_obj.put(trans_obj);
wait(t_driven.triggered);

trans_obj = new();
trans_obj.Instr_dout ={16'b0101010000100000};
trans_obj.complete_instr = 1'b1;
trans_obj.complete_data = 1'b1;
mbx_obj.put(trans_obj);
wait(t_driven.triggered);

trans_obj = new();
trans_obj.Instr_dout ={16'b0101011100100000};
trans_obj.complete_instr = 1'b1;
trans_obj.complete_data = 1'b1;
mbx_obj.put(trans_obj);
wait(t_driven.triggered);

trans_obj = new();
trans_obj.Instr_dout ={16'b0101100000100000};
trans_obj.complete_instr = 1'b1;
trans_obj.complete_data = 1'b1;
mbx_obj.put(trans_obj);
wait(t_driven.triggered);

trans_obj = new();
trans_obj.Instr_dout ={16'b0101101000100000};
trans_obj.complete_instr = 1'b1;
trans_obj.complete_data = 1'b1;
mbx_obj.put(trans_obj);
wait(t_driven.triggered);

trans_obj = new();
trans_obj.Instr_dout ={16'b0101110000100000};
trans_obj.complete_instr = 1'b1;
trans_obj.complete_data = 1'b1;
mbx_obj.put(trans_obj);
wait(t_driven.triggered);

trans_obj = new();
trans_obj.Instr_dout ={16'b0101111000100000};
trans_obj.complete_instr = 1'b1;
trans_obj.complete_data = 1'b1;
mbx_obj.put(trans_obj);

wait(t_driven.triggered);
trans_obj = new();
trans_obj.Instr_dout ={16'b0001011010100011};
trans_obj.complete_instr = 1'b1;
trans_obj.complete_data = 1'b1;
mbx_obj.put(trans_obj);
wait(t_driven.triggered);


trans_obj = new();
assert( trans_obj.randomize() );
trans_obj.Form_Instructions();
trans_obj.Instr_dout ={16'b1001000101111111};          //1
trans_obj.complete_instr = 1'b1;
trans_obj.complete_data = 1'b1;
mbx_obj.put(trans_obj);
wait(t_driven.triggered);

trans_obj = new();
assert( trans_obj.randomize() );
trans_obj.Form_Instructions();
trans_obj.Instr_dout ={16'b0101110000000000};           //2
trans_obj.complete_instr = 1'b1;
trans_obj.complete_data = 1'b1;
mbx_obj.put(trans_obj);
wait(t_driven.triggered);

trans_obj = new();
assert( trans_obj.randomize() );
trans_obj.Form_Instructions();
trans_obj.Instr_dout ={16'b1001000101111111};           //3
trans_obj.complete_instr = 1'b1;
trans_obj.complete_data = 1'b1;
mbx_obj.put(trans_obj);
wait(t_driven.triggered);

trans_obj = new();
assert( trans_obj.randomize() );
trans_obj.Form_Instructions();
trans_obj.Instr_dout ={16'b0101110000000000};           //4
trans_obj.complete_instr = 1'b1;
trans_obj.complete_data = 1'b1;
mbx_obj.put(trans_obj);
wait(t_driven.triggered);

trans_obj = new();
assert( trans_obj.randomize() );
trans_obj.Form_Instructions();
trans_obj.Instr_dout ={16'b1001000101111111};           //5
trans_obj.complete_instr = 1'b1;
trans_obj.complete_data = 1'b1;
mbx_obj.put(trans_obj);
wait(t_driven.triggered);

trans_obj = new();
assert( trans_obj.randomize() );
trans_obj.Form_Instructions();
trans_obj.Instr_dout ={16'b0101110000000000}; //6
trans_obj.complete_instr = 1'b1;
trans_obj.complete_data = 1'b1;
mbx_obj.put(trans_obj);
wait(t_driven.triggered);

/***********************************/


trans_obj = new();
assert( trans_obj.randomize() );
trans_obj.Form_Instructions();
trans_obj.Instr_dout ={16'b1010000000000000};  //7
trans_obj.complete_instr = 1'b1;
trans_obj.complete_data = 1'b1;
mbx_obj.put(trans_obj);
wait(t_driven.triggered);

trans_obj = new();
assert( trans_obj.randomize() );
trans_obj.Form_Instructions();
trans_obj.Instr_dout ={16'b0101001000100000};  //8
trans_obj.complete_instr = 1'b1;
trans_obj.complete_data = 1'b1;
mbx_obj.put(trans_obj);
wait(t_driven.triggered);

trans_obj = new();
assert( trans_obj.randomize() );
trans_obj.Form_Instructions();
trans_obj.Instr_dout ={16'b0101010000100000};   //9
trans_obj.complete_instr = 1'b1;
trans_obj.complete_data = 1'b1;
mbx_obj.put(trans_obj);
wait(t_driven.triggered);

trans_obj = new();
assert( trans_obj.randomize() );
trans_obj.Form_Instructions();
trans_obj.Instr_dout ={16'b0101011100100000};   //10
trans_obj.complete_instr = 1'b1;
trans_obj.complete_data = 1'b1;
mbx_obj.put(trans_obj);
wait(t_driven.triggered);

trans_obj = new();
assert( trans_obj.randomize() );
trans_obj.Form_Instructions();
trans_obj.Instr_dout ={16'b0101100000100000};   //11
trans_obj.complete_instr = 1'b1;
trans_obj.complete_data = 1'b1;
mbx_obj.put(trans_obj);
wait(t_driven.triggered);

trans_obj = new();
assert( trans_obj.randomize() );
trans_obj.Form_Instructions();
trans_obj.Instr_dout ={16'b0101101000100000};    //12
trans_obj.complete_instr = 1'b1;
trans_obj.complete_data = 1'b1;
mbx_obj.put(trans_obj);
wait(t_driven.triggered);

trans_obj = new();
assert( trans_obj.randomize() );
trans_obj.Form_Instructions();
trans_obj.Instr_dout ={16'b0101110000100000};   //13
trans_obj.complete_instr = 1'b1;
trans_obj.complete_data = 1'b1;
mbx_obj.put(trans_obj);
wait(t_driven.triggered);

trans_obj = new();
assert( trans_obj.randomize() );
trans_obj.Form_Instructions();
trans_obj.Instr_dout ={16'b0101111000100000};       //14
trans_obj.complete_instr = 1'b1;
trans_obj.complete_data = 1'b1;
mbx_obj.put(trans_obj);
wait(t_driven.triggered);

trans_obj = new();
assert( trans_obj.randomize() );
trans_obj.Form_Instructions();
trans_obj.Instr_dout ={16'b0001011010100011};       //15
trans_obj.complete_instr = 1'b1;
trans_obj.complete_data = 1'b1;
mbx_obj.put(trans_obj);
wait(t_driven.triggered);


trans_obj = new();

assert( trans_obj.randomize() );
trans_obj.Form_Instructions();
trans_obj.Instr_dout ={16'b1001000101111111};       //16
trans_obj.complete_instr = 1'b1;
trans_obj.complete_data = 1'b1;
mbx_obj.put(trans_obj);
wait(t_driven.triggered);

trans_obj = new();

assert( trans_obj.randomize() );
trans_obj.Form_Instructions();
trans_obj.Instr_dout ={16'b0101110000000000};       //17
trans_obj.complete_instr = 1'b1;    
trans_obj.complete_data = 1'b1;
mbx_obj.put(trans_obj);
wait(t_driven.triggered);


trans_obj = new();

assert( trans_obj.randomize() );
trans_obj.Form_Instructions();
trans_obj.Instr_dout ={16'b1001000101111111};       //18
trans_obj.complete_instr = 1'b1;
trans_obj.complete_data = 1'b1;
mbx_obj.put(trans_obj);
wait(t_driven.triggered);

trans_obj = new();
assert( trans_obj.randomize() );
trans_obj.Form_Instructions();
trans_obj.Instr_dout ={16'b1001000101111111};       //19
trans_obj.complete_instr = 1'b1;
trans_obj.complete_data = 1'b1;
mbx_obj.put(trans_obj);
wait(t_driven.triggered);

trans_obj = new();
assert( trans_obj.randomize() );
trans_obj.Form_Instructions();
trans_obj.Instr_dout ={16'b1001000101111111};       //20
trans_obj.complete_instr = 1'b1;
trans_obj.complete_data = 1'b1;

mbx_obj.put(trans_obj);
wait(t_driven.triggered);

trans_obj = new();
assert( trans_obj.randomize() );
trans_obj.Form_Instructions();
trans_obj.Instr_dout ={16'b1001000101111111};       //21
trans_obj.complete_instr = 1'b1;
trans_obj.complete_data = 1'b1;

mbx_obj.put(trans_obj);
wait(t_driven.triggered);

trans_obj = new();
assert( trans_obj.randomize() );
trans_obj.Form_Instructions();
trans_obj.Instr_dout ={16'b1001000101111111};       //22
trans_obj.complete_instr = 1'b1;
trans_obj.complete_data = 1'b1;

mbx_obj.put(trans_obj);
wait(t_driven.triggered);

trans_obj = new();
assert( trans_obj.randomize() );
trans_obj.Form_Instructions();
trans_obj.Instr_dout ={16'b0101110000000000};       //23
trans_obj.complete_instr = 1'b1;
trans_obj.complete_data = 1'b1; 
mbx_obj.put(trans_obj);
wait(t_driven.triggered);

/*********************************************************************************************************************************/
 
repeat(num_transactions) begin
trans_obj = new();
assert( trans_obj.randomize() );
trans_obj.Form_Instructions();
//$display("The put instruction %b", trans_obj.opcode );
mbx_obj.put(trans_obj);
wait(t_driven.triggered);
//$display($time," Generated-opcode - %b ",trans_obj.opcode );

end


endtask

endclass
