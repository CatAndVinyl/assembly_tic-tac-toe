.text
.globl main

main:
    #prompts the user to enter an excercise number
    #1 multiplies two numbers
    #2 checks parity of a number
    #3 prints every value within a range for each step
    #4 a game of tic tac tow
    
    #this code will prompt the user to enter an excercise number
    #and will run the associated excercise
    la $a0, excercise_Prompt
    li $v0, 4
    syscall
    li $v0, 5
    syscall
    beq $v0, 1, ex1
    beq $v0, 2, ex2
    beq $v0, 3, ex3
    beq $v0, 4, ex4
    j next
    
    ######################################################
    # 
    # Ex. 1 multiplies two numbers and outputs the product
    #
    # @version 11/15/21
    # @author Matthew L. 
    # 
    ######################################################
    ex1:
        la $a0, multiplication
        li $v0, 4
        syscall
        li $v0, 5
        syscall
        move $t0, $v0
        li $v0, 5
        syscall
        mult $v0, $t0
        mflo $a0
        li $v0, 1
        syscall
    j next
    ######################################################
    # 
    # Ex. 2 takes a value and returns its parity
    #
    # @version 11/15/21
    # @author Matthew L. 
    # 
    ######################################################  
    ex2:
        la $a0, parity
        li $v0, 4
        syscall
        li $v0, 5
        syscall
        li $t1, 2
        div $v0, $t1
        mflo $t2
        mult $t2, $t1
        mflo $t1 
        bne $t1, $v0, printOdd
        la $a0, even
        li $v0, 4
        syscall
        j next
    	printOdd:
    	    la $a0, odd
   	    li $v0, 4
    	    syscall
    j next
    ######################################################
    # 
    # Ex. 3 returns a range of values between the user's
    # given range
    #
    # @version 11/15/21
    # @author Matthew L. 
    # 
    ######################################################
    ex3:
        la $a0, range
        li $v0, 4
        syscall
        li $v0, 5
        syscall
        move $t0, $v0
        li $v0, 5
        syscall
        move $t1, $v0
        li $v0, 5
        syscall
        move $t2, $v0
        step_loop:
            bgt $t0, $t1, next
            la $a0, ($t0)
            li $v0, 1
            syscall
            la $a0, space
            li $v0, 4
            syscall
            addu $t0, $t0, $t2
            j step_loop
    j next
    ######################################################
    # 
    # Ex. 4 generates a tic tac tow game. It will ask the
    # user for the dimensions of the game, and on every
    # turn, it will add an X or and O at the given row
    # and column. It will check whether a player has won
    # by going in all 8 directions, and summing opposite
    # directions. If the area of the board equals the number
    # of turns and a player hasn't won, then it is a tie.
    #
    # Registers used:
    # $t0 : will be a constant storing the board size
    # $t1 : will be used to iterate through the printing and reused
    # $t2 : is used to iterate through each row/block of the board
    # $t3 : stores the number of turns passed
    # $t4 : stores $t3/2 so basically whose turn it is
    # $t5 : stores the original stack position and never changes 
    #       (I set it 500k below just for overflow issues idk)
    # $t6 : temporary, used for calculations (no specific use)
    # $t7 : temporary, used for calculations (no specific use)
    # $t8 : used for storing the memory address of the current row-column
    # $t9 : used for counting the amount of X's or O's in each direction
    # $s0 : stores the row-column memory address from the user's original row-column
    # $s1 : will be aa constant storing the area of the board (size^2)
    #
    # @version 11/15/21
    # @author Matthew L. 
    # 
    ######################################################
    ex4:
        #size of board
        la $a0, prompt_size
        li $v0, 4
        syscall
        li $v0, 5
        syscall
        move $t0, $v0  
        
        #set the reference of the first item in memory
        subu $sp, $sp, 500000
        addu $t5, $sp, 0
        
        #s1 is the the area
        addu $s1, $t0, 0
        mult $s1, $s1
        mflo $s1
        
        #one round of the game
        game_loop:
        #$t3 counts the number of moves
        li $t7, 2
        div $t3, $t7
        #t4 stores the remainder
        mfhi $t4
        #asks for player input
        beq $t4, 0, player1
        la $a0, player_prompt2
        li $v0, 4
        syscall
        j get_input
        player1:
            la $a0, player_prompt1
            li $v0, 4
            syscall
        #get input(two whole numbers)
        get_input:
            li $v0, 5
            syscall
        move $t6, $v0
        subu $t6, $t6, 1
            li $v0, 5
            syscall
            subu $v0, $v0, 1
        add $t3, $t3, 1
        
        #store input (O is a 67, and X is a 68)
        store_input:
            li $t7, 4
            mult $t6, $t7
            mflo $t6
            mult $t6, $t0
            mflo $t6
            mult $v0, $t7
            mflo $t7
            addu $t6, $t6, $t7
            subu $sp, $t5, $t6
            addu $t7, $t4, 67 
            sw $t7, ($sp)
            addu $s0, $sp, 0
        
        #refresh $t2
        addu $t2, $t0, 0
        #t0 holds the size, t1 is a copy for columns, t2 is for rows
        next_line:
            #checks if t2 is 0 or less and will stop if it is
            ble $t2, 0, next_check
            
            #first
            #refreshes $t1
            addu $t1, $t0, 0
            #draws the row
            draw_loop:
                ble $t1, 1, next_op
                la $a0, tab_asterisk
                li $v0, 4
                syscall
                subu $t1, $t1, 1
            j draw_loop

            #adds a newline and decrements the count
            next_op:
            la $a0, newline
            li $v0, 4
            syscall
            
        #second
            #refreshes $t1
            addu $t1, $t0, 0
            #draws the row
            draw_loop2:
                subu $t6, $t0, $t2
                subu $t7, $t0, $t1    
                li $t8, 4
                mult $t6, $t8
                mflo $t6
                mult $t6, $t0
                mflo $t6
                mult $t7, $t8
                mflo $t7
                addu $t8, $t6, $t7
                subu $sp, $t5, $t8
                lw $t8, ($sp)
                beq $t8, 67, print_X
                beq $t8, 68, print_O
                la $a0, space
                li $v0, 4
                syscall
                j after_print
                print_O:
                    la $a0, character_O
                    li $v0, 4
                    syscall
                    j after_print
                print_X:
                    la $a0, character_X
                    li $v0, 4
                    syscall
                after_print:    	    
                    ble $t1, 1, next_op2
                    la $a0, small_tab_asterisk
                    li $v0, 4
                    syscall
                subu $t1, $t1, 1
            j draw_loop2

            #adds a newline and decrements the count
            next_op2:
            la $a0, newline
            li $v0, 4
            syscall
            
        #third
            #refreshes $t1
            addu $t1, $t0, 0
            #draws the row
            draw_loop3:
                ble $t1, 1, next_op3
                la $a0, tab_asterisk
                li $v0, 4
                syscall
                subu $t1, $t1, 1
            j draw_loop3

            #adds a newline and decrements the count
            next_op3:
            la $a0, newline
            li $v0, 4
            syscall
            
        #fourth
        #refreshes $t1
        beq $t2, 1, next_op4
        
            addu $t1, $t0, 0
        #draws the row
            draw_loop4:
                ble $t1, 0, next_op4
                la $a0, line
                li $v0, 4
                syscall
                subu $t1, $t1, 1
            j draw_loop4

            #adds a newline and decrements the count
            next_op4:
            la $a0, newline
            li $v0, 4
        syscall
        subu $t2, $t2, 1
            
        j next_line

        next_check:
            li $t9, 1
            j next_step
            
        #north
        next_step:
            addu $t8, $s0, 0
            
        north:
            li $t6, 4
            mult $t6, $t0
            mflo $t6
            addu $t8, $t8, $t6
            
            bgt $t8, $t5, next_step1
            
            lw $t7, ($t8)
            
            addu $t6, $t4, 67
            beq $t7, $t6, north_count
            j next_step1
            north_count:
                addu $t9, $t9, 1
            j north
            
        next_step1:
            addu $t8, $s0, 0
        
        south:
            li $t6, 4
            mult $t6, $t0
            mflo $t6
            subu $t8, $t8, $t6
            
            li $t7, 4
            mult $t6, $t7
            mflo $t6
            addu $t6, $t6, 4
            ble $t8, $t5, next_step2
            
            lw $t7, ($t8)
            addu $t6, $t4, 67
            beq $t7, $t6, south_count
            j next_step2
            south_count:
                addu $t9, $t9, 1
            j south
        
        next_step2:
            addu $t8, $s0, 0 	
            beq $t0, $t9, end_game
            li $t9, 1
        
        west:
            li $t6, 4
            mult $t6, $t0
            mflo $t6
            subu $t7, $t5, $t8
            div $t7, $t6
            mfhi $t6
            beq $t6, 0, next_step3
            addu $t8, $t8, 4
            
            lw $t7, ($t8)
            
            addu $t6, $t4, 67
            beq $t7, $t6, west_count
            j next_step3
            west_count:
                addu $t9, $t9, 1
            j west
            
        next_step3:
            addu $t8, $s0, 0
        
        east:
            li $t6, 4
            mult $t6, $t0
            mflo $t6
            subu $t7, $t5, $t8
            addu $t7, $t7, 4
            div $t7, $t6
            mfhi $t6
            beq $t6, 0, next_step4
            subu $t8, $t8, 4
            
            lw $t7, ($t8)
            addu $t6, $t4, 67
            beq $t7, $t6, east_count
            j next_step4
            east_count:
                addu $t9, $t9, 1
            j east
        
        next_step4:
            addu $t8, $s0, 0 	
            beq $t0, $t9, end_game
            li $t9, 1
        
        north_west:
            li $t6, 4
            mult $t6, $t0
            mflo $t6
            addu $t8, $t8, $t6
            
            bgt $t8, $t5, next_step5
            
            li $t6, 4
            mult $t6, $t0
            mflo $t6
            subu $t7, $t5, $t8
            div $t7, $t6
            mfhi $t6
            beq $t6, 0, next_step5
            addu $t8, $t8, 4
            
            lw $t7, ($t8)
            addu $t6, $t4, 67
            beq $t7, $t6, northwest_count
            j next_step5
            northwest_count:
                addu $t9, $t9, 1
            j north_west	
        
        next_step5:
            addu $t8, $s0, 0	    
        
        south_east:
            li $t6, 4
            mult $t6, $t0
            mflo $t6
            subu $t8, $t8, $t6
            
            li $t7, 4
            mult $t6, $t7
            mflo $t6
            addu $t6, $t6, 4
            ble $t8, $t5, next_step6
            
            li $t6, 4
            mult $t6, $t0
            mflo $t6
            subu $t7, $t5, $t8
            addu $t7, $t7, 4
            div $t7, $t6
            mfhi $t6
            beq $t6, 0, next_step6
            subu $t8, $t8, 4
            
            lw $t7, ($t8)
            addu $t6, $t4, 67
            beq $t7, $t6, south_east_count
            j next_step6
            south_east_count:
                addu $t9, $t9, 1
            j south_east
        
        next_step6:
            addu $t8, $s0, 0 	
            beq $t0, $t9, end_game
            li $t9, 1
        
        #north east
        north_east:
            li $t6, 4
            mult $t6, $t0
            mflo $t6
            addu $t8, $t8, $t6
            
            bgt $t8, $t5, next_step7
            
            li $t6, 4
            mult $t6, $t0
            mflo $t6
            subu $t7, $t5, $t8
            addu $t7, $t7, 4
            div $t7, $t6
            mfhi $t6
            beq $t6, 0, next_step7
            subu $t8, $t8, 4
            
            lw $t7, ($t8)
            addu $t6, $t4, 67
            beq $t7, $t6, northeast_count
            j next_step7
            northeast_count:
                addu $t9, $t9, 1
            j north_east	
        
        next_step7:
            addu $t8, $s0, 0

        south_west:
            li $t6, 4
            mult $t6, $t0
            mflo $t6
            subu $t8, $t8, $t6
            
            li $t7, 4
            mult $t6, $t7
            mflo $t6
            addu $t6, $t6, 4
            ble $t8, $t5, next_step8
            
            li $t6, 4
            mult $t6, $t0
            mflo $t6
            subu $t7, $t5, $t8
            div $t7, $t6
            mfhi $t6
            beq $t6, 0, next_step8
            addu $t8, $t8, 4
            
            lw $t7, ($t8)
            addu $t6, $t4, 67
            beq $t7, $t6, southwest_count
            j next_step8
            southwest_count:
                addu $t9, $t9, 1
            j south_east	
        
        next_step8:
            addu $t8, $s0, 0
            beq $t0, $t9, end_game
            
        beq $t3, $s1, tie_game
        j after_check
        tie_game:
                la $a0, tie_message
                li $v0, 4
                syscall
                j next
    
        end_game:
            beq $t4, 0, player1_win
            la $a0, player2_win_message
            li $v0, 4
            syscall
            j next
            player1_win:
                la $a0, player1_win_message
                li $v0, 4
                syscall
                j next
            
        after_check:
            
        j game_loop
    next:
    li $v0, 10
    syscall

.data
space:
.asciiz " "
tab_asterisk:
.asciiz "   |  "
small_tab_asterisk:
.asciiz "  |  "
line:
.asciiz "-----"
newline:
.asciiz "\n"
player_prompt1:
.asciiz "player 1 - enter your move (a row and column) \n"
player_prompt2:
.asciiz "player 2 - enter your move (a row and column) \n"
player1_win_message:
.asciiz "player 1 wins"
player2_win_message:
.asciiz "player 2 wins"
tie_message:
.asciiz "both players lose"
character_O:
.asciiz "O"
character_X:
.asciiz "X"
multiplication:
.asciiz "Enter Two Integers"
parity:
.asciiz "Enter an Integer"
odd:
.asciiz "Odd"
even:
.asciiz "Even"
range:
.asciiz "Enter a Range (Two Integers) and a Step"
prompt_size:
.asciiz "Enter the size of the board"
excercise_Prompt:
.asciiz "Enter the exercise number\n"
test:
.word 55