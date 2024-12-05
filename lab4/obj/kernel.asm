
bin/kernel：     文件格式 elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02092b7          	lui	t0,0xc0209
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc0200004:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200008:	01e31313          	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc020000c:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc0200010:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc0200014:	fff0031b          	addiw	t1,zero,-1
ffffffffc0200018:	03f31313          	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc020001c:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc0200020:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200024:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc0200028:	c0209137          	lui	sp,0xc0209

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc020002c:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc0200030:	03628293          	addi	t0,t0,54 # ffffffffc0200036 <kern_init>
    jr t0
ffffffffc0200034:	8282                	jr	t0

ffffffffc0200036 <kern_init>:
void grade_backtrace(void);

int
kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200036:	0000a517          	auipc	a0,0xa
ffffffffc020003a:	02a50513          	addi	a0,a0,42 # ffffffffc020a060 <edata>
ffffffffc020003e:	00015617          	auipc	a2,0x15
ffffffffc0200042:	5c260613          	addi	a2,a2,1474 # ffffffffc0215600 <end>
kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	21d040ef          	jal	ra,ffffffffc0204a6a <memset>

    cons_init();                // init the console
ffffffffc0200052:	506000ef          	jal	ra,ffffffffc0200558 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200056:	00005597          	auipc	a1,0x5
ffffffffc020005a:	e7258593          	addi	a1,a1,-398 # ffffffffc0204ec8 <etext>
ffffffffc020005e:	00005517          	auipc	a0,0x5
ffffffffc0200062:	e8a50513          	addi	a0,a0,-374 # ffffffffc0204ee8 <etext+0x20>
ffffffffc0200066:	06a000ef          	jal	ra,ffffffffc02000d0 <cprintf>

    print_kerninfo();
ffffffffc020006a:	1ca000ef          	jal	ra,ffffffffc0200234 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006e:	7a3000ef          	jal	ra,ffffffffc0201010 <pmm_init>

    pic_init();                 // init interrupt controller
ffffffffc0200072:	558000ef          	jal	ra,ffffffffc02005ca <pic_init>
    idt_init();                 // init interrupt descriptor table
ffffffffc0200076:	5d4000ef          	jal	ra,ffffffffc020064a <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc020007a:	48d010ef          	jal	ra,ffffffffc0201d06 <vmm_init>
    proc_init();                // init process table
ffffffffc020007e:	664040ef          	jal	ra,ffffffffc02046e2 <proc_init>
    
    ide_init();                 // init ide devices
ffffffffc0200082:	42a000ef          	jal	ra,ffffffffc02004ac <ide_init>
    swap_init();                // init swap
ffffffffc0200086:	2ce020ef          	jal	ra,ffffffffc0202354 <swap_init>

    clock_init();               // init clock interrupt
ffffffffc020008a:	47a000ef          	jal	ra,ffffffffc0200504 <clock_init>
    intr_enable();              // enable irq interrupt
ffffffffc020008e:	53e000ef          	jal	ra,ffffffffc02005cc <intr_enable>

    cpu_idle();                 // run idle process
ffffffffc0200092:	043040ef          	jal	ra,ffffffffc02048d4 <cpu_idle>

ffffffffc0200096 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200096:	1141                	addi	sp,sp,-16
ffffffffc0200098:	e022                	sd	s0,0(sp)
ffffffffc020009a:	e406                	sd	ra,8(sp)
ffffffffc020009c:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc020009e:	4bc000ef          	jal	ra,ffffffffc020055a <cons_putc>
    (*cnt) ++;
ffffffffc02000a2:	401c                	lw	a5,0(s0)
}
ffffffffc02000a4:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc02000a6:	2785                	addiw	a5,a5,1
ffffffffc02000a8:	c01c                	sw	a5,0(s0)
}
ffffffffc02000aa:	6402                	ld	s0,0(sp)
ffffffffc02000ac:	0141                	addi	sp,sp,16
ffffffffc02000ae:	8082                	ret

ffffffffc02000b0 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000b0:	1101                	addi	sp,sp,-32
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000b2:	86ae                	mv	a3,a1
ffffffffc02000b4:	862a                	mv	a2,a0
ffffffffc02000b6:	006c                	addi	a1,sp,12
ffffffffc02000b8:	00000517          	auipc	a0,0x0
ffffffffc02000bc:	fde50513          	addi	a0,a0,-34 # ffffffffc0200096 <cputch>
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000c0:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000c2:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c4:	26d040ef          	jal	ra,ffffffffc0204b30 <vprintfmt>
    return cnt;
}
ffffffffc02000c8:	60e2                	ld	ra,24(sp)
ffffffffc02000ca:	4532                	lw	a0,12(sp)
ffffffffc02000cc:	6105                	addi	sp,sp,32
ffffffffc02000ce:	8082                	ret

ffffffffc02000d0 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000d0:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000d2:	02810313          	addi	t1,sp,40 # ffffffffc0209028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000d6:	f42e                	sd	a1,40(sp)
ffffffffc02000d8:	f832                	sd	a2,48(sp)
ffffffffc02000da:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000dc:	862a                	mv	a2,a0
ffffffffc02000de:	004c                	addi	a1,sp,4
ffffffffc02000e0:	00000517          	auipc	a0,0x0
ffffffffc02000e4:	fb650513          	addi	a0,a0,-74 # ffffffffc0200096 <cputch>
ffffffffc02000e8:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
ffffffffc02000ea:	ec06                	sd	ra,24(sp)
ffffffffc02000ec:	e0ba                	sd	a4,64(sp)
ffffffffc02000ee:	e4be                	sd	a5,72(sp)
ffffffffc02000f0:	e8c2                	sd	a6,80(sp)
ffffffffc02000f2:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000f4:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000f6:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000f8:	239040ef          	jal	ra,ffffffffc0204b30 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000fc:	60e2                	ld	ra,24(sp)
ffffffffc02000fe:	4512                	lw	a0,4(sp)
ffffffffc0200100:	6125                	addi	sp,sp,96
ffffffffc0200102:	8082                	ret

ffffffffc0200104 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc0200104:	a999                	j	ffffffffc020055a <cons_putc>

ffffffffc0200106 <getchar>:
    return cnt;
}

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc0200106:	1141                	addi	sp,sp,-16
ffffffffc0200108:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc020010a:	484000ef          	jal	ra,ffffffffc020058e <cons_getc>
ffffffffc020010e:	dd75                	beqz	a0,ffffffffc020010a <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200110:	60a2                	ld	ra,8(sp)
ffffffffc0200112:	0141                	addi	sp,sp,16
ffffffffc0200114:	8082                	ret

ffffffffc0200116 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0200116:	715d                	addi	sp,sp,-80
ffffffffc0200118:	e486                	sd	ra,72(sp)
ffffffffc020011a:	e0a2                	sd	s0,64(sp)
ffffffffc020011c:	fc26                	sd	s1,56(sp)
ffffffffc020011e:	f84a                	sd	s2,48(sp)
ffffffffc0200120:	f44e                	sd	s3,40(sp)
ffffffffc0200122:	f052                	sd	s4,32(sp)
ffffffffc0200124:	ec56                	sd	s5,24(sp)
ffffffffc0200126:	e85a                	sd	s6,16(sp)
ffffffffc0200128:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc020012a:	c901                	beqz	a0,ffffffffc020013a <readline+0x24>
        cprintf("%s", prompt);
ffffffffc020012c:	85aa                	mv	a1,a0
ffffffffc020012e:	00005517          	auipc	a0,0x5
ffffffffc0200132:	dc250513          	addi	a0,a0,-574 # ffffffffc0204ef0 <etext+0x28>
ffffffffc0200136:	f9bff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
readline(const char *prompt) {
ffffffffc020013a:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020013c:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc020013e:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0200140:	4aa9                	li	s5,10
ffffffffc0200142:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0200144:	0000ab97          	auipc	s7,0xa
ffffffffc0200148:	f1cb8b93          	addi	s7,s7,-228 # ffffffffc020a060 <edata>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020014c:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0200150:	fb7ff0ef          	jal	ra,ffffffffc0200106 <getchar>
ffffffffc0200154:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0200156:	00054b63          	bltz	a0,ffffffffc020016c <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020015a:	00a95b63          	bge	s2,a0,ffffffffc0200170 <readline+0x5a>
ffffffffc020015e:	029a5463          	bge	s4,s1,ffffffffc0200186 <readline+0x70>
        c = getchar();
ffffffffc0200162:	fa5ff0ef          	jal	ra,ffffffffc0200106 <getchar>
ffffffffc0200166:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0200168:	fe0559e3          	bgez	a0,ffffffffc020015a <readline+0x44>
            return NULL;
ffffffffc020016c:	4501                	li	a0,0
ffffffffc020016e:	a099                	j	ffffffffc02001b4 <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc0200170:	03341463          	bne	s0,s3,ffffffffc0200198 <readline+0x82>
ffffffffc0200174:	e8b9                	bnez	s1,ffffffffc02001ca <readline+0xb4>
        c = getchar();
ffffffffc0200176:	f91ff0ef          	jal	ra,ffffffffc0200106 <getchar>
ffffffffc020017a:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc020017c:	fe0548e3          	bltz	a0,ffffffffc020016c <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0200180:	fea958e3          	bge	s2,a0,ffffffffc0200170 <readline+0x5a>
ffffffffc0200184:	4481                	li	s1,0
            cputchar(c);
ffffffffc0200186:	8522                	mv	a0,s0
ffffffffc0200188:	f7dff0ef          	jal	ra,ffffffffc0200104 <cputchar>
            buf[i ++] = c;
ffffffffc020018c:	009b87b3          	add	a5,s7,s1
ffffffffc0200190:	00878023          	sb	s0,0(a5)
ffffffffc0200194:	2485                	addiw	s1,s1,1
ffffffffc0200196:	bf6d                	j	ffffffffc0200150 <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc0200198:	01540463          	beq	s0,s5,ffffffffc02001a0 <readline+0x8a>
ffffffffc020019c:	fb641ae3          	bne	s0,s6,ffffffffc0200150 <readline+0x3a>
            cputchar(c);
ffffffffc02001a0:	8522                	mv	a0,s0
ffffffffc02001a2:	f63ff0ef          	jal	ra,ffffffffc0200104 <cputchar>
            buf[i] = '\0';
ffffffffc02001a6:	0000a517          	auipc	a0,0xa
ffffffffc02001aa:	eba50513          	addi	a0,a0,-326 # ffffffffc020a060 <edata>
ffffffffc02001ae:	94aa                	add	s1,s1,a0
ffffffffc02001b0:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc02001b4:	60a6                	ld	ra,72(sp)
ffffffffc02001b6:	6406                	ld	s0,64(sp)
ffffffffc02001b8:	74e2                	ld	s1,56(sp)
ffffffffc02001ba:	7942                	ld	s2,48(sp)
ffffffffc02001bc:	79a2                	ld	s3,40(sp)
ffffffffc02001be:	7a02                	ld	s4,32(sp)
ffffffffc02001c0:	6ae2                	ld	s5,24(sp)
ffffffffc02001c2:	6b42                	ld	s6,16(sp)
ffffffffc02001c4:	6ba2                	ld	s7,8(sp)
ffffffffc02001c6:	6161                	addi	sp,sp,80
ffffffffc02001c8:	8082                	ret
            cputchar(c);
ffffffffc02001ca:	4521                	li	a0,8
ffffffffc02001cc:	f39ff0ef          	jal	ra,ffffffffc0200104 <cputchar>
            i --;
ffffffffc02001d0:	34fd                	addiw	s1,s1,-1
ffffffffc02001d2:	bfbd                	j	ffffffffc0200150 <readline+0x3a>

ffffffffc02001d4 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc02001d4:	00015317          	auipc	t1,0x15
ffffffffc02001d8:	29c30313          	addi	t1,t1,668 # ffffffffc0215470 <is_panic>
ffffffffc02001dc:	00032303          	lw	t1,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc02001e0:	715d                	addi	sp,sp,-80
ffffffffc02001e2:	ec06                	sd	ra,24(sp)
ffffffffc02001e4:	e822                	sd	s0,16(sp)
ffffffffc02001e6:	f436                	sd	a3,40(sp)
ffffffffc02001e8:	f83a                	sd	a4,48(sp)
ffffffffc02001ea:	fc3e                	sd	a5,56(sp)
ffffffffc02001ec:	e0c2                	sd	a6,64(sp)
ffffffffc02001ee:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02001f0:	02031c63          	bnez	t1,ffffffffc0200228 <__panic+0x54>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc02001f4:	4785                	li	a5,1
ffffffffc02001f6:	8432                	mv	s0,a2
ffffffffc02001f8:	00015717          	auipc	a4,0x15
ffffffffc02001fc:	26f72c23          	sw	a5,632(a4) # ffffffffc0215470 <is_panic>

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200200:	862e                	mv	a2,a1
    va_start(ap, fmt);
ffffffffc0200202:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200204:	85aa                	mv	a1,a0
ffffffffc0200206:	00005517          	auipc	a0,0x5
ffffffffc020020a:	cf250513          	addi	a0,a0,-782 # ffffffffc0204ef8 <etext+0x30>
    va_start(ap, fmt);
ffffffffc020020e:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200210:	ec1ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200214:	65a2                	ld	a1,8(sp)
ffffffffc0200216:	8522                	mv	a0,s0
ffffffffc0200218:	e99ff0ef          	jal	ra,ffffffffc02000b0 <vcprintf>
    cprintf("\n");
ffffffffc020021c:	00006517          	auipc	a0,0x6
ffffffffc0200220:	a9450513          	addi	a0,a0,-1388 # ffffffffc0205cb0 <commands+0xc98>
ffffffffc0200224:	eadff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc0200228:	3aa000ef          	jal	ra,ffffffffc02005d2 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc020022c:	4501                	li	a0,0
ffffffffc020022e:	130000ef          	jal	ra,ffffffffc020035e <kmonitor>
ffffffffc0200232:	bfed                	j	ffffffffc020022c <__panic+0x58>

ffffffffc0200234 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc0200234:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200236:	00005517          	auipc	a0,0x5
ffffffffc020023a:	d1250513          	addi	a0,a0,-750 # ffffffffc0204f48 <etext+0x80>
void print_kerninfo(void) {
ffffffffc020023e:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200240:	e91ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc0200244:	00000597          	auipc	a1,0x0
ffffffffc0200248:	df258593          	addi	a1,a1,-526 # ffffffffc0200036 <kern_init>
ffffffffc020024c:	00005517          	auipc	a0,0x5
ffffffffc0200250:	d1c50513          	addi	a0,a0,-740 # ffffffffc0204f68 <etext+0xa0>
ffffffffc0200254:	e7dff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc0200258:	00005597          	auipc	a1,0x5
ffffffffc020025c:	c7058593          	addi	a1,a1,-912 # ffffffffc0204ec8 <etext>
ffffffffc0200260:	00005517          	auipc	a0,0x5
ffffffffc0200264:	d2850513          	addi	a0,a0,-728 # ffffffffc0204f88 <etext+0xc0>
ffffffffc0200268:	e69ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc020026c:	0000a597          	auipc	a1,0xa
ffffffffc0200270:	df458593          	addi	a1,a1,-524 # ffffffffc020a060 <edata>
ffffffffc0200274:	00005517          	auipc	a0,0x5
ffffffffc0200278:	d3450513          	addi	a0,a0,-716 # ffffffffc0204fa8 <etext+0xe0>
ffffffffc020027c:	e55ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200280:	00015597          	auipc	a1,0x15
ffffffffc0200284:	38058593          	addi	a1,a1,896 # ffffffffc0215600 <end>
ffffffffc0200288:	00005517          	auipc	a0,0x5
ffffffffc020028c:	d4050513          	addi	a0,a0,-704 # ffffffffc0204fc8 <etext+0x100>
ffffffffc0200290:	e41ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200294:	00015597          	auipc	a1,0x15
ffffffffc0200298:	76b58593          	addi	a1,a1,1899 # ffffffffc02159ff <end+0x3ff>
ffffffffc020029c:	00000797          	auipc	a5,0x0
ffffffffc02002a0:	d9a78793          	addi	a5,a5,-614 # ffffffffc0200036 <kern_init>
ffffffffc02002a4:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02002a8:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02002ac:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02002ae:	3ff5f593          	andi	a1,a1,1023
ffffffffc02002b2:	95be                	add	a1,a1,a5
ffffffffc02002b4:	85a9                	srai	a1,a1,0xa
ffffffffc02002b6:	00005517          	auipc	a0,0x5
ffffffffc02002ba:	d3250513          	addi	a0,a0,-718 # ffffffffc0204fe8 <etext+0x120>
}
ffffffffc02002be:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02002c0:	bd01                	j	ffffffffc02000d0 <cprintf>

ffffffffc02002c2 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02002c2:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc02002c4:	00005617          	auipc	a2,0x5
ffffffffc02002c8:	c5460613          	addi	a2,a2,-940 # ffffffffc0204f18 <etext+0x50>
ffffffffc02002cc:	04d00593          	li	a1,77
ffffffffc02002d0:	00005517          	auipc	a0,0x5
ffffffffc02002d4:	c6050513          	addi	a0,a0,-928 # ffffffffc0204f30 <etext+0x68>
void print_stackframe(void) {
ffffffffc02002d8:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02002da:	efbff0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc02002de <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002de:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002e0:	00005617          	auipc	a2,0x5
ffffffffc02002e4:	e1860613          	addi	a2,a2,-488 # ffffffffc02050f8 <commands+0xe0>
ffffffffc02002e8:	00005597          	auipc	a1,0x5
ffffffffc02002ec:	e3058593          	addi	a1,a1,-464 # ffffffffc0205118 <commands+0x100>
ffffffffc02002f0:	00005517          	auipc	a0,0x5
ffffffffc02002f4:	e3050513          	addi	a0,a0,-464 # ffffffffc0205120 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002f8:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002fa:	dd7ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc02002fe:	00005617          	auipc	a2,0x5
ffffffffc0200302:	e3260613          	addi	a2,a2,-462 # ffffffffc0205130 <commands+0x118>
ffffffffc0200306:	00005597          	auipc	a1,0x5
ffffffffc020030a:	e5258593          	addi	a1,a1,-430 # ffffffffc0205158 <commands+0x140>
ffffffffc020030e:	00005517          	auipc	a0,0x5
ffffffffc0200312:	e1250513          	addi	a0,a0,-494 # ffffffffc0205120 <commands+0x108>
ffffffffc0200316:	dbbff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc020031a:	00005617          	auipc	a2,0x5
ffffffffc020031e:	e4e60613          	addi	a2,a2,-434 # ffffffffc0205168 <commands+0x150>
ffffffffc0200322:	00005597          	auipc	a1,0x5
ffffffffc0200326:	e6658593          	addi	a1,a1,-410 # ffffffffc0205188 <commands+0x170>
ffffffffc020032a:	00005517          	auipc	a0,0x5
ffffffffc020032e:	df650513          	addi	a0,a0,-522 # ffffffffc0205120 <commands+0x108>
ffffffffc0200332:	d9fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    }
    return 0;
}
ffffffffc0200336:	60a2                	ld	ra,8(sp)
ffffffffc0200338:	4501                	li	a0,0
ffffffffc020033a:	0141                	addi	sp,sp,16
ffffffffc020033c:	8082                	ret

ffffffffc020033e <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc020033e:	1141                	addi	sp,sp,-16
ffffffffc0200340:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200342:	ef3ff0ef          	jal	ra,ffffffffc0200234 <print_kerninfo>
    return 0;
}
ffffffffc0200346:	60a2                	ld	ra,8(sp)
ffffffffc0200348:	4501                	li	a0,0
ffffffffc020034a:	0141                	addi	sp,sp,16
ffffffffc020034c:	8082                	ret

ffffffffc020034e <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc020034e:	1141                	addi	sp,sp,-16
ffffffffc0200350:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200352:	f71ff0ef          	jal	ra,ffffffffc02002c2 <print_stackframe>
    return 0;
}
ffffffffc0200356:	60a2                	ld	ra,8(sp)
ffffffffc0200358:	4501                	li	a0,0
ffffffffc020035a:	0141                	addi	sp,sp,16
ffffffffc020035c:	8082                	ret

ffffffffc020035e <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc020035e:	7115                	addi	sp,sp,-224
ffffffffc0200360:	e962                	sd	s8,144(sp)
ffffffffc0200362:	8c2a                	mv	s8,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200364:	00005517          	auipc	a0,0x5
ffffffffc0200368:	cfc50513          	addi	a0,a0,-772 # ffffffffc0205060 <commands+0x48>
kmonitor(struct trapframe *tf) {
ffffffffc020036c:	ed86                	sd	ra,216(sp)
ffffffffc020036e:	e9a2                	sd	s0,208(sp)
ffffffffc0200370:	e5a6                	sd	s1,200(sp)
ffffffffc0200372:	e1ca                	sd	s2,192(sp)
ffffffffc0200374:	fd4e                	sd	s3,184(sp)
ffffffffc0200376:	f952                	sd	s4,176(sp)
ffffffffc0200378:	f556                	sd	s5,168(sp)
ffffffffc020037a:	f15a                	sd	s6,160(sp)
ffffffffc020037c:	ed5e                	sd	s7,152(sp)
ffffffffc020037e:	e566                	sd	s9,136(sp)
ffffffffc0200380:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200382:	d4fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc0200386:	00005517          	auipc	a0,0x5
ffffffffc020038a:	d0250513          	addi	a0,a0,-766 # ffffffffc0205088 <commands+0x70>
ffffffffc020038e:	d43ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    if (tf != NULL) {
ffffffffc0200392:	000c0563          	beqz	s8,ffffffffc020039c <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc0200396:	8562                	mv	a0,s8
ffffffffc0200398:	49a000ef          	jal	ra,ffffffffc0200832 <print_trapframe>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc020039c:	4501                	li	a0,0
ffffffffc020039e:	4581                	li	a1,0
ffffffffc02003a0:	4601                	li	a2,0
ffffffffc02003a2:	48a1                	li	a7,8
ffffffffc02003a4:	00000073          	ecall
ffffffffc02003a8:	00005c97          	auipc	s9,0x5
ffffffffc02003ac:	c70c8c93          	addi	s9,s9,-912 # ffffffffc0205018 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02003b0:	00005997          	auipc	s3,0x5
ffffffffc02003b4:	d0098993          	addi	s3,s3,-768 # ffffffffc02050b0 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003b8:	00005917          	auipc	s2,0x5
ffffffffc02003bc:	d0090913          	addi	s2,s2,-768 # ffffffffc02050b8 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc02003c0:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02003c2:	00005b17          	auipc	s6,0x5
ffffffffc02003c6:	cfeb0b13          	addi	s6,s6,-770 # ffffffffc02050c0 <commands+0xa8>
    if (argc == 0) {
ffffffffc02003ca:	00005a97          	auipc	s5,0x5
ffffffffc02003ce:	d4ea8a93          	addi	s5,s5,-690 # ffffffffc0205118 <commands+0x100>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003d2:	4b8d                	li	s7,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02003d4:	854e                	mv	a0,s3
ffffffffc02003d6:	d41ff0ef          	jal	ra,ffffffffc0200116 <readline>
ffffffffc02003da:	842a                	mv	s0,a0
ffffffffc02003dc:	dd65                	beqz	a0,ffffffffc02003d4 <kmonitor+0x76>
ffffffffc02003de:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02003e2:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003e4:	c999                	beqz	a1,ffffffffc02003fa <kmonitor+0x9c>
ffffffffc02003e6:	854a                	mv	a0,s2
ffffffffc02003e8:	664040ef          	jal	ra,ffffffffc0204a4c <strchr>
ffffffffc02003ec:	c925                	beqz	a0,ffffffffc020045c <kmonitor+0xfe>
            *buf ++ = '\0';
ffffffffc02003ee:	00144583          	lbu	a1,1(s0)
ffffffffc02003f2:	00040023          	sb	zero,0(s0)
ffffffffc02003f6:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003f8:	f5fd                	bnez	a1,ffffffffc02003e6 <kmonitor+0x88>
    if (argc == 0) {
ffffffffc02003fa:	dce9                	beqz	s1,ffffffffc02003d4 <kmonitor+0x76>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003fc:	6582                	ld	a1,0(sp)
ffffffffc02003fe:	00005d17          	auipc	s10,0x5
ffffffffc0200402:	c1ad0d13          	addi	s10,s10,-998 # ffffffffc0205018 <commands>
    if (argc == 0) {
ffffffffc0200406:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200408:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020040a:	0d61                	addi	s10,s10,24
ffffffffc020040c:	616040ef          	jal	ra,ffffffffc0204a22 <strcmp>
ffffffffc0200410:	c919                	beqz	a0,ffffffffc0200426 <kmonitor+0xc8>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200412:	2405                	addiw	s0,s0,1
ffffffffc0200414:	09740463          	beq	s0,s7,ffffffffc020049c <kmonitor+0x13e>
ffffffffc0200418:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020041c:	6582                	ld	a1,0(sp)
ffffffffc020041e:	0d61                	addi	s10,s10,24
ffffffffc0200420:	602040ef          	jal	ra,ffffffffc0204a22 <strcmp>
ffffffffc0200424:	f57d                	bnez	a0,ffffffffc0200412 <kmonitor+0xb4>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc0200426:	00141793          	slli	a5,s0,0x1
ffffffffc020042a:	97a2                	add	a5,a5,s0
ffffffffc020042c:	078e                	slli	a5,a5,0x3
ffffffffc020042e:	97e6                	add	a5,a5,s9
ffffffffc0200430:	6b9c                	ld	a5,16(a5)
ffffffffc0200432:	8662                	mv	a2,s8
ffffffffc0200434:	002c                	addi	a1,sp,8
ffffffffc0200436:	fff4851b          	addiw	a0,s1,-1
ffffffffc020043a:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc020043c:	f8055ce3          	bgez	a0,ffffffffc02003d4 <kmonitor+0x76>
}
ffffffffc0200440:	60ee                	ld	ra,216(sp)
ffffffffc0200442:	644e                	ld	s0,208(sp)
ffffffffc0200444:	64ae                	ld	s1,200(sp)
ffffffffc0200446:	690e                	ld	s2,192(sp)
ffffffffc0200448:	79ea                	ld	s3,184(sp)
ffffffffc020044a:	7a4a                	ld	s4,176(sp)
ffffffffc020044c:	7aaa                	ld	s5,168(sp)
ffffffffc020044e:	7b0a                	ld	s6,160(sp)
ffffffffc0200450:	6bea                	ld	s7,152(sp)
ffffffffc0200452:	6c4a                	ld	s8,144(sp)
ffffffffc0200454:	6caa                	ld	s9,136(sp)
ffffffffc0200456:	6d0a                	ld	s10,128(sp)
ffffffffc0200458:	612d                	addi	sp,sp,224
ffffffffc020045a:	8082                	ret
        if (*buf == '\0') {
ffffffffc020045c:	00044783          	lbu	a5,0(s0)
ffffffffc0200460:	dfc9                	beqz	a5,ffffffffc02003fa <kmonitor+0x9c>
        if (argc == MAXARGS - 1) {
ffffffffc0200462:	03448863          	beq	s1,s4,ffffffffc0200492 <kmonitor+0x134>
        argv[argc ++] = buf;
ffffffffc0200466:	00349793          	slli	a5,s1,0x3
ffffffffc020046a:	0118                	addi	a4,sp,128
ffffffffc020046c:	97ba                	add	a5,a5,a4
ffffffffc020046e:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200472:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc0200476:	2485                	addiw	s1,s1,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200478:	e591                	bnez	a1,ffffffffc0200484 <kmonitor+0x126>
ffffffffc020047a:	b749                	j	ffffffffc02003fc <kmonitor+0x9e>
            buf ++;
ffffffffc020047c:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020047e:	00044583          	lbu	a1,0(s0)
ffffffffc0200482:	ddad                	beqz	a1,ffffffffc02003fc <kmonitor+0x9e>
ffffffffc0200484:	854a                	mv	a0,s2
ffffffffc0200486:	5c6040ef          	jal	ra,ffffffffc0204a4c <strchr>
ffffffffc020048a:	d96d                	beqz	a0,ffffffffc020047c <kmonitor+0x11e>
ffffffffc020048c:	00044583          	lbu	a1,0(s0)
ffffffffc0200490:	bf91                	j	ffffffffc02003e4 <kmonitor+0x86>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200492:	45c1                	li	a1,16
ffffffffc0200494:	855a                	mv	a0,s6
ffffffffc0200496:	c3bff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc020049a:	b7f1                	j	ffffffffc0200466 <kmonitor+0x108>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc020049c:	6582                	ld	a1,0(sp)
ffffffffc020049e:	00005517          	auipc	a0,0x5
ffffffffc02004a2:	c4250513          	addi	a0,a0,-958 # ffffffffc02050e0 <commands+0xc8>
ffffffffc02004a6:	c2bff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    return 0;
ffffffffc02004aa:	b72d                	j	ffffffffc02003d4 <kmonitor+0x76>

ffffffffc02004ac <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc02004ac:	8082                	ret

ffffffffc02004ae <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc02004ae:	00253513          	sltiu	a0,a0,2
ffffffffc02004b2:	8082                	ret

ffffffffc02004b4 <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc02004b4:	03800513          	li	a0,56
ffffffffc02004b8:	8082                	ret

ffffffffc02004ba <ide_read_secs>:

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02004ba:	0000a797          	auipc	a5,0xa
ffffffffc02004be:	fa678793          	addi	a5,a5,-90 # ffffffffc020a460 <ide>
ffffffffc02004c2:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {
ffffffffc02004c6:	1141                	addi	sp,sp,-16
ffffffffc02004c8:	8532                	mv	a0,a2
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02004ca:	95be                	add	a1,a1,a5
ffffffffc02004cc:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {
ffffffffc02004d0:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02004d2:	5aa040ef          	jal	ra,ffffffffc0204a7c <memcpy>
    return 0;
}
ffffffffc02004d6:	60a2                	ld	ra,8(sp)
ffffffffc02004d8:	4501                	li	a0,0
ffffffffc02004da:	0141                	addi	sp,sp,16
ffffffffc02004dc:	8082                	ret

ffffffffc02004de <ide_write_secs>:

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
ffffffffc02004de:	8732                	mv	a4,a2
    int iobase = secno * SECTSIZE;
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004e0:	0095979b          	slliw	a5,a1,0x9
ffffffffc02004e4:	0000a517          	auipc	a0,0xa
ffffffffc02004e8:	f7c50513          	addi	a0,a0,-132 # ffffffffc020a460 <ide>
                   size_t nsecs) {
ffffffffc02004ec:	1141                	addi	sp,sp,-16
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004ee:	00969613          	slli	a2,a3,0x9
ffffffffc02004f2:	85ba                	mv	a1,a4
ffffffffc02004f4:	953e                	add	a0,a0,a5
                   size_t nsecs) {
ffffffffc02004f6:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004f8:	584040ef          	jal	ra,ffffffffc0204a7c <memcpy>
    return 0;
}
ffffffffc02004fc:	60a2                	ld	ra,8(sp)
ffffffffc02004fe:	4501                	li	a0,0
ffffffffc0200500:	0141                	addi	sp,sp,16
ffffffffc0200502:	8082                	ret

ffffffffc0200504 <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc0200504:	67e1                	lui	a5,0x18
ffffffffc0200506:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc020050a:	00015717          	auipc	a4,0x15
ffffffffc020050e:	f6f73723          	sd	a5,-146(a4) # ffffffffc0215478 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200512:	c0102573          	rdtime	a0
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc0200516:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200518:	953e                	add	a0,a0,a5
ffffffffc020051a:	4601                	li	a2,0
ffffffffc020051c:	4881                	li	a7,0
ffffffffc020051e:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc0200522:	02000793          	li	a5,32
ffffffffc0200526:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc020052a:	00005517          	auipc	a0,0x5
ffffffffc020052e:	c6e50513          	addi	a0,a0,-914 # ffffffffc0205198 <commands+0x180>
    ticks = 0;
ffffffffc0200532:	00015797          	auipc	a5,0x15
ffffffffc0200536:	f807bf23          	sd	zero,-98(a5) # ffffffffc02154d0 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020053a:	be59                	j	ffffffffc02000d0 <cprintf>

ffffffffc020053c <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020053c:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200540:	00015797          	auipc	a5,0x15
ffffffffc0200544:	f3878793          	addi	a5,a5,-200 # ffffffffc0215478 <timebase>
ffffffffc0200548:	639c                	ld	a5,0(a5)
ffffffffc020054a:	4581                	li	a1,0
ffffffffc020054c:	4601                	li	a2,0
ffffffffc020054e:	953e                	add	a0,a0,a5
ffffffffc0200550:	4881                	li	a7,0
ffffffffc0200552:	00000073          	ecall
ffffffffc0200556:	8082                	ret

ffffffffc0200558 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200558:	8082                	ret

ffffffffc020055a <cons_putc>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020055a:	100027f3          	csrr	a5,sstatus
ffffffffc020055e:	8b89                	andi	a5,a5,2
ffffffffc0200560:	0ff57513          	andi	a0,a0,255
ffffffffc0200564:	e799                	bnez	a5,ffffffffc0200572 <cons_putc+0x18>
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc0200566:	4581                	li	a1,0
ffffffffc0200568:	4601                	li	a2,0
ffffffffc020056a:	4885                	li	a7,1
ffffffffc020056c:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc0200570:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc0200572:	1101                	addi	sp,sp,-32
ffffffffc0200574:	ec06                	sd	ra,24(sp)
ffffffffc0200576:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0200578:	05a000ef          	jal	ra,ffffffffc02005d2 <intr_disable>
ffffffffc020057c:	6522                	ld	a0,8(sp)
ffffffffc020057e:	4581                	li	a1,0
ffffffffc0200580:	4601                	li	a2,0
ffffffffc0200582:	4885                	li	a7,1
ffffffffc0200584:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);// 确保在字符被发送到控制台的过程中，不会发生中断
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200588:	60e2                	ld	ra,24(sp)
ffffffffc020058a:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020058c:	a081                	j	ffffffffc02005cc <intr_enable>

ffffffffc020058e <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020058e:	100027f3          	csrr	a5,sstatus
ffffffffc0200592:	8b89                	andi	a5,a5,2
ffffffffc0200594:	eb89                	bnez	a5,ffffffffc02005a6 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc0200596:	4501                	li	a0,0
ffffffffc0200598:	4581                	li	a1,0
ffffffffc020059a:	4601                	li	a2,0
ffffffffc020059c:	4889                	li	a7,2
ffffffffc020059e:	00000073          	ecall
ffffffffc02005a2:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();// 读取操作需要一次性完成
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc02005a4:	8082                	ret
int cons_getc(void) {
ffffffffc02005a6:	1101                	addi	sp,sp,-32
ffffffffc02005a8:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc02005aa:	028000ef          	jal	ra,ffffffffc02005d2 <intr_disable>
ffffffffc02005ae:	4501                	li	a0,0
ffffffffc02005b0:	4581                	li	a1,0
ffffffffc02005b2:	4601                	li	a2,0
ffffffffc02005b4:	4889                	li	a7,2
ffffffffc02005b6:	00000073          	ecall
ffffffffc02005ba:	2501                	sext.w	a0,a0
ffffffffc02005bc:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc02005be:	00e000ef          	jal	ra,ffffffffc02005cc <intr_enable>
}
ffffffffc02005c2:	60e2                	ld	ra,24(sp)
ffffffffc02005c4:	6522                	ld	a0,8(sp)
ffffffffc02005c6:	6105                	addi	sp,sp,32
ffffffffc02005c8:	8082                	ret

ffffffffc02005ca <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
ffffffffc02005ca:	8082                	ret

ffffffffc02005cc <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc02005cc:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc02005d0:	8082                	ret

ffffffffc02005d2 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc02005d2:	100177f3          	csrrci	a5,sstatus,2
ffffffffc02005d6:	8082                	ret

ffffffffc02005d8 <pgfault_handler>:
    set_csr(sstatus, SSTATUS_SUM);
}

/* trap_in_kernel - test if trap happened in kernel */
bool trap_in_kernel(struct trapframe *tf) {
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02005d8:	10053783          	ld	a5,256(a0)
    cprintf("page falut at 0x%08x: %c/%c\n", tf->badvaddr,
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int pgfault_handler(struct trapframe *tf) {
ffffffffc02005dc:	1141                	addi	sp,sp,-16
ffffffffc02005de:	e022                	sd	s0,0(sp)
ffffffffc02005e0:	e406                	sd	ra,8(sp)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02005e2:	1007f793          	andi	a5,a5,256
static int pgfault_handler(struct trapframe *tf) {
ffffffffc02005e6:	842a                	mv	s0,a0
    cprintf("page falut at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc02005e8:	11053583          	ld	a1,272(a0)
ffffffffc02005ec:	05500613          	li	a2,85
ffffffffc02005f0:	c399                	beqz	a5,ffffffffc02005f6 <pgfault_handler+0x1e>
ffffffffc02005f2:	04b00613          	li	a2,75
ffffffffc02005f6:	11843703          	ld	a4,280(s0)
ffffffffc02005fa:	47bd                	li	a5,15
ffffffffc02005fc:	05700693          	li	a3,87
ffffffffc0200600:	00f70463          	beq	a4,a5,ffffffffc0200608 <pgfault_handler+0x30>
ffffffffc0200604:	05200693          	li	a3,82
ffffffffc0200608:	00005517          	auipc	a0,0x5
ffffffffc020060c:	e8850513          	addi	a0,a0,-376 # ffffffffc0205490 <commands+0x478>
ffffffffc0200610:	ac1ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
    if (check_mm_struct != NULL) {
ffffffffc0200614:	00015797          	auipc	a5,0x15
ffffffffc0200618:	ee478793          	addi	a5,a5,-284 # ffffffffc02154f8 <check_mm_struct>
ffffffffc020061c:	6388                	ld	a0,0(a5)
ffffffffc020061e:	c911                	beqz	a0,ffffffffc0200632 <pgfault_handler+0x5a>
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc0200620:	11043603          	ld	a2,272(s0)
ffffffffc0200624:	11842583          	lw	a1,280(s0)
    }
    panic("unhandled page fault.\n");
}
ffffffffc0200628:	6402                	ld	s0,0(sp)
ffffffffc020062a:	60a2                	ld	ra,8(sp)
ffffffffc020062c:	0141                	addi	sp,sp,16
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc020062e:	41f0106f          	j	ffffffffc020224c <do_pgfault>
    panic("unhandled page fault.\n");
ffffffffc0200632:	00005617          	auipc	a2,0x5
ffffffffc0200636:	e7e60613          	addi	a2,a2,-386 # ffffffffc02054b0 <commands+0x498>
ffffffffc020063a:	06200593          	li	a1,98
ffffffffc020063e:	00005517          	auipc	a0,0x5
ffffffffc0200642:	e8a50513          	addi	a0,a0,-374 # ffffffffc02054c8 <commands+0x4b0>
ffffffffc0200646:	b8fff0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc020064a <idt_init>:
    write_csr(sscratch, 0);
ffffffffc020064a:	14005073          	csrwi	sscratch,0
    write_csr(stvec, &__alltraps);
ffffffffc020064e:	00000797          	auipc	a5,0x0
ffffffffc0200652:	48278793          	addi	a5,a5,1154 # ffffffffc0200ad0 <__alltraps>
ffffffffc0200656:	10579073          	csrw	stvec,a5
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc020065a:	000407b7          	lui	a5,0x40
ffffffffc020065e:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc0200662:	8082                	ret

ffffffffc0200664 <print_regs>:
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200664:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200666:	1141                	addi	sp,sp,-16
ffffffffc0200668:	e022                	sd	s0,0(sp)
ffffffffc020066a:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020066c:	00005517          	auipc	a0,0x5
ffffffffc0200670:	e7450513          	addi	a0,a0,-396 # ffffffffc02054e0 <commands+0x4c8>
void print_regs(struct pushregs *gpr) {
ffffffffc0200674:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200676:	a5bff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020067a:	640c                	ld	a1,8(s0)
ffffffffc020067c:	00005517          	auipc	a0,0x5
ffffffffc0200680:	e7c50513          	addi	a0,a0,-388 # ffffffffc02054f8 <commands+0x4e0>
ffffffffc0200684:	a4dff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc0200688:	680c                	ld	a1,16(s0)
ffffffffc020068a:	00005517          	auipc	a0,0x5
ffffffffc020068e:	e8650513          	addi	a0,a0,-378 # ffffffffc0205510 <commands+0x4f8>
ffffffffc0200692:	a3fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc0200696:	6c0c                	ld	a1,24(s0)
ffffffffc0200698:	00005517          	auipc	a0,0x5
ffffffffc020069c:	e9050513          	addi	a0,a0,-368 # ffffffffc0205528 <commands+0x510>
ffffffffc02006a0:	a31ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02006a4:	700c                	ld	a1,32(s0)
ffffffffc02006a6:	00005517          	auipc	a0,0x5
ffffffffc02006aa:	e9a50513          	addi	a0,a0,-358 # ffffffffc0205540 <commands+0x528>
ffffffffc02006ae:	a23ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02006b2:	740c                	ld	a1,40(s0)
ffffffffc02006b4:	00005517          	auipc	a0,0x5
ffffffffc02006b8:	ea450513          	addi	a0,a0,-348 # ffffffffc0205558 <commands+0x540>
ffffffffc02006bc:	a15ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02006c0:	780c                	ld	a1,48(s0)
ffffffffc02006c2:	00005517          	auipc	a0,0x5
ffffffffc02006c6:	eae50513          	addi	a0,a0,-338 # ffffffffc0205570 <commands+0x558>
ffffffffc02006ca:	a07ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02006ce:	7c0c                	ld	a1,56(s0)
ffffffffc02006d0:	00005517          	auipc	a0,0x5
ffffffffc02006d4:	eb850513          	addi	a0,a0,-328 # ffffffffc0205588 <commands+0x570>
ffffffffc02006d8:	9f9ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02006dc:	602c                	ld	a1,64(s0)
ffffffffc02006de:	00005517          	auipc	a0,0x5
ffffffffc02006e2:	ec250513          	addi	a0,a0,-318 # ffffffffc02055a0 <commands+0x588>
ffffffffc02006e6:	9ebff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02006ea:	642c                	ld	a1,72(s0)
ffffffffc02006ec:	00005517          	auipc	a0,0x5
ffffffffc02006f0:	ecc50513          	addi	a0,a0,-308 # ffffffffc02055b8 <commands+0x5a0>
ffffffffc02006f4:	9ddff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc02006f8:	682c                	ld	a1,80(s0)
ffffffffc02006fa:	00005517          	auipc	a0,0x5
ffffffffc02006fe:	ed650513          	addi	a0,a0,-298 # ffffffffc02055d0 <commands+0x5b8>
ffffffffc0200702:	9cfff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200706:	6c2c                	ld	a1,88(s0)
ffffffffc0200708:	00005517          	auipc	a0,0x5
ffffffffc020070c:	ee050513          	addi	a0,a0,-288 # ffffffffc02055e8 <commands+0x5d0>
ffffffffc0200710:	9c1ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200714:	702c                	ld	a1,96(s0)
ffffffffc0200716:	00005517          	auipc	a0,0x5
ffffffffc020071a:	eea50513          	addi	a0,a0,-278 # ffffffffc0205600 <commands+0x5e8>
ffffffffc020071e:	9b3ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200722:	742c                	ld	a1,104(s0)
ffffffffc0200724:	00005517          	auipc	a0,0x5
ffffffffc0200728:	ef450513          	addi	a0,a0,-268 # ffffffffc0205618 <commands+0x600>
ffffffffc020072c:	9a5ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200730:	782c                	ld	a1,112(s0)
ffffffffc0200732:	00005517          	auipc	a0,0x5
ffffffffc0200736:	efe50513          	addi	a0,a0,-258 # ffffffffc0205630 <commands+0x618>
ffffffffc020073a:	997ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc020073e:	7c2c                	ld	a1,120(s0)
ffffffffc0200740:	00005517          	auipc	a0,0x5
ffffffffc0200744:	f0850513          	addi	a0,a0,-248 # ffffffffc0205648 <commands+0x630>
ffffffffc0200748:	989ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020074c:	604c                	ld	a1,128(s0)
ffffffffc020074e:	00005517          	auipc	a0,0x5
ffffffffc0200752:	f1250513          	addi	a0,a0,-238 # ffffffffc0205660 <commands+0x648>
ffffffffc0200756:	97bff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020075a:	644c                	ld	a1,136(s0)
ffffffffc020075c:	00005517          	auipc	a0,0x5
ffffffffc0200760:	f1c50513          	addi	a0,a0,-228 # ffffffffc0205678 <commands+0x660>
ffffffffc0200764:	96dff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200768:	684c                	ld	a1,144(s0)
ffffffffc020076a:	00005517          	auipc	a0,0x5
ffffffffc020076e:	f2650513          	addi	a0,a0,-218 # ffffffffc0205690 <commands+0x678>
ffffffffc0200772:	95fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200776:	6c4c                	ld	a1,152(s0)
ffffffffc0200778:	00005517          	auipc	a0,0x5
ffffffffc020077c:	f3050513          	addi	a0,a0,-208 # ffffffffc02056a8 <commands+0x690>
ffffffffc0200780:	951ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200784:	704c                	ld	a1,160(s0)
ffffffffc0200786:	00005517          	auipc	a0,0x5
ffffffffc020078a:	f3a50513          	addi	a0,a0,-198 # ffffffffc02056c0 <commands+0x6a8>
ffffffffc020078e:	943ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc0200792:	744c                	ld	a1,168(s0)
ffffffffc0200794:	00005517          	auipc	a0,0x5
ffffffffc0200798:	f4450513          	addi	a0,a0,-188 # ffffffffc02056d8 <commands+0x6c0>
ffffffffc020079c:	935ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02007a0:	784c                	ld	a1,176(s0)
ffffffffc02007a2:	00005517          	auipc	a0,0x5
ffffffffc02007a6:	f4e50513          	addi	a0,a0,-178 # ffffffffc02056f0 <commands+0x6d8>
ffffffffc02007aa:	927ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02007ae:	7c4c                	ld	a1,184(s0)
ffffffffc02007b0:	00005517          	auipc	a0,0x5
ffffffffc02007b4:	f5850513          	addi	a0,a0,-168 # ffffffffc0205708 <commands+0x6f0>
ffffffffc02007b8:	919ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02007bc:	606c                	ld	a1,192(s0)
ffffffffc02007be:	00005517          	auipc	a0,0x5
ffffffffc02007c2:	f6250513          	addi	a0,a0,-158 # ffffffffc0205720 <commands+0x708>
ffffffffc02007c6:	90bff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02007ca:	646c                	ld	a1,200(s0)
ffffffffc02007cc:	00005517          	auipc	a0,0x5
ffffffffc02007d0:	f6c50513          	addi	a0,a0,-148 # ffffffffc0205738 <commands+0x720>
ffffffffc02007d4:	8fdff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02007d8:	686c                	ld	a1,208(s0)
ffffffffc02007da:	00005517          	auipc	a0,0x5
ffffffffc02007de:	f7650513          	addi	a0,a0,-138 # ffffffffc0205750 <commands+0x738>
ffffffffc02007e2:	8efff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02007e6:	6c6c                	ld	a1,216(s0)
ffffffffc02007e8:	00005517          	auipc	a0,0x5
ffffffffc02007ec:	f8050513          	addi	a0,a0,-128 # ffffffffc0205768 <commands+0x750>
ffffffffc02007f0:	8e1ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc02007f4:	706c                	ld	a1,224(s0)
ffffffffc02007f6:	00005517          	auipc	a0,0x5
ffffffffc02007fa:	f8a50513          	addi	a0,a0,-118 # ffffffffc0205780 <commands+0x768>
ffffffffc02007fe:	8d3ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200802:	746c                	ld	a1,232(s0)
ffffffffc0200804:	00005517          	auipc	a0,0x5
ffffffffc0200808:	f9450513          	addi	a0,a0,-108 # ffffffffc0205798 <commands+0x780>
ffffffffc020080c:	8c5ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200810:	786c                	ld	a1,240(s0)
ffffffffc0200812:	00005517          	auipc	a0,0x5
ffffffffc0200816:	f9e50513          	addi	a0,a0,-98 # ffffffffc02057b0 <commands+0x798>
ffffffffc020081a:	8b7ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020081e:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200820:	6402                	ld	s0,0(sp)
ffffffffc0200822:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200824:	00005517          	auipc	a0,0x5
ffffffffc0200828:	fa450513          	addi	a0,a0,-92 # ffffffffc02057c8 <commands+0x7b0>
}
ffffffffc020082c:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020082e:	8a3ff06f          	j	ffffffffc02000d0 <cprintf>

ffffffffc0200832 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc0200832:	1141                	addi	sp,sp,-16
ffffffffc0200834:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200836:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200838:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc020083a:	00005517          	auipc	a0,0x5
ffffffffc020083e:	fa650513          	addi	a0,a0,-90 # ffffffffc02057e0 <commands+0x7c8>
void print_trapframe(struct trapframe *tf) {
ffffffffc0200842:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200844:	88dff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200848:	8522                	mv	a0,s0
ffffffffc020084a:	e1bff0ef          	jal	ra,ffffffffc0200664 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020084e:	10043583          	ld	a1,256(s0)
ffffffffc0200852:	00005517          	auipc	a0,0x5
ffffffffc0200856:	fa650513          	addi	a0,a0,-90 # ffffffffc02057f8 <commands+0x7e0>
ffffffffc020085a:	877ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020085e:	10843583          	ld	a1,264(s0)
ffffffffc0200862:	00005517          	auipc	a0,0x5
ffffffffc0200866:	fae50513          	addi	a0,a0,-82 # ffffffffc0205810 <commands+0x7f8>
ffffffffc020086a:	867ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020086e:	11043583          	ld	a1,272(s0)
ffffffffc0200872:	00005517          	auipc	a0,0x5
ffffffffc0200876:	fb650513          	addi	a0,a0,-74 # ffffffffc0205828 <commands+0x810>
ffffffffc020087a:	857ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020087e:	11843583          	ld	a1,280(s0)
}
ffffffffc0200882:	6402                	ld	s0,0(sp)
ffffffffc0200884:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200886:	00005517          	auipc	a0,0x5
ffffffffc020088a:	fba50513          	addi	a0,a0,-70 # ffffffffc0205840 <commands+0x828>
}
ffffffffc020088e:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200890:	841ff06f          	j	ffffffffc02000d0 <cprintf>

ffffffffc0200894 <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc0200894:	11853783          	ld	a5,280(a0)
    switch (cause) {
ffffffffc0200898:	472d                	li	a4,11
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc020089a:	0786                	slli	a5,a5,0x1
ffffffffc020089c:	8385                	srli	a5,a5,0x1
    switch (cause) {
ffffffffc020089e:	06f76f63          	bltu	a4,a5,ffffffffc020091c <interrupt_handler+0x88>
ffffffffc02008a2:	00005717          	auipc	a4,0x5
ffffffffc02008a6:	91270713          	addi	a4,a4,-1774 # ffffffffc02051b4 <commands+0x19c>
ffffffffc02008aa:	078a                	slli	a5,a5,0x2
ffffffffc02008ac:	97ba                	add	a5,a5,a4
ffffffffc02008ae:	439c                	lw	a5,0(a5)
ffffffffc02008b0:	97ba                	add	a5,a5,a4
ffffffffc02008b2:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02008b4:	00005517          	auipc	a0,0x5
ffffffffc02008b8:	b8c50513          	addi	a0,a0,-1140 # ffffffffc0205440 <commands+0x428>
ffffffffc02008bc:	815ff06f          	j	ffffffffc02000d0 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02008c0:	00005517          	auipc	a0,0x5
ffffffffc02008c4:	b6050513          	addi	a0,a0,-1184 # ffffffffc0205420 <commands+0x408>
ffffffffc02008c8:	809ff06f          	j	ffffffffc02000d0 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02008cc:	00005517          	auipc	a0,0x5
ffffffffc02008d0:	b1450513          	addi	a0,a0,-1260 # ffffffffc02053e0 <commands+0x3c8>
ffffffffc02008d4:	ffcff06f          	j	ffffffffc02000d0 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02008d8:	00005517          	auipc	a0,0x5
ffffffffc02008dc:	b2850513          	addi	a0,a0,-1240 # ffffffffc0205400 <commands+0x3e8>
ffffffffc02008e0:	ff0ff06f          	j	ffffffffc02000d0 <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
ffffffffc02008e4:	00005517          	auipc	a0,0x5
ffffffffc02008e8:	b8c50513          	addi	a0,a0,-1140 # ffffffffc0205470 <commands+0x458>
ffffffffc02008ec:	fe4ff06f          	j	ffffffffc02000d0 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02008f0:	1141                	addi	sp,sp,-16
ffffffffc02008f2:	e406                	sd	ra,8(sp)
            clock_set_next_event();
ffffffffc02008f4:	c49ff0ef          	jal	ra,ffffffffc020053c <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc02008f8:	00015797          	auipc	a5,0x15
ffffffffc02008fc:	bd878793          	addi	a5,a5,-1064 # ffffffffc02154d0 <ticks>
ffffffffc0200900:	639c                	ld	a5,0(a5)
ffffffffc0200902:	06400713          	li	a4,100
ffffffffc0200906:	0785                	addi	a5,a5,1
ffffffffc0200908:	02e7f733          	remu	a4,a5,a4
ffffffffc020090c:	00015697          	auipc	a3,0x15
ffffffffc0200910:	bcf6b223          	sd	a5,-1084(a3) # ffffffffc02154d0 <ticks>
ffffffffc0200914:	c709                	beqz	a4,ffffffffc020091e <interrupt_handler+0x8a>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200916:	60a2                	ld	ra,8(sp)
ffffffffc0200918:	0141                	addi	sp,sp,16
ffffffffc020091a:	8082                	ret
            print_trapframe(tf);
ffffffffc020091c:	bf19                	j	ffffffffc0200832 <print_trapframe>
}
ffffffffc020091e:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200920:	06400593          	li	a1,100
ffffffffc0200924:	00005517          	auipc	a0,0x5
ffffffffc0200928:	b3c50513          	addi	a0,a0,-1220 # ffffffffc0205460 <commands+0x448>
}
ffffffffc020092c:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc020092e:	fa2ff06f          	j	ffffffffc02000d0 <cprintf>

ffffffffc0200932 <exception_handler>:

void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc0200932:	11853783          	ld	a5,280(a0)
ffffffffc0200936:	473d                	li	a4,15
ffffffffc0200938:	16f76463          	bltu	a4,a5,ffffffffc0200aa0 <exception_handler+0x16e>
ffffffffc020093c:	00005717          	auipc	a4,0x5
ffffffffc0200940:	8a870713          	addi	a4,a4,-1880 # ffffffffc02051e4 <commands+0x1cc>
ffffffffc0200944:	078a                	slli	a5,a5,0x2
ffffffffc0200946:	97ba                	add	a5,a5,a4
ffffffffc0200948:	439c                	lw	a5,0(a5)
void exception_handler(struct trapframe *tf) {
ffffffffc020094a:	1101                	addi	sp,sp,-32
ffffffffc020094c:	e822                	sd	s0,16(sp)
ffffffffc020094e:	ec06                	sd	ra,24(sp)
ffffffffc0200950:	e426                	sd	s1,8(sp)
    switch (tf->cause) {
ffffffffc0200952:	97ba                	add	a5,a5,a4
ffffffffc0200954:	842a                	mv	s0,a0
ffffffffc0200956:	8782                	jr	a5
                print_trapframe(tf);
                panic("handle pgfault failed. %e\n", ret);
            }
            break;
        case CAUSE_STORE_PAGE_FAULT:
            cprintf("Store/AMO page fault\n");
ffffffffc0200958:	00005517          	auipc	a0,0x5
ffffffffc020095c:	a7050513          	addi	a0,a0,-1424 # ffffffffc02053c8 <commands+0x3b0>
ffffffffc0200960:	f70ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200964:	8522                	mv	a0,s0
ffffffffc0200966:	c73ff0ef          	jal	ra,ffffffffc02005d8 <pgfault_handler>
ffffffffc020096a:	84aa                	mv	s1,a0
ffffffffc020096c:	12051b63          	bnez	a0,ffffffffc0200aa2 <exception_handler+0x170>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200970:	60e2                	ld	ra,24(sp)
ffffffffc0200972:	6442                	ld	s0,16(sp)
ffffffffc0200974:	64a2                	ld	s1,8(sp)
ffffffffc0200976:	6105                	addi	sp,sp,32
ffffffffc0200978:	8082                	ret
            cprintf("Instruction address misaligned\n");
ffffffffc020097a:	00005517          	auipc	a0,0x5
ffffffffc020097e:	8ae50513          	addi	a0,a0,-1874 # ffffffffc0205228 <commands+0x210>
}
ffffffffc0200982:	6442                	ld	s0,16(sp)
ffffffffc0200984:	60e2                	ld	ra,24(sp)
ffffffffc0200986:	64a2                	ld	s1,8(sp)
ffffffffc0200988:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc020098a:	f46ff06f          	j	ffffffffc02000d0 <cprintf>
ffffffffc020098e:	00005517          	auipc	a0,0x5
ffffffffc0200992:	8ba50513          	addi	a0,a0,-1862 # ffffffffc0205248 <commands+0x230>
ffffffffc0200996:	b7f5                	j	ffffffffc0200982 <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc0200998:	00005517          	auipc	a0,0x5
ffffffffc020099c:	8d050513          	addi	a0,a0,-1840 # ffffffffc0205268 <commands+0x250>
ffffffffc02009a0:	b7cd                	j	ffffffffc0200982 <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc02009a2:	00005517          	auipc	a0,0x5
ffffffffc02009a6:	8de50513          	addi	a0,a0,-1826 # ffffffffc0205280 <commands+0x268>
ffffffffc02009aa:	bfe1                	j	ffffffffc0200982 <exception_handler+0x50>
            cprintf("Load address misaligned\n");
ffffffffc02009ac:	00005517          	auipc	a0,0x5
ffffffffc02009b0:	8e450513          	addi	a0,a0,-1820 # ffffffffc0205290 <commands+0x278>
ffffffffc02009b4:	b7f9                	j	ffffffffc0200982 <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc02009b6:	00005517          	auipc	a0,0x5
ffffffffc02009ba:	8fa50513          	addi	a0,a0,-1798 # ffffffffc02052b0 <commands+0x298>
ffffffffc02009be:	f12ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02009c2:	8522                	mv	a0,s0
ffffffffc02009c4:	c15ff0ef          	jal	ra,ffffffffc02005d8 <pgfault_handler>
ffffffffc02009c8:	84aa                	mv	s1,a0
ffffffffc02009ca:	d15d                	beqz	a0,ffffffffc0200970 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc02009cc:	8522                	mv	a0,s0
ffffffffc02009ce:	e65ff0ef          	jal	ra,ffffffffc0200832 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02009d2:	86a6                	mv	a3,s1
ffffffffc02009d4:	00005617          	auipc	a2,0x5
ffffffffc02009d8:	8f460613          	addi	a2,a2,-1804 # ffffffffc02052c8 <commands+0x2b0>
ffffffffc02009dc:	0b300593          	li	a1,179
ffffffffc02009e0:	00005517          	auipc	a0,0x5
ffffffffc02009e4:	ae850513          	addi	a0,a0,-1304 # ffffffffc02054c8 <commands+0x4b0>
ffffffffc02009e8:	fecff0ef          	jal	ra,ffffffffc02001d4 <__panic>
            cprintf("AMO address misaligned\n");
ffffffffc02009ec:	00005517          	auipc	a0,0x5
ffffffffc02009f0:	8fc50513          	addi	a0,a0,-1796 # ffffffffc02052e8 <commands+0x2d0>
ffffffffc02009f4:	b779                	j	ffffffffc0200982 <exception_handler+0x50>
            cprintf("Store/AMO access fault\n");
ffffffffc02009f6:	00005517          	auipc	a0,0x5
ffffffffc02009fa:	90a50513          	addi	a0,a0,-1782 # ffffffffc0205300 <commands+0x2e8>
ffffffffc02009fe:	ed2ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200a02:	8522                	mv	a0,s0
ffffffffc0200a04:	bd5ff0ef          	jal	ra,ffffffffc02005d8 <pgfault_handler>
ffffffffc0200a08:	84aa                	mv	s1,a0
ffffffffc0200a0a:	d13d                	beqz	a0,ffffffffc0200970 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc0200a0c:	8522                	mv	a0,s0
ffffffffc0200a0e:	e25ff0ef          	jal	ra,ffffffffc0200832 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200a12:	86a6                	mv	a3,s1
ffffffffc0200a14:	00005617          	auipc	a2,0x5
ffffffffc0200a18:	8b460613          	addi	a2,a2,-1868 # ffffffffc02052c8 <commands+0x2b0>
ffffffffc0200a1c:	0bd00593          	li	a1,189
ffffffffc0200a20:	00005517          	auipc	a0,0x5
ffffffffc0200a24:	aa850513          	addi	a0,a0,-1368 # ffffffffc02054c8 <commands+0x4b0>
ffffffffc0200a28:	facff0ef          	jal	ra,ffffffffc02001d4 <__panic>
            cprintf("Environment call from U-mode\n");
ffffffffc0200a2c:	00005517          	auipc	a0,0x5
ffffffffc0200a30:	8ec50513          	addi	a0,a0,-1812 # ffffffffc0205318 <commands+0x300>
ffffffffc0200a34:	b7b9                	j	ffffffffc0200982 <exception_handler+0x50>
            cprintf("Environment call from S-mode\n");
ffffffffc0200a36:	00005517          	auipc	a0,0x5
ffffffffc0200a3a:	90250513          	addi	a0,a0,-1790 # ffffffffc0205338 <commands+0x320>
ffffffffc0200a3e:	b791                	j	ffffffffc0200982 <exception_handler+0x50>
            cprintf("Environment call from H-mode\n");
ffffffffc0200a40:	00005517          	auipc	a0,0x5
ffffffffc0200a44:	91850513          	addi	a0,a0,-1768 # ffffffffc0205358 <commands+0x340>
ffffffffc0200a48:	bf2d                	j	ffffffffc0200982 <exception_handler+0x50>
            cprintf("Environment call from M-mode\n");
ffffffffc0200a4a:	00005517          	auipc	a0,0x5
ffffffffc0200a4e:	92e50513          	addi	a0,a0,-1746 # ffffffffc0205378 <commands+0x360>
ffffffffc0200a52:	bf05                	j	ffffffffc0200982 <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200a54:	00005517          	auipc	a0,0x5
ffffffffc0200a58:	94450513          	addi	a0,a0,-1724 # ffffffffc0205398 <commands+0x380>
ffffffffc0200a5c:	b71d                	j	ffffffffc0200982 <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200a5e:	00005517          	auipc	a0,0x5
ffffffffc0200a62:	95250513          	addi	a0,a0,-1710 # ffffffffc02053b0 <commands+0x398>
ffffffffc0200a66:	e6aff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200a6a:	8522                	mv	a0,s0
ffffffffc0200a6c:	b6dff0ef          	jal	ra,ffffffffc02005d8 <pgfault_handler>
ffffffffc0200a70:	84aa                	mv	s1,a0
ffffffffc0200a72:	ee050fe3          	beqz	a0,ffffffffc0200970 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc0200a76:	8522                	mv	a0,s0
ffffffffc0200a78:	dbbff0ef          	jal	ra,ffffffffc0200832 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200a7c:	86a6                	mv	a3,s1
ffffffffc0200a7e:	00005617          	auipc	a2,0x5
ffffffffc0200a82:	84a60613          	addi	a2,a2,-1974 # ffffffffc02052c8 <commands+0x2b0>
ffffffffc0200a86:	0d300593          	li	a1,211
ffffffffc0200a8a:	00005517          	auipc	a0,0x5
ffffffffc0200a8e:	a3e50513          	addi	a0,a0,-1474 # ffffffffc02054c8 <commands+0x4b0>
ffffffffc0200a92:	f42ff0ef          	jal	ra,ffffffffc02001d4 <__panic>
}
ffffffffc0200a96:	6442                	ld	s0,16(sp)
ffffffffc0200a98:	60e2                	ld	ra,24(sp)
ffffffffc0200a9a:	64a2                	ld	s1,8(sp)
ffffffffc0200a9c:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc0200a9e:	bb51                	j	ffffffffc0200832 <print_trapframe>
ffffffffc0200aa0:	bb49                	j	ffffffffc0200832 <print_trapframe>
                print_trapframe(tf);
ffffffffc0200aa2:	8522                	mv	a0,s0
ffffffffc0200aa4:	d8fff0ef          	jal	ra,ffffffffc0200832 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200aa8:	86a6                	mv	a3,s1
ffffffffc0200aaa:	00005617          	auipc	a2,0x5
ffffffffc0200aae:	81e60613          	addi	a2,a2,-2018 # ffffffffc02052c8 <commands+0x2b0>
ffffffffc0200ab2:	0da00593          	li	a1,218
ffffffffc0200ab6:	00005517          	auipc	a0,0x5
ffffffffc0200aba:	a1250513          	addi	a0,a0,-1518 # ffffffffc02054c8 <commands+0x4b0>
ffffffffc0200abe:	f16ff0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc0200ac2 <trap>:
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200ac2:	11853783          	ld	a5,280(a0)
ffffffffc0200ac6:	0007c363          	bltz	a5,ffffffffc0200acc <trap+0xa>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
ffffffffc0200aca:	b5a5                	j	ffffffffc0200932 <exception_handler>
        interrupt_handler(tf);
ffffffffc0200acc:	b3e1                	j	ffffffffc0200894 <interrupt_handler>
	...

ffffffffc0200ad0 <__alltraps>:
    LOAD  x2,2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200ad0:	14011073          	csrw	sscratch,sp
ffffffffc0200ad4:	712d                	addi	sp,sp,-288
ffffffffc0200ad6:	e406                	sd	ra,8(sp)
ffffffffc0200ad8:	ec0e                	sd	gp,24(sp)
ffffffffc0200ada:	f012                	sd	tp,32(sp)
ffffffffc0200adc:	f416                	sd	t0,40(sp)
ffffffffc0200ade:	f81a                	sd	t1,48(sp)
ffffffffc0200ae0:	fc1e                	sd	t2,56(sp)
ffffffffc0200ae2:	e0a2                	sd	s0,64(sp)
ffffffffc0200ae4:	e4a6                	sd	s1,72(sp)
ffffffffc0200ae6:	e8aa                	sd	a0,80(sp)
ffffffffc0200ae8:	ecae                	sd	a1,88(sp)
ffffffffc0200aea:	f0b2                	sd	a2,96(sp)
ffffffffc0200aec:	f4b6                	sd	a3,104(sp)
ffffffffc0200aee:	f8ba                	sd	a4,112(sp)
ffffffffc0200af0:	fcbe                	sd	a5,120(sp)
ffffffffc0200af2:	e142                	sd	a6,128(sp)
ffffffffc0200af4:	e546                	sd	a7,136(sp)
ffffffffc0200af6:	e94a                	sd	s2,144(sp)
ffffffffc0200af8:	ed4e                	sd	s3,152(sp)
ffffffffc0200afa:	f152                	sd	s4,160(sp)
ffffffffc0200afc:	f556                	sd	s5,168(sp)
ffffffffc0200afe:	f95a                	sd	s6,176(sp)
ffffffffc0200b00:	fd5e                	sd	s7,184(sp)
ffffffffc0200b02:	e1e2                	sd	s8,192(sp)
ffffffffc0200b04:	e5e6                	sd	s9,200(sp)
ffffffffc0200b06:	e9ea                	sd	s10,208(sp)
ffffffffc0200b08:	edee                	sd	s11,216(sp)
ffffffffc0200b0a:	f1f2                	sd	t3,224(sp)
ffffffffc0200b0c:	f5f6                	sd	t4,232(sp)
ffffffffc0200b0e:	f9fa                	sd	t5,240(sp)
ffffffffc0200b10:	fdfe                	sd	t6,248(sp)
ffffffffc0200b12:	14002473          	csrr	s0,sscratch
ffffffffc0200b16:	100024f3          	csrr	s1,sstatus
ffffffffc0200b1a:	14102973          	csrr	s2,sepc
ffffffffc0200b1e:	143029f3          	csrr	s3,stval
ffffffffc0200b22:	14202a73          	csrr	s4,scause
ffffffffc0200b26:	e822                	sd	s0,16(sp)
ffffffffc0200b28:	e226                	sd	s1,256(sp)
ffffffffc0200b2a:	e64a                	sd	s2,264(sp)
ffffffffc0200b2c:	ea4e                	sd	s3,272(sp)
ffffffffc0200b2e:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200b30:	850a                	mv	a0,sp
    jal trap
ffffffffc0200b32:	f91ff0ef          	jal	ra,ffffffffc0200ac2 <trap>

ffffffffc0200b36 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200b36:	6492                	ld	s1,256(sp)
ffffffffc0200b38:	6932                	ld	s2,264(sp)
ffffffffc0200b3a:	10049073          	csrw	sstatus,s1
ffffffffc0200b3e:	14191073          	csrw	sepc,s2
ffffffffc0200b42:	60a2                	ld	ra,8(sp)
ffffffffc0200b44:	61e2                	ld	gp,24(sp)
ffffffffc0200b46:	7202                	ld	tp,32(sp)
ffffffffc0200b48:	72a2                	ld	t0,40(sp)
ffffffffc0200b4a:	7342                	ld	t1,48(sp)
ffffffffc0200b4c:	73e2                	ld	t2,56(sp)
ffffffffc0200b4e:	6406                	ld	s0,64(sp)
ffffffffc0200b50:	64a6                	ld	s1,72(sp)
ffffffffc0200b52:	6546                	ld	a0,80(sp)
ffffffffc0200b54:	65e6                	ld	a1,88(sp)
ffffffffc0200b56:	7606                	ld	a2,96(sp)
ffffffffc0200b58:	76a6                	ld	a3,104(sp)
ffffffffc0200b5a:	7746                	ld	a4,112(sp)
ffffffffc0200b5c:	77e6                	ld	a5,120(sp)
ffffffffc0200b5e:	680a                	ld	a6,128(sp)
ffffffffc0200b60:	68aa                	ld	a7,136(sp)
ffffffffc0200b62:	694a                	ld	s2,144(sp)
ffffffffc0200b64:	69ea                	ld	s3,152(sp)
ffffffffc0200b66:	7a0a                	ld	s4,160(sp)
ffffffffc0200b68:	7aaa                	ld	s5,168(sp)
ffffffffc0200b6a:	7b4a                	ld	s6,176(sp)
ffffffffc0200b6c:	7bea                	ld	s7,184(sp)
ffffffffc0200b6e:	6c0e                	ld	s8,192(sp)
ffffffffc0200b70:	6cae                	ld	s9,200(sp)
ffffffffc0200b72:	6d4e                	ld	s10,208(sp)
ffffffffc0200b74:	6dee                	ld	s11,216(sp)
ffffffffc0200b76:	7e0e                	ld	t3,224(sp)
ffffffffc0200b78:	7eae                	ld	t4,232(sp)
ffffffffc0200b7a:	7f4e                	ld	t5,240(sp)
ffffffffc0200b7c:	7fee                	ld	t6,248(sp)
ffffffffc0200b7e:	6142                	ld	sp,16(sp)
    # go back from supervisor call
    sret
ffffffffc0200b80:	10200073          	sret

ffffffffc0200b84 <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200b84:	812a                	mv	sp,a0
    j __trapret
ffffffffc0200b86:	bf45                	j	ffffffffc0200b36 <__trapret>
	...

ffffffffc0200b8a <pa2page.part.4>:
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
}

static inline struct Page *
pa2page(uintptr_t pa) {
ffffffffc0200b8a:	1141                	addi	sp,sp,-16
    if (PPN(pa) >= npage) {
        panic("pa2page called with invalid pa");
ffffffffc0200b8c:	00005617          	auipc	a2,0x5
ffffffffc0200b90:	d0460613          	addi	a2,a2,-764 # ffffffffc0205890 <commands+0x878>
ffffffffc0200b94:	06200593          	li	a1,98
ffffffffc0200b98:	00005517          	auipc	a0,0x5
ffffffffc0200b9c:	d1850513          	addi	a0,a0,-744 # ffffffffc02058b0 <commands+0x898>
pa2page(uintptr_t pa) {
ffffffffc0200ba0:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0200ba2:	e32ff0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc0200ba6 <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc0200ba6:	715d                	addi	sp,sp,-80
ffffffffc0200ba8:	e0a2                	sd	s0,64(sp)
ffffffffc0200baa:	fc26                	sd	s1,56(sp)
ffffffffc0200bac:	f84a                	sd	s2,48(sp)
ffffffffc0200bae:	f44e                	sd	s3,40(sp)
ffffffffc0200bb0:	f052                	sd	s4,32(sp)
ffffffffc0200bb2:	ec56                	sd	s5,24(sp)
ffffffffc0200bb4:	e486                	sd	ra,72(sp)
ffffffffc0200bb6:	842a                	mv	s0,a0
ffffffffc0200bb8:	00015497          	auipc	s1,0x15
ffffffffc0200bbc:	92048493          	addi	s1,s1,-1760 # ffffffffc02154d8 <pmm_manager>
        {
            page = pmm_manager->alloc_pages(n);
        }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0200bc0:	4985                	li	s3,1
ffffffffc0200bc2:	00015a17          	auipc	s4,0x15
ffffffffc0200bc6:	8dea0a13          	addi	s4,s4,-1826 # ffffffffc02154a0 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0200bca:	0005091b          	sext.w	s2,a0
ffffffffc0200bce:	00015a97          	auipc	s5,0x15
ffffffffc0200bd2:	92aa8a93          	addi	s5,s5,-1750 # ffffffffc02154f8 <check_mm_struct>
ffffffffc0200bd6:	a00d                	j	ffffffffc0200bf8 <alloc_pages+0x52>
            page = pmm_manager->alloc_pages(n);
ffffffffc0200bd8:	609c                	ld	a5,0(s1)
ffffffffc0200bda:	6f9c                	ld	a5,24(a5)
ffffffffc0200bdc:	9782                	jalr	a5
        swap_out(check_mm_struct, n, 0);
ffffffffc0200bde:	4601                	li	a2,0
ffffffffc0200be0:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0200be2:	ed0d                	bnez	a0,ffffffffc0200c1c <alloc_pages+0x76>
ffffffffc0200be4:	0289ec63          	bltu	s3,s0,ffffffffc0200c1c <alloc_pages+0x76>
ffffffffc0200be8:	000a2783          	lw	a5,0(s4)
ffffffffc0200bec:	2781                	sext.w	a5,a5
ffffffffc0200bee:	c79d                	beqz	a5,ffffffffc0200c1c <alloc_pages+0x76>
        swap_out(check_mm_struct, n, 0);
ffffffffc0200bf0:	000ab503          	ld	a0,0(s5)
ffffffffc0200bf4:	6f5010ef          	jal	ra,ffffffffc0202ae8 <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200bf8:	100027f3          	csrr	a5,sstatus
ffffffffc0200bfc:	8b89                	andi	a5,a5,2
            page = pmm_manager->alloc_pages(n);
ffffffffc0200bfe:	8522                	mv	a0,s0
ffffffffc0200c00:	dfe1                	beqz	a5,ffffffffc0200bd8 <alloc_pages+0x32>
        intr_disable();
ffffffffc0200c02:	9d1ff0ef          	jal	ra,ffffffffc02005d2 <intr_disable>
ffffffffc0200c06:	609c                	ld	a5,0(s1)
ffffffffc0200c08:	8522                	mv	a0,s0
ffffffffc0200c0a:	6f9c                	ld	a5,24(a5)
ffffffffc0200c0c:	9782                	jalr	a5
ffffffffc0200c0e:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0200c10:	9bdff0ef          	jal	ra,ffffffffc02005cc <intr_enable>
ffffffffc0200c14:	6522                	ld	a0,8(sp)
        swap_out(check_mm_struct, n, 0);
ffffffffc0200c16:	4601                	li	a2,0
ffffffffc0200c18:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0200c1a:	d569                	beqz	a0,ffffffffc0200be4 <alloc_pages+0x3e>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0200c1c:	60a6                	ld	ra,72(sp)
ffffffffc0200c1e:	6406                	ld	s0,64(sp)
ffffffffc0200c20:	74e2                	ld	s1,56(sp)
ffffffffc0200c22:	7942                	ld	s2,48(sp)
ffffffffc0200c24:	79a2                	ld	s3,40(sp)
ffffffffc0200c26:	7a02                	ld	s4,32(sp)
ffffffffc0200c28:	6ae2                	ld	s5,24(sp)
ffffffffc0200c2a:	6161                	addi	sp,sp,80
ffffffffc0200c2c:	8082                	ret

ffffffffc0200c2e <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200c2e:	100027f3          	csrr	a5,sstatus
ffffffffc0200c32:	8b89                	andi	a5,a5,2
ffffffffc0200c34:	eb89                	bnez	a5,ffffffffc0200c46 <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0200c36:	00015797          	auipc	a5,0x15
ffffffffc0200c3a:	8a278793          	addi	a5,a5,-1886 # ffffffffc02154d8 <pmm_manager>
ffffffffc0200c3e:	639c                	ld	a5,0(a5)
ffffffffc0200c40:	0207b303          	ld	t1,32(a5)
ffffffffc0200c44:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc0200c46:	1101                	addi	sp,sp,-32
ffffffffc0200c48:	ec06                	sd	ra,24(sp)
ffffffffc0200c4a:	e822                	sd	s0,16(sp)
ffffffffc0200c4c:	e426                	sd	s1,8(sp)
ffffffffc0200c4e:	842a                	mv	s0,a0
ffffffffc0200c50:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0200c52:	981ff0ef          	jal	ra,ffffffffc02005d2 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0200c56:	00015797          	auipc	a5,0x15
ffffffffc0200c5a:	88278793          	addi	a5,a5,-1918 # ffffffffc02154d8 <pmm_manager>
ffffffffc0200c5e:	639c                	ld	a5,0(a5)
ffffffffc0200c60:	85a6                	mv	a1,s1
ffffffffc0200c62:	8522                	mv	a0,s0
ffffffffc0200c64:	739c                	ld	a5,32(a5)
ffffffffc0200c66:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200c68:	6442                	ld	s0,16(sp)
ffffffffc0200c6a:	60e2                	ld	ra,24(sp)
ffffffffc0200c6c:	64a2                	ld	s1,8(sp)
ffffffffc0200c6e:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200c70:	95dff06f          	j	ffffffffc02005cc <intr_enable>

ffffffffc0200c74 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200c74:	100027f3          	csrr	a5,sstatus
ffffffffc0200c78:	8b89                	andi	a5,a5,2
ffffffffc0200c7a:	eb89                	bnez	a5,ffffffffc0200c8c <nr_free_pages+0x18>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0200c7c:	00015797          	auipc	a5,0x15
ffffffffc0200c80:	85c78793          	addi	a5,a5,-1956 # ffffffffc02154d8 <pmm_manager>
ffffffffc0200c84:	639c                	ld	a5,0(a5)
ffffffffc0200c86:	0287b303          	ld	t1,40(a5)
ffffffffc0200c8a:	8302                	jr	t1
size_t nr_free_pages(void) {
ffffffffc0200c8c:	1141                	addi	sp,sp,-16
ffffffffc0200c8e:	e406                	sd	ra,8(sp)
ffffffffc0200c90:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0200c92:	941ff0ef          	jal	ra,ffffffffc02005d2 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0200c96:	00015797          	auipc	a5,0x15
ffffffffc0200c9a:	84278793          	addi	a5,a5,-1982 # ffffffffc02154d8 <pmm_manager>
ffffffffc0200c9e:	639c                	ld	a5,0(a5)
ffffffffc0200ca0:	779c                	ld	a5,40(a5)
ffffffffc0200ca2:	9782                	jalr	a5
ffffffffc0200ca4:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0200ca6:	927ff0ef          	jal	ra,ffffffffc02005cc <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0200caa:	8522                	mv	a0,s0
ffffffffc0200cac:	60a2                	ld	ra,8(sp)
ffffffffc0200cae:	6402                	ld	s0,0(sp)
ffffffffc0200cb0:	0141                	addi	sp,sp,16
ffffffffc0200cb2:	8082                	ret

ffffffffc0200cb4 <get_pte>:
// parameter:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0200cb4:	7139                	addi	sp,sp,-64
ffffffffc0200cb6:	f426                	sd	s1,40(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0200cb8:	01e5d493          	srli	s1,a1,0x1e
ffffffffc0200cbc:	1ff4f493          	andi	s1,s1,511
ffffffffc0200cc0:	048e                	slli	s1,s1,0x3
ffffffffc0200cc2:	94aa                	add	s1,s1,a0
    if (!(*pdep1 & PTE_V)) {
ffffffffc0200cc4:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0200cc6:	f04a                	sd	s2,32(sp)
ffffffffc0200cc8:	ec4e                	sd	s3,24(sp)
ffffffffc0200cca:	e852                	sd	s4,16(sp)
ffffffffc0200ccc:	fc06                	sd	ra,56(sp)
ffffffffc0200cce:	f822                	sd	s0,48(sp)
ffffffffc0200cd0:	e456                	sd	s5,8(sp)
ffffffffc0200cd2:	e05a                	sd	s6,0(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc0200cd4:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0200cd8:	892e                	mv	s2,a1
ffffffffc0200cda:	8a32                	mv	s4,a2
ffffffffc0200cdc:	00014997          	auipc	s3,0x14
ffffffffc0200ce0:	7ac98993          	addi	s3,s3,1964 # ffffffffc0215488 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0200ce4:	e7bd                	bnez	a5,ffffffffc0200d52 <get_pte+0x9e>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0200ce6:	12060c63          	beqz	a2,ffffffffc0200e1e <get_pte+0x16a>
ffffffffc0200cea:	4505                	li	a0,1
ffffffffc0200cec:	ebbff0ef          	jal	ra,ffffffffc0200ba6 <alloc_pages>
ffffffffc0200cf0:	842a                	mv	s0,a0
ffffffffc0200cf2:	12050663          	beqz	a0,ffffffffc0200e1e <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0200cf6:	00014b17          	auipc	s6,0x14
ffffffffc0200cfa:	7fab0b13          	addi	s6,s6,2042 # ffffffffc02154f0 <pages>
ffffffffc0200cfe:	000b3503          	ld	a0,0(s6)
ffffffffc0200d02:	00080ab7          	lui	s5,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0200d06:	00014997          	auipc	s3,0x14
ffffffffc0200d0a:	78298993          	addi	s3,s3,1922 # ffffffffc0215488 <npage>
ffffffffc0200d0e:	40a40533          	sub	a0,s0,a0
ffffffffc0200d12:	8519                	srai	a0,a0,0x6
ffffffffc0200d14:	9556                	add	a0,a0,s5
ffffffffc0200d16:	0009b703          	ld	a4,0(s3)
ffffffffc0200d1a:	00c51793          	slli	a5,a0,0xc
    return page->ref;
}

static inline void
set_page_ref(struct Page *page, int val) {
    page->ref = val;
ffffffffc0200d1e:	4685                	li	a3,1
ffffffffc0200d20:	c014                	sw	a3,0(s0)
ffffffffc0200d22:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0200d24:	0532                	slli	a0,a0,0xc
ffffffffc0200d26:	14e7f363          	bgeu	a5,a4,ffffffffc0200e6c <get_pte+0x1b8>
ffffffffc0200d2a:	00014797          	auipc	a5,0x14
ffffffffc0200d2e:	7b678793          	addi	a5,a5,1974 # ffffffffc02154e0 <va_pa_offset>
ffffffffc0200d32:	639c                	ld	a5,0(a5)
ffffffffc0200d34:	6605                	lui	a2,0x1
ffffffffc0200d36:	4581                	li	a1,0
ffffffffc0200d38:	953e                	add	a0,a0,a5
ffffffffc0200d3a:	531030ef          	jal	ra,ffffffffc0204a6a <memset>
    return page - pages + nbase;
ffffffffc0200d3e:	000b3683          	ld	a3,0(s6)
ffffffffc0200d42:	40d406b3          	sub	a3,s0,a3
ffffffffc0200d46:	8699                	srai	a3,a3,0x6
ffffffffc0200d48:	96d6                	add	a3,a3,s5
  asm volatile("sfence.vma");
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0200d4a:	06aa                	slli	a3,a3,0xa
ffffffffc0200d4c:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0200d50:	e094                	sd	a3,0(s1)
    }
    pde_t *pdep0 = &((pte_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0200d52:	77fd                	lui	a5,0xfffff
ffffffffc0200d54:	068a                	slli	a3,a3,0x2
ffffffffc0200d56:	0009b703          	ld	a4,0(s3)
ffffffffc0200d5a:	8efd                	and	a3,a3,a5
ffffffffc0200d5c:	00c6d793          	srli	a5,a3,0xc
ffffffffc0200d60:	0ce7f163          	bgeu	a5,a4,ffffffffc0200e22 <get_pte+0x16e>
ffffffffc0200d64:	00014a97          	auipc	s5,0x14
ffffffffc0200d68:	77ca8a93          	addi	s5,s5,1916 # ffffffffc02154e0 <va_pa_offset>
ffffffffc0200d6c:	000ab403          	ld	s0,0(s5)
ffffffffc0200d70:	01595793          	srli	a5,s2,0x15
ffffffffc0200d74:	1ff7f793          	andi	a5,a5,511
ffffffffc0200d78:	96a2                	add	a3,a3,s0
ffffffffc0200d7a:	00379413          	slli	s0,a5,0x3
ffffffffc0200d7e:	9436                	add	s0,s0,a3
    if (!(*pdep0 & PTE_V)) {
ffffffffc0200d80:	6014                	ld	a3,0(s0)
ffffffffc0200d82:	0016f793          	andi	a5,a3,1
ffffffffc0200d86:	e3ad                	bnez	a5,ffffffffc0200de8 <get_pte+0x134>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0200d88:	080a0b63          	beqz	s4,ffffffffc0200e1e <get_pte+0x16a>
ffffffffc0200d8c:	4505                	li	a0,1
ffffffffc0200d8e:	e19ff0ef          	jal	ra,ffffffffc0200ba6 <alloc_pages>
ffffffffc0200d92:	84aa                	mv	s1,a0
ffffffffc0200d94:	c549                	beqz	a0,ffffffffc0200e1e <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0200d96:	00014b17          	auipc	s6,0x14
ffffffffc0200d9a:	75ab0b13          	addi	s6,s6,1882 # ffffffffc02154f0 <pages>
ffffffffc0200d9e:	000b3503          	ld	a0,0(s6)
ffffffffc0200da2:	00080a37          	lui	s4,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0200da6:	0009b703          	ld	a4,0(s3)
ffffffffc0200daa:	40a48533          	sub	a0,s1,a0
ffffffffc0200dae:	8519                	srai	a0,a0,0x6
ffffffffc0200db0:	9552                	add	a0,a0,s4
ffffffffc0200db2:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc0200db6:	4685                	li	a3,1
ffffffffc0200db8:	c094                	sw	a3,0(s1)
ffffffffc0200dba:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0200dbc:	0532                	slli	a0,a0,0xc
ffffffffc0200dbe:	08e7fa63          	bgeu	a5,a4,ffffffffc0200e52 <get_pte+0x19e>
ffffffffc0200dc2:	000ab783          	ld	a5,0(s5)
ffffffffc0200dc6:	6605                	lui	a2,0x1
ffffffffc0200dc8:	4581                	li	a1,0
ffffffffc0200dca:	953e                	add	a0,a0,a5
ffffffffc0200dcc:	49f030ef          	jal	ra,ffffffffc0204a6a <memset>
    return page - pages + nbase;
ffffffffc0200dd0:	000b3683          	ld	a3,0(s6)
ffffffffc0200dd4:	40d486b3          	sub	a3,s1,a3
ffffffffc0200dd8:	8699                	srai	a3,a3,0x6
ffffffffc0200dda:	96d2                	add	a3,a3,s4
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0200ddc:	06aa                	slli	a3,a3,0xa
ffffffffc0200dde:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0200de2:	e014                	sd	a3,0(s0)
ffffffffc0200de4:	0009b703          	ld	a4,0(s3)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0200de8:	068a                	slli	a3,a3,0x2
ffffffffc0200dea:	757d                	lui	a0,0xfffff
ffffffffc0200dec:	8ee9                	and	a3,a3,a0
ffffffffc0200dee:	00c6d793          	srli	a5,a3,0xc
ffffffffc0200df2:	04e7f463          	bgeu	a5,a4,ffffffffc0200e3a <get_pte+0x186>
ffffffffc0200df6:	000ab503          	ld	a0,0(s5)
ffffffffc0200dfa:	00c95913          	srli	s2,s2,0xc
ffffffffc0200dfe:	1ff97913          	andi	s2,s2,511
ffffffffc0200e02:	96aa                	add	a3,a3,a0
ffffffffc0200e04:	00391513          	slli	a0,s2,0x3
ffffffffc0200e08:	9536                	add	a0,a0,a3
}
ffffffffc0200e0a:	70e2                	ld	ra,56(sp)
ffffffffc0200e0c:	7442                	ld	s0,48(sp)
ffffffffc0200e0e:	74a2                	ld	s1,40(sp)
ffffffffc0200e10:	7902                	ld	s2,32(sp)
ffffffffc0200e12:	69e2                	ld	s3,24(sp)
ffffffffc0200e14:	6a42                	ld	s4,16(sp)
ffffffffc0200e16:	6aa2                	ld	s5,8(sp)
ffffffffc0200e18:	6b02                	ld	s6,0(sp)
ffffffffc0200e1a:	6121                	addi	sp,sp,64
ffffffffc0200e1c:	8082                	ret
            return NULL;
ffffffffc0200e1e:	4501                	li	a0,0
ffffffffc0200e20:	b7ed                	j	ffffffffc0200e0a <get_pte+0x156>
    pde_t *pdep0 = &((pte_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0200e22:	00005617          	auipc	a2,0x5
ffffffffc0200e26:	a3660613          	addi	a2,a2,-1482 # ffffffffc0205858 <commands+0x840>
ffffffffc0200e2a:	0e400593          	li	a1,228
ffffffffc0200e2e:	00005517          	auipc	a0,0x5
ffffffffc0200e32:	a5250513          	addi	a0,a0,-1454 # ffffffffc0205880 <commands+0x868>
ffffffffc0200e36:	b9eff0ef          	jal	ra,ffffffffc02001d4 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0200e3a:	00005617          	auipc	a2,0x5
ffffffffc0200e3e:	a1e60613          	addi	a2,a2,-1506 # ffffffffc0205858 <commands+0x840>
ffffffffc0200e42:	0ef00593          	li	a1,239
ffffffffc0200e46:	00005517          	auipc	a0,0x5
ffffffffc0200e4a:	a3a50513          	addi	a0,a0,-1478 # ffffffffc0205880 <commands+0x868>
ffffffffc0200e4e:	b86ff0ef          	jal	ra,ffffffffc02001d4 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0200e52:	86aa                	mv	a3,a0
ffffffffc0200e54:	00005617          	auipc	a2,0x5
ffffffffc0200e58:	a0460613          	addi	a2,a2,-1532 # ffffffffc0205858 <commands+0x840>
ffffffffc0200e5c:	0ec00593          	li	a1,236
ffffffffc0200e60:	00005517          	auipc	a0,0x5
ffffffffc0200e64:	a2050513          	addi	a0,a0,-1504 # ffffffffc0205880 <commands+0x868>
ffffffffc0200e68:	b6cff0ef          	jal	ra,ffffffffc02001d4 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0200e6c:	86aa                	mv	a3,a0
ffffffffc0200e6e:	00005617          	auipc	a2,0x5
ffffffffc0200e72:	9ea60613          	addi	a2,a2,-1558 # ffffffffc0205858 <commands+0x840>
ffffffffc0200e76:	0e100593          	li	a1,225
ffffffffc0200e7a:	00005517          	auipc	a0,0x5
ffffffffc0200e7e:	a0650513          	addi	a0,a0,-1530 # ffffffffc0205880 <commands+0x868>
ffffffffc0200e82:	b52ff0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc0200e86 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0200e86:	1141                	addi	sp,sp,-16
ffffffffc0200e88:	e022                	sd	s0,0(sp)
ffffffffc0200e8a:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0200e8c:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0200e8e:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0200e90:	e25ff0ef          	jal	ra,ffffffffc0200cb4 <get_pte>
    if (ptep_store != NULL) {
ffffffffc0200e94:	c011                	beqz	s0,ffffffffc0200e98 <get_page+0x12>
        *ptep_store = ptep;
ffffffffc0200e96:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0200e98:	c511                	beqz	a0,ffffffffc0200ea4 <get_page+0x1e>
ffffffffc0200e9a:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0200e9c:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0200e9e:	0017f713          	andi	a4,a5,1
ffffffffc0200ea2:	e709                	bnez	a4,ffffffffc0200eac <get_page+0x26>
}
ffffffffc0200ea4:	60a2                	ld	ra,8(sp)
ffffffffc0200ea6:	6402                	ld	s0,0(sp)
ffffffffc0200ea8:	0141                	addi	sp,sp,16
ffffffffc0200eaa:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0200eac:	00014717          	auipc	a4,0x14
ffffffffc0200eb0:	5dc70713          	addi	a4,a4,1500 # ffffffffc0215488 <npage>
ffffffffc0200eb4:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0200eb6:	078a                	slli	a5,a5,0x2
ffffffffc0200eb8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0200eba:	02e7f063          	bgeu	a5,a4,ffffffffc0200eda <get_page+0x54>
    return &pages[PPN(pa) - nbase];
ffffffffc0200ebe:	00014717          	auipc	a4,0x14
ffffffffc0200ec2:	63270713          	addi	a4,a4,1586 # ffffffffc02154f0 <pages>
ffffffffc0200ec6:	6308                	ld	a0,0(a4)
ffffffffc0200ec8:	60a2                	ld	ra,8(sp)
ffffffffc0200eca:	6402                	ld	s0,0(sp)
ffffffffc0200ecc:	fff80737          	lui	a4,0xfff80
ffffffffc0200ed0:	97ba                	add	a5,a5,a4
ffffffffc0200ed2:	079a                	slli	a5,a5,0x6
ffffffffc0200ed4:	953e                	add	a0,a0,a5
ffffffffc0200ed6:	0141                	addi	sp,sp,16
ffffffffc0200ed8:	8082                	ret
ffffffffc0200eda:	cb1ff0ef          	jal	ra,ffffffffc0200b8a <pa2page.part.4>

ffffffffc0200ede <page_remove>:
    }
}

// page_remove - free an Page which is related linear address la and has an
// validated pte
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0200ede:	1101                	addi	sp,sp,-32
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0200ee0:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0200ee2:	e426                	sd	s1,8(sp)
ffffffffc0200ee4:	ec06                	sd	ra,24(sp)
ffffffffc0200ee6:	e822                	sd	s0,16(sp)
ffffffffc0200ee8:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0200eea:	dcbff0ef          	jal	ra,ffffffffc0200cb4 <get_pte>
    if (ptep != NULL) {
ffffffffc0200eee:	c511                	beqz	a0,ffffffffc0200efa <page_remove+0x1c>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0200ef0:	611c                	ld	a5,0(a0)
ffffffffc0200ef2:	842a                	mv	s0,a0
ffffffffc0200ef4:	0017f713          	andi	a4,a5,1
ffffffffc0200ef8:	e711                	bnez	a4,ffffffffc0200f04 <page_remove+0x26>
        page_remove_pte(pgdir, la, ptep);
    }
}
ffffffffc0200efa:	60e2                	ld	ra,24(sp)
ffffffffc0200efc:	6442                	ld	s0,16(sp)
ffffffffc0200efe:	64a2                	ld	s1,8(sp)
ffffffffc0200f00:	6105                	addi	sp,sp,32
ffffffffc0200f02:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0200f04:	00014717          	auipc	a4,0x14
ffffffffc0200f08:	58470713          	addi	a4,a4,1412 # ffffffffc0215488 <npage>
ffffffffc0200f0c:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0200f0e:	078a                	slli	a5,a5,0x2
ffffffffc0200f10:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0200f12:	02e7fe63          	bgeu	a5,a4,ffffffffc0200f4e <page_remove+0x70>
    return &pages[PPN(pa) - nbase];
ffffffffc0200f16:	00014717          	auipc	a4,0x14
ffffffffc0200f1a:	5da70713          	addi	a4,a4,1498 # ffffffffc02154f0 <pages>
ffffffffc0200f1e:	6308                	ld	a0,0(a4)
ffffffffc0200f20:	fff80737          	lui	a4,0xfff80
ffffffffc0200f24:	97ba                	add	a5,a5,a4
ffffffffc0200f26:	079a                	slli	a5,a5,0x6
ffffffffc0200f28:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0200f2a:	411c                	lw	a5,0(a0)
ffffffffc0200f2c:	fff7871b          	addiw	a4,a5,-1
ffffffffc0200f30:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0200f32:	cb11                	beqz	a4,ffffffffc0200f46 <page_remove+0x68>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0200f34:	00043023          	sd	zero,0(s0)
// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la) {
    // flush_tlb();
    // The flush_tlb flush the entire TLB, is there any better way?
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0200f38:	12048073          	sfence.vma	s1
}
ffffffffc0200f3c:	60e2                	ld	ra,24(sp)
ffffffffc0200f3e:	6442                	ld	s0,16(sp)
ffffffffc0200f40:	64a2                	ld	s1,8(sp)
ffffffffc0200f42:	6105                	addi	sp,sp,32
ffffffffc0200f44:	8082                	ret
            free_page(page);
ffffffffc0200f46:	4585                	li	a1,1
ffffffffc0200f48:	ce7ff0ef          	jal	ra,ffffffffc0200c2e <free_pages>
ffffffffc0200f4c:	b7e5                	j	ffffffffc0200f34 <page_remove+0x56>
ffffffffc0200f4e:	c3dff0ef          	jal	ra,ffffffffc0200b8a <pa2page.part.4>

ffffffffc0200f52 <page_insert>:
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0200f52:	7179                	addi	sp,sp,-48
ffffffffc0200f54:	e44e                	sd	s3,8(sp)
ffffffffc0200f56:	89b2                	mv	s3,a2
ffffffffc0200f58:	f022                	sd	s0,32(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0200f5a:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0200f5c:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0200f5e:	85ce                	mv	a1,s3
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0200f60:	ec26                	sd	s1,24(sp)
ffffffffc0200f62:	f406                	sd	ra,40(sp)
ffffffffc0200f64:	e84a                	sd	s2,16(sp)
ffffffffc0200f66:	e052                	sd	s4,0(sp)
ffffffffc0200f68:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0200f6a:	d4bff0ef          	jal	ra,ffffffffc0200cb4 <get_pte>
    if (ptep == NULL) {
ffffffffc0200f6e:	cd49                	beqz	a0,ffffffffc0201008 <page_insert+0xb6>
    page->ref += 1;
ffffffffc0200f70:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V) {
ffffffffc0200f72:	611c                	ld	a5,0(a0)
ffffffffc0200f74:	892a                	mv	s2,a0
ffffffffc0200f76:	0016871b          	addiw	a4,a3,1
ffffffffc0200f7a:	c018                	sw	a4,0(s0)
ffffffffc0200f7c:	0017f713          	andi	a4,a5,1
ffffffffc0200f80:	ef05                	bnez	a4,ffffffffc0200fb8 <page_insert+0x66>
ffffffffc0200f82:	00014797          	auipc	a5,0x14
ffffffffc0200f86:	56e78793          	addi	a5,a5,1390 # ffffffffc02154f0 <pages>
ffffffffc0200f8a:	6398                	ld	a4,0(a5)
    return page - pages + nbase;
ffffffffc0200f8c:	8c19                	sub	s0,s0,a4
ffffffffc0200f8e:	000806b7          	lui	a3,0x80
ffffffffc0200f92:	8419                	srai	s0,s0,0x6
ffffffffc0200f94:	9436                	add	s0,s0,a3
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0200f96:	042a                	slli	s0,s0,0xa
ffffffffc0200f98:	8c45                	or	s0,s0,s1
ffffffffc0200f9a:	00146413          	ori	s0,s0,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0200f9e:	00893023          	sd	s0,0(s2)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0200fa2:	12098073          	sfence.vma	s3
    return 0;
ffffffffc0200fa6:	4501                	li	a0,0
}
ffffffffc0200fa8:	70a2                	ld	ra,40(sp)
ffffffffc0200faa:	7402                	ld	s0,32(sp)
ffffffffc0200fac:	64e2                	ld	s1,24(sp)
ffffffffc0200fae:	6942                	ld	s2,16(sp)
ffffffffc0200fb0:	69a2                	ld	s3,8(sp)
ffffffffc0200fb2:	6a02                	ld	s4,0(sp)
ffffffffc0200fb4:	6145                	addi	sp,sp,48
ffffffffc0200fb6:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0200fb8:	00014717          	auipc	a4,0x14
ffffffffc0200fbc:	4d070713          	addi	a4,a4,1232 # ffffffffc0215488 <npage>
ffffffffc0200fc0:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0200fc2:	078a                	slli	a5,a5,0x2
ffffffffc0200fc4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0200fc6:	04e7f363          	bgeu	a5,a4,ffffffffc020100c <page_insert+0xba>
    return &pages[PPN(pa) - nbase];
ffffffffc0200fca:	00014a17          	auipc	s4,0x14
ffffffffc0200fce:	526a0a13          	addi	s4,s4,1318 # ffffffffc02154f0 <pages>
ffffffffc0200fd2:	000a3703          	ld	a4,0(s4)
ffffffffc0200fd6:	fff80537          	lui	a0,0xfff80
ffffffffc0200fda:	953e                	add	a0,a0,a5
ffffffffc0200fdc:	051a                	slli	a0,a0,0x6
ffffffffc0200fde:	953a                	add	a0,a0,a4
        if (p == page) {
ffffffffc0200fe0:	00a40a63          	beq	s0,a0,ffffffffc0200ff4 <page_insert+0xa2>
    page->ref -= 1;
ffffffffc0200fe4:	411c                	lw	a5,0(a0)
ffffffffc0200fe6:	fff7869b          	addiw	a3,a5,-1
ffffffffc0200fea:	c114                	sw	a3,0(a0)
        if (page_ref(page) ==
ffffffffc0200fec:	c691                	beqz	a3,ffffffffc0200ff8 <page_insert+0xa6>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0200fee:	12098073          	sfence.vma	s3
ffffffffc0200ff2:	bf69                	j	ffffffffc0200f8c <page_insert+0x3a>
ffffffffc0200ff4:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0200ff6:	bf59                	j	ffffffffc0200f8c <page_insert+0x3a>
            free_page(page);
ffffffffc0200ff8:	4585                	li	a1,1
ffffffffc0200ffa:	c35ff0ef          	jal	ra,ffffffffc0200c2e <free_pages>
ffffffffc0200ffe:	000a3703          	ld	a4,0(s4)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201002:	12098073          	sfence.vma	s3
ffffffffc0201006:	b759                	j	ffffffffc0200f8c <page_insert+0x3a>
        return -E_NO_MEM;
ffffffffc0201008:	5571                	li	a0,-4
ffffffffc020100a:	bf79                	j	ffffffffc0200fa8 <page_insert+0x56>
ffffffffc020100c:	b7fff0ef          	jal	ra,ffffffffc0200b8a <pa2page.part.4>

ffffffffc0201010 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0201010:	00006797          	auipc	a5,0x6
ffffffffc0201014:	b1878793          	addi	a5,a5,-1256 # ffffffffc0206b28 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201018:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc020101a:	715d                	addi	sp,sp,-80
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020101c:	00005517          	auipc	a0,0x5
ffffffffc0201020:	8bc50513          	addi	a0,a0,-1860 # ffffffffc02058d8 <commands+0x8c0>
void pmm_init(void) {
ffffffffc0201024:	e486                	sd	ra,72(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0201026:	00014717          	auipc	a4,0x14
ffffffffc020102a:	4af73923          	sd	a5,1202(a4) # ffffffffc02154d8 <pmm_manager>
void pmm_init(void) {
ffffffffc020102e:	e0a2                	sd	s0,64(sp)
ffffffffc0201030:	fc26                	sd	s1,56(sp)
ffffffffc0201032:	f84a                	sd	s2,48(sp)
ffffffffc0201034:	f44e                	sd	s3,40(sp)
ffffffffc0201036:	f052                	sd	s4,32(sp)
ffffffffc0201038:	ec56                	sd	s5,24(sp)
ffffffffc020103a:	e85a                	sd	s6,16(sp)
ffffffffc020103c:	e45e                	sd	s7,8(sp)
ffffffffc020103e:	e062                	sd	s8,0(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0201040:	00014417          	auipc	s0,0x14
ffffffffc0201044:	49840413          	addi	s0,s0,1176 # ffffffffc02154d8 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201048:	888ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    pmm_manager->init();
ffffffffc020104c:	601c                	ld	a5,0(s0)
ffffffffc020104e:	00014497          	auipc	s1,0x14
ffffffffc0201052:	43a48493          	addi	s1,s1,1082 # ffffffffc0215488 <npage>
ffffffffc0201056:	00014917          	auipc	s2,0x14
ffffffffc020105a:	49a90913          	addi	s2,s2,1178 # ffffffffc02154f0 <pages>
ffffffffc020105e:	679c                	ld	a5,8(a5)
ffffffffc0201060:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201062:	57f5                	li	a5,-3
ffffffffc0201064:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0201066:	00005517          	auipc	a0,0x5
ffffffffc020106a:	88a50513          	addi	a0,a0,-1910 # ffffffffc02058f0 <commands+0x8d8>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc020106e:	00014717          	auipc	a4,0x14
ffffffffc0201072:	46f73923          	sd	a5,1138(a4) # ffffffffc02154e0 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc0201076:	85aff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc020107a:	46c5                	li	a3,17
ffffffffc020107c:	06ee                	slli	a3,a3,0x1b
ffffffffc020107e:	40100613          	li	a2,1025
ffffffffc0201082:	16fd                	addi	a3,a3,-1
ffffffffc0201084:	0656                	slli	a2,a2,0x15
ffffffffc0201086:	07e005b7          	lui	a1,0x7e00
ffffffffc020108a:	00005517          	auipc	a0,0x5
ffffffffc020108e:	87e50513          	addi	a0,a0,-1922 # ffffffffc0205908 <commands+0x8f0>
ffffffffc0201092:	83eff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201096:	777d                	lui	a4,0xfffff
ffffffffc0201098:	00015797          	auipc	a5,0x15
ffffffffc020109c:	56778793          	addi	a5,a5,1383 # ffffffffc02165ff <end+0xfff>
ffffffffc02010a0:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc02010a2:	00088737          	lui	a4,0x88
ffffffffc02010a6:	00014697          	auipc	a3,0x14
ffffffffc02010aa:	3ee6b123          	sd	a4,994(a3) # ffffffffc0215488 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02010ae:	00014717          	auipc	a4,0x14
ffffffffc02010b2:	44f73123          	sd	a5,1090(a4) # ffffffffc02154f0 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02010b6:	4701                	li	a4,0
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02010b8:	4685                	li	a3,1
ffffffffc02010ba:	fff80837          	lui	a6,0xfff80
ffffffffc02010be:	a019                	j	ffffffffc02010c4 <pmm_init+0xb4>
ffffffffc02010c0:	00093783          	ld	a5,0(s2)
        SetPageReserved(pages + i);
ffffffffc02010c4:	00671613          	slli	a2,a4,0x6
ffffffffc02010c8:	97b2                	add	a5,a5,a2
ffffffffc02010ca:	07a1                	addi	a5,a5,8
ffffffffc02010cc:	40d7b02f          	amoor.d	zero,a3,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02010d0:	6090                	ld	a2,0(s1)
ffffffffc02010d2:	0705                	addi	a4,a4,1
ffffffffc02010d4:	010607b3          	add	a5,a2,a6
ffffffffc02010d8:	fef764e3          	bltu	a4,a5,ffffffffc02010c0 <pmm_init+0xb0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02010dc:	00093503          	ld	a0,0(s2)
ffffffffc02010e0:	fe0007b7          	lui	a5,0xfe000
ffffffffc02010e4:	00661693          	slli	a3,a2,0x6
ffffffffc02010e8:	97aa                	add	a5,a5,a0
ffffffffc02010ea:	96be                	add	a3,a3,a5
ffffffffc02010ec:	c02007b7          	lui	a5,0xc0200
ffffffffc02010f0:	7af6eb63          	bltu	a3,a5,ffffffffc02018a6 <pmm_init+0x896>
ffffffffc02010f4:	00014997          	auipc	s3,0x14
ffffffffc02010f8:	3ec98993          	addi	s3,s3,1004 # ffffffffc02154e0 <va_pa_offset>
ffffffffc02010fc:	0009b583          	ld	a1,0(s3)
    if (freemem < mem_end) {
ffffffffc0201100:	47c5                	li	a5,17
ffffffffc0201102:	07ee                	slli	a5,a5,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201104:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end) {
ffffffffc0201106:	02f6f763          	bgeu	a3,a5,ffffffffc0201134 <pmm_init+0x124>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc020110a:	6585                	lui	a1,0x1
ffffffffc020110c:	15fd                	addi	a1,a1,-1
ffffffffc020110e:	96ae                	add	a3,a3,a1
    if (PPN(pa) >= npage) {
ffffffffc0201110:	00c6d713          	srli	a4,a3,0xc
ffffffffc0201114:	48c77863          	bgeu	a4,a2,ffffffffc02015a4 <pmm_init+0x594>
    pmm_manager->init_memmap(base, n);
ffffffffc0201118:	6010                	ld	a2,0(s0)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc020111a:	75fd                	lui	a1,0xfffff
ffffffffc020111c:	8eed                	and	a3,a3,a1
    return &pages[PPN(pa) - nbase];
ffffffffc020111e:	9742                	add	a4,a4,a6
    pmm_manager->init_memmap(base, n);
ffffffffc0201120:	6a10                	ld	a2,16(a2)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0201122:	40d786b3          	sub	a3,a5,a3
ffffffffc0201126:	071a                	slli	a4,a4,0x6
    pmm_manager->init_memmap(base, n);
ffffffffc0201128:	00c6d593          	srli	a1,a3,0xc
ffffffffc020112c:	953a                	add	a0,a0,a4
ffffffffc020112e:	9602                	jalr	a2
ffffffffc0201130:	0009b583          	ld	a1,0(s3)
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc0201134:	00005517          	auipc	a0,0x5
ffffffffc0201138:	82450513          	addi	a0,a0,-2012 # ffffffffc0205958 <commands+0x940>
ffffffffc020113c:	f95fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0201140:	601c                	ld	a5,0(s0)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0201142:	00014417          	auipc	s0,0x14
ffffffffc0201146:	33e40413          	addi	s0,s0,830 # ffffffffc0215480 <boot_pgdir>
    pmm_manager->check();
ffffffffc020114a:	7b9c                	ld	a5,48(a5)
ffffffffc020114c:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc020114e:	00005517          	auipc	a0,0x5
ffffffffc0201152:	82250513          	addi	a0,a0,-2014 # ffffffffc0205970 <commands+0x958>
ffffffffc0201156:	f7bfe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc020115a:	00008697          	auipc	a3,0x8
ffffffffc020115e:	ea668693          	addi	a3,a3,-346 # ffffffffc0209000 <boot_page_table_sv39>
ffffffffc0201162:	00014797          	auipc	a5,0x14
ffffffffc0201166:	30d7bf23          	sd	a3,798(a5) # ffffffffc0215480 <boot_pgdir>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc020116a:	c02007b7          	lui	a5,0xc0200
ffffffffc020116e:	10f6e8e3          	bltu	a3,a5,ffffffffc0201a7e <pmm_init+0xa6e>
ffffffffc0201172:	0009b783          	ld	a5,0(s3)
ffffffffc0201176:	8e9d                	sub	a3,a3,a5
ffffffffc0201178:	00014797          	auipc	a5,0x14
ffffffffc020117c:	36d7b823          	sd	a3,880(a5) # ffffffffc02154e8 <boot_cr3>
    // assert(npage <= KMEMSIZE / PGSIZE);
    // The memory starts at 2GB in RISC-V
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();
ffffffffc0201180:	af5ff0ef          	jal	ra,ffffffffc0200c74 <nr_free_pages>

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0201184:	6098                	ld	a4,0(s1)
ffffffffc0201186:	c80007b7          	lui	a5,0xc8000
ffffffffc020118a:	83b1                	srli	a5,a5,0xc
    nr_free_store=nr_free_pages();
ffffffffc020118c:	8a2a                	mv	s4,a0
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc020118e:	0ce7e8e3          	bltu	a5,a4,ffffffffc0201a5e <pmm_init+0xa4e>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0201192:	6008                	ld	a0,0(s0)
ffffffffc0201194:	44050263          	beqz	a0,ffffffffc02015d8 <pmm_init+0x5c8>
ffffffffc0201198:	03451793          	slli	a5,a0,0x34
ffffffffc020119c:	42079e63          	bnez	a5,ffffffffc02015d8 <pmm_init+0x5c8>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc02011a0:	4601                	li	a2,0
ffffffffc02011a2:	4581                	li	a1,0
ffffffffc02011a4:	ce3ff0ef          	jal	ra,ffffffffc0200e86 <get_page>
ffffffffc02011a8:	78051b63          	bnez	a0,ffffffffc020193e <pmm_init+0x92e>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc02011ac:	4505                	li	a0,1
ffffffffc02011ae:	9f9ff0ef          	jal	ra,ffffffffc0200ba6 <alloc_pages>
ffffffffc02011b2:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc02011b4:	6008                	ld	a0,0(s0)
ffffffffc02011b6:	4681                	li	a3,0
ffffffffc02011b8:	4601                	li	a2,0
ffffffffc02011ba:	85d6                	mv	a1,s5
ffffffffc02011bc:	d97ff0ef          	jal	ra,ffffffffc0200f52 <page_insert>
ffffffffc02011c0:	7a051f63          	bnez	a0,ffffffffc020197e <pmm_init+0x96e>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc02011c4:	6008                	ld	a0,0(s0)
ffffffffc02011c6:	4601                	li	a2,0
ffffffffc02011c8:	4581                	li	a1,0
ffffffffc02011ca:	aebff0ef          	jal	ra,ffffffffc0200cb4 <get_pte>
ffffffffc02011ce:	78050863          	beqz	a0,ffffffffc020195e <pmm_init+0x94e>
    assert(pte2page(*ptep) == p1);
ffffffffc02011d2:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02011d4:	0017f713          	andi	a4,a5,1
ffffffffc02011d8:	3e070463          	beqz	a4,ffffffffc02015c0 <pmm_init+0x5b0>
    if (PPN(pa) >= npage) {
ffffffffc02011dc:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc02011de:	078a                	slli	a5,a5,0x2
ffffffffc02011e0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02011e2:	3ce7f163          	bgeu	a5,a4,ffffffffc02015a4 <pmm_init+0x594>
    return &pages[PPN(pa) - nbase];
ffffffffc02011e6:	00093683          	ld	a3,0(s2)
ffffffffc02011ea:	fff80637          	lui	a2,0xfff80
ffffffffc02011ee:	97b2                	add	a5,a5,a2
ffffffffc02011f0:	079a                	slli	a5,a5,0x6
ffffffffc02011f2:	97b6                	add	a5,a5,a3
ffffffffc02011f4:	72fa9563          	bne	s5,a5,ffffffffc020191e <pmm_init+0x90e>
    assert(page_ref(p1) == 1);
ffffffffc02011f8:	000aab83          	lw	s7,0(s5)
ffffffffc02011fc:	4785                	li	a5,1
ffffffffc02011fe:	70fb9063          	bne	s7,a5,ffffffffc02018fe <pmm_init+0x8ee>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0201202:	6008                	ld	a0,0(s0)
ffffffffc0201204:	76fd                	lui	a3,0xfffff
ffffffffc0201206:	611c                	ld	a5,0(a0)
ffffffffc0201208:	078a                	slli	a5,a5,0x2
ffffffffc020120a:	8ff5                	and	a5,a5,a3
ffffffffc020120c:	00c7d613          	srli	a2,a5,0xc
ffffffffc0201210:	66e67e63          	bgeu	a2,a4,ffffffffc020188c <pmm_init+0x87c>
ffffffffc0201214:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201218:	97e2                	add	a5,a5,s8
ffffffffc020121a:	0007bb03          	ld	s6,0(a5) # ffffffffc8000000 <end+0x7deaa00>
ffffffffc020121e:	0b0a                	slli	s6,s6,0x2
ffffffffc0201220:	00db7b33          	and	s6,s6,a3
ffffffffc0201224:	00cb5793          	srli	a5,s6,0xc
ffffffffc0201228:	56e7f863          	bgeu	a5,a4,ffffffffc0201798 <pmm_init+0x788>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc020122c:	4601                	li	a2,0
ffffffffc020122e:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201230:	9b62                	add	s6,s6,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201232:	a83ff0ef          	jal	ra,ffffffffc0200cb4 <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201236:	0b21                	addi	s6,s6,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201238:	55651063          	bne	a0,s6,ffffffffc0201778 <pmm_init+0x768>

    p2 = alloc_page();
ffffffffc020123c:	4505                	li	a0,1
ffffffffc020123e:	969ff0ef          	jal	ra,ffffffffc0200ba6 <alloc_pages>
ffffffffc0201242:	8b2a                	mv	s6,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0201244:	6008                	ld	a0,0(s0)
ffffffffc0201246:	46d1                	li	a3,20
ffffffffc0201248:	6605                	lui	a2,0x1
ffffffffc020124a:	85da                	mv	a1,s6
ffffffffc020124c:	d07ff0ef          	jal	ra,ffffffffc0200f52 <page_insert>
ffffffffc0201250:	50051463          	bnez	a0,ffffffffc0201758 <pmm_init+0x748>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201254:	6008                	ld	a0,0(s0)
ffffffffc0201256:	4601                	li	a2,0
ffffffffc0201258:	6585                	lui	a1,0x1
ffffffffc020125a:	a5bff0ef          	jal	ra,ffffffffc0200cb4 <get_pte>
ffffffffc020125e:	4c050d63          	beqz	a0,ffffffffc0201738 <pmm_init+0x728>
    assert(*ptep & PTE_U);
ffffffffc0201262:	611c                	ld	a5,0(a0)
ffffffffc0201264:	0107f713          	andi	a4,a5,16
ffffffffc0201268:	4a070863          	beqz	a4,ffffffffc0201718 <pmm_init+0x708>
    assert(*ptep & PTE_W);
ffffffffc020126c:	8b91                	andi	a5,a5,4
ffffffffc020126e:	48078563          	beqz	a5,ffffffffc02016f8 <pmm_init+0x6e8>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0201272:	6008                	ld	a0,0(s0)
ffffffffc0201274:	611c                	ld	a5,0(a0)
ffffffffc0201276:	8bc1                	andi	a5,a5,16
ffffffffc0201278:	46078063          	beqz	a5,ffffffffc02016d8 <pmm_init+0x6c8>
    assert(page_ref(p2) == 1);
ffffffffc020127c:	000b2783          	lw	a5,0(s6)
ffffffffc0201280:	43779c63          	bne	a5,s7,ffffffffc02016b8 <pmm_init+0x6a8>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0201284:	4681                	li	a3,0
ffffffffc0201286:	6605                	lui	a2,0x1
ffffffffc0201288:	85d6                	mv	a1,s5
ffffffffc020128a:	cc9ff0ef          	jal	ra,ffffffffc0200f52 <page_insert>
ffffffffc020128e:	40051563          	bnez	a0,ffffffffc0201698 <pmm_init+0x688>
    assert(page_ref(p1) == 2);
ffffffffc0201292:	000aa703          	lw	a4,0(s5)
ffffffffc0201296:	4789                	li	a5,2
ffffffffc0201298:	3ef71063          	bne	a4,a5,ffffffffc0201678 <pmm_init+0x668>
    assert(page_ref(p2) == 0);
ffffffffc020129c:	000b2783          	lw	a5,0(s6)
ffffffffc02012a0:	3a079c63          	bnez	a5,ffffffffc0201658 <pmm_init+0x648>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02012a4:	6008                	ld	a0,0(s0)
ffffffffc02012a6:	4601                	li	a2,0
ffffffffc02012a8:	6585                	lui	a1,0x1
ffffffffc02012aa:	a0bff0ef          	jal	ra,ffffffffc0200cb4 <get_pte>
ffffffffc02012ae:	38050563          	beqz	a0,ffffffffc0201638 <pmm_init+0x628>
    assert(pte2page(*ptep) == p1);
ffffffffc02012b2:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02012b4:	00177793          	andi	a5,a4,1
ffffffffc02012b8:	30078463          	beqz	a5,ffffffffc02015c0 <pmm_init+0x5b0>
    if (PPN(pa) >= npage) {
ffffffffc02012bc:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc02012be:	00271793          	slli	a5,a4,0x2
ffffffffc02012c2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02012c4:	2ed7f063          	bgeu	a5,a3,ffffffffc02015a4 <pmm_init+0x594>
    return &pages[PPN(pa) - nbase];
ffffffffc02012c8:	00093683          	ld	a3,0(s2)
ffffffffc02012cc:	fff80637          	lui	a2,0xfff80
ffffffffc02012d0:	97b2                	add	a5,a5,a2
ffffffffc02012d2:	079a                	slli	a5,a5,0x6
ffffffffc02012d4:	97b6                	add	a5,a5,a3
ffffffffc02012d6:	32fa9163          	bne	s5,a5,ffffffffc02015f8 <pmm_init+0x5e8>
    assert((*ptep & PTE_U) == 0);
ffffffffc02012da:	8b41                	andi	a4,a4,16
ffffffffc02012dc:	70071163          	bnez	a4,ffffffffc02019de <pmm_init+0x9ce>

    page_remove(boot_pgdir, 0x0);
ffffffffc02012e0:	6008                	ld	a0,0(s0)
ffffffffc02012e2:	4581                	li	a1,0
ffffffffc02012e4:	bfbff0ef          	jal	ra,ffffffffc0200ede <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc02012e8:	000aa703          	lw	a4,0(s5)
ffffffffc02012ec:	4785                	li	a5,1
ffffffffc02012ee:	6cf71863          	bne	a4,a5,ffffffffc02019be <pmm_init+0x9ae>
    assert(page_ref(p2) == 0);
ffffffffc02012f2:	000b2783          	lw	a5,0(s6)
ffffffffc02012f6:	6a079463          	bnez	a5,ffffffffc020199e <pmm_init+0x98e>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc02012fa:	6008                	ld	a0,0(s0)
ffffffffc02012fc:	6585                	lui	a1,0x1
ffffffffc02012fe:	be1ff0ef          	jal	ra,ffffffffc0200ede <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0201302:	000aa783          	lw	a5,0(s5)
ffffffffc0201306:	50079363          	bnez	a5,ffffffffc020180c <pmm_init+0x7fc>
    assert(page_ref(p2) == 0);
ffffffffc020130a:	000b2783          	lw	a5,0(s6)
ffffffffc020130e:	4c079f63          	bnez	a5,ffffffffc02017ec <pmm_init+0x7dc>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0201312:	00043b03          	ld	s6,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0201316:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201318:	000b3783          	ld	a5,0(s6)
ffffffffc020131c:	078a                	slli	a5,a5,0x2
ffffffffc020131e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201320:	28e7f263          	bgeu	a5,a4,ffffffffc02015a4 <pmm_init+0x594>
    return &pages[PPN(pa) - nbase];
ffffffffc0201324:	fff806b7          	lui	a3,0xfff80
ffffffffc0201328:	00093503          	ld	a0,0(s2)
ffffffffc020132c:	97b6                	add	a5,a5,a3
ffffffffc020132e:	079a                	slli	a5,a5,0x6
ffffffffc0201330:	00f506b3          	add	a3,a0,a5
ffffffffc0201334:	4290                	lw	a2,0(a3)
ffffffffc0201336:	4685                	li	a3,1
ffffffffc0201338:	48d61a63          	bne	a2,a3,ffffffffc02017cc <pmm_init+0x7bc>
    return page - pages + nbase;
ffffffffc020133c:	8799                	srai	a5,a5,0x6
ffffffffc020133e:	00080ab7          	lui	s5,0x80
ffffffffc0201342:	97d6                	add	a5,a5,s5
    return KADDR(page2pa(page));
ffffffffc0201344:	00c79693          	slli	a3,a5,0xc
ffffffffc0201348:	82b1                	srli	a3,a3,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc020134a:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc020134c:	46e6f363          	bgeu	a3,a4,ffffffffc02017b2 <pmm_init+0x7a2>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0201350:	0009b683          	ld	a3,0(s3)
ffffffffc0201354:	97b6                	add	a5,a5,a3
    return pa2page(PDE_ADDR(pde));
ffffffffc0201356:	639c                	ld	a5,0(a5)
ffffffffc0201358:	078a                	slli	a5,a5,0x2
ffffffffc020135a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020135c:	24e7f463          	bgeu	a5,a4,ffffffffc02015a4 <pmm_init+0x594>
    return &pages[PPN(pa) - nbase];
ffffffffc0201360:	415787b3          	sub	a5,a5,s5
ffffffffc0201364:	079a                	slli	a5,a5,0x6
ffffffffc0201366:	953e                	add	a0,a0,a5
ffffffffc0201368:	4585                	li	a1,1
ffffffffc020136a:	8c5ff0ef          	jal	ra,ffffffffc0200c2e <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc020136e:	000b3783          	ld	a5,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc0201372:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201374:	078a                	slli	a5,a5,0x2
ffffffffc0201376:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201378:	22e7f663          	bgeu	a5,a4,ffffffffc02015a4 <pmm_init+0x594>
    return &pages[PPN(pa) - nbase];
ffffffffc020137c:	00093503          	ld	a0,0(s2)
ffffffffc0201380:	415787b3          	sub	a5,a5,s5
ffffffffc0201384:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0201386:	953e                	add	a0,a0,a5
ffffffffc0201388:	4585                	li	a1,1
ffffffffc020138a:	8a5ff0ef          	jal	ra,ffffffffc0200c2e <free_pages>
    boot_pgdir[0] = 0;
ffffffffc020138e:	601c                	ld	a5,0(s0)
ffffffffc0201390:	0007b023          	sd	zero,0(a5)
  asm volatile("sfence.vma");
ffffffffc0201394:	12000073          	sfence.vma
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0201398:	8ddff0ef          	jal	ra,ffffffffc0200c74 <nr_free_pages>
ffffffffc020139c:	68aa1163          	bne	s4,a0,ffffffffc0201a1e <pmm_init+0xa0e>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc02013a0:	00005517          	auipc	a0,0x5
ffffffffc02013a4:	8f850513          	addi	a0,a0,-1800 # ffffffffc0205c98 <commands+0xc80>
ffffffffc02013a8:	d29fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
static void check_boot_pgdir(void) {
    size_t nr_free_store;
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();
ffffffffc02013ac:	8c9ff0ef          	jal	ra,ffffffffc0200c74 <nr_free_pages>

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02013b0:	6098                	ld	a4,0(s1)
ffffffffc02013b2:	c02007b7          	lui	a5,0xc0200
    nr_free_store=nr_free_pages();
ffffffffc02013b6:	8a2a                	mv	s4,a0
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02013b8:	00c71693          	slli	a3,a4,0xc
ffffffffc02013bc:	18d7f563          	bgeu	a5,a3,ffffffffc0201546 <pmm_init+0x536>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02013c0:	83b1                	srli	a5,a5,0xc
ffffffffc02013c2:	6008                	ld	a0,0(s0)
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02013c4:	c0200ab7          	lui	s5,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02013c8:	1ae7f163          	bgeu	a5,a4,ffffffffc020156a <pmm_init+0x55a>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02013cc:	7bfd                	lui	s7,0xfffff
ffffffffc02013ce:	6b05                	lui	s6,0x1
ffffffffc02013d0:	a029                	j	ffffffffc02013da <pmm_init+0x3ca>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02013d2:	00cad713          	srli	a4,s5,0xc
ffffffffc02013d6:	18f77a63          	bgeu	a4,a5,ffffffffc020156a <pmm_init+0x55a>
ffffffffc02013da:	0009b583          	ld	a1,0(s3)
ffffffffc02013de:	4601                	li	a2,0
ffffffffc02013e0:	95d6                	add	a1,a1,s5
ffffffffc02013e2:	8d3ff0ef          	jal	ra,ffffffffc0200cb4 <get_pte>
ffffffffc02013e6:	16050263          	beqz	a0,ffffffffc020154a <pmm_init+0x53a>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02013ea:	611c                	ld	a5,0(a0)
ffffffffc02013ec:	078a                	slli	a5,a5,0x2
ffffffffc02013ee:	0177f7b3          	and	a5,a5,s7
ffffffffc02013f2:	19579963          	bne	a5,s5,ffffffffc0201584 <pmm_init+0x574>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02013f6:	609c                	ld	a5,0(s1)
ffffffffc02013f8:	9ada                	add	s5,s5,s6
ffffffffc02013fa:	6008                	ld	a0,0(s0)
ffffffffc02013fc:	00c79713          	slli	a4,a5,0xc
ffffffffc0201400:	fceae9e3          	bltu	s5,a4,ffffffffc02013d2 <pmm_init+0x3c2>
    }

    assert(boot_pgdir[0] == 0);
ffffffffc0201404:	611c                	ld	a5,0(a0)
ffffffffc0201406:	62079c63          	bnez	a5,ffffffffc0201a3e <pmm_init+0xa2e>

    struct Page *p;
    p = alloc_page();
ffffffffc020140a:	4505                	li	a0,1
ffffffffc020140c:	f9aff0ef          	jal	ra,ffffffffc0200ba6 <alloc_pages>
ffffffffc0201410:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0201412:	6008                	ld	a0,0(s0)
ffffffffc0201414:	4699                	li	a3,6
ffffffffc0201416:	10000613          	li	a2,256
ffffffffc020141a:	85d6                	mv	a1,s5
ffffffffc020141c:	b37ff0ef          	jal	ra,ffffffffc0200f52 <page_insert>
ffffffffc0201420:	1e051c63          	bnez	a0,ffffffffc0201618 <pmm_init+0x608>
    assert(page_ref(p) == 1);
ffffffffc0201424:	000aa703          	lw	a4,0(s5) # ffffffffc0200000 <kern_entry>
ffffffffc0201428:	4785                	li	a5,1
ffffffffc020142a:	44f71163          	bne	a4,a5,ffffffffc020186c <pmm_init+0x85c>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc020142e:	6008                	ld	a0,0(s0)
ffffffffc0201430:	6b05                	lui	s6,0x1
ffffffffc0201432:	4699                	li	a3,6
ffffffffc0201434:	100b0613          	addi	a2,s6,256 # 1100 <BASE_ADDRESS-0xffffffffc01fef00>
ffffffffc0201438:	85d6                	mv	a1,s5
ffffffffc020143a:	b19ff0ef          	jal	ra,ffffffffc0200f52 <page_insert>
ffffffffc020143e:	40051763          	bnez	a0,ffffffffc020184c <pmm_init+0x83c>
    assert(page_ref(p) == 2);
ffffffffc0201442:	000aa703          	lw	a4,0(s5)
ffffffffc0201446:	4789                	li	a5,2
ffffffffc0201448:	3ef71263          	bne	a4,a5,ffffffffc020182c <pmm_init+0x81c>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc020144c:	00005597          	auipc	a1,0x5
ffffffffc0201450:	98458593          	addi	a1,a1,-1660 # ffffffffc0205dd0 <commands+0xdb8>
ffffffffc0201454:	10000513          	li	a0,256
ffffffffc0201458:	5b8030ef          	jal	ra,ffffffffc0204a10 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc020145c:	100b0593          	addi	a1,s6,256
ffffffffc0201460:	10000513          	li	a0,256
ffffffffc0201464:	5be030ef          	jal	ra,ffffffffc0204a22 <strcmp>
ffffffffc0201468:	44051b63          	bnez	a0,ffffffffc02018be <pmm_init+0x8ae>
    return page - pages + nbase;
ffffffffc020146c:	00093683          	ld	a3,0(s2)
ffffffffc0201470:	00080737          	lui	a4,0x80
    return KADDR(page2pa(page));
ffffffffc0201474:	5b7d                	li	s6,-1
    return page - pages + nbase;
ffffffffc0201476:	40da86b3          	sub	a3,s5,a3
ffffffffc020147a:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc020147c:	609c                	ld	a5,0(s1)
    return page - pages + nbase;
ffffffffc020147e:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc0201480:	00cb5b13          	srli	s6,s6,0xc
ffffffffc0201484:	0166f733          	and	a4,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc0201488:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020148a:	10f77f63          	bgeu	a4,a5,ffffffffc02015a8 <pmm_init+0x598>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc020148e:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0201492:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0201496:	96be                	add	a3,a3,a5
ffffffffc0201498:	10068023          	sb	zero,256(a3) # fffffffffff80100 <end+0x3fd6ab00>
    assert(strlen((const char *)0x100) == 0);
ffffffffc020149c:	530030ef          	jal	ra,ffffffffc02049cc <strlen>
ffffffffc02014a0:	54051f63          	bnez	a0,ffffffffc02019fe <pmm_init+0x9ee>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc02014a4:	00043b83          	ld	s7,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc02014a8:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02014aa:	000bb683          	ld	a3,0(s7) # fffffffffffff000 <end+0x3fde9a00>
ffffffffc02014ae:	068a                	slli	a3,a3,0x2
ffffffffc02014b0:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc02014b2:	0ef6f963          	bgeu	a3,a5,ffffffffc02015a4 <pmm_init+0x594>
    return KADDR(page2pa(page));
ffffffffc02014b6:	0166fb33          	and	s6,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc02014ba:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02014bc:	0efb7663          	bgeu	s6,a5,ffffffffc02015a8 <pmm_init+0x598>
ffffffffc02014c0:	0009b983          	ld	s3,0(s3)
    free_page(p);
ffffffffc02014c4:	4585                	li	a1,1
ffffffffc02014c6:	8556                	mv	a0,s5
ffffffffc02014c8:	99b6                	add	s3,s3,a3
ffffffffc02014ca:	f64ff0ef          	jal	ra,ffffffffc0200c2e <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc02014ce:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc02014d2:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02014d4:	078a                	slli	a5,a5,0x2
ffffffffc02014d6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02014d8:	0ce7f663          	bgeu	a5,a4,ffffffffc02015a4 <pmm_init+0x594>
    return &pages[PPN(pa) - nbase];
ffffffffc02014dc:	00093503          	ld	a0,0(s2)
ffffffffc02014e0:	fff809b7          	lui	s3,0xfff80
ffffffffc02014e4:	97ce                	add	a5,a5,s3
ffffffffc02014e6:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc02014e8:	953e                	add	a0,a0,a5
ffffffffc02014ea:	4585                	li	a1,1
ffffffffc02014ec:	f42ff0ef          	jal	ra,ffffffffc0200c2e <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc02014f0:	000bb783          	ld	a5,0(s7)
    if (PPN(pa) >= npage) {
ffffffffc02014f4:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02014f6:	078a                	slli	a5,a5,0x2
ffffffffc02014f8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02014fa:	0ae7f563          	bgeu	a5,a4,ffffffffc02015a4 <pmm_init+0x594>
    return &pages[PPN(pa) - nbase];
ffffffffc02014fe:	00093503          	ld	a0,0(s2)
ffffffffc0201502:	97ce                	add	a5,a5,s3
ffffffffc0201504:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0201506:	953e                	add	a0,a0,a5
ffffffffc0201508:	4585                	li	a1,1
ffffffffc020150a:	f24ff0ef          	jal	ra,ffffffffc0200c2e <free_pages>
    boot_pgdir[0] = 0;
ffffffffc020150e:	601c                	ld	a5,0(s0)
ffffffffc0201510:	0007b023          	sd	zero,0(a5) # ffffffffc0200000 <kern_entry>
  asm volatile("sfence.vma");
ffffffffc0201514:	12000073          	sfence.vma
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0201518:	f5cff0ef          	jal	ra,ffffffffc0200c74 <nr_free_pages>
ffffffffc020151c:	3caa1163          	bne	s4,a0,ffffffffc02018de <pmm_init+0x8ce>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0201520:	00005517          	auipc	a0,0x5
ffffffffc0201524:	92850513          	addi	a0,a0,-1752 # ffffffffc0205e48 <commands+0xe30>
ffffffffc0201528:	ba9fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
}
ffffffffc020152c:	6406                	ld	s0,64(sp)
ffffffffc020152e:	60a6                	ld	ra,72(sp)
ffffffffc0201530:	74e2                	ld	s1,56(sp)
ffffffffc0201532:	7942                	ld	s2,48(sp)
ffffffffc0201534:	79a2                	ld	s3,40(sp)
ffffffffc0201536:	7a02                	ld	s4,32(sp)
ffffffffc0201538:	6ae2                	ld	s5,24(sp)
ffffffffc020153a:	6b42                	ld	s6,16(sp)
ffffffffc020153c:	6ba2                	ld	s7,8(sp)
ffffffffc020153e:	6c02                	ld	s8,0(sp)
ffffffffc0201540:	6161                	addi	sp,sp,80
    kmalloc_init();
ffffffffc0201542:	1b10106f          	j	ffffffffc0202ef2 <kmalloc_init>
ffffffffc0201546:	6008                	ld	a0,0(s0)
ffffffffc0201548:	bd75                	j	ffffffffc0201404 <pmm_init+0x3f4>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc020154a:	00004697          	auipc	a3,0x4
ffffffffc020154e:	76e68693          	addi	a3,a3,1902 # ffffffffc0205cb8 <commands+0xca0>
ffffffffc0201552:	00004617          	auipc	a2,0x4
ffffffffc0201556:	45e60613          	addi	a2,a2,1118 # ffffffffc02059b0 <commands+0x998>
ffffffffc020155a:	19d00593          	li	a1,413
ffffffffc020155e:	00004517          	auipc	a0,0x4
ffffffffc0201562:	32250513          	addi	a0,a0,802 # ffffffffc0205880 <commands+0x868>
ffffffffc0201566:	c6ffe0ef          	jal	ra,ffffffffc02001d4 <__panic>
ffffffffc020156a:	86d6                	mv	a3,s5
ffffffffc020156c:	00004617          	auipc	a2,0x4
ffffffffc0201570:	2ec60613          	addi	a2,a2,748 # ffffffffc0205858 <commands+0x840>
ffffffffc0201574:	19d00593          	li	a1,413
ffffffffc0201578:	00004517          	auipc	a0,0x4
ffffffffc020157c:	30850513          	addi	a0,a0,776 # ffffffffc0205880 <commands+0x868>
ffffffffc0201580:	c55fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201584:	00004697          	auipc	a3,0x4
ffffffffc0201588:	77468693          	addi	a3,a3,1908 # ffffffffc0205cf8 <commands+0xce0>
ffffffffc020158c:	00004617          	auipc	a2,0x4
ffffffffc0201590:	42460613          	addi	a2,a2,1060 # ffffffffc02059b0 <commands+0x998>
ffffffffc0201594:	19e00593          	li	a1,414
ffffffffc0201598:	00004517          	auipc	a0,0x4
ffffffffc020159c:	2e850513          	addi	a0,a0,744 # ffffffffc0205880 <commands+0x868>
ffffffffc02015a0:	c35fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
ffffffffc02015a4:	de6ff0ef          	jal	ra,ffffffffc0200b8a <pa2page.part.4>
    return KADDR(page2pa(page));
ffffffffc02015a8:	00004617          	auipc	a2,0x4
ffffffffc02015ac:	2b060613          	addi	a2,a2,688 # ffffffffc0205858 <commands+0x840>
ffffffffc02015b0:	06900593          	li	a1,105
ffffffffc02015b4:	00004517          	auipc	a0,0x4
ffffffffc02015b8:	2fc50513          	addi	a0,a0,764 # ffffffffc02058b0 <commands+0x898>
ffffffffc02015bc:	c19fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc02015c0:	00004617          	auipc	a2,0x4
ffffffffc02015c4:	4c860613          	addi	a2,a2,1224 # ffffffffc0205a88 <commands+0xa70>
ffffffffc02015c8:	07400593          	li	a1,116
ffffffffc02015cc:	00004517          	auipc	a0,0x4
ffffffffc02015d0:	2e450513          	addi	a0,a0,740 # ffffffffc02058b0 <commands+0x898>
ffffffffc02015d4:	c01fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc02015d8:	00004697          	auipc	a3,0x4
ffffffffc02015dc:	3f068693          	addi	a3,a3,1008 # ffffffffc02059c8 <commands+0x9b0>
ffffffffc02015e0:	00004617          	auipc	a2,0x4
ffffffffc02015e4:	3d060613          	addi	a2,a2,976 # ffffffffc02059b0 <commands+0x998>
ffffffffc02015e8:	16100593          	li	a1,353
ffffffffc02015ec:	00004517          	auipc	a0,0x4
ffffffffc02015f0:	29450513          	addi	a0,a0,660 # ffffffffc0205880 <commands+0x868>
ffffffffc02015f4:	be1fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc02015f8:	00004697          	auipc	a3,0x4
ffffffffc02015fc:	4b868693          	addi	a3,a3,1208 # ffffffffc0205ab0 <commands+0xa98>
ffffffffc0201600:	00004617          	auipc	a2,0x4
ffffffffc0201604:	3b060613          	addi	a2,a2,944 # ffffffffc02059b0 <commands+0x998>
ffffffffc0201608:	17d00593          	li	a1,381
ffffffffc020160c:	00004517          	auipc	a0,0x4
ffffffffc0201610:	27450513          	addi	a0,a0,628 # ffffffffc0205880 <commands+0x868>
ffffffffc0201614:	bc1fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0201618:	00004697          	auipc	a3,0x4
ffffffffc020161c:	71068693          	addi	a3,a3,1808 # ffffffffc0205d28 <commands+0xd10>
ffffffffc0201620:	00004617          	auipc	a2,0x4
ffffffffc0201624:	39060613          	addi	a2,a2,912 # ffffffffc02059b0 <commands+0x998>
ffffffffc0201628:	1a500593          	li	a1,421
ffffffffc020162c:	00004517          	auipc	a0,0x4
ffffffffc0201630:	25450513          	addi	a0,a0,596 # ffffffffc0205880 <commands+0x868>
ffffffffc0201634:	ba1fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201638:	00004697          	auipc	a3,0x4
ffffffffc020163c:	50868693          	addi	a3,a3,1288 # ffffffffc0205b40 <commands+0xb28>
ffffffffc0201640:	00004617          	auipc	a2,0x4
ffffffffc0201644:	37060613          	addi	a2,a2,880 # ffffffffc02059b0 <commands+0x998>
ffffffffc0201648:	17c00593          	li	a1,380
ffffffffc020164c:	00004517          	auipc	a0,0x4
ffffffffc0201650:	23450513          	addi	a0,a0,564 # ffffffffc0205880 <commands+0x868>
ffffffffc0201654:	b81fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0201658:	00004697          	auipc	a3,0x4
ffffffffc020165c:	5b068693          	addi	a3,a3,1456 # ffffffffc0205c08 <commands+0xbf0>
ffffffffc0201660:	00004617          	auipc	a2,0x4
ffffffffc0201664:	35060613          	addi	a2,a2,848 # ffffffffc02059b0 <commands+0x998>
ffffffffc0201668:	17b00593          	li	a1,379
ffffffffc020166c:	00004517          	auipc	a0,0x4
ffffffffc0201670:	21450513          	addi	a0,a0,532 # ffffffffc0205880 <commands+0x868>
ffffffffc0201674:	b61fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0201678:	00004697          	auipc	a3,0x4
ffffffffc020167c:	57868693          	addi	a3,a3,1400 # ffffffffc0205bf0 <commands+0xbd8>
ffffffffc0201680:	00004617          	auipc	a2,0x4
ffffffffc0201684:	33060613          	addi	a2,a2,816 # ffffffffc02059b0 <commands+0x998>
ffffffffc0201688:	17a00593          	li	a1,378
ffffffffc020168c:	00004517          	auipc	a0,0x4
ffffffffc0201690:	1f450513          	addi	a0,a0,500 # ffffffffc0205880 <commands+0x868>
ffffffffc0201694:	b41fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0201698:	00004697          	auipc	a3,0x4
ffffffffc020169c:	52868693          	addi	a3,a3,1320 # ffffffffc0205bc0 <commands+0xba8>
ffffffffc02016a0:	00004617          	auipc	a2,0x4
ffffffffc02016a4:	31060613          	addi	a2,a2,784 # ffffffffc02059b0 <commands+0x998>
ffffffffc02016a8:	17900593          	li	a1,377
ffffffffc02016ac:	00004517          	auipc	a0,0x4
ffffffffc02016b0:	1d450513          	addi	a0,a0,468 # ffffffffc0205880 <commands+0x868>
ffffffffc02016b4:	b21fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc02016b8:	00004697          	auipc	a3,0x4
ffffffffc02016bc:	4f068693          	addi	a3,a3,1264 # ffffffffc0205ba8 <commands+0xb90>
ffffffffc02016c0:	00004617          	auipc	a2,0x4
ffffffffc02016c4:	2f060613          	addi	a2,a2,752 # ffffffffc02059b0 <commands+0x998>
ffffffffc02016c8:	17700593          	li	a1,375
ffffffffc02016cc:	00004517          	auipc	a0,0x4
ffffffffc02016d0:	1b450513          	addi	a0,a0,436 # ffffffffc0205880 <commands+0x868>
ffffffffc02016d4:	b01fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc02016d8:	00004697          	auipc	a3,0x4
ffffffffc02016dc:	4b868693          	addi	a3,a3,1208 # ffffffffc0205b90 <commands+0xb78>
ffffffffc02016e0:	00004617          	auipc	a2,0x4
ffffffffc02016e4:	2d060613          	addi	a2,a2,720 # ffffffffc02059b0 <commands+0x998>
ffffffffc02016e8:	17600593          	li	a1,374
ffffffffc02016ec:	00004517          	auipc	a0,0x4
ffffffffc02016f0:	19450513          	addi	a0,a0,404 # ffffffffc0205880 <commands+0x868>
ffffffffc02016f4:	ae1fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(*ptep & PTE_W);
ffffffffc02016f8:	00004697          	auipc	a3,0x4
ffffffffc02016fc:	48868693          	addi	a3,a3,1160 # ffffffffc0205b80 <commands+0xb68>
ffffffffc0201700:	00004617          	auipc	a2,0x4
ffffffffc0201704:	2b060613          	addi	a2,a2,688 # ffffffffc02059b0 <commands+0x998>
ffffffffc0201708:	17500593          	li	a1,373
ffffffffc020170c:	00004517          	auipc	a0,0x4
ffffffffc0201710:	17450513          	addi	a0,a0,372 # ffffffffc0205880 <commands+0x868>
ffffffffc0201714:	ac1fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(*ptep & PTE_U);
ffffffffc0201718:	00004697          	auipc	a3,0x4
ffffffffc020171c:	45868693          	addi	a3,a3,1112 # ffffffffc0205b70 <commands+0xb58>
ffffffffc0201720:	00004617          	auipc	a2,0x4
ffffffffc0201724:	29060613          	addi	a2,a2,656 # ffffffffc02059b0 <commands+0x998>
ffffffffc0201728:	17400593          	li	a1,372
ffffffffc020172c:	00004517          	auipc	a0,0x4
ffffffffc0201730:	15450513          	addi	a0,a0,340 # ffffffffc0205880 <commands+0x868>
ffffffffc0201734:	aa1fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201738:	00004697          	auipc	a3,0x4
ffffffffc020173c:	40868693          	addi	a3,a3,1032 # ffffffffc0205b40 <commands+0xb28>
ffffffffc0201740:	00004617          	auipc	a2,0x4
ffffffffc0201744:	27060613          	addi	a2,a2,624 # ffffffffc02059b0 <commands+0x998>
ffffffffc0201748:	17300593          	li	a1,371
ffffffffc020174c:	00004517          	auipc	a0,0x4
ffffffffc0201750:	13450513          	addi	a0,a0,308 # ffffffffc0205880 <commands+0x868>
ffffffffc0201754:	a81fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0201758:	00004697          	auipc	a3,0x4
ffffffffc020175c:	3b068693          	addi	a3,a3,944 # ffffffffc0205b08 <commands+0xaf0>
ffffffffc0201760:	00004617          	auipc	a2,0x4
ffffffffc0201764:	25060613          	addi	a2,a2,592 # ffffffffc02059b0 <commands+0x998>
ffffffffc0201768:	17200593          	li	a1,370
ffffffffc020176c:	00004517          	auipc	a0,0x4
ffffffffc0201770:	11450513          	addi	a0,a0,276 # ffffffffc0205880 <commands+0x868>
ffffffffc0201774:	a61fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201778:	00004697          	auipc	a3,0x4
ffffffffc020177c:	36868693          	addi	a3,a3,872 # ffffffffc0205ae0 <commands+0xac8>
ffffffffc0201780:	00004617          	auipc	a2,0x4
ffffffffc0201784:	23060613          	addi	a2,a2,560 # ffffffffc02059b0 <commands+0x998>
ffffffffc0201788:	16f00593          	li	a1,367
ffffffffc020178c:	00004517          	auipc	a0,0x4
ffffffffc0201790:	0f450513          	addi	a0,a0,244 # ffffffffc0205880 <commands+0x868>
ffffffffc0201794:	a41fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201798:	86da                	mv	a3,s6
ffffffffc020179a:	00004617          	auipc	a2,0x4
ffffffffc020179e:	0be60613          	addi	a2,a2,190 # ffffffffc0205858 <commands+0x840>
ffffffffc02017a2:	16e00593          	li	a1,366
ffffffffc02017a6:	00004517          	auipc	a0,0x4
ffffffffc02017aa:	0da50513          	addi	a0,a0,218 # ffffffffc0205880 <commands+0x868>
ffffffffc02017ae:	a27fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    return KADDR(page2pa(page));
ffffffffc02017b2:	86be                	mv	a3,a5
ffffffffc02017b4:	00004617          	auipc	a2,0x4
ffffffffc02017b8:	0a460613          	addi	a2,a2,164 # ffffffffc0205858 <commands+0x840>
ffffffffc02017bc:	06900593          	li	a1,105
ffffffffc02017c0:	00004517          	auipc	a0,0x4
ffffffffc02017c4:	0f050513          	addi	a0,a0,240 # ffffffffc02058b0 <commands+0x898>
ffffffffc02017c8:	a0dfe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc02017cc:	00004697          	auipc	a3,0x4
ffffffffc02017d0:	48468693          	addi	a3,a3,1156 # ffffffffc0205c50 <commands+0xc38>
ffffffffc02017d4:	00004617          	auipc	a2,0x4
ffffffffc02017d8:	1dc60613          	addi	a2,a2,476 # ffffffffc02059b0 <commands+0x998>
ffffffffc02017dc:	18800593          	li	a1,392
ffffffffc02017e0:	00004517          	auipc	a0,0x4
ffffffffc02017e4:	0a050513          	addi	a0,a0,160 # ffffffffc0205880 <commands+0x868>
ffffffffc02017e8:	9edfe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02017ec:	00004697          	auipc	a3,0x4
ffffffffc02017f0:	41c68693          	addi	a3,a3,1052 # ffffffffc0205c08 <commands+0xbf0>
ffffffffc02017f4:	00004617          	auipc	a2,0x4
ffffffffc02017f8:	1bc60613          	addi	a2,a2,444 # ffffffffc02059b0 <commands+0x998>
ffffffffc02017fc:	18600593          	li	a1,390
ffffffffc0201800:	00004517          	auipc	a0,0x4
ffffffffc0201804:	08050513          	addi	a0,a0,128 # ffffffffc0205880 <commands+0x868>
ffffffffc0201808:	9cdfe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc020180c:	00004697          	auipc	a3,0x4
ffffffffc0201810:	42c68693          	addi	a3,a3,1068 # ffffffffc0205c38 <commands+0xc20>
ffffffffc0201814:	00004617          	auipc	a2,0x4
ffffffffc0201818:	19c60613          	addi	a2,a2,412 # ffffffffc02059b0 <commands+0x998>
ffffffffc020181c:	18500593          	li	a1,389
ffffffffc0201820:	00004517          	auipc	a0,0x4
ffffffffc0201824:	06050513          	addi	a0,a0,96 # ffffffffc0205880 <commands+0x868>
ffffffffc0201828:	9adfe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(page_ref(p) == 2);
ffffffffc020182c:	00004697          	auipc	a3,0x4
ffffffffc0201830:	58c68693          	addi	a3,a3,1420 # ffffffffc0205db8 <commands+0xda0>
ffffffffc0201834:	00004617          	auipc	a2,0x4
ffffffffc0201838:	17c60613          	addi	a2,a2,380 # ffffffffc02059b0 <commands+0x998>
ffffffffc020183c:	1a800593          	li	a1,424
ffffffffc0201840:	00004517          	auipc	a0,0x4
ffffffffc0201844:	04050513          	addi	a0,a0,64 # ffffffffc0205880 <commands+0x868>
ffffffffc0201848:	98dfe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc020184c:	00004697          	auipc	a3,0x4
ffffffffc0201850:	52c68693          	addi	a3,a3,1324 # ffffffffc0205d78 <commands+0xd60>
ffffffffc0201854:	00004617          	auipc	a2,0x4
ffffffffc0201858:	15c60613          	addi	a2,a2,348 # ffffffffc02059b0 <commands+0x998>
ffffffffc020185c:	1a700593          	li	a1,423
ffffffffc0201860:	00004517          	auipc	a0,0x4
ffffffffc0201864:	02050513          	addi	a0,a0,32 # ffffffffc0205880 <commands+0x868>
ffffffffc0201868:	96dfe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(page_ref(p) == 1);
ffffffffc020186c:	00004697          	auipc	a3,0x4
ffffffffc0201870:	4f468693          	addi	a3,a3,1268 # ffffffffc0205d60 <commands+0xd48>
ffffffffc0201874:	00004617          	auipc	a2,0x4
ffffffffc0201878:	13c60613          	addi	a2,a2,316 # ffffffffc02059b0 <commands+0x998>
ffffffffc020187c:	1a600593          	li	a1,422
ffffffffc0201880:	00004517          	auipc	a0,0x4
ffffffffc0201884:	00050513          	mv	a0,a0
ffffffffc0201888:	94dfe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc020188c:	86be                	mv	a3,a5
ffffffffc020188e:	00004617          	auipc	a2,0x4
ffffffffc0201892:	fca60613          	addi	a2,a2,-54 # ffffffffc0205858 <commands+0x840>
ffffffffc0201896:	16d00593          	li	a1,365
ffffffffc020189a:	00004517          	auipc	a0,0x4
ffffffffc020189e:	fe650513          	addi	a0,a0,-26 # ffffffffc0205880 <commands+0x868>
ffffffffc02018a2:	933fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02018a6:	00004617          	auipc	a2,0x4
ffffffffc02018aa:	08a60613          	addi	a2,a2,138 # ffffffffc0205930 <commands+0x918>
ffffffffc02018ae:	07f00593          	li	a1,127
ffffffffc02018b2:	00004517          	auipc	a0,0x4
ffffffffc02018b6:	fce50513          	addi	a0,a0,-50 # ffffffffc0205880 <commands+0x868>
ffffffffc02018ba:	91bfe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc02018be:	00004697          	auipc	a3,0x4
ffffffffc02018c2:	52a68693          	addi	a3,a3,1322 # ffffffffc0205de8 <commands+0xdd0>
ffffffffc02018c6:	00004617          	auipc	a2,0x4
ffffffffc02018ca:	0ea60613          	addi	a2,a2,234 # ffffffffc02059b0 <commands+0x998>
ffffffffc02018ce:	1ac00593          	li	a1,428
ffffffffc02018d2:	00004517          	auipc	a0,0x4
ffffffffc02018d6:	fae50513          	addi	a0,a0,-82 # ffffffffc0205880 <commands+0x868>
ffffffffc02018da:	8fbfe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc02018de:	00004697          	auipc	a3,0x4
ffffffffc02018e2:	39a68693          	addi	a3,a3,922 # ffffffffc0205c78 <commands+0xc60>
ffffffffc02018e6:	00004617          	auipc	a2,0x4
ffffffffc02018ea:	0ca60613          	addi	a2,a2,202 # ffffffffc02059b0 <commands+0x998>
ffffffffc02018ee:	1b800593          	li	a1,440
ffffffffc02018f2:	00004517          	auipc	a0,0x4
ffffffffc02018f6:	f8e50513          	addi	a0,a0,-114 # ffffffffc0205880 <commands+0x868>
ffffffffc02018fa:	8dbfe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc02018fe:	00004697          	auipc	a3,0x4
ffffffffc0201902:	1ca68693          	addi	a3,a3,458 # ffffffffc0205ac8 <commands+0xab0>
ffffffffc0201906:	00004617          	auipc	a2,0x4
ffffffffc020190a:	0aa60613          	addi	a2,a2,170 # ffffffffc02059b0 <commands+0x998>
ffffffffc020190e:	16b00593          	li	a1,363
ffffffffc0201912:	00004517          	auipc	a0,0x4
ffffffffc0201916:	f6e50513          	addi	a0,a0,-146 # ffffffffc0205880 <commands+0x868>
ffffffffc020191a:	8bbfe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc020191e:	00004697          	auipc	a3,0x4
ffffffffc0201922:	19268693          	addi	a3,a3,402 # ffffffffc0205ab0 <commands+0xa98>
ffffffffc0201926:	00004617          	auipc	a2,0x4
ffffffffc020192a:	08a60613          	addi	a2,a2,138 # ffffffffc02059b0 <commands+0x998>
ffffffffc020192e:	16a00593          	li	a1,362
ffffffffc0201932:	00004517          	auipc	a0,0x4
ffffffffc0201936:	f4e50513          	addi	a0,a0,-178 # ffffffffc0205880 <commands+0x868>
ffffffffc020193a:	89bfe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc020193e:	00004697          	auipc	a3,0x4
ffffffffc0201942:	0c268693          	addi	a3,a3,194 # ffffffffc0205a00 <commands+0x9e8>
ffffffffc0201946:	00004617          	auipc	a2,0x4
ffffffffc020194a:	06a60613          	addi	a2,a2,106 # ffffffffc02059b0 <commands+0x998>
ffffffffc020194e:	16200593          	li	a1,354
ffffffffc0201952:	00004517          	auipc	a0,0x4
ffffffffc0201956:	f2e50513          	addi	a0,a0,-210 # ffffffffc0205880 <commands+0x868>
ffffffffc020195a:	87bfe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc020195e:	00004697          	auipc	a3,0x4
ffffffffc0201962:	0fa68693          	addi	a3,a3,250 # ffffffffc0205a58 <commands+0xa40>
ffffffffc0201966:	00004617          	auipc	a2,0x4
ffffffffc020196a:	04a60613          	addi	a2,a2,74 # ffffffffc02059b0 <commands+0x998>
ffffffffc020196e:	16900593          	li	a1,361
ffffffffc0201972:	00004517          	auipc	a0,0x4
ffffffffc0201976:	f0e50513          	addi	a0,a0,-242 # ffffffffc0205880 <commands+0x868>
ffffffffc020197a:	85bfe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc020197e:	00004697          	auipc	a3,0x4
ffffffffc0201982:	0aa68693          	addi	a3,a3,170 # ffffffffc0205a28 <commands+0xa10>
ffffffffc0201986:	00004617          	auipc	a2,0x4
ffffffffc020198a:	02a60613          	addi	a2,a2,42 # ffffffffc02059b0 <commands+0x998>
ffffffffc020198e:	16600593          	li	a1,358
ffffffffc0201992:	00004517          	auipc	a0,0x4
ffffffffc0201996:	eee50513          	addi	a0,a0,-274 # ffffffffc0205880 <commands+0x868>
ffffffffc020199a:	83bfe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc020199e:	00004697          	auipc	a3,0x4
ffffffffc02019a2:	26a68693          	addi	a3,a3,618 # ffffffffc0205c08 <commands+0xbf0>
ffffffffc02019a6:	00004617          	auipc	a2,0x4
ffffffffc02019aa:	00a60613          	addi	a2,a2,10 # ffffffffc02059b0 <commands+0x998>
ffffffffc02019ae:	18200593          	li	a1,386
ffffffffc02019b2:	00004517          	auipc	a0,0x4
ffffffffc02019b6:	ece50513          	addi	a0,a0,-306 # ffffffffc0205880 <commands+0x868>
ffffffffc02019ba:	81bfe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc02019be:	00004697          	auipc	a3,0x4
ffffffffc02019c2:	10a68693          	addi	a3,a3,266 # ffffffffc0205ac8 <commands+0xab0>
ffffffffc02019c6:	00004617          	auipc	a2,0x4
ffffffffc02019ca:	fea60613          	addi	a2,a2,-22 # ffffffffc02059b0 <commands+0x998>
ffffffffc02019ce:	18100593          	li	a1,385
ffffffffc02019d2:	00004517          	auipc	a0,0x4
ffffffffc02019d6:	eae50513          	addi	a0,a0,-338 # ffffffffc0205880 <commands+0x868>
ffffffffc02019da:	ffafe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc02019de:	00004697          	auipc	a3,0x4
ffffffffc02019e2:	24268693          	addi	a3,a3,578 # ffffffffc0205c20 <commands+0xc08>
ffffffffc02019e6:	00004617          	auipc	a2,0x4
ffffffffc02019ea:	fca60613          	addi	a2,a2,-54 # ffffffffc02059b0 <commands+0x998>
ffffffffc02019ee:	17e00593          	li	a1,382
ffffffffc02019f2:	00004517          	auipc	a0,0x4
ffffffffc02019f6:	e8e50513          	addi	a0,a0,-370 # ffffffffc0205880 <commands+0x868>
ffffffffc02019fa:	fdafe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc02019fe:	00004697          	auipc	a3,0x4
ffffffffc0201a02:	42268693          	addi	a3,a3,1058 # ffffffffc0205e20 <commands+0xe08>
ffffffffc0201a06:	00004617          	auipc	a2,0x4
ffffffffc0201a0a:	faa60613          	addi	a2,a2,-86 # ffffffffc02059b0 <commands+0x998>
ffffffffc0201a0e:	1af00593          	li	a1,431
ffffffffc0201a12:	00004517          	auipc	a0,0x4
ffffffffc0201a16:	e6e50513          	addi	a0,a0,-402 # ffffffffc0205880 <commands+0x868>
ffffffffc0201a1a:	fbafe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0201a1e:	00004697          	auipc	a3,0x4
ffffffffc0201a22:	25a68693          	addi	a3,a3,602 # ffffffffc0205c78 <commands+0xc60>
ffffffffc0201a26:	00004617          	auipc	a2,0x4
ffffffffc0201a2a:	f8a60613          	addi	a2,a2,-118 # ffffffffc02059b0 <commands+0x998>
ffffffffc0201a2e:	19000593          	li	a1,400
ffffffffc0201a32:	00004517          	auipc	a0,0x4
ffffffffc0201a36:	e4e50513          	addi	a0,a0,-434 # ffffffffc0205880 <commands+0x868>
ffffffffc0201a3a:	f9afe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc0201a3e:	00004697          	auipc	a3,0x4
ffffffffc0201a42:	2d268693          	addi	a3,a3,722 # ffffffffc0205d10 <commands+0xcf8>
ffffffffc0201a46:	00004617          	auipc	a2,0x4
ffffffffc0201a4a:	f6a60613          	addi	a2,a2,-150 # ffffffffc02059b0 <commands+0x998>
ffffffffc0201a4e:	1a100593          	li	a1,417
ffffffffc0201a52:	00004517          	auipc	a0,0x4
ffffffffc0201a56:	e2e50513          	addi	a0,a0,-466 # ffffffffc0205880 <commands+0x868>
ffffffffc0201a5a:	f7afe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0201a5e:	00004697          	auipc	a3,0x4
ffffffffc0201a62:	f3268693          	addi	a3,a3,-206 # ffffffffc0205990 <commands+0x978>
ffffffffc0201a66:	00004617          	auipc	a2,0x4
ffffffffc0201a6a:	f4a60613          	addi	a2,a2,-182 # ffffffffc02059b0 <commands+0x998>
ffffffffc0201a6e:	16000593          	li	a1,352
ffffffffc0201a72:	00004517          	auipc	a0,0x4
ffffffffc0201a76:	e0e50513          	addi	a0,a0,-498 # ffffffffc0205880 <commands+0x868>
ffffffffc0201a7a:	f5afe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0201a7e:	00004617          	auipc	a2,0x4
ffffffffc0201a82:	eb260613          	addi	a2,a2,-334 # ffffffffc0205930 <commands+0x918>
ffffffffc0201a86:	0c300593          	li	a1,195
ffffffffc0201a8a:	00004517          	auipc	a0,0x4
ffffffffc0201a8e:	df650513          	addi	a0,a0,-522 # ffffffffc0205880 <commands+0x868>
ffffffffc0201a92:	f42fe0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc0201a96 <tlb_invalidate>:
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201a96:	12058073          	sfence.vma	a1
}
ffffffffc0201a9a:	8082                	ret

ffffffffc0201a9c <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0201a9c:	7179                	addi	sp,sp,-48
ffffffffc0201a9e:	e84a                	sd	s2,16(sp)
ffffffffc0201aa0:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc0201aa2:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0201aa4:	f022                	sd	s0,32(sp)
ffffffffc0201aa6:	ec26                	sd	s1,24(sp)
ffffffffc0201aa8:	e44e                	sd	s3,8(sp)
ffffffffc0201aaa:	f406                	sd	ra,40(sp)
ffffffffc0201aac:	84ae                	mv	s1,a1
ffffffffc0201aae:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc0201ab0:	8f6ff0ef          	jal	ra,ffffffffc0200ba6 <alloc_pages>
ffffffffc0201ab4:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc0201ab6:	cd19                	beqz	a0,ffffffffc0201ad4 <pgdir_alloc_page+0x38>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc0201ab8:	85aa                	mv	a1,a0
ffffffffc0201aba:	86ce                	mv	a3,s3
ffffffffc0201abc:	8626                	mv	a2,s1
ffffffffc0201abe:	854a                	mv	a0,s2
ffffffffc0201ac0:	c92ff0ef          	jal	ra,ffffffffc0200f52 <page_insert>
ffffffffc0201ac4:	ed39                	bnez	a0,ffffffffc0201b22 <pgdir_alloc_page+0x86>
        if (swap_init_ok) {
ffffffffc0201ac6:	00014797          	auipc	a5,0x14
ffffffffc0201aca:	9da78793          	addi	a5,a5,-1574 # ffffffffc02154a0 <swap_init_ok>
ffffffffc0201ace:	439c                	lw	a5,0(a5)
ffffffffc0201ad0:	2781                	sext.w	a5,a5
ffffffffc0201ad2:	eb89                	bnez	a5,ffffffffc0201ae4 <pgdir_alloc_page+0x48>
}
ffffffffc0201ad4:	8522                	mv	a0,s0
ffffffffc0201ad6:	70a2                	ld	ra,40(sp)
ffffffffc0201ad8:	7402                	ld	s0,32(sp)
ffffffffc0201ada:	64e2                	ld	s1,24(sp)
ffffffffc0201adc:	6942                	ld	s2,16(sp)
ffffffffc0201ade:	69a2                	ld	s3,8(sp)
ffffffffc0201ae0:	6145                	addi	sp,sp,48
ffffffffc0201ae2:	8082                	ret
            swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0201ae4:	00014797          	auipc	a5,0x14
ffffffffc0201ae8:	a1478793          	addi	a5,a5,-1516 # ffffffffc02154f8 <check_mm_struct>
ffffffffc0201aec:	6388                	ld	a0,0(a5)
ffffffffc0201aee:	4681                	li	a3,0
ffffffffc0201af0:	8622                	mv	a2,s0
ffffffffc0201af2:	85a6                	mv	a1,s1
ffffffffc0201af4:	7e5000ef          	jal	ra,ffffffffc0202ad8 <swap_map_swappable>
            assert(page_ref(page) == 1);
ffffffffc0201af8:	4018                	lw	a4,0(s0)
            page->pra_vaddr = la;
ffffffffc0201afa:	fc04                	sd	s1,56(s0)
            assert(page_ref(page) == 1);
ffffffffc0201afc:	4785                	li	a5,1
ffffffffc0201afe:	fcf70be3          	beq	a4,a5,ffffffffc0201ad4 <pgdir_alloc_page+0x38>
ffffffffc0201b02:	00004697          	auipc	a3,0x4
ffffffffc0201b06:	dbe68693          	addi	a3,a3,-578 # ffffffffc02058c0 <commands+0x8a8>
ffffffffc0201b0a:	00004617          	auipc	a2,0x4
ffffffffc0201b0e:	ea660613          	addi	a2,a2,-346 # ffffffffc02059b0 <commands+0x998>
ffffffffc0201b12:	14800593          	li	a1,328
ffffffffc0201b16:	00004517          	auipc	a0,0x4
ffffffffc0201b1a:	d6a50513          	addi	a0,a0,-662 # ffffffffc0205880 <commands+0x868>
ffffffffc0201b1e:	eb6fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
            free_page(page);
ffffffffc0201b22:	8522                	mv	a0,s0
ffffffffc0201b24:	4585                	li	a1,1
ffffffffc0201b26:	908ff0ef          	jal	ra,ffffffffc0200c2e <free_pages>
            return NULL;
ffffffffc0201b2a:	4401                	li	s0,0
ffffffffc0201b2c:	b765                	j	ffffffffc0201ad4 <pgdir_alloc_page+0x38>

ffffffffc0201b2e <check_vma_overlap.isra.0.part.1>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0201b2e:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc0201b30:	00004697          	auipc	a3,0x4
ffffffffc0201b34:	33868693          	addi	a3,a3,824 # ffffffffc0205e68 <commands+0xe50>
ffffffffc0201b38:	00004617          	auipc	a2,0x4
ffffffffc0201b3c:	e7860613          	addi	a2,a2,-392 # ffffffffc02059b0 <commands+0x998>
ffffffffc0201b40:	07e00593          	li	a1,126
ffffffffc0201b44:	00004517          	auipc	a0,0x4
ffffffffc0201b48:	34450513          	addi	a0,a0,836 # ffffffffc0205e88 <commands+0xe70>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0201b4c:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc0201b4e:	e86fe0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc0201b52 <mm_create>:
mm_create(void) {
ffffffffc0201b52:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0201b54:	03000513          	li	a0,48
mm_create(void) {
ffffffffc0201b58:	e022                	sd	s0,0(sp)
ffffffffc0201b5a:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0201b5c:	3b6010ef          	jal	ra,ffffffffc0202f12 <kmalloc>
ffffffffc0201b60:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0201b62:	c115                	beqz	a0,ffffffffc0201b86 <mm_create+0x34>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0201b64:	00014797          	auipc	a5,0x14
ffffffffc0201b68:	93c78793          	addi	a5,a5,-1732 # ffffffffc02154a0 <swap_init_ok>
ffffffffc0201b6c:	439c                	lw	a5,0(a5)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0201b6e:	e408                	sd	a0,8(s0)
ffffffffc0201b70:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc0201b72:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0201b76:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0201b7a:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0201b7e:	2781                	sext.w	a5,a5
ffffffffc0201b80:	eb81                	bnez	a5,ffffffffc0201b90 <mm_create+0x3e>
        else mm->sm_priv = NULL;
ffffffffc0201b82:	02053423          	sd	zero,40(a0)
}
ffffffffc0201b86:	8522                	mv	a0,s0
ffffffffc0201b88:	60a2                	ld	ra,8(sp)
ffffffffc0201b8a:	6402                	ld	s0,0(sp)
ffffffffc0201b8c:	0141                	addi	sp,sp,16
ffffffffc0201b8e:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0201b90:	739000ef          	jal	ra,ffffffffc0202ac8 <swap_init_mm>
}
ffffffffc0201b94:	8522                	mv	a0,s0
ffffffffc0201b96:	60a2                	ld	ra,8(sp)
ffffffffc0201b98:	6402                	ld	s0,0(sp)
ffffffffc0201b9a:	0141                	addi	sp,sp,16
ffffffffc0201b9c:	8082                	ret

ffffffffc0201b9e <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc0201b9e:	1101                	addi	sp,sp,-32
ffffffffc0201ba0:	e04a                	sd	s2,0(sp)
ffffffffc0201ba2:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201ba4:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc0201ba8:	e822                	sd	s0,16(sp)
ffffffffc0201baa:	e426                	sd	s1,8(sp)
ffffffffc0201bac:	ec06                	sd	ra,24(sp)
ffffffffc0201bae:	84ae                	mv	s1,a1
ffffffffc0201bb0:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201bb2:	360010ef          	jal	ra,ffffffffc0202f12 <kmalloc>
    if (vma != NULL) {
ffffffffc0201bb6:	c509                	beqz	a0,ffffffffc0201bc0 <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc0201bb8:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc0201bbc:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0201bbe:	cd00                	sw	s0,24(a0)
}
ffffffffc0201bc0:	60e2                	ld	ra,24(sp)
ffffffffc0201bc2:	6442                	ld	s0,16(sp)
ffffffffc0201bc4:	64a2                	ld	s1,8(sp)
ffffffffc0201bc6:	6902                	ld	s2,0(sp)
ffffffffc0201bc8:	6105                	addi	sp,sp,32
ffffffffc0201bca:	8082                	ret

ffffffffc0201bcc <find_vma>:
    if (mm != NULL) {
ffffffffc0201bcc:	c51d                	beqz	a0,ffffffffc0201bfa <find_vma+0x2e>
        vma = mm->mmap_cache;
ffffffffc0201bce:	691c                	ld	a5,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0201bd0:	c781                	beqz	a5,ffffffffc0201bd8 <find_vma+0xc>
ffffffffc0201bd2:	6798                	ld	a4,8(a5)
ffffffffc0201bd4:	02e5f663          	bgeu	a1,a4,ffffffffc0201c00 <find_vma+0x34>
                list_entry_t *list = &(mm->mmap_list), *le = list;
ffffffffc0201bd8:	87aa                	mv	a5,a0
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0201bda:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc0201bdc:	00f50f63          	beq	a0,a5,ffffffffc0201bfa <find_vma+0x2e>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc0201be0:	fe87b703          	ld	a4,-24(a5)
ffffffffc0201be4:	fee5ebe3          	bltu	a1,a4,ffffffffc0201bda <find_vma+0xe>
ffffffffc0201be8:	ff07b703          	ld	a4,-16(a5)
ffffffffc0201bec:	fee5f7e3          	bgeu	a1,a4,ffffffffc0201bda <find_vma+0xe>
                    vma = le2vma(le, list_link);
ffffffffc0201bf0:	1781                	addi	a5,a5,-32
        if (vma != NULL) {
ffffffffc0201bf2:	c781                	beqz	a5,ffffffffc0201bfa <find_vma+0x2e>
            mm->mmap_cache = vma;
ffffffffc0201bf4:	e91c                	sd	a5,16(a0)
}
ffffffffc0201bf6:	853e                	mv	a0,a5
ffffffffc0201bf8:	8082                	ret
    struct vma_struct *vma = NULL;
ffffffffc0201bfa:	4781                	li	a5,0
}
ffffffffc0201bfc:	853e                	mv	a0,a5
ffffffffc0201bfe:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0201c00:	6b98                	ld	a4,16(a5)
ffffffffc0201c02:	fce5fbe3          	bgeu	a1,a4,ffffffffc0201bd8 <find_vma+0xc>
            mm->mmap_cache = vma;
ffffffffc0201c06:	e91c                	sd	a5,16(a0)
    return vma;
ffffffffc0201c08:	b7fd                	j	ffffffffc0201bf6 <find_vma+0x2a>

ffffffffc0201c0a <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc0201c0a:	6590                	ld	a2,8(a1)
ffffffffc0201c0c:	0105b803          	ld	a6,16(a1)
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc0201c10:	1141                	addi	sp,sp,-16
ffffffffc0201c12:	e406                	sd	ra,8(sp)
ffffffffc0201c14:	872a                	mv	a4,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0201c16:	01066863          	bltu	a2,a6,ffffffffc0201c26 <insert_vma_struct+0x1c>
ffffffffc0201c1a:	a8b9                	j	ffffffffc0201c78 <insert_vma_struct+0x6e>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0201c1c:	fe87b683          	ld	a3,-24(a5)
ffffffffc0201c20:	04d66763          	bltu	a2,a3,ffffffffc0201c6e <insert_vma_struct+0x64>
ffffffffc0201c24:	873e                	mv	a4,a5
ffffffffc0201c26:	671c                	ld	a5,8(a4)
        while ((le = list_next(le)) != list) {
ffffffffc0201c28:	fef51ae3          	bne	a0,a5,ffffffffc0201c1c <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc0201c2c:	02a70463          	beq	a4,a0,ffffffffc0201c54 <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0201c30:	ff073683          	ld	a3,-16(a4) # 7fff0 <BASE_ADDRESS-0xffffffffc0180010>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0201c34:	fe873883          	ld	a7,-24(a4)
ffffffffc0201c38:	08d8f063          	bgeu	a7,a3,ffffffffc0201cb8 <insert_vma_struct+0xae>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0201c3c:	04d66e63          	bltu	a2,a3,ffffffffc0201c98 <insert_vma_struct+0x8e>
    }
    if (le_next != list) {
ffffffffc0201c40:	00f50a63          	beq	a0,a5,ffffffffc0201c54 <insert_vma_struct+0x4a>
ffffffffc0201c44:	fe87b683          	ld	a3,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc0201c48:	0506e863          	bltu	a3,a6,ffffffffc0201c98 <insert_vma_struct+0x8e>
    assert(next->vm_start < next->vm_end);
ffffffffc0201c4c:	ff07b603          	ld	a2,-16(a5)
ffffffffc0201c50:	02c6f263          	bgeu	a3,a2,ffffffffc0201c74 <insert_vma_struct+0x6a>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc0201c54:	5114                	lw	a3,32(a0)
    vma->vm_mm = mm;
ffffffffc0201c56:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc0201c58:	02058613          	addi	a2,a1,32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0201c5c:	e390                	sd	a2,0(a5)
ffffffffc0201c5e:	e710                	sd	a2,8(a4)
}
ffffffffc0201c60:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc0201c62:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc0201c64:	f198                	sd	a4,32(a1)
    mm->map_count ++;
ffffffffc0201c66:	2685                	addiw	a3,a3,1
ffffffffc0201c68:	d114                	sw	a3,32(a0)
}
ffffffffc0201c6a:	0141                	addi	sp,sp,16
ffffffffc0201c6c:	8082                	ret
    if (le_prev != list) {
ffffffffc0201c6e:	fca711e3          	bne	a4,a0,ffffffffc0201c30 <insert_vma_struct+0x26>
ffffffffc0201c72:	bfd9                	j	ffffffffc0201c48 <insert_vma_struct+0x3e>
ffffffffc0201c74:	ebbff0ef          	jal	ra,ffffffffc0201b2e <check_vma_overlap.isra.0.part.1>
    assert(vma->vm_start < vma->vm_end);
ffffffffc0201c78:	00004697          	auipc	a3,0x4
ffffffffc0201c7c:	2e068693          	addi	a3,a3,736 # ffffffffc0205f58 <commands+0xf40>
ffffffffc0201c80:	00004617          	auipc	a2,0x4
ffffffffc0201c84:	d3060613          	addi	a2,a2,-720 # ffffffffc02059b0 <commands+0x998>
ffffffffc0201c88:	08500593          	li	a1,133
ffffffffc0201c8c:	00004517          	auipc	a0,0x4
ffffffffc0201c90:	1fc50513          	addi	a0,a0,508 # ffffffffc0205e88 <commands+0xe70>
ffffffffc0201c94:	d40fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0201c98:	00004697          	auipc	a3,0x4
ffffffffc0201c9c:	30068693          	addi	a3,a3,768 # ffffffffc0205f98 <commands+0xf80>
ffffffffc0201ca0:	00004617          	auipc	a2,0x4
ffffffffc0201ca4:	d1060613          	addi	a2,a2,-752 # ffffffffc02059b0 <commands+0x998>
ffffffffc0201ca8:	07d00593          	li	a1,125
ffffffffc0201cac:	00004517          	auipc	a0,0x4
ffffffffc0201cb0:	1dc50513          	addi	a0,a0,476 # ffffffffc0205e88 <commands+0xe70>
ffffffffc0201cb4:	d20fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0201cb8:	00004697          	auipc	a3,0x4
ffffffffc0201cbc:	2c068693          	addi	a3,a3,704 # ffffffffc0205f78 <commands+0xf60>
ffffffffc0201cc0:	00004617          	auipc	a2,0x4
ffffffffc0201cc4:	cf060613          	addi	a2,a2,-784 # ffffffffc02059b0 <commands+0x998>
ffffffffc0201cc8:	07c00593          	li	a1,124
ffffffffc0201ccc:	00004517          	auipc	a0,0x4
ffffffffc0201cd0:	1bc50513          	addi	a0,a0,444 # ffffffffc0205e88 <commands+0xe70>
ffffffffc0201cd4:	d00fe0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc0201cd8 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
ffffffffc0201cd8:	1141                	addi	sp,sp,-16
ffffffffc0201cda:	e022                	sd	s0,0(sp)
ffffffffc0201cdc:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc0201cde:	6508                	ld	a0,8(a0)
ffffffffc0201ce0:	e406                	sd	ra,8(sp)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc0201ce2:	00a40c63          	beq	s0,a0,ffffffffc0201cfa <mm_destroy+0x22>
    __list_del(listelm->prev, listelm->next);
ffffffffc0201ce6:	6118                	ld	a4,0(a0)
ffffffffc0201ce8:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc0201cea:	1501                	addi	a0,a0,-32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0201cec:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0201cee:	e398                	sd	a4,0(a5)
ffffffffc0201cf0:	2de010ef          	jal	ra,ffffffffc0202fce <kfree>
    return listelm->next;
ffffffffc0201cf4:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0201cf6:	fea418e3          	bne	s0,a0,ffffffffc0201ce6 <mm_destroy+0xe>
    }
    kfree(mm); //kfree mm
ffffffffc0201cfa:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc0201cfc:	6402                	ld	s0,0(sp)
ffffffffc0201cfe:	60a2                	ld	ra,8(sp)
ffffffffc0201d00:	0141                	addi	sp,sp,16
    kfree(mm); //kfree mm
ffffffffc0201d02:	2cc0106f          	j	ffffffffc0202fce <kfree>

ffffffffc0201d06 <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc0201d06:	7139                	addi	sp,sp,-64
ffffffffc0201d08:	f822                	sd	s0,48(sp)
ffffffffc0201d0a:	f426                	sd	s1,40(sp)
ffffffffc0201d0c:	fc06                	sd	ra,56(sp)
ffffffffc0201d0e:	f04a                	sd	s2,32(sp)
ffffffffc0201d10:	ec4e                	sd	s3,24(sp)
ffffffffc0201d12:	e852                	sd	s4,16(sp)
ffffffffc0201d14:	e456                	sd	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
}

static void
check_vma_struct(void) {
    struct mm_struct *mm = mm_create();
ffffffffc0201d16:	e3dff0ef          	jal	ra,ffffffffc0201b52 <mm_create>
    assert(mm != NULL);
ffffffffc0201d1a:	842a                	mv	s0,a0
ffffffffc0201d1c:	03200493          	li	s1,50
ffffffffc0201d20:	e919                	bnez	a0,ffffffffc0201d36 <vmm_init+0x30>
ffffffffc0201d22:	a989                	j	ffffffffc0202174 <vmm_init+0x46e>
        vma->vm_start = vm_start;
ffffffffc0201d24:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc0201d26:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0201d28:	00052c23          	sw	zero,24(a0)

    int i;
    for (i = step1; i >= 1; i --) {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0201d2c:	14ed                	addi	s1,s1,-5
ffffffffc0201d2e:	8522                	mv	a0,s0
ffffffffc0201d30:	edbff0ef          	jal	ra,ffffffffc0201c0a <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc0201d34:	c88d                	beqz	s1,ffffffffc0201d66 <vmm_init+0x60>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201d36:	03000513          	li	a0,48
ffffffffc0201d3a:	1d8010ef          	jal	ra,ffffffffc0202f12 <kmalloc>
ffffffffc0201d3e:	85aa                	mv	a1,a0
ffffffffc0201d40:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc0201d44:	f165                	bnez	a0,ffffffffc0201d24 <vmm_init+0x1e>
        assert(vma != NULL);
ffffffffc0201d46:	00004697          	auipc	a3,0x4
ffffffffc0201d4a:	49a68693          	addi	a3,a3,1178 # ffffffffc02061e0 <commands+0x11c8>
ffffffffc0201d4e:	00004617          	auipc	a2,0x4
ffffffffc0201d52:	c6260613          	addi	a2,a2,-926 # ffffffffc02059b0 <commands+0x998>
ffffffffc0201d56:	0c900593          	li	a1,201
ffffffffc0201d5a:	00004517          	auipc	a0,0x4
ffffffffc0201d5e:	12e50513          	addi	a0,a0,302 # ffffffffc0205e88 <commands+0xe70>
ffffffffc0201d62:	c72fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    for (i = step1; i >= 1; i --) {
ffffffffc0201d66:	03700493          	li	s1,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0201d6a:	1f900913          	li	s2,505
ffffffffc0201d6e:	a819                	j	ffffffffc0201d84 <vmm_init+0x7e>
        vma->vm_start = vm_start;
ffffffffc0201d70:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc0201d72:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0201d74:	00052c23          	sw	zero,24(a0)
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0201d78:	0495                	addi	s1,s1,5
ffffffffc0201d7a:	8522                	mv	a0,s0
ffffffffc0201d7c:	e8fff0ef          	jal	ra,ffffffffc0201c0a <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0201d80:	03248a63          	beq	s1,s2,ffffffffc0201db4 <vmm_init+0xae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201d84:	03000513          	li	a0,48
ffffffffc0201d88:	18a010ef          	jal	ra,ffffffffc0202f12 <kmalloc>
ffffffffc0201d8c:	85aa                	mv	a1,a0
ffffffffc0201d8e:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc0201d92:	fd79                	bnez	a0,ffffffffc0201d70 <vmm_init+0x6a>
        assert(vma != NULL);
ffffffffc0201d94:	00004697          	auipc	a3,0x4
ffffffffc0201d98:	44c68693          	addi	a3,a3,1100 # ffffffffc02061e0 <commands+0x11c8>
ffffffffc0201d9c:	00004617          	auipc	a2,0x4
ffffffffc0201da0:	c1460613          	addi	a2,a2,-1004 # ffffffffc02059b0 <commands+0x998>
ffffffffc0201da4:	0cf00593          	li	a1,207
ffffffffc0201da8:	00004517          	auipc	a0,0x4
ffffffffc0201dac:	0e050513          	addi	a0,a0,224 # ffffffffc0205e88 <commands+0xe70>
ffffffffc0201db0:	c24fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
ffffffffc0201db4:	6418                	ld	a4,8(s0)
ffffffffc0201db6:	479d                	li	a5,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc0201db8:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc0201dbc:	2ee40063          	beq	s0,a4,ffffffffc020209c <vmm_init+0x396>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0201dc0:	fe873603          	ld	a2,-24(a4)
ffffffffc0201dc4:	ffe78693          	addi	a3,a5,-2
ffffffffc0201dc8:	24d61a63          	bne	a2,a3,ffffffffc020201c <vmm_init+0x316>
ffffffffc0201dcc:	ff073683          	ld	a3,-16(a4)
ffffffffc0201dd0:	24f69663          	bne	a3,a5,ffffffffc020201c <vmm_init+0x316>
ffffffffc0201dd4:	0795                	addi	a5,a5,5
ffffffffc0201dd6:	6718                	ld	a4,8(a4)
    for (i = 1; i <= step2; i ++) {
ffffffffc0201dd8:	feb792e3          	bne	a5,a1,ffffffffc0201dbc <vmm_init+0xb6>
ffffffffc0201ddc:	491d                	li	s2,7
ffffffffc0201dde:	4495                	li	s1,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0201de0:	1f900a93          	li	s5,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0201de4:	85a6                	mv	a1,s1
ffffffffc0201de6:	8522                	mv	a0,s0
ffffffffc0201de8:	de5ff0ef          	jal	ra,ffffffffc0201bcc <find_vma>
ffffffffc0201dec:	8a2a                	mv	s4,a0
        assert(vma1 != NULL);
ffffffffc0201dee:	30050763          	beqz	a0,ffffffffc02020fc <vmm_init+0x3f6>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc0201df2:	00148593          	addi	a1,s1,1
ffffffffc0201df6:	8522                	mv	a0,s0
ffffffffc0201df8:	dd5ff0ef          	jal	ra,ffffffffc0201bcc <find_vma>
ffffffffc0201dfc:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc0201dfe:	2c050f63          	beqz	a0,ffffffffc02020dc <vmm_init+0x3d6>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc0201e02:	85ca                	mv	a1,s2
ffffffffc0201e04:	8522                	mv	a0,s0
ffffffffc0201e06:	dc7ff0ef          	jal	ra,ffffffffc0201bcc <find_vma>
        assert(vma3 == NULL);
ffffffffc0201e0a:	2a051963          	bnez	a0,ffffffffc02020bc <vmm_init+0x3b6>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc0201e0e:	00348593          	addi	a1,s1,3
ffffffffc0201e12:	8522                	mv	a0,s0
ffffffffc0201e14:	db9ff0ef          	jal	ra,ffffffffc0201bcc <find_vma>
        assert(vma4 == NULL);
ffffffffc0201e18:	32051263          	bnez	a0,ffffffffc020213c <vmm_init+0x436>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc0201e1c:	00448593          	addi	a1,s1,4
ffffffffc0201e20:	8522                	mv	a0,s0
ffffffffc0201e22:	dabff0ef          	jal	ra,ffffffffc0201bcc <find_vma>
        assert(vma5 == NULL);
ffffffffc0201e26:	2e051b63          	bnez	a0,ffffffffc020211c <vmm_init+0x416>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0201e2a:	008a3783          	ld	a5,8(s4)
ffffffffc0201e2e:	20979763          	bne	a5,s1,ffffffffc020203c <vmm_init+0x336>
ffffffffc0201e32:	010a3783          	ld	a5,16(s4)
ffffffffc0201e36:	21279363          	bne	a5,s2,ffffffffc020203c <vmm_init+0x336>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0201e3a:	0089b783          	ld	a5,8(s3) # fffffffffff80008 <end+0x3fd6aa08>
ffffffffc0201e3e:	20979f63          	bne	a5,s1,ffffffffc020205c <vmm_init+0x356>
ffffffffc0201e42:	0109b783          	ld	a5,16(s3)
ffffffffc0201e46:	21279b63          	bne	a5,s2,ffffffffc020205c <vmm_init+0x356>
ffffffffc0201e4a:	0495                	addi	s1,s1,5
ffffffffc0201e4c:	0915                	addi	s2,s2,5
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0201e4e:	f9549be3          	bne	s1,s5,ffffffffc0201de4 <vmm_init+0xde>
ffffffffc0201e52:	4491                	li	s1,4
    }

    for (i =4; i>=0; i--) {
ffffffffc0201e54:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc0201e56:	85a6                	mv	a1,s1
ffffffffc0201e58:	8522                	mv	a0,s0
ffffffffc0201e5a:	d73ff0ef          	jal	ra,ffffffffc0201bcc <find_vma>
ffffffffc0201e5e:	0004859b          	sext.w	a1,s1
        if (vma_below_5 != NULL ) {
ffffffffc0201e62:	c90d                	beqz	a0,ffffffffc0201e94 <vmm_init+0x18e>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc0201e64:	6914                	ld	a3,16(a0)
ffffffffc0201e66:	6510                	ld	a2,8(a0)
ffffffffc0201e68:	00004517          	auipc	a0,0x4
ffffffffc0201e6c:	26050513          	addi	a0,a0,608 # ffffffffc02060c8 <commands+0x10b0>
ffffffffc0201e70:	a60fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc0201e74:	00004697          	auipc	a3,0x4
ffffffffc0201e78:	27c68693          	addi	a3,a3,636 # ffffffffc02060f0 <commands+0x10d8>
ffffffffc0201e7c:	00004617          	auipc	a2,0x4
ffffffffc0201e80:	b3460613          	addi	a2,a2,-1228 # ffffffffc02059b0 <commands+0x998>
ffffffffc0201e84:	0f100593          	li	a1,241
ffffffffc0201e88:	00004517          	auipc	a0,0x4
ffffffffc0201e8c:	00050513          	mv	a0,a0
ffffffffc0201e90:	b44fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
ffffffffc0201e94:	14fd                	addi	s1,s1,-1
    for (i =4; i>=0; i--) {
ffffffffc0201e96:	fd2490e3          	bne	s1,s2,ffffffffc0201e56 <vmm_init+0x150>
    }

    mm_destroy(mm);
ffffffffc0201e9a:	8522                	mv	a0,s0
ffffffffc0201e9c:	e3dff0ef          	jal	ra,ffffffffc0201cd8 <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0201ea0:	00004517          	auipc	a0,0x4
ffffffffc0201ea4:	26850513          	addi	a0,a0,616 # ffffffffc0206108 <commands+0x10f0>
ffffffffc0201ea8:	a28fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0201eac:	dc9fe0ef          	jal	ra,ffffffffc0200c74 <nr_free_pages>
ffffffffc0201eb0:	89aa                	mv	s3,a0

    check_mm_struct = mm_create();
ffffffffc0201eb2:	ca1ff0ef          	jal	ra,ffffffffc0201b52 <mm_create>
ffffffffc0201eb6:	00013797          	auipc	a5,0x13
ffffffffc0201eba:	64a7b123          	sd	a0,1602(a5) # ffffffffc02154f8 <check_mm_struct>
ffffffffc0201ebe:	84aa                	mv	s1,a0
    assert(check_mm_struct != NULL);
ffffffffc0201ec0:	36050663          	beqz	a0,ffffffffc020222c <vmm_init+0x526>

    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0201ec4:	00013797          	auipc	a5,0x13
ffffffffc0201ec8:	5bc78793          	addi	a5,a5,1468 # ffffffffc0215480 <boot_pgdir>
ffffffffc0201ecc:	0007b903          	ld	s2,0(a5)
    assert(pgdir[0] == 0);
ffffffffc0201ed0:	00093783          	ld	a5,0(s2)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0201ed4:	01253c23          	sd	s2,24(a0)
    assert(pgdir[0] == 0);
ffffffffc0201ed8:	2c079e63          	bnez	a5,ffffffffc02021b4 <vmm_init+0x4ae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201edc:	03000513          	li	a0,48
ffffffffc0201ee0:	032010ef          	jal	ra,ffffffffc0202f12 <kmalloc>
ffffffffc0201ee4:	842a                	mv	s0,a0
    if (vma != NULL) {
ffffffffc0201ee6:	18050b63          	beqz	a0,ffffffffc020207c <vmm_init+0x376>
        vma->vm_end = vm_end;
ffffffffc0201eea:	002007b7          	lui	a5,0x200
ffffffffc0201eee:	e81c                	sd	a5,16(s0)
        vma->vm_flags = vm_flags;
ffffffffc0201ef0:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc0201ef2:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc0201ef4:	cc1c                	sw	a5,24(s0)
    insert_vma_struct(mm, vma);
ffffffffc0201ef6:	8526                	mv	a0,s1
        vma->vm_start = vm_start;
ffffffffc0201ef8:	00043423          	sd	zero,8(s0)
    insert_vma_struct(mm, vma);
ffffffffc0201efc:	d0fff0ef          	jal	ra,ffffffffc0201c0a <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc0201f00:	10000593          	li	a1,256
ffffffffc0201f04:	8526                	mv	a0,s1
ffffffffc0201f06:	cc7ff0ef          	jal	ra,ffffffffc0201bcc <find_vma>
ffffffffc0201f0a:	10000793          	li	a5,256

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
ffffffffc0201f0e:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc0201f12:	2ca41163          	bne	s0,a0,ffffffffc02021d4 <vmm_init+0x4ce>
        *(char *)(addr + i) = i;
ffffffffc0201f16:	00f78023          	sb	a5,0(a5) # 200000 <BASE_ADDRESS-0xffffffffc0000000>
        sum += i;
ffffffffc0201f1a:	0785                	addi	a5,a5,1
    for (i = 0; i < 100; i ++) {
ffffffffc0201f1c:	fee79de3          	bne	a5,a4,ffffffffc0201f16 <vmm_init+0x210>
        sum += i;
ffffffffc0201f20:	6705                	lui	a4,0x1
    for (i = 0; i < 100; i ++) {
ffffffffc0201f22:	10000793          	li	a5,256
        sum += i;
ffffffffc0201f26:	35670713          	addi	a4,a4,854 # 1356 <BASE_ADDRESS-0xffffffffc01fecaa>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc0201f2a:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc0201f2e:	0007c683          	lbu	a3,0(a5)
ffffffffc0201f32:	0785                	addi	a5,a5,1
ffffffffc0201f34:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc0201f36:	fec79ce3          	bne	a5,a2,ffffffffc0201f2e <vmm_init+0x228>
    }
    assert(sum == 0);
ffffffffc0201f3a:	2c071963          	bnez	a4,ffffffffc020220c <vmm_init+0x506>
    return pa2page(PDE_ADDR(pde));
ffffffffc0201f3e:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0201f42:	00013a97          	auipc	s5,0x13
ffffffffc0201f46:	546a8a93          	addi	s5,s5,1350 # ffffffffc0215488 <npage>
ffffffffc0201f4a:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201f4e:	078a                	slli	a5,a5,0x2
ffffffffc0201f50:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201f52:	20e7f563          	bgeu	a5,a4,ffffffffc020215c <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc0201f56:	00005697          	auipc	a3,0x5
ffffffffc0201f5a:	08268693          	addi	a3,a3,130 # ffffffffc0206fd8 <nbase>
ffffffffc0201f5e:	0006ba03          	ld	s4,0(a3)
ffffffffc0201f62:	414786b3          	sub	a3,a5,s4
ffffffffc0201f66:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc0201f68:	8699                	srai	a3,a3,0x6
ffffffffc0201f6a:	96d2                	add	a3,a3,s4
    return KADDR(page2pa(page));
ffffffffc0201f6c:	00c69793          	slli	a5,a3,0xc
ffffffffc0201f70:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201f72:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0201f74:	28e7f063          	bgeu	a5,a4,ffffffffc02021f4 <vmm_init+0x4ee>
ffffffffc0201f78:	00013797          	auipc	a5,0x13
ffffffffc0201f7c:	56878793          	addi	a5,a5,1384 # ffffffffc02154e0 <va_pa_offset>
ffffffffc0201f80:	6380                	ld	s0,0(a5)

    pde_t *pd1=pgdir,*pd0=page2kva(pde2page(pgdir[0]));
    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc0201f82:	4581                	li	a1,0
ffffffffc0201f84:	854a                	mv	a0,s2
ffffffffc0201f86:	9436                	add	s0,s0,a3
ffffffffc0201f88:	f57fe0ef          	jal	ra,ffffffffc0200ede <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc0201f8c:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0201f8e:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201f92:	078a                	slli	a5,a5,0x2
ffffffffc0201f94:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201f96:	1ce7f363          	bgeu	a5,a4,ffffffffc020215c <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc0201f9a:	00013417          	auipc	s0,0x13
ffffffffc0201f9e:	55640413          	addi	s0,s0,1366 # ffffffffc02154f0 <pages>
ffffffffc0201fa2:	6008                	ld	a0,0(s0)
ffffffffc0201fa4:	414787b3          	sub	a5,a5,s4
ffffffffc0201fa8:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc0201faa:	953e                	add	a0,a0,a5
ffffffffc0201fac:	4585                	li	a1,1
ffffffffc0201fae:	c81fe0ef          	jal	ra,ffffffffc0200c2e <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0201fb2:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0201fb6:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201fba:	078a                	slli	a5,a5,0x2
ffffffffc0201fbc:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201fbe:	18e7ff63          	bgeu	a5,a4,ffffffffc020215c <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc0201fc2:	6008                	ld	a0,0(s0)
ffffffffc0201fc4:	414787b3          	sub	a5,a5,s4
ffffffffc0201fc8:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0201fca:	4585                	li	a1,1
ffffffffc0201fcc:	953e                	add	a0,a0,a5
ffffffffc0201fce:	c61fe0ef          	jal	ra,ffffffffc0200c2e <free_pages>
    pgdir[0] = 0;
ffffffffc0201fd2:	00093023          	sd	zero,0(s2)
  asm volatile("sfence.vma");
ffffffffc0201fd6:	12000073          	sfence.vma
    flush_tlb();

    mm->pgdir = NULL;
ffffffffc0201fda:	0004bc23          	sd	zero,24(s1)
    mm_destroy(mm);
ffffffffc0201fde:	8526                	mv	a0,s1
ffffffffc0201fe0:	cf9ff0ef          	jal	ra,ffffffffc0201cd8 <mm_destroy>
    check_mm_struct = NULL;
ffffffffc0201fe4:	00013797          	auipc	a5,0x13
ffffffffc0201fe8:	5007ba23          	sd	zero,1300(a5) # ffffffffc02154f8 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0201fec:	c89fe0ef          	jal	ra,ffffffffc0200c74 <nr_free_pages>
ffffffffc0201ff0:	1aa99263          	bne	s3,a0,ffffffffc0202194 <vmm_init+0x48e>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc0201ff4:	00004517          	auipc	a0,0x4
ffffffffc0201ff8:	1b450513          	addi	a0,a0,436 # ffffffffc02061a8 <commands+0x1190>
ffffffffc0201ffc:	8d4fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
}
ffffffffc0202000:	7442                	ld	s0,48(sp)
ffffffffc0202002:	70e2                	ld	ra,56(sp)
ffffffffc0202004:	74a2                	ld	s1,40(sp)
ffffffffc0202006:	7902                	ld	s2,32(sp)
ffffffffc0202008:	69e2                	ld	s3,24(sp)
ffffffffc020200a:	6a42                	ld	s4,16(sp)
ffffffffc020200c:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc020200e:	00004517          	auipc	a0,0x4
ffffffffc0202012:	1ba50513          	addi	a0,a0,442 # ffffffffc02061c8 <commands+0x11b0>
}
ffffffffc0202016:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc0202018:	8b8fe06f          	j	ffffffffc02000d0 <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc020201c:	00004697          	auipc	a3,0x4
ffffffffc0202020:	fc468693          	addi	a3,a3,-60 # ffffffffc0205fe0 <commands+0xfc8>
ffffffffc0202024:	00004617          	auipc	a2,0x4
ffffffffc0202028:	98c60613          	addi	a2,a2,-1652 # ffffffffc02059b0 <commands+0x998>
ffffffffc020202c:	0d800593          	li	a1,216
ffffffffc0202030:	00004517          	auipc	a0,0x4
ffffffffc0202034:	e5850513          	addi	a0,a0,-424 # ffffffffc0205e88 <commands+0xe70>
ffffffffc0202038:	99cfe0ef          	jal	ra,ffffffffc02001d4 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc020203c:	00004697          	auipc	a3,0x4
ffffffffc0202040:	02c68693          	addi	a3,a3,44 # ffffffffc0206068 <commands+0x1050>
ffffffffc0202044:	00004617          	auipc	a2,0x4
ffffffffc0202048:	96c60613          	addi	a2,a2,-1684 # ffffffffc02059b0 <commands+0x998>
ffffffffc020204c:	0e800593          	li	a1,232
ffffffffc0202050:	00004517          	auipc	a0,0x4
ffffffffc0202054:	e3850513          	addi	a0,a0,-456 # ffffffffc0205e88 <commands+0xe70>
ffffffffc0202058:	97cfe0ef          	jal	ra,ffffffffc02001d4 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc020205c:	00004697          	auipc	a3,0x4
ffffffffc0202060:	03c68693          	addi	a3,a3,60 # ffffffffc0206098 <commands+0x1080>
ffffffffc0202064:	00004617          	auipc	a2,0x4
ffffffffc0202068:	94c60613          	addi	a2,a2,-1716 # ffffffffc02059b0 <commands+0x998>
ffffffffc020206c:	0e900593          	li	a1,233
ffffffffc0202070:	00004517          	auipc	a0,0x4
ffffffffc0202074:	e1850513          	addi	a0,a0,-488 # ffffffffc0205e88 <commands+0xe70>
ffffffffc0202078:	95cfe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(vma != NULL);
ffffffffc020207c:	00004697          	auipc	a3,0x4
ffffffffc0202080:	16468693          	addi	a3,a3,356 # ffffffffc02061e0 <commands+0x11c8>
ffffffffc0202084:	00004617          	auipc	a2,0x4
ffffffffc0202088:	92c60613          	addi	a2,a2,-1748 # ffffffffc02059b0 <commands+0x998>
ffffffffc020208c:	10800593          	li	a1,264
ffffffffc0202090:	00004517          	auipc	a0,0x4
ffffffffc0202094:	df850513          	addi	a0,a0,-520 # ffffffffc0205e88 <commands+0xe70>
ffffffffc0202098:	93cfe0ef          	jal	ra,ffffffffc02001d4 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc020209c:	00004697          	auipc	a3,0x4
ffffffffc02020a0:	f2c68693          	addi	a3,a3,-212 # ffffffffc0205fc8 <commands+0xfb0>
ffffffffc02020a4:	00004617          	auipc	a2,0x4
ffffffffc02020a8:	90c60613          	addi	a2,a2,-1780 # ffffffffc02059b0 <commands+0x998>
ffffffffc02020ac:	0d600593          	li	a1,214
ffffffffc02020b0:	00004517          	auipc	a0,0x4
ffffffffc02020b4:	dd850513          	addi	a0,a0,-552 # ffffffffc0205e88 <commands+0xe70>
ffffffffc02020b8:	91cfe0ef          	jal	ra,ffffffffc02001d4 <__panic>
        assert(vma3 == NULL);
ffffffffc02020bc:	00004697          	auipc	a3,0x4
ffffffffc02020c0:	f7c68693          	addi	a3,a3,-132 # ffffffffc0206038 <commands+0x1020>
ffffffffc02020c4:	00004617          	auipc	a2,0x4
ffffffffc02020c8:	8ec60613          	addi	a2,a2,-1812 # ffffffffc02059b0 <commands+0x998>
ffffffffc02020cc:	0e200593          	li	a1,226
ffffffffc02020d0:	00004517          	auipc	a0,0x4
ffffffffc02020d4:	db850513          	addi	a0,a0,-584 # ffffffffc0205e88 <commands+0xe70>
ffffffffc02020d8:	8fcfe0ef          	jal	ra,ffffffffc02001d4 <__panic>
        assert(vma2 != NULL);
ffffffffc02020dc:	00004697          	auipc	a3,0x4
ffffffffc02020e0:	f4c68693          	addi	a3,a3,-180 # ffffffffc0206028 <commands+0x1010>
ffffffffc02020e4:	00004617          	auipc	a2,0x4
ffffffffc02020e8:	8cc60613          	addi	a2,a2,-1844 # ffffffffc02059b0 <commands+0x998>
ffffffffc02020ec:	0e000593          	li	a1,224
ffffffffc02020f0:	00004517          	auipc	a0,0x4
ffffffffc02020f4:	d9850513          	addi	a0,a0,-616 # ffffffffc0205e88 <commands+0xe70>
ffffffffc02020f8:	8dcfe0ef          	jal	ra,ffffffffc02001d4 <__panic>
        assert(vma1 != NULL);
ffffffffc02020fc:	00004697          	auipc	a3,0x4
ffffffffc0202100:	f1c68693          	addi	a3,a3,-228 # ffffffffc0206018 <commands+0x1000>
ffffffffc0202104:	00004617          	auipc	a2,0x4
ffffffffc0202108:	8ac60613          	addi	a2,a2,-1876 # ffffffffc02059b0 <commands+0x998>
ffffffffc020210c:	0de00593          	li	a1,222
ffffffffc0202110:	00004517          	auipc	a0,0x4
ffffffffc0202114:	d7850513          	addi	a0,a0,-648 # ffffffffc0205e88 <commands+0xe70>
ffffffffc0202118:	8bcfe0ef          	jal	ra,ffffffffc02001d4 <__panic>
        assert(vma5 == NULL);
ffffffffc020211c:	00004697          	auipc	a3,0x4
ffffffffc0202120:	f3c68693          	addi	a3,a3,-196 # ffffffffc0206058 <commands+0x1040>
ffffffffc0202124:	00004617          	auipc	a2,0x4
ffffffffc0202128:	88c60613          	addi	a2,a2,-1908 # ffffffffc02059b0 <commands+0x998>
ffffffffc020212c:	0e600593          	li	a1,230
ffffffffc0202130:	00004517          	auipc	a0,0x4
ffffffffc0202134:	d5850513          	addi	a0,a0,-680 # ffffffffc0205e88 <commands+0xe70>
ffffffffc0202138:	89cfe0ef          	jal	ra,ffffffffc02001d4 <__panic>
        assert(vma4 == NULL);
ffffffffc020213c:	00004697          	auipc	a3,0x4
ffffffffc0202140:	f0c68693          	addi	a3,a3,-244 # ffffffffc0206048 <commands+0x1030>
ffffffffc0202144:	00004617          	auipc	a2,0x4
ffffffffc0202148:	86c60613          	addi	a2,a2,-1940 # ffffffffc02059b0 <commands+0x998>
ffffffffc020214c:	0e400593          	li	a1,228
ffffffffc0202150:	00004517          	auipc	a0,0x4
ffffffffc0202154:	d3850513          	addi	a0,a0,-712 # ffffffffc0205e88 <commands+0xe70>
ffffffffc0202158:	87cfe0ef          	jal	ra,ffffffffc02001d4 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020215c:	00003617          	auipc	a2,0x3
ffffffffc0202160:	73460613          	addi	a2,a2,1844 # ffffffffc0205890 <commands+0x878>
ffffffffc0202164:	06200593          	li	a1,98
ffffffffc0202168:	00003517          	auipc	a0,0x3
ffffffffc020216c:	74850513          	addi	a0,a0,1864 # ffffffffc02058b0 <commands+0x898>
ffffffffc0202170:	864fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(mm != NULL);
ffffffffc0202174:	00004697          	auipc	a3,0x4
ffffffffc0202178:	e4468693          	addi	a3,a3,-444 # ffffffffc0205fb8 <commands+0xfa0>
ffffffffc020217c:	00004617          	auipc	a2,0x4
ffffffffc0202180:	83460613          	addi	a2,a2,-1996 # ffffffffc02059b0 <commands+0x998>
ffffffffc0202184:	0c200593          	li	a1,194
ffffffffc0202188:	00004517          	auipc	a0,0x4
ffffffffc020218c:	d0050513          	addi	a0,a0,-768 # ffffffffc0205e88 <commands+0xe70>
ffffffffc0202190:	844fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0202194:	00004697          	auipc	a3,0x4
ffffffffc0202198:	fec68693          	addi	a3,a3,-20 # ffffffffc0206180 <commands+0x1168>
ffffffffc020219c:	00004617          	auipc	a2,0x4
ffffffffc02021a0:	81460613          	addi	a2,a2,-2028 # ffffffffc02059b0 <commands+0x998>
ffffffffc02021a4:	12400593          	li	a1,292
ffffffffc02021a8:	00004517          	auipc	a0,0x4
ffffffffc02021ac:	ce050513          	addi	a0,a0,-800 # ffffffffc0205e88 <commands+0xe70>
ffffffffc02021b0:	824fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(pgdir[0] == 0);
ffffffffc02021b4:	00004697          	auipc	a3,0x4
ffffffffc02021b8:	f8c68693          	addi	a3,a3,-116 # ffffffffc0206140 <commands+0x1128>
ffffffffc02021bc:	00003617          	auipc	a2,0x3
ffffffffc02021c0:	7f460613          	addi	a2,a2,2036 # ffffffffc02059b0 <commands+0x998>
ffffffffc02021c4:	10500593          	li	a1,261
ffffffffc02021c8:	00004517          	auipc	a0,0x4
ffffffffc02021cc:	cc050513          	addi	a0,a0,-832 # ffffffffc0205e88 <commands+0xe70>
ffffffffc02021d0:	804fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc02021d4:	00004697          	auipc	a3,0x4
ffffffffc02021d8:	f7c68693          	addi	a3,a3,-132 # ffffffffc0206150 <commands+0x1138>
ffffffffc02021dc:	00003617          	auipc	a2,0x3
ffffffffc02021e0:	7d460613          	addi	a2,a2,2004 # ffffffffc02059b0 <commands+0x998>
ffffffffc02021e4:	10d00593          	li	a1,269
ffffffffc02021e8:	00004517          	auipc	a0,0x4
ffffffffc02021ec:	ca050513          	addi	a0,a0,-864 # ffffffffc0205e88 <commands+0xe70>
ffffffffc02021f0:	fe5fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
    return KADDR(page2pa(page));
ffffffffc02021f4:	00003617          	auipc	a2,0x3
ffffffffc02021f8:	66460613          	addi	a2,a2,1636 # ffffffffc0205858 <commands+0x840>
ffffffffc02021fc:	06900593          	li	a1,105
ffffffffc0202200:	00003517          	auipc	a0,0x3
ffffffffc0202204:	6b050513          	addi	a0,a0,1712 # ffffffffc02058b0 <commands+0x898>
ffffffffc0202208:	fcdfd0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(sum == 0);
ffffffffc020220c:	00004697          	auipc	a3,0x4
ffffffffc0202210:	f6468693          	addi	a3,a3,-156 # ffffffffc0206170 <commands+0x1158>
ffffffffc0202214:	00003617          	auipc	a2,0x3
ffffffffc0202218:	79c60613          	addi	a2,a2,1948 # ffffffffc02059b0 <commands+0x998>
ffffffffc020221c:	11700593          	li	a1,279
ffffffffc0202220:	00004517          	auipc	a0,0x4
ffffffffc0202224:	c6850513          	addi	a0,a0,-920 # ffffffffc0205e88 <commands+0xe70>
ffffffffc0202228:	fadfd0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc020222c:	00004697          	auipc	a3,0x4
ffffffffc0202230:	efc68693          	addi	a3,a3,-260 # ffffffffc0206128 <commands+0x1110>
ffffffffc0202234:	00003617          	auipc	a2,0x3
ffffffffc0202238:	77c60613          	addi	a2,a2,1916 # ffffffffc02059b0 <commands+0x998>
ffffffffc020223c:	10100593          	li	a1,257
ffffffffc0202240:	00004517          	auipc	a0,0x4
ffffffffc0202244:	c4850513          	addi	a0,a0,-952 # ffffffffc0205e88 <commands+0xe70>
ffffffffc0202248:	f8dfd0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc020224c <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
ffffffffc020224c:	7139                	addi	sp,sp,-64
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc020224e:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
ffffffffc0202250:	f822                	sd	s0,48(sp)
ffffffffc0202252:	f426                	sd	s1,40(sp)
ffffffffc0202254:	fc06                	sd	ra,56(sp)
ffffffffc0202256:	f04a                	sd	s2,32(sp)
ffffffffc0202258:	ec4e                	sd	s3,24(sp)
ffffffffc020225a:	8432                	mv	s0,a2
ffffffffc020225c:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc020225e:	96fff0ef          	jal	ra,ffffffffc0201bcc <find_vma>

    pgfault_num++;
ffffffffc0202262:	00013797          	auipc	a5,0x13
ffffffffc0202266:	22e78793          	addi	a5,a5,558 # ffffffffc0215490 <pgfault_num>
ffffffffc020226a:	439c                	lw	a5,0(a5)
ffffffffc020226c:	2785                	addiw	a5,a5,1
ffffffffc020226e:	00013717          	auipc	a4,0x13
ffffffffc0202272:	22f72123          	sw	a5,546(a4) # ffffffffc0215490 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0202276:	c555                	beqz	a0,ffffffffc0202322 <do_pgfault+0xd6>
ffffffffc0202278:	651c                	ld	a5,8(a0)
ffffffffc020227a:	0af46463          	bltu	s0,a5,ffffffffc0202322 <do_pgfault+0xd6>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc020227e:	4d1c                	lw	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc0202280:	49c1                	li	s3,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0202282:	8b89                	andi	a5,a5,2
ffffffffc0202284:	e3a5                	bnez	a5,ffffffffc02022e4 <do_pgfault+0x98>
        perm |= READ_WRITE;
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0202286:	767d                	lui	a2,0xfffff

    pte_t *ptep=NULL;
  
    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0202288:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc020228a:	8c71                	and	s0,s0,a2
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc020228c:	85a2                	mv	a1,s0
ffffffffc020228e:	4605                	li	a2,1
ffffffffc0202290:	a25fe0ef          	jal	ra,ffffffffc0200cb4 <get_pte>
ffffffffc0202294:	c945                	beqz	a0,ffffffffc0202344 <do_pgfault+0xf8>
        cprintf("get_pte in do_pgfault failed\n");
        goto failed;
    }
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
ffffffffc0202296:	610c                	ld	a1,0(a0)
ffffffffc0202298:	c5b5                	beqz	a1,ffffffffc0202304 <do_pgfault+0xb8>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc020229a:	00013797          	auipc	a5,0x13
ffffffffc020229e:	20678793          	addi	a5,a5,518 # ffffffffc02154a0 <swap_init_ok>
ffffffffc02022a2:	439c                	lw	a5,0(a5)
ffffffffc02022a4:	2781                	sext.w	a5,a5
ffffffffc02022a6:	c7d9                	beqz	a5,ffffffffc0202334 <do_pgfault+0xe8>
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            //(3) make the page swappable.
            if ((ret = swap_in(mm, addr, &page)) != 0) {
ffffffffc02022a8:	0030                	addi	a2,sp,8
ffffffffc02022aa:	85a2                	mv	a1,s0
ffffffffc02022ac:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc02022ae:	e402                	sd	zero,8(sp)
            if ((ret = swap_in(mm, addr, &page)) != 0) {
ffffffffc02022b0:	14d000ef          	jal	ra,ffffffffc0202bfc <swap_in>
ffffffffc02022b4:	892a                	mv	s2,a0
ffffffffc02022b6:	e90d                	bnez	a0,ffffffffc02022e8 <do_pgfault+0x9c>
                cprintf("swap_in in do_pgfault failed\n");
                goto failed;
            }   
            // 交换成功，则建立物理地址<--->虚拟地址映射，并将页设置为可交换的
            page_insert(mm->pgdir, page, addr, perm);
ffffffffc02022b8:	65a2                	ld	a1,8(sp)
ffffffffc02022ba:	6c88                	ld	a0,24(s1)
ffffffffc02022bc:	86ce                	mv	a3,s3
ffffffffc02022be:	8622                	mv	a2,s0
ffffffffc02022c0:	c93fe0ef          	jal	ra,ffffffffc0200f52 <page_insert>
            swap_map_swappable(mm, addr, page, 1);//将物理页设置为可交换状态
ffffffffc02022c4:	6622                	ld	a2,8(sp)
ffffffffc02022c6:	4685                	li	a3,1
ffffffffc02022c8:	85a2                	mv	a1,s0
ffffffffc02022ca:	8526                	mv	a0,s1
ffffffffc02022cc:	00d000ef          	jal	ra,ffffffffc0202ad8 <swap_map_swappable>
            page->pra_vaddr = addr;
ffffffffc02022d0:	67a2                	ld	a5,8(sp)
ffffffffc02022d2:	ff80                	sd	s0,56(a5)
   }

   ret = 0;
failed:
    return ret;
}
ffffffffc02022d4:	70e2                	ld	ra,56(sp)
ffffffffc02022d6:	7442                	ld	s0,48(sp)
ffffffffc02022d8:	854a                	mv	a0,s2
ffffffffc02022da:	74a2                	ld	s1,40(sp)
ffffffffc02022dc:	7902                	ld	s2,32(sp)
ffffffffc02022de:	69e2                	ld	s3,24(sp)
ffffffffc02022e0:	6121                	addi	sp,sp,64
ffffffffc02022e2:	8082                	ret
        perm |= READ_WRITE;
ffffffffc02022e4:	49dd                	li	s3,23
ffffffffc02022e6:	b745                	j	ffffffffc0202286 <do_pgfault+0x3a>
                cprintf("swap_in in do_pgfault failed\n");
ffffffffc02022e8:	00004517          	auipc	a0,0x4
ffffffffc02022ec:	c2850513          	addi	a0,a0,-984 # ffffffffc0205f10 <commands+0xef8>
ffffffffc02022f0:	de1fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
}
ffffffffc02022f4:	70e2                	ld	ra,56(sp)
ffffffffc02022f6:	7442                	ld	s0,48(sp)
ffffffffc02022f8:	854a                	mv	a0,s2
ffffffffc02022fa:	74a2                	ld	s1,40(sp)
ffffffffc02022fc:	7902                	ld	s2,32(sp)
ffffffffc02022fe:	69e2                	ld	s3,24(sp)
ffffffffc0202300:	6121                	addi	sp,sp,64
ffffffffc0202302:	8082                	ret
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0202304:	6c88                	ld	a0,24(s1)
ffffffffc0202306:	864e                	mv	a2,s3
ffffffffc0202308:	85a2                	mv	a1,s0
ffffffffc020230a:	f92ff0ef          	jal	ra,ffffffffc0201a9c <pgdir_alloc_page>
   ret = 0;
ffffffffc020230e:	4901                	li	s2,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0202310:	f171                	bnez	a0,ffffffffc02022d4 <do_pgfault+0x88>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0202312:	00004517          	auipc	a0,0x4
ffffffffc0202316:	bd650513          	addi	a0,a0,-1066 # ffffffffc0205ee8 <commands+0xed0>
ffffffffc020231a:	db7fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    ret = -E_NO_MEM;
ffffffffc020231e:	5971                	li	s2,-4
            goto failed;
ffffffffc0202320:	bf55                	j	ffffffffc02022d4 <do_pgfault+0x88>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0202322:	85a2                	mv	a1,s0
ffffffffc0202324:	00004517          	auipc	a0,0x4
ffffffffc0202328:	b7450513          	addi	a0,a0,-1164 # ffffffffc0205e98 <commands+0xe80>
ffffffffc020232c:	da5fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    int ret = -E_INVAL;
ffffffffc0202330:	5975                	li	s2,-3
        goto failed;
ffffffffc0202332:	b74d                	j	ffffffffc02022d4 <do_pgfault+0x88>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc0202334:	00004517          	auipc	a0,0x4
ffffffffc0202338:	bfc50513          	addi	a0,a0,-1028 # ffffffffc0205f30 <commands+0xf18>
ffffffffc020233c:	d95fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0202340:	5971                	li	s2,-4
            goto failed;
ffffffffc0202342:	bf49                	j	ffffffffc02022d4 <do_pgfault+0x88>
        cprintf("get_pte in do_pgfault failed\n");
ffffffffc0202344:	00004517          	auipc	a0,0x4
ffffffffc0202348:	b8450513          	addi	a0,a0,-1148 # ffffffffc0205ec8 <commands+0xeb0>
ffffffffc020234c:	d85fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0202350:	5971                	li	s2,-4
        goto failed;
ffffffffc0202352:	b749                	j	ffffffffc02022d4 <do_pgfault+0x88>

ffffffffc0202354 <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc0202354:	7135                	addi	sp,sp,-160
ffffffffc0202356:	ed06                	sd	ra,152(sp)
ffffffffc0202358:	e922                	sd	s0,144(sp)
ffffffffc020235a:	e526                	sd	s1,136(sp)
ffffffffc020235c:	e14a                	sd	s2,128(sp)
ffffffffc020235e:	fcce                	sd	s3,120(sp)
ffffffffc0202360:	f8d2                	sd	s4,112(sp)
ffffffffc0202362:	f4d6                	sd	s5,104(sp)
ffffffffc0202364:	f0da                	sd	s6,96(sp)
ffffffffc0202366:	ecde                	sd	s7,88(sp)
ffffffffc0202368:	e8e2                	sd	s8,80(sp)
ffffffffc020236a:	e4e6                	sd	s9,72(sp)
ffffffffc020236c:	e0ea                	sd	s10,64(sp)
ffffffffc020236e:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc0202370:	4b9010ef          	jal	ra,ffffffffc0204028 <swapfs_init>
     // if (!(1024 <= max_swap_offset && max_swap_offset < MAX_SWAP_OFFSET_LIMIT))
     // {
     //      panic("bad max_swap_offset %08x.\n", max_swap_offset);
     // }
     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc0202374:	00013797          	auipc	a5,0x13
ffffffffc0202378:	21478793          	addi	a5,a5,532 # ffffffffc0215588 <max_swap_offset>
ffffffffc020237c:	6394                	ld	a3,0(a5)
ffffffffc020237e:	010007b7          	lui	a5,0x1000
ffffffffc0202382:	17e1                	addi	a5,a5,-8
ffffffffc0202384:	ff968713          	addi	a4,a3,-7
ffffffffc0202388:	4ae7e863          	bltu	a5,a4,ffffffffc0202838 <swap_init+0x4e4>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }

     sm = &swap_manager_fifo;
ffffffffc020238c:	00008797          	auipc	a5,0x8
ffffffffc0202390:	c8478793          	addi	a5,a5,-892 # ffffffffc020a010 <swap_manager_fifo>
     int r = sm->init();
ffffffffc0202394:	6798                	ld	a4,8(a5)
     sm = &swap_manager_fifo;
ffffffffc0202396:	00013697          	auipc	a3,0x13
ffffffffc020239a:	10f6b123          	sd	a5,258(a3) # ffffffffc0215498 <sm>
     int r = sm->init();
ffffffffc020239e:	9702                	jalr	a4
ffffffffc02023a0:	8aaa                	mv	s5,a0
     
     if (r == 0)
ffffffffc02023a2:	c10d                	beqz	a0,ffffffffc02023c4 <swap_init+0x70>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc02023a4:	60ea                	ld	ra,152(sp)
ffffffffc02023a6:	644a                	ld	s0,144(sp)
ffffffffc02023a8:	8556                	mv	a0,s5
ffffffffc02023aa:	64aa                	ld	s1,136(sp)
ffffffffc02023ac:	690a                	ld	s2,128(sp)
ffffffffc02023ae:	79e6                	ld	s3,120(sp)
ffffffffc02023b0:	7a46                	ld	s4,112(sp)
ffffffffc02023b2:	7aa6                	ld	s5,104(sp)
ffffffffc02023b4:	7b06                	ld	s6,96(sp)
ffffffffc02023b6:	6be6                	ld	s7,88(sp)
ffffffffc02023b8:	6c46                	ld	s8,80(sp)
ffffffffc02023ba:	6ca6                	ld	s9,72(sp)
ffffffffc02023bc:	6d06                	ld	s10,64(sp)
ffffffffc02023be:	7de2                	ld	s11,56(sp)
ffffffffc02023c0:	610d                	addi	sp,sp,160
ffffffffc02023c2:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02023c4:	00013797          	auipc	a5,0x13
ffffffffc02023c8:	0d478793          	addi	a5,a5,212 # ffffffffc0215498 <sm>
ffffffffc02023cc:	639c                	ld	a5,0(a5)
ffffffffc02023ce:	00004517          	auipc	a0,0x4
ffffffffc02023d2:	ea250513          	addi	a0,a0,-350 # ffffffffc0206270 <commands+0x1258>
ffffffffc02023d6:	00013417          	auipc	s0,0x13
ffffffffc02023da:	20240413          	addi	s0,s0,514 # ffffffffc02155d8 <free_area>
ffffffffc02023de:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc02023e0:	4785                	li	a5,1
ffffffffc02023e2:	00013717          	auipc	a4,0x13
ffffffffc02023e6:	0af72f23          	sw	a5,190(a4) # ffffffffc02154a0 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02023ea:	ce7fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc02023ee:	641c                	ld	a5,8(s0)
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc02023f0:	36878863          	beq	a5,s0,ffffffffc0202760 <swap_init+0x40c>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02023f4:	ff07b703          	ld	a4,-16(a5)
ffffffffc02023f8:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc02023fa:	8b05                	andi	a4,a4,1
ffffffffc02023fc:	36070663          	beqz	a4,ffffffffc0202768 <swap_init+0x414>
     int ret, count = 0, total = 0, i;
ffffffffc0202400:	4481                	li	s1,0
ffffffffc0202402:	4901                	li	s2,0
ffffffffc0202404:	a031                	j	ffffffffc0202410 <swap_init+0xbc>
ffffffffc0202406:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc020240a:	8b09                	andi	a4,a4,2
ffffffffc020240c:	34070e63          	beqz	a4,ffffffffc0202768 <swap_init+0x414>
        count ++, total += p->property;
ffffffffc0202410:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202414:	679c                	ld	a5,8(a5)
ffffffffc0202416:	2905                	addiw	s2,s2,1
ffffffffc0202418:	9cb9                	addw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc020241a:	fe8796e3          	bne	a5,s0,ffffffffc0202406 <swap_init+0xb2>
ffffffffc020241e:	89a6                	mv	s3,s1
     }
     assert(total == nr_free_pages());
ffffffffc0202420:	855fe0ef          	jal	ra,ffffffffc0200c74 <nr_free_pages>
ffffffffc0202424:	69351263          	bne	a0,s3,ffffffffc0202aa8 <swap_init+0x754>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc0202428:	8626                	mv	a2,s1
ffffffffc020242a:	85ca                	mv	a1,s2
ffffffffc020242c:	00004517          	auipc	a0,0x4
ffffffffc0202430:	e8c50513          	addi	a0,a0,-372 # ffffffffc02062b8 <commands+0x12a0>
ffffffffc0202434:	c9dfd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc0202438:	f1aff0ef          	jal	ra,ffffffffc0201b52 <mm_create>
ffffffffc020243c:	8baa                	mv	s7,a0
     assert(mm != NULL);
ffffffffc020243e:	60050563          	beqz	a0,ffffffffc0202a48 <swap_init+0x6f4>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc0202442:	00013797          	auipc	a5,0x13
ffffffffc0202446:	0b678793          	addi	a5,a5,182 # ffffffffc02154f8 <check_mm_struct>
ffffffffc020244a:	639c                	ld	a5,0(a5)
ffffffffc020244c:	60079e63          	bnez	a5,ffffffffc0202a68 <swap_init+0x714>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202450:	00013797          	auipc	a5,0x13
ffffffffc0202454:	03078793          	addi	a5,a5,48 # ffffffffc0215480 <boot_pgdir>
ffffffffc0202458:	0007bb03          	ld	s6,0(a5)
     check_mm_struct = mm;
ffffffffc020245c:	00013797          	auipc	a5,0x13
ffffffffc0202460:	08a7be23          	sd	a0,156(a5) # ffffffffc02154f8 <check_mm_struct>
     assert(pgdir[0] == 0);
ffffffffc0202464:	000b3783          	ld	a5,0(s6)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202468:	01653c23          	sd	s6,24(a0)
     assert(pgdir[0] == 0);
ffffffffc020246c:	4e079263          	bnez	a5,ffffffffc0202950 <swap_init+0x5fc>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc0202470:	6599                	lui	a1,0x6
ffffffffc0202472:	460d                	li	a2,3
ffffffffc0202474:	6505                	lui	a0,0x1
ffffffffc0202476:	f28ff0ef          	jal	ra,ffffffffc0201b9e <vma_create>
ffffffffc020247a:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc020247c:	4e050a63          	beqz	a0,ffffffffc0202970 <swap_init+0x61c>

     insert_vma_struct(mm, vma);
ffffffffc0202480:	855e                	mv	a0,s7
ffffffffc0202482:	f88ff0ef          	jal	ra,ffffffffc0201c0a <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc0202486:	00004517          	auipc	a0,0x4
ffffffffc020248a:	e7250513          	addi	a0,a0,-398 # ffffffffc02062f8 <commands+0x12e0>
ffffffffc020248e:	c43fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc0202492:	018bb503          	ld	a0,24(s7)
ffffffffc0202496:	4605                	li	a2,1
ffffffffc0202498:	6585                	lui	a1,0x1
ffffffffc020249a:	81bfe0ef          	jal	ra,ffffffffc0200cb4 <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc020249e:	4e050963          	beqz	a0,ffffffffc0202990 <swap_init+0x63c>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc02024a2:	00004517          	auipc	a0,0x4
ffffffffc02024a6:	ea650513          	addi	a0,a0,-346 # ffffffffc0206348 <commands+0x1330>
ffffffffc02024aa:	00013997          	auipc	s3,0x13
ffffffffc02024ae:	05698993          	addi	s3,s3,86 # ffffffffc0215500 <check_rp>
ffffffffc02024b2:	c1ffd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02024b6:	00013a17          	auipc	s4,0x13
ffffffffc02024ba:	06aa0a13          	addi	s4,s4,106 # ffffffffc0215520 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc02024be:	8c4e                	mv	s8,s3
          check_rp[i] = alloc_page();
ffffffffc02024c0:	4505                	li	a0,1
ffffffffc02024c2:	ee4fe0ef          	jal	ra,ffffffffc0200ba6 <alloc_pages>
ffffffffc02024c6:	00ac3023          	sd	a0,0(s8)
          assert(check_rp[i] != NULL );
ffffffffc02024ca:	32050763          	beqz	a0,ffffffffc02027f8 <swap_init+0x4a4>
ffffffffc02024ce:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc02024d0:	8b89                	andi	a5,a5,2
ffffffffc02024d2:	30079363          	bnez	a5,ffffffffc02027d8 <swap_init+0x484>
ffffffffc02024d6:	0c21                	addi	s8,s8,8
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02024d8:	ff4c14e3          	bne	s8,s4,ffffffffc02024c0 <swap_init+0x16c>
     }
     list_entry_t free_list_store = free_list;
ffffffffc02024dc:	601c                	ld	a5,0(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc02024de:	00013c17          	auipc	s8,0x13
ffffffffc02024e2:	022c0c13          	addi	s8,s8,34 # ffffffffc0215500 <check_rp>
     list_entry_t free_list_store = free_list;
ffffffffc02024e6:	ec3e                	sd	a5,24(sp)
ffffffffc02024e8:	641c                	ld	a5,8(s0)
ffffffffc02024ea:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc02024ec:	481c                	lw	a5,16(s0)
ffffffffc02024ee:	f43e                	sd	a5,40(sp)
    elm->prev = elm->next = elm;
ffffffffc02024f0:	00013797          	auipc	a5,0x13
ffffffffc02024f4:	0e87b823          	sd	s0,240(a5) # ffffffffc02155e0 <free_area+0x8>
ffffffffc02024f8:	00013797          	auipc	a5,0x13
ffffffffc02024fc:	0e87b023          	sd	s0,224(a5) # ffffffffc02155d8 <free_area>
     nr_free = 0;
ffffffffc0202500:	00013797          	auipc	a5,0x13
ffffffffc0202504:	0e07a423          	sw	zero,232(a5) # ffffffffc02155e8 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc0202508:	000c3503          	ld	a0,0(s8)
ffffffffc020250c:	4585                	li	a1,1
ffffffffc020250e:	0c21                	addi	s8,s8,8
ffffffffc0202510:	f1efe0ef          	jal	ra,ffffffffc0200c2e <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202514:	ff4c1ae3          	bne	s8,s4,ffffffffc0202508 <swap_init+0x1b4>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0202518:	01042c03          	lw	s8,16(s0)
ffffffffc020251c:	4791                	li	a5,4
ffffffffc020251e:	50fc1563          	bne	s8,a5,ffffffffc0202a28 <swap_init+0x6d4>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc0202522:	00004517          	auipc	a0,0x4
ffffffffc0202526:	eae50513          	addi	a0,a0,-338 # ffffffffc02063d0 <commands+0x13b8>
ffffffffc020252a:	ba7fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc020252e:	6685                	lui	a3,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc0202530:	00013797          	auipc	a5,0x13
ffffffffc0202534:	f607a023          	sw	zero,-160(a5) # ffffffffc0215490 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202538:	4629                	li	a2,10
     pgfault_num=0;
ffffffffc020253a:	00013797          	auipc	a5,0x13
ffffffffc020253e:	f5678793          	addi	a5,a5,-170 # ffffffffc0215490 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202542:	00c68023          	sb	a2,0(a3) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
     assert(pgfault_num==1);
ffffffffc0202546:	4398                	lw	a4,0(a5)
ffffffffc0202548:	4585                	li	a1,1
ffffffffc020254a:	2701                	sext.w	a4,a4
ffffffffc020254c:	38b71263          	bne	a4,a1,ffffffffc02028d0 <swap_init+0x57c>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc0202550:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==1);
ffffffffc0202554:	4394                	lw	a3,0(a5)
ffffffffc0202556:	2681                	sext.w	a3,a3
ffffffffc0202558:	38e69c63          	bne	a3,a4,ffffffffc02028f0 <swap_init+0x59c>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc020255c:	6689                	lui	a3,0x2
ffffffffc020255e:	462d                	li	a2,11
ffffffffc0202560:	00c68023          	sb	a2,0(a3) # 2000 <BASE_ADDRESS-0xffffffffc01fe000>
     assert(pgfault_num==2);
ffffffffc0202564:	4398                	lw	a4,0(a5)
ffffffffc0202566:	4589                	li	a1,2
ffffffffc0202568:	2701                	sext.w	a4,a4
ffffffffc020256a:	2eb71363          	bne	a4,a1,ffffffffc0202850 <swap_init+0x4fc>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc020256e:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc0202572:	4394                	lw	a3,0(a5)
ffffffffc0202574:	2681                	sext.w	a3,a3
ffffffffc0202576:	2ee69d63          	bne	a3,a4,ffffffffc0202870 <swap_init+0x51c>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc020257a:	668d                	lui	a3,0x3
ffffffffc020257c:	4631                	li	a2,12
ffffffffc020257e:	00c68023          	sb	a2,0(a3) # 3000 <BASE_ADDRESS-0xffffffffc01fd000>
     assert(pgfault_num==3);
ffffffffc0202582:	4398                	lw	a4,0(a5)
ffffffffc0202584:	458d                	li	a1,3
ffffffffc0202586:	2701                	sext.w	a4,a4
ffffffffc0202588:	30b71463          	bne	a4,a1,ffffffffc0202890 <swap_init+0x53c>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc020258c:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc0202590:	4394                	lw	a3,0(a5)
ffffffffc0202592:	2681                	sext.w	a3,a3
ffffffffc0202594:	30e69e63          	bne	a3,a4,ffffffffc02028b0 <swap_init+0x55c>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc0202598:	6691                	lui	a3,0x4
ffffffffc020259a:	4635                	li	a2,13
ffffffffc020259c:	00c68023          	sb	a2,0(a3) # 4000 <BASE_ADDRESS-0xffffffffc01fc000>
     assert(pgfault_num==4);
ffffffffc02025a0:	4398                	lw	a4,0(a5)
ffffffffc02025a2:	2701                	sext.w	a4,a4
ffffffffc02025a4:	37871663          	bne	a4,s8,ffffffffc0202910 <swap_init+0x5bc>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc02025a8:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc02025ac:	439c                	lw	a5,0(a5)
ffffffffc02025ae:	2781                	sext.w	a5,a5
ffffffffc02025b0:	38e79063          	bne	a5,a4,ffffffffc0202930 <swap_init+0x5dc>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc02025b4:	481c                	lw	a5,16(s0)
ffffffffc02025b6:	3e079d63          	bnez	a5,ffffffffc02029b0 <swap_init+0x65c>
ffffffffc02025ba:	00013797          	auipc	a5,0x13
ffffffffc02025be:	f6678793          	addi	a5,a5,-154 # ffffffffc0215520 <swap_in_seq_no>
ffffffffc02025c2:	00013717          	auipc	a4,0x13
ffffffffc02025c6:	f8670713          	addi	a4,a4,-122 # ffffffffc0215548 <swap_out_seq_no>
ffffffffc02025ca:	00013617          	auipc	a2,0x13
ffffffffc02025ce:	f7e60613          	addi	a2,a2,-130 # ffffffffc0215548 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc02025d2:	56fd                	li	a3,-1
ffffffffc02025d4:	c394                	sw	a3,0(a5)
ffffffffc02025d6:	c314                	sw	a3,0(a4)
ffffffffc02025d8:	0791                	addi	a5,a5,4
ffffffffc02025da:	0711                	addi	a4,a4,4
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc02025dc:	fef61ce3          	bne	a2,a5,ffffffffc02025d4 <swap_init+0x280>
ffffffffc02025e0:	00013697          	auipc	a3,0x13
ffffffffc02025e4:	fc868693          	addi	a3,a3,-56 # ffffffffc02155a8 <check_ptep>
ffffffffc02025e8:	00013817          	auipc	a6,0x13
ffffffffc02025ec:	f1880813          	addi	a6,a6,-232 # ffffffffc0215500 <check_rp>
ffffffffc02025f0:	6d05                	lui	s10,0x1
    if (PPN(pa) >= npage) {
ffffffffc02025f2:	00013c97          	auipc	s9,0x13
ffffffffc02025f6:	e96c8c93          	addi	s9,s9,-362 # ffffffffc0215488 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc02025fa:	00005d97          	auipc	s11,0x5
ffffffffc02025fe:	9ded8d93          	addi	s11,s11,-1570 # ffffffffc0206fd8 <nbase>
ffffffffc0202602:	00013c17          	auipc	s8,0x13
ffffffffc0202606:	eeec0c13          	addi	s8,s8,-274 # ffffffffc02154f0 <pages>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc020260a:	0006b023          	sd	zero,0(a3)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc020260e:	4601                	li	a2,0
ffffffffc0202610:	85ea                	mv	a1,s10
ffffffffc0202612:	855a                	mv	a0,s6
ffffffffc0202614:	e842                	sd	a6,16(sp)
         check_ptep[i]=0;
ffffffffc0202616:	e436                	sd	a3,8(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202618:	e9cfe0ef          	jal	ra,ffffffffc0200cb4 <get_pte>
ffffffffc020261c:	66a2                	ld	a3,8(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc020261e:	6842                	ld	a6,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202620:	e288                	sd	a0,0(a3)
         assert(check_ptep[i] != NULL);
ffffffffc0202622:	1e050b63          	beqz	a0,ffffffffc0202818 <swap_init+0x4c4>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202626:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0202628:	0017f613          	andi	a2,a5,1
ffffffffc020262c:	18060a63          	beqz	a2,ffffffffc02027c0 <swap_init+0x46c>
    if (PPN(pa) >= npage) {
ffffffffc0202630:	000cb603          	ld	a2,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202634:	078a                	slli	a5,a5,0x2
ffffffffc0202636:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202638:	14c7f863          	bgeu	a5,a2,ffffffffc0202788 <swap_init+0x434>
    return &pages[PPN(pa) - nbase];
ffffffffc020263c:	000db703          	ld	a4,0(s11)
ffffffffc0202640:	000c3603          	ld	a2,0(s8)
ffffffffc0202644:	00083583          	ld	a1,0(a6)
ffffffffc0202648:	8f99                	sub	a5,a5,a4
ffffffffc020264a:	079a                	slli	a5,a5,0x6
ffffffffc020264c:	e43a                	sd	a4,8(sp)
ffffffffc020264e:	97b2                	add	a5,a5,a2
ffffffffc0202650:	14f59863          	bne	a1,a5,ffffffffc02027a0 <swap_init+0x44c>
ffffffffc0202654:	6785                	lui	a5,0x1
ffffffffc0202656:	9d3e                	add	s10,s10,a5
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202658:	6795                	lui	a5,0x5
ffffffffc020265a:	06a1                	addi	a3,a3,8
ffffffffc020265c:	0821                	addi	a6,a6,8
ffffffffc020265e:	fafd16e3          	bne	s10,a5,ffffffffc020260a <swap_init+0x2b6>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc0202662:	00004517          	auipc	a0,0x4
ffffffffc0202666:	e2650513          	addi	a0,a0,-474 # ffffffffc0206488 <commands+0x1470>
ffffffffc020266a:	a67fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    int ret = sm->check_swap();
ffffffffc020266e:	00013797          	auipc	a5,0x13
ffffffffc0202672:	e2a78793          	addi	a5,a5,-470 # ffffffffc0215498 <sm>
ffffffffc0202676:	639c                	ld	a5,0(a5)
ffffffffc0202678:	7f9c                	ld	a5,56(a5)
ffffffffc020267a:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc020267c:	40051663          	bnez	a0,ffffffffc0202a88 <swap_init+0x734>

     nr_free = nr_free_store;
ffffffffc0202680:	77a2                	ld	a5,40(sp)
ffffffffc0202682:	00013717          	auipc	a4,0x13
ffffffffc0202686:	f6f72323          	sw	a5,-154(a4) # ffffffffc02155e8 <free_area+0x10>
     free_list = free_list_store;
ffffffffc020268a:	67e2                	ld	a5,24(sp)
ffffffffc020268c:	00013717          	auipc	a4,0x13
ffffffffc0202690:	f4f73623          	sd	a5,-180(a4) # ffffffffc02155d8 <free_area>
ffffffffc0202694:	7782                	ld	a5,32(sp)
ffffffffc0202696:	00013717          	auipc	a4,0x13
ffffffffc020269a:	f4f73523          	sd	a5,-182(a4) # ffffffffc02155e0 <free_area+0x8>

     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc020269e:	0009b503          	ld	a0,0(s3)
ffffffffc02026a2:	4585                	li	a1,1
ffffffffc02026a4:	09a1                	addi	s3,s3,8
ffffffffc02026a6:	d88fe0ef          	jal	ra,ffffffffc0200c2e <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02026aa:	ff499ae3          	bne	s3,s4,ffffffffc020269e <swap_init+0x34a>
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
ffffffffc02026ae:	855e                	mv	a0,s7
ffffffffc02026b0:	e28ff0ef          	jal	ra,ffffffffc0201cd8 <mm_destroy>

     pde_t *pd1=pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc02026b4:	00013797          	auipc	a5,0x13
ffffffffc02026b8:	dcc78793          	addi	a5,a5,-564 # ffffffffc0215480 <boot_pgdir>
ffffffffc02026bc:	639c                	ld	a5,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc02026be:	000cb703          	ld	a4,0(s9)
    return pa2page(PDE_ADDR(pde));
ffffffffc02026c2:	6394                	ld	a3,0(a5)
ffffffffc02026c4:	068a                	slli	a3,a3,0x2
ffffffffc02026c6:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc02026c8:	0ce6f063          	bgeu	a3,a4,ffffffffc0202788 <swap_init+0x434>
    return &pages[PPN(pa) - nbase];
ffffffffc02026cc:	67a2                	ld	a5,8(sp)
ffffffffc02026ce:	000c3503          	ld	a0,0(s8)
ffffffffc02026d2:	8e9d                	sub	a3,a3,a5
ffffffffc02026d4:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc02026d6:	8699                	srai	a3,a3,0x6
ffffffffc02026d8:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc02026da:	00c69793          	slli	a5,a3,0xc
ffffffffc02026de:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02026e0:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02026e2:	2ee7f763          	bgeu	a5,a4,ffffffffc02029d0 <swap_init+0x67c>
     free_page(pde2page(pd0[0]));
ffffffffc02026e6:	00013797          	auipc	a5,0x13
ffffffffc02026ea:	dfa78793          	addi	a5,a5,-518 # ffffffffc02154e0 <va_pa_offset>
ffffffffc02026ee:	639c                	ld	a5,0(a5)
ffffffffc02026f0:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc02026f2:	629c                	ld	a5,0(a3)
ffffffffc02026f4:	078a                	slli	a5,a5,0x2
ffffffffc02026f6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02026f8:	08e7f863          	bgeu	a5,a4,ffffffffc0202788 <swap_init+0x434>
    return &pages[PPN(pa) - nbase];
ffffffffc02026fc:	69a2                	ld	s3,8(sp)
ffffffffc02026fe:	4585                	li	a1,1
ffffffffc0202700:	413787b3          	sub	a5,a5,s3
ffffffffc0202704:	079a                	slli	a5,a5,0x6
ffffffffc0202706:	953e                	add	a0,a0,a5
ffffffffc0202708:	d26fe0ef          	jal	ra,ffffffffc0200c2e <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc020270c:	000b3783          	ld	a5,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc0202710:	000cb703          	ld	a4,0(s9)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202714:	078a                	slli	a5,a5,0x2
ffffffffc0202716:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202718:	06e7f863          	bgeu	a5,a4,ffffffffc0202788 <swap_init+0x434>
    return &pages[PPN(pa) - nbase];
ffffffffc020271c:	000c3503          	ld	a0,0(s8)
ffffffffc0202720:	413787b3          	sub	a5,a5,s3
ffffffffc0202724:	079a                	slli	a5,a5,0x6
     free_page(pde2page(pd1[0]));
ffffffffc0202726:	4585                	li	a1,1
ffffffffc0202728:	953e                	add	a0,a0,a5
ffffffffc020272a:	d04fe0ef          	jal	ra,ffffffffc0200c2e <free_pages>
     pgdir[0] = 0;
ffffffffc020272e:	000b3023          	sd	zero,0(s6)
  asm volatile("sfence.vma");
ffffffffc0202732:	12000073          	sfence.vma
    return listelm->next;
ffffffffc0202736:	641c                	ld	a5,8(s0)
     flush_tlb();

     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202738:	00878963          	beq	a5,s0,ffffffffc020274a <swap_init+0x3f6>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc020273c:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202740:	679c                	ld	a5,8(a5)
ffffffffc0202742:	397d                	addiw	s2,s2,-1
ffffffffc0202744:	9c99                	subw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202746:	fe879be3          	bne	a5,s0,ffffffffc020273c <swap_init+0x3e8>
     }
     assert(count==0);
ffffffffc020274a:	28091f63          	bnez	s2,ffffffffc02029e8 <swap_init+0x694>
     assert(total==0);
ffffffffc020274e:	2a049d63          	bnez	s1,ffffffffc0202a08 <swap_init+0x6b4>

     cprintf("check_swap() succeeded!\n");
ffffffffc0202752:	00004517          	auipc	a0,0x4
ffffffffc0202756:	d8650513          	addi	a0,a0,-634 # ffffffffc02064d8 <commands+0x14c0>
ffffffffc020275a:	977fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc020275e:	b199                	j	ffffffffc02023a4 <swap_init+0x50>
     int ret, count = 0, total = 0, i;
ffffffffc0202760:	4481                	li	s1,0
ffffffffc0202762:	4901                	li	s2,0
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202764:	4981                	li	s3,0
ffffffffc0202766:	b96d                	j	ffffffffc0202420 <swap_init+0xcc>
        assert(PageProperty(p));
ffffffffc0202768:	00004697          	auipc	a3,0x4
ffffffffc020276c:	b2068693          	addi	a3,a3,-1248 # ffffffffc0206288 <commands+0x1270>
ffffffffc0202770:	00003617          	auipc	a2,0x3
ffffffffc0202774:	24060613          	addi	a2,a2,576 # ffffffffc02059b0 <commands+0x998>
ffffffffc0202778:	0bd00593          	li	a1,189
ffffffffc020277c:	00004517          	auipc	a0,0x4
ffffffffc0202780:	ae450513          	addi	a0,a0,-1308 # ffffffffc0206260 <commands+0x1248>
ffffffffc0202784:	a51fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0202788:	00003617          	auipc	a2,0x3
ffffffffc020278c:	10860613          	addi	a2,a2,264 # ffffffffc0205890 <commands+0x878>
ffffffffc0202790:	06200593          	li	a1,98
ffffffffc0202794:	00003517          	auipc	a0,0x3
ffffffffc0202798:	11c50513          	addi	a0,a0,284 # ffffffffc02058b0 <commands+0x898>
ffffffffc020279c:	a39fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc02027a0:	00004697          	auipc	a3,0x4
ffffffffc02027a4:	cc068693          	addi	a3,a3,-832 # ffffffffc0206460 <commands+0x1448>
ffffffffc02027a8:	00003617          	auipc	a2,0x3
ffffffffc02027ac:	20860613          	addi	a2,a2,520 # ffffffffc02059b0 <commands+0x998>
ffffffffc02027b0:	0fd00593          	li	a1,253
ffffffffc02027b4:	00004517          	auipc	a0,0x4
ffffffffc02027b8:	aac50513          	addi	a0,a0,-1364 # ffffffffc0206260 <commands+0x1248>
ffffffffc02027bc:	a19fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc02027c0:	00003617          	auipc	a2,0x3
ffffffffc02027c4:	2c860613          	addi	a2,a2,712 # ffffffffc0205a88 <commands+0xa70>
ffffffffc02027c8:	07400593          	li	a1,116
ffffffffc02027cc:	00003517          	auipc	a0,0x3
ffffffffc02027d0:	0e450513          	addi	a0,a0,228 # ffffffffc02058b0 <commands+0x898>
ffffffffc02027d4:	a01fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc02027d8:	00004697          	auipc	a3,0x4
ffffffffc02027dc:	bb068693          	addi	a3,a3,-1104 # ffffffffc0206388 <commands+0x1370>
ffffffffc02027e0:	00003617          	auipc	a2,0x3
ffffffffc02027e4:	1d060613          	addi	a2,a2,464 # ffffffffc02059b0 <commands+0x998>
ffffffffc02027e8:	0de00593          	li	a1,222
ffffffffc02027ec:	00004517          	auipc	a0,0x4
ffffffffc02027f0:	a7450513          	addi	a0,a0,-1420 # ffffffffc0206260 <commands+0x1248>
ffffffffc02027f4:	9e1fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc02027f8:	00004697          	auipc	a3,0x4
ffffffffc02027fc:	b7868693          	addi	a3,a3,-1160 # ffffffffc0206370 <commands+0x1358>
ffffffffc0202800:	00003617          	auipc	a2,0x3
ffffffffc0202804:	1b060613          	addi	a2,a2,432 # ffffffffc02059b0 <commands+0x998>
ffffffffc0202808:	0dd00593          	li	a1,221
ffffffffc020280c:	00004517          	auipc	a0,0x4
ffffffffc0202810:	a5450513          	addi	a0,a0,-1452 # ffffffffc0206260 <commands+0x1248>
ffffffffc0202814:	9c1fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc0202818:	00004697          	auipc	a3,0x4
ffffffffc020281c:	c3068693          	addi	a3,a3,-976 # ffffffffc0206448 <commands+0x1430>
ffffffffc0202820:	00003617          	auipc	a2,0x3
ffffffffc0202824:	19060613          	addi	a2,a2,400 # ffffffffc02059b0 <commands+0x998>
ffffffffc0202828:	0fc00593          	li	a1,252
ffffffffc020282c:	00004517          	auipc	a0,0x4
ffffffffc0202830:	a3450513          	addi	a0,a0,-1484 # ffffffffc0206260 <commands+0x1248>
ffffffffc0202834:	9a1fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc0202838:	00004617          	auipc	a2,0x4
ffffffffc020283c:	a0860613          	addi	a2,a2,-1528 # ffffffffc0206240 <commands+0x1228>
ffffffffc0202840:	02a00593          	li	a1,42
ffffffffc0202844:	00004517          	auipc	a0,0x4
ffffffffc0202848:	a1c50513          	addi	a0,a0,-1508 # ffffffffc0206260 <commands+0x1248>
ffffffffc020284c:	989fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
     assert(pgfault_num==2);
ffffffffc0202850:	00004697          	auipc	a3,0x4
ffffffffc0202854:	bb868693          	addi	a3,a3,-1096 # ffffffffc0206408 <commands+0x13f0>
ffffffffc0202858:	00003617          	auipc	a2,0x3
ffffffffc020285c:	15860613          	addi	a2,a2,344 # ffffffffc02059b0 <commands+0x998>
ffffffffc0202860:	09800593          	li	a1,152
ffffffffc0202864:	00004517          	auipc	a0,0x4
ffffffffc0202868:	9fc50513          	addi	a0,a0,-1540 # ffffffffc0206260 <commands+0x1248>
ffffffffc020286c:	969fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
     assert(pgfault_num==2);
ffffffffc0202870:	00004697          	auipc	a3,0x4
ffffffffc0202874:	b9868693          	addi	a3,a3,-1128 # ffffffffc0206408 <commands+0x13f0>
ffffffffc0202878:	00003617          	auipc	a2,0x3
ffffffffc020287c:	13860613          	addi	a2,a2,312 # ffffffffc02059b0 <commands+0x998>
ffffffffc0202880:	09a00593          	li	a1,154
ffffffffc0202884:	00004517          	auipc	a0,0x4
ffffffffc0202888:	9dc50513          	addi	a0,a0,-1572 # ffffffffc0206260 <commands+0x1248>
ffffffffc020288c:	949fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
     assert(pgfault_num==3);
ffffffffc0202890:	00004697          	auipc	a3,0x4
ffffffffc0202894:	b8868693          	addi	a3,a3,-1144 # ffffffffc0206418 <commands+0x1400>
ffffffffc0202898:	00003617          	auipc	a2,0x3
ffffffffc020289c:	11860613          	addi	a2,a2,280 # ffffffffc02059b0 <commands+0x998>
ffffffffc02028a0:	09c00593          	li	a1,156
ffffffffc02028a4:	00004517          	auipc	a0,0x4
ffffffffc02028a8:	9bc50513          	addi	a0,a0,-1604 # ffffffffc0206260 <commands+0x1248>
ffffffffc02028ac:	929fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
     assert(pgfault_num==3);
ffffffffc02028b0:	00004697          	auipc	a3,0x4
ffffffffc02028b4:	b6868693          	addi	a3,a3,-1176 # ffffffffc0206418 <commands+0x1400>
ffffffffc02028b8:	00003617          	auipc	a2,0x3
ffffffffc02028bc:	0f860613          	addi	a2,a2,248 # ffffffffc02059b0 <commands+0x998>
ffffffffc02028c0:	09e00593          	li	a1,158
ffffffffc02028c4:	00004517          	auipc	a0,0x4
ffffffffc02028c8:	99c50513          	addi	a0,a0,-1636 # ffffffffc0206260 <commands+0x1248>
ffffffffc02028cc:	909fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
     assert(pgfault_num==1);
ffffffffc02028d0:	00004697          	auipc	a3,0x4
ffffffffc02028d4:	b2868693          	addi	a3,a3,-1240 # ffffffffc02063f8 <commands+0x13e0>
ffffffffc02028d8:	00003617          	auipc	a2,0x3
ffffffffc02028dc:	0d860613          	addi	a2,a2,216 # ffffffffc02059b0 <commands+0x998>
ffffffffc02028e0:	09400593          	li	a1,148
ffffffffc02028e4:	00004517          	auipc	a0,0x4
ffffffffc02028e8:	97c50513          	addi	a0,a0,-1668 # ffffffffc0206260 <commands+0x1248>
ffffffffc02028ec:	8e9fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
     assert(pgfault_num==1);
ffffffffc02028f0:	00004697          	auipc	a3,0x4
ffffffffc02028f4:	b0868693          	addi	a3,a3,-1272 # ffffffffc02063f8 <commands+0x13e0>
ffffffffc02028f8:	00003617          	auipc	a2,0x3
ffffffffc02028fc:	0b860613          	addi	a2,a2,184 # ffffffffc02059b0 <commands+0x998>
ffffffffc0202900:	09600593          	li	a1,150
ffffffffc0202904:	00004517          	auipc	a0,0x4
ffffffffc0202908:	95c50513          	addi	a0,a0,-1700 # ffffffffc0206260 <commands+0x1248>
ffffffffc020290c:	8c9fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
     assert(pgfault_num==4);
ffffffffc0202910:	00004697          	auipc	a3,0x4
ffffffffc0202914:	b1868693          	addi	a3,a3,-1256 # ffffffffc0206428 <commands+0x1410>
ffffffffc0202918:	00003617          	auipc	a2,0x3
ffffffffc020291c:	09860613          	addi	a2,a2,152 # ffffffffc02059b0 <commands+0x998>
ffffffffc0202920:	0a000593          	li	a1,160
ffffffffc0202924:	00004517          	auipc	a0,0x4
ffffffffc0202928:	93c50513          	addi	a0,a0,-1732 # ffffffffc0206260 <commands+0x1248>
ffffffffc020292c:	8a9fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
     assert(pgfault_num==4);
ffffffffc0202930:	00004697          	auipc	a3,0x4
ffffffffc0202934:	af868693          	addi	a3,a3,-1288 # ffffffffc0206428 <commands+0x1410>
ffffffffc0202938:	00003617          	auipc	a2,0x3
ffffffffc020293c:	07860613          	addi	a2,a2,120 # ffffffffc02059b0 <commands+0x998>
ffffffffc0202940:	0a200593          	li	a1,162
ffffffffc0202944:	00004517          	auipc	a0,0x4
ffffffffc0202948:	91c50513          	addi	a0,a0,-1764 # ffffffffc0206260 <commands+0x1248>
ffffffffc020294c:	889fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0202950:	00003697          	auipc	a3,0x3
ffffffffc0202954:	7f068693          	addi	a3,a3,2032 # ffffffffc0206140 <commands+0x1128>
ffffffffc0202958:	00003617          	auipc	a2,0x3
ffffffffc020295c:	05860613          	addi	a2,a2,88 # ffffffffc02059b0 <commands+0x998>
ffffffffc0202960:	0cd00593          	li	a1,205
ffffffffc0202964:	00004517          	auipc	a0,0x4
ffffffffc0202968:	8fc50513          	addi	a0,a0,-1796 # ffffffffc0206260 <commands+0x1248>
ffffffffc020296c:	869fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
     assert(vma != NULL);
ffffffffc0202970:	00004697          	auipc	a3,0x4
ffffffffc0202974:	87068693          	addi	a3,a3,-1936 # ffffffffc02061e0 <commands+0x11c8>
ffffffffc0202978:	00003617          	auipc	a2,0x3
ffffffffc020297c:	03860613          	addi	a2,a2,56 # ffffffffc02059b0 <commands+0x998>
ffffffffc0202980:	0d000593          	li	a1,208
ffffffffc0202984:	00004517          	auipc	a0,0x4
ffffffffc0202988:	8dc50513          	addi	a0,a0,-1828 # ffffffffc0206260 <commands+0x1248>
ffffffffc020298c:	849fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc0202990:	00004697          	auipc	a3,0x4
ffffffffc0202994:	9a068693          	addi	a3,a3,-1632 # ffffffffc0206330 <commands+0x1318>
ffffffffc0202998:	00003617          	auipc	a2,0x3
ffffffffc020299c:	01860613          	addi	a2,a2,24 # ffffffffc02059b0 <commands+0x998>
ffffffffc02029a0:	0d800593          	li	a1,216
ffffffffc02029a4:	00004517          	auipc	a0,0x4
ffffffffc02029a8:	8bc50513          	addi	a0,a0,-1860 # ffffffffc0206260 <commands+0x1248>
ffffffffc02029ac:	829fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
     assert( nr_free == 0);         
ffffffffc02029b0:	00004697          	auipc	a3,0x4
ffffffffc02029b4:	a8868693          	addi	a3,a3,-1400 # ffffffffc0206438 <commands+0x1420>
ffffffffc02029b8:	00003617          	auipc	a2,0x3
ffffffffc02029bc:	ff860613          	addi	a2,a2,-8 # ffffffffc02059b0 <commands+0x998>
ffffffffc02029c0:	0f400593          	li	a1,244
ffffffffc02029c4:	00004517          	auipc	a0,0x4
ffffffffc02029c8:	89c50513          	addi	a0,a0,-1892 # ffffffffc0206260 <commands+0x1248>
ffffffffc02029cc:	809fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
    return KADDR(page2pa(page));
ffffffffc02029d0:	00003617          	auipc	a2,0x3
ffffffffc02029d4:	e8860613          	addi	a2,a2,-376 # ffffffffc0205858 <commands+0x840>
ffffffffc02029d8:	06900593          	li	a1,105
ffffffffc02029dc:	00003517          	auipc	a0,0x3
ffffffffc02029e0:	ed450513          	addi	a0,a0,-300 # ffffffffc02058b0 <commands+0x898>
ffffffffc02029e4:	ff0fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
     assert(count==0);
ffffffffc02029e8:	00004697          	auipc	a3,0x4
ffffffffc02029ec:	ad068693          	addi	a3,a3,-1328 # ffffffffc02064b8 <commands+0x14a0>
ffffffffc02029f0:	00003617          	auipc	a2,0x3
ffffffffc02029f4:	fc060613          	addi	a2,a2,-64 # ffffffffc02059b0 <commands+0x998>
ffffffffc02029f8:	11c00593          	li	a1,284
ffffffffc02029fc:	00004517          	auipc	a0,0x4
ffffffffc0202a00:	86450513          	addi	a0,a0,-1948 # ffffffffc0206260 <commands+0x1248>
ffffffffc0202a04:	fd0fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
     assert(total==0);
ffffffffc0202a08:	00004697          	auipc	a3,0x4
ffffffffc0202a0c:	ac068693          	addi	a3,a3,-1344 # ffffffffc02064c8 <commands+0x14b0>
ffffffffc0202a10:	00003617          	auipc	a2,0x3
ffffffffc0202a14:	fa060613          	addi	a2,a2,-96 # ffffffffc02059b0 <commands+0x998>
ffffffffc0202a18:	11d00593          	li	a1,285
ffffffffc0202a1c:	00004517          	auipc	a0,0x4
ffffffffc0202a20:	84450513          	addi	a0,a0,-1980 # ffffffffc0206260 <commands+0x1248>
ffffffffc0202a24:	fb0fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0202a28:	00004697          	auipc	a3,0x4
ffffffffc0202a2c:	98068693          	addi	a3,a3,-1664 # ffffffffc02063a8 <commands+0x1390>
ffffffffc0202a30:	00003617          	auipc	a2,0x3
ffffffffc0202a34:	f8060613          	addi	a2,a2,-128 # ffffffffc02059b0 <commands+0x998>
ffffffffc0202a38:	0eb00593          	li	a1,235
ffffffffc0202a3c:	00004517          	auipc	a0,0x4
ffffffffc0202a40:	82450513          	addi	a0,a0,-2012 # ffffffffc0206260 <commands+0x1248>
ffffffffc0202a44:	f90fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
     assert(mm != NULL);
ffffffffc0202a48:	00003697          	auipc	a3,0x3
ffffffffc0202a4c:	57068693          	addi	a3,a3,1392 # ffffffffc0205fb8 <commands+0xfa0>
ffffffffc0202a50:	00003617          	auipc	a2,0x3
ffffffffc0202a54:	f6060613          	addi	a2,a2,-160 # ffffffffc02059b0 <commands+0x998>
ffffffffc0202a58:	0c500593          	li	a1,197
ffffffffc0202a5c:	00004517          	auipc	a0,0x4
ffffffffc0202a60:	80450513          	addi	a0,a0,-2044 # ffffffffc0206260 <commands+0x1248>
ffffffffc0202a64:	f70fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0202a68:	00004697          	auipc	a3,0x4
ffffffffc0202a6c:	87868693          	addi	a3,a3,-1928 # ffffffffc02062e0 <commands+0x12c8>
ffffffffc0202a70:	00003617          	auipc	a2,0x3
ffffffffc0202a74:	f4060613          	addi	a2,a2,-192 # ffffffffc02059b0 <commands+0x998>
ffffffffc0202a78:	0c800593          	li	a1,200
ffffffffc0202a7c:	00003517          	auipc	a0,0x3
ffffffffc0202a80:	7e450513          	addi	a0,a0,2020 # ffffffffc0206260 <commands+0x1248>
ffffffffc0202a84:	f50fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
     assert(ret==0);
ffffffffc0202a88:	00004697          	auipc	a3,0x4
ffffffffc0202a8c:	a2868693          	addi	a3,a3,-1496 # ffffffffc02064b0 <commands+0x1498>
ffffffffc0202a90:	00003617          	auipc	a2,0x3
ffffffffc0202a94:	f2060613          	addi	a2,a2,-224 # ffffffffc02059b0 <commands+0x998>
ffffffffc0202a98:	10300593          	li	a1,259
ffffffffc0202a9c:	00003517          	auipc	a0,0x3
ffffffffc0202aa0:	7c450513          	addi	a0,a0,1988 # ffffffffc0206260 <commands+0x1248>
ffffffffc0202aa4:	f30fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
     assert(total == nr_free_pages());
ffffffffc0202aa8:	00003697          	auipc	a3,0x3
ffffffffc0202aac:	7f068693          	addi	a3,a3,2032 # ffffffffc0206298 <commands+0x1280>
ffffffffc0202ab0:	00003617          	auipc	a2,0x3
ffffffffc0202ab4:	f0060613          	addi	a2,a2,-256 # ffffffffc02059b0 <commands+0x998>
ffffffffc0202ab8:	0c000593          	li	a1,192
ffffffffc0202abc:	00003517          	auipc	a0,0x3
ffffffffc0202ac0:	7a450513          	addi	a0,a0,1956 # ffffffffc0206260 <commands+0x1248>
ffffffffc0202ac4:	f10fd0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc0202ac8 <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0202ac8:	00013797          	auipc	a5,0x13
ffffffffc0202acc:	9d078793          	addi	a5,a5,-1584 # ffffffffc0215498 <sm>
ffffffffc0202ad0:	639c                	ld	a5,0(a5)
ffffffffc0202ad2:	0107b303          	ld	t1,16(a5)
ffffffffc0202ad6:	8302                	jr	t1

ffffffffc0202ad8 <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0202ad8:	00013797          	auipc	a5,0x13
ffffffffc0202adc:	9c078793          	addi	a5,a5,-1600 # ffffffffc0215498 <sm>
ffffffffc0202ae0:	639c                	ld	a5,0(a5)
ffffffffc0202ae2:	0207b303          	ld	t1,32(a5)
ffffffffc0202ae6:	8302                	jr	t1

ffffffffc0202ae8 <swap_out>:
{
ffffffffc0202ae8:	711d                	addi	sp,sp,-96
ffffffffc0202aea:	ec86                	sd	ra,88(sp)
ffffffffc0202aec:	e8a2                	sd	s0,80(sp)
ffffffffc0202aee:	e4a6                	sd	s1,72(sp)
ffffffffc0202af0:	e0ca                	sd	s2,64(sp)
ffffffffc0202af2:	fc4e                	sd	s3,56(sp)
ffffffffc0202af4:	f852                	sd	s4,48(sp)
ffffffffc0202af6:	f456                	sd	s5,40(sp)
ffffffffc0202af8:	f05a                	sd	s6,32(sp)
ffffffffc0202afa:	ec5e                	sd	s7,24(sp)
ffffffffc0202afc:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc0202afe:	cde9                	beqz	a1,ffffffffc0202bd8 <swap_out+0xf0>
ffffffffc0202b00:	8ab2                	mv	s5,a2
ffffffffc0202b02:	892a                	mv	s2,a0
ffffffffc0202b04:	8a2e                	mv	s4,a1
ffffffffc0202b06:	4401                	li	s0,0
ffffffffc0202b08:	00013997          	auipc	s3,0x13
ffffffffc0202b0c:	99098993          	addi	s3,s3,-1648 # ffffffffc0215498 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202b10:	00004b17          	auipc	s6,0x4
ffffffffc0202b14:	a48b0b13          	addi	s6,s6,-1464 # ffffffffc0206558 <commands+0x1540>
                    cprintf("SWAP: failed to save\n");
ffffffffc0202b18:	00004b97          	auipc	s7,0x4
ffffffffc0202b1c:	a28b8b93          	addi	s7,s7,-1496 # ffffffffc0206540 <commands+0x1528>
ffffffffc0202b20:	a825                	j	ffffffffc0202b58 <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202b22:	67a2                	ld	a5,8(sp)
ffffffffc0202b24:	8626                	mv	a2,s1
ffffffffc0202b26:	85a2                	mv	a1,s0
ffffffffc0202b28:	7f94                	ld	a3,56(a5)
ffffffffc0202b2a:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0202b2c:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202b2e:	82b1                	srli	a3,a3,0xc
ffffffffc0202b30:	0685                	addi	a3,a3,1
ffffffffc0202b32:	d9efd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0202b36:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0202b38:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0202b3a:	7d1c                	ld	a5,56(a0)
ffffffffc0202b3c:	83b1                	srli	a5,a5,0xc
ffffffffc0202b3e:	0785                	addi	a5,a5,1
ffffffffc0202b40:	07a2                	slli	a5,a5,0x8
ffffffffc0202b42:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc0202b46:	8e8fe0ef          	jal	ra,ffffffffc0200c2e <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0202b4a:	01893503          	ld	a0,24(s2)
ffffffffc0202b4e:	85a6                	mv	a1,s1
ffffffffc0202b50:	f47fe0ef          	jal	ra,ffffffffc0201a96 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0202b54:	048a0d63          	beq	s4,s0,ffffffffc0202bae <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0202b58:	0009b783          	ld	a5,0(s3)
ffffffffc0202b5c:	8656                	mv	a2,s5
ffffffffc0202b5e:	002c                	addi	a1,sp,8
ffffffffc0202b60:	7b9c                	ld	a5,48(a5)
ffffffffc0202b62:	854a                	mv	a0,s2
ffffffffc0202b64:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0202b66:	e12d                	bnez	a0,ffffffffc0202bc8 <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0202b68:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202b6a:	01893503          	ld	a0,24(s2)
ffffffffc0202b6e:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0202b70:	7f84                	ld	s1,56(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202b72:	85a6                	mv	a1,s1
ffffffffc0202b74:	940fe0ef          	jal	ra,ffffffffc0200cb4 <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0202b78:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202b7a:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0202b7c:	8b85                	andi	a5,a5,1
ffffffffc0202b7e:	cfb9                	beqz	a5,ffffffffc0202bdc <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0202b80:	65a2                	ld	a1,8(sp)
ffffffffc0202b82:	7d9c                	ld	a5,56(a1)
ffffffffc0202b84:	83b1                	srli	a5,a5,0xc
ffffffffc0202b86:	00178513          	addi	a0,a5,1
ffffffffc0202b8a:	0522                	slli	a0,a0,0x8
ffffffffc0202b8c:	56c010ef          	jal	ra,ffffffffc02040f8 <swapfs_write>
ffffffffc0202b90:	d949                	beqz	a0,ffffffffc0202b22 <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0202b92:	855e                	mv	a0,s7
ffffffffc0202b94:	d3cfd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0202b98:	0009b783          	ld	a5,0(s3)
ffffffffc0202b9c:	6622                	ld	a2,8(sp)
ffffffffc0202b9e:	4681                	li	a3,0
ffffffffc0202ba0:	739c                	ld	a5,32(a5)
ffffffffc0202ba2:	85a6                	mv	a1,s1
ffffffffc0202ba4:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0202ba6:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0202ba8:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0202baa:	fa8a17e3          	bne	s4,s0,ffffffffc0202b58 <swap_out+0x70>
}
ffffffffc0202bae:	8522                	mv	a0,s0
ffffffffc0202bb0:	60e6                	ld	ra,88(sp)
ffffffffc0202bb2:	6446                	ld	s0,80(sp)
ffffffffc0202bb4:	64a6                	ld	s1,72(sp)
ffffffffc0202bb6:	6906                	ld	s2,64(sp)
ffffffffc0202bb8:	79e2                	ld	s3,56(sp)
ffffffffc0202bba:	7a42                	ld	s4,48(sp)
ffffffffc0202bbc:	7aa2                	ld	s5,40(sp)
ffffffffc0202bbe:	7b02                	ld	s6,32(sp)
ffffffffc0202bc0:	6be2                	ld	s7,24(sp)
ffffffffc0202bc2:	6c42                	ld	s8,16(sp)
ffffffffc0202bc4:	6125                	addi	sp,sp,96
ffffffffc0202bc6:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc0202bc8:	85a2                	mv	a1,s0
ffffffffc0202bca:	00004517          	auipc	a0,0x4
ffffffffc0202bce:	92e50513          	addi	a0,a0,-1746 # ffffffffc02064f8 <commands+0x14e0>
ffffffffc0202bd2:	cfefd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
                  break;
ffffffffc0202bd6:	bfe1                	j	ffffffffc0202bae <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc0202bd8:	4401                	li	s0,0
ffffffffc0202bda:	bfd1                	j	ffffffffc0202bae <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0202bdc:	00004697          	auipc	a3,0x4
ffffffffc0202be0:	94c68693          	addi	a3,a3,-1716 # ffffffffc0206528 <commands+0x1510>
ffffffffc0202be4:	00003617          	auipc	a2,0x3
ffffffffc0202be8:	dcc60613          	addi	a2,a2,-564 # ffffffffc02059b0 <commands+0x998>
ffffffffc0202bec:	06900593          	li	a1,105
ffffffffc0202bf0:	00003517          	auipc	a0,0x3
ffffffffc0202bf4:	67050513          	addi	a0,a0,1648 # ffffffffc0206260 <commands+0x1248>
ffffffffc0202bf8:	ddcfd0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc0202bfc <swap_in>:
{
ffffffffc0202bfc:	7179                	addi	sp,sp,-48
ffffffffc0202bfe:	e84a                	sd	s2,16(sp)
ffffffffc0202c00:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc0202c02:	4505                	li	a0,1
{
ffffffffc0202c04:	ec26                	sd	s1,24(sp)
ffffffffc0202c06:	e44e                	sd	s3,8(sp)
ffffffffc0202c08:	f406                	sd	ra,40(sp)
ffffffffc0202c0a:	f022                	sd	s0,32(sp)
ffffffffc0202c0c:	84ae                	mv	s1,a1
ffffffffc0202c0e:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc0202c10:	f97fd0ef          	jal	ra,ffffffffc0200ba6 <alloc_pages>
     assert(result!=NULL);
ffffffffc0202c14:	c129                	beqz	a0,ffffffffc0202c56 <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc0202c16:	842a                	mv	s0,a0
ffffffffc0202c18:	01893503          	ld	a0,24(s2)
ffffffffc0202c1c:	4601                	li	a2,0
ffffffffc0202c1e:	85a6                	mv	a1,s1
ffffffffc0202c20:	894fe0ef          	jal	ra,ffffffffc0200cb4 <get_pte>
ffffffffc0202c24:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc0202c26:	6108                	ld	a0,0(a0)
ffffffffc0202c28:	85a2                	mv	a1,s0
ffffffffc0202c2a:	436010ef          	jal	ra,ffffffffc0204060 <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc0202c2e:	00093583          	ld	a1,0(s2)
ffffffffc0202c32:	8626                	mv	a2,s1
ffffffffc0202c34:	00003517          	auipc	a0,0x3
ffffffffc0202c38:	5cc50513          	addi	a0,a0,1484 # ffffffffc0206200 <commands+0x11e8>
ffffffffc0202c3c:	81a1                	srli	a1,a1,0x8
ffffffffc0202c3e:	c92fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
}
ffffffffc0202c42:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc0202c44:	0089b023          	sd	s0,0(s3)
}
ffffffffc0202c48:	7402                	ld	s0,32(sp)
ffffffffc0202c4a:	64e2                	ld	s1,24(sp)
ffffffffc0202c4c:	6942                	ld	s2,16(sp)
ffffffffc0202c4e:	69a2                	ld	s3,8(sp)
ffffffffc0202c50:	4501                	li	a0,0
ffffffffc0202c52:	6145                	addi	sp,sp,48
ffffffffc0202c54:	8082                	ret
     assert(result!=NULL);
ffffffffc0202c56:	00003697          	auipc	a3,0x3
ffffffffc0202c5a:	59a68693          	addi	a3,a3,1434 # ffffffffc02061f0 <commands+0x11d8>
ffffffffc0202c5e:	00003617          	auipc	a2,0x3
ffffffffc0202c62:	d5260613          	addi	a2,a2,-686 # ffffffffc02059b0 <commands+0x998>
ffffffffc0202c66:	07f00593          	li	a1,127
ffffffffc0202c6a:	00003517          	auipc	a0,0x3
ffffffffc0202c6e:	5f650513          	addi	a0,a0,1526 # ffffffffc0206260 <commands+0x1248>
ffffffffc0202c72:	d62fd0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc0202c76 <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc0202c76:	c125                	beqz	a0,ffffffffc0202cd6 <slob_free+0x60>
		return;

	if (size)
ffffffffc0202c78:	e1a5                	bnez	a1,ffffffffc0202cd8 <slob_free+0x62>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202c7a:	100027f3          	csrr	a5,sstatus
ffffffffc0202c7e:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0202c80:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202c82:	e3bd                	bnez	a5,ffffffffc0202ce8 <slob_free+0x72>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0202c84:	00007797          	auipc	a5,0x7
ffffffffc0202c88:	3cc78793          	addi	a5,a5,972 # ffffffffc020a050 <slobfree>
ffffffffc0202c8c:	639c                	ld	a5,0(a5)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0202c8e:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0202c90:	00a7fa63          	bgeu	a5,a0,ffffffffc0202ca4 <slob_free+0x2e>
ffffffffc0202c94:	00e56c63          	bltu	a0,a4,ffffffffc0202cac <slob_free+0x36>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0202c98:	00e7fa63          	bgeu	a5,a4,ffffffffc0202cac <slob_free+0x36>
    return 0;
ffffffffc0202c9c:	87ba                	mv	a5,a4
ffffffffc0202c9e:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0202ca0:	fea7eae3          	bltu	a5,a0,ffffffffc0202c94 <slob_free+0x1e>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0202ca4:	fee7ece3          	bltu	a5,a4,ffffffffc0202c9c <slob_free+0x26>
ffffffffc0202ca8:	fee57ae3          	bgeu	a0,a4,ffffffffc0202c9c <slob_free+0x26>
			break;

	if (b + b->units == cur->next) {
ffffffffc0202cac:	4110                	lw	a2,0(a0)
ffffffffc0202cae:	00461693          	slli	a3,a2,0x4
ffffffffc0202cb2:	96aa                	add	a3,a3,a0
ffffffffc0202cb4:	08d70b63          	beq	a4,a3,ffffffffc0202d4a <slob_free+0xd4>
		b->units += cur->next->units;
		b->next = cur->next->next;
	} else
		b->next = cur->next;

	if (cur + cur->units == b) {
ffffffffc0202cb8:	4394                	lw	a3,0(a5)
		b->next = cur->next;
ffffffffc0202cba:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc0202cbc:	00469713          	slli	a4,a3,0x4
ffffffffc0202cc0:	973e                	add	a4,a4,a5
ffffffffc0202cc2:	08e50f63          	beq	a0,a4,ffffffffc0202d60 <slob_free+0xea>
		cur->units += b->units;
		cur->next = b->next;
	} else
		cur->next = b;
ffffffffc0202cc6:	e788                	sd	a0,8(a5)

	slobfree = cur;
ffffffffc0202cc8:	00007717          	auipc	a4,0x7
ffffffffc0202ccc:	38f73423          	sd	a5,904(a4) # ffffffffc020a050 <slobfree>
    if (flag) {
ffffffffc0202cd0:	c199                	beqz	a1,ffffffffc0202cd6 <slob_free+0x60>
        intr_enable();
ffffffffc0202cd2:	8fbfd06f          	j	ffffffffc02005cc <intr_enable>
ffffffffc0202cd6:	8082                	ret
		b->units = SLOB_UNITS(size);
ffffffffc0202cd8:	05bd                	addi	a1,a1,15
ffffffffc0202cda:	8191                	srli	a1,a1,0x4
ffffffffc0202cdc:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202cde:	100027f3          	csrr	a5,sstatus
ffffffffc0202ce2:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0202ce4:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202ce6:	dfd9                	beqz	a5,ffffffffc0202c84 <slob_free+0xe>
{
ffffffffc0202ce8:	1101                	addi	sp,sp,-32
ffffffffc0202cea:	e42a                	sd	a0,8(sp)
ffffffffc0202cec:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0202cee:	8e5fd0ef          	jal	ra,ffffffffc02005d2 <intr_disable>
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0202cf2:	00007797          	auipc	a5,0x7
ffffffffc0202cf6:	35e78793          	addi	a5,a5,862 # ffffffffc020a050 <slobfree>
ffffffffc0202cfa:	639c                	ld	a5,0(a5)
        return 1;
ffffffffc0202cfc:	6522                	ld	a0,8(sp)
ffffffffc0202cfe:	4585                	li	a1,1
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0202d00:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0202d02:	00a7fa63          	bgeu	a5,a0,ffffffffc0202d16 <slob_free+0xa0>
ffffffffc0202d06:	00e56c63          	bltu	a0,a4,ffffffffc0202d1e <slob_free+0xa8>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0202d0a:	00e7fa63          	bgeu	a5,a4,ffffffffc0202d1e <slob_free+0xa8>
    return 0;
ffffffffc0202d0e:	87ba                	mv	a5,a4
ffffffffc0202d10:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0202d12:	fea7eae3          	bltu	a5,a0,ffffffffc0202d06 <slob_free+0x90>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0202d16:	fee7ece3          	bltu	a5,a4,ffffffffc0202d0e <slob_free+0x98>
ffffffffc0202d1a:	fee57ae3          	bgeu	a0,a4,ffffffffc0202d0e <slob_free+0x98>
	if (b + b->units == cur->next) {
ffffffffc0202d1e:	4110                	lw	a2,0(a0)
ffffffffc0202d20:	00461693          	slli	a3,a2,0x4
ffffffffc0202d24:	96aa                	add	a3,a3,a0
ffffffffc0202d26:	04d70763          	beq	a4,a3,ffffffffc0202d74 <slob_free+0xfe>
		b->next = cur->next;
ffffffffc0202d2a:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc0202d2c:	4394                	lw	a3,0(a5)
ffffffffc0202d2e:	00469713          	slli	a4,a3,0x4
ffffffffc0202d32:	973e                	add	a4,a4,a5
ffffffffc0202d34:	04e50663          	beq	a0,a4,ffffffffc0202d80 <slob_free+0x10a>
		cur->next = b;
ffffffffc0202d38:	e788                	sd	a0,8(a5)
	slobfree = cur;
ffffffffc0202d3a:	00007717          	auipc	a4,0x7
ffffffffc0202d3e:	30f73b23          	sd	a5,790(a4) # ffffffffc020a050 <slobfree>
    if (flag) {
ffffffffc0202d42:	e58d                	bnez	a1,ffffffffc0202d6c <slob_free+0xf6>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc0202d44:	60e2                	ld	ra,24(sp)
ffffffffc0202d46:	6105                	addi	sp,sp,32
ffffffffc0202d48:	8082                	ret
		b->units += cur->next->units;
ffffffffc0202d4a:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0202d4c:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc0202d4e:	9e35                	addw	a2,a2,a3
ffffffffc0202d50:	c110                	sw	a2,0(a0)
	if (cur + cur->units == b) {
ffffffffc0202d52:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc0202d54:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc0202d56:	00469713          	slli	a4,a3,0x4
ffffffffc0202d5a:	973e                	add	a4,a4,a5
ffffffffc0202d5c:	f6e515e3          	bne	a0,a4,ffffffffc0202cc6 <slob_free+0x50>
		cur->units += b->units;
ffffffffc0202d60:	4118                	lw	a4,0(a0)
		cur->next = b->next;
ffffffffc0202d62:	6510                	ld	a2,8(a0)
		cur->units += b->units;
ffffffffc0202d64:	9eb9                	addw	a3,a3,a4
ffffffffc0202d66:	c394                	sw	a3,0(a5)
		cur->next = b->next;
ffffffffc0202d68:	e790                	sd	a2,8(a5)
ffffffffc0202d6a:	bfb9                	j	ffffffffc0202cc8 <slob_free+0x52>
}
ffffffffc0202d6c:	60e2                	ld	ra,24(sp)
ffffffffc0202d6e:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0202d70:	85dfd06f          	j	ffffffffc02005cc <intr_enable>
		b->units += cur->next->units;
ffffffffc0202d74:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0202d76:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc0202d78:	9e35                	addw	a2,a2,a3
ffffffffc0202d7a:	c110                	sw	a2,0(a0)
		b->next = cur->next->next;
ffffffffc0202d7c:	e518                	sd	a4,8(a0)
ffffffffc0202d7e:	b77d                	j	ffffffffc0202d2c <slob_free+0xb6>
		cur->units += b->units;
ffffffffc0202d80:	4118                	lw	a4,0(a0)
		cur->next = b->next;
ffffffffc0202d82:	6510                	ld	a2,8(a0)
		cur->units += b->units;
ffffffffc0202d84:	9eb9                	addw	a3,a3,a4
ffffffffc0202d86:	c394                	sw	a3,0(a5)
		cur->next = b->next;
ffffffffc0202d88:	e790                	sd	a2,8(a5)
ffffffffc0202d8a:	bf45                	j	ffffffffc0202d3a <slob_free+0xc4>

ffffffffc0202d8c <__slob_get_free_pages.isra.0>:
  struct Page * page = alloc_pages(1 << order);
ffffffffc0202d8c:	4785                	li	a5,1
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0202d8e:	1141                	addi	sp,sp,-16
  struct Page * page = alloc_pages(1 << order);
ffffffffc0202d90:	00a7953b          	sllw	a0,a5,a0
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0202d94:	e406                	sd	ra,8(sp)
  struct Page * page = alloc_pages(1 << order);
ffffffffc0202d96:	e11fd0ef          	jal	ra,ffffffffc0200ba6 <alloc_pages>
  if(!page)
ffffffffc0202d9a:	cd1d                	beqz	a0,ffffffffc0202dd8 <__slob_get_free_pages.isra.0+0x4c>
    return page - pages + nbase;
ffffffffc0202d9c:	00012797          	auipc	a5,0x12
ffffffffc0202da0:	75478793          	addi	a5,a5,1876 # ffffffffc02154f0 <pages>
ffffffffc0202da4:	6394                	ld	a3,0(a5)
ffffffffc0202da6:	00004797          	auipc	a5,0x4
ffffffffc0202daa:	23278793          	addi	a5,a5,562 # ffffffffc0206fd8 <nbase>
ffffffffc0202dae:	8d15                	sub	a0,a0,a3
ffffffffc0202db0:	6394                	ld	a3,0(a5)
ffffffffc0202db2:	8519                	srai	a0,a0,0x6
    return KADDR(page2pa(page));
ffffffffc0202db4:	00012797          	auipc	a5,0x12
ffffffffc0202db8:	6d478793          	addi	a5,a5,1748 # ffffffffc0215488 <npage>
    return page - pages + nbase;
ffffffffc0202dbc:	9536                	add	a0,a0,a3
    return KADDR(page2pa(page));
ffffffffc0202dbe:	6398                	ld	a4,0(a5)
ffffffffc0202dc0:	00c51793          	slli	a5,a0,0xc
ffffffffc0202dc4:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202dc6:	0532                	slli	a0,a0,0xc
    return KADDR(page2pa(page));
ffffffffc0202dc8:	00e7fb63          	bgeu	a5,a4,ffffffffc0202dde <__slob_get_free_pages.isra.0+0x52>
ffffffffc0202dcc:	00012797          	auipc	a5,0x12
ffffffffc0202dd0:	71478793          	addi	a5,a5,1812 # ffffffffc02154e0 <va_pa_offset>
ffffffffc0202dd4:	6394                	ld	a3,0(a5)
ffffffffc0202dd6:	9536                	add	a0,a0,a3
}
ffffffffc0202dd8:	60a2                	ld	ra,8(sp)
ffffffffc0202dda:	0141                	addi	sp,sp,16
ffffffffc0202ddc:	8082                	ret
ffffffffc0202dde:	86aa                	mv	a3,a0
ffffffffc0202de0:	00003617          	auipc	a2,0x3
ffffffffc0202de4:	a7860613          	addi	a2,a2,-1416 # ffffffffc0205858 <commands+0x840>
ffffffffc0202de8:	06900593          	li	a1,105
ffffffffc0202dec:	00003517          	auipc	a0,0x3
ffffffffc0202df0:	ac450513          	addi	a0,a0,-1340 # ffffffffc02058b0 <commands+0x898>
ffffffffc0202df4:	be0fd0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc0202df8 <slob_alloc.isra.1.constprop.3>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc0202df8:	1101                	addi	sp,sp,-32
ffffffffc0202dfa:	ec06                	sd	ra,24(sp)
ffffffffc0202dfc:	e822                	sd	s0,16(sp)
ffffffffc0202dfe:	e426                	sd	s1,8(sp)
ffffffffc0202e00:	e04a                	sd	s2,0(sp)
	assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0202e02:	01050713          	addi	a4,a0,16
ffffffffc0202e06:	6785                	lui	a5,0x1
ffffffffc0202e08:	0cf77563          	bgeu	a4,a5,ffffffffc0202ed2 <slob_alloc.isra.1.constprop.3+0xda>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc0202e0c:	00f50493          	addi	s1,a0,15
ffffffffc0202e10:	8091                	srli	s1,s1,0x4
ffffffffc0202e12:	2481                	sext.w	s1,s1
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202e14:	10002673          	csrr	a2,sstatus
ffffffffc0202e18:	8a09                	andi	a2,a2,2
ffffffffc0202e1a:	e64d                	bnez	a2,ffffffffc0202ec4 <slob_alloc.isra.1.constprop.3+0xcc>
	prev = slobfree;
ffffffffc0202e1c:	00007917          	auipc	s2,0x7
ffffffffc0202e20:	23490913          	addi	s2,s2,564 # ffffffffc020a050 <slobfree>
ffffffffc0202e24:	00093683          	ld	a3,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0202e28:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0202e2a:	4398                	lw	a4,0(a5)
ffffffffc0202e2c:	0a975063          	bge	a4,s1,ffffffffc0202ecc <slob_alloc.isra.1.constprop.3+0xd4>
		if (cur == slobfree) {
ffffffffc0202e30:	00d78b63          	beq	a5,a3,ffffffffc0202e46 <slob_alloc.isra.1.constprop.3+0x4e>
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0202e34:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0202e36:	4018                	lw	a4,0(s0)
ffffffffc0202e38:	02975a63          	bge	a4,s1,ffffffffc0202e6c <slob_alloc.isra.1.constprop.3+0x74>
ffffffffc0202e3c:	00093683          	ld	a3,0(s2)
ffffffffc0202e40:	87a2                	mv	a5,s0
		if (cur == slobfree) {
ffffffffc0202e42:	fed799e3          	bne	a5,a3,ffffffffc0202e34 <slob_alloc.isra.1.constprop.3+0x3c>
    if (flag) {
ffffffffc0202e46:	e225                	bnez	a2,ffffffffc0202ea6 <slob_alloc.isra.1.constprop.3+0xae>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0202e48:	4501                	li	a0,0
ffffffffc0202e4a:	f43ff0ef          	jal	ra,ffffffffc0202d8c <__slob_get_free_pages.isra.0>
ffffffffc0202e4e:	842a                	mv	s0,a0
			if (!cur)
ffffffffc0202e50:	cd15                	beqz	a0,ffffffffc0202e8c <slob_alloc.isra.1.constprop.3+0x94>
			slob_free(cur, PAGE_SIZE);
ffffffffc0202e52:	6585                	lui	a1,0x1
ffffffffc0202e54:	e23ff0ef          	jal	ra,ffffffffc0202c76 <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202e58:	10002673          	csrr	a2,sstatus
ffffffffc0202e5c:	8a09                	andi	a2,a2,2
ffffffffc0202e5e:	ee15                	bnez	a2,ffffffffc0202e9a <slob_alloc.isra.1.constprop.3+0xa2>
			cur = slobfree;
ffffffffc0202e60:	00093783          	ld	a5,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0202e64:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0202e66:	4018                	lw	a4,0(s0)
ffffffffc0202e68:	fc974ae3          	blt	a4,s1,ffffffffc0202e3c <slob_alloc.isra.1.constprop.3+0x44>
			if (cur->units == units) /* exact fit? */
ffffffffc0202e6c:	04e48963          	beq	s1,a4,ffffffffc0202ebe <slob_alloc.isra.1.constprop.3+0xc6>
				prev->next = cur + units;
ffffffffc0202e70:	00449693          	slli	a3,s1,0x4
ffffffffc0202e74:	96a2                	add	a3,a3,s0
ffffffffc0202e76:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc0202e78:	640c                	ld	a1,8(s0)
				prev->next->units = cur->units - units;
ffffffffc0202e7a:	9f05                	subw	a4,a4,s1
ffffffffc0202e7c:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc0202e7e:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc0202e80:	c004                	sw	s1,0(s0)
			slobfree = prev;
ffffffffc0202e82:	00007717          	auipc	a4,0x7
ffffffffc0202e86:	1cf73723          	sd	a5,462(a4) # ffffffffc020a050 <slobfree>
    if (flag) {
ffffffffc0202e8a:	e20d                	bnez	a2,ffffffffc0202eac <slob_alloc.isra.1.constprop.3+0xb4>
}
ffffffffc0202e8c:	8522                	mv	a0,s0
ffffffffc0202e8e:	60e2                	ld	ra,24(sp)
ffffffffc0202e90:	6442                	ld	s0,16(sp)
ffffffffc0202e92:	64a2                	ld	s1,8(sp)
ffffffffc0202e94:	6902                	ld	s2,0(sp)
ffffffffc0202e96:	6105                	addi	sp,sp,32
ffffffffc0202e98:	8082                	ret
        intr_disable();
ffffffffc0202e9a:	f38fd0ef          	jal	ra,ffffffffc02005d2 <intr_disable>
ffffffffc0202e9e:	4605                	li	a2,1
			cur = slobfree;
ffffffffc0202ea0:	00093783          	ld	a5,0(s2)
ffffffffc0202ea4:	b7c1                	j	ffffffffc0202e64 <slob_alloc.isra.1.constprop.3+0x6c>
        intr_enable();
ffffffffc0202ea6:	f26fd0ef          	jal	ra,ffffffffc02005cc <intr_enable>
ffffffffc0202eaa:	bf79                	j	ffffffffc0202e48 <slob_alloc.isra.1.constprop.3+0x50>
ffffffffc0202eac:	f20fd0ef          	jal	ra,ffffffffc02005cc <intr_enable>
}
ffffffffc0202eb0:	8522                	mv	a0,s0
ffffffffc0202eb2:	60e2                	ld	ra,24(sp)
ffffffffc0202eb4:	6442                	ld	s0,16(sp)
ffffffffc0202eb6:	64a2                	ld	s1,8(sp)
ffffffffc0202eb8:	6902                	ld	s2,0(sp)
ffffffffc0202eba:	6105                	addi	sp,sp,32
ffffffffc0202ebc:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc0202ebe:	6418                	ld	a4,8(s0)
ffffffffc0202ec0:	e798                	sd	a4,8(a5)
ffffffffc0202ec2:	b7c1                	j	ffffffffc0202e82 <slob_alloc.isra.1.constprop.3+0x8a>
        intr_disable();
ffffffffc0202ec4:	f0efd0ef          	jal	ra,ffffffffc02005d2 <intr_disable>
ffffffffc0202ec8:	4605                	li	a2,1
ffffffffc0202eca:	bf89                	j	ffffffffc0202e1c <slob_alloc.isra.1.constprop.3+0x24>
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0202ecc:	843e                	mv	s0,a5
ffffffffc0202ece:	87b6                	mv	a5,a3
ffffffffc0202ed0:	bf71                	j	ffffffffc0202e6c <slob_alloc.isra.1.constprop.3+0x74>
	assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0202ed2:	00003697          	auipc	a3,0x3
ffffffffc0202ed6:	6e668693          	addi	a3,a3,1766 # ffffffffc02065b8 <commands+0x15a0>
ffffffffc0202eda:	00003617          	auipc	a2,0x3
ffffffffc0202ede:	ad660613          	addi	a2,a2,-1322 # ffffffffc02059b0 <commands+0x998>
ffffffffc0202ee2:	06300593          	li	a1,99
ffffffffc0202ee6:	00003517          	auipc	a0,0x3
ffffffffc0202eea:	6f250513          	addi	a0,a0,1778 # ffffffffc02065d8 <commands+0x15c0>
ffffffffc0202eee:	ae6fd0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc0202ef2 <kmalloc_init>:
slob_init(void) {
  cprintf("use SLOB allocator\n");
}

inline void 
kmalloc_init(void) {
ffffffffc0202ef2:	1141                	addi	sp,sp,-16
  cprintf("use SLOB allocator\n");
ffffffffc0202ef4:	00003517          	auipc	a0,0x3
ffffffffc0202ef8:	6fc50513          	addi	a0,a0,1788 # ffffffffc02065f0 <commands+0x15d8>
kmalloc_init(void) {
ffffffffc0202efc:	e406                	sd	ra,8(sp)
  cprintf("use SLOB allocator\n");
ffffffffc0202efe:	9d2fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    slob_init();
    cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc0202f02:	60a2                	ld	ra,8(sp)
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0202f04:	00003517          	auipc	a0,0x3
ffffffffc0202f08:	69450513          	addi	a0,a0,1684 # ffffffffc0206598 <commands+0x1580>
}
ffffffffc0202f0c:	0141                	addi	sp,sp,16
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0202f0e:	9c2fd06f          	j	ffffffffc02000d0 <cprintf>

ffffffffc0202f12 <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc0202f12:	1101                	addi	sp,sp,-32
ffffffffc0202f14:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0202f16:	6905                	lui	s2,0x1
{
ffffffffc0202f18:	e822                	sd	s0,16(sp)
ffffffffc0202f1a:	ec06                	sd	ra,24(sp)
ffffffffc0202f1c:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0202f1e:	fef90793          	addi	a5,s2,-17 # fef <BASE_ADDRESS-0xffffffffc01ff011>
{
ffffffffc0202f22:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0202f24:	04a7fc63          	bgeu	a5,a0,ffffffffc0202f7c <kmalloc+0x6a>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc0202f28:	4561                	li	a0,24
ffffffffc0202f2a:	ecfff0ef          	jal	ra,ffffffffc0202df8 <slob_alloc.isra.1.constprop.3>
ffffffffc0202f2e:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc0202f30:	cd21                	beqz	a0,ffffffffc0202f88 <kmalloc+0x76>
	bb->order = find_order(size);
ffffffffc0202f32:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc0202f36:	4501                	li	a0,0
	for ( ; size > 4096 ; size >>=1)
ffffffffc0202f38:	00f95763          	bge	s2,a5,ffffffffc0202f46 <kmalloc+0x34>
ffffffffc0202f3c:	6705                	lui	a4,0x1
ffffffffc0202f3e:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc0202f40:	2505                	addiw	a0,a0,1
	for ( ; size > 4096 ; size >>=1)
ffffffffc0202f42:	fef74ee3          	blt	a4,a5,ffffffffc0202f3e <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc0202f46:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc0202f48:	e45ff0ef          	jal	ra,ffffffffc0202d8c <__slob_get_free_pages.isra.0>
ffffffffc0202f4c:	e488                	sd	a0,8(s1)
ffffffffc0202f4e:	842a                	mv	s0,a0
	if (bb->pages) {
ffffffffc0202f50:	c935                	beqz	a0,ffffffffc0202fc4 <kmalloc+0xb2>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202f52:	100027f3          	csrr	a5,sstatus
ffffffffc0202f56:	8b89                	andi	a5,a5,2
ffffffffc0202f58:	e3a1                	bnez	a5,ffffffffc0202f98 <kmalloc+0x86>
		bb->next = bigblocks;
ffffffffc0202f5a:	00012797          	auipc	a5,0x12
ffffffffc0202f5e:	54e78793          	addi	a5,a5,1358 # ffffffffc02154a8 <bigblocks>
ffffffffc0202f62:	639c                	ld	a5,0(a5)
		bigblocks = bb;
ffffffffc0202f64:	00012717          	auipc	a4,0x12
ffffffffc0202f68:	54973223          	sd	s1,1348(a4) # ffffffffc02154a8 <bigblocks>
		bb->next = bigblocks;
ffffffffc0202f6c:	e89c                	sd	a5,16(s1)
  return __kmalloc(size, 0);
}
ffffffffc0202f6e:	8522                	mv	a0,s0
ffffffffc0202f70:	60e2                	ld	ra,24(sp)
ffffffffc0202f72:	6442                	ld	s0,16(sp)
ffffffffc0202f74:	64a2                	ld	s1,8(sp)
ffffffffc0202f76:	6902                	ld	s2,0(sp)
ffffffffc0202f78:	6105                	addi	sp,sp,32
ffffffffc0202f7a:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc0202f7c:	0541                	addi	a0,a0,16
ffffffffc0202f7e:	e7bff0ef          	jal	ra,ffffffffc0202df8 <slob_alloc.isra.1.constprop.3>
		return m ? (void *)(m + 1) : 0;
ffffffffc0202f82:	01050413          	addi	s0,a0,16
ffffffffc0202f86:	f565                	bnez	a0,ffffffffc0202f6e <kmalloc+0x5c>
ffffffffc0202f88:	4401                	li	s0,0
}
ffffffffc0202f8a:	8522                	mv	a0,s0
ffffffffc0202f8c:	60e2                	ld	ra,24(sp)
ffffffffc0202f8e:	6442                	ld	s0,16(sp)
ffffffffc0202f90:	64a2                	ld	s1,8(sp)
ffffffffc0202f92:	6902                	ld	s2,0(sp)
ffffffffc0202f94:	6105                	addi	sp,sp,32
ffffffffc0202f96:	8082                	ret
        intr_disable();
ffffffffc0202f98:	e3afd0ef          	jal	ra,ffffffffc02005d2 <intr_disable>
		bb->next = bigblocks;
ffffffffc0202f9c:	00012797          	auipc	a5,0x12
ffffffffc0202fa0:	50c78793          	addi	a5,a5,1292 # ffffffffc02154a8 <bigblocks>
ffffffffc0202fa4:	639c                	ld	a5,0(a5)
		bigblocks = bb;
ffffffffc0202fa6:	00012717          	auipc	a4,0x12
ffffffffc0202faa:	50973123          	sd	s1,1282(a4) # ffffffffc02154a8 <bigblocks>
		bb->next = bigblocks;
ffffffffc0202fae:	e89c                	sd	a5,16(s1)
        intr_enable();
ffffffffc0202fb0:	e1cfd0ef          	jal	ra,ffffffffc02005cc <intr_enable>
ffffffffc0202fb4:	6480                	ld	s0,8(s1)
}
ffffffffc0202fb6:	60e2                	ld	ra,24(sp)
ffffffffc0202fb8:	64a2                	ld	s1,8(sp)
ffffffffc0202fba:	8522                	mv	a0,s0
ffffffffc0202fbc:	6442                	ld	s0,16(sp)
ffffffffc0202fbe:	6902                	ld	s2,0(sp)
ffffffffc0202fc0:	6105                	addi	sp,sp,32
ffffffffc0202fc2:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0202fc4:	45e1                	li	a1,24
ffffffffc0202fc6:	8526                	mv	a0,s1
ffffffffc0202fc8:	cafff0ef          	jal	ra,ffffffffc0202c76 <slob_free>
  return __kmalloc(size, 0);
ffffffffc0202fcc:	b74d                	j	ffffffffc0202f6e <kmalloc+0x5c>

ffffffffc0202fce <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc0202fce:	c175                	beqz	a0,ffffffffc02030b2 <kfree+0xe4>
{
ffffffffc0202fd0:	1101                	addi	sp,sp,-32
ffffffffc0202fd2:	e426                	sd	s1,8(sp)
ffffffffc0202fd4:	ec06                	sd	ra,24(sp)
ffffffffc0202fd6:	e822                	sd	s0,16(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
ffffffffc0202fd8:	03451793          	slli	a5,a0,0x34
ffffffffc0202fdc:	84aa                	mv	s1,a0
ffffffffc0202fde:	eb8d                	bnez	a5,ffffffffc0203010 <kfree+0x42>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202fe0:	100027f3          	csrr	a5,sstatus
ffffffffc0202fe4:	8b89                	andi	a5,a5,2
ffffffffc0202fe6:	efc9                	bnez	a5,ffffffffc0203080 <kfree+0xb2>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0202fe8:	00012797          	auipc	a5,0x12
ffffffffc0202fec:	4c078793          	addi	a5,a5,1216 # ffffffffc02154a8 <bigblocks>
ffffffffc0202ff0:	6394                	ld	a3,0(a5)
ffffffffc0202ff2:	ce99                	beqz	a3,ffffffffc0203010 <kfree+0x42>
			if (bb->pages == block) {
ffffffffc0202ff4:	669c                	ld	a5,8(a3)
ffffffffc0202ff6:	6a80                	ld	s0,16(a3)
ffffffffc0202ff8:	0af50e63          	beq	a0,a5,ffffffffc02030b4 <kfree+0xe6>
    return 0;
ffffffffc0202ffc:	4601                	li	a2,0
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0202ffe:	c801                	beqz	s0,ffffffffc020300e <kfree+0x40>
			if (bb->pages == block) {
ffffffffc0203000:	6418                	ld	a4,8(s0)
ffffffffc0203002:	681c                	ld	a5,16(s0)
ffffffffc0203004:	00970f63          	beq	a4,s1,ffffffffc0203022 <kfree+0x54>
ffffffffc0203008:	86a2                	mv	a3,s0
ffffffffc020300a:	843e                	mv	s0,a5
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc020300c:	f875                	bnez	s0,ffffffffc0203000 <kfree+0x32>
    if (flag) {
ffffffffc020300e:	e659                	bnez	a2,ffffffffc020309c <kfree+0xce>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc0203010:	6442                	ld	s0,16(sp)
ffffffffc0203012:	60e2                	ld	ra,24(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0203014:	ff048513          	addi	a0,s1,-16
}
ffffffffc0203018:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc020301a:	4581                	li	a1,0
}
ffffffffc020301c:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc020301e:	c59ff06f          	j	ffffffffc0202c76 <slob_free>
				*last = bb->next;
ffffffffc0203022:	ea9c                	sd	a5,16(a3)
ffffffffc0203024:	e641                	bnez	a2,ffffffffc02030ac <kfree+0xde>
    return pa2page(PADDR(kva));
ffffffffc0203026:	c02007b7          	lui	a5,0xc0200
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc020302a:	4018                	lw	a4,0(s0)
ffffffffc020302c:	08f4ea63          	bltu	s1,a5,ffffffffc02030c0 <kfree+0xf2>
ffffffffc0203030:	00012797          	auipc	a5,0x12
ffffffffc0203034:	4b078793          	addi	a5,a5,1200 # ffffffffc02154e0 <va_pa_offset>
ffffffffc0203038:	6394                	ld	a3,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc020303a:	00012797          	auipc	a5,0x12
ffffffffc020303e:	44e78793          	addi	a5,a5,1102 # ffffffffc0215488 <npage>
ffffffffc0203042:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc0203044:	8c95                	sub	s1,s1,a3
    if (PPN(pa) >= npage) {
ffffffffc0203046:	80b1                	srli	s1,s1,0xc
ffffffffc0203048:	08f4f963          	bgeu	s1,a5,ffffffffc02030da <kfree+0x10c>
    return &pages[PPN(pa) - nbase];
ffffffffc020304c:	00004797          	auipc	a5,0x4
ffffffffc0203050:	f8c78793          	addi	a5,a5,-116 # ffffffffc0206fd8 <nbase>
ffffffffc0203054:	639c                	ld	a5,0(a5)
ffffffffc0203056:	00012697          	auipc	a3,0x12
ffffffffc020305a:	49a68693          	addi	a3,a3,1178 # ffffffffc02154f0 <pages>
ffffffffc020305e:	6288                	ld	a0,0(a3)
ffffffffc0203060:	8c9d                	sub	s1,s1,a5
ffffffffc0203062:	049a                	slli	s1,s1,0x6
  free_pages(kva2page(kva), 1 << order);
ffffffffc0203064:	4585                	li	a1,1
ffffffffc0203066:	9526                	add	a0,a0,s1
ffffffffc0203068:	00e595bb          	sllw	a1,a1,a4
ffffffffc020306c:	bc3fd0ef          	jal	ra,ffffffffc0200c2e <free_pages>
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0203070:	8522                	mv	a0,s0
}
ffffffffc0203072:	6442                	ld	s0,16(sp)
ffffffffc0203074:	60e2                	ld	ra,24(sp)
ffffffffc0203076:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0203078:	45e1                	li	a1,24
}
ffffffffc020307a:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc020307c:	bfbff06f          	j	ffffffffc0202c76 <slob_free>
        intr_disable();
ffffffffc0203080:	d52fd0ef          	jal	ra,ffffffffc02005d2 <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0203084:	00012797          	auipc	a5,0x12
ffffffffc0203088:	42478793          	addi	a5,a5,1060 # ffffffffc02154a8 <bigblocks>
ffffffffc020308c:	6394                	ld	a3,0(a5)
ffffffffc020308e:	c699                	beqz	a3,ffffffffc020309c <kfree+0xce>
			if (bb->pages == block) {
ffffffffc0203090:	669c                	ld	a5,8(a3)
ffffffffc0203092:	6a80                	ld	s0,16(a3)
ffffffffc0203094:	00f48763          	beq	s1,a5,ffffffffc02030a2 <kfree+0xd4>
        return 1;
ffffffffc0203098:	4605                	li	a2,1
ffffffffc020309a:	b795                	j	ffffffffc0202ffe <kfree+0x30>
        intr_enable();
ffffffffc020309c:	d30fd0ef          	jal	ra,ffffffffc02005cc <intr_enable>
ffffffffc02030a0:	bf85                	j	ffffffffc0203010 <kfree+0x42>
				*last = bb->next;
ffffffffc02030a2:	00012797          	auipc	a5,0x12
ffffffffc02030a6:	4087b323          	sd	s0,1030(a5) # ffffffffc02154a8 <bigblocks>
ffffffffc02030aa:	8436                	mv	s0,a3
ffffffffc02030ac:	d20fd0ef          	jal	ra,ffffffffc02005cc <intr_enable>
ffffffffc02030b0:	bf9d                	j	ffffffffc0203026 <kfree+0x58>
ffffffffc02030b2:	8082                	ret
ffffffffc02030b4:	00012797          	auipc	a5,0x12
ffffffffc02030b8:	3e87ba23          	sd	s0,1012(a5) # ffffffffc02154a8 <bigblocks>
ffffffffc02030bc:	8436                	mv	s0,a3
ffffffffc02030be:	b7a5                	j	ffffffffc0203026 <kfree+0x58>
    return pa2page(PADDR(kva));
ffffffffc02030c0:	86a6                	mv	a3,s1
ffffffffc02030c2:	00003617          	auipc	a2,0x3
ffffffffc02030c6:	86e60613          	addi	a2,a2,-1938 # ffffffffc0205930 <commands+0x918>
ffffffffc02030ca:	06e00593          	li	a1,110
ffffffffc02030ce:	00002517          	auipc	a0,0x2
ffffffffc02030d2:	7e250513          	addi	a0,a0,2018 # ffffffffc02058b0 <commands+0x898>
ffffffffc02030d6:	8fefd0ef          	jal	ra,ffffffffc02001d4 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02030da:	00002617          	auipc	a2,0x2
ffffffffc02030de:	7b660613          	addi	a2,a2,1974 # ffffffffc0205890 <commands+0x878>
ffffffffc02030e2:	06200593          	li	a1,98
ffffffffc02030e6:	00002517          	auipc	a0,0x2
ffffffffc02030ea:	7ca50513          	addi	a0,a0,1994 # ffffffffc02058b0 <commands+0x898>
ffffffffc02030ee:	8e6fd0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc02030f2 <_fifo_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc02030f2:	00012797          	auipc	a5,0x12
ffffffffc02030f6:	4d678793          	addi	a5,a5,1238 # ffffffffc02155c8 <pra_list_head>
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
ffffffffc02030fa:	f51c                	sd	a5,40(a0)
ffffffffc02030fc:	e79c                	sd	a5,8(a5)
ffffffffc02030fe:	e39c                	sd	a5,0(a5)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc0203100:	4501                	li	a0,0
ffffffffc0203102:	8082                	ret

ffffffffc0203104 <_fifo_init>:

static int
_fifo_init(void)
{
    return 0;
}
ffffffffc0203104:	4501                	li	a0,0
ffffffffc0203106:	8082                	ret

ffffffffc0203108 <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc0203108:	4501                	li	a0,0
ffffffffc020310a:	8082                	ret

ffffffffc020310c <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc020310c:	4501                	li	a0,0
ffffffffc020310e:	8082                	ret

ffffffffc0203110 <_fifo_check_swap>:
_fifo_check_swap(void) {
ffffffffc0203110:	711d                	addi	sp,sp,-96
ffffffffc0203112:	fc4e                	sd	s3,56(sp)
ffffffffc0203114:	f852                	sd	s4,48(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203116:	00003517          	auipc	a0,0x3
ffffffffc020311a:	4f250513          	addi	a0,a0,1266 # ffffffffc0206608 <commands+0x15f0>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc020311e:	698d                	lui	s3,0x3
ffffffffc0203120:	4a31                	li	s4,12
_fifo_check_swap(void) {
ffffffffc0203122:	e8a2                	sd	s0,80(sp)
ffffffffc0203124:	e4a6                	sd	s1,72(sp)
ffffffffc0203126:	ec86                	sd	ra,88(sp)
ffffffffc0203128:	e0ca                	sd	s2,64(sp)
ffffffffc020312a:	f456                	sd	s5,40(sp)
ffffffffc020312c:	f05a                	sd	s6,32(sp)
ffffffffc020312e:	ec5e                	sd	s7,24(sp)
ffffffffc0203130:	e862                	sd	s8,16(sp)
ffffffffc0203132:	e466                	sd	s9,8(sp)
    assert(pgfault_num==4);
ffffffffc0203134:	00012417          	auipc	s0,0x12
ffffffffc0203138:	35c40413          	addi	s0,s0,860 # ffffffffc0215490 <pgfault_num>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc020313c:	f95fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203140:	01498023          	sb	s4,0(s3) # 3000 <BASE_ADDRESS-0xffffffffc01fd000>
    assert(pgfault_num==4);
ffffffffc0203144:	4004                	lw	s1,0(s0)
ffffffffc0203146:	4791                	li	a5,4
ffffffffc0203148:	2481                	sext.w	s1,s1
ffffffffc020314a:	14f49963          	bne	s1,a5,ffffffffc020329c <_fifo_check_swap+0x18c>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc020314e:	00003517          	auipc	a0,0x3
ffffffffc0203152:	4fa50513          	addi	a0,a0,1274 # ffffffffc0206648 <commands+0x1630>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203156:	6a85                	lui	s5,0x1
ffffffffc0203158:	4b29                	li	s6,10
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc020315a:	f77fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc020315e:	016a8023          	sb	s6,0(s5) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
    assert(pgfault_num==4);
ffffffffc0203162:	00042903          	lw	s2,0(s0)
ffffffffc0203166:	2901                	sext.w	s2,s2
ffffffffc0203168:	2a991a63          	bne	s2,s1,ffffffffc020341c <_fifo_check_swap+0x30c>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc020316c:	00003517          	auipc	a0,0x3
ffffffffc0203170:	50450513          	addi	a0,a0,1284 # ffffffffc0206670 <commands+0x1658>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203174:	6b91                	lui	s7,0x4
ffffffffc0203176:	4c35                	li	s8,13
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203178:	f59fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc020317c:	018b8023          	sb	s8,0(s7) # 4000 <BASE_ADDRESS-0xffffffffc01fc000>
    assert(pgfault_num==4);
ffffffffc0203180:	4004                	lw	s1,0(s0)
ffffffffc0203182:	2481                	sext.w	s1,s1
ffffffffc0203184:	27249c63          	bne	s1,s2,ffffffffc02033fc <_fifo_check_swap+0x2ec>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203188:	00003517          	auipc	a0,0x3
ffffffffc020318c:	51050513          	addi	a0,a0,1296 # ffffffffc0206698 <commands+0x1680>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203190:	6909                	lui	s2,0x2
ffffffffc0203192:	4cad                	li	s9,11
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203194:	f3dfc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203198:	01990023          	sb	s9,0(s2) # 2000 <BASE_ADDRESS-0xffffffffc01fe000>
    assert(pgfault_num==4);
ffffffffc020319c:	401c                	lw	a5,0(s0)
ffffffffc020319e:	2781                	sext.w	a5,a5
ffffffffc02031a0:	22979e63          	bne	a5,s1,ffffffffc02033dc <_fifo_check_swap+0x2cc>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc02031a4:	00003517          	auipc	a0,0x3
ffffffffc02031a8:	51c50513          	addi	a0,a0,1308 # ffffffffc02066c0 <commands+0x16a8>
ffffffffc02031ac:	f25fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc02031b0:	6795                	lui	a5,0x5
ffffffffc02031b2:	4739                	li	a4,14
ffffffffc02031b4:	00e78023          	sb	a4,0(a5) # 5000 <BASE_ADDRESS-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc02031b8:	4004                	lw	s1,0(s0)
ffffffffc02031ba:	4795                	li	a5,5
ffffffffc02031bc:	2481                	sext.w	s1,s1
ffffffffc02031be:	1ef49f63          	bne	s1,a5,ffffffffc02033bc <_fifo_check_swap+0x2ac>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc02031c2:	00003517          	auipc	a0,0x3
ffffffffc02031c6:	4d650513          	addi	a0,a0,1238 # ffffffffc0206698 <commands+0x1680>
ffffffffc02031ca:	f07fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc02031ce:	01990023          	sb	s9,0(s2)
    assert(pgfault_num==5);
ffffffffc02031d2:	401c                	lw	a5,0(s0)
ffffffffc02031d4:	2781                	sext.w	a5,a5
ffffffffc02031d6:	1c979363          	bne	a5,s1,ffffffffc020339c <_fifo_check_swap+0x28c>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc02031da:	00003517          	auipc	a0,0x3
ffffffffc02031de:	46e50513          	addi	a0,a0,1134 # ffffffffc0206648 <commands+0x1630>
ffffffffc02031e2:	eeffc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc02031e6:	016a8023          	sb	s6,0(s5)
    assert(pgfault_num==6);
ffffffffc02031ea:	401c                	lw	a5,0(s0)
ffffffffc02031ec:	4719                	li	a4,6
ffffffffc02031ee:	2781                	sext.w	a5,a5
ffffffffc02031f0:	18e79663          	bne	a5,a4,ffffffffc020337c <_fifo_check_swap+0x26c>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc02031f4:	00003517          	auipc	a0,0x3
ffffffffc02031f8:	4a450513          	addi	a0,a0,1188 # ffffffffc0206698 <commands+0x1680>
ffffffffc02031fc:	ed5fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203200:	01990023          	sb	s9,0(s2)
    assert(pgfault_num==7);
ffffffffc0203204:	401c                	lw	a5,0(s0)
ffffffffc0203206:	471d                	li	a4,7
ffffffffc0203208:	2781                	sext.w	a5,a5
ffffffffc020320a:	14e79963          	bne	a5,a4,ffffffffc020335c <_fifo_check_swap+0x24c>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc020320e:	00003517          	auipc	a0,0x3
ffffffffc0203212:	3fa50513          	addi	a0,a0,1018 # ffffffffc0206608 <commands+0x15f0>
ffffffffc0203216:	ebbfc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc020321a:	01498023          	sb	s4,0(s3)
    assert(pgfault_num==8);
ffffffffc020321e:	401c                	lw	a5,0(s0)
ffffffffc0203220:	4721                	li	a4,8
ffffffffc0203222:	2781                	sext.w	a5,a5
ffffffffc0203224:	10e79c63          	bne	a5,a4,ffffffffc020333c <_fifo_check_swap+0x22c>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203228:	00003517          	auipc	a0,0x3
ffffffffc020322c:	44850513          	addi	a0,a0,1096 # ffffffffc0206670 <commands+0x1658>
ffffffffc0203230:	ea1fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203234:	018b8023          	sb	s8,0(s7)
    assert(pgfault_num==9);
ffffffffc0203238:	401c                	lw	a5,0(s0)
ffffffffc020323a:	4725                	li	a4,9
ffffffffc020323c:	2781                	sext.w	a5,a5
ffffffffc020323e:	0ce79f63          	bne	a5,a4,ffffffffc020331c <_fifo_check_swap+0x20c>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0203242:	00003517          	auipc	a0,0x3
ffffffffc0203246:	47e50513          	addi	a0,a0,1150 # ffffffffc02066c0 <commands+0x16a8>
ffffffffc020324a:	e87fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc020324e:	6795                	lui	a5,0x5
ffffffffc0203250:	4739                	li	a4,14
ffffffffc0203252:	00e78023          	sb	a4,0(a5) # 5000 <BASE_ADDRESS-0xffffffffc01fb000>
    assert(pgfault_num==10);
ffffffffc0203256:	4004                	lw	s1,0(s0)
ffffffffc0203258:	47a9                	li	a5,10
ffffffffc020325a:	2481                	sext.w	s1,s1
ffffffffc020325c:	0af49063          	bne	s1,a5,ffffffffc02032fc <_fifo_check_swap+0x1ec>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203260:	00003517          	auipc	a0,0x3
ffffffffc0203264:	3e850513          	addi	a0,a0,1000 # ffffffffc0206648 <commands+0x1630>
ffffffffc0203268:	e69fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc020326c:	6785                	lui	a5,0x1
ffffffffc020326e:	0007c783          	lbu	a5,0(a5) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
ffffffffc0203272:	06979563          	bne	a5,s1,ffffffffc02032dc <_fifo_check_swap+0x1cc>
    assert(pgfault_num==11);
ffffffffc0203276:	401c                	lw	a5,0(s0)
ffffffffc0203278:	472d                	li	a4,11
ffffffffc020327a:	2781                	sext.w	a5,a5
ffffffffc020327c:	04e79063          	bne	a5,a4,ffffffffc02032bc <_fifo_check_swap+0x1ac>
}
ffffffffc0203280:	60e6                	ld	ra,88(sp)
ffffffffc0203282:	6446                	ld	s0,80(sp)
ffffffffc0203284:	64a6                	ld	s1,72(sp)
ffffffffc0203286:	6906                	ld	s2,64(sp)
ffffffffc0203288:	79e2                	ld	s3,56(sp)
ffffffffc020328a:	7a42                	ld	s4,48(sp)
ffffffffc020328c:	7aa2                	ld	s5,40(sp)
ffffffffc020328e:	7b02                	ld	s6,32(sp)
ffffffffc0203290:	6be2                	ld	s7,24(sp)
ffffffffc0203292:	6c42                	ld	s8,16(sp)
ffffffffc0203294:	6ca2                	ld	s9,8(sp)
ffffffffc0203296:	4501                	li	a0,0
ffffffffc0203298:	6125                	addi	sp,sp,96
ffffffffc020329a:	8082                	ret
    assert(pgfault_num==4);
ffffffffc020329c:	00003697          	auipc	a3,0x3
ffffffffc02032a0:	18c68693          	addi	a3,a3,396 # ffffffffc0206428 <commands+0x1410>
ffffffffc02032a4:	00002617          	auipc	a2,0x2
ffffffffc02032a8:	70c60613          	addi	a2,a2,1804 # ffffffffc02059b0 <commands+0x998>
ffffffffc02032ac:	05100593          	li	a1,81
ffffffffc02032b0:	00003517          	auipc	a0,0x3
ffffffffc02032b4:	38050513          	addi	a0,a0,896 # ffffffffc0206630 <commands+0x1618>
ffffffffc02032b8:	f1dfc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(pgfault_num==11);
ffffffffc02032bc:	00003697          	auipc	a3,0x3
ffffffffc02032c0:	4b468693          	addi	a3,a3,1204 # ffffffffc0206770 <commands+0x1758>
ffffffffc02032c4:	00002617          	auipc	a2,0x2
ffffffffc02032c8:	6ec60613          	addi	a2,a2,1772 # ffffffffc02059b0 <commands+0x998>
ffffffffc02032cc:	07300593          	li	a1,115
ffffffffc02032d0:	00003517          	auipc	a0,0x3
ffffffffc02032d4:	36050513          	addi	a0,a0,864 # ffffffffc0206630 <commands+0x1618>
ffffffffc02032d8:	efdfc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc02032dc:	00003697          	auipc	a3,0x3
ffffffffc02032e0:	46c68693          	addi	a3,a3,1132 # ffffffffc0206748 <commands+0x1730>
ffffffffc02032e4:	00002617          	auipc	a2,0x2
ffffffffc02032e8:	6cc60613          	addi	a2,a2,1740 # ffffffffc02059b0 <commands+0x998>
ffffffffc02032ec:	07100593          	li	a1,113
ffffffffc02032f0:	00003517          	auipc	a0,0x3
ffffffffc02032f4:	34050513          	addi	a0,a0,832 # ffffffffc0206630 <commands+0x1618>
ffffffffc02032f8:	eddfc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(pgfault_num==10);
ffffffffc02032fc:	00003697          	auipc	a3,0x3
ffffffffc0203300:	43c68693          	addi	a3,a3,1084 # ffffffffc0206738 <commands+0x1720>
ffffffffc0203304:	00002617          	auipc	a2,0x2
ffffffffc0203308:	6ac60613          	addi	a2,a2,1708 # ffffffffc02059b0 <commands+0x998>
ffffffffc020330c:	06f00593          	li	a1,111
ffffffffc0203310:	00003517          	auipc	a0,0x3
ffffffffc0203314:	32050513          	addi	a0,a0,800 # ffffffffc0206630 <commands+0x1618>
ffffffffc0203318:	ebdfc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(pgfault_num==9);
ffffffffc020331c:	00003697          	auipc	a3,0x3
ffffffffc0203320:	40c68693          	addi	a3,a3,1036 # ffffffffc0206728 <commands+0x1710>
ffffffffc0203324:	00002617          	auipc	a2,0x2
ffffffffc0203328:	68c60613          	addi	a2,a2,1676 # ffffffffc02059b0 <commands+0x998>
ffffffffc020332c:	06c00593          	li	a1,108
ffffffffc0203330:	00003517          	auipc	a0,0x3
ffffffffc0203334:	30050513          	addi	a0,a0,768 # ffffffffc0206630 <commands+0x1618>
ffffffffc0203338:	e9dfc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(pgfault_num==8);
ffffffffc020333c:	00003697          	auipc	a3,0x3
ffffffffc0203340:	3dc68693          	addi	a3,a3,988 # ffffffffc0206718 <commands+0x1700>
ffffffffc0203344:	00002617          	auipc	a2,0x2
ffffffffc0203348:	66c60613          	addi	a2,a2,1644 # ffffffffc02059b0 <commands+0x998>
ffffffffc020334c:	06900593          	li	a1,105
ffffffffc0203350:	00003517          	auipc	a0,0x3
ffffffffc0203354:	2e050513          	addi	a0,a0,736 # ffffffffc0206630 <commands+0x1618>
ffffffffc0203358:	e7dfc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(pgfault_num==7);
ffffffffc020335c:	00003697          	auipc	a3,0x3
ffffffffc0203360:	3ac68693          	addi	a3,a3,940 # ffffffffc0206708 <commands+0x16f0>
ffffffffc0203364:	00002617          	auipc	a2,0x2
ffffffffc0203368:	64c60613          	addi	a2,a2,1612 # ffffffffc02059b0 <commands+0x998>
ffffffffc020336c:	06600593          	li	a1,102
ffffffffc0203370:	00003517          	auipc	a0,0x3
ffffffffc0203374:	2c050513          	addi	a0,a0,704 # ffffffffc0206630 <commands+0x1618>
ffffffffc0203378:	e5dfc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(pgfault_num==6);
ffffffffc020337c:	00003697          	auipc	a3,0x3
ffffffffc0203380:	37c68693          	addi	a3,a3,892 # ffffffffc02066f8 <commands+0x16e0>
ffffffffc0203384:	00002617          	auipc	a2,0x2
ffffffffc0203388:	62c60613          	addi	a2,a2,1580 # ffffffffc02059b0 <commands+0x998>
ffffffffc020338c:	06300593          	li	a1,99
ffffffffc0203390:	00003517          	auipc	a0,0x3
ffffffffc0203394:	2a050513          	addi	a0,a0,672 # ffffffffc0206630 <commands+0x1618>
ffffffffc0203398:	e3dfc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(pgfault_num==5);
ffffffffc020339c:	00003697          	auipc	a3,0x3
ffffffffc02033a0:	34c68693          	addi	a3,a3,844 # ffffffffc02066e8 <commands+0x16d0>
ffffffffc02033a4:	00002617          	auipc	a2,0x2
ffffffffc02033a8:	60c60613          	addi	a2,a2,1548 # ffffffffc02059b0 <commands+0x998>
ffffffffc02033ac:	06000593          	li	a1,96
ffffffffc02033b0:	00003517          	auipc	a0,0x3
ffffffffc02033b4:	28050513          	addi	a0,a0,640 # ffffffffc0206630 <commands+0x1618>
ffffffffc02033b8:	e1dfc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(pgfault_num==5);
ffffffffc02033bc:	00003697          	auipc	a3,0x3
ffffffffc02033c0:	32c68693          	addi	a3,a3,812 # ffffffffc02066e8 <commands+0x16d0>
ffffffffc02033c4:	00002617          	auipc	a2,0x2
ffffffffc02033c8:	5ec60613          	addi	a2,a2,1516 # ffffffffc02059b0 <commands+0x998>
ffffffffc02033cc:	05d00593          	li	a1,93
ffffffffc02033d0:	00003517          	auipc	a0,0x3
ffffffffc02033d4:	26050513          	addi	a0,a0,608 # ffffffffc0206630 <commands+0x1618>
ffffffffc02033d8:	dfdfc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(pgfault_num==4);
ffffffffc02033dc:	00003697          	auipc	a3,0x3
ffffffffc02033e0:	04c68693          	addi	a3,a3,76 # ffffffffc0206428 <commands+0x1410>
ffffffffc02033e4:	00002617          	auipc	a2,0x2
ffffffffc02033e8:	5cc60613          	addi	a2,a2,1484 # ffffffffc02059b0 <commands+0x998>
ffffffffc02033ec:	05a00593          	li	a1,90
ffffffffc02033f0:	00003517          	auipc	a0,0x3
ffffffffc02033f4:	24050513          	addi	a0,a0,576 # ffffffffc0206630 <commands+0x1618>
ffffffffc02033f8:	dddfc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(pgfault_num==4);
ffffffffc02033fc:	00003697          	auipc	a3,0x3
ffffffffc0203400:	02c68693          	addi	a3,a3,44 # ffffffffc0206428 <commands+0x1410>
ffffffffc0203404:	00002617          	auipc	a2,0x2
ffffffffc0203408:	5ac60613          	addi	a2,a2,1452 # ffffffffc02059b0 <commands+0x998>
ffffffffc020340c:	05700593          	li	a1,87
ffffffffc0203410:	00003517          	auipc	a0,0x3
ffffffffc0203414:	22050513          	addi	a0,a0,544 # ffffffffc0206630 <commands+0x1618>
ffffffffc0203418:	dbdfc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(pgfault_num==4);
ffffffffc020341c:	00003697          	auipc	a3,0x3
ffffffffc0203420:	00c68693          	addi	a3,a3,12 # ffffffffc0206428 <commands+0x1410>
ffffffffc0203424:	00002617          	auipc	a2,0x2
ffffffffc0203428:	58c60613          	addi	a2,a2,1420 # ffffffffc02059b0 <commands+0x998>
ffffffffc020342c:	05400593          	li	a1,84
ffffffffc0203430:	00003517          	auipc	a0,0x3
ffffffffc0203434:	20050513          	addi	a0,a0,512 # ffffffffc0206630 <commands+0x1618>
ffffffffc0203438:	d9dfc0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc020343c <_fifo_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc020343c:	751c                	ld	a5,40(a0)
{
ffffffffc020343e:	1141                	addi	sp,sp,-16
ffffffffc0203440:	e406                	sd	ra,8(sp)
         assert(head != NULL);
ffffffffc0203442:	cf91                	beqz	a5,ffffffffc020345e <_fifo_swap_out_victim+0x22>
     assert(in_tick==0);
ffffffffc0203444:	ee0d                	bnez	a2,ffffffffc020347e <_fifo_swap_out_victim+0x42>
    return listelm->next;
ffffffffc0203446:	679c                	ld	a5,8(a5)
}
ffffffffc0203448:	60a2                	ld	ra,8(sp)
ffffffffc020344a:	4501                	li	a0,0
    __list_del(listelm->prev, listelm->next);
ffffffffc020344c:	6394                	ld	a3,0(a5)
ffffffffc020344e:	6798                	ld	a4,8(a5)
    *ptr_page = le2page(entry, pra_page_link);
ffffffffc0203450:	fd878793          	addi	a5,a5,-40
    prev->next = next;
ffffffffc0203454:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc0203456:	e314                	sd	a3,0(a4)
ffffffffc0203458:	e19c                	sd	a5,0(a1)
}
ffffffffc020345a:	0141                	addi	sp,sp,16
ffffffffc020345c:	8082                	ret
         assert(head != NULL);
ffffffffc020345e:	00003697          	auipc	a3,0x3
ffffffffc0203462:	34268693          	addi	a3,a3,834 # ffffffffc02067a0 <commands+0x1788>
ffffffffc0203466:	00002617          	auipc	a2,0x2
ffffffffc020346a:	54a60613          	addi	a2,a2,1354 # ffffffffc02059b0 <commands+0x998>
ffffffffc020346e:	04100593          	li	a1,65
ffffffffc0203472:	00003517          	auipc	a0,0x3
ffffffffc0203476:	1be50513          	addi	a0,a0,446 # ffffffffc0206630 <commands+0x1618>
ffffffffc020347a:	d5bfc0ef          	jal	ra,ffffffffc02001d4 <__panic>
     assert(in_tick==0);
ffffffffc020347e:	00003697          	auipc	a3,0x3
ffffffffc0203482:	33268693          	addi	a3,a3,818 # ffffffffc02067b0 <commands+0x1798>
ffffffffc0203486:	00002617          	auipc	a2,0x2
ffffffffc020348a:	52a60613          	addi	a2,a2,1322 # ffffffffc02059b0 <commands+0x998>
ffffffffc020348e:	04200593          	li	a1,66
ffffffffc0203492:	00003517          	auipc	a0,0x3
ffffffffc0203496:	19e50513          	addi	a0,a0,414 # ffffffffc0206630 <commands+0x1618>
ffffffffc020349a:	d3bfc0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc020349e <_fifo_map_swappable>:
    list_entry_t *entry=&(page->pra_page_link);
ffffffffc020349e:	02860713          	addi	a4,a2,40
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc02034a2:	751c                	ld	a5,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc02034a4:	cb09                	beqz	a4,ffffffffc02034b6 <_fifo_map_swappable+0x18>
ffffffffc02034a6:	cb81                	beqz	a5,ffffffffc02034b6 <_fifo_map_swappable+0x18>
    __list_add(elm, listelm->prev, listelm);
ffffffffc02034a8:	6394                	ld	a3,0(a5)
    prev->next = next->prev = elm;
ffffffffc02034aa:	e398                	sd	a4,0(a5)
}
ffffffffc02034ac:	4501                	li	a0,0
ffffffffc02034ae:	e698                	sd	a4,8(a3)
    elm->next = next;
ffffffffc02034b0:	fa1c                	sd	a5,48(a2)
    elm->prev = prev;
ffffffffc02034b2:	f614                	sd	a3,40(a2)
ffffffffc02034b4:	8082                	ret
{
ffffffffc02034b6:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc02034b8:	00003697          	auipc	a3,0x3
ffffffffc02034bc:	2c868693          	addi	a3,a3,712 # ffffffffc0206780 <commands+0x1768>
ffffffffc02034c0:	00002617          	auipc	a2,0x2
ffffffffc02034c4:	4f060613          	addi	a2,a2,1264 # ffffffffc02059b0 <commands+0x998>
ffffffffc02034c8:	03200593          	li	a1,50
ffffffffc02034cc:	00003517          	auipc	a0,0x3
ffffffffc02034d0:	16450513          	addi	a0,a0,356 # ffffffffc0206630 <commands+0x1618>
{
ffffffffc02034d4:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc02034d6:	cfffc0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc02034da <default_init>:
    elm->prev = elm->next = elm;
ffffffffc02034da:	00012797          	auipc	a5,0x12
ffffffffc02034de:	0fe78793          	addi	a5,a5,254 # ffffffffc02155d8 <free_area>
ffffffffc02034e2:	e79c                	sd	a5,8(a5)
ffffffffc02034e4:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc02034e6:	0007a823          	sw	zero,16(a5)
}
ffffffffc02034ea:	8082                	ret

ffffffffc02034ec <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc02034ec:	00012517          	auipc	a0,0x12
ffffffffc02034f0:	0fc56503          	lwu	a0,252(a0) # ffffffffc02155e8 <free_area+0x10>
ffffffffc02034f4:	8082                	ret

ffffffffc02034f6 <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc02034f6:	715d                	addi	sp,sp,-80
ffffffffc02034f8:	f84a                	sd	s2,48(sp)
    return listelm->next;
ffffffffc02034fa:	00012917          	auipc	s2,0x12
ffffffffc02034fe:	0de90913          	addi	s2,s2,222 # ffffffffc02155d8 <free_area>
ffffffffc0203502:	00893783          	ld	a5,8(s2)
ffffffffc0203506:	e486                	sd	ra,72(sp)
ffffffffc0203508:	e0a2                	sd	s0,64(sp)
ffffffffc020350a:	fc26                	sd	s1,56(sp)
ffffffffc020350c:	f44e                	sd	s3,40(sp)
ffffffffc020350e:	f052                	sd	s4,32(sp)
ffffffffc0203510:	ec56                	sd	s5,24(sp)
ffffffffc0203512:	e85a                	sd	s6,16(sp)
ffffffffc0203514:	e45e                	sd	s7,8(sp)
ffffffffc0203516:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0203518:	31278463          	beq	a5,s2,ffffffffc0203820 <default_check+0x32a>
ffffffffc020351c:	ff07b703          	ld	a4,-16(a5)
ffffffffc0203520:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0203522:	8b05                	andi	a4,a4,1
ffffffffc0203524:	30070263          	beqz	a4,ffffffffc0203828 <default_check+0x332>
    int count = 0, total = 0;
ffffffffc0203528:	4401                	li	s0,0
ffffffffc020352a:	4481                	li	s1,0
ffffffffc020352c:	a031                	j	ffffffffc0203538 <default_check+0x42>
ffffffffc020352e:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc0203532:	8b09                	andi	a4,a4,2
ffffffffc0203534:	2e070a63          	beqz	a4,ffffffffc0203828 <default_check+0x332>
        count ++, total += p->property;
ffffffffc0203538:	ff87a703          	lw	a4,-8(a5)
ffffffffc020353c:	679c                	ld	a5,8(a5)
ffffffffc020353e:	2485                	addiw	s1,s1,1
ffffffffc0203540:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0203542:	ff2796e3          	bne	a5,s2,ffffffffc020352e <default_check+0x38>
ffffffffc0203546:	89a2                	mv	s3,s0
    }
    assert(total == nr_free_pages());
ffffffffc0203548:	f2cfd0ef          	jal	ra,ffffffffc0200c74 <nr_free_pages>
ffffffffc020354c:	73351e63          	bne	a0,s3,ffffffffc0203c88 <default_check+0x792>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0203550:	4505                	li	a0,1
ffffffffc0203552:	e54fd0ef          	jal	ra,ffffffffc0200ba6 <alloc_pages>
ffffffffc0203556:	8a2a                	mv	s4,a0
ffffffffc0203558:	46050863          	beqz	a0,ffffffffc02039c8 <default_check+0x4d2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020355c:	4505                	li	a0,1
ffffffffc020355e:	e48fd0ef          	jal	ra,ffffffffc0200ba6 <alloc_pages>
ffffffffc0203562:	89aa                	mv	s3,a0
ffffffffc0203564:	74050263          	beqz	a0,ffffffffc0203ca8 <default_check+0x7b2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0203568:	4505                	li	a0,1
ffffffffc020356a:	e3cfd0ef          	jal	ra,ffffffffc0200ba6 <alloc_pages>
ffffffffc020356e:	8aaa                	mv	s5,a0
ffffffffc0203570:	4c050c63          	beqz	a0,ffffffffc0203a48 <default_check+0x552>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0203574:	2d3a0a63          	beq	s4,s3,ffffffffc0203848 <default_check+0x352>
ffffffffc0203578:	2caa0863          	beq	s4,a0,ffffffffc0203848 <default_check+0x352>
ffffffffc020357c:	2ca98663          	beq	s3,a0,ffffffffc0203848 <default_check+0x352>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0203580:	000a2783          	lw	a5,0(s4)
ffffffffc0203584:	2e079263          	bnez	a5,ffffffffc0203868 <default_check+0x372>
ffffffffc0203588:	0009a783          	lw	a5,0(s3)
ffffffffc020358c:	2c079e63          	bnez	a5,ffffffffc0203868 <default_check+0x372>
ffffffffc0203590:	411c                	lw	a5,0(a0)
ffffffffc0203592:	2c079b63          	bnez	a5,ffffffffc0203868 <default_check+0x372>
    return page - pages + nbase;
ffffffffc0203596:	00012797          	auipc	a5,0x12
ffffffffc020359a:	f5a78793          	addi	a5,a5,-166 # ffffffffc02154f0 <pages>
ffffffffc020359e:	639c                	ld	a5,0(a5)
ffffffffc02035a0:	00004717          	auipc	a4,0x4
ffffffffc02035a4:	a3870713          	addi	a4,a4,-1480 # ffffffffc0206fd8 <nbase>
ffffffffc02035a8:	6310                	ld	a2,0(a4)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc02035aa:	00012717          	auipc	a4,0x12
ffffffffc02035ae:	ede70713          	addi	a4,a4,-290 # ffffffffc0215488 <npage>
ffffffffc02035b2:	6314                	ld	a3,0(a4)
ffffffffc02035b4:	40fa0733          	sub	a4,s4,a5
ffffffffc02035b8:	8719                	srai	a4,a4,0x6
ffffffffc02035ba:	9732                	add	a4,a4,a2
ffffffffc02035bc:	06b2                	slli	a3,a3,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02035be:	0732                	slli	a4,a4,0xc
ffffffffc02035c0:	2cd77463          	bgeu	a4,a3,ffffffffc0203888 <default_check+0x392>
    return page - pages + nbase;
ffffffffc02035c4:	40f98733          	sub	a4,s3,a5
ffffffffc02035c8:	8719                	srai	a4,a4,0x6
ffffffffc02035ca:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02035cc:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02035ce:	4ed77d63          	bgeu	a4,a3,ffffffffc0203ac8 <default_check+0x5d2>
    return page - pages + nbase;
ffffffffc02035d2:	40f507b3          	sub	a5,a0,a5
ffffffffc02035d6:	8799                	srai	a5,a5,0x6
ffffffffc02035d8:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02035da:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc02035dc:	34d7f663          	bgeu	a5,a3,ffffffffc0203928 <default_check+0x432>
    assert(alloc_page() == NULL);
ffffffffc02035e0:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc02035e2:	00093c03          	ld	s8,0(s2)
ffffffffc02035e6:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc02035ea:	01092b03          	lw	s6,16(s2)
    elm->prev = elm->next = elm;
ffffffffc02035ee:	00012797          	auipc	a5,0x12
ffffffffc02035f2:	ff27b923          	sd	s2,-14(a5) # ffffffffc02155e0 <free_area+0x8>
ffffffffc02035f6:	00012797          	auipc	a5,0x12
ffffffffc02035fa:	ff27b123          	sd	s2,-30(a5) # ffffffffc02155d8 <free_area>
    nr_free = 0;
ffffffffc02035fe:	00012797          	auipc	a5,0x12
ffffffffc0203602:	fe07a523          	sw	zero,-22(a5) # ffffffffc02155e8 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0203606:	da0fd0ef          	jal	ra,ffffffffc0200ba6 <alloc_pages>
ffffffffc020360a:	2e051f63          	bnez	a0,ffffffffc0203908 <default_check+0x412>
    free_page(p0);
ffffffffc020360e:	4585                	li	a1,1
ffffffffc0203610:	8552                	mv	a0,s4
ffffffffc0203612:	e1cfd0ef          	jal	ra,ffffffffc0200c2e <free_pages>
    free_page(p1);
ffffffffc0203616:	4585                	li	a1,1
ffffffffc0203618:	854e                	mv	a0,s3
ffffffffc020361a:	e14fd0ef          	jal	ra,ffffffffc0200c2e <free_pages>
    free_page(p2);
ffffffffc020361e:	4585                	li	a1,1
ffffffffc0203620:	8556                	mv	a0,s5
ffffffffc0203622:	e0cfd0ef          	jal	ra,ffffffffc0200c2e <free_pages>
    assert(nr_free == 3);
ffffffffc0203626:	01092703          	lw	a4,16(s2)
ffffffffc020362a:	478d                	li	a5,3
ffffffffc020362c:	2af71e63          	bne	a4,a5,ffffffffc02038e8 <default_check+0x3f2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0203630:	4505                	li	a0,1
ffffffffc0203632:	d74fd0ef          	jal	ra,ffffffffc0200ba6 <alloc_pages>
ffffffffc0203636:	89aa                	mv	s3,a0
ffffffffc0203638:	28050863          	beqz	a0,ffffffffc02038c8 <default_check+0x3d2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020363c:	4505                	li	a0,1
ffffffffc020363e:	d68fd0ef          	jal	ra,ffffffffc0200ba6 <alloc_pages>
ffffffffc0203642:	8aaa                	mv	s5,a0
ffffffffc0203644:	3e050263          	beqz	a0,ffffffffc0203a28 <default_check+0x532>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0203648:	4505                	li	a0,1
ffffffffc020364a:	d5cfd0ef          	jal	ra,ffffffffc0200ba6 <alloc_pages>
ffffffffc020364e:	8a2a                	mv	s4,a0
ffffffffc0203650:	3a050c63          	beqz	a0,ffffffffc0203a08 <default_check+0x512>
    assert(alloc_page() == NULL);
ffffffffc0203654:	4505                	li	a0,1
ffffffffc0203656:	d50fd0ef          	jal	ra,ffffffffc0200ba6 <alloc_pages>
ffffffffc020365a:	38051763          	bnez	a0,ffffffffc02039e8 <default_check+0x4f2>
    free_page(p0);
ffffffffc020365e:	4585                	li	a1,1
ffffffffc0203660:	854e                	mv	a0,s3
ffffffffc0203662:	dccfd0ef          	jal	ra,ffffffffc0200c2e <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0203666:	00893783          	ld	a5,8(s2)
ffffffffc020366a:	23278f63          	beq	a5,s2,ffffffffc02038a8 <default_check+0x3b2>
    assert((p = alloc_page()) == p0);
ffffffffc020366e:	4505                	li	a0,1
ffffffffc0203670:	d36fd0ef          	jal	ra,ffffffffc0200ba6 <alloc_pages>
ffffffffc0203674:	32a99a63          	bne	s3,a0,ffffffffc02039a8 <default_check+0x4b2>
    assert(alloc_page() == NULL);
ffffffffc0203678:	4505                	li	a0,1
ffffffffc020367a:	d2cfd0ef          	jal	ra,ffffffffc0200ba6 <alloc_pages>
ffffffffc020367e:	30051563          	bnez	a0,ffffffffc0203988 <default_check+0x492>
    assert(nr_free == 0);
ffffffffc0203682:	01092783          	lw	a5,16(s2)
ffffffffc0203686:	2e079163          	bnez	a5,ffffffffc0203968 <default_check+0x472>
    free_page(p);
ffffffffc020368a:	854e                	mv	a0,s3
ffffffffc020368c:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc020368e:	00012797          	auipc	a5,0x12
ffffffffc0203692:	f587b523          	sd	s8,-182(a5) # ffffffffc02155d8 <free_area>
ffffffffc0203696:	00012797          	auipc	a5,0x12
ffffffffc020369a:	f577b523          	sd	s7,-182(a5) # ffffffffc02155e0 <free_area+0x8>
    nr_free = nr_free_store;
ffffffffc020369e:	00012797          	auipc	a5,0x12
ffffffffc02036a2:	f567a523          	sw	s6,-182(a5) # ffffffffc02155e8 <free_area+0x10>
    free_page(p);
ffffffffc02036a6:	d88fd0ef          	jal	ra,ffffffffc0200c2e <free_pages>
    free_page(p1);
ffffffffc02036aa:	4585                	li	a1,1
ffffffffc02036ac:	8556                	mv	a0,s5
ffffffffc02036ae:	d80fd0ef          	jal	ra,ffffffffc0200c2e <free_pages>
    free_page(p2);
ffffffffc02036b2:	4585                	li	a1,1
ffffffffc02036b4:	8552                	mv	a0,s4
ffffffffc02036b6:	d78fd0ef          	jal	ra,ffffffffc0200c2e <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc02036ba:	4515                	li	a0,5
ffffffffc02036bc:	ceafd0ef          	jal	ra,ffffffffc0200ba6 <alloc_pages>
ffffffffc02036c0:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc02036c2:	28050363          	beqz	a0,ffffffffc0203948 <default_check+0x452>
ffffffffc02036c6:	651c                	ld	a5,8(a0)
ffffffffc02036c8:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc02036ca:	8b85                	andi	a5,a5,1
ffffffffc02036cc:	54079e63          	bnez	a5,ffffffffc0203c28 <default_check+0x732>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc02036d0:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc02036d2:	00093b03          	ld	s6,0(s2)
ffffffffc02036d6:	00893a83          	ld	s5,8(s2)
ffffffffc02036da:	00012797          	auipc	a5,0x12
ffffffffc02036de:	ef27bf23          	sd	s2,-258(a5) # ffffffffc02155d8 <free_area>
ffffffffc02036e2:	00012797          	auipc	a5,0x12
ffffffffc02036e6:	ef27bf23          	sd	s2,-258(a5) # ffffffffc02155e0 <free_area+0x8>
    assert(alloc_page() == NULL);
ffffffffc02036ea:	cbcfd0ef          	jal	ra,ffffffffc0200ba6 <alloc_pages>
ffffffffc02036ee:	50051d63          	bnez	a0,ffffffffc0203c08 <default_check+0x712>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc02036f2:	08098a13          	addi	s4,s3,128
ffffffffc02036f6:	8552                	mv	a0,s4
ffffffffc02036f8:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc02036fa:	01092b83          	lw	s7,16(s2)
    nr_free = 0;
ffffffffc02036fe:	00012797          	auipc	a5,0x12
ffffffffc0203702:	ee07a523          	sw	zero,-278(a5) # ffffffffc02155e8 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0203706:	d28fd0ef          	jal	ra,ffffffffc0200c2e <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc020370a:	4511                	li	a0,4
ffffffffc020370c:	c9afd0ef          	jal	ra,ffffffffc0200ba6 <alloc_pages>
ffffffffc0203710:	4c051c63          	bnez	a0,ffffffffc0203be8 <default_check+0x6f2>
ffffffffc0203714:	0889b783          	ld	a5,136(s3)
ffffffffc0203718:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc020371a:	8b85                	andi	a5,a5,1
ffffffffc020371c:	4a078663          	beqz	a5,ffffffffc0203bc8 <default_check+0x6d2>
ffffffffc0203720:	0909a703          	lw	a4,144(s3)
ffffffffc0203724:	478d                	li	a5,3
ffffffffc0203726:	4af71163          	bne	a4,a5,ffffffffc0203bc8 <default_check+0x6d2>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc020372a:	450d                	li	a0,3
ffffffffc020372c:	c7afd0ef          	jal	ra,ffffffffc0200ba6 <alloc_pages>
ffffffffc0203730:	8c2a                	mv	s8,a0
ffffffffc0203732:	46050b63          	beqz	a0,ffffffffc0203ba8 <default_check+0x6b2>
    assert(alloc_page() == NULL);
ffffffffc0203736:	4505                	li	a0,1
ffffffffc0203738:	c6efd0ef          	jal	ra,ffffffffc0200ba6 <alloc_pages>
ffffffffc020373c:	44051663          	bnez	a0,ffffffffc0203b88 <default_check+0x692>
    assert(p0 + 2 == p1);
ffffffffc0203740:	438a1463          	bne	s4,s8,ffffffffc0203b68 <default_check+0x672>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0203744:	4585                	li	a1,1
ffffffffc0203746:	854e                	mv	a0,s3
ffffffffc0203748:	ce6fd0ef          	jal	ra,ffffffffc0200c2e <free_pages>
    free_pages(p1, 3);
ffffffffc020374c:	458d                	li	a1,3
ffffffffc020374e:	8552                	mv	a0,s4
ffffffffc0203750:	cdefd0ef          	jal	ra,ffffffffc0200c2e <free_pages>
ffffffffc0203754:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0203758:	04098c13          	addi	s8,s3,64
ffffffffc020375c:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc020375e:	8b85                	andi	a5,a5,1
ffffffffc0203760:	3e078463          	beqz	a5,ffffffffc0203b48 <default_check+0x652>
ffffffffc0203764:	0109a703          	lw	a4,16(s3)
ffffffffc0203768:	4785                	li	a5,1
ffffffffc020376a:	3cf71f63          	bne	a4,a5,ffffffffc0203b48 <default_check+0x652>
ffffffffc020376e:	008a3783          	ld	a5,8(s4)
ffffffffc0203772:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0203774:	8b85                	andi	a5,a5,1
ffffffffc0203776:	3a078963          	beqz	a5,ffffffffc0203b28 <default_check+0x632>
ffffffffc020377a:	010a2703          	lw	a4,16(s4)
ffffffffc020377e:	478d                	li	a5,3
ffffffffc0203780:	3af71463          	bne	a4,a5,ffffffffc0203b28 <default_check+0x632>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0203784:	4505                	li	a0,1
ffffffffc0203786:	c20fd0ef          	jal	ra,ffffffffc0200ba6 <alloc_pages>
ffffffffc020378a:	36a99f63          	bne	s3,a0,ffffffffc0203b08 <default_check+0x612>
    free_page(p0);
ffffffffc020378e:	4585                	li	a1,1
ffffffffc0203790:	c9efd0ef          	jal	ra,ffffffffc0200c2e <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0203794:	4509                	li	a0,2
ffffffffc0203796:	c10fd0ef          	jal	ra,ffffffffc0200ba6 <alloc_pages>
ffffffffc020379a:	34aa1763          	bne	s4,a0,ffffffffc0203ae8 <default_check+0x5f2>

    free_pages(p0, 2);
ffffffffc020379e:	4589                	li	a1,2
ffffffffc02037a0:	c8efd0ef          	jal	ra,ffffffffc0200c2e <free_pages>
    free_page(p2);
ffffffffc02037a4:	4585                	li	a1,1
ffffffffc02037a6:	8562                	mv	a0,s8
ffffffffc02037a8:	c86fd0ef          	jal	ra,ffffffffc0200c2e <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02037ac:	4515                	li	a0,5
ffffffffc02037ae:	bf8fd0ef          	jal	ra,ffffffffc0200ba6 <alloc_pages>
ffffffffc02037b2:	89aa                	mv	s3,a0
ffffffffc02037b4:	48050a63          	beqz	a0,ffffffffc0203c48 <default_check+0x752>
    assert(alloc_page() == NULL);
ffffffffc02037b8:	4505                	li	a0,1
ffffffffc02037ba:	becfd0ef          	jal	ra,ffffffffc0200ba6 <alloc_pages>
ffffffffc02037be:	2e051563          	bnez	a0,ffffffffc0203aa8 <default_check+0x5b2>

    assert(nr_free == 0);
ffffffffc02037c2:	01092783          	lw	a5,16(s2)
ffffffffc02037c6:	2c079163          	bnez	a5,ffffffffc0203a88 <default_check+0x592>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc02037ca:	4595                	li	a1,5
ffffffffc02037cc:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc02037ce:	00012797          	auipc	a5,0x12
ffffffffc02037d2:	e177ad23          	sw	s7,-486(a5) # ffffffffc02155e8 <free_area+0x10>
    free_list = free_list_store;
ffffffffc02037d6:	00012797          	auipc	a5,0x12
ffffffffc02037da:	e167b123          	sd	s6,-510(a5) # ffffffffc02155d8 <free_area>
ffffffffc02037de:	00012797          	auipc	a5,0x12
ffffffffc02037e2:	e157b123          	sd	s5,-510(a5) # ffffffffc02155e0 <free_area+0x8>
    free_pages(p0, 5);
ffffffffc02037e6:	c48fd0ef          	jal	ra,ffffffffc0200c2e <free_pages>
    return listelm->next;
ffffffffc02037ea:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc02037ee:	01278963          	beq	a5,s2,ffffffffc0203800 <default_check+0x30a>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc02037f2:	ff87a703          	lw	a4,-8(a5)
ffffffffc02037f6:	679c                	ld	a5,8(a5)
ffffffffc02037f8:	34fd                	addiw	s1,s1,-1
ffffffffc02037fa:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc02037fc:	ff279be3          	bne	a5,s2,ffffffffc02037f2 <default_check+0x2fc>
    }
    assert(count == 0);
ffffffffc0203800:	26049463          	bnez	s1,ffffffffc0203a68 <default_check+0x572>
    assert(total == 0);
ffffffffc0203804:	46041263          	bnez	s0,ffffffffc0203c68 <default_check+0x772>
}
ffffffffc0203808:	60a6                	ld	ra,72(sp)
ffffffffc020380a:	6406                	ld	s0,64(sp)
ffffffffc020380c:	74e2                	ld	s1,56(sp)
ffffffffc020380e:	7942                	ld	s2,48(sp)
ffffffffc0203810:	79a2                	ld	s3,40(sp)
ffffffffc0203812:	7a02                	ld	s4,32(sp)
ffffffffc0203814:	6ae2                	ld	s5,24(sp)
ffffffffc0203816:	6b42                	ld	s6,16(sp)
ffffffffc0203818:	6ba2                	ld	s7,8(sp)
ffffffffc020381a:	6c02                	ld	s8,0(sp)
ffffffffc020381c:	6161                	addi	sp,sp,80
ffffffffc020381e:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0203820:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0203822:	4401                	li	s0,0
ffffffffc0203824:	4481                	li	s1,0
ffffffffc0203826:	b30d                	j	ffffffffc0203548 <default_check+0x52>
        assert(PageProperty(p));
ffffffffc0203828:	00003697          	auipc	a3,0x3
ffffffffc020382c:	a6068693          	addi	a3,a3,-1440 # ffffffffc0206288 <commands+0x1270>
ffffffffc0203830:	00002617          	auipc	a2,0x2
ffffffffc0203834:	18060613          	addi	a2,a2,384 # ffffffffc02059b0 <commands+0x998>
ffffffffc0203838:	0f000593          	li	a1,240
ffffffffc020383c:	00003517          	auipc	a0,0x3
ffffffffc0203840:	f9c50513          	addi	a0,a0,-100 # ffffffffc02067d8 <commands+0x17c0>
ffffffffc0203844:	991fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0203848:	00003697          	auipc	a3,0x3
ffffffffc020384c:	00868693          	addi	a3,a3,8 # ffffffffc0206850 <commands+0x1838>
ffffffffc0203850:	00002617          	auipc	a2,0x2
ffffffffc0203854:	16060613          	addi	a2,a2,352 # ffffffffc02059b0 <commands+0x998>
ffffffffc0203858:	0bd00593          	li	a1,189
ffffffffc020385c:	00003517          	auipc	a0,0x3
ffffffffc0203860:	f7c50513          	addi	a0,a0,-132 # ffffffffc02067d8 <commands+0x17c0>
ffffffffc0203864:	971fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0203868:	00003697          	auipc	a3,0x3
ffffffffc020386c:	01068693          	addi	a3,a3,16 # ffffffffc0206878 <commands+0x1860>
ffffffffc0203870:	00002617          	auipc	a2,0x2
ffffffffc0203874:	14060613          	addi	a2,a2,320 # ffffffffc02059b0 <commands+0x998>
ffffffffc0203878:	0be00593          	li	a1,190
ffffffffc020387c:	00003517          	auipc	a0,0x3
ffffffffc0203880:	f5c50513          	addi	a0,a0,-164 # ffffffffc02067d8 <commands+0x17c0>
ffffffffc0203884:	951fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0203888:	00003697          	auipc	a3,0x3
ffffffffc020388c:	03068693          	addi	a3,a3,48 # ffffffffc02068b8 <commands+0x18a0>
ffffffffc0203890:	00002617          	auipc	a2,0x2
ffffffffc0203894:	12060613          	addi	a2,a2,288 # ffffffffc02059b0 <commands+0x998>
ffffffffc0203898:	0c000593          	li	a1,192
ffffffffc020389c:	00003517          	auipc	a0,0x3
ffffffffc02038a0:	f3c50513          	addi	a0,a0,-196 # ffffffffc02067d8 <commands+0x17c0>
ffffffffc02038a4:	931fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(!list_empty(&free_list));
ffffffffc02038a8:	00003697          	auipc	a3,0x3
ffffffffc02038ac:	09868693          	addi	a3,a3,152 # ffffffffc0206940 <commands+0x1928>
ffffffffc02038b0:	00002617          	auipc	a2,0x2
ffffffffc02038b4:	10060613          	addi	a2,a2,256 # ffffffffc02059b0 <commands+0x998>
ffffffffc02038b8:	0d900593          	li	a1,217
ffffffffc02038bc:	00003517          	auipc	a0,0x3
ffffffffc02038c0:	f1c50513          	addi	a0,a0,-228 # ffffffffc02067d8 <commands+0x17c0>
ffffffffc02038c4:	911fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02038c8:	00003697          	auipc	a3,0x3
ffffffffc02038cc:	f2868693          	addi	a3,a3,-216 # ffffffffc02067f0 <commands+0x17d8>
ffffffffc02038d0:	00002617          	auipc	a2,0x2
ffffffffc02038d4:	0e060613          	addi	a2,a2,224 # ffffffffc02059b0 <commands+0x998>
ffffffffc02038d8:	0d200593          	li	a1,210
ffffffffc02038dc:	00003517          	auipc	a0,0x3
ffffffffc02038e0:	efc50513          	addi	a0,a0,-260 # ffffffffc02067d8 <commands+0x17c0>
ffffffffc02038e4:	8f1fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(nr_free == 3);
ffffffffc02038e8:	00003697          	auipc	a3,0x3
ffffffffc02038ec:	04868693          	addi	a3,a3,72 # ffffffffc0206930 <commands+0x1918>
ffffffffc02038f0:	00002617          	auipc	a2,0x2
ffffffffc02038f4:	0c060613          	addi	a2,a2,192 # ffffffffc02059b0 <commands+0x998>
ffffffffc02038f8:	0d000593          	li	a1,208
ffffffffc02038fc:	00003517          	auipc	a0,0x3
ffffffffc0203900:	edc50513          	addi	a0,a0,-292 # ffffffffc02067d8 <commands+0x17c0>
ffffffffc0203904:	8d1fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0203908:	00003697          	auipc	a3,0x3
ffffffffc020390c:	01068693          	addi	a3,a3,16 # ffffffffc0206918 <commands+0x1900>
ffffffffc0203910:	00002617          	auipc	a2,0x2
ffffffffc0203914:	0a060613          	addi	a2,a2,160 # ffffffffc02059b0 <commands+0x998>
ffffffffc0203918:	0cb00593          	li	a1,203
ffffffffc020391c:	00003517          	auipc	a0,0x3
ffffffffc0203920:	ebc50513          	addi	a0,a0,-324 # ffffffffc02067d8 <commands+0x17c0>
ffffffffc0203924:	8b1fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0203928:	00003697          	auipc	a3,0x3
ffffffffc020392c:	fd068693          	addi	a3,a3,-48 # ffffffffc02068f8 <commands+0x18e0>
ffffffffc0203930:	00002617          	auipc	a2,0x2
ffffffffc0203934:	08060613          	addi	a2,a2,128 # ffffffffc02059b0 <commands+0x998>
ffffffffc0203938:	0c200593          	li	a1,194
ffffffffc020393c:	00003517          	auipc	a0,0x3
ffffffffc0203940:	e9c50513          	addi	a0,a0,-356 # ffffffffc02067d8 <commands+0x17c0>
ffffffffc0203944:	891fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(p0 != NULL);
ffffffffc0203948:	00003697          	auipc	a3,0x3
ffffffffc020394c:	03068693          	addi	a3,a3,48 # ffffffffc0206978 <commands+0x1960>
ffffffffc0203950:	00002617          	auipc	a2,0x2
ffffffffc0203954:	06060613          	addi	a2,a2,96 # ffffffffc02059b0 <commands+0x998>
ffffffffc0203958:	0f800593          	li	a1,248
ffffffffc020395c:	00003517          	auipc	a0,0x3
ffffffffc0203960:	e7c50513          	addi	a0,a0,-388 # ffffffffc02067d8 <commands+0x17c0>
ffffffffc0203964:	871fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(nr_free == 0);
ffffffffc0203968:	00003697          	auipc	a3,0x3
ffffffffc020396c:	ad068693          	addi	a3,a3,-1328 # ffffffffc0206438 <commands+0x1420>
ffffffffc0203970:	00002617          	auipc	a2,0x2
ffffffffc0203974:	04060613          	addi	a2,a2,64 # ffffffffc02059b0 <commands+0x998>
ffffffffc0203978:	0df00593          	li	a1,223
ffffffffc020397c:	00003517          	auipc	a0,0x3
ffffffffc0203980:	e5c50513          	addi	a0,a0,-420 # ffffffffc02067d8 <commands+0x17c0>
ffffffffc0203984:	851fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0203988:	00003697          	auipc	a3,0x3
ffffffffc020398c:	f9068693          	addi	a3,a3,-112 # ffffffffc0206918 <commands+0x1900>
ffffffffc0203990:	00002617          	auipc	a2,0x2
ffffffffc0203994:	02060613          	addi	a2,a2,32 # ffffffffc02059b0 <commands+0x998>
ffffffffc0203998:	0dd00593          	li	a1,221
ffffffffc020399c:	00003517          	auipc	a0,0x3
ffffffffc02039a0:	e3c50513          	addi	a0,a0,-452 # ffffffffc02067d8 <commands+0x17c0>
ffffffffc02039a4:	831fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc02039a8:	00003697          	auipc	a3,0x3
ffffffffc02039ac:	fb068693          	addi	a3,a3,-80 # ffffffffc0206958 <commands+0x1940>
ffffffffc02039b0:	00002617          	auipc	a2,0x2
ffffffffc02039b4:	00060613          	mv	a2,a2
ffffffffc02039b8:	0dc00593          	li	a1,220
ffffffffc02039bc:	00003517          	auipc	a0,0x3
ffffffffc02039c0:	e1c50513          	addi	a0,a0,-484 # ffffffffc02067d8 <commands+0x17c0>
ffffffffc02039c4:	811fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02039c8:	00003697          	auipc	a3,0x3
ffffffffc02039cc:	e2868693          	addi	a3,a3,-472 # ffffffffc02067f0 <commands+0x17d8>
ffffffffc02039d0:	00002617          	auipc	a2,0x2
ffffffffc02039d4:	fe060613          	addi	a2,a2,-32 # ffffffffc02059b0 <commands+0x998>
ffffffffc02039d8:	0b900593          	li	a1,185
ffffffffc02039dc:	00003517          	auipc	a0,0x3
ffffffffc02039e0:	dfc50513          	addi	a0,a0,-516 # ffffffffc02067d8 <commands+0x17c0>
ffffffffc02039e4:	ff0fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02039e8:	00003697          	auipc	a3,0x3
ffffffffc02039ec:	f3068693          	addi	a3,a3,-208 # ffffffffc0206918 <commands+0x1900>
ffffffffc02039f0:	00002617          	auipc	a2,0x2
ffffffffc02039f4:	fc060613          	addi	a2,a2,-64 # ffffffffc02059b0 <commands+0x998>
ffffffffc02039f8:	0d600593          	li	a1,214
ffffffffc02039fc:	00003517          	auipc	a0,0x3
ffffffffc0203a00:	ddc50513          	addi	a0,a0,-548 # ffffffffc02067d8 <commands+0x17c0>
ffffffffc0203a04:	fd0fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0203a08:	00003697          	auipc	a3,0x3
ffffffffc0203a0c:	e2868693          	addi	a3,a3,-472 # ffffffffc0206830 <commands+0x1818>
ffffffffc0203a10:	00002617          	auipc	a2,0x2
ffffffffc0203a14:	fa060613          	addi	a2,a2,-96 # ffffffffc02059b0 <commands+0x998>
ffffffffc0203a18:	0d400593          	li	a1,212
ffffffffc0203a1c:	00003517          	auipc	a0,0x3
ffffffffc0203a20:	dbc50513          	addi	a0,a0,-580 # ffffffffc02067d8 <commands+0x17c0>
ffffffffc0203a24:	fb0fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0203a28:	00003697          	auipc	a3,0x3
ffffffffc0203a2c:	de868693          	addi	a3,a3,-536 # ffffffffc0206810 <commands+0x17f8>
ffffffffc0203a30:	00002617          	auipc	a2,0x2
ffffffffc0203a34:	f8060613          	addi	a2,a2,-128 # ffffffffc02059b0 <commands+0x998>
ffffffffc0203a38:	0d300593          	li	a1,211
ffffffffc0203a3c:	00003517          	auipc	a0,0x3
ffffffffc0203a40:	d9c50513          	addi	a0,a0,-612 # ffffffffc02067d8 <commands+0x17c0>
ffffffffc0203a44:	f90fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0203a48:	00003697          	auipc	a3,0x3
ffffffffc0203a4c:	de868693          	addi	a3,a3,-536 # ffffffffc0206830 <commands+0x1818>
ffffffffc0203a50:	00002617          	auipc	a2,0x2
ffffffffc0203a54:	f6060613          	addi	a2,a2,-160 # ffffffffc02059b0 <commands+0x998>
ffffffffc0203a58:	0bb00593          	li	a1,187
ffffffffc0203a5c:	00003517          	auipc	a0,0x3
ffffffffc0203a60:	d7c50513          	addi	a0,a0,-644 # ffffffffc02067d8 <commands+0x17c0>
ffffffffc0203a64:	f70fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(count == 0);
ffffffffc0203a68:	00003697          	auipc	a3,0x3
ffffffffc0203a6c:	06068693          	addi	a3,a3,96 # ffffffffc0206ac8 <commands+0x1ab0>
ffffffffc0203a70:	00002617          	auipc	a2,0x2
ffffffffc0203a74:	f4060613          	addi	a2,a2,-192 # ffffffffc02059b0 <commands+0x998>
ffffffffc0203a78:	12500593          	li	a1,293
ffffffffc0203a7c:	00003517          	auipc	a0,0x3
ffffffffc0203a80:	d5c50513          	addi	a0,a0,-676 # ffffffffc02067d8 <commands+0x17c0>
ffffffffc0203a84:	f50fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(nr_free == 0);
ffffffffc0203a88:	00003697          	auipc	a3,0x3
ffffffffc0203a8c:	9b068693          	addi	a3,a3,-1616 # ffffffffc0206438 <commands+0x1420>
ffffffffc0203a90:	00002617          	auipc	a2,0x2
ffffffffc0203a94:	f2060613          	addi	a2,a2,-224 # ffffffffc02059b0 <commands+0x998>
ffffffffc0203a98:	11a00593          	li	a1,282
ffffffffc0203a9c:	00003517          	auipc	a0,0x3
ffffffffc0203aa0:	d3c50513          	addi	a0,a0,-708 # ffffffffc02067d8 <commands+0x17c0>
ffffffffc0203aa4:	f30fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0203aa8:	00003697          	auipc	a3,0x3
ffffffffc0203aac:	e7068693          	addi	a3,a3,-400 # ffffffffc0206918 <commands+0x1900>
ffffffffc0203ab0:	00002617          	auipc	a2,0x2
ffffffffc0203ab4:	f0060613          	addi	a2,a2,-256 # ffffffffc02059b0 <commands+0x998>
ffffffffc0203ab8:	11800593          	li	a1,280
ffffffffc0203abc:	00003517          	auipc	a0,0x3
ffffffffc0203ac0:	d1c50513          	addi	a0,a0,-740 # ffffffffc02067d8 <commands+0x17c0>
ffffffffc0203ac4:	f10fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0203ac8:	00003697          	auipc	a3,0x3
ffffffffc0203acc:	e1068693          	addi	a3,a3,-496 # ffffffffc02068d8 <commands+0x18c0>
ffffffffc0203ad0:	00002617          	auipc	a2,0x2
ffffffffc0203ad4:	ee060613          	addi	a2,a2,-288 # ffffffffc02059b0 <commands+0x998>
ffffffffc0203ad8:	0c100593          	li	a1,193
ffffffffc0203adc:	00003517          	auipc	a0,0x3
ffffffffc0203ae0:	cfc50513          	addi	a0,a0,-772 # ffffffffc02067d8 <commands+0x17c0>
ffffffffc0203ae4:	ef0fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0203ae8:	00003697          	auipc	a3,0x3
ffffffffc0203aec:	fa068693          	addi	a3,a3,-96 # ffffffffc0206a88 <commands+0x1a70>
ffffffffc0203af0:	00002617          	auipc	a2,0x2
ffffffffc0203af4:	ec060613          	addi	a2,a2,-320 # ffffffffc02059b0 <commands+0x998>
ffffffffc0203af8:	11200593          	li	a1,274
ffffffffc0203afc:	00003517          	auipc	a0,0x3
ffffffffc0203b00:	cdc50513          	addi	a0,a0,-804 # ffffffffc02067d8 <commands+0x17c0>
ffffffffc0203b04:	ed0fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0203b08:	00003697          	auipc	a3,0x3
ffffffffc0203b0c:	f6068693          	addi	a3,a3,-160 # ffffffffc0206a68 <commands+0x1a50>
ffffffffc0203b10:	00002617          	auipc	a2,0x2
ffffffffc0203b14:	ea060613          	addi	a2,a2,-352 # ffffffffc02059b0 <commands+0x998>
ffffffffc0203b18:	11000593          	li	a1,272
ffffffffc0203b1c:	00003517          	auipc	a0,0x3
ffffffffc0203b20:	cbc50513          	addi	a0,a0,-836 # ffffffffc02067d8 <commands+0x17c0>
ffffffffc0203b24:	eb0fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0203b28:	00003697          	auipc	a3,0x3
ffffffffc0203b2c:	f1868693          	addi	a3,a3,-232 # ffffffffc0206a40 <commands+0x1a28>
ffffffffc0203b30:	00002617          	auipc	a2,0x2
ffffffffc0203b34:	e8060613          	addi	a2,a2,-384 # ffffffffc02059b0 <commands+0x998>
ffffffffc0203b38:	10e00593          	li	a1,270
ffffffffc0203b3c:	00003517          	auipc	a0,0x3
ffffffffc0203b40:	c9c50513          	addi	a0,a0,-868 # ffffffffc02067d8 <commands+0x17c0>
ffffffffc0203b44:	e90fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0203b48:	00003697          	auipc	a3,0x3
ffffffffc0203b4c:	ed068693          	addi	a3,a3,-304 # ffffffffc0206a18 <commands+0x1a00>
ffffffffc0203b50:	00002617          	auipc	a2,0x2
ffffffffc0203b54:	e6060613          	addi	a2,a2,-416 # ffffffffc02059b0 <commands+0x998>
ffffffffc0203b58:	10d00593          	li	a1,269
ffffffffc0203b5c:	00003517          	auipc	a0,0x3
ffffffffc0203b60:	c7c50513          	addi	a0,a0,-900 # ffffffffc02067d8 <commands+0x17c0>
ffffffffc0203b64:	e70fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(p0 + 2 == p1);
ffffffffc0203b68:	00003697          	auipc	a3,0x3
ffffffffc0203b6c:	ea068693          	addi	a3,a3,-352 # ffffffffc0206a08 <commands+0x19f0>
ffffffffc0203b70:	00002617          	auipc	a2,0x2
ffffffffc0203b74:	e4060613          	addi	a2,a2,-448 # ffffffffc02059b0 <commands+0x998>
ffffffffc0203b78:	10800593          	li	a1,264
ffffffffc0203b7c:	00003517          	auipc	a0,0x3
ffffffffc0203b80:	c5c50513          	addi	a0,a0,-932 # ffffffffc02067d8 <commands+0x17c0>
ffffffffc0203b84:	e50fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0203b88:	00003697          	auipc	a3,0x3
ffffffffc0203b8c:	d9068693          	addi	a3,a3,-624 # ffffffffc0206918 <commands+0x1900>
ffffffffc0203b90:	00002617          	auipc	a2,0x2
ffffffffc0203b94:	e2060613          	addi	a2,a2,-480 # ffffffffc02059b0 <commands+0x998>
ffffffffc0203b98:	10700593          	li	a1,263
ffffffffc0203b9c:	00003517          	auipc	a0,0x3
ffffffffc0203ba0:	c3c50513          	addi	a0,a0,-964 # ffffffffc02067d8 <commands+0x17c0>
ffffffffc0203ba4:	e30fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0203ba8:	00003697          	auipc	a3,0x3
ffffffffc0203bac:	e4068693          	addi	a3,a3,-448 # ffffffffc02069e8 <commands+0x19d0>
ffffffffc0203bb0:	00002617          	auipc	a2,0x2
ffffffffc0203bb4:	e0060613          	addi	a2,a2,-512 # ffffffffc02059b0 <commands+0x998>
ffffffffc0203bb8:	10600593          	li	a1,262
ffffffffc0203bbc:	00003517          	auipc	a0,0x3
ffffffffc0203bc0:	c1c50513          	addi	a0,a0,-996 # ffffffffc02067d8 <commands+0x17c0>
ffffffffc0203bc4:	e10fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0203bc8:	00003697          	auipc	a3,0x3
ffffffffc0203bcc:	df068693          	addi	a3,a3,-528 # ffffffffc02069b8 <commands+0x19a0>
ffffffffc0203bd0:	00002617          	auipc	a2,0x2
ffffffffc0203bd4:	de060613          	addi	a2,a2,-544 # ffffffffc02059b0 <commands+0x998>
ffffffffc0203bd8:	10500593          	li	a1,261
ffffffffc0203bdc:	00003517          	auipc	a0,0x3
ffffffffc0203be0:	bfc50513          	addi	a0,a0,-1028 # ffffffffc02067d8 <commands+0x17c0>
ffffffffc0203be4:	df0fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0203be8:	00003697          	auipc	a3,0x3
ffffffffc0203bec:	db868693          	addi	a3,a3,-584 # ffffffffc02069a0 <commands+0x1988>
ffffffffc0203bf0:	00002617          	auipc	a2,0x2
ffffffffc0203bf4:	dc060613          	addi	a2,a2,-576 # ffffffffc02059b0 <commands+0x998>
ffffffffc0203bf8:	10400593          	li	a1,260
ffffffffc0203bfc:	00003517          	auipc	a0,0x3
ffffffffc0203c00:	bdc50513          	addi	a0,a0,-1060 # ffffffffc02067d8 <commands+0x17c0>
ffffffffc0203c04:	dd0fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0203c08:	00003697          	auipc	a3,0x3
ffffffffc0203c0c:	d1068693          	addi	a3,a3,-752 # ffffffffc0206918 <commands+0x1900>
ffffffffc0203c10:	00002617          	auipc	a2,0x2
ffffffffc0203c14:	da060613          	addi	a2,a2,-608 # ffffffffc02059b0 <commands+0x998>
ffffffffc0203c18:	0fe00593          	li	a1,254
ffffffffc0203c1c:	00003517          	auipc	a0,0x3
ffffffffc0203c20:	bbc50513          	addi	a0,a0,-1092 # ffffffffc02067d8 <commands+0x17c0>
ffffffffc0203c24:	db0fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(!PageProperty(p0));
ffffffffc0203c28:	00003697          	auipc	a3,0x3
ffffffffc0203c2c:	d6068693          	addi	a3,a3,-672 # ffffffffc0206988 <commands+0x1970>
ffffffffc0203c30:	00002617          	auipc	a2,0x2
ffffffffc0203c34:	d8060613          	addi	a2,a2,-640 # ffffffffc02059b0 <commands+0x998>
ffffffffc0203c38:	0f900593          	li	a1,249
ffffffffc0203c3c:	00003517          	auipc	a0,0x3
ffffffffc0203c40:	b9c50513          	addi	a0,a0,-1124 # ffffffffc02067d8 <commands+0x17c0>
ffffffffc0203c44:	d90fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0203c48:	00003697          	auipc	a3,0x3
ffffffffc0203c4c:	e6068693          	addi	a3,a3,-416 # ffffffffc0206aa8 <commands+0x1a90>
ffffffffc0203c50:	00002617          	auipc	a2,0x2
ffffffffc0203c54:	d6060613          	addi	a2,a2,-672 # ffffffffc02059b0 <commands+0x998>
ffffffffc0203c58:	11700593          	li	a1,279
ffffffffc0203c5c:	00003517          	auipc	a0,0x3
ffffffffc0203c60:	b7c50513          	addi	a0,a0,-1156 # ffffffffc02067d8 <commands+0x17c0>
ffffffffc0203c64:	d70fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(total == 0);
ffffffffc0203c68:	00003697          	auipc	a3,0x3
ffffffffc0203c6c:	e7068693          	addi	a3,a3,-400 # ffffffffc0206ad8 <commands+0x1ac0>
ffffffffc0203c70:	00002617          	auipc	a2,0x2
ffffffffc0203c74:	d4060613          	addi	a2,a2,-704 # ffffffffc02059b0 <commands+0x998>
ffffffffc0203c78:	12600593          	li	a1,294
ffffffffc0203c7c:	00003517          	auipc	a0,0x3
ffffffffc0203c80:	b5c50513          	addi	a0,a0,-1188 # ffffffffc02067d8 <commands+0x17c0>
ffffffffc0203c84:	d50fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(total == nr_free_pages());
ffffffffc0203c88:	00002697          	auipc	a3,0x2
ffffffffc0203c8c:	61068693          	addi	a3,a3,1552 # ffffffffc0206298 <commands+0x1280>
ffffffffc0203c90:	00002617          	auipc	a2,0x2
ffffffffc0203c94:	d2060613          	addi	a2,a2,-736 # ffffffffc02059b0 <commands+0x998>
ffffffffc0203c98:	0f300593          	li	a1,243
ffffffffc0203c9c:	00003517          	auipc	a0,0x3
ffffffffc0203ca0:	b3c50513          	addi	a0,a0,-1220 # ffffffffc02067d8 <commands+0x17c0>
ffffffffc0203ca4:	d30fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0203ca8:	00003697          	auipc	a3,0x3
ffffffffc0203cac:	b6868693          	addi	a3,a3,-1176 # ffffffffc0206810 <commands+0x17f8>
ffffffffc0203cb0:	00002617          	auipc	a2,0x2
ffffffffc0203cb4:	d0060613          	addi	a2,a2,-768 # ffffffffc02059b0 <commands+0x998>
ffffffffc0203cb8:	0ba00593          	li	a1,186
ffffffffc0203cbc:	00003517          	auipc	a0,0x3
ffffffffc0203cc0:	b1c50513          	addi	a0,a0,-1252 # ffffffffc02067d8 <commands+0x17c0>
ffffffffc0203cc4:	d10fc0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc0203cc8 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc0203cc8:	1141                	addi	sp,sp,-16
ffffffffc0203cca:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0203ccc:	16058e63          	beqz	a1,ffffffffc0203e48 <default_free_pages+0x180>
    for (; p != base + n; p ++) {
ffffffffc0203cd0:	00659693          	slli	a3,a1,0x6
ffffffffc0203cd4:	96aa                	add	a3,a3,a0
ffffffffc0203cd6:	02d50d63          	beq	a0,a3,ffffffffc0203d10 <default_free_pages+0x48>
ffffffffc0203cda:	651c                	ld	a5,8(a0)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0203cdc:	8b85                	andi	a5,a5,1
ffffffffc0203cde:	14079563          	bnez	a5,ffffffffc0203e28 <default_free_pages+0x160>
ffffffffc0203ce2:	651c                	ld	a5,8(a0)
ffffffffc0203ce4:	8385                	srli	a5,a5,0x1
ffffffffc0203ce6:	8b85                	andi	a5,a5,1
ffffffffc0203ce8:	14079063          	bnez	a5,ffffffffc0203e28 <default_free_pages+0x160>
ffffffffc0203cec:	87aa                	mv	a5,a0
ffffffffc0203cee:	a809                	j	ffffffffc0203d00 <default_free_pages+0x38>
ffffffffc0203cf0:	6798                	ld	a4,8(a5)
ffffffffc0203cf2:	8b05                	andi	a4,a4,1
ffffffffc0203cf4:	12071a63          	bnez	a4,ffffffffc0203e28 <default_free_pages+0x160>
ffffffffc0203cf8:	6798                	ld	a4,8(a5)
ffffffffc0203cfa:	8b09                	andi	a4,a4,2
ffffffffc0203cfc:	12071663          	bnez	a4,ffffffffc0203e28 <default_free_pages+0x160>
        p->flags = 0;
ffffffffc0203d00:	0007b423          	sd	zero,8(a5)
    page->ref = val;
ffffffffc0203d04:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0203d08:	04078793          	addi	a5,a5,64
ffffffffc0203d0c:	fed792e3          	bne	a5,a3,ffffffffc0203cf0 <default_free_pages+0x28>
    base->property = n;
ffffffffc0203d10:	2581                	sext.w	a1,a1
ffffffffc0203d12:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc0203d14:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0203d18:	4789                	li	a5,2
ffffffffc0203d1a:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc0203d1e:	00012697          	auipc	a3,0x12
ffffffffc0203d22:	8ba68693          	addi	a3,a3,-1862 # ffffffffc02155d8 <free_area>
ffffffffc0203d26:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0203d28:	669c                	ld	a5,8(a3)
ffffffffc0203d2a:	9db9                	addw	a1,a1,a4
ffffffffc0203d2c:	00012717          	auipc	a4,0x12
ffffffffc0203d30:	8ab72e23          	sw	a1,-1860(a4) # ffffffffc02155e8 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc0203d34:	0cd78163          	beq	a5,a3,ffffffffc0203df6 <default_free_pages+0x12e>
            struct Page* page = le2page(le, page_link);
ffffffffc0203d38:	fe878713          	addi	a4,a5,-24
ffffffffc0203d3c:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0203d3e:	4801                	li	a6,0
ffffffffc0203d40:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc0203d44:	00e56a63          	bltu	a0,a4,ffffffffc0203d58 <default_free_pages+0x90>
    return listelm->next;
ffffffffc0203d48:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0203d4a:	04d70f63          	beq	a4,a3,ffffffffc0203da8 <default_free_pages+0xe0>
        while ((le = list_next(le)) != &free_list) {
ffffffffc0203d4e:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0203d50:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0203d54:	fee57ae3          	bgeu	a0,a4,ffffffffc0203d48 <default_free_pages+0x80>
ffffffffc0203d58:	00080663          	beqz	a6,ffffffffc0203d64 <default_free_pages+0x9c>
ffffffffc0203d5c:	00012817          	auipc	a6,0x12
ffffffffc0203d60:	86b83e23          	sd	a1,-1924(a6) # ffffffffc02155d8 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0203d64:	638c                	ld	a1,0(a5)
    prev->next = next->prev = elm;
ffffffffc0203d66:	e390                	sd	a2,0(a5)
ffffffffc0203d68:	e590                	sd	a2,8(a1)
    elm->next = next;
ffffffffc0203d6a:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0203d6c:	ed0c                	sd	a1,24(a0)
    if (le != &free_list) {
ffffffffc0203d6e:	06d58a63          	beq	a1,a3,ffffffffc0203de2 <default_free_pages+0x11a>
        if (p + p->property == base) {
ffffffffc0203d72:	ff85a603          	lw	a2,-8(a1) # ff8 <BASE_ADDRESS-0xffffffffc01ff008>
        p = le2page(le, page_link);
ffffffffc0203d76:	fe858713          	addi	a4,a1,-24
        if (p + p->property == base) {
ffffffffc0203d7a:	02061793          	slli	a5,a2,0x20
ffffffffc0203d7e:	83e9                	srli	a5,a5,0x1a
ffffffffc0203d80:	97ba                	add	a5,a5,a4
ffffffffc0203d82:	04f51b63          	bne	a0,a5,ffffffffc0203dd8 <default_free_pages+0x110>
            p->property += base->property;
ffffffffc0203d86:	491c                	lw	a5,16(a0)
ffffffffc0203d88:	9e3d                	addw	a2,a2,a5
ffffffffc0203d8a:	fec5ac23          	sw	a2,-8(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0203d8e:	57f5                	li	a5,-3
ffffffffc0203d90:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0203d94:	01853803          	ld	a6,24(a0)
ffffffffc0203d98:	7110                	ld	a2,32(a0)
            base = p;
ffffffffc0203d9a:	853a                	mv	a0,a4
    prev->next = next;
ffffffffc0203d9c:	00c83423          	sd	a2,8(a6)
    next->prev = prev;
ffffffffc0203da0:	659c                	ld	a5,8(a1)
ffffffffc0203da2:	01063023          	sd	a6,0(a2)
ffffffffc0203da6:	a815                	j	ffffffffc0203dda <default_free_pages+0x112>
    prev->next = next->prev = elm;
ffffffffc0203da8:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0203daa:	f114                	sd	a3,32(a0)
ffffffffc0203dac:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0203dae:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc0203db0:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0203db2:	00d70563          	beq	a4,a3,ffffffffc0203dbc <default_free_pages+0xf4>
ffffffffc0203db6:	4805                	li	a6,1
ffffffffc0203db8:	87ba                	mv	a5,a4
ffffffffc0203dba:	bf59                	j	ffffffffc0203d50 <default_free_pages+0x88>
ffffffffc0203dbc:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc0203dbe:	85be                	mv	a1,a5
    if (le != &free_list) {
ffffffffc0203dc0:	00d78d63          	beq	a5,a3,ffffffffc0203dda <default_free_pages+0x112>
        if (p + p->property == base) {
ffffffffc0203dc4:	ff85a603          	lw	a2,-8(a1)
        p = le2page(le, page_link);
ffffffffc0203dc8:	fe858713          	addi	a4,a1,-24
        if (p + p->property == base) {
ffffffffc0203dcc:	02061793          	slli	a5,a2,0x20
ffffffffc0203dd0:	83e9                	srli	a5,a5,0x1a
ffffffffc0203dd2:	97ba                	add	a5,a5,a4
ffffffffc0203dd4:	faf509e3          	beq	a0,a5,ffffffffc0203d86 <default_free_pages+0xbe>
ffffffffc0203dd8:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc0203dda:	fe878713          	addi	a4,a5,-24
ffffffffc0203dde:	00d78963          	beq	a5,a3,ffffffffc0203df0 <default_free_pages+0x128>
        if (base + base->property == p) {
ffffffffc0203de2:	4910                	lw	a2,16(a0)
ffffffffc0203de4:	02061693          	slli	a3,a2,0x20
ffffffffc0203de8:	82e9                	srli	a3,a3,0x1a
ffffffffc0203dea:	96aa                	add	a3,a3,a0
ffffffffc0203dec:	00d70e63          	beq	a4,a3,ffffffffc0203e08 <default_free_pages+0x140>
}
ffffffffc0203df0:	60a2                	ld	ra,8(sp)
ffffffffc0203df2:	0141                	addi	sp,sp,16
ffffffffc0203df4:	8082                	ret
ffffffffc0203df6:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0203df8:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc0203dfc:	e398                	sd	a4,0(a5)
ffffffffc0203dfe:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0203e00:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0203e02:	ed1c                	sd	a5,24(a0)
}
ffffffffc0203e04:	0141                	addi	sp,sp,16
ffffffffc0203e06:	8082                	ret
            base->property += p->property;
ffffffffc0203e08:	ff87a703          	lw	a4,-8(a5)
ffffffffc0203e0c:	ff078693          	addi	a3,a5,-16
ffffffffc0203e10:	9e39                	addw	a2,a2,a4
ffffffffc0203e12:	c910                	sw	a2,16(a0)
ffffffffc0203e14:	5775                	li	a4,-3
ffffffffc0203e16:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0203e1a:	6398                	ld	a4,0(a5)
ffffffffc0203e1c:	679c                	ld	a5,8(a5)
}
ffffffffc0203e1e:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0203e20:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0203e22:	e398                	sd	a4,0(a5)
ffffffffc0203e24:	0141                	addi	sp,sp,16
ffffffffc0203e26:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0203e28:	00003697          	auipc	a3,0x3
ffffffffc0203e2c:	cc068693          	addi	a3,a3,-832 # ffffffffc0206ae8 <commands+0x1ad0>
ffffffffc0203e30:	00002617          	auipc	a2,0x2
ffffffffc0203e34:	b8060613          	addi	a2,a2,-1152 # ffffffffc02059b0 <commands+0x998>
ffffffffc0203e38:	08300593          	li	a1,131
ffffffffc0203e3c:	00003517          	auipc	a0,0x3
ffffffffc0203e40:	99c50513          	addi	a0,a0,-1636 # ffffffffc02067d8 <commands+0x17c0>
ffffffffc0203e44:	b90fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(n > 0);
ffffffffc0203e48:	00003697          	auipc	a3,0x3
ffffffffc0203e4c:	cc868693          	addi	a3,a3,-824 # ffffffffc0206b10 <commands+0x1af8>
ffffffffc0203e50:	00002617          	auipc	a2,0x2
ffffffffc0203e54:	b6060613          	addi	a2,a2,-1184 # ffffffffc02059b0 <commands+0x998>
ffffffffc0203e58:	08000593          	li	a1,128
ffffffffc0203e5c:	00003517          	auipc	a0,0x3
ffffffffc0203e60:	97c50513          	addi	a0,a0,-1668 # ffffffffc02067d8 <commands+0x17c0>
ffffffffc0203e64:	b70fc0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc0203e68 <default_alloc_pages>:
    assert(n > 0);
ffffffffc0203e68:	c959                	beqz	a0,ffffffffc0203efe <default_alloc_pages+0x96>
    if (n > nr_free) {
ffffffffc0203e6a:	00011597          	auipc	a1,0x11
ffffffffc0203e6e:	76e58593          	addi	a1,a1,1902 # ffffffffc02155d8 <free_area>
ffffffffc0203e72:	0105a803          	lw	a6,16(a1)
ffffffffc0203e76:	862a                	mv	a2,a0
ffffffffc0203e78:	02081793          	slli	a5,a6,0x20
ffffffffc0203e7c:	9381                	srli	a5,a5,0x20
ffffffffc0203e7e:	00a7ee63          	bltu	a5,a0,ffffffffc0203e9a <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc0203e82:	87ae                	mv	a5,a1
ffffffffc0203e84:	a801                	j	ffffffffc0203e94 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc0203e86:	ff87a703          	lw	a4,-8(a5)
ffffffffc0203e8a:	02071693          	slli	a3,a4,0x20
ffffffffc0203e8e:	9281                	srli	a3,a3,0x20
ffffffffc0203e90:	00c6f763          	bgeu	a3,a2,ffffffffc0203e9e <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc0203e94:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0203e96:	feb798e3          	bne	a5,a1,ffffffffc0203e86 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc0203e9a:	4501                	li	a0,0
}
ffffffffc0203e9c:	8082                	ret
        struct Page *p = le2page(le, page_link);
ffffffffc0203e9e:	fe878513          	addi	a0,a5,-24
    if (page != NULL) {
ffffffffc0203ea2:	dd6d                	beqz	a0,ffffffffc0203e9c <default_alloc_pages+0x34>
    return listelm->prev;
ffffffffc0203ea4:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0203ea8:	0087b303          	ld	t1,8(a5)
    prev->next = next;
ffffffffc0203eac:	00060e1b          	sext.w	t3,a2
ffffffffc0203eb0:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc0203eb4:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc0203eb8:	02d67863          	bgeu	a2,a3,ffffffffc0203ee8 <default_alloc_pages+0x80>
            struct Page *p = page + n;
ffffffffc0203ebc:	061a                	slli	a2,a2,0x6
ffffffffc0203ebe:	962a                	add	a2,a2,a0
            p->property = page->property - n;
ffffffffc0203ec0:	41c7073b          	subw	a4,a4,t3
ffffffffc0203ec4:	ca18                	sw	a4,16(a2)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0203ec6:	00860693          	addi	a3,a2,8
ffffffffc0203eca:	4709                	li	a4,2
ffffffffc0203ecc:	40e6b02f          	amoor.d	zero,a4,(a3)
    __list_add(elm, listelm, listelm->next);
ffffffffc0203ed0:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc0203ed4:	01860693          	addi	a3,a2,24
    prev->next = next->prev = elm;
ffffffffc0203ed8:	0105a803          	lw	a6,16(a1)
ffffffffc0203edc:	e314                	sd	a3,0(a4)
ffffffffc0203ede:	00d8b423          	sd	a3,8(a7)
    elm->next = next;
ffffffffc0203ee2:	f218                	sd	a4,32(a2)
    elm->prev = prev;
ffffffffc0203ee4:	01163c23          	sd	a7,24(a2)
        nr_free -= n;
ffffffffc0203ee8:	41c8083b          	subw	a6,a6,t3
ffffffffc0203eec:	00011717          	auipc	a4,0x11
ffffffffc0203ef0:	6f072e23          	sw	a6,1788(a4) # ffffffffc02155e8 <free_area+0x10>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0203ef4:	5775                	li	a4,-3
ffffffffc0203ef6:	17c1                	addi	a5,a5,-16
ffffffffc0203ef8:	60e7b02f          	amoand.d	zero,a4,(a5)
ffffffffc0203efc:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc0203efe:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0203f00:	00003697          	auipc	a3,0x3
ffffffffc0203f04:	c1068693          	addi	a3,a3,-1008 # ffffffffc0206b10 <commands+0x1af8>
ffffffffc0203f08:	00002617          	auipc	a2,0x2
ffffffffc0203f0c:	aa860613          	addi	a2,a2,-1368 # ffffffffc02059b0 <commands+0x998>
ffffffffc0203f10:	06200593          	li	a1,98
ffffffffc0203f14:	00003517          	auipc	a0,0x3
ffffffffc0203f18:	8c450513          	addi	a0,a0,-1852 # ffffffffc02067d8 <commands+0x17c0>
default_alloc_pages(size_t n) {
ffffffffc0203f1c:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0203f1e:	ab6fc0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc0203f22 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc0203f22:	1141                	addi	sp,sp,-16
ffffffffc0203f24:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0203f26:	c1ed                	beqz	a1,ffffffffc0204008 <default_init_memmap+0xe6>
    for (; p != base + n; p ++) {
ffffffffc0203f28:	00659693          	slli	a3,a1,0x6
ffffffffc0203f2c:	96aa                	add	a3,a3,a0
ffffffffc0203f2e:	02d50463          	beq	a0,a3,ffffffffc0203f56 <default_init_memmap+0x34>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0203f32:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc0203f34:	87aa                	mv	a5,a0
ffffffffc0203f36:	8b05                	andi	a4,a4,1
ffffffffc0203f38:	e709                	bnez	a4,ffffffffc0203f42 <default_init_memmap+0x20>
ffffffffc0203f3a:	a07d                	j	ffffffffc0203fe8 <default_init_memmap+0xc6>
ffffffffc0203f3c:	6798                	ld	a4,8(a5)
ffffffffc0203f3e:	8b05                	andi	a4,a4,1
ffffffffc0203f40:	c745                	beqz	a4,ffffffffc0203fe8 <default_init_memmap+0xc6>
        p->flags = p->property = 0;
ffffffffc0203f42:	0007a823          	sw	zero,16(a5)
ffffffffc0203f46:	0007b423          	sd	zero,8(a5)
ffffffffc0203f4a:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0203f4e:	04078793          	addi	a5,a5,64
ffffffffc0203f52:	fed795e3          	bne	a5,a3,ffffffffc0203f3c <default_init_memmap+0x1a>
    base->property = n;
ffffffffc0203f56:	2581                	sext.w	a1,a1
ffffffffc0203f58:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0203f5a:	4789                	li	a5,2
ffffffffc0203f5c:	00850713          	addi	a4,a0,8
ffffffffc0203f60:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0203f64:	00011697          	auipc	a3,0x11
ffffffffc0203f68:	67468693          	addi	a3,a3,1652 # ffffffffc02155d8 <free_area>
ffffffffc0203f6c:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0203f6e:	669c                	ld	a5,8(a3)
ffffffffc0203f70:	9db9                	addw	a1,a1,a4
ffffffffc0203f72:	00011717          	auipc	a4,0x11
ffffffffc0203f76:	66b72b23          	sw	a1,1654(a4) # ffffffffc02155e8 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc0203f7a:	04d78a63          	beq	a5,a3,ffffffffc0203fce <default_init_memmap+0xac>
            struct Page* page = le2page(le, page_link);
ffffffffc0203f7e:	fe878713          	addi	a4,a5,-24
ffffffffc0203f82:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0203f84:	4801                	li	a6,0
ffffffffc0203f86:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc0203f8a:	00e56a63          	bltu	a0,a4,ffffffffc0203f9e <default_init_memmap+0x7c>
    return listelm->next;
ffffffffc0203f8e:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0203f90:	02d70563          	beq	a4,a3,ffffffffc0203fba <default_init_memmap+0x98>
        while ((le = list_next(le)) != &free_list) {
ffffffffc0203f94:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0203f96:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0203f9a:	fee57ae3          	bgeu	a0,a4,ffffffffc0203f8e <default_init_memmap+0x6c>
ffffffffc0203f9e:	00080663          	beqz	a6,ffffffffc0203faa <default_init_memmap+0x88>
ffffffffc0203fa2:	00011717          	auipc	a4,0x11
ffffffffc0203fa6:	62b73b23          	sd	a1,1590(a4) # ffffffffc02155d8 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0203faa:	6398                	ld	a4,0(a5)
}
ffffffffc0203fac:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0203fae:	e390                	sd	a2,0(a5)
ffffffffc0203fb0:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0203fb2:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0203fb4:	ed18                	sd	a4,24(a0)
ffffffffc0203fb6:	0141                	addi	sp,sp,16
ffffffffc0203fb8:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0203fba:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0203fbc:	f114                	sd	a3,32(a0)
ffffffffc0203fbe:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0203fc0:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc0203fc2:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0203fc4:	00d70e63          	beq	a4,a3,ffffffffc0203fe0 <default_init_memmap+0xbe>
ffffffffc0203fc8:	4805                	li	a6,1
ffffffffc0203fca:	87ba                	mv	a5,a4
ffffffffc0203fcc:	b7e9                	j	ffffffffc0203f96 <default_init_memmap+0x74>
}
ffffffffc0203fce:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0203fd0:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc0203fd4:	e398                	sd	a4,0(a5)
ffffffffc0203fd6:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0203fd8:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0203fda:	ed1c                	sd	a5,24(a0)
}
ffffffffc0203fdc:	0141                	addi	sp,sp,16
ffffffffc0203fde:	8082                	ret
ffffffffc0203fe0:	60a2                	ld	ra,8(sp)
ffffffffc0203fe2:	e290                	sd	a2,0(a3)
ffffffffc0203fe4:	0141                	addi	sp,sp,16
ffffffffc0203fe6:	8082                	ret
        assert(PageReserved(p));
ffffffffc0203fe8:	00003697          	auipc	a3,0x3
ffffffffc0203fec:	b3068693          	addi	a3,a3,-1232 # ffffffffc0206b18 <commands+0x1b00>
ffffffffc0203ff0:	00002617          	auipc	a2,0x2
ffffffffc0203ff4:	9c060613          	addi	a2,a2,-1600 # ffffffffc02059b0 <commands+0x998>
ffffffffc0203ff8:	04900593          	li	a1,73
ffffffffc0203ffc:	00002517          	auipc	a0,0x2
ffffffffc0204000:	7dc50513          	addi	a0,a0,2012 # ffffffffc02067d8 <commands+0x17c0>
ffffffffc0204004:	9d0fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(n > 0);
ffffffffc0204008:	00003697          	auipc	a3,0x3
ffffffffc020400c:	b0868693          	addi	a3,a3,-1272 # ffffffffc0206b10 <commands+0x1af8>
ffffffffc0204010:	00002617          	auipc	a2,0x2
ffffffffc0204014:	9a060613          	addi	a2,a2,-1632 # ffffffffc02059b0 <commands+0x998>
ffffffffc0204018:	04600593          	li	a1,70
ffffffffc020401c:	00002517          	auipc	a0,0x2
ffffffffc0204020:	7bc50513          	addi	a0,a0,1980 # ffffffffc02067d8 <commands+0x17c0>
ffffffffc0204024:	9b0fc0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc0204028 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0204028:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc020402a:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc020402c:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc020402e:	c80fc0ef          	jal	ra,ffffffffc02004ae <ide_device_valid>
ffffffffc0204032:	cd01                	beqz	a0,ffffffffc020404a <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204034:	4505                	li	a0,1
ffffffffc0204036:	c7efc0ef          	jal	ra,ffffffffc02004b4 <ide_device_size>
}
ffffffffc020403a:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc020403c:	810d                	srli	a0,a0,0x3
ffffffffc020403e:	00011797          	auipc	a5,0x11
ffffffffc0204042:	54a7b523          	sd	a0,1354(a5) # ffffffffc0215588 <max_swap_offset>
}
ffffffffc0204046:	0141                	addi	sp,sp,16
ffffffffc0204048:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc020404a:	00003617          	auipc	a2,0x3
ffffffffc020404e:	b2e60613          	addi	a2,a2,-1234 # ffffffffc0206b78 <default_pmm_manager+0x50>
ffffffffc0204052:	45b5                	li	a1,13
ffffffffc0204054:	00003517          	auipc	a0,0x3
ffffffffc0204058:	b4450513          	addi	a0,a0,-1212 # ffffffffc0206b98 <default_pmm_manager+0x70>
ffffffffc020405c:	978fc0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc0204060 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0204060:	1141                	addi	sp,sp,-16
ffffffffc0204062:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204064:	00855793          	srli	a5,a0,0x8
ffffffffc0204068:	cfb9                	beqz	a5,ffffffffc02040c6 <swapfs_read+0x66>
ffffffffc020406a:	00011717          	auipc	a4,0x11
ffffffffc020406e:	51e70713          	addi	a4,a4,1310 # ffffffffc0215588 <max_swap_offset>
ffffffffc0204072:	6318                	ld	a4,0(a4)
ffffffffc0204074:	04e7f963          	bgeu	a5,a4,ffffffffc02040c6 <swapfs_read+0x66>
    return page - pages + nbase;
ffffffffc0204078:	00011717          	auipc	a4,0x11
ffffffffc020407c:	47870713          	addi	a4,a4,1144 # ffffffffc02154f0 <pages>
ffffffffc0204080:	6310                	ld	a2,0(a4)
ffffffffc0204082:	00003717          	auipc	a4,0x3
ffffffffc0204086:	f5670713          	addi	a4,a4,-170 # ffffffffc0206fd8 <nbase>
ffffffffc020408a:	40c58633          	sub	a2,a1,a2
ffffffffc020408e:	630c                	ld	a1,0(a4)
ffffffffc0204090:	8619                	srai	a2,a2,0x6
    return KADDR(page2pa(page));
ffffffffc0204092:	00011717          	auipc	a4,0x11
ffffffffc0204096:	3f670713          	addi	a4,a4,1014 # ffffffffc0215488 <npage>
    return page - pages + nbase;
ffffffffc020409a:	962e                	add	a2,a2,a1
    return KADDR(page2pa(page));
ffffffffc020409c:	6314                	ld	a3,0(a4)
ffffffffc020409e:	00c61713          	slli	a4,a2,0xc
ffffffffc02040a2:	8331                	srli	a4,a4,0xc
ffffffffc02040a4:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc02040a8:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc02040aa:	02d77a63          	bgeu	a4,a3,ffffffffc02040de <swapfs_read+0x7e>
ffffffffc02040ae:	00011797          	auipc	a5,0x11
ffffffffc02040b2:	43278793          	addi	a5,a5,1074 # ffffffffc02154e0 <va_pa_offset>
ffffffffc02040b6:	639c                	ld	a5,0(a5)
}
ffffffffc02040b8:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc02040ba:	46a1                	li	a3,8
ffffffffc02040bc:	963e                	add	a2,a2,a5
ffffffffc02040be:	4505                	li	a0,1
}
ffffffffc02040c0:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc02040c2:	bf8fc06f          	j	ffffffffc02004ba <ide_read_secs>
ffffffffc02040c6:	86aa                	mv	a3,a0
ffffffffc02040c8:	00003617          	auipc	a2,0x3
ffffffffc02040cc:	ae860613          	addi	a2,a2,-1304 # ffffffffc0206bb0 <default_pmm_manager+0x88>
ffffffffc02040d0:	45d1                	li	a1,20
ffffffffc02040d2:	00003517          	auipc	a0,0x3
ffffffffc02040d6:	ac650513          	addi	a0,a0,-1338 # ffffffffc0206b98 <default_pmm_manager+0x70>
ffffffffc02040da:	8fafc0ef          	jal	ra,ffffffffc02001d4 <__panic>
ffffffffc02040de:	86b2                	mv	a3,a2
ffffffffc02040e0:	06900593          	li	a1,105
ffffffffc02040e4:	00001617          	auipc	a2,0x1
ffffffffc02040e8:	77460613          	addi	a2,a2,1908 # ffffffffc0205858 <commands+0x840>
ffffffffc02040ec:	00001517          	auipc	a0,0x1
ffffffffc02040f0:	7c450513          	addi	a0,a0,1988 # ffffffffc02058b0 <commands+0x898>
ffffffffc02040f4:	8e0fc0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc02040f8 <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc02040f8:	1141                	addi	sp,sp,-16
ffffffffc02040fa:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc02040fc:	00855793          	srli	a5,a0,0x8
ffffffffc0204100:	cfb9                	beqz	a5,ffffffffc020415e <swapfs_write+0x66>
ffffffffc0204102:	00011717          	auipc	a4,0x11
ffffffffc0204106:	48670713          	addi	a4,a4,1158 # ffffffffc0215588 <max_swap_offset>
ffffffffc020410a:	6318                	ld	a4,0(a4)
ffffffffc020410c:	04e7f963          	bgeu	a5,a4,ffffffffc020415e <swapfs_write+0x66>
    return page - pages + nbase;
ffffffffc0204110:	00011717          	auipc	a4,0x11
ffffffffc0204114:	3e070713          	addi	a4,a4,992 # ffffffffc02154f0 <pages>
ffffffffc0204118:	6310                	ld	a2,0(a4)
ffffffffc020411a:	00003717          	auipc	a4,0x3
ffffffffc020411e:	ebe70713          	addi	a4,a4,-322 # ffffffffc0206fd8 <nbase>
ffffffffc0204122:	40c58633          	sub	a2,a1,a2
ffffffffc0204126:	630c                	ld	a1,0(a4)
ffffffffc0204128:	8619                	srai	a2,a2,0x6
    return KADDR(page2pa(page));
ffffffffc020412a:	00011717          	auipc	a4,0x11
ffffffffc020412e:	35e70713          	addi	a4,a4,862 # ffffffffc0215488 <npage>
    return page - pages + nbase;
ffffffffc0204132:	962e                	add	a2,a2,a1
    return KADDR(page2pa(page));
ffffffffc0204134:	6314                	ld	a3,0(a4)
ffffffffc0204136:	00c61713          	slli	a4,a2,0xc
ffffffffc020413a:	8331                	srli	a4,a4,0xc
ffffffffc020413c:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204140:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204142:	02d77a63          	bgeu	a4,a3,ffffffffc0204176 <swapfs_write+0x7e>
ffffffffc0204146:	00011797          	auipc	a5,0x11
ffffffffc020414a:	39a78793          	addi	a5,a5,922 # ffffffffc02154e0 <va_pa_offset>
ffffffffc020414e:	639c                	ld	a5,0(a5)
}
ffffffffc0204150:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204152:	46a1                	li	a3,8
ffffffffc0204154:	963e                	add	a2,a2,a5
ffffffffc0204156:	4505                	li	a0,1
}
ffffffffc0204158:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc020415a:	b84fc06f          	j	ffffffffc02004de <ide_write_secs>
ffffffffc020415e:	86aa                	mv	a3,a0
ffffffffc0204160:	00003617          	auipc	a2,0x3
ffffffffc0204164:	a5060613          	addi	a2,a2,-1456 # ffffffffc0206bb0 <default_pmm_manager+0x88>
ffffffffc0204168:	45e5                	li	a1,25
ffffffffc020416a:	00003517          	auipc	a0,0x3
ffffffffc020416e:	a2e50513          	addi	a0,a0,-1490 # ffffffffc0206b98 <default_pmm_manager+0x70>
ffffffffc0204172:	862fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
ffffffffc0204176:	86b2                	mv	a3,a2
ffffffffc0204178:	06900593          	li	a1,105
ffffffffc020417c:	00001617          	auipc	a2,0x1
ffffffffc0204180:	6dc60613          	addi	a2,a2,1756 # ffffffffc0205858 <commands+0x840>
ffffffffc0204184:	00001517          	auipc	a0,0x1
ffffffffc0204188:	72c50513          	addi	a0,a0,1836 # ffffffffc02058b0 <commands+0x898>
ffffffffc020418c:	848fc0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc0204190 <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc0204190:	8526                	mv	a0,s1
	jalr s0
ffffffffc0204192:	9402                	jalr	s0

	jal do_exit
ffffffffc0204194:	532000ef          	jal	ra,ffffffffc02046c6 <do_exit>

ffffffffc0204198 <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc0204198:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc020419c:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc02041a0:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc02041a2:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc02041a4:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc02041a8:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc02041ac:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc02041b0:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc02041b4:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc02041b8:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc02041bc:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc02041c0:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc02041c4:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc02041c8:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc02041cc:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc02041d0:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc02041d4:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc02041d6:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc02041d8:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc02041dc:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc02041e0:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc02041e4:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc02041e8:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc02041ec:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc02041f0:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc02041f4:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc02041f8:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc02041fc:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc0204200:	8082                	ret

ffffffffc0204202 <alloc_proc>:
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
ffffffffc0204202:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));// 分配空间
ffffffffc0204204:	0e800513          	li	a0,232
alloc_proc(void) {
ffffffffc0204208:	e022                	sd	s0,0(sp)
ffffffffc020420a:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));// 分配空间
ffffffffc020420c:	d07fe0ef          	jal	ra,ffffffffc0202f12 <kmalloc>
ffffffffc0204210:	842a                	mv	s0,a0
    if (proc != NULL) {
ffffffffc0204212:	c529                	beqz	a0,ffffffffc020425c <alloc_proc+0x5a>
     *       struct trapframe *tf;                       // Trap frame for current interrupt
     *       uintptr_t cr3;                              // CR3 register: the base addr of Page Directroy Table(PDT)
     *       uint32_t flags;                             // Process flag
     *       char name[PROC_NAME_LEN + 1];               // Process name
     */
        proc->state = PROC_UNINIT;
ffffffffc0204214:	57fd                	li	a5,-1
ffffffffc0204216:	1782                	slli	a5,a5,0x20
ffffffffc0204218:	e11c                	sd	a5,0(a0)
        proc->runs = 0;
        proc->kstack = 0;
        proc->need_resched = 0;
        proc->parent = NULL;
        proc->mm = NULL;
        memset(&(proc->context),0,sizeof(struct context));
ffffffffc020421a:	07000613          	li	a2,112
ffffffffc020421e:	4581                	li	a1,0
        proc->runs = 0;
ffffffffc0204220:	00052423          	sw	zero,8(a0)
        proc->kstack = 0;
ffffffffc0204224:	00053823          	sd	zero,16(a0)
        proc->need_resched = 0;
ffffffffc0204228:	00052c23          	sw	zero,24(a0)
        proc->parent = NULL;
ffffffffc020422c:	02053023          	sd	zero,32(a0)
        proc->mm = NULL;
ffffffffc0204230:	02053423          	sd	zero,40(a0)
        memset(&(proc->context),0,sizeof(struct context));
ffffffffc0204234:	03050513          	addi	a0,a0,48
ffffffffc0204238:	033000ef          	jal	ra,ffffffffc0204a6a <memset>
        proc->tf = NULL;
        proc->cr3 = boot_cr3;
ffffffffc020423c:	00011797          	auipc	a5,0x11
ffffffffc0204240:	2ac78793          	addi	a5,a5,684 # ffffffffc02154e8 <boot_cr3>
ffffffffc0204244:	639c                	ld	a5,0(a5)
        proc->tf = NULL;
ffffffffc0204246:	0a043023          	sd	zero,160(s0)
        proc->flags = 0;
ffffffffc020424a:	0a042823          	sw	zero,176(s0)
        proc->cr3 = boot_cr3;
ffffffffc020424e:	f45c                	sd	a5,168(s0)
        memset(&(proc->name),0,PROC_NAME_LEN);
ffffffffc0204250:	463d                	li	a2,15
ffffffffc0204252:	4581                	li	a1,0
ffffffffc0204254:	0b440513          	addi	a0,s0,180
ffffffffc0204258:	013000ef          	jal	ra,ffffffffc0204a6a <memset>
    }
    return proc;
}
ffffffffc020425c:	8522                	mv	a0,s0
ffffffffc020425e:	60a2                	ld	ra,8(sp)
ffffffffc0204260:	6402                	ld	s0,0(sp)
ffffffffc0204262:	0141                	addi	sp,sp,16
ffffffffc0204264:	8082                	ret

ffffffffc0204266 <forkret>:
// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
    forkrets(current->tf);
ffffffffc0204266:	00011797          	auipc	a5,0x11
ffffffffc020426a:	24a78793          	addi	a5,a5,586 # ffffffffc02154b0 <current>
ffffffffc020426e:	639c                	ld	a5,0(a5)
ffffffffc0204270:	73c8                	ld	a0,160(a5)
ffffffffc0204272:	913fc06f          	j	ffffffffc0200b84 <forkrets>

ffffffffc0204276 <set_proc_name>:
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204276:	1101                	addi	sp,sp,-32
ffffffffc0204278:	e822                	sd	s0,16(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc020427a:	0b450413          	addi	s0,a0,180
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc020427e:	e426                	sd	s1,8(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204280:	4641                	li	a2,16
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204282:	84ae                	mv	s1,a1
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204284:	8522                	mv	a0,s0
ffffffffc0204286:	4581                	li	a1,0
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204288:	ec06                	sd	ra,24(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc020428a:	7e0000ef          	jal	ra,ffffffffc0204a6a <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc020428e:	8522                	mv	a0,s0
}
ffffffffc0204290:	6442                	ld	s0,16(sp)
ffffffffc0204292:	60e2                	ld	ra,24(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204294:	85a6                	mv	a1,s1
}
ffffffffc0204296:	64a2                	ld	s1,8(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204298:	463d                	li	a2,15
}
ffffffffc020429a:	6105                	addi	sp,sp,32
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc020429c:	7e00006f          	j	ffffffffc0204a7c <memcpy>

ffffffffc02042a0 <get_proc_name>:
get_proc_name(struct proc_struct *proc) {
ffffffffc02042a0:	1101                	addi	sp,sp,-32
ffffffffc02042a2:	e822                	sd	s0,16(sp)
    memset(name, 0, sizeof(name));
ffffffffc02042a4:	00011417          	auipc	s0,0x11
ffffffffc02042a8:	1bc40413          	addi	s0,s0,444 # ffffffffc0215460 <name.1565>
get_proc_name(struct proc_struct *proc) {
ffffffffc02042ac:	e426                	sd	s1,8(sp)
    memset(name, 0, sizeof(name));
ffffffffc02042ae:	4641                	li	a2,16
get_proc_name(struct proc_struct *proc) {
ffffffffc02042b0:	84aa                	mv	s1,a0
    memset(name, 0, sizeof(name));
ffffffffc02042b2:	4581                	li	a1,0
ffffffffc02042b4:	8522                	mv	a0,s0
get_proc_name(struct proc_struct *proc) {
ffffffffc02042b6:	ec06                	sd	ra,24(sp)
    memset(name, 0, sizeof(name));
ffffffffc02042b8:	7b2000ef          	jal	ra,ffffffffc0204a6a <memset>
    return memcpy(name, proc->name, PROC_NAME_LEN);
ffffffffc02042bc:	8522                	mv	a0,s0
}
ffffffffc02042be:	6442                	ld	s0,16(sp)
ffffffffc02042c0:	60e2                	ld	ra,24(sp)
    return memcpy(name, proc->name, PROC_NAME_LEN);
ffffffffc02042c2:	0b448593          	addi	a1,s1,180
}
ffffffffc02042c6:	64a2                	ld	s1,8(sp)
    return memcpy(name, proc->name, PROC_NAME_LEN);
ffffffffc02042c8:	463d                	li	a2,15
}
ffffffffc02042ca:	6105                	addi	sp,sp,32
    return memcpy(name, proc->name, PROC_NAME_LEN);
ffffffffc02042cc:	7b00006f          	j	ffffffffc0204a7c <memcpy>

ffffffffc02042d0 <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc02042d0:	00011797          	auipc	a5,0x11
ffffffffc02042d4:	1e078793          	addi	a5,a5,480 # ffffffffc02154b0 <current>
ffffffffc02042d8:	639c                	ld	a5,0(a5)
init_main(void *arg) {
ffffffffc02042da:	1101                	addi	sp,sp,-32
ffffffffc02042dc:	e426                	sd	s1,8(sp)
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc02042de:	43c4                	lw	s1,4(a5)
init_main(void *arg) {
ffffffffc02042e0:	e822                	sd	s0,16(sp)
ffffffffc02042e2:	842a                	mv	s0,a0
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc02042e4:	853e                	mv	a0,a5
init_main(void *arg) {
ffffffffc02042e6:	ec06                	sd	ra,24(sp)
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc02042e8:	fb9ff0ef          	jal	ra,ffffffffc02042a0 <get_proc_name>
ffffffffc02042ec:	862a                	mv	a2,a0
ffffffffc02042ee:	85a6                	mv	a1,s1
ffffffffc02042f0:	00003517          	auipc	a0,0x3
ffffffffc02042f4:	93850513          	addi	a0,a0,-1736 # ffffffffc0206c28 <default_pmm_manager+0x100>
ffffffffc02042f8:	dd9fb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("To U: \"%s\".\n", (const char *)arg);
ffffffffc02042fc:	85a2                	mv	a1,s0
ffffffffc02042fe:	00003517          	auipc	a0,0x3
ffffffffc0204302:	95250513          	addi	a0,a0,-1710 # ffffffffc0206c50 <default_pmm_manager+0x128>
ffffffffc0204306:	dcbfb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("To U: \"en.., Bye, Bye. :)\"\n");
ffffffffc020430a:	00003517          	auipc	a0,0x3
ffffffffc020430e:	95650513          	addi	a0,a0,-1706 # ffffffffc0206c60 <default_pmm_manager+0x138>
ffffffffc0204312:	dbffb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    return 0;
}
ffffffffc0204316:	60e2                	ld	ra,24(sp)
ffffffffc0204318:	6442                	ld	s0,16(sp)
ffffffffc020431a:	64a2                	ld	s1,8(sp)
ffffffffc020431c:	4501                	li	a0,0
ffffffffc020431e:	6105                	addi	sp,sp,32
ffffffffc0204320:	8082                	ret

ffffffffc0204322 <proc_run>:
proc_run(struct proc_struct *proc) {
ffffffffc0204322:	1101                	addi	sp,sp,-32
    if (proc != current) {
ffffffffc0204324:	00011797          	auipc	a5,0x11
ffffffffc0204328:	18c78793          	addi	a5,a5,396 # ffffffffc02154b0 <current>
proc_run(struct proc_struct *proc) {
ffffffffc020432c:	e426                	sd	s1,8(sp)
    if (proc != current) {
ffffffffc020432e:	6384                	ld	s1,0(a5)
proc_run(struct proc_struct *proc) {
ffffffffc0204330:	ec06                	sd	ra,24(sp)
ffffffffc0204332:	e822                	sd	s0,16(sp)
ffffffffc0204334:	e04a                	sd	s2,0(sp)
    if (proc != current) {
ffffffffc0204336:	02a48c63          	beq	s1,a0,ffffffffc020436e <proc_run+0x4c>
ffffffffc020433a:	842a                	mv	s0,a0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020433c:	100027f3          	csrr	a5,sstatus
ffffffffc0204340:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204342:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204344:	e3b1                	bnez	a5,ffffffffc0204388 <proc_run+0x66>
            lcr3(current->cr3);//切换页表
ffffffffc0204346:	745c                	ld	a5,168(s0)
            current = proc;//前一个进程和后一个进程,就两个进程
ffffffffc0204348:	00011717          	auipc	a4,0x11
ffffffffc020434c:	16873423          	sd	s0,360(a4) # ffffffffc02154b0 <current>

#define barrier() __asm__ __volatile__ ("fence" ::: "memory")

static inline void
lcr3(unsigned int cr3) {
    write_csr(sptbr, SATP32_MODE | (cr3 >> RISCV_PGSHIFT));
ffffffffc0204350:	80000737          	lui	a4,0x80000
ffffffffc0204354:	00c7d79b          	srliw	a5,a5,0xc
ffffffffc0204358:	8fd9                	or	a5,a5,a4
ffffffffc020435a:	18079073          	csrw	satp,a5
            switch_to(&(prev->context), &(current->context));
ffffffffc020435e:	03040593          	addi	a1,s0,48
ffffffffc0204362:	03048513          	addi	a0,s1,48
ffffffffc0204366:	e33ff0ef          	jal	ra,ffffffffc0204198 <switch_to>
    if (flag) {
ffffffffc020436a:	00091863          	bnez	s2,ffffffffc020437a <proc_run+0x58>
}
ffffffffc020436e:	60e2                	ld	ra,24(sp)
ffffffffc0204370:	6442                	ld	s0,16(sp)
ffffffffc0204372:	64a2                	ld	s1,8(sp)
ffffffffc0204374:	6902                	ld	s2,0(sp)
ffffffffc0204376:	6105                	addi	sp,sp,32
ffffffffc0204378:	8082                	ret
ffffffffc020437a:	6442                	ld	s0,16(sp)
ffffffffc020437c:	60e2                	ld	ra,24(sp)
ffffffffc020437e:	64a2                	ld	s1,8(sp)
ffffffffc0204380:	6902                	ld	s2,0(sp)
ffffffffc0204382:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0204384:	a48fc06f          	j	ffffffffc02005cc <intr_enable>
        intr_disable();
ffffffffc0204388:	a4afc0ef          	jal	ra,ffffffffc02005d2 <intr_disable>
        return 1;
ffffffffc020438c:	4905                	li	s2,1
ffffffffc020438e:	bf65                	j	ffffffffc0204346 <proc_run+0x24>

ffffffffc0204390 <find_proc>:
    if (0 < pid && pid < MAX_PID) {
ffffffffc0204390:	0005071b          	sext.w	a4,a0
ffffffffc0204394:	6789                	lui	a5,0x2
ffffffffc0204396:	fff7069b          	addiw	a3,a4,-1
ffffffffc020439a:	17f9                	addi	a5,a5,-2
ffffffffc020439c:	04d7e063          	bltu	a5,a3,ffffffffc02043dc <find_proc+0x4c>
find_proc(int pid) {
ffffffffc02043a0:	1141                	addi	sp,sp,-16
ffffffffc02043a2:	e022                	sd	s0,0(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc02043a4:	45a9                	li	a1,10
ffffffffc02043a6:	842a                	mv	s0,a0
ffffffffc02043a8:	853a                	mv	a0,a4
find_proc(int pid) {
ffffffffc02043aa:	e406                	sd	ra,8(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc02043ac:	305000ef          	jal	ra,ffffffffc0204eb0 <hash32>
ffffffffc02043b0:	02051693          	slli	a3,a0,0x20
ffffffffc02043b4:	82f1                	srli	a3,a3,0x1c
ffffffffc02043b6:	0000d517          	auipc	a0,0xd
ffffffffc02043ba:	0aa50513          	addi	a0,a0,170 # ffffffffc0211460 <hash_list>
ffffffffc02043be:	96aa                	add	a3,a3,a0
ffffffffc02043c0:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list) {
ffffffffc02043c2:	a029                	j	ffffffffc02043cc <find_proc+0x3c>
            if (proc->pid == pid) {
ffffffffc02043c4:	f2c7a703          	lw	a4,-212(a5) # 1f2c <BASE_ADDRESS-0xffffffffc01fe0d4>
ffffffffc02043c8:	00870c63          	beq	a4,s0,ffffffffc02043e0 <find_proc+0x50>
    return listelm->next;
ffffffffc02043cc:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc02043ce:	fef69be3          	bne	a3,a5,ffffffffc02043c4 <find_proc+0x34>
}
ffffffffc02043d2:	60a2                	ld	ra,8(sp)
ffffffffc02043d4:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc02043d6:	4501                	li	a0,0
}
ffffffffc02043d8:	0141                	addi	sp,sp,16
ffffffffc02043da:	8082                	ret
    return NULL;
ffffffffc02043dc:	4501                	li	a0,0
}
ffffffffc02043de:	8082                	ret
ffffffffc02043e0:	60a2                	ld	ra,8(sp)
ffffffffc02043e2:	6402                	ld	s0,0(sp)
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc02043e4:	f2878513          	addi	a0,a5,-216
}
ffffffffc02043e8:	0141                	addi	sp,sp,16
ffffffffc02043ea:	8082                	ret

ffffffffc02043ec <do_fork>:
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc02043ec:	7179                	addi	sp,sp,-48
ffffffffc02043ee:	e84a                	sd	s2,16(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc02043f0:	00011917          	auipc	s2,0x11
ffffffffc02043f4:	0d890913          	addi	s2,s2,216 # ffffffffc02154c8 <nr_process>
ffffffffc02043f8:	00092703          	lw	a4,0(s2)
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc02043fc:	f406                	sd	ra,40(sp)
ffffffffc02043fe:	f022                	sd	s0,32(sp)
ffffffffc0204400:	ec26                	sd	s1,24(sp)
ffffffffc0204402:	e44e                	sd	s3,8(sp)
ffffffffc0204404:	e052                	sd	s4,0(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc0204406:	6785                	lui	a5,0x1
ffffffffc0204408:	22f75763          	bge	a4,a5,ffffffffc0204636 <do_fork+0x24a>
ffffffffc020440c:	89ae                	mv	s3,a1
ffffffffc020440e:	84b2                	mv	s1,a2
    if ((proc = alloc_proc()) == NULL) {
ffffffffc0204410:	df3ff0ef          	jal	ra,ffffffffc0204202 <alloc_proc>
ffffffffc0204414:	842a                	mv	s0,a0
ffffffffc0204416:	22050263          	beqz	a0,ffffffffc020463a <do_fork+0x24e>
    proc->parent = current;//将子进程的父节点设置为当前进程
ffffffffc020441a:	00011a17          	auipc	s4,0x11
ffffffffc020441e:	096a0a13          	addi	s4,s4,150 # ffffffffc02154b0 <current>
ffffffffc0204422:	000a3783          	ld	a5,0(s4)
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc0204426:	4509                	li	a0,2
    proc->parent = current;//将子进程的父节点设置为当前进程
ffffffffc0204428:	f01c                	sd	a5,32(s0)
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc020442a:	f7cfc0ef          	jal	ra,ffffffffc0200ba6 <alloc_pages>
    if (page != NULL) {
ffffffffc020442e:	1e050f63          	beqz	a0,ffffffffc020462c <do_fork+0x240>
    return page - pages + nbase;
ffffffffc0204432:	00011797          	auipc	a5,0x11
ffffffffc0204436:	0be78793          	addi	a5,a5,190 # ffffffffc02154f0 <pages>
ffffffffc020443a:	6394                	ld	a3,0(a5)
ffffffffc020443c:	00003797          	auipc	a5,0x3
ffffffffc0204440:	b9c78793          	addi	a5,a5,-1124 # ffffffffc0206fd8 <nbase>
ffffffffc0204444:	40d506b3          	sub	a3,a0,a3
ffffffffc0204448:	6388                	ld	a0,0(a5)
ffffffffc020444a:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc020444c:	00011797          	auipc	a5,0x11
ffffffffc0204450:	03c78793          	addi	a5,a5,60 # ffffffffc0215488 <npage>
    return page - pages + nbase;
ffffffffc0204454:	96aa                	add	a3,a3,a0
    return KADDR(page2pa(page));
ffffffffc0204456:	6398                	ld	a4,0(a5)
ffffffffc0204458:	00c69793          	slli	a5,a3,0xc
ffffffffc020445c:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc020445e:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204460:	1ee7ff63          	bgeu	a5,a4,ffffffffc020465e <do_fork+0x272>
    assert(current->mm == NULL);
ffffffffc0204464:	000a3783          	ld	a5,0(s4)
ffffffffc0204468:	00011717          	auipc	a4,0x11
ffffffffc020446c:	07870713          	addi	a4,a4,120 # ffffffffc02154e0 <va_pa_offset>
ffffffffc0204470:	6318                	ld	a4,0(a4)
ffffffffc0204472:	779c                	ld	a5,40(a5)
ffffffffc0204474:	96ba                	add	a3,a3,a4
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc0204476:	e814                	sd	a3,16(s0)
    assert(current->mm == NULL);
ffffffffc0204478:	1c079363          	bnez	a5,ffffffffc020463e <do_fork+0x252>
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE - sizeof(struct trapframe));
ffffffffc020447c:	6789                	lui	a5,0x2
ffffffffc020447e:	ee078793          	addi	a5,a5,-288 # 1ee0 <BASE_ADDRESS-0xffffffffc01fe120>
ffffffffc0204482:	96be                	add	a3,a3,a5
    *(proc->tf) = *tf;
ffffffffc0204484:	8626                	mv	a2,s1
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE - sizeof(struct trapframe));
ffffffffc0204486:	f054                	sd	a3,160(s0)
    *(proc->tf) = *tf;
ffffffffc0204488:	87b6                	mv	a5,a3
ffffffffc020448a:	12048893          	addi	a7,s1,288
ffffffffc020448e:	00063803          	ld	a6,0(a2)
ffffffffc0204492:	6608                	ld	a0,8(a2)
ffffffffc0204494:	6a0c                	ld	a1,16(a2)
ffffffffc0204496:	6e18                	ld	a4,24(a2)
ffffffffc0204498:	0107b023          	sd	a6,0(a5)
ffffffffc020449c:	e788                	sd	a0,8(a5)
ffffffffc020449e:	eb8c                	sd	a1,16(a5)
ffffffffc02044a0:	ef98                	sd	a4,24(a5)
ffffffffc02044a2:	02060613          	addi	a2,a2,32
ffffffffc02044a6:	02078793          	addi	a5,a5,32
ffffffffc02044aa:	ff1612e3          	bne	a2,a7,ffffffffc020448e <do_fork+0xa2>
    proc->tf->gpr.a0 = 0;
ffffffffc02044ae:	0406b823          	sd	zero,80(a3)
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc02044b2:	10098e63          	beqz	s3,ffffffffc02045ce <do_fork+0x1e2>
ffffffffc02044b6:	0136b823          	sd	s3,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc02044ba:	00000797          	auipc	a5,0x0
ffffffffc02044be:	dac78793          	addi	a5,a5,-596 # ffffffffc0204266 <forkret>
ffffffffc02044c2:	f81c                	sd	a5,48(s0)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc02044c4:	fc14                	sd	a3,56(s0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02044c6:	100027f3          	csrr	a5,sstatus
ffffffffc02044ca:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02044cc:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02044ce:	10079f63          	bnez	a5,ffffffffc02045ec <do_fork+0x200>
    if (++ last_pid >= MAX_PID) {
ffffffffc02044d2:	00006797          	auipc	a5,0x6
ffffffffc02044d6:	b8678793          	addi	a5,a5,-1146 # ffffffffc020a058 <last_pid.1575>
ffffffffc02044da:	439c                	lw	a5,0(a5)
ffffffffc02044dc:	6709                	lui	a4,0x2
ffffffffc02044de:	0017851b          	addiw	a0,a5,1
ffffffffc02044e2:	00006697          	auipc	a3,0x6
ffffffffc02044e6:	b6a6ab23          	sw	a0,-1162(a3) # ffffffffc020a058 <last_pid.1575>
ffffffffc02044ea:	12e55263          	bge	a0,a4,ffffffffc020460e <do_fork+0x222>
    if (last_pid >= next_safe) {
ffffffffc02044ee:	00006797          	auipc	a5,0x6
ffffffffc02044f2:	b6e78793          	addi	a5,a5,-1170 # ffffffffc020a05c <next_safe.1574>
ffffffffc02044f6:	439c                	lw	a5,0(a5)
ffffffffc02044f8:	00011497          	auipc	s1,0x11
ffffffffc02044fc:	0f848493          	addi	s1,s1,248 # ffffffffc02155f0 <proc_list>
ffffffffc0204500:	06f54063          	blt	a0,a5,ffffffffc0204560 <do_fork+0x174>
        next_safe = MAX_PID;
ffffffffc0204504:	6789                	lui	a5,0x2
ffffffffc0204506:	00006717          	auipc	a4,0x6
ffffffffc020450a:	b4f72b23          	sw	a5,-1194(a4) # ffffffffc020a05c <next_safe.1574>
ffffffffc020450e:	4581                	li	a1,0
ffffffffc0204510:	87aa                	mv	a5,a0
ffffffffc0204512:	00011497          	auipc	s1,0x11
ffffffffc0204516:	0de48493          	addi	s1,s1,222 # ffffffffc02155f0 <proc_list>
    repeat:
ffffffffc020451a:	6889                	lui	a7,0x2
ffffffffc020451c:	882e                	mv	a6,a1
ffffffffc020451e:	6609                	lui	a2,0x2
        le = list;
ffffffffc0204520:	00011697          	auipc	a3,0x11
ffffffffc0204524:	0d068693          	addi	a3,a3,208 # ffffffffc02155f0 <proc_list>
ffffffffc0204528:	6694                	ld	a3,8(a3)
        while ((le = list_next(le)) != list) {
ffffffffc020452a:	00968f63          	beq	a3,s1,ffffffffc0204548 <do_fork+0x15c>
            if (proc->pid == last_pid) {
ffffffffc020452e:	f3c6a703          	lw	a4,-196(a3)
ffffffffc0204532:	08e78963          	beq	a5,a4,ffffffffc02045c4 <do_fork+0x1d8>
            else if (proc->pid > last_pid && next_safe > proc->pid) {
ffffffffc0204536:	fee7d9e3          	bge	a5,a4,ffffffffc0204528 <do_fork+0x13c>
ffffffffc020453a:	fec757e3          	bge	a4,a2,ffffffffc0204528 <do_fork+0x13c>
ffffffffc020453e:	6694                	ld	a3,8(a3)
ffffffffc0204540:	863a                	mv	a2,a4
ffffffffc0204542:	4805                	li	a6,1
        while ((le = list_next(le)) != list) {
ffffffffc0204544:	fe9695e3          	bne	a3,s1,ffffffffc020452e <do_fork+0x142>
ffffffffc0204548:	c591                	beqz	a1,ffffffffc0204554 <do_fork+0x168>
ffffffffc020454a:	00006717          	auipc	a4,0x6
ffffffffc020454e:	b0f72723          	sw	a5,-1266(a4) # ffffffffc020a058 <last_pid.1575>
ffffffffc0204552:	853e                	mv	a0,a5
ffffffffc0204554:	00080663          	beqz	a6,ffffffffc0204560 <do_fork+0x174>
ffffffffc0204558:	00006797          	auipc	a5,0x6
ffffffffc020455c:	b0c7a223          	sw	a2,-1276(a5) # ffffffffc020a05c <next_safe.1574>
        proc->pid = get_pid();//获取当前进程PID
ffffffffc0204560:	c048                	sw	a0,4(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc0204562:	45a9                	li	a1,10
ffffffffc0204564:	2501                	sext.w	a0,a0
ffffffffc0204566:	14b000ef          	jal	ra,ffffffffc0204eb0 <hash32>
ffffffffc020456a:	1502                	slli	a0,a0,0x20
ffffffffc020456c:	0000d797          	auipc	a5,0xd
ffffffffc0204570:	ef478793          	addi	a5,a5,-268 # ffffffffc0211460 <hash_list>
ffffffffc0204574:	8171                	srli	a0,a0,0x1c
ffffffffc0204576:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc0204578:	6510                	ld	a2,8(a0)
ffffffffc020457a:	0d840793          	addi	a5,s0,216
ffffffffc020457e:	6494                	ld	a3,8(s1)
        nr_process ++;//进程数加一
ffffffffc0204580:	00092703          	lw	a4,0(s2)
    prev->next = next->prev = elm;
ffffffffc0204584:	e21c                	sd	a5,0(a2)
ffffffffc0204586:	e51c                	sd	a5,8(a0)
    elm->next = next;
ffffffffc0204588:	f070                	sd	a2,224(s0)
        list_add(&proc_list, &(proc->list_link));//加入进程链表
ffffffffc020458a:	0c840793          	addi	a5,s0,200
    elm->prev = prev;
ffffffffc020458e:	ec68                	sd	a0,216(s0)
    prev->next = next->prev = elm;
ffffffffc0204590:	e29c                	sd	a5,0(a3)
        nr_process ++;//进程数加一
ffffffffc0204592:	2705                	addiw	a4,a4,1
ffffffffc0204594:	00011617          	auipc	a2,0x11
ffffffffc0204598:	06f63223          	sd	a5,100(a2) # ffffffffc02155f8 <proc_list+0x8>
    elm->next = next;
ffffffffc020459c:	e874                	sd	a3,208(s0)
    elm->prev = prev;
ffffffffc020459e:	e464                	sd	s1,200(s0)
ffffffffc02045a0:	00011797          	auipc	a5,0x11
ffffffffc02045a4:	f2e7a423          	sw	a4,-216(a5) # ffffffffc02154c8 <nr_process>
    if (flag) {
ffffffffc02045a8:	06099a63          	bnez	s3,ffffffffc020461c <do_fork+0x230>
    wakeup_proc(proc);
ffffffffc02045ac:	8522                	mv	a0,s0
ffffffffc02045ae:	352000ef          	jal	ra,ffffffffc0204900 <wakeup_proc>
    ret = proc->pid;//返回当前进程的PID
ffffffffc02045b2:	4048                	lw	a0,4(s0)
}
ffffffffc02045b4:	70a2                	ld	ra,40(sp)
ffffffffc02045b6:	7402                	ld	s0,32(sp)
ffffffffc02045b8:	64e2                	ld	s1,24(sp)
ffffffffc02045ba:	6942                	ld	s2,16(sp)
ffffffffc02045bc:	69a2                	ld	s3,8(sp)
ffffffffc02045be:	6a02                	ld	s4,0(sp)
ffffffffc02045c0:	6145                	addi	sp,sp,48
ffffffffc02045c2:	8082                	ret
                if (++ last_pid >= next_safe) {
ffffffffc02045c4:	2785                	addiw	a5,a5,1
ffffffffc02045c6:	04c7de63          	bge	a5,a2,ffffffffc0204622 <do_fork+0x236>
ffffffffc02045ca:	4585                	li	a1,1
ffffffffc02045cc:	bfb1                	j	ffffffffc0204528 <do_fork+0x13c>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc02045ce:	89b6                	mv	s3,a3
ffffffffc02045d0:	0136b823          	sd	s3,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc02045d4:	00000797          	auipc	a5,0x0
ffffffffc02045d8:	c9278793          	addi	a5,a5,-878 # ffffffffc0204266 <forkret>
ffffffffc02045dc:	f81c                	sd	a5,48(s0)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc02045de:	fc14                	sd	a3,56(s0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02045e0:	100027f3          	csrr	a5,sstatus
ffffffffc02045e4:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02045e6:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02045e8:	ee0785e3          	beqz	a5,ffffffffc02044d2 <do_fork+0xe6>
        intr_disable();
ffffffffc02045ec:	fe7fb0ef          	jal	ra,ffffffffc02005d2 <intr_disable>
    if (++ last_pid >= MAX_PID) {
ffffffffc02045f0:	00006797          	auipc	a5,0x6
ffffffffc02045f4:	a6878793          	addi	a5,a5,-1432 # ffffffffc020a058 <last_pid.1575>
ffffffffc02045f8:	439c                	lw	a5,0(a5)
ffffffffc02045fa:	6709                	lui	a4,0x2
        return 1;
ffffffffc02045fc:	4985                	li	s3,1
ffffffffc02045fe:	0017851b          	addiw	a0,a5,1
ffffffffc0204602:	00006697          	auipc	a3,0x6
ffffffffc0204606:	a4a6ab23          	sw	a0,-1450(a3) # ffffffffc020a058 <last_pid.1575>
ffffffffc020460a:	eee542e3          	blt	a0,a4,ffffffffc02044ee <do_fork+0x102>
        last_pid = 1;
ffffffffc020460e:	4785                	li	a5,1
ffffffffc0204610:	00006717          	auipc	a4,0x6
ffffffffc0204614:	a4f72423          	sw	a5,-1464(a4) # ffffffffc020a058 <last_pid.1575>
ffffffffc0204618:	4505                	li	a0,1
ffffffffc020461a:	b5ed                	j	ffffffffc0204504 <do_fork+0x118>
        intr_enable();
ffffffffc020461c:	fb1fb0ef          	jal	ra,ffffffffc02005cc <intr_enable>
ffffffffc0204620:	b771                	j	ffffffffc02045ac <do_fork+0x1c0>
                    if (last_pid >= MAX_PID) {
ffffffffc0204622:	0117c363          	blt	a5,a7,ffffffffc0204628 <do_fork+0x23c>
                        last_pid = 1;
ffffffffc0204626:	4785                	li	a5,1
                    goto repeat;
ffffffffc0204628:	4585                	li	a1,1
ffffffffc020462a:	bdcd                	j	ffffffffc020451c <do_fork+0x130>
    kfree(proc);
ffffffffc020462c:	8522                	mv	a0,s0
ffffffffc020462e:	9a1fe0ef          	jal	ra,ffffffffc0202fce <kfree>
    ret = -E_NO_MEM;
ffffffffc0204632:	5571                	li	a0,-4
    goto fork_out;
ffffffffc0204634:	b741                	j	ffffffffc02045b4 <do_fork+0x1c8>
    int ret = -E_NO_FREE_PROC;
ffffffffc0204636:	556d                	li	a0,-5
ffffffffc0204638:	bfb5                	j	ffffffffc02045b4 <do_fork+0x1c8>
    ret = -E_NO_MEM;
ffffffffc020463a:	5571                	li	a0,-4
ffffffffc020463c:	bfa5                	j	ffffffffc02045b4 <do_fork+0x1c8>
    assert(current->mm == NULL);
ffffffffc020463e:	00002697          	auipc	a3,0x2
ffffffffc0204642:	5ba68693          	addi	a3,a3,1466 # ffffffffc0206bf8 <default_pmm_manager+0xd0>
ffffffffc0204646:	00001617          	auipc	a2,0x1
ffffffffc020464a:	36a60613          	addi	a2,a2,874 # ffffffffc02059b0 <commands+0x998>
ffffffffc020464e:	10b00593          	li	a1,267
ffffffffc0204652:	00002517          	auipc	a0,0x2
ffffffffc0204656:	5be50513          	addi	a0,a0,1470 # ffffffffc0206c10 <default_pmm_manager+0xe8>
ffffffffc020465a:	b7bfb0ef          	jal	ra,ffffffffc02001d4 <__panic>
ffffffffc020465e:	00001617          	auipc	a2,0x1
ffffffffc0204662:	1fa60613          	addi	a2,a2,506 # ffffffffc0205858 <commands+0x840>
ffffffffc0204666:	06900593          	li	a1,105
ffffffffc020466a:	00001517          	auipc	a0,0x1
ffffffffc020466e:	24650513          	addi	a0,a0,582 # ffffffffc02058b0 <commands+0x898>
ffffffffc0204672:	b63fb0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc0204676 <kernel_thread>:
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc0204676:	7129                	addi	sp,sp,-320
ffffffffc0204678:	fa22                	sd	s0,304(sp)
ffffffffc020467a:	f626                	sd	s1,296(sp)
ffffffffc020467c:	f24a                	sd	s2,288(sp)
ffffffffc020467e:	84ae                	mv	s1,a1
ffffffffc0204680:	892a                	mv	s2,a0
ffffffffc0204682:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc0204684:	4581                	li	a1,0
ffffffffc0204686:	12000613          	li	a2,288
ffffffffc020468a:	850a                	mv	a0,sp
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc020468c:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc020468e:	3dc000ef          	jal	ra,ffffffffc0204a6a <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc0204692:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc0204694:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc0204696:	100027f3          	csrr	a5,sstatus
ffffffffc020469a:	edd7f793          	andi	a5,a5,-291
ffffffffc020469e:	1207e793          	ori	a5,a5,288
ffffffffc02046a2:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02046a4:	860a                	mv	a2,sp
ffffffffc02046a6:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc02046aa:	00000797          	auipc	a5,0x0
ffffffffc02046ae:	ae678793          	addi	a5,a5,-1306 # ffffffffc0204190 <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02046b2:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc02046b4:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02046b6:	d37ff0ef          	jal	ra,ffffffffc02043ec <do_fork>
}
ffffffffc02046ba:	70f2                	ld	ra,312(sp)
ffffffffc02046bc:	7452                	ld	s0,304(sp)
ffffffffc02046be:	74b2                	ld	s1,296(sp)
ffffffffc02046c0:	7912                	ld	s2,288(sp)
ffffffffc02046c2:	6131                	addi	sp,sp,320
ffffffffc02046c4:	8082                	ret

ffffffffc02046c6 <do_exit>:
do_exit(int error_code) {
ffffffffc02046c6:	1141                	addi	sp,sp,-16
    panic("process exit!!.\n");
ffffffffc02046c8:	00002617          	auipc	a2,0x2
ffffffffc02046cc:	51860613          	addi	a2,a2,1304 # ffffffffc0206be0 <default_pmm_manager+0xb8>
ffffffffc02046d0:	17000593          	li	a1,368
ffffffffc02046d4:	00002517          	auipc	a0,0x2
ffffffffc02046d8:	53c50513          	addi	a0,a0,1340 # ffffffffc0206c10 <default_pmm_manager+0xe8>
do_exit(int error_code) {
ffffffffc02046dc:	e406                	sd	ra,8(sp)
    panic("process exit!!.\n");
ffffffffc02046de:	af7fb0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc02046e2 <proc_init>:
    elm->prev = elm->next = elm;
ffffffffc02046e2:	00011797          	auipc	a5,0x11
ffffffffc02046e6:	f0e78793          	addi	a5,a5,-242 # ffffffffc02155f0 <proc_list>

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
ffffffffc02046ea:	1101                	addi	sp,sp,-32
ffffffffc02046ec:	00011717          	auipc	a4,0x11
ffffffffc02046f0:	f0f73623          	sd	a5,-244(a4) # ffffffffc02155f8 <proc_list+0x8>
ffffffffc02046f4:	00011717          	auipc	a4,0x11
ffffffffc02046f8:	eef73e23          	sd	a5,-260(a4) # ffffffffc02155f0 <proc_list>
ffffffffc02046fc:	ec06                	sd	ra,24(sp)
ffffffffc02046fe:	e822                	sd	s0,16(sp)
ffffffffc0204700:	e426                	sd	s1,8(sp)
ffffffffc0204702:	e04a                	sd	s2,0(sp)
ffffffffc0204704:	0000d797          	auipc	a5,0xd
ffffffffc0204708:	d5c78793          	addi	a5,a5,-676 # ffffffffc0211460 <hash_list>
ffffffffc020470c:	00011717          	auipc	a4,0x11
ffffffffc0204710:	d5470713          	addi	a4,a4,-684 # ffffffffc0215460 <name.1565>
ffffffffc0204714:	e79c                	sd	a5,8(a5)
ffffffffc0204716:	e39c                	sd	a5,0(a5)
ffffffffc0204718:	07c1                	addi	a5,a5,16
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
ffffffffc020471a:	fee79de3          	bne	a5,a4,ffffffffc0204714 <proc_init+0x32>
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) {
ffffffffc020471e:	ae5ff0ef          	jal	ra,ffffffffc0204202 <alloc_proc>
ffffffffc0204722:	00011797          	auipc	a5,0x11
ffffffffc0204726:	d8a7bb23          	sd	a0,-618(a5) # ffffffffc02154b8 <idleproc>
ffffffffc020472a:	00011417          	auipc	s0,0x11
ffffffffc020472e:	d8e40413          	addi	s0,s0,-626 # ffffffffc02154b8 <idleproc>
ffffffffc0204732:	12050963          	beqz	a0,ffffffffc0204864 <proc_init+0x182>
        panic("cannot alloc idleproc.\n");
    }

    // check the proc structure
    int *context_mem = (int*) kmalloc(sizeof(struct context));
ffffffffc0204736:	07000513          	li	a0,112
ffffffffc020473a:	fd8fe0ef          	jal	ra,ffffffffc0202f12 <kmalloc>
    memset(context_mem, 0, sizeof(struct context));
ffffffffc020473e:	07000613          	li	a2,112
ffffffffc0204742:	4581                	li	a1,0
    int *context_mem = (int*) kmalloc(sizeof(struct context));
ffffffffc0204744:	84aa                	mv	s1,a0
    memset(context_mem, 0, sizeof(struct context));
ffffffffc0204746:	324000ef          	jal	ra,ffffffffc0204a6a <memset>
    int context_init_flag = memcmp(&(idleproc->context), context_mem, sizeof(struct context));
ffffffffc020474a:	6008                	ld	a0,0(s0)
ffffffffc020474c:	85a6                	mv	a1,s1
ffffffffc020474e:	07000613          	li	a2,112
ffffffffc0204752:	03050513          	addi	a0,a0,48
ffffffffc0204756:	33e000ef          	jal	ra,ffffffffc0204a94 <memcmp>
ffffffffc020475a:	892a                	mv	s2,a0

    int *proc_name_mem = (int*) kmalloc(PROC_NAME_LEN);
ffffffffc020475c:	453d                	li	a0,15
ffffffffc020475e:	fb4fe0ef          	jal	ra,ffffffffc0202f12 <kmalloc>
    memset(proc_name_mem, 0, PROC_NAME_LEN);
ffffffffc0204762:	463d                	li	a2,15
ffffffffc0204764:	4581                	li	a1,0
    int *proc_name_mem = (int*) kmalloc(PROC_NAME_LEN);
ffffffffc0204766:	84aa                	mv	s1,a0
    memset(proc_name_mem, 0, PROC_NAME_LEN);
ffffffffc0204768:	302000ef          	jal	ra,ffffffffc0204a6a <memset>
    int proc_name_flag = memcmp(&(idleproc->name), proc_name_mem, PROC_NAME_LEN);
ffffffffc020476c:	6008                	ld	a0,0(s0)
ffffffffc020476e:	463d                	li	a2,15
ffffffffc0204770:	85a6                	mv	a1,s1
ffffffffc0204772:	0b450513          	addi	a0,a0,180
ffffffffc0204776:	31e000ef          	jal	ra,ffffffffc0204a94 <memcmp>

    if(idleproc->cr3 == boot_cr3 && idleproc->tf == NULL && !context_init_flag
ffffffffc020477a:	601c                	ld	a5,0(s0)
ffffffffc020477c:	00011717          	auipc	a4,0x11
ffffffffc0204780:	d6c70713          	addi	a4,a4,-660 # ffffffffc02154e8 <boot_cr3>
ffffffffc0204784:	6318                	ld	a4,0(a4)
ffffffffc0204786:	77d4                	ld	a3,168(a5)
ffffffffc0204788:	08e68d63          	beq	a3,a4,ffffffffc0204822 <proc_init+0x140>
        cprintf("alloc_proc() correct!\n");

    }
    
    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc020478c:	4709                	li	a4,2
ffffffffc020478e:	e398                	sd	a4,0(a5)
    idleproc->kstack = (uintptr_t)bootstack;
    idleproc->need_resched = 1;
ffffffffc0204790:	4485                	li	s1,1
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0204792:	00003717          	auipc	a4,0x3
ffffffffc0204796:	86e70713          	addi	a4,a4,-1938 # ffffffffc0207000 <bootstack>
ffffffffc020479a:	eb98                	sd	a4,16(a5)
    set_proc_name(idleproc, "idle");
ffffffffc020479c:	00002597          	auipc	a1,0x2
ffffffffc02047a0:	51458593          	addi	a1,a1,1300 # ffffffffc0206cb0 <default_pmm_manager+0x188>
    idleproc->need_resched = 1;
ffffffffc02047a4:	cf84                	sw	s1,24(a5)
    set_proc_name(idleproc, "idle");
ffffffffc02047a6:	853e                	mv	a0,a5
ffffffffc02047a8:	acfff0ef          	jal	ra,ffffffffc0204276 <set_proc_name>
    nr_process ++;
ffffffffc02047ac:	00011797          	auipc	a5,0x11
ffffffffc02047b0:	d1c78793          	addi	a5,a5,-740 # ffffffffc02154c8 <nr_process>
ffffffffc02047b4:	439c                	lw	a5,0(a5)

    current = idleproc;
ffffffffc02047b6:	6018                	ld	a4,0(s0)

    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc02047b8:	4601                	li	a2,0
    nr_process ++;
ffffffffc02047ba:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc02047bc:	00002597          	auipc	a1,0x2
ffffffffc02047c0:	4fc58593          	addi	a1,a1,1276 # ffffffffc0206cb8 <default_pmm_manager+0x190>
ffffffffc02047c4:	00000517          	auipc	a0,0x0
ffffffffc02047c8:	b0c50513          	addi	a0,a0,-1268 # ffffffffc02042d0 <init_main>
    nr_process ++;
ffffffffc02047cc:	00011697          	auipc	a3,0x11
ffffffffc02047d0:	cef6ae23          	sw	a5,-772(a3) # ffffffffc02154c8 <nr_process>
    current = idleproc;
ffffffffc02047d4:	00011797          	auipc	a5,0x11
ffffffffc02047d8:	cce7be23          	sd	a4,-804(a5) # ffffffffc02154b0 <current>
    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc02047dc:	e9bff0ef          	jal	ra,ffffffffc0204676 <kernel_thread>
    if (pid <= 0) {
ffffffffc02047e0:	0ca05e63          	blez	a0,ffffffffc02048bc <proc_init+0x1da>
        panic("create init_main failed.\n");
    }
    //cprintf("asdsaf\n");

    initproc = find_proc(pid);
ffffffffc02047e4:	badff0ef          	jal	ra,ffffffffc0204390 <find_proc>
    
    set_proc_name(initproc, "init");
ffffffffc02047e8:	00002597          	auipc	a1,0x2
ffffffffc02047ec:	50058593          	addi	a1,a1,1280 # ffffffffc0206ce8 <default_pmm_manager+0x1c0>
    initproc = find_proc(pid);
ffffffffc02047f0:	00011797          	auipc	a5,0x11
ffffffffc02047f4:	cca7b823          	sd	a0,-816(a5) # ffffffffc02154c0 <initproc>
    set_proc_name(initproc, "init");
ffffffffc02047f8:	a7fff0ef          	jal	ra,ffffffffc0204276 <set_proc_name>
    

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc02047fc:	601c                	ld	a5,0(s0)
ffffffffc02047fe:	cfd9                	beqz	a5,ffffffffc020489c <proc_init+0x1ba>
ffffffffc0204800:	43dc                	lw	a5,4(a5)
ffffffffc0204802:	efc9                	bnez	a5,ffffffffc020489c <proc_init+0x1ba>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0204804:	00011797          	auipc	a5,0x11
ffffffffc0204808:	cbc78793          	addi	a5,a5,-836 # ffffffffc02154c0 <initproc>
ffffffffc020480c:	639c                	ld	a5,0(a5)
ffffffffc020480e:	c7bd                	beqz	a5,ffffffffc020487c <proc_init+0x19a>
ffffffffc0204810:	43dc                	lw	a5,4(a5)
ffffffffc0204812:	06979563          	bne	a5,s1,ffffffffc020487c <proc_init+0x19a>
}
ffffffffc0204816:	60e2                	ld	ra,24(sp)
ffffffffc0204818:	6442                	ld	s0,16(sp)
ffffffffc020481a:	64a2                	ld	s1,8(sp)
ffffffffc020481c:	6902                	ld	s2,0(sp)
ffffffffc020481e:	6105                	addi	sp,sp,32
ffffffffc0204820:	8082                	ret
    if(idleproc->cr3 == boot_cr3 && idleproc->tf == NULL && !context_init_flag
ffffffffc0204822:	73d8                	ld	a4,160(a5)
ffffffffc0204824:	f725                	bnez	a4,ffffffffc020478c <proc_init+0xaa>
ffffffffc0204826:	f60913e3          	bnez	s2,ffffffffc020478c <proc_init+0xaa>
        && idleproc->state == PROC_UNINIT && idleproc->pid == -1 && idleproc->runs == 0
ffffffffc020482a:	6394                	ld	a3,0(a5)
ffffffffc020482c:	577d                	li	a4,-1
ffffffffc020482e:	1702                	slli	a4,a4,0x20
ffffffffc0204830:	f4e69ee3          	bne	a3,a4,ffffffffc020478c <proc_init+0xaa>
ffffffffc0204834:	4798                	lw	a4,8(a5)
ffffffffc0204836:	fb39                	bnez	a4,ffffffffc020478c <proc_init+0xaa>
        && idleproc->kstack == 0 && idleproc->need_resched == 0 && idleproc->parent == NULL
ffffffffc0204838:	6b98                	ld	a4,16(a5)
ffffffffc020483a:	fb29                	bnez	a4,ffffffffc020478c <proc_init+0xaa>
ffffffffc020483c:	4f98                	lw	a4,24(a5)
ffffffffc020483e:	2701                	sext.w	a4,a4
ffffffffc0204840:	f731                	bnez	a4,ffffffffc020478c <proc_init+0xaa>
ffffffffc0204842:	7398                	ld	a4,32(a5)
ffffffffc0204844:	f721                	bnez	a4,ffffffffc020478c <proc_init+0xaa>
        && idleproc->mm == NULL && idleproc->flags == 0 && !proc_name_flag
ffffffffc0204846:	7798                	ld	a4,40(a5)
ffffffffc0204848:	f331                	bnez	a4,ffffffffc020478c <proc_init+0xaa>
ffffffffc020484a:	0b07a703          	lw	a4,176(a5)
ffffffffc020484e:	8f49                	or	a4,a4,a0
ffffffffc0204850:	2701                	sext.w	a4,a4
ffffffffc0204852:	ff0d                	bnez	a4,ffffffffc020478c <proc_init+0xaa>
        cprintf("alloc_proc() correct!\n");
ffffffffc0204854:	00002517          	auipc	a0,0x2
ffffffffc0204858:	44450513          	addi	a0,a0,1092 # ffffffffc0206c98 <default_pmm_manager+0x170>
ffffffffc020485c:	875fb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc0204860:	601c                	ld	a5,0(s0)
ffffffffc0204862:	b72d                	j	ffffffffc020478c <proc_init+0xaa>
        panic("cannot alloc idleproc.\n");
ffffffffc0204864:	00002617          	auipc	a2,0x2
ffffffffc0204868:	41c60613          	addi	a2,a2,1052 # ffffffffc0206c80 <default_pmm_manager+0x158>
ffffffffc020486c:	18800593          	li	a1,392
ffffffffc0204870:	00002517          	auipc	a0,0x2
ffffffffc0204874:	3a050513          	addi	a0,a0,928 # ffffffffc0206c10 <default_pmm_manager+0xe8>
ffffffffc0204878:	95dfb0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc020487c:	00002697          	auipc	a3,0x2
ffffffffc0204880:	49c68693          	addi	a3,a3,1180 # ffffffffc0206d18 <default_pmm_manager+0x1f0>
ffffffffc0204884:	00001617          	auipc	a2,0x1
ffffffffc0204888:	12c60613          	addi	a2,a2,300 # ffffffffc02059b0 <commands+0x998>
ffffffffc020488c:	1b200593          	li	a1,434
ffffffffc0204890:	00002517          	auipc	a0,0x2
ffffffffc0204894:	38050513          	addi	a0,a0,896 # ffffffffc0206c10 <default_pmm_manager+0xe8>
ffffffffc0204898:	93dfb0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc020489c:	00002697          	auipc	a3,0x2
ffffffffc02048a0:	45468693          	addi	a3,a3,1108 # ffffffffc0206cf0 <default_pmm_manager+0x1c8>
ffffffffc02048a4:	00001617          	auipc	a2,0x1
ffffffffc02048a8:	10c60613          	addi	a2,a2,268 # ffffffffc02059b0 <commands+0x998>
ffffffffc02048ac:	1b100593          	li	a1,433
ffffffffc02048b0:	00002517          	auipc	a0,0x2
ffffffffc02048b4:	36050513          	addi	a0,a0,864 # ffffffffc0206c10 <default_pmm_manager+0xe8>
ffffffffc02048b8:	91dfb0ef          	jal	ra,ffffffffc02001d4 <__panic>
        panic("create init_main failed.\n");
ffffffffc02048bc:	00002617          	auipc	a2,0x2
ffffffffc02048c0:	40c60613          	addi	a2,a2,1036 # ffffffffc0206cc8 <default_pmm_manager+0x1a0>
ffffffffc02048c4:	1a800593          	li	a1,424
ffffffffc02048c8:	00002517          	auipc	a0,0x2
ffffffffc02048cc:	34850513          	addi	a0,a0,840 # ffffffffc0206c10 <default_pmm_manager+0xe8>
ffffffffc02048d0:	905fb0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc02048d4 <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
ffffffffc02048d4:	1101                	addi	sp,sp,-32
ffffffffc02048d6:	e822                	sd	s0,16(sp)
ffffffffc02048d8:	e426                	sd	s1,8(sp)
ffffffffc02048da:	ec06                	sd	ra,24(sp)
ffffffffc02048dc:	00011497          	auipc	s1,0x11
ffffffffc02048e0:	bd448493          	addi	s1,s1,-1068 # ffffffffc02154b0 <current>
    while (1) {
         cprintf("allasfdafsq!\n");
ffffffffc02048e4:	00002417          	auipc	s0,0x2
ffffffffc02048e8:	2ec40413          	addi	s0,s0,748 # ffffffffc0206bd0 <default_pmm_manager+0xa8>
ffffffffc02048ec:	8522                	mv	a0,s0
ffffffffc02048ee:	fe2fb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
        if (current->need_resched) {
ffffffffc02048f2:	609c                	ld	a5,0(s1)
ffffffffc02048f4:	4f9c                	lw	a5,24(a5)
ffffffffc02048f6:	2781                	sext.w	a5,a5
ffffffffc02048f8:	dbf5                	beqz	a5,ffffffffc02048ec <cpu_idle+0x18>
           
            schedule();
ffffffffc02048fa:	038000ef          	jal	ra,ffffffffc0204932 <schedule>
ffffffffc02048fe:	b7fd                	j	ffffffffc02048ec <cpu_idle+0x18>

ffffffffc0204900 <wakeup_proc>:
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
ffffffffc0204900:	411c                	lw	a5,0(a0)
ffffffffc0204902:	4705                	li	a4,1
ffffffffc0204904:	37f9                	addiw	a5,a5,-2
ffffffffc0204906:	00f77563          	bgeu	a4,a5,ffffffffc0204910 <wakeup_proc+0x10>
    proc->state = PROC_RUNNABLE;
ffffffffc020490a:	4789                	li	a5,2
ffffffffc020490c:	c11c                	sw	a5,0(a0)
ffffffffc020490e:	8082                	ret
wakeup_proc(struct proc_struct *proc) {
ffffffffc0204910:	1141                	addi	sp,sp,-16
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
ffffffffc0204912:	00002697          	auipc	a3,0x2
ffffffffc0204916:	42e68693          	addi	a3,a3,1070 # ffffffffc0206d40 <default_pmm_manager+0x218>
ffffffffc020491a:	00001617          	auipc	a2,0x1
ffffffffc020491e:	09660613          	addi	a2,a2,150 # ffffffffc02059b0 <commands+0x998>
ffffffffc0204922:	45a5                	li	a1,9
ffffffffc0204924:	00002517          	auipc	a0,0x2
ffffffffc0204928:	45c50513          	addi	a0,a0,1116 # ffffffffc0206d80 <default_pmm_manager+0x258>
wakeup_proc(struct proc_struct *proc) {
ffffffffc020492c:	e406                	sd	ra,8(sp)
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
ffffffffc020492e:	8a7fb0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc0204932 <schedule>:
}

void
schedule(void) {
ffffffffc0204932:	1141                	addi	sp,sp,-16
ffffffffc0204934:	e406                	sd	ra,8(sp)
ffffffffc0204936:	e022                	sd	s0,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204938:	100027f3          	csrr	a5,sstatus
ffffffffc020493c:	8b89                	andi	a5,a5,2
ffffffffc020493e:	4401                	li	s0,0
ffffffffc0204940:	e3d1                	bnez	a5,ffffffffc02049c4 <schedule+0x92>
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc0204942:	00011797          	auipc	a5,0x11
ffffffffc0204946:	b6e78793          	addi	a5,a5,-1170 # ffffffffc02154b0 <current>
ffffffffc020494a:	0007b883          	ld	a7,0(a5)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc020494e:	00011797          	auipc	a5,0x11
ffffffffc0204952:	b6a78793          	addi	a5,a5,-1174 # ffffffffc02154b8 <idleproc>
ffffffffc0204956:	6388                	ld	a0,0(a5)
        current->need_resched = 0;
ffffffffc0204958:	0008ac23          	sw	zero,24(a7) # 2018 <BASE_ADDRESS-0xffffffffc01fdfe8>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc020495c:	04a88e63          	beq	a7,a0,ffffffffc02049b8 <schedule+0x86>
ffffffffc0204960:	0c888693          	addi	a3,a7,200
ffffffffc0204964:	00011617          	auipc	a2,0x11
ffffffffc0204968:	c8c60613          	addi	a2,a2,-884 # ffffffffc02155f0 <proc_list>
        le = last;
ffffffffc020496c:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;
ffffffffc020496e:	4581                	li	a1,0
        do {
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE) {
ffffffffc0204970:	4809                	li	a6,2
    return listelm->next;
ffffffffc0204972:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list) {
ffffffffc0204974:	00c78863          	beq	a5,a2,ffffffffc0204984 <schedule+0x52>
                if (next->state == PROC_RUNNABLE) {
ffffffffc0204978:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc020497c:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE) {
ffffffffc0204980:	01070463          	beq	a4,a6,ffffffffc0204988 <schedule+0x56>
                    break;
                }
            }
        } while (le != last);
ffffffffc0204984:	fef697e3          	bne	a3,a5,ffffffffc0204972 <schedule+0x40>
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc0204988:	c589                	beqz	a1,ffffffffc0204992 <schedule+0x60>
ffffffffc020498a:	4198                	lw	a4,0(a1)
ffffffffc020498c:	4789                	li	a5,2
ffffffffc020498e:	00f70e63          	beq	a4,a5,ffffffffc02049aa <schedule+0x78>
            next = idleproc;
        }
        next->runs ++;
ffffffffc0204992:	451c                	lw	a5,8(a0)
ffffffffc0204994:	2785                	addiw	a5,a5,1
ffffffffc0204996:	c51c                	sw	a5,8(a0)
        //cprintf("Towqrqrqwn\n\n");
        if (next != current) {
ffffffffc0204998:	00a88463          	beq	a7,a0,ffffffffc02049a0 <schedule+0x6e>
            proc_run(next);
ffffffffc020499c:	987ff0ef          	jal	ra,ffffffffc0204322 <proc_run>
    if (flag) {
ffffffffc02049a0:	e419                	bnez	s0,ffffffffc02049ae <schedule+0x7c>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc02049a2:	60a2                	ld	ra,8(sp)
ffffffffc02049a4:	6402                	ld	s0,0(sp)
ffffffffc02049a6:	0141                	addi	sp,sp,16
ffffffffc02049a8:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc02049aa:	852e                	mv	a0,a1
ffffffffc02049ac:	b7dd                	j	ffffffffc0204992 <schedule+0x60>
}
ffffffffc02049ae:	6402                	ld	s0,0(sp)
ffffffffc02049b0:	60a2                	ld	ra,8(sp)
ffffffffc02049b2:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc02049b4:	c19fb06f          	j	ffffffffc02005cc <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc02049b8:	00011617          	auipc	a2,0x11
ffffffffc02049bc:	c3860613          	addi	a2,a2,-968 # ffffffffc02155f0 <proc_list>
ffffffffc02049c0:	86b2                	mv	a3,a2
ffffffffc02049c2:	b76d                	j	ffffffffc020496c <schedule+0x3a>
        intr_disable();
ffffffffc02049c4:	c0ffb0ef          	jal	ra,ffffffffc02005d2 <intr_disable>
        return 1;
ffffffffc02049c8:	4405                	li	s0,1
ffffffffc02049ca:	bfa5                	j	ffffffffc0204942 <schedule+0x10>

ffffffffc02049cc <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc02049cc:	00054783          	lbu	a5,0(a0)
ffffffffc02049d0:	cb91                	beqz	a5,ffffffffc02049e4 <strlen+0x18>
    size_t cnt = 0;
ffffffffc02049d2:	4781                	li	a5,0
        cnt ++;
ffffffffc02049d4:	0785                	addi	a5,a5,1
    while (*s ++ != '\0') {
ffffffffc02049d6:	00f50733          	add	a4,a0,a5
ffffffffc02049da:	00074703          	lbu	a4,0(a4)
ffffffffc02049de:	fb7d                	bnez	a4,ffffffffc02049d4 <strlen+0x8>
    }
    return cnt;
}
ffffffffc02049e0:	853e                	mv	a0,a5
ffffffffc02049e2:	8082                	ret
    size_t cnt = 0;
ffffffffc02049e4:	4781                	li	a5,0
}
ffffffffc02049e6:	853e                	mv	a0,a5
ffffffffc02049e8:	8082                	ret

ffffffffc02049ea <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc02049ea:	c185                	beqz	a1,ffffffffc0204a0a <strnlen+0x20>
ffffffffc02049ec:	00054783          	lbu	a5,0(a0)
ffffffffc02049f0:	cf89                	beqz	a5,ffffffffc0204a0a <strnlen+0x20>
    size_t cnt = 0;
ffffffffc02049f2:	4781                	li	a5,0
ffffffffc02049f4:	a021                	j	ffffffffc02049fc <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc02049f6:	00074703          	lbu	a4,0(a4)
ffffffffc02049fa:	c711                	beqz	a4,ffffffffc0204a06 <strnlen+0x1c>
        cnt ++;
ffffffffc02049fc:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc02049fe:	00f50733          	add	a4,a0,a5
ffffffffc0204a02:	fef59ae3          	bne	a1,a5,ffffffffc02049f6 <strnlen+0xc>
    }
    return cnt;
}
ffffffffc0204a06:	853e                	mv	a0,a5
ffffffffc0204a08:	8082                	ret
    size_t cnt = 0;
ffffffffc0204a0a:	4781                	li	a5,0
}
ffffffffc0204a0c:	853e                	mv	a0,a5
ffffffffc0204a0e:	8082                	ret

ffffffffc0204a10 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0204a10:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0204a12:	0585                	addi	a1,a1,1
ffffffffc0204a14:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0204a18:	0785                	addi	a5,a5,1
ffffffffc0204a1a:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0204a1e:	fb75                	bnez	a4,ffffffffc0204a12 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0204a20:	8082                	ret

ffffffffc0204a22 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204a22:	00054783          	lbu	a5,0(a0)
ffffffffc0204a26:	0005c703          	lbu	a4,0(a1)
ffffffffc0204a2a:	cb91                	beqz	a5,ffffffffc0204a3e <strcmp+0x1c>
ffffffffc0204a2c:	00e79c63          	bne	a5,a4,ffffffffc0204a44 <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc0204a30:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204a32:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc0204a36:	0585                	addi	a1,a1,1
ffffffffc0204a38:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204a3c:	fbe5                	bnez	a5,ffffffffc0204a2c <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0204a3e:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0204a40:	9d19                	subw	a0,a0,a4
ffffffffc0204a42:	8082                	ret
ffffffffc0204a44:	0007851b          	sext.w	a0,a5
ffffffffc0204a48:	9d19                	subw	a0,a0,a4
ffffffffc0204a4a:	8082                	ret

ffffffffc0204a4c <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0204a4c:	00054783          	lbu	a5,0(a0)
ffffffffc0204a50:	cb91                	beqz	a5,ffffffffc0204a64 <strchr+0x18>
        if (*s == c) {
ffffffffc0204a52:	00b79563          	bne	a5,a1,ffffffffc0204a5c <strchr+0x10>
ffffffffc0204a56:	a809                	j	ffffffffc0204a68 <strchr+0x1c>
ffffffffc0204a58:	00b78763          	beq	a5,a1,ffffffffc0204a66 <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc0204a5c:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0204a5e:	00054783          	lbu	a5,0(a0)
ffffffffc0204a62:	fbfd                	bnez	a5,ffffffffc0204a58 <strchr+0xc>
    }
    return NULL;
ffffffffc0204a64:	4501                	li	a0,0
}
ffffffffc0204a66:	8082                	ret
ffffffffc0204a68:	8082                	ret

ffffffffc0204a6a <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0204a6a:	ca01                	beqz	a2,ffffffffc0204a7a <memset+0x10>
ffffffffc0204a6c:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0204a6e:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0204a70:	0785                	addi	a5,a5,1
ffffffffc0204a72:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0204a76:	fec79de3          	bne	a5,a2,ffffffffc0204a70 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0204a7a:	8082                	ret

ffffffffc0204a7c <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0204a7c:	ca19                	beqz	a2,ffffffffc0204a92 <memcpy+0x16>
ffffffffc0204a7e:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc0204a80:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0204a82:	0585                	addi	a1,a1,1
ffffffffc0204a84:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0204a88:	0785                	addi	a5,a5,1
ffffffffc0204a8a:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0204a8e:	fec59ae3          	bne	a1,a2,ffffffffc0204a82 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0204a92:	8082                	ret

ffffffffc0204a94 <memcmp>:
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
ffffffffc0204a94:	c21d                	beqz	a2,ffffffffc0204aba <memcmp+0x26>
        if (*s1 != *s2) {
ffffffffc0204a96:	00054783          	lbu	a5,0(a0)
ffffffffc0204a9a:	0005c703          	lbu	a4,0(a1)
ffffffffc0204a9e:	962a                	add	a2,a2,a0
ffffffffc0204aa0:	00f70963          	beq	a4,a5,ffffffffc0204ab2 <memcmp+0x1e>
ffffffffc0204aa4:	a829                	j	ffffffffc0204abe <memcmp+0x2a>
ffffffffc0204aa6:	00054783          	lbu	a5,0(a0)
ffffffffc0204aaa:	0005c703          	lbu	a4,0(a1)
ffffffffc0204aae:	00e79863          	bne	a5,a4,ffffffffc0204abe <memcmp+0x2a>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
ffffffffc0204ab2:	0505                	addi	a0,a0,1
ffffffffc0204ab4:	0585                	addi	a1,a1,1
    while (n -- > 0) {
ffffffffc0204ab6:	fea618e3          	bne	a2,a0,ffffffffc0204aa6 <memcmp+0x12>
    }
    return 0;
ffffffffc0204aba:	4501                	li	a0,0
}
ffffffffc0204abc:	8082                	ret
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0204abe:	40e7853b          	subw	a0,a5,a4
ffffffffc0204ac2:	8082                	ret

ffffffffc0204ac4 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0204ac4:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0204ac8:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0204aca:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0204ace:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0204ad0:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0204ad4:	f022                	sd	s0,32(sp)
ffffffffc0204ad6:	ec26                	sd	s1,24(sp)
ffffffffc0204ad8:	e84a                	sd	s2,16(sp)
ffffffffc0204ada:	f406                	sd	ra,40(sp)
ffffffffc0204adc:	e44e                	sd	s3,8(sp)
ffffffffc0204ade:	84aa                	mv	s1,a0
ffffffffc0204ae0:	892e                	mv	s2,a1
ffffffffc0204ae2:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0204ae6:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc0204ae8:	03067e63          	bgeu	a2,a6,ffffffffc0204b24 <printnum+0x60>
ffffffffc0204aec:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0204aee:	00805763          	blez	s0,ffffffffc0204afc <printnum+0x38>
ffffffffc0204af2:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0204af4:	85ca                	mv	a1,s2
ffffffffc0204af6:	854e                	mv	a0,s3
ffffffffc0204af8:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0204afa:	fc65                	bnez	s0,ffffffffc0204af2 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204afc:	1a02                	slli	s4,s4,0x20
ffffffffc0204afe:	020a5a13          	srli	s4,s4,0x20
ffffffffc0204b02:	00002797          	auipc	a5,0x2
ffffffffc0204b06:	42678793          	addi	a5,a5,1062 # ffffffffc0206f28 <error_string+0x38>
ffffffffc0204b0a:	9a3e                	add	s4,s4,a5
}
ffffffffc0204b0c:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204b0e:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0204b12:	70a2                	ld	ra,40(sp)
ffffffffc0204b14:	69a2                	ld	s3,8(sp)
ffffffffc0204b16:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204b18:	85ca                	mv	a1,s2
ffffffffc0204b1a:	8326                	mv	t1,s1
}
ffffffffc0204b1c:	6942                	ld	s2,16(sp)
ffffffffc0204b1e:	64e2                	ld	s1,24(sp)
ffffffffc0204b20:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204b22:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0204b24:	03065633          	divu	a2,a2,a6
ffffffffc0204b28:	8722                	mv	a4,s0
ffffffffc0204b2a:	f9bff0ef          	jal	ra,ffffffffc0204ac4 <printnum>
ffffffffc0204b2e:	b7f9                	j	ffffffffc0204afc <printnum+0x38>

ffffffffc0204b30 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0204b30:	7119                	addi	sp,sp,-128
ffffffffc0204b32:	f4a6                	sd	s1,104(sp)
ffffffffc0204b34:	f0ca                	sd	s2,96(sp)
ffffffffc0204b36:	e8d2                	sd	s4,80(sp)
ffffffffc0204b38:	e4d6                	sd	s5,72(sp)
ffffffffc0204b3a:	e0da                	sd	s6,64(sp)
ffffffffc0204b3c:	fc5e                	sd	s7,56(sp)
ffffffffc0204b3e:	f862                	sd	s8,48(sp)
ffffffffc0204b40:	f06a                	sd	s10,32(sp)
ffffffffc0204b42:	fc86                	sd	ra,120(sp)
ffffffffc0204b44:	f8a2                	sd	s0,112(sp)
ffffffffc0204b46:	ecce                	sd	s3,88(sp)
ffffffffc0204b48:	f466                	sd	s9,40(sp)
ffffffffc0204b4a:	ec6e                	sd	s11,24(sp)
ffffffffc0204b4c:	892a                	mv	s2,a0
ffffffffc0204b4e:	84ae                	mv	s1,a1
ffffffffc0204b50:	8d32                	mv	s10,a2
ffffffffc0204b52:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0204b54:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204b56:	00002a17          	auipc	s4,0x2
ffffffffc0204b5a:	242a0a13          	addi	s4,s4,578 # ffffffffc0206d98 <default_pmm_manager+0x270>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204b5e:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204b62:	00002c17          	auipc	s8,0x2
ffffffffc0204b66:	38ec0c13          	addi	s8,s8,910 # ffffffffc0206ef0 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204b6a:	000d4503          	lbu	a0,0(s10) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
ffffffffc0204b6e:	02500793          	li	a5,37
ffffffffc0204b72:	001d0413          	addi	s0,s10,1
ffffffffc0204b76:	00f50e63          	beq	a0,a5,ffffffffc0204b92 <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc0204b7a:	c521                	beqz	a0,ffffffffc0204bc2 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204b7c:	02500993          	li	s3,37
ffffffffc0204b80:	a011                	j	ffffffffc0204b84 <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc0204b82:	c121                	beqz	a0,ffffffffc0204bc2 <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc0204b84:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204b86:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0204b88:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204b8a:	fff44503          	lbu	a0,-1(s0)
ffffffffc0204b8e:	ff351ae3          	bne	a0,s3,ffffffffc0204b82 <vprintfmt+0x52>
ffffffffc0204b92:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0204b96:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0204b9a:	4981                	li	s3,0
ffffffffc0204b9c:	4801                	li	a6,0
        width = precision = -1;
ffffffffc0204b9e:	5cfd                	li	s9,-1
ffffffffc0204ba0:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204ba2:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc0204ba6:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204ba8:	fdd6069b          	addiw	a3,a2,-35
ffffffffc0204bac:	0ff6f693          	andi	a3,a3,255
ffffffffc0204bb0:	00140d13          	addi	s10,s0,1
ffffffffc0204bb4:	1ed5ef63          	bltu	a1,a3,ffffffffc0204db2 <vprintfmt+0x282>
ffffffffc0204bb8:	068a                	slli	a3,a3,0x2
ffffffffc0204bba:	96d2                	add	a3,a3,s4
ffffffffc0204bbc:	4294                	lw	a3,0(a3)
ffffffffc0204bbe:	96d2                	add	a3,a3,s4
ffffffffc0204bc0:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0204bc2:	70e6                	ld	ra,120(sp)
ffffffffc0204bc4:	7446                	ld	s0,112(sp)
ffffffffc0204bc6:	74a6                	ld	s1,104(sp)
ffffffffc0204bc8:	7906                	ld	s2,96(sp)
ffffffffc0204bca:	69e6                	ld	s3,88(sp)
ffffffffc0204bcc:	6a46                	ld	s4,80(sp)
ffffffffc0204bce:	6aa6                	ld	s5,72(sp)
ffffffffc0204bd0:	6b06                	ld	s6,64(sp)
ffffffffc0204bd2:	7be2                	ld	s7,56(sp)
ffffffffc0204bd4:	7c42                	ld	s8,48(sp)
ffffffffc0204bd6:	7ca2                	ld	s9,40(sp)
ffffffffc0204bd8:	7d02                	ld	s10,32(sp)
ffffffffc0204bda:	6de2                	ld	s11,24(sp)
ffffffffc0204bdc:	6109                	addi	sp,sp,128
ffffffffc0204bde:	8082                	ret
            padc = '-';
ffffffffc0204be0:	87b2                	mv	a5,a2
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204be2:	00144603          	lbu	a2,1(s0)
ffffffffc0204be6:	846a                	mv	s0,s10
ffffffffc0204be8:	b7c1                	j	ffffffffc0204ba8 <vprintfmt+0x78>
            precision = va_arg(ap, int);
ffffffffc0204bea:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc0204bee:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0204bf2:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204bf4:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc0204bf6:	fa0dd9e3          	bgez	s11,ffffffffc0204ba8 <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc0204bfa:	8de6                	mv	s11,s9
ffffffffc0204bfc:	5cfd                	li	s9,-1
ffffffffc0204bfe:	b76d                	j	ffffffffc0204ba8 <vprintfmt+0x78>
            if (width < 0)
ffffffffc0204c00:	fffdc693          	not	a3,s11
ffffffffc0204c04:	96fd                	srai	a3,a3,0x3f
ffffffffc0204c06:	00ddfdb3          	and	s11,s11,a3
ffffffffc0204c0a:	00144603          	lbu	a2,1(s0)
ffffffffc0204c0e:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204c10:	846a                	mv	s0,s10
ffffffffc0204c12:	bf59                	j	ffffffffc0204ba8 <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc0204c14:	4705                	li	a4,1
ffffffffc0204c16:	008a8593          	addi	a1,s5,8
ffffffffc0204c1a:	01074463          	blt	a4,a6,ffffffffc0204c22 <vprintfmt+0xf2>
    else if (lflag) {
ffffffffc0204c1e:	22080863          	beqz	a6,ffffffffc0204e4e <vprintfmt+0x31e>
        return va_arg(*ap, unsigned long);
ffffffffc0204c22:	000ab603          	ld	a2,0(s5)
ffffffffc0204c26:	46c1                	li	a3,16
ffffffffc0204c28:	8aae                	mv	s5,a1
ffffffffc0204c2a:	a291                	j	ffffffffc0204d6e <vprintfmt+0x23e>
                precision = precision * 10 + ch - '0';
ffffffffc0204c2c:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc0204c30:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204c34:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0204c36:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0204c3a:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0204c3e:	fad56ce3          	bltu	a0,a3,ffffffffc0204bf6 <vprintfmt+0xc6>
            for (precision = 0; ; ++ fmt) {
ffffffffc0204c42:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0204c44:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc0204c48:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0204c4c:	0196873b          	addw	a4,a3,s9
ffffffffc0204c50:	0017171b          	slliw	a4,a4,0x1
ffffffffc0204c54:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc0204c58:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc0204c5c:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc0204c60:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0204c64:	fcd57fe3          	bgeu	a0,a3,ffffffffc0204c42 <vprintfmt+0x112>
ffffffffc0204c68:	b779                	j	ffffffffc0204bf6 <vprintfmt+0xc6>
            putch(va_arg(ap, int), putdat);
ffffffffc0204c6a:	000aa503          	lw	a0,0(s5)
ffffffffc0204c6e:	85a6                	mv	a1,s1
ffffffffc0204c70:	0aa1                	addi	s5,s5,8
ffffffffc0204c72:	9902                	jalr	s2
            break;
ffffffffc0204c74:	bddd                	j	ffffffffc0204b6a <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0204c76:	4705                	li	a4,1
ffffffffc0204c78:	008a8993          	addi	s3,s5,8
ffffffffc0204c7c:	01074463          	blt	a4,a6,ffffffffc0204c84 <vprintfmt+0x154>
    else if (lflag) {
ffffffffc0204c80:	1c080463          	beqz	a6,ffffffffc0204e48 <vprintfmt+0x318>
        return va_arg(*ap, long);
ffffffffc0204c84:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc0204c88:	1c044a63          	bltz	s0,ffffffffc0204e5c <vprintfmt+0x32c>
            num = getint(&ap, lflag);
ffffffffc0204c8c:	8622                	mv	a2,s0
ffffffffc0204c8e:	8ace                	mv	s5,s3
ffffffffc0204c90:	46a9                	li	a3,10
ffffffffc0204c92:	a8f1                	j	ffffffffc0204d6e <vprintfmt+0x23e>
            err = va_arg(ap, int);
ffffffffc0204c94:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204c98:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0204c9a:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc0204c9c:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0204ca0:	8fb5                	xor	a5,a5,a3
ffffffffc0204ca2:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204ca6:	12d74963          	blt	a4,a3,ffffffffc0204dd8 <vprintfmt+0x2a8>
ffffffffc0204caa:	00369793          	slli	a5,a3,0x3
ffffffffc0204cae:	97e2                	add	a5,a5,s8
ffffffffc0204cb0:	639c                	ld	a5,0(a5)
ffffffffc0204cb2:	12078363          	beqz	a5,ffffffffc0204dd8 <vprintfmt+0x2a8>
                printfmt(putch, putdat, "%s", p);
ffffffffc0204cb6:	86be                	mv	a3,a5
ffffffffc0204cb8:	00000617          	auipc	a2,0x0
ffffffffc0204cbc:	23860613          	addi	a2,a2,568 # ffffffffc0204ef0 <etext+0x28>
ffffffffc0204cc0:	85a6                	mv	a1,s1
ffffffffc0204cc2:	854a                	mv	a0,s2
ffffffffc0204cc4:	1cc000ef          	jal	ra,ffffffffc0204e90 <printfmt>
ffffffffc0204cc8:	b54d                	j	ffffffffc0204b6a <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0204cca:	000ab603          	ld	a2,0(s5)
ffffffffc0204cce:	0aa1                	addi	s5,s5,8
ffffffffc0204cd0:	1a060163          	beqz	a2,ffffffffc0204e72 <vprintfmt+0x342>
            if (width > 0 && padc != '-') {
ffffffffc0204cd4:	00160413          	addi	s0,a2,1
ffffffffc0204cd8:	15b05763          	blez	s11,ffffffffc0204e26 <vprintfmt+0x2f6>
ffffffffc0204cdc:	02d00593          	li	a1,45
ffffffffc0204ce0:	10b79d63          	bne	a5,a1,ffffffffc0204dfa <vprintfmt+0x2ca>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204ce4:	00064783          	lbu	a5,0(a2)
ffffffffc0204ce8:	0007851b          	sext.w	a0,a5
ffffffffc0204cec:	c905                	beqz	a0,ffffffffc0204d1c <vprintfmt+0x1ec>
ffffffffc0204cee:	000cc563          	bltz	s9,ffffffffc0204cf8 <vprintfmt+0x1c8>
ffffffffc0204cf2:	3cfd                	addiw	s9,s9,-1
ffffffffc0204cf4:	036c8263          	beq	s9,s6,ffffffffc0204d18 <vprintfmt+0x1e8>
                    putch('?', putdat);
ffffffffc0204cf8:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204cfa:	14098f63          	beqz	s3,ffffffffc0204e58 <vprintfmt+0x328>
ffffffffc0204cfe:	3781                	addiw	a5,a5,-32
ffffffffc0204d00:	14fbfc63          	bgeu	s7,a5,ffffffffc0204e58 <vprintfmt+0x328>
                    putch('?', putdat);
ffffffffc0204d04:	03f00513          	li	a0,63
ffffffffc0204d08:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204d0a:	0405                	addi	s0,s0,1
ffffffffc0204d0c:	fff44783          	lbu	a5,-1(s0)
ffffffffc0204d10:	3dfd                	addiw	s11,s11,-1
ffffffffc0204d12:	0007851b          	sext.w	a0,a5
ffffffffc0204d16:	fd61                	bnez	a0,ffffffffc0204cee <vprintfmt+0x1be>
            for (; width > 0; width --) {
ffffffffc0204d18:	e5b059e3          	blez	s11,ffffffffc0204b6a <vprintfmt+0x3a>
ffffffffc0204d1c:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0204d1e:	85a6                	mv	a1,s1
ffffffffc0204d20:	02000513          	li	a0,32
ffffffffc0204d24:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0204d26:	e40d82e3          	beqz	s11,ffffffffc0204b6a <vprintfmt+0x3a>
ffffffffc0204d2a:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0204d2c:	85a6                	mv	a1,s1
ffffffffc0204d2e:	02000513          	li	a0,32
ffffffffc0204d32:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0204d34:	fe0d94e3          	bnez	s11,ffffffffc0204d1c <vprintfmt+0x1ec>
ffffffffc0204d38:	bd0d                	j	ffffffffc0204b6a <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0204d3a:	4705                	li	a4,1
ffffffffc0204d3c:	008a8593          	addi	a1,s5,8
ffffffffc0204d40:	01074463          	blt	a4,a6,ffffffffc0204d48 <vprintfmt+0x218>
    else if (lflag) {
ffffffffc0204d44:	0e080863          	beqz	a6,ffffffffc0204e34 <vprintfmt+0x304>
        return va_arg(*ap, unsigned long);
ffffffffc0204d48:	000ab603          	ld	a2,0(s5)
ffffffffc0204d4c:	46a1                	li	a3,8
ffffffffc0204d4e:	8aae                	mv	s5,a1
ffffffffc0204d50:	a839                	j	ffffffffc0204d6e <vprintfmt+0x23e>
            putch('0', putdat);
ffffffffc0204d52:	03000513          	li	a0,48
ffffffffc0204d56:	85a6                	mv	a1,s1
ffffffffc0204d58:	e03e                	sd	a5,0(sp)
ffffffffc0204d5a:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0204d5c:	85a6                	mv	a1,s1
ffffffffc0204d5e:	07800513          	li	a0,120
ffffffffc0204d62:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0204d64:	0aa1                	addi	s5,s5,8
ffffffffc0204d66:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc0204d6a:	6782                	ld	a5,0(sp)
ffffffffc0204d6c:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0204d6e:	2781                	sext.w	a5,a5
ffffffffc0204d70:	876e                	mv	a4,s11
ffffffffc0204d72:	85a6                	mv	a1,s1
ffffffffc0204d74:	854a                	mv	a0,s2
ffffffffc0204d76:	d4fff0ef          	jal	ra,ffffffffc0204ac4 <printnum>
            break;
ffffffffc0204d7a:	bbc5                	j	ffffffffc0204b6a <vprintfmt+0x3a>
            lflag ++;
ffffffffc0204d7c:	00144603          	lbu	a2,1(s0)
ffffffffc0204d80:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204d82:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204d84:	b515                	j	ffffffffc0204ba8 <vprintfmt+0x78>
            goto reswitch;
ffffffffc0204d86:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0204d8a:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204d8c:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204d8e:	bd29                	j	ffffffffc0204ba8 <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc0204d90:	85a6                	mv	a1,s1
ffffffffc0204d92:	02500513          	li	a0,37
ffffffffc0204d96:	9902                	jalr	s2
            break;
ffffffffc0204d98:	bbc9                	j	ffffffffc0204b6a <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0204d9a:	4705                	li	a4,1
ffffffffc0204d9c:	008a8593          	addi	a1,s5,8
ffffffffc0204da0:	01074463          	blt	a4,a6,ffffffffc0204da8 <vprintfmt+0x278>
    else if (lflag) {
ffffffffc0204da4:	08080d63          	beqz	a6,ffffffffc0204e3e <vprintfmt+0x30e>
        return va_arg(*ap, unsigned long);
ffffffffc0204da8:	000ab603          	ld	a2,0(s5)
ffffffffc0204dac:	46a9                	li	a3,10
ffffffffc0204dae:	8aae                	mv	s5,a1
ffffffffc0204db0:	bf7d                	j	ffffffffc0204d6e <vprintfmt+0x23e>
            putch('%', putdat);
ffffffffc0204db2:	85a6                	mv	a1,s1
ffffffffc0204db4:	02500513          	li	a0,37
ffffffffc0204db8:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0204dba:	fff44703          	lbu	a4,-1(s0)
ffffffffc0204dbe:	02500793          	li	a5,37
ffffffffc0204dc2:	8d22                	mv	s10,s0
ffffffffc0204dc4:	daf703e3          	beq	a4,a5,ffffffffc0204b6a <vprintfmt+0x3a>
ffffffffc0204dc8:	02500713          	li	a4,37
ffffffffc0204dcc:	1d7d                	addi	s10,s10,-1
ffffffffc0204dce:	fffd4783          	lbu	a5,-1(s10)
ffffffffc0204dd2:	fee79de3          	bne	a5,a4,ffffffffc0204dcc <vprintfmt+0x29c>
ffffffffc0204dd6:	bb51                	j	ffffffffc0204b6a <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0204dd8:	00002617          	auipc	a2,0x2
ffffffffc0204ddc:	1f060613          	addi	a2,a2,496 # ffffffffc0206fc8 <error_string+0xd8>
ffffffffc0204de0:	85a6                	mv	a1,s1
ffffffffc0204de2:	854a                	mv	a0,s2
ffffffffc0204de4:	0ac000ef          	jal	ra,ffffffffc0204e90 <printfmt>
ffffffffc0204de8:	b349                	j	ffffffffc0204b6a <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0204dea:	00002617          	auipc	a2,0x2
ffffffffc0204dee:	1d660613          	addi	a2,a2,470 # ffffffffc0206fc0 <error_string+0xd0>
            if (width > 0 && padc != '-') {
ffffffffc0204df2:	00002417          	auipc	s0,0x2
ffffffffc0204df6:	1cf40413          	addi	s0,s0,463 # ffffffffc0206fc1 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204dfa:	8532                	mv	a0,a2
ffffffffc0204dfc:	85e6                	mv	a1,s9
ffffffffc0204dfe:	e032                	sd	a2,0(sp)
ffffffffc0204e00:	e43e                	sd	a5,8(sp)
ffffffffc0204e02:	be9ff0ef          	jal	ra,ffffffffc02049ea <strnlen>
ffffffffc0204e06:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0204e0a:	6602                	ld	a2,0(sp)
ffffffffc0204e0c:	01b05d63          	blez	s11,ffffffffc0204e26 <vprintfmt+0x2f6>
ffffffffc0204e10:	67a2                	ld	a5,8(sp)
ffffffffc0204e12:	2781                	sext.w	a5,a5
ffffffffc0204e14:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc0204e16:	6522                	ld	a0,8(sp)
ffffffffc0204e18:	85a6                	mv	a1,s1
ffffffffc0204e1a:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204e1c:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0204e1e:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204e20:	6602                	ld	a2,0(sp)
ffffffffc0204e22:	fe0d9ae3          	bnez	s11,ffffffffc0204e16 <vprintfmt+0x2e6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204e26:	00064783          	lbu	a5,0(a2)
ffffffffc0204e2a:	0007851b          	sext.w	a0,a5
ffffffffc0204e2e:	ec0510e3          	bnez	a0,ffffffffc0204cee <vprintfmt+0x1be>
ffffffffc0204e32:	bb25                	j	ffffffffc0204b6a <vprintfmt+0x3a>
        return va_arg(*ap, unsigned int);
ffffffffc0204e34:	000ae603          	lwu	a2,0(s5)
ffffffffc0204e38:	46a1                	li	a3,8
ffffffffc0204e3a:	8aae                	mv	s5,a1
ffffffffc0204e3c:	bf0d                	j	ffffffffc0204d6e <vprintfmt+0x23e>
ffffffffc0204e3e:	000ae603          	lwu	a2,0(s5)
ffffffffc0204e42:	46a9                	li	a3,10
ffffffffc0204e44:	8aae                	mv	s5,a1
ffffffffc0204e46:	b725                	j	ffffffffc0204d6e <vprintfmt+0x23e>
        return va_arg(*ap, int);
ffffffffc0204e48:	000aa403          	lw	s0,0(s5)
ffffffffc0204e4c:	bd35                	j	ffffffffc0204c88 <vprintfmt+0x158>
        return va_arg(*ap, unsigned int);
ffffffffc0204e4e:	000ae603          	lwu	a2,0(s5)
ffffffffc0204e52:	46c1                	li	a3,16
ffffffffc0204e54:	8aae                	mv	s5,a1
ffffffffc0204e56:	bf21                	j	ffffffffc0204d6e <vprintfmt+0x23e>
                    putch(ch, putdat);
ffffffffc0204e58:	9902                	jalr	s2
ffffffffc0204e5a:	bd45                	j	ffffffffc0204d0a <vprintfmt+0x1da>
                putch('-', putdat);
ffffffffc0204e5c:	85a6                	mv	a1,s1
ffffffffc0204e5e:	02d00513          	li	a0,45
ffffffffc0204e62:	e03e                	sd	a5,0(sp)
ffffffffc0204e64:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0204e66:	8ace                	mv	s5,s3
ffffffffc0204e68:	40800633          	neg	a2,s0
ffffffffc0204e6c:	46a9                	li	a3,10
ffffffffc0204e6e:	6782                	ld	a5,0(sp)
ffffffffc0204e70:	bdfd                	j	ffffffffc0204d6e <vprintfmt+0x23e>
            if (width > 0 && padc != '-') {
ffffffffc0204e72:	01b05663          	blez	s11,ffffffffc0204e7e <vprintfmt+0x34e>
ffffffffc0204e76:	02d00693          	li	a3,45
ffffffffc0204e7a:	f6d798e3          	bne	a5,a3,ffffffffc0204dea <vprintfmt+0x2ba>
ffffffffc0204e7e:	00002417          	auipc	s0,0x2
ffffffffc0204e82:	14340413          	addi	s0,s0,323 # ffffffffc0206fc1 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204e86:	02800513          	li	a0,40
ffffffffc0204e8a:	02800793          	li	a5,40
ffffffffc0204e8e:	b585                	j	ffffffffc0204cee <vprintfmt+0x1be>

ffffffffc0204e90 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204e90:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0204e92:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204e96:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0204e98:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204e9a:	ec06                	sd	ra,24(sp)
ffffffffc0204e9c:	f83a                	sd	a4,48(sp)
ffffffffc0204e9e:	fc3e                	sd	a5,56(sp)
ffffffffc0204ea0:	e0c2                	sd	a6,64(sp)
ffffffffc0204ea2:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0204ea4:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0204ea6:	c8bff0ef          	jal	ra,ffffffffc0204b30 <vprintfmt>
}
ffffffffc0204eaa:	60e2                	ld	ra,24(sp)
ffffffffc0204eac:	6161                	addi	sp,sp,80
ffffffffc0204eae:	8082                	ret

ffffffffc0204eb0 <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc0204eb0:	9e3707b7          	lui	a5,0x9e370
ffffffffc0204eb4:	2785                	addiw	a5,a5,1
ffffffffc0204eb6:	02f5053b          	mulw	a0,a0,a5
    return (hash >> (32 - bits));
ffffffffc0204eba:	02000793          	li	a5,32
ffffffffc0204ebe:	40b785bb          	subw	a1,a5,a1
}
ffffffffc0204ec2:	00b5553b          	srlw	a0,a0,a1
ffffffffc0204ec6:	8082                	ret
