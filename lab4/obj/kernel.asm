
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
ffffffffc020003a:	02250513          	addi	a0,a0,34 # ffffffffc020a058 <edata>
ffffffffc020003e:	00015617          	auipc	a2,0x15
ffffffffc0200042:	5ba60613          	addi	a2,a2,1466 # ffffffffc02155f8 <end>
kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	56a040ef          	jal	ra,ffffffffc02045b8 <memset>

    cons_init();                // init the console
ffffffffc0200052:	4e2000ef          	jal	ra,ffffffffc0200534 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200056:	00005597          	auipc	a1,0x5
ffffffffc020005a:	9c258593          	addi	a1,a1,-1598 # ffffffffc0204a18 <etext+0x2>
ffffffffc020005e:	00005517          	auipc	a0,0x5
ffffffffc0200062:	9da50513          	addi	a0,a0,-1574 # ffffffffc0204a38 <etext+0x22>
ffffffffc0200066:	06a000ef          	jal	ra,ffffffffc02000d0 <cprintf>

    print_kerninfo();
ffffffffc020006a:	1ca000ef          	jal	ra,ffffffffc0200234 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006e:	77f000ef          	jal	ra,ffffffffc0200fec <pmm_init>

    pic_init();                 // init interrupt controller
ffffffffc0200072:	534000ef          	jal	ra,ffffffffc02005a6 <pic_init>
    idt_init();                 // init interrupt descriptor table
ffffffffc0200076:	5b0000ef          	jal	ra,ffffffffc0200626 <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc020007a:	469010ef          	jal	ra,ffffffffc0201ce2 <vmm_init>
    proc_init();                // init process table
ffffffffc020007e:	19e040ef          	jal	ra,ffffffffc020421c <proc_init>
    
    ide_init();                 // init ide devices
ffffffffc0200082:	42a000ef          	jal	ra,ffffffffc02004ac <ide_init>
    swap_init();                // init swap
ffffffffc0200086:	264020ef          	jal	ra,ffffffffc02022ea <swap_init>

    clock_init();               // init clock interrupt
ffffffffc020008a:	456000ef          	jal	ra,ffffffffc02004e0 <clock_init>
    intr_enable();              // enable irq interrupt
ffffffffc020008e:	51a000ef          	jal	ra,ffffffffc02005a8 <intr_enable>

    cpu_idle();                 // run idle process
ffffffffc0200092:	3d2040ef          	jal	ra,ffffffffc0204464 <cpu_idle>

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
ffffffffc020009e:	498000ef          	jal	ra,ffffffffc0200536 <cons_putc>
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
ffffffffc02000c4:	5ba040ef          	jal	ra,ffffffffc020467e <vprintfmt>
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
ffffffffc02000f8:	586040ef          	jal	ra,ffffffffc020467e <vprintfmt>
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
ffffffffc0200104:	a90d                	j	ffffffffc0200536 <cons_putc>

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
ffffffffc020010a:	460000ef          	jal	ra,ffffffffc020056a <cons_getc>
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
ffffffffc0200132:	91250513          	addi	a0,a0,-1774 # ffffffffc0204a40 <etext+0x2a>
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
ffffffffc0200148:	f14b8b93          	addi	s7,s7,-236 # ffffffffc020a058 <edata>
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
ffffffffc02001aa:	eb250513          	addi	a0,a0,-334 # ffffffffc020a058 <edata>
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
ffffffffc02001d8:	29430313          	addi	t1,t1,660 # ffffffffc0215468 <is_panic>
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
ffffffffc02001fc:	26f72823          	sw	a5,624(a4) # ffffffffc0215468 <is_panic>

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
ffffffffc020020a:	84250513          	addi	a0,a0,-1982 # ffffffffc0204a48 <etext+0x32>
    va_start(ap, fmt);
ffffffffc020020e:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200210:	ec1ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200214:	65a2                	ld	a1,8(sp)
ffffffffc0200216:	8522                	mv	a0,s0
ffffffffc0200218:	e99ff0ef          	jal	ra,ffffffffc02000b0 <vcprintf>
    cprintf("\n");
ffffffffc020021c:	00005517          	auipc	a0,0x5
ffffffffc0200220:	5e450513          	addi	a0,a0,1508 # ffffffffc0205800 <commands+0xc98>
ffffffffc0200224:	eadff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc0200228:	386000ef          	jal	ra,ffffffffc02005ae <intr_disable>
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
ffffffffc020023a:	86250513          	addi	a0,a0,-1950 # ffffffffc0204a98 <etext+0x82>
void print_kerninfo(void) {
ffffffffc020023e:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200240:	e91ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc0200244:	00000597          	auipc	a1,0x0
ffffffffc0200248:	df258593          	addi	a1,a1,-526 # ffffffffc0200036 <kern_init>
ffffffffc020024c:	00005517          	auipc	a0,0x5
ffffffffc0200250:	86c50513          	addi	a0,a0,-1940 # ffffffffc0204ab8 <etext+0xa2>
ffffffffc0200254:	e7dff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc0200258:	00004597          	auipc	a1,0x4
ffffffffc020025c:	7be58593          	addi	a1,a1,1982 # ffffffffc0204a16 <etext>
ffffffffc0200260:	00005517          	auipc	a0,0x5
ffffffffc0200264:	87850513          	addi	a0,a0,-1928 # ffffffffc0204ad8 <etext+0xc2>
ffffffffc0200268:	e69ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc020026c:	0000a597          	auipc	a1,0xa
ffffffffc0200270:	dec58593          	addi	a1,a1,-532 # ffffffffc020a058 <edata>
ffffffffc0200274:	00005517          	auipc	a0,0x5
ffffffffc0200278:	88450513          	addi	a0,a0,-1916 # ffffffffc0204af8 <etext+0xe2>
ffffffffc020027c:	e55ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200280:	00015597          	auipc	a1,0x15
ffffffffc0200284:	37858593          	addi	a1,a1,888 # ffffffffc02155f8 <end>
ffffffffc0200288:	00005517          	auipc	a0,0x5
ffffffffc020028c:	89050513          	addi	a0,a0,-1904 # ffffffffc0204b18 <etext+0x102>
ffffffffc0200290:	e41ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200294:	00015597          	auipc	a1,0x15
ffffffffc0200298:	76358593          	addi	a1,a1,1891 # ffffffffc02159f7 <end+0x3ff>
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
ffffffffc02002ba:	88250513          	addi	a0,a0,-1918 # ffffffffc0204b38 <etext+0x122>
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
ffffffffc02002c4:	00004617          	auipc	a2,0x4
ffffffffc02002c8:	7a460613          	addi	a2,a2,1956 # ffffffffc0204a68 <etext+0x52>
ffffffffc02002cc:	04d00593          	li	a1,77
ffffffffc02002d0:	00004517          	auipc	a0,0x4
ffffffffc02002d4:	7b050513          	addi	a0,a0,1968 # ffffffffc0204a80 <etext+0x6a>
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
ffffffffc02002e4:	96860613          	addi	a2,a2,-1688 # ffffffffc0204c48 <commands+0xe0>
ffffffffc02002e8:	00005597          	auipc	a1,0x5
ffffffffc02002ec:	98058593          	addi	a1,a1,-1664 # ffffffffc0204c68 <commands+0x100>
ffffffffc02002f0:	00005517          	auipc	a0,0x5
ffffffffc02002f4:	98050513          	addi	a0,a0,-1664 # ffffffffc0204c70 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002f8:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002fa:	dd7ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc02002fe:	00005617          	auipc	a2,0x5
ffffffffc0200302:	98260613          	addi	a2,a2,-1662 # ffffffffc0204c80 <commands+0x118>
ffffffffc0200306:	00005597          	auipc	a1,0x5
ffffffffc020030a:	9a258593          	addi	a1,a1,-1630 # ffffffffc0204ca8 <commands+0x140>
ffffffffc020030e:	00005517          	auipc	a0,0x5
ffffffffc0200312:	96250513          	addi	a0,a0,-1694 # ffffffffc0204c70 <commands+0x108>
ffffffffc0200316:	dbbff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc020031a:	00005617          	auipc	a2,0x5
ffffffffc020031e:	99e60613          	addi	a2,a2,-1634 # ffffffffc0204cb8 <commands+0x150>
ffffffffc0200322:	00005597          	auipc	a1,0x5
ffffffffc0200326:	9b658593          	addi	a1,a1,-1610 # ffffffffc0204cd8 <commands+0x170>
ffffffffc020032a:	00005517          	auipc	a0,0x5
ffffffffc020032e:	94650513          	addi	a0,a0,-1722 # ffffffffc0204c70 <commands+0x108>
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
ffffffffc0200368:	84c50513          	addi	a0,a0,-1972 # ffffffffc0204bb0 <commands+0x48>
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
ffffffffc020038a:	85250513          	addi	a0,a0,-1966 # ffffffffc0204bd8 <commands+0x70>
ffffffffc020038e:	d43ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    if (tf != NULL) {
ffffffffc0200392:	000c0563          	beqz	s8,ffffffffc020039c <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc0200396:	8562                	mv	a0,s8
ffffffffc0200398:	476000ef          	jal	ra,ffffffffc020080e <print_trapframe>
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
ffffffffc02003a8:	00004c97          	auipc	s9,0x4
ffffffffc02003ac:	7c0c8c93          	addi	s9,s9,1984 # ffffffffc0204b68 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02003b0:	00005997          	auipc	s3,0x5
ffffffffc02003b4:	85098993          	addi	s3,s3,-1968 # ffffffffc0204c00 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003b8:	00005917          	auipc	s2,0x5
ffffffffc02003bc:	85090913          	addi	s2,s2,-1968 # ffffffffc0204c08 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc02003c0:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02003c2:	00005b17          	auipc	s6,0x5
ffffffffc02003c6:	84eb0b13          	addi	s6,s6,-1970 # ffffffffc0204c10 <commands+0xa8>
    if (argc == 0) {
ffffffffc02003ca:	00005a97          	auipc	s5,0x5
ffffffffc02003ce:	89ea8a93          	addi	s5,s5,-1890 # ffffffffc0204c68 <commands+0x100>
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
ffffffffc02003e8:	1b2040ef          	jal	ra,ffffffffc020459a <strchr>
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
ffffffffc02003fe:	00004d17          	auipc	s10,0x4
ffffffffc0200402:	76ad0d13          	addi	s10,s10,1898 # ffffffffc0204b68 <commands>
    if (argc == 0) {
ffffffffc0200406:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200408:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020040a:	0d61                	addi	s10,s10,24
ffffffffc020040c:	164040ef          	jal	ra,ffffffffc0204570 <strcmp>
ffffffffc0200410:	c919                	beqz	a0,ffffffffc0200426 <kmonitor+0xc8>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200412:	2405                	addiw	s0,s0,1
ffffffffc0200414:	09740463          	beq	s0,s7,ffffffffc020049c <kmonitor+0x13e>
ffffffffc0200418:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020041c:	6582                	ld	a1,0(sp)
ffffffffc020041e:	0d61                	addi	s10,s10,24
ffffffffc0200420:	150040ef          	jal	ra,ffffffffc0204570 <strcmp>
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
ffffffffc0200486:	114040ef          	jal	ra,ffffffffc020459a <strchr>
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
ffffffffc020049e:	00004517          	auipc	a0,0x4
ffffffffc02004a2:	79250513          	addi	a0,a0,1938 # ffffffffc0204c30 <commands+0xc8>
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

ffffffffc02004ba <ide_write_secs>:
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
    return 0;
}

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
ffffffffc02004ba:	8732                	mv	a4,a2
    int iobase = secno * SECTSIZE;
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004bc:	0095979b          	slliw	a5,a1,0x9
ffffffffc02004c0:	0000a517          	auipc	a0,0xa
ffffffffc02004c4:	f9850513          	addi	a0,a0,-104 # ffffffffc020a458 <ide>
                   size_t nsecs) {
ffffffffc02004c8:	1141                	addi	sp,sp,-16
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004ca:	00969613          	slli	a2,a3,0x9
ffffffffc02004ce:	85ba                	mv	a1,a4
ffffffffc02004d0:	953e                	add	a0,a0,a5
                   size_t nsecs) {
ffffffffc02004d2:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004d4:	0f6040ef          	jal	ra,ffffffffc02045ca <memcpy>
    return 0;
}
ffffffffc02004d8:	60a2                	ld	ra,8(sp)
ffffffffc02004da:	4501                	li	a0,0
ffffffffc02004dc:	0141                	addi	sp,sp,16
ffffffffc02004de:	8082                	ret

ffffffffc02004e0 <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc02004e0:	67e1                	lui	a5,0x18
ffffffffc02004e2:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc02004e6:	00015717          	auipc	a4,0x15
ffffffffc02004ea:	f8f73523          	sd	a5,-118(a4) # ffffffffc0215470 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc02004ee:	c0102573          	rdtime	a0
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc02004f2:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc02004f4:	953e                	add	a0,a0,a5
ffffffffc02004f6:	4601                	li	a2,0
ffffffffc02004f8:	4881                	li	a7,0
ffffffffc02004fa:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc02004fe:	02000793          	li	a5,32
ffffffffc0200502:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc0200506:	00004517          	auipc	a0,0x4
ffffffffc020050a:	7e250513          	addi	a0,a0,2018 # ffffffffc0204ce8 <commands+0x180>
    ticks = 0;
ffffffffc020050e:	00015797          	auipc	a5,0x15
ffffffffc0200512:	fa07bd23          	sd	zero,-70(a5) # ffffffffc02154c8 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200516:	be6d                	j	ffffffffc02000d0 <cprintf>

ffffffffc0200518 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200518:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020051c:	00015797          	auipc	a5,0x15
ffffffffc0200520:	f5478793          	addi	a5,a5,-172 # ffffffffc0215470 <timebase>
ffffffffc0200524:	639c                	ld	a5,0(a5)
ffffffffc0200526:	4581                	li	a1,0
ffffffffc0200528:	4601                	li	a2,0
ffffffffc020052a:	953e                	add	a0,a0,a5
ffffffffc020052c:	4881                	li	a7,0
ffffffffc020052e:	00000073          	ecall
ffffffffc0200532:	8082                	ret

ffffffffc0200534 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200534:	8082                	ret

ffffffffc0200536 <cons_putc>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200536:	100027f3          	csrr	a5,sstatus
ffffffffc020053a:	8b89                	andi	a5,a5,2
ffffffffc020053c:	0ff57513          	andi	a0,a0,255
ffffffffc0200540:	e799                	bnez	a5,ffffffffc020054e <cons_putc+0x18>
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc0200542:	4581                	li	a1,0
ffffffffc0200544:	4601                	li	a2,0
ffffffffc0200546:	4885                	li	a7,1
ffffffffc0200548:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc020054c:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc020054e:	1101                	addi	sp,sp,-32
ffffffffc0200550:	ec06                	sd	ra,24(sp)
ffffffffc0200552:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0200554:	05a000ef          	jal	ra,ffffffffc02005ae <intr_disable>
ffffffffc0200558:	6522                	ld	a0,8(sp)
ffffffffc020055a:	4581                	li	a1,0
ffffffffc020055c:	4601                	li	a2,0
ffffffffc020055e:	4885                	li	a7,1
ffffffffc0200560:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);// 确保在字符被发送到控制台的过程中，不会发生中断
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200564:	60e2                	ld	ra,24(sp)
ffffffffc0200566:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200568:	a081                	j	ffffffffc02005a8 <intr_enable>

ffffffffc020056a <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020056a:	100027f3          	csrr	a5,sstatus
ffffffffc020056e:	8b89                	andi	a5,a5,2
ffffffffc0200570:	eb89                	bnez	a5,ffffffffc0200582 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc0200572:	4501                	li	a0,0
ffffffffc0200574:	4581                	li	a1,0
ffffffffc0200576:	4601                	li	a2,0
ffffffffc0200578:	4889                	li	a7,2
ffffffffc020057a:	00000073          	ecall
ffffffffc020057e:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();// 读取操作需要一次性完成
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc0200580:	8082                	ret
int cons_getc(void) {
ffffffffc0200582:	1101                	addi	sp,sp,-32
ffffffffc0200584:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0200586:	028000ef          	jal	ra,ffffffffc02005ae <intr_disable>
ffffffffc020058a:	4501                	li	a0,0
ffffffffc020058c:	4581                	li	a1,0
ffffffffc020058e:	4601                	li	a2,0
ffffffffc0200590:	4889                	li	a7,2
ffffffffc0200592:	00000073          	ecall
ffffffffc0200596:	2501                	sext.w	a0,a0
ffffffffc0200598:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc020059a:	00e000ef          	jal	ra,ffffffffc02005a8 <intr_enable>
}
ffffffffc020059e:	60e2                	ld	ra,24(sp)
ffffffffc02005a0:	6522                	ld	a0,8(sp)
ffffffffc02005a2:	6105                	addi	sp,sp,32
ffffffffc02005a4:	8082                	ret

ffffffffc02005a6 <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
ffffffffc02005a6:	8082                	ret

ffffffffc02005a8 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc02005a8:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc02005ac:	8082                	ret

ffffffffc02005ae <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc02005ae:	100177f3          	csrrci	a5,sstatus,2
ffffffffc02005b2:	8082                	ret

ffffffffc02005b4 <pgfault_handler>:
    set_csr(sstatus, SSTATUS_SUM);
}

/* trap_in_kernel - test if trap happened in kernel */
bool trap_in_kernel(struct trapframe *tf) {
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02005b4:	10053783          	ld	a5,256(a0)
    cprintf("page falut at 0x%08x: %c/%c\n", tf->badvaddr,
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int pgfault_handler(struct trapframe *tf) {
ffffffffc02005b8:	1141                	addi	sp,sp,-16
ffffffffc02005ba:	e022                	sd	s0,0(sp)
ffffffffc02005bc:	e406                	sd	ra,8(sp)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02005be:	1007f793          	andi	a5,a5,256
static int pgfault_handler(struct trapframe *tf) {
ffffffffc02005c2:	842a                	mv	s0,a0
    cprintf("page falut at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc02005c4:	11053583          	ld	a1,272(a0)
ffffffffc02005c8:	05500613          	li	a2,85
ffffffffc02005cc:	c399                	beqz	a5,ffffffffc02005d2 <pgfault_handler+0x1e>
ffffffffc02005ce:	04b00613          	li	a2,75
ffffffffc02005d2:	11843703          	ld	a4,280(s0)
ffffffffc02005d6:	47bd                	li	a5,15
ffffffffc02005d8:	05700693          	li	a3,87
ffffffffc02005dc:	00f70463          	beq	a4,a5,ffffffffc02005e4 <pgfault_handler+0x30>
ffffffffc02005e0:	05200693          	li	a3,82
ffffffffc02005e4:	00005517          	auipc	a0,0x5
ffffffffc02005e8:	9fc50513          	addi	a0,a0,-1540 # ffffffffc0204fe0 <commands+0x478>
ffffffffc02005ec:	ae5ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
    if (check_mm_struct != NULL) {
ffffffffc02005f0:	00015797          	auipc	a5,0x15
ffffffffc02005f4:	f0078793          	addi	a5,a5,-256 # ffffffffc02154f0 <check_mm_struct>
ffffffffc02005f8:	6388                	ld	a0,0(a5)
ffffffffc02005fa:	c911                	beqz	a0,ffffffffc020060e <pgfault_handler+0x5a>
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc02005fc:	11043603          	ld	a2,272(s0)
ffffffffc0200600:	11842583          	lw	a1,280(s0)
    }
    panic("unhandled page fault.\n");
}
ffffffffc0200604:	6402                	ld	s0,0(sp)
ffffffffc0200606:	60a2                	ld	ra,8(sp)
ffffffffc0200608:	0141                	addi	sp,sp,16
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc020060a:	41f0106f          	j	ffffffffc0202228 <do_pgfault>
    panic("unhandled page fault.\n");
ffffffffc020060e:	00005617          	auipc	a2,0x5
ffffffffc0200612:	9f260613          	addi	a2,a2,-1550 # ffffffffc0205000 <commands+0x498>
ffffffffc0200616:	06200593          	li	a1,98
ffffffffc020061a:	00005517          	auipc	a0,0x5
ffffffffc020061e:	9fe50513          	addi	a0,a0,-1538 # ffffffffc0205018 <commands+0x4b0>
ffffffffc0200622:	bb3ff0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc0200626 <idt_init>:
    write_csr(sscratch, 0);
ffffffffc0200626:	14005073          	csrwi	sscratch,0
    write_csr(stvec, &__alltraps);
ffffffffc020062a:	00000797          	auipc	a5,0x0
ffffffffc020062e:	48278793          	addi	a5,a5,1154 # ffffffffc0200aac <__alltraps>
ffffffffc0200632:	10579073          	csrw	stvec,a5
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc0200636:	000407b7          	lui	a5,0x40
ffffffffc020063a:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc020063e:	8082                	ret

ffffffffc0200640 <print_regs>:
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200640:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200642:	1141                	addi	sp,sp,-16
ffffffffc0200644:	e022                	sd	s0,0(sp)
ffffffffc0200646:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200648:	00005517          	auipc	a0,0x5
ffffffffc020064c:	9e850513          	addi	a0,a0,-1560 # ffffffffc0205030 <commands+0x4c8>
void print_regs(struct pushregs *gpr) {
ffffffffc0200650:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200652:	a7fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200656:	640c                	ld	a1,8(s0)
ffffffffc0200658:	00005517          	auipc	a0,0x5
ffffffffc020065c:	9f050513          	addi	a0,a0,-1552 # ffffffffc0205048 <commands+0x4e0>
ffffffffc0200660:	a71ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc0200664:	680c                	ld	a1,16(s0)
ffffffffc0200666:	00005517          	auipc	a0,0x5
ffffffffc020066a:	9fa50513          	addi	a0,a0,-1542 # ffffffffc0205060 <commands+0x4f8>
ffffffffc020066e:	a63ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc0200672:	6c0c                	ld	a1,24(s0)
ffffffffc0200674:	00005517          	auipc	a0,0x5
ffffffffc0200678:	a0450513          	addi	a0,a0,-1532 # ffffffffc0205078 <commands+0x510>
ffffffffc020067c:	a55ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc0200680:	700c                	ld	a1,32(s0)
ffffffffc0200682:	00005517          	auipc	a0,0x5
ffffffffc0200686:	a0e50513          	addi	a0,a0,-1522 # ffffffffc0205090 <commands+0x528>
ffffffffc020068a:	a47ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc020068e:	740c                	ld	a1,40(s0)
ffffffffc0200690:	00005517          	auipc	a0,0x5
ffffffffc0200694:	a1850513          	addi	a0,a0,-1512 # ffffffffc02050a8 <commands+0x540>
ffffffffc0200698:	a39ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc020069c:	780c                	ld	a1,48(s0)
ffffffffc020069e:	00005517          	auipc	a0,0x5
ffffffffc02006a2:	a2250513          	addi	a0,a0,-1502 # ffffffffc02050c0 <commands+0x558>
ffffffffc02006a6:	a2bff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02006aa:	7c0c                	ld	a1,56(s0)
ffffffffc02006ac:	00005517          	auipc	a0,0x5
ffffffffc02006b0:	a2c50513          	addi	a0,a0,-1492 # ffffffffc02050d8 <commands+0x570>
ffffffffc02006b4:	a1dff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02006b8:	602c                	ld	a1,64(s0)
ffffffffc02006ba:	00005517          	auipc	a0,0x5
ffffffffc02006be:	a3650513          	addi	a0,a0,-1482 # ffffffffc02050f0 <commands+0x588>
ffffffffc02006c2:	a0fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02006c6:	642c                	ld	a1,72(s0)
ffffffffc02006c8:	00005517          	auipc	a0,0x5
ffffffffc02006cc:	a4050513          	addi	a0,a0,-1472 # ffffffffc0205108 <commands+0x5a0>
ffffffffc02006d0:	a01ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc02006d4:	682c                	ld	a1,80(s0)
ffffffffc02006d6:	00005517          	auipc	a0,0x5
ffffffffc02006da:	a4a50513          	addi	a0,a0,-1462 # ffffffffc0205120 <commands+0x5b8>
ffffffffc02006de:	9f3ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc02006e2:	6c2c                	ld	a1,88(s0)
ffffffffc02006e4:	00005517          	auipc	a0,0x5
ffffffffc02006e8:	a5450513          	addi	a0,a0,-1452 # ffffffffc0205138 <commands+0x5d0>
ffffffffc02006ec:	9e5ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc02006f0:	702c                	ld	a1,96(s0)
ffffffffc02006f2:	00005517          	auipc	a0,0x5
ffffffffc02006f6:	a5e50513          	addi	a0,a0,-1442 # ffffffffc0205150 <commands+0x5e8>
ffffffffc02006fa:	9d7ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc02006fe:	742c                	ld	a1,104(s0)
ffffffffc0200700:	00005517          	auipc	a0,0x5
ffffffffc0200704:	a6850513          	addi	a0,a0,-1432 # ffffffffc0205168 <commands+0x600>
ffffffffc0200708:	9c9ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc020070c:	782c                	ld	a1,112(s0)
ffffffffc020070e:	00005517          	auipc	a0,0x5
ffffffffc0200712:	a7250513          	addi	a0,a0,-1422 # ffffffffc0205180 <commands+0x618>
ffffffffc0200716:	9bbff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc020071a:	7c2c                	ld	a1,120(s0)
ffffffffc020071c:	00005517          	auipc	a0,0x5
ffffffffc0200720:	a7c50513          	addi	a0,a0,-1412 # ffffffffc0205198 <commands+0x630>
ffffffffc0200724:	9adff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200728:	604c                	ld	a1,128(s0)
ffffffffc020072a:	00005517          	auipc	a0,0x5
ffffffffc020072e:	a8650513          	addi	a0,a0,-1402 # ffffffffc02051b0 <commands+0x648>
ffffffffc0200732:	99fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200736:	644c                	ld	a1,136(s0)
ffffffffc0200738:	00005517          	auipc	a0,0x5
ffffffffc020073c:	a9050513          	addi	a0,a0,-1392 # ffffffffc02051c8 <commands+0x660>
ffffffffc0200740:	991ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200744:	684c                	ld	a1,144(s0)
ffffffffc0200746:	00005517          	auipc	a0,0x5
ffffffffc020074a:	a9a50513          	addi	a0,a0,-1382 # ffffffffc02051e0 <commands+0x678>
ffffffffc020074e:	983ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200752:	6c4c                	ld	a1,152(s0)
ffffffffc0200754:	00005517          	auipc	a0,0x5
ffffffffc0200758:	aa450513          	addi	a0,a0,-1372 # ffffffffc02051f8 <commands+0x690>
ffffffffc020075c:	975ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200760:	704c                	ld	a1,160(s0)
ffffffffc0200762:	00005517          	auipc	a0,0x5
ffffffffc0200766:	aae50513          	addi	a0,a0,-1362 # ffffffffc0205210 <commands+0x6a8>
ffffffffc020076a:	967ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc020076e:	744c                	ld	a1,168(s0)
ffffffffc0200770:	00005517          	auipc	a0,0x5
ffffffffc0200774:	ab850513          	addi	a0,a0,-1352 # ffffffffc0205228 <commands+0x6c0>
ffffffffc0200778:	959ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc020077c:	784c                	ld	a1,176(s0)
ffffffffc020077e:	00005517          	auipc	a0,0x5
ffffffffc0200782:	ac250513          	addi	a0,a0,-1342 # ffffffffc0205240 <commands+0x6d8>
ffffffffc0200786:	94bff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc020078a:	7c4c                	ld	a1,184(s0)
ffffffffc020078c:	00005517          	auipc	a0,0x5
ffffffffc0200790:	acc50513          	addi	a0,a0,-1332 # ffffffffc0205258 <commands+0x6f0>
ffffffffc0200794:	93dff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc0200798:	606c                	ld	a1,192(s0)
ffffffffc020079a:	00005517          	auipc	a0,0x5
ffffffffc020079e:	ad650513          	addi	a0,a0,-1322 # ffffffffc0205270 <commands+0x708>
ffffffffc02007a2:	92fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02007a6:	646c                	ld	a1,200(s0)
ffffffffc02007a8:	00005517          	auipc	a0,0x5
ffffffffc02007ac:	ae050513          	addi	a0,a0,-1312 # ffffffffc0205288 <commands+0x720>
ffffffffc02007b0:	921ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02007b4:	686c                	ld	a1,208(s0)
ffffffffc02007b6:	00005517          	auipc	a0,0x5
ffffffffc02007ba:	aea50513          	addi	a0,a0,-1302 # ffffffffc02052a0 <commands+0x738>
ffffffffc02007be:	913ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02007c2:	6c6c                	ld	a1,216(s0)
ffffffffc02007c4:	00005517          	auipc	a0,0x5
ffffffffc02007c8:	af450513          	addi	a0,a0,-1292 # ffffffffc02052b8 <commands+0x750>
ffffffffc02007cc:	905ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc02007d0:	706c                	ld	a1,224(s0)
ffffffffc02007d2:	00005517          	auipc	a0,0x5
ffffffffc02007d6:	afe50513          	addi	a0,a0,-1282 # ffffffffc02052d0 <commands+0x768>
ffffffffc02007da:	8f7ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc02007de:	746c                	ld	a1,232(s0)
ffffffffc02007e0:	00005517          	auipc	a0,0x5
ffffffffc02007e4:	b0850513          	addi	a0,a0,-1272 # ffffffffc02052e8 <commands+0x780>
ffffffffc02007e8:	8e9ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc02007ec:	786c                	ld	a1,240(s0)
ffffffffc02007ee:	00005517          	auipc	a0,0x5
ffffffffc02007f2:	b1250513          	addi	a0,a0,-1262 # ffffffffc0205300 <commands+0x798>
ffffffffc02007f6:	8dbff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc02007fa:	7c6c                	ld	a1,248(s0)
}
ffffffffc02007fc:	6402                	ld	s0,0(sp)
ffffffffc02007fe:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200800:	00005517          	auipc	a0,0x5
ffffffffc0200804:	b1850513          	addi	a0,a0,-1256 # ffffffffc0205318 <commands+0x7b0>
}
ffffffffc0200808:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020080a:	8c7ff06f          	j	ffffffffc02000d0 <cprintf>

ffffffffc020080e <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc020080e:	1141                	addi	sp,sp,-16
ffffffffc0200810:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200812:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200814:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200816:	00005517          	auipc	a0,0x5
ffffffffc020081a:	b1a50513          	addi	a0,a0,-1254 # ffffffffc0205330 <commands+0x7c8>
void print_trapframe(struct trapframe *tf) {
ffffffffc020081e:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200820:	8b1ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200824:	8522                	mv	a0,s0
ffffffffc0200826:	e1bff0ef          	jal	ra,ffffffffc0200640 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020082a:	10043583          	ld	a1,256(s0)
ffffffffc020082e:	00005517          	auipc	a0,0x5
ffffffffc0200832:	b1a50513          	addi	a0,a0,-1254 # ffffffffc0205348 <commands+0x7e0>
ffffffffc0200836:	89bff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020083a:	10843583          	ld	a1,264(s0)
ffffffffc020083e:	00005517          	auipc	a0,0x5
ffffffffc0200842:	b2250513          	addi	a0,a0,-1246 # ffffffffc0205360 <commands+0x7f8>
ffffffffc0200846:	88bff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020084a:	11043583          	ld	a1,272(s0)
ffffffffc020084e:	00005517          	auipc	a0,0x5
ffffffffc0200852:	b2a50513          	addi	a0,a0,-1238 # ffffffffc0205378 <commands+0x810>
ffffffffc0200856:	87bff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020085a:	11843583          	ld	a1,280(s0)
}
ffffffffc020085e:	6402                	ld	s0,0(sp)
ffffffffc0200860:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200862:	00005517          	auipc	a0,0x5
ffffffffc0200866:	b2e50513          	addi	a0,a0,-1234 # ffffffffc0205390 <commands+0x828>
}
ffffffffc020086a:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020086c:	865ff06f          	j	ffffffffc02000d0 <cprintf>

ffffffffc0200870 <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc0200870:	11853783          	ld	a5,280(a0)
    switch (cause) {
ffffffffc0200874:	472d                	li	a4,11
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc0200876:	0786                	slli	a5,a5,0x1
ffffffffc0200878:	8385                	srli	a5,a5,0x1
    switch (cause) {
ffffffffc020087a:	06f76f63          	bltu	a4,a5,ffffffffc02008f8 <interrupt_handler+0x88>
ffffffffc020087e:	00004717          	auipc	a4,0x4
ffffffffc0200882:	48670713          	addi	a4,a4,1158 # ffffffffc0204d04 <commands+0x19c>
ffffffffc0200886:	078a                	slli	a5,a5,0x2
ffffffffc0200888:	97ba                	add	a5,a5,a4
ffffffffc020088a:	439c                	lw	a5,0(a5)
ffffffffc020088c:	97ba                	add	a5,a5,a4
ffffffffc020088e:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc0200890:	00004517          	auipc	a0,0x4
ffffffffc0200894:	70050513          	addi	a0,a0,1792 # ffffffffc0204f90 <commands+0x428>
ffffffffc0200898:	839ff06f          	j	ffffffffc02000d0 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc020089c:	00004517          	auipc	a0,0x4
ffffffffc02008a0:	6d450513          	addi	a0,a0,1748 # ffffffffc0204f70 <commands+0x408>
ffffffffc02008a4:	82dff06f          	j	ffffffffc02000d0 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02008a8:	00004517          	auipc	a0,0x4
ffffffffc02008ac:	68850513          	addi	a0,a0,1672 # ffffffffc0204f30 <commands+0x3c8>
ffffffffc02008b0:	821ff06f          	j	ffffffffc02000d0 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02008b4:	00004517          	auipc	a0,0x4
ffffffffc02008b8:	69c50513          	addi	a0,a0,1692 # ffffffffc0204f50 <commands+0x3e8>
ffffffffc02008bc:	815ff06f          	j	ffffffffc02000d0 <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
ffffffffc02008c0:	00004517          	auipc	a0,0x4
ffffffffc02008c4:	70050513          	addi	a0,a0,1792 # ffffffffc0204fc0 <commands+0x458>
ffffffffc02008c8:	809ff06f          	j	ffffffffc02000d0 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02008cc:	1141                	addi	sp,sp,-16
ffffffffc02008ce:	e406                	sd	ra,8(sp)
            clock_set_next_event();
ffffffffc02008d0:	c49ff0ef          	jal	ra,ffffffffc0200518 <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc02008d4:	00015797          	auipc	a5,0x15
ffffffffc02008d8:	bf478793          	addi	a5,a5,-1036 # ffffffffc02154c8 <ticks>
ffffffffc02008dc:	639c                	ld	a5,0(a5)
ffffffffc02008de:	06400713          	li	a4,100
ffffffffc02008e2:	0785                	addi	a5,a5,1
ffffffffc02008e4:	02e7f733          	remu	a4,a5,a4
ffffffffc02008e8:	00015697          	auipc	a3,0x15
ffffffffc02008ec:	bef6b023          	sd	a5,-1056(a3) # ffffffffc02154c8 <ticks>
ffffffffc02008f0:	c709                	beqz	a4,ffffffffc02008fa <interrupt_handler+0x8a>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc02008f2:	60a2                	ld	ra,8(sp)
ffffffffc02008f4:	0141                	addi	sp,sp,16
ffffffffc02008f6:	8082                	ret
            print_trapframe(tf);
ffffffffc02008f8:	bf19                	j	ffffffffc020080e <print_trapframe>
}
ffffffffc02008fa:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc02008fc:	06400593          	li	a1,100
ffffffffc0200900:	00004517          	auipc	a0,0x4
ffffffffc0200904:	6b050513          	addi	a0,a0,1712 # ffffffffc0204fb0 <commands+0x448>
}
ffffffffc0200908:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc020090a:	fc6ff06f          	j	ffffffffc02000d0 <cprintf>

ffffffffc020090e <exception_handler>:

void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc020090e:	11853783          	ld	a5,280(a0)
ffffffffc0200912:	473d                	li	a4,15
ffffffffc0200914:	16f76463          	bltu	a4,a5,ffffffffc0200a7c <exception_handler+0x16e>
ffffffffc0200918:	00004717          	auipc	a4,0x4
ffffffffc020091c:	41c70713          	addi	a4,a4,1052 # ffffffffc0204d34 <commands+0x1cc>
ffffffffc0200920:	078a                	slli	a5,a5,0x2
ffffffffc0200922:	97ba                	add	a5,a5,a4
ffffffffc0200924:	439c                	lw	a5,0(a5)
void exception_handler(struct trapframe *tf) {
ffffffffc0200926:	1101                	addi	sp,sp,-32
ffffffffc0200928:	e822                	sd	s0,16(sp)
ffffffffc020092a:	ec06                	sd	ra,24(sp)
ffffffffc020092c:	e426                	sd	s1,8(sp)
    switch (tf->cause) {
ffffffffc020092e:	97ba                	add	a5,a5,a4
ffffffffc0200930:	842a                	mv	s0,a0
ffffffffc0200932:	8782                	jr	a5
                print_trapframe(tf);
                panic("handle pgfault failed. %e\n", ret);
            }
            break;
        case CAUSE_STORE_PAGE_FAULT:
            cprintf("Store/AMO page fault\n");
ffffffffc0200934:	00004517          	auipc	a0,0x4
ffffffffc0200938:	5e450513          	addi	a0,a0,1508 # ffffffffc0204f18 <commands+0x3b0>
ffffffffc020093c:	f94ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200940:	8522                	mv	a0,s0
ffffffffc0200942:	c73ff0ef          	jal	ra,ffffffffc02005b4 <pgfault_handler>
ffffffffc0200946:	84aa                	mv	s1,a0
ffffffffc0200948:	12051b63          	bnez	a0,ffffffffc0200a7e <exception_handler+0x170>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc020094c:	60e2                	ld	ra,24(sp)
ffffffffc020094e:	6442                	ld	s0,16(sp)
ffffffffc0200950:	64a2                	ld	s1,8(sp)
ffffffffc0200952:	6105                	addi	sp,sp,32
ffffffffc0200954:	8082                	ret
            cprintf("Instruction address misaligned\n");
ffffffffc0200956:	00004517          	auipc	a0,0x4
ffffffffc020095a:	42250513          	addi	a0,a0,1058 # ffffffffc0204d78 <commands+0x210>
}
ffffffffc020095e:	6442                	ld	s0,16(sp)
ffffffffc0200960:	60e2                	ld	ra,24(sp)
ffffffffc0200962:	64a2                	ld	s1,8(sp)
ffffffffc0200964:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc0200966:	f6aff06f          	j	ffffffffc02000d0 <cprintf>
ffffffffc020096a:	00004517          	auipc	a0,0x4
ffffffffc020096e:	42e50513          	addi	a0,a0,1070 # ffffffffc0204d98 <commands+0x230>
ffffffffc0200972:	b7f5                	j	ffffffffc020095e <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc0200974:	00004517          	auipc	a0,0x4
ffffffffc0200978:	44450513          	addi	a0,a0,1092 # ffffffffc0204db8 <commands+0x250>
ffffffffc020097c:	b7cd                	j	ffffffffc020095e <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc020097e:	00004517          	auipc	a0,0x4
ffffffffc0200982:	45250513          	addi	a0,a0,1106 # ffffffffc0204dd0 <commands+0x268>
ffffffffc0200986:	bfe1                	j	ffffffffc020095e <exception_handler+0x50>
            cprintf("Load address misaligned\n");
ffffffffc0200988:	00004517          	auipc	a0,0x4
ffffffffc020098c:	45850513          	addi	a0,a0,1112 # ffffffffc0204de0 <commands+0x278>
ffffffffc0200990:	b7f9                	j	ffffffffc020095e <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc0200992:	00004517          	auipc	a0,0x4
ffffffffc0200996:	46e50513          	addi	a0,a0,1134 # ffffffffc0204e00 <commands+0x298>
ffffffffc020099a:	f36ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc020099e:	8522                	mv	a0,s0
ffffffffc02009a0:	c15ff0ef          	jal	ra,ffffffffc02005b4 <pgfault_handler>
ffffffffc02009a4:	84aa                	mv	s1,a0
ffffffffc02009a6:	d15d                	beqz	a0,ffffffffc020094c <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc02009a8:	8522                	mv	a0,s0
ffffffffc02009aa:	e65ff0ef          	jal	ra,ffffffffc020080e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02009ae:	86a6                	mv	a3,s1
ffffffffc02009b0:	00004617          	auipc	a2,0x4
ffffffffc02009b4:	46860613          	addi	a2,a2,1128 # ffffffffc0204e18 <commands+0x2b0>
ffffffffc02009b8:	0b300593          	li	a1,179
ffffffffc02009bc:	00004517          	auipc	a0,0x4
ffffffffc02009c0:	65c50513          	addi	a0,a0,1628 # ffffffffc0205018 <commands+0x4b0>
ffffffffc02009c4:	811ff0ef          	jal	ra,ffffffffc02001d4 <__panic>
            cprintf("AMO address misaligned\n");
ffffffffc02009c8:	00004517          	auipc	a0,0x4
ffffffffc02009cc:	47050513          	addi	a0,a0,1136 # ffffffffc0204e38 <commands+0x2d0>
ffffffffc02009d0:	b779                	j	ffffffffc020095e <exception_handler+0x50>
            cprintf("Store/AMO access fault\n");
ffffffffc02009d2:	00004517          	auipc	a0,0x4
ffffffffc02009d6:	47e50513          	addi	a0,a0,1150 # ffffffffc0204e50 <commands+0x2e8>
ffffffffc02009da:	ef6ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02009de:	8522                	mv	a0,s0
ffffffffc02009e0:	bd5ff0ef          	jal	ra,ffffffffc02005b4 <pgfault_handler>
ffffffffc02009e4:	84aa                	mv	s1,a0
ffffffffc02009e6:	d13d                	beqz	a0,ffffffffc020094c <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc02009e8:	8522                	mv	a0,s0
ffffffffc02009ea:	e25ff0ef          	jal	ra,ffffffffc020080e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02009ee:	86a6                	mv	a3,s1
ffffffffc02009f0:	00004617          	auipc	a2,0x4
ffffffffc02009f4:	42860613          	addi	a2,a2,1064 # ffffffffc0204e18 <commands+0x2b0>
ffffffffc02009f8:	0bd00593          	li	a1,189
ffffffffc02009fc:	00004517          	auipc	a0,0x4
ffffffffc0200a00:	61c50513          	addi	a0,a0,1564 # ffffffffc0205018 <commands+0x4b0>
ffffffffc0200a04:	fd0ff0ef          	jal	ra,ffffffffc02001d4 <__panic>
            cprintf("Environment call from U-mode\n");
ffffffffc0200a08:	00004517          	auipc	a0,0x4
ffffffffc0200a0c:	46050513          	addi	a0,a0,1120 # ffffffffc0204e68 <commands+0x300>
ffffffffc0200a10:	b7b9                	j	ffffffffc020095e <exception_handler+0x50>
            cprintf("Environment call from S-mode\n");
ffffffffc0200a12:	00004517          	auipc	a0,0x4
ffffffffc0200a16:	47650513          	addi	a0,a0,1142 # ffffffffc0204e88 <commands+0x320>
ffffffffc0200a1a:	b791                	j	ffffffffc020095e <exception_handler+0x50>
            cprintf("Environment call from H-mode\n");
ffffffffc0200a1c:	00004517          	auipc	a0,0x4
ffffffffc0200a20:	48c50513          	addi	a0,a0,1164 # ffffffffc0204ea8 <commands+0x340>
ffffffffc0200a24:	bf2d                	j	ffffffffc020095e <exception_handler+0x50>
            cprintf("Environment call from M-mode\n");
ffffffffc0200a26:	00004517          	auipc	a0,0x4
ffffffffc0200a2a:	4a250513          	addi	a0,a0,1186 # ffffffffc0204ec8 <commands+0x360>
ffffffffc0200a2e:	bf05                	j	ffffffffc020095e <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200a30:	00004517          	auipc	a0,0x4
ffffffffc0200a34:	4b850513          	addi	a0,a0,1208 # ffffffffc0204ee8 <commands+0x380>
ffffffffc0200a38:	b71d                	j	ffffffffc020095e <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200a3a:	00004517          	auipc	a0,0x4
ffffffffc0200a3e:	4c650513          	addi	a0,a0,1222 # ffffffffc0204f00 <commands+0x398>
ffffffffc0200a42:	e8eff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200a46:	8522                	mv	a0,s0
ffffffffc0200a48:	b6dff0ef          	jal	ra,ffffffffc02005b4 <pgfault_handler>
ffffffffc0200a4c:	84aa                	mv	s1,a0
ffffffffc0200a4e:	ee050fe3          	beqz	a0,ffffffffc020094c <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc0200a52:	8522                	mv	a0,s0
ffffffffc0200a54:	dbbff0ef          	jal	ra,ffffffffc020080e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200a58:	86a6                	mv	a3,s1
ffffffffc0200a5a:	00004617          	auipc	a2,0x4
ffffffffc0200a5e:	3be60613          	addi	a2,a2,958 # ffffffffc0204e18 <commands+0x2b0>
ffffffffc0200a62:	0d300593          	li	a1,211
ffffffffc0200a66:	00004517          	auipc	a0,0x4
ffffffffc0200a6a:	5b250513          	addi	a0,a0,1458 # ffffffffc0205018 <commands+0x4b0>
ffffffffc0200a6e:	f66ff0ef          	jal	ra,ffffffffc02001d4 <__panic>
}
ffffffffc0200a72:	6442                	ld	s0,16(sp)
ffffffffc0200a74:	60e2                	ld	ra,24(sp)
ffffffffc0200a76:	64a2                	ld	s1,8(sp)
ffffffffc0200a78:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc0200a7a:	bb51                	j	ffffffffc020080e <print_trapframe>
ffffffffc0200a7c:	bb49                	j	ffffffffc020080e <print_trapframe>
                print_trapframe(tf);
ffffffffc0200a7e:	8522                	mv	a0,s0
ffffffffc0200a80:	d8fff0ef          	jal	ra,ffffffffc020080e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200a84:	86a6                	mv	a3,s1
ffffffffc0200a86:	00004617          	auipc	a2,0x4
ffffffffc0200a8a:	39260613          	addi	a2,a2,914 # ffffffffc0204e18 <commands+0x2b0>
ffffffffc0200a8e:	0da00593          	li	a1,218
ffffffffc0200a92:	00004517          	auipc	a0,0x4
ffffffffc0200a96:	58650513          	addi	a0,a0,1414 # ffffffffc0205018 <commands+0x4b0>
ffffffffc0200a9a:	f3aff0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc0200a9e <trap>:
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200a9e:	11853783          	ld	a5,280(a0)
ffffffffc0200aa2:	0007c363          	bltz	a5,ffffffffc0200aa8 <trap+0xa>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
ffffffffc0200aa6:	b5a5                	j	ffffffffc020090e <exception_handler>
        interrupt_handler(tf);
ffffffffc0200aa8:	b3e1                	j	ffffffffc0200870 <interrupt_handler>
	...

ffffffffc0200aac <__alltraps>:
    LOAD  x2,2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200aac:	14011073          	csrw	sscratch,sp
ffffffffc0200ab0:	712d                	addi	sp,sp,-288
ffffffffc0200ab2:	e406                	sd	ra,8(sp)
ffffffffc0200ab4:	ec0e                	sd	gp,24(sp)
ffffffffc0200ab6:	f012                	sd	tp,32(sp)
ffffffffc0200ab8:	f416                	sd	t0,40(sp)
ffffffffc0200aba:	f81a                	sd	t1,48(sp)
ffffffffc0200abc:	fc1e                	sd	t2,56(sp)
ffffffffc0200abe:	e0a2                	sd	s0,64(sp)
ffffffffc0200ac0:	e4a6                	sd	s1,72(sp)
ffffffffc0200ac2:	e8aa                	sd	a0,80(sp)
ffffffffc0200ac4:	ecae                	sd	a1,88(sp)
ffffffffc0200ac6:	f0b2                	sd	a2,96(sp)
ffffffffc0200ac8:	f4b6                	sd	a3,104(sp)
ffffffffc0200aca:	f8ba                	sd	a4,112(sp)
ffffffffc0200acc:	fcbe                	sd	a5,120(sp)
ffffffffc0200ace:	e142                	sd	a6,128(sp)
ffffffffc0200ad0:	e546                	sd	a7,136(sp)
ffffffffc0200ad2:	e94a                	sd	s2,144(sp)
ffffffffc0200ad4:	ed4e                	sd	s3,152(sp)
ffffffffc0200ad6:	f152                	sd	s4,160(sp)
ffffffffc0200ad8:	f556                	sd	s5,168(sp)
ffffffffc0200ada:	f95a                	sd	s6,176(sp)
ffffffffc0200adc:	fd5e                	sd	s7,184(sp)
ffffffffc0200ade:	e1e2                	sd	s8,192(sp)
ffffffffc0200ae0:	e5e6                	sd	s9,200(sp)
ffffffffc0200ae2:	e9ea                	sd	s10,208(sp)
ffffffffc0200ae4:	edee                	sd	s11,216(sp)
ffffffffc0200ae6:	f1f2                	sd	t3,224(sp)
ffffffffc0200ae8:	f5f6                	sd	t4,232(sp)
ffffffffc0200aea:	f9fa                	sd	t5,240(sp)
ffffffffc0200aec:	fdfe                	sd	t6,248(sp)
ffffffffc0200aee:	14002473          	csrr	s0,sscratch
ffffffffc0200af2:	100024f3          	csrr	s1,sstatus
ffffffffc0200af6:	14102973          	csrr	s2,sepc
ffffffffc0200afa:	143029f3          	csrr	s3,stval
ffffffffc0200afe:	14202a73          	csrr	s4,scause
ffffffffc0200b02:	e822                	sd	s0,16(sp)
ffffffffc0200b04:	e226                	sd	s1,256(sp)
ffffffffc0200b06:	e64a                	sd	s2,264(sp)
ffffffffc0200b08:	ea4e                	sd	s3,272(sp)
ffffffffc0200b0a:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200b0c:	850a                	mv	a0,sp
    jal trap
ffffffffc0200b0e:	f91ff0ef          	jal	ra,ffffffffc0200a9e <trap>

ffffffffc0200b12 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200b12:	6492                	ld	s1,256(sp)
ffffffffc0200b14:	6932                	ld	s2,264(sp)
ffffffffc0200b16:	10049073          	csrw	sstatus,s1
ffffffffc0200b1a:	14191073          	csrw	sepc,s2
ffffffffc0200b1e:	60a2                	ld	ra,8(sp)
ffffffffc0200b20:	61e2                	ld	gp,24(sp)
ffffffffc0200b22:	7202                	ld	tp,32(sp)
ffffffffc0200b24:	72a2                	ld	t0,40(sp)
ffffffffc0200b26:	7342                	ld	t1,48(sp)
ffffffffc0200b28:	73e2                	ld	t2,56(sp)
ffffffffc0200b2a:	6406                	ld	s0,64(sp)
ffffffffc0200b2c:	64a6                	ld	s1,72(sp)
ffffffffc0200b2e:	6546                	ld	a0,80(sp)
ffffffffc0200b30:	65e6                	ld	a1,88(sp)
ffffffffc0200b32:	7606                	ld	a2,96(sp)
ffffffffc0200b34:	76a6                	ld	a3,104(sp)
ffffffffc0200b36:	7746                	ld	a4,112(sp)
ffffffffc0200b38:	77e6                	ld	a5,120(sp)
ffffffffc0200b3a:	680a                	ld	a6,128(sp)
ffffffffc0200b3c:	68aa                	ld	a7,136(sp)
ffffffffc0200b3e:	694a                	ld	s2,144(sp)
ffffffffc0200b40:	69ea                	ld	s3,152(sp)
ffffffffc0200b42:	7a0a                	ld	s4,160(sp)
ffffffffc0200b44:	7aaa                	ld	s5,168(sp)
ffffffffc0200b46:	7b4a                	ld	s6,176(sp)
ffffffffc0200b48:	7bea                	ld	s7,184(sp)
ffffffffc0200b4a:	6c0e                	ld	s8,192(sp)
ffffffffc0200b4c:	6cae                	ld	s9,200(sp)
ffffffffc0200b4e:	6d4e                	ld	s10,208(sp)
ffffffffc0200b50:	6dee                	ld	s11,216(sp)
ffffffffc0200b52:	7e0e                	ld	t3,224(sp)
ffffffffc0200b54:	7eae                	ld	t4,232(sp)
ffffffffc0200b56:	7f4e                	ld	t5,240(sp)
ffffffffc0200b58:	7fee                	ld	t6,248(sp)
ffffffffc0200b5a:	6142                	ld	sp,16(sp)
    # go back from supervisor call
    sret
ffffffffc0200b5c:	10200073          	sret

ffffffffc0200b60 <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200b60:	812a                	mv	sp,a0
    j __trapret
ffffffffc0200b62:	bf45                	j	ffffffffc0200b12 <__trapret>
	...

ffffffffc0200b66 <pa2page.part.4>:
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
}

static inline struct Page *
pa2page(uintptr_t pa) {
ffffffffc0200b66:	1141                	addi	sp,sp,-16
    if (PPN(pa) >= npage) {
        panic("pa2page called with invalid pa");
ffffffffc0200b68:	00005617          	auipc	a2,0x5
ffffffffc0200b6c:	87860613          	addi	a2,a2,-1928 # ffffffffc02053e0 <commands+0x878>
ffffffffc0200b70:	06200593          	li	a1,98
ffffffffc0200b74:	00005517          	auipc	a0,0x5
ffffffffc0200b78:	88c50513          	addi	a0,a0,-1908 # ffffffffc0205400 <commands+0x898>
pa2page(uintptr_t pa) {
ffffffffc0200b7c:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0200b7e:	e56ff0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc0200b82 <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc0200b82:	715d                	addi	sp,sp,-80
ffffffffc0200b84:	e0a2                	sd	s0,64(sp)
ffffffffc0200b86:	fc26                	sd	s1,56(sp)
ffffffffc0200b88:	f84a                	sd	s2,48(sp)
ffffffffc0200b8a:	f44e                	sd	s3,40(sp)
ffffffffc0200b8c:	f052                	sd	s4,32(sp)
ffffffffc0200b8e:	ec56                	sd	s5,24(sp)
ffffffffc0200b90:	e486                	sd	ra,72(sp)
ffffffffc0200b92:	842a                	mv	s0,a0
ffffffffc0200b94:	00015497          	auipc	s1,0x15
ffffffffc0200b98:	93c48493          	addi	s1,s1,-1732 # ffffffffc02154d0 <pmm_manager>
        {
            page = pmm_manager->alloc_pages(n);
        }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0200b9c:	4985                	li	s3,1
ffffffffc0200b9e:	00015a17          	auipc	s4,0x15
ffffffffc0200ba2:	8faa0a13          	addi	s4,s4,-1798 # ffffffffc0215498 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0200ba6:	0005091b          	sext.w	s2,a0
ffffffffc0200baa:	00015a97          	auipc	s5,0x15
ffffffffc0200bae:	946a8a93          	addi	s5,s5,-1722 # ffffffffc02154f0 <check_mm_struct>
ffffffffc0200bb2:	a00d                	j	ffffffffc0200bd4 <alloc_pages+0x52>
            page = pmm_manager->alloc_pages(n);
ffffffffc0200bb4:	609c                	ld	a5,0(s1)
ffffffffc0200bb6:	6f9c                	ld	a5,24(a5)
ffffffffc0200bb8:	9782                	jalr	a5
        swap_out(check_mm_struct, n, 0);
ffffffffc0200bba:	4601                	li	a2,0
ffffffffc0200bbc:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0200bbe:	ed0d                	bnez	a0,ffffffffc0200bf8 <alloc_pages+0x76>
ffffffffc0200bc0:	0289ec63          	bltu	s3,s0,ffffffffc0200bf8 <alloc_pages+0x76>
ffffffffc0200bc4:	000a2783          	lw	a5,0(s4)
ffffffffc0200bc8:	2781                	sext.w	a5,a5
ffffffffc0200bca:	c79d                	beqz	a5,ffffffffc0200bf8 <alloc_pages+0x76>
        swap_out(check_mm_struct, n, 0);
ffffffffc0200bcc:	000ab503          	ld	a0,0(s5)
ffffffffc0200bd0:	6af010ef          	jal	ra,ffffffffc0202a7e <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200bd4:	100027f3          	csrr	a5,sstatus
ffffffffc0200bd8:	8b89                	andi	a5,a5,2
            page = pmm_manager->alloc_pages(n);
ffffffffc0200bda:	8522                	mv	a0,s0
ffffffffc0200bdc:	dfe1                	beqz	a5,ffffffffc0200bb4 <alloc_pages+0x32>
        intr_disable();
ffffffffc0200bde:	9d1ff0ef          	jal	ra,ffffffffc02005ae <intr_disable>
ffffffffc0200be2:	609c                	ld	a5,0(s1)
ffffffffc0200be4:	8522                	mv	a0,s0
ffffffffc0200be6:	6f9c                	ld	a5,24(a5)
ffffffffc0200be8:	9782                	jalr	a5
ffffffffc0200bea:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0200bec:	9bdff0ef          	jal	ra,ffffffffc02005a8 <intr_enable>
ffffffffc0200bf0:	6522                	ld	a0,8(sp)
        swap_out(check_mm_struct, n, 0);
ffffffffc0200bf2:	4601                	li	a2,0
ffffffffc0200bf4:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0200bf6:	d569                	beqz	a0,ffffffffc0200bc0 <alloc_pages+0x3e>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0200bf8:	60a6                	ld	ra,72(sp)
ffffffffc0200bfa:	6406                	ld	s0,64(sp)
ffffffffc0200bfc:	74e2                	ld	s1,56(sp)
ffffffffc0200bfe:	7942                	ld	s2,48(sp)
ffffffffc0200c00:	79a2                	ld	s3,40(sp)
ffffffffc0200c02:	7a02                	ld	s4,32(sp)
ffffffffc0200c04:	6ae2                	ld	s5,24(sp)
ffffffffc0200c06:	6161                	addi	sp,sp,80
ffffffffc0200c08:	8082                	ret

ffffffffc0200c0a <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200c0a:	100027f3          	csrr	a5,sstatus
ffffffffc0200c0e:	8b89                	andi	a5,a5,2
ffffffffc0200c10:	eb89                	bnez	a5,ffffffffc0200c22 <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0200c12:	00015797          	auipc	a5,0x15
ffffffffc0200c16:	8be78793          	addi	a5,a5,-1858 # ffffffffc02154d0 <pmm_manager>
ffffffffc0200c1a:	639c                	ld	a5,0(a5)
ffffffffc0200c1c:	0207b303          	ld	t1,32(a5)
ffffffffc0200c20:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc0200c22:	1101                	addi	sp,sp,-32
ffffffffc0200c24:	ec06                	sd	ra,24(sp)
ffffffffc0200c26:	e822                	sd	s0,16(sp)
ffffffffc0200c28:	e426                	sd	s1,8(sp)
ffffffffc0200c2a:	842a                	mv	s0,a0
ffffffffc0200c2c:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0200c2e:	981ff0ef          	jal	ra,ffffffffc02005ae <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0200c32:	00015797          	auipc	a5,0x15
ffffffffc0200c36:	89e78793          	addi	a5,a5,-1890 # ffffffffc02154d0 <pmm_manager>
ffffffffc0200c3a:	639c                	ld	a5,0(a5)
ffffffffc0200c3c:	85a6                	mv	a1,s1
ffffffffc0200c3e:	8522                	mv	a0,s0
ffffffffc0200c40:	739c                	ld	a5,32(a5)
ffffffffc0200c42:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200c44:	6442                	ld	s0,16(sp)
ffffffffc0200c46:	60e2                	ld	ra,24(sp)
ffffffffc0200c48:	64a2                	ld	s1,8(sp)
ffffffffc0200c4a:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200c4c:	95dff06f          	j	ffffffffc02005a8 <intr_enable>

ffffffffc0200c50 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200c50:	100027f3          	csrr	a5,sstatus
ffffffffc0200c54:	8b89                	andi	a5,a5,2
ffffffffc0200c56:	eb89                	bnez	a5,ffffffffc0200c68 <nr_free_pages+0x18>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0200c58:	00015797          	auipc	a5,0x15
ffffffffc0200c5c:	87878793          	addi	a5,a5,-1928 # ffffffffc02154d0 <pmm_manager>
ffffffffc0200c60:	639c                	ld	a5,0(a5)
ffffffffc0200c62:	0287b303          	ld	t1,40(a5)
ffffffffc0200c66:	8302                	jr	t1
size_t nr_free_pages(void) {
ffffffffc0200c68:	1141                	addi	sp,sp,-16
ffffffffc0200c6a:	e406                	sd	ra,8(sp)
ffffffffc0200c6c:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0200c6e:	941ff0ef          	jal	ra,ffffffffc02005ae <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0200c72:	00015797          	auipc	a5,0x15
ffffffffc0200c76:	85e78793          	addi	a5,a5,-1954 # ffffffffc02154d0 <pmm_manager>
ffffffffc0200c7a:	639c                	ld	a5,0(a5)
ffffffffc0200c7c:	779c                	ld	a5,40(a5)
ffffffffc0200c7e:	9782                	jalr	a5
ffffffffc0200c80:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0200c82:	927ff0ef          	jal	ra,ffffffffc02005a8 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0200c86:	8522                	mv	a0,s0
ffffffffc0200c88:	60a2                	ld	ra,8(sp)
ffffffffc0200c8a:	6402                	ld	s0,0(sp)
ffffffffc0200c8c:	0141                	addi	sp,sp,16
ffffffffc0200c8e:	8082                	ret

ffffffffc0200c90 <get_pte>:
// parameter:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0200c90:	7139                	addi	sp,sp,-64
ffffffffc0200c92:	f426                	sd	s1,40(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0200c94:	01e5d493          	srli	s1,a1,0x1e
ffffffffc0200c98:	1ff4f493          	andi	s1,s1,511
ffffffffc0200c9c:	048e                	slli	s1,s1,0x3
ffffffffc0200c9e:	94aa                	add	s1,s1,a0
    if (!(*pdep1 & PTE_V)) {
ffffffffc0200ca0:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0200ca2:	f04a                	sd	s2,32(sp)
ffffffffc0200ca4:	ec4e                	sd	s3,24(sp)
ffffffffc0200ca6:	e852                	sd	s4,16(sp)
ffffffffc0200ca8:	fc06                	sd	ra,56(sp)
ffffffffc0200caa:	f822                	sd	s0,48(sp)
ffffffffc0200cac:	e456                	sd	s5,8(sp)
ffffffffc0200cae:	e05a                	sd	s6,0(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc0200cb0:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0200cb4:	892e                	mv	s2,a1
ffffffffc0200cb6:	8a32                	mv	s4,a2
ffffffffc0200cb8:	00014997          	auipc	s3,0x14
ffffffffc0200cbc:	7c898993          	addi	s3,s3,1992 # ffffffffc0215480 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0200cc0:	e7bd                	bnez	a5,ffffffffc0200d2e <get_pte+0x9e>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0200cc2:	12060c63          	beqz	a2,ffffffffc0200dfa <get_pte+0x16a>
ffffffffc0200cc6:	4505                	li	a0,1
ffffffffc0200cc8:	ebbff0ef          	jal	ra,ffffffffc0200b82 <alloc_pages>
ffffffffc0200ccc:	842a                	mv	s0,a0
ffffffffc0200cce:	12050663          	beqz	a0,ffffffffc0200dfa <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0200cd2:	00015b17          	auipc	s6,0x15
ffffffffc0200cd6:	816b0b13          	addi	s6,s6,-2026 # ffffffffc02154e8 <pages>
ffffffffc0200cda:	000b3503          	ld	a0,0(s6)
ffffffffc0200cde:	00080ab7          	lui	s5,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0200ce2:	00014997          	auipc	s3,0x14
ffffffffc0200ce6:	79e98993          	addi	s3,s3,1950 # ffffffffc0215480 <npage>
ffffffffc0200cea:	40a40533          	sub	a0,s0,a0
ffffffffc0200cee:	8519                	srai	a0,a0,0x6
ffffffffc0200cf0:	9556                	add	a0,a0,s5
ffffffffc0200cf2:	0009b703          	ld	a4,0(s3)
ffffffffc0200cf6:	00c51793          	slli	a5,a0,0xc
    return page->ref;
}

static inline void
set_page_ref(struct Page *page, int val) {
    page->ref = val;
ffffffffc0200cfa:	4685                	li	a3,1
ffffffffc0200cfc:	c014                	sw	a3,0(s0)
ffffffffc0200cfe:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0200d00:	0532                	slli	a0,a0,0xc
ffffffffc0200d02:	14e7f363          	bgeu	a5,a4,ffffffffc0200e48 <get_pte+0x1b8>
ffffffffc0200d06:	00014797          	auipc	a5,0x14
ffffffffc0200d0a:	7d278793          	addi	a5,a5,2002 # ffffffffc02154d8 <va_pa_offset>
ffffffffc0200d0e:	639c                	ld	a5,0(a5)
ffffffffc0200d10:	6605                	lui	a2,0x1
ffffffffc0200d12:	4581                	li	a1,0
ffffffffc0200d14:	953e                	add	a0,a0,a5
ffffffffc0200d16:	0a3030ef          	jal	ra,ffffffffc02045b8 <memset>
    return page - pages + nbase;
ffffffffc0200d1a:	000b3683          	ld	a3,0(s6)
ffffffffc0200d1e:	40d406b3          	sub	a3,s0,a3
ffffffffc0200d22:	8699                	srai	a3,a3,0x6
ffffffffc0200d24:	96d6                	add	a3,a3,s5
  asm volatile("sfence.vma");
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0200d26:	06aa                	slli	a3,a3,0xa
ffffffffc0200d28:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0200d2c:	e094                	sd	a3,0(s1)
    }
    pde_t *pdep0 = &((pte_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0200d2e:	77fd                	lui	a5,0xfffff
ffffffffc0200d30:	068a                	slli	a3,a3,0x2
ffffffffc0200d32:	0009b703          	ld	a4,0(s3)
ffffffffc0200d36:	8efd                	and	a3,a3,a5
ffffffffc0200d38:	00c6d793          	srli	a5,a3,0xc
ffffffffc0200d3c:	0ce7f163          	bgeu	a5,a4,ffffffffc0200dfe <get_pte+0x16e>
ffffffffc0200d40:	00014a97          	auipc	s5,0x14
ffffffffc0200d44:	798a8a93          	addi	s5,s5,1944 # ffffffffc02154d8 <va_pa_offset>
ffffffffc0200d48:	000ab403          	ld	s0,0(s5)
ffffffffc0200d4c:	01595793          	srli	a5,s2,0x15
ffffffffc0200d50:	1ff7f793          	andi	a5,a5,511
ffffffffc0200d54:	96a2                	add	a3,a3,s0
ffffffffc0200d56:	00379413          	slli	s0,a5,0x3
ffffffffc0200d5a:	9436                	add	s0,s0,a3
    if (!(*pdep0 & PTE_V)) {
ffffffffc0200d5c:	6014                	ld	a3,0(s0)
ffffffffc0200d5e:	0016f793          	andi	a5,a3,1
ffffffffc0200d62:	e3ad                	bnez	a5,ffffffffc0200dc4 <get_pte+0x134>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0200d64:	080a0b63          	beqz	s4,ffffffffc0200dfa <get_pte+0x16a>
ffffffffc0200d68:	4505                	li	a0,1
ffffffffc0200d6a:	e19ff0ef          	jal	ra,ffffffffc0200b82 <alloc_pages>
ffffffffc0200d6e:	84aa                	mv	s1,a0
ffffffffc0200d70:	c549                	beqz	a0,ffffffffc0200dfa <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0200d72:	00014b17          	auipc	s6,0x14
ffffffffc0200d76:	776b0b13          	addi	s6,s6,1910 # ffffffffc02154e8 <pages>
ffffffffc0200d7a:	000b3503          	ld	a0,0(s6)
ffffffffc0200d7e:	00080a37          	lui	s4,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0200d82:	0009b703          	ld	a4,0(s3)
ffffffffc0200d86:	40a48533          	sub	a0,s1,a0
ffffffffc0200d8a:	8519                	srai	a0,a0,0x6
ffffffffc0200d8c:	9552                	add	a0,a0,s4
ffffffffc0200d8e:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc0200d92:	4685                	li	a3,1
ffffffffc0200d94:	c094                	sw	a3,0(s1)
ffffffffc0200d96:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0200d98:	0532                	slli	a0,a0,0xc
ffffffffc0200d9a:	08e7fa63          	bgeu	a5,a4,ffffffffc0200e2e <get_pte+0x19e>
ffffffffc0200d9e:	000ab783          	ld	a5,0(s5)
ffffffffc0200da2:	6605                	lui	a2,0x1
ffffffffc0200da4:	4581                	li	a1,0
ffffffffc0200da6:	953e                	add	a0,a0,a5
ffffffffc0200da8:	011030ef          	jal	ra,ffffffffc02045b8 <memset>
    return page - pages + nbase;
ffffffffc0200dac:	000b3683          	ld	a3,0(s6)
ffffffffc0200db0:	40d486b3          	sub	a3,s1,a3
ffffffffc0200db4:	8699                	srai	a3,a3,0x6
ffffffffc0200db6:	96d2                	add	a3,a3,s4
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0200db8:	06aa                	slli	a3,a3,0xa
ffffffffc0200dba:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0200dbe:	e014                	sd	a3,0(s0)
ffffffffc0200dc0:	0009b703          	ld	a4,0(s3)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0200dc4:	068a                	slli	a3,a3,0x2
ffffffffc0200dc6:	757d                	lui	a0,0xfffff
ffffffffc0200dc8:	8ee9                	and	a3,a3,a0
ffffffffc0200dca:	00c6d793          	srli	a5,a3,0xc
ffffffffc0200dce:	04e7f463          	bgeu	a5,a4,ffffffffc0200e16 <get_pte+0x186>
ffffffffc0200dd2:	000ab503          	ld	a0,0(s5)
ffffffffc0200dd6:	00c95913          	srli	s2,s2,0xc
ffffffffc0200dda:	1ff97913          	andi	s2,s2,511
ffffffffc0200dde:	96aa                	add	a3,a3,a0
ffffffffc0200de0:	00391513          	slli	a0,s2,0x3
ffffffffc0200de4:	9536                	add	a0,a0,a3
}
ffffffffc0200de6:	70e2                	ld	ra,56(sp)
ffffffffc0200de8:	7442                	ld	s0,48(sp)
ffffffffc0200dea:	74a2                	ld	s1,40(sp)
ffffffffc0200dec:	7902                	ld	s2,32(sp)
ffffffffc0200dee:	69e2                	ld	s3,24(sp)
ffffffffc0200df0:	6a42                	ld	s4,16(sp)
ffffffffc0200df2:	6aa2                	ld	s5,8(sp)
ffffffffc0200df4:	6b02                	ld	s6,0(sp)
ffffffffc0200df6:	6121                	addi	sp,sp,64
ffffffffc0200df8:	8082                	ret
            return NULL;
ffffffffc0200dfa:	4501                	li	a0,0
ffffffffc0200dfc:	b7ed                	j	ffffffffc0200de6 <get_pte+0x156>
    pde_t *pdep0 = &((pte_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0200dfe:	00004617          	auipc	a2,0x4
ffffffffc0200e02:	5aa60613          	addi	a2,a2,1450 # ffffffffc02053a8 <commands+0x840>
ffffffffc0200e06:	0e400593          	li	a1,228
ffffffffc0200e0a:	00004517          	auipc	a0,0x4
ffffffffc0200e0e:	5c650513          	addi	a0,a0,1478 # ffffffffc02053d0 <commands+0x868>
ffffffffc0200e12:	bc2ff0ef          	jal	ra,ffffffffc02001d4 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0200e16:	00004617          	auipc	a2,0x4
ffffffffc0200e1a:	59260613          	addi	a2,a2,1426 # ffffffffc02053a8 <commands+0x840>
ffffffffc0200e1e:	0ef00593          	li	a1,239
ffffffffc0200e22:	00004517          	auipc	a0,0x4
ffffffffc0200e26:	5ae50513          	addi	a0,a0,1454 # ffffffffc02053d0 <commands+0x868>
ffffffffc0200e2a:	baaff0ef          	jal	ra,ffffffffc02001d4 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0200e2e:	86aa                	mv	a3,a0
ffffffffc0200e30:	00004617          	auipc	a2,0x4
ffffffffc0200e34:	57860613          	addi	a2,a2,1400 # ffffffffc02053a8 <commands+0x840>
ffffffffc0200e38:	0ec00593          	li	a1,236
ffffffffc0200e3c:	00004517          	auipc	a0,0x4
ffffffffc0200e40:	59450513          	addi	a0,a0,1428 # ffffffffc02053d0 <commands+0x868>
ffffffffc0200e44:	b90ff0ef          	jal	ra,ffffffffc02001d4 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0200e48:	86aa                	mv	a3,a0
ffffffffc0200e4a:	00004617          	auipc	a2,0x4
ffffffffc0200e4e:	55e60613          	addi	a2,a2,1374 # ffffffffc02053a8 <commands+0x840>
ffffffffc0200e52:	0e100593          	li	a1,225
ffffffffc0200e56:	00004517          	auipc	a0,0x4
ffffffffc0200e5a:	57a50513          	addi	a0,a0,1402 # ffffffffc02053d0 <commands+0x868>
ffffffffc0200e5e:	b76ff0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc0200e62 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0200e62:	1141                	addi	sp,sp,-16
ffffffffc0200e64:	e022                	sd	s0,0(sp)
ffffffffc0200e66:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0200e68:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0200e6a:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0200e6c:	e25ff0ef          	jal	ra,ffffffffc0200c90 <get_pte>
    if (ptep_store != NULL) {
ffffffffc0200e70:	c011                	beqz	s0,ffffffffc0200e74 <get_page+0x12>
        *ptep_store = ptep;
ffffffffc0200e72:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0200e74:	c511                	beqz	a0,ffffffffc0200e80 <get_page+0x1e>
ffffffffc0200e76:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0200e78:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0200e7a:	0017f713          	andi	a4,a5,1
ffffffffc0200e7e:	e709                	bnez	a4,ffffffffc0200e88 <get_page+0x26>
}
ffffffffc0200e80:	60a2                	ld	ra,8(sp)
ffffffffc0200e82:	6402                	ld	s0,0(sp)
ffffffffc0200e84:	0141                	addi	sp,sp,16
ffffffffc0200e86:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0200e88:	00014717          	auipc	a4,0x14
ffffffffc0200e8c:	5f870713          	addi	a4,a4,1528 # ffffffffc0215480 <npage>
ffffffffc0200e90:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0200e92:	078a                	slli	a5,a5,0x2
ffffffffc0200e94:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0200e96:	02e7f063          	bgeu	a5,a4,ffffffffc0200eb6 <get_page+0x54>
    return &pages[PPN(pa) - nbase];
ffffffffc0200e9a:	00014717          	auipc	a4,0x14
ffffffffc0200e9e:	64e70713          	addi	a4,a4,1614 # ffffffffc02154e8 <pages>
ffffffffc0200ea2:	6308                	ld	a0,0(a4)
ffffffffc0200ea4:	60a2                	ld	ra,8(sp)
ffffffffc0200ea6:	6402                	ld	s0,0(sp)
ffffffffc0200ea8:	fff80737          	lui	a4,0xfff80
ffffffffc0200eac:	97ba                	add	a5,a5,a4
ffffffffc0200eae:	079a                	slli	a5,a5,0x6
ffffffffc0200eb0:	953e                	add	a0,a0,a5
ffffffffc0200eb2:	0141                	addi	sp,sp,16
ffffffffc0200eb4:	8082                	ret
ffffffffc0200eb6:	cb1ff0ef          	jal	ra,ffffffffc0200b66 <pa2page.part.4>

ffffffffc0200eba <page_remove>:
    }
}

// page_remove - free an Page which is related linear address la and has an
// validated pte
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0200eba:	1101                	addi	sp,sp,-32
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0200ebc:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0200ebe:	e426                	sd	s1,8(sp)
ffffffffc0200ec0:	ec06                	sd	ra,24(sp)
ffffffffc0200ec2:	e822                	sd	s0,16(sp)
ffffffffc0200ec4:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0200ec6:	dcbff0ef          	jal	ra,ffffffffc0200c90 <get_pte>
    if (ptep != NULL) {
ffffffffc0200eca:	c511                	beqz	a0,ffffffffc0200ed6 <page_remove+0x1c>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0200ecc:	611c                	ld	a5,0(a0)
ffffffffc0200ece:	842a                	mv	s0,a0
ffffffffc0200ed0:	0017f713          	andi	a4,a5,1
ffffffffc0200ed4:	e711                	bnez	a4,ffffffffc0200ee0 <page_remove+0x26>
        page_remove_pte(pgdir, la, ptep);
    }
}
ffffffffc0200ed6:	60e2                	ld	ra,24(sp)
ffffffffc0200ed8:	6442                	ld	s0,16(sp)
ffffffffc0200eda:	64a2                	ld	s1,8(sp)
ffffffffc0200edc:	6105                	addi	sp,sp,32
ffffffffc0200ede:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0200ee0:	00014717          	auipc	a4,0x14
ffffffffc0200ee4:	5a070713          	addi	a4,a4,1440 # ffffffffc0215480 <npage>
ffffffffc0200ee8:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0200eea:	078a                	slli	a5,a5,0x2
ffffffffc0200eec:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0200eee:	02e7fe63          	bgeu	a5,a4,ffffffffc0200f2a <page_remove+0x70>
    return &pages[PPN(pa) - nbase];
ffffffffc0200ef2:	00014717          	auipc	a4,0x14
ffffffffc0200ef6:	5f670713          	addi	a4,a4,1526 # ffffffffc02154e8 <pages>
ffffffffc0200efa:	6308                	ld	a0,0(a4)
ffffffffc0200efc:	fff80737          	lui	a4,0xfff80
ffffffffc0200f00:	97ba                	add	a5,a5,a4
ffffffffc0200f02:	079a                	slli	a5,a5,0x6
ffffffffc0200f04:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0200f06:	411c                	lw	a5,0(a0)
ffffffffc0200f08:	fff7871b          	addiw	a4,a5,-1
ffffffffc0200f0c:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0200f0e:	cb11                	beqz	a4,ffffffffc0200f22 <page_remove+0x68>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0200f10:	00043023          	sd	zero,0(s0)
// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la) {
    // flush_tlb();
    // The flush_tlb flush the entire TLB, is there any better way?
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0200f14:	12048073          	sfence.vma	s1
}
ffffffffc0200f18:	60e2                	ld	ra,24(sp)
ffffffffc0200f1a:	6442                	ld	s0,16(sp)
ffffffffc0200f1c:	64a2                	ld	s1,8(sp)
ffffffffc0200f1e:	6105                	addi	sp,sp,32
ffffffffc0200f20:	8082                	ret
            free_page(page);
ffffffffc0200f22:	4585                	li	a1,1
ffffffffc0200f24:	ce7ff0ef          	jal	ra,ffffffffc0200c0a <free_pages>
ffffffffc0200f28:	b7e5                	j	ffffffffc0200f10 <page_remove+0x56>
ffffffffc0200f2a:	c3dff0ef          	jal	ra,ffffffffc0200b66 <pa2page.part.4>

ffffffffc0200f2e <page_insert>:
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0200f2e:	7179                	addi	sp,sp,-48
ffffffffc0200f30:	e44e                	sd	s3,8(sp)
ffffffffc0200f32:	89b2                	mv	s3,a2
ffffffffc0200f34:	f022                	sd	s0,32(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0200f36:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0200f38:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0200f3a:	85ce                	mv	a1,s3
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0200f3c:	ec26                	sd	s1,24(sp)
ffffffffc0200f3e:	f406                	sd	ra,40(sp)
ffffffffc0200f40:	e84a                	sd	s2,16(sp)
ffffffffc0200f42:	e052                	sd	s4,0(sp)
ffffffffc0200f44:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0200f46:	d4bff0ef          	jal	ra,ffffffffc0200c90 <get_pte>
    if (ptep == NULL) {
ffffffffc0200f4a:	cd49                	beqz	a0,ffffffffc0200fe4 <page_insert+0xb6>
    page->ref += 1;
ffffffffc0200f4c:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V) {
ffffffffc0200f4e:	611c                	ld	a5,0(a0)
ffffffffc0200f50:	892a                	mv	s2,a0
ffffffffc0200f52:	0016871b          	addiw	a4,a3,1
ffffffffc0200f56:	c018                	sw	a4,0(s0)
ffffffffc0200f58:	0017f713          	andi	a4,a5,1
ffffffffc0200f5c:	ef05                	bnez	a4,ffffffffc0200f94 <page_insert+0x66>
ffffffffc0200f5e:	00014797          	auipc	a5,0x14
ffffffffc0200f62:	58a78793          	addi	a5,a5,1418 # ffffffffc02154e8 <pages>
ffffffffc0200f66:	6398                	ld	a4,0(a5)
    return page - pages + nbase;
ffffffffc0200f68:	8c19                	sub	s0,s0,a4
ffffffffc0200f6a:	000806b7          	lui	a3,0x80
ffffffffc0200f6e:	8419                	srai	s0,s0,0x6
ffffffffc0200f70:	9436                	add	s0,s0,a3
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0200f72:	042a                	slli	s0,s0,0xa
ffffffffc0200f74:	8c45                	or	s0,s0,s1
ffffffffc0200f76:	00146413          	ori	s0,s0,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0200f7a:	00893023          	sd	s0,0(s2)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0200f7e:	12098073          	sfence.vma	s3
    return 0;
ffffffffc0200f82:	4501                	li	a0,0
}
ffffffffc0200f84:	70a2                	ld	ra,40(sp)
ffffffffc0200f86:	7402                	ld	s0,32(sp)
ffffffffc0200f88:	64e2                	ld	s1,24(sp)
ffffffffc0200f8a:	6942                	ld	s2,16(sp)
ffffffffc0200f8c:	69a2                	ld	s3,8(sp)
ffffffffc0200f8e:	6a02                	ld	s4,0(sp)
ffffffffc0200f90:	6145                	addi	sp,sp,48
ffffffffc0200f92:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0200f94:	00014717          	auipc	a4,0x14
ffffffffc0200f98:	4ec70713          	addi	a4,a4,1260 # ffffffffc0215480 <npage>
ffffffffc0200f9c:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0200f9e:	078a                	slli	a5,a5,0x2
ffffffffc0200fa0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0200fa2:	04e7f363          	bgeu	a5,a4,ffffffffc0200fe8 <page_insert+0xba>
    return &pages[PPN(pa) - nbase];
ffffffffc0200fa6:	00014a17          	auipc	s4,0x14
ffffffffc0200faa:	542a0a13          	addi	s4,s4,1346 # ffffffffc02154e8 <pages>
ffffffffc0200fae:	000a3703          	ld	a4,0(s4)
ffffffffc0200fb2:	fff80537          	lui	a0,0xfff80
ffffffffc0200fb6:	953e                	add	a0,a0,a5
ffffffffc0200fb8:	051a                	slli	a0,a0,0x6
ffffffffc0200fba:	953a                	add	a0,a0,a4
        if (p == page) {
ffffffffc0200fbc:	00a40a63          	beq	s0,a0,ffffffffc0200fd0 <page_insert+0xa2>
    page->ref -= 1;
ffffffffc0200fc0:	411c                	lw	a5,0(a0)
ffffffffc0200fc2:	fff7869b          	addiw	a3,a5,-1
ffffffffc0200fc6:	c114                	sw	a3,0(a0)
        if (page_ref(page) ==
ffffffffc0200fc8:	c691                	beqz	a3,ffffffffc0200fd4 <page_insert+0xa6>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0200fca:	12098073          	sfence.vma	s3
ffffffffc0200fce:	bf69                	j	ffffffffc0200f68 <page_insert+0x3a>
ffffffffc0200fd0:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0200fd2:	bf59                	j	ffffffffc0200f68 <page_insert+0x3a>
            free_page(page);
ffffffffc0200fd4:	4585                	li	a1,1
ffffffffc0200fd6:	c35ff0ef          	jal	ra,ffffffffc0200c0a <free_pages>
ffffffffc0200fda:	000a3703          	ld	a4,0(s4)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0200fde:	12098073          	sfence.vma	s3
ffffffffc0200fe2:	b759                	j	ffffffffc0200f68 <page_insert+0x3a>
        return -E_NO_MEM;
ffffffffc0200fe4:	5571                	li	a0,-4
ffffffffc0200fe6:	bf79                	j	ffffffffc0200f84 <page_insert+0x56>
ffffffffc0200fe8:	b7fff0ef          	jal	ra,ffffffffc0200b66 <pa2page.part.4>

ffffffffc0200fec <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0200fec:	00005797          	auipc	a5,0x5
ffffffffc0200ff0:	61c78793          	addi	a5,a5,1564 # ffffffffc0206608 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200ff4:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0200ff6:	715d                	addi	sp,sp,-80
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200ff8:	00004517          	auipc	a0,0x4
ffffffffc0200ffc:	43050513          	addi	a0,a0,1072 # ffffffffc0205428 <commands+0x8c0>
void pmm_init(void) {
ffffffffc0201000:	e486                	sd	ra,72(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0201002:	00014717          	auipc	a4,0x14
ffffffffc0201006:	4cf73723          	sd	a5,1230(a4) # ffffffffc02154d0 <pmm_manager>
void pmm_init(void) {
ffffffffc020100a:	e0a2                	sd	s0,64(sp)
ffffffffc020100c:	fc26                	sd	s1,56(sp)
ffffffffc020100e:	f84a                	sd	s2,48(sp)
ffffffffc0201010:	f44e                	sd	s3,40(sp)
ffffffffc0201012:	f052                	sd	s4,32(sp)
ffffffffc0201014:	ec56                	sd	s5,24(sp)
ffffffffc0201016:	e85a                	sd	s6,16(sp)
ffffffffc0201018:	e45e                	sd	s7,8(sp)
ffffffffc020101a:	e062                	sd	s8,0(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc020101c:	00014417          	auipc	s0,0x14
ffffffffc0201020:	4b440413          	addi	s0,s0,1204 # ffffffffc02154d0 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201024:	8acff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    pmm_manager->init();
ffffffffc0201028:	601c                	ld	a5,0(s0)
ffffffffc020102a:	00014497          	auipc	s1,0x14
ffffffffc020102e:	45648493          	addi	s1,s1,1110 # ffffffffc0215480 <npage>
ffffffffc0201032:	00014917          	auipc	s2,0x14
ffffffffc0201036:	4b690913          	addi	s2,s2,1206 # ffffffffc02154e8 <pages>
ffffffffc020103a:	679c                	ld	a5,8(a5)
ffffffffc020103c:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc020103e:	57f5                	li	a5,-3
ffffffffc0201040:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0201042:	00004517          	auipc	a0,0x4
ffffffffc0201046:	3fe50513          	addi	a0,a0,1022 # ffffffffc0205440 <commands+0x8d8>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc020104a:	00014717          	auipc	a4,0x14
ffffffffc020104e:	48f73723          	sd	a5,1166(a4) # ffffffffc02154d8 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc0201052:	87eff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0201056:	46c5                	li	a3,17
ffffffffc0201058:	06ee                	slli	a3,a3,0x1b
ffffffffc020105a:	40100613          	li	a2,1025
ffffffffc020105e:	16fd                	addi	a3,a3,-1
ffffffffc0201060:	0656                	slli	a2,a2,0x15
ffffffffc0201062:	07e005b7          	lui	a1,0x7e00
ffffffffc0201066:	00004517          	auipc	a0,0x4
ffffffffc020106a:	3f250513          	addi	a0,a0,1010 # ffffffffc0205458 <commands+0x8f0>
ffffffffc020106e:	862ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201072:	777d                	lui	a4,0xfffff
ffffffffc0201074:	00015797          	auipc	a5,0x15
ffffffffc0201078:	58378793          	addi	a5,a5,1411 # ffffffffc02165f7 <end+0xfff>
ffffffffc020107c:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc020107e:	00088737          	lui	a4,0x88
ffffffffc0201082:	00014697          	auipc	a3,0x14
ffffffffc0201086:	3ee6bf23          	sd	a4,1022(a3) # ffffffffc0215480 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020108a:	00014717          	auipc	a4,0x14
ffffffffc020108e:	44f73f23          	sd	a5,1118(a4) # ffffffffc02154e8 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201092:	4701                	li	a4,0
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201094:	4685                	li	a3,1
ffffffffc0201096:	fff80837          	lui	a6,0xfff80
ffffffffc020109a:	a019                	j	ffffffffc02010a0 <pmm_init+0xb4>
ffffffffc020109c:	00093783          	ld	a5,0(s2)
        SetPageReserved(pages + i);
ffffffffc02010a0:	00671613          	slli	a2,a4,0x6
ffffffffc02010a4:	97b2                	add	a5,a5,a2
ffffffffc02010a6:	07a1                	addi	a5,a5,8
ffffffffc02010a8:	40d7b02f          	amoor.d	zero,a3,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02010ac:	6090                	ld	a2,0(s1)
ffffffffc02010ae:	0705                	addi	a4,a4,1
ffffffffc02010b0:	010607b3          	add	a5,a2,a6
ffffffffc02010b4:	fef764e3          	bltu	a4,a5,ffffffffc020109c <pmm_init+0xb0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02010b8:	00093503          	ld	a0,0(s2)
ffffffffc02010bc:	fe0007b7          	lui	a5,0xfe000
ffffffffc02010c0:	00661693          	slli	a3,a2,0x6
ffffffffc02010c4:	97aa                	add	a5,a5,a0
ffffffffc02010c6:	96be                	add	a3,a3,a5
ffffffffc02010c8:	c02007b7          	lui	a5,0xc0200
ffffffffc02010cc:	7af6eb63          	bltu	a3,a5,ffffffffc0201882 <pmm_init+0x896>
ffffffffc02010d0:	00014997          	auipc	s3,0x14
ffffffffc02010d4:	40898993          	addi	s3,s3,1032 # ffffffffc02154d8 <va_pa_offset>
ffffffffc02010d8:	0009b583          	ld	a1,0(s3)
    if (freemem < mem_end) {
ffffffffc02010dc:	47c5                	li	a5,17
ffffffffc02010de:	07ee                	slli	a5,a5,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02010e0:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end) {
ffffffffc02010e2:	02f6f763          	bgeu	a3,a5,ffffffffc0201110 <pmm_init+0x124>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02010e6:	6585                	lui	a1,0x1
ffffffffc02010e8:	15fd                	addi	a1,a1,-1
ffffffffc02010ea:	96ae                	add	a3,a3,a1
    if (PPN(pa) >= npage) {
ffffffffc02010ec:	00c6d713          	srli	a4,a3,0xc
ffffffffc02010f0:	48c77863          	bgeu	a4,a2,ffffffffc0201580 <pmm_init+0x594>
    pmm_manager->init_memmap(base, n);
ffffffffc02010f4:	6010                	ld	a2,0(s0)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02010f6:	75fd                	lui	a1,0xfffff
ffffffffc02010f8:	8eed                	and	a3,a3,a1
    return &pages[PPN(pa) - nbase];
ffffffffc02010fa:	9742                	add	a4,a4,a6
    pmm_manager->init_memmap(base, n);
ffffffffc02010fc:	6a10                	ld	a2,16(a2)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02010fe:	40d786b3          	sub	a3,a5,a3
ffffffffc0201102:	071a                	slli	a4,a4,0x6
    pmm_manager->init_memmap(base, n);
ffffffffc0201104:	00c6d593          	srli	a1,a3,0xc
ffffffffc0201108:	953a                	add	a0,a0,a4
ffffffffc020110a:	9602                	jalr	a2
ffffffffc020110c:	0009b583          	ld	a1,0(s3)
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc0201110:	00004517          	auipc	a0,0x4
ffffffffc0201114:	39850513          	addi	a0,a0,920 # ffffffffc02054a8 <commands+0x940>
ffffffffc0201118:	fb9fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc020111c:	601c                	ld	a5,0(s0)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc020111e:	00014417          	auipc	s0,0x14
ffffffffc0201122:	35a40413          	addi	s0,s0,858 # ffffffffc0215478 <boot_pgdir>
    pmm_manager->check();
ffffffffc0201126:	7b9c                	ld	a5,48(a5)
ffffffffc0201128:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc020112a:	00004517          	auipc	a0,0x4
ffffffffc020112e:	39650513          	addi	a0,a0,918 # ffffffffc02054c0 <commands+0x958>
ffffffffc0201132:	f9ffe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0201136:	00008697          	auipc	a3,0x8
ffffffffc020113a:	eca68693          	addi	a3,a3,-310 # ffffffffc0209000 <boot_page_table_sv39>
ffffffffc020113e:	00014797          	auipc	a5,0x14
ffffffffc0201142:	32d7bd23          	sd	a3,826(a5) # ffffffffc0215478 <boot_pgdir>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0201146:	c02007b7          	lui	a5,0xc0200
ffffffffc020114a:	10f6e8e3          	bltu	a3,a5,ffffffffc0201a5a <pmm_init+0xa6e>
ffffffffc020114e:	0009b783          	ld	a5,0(s3)
ffffffffc0201152:	8e9d                	sub	a3,a3,a5
ffffffffc0201154:	00014797          	auipc	a5,0x14
ffffffffc0201158:	38d7b623          	sd	a3,908(a5) # ffffffffc02154e0 <boot_cr3>
    // assert(npage <= KMEMSIZE / PGSIZE);
    // The memory starts at 2GB in RISC-V
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();
ffffffffc020115c:	af5ff0ef          	jal	ra,ffffffffc0200c50 <nr_free_pages>

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0201160:	6098                	ld	a4,0(s1)
ffffffffc0201162:	c80007b7          	lui	a5,0xc8000
ffffffffc0201166:	83b1                	srli	a5,a5,0xc
    nr_free_store=nr_free_pages();
ffffffffc0201168:	8a2a                	mv	s4,a0
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc020116a:	0ce7e8e3          	bltu	a5,a4,ffffffffc0201a3a <pmm_init+0xa4e>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc020116e:	6008                	ld	a0,0(s0)
ffffffffc0201170:	44050263          	beqz	a0,ffffffffc02015b4 <pmm_init+0x5c8>
ffffffffc0201174:	03451793          	slli	a5,a0,0x34
ffffffffc0201178:	42079e63          	bnez	a5,ffffffffc02015b4 <pmm_init+0x5c8>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc020117c:	4601                	li	a2,0
ffffffffc020117e:	4581                	li	a1,0
ffffffffc0201180:	ce3ff0ef          	jal	ra,ffffffffc0200e62 <get_page>
ffffffffc0201184:	78051b63          	bnez	a0,ffffffffc020191a <pmm_init+0x92e>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc0201188:	4505                	li	a0,1
ffffffffc020118a:	9f9ff0ef          	jal	ra,ffffffffc0200b82 <alloc_pages>
ffffffffc020118e:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0201190:	6008                	ld	a0,0(s0)
ffffffffc0201192:	4681                	li	a3,0
ffffffffc0201194:	4601                	li	a2,0
ffffffffc0201196:	85d6                	mv	a1,s5
ffffffffc0201198:	d97ff0ef          	jal	ra,ffffffffc0200f2e <page_insert>
ffffffffc020119c:	7a051f63          	bnez	a0,ffffffffc020195a <pmm_init+0x96e>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc02011a0:	6008                	ld	a0,0(s0)
ffffffffc02011a2:	4601                	li	a2,0
ffffffffc02011a4:	4581                	li	a1,0
ffffffffc02011a6:	aebff0ef          	jal	ra,ffffffffc0200c90 <get_pte>
ffffffffc02011aa:	78050863          	beqz	a0,ffffffffc020193a <pmm_init+0x94e>
    assert(pte2page(*ptep) == p1);
ffffffffc02011ae:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02011b0:	0017f713          	andi	a4,a5,1
ffffffffc02011b4:	3e070463          	beqz	a4,ffffffffc020159c <pmm_init+0x5b0>
    if (PPN(pa) >= npage) {
ffffffffc02011b8:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc02011ba:	078a                	slli	a5,a5,0x2
ffffffffc02011bc:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02011be:	3ce7f163          	bgeu	a5,a4,ffffffffc0201580 <pmm_init+0x594>
    return &pages[PPN(pa) - nbase];
ffffffffc02011c2:	00093683          	ld	a3,0(s2)
ffffffffc02011c6:	fff80637          	lui	a2,0xfff80
ffffffffc02011ca:	97b2                	add	a5,a5,a2
ffffffffc02011cc:	079a                	slli	a5,a5,0x6
ffffffffc02011ce:	97b6                	add	a5,a5,a3
ffffffffc02011d0:	72fa9563          	bne	s5,a5,ffffffffc02018fa <pmm_init+0x90e>
    assert(page_ref(p1) == 1);
ffffffffc02011d4:	000aab83          	lw	s7,0(s5)
ffffffffc02011d8:	4785                	li	a5,1
ffffffffc02011da:	70fb9063          	bne	s7,a5,ffffffffc02018da <pmm_init+0x8ee>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc02011de:	6008                	ld	a0,0(s0)
ffffffffc02011e0:	76fd                	lui	a3,0xfffff
ffffffffc02011e2:	611c                	ld	a5,0(a0)
ffffffffc02011e4:	078a                	slli	a5,a5,0x2
ffffffffc02011e6:	8ff5                	and	a5,a5,a3
ffffffffc02011e8:	00c7d613          	srli	a2,a5,0xc
ffffffffc02011ec:	66e67e63          	bgeu	a2,a4,ffffffffc0201868 <pmm_init+0x87c>
ffffffffc02011f0:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02011f4:	97e2                	add	a5,a5,s8
ffffffffc02011f6:	0007bb03          	ld	s6,0(a5) # ffffffffc8000000 <end+0x7deaa08>
ffffffffc02011fa:	0b0a                	slli	s6,s6,0x2
ffffffffc02011fc:	00db7b33          	and	s6,s6,a3
ffffffffc0201200:	00cb5793          	srli	a5,s6,0xc
ffffffffc0201204:	56e7f863          	bgeu	a5,a4,ffffffffc0201774 <pmm_init+0x788>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201208:	4601                	li	a2,0
ffffffffc020120a:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020120c:	9b62                	add	s6,s6,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc020120e:	a83ff0ef          	jal	ra,ffffffffc0200c90 <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201212:	0b21                	addi	s6,s6,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201214:	55651063          	bne	a0,s6,ffffffffc0201754 <pmm_init+0x768>

    p2 = alloc_page();
ffffffffc0201218:	4505                	li	a0,1
ffffffffc020121a:	969ff0ef          	jal	ra,ffffffffc0200b82 <alloc_pages>
ffffffffc020121e:	8b2a                	mv	s6,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0201220:	6008                	ld	a0,0(s0)
ffffffffc0201222:	46d1                	li	a3,20
ffffffffc0201224:	6605                	lui	a2,0x1
ffffffffc0201226:	85da                	mv	a1,s6
ffffffffc0201228:	d07ff0ef          	jal	ra,ffffffffc0200f2e <page_insert>
ffffffffc020122c:	50051463          	bnez	a0,ffffffffc0201734 <pmm_init+0x748>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201230:	6008                	ld	a0,0(s0)
ffffffffc0201232:	4601                	li	a2,0
ffffffffc0201234:	6585                	lui	a1,0x1
ffffffffc0201236:	a5bff0ef          	jal	ra,ffffffffc0200c90 <get_pte>
ffffffffc020123a:	4c050d63          	beqz	a0,ffffffffc0201714 <pmm_init+0x728>
    assert(*ptep & PTE_U);
ffffffffc020123e:	611c                	ld	a5,0(a0)
ffffffffc0201240:	0107f713          	andi	a4,a5,16
ffffffffc0201244:	4a070863          	beqz	a4,ffffffffc02016f4 <pmm_init+0x708>
    assert(*ptep & PTE_W);
ffffffffc0201248:	8b91                	andi	a5,a5,4
ffffffffc020124a:	48078563          	beqz	a5,ffffffffc02016d4 <pmm_init+0x6e8>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc020124e:	6008                	ld	a0,0(s0)
ffffffffc0201250:	611c                	ld	a5,0(a0)
ffffffffc0201252:	8bc1                	andi	a5,a5,16
ffffffffc0201254:	46078063          	beqz	a5,ffffffffc02016b4 <pmm_init+0x6c8>
    assert(page_ref(p2) == 1);
ffffffffc0201258:	000b2783          	lw	a5,0(s6)
ffffffffc020125c:	43779c63          	bne	a5,s7,ffffffffc0201694 <pmm_init+0x6a8>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0201260:	4681                	li	a3,0
ffffffffc0201262:	6605                	lui	a2,0x1
ffffffffc0201264:	85d6                	mv	a1,s5
ffffffffc0201266:	cc9ff0ef          	jal	ra,ffffffffc0200f2e <page_insert>
ffffffffc020126a:	40051563          	bnez	a0,ffffffffc0201674 <pmm_init+0x688>
    assert(page_ref(p1) == 2);
ffffffffc020126e:	000aa703          	lw	a4,0(s5)
ffffffffc0201272:	4789                	li	a5,2
ffffffffc0201274:	3ef71063          	bne	a4,a5,ffffffffc0201654 <pmm_init+0x668>
    assert(page_ref(p2) == 0);
ffffffffc0201278:	000b2783          	lw	a5,0(s6)
ffffffffc020127c:	3a079c63          	bnez	a5,ffffffffc0201634 <pmm_init+0x648>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201280:	6008                	ld	a0,0(s0)
ffffffffc0201282:	4601                	li	a2,0
ffffffffc0201284:	6585                	lui	a1,0x1
ffffffffc0201286:	a0bff0ef          	jal	ra,ffffffffc0200c90 <get_pte>
ffffffffc020128a:	38050563          	beqz	a0,ffffffffc0201614 <pmm_init+0x628>
    assert(pte2page(*ptep) == p1);
ffffffffc020128e:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201290:	00177793          	andi	a5,a4,1
ffffffffc0201294:	30078463          	beqz	a5,ffffffffc020159c <pmm_init+0x5b0>
    if (PPN(pa) >= npage) {
ffffffffc0201298:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc020129a:	00271793          	slli	a5,a4,0x2
ffffffffc020129e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02012a0:	2ed7f063          	bgeu	a5,a3,ffffffffc0201580 <pmm_init+0x594>
    return &pages[PPN(pa) - nbase];
ffffffffc02012a4:	00093683          	ld	a3,0(s2)
ffffffffc02012a8:	fff80637          	lui	a2,0xfff80
ffffffffc02012ac:	97b2                	add	a5,a5,a2
ffffffffc02012ae:	079a                	slli	a5,a5,0x6
ffffffffc02012b0:	97b6                	add	a5,a5,a3
ffffffffc02012b2:	32fa9163          	bne	s5,a5,ffffffffc02015d4 <pmm_init+0x5e8>
    assert((*ptep & PTE_U) == 0);
ffffffffc02012b6:	8b41                	andi	a4,a4,16
ffffffffc02012b8:	70071163          	bnez	a4,ffffffffc02019ba <pmm_init+0x9ce>

    page_remove(boot_pgdir, 0x0);
ffffffffc02012bc:	6008                	ld	a0,0(s0)
ffffffffc02012be:	4581                	li	a1,0
ffffffffc02012c0:	bfbff0ef          	jal	ra,ffffffffc0200eba <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc02012c4:	000aa703          	lw	a4,0(s5)
ffffffffc02012c8:	4785                	li	a5,1
ffffffffc02012ca:	6cf71863          	bne	a4,a5,ffffffffc020199a <pmm_init+0x9ae>
    assert(page_ref(p2) == 0);
ffffffffc02012ce:	000b2783          	lw	a5,0(s6)
ffffffffc02012d2:	6a079463          	bnez	a5,ffffffffc020197a <pmm_init+0x98e>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc02012d6:	6008                	ld	a0,0(s0)
ffffffffc02012d8:	6585                	lui	a1,0x1
ffffffffc02012da:	be1ff0ef          	jal	ra,ffffffffc0200eba <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc02012de:	000aa783          	lw	a5,0(s5)
ffffffffc02012e2:	50079363          	bnez	a5,ffffffffc02017e8 <pmm_init+0x7fc>
    assert(page_ref(p2) == 0);
ffffffffc02012e6:	000b2783          	lw	a5,0(s6)
ffffffffc02012ea:	4c079f63          	bnez	a5,ffffffffc02017c8 <pmm_init+0x7dc>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc02012ee:	00043b03          	ld	s6,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc02012f2:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02012f4:	000b3783          	ld	a5,0(s6)
ffffffffc02012f8:	078a                	slli	a5,a5,0x2
ffffffffc02012fa:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02012fc:	28e7f263          	bgeu	a5,a4,ffffffffc0201580 <pmm_init+0x594>
    return &pages[PPN(pa) - nbase];
ffffffffc0201300:	fff806b7          	lui	a3,0xfff80
ffffffffc0201304:	00093503          	ld	a0,0(s2)
ffffffffc0201308:	97b6                	add	a5,a5,a3
ffffffffc020130a:	079a                	slli	a5,a5,0x6
ffffffffc020130c:	00f506b3          	add	a3,a0,a5
ffffffffc0201310:	4290                	lw	a2,0(a3)
ffffffffc0201312:	4685                	li	a3,1
ffffffffc0201314:	48d61a63          	bne	a2,a3,ffffffffc02017a8 <pmm_init+0x7bc>
    return page - pages + nbase;
ffffffffc0201318:	8799                	srai	a5,a5,0x6
ffffffffc020131a:	00080ab7          	lui	s5,0x80
ffffffffc020131e:	97d6                	add	a5,a5,s5
    return KADDR(page2pa(page));
ffffffffc0201320:	00c79693          	slli	a3,a5,0xc
ffffffffc0201324:	82b1                	srli	a3,a3,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201326:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0201328:	46e6f363          	bgeu	a3,a4,ffffffffc020178e <pmm_init+0x7a2>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc020132c:	0009b683          	ld	a3,0(s3)
ffffffffc0201330:	97b6                	add	a5,a5,a3
    return pa2page(PDE_ADDR(pde));
ffffffffc0201332:	639c                	ld	a5,0(a5)
ffffffffc0201334:	078a                	slli	a5,a5,0x2
ffffffffc0201336:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201338:	24e7f463          	bgeu	a5,a4,ffffffffc0201580 <pmm_init+0x594>
    return &pages[PPN(pa) - nbase];
ffffffffc020133c:	415787b3          	sub	a5,a5,s5
ffffffffc0201340:	079a                	slli	a5,a5,0x6
ffffffffc0201342:	953e                	add	a0,a0,a5
ffffffffc0201344:	4585                	li	a1,1
ffffffffc0201346:	8c5ff0ef          	jal	ra,ffffffffc0200c0a <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc020134a:	000b3783          	ld	a5,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc020134e:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201350:	078a                	slli	a5,a5,0x2
ffffffffc0201352:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201354:	22e7f663          	bgeu	a5,a4,ffffffffc0201580 <pmm_init+0x594>
    return &pages[PPN(pa) - nbase];
ffffffffc0201358:	00093503          	ld	a0,0(s2)
ffffffffc020135c:	415787b3          	sub	a5,a5,s5
ffffffffc0201360:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0201362:	953e                	add	a0,a0,a5
ffffffffc0201364:	4585                	li	a1,1
ffffffffc0201366:	8a5ff0ef          	jal	ra,ffffffffc0200c0a <free_pages>
    boot_pgdir[0] = 0;
ffffffffc020136a:	601c                	ld	a5,0(s0)
ffffffffc020136c:	0007b023          	sd	zero,0(a5)
  asm volatile("sfence.vma");
ffffffffc0201370:	12000073          	sfence.vma
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0201374:	8ddff0ef          	jal	ra,ffffffffc0200c50 <nr_free_pages>
ffffffffc0201378:	68aa1163          	bne	s4,a0,ffffffffc02019fa <pmm_init+0xa0e>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc020137c:	00004517          	auipc	a0,0x4
ffffffffc0201380:	46c50513          	addi	a0,a0,1132 # ffffffffc02057e8 <commands+0xc80>
ffffffffc0201384:	d4dfe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
static void check_boot_pgdir(void) {
    size_t nr_free_store;
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();
ffffffffc0201388:	8c9ff0ef          	jal	ra,ffffffffc0200c50 <nr_free_pages>

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc020138c:	6098                	ld	a4,0(s1)
ffffffffc020138e:	c02007b7          	lui	a5,0xc0200
    nr_free_store=nr_free_pages();
ffffffffc0201392:	8a2a                	mv	s4,a0
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201394:	00c71693          	slli	a3,a4,0xc
ffffffffc0201398:	18d7f563          	bgeu	a5,a3,ffffffffc0201522 <pmm_init+0x536>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc020139c:	83b1                	srli	a5,a5,0xc
ffffffffc020139e:	6008                	ld	a0,0(s0)
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02013a0:	c0200ab7          	lui	s5,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02013a4:	1ae7f163          	bgeu	a5,a4,ffffffffc0201546 <pmm_init+0x55a>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02013a8:	7bfd                	lui	s7,0xfffff
ffffffffc02013aa:	6b05                	lui	s6,0x1
ffffffffc02013ac:	a029                	j	ffffffffc02013b6 <pmm_init+0x3ca>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02013ae:	00cad713          	srli	a4,s5,0xc
ffffffffc02013b2:	18f77a63          	bgeu	a4,a5,ffffffffc0201546 <pmm_init+0x55a>
ffffffffc02013b6:	0009b583          	ld	a1,0(s3)
ffffffffc02013ba:	4601                	li	a2,0
ffffffffc02013bc:	95d6                	add	a1,a1,s5
ffffffffc02013be:	8d3ff0ef          	jal	ra,ffffffffc0200c90 <get_pte>
ffffffffc02013c2:	16050263          	beqz	a0,ffffffffc0201526 <pmm_init+0x53a>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02013c6:	611c                	ld	a5,0(a0)
ffffffffc02013c8:	078a                	slli	a5,a5,0x2
ffffffffc02013ca:	0177f7b3          	and	a5,a5,s7
ffffffffc02013ce:	19579963          	bne	a5,s5,ffffffffc0201560 <pmm_init+0x574>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02013d2:	609c                	ld	a5,0(s1)
ffffffffc02013d4:	9ada                	add	s5,s5,s6
ffffffffc02013d6:	6008                	ld	a0,0(s0)
ffffffffc02013d8:	00c79713          	slli	a4,a5,0xc
ffffffffc02013dc:	fceae9e3          	bltu	s5,a4,ffffffffc02013ae <pmm_init+0x3c2>
    }

    assert(boot_pgdir[0] == 0);
ffffffffc02013e0:	611c                	ld	a5,0(a0)
ffffffffc02013e2:	62079c63          	bnez	a5,ffffffffc0201a1a <pmm_init+0xa2e>

    struct Page *p;
    p = alloc_page();
ffffffffc02013e6:	4505                	li	a0,1
ffffffffc02013e8:	f9aff0ef          	jal	ra,ffffffffc0200b82 <alloc_pages>
ffffffffc02013ec:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc02013ee:	6008                	ld	a0,0(s0)
ffffffffc02013f0:	4699                	li	a3,6
ffffffffc02013f2:	10000613          	li	a2,256
ffffffffc02013f6:	85d6                	mv	a1,s5
ffffffffc02013f8:	b37ff0ef          	jal	ra,ffffffffc0200f2e <page_insert>
ffffffffc02013fc:	1e051c63          	bnez	a0,ffffffffc02015f4 <pmm_init+0x608>
    assert(page_ref(p) == 1);
ffffffffc0201400:	000aa703          	lw	a4,0(s5) # ffffffffc0200000 <kern_entry>
ffffffffc0201404:	4785                	li	a5,1
ffffffffc0201406:	44f71163          	bne	a4,a5,ffffffffc0201848 <pmm_init+0x85c>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc020140a:	6008                	ld	a0,0(s0)
ffffffffc020140c:	6b05                	lui	s6,0x1
ffffffffc020140e:	4699                	li	a3,6
ffffffffc0201410:	100b0613          	addi	a2,s6,256 # 1100 <BASE_ADDRESS-0xffffffffc01fef00>
ffffffffc0201414:	85d6                	mv	a1,s5
ffffffffc0201416:	b19ff0ef          	jal	ra,ffffffffc0200f2e <page_insert>
ffffffffc020141a:	40051763          	bnez	a0,ffffffffc0201828 <pmm_init+0x83c>
    assert(page_ref(p) == 2);
ffffffffc020141e:	000aa703          	lw	a4,0(s5)
ffffffffc0201422:	4789                	li	a5,2
ffffffffc0201424:	3ef71263          	bne	a4,a5,ffffffffc0201808 <pmm_init+0x81c>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0201428:	00004597          	auipc	a1,0x4
ffffffffc020142c:	4f858593          	addi	a1,a1,1272 # ffffffffc0205920 <commands+0xdb8>
ffffffffc0201430:	10000513          	li	a0,256
ffffffffc0201434:	12a030ef          	jal	ra,ffffffffc020455e <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0201438:	100b0593          	addi	a1,s6,256
ffffffffc020143c:	10000513          	li	a0,256
ffffffffc0201440:	130030ef          	jal	ra,ffffffffc0204570 <strcmp>
ffffffffc0201444:	44051b63          	bnez	a0,ffffffffc020189a <pmm_init+0x8ae>
    return page - pages + nbase;
ffffffffc0201448:	00093683          	ld	a3,0(s2)
ffffffffc020144c:	00080737          	lui	a4,0x80
    return KADDR(page2pa(page));
ffffffffc0201450:	5b7d                	li	s6,-1
    return page - pages + nbase;
ffffffffc0201452:	40da86b3          	sub	a3,s5,a3
ffffffffc0201456:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0201458:	609c                	ld	a5,0(s1)
    return page - pages + nbase;
ffffffffc020145a:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc020145c:	00cb5b13          	srli	s6,s6,0xc
ffffffffc0201460:	0166f733          	and	a4,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc0201464:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0201466:	10f77f63          	bgeu	a4,a5,ffffffffc0201584 <pmm_init+0x598>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc020146a:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc020146e:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0201472:	96be                	add	a3,a3,a5
ffffffffc0201474:	10068023          	sb	zero,256(a3) # fffffffffff80100 <end+0x3fd6ab08>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0201478:	0a2030ef          	jal	ra,ffffffffc020451a <strlen>
ffffffffc020147c:	54051f63          	bnez	a0,ffffffffc02019da <pmm_init+0x9ee>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0201480:	00043b83          	ld	s7,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0201484:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201486:	000bb683          	ld	a3,0(s7) # fffffffffffff000 <end+0x3fde9a08>
ffffffffc020148a:	068a                	slli	a3,a3,0x2
ffffffffc020148c:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc020148e:	0ef6f963          	bgeu	a3,a5,ffffffffc0201580 <pmm_init+0x594>
    return KADDR(page2pa(page));
ffffffffc0201492:	0166fb33          	and	s6,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc0201496:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0201498:	0efb7663          	bgeu	s6,a5,ffffffffc0201584 <pmm_init+0x598>
ffffffffc020149c:	0009b983          	ld	s3,0(s3)
    free_page(p);
ffffffffc02014a0:	4585                	li	a1,1
ffffffffc02014a2:	8556                	mv	a0,s5
ffffffffc02014a4:	99b6                	add	s3,s3,a3
ffffffffc02014a6:	f64ff0ef          	jal	ra,ffffffffc0200c0a <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc02014aa:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc02014ae:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02014b0:	078a                	slli	a5,a5,0x2
ffffffffc02014b2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02014b4:	0ce7f663          	bgeu	a5,a4,ffffffffc0201580 <pmm_init+0x594>
    return &pages[PPN(pa) - nbase];
ffffffffc02014b8:	00093503          	ld	a0,0(s2)
ffffffffc02014bc:	fff809b7          	lui	s3,0xfff80
ffffffffc02014c0:	97ce                	add	a5,a5,s3
ffffffffc02014c2:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc02014c4:	953e                	add	a0,a0,a5
ffffffffc02014c6:	4585                	li	a1,1
ffffffffc02014c8:	f42ff0ef          	jal	ra,ffffffffc0200c0a <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc02014cc:	000bb783          	ld	a5,0(s7)
    if (PPN(pa) >= npage) {
ffffffffc02014d0:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02014d2:	078a                	slli	a5,a5,0x2
ffffffffc02014d4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02014d6:	0ae7f563          	bgeu	a5,a4,ffffffffc0201580 <pmm_init+0x594>
    return &pages[PPN(pa) - nbase];
ffffffffc02014da:	00093503          	ld	a0,0(s2)
ffffffffc02014de:	97ce                	add	a5,a5,s3
ffffffffc02014e0:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc02014e2:	953e                	add	a0,a0,a5
ffffffffc02014e4:	4585                	li	a1,1
ffffffffc02014e6:	f24ff0ef          	jal	ra,ffffffffc0200c0a <free_pages>
    boot_pgdir[0] = 0;
ffffffffc02014ea:	601c                	ld	a5,0(s0)
ffffffffc02014ec:	0007b023          	sd	zero,0(a5) # ffffffffc0200000 <kern_entry>
  asm volatile("sfence.vma");
ffffffffc02014f0:	12000073          	sfence.vma
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc02014f4:	f5cff0ef          	jal	ra,ffffffffc0200c50 <nr_free_pages>
ffffffffc02014f8:	3caa1163          	bne	s4,a0,ffffffffc02018ba <pmm_init+0x8ce>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc02014fc:	00004517          	auipc	a0,0x4
ffffffffc0201500:	49c50513          	addi	a0,a0,1180 # ffffffffc0205998 <commands+0xe30>
ffffffffc0201504:	bcdfe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
}
ffffffffc0201508:	6406                	ld	s0,64(sp)
ffffffffc020150a:	60a6                	ld	ra,72(sp)
ffffffffc020150c:	74e2                	ld	s1,56(sp)
ffffffffc020150e:	7942                	ld	s2,48(sp)
ffffffffc0201510:	79a2                	ld	s3,40(sp)
ffffffffc0201512:	7a02                	ld	s4,32(sp)
ffffffffc0201514:	6ae2                	ld	s5,24(sp)
ffffffffc0201516:	6b42                	ld	s6,16(sp)
ffffffffc0201518:	6ba2                	ld	s7,8(sp)
ffffffffc020151a:	6c02                	ld	s8,0(sp)
ffffffffc020151c:	6161                	addi	sp,sp,80
    kmalloc_init();
ffffffffc020151e:	0f10106f          	j	ffffffffc0202e0e <kmalloc_init>
ffffffffc0201522:	6008                	ld	a0,0(s0)
ffffffffc0201524:	bd75                	j	ffffffffc02013e0 <pmm_init+0x3f4>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201526:	00004697          	auipc	a3,0x4
ffffffffc020152a:	2e268693          	addi	a3,a3,738 # ffffffffc0205808 <commands+0xca0>
ffffffffc020152e:	00004617          	auipc	a2,0x4
ffffffffc0201532:	fd260613          	addi	a2,a2,-46 # ffffffffc0205500 <commands+0x998>
ffffffffc0201536:	19d00593          	li	a1,413
ffffffffc020153a:	00004517          	auipc	a0,0x4
ffffffffc020153e:	e9650513          	addi	a0,a0,-362 # ffffffffc02053d0 <commands+0x868>
ffffffffc0201542:	c93fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
ffffffffc0201546:	86d6                	mv	a3,s5
ffffffffc0201548:	00004617          	auipc	a2,0x4
ffffffffc020154c:	e6060613          	addi	a2,a2,-416 # ffffffffc02053a8 <commands+0x840>
ffffffffc0201550:	19d00593          	li	a1,413
ffffffffc0201554:	00004517          	auipc	a0,0x4
ffffffffc0201558:	e7c50513          	addi	a0,a0,-388 # ffffffffc02053d0 <commands+0x868>
ffffffffc020155c:	c79fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201560:	00004697          	auipc	a3,0x4
ffffffffc0201564:	2e868693          	addi	a3,a3,744 # ffffffffc0205848 <commands+0xce0>
ffffffffc0201568:	00004617          	auipc	a2,0x4
ffffffffc020156c:	f9860613          	addi	a2,a2,-104 # ffffffffc0205500 <commands+0x998>
ffffffffc0201570:	19e00593          	li	a1,414
ffffffffc0201574:	00004517          	auipc	a0,0x4
ffffffffc0201578:	e5c50513          	addi	a0,a0,-420 # ffffffffc02053d0 <commands+0x868>
ffffffffc020157c:	c59fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
ffffffffc0201580:	de6ff0ef          	jal	ra,ffffffffc0200b66 <pa2page.part.4>
    return KADDR(page2pa(page));
ffffffffc0201584:	00004617          	auipc	a2,0x4
ffffffffc0201588:	e2460613          	addi	a2,a2,-476 # ffffffffc02053a8 <commands+0x840>
ffffffffc020158c:	06900593          	li	a1,105
ffffffffc0201590:	00004517          	auipc	a0,0x4
ffffffffc0201594:	e7050513          	addi	a0,a0,-400 # ffffffffc0205400 <commands+0x898>
ffffffffc0201598:	c3dfe0ef          	jal	ra,ffffffffc02001d4 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc020159c:	00004617          	auipc	a2,0x4
ffffffffc02015a0:	03c60613          	addi	a2,a2,60 # ffffffffc02055d8 <commands+0xa70>
ffffffffc02015a4:	07400593          	li	a1,116
ffffffffc02015a8:	00004517          	auipc	a0,0x4
ffffffffc02015ac:	e5850513          	addi	a0,a0,-424 # ffffffffc0205400 <commands+0x898>
ffffffffc02015b0:	c25fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc02015b4:	00004697          	auipc	a3,0x4
ffffffffc02015b8:	f6468693          	addi	a3,a3,-156 # ffffffffc0205518 <commands+0x9b0>
ffffffffc02015bc:	00004617          	auipc	a2,0x4
ffffffffc02015c0:	f4460613          	addi	a2,a2,-188 # ffffffffc0205500 <commands+0x998>
ffffffffc02015c4:	16100593          	li	a1,353
ffffffffc02015c8:	00004517          	auipc	a0,0x4
ffffffffc02015cc:	e0850513          	addi	a0,a0,-504 # ffffffffc02053d0 <commands+0x868>
ffffffffc02015d0:	c05fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc02015d4:	00004697          	auipc	a3,0x4
ffffffffc02015d8:	02c68693          	addi	a3,a3,44 # ffffffffc0205600 <commands+0xa98>
ffffffffc02015dc:	00004617          	auipc	a2,0x4
ffffffffc02015e0:	f2460613          	addi	a2,a2,-220 # ffffffffc0205500 <commands+0x998>
ffffffffc02015e4:	17d00593          	li	a1,381
ffffffffc02015e8:	00004517          	auipc	a0,0x4
ffffffffc02015ec:	de850513          	addi	a0,a0,-536 # ffffffffc02053d0 <commands+0x868>
ffffffffc02015f0:	be5fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc02015f4:	00004697          	auipc	a3,0x4
ffffffffc02015f8:	28468693          	addi	a3,a3,644 # ffffffffc0205878 <commands+0xd10>
ffffffffc02015fc:	00004617          	auipc	a2,0x4
ffffffffc0201600:	f0460613          	addi	a2,a2,-252 # ffffffffc0205500 <commands+0x998>
ffffffffc0201604:	1a500593          	li	a1,421
ffffffffc0201608:	00004517          	auipc	a0,0x4
ffffffffc020160c:	dc850513          	addi	a0,a0,-568 # ffffffffc02053d0 <commands+0x868>
ffffffffc0201610:	bc5fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201614:	00004697          	auipc	a3,0x4
ffffffffc0201618:	07c68693          	addi	a3,a3,124 # ffffffffc0205690 <commands+0xb28>
ffffffffc020161c:	00004617          	auipc	a2,0x4
ffffffffc0201620:	ee460613          	addi	a2,a2,-284 # ffffffffc0205500 <commands+0x998>
ffffffffc0201624:	17c00593          	li	a1,380
ffffffffc0201628:	00004517          	auipc	a0,0x4
ffffffffc020162c:	da850513          	addi	a0,a0,-600 # ffffffffc02053d0 <commands+0x868>
ffffffffc0201630:	ba5fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0201634:	00004697          	auipc	a3,0x4
ffffffffc0201638:	12468693          	addi	a3,a3,292 # ffffffffc0205758 <commands+0xbf0>
ffffffffc020163c:	00004617          	auipc	a2,0x4
ffffffffc0201640:	ec460613          	addi	a2,a2,-316 # ffffffffc0205500 <commands+0x998>
ffffffffc0201644:	17b00593          	li	a1,379
ffffffffc0201648:	00004517          	auipc	a0,0x4
ffffffffc020164c:	d8850513          	addi	a0,a0,-632 # ffffffffc02053d0 <commands+0x868>
ffffffffc0201650:	b85fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0201654:	00004697          	auipc	a3,0x4
ffffffffc0201658:	0ec68693          	addi	a3,a3,236 # ffffffffc0205740 <commands+0xbd8>
ffffffffc020165c:	00004617          	auipc	a2,0x4
ffffffffc0201660:	ea460613          	addi	a2,a2,-348 # ffffffffc0205500 <commands+0x998>
ffffffffc0201664:	17a00593          	li	a1,378
ffffffffc0201668:	00004517          	auipc	a0,0x4
ffffffffc020166c:	d6850513          	addi	a0,a0,-664 # ffffffffc02053d0 <commands+0x868>
ffffffffc0201670:	b65fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0201674:	00004697          	auipc	a3,0x4
ffffffffc0201678:	09c68693          	addi	a3,a3,156 # ffffffffc0205710 <commands+0xba8>
ffffffffc020167c:	00004617          	auipc	a2,0x4
ffffffffc0201680:	e8460613          	addi	a2,a2,-380 # ffffffffc0205500 <commands+0x998>
ffffffffc0201684:	17900593          	li	a1,377
ffffffffc0201688:	00004517          	auipc	a0,0x4
ffffffffc020168c:	d4850513          	addi	a0,a0,-696 # ffffffffc02053d0 <commands+0x868>
ffffffffc0201690:	b45fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0201694:	00004697          	auipc	a3,0x4
ffffffffc0201698:	06468693          	addi	a3,a3,100 # ffffffffc02056f8 <commands+0xb90>
ffffffffc020169c:	00004617          	auipc	a2,0x4
ffffffffc02016a0:	e6460613          	addi	a2,a2,-412 # ffffffffc0205500 <commands+0x998>
ffffffffc02016a4:	17700593          	li	a1,375
ffffffffc02016a8:	00004517          	auipc	a0,0x4
ffffffffc02016ac:	d2850513          	addi	a0,a0,-728 # ffffffffc02053d0 <commands+0x868>
ffffffffc02016b0:	b25fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc02016b4:	00004697          	auipc	a3,0x4
ffffffffc02016b8:	02c68693          	addi	a3,a3,44 # ffffffffc02056e0 <commands+0xb78>
ffffffffc02016bc:	00004617          	auipc	a2,0x4
ffffffffc02016c0:	e4460613          	addi	a2,a2,-444 # ffffffffc0205500 <commands+0x998>
ffffffffc02016c4:	17600593          	li	a1,374
ffffffffc02016c8:	00004517          	auipc	a0,0x4
ffffffffc02016cc:	d0850513          	addi	a0,a0,-760 # ffffffffc02053d0 <commands+0x868>
ffffffffc02016d0:	b05fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(*ptep & PTE_W);
ffffffffc02016d4:	00004697          	auipc	a3,0x4
ffffffffc02016d8:	ffc68693          	addi	a3,a3,-4 # ffffffffc02056d0 <commands+0xb68>
ffffffffc02016dc:	00004617          	auipc	a2,0x4
ffffffffc02016e0:	e2460613          	addi	a2,a2,-476 # ffffffffc0205500 <commands+0x998>
ffffffffc02016e4:	17500593          	li	a1,373
ffffffffc02016e8:	00004517          	auipc	a0,0x4
ffffffffc02016ec:	ce850513          	addi	a0,a0,-792 # ffffffffc02053d0 <commands+0x868>
ffffffffc02016f0:	ae5fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(*ptep & PTE_U);
ffffffffc02016f4:	00004697          	auipc	a3,0x4
ffffffffc02016f8:	fcc68693          	addi	a3,a3,-52 # ffffffffc02056c0 <commands+0xb58>
ffffffffc02016fc:	00004617          	auipc	a2,0x4
ffffffffc0201700:	e0460613          	addi	a2,a2,-508 # ffffffffc0205500 <commands+0x998>
ffffffffc0201704:	17400593          	li	a1,372
ffffffffc0201708:	00004517          	auipc	a0,0x4
ffffffffc020170c:	cc850513          	addi	a0,a0,-824 # ffffffffc02053d0 <commands+0x868>
ffffffffc0201710:	ac5fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201714:	00004697          	auipc	a3,0x4
ffffffffc0201718:	f7c68693          	addi	a3,a3,-132 # ffffffffc0205690 <commands+0xb28>
ffffffffc020171c:	00004617          	auipc	a2,0x4
ffffffffc0201720:	de460613          	addi	a2,a2,-540 # ffffffffc0205500 <commands+0x998>
ffffffffc0201724:	17300593          	li	a1,371
ffffffffc0201728:	00004517          	auipc	a0,0x4
ffffffffc020172c:	ca850513          	addi	a0,a0,-856 # ffffffffc02053d0 <commands+0x868>
ffffffffc0201730:	aa5fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0201734:	00004697          	auipc	a3,0x4
ffffffffc0201738:	f2468693          	addi	a3,a3,-220 # ffffffffc0205658 <commands+0xaf0>
ffffffffc020173c:	00004617          	auipc	a2,0x4
ffffffffc0201740:	dc460613          	addi	a2,a2,-572 # ffffffffc0205500 <commands+0x998>
ffffffffc0201744:	17200593          	li	a1,370
ffffffffc0201748:	00004517          	auipc	a0,0x4
ffffffffc020174c:	c8850513          	addi	a0,a0,-888 # ffffffffc02053d0 <commands+0x868>
ffffffffc0201750:	a85fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201754:	00004697          	auipc	a3,0x4
ffffffffc0201758:	edc68693          	addi	a3,a3,-292 # ffffffffc0205630 <commands+0xac8>
ffffffffc020175c:	00004617          	auipc	a2,0x4
ffffffffc0201760:	da460613          	addi	a2,a2,-604 # ffffffffc0205500 <commands+0x998>
ffffffffc0201764:	16f00593          	li	a1,367
ffffffffc0201768:	00004517          	auipc	a0,0x4
ffffffffc020176c:	c6850513          	addi	a0,a0,-920 # ffffffffc02053d0 <commands+0x868>
ffffffffc0201770:	a65fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201774:	86da                	mv	a3,s6
ffffffffc0201776:	00004617          	auipc	a2,0x4
ffffffffc020177a:	c3260613          	addi	a2,a2,-974 # ffffffffc02053a8 <commands+0x840>
ffffffffc020177e:	16e00593          	li	a1,366
ffffffffc0201782:	00004517          	auipc	a0,0x4
ffffffffc0201786:	c4e50513          	addi	a0,a0,-946 # ffffffffc02053d0 <commands+0x868>
ffffffffc020178a:	a4bfe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    return KADDR(page2pa(page));
ffffffffc020178e:	86be                	mv	a3,a5
ffffffffc0201790:	00004617          	auipc	a2,0x4
ffffffffc0201794:	c1860613          	addi	a2,a2,-1000 # ffffffffc02053a8 <commands+0x840>
ffffffffc0201798:	06900593          	li	a1,105
ffffffffc020179c:	00004517          	auipc	a0,0x4
ffffffffc02017a0:	c6450513          	addi	a0,a0,-924 # ffffffffc0205400 <commands+0x898>
ffffffffc02017a4:	a31fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc02017a8:	00004697          	auipc	a3,0x4
ffffffffc02017ac:	ff868693          	addi	a3,a3,-8 # ffffffffc02057a0 <commands+0xc38>
ffffffffc02017b0:	00004617          	auipc	a2,0x4
ffffffffc02017b4:	d5060613          	addi	a2,a2,-688 # ffffffffc0205500 <commands+0x998>
ffffffffc02017b8:	18800593          	li	a1,392
ffffffffc02017bc:	00004517          	auipc	a0,0x4
ffffffffc02017c0:	c1450513          	addi	a0,a0,-1004 # ffffffffc02053d0 <commands+0x868>
ffffffffc02017c4:	a11fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02017c8:	00004697          	auipc	a3,0x4
ffffffffc02017cc:	f9068693          	addi	a3,a3,-112 # ffffffffc0205758 <commands+0xbf0>
ffffffffc02017d0:	00004617          	auipc	a2,0x4
ffffffffc02017d4:	d3060613          	addi	a2,a2,-720 # ffffffffc0205500 <commands+0x998>
ffffffffc02017d8:	18600593          	li	a1,390
ffffffffc02017dc:	00004517          	auipc	a0,0x4
ffffffffc02017e0:	bf450513          	addi	a0,a0,-1036 # ffffffffc02053d0 <commands+0x868>
ffffffffc02017e4:	9f1fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc02017e8:	00004697          	auipc	a3,0x4
ffffffffc02017ec:	fa068693          	addi	a3,a3,-96 # ffffffffc0205788 <commands+0xc20>
ffffffffc02017f0:	00004617          	auipc	a2,0x4
ffffffffc02017f4:	d1060613          	addi	a2,a2,-752 # ffffffffc0205500 <commands+0x998>
ffffffffc02017f8:	18500593          	li	a1,389
ffffffffc02017fc:	00004517          	auipc	a0,0x4
ffffffffc0201800:	bd450513          	addi	a0,a0,-1068 # ffffffffc02053d0 <commands+0x868>
ffffffffc0201804:	9d1fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(page_ref(p) == 2);
ffffffffc0201808:	00004697          	auipc	a3,0x4
ffffffffc020180c:	10068693          	addi	a3,a3,256 # ffffffffc0205908 <commands+0xda0>
ffffffffc0201810:	00004617          	auipc	a2,0x4
ffffffffc0201814:	cf060613          	addi	a2,a2,-784 # ffffffffc0205500 <commands+0x998>
ffffffffc0201818:	1a800593          	li	a1,424
ffffffffc020181c:	00004517          	auipc	a0,0x4
ffffffffc0201820:	bb450513          	addi	a0,a0,-1100 # ffffffffc02053d0 <commands+0x868>
ffffffffc0201824:	9b1fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0201828:	00004697          	auipc	a3,0x4
ffffffffc020182c:	0a068693          	addi	a3,a3,160 # ffffffffc02058c8 <commands+0xd60>
ffffffffc0201830:	00004617          	auipc	a2,0x4
ffffffffc0201834:	cd060613          	addi	a2,a2,-816 # ffffffffc0205500 <commands+0x998>
ffffffffc0201838:	1a700593          	li	a1,423
ffffffffc020183c:	00004517          	auipc	a0,0x4
ffffffffc0201840:	b9450513          	addi	a0,a0,-1132 # ffffffffc02053d0 <commands+0x868>
ffffffffc0201844:	991fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0201848:	00004697          	auipc	a3,0x4
ffffffffc020184c:	06868693          	addi	a3,a3,104 # ffffffffc02058b0 <commands+0xd48>
ffffffffc0201850:	00004617          	auipc	a2,0x4
ffffffffc0201854:	cb060613          	addi	a2,a2,-848 # ffffffffc0205500 <commands+0x998>
ffffffffc0201858:	1a600593          	li	a1,422
ffffffffc020185c:	00004517          	auipc	a0,0x4
ffffffffc0201860:	b7450513          	addi	a0,a0,-1164 # ffffffffc02053d0 <commands+0x868>
ffffffffc0201864:	971fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0201868:	86be                	mv	a3,a5
ffffffffc020186a:	00004617          	auipc	a2,0x4
ffffffffc020186e:	b3e60613          	addi	a2,a2,-1218 # ffffffffc02053a8 <commands+0x840>
ffffffffc0201872:	16d00593          	li	a1,365
ffffffffc0201876:	00004517          	auipc	a0,0x4
ffffffffc020187a:	b5a50513          	addi	a0,a0,-1190 # ffffffffc02053d0 <commands+0x868>
ffffffffc020187e:	957fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201882:	00004617          	auipc	a2,0x4
ffffffffc0201886:	bfe60613          	addi	a2,a2,-1026 # ffffffffc0205480 <commands+0x918>
ffffffffc020188a:	07f00593          	li	a1,127
ffffffffc020188e:	00004517          	auipc	a0,0x4
ffffffffc0201892:	b4250513          	addi	a0,a0,-1214 # ffffffffc02053d0 <commands+0x868>
ffffffffc0201896:	93ffe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc020189a:	00004697          	auipc	a3,0x4
ffffffffc020189e:	09e68693          	addi	a3,a3,158 # ffffffffc0205938 <commands+0xdd0>
ffffffffc02018a2:	00004617          	auipc	a2,0x4
ffffffffc02018a6:	c5e60613          	addi	a2,a2,-930 # ffffffffc0205500 <commands+0x998>
ffffffffc02018aa:	1ac00593          	li	a1,428
ffffffffc02018ae:	00004517          	auipc	a0,0x4
ffffffffc02018b2:	b2250513          	addi	a0,a0,-1246 # ffffffffc02053d0 <commands+0x868>
ffffffffc02018b6:	91ffe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc02018ba:	00004697          	auipc	a3,0x4
ffffffffc02018be:	f0e68693          	addi	a3,a3,-242 # ffffffffc02057c8 <commands+0xc60>
ffffffffc02018c2:	00004617          	auipc	a2,0x4
ffffffffc02018c6:	c3e60613          	addi	a2,a2,-962 # ffffffffc0205500 <commands+0x998>
ffffffffc02018ca:	1b800593          	li	a1,440
ffffffffc02018ce:	00004517          	auipc	a0,0x4
ffffffffc02018d2:	b0250513          	addi	a0,a0,-1278 # ffffffffc02053d0 <commands+0x868>
ffffffffc02018d6:	8fffe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc02018da:	00004697          	auipc	a3,0x4
ffffffffc02018de:	d3e68693          	addi	a3,a3,-706 # ffffffffc0205618 <commands+0xab0>
ffffffffc02018e2:	00004617          	auipc	a2,0x4
ffffffffc02018e6:	c1e60613          	addi	a2,a2,-994 # ffffffffc0205500 <commands+0x998>
ffffffffc02018ea:	16b00593          	li	a1,363
ffffffffc02018ee:	00004517          	auipc	a0,0x4
ffffffffc02018f2:	ae250513          	addi	a0,a0,-1310 # ffffffffc02053d0 <commands+0x868>
ffffffffc02018f6:	8dffe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc02018fa:	00004697          	auipc	a3,0x4
ffffffffc02018fe:	d0668693          	addi	a3,a3,-762 # ffffffffc0205600 <commands+0xa98>
ffffffffc0201902:	00004617          	auipc	a2,0x4
ffffffffc0201906:	bfe60613          	addi	a2,a2,-1026 # ffffffffc0205500 <commands+0x998>
ffffffffc020190a:	16a00593          	li	a1,362
ffffffffc020190e:	00004517          	auipc	a0,0x4
ffffffffc0201912:	ac250513          	addi	a0,a0,-1342 # ffffffffc02053d0 <commands+0x868>
ffffffffc0201916:	8bffe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc020191a:	00004697          	auipc	a3,0x4
ffffffffc020191e:	c3668693          	addi	a3,a3,-970 # ffffffffc0205550 <commands+0x9e8>
ffffffffc0201922:	00004617          	auipc	a2,0x4
ffffffffc0201926:	bde60613          	addi	a2,a2,-1058 # ffffffffc0205500 <commands+0x998>
ffffffffc020192a:	16200593          	li	a1,354
ffffffffc020192e:	00004517          	auipc	a0,0x4
ffffffffc0201932:	aa250513          	addi	a0,a0,-1374 # ffffffffc02053d0 <commands+0x868>
ffffffffc0201936:	89ffe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc020193a:	00004697          	auipc	a3,0x4
ffffffffc020193e:	c6e68693          	addi	a3,a3,-914 # ffffffffc02055a8 <commands+0xa40>
ffffffffc0201942:	00004617          	auipc	a2,0x4
ffffffffc0201946:	bbe60613          	addi	a2,a2,-1090 # ffffffffc0205500 <commands+0x998>
ffffffffc020194a:	16900593          	li	a1,361
ffffffffc020194e:	00004517          	auipc	a0,0x4
ffffffffc0201952:	a8250513          	addi	a0,a0,-1406 # ffffffffc02053d0 <commands+0x868>
ffffffffc0201956:	87ffe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc020195a:	00004697          	auipc	a3,0x4
ffffffffc020195e:	c1e68693          	addi	a3,a3,-994 # ffffffffc0205578 <commands+0xa10>
ffffffffc0201962:	00004617          	auipc	a2,0x4
ffffffffc0201966:	b9e60613          	addi	a2,a2,-1122 # ffffffffc0205500 <commands+0x998>
ffffffffc020196a:	16600593          	li	a1,358
ffffffffc020196e:	00004517          	auipc	a0,0x4
ffffffffc0201972:	a6250513          	addi	a0,a0,-1438 # ffffffffc02053d0 <commands+0x868>
ffffffffc0201976:	85ffe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc020197a:	00004697          	auipc	a3,0x4
ffffffffc020197e:	dde68693          	addi	a3,a3,-546 # ffffffffc0205758 <commands+0xbf0>
ffffffffc0201982:	00004617          	auipc	a2,0x4
ffffffffc0201986:	b7e60613          	addi	a2,a2,-1154 # ffffffffc0205500 <commands+0x998>
ffffffffc020198a:	18200593          	li	a1,386
ffffffffc020198e:	00004517          	auipc	a0,0x4
ffffffffc0201992:	a4250513          	addi	a0,a0,-1470 # ffffffffc02053d0 <commands+0x868>
ffffffffc0201996:	83ffe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc020199a:	00004697          	auipc	a3,0x4
ffffffffc020199e:	c7e68693          	addi	a3,a3,-898 # ffffffffc0205618 <commands+0xab0>
ffffffffc02019a2:	00004617          	auipc	a2,0x4
ffffffffc02019a6:	b5e60613          	addi	a2,a2,-1186 # ffffffffc0205500 <commands+0x998>
ffffffffc02019aa:	18100593          	li	a1,385
ffffffffc02019ae:	00004517          	auipc	a0,0x4
ffffffffc02019b2:	a2250513          	addi	a0,a0,-1502 # ffffffffc02053d0 <commands+0x868>
ffffffffc02019b6:	81ffe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc02019ba:	00004697          	auipc	a3,0x4
ffffffffc02019be:	db668693          	addi	a3,a3,-586 # ffffffffc0205770 <commands+0xc08>
ffffffffc02019c2:	00004617          	auipc	a2,0x4
ffffffffc02019c6:	b3e60613          	addi	a2,a2,-1218 # ffffffffc0205500 <commands+0x998>
ffffffffc02019ca:	17e00593          	li	a1,382
ffffffffc02019ce:	00004517          	auipc	a0,0x4
ffffffffc02019d2:	a0250513          	addi	a0,a0,-1534 # ffffffffc02053d0 <commands+0x868>
ffffffffc02019d6:	ffefe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc02019da:	00004697          	auipc	a3,0x4
ffffffffc02019de:	f9668693          	addi	a3,a3,-106 # ffffffffc0205970 <commands+0xe08>
ffffffffc02019e2:	00004617          	auipc	a2,0x4
ffffffffc02019e6:	b1e60613          	addi	a2,a2,-1250 # ffffffffc0205500 <commands+0x998>
ffffffffc02019ea:	1af00593          	li	a1,431
ffffffffc02019ee:	00004517          	auipc	a0,0x4
ffffffffc02019f2:	9e250513          	addi	a0,a0,-1566 # ffffffffc02053d0 <commands+0x868>
ffffffffc02019f6:	fdefe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc02019fa:	00004697          	auipc	a3,0x4
ffffffffc02019fe:	dce68693          	addi	a3,a3,-562 # ffffffffc02057c8 <commands+0xc60>
ffffffffc0201a02:	00004617          	auipc	a2,0x4
ffffffffc0201a06:	afe60613          	addi	a2,a2,-1282 # ffffffffc0205500 <commands+0x998>
ffffffffc0201a0a:	19000593          	li	a1,400
ffffffffc0201a0e:	00004517          	auipc	a0,0x4
ffffffffc0201a12:	9c250513          	addi	a0,a0,-1598 # ffffffffc02053d0 <commands+0x868>
ffffffffc0201a16:	fbefe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc0201a1a:	00004697          	auipc	a3,0x4
ffffffffc0201a1e:	e4668693          	addi	a3,a3,-442 # ffffffffc0205860 <commands+0xcf8>
ffffffffc0201a22:	00004617          	auipc	a2,0x4
ffffffffc0201a26:	ade60613          	addi	a2,a2,-1314 # ffffffffc0205500 <commands+0x998>
ffffffffc0201a2a:	1a100593          	li	a1,417
ffffffffc0201a2e:	00004517          	auipc	a0,0x4
ffffffffc0201a32:	9a250513          	addi	a0,a0,-1630 # ffffffffc02053d0 <commands+0x868>
ffffffffc0201a36:	f9efe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0201a3a:	00004697          	auipc	a3,0x4
ffffffffc0201a3e:	aa668693          	addi	a3,a3,-1370 # ffffffffc02054e0 <commands+0x978>
ffffffffc0201a42:	00004617          	auipc	a2,0x4
ffffffffc0201a46:	abe60613          	addi	a2,a2,-1346 # ffffffffc0205500 <commands+0x998>
ffffffffc0201a4a:	16000593          	li	a1,352
ffffffffc0201a4e:	00004517          	auipc	a0,0x4
ffffffffc0201a52:	98250513          	addi	a0,a0,-1662 # ffffffffc02053d0 <commands+0x868>
ffffffffc0201a56:	f7efe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0201a5a:	00004617          	auipc	a2,0x4
ffffffffc0201a5e:	a2660613          	addi	a2,a2,-1498 # ffffffffc0205480 <commands+0x918>
ffffffffc0201a62:	0c300593          	li	a1,195
ffffffffc0201a66:	00004517          	auipc	a0,0x4
ffffffffc0201a6a:	96a50513          	addi	a0,a0,-1686 # ffffffffc02053d0 <commands+0x868>
ffffffffc0201a6e:	f66fe0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc0201a72 <tlb_invalidate>:
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201a72:	12058073          	sfence.vma	a1
}
ffffffffc0201a76:	8082                	ret

ffffffffc0201a78 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0201a78:	7179                	addi	sp,sp,-48
ffffffffc0201a7a:	e84a                	sd	s2,16(sp)
ffffffffc0201a7c:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc0201a7e:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0201a80:	f022                	sd	s0,32(sp)
ffffffffc0201a82:	ec26                	sd	s1,24(sp)
ffffffffc0201a84:	e44e                	sd	s3,8(sp)
ffffffffc0201a86:	f406                	sd	ra,40(sp)
ffffffffc0201a88:	84ae                	mv	s1,a1
ffffffffc0201a8a:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc0201a8c:	8f6ff0ef          	jal	ra,ffffffffc0200b82 <alloc_pages>
ffffffffc0201a90:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc0201a92:	cd19                	beqz	a0,ffffffffc0201ab0 <pgdir_alloc_page+0x38>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc0201a94:	85aa                	mv	a1,a0
ffffffffc0201a96:	86ce                	mv	a3,s3
ffffffffc0201a98:	8626                	mv	a2,s1
ffffffffc0201a9a:	854a                	mv	a0,s2
ffffffffc0201a9c:	c92ff0ef          	jal	ra,ffffffffc0200f2e <page_insert>
ffffffffc0201aa0:	ed39                	bnez	a0,ffffffffc0201afe <pgdir_alloc_page+0x86>
        if (swap_init_ok) {
ffffffffc0201aa2:	00014797          	auipc	a5,0x14
ffffffffc0201aa6:	9f678793          	addi	a5,a5,-1546 # ffffffffc0215498 <swap_init_ok>
ffffffffc0201aaa:	439c                	lw	a5,0(a5)
ffffffffc0201aac:	2781                	sext.w	a5,a5
ffffffffc0201aae:	eb89                	bnez	a5,ffffffffc0201ac0 <pgdir_alloc_page+0x48>
}
ffffffffc0201ab0:	8522                	mv	a0,s0
ffffffffc0201ab2:	70a2                	ld	ra,40(sp)
ffffffffc0201ab4:	7402                	ld	s0,32(sp)
ffffffffc0201ab6:	64e2                	ld	s1,24(sp)
ffffffffc0201ab8:	6942                	ld	s2,16(sp)
ffffffffc0201aba:	69a2                	ld	s3,8(sp)
ffffffffc0201abc:	6145                	addi	sp,sp,48
ffffffffc0201abe:	8082                	ret
            swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0201ac0:	00014797          	auipc	a5,0x14
ffffffffc0201ac4:	a3078793          	addi	a5,a5,-1488 # ffffffffc02154f0 <check_mm_struct>
ffffffffc0201ac8:	6388                	ld	a0,0(a5)
ffffffffc0201aca:	4681                	li	a3,0
ffffffffc0201acc:	8622                	mv	a2,s0
ffffffffc0201ace:	85a6                	mv	a1,s1
ffffffffc0201ad0:	79f000ef          	jal	ra,ffffffffc0202a6e <swap_map_swappable>
            assert(page_ref(page) == 1);
ffffffffc0201ad4:	4018                	lw	a4,0(s0)
            page->pra_vaddr = la;
ffffffffc0201ad6:	fc04                	sd	s1,56(s0)
            assert(page_ref(page) == 1);
ffffffffc0201ad8:	4785                	li	a5,1
ffffffffc0201ada:	fcf70be3          	beq	a4,a5,ffffffffc0201ab0 <pgdir_alloc_page+0x38>
ffffffffc0201ade:	00004697          	auipc	a3,0x4
ffffffffc0201ae2:	93268693          	addi	a3,a3,-1742 # ffffffffc0205410 <commands+0x8a8>
ffffffffc0201ae6:	00004617          	auipc	a2,0x4
ffffffffc0201aea:	a1a60613          	addi	a2,a2,-1510 # ffffffffc0205500 <commands+0x998>
ffffffffc0201aee:	14800593          	li	a1,328
ffffffffc0201af2:	00004517          	auipc	a0,0x4
ffffffffc0201af6:	8de50513          	addi	a0,a0,-1826 # ffffffffc02053d0 <commands+0x868>
ffffffffc0201afa:	edafe0ef          	jal	ra,ffffffffc02001d4 <__panic>
            free_page(page);
ffffffffc0201afe:	8522                	mv	a0,s0
ffffffffc0201b00:	4585                	li	a1,1
ffffffffc0201b02:	908ff0ef          	jal	ra,ffffffffc0200c0a <free_pages>
            return NULL;
ffffffffc0201b06:	4401                	li	s0,0
ffffffffc0201b08:	b765                	j	ffffffffc0201ab0 <pgdir_alloc_page+0x38>

ffffffffc0201b0a <check_vma_overlap.isra.0.part.1>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0201b0a:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc0201b0c:	00004697          	auipc	a3,0x4
ffffffffc0201b10:	eac68693          	addi	a3,a3,-340 # ffffffffc02059b8 <commands+0xe50>
ffffffffc0201b14:	00004617          	auipc	a2,0x4
ffffffffc0201b18:	9ec60613          	addi	a2,a2,-1556 # ffffffffc0205500 <commands+0x998>
ffffffffc0201b1c:	07e00593          	li	a1,126
ffffffffc0201b20:	00004517          	auipc	a0,0x4
ffffffffc0201b24:	eb850513          	addi	a0,a0,-328 # ffffffffc02059d8 <commands+0xe70>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0201b28:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc0201b2a:	eaafe0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc0201b2e <mm_create>:
mm_create(void) {
ffffffffc0201b2e:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0201b30:	03000513          	li	a0,48
mm_create(void) {
ffffffffc0201b34:	e022                	sd	s0,0(sp)
ffffffffc0201b36:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0201b38:	2f6010ef          	jal	ra,ffffffffc0202e2e <kmalloc>
ffffffffc0201b3c:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0201b3e:	c115                	beqz	a0,ffffffffc0201b62 <mm_create+0x34>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0201b40:	00014797          	auipc	a5,0x14
ffffffffc0201b44:	95878793          	addi	a5,a5,-1704 # ffffffffc0215498 <swap_init_ok>
ffffffffc0201b48:	439c                	lw	a5,0(a5)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0201b4a:	e408                	sd	a0,8(s0)
ffffffffc0201b4c:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc0201b4e:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0201b52:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0201b56:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0201b5a:	2781                	sext.w	a5,a5
ffffffffc0201b5c:	eb81                	bnez	a5,ffffffffc0201b6c <mm_create+0x3e>
        else mm->sm_priv = NULL;
ffffffffc0201b5e:	02053423          	sd	zero,40(a0)
}
ffffffffc0201b62:	8522                	mv	a0,s0
ffffffffc0201b64:	60a2                	ld	ra,8(sp)
ffffffffc0201b66:	6402                	ld	s0,0(sp)
ffffffffc0201b68:	0141                	addi	sp,sp,16
ffffffffc0201b6a:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0201b6c:	6f3000ef          	jal	ra,ffffffffc0202a5e <swap_init_mm>
}
ffffffffc0201b70:	8522                	mv	a0,s0
ffffffffc0201b72:	60a2                	ld	ra,8(sp)
ffffffffc0201b74:	6402                	ld	s0,0(sp)
ffffffffc0201b76:	0141                	addi	sp,sp,16
ffffffffc0201b78:	8082                	ret

ffffffffc0201b7a <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc0201b7a:	1101                	addi	sp,sp,-32
ffffffffc0201b7c:	e04a                	sd	s2,0(sp)
ffffffffc0201b7e:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201b80:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc0201b84:	e822                	sd	s0,16(sp)
ffffffffc0201b86:	e426                	sd	s1,8(sp)
ffffffffc0201b88:	ec06                	sd	ra,24(sp)
ffffffffc0201b8a:	84ae                	mv	s1,a1
ffffffffc0201b8c:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201b8e:	2a0010ef          	jal	ra,ffffffffc0202e2e <kmalloc>
    if (vma != NULL) {
ffffffffc0201b92:	c509                	beqz	a0,ffffffffc0201b9c <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc0201b94:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc0201b98:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0201b9a:	cd00                	sw	s0,24(a0)
}
ffffffffc0201b9c:	60e2                	ld	ra,24(sp)
ffffffffc0201b9e:	6442                	ld	s0,16(sp)
ffffffffc0201ba0:	64a2                	ld	s1,8(sp)
ffffffffc0201ba2:	6902                	ld	s2,0(sp)
ffffffffc0201ba4:	6105                	addi	sp,sp,32
ffffffffc0201ba6:	8082                	ret

ffffffffc0201ba8 <find_vma>:
    if (mm != NULL) {
ffffffffc0201ba8:	c51d                	beqz	a0,ffffffffc0201bd6 <find_vma+0x2e>
        vma = mm->mmap_cache;
ffffffffc0201baa:	691c                	ld	a5,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0201bac:	c781                	beqz	a5,ffffffffc0201bb4 <find_vma+0xc>
ffffffffc0201bae:	6798                	ld	a4,8(a5)
ffffffffc0201bb0:	02e5f663          	bgeu	a1,a4,ffffffffc0201bdc <find_vma+0x34>
                list_entry_t *list = &(mm->mmap_list), *le = list;
ffffffffc0201bb4:	87aa                	mv	a5,a0
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0201bb6:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc0201bb8:	00f50f63          	beq	a0,a5,ffffffffc0201bd6 <find_vma+0x2e>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc0201bbc:	fe87b703          	ld	a4,-24(a5)
ffffffffc0201bc0:	fee5ebe3          	bltu	a1,a4,ffffffffc0201bb6 <find_vma+0xe>
ffffffffc0201bc4:	ff07b703          	ld	a4,-16(a5)
ffffffffc0201bc8:	fee5f7e3          	bgeu	a1,a4,ffffffffc0201bb6 <find_vma+0xe>
                    vma = le2vma(le, list_link);
ffffffffc0201bcc:	1781                	addi	a5,a5,-32
        if (vma != NULL) {
ffffffffc0201bce:	c781                	beqz	a5,ffffffffc0201bd6 <find_vma+0x2e>
            mm->mmap_cache = vma;
ffffffffc0201bd0:	e91c                	sd	a5,16(a0)
}
ffffffffc0201bd2:	853e                	mv	a0,a5
ffffffffc0201bd4:	8082                	ret
    struct vma_struct *vma = NULL;
ffffffffc0201bd6:	4781                	li	a5,0
}
ffffffffc0201bd8:	853e                	mv	a0,a5
ffffffffc0201bda:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0201bdc:	6b98                	ld	a4,16(a5)
ffffffffc0201bde:	fce5fbe3          	bgeu	a1,a4,ffffffffc0201bb4 <find_vma+0xc>
            mm->mmap_cache = vma;
ffffffffc0201be2:	e91c                	sd	a5,16(a0)
    return vma;
ffffffffc0201be4:	b7fd                	j	ffffffffc0201bd2 <find_vma+0x2a>

ffffffffc0201be6 <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc0201be6:	6590                	ld	a2,8(a1)
ffffffffc0201be8:	0105b803          	ld	a6,16(a1)
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc0201bec:	1141                	addi	sp,sp,-16
ffffffffc0201bee:	e406                	sd	ra,8(sp)
ffffffffc0201bf0:	872a                	mv	a4,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0201bf2:	01066863          	bltu	a2,a6,ffffffffc0201c02 <insert_vma_struct+0x1c>
ffffffffc0201bf6:	a8b9                	j	ffffffffc0201c54 <insert_vma_struct+0x6e>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0201bf8:	fe87b683          	ld	a3,-24(a5)
ffffffffc0201bfc:	04d66763          	bltu	a2,a3,ffffffffc0201c4a <insert_vma_struct+0x64>
ffffffffc0201c00:	873e                	mv	a4,a5
ffffffffc0201c02:	671c                	ld	a5,8(a4)
        while ((le = list_next(le)) != list) {
ffffffffc0201c04:	fef51ae3          	bne	a0,a5,ffffffffc0201bf8 <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc0201c08:	02a70463          	beq	a4,a0,ffffffffc0201c30 <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0201c0c:	ff073683          	ld	a3,-16(a4) # 7fff0 <BASE_ADDRESS-0xffffffffc0180010>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0201c10:	fe873883          	ld	a7,-24(a4)
ffffffffc0201c14:	08d8f063          	bgeu	a7,a3,ffffffffc0201c94 <insert_vma_struct+0xae>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0201c18:	04d66e63          	bltu	a2,a3,ffffffffc0201c74 <insert_vma_struct+0x8e>
    }
    if (le_next != list) {
ffffffffc0201c1c:	00f50a63          	beq	a0,a5,ffffffffc0201c30 <insert_vma_struct+0x4a>
ffffffffc0201c20:	fe87b683          	ld	a3,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc0201c24:	0506e863          	bltu	a3,a6,ffffffffc0201c74 <insert_vma_struct+0x8e>
    assert(next->vm_start < next->vm_end);
ffffffffc0201c28:	ff07b603          	ld	a2,-16(a5)
ffffffffc0201c2c:	02c6f263          	bgeu	a3,a2,ffffffffc0201c50 <insert_vma_struct+0x6a>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc0201c30:	5114                	lw	a3,32(a0)
    vma->vm_mm = mm;
ffffffffc0201c32:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc0201c34:	02058613          	addi	a2,a1,32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0201c38:	e390                	sd	a2,0(a5)
ffffffffc0201c3a:	e710                	sd	a2,8(a4)
}
ffffffffc0201c3c:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc0201c3e:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc0201c40:	f198                	sd	a4,32(a1)
    mm->map_count ++;
ffffffffc0201c42:	2685                	addiw	a3,a3,1
ffffffffc0201c44:	d114                	sw	a3,32(a0)
}
ffffffffc0201c46:	0141                	addi	sp,sp,16
ffffffffc0201c48:	8082                	ret
    if (le_prev != list) {
ffffffffc0201c4a:	fca711e3          	bne	a4,a0,ffffffffc0201c0c <insert_vma_struct+0x26>
ffffffffc0201c4e:	bfd9                	j	ffffffffc0201c24 <insert_vma_struct+0x3e>
ffffffffc0201c50:	ebbff0ef          	jal	ra,ffffffffc0201b0a <check_vma_overlap.isra.0.part.1>
    assert(vma->vm_start < vma->vm_end);
ffffffffc0201c54:	00004697          	auipc	a3,0x4
ffffffffc0201c58:	e3468693          	addi	a3,a3,-460 # ffffffffc0205a88 <commands+0xf20>
ffffffffc0201c5c:	00004617          	auipc	a2,0x4
ffffffffc0201c60:	8a460613          	addi	a2,a2,-1884 # ffffffffc0205500 <commands+0x998>
ffffffffc0201c64:	08500593          	li	a1,133
ffffffffc0201c68:	00004517          	auipc	a0,0x4
ffffffffc0201c6c:	d7050513          	addi	a0,a0,-656 # ffffffffc02059d8 <commands+0xe70>
ffffffffc0201c70:	d64fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0201c74:	00004697          	auipc	a3,0x4
ffffffffc0201c78:	e5468693          	addi	a3,a3,-428 # ffffffffc0205ac8 <commands+0xf60>
ffffffffc0201c7c:	00004617          	auipc	a2,0x4
ffffffffc0201c80:	88460613          	addi	a2,a2,-1916 # ffffffffc0205500 <commands+0x998>
ffffffffc0201c84:	07d00593          	li	a1,125
ffffffffc0201c88:	00004517          	auipc	a0,0x4
ffffffffc0201c8c:	d5050513          	addi	a0,a0,-688 # ffffffffc02059d8 <commands+0xe70>
ffffffffc0201c90:	d44fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0201c94:	00004697          	auipc	a3,0x4
ffffffffc0201c98:	e1468693          	addi	a3,a3,-492 # ffffffffc0205aa8 <commands+0xf40>
ffffffffc0201c9c:	00004617          	auipc	a2,0x4
ffffffffc0201ca0:	86460613          	addi	a2,a2,-1948 # ffffffffc0205500 <commands+0x998>
ffffffffc0201ca4:	07c00593          	li	a1,124
ffffffffc0201ca8:	00004517          	auipc	a0,0x4
ffffffffc0201cac:	d3050513          	addi	a0,a0,-720 # ffffffffc02059d8 <commands+0xe70>
ffffffffc0201cb0:	d24fe0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc0201cb4 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
ffffffffc0201cb4:	1141                	addi	sp,sp,-16
ffffffffc0201cb6:	e022                	sd	s0,0(sp)
ffffffffc0201cb8:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc0201cba:	6508                	ld	a0,8(a0)
ffffffffc0201cbc:	e406                	sd	ra,8(sp)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc0201cbe:	00a40c63          	beq	s0,a0,ffffffffc0201cd6 <mm_destroy+0x22>
    __list_del(listelm->prev, listelm->next);
ffffffffc0201cc2:	6118                	ld	a4,0(a0)
ffffffffc0201cc4:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc0201cc6:	1501                	addi	a0,a0,-32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0201cc8:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0201cca:	e398                	sd	a4,0(a5)
ffffffffc0201ccc:	21e010ef          	jal	ra,ffffffffc0202eea <kfree>
    return listelm->next;
ffffffffc0201cd0:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0201cd2:	fea418e3          	bne	s0,a0,ffffffffc0201cc2 <mm_destroy+0xe>
    }
    kfree(mm); //kfree mm
ffffffffc0201cd6:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc0201cd8:	6402                	ld	s0,0(sp)
ffffffffc0201cda:	60a2                	ld	ra,8(sp)
ffffffffc0201cdc:	0141                	addi	sp,sp,16
    kfree(mm); //kfree mm
ffffffffc0201cde:	20c0106f          	j	ffffffffc0202eea <kfree>

ffffffffc0201ce2 <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc0201ce2:	7139                	addi	sp,sp,-64
ffffffffc0201ce4:	f822                	sd	s0,48(sp)
ffffffffc0201ce6:	f426                	sd	s1,40(sp)
ffffffffc0201ce8:	fc06                	sd	ra,56(sp)
ffffffffc0201cea:	f04a                	sd	s2,32(sp)
ffffffffc0201cec:	ec4e                	sd	s3,24(sp)
ffffffffc0201cee:	e852                	sd	s4,16(sp)
ffffffffc0201cf0:	e456                	sd	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
}

static void
check_vma_struct(void) {
    struct mm_struct *mm = mm_create();
ffffffffc0201cf2:	e3dff0ef          	jal	ra,ffffffffc0201b2e <mm_create>
    assert(mm != NULL);
ffffffffc0201cf6:	842a                	mv	s0,a0
ffffffffc0201cf8:	03200493          	li	s1,50
ffffffffc0201cfc:	e919                	bnez	a0,ffffffffc0201d12 <vmm_init+0x30>
ffffffffc0201cfe:	a989                	j	ffffffffc0202150 <vmm_init+0x46e>
        vma->vm_start = vm_start;
ffffffffc0201d00:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc0201d02:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0201d04:	00052c23          	sw	zero,24(a0)

    int i;
    for (i = step1; i >= 1; i --) {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0201d08:	14ed                	addi	s1,s1,-5
ffffffffc0201d0a:	8522                	mv	a0,s0
ffffffffc0201d0c:	edbff0ef          	jal	ra,ffffffffc0201be6 <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc0201d10:	c88d                	beqz	s1,ffffffffc0201d42 <vmm_init+0x60>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201d12:	03000513          	li	a0,48
ffffffffc0201d16:	118010ef          	jal	ra,ffffffffc0202e2e <kmalloc>
ffffffffc0201d1a:	85aa                	mv	a1,a0
ffffffffc0201d1c:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc0201d20:	f165                	bnez	a0,ffffffffc0201d00 <vmm_init+0x1e>
        assert(vma != NULL);
ffffffffc0201d22:	00004697          	auipc	a3,0x4
ffffffffc0201d26:	fee68693          	addi	a3,a3,-18 # ffffffffc0205d10 <commands+0x11a8>
ffffffffc0201d2a:	00003617          	auipc	a2,0x3
ffffffffc0201d2e:	7d660613          	addi	a2,a2,2006 # ffffffffc0205500 <commands+0x998>
ffffffffc0201d32:	0c900593          	li	a1,201
ffffffffc0201d36:	00004517          	auipc	a0,0x4
ffffffffc0201d3a:	ca250513          	addi	a0,a0,-862 # ffffffffc02059d8 <commands+0xe70>
ffffffffc0201d3e:	c96fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    for (i = step1; i >= 1; i --) {
ffffffffc0201d42:	03700493          	li	s1,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0201d46:	1f900913          	li	s2,505
ffffffffc0201d4a:	a819                	j	ffffffffc0201d60 <vmm_init+0x7e>
        vma->vm_start = vm_start;
ffffffffc0201d4c:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc0201d4e:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0201d50:	00052c23          	sw	zero,24(a0)
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0201d54:	0495                	addi	s1,s1,5
ffffffffc0201d56:	8522                	mv	a0,s0
ffffffffc0201d58:	e8fff0ef          	jal	ra,ffffffffc0201be6 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0201d5c:	03248a63          	beq	s1,s2,ffffffffc0201d90 <vmm_init+0xae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201d60:	03000513          	li	a0,48
ffffffffc0201d64:	0ca010ef          	jal	ra,ffffffffc0202e2e <kmalloc>
ffffffffc0201d68:	85aa                	mv	a1,a0
ffffffffc0201d6a:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc0201d6e:	fd79                	bnez	a0,ffffffffc0201d4c <vmm_init+0x6a>
        assert(vma != NULL);
ffffffffc0201d70:	00004697          	auipc	a3,0x4
ffffffffc0201d74:	fa068693          	addi	a3,a3,-96 # ffffffffc0205d10 <commands+0x11a8>
ffffffffc0201d78:	00003617          	auipc	a2,0x3
ffffffffc0201d7c:	78860613          	addi	a2,a2,1928 # ffffffffc0205500 <commands+0x998>
ffffffffc0201d80:	0cf00593          	li	a1,207
ffffffffc0201d84:	00004517          	auipc	a0,0x4
ffffffffc0201d88:	c5450513          	addi	a0,a0,-940 # ffffffffc02059d8 <commands+0xe70>
ffffffffc0201d8c:	c48fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
ffffffffc0201d90:	6418                	ld	a4,8(s0)
ffffffffc0201d92:	479d                	li	a5,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc0201d94:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc0201d98:	2ee40063          	beq	s0,a4,ffffffffc0202078 <vmm_init+0x396>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0201d9c:	fe873603          	ld	a2,-24(a4)
ffffffffc0201da0:	ffe78693          	addi	a3,a5,-2
ffffffffc0201da4:	24d61a63          	bne	a2,a3,ffffffffc0201ff8 <vmm_init+0x316>
ffffffffc0201da8:	ff073683          	ld	a3,-16(a4)
ffffffffc0201dac:	24f69663          	bne	a3,a5,ffffffffc0201ff8 <vmm_init+0x316>
ffffffffc0201db0:	0795                	addi	a5,a5,5
ffffffffc0201db2:	6718                	ld	a4,8(a4)
    for (i = 1; i <= step2; i ++) {
ffffffffc0201db4:	feb792e3          	bne	a5,a1,ffffffffc0201d98 <vmm_init+0xb6>
ffffffffc0201db8:	491d                	li	s2,7
ffffffffc0201dba:	4495                	li	s1,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0201dbc:	1f900a93          	li	s5,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0201dc0:	85a6                	mv	a1,s1
ffffffffc0201dc2:	8522                	mv	a0,s0
ffffffffc0201dc4:	de5ff0ef          	jal	ra,ffffffffc0201ba8 <find_vma>
ffffffffc0201dc8:	8a2a                	mv	s4,a0
        assert(vma1 != NULL);
ffffffffc0201dca:	30050763          	beqz	a0,ffffffffc02020d8 <vmm_init+0x3f6>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc0201dce:	00148593          	addi	a1,s1,1
ffffffffc0201dd2:	8522                	mv	a0,s0
ffffffffc0201dd4:	dd5ff0ef          	jal	ra,ffffffffc0201ba8 <find_vma>
ffffffffc0201dd8:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc0201dda:	2c050f63          	beqz	a0,ffffffffc02020b8 <vmm_init+0x3d6>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc0201dde:	85ca                	mv	a1,s2
ffffffffc0201de0:	8522                	mv	a0,s0
ffffffffc0201de2:	dc7ff0ef          	jal	ra,ffffffffc0201ba8 <find_vma>
        assert(vma3 == NULL);
ffffffffc0201de6:	2a051963          	bnez	a0,ffffffffc0202098 <vmm_init+0x3b6>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc0201dea:	00348593          	addi	a1,s1,3
ffffffffc0201dee:	8522                	mv	a0,s0
ffffffffc0201df0:	db9ff0ef          	jal	ra,ffffffffc0201ba8 <find_vma>
        assert(vma4 == NULL);
ffffffffc0201df4:	32051263          	bnez	a0,ffffffffc0202118 <vmm_init+0x436>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc0201df8:	00448593          	addi	a1,s1,4
ffffffffc0201dfc:	8522                	mv	a0,s0
ffffffffc0201dfe:	dabff0ef          	jal	ra,ffffffffc0201ba8 <find_vma>
        assert(vma5 == NULL);
ffffffffc0201e02:	2e051b63          	bnez	a0,ffffffffc02020f8 <vmm_init+0x416>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0201e06:	008a3783          	ld	a5,8(s4)
ffffffffc0201e0a:	20979763          	bne	a5,s1,ffffffffc0202018 <vmm_init+0x336>
ffffffffc0201e0e:	010a3783          	ld	a5,16(s4)
ffffffffc0201e12:	21279363          	bne	a5,s2,ffffffffc0202018 <vmm_init+0x336>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0201e16:	0089b783          	ld	a5,8(s3) # fffffffffff80008 <end+0x3fd6aa10>
ffffffffc0201e1a:	20979f63          	bne	a5,s1,ffffffffc0202038 <vmm_init+0x356>
ffffffffc0201e1e:	0109b783          	ld	a5,16(s3)
ffffffffc0201e22:	21279b63          	bne	a5,s2,ffffffffc0202038 <vmm_init+0x356>
ffffffffc0201e26:	0495                	addi	s1,s1,5
ffffffffc0201e28:	0915                	addi	s2,s2,5
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0201e2a:	f9549be3          	bne	s1,s5,ffffffffc0201dc0 <vmm_init+0xde>
ffffffffc0201e2e:	4491                	li	s1,4
    }

    for (i =4; i>=0; i--) {
ffffffffc0201e30:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc0201e32:	85a6                	mv	a1,s1
ffffffffc0201e34:	8522                	mv	a0,s0
ffffffffc0201e36:	d73ff0ef          	jal	ra,ffffffffc0201ba8 <find_vma>
ffffffffc0201e3a:	0004859b          	sext.w	a1,s1
        if (vma_below_5 != NULL ) {
ffffffffc0201e3e:	c90d                	beqz	a0,ffffffffc0201e70 <vmm_init+0x18e>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc0201e40:	6914                	ld	a3,16(a0)
ffffffffc0201e42:	6510                	ld	a2,8(a0)
ffffffffc0201e44:	00004517          	auipc	a0,0x4
ffffffffc0201e48:	db450513          	addi	a0,a0,-588 # ffffffffc0205bf8 <commands+0x1090>
ffffffffc0201e4c:	a84fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc0201e50:	00004697          	auipc	a3,0x4
ffffffffc0201e54:	dd068693          	addi	a3,a3,-560 # ffffffffc0205c20 <commands+0x10b8>
ffffffffc0201e58:	00003617          	auipc	a2,0x3
ffffffffc0201e5c:	6a860613          	addi	a2,a2,1704 # ffffffffc0205500 <commands+0x998>
ffffffffc0201e60:	0f100593          	li	a1,241
ffffffffc0201e64:	00004517          	auipc	a0,0x4
ffffffffc0201e68:	b7450513          	addi	a0,a0,-1164 # ffffffffc02059d8 <commands+0xe70>
ffffffffc0201e6c:	b68fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
ffffffffc0201e70:	14fd                	addi	s1,s1,-1
    for (i =4; i>=0; i--) {
ffffffffc0201e72:	fd2490e3          	bne	s1,s2,ffffffffc0201e32 <vmm_init+0x150>
    }

    mm_destroy(mm);
ffffffffc0201e76:	8522                	mv	a0,s0
ffffffffc0201e78:	e3dff0ef          	jal	ra,ffffffffc0201cb4 <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0201e7c:	00004517          	auipc	a0,0x4
ffffffffc0201e80:	dbc50513          	addi	a0,a0,-580 # ffffffffc0205c38 <commands+0x10d0>
ffffffffc0201e84:	a4cfe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0201e88:	dc9fe0ef          	jal	ra,ffffffffc0200c50 <nr_free_pages>
ffffffffc0201e8c:	89aa                	mv	s3,a0

    check_mm_struct = mm_create();
ffffffffc0201e8e:	ca1ff0ef          	jal	ra,ffffffffc0201b2e <mm_create>
ffffffffc0201e92:	00013797          	auipc	a5,0x13
ffffffffc0201e96:	64a7bf23          	sd	a0,1630(a5) # ffffffffc02154f0 <check_mm_struct>
ffffffffc0201e9a:	84aa                	mv	s1,a0
    assert(check_mm_struct != NULL);
ffffffffc0201e9c:	36050663          	beqz	a0,ffffffffc0202208 <vmm_init+0x526>

    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0201ea0:	00013797          	auipc	a5,0x13
ffffffffc0201ea4:	5d878793          	addi	a5,a5,1496 # ffffffffc0215478 <boot_pgdir>
ffffffffc0201ea8:	0007b903          	ld	s2,0(a5)
    assert(pgdir[0] == 0);
ffffffffc0201eac:	00093783          	ld	a5,0(s2)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0201eb0:	01253c23          	sd	s2,24(a0)
    assert(pgdir[0] == 0);
ffffffffc0201eb4:	2c079e63          	bnez	a5,ffffffffc0202190 <vmm_init+0x4ae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201eb8:	03000513          	li	a0,48
ffffffffc0201ebc:	773000ef          	jal	ra,ffffffffc0202e2e <kmalloc>
ffffffffc0201ec0:	842a                	mv	s0,a0
    if (vma != NULL) {
ffffffffc0201ec2:	18050b63          	beqz	a0,ffffffffc0202058 <vmm_init+0x376>
        vma->vm_end = vm_end;
ffffffffc0201ec6:	002007b7          	lui	a5,0x200
ffffffffc0201eca:	e81c                	sd	a5,16(s0)
        vma->vm_flags = vm_flags;
ffffffffc0201ecc:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc0201ece:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc0201ed0:	cc1c                	sw	a5,24(s0)
    insert_vma_struct(mm, vma);
ffffffffc0201ed2:	8526                	mv	a0,s1
        vma->vm_start = vm_start;
ffffffffc0201ed4:	00043423          	sd	zero,8(s0)
    insert_vma_struct(mm, vma);
ffffffffc0201ed8:	d0fff0ef          	jal	ra,ffffffffc0201be6 <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc0201edc:	10000593          	li	a1,256
ffffffffc0201ee0:	8526                	mv	a0,s1
ffffffffc0201ee2:	cc7ff0ef          	jal	ra,ffffffffc0201ba8 <find_vma>
ffffffffc0201ee6:	10000793          	li	a5,256

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
ffffffffc0201eea:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc0201eee:	2ca41163          	bne	s0,a0,ffffffffc02021b0 <vmm_init+0x4ce>
        *(char *)(addr + i) = i;
ffffffffc0201ef2:	00f78023          	sb	a5,0(a5) # 200000 <BASE_ADDRESS-0xffffffffc0000000>
        sum += i;
ffffffffc0201ef6:	0785                	addi	a5,a5,1
    for (i = 0; i < 100; i ++) {
ffffffffc0201ef8:	fee79de3          	bne	a5,a4,ffffffffc0201ef2 <vmm_init+0x210>
        sum += i;
ffffffffc0201efc:	6705                	lui	a4,0x1
    for (i = 0; i < 100; i ++) {
ffffffffc0201efe:	10000793          	li	a5,256
        sum += i;
ffffffffc0201f02:	35670713          	addi	a4,a4,854 # 1356 <BASE_ADDRESS-0xffffffffc01fecaa>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc0201f06:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc0201f0a:	0007c683          	lbu	a3,0(a5)
ffffffffc0201f0e:	0785                	addi	a5,a5,1
ffffffffc0201f10:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc0201f12:	fec79ce3          	bne	a5,a2,ffffffffc0201f0a <vmm_init+0x228>
    }
    assert(sum == 0);
ffffffffc0201f16:	2c071963          	bnez	a4,ffffffffc02021e8 <vmm_init+0x506>
    return pa2page(PDE_ADDR(pde));
ffffffffc0201f1a:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0201f1e:	00013a97          	auipc	s5,0x13
ffffffffc0201f22:	562a8a93          	addi	s5,s5,1378 # ffffffffc0215480 <npage>
ffffffffc0201f26:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201f2a:	078a                	slli	a5,a5,0x2
ffffffffc0201f2c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201f2e:	20e7f563          	bgeu	a5,a4,ffffffffc0202138 <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc0201f32:	00005697          	auipc	a3,0x5
ffffffffc0201f36:	b0668693          	addi	a3,a3,-1274 # ffffffffc0206a38 <nbase>
ffffffffc0201f3a:	0006ba03          	ld	s4,0(a3)
ffffffffc0201f3e:	414786b3          	sub	a3,a5,s4
ffffffffc0201f42:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc0201f44:	8699                	srai	a3,a3,0x6
ffffffffc0201f46:	96d2                	add	a3,a3,s4
    return KADDR(page2pa(page));
ffffffffc0201f48:	00c69793          	slli	a5,a3,0xc
ffffffffc0201f4c:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201f4e:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0201f50:	28e7f063          	bgeu	a5,a4,ffffffffc02021d0 <vmm_init+0x4ee>
ffffffffc0201f54:	00013797          	auipc	a5,0x13
ffffffffc0201f58:	58478793          	addi	a5,a5,1412 # ffffffffc02154d8 <va_pa_offset>
ffffffffc0201f5c:	6380                	ld	s0,0(a5)

    pde_t *pd1=pgdir,*pd0=page2kva(pde2page(pgdir[0]));
    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc0201f5e:	4581                	li	a1,0
ffffffffc0201f60:	854a                	mv	a0,s2
ffffffffc0201f62:	9436                	add	s0,s0,a3
ffffffffc0201f64:	f57fe0ef          	jal	ra,ffffffffc0200eba <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc0201f68:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0201f6a:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201f6e:	078a                	slli	a5,a5,0x2
ffffffffc0201f70:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201f72:	1ce7f363          	bgeu	a5,a4,ffffffffc0202138 <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc0201f76:	00013417          	auipc	s0,0x13
ffffffffc0201f7a:	57240413          	addi	s0,s0,1394 # ffffffffc02154e8 <pages>
ffffffffc0201f7e:	6008                	ld	a0,0(s0)
ffffffffc0201f80:	414787b3          	sub	a5,a5,s4
ffffffffc0201f84:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc0201f86:	953e                	add	a0,a0,a5
ffffffffc0201f88:	4585                	li	a1,1
ffffffffc0201f8a:	c81fe0ef          	jal	ra,ffffffffc0200c0a <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0201f8e:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0201f92:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201f96:	078a                	slli	a5,a5,0x2
ffffffffc0201f98:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201f9a:	18e7ff63          	bgeu	a5,a4,ffffffffc0202138 <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc0201f9e:	6008                	ld	a0,0(s0)
ffffffffc0201fa0:	414787b3          	sub	a5,a5,s4
ffffffffc0201fa4:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0201fa6:	4585                	li	a1,1
ffffffffc0201fa8:	953e                	add	a0,a0,a5
ffffffffc0201faa:	c61fe0ef          	jal	ra,ffffffffc0200c0a <free_pages>
    pgdir[0] = 0;
ffffffffc0201fae:	00093023          	sd	zero,0(s2)
  asm volatile("sfence.vma");
ffffffffc0201fb2:	12000073          	sfence.vma
    flush_tlb();

    mm->pgdir = NULL;
ffffffffc0201fb6:	0004bc23          	sd	zero,24(s1)
    mm_destroy(mm);
ffffffffc0201fba:	8526                	mv	a0,s1
ffffffffc0201fbc:	cf9ff0ef          	jal	ra,ffffffffc0201cb4 <mm_destroy>
    check_mm_struct = NULL;
ffffffffc0201fc0:	00013797          	auipc	a5,0x13
ffffffffc0201fc4:	5207b823          	sd	zero,1328(a5) # ffffffffc02154f0 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0201fc8:	c89fe0ef          	jal	ra,ffffffffc0200c50 <nr_free_pages>
ffffffffc0201fcc:	1aa99263          	bne	s3,a0,ffffffffc0202170 <vmm_init+0x48e>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc0201fd0:	00004517          	auipc	a0,0x4
ffffffffc0201fd4:	d0850513          	addi	a0,a0,-760 # ffffffffc0205cd8 <commands+0x1170>
ffffffffc0201fd8:	8f8fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
}
ffffffffc0201fdc:	7442                	ld	s0,48(sp)
ffffffffc0201fde:	70e2                	ld	ra,56(sp)
ffffffffc0201fe0:	74a2                	ld	s1,40(sp)
ffffffffc0201fe2:	7902                	ld	s2,32(sp)
ffffffffc0201fe4:	69e2                	ld	s3,24(sp)
ffffffffc0201fe6:	6a42                	ld	s4,16(sp)
ffffffffc0201fe8:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0201fea:	00004517          	auipc	a0,0x4
ffffffffc0201fee:	d0e50513          	addi	a0,a0,-754 # ffffffffc0205cf8 <commands+0x1190>
}
ffffffffc0201ff2:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc0201ff4:	8dcfe06f          	j	ffffffffc02000d0 <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0201ff8:	00004697          	auipc	a3,0x4
ffffffffc0201ffc:	b1868693          	addi	a3,a3,-1256 # ffffffffc0205b10 <commands+0xfa8>
ffffffffc0202000:	00003617          	auipc	a2,0x3
ffffffffc0202004:	50060613          	addi	a2,a2,1280 # ffffffffc0205500 <commands+0x998>
ffffffffc0202008:	0d800593          	li	a1,216
ffffffffc020200c:	00004517          	auipc	a0,0x4
ffffffffc0202010:	9cc50513          	addi	a0,a0,-1588 # ffffffffc02059d8 <commands+0xe70>
ffffffffc0202014:	9c0fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0202018:	00004697          	auipc	a3,0x4
ffffffffc020201c:	b8068693          	addi	a3,a3,-1152 # ffffffffc0205b98 <commands+0x1030>
ffffffffc0202020:	00003617          	auipc	a2,0x3
ffffffffc0202024:	4e060613          	addi	a2,a2,1248 # ffffffffc0205500 <commands+0x998>
ffffffffc0202028:	0e800593          	li	a1,232
ffffffffc020202c:	00004517          	auipc	a0,0x4
ffffffffc0202030:	9ac50513          	addi	a0,a0,-1620 # ffffffffc02059d8 <commands+0xe70>
ffffffffc0202034:	9a0fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0202038:	00004697          	auipc	a3,0x4
ffffffffc020203c:	b9068693          	addi	a3,a3,-1136 # ffffffffc0205bc8 <commands+0x1060>
ffffffffc0202040:	00003617          	auipc	a2,0x3
ffffffffc0202044:	4c060613          	addi	a2,a2,1216 # ffffffffc0205500 <commands+0x998>
ffffffffc0202048:	0e900593          	li	a1,233
ffffffffc020204c:	00004517          	auipc	a0,0x4
ffffffffc0202050:	98c50513          	addi	a0,a0,-1652 # ffffffffc02059d8 <commands+0xe70>
ffffffffc0202054:	980fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(vma != NULL);
ffffffffc0202058:	00004697          	auipc	a3,0x4
ffffffffc020205c:	cb868693          	addi	a3,a3,-840 # ffffffffc0205d10 <commands+0x11a8>
ffffffffc0202060:	00003617          	auipc	a2,0x3
ffffffffc0202064:	4a060613          	addi	a2,a2,1184 # ffffffffc0205500 <commands+0x998>
ffffffffc0202068:	10800593          	li	a1,264
ffffffffc020206c:	00004517          	auipc	a0,0x4
ffffffffc0202070:	96c50513          	addi	a0,a0,-1684 # ffffffffc02059d8 <commands+0xe70>
ffffffffc0202074:	960fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0202078:	00004697          	auipc	a3,0x4
ffffffffc020207c:	a8068693          	addi	a3,a3,-1408 # ffffffffc0205af8 <commands+0xf90>
ffffffffc0202080:	00003617          	auipc	a2,0x3
ffffffffc0202084:	48060613          	addi	a2,a2,1152 # ffffffffc0205500 <commands+0x998>
ffffffffc0202088:	0d600593          	li	a1,214
ffffffffc020208c:	00004517          	auipc	a0,0x4
ffffffffc0202090:	94c50513          	addi	a0,a0,-1716 # ffffffffc02059d8 <commands+0xe70>
ffffffffc0202094:	940fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
        assert(vma3 == NULL);
ffffffffc0202098:	00004697          	auipc	a3,0x4
ffffffffc020209c:	ad068693          	addi	a3,a3,-1328 # ffffffffc0205b68 <commands+0x1000>
ffffffffc02020a0:	00003617          	auipc	a2,0x3
ffffffffc02020a4:	46060613          	addi	a2,a2,1120 # ffffffffc0205500 <commands+0x998>
ffffffffc02020a8:	0e200593          	li	a1,226
ffffffffc02020ac:	00004517          	auipc	a0,0x4
ffffffffc02020b0:	92c50513          	addi	a0,a0,-1748 # ffffffffc02059d8 <commands+0xe70>
ffffffffc02020b4:	920fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
        assert(vma2 != NULL);
ffffffffc02020b8:	00004697          	auipc	a3,0x4
ffffffffc02020bc:	aa068693          	addi	a3,a3,-1376 # ffffffffc0205b58 <commands+0xff0>
ffffffffc02020c0:	00003617          	auipc	a2,0x3
ffffffffc02020c4:	44060613          	addi	a2,a2,1088 # ffffffffc0205500 <commands+0x998>
ffffffffc02020c8:	0e000593          	li	a1,224
ffffffffc02020cc:	00004517          	auipc	a0,0x4
ffffffffc02020d0:	90c50513          	addi	a0,a0,-1780 # ffffffffc02059d8 <commands+0xe70>
ffffffffc02020d4:	900fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
        assert(vma1 != NULL);
ffffffffc02020d8:	00004697          	auipc	a3,0x4
ffffffffc02020dc:	a7068693          	addi	a3,a3,-1424 # ffffffffc0205b48 <commands+0xfe0>
ffffffffc02020e0:	00003617          	auipc	a2,0x3
ffffffffc02020e4:	42060613          	addi	a2,a2,1056 # ffffffffc0205500 <commands+0x998>
ffffffffc02020e8:	0de00593          	li	a1,222
ffffffffc02020ec:	00004517          	auipc	a0,0x4
ffffffffc02020f0:	8ec50513          	addi	a0,a0,-1812 # ffffffffc02059d8 <commands+0xe70>
ffffffffc02020f4:	8e0fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
        assert(vma5 == NULL);
ffffffffc02020f8:	00004697          	auipc	a3,0x4
ffffffffc02020fc:	a9068693          	addi	a3,a3,-1392 # ffffffffc0205b88 <commands+0x1020>
ffffffffc0202100:	00003617          	auipc	a2,0x3
ffffffffc0202104:	40060613          	addi	a2,a2,1024 # ffffffffc0205500 <commands+0x998>
ffffffffc0202108:	0e600593          	li	a1,230
ffffffffc020210c:	00004517          	auipc	a0,0x4
ffffffffc0202110:	8cc50513          	addi	a0,a0,-1844 # ffffffffc02059d8 <commands+0xe70>
ffffffffc0202114:	8c0fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
        assert(vma4 == NULL);
ffffffffc0202118:	00004697          	auipc	a3,0x4
ffffffffc020211c:	a6068693          	addi	a3,a3,-1440 # ffffffffc0205b78 <commands+0x1010>
ffffffffc0202120:	00003617          	auipc	a2,0x3
ffffffffc0202124:	3e060613          	addi	a2,a2,992 # ffffffffc0205500 <commands+0x998>
ffffffffc0202128:	0e400593          	li	a1,228
ffffffffc020212c:	00004517          	auipc	a0,0x4
ffffffffc0202130:	8ac50513          	addi	a0,a0,-1876 # ffffffffc02059d8 <commands+0xe70>
ffffffffc0202134:	8a0fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0202138:	00003617          	auipc	a2,0x3
ffffffffc020213c:	2a860613          	addi	a2,a2,680 # ffffffffc02053e0 <commands+0x878>
ffffffffc0202140:	06200593          	li	a1,98
ffffffffc0202144:	00003517          	auipc	a0,0x3
ffffffffc0202148:	2bc50513          	addi	a0,a0,700 # ffffffffc0205400 <commands+0x898>
ffffffffc020214c:	888fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(mm != NULL);
ffffffffc0202150:	00004697          	auipc	a3,0x4
ffffffffc0202154:	99868693          	addi	a3,a3,-1640 # ffffffffc0205ae8 <commands+0xf80>
ffffffffc0202158:	00003617          	auipc	a2,0x3
ffffffffc020215c:	3a860613          	addi	a2,a2,936 # ffffffffc0205500 <commands+0x998>
ffffffffc0202160:	0c200593          	li	a1,194
ffffffffc0202164:	00004517          	auipc	a0,0x4
ffffffffc0202168:	87450513          	addi	a0,a0,-1932 # ffffffffc02059d8 <commands+0xe70>
ffffffffc020216c:	868fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0202170:	00004697          	auipc	a3,0x4
ffffffffc0202174:	b4068693          	addi	a3,a3,-1216 # ffffffffc0205cb0 <commands+0x1148>
ffffffffc0202178:	00003617          	auipc	a2,0x3
ffffffffc020217c:	38860613          	addi	a2,a2,904 # ffffffffc0205500 <commands+0x998>
ffffffffc0202180:	12400593          	li	a1,292
ffffffffc0202184:	00004517          	auipc	a0,0x4
ffffffffc0202188:	85450513          	addi	a0,a0,-1964 # ffffffffc02059d8 <commands+0xe70>
ffffffffc020218c:	848fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(pgdir[0] == 0);
ffffffffc0202190:	00004697          	auipc	a3,0x4
ffffffffc0202194:	ae068693          	addi	a3,a3,-1312 # ffffffffc0205c70 <commands+0x1108>
ffffffffc0202198:	00003617          	auipc	a2,0x3
ffffffffc020219c:	36860613          	addi	a2,a2,872 # ffffffffc0205500 <commands+0x998>
ffffffffc02021a0:	10500593          	li	a1,261
ffffffffc02021a4:	00004517          	auipc	a0,0x4
ffffffffc02021a8:	83450513          	addi	a0,a0,-1996 # ffffffffc02059d8 <commands+0xe70>
ffffffffc02021ac:	828fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc02021b0:	00004697          	auipc	a3,0x4
ffffffffc02021b4:	ad068693          	addi	a3,a3,-1328 # ffffffffc0205c80 <commands+0x1118>
ffffffffc02021b8:	00003617          	auipc	a2,0x3
ffffffffc02021bc:	34860613          	addi	a2,a2,840 # ffffffffc0205500 <commands+0x998>
ffffffffc02021c0:	10d00593          	li	a1,269
ffffffffc02021c4:	00004517          	auipc	a0,0x4
ffffffffc02021c8:	81450513          	addi	a0,a0,-2028 # ffffffffc02059d8 <commands+0xe70>
ffffffffc02021cc:	808fe0ef          	jal	ra,ffffffffc02001d4 <__panic>
    return KADDR(page2pa(page));
ffffffffc02021d0:	00003617          	auipc	a2,0x3
ffffffffc02021d4:	1d860613          	addi	a2,a2,472 # ffffffffc02053a8 <commands+0x840>
ffffffffc02021d8:	06900593          	li	a1,105
ffffffffc02021dc:	00003517          	auipc	a0,0x3
ffffffffc02021e0:	22450513          	addi	a0,a0,548 # ffffffffc0205400 <commands+0x898>
ffffffffc02021e4:	ff1fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(sum == 0);
ffffffffc02021e8:	00004697          	auipc	a3,0x4
ffffffffc02021ec:	ab868693          	addi	a3,a3,-1352 # ffffffffc0205ca0 <commands+0x1138>
ffffffffc02021f0:	00003617          	auipc	a2,0x3
ffffffffc02021f4:	31060613          	addi	a2,a2,784 # ffffffffc0205500 <commands+0x998>
ffffffffc02021f8:	11700593          	li	a1,279
ffffffffc02021fc:	00003517          	auipc	a0,0x3
ffffffffc0202200:	7dc50513          	addi	a0,a0,2012 # ffffffffc02059d8 <commands+0xe70>
ffffffffc0202204:	fd1fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc0202208:	00004697          	auipc	a3,0x4
ffffffffc020220c:	a5068693          	addi	a3,a3,-1456 # ffffffffc0205c58 <commands+0x10f0>
ffffffffc0202210:	00003617          	auipc	a2,0x3
ffffffffc0202214:	2f060613          	addi	a2,a2,752 # ffffffffc0205500 <commands+0x998>
ffffffffc0202218:	10100593          	li	a1,257
ffffffffc020221c:	00003517          	auipc	a0,0x3
ffffffffc0202220:	7bc50513          	addi	a0,a0,1980 # ffffffffc02059d8 <commands+0xe70>
ffffffffc0202224:	fb1fd0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc0202228 <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
ffffffffc0202228:	1101                	addi	sp,sp,-32
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc020222a:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
ffffffffc020222c:	e822                	sd	s0,16(sp)
ffffffffc020222e:	e426                	sd	s1,8(sp)
ffffffffc0202230:	ec06                	sd	ra,24(sp)
ffffffffc0202232:	e04a                	sd	s2,0(sp)
ffffffffc0202234:	8432                	mv	s0,a2
ffffffffc0202236:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0202238:	971ff0ef          	jal	ra,ffffffffc0201ba8 <find_vma>

    pgfault_num++;
ffffffffc020223c:	00013797          	auipc	a5,0x13
ffffffffc0202240:	24c78793          	addi	a5,a5,588 # ffffffffc0215488 <pgfault_num>
ffffffffc0202244:	439c                	lw	a5,0(a5)
ffffffffc0202246:	2785                	addiw	a5,a5,1
ffffffffc0202248:	00013717          	auipc	a4,0x13
ffffffffc020224c:	24f72023          	sw	a5,576(a4) # ffffffffc0215488 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0202250:	cd21                	beqz	a0,ffffffffc02022a8 <do_pgfault+0x80>
ffffffffc0202252:	651c                	ld	a5,8(a0)
ffffffffc0202254:	04f46a63          	bltu	s0,a5,ffffffffc02022a8 <do_pgfault+0x80>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0202258:	4d1c                	lw	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc020225a:	4941                	li	s2,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc020225c:	8b89                	andi	a5,a5,2
ffffffffc020225e:	e78d                	bnez	a5,ffffffffc0202288 <do_pgfault+0x60>
        perm |= READ_WRITE;
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0202260:	767d                	lui	a2,0xfffff

    pte_t *ptep=NULL;
  
    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0202262:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0202264:	8c71                	and	s0,s0,a2
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0202266:	85a2                	mv	a1,s0
ffffffffc0202268:	4605                	li	a2,1
ffffffffc020226a:	a27fe0ef          	jal	ra,ffffffffc0200c90 <get_pte>
ffffffffc020226e:	cd31                	beqz	a0,ffffffffc02022ca <do_pgfault+0xa2>
        cprintf("get_pte in do_pgfault failed\n");
        goto failed;
    }
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
ffffffffc0202270:	610c                	ld	a1,0(a0)
ffffffffc0202272:	cd89                	beqz	a1,ffffffffc020228c <do_pgfault+0x64>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc0202274:	00013797          	auipc	a5,0x13
ffffffffc0202278:	22478793          	addi	a5,a5,548 # ffffffffc0215498 <swap_init_ok>
ffffffffc020227c:	439c                	lw	a5,0(a5)
ffffffffc020227e:	2781                	sext.w	a5,a5
ffffffffc0202280:	cf8d                	beqz	a5,ffffffffc02022ba <do_pgfault+0x92>
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            //(3) make the page swappable.
            page->pra_vaddr = addr;
ffffffffc0202282:	02003c23          	sd	zero,56(zero) # 38 <BASE_ADDRESS-0xffffffffc01fffc8>
ffffffffc0202286:	9002                	ebreak
        perm |= READ_WRITE;
ffffffffc0202288:	495d                	li	s2,23
ffffffffc020228a:	bfd9                	j	ffffffffc0202260 <do_pgfault+0x38>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc020228c:	6c88                	ld	a0,24(s1)
ffffffffc020228e:	864a                	mv	a2,s2
ffffffffc0202290:	85a2                	mv	a1,s0
ffffffffc0202292:	fe6ff0ef          	jal	ra,ffffffffc0201a78 <pgdir_alloc_page>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
   }

   ret = 0;
ffffffffc0202296:	4781                	li	a5,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0202298:	c129                	beqz	a0,ffffffffc02022da <do_pgfault+0xb2>
failed:
    return ret;
}
ffffffffc020229a:	60e2                	ld	ra,24(sp)
ffffffffc020229c:	6442                	ld	s0,16(sp)
ffffffffc020229e:	64a2                	ld	s1,8(sp)
ffffffffc02022a0:	6902                	ld	s2,0(sp)
ffffffffc02022a2:	853e                	mv	a0,a5
ffffffffc02022a4:	6105                	addi	sp,sp,32
ffffffffc02022a6:	8082                	ret
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc02022a8:	85a2                	mv	a1,s0
ffffffffc02022aa:	00003517          	auipc	a0,0x3
ffffffffc02022ae:	73e50513          	addi	a0,a0,1854 # ffffffffc02059e8 <commands+0xe80>
ffffffffc02022b2:	e1ffd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    int ret = -E_INVAL;
ffffffffc02022b6:	57f5                	li	a5,-3
        goto failed;
ffffffffc02022b8:	b7cd                	j	ffffffffc020229a <do_pgfault+0x72>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc02022ba:	00003517          	auipc	a0,0x3
ffffffffc02022be:	7a650513          	addi	a0,a0,1958 # ffffffffc0205a60 <commands+0xef8>
ffffffffc02022c2:	e0ffd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    ret = -E_NO_MEM;
ffffffffc02022c6:	57f1                	li	a5,-4
            goto failed;
ffffffffc02022c8:	bfc9                	j	ffffffffc020229a <do_pgfault+0x72>
        cprintf("get_pte in do_pgfault failed\n");
ffffffffc02022ca:	00003517          	auipc	a0,0x3
ffffffffc02022ce:	74e50513          	addi	a0,a0,1870 # ffffffffc0205a18 <commands+0xeb0>
ffffffffc02022d2:	dfffd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    ret = -E_NO_MEM;
ffffffffc02022d6:	57f1                	li	a5,-4
        goto failed;
ffffffffc02022d8:	b7c9                	j	ffffffffc020229a <do_pgfault+0x72>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc02022da:	00003517          	auipc	a0,0x3
ffffffffc02022de:	75e50513          	addi	a0,a0,1886 # ffffffffc0205a38 <commands+0xed0>
ffffffffc02022e2:	deffd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    ret = -E_NO_MEM;
ffffffffc02022e6:	57f1                	li	a5,-4
            goto failed;
ffffffffc02022e8:	bf4d                	j	ffffffffc020229a <do_pgfault+0x72>

ffffffffc02022ea <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc02022ea:	7135                	addi	sp,sp,-160
ffffffffc02022ec:	ed06                	sd	ra,152(sp)
ffffffffc02022ee:	e922                	sd	s0,144(sp)
ffffffffc02022f0:	e526                	sd	s1,136(sp)
ffffffffc02022f2:	e14a                	sd	s2,128(sp)
ffffffffc02022f4:	fcce                	sd	s3,120(sp)
ffffffffc02022f6:	f8d2                	sd	s4,112(sp)
ffffffffc02022f8:	f4d6                	sd	s5,104(sp)
ffffffffc02022fa:	f0da                	sd	s6,96(sp)
ffffffffc02022fc:	ecde                	sd	s7,88(sp)
ffffffffc02022fe:	e8e2                	sd	s8,80(sp)
ffffffffc0202300:	e4e6                	sd	s9,72(sp)
ffffffffc0202302:	e0ea                	sd	s10,64(sp)
ffffffffc0202304:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc0202306:	43f010ef          	jal	ra,ffffffffc0203f44 <swapfs_init>
     // if (!(1024 <= max_swap_offset && max_swap_offset < MAX_SWAP_OFFSET_LIMIT))
     // {
     //      panic("bad max_swap_offset %08x.\n", max_swap_offset);
     // }
     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc020230a:	00013797          	auipc	a5,0x13
ffffffffc020230e:	27678793          	addi	a5,a5,630 # ffffffffc0215580 <max_swap_offset>
ffffffffc0202312:	6394                	ld	a3,0(a5)
ffffffffc0202314:	010007b7          	lui	a5,0x1000
ffffffffc0202318:	17e1                	addi	a5,a5,-8
ffffffffc020231a:	ff968713          	addi	a4,a3,-7
ffffffffc020231e:	4ae7e863          	bltu	a5,a4,ffffffffc02027ce <swap_init+0x4e4>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }

     sm = &swap_manager_fifo;
ffffffffc0202322:	00008797          	auipc	a5,0x8
ffffffffc0202326:	cee78793          	addi	a5,a5,-786 # ffffffffc020a010 <swap_manager_fifo>
     int r = sm->init();
ffffffffc020232a:	6798                	ld	a4,8(a5)
     sm = &swap_manager_fifo;
ffffffffc020232c:	00013697          	auipc	a3,0x13
ffffffffc0202330:	16f6b223          	sd	a5,356(a3) # ffffffffc0215490 <sm>
     int r = sm->init();
ffffffffc0202334:	9702                	jalr	a4
ffffffffc0202336:	8aaa                	mv	s5,a0
     
     if (r == 0)
ffffffffc0202338:	c10d                	beqz	a0,ffffffffc020235a <swap_init+0x70>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc020233a:	60ea                	ld	ra,152(sp)
ffffffffc020233c:	644a                	ld	s0,144(sp)
ffffffffc020233e:	8556                	mv	a0,s5
ffffffffc0202340:	64aa                	ld	s1,136(sp)
ffffffffc0202342:	690a                	ld	s2,128(sp)
ffffffffc0202344:	79e6                	ld	s3,120(sp)
ffffffffc0202346:	7a46                	ld	s4,112(sp)
ffffffffc0202348:	7aa6                	ld	s5,104(sp)
ffffffffc020234a:	7b06                	ld	s6,96(sp)
ffffffffc020234c:	6be6                	ld	s7,88(sp)
ffffffffc020234e:	6c46                	ld	s8,80(sp)
ffffffffc0202350:	6ca6                	ld	s9,72(sp)
ffffffffc0202352:	6d06                	ld	s10,64(sp)
ffffffffc0202354:	7de2                	ld	s11,56(sp)
ffffffffc0202356:	610d                	addi	sp,sp,160
ffffffffc0202358:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc020235a:	00013797          	auipc	a5,0x13
ffffffffc020235e:	13678793          	addi	a5,a5,310 # ffffffffc0215490 <sm>
ffffffffc0202362:	639c                	ld	a5,0(a5)
ffffffffc0202364:	00004517          	auipc	a0,0x4
ffffffffc0202368:	9ec50513          	addi	a0,a0,-1556 # ffffffffc0205d50 <commands+0x11e8>
ffffffffc020236c:	00013417          	auipc	s0,0x13
ffffffffc0202370:	26440413          	addi	s0,s0,612 # ffffffffc02155d0 <free_area>
ffffffffc0202374:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc0202376:	4785                	li	a5,1
ffffffffc0202378:	00013717          	auipc	a4,0x13
ffffffffc020237c:	12f72023          	sw	a5,288(a4) # ffffffffc0215498 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0202380:	d51fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc0202384:	641c                	ld	a5,8(s0)
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202386:	36878863          	beq	a5,s0,ffffffffc02026f6 <swap_init+0x40c>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020238a:	ff07b703          	ld	a4,-16(a5)
ffffffffc020238e:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0202390:	8b05                	andi	a4,a4,1
ffffffffc0202392:	36070663          	beqz	a4,ffffffffc02026fe <swap_init+0x414>
     int ret, count = 0, total = 0, i;
ffffffffc0202396:	4481                	li	s1,0
ffffffffc0202398:	4901                	li	s2,0
ffffffffc020239a:	a031                	j	ffffffffc02023a6 <swap_init+0xbc>
ffffffffc020239c:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc02023a0:	8b09                	andi	a4,a4,2
ffffffffc02023a2:	34070e63          	beqz	a4,ffffffffc02026fe <swap_init+0x414>
        count ++, total += p->property;
ffffffffc02023a6:	ff87a703          	lw	a4,-8(a5)
ffffffffc02023aa:	679c                	ld	a5,8(a5)
ffffffffc02023ac:	2905                	addiw	s2,s2,1
ffffffffc02023ae:	9cb9                	addw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc02023b0:	fe8796e3          	bne	a5,s0,ffffffffc020239c <swap_init+0xb2>
ffffffffc02023b4:	89a6                	mv	s3,s1
     }
     assert(total == nr_free_pages());
ffffffffc02023b6:	89bfe0ef          	jal	ra,ffffffffc0200c50 <nr_free_pages>
ffffffffc02023ba:	69351263          	bne	a0,s3,ffffffffc0202a3e <swap_init+0x754>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc02023be:	8626                	mv	a2,s1
ffffffffc02023c0:	85ca                	mv	a1,s2
ffffffffc02023c2:	00004517          	auipc	a0,0x4
ffffffffc02023c6:	9d650513          	addi	a0,a0,-1578 # ffffffffc0205d98 <commands+0x1230>
ffffffffc02023ca:	d07fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc02023ce:	f60ff0ef          	jal	ra,ffffffffc0201b2e <mm_create>
ffffffffc02023d2:	8baa                	mv	s7,a0
     assert(mm != NULL);
ffffffffc02023d4:	60050563          	beqz	a0,ffffffffc02029de <swap_init+0x6f4>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc02023d8:	00013797          	auipc	a5,0x13
ffffffffc02023dc:	11878793          	addi	a5,a5,280 # ffffffffc02154f0 <check_mm_struct>
ffffffffc02023e0:	639c                	ld	a5,0(a5)
ffffffffc02023e2:	60079e63          	bnez	a5,ffffffffc02029fe <swap_init+0x714>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02023e6:	00013797          	auipc	a5,0x13
ffffffffc02023ea:	09278793          	addi	a5,a5,146 # ffffffffc0215478 <boot_pgdir>
ffffffffc02023ee:	0007bb03          	ld	s6,0(a5)
     check_mm_struct = mm;
ffffffffc02023f2:	00013797          	auipc	a5,0x13
ffffffffc02023f6:	0ea7bf23          	sd	a0,254(a5) # ffffffffc02154f0 <check_mm_struct>
     assert(pgdir[0] == 0);
ffffffffc02023fa:	000b3783          	ld	a5,0(s6)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02023fe:	01653c23          	sd	s6,24(a0)
     assert(pgdir[0] == 0);
ffffffffc0202402:	4e079263          	bnez	a5,ffffffffc02028e6 <swap_init+0x5fc>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc0202406:	6599                	lui	a1,0x6
ffffffffc0202408:	460d                	li	a2,3
ffffffffc020240a:	6505                	lui	a0,0x1
ffffffffc020240c:	f6eff0ef          	jal	ra,ffffffffc0201b7a <vma_create>
ffffffffc0202410:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc0202412:	4e050a63          	beqz	a0,ffffffffc0202906 <swap_init+0x61c>

     insert_vma_struct(mm, vma);
ffffffffc0202416:	855e                	mv	a0,s7
ffffffffc0202418:	fceff0ef          	jal	ra,ffffffffc0201be6 <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc020241c:	00004517          	auipc	a0,0x4
ffffffffc0202420:	9bc50513          	addi	a0,a0,-1604 # ffffffffc0205dd8 <commands+0x1270>
ffffffffc0202424:	cadfd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc0202428:	018bb503          	ld	a0,24(s7)
ffffffffc020242c:	4605                	li	a2,1
ffffffffc020242e:	6585                	lui	a1,0x1
ffffffffc0202430:	861fe0ef          	jal	ra,ffffffffc0200c90 <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc0202434:	4e050963          	beqz	a0,ffffffffc0202926 <swap_init+0x63c>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202438:	00004517          	auipc	a0,0x4
ffffffffc020243c:	9f050513          	addi	a0,a0,-1552 # ffffffffc0205e28 <commands+0x12c0>
ffffffffc0202440:	00013997          	auipc	s3,0x13
ffffffffc0202444:	0b898993          	addi	s3,s3,184 # ffffffffc02154f8 <check_rp>
ffffffffc0202448:	c89fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020244c:	00013a17          	auipc	s4,0x13
ffffffffc0202450:	0cca0a13          	addi	s4,s4,204 # ffffffffc0215518 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202454:	8c4e                	mv	s8,s3
          check_rp[i] = alloc_page();
ffffffffc0202456:	4505                	li	a0,1
ffffffffc0202458:	f2afe0ef          	jal	ra,ffffffffc0200b82 <alloc_pages>
ffffffffc020245c:	00ac3023          	sd	a0,0(s8)
          assert(check_rp[i] != NULL );
ffffffffc0202460:	32050763          	beqz	a0,ffffffffc020278e <swap_init+0x4a4>
ffffffffc0202464:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc0202466:	8b89                	andi	a5,a5,2
ffffffffc0202468:	30079363          	bnez	a5,ffffffffc020276e <swap_init+0x484>
ffffffffc020246c:	0c21                	addi	s8,s8,8
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020246e:	ff4c14e3          	bne	s8,s4,ffffffffc0202456 <swap_init+0x16c>
     }
     list_entry_t free_list_store = free_list;
ffffffffc0202472:	601c                	ld	a5,0(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc0202474:	00013c17          	auipc	s8,0x13
ffffffffc0202478:	084c0c13          	addi	s8,s8,132 # ffffffffc02154f8 <check_rp>
     list_entry_t free_list_store = free_list;
ffffffffc020247c:	ec3e                	sd	a5,24(sp)
ffffffffc020247e:	641c                	ld	a5,8(s0)
ffffffffc0202480:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc0202482:	481c                	lw	a5,16(s0)
ffffffffc0202484:	f43e                	sd	a5,40(sp)
    elm->prev = elm->next = elm;
ffffffffc0202486:	00013797          	auipc	a5,0x13
ffffffffc020248a:	1487b923          	sd	s0,338(a5) # ffffffffc02155d8 <free_area+0x8>
ffffffffc020248e:	00013797          	auipc	a5,0x13
ffffffffc0202492:	1487b123          	sd	s0,322(a5) # ffffffffc02155d0 <free_area>
     nr_free = 0;
ffffffffc0202496:	00013797          	auipc	a5,0x13
ffffffffc020249a:	1407a523          	sw	zero,330(a5) # ffffffffc02155e0 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc020249e:	000c3503          	ld	a0,0(s8)
ffffffffc02024a2:	4585                	li	a1,1
ffffffffc02024a4:	0c21                	addi	s8,s8,8
ffffffffc02024a6:	f64fe0ef          	jal	ra,ffffffffc0200c0a <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02024aa:	ff4c1ae3          	bne	s8,s4,ffffffffc020249e <swap_init+0x1b4>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc02024ae:	01042c03          	lw	s8,16(s0)
ffffffffc02024b2:	4791                	li	a5,4
ffffffffc02024b4:	50fc1563          	bne	s8,a5,ffffffffc02029be <swap_init+0x6d4>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc02024b8:	00004517          	auipc	a0,0x4
ffffffffc02024bc:	9f850513          	addi	a0,a0,-1544 # ffffffffc0205eb0 <commands+0x1348>
ffffffffc02024c0:	c11fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc02024c4:	6685                	lui	a3,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc02024c6:	00013797          	auipc	a5,0x13
ffffffffc02024ca:	fc07a123          	sw	zero,-62(a5) # ffffffffc0215488 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc02024ce:	4629                	li	a2,10
     pgfault_num=0;
ffffffffc02024d0:	00013797          	auipc	a5,0x13
ffffffffc02024d4:	fb878793          	addi	a5,a5,-72 # ffffffffc0215488 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc02024d8:	00c68023          	sb	a2,0(a3) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
     assert(pgfault_num==1);
ffffffffc02024dc:	4398                	lw	a4,0(a5)
ffffffffc02024de:	4585                	li	a1,1
ffffffffc02024e0:	2701                	sext.w	a4,a4
ffffffffc02024e2:	38b71263          	bne	a4,a1,ffffffffc0202866 <swap_init+0x57c>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc02024e6:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==1);
ffffffffc02024ea:	4394                	lw	a3,0(a5)
ffffffffc02024ec:	2681                	sext.w	a3,a3
ffffffffc02024ee:	38e69c63          	bne	a3,a4,ffffffffc0202886 <swap_init+0x59c>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc02024f2:	6689                	lui	a3,0x2
ffffffffc02024f4:	462d                	li	a2,11
ffffffffc02024f6:	00c68023          	sb	a2,0(a3) # 2000 <BASE_ADDRESS-0xffffffffc01fe000>
     assert(pgfault_num==2);
ffffffffc02024fa:	4398                	lw	a4,0(a5)
ffffffffc02024fc:	4589                	li	a1,2
ffffffffc02024fe:	2701                	sext.w	a4,a4
ffffffffc0202500:	2eb71363          	bne	a4,a1,ffffffffc02027e6 <swap_init+0x4fc>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc0202504:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc0202508:	4394                	lw	a3,0(a5)
ffffffffc020250a:	2681                	sext.w	a3,a3
ffffffffc020250c:	2ee69d63          	bne	a3,a4,ffffffffc0202806 <swap_init+0x51c>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc0202510:	668d                	lui	a3,0x3
ffffffffc0202512:	4631                	li	a2,12
ffffffffc0202514:	00c68023          	sb	a2,0(a3) # 3000 <BASE_ADDRESS-0xffffffffc01fd000>
     assert(pgfault_num==3);
ffffffffc0202518:	4398                	lw	a4,0(a5)
ffffffffc020251a:	458d                	li	a1,3
ffffffffc020251c:	2701                	sext.w	a4,a4
ffffffffc020251e:	30b71463          	bne	a4,a1,ffffffffc0202826 <swap_init+0x53c>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc0202522:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc0202526:	4394                	lw	a3,0(a5)
ffffffffc0202528:	2681                	sext.w	a3,a3
ffffffffc020252a:	30e69e63          	bne	a3,a4,ffffffffc0202846 <swap_init+0x55c>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc020252e:	6691                	lui	a3,0x4
ffffffffc0202530:	4635                	li	a2,13
ffffffffc0202532:	00c68023          	sb	a2,0(a3) # 4000 <BASE_ADDRESS-0xffffffffc01fc000>
     assert(pgfault_num==4);
ffffffffc0202536:	4398                	lw	a4,0(a5)
ffffffffc0202538:	2701                	sext.w	a4,a4
ffffffffc020253a:	37871663          	bne	a4,s8,ffffffffc02028a6 <swap_init+0x5bc>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc020253e:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc0202542:	439c                	lw	a5,0(a5)
ffffffffc0202544:	2781                	sext.w	a5,a5
ffffffffc0202546:	38e79063          	bne	a5,a4,ffffffffc02028c6 <swap_init+0x5dc>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc020254a:	481c                	lw	a5,16(s0)
ffffffffc020254c:	3e079d63          	bnez	a5,ffffffffc0202946 <swap_init+0x65c>
ffffffffc0202550:	00013797          	auipc	a5,0x13
ffffffffc0202554:	fc878793          	addi	a5,a5,-56 # ffffffffc0215518 <swap_in_seq_no>
ffffffffc0202558:	00013717          	auipc	a4,0x13
ffffffffc020255c:	fe870713          	addi	a4,a4,-24 # ffffffffc0215540 <swap_out_seq_no>
ffffffffc0202560:	00013617          	auipc	a2,0x13
ffffffffc0202564:	fe060613          	addi	a2,a2,-32 # ffffffffc0215540 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc0202568:	56fd                	li	a3,-1
ffffffffc020256a:	c394                	sw	a3,0(a5)
ffffffffc020256c:	c314                	sw	a3,0(a4)
ffffffffc020256e:	0791                	addi	a5,a5,4
ffffffffc0202570:	0711                	addi	a4,a4,4
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0202572:	fef61ce3          	bne	a2,a5,ffffffffc020256a <swap_init+0x280>
ffffffffc0202576:	00013697          	auipc	a3,0x13
ffffffffc020257a:	02a68693          	addi	a3,a3,42 # ffffffffc02155a0 <check_ptep>
ffffffffc020257e:	00013817          	auipc	a6,0x13
ffffffffc0202582:	f7a80813          	addi	a6,a6,-134 # ffffffffc02154f8 <check_rp>
ffffffffc0202586:	6d05                	lui	s10,0x1
    if (PPN(pa) >= npage) {
ffffffffc0202588:	00013c97          	auipc	s9,0x13
ffffffffc020258c:	ef8c8c93          	addi	s9,s9,-264 # ffffffffc0215480 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0202590:	00004d97          	auipc	s11,0x4
ffffffffc0202594:	4a8d8d93          	addi	s11,s11,1192 # ffffffffc0206a38 <nbase>
ffffffffc0202598:	00013c17          	auipc	s8,0x13
ffffffffc020259c:	f50c0c13          	addi	s8,s8,-176 # ffffffffc02154e8 <pages>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc02025a0:	0006b023          	sd	zero,0(a3)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc02025a4:	4601                	li	a2,0
ffffffffc02025a6:	85ea                	mv	a1,s10
ffffffffc02025a8:	855a                	mv	a0,s6
ffffffffc02025aa:	e842                	sd	a6,16(sp)
         check_ptep[i]=0;
ffffffffc02025ac:	e436                	sd	a3,8(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc02025ae:	ee2fe0ef          	jal	ra,ffffffffc0200c90 <get_pte>
ffffffffc02025b2:	66a2                	ld	a3,8(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc02025b4:	6842                	ld	a6,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc02025b6:	e288                	sd	a0,0(a3)
         assert(check_ptep[i] != NULL);
ffffffffc02025b8:	1e050b63          	beqz	a0,ffffffffc02027ae <swap_init+0x4c4>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc02025bc:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02025be:	0017f613          	andi	a2,a5,1
ffffffffc02025c2:	18060a63          	beqz	a2,ffffffffc0202756 <swap_init+0x46c>
    if (PPN(pa) >= npage) {
ffffffffc02025c6:	000cb603          	ld	a2,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc02025ca:	078a                	slli	a5,a5,0x2
ffffffffc02025cc:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02025ce:	14c7f863          	bgeu	a5,a2,ffffffffc020271e <swap_init+0x434>
    return &pages[PPN(pa) - nbase];
ffffffffc02025d2:	000db703          	ld	a4,0(s11)
ffffffffc02025d6:	000c3603          	ld	a2,0(s8)
ffffffffc02025da:	00083583          	ld	a1,0(a6)
ffffffffc02025de:	8f99                	sub	a5,a5,a4
ffffffffc02025e0:	079a                	slli	a5,a5,0x6
ffffffffc02025e2:	e43a                	sd	a4,8(sp)
ffffffffc02025e4:	97b2                	add	a5,a5,a2
ffffffffc02025e6:	14f59863          	bne	a1,a5,ffffffffc0202736 <swap_init+0x44c>
ffffffffc02025ea:	6785                	lui	a5,0x1
ffffffffc02025ec:	9d3e                	add	s10,s10,a5
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02025ee:	6795                	lui	a5,0x5
ffffffffc02025f0:	06a1                	addi	a3,a3,8
ffffffffc02025f2:	0821                	addi	a6,a6,8
ffffffffc02025f4:	fafd16e3          	bne	s10,a5,ffffffffc02025a0 <swap_init+0x2b6>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc02025f8:	00004517          	auipc	a0,0x4
ffffffffc02025fc:	97050513          	addi	a0,a0,-1680 # ffffffffc0205f68 <commands+0x1400>
ffffffffc0202600:	ad1fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    int ret = sm->check_swap();
ffffffffc0202604:	00013797          	auipc	a5,0x13
ffffffffc0202608:	e8c78793          	addi	a5,a5,-372 # ffffffffc0215490 <sm>
ffffffffc020260c:	639c                	ld	a5,0(a5)
ffffffffc020260e:	7f9c                	ld	a5,56(a5)
ffffffffc0202610:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc0202612:	40051663          	bnez	a0,ffffffffc0202a1e <swap_init+0x734>

     nr_free = nr_free_store;
ffffffffc0202616:	77a2                	ld	a5,40(sp)
ffffffffc0202618:	00013717          	auipc	a4,0x13
ffffffffc020261c:	fcf72423          	sw	a5,-56(a4) # ffffffffc02155e0 <free_area+0x10>
     free_list = free_list_store;
ffffffffc0202620:	67e2                	ld	a5,24(sp)
ffffffffc0202622:	00013717          	auipc	a4,0x13
ffffffffc0202626:	faf73723          	sd	a5,-82(a4) # ffffffffc02155d0 <free_area>
ffffffffc020262a:	7782                	ld	a5,32(sp)
ffffffffc020262c:	00013717          	auipc	a4,0x13
ffffffffc0202630:	faf73623          	sd	a5,-84(a4) # ffffffffc02155d8 <free_area+0x8>

     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc0202634:	0009b503          	ld	a0,0(s3)
ffffffffc0202638:	4585                	li	a1,1
ffffffffc020263a:	09a1                	addi	s3,s3,8
ffffffffc020263c:	dcefe0ef          	jal	ra,ffffffffc0200c0a <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202640:	ff499ae3          	bne	s3,s4,ffffffffc0202634 <swap_init+0x34a>
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
ffffffffc0202644:	855e                	mv	a0,s7
ffffffffc0202646:	e6eff0ef          	jal	ra,ffffffffc0201cb4 <mm_destroy>

     pde_t *pd1=pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc020264a:	00013797          	auipc	a5,0x13
ffffffffc020264e:	e2e78793          	addi	a5,a5,-466 # ffffffffc0215478 <boot_pgdir>
ffffffffc0202652:	639c                	ld	a5,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0202654:	000cb703          	ld	a4,0(s9)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202658:	6394                	ld	a3,0(a5)
ffffffffc020265a:	068a                	slli	a3,a3,0x2
ffffffffc020265c:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc020265e:	0ce6f063          	bgeu	a3,a4,ffffffffc020271e <swap_init+0x434>
    return &pages[PPN(pa) - nbase];
ffffffffc0202662:	67a2                	ld	a5,8(sp)
ffffffffc0202664:	000c3503          	ld	a0,0(s8)
ffffffffc0202668:	8e9d                	sub	a3,a3,a5
ffffffffc020266a:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc020266c:	8699                	srai	a3,a3,0x6
ffffffffc020266e:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0202670:	00c69793          	slli	a5,a3,0xc
ffffffffc0202674:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202676:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202678:	2ee7f763          	bgeu	a5,a4,ffffffffc0202966 <swap_init+0x67c>
     free_page(pde2page(pd0[0]));
ffffffffc020267c:	00013797          	auipc	a5,0x13
ffffffffc0202680:	e5c78793          	addi	a5,a5,-420 # ffffffffc02154d8 <va_pa_offset>
ffffffffc0202684:	639c                	ld	a5,0(a5)
ffffffffc0202686:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202688:	629c                	ld	a5,0(a3)
ffffffffc020268a:	078a                	slli	a5,a5,0x2
ffffffffc020268c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020268e:	08e7f863          	bgeu	a5,a4,ffffffffc020271e <swap_init+0x434>
    return &pages[PPN(pa) - nbase];
ffffffffc0202692:	69a2                	ld	s3,8(sp)
ffffffffc0202694:	4585                	li	a1,1
ffffffffc0202696:	413787b3          	sub	a5,a5,s3
ffffffffc020269a:	079a                	slli	a5,a5,0x6
ffffffffc020269c:	953e                	add	a0,a0,a5
ffffffffc020269e:	d6cfe0ef          	jal	ra,ffffffffc0200c0a <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc02026a2:	000b3783          	ld	a5,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc02026a6:	000cb703          	ld	a4,0(s9)
    return pa2page(PDE_ADDR(pde));
ffffffffc02026aa:	078a                	slli	a5,a5,0x2
ffffffffc02026ac:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02026ae:	06e7f863          	bgeu	a5,a4,ffffffffc020271e <swap_init+0x434>
    return &pages[PPN(pa) - nbase];
ffffffffc02026b2:	000c3503          	ld	a0,0(s8)
ffffffffc02026b6:	413787b3          	sub	a5,a5,s3
ffffffffc02026ba:	079a                	slli	a5,a5,0x6
     free_page(pde2page(pd1[0]));
ffffffffc02026bc:	4585                	li	a1,1
ffffffffc02026be:	953e                	add	a0,a0,a5
ffffffffc02026c0:	d4afe0ef          	jal	ra,ffffffffc0200c0a <free_pages>
     pgdir[0] = 0;
ffffffffc02026c4:	000b3023          	sd	zero,0(s6)
  asm volatile("sfence.vma");
ffffffffc02026c8:	12000073          	sfence.vma
    return listelm->next;
ffffffffc02026cc:	641c                	ld	a5,8(s0)
     flush_tlb();

     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc02026ce:	00878963          	beq	a5,s0,ffffffffc02026e0 <swap_init+0x3f6>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc02026d2:	ff87a703          	lw	a4,-8(a5)
ffffffffc02026d6:	679c                	ld	a5,8(a5)
ffffffffc02026d8:	397d                	addiw	s2,s2,-1
ffffffffc02026da:	9c99                	subw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc02026dc:	fe879be3          	bne	a5,s0,ffffffffc02026d2 <swap_init+0x3e8>
     }
     assert(count==0);
ffffffffc02026e0:	28091f63          	bnez	s2,ffffffffc020297e <swap_init+0x694>
     assert(total==0);
ffffffffc02026e4:	2a049d63          	bnez	s1,ffffffffc020299e <swap_init+0x6b4>

     cprintf("check_swap() succeeded!\n");
ffffffffc02026e8:	00004517          	auipc	a0,0x4
ffffffffc02026ec:	8d050513          	addi	a0,a0,-1840 # ffffffffc0205fb8 <commands+0x1450>
ffffffffc02026f0:	9e1fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc02026f4:	b199                	j	ffffffffc020233a <swap_init+0x50>
     int ret, count = 0, total = 0, i;
ffffffffc02026f6:	4481                	li	s1,0
ffffffffc02026f8:	4901                	li	s2,0
     while ((le = list_next(le)) != &free_list) {
ffffffffc02026fa:	4981                	li	s3,0
ffffffffc02026fc:	b96d                	j	ffffffffc02023b6 <swap_init+0xcc>
        assert(PageProperty(p));
ffffffffc02026fe:	00003697          	auipc	a3,0x3
ffffffffc0202702:	66a68693          	addi	a3,a3,1642 # ffffffffc0205d68 <commands+0x1200>
ffffffffc0202706:	00003617          	auipc	a2,0x3
ffffffffc020270a:	dfa60613          	addi	a2,a2,-518 # ffffffffc0205500 <commands+0x998>
ffffffffc020270e:	0bd00593          	li	a1,189
ffffffffc0202712:	00003517          	auipc	a0,0x3
ffffffffc0202716:	62e50513          	addi	a0,a0,1582 # ffffffffc0205d40 <commands+0x11d8>
ffffffffc020271a:	abbfd0ef          	jal	ra,ffffffffc02001d4 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020271e:	00003617          	auipc	a2,0x3
ffffffffc0202722:	cc260613          	addi	a2,a2,-830 # ffffffffc02053e0 <commands+0x878>
ffffffffc0202726:	06200593          	li	a1,98
ffffffffc020272a:	00003517          	auipc	a0,0x3
ffffffffc020272e:	cd650513          	addi	a0,a0,-810 # ffffffffc0205400 <commands+0x898>
ffffffffc0202732:	aa3fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202736:	00004697          	auipc	a3,0x4
ffffffffc020273a:	80a68693          	addi	a3,a3,-2038 # ffffffffc0205f40 <commands+0x13d8>
ffffffffc020273e:	00003617          	auipc	a2,0x3
ffffffffc0202742:	dc260613          	addi	a2,a2,-574 # ffffffffc0205500 <commands+0x998>
ffffffffc0202746:	0fd00593          	li	a1,253
ffffffffc020274a:	00003517          	auipc	a0,0x3
ffffffffc020274e:	5f650513          	addi	a0,a0,1526 # ffffffffc0205d40 <commands+0x11d8>
ffffffffc0202752:	a83fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0202756:	00003617          	auipc	a2,0x3
ffffffffc020275a:	e8260613          	addi	a2,a2,-382 # ffffffffc02055d8 <commands+0xa70>
ffffffffc020275e:	07400593          	li	a1,116
ffffffffc0202762:	00003517          	auipc	a0,0x3
ffffffffc0202766:	c9e50513          	addi	a0,a0,-866 # ffffffffc0205400 <commands+0x898>
ffffffffc020276a:	a6bfd0ef          	jal	ra,ffffffffc02001d4 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc020276e:	00003697          	auipc	a3,0x3
ffffffffc0202772:	6fa68693          	addi	a3,a3,1786 # ffffffffc0205e68 <commands+0x1300>
ffffffffc0202776:	00003617          	auipc	a2,0x3
ffffffffc020277a:	d8a60613          	addi	a2,a2,-630 # ffffffffc0205500 <commands+0x998>
ffffffffc020277e:	0de00593          	li	a1,222
ffffffffc0202782:	00003517          	auipc	a0,0x3
ffffffffc0202786:	5be50513          	addi	a0,a0,1470 # ffffffffc0205d40 <commands+0x11d8>
ffffffffc020278a:	a4bfd0ef          	jal	ra,ffffffffc02001d4 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc020278e:	00003697          	auipc	a3,0x3
ffffffffc0202792:	6c268693          	addi	a3,a3,1730 # ffffffffc0205e50 <commands+0x12e8>
ffffffffc0202796:	00003617          	auipc	a2,0x3
ffffffffc020279a:	d6a60613          	addi	a2,a2,-662 # ffffffffc0205500 <commands+0x998>
ffffffffc020279e:	0dd00593          	li	a1,221
ffffffffc02027a2:	00003517          	auipc	a0,0x3
ffffffffc02027a6:	59e50513          	addi	a0,a0,1438 # ffffffffc0205d40 <commands+0x11d8>
ffffffffc02027aa:	a2bfd0ef          	jal	ra,ffffffffc02001d4 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc02027ae:	00003697          	auipc	a3,0x3
ffffffffc02027b2:	77a68693          	addi	a3,a3,1914 # ffffffffc0205f28 <commands+0x13c0>
ffffffffc02027b6:	00003617          	auipc	a2,0x3
ffffffffc02027ba:	d4a60613          	addi	a2,a2,-694 # ffffffffc0205500 <commands+0x998>
ffffffffc02027be:	0fc00593          	li	a1,252
ffffffffc02027c2:	00003517          	auipc	a0,0x3
ffffffffc02027c6:	57e50513          	addi	a0,a0,1406 # ffffffffc0205d40 <commands+0x11d8>
ffffffffc02027ca:	a0bfd0ef          	jal	ra,ffffffffc02001d4 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc02027ce:	00003617          	auipc	a2,0x3
ffffffffc02027d2:	55260613          	addi	a2,a2,1362 # ffffffffc0205d20 <commands+0x11b8>
ffffffffc02027d6:	02a00593          	li	a1,42
ffffffffc02027da:	00003517          	auipc	a0,0x3
ffffffffc02027de:	56650513          	addi	a0,a0,1382 # ffffffffc0205d40 <commands+0x11d8>
ffffffffc02027e2:	9f3fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
     assert(pgfault_num==2);
ffffffffc02027e6:	00003697          	auipc	a3,0x3
ffffffffc02027ea:	70268693          	addi	a3,a3,1794 # ffffffffc0205ee8 <commands+0x1380>
ffffffffc02027ee:	00003617          	auipc	a2,0x3
ffffffffc02027f2:	d1260613          	addi	a2,a2,-750 # ffffffffc0205500 <commands+0x998>
ffffffffc02027f6:	09800593          	li	a1,152
ffffffffc02027fa:	00003517          	auipc	a0,0x3
ffffffffc02027fe:	54650513          	addi	a0,a0,1350 # ffffffffc0205d40 <commands+0x11d8>
ffffffffc0202802:	9d3fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
     assert(pgfault_num==2);
ffffffffc0202806:	00003697          	auipc	a3,0x3
ffffffffc020280a:	6e268693          	addi	a3,a3,1762 # ffffffffc0205ee8 <commands+0x1380>
ffffffffc020280e:	00003617          	auipc	a2,0x3
ffffffffc0202812:	cf260613          	addi	a2,a2,-782 # ffffffffc0205500 <commands+0x998>
ffffffffc0202816:	09a00593          	li	a1,154
ffffffffc020281a:	00003517          	auipc	a0,0x3
ffffffffc020281e:	52650513          	addi	a0,a0,1318 # ffffffffc0205d40 <commands+0x11d8>
ffffffffc0202822:	9b3fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
     assert(pgfault_num==3);
ffffffffc0202826:	00003697          	auipc	a3,0x3
ffffffffc020282a:	6d268693          	addi	a3,a3,1746 # ffffffffc0205ef8 <commands+0x1390>
ffffffffc020282e:	00003617          	auipc	a2,0x3
ffffffffc0202832:	cd260613          	addi	a2,a2,-814 # ffffffffc0205500 <commands+0x998>
ffffffffc0202836:	09c00593          	li	a1,156
ffffffffc020283a:	00003517          	auipc	a0,0x3
ffffffffc020283e:	50650513          	addi	a0,a0,1286 # ffffffffc0205d40 <commands+0x11d8>
ffffffffc0202842:	993fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
     assert(pgfault_num==3);
ffffffffc0202846:	00003697          	auipc	a3,0x3
ffffffffc020284a:	6b268693          	addi	a3,a3,1714 # ffffffffc0205ef8 <commands+0x1390>
ffffffffc020284e:	00003617          	auipc	a2,0x3
ffffffffc0202852:	cb260613          	addi	a2,a2,-846 # ffffffffc0205500 <commands+0x998>
ffffffffc0202856:	09e00593          	li	a1,158
ffffffffc020285a:	00003517          	auipc	a0,0x3
ffffffffc020285e:	4e650513          	addi	a0,a0,1254 # ffffffffc0205d40 <commands+0x11d8>
ffffffffc0202862:	973fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
     assert(pgfault_num==1);
ffffffffc0202866:	00003697          	auipc	a3,0x3
ffffffffc020286a:	67268693          	addi	a3,a3,1650 # ffffffffc0205ed8 <commands+0x1370>
ffffffffc020286e:	00003617          	auipc	a2,0x3
ffffffffc0202872:	c9260613          	addi	a2,a2,-878 # ffffffffc0205500 <commands+0x998>
ffffffffc0202876:	09400593          	li	a1,148
ffffffffc020287a:	00003517          	auipc	a0,0x3
ffffffffc020287e:	4c650513          	addi	a0,a0,1222 # ffffffffc0205d40 <commands+0x11d8>
ffffffffc0202882:	953fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
     assert(pgfault_num==1);
ffffffffc0202886:	00003697          	auipc	a3,0x3
ffffffffc020288a:	65268693          	addi	a3,a3,1618 # ffffffffc0205ed8 <commands+0x1370>
ffffffffc020288e:	00003617          	auipc	a2,0x3
ffffffffc0202892:	c7260613          	addi	a2,a2,-910 # ffffffffc0205500 <commands+0x998>
ffffffffc0202896:	09600593          	li	a1,150
ffffffffc020289a:	00003517          	auipc	a0,0x3
ffffffffc020289e:	4a650513          	addi	a0,a0,1190 # ffffffffc0205d40 <commands+0x11d8>
ffffffffc02028a2:	933fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
     assert(pgfault_num==4);
ffffffffc02028a6:	00003697          	auipc	a3,0x3
ffffffffc02028aa:	66268693          	addi	a3,a3,1634 # ffffffffc0205f08 <commands+0x13a0>
ffffffffc02028ae:	00003617          	auipc	a2,0x3
ffffffffc02028b2:	c5260613          	addi	a2,a2,-942 # ffffffffc0205500 <commands+0x998>
ffffffffc02028b6:	0a000593          	li	a1,160
ffffffffc02028ba:	00003517          	auipc	a0,0x3
ffffffffc02028be:	48650513          	addi	a0,a0,1158 # ffffffffc0205d40 <commands+0x11d8>
ffffffffc02028c2:	913fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
     assert(pgfault_num==4);
ffffffffc02028c6:	00003697          	auipc	a3,0x3
ffffffffc02028ca:	64268693          	addi	a3,a3,1602 # ffffffffc0205f08 <commands+0x13a0>
ffffffffc02028ce:	00003617          	auipc	a2,0x3
ffffffffc02028d2:	c3260613          	addi	a2,a2,-974 # ffffffffc0205500 <commands+0x998>
ffffffffc02028d6:	0a200593          	li	a1,162
ffffffffc02028da:	00003517          	auipc	a0,0x3
ffffffffc02028de:	46650513          	addi	a0,a0,1126 # ffffffffc0205d40 <commands+0x11d8>
ffffffffc02028e2:	8f3fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
     assert(pgdir[0] == 0);
ffffffffc02028e6:	00003697          	auipc	a3,0x3
ffffffffc02028ea:	38a68693          	addi	a3,a3,906 # ffffffffc0205c70 <commands+0x1108>
ffffffffc02028ee:	00003617          	auipc	a2,0x3
ffffffffc02028f2:	c1260613          	addi	a2,a2,-1006 # ffffffffc0205500 <commands+0x998>
ffffffffc02028f6:	0cd00593          	li	a1,205
ffffffffc02028fa:	00003517          	auipc	a0,0x3
ffffffffc02028fe:	44650513          	addi	a0,a0,1094 # ffffffffc0205d40 <commands+0x11d8>
ffffffffc0202902:	8d3fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
     assert(vma != NULL);
ffffffffc0202906:	00003697          	auipc	a3,0x3
ffffffffc020290a:	40a68693          	addi	a3,a3,1034 # ffffffffc0205d10 <commands+0x11a8>
ffffffffc020290e:	00003617          	auipc	a2,0x3
ffffffffc0202912:	bf260613          	addi	a2,a2,-1038 # ffffffffc0205500 <commands+0x998>
ffffffffc0202916:	0d000593          	li	a1,208
ffffffffc020291a:	00003517          	auipc	a0,0x3
ffffffffc020291e:	42650513          	addi	a0,a0,1062 # ffffffffc0205d40 <commands+0x11d8>
ffffffffc0202922:	8b3fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc0202926:	00003697          	auipc	a3,0x3
ffffffffc020292a:	4ea68693          	addi	a3,a3,1258 # ffffffffc0205e10 <commands+0x12a8>
ffffffffc020292e:	00003617          	auipc	a2,0x3
ffffffffc0202932:	bd260613          	addi	a2,a2,-1070 # ffffffffc0205500 <commands+0x998>
ffffffffc0202936:	0d800593          	li	a1,216
ffffffffc020293a:	00003517          	auipc	a0,0x3
ffffffffc020293e:	40650513          	addi	a0,a0,1030 # ffffffffc0205d40 <commands+0x11d8>
ffffffffc0202942:	893fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
     assert( nr_free == 0);         
ffffffffc0202946:	00003697          	auipc	a3,0x3
ffffffffc020294a:	5d268693          	addi	a3,a3,1490 # ffffffffc0205f18 <commands+0x13b0>
ffffffffc020294e:	00003617          	auipc	a2,0x3
ffffffffc0202952:	bb260613          	addi	a2,a2,-1102 # ffffffffc0205500 <commands+0x998>
ffffffffc0202956:	0f400593          	li	a1,244
ffffffffc020295a:	00003517          	auipc	a0,0x3
ffffffffc020295e:	3e650513          	addi	a0,a0,998 # ffffffffc0205d40 <commands+0x11d8>
ffffffffc0202962:	873fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
    return KADDR(page2pa(page));
ffffffffc0202966:	00003617          	auipc	a2,0x3
ffffffffc020296a:	a4260613          	addi	a2,a2,-1470 # ffffffffc02053a8 <commands+0x840>
ffffffffc020296e:	06900593          	li	a1,105
ffffffffc0202972:	00003517          	auipc	a0,0x3
ffffffffc0202976:	a8e50513          	addi	a0,a0,-1394 # ffffffffc0205400 <commands+0x898>
ffffffffc020297a:	85bfd0ef          	jal	ra,ffffffffc02001d4 <__panic>
     assert(count==0);
ffffffffc020297e:	00003697          	auipc	a3,0x3
ffffffffc0202982:	61a68693          	addi	a3,a3,1562 # ffffffffc0205f98 <commands+0x1430>
ffffffffc0202986:	00003617          	auipc	a2,0x3
ffffffffc020298a:	b7a60613          	addi	a2,a2,-1158 # ffffffffc0205500 <commands+0x998>
ffffffffc020298e:	11c00593          	li	a1,284
ffffffffc0202992:	00003517          	auipc	a0,0x3
ffffffffc0202996:	3ae50513          	addi	a0,a0,942 # ffffffffc0205d40 <commands+0x11d8>
ffffffffc020299a:	83bfd0ef          	jal	ra,ffffffffc02001d4 <__panic>
     assert(total==0);
ffffffffc020299e:	00003697          	auipc	a3,0x3
ffffffffc02029a2:	60a68693          	addi	a3,a3,1546 # ffffffffc0205fa8 <commands+0x1440>
ffffffffc02029a6:	00003617          	auipc	a2,0x3
ffffffffc02029aa:	b5a60613          	addi	a2,a2,-1190 # ffffffffc0205500 <commands+0x998>
ffffffffc02029ae:	11d00593          	li	a1,285
ffffffffc02029b2:	00003517          	auipc	a0,0x3
ffffffffc02029b6:	38e50513          	addi	a0,a0,910 # ffffffffc0205d40 <commands+0x11d8>
ffffffffc02029ba:	81bfd0ef          	jal	ra,ffffffffc02001d4 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc02029be:	00003697          	auipc	a3,0x3
ffffffffc02029c2:	4ca68693          	addi	a3,a3,1226 # ffffffffc0205e88 <commands+0x1320>
ffffffffc02029c6:	00003617          	auipc	a2,0x3
ffffffffc02029ca:	b3a60613          	addi	a2,a2,-1222 # ffffffffc0205500 <commands+0x998>
ffffffffc02029ce:	0eb00593          	li	a1,235
ffffffffc02029d2:	00003517          	auipc	a0,0x3
ffffffffc02029d6:	36e50513          	addi	a0,a0,878 # ffffffffc0205d40 <commands+0x11d8>
ffffffffc02029da:	ffafd0ef          	jal	ra,ffffffffc02001d4 <__panic>
     assert(mm != NULL);
ffffffffc02029de:	00003697          	auipc	a3,0x3
ffffffffc02029e2:	10a68693          	addi	a3,a3,266 # ffffffffc0205ae8 <commands+0xf80>
ffffffffc02029e6:	00003617          	auipc	a2,0x3
ffffffffc02029ea:	b1a60613          	addi	a2,a2,-1254 # ffffffffc0205500 <commands+0x998>
ffffffffc02029ee:	0c500593          	li	a1,197
ffffffffc02029f2:	00003517          	auipc	a0,0x3
ffffffffc02029f6:	34e50513          	addi	a0,a0,846 # ffffffffc0205d40 <commands+0x11d8>
ffffffffc02029fa:	fdafd0ef          	jal	ra,ffffffffc02001d4 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc02029fe:	00003697          	auipc	a3,0x3
ffffffffc0202a02:	3c268693          	addi	a3,a3,962 # ffffffffc0205dc0 <commands+0x1258>
ffffffffc0202a06:	00003617          	auipc	a2,0x3
ffffffffc0202a0a:	afa60613          	addi	a2,a2,-1286 # ffffffffc0205500 <commands+0x998>
ffffffffc0202a0e:	0c800593          	li	a1,200
ffffffffc0202a12:	00003517          	auipc	a0,0x3
ffffffffc0202a16:	32e50513          	addi	a0,a0,814 # ffffffffc0205d40 <commands+0x11d8>
ffffffffc0202a1a:	fbafd0ef          	jal	ra,ffffffffc02001d4 <__panic>
     assert(ret==0);
ffffffffc0202a1e:	00003697          	auipc	a3,0x3
ffffffffc0202a22:	57268693          	addi	a3,a3,1394 # ffffffffc0205f90 <commands+0x1428>
ffffffffc0202a26:	00003617          	auipc	a2,0x3
ffffffffc0202a2a:	ada60613          	addi	a2,a2,-1318 # ffffffffc0205500 <commands+0x998>
ffffffffc0202a2e:	10300593          	li	a1,259
ffffffffc0202a32:	00003517          	auipc	a0,0x3
ffffffffc0202a36:	30e50513          	addi	a0,a0,782 # ffffffffc0205d40 <commands+0x11d8>
ffffffffc0202a3a:	f9afd0ef          	jal	ra,ffffffffc02001d4 <__panic>
     assert(total == nr_free_pages());
ffffffffc0202a3e:	00003697          	auipc	a3,0x3
ffffffffc0202a42:	33a68693          	addi	a3,a3,826 # ffffffffc0205d78 <commands+0x1210>
ffffffffc0202a46:	00003617          	auipc	a2,0x3
ffffffffc0202a4a:	aba60613          	addi	a2,a2,-1350 # ffffffffc0205500 <commands+0x998>
ffffffffc0202a4e:	0c000593          	li	a1,192
ffffffffc0202a52:	00003517          	auipc	a0,0x3
ffffffffc0202a56:	2ee50513          	addi	a0,a0,750 # ffffffffc0205d40 <commands+0x11d8>
ffffffffc0202a5a:	f7afd0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc0202a5e <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0202a5e:	00013797          	auipc	a5,0x13
ffffffffc0202a62:	a3278793          	addi	a5,a5,-1486 # ffffffffc0215490 <sm>
ffffffffc0202a66:	639c                	ld	a5,0(a5)
ffffffffc0202a68:	0107b303          	ld	t1,16(a5)
ffffffffc0202a6c:	8302                	jr	t1

ffffffffc0202a6e <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0202a6e:	00013797          	auipc	a5,0x13
ffffffffc0202a72:	a2278793          	addi	a5,a5,-1502 # ffffffffc0215490 <sm>
ffffffffc0202a76:	639c                	ld	a5,0(a5)
ffffffffc0202a78:	0207b303          	ld	t1,32(a5)
ffffffffc0202a7c:	8302                	jr	t1

ffffffffc0202a7e <swap_out>:
{
ffffffffc0202a7e:	711d                	addi	sp,sp,-96
ffffffffc0202a80:	ec86                	sd	ra,88(sp)
ffffffffc0202a82:	e8a2                	sd	s0,80(sp)
ffffffffc0202a84:	e4a6                	sd	s1,72(sp)
ffffffffc0202a86:	e0ca                	sd	s2,64(sp)
ffffffffc0202a88:	fc4e                	sd	s3,56(sp)
ffffffffc0202a8a:	f852                	sd	s4,48(sp)
ffffffffc0202a8c:	f456                	sd	s5,40(sp)
ffffffffc0202a8e:	f05a                	sd	s6,32(sp)
ffffffffc0202a90:	ec5e                	sd	s7,24(sp)
ffffffffc0202a92:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc0202a94:	cde9                	beqz	a1,ffffffffc0202b6e <swap_out+0xf0>
ffffffffc0202a96:	8ab2                	mv	s5,a2
ffffffffc0202a98:	892a                	mv	s2,a0
ffffffffc0202a9a:	8a2e                	mv	s4,a1
ffffffffc0202a9c:	4401                	li	s0,0
ffffffffc0202a9e:	00013997          	auipc	s3,0x13
ffffffffc0202aa2:	9f298993          	addi	s3,s3,-1550 # ffffffffc0215490 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202aa6:	00003b17          	auipc	s6,0x3
ffffffffc0202aaa:	592b0b13          	addi	s6,s6,1426 # ffffffffc0206038 <commands+0x14d0>
                    cprintf("SWAP: failed to save\n");
ffffffffc0202aae:	00003b97          	auipc	s7,0x3
ffffffffc0202ab2:	572b8b93          	addi	s7,s7,1394 # ffffffffc0206020 <commands+0x14b8>
ffffffffc0202ab6:	a825                	j	ffffffffc0202aee <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202ab8:	67a2                	ld	a5,8(sp)
ffffffffc0202aba:	8626                	mv	a2,s1
ffffffffc0202abc:	85a2                	mv	a1,s0
ffffffffc0202abe:	7f94                	ld	a3,56(a5)
ffffffffc0202ac0:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0202ac2:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202ac4:	82b1                	srli	a3,a3,0xc
ffffffffc0202ac6:	0685                	addi	a3,a3,1
ffffffffc0202ac8:	e08fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0202acc:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0202ace:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0202ad0:	7d1c                	ld	a5,56(a0)
ffffffffc0202ad2:	83b1                	srli	a5,a5,0xc
ffffffffc0202ad4:	0785                	addi	a5,a5,1
ffffffffc0202ad6:	07a2                	slli	a5,a5,0x8
ffffffffc0202ad8:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc0202adc:	92efe0ef          	jal	ra,ffffffffc0200c0a <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0202ae0:	01893503          	ld	a0,24(s2)
ffffffffc0202ae4:	85a6                	mv	a1,s1
ffffffffc0202ae6:	f8dfe0ef          	jal	ra,ffffffffc0201a72 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0202aea:	048a0d63          	beq	s4,s0,ffffffffc0202b44 <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0202aee:	0009b783          	ld	a5,0(s3)
ffffffffc0202af2:	8656                	mv	a2,s5
ffffffffc0202af4:	002c                	addi	a1,sp,8
ffffffffc0202af6:	7b9c                	ld	a5,48(a5)
ffffffffc0202af8:	854a                	mv	a0,s2
ffffffffc0202afa:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0202afc:	e12d                	bnez	a0,ffffffffc0202b5e <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0202afe:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202b00:	01893503          	ld	a0,24(s2)
ffffffffc0202b04:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0202b06:	7f84                	ld	s1,56(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202b08:	85a6                	mv	a1,s1
ffffffffc0202b0a:	986fe0ef          	jal	ra,ffffffffc0200c90 <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0202b0e:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202b10:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0202b12:	8b85                	andi	a5,a5,1
ffffffffc0202b14:	cfb9                	beqz	a5,ffffffffc0202b72 <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0202b16:	65a2                	ld	a1,8(sp)
ffffffffc0202b18:	7d9c                	ld	a5,56(a1)
ffffffffc0202b1a:	83b1                	srli	a5,a5,0xc
ffffffffc0202b1c:	00178513          	addi	a0,a5,1
ffffffffc0202b20:	0522                	slli	a0,a0,0x8
ffffffffc0202b22:	45a010ef          	jal	ra,ffffffffc0203f7c <swapfs_write>
ffffffffc0202b26:	d949                	beqz	a0,ffffffffc0202ab8 <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0202b28:	855e                	mv	a0,s7
ffffffffc0202b2a:	da6fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0202b2e:	0009b783          	ld	a5,0(s3)
ffffffffc0202b32:	6622                	ld	a2,8(sp)
ffffffffc0202b34:	4681                	li	a3,0
ffffffffc0202b36:	739c                	ld	a5,32(a5)
ffffffffc0202b38:	85a6                	mv	a1,s1
ffffffffc0202b3a:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0202b3c:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0202b3e:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0202b40:	fa8a17e3          	bne	s4,s0,ffffffffc0202aee <swap_out+0x70>
}
ffffffffc0202b44:	8522                	mv	a0,s0
ffffffffc0202b46:	60e6                	ld	ra,88(sp)
ffffffffc0202b48:	6446                	ld	s0,80(sp)
ffffffffc0202b4a:	64a6                	ld	s1,72(sp)
ffffffffc0202b4c:	6906                	ld	s2,64(sp)
ffffffffc0202b4e:	79e2                	ld	s3,56(sp)
ffffffffc0202b50:	7a42                	ld	s4,48(sp)
ffffffffc0202b52:	7aa2                	ld	s5,40(sp)
ffffffffc0202b54:	7b02                	ld	s6,32(sp)
ffffffffc0202b56:	6be2                	ld	s7,24(sp)
ffffffffc0202b58:	6c42                	ld	s8,16(sp)
ffffffffc0202b5a:	6125                	addi	sp,sp,96
ffffffffc0202b5c:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc0202b5e:	85a2                	mv	a1,s0
ffffffffc0202b60:	00003517          	auipc	a0,0x3
ffffffffc0202b64:	47850513          	addi	a0,a0,1144 # ffffffffc0205fd8 <commands+0x1470>
ffffffffc0202b68:	d68fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
                  break;
ffffffffc0202b6c:	bfe1                	j	ffffffffc0202b44 <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc0202b6e:	4401                	li	s0,0
ffffffffc0202b70:	bfd1                	j	ffffffffc0202b44 <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0202b72:	00003697          	auipc	a3,0x3
ffffffffc0202b76:	49668693          	addi	a3,a3,1174 # ffffffffc0206008 <commands+0x14a0>
ffffffffc0202b7a:	00003617          	auipc	a2,0x3
ffffffffc0202b7e:	98660613          	addi	a2,a2,-1658 # ffffffffc0205500 <commands+0x998>
ffffffffc0202b82:	06900593          	li	a1,105
ffffffffc0202b86:	00003517          	auipc	a0,0x3
ffffffffc0202b8a:	1ba50513          	addi	a0,a0,442 # ffffffffc0205d40 <commands+0x11d8>
ffffffffc0202b8e:	e46fd0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc0202b92 <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc0202b92:	c125                	beqz	a0,ffffffffc0202bf2 <slob_free+0x60>
		return;

	if (size)
ffffffffc0202b94:	e1a5                	bnez	a1,ffffffffc0202bf4 <slob_free+0x62>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202b96:	100027f3          	csrr	a5,sstatus
ffffffffc0202b9a:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0202b9c:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202b9e:	e3bd                	bnez	a5,ffffffffc0202c04 <slob_free+0x72>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0202ba0:	00007797          	auipc	a5,0x7
ffffffffc0202ba4:	4b078793          	addi	a5,a5,1200 # ffffffffc020a050 <slobfree>
ffffffffc0202ba8:	639c                	ld	a5,0(a5)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0202baa:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0202bac:	00a7fa63          	bgeu	a5,a0,ffffffffc0202bc0 <slob_free+0x2e>
ffffffffc0202bb0:	00e56c63          	bltu	a0,a4,ffffffffc0202bc8 <slob_free+0x36>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0202bb4:	00e7fa63          	bgeu	a5,a4,ffffffffc0202bc8 <slob_free+0x36>
    return 0;
ffffffffc0202bb8:	87ba                	mv	a5,a4
ffffffffc0202bba:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0202bbc:	fea7eae3          	bltu	a5,a0,ffffffffc0202bb0 <slob_free+0x1e>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0202bc0:	fee7ece3          	bltu	a5,a4,ffffffffc0202bb8 <slob_free+0x26>
ffffffffc0202bc4:	fee57ae3          	bgeu	a0,a4,ffffffffc0202bb8 <slob_free+0x26>
			break;

	if (b + b->units == cur->next) {
ffffffffc0202bc8:	4110                	lw	a2,0(a0)
ffffffffc0202bca:	00461693          	slli	a3,a2,0x4
ffffffffc0202bce:	96aa                	add	a3,a3,a0
ffffffffc0202bd0:	08d70b63          	beq	a4,a3,ffffffffc0202c66 <slob_free+0xd4>
		b->units += cur->next->units;
		b->next = cur->next->next;
	} else
		b->next = cur->next;

	if (cur + cur->units == b) {
ffffffffc0202bd4:	4394                	lw	a3,0(a5)
		b->next = cur->next;
ffffffffc0202bd6:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc0202bd8:	00469713          	slli	a4,a3,0x4
ffffffffc0202bdc:	973e                	add	a4,a4,a5
ffffffffc0202bde:	08e50f63          	beq	a0,a4,ffffffffc0202c7c <slob_free+0xea>
		cur->units += b->units;
		cur->next = b->next;
	} else
		cur->next = b;
ffffffffc0202be2:	e788                	sd	a0,8(a5)

	slobfree = cur;
ffffffffc0202be4:	00007717          	auipc	a4,0x7
ffffffffc0202be8:	46f73623          	sd	a5,1132(a4) # ffffffffc020a050 <slobfree>
    if (flag) {
ffffffffc0202bec:	c199                	beqz	a1,ffffffffc0202bf2 <slob_free+0x60>
        intr_enable();
ffffffffc0202bee:	9bbfd06f          	j	ffffffffc02005a8 <intr_enable>
ffffffffc0202bf2:	8082                	ret
		b->units = SLOB_UNITS(size);
ffffffffc0202bf4:	05bd                	addi	a1,a1,15
ffffffffc0202bf6:	8191                	srli	a1,a1,0x4
ffffffffc0202bf8:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202bfa:	100027f3          	csrr	a5,sstatus
ffffffffc0202bfe:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0202c00:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202c02:	dfd9                	beqz	a5,ffffffffc0202ba0 <slob_free+0xe>
{
ffffffffc0202c04:	1101                	addi	sp,sp,-32
ffffffffc0202c06:	e42a                	sd	a0,8(sp)
ffffffffc0202c08:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0202c0a:	9a5fd0ef          	jal	ra,ffffffffc02005ae <intr_disable>
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0202c0e:	00007797          	auipc	a5,0x7
ffffffffc0202c12:	44278793          	addi	a5,a5,1090 # ffffffffc020a050 <slobfree>
ffffffffc0202c16:	639c                	ld	a5,0(a5)
        return 1;
ffffffffc0202c18:	6522                	ld	a0,8(sp)
ffffffffc0202c1a:	4585                	li	a1,1
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0202c1c:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0202c1e:	00a7fa63          	bgeu	a5,a0,ffffffffc0202c32 <slob_free+0xa0>
ffffffffc0202c22:	00e56c63          	bltu	a0,a4,ffffffffc0202c3a <slob_free+0xa8>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0202c26:	00e7fa63          	bgeu	a5,a4,ffffffffc0202c3a <slob_free+0xa8>
    return 0;
ffffffffc0202c2a:	87ba                	mv	a5,a4
ffffffffc0202c2c:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0202c2e:	fea7eae3          	bltu	a5,a0,ffffffffc0202c22 <slob_free+0x90>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0202c32:	fee7ece3          	bltu	a5,a4,ffffffffc0202c2a <slob_free+0x98>
ffffffffc0202c36:	fee57ae3          	bgeu	a0,a4,ffffffffc0202c2a <slob_free+0x98>
	if (b + b->units == cur->next) {
ffffffffc0202c3a:	4110                	lw	a2,0(a0)
ffffffffc0202c3c:	00461693          	slli	a3,a2,0x4
ffffffffc0202c40:	96aa                	add	a3,a3,a0
ffffffffc0202c42:	04d70763          	beq	a4,a3,ffffffffc0202c90 <slob_free+0xfe>
		b->next = cur->next;
ffffffffc0202c46:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc0202c48:	4394                	lw	a3,0(a5)
ffffffffc0202c4a:	00469713          	slli	a4,a3,0x4
ffffffffc0202c4e:	973e                	add	a4,a4,a5
ffffffffc0202c50:	04e50663          	beq	a0,a4,ffffffffc0202c9c <slob_free+0x10a>
		cur->next = b;
ffffffffc0202c54:	e788                	sd	a0,8(a5)
	slobfree = cur;
ffffffffc0202c56:	00007717          	auipc	a4,0x7
ffffffffc0202c5a:	3ef73d23          	sd	a5,1018(a4) # ffffffffc020a050 <slobfree>
    if (flag) {
ffffffffc0202c5e:	e58d                	bnez	a1,ffffffffc0202c88 <slob_free+0xf6>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc0202c60:	60e2                	ld	ra,24(sp)
ffffffffc0202c62:	6105                	addi	sp,sp,32
ffffffffc0202c64:	8082                	ret
		b->units += cur->next->units;
ffffffffc0202c66:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0202c68:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc0202c6a:	9e35                	addw	a2,a2,a3
ffffffffc0202c6c:	c110                	sw	a2,0(a0)
	if (cur + cur->units == b) {
ffffffffc0202c6e:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc0202c70:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc0202c72:	00469713          	slli	a4,a3,0x4
ffffffffc0202c76:	973e                	add	a4,a4,a5
ffffffffc0202c78:	f6e515e3          	bne	a0,a4,ffffffffc0202be2 <slob_free+0x50>
		cur->units += b->units;
ffffffffc0202c7c:	4118                	lw	a4,0(a0)
		cur->next = b->next;
ffffffffc0202c7e:	6510                	ld	a2,8(a0)
		cur->units += b->units;
ffffffffc0202c80:	9eb9                	addw	a3,a3,a4
ffffffffc0202c82:	c394                	sw	a3,0(a5)
		cur->next = b->next;
ffffffffc0202c84:	e790                	sd	a2,8(a5)
ffffffffc0202c86:	bfb9                	j	ffffffffc0202be4 <slob_free+0x52>
}
ffffffffc0202c88:	60e2                	ld	ra,24(sp)
ffffffffc0202c8a:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0202c8c:	91dfd06f          	j	ffffffffc02005a8 <intr_enable>
		b->units += cur->next->units;
ffffffffc0202c90:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0202c92:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc0202c94:	9e35                	addw	a2,a2,a3
ffffffffc0202c96:	c110                	sw	a2,0(a0)
		b->next = cur->next->next;
ffffffffc0202c98:	e518                	sd	a4,8(a0)
ffffffffc0202c9a:	b77d                	j	ffffffffc0202c48 <slob_free+0xb6>
		cur->units += b->units;
ffffffffc0202c9c:	4118                	lw	a4,0(a0)
		cur->next = b->next;
ffffffffc0202c9e:	6510                	ld	a2,8(a0)
		cur->units += b->units;
ffffffffc0202ca0:	9eb9                	addw	a3,a3,a4
ffffffffc0202ca2:	c394                	sw	a3,0(a5)
		cur->next = b->next;
ffffffffc0202ca4:	e790                	sd	a2,8(a5)
ffffffffc0202ca6:	bf45                	j	ffffffffc0202c56 <slob_free+0xc4>

ffffffffc0202ca8 <__slob_get_free_pages.isra.0>:
  struct Page * page = alloc_pages(1 << order);
ffffffffc0202ca8:	4785                	li	a5,1
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0202caa:	1141                	addi	sp,sp,-16
  struct Page * page = alloc_pages(1 << order);
ffffffffc0202cac:	00a7953b          	sllw	a0,a5,a0
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0202cb0:	e406                	sd	ra,8(sp)
  struct Page * page = alloc_pages(1 << order);
ffffffffc0202cb2:	ed1fd0ef          	jal	ra,ffffffffc0200b82 <alloc_pages>
  if(!page)
ffffffffc0202cb6:	cd1d                	beqz	a0,ffffffffc0202cf4 <__slob_get_free_pages.isra.0+0x4c>
    return page - pages + nbase;
ffffffffc0202cb8:	00013797          	auipc	a5,0x13
ffffffffc0202cbc:	83078793          	addi	a5,a5,-2000 # ffffffffc02154e8 <pages>
ffffffffc0202cc0:	6394                	ld	a3,0(a5)
ffffffffc0202cc2:	00004797          	auipc	a5,0x4
ffffffffc0202cc6:	d7678793          	addi	a5,a5,-650 # ffffffffc0206a38 <nbase>
ffffffffc0202cca:	8d15                	sub	a0,a0,a3
ffffffffc0202ccc:	6394                	ld	a3,0(a5)
ffffffffc0202cce:	8519                	srai	a0,a0,0x6
    return KADDR(page2pa(page));
ffffffffc0202cd0:	00012797          	auipc	a5,0x12
ffffffffc0202cd4:	7b078793          	addi	a5,a5,1968 # ffffffffc0215480 <npage>
    return page - pages + nbase;
ffffffffc0202cd8:	9536                	add	a0,a0,a3
    return KADDR(page2pa(page));
ffffffffc0202cda:	6398                	ld	a4,0(a5)
ffffffffc0202cdc:	00c51793          	slli	a5,a0,0xc
ffffffffc0202ce0:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202ce2:	0532                	slli	a0,a0,0xc
    return KADDR(page2pa(page));
ffffffffc0202ce4:	00e7fb63          	bgeu	a5,a4,ffffffffc0202cfa <__slob_get_free_pages.isra.0+0x52>
ffffffffc0202ce8:	00012797          	auipc	a5,0x12
ffffffffc0202cec:	7f078793          	addi	a5,a5,2032 # ffffffffc02154d8 <va_pa_offset>
ffffffffc0202cf0:	6394                	ld	a3,0(a5)
ffffffffc0202cf2:	9536                	add	a0,a0,a3
}
ffffffffc0202cf4:	60a2                	ld	ra,8(sp)
ffffffffc0202cf6:	0141                	addi	sp,sp,16
ffffffffc0202cf8:	8082                	ret
ffffffffc0202cfa:	86aa                	mv	a3,a0
ffffffffc0202cfc:	00002617          	auipc	a2,0x2
ffffffffc0202d00:	6ac60613          	addi	a2,a2,1708 # ffffffffc02053a8 <commands+0x840>
ffffffffc0202d04:	06900593          	li	a1,105
ffffffffc0202d08:	00002517          	auipc	a0,0x2
ffffffffc0202d0c:	6f850513          	addi	a0,a0,1784 # ffffffffc0205400 <commands+0x898>
ffffffffc0202d10:	cc4fd0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc0202d14 <slob_alloc.isra.1.constprop.3>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc0202d14:	1101                	addi	sp,sp,-32
ffffffffc0202d16:	ec06                	sd	ra,24(sp)
ffffffffc0202d18:	e822                	sd	s0,16(sp)
ffffffffc0202d1a:	e426                	sd	s1,8(sp)
ffffffffc0202d1c:	e04a                	sd	s2,0(sp)
	assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0202d1e:	01050713          	addi	a4,a0,16
ffffffffc0202d22:	6785                	lui	a5,0x1
ffffffffc0202d24:	0cf77563          	bgeu	a4,a5,ffffffffc0202dee <slob_alloc.isra.1.constprop.3+0xda>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc0202d28:	00f50493          	addi	s1,a0,15
ffffffffc0202d2c:	8091                	srli	s1,s1,0x4
ffffffffc0202d2e:	2481                	sext.w	s1,s1
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202d30:	10002673          	csrr	a2,sstatus
ffffffffc0202d34:	8a09                	andi	a2,a2,2
ffffffffc0202d36:	e64d                	bnez	a2,ffffffffc0202de0 <slob_alloc.isra.1.constprop.3+0xcc>
	prev = slobfree;
ffffffffc0202d38:	00007917          	auipc	s2,0x7
ffffffffc0202d3c:	31890913          	addi	s2,s2,792 # ffffffffc020a050 <slobfree>
ffffffffc0202d40:	00093683          	ld	a3,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0202d44:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0202d46:	4398                	lw	a4,0(a5)
ffffffffc0202d48:	0a975063          	bge	a4,s1,ffffffffc0202de8 <slob_alloc.isra.1.constprop.3+0xd4>
		if (cur == slobfree) {
ffffffffc0202d4c:	00d78b63          	beq	a5,a3,ffffffffc0202d62 <slob_alloc.isra.1.constprop.3+0x4e>
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0202d50:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0202d52:	4018                	lw	a4,0(s0)
ffffffffc0202d54:	02975a63          	bge	a4,s1,ffffffffc0202d88 <slob_alloc.isra.1.constprop.3+0x74>
ffffffffc0202d58:	00093683          	ld	a3,0(s2)
ffffffffc0202d5c:	87a2                	mv	a5,s0
		if (cur == slobfree) {
ffffffffc0202d5e:	fed799e3          	bne	a5,a3,ffffffffc0202d50 <slob_alloc.isra.1.constprop.3+0x3c>
    if (flag) {
ffffffffc0202d62:	e225                	bnez	a2,ffffffffc0202dc2 <slob_alloc.isra.1.constprop.3+0xae>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0202d64:	4501                	li	a0,0
ffffffffc0202d66:	f43ff0ef          	jal	ra,ffffffffc0202ca8 <__slob_get_free_pages.isra.0>
ffffffffc0202d6a:	842a                	mv	s0,a0
			if (!cur)
ffffffffc0202d6c:	cd15                	beqz	a0,ffffffffc0202da8 <slob_alloc.isra.1.constprop.3+0x94>
			slob_free(cur, PAGE_SIZE);
ffffffffc0202d6e:	6585                	lui	a1,0x1
ffffffffc0202d70:	e23ff0ef          	jal	ra,ffffffffc0202b92 <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202d74:	10002673          	csrr	a2,sstatus
ffffffffc0202d78:	8a09                	andi	a2,a2,2
ffffffffc0202d7a:	ee15                	bnez	a2,ffffffffc0202db6 <slob_alloc.isra.1.constprop.3+0xa2>
			cur = slobfree;
ffffffffc0202d7c:	00093783          	ld	a5,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0202d80:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0202d82:	4018                	lw	a4,0(s0)
ffffffffc0202d84:	fc974ae3          	blt	a4,s1,ffffffffc0202d58 <slob_alloc.isra.1.constprop.3+0x44>
			if (cur->units == units) /* exact fit? */
ffffffffc0202d88:	04e48963          	beq	s1,a4,ffffffffc0202dda <slob_alloc.isra.1.constprop.3+0xc6>
				prev->next = cur + units;
ffffffffc0202d8c:	00449693          	slli	a3,s1,0x4
ffffffffc0202d90:	96a2                	add	a3,a3,s0
ffffffffc0202d92:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc0202d94:	640c                	ld	a1,8(s0)
				prev->next->units = cur->units - units;
ffffffffc0202d96:	9f05                	subw	a4,a4,s1
ffffffffc0202d98:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc0202d9a:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc0202d9c:	c004                	sw	s1,0(s0)
			slobfree = prev;
ffffffffc0202d9e:	00007717          	auipc	a4,0x7
ffffffffc0202da2:	2af73923          	sd	a5,690(a4) # ffffffffc020a050 <slobfree>
    if (flag) {
ffffffffc0202da6:	e20d                	bnez	a2,ffffffffc0202dc8 <slob_alloc.isra.1.constprop.3+0xb4>
}
ffffffffc0202da8:	8522                	mv	a0,s0
ffffffffc0202daa:	60e2                	ld	ra,24(sp)
ffffffffc0202dac:	6442                	ld	s0,16(sp)
ffffffffc0202dae:	64a2                	ld	s1,8(sp)
ffffffffc0202db0:	6902                	ld	s2,0(sp)
ffffffffc0202db2:	6105                	addi	sp,sp,32
ffffffffc0202db4:	8082                	ret
        intr_disable();
ffffffffc0202db6:	ff8fd0ef          	jal	ra,ffffffffc02005ae <intr_disable>
ffffffffc0202dba:	4605                	li	a2,1
			cur = slobfree;
ffffffffc0202dbc:	00093783          	ld	a5,0(s2)
ffffffffc0202dc0:	b7c1                	j	ffffffffc0202d80 <slob_alloc.isra.1.constprop.3+0x6c>
        intr_enable();
ffffffffc0202dc2:	fe6fd0ef          	jal	ra,ffffffffc02005a8 <intr_enable>
ffffffffc0202dc6:	bf79                	j	ffffffffc0202d64 <slob_alloc.isra.1.constprop.3+0x50>
ffffffffc0202dc8:	fe0fd0ef          	jal	ra,ffffffffc02005a8 <intr_enable>
}
ffffffffc0202dcc:	8522                	mv	a0,s0
ffffffffc0202dce:	60e2                	ld	ra,24(sp)
ffffffffc0202dd0:	6442                	ld	s0,16(sp)
ffffffffc0202dd2:	64a2                	ld	s1,8(sp)
ffffffffc0202dd4:	6902                	ld	s2,0(sp)
ffffffffc0202dd6:	6105                	addi	sp,sp,32
ffffffffc0202dd8:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc0202dda:	6418                	ld	a4,8(s0)
ffffffffc0202ddc:	e798                	sd	a4,8(a5)
ffffffffc0202dde:	b7c1                	j	ffffffffc0202d9e <slob_alloc.isra.1.constprop.3+0x8a>
        intr_disable();
ffffffffc0202de0:	fcefd0ef          	jal	ra,ffffffffc02005ae <intr_disable>
ffffffffc0202de4:	4605                	li	a2,1
ffffffffc0202de6:	bf89                	j	ffffffffc0202d38 <slob_alloc.isra.1.constprop.3+0x24>
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0202de8:	843e                	mv	s0,a5
ffffffffc0202dea:	87b6                	mv	a5,a3
ffffffffc0202dec:	bf71                	j	ffffffffc0202d88 <slob_alloc.isra.1.constprop.3+0x74>
	assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0202dee:	00003697          	auipc	a3,0x3
ffffffffc0202df2:	2aa68693          	addi	a3,a3,682 # ffffffffc0206098 <commands+0x1530>
ffffffffc0202df6:	00002617          	auipc	a2,0x2
ffffffffc0202dfa:	70a60613          	addi	a2,a2,1802 # ffffffffc0205500 <commands+0x998>
ffffffffc0202dfe:	06300593          	li	a1,99
ffffffffc0202e02:	00003517          	auipc	a0,0x3
ffffffffc0202e06:	2b650513          	addi	a0,a0,694 # ffffffffc02060b8 <commands+0x1550>
ffffffffc0202e0a:	bcafd0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc0202e0e <kmalloc_init>:
slob_init(void) {
  cprintf("use SLOB allocator\n");
}

inline void 
kmalloc_init(void) {
ffffffffc0202e0e:	1141                	addi	sp,sp,-16
  cprintf("use SLOB allocator\n");
ffffffffc0202e10:	00003517          	auipc	a0,0x3
ffffffffc0202e14:	2c050513          	addi	a0,a0,704 # ffffffffc02060d0 <commands+0x1568>
kmalloc_init(void) {
ffffffffc0202e18:	e406                	sd	ra,8(sp)
  cprintf("use SLOB allocator\n");
ffffffffc0202e1a:	ab6fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    slob_init();
    cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc0202e1e:	60a2                	ld	ra,8(sp)
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0202e20:	00003517          	auipc	a0,0x3
ffffffffc0202e24:	25850513          	addi	a0,a0,600 # ffffffffc0206078 <commands+0x1510>
}
ffffffffc0202e28:	0141                	addi	sp,sp,16
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0202e2a:	aa6fd06f          	j	ffffffffc02000d0 <cprintf>

ffffffffc0202e2e <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc0202e2e:	1101                	addi	sp,sp,-32
ffffffffc0202e30:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0202e32:	6905                	lui	s2,0x1
{
ffffffffc0202e34:	e822                	sd	s0,16(sp)
ffffffffc0202e36:	ec06                	sd	ra,24(sp)
ffffffffc0202e38:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0202e3a:	fef90793          	addi	a5,s2,-17 # fef <BASE_ADDRESS-0xffffffffc01ff011>
{
ffffffffc0202e3e:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0202e40:	04a7fc63          	bgeu	a5,a0,ffffffffc0202e98 <kmalloc+0x6a>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc0202e44:	4561                	li	a0,24
ffffffffc0202e46:	ecfff0ef          	jal	ra,ffffffffc0202d14 <slob_alloc.isra.1.constprop.3>
ffffffffc0202e4a:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc0202e4c:	cd21                	beqz	a0,ffffffffc0202ea4 <kmalloc+0x76>
	bb->order = find_order(size);
ffffffffc0202e4e:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc0202e52:	4501                	li	a0,0
	for ( ; size > 4096 ; size >>=1)
ffffffffc0202e54:	00f95763          	bge	s2,a5,ffffffffc0202e62 <kmalloc+0x34>
ffffffffc0202e58:	6705                	lui	a4,0x1
ffffffffc0202e5a:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc0202e5c:	2505                	addiw	a0,a0,1
	for ( ; size > 4096 ; size >>=1)
ffffffffc0202e5e:	fef74ee3          	blt	a4,a5,ffffffffc0202e5a <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc0202e62:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc0202e64:	e45ff0ef          	jal	ra,ffffffffc0202ca8 <__slob_get_free_pages.isra.0>
ffffffffc0202e68:	e488                	sd	a0,8(s1)
ffffffffc0202e6a:	842a                	mv	s0,a0
	if (bb->pages) {
ffffffffc0202e6c:	c935                	beqz	a0,ffffffffc0202ee0 <kmalloc+0xb2>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202e6e:	100027f3          	csrr	a5,sstatus
ffffffffc0202e72:	8b89                	andi	a5,a5,2
ffffffffc0202e74:	e3a1                	bnez	a5,ffffffffc0202eb4 <kmalloc+0x86>
		bb->next = bigblocks;
ffffffffc0202e76:	00012797          	auipc	a5,0x12
ffffffffc0202e7a:	62a78793          	addi	a5,a5,1578 # ffffffffc02154a0 <bigblocks>
ffffffffc0202e7e:	639c                	ld	a5,0(a5)
		bigblocks = bb;
ffffffffc0202e80:	00012717          	auipc	a4,0x12
ffffffffc0202e84:	62973023          	sd	s1,1568(a4) # ffffffffc02154a0 <bigblocks>
		bb->next = bigblocks;
ffffffffc0202e88:	e89c                	sd	a5,16(s1)
  return __kmalloc(size, 0);
}
ffffffffc0202e8a:	8522                	mv	a0,s0
ffffffffc0202e8c:	60e2                	ld	ra,24(sp)
ffffffffc0202e8e:	6442                	ld	s0,16(sp)
ffffffffc0202e90:	64a2                	ld	s1,8(sp)
ffffffffc0202e92:	6902                	ld	s2,0(sp)
ffffffffc0202e94:	6105                	addi	sp,sp,32
ffffffffc0202e96:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc0202e98:	0541                	addi	a0,a0,16
ffffffffc0202e9a:	e7bff0ef          	jal	ra,ffffffffc0202d14 <slob_alloc.isra.1.constprop.3>
		return m ? (void *)(m + 1) : 0;
ffffffffc0202e9e:	01050413          	addi	s0,a0,16
ffffffffc0202ea2:	f565                	bnez	a0,ffffffffc0202e8a <kmalloc+0x5c>
ffffffffc0202ea4:	4401                	li	s0,0
}
ffffffffc0202ea6:	8522                	mv	a0,s0
ffffffffc0202ea8:	60e2                	ld	ra,24(sp)
ffffffffc0202eaa:	6442                	ld	s0,16(sp)
ffffffffc0202eac:	64a2                	ld	s1,8(sp)
ffffffffc0202eae:	6902                	ld	s2,0(sp)
ffffffffc0202eb0:	6105                	addi	sp,sp,32
ffffffffc0202eb2:	8082                	ret
        intr_disable();
ffffffffc0202eb4:	efafd0ef          	jal	ra,ffffffffc02005ae <intr_disable>
		bb->next = bigblocks;
ffffffffc0202eb8:	00012797          	auipc	a5,0x12
ffffffffc0202ebc:	5e878793          	addi	a5,a5,1512 # ffffffffc02154a0 <bigblocks>
ffffffffc0202ec0:	639c                	ld	a5,0(a5)
		bigblocks = bb;
ffffffffc0202ec2:	00012717          	auipc	a4,0x12
ffffffffc0202ec6:	5c973f23          	sd	s1,1502(a4) # ffffffffc02154a0 <bigblocks>
		bb->next = bigblocks;
ffffffffc0202eca:	e89c                	sd	a5,16(s1)
        intr_enable();
ffffffffc0202ecc:	edcfd0ef          	jal	ra,ffffffffc02005a8 <intr_enable>
ffffffffc0202ed0:	6480                	ld	s0,8(s1)
}
ffffffffc0202ed2:	60e2                	ld	ra,24(sp)
ffffffffc0202ed4:	64a2                	ld	s1,8(sp)
ffffffffc0202ed6:	8522                	mv	a0,s0
ffffffffc0202ed8:	6442                	ld	s0,16(sp)
ffffffffc0202eda:	6902                	ld	s2,0(sp)
ffffffffc0202edc:	6105                	addi	sp,sp,32
ffffffffc0202ede:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0202ee0:	45e1                	li	a1,24
ffffffffc0202ee2:	8526                	mv	a0,s1
ffffffffc0202ee4:	cafff0ef          	jal	ra,ffffffffc0202b92 <slob_free>
  return __kmalloc(size, 0);
ffffffffc0202ee8:	b74d                	j	ffffffffc0202e8a <kmalloc+0x5c>

ffffffffc0202eea <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc0202eea:	c175                	beqz	a0,ffffffffc0202fce <kfree+0xe4>
{
ffffffffc0202eec:	1101                	addi	sp,sp,-32
ffffffffc0202eee:	e426                	sd	s1,8(sp)
ffffffffc0202ef0:	ec06                	sd	ra,24(sp)
ffffffffc0202ef2:	e822                	sd	s0,16(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
ffffffffc0202ef4:	03451793          	slli	a5,a0,0x34
ffffffffc0202ef8:	84aa                	mv	s1,a0
ffffffffc0202efa:	eb8d                	bnez	a5,ffffffffc0202f2c <kfree+0x42>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202efc:	100027f3          	csrr	a5,sstatus
ffffffffc0202f00:	8b89                	andi	a5,a5,2
ffffffffc0202f02:	efc9                	bnez	a5,ffffffffc0202f9c <kfree+0xb2>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0202f04:	00012797          	auipc	a5,0x12
ffffffffc0202f08:	59c78793          	addi	a5,a5,1436 # ffffffffc02154a0 <bigblocks>
ffffffffc0202f0c:	6394                	ld	a3,0(a5)
ffffffffc0202f0e:	ce99                	beqz	a3,ffffffffc0202f2c <kfree+0x42>
			if (bb->pages == block) {
ffffffffc0202f10:	669c                	ld	a5,8(a3)
ffffffffc0202f12:	6a80                	ld	s0,16(a3)
ffffffffc0202f14:	0af50e63          	beq	a0,a5,ffffffffc0202fd0 <kfree+0xe6>
    return 0;
ffffffffc0202f18:	4601                	li	a2,0
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0202f1a:	c801                	beqz	s0,ffffffffc0202f2a <kfree+0x40>
			if (bb->pages == block) {
ffffffffc0202f1c:	6418                	ld	a4,8(s0)
ffffffffc0202f1e:	681c                	ld	a5,16(s0)
ffffffffc0202f20:	00970f63          	beq	a4,s1,ffffffffc0202f3e <kfree+0x54>
ffffffffc0202f24:	86a2                	mv	a3,s0
ffffffffc0202f26:	843e                	mv	s0,a5
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0202f28:	f875                	bnez	s0,ffffffffc0202f1c <kfree+0x32>
    if (flag) {
ffffffffc0202f2a:	e659                	bnez	a2,ffffffffc0202fb8 <kfree+0xce>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc0202f2c:	6442                	ld	s0,16(sp)
ffffffffc0202f2e:	60e2                	ld	ra,24(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0202f30:	ff048513          	addi	a0,s1,-16
}
ffffffffc0202f34:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0202f36:	4581                	li	a1,0
}
ffffffffc0202f38:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0202f3a:	c59ff06f          	j	ffffffffc0202b92 <slob_free>
				*last = bb->next;
ffffffffc0202f3e:	ea9c                	sd	a5,16(a3)
ffffffffc0202f40:	e641                	bnez	a2,ffffffffc0202fc8 <kfree+0xde>
    return pa2page(PADDR(kva));
ffffffffc0202f42:	c02007b7          	lui	a5,0xc0200
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc0202f46:	4018                	lw	a4,0(s0)
ffffffffc0202f48:	08f4ea63          	bltu	s1,a5,ffffffffc0202fdc <kfree+0xf2>
ffffffffc0202f4c:	00012797          	auipc	a5,0x12
ffffffffc0202f50:	58c78793          	addi	a5,a5,1420 # ffffffffc02154d8 <va_pa_offset>
ffffffffc0202f54:	6394                	ld	a3,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0202f56:	00012797          	auipc	a5,0x12
ffffffffc0202f5a:	52a78793          	addi	a5,a5,1322 # ffffffffc0215480 <npage>
ffffffffc0202f5e:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc0202f60:	8c95                	sub	s1,s1,a3
    if (PPN(pa) >= npage) {
ffffffffc0202f62:	80b1                	srli	s1,s1,0xc
ffffffffc0202f64:	08f4f963          	bgeu	s1,a5,ffffffffc0202ff6 <kfree+0x10c>
    return &pages[PPN(pa) - nbase];
ffffffffc0202f68:	00004797          	auipc	a5,0x4
ffffffffc0202f6c:	ad078793          	addi	a5,a5,-1328 # ffffffffc0206a38 <nbase>
ffffffffc0202f70:	639c                	ld	a5,0(a5)
ffffffffc0202f72:	00012697          	auipc	a3,0x12
ffffffffc0202f76:	57668693          	addi	a3,a3,1398 # ffffffffc02154e8 <pages>
ffffffffc0202f7a:	6288                	ld	a0,0(a3)
ffffffffc0202f7c:	8c9d                	sub	s1,s1,a5
ffffffffc0202f7e:	049a                	slli	s1,s1,0x6
  free_pages(kva2page(kva), 1 << order);
ffffffffc0202f80:	4585                	li	a1,1
ffffffffc0202f82:	9526                	add	a0,a0,s1
ffffffffc0202f84:	00e595bb          	sllw	a1,a1,a4
ffffffffc0202f88:	c83fd0ef          	jal	ra,ffffffffc0200c0a <free_pages>
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0202f8c:	8522                	mv	a0,s0
}
ffffffffc0202f8e:	6442                	ld	s0,16(sp)
ffffffffc0202f90:	60e2                	ld	ra,24(sp)
ffffffffc0202f92:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0202f94:	45e1                	li	a1,24
}
ffffffffc0202f96:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0202f98:	bfbff06f          	j	ffffffffc0202b92 <slob_free>
        intr_disable();
ffffffffc0202f9c:	e12fd0ef          	jal	ra,ffffffffc02005ae <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0202fa0:	00012797          	auipc	a5,0x12
ffffffffc0202fa4:	50078793          	addi	a5,a5,1280 # ffffffffc02154a0 <bigblocks>
ffffffffc0202fa8:	6394                	ld	a3,0(a5)
ffffffffc0202faa:	c699                	beqz	a3,ffffffffc0202fb8 <kfree+0xce>
			if (bb->pages == block) {
ffffffffc0202fac:	669c                	ld	a5,8(a3)
ffffffffc0202fae:	6a80                	ld	s0,16(a3)
ffffffffc0202fb0:	00f48763          	beq	s1,a5,ffffffffc0202fbe <kfree+0xd4>
        return 1;
ffffffffc0202fb4:	4605                	li	a2,1
ffffffffc0202fb6:	b795                	j	ffffffffc0202f1a <kfree+0x30>
        intr_enable();
ffffffffc0202fb8:	df0fd0ef          	jal	ra,ffffffffc02005a8 <intr_enable>
ffffffffc0202fbc:	bf85                	j	ffffffffc0202f2c <kfree+0x42>
				*last = bb->next;
ffffffffc0202fbe:	00012797          	auipc	a5,0x12
ffffffffc0202fc2:	4e87b123          	sd	s0,1250(a5) # ffffffffc02154a0 <bigblocks>
ffffffffc0202fc6:	8436                	mv	s0,a3
ffffffffc0202fc8:	de0fd0ef          	jal	ra,ffffffffc02005a8 <intr_enable>
ffffffffc0202fcc:	bf9d                	j	ffffffffc0202f42 <kfree+0x58>
ffffffffc0202fce:	8082                	ret
ffffffffc0202fd0:	00012797          	auipc	a5,0x12
ffffffffc0202fd4:	4c87b823          	sd	s0,1232(a5) # ffffffffc02154a0 <bigblocks>
ffffffffc0202fd8:	8436                	mv	s0,a3
ffffffffc0202fda:	b7a5                	j	ffffffffc0202f42 <kfree+0x58>
    return pa2page(PADDR(kva));
ffffffffc0202fdc:	86a6                	mv	a3,s1
ffffffffc0202fde:	00002617          	auipc	a2,0x2
ffffffffc0202fe2:	4a260613          	addi	a2,a2,1186 # ffffffffc0205480 <commands+0x918>
ffffffffc0202fe6:	06e00593          	li	a1,110
ffffffffc0202fea:	00002517          	auipc	a0,0x2
ffffffffc0202fee:	41650513          	addi	a0,a0,1046 # ffffffffc0205400 <commands+0x898>
ffffffffc0202ff2:	9e2fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0202ff6:	00002617          	auipc	a2,0x2
ffffffffc0202ffa:	3ea60613          	addi	a2,a2,1002 # ffffffffc02053e0 <commands+0x878>
ffffffffc0202ffe:	06200593          	li	a1,98
ffffffffc0203002:	00002517          	auipc	a0,0x2
ffffffffc0203006:	3fe50513          	addi	a0,a0,1022 # ffffffffc0205400 <commands+0x898>
ffffffffc020300a:	9cafd0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc020300e <_fifo_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc020300e:	00012797          	auipc	a5,0x12
ffffffffc0203012:	5b278793          	addi	a5,a5,1458 # ffffffffc02155c0 <pra_list_head>
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
ffffffffc0203016:	f51c                	sd	a5,40(a0)
ffffffffc0203018:	e79c                	sd	a5,8(a5)
ffffffffc020301a:	e39c                	sd	a5,0(a5)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc020301c:	4501                	li	a0,0
ffffffffc020301e:	8082                	ret

ffffffffc0203020 <_fifo_init>:

static int
_fifo_init(void)
{
    return 0;
}
ffffffffc0203020:	4501                	li	a0,0
ffffffffc0203022:	8082                	ret

ffffffffc0203024 <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc0203024:	4501                	li	a0,0
ffffffffc0203026:	8082                	ret

ffffffffc0203028 <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc0203028:	4501                	li	a0,0
ffffffffc020302a:	8082                	ret

ffffffffc020302c <_fifo_check_swap>:
_fifo_check_swap(void) {
ffffffffc020302c:	711d                	addi	sp,sp,-96
ffffffffc020302e:	fc4e                	sd	s3,56(sp)
ffffffffc0203030:	f852                	sd	s4,48(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203032:	00003517          	auipc	a0,0x3
ffffffffc0203036:	0b650513          	addi	a0,a0,182 # ffffffffc02060e8 <commands+0x1580>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc020303a:	698d                	lui	s3,0x3
ffffffffc020303c:	4a31                	li	s4,12
_fifo_check_swap(void) {
ffffffffc020303e:	e8a2                	sd	s0,80(sp)
ffffffffc0203040:	e4a6                	sd	s1,72(sp)
ffffffffc0203042:	ec86                	sd	ra,88(sp)
ffffffffc0203044:	e0ca                	sd	s2,64(sp)
ffffffffc0203046:	f456                	sd	s5,40(sp)
ffffffffc0203048:	f05a                	sd	s6,32(sp)
ffffffffc020304a:	ec5e                	sd	s7,24(sp)
ffffffffc020304c:	e862                	sd	s8,16(sp)
ffffffffc020304e:	e466                	sd	s9,8(sp)
    assert(pgfault_num==4);
ffffffffc0203050:	00012417          	auipc	s0,0x12
ffffffffc0203054:	43840413          	addi	s0,s0,1080 # ffffffffc0215488 <pgfault_num>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203058:	878fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc020305c:	01498023          	sb	s4,0(s3) # 3000 <BASE_ADDRESS-0xffffffffc01fd000>
    assert(pgfault_num==4);
ffffffffc0203060:	4004                	lw	s1,0(s0)
ffffffffc0203062:	4791                	li	a5,4
ffffffffc0203064:	2481                	sext.w	s1,s1
ffffffffc0203066:	14f49963          	bne	s1,a5,ffffffffc02031b8 <_fifo_check_swap+0x18c>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc020306a:	00003517          	auipc	a0,0x3
ffffffffc020306e:	0be50513          	addi	a0,a0,190 # ffffffffc0206128 <commands+0x15c0>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203072:	6a85                	lui	s5,0x1
ffffffffc0203074:	4b29                	li	s6,10
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203076:	85afd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc020307a:	016a8023          	sb	s6,0(s5) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
    assert(pgfault_num==4);
ffffffffc020307e:	00042903          	lw	s2,0(s0)
ffffffffc0203082:	2901                	sext.w	s2,s2
ffffffffc0203084:	2a991a63          	bne	s2,s1,ffffffffc0203338 <_fifo_check_swap+0x30c>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203088:	00003517          	auipc	a0,0x3
ffffffffc020308c:	0c850513          	addi	a0,a0,200 # ffffffffc0206150 <commands+0x15e8>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203090:	6b91                	lui	s7,0x4
ffffffffc0203092:	4c35                	li	s8,13
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203094:	83cfd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203098:	018b8023          	sb	s8,0(s7) # 4000 <BASE_ADDRESS-0xffffffffc01fc000>
    assert(pgfault_num==4);
ffffffffc020309c:	4004                	lw	s1,0(s0)
ffffffffc020309e:	2481                	sext.w	s1,s1
ffffffffc02030a0:	27249c63          	bne	s1,s2,ffffffffc0203318 <_fifo_check_swap+0x2ec>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc02030a4:	00003517          	auipc	a0,0x3
ffffffffc02030a8:	0d450513          	addi	a0,a0,212 # ffffffffc0206178 <commands+0x1610>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc02030ac:	6909                	lui	s2,0x2
ffffffffc02030ae:	4cad                	li	s9,11
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc02030b0:	820fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc02030b4:	01990023          	sb	s9,0(s2) # 2000 <BASE_ADDRESS-0xffffffffc01fe000>
    assert(pgfault_num==4);
ffffffffc02030b8:	401c                	lw	a5,0(s0)
ffffffffc02030ba:	2781                	sext.w	a5,a5
ffffffffc02030bc:	22979e63          	bne	a5,s1,ffffffffc02032f8 <_fifo_check_swap+0x2cc>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc02030c0:	00003517          	auipc	a0,0x3
ffffffffc02030c4:	0e050513          	addi	a0,a0,224 # ffffffffc02061a0 <commands+0x1638>
ffffffffc02030c8:	808fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc02030cc:	6795                	lui	a5,0x5
ffffffffc02030ce:	4739                	li	a4,14
ffffffffc02030d0:	00e78023          	sb	a4,0(a5) # 5000 <BASE_ADDRESS-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc02030d4:	4004                	lw	s1,0(s0)
ffffffffc02030d6:	4795                	li	a5,5
ffffffffc02030d8:	2481                	sext.w	s1,s1
ffffffffc02030da:	1ef49f63          	bne	s1,a5,ffffffffc02032d8 <_fifo_check_swap+0x2ac>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc02030de:	00003517          	auipc	a0,0x3
ffffffffc02030e2:	09a50513          	addi	a0,a0,154 # ffffffffc0206178 <commands+0x1610>
ffffffffc02030e6:	febfc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc02030ea:	01990023          	sb	s9,0(s2)
    assert(pgfault_num==5);
ffffffffc02030ee:	401c                	lw	a5,0(s0)
ffffffffc02030f0:	2781                	sext.w	a5,a5
ffffffffc02030f2:	1c979363          	bne	a5,s1,ffffffffc02032b8 <_fifo_check_swap+0x28c>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc02030f6:	00003517          	auipc	a0,0x3
ffffffffc02030fa:	03250513          	addi	a0,a0,50 # ffffffffc0206128 <commands+0x15c0>
ffffffffc02030fe:	fd3fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203102:	016a8023          	sb	s6,0(s5)
    assert(pgfault_num==6);
ffffffffc0203106:	401c                	lw	a5,0(s0)
ffffffffc0203108:	4719                	li	a4,6
ffffffffc020310a:	2781                	sext.w	a5,a5
ffffffffc020310c:	18e79663          	bne	a5,a4,ffffffffc0203298 <_fifo_check_swap+0x26c>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203110:	00003517          	auipc	a0,0x3
ffffffffc0203114:	06850513          	addi	a0,a0,104 # ffffffffc0206178 <commands+0x1610>
ffffffffc0203118:	fb9fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc020311c:	01990023          	sb	s9,0(s2)
    assert(pgfault_num==7);
ffffffffc0203120:	401c                	lw	a5,0(s0)
ffffffffc0203122:	471d                	li	a4,7
ffffffffc0203124:	2781                	sext.w	a5,a5
ffffffffc0203126:	14e79963          	bne	a5,a4,ffffffffc0203278 <_fifo_check_swap+0x24c>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc020312a:	00003517          	auipc	a0,0x3
ffffffffc020312e:	fbe50513          	addi	a0,a0,-66 # ffffffffc02060e8 <commands+0x1580>
ffffffffc0203132:	f9ffc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203136:	01498023          	sb	s4,0(s3)
    assert(pgfault_num==8);
ffffffffc020313a:	401c                	lw	a5,0(s0)
ffffffffc020313c:	4721                	li	a4,8
ffffffffc020313e:	2781                	sext.w	a5,a5
ffffffffc0203140:	10e79c63          	bne	a5,a4,ffffffffc0203258 <_fifo_check_swap+0x22c>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203144:	00003517          	auipc	a0,0x3
ffffffffc0203148:	00c50513          	addi	a0,a0,12 # ffffffffc0206150 <commands+0x15e8>
ffffffffc020314c:	f85fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203150:	018b8023          	sb	s8,0(s7)
    assert(pgfault_num==9);
ffffffffc0203154:	401c                	lw	a5,0(s0)
ffffffffc0203156:	4725                	li	a4,9
ffffffffc0203158:	2781                	sext.w	a5,a5
ffffffffc020315a:	0ce79f63          	bne	a5,a4,ffffffffc0203238 <_fifo_check_swap+0x20c>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc020315e:	00003517          	auipc	a0,0x3
ffffffffc0203162:	04250513          	addi	a0,a0,66 # ffffffffc02061a0 <commands+0x1638>
ffffffffc0203166:	f6bfc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc020316a:	6795                	lui	a5,0x5
ffffffffc020316c:	4739                	li	a4,14
ffffffffc020316e:	00e78023          	sb	a4,0(a5) # 5000 <BASE_ADDRESS-0xffffffffc01fb000>
    assert(pgfault_num==10);
ffffffffc0203172:	4004                	lw	s1,0(s0)
ffffffffc0203174:	47a9                	li	a5,10
ffffffffc0203176:	2481                	sext.w	s1,s1
ffffffffc0203178:	0af49063          	bne	s1,a5,ffffffffc0203218 <_fifo_check_swap+0x1ec>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc020317c:	00003517          	auipc	a0,0x3
ffffffffc0203180:	fac50513          	addi	a0,a0,-84 # ffffffffc0206128 <commands+0x15c0>
ffffffffc0203184:	f4dfc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203188:	6785                	lui	a5,0x1
ffffffffc020318a:	0007c783          	lbu	a5,0(a5) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
ffffffffc020318e:	06979563          	bne	a5,s1,ffffffffc02031f8 <_fifo_check_swap+0x1cc>
    assert(pgfault_num==11);
ffffffffc0203192:	401c                	lw	a5,0(s0)
ffffffffc0203194:	472d                	li	a4,11
ffffffffc0203196:	2781                	sext.w	a5,a5
ffffffffc0203198:	04e79063          	bne	a5,a4,ffffffffc02031d8 <_fifo_check_swap+0x1ac>
}
ffffffffc020319c:	60e6                	ld	ra,88(sp)
ffffffffc020319e:	6446                	ld	s0,80(sp)
ffffffffc02031a0:	64a6                	ld	s1,72(sp)
ffffffffc02031a2:	6906                	ld	s2,64(sp)
ffffffffc02031a4:	79e2                	ld	s3,56(sp)
ffffffffc02031a6:	7a42                	ld	s4,48(sp)
ffffffffc02031a8:	7aa2                	ld	s5,40(sp)
ffffffffc02031aa:	7b02                	ld	s6,32(sp)
ffffffffc02031ac:	6be2                	ld	s7,24(sp)
ffffffffc02031ae:	6c42                	ld	s8,16(sp)
ffffffffc02031b0:	6ca2                	ld	s9,8(sp)
ffffffffc02031b2:	4501                	li	a0,0
ffffffffc02031b4:	6125                	addi	sp,sp,96
ffffffffc02031b6:	8082                	ret
    assert(pgfault_num==4);
ffffffffc02031b8:	00003697          	auipc	a3,0x3
ffffffffc02031bc:	d5068693          	addi	a3,a3,-688 # ffffffffc0205f08 <commands+0x13a0>
ffffffffc02031c0:	00002617          	auipc	a2,0x2
ffffffffc02031c4:	34060613          	addi	a2,a2,832 # ffffffffc0205500 <commands+0x998>
ffffffffc02031c8:	05100593          	li	a1,81
ffffffffc02031cc:	00003517          	auipc	a0,0x3
ffffffffc02031d0:	f4450513          	addi	a0,a0,-188 # ffffffffc0206110 <commands+0x15a8>
ffffffffc02031d4:	800fd0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(pgfault_num==11);
ffffffffc02031d8:	00003697          	auipc	a3,0x3
ffffffffc02031dc:	07868693          	addi	a3,a3,120 # ffffffffc0206250 <commands+0x16e8>
ffffffffc02031e0:	00002617          	auipc	a2,0x2
ffffffffc02031e4:	32060613          	addi	a2,a2,800 # ffffffffc0205500 <commands+0x998>
ffffffffc02031e8:	07300593          	li	a1,115
ffffffffc02031ec:	00003517          	auipc	a0,0x3
ffffffffc02031f0:	f2450513          	addi	a0,a0,-220 # ffffffffc0206110 <commands+0x15a8>
ffffffffc02031f4:	fe1fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc02031f8:	00003697          	auipc	a3,0x3
ffffffffc02031fc:	03068693          	addi	a3,a3,48 # ffffffffc0206228 <commands+0x16c0>
ffffffffc0203200:	00002617          	auipc	a2,0x2
ffffffffc0203204:	30060613          	addi	a2,a2,768 # ffffffffc0205500 <commands+0x998>
ffffffffc0203208:	07100593          	li	a1,113
ffffffffc020320c:	00003517          	auipc	a0,0x3
ffffffffc0203210:	f0450513          	addi	a0,a0,-252 # ffffffffc0206110 <commands+0x15a8>
ffffffffc0203214:	fc1fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(pgfault_num==10);
ffffffffc0203218:	00003697          	auipc	a3,0x3
ffffffffc020321c:	00068693          	mv	a3,a3
ffffffffc0203220:	00002617          	auipc	a2,0x2
ffffffffc0203224:	2e060613          	addi	a2,a2,736 # ffffffffc0205500 <commands+0x998>
ffffffffc0203228:	06f00593          	li	a1,111
ffffffffc020322c:	00003517          	auipc	a0,0x3
ffffffffc0203230:	ee450513          	addi	a0,a0,-284 # ffffffffc0206110 <commands+0x15a8>
ffffffffc0203234:	fa1fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(pgfault_num==9);
ffffffffc0203238:	00003697          	auipc	a3,0x3
ffffffffc020323c:	fd068693          	addi	a3,a3,-48 # ffffffffc0206208 <commands+0x16a0>
ffffffffc0203240:	00002617          	auipc	a2,0x2
ffffffffc0203244:	2c060613          	addi	a2,a2,704 # ffffffffc0205500 <commands+0x998>
ffffffffc0203248:	06c00593          	li	a1,108
ffffffffc020324c:	00003517          	auipc	a0,0x3
ffffffffc0203250:	ec450513          	addi	a0,a0,-316 # ffffffffc0206110 <commands+0x15a8>
ffffffffc0203254:	f81fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(pgfault_num==8);
ffffffffc0203258:	00003697          	auipc	a3,0x3
ffffffffc020325c:	fa068693          	addi	a3,a3,-96 # ffffffffc02061f8 <commands+0x1690>
ffffffffc0203260:	00002617          	auipc	a2,0x2
ffffffffc0203264:	2a060613          	addi	a2,a2,672 # ffffffffc0205500 <commands+0x998>
ffffffffc0203268:	06900593          	li	a1,105
ffffffffc020326c:	00003517          	auipc	a0,0x3
ffffffffc0203270:	ea450513          	addi	a0,a0,-348 # ffffffffc0206110 <commands+0x15a8>
ffffffffc0203274:	f61fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(pgfault_num==7);
ffffffffc0203278:	00003697          	auipc	a3,0x3
ffffffffc020327c:	f7068693          	addi	a3,a3,-144 # ffffffffc02061e8 <commands+0x1680>
ffffffffc0203280:	00002617          	auipc	a2,0x2
ffffffffc0203284:	28060613          	addi	a2,a2,640 # ffffffffc0205500 <commands+0x998>
ffffffffc0203288:	06600593          	li	a1,102
ffffffffc020328c:	00003517          	auipc	a0,0x3
ffffffffc0203290:	e8450513          	addi	a0,a0,-380 # ffffffffc0206110 <commands+0x15a8>
ffffffffc0203294:	f41fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(pgfault_num==6);
ffffffffc0203298:	00003697          	auipc	a3,0x3
ffffffffc020329c:	f4068693          	addi	a3,a3,-192 # ffffffffc02061d8 <commands+0x1670>
ffffffffc02032a0:	00002617          	auipc	a2,0x2
ffffffffc02032a4:	26060613          	addi	a2,a2,608 # ffffffffc0205500 <commands+0x998>
ffffffffc02032a8:	06300593          	li	a1,99
ffffffffc02032ac:	00003517          	auipc	a0,0x3
ffffffffc02032b0:	e6450513          	addi	a0,a0,-412 # ffffffffc0206110 <commands+0x15a8>
ffffffffc02032b4:	f21fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(pgfault_num==5);
ffffffffc02032b8:	00003697          	auipc	a3,0x3
ffffffffc02032bc:	f1068693          	addi	a3,a3,-240 # ffffffffc02061c8 <commands+0x1660>
ffffffffc02032c0:	00002617          	auipc	a2,0x2
ffffffffc02032c4:	24060613          	addi	a2,a2,576 # ffffffffc0205500 <commands+0x998>
ffffffffc02032c8:	06000593          	li	a1,96
ffffffffc02032cc:	00003517          	auipc	a0,0x3
ffffffffc02032d0:	e4450513          	addi	a0,a0,-444 # ffffffffc0206110 <commands+0x15a8>
ffffffffc02032d4:	f01fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(pgfault_num==5);
ffffffffc02032d8:	00003697          	auipc	a3,0x3
ffffffffc02032dc:	ef068693          	addi	a3,a3,-272 # ffffffffc02061c8 <commands+0x1660>
ffffffffc02032e0:	00002617          	auipc	a2,0x2
ffffffffc02032e4:	22060613          	addi	a2,a2,544 # ffffffffc0205500 <commands+0x998>
ffffffffc02032e8:	05d00593          	li	a1,93
ffffffffc02032ec:	00003517          	auipc	a0,0x3
ffffffffc02032f0:	e2450513          	addi	a0,a0,-476 # ffffffffc0206110 <commands+0x15a8>
ffffffffc02032f4:	ee1fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(pgfault_num==4);
ffffffffc02032f8:	00003697          	auipc	a3,0x3
ffffffffc02032fc:	c1068693          	addi	a3,a3,-1008 # ffffffffc0205f08 <commands+0x13a0>
ffffffffc0203300:	00002617          	auipc	a2,0x2
ffffffffc0203304:	20060613          	addi	a2,a2,512 # ffffffffc0205500 <commands+0x998>
ffffffffc0203308:	05a00593          	li	a1,90
ffffffffc020330c:	00003517          	auipc	a0,0x3
ffffffffc0203310:	e0450513          	addi	a0,a0,-508 # ffffffffc0206110 <commands+0x15a8>
ffffffffc0203314:	ec1fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(pgfault_num==4);
ffffffffc0203318:	00003697          	auipc	a3,0x3
ffffffffc020331c:	bf068693          	addi	a3,a3,-1040 # ffffffffc0205f08 <commands+0x13a0>
ffffffffc0203320:	00002617          	auipc	a2,0x2
ffffffffc0203324:	1e060613          	addi	a2,a2,480 # ffffffffc0205500 <commands+0x998>
ffffffffc0203328:	05700593          	li	a1,87
ffffffffc020332c:	00003517          	auipc	a0,0x3
ffffffffc0203330:	de450513          	addi	a0,a0,-540 # ffffffffc0206110 <commands+0x15a8>
ffffffffc0203334:	ea1fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(pgfault_num==4);
ffffffffc0203338:	00003697          	auipc	a3,0x3
ffffffffc020333c:	bd068693          	addi	a3,a3,-1072 # ffffffffc0205f08 <commands+0x13a0>
ffffffffc0203340:	00002617          	auipc	a2,0x2
ffffffffc0203344:	1c060613          	addi	a2,a2,448 # ffffffffc0205500 <commands+0x998>
ffffffffc0203348:	05400593          	li	a1,84
ffffffffc020334c:	00003517          	auipc	a0,0x3
ffffffffc0203350:	dc450513          	addi	a0,a0,-572 # ffffffffc0206110 <commands+0x15a8>
ffffffffc0203354:	e81fc0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc0203358 <_fifo_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0203358:	751c                	ld	a5,40(a0)
{
ffffffffc020335a:	1141                	addi	sp,sp,-16
ffffffffc020335c:	e406                	sd	ra,8(sp)
         assert(head != NULL);
ffffffffc020335e:	cf91                	beqz	a5,ffffffffc020337a <_fifo_swap_out_victim+0x22>
     assert(in_tick==0);
ffffffffc0203360:	ee0d                	bnez	a2,ffffffffc020339a <_fifo_swap_out_victim+0x42>
    return listelm->next;
ffffffffc0203362:	679c                	ld	a5,8(a5)
}
ffffffffc0203364:	60a2                	ld	ra,8(sp)
ffffffffc0203366:	4501                	li	a0,0
    __list_del(listelm->prev, listelm->next);
ffffffffc0203368:	6394                	ld	a3,0(a5)
ffffffffc020336a:	6798                	ld	a4,8(a5)
    *ptr_page = le2page(entry, pra_page_link);
ffffffffc020336c:	fd878793          	addi	a5,a5,-40
    prev->next = next;
ffffffffc0203370:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc0203372:	e314                	sd	a3,0(a4)
ffffffffc0203374:	e19c                	sd	a5,0(a1)
}
ffffffffc0203376:	0141                	addi	sp,sp,16
ffffffffc0203378:	8082                	ret
         assert(head != NULL);
ffffffffc020337a:	00003697          	auipc	a3,0x3
ffffffffc020337e:	f0668693          	addi	a3,a3,-250 # ffffffffc0206280 <commands+0x1718>
ffffffffc0203382:	00002617          	auipc	a2,0x2
ffffffffc0203386:	17e60613          	addi	a2,a2,382 # ffffffffc0205500 <commands+0x998>
ffffffffc020338a:	04100593          	li	a1,65
ffffffffc020338e:	00003517          	auipc	a0,0x3
ffffffffc0203392:	d8250513          	addi	a0,a0,-638 # ffffffffc0206110 <commands+0x15a8>
ffffffffc0203396:	e3ffc0ef          	jal	ra,ffffffffc02001d4 <__panic>
     assert(in_tick==0);
ffffffffc020339a:	00003697          	auipc	a3,0x3
ffffffffc020339e:	ef668693          	addi	a3,a3,-266 # ffffffffc0206290 <commands+0x1728>
ffffffffc02033a2:	00002617          	auipc	a2,0x2
ffffffffc02033a6:	15e60613          	addi	a2,a2,350 # ffffffffc0205500 <commands+0x998>
ffffffffc02033aa:	04200593          	li	a1,66
ffffffffc02033ae:	00003517          	auipc	a0,0x3
ffffffffc02033b2:	d6250513          	addi	a0,a0,-670 # ffffffffc0206110 <commands+0x15a8>
ffffffffc02033b6:	e1ffc0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc02033ba <_fifo_map_swappable>:
    list_entry_t *entry=&(page->pra_page_link);
ffffffffc02033ba:	02860713          	addi	a4,a2,40
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc02033be:	751c                	ld	a5,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc02033c0:	cb09                	beqz	a4,ffffffffc02033d2 <_fifo_map_swappable+0x18>
ffffffffc02033c2:	cb81                	beqz	a5,ffffffffc02033d2 <_fifo_map_swappable+0x18>
    __list_add(elm, listelm->prev, listelm);
ffffffffc02033c4:	6394                	ld	a3,0(a5)
    prev->next = next->prev = elm;
ffffffffc02033c6:	e398                	sd	a4,0(a5)
}
ffffffffc02033c8:	4501                	li	a0,0
ffffffffc02033ca:	e698                	sd	a4,8(a3)
    elm->next = next;
ffffffffc02033cc:	fa1c                	sd	a5,48(a2)
    elm->prev = prev;
ffffffffc02033ce:	f614                	sd	a3,40(a2)
ffffffffc02033d0:	8082                	ret
{
ffffffffc02033d2:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc02033d4:	00003697          	auipc	a3,0x3
ffffffffc02033d8:	e8c68693          	addi	a3,a3,-372 # ffffffffc0206260 <commands+0x16f8>
ffffffffc02033dc:	00002617          	auipc	a2,0x2
ffffffffc02033e0:	12460613          	addi	a2,a2,292 # ffffffffc0205500 <commands+0x998>
ffffffffc02033e4:	03200593          	li	a1,50
ffffffffc02033e8:	00003517          	auipc	a0,0x3
ffffffffc02033ec:	d2850513          	addi	a0,a0,-728 # ffffffffc0206110 <commands+0x15a8>
{
ffffffffc02033f0:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc02033f2:	de3fc0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc02033f6 <default_init>:
    elm->prev = elm->next = elm;
ffffffffc02033f6:	00012797          	auipc	a5,0x12
ffffffffc02033fa:	1da78793          	addi	a5,a5,474 # ffffffffc02155d0 <free_area>
ffffffffc02033fe:	e79c                	sd	a5,8(a5)
ffffffffc0203400:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0203402:	0007a823          	sw	zero,16(a5)
}
ffffffffc0203406:	8082                	ret

ffffffffc0203408 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0203408:	00012517          	auipc	a0,0x12
ffffffffc020340c:	1d856503          	lwu	a0,472(a0) # ffffffffc02155e0 <free_area+0x10>
ffffffffc0203410:	8082                	ret

ffffffffc0203412 <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0203412:	715d                	addi	sp,sp,-80
ffffffffc0203414:	f84a                	sd	s2,48(sp)
    return listelm->next;
ffffffffc0203416:	00012917          	auipc	s2,0x12
ffffffffc020341a:	1ba90913          	addi	s2,s2,442 # ffffffffc02155d0 <free_area>
ffffffffc020341e:	00893783          	ld	a5,8(s2)
ffffffffc0203422:	e486                	sd	ra,72(sp)
ffffffffc0203424:	e0a2                	sd	s0,64(sp)
ffffffffc0203426:	fc26                	sd	s1,56(sp)
ffffffffc0203428:	f44e                	sd	s3,40(sp)
ffffffffc020342a:	f052                	sd	s4,32(sp)
ffffffffc020342c:	ec56                	sd	s5,24(sp)
ffffffffc020342e:	e85a                	sd	s6,16(sp)
ffffffffc0203430:	e45e                	sd	s7,8(sp)
ffffffffc0203432:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0203434:	31278463          	beq	a5,s2,ffffffffc020373c <default_check+0x32a>
ffffffffc0203438:	ff07b703          	ld	a4,-16(a5)
ffffffffc020343c:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc020343e:	8b05                	andi	a4,a4,1
ffffffffc0203440:	30070263          	beqz	a4,ffffffffc0203744 <default_check+0x332>
    int count = 0, total = 0;
ffffffffc0203444:	4401                	li	s0,0
ffffffffc0203446:	4481                	li	s1,0
ffffffffc0203448:	a031                	j	ffffffffc0203454 <default_check+0x42>
ffffffffc020344a:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc020344e:	8b09                	andi	a4,a4,2
ffffffffc0203450:	2e070a63          	beqz	a4,ffffffffc0203744 <default_check+0x332>
        count ++, total += p->property;
ffffffffc0203454:	ff87a703          	lw	a4,-8(a5)
ffffffffc0203458:	679c                	ld	a5,8(a5)
ffffffffc020345a:	2485                	addiw	s1,s1,1
ffffffffc020345c:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc020345e:	ff2796e3          	bne	a5,s2,ffffffffc020344a <default_check+0x38>
ffffffffc0203462:	89a2                	mv	s3,s0
    }
    assert(total == nr_free_pages());
ffffffffc0203464:	fecfd0ef          	jal	ra,ffffffffc0200c50 <nr_free_pages>
ffffffffc0203468:	73351e63          	bne	a0,s3,ffffffffc0203ba4 <default_check+0x792>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020346c:	4505                	li	a0,1
ffffffffc020346e:	f14fd0ef          	jal	ra,ffffffffc0200b82 <alloc_pages>
ffffffffc0203472:	8a2a                	mv	s4,a0
ffffffffc0203474:	46050863          	beqz	a0,ffffffffc02038e4 <default_check+0x4d2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0203478:	4505                	li	a0,1
ffffffffc020347a:	f08fd0ef          	jal	ra,ffffffffc0200b82 <alloc_pages>
ffffffffc020347e:	89aa                	mv	s3,a0
ffffffffc0203480:	74050263          	beqz	a0,ffffffffc0203bc4 <default_check+0x7b2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0203484:	4505                	li	a0,1
ffffffffc0203486:	efcfd0ef          	jal	ra,ffffffffc0200b82 <alloc_pages>
ffffffffc020348a:	8aaa                	mv	s5,a0
ffffffffc020348c:	4c050c63          	beqz	a0,ffffffffc0203964 <default_check+0x552>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0203490:	2d3a0a63          	beq	s4,s3,ffffffffc0203764 <default_check+0x352>
ffffffffc0203494:	2caa0863          	beq	s4,a0,ffffffffc0203764 <default_check+0x352>
ffffffffc0203498:	2ca98663          	beq	s3,a0,ffffffffc0203764 <default_check+0x352>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc020349c:	000a2783          	lw	a5,0(s4)
ffffffffc02034a0:	2e079263          	bnez	a5,ffffffffc0203784 <default_check+0x372>
ffffffffc02034a4:	0009a783          	lw	a5,0(s3)
ffffffffc02034a8:	2c079e63          	bnez	a5,ffffffffc0203784 <default_check+0x372>
ffffffffc02034ac:	411c                	lw	a5,0(a0)
ffffffffc02034ae:	2c079b63          	bnez	a5,ffffffffc0203784 <default_check+0x372>
    return page - pages + nbase;
ffffffffc02034b2:	00012797          	auipc	a5,0x12
ffffffffc02034b6:	03678793          	addi	a5,a5,54 # ffffffffc02154e8 <pages>
ffffffffc02034ba:	639c                	ld	a5,0(a5)
ffffffffc02034bc:	00003717          	auipc	a4,0x3
ffffffffc02034c0:	57c70713          	addi	a4,a4,1404 # ffffffffc0206a38 <nbase>
ffffffffc02034c4:	6310                	ld	a2,0(a4)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc02034c6:	00012717          	auipc	a4,0x12
ffffffffc02034ca:	fba70713          	addi	a4,a4,-70 # ffffffffc0215480 <npage>
ffffffffc02034ce:	6314                	ld	a3,0(a4)
ffffffffc02034d0:	40fa0733          	sub	a4,s4,a5
ffffffffc02034d4:	8719                	srai	a4,a4,0x6
ffffffffc02034d6:	9732                	add	a4,a4,a2
ffffffffc02034d8:	06b2                	slli	a3,a3,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02034da:	0732                	slli	a4,a4,0xc
ffffffffc02034dc:	2cd77463          	bgeu	a4,a3,ffffffffc02037a4 <default_check+0x392>
    return page - pages + nbase;
ffffffffc02034e0:	40f98733          	sub	a4,s3,a5
ffffffffc02034e4:	8719                	srai	a4,a4,0x6
ffffffffc02034e6:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02034e8:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02034ea:	4ed77d63          	bgeu	a4,a3,ffffffffc02039e4 <default_check+0x5d2>
    return page - pages + nbase;
ffffffffc02034ee:	40f507b3          	sub	a5,a0,a5
ffffffffc02034f2:	8799                	srai	a5,a5,0x6
ffffffffc02034f4:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02034f6:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc02034f8:	34d7f663          	bgeu	a5,a3,ffffffffc0203844 <default_check+0x432>
    assert(alloc_page() == NULL);
ffffffffc02034fc:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc02034fe:	00093c03          	ld	s8,0(s2)
ffffffffc0203502:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc0203506:	01092b03          	lw	s6,16(s2)
    elm->prev = elm->next = elm;
ffffffffc020350a:	00012797          	auipc	a5,0x12
ffffffffc020350e:	0d27b723          	sd	s2,206(a5) # ffffffffc02155d8 <free_area+0x8>
ffffffffc0203512:	00012797          	auipc	a5,0x12
ffffffffc0203516:	0b27bf23          	sd	s2,190(a5) # ffffffffc02155d0 <free_area>
    nr_free = 0;
ffffffffc020351a:	00012797          	auipc	a5,0x12
ffffffffc020351e:	0c07a323          	sw	zero,198(a5) # ffffffffc02155e0 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0203522:	e60fd0ef          	jal	ra,ffffffffc0200b82 <alloc_pages>
ffffffffc0203526:	2e051f63          	bnez	a0,ffffffffc0203824 <default_check+0x412>
    free_page(p0);
ffffffffc020352a:	4585                	li	a1,1
ffffffffc020352c:	8552                	mv	a0,s4
ffffffffc020352e:	edcfd0ef          	jal	ra,ffffffffc0200c0a <free_pages>
    free_page(p1);
ffffffffc0203532:	4585                	li	a1,1
ffffffffc0203534:	854e                	mv	a0,s3
ffffffffc0203536:	ed4fd0ef          	jal	ra,ffffffffc0200c0a <free_pages>
    free_page(p2);
ffffffffc020353a:	4585                	li	a1,1
ffffffffc020353c:	8556                	mv	a0,s5
ffffffffc020353e:	eccfd0ef          	jal	ra,ffffffffc0200c0a <free_pages>
    assert(nr_free == 3);
ffffffffc0203542:	01092703          	lw	a4,16(s2)
ffffffffc0203546:	478d                	li	a5,3
ffffffffc0203548:	2af71e63          	bne	a4,a5,ffffffffc0203804 <default_check+0x3f2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020354c:	4505                	li	a0,1
ffffffffc020354e:	e34fd0ef          	jal	ra,ffffffffc0200b82 <alloc_pages>
ffffffffc0203552:	89aa                	mv	s3,a0
ffffffffc0203554:	28050863          	beqz	a0,ffffffffc02037e4 <default_check+0x3d2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0203558:	4505                	li	a0,1
ffffffffc020355a:	e28fd0ef          	jal	ra,ffffffffc0200b82 <alloc_pages>
ffffffffc020355e:	8aaa                	mv	s5,a0
ffffffffc0203560:	3e050263          	beqz	a0,ffffffffc0203944 <default_check+0x532>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0203564:	4505                	li	a0,1
ffffffffc0203566:	e1cfd0ef          	jal	ra,ffffffffc0200b82 <alloc_pages>
ffffffffc020356a:	8a2a                	mv	s4,a0
ffffffffc020356c:	3a050c63          	beqz	a0,ffffffffc0203924 <default_check+0x512>
    assert(alloc_page() == NULL);
ffffffffc0203570:	4505                	li	a0,1
ffffffffc0203572:	e10fd0ef          	jal	ra,ffffffffc0200b82 <alloc_pages>
ffffffffc0203576:	38051763          	bnez	a0,ffffffffc0203904 <default_check+0x4f2>
    free_page(p0);
ffffffffc020357a:	4585                	li	a1,1
ffffffffc020357c:	854e                	mv	a0,s3
ffffffffc020357e:	e8cfd0ef          	jal	ra,ffffffffc0200c0a <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0203582:	00893783          	ld	a5,8(s2)
ffffffffc0203586:	23278f63          	beq	a5,s2,ffffffffc02037c4 <default_check+0x3b2>
    assert((p = alloc_page()) == p0);
ffffffffc020358a:	4505                	li	a0,1
ffffffffc020358c:	df6fd0ef          	jal	ra,ffffffffc0200b82 <alloc_pages>
ffffffffc0203590:	32a99a63          	bne	s3,a0,ffffffffc02038c4 <default_check+0x4b2>
    assert(alloc_page() == NULL);
ffffffffc0203594:	4505                	li	a0,1
ffffffffc0203596:	decfd0ef          	jal	ra,ffffffffc0200b82 <alloc_pages>
ffffffffc020359a:	30051563          	bnez	a0,ffffffffc02038a4 <default_check+0x492>
    assert(nr_free == 0);
ffffffffc020359e:	01092783          	lw	a5,16(s2)
ffffffffc02035a2:	2e079163          	bnez	a5,ffffffffc0203884 <default_check+0x472>
    free_page(p);
ffffffffc02035a6:	854e                	mv	a0,s3
ffffffffc02035a8:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc02035aa:	00012797          	auipc	a5,0x12
ffffffffc02035ae:	0387b323          	sd	s8,38(a5) # ffffffffc02155d0 <free_area>
ffffffffc02035b2:	00012797          	auipc	a5,0x12
ffffffffc02035b6:	0377b323          	sd	s7,38(a5) # ffffffffc02155d8 <free_area+0x8>
    nr_free = nr_free_store;
ffffffffc02035ba:	00012797          	auipc	a5,0x12
ffffffffc02035be:	0367a323          	sw	s6,38(a5) # ffffffffc02155e0 <free_area+0x10>
    free_page(p);
ffffffffc02035c2:	e48fd0ef          	jal	ra,ffffffffc0200c0a <free_pages>
    free_page(p1);
ffffffffc02035c6:	4585                	li	a1,1
ffffffffc02035c8:	8556                	mv	a0,s5
ffffffffc02035ca:	e40fd0ef          	jal	ra,ffffffffc0200c0a <free_pages>
    free_page(p2);
ffffffffc02035ce:	4585                	li	a1,1
ffffffffc02035d0:	8552                	mv	a0,s4
ffffffffc02035d2:	e38fd0ef          	jal	ra,ffffffffc0200c0a <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc02035d6:	4515                	li	a0,5
ffffffffc02035d8:	daafd0ef          	jal	ra,ffffffffc0200b82 <alloc_pages>
ffffffffc02035dc:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc02035de:	28050363          	beqz	a0,ffffffffc0203864 <default_check+0x452>
ffffffffc02035e2:	651c                	ld	a5,8(a0)
ffffffffc02035e4:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc02035e6:	8b85                	andi	a5,a5,1
ffffffffc02035e8:	54079e63          	bnez	a5,ffffffffc0203b44 <default_check+0x732>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc02035ec:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc02035ee:	00093b03          	ld	s6,0(s2)
ffffffffc02035f2:	00893a83          	ld	s5,8(s2)
ffffffffc02035f6:	00012797          	auipc	a5,0x12
ffffffffc02035fa:	fd27bd23          	sd	s2,-38(a5) # ffffffffc02155d0 <free_area>
ffffffffc02035fe:	00012797          	auipc	a5,0x12
ffffffffc0203602:	fd27bd23          	sd	s2,-38(a5) # ffffffffc02155d8 <free_area+0x8>
    assert(alloc_page() == NULL);
ffffffffc0203606:	d7cfd0ef          	jal	ra,ffffffffc0200b82 <alloc_pages>
ffffffffc020360a:	50051d63          	bnez	a0,ffffffffc0203b24 <default_check+0x712>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc020360e:	08098a13          	addi	s4,s3,128
ffffffffc0203612:	8552                	mv	a0,s4
ffffffffc0203614:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0203616:	01092b83          	lw	s7,16(s2)
    nr_free = 0;
ffffffffc020361a:	00012797          	auipc	a5,0x12
ffffffffc020361e:	fc07a323          	sw	zero,-58(a5) # ffffffffc02155e0 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0203622:	de8fd0ef          	jal	ra,ffffffffc0200c0a <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0203626:	4511                	li	a0,4
ffffffffc0203628:	d5afd0ef          	jal	ra,ffffffffc0200b82 <alloc_pages>
ffffffffc020362c:	4c051c63          	bnez	a0,ffffffffc0203b04 <default_check+0x6f2>
ffffffffc0203630:	0889b783          	ld	a5,136(s3)
ffffffffc0203634:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0203636:	8b85                	andi	a5,a5,1
ffffffffc0203638:	4a078663          	beqz	a5,ffffffffc0203ae4 <default_check+0x6d2>
ffffffffc020363c:	0909a703          	lw	a4,144(s3)
ffffffffc0203640:	478d                	li	a5,3
ffffffffc0203642:	4af71163          	bne	a4,a5,ffffffffc0203ae4 <default_check+0x6d2>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0203646:	450d                	li	a0,3
ffffffffc0203648:	d3afd0ef          	jal	ra,ffffffffc0200b82 <alloc_pages>
ffffffffc020364c:	8c2a                	mv	s8,a0
ffffffffc020364e:	46050b63          	beqz	a0,ffffffffc0203ac4 <default_check+0x6b2>
    assert(alloc_page() == NULL);
ffffffffc0203652:	4505                	li	a0,1
ffffffffc0203654:	d2efd0ef          	jal	ra,ffffffffc0200b82 <alloc_pages>
ffffffffc0203658:	44051663          	bnez	a0,ffffffffc0203aa4 <default_check+0x692>
    assert(p0 + 2 == p1);
ffffffffc020365c:	438a1463          	bne	s4,s8,ffffffffc0203a84 <default_check+0x672>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0203660:	4585                	li	a1,1
ffffffffc0203662:	854e                	mv	a0,s3
ffffffffc0203664:	da6fd0ef          	jal	ra,ffffffffc0200c0a <free_pages>
    free_pages(p1, 3);
ffffffffc0203668:	458d                	li	a1,3
ffffffffc020366a:	8552                	mv	a0,s4
ffffffffc020366c:	d9efd0ef          	jal	ra,ffffffffc0200c0a <free_pages>
ffffffffc0203670:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0203674:	04098c13          	addi	s8,s3,64
ffffffffc0203678:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc020367a:	8b85                	andi	a5,a5,1
ffffffffc020367c:	3e078463          	beqz	a5,ffffffffc0203a64 <default_check+0x652>
ffffffffc0203680:	0109a703          	lw	a4,16(s3)
ffffffffc0203684:	4785                	li	a5,1
ffffffffc0203686:	3cf71f63          	bne	a4,a5,ffffffffc0203a64 <default_check+0x652>
ffffffffc020368a:	008a3783          	ld	a5,8(s4)
ffffffffc020368e:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0203690:	8b85                	andi	a5,a5,1
ffffffffc0203692:	3a078963          	beqz	a5,ffffffffc0203a44 <default_check+0x632>
ffffffffc0203696:	010a2703          	lw	a4,16(s4)
ffffffffc020369a:	478d                	li	a5,3
ffffffffc020369c:	3af71463          	bne	a4,a5,ffffffffc0203a44 <default_check+0x632>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02036a0:	4505                	li	a0,1
ffffffffc02036a2:	ce0fd0ef          	jal	ra,ffffffffc0200b82 <alloc_pages>
ffffffffc02036a6:	36a99f63          	bne	s3,a0,ffffffffc0203a24 <default_check+0x612>
    free_page(p0);
ffffffffc02036aa:	4585                	li	a1,1
ffffffffc02036ac:	d5efd0ef          	jal	ra,ffffffffc0200c0a <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc02036b0:	4509                	li	a0,2
ffffffffc02036b2:	cd0fd0ef          	jal	ra,ffffffffc0200b82 <alloc_pages>
ffffffffc02036b6:	34aa1763          	bne	s4,a0,ffffffffc0203a04 <default_check+0x5f2>

    free_pages(p0, 2);
ffffffffc02036ba:	4589                	li	a1,2
ffffffffc02036bc:	d4efd0ef          	jal	ra,ffffffffc0200c0a <free_pages>
    free_page(p2);
ffffffffc02036c0:	4585                	li	a1,1
ffffffffc02036c2:	8562                	mv	a0,s8
ffffffffc02036c4:	d46fd0ef          	jal	ra,ffffffffc0200c0a <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02036c8:	4515                	li	a0,5
ffffffffc02036ca:	cb8fd0ef          	jal	ra,ffffffffc0200b82 <alloc_pages>
ffffffffc02036ce:	89aa                	mv	s3,a0
ffffffffc02036d0:	48050a63          	beqz	a0,ffffffffc0203b64 <default_check+0x752>
    assert(alloc_page() == NULL);
ffffffffc02036d4:	4505                	li	a0,1
ffffffffc02036d6:	cacfd0ef          	jal	ra,ffffffffc0200b82 <alloc_pages>
ffffffffc02036da:	2e051563          	bnez	a0,ffffffffc02039c4 <default_check+0x5b2>

    assert(nr_free == 0);
ffffffffc02036de:	01092783          	lw	a5,16(s2)
ffffffffc02036e2:	2c079163          	bnez	a5,ffffffffc02039a4 <default_check+0x592>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc02036e6:	4595                	li	a1,5
ffffffffc02036e8:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc02036ea:	00012797          	auipc	a5,0x12
ffffffffc02036ee:	ef77ab23          	sw	s7,-266(a5) # ffffffffc02155e0 <free_area+0x10>
    free_list = free_list_store;
ffffffffc02036f2:	00012797          	auipc	a5,0x12
ffffffffc02036f6:	ed67bf23          	sd	s6,-290(a5) # ffffffffc02155d0 <free_area>
ffffffffc02036fa:	00012797          	auipc	a5,0x12
ffffffffc02036fe:	ed57bf23          	sd	s5,-290(a5) # ffffffffc02155d8 <free_area+0x8>
    free_pages(p0, 5);
ffffffffc0203702:	d08fd0ef          	jal	ra,ffffffffc0200c0a <free_pages>
    return listelm->next;
ffffffffc0203706:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc020370a:	01278963          	beq	a5,s2,ffffffffc020371c <default_check+0x30a>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc020370e:	ff87a703          	lw	a4,-8(a5)
ffffffffc0203712:	679c                	ld	a5,8(a5)
ffffffffc0203714:	34fd                	addiw	s1,s1,-1
ffffffffc0203716:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0203718:	ff279be3          	bne	a5,s2,ffffffffc020370e <default_check+0x2fc>
    }
    assert(count == 0);
ffffffffc020371c:	26049463          	bnez	s1,ffffffffc0203984 <default_check+0x572>
    assert(total == 0);
ffffffffc0203720:	46041263          	bnez	s0,ffffffffc0203b84 <default_check+0x772>
}
ffffffffc0203724:	60a6                	ld	ra,72(sp)
ffffffffc0203726:	6406                	ld	s0,64(sp)
ffffffffc0203728:	74e2                	ld	s1,56(sp)
ffffffffc020372a:	7942                	ld	s2,48(sp)
ffffffffc020372c:	79a2                	ld	s3,40(sp)
ffffffffc020372e:	7a02                	ld	s4,32(sp)
ffffffffc0203730:	6ae2                	ld	s5,24(sp)
ffffffffc0203732:	6b42                	ld	s6,16(sp)
ffffffffc0203734:	6ba2                	ld	s7,8(sp)
ffffffffc0203736:	6c02                	ld	s8,0(sp)
ffffffffc0203738:	6161                	addi	sp,sp,80
ffffffffc020373a:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc020373c:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc020373e:	4401                	li	s0,0
ffffffffc0203740:	4481                	li	s1,0
ffffffffc0203742:	b30d                	j	ffffffffc0203464 <default_check+0x52>
        assert(PageProperty(p));
ffffffffc0203744:	00002697          	auipc	a3,0x2
ffffffffc0203748:	62468693          	addi	a3,a3,1572 # ffffffffc0205d68 <commands+0x1200>
ffffffffc020374c:	00002617          	auipc	a2,0x2
ffffffffc0203750:	db460613          	addi	a2,a2,-588 # ffffffffc0205500 <commands+0x998>
ffffffffc0203754:	0f000593          	li	a1,240
ffffffffc0203758:	00003517          	auipc	a0,0x3
ffffffffc020375c:	b6050513          	addi	a0,a0,-1184 # ffffffffc02062b8 <commands+0x1750>
ffffffffc0203760:	a75fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0203764:	00003697          	auipc	a3,0x3
ffffffffc0203768:	bcc68693          	addi	a3,a3,-1076 # ffffffffc0206330 <commands+0x17c8>
ffffffffc020376c:	00002617          	auipc	a2,0x2
ffffffffc0203770:	d9460613          	addi	a2,a2,-620 # ffffffffc0205500 <commands+0x998>
ffffffffc0203774:	0bd00593          	li	a1,189
ffffffffc0203778:	00003517          	auipc	a0,0x3
ffffffffc020377c:	b4050513          	addi	a0,a0,-1216 # ffffffffc02062b8 <commands+0x1750>
ffffffffc0203780:	a55fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0203784:	00003697          	auipc	a3,0x3
ffffffffc0203788:	bd468693          	addi	a3,a3,-1068 # ffffffffc0206358 <commands+0x17f0>
ffffffffc020378c:	00002617          	auipc	a2,0x2
ffffffffc0203790:	d7460613          	addi	a2,a2,-652 # ffffffffc0205500 <commands+0x998>
ffffffffc0203794:	0be00593          	li	a1,190
ffffffffc0203798:	00003517          	auipc	a0,0x3
ffffffffc020379c:	b2050513          	addi	a0,a0,-1248 # ffffffffc02062b8 <commands+0x1750>
ffffffffc02037a0:	a35fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc02037a4:	00003697          	auipc	a3,0x3
ffffffffc02037a8:	bf468693          	addi	a3,a3,-1036 # ffffffffc0206398 <commands+0x1830>
ffffffffc02037ac:	00002617          	auipc	a2,0x2
ffffffffc02037b0:	d5460613          	addi	a2,a2,-684 # ffffffffc0205500 <commands+0x998>
ffffffffc02037b4:	0c000593          	li	a1,192
ffffffffc02037b8:	00003517          	auipc	a0,0x3
ffffffffc02037bc:	b0050513          	addi	a0,a0,-1280 # ffffffffc02062b8 <commands+0x1750>
ffffffffc02037c0:	a15fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(!list_empty(&free_list));
ffffffffc02037c4:	00003697          	auipc	a3,0x3
ffffffffc02037c8:	c5c68693          	addi	a3,a3,-932 # ffffffffc0206420 <commands+0x18b8>
ffffffffc02037cc:	00002617          	auipc	a2,0x2
ffffffffc02037d0:	d3460613          	addi	a2,a2,-716 # ffffffffc0205500 <commands+0x998>
ffffffffc02037d4:	0d900593          	li	a1,217
ffffffffc02037d8:	00003517          	auipc	a0,0x3
ffffffffc02037dc:	ae050513          	addi	a0,a0,-1312 # ffffffffc02062b8 <commands+0x1750>
ffffffffc02037e0:	9f5fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02037e4:	00003697          	auipc	a3,0x3
ffffffffc02037e8:	aec68693          	addi	a3,a3,-1300 # ffffffffc02062d0 <commands+0x1768>
ffffffffc02037ec:	00002617          	auipc	a2,0x2
ffffffffc02037f0:	d1460613          	addi	a2,a2,-748 # ffffffffc0205500 <commands+0x998>
ffffffffc02037f4:	0d200593          	li	a1,210
ffffffffc02037f8:	00003517          	auipc	a0,0x3
ffffffffc02037fc:	ac050513          	addi	a0,a0,-1344 # ffffffffc02062b8 <commands+0x1750>
ffffffffc0203800:	9d5fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(nr_free == 3);
ffffffffc0203804:	00003697          	auipc	a3,0x3
ffffffffc0203808:	c0c68693          	addi	a3,a3,-1012 # ffffffffc0206410 <commands+0x18a8>
ffffffffc020380c:	00002617          	auipc	a2,0x2
ffffffffc0203810:	cf460613          	addi	a2,a2,-780 # ffffffffc0205500 <commands+0x998>
ffffffffc0203814:	0d000593          	li	a1,208
ffffffffc0203818:	00003517          	auipc	a0,0x3
ffffffffc020381c:	aa050513          	addi	a0,a0,-1376 # ffffffffc02062b8 <commands+0x1750>
ffffffffc0203820:	9b5fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0203824:	00003697          	auipc	a3,0x3
ffffffffc0203828:	bd468693          	addi	a3,a3,-1068 # ffffffffc02063f8 <commands+0x1890>
ffffffffc020382c:	00002617          	auipc	a2,0x2
ffffffffc0203830:	cd460613          	addi	a2,a2,-812 # ffffffffc0205500 <commands+0x998>
ffffffffc0203834:	0cb00593          	li	a1,203
ffffffffc0203838:	00003517          	auipc	a0,0x3
ffffffffc020383c:	a8050513          	addi	a0,a0,-1408 # ffffffffc02062b8 <commands+0x1750>
ffffffffc0203840:	995fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0203844:	00003697          	auipc	a3,0x3
ffffffffc0203848:	b9468693          	addi	a3,a3,-1132 # ffffffffc02063d8 <commands+0x1870>
ffffffffc020384c:	00002617          	auipc	a2,0x2
ffffffffc0203850:	cb460613          	addi	a2,a2,-844 # ffffffffc0205500 <commands+0x998>
ffffffffc0203854:	0c200593          	li	a1,194
ffffffffc0203858:	00003517          	auipc	a0,0x3
ffffffffc020385c:	a6050513          	addi	a0,a0,-1440 # ffffffffc02062b8 <commands+0x1750>
ffffffffc0203860:	975fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(p0 != NULL);
ffffffffc0203864:	00003697          	auipc	a3,0x3
ffffffffc0203868:	bf468693          	addi	a3,a3,-1036 # ffffffffc0206458 <commands+0x18f0>
ffffffffc020386c:	00002617          	auipc	a2,0x2
ffffffffc0203870:	c9460613          	addi	a2,a2,-876 # ffffffffc0205500 <commands+0x998>
ffffffffc0203874:	0f800593          	li	a1,248
ffffffffc0203878:	00003517          	auipc	a0,0x3
ffffffffc020387c:	a4050513          	addi	a0,a0,-1472 # ffffffffc02062b8 <commands+0x1750>
ffffffffc0203880:	955fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(nr_free == 0);
ffffffffc0203884:	00002697          	auipc	a3,0x2
ffffffffc0203888:	69468693          	addi	a3,a3,1684 # ffffffffc0205f18 <commands+0x13b0>
ffffffffc020388c:	00002617          	auipc	a2,0x2
ffffffffc0203890:	c7460613          	addi	a2,a2,-908 # ffffffffc0205500 <commands+0x998>
ffffffffc0203894:	0df00593          	li	a1,223
ffffffffc0203898:	00003517          	auipc	a0,0x3
ffffffffc020389c:	a2050513          	addi	a0,a0,-1504 # ffffffffc02062b8 <commands+0x1750>
ffffffffc02038a0:	935fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02038a4:	00003697          	auipc	a3,0x3
ffffffffc02038a8:	b5468693          	addi	a3,a3,-1196 # ffffffffc02063f8 <commands+0x1890>
ffffffffc02038ac:	00002617          	auipc	a2,0x2
ffffffffc02038b0:	c5460613          	addi	a2,a2,-940 # ffffffffc0205500 <commands+0x998>
ffffffffc02038b4:	0dd00593          	li	a1,221
ffffffffc02038b8:	00003517          	auipc	a0,0x3
ffffffffc02038bc:	a0050513          	addi	a0,a0,-1536 # ffffffffc02062b8 <commands+0x1750>
ffffffffc02038c0:	915fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc02038c4:	00003697          	auipc	a3,0x3
ffffffffc02038c8:	b7468693          	addi	a3,a3,-1164 # ffffffffc0206438 <commands+0x18d0>
ffffffffc02038cc:	00002617          	auipc	a2,0x2
ffffffffc02038d0:	c3460613          	addi	a2,a2,-972 # ffffffffc0205500 <commands+0x998>
ffffffffc02038d4:	0dc00593          	li	a1,220
ffffffffc02038d8:	00003517          	auipc	a0,0x3
ffffffffc02038dc:	9e050513          	addi	a0,a0,-1568 # ffffffffc02062b8 <commands+0x1750>
ffffffffc02038e0:	8f5fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02038e4:	00003697          	auipc	a3,0x3
ffffffffc02038e8:	9ec68693          	addi	a3,a3,-1556 # ffffffffc02062d0 <commands+0x1768>
ffffffffc02038ec:	00002617          	auipc	a2,0x2
ffffffffc02038f0:	c1460613          	addi	a2,a2,-1004 # ffffffffc0205500 <commands+0x998>
ffffffffc02038f4:	0b900593          	li	a1,185
ffffffffc02038f8:	00003517          	auipc	a0,0x3
ffffffffc02038fc:	9c050513          	addi	a0,a0,-1600 # ffffffffc02062b8 <commands+0x1750>
ffffffffc0203900:	8d5fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0203904:	00003697          	auipc	a3,0x3
ffffffffc0203908:	af468693          	addi	a3,a3,-1292 # ffffffffc02063f8 <commands+0x1890>
ffffffffc020390c:	00002617          	auipc	a2,0x2
ffffffffc0203910:	bf460613          	addi	a2,a2,-1036 # ffffffffc0205500 <commands+0x998>
ffffffffc0203914:	0d600593          	li	a1,214
ffffffffc0203918:	00003517          	auipc	a0,0x3
ffffffffc020391c:	9a050513          	addi	a0,a0,-1632 # ffffffffc02062b8 <commands+0x1750>
ffffffffc0203920:	8b5fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0203924:	00003697          	auipc	a3,0x3
ffffffffc0203928:	9ec68693          	addi	a3,a3,-1556 # ffffffffc0206310 <commands+0x17a8>
ffffffffc020392c:	00002617          	auipc	a2,0x2
ffffffffc0203930:	bd460613          	addi	a2,a2,-1068 # ffffffffc0205500 <commands+0x998>
ffffffffc0203934:	0d400593          	li	a1,212
ffffffffc0203938:	00003517          	auipc	a0,0x3
ffffffffc020393c:	98050513          	addi	a0,a0,-1664 # ffffffffc02062b8 <commands+0x1750>
ffffffffc0203940:	895fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0203944:	00003697          	auipc	a3,0x3
ffffffffc0203948:	9ac68693          	addi	a3,a3,-1620 # ffffffffc02062f0 <commands+0x1788>
ffffffffc020394c:	00002617          	auipc	a2,0x2
ffffffffc0203950:	bb460613          	addi	a2,a2,-1100 # ffffffffc0205500 <commands+0x998>
ffffffffc0203954:	0d300593          	li	a1,211
ffffffffc0203958:	00003517          	auipc	a0,0x3
ffffffffc020395c:	96050513          	addi	a0,a0,-1696 # ffffffffc02062b8 <commands+0x1750>
ffffffffc0203960:	875fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0203964:	00003697          	auipc	a3,0x3
ffffffffc0203968:	9ac68693          	addi	a3,a3,-1620 # ffffffffc0206310 <commands+0x17a8>
ffffffffc020396c:	00002617          	auipc	a2,0x2
ffffffffc0203970:	b9460613          	addi	a2,a2,-1132 # ffffffffc0205500 <commands+0x998>
ffffffffc0203974:	0bb00593          	li	a1,187
ffffffffc0203978:	00003517          	auipc	a0,0x3
ffffffffc020397c:	94050513          	addi	a0,a0,-1728 # ffffffffc02062b8 <commands+0x1750>
ffffffffc0203980:	855fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(count == 0);
ffffffffc0203984:	00003697          	auipc	a3,0x3
ffffffffc0203988:	c2468693          	addi	a3,a3,-988 # ffffffffc02065a8 <commands+0x1a40>
ffffffffc020398c:	00002617          	auipc	a2,0x2
ffffffffc0203990:	b7460613          	addi	a2,a2,-1164 # ffffffffc0205500 <commands+0x998>
ffffffffc0203994:	12500593          	li	a1,293
ffffffffc0203998:	00003517          	auipc	a0,0x3
ffffffffc020399c:	92050513          	addi	a0,a0,-1760 # ffffffffc02062b8 <commands+0x1750>
ffffffffc02039a0:	835fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(nr_free == 0);
ffffffffc02039a4:	00002697          	auipc	a3,0x2
ffffffffc02039a8:	57468693          	addi	a3,a3,1396 # ffffffffc0205f18 <commands+0x13b0>
ffffffffc02039ac:	00002617          	auipc	a2,0x2
ffffffffc02039b0:	b5460613          	addi	a2,a2,-1196 # ffffffffc0205500 <commands+0x998>
ffffffffc02039b4:	11a00593          	li	a1,282
ffffffffc02039b8:	00003517          	auipc	a0,0x3
ffffffffc02039bc:	90050513          	addi	a0,a0,-1792 # ffffffffc02062b8 <commands+0x1750>
ffffffffc02039c0:	815fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02039c4:	00003697          	auipc	a3,0x3
ffffffffc02039c8:	a3468693          	addi	a3,a3,-1484 # ffffffffc02063f8 <commands+0x1890>
ffffffffc02039cc:	00002617          	auipc	a2,0x2
ffffffffc02039d0:	b3460613          	addi	a2,a2,-1228 # ffffffffc0205500 <commands+0x998>
ffffffffc02039d4:	11800593          	li	a1,280
ffffffffc02039d8:	00003517          	auipc	a0,0x3
ffffffffc02039dc:	8e050513          	addi	a0,a0,-1824 # ffffffffc02062b8 <commands+0x1750>
ffffffffc02039e0:	ff4fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02039e4:	00003697          	auipc	a3,0x3
ffffffffc02039e8:	9d468693          	addi	a3,a3,-1580 # ffffffffc02063b8 <commands+0x1850>
ffffffffc02039ec:	00002617          	auipc	a2,0x2
ffffffffc02039f0:	b1460613          	addi	a2,a2,-1260 # ffffffffc0205500 <commands+0x998>
ffffffffc02039f4:	0c100593          	li	a1,193
ffffffffc02039f8:	00003517          	auipc	a0,0x3
ffffffffc02039fc:	8c050513          	addi	a0,a0,-1856 # ffffffffc02062b8 <commands+0x1750>
ffffffffc0203a00:	fd4fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0203a04:	00003697          	auipc	a3,0x3
ffffffffc0203a08:	b6468693          	addi	a3,a3,-1180 # ffffffffc0206568 <commands+0x1a00>
ffffffffc0203a0c:	00002617          	auipc	a2,0x2
ffffffffc0203a10:	af460613          	addi	a2,a2,-1292 # ffffffffc0205500 <commands+0x998>
ffffffffc0203a14:	11200593          	li	a1,274
ffffffffc0203a18:	00003517          	auipc	a0,0x3
ffffffffc0203a1c:	8a050513          	addi	a0,a0,-1888 # ffffffffc02062b8 <commands+0x1750>
ffffffffc0203a20:	fb4fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0203a24:	00003697          	auipc	a3,0x3
ffffffffc0203a28:	b2468693          	addi	a3,a3,-1244 # ffffffffc0206548 <commands+0x19e0>
ffffffffc0203a2c:	00002617          	auipc	a2,0x2
ffffffffc0203a30:	ad460613          	addi	a2,a2,-1324 # ffffffffc0205500 <commands+0x998>
ffffffffc0203a34:	11000593          	li	a1,272
ffffffffc0203a38:	00003517          	auipc	a0,0x3
ffffffffc0203a3c:	88050513          	addi	a0,a0,-1920 # ffffffffc02062b8 <commands+0x1750>
ffffffffc0203a40:	f94fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0203a44:	00003697          	auipc	a3,0x3
ffffffffc0203a48:	adc68693          	addi	a3,a3,-1316 # ffffffffc0206520 <commands+0x19b8>
ffffffffc0203a4c:	00002617          	auipc	a2,0x2
ffffffffc0203a50:	ab460613          	addi	a2,a2,-1356 # ffffffffc0205500 <commands+0x998>
ffffffffc0203a54:	10e00593          	li	a1,270
ffffffffc0203a58:	00003517          	auipc	a0,0x3
ffffffffc0203a5c:	86050513          	addi	a0,a0,-1952 # ffffffffc02062b8 <commands+0x1750>
ffffffffc0203a60:	f74fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0203a64:	00003697          	auipc	a3,0x3
ffffffffc0203a68:	a9468693          	addi	a3,a3,-1388 # ffffffffc02064f8 <commands+0x1990>
ffffffffc0203a6c:	00002617          	auipc	a2,0x2
ffffffffc0203a70:	a9460613          	addi	a2,a2,-1388 # ffffffffc0205500 <commands+0x998>
ffffffffc0203a74:	10d00593          	li	a1,269
ffffffffc0203a78:	00003517          	auipc	a0,0x3
ffffffffc0203a7c:	84050513          	addi	a0,a0,-1984 # ffffffffc02062b8 <commands+0x1750>
ffffffffc0203a80:	f54fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(p0 + 2 == p1);
ffffffffc0203a84:	00003697          	auipc	a3,0x3
ffffffffc0203a88:	a6468693          	addi	a3,a3,-1436 # ffffffffc02064e8 <commands+0x1980>
ffffffffc0203a8c:	00002617          	auipc	a2,0x2
ffffffffc0203a90:	a7460613          	addi	a2,a2,-1420 # ffffffffc0205500 <commands+0x998>
ffffffffc0203a94:	10800593          	li	a1,264
ffffffffc0203a98:	00003517          	auipc	a0,0x3
ffffffffc0203a9c:	82050513          	addi	a0,a0,-2016 # ffffffffc02062b8 <commands+0x1750>
ffffffffc0203aa0:	f34fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0203aa4:	00003697          	auipc	a3,0x3
ffffffffc0203aa8:	95468693          	addi	a3,a3,-1708 # ffffffffc02063f8 <commands+0x1890>
ffffffffc0203aac:	00002617          	auipc	a2,0x2
ffffffffc0203ab0:	a5460613          	addi	a2,a2,-1452 # ffffffffc0205500 <commands+0x998>
ffffffffc0203ab4:	10700593          	li	a1,263
ffffffffc0203ab8:	00003517          	auipc	a0,0x3
ffffffffc0203abc:	80050513          	addi	a0,a0,-2048 # ffffffffc02062b8 <commands+0x1750>
ffffffffc0203ac0:	f14fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0203ac4:	00003697          	auipc	a3,0x3
ffffffffc0203ac8:	a0468693          	addi	a3,a3,-1532 # ffffffffc02064c8 <commands+0x1960>
ffffffffc0203acc:	00002617          	auipc	a2,0x2
ffffffffc0203ad0:	a3460613          	addi	a2,a2,-1484 # ffffffffc0205500 <commands+0x998>
ffffffffc0203ad4:	10600593          	li	a1,262
ffffffffc0203ad8:	00002517          	auipc	a0,0x2
ffffffffc0203adc:	7e050513          	addi	a0,a0,2016 # ffffffffc02062b8 <commands+0x1750>
ffffffffc0203ae0:	ef4fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0203ae4:	00003697          	auipc	a3,0x3
ffffffffc0203ae8:	9b468693          	addi	a3,a3,-1612 # ffffffffc0206498 <commands+0x1930>
ffffffffc0203aec:	00002617          	auipc	a2,0x2
ffffffffc0203af0:	a1460613          	addi	a2,a2,-1516 # ffffffffc0205500 <commands+0x998>
ffffffffc0203af4:	10500593          	li	a1,261
ffffffffc0203af8:	00002517          	auipc	a0,0x2
ffffffffc0203afc:	7c050513          	addi	a0,a0,1984 # ffffffffc02062b8 <commands+0x1750>
ffffffffc0203b00:	ed4fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0203b04:	00003697          	auipc	a3,0x3
ffffffffc0203b08:	97c68693          	addi	a3,a3,-1668 # ffffffffc0206480 <commands+0x1918>
ffffffffc0203b0c:	00002617          	auipc	a2,0x2
ffffffffc0203b10:	9f460613          	addi	a2,a2,-1548 # ffffffffc0205500 <commands+0x998>
ffffffffc0203b14:	10400593          	li	a1,260
ffffffffc0203b18:	00002517          	auipc	a0,0x2
ffffffffc0203b1c:	7a050513          	addi	a0,a0,1952 # ffffffffc02062b8 <commands+0x1750>
ffffffffc0203b20:	eb4fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0203b24:	00003697          	auipc	a3,0x3
ffffffffc0203b28:	8d468693          	addi	a3,a3,-1836 # ffffffffc02063f8 <commands+0x1890>
ffffffffc0203b2c:	00002617          	auipc	a2,0x2
ffffffffc0203b30:	9d460613          	addi	a2,a2,-1580 # ffffffffc0205500 <commands+0x998>
ffffffffc0203b34:	0fe00593          	li	a1,254
ffffffffc0203b38:	00002517          	auipc	a0,0x2
ffffffffc0203b3c:	78050513          	addi	a0,a0,1920 # ffffffffc02062b8 <commands+0x1750>
ffffffffc0203b40:	e94fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(!PageProperty(p0));
ffffffffc0203b44:	00003697          	auipc	a3,0x3
ffffffffc0203b48:	92468693          	addi	a3,a3,-1756 # ffffffffc0206468 <commands+0x1900>
ffffffffc0203b4c:	00002617          	auipc	a2,0x2
ffffffffc0203b50:	9b460613          	addi	a2,a2,-1612 # ffffffffc0205500 <commands+0x998>
ffffffffc0203b54:	0f900593          	li	a1,249
ffffffffc0203b58:	00002517          	auipc	a0,0x2
ffffffffc0203b5c:	76050513          	addi	a0,a0,1888 # ffffffffc02062b8 <commands+0x1750>
ffffffffc0203b60:	e74fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0203b64:	00003697          	auipc	a3,0x3
ffffffffc0203b68:	a2468693          	addi	a3,a3,-1500 # ffffffffc0206588 <commands+0x1a20>
ffffffffc0203b6c:	00002617          	auipc	a2,0x2
ffffffffc0203b70:	99460613          	addi	a2,a2,-1644 # ffffffffc0205500 <commands+0x998>
ffffffffc0203b74:	11700593          	li	a1,279
ffffffffc0203b78:	00002517          	auipc	a0,0x2
ffffffffc0203b7c:	74050513          	addi	a0,a0,1856 # ffffffffc02062b8 <commands+0x1750>
ffffffffc0203b80:	e54fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(total == 0);
ffffffffc0203b84:	00003697          	auipc	a3,0x3
ffffffffc0203b88:	a3468693          	addi	a3,a3,-1484 # ffffffffc02065b8 <commands+0x1a50>
ffffffffc0203b8c:	00002617          	auipc	a2,0x2
ffffffffc0203b90:	97460613          	addi	a2,a2,-1676 # ffffffffc0205500 <commands+0x998>
ffffffffc0203b94:	12600593          	li	a1,294
ffffffffc0203b98:	00002517          	auipc	a0,0x2
ffffffffc0203b9c:	72050513          	addi	a0,a0,1824 # ffffffffc02062b8 <commands+0x1750>
ffffffffc0203ba0:	e34fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(total == nr_free_pages());
ffffffffc0203ba4:	00002697          	auipc	a3,0x2
ffffffffc0203ba8:	1d468693          	addi	a3,a3,468 # ffffffffc0205d78 <commands+0x1210>
ffffffffc0203bac:	00002617          	auipc	a2,0x2
ffffffffc0203bb0:	95460613          	addi	a2,a2,-1708 # ffffffffc0205500 <commands+0x998>
ffffffffc0203bb4:	0f300593          	li	a1,243
ffffffffc0203bb8:	00002517          	auipc	a0,0x2
ffffffffc0203bbc:	70050513          	addi	a0,a0,1792 # ffffffffc02062b8 <commands+0x1750>
ffffffffc0203bc0:	e14fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0203bc4:	00002697          	auipc	a3,0x2
ffffffffc0203bc8:	72c68693          	addi	a3,a3,1836 # ffffffffc02062f0 <commands+0x1788>
ffffffffc0203bcc:	00002617          	auipc	a2,0x2
ffffffffc0203bd0:	93460613          	addi	a2,a2,-1740 # ffffffffc0205500 <commands+0x998>
ffffffffc0203bd4:	0ba00593          	li	a1,186
ffffffffc0203bd8:	00002517          	auipc	a0,0x2
ffffffffc0203bdc:	6e050513          	addi	a0,a0,1760 # ffffffffc02062b8 <commands+0x1750>
ffffffffc0203be0:	df4fc0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc0203be4 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc0203be4:	1141                	addi	sp,sp,-16
ffffffffc0203be6:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0203be8:	16058e63          	beqz	a1,ffffffffc0203d64 <default_free_pages+0x180>
    for (; p != base + n; p ++) {
ffffffffc0203bec:	00659693          	slli	a3,a1,0x6
ffffffffc0203bf0:	96aa                	add	a3,a3,a0
ffffffffc0203bf2:	02d50d63          	beq	a0,a3,ffffffffc0203c2c <default_free_pages+0x48>
ffffffffc0203bf6:	651c                	ld	a5,8(a0)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0203bf8:	8b85                	andi	a5,a5,1
ffffffffc0203bfa:	14079563          	bnez	a5,ffffffffc0203d44 <default_free_pages+0x160>
ffffffffc0203bfe:	651c                	ld	a5,8(a0)
ffffffffc0203c00:	8385                	srli	a5,a5,0x1
ffffffffc0203c02:	8b85                	andi	a5,a5,1
ffffffffc0203c04:	14079063          	bnez	a5,ffffffffc0203d44 <default_free_pages+0x160>
ffffffffc0203c08:	87aa                	mv	a5,a0
ffffffffc0203c0a:	a809                	j	ffffffffc0203c1c <default_free_pages+0x38>
ffffffffc0203c0c:	6798                	ld	a4,8(a5)
ffffffffc0203c0e:	8b05                	andi	a4,a4,1
ffffffffc0203c10:	12071a63          	bnez	a4,ffffffffc0203d44 <default_free_pages+0x160>
ffffffffc0203c14:	6798                	ld	a4,8(a5)
ffffffffc0203c16:	8b09                	andi	a4,a4,2
ffffffffc0203c18:	12071663          	bnez	a4,ffffffffc0203d44 <default_free_pages+0x160>
        p->flags = 0;
ffffffffc0203c1c:	0007b423          	sd	zero,8(a5)
    page->ref = val;
ffffffffc0203c20:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0203c24:	04078793          	addi	a5,a5,64
ffffffffc0203c28:	fed792e3          	bne	a5,a3,ffffffffc0203c0c <default_free_pages+0x28>
    base->property = n;
ffffffffc0203c2c:	2581                	sext.w	a1,a1
ffffffffc0203c2e:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc0203c30:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0203c34:	4789                	li	a5,2
ffffffffc0203c36:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc0203c3a:	00012697          	auipc	a3,0x12
ffffffffc0203c3e:	99668693          	addi	a3,a3,-1642 # ffffffffc02155d0 <free_area>
ffffffffc0203c42:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0203c44:	669c                	ld	a5,8(a3)
ffffffffc0203c46:	9db9                	addw	a1,a1,a4
ffffffffc0203c48:	00012717          	auipc	a4,0x12
ffffffffc0203c4c:	98b72c23          	sw	a1,-1640(a4) # ffffffffc02155e0 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc0203c50:	0cd78163          	beq	a5,a3,ffffffffc0203d12 <default_free_pages+0x12e>
            struct Page* page = le2page(le, page_link);
ffffffffc0203c54:	fe878713          	addi	a4,a5,-24
ffffffffc0203c58:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0203c5a:	4801                	li	a6,0
ffffffffc0203c5c:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc0203c60:	00e56a63          	bltu	a0,a4,ffffffffc0203c74 <default_free_pages+0x90>
    return listelm->next;
ffffffffc0203c64:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0203c66:	04d70f63          	beq	a4,a3,ffffffffc0203cc4 <default_free_pages+0xe0>
        while ((le = list_next(le)) != &free_list) {
ffffffffc0203c6a:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0203c6c:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0203c70:	fee57ae3          	bgeu	a0,a4,ffffffffc0203c64 <default_free_pages+0x80>
ffffffffc0203c74:	00080663          	beqz	a6,ffffffffc0203c80 <default_free_pages+0x9c>
ffffffffc0203c78:	00012817          	auipc	a6,0x12
ffffffffc0203c7c:	94b83c23          	sd	a1,-1704(a6) # ffffffffc02155d0 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0203c80:	638c                	ld	a1,0(a5)
    prev->next = next->prev = elm;
ffffffffc0203c82:	e390                	sd	a2,0(a5)
ffffffffc0203c84:	e590                	sd	a2,8(a1)
    elm->next = next;
ffffffffc0203c86:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0203c88:	ed0c                	sd	a1,24(a0)
    if (le != &free_list) {
ffffffffc0203c8a:	06d58a63          	beq	a1,a3,ffffffffc0203cfe <default_free_pages+0x11a>
        if (p + p->property == base) {
ffffffffc0203c8e:	ff85a603          	lw	a2,-8(a1) # ff8 <BASE_ADDRESS-0xffffffffc01ff008>
        p = le2page(le, page_link);
ffffffffc0203c92:	fe858713          	addi	a4,a1,-24
        if (p + p->property == base) {
ffffffffc0203c96:	02061793          	slli	a5,a2,0x20
ffffffffc0203c9a:	83e9                	srli	a5,a5,0x1a
ffffffffc0203c9c:	97ba                	add	a5,a5,a4
ffffffffc0203c9e:	04f51b63          	bne	a0,a5,ffffffffc0203cf4 <default_free_pages+0x110>
            p->property += base->property;
ffffffffc0203ca2:	491c                	lw	a5,16(a0)
ffffffffc0203ca4:	9e3d                	addw	a2,a2,a5
ffffffffc0203ca6:	fec5ac23          	sw	a2,-8(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0203caa:	57f5                	li	a5,-3
ffffffffc0203cac:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0203cb0:	01853803          	ld	a6,24(a0)
ffffffffc0203cb4:	7110                	ld	a2,32(a0)
            base = p;
ffffffffc0203cb6:	853a                	mv	a0,a4
    prev->next = next;
ffffffffc0203cb8:	00c83423          	sd	a2,8(a6)
    next->prev = prev;
ffffffffc0203cbc:	659c                	ld	a5,8(a1)
ffffffffc0203cbe:	01063023          	sd	a6,0(a2)
ffffffffc0203cc2:	a815                	j	ffffffffc0203cf6 <default_free_pages+0x112>
    prev->next = next->prev = elm;
ffffffffc0203cc4:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0203cc6:	f114                	sd	a3,32(a0)
ffffffffc0203cc8:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0203cca:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc0203ccc:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0203cce:	00d70563          	beq	a4,a3,ffffffffc0203cd8 <default_free_pages+0xf4>
ffffffffc0203cd2:	4805                	li	a6,1
ffffffffc0203cd4:	87ba                	mv	a5,a4
ffffffffc0203cd6:	bf59                	j	ffffffffc0203c6c <default_free_pages+0x88>
ffffffffc0203cd8:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc0203cda:	85be                	mv	a1,a5
    if (le != &free_list) {
ffffffffc0203cdc:	00d78d63          	beq	a5,a3,ffffffffc0203cf6 <default_free_pages+0x112>
        if (p + p->property == base) {
ffffffffc0203ce0:	ff85a603          	lw	a2,-8(a1)
        p = le2page(le, page_link);
ffffffffc0203ce4:	fe858713          	addi	a4,a1,-24
        if (p + p->property == base) {
ffffffffc0203ce8:	02061793          	slli	a5,a2,0x20
ffffffffc0203cec:	83e9                	srli	a5,a5,0x1a
ffffffffc0203cee:	97ba                	add	a5,a5,a4
ffffffffc0203cf0:	faf509e3          	beq	a0,a5,ffffffffc0203ca2 <default_free_pages+0xbe>
ffffffffc0203cf4:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc0203cf6:	fe878713          	addi	a4,a5,-24
ffffffffc0203cfa:	00d78963          	beq	a5,a3,ffffffffc0203d0c <default_free_pages+0x128>
        if (base + base->property == p) {
ffffffffc0203cfe:	4910                	lw	a2,16(a0)
ffffffffc0203d00:	02061693          	slli	a3,a2,0x20
ffffffffc0203d04:	82e9                	srli	a3,a3,0x1a
ffffffffc0203d06:	96aa                	add	a3,a3,a0
ffffffffc0203d08:	00d70e63          	beq	a4,a3,ffffffffc0203d24 <default_free_pages+0x140>
}
ffffffffc0203d0c:	60a2                	ld	ra,8(sp)
ffffffffc0203d0e:	0141                	addi	sp,sp,16
ffffffffc0203d10:	8082                	ret
ffffffffc0203d12:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0203d14:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc0203d18:	e398                	sd	a4,0(a5)
ffffffffc0203d1a:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0203d1c:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0203d1e:	ed1c                	sd	a5,24(a0)
}
ffffffffc0203d20:	0141                	addi	sp,sp,16
ffffffffc0203d22:	8082                	ret
            base->property += p->property;
ffffffffc0203d24:	ff87a703          	lw	a4,-8(a5)
ffffffffc0203d28:	ff078693          	addi	a3,a5,-16
ffffffffc0203d2c:	9e39                	addw	a2,a2,a4
ffffffffc0203d2e:	c910                	sw	a2,16(a0)
ffffffffc0203d30:	5775                	li	a4,-3
ffffffffc0203d32:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0203d36:	6398                	ld	a4,0(a5)
ffffffffc0203d38:	679c                	ld	a5,8(a5)
}
ffffffffc0203d3a:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0203d3c:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0203d3e:	e398                	sd	a4,0(a5)
ffffffffc0203d40:	0141                	addi	sp,sp,16
ffffffffc0203d42:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0203d44:	00003697          	auipc	a3,0x3
ffffffffc0203d48:	88468693          	addi	a3,a3,-1916 # ffffffffc02065c8 <commands+0x1a60>
ffffffffc0203d4c:	00001617          	auipc	a2,0x1
ffffffffc0203d50:	7b460613          	addi	a2,a2,1972 # ffffffffc0205500 <commands+0x998>
ffffffffc0203d54:	08300593          	li	a1,131
ffffffffc0203d58:	00002517          	auipc	a0,0x2
ffffffffc0203d5c:	56050513          	addi	a0,a0,1376 # ffffffffc02062b8 <commands+0x1750>
ffffffffc0203d60:	c74fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(n > 0);
ffffffffc0203d64:	00003697          	auipc	a3,0x3
ffffffffc0203d68:	88c68693          	addi	a3,a3,-1908 # ffffffffc02065f0 <commands+0x1a88>
ffffffffc0203d6c:	00001617          	auipc	a2,0x1
ffffffffc0203d70:	79460613          	addi	a2,a2,1940 # ffffffffc0205500 <commands+0x998>
ffffffffc0203d74:	08000593          	li	a1,128
ffffffffc0203d78:	00002517          	auipc	a0,0x2
ffffffffc0203d7c:	54050513          	addi	a0,a0,1344 # ffffffffc02062b8 <commands+0x1750>
ffffffffc0203d80:	c54fc0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc0203d84 <default_alloc_pages>:
    assert(n > 0);
ffffffffc0203d84:	c959                	beqz	a0,ffffffffc0203e1a <default_alloc_pages+0x96>
    if (n > nr_free) {
ffffffffc0203d86:	00012597          	auipc	a1,0x12
ffffffffc0203d8a:	84a58593          	addi	a1,a1,-1974 # ffffffffc02155d0 <free_area>
ffffffffc0203d8e:	0105a803          	lw	a6,16(a1)
ffffffffc0203d92:	862a                	mv	a2,a0
ffffffffc0203d94:	02081793          	slli	a5,a6,0x20
ffffffffc0203d98:	9381                	srli	a5,a5,0x20
ffffffffc0203d9a:	00a7ee63          	bltu	a5,a0,ffffffffc0203db6 <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc0203d9e:	87ae                	mv	a5,a1
ffffffffc0203da0:	a801                	j	ffffffffc0203db0 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc0203da2:	ff87a703          	lw	a4,-8(a5)
ffffffffc0203da6:	02071693          	slli	a3,a4,0x20
ffffffffc0203daa:	9281                	srli	a3,a3,0x20
ffffffffc0203dac:	00c6f763          	bgeu	a3,a2,ffffffffc0203dba <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc0203db0:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0203db2:	feb798e3          	bne	a5,a1,ffffffffc0203da2 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc0203db6:	4501                	li	a0,0
}
ffffffffc0203db8:	8082                	ret
        struct Page *p = le2page(le, page_link);
ffffffffc0203dba:	fe878513          	addi	a0,a5,-24
    if (page != NULL) {
ffffffffc0203dbe:	dd6d                	beqz	a0,ffffffffc0203db8 <default_alloc_pages+0x34>
    return listelm->prev;
ffffffffc0203dc0:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0203dc4:	0087b303          	ld	t1,8(a5)
    prev->next = next;
ffffffffc0203dc8:	00060e1b          	sext.w	t3,a2
ffffffffc0203dcc:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc0203dd0:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc0203dd4:	02d67863          	bgeu	a2,a3,ffffffffc0203e04 <default_alloc_pages+0x80>
            struct Page *p = page + n;
ffffffffc0203dd8:	061a                	slli	a2,a2,0x6
ffffffffc0203dda:	962a                	add	a2,a2,a0
            p->property = page->property - n;
ffffffffc0203ddc:	41c7073b          	subw	a4,a4,t3
ffffffffc0203de0:	ca18                	sw	a4,16(a2)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0203de2:	00860693          	addi	a3,a2,8
ffffffffc0203de6:	4709                	li	a4,2
ffffffffc0203de8:	40e6b02f          	amoor.d	zero,a4,(a3)
    __list_add(elm, listelm, listelm->next);
ffffffffc0203dec:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc0203df0:	01860693          	addi	a3,a2,24
    prev->next = next->prev = elm;
ffffffffc0203df4:	0105a803          	lw	a6,16(a1)
ffffffffc0203df8:	e314                	sd	a3,0(a4)
ffffffffc0203dfa:	00d8b423          	sd	a3,8(a7)
    elm->next = next;
ffffffffc0203dfe:	f218                	sd	a4,32(a2)
    elm->prev = prev;
ffffffffc0203e00:	01163c23          	sd	a7,24(a2)
        nr_free -= n;
ffffffffc0203e04:	41c8083b          	subw	a6,a6,t3
ffffffffc0203e08:	00011717          	auipc	a4,0x11
ffffffffc0203e0c:	7d072c23          	sw	a6,2008(a4) # ffffffffc02155e0 <free_area+0x10>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0203e10:	5775                	li	a4,-3
ffffffffc0203e12:	17c1                	addi	a5,a5,-16
ffffffffc0203e14:	60e7b02f          	amoand.d	zero,a4,(a5)
ffffffffc0203e18:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc0203e1a:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0203e1c:	00002697          	auipc	a3,0x2
ffffffffc0203e20:	7d468693          	addi	a3,a3,2004 # ffffffffc02065f0 <commands+0x1a88>
ffffffffc0203e24:	00001617          	auipc	a2,0x1
ffffffffc0203e28:	6dc60613          	addi	a2,a2,1756 # ffffffffc0205500 <commands+0x998>
ffffffffc0203e2c:	06200593          	li	a1,98
ffffffffc0203e30:	00002517          	auipc	a0,0x2
ffffffffc0203e34:	48850513          	addi	a0,a0,1160 # ffffffffc02062b8 <commands+0x1750>
default_alloc_pages(size_t n) {
ffffffffc0203e38:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0203e3a:	b9afc0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc0203e3e <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc0203e3e:	1141                	addi	sp,sp,-16
ffffffffc0203e40:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0203e42:	c1ed                	beqz	a1,ffffffffc0203f24 <default_init_memmap+0xe6>
    for (; p != base + n; p ++) {
ffffffffc0203e44:	00659693          	slli	a3,a1,0x6
ffffffffc0203e48:	96aa                	add	a3,a3,a0
ffffffffc0203e4a:	02d50463          	beq	a0,a3,ffffffffc0203e72 <default_init_memmap+0x34>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0203e4e:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc0203e50:	87aa                	mv	a5,a0
ffffffffc0203e52:	8b05                	andi	a4,a4,1
ffffffffc0203e54:	e709                	bnez	a4,ffffffffc0203e5e <default_init_memmap+0x20>
ffffffffc0203e56:	a07d                	j	ffffffffc0203f04 <default_init_memmap+0xc6>
ffffffffc0203e58:	6798                	ld	a4,8(a5)
ffffffffc0203e5a:	8b05                	andi	a4,a4,1
ffffffffc0203e5c:	c745                	beqz	a4,ffffffffc0203f04 <default_init_memmap+0xc6>
        p->flags = p->property = 0;
ffffffffc0203e5e:	0007a823          	sw	zero,16(a5)
ffffffffc0203e62:	0007b423          	sd	zero,8(a5)
ffffffffc0203e66:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0203e6a:	04078793          	addi	a5,a5,64
ffffffffc0203e6e:	fed795e3          	bne	a5,a3,ffffffffc0203e58 <default_init_memmap+0x1a>
    base->property = n;
ffffffffc0203e72:	2581                	sext.w	a1,a1
ffffffffc0203e74:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0203e76:	4789                	li	a5,2
ffffffffc0203e78:	00850713          	addi	a4,a0,8
ffffffffc0203e7c:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0203e80:	00011697          	auipc	a3,0x11
ffffffffc0203e84:	75068693          	addi	a3,a3,1872 # ffffffffc02155d0 <free_area>
ffffffffc0203e88:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0203e8a:	669c                	ld	a5,8(a3)
ffffffffc0203e8c:	9db9                	addw	a1,a1,a4
ffffffffc0203e8e:	00011717          	auipc	a4,0x11
ffffffffc0203e92:	74b72923          	sw	a1,1874(a4) # ffffffffc02155e0 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc0203e96:	04d78a63          	beq	a5,a3,ffffffffc0203eea <default_init_memmap+0xac>
            struct Page* page = le2page(le, page_link);
ffffffffc0203e9a:	fe878713          	addi	a4,a5,-24
ffffffffc0203e9e:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0203ea0:	4801                	li	a6,0
ffffffffc0203ea2:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc0203ea6:	00e56a63          	bltu	a0,a4,ffffffffc0203eba <default_init_memmap+0x7c>
    return listelm->next;
ffffffffc0203eaa:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0203eac:	02d70563          	beq	a4,a3,ffffffffc0203ed6 <default_init_memmap+0x98>
        while ((le = list_next(le)) != &free_list) {
ffffffffc0203eb0:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0203eb2:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0203eb6:	fee57ae3          	bgeu	a0,a4,ffffffffc0203eaa <default_init_memmap+0x6c>
ffffffffc0203eba:	00080663          	beqz	a6,ffffffffc0203ec6 <default_init_memmap+0x88>
ffffffffc0203ebe:	00011717          	auipc	a4,0x11
ffffffffc0203ec2:	70b73923          	sd	a1,1810(a4) # ffffffffc02155d0 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0203ec6:	6398                	ld	a4,0(a5)
}
ffffffffc0203ec8:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0203eca:	e390                	sd	a2,0(a5)
ffffffffc0203ecc:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0203ece:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0203ed0:	ed18                	sd	a4,24(a0)
ffffffffc0203ed2:	0141                	addi	sp,sp,16
ffffffffc0203ed4:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0203ed6:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0203ed8:	f114                	sd	a3,32(a0)
ffffffffc0203eda:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0203edc:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc0203ede:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0203ee0:	00d70e63          	beq	a4,a3,ffffffffc0203efc <default_init_memmap+0xbe>
ffffffffc0203ee4:	4805                	li	a6,1
ffffffffc0203ee6:	87ba                	mv	a5,a4
ffffffffc0203ee8:	b7e9                	j	ffffffffc0203eb2 <default_init_memmap+0x74>
}
ffffffffc0203eea:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0203eec:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc0203ef0:	e398                	sd	a4,0(a5)
ffffffffc0203ef2:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0203ef4:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0203ef6:	ed1c                	sd	a5,24(a0)
}
ffffffffc0203ef8:	0141                	addi	sp,sp,16
ffffffffc0203efa:	8082                	ret
ffffffffc0203efc:	60a2                	ld	ra,8(sp)
ffffffffc0203efe:	e290                	sd	a2,0(a3)
ffffffffc0203f00:	0141                	addi	sp,sp,16
ffffffffc0203f02:	8082                	ret
        assert(PageReserved(p));
ffffffffc0203f04:	00002697          	auipc	a3,0x2
ffffffffc0203f08:	6f468693          	addi	a3,a3,1780 # ffffffffc02065f8 <commands+0x1a90>
ffffffffc0203f0c:	00001617          	auipc	a2,0x1
ffffffffc0203f10:	5f460613          	addi	a2,a2,1524 # ffffffffc0205500 <commands+0x998>
ffffffffc0203f14:	04900593          	li	a1,73
ffffffffc0203f18:	00002517          	auipc	a0,0x2
ffffffffc0203f1c:	3a050513          	addi	a0,a0,928 # ffffffffc02062b8 <commands+0x1750>
ffffffffc0203f20:	ab4fc0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(n > 0);
ffffffffc0203f24:	00002697          	auipc	a3,0x2
ffffffffc0203f28:	6cc68693          	addi	a3,a3,1740 # ffffffffc02065f0 <commands+0x1a88>
ffffffffc0203f2c:	00001617          	auipc	a2,0x1
ffffffffc0203f30:	5d460613          	addi	a2,a2,1492 # ffffffffc0205500 <commands+0x998>
ffffffffc0203f34:	04600593          	li	a1,70
ffffffffc0203f38:	00002517          	auipc	a0,0x2
ffffffffc0203f3c:	38050513          	addi	a0,a0,896 # ffffffffc02062b8 <commands+0x1750>
ffffffffc0203f40:	a94fc0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc0203f44 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0203f44:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203f46:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0203f48:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203f4a:	d64fc0ef          	jal	ra,ffffffffc02004ae <ide_device_valid>
ffffffffc0203f4e:	cd01                	beqz	a0,ffffffffc0203f66 <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203f50:	4505                	li	a0,1
ffffffffc0203f52:	d62fc0ef          	jal	ra,ffffffffc02004b4 <ide_device_size>
}
ffffffffc0203f56:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203f58:	810d                	srli	a0,a0,0x3
ffffffffc0203f5a:	00011797          	auipc	a5,0x11
ffffffffc0203f5e:	62a7b323          	sd	a0,1574(a5) # ffffffffc0215580 <max_swap_offset>
}
ffffffffc0203f62:	0141                	addi	sp,sp,16
ffffffffc0203f64:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0203f66:	00002617          	auipc	a2,0x2
ffffffffc0203f6a:	6f260613          	addi	a2,a2,1778 # ffffffffc0206658 <default_pmm_manager+0x50>
ffffffffc0203f6e:	45b5                	li	a1,13
ffffffffc0203f70:	00002517          	auipc	a0,0x2
ffffffffc0203f74:	70850513          	addi	a0,a0,1800 # ffffffffc0206678 <default_pmm_manager+0x70>
ffffffffc0203f78:	a5cfc0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc0203f7c <swapfs_write>:
swapfs_read(swap_entry_t entry, struct Page *page) {
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
}

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0203f7c:	1141                	addi	sp,sp,-16
ffffffffc0203f7e:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203f80:	00855793          	srli	a5,a0,0x8
ffffffffc0203f84:	cfb9                	beqz	a5,ffffffffc0203fe2 <swapfs_write+0x66>
ffffffffc0203f86:	00011717          	auipc	a4,0x11
ffffffffc0203f8a:	5fa70713          	addi	a4,a4,1530 # ffffffffc0215580 <max_swap_offset>
ffffffffc0203f8e:	6318                	ld	a4,0(a4)
ffffffffc0203f90:	04e7f963          	bgeu	a5,a4,ffffffffc0203fe2 <swapfs_write+0x66>
    return page - pages + nbase;
ffffffffc0203f94:	00011717          	auipc	a4,0x11
ffffffffc0203f98:	55470713          	addi	a4,a4,1364 # ffffffffc02154e8 <pages>
ffffffffc0203f9c:	6310                	ld	a2,0(a4)
ffffffffc0203f9e:	00003717          	auipc	a4,0x3
ffffffffc0203fa2:	a9a70713          	addi	a4,a4,-1382 # ffffffffc0206a38 <nbase>
ffffffffc0203fa6:	40c58633          	sub	a2,a1,a2
ffffffffc0203faa:	630c                	ld	a1,0(a4)
ffffffffc0203fac:	8619                	srai	a2,a2,0x6
    return KADDR(page2pa(page));
ffffffffc0203fae:	00011717          	auipc	a4,0x11
ffffffffc0203fb2:	4d270713          	addi	a4,a4,1234 # ffffffffc0215480 <npage>
    return page - pages + nbase;
ffffffffc0203fb6:	962e                	add	a2,a2,a1
    return KADDR(page2pa(page));
ffffffffc0203fb8:	6314                	ld	a3,0(a4)
ffffffffc0203fba:	00c61713          	slli	a4,a2,0xc
ffffffffc0203fbe:	8331                	srli	a4,a4,0xc
ffffffffc0203fc0:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0203fc4:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0203fc6:	02d77a63          	bgeu	a4,a3,ffffffffc0203ffa <swapfs_write+0x7e>
ffffffffc0203fca:	00011797          	auipc	a5,0x11
ffffffffc0203fce:	50e78793          	addi	a5,a5,1294 # ffffffffc02154d8 <va_pa_offset>
ffffffffc0203fd2:	639c                	ld	a5,0(a5)
}
ffffffffc0203fd4:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203fd6:	46a1                	li	a3,8
ffffffffc0203fd8:	963e                	add	a2,a2,a5
ffffffffc0203fda:	4505                	li	a0,1
}
ffffffffc0203fdc:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203fde:	cdcfc06f          	j	ffffffffc02004ba <ide_write_secs>
ffffffffc0203fe2:	86aa                	mv	a3,a0
ffffffffc0203fe4:	00002617          	auipc	a2,0x2
ffffffffc0203fe8:	6ac60613          	addi	a2,a2,1708 # ffffffffc0206690 <default_pmm_manager+0x88>
ffffffffc0203fec:	45e5                	li	a1,25
ffffffffc0203fee:	00002517          	auipc	a0,0x2
ffffffffc0203ff2:	68a50513          	addi	a0,a0,1674 # ffffffffc0206678 <default_pmm_manager+0x70>
ffffffffc0203ff6:	9defc0ef          	jal	ra,ffffffffc02001d4 <__panic>
ffffffffc0203ffa:	86b2                	mv	a3,a2
ffffffffc0203ffc:	06900593          	li	a1,105
ffffffffc0204000:	00001617          	auipc	a2,0x1
ffffffffc0204004:	3a860613          	addi	a2,a2,936 # ffffffffc02053a8 <commands+0x840>
ffffffffc0204008:	00001517          	auipc	a0,0x1
ffffffffc020400c:	3f850513          	addi	a0,a0,1016 # ffffffffc0205400 <commands+0x898>
ffffffffc0204010:	9c4fc0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc0204014 <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc0204014:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc0204018:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc020401c:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc020401e:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc0204020:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc0204024:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc0204028:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc020402c:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc0204030:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc0204034:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc0204038:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc020403c:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc0204040:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc0204044:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc0204048:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc020404c:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc0204050:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc0204052:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc0204054:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc0204058:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc020405c:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc0204060:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc0204064:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc0204068:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc020406c:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc0204070:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc0204074:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc0204078:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc020407c:	8082                	ret

ffffffffc020407e <set_proc_name>:
    return proc;
}

// set_proc_name - set the name of proc
char *
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc020407e:	1101                	addi	sp,sp,-32
ffffffffc0204080:	e822                	sd	s0,16(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204082:	0b450413          	addi	s0,a0,180
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204086:	e426                	sd	s1,8(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204088:	4641                	li	a2,16
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc020408a:	84ae                	mv	s1,a1
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc020408c:	8522                	mv	a0,s0
ffffffffc020408e:	4581                	li	a1,0
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204090:	ec06                	sd	ra,24(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204092:	526000ef          	jal	ra,ffffffffc02045b8 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204096:	8522                	mv	a0,s0
}
ffffffffc0204098:	6442                	ld	s0,16(sp)
ffffffffc020409a:	60e2                	ld	ra,24(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc020409c:	85a6                	mv	a1,s1
}
ffffffffc020409e:	64a2                	ld	s1,8(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc02040a0:	463d                	li	a2,15
}
ffffffffc02040a2:	6105                	addi	sp,sp,32
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc02040a4:	a31d                	j	ffffffffc02045ca <memcpy>

ffffffffc02040a6 <get_proc_name>:

// get_proc_name - get the name of proc
char *
get_proc_name(struct proc_struct *proc) {
ffffffffc02040a6:	1101                	addi	sp,sp,-32
ffffffffc02040a8:	e822                	sd	s0,16(sp)
    static char name[PROC_NAME_LEN + 1];
    memset(name, 0, sizeof(name));
ffffffffc02040aa:	00011417          	auipc	s0,0x11
ffffffffc02040ae:	3ae40413          	addi	s0,s0,942 # ffffffffc0215458 <name.1565>
get_proc_name(struct proc_struct *proc) {
ffffffffc02040b2:	e426                	sd	s1,8(sp)
    memset(name, 0, sizeof(name));
ffffffffc02040b4:	4641                	li	a2,16
get_proc_name(struct proc_struct *proc) {
ffffffffc02040b6:	84aa                	mv	s1,a0
    memset(name, 0, sizeof(name));
ffffffffc02040b8:	4581                	li	a1,0
ffffffffc02040ba:	8522                	mv	a0,s0
get_proc_name(struct proc_struct *proc) {
ffffffffc02040bc:	ec06                	sd	ra,24(sp)
    memset(name, 0, sizeof(name));
ffffffffc02040be:	4fa000ef          	jal	ra,ffffffffc02045b8 <memset>
    return memcpy(name, proc->name, PROC_NAME_LEN);
ffffffffc02040c2:	8522                	mv	a0,s0
}
ffffffffc02040c4:	6442                	ld	s0,16(sp)
ffffffffc02040c6:	60e2                	ld	ra,24(sp)
    return memcpy(name, proc->name, PROC_NAME_LEN);
ffffffffc02040c8:	0b448593          	addi	a1,s1,180
}
ffffffffc02040cc:	64a2                	ld	s1,8(sp)
    return memcpy(name, proc->name, PROC_NAME_LEN);
ffffffffc02040ce:	463d                	li	a2,15
}
ffffffffc02040d0:	6105                	addi	sp,sp,32
    return memcpy(name, proc->name, PROC_NAME_LEN);
ffffffffc02040d2:	a9e5                	j	ffffffffc02045ca <memcpy>

ffffffffc02040d4 <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc02040d4:	00011797          	auipc	a5,0x11
ffffffffc02040d8:	3d478793          	addi	a5,a5,980 # ffffffffc02154a8 <current>
ffffffffc02040dc:	639c                	ld	a5,0(a5)
init_main(void *arg) {
ffffffffc02040de:	1101                	addi	sp,sp,-32
ffffffffc02040e0:	e426                	sd	s1,8(sp)
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc02040e2:	43c4                	lw	s1,4(a5)
init_main(void *arg) {
ffffffffc02040e4:	e822                	sd	s0,16(sp)
ffffffffc02040e6:	842a                	mv	s0,a0
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc02040e8:	853e                	mv	a0,a5
init_main(void *arg) {
ffffffffc02040ea:	ec06                	sd	ra,24(sp)
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc02040ec:	fbbff0ef          	jal	ra,ffffffffc02040a6 <get_proc_name>
ffffffffc02040f0:	862a                	mv	a2,a0
ffffffffc02040f2:	85a6                	mv	a1,s1
ffffffffc02040f4:	00002517          	auipc	a0,0x2
ffffffffc02040f8:	5ec50513          	addi	a0,a0,1516 # ffffffffc02066e0 <default_pmm_manager+0xd8>
ffffffffc02040fc:	fd5fb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("To U: \"%s\".\n", (const char *)arg);
ffffffffc0204100:	85a2                	mv	a1,s0
ffffffffc0204102:	00002517          	auipc	a0,0x2
ffffffffc0204106:	60650513          	addi	a0,a0,1542 # ffffffffc0206708 <default_pmm_manager+0x100>
ffffffffc020410a:	fc7fb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("To U: \"en.., Bye, Bye. :)\"\n");
ffffffffc020410e:	00002517          	auipc	a0,0x2
ffffffffc0204112:	60a50513          	addi	a0,a0,1546 # ffffffffc0206718 <default_pmm_manager+0x110>
ffffffffc0204116:	fbbfb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    return 0;
}
ffffffffc020411a:	60e2                	ld	ra,24(sp)
ffffffffc020411c:	6442                	ld	s0,16(sp)
ffffffffc020411e:	64a2                	ld	s1,8(sp)
ffffffffc0204120:	4501                	li	a0,0
ffffffffc0204122:	6105                	addi	sp,sp,32
ffffffffc0204124:	8082                	ret

ffffffffc0204126 <proc_run>:
proc_run(struct proc_struct *proc) {
ffffffffc0204126:	1101                	addi	sp,sp,-32
ffffffffc0204128:	e426                	sd	s1,8(sp)
    if (proc != current) {
ffffffffc020412a:	00011497          	auipc	s1,0x11
ffffffffc020412e:	37e48493          	addi	s1,s1,894 # ffffffffc02154a8 <current>
proc_run(struct proc_struct *proc) {
ffffffffc0204132:	e822                	sd	s0,16(sp)
    if (proc != current) {
ffffffffc0204134:	6080                	ld	s0,0(s1)
proc_run(struct proc_struct *proc) {
ffffffffc0204136:	ec06                	sd	ra,24(sp)
ffffffffc0204138:	e04a                	sd	s2,0(sp)
    if (proc != current) {
ffffffffc020413a:	02a40b63          	beq	s0,a0,ffffffffc0204170 <proc_run+0x4a>
        current = proc;//前一个进程和后一个进程,就两个进程
ffffffffc020413e:	00011797          	auipc	a5,0x11
ffffffffc0204142:	36a7b523          	sd	a0,874(a5) # ffffffffc02154a8 <current>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204146:	100027f3          	csrr	a5,sstatus
ffffffffc020414a:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020414c:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020414e:	ef95                	bnez	a5,ffffffffc020418a <proc_run+0x64>
            lcr3(current->cr3);//切换页表
ffffffffc0204150:	755c                	ld	a5,168(a0)

#define barrier() __asm__ __volatile__ ("fence" ::: "memory")

static inline void
lcr3(unsigned int cr3) {
    write_csr(sptbr, SATP32_MODE | (cr3 >> RISCV_PGSHIFT));
ffffffffc0204152:	80000737          	lui	a4,0x80000
ffffffffc0204156:	00c7d79b          	srliw	a5,a5,0xc
ffffffffc020415a:	8fd9                	or	a5,a5,a4
ffffffffc020415c:	18079073          	csrw	satp,a5
            switch_to(&(prev->context), &(current->context));
ffffffffc0204160:	03050593          	addi	a1,a0,48
ffffffffc0204164:	03040513          	addi	a0,s0,48
ffffffffc0204168:	eadff0ef          	jal	ra,ffffffffc0204014 <switch_to>
    if (flag) {
ffffffffc020416c:	00091863          	bnez	s2,ffffffffc020417c <proc_run+0x56>
}
ffffffffc0204170:	60e2                	ld	ra,24(sp)
ffffffffc0204172:	6442                	ld	s0,16(sp)
ffffffffc0204174:	64a2                	ld	s1,8(sp)
ffffffffc0204176:	6902                	ld	s2,0(sp)
ffffffffc0204178:	6105                	addi	sp,sp,32
ffffffffc020417a:	8082                	ret
ffffffffc020417c:	6442                	ld	s0,16(sp)
ffffffffc020417e:	60e2                	ld	ra,24(sp)
ffffffffc0204180:	64a2                	ld	s1,8(sp)
ffffffffc0204182:	6902                	ld	s2,0(sp)
ffffffffc0204184:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0204186:	c22fc06f          	j	ffffffffc02005a8 <intr_enable>
        intr_disable();
ffffffffc020418a:	c24fc0ef          	jal	ra,ffffffffc02005ae <intr_disable>
        return 1;
ffffffffc020418e:	6088                	ld	a0,0(s1)
ffffffffc0204190:	4905                	li	s2,1
ffffffffc0204192:	bf7d                	j	ffffffffc0204150 <proc_run+0x2a>

ffffffffc0204194 <find_proc>:
    if (0 < pid && pid < MAX_PID) {
ffffffffc0204194:	0005071b          	sext.w	a4,a0
ffffffffc0204198:	6789                	lui	a5,0x2
ffffffffc020419a:	fff7069b          	addiw	a3,a4,-1
ffffffffc020419e:	17f9                	addi	a5,a5,-2
ffffffffc02041a0:	04d7e063          	bltu	a5,a3,ffffffffc02041e0 <find_proc+0x4c>
find_proc(int pid) {
ffffffffc02041a4:	1141                	addi	sp,sp,-16
ffffffffc02041a6:	e022                	sd	s0,0(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc02041a8:	45a9                	li	a1,10
ffffffffc02041aa:	842a                	mv	s0,a0
ffffffffc02041ac:	853a                	mv	a0,a4
find_proc(int pid) {
ffffffffc02041ae:	e406                	sd	ra,8(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc02041b0:	04f000ef          	jal	ra,ffffffffc02049fe <hash32>
ffffffffc02041b4:	02051693          	slli	a3,a0,0x20
ffffffffc02041b8:	82f1                	srli	a3,a3,0x1c
ffffffffc02041ba:	0000d517          	auipc	a0,0xd
ffffffffc02041be:	29e50513          	addi	a0,a0,670 # ffffffffc0211458 <hash_list>
ffffffffc02041c2:	96aa                	add	a3,a3,a0
ffffffffc02041c4:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list) {
ffffffffc02041c6:	a029                	j	ffffffffc02041d0 <find_proc+0x3c>
            if (proc->pid == pid) {
ffffffffc02041c8:	f2c7a703          	lw	a4,-212(a5) # 1f2c <BASE_ADDRESS-0xffffffffc01fe0d4>
ffffffffc02041cc:	00870c63          	beq	a4,s0,ffffffffc02041e4 <find_proc+0x50>
    return listelm->next;
ffffffffc02041d0:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc02041d2:	fef69be3          	bne	a3,a5,ffffffffc02041c8 <find_proc+0x34>
}
ffffffffc02041d6:	60a2                	ld	ra,8(sp)
ffffffffc02041d8:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc02041da:	4501                	li	a0,0
}
ffffffffc02041dc:	0141                	addi	sp,sp,16
ffffffffc02041de:	8082                	ret
    return NULL;
ffffffffc02041e0:	4501                	li	a0,0
}
ffffffffc02041e2:	8082                	ret
ffffffffc02041e4:	60a2                	ld	ra,8(sp)
ffffffffc02041e6:	6402                	ld	s0,0(sp)
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc02041e8:	f2878513          	addi	a0,a5,-216
}
ffffffffc02041ec:	0141                	addi	sp,sp,16
ffffffffc02041ee:	8082                	ret

ffffffffc02041f0 <kernel_thread>:
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc02041f0:	7169                	addi	sp,sp,-304
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc02041f2:	12000613          	li	a2,288
ffffffffc02041f6:	4581                	li	a1,0
ffffffffc02041f8:	850a                	mv	a0,sp
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc02041fa:	f606                	sd	ra,296(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc02041fc:	3bc000ef          	jal	ra,ffffffffc02045b8 <memset>
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc0204200:	100027f3          	csrr	a5,sstatus
    if (nr_process >= MAX_PROCESS) {
ffffffffc0204204:	00011797          	auipc	a5,0x11
ffffffffc0204208:	2bc78793          	addi	a5,a5,700 # ffffffffc02154c0 <nr_process>
ffffffffc020420c:	4388                	lw	a0,0(a5)
}
ffffffffc020420e:	70b2                	ld	ra,296(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc0204210:	6785                	lui	a5,0x1
    int ret = -E_NO_FREE_PROC;
ffffffffc0204212:	00f52533          	slt	a0,a0,a5
}
ffffffffc0204216:	156d                	addi	a0,a0,-5
ffffffffc0204218:	6155                	addi	sp,sp,304
ffffffffc020421a:	8082                	ret

ffffffffc020421c <proc_init>:
    elm->prev = elm->next = elm;
ffffffffc020421c:	00011797          	auipc	a5,0x11
ffffffffc0204220:	3cc78793          	addi	a5,a5,972 # ffffffffc02155e8 <proc_list>

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
ffffffffc0204224:	7179                	addi	sp,sp,-48
ffffffffc0204226:	00011717          	auipc	a4,0x11
ffffffffc020422a:	3cf73523          	sd	a5,970(a4) # ffffffffc02155f0 <proc_list+0x8>
ffffffffc020422e:	00011717          	auipc	a4,0x11
ffffffffc0204232:	3af73d23          	sd	a5,954(a4) # ffffffffc02155e8 <proc_list>
ffffffffc0204236:	f406                	sd	ra,40(sp)
ffffffffc0204238:	f022                	sd	s0,32(sp)
ffffffffc020423a:	ec26                	sd	s1,24(sp)
ffffffffc020423c:	e84a                	sd	s2,16(sp)
ffffffffc020423e:	e44e                	sd	s3,8(sp)
ffffffffc0204240:	e052                	sd	s4,0(sp)
ffffffffc0204242:	0000d797          	auipc	a5,0xd
ffffffffc0204246:	21678793          	addi	a5,a5,534 # ffffffffc0211458 <hash_list>
ffffffffc020424a:	00011717          	auipc	a4,0x11
ffffffffc020424e:	20e70713          	addi	a4,a4,526 # ffffffffc0215458 <name.1565>
ffffffffc0204252:	e79c                	sd	a5,8(a5)
ffffffffc0204254:	e39c                	sd	a5,0(a5)
ffffffffc0204256:	07c1                	addi	a5,a5,16
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
ffffffffc0204258:	fee79de3          	bne	a5,a4,ffffffffc0204252 <proc_init+0x36>
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));// 分配空间
ffffffffc020425c:	0e800513          	li	a0,232
ffffffffc0204260:	bcffe0ef          	jal	ra,ffffffffc0202e2e <kmalloc>
ffffffffc0204264:	842a                	mv	s0,a0
    if (proc != NULL) {
ffffffffc0204266:	18050363          	beqz	a0,ffffffffc02043ec <proc_init+0x1d0>
        proc->state = PROC_UNINIT;
ffffffffc020426a:	54fd                	li	s1,-1
ffffffffc020426c:	1482                	slli	s1,s1,0x20
        memset(&(proc->context),0,sizeof(struct context));
ffffffffc020426e:	07000613          	li	a2,112
ffffffffc0204272:	4581                	li	a1,0
        proc->state = PROC_UNINIT;
ffffffffc0204274:	e104                	sd	s1,0(a0)
        proc->runs = 0;
ffffffffc0204276:	00052423          	sw	zero,8(a0)
        proc->kstack = 0;
ffffffffc020427a:	00053823          	sd	zero,16(a0)
        proc->need_resched = 0;
ffffffffc020427e:	00052c23          	sw	zero,24(a0)
        proc->parent = NULL;
ffffffffc0204282:	02053023          	sd	zero,32(a0)
        proc->mm = NULL;
ffffffffc0204286:	02053423          	sd	zero,40(a0)
        memset(&(proc->context),0,sizeof(struct context));
ffffffffc020428a:	03050513          	addi	a0,a0,48
ffffffffc020428e:	32a000ef          	jal	ra,ffffffffc02045b8 <memset>
        proc->cr3 = boot_cr3;
ffffffffc0204292:	00011917          	auipc	s2,0x11
ffffffffc0204296:	24e90913          	addi	s2,s2,590 # ffffffffc02154e0 <boot_cr3>
ffffffffc020429a:	00093783          	ld	a5,0(s2)
        memset(&(proc->name),0,PROC_NAME_LEN);
ffffffffc020429e:	463d                	li	a2,15
ffffffffc02042a0:	4581                	li	a1,0
        proc->cr3 = boot_cr3;
ffffffffc02042a2:	f45c                	sd	a5,168(s0)
        proc->tf = NULL;
ffffffffc02042a4:	0a043023          	sd	zero,160(s0)
        proc->flags = 0;
ffffffffc02042a8:	0a042823          	sw	zero,176(s0)
        memset(&(proc->name),0,PROC_NAME_LEN);
ffffffffc02042ac:	0b440513          	addi	a0,s0,180
ffffffffc02042b0:	308000ef          	jal	ra,ffffffffc02045b8 <memset>
    if ((idleproc = alloc_proc()) == NULL) {
        panic("cannot alloc idleproc.\n");
    }

    // check the proc structure
    int *context_mem = (int*) kmalloc(sizeof(struct context));
ffffffffc02042b4:	07000513          	li	a0,112
    if ((idleproc = alloc_proc()) == NULL) {
ffffffffc02042b8:	00011797          	auipc	a5,0x11
ffffffffc02042bc:	1e87bc23          	sd	s0,504(a5) # ffffffffc02154b0 <idleproc>
    int *context_mem = (int*) kmalloc(sizeof(struct context));
ffffffffc02042c0:	b6ffe0ef          	jal	ra,ffffffffc0202e2e <kmalloc>
    memset(context_mem, 0, sizeof(struct context));
ffffffffc02042c4:	07000613          	li	a2,112
ffffffffc02042c8:	4581                	li	a1,0
    int *context_mem = (int*) kmalloc(sizeof(struct context));
ffffffffc02042ca:	89aa                	mv	s3,a0
    if ((idleproc = alloc_proc()) == NULL) {
ffffffffc02042cc:	00011417          	auipc	s0,0x11
ffffffffc02042d0:	1e440413          	addi	s0,s0,484 # ffffffffc02154b0 <idleproc>
    memset(context_mem, 0, sizeof(struct context));
ffffffffc02042d4:	2e4000ef          	jal	ra,ffffffffc02045b8 <memset>
    int context_init_flag = memcmp(&(idleproc->context), context_mem, sizeof(struct context));
ffffffffc02042d8:	6008                	ld	a0,0(s0)
ffffffffc02042da:	85ce                	mv	a1,s3
ffffffffc02042dc:	07000613          	li	a2,112
ffffffffc02042e0:	03050513          	addi	a0,a0,48
ffffffffc02042e4:	2fe000ef          	jal	ra,ffffffffc02045e2 <memcmp>
ffffffffc02042e8:	8a2a                	mv	s4,a0

    int *proc_name_mem = (int*) kmalloc(PROC_NAME_LEN);
ffffffffc02042ea:	453d                	li	a0,15
ffffffffc02042ec:	b43fe0ef          	jal	ra,ffffffffc0202e2e <kmalloc>
    memset(proc_name_mem, 0, PROC_NAME_LEN);
ffffffffc02042f0:	463d                	li	a2,15
ffffffffc02042f2:	4581                	li	a1,0
    int *proc_name_mem = (int*) kmalloc(PROC_NAME_LEN);
ffffffffc02042f4:	89aa                	mv	s3,a0
    memset(proc_name_mem, 0, PROC_NAME_LEN);
ffffffffc02042f6:	2c2000ef          	jal	ra,ffffffffc02045b8 <memset>
    int proc_name_flag = memcmp(&(idleproc->name), proc_name_mem, PROC_NAME_LEN);
ffffffffc02042fa:	6008                	ld	a0,0(s0)
ffffffffc02042fc:	463d                	li	a2,15
ffffffffc02042fe:	85ce                	mv	a1,s3
ffffffffc0204300:	0b450513          	addi	a0,a0,180
ffffffffc0204304:	2de000ef          	jal	ra,ffffffffc02045e2 <memcmp>

    if(idleproc->cr3 == boot_cr3 && idleproc->tf == NULL && !context_init_flag
ffffffffc0204308:	601c                	ld	a5,0(s0)
ffffffffc020430a:	00093703          	ld	a4,0(s2)
ffffffffc020430e:	77d4                	ld	a3,168(a5)
ffffffffc0204310:	08e68f63          	beq	a3,a4,ffffffffc02043ae <proc_init+0x192>
        cprintf("alloc_proc() correct!\n");

    }
    
    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc0204314:	4709                	li	a4,2
ffffffffc0204316:	e398                	sd	a4,0(a5)
    idleproc->kstack = (uintptr_t)bootstack;
    idleproc->need_resched = 1;
ffffffffc0204318:	4485                	li	s1,1
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc020431a:	00003717          	auipc	a4,0x3
ffffffffc020431e:	ce670713          	addi	a4,a4,-794 # ffffffffc0207000 <bootstack>
ffffffffc0204322:	eb98                	sd	a4,16(a5)
    set_proc_name(idleproc, "idle");
ffffffffc0204324:	00002597          	auipc	a1,0x2
ffffffffc0204328:	42c58593          	addi	a1,a1,1068 # ffffffffc0206750 <default_pmm_manager+0x148>
    idleproc->need_resched = 1;
ffffffffc020432c:	cf84                	sw	s1,24(a5)
    set_proc_name(idleproc, "idle");
ffffffffc020432e:	853e                	mv	a0,a5
ffffffffc0204330:	d4fff0ef          	jal	ra,ffffffffc020407e <set_proc_name>
    nr_process ++;
ffffffffc0204334:	00011797          	auipc	a5,0x11
ffffffffc0204338:	18c78793          	addi	a5,a5,396 # ffffffffc02154c0 <nr_process>
ffffffffc020433c:	439c                	lw	a5,0(a5)

    current = idleproc;
ffffffffc020433e:	6018                	ld	a4,0(s0)

    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc0204340:	4601                	li	a2,0
    nr_process ++;
ffffffffc0204342:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc0204344:	00002597          	auipc	a1,0x2
ffffffffc0204348:	41458593          	addi	a1,a1,1044 # ffffffffc0206758 <default_pmm_manager+0x150>
ffffffffc020434c:	00000517          	auipc	a0,0x0
ffffffffc0204350:	d8850513          	addi	a0,a0,-632 # ffffffffc02040d4 <init_main>
    nr_process ++;
ffffffffc0204354:	00011697          	auipc	a3,0x11
ffffffffc0204358:	16f6a623          	sw	a5,364(a3) # ffffffffc02154c0 <nr_process>
    current = idleproc;
ffffffffc020435c:	00011797          	auipc	a5,0x11
ffffffffc0204360:	14e7b623          	sd	a4,332(a5) # ffffffffc02154a8 <current>
    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc0204364:	e8dff0ef          	jal	ra,ffffffffc02041f0 <kernel_thread>
    if (pid <= 0) {
ffffffffc0204368:	0ea05263          	blez	a0,ffffffffc020444c <proc_init+0x230>
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc020436c:	e29ff0ef          	jal	ra,ffffffffc0204194 <find_proc>
    set_proc_name(initproc, "init");
ffffffffc0204370:	00002597          	auipc	a1,0x2
ffffffffc0204374:	41858593          	addi	a1,a1,1048 # ffffffffc0206788 <default_pmm_manager+0x180>
    initproc = find_proc(pid);
ffffffffc0204378:	00011797          	auipc	a5,0x11
ffffffffc020437c:	14a7b023          	sd	a0,320(a5) # ffffffffc02154b8 <initproc>
    set_proc_name(initproc, "init");
ffffffffc0204380:	cffff0ef          	jal	ra,ffffffffc020407e <set_proc_name>

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0204384:	601c                	ld	a5,0(s0)
ffffffffc0204386:	c3dd                	beqz	a5,ffffffffc020442c <proc_init+0x210>
ffffffffc0204388:	43dc                	lw	a5,4(a5)
ffffffffc020438a:	e3cd                	bnez	a5,ffffffffc020442c <proc_init+0x210>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc020438c:	00011797          	auipc	a5,0x11
ffffffffc0204390:	12c78793          	addi	a5,a5,300 # ffffffffc02154b8 <initproc>
ffffffffc0204394:	639c                	ld	a5,0(a5)
ffffffffc0204396:	cbbd                	beqz	a5,ffffffffc020440c <proc_init+0x1f0>
ffffffffc0204398:	43dc                	lw	a5,4(a5)
ffffffffc020439a:	06979963          	bne	a5,s1,ffffffffc020440c <proc_init+0x1f0>
}
ffffffffc020439e:	70a2                	ld	ra,40(sp)
ffffffffc02043a0:	7402                	ld	s0,32(sp)
ffffffffc02043a2:	64e2                	ld	s1,24(sp)
ffffffffc02043a4:	6942                	ld	s2,16(sp)
ffffffffc02043a6:	69a2                	ld	s3,8(sp)
ffffffffc02043a8:	6a02                	ld	s4,0(sp)
ffffffffc02043aa:	6145                	addi	sp,sp,48
ffffffffc02043ac:	8082                	ret
    if(idleproc->cr3 == boot_cr3 && idleproc->tf == NULL && !context_init_flag
ffffffffc02043ae:	73d8                	ld	a4,160(a5)
ffffffffc02043b0:	f335                	bnez	a4,ffffffffc0204314 <proc_init+0xf8>
ffffffffc02043b2:	f60a11e3          	bnez	s4,ffffffffc0204314 <proc_init+0xf8>
        && idleproc->state == PROC_UNINIT && idleproc->pid == -1 && idleproc->runs == 0
ffffffffc02043b6:	6398                	ld	a4,0(a5)
ffffffffc02043b8:	f4971ee3          	bne	a4,s1,ffffffffc0204314 <proc_init+0xf8>
ffffffffc02043bc:	4798                	lw	a4,8(a5)
ffffffffc02043be:	fb39                	bnez	a4,ffffffffc0204314 <proc_init+0xf8>
        && idleproc->kstack == 0 && idleproc->need_resched == 0 && idleproc->parent == NULL
ffffffffc02043c0:	6b98                	ld	a4,16(a5)
ffffffffc02043c2:	fb29                	bnez	a4,ffffffffc0204314 <proc_init+0xf8>
ffffffffc02043c4:	4f98                	lw	a4,24(a5)
ffffffffc02043c6:	2701                	sext.w	a4,a4
ffffffffc02043c8:	f731                	bnez	a4,ffffffffc0204314 <proc_init+0xf8>
ffffffffc02043ca:	7398                	ld	a4,32(a5)
ffffffffc02043cc:	f721                	bnez	a4,ffffffffc0204314 <proc_init+0xf8>
        && idleproc->mm == NULL && idleproc->flags == 0 && !proc_name_flag
ffffffffc02043ce:	7798                	ld	a4,40(a5)
ffffffffc02043d0:	f331                	bnez	a4,ffffffffc0204314 <proc_init+0xf8>
ffffffffc02043d2:	0b07a703          	lw	a4,176(a5)
ffffffffc02043d6:	8f49                	or	a4,a4,a0
ffffffffc02043d8:	2701                	sext.w	a4,a4
ffffffffc02043da:	ff0d                	bnez	a4,ffffffffc0204314 <proc_init+0xf8>
        cprintf("alloc_proc() correct!\n");
ffffffffc02043dc:	00002517          	auipc	a0,0x2
ffffffffc02043e0:	35c50513          	addi	a0,a0,860 # ffffffffc0206738 <default_pmm_manager+0x130>
ffffffffc02043e4:	cedfb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc02043e8:	601c                	ld	a5,0(s0)
ffffffffc02043ea:	b72d                	j	ffffffffc0204314 <proc_init+0xf8>
        panic("cannot alloc idleproc.\n");
ffffffffc02043ec:	00002617          	auipc	a2,0x2
ffffffffc02043f0:	3f460613          	addi	a2,a2,1012 # ffffffffc02067e0 <default_pmm_manager+0x1d8>
ffffffffc02043f4:	16c00593          	li	a1,364
ffffffffc02043f8:	00002517          	auipc	a0,0x2
ffffffffc02043fc:	2d050513          	addi	a0,a0,720 # ffffffffc02066c8 <default_pmm_manager+0xc0>
    if ((idleproc = alloc_proc()) == NULL) {
ffffffffc0204400:	00011797          	auipc	a5,0x11
ffffffffc0204404:	0a07b823          	sd	zero,176(a5) # ffffffffc02154b0 <idleproc>
        panic("cannot alloc idleproc.\n");
ffffffffc0204408:	dcdfb0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc020440c:	00002697          	auipc	a3,0x2
ffffffffc0204410:	3ac68693          	addi	a3,a3,940 # ffffffffc02067b8 <default_pmm_manager+0x1b0>
ffffffffc0204414:	00001617          	auipc	a2,0x1
ffffffffc0204418:	0ec60613          	addi	a2,a2,236 # ffffffffc0205500 <commands+0x998>
ffffffffc020441c:	19300593          	li	a1,403
ffffffffc0204420:	00002517          	auipc	a0,0x2
ffffffffc0204424:	2a850513          	addi	a0,a0,680 # ffffffffc02066c8 <default_pmm_manager+0xc0>
ffffffffc0204428:	dadfb0ef          	jal	ra,ffffffffc02001d4 <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc020442c:	00002697          	auipc	a3,0x2
ffffffffc0204430:	36468693          	addi	a3,a3,868 # ffffffffc0206790 <default_pmm_manager+0x188>
ffffffffc0204434:	00001617          	auipc	a2,0x1
ffffffffc0204438:	0cc60613          	addi	a2,a2,204 # ffffffffc0205500 <commands+0x998>
ffffffffc020443c:	19200593          	li	a1,402
ffffffffc0204440:	00002517          	auipc	a0,0x2
ffffffffc0204444:	28850513          	addi	a0,a0,648 # ffffffffc02066c8 <default_pmm_manager+0xc0>
ffffffffc0204448:	d8dfb0ef          	jal	ra,ffffffffc02001d4 <__panic>
        panic("create init_main failed.\n");
ffffffffc020444c:	00002617          	auipc	a2,0x2
ffffffffc0204450:	31c60613          	addi	a2,a2,796 # ffffffffc0206768 <default_pmm_manager+0x160>
ffffffffc0204454:	18c00593          	li	a1,396
ffffffffc0204458:	00002517          	auipc	a0,0x2
ffffffffc020445c:	27050513          	addi	a0,a0,624 # ffffffffc02066c8 <default_pmm_manager+0xc0>
ffffffffc0204460:	d75fb0ef          	jal	ra,ffffffffc02001d4 <__panic>

ffffffffc0204464 <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
ffffffffc0204464:	1141                	addi	sp,sp,-16
ffffffffc0204466:	e022                	sd	s0,0(sp)
ffffffffc0204468:	e406                	sd	ra,8(sp)
ffffffffc020446a:	00011417          	auipc	s0,0x11
ffffffffc020446e:	03e40413          	addi	s0,s0,62 # ffffffffc02154a8 <current>
    while (1) {
        if (current->need_resched) {
ffffffffc0204472:	6018                	ld	a4,0(s0)
ffffffffc0204474:	4f1c                	lw	a5,24(a4)
ffffffffc0204476:	2781                	sext.w	a5,a5
ffffffffc0204478:	dff5                	beqz	a5,ffffffffc0204474 <cpu_idle+0x10>
            schedule();
ffffffffc020447a:	006000ef          	jal	ra,ffffffffc0204480 <schedule>
ffffffffc020447e:	bfd5                	j	ffffffffc0204472 <cpu_idle+0xe>

ffffffffc0204480 <schedule>:
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
    proc->state = PROC_RUNNABLE;
}

void
schedule(void) {
ffffffffc0204480:	1141                	addi	sp,sp,-16
ffffffffc0204482:	e406                	sd	ra,8(sp)
ffffffffc0204484:	e022                	sd	s0,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204486:	100027f3          	csrr	a5,sstatus
ffffffffc020448a:	8b89                	andi	a5,a5,2
ffffffffc020448c:	4401                	li	s0,0
ffffffffc020448e:	e3d1                	bnez	a5,ffffffffc0204512 <schedule+0x92>
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc0204490:	00011797          	auipc	a5,0x11
ffffffffc0204494:	01878793          	addi	a5,a5,24 # ffffffffc02154a8 <current>
ffffffffc0204498:	0007b883          	ld	a7,0(a5)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc020449c:	00011797          	auipc	a5,0x11
ffffffffc02044a0:	01478793          	addi	a5,a5,20 # ffffffffc02154b0 <idleproc>
ffffffffc02044a4:	6388                	ld	a0,0(a5)
        current->need_resched = 0;
ffffffffc02044a6:	0008ac23          	sw	zero,24(a7)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc02044aa:	04a88e63          	beq	a7,a0,ffffffffc0204506 <schedule+0x86>
ffffffffc02044ae:	0c888693          	addi	a3,a7,200
ffffffffc02044b2:	00011617          	auipc	a2,0x11
ffffffffc02044b6:	13660613          	addi	a2,a2,310 # ffffffffc02155e8 <proc_list>
        le = last;
ffffffffc02044ba:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;
ffffffffc02044bc:	4581                	li	a1,0
        do {
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE) {
ffffffffc02044be:	4809                	li	a6,2
    return listelm->next;
ffffffffc02044c0:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list) {
ffffffffc02044c2:	00c78863          	beq	a5,a2,ffffffffc02044d2 <schedule+0x52>
                if (next->state == PROC_RUNNABLE) {
ffffffffc02044c6:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc02044ca:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE) {
ffffffffc02044ce:	01070463          	beq	a4,a6,ffffffffc02044d6 <schedule+0x56>
                    break;
                }
            }
        } while (le != last);
ffffffffc02044d2:	fef697e3          	bne	a3,a5,ffffffffc02044c0 <schedule+0x40>
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc02044d6:	c589                	beqz	a1,ffffffffc02044e0 <schedule+0x60>
ffffffffc02044d8:	4198                	lw	a4,0(a1)
ffffffffc02044da:	4789                	li	a5,2
ffffffffc02044dc:	00f70e63          	beq	a4,a5,ffffffffc02044f8 <schedule+0x78>
            next = idleproc;
        }
        next->runs ++;
ffffffffc02044e0:	451c                	lw	a5,8(a0)
ffffffffc02044e2:	2785                	addiw	a5,a5,1
ffffffffc02044e4:	c51c                	sw	a5,8(a0)
        if (next != current) {
ffffffffc02044e6:	00a88463          	beq	a7,a0,ffffffffc02044ee <schedule+0x6e>
            proc_run(next);
ffffffffc02044ea:	c3dff0ef          	jal	ra,ffffffffc0204126 <proc_run>
    if (flag) {
ffffffffc02044ee:	e419                	bnez	s0,ffffffffc02044fc <schedule+0x7c>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc02044f0:	60a2                	ld	ra,8(sp)
ffffffffc02044f2:	6402                	ld	s0,0(sp)
ffffffffc02044f4:	0141                	addi	sp,sp,16
ffffffffc02044f6:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc02044f8:	852e                	mv	a0,a1
ffffffffc02044fa:	b7dd                	j	ffffffffc02044e0 <schedule+0x60>
}
ffffffffc02044fc:	6402                	ld	s0,0(sp)
ffffffffc02044fe:	60a2                	ld	ra,8(sp)
ffffffffc0204500:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc0204502:	8a6fc06f          	j	ffffffffc02005a8 <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0204506:	00011617          	auipc	a2,0x11
ffffffffc020450a:	0e260613          	addi	a2,a2,226 # ffffffffc02155e8 <proc_list>
ffffffffc020450e:	86b2                	mv	a3,a2
ffffffffc0204510:	b76d                	j	ffffffffc02044ba <schedule+0x3a>
        intr_disable();
ffffffffc0204512:	89cfc0ef          	jal	ra,ffffffffc02005ae <intr_disable>
        return 1;
ffffffffc0204516:	4405                	li	s0,1
ffffffffc0204518:	bfa5                	j	ffffffffc0204490 <schedule+0x10>

ffffffffc020451a <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc020451a:	00054783          	lbu	a5,0(a0)
ffffffffc020451e:	cb91                	beqz	a5,ffffffffc0204532 <strlen+0x18>
    size_t cnt = 0;
ffffffffc0204520:	4781                	li	a5,0
        cnt ++;
ffffffffc0204522:	0785                	addi	a5,a5,1
    while (*s ++ != '\0') {
ffffffffc0204524:	00f50733          	add	a4,a0,a5
ffffffffc0204528:	00074703          	lbu	a4,0(a4)
ffffffffc020452c:	fb7d                	bnez	a4,ffffffffc0204522 <strlen+0x8>
    }
    return cnt;
}
ffffffffc020452e:	853e                	mv	a0,a5
ffffffffc0204530:	8082                	ret
    size_t cnt = 0;
ffffffffc0204532:	4781                	li	a5,0
}
ffffffffc0204534:	853e                	mv	a0,a5
ffffffffc0204536:	8082                	ret

ffffffffc0204538 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc0204538:	c185                	beqz	a1,ffffffffc0204558 <strnlen+0x20>
ffffffffc020453a:	00054783          	lbu	a5,0(a0)
ffffffffc020453e:	cf89                	beqz	a5,ffffffffc0204558 <strnlen+0x20>
    size_t cnt = 0;
ffffffffc0204540:	4781                	li	a5,0
ffffffffc0204542:	a021                	j	ffffffffc020454a <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc0204544:	00074703          	lbu	a4,0(a4)
ffffffffc0204548:	c711                	beqz	a4,ffffffffc0204554 <strnlen+0x1c>
        cnt ++;
ffffffffc020454a:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc020454c:	00f50733          	add	a4,a0,a5
ffffffffc0204550:	fef59ae3          	bne	a1,a5,ffffffffc0204544 <strnlen+0xc>
    }
    return cnt;
}
ffffffffc0204554:	853e                	mv	a0,a5
ffffffffc0204556:	8082                	ret
    size_t cnt = 0;
ffffffffc0204558:	4781                	li	a5,0
}
ffffffffc020455a:	853e                	mv	a0,a5
ffffffffc020455c:	8082                	ret

ffffffffc020455e <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc020455e:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0204560:	0585                	addi	a1,a1,1
ffffffffc0204562:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0204566:	0785                	addi	a5,a5,1
ffffffffc0204568:	fee78fa3          	sb	a4,-1(a5)
ffffffffc020456c:	fb75                	bnez	a4,ffffffffc0204560 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc020456e:	8082                	ret

ffffffffc0204570 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204570:	00054783          	lbu	a5,0(a0)
ffffffffc0204574:	0005c703          	lbu	a4,0(a1)
ffffffffc0204578:	cb91                	beqz	a5,ffffffffc020458c <strcmp+0x1c>
ffffffffc020457a:	00e79c63          	bne	a5,a4,ffffffffc0204592 <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc020457e:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204580:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc0204584:	0585                	addi	a1,a1,1
ffffffffc0204586:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020458a:	fbe5                	bnez	a5,ffffffffc020457a <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020458c:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc020458e:	9d19                	subw	a0,a0,a4
ffffffffc0204590:	8082                	ret
ffffffffc0204592:	0007851b          	sext.w	a0,a5
ffffffffc0204596:	9d19                	subw	a0,a0,a4
ffffffffc0204598:	8082                	ret

ffffffffc020459a <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc020459a:	00054783          	lbu	a5,0(a0)
ffffffffc020459e:	cb91                	beqz	a5,ffffffffc02045b2 <strchr+0x18>
        if (*s == c) {
ffffffffc02045a0:	00b79563          	bne	a5,a1,ffffffffc02045aa <strchr+0x10>
ffffffffc02045a4:	a809                	j	ffffffffc02045b6 <strchr+0x1c>
ffffffffc02045a6:	00b78763          	beq	a5,a1,ffffffffc02045b4 <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc02045aa:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc02045ac:	00054783          	lbu	a5,0(a0)
ffffffffc02045b0:	fbfd                	bnez	a5,ffffffffc02045a6 <strchr+0xc>
    }
    return NULL;
ffffffffc02045b2:	4501                	li	a0,0
}
ffffffffc02045b4:	8082                	ret
ffffffffc02045b6:	8082                	ret

ffffffffc02045b8 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc02045b8:	ca01                	beqz	a2,ffffffffc02045c8 <memset+0x10>
ffffffffc02045ba:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc02045bc:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc02045be:	0785                	addi	a5,a5,1
ffffffffc02045c0:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc02045c4:	fec79de3          	bne	a5,a2,ffffffffc02045be <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc02045c8:	8082                	ret

ffffffffc02045ca <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc02045ca:	ca19                	beqz	a2,ffffffffc02045e0 <memcpy+0x16>
ffffffffc02045cc:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc02045ce:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc02045d0:	0585                	addi	a1,a1,1
ffffffffc02045d2:	fff5c703          	lbu	a4,-1(a1)
ffffffffc02045d6:	0785                	addi	a5,a5,1
ffffffffc02045d8:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc02045dc:	fec59ae3          	bne	a1,a2,ffffffffc02045d0 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc02045e0:	8082                	ret

ffffffffc02045e2 <memcmp>:
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
ffffffffc02045e2:	c21d                	beqz	a2,ffffffffc0204608 <memcmp+0x26>
        if (*s1 != *s2) {
ffffffffc02045e4:	00054783          	lbu	a5,0(a0)
ffffffffc02045e8:	0005c703          	lbu	a4,0(a1)
ffffffffc02045ec:	962a                	add	a2,a2,a0
ffffffffc02045ee:	00f70963          	beq	a4,a5,ffffffffc0204600 <memcmp+0x1e>
ffffffffc02045f2:	a829                	j	ffffffffc020460c <memcmp+0x2a>
ffffffffc02045f4:	00054783          	lbu	a5,0(a0)
ffffffffc02045f8:	0005c703          	lbu	a4,0(a1)
ffffffffc02045fc:	00e79863          	bne	a5,a4,ffffffffc020460c <memcmp+0x2a>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
ffffffffc0204600:	0505                	addi	a0,a0,1
ffffffffc0204602:	0585                	addi	a1,a1,1
    while (n -- > 0) {
ffffffffc0204604:	fea618e3          	bne	a2,a0,ffffffffc02045f4 <memcmp+0x12>
    }
    return 0;
ffffffffc0204608:	4501                	li	a0,0
}
ffffffffc020460a:	8082                	ret
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020460c:	40e7853b          	subw	a0,a5,a4
ffffffffc0204610:	8082                	ret

ffffffffc0204612 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0204612:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0204616:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0204618:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020461c:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc020461e:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0204622:	f022                	sd	s0,32(sp)
ffffffffc0204624:	ec26                	sd	s1,24(sp)
ffffffffc0204626:	e84a                	sd	s2,16(sp)
ffffffffc0204628:	f406                	sd	ra,40(sp)
ffffffffc020462a:	e44e                	sd	s3,8(sp)
ffffffffc020462c:	84aa                	mv	s1,a0
ffffffffc020462e:	892e                	mv	s2,a1
ffffffffc0204630:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0204634:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc0204636:	03067e63          	bgeu	a2,a6,ffffffffc0204672 <printnum+0x60>
ffffffffc020463a:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc020463c:	00805763          	blez	s0,ffffffffc020464a <printnum+0x38>
ffffffffc0204640:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0204642:	85ca                	mv	a1,s2
ffffffffc0204644:	854e                	mv	a0,s3
ffffffffc0204646:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0204648:	fc65                	bnez	s0,ffffffffc0204640 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020464a:	1a02                	slli	s4,s4,0x20
ffffffffc020464c:	020a5a13          	srli	s4,s4,0x20
ffffffffc0204650:	00002797          	auipc	a5,0x2
ffffffffc0204654:	33878793          	addi	a5,a5,824 # ffffffffc0206988 <error_string+0x38>
ffffffffc0204658:	9a3e                	add	s4,s4,a5
}
ffffffffc020465a:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020465c:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0204660:	70a2                	ld	ra,40(sp)
ffffffffc0204662:	69a2                	ld	s3,8(sp)
ffffffffc0204664:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204666:	85ca                	mv	a1,s2
ffffffffc0204668:	8326                	mv	t1,s1
}
ffffffffc020466a:	6942                	ld	s2,16(sp)
ffffffffc020466c:	64e2                	ld	s1,24(sp)
ffffffffc020466e:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204670:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0204672:	03065633          	divu	a2,a2,a6
ffffffffc0204676:	8722                	mv	a4,s0
ffffffffc0204678:	f9bff0ef          	jal	ra,ffffffffc0204612 <printnum>
ffffffffc020467c:	b7f9                	j	ffffffffc020464a <printnum+0x38>

ffffffffc020467e <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc020467e:	7119                	addi	sp,sp,-128
ffffffffc0204680:	f4a6                	sd	s1,104(sp)
ffffffffc0204682:	f0ca                	sd	s2,96(sp)
ffffffffc0204684:	e8d2                	sd	s4,80(sp)
ffffffffc0204686:	e4d6                	sd	s5,72(sp)
ffffffffc0204688:	e0da                	sd	s6,64(sp)
ffffffffc020468a:	fc5e                	sd	s7,56(sp)
ffffffffc020468c:	f862                	sd	s8,48(sp)
ffffffffc020468e:	f06a                	sd	s10,32(sp)
ffffffffc0204690:	fc86                	sd	ra,120(sp)
ffffffffc0204692:	f8a2                	sd	s0,112(sp)
ffffffffc0204694:	ecce                	sd	s3,88(sp)
ffffffffc0204696:	f466                	sd	s9,40(sp)
ffffffffc0204698:	ec6e                	sd	s11,24(sp)
ffffffffc020469a:	892a                	mv	s2,a0
ffffffffc020469c:	84ae                	mv	s1,a1
ffffffffc020469e:	8d32                	mv	s10,a2
ffffffffc02046a0:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc02046a2:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02046a4:	00002a17          	auipc	s4,0x2
ffffffffc02046a8:	154a0a13          	addi	s4,s4,340 # ffffffffc02067f8 <default_pmm_manager+0x1f0>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02046ac:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02046b0:	00002c17          	auipc	s8,0x2
ffffffffc02046b4:	2a0c0c13          	addi	s8,s8,672 # ffffffffc0206950 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02046b8:	000d4503          	lbu	a0,0(s10) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
ffffffffc02046bc:	02500793          	li	a5,37
ffffffffc02046c0:	001d0413          	addi	s0,s10,1
ffffffffc02046c4:	00f50e63          	beq	a0,a5,ffffffffc02046e0 <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc02046c8:	c521                	beqz	a0,ffffffffc0204710 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02046ca:	02500993          	li	s3,37
ffffffffc02046ce:	a011                	j	ffffffffc02046d2 <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc02046d0:	c121                	beqz	a0,ffffffffc0204710 <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc02046d2:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02046d4:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc02046d6:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02046d8:	fff44503          	lbu	a0,-1(s0)
ffffffffc02046dc:	ff351ae3          	bne	a0,s3,ffffffffc02046d0 <vprintfmt+0x52>
ffffffffc02046e0:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc02046e4:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc02046e8:	4981                	li	s3,0
ffffffffc02046ea:	4801                	li	a6,0
        width = precision = -1;
ffffffffc02046ec:	5cfd                	li	s9,-1
ffffffffc02046ee:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02046f0:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc02046f4:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02046f6:	fdd6069b          	addiw	a3,a2,-35
ffffffffc02046fa:	0ff6f693          	andi	a3,a3,255
ffffffffc02046fe:	00140d13          	addi	s10,s0,1
ffffffffc0204702:	1ed5ef63          	bltu	a1,a3,ffffffffc0204900 <vprintfmt+0x282>
ffffffffc0204706:	068a                	slli	a3,a3,0x2
ffffffffc0204708:	96d2                	add	a3,a3,s4
ffffffffc020470a:	4294                	lw	a3,0(a3)
ffffffffc020470c:	96d2                	add	a3,a3,s4
ffffffffc020470e:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0204710:	70e6                	ld	ra,120(sp)
ffffffffc0204712:	7446                	ld	s0,112(sp)
ffffffffc0204714:	74a6                	ld	s1,104(sp)
ffffffffc0204716:	7906                	ld	s2,96(sp)
ffffffffc0204718:	69e6                	ld	s3,88(sp)
ffffffffc020471a:	6a46                	ld	s4,80(sp)
ffffffffc020471c:	6aa6                	ld	s5,72(sp)
ffffffffc020471e:	6b06                	ld	s6,64(sp)
ffffffffc0204720:	7be2                	ld	s7,56(sp)
ffffffffc0204722:	7c42                	ld	s8,48(sp)
ffffffffc0204724:	7ca2                	ld	s9,40(sp)
ffffffffc0204726:	7d02                	ld	s10,32(sp)
ffffffffc0204728:	6de2                	ld	s11,24(sp)
ffffffffc020472a:	6109                	addi	sp,sp,128
ffffffffc020472c:	8082                	ret
            padc = '-';
ffffffffc020472e:	87b2                	mv	a5,a2
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204730:	00144603          	lbu	a2,1(s0)
ffffffffc0204734:	846a                	mv	s0,s10
ffffffffc0204736:	b7c1                	j	ffffffffc02046f6 <vprintfmt+0x78>
            precision = va_arg(ap, int);
ffffffffc0204738:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc020473c:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0204740:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204742:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc0204744:	fa0dd9e3          	bgez	s11,ffffffffc02046f6 <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc0204748:	8de6                	mv	s11,s9
ffffffffc020474a:	5cfd                	li	s9,-1
ffffffffc020474c:	b76d                	j	ffffffffc02046f6 <vprintfmt+0x78>
            if (width < 0)
ffffffffc020474e:	fffdc693          	not	a3,s11
ffffffffc0204752:	96fd                	srai	a3,a3,0x3f
ffffffffc0204754:	00ddfdb3          	and	s11,s11,a3
ffffffffc0204758:	00144603          	lbu	a2,1(s0)
ffffffffc020475c:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020475e:	846a                	mv	s0,s10
ffffffffc0204760:	bf59                	j	ffffffffc02046f6 <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc0204762:	4705                	li	a4,1
ffffffffc0204764:	008a8593          	addi	a1,s5,8
ffffffffc0204768:	01074463          	blt	a4,a6,ffffffffc0204770 <vprintfmt+0xf2>
    else if (lflag) {
ffffffffc020476c:	22080863          	beqz	a6,ffffffffc020499c <vprintfmt+0x31e>
        return va_arg(*ap, unsigned long);
ffffffffc0204770:	000ab603          	ld	a2,0(s5)
ffffffffc0204774:	46c1                	li	a3,16
ffffffffc0204776:	8aae                	mv	s5,a1
ffffffffc0204778:	a291                	j	ffffffffc02048bc <vprintfmt+0x23e>
                precision = precision * 10 + ch - '0';
ffffffffc020477a:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc020477e:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204782:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0204784:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0204788:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc020478c:	fad56ce3          	bltu	a0,a3,ffffffffc0204744 <vprintfmt+0xc6>
            for (precision = 0; ; ++ fmt) {
ffffffffc0204790:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0204792:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc0204796:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc020479a:	0196873b          	addw	a4,a3,s9
ffffffffc020479e:	0017171b          	slliw	a4,a4,0x1
ffffffffc02047a2:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc02047a6:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc02047aa:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc02047ae:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc02047b2:	fcd57fe3          	bgeu	a0,a3,ffffffffc0204790 <vprintfmt+0x112>
ffffffffc02047b6:	b779                	j	ffffffffc0204744 <vprintfmt+0xc6>
            putch(va_arg(ap, int), putdat);
ffffffffc02047b8:	000aa503          	lw	a0,0(s5)
ffffffffc02047bc:	85a6                	mv	a1,s1
ffffffffc02047be:	0aa1                	addi	s5,s5,8
ffffffffc02047c0:	9902                	jalr	s2
            break;
ffffffffc02047c2:	bddd                	j	ffffffffc02046b8 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02047c4:	4705                	li	a4,1
ffffffffc02047c6:	008a8993          	addi	s3,s5,8
ffffffffc02047ca:	01074463          	blt	a4,a6,ffffffffc02047d2 <vprintfmt+0x154>
    else if (lflag) {
ffffffffc02047ce:	1c080463          	beqz	a6,ffffffffc0204996 <vprintfmt+0x318>
        return va_arg(*ap, long);
ffffffffc02047d2:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc02047d6:	1c044a63          	bltz	s0,ffffffffc02049aa <vprintfmt+0x32c>
            num = getint(&ap, lflag);
ffffffffc02047da:	8622                	mv	a2,s0
ffffffffc02047dc:	8ace                	mv	s5,s3
ffffffffc02047de:	46a9                	li	a3,10
ffffffffc02047e0:	a8f1                	j	ffffffffc02048bc <vprintfmt+0x23e>
            err = va_arg(ap, int);
ffffffffc02047e2:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02047e6:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc02047e8:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc02047ea:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02047ee:	8fb5                	xor	a5,a5,a3
ffffffffc02047f0:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02047f4:	12d74963          	blt	a4,a3,ffffffffc0204926 <vprintfmt+0x2a8>
ffffffffc02047f8:	00369793          	slli	a5,a3,0x3
ffffffffc02047fc:	97e2                	add	a5,a5,s8
ffffffffc02047fe:	639c                	ld	a5,0(a5)
ffffffffc0204800:	12078363          	beqz	a5,ffffffffc0204926 <vprintfmt+0x2a8>
                printfmt(putch, putdat, "%s", p);
ffffffffc0204804:	86be                	mv	a3,a5
ffffffffc0204806:	00000617          	auipc	a2,0x0
ffffffffc020480a:	23a60613          	addi	a2,a2,570 # ffffffffc0204a40 <etext+0x2a>
ffffffffc020480e:	85a6                	mv	a1,s1
ffffffffc0204810:	854a                	mv	a0,s2
ffffffffc0204812:	1cc000ef          	jal	ra,ffffffffc02049de <printfmt>
ffffffffc0204816:	b54d                	j	ffffffffc02046b8 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0204818:	000ab603          	ld	a2,0(s5)
ffffffffc020481c:	0aa1                	addi	s5,s5,8
ffffffffc020481e:	1a060163          	beqz	a2,ffffffffc02049c0 <vprintfmt+0x342>
            if (width > 0 && padc != '-') {
ffffffffc0204822:	00160413          	addi	s0,a2,1
ffffffffc0204826:	15b05763          	blez	s11,ffffffffc0204974 <vprintfmt+0x2f6>
ffffffffc020482a:	02d00593          	li	a1,45
ffffffffc020482e:	10b79d63          	bne	a5,a1,ffffffffc0204948 <vprintfmt+0x2ca>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204832:	00064783          	lbu	a5,0(a2)
ffffffffc0204836:	0007851b          	sext.w	a0,a5
ffffffffc020483a:	c905                	beqz	a0,ffffffffc020486a <vprintfmt+0x1ec>
ffffffffc020483c:	000cc563          	bltz	s9,ffffffffc0204846 <vprintfmt+0x1c8>
ffffffffc0204840:	3cfd                	addiw	s9,s9,-1
ffffffffc0204842:	036c8263          	beq	s9,s6,ffffffffc0204866 <vprintfmt+0x1e8>
                    putch('?', putdat);
ffffffffc0204846:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204848:	14098f63          	beqz	s3,ffffffffc02049a6 <vprintfmt+0x328>
ffffffffc020484c:	3781                	addiw	a5,a5,-32
ffffffffc020484e:	14fbfc63          	bgeu	s7,a5,ffffffffc02049a6 <vprintfmt+0x328>
                    putch('?', putdat);
ffffffffc0204852:	03f00513          	li	a0,63
ffffffffc0204856:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204858:	0405                	addi	s0,s0,1
ffffffffc020485a:	fff44783          	lbu	a5,-1(s0)
ffffffffc020485e:	3dfd                	addiw	s11,s11,-1
ffffffffc0204860:	0007851b          	sext.w	a0,a5
ffffffffc0204864:	fd61                	bnez	a0,ffffffffc020483c <vprintfmt+0x1be>
            for (; width > 0; width --) {
ffffffffc0204866:	e5b059e3          	blez	s11,ffffffffc02046b8 <vprintfmt+0x3a>
ffffffffc020486a:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc020486c:	85a6                	mv	a1,s1
ffffffffc020486e:	02000513          	li	a0,32
ffffffffc0204872:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0204874:	e40d82e3          	beqz	s11,ffffffffc02046b8 <vprintfmt+0x3a>
ffffffffc0204878:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc020487a:	85a6                	mv	a1,s1
ffffffffc020487c:	02000513          	li	a0,32
ffffffffc0204880:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0204882:	fe0d94e3          	bnez	s11,ffffffffc020486a <vprintfmt+0x1ec>
ffffffffc0204886:	bd0d                	j	ffffffffc02046b8 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0204888:	4705                	li	a4,1
ffffffffc020488a:	008a8593          	addi	a1,s5,8
ffffffffc020488e:	01074463          	blt	a4,a6,ffffffffc0204896 <vprintfmt+0x218>
    else if (lflag) {
ffffffffc0204892:	0e080863          	beqz	a6,ffffffffc0204982 <vprintfmt+0x304>
        return va_arg(*ap, unsigned long);
ffffffffc0204896:	000ab603          	ld	a2,0(s5)
ffffffffc020489a:	46a1                	li	a3,8
ffffffffc020489c:	8aae                	mv	s5,a1
ffffffffc020489e:	a839                	j	ffffffffc02048bc <vprintfmt+0x23e>
            putch('0', putdat);
ffffffffc02048a0:	03000513          	li	a0,48
ffffffffc02048a4:	85a6                	mv	a1,s1
ffffffffc02048a6:	e03e                	sd	a5,0(sp)
ffffffffc02048a8:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc02048aa:	85a6                	mv	a1,s1
ffffffffc02048ac:	07800513          	li	a0,120
ffffffffc02048b0:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02048b2:	0aa1                	addi	s5,s5,8
ffffffffc02048b4:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc02048b8:	6782                	ld	a5,0(sp)
ffffffffc02048ba:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc02048bc:	2781                	sext.w	a5,a5
ffffffffc02048be:	876e                	mv	a4,s11
ffffffffc02048c0:	85a6                	mv	a1,s1
ffffffffc02048c2:	854a                	mv	a0,s2
ffffffffc02048c4:	d4fff0ef          	jal	ra,ffffffffc0204612 <printnum>
            break;
ffffffffc02048c8:	bbc5                	j	ffffffffc02046b8 <vprintfmt+0x3a>
            lflag ++;
ffffffffc02048ca:	00144603          	lbu	a2,1(s0)
ffffffffc02048ce:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02048d0:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02048d2:	b515                	j	ffffffffc02046f6 <vprintfmt+0x78>
            goto reswitch;
ffffffffc02048d4:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc02048d8:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02048da:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02048dc:	bd29                	j	ffffffffc02046f6 <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc02048de:	85a6                	mv	a1,s1
ffffffffc02048e0:	02500513          	li	a0,37
ffffffffc02048e4:	9902                	jalr	s2
            break;
ffffffffc02048e6:	bbc9                	j	ffffffffc02046b8 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02048e8:	4705                	li	a4,1
ffffffffc02048ea:	008a8593          	addi	a1,s5,8
ffffffffc02048ee:	01074463          	blt	a4,a6,ffffffffc02048f6 <vprintfmt+0x278>
    else if (lflag) {
ffffffffc02048f2:	08080d63          	beqz	a6,ffffffffc020498c <vprintfmt+0x30e>
        return va_arg(*ap, unsigned long);
ffffffffc02048f6:	000ab603          	ld	a2,0(s5)
ffffffffc02048fa:	46a9                	li	a3,10
ffffffffc02048fc:	8aae                	mv	s5,a1
ffffffffc02048fe:	bf7d                	j	ffffffffc02048bc <vprintfmt+0x23e>
            putch('%', putdat);
ffffffffc0204900:	85a6                	mv	a1,s1
ffffffffc0204902:	02500513          	li	a0,37
ffffffffc0204906:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0204908:	fff44703          	lbu	a4,-1(s0)
ffffffffc020490c:	02500793          	li	a5,37
ffffffffc0204910:	8d22                	mv	s10,s0
ffffffffc0204912:	daf703e3          	beq	a4,a5,ffffffffc02046b8 <vprintfmt+0x3a>
ffffffffc0204916:	02500713          	li	a4,37
ffffffffc020491a:	1d7d                	addi	s10,s10,-1
ffffffffc020491c:	fffd4783          	lbu	a5,-1(s10)
ffffffffc0204920:	fee79de3          	bne	a5,a4,ffffffffc020491a <vprintfmt+0x29c>
ffffffffc0204924:	bb51                	j	ffffffffc02046b8 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0204926:	00002617          	auipc	a2,0x2
ffffffffc020492a:	10260613          	addi	a2,a2,258 # ffffffffc0206a28 <error_string+0xd8>
ffffffffc020492e:	85a6                	mv	a1,s1
ffffffffc0204930:	854a                	mv	a0,s2
ffffffffc0204932:	0ac000ef          	jal	ra,ffffffffc02049de <printfmt>
ffffffffc0204936:	b349                	j	ffffffffc02046b8 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0204938:	00002617          	auipc	a2,0x2
ffffffffc020493c:	0e860613          	addi	a2,a2,232 # ffffffffc0206a20 <error_string+0xd0>
            if (width > 0 && padc != '-') {
ffffffffc0204940:	00002417          	auipc	s0,0x2
ffffffffc0204944:	0e140413          	addi	s0,s0,225 # ffffffffc0206a21 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204948:	8532                	mv	a0,a2
ffffffffc020494a:	85e6                	mv	a1,s9
ffffffffc020494c:	e032                	sd	a2,0(sp)
ffffffffc020494e:	e43e                	sd	a5,8(sp)
ffffffffc0204950:	be9ff0ef          	jal	ra,ffffffffc0204538 <strnlen>
ffffffffc0204954:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0204958:	6602                	ld	a2,0(sp)
ffffffffc020495a:	01b05d63          	blez	s11,ffffffffc0204974 <vprintfmt+0x2f6>
ffffffffc020495e:	67a2                	ld	a5,8(sp)
ffffffffc0204960:	2781                	sext.w	a5,a5
ffffffffc0204962:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc0204964:	6522                	ld	a0,8(sp)
ffffffffc0204966:	85a6                	mv	a1,s1
ffffffffc0204968:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020496a:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc020496c:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020496e:	6602                	ld	a2,0(sp)
ffffffffc0204970:	fe0d9ae3          	bnez	s11,ffffffffc0204964 <vprintfmt+0x2e6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204974:	00064783          	lbu	a5,0(a2)
ffffffffc0204978:	0007851b          	sext.w	a0,a5
ffffffffc020497c:	ec0510e3          	bnez	a0,ffffffffc020483c <vprintfmt+0x1be>
ffffffffc0204980:	bb25                	j	ffffffffc02046b8 <vprintfmt+0x3a>
        return va_arg(*ap, unsigned int);
ffffffffc0204982:	000ae603          	lwu	a2,0(s5)
ffffffffc0204986:	46a1                	li	a3,8
ffffffffc0204988:	8aae                	mv	s5,a1
ffffffffc020498a:	bf0d                	j	ffffffffc02048bc <vprintfmt+0x23e>
ffffffffc020498c:	000ae603          	lwu	a2,0(s5)
ffffffffc0204990:	46a9                	li	a3,10
ffffffffc0204992:	8aae                	mv	s5,a1
ffffffffc0204994:	b725                	j	ffffffffc02048bc <vprintfmt+0x23e>
        return va_arg(*ap, int);
ffffffffc0204996:	000aa403          	lw	s0,0(s5)
ffffffffc020499a:	bd35                	j	ffffffffc02047d6 <vprintfmt+0x158>
        return va_arg(*ap, unsigned int);
ffffffffc020499c:	000ae603          	lwu	a2,0(s5)
ffffffffc02049a0:	46c1                	li	a3,16
ffffffffc02049a2:	8aae                	mv	s5,a1
ffffffffc02049a4:	bf21                	j	ffffffffc02048bc <vprintfmt+0x23e>
                    putch(ch, putdat);
ffffffffc02049a6:	9902                	jalr	s2
ffffffffc02049a8:	bd45                	j	ffffffffc0204858 <vprintfmt+0x1da>
                putch('-', putdat);
ffffffffc02049aa:	85a6                	mv	a1,s1
ffffffffc02049ac:	02d00513          	li	a0,45
ffffffffc02049b0:	e03e                	sd	a5,0(sp)
ffffffffc02049b2:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc02049b4:	8ace                	mv	s5,s3
ffffffffc02049b6:	40800633          	neg	a2,s0
ffffffffc02049ba:	46a9                	li	a3,10
ffffffffc02049bc:	6782                	ld	a5,0(sp)
ffffffffc02049be:	bdfd                	j	ffffffffc02048bc <vprintfmt+0x23e>
            if (width > 0 && padc != '-') {
ffffffffc02049c0:	01b05663          	blez	s11,ffffffffc02049cc <vprintfmt+0x34e>
ffffffffc02049c4:	02d00693          	li	a3,45
ffffffffc02049c8:	f6d798e3          	bne	a5,a3,ffffffffc0204938 <vprintfmt+0x2ba>
ffffffffc02049cc:	00002417          	auipc	s0,0x2
ffffffffc02049d0:	05540413          	addi	s0,s0,85 # ffffffffc0206a21 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02049d4:	02800513          	li	a0,40
ffffffffc02049d8:	02800793          	li	a5,40
ffffffffc02049dc:	b585                	j	ffffffffc020483c <vprintfmt+0x1be>

ffffffffc02049de <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02049de:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02049e0:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02049e4:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02049e6:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02049e8:	ec06                	sd	ra,24(sp)
ffffffffc02049ea:	f83a                	sd	a4,48(sp)
ffffffffc02049ec:	fc3e                	sd	a5,56(sp)
ffffffffc02049ee:	e0c2                	sd	a6,64(sp)
ffffffffc02049f0:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02049f2:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02049f4:	c8bff0ef          	jal	ra,ffffffffc020467e <vprintfmt>
}
ffffffffc02049f8:	60e2                	ld	ra,24(sp)
ffffffffc02049fa:	6161                	addi	sp,sp,80
ffffffffc02049fc:	8082                	ret

ffffffffc02049fe <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc02049fe:	9e3707b7          	lui	a5,0x9e370
ffffffffc0204a02:	2785                	addiw	a5,a5,1
ffffffffc0204a04:	02f5053b          	mulw	a0,a0,a5
    return (hash >> (32 - bits));
ffffffffc0204a08:	02000793          	li	a5,32
ffffffffc0204a0c:	40b785bb          	subw	a1,a5,a1
}
ffffffffc0204a10:	00b5553b          	srlw	a0,a0,a1
ffffffffc0204a14:	8082                	ret
