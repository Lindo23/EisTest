'rows = wie oft soll die fläche abgefahren werden?
'y und x = wie groß ist die abzufahrende fläche?
'offsetX und offsetY = wie groß soll der abstand von den linien zur fläche sein?
' --> soll bei 0,0 angefangen werden oder nicht?
Function f_DriveGridLines(rows As Integer, x As Double, y As Double, offsetX As Double, offsetY As Double)
	Double abstand_Y
	Integer currentLine
	
	currentLine = 1

	BMove XY(-offsetX, offsetY, 0, 0)
	
	If rows = 1 Then
		abstand_Y = 0
	Else
		abstand_Y = (y - (2 * offsetY)) / (rows - 1)
	EndIf

	Do While currentLine <= rows
		If currentLine Mod 2 = 1 Then
			BMove XY(-x + (2 * offsetX), 0, 0, 0)
		Else
			BMove XY(x - (2 * offsetX), 0, 0, 0)
		EndIf
		
		If currentLine < rows Then
			BMove XY(0, abstand_Y, 0, 0)
		EndIf
		currentLine = currentLine + 1
	Loop

Fend


Function f_kreisCenter(radius As Double, turns As Integer)
	If turns < 1 Then
		turns = 1
	EndIf
	P10 = Here
	P11 = P10 +X(radius / 2)
	P12 = P11 +Y(radius / 2)
	P13 = P12 -X(radius)
	P14 = P13 -Y(radius)
	P11 = P14 +X(radius)
	P12 = P11 +Y(radius)
	
	P14 = P14 +X(radius / 2)
	P11 = P11 +Y(radius / 2)
	P12 = P12 -X(radius / 2)
	P13 = P13 -Y(radius / 2)
	
	Go P13
	Integer i
	For i = 1 To turns Step 1
		Arc3 P14, P11 CP
		Arc3 P12, P13 CP
	Next
	
Fend


Function f_kreisAufDurchmesser(radius As Double)
	P10 = Here
	P11 = P10 +X(radius)
	P12 = P11 +Y(radius)
	P13 = P12 -X(radius)
	Arc3 P11, P12 CP
	Arc3 P13, P10 CP
Fend


Function f_kreisAusmahlen(radius As Double, turns As Integer)
	Double currentRadius, reductionPerTurn
	If turns < 1 Then
		turns = 1
	EndIf
	
	reductionPerTurn = (radius - 0.5) / turns
	
	currentRadius = radius
	P10 = Here
	
	Integer i
	For i = 1 To turns
		
		P11 = P10 +X(currentRadius / 2)
		P12 = P11 +Y(currentRadius / 2)
		P13 = P12 -X(currentRadius)
		P14 = P13 -Y(currentRadius)
		P11 = P14 +X(currentRadius)
		P12 = P11 +Y(currentRadius)
		
		P14 = P14 +X(currentRadius / 2)
		P11 = P11 +Y(currentRadius / 2)
		P12 = P12 -X(currentRadius / 2)
		P13 = P13 -Y(currentRadius / 2)
		
		If currentRadius = radius Then
			Go P13
		EndIf
		
		Arc3 P14, P11 CP
		Arc3 P12, P13 CP
		
		currentRadius = currentRadius - reductionPerTurn
		If currentRadius < 0.5 Then
			currentRadius = 0.5
		EndIf
	Next
	
	Go P10
	
Fend




