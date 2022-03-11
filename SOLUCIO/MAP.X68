; =============================================================================
; TITLE    : MEMORY MAPPED HARD CODE
; AUTHOR   : SERGI MORENO PÉREZ
; COMMENTS :
; HISTORY  : 25/OCTUBRE/2020 - MODIFICACIÓ
; =============================================================================

; -----------------------------------------------------------------------------

MAPINIT
; SHOWS HARDWARE WINDOW AND GETS MAPPING ADDRESSESG.
; INPUT    - D0.B BIT 0: SHOW HARDWARE WINDOW (1: YES, 0: NO)
;                 BIT 1: GET MAPPING ADDRESSES (1: YES, 0: NO)
;                 BIT 2-7: NOT USED.
;            A0 POINTER TO RAM ADDRESS TO STORE THE MAPPING ADDRESSES IN THIS
;               ORDER: 7-SEGMENT, LEDS, SWITCHES, BUTTONS.
;               IF D0.B BIT 1 IS ZERO, A0 IS NOT USED.
; OUTPUT   - NO OUTPUT THROUGH REGISTERS
;            RAM POINTED BY A0 IS MODIFIED IF D0.B BIT 1 IS 1
; MODIFIES - NONE
; -----------------------------------------------------------------------------
            MOVEM.L A0-A1/D0-D2,-(A7)

            MOVE.B  D0,D2                   ; UTILITZAM D2 COM A REGISTRE AUX
            BTST.L  #0,D2
            BEQ     .NO_SHOWINDOW
            
            MOVE.B  #32,D0                  ; SI EL BIT MENYS SIGNIFICATIU
            CLR.B   D1                      ; DE D0 ÉS 1, MOSTRAM LA HARDWARE
            TRAP    #15                     ; WINDOW A TRAVÉS DEL TRAP 15
            
.NO_SHOWINDOW
            BTST.L  #1,D2                   ; COMPROVAM SOBRE D2 EL VALOR DEL
                                            ; PENÚLTIM BIT MENYS SIGNIFICATIU
                                            ; DE D0
            BEQ     .EXIT
            
            ; A TRAVÉS DELS VALORS DEL VECTOR .VEC QUE ANIREM MOVENT A D1
            ; I DE LA INSTRUCCIÓ TRAP 15, PODREM OBTENIR LES ADRECES DE 
            ; MAPATGE DELS DISPOSITIUS DE HARDWARE, SEGUINT L'ORDRE
            ; DEFINIT PEL VECTOR; I EMMAGATZEMAR-LES A LA POSICIÓ DE MEMÒRIA
            ; APUNTADA PER A0
            LEA     .VEC,A1
            MOVE.B  #32,D0
.LOOP       MOVE.B  (A1)+,D1
            BEQ     .EXIT
            TRAP    #15
            MOVE.L  D1,(A0)+
            BRA     .LOOP
            
.EXIT 
            MOVEM.L (A7)+,A0-A1/D0-D2
            RTS
            
            ; VECTOR AMB ELS VALORS PER OBTENIR LES ADRECES DE
            ; MAPATGE, JUNT AMB EL VALOR 0 PER FINALITZAR EL BUCLE
.VEC        DC.B    1,2,3,7,0
            DS.W    0


; -----------------------------------------------------------------------------
MAPPRBIT
; PRINTS 'ZERO','ONE','TWO',...,'SEVEN' INTO THE 7-SEGMENT DISPLAYS DEPENDING
; ON THE BUTTON THAT IS PRESSED (ZERO IS THE RIGHTMOST, SEVEN IS THE LEFTMOST).
; PRINTS 'NONE' IF NO BUTTON IS PRESSED.
; INPUT    - A0 BUTTONS MAPPING ADDRESS
;            A1 7-SEGMENT DISPLAY MAPPING ADDRESS
; OUTPUT   - NONE THROUGH REGISTERS
; MODIFIES - NO REGISTER MODIFIED
; -----------------------------------------------------------------------------
            MOVEM.L A0-A1/D0,-(A7)
            
            MOVE.B  (A0),D0                 ; FICAM A D0 EL BYTE MENYS
                                            ; SIGNIFICATIU DE L'ADREÇA DE 
                                            ; MAPATGE DE BUTTONS
            NOT.B   D0
            JSR     BITPOS                  ; CRIDADA A BITPOS, RETORNA A D0 LA
                                            ; POSICIÓ DEL PRIMER BIT A 1

            LEA     .OUTPUT,A0
            
            ; OPERACIÓ SOBRE D2 PER POSICIONAR-SE A LA STRING DEL VECTOR
            ; .OUTPUT CORRECTE I AMB LA CRIDADA A STR2SEG, LA VISUALITZAREM
            MULS.W  #8,D0
            ADDA.L  D0,A0
            JSR     STR2SEG

            MOVEM.L (A7)+,A0-A1/D0
            RTS
            
            ; VECTOR DE STRINGS QUE VISUALITZAREM SOBRE ELS SET SEGMENTS EN
            ; FUNCIÓ DEL BOTÓ PULSAT
.OUTPUT     DC.B    'ZERO    ','ONE     ','TWO     ','THREE   '
            DC.B    'FOUR    ','FIVE    ','SIX     ','SEVEN   ','NONE    '
            DS.W    0














*~Font name~Courier New~
*~Font size~10~
*~Tab type~0~
*~Tab size~4~
