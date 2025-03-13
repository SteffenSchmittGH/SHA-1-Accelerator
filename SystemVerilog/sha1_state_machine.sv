

package state_machine_definitions;

	enum logic [1:0] {__RESET = 2'b00, __IDLE = 2'b01, __PROC = 2'b10, __DONE = 2'b11} state;
	// ...  

endpackage 


module sha1_state_machine(
	input logic clk,
	input logic reset_n,
	input logic start,
	input logic [511:0] data,
	output logic [159:0] q,
	output logic done,
	output logic [31:0] H_0_out,
	output logic [31:0] data_index_out,
	output logic [31:0] state_counter_out,
	output logic [3:0] state_out
);

	import state_machine_definitions::*;
	
	
	localparam LOOP_ITERATIONS = 120;
	localparam ITERATIONS      = LOOP_ITERATIONS - 1;
	localparam BITWIDTH        = $clog2(ITERATIONS);
	
	

	/* ### start pulse detection ##############################################
	
	CPU asserts a start pulse ...
	
								   ___________________________________________________
	start_signal:		__________|                                                   |_______________________________________
	
										 ^
										 |
										 
								 ACTUAL START
						
	
	We are using the start_signal to derive a 50MHz related start pulse ..., which is only high for 20ns ... 
	
							             _
							____________| |________________________________________________________________________________________
	
	
	We use this start pulse to trigger our sha-1 processing stage ...
	
	*/
	
	// with the following structure, we are detecting the rising edge of our start signal ... 
	
	logic [3:0] sync_reg = 0;
	
	// shifting data (start signal) from the right-hand side. shifting everything to the left ... newest data is placed at the LSB side ...
	always_ff@(posedge clk)
		begin : start_detection
			if(reset_n == 1'b0)
				sync_reg <= 4'b0000;
			else
				sync_reg <= {sync_reg[2:0],start};
		
		end : start_detection

	// comparator that continuously evaluates the content of our sync_reg ...
	logic sync_start; assign sync_start = (sync_reg == 4'b0011) ? 1'b1 : 1'b0; 

	assign q_start = sync_start;
	
	// ### 'state-machine' ... #######################################################################################################
		
	logic [1:0] control = 0;	
		
	logic [BITWIDTH-1:0] state_counter = 'd0;
	
	always_ff@(posedge clk)
		begin : state_machine
			if(reset_n == 1'b0)
				begin
					control       <= 0;
					state_counter <= 0;
					state 		  <= __RESET;
					state_counter_out <= state_counter;
				end
			else
				begin
					case(state)
						__RESET:	
							begin
								control       <= 0;
								state_counter <= 0;
								state 		  <= __IDLE;
								state_counter_out <= state_counter;
								state_out <= 2'b00;
							end	
						__IDLE: 
							begin
								state_out <= 2'b01;
							    state_counter_out <= state_counter;
								state_counter <= 0;
								control       <= 0;
								if(sync_start)
									state <= __PROC;
							end
						__PROC: 
							begin
								/*
									do something meaningful ... , 
									the control signal is just used for illustration purposes ...
								*/
								state_out <= 2'b10;
							    state_counter_out <= state_counter;
								if(state_counter < 10)
									control <= 2'b01;
								else if(state_counter >= 10 && state_counter < 64)
									control <= 2'b10;
								else if(state_counter >= 64 && state_counter < 110)
									control <= 2'b00;
								else
									control <= 2'b11;
							
								if(state_counter == ITERATIONS)
									begin
										state_counter <= 0;
										state         <= __DONE;
									end
								else
									begin
										state_counter <= state_counter + 1;
										state         <= __PROC;
									end
							end
						__DONE:
							begin
								state_out <= 2'b11;
							    state_counter_out <= state_counter;
								control       <= 0;
								state_counter <= 0;
								state			  <= __IDLE;
							end
						default:
							begin
							    state_counter_out <= state_counter;
								control       <= 0;
								state_counter <= 0;
								state 		  <= __RESET;
							end
					endcase
				end
		end : state_machine
				
				
			assign q_done = (state == __DONE) ? 1'b1 : 1'b0;
				
			assign q_control = control;
			assign q_state   = state;
			// this part should be changed since it uses too much memory
			logic [31:0] K [79:0] = '{
				// 60 ≤ t ≤ 79
				32'hCA62C1D6, 32'hCA62C1D6, 32'hCA62C1D6, 32'hCA62C1D6, 32'hCA62C1D6,
				32'hCA62C1D6, 32'hCA62C1D6, 32'hCA62C1D6, 32'hCA62C1D6, 32'hCA62C1D6,
				32'hCA62C1D6, 32'hCA62C1D6, 32'hCA62C1D6, 32'hCA62C1D6, 32'hCA62C1D6,
				32'hCA62C1D6, 32'hCA62C1D6, 32'hCA62C1D6, 32'hCA62C1D6, 32'hCA62C1D6,
	
				// 40 ≤ t ≤ 59
				32'h8F1BBCDC, 32'h8F1BBCDC, 32'h8F1BBCDC, 32'h8F1BBCDC, 32'h8F1BBCDC,
				32'h8F1BBCDC, 32'h8F1BBCDC, 32'h8F1BBCDC, 32'h8F1BBCDC, 32'h8F1BBCDC,
				32'h8F1BBCDC, 32'h8F1BBCDC, 32'h8F1BBCDC, 32'h8F1BBCDC, 32'h8F1BBCDC,
				32'h8F1BBCDC, 32'h8F1BBCDC, 32'h8F1BBCDC, 32'h8F1BBCDC, 32'h8F1BBCDC,
	    
				// 20 ≤ t ≤ 39
				32'h6ED9EBA1, 32'h6ED9EBA1, 32'h6ED9EBA1, 32'h6ED9EBA1, 32'h6ED9EBA1,
				32'h6ED9EBA1, 32'h6ED9EBA1, 32'h6ED9EBA1, 32'h6ED9EBA1, 32'h6ED9EBA1,
				32'h6ED9EBA1, 32'h6ED9EBA1, 32'h6ED9EBA1, 32'h6ED9EBA1, 32'h6ED9EBA1,
				32'h6ED9EBA1, 32'h6ED9EBA1, 32'h6ED9EBA1, 32'h6ED9EBA1, 32'h6ED9EBA1,
	
				// 0 ≤ t ≤ 19
				32'h5A827999, 32'h5A827999, 32'h5A827999, 32'h5A827999, 32'h5A827999,
				32'h5A827999, 32'h5A827999, 32'h5A827999, 32'h5A827999, 32'h5A827999,
				32'h5A827999, 32'h5A827999, 32'h5A827999, 32'h5A827999, 32'h5A827999,
				32'h5A827999, 32'h5A827999, 32'h5A827999, 32'h5A827999, 32'h5A827999
			};
		
			logic [31:0] H_0 = 32'h67452301;
			logic [31:0] H_1 = 32'hefcdab89;
			logic [31:0] H_2 = 32'h98badcfe;
			logic [31:0] H_3 = 32'h10325476;
			logic [31:0] H_4 = 32'hc3d2e1f0;

			logic [31:0] a ;
			logic [31:0] b ;
			logic [31:0] c;
			logic [31:0] d ;
			logic [31:0] e;
			
			
			
			logic [31:0] H_1_out;
			logic [31:0] H_2_out;
			logic [31:0] H_3_out;
			logic [31:0] H_4_out;
			
			 
			logic [31:0] W [79:0]; //create packed array
			
			logic [31:0] T;
			logic [31:0] data_index;
			
			
			logic [159:0] H_result;
			
always_ff @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        // Reset logic
        state <= __RESET;
    end else begin
        case (state)
            __RESET: begin
                // Add reset state logic here
				done <= '0;
				q <= '0;
				H_0_out <= 4'b100;
				data_index <= '0;
            end

            __IDLE: begin
                // Add idle state logic here
				data_index <= 32'h00000000;
				data_index_out <= data_index;
				W[0]  <= data[511:480]; // Assign the highest 32 bits of 'data' to W[0]
				W[1]  <= data[479:448];
				W[2]  <= data[447:416];
				W[3]  <= data[415:384];
				W[4]  <= data[383:352];
				W[5]  <= data[351:320];
				W[6]  <= data[319:288];
				W[7]  <= data[287:256];
				W[8]  <= data[255:224];
				W[9]  <= data[223:192];
				W[10] <= data[191:160];
				W[11] <= data[159:128];
				W[12] <= data[127:96];
				W[13] <= data[95:64];
				W[14] <= data[63:32];
				W[15] <= data[31:0];  // Assign the lowest 32 bits of 'data' to W[15]

			
			    a <= H_0;
			    b <= H_1;
			    c <= H_2;
			    d <= H_3;
			    e <= H_4;
				done <= '0;
				H_0_out <= a;
				T <= a;
            end

            __PROC: begin
                // Add processing logic here
				data_index_out <= data_index;
				
				W[data_index+16] <= (((((W[data_index-3+16] ^ W[data_index-8+16]) ^ W[data_index-14+16]) ^ W[data_index])) << 1) |
                    (((((W[data_index-3+16] ^ W[data_index-8+16]) ^ W[data_index-14+16]) ^ W[data_index])) >> 31);
				if(data_index < 20) begin
						T = (((a << 5) | ( a >> (32 - 5))) + e + K[data_index] + W[data_index] + ((b&c)^((~b)&(d))));
						end
				else if(data_index < 40)begin
					    T = ((a << 5) | ( a >> (32 - 5))) + e + K[data_index] + W[data_index] + (b ^ c ^ d);
						end
				else if(data_index < 60)begin
						T = ((a << 5) | ( a >> (32 - 5))) + e + K[data_index] + W[data_index] + ((b&c) ^ (b&d) ^ (c&d));
						end
				else if(data_index < 80) begin
						T = ((a << 5) | ( a >> (32 - 5))) + e + K[data_index]  + W[data_index] + (b ^ c ^ d);
						end
						
				e <= d;
				d <= c;
				c <= ((b << 30) | ( b >> (32 - 30)));
				b <= a;
				a <= T;
				
				data_index <= data_index + 1;
				
				if(data_index == 79)begin
						state <= __DONE;
				end
				
			end
            __DONE: begin
						H_0_out = a + H_0;//32'h67452301;
						H_1_out = b + H_1;
						H_2_out = c + H_2;
						H_3_out = d + H_3;
						H_4_out = e + H_4;
						q = {H_0_out,H_1_out,H_2_out,H_3_out,H_4_out};
						data_index_out <= data_index;
				done <= '1;
				data_index <= '0;
            end

            default: begin
			data_index <= '0;
            end
        endcase
    end
end
endmodule 
