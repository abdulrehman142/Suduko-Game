[org 0x0100]

jmp startStarting

drawStarting:
    pushA

    mov si, StringStart
    call findlength1
    mov di, 2950
    
    mov ax, 0xb800
    mov es, ax
    mov ah, 00001111b

    loopingPrintingStart:
    mov al, [si]
    inc si
    mov word [es:di], ax
    add di, 2
    loop loopingPrintingStart
    ;==================================;
    mov ah, 10001111b
    mov al, 174
    mov word [es:di], ax
    mov di, 2948
    mov al, 175
    mov word [es:di], ax
    ;==================================;

    mov si, StringQuit
    call findlength1
    mov di, 3280
    sub di, cx
    sub di, 2

    mov ah, 00001111b
    loopingPrintingQuit:
    mov al, [si]
    inc si
    mov word [es:di], ax
    add di, 2
    loop loopingPrintingQuit
 

    popA
ret

drawDifficultyScreen:
    pushA

        mov byte [modeSelection], 0

        mov ax, 0xb800
        mov es, ax
        mov di, 2948
        mov ax, 0x0720
        mov cx, 12

        clearStartGameIcon:
            mov word [es: di], ax
            add di, 2
            loop clearStartGameIcon

        mov di, 3272
        mov cx, 12
        
        clearQuitGameIcon:
            mov word [es:di], ax
            add di, 2
            loop clearQuitGameIcon

        ; priting from here the difficulty levels

        mov si, topOfBoardEasy
        mov di, 3114
        mov cx, 4
        mov ah, 0x0F
        call justSomeRandomPrintFunction

        mov si, topOfBoardMedium
        mov di, 3272
        mov cx, 6

        call justSomeRandomPrintFunction


        mov si, topOfBoardHard
        mov di, 160 * 21 + 80 - 6
        mov cx, 4
        call justSomeRandomPrintFunction

    popA
ret

justSomeRandomPrintFunction:
        loopingjustSomeRandomPrintFunction:
            mov al, [si]
            mov word [es:di], ax
            inc si
            add di, 2
        loop loopingjustSomeRandomPrintFunction

ret

startStarting:
    ; mov ax, 0
    ; int 16h
    
    ; mov ax, 0x4c00
    ; int 21h