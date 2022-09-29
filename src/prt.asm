org 0x7c00
cpu 8086
_start:
	mov si,0x9000
	cld
.loop0:
	lodsb
	cmp al,0x20
	je .print
	cmp al,0x00
	je .exit
	jmp .loop0
.print:
	mov ah,0x03
	int 0x20
.exit:
	mov si,endl
	mov ah,0x03
	int 0x20
	int 0x22

endl:db 13,10,0
times (510-($-$$)) db 0
dw 0xaa55
