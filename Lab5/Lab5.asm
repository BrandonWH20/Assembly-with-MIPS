##########################################################################
# Created by: Holcombe, Brandon
# BHolcomb
# 15 March 2019
#
# Assignment: Lab 5 : Subroutines
# CMPE 012, Computer Systems and Assembly Language
# UC Santa Cruz, Winter 2019
#
# Description: This program encrypts or decrypts strings using the given key. 
#
##########################################################################


.data 

string:         .align 2 
	        .space 100
	
result:         .align 2 
	        .space 100
	
key:            .align 2 
	        .space 100
	
choice:         .align 2
	        .space 1

segment:        .align 2
                .asciiz  "\nHere is the encrypted and decrypted string"

encrypt_String: .asciiz  "\n<Encrypted> "

decrypt_String: .asciiz  "<Decrypted> "


bad_input:      .asciiz "Invalid input: Please input E, D, or X. "


.text

return: #jumps to return address
jr $ra

give_prompt:
#-------------------------------------------------------------------- 
# give_prompt 
# 
# This function should print the string in $a0 to the user, store the user’s input in 
# an array, and return the address of that array in $v0. Use the prompt number in $a1 
# to determine which array to store the user’s input in. Include error checking for 
# the first prompt to see if user input E, D, or X if not print error message and ask 
# again. 
# 
# arguments: $a0 - address of string prompt to be printed to user 
# $a1 - prompt number (0, 1, or 2) 
# n
# note: prompt 0: Do you want to (E)ncrypt, (D)ecrypt, or e(X)it? 
# prompt 1: What is the key? 
# prompt 2: What is the string? 
# 
# return: $v0 - address of the corresponding user input data 
#-------------------------------------------------------------------- 
	li $v0 4              # print prompt
	la $t3 ($a0)          # store address of prompt in temp register
	syscall               # so that it can be called in case of invalid choice
	
	beq $a1, 0, p0        #if prompt = 0, store user input as choice
	beq $a1, 1, p1        #if prompt = 1, store user input as the key
	beq $a1, 2, p2        #if prompt = 2, store user input as the string
	
	p0:
	li  $v0, 8
        la  $a0, choice
        li  $a1, 10
        syscall
        
        lb  $t5, 0($a0)
        
        la   $v0, choice
        beq  $t5, 0x45 return     # If choice is E return
        beq  $t5, 0x44 return     # if choice is D return
        beq  $t5, 0x58 return     # if choice is X return
        
        li   $v0, 4               # otherwise print bad input and prompt again
        la   $a0, bad_input
        syscall	
        la   $a0, ($t3)           # load original prompt address back into $a0
        li   $t3, 0               # Set $t3 to null for future use. 
        j give_prompt
	
	p1:                       # prompt for Key
	li $v0, 8
	la $a0, key
	li $a1, 100
	syscall
	
	la $v0 key
	j return

	p2:                       #prompt for String to encrypt/Decrypt
	li $v0, 8
	la $a0, string
	li $a1, 100
	syscall
	
	la $v0 string
	j return


cipher:
#-------------------------------------------------------------------- 
# cipher 
# 
# Calls compute_checksum and encrypt or decrypt depending on if the user input E or 
# D. The numerical key from compute_checksum is passed into either encrypt or decrypt 
# 
# note: this should call compute_checksum and then either encrypt or decrypt 
# 
# arguments: $a0 - address of E or D character 
# $a1 - address of key string 
# $a2 - address of user input string 
# 
# return: $v0 - address of resulting encrypted/decrypted string
#-------------------------------------------------------------------- 
sub  $sp, $sp, 4       # shift stack pointer
sw   $ra, 0($sp)       # store current return address

lb   $t0, ($a0)        # store E or D  or other address in temp0

la   $a0, key          # put key address in $a0 for checksum
li   $t4, 0            # set $t4 to 0
jal  compute_checksum

move $a1, $v0          # move checksum result to  $a1

lw    $ra, 0($sp)
add   $sp, $sp, 4

la   $t7, result       # load address of result, done regardless of chouce. 
beq  $t0, 0x45 encrypt_Start
beq  $t0, 0x44 decrypt_Start
j return


encrypt_Start:
lb   $a0, 0($a2)       # load char from string input
beq  $a0, 0x0, set_v0  # if char is null, return

sub  $sp, $sp, 4       # shift stack pointer
sw   $ra, 0($sp)       # store current return address
jal encrypt

sb   $v0, 0($t7)       # add encrpted char to result 
add  $t7, $t7, 1       # move to next char in result
add  $a2, $a2, 1       # move to next char in string

lw    $ra, 0($sp)      # restore return address
add   $sp, $sp, 4      # pop off from stack. 
j encrypt_Start

set_v0: 
la $v0, result 
j return


decrypt_Start:
lb   $a0, 0($a2)       # load char from string to  to $a0
beq  $a0, 0x0, set_v0  # if char is line feed, return

sub  $sp, $sp, 4       # shift stack pointer
sw   $ra, 0($sp)       # store current return address

jal decrypt
sb   $v0, 0($t7)           # move encrypted char to result
add  $t7, $t7, 1       # move to next char in result
add  $a2, $a2, 1       # move to next char in string

lw    $ra, 0($sp)      # restore return address
add   $sp, $sp, 4      # pop off from stack. 
j decrypt_Start
	

compute_checksum:
#-------------------------------------------------------------------- 
# compute_checksum 
# 
# Computes the checksum by xor’ing each character in the key together. Then, 
# use mod 26 in order to return a value between 0 and 25. 
# 
# arguments: $a0 - address of key string 
# 
# return: $v0 - numerical checksum result (value should be between 0 - 25) 
#--------------------------------------------------------------------
lb  $t2, ($a1)          #load char from $a1
beq $t2,  0xa   mod     #if char is null, return
xor $t4, $t4, $t2       #xor char with previous char. 
add $a1, $a1, 1         #move to next char
j compute_checksum

mod:                    #divide by 26, and move remainder from hi to $v0
div  $t4, $t4, 26
mfhi $v0
j return




encrypt:
#-------------------------------------------------------------------- 
# encrypt 
# 
# Uses a Caesar cipher to encrypt a character using the key returned from 
# compute_checksum. This function should call check_ascii. 
# 
# arguments: $a0 - character to encrypt 
# $a1 - checksum result 
# 
# return: $v0 - encrypted character 
#-------------------------------------------------------------------- 
sub  $sp, $sp, 4           # shift stack pointer
sw   $ra, 0($sp)           # store current return address
jal  check_ascii           # call to check if encrypting char

lw   $ra, 0($sp)           # restore return address
add  $sp, $sp, 4           # pop from stack

beq  $v0, -1, encrypt_n1   # if not a number, set $v0 to the char and return
add  $a0, $a0, $a1         # else add the checksum
beq  $v0, 1, encrypt_1     # if 1, lowercase
beqz $v0, encrypt_0        # if 0, uppercase

encrypt_n1:                # if negative 1, don't encrypt, just move to $v0
move $v0, $a0
j return

encrypt_0:
move $v0, $a0              # move char to v0
ble  $v0, 90,  return      # if char is still lowercase, return
sub  $v0, $v0, 26          # char must have overflowed, reduce by 26
j return

encrypt_1:
move $v0, $a0              # move char to v0
ble  $v0, 122, return      # if char is still uppercase, return
sub  $v0, $v0, 26          # char must have overflowed, reduce by 26
j return
 

decrypt:
#--------------------------------------------------------------------
# decrypt 
# 
# Uses a Caesar cipher to decrypt a character using the key returned from 
# compute_checksum. This function should call check_ascii. 
# 
# arguments: $a0 - character to decrypt 
# $a1 - checksum result 
# 
# return: $v0 - decrypted character 
#-------------------------------------------------------------------- 
sub  $sp, $sp, 4               # shift stack pointer
sw   $ra, 0($sp)               # store current return address
jal  check_ascii               # call to check if encrypting char

lw   $ra, 0($sp)               # restore return address
add  $sp, $sp, 4               # pop from stack

beq  $v0, -1, decrypt_n1       # if not a letter, set $v0 to the char and return
sub  $a0, $a0, $a1             # else subtract the checksum
beq  $v0, 1, decrypt_1         # if 1, lowercase
beqz $v0, decrypt_0            # if 0, uppercase

decrypt_n1:
move  $v0, $a0
j return

decrypt_0:
move $v0, $a0                  # move char to v0
bge  $v0, 65, return           # if char is still lowercase, return
add  $v0, $v0, 26              # char must have underflowed, increase by 26
j return

decrypt_1:
move $v0, $a0                  # move char to v0
bge  $v0, 97, return           # if char is still uppercase, return
add  $v0, $v0, 26              # char must have underflowed, increase by 26
j return

check_ascii:
#-------------------------------------------------------------------- 
# check_ascii # # This checks if a character is an uppercase letter, lowercase letter, or 
# not a letter at all. Returns 0, 1, or -1 for each case, respectively. 
# 
# arguments: $a0 - character to check 
# 
# return: $v0 - 0 if uppercase, 1 if lowercase, -1 if not letter
#-------------------------------------------------------------------- 
ble  $a0, 64,  set_n1  # if less then 65 not a char
ble  $a0, 90,  set_0   # if char is 65-90, must be uppercase
ble  $a0, 96,  set_n1  # if char is 91-96, not a char
ble  $a0, 122, set_1   # if char is 97-122, lowercase


set_n1: li $v0, -1     # not a char
j return

set_0:  li $v0, 0      # char is uppercase
j return

set_1:  li $v0, 1      # char is lowercase
j return

print_strings:
#-------------------------------------------------------------------- 
# print_strings 
#
# Determines if user input is the encrypted or decrypted string in order 
# to print accordingly. Prints encrypted string and decrypted string. See 
# example output for more detail. 
# 
# arguments: $a0 - address of user input string to be printed 
# $a1 - address of resulting encrypted/decrypted string to be printed
# $a2 - address of E or D character # 
# return: prints to console
#--------------------------------------------------------------------

li  $v0, 4                      # Print out "Here is...." 
la  $a0, segment
syscall

lb $t2 ($a2)                    # load in user choice

beq $t2, 0x45, encrypted        # if E, we encrypted
beq $t2, 0x44, decrypted        # if D, we decrypted
j return                        # must have bad input

encrypted:                      
li $v0, 4
la $a0, encrypt_String          # print <Encrypted>
syscall

la $a0, result                  # print the encrypted string
syscall

la $a0, decrypt_String          # print <Decrypted>
syscall
la $a0, string                  # print the original string given
syscall

j wipe_strings                  # call to wipe strings from memory

decrypted: 
li $v0, 4
la $a0, encrypt_String          # print <Encrypted>
syscall

la $a0, string                  # print original string given
syscall

la $a0, decrypt_String          # print <Decrypted>
syscall
la $a0, result                  # print the decrypted string
syscall

j wipe_strings                  # call to wipe strings from memory

wipe_strings:                   #Wipes Strings and registers, if user call to encrypt or decrypt 
la $t1, string
la $t2, result
la $t3, choice

li $t0, 0
li $t4, 0
li $t5, 0
li $t6, 0
li $t7, 0
j wipe

wipe:                          # loop through strings bit by bit.
beq $t4, 99, return
sb $zero, ($t1)
sb $zero, ($t2)
sb $zero, ($t3)
add $t1, $t1, 1
add $t2, $t2, 1
add $t4, $t4, 1
j wipe