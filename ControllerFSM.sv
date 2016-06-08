`default_nettype none

/*
 * This FSM Controls all other FSMs through start/stop signals
 */

module ControllerFSM(clock, startTask1, stopTask1);
    input logic clock;

    output logic startTask1;
    input logic stopTask1;

     //state encoding: {state bits}, startTask1
     
    reg[4:0] state;
	 parameter initialize = 5'b0000_0;
    parameter start_task_1 = 5'b0000_1;
    parameter wait_for_task1_finish = 5'b0001_0;
    
    //output logic:
    assign startTask1 = state[1];

    //state transition logic:
    always_ff @(posedge clock) begin
        case (state)
				initialize: state <= start_task_1;
		  
            start_task_1: state <= wait_for_task1_finish;
				
				wait_for_task1_finish: state <= (stopTask1) ? wait_for_task1_finish : wait_for_task1_finish; //TODO: IMPLEMENT MORE
				
            default: state <= initialize;
        endcase
    end
endmodule