`timescale 1 ns / 1ns
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

bit LDI_LDR_LD_at_IR_EXEC_1C =0;
bit LDI_at_IR_EXEC_2C =0;
bit LDI_at_IR_EXEC_3C =0;
bit LDR_LD_at_IR_EXEC_2C =0;
bit STI_STR_ST_at_IR_EXEC_1C =0;
bit STR_ST_at_IR_EXEC_2C =0;
bit STI_at_IR_EXEC_2C =0;
bit STI_at_IR_EXEC_3C =0;
bit C1_after_ST = 0;
bit ST_at_2C = 0;
bit C1_after_STR = 0;  //7
bit STR_at_2C = 0;
bit C1_after_LD = 0;  //2
bit LD_at_2C = 0;
bit C1_after_LDR = 0; //6
bit LDR_at_2C = 0;


class Controller;

  //golden ref signals

  virtual controller_probe_if  if_controller;
  virtual LC3_top_if if_Top;

  function new(virtual controller_probe_if  if_controller, virtual LC3_top_if if_Top  );
    this.if_controller = if_controller;
    this.if_Top = if_Top;
    
  endfunction

  task goldenrefmodel();

    fork

      forever begin

          @(posedge if_controller.clk); //reset at posedge of clock  since synchronous
          if(if_controller.reset) begin
          if_controller.golden_enable_fetch=1'b1;
          if_controller.golden_enable_updatePC=0;
          if_controller.golden_bypass_alu_1=0;
          if_controller.golden_bypass_alu_2=0;
          if_controller.golden_bypass_mem_1=0;
          if_controller.golden_bypass_mem_2=0;
          if_controller.golden_mem_state=3;
          if_controller.golden_br_taken=0;

		  		  
          @(negedge if_controller.reset) ;  
		      if_controller.golden_enable_updatePC=1;		  
          @(posedge if_controller.clk);
          if_controller.golden_enable_decode=1'b1;
          @(posedge if_controller.clk);
          if_controller.golden_enable_execute=1'b1;
          @(posedge if_controller.clk);
          if_controller.golden_enable_writeback=1'b1;
        end
        end


      forever begin
        @(posedge if_controller.clk );
        if(!if_controller.reset) begin
          if((if_controller.IR[15:12] == `LD || if_controller.IR[15:12] == `LDR ||  if_controller.IR[15:12] == `LDI)  )
           begin
        			if_controller.golden_enable_fetch = 0;
        		        if_controller.golden_enable_decode = 0;
        			if_controller.golden_enable_execute = 0;
        			if_controller.golden_enable_writeback = 0;
        			if_controller.golden_enable_updatePC = 0;

              LDI_LDR_LD_at_IR_EXEC_1C =1;

/***2***/     @(posedge if_controller.clk);

        		if(if_controller.IR_Exec[15:12] == `LD) //CHANGES
               LD_at_2C = 1;

              if(if_controller.IR_Exec[15:12] == `LDR) //Changes
               LDR_at_2C =1; 

              if(if_controller.IR_Exec[15:12] == `LDR || if_controller.IR_Exec[15:12] == `LD ) begin 
                LDR_LD_at_IR_EXEC_2C =1;
               end


              if( if_controller.IR_Exec[15:12] == `LDI)  //need to check
              begin
/******/       @(posedge if_controller.clk);
                LDI_at_IR_EXEC_2C = 1;
              end

                LDI_LDR_LD_at_IR_EXEC_1C =0;
			  
			   

              if(if_controller.IMem_dout[15:12] !=`JMP && if_controller.IMem_dout[15:12] != `BR ) begin
              if_controller.golden_enable_fetch = 1;
              if_controller.golden_enable_updatePC = 1;
              end

              if(if_controller.IR[15:12] !=`JMP && if_controller.IR[15:12] != `BR )
              if_controller.golden_enable_decode = 1;
               
               
              if_controller.golden_enable_execute = 1;
              if_controller.golden_enable_writeback = 1;

/***3***/     @(posedge if_controller.clk);   

          if((LDR_at_2C == 1) && (if_controller.IR[15:12] == `ADD || if_controller.IR[15:12] == `AND || if_controller.IR[15:12] == `NOT) && (if_controller.IMem_dout[15:12] == `BR || if_controller.IMem_dout[15:12] == `JMP))  
          begin
          if_controller.golden_enable_decode = 0; //changes
          end
           if((LD_at_2C == 1) && (if_controller.IR[15:12] == `ADD || if_controller.IR[15:12] == `AND || if_controller.IR[15:12] == `NOT) && (if_controller.IMem_dout[15:12] == `BR || if_controller.IMem_dout[15:12] == `JMP))  
          begin
          if_controller.golden_enable_decode = 0; //changes
          end

              if(LD_at_2C == 1) begin //changes
              LD_at_2C = 0;
              C1_after_LD = 1;
             end

             if(LDR_at_2C == 1)begin //changes
             LDR_at_2C = 0;
             C1_after_LDR = 1;
             end      


               if(if_controller.IR_Exec[15:12] == `LDI)
               LDI_at_IR_EXEC_3C =1;
               LDI_at_IR_EXEC_2C = 0;
               LDR_LD_at_IR_EXEC_2C=0;
                      

 
          @(posedge if_controller.clk);
              C1_after_LD = 0; //CHANGES
              C1_after_LDR = 0;   //CHANGES
              #0.5ns if(if_controller.IR[15:12] == `BR || if_controller.IR[15:12] == `JMP)  //[2]
               if_controller.golden_enable_decode = 0;


              @(posedge if_controller.clk);
              LDI_at_IR_EXEC_3C =0;

              

        			end
        end
      end


      forever begin
       @(posedge if_controller.clk );
        if(!if_controller.reset) begin
          if(if_controller.IR[15:12] == `ST || if_controller.IR[15:12] == `STR ||  if_controller.IR[15:12] == `STI )
        			begin

        			if_controller.golden_enable_fetch = 0;
        		  if_controller.golden_enable_decode = 0;

        			if_controller.golden_enable_execute = 0;
        			if_controller.golden_enable_writeback = 0; 

        			if_controller.golden_enable_updatePC = 0;

               STI_STR_ST_at_IR_EXEC_1C =1;

        			
 /***2***/    @(posedge if_controller.clk);

              if(if_controller.IR_Exec[15:12] == `ST) //CHANGES
               ST_at_2C = 1;

              if(if_controller.IR_Exec[15:12] == `STR) //Changes
               STR_at_2C =1; 

               
               if(if_controller.IR_Exec[15:12] == `ST || if_controller.IR_Exec[15:12] == `STR ) begin 
                STR_ST_at_IR_EXEC_2C =1;
               end


              if(if_controller.IR_Exec[15:12] == `STI) begin
             @(posedge if_controller.clk);
                 STI_at_IR_EXEC_2C =0;
               end
			  
	             STI_STR_ST_at_IR_EXEC_1C =0;		  


              if(if_controller.IMem_dout[15:12] != `JMP && if_controller.IMem_dout[15:12] != `BR ) begin
                if_controller.golden_enable_fetch = 1;
                if_controller.golden_enable_updatePC = 1;
              end

              if(if_controller.IR[15:12] != `JMP && if_controller.IR[15:12] != `BR )
                 if_controller.golden_enable_decode = 1;
			  
                 if_controller.golden_enable_execute = 1;

/***3***/    @(posedge if_controller.clk);

            if(ST_at_2C == 1) begin //changes
              ST_at_2C = 0;
              C1_after_ST = 1;
             end

             if(STR_at_2C == 1)begin //changes
             STR_at_2C = 0;
             C1_after_STR = 1;
             end
         

              STR_ST_at_IR_EXEC_2C=0;
              STI_at_IR_EXEC_3C =1;  //[16,17,18]


              if(if_controller.IR[15:12] != `JMP && if_controller.IR[15:12] != `BR ) begin //need to check this.
              if_controller.golden_enable_writeback = 1;
              end

              
              #0.5ns if(if_controller.IR[15:12] == `BR || if_controller.IR[15:12] == `JMP)  //[5]
               if_controller.golden_enable_decode = 0;

              @(posedge if_controller.clk)
              C1_after_ST = 0; //CHANGES
              C1_after_STR = 0;   //CHANGES
              STI_at_IR_EXEC_2C =0;
              STI_at_IR_EXEC_3C =0;   //[16,17,18]
        			end
        end
      end	

/******************************************************************************************************************************/

	forever 
	begin
		@(if_controller.reset, if_controller.IMem_dout, if_controller.br_taken, if_controller.IR_Exec, posedge if_controller.clk)
		if(!(if_controller.reset))
			begin				
			if((if_controller.IMem_dout[15:12] == `BR) || (if_controller.IMem_dout[15:12] == `JMP))   // BR or JMP
			  begin

          bit LDR_EXE_Count  =0;
          bit ST_EXE_Count = 0;
          bit Prev_Inst_1_STR =0;  // [10]

          if_controller.golden_enable_fetch=1'b0;
	        if_controller.golden_enable_updatePC=1'b0;

  
/***2***/ @(posedge if_controller.clk); 										         			      						       
			    if_controller.golden_enable_decode=0;
 
        
          
        #0.5ns  if(STR_ST_at_IR_EXEC_2C ==1)  //[10]
          Prev_Inst_1_STR = 1;



/***3***/ @(posedge if_controller.clk);	

          if( (if_controller.IR_Exec[15:12] == `AND || if_controller.IR_Exec[15:12] == `NOT || if_controller.IR_Exec[15:12] == `ADD ) && (if_controller.IR[15:12] == `BR || if_controller.IR[15:12] == `JMP  )) begin

          if_controller.golden_enable_execute = 0;  //cHANGES
          if_controller.golden_enable_writeback=0; 
          end



          if(if_controller.IR_Exec[15:12] == `LDI) begin  //[13,14,15]
          
           @(posedge if_controller.clk);

          #0.5ns if( (if_controller.IR[15:12] == `BR || if_controller.IR[15:12] == `JMP)&& LDI_at_IR_EXEC_3C ==1 )   
          if_controller.golden_enable_decode=0;

           @(posedge if_controller.clk);
          end 


           if(if_controller.IR_Exec[15:12] == `STI) begin  //[16,17,18]
          
           @(posedge if_controller.clk);

          #0.5ns if( (if_controller.IR[15:12] == `BR || if_controller.IR[15:12] == `JMP)&& STI_at_IR_EXEC_3C ==1 )   
          if_controller.golden_enable_decode=0;

           @(posedge if_controller.clk);
          end 

      
          
          if(if_controller.IR_Exec[15:12] == `LDI && ( if_controller.IMem_dout[15:12] == `BR || if_controller.IMem_dout[15:12] == `JMP ) &&  LDI_at_IR_EXEC_2C == 1 )   //LDI [13,14,15]
          begin
          if_controller.golden_enable_execute = 1;  //LDI -> Jmp 1ST CYCLE
          if_controller.golden_enable_writeback=1;  //LDI -> Jmp  1ST CYCLE
    //      LDI_EXE_Count = 1;     //changes
          end

          
          if(if_controller.IR_Exec[15:12] == `STI && ( if_controller.IMem_dout[15:12] == `BR || if_controller.IMem_dout[15:12] == `JMP ) &&  STI_at_IR_EXEC_2C == 1 )   //LDI [13,14,15]
          begin
          if_controller.golden_enable_execute = 1;  //STI -> Jmp 1ST CYCLE
          end



          if(if_controller.IR_Exec[15:12] == `LDR && ( if_controller.IMem_dout[15:12] == `BR || if_controller.IMem_dout[15:12] == `JMP ) &&  LDR_LD_at_IR_EXEC_2C == 1 )  //LDR  [7,8,9]
          begin
          if_controller.golden_enable_execute = 1;  //LDI -> Jmp 1ST CYCLE
          if_controller.golden_enable_writeback=1;  //LDI -> Jmp  1ST CYCLE
          LDR_EXE_Count = 1;
          end

          if( LDR_EXE_Count == 1)    //changes
          @(posedge if_controller.clk);


           if(if_controller.IR_Exec[15:12] == `ST && ( if_controller.IR[15:12] == `BR || if_controller.IR[15:12] == `JMP ) )   // Jmp, ST
          begin				
			    if_controller.golden_enable_execute=1;
			    if_controller.golden_enable_writeback=0;
          end

          

   /*****************/
        if(if_controller.IR_Exec[15:12] == `ST &&( if_controller.IR[15:12] == `JMP || if_controller.IR[15:12] == `BR))  // ST -> BR in 
        @(posedge if_controller.clk);

        if((if_controller.IR[15:12] == `BR || if_controller.IR[15:12] == `JMP) && STR_ST_at_IR_EXEC_2C== 1)
        if_controller.golden_enable_execute = 0;
  /*****************/

        if((if_controller.IR[15:12] == `JMP || if_controller.IR[15:12] == `BR) && LDR_LD_at_IR_EXEC_2C == 1) begin
        @(posedge if_controller.clk);
          if_controller.golden_enable_execute = 0;
          if_controller.golden_enable_writeback = 0;
          end
    

        if(Prev_Inst_1_STR ==1 && (if_controller.IR[15:12] == `JMP || if_controller.IR[15:12] == `BR))  //[10]
        if_controller.golden_enable_writeback = 1;

       if((ST_at_2C == 1) && (if_controller.IR[15:12] == `ADD || if_controller.IR[15:12] == `AND || if_controller.IR[15:12] == `NOT) && (if_controller.IMem_dout[15:12] == `BR || if_controller.IMem_dout[15:12] == `JMP))  
          begin
          if_controller.golden_enable_execute=1;   //changes
			    if_controller.golden_enable_writeback=1;
          @(posedge if_controller.clk);
          end 

        
       if((STR_at_2C == 1) && (if_controller.IR[15:12] == `ADD || if_controller.IR[15:12] == `AND || if_controller.IR[15:12] == `NOT) && (if_controller.IMem_dout[15:12] == `BR || if_controller.IMem_dout[15:12] == `JMP))  
          begin
          if_controller.golden_enable_execute=1;   //changes
			    if_controller.golden_enable_writeback=1;
          @(posedge if_controller.clk);
          end   

        
       if((LD_at_2C == 1) && (if_controller.IR[15:12] == `ADD || if_controller.IR[15:12] == `AND || if_controller.IR[15:12] == `NOT) && (if_controller.IMem_dout[15:12] == `BR || if_controller.IMem_dout[15:12] == `JMP))  
          begin
          if_controller.golden_enable_execute=1;   //changes
			    if_controller.golden_enable_writeback=1;
          @(posedge if_controller.clk);
          end   

         
       if((LDR_at_2C == 1) && (if_controller.IR[15:12] == `ADD || if_controller.IR[15:12] == `AND || if_controller.IR[15:12] == `NOT) && (if_controller.IMem_dout[15:12] == `BR || if_controller.IMem_dout[15:12] == `JMP))  
          begin
          if_controller.golden_enable_execute=1;   //changes
			    if_controller.golden_enable_writeback=1;
          @(posedge if_controller.clk);
          end  

       

/***4***/ @(posedge if_controller.br_taken, if_controller.IR_Exec[15:12]);   // REMOVED POSEDGE IF_CONTROLLER.CLK CHANGES

        #0.5ns  if(if_controller.br_taken==1)  /***************/
					begin
          if_controller.golden_enable_execute = 0;  //LD -> Jmp   (normal behaviour)
          if_controller.golden_enable_writeback=0;  //LD -> Jmp



					if_controller.golden_enable_updatePC=1'b1;
					@(posedge if_controller.clk);
					if_controller.golden_enable_fetch=1'b1;
					end

       
        

			  else if (if_controller.br_taken==0) begin   /***************/
           
          if_controller.golden_enable_execute = 0;  //LD -> Jmp   (normal behaviour)
          if_controller.golden_enable_writeback=0;  //LD -> Jmp
          
          @(posedge if_controller.clk);  //changes           
					if_controller.golden_enable_updatePC=1'b1;
					if_controller.golden_enable_fetch=1'b1;

					end

/***5***/@(posedge if_controller.clk);begin
          
                    
					if_controller.golden_enable_decode=1'b1;

          end


/***6***/@(posedge if_controller.clk);
					if_controller.golden_enable_execute=1'b1;
					
					
/***7***/@(posedge if_controller.clk);
        
					if_controller.golden_enable_writeback=1'b1;

         if(( LDI_LDR_LD_at_IR_EXEC_1C ==1 || LDI_at_IR_EXEC_2C == 1 ))  // BR->LDI
          begin				
			    if_controller.golden_enable_writeback=0;
          end

          if(STR_ST_at_IR_EXEC_2C == 1 || STI_STR_ST_at_IR_EXEC_1C==1 || STI_at_IR_EXEC_2C ==1 ) begin   //BR->STI
			    if_controller.golden_enable_writeback=0;
          end        

  				
				end
			end
	    end

      forever  //continuously generate br_taken asynchronously
      begin
        @(if_controller.NZP, if_controller.psr, posedge if_controller.clk);
        if_controller.golden_br_taken = |(if_controller.psr & if_controller.NZP);
      end

/********************************************************************************************************************************************************************************/

  forever
  begin //Generate bypass logic  asynchronous
  @(posedge if_controller.clk, if_controller.IR, if_controller.IR_Exec);

if(!if_controller.reset)
begin

            if_controller.golden_bypass_alu_1=0;
            if_controller.golden_bypass_alu_2=0;
            if_controller.golden_bypass_mem_1=0;
            if_controller.golden_bypass_mem_2=0;



        if(if_controller.IR_Exec[15:12]==`ADD||if_controller.IR_Exec[15:12]==`AND||if_controller.IR_Exec[15:12]==`NOT || if_controller.IR_Exec[15:12]==`LEA )
        begin //execute stage- Arithmetic
              
                if(if_controller.IR[15:12]==`ADD||if_controller.IR[15:12]==`AND||if_controller.IR[15:12]==`NOT)    //decode stage - Arithmetic
                begin

                     if(if_controller.IR_Exec[11:9]==if_controller.IR[8:6])
                      begin
                      if_controller.golden_bypass_alu_1=1;
                     end

                    if(if_controller.IR_Exec[11:9]==if_controller.IR[2:0] &&  if_controller.IR[5]==1'b0)
                      begin
                      if_controller.golden_bypass_alu_2=1;
                     end
                end

               else if(if_controller.IR[15:12]==`ST|| if_controller.IR[15:12]==`STR || if_controller.IR[15:12]==`STI)    //decode stage - Store
                begin
                    if(if_controller.IR_Exec[11:9]==if_controller.IR[8:6] && if_controller.IR[15:12] == `STR)
                    begin  //SR
                     if_controller.golden_bypass_alu_1=1;
                   end
          
                    if(if_controller.IR_Exec[11:9]==if_controller.IR[11:9])
                    begin //BaseR
                     if_controller.golden_bypass_alu_2=1;
                    end
                end
				
			    else if(if_controller.IR[15:12]==`LDR)    //decode stage - Load
                begin
                    if(if_controller.IR_Exec[11:9]==if_controller.IR[8:6])
                    begin  //SR
                     if_controller.golden_bypass_alu_1=1;
                   end
                end

              else if(if_controller.IR[15:12]==`JMP)    //decode stage - JMP
              begin
                   if(if_controller.IR_Exec[11:9]==if_controller.IR[8:6])
                     begin
                   if_controller.golden_bypass_alu_1=1;
                   end
            end
  
      end



      if(if_controller.IR_Exec[15:12]==`LD||if_controller.IR_Exec[15:12]==`LDR||if_controller.IR_Exec[15:12]==`LDI )
        begin //execute stage- load

        if(if_controller.IR[15:12]==`ST|| if_controller.IR[15:12]==`STR || if_controller.IR[15:12]==`STI)    //decode stage - store
        begin


          if(if_controller.IR_Exec[11:9]==if_controller.IR[8:6] && if_controller.IR[15:12] == `STR) begin //decode stage - store

            if_controller.golden_bypass_mem_1=1;
          end

          if(if_controller.IR_Exec[11:9]==if_controller.IR[11:9]) begin
            if_controller.golden_bypass_mem_2=1;
          end

        end
		
		
		if(if_controller.IR[15:12]==`LD|| if_controller.IR[15:12]==`LDR || if_controller.IR[15:12]==`LDI)     //decode load
        begin


          if(if_controller.IR_Exec[11:9]==if_controller.IR[8:6] && if_controller.IR[15:12] == `LDR) begin

            if_controller.golden_bypass_mem_1=1;
          end

          if(if_controller.IR_Exec[11:9]==if_controller.IR[11:9]) begin
            if_controller.golden_bypass_mem_2=1;
          end

        end


            if(if_controller.IR[15:12]==`ADD|| if_controller.IR[15:12]==`NOT || if_controller.IR[15:12]==`AND)    //decode stage - Arithmetic
            begin

              if(if_controller.IR_Exec[11:9]==if_controller.IR[8:6]) begin
                if_controller.golden_bypass_mem_1=1;
              end

              if(if_controller.IR_Exec[11:9]==if_controller.IR[2:0] &&  if_controller.IR[5]==1'b0) begin
                if_controller.golden_bypass_mem_2=1;
              end

            end


          if(if_controller.IR[15:12]==`JMP)    //decode stage - JMP
                begin               
                  if(if_controller.IR_Exec[11:9]==if_controller.IR[8:6])
                   begin
                    if_controller.golden_bypass_mem_1=1;
                  end             
                end
       end


end

end

forever begin   //memstate is synchronous
    
@(posedge if_controller.clk);

      if(!if_controller.reset)
      begin

        if(if_controller.mem_state==3)
         begin
		  wait(if_controller.complete_data);

                  if(if_controller.IR[15:12] == `LD || if_controller.IR[15:12] == `LDR )
                  if_controller.golden_mem_state = 0;

                  else if(if_controller.IR[15:12] == `ST || if_controller.IR[15:12] == `STR)
                  if_controller.golden_mem_state = 2;

                  else if(if_controller.IR[15:12] == `STI || if_controller.IR[15:12] == `LDI)
                  if_controller.golden_mem_state = 1;

                  else
                  if_controller.golden_mem_state = 3;
                  end

         end
          if(if_controller.mem_state==2)
         begin

                wait(if_controller.complete_data);

                 if (if_controller.complete_data == 1'b1)
           			 begin
           						if_controller.golden_mem_state=3;
           			 end

          end
           if(if_controller.mem_state==0) begin

                wait(if_controller.complete_data);
           
                 if (if_controller.complete_data == 1'b1)
                       begin
                       if_controller.golden_mem_state=3;
                       end
           end
            if(if_controller.mem_state==1) begin

                 wait(if_controller.complete_data);

				 
						if( if_controller.IR_Exec[15:12] == `STI  || if_controller.IR_Exec[15:12] == `ST || if_controller.IR_Exec[15:12] == `STR ) 
                        begin
                        if_controller.golden_mem_state=2;
                        end

						 if ( if_controller.IR_Exec[15:12] == `LDI || if_controller.IR_Exec[15:12] == `LDR || if_controller.IR_Exec[15:12] == `LD )  
                        begin
                        if_controller.golden_mem_state=0;
                        end
						
        end
    end

	


join 
endtask


task checkerfunc();

forever begin

#10ns


    if( if_controller.enable_updatePC!= if_controller.golden_enable_updatePC)
   $display($time,"enable_updatePC Error is  %d, correct value should be %d",if_controller.enable_updatePC,if_controller.golden_enable_updatePC);



  if( if_controller.enable_fetch!= if_controller.golden_enable_fetch)
   $display($time,"enable_fetch Error is %d, correct value should be %d branch taken value %d",if_controller.enable_fetch,if_controller.golden_enable_fetch,if_controller.br_taken);



 
  if( if_controller.enable_decode!= if_controller.golden_enable_decode)
  $display($time,"enable_decode Error is %d, correct value should be %d IR %h",if_controller.enable_decode, if_controller.golden_enable_decode,if_controller.IR[15:12]);




  if( if_controller.enable_execute!= if_controller.golden_enable_execute)
  $display($time,"enable_execute Error is %d, correct value should be %d branch taken value %d instruction %h",if_controller.enable_execute, if_controller.golden_enable_execute,if_controller.br_taken,if_controller.IR_Exec[15:12]);



  if( if_controller.enable_writeback!= if_controller.golden_enable_writeback)
  $display($time,"enable_writeback Error is %d, correct value should be %d branch taken value %d",if_controller.enable_writeback, if_controller.golden_enable_execute,if_controller.br_taken);

  if( if_controller.br_taken!= if_controller.golden_br_taken)
  $display($time,"br_taken Error is %d, correct value should be %d",if_controller.br_taken, if_controller.golden_br_taken);
 /* else  $display($time,"br_taken  No   Error is %d, correct value should be %d",if_controller.br_taken, if_controller.golden_br_taken);*/

   if( if_controller.bypass_alu_1!= if_controller.golden_bypass_alu_1)
  $display($time,"bypass_alu_1 Error is %d, correct value should be %d",if_controller.bypass_alu_1, if_controller.golden_bypass_alu_1);
/*  else   $display($time,"bypass_alu_1    No   Error is %d, correct value should be %d",if_controller.bypass_alu_1, if_controller.golden_bypass_alu_1);*/

    if( if_controller.bypass_alu_2!= if_controller.golden_bypass_alu_2)
  $display($time,"bypass_alu_2 Error is %d, correct value should be %d",if_controller.bypass_alu_2, if_controller.golden_bypass_alu_2);
/*  else   $display($time,"bypass_alu_2        No Error is %d, correct value should be %d",if_controller.bypass_alu_2, if_controller.golden_bypass_alu_2);*/



     if( if_controller.bypass_mem_1!= if_controller.golden_bypass_mem_1)
  $display($time,"bypass_mem_1 Error is %d, correct value should be %d",if_controller.bypass_mem_1,if_controller.golden_bypass_mem_1);
 /* else    $display($time,"bypass_mem_1      No     Error is %d, correct value should be %d",if_controller.bypass_mem_1,if_controller.golden_bypass_mem_1);*/


      if( if_controller.bypass_mem_2!= if_controller.golden_bypass_mem_2)
  $display($time,"bypass_mem_2 Error is %d, correct value should be %d",if_controller.bypass_mem_2, if_controller.golden_bypass_mem_2);
 /* else   $display($time,"bypass_mem_2          No Error is %d, correct value should be %d",if_controller.bypass_mem_2, if_controller.golden_bypass_mem_2); */
 

      if( if_controller.mem_state!= if_controller.golden_mem_state)
  $display($time,"mem_state Error is %d, correct value should be %d",if_controller.mem_state, if_controller.golden_mem_state);
/*  else    $display($time,"mem_state    No  Error is %d, correct value should be %d",if_controller.mem_state, if_controller.golden_mem_state);*/

end
endtask:checkerfunc

  endclass
