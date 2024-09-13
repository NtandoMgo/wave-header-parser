.data
    file_name_prompt: .asciiz "Enter a wave file name:\n"
    file_name: .space 50
    buffer: .space 44

    file_size_prompt: .asciiz "Enter the file size (in bytes):\n"

    output_prompt: .asciiz "Information about the wave file:\n"
    out_lines: .asciiz "================================\n"

    error_msg: .asciiz "Error: Could not open file.\n"
    db1: .asciiz "\n1: "
    db2: .asciiz "\n2: "
    db3: .asciiz "\n3: "
.text
main:
    #asking for a wave file name/path
    li $v0, 4
    la $a0, file_name_prompt
    syscall

    #reading a string - file name
    li $v0, 8
    la $a0, file_name
    li $a1, 50
    syscall

    #remove newline '\n' char from file name
    jal remove_newline

    #primpt the user to enter the file size
    li $v0, 4
    la $a0, file_size_prompt
    syscall

    #read the integer - file size
    li $v0, 5
    syscall     #input stored in $v0

    move $t0, $v0   #free $v0, keep the size for later use

    jal open_file

open_file:      #open file to read
    li $v0, 13
    la $a0, file_name       #get the file name-without the newline
    li $a1, 0           #flag = reading the file, not writing
    li $a2, 0           #mode: default - the default mode is 'r':read
    syscall         #file descriptor will be storeed in $v0, code indicating whether opening was successful
    move $t1, $v0   #free $v0, keep file descriptor for later use

 ##################################3   
    li $v0, 4
    la $a0, db1
    syscall

    li $v0, 1
    move $a0, $t1
    syscall
 ###################################   
    #check if the fole open was succeffull
    bgez $t1, read_file     #if $t1 >= 0, then read the file else continue

    #Error: file could not be opened, $t1 < 0
    li $v0, 4
    la $a0, error_msg
    syscall

    j exit

read_file:
    li $v0, 14
    #la $a0, file_name
    move $a0, $t1       #file descritpor
    la $a1, buffer      #holds the string of the entire file
    li $a2, 44       #number of bytes to read
    syscall

    close_file:
    li $v0, 16
    move $a0, $t1
    syscall

##########################
    li $v0, 4
    la $a0, db2
    syscall

    li $v0, 1
    move $a0, $v0
    syscall
############################
    # Extract number of channels (2 bytes) from address 22-24 in the buffer
    la $t2, buffer      # Load buffer address into $t2
    #addi $t2, $t2, 22   # Move to the 22nd byte (number of channels)

    lw $t3, 24($t2)      # Load the 2-byte halfword (number of channels) from address 22-23
###########################
    li $v0, 4
    la $a0, db3
    syscall
###########################
    # Print the number of channels
    li $v0, 1           # syscall for printing an integer
    move $a0, $t3       # Move number of channels to $a0
    syscall


    j exit

remove_newline:
    la $a0, file_name
    li $t2, 0

find_newline:   #looping thre the string char by char to find '\n'
    lb $t1, 0($a0)                  #load byte @current location - character
    beqz $t1, end_remove_newline    #base case, if $t1 == 0 - null terminator
    beq $t1, 0x0A, remove_it        #if newline, remove it
    addi $a0, $a0, 1                # increment index (address) to fetch/load next char - byte
    j find_newline                  #recursive, call find again-jump to find label again


remove_it:
    sb $zero,0($a0)      #now replacing newline with null terminator

end_remove_newline:
    jr $ra          # jump to $ra - return to line 29

exit:
    li $v0, 10
    syscall