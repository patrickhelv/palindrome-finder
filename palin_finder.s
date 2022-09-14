.global _start // This marks the symbol at which execution starts (entrypoint)


.section .text
	// The text section is the code section containing the instructions
	// that are executed on the processor

count: //loop that counts amount of char in input
	LDR R0, =input //takes in input
	MOV R3, #0
	LDR R8, =0xFF200000 //address of led
	MOV R2, #0
	STR R2, [R8] // reset led
	loop:
		LDRB R2, [R0, R3] //loads the first char
		CMP R2, #0 //if at the end of the arry go to end
		BEQ analyse		
		ADD R3, R3, #1 // or add 1 and go back to loop
		b loop


add_i:
	ADD R5, R5, #1 // i = i + 1
	LDRB R2, [R0, R5] //load input[i]
	b if_i_space_return

sub_j:
	SUB R4, R4, #1 // j = j + 1
	LDRB R6, [R0, R4] //load input[j]
	b if_j_space_return

if_statement_i:
	SUB R2, R2, #0x20 //add 32 to input[i]
	CMP R2, R6 // compare input[i] + 32 == input[j]
	BEQ update_index
	b light_error
	
update_index:
	ADD R5, R5, #1 // i = i + 1
	SUB R4, R4, #1 // j = j - 1
	b main_loop
	
equal_condition:
	CMP R2, R6 //if input[i] == input[j]
	BNE light_error //if not go not palindrome
	ADD R5, R5, #1 // i = i + 1
	SUB R4, R4, #1 // j = j - 1
	b main_loop //go back to loop if right

condition:
	CMP R2, #0x60 // if input[i] > 96
	BGT equal_condition //go to equal condition
	b out //goes back to out

if_statement_j:
	SUB R6, R6, #0x20 //add 32 to input[j]
	CMP R2, R6 // compare input[j] + 32 == input[i]
	BEQ update_index //update 
	b light_error
	
analyse:
	CMP R3, #2 //if less than 2 characters not a palindrome
	BLT light_error
	SUB R4, R3, #1 //j
	MOV R5, #0 //i
	
	main_loop:
		LDRB R2, [R0, R5] //load input[i] 
		LDRB R6, [R0, R4] //load input[j]
		CMP R5, R4 //MAYBE R3 - 1, while loop from i to lenght of input
		BGE light_sucsess
		
		CMP R2, #0x20 //check space
		BEQ add_i //if space add i = i + 1
		if_i_space_return:

			CMP R6, #0x20 //check space
			BEQ sub_j // if space sub j = j - 1
			
			if_j_space_return:
			
				CMP R6, #0x60//compare if input[j] > 96
				BGT condition
				
				out:

					CMP R6, #0x60 //compare if input[j] > 96
					BGT if_statement_j //if yes
					
					CMP R2, #0x60 //compare if input[i] > 96
					BGT if_statement_i //if yes

					CMP R2, R6 //if input[i] == input[j]
					BNE light_error

					ADD R5, R5, #1 // i = i + 1
					SUB R4, R4, #1 // j = j - 1
					b main_loop //go back to main loop
		
_start:
	bl count //sends you to count 
	b exit //exit program
	
light_sucsess:
	LDR R8, =0xFF200000 //address of led
	LDR R2, =0x1F //loads value in R2
	STR R2, [R8] // store the same value in R8
	b print
	
light_error:
	LDR R8, =0xFF200000 //address of led
	LDR R2, =0xFE0 //loads value in R2
	STR R2, [R8] // store the same value in R8
	b print_error

print_error:
//loop trough and print each char in error
	LDR R8, =0xFF201000 // loads the address of JTAG UART
	LDR R2, =error //loads error string
	MOV R5, #0 
	print_loop1:
		LDRB R6, [R2, R5] //loads first char
		CMP R6, #0 //if not end of array continue
		BEQ exit //else exit
		STR R6, [R8] //stores the first char in R8
		ADD R5, R5, #1 //i = i + 1 to go to next char
		b print_loop1

print:
	LDR R8, =0xFF201000 //load adress of JTAG UART
	LDR R2, =message //load message
	MOV R5, #0 
	print_loop2:
		LDRB R6, [R2, R5] //load first char
		CMP R6, #0 // if not end of array continue
		BEQ exit // else exit
		STR R6, [R8] //stores first char in R8
		ADD R5, R5, #1 // i = i + 1 go to next char
		b print_loop2

exit:
	b exit // Branch to iteself (exit of programm)

.section .data
.align
	//input: .asciz "Wasit a car or a cat I saw"
	//input: .asciz "level"
	// input: .asciz "8448"
    // input: .asciz "KayAk"
    // input: .asciz "step on no pets"
    input: .asciz "Never odd or even"
	//input: .asciz "Palindrome"
	error: .asciz "Not a palindrome "
	message: .asciz "Palindrome detected "
	// This section is evaluated before execution to put things into
	// memory that are required for the execution of your application

	
.end