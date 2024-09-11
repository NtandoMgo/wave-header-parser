.data
    file_name_prompt: .asciiz "Enter a wave file name:\n"
    file_name: .space 50
    buffer: .space 132344

    file_size_prompt: .asciiz "Enter the file size (in bytes):\n"

    output_prompt: .asciiz "Information about the wave file:\n"
    out_lines: .asciiz "================================\n"

    error_msg: .asciiz "Error: Could not open file.\n"

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
    move $a2, $t0       #number of bytes to read
    syscall

see_data_from_file:
    li $v0, 4
    la $a0, buffer
    syscall

close_file:
    li $v0, 16
    move $a0, $t1
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
    sb $t2, 0($a0)      #now replacing newline with null terminator

end_remove_newline:
    jr $ra          # jump to $ra - return to line 29

exit:
    li $v0, 10
    syscall