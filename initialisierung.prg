#include "globaleVariablen.inc"

Function setGlobals
	
	' Deklarieren der Bit-Adressen für die Nest-Sensoren
    WT_INPUT_GS(1) = 532 ' Nest1_GS
    WT_INPUT_AS(1) = 533 ' Nest1_AS
    WT_INPUT_GS(2) = 534 ' Nest2_GS
    WT_INPUT_AS(2) = 535 ' Nest2_AS
    WT_INPUT_GS(3) = 548 ' Nest3_GS
    WT_INPUT_AS(3) = 549 ' Nest3_AS
    WT_INPUT_GS(4) = 550 ' Nest4_GS
    WT_INPUT_AS(4) = 551 ' Nest4_AS
    
    WT_OUTPUT_GS(1) = 532 ' Nest1_GS
    WT_OUTPUT_AS(1) = 533 ' Nest1_AS
    WT_OUTPUT_GS(2) = 534 ' Nest2_GS
    WT_OUTPUT_AS(2) = 535 ' Nest2_AS
    WT_OUTPUT_GS(3) = 537 ' Nest3_GS
    WT_OUTPUT_AS(3) = 538 ' Nest3_AS
    WT_OUTPUT_GS(4) = 539 ' Nest4_GS
    WT_OUTPUT_AS(4) = 540 ' Nest4_AS
    
    G_CURRENTPARTNAME$(1) = "10286"
    G_CURRENTPARTNAME$(2) = "10287"
    G_CURRENTPARTNAME$(3) = "10312"
    G_CURRENTPARTNAME$(4) = "10313"
    G_CURRENTPARTNAME$(5) = "10314"
    
    TestTimer = Tmr(0)
Fend

