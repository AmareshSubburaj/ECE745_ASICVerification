# Compilation File for Modelsim

#vlog -sv Project_interfaces.sv
#vlog -sv Generator.sv
#vlog -sv Driver.sv

#vlog -sv data_defs.vp
#vlog -sv data_defs_controller.vp
#vlog -sv data_defs_decode.vp
#vlog -sv data_defs_execute.vp
#vlog -sv data_defs_fetch.vp
#vlog -sv data_defs_memaccess.vp
#vlog -sv data_defs_writeback.vp
vlog -sv Decode_Pipelined.vp
vlog -sv Execute.vp
vlog -sv Fetch.vp
vlog -sv Mem_Access.vp
vlog -sv WriteBack.vp
vlog -sv Controller_Pipeline.vp
vlog TopLevelLC3.v
#vlog -sv Testbench_top.sv
#vlog -sv fetch.sv
#vlog -sv decode.sv
#vlog -sv Execute.sv
#vlog -sv writeback.sv
vlog -sv *.sv
vsim -novopt -coverage LC3_test_top
#log -r /*
