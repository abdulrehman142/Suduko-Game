[org 0x0100]

	jmp startBitmap

	;=====================================================================================================================================================================================================;
	SudokuLogo: dw 0x0001, 0x8000, 0x000c, 0x3000, 0x0fff, 0xfff0, 0x0000, 0x0000, 0xf4b1, 0xe924, 0x84a9, 0x2a24, 0x84a5, 0x2c24, 0xf4a5, 0x2c24, 0x14a5, 0x2a24, 0x14a9, 0x2924, 0xf7b1, 0xe8bd, 0x0000, 0x0000, 0x0fff, 0xfff0, 0x000c, 0x3000, 0x0001, 0x8000, 0x0000, 0x0000
	; 24 starting x, 0 starting y, 32 columns in single Row

	StringStart: db 'Start Game', 1
	StringQuit: db 'Quit', 1

	StringExitToMainMenu: db 'Exit To Main Menu', 1

	clrScreen:
		mov ax, 0xb800
		mov es, ax
		mov di, 0   
		mov cx, 2000

		mov ax, 0x0720
		rep stosw 
	ret
	;==================================================================================================================================================================================================================;
	
	ReSetSIInSudoku:
		push ax
		mov ax, [si]
		add si, 2
		mov [bp - 4], ax
		mov word [bp - 6], 16
		
		pop ax
	ret


	drawSudokuLogo: 
		push bp
		mov bp, sp
		sub sp, 6
		mov word [bp - 2], 0    ; row count, adds 80 for every row
		mov word [bp - 4], 0    ; to store content of [si]
		mov word [bp - 6], 0    ; to store byte count
		pushA

		mov si, SudokuLogo
		mov ax, 0xb800
		mov es, ax
		
		mov ah , 00001111b
		mov al, 178

		mov cx, 16

		mov dx, 23
		call ReSetSIInSudoku

		loopingDrawingSudoku:

				shl word [bp - 4], 1
			jnc SkipPrintinSudoku

				mov di, [bp - 2]
				add di, dx
				shl di, 1

				mov word [es:di], ax

			SkipPrintinSudoku:
				dec word [bp - 6]
				cmp word [bp - 6], 0
				jnz skipResettingSiinSudoku

					call ReSetSIInSudoku

			skipResettingSiinSudoku:

					inc dx
					cmp dx, 55

			jnz loopingDrawingSudoku

				mov dx, 23
				add word [bp - 2], 80
			
			loop loopingDrawingSudoku

		popA        
		mov sp, bp
		pop bp
	ret


	;=====================================================================================================================================================================================================;
	ScoreString:  db 'Score: ', 1
	ScoreString2: db '000000', 1
	Score:        dw 0x0000
	
Printscore:
		push bp
		mov  bp, sp
		pushA
		
		mov si, 5
		mov cx, 6
		mov di, [Score]
		mov bx, 10

		loopingPrintScore:

			mov dx, 0
			mov ax, di
			div bx
			add dl, 0x30
			mov byte [ScoreString2 + si], dl
			mov di, ax
			dec si
			dec cx
			cmp cx, 0
		jnz loopingPrintScore

		mov dh, 1
		dec dh
		mov dl, 41
		mov bx, 0
		mov ah, 02h
		int 10h          ; settings cursor at given index
		mov ah, 0x0e     ; setting for teletype output
		mov bl, 11
				
		mov si, ScoreString2
		call PrintString


		popA
		mov sp, bp
		pop bp
	ret

	;=====================================================================================================================================================================================================;

	; bitmaps to be stored in little endian
	; bitmps for notes
	bitMap1: db 00111000b ,00011000b ,11011000b ,01111000b ,00011000b ,00011000b ,11111111b ,00011000b
	bitMap2: db 11111111b ,11111111b ,11111111b ,00000011b ,11000000b ,11111111b ,11111111b ,11111111b
	bitMap3: db 11111111b ,11111111b ,11111111b ,00000011b ,00000011b ,11111111b ,11111111b ,11111111b
	bitMap4: db 11000011b ,11000011b ,11111111b ,11000011b ,00000011b ,00000011b ,00000011b ,00000011b
	bitMap5: db 11111111b ,11111111b ,11111111b ,11000000b ,00000011b ,11111111b ,11111111b ,11111111b
	bitMap6: db 11111111b ,11111111b ,11111111b ,11000000b ,11000011b ,11111111b ,11111111b ,11111111b
	bitMap7: db 00111111b ,00111111b ,00000011b ,00000011b ,00000011b ,00000011b ,00000011b ,00000011b
	bitMap8: db 11111111b ,11111111b ,11111111b ,11000011b ,11000011b ,11111111b ,11111111b ,11111111b
	bitMap9: db 11111111b ,11111111b ,11111111b ,11000011b ,00000011b ,11111111b ,11111111b ,11111111b
	bitMap0: db 11111111b ,11111111b ,11000011b ,11000011b ,11000011b ,11000011b ,11111111b ,11111111b 

	bitMaps: dw bitMap1, bitMap2, bitMap3, bitMap4, bitMap5, bitMap6, bitMap7, bitMap8, bitMap9, bitMap0
	
	;=====================================================================================================================================================================================================;

	; bitmaps for numbers 
	
	BitmapNumber2: dw 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0007, 0x8000, 0x001f, 0xf000, 0x003e, 0xf800, 0x0030, 0x3800, 0x0070, 0x1c00, 0x00e0, 0x1c00, 0x00e0, 0x1c00, 0x0040, 0x0c00, 0x0000, 0x0c00, 0x0000, 0x1c00, 0x0000, 0x1c00, 0x0000, 0x7800, 0x0000, 0xf000, 0x0003, 0xe000, 0x0007, 0xc000, 0x000f, 0x0000, 0x001e, 0x0000, 0x003c, 0x0000, 0x0070, 0x0000, 0x007f, 0xff00, 0x00ff, 0xff00, 0x00ff, 0xff00, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000
	BitmapNumber1: dw 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0001, 0xc000, 0x0003, 0xc000, 0x0007, 0xc000, 0x000f, 0xc000, 0x001d, 0xc000, 0x0039, 0xc000, 0x0001, 0xc000, 0x0001, 0xc000, 0x0001, 0xc000, 0x0001, 0xc000, 0x0001, 0xc000, 0x0001, 0xc000, 0x0001, 0xc000, 0x0001, 0xc000, 0x0001, 0xc000, 0x0001, 0xc000, 0x0001, 0xc000, 0x0001, 0xc000, 0x0001, 0xc000, 0x03ff, 0xffc0, 0x03ff, 0xffc0, 0x03ff, 0xffc0, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000
	BitmapNumber3: dw 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x00ff, 0xff00, 0x00ff, 0xff00, 0x00ff, 0xff00, 0x0000, 0x0700, 0x0000, 0x1e00, 0x0000, 0x7800, 0x0001, 0xe000, 0x0007, 0x8000, 0x000f, 0xfc00, 0x000f, 0xff00, 0x0000, 0x0f00, 0x0000, 0x0300, 0x0000, 0x0380, 0x0000, 0x0180, 0x0000, 0x0180, 0x00e0, 0x0180, 0x00e0, 0x0380, 0x0060, 0x0700, 0x0070, 0x1e00, 0x003c, 0x7c00, 0x003f, 0xf000, 0x000f, 0xc000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000
	BitmapNumber4: dw 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0001, 0xc000, 0x0003, 0x8000, 0x0007, 0x0000, 0x0007, 0x0000, 0x000e, 0x0000, 0x000e, 0x0000, 0x001c, 0x0000, 0x001c, 0x0000, 0x0038, 0x1c00, 0x0070, 0x1c00, 0x0070, 0x1c00, 0x00e0, 0x1c00, 0x01ff, 0xff80, 0x01ff, 0xff80, 0x01ff, 0xff80, 0x0000, 0x1c00, 0x0000, 0x1c00, 0x0000, 0x1c00, 0x0000, 0x1c00, 0x0000, 0x1c00, 0x0000, 0x1c00, 0x0000, 0x1c00, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000
	BitmapNumber5: dw 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x00ff, 0xfe00, 0x00ff, 0xfe00, 0x00ff, 0xfe00, 0x00e0, 0x0000, 0x00e0, 0x0000, 0x00e0, 0x0000, 0x00e0, 0x0000, 0x00e0, 0x0000, 0x00ff, 0xc000, 0x00ff, 0xf800, 0x00f0, 0x7c00, 0x0000, 0x1c00, 0x0000, 0x0e00, 0x0000, 0x0e00, 0x0000, 0x0600, 0x0000, 0x0e00, 0x0000, 0x0e00, 0x00f0, 0x3c00, 0x00f0, 0x7800, 0x00ff, 0xf000, 0x001f, 0xc000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000
	BitmapNumber6: dw 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0xf000, 0x0001, 0xe000, 0x0003, 0x8000, 0x0007, 0x0000, 0x000e, 0x0000, 0x001c, 0x0000, 0x0038, 0x0000, 0x0038, 0x0000, 0x0070, 0x0000, 0x0073, 0x8000, 0x007f, 0xf000, 0x00ff, 0xf800, 0x00f8, 0x3c00, 0x00f0, 0x0c00, 0x0060, 0x0c00, 0x0060, 0x0c00, 0x0070, 0x1c00, 0x0038, 0x1c00, 0x003c, 0x3800, 0x001f, 0xf800, 0x0007, 0xc000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000
	BitmapNumber7: dw 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x00ff, 0xff00, 0x00ff, 0xff00, 0x00ff, 0xff00, 0x0000, 0x0700, 0x0000, 0x0700, 0x0000, 0x0700, 0x0000, 0x0e00, 0x0000, 0x1e00, 0x0000, 0x1c00, 0x0000, 0x3800, 0x0000, 0x7000, 0x0000, 0xe000, 0x0001, 0xe000, 0x0003, 0xc000, 0x0007, 0x8000, 0x000f, 0x0000, 0x001e, 0x0000, 0x003c, 0x0000, 0x0078, 0x0000, 0x0070, 0x0000, 0x0060, 0x0000, 0x0040, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000
	BitmapNumber8: dw 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0007, 0xe000, 0x003f, 0xf800, 0x0038, 0x1c00, 0x0070, 0x1e00, 0x00f0, 0x0e00, 0x00e0, 0x1e00, 0x0070, 0x1c00, 0x0038, 0x3800, 0x001f, 0xf000, 0x003f, 0xf800, 0x0070, 0x3c00, 0x00e0, 0x0c00, 0x00c0, 0x0600, 0x01c0, 0x0600, 0x01c0, 0x0700, 0x01c0, 0x0700, 0x00e0, 0x0600, 0x0070, 0x0e00, 0x003c, 0x1c00, 0x001f, 0xf800, 0x0003, 0xe000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000
	BitmapNumber9: dw 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x001f, 0xf000, 0x003f, 0xf800, 0x0078, 0x3c00, 0x00e0, 0x1e00, 0x00e0, 0x0e00, 0x00e0, 0x0e00, 0x00e0, 0x0e00, 0x0070, 0x1e00, 0x0078, 0x3c00, 0x007f, 0xfc00, 0x000f, 0xfc00, 0x0000, 0x1c00, 0x0000, 0x3800, 0x0000, 0x7800, 0x0000, 0x7000, 0x0000, 0xf000, 0x0000, 0xe000, 0x0003, 0xe000, 0x007f, 0xc000, 0x007f, 0x0000, 0x007c, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000

	NumbersBitmaps: dw BitmapNumber1, BitmapNumber2, BitmapNumber3, BitmapNumber4, BitmapNumber5, BitmapNumber6, BitmapNumber7, BitmapNumber8, BitmapNumber9

	ClearABox:			; + 4 -- y co ordinate, + 6 x -- coordinate, + 8 -- color,	+ 10 -- size y, + 12 -- size x
		push bp
		mov  bp, sp
		pushA
		mov  cx, [bp + 6]
		mov  dx, [bp + 4]
		mov  al, [bp + 8]
		mov  ah, 0ch
		mov  bh, 0
		mov  si, 0
		mov  di, 0

		loopingClearingBox:
			int 10h

			inc cx
			inc si

			cmp si, [bp + 12]
			jnz DidntreachEndInClearingBox
				mov si, 0
				mov cx, [bp + 6]
				inc di
				inc dx
				cmp di, [bp + 10]
				jz  exitingClearbox

			DidntreachEndInClearingBox:
		jmp loopingClearingBox

		exitingClearbox:
		popA
		mov sp, bp
		pop bp
	ret 10

	;======================================================================================================================================================================================;
	
	; ; notesForRow1: db 00000000b, 00000000b, 00000000b, 00000000b, 00000000b, 00000000b, 00000000b, 00000000b, 00000000b, 00000000b, 00000000b, 00000000b
	; ; notesForRow2: db 00000000b, 00000000b, 00000000b, 00000000b, 00000000b, 00000000b, 00000000b, 00000000b, 00000000b, 00000000b, 00000000b, 00000000b
	; ; notesForRow3: db 00000000b, 00000000b, 00000000b, 00000000b, 00000000b, 00000000b, 00000000b, 00000000b, 00000000b, 00000000b, 00000000b, 00000000b
	; ; notesForRow4: db 00000000b, 00000000b, 00000000b, 00000000b, 00000000b, 00000000b, 00000000b, 00000000b, 00000000b, 00000000b, 00000000b, 00000000b
	; ; notesForRow5: db 00000000b, 00000000b, 00000000b, 00000000b, 00000000b, 00000000b, 00000000b, 00000000b, 00000000b, 00000000b, 00000000b, 00000000b
	; ; notesForRow6: db 00000000b, 00000000b, 00000000b, 00000000b, 00000000b, 00000000b, 00000000b, 00000000b, 00000000b, 00000000b, 00000000b, 00000000b
	; ; notesForRow7: db 00000000b, 00000000b, 00000000b, 00000000b, 00000000b, 00000000b, 00000000b, 00000000b, 00000000b, 00000000b, 00000000b, 00000000b
	; ; notesForRow8: db 00000000b, 00000000b, 00000000b, 00000000b, 00000000b, 00000000b, 00000000b, 00000000b, 00000000b, 00000000b, 00000000b, 00000000b
	; ; notesForRow9: db 00000000b, 00000000b, 00000000b, 00000000b, 00000000b, 00000000b, 00000000b, 00000000b, 00000000b, 00000000b, 00000000b, 00000000b

	; notesForRow1: times 81 dw 0
	; notesForRow2: times 81 dw 0
	; notesForRow3: times 81 dw 0
	; notesForRow4: times 81 dw 0	
	; notesForRow5: times 81 dw 0
	; notesForRow6: times 81 dw 0
	; notesForRow7: times 81 dw 0
	; notesForRow8: times 81 dw 0
	; notesForRow9: times 81 dw 0
	; notesArray: dw notesForRow1, notesForRow2, notesForRow3, notesForRow4, notesForRow5, notesForRow6, notesForRow7, notesForRow8, notesForRow9

	;======================================================================================================================================================================================;
	NumbersForRow1: dw 0,0,0,0,0,0,0,0,0
	NumbersForRow2: dw 0,0,0,0,0,0,0,0,0
	NumbersForRow3: dw 0,0,0,0,0,0,0,0,0
	NumbersForRow4: dw 0,0,0,0,0,0,0,0,0
	NumbersForRow5: dw 0,0,0,0,0,0,0,0,0
	NumbersForRow6: dw 0,0,0,0,0,0,0,0,0
	NumbersForRow7: dw 0,0,0,0,0,0,0,0,0
	NumbersForRow8: dw 0,0,0,0,0,0,0,0,0
	NumbersForRow9: dw 0,0,0,0,0,0,0,0,0

	NumbersArray: dw NumbersForRow1, NumbersForRow2, NumbersForRow3, NumbersForRow4, NumbersForRow5, NumbersForRow6, NumbersForRow7, NumbersForRow8, NumbersForRow9

	SolutionNumbersForRow1: dw 0,0,0,0,0,0,0,0,0
	SolutionNumbersForRow2: dw 0,0,0,0,0,0,0,0,0
	SolutionNumbersForRow3: dw 0,0,0,0,0,0,0,0,0
	SolutionNumbersForRow4: dw 0,0,0,0,0,0,0,0,0
	SolutionNumbersForRow5: dw 0,0,0,0,0,0,0,0,0
	SolutionNumbersForRow6: dw 0,0,0,0,0,0,0,0,0
	SolutionNumbersForRow7: dw 0,0,0,0,0,0,0,0,0
	SolutionNumbersForRow8: dw 0,0,0,0,0,0,0,0,0
	SolutionNumbersForRow9: dw 0,0,0,0,0,0,0,0,0

	SolutionNumbersArray: dw SolutionNumbersForRow1, SolutionNumbersForRow2, SolutionNumbersForRow3, SolutionNumbersForRow4, SolutionNumbersForRow5, SolutionNumbersForRow6, SolutionNumbersForRow7, SolutionNumbersForRow8, SolutionNumbersForRow9

	NumbersUserCantEditForRow1: dw 0,0,0,0,0,0,0,0,0			; the numbers which will be alr present when the game starts 
	NumbersUserCantEditForRow2: dw 0,0,0,0,0,0,0,0,0
	NumbersUserCantEditForRow3: dw 0,0,0,0,0,0,0,0,0
	NumbersUserCantEditForRow4: dw 0,0,0,0,0,0,0,0,0
	NumbersUserCantEditForRow5: dw 0,0,0,0,0,0,0,0,0
	NumbersUserCantEditForRow6: dw 0,0,0,0,0,0,0,0,0
	NumbersUserCantEditForRow7: dw 0,0,0,0,0,0,0,0,0
	NumbersUserCantEditForRow8: dw 0,0,0,0,0,0,0,0,0
	NumbersUserCantEditForRow9: dw 0,0,0,0,0,0,0,0,0

	NumbersUserCantEditArray: dw NumbersUserCantEditForRow1, NumbersUserCantEditForRow2, NumbersUserCantEditForRow3, NumbersUserCantEditForRow4, NumbersUserCantEditForRow5, NumbersUserCantEditForRow6, NumbersUserCantEditForRow7, NumbersUserCantEditForRow8, NumbersUserCantEditForRow9

	currentRow: db 0
	currentCol: db 0

	SPBeforeGeneration: dw 0				; will be used if i do random board generation
	OriginalISRforINT9: dw 0, 0

	;======================================================================================================================================================================================;
	UndoButton:   dw 0x0fff, 0xfff0, 0x1fff, 0xfff8, 0x3000, 0x000c, 0x6000, 0x0006, 0xc000, 0x0003, 0xc000, 0x0003, 0xc002, 0x0003, 0xc006, 0x0003, 0xc00e, 0x0003, 0xc01e, 0x0003, 0xc03f, 0xf803, 0xc07f, 0xfc03, 0xc03e, 0x0e03, 0xc00e, 0x0703, 0xc006, 0x0303, 0xc002, 0x0303, 0xc000, 0x0303, 0xc000, 0x0303, 0xc000, 0x0303, 0xc000, 0x0303, 0xc000, 0x0603, 0xc000, 0x0403, 0xc007, 0xfc03, 0xc007, 0xf803, 0xc000, 0x0003, 0xc000, 0x0003, 0xc000, 0x0003, 0xc000, 0x0003, 0x6000, 0x0006, 0x3000, 0x000c, 0x1fff, 0xfff8, 0x0fff, 0xfff0
	EraseButton:  dw 0x0fff, 0xfff0, 0x1fff, 0xfff8, 0x3000, 0x000c, 0x6000, 0x3e06, 0xc000, 0x6f03, 0xc000, 0xdf83, 0xc001, 0xbfc3, 0xc003, 0x7ff3, 0xc006, 0xfff3, 0xc00d, 0xffe3, 0xc01b, 0xffc3, 0xc037, 0xff83, 0xc07f, 0xff03, 0xc0df, 0xfe03, 0xc18f, 0xfc03, 0xc307, 0xf803, 0xc603, 0xf003, 0xcc01, 0xe003, 0xcc00, 0xc003, 0xc601, 0x8003, 0xc303, 0x0003, 0xc186, 0x0003, 0xcfff, 0xfc03, 0xc000, 0x0003, 0xc000, 0x0003, 0xc000, 0x0003, 0xc000, 0x0003, 0xc000, 0x0003, 0x6000, 0x0006, 0x3000, 0x000c, 0x1fff, 0xfff8, 0x0fff, 0xfff0
	PencilButton: dw 0x0fff, 0xfff0, 0x1fff, 0xfff8, 0x3000, 0x000c, 0x6000, 0x0006, 0xc000, 0x0003, 0xc000, 0x0003, 0xc000, 0x0e03, 0xc000, 0x1103, 0xc000, 0x3083, 0xc000, 0x5843, 0xc000, 0x8c43, 0xc001, 0x0e43, 0xc002, 0x1383, 0xc004, 0x2103, 0xc008, 0x4203, 0xc010, 0x8403, 0xc021, 0x0803, 0xc042, 0x1003, 0xc084, 0x2003, 0xc108, 0x4003, 0xc310, 0x8003, 0xc5a1, 0x0003, 0xc4c2, 0x0003, 0xc464, 0x0003, 0xc638, 0x0003, 0xc710, 0x0003, 0xe7e0, 0x0003, 0xc000, 0x0003, 0x6000, 0x0006, 0x3000, 0x000c, 0x1fff, 0xfff8, 0x0fff, 0xfff0
	HintButton:   dw 0x1fff, 0xfff8, 0x3fff, 0xfffc, 0x6000, 0x0006, 0xc020, 0x0203, 0xc011, 0xc403, 0xc007, 0xf003, 0xc60f, 0xf833, 0xc313, 0xfc63, 0xc1a3, 0xfec3, 0xc027, 0xfe03, 0xc047, 0xff03, 0xc047, 0xff03, 0xc07f, 0xff03, 0xc73f, 0xfe73, 0xc03f, 0xfe03, 0xc01f, 0xfc03, 0xc19f, 0xfcc3, 0xc30f, 0xf863, 0xc607, 0xf033, 0xc007, 0xf003, 0xc007, 0xf003, 0xc000, 0x0003, 0xc007, 0xf003, 0xc003, 0xe003, 0xc000, 0x0003, 0xc003, 0xe003, 0xc001, 0xc003, 0xc000, 0x0003, 0xc000, 0x0003, 0x6000, 0x0006, 0x3fff, 0xfffc, 0x1fff, 0xfff8



	ButtonsXCoordinate: dw 57
	ButtonsYCoordinate: dw 50 + 25, 137 + 25, 224 + 25, 311 + 25

	ButtonsArray: dw UndoButton, EraseButton, PencilButton, HintButton

	;======================================================================================================================================================================================;

	LinesPixelCount: dw 4, 5, 6, 9,10, 11, 14, 15, 16 ;0, 1, 1, 4, 1, 1, 4, 1, 1 ; 0 for first on purpose, warrna 5 h 


	topOfBoardStart:  db 'Mistakes: 0', 1
	topOfBoardEasy:   db 'Easy', 1
	topOfBoardMedium: db 'Medium', 1
	topOfBoardHard:   db 'Hard', 1

	topOfBoardDifficulty: dw topOfBoardEasy, topOfBoardMedium, topOfBoardHard

	;======================================================================================================================================;
	
	FrequencyArray: dw 0,0,0,0,0,0,0,0,0

	FrequencyXCoordinate: dw 515, 551, 587, 1000
	FrequencyYCoordinate: dw 117, 207, 291

	;======================================================================================================================================;
	BottomNumbersXCoordinate: dw 100, 150, 200, 250, 300, 350, 400, 450, 500
	BottomNumbersYCoordinate: dw 424

	BoxForBottomNumbers: dw 0x0fff, 0xfff0, 0x1fff, 0xfff8, 0x3800, 0x001c, 0x6000, 0x0006, 0xe000, 0x0007, 0xc000, 0x0003, 0xc000, 0x0003, 0xc000, 0x0003, 0xc000, 0x0003, 0xc000, 0x0003, 0xc000, 0x0003, 0xc000, 0x0003, 0xc000, 0x0003, 0xc000, 0x0003, 0xc000, 0x0003, 0xc000, 0x0003, 0xc000, 0x0003, 0xc000, 0x0003, 0xc000, 0x0003, 0xc000, 0x0003, 0xc000, 0x0003, 0xc000, 0x0003, 0xc000, 0x0003, 0xc000, 0x0003, 0xc000, 0x0003, 0xc000, 0x0003, 0xc000, 0x0003, 0xe000, 0x0007, 0x6000, 0x0006, 0x3800, 0x001c, 0x1fff, 0xfff8, 0x0fff, 0xfff0
	DummyArray:          dw BoxForBottomNumbers

	;======================================================================================================================================;

findlength1: ; will return length in cx
		push si
		mov  cx,        0
		loopAgainInFindingLength:
		inc  cx
		inc  si
		cmp  byte [si], 1
		jnz  loopAgainInFindingLength
		pop  si
ret



PrintString:		; give array in si
	push cx
	push si
	push ax
	call findlength1

	repeatPrintInDrawingOnBoardTop:
		mov  al, [si]
		add  si, 1
		int  10h
		loop repeatPrintInDrawingOnBoardTop
	pop ax
	pop si
	pop cx
ret 
	;======================================================================================================================================;


drawBitMap: ; -- 4 color to print, 6 number to print, 8 size of bitmap y, 10 size of bitmap x, 12 index to print y, 14 index to print x, 16 array to use
	
	push bp
	mov  bp,            sp
	sub  sp,            6
	mov  word [bp - 2], 0  ;local variable to store the current byte count of the bitmap
	mov  word [bp - 4], 16 ; size of byte
	mov  word [bp - 6], 0  ; to compare with bp + 10 to check if we need to go to next line or not
	pushA

	mov ax,            [bp + 10]
	mov word [bp - 6], ax

	mov di, [bp + 8] ;

	dec word [bp + 6]
	shl word [bp + 6], 1         ;offset calculation in bitMaps array
	mov cx,            [bp + 14] ; x co-ordinate
	mov dx,            [bp + 12] ; y co-ordinate
	mov ah,            0x0c
	mov al,            [bp + 4]
	mov bx,            0
	
	reloadSI:
		push di
		mov  di,            [bp + 16]
		add  di,            [bp + 6]
		mov  si,            [di]
		pop  di
		; mov si, [bp + 6]
		; mov si, [bitMaps + si] ;stores the base address of the number
		add  si,            [bp - 2]  ;stores the offset
		mov  si,            [si]
		add  word [bp - 2], 2
		mov  word [bp - 4], 16
		jmp  compare_reload_and_si

	nextLine:
		inc dx
		dec di
		cmp di,            0
		jz  exit_print_bitmap
		mov cx,            [bp + 14]
		mov ax,            [bp + 10]
		mov word [bp - 6], ax
		mov ah,            0x0c
		mov al,            [bp + 4]
		
	compare_reload_and_si:
		cmp word [bp - 6], 0
		jz  nextLine
		cmp word [bp - 4], 0
		jz  reloadSI
		
	drawPixel:
		shl si, 1
		jnc skip_print_bitmap
		int 10h
		skip_print_bitmap:
			inc cx
			dec word [bp - 4]
			dec word [bp - 6]
		jmp compare_reload_and_si

	exit_print_bitmap:			
		popA
		mov sp, bp
		pop bp
ret 14


startBitmap: