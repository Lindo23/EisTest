#include "globaleVariablen.inc"
' --- Initialisierungsfunktion ---
' Wird einmal beim Start des Programms aufgerufen, um die Anfangszustände zu setzen

Function InitializeSystem
	
	Call setGlobals
	
	If Motor = Off Then
		Motor On
	EndIf
	
	Speed 100
	Accel 100, 100
	SpeedS 2000
 	AccelS 5000

	Power High
	
	
    Print "Initialisiere System..."
    G_CURRENT_STATE = STATE_IDLE
    G_WAITFORSECONDPARTSTARTTIME = 0

    ' Lese den Teiltyp einmalig zu Beginn
    Call ReadPartTypeFromSPS()

    ' Deklaration lokaler Variablen
    Integer i
    Integer WT_ALLOWED_START
    Integer WT_ALLOWED_END
    Integer errorOnWTCount
    errorOnWTCount = 0
    ' Check WT sensoren ob GS oder AS und speichere intern

    ' Setze den initialen Status der WTs basierend auf physischen Sensoren
    For i = 1 To 4
    	If GetNestStatus(i) = 1 Then '0=offen, 1=zu
            G_WT_INTERNERSTATUS(i) = WT_STATUS_UNBEKANNT
            Print "WT " + Str$(i) + " bei Start belegt (unbekannter Status)."
        ElseIf GetNestStatus(i) = 0 Then
            G_WT_INTERNERSTATUS(i) = WT_STATUS_LEER
            Print "WT " + Str$(i) + " bei Start leer."
        Else
        	G_WT_INTERNERSTATUS(i) = WT_STATUS_FEHLER
        	Print "WT " + Str$(i) + " Endschalter prüfen!"
        	errorOnWTCount = errorOnWTCount + 1
        	If errorOnWTCount > 3 Then
        		Print "Achtung alle Werkzeugträger sind niO, endschalter Prüfen!"
        		G_CURRENT_STATE = STATE_ERROR
        	EndIf
    	EndIf
    	
    Next

    ' Sperre die WTs basierend auf dem G_CURRENTPARTTYPE, wenn sie LEER sind.
    If G_CURRENTPARTTYPE >= 1 And G_CURRENTPARTTYPE <= 3 Then
        WT_ALLOWED_START = 1
        WT_ALLOWED_END = 2
        Print "System fuer Teiltyp 1-3 konfiguriert. Erlaubte WTs: 1, 2."
    ElseIf G_CURRENTPARTTYPE >= 4 And G_CURRENTPARTTYPE <= 5 Then
        WT_ALLOWED_START = 3
        WT_ALLOWED_END = 4
        Print "System fuer Teiltyp 4-5 konfiguriert. Erlaubte WTs: 3, 4."
    Else
        ' Fehlerfall: Ungültiger Teiltyp.
        Print "FEHLER: Ungueltiger Teiltyp bei Initialisierung: " + Str$(G_CURRENTPARTTYPE) + ". Keine WT-Sperrung vorgenommen. Roboter kann nicht starten."
        G_CURRENT_STATE = -1 ' Setze auf einen Fehlerzustand
        GoTo InitializeSystemExit ' Springe zum Ende der Funktion
    EndIf

    For i = 1 To 4
        ' Wenn der WT nicht im erlaubten Bereich liegt UND er leer ist
        If (i < WT_ALLOWED_START Or i > WT_ALLOWED_END) And G_WT_INTERNERSTATUS(i) = WT_STATUS_LEER Then
            G_WT_INTERNERSTATUS(i) = WT_STATUS_GESPERRT
            Print "WT " + Str$(i) + " wurde fuer diesen Teiltyp (" + Str$(G_CURRENTPARTTYPE) + ") GESPERRT."
        EndIf
    Next

    Print "System initialisiert. Starte Zustandsautomat."
InitializeSystemExit: ' Label für den GOTO-Sprung
Fend





Function setGlobals
		' Deklarieren der Bit-Adressen für die Nest-Sensoren

    WT_INPUT_GS(1) = 532 ' Nest1_GS
    WT_INPUT_AS(1) = 533 ' Nest1_AS
    WT_INPUT_GS(2) = 534 ' Nest2_GS
    WT_INPUT_AS(2) = 535 ' Nest2_AS
    WT_INPUT_GS(3) = 548 ' Nest3_GS
    WT_INPUT_AS(3) = 549 ' Nest3_AS
    WT_INPUT_GS(4) = 550 ' Nest4_GS
    WT_INPUT_AS(4) = 551 ' Nest4_AS
    
    WT_OUTPUT_GS(1) = 532 ' Nest1_GS
    WT_OUTPUT_AS(1) = 533 ' Nest1_AS
    WT_OUTPUT_GS(2) = 534 ' Nest2_GS
    WT_OUTPUT_AS(2) = 535 ' Nest2_AS
    WT_OUTPUT_GS(3) = 537 ' Nest3_GS
    WT_OUTPUT_AS(3) = 538 ' Nest3_AS
    WT_OUTPUT_GS(4) = 539 ' Nest4_GS
    WT_OUTPUT_AS(4) = 540 ' Nest4_AS
    

    ' Setze Konstantenwerte
    STATE_ERROR = 999
    STATE_IDLE = 0
    STATE_WAIT_FOR_SECOND_WT = 15
    STATE_BOTH_WTS_READY_TO_PROCESS = 25
    STATE_BOTH_WTS_READY_FOR_PICKUP = 35
    STATE_WT_STATUS_UNKNOWN_ACTION = 10
    STATE_WT_ERROR_ACTION = 40
    STATE_PICKUP_SINGLE_PART = 50
    STATE_PROCESS_SINGLE_WT = 60

    WT_STATUS_LEER = 0
    WT_STATUS_UNBEKANNT = 1
    WT_STATUS_UNBEARBEITET = 2
    WT_STATUS_BEARBEITET = 3
    WT_STATUS_FEHLER = 4
    WT_STATUS_BESTUECKT_WARTE_ZWEI = 5
    WT_STATUS_GESPERRT = 6
    
Fend

