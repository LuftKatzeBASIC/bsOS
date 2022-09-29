all:
	nasm src/bsOS.asm -o bin/bsos
	nasm src/fs.asm -o bin/fs
	nasm src/ccp.asm -o bin/ccp
	nasm src/cls.asm -o bin/cls
	nasm src/fmt.asm -o bin/fmt
	nasm src/hlp.asm -o bin/hlp
	nasm src/prt.asm -o bin/prt
	nasm src/hex.asm -o bin/hex
	cat bin/bsos bin/fs bin/ccp bin/cls bin/fmt bin/hlp bin/prt bin/hex > os.bin
	qemu-system-i386 -fda os.bin -nographic