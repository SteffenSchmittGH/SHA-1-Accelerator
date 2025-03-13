`timescale 1ns/1ps

`define HALF_CLOCK_PERIOD   10
`define RESET_PERIOD 	   100
`define DELAY 	    	   	200
`define SIM_DURATION 	  5000

module sha1_state_machine_tb();

	// ### signals that should get monitored ... 
	logic tb_q_start, tb_q_done;
	logic [1:0] tb_q_state;
	logic [1:0] tb_q_control;

	// ### clock generation process ...
   logic tb_local_clock = 0;
 	initial 
		begin: clock_generation_process
			tb_local_clock = 0;
				forever begin
					#`HALF_CLOCK_PERIOD tb_local_clock = ~tb_local_clock;
				end
		end	

	logic tb_local_reset_n = 0;
	
	initial 
		begin: reset_generation_process
			$display ("Simulation starts ...");
			// reset assertion ... 
			#`RESET_PERIOD tb_local_reset_n = 1'b1;
			#`SIM_DURATION
			$display("SHA-1 Hash: %h", tb_q);
			$display ("Simulation done ...");
			$stop();
		end
		
	logic [7:0] counter = 0;
	
	always_ff@(posedge tb_local_clock)
		counter = counter + 1;
		
	// if counter is equal to 255, tb_start is set to one ... 
	logic tb_start; assign tb_start = (counter >  128) ? 1'b1 : 1'b0;
		

	logic [511:0] tb_data;
	
	initial begin
		tb_data = 512'h46536f4332342f32352069732066756e218000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000088;
	end

	logic [159:0] tb_q;
	logic [31:0] tb_H_0_out;
	logic [31:0] tb_index_counter;
	logic [31:0] tb_state_counter;
	logic [3:0] tb_state_out;
	logic tb_done;

	sha1_state_machine dut_0 (.clk(tb_local_clock),
									  .reset_n(tb_local_reset_n),
									  .start(tb_start),
									  .data(tb_data),
									  .q(tb_q),
								      .done(tb_done),
									  .H_0_out(tb_H_0_out),
									  .data_index_out(tb_index_counter),
									  .state_counter_out(tb_state_counter),
									  .state_out(tb_state_out)
									 );
									 
endmodule 