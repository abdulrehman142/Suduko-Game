[org 0x0100]
jmp startScore

RowCompletion:      ; will pass dx -- row/col
    push dx
    push si


        mov dl, 0
    loopingRowCompletionCheckInScore:
        mov si, NumbersUserCantEditForRow1
        call returnValueFromBoard

        cmp ax, 0
        jz RowIsNotCompleteInScore

        inc dl
        cmp dl, 9
        jnz loopingRowCompletionCheckInScore

        mov ax, 1

        call playCompletionSound


        jmp exitRowCompletionInScore

    RowIsNotCompleteInScore:
        mov ax, 0

    exitRowCompletionInScore:

    pop si
    pop dx
ret

ColCompletion:      ; will pass dx -- row/col
    push dx
    push si


        mov dh, 0
    loopingColCompletionCheck:
        mov si, NumbersUserCantEditForRow1
        call returnValueFromBoard

        cmp ax, 0
        jz ColIsNotComplete

        inc dh
        cmp dh, 9
        jnz loopingColCompletionCheck

        mov ax, 1

        call playCompletionSound

        jmp exitColCompletion

    ColIsNotComplete:
        mov ax, 0

    exitColCompletion:


    pop si
    pop dx
ret

Box3x3Completion:
push dx
push si
push cx

        mov bx, dx
        xor ax, ax
        xor dx, dx
        mov al, bl

        mov di, 3
        div di
        mov dx, 0
        mul di

        mov cl, al

        mov al, bh
        div di
        mov dx, 0
        mul di
        mov ch, al

        mov bx, cx
        mov dx, cx
        add bl, 3
        add bh, 3


    loopingBoxCompletionCheck:
        mov si, NumbersUserCantEditForRow1
        call returnValueFromBoard

        cmp ax, 0
        jz BoxisNotComplete

            inc dl
            cmp dl, bl
            jnz loopingBoxCompletionCheck

                inc dh
                sub dl, 3
                cmp dh, bh
                jnz loopingBoxCompletionCheck

        mov ax, 1

        call playCompletionSound

        jmp exitBoxCompletionCheck

    BoxisNotComplete:
        mov ax, 0

    exitBoxCompletionCheck:

pop cx
pop si
pop dx
ret

ScoreCalculate: ; pass dx
    pushA

        call RowCompletion
        cmp ax, 1
        jnz CheckTheColumnForCompletion

            push dx

            xor dx, dx
            mov ax, 100
            xor bx, bx
            mov bl, [TimerCount]
            inc bl
            sub bl, 0x30
            div bx

            add [Score], ax

            pop dx

        CheckTheColumnForCompletion:  
            
            call ColCompletion
            cmp ax, 1
            jnz checkBoxForCompletion

                push dx

                xor dx, dx
                mov ax, 100
                xor bx, bx
                mov bl, [TimerCount]
                inc bl
                sub bl, 0x30
                div bx

                add [Score], ax

                pop dx
            
            checkBoxForCompletion:

                call Box3x3Completion
                cmp ax, 1
                jnz exitScoreCalculationCheck

                    xor dx, dx
                    mov ax, 100
                    xor bx, bx
                    mov bl, [TimerCount]
                    inc bl
                    sub bl, 0x30
                    div bx

                    add [Score], ax
        
        exitScoreCalculationCheck:


            call DrawScoreCard
    popA
ret

startScore: