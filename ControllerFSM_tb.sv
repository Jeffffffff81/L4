module ControllerFSM_tb();
    logic clock;

    logic startTask1;
    logic stopTask1;

    ControllerFSM dut(
	.clock(clock),
        .startTask1(startTask1),
        .stopTask1(stopTask1)
    );

    initial begin
        forever begin
            clock = 1; #1;
            clock = 0; #1;
         end
    end

    initial begin
        stopTask1 = 0;
        #20;
        $stop;
    end
endmodule
