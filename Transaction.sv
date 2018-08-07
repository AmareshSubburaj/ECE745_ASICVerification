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

class Transaction;

static int mem_instruct=0;
static int control_inst=0;
static bit [3:0] pipeline_q[$:5]= {4'b0001,4'b0001,4'b0001,4'b0001,4'b0001};

rand bit [3:0] opcode;
rand bit [2:0] DR, SR , SR1 , SR2,  BaseR, NZP;
rand bit [4:0] Imm5;
rand bit [5:0] PC_offset6;
rand bit [8:0] PC_offset9;
rand bit ir5;
rand bit complete_instr, complete_data;
//only when complete_instr is high IF->ID
//only when complete_data is high mem_state will change
rand bit [15:0] Data_dout;
logic [15:0] Instr_dout;
rand bit [1:0] Select_data;
constraint Com_Inst { complete_instr inside {1'b1} ;}
constraint Com_data { complete_data inside {1'b1} ;}
constraint nzp  {NZP inside {3'b011,3'b110,3'b101,3'b001,3'b010,3'b100};}

constraint Data {
		Select_data dist {[0:3]:/ 20, 4:=50};
		}

constraint data_select {	                
         if (Select_data==0)
					Data_dout inside {0};
					else if (Select_data ==1)
					Data_dout inside{1};
					else if (Select_data == 2)
					Data_dout inside{43690};
					else if(Select_data == 3)
					Data_dout inside {21845};
					else ( Data_dout inside {1,0,43690,21845});
	}

constraint illegal_opcodes_0 {

   opcode != {4'b0100}; };


constraint illegal_opcodes_1 {

   opcode != {4'b1000}; };

	


constraint illegal_opcodes_2 {

   opcode != {4'b1101};  };

	


constraint illegal_opcodes_3 {

   opcode != {4'b1111}; };
	
	
constraint Control_branch {

if(control_inst==0 && mem_instruct==0 )opcode inside { `LD, `LDI, `LEA, `ST , `STI, `LDR, `STR, `BR, `JMP, `ADD, `AND, `NOT}; 

else if( control_inst==1 && mem_instruct==0 ) opcode inside {  `LD, `LDI, `LEA, `ST , `STI, `LDR, `STR, `ADD, `AND, `NOT}; 

else if(control_inst==0 && mem_instruct==1 )   opcode inside { `BR, `JMP, `ADD, `AND, `NOT};

else if(control_inst==1 && mem_instruct==1 )  opcode inside { `ADD, `AND, `NOT}; 

}
        
task Form_Instructions();



if(opcode==`LD || opcode==`LDI || opcode==`LEA ) begin
                  Instr_dout[15:12] = opcode;
                  Instr_dout[11:9] = DR;
                  Instr_dout[8:0] = PC_offset9;
                  
end

else if (opcode==`ST || opcode == `STI) begin
                  Instr_dout[15:12] = opcode;
                  Instr_dout[11:9] = SR;
                  Instr_dout[8:0] = PC_offset9;
               
end

else if (opcode==`LDR) begin
                  Instr_dout[15:12] = opcode;
                  Instr_dout[11:9] = DR;
                  Instr_dout[8:6] = BaseR;
                  Instr_dout[5:0] = PC_offset6;
                  
end

else if (opcode==`STR) begin
                  Instr_dout[15:12] = opcode;
                  Instr_dout[11:9] = SR;
                  Instr_dout[8:6] = BaseR;
                  Instr_dout[5:0] = PC_offset6;
             
end

else if (opcode == `BR) begin
                  Instr_dout[15:12] = opcode;
                  Instr_dout[11:9] = NZP;
                  Instr_dout[8:0] = PC_offset9;
                 
end

else if (opcode == `JMP) begin
                  Instr_dout[15:12] = opcode;
                  Instr_dout[11:9] = 3'b000;
                  Instr_dout[8:6] = BaseR;
                  Instr_dout[5:0] = 6'b000000;
                  
end

else if (opcode==`ADD || opcode == `AND) begin
        case (ir5)
        0: Instr_dout = {opcode,DR,SR1,ir5,1'b0,1'b0,SR2};
        1: Instr_dout =  {opcode,DR,SR1,ir5,Imm5};
        endcase
end

else if(opcode == `NOT) begin
        Instr_dout[15:12] = opcode;
        Instr_dout[11:9] = DR;
        Instr_dout[8:6] = SR1;
        Instr_dout[5:0] = 6'b111111;
end


endtask:Form_Instructions

function void post_randomize();

          pipeline_q. push_front(opcode);
	   
	   void'(pipeline_q.pop_back());

	   mem_instruct=0;
	   control_inst=0;
	   
	   //$display("Pipeline");
		
	   foreach(pipeline_q[i]) begin	   	  
	   
        if(pipeline_q[i]==4'b0010||pipeline_q[i]==4'b1010||pipeline_q[i]==4'b1110||pipeline_q[i] == 4'b0011 || pipeline_q[i] == 4'b1011||pipeline_q[i] == 4'b0110 ||pipeline_q[i]== 4'b0111)
          mem_instruct=1;
		
		
        if(pipeline_q[i]==4'b0000||pipeline_q[i]==4'b1100)
          control_inst=1;
		
		end


endfunction

endclass:Transaction
