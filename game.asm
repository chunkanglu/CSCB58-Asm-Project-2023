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
# - Display width in pixels: 512 (update this as needed) 
# - Display height in pixels: 512 (update this as needed) 
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

.eqv  	DISP_BASE  			0x10008000
.eqv	DISP_SIZE			4096 				# 64 units * 64 units = 4096
.eqv	DISP_ROW			256
.eqv	PLAYER_BL_OFF		1280				# 256 * 5 = 1280 offset for Bottom left unit below player
.eqv	DISP_W				0x00000080 # unused
.eqv	DISP_H				0x00000080 # unused
.eqv	PLAY_BASE			0x10008000 # unused
.eqv	P_OFF_X				0x00000004 # unused
.eqv	P_OFF_Y				0x00000005 # unused

.eqv 	SLP_T				200			# Sleep time

# Colours
.eqv	RED					0xff0000
.eqv	D_RED				0x7f2525
.eqv	CYAN				0x81a0a9 	
.eqv	GRAY				0x585858
.eqv	L_GRAY				0xb4b4b4
.eqv	BLACK				0x000000	

.eqv	PLATFORM			0xb4b4b4 			# L_GRAY

.eqv	PLAYER_JUMP_HEIGHT	5

# ----------------------------------------
# Stored
# ----------------------------------------
.data
PLAYER_XY:				.word 2, 2 			# x, y where 0 <= x <= 60, 0 <= y <= 47
							   			# This marks top-left unit of 4 by 5 player
PLAYER_LR_UD:			.word 0, 0			# [0 stationary, 1,left, 2 right] [0 stationary, 1 up (jump), 2 down (falling from jump or ledge)]

PLAYER_WALK_ANIM_ITER:	.word 0
PLAYER_UP_ITER:			.word 0

STAGE:					.word 1

left:	.asciiz "left\n"
right: 	.asciiz "right\n"

# ----------------------------------------
# Game Start
# ----------------------------------------

.text
.globl 	main

main:	
		# Initialize		
		li $s0, DISP_BASE 	# $s0 stores the base address for display
		# MIGHT NOT NEED TO BE USED
		
		li $t0, 0 # iter
		
		
		la $s1, PLAYER_XY
		la $s2, PLAYER_LR_UD
		la $s3, PLAYER_WALK_ANIM_ITER
		la $s4, PLAYER_UP_ITER
		
		jal clear_screen
		
loop:	beq $t0, 100, exit # TODO: temporary exit condition
		addi $t0, $t0, 1		
		
		lw $t2, 0($s1) 				# Load player X-coord
		lw $t3, 4($s1) 				# Load player Y-coord
		
		# Calculate unit location from coords
		sll $t2, $t2, 2				# $t2 = $t2 * 4	(Right $t2 units)
		sll $t3, $t3, 8				# $t3 = $t3 * 64 * 4 (Down $t3 rows)
		addi $t1, $t2, DISP_BASE	# $t1 = base + x-offset
		add $t1, $t1, $t3			# $t1 = updated + y-offset
		
		addi $s0, $t1, 0			# Store player location before possible moves in $s0
		
		# Check if at the goal & update level state
		
			# Check if finish game
			
			# Clear & Update next level & respawn if not finish
		
# ----------------------------------------
# Check if at lava & remove heart
# ----------------------------------------
in_lava:
		lw $t3, 4($s1) 				# Load player Y-coord
		blt $t3, 47, check_hearts	# Skip if not in lava
		# TODO: decrease heart & respawn
		j restart # TODO: remove this temporary restart when lives implemented
# ----------------------------------------

# ----------------------------------------
# Check heart level & determine if respawn or end
# ----------------------------------------
check_hearts:

# ----------------------------------------
# Check for L, R, U & update state & new position
# ----------------------------------------
keypress_event:
		li $t9, 0xffff0000  
		lw $t8, 0($t9) 
		beq $t8, 1, check_keypress 
		
# t2: x-coord, t3: y-coord, t8: key value, t9: key address
check_keypress:
		lw $t2, 0($s1) 				# Reload player X-coord
		lw $t3, 4($s1) 				# Reload player Y-coord

		lw $t8, 4($t9) 				# this assumes $t9 is set to 0xfff0000 from before 
		beq $t8, 0x70, restart   	# ASCII code of 'p' is 0x70
		beq $t8, 0x61, key_left   	# ASCII code of 'a' is 0x61
		beq $t8, 0x64, key_right   	# ASCII code of 'd' is 0x64
		
		# Else, player is stationary
		j set_stationary_lr

# t1: player position, t2: x-coord 
key_left:	
		beq $t2, 0, set_stationary_lr  # Do not go left if at left edge of display
		
		addi $t1, $t1, -4 			# player position Left 1
		addi $t2, $t2, -1 			# Update PLAYER_X coord
		sw $t2, 0($s1) 				# Send update
		
		li $t2, 1
		sw $t2, 0($s2)				# Set PLAYER_LR to 1
		
		j update_ud
						
key_right:		
		beq $t2, 60, set_stationary_lr  # Do not go right if at right edge of display
		
		addi $t1, $t1, 4 			# player position Right 1
		addi $t2, $t2, 1 			# Update PLAYER_X coord
		sw $t2, 0($s1) 				# Send update
		
		li $t2, 2
		sw $t2, 0($s2)				# Set PLAYER_LR to 2
		
		j update_ud
		
set_stationary_lr:
		sw $zero, 0($s2)				# Set PLAYER_LR to 0
		
		j update_ud
		
restart:
		# TODO: go to first stage
		li $t2, 2 					# TODO: replace with start pos
		li $t3, 2
		sw $t2, 0($s1)
		sw $t3, 4($s1)
		# TODO: clear score & reset health
		# TODO: reset all iteration variables for tracking cycles (walk anim...)
		# TODO: reset other player states
		
		j main

# ----------------------------------------
# Check top screen edge or platform (below) collision
# ----------------------------------------
update_ud:
		lw $t2, 4($s2)				# Load Player_UD state in $t2
		
up_collision:
		bne $t2, 1, down_collision	# Skip if not going upwards (trying to jump)
		lw $t3, 0($s4)				# Load upwards iteration in $t3
		
		bne $t3, PLAYER_JUMP_HEIGHT, ceil_collision # Check ceil collision if not max jump height
		j set_falling
		
ceil_collision:
		addi $t3, $t3, 1			# + 1 jump iteration in $t3
		sw $t3, 0($s4)
		
		lw $t3, 4($s1)				# Load player y-coord in $t3
		bgt $t3, 0, platform_bot_collision	# Check platform collision if not at top of screen
		j set_falling
		
platform_bot_collision:
		# Check the 4 units above player and see if platform
		subi $t3, $t1, DISP_ROW		# $t3 :: unit of leftmost pixel above player
		lw $t4, 0($t3)				# Color of 1st unit in $t4
		beq $t4, L_GRAY, set_falling
		
		lw $t4, 4($t3)				# Color of 2nd unit in $t4
		beq $t4, L_GRAY, set_falling

		lw $t4, 8($t3)				# Color of 3rd unit in $t4
		beq $t4, L_GRAY, set_falling	

		lw $t4, 12($t3)				# Color of 4th unit in $t4
		beq $t4, L_GRAY, set_falling

		j down_collision			# $t2 up state, passed all checks, can jump if valid floor
		
set_falling:
		sw $zero, 0($s4)			# Reset upwards iteration
		li $t2, 2
		sw $t2, 4($s2)				# Set PLAYER_UD to 2 (falling), $t2 fall state
		
# ----------------------------------------
# Check platform (above) collision
# ----------------------------------------
down_collision:
		addi $t3, $t1, PLAYER_BL_OFF 	# $t3 leftmost unit below player
		
		# Check 
		lw $t4, 0($t3)				# Color of 1st unit in $t4
		beq $t4, L_GRAY, jump_or_stationary
		
		lw $t4, 4($t3)				# Color of 2nd unit in $t4
		beq $t4, L_GRAY, jump_or_stationary

		lw $t4, 8($t3)				# Color of 3rd unit in $t4
		beq $t4, L_GRAY, jump_or_stationary	

		lw $t4, 12($t3)				# Color of 4th unit in $t4
		beq $t4, L_GRAY, jump_or_stationary
		
		# No valid floor, set fall state & update player 1 unit lower
		li $t2, 2
		sw $t2, 4($s2)				# Set PLAYER_UD to 2 (falling), $t2 fall state
		
		lw $t3, 4($s1) 				# Load player Y-coord
		addi $t3, $t3, 1 			# Down 1
		sw $t3, 4($s1)
		
		addi $t1, $t1, DISP_ROW 	# Update player position down 1
		
		j done_ud
		
jump_or_stationary:
		# Valid floor
		beq $t2, 1, set_jump	# Check if upward state

set_stationary:
		# Valid floor & falling becomes stationary
		li $t2, 0
		sw $t2, 4($s2)				# Set PLAYER_UD to 0 (stationary)
		
		j done_ud
		
set_jump:
		# Valid floor & upward
		li $t2, 1
		sw $t2, 4($s2)				# Set PLAYER_UD to 1 (upward), $t2 up state
		
		lw $t3, 4($s1) 				# Load player Y-coord
		addi $t3, $t3, -1 			# Up 1
		sw $t3, 4($s1)
		
		subi $t1, $t1, DISP_ROW 	# Update player position up 1

done_ud:
			
# ----------------------------------------
# Check iteration states & determine which sprite to render
# ----------------------------------------


# ----------------------------------------
# Clear & render player
# ----------------------------------------
update_player:
		# $t1 is player position to draw
		# $t2 is PLAYER_LR state
		# $t3 is PLAYER_UD state
		lw $t2, 0($s2)
		lw $t3, 4($s2)
		
		bne $t2, 0, clear_and_render_player
		bne $t3, 0, clear_and_render_player
		# Stationary, no update
		j update_timer
		
clear_and_render_player:
		addi $t4, $t1, 0			# Temp store new player location in $t4
		addi $t1, $s0, 0			# Load previous location to clear
		jal clear_player			# Clear player at $t1
		
		addi $t1, $t4, 0			# Load new location to draw
		jal set_player 				# Draws player at $t1
		
		# Reset PLAYER_LR_UD
		sw $zero, 0($s2)				# Set PLAYER_LR to 0
		sw $zero, 4($s2)				# Set PLAYER_UD to 0
		
# ----------------------------------------
# Check if 24 cycles & update timer
# ----------------------------------------
update_timer:

end_of_loop:				
		li $v0, 32 
		li $a0, SLP_T   			# Wait 40 milliseconds
		syscall
		
		j loop						# Go to start of game loop

# ---- MAIN LOOP END ----

# ---- CLEAR SCREEN +
clear_screen:
		li $t7, BLACK
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
		li $t6, D_RED
		li $t7, RED
		li $t8, CYAN
		li $t9, GRAY
		
		j draw_player
		
clear_player:
		li $t6, BLACK
		li $t7, BLACK
		li $t8, BLACK
		li $t9, BLACK
		
		j draw_player

# t1: player position
draw_player:	
		sw $t7, 4($t1)
		sw $t7, 8($t1)
		sw $t7, 12($t1)
		sw $t9, 256($t1)			# Next row is 256 offset
		sw $t7, 260($t1)
		sw $t8, 264($t1)
		sw $t8, 268($t1)
		sw $t9, 512($t1)
		sw $t7, 516($t1)
		sw $t7, 520($t1)
		sw $t7, 524($t1)
		sw $t9, 768($t1)
		sw $t7, 772($t1)
		sw $t7, 776($t1)
		sw $t7, 780($t1)
		sw $t6, 1028($t1)
		sw $t6, 1036($t1)
		
		jr $ra
		
draw_level_1:

draw_level_2:

draw_level_3:
		
exit:	
		li $v0, 10 # terminate the program gracefully 
 		syscall

