Function init
	
	Call setGlobals			' deklaration der Variablen
	
	If Motor = Off Then
		Motor On
	EndIf
	
	Power High
	
	SpeedFactor 100
	
	Speed 75
	Accel 75, 75
	SpeedS 750
	AccelS 500

	OutW Coldjet_senden, CJ_out_AUS
	OutW Rckgabewert_SPS, RM_START
	
Fend


Function setGlobals
	
'	Deklarieren der Bit-Adressen für die Nest-Sensoren
    WT_INPUT_BIT_GS(1) = 532 ' Nest1_GS
    WT_INPUT_BIT_AS(1) = 533 ' Nest1_AS
    WT_INPUT_BIT_GS(2) = 534 ' Nest2_GS
    WT_INPUT_BIT_AS(2) = 535 ' Nest2_AS
    WT_INPUT_BIT_GS(3) = 548 ' Nest3_GS
    WT_INPUT_BIT_AS(3) = 549 ' Nest3_AS
    WT_INPUT_BIT_GS(4) = 550 ' Nest4_GS
    WT_INPUT_BIT_AS(4) = 551 ' Nest4_AS
    
    WT_OUTPUT_BIT_GS(1) = 532 ' Nest1_GS
    WT_OUTPUT_BIT_AS(1) = 533 ' Nest1_AS
    WT_OUTPUT_BIT_GS(2) = 534 ' Nest2_GS
    WT_OUTPUT_BIT_AS(2) = 535 ' Nest2_AS
    WT_OUTPUT_BIT_GS(3) = 537 ' Nest3_GS
    WT_OUTPUT_BIT_AS(3) = 538 ' Nest3_AS
    WT_OUTPUT_BIT_GS(4) = 539 ' Nest4_GS
    WT_OUTPUT_BIT_AS(4) = 540 ' Nest4_AS
    
'   Deklarieren der SPS Freigaben und Rückmeldungen
	FG_GRUNDSTELLUNG = 10
	FG_EINLEGEN = 20
	FG_STRAHLEN = 30
	FG_ABHOLEN = 40

	RM_START = 0
	RM_GRUNDSTELLUNG_BEGINN = 15
	RM_GRUNDSTELLUNG_FERTIG = 19
	RM_EINLEGEN_BEGINN = 25
	RM_EINLEGEN_FERTIG = 29
	RM_STRAHLEN_BEGINN = 35
	RM_STRAHLEN_FERTIG = 39
	RM_ABHOLEN_BEGINN = 45
	RM_ABHOLEN_FERTIG = 49
	
	CJ_out_STRAHLEN = 2
	CJ_out_NUR_LUFT = 1
	CJ_out_AUS = 0

	CJ_in_STRAHLT = 4
	CJ_in_NUR_LUFT = 3	' testen!
	CJ_in_aus = 1

	
	tZyklus = Tmr(0) 	' Zykluszeit Timer setzen

Fend

' Einlesen des Typs, welcher Artikel bearbeitet werden soll.
Function read_PartTyp_From_SPS
	
	If Sw(Typ1) + Sw(Typ2) + Sw(Typ3) + Sw(Typ4) + Sw(Typ5) > 1 Then	' Prüft ob mehr als ein Typ ausgewählt wurde
'		Error err_more_typs
	ElseIf Sw(Typ1) Then
		read_PartTyp_From_SPS = 1
	ElseIf Sw(Typ2) Then
		read_PartTyp_From_SPS = 2
	ElseIf Sw(Typ3) Then
		read_PartTyp_From_SPS = 3
	ElseIf Sw(Typ4) Then
		read_PartTyp_From_SPS = 4
	ElseIf Sw(Typ5) Then
		read_PartTyp_From_SPS = 5
	Else
'		Error err_no_typ			' Wenn kein Typ ausgewählt wurde
	EndIf
	
	If read_PartTyp_From_SPS <= 3 Then	' Prüfen welches Teil welcher Typ ist und anpassen!
		g_ALLOWED_WT(1) = 1	' typ 1-3
		g_ALLOWED_WT(2) = 2	' erlaubte wts 1&2
	Else
		g_ALLOWED_WT(1) = 3	' typ 4-5
		g_ALLOWED_WT(2) = 4	' erlaubte wts 2&3
	EndIf
	
Fend
