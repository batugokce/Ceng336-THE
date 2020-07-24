      LIST    P=18F8722

#include <p18f8722.inc>
    
    CONFIG OSC = HSPLL, FCMEN = OFF, IESO = OFF, PWRT = OFF, BOREN = OFF, WDT = OFF, MCLRE = ON, LPT1OSC = OFF, LVP = OFF, XINST = OFF, DEBUG = OFF

    
tmpReg		udata 0X20 ;0 for middle shift, 1 for uctaki shift
tmpReg
tmrCounter	udata 0X21
tmrCounter
checkLoops	udata 0X22  ;it is 100 for level1, 80 for level2, 70 for level3
checkLoops
barPlace	udata 0X23
barPlace
f0		udata 0X24
f0
f1		udata 0X25
f1
f2		udata 0X26
f2
f3		udata 0X27
f3
f4		udata 0X28
f4
f5		udata 0X29
f5
randomH		udata 0X30
randomH
randomL		udata 0X31
randomL
storedRandomH		udata 0X32
storedRandomH
storedRandomL		udata 0X33
storedRandomL
health		udata 0x34
health
limitCtr		udata 0x35
limitCtr
ballCounter		udata 0x36
ballCounter
lvl1	udata 0x37
lvl1
lvl2	udata 0x38
lvl2
lvl3	udata 0x39
lvl3
finalCounter	udata 0x40
finalCounter
finalBool   udata 0x41
finalBool

		
		
    ORG     0x00
    goto    main
    
    ORG	    0x08
    goto    high_isr
    
    ORG	    0x18
    RETFIE
    
high_isr:
    bcf	    INTCON,1
    bcf	    INTCON,2
    movlw   b'00111101'	 ;initial value of tmr0 for 5ms
    movwf   TMR0
    INCF    tmrCounter,f ;increment at each 5ms
    movf    limitCtr,w		 ;add other levels
    cpfslt  tmrCounter	 ;skip if tmrCounter < 100
    call    handleBalls  
    RETFIE  FAST
    
finalCountdown
    clrf    tmrCounter
    INCF    finalCounter
    movlw   d'6'
    cpfslt  finalCounter
    call    makeHealthZero
    return
    
makeHealthZero
    movlw   d'0'
    movwf   health
    return
    
decreaseHP
    decf    health
    movlw   d'1'
    cpfslt  health
    call    makeHP1
    movlw   d'2'
    cpfslt  health
    call    makeHP2
    movlw   d'3'
    cpfslt  health
    call    makeHP3
    movlw   d'4'
    cpfslt  health
    call    makeHP4
    return

handleBalls
    btfsc   f0,0
    call    decreaseHP
    btfsc   f0,1
    call    decreaseHP
    btfsc   f0,2
    call    decreaseHP
    btfsc   f0,3
    call    decreaseHP
    clrf    f0
    btfsc   f1,0
    bsf	    f0,0
    btfsc   f1,1
    bsf	    f0,1
    btfsc   f1,2
    bsf	    f0,2
    btfsc   f1,3
    bsf	    f0,3
    btfsc   barPlace,0
    bcf	    f0,0
    btfsc   barPlace,1
    bcf	    f0,1
    btfsc   barPlace,2
    bcf	    f0,2
    btfsc   barPlace,3
    bcf	    f0,3
    clrf    f1
    btfsc   f2,0
    bsf	    f1,0
    btfsc   f2,1
    bsf	    f1,1
    btfsc   f2,2
    bsf	    f1,2
    btfsc   f2,3
    bsf	    f1,3
    clrf    f2
    btfsc   f3,0
    bsf	    f2,0
    btfsc   f3,1
    bsf	    f2,1
    btfsc   f3,2
    bsf	    f2,2
    btfsc   f3,3
    bsf	    f2,3
    clrf    f3
    btfsc   f4,0
    bsf	    f3,0
    btfsc   f4,1
    bsf	    f3,1
    btfsc   f4,2
    bsf	    f3,2
    btfsc   f4,3
    bsf	    f3,3
    clrf    f4
    btfsc   f5,0
    bsf	    f4,0
    btfsc   f5,1
    bsf	    f4,1
    btfsc   f5,2
    bsf	    f4,2
    btfsc   f5,3
    bsf	    f4,3
    clrf    f5
    movlw   d'29'
    cpfsgt  ballCounter
    call    createBalls
    call    handleLeds
    call    handleBarAndBalls
    btfsc   finalBool, 0
    call    finalCountdown 
    movlw   d'5'
    cpfslt  ballCounter
    call    makeLvl2   ;if more than 5 balls generated, 80 is moved to limitCtr
    movlw   d'15'
    cpfslt  ballCounter
    call    makeLvl3	;if more than 15 balls generated, 70 is moved to limitCtr
    movlw   d'30'
    cpfslt  ballCounter
    call    stopCreatingBalls   ;if 30 balls generated, wait for the last ball to drop
    movlw   d'100'
    cpfseq  limitCtr
    call    shiftLevel1
    movlw   d'80'
    cpfseq  limitCtr
    call    shiftLevel2
    movlw   d'70'
    cpfseq  limitCtr
    call    shiftLevel3
    return
    
    ;now we need to generate a new ball randomly at f5
createBalls
    btfss   randomL,0
    call    rndFnc1	  ;run if _0
    btfsc   randomL,0
    call    rndFnc2	  ;run if _1
    clrf    tmrCounter	 
    INCF    ballCounter
    return

makeHP1
    movlw   b'00001000'
    movwf   LATH
    movlw   b'00000110'
    movwf   LATJ
    movlw   b'00000000'
    movwf   LATH
    return
    
makeHP2
    movlw   b'00001000'
    movwf   LATH
    movlw   b'01011011'
    movwf   LATJ
    movlw   b'00000000'
    movwf   LATH
    return
    
makeHP3
    movlw   b'00001000'
    movwf   LATH
    movlw   b'01001111'
    movwf   LATJ
    movlw   b'00000000'
    movwf   LATH
    return
    
makeHP4
    movlw   b'00001000'
    movwf   LATH
    movlw   b'01100110'
    movwf   LATJ
    movlw   b'00000000'
    movwf   LATH
    return
    
makeHP5
    movlw   b'00001000'
    movwf   LATH
    movlw   b'01101101'
    movwf   LATJ
    movlw   b'00000000'
    movwf   LATH
    return
    
makeLvl1
    movlw   b'00000001'
    movwf   LATH
    movlw   b'00000110'
    movwf   LATJ
    movlw   b'00000000'
    movwf   LATH
    return
    
makeLvl2
    movlw   b'00000001'
    movwf   LATH
    movlw   b'01011011'
    movwf   LATJ
    movlw   b'00000000'
    movwf   LATH
    movff   lvl2,limitCtr
    return
    
makeLvl3
    movlw   b'00000001'
    movwf   LATH
    movlw   b'01001111'
    movwf   LATJ
    movlw   b'00000000'
    movwf   LATH
    movff   lvl3,limitCtr   
    return
    
stopCreatingBalls
    movlw b'11111111'
    movwf finalBool
    return
    
handleLeds
    movlw   b'00000000'
    movwf   LATA
    movwf   LATB
    movwf   LATC
    movwf   LATD
    btfsc   f5,0
    bsf	    LATD,0
    btfsc   f5,1
    bsf	    LATC,0
    btfsc   f5,2
    bsf	    LATB,0
    btfsc   f5,3
    bsf	    LATA,0
    
    btfsc   f4,0
    bsf	    LATD,1
    btfsc   f4,1
    bsf	    LATC,1
    btfsc   f4,2
    bsf	    LATB,1
    btfsc   f4,3
    bsf	    LATA,1
    
    btfsc   f3,0
    bsf	    LATD,2
    btfsc   f3,1
    bsf	    LATC,2
    btfsc   f3,2
    bsf	    LATB,2
    btfsc   f3,3
    bsf	    LATA,2
    
    btfsc   f2,0
    bsf	    LATD,3
    btfsc   f2,1
    bsf	    LATC,3
    btfsc   f2,2
    bsf	    LATB,3
    btfsc   f2,3
    bsf	    LATA,3
    
    btfsc   f1,0
    bsf	    LATD,4
    btfsc   f1,1
    bsf	    LATC,4
    btfsc   f1,2
    bsf	    LATB,4
    btfsc   f1,3
    bsf	    LATA,4
    return
    
rndFnc1  ; _0
    btfss   randomL,1	    
    bsf	    f5,3	  ;run if 00
    btfsc   randomL,1
    bsf	    f5,1	  ;run if 10
    return
    
rndFnc2  ; _1
    btfss   randomL,1	    
    bsf	    f5,2	  ;run if 01
    btfsc   randomL,1
    bsf	    f5,0	  ;run if 11
    return
    
init
    ;initializations
    clrf    tmrCounter
    clrf    f0
    clrf    f1
    clrf    f2
    clrf    f3
    clrf    f4
    clrf    f5
    clrf    PORTB
    clrf    randomH
    clrf    randomL
    clrf    storedRandomH
    clrf    storedRandomL
    clrf    tmpReg
    clrf    finalCounter
    clrf    finalBool
    clrf    LATH
    clrf    LATJ
    movlw   b'00001111'
    movwf   ADCON1
    movlw   b'00000000'
    movwf   finalCounter
    movlw   b'00000000'
    movwf   finalBool
    movlw   b'00000101'
    movwf   health
    movlw   d'100'
    movwf   lvl1
    movlw   d'80'
    movwf   lvl2
    movlw   d'70'
    movwf   lvl3
    movlw   b'00001100'
    movwf   barPlace
    movlw   b'00000000'
    movwf   TRISA
    movwf   TRISB
    movwf   TRISC
    movwf   TRISD
    movwf   TRISH
    movwf   TRISJ
    movwf   LATH
    movwf   LATJ
    movwf   ballCounter
    movlw   b'11111111'
    movwf   TRISG
    movlw   d'100'
    movwf   limitCtr
    call    makeLvl1
    call    makeHP5
    bcf	    RCON,7	;disable priorities
    
    return
    
handleBarAndBalls	;just for leds at floor0
    bcf	    LATD,5	    ;make floor leds OFF
    bcf	    LATC,5	    
    bcf	    LATB,5
    bcf	    LATA,5
    
    btfsc   barPlace,0	    ;make bar coord leds ON again
    bsf	    LATD,5
    btfsc   barPlace,1
    bsf	    LATC,5
    btfsc   barPlace,2
    bsf	    LATB,5
    btfsc   barPlace,3
    bsf	    LATA,5
    
    btfsc   barPlace,0	    ;if there is a ball in bar, remove ball
    bcf	    f0,0
    btfsc   barPlace,1
    bcf	    f0,1
    btfsc   barPlace,2
    bcf	    f0,2
    btfsc   barPlace,3
    bcf	    f0,3
    
    btfsc   f0,0	    ;make ball coord leds ON
    bsf	    LATD,5
    btfsc   f0,1
    bsf	    LATC,5
    btfsc   f0,2
    bsf	    LATB,5
    btfsc   f0,3
    bsf	    LATA,5
    
    return
    
startFunc
    movlw   b'10110000'	;enable tmr0, rb0 interrupts. last three are flags
    movwf   INTCON
    movlw   b'11000111' ;8bit,internal,rising edge,1:256 prescaler
    movwf   T0CON
    movlw   b'11000101'
    movwf   T1CON
    movlw   b'00111101'
    movwf   TMR0
    movlw   b'00000101'  ;CHANGE HEALTH TO 5 
    movwf   health
    movlw   d'100'
    movwf   checkLoops
    bsf	    INTCON,5
    return
    
    
endTheGame:
    clrf    f0
    clrf    f1
    clrf    f2
    clrf    f3
    clrf    f4
    clrf    f5
    movlw   b'00000000'
    movwf   LATA
    movwf   LATB
    movwf   LATC
    movwf   LATD
    movwf   ballCounter
    movlw   d'5'
    movwf   health
    movlw   b'00001100'
    movwf   barPlace
    bsf	    LATA,5
    bsf	    LATB,5
    bcf	    INTCON,5	;game is over, so disable tmr0 interrupts
    movlw   d'100'
    movwf   limitCtr
    call    makeLvl1
    goto    main
    
main:
    call    init
    call    handleBarAndBalls
    goto    isRG0Pressed
    
isRG0Pressed:
    btfsc   PORTG,0
    goto    isRG0Released
    goto    isRG0Pressed
    
isRG0Released:
    btfss   PORTG,0
    goto    startTheGame
    goto    isRG0Released
    
startTheGame:
    call    startFunc
    movff   TMR1L,randomL   ;tmr1 value is saved into a register, 16 bit
    movff   TMR1H,randomH
    call    handleBalls
    goto    isRG3Pressed
    
healthControl:
    movlw   d'0'
    cpfsgt  health
    goto    endTheGame ;health is zero, finish the game
    goto    isRG3Pressed ;health is greater, continue
    
isRG3Pressed: ;left
    btfsc   PORTG,3
    goto    isRG3Released
    goto    isRG2Pressed
    
isRG3Released:
    btfss   PORTG,3
    goto    goLeft
    goto    isRG3Released
    
isRG2Pressed:	;right
    btfsc   PORTG,2
    goto    isRG2Released
    goto    healthControl
    
isRG2Released:
    btfss   PORTG,2
    goto    goRight
    goto    isRG2Released
    
goLeft:
    btfsc   barPlace,0
    goto    goLeftLab2
    goto    goLeftLab1
    
goLeftLab1:
    call    barAtLeft
    call    handleBarAndBalls
    goto    isRG3Pressed
    
goLeftLab2:
    call    barAtMiddle
    call    handleBarAndBalls
    goto    isRG3Pressed
    
goRight:
    btfsc   barPlace,3
    goto    goRightLab2
    goto    goRightLab1
    
goRightLab1:
    call    barAtRight
    call    handleBarAndBalls
    goto    isRG3Pressed
    
goRightLab2:
    call    barAtMiddle
    call    handleBarAndBalls
    goto    isRG3Pressed
    
barAtLeft
    movlw   b'00001100'
    movwf   barPlace
    return
    
barAtMiddle
    movlw   b'00000110'
    movwf   barPlace
    return
    
barAtRight
    movlw   b'00000011'
    movwf   barPlace
    return
    
    
;THREE LABELS FOR SHIFTING TIMER1 VALUE MANUALLY, FOR EACH 3 LEVEL
shiftLevel1
    movff   randomH,storedRandomH
    movff   randomL,storedRandomL
    clrf    randomH
    clrf    randomL
    btfsc   storedRandomH,7
    bsf	    randomH,6
    btfsc   storedRandomH,6
    bsf	    randomH,5
    btfsc   storedRandomH,5
    bsf	    randomH,4
    btfsc   storedRandomH,4
    bsf	    randomH,3
    btfsc   storedRandomH,3
    bsf	    randomH,2
    btfsc   storedRandomH,2
    bsf	    randomH,1
    btfsc   storedRandomH,1
    bsf	    randomH,0
    btfsc   storedRandomH,0
    bsf	    randomL,7
    btfsc   storedRandomL,7
    bsf	    randomL,6
    btfsc   storedRandomL,6
    bsf	    randomL,5
    btfsc   storedRandomL,5
    bsf	    randomL,4
    btfsc   storedRandomL,4
    bsf	    randomL,3
    btfsc   storedRandomL,3
    bsf	    randomL,2
    btfsc   storedRandomL,2
    bsf	    randomL,1
    btfsc   storedRandomL,1
    bsf	    randomL,0
    btfsc   storedRandomL,0
    bsf	    randomH,7
    return
    
shiftLevel2 ;3 bit shift
    movff   randomH,storedRandomH
    movff   randomL,storedRandomL
    clrf    randomH
    clrf    randomL
    btfsc   storedRandomH,7
    bsf	    randomH,4
    btfsc   storedRandomH,6
    bsf	    randomH,3
    btfsc   storedRandomH,5
    bsf	    randomH,2
    btfsc   storedRandomH,4
    bsf	    randomH,1
    btfsc   storedRandomH,3
    bsf	    randomH,0
    btfsc   storedRandomH,2
    bsf	    randomL,7
    btfsc   storedRandomH,1
    bsf	    randomL,6
    btfsc   storedRandomH,0
    bsf	    randomL,5
    btfsc   storedRandomL,7
    bsf	    randomL,4
    btfsc   storedRandomL,6
    bsf	    randomL,3
    btfsc   storedRandomL,5
    bsf	    randomL,2
    btfsc   storedRandomL,4
    bsf	    randomL,1
    btfsc   storedRandomL,3
    bsf	    randomL,0
    btfsc   storedRandomL,2
    bsf	    randomH,7
    btfsc   storedRandomL,1
    bsf	    randomH,6
    btfsc   storedRandomL,0
    bsf	    randomH,5
    return
    
shiftLevel3 ;5 bit shift
    movff   randomH,storedRandomH
    movff   randomL,storedRandomL
    clrf    randomH
    clrf    randomL
    btfsc   storedRandomH,7
    bsf	    randomH,2
    btfsc   storedRandomH,6
    bsf	    randomH,1
    btfsc   storedRandomH,5
    bsf	    randomH,0
    btfsc   storedRandomH,4
    bsf	    randomL,7
    btfsc   storedRandomH,3
    bsf	    randomL,6
    btfsc   storedRandomH,2
    bsf	    randomL,5
    btfsc   storedRandomH,1
    bsf	    randomL,4
    btfsc   storedRandomH,0
    bsf	    randomL,3
    btfsc   storedRandomL,7
    bsf	    randomL,2
    btfsc   storedRandomL,6
    bsf	    randomL,1
    btfsc   storedRandomL,5
    bsf	    randomL,0
    btfsc   storedRandomL,4
    bsf	    randomH,7
    btfsc   storedRandomL,3
    bsf	    randomH,6
    btfsc   storedRandomL,2
    bsf	    randomH,5
    btfsc   storedRandomL,1
    bsf	    randomH,4
    btfsc   storedRandomL,0
    bsf	    randomH,3
    return   
    
    end



