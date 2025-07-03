' ToDo 
' bei move_PickPart_From_WT Mem Nest1_gedreht erst Off wenn Teil gegriffen wurde
' 
'
'
'


#include "globals.inc"

Function main
	
	Call init	' initzialisiere das system einmalig (setzt variablen, Motor an, geschwindigkeiten, etc)
	
	Do
'		Einlesen der zu bearbeitenden Teile Typs (Sw(Typ1-5)(Sw 552-556) )und setzen der erlaubten Werkzeugträgers (WT_ALLOWED(4))
		Call read_PartTyp_From_SPS				' falscher Platz -> was macht sps wenn Typ wechsel ist?
												' maybe einmalig in main aufrufen?
		
		Select InW(FG_wert_SPS)		' Was soll laut SPS getan werden?
			
			Case FG_GRUNDSTELLUNG And OutW(Rckgabewert_SPS) <> RM_GRUNDSTELLUNG_FERTIG
				OutW Rckgabewert_SPS, RM_GRUNDSTELLUNG_BEGINN
				Call move_Grundstellung
				Call check_and_clear_WT ' WT auf funktion prüfen und ob teil vorhanden ist. -	nur die Aktiven WTs
				Home
				OutW Rckgabewert_SPS, RM_GRUNDSTELLUNG_FERTIG
			
			Case FG_EINLEGEN And OutW(Rckgabewert_SPS) <> RM_EINLEGEN_FERTIG
				OutW Rckgabewert_SPS, RM_EINLEGEN_BEGINN
				Call move_PickAndPlace_Parts
				OutW Rckgabewert_SPS, RM_EINLEGEN_FERTIG
			
			Case FG_STRAHLEN And OutW(Rckgabewert_SPS) <> RM_STRAHLEN_FERTIG
				OutW Rckgabewert_SPS, RM_STRAHLEN_BEGINN
				Call EisStrahlen
				OutW Rckgabewert_SPS, RM_STRAHLEN_FERTIG
				
			Case FG_ABHOLEN And OutW(Rckgabewert_SPS) <> RM_ABHOLEN_FERTIG
				OutW Rckgabewert_SPS, RM_ABHOLEN_BEGINN
				Call move_PickParts_from_wt_to_belt
				OutW Rckgabewert_SPS, RM_ABHOLEN_FERTIG
				Print "Zykluszeit: " + Str$(Tmr(0))
				TmReset (0)
		Send

		Wait 0.05
	Loop

Fend


'Drehen der Werkzeugträger -> WT_Position (integer) als Übergabeparameter
' 1 -> 0°   2 -> 90°   3 -> 180°   4 -> 270°
'maybe irgendeine prüfung ob Roboter nicht in WT?
Function f_wt_drehen_auf_position(WT_POSITION As Integer)
		OutW Pos_vorgabe, WT_POSITION
		On Anforderung_Nestdrehen
		Wait InW(WT_Position_antwort) = WT_POSITION
'		Wait Sw(Nest_wurde_gerdreht) = True
		If TW Then
			Print "Werkzeugträger wurde nicht gedreht oder bestätigung von SPS fehlt! - (f_wt_drehen_auf_position)"
'			Error err_rot_wt
		EndIf
		Off Anforderung_Nestdrehen
		Wait Sw(Nest_wurde_gerdreht) = False
Fend


Function y_rZylinder(ausfahren As Boolean)
	If ausfahren Then
		Off Y_LEV_GS
		On Y_LEV_AS
		Wait Sw(LEV_AS) And Sw(LEV_GS) = 0
	Else
		Off Y_LEV_AS
		On Y_LEV_GS
		Wait Sw(LEV_GS) And Sw(LEV_AS) = 0
	EndIf
	
	If TW Then
		Print "y_rZylinder hat Grund- oder Arbeitsstellung nicht erreicht, endschalter prüfen!"
		Print "Endschalter GS: " + Str$(Sw(LEV_GS))
		Print "Endschalter AS: " + Str$(Sw(LEV_AS))
'		Error err_Zylinder
	EndIf
Fend

Function y_rGreifer(greifen As Boolean)
	If greifen Then
		Off Y_Greifer_GS
		On Y_Greifer_AS
		Wait Sw(Greifer_GS) = 0 ' AS = 0 fehlt, da keine vernünftige überwachung vorhanden.
		MemOn Teil_im_Greifer
	Else
		Off Y_Greifer_AS
		On Y_Greifer_GS
		Wait Sw(Greifer_GS) 'And Sw(Greifer_AS) = 0	AS ist an, da zwar Greifer offen aber Teil mit AS Sensor (Lichtsensor) erkannt wird.
		MemOff Teil_im_Greifer
	EndIf
	
	If TW Then
		Print "y_rGreifer hat Grund- oder Arbeitsstellung nicht erreicht, endschalter prüfen!"
		Print "Endschalter GS: " + Str$(Sw(Greifer_GS))
		Print "Endschalter AS: " + Str$(Sw(Greifer_AS))
'		Error err_Greifer
	EndIf
Fend


Function y_wt_greifen(WT_INDEX As UByte, greifen As Boolean)
	If greifen Then
		Off WT_OUTPUT_BIT_GS(WT_INDEX)
		On WT_OUTPUT_BIT_AS(WT_INDEX)
		Wait Sw(WT_INPUT_BIT_AS(WT_INDEX)) And Sw(WT_INPUT_BIT_GS(WT_INDEX)) = 0, 0.3
	Else
		Off WT_OUTPUT_BIT_AS(WT_INDEX)
		On WT_OUTPUT_BIT_GS(WT_INDEX)
		Wait Sw(WT_INPUT_BIT_GS(WT_INDEX)) And Sw(WT_INPUT_BIT_AS(WT_INDEX)) = 0, 0.3
	EndIf
	
	If TW Then
		Print "Werkzeugträger " + Str$(WT_INDEX) + " hat Grund- oder Arbeitsstellung nicht erreicht, endschalter prüfen!"
		Print "Endschalter GS: " + Str$(Sw(WT_INPUT_BIT_GS(WT_INDEX)))
		Print "Endschalter AS: " + Str$(Sw(WT_INPUT_BIT_AS(WT_INDEX)))
'		Error err_WT
	EndIf
Fend


Function check_and_clear_WT
	Integer i
	For i = 1 To 4
		If get_WT_Status(i) <> 0 Then
			If i = g_ALLOWED_WT(1) Or i = g_ALLOWED_WT(2) Then
				Call move_PickPart_From_WT(i)
				Call move_to_nio
			Else
				y_wt_greifen(i, 1)	'nicht benutzte wt schließen
			EndIf
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
    If WT_Index < 1 Or WT_Index > 4 Then
        Print "FEHLER: Ungueltiger WT_Index fuer get_WT_Status: " + Str$(WT_Index)
        get_WT_Status = 999
        GoTo get_WT_StatusExit
    EndIf
    ' Lese die Bit-Zustaende von WT
    GS_Active = Sw(WT_INPUT_BIT_GS(WT_Index))
    AS_Active = Sw(WT_INPUT_BIT_AS(WT_Index))
    
    If GS_Active And Not AS_Active Then
        get_WT_Status = 0 ' Nest ist offen
    ElseIf AS_Active And Not GS_Active Then
        get_WT_Status = 1 ' Nest ist geschlossen 
    Else
		' Entweder beide aktiv oder beide inaktiv
        Print "WARNUNG: Inkonsistenter Nest-Status fuer WT " + Str$(WT_Index) + ". GS: " + Str$(GS_Active) + ", AS: " + Str$(AS_Active)
        get_WT_Status = 999 ' Fehler/Unbestimmt
    EndIf
get_WT_StatusExit: ' Label für GOTO-Sprung
Fend
