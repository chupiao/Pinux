;current code address
[ORG 0x7c00]

;specify code segment and 16bit mode
[SECTION .text]
[BITS 16]

_start:
	mov ax,cs           ;clear zore for segment register
	mov ds,ax
	mov es,ax
	mov ss,ax
	mov fs,ax
	mov sp,0x7c00       ;stack memory source address

;int 0x10 相当函数，参数从ax,bx,cx,dx这些寄存器取。清掉BIOS的输出。
	mov	ax,	0x0600  ;ah=0x06，表示功能号，功能为上卷清屏.al=0x0,表示上卷行数，为0则表示全部
	mov	bx,	0x0700  ;上卷属性，黑底
	mov	cx,	0       ;左上角坐标(0, 0)
	mov	dx,	0x184f  ;右下角坐标(24, 79), 0x18=24,0x4f=79
	int	0x10        ;0x10中断

;设置光标
	;mov ah, 0x03    ;3号功能号，可以获取光标位置
	;mov bh, 0       ;bh可以获取光标页号，这里只用第1页
	;int 0x10        ;输出，相当返回值
			;ch=光标开始行，cl=光标结束行
			;dh=光标所在行号，dl=光标所在列号
			;这输出在后面显示字符时，调用0x10中断的13功能号时，将会在dx中获取光标位置。

;打印字符
	mov ax, message ;将message内存地址传给ax
			; (0) [0x00007c21] 0000:7c21 (unk. ctxt): mov ax, 0x7c33            ; b8337c   这里0x7c33既是message地址，编译器编译时自动转换。所以message只是方便编程的符号。
	mov bp, ax      ;由于bp不能直接传址，但可以通过通用寄存器传址。es:bp指向字符串首地址
	mov dx, 0x00
	mov cx, 10       ;字符串长度
	mov ax, 0x1301  ;ah=0x13,功能号，显示字符串。al=0x01,设置写字符方式，为显示字符，光标跟随移动。显示字符功能号还有09、0a、0e。oe可以结合循环，判断字符串是否到si寄存器指向0。
	mov bx, 0x2     ;bh=0x0，要显示的页号，这里只用第1页。bl=0x2字符属性，黑底绿字
	int 0x10

	jmp $           ;在这行的地址处循环跳转，相当于while(1)

	message db "Start Boot",13,10,'$'      ;message会在编译时转换为当前行地址，并作为字符串首地址
								 ;<bochs:10> xp /10bc 0x7c33
                                 ;[bochs]:
                                 ;0x00007c33 <bogus+       0>:  S    t    a    r    t         B    o
                                 ;0x00007c3b <bogus+       8>:  o    t
	times 510-($-$$) db 0    ;一个扇区512字节，减去0xaa55为510字节。（$$-$）为上面代码所占用字节数，510-($-$$)为当前行到魔术符字节数。time 字节数 dd 0 ： 填充当前字节开始，到字节数为0
	dw 0xaa55                ;BIOS程序识别MBR魔术符
