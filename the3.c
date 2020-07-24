/*
 * We have global flags, counters, ISRs, helper functions and a main while loop. In the ISR, we just handle the global flags, and 
 * do the actual job in the while loop. For example, when an interrupt is generated, we check the interrupt flags in the ISR, and
 * then set the corresponding global flag. After that, while checking the global flags in the main while loop, we handle the jobs
 * whose interrupt was generated. To solve the debouncing problem, we used Timer4 with 1/16 pre-scaler. The program waits for 10ms
 * after rb4 interrupt is generated, and then handle it. Additionaly, we put some comments on critical points to explain the code 
 * better.
 */

#pragma config OSC = HSPLL, FCMEN = OFF, IESO = OFF, PWRT = OFF, BOREN = OFF, WDT = OFF, MCLRE = ON, LPT1OSC = OFF, LVP = OFF, XINST = OFF, DEBUG = OFF

#include <xc.h>
#include "breakpoints.h"
    
// Variables
int readValue = 0;      //10 bit ad converter value stored here
int guessDigit = 0;     //the digit displayed on 7segment display
int dummy = 0;          //nothing
int buttonState = 0;    //rb4 button read value
int portionOfGame = 1;  //1 for gaming, 2 for blinking. then restart the game and make it 1

// Counters
int timer1Counter = 0; //when it is 10, 500ms has passed
int blinkCounter = 0; //when it becomes 4, the game should restart
int fiftyMsCounter = 0; //when it becomes 100, game should end and blinking starts FOR TIMER1
int tmr4Counter = 0;    //it counts up to 25 after rb4 interrupt. it measures 10ms then rb4 is handled

// Flags 
int fiftyMsPassedFlag = 0;  //set when 50ms passed by timer0
int R4PressedFlag = 0;      //set when r4 is pressed
int blinkFlag = 0;          //set for each 500ms passed in blinking period
int conversionEndFlag = 0;  //set when a conversion done
int gameOverFlag = 0;       //set when the game is over after 5 second passed
int debounceFlag = 0;       //to handle debouncing

void __interrupt(high_priority) my_isr() {
    if (PIR3bits.TMR4IF){
        if (tmr4Counter == 25){//timer4 interrupts for handling debounce problem of RB4
            tmr4Counter = 0;    //after rb is pressed, wait 10ms, and then handle the rb4
            
            if (dummy != buttonState){
                if (dummy){ //button is pressed
                    R4PressedFlag = 1;
                }
                buttonState = dummy;
            }
            
            debounceFlag = 0;
            T4CONbits.TMR4ON = 0;
            PIR3bits.TMR4IF = 0;
        }
        else {
            tmr4Counter++;
            TMR4 = 6;
            PIR3bits.TMR4IF = 0;
        }      
    }
    if (PIR1bits.TMR1IF){//interrupt at each 50ms
        if (portionOfGame == 1){//program is in guessing period
            TMR1H = 0x0B; TMR1L = 0xDC;
            fiftyMsCounter++;
            if (fiftyMsCounter == 100){
                fiftyMsCounter = 0;
                gameOverFlag = 1;
            }
        }
        else {//program is in blinking period
            timer1Counter++;
            TMR1H = 0x0B; TMR1L = 0xDC;

            if (timer1Counter == 10){
                blinkFlag = 1;
                timer1Counter = 0;
                blinkCounter++;
            }
        }
        
        
        PIR1bits.TMR1IF = 0;
    }
    if (INTCONbits.TMR0IF){//interrupt at each 50ms
        TMR0H = 0x85; TMR0L = 0xEE;
        fiftyMsPassedFlag = 1;
        
        INTCONbits.TMR0IF = 0;
    }
    if (PIR1bits.ADIF){//interrupt when the conversion is done
        conversionEndFlag = 1;
        PIR1bits.ADIF = 0;
    }
    if (INTCONbits.RBIF){//interrupt when the state of rb4 changes
        if (debounceFlag == 0){
            T4CONbits.TMR4ON = 1;
            TMR4 = 0x06;
            dummy = PORTBbits.RB4;
            debounceFlag = 1;
            Nop();
            INTCONbits.RBIF = 0;
        }
        else {
            dummy = PORTBbits.RB4;
            Nop();
            INTCONbits.RBIF = 0;
        }
        
    }
}

void findDigit(){//find the correct digit, according to read value from ad converter
    if      (readValue <= 102) { guessDigit = 0; }
    else if (readValue <= 204) { guessDigit = 1; }
    else if (readValue <= 306) { guessDigit = 2; }
    else if (readValue <= 408) { guessDigit = 3; }
    else if (readValue <= 510) { guessDigit = 4; }
    else if (readValue <= 612) { guessDigit = 5; }
    else if (readValue <= 714) { guessDigit = 6; }
    else if (readValue <= 816) { guessDigit = 7; }
    else if (readValue <= 918) { guessDigit = 8; }
    else                       { guessDigit = 9; }
}

void handleDisplay(int dig){//handle the 7segment display
    LATH = 0x08;
    if      (dig == 0) { LATJ = 0x3F; }
    else if (dig == 1) { LATJ = 0x06; }
    else if (dig == 2) { LATJ = 0x5B; }
    else if (dig == 3) { LATJ = 0x4F; }
    else if (dig == 4) { LATJ = 0x66; }
    else if (dig == 5) { LATJ = 0x6D; }
    else if (dig == 6) { LATJ = 0x7D; }
    else if (dig == 7) { LATJ = 0x07; }
    else if (dig == 8) { LATJ = 0x7F; }
    else               { LATJ = 0x6F; }
}


void init(void){
    TRISB = 0xFF; //makes RB pins input
    TRISH = 0x10; 
    TRISJ = 0;
    TRISC =  0; TRISD = 0; TRISE = 0;

    INTCON = 0x60; //gie,peie,tmr0,rb0,rb47. the rest three are flags:tmr0,rb0,rb47
    
    PIE1bits.TMR1IE = 1;
    PIE1bits.ADIE = 1;
    PIE3bits.TMR4IE = 1;
    
    T0CON = 0x03; //timer control registers
    T1CON = 0xF4;
    T4CON = 0x03;
    TMR1H = 0x0B; TMR1L = 0xDC; //initial values of timers
    TMR0H = 0x85; TMR0L = 0xEE;

    ADCON0 = 0x30; //channel 12
    ADCON1 = 0;    //all sources are analog
    ADCON2 = 0x82;
}

void startVariables(void){//run after init_complete breakpoint
    INTCONbits.GIE = 1;     //enables global interrupts
    T0CONbits.TMR0ON = 1;   //starts timer0
    T1CONbits.TMR1ON = 1;   //starts timer1
    INTCONbits.RBIE = 1;    //enables rb4-7 interrupts
    ADCON0bits.ADON = 1;    //enables ad converter module
}

void greaterPortCDE(void){//downside arrow
    LATC = 0x04;
    LATD = 0x0F;
    LATE = 0x04;
}

void lessPortCDE(void){//upside arrow
    LATC = 0x02;
    LATD = 0x0F;
    LATE = 0x02;
}

void clearPortCDE(void){
    LATC = 0;
    LATD = 0;
    LATE = 0;
}

void main(void) {
    init();
    init_complete();
    startVariables();

    
    while(1){
        if (portionOfGame == 1){//program is in the guessing period
            if (fiftyMsPassedFlag){
                fiftyMsPassedFlag = 0;
                ADCON0bits.GO = 1;
            }
            if (conversionEndFlag){
                conversionEndFlag = 0;
                readValue = ADRESH * 256;
                readValue+=ADRESL;
                adc_value = readValue;
                adc_complete();
                findDigit();
                handleDisplay(guessDigit);
                latjh_update_complete();
            }
            if (R4PressedFlag){
                R4PressedFlag = 0;
                
                //After handling bouncing,
                rb4_handled();
                

                if (guessDigit == special_number()){
                    TMR1H = 0x0B; TMR1L = 0xDC;
                    correct_guess();
                    portionOfGame = 2;
                    handleDisplay(guessDigit);
                    latjh_update_complete();
                    clearPortCDE();
                    latcde_update_complete();
                    //hs_passed();
                }
                else if (guessDigit > special_number()){//not correct, guess is greater
                    greaterPortCDE();
                    latcde_update_complete();
                }
                else {//not correct, guess is less
                    lessPortCDE();
                    latcde_update_complete();
                }
                
            }
            if (gameOverFlag){//5second has passed, start to blink
                gameOverFlag = 0;
                portionOfGame = 2;
                game_over();
                clearPortCDE();
                latcde_update_complete();
                handleDisplay(special_number());
                latjh_update_complete();
                //hs_passed();
            }
        }
        if (portionOfGame == 2) {//game is in the blinking period
            if (blinkFlag){
                blinkFlag = 0;
                if (blinkCounter == 4){//blink is enough, restart the game
                    hs_passed();
                    latjh_update_complete();
                    blinkCounter = 0;
                    portionOfGame = 1;
                    restart();
                }
                else {
                    hs_passed();
                    if      (blinkCounter == 1) { LATH = 0x08; LATJ = 0;             }
                    else if (blinkCounter == 2) { handleDisplay(special_number());   }
                    else if (blinkCounter == 3) { LATH = 0x08; LATJ = 0;             }
                    latjh_update_complete();
                }
            }
        }
    }
    
    
    return;
}
