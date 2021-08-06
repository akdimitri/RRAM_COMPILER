;--------------------------------------------------------------------------------------------------------------------------------------------
; Author:		Dimitrios Antoniadis
; Date:			03/08/2021
; Description:	This file contains the SKILL function to simulate the mixed signal design of a RRAM
;-------------------------------------------------------------------------------------------------------------------------------------------- 
procedure( simulateRRAM(		; LIST OF ARGUMENTS
						X		; NUMBER OF COLUMNS X
						Y		; NUMBER OF ROWS Y						
						B		; BITS OF A WORD B
						;DB_TOP	; DB SYMBOL OF TOP LEVEL
						@optional
						(CLOCK_PS		10000)	; 10ns digital clock
						(LIBRARY "THESIS")
						(VDDW		3.3)
						(RATIO		0.3)						
						(VDDH 		5)
						(VDDL		1.8)
						)		; END OF LIST OF ARGUMENTS

	prog(	(			; LIST OF LOCAL VARIABLES
			OUT_PORT		; PORT TO WRITE TO FILE
			FILE		
			;CMD			; CMD RUN
			DIR			; VARIABLE USED FOR DIRECTORIES
			NAME
			TSMC_PDK_PATH
			USER
			STR
			)			; END OF LIST OF LOCAL VARIABLES

	TSMC_PDK_PATH = getShellEnvVar("TSMC_PDK_PATH")
	USER = getShellEnvVar("USER")

	sprintf(NAME "TB_TOP_%d_%d_%d" X Y B)	
	sprintf(DIR "%s/%s/%s/.CHARACTERIZATION" pwd() LIBRARY NAME)
	sprintf(FILE "%s/characterizeRRAMscript.ocn" DIR)

	OUT_PORT = outfile( FILE "w")
	fprintf(OUT_PORT ";============================================\n")
	fprintf(OUT_PORT ";===               RRAM COMPILER          ===\n")
	fprintf(OUT_PORT ";===            DIMITRIS ANTONIADIS       ===\n")
	fprintf(OUT_PORT ";===          IMPERIAL COLLEGE LONDON     ===\n")
	fprintf(OUT_PORT ";============================================\n")
	fprintf(OUT_PORT ";====================Set to Maestro mode explorer =============================\n")
  fprintf(OUT_PORT "envSetVal(\"adexl.simulation\" \"ignoreDesignChangesDuringRun\" 'boolean t)\n")
	fprintf(OUT_PORT "envSetVal(\"maestro.explorer\" \"onHistoryNameCollision\" 'cyclic \"IncrementAsNew\")\n")
	fprintf(OUT_PORT "ocnSetXLMode(\"explorer\")\n")
	fprintf(OUT_PORT "ocnxlProjectDir( \"/tmp/%s/Sim\" )\n" USER)
	fprintf(OUT_PORT "ocnxlTargetCellView( \"%s\" \"%s\" \"maestro\" )\n" LIBRARY NAME)
	fprintf(OUT_PORT "ocnxlResultsLocation( \"/tmp/%s/ADE_XL\" )\n" USER)
	fprintf(OUT_PORT "ocnxlSimResultsLocation( \"/tmp/%s/Res\" )\n" USER)
	fprintf(OUT_PORT "ocnxlMaxJobFail( 20 )\n")

	fprintf(OUT_PORT "\n;====================== Tests setup ============================================\n\n")
	fprintf(OUT_PORT ";---------- Test \"%s\" ------------- \n" NAME)
	fprintf(OUT_PORT "ocnxlBeginTest(\"%s:%s:1\")\n" LIBRARY NAME)
	fprintf(OUT_PORT "simulator( 'ams )\n")
	fprintf(OUT_PORT "solver( 'Spectre )\n")
	fprintf(OUT_PORT "design( \"%s\" \"%s\" \"config\" )\n" LIBRARY NAME)
	fprintf(OUT_PORT "ocnAmsSetUnlNetlister()\n")
	fprintf(OUT_PORT "modelFile( \n")
	fprintf(OUT_PORT "\t'(\"%s/models/spectre/c018bcd_gen2_v1d6_usage.scs\" \"pre_simu\")\n" TSMC_PDK_PATH)
	fprintf(OUT_PORT "\t'(\"%s/models/spectre/c018bcd_gen2_v1d6_usage.scs\" \"tt_lib\")\n" TSMC_PDK_PATH)
	fprintf(OUT_PORT "\t'(\"%s/param_test\" \"\")\n" DIR)
	fprintf(OUT_PORT ")\n")
	fprintf(OUT_PORT "analysis('tran ?stop \"%fu\"  ?errpreset \"liberal\"  ?additionalParams \"paramset=pset1\"  )\n" CLOCK_PS/1000.0/1000.0*60)
	fprintf(OUT_PORT "desVar(	  \"Re\" 1	)\n")
	fprintf(OUT_PORT "desVar(	  \"Ro\" 1	)\n")
	fprintf(OUT_PORT "desVar(	  \"VDDH\" %f	)\n" float(VDDH))
	fprintf(OUT_PORT "desVar(	  \"VDDL\" %f	)\n" float(VDDL))
	fprintf(OUT_PORT "desVar(	  \"VDDW\" %f	)\n" float(VDDW))
	fprintf(OUT_PORT "desVar(	  \"CLK\" %fn	)\n" CLOCK_PS/1000.0)
	fprintf(OUT_PORT "envOption(\n")
	fprintf(OUT_PORT "\t'netlisterMode  \"AMS-UNL\"\n")
	fprintf(OUT_PORT "\t'amsIEsList  '((t \"global\" \"\" \"Value\" \"%f\" \"connectLib.CR_full_fast\" \"\" \"logic\" \"discipline=logic;\" \"Built-in\") (t \"inst\" \"/TOP/SIGNALS_VDDL\" \"Value\" \"%f\" \"connectLib.CR_full_fast\" \"\" \"\" \"inst=\\\"/TOP/SIGNALS_VDDL\\\";\" \"Built-in\") (t \"net\" \"/Z_BUS\" \"Value\" \"%f\" \"connectLib.CR_full_fast\" \"\" \"\" \"net=\\\"/Z_BUS\\\";\" \"Built-in\"))\n" float(VDDH) float(VDDL) float(VDDL))
	fprintf(OUT_PORT "\t'builtinuser  nil \n")	
	fprintf(OUT_PORT ")\n")
	fprintf(OUT_PORT "option( ?categ 'amsTurboOpts\n")
	fprintf(OUT_PORT "\t'psrSwitch  t \n")
	;fprintf(OUT_PORT "\t'proc_affinity  \"8\" \n")
	fprintf(OUT_PORT "\t'apsplus  t \n")
	fprintf(OUT_PORT "\t'errorLevel  \"Liberal\" \n")
	fprintf(OUT_PORT "\t'uniMode  \"APS\" \n")
	fprintf(OUT_PORT ")\n")
	fprintf(OUT_PORT "option( ?categ 'elaborator\n")
	fprintf(OUT_PORT "\t'delay_mode  \"Path\" \n")
	fprintf(OUT_PORT "\t'ntc_warn  t \n")
	fprintf(OUT_PORT "\t'no_tchk_msg  t \n")
	fprintf(OUT_PORT "\t'sdf_verbose  t \n")
	fprintf(OUT_PORT "\t'intermod_path  t \n")
	fprintf(OUT_PORT "\t'delay_type  \"Maximum\"\n")
	fprintf(OUT_PORT "\t'sdf_cmd_file  \"%s/%s_SDF_CMD\"\n" DIR NAME)
	fprintf(OUT_PORT ")\n")

	sprintf(STR "save( 'v \"/clk\" \"/EN\" \"/RW\" \"/X_ADDRESS_IN<%d:0>\" \"/Y_ADDRESS_IN<%d:0>\" \"/reset\" \"/Z_BUS<%d:0>\" " int(log(X/B)/log(2))-1 int(log(Y)/log(2))-1 B-1)
	for(j 0 B-1
		sprintf(STR "%s \"/TOP/Z_SA<%d>\" " STR j)
	)
	for(j 0 B-1
		sprintf(STR "%s \"/P<%d>\" " STR X-B-1-j)
	)
	for(j 0 B-1
		sprintf(STR "%s \"/TOP/RRAM_ANALOG/N<%d>\" " STR X-B-j)
	)
	fprintf(OUT_PORT "%s)\n" STR)
	;fprintf(OUT_PORT "save( 'i \"/TOP/VDDH\" \"/TOP/VDDW\" \"/TOP/VDDL\" \"/TOP/LEVEL_DOWN/VDD\" )\n")
	fprintf(OUT_PORT "temp( 27 ) \n")
	fprintf(OUT_PORT "ocnxlOutputSignal( \"/clk\" ?plot t ?save t)\n")
	fprintf(OUT_PORT "ocnxlOutputSignal( \"/EN\" ?plot t ?save t)\n")
	fprintf(OUT_PORT "ocnxlOutputSignal( \"/RW\" ?plot t ?save t)\n")
	fprintf(OUT_PORT "ocnxlOutputSignal( \"/X_ADDRESS_IN<%d:0>\" ?plot t ?save t)\n" int(log(X/B)/log(2))-1)
	fprintf(OUT_PORT "ocnxlOutputSignal( \"/Y_ADDRESS_IN<%d:0>\" ?plot t ?save t)\n" int(log(Y)/log(2))-1)
	fprintf(OUT_PORT "ocnxlOutputSignal( \"/reset\" ?plot t ?save t)\n")
	fprintf(OUT_PORT "ocnxlOutputSignal( \"/Z_BUS<%d:0>\" ?plot t ?save t)\n" B-1)
	fprintf(OUT_PORT "ocnxlOutputSignal( \"/TOP/RRAM_ANALOG/SA_IN<1:%d>\" ?plot t ?save t)\n" B)
	fprintf(OUT_PORT "ocnxlOutputSignal( \"/TOP/RRAM_ANALOG/SA_IN<%d:%d>\" ?plot t ?save t)\n" B+1 2*B) 
	for(j 1 B
		fprintf(OUT_PORT "ocnxlOutputSignal( \"/TOP/RRAM_ANALOG/SA_VO<%d>\" ?plot t ?save t)\n" j)
		fprintf(OUT_PORT "ocnxlOutputSignal( \"/TOP/RRAM_ANALOG/net1<%d>\" ?plot t ?save t)\n" j-1)
	)
	
	;fprintf(OUT_PORT "ocnxlOutputTerminal( \"/TOP/VDDH\" ?save t)\n")
	;fprintf(OUT_PORT "ocnxlOutputSignal( \"/VDDH\" ?save t)\n")
	;fprintf(OUT_PORT "ocnxlOutputTerminal( \"/TOP/VDDW\" ?save t)\n")
	;fprintf(OUT_PORT "ocnxlOutputSignal( \"/VDDW\" ?save t)\n")
	;fprintf(OUT_PORT "ocnxlOutputTerminal( \"/TOP/VDDL\" ?save t)\n")
	;fprintf(OUT_PORT "ocnxlOutputSignal( \"/VDDL\" ?save t)\n")
	for(j 0 B-1
		fprintf(OUT_PORT "ocnxlOutputSignal( \"/TOP/Z_SA<%d>\" ?save t)\n" j)
	)
	for(j 0 B-1
		fprintf(OUT_PORT "ocnxlOutputSignal( \"/P<%d>\" ?save t)\n" X-B-1-j)
	)
	for( j 0 B-1
		fprintf(OUT_PORT "ocnxlOutputSignal( \"/TOP/RRAM_ANALOG/N<%d>\" ?save t)\n" X-B-j)
	)
	fprintf(OUT_PORT "ocnxlOutputExpr( \"numConv(value(VT(\\\"/Z_BUS<%d:0>\\\") (27.4 * VAR(\\\"CLK\\\"))) \\\"bin\\\" t)\" ?name \"READ_2\" ?plot t)\n" B-1)
	
	for(j 0 B-1
		fprintf(OUT_PORT "ocnxlOutputExpr( \"value((VT(\\\"/P<%d>\\\") - VT(\\\"/TOP/RRAM_ANALOG/N<%d>\\\")) (11.4 * VAR(\\\"CLK\\\")))\" ?name \"WRITE_1_%d\" ?plot t)\n" X-B-1-j X-B-j B-j-1)
	)
	for(j 0 B-1
		fprintf(OUT_PORT "ocnxlOutputExpr( \"value((VT(\\\"/P<%d>\\\") - VT(\\\"/TOP/RRAM_ANALOG/N<%d>\\\")) (13.4 * VAR(\\\"CLK\\\")))\" ?name \"WRITE_2_%d\" ?plot t)\n" X-B-1-j X-B-j B-j-1)
	)
	for(j 0 B-1
		fprintf(OUT_PORT "ocnxlOutputExpr( \"value(VT(\\\"/TOP/Z_SA<%d>\\\") (27.4 * VAR(\\\"CLK\\\")))\" ?name \"READ_1_%d\" ?plot t)\n" j j)
	)
	for(j 0 B-1
		fprintf(OUT_PORT "ocnxlOutputExpr( \"value(VT(\\\"/TOP/Z_SA<%d>\\\") (41.4 * VAR(\\\"CLK\\\")))\" ?name \"READ_2_%d\" ?plot t)\n" j j)
	)
	;fprintf(OUT_PORT "ocnxlOutputExpr( \"abs((IT(\\\"/TOP/VDDH\\\") * VT(\\\"/VDDH\\\")))\" ?name \"POWER_H\" ?plot t ?save t)\n")
	;fprintf(OUT_PORT "ocnxlOutputExpr( \"abs((IT(\\\"/TOP/VDDW\\\") * VT(\\\"/VDDW\\\")))\" ?name \"POWER_W\" ?plot t ?save t)\n")
	;fprintf(OUT_PORT "ocnxlOutputExpr( \"abs((IT(\\\"/TOP/VDDL\\\") * VT(\\\"/VDDL\\\")))\" ?name \"POWER_L\" ?plot t ?save t)\n")
	;fprintf(OUT_PORT "ocnxlOutputExpr( \"abs((IT(\\\"/TOP/LEVEL_DOWN/VDD\\\") * VT(\\\"/VDDL\\\")))\" ?name \"POWER_LVL_D\" ?plot t ?save t)\n")
	;fprintf(OUT_PORT "ocnxlOutputExpr( \"ymax(clip((POWER_H + POWER_L + POWER_W + POWER_LVL_D) (12 * %fn) (14 * %fn)))\" ?name \"MAX_POWER_WR\" ?plot t)\n" float(CLOCK_PS/1000) float(CLOCK_PS/1000))
	;fprintf(OUT_PORT "ocnxlOutputExpr( \"ymax(clip((POWER_H + POWER_L + POWER_W + POWER_LVL_D) (39 * %fn) (42 * %fn)))\" ?name \"MAX_POWER_RE\" ?plot t)\n" float(CLOCK_PS/1000) float(CLOCK_PS/1000))
	;;fprintf(OUT_PORT "ocnxlOutputExpr( \"value((POWER_H + POWER_L + POWER_W + POWER_LVL_D) (20 * %fn))\" ?name \"POWER_IDLE\" ?plot t)\n" float(CLOCK_PS/1000) float(CLOCK_PS/1000))
	;fprintf(OUT_PORT "ocnxlOutputExpr( \"average(clip((POWER_H + POWER_L + POWER_W + POWER_LVL_D) (39 * %fn) (42 * %fn)))\" ?name \"AV_POWER_RE\" ?plot t)\n" float(CLOCK_PS/1000) float(CLOCK_PS/1000))
	;fprintf(OUT_PORT "ocnxlOutputExpr( \"average(clip((POWER_H + POWER_L + POWER_W + POWER_LVL_D) (12 * %fn) (14 * %fn)))\" ?name \"AV_POWER_RE\" ?plot t)\n" float(CLOCK_PS/1000) float(CLOCK_PS/1000))
	fprintf(OUT_PORT "ocnxlOutputExpr( \"value(VT(\\\"/Z_BUS<3:0>\\\") (41.4 * %fn))\" ?name \"READ_2\" ?plot t)\n" float(CLOCK_PS/1000))
	fprintf(OUT_PORT "ocnxlOutputExpr( \"value(VT(\\\"/Z_BUS<3:0>\\\") (27.4 * %fn))\" ?name \"READ_1\" ?plot t)\n" float(CLOCK_PS/1000))
	
	fprintf(OUT_PORT "ocnxlEndTest()\n")	

	fprintf(OUT_PORT "\n;====================== Specs ==================================================\n\n")
	for(j 0 B-1
		if( mod(j,2)==0		
			then
				fprintf(OUT_PORT "ocnxlPutGreaterthanSpec( \"%s:%s:1\" \"READ_1_%d\" \"1.5\" )\n" LIBRARY NAME j)
				fprintf(OUT_PORT "ocnxlPutLessthanSpec( \"%s:%s:1\" \"READ_2_%d\" \"0.3\" )\n" LIBRARY NAME j)
				fprintf(OUT_PORT "ocnxlPutLessthanSpec( \"%s:%s:1\" \"WRITE_2_%d\" \"(-0.7 * VAR(\\\"VDDW\\\"))\" )\n" LIBRARY NAME j)
				fprintf(OUT_PORT "ocnxlPutGreaterthanSpec( \"%s:%s:1\" \"WRITE_1_%d\" \"(0.7 * VAR(\\\"VDDW\\\"))\" )\n" LIBRARY NAME j)
			else
				fprintf(OUT_PORT "ocnxlPutGreaterthanSpec( \"%s:%s:1\" \"READ_2_%d\" \"1.5\" )\n" LIBRARY NAME j)
				fprintf(OUT_PORT "ocnxlPutLessthanSpec( \"%s:%s:1\" \"READ_1_%d\" \"0.3\" )\n" LIBRARY NAME j)
				fprintf(OUT_PORT "ocnxlPutLessthanSpec( \"%s:%s:1\" \"WRITE_1_%d\" \"(-0.7 * VAR(\\\"VDDW\\\"))\" )\n" LIBRARY NAME j)
				fprintf(OUT_PORT "ocnxlPutGreaterthanSpec( \"%s:%s:1\" \"WRITE_2_%d\" \"(0.7 * VAR(\\\"VDDW\\\"))\" )\n" LIBRARY NAME j)
		)	
	)

	fprintf(OUT_PORT "\n;====================== Sweeps setup ===========================================\n\n")
	fprintf(OUT_PORT ";====================== Model Group setup ======================================\n\n")
	fprintf(OUT_PORT ";====================== Corners setup ==========================================\n\n")
	fprintf(OUT_PORT "ocnxlCorner( \"FS\"\n")
	fprintf(OUT_PORT "\t'(\n")
	fprintf(OUT_PORT "\t\t(\"model\" \"%s/models/spectre/c018bcd_gen2_v1d6_usage.scs\" ?section \"\\\"fs_lib\\\"\")\n" TSMC_PDK_PATH)
	fprintf(OUT_PORT "\t\t(\"model\" \"%s/param_test\" ?section \"\")\n" DIR)
	fprintf(OUT_PORT "\t\t(\"modelGroup\" \"\")\n")
	fprintf(OUT_PORT "\t)\n")
	fprintf(OUT_PORT ")\n")

	fprintf(OUT_PORT "ocnxlCorner( \"SF\"\n")
	fprintf(OUT_PORT "\t'(\n")
	fprintf(OUT_PORT "\t\t(\"model\" \"%s/models/spectre/c018bcd_gen2_v1d6_usage.scs\" ?section \"\\\"sf_lib\\\"\")\n" TSMC_PDK_PATH)
	fprintf(OUT_PORT "\t\t(\"model\" \"%s/param_test\" ?section \"\")\n" DIR)
	fprintf(OUT_PORT "\t\t(\"modelGroup\" \"\")\n")
	fprintf(OUT_PORT "\t)\n")
	fprintf(OUT_PORT ")\n")

	fprintf(OUT_PORT "ocnxlCorner( \"SS\"\n")
	fprintf(OUT_PORT "\t'(\n")
	fprintf(OUT_PORT "\t\t(\"model\" \"%s/models/spectre/c018bcd_gen2_v1d6_usage.scs\" ?section \"\\\"ss_lib\\\"\")\n" TSMC_PDK_PATH)
	fprintf(OUT_PORT "\t\t(\"model\" \"%s/param_test\" ?section \"\")\n" DIR)
	fprintf(OUT_PORT "\t\t(\"modelGroup\" \"\")\n")
	fprintf(OUT_PORT "\t)\n")
	fprintf(OUT_PORT ")\n")

	fprintf(OUT_PORT "ocnxlCorner( \"FF\"\n")
	fprintf(OUT_PORT "\t'(\n")
	fprintf(OUT_PORT "\t\t(\"model\" \"%s/models/spectre/c018bcd_gen2_v1d6_usage.scs\" ?section \"\\\"ff_lib\\\"\")\n" TSMC_PDK_PATH)
	fprintf(OUT_PORT "\t\t(\"model\" \"%s/param_test\" ?section \"\")\n" DIR)
	fprintf(OUT_PORT "\t\t(\"modelGroup\" \"\")\n")
	fprintf(OUT_PORT "\t)\n")
	fprintf(OUT_PORT ")\n")

	fprintf(OUT_PORT "\n;====================== Checks and Asserts setup ============================================\n")
	fprintf(OUT_PORT "ocnxlPutChecksAsserts(?netlist nil)\n")

	fprintf(OUT_PORT "\n;====================== Job setup ==============================================\n\n")
	fprintf(OUT_PORT "ocnxlJobSetup( '(\n")
	fprintf(OUT_PORT "\"blockemail\" \"1\"\n")
	fprintf(OUT_PORT "\"configuretimeout\" \"300\"\n")
	fprintf(OUT_PORT "\"defaultcpuvalue\" \"1\"\n")
	fprintf(OUT_PORT "\"defaultmemoryvalue\" \"1000\"\n")
	fprintf(OUT_PORT "\"distributionmethod\" \"Local\"\n")
	fprintf(OUT_PORT "\"jobruntype\" \"ICRP\"\n")
	fprintf(OUT_PORT "\"estimatememoryvalue\" \"\"\n")
	fprintf(OUT_PORT "\"estimationsimulationmode\" \"0\"\n")
	fprintf(OUT_PORT "\"lingertimeout\" \"300\"\n")
	fprintf(OUT_PORT "\"maxjobs\" \"1\"\n")
	fprintf(OUT_PORT "\"name\" \"Maestro Default\"\n")
	fprintf(OUT_PORT "\"preemptivestart\" \"1\"\n")
	fprintf(OUT_PORT "\"providecpuandmemorydata\" \"1\"\n")
	fprintf(OUT_PORT "\"reconfigureimmediately\" \"1\"\n")
	fprintf(OUT_PORT "\"runpointsvalue\" \"5\"\n")
	fprintf(OUT_PORT "\"runtimeout\" \"-1\"\n")
	fprintf(OUT_PORT "\"scaleestimatedbycpu\" \"100\"\n")
	fprintf(OUT_PORT "\"scaleestimatedbymemory\" \"100\"\n")
	fprintf(OUT_PORT "\"showerrorwhenretrying\" \"1\"\n")
	fprintf(OUT_PORT "\"showoutputlogerror\" \"0\"\n")
	fprintf(OUT_PORT "\"startmaxjobsimmed\" \"1\"\n")
	fprintf(OUT_PORT "\"starttimeout\" \"300\"\n")
	fprintf(OUT_PORT "\"usesameprocess\" \"1\"\n")
	fprintf(OUT_PORT "\"warndisklow\" \"0\"\n")
	fprintf(OUT_PORT "\"warnthresholdvalue\" \"100\"\n")
	fprintf(OUT_PORT ") )\n")

	fprintf(OUT_PORT "\n;====================== Disabled items =========================================\n\n")
	fprintf(OUT_PORT ";====================== Run Mode Options ======================================\n\n")
	fprintf(OUT_PORT ";====================== Starting Point Info ======================================\n\n")
	fprintf(OUT_PORT ";====================== Run command ============================================\n\n")
	fprintf(OUT_PORT "ocnxlRun( ?mode 'sweepsAndCorners ?nominalCornerEnabled t ?allCornersEnabled t ?allSweepsEnabled t)\n")
	fprintf(OUT_PORT "ocnxlOutputSummary(?exprSummary t ?specSummary t ?detailed t ?wave t)\n")
	fprintf(OUT_PORT "ocnxlExportOutputView( \"%s/%d_%s.html\" \"Detail\")\n" DIR int(CLOCK_PS/1000) NAME)
	fprintf(OUT_PORT "ocnxlExportOutputView( \"%s/%d_%s.csv\" \"Detail\")\n" DIR int(CLOCK_PS/1000) NAME)
	fprintf(OUT_PORT "ocnxlOpenResults()\n")
	fprintf(OUT_PORT "\n;====================== End XL Mode command ===================================\n\n")
	fprintf(OUT_PORT "ocnxlEndXLMode(\"explorer\")\n")

	close(OUT_PORT)

	sprintf(FILE "%s/param_test" DIR)
	OUT_PORT = outfile( FILE "w")	
	fprintf(OUT_PORT "simulator lang=spectre\n")
	fprintf(OUT_PORT "pset1 paramset {\n")
    fprintf(OUT_PORT "time  Re  Ro  \n")
    fprintf(OUT_PORT "0n    %fk	 %fk\n" RATIO*32.5 1/RATIO*32.5)
    fprintf(OUT_PORT "%fn	%fk	%fk\n" float(CLOCK_PS/1000*34) 1/RATIO*32.5 RATIO*32.5)
	fprintf(OUT_PORT "}\n")
	close(OUT_PORT)

	sprintf(FILE "%s/characterizeRRAMscript.ocn" DIR)
	load(FILE)
	return(t)	
	)	; prog
)	; procedure
