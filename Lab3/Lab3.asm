##########################################################################
# Created by: Holcombe, Brandon
# BHolcomb
# 15 Feb 2019
#
# Assignment: Lab 3 : MIPS Looping ASCII Art
# CMPE 012, Computer Systems and Assembly Language
# UC Santa Cruz, Winter 2019
#
# Description: This program prints draws triangles based on the values specifies by the user, to the screen.
#
# Notes: This program is intended to be run from the MARS IDE.
##########################################################################

#	REGISTER USAGE
# $t0 stores number of triangles to print
# $t1 stores number of legs in each triangle. 
# $t2 counts number of triangles printed
# $t3 counts number of '\' legs printed in current triangle. 
# $t5 counts number of spaces that have been printed on the line. 


.data
promptL: .asciiz "Enter the length of one of the triangle legs: "
promptT: .asciiz "Enter the number of triangles to print: "


.text
#set variables used in loops to 0
li $t0, 0                   #triangles to print
li $t1, 0                   #legs to printer per triangle
li $t2, 0                   #number of triangles printed
li $t3, 0                   #number of legs printed on current triangle
li $t5, 0                   #of spaces printed. 

        #Prompt for number of legs per side of each triangle. 
	li $v0, 4
	la $a0, promptL
	syscall

        #Take input of legs. 
	li $v0, 5
	syscall
	move $t1,$v0           #Move to a saved variable
	
	#Prompt for Triangles
	li $v0, 4
	la $a0, promptT
	syscall
	
	#Take input of # of Triangles
	li $v0, 5
	syscall	
	move $t0,$v0            #Move to variable s1
	j triangle_Count_Loop


#for Loop based on the amount of triangles. 
triangle_Count_Loop:
	beq $t0, $t2, kill_It   #if (triangles to print = triangles printed.) kill the program.
	
	#print "\n"             #will create a new line for each triangle, WILL NOT CREATE ONE AFTER LAST TRIANGLE
	li $v0 11
	la $a0 0x0a
	syscall
	
	add $t2, $t2, 1         #Increment counter by 1 
	jal build_It_Up         #build top half of the triangle.
	j triangle_Count_Loop   #return to top loop
	
	

#determines number of spaces to print on the line. 
space_It_Out:
	beq  $t3, $t5, return      #if spaces to print is = legs printed, return to function that called it.  
	
	#print " "
	li $v0, 11
	la $a0, 0x20
	syscall
	
	add  $t5, $t5,1             #Increment spaces printed by 1
	j space_It_Out              #return to the top of the function. 
	
	
#used in conditional statemtents to go to return address, also resets space counter. 
return: 
	li $t5,0                    #reset space counter
	jr $ra
	
	
#creates top half of the triangle. 
build_It_Up:                             
	beq $t3, $t1, break_It_Down  	 #if (legs to print = legs printed.) begin building bottom. 
	
	jal space_It_Out                 #call to calculate spaces.
	jal print_Back                   #print backslash
	add $t3, $t3, 1                  #increment legs printed by 1
	j build_It_Up
	
break_It_Down: 
	beqz $t3, triangle_Count_Loop
	
	#build lower half of the triangle.
	sub $t3, $t3, 1          #de-increment leg counter by 1
	jal space_It_Out         #call to space from break
	jal print_Forward        #print forward slash
	j break_It_Down          #jump to top. 
	
	
#Properly exit function. 
kill_It:
	li $v0, 10
	syscall

#prints backslash and EOL
print_Back:	
	#print "\"
	li $v0 11
	la $a0 0x5C 
	syscall 
	
	
	#print "\n"
	li $v0 11
	la $a0 0x0a
	syscall 
	
	jr $ra
	
#prints forward slash and EOL unless its the last leg of the triangle. 		
print_Forward:	
	#print "/"
	li $v0 11
	la $a0 0x2F
	syscall 
	
	beqz $t3, return #if this is the last forward slash, do not print EOL, go to return address.
	 
	#print "\n"
	li $v0 11
	la $a0 0x0a
	
	syscall 
	jr $ra