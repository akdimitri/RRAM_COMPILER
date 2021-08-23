//-----------------------------------------------------
// Design Name 	: tb_signals_vddw
// File Name   	: tb_signals_vddw.v
// Function    	: vddw signals testbench
// Coder       	: Dimitris Antoniadis
// Date			: 14/07/2021
//-----------------------------------------------------

module	tb_signals_vddl();

reg	WRITE_VDDH;
reg	READ_VDDH;
reg	DVLP_H;
reg	PRE_H;
reg	SA_EN_H;
reg	dummy_en;

wire	WRITE_VDDL;
wire	NOT_WRITE_VDDL;
wire	READ_VDDL_1;
wire	NOT_READ_VDDL_1;
wire	READ_VDDL_2;
wire	NOT_READ_VDDL_2;
wire 	DVLP_L;
wire	PRE_L;
//wire	SA_EN_L;

// MODIFY NAME //
signals_vddl U1(
// END MODIFY NAME //
WRITE_VDDH,
READ_VDDH,
DVLP_H,
PRE_H,
SA_EN_H,
dummy_en,
WRITE_VDDL,
NOT_WRITE_VDDL,
READ_VDDL_1,
NOT_READ_VDDL_1,
READ_VDDL_2,
NOT_READ_VDDL_2,
DVLP_L,
PRE_L
//SA_EN_L,
);

initial begin
$dumpfile("tb_signals_vddl.vcd");
$dumpvars;
dummy_en = 1;
WRITE_VDDH = 0;
READ_VDDH = 0;
DVLP_H = 0;
PRE_H = 0;
SA_EN_H = 0;
#10;
WRITE_VDDH= 1;
READ_VDDH = 1;
DVLP_H = 1;
PRE_H = 1;
SA_EN_H = 1;
#10;
WRITE_VDDH = 0;
READ_VDDH = 0;
DVLP_H = 0;
PRE_H = 0;
SA_EN_H = 0;
#10;
$display("SUCCESS");
$finish;
end

endmodule