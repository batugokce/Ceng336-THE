    LIST    P=18F8722

#include <p18f8722.inc>
    
    CONFIG OSC = HSPLL, FCMEN = OFF, IESO = OFF, PWRT = OFF, BOREN = OFF, WDT = OFF, MCLRE = ON, LPT1OSC = OFF, LVP = OFF, XINST = OFF, DEBUG = OFF

UDATA_ACS
  t1	res 1	; used in delay
  t2	res 1	; used in delay
  t3	res 1	; used in delay
  state res 1	; controlled by RB0 button
    
operation	udata 0X20
operation
b_counter	udata 0X21
b_counter
c_counter	udata 0X22
c_counter
resultt		udata 0X23
resultt

    ORG     0x00
    goto    main
    
init
    ;initializations
    movlw   h'00'
    movwf   operation
    
    movlw   b'11110000'
    movwf   TRISB
    movwf   TRISC
    
    movlw   b'00000000'
    movwf   TRISD
    movwf   b_counter
    movwf   c_counter
    
    movlw   b'11111111'
    movwf   TRISA
    movwf   TRISE
    
    clrf    b_counter
    clrf    c_counter
    
    return
    
firstsec
    movlw   b'00001111'
    movwf   LATB
    movwf   LATC
    
    movlw   b'11111111'
    movwf   LATD	    ;after 1 second must be turned off and wait for RA4
    
    call    delay
    
    movlw   b'00000000'
    movwf   LATB
    movwf   LATC
    movwf   LATD
    
    return
    
ra40:
    btfsc   PORTA,4
    goto    ra41
    goto    ra40
    
ra41:
    btfss   PORTA,4
    goto    ra42
    goto    ra41
    
ra42:
    bsf	    operation,0
    goto    chngop1
    
    
chngop1:
    btfss   PORTE,3	;check whether RE3 is pressed. if pressed go next step.
    goto    chngop2	;RE3 is not pressed. go and check RA4
    goto    chngport1	;operation is determined and RE3 is pressed now. goto next step
    
chngop2:
    btfsc   PORTA,4	;check RA4.
    goto    chngop3	;RA4 is pressed, go and wait for release
    goto    chngop1	;RA4 is not pressed, go back and check RE3
    
chngop3:
    btfss   PORTA,4
    goto    chngop4
    goto    chngop3
    
chngop4:
    btg	    operation,0	;RA4 is pressed and released, so change the operation
    goto    chngop1	;then go back to the beginning of the loop
    
chngport00:
    btfsc   PORTE,3
    goto    chngport1c	;when PORTB is selected, RE3 is pressed and released
    goto    chngport01
    
chngport01:
    btfsc   PORTA,4
    goto    chngport4	
    goto    chngport00
    
chngport1:
    btfss   PORTE,3	;check whether RE3 is still pressed
    goto    chngport2	;RE3 is released. go to the next step
    goto    chngport1	;RE3 is still pressed. go back to the loop
    
chngport2:		;RE3 is pressed and released once. selected port is PORTB
    btfss   PORTE,3
    goto    chngport3	;RE3 is not pressed. go and check RA4
    goto    chngport1c	;RE3 is pressed again. select the PORTC TODO
    
chngport3:
    btfss   PORTA,4
    goto    chngport2	;RA4 is not pressed. go back and check RE3
    goto    chngport4	;RA4 is pressed. go to the next step and wait for the release
 
chngport4:
    btfss   PORTA,4
    goto    chngport50
    goto    chngport4
    
chngport50:		;In PORTB, RA4 is pressed and released. increment it
    movlw   b'00000100'
    cpfseq  b_counter
    goto    chngport51
    goto    resetb
    
chngport51:
    movlw   b'00000000'
    cpfseq  b_counter
    goto    chngport6
    bsf	    LATB,0
    INCF    b_counter,F	;PORTB counter is incremented by 1
    goto    chngport00
    
chngport6:
    movlw   b'00000001'
    cpfseq  b_counter
    goto    chngport7
    bsf	    LATB,1
    INCF    b_counter,F	;PORTB counter is incremented by 1
    goto    chngport00
    
chngport7:
    movlw   b'00000010'
    cpfseq  b_counter
    goto    chngport8
    bsf	    LATB,2
    INCF    b_counter,F	;PORTB counter is incremented by 1
    goto    chngport00
    
chngport8:
    bsf	    LATB,3
    INCF    b_counter,F	;PORTB counter is incremented by 1
    goto    chngport00
    
    
;---------------------------------------------------------------------
;---------------------------------------------------------------------
    
    
chngport00c:
    btfsc   PORTE,3
    goto    result0	;when PORTC is selected, RE3 is pressed and released
    goto    chngport01c
    
chngport01c:
    btfsc   PORTA,4
    goto    chngport4c	
    goto    chngport00c
    
chngport1c:
    btfss   PORTE,3	;check whether RE3 is still pressed
    goto    chngport2c	;RE3 is released. go to the next step
    goto    chngport1c	;RE3 is still pressed. go back to the loop
    
chngport2c:		;RE3 is pressed and released twice. selected port is PORTC
    btfss   PORTE,3
    goto    chngport3c	;RE3 is not pressed. go and check RA4
    goto    result0	;RE3 is pressed again. select the PORTD TODO
    
chngport3c:
    btfss   PORTA,4
    goto    chngport2c	;RA4 is not pressed. go back and check RE3
    goto    chngport4c	;RA4 is pressed. go to the next step and wait for the release
 
chngport4c:
    btfss   PORTA,4
    goto    chngport50c
    goto    chngport4c
    
chngport50c:		;In PORTC, RA4 is pressed and released. increment it
    movlw   b'00000100'
    cpfseq  c_counter
    goto    chngport51c
    goto    resetc
    
chngport51c:
    movlw   b'00000000'
    cpfseq  c_counter
    goto    chngport6c
    bsf	    LATC,0
    INCF    c_counter,F	;PORTC counter is incremented by 1
    goto    chngport00c
    
chngport6c:
    movlw   b'00000001'
    cpfseq  c_counter
    goto    chngport7c
    bsf	    LATC,1
    INCF    c_counter,F	;PORTC counter is incremented by 1
    goto    chngport00c
    
chngport7c:
    movlw   b'00000010'
    cpfseq  c_counter
    goto    chngport8c
    bsf	    LATC,2
    INCF    c_counter,F	;PORTC counter is incremented by 1
    goto    chngport00c
    
chngport8c:
    bsf	    LATC,3
    INCF    c_counter,F	;PORTC counter is incremented by 1
    goto    chngport00c
    
    
;---------------------------------------------------------------------
;---------------------------------------------------------------------
    
result0:
    btfss   PORTE,3
    goto    result1
    goto    result0
    
result1:
    btfss   operation,0
    goto    result3
    goto    result2
    
result2:		;addition
    movlw   b'00000000'
    movf    b_counter,w
    addwf   c_counter,w
    goto    result6
    
result3:
    movf    b_counter,w
    cpfsgt  c_counter
    goto    result4	;b >= c
    goto    result5	;c >  b
    
result4:    ;b - c
    movf    c_counter,w
    subwf   b_counter,w
    goto    result6
    
result5:
    movf    b_counter,w
    subwf   c_counter,w
    goto    result6
    
result6:
    movwf   resultt
    movlw   b'00000000'
    cpfsgt  resultt
    goto    result14	;TODO
    decf    resultt,F
    bsf	    LATD,0
    goto    result7
    
result7:
    cpfsgt  resultt
    goto    result14	;TODO
    decf    resultt,F
    bsf	    LATD,1
    goto    result8
    
result8:
    cpfsgt  resultt
    goto    result14	;TODO
    decf    resultt,F
    bsf	    LATD,2
    goto    result9
    
result9:
    cpfsgt  resultt
    goto    result14	;TODO
    decf    resultt,F
    bsf	    LATD,3
    goto    result10
    
result10:
    cpfsgt  resultt
    goto    result14	;TODO
    decf    resultt,F
    bsf	    LATD,4
    goto    result11
    
result11:
    cpfsgt  resultt
    goto    result14	;TODO
    decf    resultt,F
    bsf	    LATD,5
    goto    result12
    
result12:
    cpfsgt  resultt
    goto    result14	;TODO
    decf    resultt,F
    bsf	    LATD,6
    goto    result13
    
result13:
    cpfsgt  resultt
    goto    result14	;TODO
    decf    resultt,F
    bsf	    LATD,7
    goto    result14
    
result14:
    call    delay
    movlw   b'00000000'
    movwf   LATD
    movwf   LATB
    movwf   LATC
    bsf	    operation,0
    clrf    b_counter
    clrf    c_counter
    clrf    resultt
    goto    ra40
    
    
    
;---------------------------------------------------------------------
;---------------------------------------------------------------------    

resetb:
    movlw   b'00000000'
    movwf   LATB
    movwf   b_counter
    goto    chngport00
    
resetc:
    movlw   b'00000000'
    movwf   LATC
    movwf   c_counter
    goto    chngport00c	;TODO
    
    
delay	; Time Delay Routine with 3 nested loops
    movlw   82	; Copy desired value to W
    movwf   t3	; Copy W into t3
_loop3:
    movlw   0xA0  ; Copy desired value to W
    movwf   t2    ; Copy W into t2
_loop2:
    movlw   0x9F	; Copy desired value to W
    movwf   t1	; Copy W into t1
_loop1:
    decfsz  t1,F ; Decrement t1. If 0 Skip next instruction
    goto    _loop1 ; ELSE Keep counting down
    decfsz  t2,F ; Decrement t2. If 0 Skip next instruction
    goto    _loop2 ; ELSE Keep counting down
    decfsz  t3,F ; Decrement t3. If 0 Skip next instruction
    goto    _loop3 ; ELSE Keep counting down
    return
    
main:
    call    init
    call    firstsec
    goto    ra40
loopx:
    btg	    operation,0
    call    delay
    goto    loopx
	
    end

