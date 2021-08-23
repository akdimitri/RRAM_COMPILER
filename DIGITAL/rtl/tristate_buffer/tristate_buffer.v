//-----------------------------------------------------
// Design Name 	: Tri State Buffer
// File Name   	: tristate_buffer.v
// Function    	: tristate buffer for IO Ports
// Coder       	: Dimitris Antoniadis
// Date		: 27/06/2021
//-----------------------------------------------------
module tristate_buffer(
Z_SA,
//Z_WR,
Z_BUS,
OE
);

parameter B_SIZE = 4;		// WORD SIZE IN BITS 4*8 = 32

// Input Ouput
inout	[B_SIZE-1:0] Z_SA;
//inout	[B_SIZE-1:0] Z_WR;
inout	[B_SIZE-1:0] Z_BUS;

// Input
input	OE;

// Wires
wire	[B_SIZE-1:0] Z_BUS;
wire	[B_SIZE-1:0] Z_SA;
//wire	[B_SIZE-1:0] Z_WR;
wire				OE; 

assign Z_BUS = OE ? Z_SA : {(B_SIZE){1'bz}};
//assign Z_WR = Z_BUS;

endmodule
