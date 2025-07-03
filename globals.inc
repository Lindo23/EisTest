Global Real tZyklus						' Timer für Zykluszeit

' Setzen der in/output bits von Grundstellung (GS), Arbeitsstellung (AS) der Werkzeugträger (WT)
Global Integer WT_INPUT_BIT_GS(4)
Global Integer WT_INPUT_BIT_AS(4)
Global Integer WT_OUTPUT_BIT_GS(4)
Global Integer WT_OUTPUT_BIT_AS(4)

Global Integer g_ALLOWED_WT(2)			' erlaubte / benutzbare Werkzeugträger

' Setzen der Variablen für Freigabe (InW(41)) (FG) von SPS und Rückmeldung(OutW(41)) (RM) zur SPS
Global Integer FG_GRUNDSTELLUNG
Global Integer FG_EINLEGEN
Global Integer FG_STRAHLEN
Global Integer FG_ABHOLEN

Global Integer RM_START
Global Integer RM_GRUNDSTELLUNG_BEGINN
Global Integer RM_GRUNDSTELLUNG_FERTIG
Global Integer RM_EINLEGEN_BEGINN
Global Integer RM_EINLEGEN_FERTIG
Global Integer RM_STRAHLEN_BEGINN
Global Integer RM_STRAHLEN_FERTIG
Global Integer RM_ABHOLEN_BEGINN
Global Integer RM_ABHOLEN_FERTIG

' Kommunikation Roboter -> SPS -> ColdJet -> SPS -> Roboter
' CJ_out_ -> vorgabe was ColdJet machen soll, CJ_in_ -> rückmeldung was ColdJet macht.
Global Integer CJ_out_STRAHLEN
Global Integer CJ_out_NUR_LUFT
Global Integer CJ_out_AUS

Global Integer CJ_in_STRAHLT
Global Integer CJ_in_NUR_LUFT
Global Integer CJ_in_aus
