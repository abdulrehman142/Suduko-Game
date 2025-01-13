[org 0x0100]
jmp startMainScreen

modeSelection: db 0, 0

hookCustomISRINT9ForMainScreen:
push ax
push es

    mov byte [modeSelection], 0

cli 

    xor ax, ax
    mov es, ax
    mov word [es:9 * 4], CustomISRINT9ForMainScreen
    mov word [es:9 * 4 + 2], cs

sti
pop es
pop ax
ret

Bracketsvalue: db 0xae, 0xaf
currentSelection: db 0

CustomISRINT9ForDifficultySelection:
    pushA

        mov bx, 0xb800

    popA
ret

CustomISRINT9ForMainScreen:
    pushA
        mov bx, 0xb800
        mov es, bx

        in al, 0x60
        cmp al, 0x48                ; up
        jnz checkDownForMainScreen

            mov word[es:2948], 0x8FAF 
            mov word[es:2970], 0x8FAE
            mov word[es:3272], 0x0F20
            mov word[es:3282], 0x0F20
            mov byte [currentSelection], 0

        checkDownForMainScreen:
            cmp al, 0x50            ; down
            jnz checkEnterKey

                mov word[es:2948], 0x0F20
                mov word[es:2970], 0x0F20
                mov word[es:3272], 0x8FAF
                mov word[es:3282], 0x8FAE
                mov byte [currentSelection], 1

            checkEnterKey:
                cmp al, 0x1c
                jnz exitMainScreenSelection

                    mov al, [currentSelection]
                    inc al
                    mov [modeSelection], al

            exitMainScreenSelection:
        mov al, 0x20
        out 0x20, al
    popA
iret

changeCurrentDifficultySelection:
pushA

    mov bx, 0xb800
    mov es, bx
    mov si, pixelsForDifficulty
    mov cx, 3

    loopingDifficultyCursor:
    mov di, [si]
    mov word [es:di], 0x0720
    add si, 2
    mov di, [si]
    mov word [es:di], 0x0720
    add si, 2 
    loop loopingDifficultyCursor

    xor bx, bx
    mov bl, [currentSelection]
    add bl, bl
    add bl, bl
    mov di, [pixelsForDifficulty + bx]
    mov word [es:di], 0x8faf
    mov di, [pixelsForDifficulty + bx + 2]
    mov word [es:di], 0x8fae


popA
ret

pixelsForDifficulty: dw 3112, 3122, 3270, 3284, 3432, 3442

hookKeyBoardISRDifficultySelection: 
push ax
push es

    mov word [ValueFromDifficulty], 50

cli 

    xor ax, ax
    mov es, ax
    mov word [es:9 * 4], KeyBoardISRDifficultySelection
    mov word [es:9 * 4 + 2], cs

sti
pop es
pop ax
ret

KeyBoardISRDifficultySelection:
pushA

    mov bx, 0xb800
    mov es, bx

    in al, 0x60
    cmp al, 0x48                ; up
    jnz checkDownForDifficultyScreen

        cmp byte [currentSelection], 0
        jz exitDifficultyScreenSelection
            add word [ValueFromDifficulty], 10
            dec byte [currentSelection]
            call changeCurrentDifficultySelection

    checkDownForDifficultyScreen:
        cmp al, 0x50            ; down
        jnz checkEnterKeyForDifficultyScreen

            cmp byte [currentSelection], 2
            jz exitDifficultyScreenSelection
                sub word [ValueFromDifficulty], 10
                inc byte [currentSelection]
                call changeCurrentDifficultySelection

        checkEnterKeyForDifficultyScreen:
            cmp al, 0x1c
            jnz exitDifficultyScreenSelection

                mov al, [currentSelection]
                inc al
                mov [modeSelection], al


        exitDifficultyScreenSelection:
    mov al, 0x20
    out 0x20, al


popA
iret

startMainScreen: