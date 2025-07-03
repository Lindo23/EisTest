Function move_Grundstellung
	Tool 0
	Speed 20
	Accel 10, 10

	Off trigger_zaehlen
	Off triggeranfahrt
	Off Anforderung_Nestdrehen
	OutW Pos_vorgabe, 0
	
	
	If MemSw(Teil_im_Greifer) = 0 Then
		Call y_rGreifer(0)
	EndIf
	
	Call y_rZylinder(0)
	Go RealPos :Z(0)
	Home

	If MemSw(Teil_im_Greifer) Then
		Call move_to_nio
	EndIf
	
	Home
	
	Wait Sw(Nest_GST), 20
	If TW Then
		Print "Werkzeugträger nicht auf Grundstellung"
'		Error err_
	EndIf
	
Fend

Function move_to_nio
	Tool 0
	Go RealPos :Z(0)
	On triggeranfahrt
	On trigger_zaehlen
	Jump NIO :Z(0)
	Go NIO
	Wait Sw(NIO_voll) = Off
	Call y_rZylinder(1)
	Call y_rGreifer(0)
	Call y_rZylinder(0)
	Go RealPos :Z(0)
	Off abgeholt_von_Robbi		' ??
	Off triggeranfahrt
	Off trigger_zaehlen
Fend

Function move_PickPart_from_belt
	
	Do Until MemSw(Teil_im_Greifer)

		Jump Abholen :Z(0)
		
		Wait Sw(Frg_abholen)
'		If TW Then
'			Print "Keine Freigabe zum abholen der Teile durch SPS erhalten."
'		EndIf
'		
		Go Abholen
		Call y_rZylinder(1)
		Call y_rGreifer(1)
		Call y_rZylinder(0)
		Jump Abholen :Z(0)
		On abgeholt_von_Robbi
		
		If Sw(Vision_NIO) = On Then
			Call move_to_nio
		EndIf
	Loop
Fend

Function move_PickAndPlace_Parts
	Integer i
	For i = 1 To 2
		move_PickPart_from_belt
		move_PlacePart_to_WT(i)
	Next
Fend

Function move_PlacePart_to_WT(WT_INDEX As Integer)
	Tool 0
	
	If InW(WT_Position_antwort) <> 1 Then Call f_wt_drehen_auf_position(1)
	
	If Sw(WT_INPUT_BIT_AS(WT_INDEX)) Then
		Print "WT schon in Arbeitsstellung!"
'		Error err_
	EndIf
	
	Select WT_INDEX
		Case 1
			If MemSw(Nest1gedreht) Then Jump Nest1_gedreht Else Jump Nest1_p
		Case 2
			If MemSw(Nest2gedreht) Then Jump Nest2_gedreht Else Jump Nest2_p
		Case 3
			If MemSw(Nest3gedreht) Then Jump Nest3_gedreht Else Jump Nest3_p
		Case 4
			If MemSw(Nest4gedreht) Then Jump Nest4_gedreht Else Jump Nest4_p
		Default
			Print "error placePart " + Str$(WT_INDEX)
			Error err_WT_Index
	Send
	
	Call y_rZylinder(1)
	Call y_wt_greifen(WT_INDEX, 1)
	Call y_rGreifer(0)
	Call y_rZylinder(0)
	
Fend

Function move_PickParts_from_wt_to_belt
	Integer i
	For i = 1 To 2
		Call move_PickPart_From_WT(i)
		If Sw(anfahrt) Then
			Call move_to_nio
		Else
			Call move_Part_to_belt
		EndIf
		
	Next
Fend

Function move_PickPart_From_WT(WT_INDEX As Integer)
	Tool 0
	
	If InW(WT_Position_antwort) <> 1 Then Call f_wt_drehen_auf_position(1)
	
	Select WT_INDEX
		Case 1
			If MemSw(Nest1gedreht) Then Jump Nest1_gedreht Else Jump Nest1_p
			MemOff Nest1gedreht
		Case 2
			If MemSw(Nest2gedreht) Then Jump Nest2_gedreht Else Jump Nest2_p
			MemOff Nest2gedreht
		Case 3
			If MemSw(Nest3gedreht) Then Jump Nest3_gedreht Else Jump Nest3_p
			MemOff Nest3gedreht
		Case 4
			If MemSw(Nest4gedreht) Then Jump Nest4_gedreht Else Jump Nest4_p
			MemOff Nest4gedreht
		Default
			Print "error move_PickPart_From_WT " + Str$(WT_INDEX)
			Error err_WT_Index
	Send
	
'	Move RealPos -Z(1)
	Call y_rZylinder(1)
	Call y_rGreifer(1)
	Call y_wt_greifen(WT_INDEX, 0)
	Call y_rZylinder(0)
	
Fend

Function move_Part_to_belt
	Tool 0
	On trigger_zaehlen
	Jump Ablegen :Z(0)
	Go Ablegen
	Wait Sw(Auslauf_voll) = Off
	Call y_rZylinder(1)
	Call y_rGreifer(0)
	Call y_rZylinder(0)
	Jump Ablegen :Z(0)
	Off trigger_zaehlen
Fend

Function move_rotate_parts
	Integer i
	For i = 1 To 2
		move_PickPart_From_WT(g_ALLOWED_WT(i))
		Select g_ALLOWED_WT(i)
			Case 1 MemOn Nest1gedreht; Wait MemSw(Nest1gedreht)
			Case 2 MemOn Nest2gedreht; Wait MemSw(Nest2gedreht)
			Case 3 MemOn Nest3gedreht; Wait MemSw(Nest3gedreht)
			Case 4 MemOn Nest4gedreht; Wait MemSw(Nest4gedreht)
		Send
		move_PlacePart_to_WT(g_ALLOWED_WT(i))
	Next
Fend
