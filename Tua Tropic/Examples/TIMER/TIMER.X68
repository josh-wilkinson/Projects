*-----------------------------------------------------------
* Title      :  TIMER
* Written by :  Joshua Wilkinson
* Date       :  09/02/2022
* Description:  Sample Timer for the game I am working on
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program
    MOVE.B #1, D2
* Put program code here

GAME_LOOP:
    
    CLR.L D1
    
    MOVE.B D2, D1     # Sample message
    MOVE.B #3, D0      
    TRAP #15
    ADD #1, D2
    
    MOVE.B #8, D0       # Loads to since whenever 
    TRAP #15            # Into D1    
    
    MOVE.L D1, D4       # A copy of it for subtraction
    MOVE.L D1, D5       # A copy to reset D4 if it does'nt go back to GAME_LOOP        
    
    BRA TIME_LOOP



TIME_LOOP:

    MOVE.B #8, D0
    TRAP #15
    
    SUB D4, D1      
    
    CMP #100, D1    # 100 for every second
    BGT GAME_LOOP   # If 
    
    MOVE.L D5, D4   # Else reset to original value
    
    BRA TIME_LOOP   # Repeat the loop until true    



    SIMHALT             ; halt simulator

* Put variables and constants here
MESSAGE dc.b    'TIMER ',0      

    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
