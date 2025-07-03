'rows = wie oft soll die fläche abgefahren werden?
'y und x = wie groß ist die abzufahrende fläche?
'offsetX und offsetY = wie groß soll der abstand von den linien zur fläche sein?
' --> soll bei 0,0 angefangen werden oder nicht?
Function f_DriveGridLines(rows As Integer, x As Double, y As Double, offsetX As Double, offsetY As Double)
	Double abstand_Y
	Integer currentLine
	
	currentLine = 1
	CP On
	BMove XY(offsetX, offsetY, 0, 0)
	
	If rows = 1 Then
		abstand_Y = 0
	Else
		abstand_Y = (y - (2 * offsetY)) / (rows - 1)
	EndIf

	Do While currentLine <= rows
		If currentLine Mod 2 = 1 Then
			BMove XY(x - (2 * offsetX), 0, 0, 0)
		Else
			BMove XY(-x + (2 * offsetX), 0, 0, 0)
		EndIf
		
		If currentLine < rows Then
			BMove XY(0, abstand_Y, 0, 0)
		EndIf
		currentLine = currentLine + 1
	Loop
	CP Off
Fend


Function f_kreisCenter(radius As Double, turns As Integer)
	If turns < 1 Then
		turns = 1
	EndIf
	P910 = Here
	P911 = P910 +X(radius / 2)
	P912 = P911 +Y(radius / 2)
	P913 = P912 -X(radius)
	P914 = P913 -Y(radius)
	P911 = P914 +X(radius)
	P912 = P911 +Y(radius)
	
	P914 = P914 +X(radius / 2)
	P911 = P911 +Y(radius / 2)
	P912 = P912 -X(radius / 2)
	P913 = P913 -Y(radius / 2)
	
	Go P913
	Integer i
	For i = 1 To turns Step 1
		Arc3 P914, P911 CP
		Arc3 P912, P913 CP
	Next
	
Fend


Function f_kreisAufDurchmesser(radius As Double)
	P910 = Here
	P911 = P910 +X(radius)
	P912 = P911 +Y(radius)
	P913 = P912 -X(radius)
	Arc3 P911, P912 CP
	Arc3 P913, P910 CP
Fend


Function f_kreisAusmahlen(radius As Double, turns As Integer)
	Double currentRadius, reductionPerTurn
	If turns < 1 Then
		turns = 1
	EndIf
	
	reductionPerTurn = (radius - 0.5) / turns
	
	currentRadius = radius
	P910 = Here
	
	Integer i
	For i = 1 To turns
		
		P911 = P910 +X(currentRadius / 2)
		P912 = P911 +Y(currentRadius / 2)
		P913 = P912 -X(currentRadius)
		P914 = P913 -Y(currentRadius)
		P911 = P914 +X(currentRadius)
		P912 = P911 +Y(currentRadius)
		
		P914 = P914 +X(currentRadius / 2)
		P911 = P911 +Y(currentRadius / 2)
		P912 = P912 -X(currentRadius / 2)
		P913 = P913 -Y(currentRadius / 2)
		
		If currentRadius = radius Then
			Go P913
		EndIf
		
		Arc3 P914, P911 CP
		Arc3 P912, P913 CP
		
		currentRadius = currentRadius - reductionPerTurn
		If currentRadius < 0.5 Then
			currentRadius = 0.5
		EndIf
	Next
	
	Go P910
	
Fend

