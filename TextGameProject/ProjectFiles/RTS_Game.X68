*-----------------------------------------------------------
* Title      :  RTS Game
* Written by :  Joshua Wilkinson
* Date       :  09/02/2022
* Description:  Game project, small text based strategy game.
*-----------------------------------------------------------
    ORG    $0
START:                  ; first instruction of program, using it to store variables

* Variable declarations
    MOVE.L #50, $3000   # Base coins
    MOVE.L #1000, $3010 # Base trees
    MOVE.L #1, $3016    # Tree Carbon Reduction
    MOVE.L #1, $3050    # Trees planted
    MOVE.L #0, $3020    # Base Windmills
    MOVE.L #500, $3026  # Windmill Carbon Reduction
    MOVE.L #0, $3030    # Base Solar Panels
    MOVE.L #1000, $3036 # Solar Panel Carbon Reduction
    MOVE.L #0, $3040    # Base Markets
    
    MOVE.L #10, $3100   # Base Income
    MOVE.L #0, $3200    # Political Power
    MOVE.L #10, $3260    # P.P. increase
    
    MOVE.B #0, $3300    # Eco-Policy (1,2,3)
    MOVE.B #0, $3301    # Media Policy (1,2,3)
    MOVE.B #1, $3302    # PR Policy (1,2)
    
    MOVE.B #0, $3310    # Oil company popup event stage
    
    MOVE.L #1000000, $2000 # Base Carbon Particles
    


TITLE:              ; Title screen that appears for a couple of seconds
    BSR newLine
    BSR newLine
    BSR newLine
    
    BSR GRETEXT
    
    LEA TITLE_ASCII, A1
    BSR DISPLAY
    LEA TITLE2_ASCII, A1
    BSR DISPLAY
        
    BSR newLine
    BSR newLine
    BSR newLine
    
    MOVE.L #200,D1     ; delay in 1/100th of seconds
    MOVEQ #23,D0
    TRAP #15
    
    BSR ENTER

    BSR CLEAR    
    
    BRA INTRO    
    
INTRO:              ; Introduction the game and the rules    
    BSR GRETEXT
    LEA INTRO1, A1    
    BSR DISPLAY
    
    BSR WHITEXT
    LEA INTRO2, A1    
    BSR DISPLAY
    
    BSR GRETEXT
    LEA CITY_ASCII, A1
    BSR DISPLAY
    
    MOVE.L #200,D1     ; delay in 1/100th of seconds
    MOVEQ #23,D0
    TRAP #15
        
    BSR ENTER        
    BSR CLEAR
    
    BSR GRETEXT
    LEA RULES1, A1
    BSR DISPLAY
    
    
    
    BSR WHITEXT
    LEA RULES2, A1
    BSR DISPLAY
    
    MOVE.L #200,D1     ; delay in 1/100th of seconds
    MOVEQ #23,D0
    TRAP #15
    
    BSR ENTER    
    
    BSR CLEAR
    
    BRA INPUT       
    
INPUT:          ; First part of the game loop is the input options
    BSR CLEAR
    BSR GRETEXT
    LEA FRAME_ASCII, A1
    BSR DISPLAY
    BSR WHITEXT
    LEA OPTIONS, A1
    BSR DISPLAY
    BSR GRETEXT
    LEA FRAME_ASCII, A1
    BSR DISPLAY
    BSR WHITEXT
    
    MOVE.B #4, D0
    TRAP #15
    CMP #1, D1
    BEQ SHOP
    CMP #2, D1
    BEQ POLICY
    CMP #3, D1
    BEQ VIEW_WINNING_CONDITIONS
    CMP #88, D1
    BEQ GOOD_ENDING
    CMP #99, D1
    BEQ BAD_ENDING
        
    BRA CHECK_FOR_WIN
    
SHOP:           ; Player may choose the shop option and spend some coins
    BSR CLEAR
    
    BSR GRETEXT
    LEA SHOP1, A1
    BSR DISPLAY
    BSR WHITEXT
    
    LEA SHOP2, A1
    BSR DISPLAY
    
    BSR MONEY
    BSR STATS
    
    BSR newLine

    MOVE.B #4, D0
    TRAP #15
    
    CMP #1, D1  
    BEQ PLANT
    CMP #2, D1   
    BEQ UPGRADE_PLANTERS
    CMP #3, D1 
    BEQ BUILD_WINDMILL
    CMP #4, D1 
    BEQ UPGRADE_WINDMILLS
    CMP #5, D1 
    BEQ BUILD_PANEL
    CMP #6, D1 
    BEQ UPGRADE_PANELS
    CMP #7, D1 
    BEQ MARKET
    CMP #8, D1 
    BEQ ADVISORS
    

    BSR CLEAR
    BRA INPUT
    
POLICY:         ; Player may choose to spend P.P. (political power) for different modifiers
    BSR CLEAR
    
    BSR GRETEXT
    LEA PP1, A1
    BSR DISPLAY
    BSR WHITEXT
    
    LEA PP2, A1
    BSR DISPLAY
    
    LEA PP3, A1
    MOVE.B #14, D0
    TRAP #15
    MOVE.B #3, D0
    MOVE.L $3200, D1
    TRAP #15
    
    BSR newLine
    
    MOVE.B #4, D0
    TRAP #15
    
    CMP #1, D1
    BEQ ECO_MENU
    CMP #2, D1
    BEQ MEDIA_MENU
    CMP #3, D1
    BEQ PR_MENU
    CMP #4, D1
    BEQ OPTION4
    CMP #5, D1
    BEQ OPTION5
    
    BRA INPUT
    
GAME_LOOP:     
    
    MOVE.L D1, D4
    
    BSR CLEAR
    
    BSR GRETEXT
    LEA FRAME_ASCII, A1
    BSR DISPLAY
    BSR WHITEXT
    
    BSR UPDATE
    BSR CHECK_ECO
    BSR CHECK_MED
    BSR CHECK_PR
    
    BSR MONEY

    BSR STATS
    BSR newLine
    BSR GRETEXT
    LEA FRAME_ASCII, A1
    BSR DISPLAY
    BSR WHITEXT
    
        
    ; Gameplay/RNG popups go here (to be added)
    
    BSR newLine
    BSR TIME        # Subroutine that uses d4(for subtraction) & d5 to store time for TIME_LOOP
    BRA TIME_LOOP
    
TIME_LOOP:

    MOVE.B #8, D0   # Stores time since midnight again in d1
    TRAP #15
    
    SUB D4, D1      # The difference between previous and current times
    
    CMP #100, D1    # 100 for every second
    BGT RNG       # If 100 is greater D1 (when a second has passed), then branch to INPUT
    
    MOVE.L D5, D4   # Else reset to original value
    
    BRA TIME_LOOP   # Repeat the loop until true  

RNG:  ; For pop-up events 
    BSR GENERATE_RANDOM_NUMBER  # new random number between 1-100 in d1 (below are the chances of a different types of popup events occuring)
    CMP #5, D1
    BLT SPECIAL_EVENT
    CMP #15, D1
    BLT BAD_EVENT
    CMP #75, D1
    BGT GOOD_EVENT    
    
    BRA INPUT
    
GOOD_EVENT:
    BSR GENERATE_RANDOM_NUMBER
    CMP #20, D1
    BLT GREAT_HARVEST_SEASON
    CMP #40, D1
    BLT PEOPLE_SUPPORT_GOVERNMENT
    CMP #60, D1
    BLT GREAT_HARVEST_SEASON
    CMP #80, D1
    BLT PEOPLE_SUPPORT_GOVERNMENT
    CMP #100, D1
    BLT GREAT_HARVEST_SEASON
    
    BRA INPUT

BAD_EVENT:
    BSR GENERATE_RANDOM_NUMBER
    CMP #25, D1
    BLT PEOPLE_DONT_SUPPORT_GOVERNMENT
    CMP #75, D1
    BGT HURRICANE
    
    BRA INPUT

SPECIAL_EVENT:
    BSR GENERATE_RANDOM_NUMBER
    CMP #50, D1
    BLT OIL_COMPANY_BRANCH1
    CMP #100, D1
    BLT COAL_COMPANY_OFFER
    
    BRA INPUT
    
VIEW_WINNING_CONDITIONS:
    BSR CLEAR
    BSR GRETEXT
    LEA WIN_CONDITIONS1, A1
    BSR DISPLAY
    BSR WHITEXT
    LEA WIN_CONDITIONS2, A1
    BSR DISPLAY
    
    
    BSR ENTER
    BRA INPUT

YOU_WIN:
    BSR CLEAR
    LEA WIN_MSG, A1
    BSR DISPLAY
    
    BRA END
    
* ENDING STUFF    
    
GOOD_ENDING:
    BSR CLEAR
    LEA GOOD_ENDING_TEXT, A1
    BSR DISPLAY
    
    BSR GRETEXT
    LEA PEACE_ASCII, A1
    BSR DISPLAY
    BSR WHITEXT

    BRA END
    

    
CHECK_FOR_WIN:
    MOVE.L $2000, D3
    CMP.L #0, D3
    BEQ GOOD_ENDING_CHECK
    CMP.L #0, D3
    BLT GOOD_ENDING_CHECK
    CMP.L #1000000, D3
    BEQ BAD_ENDING_CHECK
    CMP.L #1000000, D3
    BGT BAD_ENDING_CHECK
    
    BRA GAME_LOOP
    
GOOD_ENDING_CHECK:
    CLR.L D3
    MOVE.L $3010, D3
    CMP.L #20000, D3
    BGE GOOD_ENDING
    
    BRA GAME_LOOP
    
BAD_ENDING_CHECK:
    CLR.L D3
    MOVE.L $3000, D3
    CMP.L #10000, D3
    BGE BAD_ENDING
    
    BRA GAME_LOOP
      
* Shop branches -----------------------------
      
PLANT:  
        MOVE.L $3000, D3        # This block of code checks if the player has enough coins
        CMP #10, D3             # The cost is 10 coins
        BLT NOT_ENOUGH_MONEY    # If true: branch to NOT_ENOUGH_MONEY, else: rest of code
       
        SUB #10, D3
        MOVE.L D3, $3000

        BSR CLEAR
        MOVE.L $3010, D4        # No. of Trees
        MOVE.L $3050, D5        # No. of Trees planted
        ADD.L D5, D4
        MOVE.L D4, $3010 
        
        BSR GRETEXT
        LEA TREE_ASCII, A1
        BSR DISPLAY
        BSR WHITEXT

        BSR ENTER
 
        BRA SHOP
        
UPGRADE_PLANTERS:               ; This Subroutine basically doubles the amount of trees that can be planted
        MOVE.L $3000, D3        # This block of code checks if the player has enough coins
        CMP #50, D3             # The cost is 50 coins
        BLT NOT_ENOUGH_MONEY    # If true: branch to NOT_ENOUGH_MONEY, else: rest of code
        
        SUB #50, D3
        MOVE.L D3, $3000
        
        BSR CLEAR
        MOVE.L $3050, D4        # No. of Trees planted
        MULU #2, D4             # Multiply by 2
        MOVE.L D4, $3050        # Loaded back in memory
        
        BSR ENTER
        
        BRA SHOP
        
BUILD_WINDMILL:
        MOVE.L $3000, D3        # This block of code checks if the player has enough coins
        CMP #100, D3            # The cost is 100 coins
        BLT NOT_ENOUGH_MONEY    # If true: branch to NOT_ENOUGH_MONEY, else: rest of code
       
        SUB #100, D3
        MOVE.L D3, $3000

        BSR CLEAR
        MOVE.L $3020, D4
        ADD #1, D4
        MOVE.L D4, $3020
        
        CLR.L D4                # Block of code for upkeep
        MOVE.L $3100, D4
        SUB.L #1, D4 
        MOVE.L D4, $3100
        
        BSR YELTEXT
        LEA WINDMILL2_ASCII, A1
        BSR DISPLAY
        BSR WHITEXT
        BSR newLine
        
        BSR ENTER
        
        BRA SHOP
        
UPGRADE_WINDMILLS:
        MOVE.L $3000, D3        # This block of code checks if the player has enough coins
        CMP #500, D3             # The cost is 500 coins
        BLT NOT_ENOUGH_MONEY    # If true: branch to NOT_ENOUGH_MONEY, else: rest of code
        
        SUB #500, D3
        MOVE.L D3, $3000
        
        BSR CLEAR
        MOVE.L $3026, D4
        ADD.L #500, D4
        MOVE.L D4, $3026   

        CLR.L D4                # Block of code for upkeep
        MOVE.L $3100, D4
        SUB.L #1, D4 
        MOVE.L D4, $3100     
        
        BSR ENTER
        
        BRA SHOP
        
BUILD_PANEL:
        MOVE.L $3000, D3        # This block of code checks if the player has enough coins
        CMP #300, D3            # The cost is 300 coins
        BLT NOT_ENOUGH_MONEY    # If true: branch to NOT_ENOUGH_MONEY, else: rest of code
       
        SUB #300, D3
        MOVE.L D3, $3000

        BSR CLEAR
        MOVE.L $3030, D4
        ADD #1, D4
        MOVE.L D4, $3030
        
        CLR.L D4                # Block of code for upkeep
        MOVE.L $3100, D4
        SUB.L #2, D4 
        MOVE.L D4, $3100
        
        BSR YELTEXT
        LEA SOLAR_PANEL_ASCII, A1
        BSR DISPLAY
        BSR WHITEXT
        
        BSR ENTER
        
        BRA SHOP
        
UPGRADE_PANELS:
        MOVE.L $3000, D3        # This block of code checks if the player has enough coins
        CMP #600, D3             # The cost is 600 coins
        BLT NOT_ENOUGH_MONEY    # If true: branch to NOT_ENOUGH_MONEY, else: rest of code
        
        SUB #600, D3
        MOVE.L D3, $3000
        
        BSR CLEAR
        MOVE.L $3036, D4
        ADD.L #1000, D4
        MOVE.L D4, $3036
        
        CLR.L D4                # Block of code for upkeep
        MOVE.L $3100, D4
        SUB.L #2, D4 
        MOVE.L D4, $3100
        
        BSR ENTER
        
        BRA SHOP
        
MARKET:
        MOVE.L $3000, D3        # This block of code checks if the player has enough coins
        CMP #100, D3            # The cost is 100 coins
        BLT NOT_ENOUGH_MONEY    # If true: branch to NOT_ENOUGH_MONEY, else: rest of code
        
        SUB #100, D3
        MOVE.L D3, $3000

        BSR CLEAR
        MOVE.L $3040, D4
        MOVE.L $3100, D5
        ADD #1, D4
        ADD #10, D5
        MOVE.L D4, $3040
        MOVE.L D5, $3100
        
        BSR ENTER
        
        BRA SHOP
        
ADVISORS:
        MOVE.L $3000, D3        # This block of code checks if the player has enough coins
        CMP #100, D3            # The cost is 100 coins
        BLT NOT_ENOUGH_MONEY    # If true: branch to NOT_ENOUGH_MONEY, else: rest of code

        SUB #100, D3
        MOVE.L D3, $3000

        BSR CLEAR
        MOVE.L $3260, D4
        ADD.L #5, D4
        MOVE.L D4, $3260
        
        BSR ENTER
        
        BRA SHOP
        
NOT_ENOUGH_MONEY:
        BSR CLEAR
        LEA NEC, A1
        BSR DISPLAY
        BSR MONEY        
        BSR ENTER
        BRA SHOP
        
NOT_ENOUGH_PP:
        BSR CLEAR
        LEA NEPP, A1
        BSR DISPLAY
        BSR ENTER
        BRA POLICY
        
ALREADY_SELECTED:
        BSR CLEAR
        LEA AS, A1
        BSR DISPLAY
        BSR ENTER
        BRA POLICY
        
    
* Policy Branches ----------------  

ECO_MENU:
        BSR CLEAR
        BSR GRETEXT
        LEA ECM1, A1
        BSR DISPLAY
        BSR WHITEXT
        LEA ECM2, A1
        MOVE.B #14, D0
        TRAP #15
        
        CLR.L D1
        MOVE.B $3300, D1
        MOVE.B #3, D0
        TRAP #15        
        
        BSR newLine
        
        MOVE.B #4, D0
        TRAP #15
    
        CMP #1, D1
        BEQ ECO1
        CMP #2, D1
        BEQ ECO2
        CMP #3, D1
        BEQ ECO3
        
        BRA POLICY
        
ECO1:
        CLR.L D3                # This block of code checks to see if the policy is already active 
        MOVE.B $3300, D3
        CMP #1, D3
        BEQ ALREADY_SELECTED

        MOVE.L $3200, D4        # This block of code checks if the player has enough P.P.
        CMP #500, D4            # The cost is 500 P.P.
        BLT NOT_ENOUGH_PP       # If true: branch to NOT_ENOUGH_PP, else: rest of code
        
        SUB #500, D4
        MOVE.L D4, $3200
        
        MOVE.B #1, $3300

        BSR CLEAR
        BSR ENTER
        BRA ECO_MENU
        
ECO2:
        CLR.L D3                # This block of code checks to see if the policy is already active 
        MOVE.B $3300, D3
        CMP #2, D3
        BEQ ALREADY_SELECTED

        MOVE.L $3200, D4        # This block of code checks if the player has enough P.P.
        CMP #200, D4            # The cost is 500 P.P.
        BLT NOT_ENOUGH_PP       # If true: branch to NOT_ENOUGH_PP, else: rest of code
        
        SUB #200, D4
        MOVE.L D4, $3200
        
        MOVE.B #2, $3300
        
        BSR CLEAR
        BSR ENTER
        BRA ECO_MENU
        
ECO3:
        CLR.L D3                # This block of code checks to see if the policy is already active 
        MOVE.B $3300, D3
        CMP #3, D3
        BEQ ALREADY_SELECTED

        MOVE.L $3200, D4        # This block of code checks if the player has enough P.P.
        CMP #100, D4            # The cost is 500 P.P.
        BLT NOT_ENOUGH_PP       # If true: branch to NOT_ENOUGH_PP, else: rest of code
        
        SUB #100, D4
        MOVE.L D4, $3200
        
        MOVE.B #3, $3300
        
        BSR CLEAR
        BSR ENTER
        BRA ECO_MENU
    
MEDIA_MENU:
        BSR CLEAR
        BSR GRETEXT
        LEA MEDIA1, A1
        BSR DISPLAY
        BSR WHITEXT
        LEA MEDIA2, A1
        MOVE.B #14, D0
        TRAP #15       
        
        CLR.L D1
        MOVE.B $3301, D1
        MOVE.B #3, D0
        TRAP #15
        
        BSR newLine
        
        MOVE.B #4, D0
        TRAP #15
    
        CMP #1, D1
        BEQ MED1
        CMP #2, D1
        BEQ MED2
        CMP #3, D1
        BEQ MED3
        
        BRA POLICY
        
MED1:
        CLR.L D3                # This block of code checks to see if the policy is already active 
        MOVE.B $3301, D3
        CMP #1, D3
        BEQ ALREADY_SELECTED

        MOVE.L $3200, D4        # This block of code checks if the player has enough P.P.
        CMP #200, D4            # The cost is 500 P.P.
        BLT NOT_ENOUGH_PP       # If true: branch to NOT_ENOUGH_PP, else: rest of code
        
        SUB #200, D4
        MOVE.L D4, $3200
        
        MOVE.B #1, $3301
        
        BSR CLEAR
        BSR ENTER
        BRA MEDIA_MENU
        
MED2:
        CLR.L D3                # This block of code checks to see if the policy is already active 
        MOVE.B $3301, D3
        CMP #2, D3
        BEQ ALREADY_SELECTED

        MOVE.L $3200, D4        # This block of code checks if the player has enough P.P.
        CMP #200, D4            # The cost is 500 P.P.
        BLT NOT_ENOUGH_PP       # If true: branch to NOT_ENOUGH_PP, else: rest of code
        
        SUB #200, D4
        MOVE.L D4, $3200
        
        MOVE.B #2, $3301
        
        BSR CLEAR
        BSR ENTER
        BRA MEDIA_MENU
        
MED3:
        CLR.L D3                # This block of code checks to see if the policy is already active 
        MOVE.B $3301, D3
        CMP #3, D3
        BEQ ALREADY_SELECTED

        MOVE.L $3200, D4        # This block of code checks if the player has enough P.P.
        CMP #100, D4            # The cost is 500 P.P.
        BLT NOT_ENOUGH_PP       # If true: branch to NOT_ENOUGH_PP, else: rest of code
        
        SUB #100, D4
        MOVE.L D4, $3200
        
        MOVE.B #3, $3301
        
        BSR CLEAR
        BSR ENTER
        BRA MEDIA_MENU
        

PR_MENU:
        BSR CLEAR
        BSR GRETEXT
        LEA PRM1, A1
        BSR DISPLAY
        BSR WHITEXT
        LEA PRM2, A1
        MOVE.B #14, D0
        TRAP #15
        
        CLR.L D1
        MOVE.B $3302, D1
        MOVE.B #3, D0
        TRAP #15
        
        BSR newLine
        
        MOVE.B #4, D0
        TRAP #15
    
        CMP #1, D1
        BEQ PR1
        CMP #2, D1
        BEQ PR2
        
        BRA POLICY
        
PR1:
        CLR.L D3                # This block of code checks to see if the policy is already active 
        MOVE.B $3302, D3
        CMP #1, D3
        BEQ ALREADY_SELECTED
        
        MOVE.L $3200, D4        # This block of code checks if the player has enough P.P.
        CMP #100, D4            # The cost is 100 P.P.
        BLT NOT_ENOUGH_PP       # If true: branch to NOT_ENOUGH_PP, else: rest of code
        
        SUB #100, D4
        MOVE.L D4, $3200
        
        MOVE.B #1, $3302
        
        BSR CLEAR
        BSR ENTER
        BRA PR_MENU
        
PR2:
        CLR.L D3                # This block of code checks to see if the policy is already active 
        MOVE.B $3302, D3
        CMP #2, D3
        BEQ ALREADY_SELECTED

        MOVE.L $3200, D4        # This block of code checks if the player has enough P.P.
        CMP #200, D4            # The cost is 200 P.P.
        BLT NOT_ENOUGH_PP       # If true: branch to NOT_ENOUGH_PP, else: rest of code
        
        SUB #200, D4
        MOVE.L D3, $3200
        
        MOVE.B #2, $3302
        
        BSR CLEAR
        BSR ENTER
        BRA PR_MENU

OPTION4:
        BSR ENTER
        BRA POLICY

OPTION5:
        BSR ENTER
        BRA POLICY

* Pop-up event branches ----------

HURRICANE:
        MOVE.L $3010, D4    # Cancels this event if trees are less than 500 since you cant have minus trees
        CMP.L #500, D4
        BLT INPUT

        BSR CLEAR
        BSR GRETEXT
        LEA POPUP1, A1
        BSR DISPLAY
        BSR WHITEXT
        LEA HURRIC, A1
        BSR DISPLAY
        
        SUB.L #500, D4
        MOVE.L D4, $3010
        
        BSR ENTER

        BRA INPUT
        
GREAT_HARVEST_SEASON:
        BSR CLEAR
        BSR GRETEXT
        LEA POPUP1, A1
        BSR DISPLAY
        BSR WHITEXT
        LEA HARVES, A1
        BSR DISPLAY
        
        MOVE.L $3000, D4
        ADD.L #100, D4
        MOVE.L D4, $3000
        
        BSR ENTER

        BRA INPUT
        
PEOPLE_SUPPORT_GOVERNMENT:
        BSR CLEAR
        BSR GRETEXT
        LEA POPUP1, A1
        BSR DISPLAY
        BSR WHITEXT
        LEA SUPPOR, A1
        BSR DISPLAY
        
        MOVE.L $3200, D4
        ADD.L #100, D4
        MOVE.L D4, $3200
        
        BSR ENTER

        BRA INPUT
        
PEOPLE_DONT_SUPPORT_GOVERNMENT:
        MOVE.L $3200, D4    # Cancels this event if PP is below 100 to avoid issues
        CMP.L #100, D4
        BLT INPUT 

        BSR CLEAR
        BSR GRETEXT
        LEA POPUP1, A1
        BSR DISPLAY
        BSR WHITEXT
        LEA NOSUPP, A1
        BSR DISPLAY
        
        SUB.L #100, D4
        MOVE.L D4, $3200
        
        BSR ENTER

        BRA INPUT
        
OIL_COMPANY_BRANCH1:
        BSR CLEAR
        CLR.L D1
        LEA BIGOIL1, A1
        BSR DISPLAY
        
        BSR YELTEXT
        LEA OIL_MAN_ASCII, A1
        BSR DISPLAY
        BSR WHITEXT
        
        MOVE.B #4, D0
        TRAP #15
        CMP #1, D1
        BEQ ACCEPT1
        CMP #2, D1
        BEQ OIL_COMPANY_BRANCH2
        
        BRA OIL_COMPANY_BRANCH1
        
OIL_COMPANY_BRANCH2:
        BSR CLEAR
        CLR.L D1
        LEA BIGOIL2, A1
        BSR DISPLAY
        
        BSR YELTEXT
        LEA OIL_MAN2_ASCII, A1
        BSR DISPLAY
        BSR WHITEXT
        
        MOVE.B #4, D0
        TRAP #15
        CMP #1, D1
        BEQ ACCEPT2
        CMP #2, D1
        BEQ REFUSE
        
        BSR newLine
        
        BRA OIL_COMPANY_BRANCH2
        
COAL_COMPANY_OFFER:
        CLR.L D1
        LEA BIGCOAL, A1
        BSR DISPLAY
        
        BSR YELTEXT
        LEA OIL_MAN_ASCII, A1
        BSR DISPLAY
        BSR WHITEXT
        
        MOVE.B #4, D0
        TRAP #15
        CMP #1, D1
        BEQ ACCEPT3
        CMP #2, D1
        BEQ INPUT
        
        BRA COAL_COMPANY_OFFER

ACCEPT1:
        CLR.L D4
        MOVE.L $3000, D4    # Coins
        MOVE.L $2000, D5    # Carbon
        ADD.L #500, D4
        ADD.L #10000, D5
        MOVE.L D4, $3000
        MOVE.L D5, $2000
        BRA INPUT    

ACCEPT2:
        CLR.L D4
        MOVE.L $3000, D4    # Coins
        MOVE.L $2000, D5    # Carbon
        ADD.L #1000, D4
        ADD.L #10000, D5
        MOVE.L D4, $3000
        MOVE.L D5, $2000
        BRA INPUT  
        
ACCEPT3:
        CLR.L D4
        CLR.L D5
        MOVE.L $3000, D4
        MOVE.L $2000, D5
        ADD.L #2000, D4
        ADD.L #20000, D5
        MOVE.L D4, $3000
        MOVE.L D5, $2000
        BRA INPUT

REFUSE:
        CLR.L D4
        MOVE.L $3200, D4    # PP
        ADD.L #100, D4
        MOVE.L D4, $3200
        BRA INPUT  
                    
    
* Subroutines --------------------
    
DISPLAY MOVE.B #14, D0
        TRAP #15
        BSR newLine
        RTS
        
newLine MOVE.B #14, D0
        LEA	crlf,A1
	    TRAP #15
        RTS
        
ENTER   BSR REDTEXT         # Block of code for displaying continue message
        LEA CONTINUE, A1
        MOVE.B #14, D0
        TRAP #15

        BSR WHITEXT         # Block of code for taking input
        MOVE.B #4, D0
        TRAP #15
	    RTS             
	    
CLEAR   MOVE.W #$FF00, D1
        MOVEQ #11, D0
        TRAP #15
        RTS
        
TIME    MOVE.B #8, D0       # Loads time since whenever 
        TRAP #15            # Into D1    
    
        MOVE.L D1, D4       # A copy of it for subtraction
        MOVE.L D1, D5       # A copy to reset D4 if it does not go back to GAME_LOOP           
        RTS
        
UPDATE  MOVE.L $3000, D4    # No. of coins
        MOVE.L $3100, D5    # Income
        ADD D5, D4
        MOVE.L D4, $3000    # Coins updated
        
        MOVE.L $3200, D4    # P.P.
        MOVE.L $3260, D5    # P.P. increase
        ADD.L D5, D4
        MOVE.L D4, $3200
        
        CLR D3
        CLR D4
        CLR D5
        
        MOVE.L $2000, D3    # C.P. (below are the calculations for reducing carbon) >
        
        MOVE.L $3010, D4    # No. of Trees
        MOVE.L $3016, D5    # Tree carbon reduction
        MULU D4, D5         # No. of Trees * Tree carbon reduction 
        SUB.L D5, D3        # Carbon particles - D5
        
        MOVE.L $3020, D4    # No. of Windmills
        MOVE.L $3026, D5    # Windmill carbon reduction
        MULU D4, D5         # No. of Windmills * Windmill carbon reduction
        SUB.L D5, D3        # Carbon particles - D5
        
        MOVE.L $3030, D4    # No. of Solar Panel Farms
        MOVE.L $3036, D5    # Solar Panel Farm carbon reduction
        MULU D4, D5         # No. of panels * panel carbon reduction
        SUB.L D5, D3        # Carbon particles - D5
        
        MOVE.L D3, $2000    # Carbon Particles Calculations done                    <
        
                
        RTS

MONEY   LEA COINS, A1       # This block of code displays the current amount of money the player has
        MOVE.B #14, D0
        TRAP #15
        BSR YELTEXT
        MOVE.L $3000, D1
        MOVE.B #3, D0
        TRAP #15
        BSR WHITEXT
        BSR newLine
        RTS
        
STATS   LEA CP, A1      
        MOVE.B #14, D0
        TRAP #15
        
        MOVE.L $2000, D1
        MOVE.B #3, D0
        TRAP #15
        
        CLR.L D1
        BSR newLine    
        
        LEA TREES, A1
        MOVE.B #14, D0
        TRAP #15
        
        BSR GRETEXT
        MOVE.L $3010, D1
        MOVE.B #3, D0
        TRAP #15
        BSR WHITEXT
        
        CLR.L D1
        BSR newLine
        
        LEA MILLS, A1
        MOVE.B #14, D0
        TRAP #15
        
        MOVE.L $3020, D1
        MOVE.B #3, D0
        TRAP #15
        
        CLR.L D1
        BSR newLine
        
        LEA PANEL, A1
        MOVE.B #14, D0
        TRAP #15
        
        MOVE.L $3030, D1
        MOVE.B #3, D0
        TRAP #15
        
        CLR.L D1
        BSR newLine
        
        LEA MARKT, A1
        MOVE.B #14, D0
        TRAP #15
        
        BSR YELTEXT
        MOVE.L $3040, D1
        MOVE.B #3, D0
        TRAP #15
        BSR WHITEXT
        
        CLR.L D1
        
        RTS
        
GENERATE_RANDOM_NUMBER     
    MOVE.B #8, D0 #Loads D1 with Time in 100's of Seconds since midnight (6 Bits)

    TRAP #15  #Place time in D1

    AND.L #$5FFFFF, D1 # AND 6 Bits to prevent any overflow

    DIVU #100, D1 #Divide by 100, 1000, 10000 depending on Number range required

    SWAP D1 #SWAP Higher Order Word and Lower Order Word in D1

    ADDQ.W #1, D1 #Add 1 to D1.W so number is at least 1

    MOVE.W D1, D2 #Extract the number from D1.W

    CLR.L D1 # Clear contents of D1

    MOVE.W D2, D1 #Move the generated number to D1
    
    RTS      

   
        
*   Subroutines for Policies

CHECK_ECO
        CLR.L D3
        MOVE.B $3300, D3
        CMP #1, D3
        BEQ ZERO_EMISSIONS
        CMP #2, D3
        BEQ ENERGY_EFFICIENT
        CMP #3, D3
        BEQ ECONOMY_FIRST
        
        RTS
        
CHECK_MED
        CLR.L D3
        MOVE.B $3301, D3
        CMP #1, D3
        BEQ STATE_MEDIA
        CMP #2, D3
        BEQ UNBIASED_MEDIA
        CMP #3, D3
        BEQ SPONSERED_MEDIA
        
        RTS
        
CHECK_PR
        CLR.L D3
        MOVE.B $3302, D3
        CMP #1, D3
        BEQ OPEN_SOCIETY
        CMP #2, D3
        BEQ TOTAL_SURVEILLANCE
        
        RTS

ZERO_EMISSIONS
        MOVE.L $3000, D3
        MOVE.L $3200, D4        
        
        RTS
        
ENERGY_EFFICIENT
        MOVE.L $3000, D3
        MOVE.L $2000, D4
        
        ADD.L #5, D3
        ADD.L #200, D4
        
        MOVE.L D3, $3000
        MOVE.L D4, $2000

        RTS
        
ECONOMY_FIRST
        MOVE.L $3000, D3
        MOVE.L $2000, D4
        
        ADD.L #20, D3
        ADD.L #1000, D4
        
        MOVE.L D3, $3000
        MOVE.L D4, $2000

        RTS
        
STATE_MEDIA
        MOVE.L $3200, D3
        
        ADD.L #20, D3
        
        MOVE.L D3, $3200
        
        RTS

UNBIASED_MEDIA
        MOVE.L $3000, D3
        
        ADD.L #20, D3
        
        MOVE.L D3, $3000
        
        RTS

SPONSERED_MEDIA
        MOVE.L $3000, D3
        MOVE.L $3200, D4
        
        ADD.L #5, D3
        ADD.L #5, D4
        
        MOVE.L D3, $3000
        MOVE.L D4, $3200
        
        RTS

OPEN_SOCIETY
        RTS

TOTAL_SURVEILLANCE
        MOVE.L $3200, D4
        MOVE.L $3000, D5
        
        ADD.L #20, D4
        SUB.L #20, D5
        
        MOVE.L D4, $3200
        MOVE.L D5, $3000
        
        RTS
        
*   Subroutines for text style (colours and fonts).
        
REDTEXT	MOVE.L	#RED,D1
	    MOVE.L	#FONT,D2
	    MOVE.B	#21,D0
	    TRAP	#15
	    RTS
	    
WHITEXT	MOVE.L	#WHITE,D1
	    MOVE.L	#FONT,D2
	    MOVE.B	#21,D0
	    TRAP	#15
	    RTS
	    
YELTEXT	MOVE.L	#YELLOW,D1
	    MOVE.L	#FONT,D2
	    MOVE.B	#21,D0
	    TRAP	#15
	    RTS
	    
GRETEXT	MOVE.L	#GREEN,D1
	    MOVE.L	#FONT,D2
	    MOVE.B	#21,D0
	    TRAP	#15
	    RTS
	    
*   Subroutines for ascii art.
WINDMILL
        BSR YELTEXT
    
        LEA WINDMILL_ASCII, A1
        BSR DISPLAY
        
        BSR WHITEXT
        RTS

    
    SIMHALT             ; halt simulator

* Put variables and constants here

crlf	DC.B	$d,$a,0

* Font Stuff ---------------------
RED	    EQU	    $000000FF
WHITE	EQU	    $00FFFFFF
YELLOW  EQU     $0000FFFF
GREEN   EQU     $0000FF00
FONT	EQU	    $01090000 

* Messages -----------------------
CONTINUE DC.B   'Please type anything to continue....',$d,$a,0
SAMPLE  DC.B    ' sample ',0
NEC     DC.B    'You do not have enough coins!!',$d,$a,0
NEPP    DC.B    'You do not have enough Political Power!!',$d,$a,0
AS      DC.B    'This option is already active!!',$d,$a,0
WIN_MSG DC.B    'CONGRATULATIONS, YOU WIN!!!',0
LOSE    DC.B    'YOU RUINED THE ECONOMY AND GOT VOTED OUT, GAME OVER',0

* Title Screen -------------------
WELCOME_MSG:    DC.B    '                      _                             _',$d,$a
                DC.B    '                     ( )                           ( )',$d,$a
                DC.B    '                    (_X_)   Welcome to my game!   (_X_)',$d,$a
                DC.B    '                      j                             j',$d,$a
                DC.B    '*****************************************************************************************',0

* Introduction -------------------
INTRO1: DC.B    '---------------------------------Introduction---------------------------------',$d,$a,0

INTRO2: DC.B    'You are the leader of the newly independant island of Tua.',$d,$a
        DC.B    'While that is great and all, you have seemed to inherited quite the problem!',$d,$a
        DC.B    'Climate change has really had a noticable effect on the island.',$d,$a
        DC.B    'For instance, only 20% of the jungle is left, previously it was 75%!',$d,$a
        DC.B    'Our sunny island also does not produce clean energy!',$d,$a
        DC.B    'This has led to too much carbon particles in the air.',$d,$a
        DC.B    'Luckily, you are in charge of solving the problem. Good luck!',$d,$a,0
        


* Game Rules ---------------------
RULES1: DC.B    '-----------------------------------Rules--------------------------------------',$d,$a,0

RULES2: DC.B    '1. Reduce the carbon count by building renewable energy and planting trees.',$d,$a
        DC.B    '2. Spend PP (political power) to change government policy.',$d,$a
        DC.B    '3. Make decisions during popup events.',$d,$a
        DC.B    '4. Do not fall into debt.',$d,$a
        DC.B    '5. Have fun playing this game.',$d,$a,0
        
* Win conditions -----------------
WIN_CONDITIONS1:
        DC.B    '-----------------------------Win conditions-----------------------------',$d,$a,0
WIN_CONDITIONS2:
        DC.B    'You can win the game one of 2 ways:',$d,$a
        DC.B    '1. Plant 20,000 trees and reduce the Carbon Particle count to below 0.',$d,$a
        DC.B    '2. Exploit the country, make 10,000 coins & have carbon count above 1,000,000',$d,$a,0

* Game Loop Stuff ----------------
OPTIONS DC.B    '1. Go to Shop',$d,$a
        DC.B    '2. Implement new Policy',$d,$a
        DC.B    '3. View the winning conditions',$d,$a
        DC.B    $d,$a
        DC.B    'Press ENTER to go through the loop',$d,$a,0


* Shop Items ---------------------
SHOP1:  DC.B    '-----------------------------Buy and Upgrade----------------------------',$d,$a,0
        
SHOP2:  DC.B    '1. Plant Trees                     (10 coins)',$d,$a
        DC.B    '2. Upgrade Tree Planter            (50 coins)',$d,$a
        DC.B    '3. Buy Windmill                    (100 coins, upkeep -1)',$d,$a
        DC.B    '4. Upgrade Windmills               (500 coins, upkeep -1)',$d,$a
        DC.B    '5. Buy Solar Panel Farm            (300 coins, upkeep -2)',$d,$a
        DC.B    '6. Upgrade Solar Panels            (600 coins, upkeep -2)',$d,$a
        DC.B    '7. Build Market                    (100 coins, income +10)',$d,$a
        DC.B    '8. Hire Advisors                   (100 coins, P.P.   +5)',$d,$a
        DC.B    $d,$a
        DC.B    '9. Back',$d,$a,0
        
* P.P. Choices -------------------
PP1:    DC.B    '-----------------------------Political Power----------------------------',$d,$a,0
PP2:    DC.B    '1. Ecology Menu',$d,$a
        DC.B    '2. Media Menu',$d,$a
        DC.B    '3. Person Rights Menu',$d,$a,0
PP3:    DC.B    'Political Power Points: ',0

ECM1:   DC.B    '-----------------------------Ecology Menu-------------------------------',$d,$a,0
ECM2:   DC.B    '1. Zero Emissions                  (500 PP, income +0, CP +0)',$d,$a
        DC.B    '2. Energy Efficient                (200 PP, income +5, CP +200)',$d,$a
        DC.B    '3. Economy First                   (100 PP, income +20, CP +1000)',$d,$a
        DC.B    $d,$a
        DC.B    'Currently Active: ',0
        
MEDIA1: DC.B    '-----------------------------Media Menu---------------------------------',$d,$a,0
MEDIA2: DC.B    '1. State Controlled Media          (200 PP, PP +20)',$d,$a
        DC.B    '2. Unbiased Independant Media      (200 PP, Income +20)',$d,$a
        DC.B    '3. Sponsered Media                 (100 PP, PP +5, Income +5)',$d,$a
        DC.B    $d,$a
        DC.B    'Currently Active: ',0

PRM1:   DC.B    '-------------------------Personal Rights Menu---------------------------',$d,$a,0
PRM2:   DC.B    '1. Open Society		(100 PP)',$d,$a
        DC.B    '2. Total Surveillance	(200 PP, PP +20, Income -20)',$d,$a
        DC.B    $d,$a
        DC.B    'Currently Active: ',0       

* Game Loop stuff ----------------
COINS:  DC.B    'Coins: ',0
TREES:  DC.B    'Trees: ',0
MARKT:  DC.B    'Markets: ',0
CP:     DC.B    'Carbon Particals Remaining: ',0
MILLS:  DC.B    'Windmills: ',0
PANEL:  DC.B    'Solar Panel Farms: ',0
CR:     DC.B    'Carbon Reduction: ',0

* Pop-up event messages ----------
POPUP1  DC.B    '-----------------------------Pop-up Event-------------------------------',$d,$a,0

HURRIC  DC.B    'Oh no!!! A hurricane has hit the island!   (-500 Trees)',$d,$a,0

HARVES  DC.B    'Great news! There has been a good harvest season!  (+100 coins)',$d,$a,0

SUPPOR  DC.B    'Great news! The people of Tua support your government!     (+100 PP)',$d,$a,0
NOSUPP  DC.B    'Bad news! Many of the people of Tua protest your government!   (-100 PP)',$d,$a,0

BIGOIL1 DC.B    'A big offer has come in from BIG OIL co. , +500 coins!',$d,$a
        DC.B    '1. Accept      (+500 Coins, +10000 Carbon Particles)',$d,$a
        DC.B    '2. Decline',$d,$a,0
        
BIGOIL2 DC.B    'Another big offer has come in from BIG OIL co. , +1000 coins!',$d,$a
        DC.B    'They must think that we are trying to negotiate a better deal...',$d,$a
        DC.B    '1. Accept      (+1000 Coins, +10000 Carbon Particles)',$d,$a
        DC.B    '2. Decline, and tell your staff not to return their calls...     (+100 PP)',$d,$a,0
        
BIGCOAL DC.B    'A big offer has come in from BIG COAL co. , 2000 coins!',$d,$a
        DC.B    'They want to set up 10 coal power plants in Tua.',$d,$a
        DC.B    '1. Accept      (+2000 Coins, +20000 Carbon Particles)',$d,$a
        DC.B    '2. Decline     (+200 PP)',$d,$a,0

* Ending text --------------------

GOOD_ENDING_TEXT:
        DC.B    'CONGRATULATIONS, YOU WIN!!!',$d,$a
        DC.B    $d,$a
        DC.B    'Your government took urgent actions to combat climate change!!',$d,$a
        DC.B    'However, there is still work to be done throughout the rest of the world,',$d,$a
        DC.B    'after all, Tua island is only a small part of this planet...',$d,$a
        DC.B    $d,$a
        DC.B    'SDG13 Link:    https://sdgs.un.org/goals/goal13',$d,$a,0
        
BAD_ENDING_TEXT:
        DC.B    'CONGRATULATIONS, YOU WIN??',$d,$a
        DC.B    'You have won, but at what cost? The people of Tua will soon notice that the sea',$d,$a
        DC.B    'is rising, wild life is inexistant & smog ruins the air.',$d,$a
        DC.B    'SDG13 Link:    https://sdgs.un.org/goals/goal13',$d,$a,0



* ASCII Objects ------------------

TITLE_ASCII:
        DC.B	'        _________  ___  ___  ________                  ',$d,$a
        DC.B	'       |\___   ___\\  \|\  \|\   __  \                 ',$d,$a
        DC.B	'       \|___ \  \_\ \  \\\  \ \  \|\  \         _      ',$d,$a
        DC.B	'            \ \  \ \ \  \\\  \ \   __  \       ( )     ',$d,$a
        DC.B	'             \ \  \ \ \  \\\  \ \  \ \  \     (_X_)    ',$d,$a
        DC.B	'              \ \__\ \ \_______\ \__\ \__\      j      ',$d,$a
        DC.B	'               \|__|  \|_______|\|__|\|__|             ',$d,$a,0
        
TITLE2_ASCII:
        DC.B	'        _________  ________  ________  ________  ___  ________     ',$d,$a
        DC.B	'       |\___   ___\\   __  \|\   __  \|\   __  \|\  \|\   ____\    ',$d,$a
        DC.B	'       \|___ \  \_\ \  \\\  \ \  \|\  \ \  \|\  \ \  \|\  \___|    ',$d,$a
        DC.B	'            \ \  \ \ \   _  _\ \  \\\  \ \   ____\ \  \ \  \       ',$d,$a
        DC.B	'             \ \  \ \ \  \\  \\ \  \\\  \ \  \___|\ \  \ \  \____  ',$d,$a
        DC.B	'              \ \__\ \ \__\\ _\\ \_______\ \__\    \ \__\ \_______\',$d,$a
        DC.B	'               \|__|  \|__|\|__|\|_______|\|__|     \|__|\|_______|',$d,$a
        DC.B    '                                                                   ',$d,$a
        DC.B    '                                                                   ',$d,$a
        DC.B    '               A STRATEGY GAME BY JOSHUA WILKINSON                 ',$d,$a
        DC.B    '                   WRITTEN IN ASSEMBLY 68000                       ',$d,$a,0        

TREE_ASCII:
        DC.B    '  _',$d,$a
        DC.B    ' ( )',$d,$a
        DC.B    '(_X_)',$d,$a
        DC.B    '  j',$d,$a,0 

CITY_ASCII:
        DC.B	'               __   __                     ___      _			    ',$d,$a
        DC.B	'              |  | |  |      /|           |   |   _/ \_		    ',$d,$a
        DC.B	'              |  | |  |  _  | |__         |   |_-/     \-_     _	',$d,$a
        DC.B	'            __|  | |  |_| | | |  |/\_     |   |  \     /  |___|	',$d,$a
        DC.B	'           |  |  | |  | | __| |  |   |_   |   |   |___|   |   |	',$d,$a
        DC.B	'           |  |  |^|  | ||  | |  |   | |__|   |   |   |   |   |	',$d,$a
        DC.B	'           |  |  |||  | ||  | |  |   | /\ |   |   |   |   |   |	',$d,$a
        DC.B	'           ~~~~~~~~~~~~~~~~~~~~~~~~~~~/  \~~~~~~~~~~~~~~~~~~~~~~~	',$d,$a
        DC.B	'          ~ ~~  ~ ~~ ~~~ ~ ~ ~~ ~~ ~~ \   \__   ~  ~  ~~~~ ~~~ ~~	',$d,$a
        DC.B	'        ~~ ~ ~ ~~~ ~~  ~~ ~~~~~~~~~~ ~ \   \o\  ~~ ~ ~~~~ ~ ~ ~~~	',$d,$a
        DC.B	'          ~ ~~~~~~~~ ~ ~ ~~ ~ ~ ~ ~ ~~~ \   \o\=   ~~ ~~  ~~ ~ ~~	',$d,$a
        DC.B	'       ~ ~ ~ ~~~~~~~ ~  ~~ ~~ ~ ~~ ~ ~ ~~ ~ ~ ~~ ~~~ ~ ~ ~ ~ ~~~~	',$d,$a,0


WINDMILL_ASCII:
        DC.B      '\\         //',$d,$a
        DC.B      '  \\     //',$d,$a
        DC.B      '    \\ //',$d,$a
        DC.B      '     (O)',$d,$a
        DC.B      '    //#\\',$d,$a
        DC.B      '  // ### \\',$d,$a
        DC.B      '//  #####  \\',$d,$a
        DC.B      '   #######',0
        
WINDMILL2_ASCII:
        DC.B      '__          __',$d,$a
        DC.B      '\\\        ///',$d,$a
        DC.B      ' \\\  __  ///',$d,$a
        DC.B      '  \\\/__\///',$d,$a
        DC.B      '   \\\__///',$d,$a
        DC.B      '   |\\\///|',$d,$a
        DC.B      '   |_XXXX_|',$d,$a
        DC.B      '   \///\\\/',$d,$a
        DC.B      '   ///__\\\',$d,$a
        DC.B      '  ///____\\\',$d,$a
        DC.B      ' ///______\\\',$d,$a
        DC.B      '///________\\\',$d,$a
        DC.B      '~|__________|~',$d,$a
        DC.B      ' ||_||  ||_||',$d,$a
        DC.B      ' |___|  |___|',0

SOLAR_PANEL_ASCII:
        DC.B      '   /========/',$d,$a		
	    DC.B      '  /  +	/',$d,$a	
	    DC.B      ' /	   /|',$d,$a
	    DC.B      '/========/ |',0
        
PEACE_ASCII:
        DC.B      '   ..eeeee..',$d,$a
        DC.B      ' e8"   8   "8e',$d,$a
        DC.B      'd8     8     8b',$d,$a
        DC.B      '8!   .dWb.   !8',$d,$a
        DC.B      'Y8 .e* 8 *e. 8P',$d,$a
        DC.B      ' *8*   8   *8*',$d,$a
        DC.B      '   **ee8ee**',$d,$a,0
        
OIL_MAN_ASCII:
        DC.B      '   #############',$d,$a     
	    DC.B      '   ##         ##',$d,$a      
	    DC.B      '   #  ~~   ~~  #',$d,$a      
	    DC.B      '   #  ()   ()  #',$d,$a     
	    DC.B      '   (     ^     )',$d,$a      
	    DC.B      '    |         |',$d,$a       
	    DC.B      '    |  {===}  |',$d,$a     
	    DC.B      '     \       /',$d,$a       
	    DC.B      '    /  -----  \',$d,$a      
        DC.B      ' ---  |%\ /%|  ---',$d,$a    
        DC.B      '/     |%%%%%|     \',$d,$a    
        DC.B      '      |%/ \%|',$d,$a,0
        
OIL_MAN2_ASCII:
        DC.B      '   #############',$d,$a     
	    DC.B      '   ## _     _  ##',$d,$a      
	    DC.B      '   #   \   /   #',$d,$a      
	    DC.B      '   #  ()   ()  #',$d,$a     
	    DC.B      '   (     ^     )',$d,$a      
	    DC.B      '    |         |',$d,$a       
	    DC.B      '    |  {===}  |',$d,$a     
	    DC.B      '     \       /',$d,$a       
	    DC.B      '    /  -----  \',$d,$a      
        DC.B      ' ---  |%\ /%|  ---',$d,$a    
        DC.B      '/     |%%%%%|     \',$d,$a    
        DC.B      '      |%/ \%|',$d,$a,0

FRAME_ASCII
        DC.B      '.-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=.',$d,$a,0
        
BAD_ENDING:
    BSR CLEAR
    LEA BAD_ENDING_TEXT, A1
    BSR DISPLAY
    
    BSR YELTEXT
    LEA OIL_MAN_ASCII, A1
    BSR WHITEXT
    
    BRA END


END:

    END    START        ; last line of source




















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
