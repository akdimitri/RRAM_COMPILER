//-----------------------------------------------------
// Design Name 	: decoder testbench
// File Name   	: tb_decoder.v
// Function    	: test correct functionality of decoder
// Coder       	: Dimitris Antoniadis
// Date		: 11/6/2021
//-----------------------------------------------------
module tb_decoder();

parameter WIDTH = 16;

// REGISTERS
reg  	[WIDTH-1:0]		in;
reg 			en;

// WIRES
wire	[(1 << WIDTH)-1: 0] out;


// INSTANTIATION OF DECODER
decoder #(WIDTH) decoder1(
.binary_in	(in)   , //  4 bit binary input
.decoder_out 	(out), //  16-bit out 
.enable		(en)        //  Enable for the decoder
);



initial begin
	// INITIALISATION
	$dumpfile("tb_decoder.vcd");
	$dumpvars;
	//$monitor("%0d ns \t in=%b \t out=%b", $time, in, out);
	in = 0;
	en = 0;	
	// -----------------

	#20;
	en = 1;		// enable decoder
	#5;
	
	// TEST ALL POSSIBLE COMBINATIONS
	while (in < ((1<<WIDTH)-1))	begin			
		check_out(1 << in);
		#4;
		in = in + 1;
		#1;
	end

$display("SUCCESS");
$finish;	
end

// TASK TO CHECK CORRECT FUNCTIONAILITY
// EXIT UPON WRONG RESULT
task check_out;
	input [(1 << WIDTH)-1:0] a;
	begin
		if (out != a) begin
			$display("ERROR: EXITING");
			$finish;
		end
	end
endtask

endmodule

