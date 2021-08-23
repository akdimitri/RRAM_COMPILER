//-----------------------------------------------------
// Design Name 	: controller_5V testbench
// File Name   	: tb_controller_5V.v
// Function    	: test correct functionality of decoder
// Coder       	: Dimitris Antoniadis
// Date		: 11/6/2021
//-----------------------------------------------------

// MODIFY NAME //
module tb_controller_5V();
// END MODIFY NAME //

// RRAM 64 64
// B = 4 Bits
// X=log2(64/4)=4
// SKILL CODE TO MODIFY HERE //
parameter B_SIZE = 4;	// WORD SIZE IN BITS
parameter X_SIZE = 4;	// BITS TO DESCRIBE ADDRESS OF WORDS COLUMN 2^4 = 16
parameter Y_SIZE = 6;	// BITS TO DESCRIBE ADDRESS OF SEL COLUMNS  2^5 = 32
// END OF SKILL MODIFICATION //

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
wire 	[(1<<X_SIZE):0]		P_EN;
wire 	[(1<<X_SIZE):0]		P_NOT_EN;
wire 	[(1<<X_SIZE)-1:0]	N_EN;
wire 	[(1<<X_SIZE)-1:0]	N_NOT_EN;
wire	[((1<<Y_SIZE)-1):0]	SEL;
wire			READ;
wire			WRITE;
wire			DVLP;
wire			PRE;
wire			EN_SA;
wire			NOT_WRITE;

// CLOCK
parameter CLOCK_PULSE_DURATION = 20;
always #(CLOCK_PULSE_DURATION/2) clk = ~clk;

// MODIFY CONTROLLER NAME //
controller_5V #(B_SIZE, X_SIZE, Y_SIZE) controller1(
// END MODIFY CONTROLLER NAME //
.EN			(EN),
.RW			(RW),
.X_ADDRESS_IN		(X_ADDRESS_IN),
.Y_ADDRESS_IN		(Y_ADDRESS_IN),
.P_EN			(P_EN),
.P_NOT_EN		(P_NOT_EN),
.N_EN			(N_EN),
.N_NOT_EN		(N_NOT_EN),
.SEL			(SEL),
.READ			(READ),
.WRITE			(WRITE),
.NOT_WRITE		(NOT_WRITE),
.DVLP			(DVLP),
.PRE			(PRE),
.EN_SA			(EN_SA),
.clk			(clk),
.reset			(reset)
);

`ifdef SDF_ANNOTATE_TASK
  initial
    $sdf_annotate  ("file.sdf",tb_controller_5V.controller1, , ,"MAXIMUM");
`endif

//irun -access +r -timescale 1ns/10ps -sdf_simtime -sdf_file ../../../constraints/CONTROLLER_5V_8_8_4/CONTROLLER_5V_8_8_4_syn.sdf  -sdf_verbose  -define SDF_ANNOTATE_TASK ../../../rtl/CONTROLLER_5V_8_8_4/CONTROLLER_5V_8_8_4_syn.v ../../../rtl/CONTROLLER_5V_8_8_4/tb_CONTROLLER_5V_8_8_4.v $TSMC_PDK_PATH/tsmc_libraries/TSMCHOME/digital/Front_End/verilog/tcb018gbwp7t_270a/original_tcb018gbwp7t.v

// TESTBENCH
initial begin
	// INITIALISATION
	$dumpfile("tb_controller_5V.vcd");
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
		tb_controller_5V.X_ADDRESS_IN <= X_ADDRESS_IN;
		tb_controller_5V.Y_ADDRESS_IN <= Y_ADDRESS_IN;
		tb_controller_5V.EN <= 1;
		tb_controller_5V.RW <= 0;
	end
	@ (posedge clk) begin
		tb_controller_5V.EN <= 0;		
	end	
	@ (negedge clk) begin
		if (tb_controller_5V.P_EN != temp_p_en) begin
			$display("%0ds \t ERROR on WRITING on X = %b\n", $time, X_ADDRESS_IN);
			$finish;
		end
		if (tb_controller_5V.SEL != temp_sel) begin
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
		tb_controller_5V.X_ADDRESS_IN <= X_ADDRESS_IN;
		tb_controller_5V.Y_ADDRESS_IN <= Y_ADDRESS_IN;
		tb_controller_5V.EN <= 1;
		tb_controller_5V.RW <= 1;
	end
	@ (posedge clk) begin
		tb_controller_5V.EN <= 0;		
	end	
	@ (negedge clk) begin
		if (tb_controller_5V.P_EN != temp_p_en) begin
			$display("%0ds \t ERROR on WRITING on X = %b\n", $time, X_ADDRESS_IN);
			$finish;
		end
		if (tb_controller_5V.SEL != temp_sel) begin
			$display("%0ds \t ERROR on WRITING on Y = %b\n", $time, Y_ADDRESS_IN);
			$finish;
		end
		//if (controller1.controller1.state != RPH1) begin
		//	$display("%0ds \t ERROR on STATE on RPH1\n", $time);
		//	$finish;
		//end
	end
	@ (negedge clk) #1; //begin #1;
		//if (controller1.controller1.state != RPH2) begin
		//	$display("%0ds \t ERROR on STATE on RPH2\n", $time);
		//	$finish;
		//end
	//end
	@ (negedge clk) #1;
		//if (controller1.controller1.state != RPH3) begin
		//	$display("%0ds \t ERROR on STATE on RPH3\n", $time);
		//	$finish;
		//end
end
endtask
endmodule

