

class coverage;

virtual LC3_top_if if_LC3_Top;
virtual LC3_exe_if exe_int;
virtual LC3_wb_if wb_int;

covergroup ALU_OPR_cg;

Cov_alu_opcode: coverpoint if_LC3_Top.Instr_dout[15:12]{
	bins add_op = {4'b0001};
	bins and_op ={4'b0101};
	bins not_op ={4'b1001};
	}
Cov_imm_en: coverpoint if_LC3_Top.Instr_dout[5] iff( if_LC3_Top.Instr_dout[15:12] == 4'b0001 || if_LC3_Top.Instr_dout[15:12] == 4'b0101 || if_LC3_Top.Instr_dout[15:12] == 4'b1001){
	bins enable_on = {1'b1};
	bins enable_off = {1'b0};
	}
Cov_SR1 : coverpoint if_LC3_Top.Instr_dout[8:6] iff(if_LC3_Top.Instr_dout[15:12] == 4'b0001 || if_LC3_Top.Instr_dout[15:12] == 4'b0101 || if_LC3_Top.Instr_dout[15:12] == 4'b1001){
		bins sr1_zero = {3'b000};
		bins sr2_one = {3'b001};
		bins sr1_two = {3'b010};
		bins sr1_three = {3'b011};
		bins sr1_four = {3'b100};
		bins sr1_five = {3'b101};
		bins sr1_six = {3'b110};
		bins sr1_seven = {3'b111};
}

Cov_SR2 : coverpoint if_LC3_Top.Instr_dout[2:0] iff(if_LC3_Top.Instr_dout[15:12] == 4'b0001 || if_LC3_Top.Instr_dout[15:12] == 4'b0101 /*|| if_LC3_Top.Instr_dout[15:12] == 4'b1001*/){
		bins sr2_zero = {3'b000};
		bins sr2_one = {3'b001};
		bins sr2_two = {3'b010};
		bins sr2_three = {3'b011};
		bins sr2_four = {3'b100};
		bins sr2_five = {3'b101};
		bins sr2_six = {3'b110};
		bins sr2_seven = {3'b111};
}		
 Cov_DR:coverpoint if_LC3_Top.Instr_dout[11:9] iff( if_LC3_Top.Instr_dout[15:12] == 4'b0001 || if_LC3_Top.Instr_dout[15:12] == 4'b0101 || if_LC3_Top.Instr_dout[15:12] == 4'b1001){
		bins dr_zero = {3'b000};
		bins dr_one = {3'b001};
		bins dr_two = {3'b010};
		bins dr_three = {3'b011};
		bins dr_four ={3'b100};
		bins dr_five = {3'b101};
		bins dr_six = {3'b110};
		bins dr_seven = {3'b111};
		}
Cov_imm5: coverpoint if_LC3_Top.Instr_dout[4:0] iff( if_LC3_Top.Instr_dout[5] == 1'b1){
		bins imm_zero = {5'b00000};
		bins imm_one = {5'b11111};
		bins imm_alt01 = {5'b01010};
		bins imm_alt10 ={5'b10101};
		option.auto_bin_max =32;
		}
		
		
Xc_opcode_imm_en:cross Cov_alu_opcode,Cov_imm_en  iff(if_LC3_Top.Instr_dout[15:12] == 4'b0001 || if_LC3_Top.Instr_dout[15:12] == 4'b0101 ||if_LC3_Top.Instr_dout[15:12] == 4'b1001){
		
		ignore_bins cross_register = binsof(Cov_imm_en.enable_off) && binsof(Cov_alu_opcode.not_op);
		} 

Xc_opcode_dr_sr1_imm5: cross Cov_alu_opcode, Cov_SR1,Cov_DR,Cov_imm5,Cov_imm_en  iff(if_LC3_Top.Instr_dout[15:12] == 4'b0001 || if_LC3_Top.Instr_dout[15:12] == 4'b0101 ||if_LC3_Top.Instr_dout[15:12] == 4'b1001){
		ignore_bins cross_register = binsof(Cov_imm_en.enable_off);
		ignore_bins cross_register1 = binsof(Cov_alu_opcode.not_op);
		}
		
Xc_opcode_dr_sr1_sr2: cross Cov_alu_opcode, Cov_SR1,Cov_SR2, Cov_DR iff((if_LC3_Top.Instr_dout[15:12] == 4'b0001 || if_LC3_Top.Instr_dout[15:12] == 4'b0101) && (if_LC3_Top.Instr_dout[5] == 0)){
		ignore_bins cross_register = binsof(Cov_alu_opcode.not_op);
			
		}
	
		
Cov_aluin1: coverpoint exe_int.golden_aluin1{
		option.auto_bin_max = 8;
		}
		
Cov_aluin1_corner: coverpoint exe_int.golden_aluin1 iff(if_LC3_Top.Instr_dout[15:12] == 4'b0001 || if_LC3_Top.Instr_dout[15:12] == 4'b0101 ||if_LC3_Top.Instr_dout[15:12] == 4'b1001){
		bins aluin1_all_zeros = {16'b0};
		bins aluin1_all_ones = {16'hFFFF};
		bins aluin1_alt01 = {16'b0101010101010101};
		bins aluin1_alt10 = {16'b1010101010101010};	
		wildcard bins aluin1_pos = {16'b0xxxxxxxxxxxxxxx};
		wildcard bins aluin1_neg = {16'b1xxxxxxxxxxxxxxx};
		}
		
Cov_aluin1_VSR1: coverpoint exe_int.VSR1 iff(if_LC3_Top.Instr_dout[15:12] == 4'b0001 || if_LC3_Top.Instr_dout[15:12] == 4'b0101 ||if_LC3_Top.Instr_dout[15:12] == 4'b1001)
{ option.auto_bin_max =8; }
Cov_aluin2_VSR2: coverpoint exe_int.VSR2 iff(if_LC3_Top.Instr_dout[15:12] == 4'b0001 || if_LC3_Top.Instr_dout[15:12] == 4'b0101 ||if_LC3_Top.Instr_dout[15:12] == 4'b1001)	
{ option.auto_bin_max =8; }		
Cov_aluin2: coverpoint exe_int.golden_aluin2{
		option.auto_bin_max = 8;
		}
		
Cov_aluin2_corner:coverpoint exe_int.golden_aluin2 iff(if_LC3_Top.Instr_dout[15:12] == 4'b0001 || if_LC3_Top.Instr_dout[15:12] == 4'b0101 || if_LC3_Top.Instr_dout[15:12] == 4'b1001){
		bins aluin2_all_zeros = {16'b0};
		bins aluin2_all_ones = {16'hFFFF};
		bins aluin2_alt01 = {16'b0101010101010101};
		bins aluin2_alt10 = {16'b1010101010101010};
		wildcard bins aluin2_pos = {16'b0xxxxxxxxxxxxxxx};
		wildcard bins aluin2_neg = {16'b1xxxxxxxxxxxxxxx};
		}
//Cov_mem_bypass: coverpoint exe_int.Mem_Bypass_Val iff(if_LC3_Top.Instr_dout[15:12] == 4'b0001 || if_LC3_Top.Instr_dout[15:12] == 4'b0101 || if_LC3_Top.Instr_dout[15:12] == 4'b1001);

//Cov_aluout: coverpoint exe_int.aluout iff(if_LC3_Top.Instr_dout[15:12] == 4'b0001 || if_LC3_Top.Instr_dout[15:12] == 4'b0101 || if_LC3_Top.Instr_dout[15:12] == 4'b1001); 		
		
Xc_opcode_aluin1:cross Cov_alu_opcode,Cov_aluin1_corner;

Xc_opcode_aluin2:cross Cov_alu_opcode,Cov_aluin2_corner;

//Xc_VSR1_VSR2: cross Cov_aluin1_VSR1,Cov_aluin2_VSR2 iff(if_LC3_Top.Instr_dout[15:12] == 4'b0001 || if_LC3_Top.Instr_dout[15:12] == 4'b0101 || if_LC3_Top.Instr_dout[15:12] == 4'b1001);

Cov_opr_zero_zero: cross Cov_aluin2_corner, Cov_aluin1_corner iff(if_LC3_Top.Instr_dout[15:12] == 4'b0001 || if_LC3_Top.Instr_dout[15:12] == 4'b0101 ||if_LC3_Top.Instr_dout[15:12] == 4'b1001){
		bins opr_zero_zero = binsof(Cov_aluin1_corner.aluin1_all_zeros) && binsof(Cov_aluin2_corner.aluin2_all_zeros);
		}
				
Cov_opr_zero_all1: cross Cov_aluin2_corner, Cov_aluin1_corner iff(if_LC3_Top.Instr_dout[15:12] == 4'b0001 || if_LC3_Top.Instr_dout[15:12] == 4'b0101 ||if_LC3_Top.Instr_dout[15:12] == 4'b1001){
		bins opr_zero_all1 = binsof(Cov_aluin1_corner.aluin1_all_zeros) && binsof(Cov_aluin2_corner.aluin2_all_ones);
		}
		
Cov_opr_all1_zero:cross Cov_aluin2_corner, Cov_aluin1_corner iff(if_LC3_Top.Instr_dout[15:12] == 4'b0001 || if_LC3_Top.Instr_dout[15:12] == 4'b0101 ||if_LC3_Top.Instr_dout[15:12] == 4'b1001){
		bins opr_all1_zero = binsof(Cov_aluin1_corner.aluin1_all_ones) && binsof(Cov_aluin2_corner.aluin2_all_zeros);
		}
		
Cov_opr_all1_all1:cross Cov_aluin2_corner, Cov_aluin1_corner iff(if_LC3_Top.Instr_dout[15:12] == 4'b0001 || if_LC3_Top.Instr_dout[15:12] == 4'b0101 ||if_LC3_Top.Instr_dout[15:12] == 4'b1001){
		bins opr_all1_all1 = binsof(Cov_aluin1_corner.aluin1_all_ones) && binsof(Cov_aluin2_corner.aluin2_all_ones);
		}

Cov_opr_alt01_alt01:cross Cov_aluin1_corner,Cov_aluin2_corner iff(if_LC3_Top.Instr_dout[15:12] == 4'b0001 || if_LC3_Top.Instr_dout[15:12] == 4'b0101 ||if_LC3_Top.Instr_dout[15:12] == 4'b1001){
		bins opr_alt01_alt01 = binsof(Cov_aluin1_corner.aluin1_alt01) && binsof(Cov_aluin2_corner.aluin2_alt01);
		}		

Cov_opr_alt01_alt10:cross Cov_aluin1_corner,Cov_aluin2_corner iff(if_LC3_Top.Instr_dout[15:12] == 4'b0001 || if_LC3_Top.Instr_dout[15:12] == 4'b0101 ||if_LC3_Top.Instr_dout[15:12] == 4'b1001){
		bins opr_alt01_alt10 = binsof(Cov_aluin1_corner.aluin1_alt01) && binsof(Cov_aluin2_corner.aluin2_alt10);
		}

Cov_opr_alt10_alt01:cross Cov_aluin1_corner,Cov_aluin2_corner iff(if_LC3_Top.Instr_dout[15:12] == 4'b0001 || if_LC3_Top.Instr_dout[15:12] == 4'b0101 ||if_LC3_Top.Instr_dout[15:12] == 4'b1001){
		bins opr_alt10_alt01 = binsof(Cov_aluin1_corner.aluin1_alt10) && binsof(Cov_aluin2_corner.aluin2_alt01);
		}

Cov_opr_alt10_alt10:cross Cov_aluin1_corner,Cov_aluin2_corner iff(if_LC3_Top.Instr_dout[15:12] == 4'b0001 || if_LC3_Top.Instr_dout[15:12] == 4'b0101 ||if_LC3_Top.Instr_dout[15:12] == 4'b1001){
		bins opr_alt10_alt10 = binsof(Cov_aluin1_corner.aluin1_alt10) && binsof(Cov_aluin2_corner.aluin2_alt10);
		}		
		
Cov_opr_pos_pos:cross Cov_aluin1_corner,Cov_aluin2_corner iff(if_LC3_Top.Instr_dout[15:12] == 4'b0001 || if_LC3_Top.Instr_dout[15:12] == 4'b0101 ||if_LC3_Top.Instr_dout[15:12] == 4'b1001){
		bins pos_pos = binsof(Cov_aluin1_corner.aluin1_pos) && binsof(Cov_aluin2_corner.aluin2_pos);
			}
Cov_opr_pos_neg:cross Cov_aluin1_corner,Cov_aluin2_corner iff(if_LC3_Top.Instr_dout[15:12] == 4'b0001 || if_LC3_Top.Instr_dout[15:12] == 4'b0101 ||if_LC3_Top.Instr_dout[15:12] == 4'b1001){
		bins pos_neg = binsof(Cov_aluin1_corner.aluin1_pos) && binsof(Cov_aluin2_corner.aluin2_neg);
		}
Cov_opr_neg_pos:cross Cov_aluin1_corner,Cov_aluin2_corner iff(if_LC3_Top.Instr_dout[15:12] == 4'b0001 || if_LC3_Top.Instr_dout[15:12] == 4'b0101 ||if_LC3_Top.Instr_dout[15:12] == 4'b1001){
		bins neg_pos = binsof(Cov_aluin1_corner.aluin1_neg) && binsof(Cov_aluin2_corner.aluin2_pos);
		}		
Cov_opr_neg_neg:cross Cov_aluin1_corner,Cov_aluin2_corner iff(if_LC3_Top.Instr_dout[15:12] == 4'b0001 || if_LC3_Top.Instr_dout[15:12] == 4'b0101 ||if_LC3_Top.Instr_dout[15:12] == 4'b1001){
		bins neg_neg  = binsof(Cov_aluin1_corner.aluin1_neg) && binsof(Cov_aluin2_corner.aluin2_neg);
		}		
endgroup:ALU_OPR_cg	
		
		
covergroup MEM_OPR_cg;
 Cov_mem_opcode: coverpoint if_LC3_Top.Instr_dout[15:12]{
		bins ld = {4'b0010};
		bins ldr = {4'b0110};
		bins ldi = {4'b1010};
		bins lea = {4'b1110};
		bins st = {4'b0011};
		bins str = {4'b0111};
		bins sti = {4'b1011};} 
		
 Cov_BaseR:coverpoint if_LC3_Top.Instr_dout[8:6] iff( if_LC3_Top.Instr_dout[15:12] == 4'b0110 || if_LC3_Top.Instr_dout[15:12] == 4'b0111){
		bins base_r_zero = {3'b000};
		bins base_r_one = {3'b001};
		bins base_r_two = {3'b010};
		bins base_r_three = {3'b011};
		bins base_r_four = {3'b100};
		bins base_r_five = {3'b101};
		bins base_r_six = {3'b110};
		bins base_r_seven = {3'b111};
		}  
 
 Cov_SR:coverpoint if_LC3_Top.Instr_dout[11:9] iff( if_LC3_Top.Instr_dout[15:12] == 4'b0110 || if_LC3_Top.Instr_dout[15:12] == 4'b0111 || if_LC3_Top.Instr_dout[15:12] == 4'b0111){
		bins sr_zero = {3'b000};
		bins sr_one = {3'b001};
		bins sr_two = {3'b010};
		bins sr_three = {3'b011};
		bins sr_four ={3'b100};
		bins sr_five = {3'b101};
		bins sr_six = {3'b110};
		bins sr_seven = {3'b111};
		}
 
  Cov_DR:coverpoint if_LC3_Top.Instr_dout[11:9] iff(if_LC3_Top.Instr_dout[15:12] == 4'b0010 || if_LC3_Top.Instr_dout[15:12] == 4'b0110 || if_LC3_Top.Instr_dout[15:12] == 4'b1010|| if_LC3_Top.Instr_dout[15:12] == 4'b1110){
		bins dr_zero = {3'b000};
		bins dr_one = {3'b001};
		bins dr_two = {3'b010};
		bins dr_three = {3'b011};
		bins dr_four ={3'b100};
		bins dr_five = {3'b101};
		bins dr_six = {3'b110};
		bins dr_seven = {3'b111};
		}
   Cov_PCoffset9: coverpoint if_LC3_Top.Instr_dout[8:0] iff(if_LC3_Top.Instr_dout[15:12] == 4'b0010 || if_LC3_Top.Instr_dout[15:12] ==4'b1010 || if_LC3_Top.Instr_dout[15:12] ==4'b1110|| if_LC3_Top.Instr_dout[15:12] ==4'b0011|| if_LC3_Top.Instr_dout[15:12] ==4'b1011){
		option.auto_bin_max = 8; 
		}	
  Cov_PCoffset9_c: coverpoint if_LC3_Top.Instr_dout[8:0] iff(if_LC3_Top.Instr_dout[15:12] == 4'b0010 || if_LC3_Top.Instr_dout[15:12] ==4'b1010 || if_LC3_Top.Instr_dout[15:12] ==4'b1110|| if_LC3_Top.Instr_dout[15:12] ==4'b0011|| if_LC3_Top.Instr_dout[15:12] ==4'b1011){
		bins all_ones = {9'b111111111};
		bins all_zeros = {9'b000000000};
		bins alt_01 = {9'b010101010};
		bins alt_10 = {9'b101010101};
		wildcard bins all_pos = {9'b0????????};
		wildcard bins all_neg = {9'b1????????};
		
		}
	Cov_PCoffset6:coverpoint if_LC3_Top.Instr_dout[5:0] iff( if_LC3_Top.Instr_dout[15:12] == 4'b0110 || if_LC3_Top.Instr_dout[15:12] == 4'b0111){
		option.auto_bin_max = 8;
		}	
	Cov_PCoffset6_c: coverpoint if_LC3_Top.Instr_dout[5:0] iff( if_LC3_Top.Instr_dout[15:12] == 4'b0110 || if_LC3_Top.Instr_dout[15:12] == 4'b0111){
		bins all_zeros = {6'b000000};
		bins all_ones = {6'b111111};
		bins alt_01 = {6'b010101};
		bins alt_10 = {6'b101010};
		wildcard bins all_pos = {6'b0?????};
		wildcard bins all_neg = {6'b1?????};
		
		}
		
 		
 Xc_BaseR_DR_offset6: cross Cov_PCoffset6,Cov_DR,Cov_BaseR iff(if_LC3_Top.Instr_dout[15:12] == 4'b0110); 
 Xc_BaseR_DR_offset6_corner: cross Cov_PCoffset6_c,Cov_DR,Cov_BaseR iff(if_LC3_Top.Instr_dout[15:12] == 4'b0110);
 Xc_BaseR_SR_offset6: cross Cov_PCoffset6,Cov_SR,Cov_BaseR iff(if_LC3_Top.Instr_dout[15:12] == 4'b0111);
// Xc_BaseR_SR_offset6_corner: cross Cov_PCoffset6_c,Cov_SR,Cov_BaseR iff(if_LC3_Top.Instr_dout[15:12] == 4'b0111); 
 Xc_DR_offset9: cross Cov_PCoffset9,Cov_DR iff(if_LC3_Top.Instr_dout[15:12] == 4'b0110||if_LC3_Top.Instr_dout[15:12] == 4'b0010 || if_LC3_Top.Instr_dout[15:12] == 4'b1110);
// Xc_DR_offset9_corner: cross Cov_PCoffset9_c,Cov_DR iff(if_LC3_Top.Instr_dout[15:12] == 4'b0110||if_LC3_Top.Instr_dout[15:12] == 4'b0010||if_LC3_Top.Instr_dout[15:12] == 4'b1110);
 //Xc_SR_offset9: cross Cov_PCoffset9,Cov_SR iff(if_LC3_Top.Instr_dout[15:12] == 4'b0011||if_LC3_Top.Instr_dout[15:12] == 4'b1011);
// Xc_SR_offset9_corner: cross Cov_PCoffset9_c,Cov_SR iff(if_LC3_Top.Instr_dout[15:12] == 4'b0011||if_LC3_Top.Instr_dout[15:12] == 4'b1011);
 
 endgroup: MEM_OPR_cg
 
 covergroup CTRL_OPR_cg;
  Cov_ctrl_opcode : coverpoint if_LC3_Top.Instr_dout[15:12]{
		bins br_only = {4'b0000};
		bins jmp_only = {4'b1100};
		}
  Cov_BaseR: coverpoint if_LC3_Top.Instr_dout[8:6] iff(if_LC3_Top.Instr_dout[15:12] == 4'b1100)	{
		bins base_r_zero = {3'b000};
		bins base_r_one = {3'b001};
		bins base_r_two = {3'b010};
		bins base_r_three = {3'b011};
		bins base_r_four = {3'b100};
		bins base_r_five = {3'b101};
		bins base_r_six = {3'b110};
		bins base_r_seven = {3'b111};
		}		
  Cov_PSR: coverpoint wb_int.psr iff( if_LC3_Top.Instr_dout[15:12] == 4'b0000 || if_LC3_Top.Instr_dout[15:12] == 4'b1100){
		bins psr_one ={3'b001};
		bins psr_two ={3'b010};
		bins psr_four = {3'b100};
		}
  Cov_NZP: coverpoint exe_int.NZP iff ( if_LC3_Top.Instr_dout[15:12] == 4'b0000 || if_LC3_Top.Instr_dout[15:12] == 4'b1100){
		bins NZP_one = {3'b001};
		bins NZP_two = {3'b010};
		bins NZP_three = {3'b011};
		bins NZP_four = {3'b100};
		bins NZP_five = {3'b101};
		bins NZP_six = {3'b110};
		bins NZP_seven = {3'b111};
		}
  Cov_PCoffset9: coverpoint if_LC3_Top.Instr_dout[8:0] iff( if_LC3_Top.Instr_dout[15:12] == 4'b0000){
		option.auto_bin_max = 8; 
		}
	
  Cov_PCoffset9_c: coverpoint if_LC3_Top.Instr_dout[8:0] iff(if_LC3_Top.Instr_dout[15:12] == 4'b0000){
		bins all_ones = {9'b111111111};
		bins all_zeros = {9'b000000000};
		bins alt01 = {9'b010101010};
		bins alt10 = {9'b101010101};
		}	 
  //Cov_mem_bypass_val_ctrl: coverpoint exe_int.Mem_Bypass_Val iff( if_LC3_Top.Instr_dout[15:12] == 4'b0000 || if_LC3_Top.Instr_dout[15:12] == 4'b1100);
  //Cov_aluout_ctrl: coverpoint exe_int.aluout iff( if_LC3_Top.Instr_dout[15:12] == 4'b0000 || if_LC3_Top.Instr_dout[15:12] == 4'b1100);
  Xc_NZP_PSR: cross Cov_NZP, Cov_PSR iff ( if_LC3_Top.Instr_dout[15:12] == 4'b0000 || if_LC3_Top.Instr_dout[15:12] == 4'b1100);
  endgroup:CTRL_OPR_cg
  
  covergroup OPR_SEQ_cg;	
	Cov_alu_first : coverpoint if_LC3_Top.Instr_dout[15:12]{
		bins alu_first[] = ( 4'b0001,4'b0101,4'b1001 => 4'b0001,4'b0101,4'b1001,4'b0010,4'b0110,4'b1010,4'b1110,4'b0011,4'b0111,4'b1011,4'b0000,4'b1100 ); 		
	}
	Cov_mem_first : coverpoint if_LC3_Top.Instr_dout[15:12]{
	    bins memory_first[] = ( 4'b0010,4'b0110,4'b1010,4'b1110,4'b0011,4'b0111,4'b1011 => 4'b0001,4'b0101,4'b1001,4'b0000,4'b1100 );  //LEA
	}
	
	Cov_control_first : coverpoint if_LC3_Top.Instr_dout[15:12]{
		bins control_first[] = ( 4'b0000,4'b1100 =>  4'b0001,4'b0101,4'b1001,4'b0010,4'b0110,4'b1010,4'b1110,4'b0011,4'b0111,4'b1011 );	
	}
	endgroup : OPR_SEQ_cg 
	
function new( virtual LC3_exe_if exe_int,virtual LC3_top_if if_LC3_Top, virtual LC3_wb_if wb_int );
 this.exe_int = exe_int;
 this.if_LC3_Top = if_LC3_Top;
 this.wb_int = wb_int;
 MEM_OPR_cg = new();
 ALU_OPR_cg = new();
 CTRL_OPR_cg = new();
 OPR_SEQ_cg = new();
endfunction

 task coverage_sample();
  MEM_OPR_cg.sample();
  ALU_OPR_cg.sample();
  CTRL_OPR_cg.sample();
  OPR_SEQ_cg.sample();
	endtask

	
endclass: coverage	
