.code16
.att_syntax prefix
.text
.globl _start

_start:
    movb $0b10000000, %al       # AL holds 8-bit control word sent to 8255
    movw $0x643, %dx            # DX holds 8255 Control Register address
    outb %al, %dx               # Configure Port A & Port B as Mode 0 outputs
    
    movw $7, %si                # Start leftmost digit (digit-7)
    movw $-1, %bp               # starting point: -1 

frame_loop:
    movw $150, %di
    
refresh_loop:
    movb $0b01101101, %bl       # BL, segment pattern for 'S' (0x6D)
    movw %si, %cx              
    call show_char              # Lights up 'S' at digit [CX]
    
    movb $0b01110110, %bl       # BL, segment pattern for 'H' (0x76)
    movw %si, %cx               
    decw %cx                    
    call show_char              # Lights up 'H' at digit [CX]

    movb $0b01111001, %bl       # BL, segment pattern for 'E' (0x79)
    movw %si, %cx              
    subw $2, %cx              
    call show_char              # Lights up 'E' at digit [CX]

    # repeats this process, until DI reaches 0
    decw %di                    # Decrement refresh counter DI
    jnz refresh_loop            # Keep refreshing current "SHE" position
    
    addw %bp, %si               # Moves 'S' position

    cmpw $2, %si                # Checks if 'E' reached rightmost digit 0?
    je reverse_to_left          # If SI == 2, reverse direction to +1 (move left)

    cmpw $7, %si                # Checks if 'S' reached leftmost digit 7?
    je reverse_to_right         # If SI == 7, reverse direction to -1 (move right)

    jmp frame_loop              # Otherwise continues moving in current direction

reverse_to_left:
    movw $1, %bp                # Set direction BP = +1 (scroll left toward dig-7)
    jmp frame_loop

reverse_to_right:
    movw $-1, %bp               # Set direction BP = -1 (scroll right toward dig-0)
    jmp frame_loop


show_char:
    # Turns off all digits on port A
    movb $0x00, %al             # All Port A digit transistors OFF
    movw $0x640, %dx            
    outb %al, %dx               # Clears all digits before changing segments

    # Send 7-segment pattern to port B
    movb %bl, %al               
    movw $0x641, %dx            
    outb %al, %dx               # Moves segment transistors on Port B

    # Enables the specified digit on port A
    movb $0b00000001, %al       # Start with bit 0 
    shlb %cl, %al               
    movw $0x640, %dx           
    outb %al, %dx               # Turns ON specificed digit transistor on Port A

    # Creates a short delay for visibility
    movw $250, %cx              # Delay loop count
    
delay_loop:
    nop                         # Hold digit lit
    loop delay_loop             # Decrement CX until delay finishes

    ret                         # Return to refresh_loop
