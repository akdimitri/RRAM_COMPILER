//-----------------------------------------------------
// Design Name 	: Controller
// File Name   	: controller.v
// Function    	: Controller of the memory. It takes as arguments the addresses 
//                of a word and RW signal. It generates the necessary signals to
//                controll RRAM Array and its preipheral circuits.
// Coder       	: Dimitris Antoniadis
// Date		: 25/06/2021
//-----------------------------------------------------

`include "/ibe/users/da220/Cadence/WORK_TSMC180FORTE/DIGITAL/rtl/decoder/decoder.v"

module controller(
EN,
RW,
X_ADDRESS_IN,
Y_ADDRESS_IN,
P_DECODER_OUT,
NOT_P_DECODER_OUT,
N_DECODER_OUT,
NOT_N_DECODER_OUT,
Y_DECODER_OUT,
P_EN_REF,
NOT_P_EN_REF,
READ,
WRITE,
DVLP,
PRE,
EN_SA,
clk,
reset
);

// ASSUMING A M(ROWS) = 32 x 32 = N(COLUMNS) MEMORY ARRAY
// WITH WORD OF b = 4 BITS
// ----- X -----
// THEN THE NUMBER OF COLUMNS IS 32 / 4 = 8 = 2^(X_SIZE), X_SIZE = NUMBER OF BITS NEEDED TO REPRESENT ADDRESS OF COLUMNS IN BINARY.
// OR X_SIZE = LOG2(8) = LOG(N/b).
// THE ADDRESSES OF COLUMNS START FROM 0 TO 7
// SO A DECODER FROM [2:0]->[7:0] ([X_SIZE-1:0]->[(1<<X_SIZE)-1:0]) IS NEEDED 
// TO CHOSE THE CORRECT COLUMN ADDRESS.
// ----- Y ------
// THE NUMBER OF ROWS IS 32. EVERY TIME ONLY ONE ROW CAN BE SELECTED.
// A DECODER IS NEEDED FROM Y_SIZE = LOG2(M) = 5
// OR FROM [3:0]->[31:0] ([Y_SIZE-1:0]->[(1<<Y_SIZE)-1:0])


parameter B_SIZE = 4;	// WORD SIZE IN BITS 4*8 = 32
parameter X_SIZE = 3;	// BITS TO DESCRIBE ADDRESS OF WORDS COLUMN 2^3 = 8
parameter Y_SIZE = 5;	// BITS TO DESCRIBE ADDRESS OF SEL COLUMNS  2^5 = 32

localparam IDLE = 3'b000;
localparam RPH1 = 3'b001;
localparam RPH2 = 3'b010;
localparam RPH3 = 3'b011;
localparam WPH1 = 3'b100;

// Inputs
input 			EN;
input			RW;
input	[X_SIZE-1:0]	X_ADDRESS_IN;
input	[Y_SIZE-1:0]	Y_ADDRESS_IN;
input 			clk;
input			reset;

// Outputs
output 	[((1<<X_SIZE)-1):0]	P_DECODER_OUT;
output 	[((1<<X_SIZE)-1):0]	N_DECODER_OUT;
output	[((1<<X_SIZE)-1):0]	NOT_P_DECODER_OUT;
output	[((1<<X_SIZE)-1):0]	NOT_N_DECODER_OUT;
output 	[((1<<Y_SIZE)-1):0]	Y_DECODER_OUT;
output				P_EN_REF;
output				NOT_P_EN_REF;
output				READ;
output				WRITE;
output				DVLP;
output				PRE;
output				EN_SA;

// Wires
wire 			EN;
wire			RW;
wire	[X_SIZE-1:0]	X_ADDRESS_IN;
wire	[Y_SIZE-1:0]	Y_ADDRESS_IN;
wire 			clk;
wire			reset;
wire 	[((1<<X_SIZE)-1):0]	P_DECODER_OUT;
wire 	[((1<<X_SIZE)-1):0]	N_DECODER_OUT;
wire 	[((1<<Y_SIZE)-1):0]	Y_DECODER_OUT;
wire 	[((1<<X_SIZE)-1):0]	NOT_P_DECODER_OUT;
wire 	[((1<<X_SIZE)-1):0]	NOT_N_DECODER_OUT;
wire			NOT_P_EN_REF;




// Registers
reg				P_EN_REF;
reg				READ;
reg				WRITE;
reg				DVLP;
reg				PRE;
reg				EN_SA;
reg				Y_ADDRESS_EN;
reg				P_ADDRESS_EN;
reg				N_ADDRESS_EN;

// Registers CONTROLLER <-> P_DECODER and N_DECODER
reg 	[X_SIZE-1:0]	X_ADDRESS_CON_DEC;
// Registers CONTROLLER <-> P_DECODER 
reg			P_DECODER_EN;
// Registers CONTROLLER <-> N_DECODER
reg			N_DECODER_EN;
// Registers CONTROLLER <-> Y_DECODER
reg 	[Y_SIZE-1:0]	Y_ADDRESS_CON_DEC;
reg			Y_DECODER_EN;

// Internal Variables used for FSM
reg 	[2:0]		state;
reg	[2:0]		nstate;


// INSTANTIATION OF P DECODER
decoder #(X_SIZE) P_decoder(
.binary_in	(X_ADDRESS_CON_DEC), 	//  X_ADDRESS_BINARY
.decoder_out 	(P_DECODER_OUT),	//  P_DECODER_OUTPUT
.enable		(P_ADDRESS_EN)   	//  ENABLE
);

// INSTANTIATION OF N DECODER
decoder #(X_SIZE) N_decoder(
.binary_in	(X_ADDRESS_CON_DEC), 	//  X_ADDRESS_BINARY
.decoder_out 	(N_DECODER_OUT),	//  N_DECODER_OUTPUT
.enable		(N_ADDRESS_EN)   	//  ENABLE
);

// INSTANTIATION OF Y DECODER
decoder #(Y_SIZE) Y_decoder(
.binary_in	(Y_ADDRESS_CON_DEC), 	//  X_ADDRESS_BINARY
.decoder_out 	(Y_DECODER_OUT),	//  Y_DECODER_OUTPUT
.enable		(Y_ADDRESS_EN)   	//  ENABLE
);

// INSTANTIATION OF COMPLEMENTARY OUTPUTS
assign NOT_P_DECODER_OUT = ~P_DECODER_OUT;
assign NOT_N_DECODER_OUT = ~N_DECODER_OUT;
assign NOT_P_EN_REF = ~P_EN_REF;


always @ * begin
	case(state)
		/*IDLE: begin
			if (EN == 1 && RW == 1)	begin			
					nstate = RPH1;
			end else if (EN == 1 && RW == 0) begin
					nstate = WPH1;
			end
		end*/
		IDLE: nstate = EN ? (RW ? RPH1 : WPH1) : IDLE;
		RPH1: nstate = RPH2;
		RPH2: nstate = RPH3;
		RPH3: nstate = IDLE;
		WPH1: nstate = IDLE;
	endcase
end

always @ ( posedge clk ) begin
 	if ( reset ) begin
 		state <= IDLE ;
 	end else begin
 		state <= nstate ;
	end
end

always @ * begin
	case(state)
	IDLE:	begin
		Y_ADDRESS_EN = 0;
		P_ADDRESS_EN = 0;
		N_ADDRESS_EN = 0;
		P_EN_REF = 0;
		READ = 0;
		WRITE = 0;
		DVLP = 0;
		PRE = 0;
		EN_SA = 0;	
	end
	RPH1:	begin
		Y_ADDRESS_EN = 1;
		P_ADDRESS_EN = 1;
		N_ADDRESS_EN = 0;
		P_EN_REF = 1;
		READ = 1;
		WRITE = 0;
		X_ADDRESS_CON_DEC = X_ADDRESS_IN;
		Y_ADDRESS_CON_DEC = Y_ADDRESS_IN;
		DVLP = 1;
		PRE = 0;
		EN_SA = 0;
	end
	RPH2:	begin
		Y_ADDRESS_EN = 1;
		P_ADDRESS_EN = 1;
		N_ADDRESS_EN = 0;
		P_EN_REF = 1;
		READ = 1;
		WRITE = 0;
		X_ADDRESS_CON_DEC = X_ADDRESS_CON_DEC;
		Y_ADDRESS_CON_DEC = Y_ADDRESS_CON_DEC;
		DVLP = 1;
		PRE = 1;
		EN_SA = 0;
	end	
	RPH3:	begin
		Y_ADDRESS_EN = 0;
		P_ADDRESS_EN = 0;
		N_ADDRESS_EN = 0;
		P_EN_REF = 0;
		READ = 1;
		WRITE = 0;		
		DVLP = 0;
		PRE = 1;
		EN_SA = 1;
	end
	WPH1:	begin
		Y_ADDRESS_EN = 1;
		P_ADDRESS_EN = 1;
		N_ADDRESS_EN = 1;
		X_ADDRESS_CON_DEC = X_ADDRESS_IN;
		Y_ADDRESS_CON_DEC = Y_ADDRESS_IN;
		P_EN_REF = 0;
		READ = 0;
		WRITE = 1;		
		DVLP = 0;
		PRE = 0;
		EN_SA = 0;
	end			
	endcase
end


endmodule	// endmodule
