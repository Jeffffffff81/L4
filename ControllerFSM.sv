`default_nettype none

/*
 * This FSM Controls all other FSMs through start/stop signals
 *
 */

module ControllerFSM(clock, startTask1, stopTask1);
    input logic clock;

    output logic startTask1;
    input logic stopTask1;

     //state encoding: {state bits}, !startTask1
     
    reg[4:0] state;
    parameter init_memory = 4'b0000_0;
    parameter idle = 4'b0001_1;
    
    //output logic:
    assign startTask1 = !state[0];

    //state transition logic:
    always_ff @(posedge clock) begin
        case (state)
            init_memory: begin
                             state <= idle;
                         end
            idle:        begin
                             state <= idle;
                         end
            default: state <= init_memory;
        endcase
    end
endmodule