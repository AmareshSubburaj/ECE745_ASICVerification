

`timescale 1 ns / 1 ns


class fetch;




virtual fetchinterface finterface;

function new(virtual fetchinterface finterface);
 this.finterface = finterface;
endfunction 

task goldenreffetch();
forever
fork
  

forever begin
@(posedge finterface.clk);
if( finterface.reset== 1)
 begin 
   finterface.golden_pc=16'h3000;
finterface.golden_npc =finterface.golden_pc+1;
 end
end





forever begin
@(posedge finterface.clk);	 //Amaresh
     if(finterface.enable_updatePC==1)  
      begin 
   
        if(finterface.br_taken ==1) begin 
          finterface.golden_pc= finterface.taddr;
          end

     
        else if(finterface.br_taken==0) begin
          finterface.golden_pc=finterface.golden_pc+1; 
        end
         

      end
   
      else if(finterface.enable_updatePC==0) begin
        finterface.golden_pc=finterface.golden_pc;
      end

        finterface.golden_npc =finterface.golden_pc+1;
        

end



   
forever begin
@(finterface.enable_fetch, posedge finterface.clk );
  if( finterface.enable_fetch==1)   
   finterface.goldeninstrmem_rd=1;
  
  else if( finterface.enable_fetch==0)
   finterface.goldeninstrmem_rd=1'h0;

end


join 
endtask: goldenreffetch


task checkerfunc();
fork

  forever begin 
 
#10ns

   if( finterface.goldeninstrmem_rd!= finterface.instrmem_rd)
   $display($time,"\tERROR FETCH STAGE - INSTRMEM_RD        DUT VALUE: %b                     GOLDEN REFERENCE VALUE: %b",finterface.instrmem_rd,finterface.goldeninstrmem_rd);	
   /*else 
    $display($time,"\tPASS FETCH STAGE - INSTRMEM_RD         DUT VALUE: %b                      GOLDEN REFERENCE VALUE: %b",finterface.instrmem_rd,finterface.goldeninstrmem_rd); */

 
   if(finterface.golden_pc!=finterface.pc)
    $display($time,"\tERROR FETCH STAGE - PC                DUT VALUE: %b      GOLDEN REFERENCE VALUE: %b",finterface.pc,finterface.golden_pc);
 /*  else
    $display($time,"\tPASS FETCH STAGE - PC                  DUT VALUE: %b       GOLDEN REFERENCE VALUE: %b",finterface.pc,finterface.golden_pc);*/
   
   
   if (finterface.golden_npc!=finterface.npc_out)
    $display($time,"\tERROR FETCH STAGE - NPC_OUT           DUT VALUE: %b      GOLDEN REFERENCE VALUE: %b",finterface.npc_out,finterface.golden_npc);
  /* else 
    $display($time,"\tPASS FETCH STAGE - NPC_OUT             DUT VALUE: %b       GOLDEN REFERENCE VALUE: %b",finterface.npc_out,finterface.golden_npc);*/

  end 


join
endtask: checkerfunc

endclass:fetch
