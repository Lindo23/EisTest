Function Simulation
    ' --- Variablen-Deklaration ---
    Integer i, byteIdx, bitIdx, status, idx, typ
    Integer masks(8)
    Integer validInputBytes(8) ' Anzupassen, falls deine Inputs in anderen Bytes liegen
    Integer swOn(600), swOff(600) ' Größe der Arrays an maximale Bit-Nummer anpassen

    Integer lastActivePos
    lastActivePos = -1
	
	'Typen Wahl 
	SetSw 752, On
	SetSw 753, On
	SetSw 754, Off
	
    ' --- 1) Feste Bit-Masken 1,2,4,…,128 ---
    masks(0) = 1
    masks(1) = 2
    masks(2) = 4
    masks(3) = 8
    masks(4) = 16
    masks(5) = 32
    masks(6) = 64
    masks(7) = 128

    ' --- 2) Die relevanten Input-Bytes basierend auf io.dat ---
    ' Ich habe hier die Bytes 0, 65, 66, 68, 69, 70, 71, 72 gewählt,
    ' da deine Input-Bits ab Bit 8 und dann ab Bit 525 beginnen.
    ' Bitte überprüfe, ob diese Auswahl alle relevanten Input-Bytes abdeckt.
    validInputBytes(0) = 0   ' Für Bit 8 (i_Teil_auf_Band_rdy)
    validInputBytes(1) = 65  ' Für Bits ab 525 (525/8 = 65, Rest 5)
    validInputBytes(2) = 66
    validInputBytes(3) = 67
    validInputBytes(4) = 68
    validInputBytes(5) = 69
    validInputBytes(6) = 70
    validInputBytes(7) = 71
    ' Füge bei Bedarf weitere validBytes hinzu, wenn deine Inputs in höheren Bytes liegen.

    ' --- 3) swOn/swOff-Mapping basierend auf OutputBitLabels und MemoryBitLabels
    ' Diese werden jetzt dynamisch belegt, um die Simulation der Inputs zu steuern.
    ' Hier werden Output-Bits auf Input-Bits gemappt, wo eine direkte Reaktion erwartet wird.
    ' Bitte diese Mappings prüfen und ggf. erweitern/anpassen.

    ' Output Y_Greifer_GS (528) -> Input Greifer_GS (528)
    swOn(Y_Greifer_GS) = Greifer_GS
    swOff(Y_Greifer_GS) = Greifer_AS ' Greifer_AS wird ausgeschaltet, wenn Greifer_GS aktiv

    ' Output Y_Greifer_AS (529) -> Input Greifer_AS (529)
    swOn(Y_Greifer_AS) = Greifer_AS
    swOff(Y_Greifer_AS) = Greifer_GS ' Greifer_GS wird ausgeschaltet, wenn Greifer_AS aktiv

    ' Output Y_LEV_GS (530) -> Input LEV_GS (530)
    swOn(Y_LEV_GS) = LEV_GS
    swOff(Y_LEV_GS) = LEV_AS

    ' Output Y_LEV_AS (531) -> Input LEV_AS (531)
    swOn(Y_LEV_AS) = LEV_AS
    swOff(Y_LEV_AS) = LEV_GS

    ' Output Y_BT_Nest1_GS (532) -> Input Nest1_GS (532)
    swOn(Y_BT_Nest1_GS) = Nest1_GS
    swOff(Y_BT_Nest1_GS) = Nest1_AS

    ' Output Y_BT_Nest1_AS (533) -> Input Nest1_AS (533)
    swOn(Y_BT_Nest1_AS) = Nest1_AS
    swOff(Y_BT_Nest1_AS) = Nest1_GS

    ' Output Y_BT_Nest2_GS (534) -> Input Nest2_GS (534)
    swOn(Y_BT_Nest2_GS) = Nest2_GS
    swOff(Y_BT_Nest2_GS) = Nest2_AS

    ' Output Y_BT_Nest2_AS (535) -> Input Nest2_AS (535)
    swOn(Y_BT_Nest2_AS) = Nest2_AS
    swOff(Y_BT_Nest2_AS) = Nest2_GS

    ' Output abgeholt_von_Robbi (536) -> Input i_Teil_auf_Band_rdy (8)
    ' Dies ist ein Beispiel für eine logische Verknüpfung: Wenn der Roboter das Teil abholt,
    ' ist das Band nicht mehr bereit.
    swOff(abgeholt_von_Robbi) = i_Teil_auf_Band_rdy

    ' Output Y_BT_Nest3_GS (537) -> Input Nest3_GS (548)
    swOn(Y_BT_Nest3_GS) = Nest3_GS
    swOff(Y_BT_Nest3_GS) = Nest3_AS

    ' Output Y_BT_Nest3_AS (538) -> Input Nest3_AS (549)
    swOn(Y_BT_Nest3_AS) = Nest3_AS
    swOff(Y_BT_Nest3_AS) = Nest3_GS

    ' Output Y_BT_Nest4_GS (539) -> Input Nest4_GS (550)
    swOn(Y_BT_Nest4_GS) = Nest4_GS
    swOff(Y_BT_Nest4_GS) = Nest4_AS

    ' Output Y_BT_Nest4_AS (540) -> Input Nest4_AS (551)
    swOn(Y_BT_Nest4_AS) = Nest4_AS
    swOff(Y_BT_Nest4_AS) = Nest4_GS

    ' Output Anforderung_Nestdrehen (545) -> Input Nest_wurde_gedreht (545)
    ' Simuliert, dass das Nest gedreht wurde, wenn die Anforderung kommt.
    swOn(Anforderung_Nestdrehen) = Nest_wurde_gedreht

    ' Output Strahlen_fertig_sps (546) -> Input Vision_IO (538) oder Vision_NIO (539)
    ' Hier musst du selbst entscheiden, wie die Logik sein soll.
    ' Zum Beispiel: Wenn Strahlen_fertig_sps gesetzt ist, setze Vision_IO oder Vision_NIO.
    ' Beispiel:
    ' swOn(Strahlen_fertig_sps) = Vision_IO
    ' swOff(Strahlen_fertig_sps) = Vision_NIO

    ' Output GST_fertig_sps (547) -> Input Nest_GST (546)
    swOn(GST_fertig_sps) = Nest_GST
    swOff(GST_fertig_sps) = Off ' Schalte Nest_GST aus, wenn GST_fertig_sps nicht aktiv ist.


    ' Beispiel für die Ermo-Positionen, basierend auf deinen ursprünglichen swOn/swOff Definitionen.
    ' Diese benötigen entsprechende Input-Labels in deiner io.dat, die ich aktuell nicht sehe.
    ' Wenn diese "bErmo_PosX_ready" o.Ä. Output-Labels sind, dann müsstest du sie auf Input-Labels mappen.
    ' Beispielsweise, wenn bErmo_Referenced ein Output ist, der den Input i_Referenced_Ermo steuert:
    ' swOn(bErmo_Referenced) = i_Referenced_Ermo
    ' swOff(bErmo_Referenced) = Off ' oder ein entsprechendes Gegen-Bit


    ' --- 4) Simulation starten ---
    Do
        ' Iteriere über alle relevanten Output-Bytes
        For i = 0 To 7 ' Geht nur bis 7, da validInputBytes 8 Elemente hat (0-7)
            byteIdx = validInputBytes(i)
            status = Out(byteIdx) ' Lies den Status der Output-Bytes

            ' Jedes der 8 Bits in diesem Byte
            For bitIdx = 0 To 7
                idx = byteIdx * 8 + bitIdx ' Berechne die absolute Bit-Nummer
                
                ' Prüfe, ob ein swOn-Mapping für dieses Output-Bit existiert
                If swOn(idx) <> 0 Then ' Prüft, ob ein Input-Bit-Label an dieser Stelle gemappt ist
                    If (status And masks(bitIdx)) <> 0 Then
                        SetSw swOn(idx), On ' Schalte den gemappten Input EIN
                    Else
                        SetSw swOn(idx), Off ' Schalte den gemappten Input AUS
                    EndIf
                EndIf

                ' Prüfe, ob ein swOff-Mapping für dieses Output-Bit existiert
                If swOff(idx) <> 0 Then ' Prüft, ob ein Input-Bit-Label an dieser Stelle gemappt ist
                    If (status And masks(bitIdx)) <> 0 Then
                        SetSw swOff(idx), Off ' Schalte den gemappten Input AUS, wenn Output AN
                    Else
                        SetSw swOff(idx), On ' Schalte den gemappten Input EIN, wenn Output AUS
                    EndIf
                EndIf
            Next bitIdx
        Next i

        Wait 0.1 ' Kurze Pause, um CPU-Auslastung zu reduzieren
    Loop

Fend
