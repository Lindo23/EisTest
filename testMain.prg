' --- Globale Variablen Deklaration ---
Global Integer G_CURRENT_STATE         ' Aktueller Zustand
Global Integer G_WT_INTERNERSTATUS(4)   ' Status der 4 Werkzeugträger (Index 1-4)

Global Integer G_CURRENTPROCESSWT1      ' Index des ersten WTs im aktuellen Bearbeitungspaar/-einzelteil
Global Integer G_CURRENTPROCESSWT2      ' Index des zweiten WTs im aktuellen Bearbeitungspaar

Global Long G_WAITFORSECONDPARTSTARTTIME ' Startzeitpunkt des Timers für das zweite Teil (s)
Global Integer G_CURRENTPARTTYPE        ' Aktueller Teiltyp, vorgegeben von der SPS (1-5)

' --- Konstanten STATUS Definition ---
Global Integer STATE_IDLE
Global Integer STATE_WAIT_FOR_SECOND_WT
Global Integer STATE_BOTH_WTS_READY_TO_PROCESS
Global Integer STATE_BOTH_WTS_READY_FOR_PICKUP
Global Integer STATE_WT_STATUS_UNKNOWN_ACTION
Global Integer STATE_WT_ERROR_ACTION
Global Integer STATE_PICKUP_SINGLE_PART
Global Integer STATE_PROCESS_SINGLE_WT
Global Integer STATE_ERROR

Global Integer STATE_CHECK_WTS

Global Integer WT_STATUS_LEER
Global Integer WT_STATUS_UNBEKANNT
Global Integer WT_STATUS_UNBEARBEITET
Global Integer WT_STATUS_BEARBEITET
Global Integer WT_STATUS_FEHLER
Global Integer WT_STATUS_BESTUECKT_WARTE_ZWEI
Global Integer WT_STATUS_GESPERRT


' --- Hauptfunktion des Zustandsautomaten ---
Function RunStateMachine
    Select Case G_CURRENT_STATE

        Case STATE_IDLE
            Print "Aktueller Zustand: IDLE. Suche nach Aufgaben..."
            G_CURRENT_STATE = FindNextWTTask()
            If G_CURRENT_STATE = STATE_IDLE Then
                Wait 0.1
            EndIf
            GoTo RunStateMachineExit ' Sprung zum Ende der Funktion
            
        Case STATE_ERROR
        	Print "something is wrong"
        	Print "cu"
        	Quit All

        Case STATE_WAIT_FOR_SECOND_WT
            Print "Aktueller Zustand: WARTE AUF ZWEITES TEIL fuer WT " + Str$(G_CURRENTPROCESSWT2)

            If G_WAITFORSECONDPARTSTARTTIME = 0 Then
                G_WAITFORSECONDPARTSTARTTIME = Time(2)
                Print "Timer gestartet fuer zweites Teil..."
            EndIf

            If Sw(i_Teil_auf_Band_rdy) Then
                Print "Zweites Teil fuer WT " + Str$(G_CURRENTPROCESSWT2) + " angekommen! Starte Paar-Bearbeitung."
                G_WT_INTERNERSTATUS(G_CURRENTPROCESSWT1) = WT_STATUS_UNBEARBEITET
                G_WT_INTERNERSTATUS(G_CURRENTPROCESSWT2) = WT_STATUS_UNBEARBEITET
                G_CURRENT_STATE = STATE_BOTH_WTS_READY_TO_PROCESS
                G_WAITFORSECONDPARTSTARTTIME = 0
                GoTo RunStateMachineExit ' Sprung zum Ende der Funktion
            EndIf

            If Time(2) - G_WAITFORSECONDPARTSTARTTIME >= 3 Then
                Print "Timeout fuer zweites Teil auf WT " + Str$(G_CURRENTPROCESSWT2) + ". Bearbeite WT " + Str$(G_CURRENTPROCESSWT1) + " einzeln."
                G_WT_INTERNERSTATUS(G_CURRENTPROCESSWT1) = WT_STATUS_UNBEARBEITET
                G_WT_INTERNERSTATUS(G_CURRENTPROCESSWT2) = WT_STATUS_LEER ' Zweiter WT als leer markieren
                G_CURRENT_STATE = STATE_PROCESS_SINGLE_WT
                G_WAITFORSECONDPARTSTARTTIME = 0
                GoTo RunStateMachineExit ' Sprung zum Ende der Funktion
            EndIf

            Wait 0.1
        
        Case STATE_BOTH_WTS_READY_TO_PROCESS
            Print "Aktueller Zustand: BEARBEITE BEIDE TEILE (WT " + Str$(G_CURRENTPROCESSWT1) + " und WT " + Str$(G_CURRENTPROCESSWT2) + ")"
            Call ProcessPart(G_CURRENTPROCESSWT1)
            Call ProcessPart(G_CURRENTPROCESSWT2)
            
            G_WT_INTERNERSTATUS(G_CURRENTPROCESSWT1) = WT_STATUS_BEARBEITET
            G_WT_INTERNERSTATUS(G_CURRENTPROCESSWT2) = WT_STATUS_BEARBEITET

            G_CURRENT_STATE = STATE_BOTH_WTS_READY_FOR_PICKUP
            ' Kein GOTO nötig, da dies der natürliche Codefluss zum Ende ist
        
        Case STATE_BOTH_WTS_READY_FOR_PICKUP
            Print "Aktueller Zustand: HOLE BEIDE TEILE AB (WT " + Str$(G_CURRENTPROCESSWT1) + " und WT " + Str$(G_CURRENTPROCESSWT2) + ")"
            Call PickUpAndStoreFinishedPart(G_CURRENTPROCESSWT1)
            G_WT_INTERNERSTATUS(G_CURRENTPROCESSWT1) = WT_STATUS_LEER

            Call PickUpAndStoreFinishedPart(G_CURRENTPROCESSWT2)
            G_WT_INTERNERSTATUS(G_CURRENTPROCESSWT2) = WT_STATUS_LEER

            G_CURRENT_STATE = STATE_IDLE
        
        Case STATE_WT_STATUS_UNKNOWN_ACTION
            Print "Aktueller Zustand: UNBEKANNTES TEIL BEHANDELN auf WT " + Str$(G_CURRENTPROCESSWT1)
            Call DisposeUnknownPart(G_CURRENTPROCESSWT1)
            G_WT_INTERNERSTATUS(G_CURRENTPROCESSWT1) = WT_STATUS_LEER
            G_CURRENT_STATE = STATE_IDLE
        
        Case STATE_WT_ERROR_ACTION
            Print "Aktueller Zustand: FEHLERHAFTES TEIL BEHANDELN auf WT " + Str$(G_CURRENTPROCESSWT1)
            Call DisposeFaultyPart(G_CURRENTPROCESSWT1)
            G_WT_INTERNERSTATUS(G_CURRENTPROCESSWT1) = WT_STATUS_LEER
            G_CURRENT_STATE = STATE_IDLE
        
        Case STATE_PICKUP_SINGLE_PART
            Print "Aktueller Zustand: HOLE EINZELNES TEIL AB von WT " + Str$(G_CURRENTPROCESSWT1)
            Call PickUpAndStoreFinishedPart(G_CURRENTPROCESSWT1)
            G_WT_INTERNERSTATUS(G_CURRENTPROCESSWT1) = WT_STATUS_LEER
            G_CURRENT_STATE = STATE_IDLE
        
        Case STATE_PROCESS_SINGLE_WT
            Print "Aktueller Zustand: BEARBEITE EINZELNES TEIL auf WT " + Str$(G_CURRENTPROCESSWT1)
            Call ProcessPart(G_CURRENTPROCESSWT1)
            G_WT_INTERNERSTATUS(G_CURRENTPROCESSWT1) = WT_STATUS_BEARBEITET
            G_CURRENT_STATE = STATE_IDLE
        
        Default
            Print "FEHLER: Unbekannter Zustand im Zustandsautomaten: " + Str$(G_CURRENT_STATE)
            Wait 1
    Send
RunStateMachineExit: ' Label für GOTO-Sprünge innerhalb der Funktion
Fend

' --- Hilfsfunktion zum Finden der naechsten Aufgabe und Setzen des Folgezustands ---
Function FindNextWTTask()
    Integer COUNT_FOUND
    Integer TEMP_WTS(2)
    Integer i

    ' Standard-Rückgabewert, falls keine spezifische Aufgabe gefunden wird
    FindNextWTTask = STATE_IDLE

    ' 1. Prioritaet: Aufraeumen (unbekannt/fehlerhaft) - hoechste Prioritaet!
    For i = 1 To 4
        If GetNestStatus(i) = 1 And (G_WT_INTERNERSTATUS(i) = WT_STATUS_UNBEKANNT Or G_WT_INTERNERSTATUS(i) = WT_STATUS_FEHLER) Then
            G_CURRENTPROCESSWT1 = i
            Print "Aufgabe gefunden: Aufraeumen von WT " + Str$(i) + " (Status: " + Str$(G_WT_INTERNERSTATUS(i)) + ")"
            FindNextWTTask = STATE_WT_STATUS_UNKNOWN_ACTION
            GoTo FindNextWTTaskExit ' Springe zum Ende der Funktion
        ElseIf GetNestStatus(i) = 0 And (G_WT_INTERNERSTATUS(i) = WT_STATUS_UNBEKANNT Or G_WT_INTERNERSTATUS(i) = WT_STATUS_FEHLER) Then
            Print "WARNUNG: WT " + Str$(i) + " intern als " + Str$(G_WT_INTERNERSTATUS(i)) + " markiert, aber physisch leer. Setze auf LEER."
            G_WT_INTERNERSTATUS(i) = WT_STATUS_LEER
        EndIf
    Next

    ' 2. Prioritaet: Abholung von bearbeiteten Teilen (Paare oder Einzel)
    COUNT_FOUND = 0
    For i = 1 To 4
        If G_WT_INTERNERSTATUS(i) = WT_STATUS_BEARBEITET Then	'and In(?) maybe
            COUNT_FOUND = COUNT_FOUND + 1
            If COUNT_FOUND = 1 Then TEMP_WTS(1) = i
            If COUNT_FOUND = 2 Then TEMP_WTS(2) = i
        EndIf
    Next

    If COUNT_FOUND >= 2 Then
        G_CURRENTPROCESSWT1 = TEMP_WTS(1)
        G_CURRENTPROCESSWT2 = TEMP_WTS(2)
        Print "Aufgabe gefunden: Abholung von WT " + Str$(G_CURRENTPROCESSWT1) + " und WT " + Str$(G_CURRENTPROCESSWT2)
        FindNextWTTask = STATE_BOTH_WTS_READY_FOR_PICKUP
        GoTo FindNextWTTaskExit
    ElseIf COUNT_FOUND = 1 Then
        G_CURRENTPROCESSWT1 = TEMP_WTS(1)
        Print "Aufgabe gefunden: Abholung von WT " + Str$(G_CURRENTPROCESSWT1) + " (Einzelteil)"
        FindNextWTTask = STATE_PICKUP_SINGLE_PART
        GoTo FindNextWTTaskExit
    EndIf

    ' 3. Prioritaet: Bearbeiten von vorbereiteten Teilen (Paare oder Einzel)
    COUNT_FOUND = 0
    For i = 1 To 4
        If G_WT_INTERNERSTATUS(i) = WT_STATUS_UNBEARBEITET And In(i) Then
            COUNT_FOUND = COUNT_FOUND + 1
            If COUNT_FOUND = 1 Then TEMP_WTS(1) = i
            If COUNT_FOUND = 2 Then TEMP_WTS(2) = i
        EndIf
    Next

    If COUNT_FOUND >= 2 Then
        G_CURRENTPROCESSWT1 = TEMP_WTS(1)
        G_CURRENTPROCESSWT2 = TEMP_WTS(2)
        Print "Aufgabe gefunden: Bearbeitung von WT " + Str$(G_CURRENTPROCESSWT1) + " und WT " + Str$(G_CURRENTPROCESSWT2)
        FindNextWTTask = STATE_BOTH_WTS_READY_TO_PROCESS
        GoTo FindNextWTTaskExit
    ElseIf COUNT_FOUND = 1 Then
        G_CURRENTPROCESSWT1 = TEMP_WTS(1)
        Print "Aufgabe gefunden: Bearbeitung von WT " + Str$(G_CURRENTPROCESSWT1) + " (Einzelteil)"
        FindNextWTTask = STATE_PROCESS_SINGLE_WT
        GoTo FindNextWTTaskExit
    EndIf

    ' 4. Prioritaet: Bestuecken neuer Paare (Niedrigste Prioritaet)
    COUNT_FOUND = 0
    For i = 1 To 4
        ' Nur WTs betrachten, die LEER und NICHT GESPERRT sind
        If Not In(i) And G_WT_INTERNERSTATUS(i) = WT_STATUS_LEER Then
            COUNT_FOUND = COUNT_FOUND + 1
            If COUNT_FOUND = 1 Then TEMP_WTS(1) = i
            If COUNT_FOUND = 2 Then TEMP_WTS(2) = i
        EndIf
    Next

    If COUNT_FOUND >= 2 Then
        G_CURRENTPROCESSWT1 = TEMP_WTS(1)
        G_CURRENTPROCESSWT2 = TEMP_WTS(2)
        Print "Aufgabe gefunden: Bestuecke WT " + Str$(G_CURRENTPROCESSWT1) + " (Typ " + Str$(G_CURRENTPARTTYPE) + "). Warte auf zweites Teil fuer WT " + Str$(G_CURRENTPROCESSWT2)
        Call PlacePartInWT(G_CURRENTPROCESSWT1)
        G_WT_INTERNERSTATUS(G_CURRENTPROCESSWT1) = WT_STATUS_BESTUECKT_WARTE_ZWEI
        FindNextWTTask = STATE_WAIT_FOR_SECOND_WT
        GoTo FindNextWTTaskExit
    EndIf

    ' Wenn keine Aufgabe gefunden wurde, bleibt FindNextWTTask auf STATE_IDLE (Standardwert)
FindNextWTTaskExit: ' Label für den GOTO-Sprung
Fend


Function PickPartFromBelt
	Jump Abholen :Z(0)
	Go Abholen
	Print "greifer + zylinder as"
	Print "zylinder gs"
	Jump Abholen :Z(0)
Fend
' --- Hilfsfunktionen fuer Roboteraktionen (Platzhalter - hier deine Bewegungen einfuegen) ---
Function PlacePartInWT(WT_INDEX As Integer)
	Call PickPartFromBelt
    Print "Aktion: Platziere Teil in WT " + Str$(WT_INDEX) + " fuer Teiltyp " + Str$(G_CURRENTPARTTYPE) + "..."
    
	Select WT_INDEX
		Case 1
			Jump Nest1_p
		Case 2
			Jump Nest2_p
		Case 3
			Jump Nest3_p
		Case 3
			Jump Nest4_P
		Default
			Print "error PlacePartInWT " + Str$(WT_INDEX)
	Send
	Print "call greifer zylinder"
Fend

Function ProcessPart(WT_INDEX As Integer)
    Print "Aktion: Bearbeite Teil in WT " + Str$(WT_INDEX) + " (Typ " + Str$(G_CURRENTPARTTYPE) + ") ..."
    Wait 0.1
Fend

Function PickUpAndStoreFinishedPart(WT_INDEX As Integer)
    Print "Aktion: Hole bearbeitetes Teil von WT " + Str$(WT_INDEX) + " ab und lagere es..."
    Wait 0.5
Fend

Function DisposeUnknownPart(WT_INDEX As Integer)
    Print "Aktion: Entsorge unbekanntes Teil von WT " + Str$(WT_INDEX) + "..."
    Wait 0.5
Fend

Function DisposeFaultyPart(WT_INDEX As Integer)
    Print "Aktion: Entsorge fehlerhaftes Teil von WT " + Str$(WT_Index) + "..."
    Wait 0.5
Fend

' --- Hauptprogramm ---
Function mainTest()
    Call InitializeSystem

    ' Pruefe, ob die Initialisierung erfolgreich war (G_CURRENT_STATE = -1 im Fehlerfall)
    If G_CURRENT_STATE = -1 Then
        Print "System konnte nicht initialisiert werden. Bitte Fehler beheben und neu starten."
        Quit All ' Beende das Programm, wenn Initialisierung fehlgeschlagen ist
    EndIf

    ' Endlosschleife fuer den Zustandsautomaten
    Do
        ' RunStateMachine ruft FindNextWTTask intern auf und steuert die Ablaeufe
        Call RunStateMachine()
    Loop
Fend




