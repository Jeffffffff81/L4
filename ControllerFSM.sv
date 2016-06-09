`default_nettype none

/*
 * This FSM Controls all other FSMs through start/stop signals
 */

module ControllerFSM(clock, startTask1, stopTask1, startTask2a, stopTask2a);
    input logic clock;

    output logic startTask1, startTask2a;
    input logic stopTask1, stopTask2a;

     //state encoding: {state bits}, startTask1
     
    reg[5:0] state;
    parameter initialize                = 6'b0000_0_0;
    parameter start_task_1              = 6'b0001_0_1;
    parameter wait_for_task1_finish     = 6'b0010_0_0;
    parameter start_task_2a             = 6'b0011_1_0;
    parameter wait_for_task_2a_finish   = 6'b0100_0_0;
    
    //output logic:
    assign startTask1 = state[0];
    assign startTask2a = state[1];

    //state transition logic:
    always_ff @(posedge clock) begin
        case (state)
	    initialize: state <= start_task_1;  
            start_task_1: state <= wait_for_task1_finish;
	    wait_for_task1_finish: state <= (stopTask1) ? start_task_2a : wait_for_task1_finish;
            start_task_2a: state <= wait_for_task_2a_finish;
            wait_for_task_2a_finish: state <= wait_for_task_2a_finish;
				
            default: state <= initialize;
        endcase
    end
endmodule