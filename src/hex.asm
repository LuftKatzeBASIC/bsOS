org 0x7c00

IBUFF: equ 0x900

_start:
     mov ax,0x03
     int 0x10
     mov si,intro
     mov ah,0x03
     int 0x20
.loop0:
     mov ax,0x025d
     int 0x20
     mov si,IBUFF
     call _readln
     cmp byte [si],0x00
     je .done
.loop1:
     lodsb
     test al,al
     jz .loop0
     call digit
     mov dh,dl
     lodsb
     test al,al
     jz .done
     call digit
     mov al,0x10
     mul dh
     add dl,al
     jmp $
     jmp .loop0
.done:
     mov ax,0x023E
     int 0x20
     mov si,IBUFF
     call _readln
     xor bx,bx
     mov es,bx
     mov bx,0x8000
     mov ah,0x05
     int 0x20
     int 0x22
     
digit:
     cmp al,'0'
     jl _start.done
     cmp al,'9'
     jg .hex
     sub al,'0'
     mov dl,al
     ret
.hex:
     cmp al,'A'
     jl _start.done
     cmp al,'F'
     jg _start.done
     sub al,'A'
     mov dl,al
     ret

_readln:
     push si
     xor cx,cx
.loop0:
     mov ah,0x01
     int 0x20
     cmp al,0x08
     je .back
     cmp ah,0x0e
     je .back
     mov ah,0x02
     int 0x20
     cmp al,0x0d
     jz .enter
     mov byte [si],al
     inc si
     inc cx
     jmp .loop0
.back:
     cmp cx,0x00
     je .loop0
     mov ax,0x0208
     int 0x20
     mov ax,0x0220
     int 0x20
     mov ax,0x0208
     int 0x20
     dec cx
     dec si
     jmp .loop0
.enter:
     mov ax,0x020a
     int 0x20
     mov byte [si],0x00
     pop si
     ret

intro: db "HEX 0.00",13,10,0
times (510-($-$$)) db 0
dw 0xaa55