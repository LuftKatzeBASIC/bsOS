org 0x7800
cpu 8086

IBUFF: equ 0x900

_start:
     mov ah,0x03
     mov si,intro
     int 0x20
     cli
     mov word [0x22*4],td
     mov word [0x22*4+2],cs
     mov word [0x23*4],.loop0
     mov word [0x23*4+2],cs
     sti
     int 0x22
.loop0:
     mov ax,0x0e24
     int 0x10
     mov si,IBUFF
     call _readln
     mov si,IBUFF
     cmp byte [si],0x00
     je .loop0
     mov di,0x9000
     mov cx,0x45
     cld
     rep movsb
     mov si,IBUFF
     call cmd
     jmp .loop0


td:
     mov word [0x7c00],0x22cd
     jmp _start.loop0

fwtu:
	push si
.main:
	lodsb
	cmp al,0
	je .done
	cmp al,' '
	je .done
	cmp al,'a'
	jl .main
	cmp al,'z'
	jg .main
	sub byte [si-1],0x20 
	jmp .main
.done:
     mov byte [si-1],0x00
	pop si
	ret

cmd:
     call fwtu
	mov di,comtab
	xor ax,ax
.loop0:
	mov al,[di]
	xor cx,cx
	mov cx,ax
	inc di
	push di
	push si
	repe cmpsb
	pop si
	pop di
	jne .next
	xor ah,ah
	add di,ax
	mov dx,[di]
	jmp dx
.next:
	xor ah,ah
	add di,ax
	add di,2
	cmp byte [di], 0
	je .tryexe
	jmp .loop0
.tryexe:
     mov word [0x7c00+0x200-0x02],0x00
     xor bx,bx
     mov es,bx
     mov bx,0x7c00
     mov ah,0x04
     int 0x20
     cmp ax,0xfffe
     jne .isexe


     mov si,IBUFF
     call __strlenx
     mov word [0x595],cx
     mov di,si
     mov si,e86
     mov cx,0x05
     rep movsb
     mov si,IBUFF

     xor bx,bx
     mov es,bx
     mov bx,0x7c00
     mov ah,0x04
     int 0x20
     cmp ax,0xfffe
.isexe:
     cmp word [0x7c00+0x200-0x02],0xaa55
     je 0x7c00
.error:
     mov bx,[0x595]
     add bx,IBUFF-1
     mov byte [bx],0x00
     mov si,IBUFF
     mov ah,0x03
     int 0x20
     mov si,error
     mov ah,0x03
     int 0x20
     ret






__strlenx:
     xor cx,cx
.loop0:
     inc cx
     cmp byte [si],0x00
     je .done
     inc si
     jmp .loop0
.done:
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





_dir:
     mov ah,0x0e
     mov al,[0x500]
     cmp al,0x80
     jg .fdd
     sub al,0x7E
.fdd:
     add al,'A'
     mov [0x570],al
.loop0:
     xor ax,ax
     int 0x13
     mov ax,0x0201
     xor bx,bx
     mov es,bx
     mov bx,0x600
     mov cx,0x0002
     mov dx,[0x500]
     clc
     int 0x13
     jc .loop0
     mov si,0x600
.loop1:
     cmp si,0x800
     jge .done
     cmp byte [si],0x20
     jle .next
     mov al,[0x570]
     mov ah,0x0e
     int 0x10
     mov ax,0x0e3a
     int 0x10
     push si
     mov ah,0x03
     int 0x20
     mov si,endl
     mov ah,0x03
     int 0x20
     pop si
.next:
     add si,0x0c
     jmp .loop1
.done:
     ret

_era:
     add si,0x04
     mov ah,0x06
     int 0x20
     cmp al,0xfe
     jne .ok
     jmp cmd.error
.ok:
     ret

_exit:
     cmp word [0x7c00],0x22cd
     jne 0x7c00
     mov si,error
     mov ah,0x03
     int 0x20
     ret

comtab:
     db 3,"DIR"
     dw _dir
     db 3,"ERA"
     dw _era
     db 4,"EXIT"
     dw _exit
     db 0


intro: db 13,"bsOS Console Command Processor",13,10,0
error: db "?"
endl: db 13,10,0
e86: db ".E86",0
times (512-($-$$)) db 0