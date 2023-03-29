# Colours
.eqv	RED					0xff0000
.eqv	ORANGE				0xff8000
.eqv	CYAN				0x81a0a9 	
.eqv	GRAY				0x585858
.eqv	L_GRAY				0xb4b4b4
.eqv	BLACK				0x000000
.eqv 	WHITE				0xffffff

.globl load_draw_colors, load_clear_colors, load_player_white, draw_left_static, draw_left_lleg, draw_left_rleg, draw_left_jump, draw_right_static, draw_right_lleg, draw_right_rleg, draw_right_jump

load_draw_colors:
		li $t6, ORANGE
		li $t7, RED
		li $t8, CYAN
		li $t9, GRAY
		jr $ra
		
load_clear_colors:
		li $t6, BLACK
		li $t7, BLACK
		li $t8, BLACK
		li $t9, BLACK
		jr $ra
		
load_player_white:
		li $t6, WHITE
		li $t7, WHITE
		li $t8, WHITE
		li $t9, WHITE
		jr $ra

draw_left_static:
		sw $t7, 0($t1)
		sw $t7, 4($t1)
		sw $t7, 8($t1)
		sw $t8, 256($t1)
		sw $t8, 260($t1)
		sw $t7, 264($t1)
		sw $t9, 268($t1)
		sw $t7, 512($t1)
		sw $t7, 516($t1)
		sw $t7, 520($t1)
		sw $t9, 524($t1)
		sw $t7, 768($t1)
		sw $t7, 772($t1)
		sw $t7, 776($t1)
		sw $t9, 780($t1)
		sw $t6, 1024($t1)
		sw $t6, 1032($t1)
		
		jr $ra


draw_left_lleg: 
		sw $t7, 0($t1)
		sw $t7, 4($t1)
		sw $t7, 8($t1)
		sw $t8, 256($t1)
		sw $t8, 260($t1)
		sw $t7, 264($t1)
		sw $t9, 268($t1)
		sw $t7, 512($t1)
		sw $t7, 516($t1)
		sw $t7, 520($t1)
		sw $t9, 524($t1)
		sw $t6, 768($t1)
		sw $t7, 772($t1)
		sw $t7, 776($t1)
		sw $t9, 780($t1)
		sw $t6, 1032($t1)
		
		jr $ra


draw_left_rleg:
		sw $t7, 0($t1)
		sw $t7, 4($t1)
		sw $t7, 8($t1)
		sw $t8, 256($t1)
		sw $t8, 260($t1)
		sw $t7, 264($t1)
		sw $t9, 268($t1)
		sw $t7, 512($t1)
		sw $t7, 516($t1)
		sw $t7, 520($t1)
		sw $t9, 524($t1)
		sw $t7, 768($t1)
		sw $t7, 772($t1)
		sw $t6, 776($t1)
		sw $t9, 780($t1)
		sw $t6, 1024($t1)
		
		jr $ra


draw_left_jump:
		sw $t7, 256($t1)
		sw $t7, 260($t1)
		sw $t7, 264($t1)
		sw $t8, 512($t1)
		sw $t8, 516($t1)
		sw $t7, 520($t1)
		sw $t9, 524($t1)
		sw $t7, 768($t1)
		sw $t7, 772($t1)
		sw $t7, 776($t1)
		sw $t9, 780($t1)
		sw $t6, 1024($t1)
		sw $t6, 1032($t1)
		
		jr $ra


draw_right_static:
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


draw_right_lleg:
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
		sw $t6, 772($t1)
		sw $t7, 776($t1)
		sw $t7, 780($t1)
		sw $t6, 1036($t1)
		
		jr $ra


draw_right_rleg:
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
		sw $t6, 780($t1)
		sw $t6, 1028($t1)
		
		jr $ra


draw_right_jump:
		sw $t7, 260($t1)
		sw $t7, 264($t1)
		sw $t7, 268($t1)
		sw $t9, 512($t1)			# Next row is 256 offset
		sw $t7, 516($t1)
		sw $t8, 520($t1)
		sw $t8, 524($t1)
		sw $t9, 768($t1)
		sw $t7, 772($t1)
		sw $t7, 776($t1)
		sw $t7, 780($t1)
		sw $t6, 1028($t1)
		sw $t6, 1036($t1)
		
		jr $ra