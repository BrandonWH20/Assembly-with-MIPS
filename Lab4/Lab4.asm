##########################################################################
# Created by: Holcombe, Brandon
# BHolcomb
# 15 Feb 2019
#
# Assignment: Lab 4 : ASCII Conversion
# CMPE 012, Computer Systems and Assembly Language
# UC Santa Cruz, Winter 2019
#
# Description: This program converts hex and binary to 2sc, adds the two numbers, then returns the result in base 4
#
# Notes: This program is intended to be run from the MARS IDE.
# Functionality
# The functionality of your program will be as follows:
#
# Read two 8-bit 2SC program arguments. 
# inputs are: [0x80, 0x7F] or [0b10000000, 0b01111111].
#
# Print the user inputs.
# Identify each number as hex or binary by looking at “0x” prefix for hex and “0b” prefix for 2SC binary.
#
# Convert the ASCII strings into two sign-extended integer values.
#
# a. Convert the first program argument to a 32-bit two’s complement number, stored in register $s1.
# b. Convert the second program argument to a 32-bit two’s complement number, stored in register $s2.
#
# Add the two integer values, store the sum in $s0.
#
# Print the sum as a signed base 4 number to the console. Do not print any leading 0s.
# a. If the number is negative, print a negative sign and the magnitude.
#
# b. If the number is positive, just print the magnitude.
#	
##########################################################################

#	REGISTER USAGE
# $t0 used for navigating arguments
# $t1 
# $t2 
# $t3 
# $t4 used as a counter for various sub routines
# $t5 
# $t6 used or result array

.data
result:  .space 5
sign:    .space 1
initial: .asciiz "You entered the numbers:\n"
sum:     .asciiz "\n\nThe sum in base 4 is: \n"

.text
# set variables used in loops to 0
li $t0, 0                    # First number
li $t1, 0                    # Second Number
li $t2, 0                    # used for holding remainder.
li $t3, 0   		     # used in hex conversion, with logical shifts. 
li $t4, 0                    # Used as a counter for various sub routines
li $t5, 0                    # holds count of hex conversotions already done. 

main:
	jal start
	
	jal type_Arg1        # determine type of arg 1, and convert
	move $s1, $t3        # move binary result to register s1
	jal reset_Registers
	
	jal type_Arg2        # determine type of Arg 2, and convert
	move $s2, $t3        # move binary result to register s2
	jal reset_Registers
	
	jal print_out        # print out first part of result. 
	jal add_em_up        # add the two 2sc numbers and store in s0
	jal print_Result
	
	j kill_It

# Properly exit function. 
kill_It:
	li $v0, 10
	syscall

reset_Registers:
	li $t4, 0
	li $t3, 0           
	li $t1, 0            
	li $t0, 0
		
return: 
	jr $ra

start:
        # initial text. given numbers
	li $v0, 4
	la $a0, initial
	syscall
	
        # Print input from arguments 
	li $v0, 4
	lw $a0, 0($a1) 	
	syscall
	
	# print a space
	li $v0 11
	la $a0 0x20
	syscall
	
	# print input from arguments
	li $v0, 4
	lw $a0, 4($a1)                    # print second argument
	syscall	
	jr $ra
	
type_Arg1:	                          # determine Type of first argument
	lw  $t0, ($a1)                    # load address of first argument
	add $t0, $t0, 1                   # get address of second char 
	lb  $t1, ($t0)                    # load value from that address 
	beq $t1, 0x78, convert_Hex
	nop
	beq $t1, 0x62, convert_Bin 
	nop
	jr $ra
	

type_Arg2:
	lw  $t0, 4($a1)                   # load address of second argument
	add $t0, $t0, 1
	lb  $t1, ($t0)
	beq $t1, 0x78, convert_Hex
	nop
	beq $t1, 0x62, convert_Bin
	nop
	jr  $ra
	
convert_Bin:
	#li  $t5, 0x8
	add $t0, $t0, 1                 # get the next binary number, moving towards the least sign bit
	lb  $t1, ($t0)                  # get value of that byte
	sub $t1, $t1, 48                # convert from ascii to actual value
	add $t3, $t3, $t1               # add either 1 or 0 to the new place
	beq  $t4, 7, finish_Bin
	nop
	sll  $t3, $t3, 1                # logical shift left 1. to open space for the next value. 
	add  $t4, $t4, 1                #  
	j   convert_Bin
	
finish_Bin:
	sll  $t3, $t3, 24
	sra  $t3, $t3, 24
	j return
	
	
convert_Hex: 
	add $t0, $t0, 1                # get most significant part of number. 
	lb  $t1, ($t0)
	bgt $t1, 62, sub55             # if first index is letter, subtract 55 to get actual value
	ble $t1, 60, sub48             # otherwise, subtract 48, to get actual value
	return_H:
	
	sll $t3, $t1, 4                # shift left 4 bits for next value. 
	lb  $t1, 1($t0)                # t1 was at the first char, move to second char
	bgt $t1, 62, sub55v2
	ble $t1, 60, sub48v2
	
	returnv2:
	add $t3, $t1, $t3              # add actual value.                            
	sll  $t3, $t3, 24              # logical left shift. 
	sra  $t3, $t3, 24              # right arithmetic shift, to complete sign extension
	jr   $ra
	
	sub55: 
	sub $t1, $t1, 55
	j return_H
	
	sub48:
	sub $t1, $t1, 48
	j return_H
	
	sub55v2: 
	sub $t1, $t1, 55
	j returnv2
	
	sub48v2:
	sub $t1, $t1, 48
	j returnv2	
	
	
twosc: 
	li  $v0, 11	          # since converting 2sc, print a "-" at the next line. 
	li  $a0, 0x2D             # hex for "-"
	syscall
	
	li  $t7, 0xffffffff       # load in a value of all 1's
	xor $s0, $s0, $t7  	  # invert all bits
	add $s0, $s0, 1	          # add 1
	j convert_b4

add_em_up:
	add $s0, $s1, $s2
	li $t6, 0x80000000
	and $t6, $s0, $t6
	beq $t6,0x80000000, twosc
	
	convert_b4:
	add $t1, $s0, $zero       # move answer to temporary register for converstion.
	li  $t3, 0                # reset t3 to 0
	li  $t2, 0                # reset t2 to 0
	
	convert:
	beqz $t1, return          # check if nothing left to divide. 
	div $t1, $t1, 4           # divide by 4
	sll $t3, $t3, 8
	mfhi $t2	          # take remainder place in t2
	add $t2,$t2, 48	          # change to ascii
	add $t3, $t3, $t2         # add remainder back in.  
	j convert                 
	
print_out:
	li $v0, 4
	la $a0, sum
	syscall
	jr $ra	
	
print_Result:
	beqz $s0 print_zero       # because we ignore all leading zero's, we should check for a zero value. 
	li $t6, 0                 # clear register t6
	la $t6, result            # put result arrray address in t6
	sw $t3, ($t6)             # put number into array 
	li $v0, 4
	la $a0, ($t6)
	syscall
	jr $ra

	print_zero: 
	li $v0 11
	li $a0 0x30
	syscall 
	jr $ra