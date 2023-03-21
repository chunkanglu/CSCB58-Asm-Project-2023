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

.eqv 	SLP_T				40			# Sleep time

# Colours
.eqv	RED					0xff0000
.eqv	ORANGE				0xff8000
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
PLAYER_XY:				.word 2, 14 			# x, y where 0 <= x <= 60, 0 <= y <= 47
							   			# This marks top-left unit of 4 by 5 player
PLAYER_LR_UD:			.word 0, 0			# [0 stationary, 1,left, 2 right] [0 stationary, 1 up (jump), 2 down (falling from jump or ledge)]

PLAYER_WALK_ANIM_ITER:	.word 0
PLAYER_UP_ITER:			.word 0

STAGE:					.word 1

# ----------------------------------------
# Game Start
# ----------------------------------------

.text
.globl 	main

main:	
		# Initialize		
		li $s7, DISP_BASE 	# $s7 stores the base address for display
		# MIGHT NOT NEED TO BE USED
		
		li $t0, 0 # iter
		
		
		la $s1, PLAYER_XY
		la $s2, PLAYER_LR_UD
		la $s3, PLAYER_WALK_ANIM_ITER
		la $s4, PLAYER_UP_ITER
		
		jal clear_screen
		
		
		li $t1, DISP_BASE
		
		jal draw_level
			
loop:	beq $t0, 10000, exit # TODO: temporary exit condition
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
		bne $t8, 1, update_ud
		
# t2: x-coord, t3: y-coord, t8: key value, t9: key address
check_keypress:
		lw $t2, 0($s1) 				# Reload player X-coord
		lw $t3, 4($s1) 				# Reload player Y-coord

		lw $t8, 4($t9) 				# this assumes $t9 is set to 0xfff0000 from before 
		beq $t8, 0x70, restart   	# ASCII code of 'p' is 0x70
		beq $t8, 0x61, key_left   	# ASCII code of 'a' is 0x61
		beq $t8, 0x64, key_right   	# ASCII code of 'd' is 0x64
		beq $t8, 0x77, key_up   	# ASCII code of 'w' is 0x77
		
		# Else, keep what was previously
		j update_ud

# t1: player position, t2: x-coord 
key_left:	
		beq $t2, 0, update_ud  # Do not go left if at left edge of display
		
		addi $t1, $t1, -4 			# player position Left 1
		addi $t2, $t2, -1 			# Update PLAYER_X coord
		sw $t2, 0($s1) 				# Send update
		
		li $t2, 1
		sw $t2, 0($s2)				# Set PLAYER_LR to 1
		
		j update_ud
						
key_right:		
		beq $t2, 60, update_ud  # Do not go right if at right edge of display
		
		addi $t1, $t1, 4 			# player position Right 1
		addi $t2, $t2, 1 			# Update PLAYER_X coord
		sw $t2, 0($s1) 				# Send update
		
		li $t2, 2
		sw $t2, 0($s2)				# Set PLAYER_LR to 2
		
		j update_ud
		
key_up:		
		# Set state saying want to jump, but must pass collision checks to actually jump		
		li $t3, 1
		sw $t3, 4($s2)				# Set PLAYER_UD to 1
		
		j update_ud
		
#set_stationary_lr:
#		sw $zero, 0($s2)				# Set PLAYER_LR to 0
		
#		j update_ud
		
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
# Check Up/Down State
# ----------------------------------------
update_ud:
		lw $t2, 4($s2)					# $t2 PLAYER_UD state
# ----------------------------------------
# Check collision below
# ----------------------------------------
# $t5 stores if there is valid floor (0/1)
down_collision:
		addi $t3, $t1, PLAYER_BL_OFF 	# $t3 leftmost unit below player
		
		# Check 
		lw $t4, 0($t3)				# Color of 1st unit in $t4
		beq $t4, L_GRAY, valid_floor
		
		lw $t4, 4($t3)				# Color of 2nd unit in $t4
		beq $t4, L_GRAY, valid_floor

		lw $t4, 8($t3)				# Color of 3rd unit in $t4
		beq $t4, L_GRAY, valid_floor

		lw $t4, 12($t3)				# Color of 4th unit in $t4
		beq $t4, L_GRAY, valid_floor
		
		# No floor, check if stationary or mid-air going up
		li $t5, 0
		# If going up, check up iteration TODO: PROBLEM HERE IDK WHY
		lw $t2, 4($s2)				# Load Player_UD state in $t2
		
		#bne $t2, 1, set_falling		# If not going up, set to fall
		# Know player is going up
		lw $t3, 0($s4)				# Load upwards iteration in $t3
		bne $t3, 0, check_max_height 	# If up iteration not 0, then it is mid-air and check jump height
		# Else, up iteration is 0 and is trying to jump mid-air, not allowed and set to fall
		
set_falling:
		# Player fall, set fall state & update player 1 unit lower
		li $t2, 2
		sw $t2, 4($s2)				# Set PLAYER_UD to 2 (falling), $t2 fall state
		
		lw $t3, 4($s1) 				# Load player Y-coord
		addi $t3, $t3, 1 			# Down 1
		sw $t3, 4($s1)
		
		addi $t1, $t1, DISP_ROW 	# Update player position down 1
		j done_ud					# No need to check above if already going down
		
valid_floor:
		# Valid floor
		li $t5, 1
		sw $zero, 0($s4)			# Reset jump iteration
		beq $t2, 1, up_collision	# If going up, check above up collision (know jump height 0)
		# Stationary
		sw $zero, 4($s2)				# Set PLAYER_UD to 0 (stationary)
		j done_ud
		
# ----------------------------------------
# Check if at max height
# ----------------------------------------
check_max_height:
		bge $t3, PLAYER_JUMP_HEIGHT, set_falling # Set to fall if at max jump height
		# Else check collision above
		
# ----------------------------------------
# Check collision above
# ----------------------------------------
up_collision:
		# Know player is trying to go up
		lw $t3, 4($s1)						# Load player y-coord in $t3
		bgt $t3, 0, platform_bot_collision	# Check platform collision if not at top of screen
		j stationary_or_fall				# At top of screen, see if player is standing on platform TODO: currently player repeatedly slams head on edge

platform_bot_collision:
		# Check the 4 units above player and see if platform
		# If platform, stay or fall depending on if floor below player
		subi $t3, $t1, DISP_ROW		# $t3 :: unit of leftmost pixel above player
		lw $t4, 0($t3)				# Color of 1st unit in $t4
		beq $t4, L_GRAY, stationary_or_fall
		
		lw $t4, 4($t3)				# Color of 2nd unit in $t4
		beq $t4, L_GRAY, stationary_or_fall

		lw $t4, 8($t3)				# Color of 3rd unit in $t4
		beq $t4, L_GRAY, stationary_or_fall	

		lw $t4, 12($t3)				# Color of 4th unit in $t4
		beq $t4, L_GRAY, stationary_or_fall
		
set_up:
		# Pass up collision tests, and know it can go up
		li $t2, 1
		sw $t2, 4($s2)				# Set PLAYER_UD to 1 (upward), $t2 up state
		
		lw $t3, 4($s1) 				# Load player Y-coord
		addi $t3, $t3, -1 			# Up 1
		sw $t3, 4($s1)
		
		subi $t1, $t1, DISP_ROW 	# Update player position up 1
		
		lw $t3, 0($s4)				# Update jump iteration
		addi $t3, $t3, 1
		sw $t3, 0($s4)
		
		j done_ud
			
stationary_or_fall:
		# $t5 stored if valid floor
		beq $t5, 0, set_falling				# Set to fall if no valid floor
		# Else stationary
		sw $zero, 4($s2)					# Set PLAYER_UD to 0 (stationary)
		
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
		li $t6, ORANGE
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
	
draw_ui:

draw_empty_heart:
				
draw_level_1:

draw_level_2:

draw_level_3:

draw_0:

draw_1:

draw_2:

draw_3:

draw_4:

draw_5:
	
draw_6:

draw_7:

draw_8:	

draw_9:

#-----------
exit:	
		li $v0, 10 # terminate the program gracefully 
 		syscall

draw_level:
		li $t9, PLATFORM
		
		sw $t9, 5120($s7)
		sw $t9, 5124($s7)
		sw $t9, 5128($s7)
		sw $t9, 5132($s7)
		sw $t9, 5136($s7)
		sw $t9, 5140($s7)
		sw $t9, 5144($s7)


jr $ra