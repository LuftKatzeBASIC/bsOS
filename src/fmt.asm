org 0x7c00
cpu 8086

_start:
	mov si,sure
	mov ah,0x03
	int 0x20
	mov ah,0x01
	int 0x20
.try:
	xor ax,ax
	mov ss,ax
	mov sp,0x7300
	mov cx,0x200
	mov di,0x600
	xor al,al
	cld
	rep stosb
	xor ax,ax
	int 0x13
	mov ax,0x0301
	xor bx,bx
	mov es,bx
	mov bx,0x600
	mov cx,0x0002
	mov dx,[0x500]
	clc
	int 0x13
	jc .try
	mov si,endl
	mov ah,0x03
	int 0x20
	int 0x22


sure: db "Are you sure? It will remove every file record. (^C to exit) ?",0
endl: db 13,10
times (510-($-$$)) db 0
dw 0xaa55
