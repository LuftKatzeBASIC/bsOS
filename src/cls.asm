cpu 8086
mov ax,0x03
int 0x10
xor ax,ax
int 0x23
times (510-($-$$)) db 0
dw 0xaa55