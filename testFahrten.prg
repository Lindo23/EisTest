Function test
	Tool 1
	TmReset (0)
	Go ursprung_Part /4
	Go ursprung_Part +Y(45) /4
	Go ursprung_Part +Y(45) -X(67.5) /4
	Go ursprung_Part -X(67.5) /4
	Go ursprung_Part /4
	Print "Go bewegung: " + Str$(Tmr(0)) + " ms"
	Wait 1

	TmReset (0)
	Move ursprung_Part /4
	Move ursprung_Part +Y(45) /4
	Move ursprung_Part +Y(45) -X(67.5) /4
	Move ursprung_Part -X(67.5) /4
	Move ursprung_Part /4
	Print "Move bewegung: " + Str$(Tmr(0)) + " ms"
	Wait 1
	
	TmReset (0)
	Move ursprung_Part /4 CP
	Move ursprung_Part +Y(45) /4 CP
	Move ursprung_Part +Y(45) -X(67.5) /4 CP
	Move ursprung_Part -X(67.5) /4 CP
	Move ursprung_Part /4 CP
	Print "Move CP bewegung: " + Str$(Tmr(0)) + " ms"
	Wait 1
	
	CP On
	TmReset (0)
	Move ursprung_Part /4
	Move ursprung_Part +Y(45) /4
	Move ursprung_Part +Y(45) -X(67.5) /4
	Move ursprung_Part -X(67.5) /4
	Move ursprung_Part /4
	Print "Move CP On bewegung: " + Str$(Tmr(0)) + " ms"
	CP Off
	Wait 1
	
	TmReset (0)
	BMove ursprung_Part
	BMove ursprung_Part +Y(45)
	BMove ursprung_Part -X(67.5)
	BMove ursprung_Part -Y(45)
	BMove ursprung_Part +X(67.5)
	Print "BMove bewegung: " + Str$(Tmr(0)) + " ms"
	Wait 1
	
	TmReset (0)
	BMove ursprung_Part CP
	BMove ursprung_Part +Y(45) CP
	BMove ursprung_Part -X(67.5) CP
	BMove ursprung_Part -Y(45) CP
	BMove ursprung_Part +X(67.5) CP
	Print "BMove CP bewegung: " + Str$(Tmr(0)) + " ms"
	Wait 1
	
	CP On
	TmReset (0)
	BMove ursprung_Part
	BMove ursprung_Part +Y(45)
	BMove ursprung_Part -X(67.5)
	BMove ursprung_Part -Y(45)
	BMove ursprung_Part +X(67.5)
	Print "BMove bewegung: " + Str$(Tmr(0)) + " ms"
	CP Off
	Wait 1
	
	
	Quit All
Fend

