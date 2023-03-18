##################################################################### 
# 
# CSCB58 Winter 2023 Assembly Final Project 
# University of Toronto, Scarborough 
# 
# Student: Chun Kang Lu, 1008161150, luchun3, chunkang.lu@mail.utoronto.ca
# 
# Bitmap Display Configuration: 
# - Unit width in pixels: 8 (update this as needed)  
# - Unit height in pixels: 8 (update this as needed) 
# - Display width in pixels: 256 (update this as needed) 
# - Display height in pixels: 256 (update this as needed) 
# - Base Address for Display: 0x10008000 ($gp) 
# 
# Which milestones have been reached in this submission? 
# (See the assignment handout for descriptions of the milestones) 
# - Milestone 1/2/3 (choose the one the applies) 
# 
# Which approved features have been implemented for milestone 3? 
# (See the assignment handout for the list of additional features) 
# 1. (fill in the feature, if any) 
# 2. (fill in the feature, if any) 
# 3. (fill in the feature, if any) 
# ... (add more if necessary) 
# 
# Link to video demonstration for final submission: 
# - (insert YouTube / MyMedia / other URL here). Make sure we can view it! 
# 
# Are you OK with us sharing the video with people outside course staff? 
# - yes / no / yes, and please share this project github link as well! 
# 
# Any additional information that the TA needs to know: 
# - (write here, if any) 
# 
##################################################################### 

# ----------------------------------------
# Constants
# ----------------------------------------

.eqv  	DISP_BASE  	0x10008000
.eqv	DISP_SIZE	1024 				# 32 units * 32 units = 1024
.eqv	DISP_W		0x00000080 # unused
.eqv	DISP_H		0x00000080 # unused
.eqv	PLAY_BASE	0x10008000 # unused
.eqv	P_OFF_X		0x00000004 # unused
.eqv	P_OFF_Y		0x00000005 # unused

.eqv 	SLP_T		40			# Sleep time

# Colours
.eqv	P_COL_P		0xff0000 	# Red
.eqv	P_COL_S		0x81a0a9 	# Light Blue
.eqv	P_COL_T		0x585858	# Gray
.eqv	BG			0x000000	# Black

# ----------------------------------------
# Stored
# ----------------------------------------
.data
PLAYER_XY:			.word 0, 0 			# x, y where 0 <= x <= 28, 0 <= y <= 27
							   			# This marks top-left unit of 4 by 5 player
PLAYER_LR:			.word 0				# 0 stationary, 1,left, 2 right
PLAYER_UD:			.word 0 			# 0 stationary, 1 up (jump), 2 down (falling from jump or ledge)

# ----------------------------------------
# Game Start
# ----------------------------------------

.text
.globl 	main

main:	
		# Initialize		
		li $s0, DISP_BASE 	# $s0 stores the base address for display
		# MIGHT NOT NEED TO BE USED
		
		li $t4, 0 # iter
		
		la $s1, PLAYER_XY
		la $s2, PLAYER_LR
		la $s3, PLAYER_UD
		
		jal clear_screen
		
loop:	beq $t4, 100, exit # TODO: temporary exit condition
		addi $t4, $t4, 1
		
		
		lw $t2, 0($s1) 				# Load player X-coord
		lw $t3, 4($s1) 				# Load player Y-coord
		
		# Calculate unit location from coords
		sll $t2, $t2, 2				# $t2 = $t2 * 4	(Right $t2 units)
		sll $t3, $t3, 7				# $t3 = $t3 * 128 (Down $t3 rows)
		addi $t1, $t2, DISP_BASE	# $t1 = base + x-offset
		add $t1, $t1, $t3			# $t1 = updated + y-offset
		
		jal clear_player			# Clear player at $t1
		
keypress_event:
		li $t9, 0xffff0000  
		lw $t8, 0($t9) 
		beq $t8, 1, check_keypress 
		
update_player:
		jal set_player 				# Draws player at $t1
		
		li $v0, 32 
		li $a0, SLP_T   			# Wait 40 milliseconds
		syscall
		
		j loop						# Go to start of game loop

# ---- MAIN LOOP END ----

# t2: x-coord, t3: y-coord, t8: key value, t9: key address
check_keypress:
		lw $t2, 0($s1) 				# Reload player X-coord
		lw $t3, 4($s1) 				# Reload player Y-coord

		lw $t8, 4($t9) 				# this assumes $t9 is set to 0xfff0000 from before 
		beq $t8, 0x61, key_left   	# ASCII code of 'a' is 0x61
		beq $t8, 0x64, key_right   	# ASCII code of 'd' is 0x64
		
		# Else, player is stationary
		sw $zero, 0($s2)				# Set PLAYER_LR to 0
		
		j update_player

# t1: player position, t2: x-coord | PLAYER_LR, s1: PLAYER_XY
key_left:
		beq $t2, 0, update_player  # Do not go right if at right edge of display
		
		addi $t1, $t1, -4 			# player position Left 1
		addi $t2, $t2, -1 			# Update PLAYER_XY
		sw $t2, 0($s1) 				# Send update
		
		li $t2, 1
		sw $t2, 0($s2)				# Set PLAYER_LR to 1
		
		j update_player
						
key_right:
		beq $t2, 28, update_player  # Do not go right if at right edge of display
		
		addi $t1, $t1, 4 			# player position Right 1
		addi $t2, $t2, 1 			# Update PLAYER_XY
		sw $t2, 0($s1) 				# Send update
		
		li $t2, 2
		sw $t2, 0($s2)				# Set PLAYER_LR to 2
		
		j update_player

# ---- CLEAR SCREEN +
clear_screen:
		li $t7, BG
		li $t8, 0 					# Iterator over screen
		li $t9, DISP_BASE			# Iter address to clear
		
clear_loop:
		beq $t8, DISP_SIZE, clear_end
		sw $t7, 0($t9)
		addi $t8, $t8, 1			# Move to next unit
		addi $t9, $t9, 4
		j clear_loop
		
clear_end:
		jr $ra
# ---- CLEAR SCREEN -
 		
set_player:
		li $t7, P_COL_P
		li $t8, P_COL_S
		li $t9, P_COL_T
		
		j draw_player
		
clear_player:
		li $t7, BG
		li $t8, BG
		li $t9, BG
		
		j draw_player

# t1: player position
draw_player:	
		sw $t7, 4($t1)
		sw $t7, 8($t1)
		sw $t7, 12($t1)
		sw $t9, 128($t1)
		sw $t7, 132($t1)
		sw $t8, 136($t1)
		sw $t8, 140($t1)
		sw $t9, 256($t1)
		sw $t7, 260($t1)
		sw $t7, 264($t1)
		sw $t7, 268($t1)
		sw $t9, 384($t1)
		sw $t7, 388($t1)
		sw $t7, 392($t1)
		sw $t7, 396($t1)
		sw $t7, 516($t1)
		sw $t7, 524($t1)
		
		jr $ra
		
exit:	
		li $v0, 10 # terminate the program gracefully 
 		syscall

