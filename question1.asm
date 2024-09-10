.data
    file_name_prompt: .asciiz "Enter a wave file name:\n"
    file_name: .space 50
    file_size_prompt: .asciiz "Enter the file size (in bytes):\n"
    output_promt: .asciiz "Information about the wave file:\n"

    input_test_prompt: .asciiz "The name and size you entered:\n"
    new_line: .asciiz "\n"

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

    # print the read data for verification
    # # output prompt first
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

    li $v0, 10
    syscall