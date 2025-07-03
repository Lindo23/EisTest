Function EisStrahlen

	'typabhängig laden
	'If Sw(Typ1) = On Then
		
	'	EndIf
		
	'If Sw(Typ2) = On Then
	'	Call main_10312
	'	EndIf
		
	'If Sw(Typ3) = On Then
	'	Call main_10286
	'	EndIf
		
	'If Sw(Typ4) = On Then
	'	Call main_10287
	
	'
'	EndIf
'Test lauf 

'10312
	
	Speed 75
	Accel 75, 75
	SpeedS 700
	AccelS 500

	Jump RealPos :Z(0)

'	OutW Coldjet_senden, CJ_out_NUR_LUFT		'ColdJet nur Luft
	OutW Coldjet_senden, CJ_out_STRAHLEN		'ColdJet Strahlen

	Call f_wt_drehen_auf_position(1)
	
	Wait InW(Coldjet_antwort) = CJ_in_STRAHLT
	
	Integer i
	For i = 2 To 1 Step -1
		Jump pTeil_ursprung /(i)
		Call f_DriveGridLines(7, 80, 45, 0, 1)
		Call punkte_oberseite_10312(i)
	Next
	
	Jump RealPos :Z(0)

	Call f_wt_drehen_auf_position(2)

	For i = 1 To 2
		Jump p_10312_p15 /(i)
		Wait 0.8
	Next
	
	Jump RealPos :Z(0)

	Call f_wt_drehen_auf_position(3)

	For i = 2 To 1 Step -1
		Jump pTeil_ursprung /(i)
		Call f_DriveGridLines(7, 80, 45, 0, 1)
		Call punkte_unterseite_10312(i)
	Next
	
	Jump RealPos :Z(0)
	
	Call f_wt_drehen_auf_position(4)
	
	For i = 1 To 2
		Jump p_10312_p29 /(i)
		Call f_kreisCenter(4.5, 2)
		Wait 0.8
		Go p_10312_p30 /(i)
		Call f_kreisCenter(4.5, 2)
		Wait 0.8
	Next
	
	OutW Coldjet_senden, CJ_out_AUS
	
	Call f_wt_drehen_auf_position(1)
	
	Wait InW(Coldjet_antwort) = CJ_in_aus Or InW(Coldjet_antwort) = 0	 		' oder weglassen?
	
	Call move_rotate_parts

	OutW Coldjet_senden, CJ_out_STRAHLEN
	
	Jump RealPos :Z(0)

	Call f_wt_drehen_auf_position(2)

	Wait InW(Coldjet_antwort) = CJ_in_STRAHLT
	
	For i = 1 To 2
		Jump p_10312_p31 /(i)
		Move p_10312_p32 /(i)
		Call f_kreisCenter(2, 2)
		Wait 0.5
		Move p_10312_p33 /(i)
	Next
	
	OutW Coldjet_senden, CJ_out_AUS
	Jump RealPos :Z(0)
	
	Call f_wt_drehen_auf_position(1)

	Wait InW(Coldjet_antwort) = CJ_in_aus Or InW(Coldjet_antwort) = 0
	OutW Rckgabewert_SPS, RM_STRAHLEN_FERTIG

Fend
