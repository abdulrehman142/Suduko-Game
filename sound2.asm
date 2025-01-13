[org 0x0100]

jmp start

musical_Score: dw 262, 294, 330, 349, 392, 440, 494, 523, 587, 659, 698, 784
           dw 262, 294, 330, 349, 392, 440, 494, 523, 587, 659, 698, 784
delay: push cx
push dx
mov dx, 10
l2:
mov cx,0xffff
l1: loop l1
dec dx
cmp dx, 0
jne l2
pop dx 
pop cx
ret

play_note:
    push ax         ; Save registers
    push bx
    push dx
    mov bx, [musical_Score + si] ; Access the divisor for the current note (using SI as index)
    call sound      ; Call the sound function to play the note using the divisor

    pop dx          ; Restore registers
    pop bx
    pop ax
    ret

; Sound function that sends the divisor to the PIT and enables the speaker
sound:
    ; Save current state of port 0x61 (speaker state)
    in al, 61h
    push ax         ; Save the AL value (mode of port 0x61)
    
    ; Enable the speaker and connect it to channel 2
    or al, 3h
    out 61h, al

    ; Set channel 2 (PIT)
    mov al, 0b6h    ; Select mode 3 (square wave) for channel 2
    out 43h, al

    ; Send the divisor to the PIT
    mov ax, bx      ; Load the divisor into AX
    out 42h, al     ; Send the LSB (lower byte)
    mov al, ah      ; Get the MSB (higher byte)
    out 42h, al     ; Send the MSB (higher byte)

	call delay

    ; Restore the previous state of port 0x61
    pop ax;restore Speaker state
	out 61h, al
    ret

; Main loop to play a sequence of notes
start:
    mov si, 0       ; Start with the first note in the array (C4)
play_loop:
    call play_note  ; Play the current note
    add si, 2        ; Move to the next note in the array
    cmp si, 32	; Check if we've reached the end of the array (B4 is the 7th note)
	jne play_loop
    mov si, 0   ; Loop until all notes have been played
; jmp play_loop
    mov ax, 0x4c00  ; Terminate the program
    int 0x21