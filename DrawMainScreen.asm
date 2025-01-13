[org 0x0100]

	jmp startDrawMiddle
	
	;======================================================================================================================================;
	drawVertical: ; bp + 4 -- counter, bp + 6 --- y, bp + 8 --- x, bp + 10 --- color
		push bp
		mov  bp, sp
		sub  sp, 2         ;space for counter
		pushA
		mov  ah, 0x0c
		mov  si, [bp + 4]  ; counter
		mov  di, 0
		mov  cx, [bp + 8]
		mov  dx, [bp + 6]
		mov  bh, 0
		mov  al, [bp + 10] ; color

		loopDrawVertical:
			int 10h
			inc dx  ;increment y axis
			dec si  ;decrement counter
		jnz loopDrawVertical

		popA
		mov sp, bp
		pop bp
	ret 8

	drawHorizontal: ; counter [bp + 4] --- y [bp + 6] --- x [bp + 4]
		push bp
		mov  bp, sp
		sub  sp, 2         ;space for counter
		pushA
		mov  ah, 0x0c
		mov  si, [bp + 4]  ; counter
		mov  cx, [bp + 8]  ;x
		mov  dx, [bp + 6]  ;y
		mov  bh, 0         ;page number
		mov  al, [bp + 10] ;color

		loopDrawHorizontal:
			int 10h
			inc cx  ;increment x axis
			dec si  ;decrement counter
		jnz loopDrawHorizontal
		popA
		mov sp, bp
		pop bp
	ret 8


	;======================================================================================================================================;

DrawNumberAtPosition:		;give Row in dh, col in dl, number to print in ax, bg color in bx, number color in cx
	push dx
	push ax
	push bx
	push cx
	push ax
		call pixelCalculatorFromIndex

			add ax, 1
			add dx, 1
			push word 36		;size x
			push word 36		;size y
			push word bx		; color
			push word ax 		; x coordinate
			push word dx		; y coordinate
			call ClearABox

			add dx, 2
			add ax, 2

			pop bx
			push NumbersBitmaps
			push ax
			push dx
			push word 32
			push word 32
			push word bx
			push word cx
			call drawBitMap

	pop cx
	pop bx
	pop ax
	pop dx
ret

drawNumbersInGrid:
	pushA
		xor dx, dx
		mov si, NumbersForRow1
		mov cx, 15		; number color to print
		mov bx, 7		; bg color 
		getValuesInDrawingNumbers:
			call returnValueFromBoard

			cmp ax, 0
			jz skipPrintingInDrawingNumbers

				call DrawNumberAtPosition
				
		skipPrintingInDrawingNumbers:
				inc dl
				cmp dl, 9
			jnz getValuesInDrawingNumbers
				mov dl, 0
				inc dh
				cmp dh, 9
			jnz getValuesInDrawingNumbers

	popA
ret

;=====================================================================================================================================================================;

	
	;======================================================================================================================================;
;===============================================================================================================================================================================================;

DrawScoreCard: 
	pushA
	
	mov dh, 1
	dec dh
	mov dl, 34
	mov bx, 0
	mov ah, 02h
	int 10h          ; settings cursor at given index
	mov ah, 0x0e     ; setting for teletype output
	mov bl, 15

	mov si, ScoreString
	call PrintString
	
	mov bl, 11
	call Printscore
	
	popA
ret

;===============================================================================================================================================================================================;

updateMistake:
	pushA

	mov ax, 50
	mov bl, 16
	div bl
	mov dh, al
	dec dh
	mov ax, 145
	mov bl, 8
	div bl
	mov dl, al
	inc dl
	mov bx, 0
	mov ah, 02h
	int 10h          ; settings cursor at given index
	mov ah, 0x0e     ; setting for teletype output
	mov bl, 15

	mov  si, topOfBoardStart
	call PrintString

	popA

ret

;===============================================================================================================================================================================================;
drawBoardTop: ; bp + 4 --- y, bp + 6 --- x, bp + 8 difficulty
	push bp
	mov  bp, sp
	pushA

	mov ax, [bp + 4]
	mov bl, 16
	div bl
	mov dh, al
	dec dh
	mov ax, [bp + 6]
	mov bl, 8
	div bl
	mov dl, al
	inc dl
	mov bx, 0
	mov ah, 02h
	int 10h          ; settings cursor at given index
	mov ah, 0x0e     ; setting for teletype output
	mov bl, 15

	mov  si, topOfBoardStart
	call PrintString

	
	mov  si, [bp + 8]
	dec si
	add si, si
	mov  si, [topOfBoardDifficulty + si]
	call findlength1
	shr  cx, 1
	add  dl, 21
	sub  dl, cl
	mov  ah, 02h
	int  10h
	mov  ah, 0x0e

	call PrintString

	popA
	mov sp, bp
	pop bp
ret 6
;==================================================================================================================================================================================================;
	DrawGrid: ; [bp + 4] grid size --- [bp + 6] y --- [bp + 8] x 
		push bp
		mov  bp,            sp
		sub  sp,            4
		mov  word [bp - 2], 0
		mov  word [bp - 4], 0
		pushA
		
		
		mov si,            0
		mov cx,            [bp + 6] ;x co-ordinate
		mov dx,            [bp + 8] ;y co-ordinate
		mov di,            0
		mov word [bp - 4], cx
		mov word [bp - 2], dx
		mov ax,            [bp + 4]
		mov bl,            9
		mul bl
		add ax,            22       ;total no of pixels to printc
		
		jmp drawAgain
		
		someThingIdk:
			inc di
			inc cx
			inc dx
			cmp di, 5
		jnz drawAgain
			dec cx
			dec dx
			mov di, 0
		jmp iterateNext
		
		someThingIdk2:
			inc di
			inc cx
			inc dx
			cmp di, 3
		jnz drawAgain
			dec cx
			dec dx
			mov di, 0
		jmp iterateNext
		
		drawAgain:
			push word 8       ; color 3
			push word [bp - 4]  ;x
			push dx             ;y
			push ax             ;pxl count
			call drawHorizontal
			push word 8
			push cx
			push word [bp - 2]
			push ax
			call drawVertical
				cmp si, 0
			jz someThingIdk
				cmp si, 9
			jz someThingIdk
				cmp si, 3
			jz someThingIdk2
				cmp si, 6
			jz someThingIdk2
			
			iterateNext:
			add dx, [bp + 4] ;; adding the offset
			add cx, [bp + 4]
			inc dx
			inc cx
			inc si
			cmp si, 10
			
		jnz drawAgain
		
		popA
		mov sp, bp
		pop bp
		
	ret 6
;==========================================================================================================================================================================================================================;

DrawLeftSideButtons:
	pushA

	mov di, 0
	mov si, [ButtonsYCoordinate+ di]
	add di, 2
	mov ax, [ButtonsXCoordinate]
	push ButtonsArray
	push ax
	push si
	push word 32
	push word 32
	push word 1
	push word 15
	call drawBitMap
	
	mov si, [ButtonsYCoordinate+ di]
	add di, 2
	mov ax, [ButtonsXCoordinate]
	push ButtonsArray
	push ax
	push si
	push word 32
	push word 32
	push word 2
	push word 15
	call drawBitMap

	mov si, [ButtonsYCoordinate+ di]
	add di, 2
	mov ax, [ButtonsXCoordinate]
	push ButtonsArray
	push ax
	push si
	push word 32
	push word 32
	push word 3
	push word 15
	call drawBitMap

	mov si, [ButtonsYCoordinate+ di]
	add di, 2
	mov ax, [ButtonsXCoordinate]
	push ButtonsArray
	push ax
	push si
	push word 32
	push word 32
	push word 4
	push word 15
	call drawBitMap



	popA
ret

;==========================================================================================================================================================================================================================;

DrawRightSideButton:
pushA
	mov si, FrequencyXCoordinate
	mov di, FrequencyYCoordinate
	mov bx, FrequencyArray
	mov cx, 1

	loopingRightSideButtons:

	cmp word [si], 1000	;change this in case of alteration
	jnz SkipEnteringNewRowInSideButtons
		mov si, FrequencyXCoordinate
		add di, 2
	SkipEnteringNewRowInSideButtons:
		push word NumbersBitmaps
		push word [si]
		push word [di]
		push word 32
		push word 32
		push cx
		push word 11
		call drawBitMap
		
		mov ax, [di]
		add ax, 40

		cmp word [bx], 0
		jnz FreqIsNot0

			mov dx, 10
			jmp justDontHaveALableToNameThisJump
		FreqIsNot0:

			mov dx, [bx]		

		justDontHaveALableToNameThisJump:
		push word bitMaps
		push word [si]
		push word ax
		push word 8
		push word 8
		push word dx
		push word 15
		call drawBitMap
		inc cx
		add si, 2
		add bx, 2
		cmp cx, 10
		jnz loopingRightSideButtons

popA
ret
;==========================================================================================================================================================================================================================;

DrawBottomNumbers:
pushA
	mov cx, 1
	mov si, FrequencyArray
	mov bx, BottomNumbersXCoordinate
	
	loopingDrawingBottomNumbers:
	cmp word [si], 0
	jz skipPrintingBottomNumbers
		push word DummyArray
		push word [bx]
		push word [BottomNumbersYCoordinate]
		push word 32
		push word 32
		push word 1
		push word 3
		call drawBitMap

		push word NumbersBitmaps
		push word [bx]
		push word [BottomNumbersYCoordinate]
		push word 32
		push word 32
		push word cx
		push word 11
		call drawBitMap
		
	skipPrintingBottomNumbers:
		add bx, 2
		inc cx
		cmp cx, 10
		jnz loopingDrawingBottomNumbers

popA
ret

;==========================================================================================================================================================================================================================;

startDrawMiddle: