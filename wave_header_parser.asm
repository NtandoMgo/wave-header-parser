.data
    file_name_prompt: .asciiz "Enter a wave file name:\n"
    file_name: .space 50
    buffer: .space 44

    file_size_prompt: .asciiz "Enter the file size (in bytes):\n"

    output_prompt: .asciiz "Information about the wave file:\n================================\n"

    error_msg: .asciiz "Error: Could not open file.\n"
    db1: .asciiz "\nDiscriptor1: "
    db2: .asciiz "Number of channels: "
    db3: .asciiz "\nSample rate: "
    db4: .asciiz "\nByte rate: "
    db5: .asciiz "\nBits per sample: "
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
    la $a0, output_prompt
    syscall

    # li $v0, 1
    # move $a0, $t1
    # syscall
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

# Extract number of channels (2 bytes) from address 22-24 in the buffer
get_numOfChannels:
    la $t2, buffer      # Load buffer address into $t2
    #addi $t2, $t2, 22   # Move to the 22nd byte (number of channels)

    #lb $t3, 22($t2)      # Load the 2-byte halfword (number of channels) from address 22-23
    lb $t3, 22($t2)         # load 1 byte at adress 22 of number of channels
    lb $t4, 23($t2)         # load 1 byte at adress 23 the rest of number of channels

    # Combine the 2 bytes into 1 16-bit value (num of channels)
    sll $t4, $t4, 8     # shifts $t4 (the higher byte) 8 bits to the left
    or $t3, $t3, $t4    #combine the lower and higher bytes

    move $t7, $t3       # keep num of channels for byte rate calc
###########################
    li $v0, 4
    la $a0, db2
    syscall
###########################
    # Print the number of channels
    li $v0, 1           # syscall for printing an integer
    move $a0, $t3       # Move number of channels to $a0
    syscall

    #jal get_bitsPerSample

#Extract sample rate from bytes 24-27 (4 bytes), little indian format
get_sampleRate:
    lb $t3, 24($t2)
    lb $t4, 25($t2)
    lb $t5, 26($t2)
    lb $t6, 27($t2)

    #combine the 4 bytes to 32 bits val
    sll $t4, $t4, 8         #shift byte 25 by 8 bits
    sll $t5, $t5, 16        # shifts byte 26 by 16 bits
    sll $t6, $t6, 24        # shifts byte 27 by 24 bits

    or $t3, $t3, $t4        # combine 24 with 25
    or $t3, $t3, $t5        # combine 24 and 25 with 26
    or $t3, $t3, $t6        # combine 24, 25 and 26 with 27

    mul $t7, $t7, $t3       # t7 = t7 * t3      numOfChan * samplerate
print_sampleRate:
    li $v0, 4
    la $a0, db3
    syscall

    li $v0, 1
    move $a0, $t3
    syscall

#Calculate byte rate: br = sr*noOfChan*bps
get_byteRate:
    #addi $t2, $t2, 28       #move to the 28th byte

    mul $t7, $t7, $t3       #   product of numOfChan(t7) * samplerate times the bps (t3)

    #print byte rate
    li $v0, 4
    la $a0, db4
    syscall

    li $v0, 1
    move $a0, $t7
    syscall

    jr $ra

#extract bits per sample from address 34-35 (2 bytes)
get_bitsPerSample:
    addi $t2, $t2, 34   #move to 34th byte

    lb $t3, 0($t2)
    lb $t4, 1($t2)

    sll $t4, $t4, 8
    or $t3, $t3, $t4

    addi $t2, $t2, -34

    jal get_byteRate

    li $v0, 4
    la $a0, db5
    syscall

    li $v0, 1
    move $a0, $t3
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