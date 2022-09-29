org 0x7c00
cpu 8086

_start:
	mov si,hlp
	mov ah,0x03
	int 0x20
	int 0x22

hlp: db "Internal:",13,10," DIR - Show files",13,10," ERA <file> - delete <file>",13,10
	db "External:",13,10," FMT.E86 - format drive",13,10," CLS.E86 - clear screen",13,10
	db " HLP.E86 - help",13,10," PRT.E86 <msg> - print message",13,10,0
times (510-($-$$)) db 0
dw 0xaa55
