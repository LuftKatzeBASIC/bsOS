org 0x7a00
cpu 8086

mov [0x500],dx

mov si,0x7c00
mov di,0x7a00
cld
mov cx,0x200
rep movsb
jmp _start

_api:

     push ax
     xor ax,ax
     inc ah
     int 0x16
     cmp al,'C'-'@'
     je _ctrlc
     pop ax
     cmp ah,0x00
     je _start
     cmp ah,0x01
     je _getc
     cmp ah,0x02
     je _putc
     cmp ah,0x03
     je _print
     cmp ah,0x04
     je _loadfile
     cmp ah,0x05
     je _writefile
     cmp ah,0x06
     je _delfile
     stc
     iret

_print:
     push ax
.loop0:
     lodsb
     test al,al
     jz .done
     mov ah,0x02
     int 0x20
     jmp .loop0
.done:
     pop ax
     iret

_putc:
     push ax
     mov ah,0x0e
     int 0x10
     pop ax
     iret

_getc:
     xor ax,ax
     int 0x16
     cmp al,'C'-'@'
     je _ctrlc
     iret

__strlen:
     push si
     xor cx,cx
.loop0:
     inc cx
     cmp byte [si],0x00
     je .done
     inc si
     jmp .loop0
.done:
     pop si
     ret

_rdrv:
     mov dx,[0x500]
     xor ax,ax
     int 0x13
     ret

___loadtab:
     push ax
     push es
.main:
     call _rdrv
     mov ax,0x0201
     xor bx,bx
     mov es,bx
     mov bx,0x600
     mov cx,0x0002
     mov dx,[0x500]
     clc
     int 0x13
     jc .main
     pop es
     pop ax
     mov di,0x600
     ret

___savetab:
     call _rdrv
     mov ax,0x0301
     xor bx,bx
     mov es,bx
     mov bx,0x600
     mov cx,0x0002
     mov dx,[0x500]
     clc
     int 0x13
     jc ___savetab
     ret

__calcchs:
     sub si,0x600
     xor dx,dx
     mov ax,si
     mov bx,0x0c
     div bx
     add ax,0x03
     xor cx,cx
.loop0:
     cmp ax,0x00
     je .done
     inc cl
     cmp cl,0x09
     jl .n
.ns:
     xor cl,cl
     inc ch
.n:
     dec ax
     jmp .loop0
.done:
     ret

_delfile:
     call __findfile
     cmp al,0xfe
     je _doner
     mov word [si],0x00
     call ___savetab
     iret

__findfile:
     call ___loadtab
.loop0:
     cmp di,0x800
     jge .doner
     push si
     push di
     call __strlen
     repe cmpsb
     pop di
     pop si
     je .done
     add di,0x0c
     jmp .loop0
.doner:
     mov ax,0xfffe
     ret
.done:
     mov si,di
     ret

_loadfile:
     mov [ad],bx
     mov bx,es
     mov [sg],bx
     call __findfile
     cmp ax,0xfffe
     je _doner
     call __calcchs
     mov [cr],cx
.try:
     mov ax,0x0201
     mov bx,[sg]
     mov es,bx
     mov bx,[ad]
     mov dx,[0x500]
     clc
     int 0x13
     jc .try
     iret

_findempty:
     call ___loadtab
     xor ax,ax
.loop0:
     cmp di,0x800
     jge .err
     cmp byte [di],0x00
     je .done
     add di,0x0c
     jmp .loop0
.err:
     mov ax,0xfffe
.done:
     ret

_writefile:
     mov [515],si
     mov [ad],bx
     mov bx,es
     mov [sg],bx
     call __findfile
     cmp ax,0xfffe
     jne .exists
     call _findempty
     cmp ax,0xfffe
     je _doner
     mov si,[515]
     call __strlen
     rep movsb
     mov si,[515]
     sub di,0x0c
     mov si,di
.exists:
     call __calcchs
     mov [cr],cx
.try:
     call _rdrv
     mov ax,0x0301
     mov bx,[sg]
     mov es,bx
     mov bx,[ad]
     mov cx,[cr]
     mov dx,[0x500]
     clc
     int 0x13
     jc .try
     call ___savetab
     iret


cr:equ 0x550
ad:equ 0x560
sg:equ 0x570


_doner:
     mov ax,0xfffe
     iret

_ctrlc:
     xor ax,ax
     int 0x16
_start:
     xor ax,ax
     mov es,ax
     mov sp,0x7300
     cli
     mov word [0x20*4],_api
     mov word [0x20*4+2],cs
     sti
     mov si,ccp
.loop0:
     mov ah,0x04
     mov bx,0x7800
     int 0x20
     cmp al,0xfe
     jne 0x7800
     xor dx,dx
     inc dx
     int 0x19

ccp: db "CCP.SYS"
edrv: db 0
times (510-($-$$)) db 0
dw 0xaa55