; =============================================================================
; TITLE    : AUXILIARY CODE
; AUTHOR   : SERGI MORENO PÉREZ
; COMMENTS : 
; HISTORY  : 25/OCTUBRE/2020 - MODIFICACIÓ
; =============================================================================

; -----------------------------------------------------------------------------

STR2SEG
; CONVERTS A STRING OF 8 CHARS INTO THE 7-SEGMENT DISPLAYS WORDS SEQUENCE,
; READY TO BE SENT TO THE DISPLAYS.
; ACCEPTS CHARACTERS FROM A TO Z AND FROM a TO z AND SPACE. CAPITAL AND NON
; CAPITAL ARE DISPLAYED WITH THE SAME GRAPHIC.
; INPUT    - A0 POINTER TO THE STRING (8 CHAR)
;            A1 POINTER TO THE ADDRESS WHERE TO PUT THE WORDS SEQUENCE
; OUTPUT   - MEMORY FROM (A1) TO (A0+15) MODIFIED.
; MODIFIES - NO REGISTERS MODIFIED
; NOTE     - BEHAVIOR IN FRONT OF CHARS OUTSIDE RANGES A-Z AND a-z AND SPACE
;            IS UNDEFINED
; -----------------------------------------------------------------------------
            MOVEM.L A0-A2/D0-D1,-(A7)
            
            MOVE.B  #8,D0
            SUBQ.B  #1,D0
            
.LOOP       LEA     .VALUES,A2
            CLR.W   D1
            MOVE.B  (A0)+,D1                ;GUARDA A D1 EL CODI ASCII DEL CHAR
                                            ;APUNTAT PER A0
            
            ; RESTA 96 DECIMAL AL CODI ASCII EMMAGATZEMAT PER SABER QUINA
            ; POSICIÓ DEL VECTOR .VALUES HEM DE REPRESENTAR
            SUB.B   #96,D1   
               
            ; EN CAS DE QUE FOS MINÚSCULA, FARÍEM EL BRANCH, EN CAS CONTRARI
            ; SUMARÍEM 32 DECIMAL AL RESULTAT DE LA RESTA ANTERIOR PER OBTENIR
            ; LA POSICIÓ CORRECTE DEL VECTOR
            BGE     .MINUS 
            
            ADD.B   #32,D1 
            ; SI ES TRACTA DEL CHAR ' ', NO FA FALTA FER CAP MOVIMENT SOBRE EL
            ; VECTOR, JA QUE EL VALOR DE LA SEVA REPRESENTACIÓ OCUPA LA 1A
            ; POSICIÓ DEL VECTOR .VALUES
            BMI     .ESPAI
            
.MINUS      ADDA.L  D1,A2 ; SUMAM L'ÍNDEX OBTINGUT A A2 PER POSICIONAR-SE
                          ; A LA POSICIÓ DE .VALUES ADEQUADA

            ; MOVEM EL VALOR OBTINGUT DEL VECTOR AL BYTE MENYS SIGNIFICATIU
            ; DE L'ADREÇA DE MAPATGE DELS SEGMENTS, POSTERIORMENT AUGMENTAM
            ; L'ADREÇA PER APUNTAR AL SEGÜENT DISPLAY ON REPRESENTAR EL CHAR
.ESPAI      MOVE.B  (A2),(A1)
            ADDA.L  #2,A1
            DBRA    D0,.LOOP
            
            MOVEM.L (A7)+,A0-A2/D0-D1
            
            RTS

            ; VECTOR QUE CONTÉ EL VALOR PER A LA REPRESENTACIÓ DE CADA
            ; CHAR NECESSITADA SOBRE EL VISUALITZADOR DE SET SEGMENTS
.VALUES     DC.B    $0,$77,$7C,$39,$5E,$79,$71,$3D,$76,$30,$1E,$76,$38,$37,$37
            DC.B    $3F,$73,$3F,$50,$6D,$78,$3E,$3E,$3E,$76,$6E,$5B
            DS.W    0     
      
; -----------------------------------------------------------------------------
BITPOS
; GIVEN A BYTE, IT RETURNS THE POSITION (VALUE BETWEEN 0 AND 7) OF THE RIGHT-
; MOST BIT VALUED ONE. IF ALL BITS ARE ZERO, OUTPUTS 8
; INPUT    - D0.B THE BYTE
; OUTPUT   - D0.B THE BIT POSITION
; MODIFIES - NO REGISTER, ASIDE OF D0.B
; -----------------------------------------------------------------------------
            MOVEM.L D1,-(A7)
            CLR.W   D1

.LOOP          
            BTST.L  D1,D0                   ; TEST DEL BIT EN LA POSICIÓ 
                                            ; REFERENCIADA PER D1,
                                            ; EN SER TROVAT, SORTIREM I D1
                                            ; MOURÀ EL SEU VALOR A D0
            BNE     .OUT
            
            ADDQ.B  #1,D1 
            
            CMP.B    #8,D1                  ; EN ARRIBAR A LES 8 ITERACIONS
            BEQ     .OUT                    ; FORA HAVER TROVAT CAP BIT A 1,
                                            ; ACABAM I GUARDAM UN 8DEC A D0
            BRA     .LOOP
               
.OUT        MOVE.B  D1,D0
            
            MOVEM.L (A7)+,D1
            RTS





*~Font name~Courier New~
*~Font size~10~
*~Tab type~0~
*~Tab size~4~
