[org 0x0100]
jmp startNotes

notesStackX:      times 81  * 9 db 0 
notesStackY:   times 81  * 9 db 0 
notesStackNumber: times 81  * 9 db 0 
currentValuesInStack: dw 0

UndoButtonFunc:
pushA

    cmp word [currentValuesInStack], 0
    jz exitUndoButton

        dec word [currentValuesInStack]
        mov di, [currentValuesInStack]

        mov dl, [notesStackX + di]
        mov dh, [notesStackY + di]
        mov cl, [notesStackNumber + di]
        mov si, NumbersUserCantEditForRow1
        call returnValueFromBoard
        cmp ax, 1
        jz exitUndoButton 
            
            call eraseNotesAtIndex

    exitUndoButton:
popA
ret

hookcustomISRforINT9ForNotes:
push ax
push es    

cli 

    xor ax, ax
    mov es, ax
    mov word [es:9 * 4], customISRforINT9ForNotes
    mov word [es:9 * 4 + 2], cs

sti

    push word ButtonsArray
    push word [ButtonsXCoordinate]
    push word [ButtonsYCoordinate + 4]
    push word 32
    push word 32
    push word 3
    push word 11
    call drawBitMap

pop es
pop ax
ret

eraseNotesFromBox:          ; pass dx (row / col)
pushA
    call pixelCalculatorFromIndex
    add ax,1
    add dx, 1
    
    push word 36
    push word 36
    push word 0
    push ax
    push dx
    call ClearABox

popA
ret

customISRforINT9ForNotes:
    pushA
    in al, 0x60

        cmp al, 0x16
        jnz checkingInputForHint

            call UndoButtonFunc

    checkingInputForHint:

        cmp al, 0x31
        jnz CheckingInputNumberForNotes

            call HookcustomISRforINT9ForNavigationOnBoard


    	CheckingInputNumberForNotes:

		cmp al, 1
		jle checkForErase			

		cmp al, 0x0b
		jge checkForErase			

		mov dh, [currentRow]
		mov dl, [currentCol]
		sub al, 1

		xor cx, cx
        mov cl, al

        call setNotes

    checkForErase:
        cmp al, 0x12
        jnz exitEnteringNotes

            mov dh, [currentRow]
            mov dl, [currentCol]
            call eraseNotesFromBox
	
    exitEnteringNotes:
        mov al, 0x20
        out 0x20, al
    popA
iret

EnterValueInStack:
pushA

    mov di, [currentValuesInStack]
    mov [notesStackX + di], dl
    mov [notesStackY + di], dh
    mov [notesStackNumber + di], cl
    inc word [currentValuesInStack]
popA
ret

ValuestoAddInNotesPixel: dw 3, 3, 3, 14, 3, 25, 14, 3, 14, 14, 14, 25, 25, 3, 25, 14, 25 ,25

setNotes:       ; pass dx (row/col), cx -- val
pushA    
push cx
    
    call EnterValueInStack

    call pixelCalculatorFromIndex

    add ax, 1
    add dx, 1
    dec cx
    add cx, cx

    mov bx, cx
    add bx, bx

    add ax, [ValuestoAddInNotesPixel + bx + 2]
    add dx, [ValuestoAddInNotesPixel + bx]


    pop cx
    push word bitMaps
    push ax
    push dx
    push word 8
    push word 8
    push cx
    push word 11
    call drawBitMap

popA
ret

eraseNotesAtIndex:              ; value in cx, dx -- row / col
pushA
push cx
    
    call pixelCalculatorFromIndex

    add ax, 1
    add dx, 1
    dec cx
    add cx, cx

    mov bx, cx
    add bx, bx

    add ax, [ValuestoAddInNotesPixel + bx + 2]
    add dx, [ValuestoAddInNotesPixel + bx]


    pop cx
    push word 8
    push word 8
    push word 0         ; color 
    push ax
    push dx
    call ClearABox

popA
ret

startNotes: