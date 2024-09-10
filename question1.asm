.data
    file_name_prompt: .asciiz "Enter a wave file name:\n"
    file_name: .space 50
    buffer: .space 1024
    file_size_prompt: .asciiz "Enter the file size (in bytes):\n"
    output_promt: .asciiz "Information about the wave file:\n"
    out_lines: .asciiz "================================\n"

    # input_test_prompt: .asciiz "The name and size you entered:\n"
    # new_line: .asciiz "\n"

    error_msg: .asciiz "Error: Could not open file.\n"

.text
main:
    # printing "Enter a wave file name:"
    li $v0, 4
    la $a0, file_name_prompt
    syscall

    # reading file name as String, will be in $a0
    li $v0, 8
    la $a0, file_name       # the file name will be stored here in $a0
    la $a1, 50              # read maximum of 5 chars
    syscall

    # printing "Enter the file size (in bytes):"
    li $v0, 4
    la $a0, file_size_prompt
    syscall

    # reading file size as an int, will be in $v0
    li $v0, 5
    syscall

    move $t0, $v0   # avoiding to lose data-integer read, 
                    # since I would like to print for testing as well
                     
    jal open_file

open_file:
    li $v0, 13  # Service code to open the file
    la $a0, file_name   # get file name
    li $a1, 0           # flag, indicating we read the file !(write)
    li $a2, 0           # mode: default
    syscall
    move $t1, $v0       # store file descriptor in $t1

    # Check if file opened correctly
    bgez $t1, read_file  # if file descriptor >= 0, then read the file

    # Error handling: file could not be opened
    li $v0, 4
    la $a0, error_msg
    syscall

    j exit



read_file:
    li $v0, 14  # Service code to read the file
    move $a0, $t1   # File descriptor
    la $a1, buffer   # buffer, holds the string of the whole file
    move $a2, $t0   # number of bytes to read
    syscall

see_data:
    # print the file/data read (for debugging)
    li $v0, 4
    la $a0, buffer
    syscall

    # close the file
    li $v0, 16
    move $a0, $t1   # file to close-file descriptor

# input_test:
    # print the read data for verification
    # output prompt first
    # li $v0, 4
    # la $a0, input_test_prompt
    # syscall

    # li $v0, 4   # output file name
    # la $a0, file_name
    # syscall

    # # li $v0, 4
    # # la $a0, new_line    #printing newline
    # # syscall

    # # now printing the size - integer
    # li $v0, 1
    # move $a0, $t0
    # syscall

    # li $v0, 10
    # syscall


   # Exit the program

exit:
    li $v0, 10   # service code for exit
    syscall