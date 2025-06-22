Function main
	Xqt Simulation		' Nötig für I/O Simulation
	SpeedFactor 100		' like overwrite geschwindigkeit
	Call init
	

	Call move_Grundstellung		' gs fahrt + ggf. wenn Teil in GRF -> fahrt zu niO
	Call checkWTs 				' prüft WT endschalter + ggf. vorhandene Teile zu niO
	
	Integer i
	For i = 1 To 2
		Call move_PickPart_from_belt
		If Sw(Vision_drehen) Or Sw(Vision_NIO) Then
			Call move_to_nio
			i = i - 1
		Else
			Call move_PlacePart_to_WT(i)
		EndIf
	Next
	
	For i = 2 To 1 Step -1
		Call move_WT_putzen(G_ALLOWED_WTs(i))	'oberseite "putzen"
		Call f_WT_Punkte_oberseite(G_ALLOWED_WTs(i))
	Next
	
	For i = 1 To 2
		Call move_PickPart_From_WT(G_ALLOWED_WTs(i))
		Call move_Part_to_belt
	Next
	
	Tool 0
	Go pGSD
	Quit All
Fend

Function init
	Call setGlobals				' set global variables 
	Call ReadPartTypeFromSPS	' check part typ given from sps - allowed 1-5
	
	If Motor = Off Then	'ff +0.9sec wenn aus oder ohne if abfrage
		Motor On
	EndIf
	
	Speed 100
	Accel 100, 100
	SpeedS 2000			'max 2000
 	AccelS 25000		'max 25000

	Power High
Fend

Function ReadPartTypeFromSPS

    G_CURRENTPARTTYPE = InW(Typnr)

    If G_CURRENTPARTTYPE < 1 Or G_CURRENTPARTTYPE > 5 Then
        Print "FEHLER: Ungueltiger Teiltyp von SPS erhalten bei Start: " + Str$(G_CURRENTPARTTYPE) + ". Erwarte 1-5."
        Error error_Part_Type
    EndIf
        
    If G_CURRENTPARTTYPE < 3 Then
    	G_ALLOWED_WTs(1) = 3
    	G_ALLOWED_WTs(2) = 4
    Else
    	G_ALLOWED_WTs(1) = 1
    	G_ALLOWED_WTs(2) = 2
    EndIf
    
    Print "Teiltyp von SPS gelesen: " + Str$(G_CURRENTPARTTYPE) + " Teil: " + G_CURRENTPARTNAME$(G_CURRENTPARTTYPE)
    ReadPartTypeFromSPS = G_CURRENTPARTTYPE
Fend

Function checkWTs
	Integer i
	For i = 1 To 4
		If get_WT_Status(i) <> 0 Then
			Print "Teil in WT# " + Str$(i) + " erkannt, schmeiße es weg"
			Call move_PickPart_From_WT(i)
			Call move_to_nio
		EndIf
	Next
Fend

'999: Fehler/Unbestimmt (beide oder keine Bits aktiv)
'1: Nest geschlossen 
'0: Nest offen
Function get_WT_Status(WT_Index As Integer)
    Boolean GS_Active 		' Ist Grundstellungssensor aktiv?
    Boolean AS_Active 		' Ist Arbeitsstellungssensor aktiv?

    ' Prüfe, ob der WT_Index gültig ist
    If WT_INDEX < 1 Or WT_INDEX > 4 Then
        Print "FEHLER: Ungueltiger WT_Index fuer get_WT_Status: " + Str$(WT_INDEX)
        get_WT_Status = 999
        GoTo get_WT_StatusExit
    EndIf
    ' Lese die Bit-Zustaende von WT
    GS_Active = Sw(WT_INPUT_GS(WT_INDEX))
    AS_Active = Sw(WT_INPUT_AS(WT_INDEX))
    
    If GS_Active And Not AS_Active Then
        get_WT_Status = 0 ' Nest ist offen
    ElseIf AS_Active And Not GS_Active Then
        get_WT_Status = 1 ' Nest ist geschlossen 
    Else
		'Fehlerfall: Entweder beide aktiv oder beide inaktiv
        Print "WARNUNG: Inkonsistenter Nest-Status fuer WT " + Str$(WT_INDEX) + ". GS: " + Str$(GS_Active) + ", AS: " + Str$(AS_Active)
        get_WT_Status = 999 ' Fehler/Unbestimmt
    EndIf
get_WT_StatusExit: ' Label für GOTO-Sprung
Fend

Function move_PickPart_from_belt
	Print "Hole Teil von Förderband"
	Jump Abholen :Z(0)
	Go Abholen
	Call y_rZylinder(1)
	Wait 0.3
	Call y_rGreifer(1)
	Wait 0.2
	Call y_rZylinder(0)
	Wait 0.3
	Jump Abholen :Z(0)
Fend

Function move_Part_to_belt
	Tool 0
	Print "Lege Teil auf Förderband"
	Jump Ablegen :Z(0)
	Go Ablegen
	Call y_rZylinder(1)
	Wait 0.3
	Call y_rGreifer(0)
	Wait 0.2
	Call y_rZylinder(0)
	Wait 0.3
	Jump Ablegen :Z(0)
Fend

Function move_to_nio
	Go Here :Z(0)
	Jump NIO :Z(0)
	Go NIO
	Call y_rZylinder(1)
	Wait 0.3
	Call y_rGreifer(0)
	Wait 0.2
	Call y_rZylinder(0)
	Wait 0.3
	Go Here +Z(20)
	
Fend

Function move_PlacePart_to_WT(PART_INDEX As Integer)
	Integer WT_INDEX
	WT_INDEX = G_ALLOWED_WTs(PART_INDEX)
	Print "gehe zu WT# " + Str$(WT_INDEX) + " und lege ein"
	Select WT_INDEX
		Case 1
			Jump Nest1_p
		Case 2
			Jump Nest2_p
		Case 3
			Jump Nest3_p
		Case 4
			Jump Nest4_P
		Default
			Print "error placePart " + Str$(WT_INDEX)
	Send
	
	Call y_rZylinder(1)
	Wait 0.3
	Call y_wt_greifen(WT_INDEX, 1)
	Wait 0.3
	Call y_rGreifer(0)
	Wait 0.2
	Call y_rZylinder(0)
	Wait 0.3

Fend

Function f_WT_Punkte_oberseite(WT_INDEX As UByte)
	Select G_CURRENTPARTTYPE
		Case 1
			Print "punkte nicht definiert für Teil: " + G_CURRENTPARTNAME$(G_CURRENTPARTTYPE)
		Case 2
			Print "punkte nicht definiert für Teil: " + G_CURRENTPARTNAME$(G_CURRENTPARTTYPE)
		Case 3
			Call move_WT_Punkte_oberseite_10312(WT_INDEX)
		Case 4
			Print "punkte nicht definiert für Teil: " + G_CURRENTPARTNAME$(G_CURRENTPARTTYPE)
		Case 5
			Print "punkte nicht definiert für Teil: " + G_CURRENTPARTNAME$(G_CURRENTPARTTYPE)
		Default
			Print "f_WT_Punkte_oberseite G_CURRENTPARTTYPE:" + Str$(G_CURRENTPARTTYPE) + " nicht definiert"
			Error error_Part_Type
	Send
Fend

Function move_WT_putzen(WT_INDEX As UByte)
	Print "Strahle oberflächlich WT_INDEX# " + Str$(WT_INDEX) + " ab"
	Tool 1
	Go Here +Z(10)
	Go ursprung_Part +Z(10) /(WT_INDEX)
	Go Here -Z(10)
	Call grid_for_PartType(7) '+0,41 bis +0,44 pro linie
Fend

Function grid_for_PartType(linien As Integer) 'ff +0,8sec unterschied bei 12 linien
	TmReset (0)
	If G_ALLOWED_WTs(1) = 1 Or G_ALLOWED_WTs(1) = 2 Then
		Call f_DriveGridLines(linien, 83, 45, 3, 3)
	ElseIf G_ALLOWED_WTs(1) = 3 Or G_ALLOWED_WTs(1) = 3 Then
		Call f_DriveGridLines(linien, 67.5, 45, 3, 3)
	EndIf
	Print Tmr(0)
Fend

Function move_PickPart_From_WT(WT_INDEX As Integer)
	Print "Hole Teil aus WT# " + Str$(WT_INDEX)
	Tool 0
	Select WT_INDEX
		Case 1
			Jump Nest1_p
		Case 2
			Jump Nest2_p
		Case 3
			Jump Nest3_p
		Case 4
			Jump Nest4_P
		Default
			Print "error move_PickPart_From_WT " + Str$(WT_INDEX)
			Error error_WT_Index
	Send
	
	Call y_rZylinder(1)
	Wait 0.3
	Call y_rGreifer(1)
	Wait 0.2
	Call y_wt_greifen(WT_INDEX, 0)
	Wait 0.2
	Call y_rZylinder(0)
	Wait 0.3
	
Fend

' Was wenn WT_Greifer und Roboter_Greifer zu sind, gerade bei der übergabe? 
Function move_Grundstellung
	If MemSw(Teil_im_Greifer) = 0 Then
		Call y_rGreifer(0)
	EndIf
	Call y_rZylinder(0)
	Tool 0
	Go Here :Z(0)
	Go pGSD
	
	If MemSw(Teil_im_Greifer) Then
		Print "Teil in Roboter Greifer erkannt, schmeiße es weg"
		move_to_nio
	EndIf
	
	Tool 0
	Go Here :Z(0)
	Go pGSD
	
Fend

Function y_rZylinder(ausfahren As Boolean)
	If ausfahren Then
		Off Y_LEV_GS
		On Y_LEV_AS
		Wait Sw(LEV_AS) And Sw(LEV_GS) = 0, 1
	Else
		Off Y_LEV_AS
		On Y_LEV_GS
		Wait Sw(LEV_GS) And Sw(LEV_AS) = 0, 1
	EndIf
	
	If TW Then
		Print "y_rZylinder hat Grund- oder Arbeitsstellung nicht erreicht, endschalter prüfen!"
		Print "Endschalter GS: " + Str$(Sw(LEV_GS))
		Print "Endschalter AS: " + Str$(Sw(LEV_AS))
		Error error_Zylinder
	EndIf
Fend

Function y_rGreifer(greifen As Boolean)
	If greifen Then
		Off Y_Greifer_GS
		On Y_Greifer_AS
		Wait Sw(Greifer_AS) And Sw(Greifer_GS) = 0, 1
		MemOn Teil_im_Greifer
	Else
		Off Y_Greifer_AS
		On Y_Greifer_GS
		Wait Sw(Greifer_GS) And Sw(Greifer_AS) = 0, 1
		MemOff Teil_im_Greifer
	EndIf
	
	If TW Then
		Print "y_rGreifer hat Grund- oder Arbeitsstellung nicht erreicht, endschalter prüfen!"
		Print "Endschalter GS: " + Str$(Sw(Greifer_GS))
		Print "Endschalter AS: " + Str$(Sw(Greifer_AS))
		Error error_Greifer
	EndIf
Fend


Function y_wt_greifen(WT_INDEX As UByte, greifen As Boolean)
	If greifen Then
		Off WT_OUTPUT_GS(WT_INDEX)
		On WT_OUTPUT_AS(WT_INDEX)
		Wait Sw(WT_INPUT_AS(WT_INDEX)) And Sw(WT_INPUT_GS(WT_INDEX)) = 0, 1
	Else
		Off WT_OUTPUT_AS(WT_INDEX)
		On WT_OUTPUT_GS(WT_INDEX)
		Wait Sw(WT_INPUT_GS(WT_INDEX)) And Sw(WT_INPUT_AS(WT_INDEX)) = 0, 1
	EndIf
	
	If TW Then
		Print "Werkzeugträger " + Str$(WT_INDEX) + " hat Grund- oder Arbeitsstellung nicht erreicht, endschalter prüfen!"
		Print "Endschalter GS: " + Str$(Sw(WT_INPUT_GS(WT_INDEX)))
		Print "Endschalter AS: " + Str$(Sw(WT_INPUT_AS(WT_INDEX)))
		Error error_WT
	EndIf
Fend

