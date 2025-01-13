[org 0x0100]

jmp startSound

; Winning sound melody for Sudoku completion (short and popping)
melody: 
    dw 800, 900, 1000, 1100, 1200, 1300, 1400, 1500 ; Ascending victory tones
    dw 1500, 1400, 1300, 1200, 1100, 1000, 900, 800 ; Descending back for effect

tempo: dw 2       ; Faster tempo for a short, snappy sound

delay:
    push cx
    push dx
    mov dx, [tempo] ; Use tempo for dynamic delay control
l2:
    mov cx, 0xafff ; Reduced loop for shorter delay
l1: 
    loop l1
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
    mov bx, [melody + si] ; Access the divisor for the current note
    call sound      ; Call the sound function to play the note

    pop dx          ; Restore registers
    pop bx
    pop ax
    ret

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

    call delay      ; Play the sound for a duration based on delay

    ; Restore the previous state of port 0x61
    pop ax          ; Restore speaker state
    out 61h, al
    ret

playCompletionSound:
pushA
      mov si, 0       ; Start with the first note in the array
    mov cx, 16      ; Number of notes in the melody
play_loop:
    call play_note  ; Play the current note
    add si, 2       ; Move to the next note
    loop play_loop  ; Repeat until all notes are played


popA
ret

startSound:
    
;     mov si, 0       ; Start with the first note in the array
;     mov cx, 16      ; Number of notes in the melody
; play_loop:
;     call play_note  ; Play the current note
;     add si, 2       ; Move to the next note
;     loop play_loop  ; Repeat until all notes are played

;     ; mov ax, 0x4c00  ; Terminate program
    ; int 0x21