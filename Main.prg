Function init
	Call setGlobals				' set global variables 
	Call ReadPartTypeFromSPS	' check part typ given from sps - allowed 1-5
	
	If Motor = Off Then
		Motor On
	EndIf
	
	Speed 100
	Accel 100, 100
	SpeedS 2000
 	AccelS 5000

	Power High
Fend

Function ReadPartTypeFromSPS

    G_CURRENTPARTTYPE = InW(Typnr)

    If G_CURRENTPARTTYPE < 1 Or G_CURRENTPARTTYPE > 5 Then
        Print "FEHLER: Ungueltiger Teiltyp von SPS erhalten bei Start: " + Str$(G_CURRENTPARTTYPE) + ". Erwarte 1-5."
        Error error_Part_Type
    EndIf
    Print "INFO: Teiltyp von SPS bei Initialisierung gelesen: " + Str$(G_CURRENTPARTTYPE)
    ReadPartTypeFromSPS = G_CURRENTPARTTYPE
Fend


Function main
	Xqt Simulation
	
	Call init

'    ' Pruefe, ob die Initialisierung erfolgreich war (G_CURRENT_STATE = -1 im Fehlerfall)
'    If G_CURRENT_STATE = -1 Then
'        Print "System konnte nicht initialisiert werden. Bitte Fehler beheben und neu starten."
'        Quit All ' Beende das Programm, wenn Initialisierung fehlgeschlagen ist
'    EndIf
'
'    ' Endlosschleife fuer den Zustandsautomaten
'    Do
'        Call StateMachine
'    Loop
	
	
	'Fahre auf Grundstellung 
	Call move_Grundstellung
	Call checkWTs
	
	
	Wait 1000
	' check ob teil in roboter greifer oder greifer zu
'	Call Grundstellung
	
	
	
	
	
	
	

	Call pickPart
	Call move_to_nio
	Call placePart(1)
	Call pickPart
	Call placePart(2)
	
	Call bearbeiten
	
	
Fend


Function init9
	If Motor = Off Then
		Motor On
	EndIf
	
	Speed 100
	Accel 100, 100
	SpeedS 2000
 	AccelS 5000

	Power High
	Tool 0
	Go pGSD
	
	Print "Artikel Typ " + Str$(ReadPartTypeFromSPS) + " wird bearbeitet"
	
	
Fend


Function checkWTs
	Integer i
	Wait 1
	Do
	For i = 1 To 4
		If GetNestStatus(i) <> 0 Then
			Print GetNestStatus(i)
		EndIf
	Next
	Loop
Fend

'999: Fehler/Unbestimmt (beide oder keine Bits aktiv)
'1: Nest geschlossen 
'0: Nest offen
Function GetNestStatus(WT_Index As Integer)
    Boolean GS_Active 		' Ist Grundstellungssensor aktiv?
    Boolean AS_Active 		' Ist Arbeitsstellungssensor aktiv?

    ' Prüfe, ob der WT_Index gültig ist
    If WT_Index < 1 Or WT_Index > 4 Then
        Print "FEHLER: Ungueltiger WT_Index fuer GetNestStatus: " + Str$(WT_Index)
        GetNestStatus = 999 ' Fehlercode
        GoTo GetNestStatusExit
    EndIf
    ' Lese die Bit-Zustaende von SPS-Eingängen
    GS_Active = Sw(WT_INPUT_GS(WT_Index))
    AS_Active = Sw(WT_INPUT_AS(WT_Index))
    
    If GS_Active And Not AS_Active Then
        GetNestStatus = 0 ' Nest ist offen
    ElseIf AS_Active And Not GS_Active Then
        GetNestStatus = 1 ' Nest ist geschlossen 
    Else
		'Fehlerfall: Entweder beide aktiv oder beide inaktiv
        Print "WARNUNG: Inkonsistenter Nest-Status fuer WT " + Str$(WT_Index) + ". GS: " + Str$(GS_Active) + ", AS: " + Str$(AS_Active)
        GetNestStatus = 999 ' Fehler/Unbestimmt
    EndIf
GetNestStatusExit: ' Label für den GOTO-Sprung
Fend

Function pickPart

	Jump Abholen :Z(0)
	Go Abholen
	Print "greifer + zylinder as"
	Print "zylinder gs"
	Jump Abholen :Z(0)

Fend

Function f_typAuswahl
	Print "call kamera i.O? (TypAuswahl or SPS)"
	f_typAuswahl = 3
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
	Go Here :Z(0)
	
Fend


Function placePart(NestNummer As UByte)
	
	Select NestNummer
		Case 1
			Jump Nest1_p
		Case 2
			Jump Nest2_p
		Case 3
			Jump Nest3_p
		Case 3
			Jump Nest4_P
		Default
			Print "error placePart " + Str$(NestNummer)
	Send
	
Fend

Function bearbeiten
	Tool 1
	Go Local1
	Call f_DriveGridLines(8, 45, 83, 0, 3)
	Jump Local2
	Call f_DriveGridLines(8, 45, 83, 0, 3)
	Go gewinde1 /2
	Call f_kreisCenter(9.5, 3)
	Go gewinde2 /2
	Call f_kreisCenter(9.5, 3)
	Go gewinde1 /1
	Call f_kreisCenter(9.5, 3)
	Go gewinde2 /1
	Call f_kreisCenter(9.5, 3)
	Tool 0
	Jump pGSD
Fend

'	Select TypAuswahl
'		Case 1
'			Print "call 10286"
'		Case 2
'			Print "call 10287"
'		Case 3
'			Print "call 10312"
'		Case 4
'			Print "call 10313"
'		Case 5
'			Print " call 10314"
'	Send


Function StateMachine
	Select Case G_CURRENT_STATE
		Integer i

		Case STATE_CHECK_WTS
			For i = 1 To 4
				If GetNestStatus(i) = 1 Then
					move_PickPartFromWT(i)
				EndIf
			Next
		Case STATE_IDLE
			G_CURRENT_STATE = STATE_CHECK_WTS
	Send
Fend


Function move_PickPartFromWT(WT_INDEX As Integer)
	
	Select WT_Index
		Case 1
			Jump Nest1_p
		Case 2
			Jump Nest2_p
		Case 3
			Jump Nest3_p
		Case 3
			Jump Nest4_P
		Default
			Print "error move_PickPartFromWT " + Str$(WT_Index)
	Send
	
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
		move_to_nio
	EndIf
	
	Tool 0
	Go Here :Z(0)
	Go pGSD
	
Fend

Function y_rZylinder(ausfahren As Boolean)
	If ausfahren Then
		Off Y_LEV_AS
		On Y_LEV_GS
		Wait Sw(LEV_GS) And Sw(LEV_AS) = 0, 1
	Else
		Off Y_LEV_GS
		On Y_LEV_AS
		Wait Sw(LEV_AS) And Sw(LEV_GS) = 0, 1
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

