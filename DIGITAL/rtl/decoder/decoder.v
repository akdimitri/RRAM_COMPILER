//-----------------------------------------------------
// Design Name 	: decoder
// File Name   	: decoder.v
// Function    	: decoder using assign for SEL lines
// Coder       	: Dimitris Antoniadis
// Date		: 11/6/2021
//-----------------------------------------------------
module decoder(
binary_in   , //  binary input
decoder_out , //  out 
enable        //  Enable for the decoder
);

// PARAMETERS
parameter Y = 5;

// INPUTS
input [Y-1:0] binary_in  ;		// Encoded address of READ/WRITE of Y bits
input  enable ; 			// Enable signal of decoder
	
// OUTPUTS
output [(1 << Y)-1:0] decoder_out ; 	// Output of decoder 2^Y size

// WIRES
wire [Y-1:0] binary_in;
wire [(1 << Y)-1:0] decoder_out ; 
wire enable;

assign decoder_out = (enable) ? (1 << binary_in) : 0 ;

endmodule
