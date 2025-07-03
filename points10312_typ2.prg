Function punkte_oberseite_10312(WT_INDEX As Integer)
	Integer i
	CP On
	For i = 21 To 34
		Move P(i) /(WT_INDEX)
		If i = 29 Then
			Call f_kreisCenter(3, 1)
		EndIf
		Wait 0.4
	Next
	Wait 0.3
	CP Off
Fend

Function punkte_unterseite_10312(WT_INDEX As Integer)
	Integer i
	CP On
	For i = 38 To 50
		Move P(i) /(WT_INDEX)
		If i = 42 Then
			Call f_kreisCenter(3, 1)
		EndIf
		Wait 0.4
	Next
	CP Off
Fend
