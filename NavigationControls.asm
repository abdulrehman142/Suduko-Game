[org 0x0100]
jmp                   startNavigation
;=========================;

returnValueFromBoard:                 ; dh --- row , dl --- col, si --- row 1 of the array to use   			will return value in ax
	push bx
	push dx
	push cx

	mov al, dh        ; row for multiplication
	mov bl, 18
	mul bl
	mov dh, 0
	add ax, dx
	add ax, dx
	mov bx, ax
	mov ax, [si + bx]
	pop cx
	pop dx
	pop bx
ret

enterValueAtBoard:    ;dh --- row , dl --- col, si --- row 1 of the array to use , value to set in ax 
push               bx
push               dx
push               cx
push               ax
push               ax ; will use late to retrieve value 

	mov al, dh ; row for multiplication
	mov bl, 18
	mul bl
	mov dh, 0
	add ax, dx
	add ax, dx
	mov bx, ax

	pop ax            ; value retreived 
	mov [si + bx], ax

    pop                  ax
    pop                  cx
    pop                  dx
    pop                  bx
ret

IsInsertibleAtIndex:    ; dh --- row, dl --- col, cx --- number to check, will return 1 in ax if it is insertable           push array to use in bp + 4
    push bp
    mov  bp, sp
    push dx
    push cx
    push bx
    push di
	push si
		mov si, [bp + 4]

        mov bx, dx ; saving value of dx
        mov dl, 0  ; column checking
        RecheckInColumnLoop:
            
            cmp bl, dl              ; using continue
            jz  ColumnLoopIncrement

                call returnValueFromBoard ; will return value in ax
                cmp  al, cl
                jz   valueIsNotInsertible

        ColumnLoopIncrement:
            inc dl
            cmp dl, 9
        jnz RecheckInColumnLoop


        mov dx, bx ; getting value of dx back
        mov dh, 0  ; checking row
        RecheckInRowLoop:

                cmp bh, dh
                jz  RowLoopIncrement

                    call returnValueFromBoard
                    cmp  al, cl
                    jz   valueIsNotInsertible

        RowLoopIncrement:
            inc dh
            cmp dh, 9
        jnz RecheckInRowLoop

        push cx ; saving a cx value

        mov dx, 0  ; 3x3 box checks
        mov ax, 0
        mov al, bl ; col
        mov di, 3  ; col / 3
        div di

        mov dx, 0
        mul di     ; col / 3 * 3
        mov cl, al

        mov dx, 0
        mov ax, 0
        mov al, bh
        div di     ; row / 3

        mov dx, 0
        mul di     ; row / 3 * 3 
        mov ch, al

        mov dx, cx
        pop cx     ; value to insert is in cx 

        mov bx, dx
        add bl, 3  ; col / 3 * 3 + 3
        add bh, 3  ; row / 3 * 3 + 3

        checking3x3Box:
			
			cmp bx, dx
			jz  Increment3x3Box

			call returnValueFromBoard
			cmp  cx, ax
			jz   valueIsNotInsertible

			Increment3x3Box:	
				inc dl
				cmp dl, bl
				jnz checking3x3Box

			sub dl, 3
			inc dh
			cmp dh, bh
			jnz checking3x3Box

	valueIsInsertible:
		mov ax, 1
		jmp exitIsInsertable

    valueIsNotInsertible:
        mov ax, 0

	exitIsInsertable:

	pop si
    pop di
    pop bx
    pop cx
    pop dx
    mov sp, bp
    pop bp
ret 2

seed: dw 0
rand:
    ; [BP + 8] RANDOM_NUMBER (RETURN)
    ; [BP + 6] LOWER_BOUND
    ; [BP + 4] UPPER_BOUND
    PUSH BP
    MOV  BP, SP

    PUSH AX
    PUSH BX
    PUSH DX

    MOV BX, [BP + 4]
    SUB BX, [BP + 6]

    OR  BX, BX
    JNZ read_tsc
    
    INC BX

read_tsc:
    RDTSC

    ADD AX,     [seed]
    ADD [seed], AX

    XOR DX, DX
    DIV BX

    ADD DX,       [BP + 6]
    MOV [BP + 8], DX

    POP DX
    POP BX
    POP AX

    MOV SP, BP
    POP BP

RET 4

GenerateRandomBoard:            ; this is the wrapper function
    pushA

        mov byte [currentRow], 0
        mov byte [currentCol], 0
        
        xor dx, dx

        mov di, 9
        mov si, SolutionNumbersForRow1 ;SolutionNumbersForRow1
        loopFillingTheFirstRow:
           push word 0
           push word 1
           push word 9
           call rand
           pop  cx
            push si
           call IsInsertibleAtIndex
           cmp  ax, 1
           jnz  itIsNotInsertableInFillingFirstRow

                mov  ax, cx
                call enterValueAtBoard
                inc  dl
           itIsNotInsertableInFillingFirstRow:
            dec di
            cmp di, 0
            jnz loopFillingTheFirstRow

        mov byte [currentCol], dl

        mov [SPBeforeGeneration], sp

        call RandomBoardGeneration

        RandomBoardGenerationComplete:
            
            mov sp,                [SPBeforeGeneration]
            mov byte [currentCol], 0
            mov byte [currentRow], 0
    popA
ret

RandomBoardGeneration:          ; this is the recursive function
    pushA


        cmp byte [currentCol], 9
        jnz NotTheEndingColYetInGeneration
            mov byte [currentCol], 0
            inc byte [currentRow]
        
        cmp byte [currentRow], 9
        jnz NotTheEndingColYetInGeneration

            jmp RandomBoardGenerationComplete

        NotTheEndingColYetInGeneration:

        mov dh, [currentRow]
        mov dl, [currentCol]
        mov cx, 9
        mov si, SolutionNumbersForRow1 ;SolutionNumbersForRow1

        RandomBoardGenerationRecurrsion:
            push si
            call IsInsertibleAtIndex
            cmp  ax, 1
        jnz skipInsertingNumberWhileBoardGeneration

            mov  ax, cx
            call enterValueAtBoard
            inc  byte [currentCol]

            call RandomBoardGeneration
            dec  byte [currentCol]

            mov  ax, 0
            call enterValueAtBoard

        skipInsertingNumberWhileBoardGeneration:
            loop RandomBoardGenerationRecurrsion

    popA
ret

Index: db 0, 0,  0, 0,  0, 0,  0, 0,  0, 0,  0, 5,  0, 6,  0, 7,  0, 8
        db 1, 0,  1, 1,  1, 2,  1, 3,  1, 4,  1, 5,  1, 6,  1, 7,  1, 8
        db 2, 0,  2, 1,  2, 2,  2, 3,  2, 4,  2, 5,  2, 6,  2, 7,  2, 8
        db 3, 0,  3, 1,  3, 2,  3, 3,  3, 4,  3, 5,  3, 6,  3, 7,  3, 8
        db 4, 0,  4, 1,  4, 2,  4, 3,  4, 4,  4, 5,  4, 6,  4, 7,  4, 8
        db 5, 0,  5, 1,  5, 2,  5, 3,  5, 4,  5, 5,  5, 6,  5, 7,  5, 8
        db 6, 0,  6, 1,  6, 2,  6, 3,  6, 4,  6, 5,  6, 6,  6, 7,  6, 8
        db 7, 0,  7, 1,  7, 2,  7, 3,  7, 4,  7, 5,  7, 6,  7, 7,  7, 8
        db 8, 0,  8, 1,  8, 2,  8, 3,  8, 4,  8, 5,  8, 6,  8, 7,  8, 8

IndexRestore :  db           0, 0,  0, 1,  0, 2,  0, 3,  0, 4,  0, 5,  0, 6,  0, 7,  0, 8
                db           1, 0,  1, 1,  1, 2,  1, 3,  1, 4,  1, 5,  1, 6,  1, 7,  1, 8
        db                   2, 0,  2, 1,  2, 2,  2, 3,  2, 4,  2, 5,  2, 6,  2, 7,  2, 8
        db                   3, 0,  3, 1,  3, 2,  3, 3,  3, 4,  3, 5,  3, 6,  3, 7,  3, 8
        db                   4, 0,  4, 1,  4, 2,  4, 3,  4, 4,  4, 5,  4, 6,  4, 7,  4, 8
        db                   5, 0,  5, 1,  5, 2,  5, 3,  5, 4,  5, 5,  5, 6,  5, 7,  5, 8
        db                   6, 0,  6, 1,  6, 2,  6, 3,  6, 4,  6, 5,  6, 6,  6, 7,  6, 8
        db                   7, 0,  7, 1,  7, 2,  7, 3,  7, 4,  7, 5,  7, 6,  7, 7,  7, 8
        db                   8, 0,  8, 1,  8, 2,  8, 3,  8, 4,  8, 5,  8, 6,  8, 7,  8, 8

ValueFromDifficulty: dw 20
ValuesLeftInIndexes: dw 80

FillRandomBasedOnDifficulty:
    pushA

    push cs
    pop ds
    push cs
    pop es 
    mov di, Index
    mov si, IndexRestore
    mov cx, 80
    rep movsw


    mov cx, [ValueFromDifficulty]
    GenerateANumberAgain:       
        push cx

        push word 0
        push word 1
        push word [ValuesLeftInIndexes]
        call rand
        dec word [ValuesLeftInIndexes]
        pop di
        add di, di

        mov dx, [Index + di];
        mov cx, 160
        sub cx, di

        add di, Index
        mov si, di
        add si, 2
        

        rep movsb

        pop cx
            
            mov  si, SolutionNumbersForRow1
            call returnValueFromBoard

            mov bx, ax              ; just for inc freq 
            dec bx
            add bx, bx
            inc word [FrequencyArray + bx]

            mov  si, NumbersForRow1
            call enterValueAtBoard
            mov  si, NumbersUserCantEditForRow1
            mov  ax, 1
            call enterValueAtBoard

        loop GenerateANumberAgain

        mov ax, 81
        sub ax, [ValueFromDifficulty]
        mov word [ValuesLeftInIndexes], ax

    popA
ret


startNavigation:
