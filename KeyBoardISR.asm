[org 0x0100]

jmp startINT9

customISRforINT9ForNavigationOnBoard:
pushA
	in al, 0x60
	mov bl, al

	cmp al, 0x31
	jnz CheckingInput

		call hookcustomISRforINT9ForNotes

	CheckingInput:

		cmp al, 1
		jle itWasAnAlphabet			

		cmp al, 0x0b
		jge itWasAnAlphabet			

		mov dh, [currentRow]
		mov dl, [currentCol]
		sub al, 1

		call validateAndPrintNumber

	jmp itWasANumber	

	itWasAnAlphabet:	
		cmp al, 0x23			; Hint Key (H)
		jnz itWasADirection

			cmp byte [HintCount], 0
			jz itWasANumber

			dec byte [HintCount]

			mov dh, [currentRow]
			mov dl, [currentCol]
			mov si, SolutionNumbersForRow1
			call returnValueFromBoard

			call validateAndPrintNumber

			cmp byte [HintCount], 0
			jnz itWasAnAlphabet

				call DisableHints


	itWasADirection:

		mov bl, al
		call getToNextPossibleIndex

	
	itWasANumber:

	mov al, 0x20
	out 0x20, al

	popA
iret

DisableHints:

			push word ButtonsArray
			push word [ButtonsXCoordinate]
			push word [ButtonsYCoordinate + 6]
			push word 32
			push word 32
			push word 4
			push word 12		; color of the hint button when disabled 
			call drawBitMap

ret

getToNextPossibleIndex:		; give the scan code of movement in al
push ax
push dx
push si
push bx

	cmp word [ValuesLeftInIndexes], 0
	jz SkipTheFunctionDirectly
	mov bl, al

	forJumpingIfNumberIsNotEditable1:
		mov al, bl
		cmp al, 0x48		;up
		jnz checkLeft1
			dec byte [currentRow]
			cmp byte [currentRow], -1
			jnz skipMovingRowToLast1
				mov byte [currentRow], 8 
				dec byte [currentCol]
				cmp byte [currentCol], -1
				jnz skipMovingRowToLast1
					mov byte [currentCol], 8			

			skipMovingRowToLast1:
				jmp exitChecksInNavigation1


		checkLeft1:
		cmp al, 0x4b 		;left
		jnz checkDown1
			dec byte [currentCol]
			cmp byte [currentCol], -1
			jnz skipMovingColToLast1
				mov byte [currentCol], 8
				dec byte [currentRow]
				cmp byte [currentRow], -1
				jnz skipMovingColToLast1
					mov byte [currentRow], 8

			skipMovingColToLast1:
				jmp exitChecksInNavigation1


		checkDown1:
		cmp al, 0x50		;down
		jnz checkRight1
			inc byte [currentRow]
			cmp byte [currentRow], 9
			jnz skipMovingRowToStart1
				mov byte [currentRow], 0
				inc byte [currentCol]
				cmp byte [currentCol], 9
				jnz skipMovingRowToStart1
					mov byte [currentCol], 0

			skipMovingRowToStart1:
				jmp exitChecksInNavigation1

		checkRight1:
		cmp al, 0x4d		;right
		jnz exitChecksInNavigation1
			inc byte [currentCol]
			cmp byte [currentCol], 9
			jnz exitChecksInNavigation1
				mov byte [currentCol], 0
				inc byte [currentRow]
				cmp byte [currentRow], 9
				jnz exitChecksInNavigation1
					mov byte [currentRow], 0


		exitChecksInNavigation1:
		
	mov dh, [currentRow]
	mov dl, [currentCol]
	mov si, NumbersUserCantEditForRow1
	call returnValueFromBoard
	cmp ax, 1
	jz forJumpingIfNumberIsNotEditable1

	SkipTheFunctionDirectly:

	call DrawNavigationBox

pop bx
pop si
pop dx
pop ax
ret

updateSpecificFreq:			; give the number in ax whose freq is to be increased 
	pushA

		mov bx, ax
		dec bx
		add bx, bx
		inc word [FrequencyArray + bx]		; inc the freq 
		mov cx, [FrequencyArray + bx]

		mov ah, 0
		dec al
		xor dx, dx
		mov bx, 3
		div bx
		
		xchg ax, dx
		mov bx, dx
		add bx, bx
		mov dx, [FrequencyYCoordinate + bx]

		mov bx, ax
		add bx, bx
		mov ax, [FrequencyXCoordinate + bx]

		add dx, 40

		push word 8
		push word 8
		push word 0
		push word ax
		push word dx
		call ClearABox

		push word bitMaps
		push word ax
		push word dx
		push word 8
		push word 8
		push word cx
		push word 15
		call drawBitMap

	popA
ret

validateAndPrintNumber:		; number in ax, dh -- row, dl -- col
	push bp
	mov bp, sp
	push dx
	push ax
	push bx

		mov si, SolutionNumbersForRow1
		push ax			; saving the number passed 
		call returnValueFromBoard

		pop bx
		cmp ax, bx
		mov ax, bx		; returning the value back in ax which was pressed 
		jnz ItsWrongInput

			mov bx, 7			; background fill color
			mov cx, 15			; foreground color
			call DrawNumberAtPosition

			dec word [ValuesLeftInIndexes]		; dec values left to fill

			call updateSpecificFreq

			mov dx, [bp - 2]


			mov si, NumbersUserCantEditForRow1
			mov ax, 1
			call enterValueAtBoard

			call ScoreCalculate

			mov al, 0x4d
			call getToNextPossibleIndex

			jmp exitInputValidation

		ItsWrongInput:
			mov bx, 7			
			mov cx, 12
			call DrawNumberAtPosition
			
			; inc mistake here ==============================================;
			inc byte [topOfBoardStart + 10]

			call updateMistake

		exitInputValidation:
			
			
	pop bx
	pop dx
	pop ax
	mov sp, bp
	pop bp
ret

HookcustomISRforINT9ForNavigationOnBoard:

	push es
    push ax
	push dx

    xor  ax, ax
    mov  es, ax

    cli
		mov word [es: 9 * 4], customISRforINT9ForNavigationOnBoard
		mov [es: 9 * 4 + 2],  cs
    sti

	mov dh, [currentRow]
	mov dl, [currentCol]
	call DrawNavigationBox

	push word ButtonsArray
    push word [ButtonsXCoordinate]
    push word [ButtonsYCoordinate + 4]
    push word 32
    push word 32
    push word 3
    push word 15
    call drawBitMap


	pop dx
    pop ax
	pop es

ret

UnhookCustomISR9ForNavigationOnBoard:
	push es
	push ax
	push dx

	xor ax, ax
	mov es, ax

	cli 
		mov ax, [OriginalISRforINT9]
		mov [es: 9 * 4], ax
		mov ax, [OriginalISRforINT9 + 2]
		mov [es: 9 * 4 + 2], ax
	sti


	pop dx
	pop ax
	pop es
ret

saveOriginalKeyboardISR:
	push es
	push ax
	cli
		xor ax, ax
		mov es, ax
		mov ax, [es: 9 * 4]
		mov [OriginalISRforINT9], ax
		mov ax, [es: 9 * 4 + 2]
		mov [OriginalISRforINT9 + 2],ax
	sti
	pop ax
	pop es
ret

PrintOnScreenTesting:
	pushA

		mov ax, 0xb800 
		mov es, ax
		mov di, 0

		mov ah, 0x07
		mov al, [currentRow]
		add al, 0x30
		mov [es:di], ax
		add di, 4
		mov al, [currentCol]
		add al, 0x30
		mov [es:di], ax

	popA
ret

pixelCalculatorFromIndex:		; dh -- row, dl -- col, will return x pixel in ax, y pixel in dx
	push bx
	push cx

	xchg dh, dl
	mov cx, dx
	mov dx, 0
	mov ax, 0
	mov al, cl		; col pixel calculation
	mov bx, 36		
	mul bx
	add ax, 50
	
	push ax

	mov dx, 0
	mov ax, 0
	mov al, ch
	mul bx
	add ax, 145		; row pixel calculation
	
	pop dx

	mov bx, 0
	mov bl, cl
	add bl, bl
	add dx, [LinesPixelCount + bx]
	mov bl, ch
	add bl, bl
	add ax, [LinesPixelCount + bx]
	
	pop cx
	pop bx
ret

DrawNavigationBox:	; give new row/col in dh/dl
	pushA


	push word 50
	push word 145
	push word 36
	call DrawGrid

	call pixelCalculatorFromIndex

		push word 11        ; color 
		push ax  			;x
		push dx             ;y
		push word 38             ;pxl count
		call drawHorizontal
		push word 11
		push ax
		push dx
		push word 38
		call drawVertical

		add ax, 37

		push word 11        ; color 3
		push ax  			;x
		push dx             ;y
		push word 38             ;pxl count
		call drawVertical

		sub ax, 37
		add dx, 37

		push word 11
		push ax
		push dx
		push word 38
		call drawHorizontal

	popA
ret

startINT9:

