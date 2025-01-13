[org 0x0100]

jmp TimerStart

TimerCount: db '0:00', 1

tickCount: db 0

OriginalISRforINT8: dd 0

saveOriginalTimerISR:
    push es
	push ax
	cli
		xor ax, ax
		mov es, ax
		mov ax, [es: 8 * 4]
		mov [OriginalISRforINT8], ax
		mov ax, [es: 8 * 4 + 2]
		mov [OriginalISRforINT8 + 2],ax
	sti
	pop ax
	pop es
ret

HookTimerISR:
	push es
    push ax
	push dx

    xor  ax, ax
    mov  es, ax

    cli
		mov word [es: 8 * 4], TimerISR
		mov [es: 8 * 4 + 2],  cs
    sti

	pop dx
    pop ax
	pop es
ret

UnhookTimerISR:
	push es
	push ax
	push dx

	xor ax, ax
	mov es, ax

	cli 
		mov ax, [OriginalISRforINT8]
		mov [es: 8 * 4], ax
		mov ax, [OriginalISRforINT8 + 2]
		mov [es: 8 * 4 + 2], ax
	sti


	pop dx
	pop ax
	pop es
ret

PrintTimer:

    mov ah, 02h
    mov bh, 0
    mov dl, 58
    mov dh, 2
    int 10h

    mov cx, 4
    mov si, 0
    mov bl, 11  ; color
    mov bh, 0
    mov ah, 0eh

    mov si, TimerCount
    call PrintString


ret

TimerISR:
    pushA

        inc byte [tickCount]
        cmp byte [tickCount], 18
        jnz SkipEverythingInTimerISR

            mov byte [tickCount], 0
            inc byte [TimerCount + 3]
            cmp byte [TimerCount + 3], 0x3A
            jnz TimerInterruptEnd

                mov byte [TimerCount + 3], 0x30
                inc byte [TimerCount + 2]
                cmp byte [TimerCount + 2], 0x36
                jnz TimerInterruptEnd

                    mov byte [TimerCount + 2], 0x30
                    inc byte [TimerCount]
                    cmp byte [TimerCount], 0x3A
                    jnz TimerInterruptEnd
                    mov byte [TimerCount], 0x30

            TimerInterruptEnd:
                
                call PrintTimer

        SkipEverythingInTimerISR:

    popA
        jmp far [cs:OriginalISRforINT8]

iret

TimerStart: