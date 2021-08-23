//-----------------------------------------------------
// Design Name 	: controller testbench
// File Name   	: tb_controller.v
// Function    	: test correct functionality of decoder
// Coder       	: Dimitris Antoniadis
// Date		: 11/6/2021
//-----------------------------------------------------
module tb_controller();

// RRAM ARRAY 32*32, b=2
// COLUMNS 16
parameter B_SIZE = 2;	// WORD SIZE IN BITS
parameter X_SIZE = 4;	// BITS TO DESCRIBE ADDRESS OF WORDS COLUMN 2^4 = 16
parameter Y_SIZE = 5;	// BITS TO DESCRIBE ADDRESS OF SEL COLUMNS  2^5 = 32

localparam IDLE = 3'b000;
localparam RPH1 = 3'b001;
localparam RPH2 = 3'b010;
localparam RPH3 = 3'b011;
localparam WPH1 = 3'b100;

// Registers
reg			EN;
reg			RW;
reg	[X_SIZE-1:0]	X_ADDRESS_IN;
reg	[Y_SIZE-1:0]	Y_ADDRESS_IN;
reg			clk;
reg			reset;

// Wire
wire 	[(1<<X_SIZE):0]	P_EN;
wire 	[(1<<X_SIZE):0]	NOT_P_EN;
wire 	[(1<<X_SIZE)-1:0]	N_EN;
wire 	[(1<<X_SIZE)-1:0]	NOT_N_EN;
wire	[((1<<Y_SIZE)-1):0]	SEL;
wire			READ;
wire			WRITE;
wire			DVLP;
wire			PRE;
wire			EN_SA;

// CLOCK
parameter CLOCK_PULSE_DURATION = 20;
always #(CLOCK_PULSE_DURATION/2) clk = ~clk;

// CONTROLLER
controller #(B_SIZE, X_SIZE, Y_SIZE) controller1(
.EN			(EN),
.RW			(RW),
.X_ADDRESS_IN		(X_ADDRESS_IN),
.Y_ADDRESS_IN		(Y_ADDRESS_IN),
.P_DECODER_OUT		(P_EN[(1<<X_SIZE)-1:0]),
.NOT_P_DECODER_OUT 	(NOT_P_EN[(1<<X_SIZE)-1:0]),
.N_DECODER_OUT		(N_EN),
.NOT_N_DECODER_OUT	(NOT_N_EN),
.Y_DECODER_OUT		(SEL),
.P_EN_REF		(P_EN[1<<X_SIZE]),
.NOT_P_EN_REF		(NOT_P_EN[1<<X_SIZE]),
.READ			(READ),
.WRITE			(WRITE),
.DVLP			(DVLP),
.PRE			(PRE),
.EN_SA			(EN_SA),
.clk			(clk),
.reset			(reset)
);



// TESTBENCH
initial begin
	// INITIALISATION
	$dumpfile("tb_controller.vcd");
	$dumpvars;
	reset = 0;
	clk = 0;
	EN = 0;
	RW = 0;
	X_ADDRESS_IN = 0;
	Y_ADDRESS_IN = 0;


	#11
	@ (posedge clk) begin
		 reset <= 1;
	end
	#11
	@ (posedge clk) begin
		 reset <= 0;
	end
	#11
	write_memory(2, 4);
	write_memory((1<<X_SIZE)-1, (1<<Y_SIZE)-1);

	#200
	read_memory(2, 4);
	read_memory((1<<X_SIZE)-1, (1<<Y_SIZE)-1);
	#200
	

$display("SUCCESS");
$finish;	
end


task write_memory;
input [X_SIZE-1:0]	X_ADDRESS_IN;
input [Y_SIZE-1:0]	Y_ADDRESS_IN;
begin: WRITE_TASK
	reg [(1<<X_SIZE):0] temp_p_en;
	reg [((1<<Y_SIZE)-1):0]	temp_sel;
	temp_p_en[(1<<X_SIZE)-1:0] =  1<<X_ADDRESS_IN;
	temp_p_en[1<<X_SIZE] = 0;
	temp_sel = 1 << Y_ADDRESS_IN;
	@ (posedge clk) begin
		tb_controller.X_ADDRESS_IN <= X_ADDRESS_IN;
		tb_controller.Y_ADDRESS_IN <= Y_ADDRESS_IN;
		tb_controller.EN <= 1;
		tb_controller.RW <= 0;
	end
	@ (posedge clk) begin
		tb_controller.EN <= 0;		
	end	
	@ (negedge clk) begin
		if (tb_controller.P_EN != temp_p_en) begin
			$display("%0ds \t ERROR on WRITING on X = %b\n", $time, X_ADDRESS_IN);
			$finish;
		end
		if (tb_controller.SEL != temp_sel) begin
			$display("%0ds \t ERROR on WRITING on Y = %b\n", $time, Y_ADDRESS_IN);
			$finish;
		end
	end
end
endtask

task read_memory;
input [X_SIZE-1:0]	X_ADDRESS_IN;
input [Y_SIZE-1:0]	Y_ADDRESS_IN;
begin: READ_TASK
	reg [(1<<X_SIZE):0] temp_p_en;
	reg [((1<<Y_SIZE)-1):0]	temp_sel;
	temp_p_en[(1<<X_SIZE)-1:0] =  1<<X_ADDRESS_IN;
	temp_p_en[1<<X_SIZE] = 1;
	temp_sel = 1 << Y_ADDRESS_IN;
	@ (posedge clk) begin
		tb_controller.X_ADDRESS_IN <= X_ADDRESS_IN;
		tb_controller.Y_ADDRESS_IN <= Y_ADDRESS_IN;
		tb_controller.EN <= 1;
		tb_controller.RW <= 1;
	end
	@ (posedge clk) begin
		tb_controller.EN <= 0;		
	end	
	@ (negedge clk) begin
		if (tb_controller.P_EN != temp_p_en) begin
			$display("%0ds \t ERROR on WRITING on X = %b\n", $time, X_ADDRESS_IN);
			$finish;
		end
		if (tb_controller.SEL != temp_sel) begin
			$display("%0ds \t ERROR on WRITING on Y = %b\n", $time, Y_ADDRESS_IN);
			$finish;
		end
		if (controller1.state != RPH1) begin
			$display("%0ds \t ERROR on STATE on RPH1\n", $time);
			$finish;
		end
	end
	@ (negedge clk) begin
		if (controller1.state != RPH2) begin
			$display("%0ds \t ERROR on STATE on RPH2\n", $time);
			$finish;
		end
	end
	@ (negedge clk) 
		if (controller1.state != RPH3) begin
			$display("%0ds \t ERROR on STATE on RPH3\n", $time);
			$finish;
		end
end
endtask
endmodule
