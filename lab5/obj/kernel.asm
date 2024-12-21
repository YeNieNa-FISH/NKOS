
bin/kernel：     文件格式 elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c020b2b7          	lui	t0,0xc020b
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
ffffffffc0200028:	c020b137          	lui	sp,0xc020b

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
ffffffffc0200036:	000a1517          	auipc	a0,0xa1
ffffffffc020003a:	41250513          	addi	a0,a0,1042 # ffffffffc02a1448 <edata>
ffffffffc020003e:	000ad617          	auipc	a2,0xad
ffffffffc0200042:	99a60613          	addi	a2,a2,-1638 # ffffffffc02ac9d8 <end>
kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	172060ef          	jal	ra,ffffffffc02061c0 <memset>
    cons_init();                // init the console
ffffffffc0200052:	588000ef          	jal	ra,ffffffffc02005da <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200056:	00006597          	auipc	a1,0x6
ffffffffc020005a:	59a58593          	addi	a1,a1,1434 # ffffffffc02065f0 <etext+0x2>
ffffffffc020005e:	00006517          	auipc	a0,0x6
ffffffffc0200062:	5b250513          	addi	a0,a0,1458 # ffffffffc0206610 <etext+0x22>
ffffffffc0200066:	06a000ef          	jal	ra,ffffffffc02000d0 <cprintf>

    print_kerninfo();
ffffffffc020006a:	258000ef          	jal	ra,ffffffffc02002c2 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006e:	5c4010ef          	jal	ra,ffffffffc0201632 <pmm_init>

    pic_init();                 // init interrupt controller
ffffffffc0200072:	5da000ef          	jal	ra,ffffffffc020064c <pic_init>
    idt_init();                 // init interrupt descriptor table
ffffffffc0200076:	5e4000ef          	jal	ra,ffffffffc020065a <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc020007a:	6cc020ef          	jal	ra,ffffffffc0202746 <vmm_init>
    proc_init();                // init process table
ffffffffc020007e:	54d050ef          	jal	ra,ffffffffc0205dca <proc_init>
    
    ide_init();                 // init ide devices
ffffffffc0200082:	4ac000ef          	jal	ra,ffffffffc020052e <ide_init>
    swap_init();                // init swap
ffffffffc0200086:	5a3020ef          	jal	ra,ffffffffc0202e28 <swap_init>

    clock_init();               // init clock interrupt
ffffffffc020008a:	4fc000ef          	jal	ra,ffffffffc0200586 <clock_init>
    intr_enable();              // enable irq interrupt
ffffffffc020008e:	5c0000ef          	jal	ra,ffffffffc020064e <intr_enable>
    
    cpu_idle();                 // run idle process
ffffffffc0200092:	685050ef          	jal	ra,ffffffffc0205f16 <cpu_idle>

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
ffffffffc020009e:	53e000ef          	jal	ra,ffffffffc02005dc <cons_putc>
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
ffffffffc02000c4:	192060ef          	jal	ra,ffffffffc0206256 <vprintfmt>
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
ffffffffc02000d2:	02810313          	addi	t1,sp,40 # ffffffffc020b028 <boot_page_table_sv39+0x28>
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
ffffffffc02000f8:	15e060ef          	jal	ra,ffffffffc0206256 <vprintfmt>
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
ffffffffc0200104:	a9e1                	j	ffffffffc02005dc <cons_putc>

ffffffffc0200106 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc0200106:	1101                	addi	sp,sp,-32
ffffffffc0200108:	e822                	sd	s0,16(sp)
ffffffffc020010a:	ec06                	sd	ra,24(sp)
ffffffffc020010c:	e426                	sd	s1,8(sp)
ffffffffc020010e:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc0200110:	00054503          	lbu	a0,0(a0)
ffffffffc0200114:	c51d                	beqz	a0,ffffffffc0200142 <cputs+0x3c>
ffffffffc0200116:	0405                	addi	s0,s0,1
ffffffffc0200118:	4485                	li	s1,1
ffffffffc020011a:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc020011c:	4c0000ef          	jal	ra,ffffffffc02005dc <cons_putc>
    (*cnt) ++;
ffffffffc0200120:	008487bb          	addw	a5,s1,s0
    while ((c = *str ++) != '\0') {
ffffffffc0200124:	0405                	addi	s0,s0,1
ffffffffc0200126:	fff44503          	lbu	a0,-1(s0)
ffffffffc020012a:	f96d                	bnez	a0,ffffffffc020011c <cputs+0x16>
ffffffffc020012c:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc0200130:	4529                	li	a0,10
ffffffffc0200132:	4aa000ef          	jal	ra,ffffffffc02005dc <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc0200136:	8522                	mv	a0,s0
ffffffffc0200138:	60e2                	ld	ra,24(sp)
ffffffffc020013a:	6442                	ld	s0,16(sp)
ffffffffc020013c:	64a2                	ld	s1,8(sp)
ffffffffc020013e:	6105                	addi	sp,sp,32
ffffffffc0200140:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc0200142:	4405                	li	s0,1
ffffffffc0200144:	b7f5                	j	ffffffffc0200130 <cputs+0x2a>

ffffffffc0200146 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc0200146:	1141                	addi	sp,sp,-16
ffffffffc0200148:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc020014a:	4c6000ef          	jal	ra,ffffffffc0200610 <cons_getc>
ffffffffc020014e:	dd75                	beqz	a0,ffffffffc020014a <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200150:	60a2                	ld	ra,8(sp)
ffffffffc0200152:	0141                	addi	sp,sp,16
ffffffffc0200154:	8082                	ret

ffffffffc0200156 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0200156:	715d                	addi	sp,sp,-80
ffffffffc0200158:	e486                	sd	ra,72(sp)
ffffffffc020015a:	e0a2                	sd	s0,64(sp)
ffffffffc020015c:	fc26                	sd	s1,56(sp)
ffffffffc020015e:	f84a                	sd	s2,48(sp)
ffffffffc0200160:	f44e                	sd	s3,40(sp)
ffffffffc0200162:	f052                	sd	s4,32(sp)
ffffffffc0200164:	ec56                	sd	s5,24(sp)
ffffffffc0200166:	e85a                	sd	s6,16(sp)
ffffffffc0200168:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc020016a:	c901                	beqz	a0,ffffffffc020017a <readline+0x24>
        cprintf("%s", prompt);
ffffffffc020016c:	85aa                	mv	a1,a0
ffffffffc020016e:	00006517          	auipc	a0,0x6
ffffffffc0200172:	4aa50513          	addi	a0,a0,1194 # ffffffffc0206618 <etext+0x2a>
ffffffffc0200176:	f5bff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
readline(const char *prompt) {
ffffffffc020017a:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020017c:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc020017e:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0200180:	4aa9                	li	s5,10
ffffffffc0200182:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0200184:	000a1b97          	auipc	s7,0xa1
ffffffffc0200188:	2c4b8b93          	addi	s7,s7,708 # ffffffffc02a1448 <edata>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020018c:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0200190:	fb7ff0ef          	jal	ra,ffffffffc0200146 <getchar>
ffffffffc0200194:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0200196:	00054b63          	bltz	a0,ffffffffc02001ac <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020019a:	00a95b63          	bge	s2,a0,ffffffffc02001b0 <readline+0x5a>
ffffffffc020019e:	029a5463          	bge	s4,s1,ffffffffc02001c6 <readline+0x70>
        c = getchar();
ffffffffc02001a2:	fa5ff0ef          	jal	ra,ffffffffc0200146 <getchar>
ffffffffc02001a6:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02001a8:	fe0559e3          	bgez	a0,ffffffffc020019a <readline+0x44>
            return NULL;
ffffffffc02001ac:	4501                	li	a0,0
ffffffffc02001ae:	a099                	j	ffffffffc02001f4 <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc02001b0:	03341463          	bne	s0,s3,ffffffffc02001d8 <readline+0x82>
ffffffffc02001b4:	e8b9                	bnez	s1,ffffffffc020020a <readline+0xb4>
        c = getchar();
ffffffffc02001b6:	f91ff0ef          	jal	ra,ffffffffc0200146 <getchar>
ffffffffc02001ba:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02001bc:	fe0548e3          	bltz	a0,ffffffffc02001ac <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02001c0:	fea958e3          	bge	s2,a0,ffffffffc02001b0 <readline+0x5a>
ffffffffc02001c4:	4481                	li	s1,0
            cputchar(c);
ffffffffc02001c6:	8522                	mv	a0,s0
ffffffffc02001c8:	f3dff0ef          	jal	ra,ffffffffc0200104 <cputchar>
            buf[i ++] = c;
ffffffffc02001cc:	009b87b3          	add	a5,s7,s1
ffffffffc02001d0:	00878023          	sb	s0,0(a5)
ffffffffc02001d4:	2485                	addiw	s1,s1,1
ffffffffc02001d6:	bf6d                	j	ffffffffc0200190 <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc02001d8:	01540463          	beq	s0,s5,ffffffffc02001e0 <readline+0x8a>
ffffffffc02001dc:	fb641ae3          	bne	s0,s6,ffffffffc0200190 <readline+0x3a>
            cputchar(c);
ffffffffc02001e0:	8522                	mv	a0,s0
ffffffffc02001e2:	f23ff0ef          	jal	ra,ffffffffc0200104 <cputchar>
            buf[i] = '\0';
ffffffffc02001e6:	000a1517          	auipc	a0,0xa1
ffffffffc02001ea:	26250513          	addi	a0,a0,610 # ffffffffc02a1448 <edata>
ffffffffc02001ee:	94aa                	add	s1,s1,a0
ffffffffc02001f0:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc02001f4:	60a6                	ld	ra,72(sp)
ffffffffc02001f6:	6406                	ld	s0,64(sp)
ffffffffc02001f8:	74e2                	ld	s1,56(sp)
ffffffffc02001fa:	7942                	ld	s2,48(sp)
ffffffffc02001fc:	79a2                	ld	s3,40(sp)
ffffffffc02001fe:	7a02                	ld	s4,32(sp)
ffffffffc0200200:	6ae2                	ld	s5,24(sp)
ffffffffc0200202:	6b42                	ld	s6,16(sp)
ffffffffc0200204:	6ba2                	ld	s7,8(sp)
ffffffffc0200206:	6161                	addi	sp,sp,80
ffffffffc0200208:	8082                	ret
            cputchar(c);
ffffffffc020020a:	4521                	li	a0,8
ffffffffc020020c:	ef9ff0ef          	jal	ra,ffffffffc0200104 <cputchar>
            i --;
ffffffffc0200210:	34fd                	addiw	s1,s1,-1
ffffffffc0200212:	bfbd                	j	ffffffffc0200190 <readline+0x3a>

ffffffffc0200214 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc0200214:	000ac317          	auipc	t1,0xac
ffffffffc0200218:	63430313          	addi	t1,t1,1588 # ffffffffc02ac848 <is_panic>
ffffffffc020021c:	00033303          	ld	t1,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc0200220:	715d                	addi	sp,sp,-80
ffffffffc0200222:	ec06                	sd	ra,24(sp)
ffffffffc0200224:	e822                	sd	s0,16(sp)
ffffffffc0200226:	f436                	sd	a3,40(sp)
ffffffffc0200228:	f83a                	sd	a4,48(sp)
ffffffffc020022a:	fc3e                	sd	a5,56(sp)
ffffffffc020022c:	e0c2                	sd	a6,64(sp)
ffffffffc020022e:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc0200230:	02031c63          	bnez	t1,ffffffffc0200268 <__panic+0x54>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc0200234:	4785                	li	a5,1
ffffffffc0200236:	8432                	mv	s0,a2
ffffffffc0200238:	000ac717          	auipc	a4,0xac
ffffffffc020023c:	60f73823          	sd	a5,1552(a4) # ffffffffc02ac848 <is_panic>

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200240:	862e                	mv	a2,a1
    va_start(ap, fmt);
ffffffffc0200242:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200244:	85aa                	mv	a1,a0
ffffffffc0200246:	00006517          	auipc	a0,0x6
ffffffffc020024a:	3da50513          	addi	a0,a0,986 # ffffffffc0206620 <etext+0x32>
    va_start(ap, fmt);
ffffffffc020024e:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200250:	e81ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200254:	65a2                	ld	a1,8(sp)
ffffffffc0200256:	8522                	mv	a0,s0
ffffffffc0200258:	e59ff0ef          	jal	ra,ffffffffc02000b0 <vcprintf>
    cprintf("\n");
ffffffffc020025c:	00007517          	auipc	a0,0x7
ffffffffc0200260:	1ac50513          	addi	a0,a0,428 # ffffffffc0207408 <commands+0xca8>
ffffffffc0200264:	e6dff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc0200268:	4501                	li	a0,0
ffffffffc020026a:	4581                	li	a1,0
ffffffffc020026c:	4601                	li	a2,0
ffffffffc020026e:	48a1                	li	a7,8
ffffffffc0200270:	00000073          	ecall
    va_end(ap);

panic_dead:
    // No debug monitor here
    sbi_shutdown();
    intr_disable();
ffffffffc0200274:	3e0000ef          	jal	ra,ffffffffc0200654 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc0200278:	4501                	li	a0,0
ffffffffc020027a:	172000ef          	jal	ra,ffffffffc02003ec <kmonitor>
ffffffffc020027e:	bfed                	j	ffffffffc0200278 <__panic+0x64>

ffffffffc0200280 <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc0200280:	715d                	addi	sp,sp,-80
ffffffffc0200282:	e822                	sd	s0,16(sp)
ffffffffc0200284:	fc3e                	sd	a5,56(sp)
ffffffffc0200286:	8432                	mv	s0,a2
    va_list ap;
    va_start(ap, fmt);
ffffffffc0200288:	103c                	addi	a5,sp,40
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc020028a:	862e                	mv	a2,a1
ffffffffc020028c:	85aa                	mv	a1,a0
ffffffffc020028e:	00006517          	auipc	a0,0x6
ffffffffc0200292:	3b250513          	addi	a0,a0,946 # ffffffffc0206640 <etext+0x52>
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc0200296:	ec06                	sd	ra,24(sp)
ffffffffc0200298:	f436                	sd	a3,40(sp)
ffffffffc020029a:	f83a                	sd	a4,48(sp)
ffffffffc020029c:	e0c2                	sd	a6,64(sp)
ffffffffc020029e:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02002a0:	e43e                	sd	a5,8(sp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc02002a2:	e2fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02002a6:	65a2                	ld	a1,8(sp)
ffffffffc02002a8:	8522                	mv	a0,s0
ffffffffc02002aa:	e07ff0ef          	jal	ra,ffffffffc02000b0 <vcprintf>
    cprintf("\n");
ffffffffc02002ae:	00007517          	auipc	a0,0x7
ffffffffc02002b2:	15a50513          	addi	a0,a0,346 # ffffffffc0207408 <commands+0xca8>
ffffffffc02002b6:	e1bff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    va_end(ap);
}
ffffffffc02002ba:	60e2                	ld	ra,24(sp)
ffffffffc02002bc:	6442                	ld	s0,16(sp)
ffffffffc02002be:	6161                	addi	sp,sp,80
ffffffffc02002c0:	8082                	ret

ffffffffc02002c2 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc02002c2:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc02002c4:	00006517          	auipc	a0,0x6
ffffffffc02002c8:	3cc50513          	addi	a0,a0,972 # ffffffffc0206690 <etext+0xa2>
void print_kerninfo(void) {
ffffffffc02002cc:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc02002ce:	e03ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc02002d2:	00000597          	auipc	a1,0x0
ffffffffc02002d6:	d6458593          	addi	a1,a1,-668 # ffffffffc0200036 <kern_init>
ffffffffc02002da:	00006517          	auipc	a0,0x6
ffffffffc02002de:	3d650513          	addi	a0,a0,982 # ffffffffc02066b0 <etext+0xc2>
ffffffffc02002e2:	defff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc02002e6:	00006597          	auipc	a1,0x6
ffffffffc02002ea:	30858593          	addi	a1,a1,776 # ffffffffc02065ee <etext>
ffffffffc02002ee:	00006517          	auipc	a0,0x6
ffffffffc02002f2:	3e250513          	addi	a0,a0,994 # ffffffffc02066d0 <etext+0xe2>
ffffffffc02002f6:	ddbff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc02002fa:	000a1597          	auipc	a1,0xa1
ffffffffc02002fe:	14e58593          	addi	a1,a1,334 # ffffffffc02a1448 <edata>
ffffffffc0200302:	00006517          	auipc	a0,0x6
ffffffffc0200306:	3ee50513          	addi	a0,a0,1006 # ffffffffc02066f0 <etext+0x102>
ffffffffc020030a:	dc7ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc020030e:	000ac597          	auipc	a1,0xac
ffffffffc0200312:	6ca58593          	addi	a1,a1,1738 # ffffffffc02ac9d8 <end>
ffffffffc0200316:	00006517          	auipc	a0,0x6
ffffffffc020031a:	3fa50513          	addi	a0,a0,1018 # ffffffffc0206710 <etext+0x122>
ffffffffc020031e:	db3ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200322:	000ad597          	auipc	a1,0xad
ffffffffc0200326:	ab558593          	addi	a1,a1,-1355 # ffffffffc02acdd7 <end+0x3ff>
ffffffffc020032a:	00000797          	auipc	a5,0x0
ffffffffc020032e:	d0c78793          	addi	a5,a5,-756 # ffffffffc0200036 <kern_init>
ffffffffc0200332:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200336:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc020033a:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020033c:	3ff5f593          	andi	a1,a1,1023
ffffffffc0200340:	95be                	add	a1,a1,a5
ffffffffc0200342:	85a9                	srai	a1,a1,0xa
ffffffffc0200344:	00006517          	auipc	a0,0x6
ffffffffc0200348:	3ec50513          	addi	a0,a0,1004 # ffffffffc0206730 <etext+0x142>
}
ffffffffc020034c:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020034e:	b349                	j	ffffffffc02000d0 <cprintf>

ffffffffc0200350 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc0200350:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc0200352:	00006617          	auipc	a2,0x6
ffffffffc0200356:	30e60613          	addi	a2,a2,782 # ffffffffc0206660 <etext+0x72>
ffffffffc020035a:	04d00593          	li	a1,77
ffffffffc020035e:	00006517          	auipc	a0,0x6
ffffffffc0200362:	31a50513          	addi	a0,a0,794 # ffffffffc0206678 <etext+0x8a>
void print_stackframe(void) {
ffffffffc0200366:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc0200368:	eadff0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc020036c <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc020036c:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc020036e:	00006617          	auipc	a2,0x6
ffffffffc0200372:	4d260613          	addi	a2,a2,1234 # ffffffffc0206840 <commands+0xe0>
ffffffffc0200376:	00006597          	auipc	a1,0x6
ffffffffc020037a:	4ea58593          	addi	a1,a1,1258 # ffffffffc0206860 <commands+0x100>
ffffffffc020037e:	00006517          	auipc	a0,0x6
ffffffffc0200382:	4ea50513          	addi	a0,a0,1258 # ffffffffc0206868 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200386:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200388:	d49ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc020038c:	00006617          	auipc	a2,0x6
ffffffffc0200390:	4ec60613          	addi	a2,a2,1260 # ffffffffc0206878 <commands+0x118>
ffffffffc0200394:	00006597          	auipc	a1,0x6
ffffffffc0200398:	50c58593          	addi	a1,a1,1292 # ffffffffc02068a0 <commands+0x140>
ffffffffc020039c:	00006517          	auipc	a0,0x6
ffffffffc02003a0:	4cc50513          	addi	a0,a0,1228 # ffffffffc0206868 <commands+0x108>
ffffffffc02003a4:	d2dff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc02003a8:	00006617          	auipc	a2,0x6
ffffffffc02003ac:	50860613          	addi	a2,a2,1288 # ffffffffc02068b0 <commands+0x150>
ffffffffc02003b0:	00006597          	auipc	a1,0x6
ffffffffc02003b4:	52058593          	addi	a1,a1,1312 # ffffffffc02068d0 <commands+0x170>
ffffffffc02003b8:	00006517          	auipc	a0,0x6
ffffffffc02003bc:	4b050513          	addi	a0,a0,1200 # ffffffffc0206868 <commands+0x108>
ffffffffc02003c0:	d11ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    }
    return 0;
}
ffffffffc02003c4:	60a2                	ld	ra,8(sp)
ffffffffc02003c6:	4501                	li	a0,0
ffffffffc02003c8:	0141                	addi	sp,sp,16
ffffffffc02003ca:	8082                	ret

ffffffffc02003cc <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc02003cc:	1141                	addi	sp,sp,-16
ffffffffc02003ce:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc02003d0:	ef3ff0ef          	jal	ra,ffffffffc02002c2 <print_kerninfo>
    return 0;
}
ffffffffc02003d4:	60a2                	ld	ra,8(sp)
ffffffffc02003d6:	4501                	li	a0,0
ffffffffc02003d8:	0141                	addi	sp,sp,16
ffffffffc02003da:	8082                	ret

ffffffffc02003dc <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc02003dc:	1141                	addi	sp,sp,-16
ffffffffc02003de:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc02003e0:	f71ff0ef          	jal	ra,ffffffffc0200350 <print_stackframe>
    return 0;
}
ffffffffc02003e4:	60a2                	ld	ra,8(sp)
ffffffffc02003e6:	4501                	li	a0,0
ffffffffc02003e8:	0141                	addi	sp,sp,16
ffffffffc02003ea:	8082                	ret

ffffffffc02003ec <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc02003ec:	7115                	addi	sp,sp,-224
ffffffffc02003ee:	e962                	sd	s8,144(sp)
ffffffffc02003f0:	8c2a                	mv	s8,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02003f2:	00006517          	auipc	a0,0x6
ffffffffc02003f6:	3b650513          	addi	a0,a0,950 # ffffffffc02067a8 <commands+0x48>
kmonitor(struct trapframe *tf) {
ffffffffc02003fa:	ed86                	sd	ra,216(sp)
ffffffffc02003fc:	e9a2                	sd	s0,208(sp)
ffffffffc02003fe:	e5a6                	sd	s1,200(sp)
ffffffffc0200400:	e1ca                	sd	s2,192(sp)
ffffffffc0200402:	fd4e                	sd	s3,184(sp)
ffffffffc0200404:	f952                	sd	s4,176(sp)
ffffffffc0200406:	f556                	sd	s5,168(sp)
ffffffffc0200408:	f15a                	sd	s6,160(sp)
ffffffffc020040a:	ed5e                	sd	s7,152(sp)
ffffffffc020040c:	e566                	sd	s9,136(sp)
ffffffffc020040e:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200410:	cc1ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc0200414:	00006517          	auipc	a0,0x6
ffffffffc0200418:	3bc50513          	addi	a0,a0,956 # ffffffffc02067d0 <commands+0x70>
ffffffffc020041c:	cb5ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    if (tf != NULL) {
ffffffffc0200420:	000c0563          	beqz	s8,ffffffffc020042a <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc0200424:	8562                	mv	a0,s8
ffffffffc0200426:	41c000ef          	jal	ra,ffffffffc0200842 <print_trapframe>
ffffffffc020042a:	00006c97          	auipc	s9,0x6
ffffffffc020042e:	336c8c93          	addi	s9,s9,822 # ffffffffc0206760 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200432:	00006997          	auipc	s3,0x6
ffffffffc0200436:	3c698993          	addi	s3,s3,966 # ffffffffc02067f8 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020043a:	00006917          	auipc	s2,0x6
ffffffffc020043e:	3c690913          	addi	s2,s2,966 # ffffffffc0206800 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc0200442:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200444:	00006b17          	auipc	s6,0x6
ffffffffc0200448:	3c4b0b13          	addi	s6,s6,964 # ffffffffc0206808 <commands+0xa8>
    if (argc == 0) {
ffffffffc020044c:	00006a97          	auipc	s5,0x6
ffffffffc0200450:	414a8a93          	addi	s5,s5,1044 # ffffffffc0206860 <commands+0x100>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200454:	4b8d                	li	s7,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200456:	854e                	mv	a0,s3
ffffffffc0200458:	cffff0ef          	jal	ra,ffffffffc0200156 <readline>
ffffffffc020045c:	842a                	mv	s0,a0
ffffffffc020045e:	dd65                	beqz	a0,ffffffffc0200456 <kmonitor+0x6a>
ffffffffc0200460:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc0200464:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200466:	c999                	beqz	a1,ffffffffc020047c <kmonitor+0x90>
ffffffffc0200468:	854a                	mv	a0,s2
ffffffffc020046a:	539050ef          	jal	ra,ffffffffc02061a2 <strchr>
ffffffffc020046e:	c925                	beqz	a0,ffffffffc02004de <kmonitor+0xf2>
            *buf ++ = '\0';
ffffffffc0200470:	00144583          	lbu	a1,1(s0)
ffffffffc0200474:	00040023          	sb	zero,0(s0)
ffffffffc0200478:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020047a:	f5fd                	bnez	a1,ffffffffc0200468 <kmonitor+0x7c>
    if (argc == 0) {
ffffffffc020047c:	dce9                	beqz	s1,ffffffffc0200456 <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020047e:	6582                	ld	a1,0(sp)
ffffffffc0200480:	00006d17          	auipc	s10,0x6
ffffffffc0200484:	2e0d0d13          	addi	s10,s10,736 # ffffffffc0206760 <commands>
    if (argc == 0) {
ffffffffc0200488:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020048a:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020048c:	0d61                	addi	s10,s10,24
ffffffffc020048e:	4eb050ef          	jal	ra,ffffffffc0206178 <strcmp>
ffffffffc0200492:	c919                	beqz	a0,ffffffffc02004a8 <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200494:	2405                	addiw	s0,s0,1
ffffffffc0200496:	09740463          	beq	s0,s7,ffffffffc020051e <kmonitor+0x132>
ffffffffc020049a:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020049e:	6582                	ld	a1,0(sp)
ffffffffc02004a0:	0d61                	addi	s10,s10,24
ffffffffc02004a2:	4d7050ef          	jal	ra,ffffffffc0206178 <strcmp>
ffffffffc02004a6:	f57d                	bnez	a0,ffffffffc0200494 <kmonitor+0xa8>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc02004a8:	00141793          	slli	a5,s0,0x1
ffffffffc02004ac:	97a2                	add	a5,a5,s0
ffffffffc02004ae:	078e                	slli	a5,a5,0x3
ffffffffc02004b0:	97e6                	add	a5,a5,s9
ffffffffc02004b2:	6b9c                	ld	a5,16(a5)
ffffffffc02004b4:	8662                	mv	a2,s8
ffffffffc02004b6:	002c                	addi	a1,sp,8
ffffffffc02004b8:	fff4851b          	addiw	a0,s1,-1
ffffffffc02004bc:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc02004be:	f8055ce3          	bgez	a0,ffffffffc0200456 <kmonitor+0x6a>
}
ffffffffc02004c2:	60ee                	ld	ra,216(sp)
ffffffffc02004c4:	644e                	ld	s0,208(sp)
ffffffffc02004c6:	64ae                	ld	s1,200(sp)
ffffffffc02004c8:	690e                	ld	s2,192(sp)
ffffffffc02004ca:	79ea                	ld	s3,184(sp)
ffffffffc02004cc:	7a4a                	ld	s4,176(sp)
ffffffffc02004ce:	7aaa                	ld	s5,168(sp)
ffffffffc02004d0:	7b0a                	ld	s6,160(sp)
ffffffffc02004d2:	6bea                	ld	s7,152(sp)
ffffffffc02004d4:	6c4a                	ld	s8,144(sp)
ffffffffc02004d6:	6caa                	ld	s9,136(sp)
ffffffffc02004d8:	6d0a                	ld	s10,128(sp)
ffffffffc02004da:	612d                	addi	sp,sp,224
ffffffffc02004dc:	8082                	ret
        if (*buf == '\0') {
ffffffffc02004de:	00044783          	lbu	a5,0(s0)
ffffffffc02004e2:	dfc9                	beqz	a5,ffffffffc020047c <kmonitor+0x90>
        if (argc == MAXARGS - 1) {
ffffffffc02004e4:	03448863          	beq	s1,s4,ffffffffc0200514 <kmonitor+0x128>
        argv[argc ++] = buf;
ffffffffc02004e8:	00349793          	slli	a5,s1,0x3
ffffffffc02004ec:	0118                	addi	a4,sp,128
ffffffffc02004ee:	97ba                	add	a5,a5,a4
ffffffffc02004f0:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02004f4:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc02004f8:	2485                	addiw	s1,s1,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02004fa:	e591                	bnez	a1,ffffffffc0200506 <kmonitor+0x11a>
ffffffffc02004fc:	b749                	j	ffffffffc020047e <kmonitor+0x92>
            buf ++;
ffffffffc02004fe:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200500:	00044583          	lbu	a1,0(s0)
ffffffffc0200504:	ddad                	beqz	a1,ffffffffc020047e <kmonitor+0x92>
ffffffffc0200506:	854a                	mv	a0,s2
ffffffffc0200508:	49b050ef          	jal	ra,ffffffffc02061a2 <strchr>
ffffffffc020050c:	d96d                	beqz	a0,ffffffffc02004fe <kmonitor+0x112>
ffffffffc020050e:	00044583          	lbu	a1,0(s0)
ffffffffc0200512:	bf91                	j	ffffffffc0200466 <kmonitor+0x7a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200514:	45c1                	li	a1,16
ffffffffc0200516:	855a                	mv	a0,s6
ffffffffc0200518:	bb9ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc020051c:	b7f1                	j	ffffffffc02004e8 <kmonitor+0xfc>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc020051e:	6582                	ld	a1,0(sp)
ffffffffc0200520:	00006517          	auipc	a0,0x6
ffffffffc0200524:	30850513          	addi	a0,a0,776 # ffffffffc0206828 <commands+0xc8>
ffffffffc0200528:	ba9ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    return 0;
ffffffffc020052c:	b72d                	j	ffffffffc0200456 <kmonitor+0x6a>

ffffffffc020052e <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc020052e:	8082                	ret

ffffffffc0200530 <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc0200530:	00253513          	sltiu	a0,a0,2
ffffffffc0200534:	8082                	ret

ffffffffc0200536 <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc0200536:	03800513          	li	a0,56
ffffffffc020053a:	8082                	ret

ffffffffc020053c <ide_read_secs>:

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc020053c:	000a1797          	auipc	a5,0xa1
ffffffffc0200540:	30c78793          	addi	a5,a5,780 # ffffffffc02a1848 <ide>
ffffffffc0200544:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {
ffffffffc0200548:	1141                	addi	sp,sp,-16
ffffffffc020054a:	8532                	mv	a0,a2
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc020054c:	95be                	add	a1,a1,a5
ffffffffc020054e:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {
ffffffffc0200552:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200554:	47f050ef          	jal	ra,ffffffffc02061d2 <memcpy>
    return 0;
}
ffffffffc0200558:	60a2                	ld	ra,8(sp)
ffffffffc020055a:	4501                	li	a0,0
ffffffffc020055c:	0141                	addi	sp,sp,16
ffffffffc020055e:	8082                	ret

ffffffffc0200560 <ide_write_secs>:

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
ffffffffc0200560:	8732                	mv	a4,a2
    int iobase = secno * SECTSIZE;
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200562:	0095979b          	slliw	a5,a1,0x9
ffffffffc0200566:	000a1517          	auipc	a0,0xa1
ffffffffc020056a:	2e250513          	addi	a0,a0,738 # ffffffffc02a1848 <ide>
                   size_t nsecs) {
ffffffffc020056e:	1141                	addi	sp,sp,-16
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200570:	00969613          	slli	a2,a3,0x9
ffffffffc0200574:	85ba                	mv	a1,a4
ffffffffc0200576:	953e                	add	a0,a0,a5
                   size_t nsecs) {
ffffffffc0200578:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc020057a:	459050ef          	jal	ra,ffffffffc02061d2 <memcpy>
    return 0;
}
ffffffffc020057e:	60a2                	ld	ra,8(sp)
ffffffffc0200580:	4501                	li	a0,0
ffffffffc0200582:	0141                	addi	sp,sp,16
ffffffffc0200584:	8082                	ret

ffffffffc0200586 <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc0200586:	67e1                	lui	a5,0x18
ffffffffc0200588:	6a078793          	addi	a5,a5,1696 # 186a0 <_binary_obj___user_exit_out_size+0xdbd8>
ffffffffc020058c:	000ac717          	auipc	a4,0xac
ffffffffc0200590:	2cf73223          	sd	a5,708(a4) # ffffffffc02ac850 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200594:	c0102573          	rdtime	a0
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc0200598:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020059a:	953e                	add	a0,a0,a5
ffffffffc020059c:	4601                	li	a2,0
ffffffffc020059e:	4881                	li	a7,0
ffffffffc02005a0:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc02005a4:	02000793          	li	a5,32
ffffffffc02005a8:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc02005ac:	00006517          	auipc	a0,0x6
ffffffffc02005b0:	33450513          	addi	a0,a0,820 # ffffffffc02068e0 <commands+0x180>
    ticks = 0;
ffffffffc02005b4:	000ac797          	auipc	a5,0xac
ffffffffc02005b8:	2e07ba23          	sd	zero,756(a5) # ffffffffc02ac8a8 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc02005bc:	be11                	j	ffffffffc02000d0 <cprintf>

ffffffffc02005be <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc02005be:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc02005c2:	000ac797          	auipc	a5,0xac
ffffffffc02005c6:	28e78793          	addi	a5,a5,654 # ffffffffc02ac850 <timebase>
ffffffffc02005ca:	639c                	ld	a5,0(a5)
ffffffffc02005cc:	4581                	li	a1,0
ffffffffc02005ce:	4601                	li	a2,0
ffffffffc02005d0:	953e                	add	a0,a0,a5
ffffffffc02005d2:	4881                	li	a7,0
ffffffffc02005d4:	00000073          	ecall
ffffffffc02005d8:	8082                	ret

ffffffffc02005da <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc02005da:	8082                	ret

ffffffffc02005dc <cons_putc>:
#include <sched.h>
#include <riscv.h>
#include <assert.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02005dc:	100027f3          	csrr	a5,sstatus
ffffffffc02005e0:	8b89                	andi	a5,a5,2
ffffffffc02005e2:	0ff57513          	andi	a0,a0,255
ffffffffc02005e6:	e799                	bnez	a5,ffffffffc02005f4 <cons_putc+0x18>
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc02005e8:	4581                	li	a1,0
ffffffffc02005ea:	4601                	li	a2,0
ffffffffc02005ec:	4885                	li	a7,1
ffffffffc02005ee:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc02005f2:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc02005f4:	1101                	addi	sp,sp,-32
ffffffffc02005f6:	ec06                	sd	ra,24(sp)
ffffffffc02005f8:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02005fa:	05a000ef          	jal	ra,ffffffffc0200654 <intr_disable>
ffffffffc02005fe:	6522                	ld	a0,8(sp)
ffffffffc0200600:	4581                	li	a1,0
ffffffffc0200602:	4601                	li	a2,0
ffffffffc0200604:	4885                	li	a7,1
ffffffffc0200606:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc020060a:	60e2                	ld	ra,24(sp)
ffffffffc020060c:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020060e:	a081                	j	ffffffffc020064e <intr_enable>

ffffffffc0200610 <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200610:	100027f3          	csrr	a5,sstatus
ffffffffc0200614:	8b89                	andi	a5,a5,2
ffffffffc0200616:	eb89                	bnez	a5,ffffffffc0200628 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc0200618:	4501                	li	a0,0
ffffffffc020061a:	4581                	li	a1,0
ffffffffc020061c:	4601                	li	a2,0
ffffffffc020061e:	4889                	li	a7,2
ffffffffc0200620:	00000073          	ecall
ffffffffc0200624:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc0200626:	8082                	ret
int cons_getc(void) {
ffffffffc0200628:	1101                	addi	sp,sp,-32
ffffffffc020062a:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc020062c:	028000ef          	jal	ra,ffffffffc0200654 <intr_disable>
ffffffffc0200630:	4501                	li	a0,0
ffffffffc0200632:	4581                	li	a1,0
ffffffffc0200634:	4601                	li	a2,0
ffffffffc0200636:	4889                	li	a7,2
ffffffffc0200638:	00000073          	ecall
ffffffffc020063c:	2501                	sext.w	a0,a0
ffffffffc020063e:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0200640:	00e000ef          	jal	ra,ffffffffc020064e <intr_enable>
}
ffffffffc0200644:	60e2                	ld	ra,24(sp)
ffffffffc0200646:	6522                	ld	a0,8(sp)
ffffffffc0200648:	6105                	addi	sp,sp,32
ffffffffc020064a:	8082                	ret

ffffffffc020064c <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
ffffffffc020064c:	8082                	ret

ffffffffc020064e <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc020064e:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc0200652:	8082                	ret

ffffffffc0200654 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200654:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200658:	8082                	ret

ffffffffc020065a <idt_init>:
void
idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc020065a:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc020065e:	00000797          	auipc	a5,0x0
ffffffffc0200662:	66a78793          	addi	a5,a5,1642 # ffffffffc0200cc8 <__alltraps>
ffffffffc0200666:	10579073          	csrw	stvec,a5
    /* Allow kernel to access user memory */
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc020066a:	000407b7          	lui	a5,0x40
ffffffffc020066e:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc0200672:	8082                	ret

ffffffffc0200674 <print_regs>:
    cprintf("  tval 0x%08x\n", tf->tval);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs* gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200674:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs* gpr) {
ffffffffc0200676:	1141                	addi	sp,sp,-16
ffffffffc0200678:	e022                	sd	s0,0(sp)
ffffffffc020067a:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020067c:	00006517          	auipc	a0,0x6
ffffffffc0200680:	5ac50513          	addi	a0,a0,1452 # ffffffffc0206c28 <commands+0x4c8>
void print_regs(struct pushregs* gpr) {
ffffffffc0200684:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200686:	a4bff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020068a:	640c                	ld	a1,8(s0)
ffffffffc020068c:	00006517          	auipc	a0,0x6
ffffffffc0200690:	5b450513          	addi	a0,a0,1460 # ffffffffc0206c40 <commands+0x4e0>
ffffffffc0200694:	a3dff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc0200698:	680c                	ld	a1,16(s0)
ffffffffc020069a:	00006517          	auipc	a0,0x6
ffffffffc020069e:	5be50513          	addi	a0,a0,1470 # ffffffffc0206c58 <commands+0x4f8>
ffffffffc02006a2:	a2fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02006a6:	6c0c                	ld	a1,24(s0)
ffffffffc02006a8:	00006517          	auipc	a0,0x6
ffffffffc02006ac:	5c850513          	addi	a0,a0,1480 # ffffffffc0206c70 <commands+0x510>
ffffffffc02006b0:	a21ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02006b4:	700c                	ld	a1,32(s0)
ffffffffc02006b6:	00006517          	auipc	a0,0x6
ffffffffc02006ba:	5d250513          	addi	a0,a0,1490 # ffffffffc0206c88 <commands+0x528>
ffffffffc02006be:	a13ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02006c2:	740c                	ld	a1,40(s0)
ffffffffc02006c4:	00006517          	auipc	a0,0x6
ffffffffc02006c8:	5dc50513          	addi	a0,a0,1500 # ffffffffc0206ca0 <commands+0x540>
ffffffffc02006cc:	a05ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02006d0:	780c                	ld	a1,48(s0)
ffffffffc02006d2:	00006517          	auipc	a0,0x6
ffffffffc02006d6:	5e650513          	addi	a0,a0,1510 # ffffffffc0206cb8 <commands+0x558>
ffffffffc02006da:	9f7ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02006de:	7c0c                	ld	a1,56(s0)
ffffffffc02006e0:	00006517          	auipc	a0,0x6
ffffffffc02006e4:	5f050513          	addi	a0,a0,1520 # ffffffffc0206cd0 <commands+0x570>
ffffffffc02006e8:	9e9ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02006ec:	602c                	ld	a1,64(s0)
ffffffffc02006ee:	00006517          	auipc	a0,0x6
ffffffffc02006f2:	5fa50513          	addi	a0,a0,1530 # ffffffffc0206ce8 <commands+0x588>
ffffffffc02006f6:	9dbff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02006fa:	642c                	ld	a1,72(s0)
ffffffffc02006fc:	00006517          	auipc	a0,0x6
ffffffffc0200700:	60450513          	addi	a0,a0,1540 # ffffffffc0206d00 <commands+0x5a0>
ffffffffc0200704:	9cdff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200708:	682c                	ld	a1,80(s0)
ffffffffc020070a:	00006517          	auipc	a0,0x6
ffffffffc020070e:	60e50513          	addi	a0,a0,1550 # ffffffffc0206d18 <commands+0x5b8>
ffffffffc0200712:	9bfff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200716:	6c2c                	ld	a1,88(s0)
ffffffffc0200718:	00006517          	auipc	a0,0x6
ffffffffc020071c:	61850513          	addi	a0,a0,1560 # ffffffffc0206d30 <commands+0x5d0>
ffffffffc0200720:	9b1ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200724:	702c                	ld	a1,96(s0)
ffffffffc0200726:	00006517          	auipc	a0,0x6
ffffffffc020072a:	62250513          	addi	a0,a0,1570 # ffffffffc0206d48 <commands+0x5e8>
ffffffffc020072e:	9a3ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200732:	742c                	ld	a1,104(s0)
ffffffffc0200734:	00006517          	auipc	a0,0x6
ffffffffc0200738:	62c50513          	addi	a0,a0,1580 # ffffffffc0206d60 <commands+0x600>
ffffffffc020073c:	995ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200740:	782c                	ld	a1,112(s0)
ffffffffc0200742:	00006517          	auipc	a0,0x6
ffffffffc0200746:	63650513          	addi	a0,a0,1590 # ffffffffc0206d78 <commands+0x618>
ffffffffc020074a:	987ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc020074e:	7c2c                	ld	a1,120(s0)
ffffffffc0200750:	00006517          	auipc	a0,0x6
ffffffffc0200754:	64050513          	addi	a0,a0,1600 # ffffffffc0206d90 <commands+0x630>
ffffffffc0200758:	979ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020075c:	604c                	ld	a1,128(s0)
ffffffffc020075e:	00006517          	auipc	a0,0x6
ffffffffc0200762:	64a50513          	addi	a0,a0,1610 # ffffffffc0206da8 <commands+0x648>
ffffffffc0200766:	96bff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020076a:	644c                	ld	a1,136(s0)
ffffffffc020076c:	00006517          	auipc	a0,0x6
ffffffffc0200770:	65450513          	addi	a0,a0,1620 # ffffffffc0206dc0 <commands+0x660>
ffffffffc0200774:	95dff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200778:	684c                	ld	a1,144(s0)
ffffffffc020077a:	00006517          	auipc	a0,0x6
ffffffffc020077e:	65e50513          	addi	a0,a0,1630 # ffffffffc0206dd8 <commands+0x678>
ffffffffc0200782:	94fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200786:	6c4c                	ld	a1,152(s0)
ffffffffc0200788:	00006517          	auipc	a0,0x6
ffffffffc020078c:	66850513          	addi	a0,a0,1640 # ffffffffc0206df0 <commands+0x690>
ffffffffc0200790:	941ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200794:	704c                	ld	a1,160(s0)
ffffffffc0200796:	00006517          	auipc	a0,0x6
ffffffffc020079a:	67250513          	addi	a0,a0,1650 # ffffffffc0206e08 <commands+0x6a8>
ffffffffc020079e:	933ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02007a2:	744c                	ld	a1,168(s0)
ffffffffc02007a4:	00006517          	auipc	a0,0x6
ffffffffc02007a8:	67c50513          	addi	a0,a0,1660 # ffffffffc0206e20 <commands+0x6c0>
ffffffffc02007ac:	925ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02007b0:	784c                	ld	a1,176(s0)
ffffffffc02007b2:	00006517          	auipc	a0,0x6
ffffffffc02007b6:	68650513          	addi	a0,a0,1670 # ffffffffc0206e38 <commands+0x6d8>
ffffffffc02007ba:	917ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02007be:	7c4c                	ld	a1,184(s0)
ffffffffc02007c0:	00006517          	auipc	a0,0x6
ffffffffc02007c4:	69050513          	addi	a0,a0,1680 # ffffffffc0206e50 <commands+0x6f0>
ffffffffc02007c8:	909ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02007cc:	606c                	ld	a1,192(s0)
ffffffffc02007ce:	00006517          	auipc	a0,0x6
ffffffffc02007d2:	69a50513          	addi	a0,a0,1690 # ffffffffc0206e68 <commands+0x708>
ffffffffc02007d6:	8fbff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02007da:	646c                	ld	a1,200(s0)
ffffffffc02007dc:	00006517          	auipc	a0,0x6
ffffffffc02007e0:	6a450513          	addi	a0,a0,1700 # ffffffffc0206e80 <commands+0x720>
ffffffffc02007e4:	8edff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02007e8:	686c                	ld	a1,208(s0)
ffffffffc02007ea:	00006517          	auipc	a0,0x6
ffffffffc02007ee:	6ae50513          	addi	a0,a0,1710 # ffffffffc0206e98 <commands+0x738>
ffffffffc02007f2:	8dfff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02007f6:	6c6c                	ld	a1,216(s0)
ffffffffc02007f8:	00006517          	auipc	a0,0x6
ffffffffc02007fc:	6b850513          	addi	a0,a0,1720 # ffffffffc0206eb0 <commands+0x750>
ffffffffc0200800:	8d1ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200804:	706c                	ld	a1,224(s0)
ffffffffc0200806:	00006517          	auipc	a0,0x6
ffffffffc020080a:	6c250513          	addi	a0,a0,1730 # ffffffffc0206ec8 <commands+0x768>
ffffffffc020080e:	8c3ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200812:	746c                	ld	a1,232(s0)
ffffffffc0200814:	00006517          	auipc	a0,0x6
ffffffffc0200818:	6cc50513          	addi	a0,a0,1740 # ffffffffc0206ee0 <commands+0x780>
ffffffffc020081c:	8b5ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200820:	786c                	ld	a1,240(s0)
ffffffffc0200822:	00006517          	auipc	a0,0x6
ffffffffc0200826:	6d650513          	addi	a0,a0,1750 # ffffffffc0206ef8 <commands+0x798>
ffffffffc020082a:	8a7ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020082e:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200830:	6402                	ld	s0,0(sp)
ffffffffc0200832:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200834:	00006517          	auipc	a0,0x6
ffffffffc0200838:	6dc50513          	addi	a0,a0,1756 # ffffffffc0206f10 <commands+0x7b0>
}
ffffffffc020083c:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020083e:	893ff06f          	j	ffffffffc02000d0 <cprintf>

ffffffffc0200842 <print_trapframe>:
print_trapframe(struct trapframe *tf) {
ffffffffc0200842:	1141                	addi	sp,sp,-16
ffffffffc0200844:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200846:	85aa                	mv	a1,a0
print_trapframe(struct trapframe *tf) {
ffffffffc0200848:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc020084a:	00006517          	auipc	a0,0x6
ffffffffc020084e:	6de50513          	addi	a0,a0,1758 # ffffffffc0206f28 <commands+0x7c8>
print_trapframe(struct trapframe *tf) {
ffffffffc0200852:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200854:	87dff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200858:	8522                	mv	a0,s0
ffffffffc020085a:	e1bff0ef          	jal	ra,ffffffffc0200674 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020085e:	10043583          	ld	a1,256(s0)
ffffffffc0200862:	00006517          	auipc	a0,0x6
ffffffffc0200866:	6de50513          	addi	a0,a0,1758 # ffffffffc0206f40 <commands+0x7e0>
ffffffffc020086a:	867ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020086e:	10843583          	ld	a1,264(s0)
ffffffffc0200872:	00006517          	auipc	a0,0x6
ffffffffc0200876:	6e650513          	addi	a0,a0,1766 # ffffffffc0206f58 <commands+0x7f8>
ffffffffc020087a:	857ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  tval 0x%08x\n", tf->tval);
ffffffffc020087e:	11043583          	ld	a1,272(s0)
ffffffffc0200882:	00006517          	auipc	a0,0x6
ffffffffc0200886:	6ee50513          	addi	a0,a0,1774 # ffffffffc0206f70 <commands+0x810>
ffffffffc020088a:	847ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020088e:	11843583          	ld	a1,280(s0)
}
ffffffffc0200892:	6402                	ld	s0,0(sp)
ffffffffc0200894:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200896:	00006517          	auipc	a0,0x6
ffffffffc020089a:	6ea50513          	addi	a0,a0,1770 # ffffffffc0206f80 <commands+0x820>
}
ffffffffc020089e:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02008a0:	831ff06f          	j	ffffffffc02000d0 <cprintf>

ffffffffc02008a4 <pgfault_handler>:
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int
pgfault_handler(struct trapframe *tf) {
ffffffffc02008a4:	1101                	addi	sp,sp,-32
ffffffffc02008a6:	e426                	sd	s1,8(sp)
    extern struct mm_struct *check_mm_struct;
    if(check_mm_struct !=NULL) { //used for test check_swap
ffffffffc02008a8:	000ac497          	auipc	s1,0xac
ffffffffc02008ac:	02848493          	addi	s1,s1,40 # ffffffffc02ac8d0 <check_mm_struct>
ffffffffc02008b0:	609c                	ld	a5,0(s1)
pgfault_handler(struct trapframe *tf) {
ffffffffc02008b2:	e822                	sd	s0,16(sp)
ffffffffc02008b4:	ec06                	sd	ra,24(sp)
ffffffffc02008b6:	842a                	mv	s0,a0
    if(check_mm_struct !=NULL) { //used for test check_swap
ffffffffc02008b8:	cbbd                	beqz	a5,ffffffffc020092e <pgfault_handler+0x8a>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02008ba:	10053783          	ld	a5,256(a0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02008be:	11053583          	ld	a1,272(a0)
ffffffffc02008c2:	04b00613          	li	a2,75
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02008c6:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02008ca:	cba1                	beqz	a5,ffffffffc020091a <pgfault_handler+0x76>
ffffffffc02008cc:	11843703          	ld	a4,280(s0)
ffffffffc02008d0:	47bd                	li	a5,15
ffffffffc02008d2:	05700693          	li	a3,87
ffffffffc02008d6:	00f70463          	beq	a4,a5,ffffffffc02008de <pgfault_handler+0x3a>
ffffffffc02008da:	05200693          	li	a3,82
ffffffffc02008de:	00006517          	auipc	a0,0x6
ffffffffc02008e2:	2ca50513          	addi	a0,a0,714 # ffffffffc0206ba8 <commands+0x448>
ffffffffc02008e6:	feaff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            print_pgfault(tf);
        }
    struct mm_struct *mm;
    if (check_mm_struct != NULL) {
ffffffffc02008ea:	6088                	ld	a0,0(s1)
ffffffffc02008ec:	c129                	beqz	a0,ffffffffc020092e <pgfault_handler+0x8a>
        assert(current == idleproc);
ffffffffc02008ee:	000ac797          	auipc	a5,0xac
ffffffffc02008f2:	f9a78793          	addi	a5,a5,-102 # ffffffffc02ac888 <current>
ffffffffc02008f6:	6398                	ld	a4,0(a5)
ffffffffc02008f8:	000ac797          	auipc	a5,0xac
ffffffffc02008fc:	f9878793          	addi	a5,a5,-104 # ffffffffc02ac890 <idleproc>
ffffffffc0200900:	639c                	ld	a5,0(a5)
ffffffffc0200902:	04f71763          	bne	a4,a5,ffffffffc0200950 <pgfault_handler+0xac>
            print_pgfault(tf);
            panic("unhandled page fault.\n");
        }
        mm = current->mm;
    }
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200906:	11043603          	ld	a2,272(s0)
ffffffffc020090a:	11843583          	ld	a1,280(s0)
}
ffffffffc020090e:	6442                	ld	s0,16(sp)
ffffffffc0200910:	60e2                	ld	ra,24(sp)
ffffffffc0200912:	64a2                	ld	s1,8(sp)
ffffffffc0200914:	6105                	addi	sp,sp,32
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200916:	3760206f          	j	ffffffffc0202c8c <do_pgfault>
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc020091a:	11843703          	ld	a4,280(s0)
ffffffffc020091e:	47bd                	li	a5,15
ffffffffc0200920:	05500613          	li	a2,85
ffffffffc0200924:	05700693          	li	a3,87
ffffffffc0200928:	faf719e3          	bne	a4,a5,ffffffffc02008da <pgfault_handler+0x36>
ffffffffc020092c:	bf4d                	j	ffffffffc02008de <pgfault_handler+0x3a>
        if (current == NULL) {
ffffffffc020092e:	000ac797          	auipc	a5,0xac
ffffffffc0200932:	f5a78793          	addi	a5,a5,-166 # ffffffffc02ac888 <current>
ffffffffc0200936:	639c                	ld	a5,0(a5)
ffffffffc0200938:	cf85                	beqz	a5,ffffffffc0200970 <pgfault_handler+0xcc>
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc020093a:	11043603          	ld	a2,272(s0)
ffffffffc020093e:	11843583          	ld	a1,280(s0)
}
ffffffffc0200942:	6442                	ld	s0,16(sp)
ffffffffc0200944:	60e2                	ld	ra,24(sp)
ffffffffc0200946:	64a2                	ld	s1,8(sp)
        mm = current->mm;
ffffffffc0200948:	7788                	ld	a0,40(a5)
}
ffffffffc020094a:	6105                	addi	sp,sp,32
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc020094c:	3400206f          	j	ffffffffc0202c8c <do_pgfault>
        assert(current == idleproc);
ffffffffc0200950:	00006697          	auipc	a3,0x6
ffffffffc0200954:	27868693          	addi	a3,a3,632 # ffffffffc0206bc8 <commands+0x468>
ffffffffc0200958:	00006617          	auipc	a2,0x6
ffffffffc020095c:	28860613          	addi	a2,a2,648 # ffffffffc0206be0 <commands+0x480>
ffffffffc0200960:	06b00593          	li	a1,107
ffffffffc0200964:	00006517          	auipc	a0,0x6
ffffffffc0200968:	29450513          	addi	a0,a0,660 # ffffffffc0206bf8 <commands+0x498>
ffffffffc020096c:	8a9ff0ef          	jal	ra,ffffffffc0200214 <__panic>
            print_trapframe(tf);
ffffffffc0200970:	8522                	mv	a0,s0
ffffffffc0200972:	ed1ff0ef          	jal	ra,ffffffffc0200842 <print_trapframe>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200976:	10043783          	ld	a5,256(s0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc020097a:	11043583          	ld	a1,272(s0)
ffffffffc020097e:	04b00613          	li	a2,75
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200982:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200986:	e399                	bnez	a5,ffffffffc020098c <pgfault_handler+0xe8>
ffffffffc0200988:	05500613          	li	a2,85
ffffffffc020098c:	11843703          	ld	a4,280(s0)
ffffffffc0200990:	47bd                	li	a5,15
ffffffffc0200992:	02f70663          	beq	a4,a5,ffffffffc02009be <pgfault_handler+0x11a>
ffffffffc0200996:	05200693          	li	a3,82
ffffffffc020099a:	00006517          	auipc	a0,0x6
ffffffffc020099e:	20e50513          	addi	a0,a0,526 # ffffffffc0206ba8 <commands+0x448>
ffffffffc02009a2:	f2eff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            panic("unhandled page fault.\n");
ffffffffc02009a6:	00006617          	auipc	a2,0x6
ffffffffc02009aa:	26a60613          	addi	a2,a2,618 # ffffffffc0206c10 <commands+0x4b0>
ffffffffc02009ae:	07200593          	li	a1,114
ffffffffc02009b2:	00006517          	auipc	a0,0x6
ffffffffc02009b6:	24650513          	addi	a0,a0,582 # ffffffffc0206bf8 <commands+0x498>
ffffffffc02009ba:	85bff0ef          	jal	ra,ffffffffc0200214 <__panic>
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02009be:	05700693          	li	a3,87
ffffffffc02009c2:	bfe1                	j	ffffffffc020099a <pgfault_handler+0xf6>

ffffffffc02009c4 <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02009c4:	11853783          	ld	a5,280(a0)
    switch (cause) {
ffffffffc02009c8:	472d                	li	a4,11
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02009ca:	0786                	slli	a5,a5,0x1
ffffffffc02009cc:	8385                	srli	a5,a5,0x1
    switch (cause) {
ffffffffc02009ce:	08f76763          	bltu	a4,a5,ffffffffc0200a5c <interrupt_handler+0x98>
ffffffffc02009d2:	00006717          	auipc	a4,0x6
ffffffffc02009d6:	f2a70713          	addi	a4,a4,-214 # ffffffffc02068fc <commands+0x19c>
ffffffffc02009da:	078a                	slli	a5,a5,0x2
ffffffffc02009dc:	97ba                	add	a5,a5,a4
ffffffffc02009de:	439c                	lw	a5,0(a5)
ffffffffc02009e0:	97ba                	add	a5,a5,a4
ffffffffc02009e2:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02009e4:	00006517          	auipc	a0,0x6
ffffffffc02009e8:	18450513          	addi	a0,a0,388 # ffffffffc0206b68 <commands+0x408>
ffffffffc02009ec:	ee4ff06f          	j	ffffffffc02000d0 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02009f0:	00006517          	auipc	a0,0x6
ffffffffc02009f4:	15850513          	addi	a0,a0,344 # ffffffffc0206b48 <commands+0x3e8>
ffffffffc02009f8:	ed8ff06f          	j	ffffffffc02000d0 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02009fc:	00006517          	auipc	a0,0x6
ffffffffc0200a00:	10c50513          	addi	a0,a0,268 # ffffffffc0206b08 <commands+0x3a8>
ffffffffc0200a04:	eccff06f          	j	ffffffffc02000d0 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200a08:	00006517          	auipc	a0,0x6
ffffffffc0200a0c:	12050513          	addi	a0,a0,288 # ffffffffc0206b28 <commands+0x3c8>
ffffffffc0200a10:	ec0ff06f          	j	ffffffffc02000d0 <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
ffffffffc0200a14:	00006517          	auipc	a0,0x6
ffffffffc0200a18:	17450513          	addi	a0,a0,372 # ffffffffc0206b88 <commands+0x428>
ffffffffc0200a1c:	eb4ff06f          	j	ffffffffc02000d0 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc0200a20:	1141                	addi	sp,sp,-16
ffffffffc0200a22:	e406                	sd	ra,8(sp)
            clock_set_next_event();
ffffffffc0200a24:	b9bff0ef          	jal	ra,ffffffffc02005be <clock_set_next_event>
            if (++ticks % TICK_NUM == 0 && current) {
ffffffffc0200a28:	000ac797          	auipc	a5,0xac
ffffffffc0200a2c:	e8078793          	addi	a5,a5,-384 # ffffffffc02ac8a8 <ticks>
ffffffffc0200a30:	639c                	ld	a5,0(a5)
ffffffffc0200a32:	06400713          	li	a4,100
ffffffffc0200a36:	0785                	addi	a5,a5,1
ffffffffc0200a38:	02e7f733          	remu	a4,a5,a4
ffffffffc0200a3c:	000ac697          	auipc	a3,0xac
ffffffffc0200a40:	e6f6b623          	sd	a5,-404(a3) # ffffffffc02ac8a8 <ticks>
ffffffffc0200a44:	eb09                	bnez	a4,ffffffffc0200a56 <interrupt_handler+0x92>
ffffffffc0200a46:	000ac797          	auipc	a5,0xac
ffffffffc0200a4a:	e4278793          	addi	a5,a5,-446 # ffffffffc02ac888 <current>
ffffffffc0200a4e:	639c                	ld	a5,0(a5)
ffffffffc0200a50:	c399                	beqz	a5,ffffffffc0200a56 <interrupt_handler+0x92>
                current->need_resched = 1;
ffffffffc0200a52:	4705                	li	a4,1
ffffffffc0200a54:	ef98                	sd	a4,24(a5)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200a56:	60a2                	ld	ra,8(sp)
ffffffffc0200a58:	0141                	addi	sp,sp,16
ffffffffc0200a5a:	8082                	ret
            print_trapframe(tf);
ffffffffc0200a5c:	b3dd                	j	ffffffffc0200842 <print_trapframe>

ffffffffc0200a5e <exception_handler>:
void kernel_execve_ret(struct trapframe *tf,uintptr_t kstacktop);
void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc0200a5e:	11853783          	ld	a5,280(a0)
ffffffffc0200a62:	473d                	li	a4,15
ffffffffc0200a64:	1af76c63          	bltu	a4,a5,ffffffffc0200c1c <exception_handler+0x1be>
ffffffffc0200a68:	00006717          	auipc	a4,0x6
ffffffffc0200a6c:	ec470713          	addi	a4,a4,-316 # ffffffffc020692c <commands+0x1cc>
ffffffffc0200a70:	078a                	slli	a5,a5,0x2
ffffffffc0200a72:	97ba                	add	a5,a5,a4
ffffffffc0200a74:	439c                	lw	a5,0(a5)
void exception_handler(struct trapframe *tf) {
ffffffffc0200a76:	1101                	addi	sp,sp,-32
ffffffffc0200a78:	e822                	sd	s0,16(sp)
ffffffffc0200a7a:	ec06                	sd	ra,24(sp)
ffffffffc0200a7c:	e426                	sd	s1,8(sp)
    switch (tf->cause) {
ffffffffc0200a7e:	97ba                	add	a5,a5,a4
ffffffffc0200a80:	842a                	mv	s0,a0
ffffffffc0200a82:	8782                	jr	a5
            //cprintf("Environment call from U-mode\n");
            tf->epc += 4;
            syscall();
            break;
        case CAUSE_SUPERVISOR_ECALL:
            cprintf("Environment call from S-mode\n");
ffffffffc0200a84:	00006517          	auipc	a0,0x6
ffffffffc0200a88:	fdc50513          	addi	a0,a0,-36 # ffffffffc0206a60 <commands+0x300>
ffffffffc0200a8c:	e44ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            tf->epc += 4;
ffffffffc0200a90:	10843783          	ld	a5,264(s0)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200a94:	60e2                	ld	ra,24(sp)
ffffffffc0200a96:	64a2                	ld	s1,8(sp)
            tf->epc += 4;
ffffffffc0200a98:	0791                	addi	a5,a5,4
ffffffffc0200a9a:	10f43423          	sd	a5,264(s0)
}
ffffffffc0200a9e:	6442                	ld	s0,16(sp)
ffffffffc0200aa0:	6105                	addi	sp,sp,32
            syscall();
ffffffffc0200aa2:	6000506f          	j	ffffffffc02060a2 <syscall>
            cprintf("Environment call from H-mode\n");
ffffffffc0200aa6:	00006517          	auipc	a0,0x6
ffffffffc0200aaa:	fda50513          	addi	a0,a0,-38 # ffffffffc0206a80 <commands+0x320>
}
ffffffffc0200aae:	6442                	ld	s0,16(sp)
ffffffffc0200ab0:	60e2                	ld	ra,24(sp)
ffffffffc0200ab2:	64a2                	ld	s1,8(sp)
ffffffffc0200ab4:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc0200ab6:	e1aff06f          	j	ffffffffc02000d0 <cprintf>
            cprintf("Environment call from M-mode\n");
ffffffffc0200aba:	00006517          	auipc	a0,0x6
ffffffffc0200abe:	fe650513          	addi	a0,a0,-26 # ffffffffc0206aa0 <commands+0x340>
ffffffffc0200ac2:	b7f5                	j	ffffffffc0200aae <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200ac4:	00006517          	auipc	a0,0x6
ffffffffc0200ac8:	ffc50513          	addi	a0,a0,-4 # ffffffffc0206ac0 <commands+0x360>
ffffffffc0200acc:	b7cd                	j	ffffffffc0200aae <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200ace:	00006517          	auipc	a0,0x6
ffffffffc0200ad2:	00a50513          	addi	a0,a0,10 # ffffffffc0206ad8 <commands+0x378>
ffffffffc0200ad6:	dfaff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200ada:	8522                	mv	a0,s0
ffffffffc0200adc:	dc9ff0ef          	jal	ra,ffffffffc02008a4 <pgfault_handler>
ffffffffc0200ae0:	84aa                	mv	s1,a0
ffffffffc0200ae2:	12051e63          	bnez	a0,ffffffffc0200c1e <exception_handler+0x1c0>
}
ffffffffc0200ae6:	60e2                	ld	ra,24(sp)
ffffffffc0200ae8:	6442                	ld	s0,16(sp)
ffffffffc0200aea:	64a2                	ld	s1,8(sp)
ffffffffc0200aec:	6105                	addi	sp,sp,32
ffffffffc0200aee:	8082                	ret
            cprintf("Store/AMO page fault\n");
ffffffffc0200af0:	00006517          	auipc	a0,0x6
ffffffffc0200af4:	00050513          	mv	a0,a0
ffffffffc0200af8:	dd8ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200afc:	8522                	mv	a0,s0
ffffffffc0200afe:	da7ff0ef          	jal	ra,ffffffffc02008a4 <pgfault_handler>
ffffffffc0200b02:	84aa                	mv	s1,a0
ffffffffc0200b04:	d16d                	beqz	a0,ffffffffc0200ae6 <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200b06:	8522                	mv	a0,s0
ffffffffc0200b08:	d3bff0ef          	jal	ra,ffffffffc0200842 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200b0c:	86a6                	mv	a3,s1
ffffffffc0200b0e:	00006617          	auipc	a2,0x6
ffffffffc0200b12:	f0260613          	addi	a2,a2,-254 # ffffffffc0206a10 <commands+0x2b0>
ffffffffc0200b16:	0f800593          	li	a1,248
ffffffffc0200b1a:	00006517          	auipc	a0,0x6
ffffffffc0200b1e:	0de50513          	addi	a0,a0,222 # ffffffffc0206bf8 <commands+0x498>
ffffffffc0200b22:	ef2ff0ef          	jal	ra,ffffffffc0200214 <__panic>
            cprintf("Instruction address misaligned\n");
ffffffffc0200b26:	00006517          	auipc	a0,0x6
ffffffffc0200b2a:	e4a50513          	addi	a0,a0,-438 # ffffffffc0206970 <commands+0x210>
ffffffffc0200b2e:	b741                	j	ffffffffc0200aae <exception_handler+0x50>
            cprintf("Instruction access fault\n");
ffffffffc0200b30:	00006517          	auipc	a0,0x6
ffffffffc0200b34:	e6050513          	addi	a0,a0,-416 # ffffffffc0206990 <commands+0x230>
ffffffffc0200b38:	bf9d                	j	ffffffffc0200aae <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc0200b3a:	00006517          	auipc	a0,0x6
ffffffffc0200b3e:	e7650513          	addi	a0,a0,-394 # ffffffffc02069b0 <commands+0x250>
ffffffffc0200b42:	b7b5                	j	ffffffffc0200aae <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc0200b44:	00006517          	auipc	a0,0x6
ffffffffc0200b48:	e8450513          	addi	a0,a0,-380 # ffffffffc02069c8 <commands+0x268>
ffffffffc0200b4c:	d84ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            if(tf->gpr.a7 == 10){
ffffffffc0200b50:	6458                	ld	a4,136(s0)
ffffffffc0200b52:	47a9                	li	a5,10
ffffffffc0200b54:	f8f719e3          	bne	a4,a5,ffffffffc0200ae6 <exception_handler+0x88>
                tf->epc += 4;
ffffffffc0200b58:	10843783          	ld	a5,264(s0)
ffffffffc0200b5c:	0791                	addi	a5,a5,4
ffffffffc0200b5e:	10f43423          	sd	a5,264(s0)
                syscall();
ffffffffc0200b62:	540050ef          	jal	ra,ffffffffc02060a2 <syscall>
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b66:	000ac797          	auipc	a5,0xac
ffffffffc0200b6a:	d2278793          	addi	a5,a5,-734 # ffffffffc02ac888 <current>
ffffffffc0200b6e:	639c                	ld	a5,0(a5)
ffffffffc0200b70:	8522                	mv	a0,s0
}
ffffffffc0200b72:	6442                	ld	s0,16(sp)
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b74:	6b9c                	ld	a5,16(a5)
}
ffffffffc0200b76:	60e2                	ld	ra,24(sp)
ffffffffc0200b78:	64a2                	ld	s1,8(sp)
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b7a:	6589                	lui	a1,0x2
ffffffffc0200b7c:	95be                	add	a1,a1,a5
}
ffffffffc0200b7e:	6105                	addi	sp,sp,32
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b80:	ac19                	j	ffffffffc0200d96 <kernel_execve_ret>
            cprintf("Load address misaligned\n");
ffffffffc0200b82:	00006517          	auipc	a0,0x6
ffffffffc0200b86:	e5650513          	addi	a0,a0,-426 # ffffffffc02069d8 <commands+0x278>
ffffffffc0200b8a:	b715                	j	ffffffffc0200aae <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc0200b8c:	00006517          	auipc	a0,0x6
ffffffffc0200b90:	e6c50513          	addi	a0,a0,-404 # ffffffffc02069f8 <commands+0x298>
ffffffffc0200b94:	d3cff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200b98:	8522                	mv	a0,s0
ffffffffc0200b9a:	d0bff0ef          	jal	ra,ffffffffc02008a4 <pgfault_handler>
ffffffffc0200b9e:	84aa                	mv	s1,a0
ffffffffc0200ba0:	d139                	beqz	a0,ffffffffc0200ae6 <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200ba2:	8522                	mv	a0,s0
ffffffffc0200ba4:	c9fff0ef          	jal	ra,ffffffffc0200842 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200ba8:	86a6                	mv	a3,s1
ffffffffc0200baa:	00006617          	auipc	a2,0x6
ffffffffc0200bae:	e6660613          	addi	a2,a2,-410 # ffffffffc0206a10 <commands+0x2b0>
ffffffffc0200bb2:	0cd00593          	li	a1,205
ffffffffc0200bb6:	00006517          	auipc	a0,0x6
ffffffffc0200bba:	04250513          	addi	a0,a0,66 # ffffffffc0206bf8 <commands+0x498>
ffffffffc0200bbe:	e56ff0ef          	jal	ra,ffffffffc0200214 <__panic>
            cprintf("Store/AMO access fault\n");
ffffffffc0200bc2:	00006517          	auipc	a0,0x6
ffffffffc0200bc6:	e8650513          	addi	a0,a0,-378 # ffffffffc0206a48 <commands+0x2e8>
ffffffffc0200bca:	d06ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200bce:	8522                	mv	a0,s0
ffffffffc0200bd0:	cd5ff0ef          	jal	ra,ffffffffc02008a4 <pgfault_handler>
ffffffffc0200bd4:	84aa                	mv	s1,a0
ffffffffc0200bd6:	f00508e3          	beqz	a0,ffffffffc0200ae6 <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200bda:	8522                	mv	a0,s0
ffffffffc0200bdc:	c67ff0ef          	jal	ra,ffffffffc0200842 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200be0:	86a6                	mv	a3,s1
ffffffffc0200be2:	00006617          	auipc	a2,0x6
ffffffffc0200be6:	e2e60613          	addi	a2,a2,-466 # ffffffffc0206a10 <commands+0x2b0>
ffffffffc0200bea:	0d700593          	li	a1,215
ffffffffc0200bee:	00006517          	auipc	a0,0x6
ffffffffc0200bf2:	00a50513          	addi	a0,a0,10 # ffffffffc0206bf8 <commands+0x498>
ffffffffc0200bf6:	e1eff0ef          	jal	ra,ffffffffc0200214 <__panic>
}
ffffffffc0200bfa:	6442                	ld	s0,16(sp)
ffffffffc0200bfc:	60e2                	ld	ra,24(sp)
ffffffffc0200bfe:	64a2                	ld	s1,8(sp)
ffffffffc0200c00:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc0200c02:	b181                	j	ffffffffc0200842 <print_trapframe>
            panic("AMO address misaligned\n");
ffffffffc0200c04:	00006617          	auipc	a2,0x6
ffffffffc0200c08:	e2c60613          	addi	a2,a2,-468 # ffffffffc0206a30 <commands+0x2d0>
ffffffffc0200c0c:	0d100593          	li	a1,209
ffffffffc0200c10:	00006517          	auipc	a0,0x6
ffffffffc0200c14:	fe850513          	addi	a0,a0,-24 # ffffffffc0206bf8 <commands+0x498>
ffffffffc0200c18:	dfcff0ef          	jal	ra,ffffffffc0200214 <__panic>
            print_trapframe(tf);
ffffffffc0200c1c:	b11d                	j	ffffffffc0200842 <print_trapframe>
                print_trapframe(tf);
ffffffffc0200c1e:	8522                	mv	a0,s0
ffffffffc0200c20:	c23ff0ef          	jal	ra,ffffffffc0200842 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200c24:	86a6                	mv	a3,s1
ffffffffc0200c26:	00006617          	auipc	a2,0x6
ffffffffc0200c2a:	dea60613          	addi	a2,a2,-534 # ffffffffc0206a10 <commands+0x2b0>
ffffffffc0200c2e:	0f100593          	li	a1,241
ffffffffc0200c32:	00006517          	auipc	a0,0x6
ffffffffc0200c36:	fc650513          	addi	a0,a0,-58 # ffffffffc0206bf8 <commands+0x498>
ffffffffc0200c3a:	ddaff0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0200c3e <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
ffffffffc0200c3e:	1101                	addi	sp,sp,-32
ffffffffc0200c40:	e822                	sd	s0,16(sp)
    // dispatch based on what type of trap occurred
//    cputs("some trap");
    if (current == NULL) {
ffffffffc0200c42:	000ac417          	auipc	s0,0xac
ffffffffc0200c46:	c4640413          	addi	s0,s0,-954 # ffffffffc02ac888 <current>
ffffffffc0200c4a:	6018                	ld	a4,0(s0)
trap(struct trapframe *tf) {
ffffffffc0200c4c:	ec06                	sd	ra,24(sp)
ffffffffc0200c4e:	e426                	sd	s1,8(sp)
ffffffffc0200c50:	e04a                	sd	s2,0(sp)
ffffffffc0200c52:	11853683          	ld	a3,280(a0)
    if (current == NULL) {
ffffffffc0200c56:	cf1d                	beqz	a4,ffffffffc0200c94 <trap+0x56>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c58:	10053483          	ld	s1,256(a0)
        trap_dispatch(tf);
    } else {
        struct trapframe *otf = current->tf;
ffffffffc0200c5c:	0a073903          	ld	s2,160(a4)
        current->tf = tf;
ffffffffc0200c60:	f348                	sd	a0,160(a4)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c62:	1004f493          	andi	s1,s1,256
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c66:	0206c463          	bltz	a3,ffffffffc0200c8e <trap+0x50>
        exception_handler(tf);
ffffffffc0200c6a:	df5ff0ef          	jal	ra,ffffffffc0200a5e <exception_handler>

        bool in_kernel = trap_in_kernel(tf);

        trap_dispatch(tf);

        current->tf = otf;
ffffffffc0200c6e:	601c                	ld	a5,0(s0)
ffffffffc0200c70:	0b27b023          	sd	s2,160(a5)
        if (!in_kernel) {
ffffffffc0200c74:	e499                	bnez	s1,ffffffffc0200c82 <trap+0x44>
            if (current->flags & PF_EXITING) {
ffffffffc0200c76:	0b07a703          	lw	a4,176(a5)
ffffffffc0200c7a:	8b05                	andi	a4,a4,1
ffffffffc0200c7c:	e329                	bnez	a4,ffffffffc0200cbe <trap+0x80>
                do_exit(-E_KILLED);
            }
            if (current->need_resched) {
ffffffffc0200c7e:	6f9c                	ld	a5,24(a5)
ffffffffc0200c80:	eb85                	bnez	a5,ffffffffc0200cb0 <trap+0x72>
                schedule();
            }
        }
    }
}
ffffffffc0200c82:	60e2                	ld	ra,24(sp)
ffffffffc0200c84:	6442                	ld	s0,16(sp)
ffffffffc0200c86:	64a2                	ld	s1,8(sp)
ffffffffc0200c88:	6902                	ld	s2,0(sp)
ffffffffc0200c8a:	6105                	addi	sp,sp,32
ffffffffc0200c8c:	8082                	ret
        interrupt_handler(tf);
ffffffffc0200c8e:	d37ff0ef          	jal	ra,ffffffffc02009c4 <interrupt_handler>
ffffffffc0200c92:	bff1                	j	ffffffffc0200c6e <trap+0x30>
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c94:	0006c863          	bltz	a3,ffffffffc0200ca4 <trap+0x66>
}
ffffffffc0200c98:	6442                	ld	s0,16(sp)
ffffffffc0200c9a:	60e2                	ld	ra,24(sp)
ffffffffc0200c9c:	64a2                	ld	s1,8(sp)
ffffffffc0200c9e:	6902                	ld	s2,0(sp)
ffffffffc0200ca0:	6105                	addi	sp,sp,32
        exception_handler(tf);
ffffffffc0200ca2:	bb75                	j	ffffffffc0200a5e <exception_handler>
}
ffffffffc0200ca4:	6442                	ld	s0,16(sp)
ffffffffc0200ca6:	60e2                	ld	ra,24(sp)
ffffffffc0200ca8:	64a2                	ld	s1,8(sp)
ffffffffc0200caa:	6902                	ld	s2,0(sp)
ffffffffc0200cac:	6105                	addi	sp,sp,32
        interrupt_handler(tf);
ffffffffc0200cae:	bb19                	j	ffffffffc02009c4 <interrupt_handler>
}
ffffffffc0200cb0:	6442                	ld	s0,16(sp)
ffffffffc0200cb2:	60e2                	ld	ra,24(sp)
ffffffffc0200cb4:	64a2                	ld	s1,8(sp)
ffffffffc0200cb6:	6902                	ld	s2,0(sp)
ffffffffc0200cb8:	6105                	addi	sp,sp,32
                schedule();
ffffffffc0200cba:	2f20506f          	j	ffffffffc0205fac <schedule>
                do_exit(-E_KILLED);
ffffffffc0200cbe:	555d                	li	a0,-9
ffffffffc0200cc0:	754040ef          	jal	ra,ffffffffc0205414 <do_exit>
ffffffffc0200cc4:	601c                	ld	a5,0(s0)
ffffffffc0200cc6:	bf65                	j	ffffffffc0200c7e <trap+0x40>

ffffffffc0200cc8 <__alltraps>:
    LOAD x2, 2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200cc8:	14011173          	csrrw	sp,sscratch,sp
ffffffffc0200ccc:	00011463          	bnez	sp,ffffffffc0200cd4 <__alltraps+0xc>
ffffffffc0200cd0:	14002173          	csrr	sp,sscratch
ffffffffc0200cd4:	712d                	addi	sp,sp,-288
ffffffffc0200cd6:	e002                	sd	zero,0(sp)
ffffffffc0200cd8:	e406                	sd	ra,8(sp)
ffffffffc0200cda:	ec0e                	sd	gp,24(sp)
ffffffffc0200cdc:	f012                	sd	tp,32(sp)
ffffffffc0200cde:	f416                	sd	t0,40(sp)
ffffffffc0200ce0:	f81a                	sd	t1,48(sp)
ffffffffc0200ce2:	fc1e                	sd	t2,56(sp)
ffffffffc0200ce4:	e0a2                	sd	s0,64(sp)
ffffffffc0200ce6:	e4a6                	sd	s1,72(sp)
ffffffffc0200ce8:	e8aa                	sd	a0,80(sp)
ffffffffc0200cea:	ecae                	sd	a1,88(sp)
ffffffffc0200cec:	f0b2                	sd	a2,96(sp)
ffffffffc0200cee:	f4b6                	sd	a3,104(sp)
ffffffffc0200cf0:	f8ba                	sd	a4,112(sp)
ffffffffc0200cf2:	fcbe                	sd	a5,120(sp)
ffffffffc0200cf4:	e142                	sd	a6,128(sp)
ffffffffc0200cf6:	e546                	sd	a7,136(sp)
ffffffffc0200cf8:	e94a                	sd	s2,144(sp)
ffffffffc0200cfa:	ed4e                	sd	s3,152(sp)
ffffffffc0200cfc:	f152                	sd	s4,160(sp)
ffffffffc0200cfe:	f556                	sd	s5,168(sp)
ffffffffc0200d00:	f95a                	sd	s6,176(sp)
ffffffffc0200d02:	fd5e                	sd	s7,184(sp)
ffffffffc0200d04:	e1e2                	sd	s8,192(sp)
ffffffffc0200d06:	e5e6                	sd	s9,200(sp)
ffffffffc0200d08:	e9ea                	sd	s10,208(sp)
ffffffffc0200d0a:	edee                	sd	s11,216(sp)
ffffffffc0200d0c:	f1f2                	sd	t3,224(sp)
ffffffffc0200d0e:	f5f6                	sd	t4,232(sp)
ffffffffc0200d10:	f9fa                	sd	t5,240(sp)
ffffffffc0200d12:	fdfe                	sd	t6,248(sp)
ffffffffc0200d14:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200d18:	100024f3          	csrr	s1,sstatus
ffffffffc0200d1c:	14102973          	csrr	s2,sepc
ffffffffc0200d20:	143029f3          	csrr	s3,stval
ffffffffc0200d24:	14202a73          	csrr	s4,scause
ffffffffc0200d28:	e822                	sd	s0,16(sp)
ffffffffc0200d2a:	e226                	sd	s1,256(sp)
ffffffffc0200d2c:	e64a                	sd	s2,264(sp)
ffffffffc0200d2e:	ea4e                	sd	s3,272(sp)
ffffffffc0200d30:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200d32:	850a                	mv	a0,sp
    jal trap
ffffffffc0200d34:	f0bff0ef          	jal	ra,ffffffffc0200c3e <trap>

ffffffffc0200d38 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200d38:	6492                	ld	s1,256(sp)
ffffffffc0200d3a:	6932                	ld	s2,264(sp)
ffffffffc0200d3c:	1004f413          	andi	s0,s1,256
ffffffffc0200d40:	e401                	bnez	s0,ffffffffc0200d48 <__trapret+0x10>
ffffffffc0200d42:	1200                	addi	s0,sp,288
ffffffffc0200d44:	14041073          	csrw	sscratch,s0
ffffffffc0200d48:	10049073          	csrw	sstatus,s1
ffffffffc0200d4c:	14191073          	csrw	sepc,s2
ffffffffc0200d50:	60a2                	ld	ra,8(sp)
ffffffffc0200d52:	61e2                	ld	gp,24(sp)
ffffffffc0200d54:	7202                	ld	tp,32(sp)
ffffffffc0200d56:	72a2                	ld	t0,40(sp)
ffffffffc0200d58:	7342                	ld	t1,48(sp)
ffffffffc0200d5a:	73e2                	ld	t2,56(sp)
ffffffffc0200d5c:	6406                	ld	s0,64(sp)
ffffffffc0200d5e:	64a6                	ld	s1,72(sp)
ffffffffc0200d60:	6546                	ld	a0,80(sp)
ffffffffc0200d62:	65e6                	ld	a1,88(sp)
ffffffffc0200d64:	7606                	ld	a2,96(sp)
ffffffffc0200d66:	76a6                	ld	a3,104(sp)
ffffffffc0200d68:	7746                	ld	a4,112(sp)
ffffffffc0200d6a:	77e6                	ld	a5,120(sp)
ffffffffc0200d6c:	680a                	ld	a6,128(sp)
ffffffffc0200d6e:	68aa                	ld	a7,136(sp)
ffffffffc0200d70:	694a                	ld	s2,144(sp)
ffffffffc0200d72:	69ea                	ld	s3,152(sp)
ffffffffc0200d74:	7a0a                	ld	s4,160(sp)
ffffffffc0200d76:	7aaa                	ld	s5,168(sp)
ffffffffc0200d78:	7b4a                	ld	s6,176(sp)
ffffffffc0200d7a:	7bea                	ld	s7,184(sp)
ffffffffc0200d7c:	6c0e                	ld	s8,192(sp)
ffffffffc0200d7e:	6cae                	ld	s9,200(sp)
ffffffffc0200d80:	6d4e                	ld	s10,208(sp)
ffffffffc0200d82:	6dee                	ld	s11,216(sp)
ffffffffc0200d84:	7e0e                	ld	t3,224(sp)
ffffffffc0200d86:	7eae                	ld	t4,232(sp)
ffffffffc0200d88:	7f4e                	ld	t5,240(sp)
ffffffffc0200d8a:	7fee                	ld	t6,248(sp)
ffffffffc0200d8c:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200d8e:	10200073          	sret

ffffffffc0200d92 <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200d92:	812a                	mv	sp,a0
    j __trapret
ffffffffc0200d94:	b755                	j	ffffffffc0200d38 <__trapret>

ffffffffc0200d96 <kernel_execve_ret>:

    .global kernel_execve_ret
kernel_execve_ret:
    // adjust sp to beneath kstacktop of current process
    addi a1, a1, -36*REGBYTES
ffffffffc0200d96:	ee058593          	addi	a1,a1,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x76e8>

    // copy from previous trapframe to new trapframe
    LOAD s1, 35*REGBYTES(a0)
ffffffffc0200d9a:	11853483          	ld	s1,280(a0)
    STORE s1, 35*REGBYTES(a1)
ffffffffc0200d9e:	1095bc23          	sd	s1,280(a1)
    LOAD s1, 34*REGBYTES(a0)
ffffffffc0200da2:	11053483          	ld	s1,272(a0)
    STORE s1, 34*REGBYTES(a1)
ffffffffc0200da6:	1095b823          	sd	s1,272(a1)
    LOAD s1, 33*REGBYTES(a0)
ffffffffc0200daa:	10853483          	ld	s1,264(a0)
    STORE s1, 33*REGBYTES(a1)
ffffffffc0200dae:	1095b423          	sd	s1,264(a1)
    LOAD s1, 32*REGBYTES(a0)
ffffffffc0200db2:	10053483          	ld	s1,256(a0)
    STORE s1, 32*REGBYTES(a1)
ffffffffc0200db6:	1095b023          	sd	s1,256(a1)
    LOAD s1, 31*REGBYTES(a0)
ffffffffc0200dba:	7d64                	ld	s1,248(a0)
    STORE s1, 31*REGBYTES(a1)
ffffffffc0200dbc:	fde4                	sd	s1,248(a1)
    LOAD s1, 30*REGBYTES(a0)
ffffffffc0200dbe:	7964                	ld	s1,240(a0)
    STORE s1, 30*REGBYTES(a1)
ffffffffc0200dc0:	f9e4                	sd	s1,240(a1)
    LOAD s1, 29*REGBYTES(a0)
ffffffffc0200dc2:	7564                	ld	s1,232(a0)
    STORE s1, 29*REGBYTES(a1)
ffffffffc0200dc4:	f5e4                	sd	s1,232(a1)
    LOAD s1, 28*REGBYTES(a0)
ffffffffc0200dc6:	7164                	ld	s1,224(a0)
    STORE s1, 28*REGBYTES(a1)
ffffffffc0200dc8:	f1e4                	sd	s1,224(a1)
    LOAD s1, 27*REGBYTES(a0)
ffffffffc0200dca:	6d64                	ld	s1,216(a0)
    STORE s1, 27*REGBYTES(a1)
ffffffffc0200dcc:	ede4                	sd	s1,216(a1)
    LOAD s1, 26*REGBYTES(a0)
ffffffffc0200dce:	6964                	ld	s1,208(a0)
    STORE s1, 26*REGBYTES(a1)
ffffffffc0200dd0:	e9e4                	sd	s1,208(a1)
    LOAD s1, 25*REGBYTES(a0)
ffffffffc0200dd2:	6564                	ld	s1,200(a0)
    STORE s1, 25*REGBYTES(a1)
ffffffffc0200dd4:	e5e4                	sd	s1,200(a1)
    LOAD s1, 24*REGBYTES(a0)
ffffffffc0200dd6:	6164                	ld	s1,192(a0)
    STORE s1, 24*REGBYTES(a1)
ffffffffc0200dd8:	e1e4                	sd	s1,192(a1)
    LOAD s1, 23*REGBYTES(a0)
ffffffffc0200dda:	7d44                	ld	s1,184(a0)
    STORE s1, 23*REGBYTES(a1)
ffffffffc0200ddc:	fdc4                	sd	s1,184(a1)
    LOAD s1, 22*REGBYTES(a0)
ffffffffc0200dde:	7944                	ld	s1,176(a0)
    STORE s1, 22*REGBYTES(a1)
ffffffffc0200de0:	f9c4                	sd	s1,176(a1)
    LOAD s1, 21*REGBYTES(a0)
ffffffffc0200de2:	7544                	ld	s1,168(a0)
    STORE s1, 21*REGBYTES(a1)
ffffffffc0200de4:	f5c4                	sd	s1,168(a1)
    LOAD s1, 20*REGBYTES(a0)
ffffffffc0200de6:	7144                	ld	s1,160(a0)
    STORE s1, 20*REGBYTES(a1)
ffffffffc0200de8:	f1c4                	sd	s1,160(a1)
    LOAD s1, 19*REGBYTES(a0)
ffffffffc0200dea:	6d44                	ld	s1,152(a0)
    STORE s1, 19*REGBYTES(a1)
ffffffffc0200dec:	edc4                	sd	s1,152(a1)
    LOAD s1, 18*REGBYTES(a0)
ffffffffc0200dee:	6944                	ld	s1,144(a0)
    STORE s1, 18*REGBYTES(a1)
ffffffffc0200df0:	e9c4                	sd	s1,144(a1)
    LOAD s1, 17*REGBYTES(a0)
ffffffffc0200df2:	6544                	ld	s1,136(a0)
    STORE s1, 17*REGBYTES(a1)
ffffffffc0200df4:	e5c4                	sd	s1,136(a1)
    LOAD s1, 16*REGBYTES(a0)
ffffffffc0200df6:	6144                	ld	s1,128(a0)
    STORE s1, 16*REGBYTES(a1)
ffffffffc0200df8:	e1c4                	sd	s1,128(a1)
    LOAD s1, 15*REGBYTES(a0)
ffffffffc0200dfa:	7d24                	ld	s1,120(a0)
    STORE s1, 15*REGBYTES(a1)
ffffffffc0200dfc:	fda4                	sd	s1,120(a1)
    LOAD s1, 14*REGBYTES(a0)
ffffffffc0200dfe:	7924                	ld	s1,112(a0)
    STORE s1, 14*REGBYTES(a1)
ffffffffc0200e00:	f9a4                	sd	s1,112(a1)
    LOAD s1, 13*REGBYTES(a0)
ffffffffc0200e02:	7524                	ld	s1,104(a0)
    STORE s1, 13*REGBYTES(a1)
ffffffffc0200e04:	f5a4                	sd	s1,104(a1)
    LOAD s1, 12*REGBYTES(a0)
ffffffffc0200e06:	7124                	ld	s1,96(a0)
    STORE s1, 12*REGBYTES(a1)
ffffffffc0200e08:	f1a4                	sd	s1,96(a1)
    LOAD s1, 11*REGBYTES(a0)
ffffffffc0200e0a:	6d24                	ld	s1,88(a0)
    STORE s1, 11*REGBYTES(a1)
ffffffffc0200e0c:	eda4                	sd	s1,88(a1)
    LOAD s1, 10*REGBYTES(a0)
ffffffffc0200e0e:	6924                	ld	s1,80(a0)
    STORE s1, 10*REGBYTES(a1)
ffffffffc0200e10:	e9a4                	sd	s1,80(a1)
    LOAD s1, 9*REGBYTES(a0)
ffffffffc0200e12:	6524                	ld	s1,72(a0)
    STORE s1, 9*REGBYTES(a1)
ffffffffc0200e14:	e5a4                	sd	s1,72(a1)
    LOAD s1, 8*REGBYTES(a0)
ffffffffc0200e16:	6124                	ld	s1,64(a0)
    STORE s1, 8*REGBYTES(a1)
ffffffffc0200e18:	e1a4                	sd	s1,64(a1)
    LOAD s1, 7*REGBYTES(a0)
ffffffffc0200e1a:	7d04                	ld	s1,56(a0)
    STORE s1, 7*REGBYTES(a1)
ffffffffc0200e1c:	fd84                	sd	s1,56(a1)
    LOAD s1, 6*REGBYTES(a0)
ffffffffc0200e1e:	7904                	ld	s1,48(a0)
    STORE s1, 6*REGBYTES(a1)
ffffffffc0200e20:	f984                	sd	s1,48(a1)
    LOAD s1, 5*REGBYTES(a0)
ffffffffc0200e22:	7504                	ld	s1,40(a0)
    STORE s1, 5*REGBYTES(a1)
ffffffffc0200e24:	f584                	sd	s1,40(a1)
    LOAD s1, 4*REGBYTES(a0)
ffffffffc0200e26:	7104                	ld	s1,32(a0)
    STORE s1, 4*REGBYTES(a1)
ffffffffc0200e28:	f184                	sd	s1,32(a1)
    LOAD s1, 3*REGBYTES(a0)
ffffffffc0200e2a:	6d04                	ld	s1,24(a0)
    STORE s1, 3*REGBYTES(a1)
ffffffffc0200e2c:	ed84                	sd	s1,24(a1)
    LOAD s1, 2*REGBYTES(a0)
ffffffffc0200e2e:	6904                	ld	s1,16(a0)
    STORE s1, 2*REGBYTES(a1)
ffffffffc0200e30:	e984                	sd	s1,16(a1)
    LOAD s1, 1*REGBYTES(a0)
ffffffffc0200e32:	6504                	ld	s1,8(a0)
    STORE s1, 1*REGBYTES(a1)
ffffffffc0200e34:	e584                	sd	s1,8(a1)
    LOAD s1, 0*REGBYTES(a0)
ffffffffc0200e36:	6104                	ld	s1,0(a0)
    STORE s1, 0*REGBYTES(a1)
ffffffffc0200e38:	e184                	sd	s1,0(a1)

    // acutually adjust sp
    move sp, a1
ffffffffc0200e3a:	812e                	mv	sp,a1
ffffffffc0200e3c:	bdf5                	j	ffffffffc0200d38 <__trapret>

ffffffffc0200e3e <pa2page.part.4>:
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
}

static inline struct Page *
pa2page(uintptr_t pa) {
ffffffffc0200e3e:	1141                	addi	sp,sp,-16
    if (PPN(pa) >= npage) {
        panic("pa2page called with invalid pa");
ffffffffc0200e40:	00006617          	auipc	a2,0x6
ffffffffc0200e44:	1c060613          	addi	a2,a2,448 # ffffffffc0207000 <commands+0x8a0>
ffffffffc0200e48:	06200593          	li	a1,98
ffffffffc0200e4c:	00006517          	auipc	a0,0x6
ffffffffc0200e50:	1d450513          	addi	a0,a0,468 # ffffffffc0207020 <commands+0x8c0>
pa2page(uintptr_t pa) {
ffffffffc0200e54:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0200e56:	bbeff0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0200e5a <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc0200e5a:	715d                	addi	sp,sp,-80
ffffffffc0200e5c:	e0a2                	sd	s0,64(sp)
ffffffffc0200e5e:	fc26                	sd	s1,56(sp)
ffffffffc0200e60:	f84a                	sd	s2,48(sp)
ffffffffc0200e62:	f44e                	sd	s3,40(sp)
ffffffffc0200e64:	f052                	sd	s4,32(sp)
ffffffffc0200e66:	ec56                	sd	s5,24(sp)
ffffffffc0200e68:	e486                	sd	ra,72(sp)
ffffffffc0200e6a:	842a                	mv	s0,a0
ffffffffc0200e6c:	000ac497          	auipc	s1,0xac
ffffffffc0200e70:	a4448493          	addi	s1,s1,-1468 # ffffffffc02ac8b0 <pmm_manager>
        {
            page = pmm_manager->alloc_pages(n);
        }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0200e74:	4985                	li	s3,1
ffffffffc0200e76:	000aca17          	auipc	s4,0xac
ffffffffc0200e7a:	a02a0a13          	addi	s4,s4,-1534 # ffffffffc02ac878 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0200e7e:	0005091b          	sext.w	s2,a0
ffffffffc0200e82:	000aca97          	auipc	s5,0xac
ffffffffc0200e86:	a4ea8a93          	addi	s5,s5,-1458 # ffffffffc02ac8d0 <check_mm_struct>
ffffffffc0200e8a:	a00d                	j	ffffffffc0200eac <alloc_pages+0x52>
            page = pmm_manager->alloc_pages(n);
ffffffffc0200e8c:	609c                	ld	a5,0(s1)
ffffffffc0200e8e:	6f9c                	ld	a5,24(a5)
ffffffffc0200e90:	9782                	jalr	a5
        swap_out(check_mm_struct, n, 0);
ffffffffc0200e92:	4601                	li	a2,0
ffffffffc0200e94:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0200e96:	ed0d                	bnez	a0,ffffffffc0200ed0 <alloc_pages+0x76>
ffffffffc0200e98:	0289ec63          	bltu	s3,s0,ffffffffc0200ed0 <alloc_pages+0x76>
ffffffffc0200e9c:	000a2783          	lw	a5,0(s4)
ffffffffc0200ea0:	2781                	sext.w	a5,a5
ffffffffc0200ea2:	c79d                	beqz	a5,ffffffffc0200ed0 <alloc_pages+0x76>
        swap_out(check_mm_struct, n, 0);
ffffffffc0200ea4:	000ab503          	ld	a0,0(s5)
ffffffffc0200ea8:	720020ef          	jal	ra,ffffffffc02035c8 <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200eac:	100027f3          	csrr	a5,sstatus
ffffffffc0200eb0:	8b89                	andi	a5,a5,2
            page = pmm_manager->alloc_pages(n);
ffffffffc0200eb2:	8522                	mv	a0,s0
ffffffffc0200eb4:	dfe1                	beqz	a5,ffffffffc0200e8c <alloc_pages+0x32>
        intr_disable();
ffffffffc0200eb6:	f9eff0ef          	jal	ra,ffffffffc0200654 <intr_disable>
ffffffffc0200eba:	609c                	ld	a5,0(s1)
ffffffffc0200ebc:	8522                	mv	a0,s0
ffffffffc0200ebe:	6f9c                	ld	a5,24(a5)
ffffffffc0200ec0:	9782                	jalr	a5
ffffffffc0200ec2:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0200ec4:	f8aff0ef          	jal	ra,ffffffffc020064e <intr_enable>
ffffffffc0200ec8:	6522                	ld	a0,8(sp)
        swap_out(check_mm_struct, n, 0);
ffffffffc0200eca:	4601                	li	a2,0
ffffffffc0200ecc:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0200ece:	d569                	beqz	a0,ffffffffc0200e98 <alloc_pages+0x3e>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0200ed0:	60a6                	ld	ra,72(sp)
ffffffffc0200ed2:	6406                	ld	s0,64(sp)
ffffffffc0200ed4:	74e2                	ld	s1,56(sp)
ffffffffc0200ed6:	7942                	ld	s2,48(sp)
ffffffffc0200ed8:	79a2                	ld	s3,40(sp)
ffffffffc0200eda:	7a02                	ld	s4,32(sp)
ffffffffc0200edc:	6ae2                	ld	s5,24(sp)
ffffffffc0200ede:	6161                	addi	sp,sp,80
ffffffffc0200ee0:	8082                	ret

ffffffffc0200ee2 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200ee2:	100027f3          	csrr	a5,sstatus
ffffffffc0200ee6:	8b89                	andi	a5,a5,2
ffffffffc0200ee8:	eb89                	bnez	a5,ffffffffc0200efa <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0200eea:	000ac797          	auipc	a5,0xac
ffffffffc0200eee:	9c678793          	addi	a5,a5,-1594 # ffffffffc02ac8b0 <pmm_manager>
ffffffffc0200ef2:	639c                	ld	a5,0(a5)
ffffffffc0200ef4:	0207b303          	ld	t1,32(a5)
ffffffffc0200ef8:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc0200efa:	1101                	addi	sp,sp,-32
ffffffffc0200efc:	ec06                	sd	ra,24(sp)
ffffffffc0200efe:	e822                	sd	s0,16(sp)
ffffffffc0200f00:	e426                	sd	s1,8(sp)
ffffffffc0200f02:	842a                	mv	s0,a0
ffffffffc0200f04:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0200f06:	f4eff0ef          	jal	ra,ffffffffc0200654 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0200f0a:	000ac797          	auipc	a5,0xac
ffffffffc0200f0e:	9a678793          	addi	a5,a5,-1626 # ffffffffc02ac8b0 <pmm_manager>
ffffffffc0200f12:	639c                	ld	a5,0(a5)
ffffffffc0200f14:	85a6                	mv	a1,s1
ffffffffc0200f16:	8522                	mv	a0,s0
ffffffffc0200f18:	739c                	ld	a5,32(a5)
ffffffffc0200f1a:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200f1c:	6442                	ld	s0,16(sp)
ffffffffc0200f1e:	60e2                	ld	ra,24(sp)
ffffffffc0200f20:	64a2                	ld	s1,8(sp)
ffffffffc0200f22:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200f24:	f2aff06f          	j	ffffffffc020064e <intr_enable>

ffffffffc0200f28 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200f28:	100027f3          	csrr	a5,sstatus
ffffffffc0200f2c:	8b89                	andi	a5,a5,2
ffffffffc0200f2e:	eb89                	bnez	a5,ffffffffc0200f40 <nr_free_pages+0x18>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0200f30:	000ac797          	auipc	a5,0xac
ffffffffc0200f34:	98078793          	addi	a5,a5,-1664 # ffffffffc02ac8b0 <pmm_manager>
ffffffffc0200f38:	639c                	ld	a5,0(a5)
ffffffffc0200f3a:	0287b303          	ld	t1,40(a5)
ffffffffc0200f3e:	8302                	jr	t1
size_t nr_free_pages(void) {
ffffffffc0200f40:	1141                	addi	sp,sp,-16
ffffffffc0200f42:	e406                	sd	ra,8(sp)
ffffffffc0200f44:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0200f46:	f0eff0ef          	jal	ra,ffffffffc0200654 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0200f4a:	000ac797          	auipc	a5,0xac
ffffffffc0200f4e:	96678793          	addi	a5,a5,-1690 # ffffffffc02ac8b0 <pmm_manager>
ffffffffc0200f52:	639c                	ld	a5,0(a5)
ffffffffc0200f54:	779c                	ld	a5,40(a5)
ffffffffc0200f56:	9782                	jalr	a5
ffffffffc0200f58:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0200f5a:	ef4ff0ef          	jal	ra,ffffffffc020064e <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0200f5e:	8522                	mv	a0,s0
ffffffffc0200f60:	60a2                	ld	ra,8(sp)
ffffffffc0200f62:	6402                	ld	s0,0(sp)
ffffffffc0200f64:	0141                	addi	sp,sp,16
ffffffffc0200f66:	8082                	ret

ffffffffc0200f68 <get_pte>:
// parameter:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0200f68:	7139                	addi	sp,sp,-64
ffffffffc0200f6a:	f426                	sd	s1,40(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0200f6c:	01e5d493          	srli	s1,a1,0x1e
ffffffffc0200f70:	1ff4f493          	andi	s1,s1,511
ffffffffc0200f74:	048e                	slli	s1,s1,0x3
ffffffffc0200f76:	94aa                	add	s1,s1,a0
    if (!(*pdep1 & PTE_V)) {
ffffffffc0200f78:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0200f7a:	f04a                	sd	s2,32(sp)
ffffffffc0200f7c:	ec4e                	sd	s3,24(sp)
ffffffffc0200f7e:	e852                	sd	s4,16(sp)
ffffffffc0200f80:	fc06                	sd	ra,56(sp)
ffffffffc0200f82:	f822                	sd	s0,48(sp)
ffffffffc0200f84:	e456                	sd	s5,8(sp)
ffffffffc0200f86:	e05a                	sd	s6,0(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc0200f88:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0200f8c:	892e                	mv	s2,a1
ffffffffc0200f8e:	8a32                	mv	s4,a2
ffffffffc0200f90:	000ac997          	auipc	s3,0xac
ffffffffc0200f94:	8d098993          	addi	s3,s3,-1840 # ffffffffc02ac860 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0200f98:	e7bd                	bnez	a5,ffffffffc0201006 <get_pte+0x9e>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0200f9a:	12060c63          	beqz	a2,ffffffffc02010d2 <get_pte+0x16a>
ffffffffc0200f9e:	4505                	li	a0,1
ffffffffc0200fa0:	ebbff0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0200fa4:	842a                	mv	s0,a0
ffffffffc0200fa6:	12050663          	beqz	a0,ffffffffc02010d2 <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0200faa:	000acb17          	auipc	s6,0xac
ffffffffc0200fae:	91eb0b13          	addi	s6,s6,-1762 # ffffffffc02ac8c8 <pages>
ffffffffc0200fb2:	000b3503          	ld	a0,0(s6)
ffffffffc0200fb6:	00080ab7          	lui	s5,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0200fba:	000ac997          	auipc	s3,0xac
ffffffffc0200fbe:	8a698993          	addi	s3,s3,-1882 # ffffffffc02ac860 <npage>
ffffffffc0200fc2:	40a40533          	sub	a0,s0,a0
ffffffffc0200fc6:	8519                	srai	a0,a0,0x6
ffffffffc0200fc8:	9556                	add	a0,a0,s5
ffffffffc0200fca:	0009b703          	ld	a4,0(s3)
ffffffffc0200fce:	00c51793          	slli	a5,a0,0xc
    return page->ref;
}

static inline void
set_page_ref(struct Page *page, int val) {
    page->ref = val;
ffffffffc0200fd2:	4685                	li	a3,1
ffffffffc0200fd4:	c014                	sw	a3,0(s0)
ffffffffc0200fd6:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0200fd8:	0532                	slli	a0,a0,0xc
ffffffffc0200fda:	14e7f363          	bgeu	a5,a4,ffffffffc0201120 <get_pte+0x1b8>
ffffffffc0200fde:	000ac797          	auipc	a5,0xac
ffffffffc0200fe2:	8da78793          	addi	a5,a5,-1830 # ffffffffc02ac8b8 <va_pa_offset>
ffffffffc0200fe6:	639c                	ld	a5,0(a5)
ffffffffc0200fe8:	6605                	lui	a2,0x1
ffffffffc0200fea:	4581                	li	a1,0
ffffffffc0200fec:	953e                	add	a0,a0,a5
ffffffffc0200fee:	1d2050ef          	jal	ra,ffffffffc02061c0 <memset>
    return page - pages + nbase;
ffffffffc0200ff2:	000b3683          	ld	a3,0(s6)
ffffffffc0200ff6:	40d406b3          	sub	a3,s0,a3
ffffffffc0200ffa:	8699                	srai	a3,a3,0x6
ffffffffc0200ffc:	96d6                	add	a3,a3,s5
  asm volatile("sfence.vma");
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0200ffe:	06aa                	slli	a3,a3,0xa
ffffffffc0201000:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201004:	e094                	sd	a3,0(s1)
    }

    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201006:	77fd                	lui	a5,0xfffff
ffffffffc0201008:	068a                	slli	a3,a3,0x2
ffffffffc020100a:	0009b703          	ld	a4,0(s3)
ffffffffc020100e:	8efd                	and	a3,a3,a5
ffffffffc0201010:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201014:	0ce7f163          	bgeu	a5,a4,ffffffffc02010d6 <get_pte+0x16e>
ffffffffc0201018:	000aca97          	auipc	s5,0xac
ffffffffc020101c:	8a0a8a93          	addi	s5,s5,-1888 # ffffffffc02ac8b8 <va_pa_offset>
ffffffffc0201020:	000ab403          	ld	s0,0(s5)
ffffffffc0201024:	01595793          	srli	a5,s2,0x15
ffffffffc0201028:	1ff7f793          	andi	a5,a5,511
ffffffffc020102c:	96a2                	add	a3,a3,s0
ffffffffc020102e:	00379413          	slli	s0,a5,0x3
ffffffffc0201032:	9436                	add	s0,s0,a3
    if (!(*pdep0 & PTE_V)) {
ffffffffc0201034:	6014                	ld	a3,0(s0)
ffffffffc0201036:	0016f793          	andi	a5,a3,1
ffffffffc020103a:	e3ad                	bnez	a5,ffffffffc020109c <get_pte+0x134>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc020103c:	080a0b63          	beqz	s4,ffffffffc02010d2 <get_pte+0x16a>
ffffffffc0201040:	4505                	li	a0,1
ffffffffc0201042:	e19ff0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0201046:	84aa                	mv	s1,a0
ffffffffc0201048:	c549                	beqz	a0,ffffffffc02010d2 <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc020104a:	000acb17          	auipc	s6,0xac
ffffffffc020104e:	87eb0b13          	addi	s6,s6,-1922 # ffffffffc02ac8c8 <pages>
ffffffffc0201052:	000b3503          	ld	a0,0(s6)
ffffffffc0201056:	00080a37          	lui	s4,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc020105a:	0009b703          	ld	a4,0(s3)
ffffffffc020105e:	40a48533          	sub	a0,s1,a0
ffffffffc0201062:	8519                	srai	a0,a0,0x6
ffffffffc0201064:	9552                	add	a0,a0,s4
ffffffffc0201066:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc020106a:	4685                	li	a3,1
ffffffffc020106c:	c094                	sw	a3,0(s1)
ffffffffc020106e:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201070:	0532                	slli	a0,a0,0xc
ffffffffc0201072:	08e7fa63          	bgeu	a5,a4,ffffffffc0201106 <get_pte+0x19e>
ffffffffc0201076:	000ab783          	ld	a5,0(s5)
ffffffffc020107a:	6605                	lui	a2,0x1
ffffffffc020107c:	4581                	li	a1,0
ffffffffc020107e:	953e                	add	a0,a0,a5
ffffffffc0201080:	140050ef          	jal	ra,ffffffffc02061c0 <memset>
    return page - pages + nbase;
ffffffffc0201084:	000b3683          	ld	a3,0(s6)
ffffffffc0201088:	40d486b3          	sub	a3,s1,a3
ffffffffc020108c:	8699                	srai	a3,a3,0x6
ffffffffc020108e:	96d2                	add	a3,a3,s4
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201090:	06aa                	slli	a3,a3,0xa
ffffffffc0201092:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201096:	e014                	sd	a3,0(s0)
ffffffffc0201098:	0009b703          	ld	a4,0(s3)
        }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc020109c:	068a                	slli	a3,a3,0x2
ffffffffc020109e:	757d                	lui	a0,0xfffff
ffffffffc02010a0:	8ee9                	and	a3,a3,a0
ffffffffc02010a2:	00c6d793          	srli	a5,a3,0xc
ffffffffc02010a6:	04e7f463          	bgeu	a5,a4,ffffffffc02010ee <get_pte+0x186>
ffffffffc02010aa:	000ab503          	ld	a0,0(s5)
ffffffffc02010ae:	00c95913          	srli	s2,s2,0xc
ffffffffc02010b2:	1ff97913          	andi	s2,s2,511
ffffffffc02010b6:	96aa                	add	a3,a3,a0
ffffffffc02010b8:	00391513          	slli	a0,s2,0x3
ffffffffc02010bc:	9536                	add	a0,a0,a3
}
ffffffffc02010be:	70e2                	ld	ra,56(sp)
ffffffffc02010c0:	7442                	ld	s0,48(sp)
ffffffffc02010c2:	74a2                	ld	s1,40(sp)
ffffffffc02010c4:	7902                	ld	s2,32(sp)
ffffffffc02010c6:	69e2                	ld	s3,24(sp)
ffffffffc02010c8:	6a42                	ld	s4,16(sp)
ffffffffc02010ca:	6aa2                	ld	s5,8(sp)
ffffffffc02010cc:	6b02                	ld	s6,0(sp)
ffffffffc02010ce:	6121                	addi	sp,sp,64
ffffffffc02010d0:	8082                	ret
            return NULL;
ffffffffc02010d2:	4501                	li	a0,0
ffffffffc02010d4:	b7ed                	j	ffffffffc02010be <get_pte+0x156>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc02010d6:	00006617          	auipc	a2,0x6
ffffffffc02010da:	ef260613          	addi	a2,a2,-270 # ffffffffc0206fc8 <commands+0x868>
ffffffffc02010de:	0e300593          	li	a1,227
ffffffffc02010e2:	00006517          	auipc	a0,0x6
ffffffffc02010e6:	f0e50513          	addi	a0,a0,-242 # ffffffffc0206ff0 <commands+0x890>
ffffffffc02010ea:	92aff0ef          	jal	ra,ffffffffc0200214 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc02010ee:	00006617          	auipc	a2,0x6
ffffffffc02010f2:	eda60613          	addi	a2,a2,-294 # ffffffffc0206fc8 <commands+0x868>
ffffffffc02010f6:	0ee00593          	li	a1,238
ffffffffc02010fa:	00006517          	auipc	a0,0x6
ffffffffc02010fe:	ef650513          	addi	a0,a0,-266 # ffffffffc0206ff0 <commands+0x890>
ffffffffc0201102:	912ff0ef          	jal	ra,ffffffffc0200214 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201106:	86aa                	mv	a3,a0
ffffffffc0201108:	00006617          	auipc	a2,0x6
ffffffffc020110c:	ec060613          	addi	a2,a2,-320 # ffffffffc0206fc8 <commands+0x868>
ffffffffc0201110:	0eb00593          	li	a1,235
ffffffffc0201114:	00006517          	auipc	a0,0x6
ffffffffc0201118:	edc50513          	addi	a0,a0,-292 # ffffffffc0206ff0 <commands+0x890>
ffffffffc020111c:	8f8ff0ef          	jal	ra,ffffffffc0200214 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201120:	86aa                	mv	a3,a0
ffffffffc0201122:	00006617          	auipc	a2,0x6
ffffffffc0201126:	ea660613          	addi	a2,a2,-346 # ffffffffc0206fc8 <commands+0x868>
ffffffffc020112a:	0df00593          	li	a1,223
ffffffffc020112e:	00006517          	auipc	a0,0x6
ffffffffc0201132:	ec250513          	addi	a0,a0,-318 # ffffffffc0206ff0 <commands+0x890>
ffffffffc0201136:	8deff0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc020113a <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc020113a:	1141                	addi	sp,sp,-16
ffffffffc020113c:	e022                	sd	s0,0(sp)
ffffffffc020113e:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201140:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0201142:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201144:	e25ff0ef          	jal	ra,ffffffffc0200f68 <get_pte>
    if (ptep_store != NULL) {
ffffffffc0201148:	c011                	beqz	s0,ffffffffc020114c <get_page+0x12>
        *ptep_store = ptep;
ffffffffc020114a:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc020114c:	c511                	beqz	a0,ffffffffc0201158 <get_page+0x1e>
ffffffffc020114e:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0201150:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0201152:	0017f713          	andi	a4,a5,1
ffffffffc0201156:	e709                	bnez	a4,ffffffffc0201160 <get_page+0x26>
}
ffffffffc0201158:	60a2                	ld	ra,8(sp)
ffffffffc020115a:	6402                	ld	s0,0(sp)
ffffffffc020115c:	0141                	addi	sp,sp,16
ffffffffc020115e:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0201160:	000ab717          	auipc	a4,0xab
ffffffffc0201164:	70070713          	addi	a4,a4,1792 # ffffffffc02ac860 <npage>
ffffffffc0201168:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc020116a:	078a                	slli	a5,a5,0x2
ffffffffc020116c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020116e:	02e7f063          	bgeu	a5,a4,ffffffffc020118e <get_page+0x54>
    return &pages[PPN(pa) - nbase];
ffffffffc0201172:	000ab717          	auipc	a4,0xab
ffffffffc0201176:	75670713          	addi	a4,a4,1878 # ffffffffc02ac8c8 <pages>
ffffffffc020117a:	6308                	ld	a0,0(a4)
ffffffffc020117c:	60a2                	ld	ra,8(sp)
ffffffffc020117e:	6402                	ld	s0,0(sp)
ffffffffc0201180:	fff80737          	lui	a4,0xfff80
ffffffffc0201184:	97ba                	add	a5,a5,a4
ffffffffc0201186:	079a                	slli	a5,a5,0x6
ffffffffc0201188:	953e                	add	a0,a0,a5
ffffffffc020118a:	0141                	addi	sp,sp,16
ffffffffc020118c:	8082                	ret
ffffffffc020118e:	cb1ff0ef          	jal	ra,ffffffffc0200e3e <pa2page.part.4>

ffffffffc0201192 <unmap_range>:
        *ptep = 0;                  //(5) clear second page table entry
        tlb_invalidate(pgdir, la);  //(6) flush tlb
    }
}

void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc0201192:	711d                	addi	sp,sp,-96
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0201194:	00c5e7b3          	or	a5,a1,a2
void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc0201198:	ec86                	sd	ra,88(sp)
ffffffffc020119a:	e8a2                	sd	s0,80(sp)
ffffffffc020119c:	e4a6                	sd	s1,72(sp)
ffffffffc020119e:	e0ca                	sd	s2,64(sp)
ffffffffc02011a0:	fc4e                	sd	s3,56(sp)
ffffffffc02011a2:	f852                	sd	s4,48(sp)
ffffffffc02011a4:	f456                	sd	s5,40(sp)
ffffffffc02011a6:	f05a                	sd	s6,32(sp)
ffffffffc02011a8:	ec5e                	sd	s7,24(sp)
ffffffffc02011aa:	e862                	sd	s8,16(sp)
ffffffffc02011ac:	e466                	sd	s9,8(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02011ae:	03479713          	slli	a4,a5,0x34
ffffffffc02011b2:	eb71                	bnez	a4,ffffffffc0201286 <unmap_range+0xf4>
    assert(USER_ACCESS(start, end));
ffffffffc02011b4:	002007b7          	lui	a5,0x200
ffffffffc02011b8:	842e                	mv	s0,a1
ffffffffc02011ba:	0af5e663          	bltu	a1,a5,ffffffffc0201266 <unmap_range+0xd4>
ffffffffc02011be:	8932                	mv	s2,a2
ffffffffc02011c0:	0ac5f363          	bgeu	a1,a2,ffffffffc0201266 <unmap_range+0xd4>
ffffffffc02011c4:	4785                	li	a5,1
ffffffffc02011c6:	07fe                	slli	a5,a5,0x1f
ffffffffc02011c8:	08c7ef63          	bltu	a5,a2,ffffffffc0201266 <unmap_range+0xd4>
ffffffffc02011cc:	89aa                	mv	s3,a0
            continue;
        }
        if (*ptep != 0) {
            page_remove_pte(pgdir, start, ptep);
        }
        start += PGSIZE;
ffffffffc02011ce:	6a05                	lui	s4,0x1
    if (PPN(pa) >= npage) {
ffffffffc02011d0:	000abc97          	auipc	s9,0xab
ffffffffc02011d4:	690c8c93          	addi	s9,s9,1680 # ffffffffc02ac860 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc02011d8:	000abc17          	auipc	s8,0xab
ffffffffc02011dc:	6f0c0c13          	addi	s8,s8,1776 # ffffffffc02ac8c8 <pages>
ffffffffc02011e0:	fff80bb7          	lui	s7,0xfff80
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc02011e4:	00200b37          	lui	s6,0x200
ffffffffc02011e8:	ffe00ab7          	lui	s5,0xffe00
        pte_t *ptep = get_pte(pgdir, start, 0);
ffffffffc02011ec:	4601                	li	a2,0
ffffffffc02011ee:	85a2                	mv	a1,s0
ffffffffc02011f0:	854e                	mv	a0,s3
ffffffffc02011f2:	d77ff0ef          	jal	ra,ffffffffc0200f68 <get_pte>
ffffffffc02011f6:	84aa                	mv	s1,a0
        if (ptep == NULL) {
ffffffffc02011f8:	cd21                	beqz	a0,ffffffffc0201250 <unmap_range+0xbe>
        if (*ptep != 0) {
ffffffffc02011fa:	611c                	ld	a5,0(a0)
ffffffffc02011fc:	e38d                	bnez	a5,ffffffffc020121e <unmap_range+0x8c>
        start += PGSIZE;
ffffffffc02011fe:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc0201200:	ff2466e3          	bltu	s0,s2,ffffffffc02011ec <unmap_range+0x5a>
}
ffffffffc0201204:	60e6                	ld	ra,88(sp)
ffffffffc0201206:	6446                	ld	s0,80(sp)
ffffffffc0201208:	64a6                	ld	s1,72(sp)
ffffffffc020120a:	6906                	ld	s2,64(sp)
ffffffffc020120c:	79e2                	ld	s3,56(sp)
ffffffffc020120e:	7a42                	ld	s4,48(sp)
ffffffffc0201210:	7aa2                	ld	s5,40(sp)
ffffffffc0201212:	7b02                	ld	s6,32(sp)
ffffffffc0201214:	6be2                	ld	s7,24(sp)
ffffffffc0201216:	6c42                	ld	s8,16(sp)
ffffffffc0201218:	6ca2                	ld	s9,8(sp)
ffffffffc020121a:	6125                	addi	sp,sp,96
ffffffffc020121c:	8082                	ret
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc020121e:	0017f713          	andi	a4,a5,1
ffffffffc0201222:	df71                	beqz	a4,ffffffffc02011fe <unmap_range+0x6c>
    if (PPN(pa) >= npage) {
ffffffffc0201224:	000cb703          	ld	a4,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201228:	078a                	slli	a5,a5,0x2
ffffffffc020122a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020122c:	06e7fd63          	bgeu	a5,a4,ffffffffc02012a6 <unmap_range+0x114>
    return &pages[PPN(pa) - nbase];
ffffffffc0201230:	000c3503          	ld	a0,0(s8)
ffffffffc0201234:	97de                	add	a5,a5,s7
ffffffffc0201236:	079a                	slli	a5,a5,0x6
ffffffffc0201238:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc020123a:	411c                	lw	a5,0(a0)
ffffffffc020123c:	fff7871b          	addiw	a4,a5,-1
ffffffffc0201240:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0201242:	cf11                	beqz	a4,ffffffffc020125e <unmap_range+0xcc>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0201244:	0004b023          	sd	zero,0(s1)
}

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la) {
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201248:	12040073          	sfence.vma	s0
        start += PGSIZE;
ffffffffc020124c:	9452                	add	s0,s0,s4
ffffffffc020124e:	bf4d                	j	ffffffffc0201200 <unmap_range+0x6e>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0201250:	945a                	add	s0,s0,s6
ffffffffc0201252:	01547433          	and	s0,s0,s5
    } while (start != 0 && start < end);
ffffffffc0201256:	d45d                	beqz	s0,ffffffffc0201204 <unmap_range+0x72>
ffffffffc0201258:	f9246ae3          	bltu	s0,s2,ffffffffc02011ec <unmap_range+0x5a>
ffffffffc020125c:	b765                	j	ffffffffc0201204 <unmap_range+0x72>
            free_page(page);
ffffffffc020125e:	4585                	li	a1,1
ffffffffc0201260:	c83ff0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
ffffffffc0201264:	b7c5                	j	ffffffffc0201244 <unmap_range+0xb2>
    assert(USER_ACCESS(start, end));
ffffffffc0201266:	00006697          	auipc	a3,0x6
ffffffffc020126a:	38a68693          	addi	a3,a3,906 # ffffffffc02075f0 <commands+0xe90>
ffffffffc020126e:	00006617          	auipc	a2,0x6
ffffffffc0201272:	97260613          	addi	a2,a2,-1678 # ffffffffc0206be0 <commands+0x480>
ffffffffc0201276:	11000593          	li	a1,272
ffffffffc020127a:	00006517          	auipc	a0,0x6
ffffffffc020127e:	d7650513          	addi	a0,a0,-650 # ffffffffc0206ff0 <commands+0x890>
ffffffffc0201282:	f93fe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0201286:	00006697          	auipc	a3,0x6
ffffffffc020128a:	33a68693          	addi	a3,a3,826 # ffffffffc02075c0 <commands+0xe60>
ffffffffc020128e:	00006617          	auipc	a2,0x6
ffffffffc0201292:	95260613          	addi	a2,a2,-1710 # ffffffffc0206be0 <commands+0x480>
ffffffffc0201296:	10f00593          	li	a1,271
ffffffffc020129a:	00006517          	auipc	a0,0x6
ffffffffc020129e:	d5650513          	addi	a0,a0,-682 # ffffffffc0206ff0 <commands+0x890>
ffffffffc02012a2:	f73fe0ef          	jal	ra,ffffffffc0200214 <__panic>
ffffffffc02012a6:	b99ff0ef          	jal	ra,ffffffffc0200e3e <pa2page.part.4>

ffffffffc02012aa <exit_range>:
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc02012aa:	7119                	addi	sp,sp,-128
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02012ac:	00c5e7b3          	or	a5,a1,a2
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc02012b0:	fc86                	sd	ra,120(sp)
ffffffffc02012b2:	f8a2                	sd	s0,112(sp)
ffffffffc02012b4:	f4a6                	sd	s1,104(sp)
ffffffffc02012b6:	f0ca                	sd	s2,96(sp)
ffffffffc02012b8:	ecce                	sd	s3,88(sp)
ffffffffc02012ba:	e8d2                	sd	s4,80(sp)
ffffffffc02012bc:	e4d6                	sd	s5,72(sp)
ffffffffc02012be:	e0da                	sd	s6,64(sp)
ffffffffc02012c0:	fc5e                	sd	s7,56(sp)
ffffffffc02012c2:	f862                	sd	s8,48(sp)
ffffffffc02012c4:	f466                	sd	s9,40(sp)
ffffffffc02012c6:	f06a                	sd	s10,32(sp)
ffffffffc02012c8:	ec6e                	sd	s11,24(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02012ca:	03479713          	slli	a4,a5,0x34
ffffffffc02012ce:	1c071163          	bnez	a4,ffffffffc0201490 <exit_range+0x1e6>
    assert(USER_ACCESS(start, end));
ffffffffc02012d2:	002007b7          	lui	a5,0x200
ffffffffc02012d6:	20f5e563          	bltu	a1,a5,ffffffffc02014e0 <exit_range+0x236>
ffffffffc02012da:	8b32                	mv	s6,a2
ffffffffc02012dc:	20c5f263          	bgeu	a1,a2,ffffffffc02014e0 <exit_range+0x236>
ffffffffc02012e0:	4785                	li	a5,1
ffffffffc02012e2:	07fe                	slli	a5,a5,0x1f
ffffffffc02012e4:	1ec7ee63          	bltu	a5,a2,ffffffffc02014e0 <exit_range+0x236>
    d1start = ROUNDDOWN(start, PDSIZE);
ffffffffc02012e8:	c00009b7          	lui	s3,0xc0000
ffffffffc02012ec:	400007b7          	lui	a5,0x40000
ffffffffc02012f0:	0135f9b3          	and	s3,a1,s3
ffffffffc02012f4:	99be                	add	s3,s3,a5
        pde1 = pgdir[PDX1(d1start)];
ffffffffc02012f6:	c0000337          	lui	t1,0xc0000
ffffffffc02012fa:	00698933          	add	s2,s3,t1
ffffffffc02012fe:	01e95913          	srli	s2,s2,0x1e
ffffffffc0201302:	1ff97913          	andi	s2,s2,511
ffffffffc0201306:	8e2a                	mv	t3,a0
ffffffffc0201308:	090e                	slli	s2,s2,0x3
ffffffffc020130a:	9972                	add	s2,s2,t3
ffffffffc020130c:	00093b83          	ld	s7,0(s2)
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc0201310:	ffe004b7          	lui	s1,0xffe00
    return KADDR(page2pa(page));
ffffffffc0201314:	5dfd                	li	s11,-1
        if (pde1&PTE_V){
ffffffffc0201316:	001bf793          	andi	a5,s7,1
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc020131a:	8ced                	and	s1,s1,a1
    if (PPN(pa) >= npage) {
ffffffffc020131c:	000abd17          	auipc	s10,0xab
ffffffffc0201320:	544d0d13          	addi	s10,s10,1348 # ffffffffc02ac860 <npage>
    return KADDR(page2pa(page));
ffffffffc0201324:	00cddd93          	srli	s11,s11,0xc
ffffffffc0201328:	000ab717          	auipc	a4,0xab
ffffffffc020132c:	59070713          	addi	a4,a4,1424 # ffffffffc02ac8b8 <va_pa_offset>
    return &pages[PPN(pa) - nbase];
ffffffffc0201330:	000abe97          	auipc	t4,0xab
ffffffffc0201334:	598e8e93          	addi	t4,t4,1432 # ffffffffc02ac8c8 <pages>
        if (pde1&PTE_V){
ffffffffc0201338:	e79d                	bnez	a5,ffffffffc0201366 <exit_range+0xbc>
    } while (d1start != 0 && d1start < end);
ffffffffc020133a:	12098963          	beqz	s3,ffffffffc020146c <exit_range+0x1c2>
ffffffffc020133e:	400007b7          	lui	a5,0x40000
ffffffffc0201342:	84ce                	mv	s1,s3
ffffffffc0201344:	97ce                	add	a5,a5,s3
ffffffffc0201346:	1369f363          	bgeu	s3,s6,ffffffffc020146c <exit_range+0x1c2>
ffffffffc020134a:	89be                	mv	s3,a5
        pde1 = pgdir[PDX1(d1start)];
ffffffffc020134c:	00698933          	add	s2,s3,t1
ffffffffc0201350:	01e95913          	srli	s2,s2,0x1e
ffffffffc0201354:	1ff97913          	andi	s2,s2,511
ffffffffc0201358:	090e                	slli	s2,s2,0x3
ffffffffc020135a:	9972                	add	s2,s2,t3
ffffffffc020135c:	00093b83          	ld	s7,0(s2)
        if (pde1&PTE_V){
ffffffffc0201360:	001bf793          	andi	a5,s7,1
ffffffffc0201364:	dbf9                	beqz	a5,ffffffffc020133a <exit_range+0x90>
    if (PPN(pa) >= npage) {
ffffffffc0201366:	000d3783          	ld	a5,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc020136a:	0b8a                	slli	s7,s7,0x2
ffffffffc020136c:	00cbdb93          	srli	s7,s7,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201370:	14fbfc63          	bgeu	s7,a5,ffffffffc02014c8 <exit_range+0x21e>
    return &pages[PPN(pa) - nbase];
ffffffffc0201374:	fff80ab7          	lui	s5,0xfff80
ffffffffc0201378:	9ade                	add	s5,s5,s7
    return page - pages + nbase;
ffffffffc020137a:	000806b7          	lui	a3,0x80
ffffffffc020137e:	96d6                	add	a3,a3,s5
ffffffffc0201380:	006a9593          	slli	a1,s5,0x6
    return KADDR(page2pa(page));
ffffffffc0201384:	01b6f633          	and	a2,a3,s11
    return page - pages + nbase;
ffffffffc0201388:	e42e                	sd	a1,8(sp)
    return page2ppn(page) << PGSHIFT;
ffffffffc020138a:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020138c:	12f67263          	bgeu	a2,a5,ffffffffc02014b0 <exit_range+0x206>
ffffffffc0201390:	00073a03          	ld	s4,0(a4)
            free_pd0 = 1;
ffffffffc0201394:	4c85                	li	s9,1
    return &pages[PPN(pa) - nbase];
ffffffffc0201396:	fff808b7          	lui	a7,0xfff80
    return KADDR(page2pa(page));
ffffffffc020139a:	9a36                	add	s4,s4,a3
    return page - pages + nbase;
ffffffffc020139c:	00080837          	lui	a6,0x80
ffffffffc02013a0:	6a85                	lui	s5,0x1
                d0start += PTSIZE;
ffffffffc02013a2:	00200c37          	lui	s8,0x200
ffffffffc02013a6:	a801                	j	ffffffffc02013b6 <exit_range+0x10c>
                    free_pd0 = 0;
ffffffffc02013a8:	4c81                	li	s9,0
                d0start += PTSIZE;
ffffffffc02013aa:	94e2                	add	s1,s1,s8
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc02013ac:	c0d9                	beqz	s1,ffffffffc0201432 <exit_range+0x188>
ffffffffc02013ae:	0934f263          	bgeu	s1,s3,ffffffffc0201432 <exit_range+0x188>
ffffffffc02013b2:	0d64fc63          	bgeu	s1,s6,ffffffffc020148a <exit_range+0x1e0>
                pde0 = pd0[PDX0(d0start)];
ffffffffc02013b6:	0154d413          	srli	s0,s1,0x15
ffffffffc02013ba:	1ff47413          	andi	s0,s0,511
ffffffffc02013be:	040e                	slli	s0,s0,0x3
ffffffffc02013c0:	9452                	add	s0,s0,s4
ffffffffc02013c2:	601c                	ld	a5,0(s0)
                if (pde0&PTE_V) {
ffffffffc02013c4:	0017f693          	andi	a3,a5,1
ffffffffc02013c8:	d2e5                	beqz	a3,ffffffffc02013a8 <exit_range+0xfe>
    if (PPN(pa) >= npage) {
ffffffffc02013ca:	000d3583          	ld	a1,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc02013ce:	00279513          	slli	a0,a5,0x2
ffffffffc02013d2:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc02013d4:	0eb57a63          	bgeu	a0,a1,ffffffffc02014c8 <exit_range+0x21e>
    return &pages[PPN(pa) - nbase];
ffffffffc02013d8:	9546                	add	a0,a0,a7
    return page - pages + nbase;
ffffffffc02013da:	010506b3          	add	a3,a0,a6
    return KADDR(page2pa(page));
ffffffffc02013de:	01b6f7b3          	and	a5,a3,s11
    return page - pages + nbase;
ffffffffc02013e2:	051a                	slli	a0,a0,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc02013e4:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02013e6:	0cb7f563          	bgeu	a5,a1,ffffffffc02014b0 <exit_range+0x206>
ffffffffc02013ea:	631c                	ld	a5,0(a4)
ffffffffc02013ec:	96be                	add	a3,a3,a5
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc02013ee:	015685b3          	add	a1,a3,s5
                        if (pt[i]&PTE_V){
ffffffffc02013f2:	629c                	ld	a5,0(a3)
ffffffffc02013f4:	8b85                	andi	a5,a5,1
ffffffffc02013f6:	fbd5                	bnez	a5,ffffffffc02013aa <exit_range+0x100>
ffffffffc02013f8:	06a1                	addi	a3,a3,8
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc02013fa:	fed59ce3          	bne	a1,a3,ffffffffc02013f2 <exit_range+0x148>
    return &pages[PPN(pa) - nbase];
ffffffffc02013fe:	000eb783          	ld	a5,0(t4)
                        free_page(pde2page(pde0));
ffffffffc0201402:	4585                	li	a1,1
ffffffffc0201404:	e072                	sd	t3,0(sp)
ffffffffc0201406:	953e                	add	a0,a0,a5
ffffffffc0201408:	adbff0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
                d0start += PTSIZE;
ffffffffc020140c:	94e2                	add	s1,s1,s8
                        pd0[PDX0(d0start)] = 0;
ffffffffc020140e:	00043023          	sd	zero,0(s0)
ffffffffc0201412:	000abe97          	auipc	t4,0xab
ffffffffc0201416:	4b6e8e93          	addi	t4,t4,1206 # ffffffffc02ac8c8 <pages>
ffffffffc020141a:	6e02                	ld	t3,0(sp)
ffffffffc020141c:	c0000337          	lui	t1,0xc0000
ffffffffc0201420:	fff808b7          	lui	a7,0xfff80
ffffffffc0201424:	00080837          	lui	a6,0x80
ffffffffc0201428:	000ab717          	auipc	a4,0xab
ffffffffc020142c:	49070713          	addi	a4,a4,1168 # ffffffffc02ac8b8 <va_pa_offset>
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc0201430:	fcbd                	bnez	s1,ffffffffc02013ae <exit_range+0x104>
            if (free_pd0) {
ffffffffc0201432:	f00c84e3          	beqz	s9,ffffffffc020133a <exit_range+0x90>
    if (PPN(pa) >= npage) {
ffffffffc0201436:	000d3783          	ld	a5,0(s10)
ffffffffc020143a:	e072                	sd	t3,0(sp)
ffffffffc020143c:	08fbf663          	bgeu	s7,a5,ffffffffc02014c8 <exit_range+0x21e>
    return &pages[PPN(pa) - nbase];
ffffffffc0201440:	000eb503          	ld	a0,0(t4)
                free_page(pde2page(pde1));
ffffffffc0201444:	67a2                	ld	a5,8(sp)
ffffffffc0201446:	4585                	li	a1,1
ffffffffc0201448:	953e                	add	a0,a0,a5
ffffffffc020144a:	a99ff0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc020144e:	00093023          	sd	zero,0(s2)
ffffffffc0201452:	000ab717          	auipc	a4,0xab
ffffffffc0201456:	46670713          	addi	a4,a4,1126 # ffffffffc02ac8b8 <va_pa_offset>
ffffffffc020145a:	c0000337          	lui	t1,0xc0000
ffffffffc020145e:	6e02                	ld	t3,0(sp)
ffffffffc0201460:	000abe97          	auipc	t4,0xab
ffffffffc0201464:	468e8e93          	addi	t4,t4,1128 # ffffffffc02ac8c8 <pages>
    } while (d1start != 0 && d1start < end);
ffffffffc0201468:	ec099be3          	bnez	s3,ffffffffc020133e <exit_range+0x94>
}
ffffffffc020146c:	70e6                	ld	ra,120(sp)
ffffffffc020146e:	7446                	ld	s0,112(sp)
ffffffffc0201470:	74a6                	ld	s1,104(sp)
ffffffffc0201472:	7906                	ld	s2,96(sp)
ffffffffc0201474:	69e6                	ld	s3,88(sp)
ffffffffc0201476:	6a46                	ld	s4,80(sp)
ffffffffc0201478:	6aa6                	ld	s5,72(sp)
ffffffffc020147a:	6b06                	ld	s6,64(sp)
ffffffffc020147c:	7be2                	ld	s7,56(sp)
ffffffffc020147e:	7c42                	ld	s8,48(sp)
ffffffffc0201480:	7ca2                	ld	s9,40(sp)
ffffffffc0201482:	7d02                	ld	s10,32(sp)
ffffffffc0201484:	6de2                	ld	s11,24(sp)
ffffffffc0201486:	6109                	addi	sp,sp,128
ffffffffc0201488:	8082                	ret
            if (free_pd0) {
ffffffffc020148a:	ea0c8ae3          	beqz	s9,ffffffffc020133e <exit_range+0x94>
ffffffffc020148e:	b765                	j	ffffffffc0201436 <exit_range+0x18c>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0201490:	00006697          	auipc	a3,0x6
ffffffffc0201494:	13068693          	addi	a3,a3,304 # ffffffffc02075c0 <commands+0xe60>
ffffffffc0201498:	00005617          	auipc	a2,0x5
ffffffffc020149c:	74860613          	addi	a2,a2,1864 # ffffffffc0206be0 <commands+0x480>
ffffffffc02014a0:	12000593          	li	a1,288
ffffffffc02014a4:	00006517          	auipc	a0,0x6
ffffffffc02014a8:	b4c50513          	addi	a0,a0,-1204 # ffffffffc0206ff0 <commands+0x890>
ffffffffc02014ac:	d69fe0ef          	jal	ra,ffffffffc0200214 <__panic>
    return KADDR(page2pa(page));
ffffffffc02014b0:	00006617          	auipc	a2,0x6
ffffffffc02014b4:	b1860613          	addi	a2,a2,-1256 # ffffffffc0206fc8 <commands+0x868>
ffffffffc02014b8:	06900593          	li	a1,105
ffffffffc02014bc:	00006517          	auipc	a0,0x6
ffffffffc02014c0:	b6450513          	addi	a0,a0,-1180 # ffffffffc0207020 <commands+0x8c0>
ffffffffc02014c4:	d51fe0ef          	jal	ra,ffffffffc0200214 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02014c8:	00006617          	auipc	a2,0x6
ffffffffc02014cc:	b3860613          	addi	a2,a2,-1224 # ffffffffc0207000 <commands+0x8a0>
ffffffffc02014d0:	06200593          	li	a1,98
ffffffffc02014d4:	00006517          	auipc	a0,0x6
ffffffffc02014d8:	b4c50513          	addi	a0,a0,-1204 # ffffffffc0207020 <commands+0x8c0>
ffffffffc02014dc:	d39fe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc02014e0:	00006697          	auipc	a3,0x6
ffffffffc02014e4:	11068693          	addi	a3,a3,272 # ffffffffc02075f0 <commands+0xe90>
ffffffffc02014e8:	00005617          	auipc	a2,0x5
ffffffffc02014ec:	6f860613          	addi	a2,a2,1784 # ffffffffc0206be0 <commands+0x480>
ffffffffc02014f0:	12100593          	li	a1,289
ffffffffc02014f4:	00006517          	auipc	a0,0x6
ffffffffc02014f8:	afc50513          	addi	a0,a0,-1284 # ffffffffc0206ff0 <commands+0x890>
ffffffffc02014fc:	d19fe0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0201500 <page_remove>:
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0201500:	1101                	addi	sp,sp,-32
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201502:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0201504:	e426                	sd	s1,8(sp)
ffffffffc0201506:	ec06                	sd	ra,24(sp)
ffffffffc0201508:	e822                	sd	s0,16(sp)
ffffffffc020150a:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020150c:	a5dff0ef          	jal	ra,ffffffffc0200f68 <get_pte>
    if (ptep != NULL) {
ffffffffc0201510:	c511                	beqz	a0,ffffffffc020151c <page_remove+0x1c>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0201512:	611c                	ld	a5,0(a0)
ffffffffc0201514:	842a                	mv	s0,a0
ffffffffc0201516:	0017f713          	andi	a4,a5,1
ffffffffc020151a:	e711                	bnez	a4,ffffffffc0201526 <page_remove+0x26>
}
ffffffffc020151c:	60e2                	ld	ra,24(sp)
ffffffffc020151e:	6442                	ld	s0,16(sp)
ffffffffc0201520:	64a2                	ld	s1,8(sp)
ffffffffc0201522:	6105                	addi	sp,sp,32
ffffffffc0201524:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0201526:	000ab717          	auipc	a4,0xab
ffffffffc020152a:	33a70713          	addi	a4,a4,826 # ffffffffc02ac860 <npage>
ffffffffc020152e:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201530:	078a                	slli	a5,a5,0x2
ffffffffc0201532:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201534:	02e7fe63          	bgeu	a5,a4,ffffffffc0201570 <page_remove+0x70>
    return &pages[PPN(pa) - nbase];
ffffffffc0201538:	000ab717          	auipc	a4,0xab
ffffffffc020153c:	39070713          	addi	a4,a4,912 # ffffffffc02ac8c8 <pages>
ffffffffc0201540:	6308                	ld	a0,0(a4)
ffffffffc0201542:	fff80737          	lui	a4,0xfff80
ffffffffc0201546:	97ba                	add	a5,a5,a4
ffffffffc0201548:	079a                	slli	a5,a5,0x6
ffffffffc020154a:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc020154c:	411c                	lw	a5,0(a0)
ffffffffc020154e:	fff7871b          	addiw	a4,a5,-1
ffffffffc0201552:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0201554:	cb11                	beqz	a4,ffffffffc0201568 <page_remove+0x68>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0201556:	00043023          	sd	zero,0(s0)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020155a:	12048073          	sfence.vma	s1
}
ffffffffc020155e:	60e2                	ld	ra,24(sp)
ffffffffc0201560:	6442                	ld	s0,16(sp)
ffffffffc0201562:	64a2                	ld	s1,8(sp)
ffffffffc0201564:	6105                	addi	sp,sp,32
ffffffffc0201566:	8082                	ret
            free_page(page);
ffffffffc0201568:	4585                	li	a1,1
ffffffffc020156a:	979ff0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
ffffffffc020156e:	b7e5                	j	ffffffffc0201556 <page_remove+0x56>
ffffffffc0201570:	8cfff0ef          	jal	ra,ffffffffc0200e3e <pa2page.part.4>

ffffffffc0201574 <page_insert>:
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201574:	7179                	addi	sp,sp,-48
ffffffffc0201576:	e44e                	sd	s3,8(sp)
ffffffffc0201578:	89b2                	mv	s3,a2
ffffffffc020157a:	f022                	sd	s0,32(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc020157c:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc020157e:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201580:	85ce                	mv	a1,s3
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201582:	ec26                	sd	s1,24(sp)
ffffffffc0201584:	f406                	sd	ra,40(sp)
ffffffffc0201586:	e84a                	sd	s2,16(sp)
ffffffffc0201588:	e052                	sd	s4,0(sp)
ffffffffc020158a:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc020158c:	9ddff0ef          	jal	ra,ffffffffc0200f68 <get_pte>
    if (ptep == NULL) {
ffffffffc0201590:	cd49                	beqz	a0,ffffffffc020162a <page_insert+0xb6>
    page->ref += 1;
ffffffffc0201592:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V) {
ffffffffc0201594:	611c                	ld	a5,0(a0)
ffffffffc0201596:	892a                	mv	s2,a0
ffffffffc0201598:	0016871b          	addiw	a4,a3,1
ffffffffc020159c:	c018                	sw	a4,0(s0)
ffffffffc020159e:	0017f713          	andi	a4,a5,1
ffffffffc02015a2:	ef05                	bnez	a4,ffffffffc02015da <page_insert+0x66>
ffffffffc02015a4:	000ab797          	auipc	a5,0xab
ffffffffc02015a8:	32478793          	addi	a5,a5,804 # ffffffffc02ac8c8 <pages>
ffffffffc02015ac:	6398                	ld	a4,0(a5)
    return page - pages + nbase;
ffffffffc02015ae:	8c19                	sub	s0,s0,a4
ffffffffc02015b0:	000806b7          	lui	a3,0x80
ffffffffc02015b4:	8419                	srai	s0,s0,0x6
ffffffffc02015b6:	9436                	add	s0,s0,a3
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02015b8:	042a                	slli	s0,s0,0xa
ffffffffc02015ba:	8c45                	or	s0,s0,s1
ffffffffc02015bc:	00146413          	ori	s0,s0,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc02015c0:	00893023          	sd	s0,0(s2)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02015c4:	12098073          	sfence.vma	s3
    return 0;
ffffffffc02015c8:	4501                	li	a0,0
}
ffffffffc02015ca:	70a2                	ld	ra,40(sp)
ffffffffc02015cc:	7402                	ld	s0,32(sp)
ffffffffc02015ce:	64e2                	ld	s1,24(sp)
ffffffffc02015d0:	6942                	ld	s2,16(sp)
ffffffffc02015d2:	69a2                	ld	s3,8(sp)
ffffffffc02015d4:	6a02                	ld	s4,0(sp)
ffffffffc02015d6:	6145                	addi	sp,sp,48
ffffffffc02015d8:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc02015da:	000ab717          	auipc	a4,0xab
ffffffffc02015de:	28670713          	addi	a4,a4,646 # ffffffffc02ac860 <npage>
ffffffffc02015e2:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc02015e4:	078a                	slli	a5,a5,0x2
ffffffffc02015e6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02015e8:	04e7f363          	bgeu	a5,a4,ffffffffc020162e <page_insert+0xba>
    return &pages[PPN(pa) - nbase];
ffffffffc02015ec:	000aba17          	auipc	s4,0xab
ffffffffc02015f0:	2dca0a13          	addi	s4,s4,732 # ffffffffc02ac8c8 <pages>
ffffffffc02015f4:	000a3703          	ld	a4,0(s4)
ffffffffc02015f8:	fff80537          	lui	a0,0xfff80
ffffffffc02015fc:	953e                	add	a0,a0,a5
ffffffffc02015fe:	051a                	slli	a0,a0,0x6
ffffffffc0201600:	953a                	add	a0,a0,a4
        if (p == page) {
ffffffffc0201602:	00a40a63          	beq	s0,a0,ffffffffc0201616 <page_insert+0xa2>
    page->ref -= 1;
ffffffffc0201606:	411c                	lw	a5,0(a0)
ffffffffc0201608:	fff7869b          	addiw	a3,a5,-1
ffffffffc020160c:	c114                	sw	a3,0(a0)
        if (page_ref(page) ==
ffffffffc020160e:	c691                	beqz	a3,ffffffffc020161a <page_insert+0xa6>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201610:	12098073          	sfence.vma	s3
ffffffffc0201614:	bf69                	j	ffffffffc02015ae <page_insert+0x3a>
ffffffffc0201616:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0201618:	bf59                	j	ffffffffc02015ae <page_insert+0x3a>
            free_page(page);
ffffffffc020161a:	4585                	li	a1,1
ffffffffc020161c:	8c7ff0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
ffffffffc0201620:	000a3703          	ld	a4,0(s4)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201624:	12098073          	sfence.vma	s3
ffffffffc0201628:	b759                	j	ffffffffc02015ae <page_insert+0x3a>
        return -E_NO_MEM;
ffffffffc020162a:	5571                	li	a0,-4
ffffffffc020162c:	bf79                	j	ffffffffc02015ca <page_insert+0x56>
ffffffffc020162e:	811ff0ef          	jal	ra,ffffffffc0200e3e <pa2page.part.4>

ffffffffc0201632 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0201632:	00007797          	auipc	a5,0x7
ffffffffc0201636:	cee78793          	addi	a5,a5,-786 # ffffffffc0208320 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020163a:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc020163c:	715d                	addi	sp,sp,-80
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020163e:	00006517          	auipc	a0,0x6
ffffffffc0201642:	a0a50513          	addi	a0,a0,-1526 # ffffffffc0207048 <commands+0x8e8>
void pmm_init(void) {
ffffffffc0201646:	e486                	sd	ra,72(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0201648:	000ab717          	auipc	a4,0xab
ffffffffc020164c:	26f73423          	sd	a5,616(a4) # ffffffffc02ac8b0 <pmm_manager>
void pmm_init(void) {
ffffffffc0201650:	e0a2                	sd	s0,64(sp)
ffffffffc0201652:	fc26                	sd	s1,56(sp)
ffffffffc0201654:	f84a                	sd	s2,48(sp)
ffffffffc0201656:	f44e                	sd	s3,40(sp)
ffffffffc0201658:	f052                	sd	s4,32(sp)
ffffffffc020165a:	ec56                	sd	s5,24(sp)
ffffffffc020165c:	e85a                	sd	s6,16(sp)
ffffffffc020165e:	e45e                	sd	s7,8(sp)
ffffffffc0201660:	e062                	sd	s8,0(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0201662:	000ab417          	auipc	s0,0xab
ffffffffc0201666:	24e40413          	addi	s0,s0,590 # ffffffffc02ac8b0 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020166a:	a67fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    pmm_manager->init();
ffffffffc020166e:	601c                	ld	a5,0(s0)
ffffffffc0201670:	000ab497          	auipc	s1,0xab
ffffffffc0201674:	1f048493          	addi	s1,s1,496 # ffffffffc02ac860 <npage>
ffffffffc0201678:	000ab917          	auipc	s2,0xab
ffffffffc020167c:	25090913          	addi	s2,s2,592 # ffffffffc02ac8c8 <pages>
ffffffffc0201680:	679c                	ld	a5,8(a5)
ffffffffc0201682:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201684:	57f5                	li	a5,-3
ffffffffc0201686:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0201688:	00006517          	auipc	a0,0x6
ffffffffc020168c:	9d850513          	addi	a0,a0,-1576 # ffffffffc0207060 <commands+0x900>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201690:	000ab717          	auipc	a4,0xab
ffffffffc0201694:	22f73423          	sd	a5,552(a4) # ffffffffc02ac8b8 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc0201698:	a39fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc020169c:	46c5                	li	a3,17
ffffffffc020169e:	06ee                	slli	a3,a3,0x1b
ffffffffc02016a0:	40100613          	li	a2,1025
ffffffffc02016a4:	16fd                	addi	a3,a3,-1
ffffffffc02016a6:	0656                	slli	a2,a2,0x15
ffffffffc02016a8:	07e005b7          	lui	a1,0x7e00
ffffffffc02016ac:	00006517          	auipc	a0,0x6
ffffffffc02016b0:	9cc50513          	addi	a0,a0,-1588 # ffffffffc0207078 <commands+0x918>
ffffffffc02016b4:	a1dfe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02016b8:	777d                	lui	a4,0xfffff
ffffffffc02016ba:	000ac797          	auipc	a5,0xac
ffffffffc02016be:	31d78793          	addi	a5,a5,797 # ffffffffc02ad9d7 <end+0xfff>
ffffffffc02016c2:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc02016c4:	00088737          	lui	a4,0x88
ffffffffc02016c8:	000ab697          	auipc	a3,0xab
ffffffffc02016cc:	18e6bc23          	sd	a4,408(a3) # ffffffffc02ac860 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02016d0:	000ab717          	auipc	a4,0xab
ffffffffc02016d4:	1ef73c23          	sd	a5,504(a4) # ffffffffc02ac8c8 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02016d8:	4701                	li	a4,0
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02016da:	4685                	li	a3,1
ffffffffc02016dc:	fff80837          	lui	a6,0xfff80
ffffffffc02016e0:	a019                	j	ffffffffc02016e6 <pmm_init+0xb4>
ffffffffc02016e2:	00093783          	ld	a5,0(s2)
        SetPageReserved(pages + i);
ffffffffc02016e6:	00671613          	slli	a2,a4,0x6
ffffffffc02016ea:	97b2                	add	a5,a5,a2
ffffffffc02016ec:	07a1                	addi	a5,a5,8
ffffffffc02016ee:	40d7b02f          	amoor.d	zero,a3,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02016f2:	6090                	ld	a2,0(s1)
ffffffffc02016f4:	0705                	addi	a4,a4,1
ffffffffc02016f6:	010607b3          	add	a5,a2,a6
ffffffffc02016fa:	fef764e3          	bltu	a4,a5,ffffffffc02016e2 <pmm_init+0xb0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02016fe:	00093503          	ld	a0,0(s2)
ffffffffc0201702:	fe0007b7          	lui	a5,0xfe000
ffffffffc0201706:	00661693          	slli	a3,a2,0x6
ffffffffc020170a:	97aa                	add	a5,a5,a0
ffffffffc020170c:	96be                	add	a3,a3,a5
ffffffffc020170e:	c02007b7          	lui	a5,0xc0200
ffffffffc0201712:	7af6eb63          	bltu	a3,a5,ffffffffc0201ec8 <pmm_init+0x896>
ffffffffc0201716:	000ab997          	auipc	s3,0xab
ffffffffc020171a:	1a298993          	addi	s3,s3,418 # ffffffffc02ac8b8 <va_pa_offset>
ffffffffc020171e:	0009b583          	ld	a1,0(s3)
    if (freemem < mem_end) {
ffffffffc0201722:	47c5                	li	a5,17
ffffffffc0201724:	07ee                	slli	a5,a5,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201726:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end) {
ffffffffc0201728:	02f6f763          	bgeu	a3,a5,ffffffffc0201756 <pmm_init+0x124>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc020172c:	6585                	lui	a1,0x1
ffffffffc020172e:	15fd                	addi	a1,a1,-1
ffffffffc0201730:	96ae                	add	a3,a3,a1
    if (PPN(pa) >= npage) {
ffffffffc0201732:	00c6d713          	srli	a4,a3,0xc
ffffffffc0201736:	48c77863          	bgeu	a4,a2,ffffffffc0201bc6 <pmm_init+0x594>
    pmm_manager->init_memmap(base, n);
ffffffffc020173a:	6010                	ld	a2,0(s0)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc020173c:	75fd                	lui	a1,0xfffff
ffffffffc020173e:	8eed                	and	a3,a3,a1
    return &pages[PPN(pa) - nbase];
ffffffffc0201740:	9742                	add	a4,a4,a6
    pmm_manager->init_memmap(base, n);
ffffffffc0201742:	6a10                	ld	a2,16(a2)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0201744:	40d786b3          	sub	a3,a5,a3
ffffffffc0201748:	071a                	slli	a4,a4,0x6
    pmm_manager->init_memmap(base, n);
ffffffffc020174a:	00c6d593          	srli	a1,a3,0xc
ffffffffc020174e:	953a                	add	a0,a0,a4
ffffffffc0201750:	9602                	jalr	a2
ffffffffc0201752:	0009b583          	ld	a1,0(s3)
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc0201756:	00006517          	auipc	a0,0x6
ffffffffc020175a:	97250513          	addi	a0,a0,-1678 # ffffffffc02070c8 <commands+0x968>
ffffffffc020175e:	973fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0201762:	601c                	ld	a5,0(s0)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0201764:	000ab417          	auipc	s0,0xab
ffffffffc0201768:	0f440413          	addi	s0,s0,244 # ffffffffc02ac858 <boot_pgdir>
    pmm_manager->check();
ffffffffc020176c:	7b9c                	ld	a5,48(a5)
ffffffffc020176e:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0201770:	00006517          	auipc	a0,0x6
ffffffffc0201774:	97050513          	addi	a0,a0,-1680 # ffffffffc02070e0 <commands+0x980>
ffffffffc0201778:	959fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc020177c:	0000a697          	auipc	a3,0xa
ffffffffc0201780:	88468693          	addi	a3,a3,-1916 # ffffffffc020b000 <boot_page_table_sv39>
ffffffffc0201784:	000ab797          	auipc	a5,0xab
ffffffffc0201788:	0cd7ba23          	sd	a3,212(a5) # ffffffffc02ac858 <boot_pgdir>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc020178c:	c02007b7          	lui	a5,0xc0200
ffffffffc0201790:	10f6e8e3          	bltu	a3,a5,ffffffffc02020a0 <pmm_init+0xa6e>
ffffffffc0201794:	0009b783          	ld	a5,0(s3)
ffffffffc0201798:	8e9d                	sub	a3,a3,a5
ffffffffc020179a:	000ab797          	auipc	a5,0xab
ffffffffc020179e:	12d7b323          	sd	a3,294(a5) # ffffffffc02ac8c0 <boot_cr3>
    // assert(npage <= KMEMSIZE / PGSIZE);
    // The memory starts at 2GB in RISC-V
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();
ffffffffc02017a2:	f86ff0ef          	jal	ra,ffffffffc0200f28 <nr_free_pages>

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02017a6:	6098                	ld	a4,0(s1)
ffffffffc02017a8:	c80007b7          	lui	a5,0xc8000
ffffffffc02017ac:	83b1                	srli	a5,a5,0xc
    nr_free_store=nr_free_pages();
ffffffffc02017ae:	8a2a                	mv	s4,a0
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02017b0:	0ce7e8e3          	bltu	a5,a4,ffffffffc0202080 <pmm_init+0xa4e>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc02017b4:	6008                	ld	a0,0(s0)
ffffffffc02017b6:	44050263          	beqz	a0,ffffffffc0201bfa <pmm_init+0x5c8>
ffffffffc02017ba:	03451793          	slli	a5,a0,0x34
ffffffffc02017be:	42079e63          	bnez	a5,ffffffffc0201bfa <pmm_init+0x5c8>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc02017c2:	4601                	li	a2,0
ffffffffc02017c4:	4581                	li	a1,0
ffffffffc02017c6:	975ff0ef          	jal	ra,ffffffffc020113a <get_page>
ffffffffc02017ca:	78051b63          	bnez	a0,ffffffffc0201f60 <pmm_init+0x92e>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc02017ce:	4505                	li	a0,1
ffffffffc02017d0:	e8aff0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc02017d4:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc02017d6:	6008                	ld	a0,0(s0)
ffffffffc02017d8:	4681                	li	a3,0
ffffffffc02017da:	4601                	li	a2,0
ffffffffc02017dc:	85d6                	mv	a1,s5
ffffffffc02017de:	d97ff0ef          	jal	ra,ffffffffc0201574 <page_insert>
ffffffffc02017e2:	7a051f63          	bnez	a0,ffffffffc0201fa0 <pmm_init+0x96e>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc02017e6:	6008                	ld	a0,0(s0)
ffffffffc02017e8:	4601                	li	a2,0
ffffffffc02017ea:	4581                	li	a1,0
ffffffffc02017ec:	f7cff0ef          	jal	ra,ffffffffc0200f68 <get_pte>
ffffffffc02017f0:	78050863          	beqz	a0,ffffffffc0201f80 <pmm_init+0x94e>
    assert(pte2page(*ptep) == p1);
ffffffffc02017f4:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02017f6:	0017f713          	andi	a4,a5,1
ffffffffc02017fa:	3e070463          	beqz	a4,ffffffffc0201be2 <pmm_init+0x5b0>
    if (PPN(pa) >= npage) {
ffffffffc02017fe:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201800:	078a                	slli	a5,a5,0x2
ffffffffc0201802:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201804:	3ce7f163          	bgeu	a5,a4,ffffffffc0201bc6 <pmm_init+0x594>
    return &pages[PPN(pa) - nbase];
ffffffffc0201808:	00093683          	ld	a3,0(s2)
ffffffffc020180c:	fff80637          	lui	a2,0xfff80
ffffffffc0201810:	97b2                	add	a5,a5,a2
ffffffffc0201812:	079a                	slli	a5,a5,0x6
ffffffffc0201814:	97b6                	add	a5,a5,a3
ffffffffc0201816:	72fa9563          	bne	s5,a5,ffffffffc0201f40 <pmm_init+0x90e>
    assert(page_ref(p1) == 1);
ffffffffc020181a:	000aab83          	lw	s7,0(s5) # 1000 <_binary_obj___user_faultread_out_size-0x85c8>
ffffffffc020181e:	4785                	li	a5,1
ffffffffc0201820:	70fb9063          	bne	s7,a5,ffffffffc0201f20 <pmm_init+0x8ee>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0201824:	6008                	ld	a0,0(s0)
ffffffffc0201826:	76fd                	lui	a3,0xfffff
ffffffffc0201828:	611c                	ld	a5,0(a0)
ffffffffc020182a:	078a                	slli	a5,a5,0x2
ffffffffc020182c:	8ff5                	and	a5,a5,a3
ffffffffc020182e:	00c7d613          	srli	a2,a5,0xc
ffffffffc0201832:	66e67e63          	bgeu	a2,a4,ffffffffc0201eae <pmm_init+0x87c>
ffffffffc0201836:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020183a:	97e2                	add	a5,a5,s8
ffffffffc020183c:	0007bb03          	ld	s6,0(a5) # ffffffffc8000000 <end+0x7d53628>
ffffffffc0201840:	0b0a                	slli	s6,s6,0x2
ffffffffc0201842:	00db7b33          	and	s6,s6,a3
ffffffffc0201846:	00cb5793          	srli	a5,s6,0xc
ffffffffc020184a:	56e7f863          	bgeu	a5,a4,ffffffffc0201dba <pmm_init+0x788>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc020184e:	4601                	li	a2,0
ffffffffc0201850:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201852:	9b62                	add	s6,s6,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201854:	f14ff0ef          	jal	ra,ffffffffc0200f68 <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201858:	0b21                	addi	s6,s6,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc020185a:	55651063          	bne	a0,s6,ffffffffc0201d9a <pmm_init+0x768>

    p2 = alloc_page();
ffffffffc020185e:	4505                	li	a0,1
ffffffffc0201860:	dfaff0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0201864:	8b2a                	mv	s6,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0201866:	6008                	ld	a0,0(s0)
ffffffffc0201868:	46d1                	li	a3,20
ffffffffc020186a:	6605                	lui	a2,0x1
ffffffffc020186c:	85da                	mv	a1,s6
ffffffffc020186e:	d07ff0ef          	jal	ra,ffffffffc0201574 <page_insert>
ffffffffc0201872:	50051463          	bnez	a0,ffffffffc0201d7a <pmm_init+0x748>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201876:	6008                	ld	a0,0(s0)
ffffffffc0201878:	4601                	li	a2,0
ffffffffc020187a:	6585                	lui	a1,0x1
ffffffffc020187c:	eecff0ef          	jal	ra,ffffffffc0200f68 <get_pte>
ffffffffc0201880:	4c050d63          	beqz	a0,ffffffffc0201d5a <pmm_init+0x728>
    assert(*ptep & PTE_U);
ffffffffc0201884:	611c                	ld	a5,0(a0)
ffffffffc0201886:	0107f713          	andi	a4,a5,16
ffffffffc020188a:	4a070863          	beqz	a4,ffffffffc0201d3a <pmm_init+0x708>
    assert(*ptep & PTE_W);
ffffffffc020188e:	8b91                	andi	a5,a5,4
ffffffffc0201890:	48078563          	beqz	a5,ffffffffc0201d1a <pmm_init+0x6e8>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0201894:	6008                	ld	a0,0(s0)
ffffffffc0201896:	611c                	ld	a5,0(a0)
ffffffffc0201898:	8bc1                	andi	a5,a5,16
ffffffffc020189a:	46078063          	beqz	a5,ffffffffc0201cfa <pmm_init+0x6c8>
    assert(page_ref(p2) == 1);
ffffffffc020189e:	000b2783          	lw	a5,0(s6) # 200000 <_binary_obj___user_exit_out_size+0x1f5538>
ffffffffc02018a2:	43779c63          	bne	a5,s7,ffffffffc0201cda <pmm_init+0x6a8>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc02018a6:	4681                	li	a3,0
ffffffffc02018a8:	6605                	lui	a2,0x1
ffffffffc02018aa:	85d6                	mv	a1,s5
ffffffffc02018ac:	cc9ff0ef          	jal	ra,ffffffffc0201574 <page_insert>
ffffffffc02018b0:	40051563          	bnez	a0,ffffffffc0201cba <pmm_init+0x688>
    assert(page_ref(p1) == 2);
ffffffffc02018b4:	000aa703          	lw	a4,0(s5)
ffffffffc02018b8:	4789                	li	a5,2
ffffffffc02018ba:	3ef71063          	bne	a4,a5,ffffffffc0201c9a <pmm_init+0x668>
    assert(page_ref(p2) == 0);
ffffffffc02018be:	000b2783          	lw	a5,0(s6)
ffffffffc02018c2:	3a079c63          	bnez	a5,ffffffffc0201c7a <pmm_init+0x648>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02018c6:	6008                	ld	a0,0(s0)
ffffffffc02018c8:	4601                	li	a2,0
ffffffffc02018ca:	6585                	lui	a1,0x1
ffffffffc02018cc:	e9cff0ef          	jal	ra,ffffffffc0200f68 <get_pte>
ffffffffc02018d0:	38050563          	beqz	a0,ffffffffc0201c5a <pmm_init+0x628>
    assert(pte2page(*ptep) == p1);
ffffffffc02018d4:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02018d6:	00177793          	andi	a5,a4,1
ffffffffc02018da:	30078463          	beqz	a5,ffffffffc0201be2 <pmm_init+0x5b0>
    if (PPN(pa) >= npage) {
ffffffffc02018de:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc02018e0:	00271793          	slli	a5,a4,0x2
ffffffffc02018e4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02018e6:	2ed7f063          	bgeu	a5,a3,ffffffffc0201bc6 <pmm_init+0x594>
    return &pages[PPN(pa) - nbase];
ffffffffc02018ea:	00093683          	ld	a3,0(s2)
ffffffffc02018ee:	fff80637          	lui	a2,0xfff80
ffffffffc02018f2:	97b2                	add	a5,a5,a2
ffffffffc02018f4:	079a                	slli	a5,a5,0x6
ffffffffc02018f6:	97b6                	add	a5,a5,a3
ffffffffc02018f8:	32fa9163          	bne	s5,a5,ffffffffc0201c1a <pmm_init+0x5e8>
    assert((*ptep & PTE_U) == 0);
ffffffffc02018fc:	8b41                	andi	a4,a4,16
ffffffffc02018fe:	70071163          	bnez	a4,ffffffffc0202000 <pmm_init+0x9ce>

    page_remove(boot_pgdir, 0x0);
ffffffffc0201902:	6008                	ld	a0,0(s0)
ffffffffc0201904:	4581                	li	a1,0
ffffffffc0201906:	bfbff0ef          	jal	ra,ffffffffc0201500 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc020190a:	000aa703          	lw	a4,0(s5)
ffffffffc020190e:	4785                	li	a5,1
ffffffffc0201910:	6cf71863          	bne	a4,a5,ffffffffc0201fe0 <pmm_init+0x9ae>
    assert(page_ref(p2) == 0);
ffffffffc0201914:	000b2783          	lw	a5,0(s6)
ffffffffc0201918:	6a079463          	bnez	a5,ffffffffc0201fc0 <pmm_init+0x98e>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc020191c:	6008                	ld	a0,0(s0)
ffffffffc020191e:	6585                	lui	a1,0x1
ffffffffc0201920:	be1ff0ef          	jal	ra,ffffffffc0201500 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0201924:	000aa783          	lw	a5,0(s5)
ffffffffc0201928:	50079363          	bnez	a5,ffffffffc0201e2e <pmm_init+0x7fc>
    assert(page_ref(p2) == 0);
ffffffffc020192c:	000b2783          	lw	a5,0(s6)
ffffffffc0201930:	4c079f63          	bnez	a5,ffffffffc0201e0e <pmm_init+0x7dc>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0201934:	00043b03          	ld	s6,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0201938:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020193a:	000b3783          	ld	a5,0(s6)
ffffffffc020193e:	078a                	slli	a5,a5,0x2
ffffffffc0201940:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201942:	28e7f263          	bgeu	a5,a4,ffffffffc0201bc6 <pmm_init+0x594>
    return &pages[PPN(pa) - nbase];
ffffffffc0201946:	fff806b7          	lui	a3,0xfff80
ffffffffc020194a:	00093503          	ld	a0,0(s2)
ffffffffc020194e:	97b6                	add	a5,a5,a3
ffffffffc0201950:	079a                	slli	a5,a5,0x6
ffffffffc0201952:	00f506b3          	add	a3,a0,a5
ffffffffc0201956:	4290                	lw	a2,0(a3)
ffffffffc0201958:	4685                	li	a3,1
ffffffffc020195a:	48d61a63          	bne	a2,a3,ffffffffc0201dee <pmm_init+0x7bc>
    return page - pages + nbase;
ffffffffc020195e:	8799                	srai	a5,a5,0x6
ffffffffc0201960:	00080ab7          	lui	s5,0x80
ffffffffc0201964:	97d6                	add	a5,a5,s5
    return KADDR(page2pa(page));
ffffffffc0201966:	00c79693          	slli	a3,a5,0xc
ffffffffc020196a:	82b1                	srli	a3,a3,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc020196c:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc020196e:	46e6f363          	bgeu	a3,a4,ffffffffc0201dd4 <pmm_init+0x7a2>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0201972:	0009b683          	ld	a3,0(s3)
ffffffffc0201976:	97b6                	add	a5,a5,a3
    return pa2page(PDE_ADDR(pde));
ffffffffc0201978:	639c                	ld	a5,0(a5)
ffffffffc020197a:	078a                	slli	a5,a5,0x2
ffffffffc020197c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020197e:	24e7f463          	bgeu	a5,a4,ffffffffc0201bc6 <pmm_init+0x594>
    return &pages[PPN(pa) - nbase];
ffffffffc0201982:	415787b3          	sub	a5,a5,s5
ffffffffc0201986:	079a                	slli	a5,a5,0x6
ffffffffc0201988:	953e                	add	a0,a0,a5
ffffffffc020198a:	4585                	li	a1,1
ffffffffc020198c:	d56ff0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0201990:	000b3783          	ld	a5,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc0201994:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201996:	078a                	slli	a5,a5,0x2
ffffffffc0201998:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020199a:	22e7f663          	bgeu	a5,a4,ffffffffc0201bc6 <pmm_init+0x594>
    return &pages[PPN(pa) - nbase];
ffffffffc020199e:	00093503          	ld	a0,0(s2)
ffffffffc02019a2:	415787b3          	sub	a5,a5,s5
ffffffffc02019a6:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc02019a8:	953e                	add	a0,a0,a5
ffffffffc02019aa:	4585                	li	a1,1
ffffffffc02019ac:	d36ff0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
    boot_pgdir[0] = 0;
ffffffffc02019b0:	601c                	ld	a5,0(s0)
ffffffffc02019b2:	0007b023          	sd	zero,0(a5)
  asm volatile("sfence.vma");
ffffffffc02019b6:	12000073          	sfence.vma
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc02019ba:	d6eff0ef          	jal	ra,ffffffffc0200f28 <nr_free_pages>
ffffffffc02019be:	68aa1163          	bne	s4,a0,ffffffffc0202040 <pmm_init+0xa0e>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc02019c2:	00006517          	auipc	a0,0x6
ffffffffc02019c6:	a2e50513          	addi	a0,a0,-1490 # ffffffffc02073f0 <commands+0xc90>
ffffffffc02019ca:	f06fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
static void check_boot_pgdir(void) {
    size_t nr_free_store;
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();
ffffffffc02019ce:	d5aff0ef          	jal	ra,ffffffffc0200f28 <nr_free_pages>

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02019d2:	6098                	ld	a4,0(s1)
ffffffffc02019d4:	c02007b7          	lui	a5,0xc0200
    nr_free_store=nr_free_pages();
ffffffffc02019d8:	8a2a                	mv	s4,a0
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02019da:	00c71693          	slli	a3,a4,0xc
ffffffffc02019de:	18d7f563          	bgeu	a5,a3,ffffffffc0201b68 <pmm_init+0x536>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02019e2:	83b1                	srli	a5,a5,0xc
ffffffffc02019e4:	6008                	ld	a0,0(s0)
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02019e6:	c0200ab7          	lui	s5,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02019ea:	1ae7f163          	bgeu	a5,a4,ffffffffc0201b8c <pmm_init+0x55a>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02019ee:	7bfd                	lui	s7,0xfffff
ffffffffc02019f0:	6b05                	lui	s6,0x1
ffffffffc02019f2:	a029                	j	ffffffffc02019fc <pmm_init+0x3ca>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02019f4:	00cad713          	srli	a4,s5,0xc
ffffffffc02019f8:	18f77a63          	bgeu	a4,a5,ffffffffc0201b8c <pmm_init+0x55a>
ffffffffc02019fc:	0009b583          	ld	a1,0(s3)
ffffffffc0201a00:	4601                	li	a2,0
ffffffffc0201a02:	95d6                	add	a1,a1,s5
ffffffffc0201a04:	d64ff0ef          	jal	ra,ffffffffc0200f68 <get_pte>
ffffffffc0201a08:	16050263          	beqz	a0,ffffffffc0201b6c <pmm_init+0x53a>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201a0c:	611c                	ld	a5,0(a0)
ffffffffc0201a0e:	078a                	slli	a5,a5,0x2
ffffffffc0201a10:	0177f7b3          	and	a5,a5,s7
ffffffffc0201a14:	19579963          	bne	a5,s5,ffffffffc0201ba6 <pmm_init+0x574>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201a18:	609c                	ld	a5,0(s1)
ffffffffc0201a1a:	9ada                	add	s5,s5,s6
ffffffffc0201a1c:	6008                	ld	a0,0(s0)
ffffffffc0201a1e:	00c79713          	slli	a4,a5,0xc
ffffffffc0201a22:	fceae9e3          	bltu	s5,a4,ffffffffc02019f4 <pmm_init+0x3c2>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc0201a26:	611c                	ld	a5,0(a0)
ffffffffc0201a28:	62079c63          	bnez	a5,ffffffffc0202060 <pmm_init+0xa2e>

    struct Page *p;
    p = alloc_page();
ffffffffc0201a2c:	4505                	li	a0,1
ffffffffc0201a2e:	c2cff0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0201a32:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0201a34:	6008                	ld	a0,0(s0)
ffffffffc0201a36:	4699                	li	a3,6
ffffffffc0201a38:	10000613          	li	a2,256
ffffffffc0201a3c:	85d6                	mv	a1,s5
ffffffffc0201a3e:	b37ff0ef          	jal	ra,ffffffffc0201574 <page_insert>
ffffffffc0201a42:	1e051c63          	bnez	a0,ffffffffc0201c3a <pmm_init+0x608>
    assert(page_ref(p) == 1);
ffffffffc0201a46:	000aa703          	lw	a4,0(s5) # ffffffffc0200000 <kern_entry>
ffffffffc0201a4a:	4785                	li	a5,1
ffffffffc0201a4c:	44f71163          	bne	a4,a5,ffffffffc0201e8e <pmm_init+0x85c>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0201a50:	6008                	ld	a0,0(s0)
ffffffffc0201a52:	6b05                	lui	s6,0x1
ffffffffc0201a54:	4699                	li	a3,6
ffffffffc0201a56:	100b0613          	addi	a2,s6,256 # 1100 <_binary_obj___user_faultread_out_size-0x84c8>
ffffffffc0201a5a:	85d6                	mv	a1,s5
ffffffffc0201a5c:	b19ff0ef          	jal	ra,ffffffffc0201574 <page_insert>
ffffffffc0201a60:	40051763          	bnez	a0,ffffffffc0201e6e <pmm_init+0x83c>
    assert(page_ref(p) == 2);
ffffffffc0201a64:	000aa703          	lw	a4,0(s5)
ffffffffc0201a68:	4789                	li	a5,2
ffffffffc0201a6a:	3ef71263          	bne	a4,a5,ffffffffc0201e4e <pmm_init+0x81c>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0201a6e:	00006597          	auipc	a1,0x6
ffffffffc0201a72:	aba58593          	addi	a1,a1,-1350 # ffffffffc0207528 <commands+0xdc8>
ffffffffc0201a76:	10000513          	li	a0,256
ffffffffc0201a7a:	6ec040ef          	jal	ra,ffffffffc0206166 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0201a7e:	100b0593          	addi	a1,s6,256
ffffffffc0201a82:	10000513          	li	a0,256
ffffffffc0201a86:	6f2040ef          	jal	ra,ffffffffc0206178 <strcmp>
ffffffffc0201a8a:	44051b63          	bnez	a0,ffffffffc0201ee0 <pmm_init+0x8ae>
    return page - pages + nbase;
ffffffffc0201a8e:	00093683          	ld	a3,0(s2)
ffffffffc0201a92:	00080737          	lui	a4,0x80
    return KADDR(page2pa(page));
ffffffffc0201a96:	5b7d                	li	s6,-1
    return page - pages + nbase;
ffffffffc0201a98:	40da86b3          	sub	a3,s5,a3
ffffffffc0201a9c:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0201a9e:	609c                	ld	a5,0(s1)
    return page - pages + nbase;
ffffffffc0201aa0:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc0201aa2:	00cb5b13          	srli	s6,s6,0xc
ffffffffc0201aa6:	0166f733          	and	a4,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc0201aaa:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0201aac:	10f77f63          	bgeu	a4,a5,ffffffffc0201bca <pmm_init+0x598>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0201ab0:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0201ab4:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0201ab8:	96be                	add	a3,a3,a5
ffffffffc0201aba:	10068023          	sb	zero,256(a3) # fffffffffff80100 <end+0x3fcd3728>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0201abe:	664040ef          	jal	ra,ffffffffc0206122 <strlen>
ffffffffc0201ac2:	54051f63          	bnez	a0,ffffffffc0202020 <pmm_init+0x9ee>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0201ac6:	00043b83          	ld	s7,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0201aca:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201acc:	000bb683          	ld	a3,0(s7) # fffffffffffff000 <end+0x3fd52628>
ffffffffc0201ad0:	068a                	slli	a3,a3,0x2
ffffffffc0201ad2:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201ad4:	0ef6f963          	bgeu	a3,a5,ffffffffc0201bc6 <pmm_init+0x594>
    return KADDR(page2pa(page));
ffffffffc0201ad8:	0166fb33          	and	s6,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc0201adc:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0201ade:	0efb7663          	bgeu	s6,a5,ffffffffc0201bca <pmm_init+0x598>
ffffffffc0201ae2:	0009b983          	ld	s3,0(s3)
    free_page(p);
ffffffffc0201ae6:	4585                	li	a1,1
ffffffffc0201ae8:	8556                	mv	a0,s5
ffffffffc0201aea:	99b6                	add	s3,s3,a3
ffffffffc0201aec:	bf6ff0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0201af0:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc0201af4:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201af6:	078a                	slli	a5,a5,0x2
ffffffffc0201af8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201afa:	0ce7f663          	bgeu	a5,a4,ffffffffc0201bc6 <pmm_init+0x594>
    return &pages[PPN(pa) - nbase];
ffffffffc0201afe:	00093503          	ld	a0,0(s2)
ffffffffc0201b02:	fff809b7          	lui	s3,0xfff80
ffffffffc0201b06:	97ce                	add	a5,a5,s3
ffffffffc0201b08:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc0201b0a:	953e                	add	a0,a0,a5
ffffffffc0201b0c:	4585                	li	a1,1
ffffffffc0201b0e:	bd4ff0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0201b12:	000bb783          	ld	a5,0(s7)
    if (PPN(pa) >= npage) {
ffffffffc0201b16:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201b18:	078a                	slli	a5,a5,0x2
ffffffffc0201b1a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201b1c:	0ae7f563          	bgeu	a5,a4,ffffffffc0201bc6 <pmm_init+0x594>
    return &pages[PPN(pa) - nbase];
ffffffffc0201b20:	00093503          	ld	a0,0(s2)
ffffffffc0201b24:	97ce                	add	a5,a5,s3
ffffffffc0201b26:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0201b28:	953e                	add	a0,a0,a5
ffffffffc0201b2a:	4585                	li	a1,1
ffffffffc0201b2c:	bb6ff0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
    boot_pgdir[0] = 0;
ffffffffc0201b30:	601c                	ld	a5,0(s0)
ffffffffc0201b32:	0007b023          	sd	zero,0(a5) # ffffffffc0200000 <kern_entry>
  asm volatile("sfence.vma");
ffffffffc0201b36:	12000073          	sfence.vma
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0201b3a:	beeff0ef          	jal	ra,ffffffffc0200f28 <nr_free_pages>
ffffffffc0201b3e:	3caa1163          	bne	s4,a0,ffffffffc0201f00 <pmm_init+0x8ce>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0201b42:	00006517          	auipc	a0,0x6
ffffffffc0201b46:	a5e50513          	addi	a0,a0,-1442 # ffffffffc02075a0 <commands+0xe40>
ffffffffc0201b4a:	d86fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
}
ffffffffc0201b4e:	6406                	ld	s0,64(sp)
ffffffffc0201b50:	60a6                	ld	ra,72(sp)
ffffffffc0201b52:	74e2                	ld	s1,56(sp)
ffffffffc0201b54:	7942                	ld	s2,48(sp)
ffffffffc0201b56:	79a2                	ld	s3,40(sp)
ffffffffc0201b58:	7a02                	ld	s4,32(sp)
ffffffffc0201b5a:	6ae2                	ld	s5,24(sp)
ffffffffc0201b5c:	6b42                	ld	s6,16(sp)
ffffffffc0201b5e:	6ba2                	ld	s7,8(sp)
ffffffffc0201b60:	6c02                	ld	s8,0(sp)
ffffffffc0201b62:	6161                	addi	sp,sp,80
    kmalloc_init();
ffffffffc0201b64:	66f0106f          	j	ffffffffc02039d2 <kmalloc_init>
ffffffffc0201b68:	6008                	ld	a0,0(s0)
ffffffffc0201b6a:	bd75                	j	ffffffffc0201a26 <pmm_init+0x3f4>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201b6c:	00006697          	auipc	a3,0x6
ffffffffc0201b70:	8a468693          	addi	a3,a3,-1884 # ffffffffc0207410 <commands+0xcb0>
ffffffffc0201b74:	00005617          	auipc	a2,0x5
ffffffffc0201b78:	06c60613          	addi	a2,a2,108 # ffffffffc0206be0 <commands+0x480>
ffffffffc0201b7c:	22a00593          	li	a1,554
ffffffffc0201b80:	00005517          	auipc	a0,0x5
ffffffffc0201b84:	47050513          	addi	a0,a0,1136 # ffffffffc0206ff0 <commands+0x890>
ffffffffc0201b88:	e8cfe0ef          	jal	ra,ffffffffc0200214 <__panic>
ffffffffc0201b8c:	86d6                	mv	a3,s5
ffffffffc0201b8e:	00005617          	auipc	a2,0x5
ffffffffc0201b92:	43a60613          	addi	a2,a2,1082 # ffffffffc0206fc8 <commands+0x868>
ffffffffc0201b96:	22a00593          	li	a1,554
ffffffffc0201b9a:	00005517          	auipc	a0,0x5
ffffffffc0201b9e:	45650513          	addi	a0,a0,1110 # ffffffffc0206ff0 <commands+0x890>
ffffffffc0201ba2:	e72fe0ef          	jal	ra,ffffffffc0200214 <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201ba6:	00006697          	auipc	a3,0x6
ffffffffc0201baa:	8aa68693          	addi	a3,a3,-1878 # ffffffffc0207450 <commands+0xcf0>
ffffffffc0201bae:	00005617          	auipc	a2,0x5
ffffffffc0201bb2:	03260613          	addi	a2,a2,50 # ffffffffc0206be0 <commands+0x480>
ffffffffc0201bb6:	22b00593          	li	a1,555
ffffffffc0201bba:	00005517          	auipc	a0,0x5
ffffffffc0201bbe:	43650513          	addi	a0,a0,1078 # ffffffffc0206ff0 <commands+0x890>
ffffffffc0201bc2:	e52fe0ef          	jal	ra,ffffffffc0200214 <__panic>
ffffffffc0201bc6:	a78ff0ef          	jal	ra,ffffffffc0200e3e <pa2page.part.4>
    return KADDR(page2pa(page));
ffffffffc0201bca:	00005617          	auipc	a2,0x5
ffffffffc0201bce:	3fe60613          	addi	a2,a2,1022 # ffffffffc0206fc8 <commands+0x868>
ffffffffc0201bd2:	06900593          	li	a1,105
ffffffffc0201bd6:	00005517          	auipc	a0,0x5
ffffffffc0201bda:	44a50513          	addi	a0,a0,1098 # ffffffffc0207020 <commands+0x8c0>
ffffffffc0201bde:	e36fe0ef          	jal	ra,ffffffffc0200214 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0201be2:	00005617          	auipc	a2,0x5
ffffffffc0201be6:	5fe60613          	addi	a2,a2,1534 # ffffffffc02071e0 <commands+0xa80>
ffffffffc0201bea:	07400593          	li	a1,116
ffffffffc0201bee:	00005517          	auipc	a0,0x5
ffffffffc0201bf2:	43250513          	addi	a0,a0,1074 # ffffffffc0207020 <commands+0x8c0>
ffffffffc0201bf6:	e1efe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0201bfa:	00005697          	auipc	a3,0x5
ffffffffc0201bfe:	52668693          	addi	a3,a3,1318 # ffffffffc0207120 <commands+0x9c0>
ffffffffc0201c02:	00005617          	auipc	a2,0x5
ffffffffc0201c06:	fde60613          	addi	a2,a2,-34 # ffffffffc0206be0 <commands+0x480>
ffffffffc0201c0a:	1ee00593          	li	a1,494
ffffffffc0201c0e:	00005517          	auipc	a0,0x5
ffffffffc0201c12:	3e250513          	addi	a0,a0,994 # ffffffffc0206ff0 <commands+0x890>
ffffffffc0201c16:	dfefe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0201c1a:	00005697          	auipc	a3,0x5
ffffffffc0201c1e:	5ee68693          	addi	a3,a3,1518 # ffffffffc0207208 <commands+0xaa8>
ffffffffc0201c22:	00005617          	auipc	a2,0x5
ffffffffc0201c26:	fbe60613          	addi	a2,a2,-66 # ffffffffc0206be0 <commands+0x480>
ffffffffc0201c2a:	20a00593          	li	a1,522
ffffffffc0201c2e:	00005517          	auipc	a0,0x5
ffffffffc0201c32:	3c250513          	addi	a0,a0,962 # ffffffffc0206ff0 <commands+0x890>
ffffffffc0201c36:	ddefe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0201c3a:	00006697          	auipc	a3,0x6
ffffffffc0201c3e:	84668693          	addi	a3,a3,-1978 # ffffffffc0207480 <commands+0xd20>
ffffffffc0201c42:	00005617          	auipc	a2,0x5
ffffffffc0201c46:	f9e60613          	addi	a2,a2,-98 # ffffffffc0206be0 <commands+0x480>
ffffffffc0201c4a:	23300593          	li	a1,563
ffffffffc0201c4e:	00005517          	auipc	a0,0x5
ffffffffc0201c52:	3a250513          	addi	a0,a0,930 # ffffffffc0206ff0 <commands+0x890>
ffffffffc0201c56:	dbefe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201c5a:	00005697          	auipc	a3,0x5
ffffffffc0201c5e:	63e68693          	addi	a3,a3,1598 # ffffffffc0207298 <commands+0xb38>
ffffffffc0201c62:	00005617          	auipc	a2,0x5
ffffffffc0201c66:	f7e60613          	addi	a2,a2,-130 # ffffffffc0206be0 <commands+0x480>
ffffffffc0201c6a:	20900593          	li	a1,521
ffffffffc0201c6e:	00005517          	auipc	a0,0x5
ffffffffc0201c72:	38250513          	addi	a0,a0,898 # ffffffffc0206ff0 <commands+0x890>
ffffffffc0201c76:	d9efe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0201c7a:	00005697          	auipc	a3,0x5
ffffffffc0201c7e:	6e668693          	addi	a3,a3,1766 # ffffffffc0207360 <commands+0xc00>
ffffffffc0201c82:	00005617          	auipc	a2,0x5
ffffffffc0201c86:	f5e60613          	addi	a2,a2,-162 # ffffffffc0206be0 <commands+0x480>
ffffffffc0201c8a:	20800593          	li	a1,520
ffffffffc0201c8e:	00005517          	auipc	a0,0x5
ffffffffc0201c92:	36250513          	addi	a0,a0,866 # ffffffffc0206ff0 <commands+0x890>
ffffffffc0201c96:	d7efe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0201c9a:	00005697          	auipc	a3,0x5
ffffffffc0201c9e:	6ae68693          	addi	a3,a3,1710 # ffffffffc0207348 <commands+0xbe8>
ffffffffc0201ca2:	00005617          	auipc	a2,0x5
ffffffffc0201ca6:	f3e60613          	addi	a2,a2,-194 # ffffffffc0206be0 <commands+0x480>
ffffffffc0201caa:	20700593          	li	a1,519
ffffffffc0201cae:	00005517          	auipc	a0,0x5
ffffffffc0201cb2:	34250513          	addi	a0,a0,834 # ffffffffc0206ff0 <commands+0x890>
ffffffffc0201cb6:	d5efe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0201cba:	00005697          	auipc	a3,0x5
ffffffffc0201cbe:	65e68693          	addi	a3,a3,1630 # ffffffffc0207318 <commands+0xbb8>
ffffffffc0201cc2:	00005617          	auipc	a2,0x5
ffffffffc0201cc6:	f1e60613          	addi	a2,a2,-226 # ffffffffc0206be0 <commands+0x480>
ffffffffc0201cca:	20600593          	li	a1,518
ffffffffc0201cce:	00005517          	auipc	a0,0x5
ffffffffc0201cd2:	32250513          	addi	a0,a0,802 # ffffffffc0206ff0 <commands+0x890>
ffffffffc0201cd6:	d3efe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0201cda:	00005697          	auipc	a3,0x5
ffffffffc0201cde:	62668693          	addi	a3,a3,1574 # ffffffffc0207300 <commands+0xba0>
ffffffffc0201ce2:	00005617          	auipc	a2,0x5
ffffffffc0201ce6:	efe60613          	addi	a2,a2,-258 # ffffffffc0206be0 <commands+0x480>
ffffffffc0201cea:	20400593          	li	a1,516
ffffffffc0201cee:	00005517          	auipc	a0,0x5
ffffffffc0201cf2:	30250513          	addi	a0,a0,770 # ffffffffc0206ff0 <commands+0x890>
ffffffffc0201cf6:	d1efe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0201cfa:	00005697          	auipc	a3,0x5
ffffffffc0201cfe:	5ee68693          	addi	a3,a3,1518 # ffffffffc02072e8 <commands+0xb88>
ffffffffc0201d02:	00005617          	auipc	a2,0x5
ffffffffc0201d06:	ede60613          	addi	a2,a2,-290 # ffffffffc0206be0 <commands+0x480>
ffffffffc0201d0a:	20300593          	li	a1,515
ffffffffc0201d0e:	00005517          	auipc	a0,0x5
ffffffffc0201d12:	2e250513          	addi	a0,a0,738 # ffffffffc0206ff0 <commands+0x890>
ffffffffc0201d16:	cfefe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(*ptep & PTE_W);
ffffffffc0201d1a:	00005697          	auipc	a3,0x5
ffffffffc0201d1e:	5be68693          	addi	a3,a3,1470 # ffffffffc02072d8 <commands+0xb78>
ffffffffc0201d22:	00005617          	auipc	a2,0x5
ffffffffc0201d26:	ebe60613          	addi	a2,a2,-322 # ffffffffc0206be0 <commands+0x480>
ffffffffc0201d2a:	20200593          	li	a1,514
ffffffffc0201d2e:	00005517          	auipc	a0,0x5
ffffffffc0201d32:	2c250513          	addi	a0,a0,706 # ffffffffc0206ff0 <commands+0x890>
ffffffffc0201d36:	cdefe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(*ptep & PTE_U);
ffffffffc0201d3a:	00005697          	auipc	a3,0x5
ffffffffc0201d3e:	58e68693          	addi	a3,a3,1422 # ffffffffc02072c8 <commands+0xb68>
ffffffffc0201d42:	00005617          	auipc	a2,0x5
ffffffffc0201d46:	e9e60613          	addi	a2,a2,-354 # ffffffffc0206be0 <commands+0x480>
ffffffffc0201d4a:	20100593          	li	a1,513
ffffffffc0201d4e:	00005517          	auipc	a0,0x5
ffffffffc0201d52:	2a250513          	addi	a0,a0,674 # ffffffffc0206ff0 <commands+0x890>
ffffffffc0201d56:	cbefe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201d5a:	00005697          	auipc	a3,0x5
ffffffffc0201d5e:	53e68693          	addi	a3,a3,1342 # ffffffffc0207298 <commands+0xb38>
ffffffffc0201d62:	00005617          	auipc	a2,0x5
ffffffffc0201d66:	e7e60613          	addi	a2,a2,-386 # ffffffffc0206be0 <commands+0x480>
ffffffffc0201d6a:	20000593          	li	a1,512
ffffffffc0201d6e:	00005517          	auipc	a0,0x5
ffffffffc0201d72:	28250513          	addi	a0,a0,642 # ffffffffc0206ff0 <commands+0x890>
ffffffffc0201d76:	c9efe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0201d7a:	00005697          	auipc	a3,0x5
ffffffffc0201d7e:	4e668693          	addi	a3,a3,1254 # ffffffffc0207260 <commands+0xb00>
ffffffffc0201d82:	00005617          	auipc	a2,0x5
ffffffffc0201d86:	e5e60613          	addi	a2,a2,-418 # ffffffffc0206be0 <commands+0x480>
ffffffffc0201d8a:	1ff00593          	li	a1,511
ffffffffc0201d8e:	00005517          	auipc	a0,0x5
ffffffffc0201d92:	26250513          	addi	a0,a0,610 # ffffffffc0206ff0 <commands+0x890>
ffffffffc0201d96:	c7efe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201d9a:	00005697          	auipc	a3,0x5
ffffffffc0201d9e:	49e68693          	addi	a3,a3,1182 # ffffffffc0207238 <commands+0xad8>
ffffffffc0201da2:	00005617          	auipc	a2,0x5
ffffffffc0201da6:	e3e60613          	addi	a2,a2,-450 # ffffffffc0206be0 <commands+0x480>
ffffffffc0201daa:	1fc00593          	li	a1,508
ffffffffc0201dae:	00005517          	auipc	a0,0x5
ffffffffc0201db2:	24250513          	addi	a0,a0,578 # ffffffffc0206ff0 <commands+0x890>
ffffffffc0201db6:	c5efe0ef          	jal	ra,ffffffffc0200214 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201dba:	86da                	mv	a3,s6
ffffffffc0201dbc:	00005617          	auipc	a2,0x5
ffffffffc0201dc0:	20c60613          	addi	a2,a2,524 # ffffffffc0206fc8 <commands+0x868>
ffffffffc0201dc4:	1fb00593          	li	a1,507
ffffffffc0201dc8:	00005517          	auipc	a0,0x5
ffffffffc0201dcc:	22850513          	addi	a0,a0,552 # ffffffffc0206ff0 <commands+0x890>
ffffffffc0201dd0:	c44fe0ef          	jal	ra,ffffffffc0200214 <__panic>
    return KADDR(page2pa(page));
ffffffffc0201dd4:	86be                	mv	a3,a5
ffffffffc0201dd6:	00005617          	auipc	a2,0x5
ffffffffc0201dda:	1f260613          	addi	a2,a2,498 # ffffffffc0206fc8 <commands+0x868>
ffffffffc0201dde:	06900593          	li	a1,105
ffffffffc0201de2:	00005517          	auipc	a0,0x5
ffffffffc0201de6:	23e50513          	addi	a0,a0,574 # ffffffffc0207020 <commands+0x8c0>
ffffffffc0201dea:	c2afe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0201dee:	00005697          	auipc	a3,0x5
ffffffffc0201df2:	5ba68693          	addi	a3,a3,1466 # ffffffffc02073a8 <commands+0xc48>
ffffffffc0201df6:	00005617          	auipc	a2,0x5
ffffffffc0201dfa:	dea60613          	addi	a2,a2,-534 # ffffffffc0206be0 <commands+0x480>
ffffffffc0201dfe:	21500593          	li	a1,533
ffffffffc0201e02:	00005517          	auipc	a0,0x5
ffffffffc0201e06:	1ee50513          	addi	a0,a0,494 # ffffffffc0206ff0 <commands+0x890>
ffffffffc0201e0a:	c0afe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0201e0e:	00005697          	auipc	a3,0x5
ffffffffc0201e12:	55268693          	addi	a3,a3,1362 # ffffffffc0207360 <commands+0xc00>
ffffffffc0201e16:	00005617          	auipc	a2,0x5
ffffffffc0201e1a:	dca60613          	addi	a2,a2,-566 # ffffffffc0206be0 <commands+0x480>
ffffffffc0201e1e:	21300593          	li	a1,531
ffffffffc0201e22:	00005517          	auipc	a0,0x5
ffffffffc0201e26:	1ce50513          	addi	a0,a0,462 # ffffffffc0206ff0 <commands+0x890>
ffffffffc0201e2a:	beafe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0201e2e:	00005697          	auipc	a3,0x5
ffffffffc0201e32:	56268693          	addi	a3,a3,1378 # ffffffffc0207390 <commands+0xc30>
ffffffffc0201e36:	00005617          	auipc	a2,0x5
ffffffffc0201e3a:	daa60613          	addi	a2,a2,-598 # ffffffffc0206be0 <commands+0x480>
ffffffffc0201e3e:	21200593          	li	a1,530
ffffffffc0201e42:	00005517          	auipc	a0,0x5
ffffffffc0201e46:	1ae50513          	addi	a0,a0,430 # ffffffffc0206ff0 <commands+0x890>
ffffffffc0201e4a:	bcafe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(page_ref(p) == 2);
ffffffffc0201e4e:	00005697          	auipc	a3,0x5
ffffffffc0201e52:	6c268693          	addi	a3,a3,1730 # ffffffffc0207510 <commands+0xdb0>
ffffffffc0201e56:	00005617          	auipc	a2,0x5
ffffffffc0201e5a:	d8a60613          	addi	a2,a2,-630 # ffffffffc0206be0 <commands+0x480>
ffffffffc0201e5e:	23600593          	li	a1,566
ffffffffc0201e62:	00005517          	auipc	a0,0x5
ffffffffc0201e66:	18e50513          	addi	a0,a0,398 # ffffffffc0206ff0 <commands+0x890>
ffffffffc0201e6a:	baafe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0201e6e:	00005697          	auipc	a3,0x5
ffffffffc0201e72:	66268693          	addi	a3,a3,1634 # ffffffffc02074d0 <commands+0xd70>
ffffffffc0201e76:	00005617          	auipc	a2,0x5
ffffffffc0201e7a:	d6a60613          	addi	a2,a2,-662 # ffffffffc0206be0 <commands+0x480>
ffffffffc0201e7e:	23500593          	li	a1,565
ffffffffc0201e82:	00005517          	auipc	a0,0x5
ffffffffc0201e86:	16e50513          	addi	a0,a0,366 # ffffffffc0206ff0 <commands+0x890>
ffffffffc0201e8a:	b8afe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0201e8e:	00005697          	auipc	a3,0x5
ffffffffc0201e92:	62a68693          	addi	a3,a3,1578 # ffffffffc02074b8 <commands+0xd58>
ffffffffc0201e96:	00005617          	auipc	a2,0x5
ffffffffc0201e9a:	d4a60613          	addi	a2,a2,-694 # ffffffffc0206be0 <commands+0x480>
ffffffffc0201e9e:	23400593          	li	a1,564
ffffffffc0201ea2:	00005517          	auipc	a0,0x5
ffffffffc0201ea6:	14e50513          	addi	a0,a0,334 # ffffffffc0206ff0 <commands+0x890>
ffffffffc0201eaa:	b6afe0ef          	jal	ra,ffffffffc0200214 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0201eae:	86be                	mv	a3,a5
ffffffffc0201eb0:	00005617          	auipc	a2,0x5
ffffffffc0201eb4:	11860613          	addi	a2,a2,280 # ffffffffc0206fc8 <commands+0x868>
ffffffffc0201eb8:	1fa00593          	li	a1,506
ffffffffc0201ebc:	00005517          	auipc	a0,0x5
ffffffffc0201ec0:	13450513          	addi	a0,a0,308 # ffffffffc0206ff0 <commands+0x890>
ffffffffc0201ec4:	b50fe0ef          	jal	ra,ffffffffc0200214 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201ec8:	00005617          	auipc	a2,0x5
ffffffffc0201ecc:	1d860613          	addi	a2,a2,472 # ffffffffc02070a0 <commands+0x940>
ffffffffc0201ed0:	07f00593          	li	a1,127
ffffffffc0201ed4:	00005517          	auipc	a0,0x5
ffffffffc0201ed8:	11c50513          	addi	a0,a0,284 # ffffffffc0206ff0 <commands+0x890>
ffffffffc0201edc:	b38fe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0201ee0:	00005697          	auipc	a3,0x5
ffffffffc0201ee4:	66068693          	addi	a3,a3,1632 # ffffffffc0207540 <commands+0xde0>
ffffffffc0201ee8:	00005617          	auipc	a2,0x5
ffffffffc0201eec:	cf860613          	addi	a2,a2,-776 # ffffffffc0206be0 <commands+0x480>
ffffffffc0201ef0:	23a00593          	li	a1,570
ffffffffc0201ef4:	00005517          	auipc	a0,0x5
ffffffffc0201ef8:	0fc50513          	addi	a0,a0,252 # ffffffffc0206ff0 <commands+0x890>
ffffffffc0201efc:	b18fe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0201f00:	00005697          	auipc	a3,0x5
ffffffffc0201f04:	4d068693          	addi	a3,a3,1232 # ffffffffc02073d0 <commands+0xc70>
ffffffffc0201f08:	00005617          	auipc	a2,0x5
ffffffffc0201f0c:	cd860613          	addi	a2,a2,-808 # ffffffffc0206be0 <commands+0x480>
ffffffffc0201f10:	24600593          	li	a1,582
ffffffffc0201f14:	00005517          	auipc	a0,0x5
ffffffffc0201f18:	0dc50513          	addi	a0,a0,220 # ffffffffc0206ff0 <commands+0x890>
ffffffffc0201f1c:	af8fe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0201f20:	00005697          	auipc	a3,0x5
ffffffffc0201f24:	30068693          	addi	a3,a3,768 # ffffffffc0207220 <commands+0xac0>
ffffffffc0201f28:	00005617          	auipc	a2,0x5
ffffffffc0201f2c:	cb860613          	addi	a2,a2,-840 # ffffffffc0206be0 <commands+0x480>
ffffffffc0201f30:	1f800593          	li	a1,504
ffffffffc0201f34:	00005517          	auipc	a0,0x5
ffffffffc0201f38:	0bc50513          	addi	a0,a0,188 # ffffffffc0206ff0 <commands+0x890>
ffffffffc0201f3c:	ad8fe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0201f40:	00005697          	auipc	a3,0x5
ffffffffc0201f44:	2c868693          	addi	a3,a3,712 # ffffffffc0207208 <commands+0xaa8>
ffffffffc0201f48:	00005617          	auipc	a2,0x5
ffffffffc0201f4c:	c9860613          	addi	a2,a2,-872 # ffffffffc0206be0 <commands+0x480>
ffffffffc0201f50:	1f700593          	li	a1,503
ffffffffc0201f54:	00005517          	auipc	a0,0x5
ffffffffc0201f58:	09c50513          	addi	a0,a0,156 # ffffffffc0206ff0 <commands+0x890>
ffffffffc0201f5c:	ab8fe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0201f60:	00005697          	auipc	a3,0x5
ffffffffc0201f64:	1f868693          	addi	a3,a3,504 # ffffffffc0207158 <commands+0x9f8>
ffffffffc0201f68:	00005617          	auipc	a2,0x5
ffffffffc0201f6c:	c7860613          	addi	a2,a2,-904 # ffffffffc0206be0 <commands+0x480>
ffffffffc0201f70:	1ef00593          	li	a1,495
ffffffffc0201f74:	00005517          	auipc	a0,0x5
ffffffffc0201f78:	07c50513          	addi	a0,a0,124 # ffffffffc0206ff0 <commands+0x890>
ffffffffc0201f7c:	a98fe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0201f80:	00005697          	auipc	a3,0x5
ffffffffc0201f84:	23068693          	addi	a3,a3,560 # ffffffffc02071b0 <commands+0xa50>
ffffffffc0201f88:	00005617          	auipc	a2,0x5
ffffffffc0201f8c:	c5860613          	addi	a2,a2,-936 # ffffffffc0206be0 <commands+0x480>
ffffffffc0201f90:	1f600593          	li	a1,502
ffffffffc0201f94:	00005517          	auipc	a0,0x5
ffffffffc0201f98:	05c50513          	addi	a0,a0,92 # ffffffffc0206ff0 <commands+0x890>
ffffffffc0201f9c:	a78fe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0201fa0:	00005697          	auipc	a3,0x5
ffffffffc0201fa4:	1e068693          	addi	a3,a3,480 # ffffffffc0207180 <commands+0xa20>
ffffffffc0201fa8:	00005617          	auipc	a2,0x5
ffffffffc0201fac:	c3860613          	addi	a2,a2,-968 # ffffffffc0206be0 <commands+0x480>
ffffffffc0201fb0:	1f300593          	li	a1,499
ffffffffc0201fb4:	00005517          	auipc	a0,0x5
ffffffffc0201fb8:	03c50513          	addi	a0,a0,60 # ffffffffc0206ff0 <commands+0x890>
ffffffffc0201fbc:	a58fe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0201fc0:	00005697          	auipc	a3,0x5
ffffffffc0201fc4:	3a068693          	addi	a3,a3,928 # ffffffffc0207360 <commands+0xc00>
ffffffffc0201fc8:	00005617          	auipc	a2,0x5
ffffffffc0201fcc:	c1860613          	addi	a2,a2,-1000 # ffffffffc0206be0 <commands+0x480>
ffffffffc0201fd0:	20f00593          	li	a1,527
ffffffffc0201fd4:	00005517          	auipc	a0,0x5
ffffffffc0201fd8:	01c50513          	addi	a0,a0,28 # ffffffffc0206ff0 <commands+0x890>
ffffffffc0201fdc:	a38fe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0201fe0:	00005697          	auipc	a3,0x5
ffffffffc0201fe4:	24068693          	addi	a3,a3,576 # ffffffffc0207220 <commands+0xac0>
ffffffffc0201fe8:	00005617          	auipc	a2,0x5
ffffffffc0201fec:	bf860613          	addi	a2,a2,-1032 # ffffffffc0206be0 <commands+0x480>
ffffffffc0201ff0:	20e00593          	li	a1,526
ffffffffc0201ff4:	00005517          	auipc	a0,0x5
ffffffffc0201ff8:	ffc50513          	addi	a0,a0,-4 # ffffffffc0206ff0 <commands+0x890>
ffffffffc0201ffc:	a18fe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc0202000:	00005697          	auipc	a3,0x5
ffffffffc0202004:	37868693          	addi	a3,a3,888 # ffffffffc0207378 <commands+0xc18>
ffffffffc0202008:	00005617          	auipc	a2,0x5
ffffffffc020200c:	bd860613          	addi	a2,a2,-1064 # ffffffffc0206be0 <commands+0x480>
ffffffffc0202010:	20b00593          	li	a1,523
ffffffffc0202014:	00005517          	auipc	a0,0x5
ffffffffc0202018:	fdc50513          	addi	a0,a0,-36 # ffffffffc0206ff0 <commands+0x890>
ffffffffc020201c:	9f8fe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202020:	00005697          	auipc	a3,0x5
ffffffffc0202024:	55868693          	addi	a3,a3,1368 # ffffffffc0207578 <commands+0xe18>
ffffffffc0202028:	00005617          	auipc	a2,0x5
ffffffffc020202c:	bb860613          	addi	a2,a2,-1096 # ffffffffc0206be0 <commands+0x480>
ffffffffc0202030:	23d00593          	li	a1,573
ffffffffc0202034:	00005517          	auipc	a0,0x5
ffffffffc0202038:	fbc50513          	addi	a0,a0,-68 # ffffffffc0206ff0 <commands+0x890>
ffffffffc020203c:	9d8fe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0202040:	00005697          	auipc	a3,0x5
ffffffffc0202044:	39068693          	addi	a3,a3,912 # ffffffffc02073d0 <commands+0xc70>
ffffffffc0202048:	00005617          	auipc	a2,0x5
ffffffffc020204c:	b9860613          	addi	a2,a2,-1128 # ffffffffc0206be0 <commands+0x480>
ffffffffc0202050:	21d00593          	li	a1,541
ffffffffc0202054:	00005517          	auipc	a0,0x5
ffffffffc0202058:	f9c50513          	addi	a0,a0,-100 # ffffffffc0206ff0 <commands+0x890>
ffffffffc020205c:	9b8fe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc0202060:	00005697          	auipc	a3,0x5
ffffffffc0202064:	40868693          	addi	a3,a3,1032 # ffffffffc0207468 <commands+0xd08>
ffffffffc0202068:	00005617          	auipc	a2,0x5
ffffffffc020206c:	b7860613          	addi	a2,a2,-1160 # ffffffffc0206be0 <commands+0x480>
ffffffffc0202070:	22f00593          	li	a1,559
ffffffffc0202074:	00005517          	auipc	a0,0x5
ffffffffc0202078:	f7c50513          	addi	a0,a0,-132 # ffffffffc0206ff0 <commands+0x890>
ffffffffc020207c:	998fe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0202080:	00005697          	auipc	a3,0x5
ffffffffc0202084:	08068693          	addi	a3,a3,128 # ffffffffc0207100 <commands+0x9a0>
ffffffffc0202088:	00005617          	auipc	a2,0x5
ffffffffc020208c:	b5860613          	addi	a2,a2,-1192 # ffffffffc0206be0 <commands+0x480>
ffffffffc0202090:	1ed00593          	li	a1,493
ffffffffc0202094:	00005517          	auipc	a0,0x5
ffffffffc0202098:	f5c50513          	addi	a0,a0,-164 # ffffffffc0206ff0 <commands+0x890>
ffffffffc020209c:	978fe0ef          	jal	ra,ffffffffc0200214 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc02020a0:	00005617          	auipc	a2,0x5
ffffffffc02020a4:	00060613          	mv	a2,a2
ffffffffc02020a8:	0c100593          	li	a1,193
ffffffffc02020ac:	00005517          	auipc	a0,0x5
ffffffffc02020b0:	f4450513          	addi	a0,a0,-188 # ffffffffc0206ff0 <commands+0x890>
ffffffffc02020b4:	960fe0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc02020b8 <copy_range>:
               bool share) {
ffffffffc02020b8:	7159                	addi	sp,sp,-112
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02020ba:	00d667b3          	or	a5,a2,a3
               bool share) {
ffffffffc02020be:	f486                	sd	ra,104(sp)
ffffffffc02020c0:	f0a2                	sd	s0,96(sp)
ffffffffc02020c2:	eca6                	sd	s1,88(sp)
ffffffffc02020c4:	e8ca                	sd	s2,80(sp)
ffffffffc02020c6:	e4ce                	sd	s3,72(sp)
ffffffffc02020c8:	e0d2                	sd	s4,64(sp)
ffffffffc02020ca:	fc56                	sd	s5,56(sp)
ffffffffc02020cc:	f85a                	sd	s6,48(sp)
ffffffffc02020ce:	f45e                	sd	s7,40(sp)
ffffffffc02020d0:	f062                	sd	s8,32(sp)
ffffffffc02020d2:	ec66                	sd	s9,24(sp)
ffffffffc02020d4:	e86a                	sd	s10,16(sp)
ffffffffc02020d6:	e46e                	sd	s11,8(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02020d8:	03479713          	slli	a4,a5,0x34
ffffffffc02020dc:	1e071863          	bnez	a4,ffffffffc02022cc <copy_range+0x214>
    assert(USER_ACCESS(start, end));
ffffffffc02020e0:	002007b7          	lui	a5,0x200
ffffffffc02020e4:	8432                	mv	s0,a2
ffffffffc02020e6:	16f66b63          	bltu	a2,a5,ffffffffc020225c <copy_range+0x1a4>
ffffffffc02020ea:	84b6                	mv	s1,a3
ffffffffc02020ec:	16d67863          	bgeu	a2,a3,ffffffffc020225c <copy_range+0x1a4>
ffffffffc02020f0:	4785                	li	a5,1
ffffffffc02020f2:	07fe                	slli	a5,a5,0x1f
ffffffffc02020f4:	16d7e463          	bltu	a5,a3,ffffffffc020225c <copy_range+0x1a4>
ffffffffc02020f8:	5a7d                	li	s4,-1
ffffffffc02020fa:	8aaa                	mv	s5,a0
ffffffffc02020fc:	892e                	mv	s2,a1
        start += PGSIZE;
ffffffffc02020fe:	6985                	lui	s3,0x1
    if (PPN(pa) >= npage) {
ffffffffc0202100:	000aac17          	auipc	s8,0xaa
ffffffffc0202104:	760c0c13          	addi	s8,s8,1888 # ffffffffc02ac860 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0202108:	000aab97          	auipc	s7,0xaa
ffffffffc020210c:	7c0b8b93          	addi	s7,s7,1984 # ffffffffc02ac8c8 <pages>
    return page - pages + nbase;
ffffffffc0202110:	00080b37          	lui	s6,0x80
    return KADDR(page2pa(page));
ffffffffc0202114:	00ca5a13          	srli	s4,s4,0xc
        pte_t *ptep = get_pte(from, start, 0), *nptep;
ffffffffc0202118:	4601                	li	a2,0
ffffffffc020211a:	85a2                	mv	a1,s0
ffffffffc020211c:	854a                	mv	a0,s2
ffffffffc020211e:	e4bfe0ef          	jal	ra,ffffffffc0200f68 <get_pte>
ffffffffc0202122:	8caa                	mv	s9,a0
        if (ptep == NULL) {
ffffffffc0202124:	c17d                	beqz	a0,ffffffffc020220a <copy_range+0x152>
        if (*ptep & PTE_V) {
ffffffffc0202126:	611c                	ld	a5,0(a0)
ffffffffc0202128:	8b85                	andi	a5,a5,1
ffffffffc020212a:	e785                	bnez	a5,ffffffffc0202152 <copy_range+0x9a>
        start += PGSIZE;
ffffffffc020212c:	944e                	add	s0,s0,s3
    } while (start != 0 && start < end);
ffffffffc020212e:	fe9465e3          	bltu	s0,s1,ffffffffc0202118 <copy_range+0x60>
    return 0;
ffffffffc0202132:	4501                	li	a0,0
}
ffffffffc0202134:	70a6                	ld	ra,104(sp)
ffffffffc0202136:	7406                	ld	s0,96(sp)
ffffffffc0202138:	64e6                	ld	s1,88(sp)
ffffffffc020213a:	6946                	ld	s2,80(sp)
ffffffffc020213c:	69a6                	ld	s3,72(sp)
ffffffffc020213e:	6a06                	ld	s4,64(sp)
ffffffffc0202140:	7ae2                	ld	s5,56(sp)
ffffffffc0202142:	7b42                	ld	s6,48(sp)
ffffffffc0202144:	7ba2                	ld	s7,40(sp)
ffffffffc0202146:	7c02                	ld	s8,32(sp)
ffffffffc0202148:	6ce2                	ld	s9,24(sp)
ffffffffc020214a:	6d42                	ld	s10,16(sp)
ffffffffc020214c:	6da2                	ld	s11,8(sp)
ffffffffc020214e:	6165                	addi	sp,sp,112
ffffffffc0202150:	8082                	ret
            if ((nptep = get_pte(to, start, 1)) == NULL) {
ffffffffc0202152:	4605                	li	a2,1
ffffffffc0202154:	85a2                	mv	a1,s0
ffffffffc0202156:	8556                	mv	a0,s5
ffffffffc0202158:	e11fe0ef          	jal	ra,ffffffffc0200f68 <get_pte>
ffffffffc020215c:	c169                	beqz	a0,ffffffffc020221e <copy_range+0x166>
            uint32_t perm = (*ptep & PTE_USER);
ffffffffc020215e:	000cb783          	ld	a5,0(s9)
    if (!(pte & PTE_V)) {
ffffffffc0202162:	0017f713          	andi	a4,a5,1
ffffffffc0202166:	01f7fc93          	andi	s9,a5,31
ffffffffc020216a:	14070563          	beqz	a4,ffffffffc02022b4 <copy_range+0x1fc>
    if (PPN(pa) >= npage) {
ffffffffc020216e:	000c3683          	ld	a3,0(s8)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202172:	078a                	slli	a5,a5,0x2
ffffffffc0202174:	00c7d713          	srli	a4,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202178:	12d77263          	bgeu	a4,a3,ffffffffc020229c <copy_range+0x1e4>
    return &pages[PPN(pa) - nbase];
ffffffffc020217c:	000bb783          	ld	a5,0(s7)
ffffffffc0202180:	fff806b7          	lui	a3,0xfff80
ffffffffc0202184:	9736                	add	a4,a4,a3
ffffffffc0202186:	071a                	slli	a4,a4,0x6
            struct Page *npage = alloc_page();
ffffffffc0202188:	4505                	li	a0,1
ffffffffc020218a:	00e78db3          	add	s11,a5,a4
ffffffffc020218e:	ccdfe0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0202192:	8d2a                	mv	s10,a0
            assert(page != NULL);
ffffffffc0202194:	0a0d8463          	beqz	s11,ffffffffc020223c <copy_range+0x184>
            assert(npage != NULL);
ffffffffc0202198:	c175                	beqz	a0,ffffffffc020227c <copy_range+0x1c4>
    return page - pages + nbase;
ffffffffc020219a:	000bb703          	ld	a4,0(s7)
    return KADDR(page2pa(page));
ffffffffc020219e:	000c3603          	ld	a2,0(s8)
    return page - pages + nbase;
ffffffffc02021a2:	40ed86b3          	sub	a3,s11,a4
ffffffffc02021a6:	8699                	srai	a3,a3,0x6
ffffffffc02021a8:	96da                	add	a3,a3,s6
    return KADDR(page2pa(page));
ffffffffc02021aa:	0146f7b3          	and	a5,a3,s4
    return page2ppn(page) << PGSHIFT;
ffffffffc02021ae:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02021b0:	06c7fa63          	bgeu	a5,a2,ffffffffc0202224 <copy_range+0x16c>
    return page - pages + nbase;
ffffffffc02021b4:	40e507b3          	sub	a5,a0,a4
    return KADDR(page2pa(page));
ffffffffc02021b8:	000aa717          	auipc	a4,0xaa
ffffffffc02021bc:	70070713          	addi	a4,a4,1792 # ffffffffc02ac8b8 <va_pa_offset>
ffffffffc02021c0:	6308                	ld	a0,0(a4)
    return page - pages + nbase;
ffffffffc02021c2:	8799                	srai	a5,a5,0x6
ffffffffc02021c4:	97da                	add	a5,a5,s6
    return KADDR(page2pa(page));
ffffffffc02021c6:	0147f733          	and	a4,a5,s4
ffffffffc02021ca:	00a685b3          	add	a1,a3,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc02021ce:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc02021d0:	04c77963          	bgeu	a4,a2,ffffffffc0202222 <copy_range+0x16a>
            memcpy(kva_dst, kva_src, PGSIZE);
ffffffffc02021d4:	6605                	lui	a2,0x1
ffffffffc02021d6:	953e                	add	a0,a0,a5
ffffffffc02021d8:	7fb030ef          	jal	ra,ffffffffc02061d2 <memcpy>
            ret = page_insert(to, npage, start, perm);
ffffffffc02021dc:	86e6                	mv	a3,s9
ffffffffc02021de:	8622                	mv	a2,s0
ffffffffc02021e0:	85ea                	mv	a1,s10
ffffffffc02021e2:	8556                	mv	a0,s5
ffffffffc02021e4:	b90ff0ef          	jal	ra,ffffffffc0201574 <page_insert>
            assert(ret == 0);
ffffffffc02021e8:	d131                	beqz	a0,ffffffffc020212c <copy_range+0x74>
ffffffffc02021ea:	00005697          	auipc	a3,0x5
ffffffffc02021ee:	dce68693          	addi	a3,a3,-562 # ffffffffc0206fb8 <commands+0x858>
ffffffffc02021f2:	00005617          	auipc	a2,0x5
ffffffffc02021f6:	9ee60613          	addi	a2,a2,-1554 # ffffffffc0206be0 <commands+0x480>
ffffffffc02021fa:	18f00593          	li	a1,399
ffffffffc02021fe:	00005517          	auipc	a0,0x5
ffffffffc0202202:	df250513          	addi	a0,a0,-526 # ffffffffc0206ff0 <commands+0x890>
ffffffffc0202206:	80efe0ef          	jal	ra,ffffffffc0200214 <__panic>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc020220a:	002007b7          	lui	a5,0x200
ffffffffc020220e:	943e                	add	s0,s0,a5
ffffffffc0202210:	ffe007b7          	lui	a5,0xffe00
ffffffffc0202214:	8c7d                	and	s0,s0,a5
    } while (start != 0 && start < end);
ffffffffc0202216:	dc11                	beqz	s0,ffffffffc0202132 <copy_range+0x7a>
ffffffffc0202218:	f09460e3          	bltu	s0,s1,ffffffffc0202118 <copy_range+0x60>
ffffffffc020221c:	bf19                	j	ffffffffc0202132 <copy_range+0x7a>
                return -E_NO_MEM;
ffffffffc020221e:	5571                	li	a0,-4
ffffffffc0202220:	bf11                	j	ffffffffc0202134 <copy_range+0x7c>
ffffffffc0202222:	86be                	mv	a3,a5
ffffffffc0202224:	00005617          	auipc	a2,0x5
ffffffffc0202228:	da460613          	addi	a2,a2,-604 # ffffffffc0206fc8 <commands+0x868>
ffffffffc020222c:	06900593          	li	a1,105
ffffffffc0202230:	00005517          	auipc	a0,0x5
ffffffffc0202234:	df050513          	addi	a0,a0,-528 # ffffffffc0207020 <commands+0x8c0>
ffffffffc0202238:	fddfd0ef          	jal	ra,ffffffffc0200214 <__panic>
            assert(page != NULL);
ffffffffc020223c:	00005697          	auipc	a3,0x5
ffffffffc0202240:	d5c68693          	addi	a3,a3,-676 # ffffffffc0206f98 <commands+0x838>
ffffffffc0202244:	00005617          	auipc	a2,0x5
ffffffffc0202248:	99c60613          	addi	a2,a2,-1636 # ffffffffc0206be0 <commands+0x480>
ffffffffc020224c:	17200593          	li	a1,370
ffffffffc0202250:	00005517          	auipc	a0,0x5
ffffffffc0202254:	da050513          	addi	a0,a0,-608 # ffffffffc0206ff0 <commands+0x890>
ffffffffc0202258:	fbdfd0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc020225c:	00005697          	auipc	a3,0x5
ffffffffc0202260:	39468693          	addi	a3,a3,916 # ffffffffc02075f0 <commands+0xe90>
ffffffffc0202264:	00005617          	auipc	a2,0x5
ffffffffc0202268:	97c60613          	addi	a2,a2,-1668 # ffffffffc0206be0 <commands+0x480>
ffffffffc020226c:	15e00593          	li	a1,350
ffffffffc0202270:	00005517          	auipc	a0,0x5
ffffffffc0202274:	d8050513          	addi	a0,a0,-640 # ffffffffc0206ff0 <commands+0x890>
ffffffffc0202278:	f9dfd0ef          	jal	ra,ffffffffc0200214 <__panic>
            assert(npage != NULL);
ffffffffc020227c:	00005697          	auipc	a3,0x5
ffffffffc0202280:	d2c68693          	addi	a3,a3,-724 # ffffffffc0206fa8 <commands+0x848>
ffffffffc0202284:	00005617          	auipc	a2,0x5
ffffffffc0202288:	95c60613          	addi	a2,a2,-1700 # ffffffffc0206be0 <commands+0x480>
ffffffffc020228c:	17300593          	li	a1,371
ffffffffc0202290:	00005517          	auipc	a0,0x5
ffffffffc0202294:	d6050513          	addi	a0,a0,-672 # ffffffffc0206ff0 <commands+0x890>
ffffffffc0202298:	f7dfd0ef          	jal	ra,ffffffffc0200214 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020229c:	00005617          	auipc	a2,0x5
ffffffffc02022a0:	d6460613          	addi	a2,a2,-668 # ffffffffc0207000 <commands+0x8a0>
ffffffffc02022a4:	06200593          	li	a1,98
ffffffffc02022a8:	00005517          	auipc	a0,0x5
ffffffffc02022ac:	d7850513          	addi	a0,a0,-648 # ffffffffc0207020 <commands+0x8c0>
ffffffffc02022b0:	f65fd0ef          	jal	ra,ffffffffc0200214 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc02022b4:	00005617          	auipc	a2,0x5
ffffffffc02022b8:	f2c60613          	addi	a2,a2,-212 # ffffffffc02071e0 <commands+0xa80>
ffffffffc02022bc:	07400593          	li	a1,116
ffffffffc02022c0:	00005517          	auipc	a0,0x5
ffffffffc02022c4:	d6050513          	addi	a0,a0,-672 # ffffffffc0207020 <commands+0x8c0>
ffffffffc02022c8:	f4dfd0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02022cc:	00005697          	auipc	a3,0x5
ffffffffc02022d0:	2f468693          	addi	a3,a3,756 # ffffffffc02075c0 <commands+0xe60>
ffffffffc02022d4:	00005617          	auipc	a2,0x5
ffffffffc02022d8:	90c60613          	addi	a2,a2,-1780 # ffffffffc0206be0 <commands+0x480>
ffffffffc02022dc:	15d00593          	li	a1,349
ffffffffc02022e0:	00005517          	auipc	a0,0x5
ffffffffc02022e4:	d1050513          	addi	a0,a0,-752 # ffffffffc0206ff0 <commands+0x890>
ffffffffc02022e8:	f2dfd0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc02022ec <tlb_invalidate>:
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02022ec:	12058073          	sfence.vma	a1
}
ffffffffc02022f0:	8082                	ret

ffffffffc02022f2 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc02022f2:	7179                	addi	sp,sp,-48
ffffffffc02022f4:	e84a                	sd	s2,16(sp)
ffffffffc02022f6:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc02022f8:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc02022fa:	f022                	sd	s0,32(sp)
ffffffffc02022fc:	ec26                	sd	s1,24(sp)
ffffffffc02022fe:	e44e                	sd	s3,8(sp)
ffffffffc0202300:	f406                	sd	ra,40(sp)
ffffffffc0202302:	84ae                	mv	s1,a1
ffffffffc0202304:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc0202306:	b55fe0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc020230a:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc020230c:	cd1d                	beqz	a0,ffffffffc020234a <pgdir_alloc_page+0x58>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc020230e:	85aa                	mv	a1,a0
ffffffffc0202310:	86ce                	mv	a3,s3
ffffffffc0202312:	8626                	mv	a2,s1
ffffffffc0202314:	854a                	mv	a0,s2
ffffffffc0202316:	a5eff0ef          	jal	ra,ffffffffc0201574 <page_insert>
ffffffffc020231a:	e121                	bnez	a0,ffffffffc020235a <pgdir_alloc_page+0x68>
        if (swap_init_ok) {
ffffffffc020231c:	000aa797          	auipc	a5,0xaa
ffffffffc0202320:	55c78793          	addi	a5,a5,1372 # ffffffffc02ac878 <swap_init_ok>
ffffffffc0202324:	439c                	lw	a5,0(a5)
ffffffffc0202326:	2781                	sext.w	a5,a5
ffffffffc0202328:	c38d                	beqz	a5,ffffffffc020234a <pgdir_alloc_page+0x58>
            if (check_mm_struct != NULL) {
ffffffffc020232a:	000aa797          	auipc	a5,0xaa
ffffffffc020232e:	5a678793          	addi	a5,a5,1446 # ffffffffc02ac8d0 <check_mm_struct>
ffffffffc0202332:	6388                	ld	a0,0(a5)
ffffffffc0202334:	c919                	beqz	a0,ffffffffc020234a <pgdir_alloc_page+0x58>
                swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0202336:	4681                	li	a3,0
ffffffffc0202338:	8622                	mv	a2,s0
ffffffffc020233a:	85a6                	mv	a1,s1
ffffffffc020233c:	27c010ef          	jal	ra,ffffffffc02035b8 <swap_map_swappable>
                assert(page_ref(page) == 1);
ffffffffc0202340:	4018                	lw	a4,0(s0)
                page->pra_vaddr = la;
ffffffffc0202342:	fc04                	sd	s1,56(s0)
                assert(page_ref(page) == 1);
ffffffffc0202344:	4785                	li	a5,1
ffffffffc0202346:	02f71063          	bne	a4,a5,ffffffffc0202366 <pgdir_alloc_page+0x74>
}
ffffffffc020234a:	8522                	mv	a0,s0
ffffffffc020234c:	70a2                	ld	ra,40(sp)
ffffffffc020234e:	7402                	ld	s0,32(sp)
ffffffffc0202350:	64e2                	ld	s1,24(sp)
ffffffffc0202352:	6942                	ld	s2,16(sp)
ffffffffc0202354:	69a2                	ld	s3,8(sp)
ffffffffc0202356:	6145                	addi	sp,sp,48
ffffffffc0202358:	8082                	ret
            free_page(page);
ffffffffc020235a:	8522                	mv	a0,s0
ffffffffc020235c:	4585                	li	a1,1
ffffffffc020235e:	b85fe0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
            return NULL;
ffffffffc0202362:	4401                	li	s0,0
ffffffffc0202364:	b7dd                	j	ffffffffc020234a <pgdir_alloc_page+0x58>
                assert(page_ref(page) == 1);
ffffffffc0202366:	00005697          	auipc	a3,0x5
ffffffffc020236a:	cca68693          	addi	a3,a3,-822 # ffffffffc0207030 <commands+0x8d0>
ffffffffc020236e:	00005617          	auipc	a2,0x5
ffffffffc0202372:	87260613          	addi	a2,a2,-1934 # ffffffffc0206be0 <commands+0x480>
ffffffffc0202376:	1ce00593          	li	a1,462
ffffffffc020237a:	00005517          	auipc	a0,0x5
ffffffffc020237e:	c7650513          	addi	a0,a0,-906 # ffffffffc0206ff0 <commands+0x890>
ffffffffc0202382:	e93fd0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0202386 <check_vma_overlap.isra.0.part.1>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0202386:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc0202388:	00005697          	auipc	a3,0x5
ffffffffc020238c:	28068693          	addi	a3,a3,640 # ffffffffc0207608 <commands+0xea8>
ffffffffc0202390:	00005617          	auipc	a2,0x5
ffffffffc0202394:	85060613          	addi	a2,a2,-1968 # ffffffffc0206be0 <commands+0x480>
ffffffffc0202398:	06d00593          	li	a1,109
ffffffffc020239c:	00005517          	auipc	a0,0x5
ffffffffc02023a0:	28c50513          	addi	a0,a0,652 # ffffffffc0207628 <commands+0xec8>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc02023a4:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc02023a6:	e6ffd0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc02023aa <mm_create>:
mm_create(void) {
ffffffffc02023aa:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02023ac:	04000513          	li	a0,64
mm_create(void) {
ffffffffc02023b0:	e022                	sd	s0,0(sp)
ffffffffc02023b2:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02023b4:	642010ef          	jal	ra,ffffffffc02039f6 <kmalloc>
ffffffffc02023b8:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc02023ba:	c515                	beqz	a0,ffffffffc02023e6 <mm_create+0x3c>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02023bc:	000aa797          	auipc	a5,0xaa
ffffffffc02023c0:	4bc78793          	addi	a5,a5,1212 # ffffffffc02ac878 <swap_init_ok>
ffffffffc02023c4:	439c                	lw	a5,0(a5)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc02023c6:	e408                	sd	a0,8(s0)
ffffffffc02023c8:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc02023ca:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc02023ce:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc02023d2:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02023d6:	2781                	sext.w	a5,a5
ffffffffc02023d8:	ef81                	bnez	a5,ffffffffc02023f0 <mm_create+0x46>
        else mm->sm_priv = NULL;
ffffffffc02023da:	02053423          	sd	zero,40(a0)
    return mm->mm_count;
}

static inline void
set_mm_count(struct mm_struct *mm, int val) {
    mm->mm_count = val;
ffffffffc02023de:	02042823          	sw	zero,48(s0)

typedef volatile bool lock_t;

static inline void
lock_init(lock_t *lock) {
    *lock = 0;
ffffffffc02023e2:	02043c23          	sd	zero,56(s0)
}
ffffffffc02023e6:	8522                	mv	a0,s0
ffffffffc02023e8:	60a2                	ld	ra,8(sp)
ffffffffc02023ea:	6402                	ld	s0,0(sp)
ffffffffc02023ec:	0141                	addi	sp,sp,16
ffffffffc02023ee:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02023f0:	1b8010ef          	jal	ra,ffffffffc02035a8 <swap_init_mm>
ffffffffc02023f4:	b7ed                	j	ffffffffc02023de <mm_create+0x34>

ffffffffc02023f6 <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc02023f6:	1101                	addi	sp,sp,-32
ffffffffc02023f8:	e04a                	sd	s2,0(sp)
ffffffffc02023fa:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02023fc:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc0202400:	e822                	sd	s0,16(sp)
ffffffffc0202402:	e426                	sd	s1,8(sp)
ffffffffc0202404:	ec06                	sd	ra,24(sp)
ffffffffc0202406:	84ae                	mv	s1,a1
ffffffffc0202408:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020240a:	5ec010ef          	jal	ra,ffffffffc02039f6 <kmalloc>
    if (vma != NULL) {
ffffffffc020240e:	c509                	beqz	a0,ffffffffc0202418 <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc0202410:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc0202414:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0202416:	cd00                	sw	s0,24(a0)
}
ffffffffc0202418:	60e2                	ld	ra,24(sp)
ffffffffc020241a:	6442                	ld	s0,16(sp)
ffffffffc020241c:	64a2                	ld	s1,8(sp)
ffffffffc020241e:	6902                	ld	s2,0(sp)
ffffffffc0202420:	6105                	addi	sp,sp,32
ffffffffc0202422:	8082                	ret

ffffffffc0202424 <find_vma>:
    if (mm != NULL) {
ffffffffc0202424:	c51d                	beqz	a0,ffffffffc0202452 <find_vma+0x2e>
        vma = mm->mmap_cache;
ffffffffc0202426:	691c                	ld	a5,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0202428:	c781                	beqz	a5,ffffffffc0202430 <find_vma+0xc>
ffffffffc020242a:	6798                	ld	a4,8(a5)
ffffffffc020242c:	02e5f663          	bgeu	a1,a4,ffffffffc0202458 <find_vma+0x34>
                list_entry_t *list = &(mm->mmap_list), *le = list;
ffffffffc0202430:	87aa                	mv	a5,a0
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0202432:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc0202434:	00f50f63          	beq	a0,a5,ffffffffc0202452 <find_vma+0x2e>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc0202438:	fe87b703          	ld	a4,-24(a5)
ffffffffc020243c:	fee5ebe3          	bltu	a1,a4,ffffffffc0202432 <find_vma+0xe>
ffffffffc0202440:	ff07b703          	ld	a4,-16(a5)
ffffffffc0202444:	fee5f7e3          	bgeu	a1,a4,ffffffffc0202432 <find_vma+0xe>
                    vma = le2vma(le, list_link);
ffffffffc0202448:	1781                	addi	a5,a5,-32
        if (vma != NULL) {
ffffffffc020244a:	c781                	beqz	a5,ffffffffc0202452 <find_vma+0x2e>
            mm->mmap_cache = vma;
ffffffffc020244c:	e91c                	sd	a5,16(a0)
}
ffffffffc020244e:	853e                	mv	a0,a5
ffffffffc0202450:	8082                	ret
    struct vma_struct *vma = NULL;
ffffffffc0202452:	4781                	li	a5,0
}
ffffffffc0202454:	853e                	mv	a0,a5
ffffffffc0202456:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0202458:	6b98                	ld	a4,16(a5)
ffffffffc020245a:	fce5fbe3          	bgeu	a1,a4,ffffffffc0202430 <find_vma+0xc>
            mm->mmap_cache = vma;
ffffffffc020245e:	e91c                	sd	a5,16(a0)
    return vma;
ffffffffc0202460:	b7fd                	j	ffffffffc020244e <find_vma+0x2a>

ffffffffc0202462 <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc0202462:	6590                	ld	a2,8(a1)
ffffffffc0202464:	0105b803          	ld	a6,16(a1)
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc0202468:	1141                	addi	sp,sp,-16
ffffffffc020246a:	e406                	sd	ra,8(sp)
ffffffffc020246c:	872a                	mv	a4,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc020246e:	01066863          	bltu	a2,a6,ffffffffc020247e <insert_vma_struct+0x1c>
ffffffffc0202472:	a8b9                	j	ffffffffc02024d0 <insert_vma_struct+0x6e>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0202474:	fe87b683          	ld	a3,-24(a5)
ffffffffc0202478:	04d66763          	bltu	a2,a3,ffffffffc02024c6 <insert_vma_struct+0x64>
ffffffffc020247c:	873e                	mv	a4,a5
ffffffffc020247e:	671c                	ld	a5,8(a4)
        while ((le = list_next(le)) != list) {
ffffffffc0202480:	fef51ae3          	bne	a0,a5,ffffffffc0202474 <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc0202484:	02a70463          	beq	a4,a0,ffffffffc02024ac <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0202488:	ff073683          	ld	a3,-16(a4)
    assert(prev->vm_start < prev->vm_end);
ffffffffc020248c:	fe873883          	ld	a7,-24(a4)
ffffffffc0202490:	08d8f063          	bgeu	a7,a3,ffffffffc0202510 <insert_vma_struct+0xae>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0202494:	04d66e63          	bltu	a2,a3,ffffffffc02024f0 <insert_vma_struct+0x8e>
    }
    if (le_next != list) {
ffffffffc0202498:	00f50a63          	beq	a0,a5,ffffffffc02024ac <insert_vma_struct+0x4a>
ffffffffc020249c:	fe87b683          	ld	a3,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc02024a0:	0506e863          	bltu	a3,a6,ffffffffc02024f0 <insert_vma_struct+0x8e>
    assert(next->vm_start < next->vm_end);
ffffffffc02024a4:	ff07b603          	ld	a2,-16(a5)
ffffffffc02024a8:	02c6f263          	bgeu	a3,a2,ffffffffc02024cc <insert_vma_struct+0x6a>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc02024ac:	5114                	lw	a3,32(a0)
    vma->vm_mm = mm;
ffffffffc02024ae:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc02024b0:	02058613          	addi	a2,a1,32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc02024b4:	e390                	sd	a2,0(a5)
ffffffffc02024b6:	e710                	sd	a2,8(a4)
}
ffffffffc02024b8:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc02024ba:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc02024bc:	f198                	sd	a4,32(a1)
    mm->map_count ++;
ffffffffc02024be:	2685                	addiw	a3,a3,1
ffffffffc02024c0:	d114                	sw	a3,32(a0)
}
ffffffffc02024c2:	0141                	addi	sp,sp,16
ffffffffc02024c4:	8082                	ret
    if (le_prev != list) {
ffffffffc02024c6:	fca711e3          	bne	a4,a0,ffffffffc0202488 <insert_vma_struct+0x26>
ffffffffc02024ca:	bfd9                	j	ffffffffc02024a0 <insert_vma_struct+0x3e>
ffffffffc02024cc:	ebbff0ef          	jal	ra,ffffffffc0202386 <check_vma_overlap.isra.0.part.1>
    assert(vma->vm_start < vma->vm_end);
ffffffffc02024d0:	00005697          	auipc	a3,0x5
ffffffffc02024d4:	26868693          	addi	a3,a3,616 # ffffffffc0207738 <commands+0xfd8>
ffffffffc02024d8:	00004617          	auipc	a2,0x4
ffffffffc02024dc:	70860613          	addi	a2,a2,1800 # ffffffffc0206be0 <commands+0x480>
ffffffffc02024e0:	07400593          	li	a1,116
ffffffffc02024e4:	00005517          	auipc	a0,0x5
ffffffffc02024e8:	14450513          	addi	a0,a0,324 # ffffffffc0207628 <commands+0xec8>
ffffffffc02024ec:	d29fd0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02024f0:	00005697          	auipc	a3,0x5
ffffffffc02024f4:	28868693          	addi	a3,a3,648 # ffffffffc0207778 <commands+0x1018>
ffffffffc02024f8:	00004617          	auipc	a2,0x4
ffffffffc02024fc:	6e860613          	addi	a2,a2,1768 # ffffffffc0206be0 <commands+0x480>
ffffffffc0202500:	06c00593          	li	a1,108
ffffffffc0202504:	00005517          	auipc	a0,0x5
ffffffffc0202508:	12450513          	addi	a0,a0,292 # ffffffffc0207628 <commands+0xec8>
ffffffffc020250c:	d09fd0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0202510:	00005697          	auipc	a3,0x5
ffffffffc0202514:	24868693          	addi	a3,a3,584 # ffffffffc0207758 <commands+0xff8>
ffffffffc0202518:	00004617          	auipc	a2,0x4
ffffffffc020251c:	6c860613          	addi	a2,a2,1736 # ffffffffc0206be0 <commands+0x480>
ffffffffc0202520:	06b00593          	li	a1,107
ffffffffc0202524:	00005517          	auipc	a0,0x5
ffffffffc0202528:	10450513          	addi	a0,a0,260 # ffffffffc0207628 <commands+0xec8>
ffffffffc020252c:	ce9fd0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0202530 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
    assert(mm_count(mm) == 0);
ffffffffc0202530:	591c                	lw	a5,48(a0)
mm_destroy(struct mm_struct *mm) {
ffffffffc0202532:	1141                	addi	sp,sp,-16
ffffffffc0202534:	e406                	sd	ra,8(sp)
ffffffffc0202536:	e022                	sd	s0,0(sp)
    assert(mm_count(mm) == 0);
ffffffffc0202538:	e78d                	bnez	a5,ffffffffc0202562 <mm_destroy+0x32>
ffffffffc020253a:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc020253c:	6508                	ld	a0,8(a0)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc020253e:	00a40c63          	beq	s0,a0,ffffffffc0202556 <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc0202542:	6118                	ld	a4,0(a0)
ffffffffc0202544:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc0202546:	1501                	addi	a0,a0,-32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0202548:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc020254a:	e398                	sd	a4,0(a5)
ffffffffc020254c:	566010ef          	jal	ra,ffffffffc0203ab2 <kfree>
    return listelm->next;
ffffffffc0202550:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0202552:	fea418e3          	bne	s0,a0,ffffffffc0202542 <mm_destroy+0x12>
    }
    kfree(mm); //kfree mm
ffffffffc0202556:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc0202558:	6402                	ld	s0,0(sp)
ffffffffc020255a:	60a2                	ld	ra,8(sp)
ffffffffc020255c:	0141                	addi	sp,sp,16
    kfree(mm); //kfree mm
ffffffffc020255e:	5540106f          	j	ffffffffc0203ab2 <kfree>
    assert(mm_count(mm) == 0);
ffffffffc0202562:	00005697          	auipc	a3,0x5
ffffffffc0202566:	23668693          	addi	a3,a3,566 # ffffffffc0207798 <commands+0x1038>
ffffffffc020256a:	00004617          	auipc	a2,0x4
ffffffffc020256e:	67660613          	addi	a2,a2,1654 # ffffffffc0206be0 <commands+0x480>
ffffffffc0202572:	09400593          	li	a1,148
ffffffffc0202576:	00005517          	auipc	a0,0x5
ffffffffc020257a:	0b250513          	addi	a0,a0,178 # ffffffffc0207628 <commands+0xec8>
ffffffffc020257e:	c97fd0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0202582 <mm_map>:

int
mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
       struct vma_struct **vma_store) {
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0202582:	6785                	lui	a5,0x1
       struct vma_struct **vma_store) {
ffffffffc0202584:	7139                	addi	sp,sp,-64
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0202586:	17fd                	addi	a5,a5,-1
ffffffffc0202588:	787d                	lui	a6,0xfffff
       struct vma_struct **vma_store) {
ffffffffc020258a:	f822                	sd	s0,48(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc020258c:	00f60433          	add	s0,a2,a5
       struct vma_struct **vma_store) {
ffffffffc0202590:	f426                	sd	s1,40(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0202592:	942e                	add	s0,s0,a1
       struct vma_struct **vma_store) {
ffffffffc0202594:	fc06                	sd	ra,56(sp)
ffffffffc0202596:	f04a                	sd	s2,32(sp)
ffffffffc0202598:	ec4e                	sd	s3,24(sp)
ffffffffc020259a:	e852                	sd	s4,16(sp)
ffffffffc020259c:	e456                	sd	s5,8(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc020259e:	0105f4b3          	and	s1,a1,a6
    if (!USER_ACCESS(start, end)) {
ffffffffc02025a2:	002007b7          	lui	a5,0x200
ffffffffc02025a6:	01047433          	and	s0,s0,a6
ffffffffc02025aa:	06f4e363          	bltu	s1,a5,ffffffffc0202610 <mm_map+0x8e>
ffffffffc02025ae:	0684f163          	bgeu	s1,s0,ffffffffc0202610 <mm_map+0x8e>
ffffffffc02025b2:	4785                	li	a5,1
ffffffffc02025b4:	07fe                	slli	a5,a5,0x1f
ffffffffc02025b6:	0487ed63          	bltu	a5,s0,ffffffffc0202610 <mm_map+0x8e>
ffffffffc02025ba:	89aa                	mv	s3,a0
ffffffffc02025bc:	8a3a                	mv	s4,a4
ffffffffc02025be:	8ab6                	mv	s5,a3
        return -E_INVAL;
    }

    assert(mm != NULL);
ffffffffc02025c0:	c931                	beqz	a0,ffffffffc0202614 <mm_map+0x92>

    int ret = -E_INVAL;

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start) {
ffffffffc02025c2:	85a6                	mv	a1,s1
ffffffffc02025c4:	e61ff0ef          	jal	ra,ffffffffc0202424 <find_vma>
ffffffffc02025c8:	c501                	beqz	a0,ffffffffc02025d0 <mm_map+0x4e>
ffffffffc02025ca:	651c                	ld	a5,8(a0)
ffffffffc02025cc:	0487e263          	bltu	a5,s0,ffffffffc0202610 <mm_map+0x8e>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02025d0:	03000513          	li	a0,48
ffffffffc02025d4:	422010ef          	jal	ra,ffffffffc02039f6 <kmalloc>
ffffffffc02025d8:	892a                	mv	s2,a0
        goto out;
    }
    ret = -E_NO_MEM;
ffffffffc02025da:	5571                	li	a0,-4
    if (vma != NULL) {
ffffffffc02025dc:	02090163          	beqz	s2,ffffffffc02025fe <mm_map+0x7c>

    if ((vma = vma_create(start, end, vm_flags)) == NULL) {
        goto out;
    }
    insert_vma_struct(mm, vma);
ffffffffc02025e0:	854e                	mv	a0,s3
        vma->vm_start = vm_start;
ffffffffc02025e2:	00993423          	sd	s1,8(s2)
        vma->vm_end = vm_end;
ffffffffc02025e6:	00893823          	sd	s0,16(s2)
        vma->vm_flags = vm_flags;
ffffffffc02025ea:	01592c23          	sw	s5,24(s2)
    insert_vma_struct(mm, vma);
ffffffffc02025ee:	85ca                	mv	a1,s2
ffffffffc02025f0:	e73ff0ef          	jal	ra,ffffffffc0202462 <insert_vma_struct>
    if (vma_store != NULL) {
        *vma_store = vma;
    }
    ret = 0;
ffffffffc02025f4:	4501                	li	a0,0
    if (vma_store != NULL) {
ffffffffc02025f6:	000a0463          	beqz	s4,ffffffffc02025fe <mm_map+0x7c>
        *vma_store = vma;
ffffffffc02025fa:	012a3023          	sd	s2,0(s4)

out:
    return ret;
}
ffffffffc02025fe:	70e2                	ld	ra,56(sp)
ffffffffc0202600:	7442                	ld	s0,48(sp)
ffffffffc0202602:	74a2                	ld	s1,40(sp)
ffffffffc0202604:	7902                	ld	s2,32(sp)
ffffffffc0202606:	69e2                	ld	s3,24(sp)
ffffffffc0202608:	6a42                	ld	s4,16(sp)
ffffffffc020260a:	6aa2                	ld	s5,8(sp)
ffffffffc020260c:	6121                	addi	sp,sp,64
ffffffffc020260e:	8082                	ret
        return -E_INVAL;
ffffffffc0202610:	5575                	li	a0,-3
ffffffffc0202612:	b7f5                	j	ffffffffc02025fe <mm_map+0x7c>
    assert(mm != NULL);
ffffffffc0202614:	00005697          	auipc	a3,0x5
ffffffffc0202618:	19c68693          	addi	a3,a3,412 # ffffffffc02077b0 <commands+0x1050>
ffffffffc020261c:	00004617          	auipc	a2,0x4
ffffffffc0202620:	5c460613          	addi	a2,a2,1476 # ffffffffc0206be0 <commands+0x480>
ffffffffc0202624:	0a700593          	li	a1,167
ffffffffc0202628:	00005517          	auipc	a0,0x5
ffffffffc020262c:	00050513          	mv	a0,a0
ffffffffc0202630:	be5fd0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0202634 <dup_mmap>:

int
dup_mmap(struct mm_struct *to, struct mm_struct *from) {
ffffffffc0202634:	7139                	addi	sp,sp,-64
ffffffffc0202636:	fc06                	sd	ra,56(sp)
ffffffffc0202638:	f822                	sd	s0,48(sp)
ffffffffc020263a:	f426                	sd	s1,40(sp)
ffffffffc020263c:	f04a                	sd	s2,32(sp)
ffffffffc020263e:	ec4e                	sd	s3,24(sp)
ffffffffc0202640:	e852                	sd	s4,16(sp)
ffffffffc0202642:	e456                	sd	s5,8(sp)
    assert(to != NULL && from != NULL);
ffffffffc0202644:	c535                	beqz	a0,ffffffffc02026b0 <dup_mmap+0x7c>
ffffffffc0202646:	892a                	mv	s2,a0
ffffffffc0202648:	84ae                	mv	s1,a1
    list_entry_t *list = &(from->mmap_list), *le = list;
ffffffffc020264a:	842e                	mv	s0,a1
    assert(to != NULL && from != NULL);
ffffffffc020264c:	e59d                	bnez	a1,ffffffffc020267a <dup_mmap+0x46>
ffffffffc020264e:	a08d                	j	ffffffffc02026b0 <dup_mmap+0x7c>
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
        if (nvma == NULL) {
            return -E_NO_MEM;
        }

        insert_vma_struct(to, nvma);
ffffffffc0202650:	85aa                	mv	a1,a0
        vma->vm_start = vm_start;
ffffffffc0202652:	0157b423          	sd	s5,8(a5) # 200008 <_binary_obj___user_exit_out_size+0x1f5540>
        insert_vma_struct(to, nvma);
ffffffffc0202656:	854a                	mv	a0,s2
        vma->vm_end = vm_end;
ffffffffc0202658:	0147b823          	sd	s4,16(a5)
        vma->vm_flags = vm_flags;
ffffffffc020265c:	0137ac23          	sw	s3,24(a5)
        insert_vma_struct(to, nvma);
ffffffffc0202660:	e03ff0ef          	jal	ra,ffffffffc0202462 <insert_vma_struct>

        bool share = 0;
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0) {
ffffffffc0202664:	ff043683          	ld	a3,-16(s0)
ffffffffc0202668:	fe843603          	ld	a2,-24(s0)
ffffffffc020266c:	6c8c                	ld	a1,24(s1)
ffffffffc020266e:	01893503          	ld	a0,24(s2)
ffffffffc0202672:	4701                	li	a4,0
ffffffffc0202674:	a45ff0ef          	jal	ra,ffffffffc02020b8 <copy_range>
ffffffffc0202678:	e105                	bnez	a0,ffffffffc0202698 <dup_mmap+0x64>
    return listelm->prev;
ffffffffc020267a:	6000                	ld	s0,0(s0)
    while ((le = list_prev(le)) != list) {
ffffffffc020267c:	02848863          	beq	s1,s0,ffffffffc02026ac <dup_mmap+0x78>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0202680:	03000513          	li	a0,48
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
ffffffffc0202684:	fe843a83          	ld	s5,-24(s0)
ffffffffc0202688:	ff043a03          	ld	s4,-16(s0)
ffffffffc020268c:	ff842983          	lw	s3,-8(s0)
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0202690:	366010ef          	jal	ra,ffffffffc02039f6 <kmalloc>
ffffffffc0202694:	87aa                	mv	a5,a0
    if (vma != NULL) {
ffffffffc0202696:	fd4d                	bnez	a0,ffffffffc0202650 <dup_mmap+0x1c>
            return -E_NO_MEM;
ffffffffc0202698:	5571                	li	a0,-4
            return -E_NO_MEM;
        }
    }
    return 0;
}
ffffffffc020269a:	70e2                	ld	ra,56(sp)
ffffffffc020269c:	7442                	ld	s0,48(sp)
ffffffffc020269e:	74a2                	ld	s1,40(sp)
ffffffffc02026a0:	7902                	ld	s2,32(sp)
ffffffffc02026a2:	69e2                	ld	s3,24(sp)
ffffffffc02026a4:	6a42                	ld	s4,16(sp)
ffffffffc02026a6:	6aa2                	ld	s5,8(sp)
ffffffffc02026a8:	6121                	addi	sp,sp,64
ffffffffc02026aa:	8082                	ret
    return 0;
ffffffffc02026ac:	4501                	li	a0,0
ffffffffc02026ae:	b7f5                	j	ffffffffc020269a <dup_mmap+0x66>
    assert(to != NULL && from != NULL);
ffffffffc02026b0:	00005697          	auipc	a3,0x5
ffffffffc02026b4:	04868693          	addi	a3,a3,72 # ffffffffc02076f8 <commands+0xf98>
ffffffffc02026b8:	00004617          	auipc	a2,0x4
ffffffffc02026bc:	52860613          	addi	a2,a2,1320 # ffffffffc0206be0 <commands+0x480>
ffffffffc02026c0:	0c000593          	li	a1,192
ffffffffc02026c4:	00005517          	auipc	a0,0x5
ffffffffc02026c8:	f6450513          	addi	a0,a0,-156 # ffffffffc0207628 <commands+0xec8>
ffffffffc02026cc:	b49fd0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc02026d0 <exit_mmap>:

void
exit_mmap(struct mm_struct *mm) {
ffffffffc02026d0:	1101                	addi	sp,sp,-32
ffffffffc02026d2:	ec06                	sd	ra,24(sp)
ffffffffc02026d4:	e822                	sd	s0,16(sp)
ffffffffc02026d6:	e426                	sd	s1,8(sp)
ffffffffc02026d8:	e04a                	sd	s2,0(sp)
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc02026da:	c531                	beqz	a0,ffffffffc0202726 <exit_mmap+0x56>
ffffffffc02026dc:	591c                	lw	a5,48(a0)
ffffffffc02026de:	84aa                	mv	s1,a0
ffffffffc02026e0:	e3b9                	bnez	a5,ffffffffc0202726 <exit_mmap+0x56>
    return listelm->next;
ffffffffc02026e2:	6500                	ld	s0,8(a0)
    pde_t *pgdir = mm->pgdir;
ffffffffc02026e4:	01853903          	ld	s2,24(a0)
    list_entry_t *list = &(mm->mmap_list), *le = list;
    while ((le = list_next(le)) != list) {
ffffffffc02026e8:	02850663          	beq	a0,s0,ffffffffc0202714 <exit_mmap+0x44>
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc02026ec:	ff043603          	ld	a2,-16(s0)
ffffffffc02026f0:	fe843583          	ld	a1,-24(s0)
ffffffffc02026f4:	854a                	mv	a0,s2
ffffffffc02026f6:	a9dfe0ef          	jal	ra,ffffffffc0201192 <unmap_range>
ffffffffc02026fa:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc02026fc:	fe8498e3          	bne	s1,s0,ffffffffc02026ec <exit_mmap+0x1c>
ffffffffc0202700:	6400                	ld	s0,8(s0)
    }
    while ((le = list_next(le)) != list) {
ffffffffc0202702:	00848c63          	beq	s1,s0,ffffffffc020271a <exit_mmap+0x4a>
        struct vma_struct *vma = le2vma(le, list_link);
        exit_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc0202706:	ff043603          	ld	a2,-16(s0)
ffffffffc020270a:	fe843583          	ld	a1,-24(s0)
ffffffffc020270e:	854a                	mv	a0,s2
ffffffffc0202710:	b9bfe0ef          	jal	ra,ffffffffc02012aa <exit_range>
ffffffffc0202714:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc0202716:	fe8498e3          	bne	s1,s0,ffffffffc0202706 <exit_mmap+0x36>
    }
}
ffffffffc020271a:	60e2                	ld	ra,24(sp)
ffffffffc020271c:	6442                	ld	s0,16(sp)
ffffffffc020271e:	64a2                	ld	s1,8(sp)
ffffffffc0202720:	6902                	ld	s2,0(sp)
ffffffffc0202722:	6105                	addi	sp,sp,32
ffffffffc0202724:	8082                	ret
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0202726:	00005697          	auipc	a3,0x5
ffffffffc020272a:	ff268693          	addi	a3,a3,-14 # ffffffffc0207718 <commands+0xfb8>
ffffffffc020272e:	00004617          	auipc	a2,0x4
ffffffffc0202732:	4b260613          	addi	a2,a2,1202 # ffffffffc0206be0 <commands+0x480>
ffffffffc0202736:	0d600593          	li	a1,214
ffffffffc020273a:	00005517          	auipc	a0,0x5
ffffffffc020273e:	eee50513          	addi	a0,a0,-274 # ffffffffc0207628 <commands+0xec8>
ffffffffc0202742:	ad3fd0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0202746 <vmm_init>:
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc0202746:	7139                	addi	sp,sp,-64
ffffffffc0202748:	f822                	sd	s0,48(sp)
ffffffffc020274a:	f426                	sd	s1,40(sp)
ffffffffc020274c:	fc06                	sd	ra,56(sp)
ffffffffc020274e:	f04a                	sd	s2,32(sp)
ffffffffc0202750:	ec4e                	sd	s3,24(sp)
ffffffffc0202752:	e852                	sd	s4,16(sp)
ffffffffc0202754:	e456                	sd	s5,8(sp)

static void
check_vma_struct(void) {
    // size_t nr_free_pages_store = nr_free_pages();

    struct mm_struct *mm = mm_create();
ffffffffc0202756:	c55ff0ef          	jal	ra,ffffffffc02023aa <mm_create>
    assert(mm != NULL);
ffffffffc020275a:	842a                	mv	s0,a0
ffffffffc020275c:	03200493          	li	s1,50
ffffffffc0202760:	e919                	bnez	a0,ffffffffc0202776 <vmm_init+0x30>
ffffffffc0202762:	a989                	j	ffffffffc0202bb4 <vmm_init+0x46e>
        vma->vm_start = vm_start;
ffffffffc0202764:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc0202766:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0202768:	00052c23          	sw	zero,24(a0)

    int i;
    for (i = step1; i >= 1; i --) {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc020276c:	14ed                	addi	s1,s1,-5
ffffffffc020276e:	8522                	mv	a0,s0
ffffffffc0202770:	cf3ff0ef          	jal	ra,ffffffffc0202462 <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc0202774:	c88d                	beqz	s1,ffffffffc02027a6 <vmm_init+0x60>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0202776:	03000513          	li	a0,48
ffffffffc020277a:	27c010ef          	jal	ra,ffffffffc02039f6 <kmalloc>
ffffffffc020277e:	85aa                	mv	a1,a0
ffffffffc0202780:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc0202784:	f165                	bnez	a0,ffffffffc0202764 <vmm_init+0x1e>
        assert(vma != NULL);
ffffffffc0202786:	00005697          	auipc	a3,0x5
ffffffffc020278a:	25268693          	addi	a3,a3,594 # ffffffffc02079d8 <commands+0x1278>
ffffffffc020278e:	00004617          	auipc	a2,0x4
ffffffffc0202792:	45260613          	addi	a2,a2,1106 # ffffffffc0206be0 <commands+0x480>
ffffffffc0202796:	11300593          	li	a1,275
ffffffffc020279a:	00005517          	auipc	a0,0x5
ffffffffc020279e:	e8e50513          	addi	a0,a0,-370 # ffffffffc0207628 <commands+0xec8>
ffffffffc02027a2:	a73fd0ef          	jal	ra,ffffffffc0200214 <__panic>
    for (i = step1; i >= 1; i --) {
ffffffffc02027a6:	03700493          	li	s1,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc02027aa:	1f900913          	li	s2,505
ffffffffc02027ae:	a819                	j	ffffffffc02027c4 <vmm_init+0x7e>
        vma->vm_start = vm_start;
ffffffffc02027b0:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc02027b2:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02027b4:	00052c23          	sw	zero,24(a0)
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc02027b8:	0495                	addi	s1,s1,5
ffffffffc02027ba:	8522                	mv	a0,s0
ffffffffc02027bc:	ca7ff0ef          	jal	ra,ffffffffc0202462 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc02027c0:	03248a63          	beq	s1,s2,ffffffffc02027f4 <vmm_init+0xae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02027c4:	03000513          	li	a0,48
ffffffffc02027c8:	22e010ef          	jal	ra,ffffffffc02039f6 <kmalloc>
ffffffffc02027cc:	85aa                	mv	a1,a0
ffffffffc02027ce:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc02027d2:	fd79                	bnez	a0,ffffffffc02027b0 <vmm_init+0x6a>
        assert(vma != NULL);
ffffffffc02027d4:	00005697          	auipc	a3,0x5
ffffffffc02027d8:	20468693          	addi	a3,a3,516 # ffffffffc02079d8 <commands+0x1278>
ffffffffc02027dc:	00004617          	auipc	a2,0x4
ffffffffc02027e0:	40460613          	addi	a2,a2,1028 # ffffffffc0206be0 <commands+0x480>
ffffffffc02027e4:	11900593          	li	a1,281
ffffffffc02027e8:	00005517          	auipc	a0,0x5
ffffffffc02027ec:	e4050513          	addi	a0,a0,-448 # ffffffffc0207628 <commands+0xec8>
ffffffffc02027f0:	a25fd0ef          	jal	ra,ffffffffc0200214 <__panic>
ffffffffc02027f4:	6418                	ld	a4,8(s0)
ffffffffc02027f6:	479d                	li	a5,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc02027f8:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc02027fc:	2ee40063          	beq	s0,a4,ffffffffc0202adc <vmm_init+0x396>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0202800:	fe873603          	ld	a2,-24(a4)
ffffffffc0202804:	ffe78693          	addi	a3,a5,-2
ffffffffc0202808:	24d61a63          	bne	a2,a3,ffffffffc0202a5c <vmm_init+0x316>
ffffffffc020280c:	ff073683          	ld	a3,-16(a4)
ffffffffc0202810:	24f69663          	bne	a3,a5,ffffffffc0202a5c <vmm_init+0x316>
ffffffffc0202814:	0795                	addi	a5,a5,5
ffffffffc0202816:	6718                	ld	a4,8(a4)
    for (i = 1; i <= step2; i ++) {
ffffffffc0202818:	feb792e3          	bne	a5,a1,ffffffffc02027fc <vmm_init+0xb6>
ffffffffc020281c:	491d                	li	s2,7
ffffffffc020281e:	4495                	li	s1,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0202820:	1f900a93          	li	s5,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0202824:	85a6                	mv	a1,s1
ffffffffc0202826:	8522                	mv	a0,s0
ffffffffc0202828:	bfdff0ef          	jal	ra,ffffffffc0202424 <find_vma>
ffffffffc020282c:	8a2a                	mv	s4,a0
        assert(vma1 != NULL);
ffffffffc020282e:	30050763          	beqz	a0,ffffffffc0202b3c <vmm_init+0x3f6>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc0202832:	00148593          	addi	a1,s1,1
ffffffffc0202836:	8522                	mv	a0,s0
ffffffffc0202838:	bedff0ef          	jal	ra,ffffffffc0202424 <find_vma>
ffffffffc020283c:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc020283e:	2c050f63          	beqz	a0,ffffffffc0202b1c <vmm_init+0x3d6>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc0202842:	85ca                	mv	a1,s2
ffffffffc0202844:	8522                	mv	a0,s0
ffffffffc0202846:	bdfff0ef          	jal	ra,ffffffffc0202424 <find_vma>
        assert(vma3 == NULL);
ffffffffc020284a:	2a051963          	bnez	a0,ffffffffc0202afc <vmm_init+0x3b6>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc020284e:	00348593          	addi	a1,s1,3
ffffffffc0202852:	8522                	mv	a0,s0
ffffffffc0202854:	bd1ff0ef          	jal	ra,ffffffffc0202424 <find_vma>
        assert(vma4 == NULL);
ffffffffc0202858:	32051263          	bnez	a0,ffffffffc0202b7c <vmm_init+0x436>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc020285c:	00448593          	addi	a1,s1,4
ffffffffc0202860:	8522                	mv	a0,s0
ffffffffc0202862:	bc3ff0ef          	jal	ra,ffffffffc0202424 <find_vma>
        assert(vma5 == NULL);
ffffffffc0202866:	2e051b63          	bnez	a0,ffffffffc0202b5c <vmm_init+0x416>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc020286a:	008a3783          	ld	a5,8(s4)
ffffffffc020286e:	20979763          	bne	a5,s1,ffffffffc0202a7c <vmm_init+0x336>
ffffffffc0202872:	010a3783          	ld	a5,16(s4)
ffffffffc0202876:	21279363          	bne	a5,s2,ffffffffc0202a7c <vmm_init+0x336>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc020287a:	0089b783          	ld	a5,8(s3) # 1008 <_binary_obj___user_faultread_out_size-0x85c0>
ffffffffc020287e:	20979f63          	bne	a5,s1,ffffffffc0202a9c <vmm_init+0x356>
ffffffffc0202882:	0109b783          	ld	a5,16(s3)
ffffffffc0202886:	21279b63          	bne	a5,s2,ffffffffc0202a9c <vmm_init+0x356>
ffffffffc020288a:	0495                	addi	s1,s1,5
ffffffffc020288c:	0915                	addi	s2,s2,5
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc020288e:	f9549be3          	bne	s1,s5,ffffffffc0202824 <vmm_init+0xde>
ffffffffc0202892:	4491                	li	s1,4
    }

    for (i =4; i>=0; i--) {
ffffffffc0202894:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc0202896:	85a6                	mv	a1,s1
ffffffffc0202898:	8522                	mv	a0,s0
ffffffffc020289a:	b8bff0ef          	jal	ra,ffffffffc0202424 <find_vma>
ffffffffc020289e:	0004859b          	sext.w	a1,s1
        if (vma_below_5 != NULL ) {
ffffffffc02028a2:	c90d                	beqz	a0,ffffffffc02028d4 <vmm_init+0x18e>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc02028a4:	6914                	ld	a3,16(a0)
ffffffffc02028a6:	6510                	ld	a2,8(a0)
ffffffffc02028a8:	00005517          	auipc	a0,0x5
ffffffffc02028ac:	01850513          	addi	a0,a0,24 # ffffffffc02078c0 <commands+0x1160>
ffffffffc02028b0:	821fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc02028b4:	00005697          	auipc	a3,0x5
ffffffffc02028b8:	03468693          	addi	a3,a3,52 # ffffffffc02078e8 <commands+0x1188>
ffffffffc02028bc:	00004617          	auipc	a2,0x4
ffffffffc02028c0:	32460613          	addi	a2,a2,804 # ffffffffc0206be0 <commands+0x480>
ffffffffc02028c4:	13b00593          	li	a1,315
ffffffffc02028c8:	00005517          	auipc	a0,0x5
ffffffffc02028cc:	d6050513          	addi	a0,a0,-672 # ffffffffc0207628 <commands+0xec8>
ffffffffc02028d0:	945fd0ef          	jal	ra,ffffffffc0200214 <__panic>
ffffffffc02028d4:	14fd                	addi	s1,s1,-1
    for (i =4; i>=0; i--) {
ffffffffc02028d6:	fd2490e3          	bne	s1,s2,ffffffffc0202896 <vmm_init+0x150>
    }

    mm_destroy(mm);
ffffffffc02028da:	8522                	mv	a0,s0
ffffffffc02028dc:	c55ff0ef          	jal	ra,ffffffffc0202530 <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc02028e0:	00005517          	auipc	a0,0x5
ffffffffc02028e4:	02050513          	addi	a0,a0,32 # ffffffffc0207900 <commands+0x11a0>
ffffffffc02028e8:	fe8fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc02028ec:	e3cfe0ef          	jal	ra,ffffffffc0200f28 <nr_free_pages>
ffffffffc02028f0:	89aa                	mv	s3,a0

    check_mm_struct = mm_create();
ffffffffc02028f2:	ab9ff0ef          	jal	ra,ffffffffc02023aa <mm_create>
ffffffffc02028f6:	000aa797          	auipc	a5,0xaa
ffffffffc02028fa:	fca7bd23          	sd	a0,-38(a5) # ffffffffc02ac8d0 <check_mm_struct>
ffffffffc02028fe:	84aa                	mv	s1,a0
    assert(check_mm_struct != NULL);
ffffffffc0202900:	36050663          	beqz	a0,ffffffffc0202c6c <vmm_init+0x526>

    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202904:	000aa797          	auipc	a5,0xaa
ffffffffc0202908:	f5478793          	addi	a5,a5,-172 # ffffffffc02ac858 <boot_pgdir>
ffffffffc020290c:	0007b903          	ld	s2,0(a5)
    assert(pgdir[0] == 0);
ffffffffc0202910:	00093783          	ld	a5,0(s2)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202914:	01253c23          	sd	s2,24(a0)
    assert(pgdir[0] == 0);
ffffffffc0202918:	2c079e63          	bnez	a5,ffffffffc0202bf4 <vmm_init+0x4ae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020291c:	03000513          	li	a0,48
ffffffffc0202920:	0d6010ef          	jal	ra,ffffffffc02039f6 <kmalloc>
ffffffffc0202924:	842a                	mv	s0,a0
    if (vma != NULL) {
ffffffffc0202926:	18050b63          	beqz	a0,ffffffffc0202abc <vmm_init+0x376>
        vma->vm_end = vm_end;
ffffffffc020292a:	002007b7          	lui	a5,0x200
ffffffffc020292e:	e81c                	sd	a5,16(s0)
        vma->vm_flags = vm_flags;
ffffffffc0202930:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc0202932:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc0202934:	cc1c                	sw	a5,24(s0)
    insert_vma_struct(mm, vma);
ffffffffc0202936:	8526                	mv	a0,s1
        vma->vm_start = vm_start;
ffffffffc0202938:	00043423          	sd	zero,8(s0)
    insert_vma_struct(mm, vma);
ffffffffc020293c:	b27ff0ef          	jal	ra,ffffffffc0202462 <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc0202940:	10000593          	li	a1,256
ffffffffc0202944:	8526                	mv	a0,s1
ffffffffc0202946:	adfff0ef          	jal	ra,ffffffffc0202424 <find_vma>
ffffffffc020294a:	10000793          	li	a5,256

    int i, sum = 0;

    for (i = 0; i < 100; i ++) {
ffffffffc020294e:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc0202952:	2ca41163          	bne	s0,a0,ffffffffc0202c14 <vmm_init+0x4ce>
        *(char *)(addr + i) = i;
ffffffffc0202956:	00f78023          	sb	a5,0(a5) # 200000 <_binary_obj___user_exit_out_size+0x1f5538>
        sum += i;
ffffffffc020295a:	0785                	addi	a5,a5,1
    for (i = 0; i < 100; i ++) {
ffffffffc020295c:	fee79de3          	bne	a5,a4,ffffffffc0202956 <vmm_init+0x210>
        sum += i;
ffffffffc0202960:	6705                	lui	a4,0x1
    for (i = 0; i < 100; i ++) {
ffffffffc0202962:	10000793          	li	a5,256
        sum += i;
ffffffffc0202966:	35670713          	addi	a4,a4,854 # 1356 <_binary_obj___user_faultread_out_size-0x8272>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc020296a:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc020296e:	0007c683          	lbu	a3,0(a5)
ffffffffc0202972:	0785                	addi	a5,a5,1
ffffffffc0202974:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc0202976:	fec79ce3          	bne	a5,a2,ffffffffc020296e <vmm_init+0x228>
    }

    assert(sum == 0);
ffffffffc020297a:	2c071963          	bnez	a4,ffffffffc0202c4c <vmm_init+0x506>
    return pa2page(PDE_ADDR(pde));
ffffffffc020297e:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0202982:	000aaa97          	auipc	s5,0xaa
ffffffffc0202986:	edea8a93          	addi	s5,s5,-290 # ffffffffc02ac860 <npage>
ffffffffc020298a:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc020298e:	078a                	slli	a5,a5,0x2
ffffffffc0202990:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202992:	20e7f563          	bgeu	a5,a4,ffffffffc0202b9c <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc0202996:	00006697          	auipc	a3,0x6
ffffffffc020299a:	35268693          	addi	a3,a3,850 # ffffffffc0208ce8 <nbase>
ffffffffc020299e:	0006ba03          	ld	s4,0(a3)
ffffffffc02029a2:	414786b3          	sub	a3,a5,s4
ffffffffc02029a6:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc02029a8:	8699                	srai	a3,a3,0x6
ffffffffc02029aa:	96d2                	add	a3,a3,s4
    return KADDR(page2pa(page));
ffffffffc02029ac:	00c69793          	slli	a5,a3,0xc
ffffffffc02029b0:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02029b2:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02029b4:	28e7f063          	bgeu	a5,a4,ffffffffc0202c34 <vmm_init+0x4ee>
ffffffffc02029b8:	000aa797          	auipc	a5,0xaa
ffffffffc02029bc:	f0078793          	addi	a5,a5,-256 # ffffffffc02ac8b8 <va_pa_offset>
ffffffffc02029c0:	6380                	ld	s0,0(a5)

    pde_t *pd1=pgdir,*pd0=page2kva(pde2page(pgdir[0]));
    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc02029c2:	4581                	li	a1,0
ffffffffc02029c4:	854a                	mv	a0,s2
ffffffffc02029c6:	9436                	add	s0,s0,a3
ffffffffc02029c8:	b39fe0ef          	jal	ra,ffffffffc0201500 <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc02029cc:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc02029ce:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc02029d2:	078a                	slli	a5,a5,0x2
ffffffffc02029d4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02029d6:	1ce7f363          	bgeu	a5,a4,ffffffffc0202b9c <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc02029da:	000aa417          	auipc	s0,0xaa
ffffffffc02029de:	eee40413          	addi	s0,s0,-274 # ffffffffc02ac8c8 <pages>
ffffffffc02029e2:	6008                	ld	a0,0(s0)
ffffffffc02029e4:	414787b3          	sub	a5,a5,s4
ffffffffc02029e8:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc02029ea:	953e                	add	a0,a0,a5
ffffffffc02029ec:	4585                	li	a1,1
ffffffffc02029ee:	cf4fe0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc02029f2:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc02029f6:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc02029fa:	078a                	slli	a5,a5,0x2
ffffffffc02029fc:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02029fe:	18e7ff63          	bgeu	a5,a4,ffffffffc0202b9c <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc0202a02:	6008                	ld	a0,0(s0)
ffffffffc0202a04:	414787b3          	sub	a5,a5,s4
ffffffffc0202a08:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0202a0a:	4585                	li	a1,1
ffffffffc0202a0c:	953e                	add	a0,a0,a5
ffffffffc0202a0e:	cd4fe0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
    pgdir[0] = 0;
ffffffffc0202a12:	00093023          	sd	zero,0(s2)
  asm volatile("sfence.vma");
ffffffffc0202a16:	12000073          	sfence.vma
    flush_tlb();

    mm->pgdir = NULL;
ffffffffc0202a1a:	0004bc23          	sd	zero,24(s1)
    mm_destroy(mm);
ffffffffc0202a1e:	8526                	mv	a0,s1
ffffffffc0202a20:	b11ff0ef          	jal	ra,ffffffffc0202530 <mm_destroy>
    check_mm_struct = NULL;
ffffffffc0202a24:	000aa797          	auipc	a5,0xaa
ffffffffc0202a28:	ea07b623          	sd	zero,-340(a5) # ffffffffc02ac8d0 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0202a2c:	cfcfe0ef          	jal	ra,ffffffffc0200f28 <nr_free_pages>
ffffffffc0202a30:	1aa99263          	bne	s3,a0,ffffffffc0202bd4 <vmm_init+0x48e>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc0202a34:	00005517          	auipc	a0,0x5
ffffffffc0202a38:	f6c50513          	addi	a0,a0,-148 # ffffffffc02079a0 <commands+0x1240>
ffffffffc0202a3c:	e94fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
}
ffffffffc0202a40:	7442                	ld	s0,48(sp)
ffffffffc0202a42:	70e2                	ld	ra,56(sp)
ffffffffc0202a44:	74a2                	ld	s1,40(sp)
ffffffffc0202a46:	7902                	ld	s2,32(sp)
ffffffffc0202a48:	69e2                	ld	s3,24(sp)
ffffffffc0202a4a:	6a42                	ld	s4,16(sp)
ffffffffc0202a4c:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0202a4e:	00005517          	auipc	a0,0x5
ffffffffc0202a52:	f7250513          	addi	a0,a0,-142 # ffffffffc02079c0 <commands+0x1260>
}
ffffffffc0202a56:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc0202a58:	e78fd06f          	j	ffffffffc02000d0 <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0202a5c:	00005697          	auipc	a3,0x5
ffffffffc0202a60:	d7c68693          	addi	a3,a3,-644 # ffffffffc02077d8 <commands+0x1078>
ffffffffc0202a64:	00004617          	auipc	a2,0x4
ffffffffc0202a68:	17c60613          	addi	a2,a2,380 # ffffffffc0206be0 <commands+0x480>
ffffffffc0202a6c:	12200593          	li	a1,290
ffffffffc0202a70:	00005517          	auipc	a0,0x5
ffffffffc0202a74:	bb850513          	addi	a0,a0,-1096 # ffffffffc0207628 <commands+0xec8>
ffffffffc0202a78:	f9cfd0ef          	jal	ra,ffffffffc0200214 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0202a7c:	00005697          	auipc	a3,0x5
ffffffffc0202a80:	de468693          	addi	a3,a3,-540 # ffffffffc0207860 <commands+0x1100>
ffffffffc0202a84:	00004617          	auipc	a2,0x4
ffffffffc0202a88:	15c60613          	addi	a2,a2,348 # ffffffffc0206be0 <commands+0x480>
ffffffffc0202a8c:	13200593          	li	a1,306
ffffffffc0202a90:	00005517          	auipc	a0,0x5
ffffffffc0202a94:	b9850513          	addi	a0,a0,-1128 # ffffffffc0207628 <commands+0xec8>
ffffffffc0202a98:	f7cfd0ef          	jal	ra,ffffffffc0200214 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0202a9c:	00005697          	auipc	a3,0x5
ffffffffc0202aa0:	df468693          	addi	a3,a3,-524 # ffffffffc0207890 <commands+0x1130>
ffffffffc0202aa4:	00004617          	auipc	a2,0x4
ffffffffc0202aa8:	13c60613          	addi	a2,a2,316 # ffffffffc0206be0 <commands+0x480>
ffffffffc0202aac:	13300593          	li	a1,307
ffffffffc0202ab0:	00005517          	auipc	a0,0x5
ffffffffc0202ab4:	b7850513          	addi	a0,a0,-1160 # ffffffffc0207628 <commands+0xec8>
ffffffffc0202ab8:	f5cfd0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(vma != NULL);
ffffffffc0202abc:	00005697          	auipc	a3,0x5
ffffffffc0202ac0:	f1c68693          	addi	a3,a3,-228 # ffffffffc02079d8 <commands+0x1278>
ffffffffc0202ac4:	00004617          	auipc	a2,0x4
ffffffffc0202ac8:	11c60613          	addi	a2,a2,284 # ffffffffc0206be0 <commands+0x480>
ffffffffc0202acc:	15200593          	li	a1,338
ffffffffc0202ad0:	00005517          	auipc	a0,0x5
ffffffffc0202ad4:	b5850513          	addi	a0,a0,-1192 # ffffffffc0207628 <commands+0xec8>
ffffffffc0202ad8:	f3cfd0ef          	jal	ra,ffffffffc0200214 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0202adc:	00005697          	auipc	a3,0x5
ffffffffc0202ae0:	ce468693          	addi	a3,a3,-796 # ffffffffc02077c0 <commands+0x1060>
ffffffffc0202ae4:	00004617          	auipc	a2,0x4
ffffffffc0202ae8:	0fc60613          	addi	a2,a2,252 # ffffffffc0206be0 <commands+0x480>
ffffffffc0202aec:	12000593          	li	a1,288
ffffffffc0202af0:	00005517          	auipc	a0,0x5
ffffffffc0202af4:	b3850513          	addi	a0,a0,-1224 # ffffffffc0207628 <commands+0xec8>
ffffffffc0202af8:	f1cfd0ef          	jal	ra,ffffffffc0200214 <__panic>
        assert(vma3 == NULL);
ffffffffc0202afc:	00005697          	auipc	a3,0x5
ffffffffc0202b00:	d3468693          	addi	a3,a3,-716 # ffffffffc0207830 <commands+0x10d0>
ffffffffc0202b04:	00004617          	auipc	a2,0x4
ffffffffc0202b08:	0dc60613          	addi	a2,a2,220 # ffffffffc0206be0 <commands+0x480>
ffffffffc0202b0c:	12c00593          	li	a1,300
ffffffffc0202b10:	00005517          	auipc	a0,0x5
ffffffffc0202b14:	b1850513          	addi	a0,a0,-1256 # ffffffffc0207628 <commands+0xec8>
ffffffffc0202b18:	efcfd0ef          	jal	ra,ffffffffc0200214 <__panic>
        assert(vma2 != NULL);
ffffffffc0202b1c:	00005697          	auipc	a3,0x5
ffffffffc0202b20:	d0468693          	addi	a3,a3,-764 # ffffffffc0207820 <commands+0x10c0>
ffffffffc0202b24:	00004617          	auipc	a2,0x4
ffffffffc0202b28:	0bc60613          	addi	a2,a2,188 # ffffffffc0206be0 <commands+0x480>
ffffffffc0202b2c:	12a00593          	li	a1,298
ffffffffc0202b30:	00005517          	auipc	a0,0x5
ffffffffc0202b34:	af850513          	addi	a0,a0,-1288 # ffffffffc0207628 <commands+0xec8>
ffffffffc0202b38:	edcfd0ef          	jal	ra,ffffffffc0200214 <__panic>
        assert(vma1 != NULL);
ffffffffc0202b3c:	00005697          	auipc	a3,0x5
ffffffffc0202b40:	cd468693          	addi	a3,a3,-812 # ffffffffc0207810 <commands+0x10b0>
ffffffffc0202b44:	00004617          	auipc	a2,0x4
ffffffffc0202b48:	09c60613          	addi	a2,a2,156 # ffffffffc0206be0 <commands+0x480>
ffffffffc0202b4c:	12800593          	li	a1,296
ffffffffc0202b50:	00005517          	auipc	a0,0x5
ffffffffc0202b54:	ad850513          	addi	a0,a0,-1320 # ffffffffc0207628 <commands+0xec8>
ffffffffc0202b58:	ebcfd0ef          	jal	ra,ffffffffc0200214 <__panic>
        assert(vma5 == NULL);
ffffffffc0202b5c:	00005697          	auipc	a3,0x5
ffffffffc0202b60:	cf468693          	addi	a3,a3,-780 # ffffffffc0207850 <commands+0x10f0>
ffffffffc0202b64:	00004617          	auipc	a2,0x4
ffffffffc0202b68:	07c60613          	addi	a2,a2,124 # ffffffffc0206be0 <commands+0x480>
ffffffffc0202b6c:	13000593          	li	a1,304
ffffffffc0202b70:	00005517          	auipc	a0,0x5
ffffffffc0202b74:	ab850513          	addi	a0,a0,-1352 # ffffffffc0207628 <commands+0xec8>
ffffffffc0202b78:	e9cfd0ef          	jal	ra,ffffffffc0200214 <__panic>
        assert(vma4 == NULL);
ffffffffc0202b7c:	00005697          	auipc	a3,0x5
ffffffffc0202b80:	cc468693          	addi	a3,a3,-828 # ffffffffc0207840 <commands+0x10e0>
ffffffffc0202b84:	00004617          	auipc	a2,0x4
ffffffffc0202b88:	05c60613          	addi	a2,a2,92 # ffffffffc0206be0 <commands+0x480>
ffffffffc0202b8c:	12e00593          	li	a1,302
ffffffffc0202b90:	00005517          	auipc	a0,0x5
ffffffffc0202b94:	a9850513          	addi	a0,a0,-1384 # ffffffffc0207628 <commands+0xec8>
ffffffffc0202b98:	e7cfd0ef          	jal	ra,ffffffffc0200214 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0202b9c:	00004617          	auipc	a2,0x4
ffffffffc0202ba0:	46460613          	addi	a2,a2,1124 # ffffffffc0207000 <commands+0x8a0>
ffffffffc0202ba4:	06200593          	li	a1,98
ffffffffc0202ba8:	00004517          	auipc	a0,0x4
ffffffffc0202bac:	47850513          	addi	a0,a0,1144 # ffffffffc0207020 <commands+0x8c0>
ffffffffc0202bb0:	e64fd0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(mm != NULL);
ffffffffc0202bb4:	00005697          	auipc	a3,0x5
ffffffffc0202bb8:	bfc68693          	addi	a3,a3,-1028 # ffffffffc02077b0 <commands+0x1050>
ffffffffc0202bbc:	00004617          	auipc	a2,0x4
ffffffffc0202bc0:	02460613          	addi	a2,a2,36 # ffffffffc0206be0 <commands+0x480>
ffffffffc0202bc4:	10c00593          	li	a1,268
ffffffffc0202bc8:	00005517          	auipc	a0,0x5
ffffffffc0202bcc:	a6050513          	addi	a0,a0,-1440 # ffffffffc0207628 <commands+0xec8>
ffffffffc0202bd0:	e44fd0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0202bd4:	00005697          	auipc	a3,0x5
ffffffffc0202bd8:	da468693          	addi	a3,a3,-604 # ffffffffc0207978 <commands+0x1218>
ffffffffc0202bdc:	00004617          	auipc	a2,0x4
ffffffffc0202be0:	00460613          	addi	a2,a2,4 # ffffffffc0206be0 <commands+0x480>
ffffffffc0202be4:	17000593          	li	a1,368
ffffffffc0202be8:	00005517          	auipc	a0,0x5
ffffffffc0202bec:	a4050513          	addi	a0,a0,-1472 # ffffffffc0207628 <commands+0xec8>
ffffffffc0202bf0:	e24fd0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(pgdir[0] == 0);
ffffffffc0202bf4:	00005697          	auipc	a3,0x5
ffffffffc0202bf8:	d4468693          	addi	a3,a3,-700 # ffffffffc0207938 <commands+0x11d8>
ffffffffc0202bfc:	00004617          	auipc	a2,0x4
ffffffffc0202c00:	fe460613          	addi	a2,a2,-28 # ffffffffc0206be0 <commands+0x480>
ffffffffc0202c04:	14f00593          	li	a1,335
ffffffffc0202c08:	00005517          	auipc	a0,0x5
ffffffffc0202c0c:	a2050513          	addi	a0,a0,-1504 # ffffffffc0207628 <commands+0xec8>
ffffffffc0202c10:	e04fd0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc0202c14:	00005697          	auipc	a3,0x5
ffffffffc0202c18:	d3468693          	addi	a3,a3,-716 # ffffffffc0207948 <commands+0x11e8>
ffffffffc0202c1c:	00004617          	auipc	a2,0x4
ffffffffc0202c20:	fc460613          	addi	a2,a2,-60 # ffffffffc0206be0 <commands+0x480>
ffffffffc0202c24:	15700593          	li	a1,343
ffffffffc0202c28:	00005517          	auipc	a0,0x5
ffffffffc0202c2c:	a0050513          	addi	a0,a0,-1536 # ffffffffc0207628 <commands+0xec8>
ffffffffc0202c30:	de4fd0ef          	jal	ra,ffffffffc0200214 <__panic>
    return KADDR(page2pa(page));
ffffffffc0202c34:	00004617          	auipc	a2,0x4
ffffffffc0202c38:	39460613          	addi	a2,a2,916 # ffffffffc0206fc8 <commands+0x868>
ffffffffc0202c3c:	06900593          	li	a1,105
ffffffffc0202c40:	00004517          	auipc	a0,0x4
ffffffffc0202c44:	3e050513          	addi	a0,a0,992 # ffffffffc0207020 <commands+0x8c0>
ffffffffc0202c48:	dccfd0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(sum == 0);
ffffffffc0202c4c:	00005697          	auipc	a3,0x5
ffffffffc0202c50:	d1c68693          	addi	a3,a3,-740 # ffffffffc0207968 <commands+0x1208>
ffffffffc0202c54:	00004617          	auipc	a2,0x4
ffffffffc0202c58:	f8c60613          	addi	a2,a2,-116 # ffffffffc0206be0 <commands+0x480>
ffffffffc0202c5c:	16300593          	li	a1,355
ffffffffc0202c60:	00005517          	auipc	a0,0x5
ffffffffc0202c64:	9c850513          	addi	a0,a0,-1592 # ffffffffc0207628 <commands+0xec8>
ffffffffc0202c68:	dacfd0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc0202c6c:	00005697          	auipc	a3,0x5
ffffffffc0202c70:	cb468693          	addi	a3,a3,-844 # ffffffffc0207920 <commands+0x11c0>
ffffffffc0202c74:	00004617          	auipc	a2,0x4
ffffffffc0202c78:	f6c60613          	addi	a2,a2,-148 # ffffffffc0206be0 <commands+0x480>
ffffffffc0202c7c:	14b00593          	li	a1,331
ffffffffc0202c80:	00005517          	auipc	a0,0x5
ffffffffc0202c84:	9a850513          	addi	a0,a0,-1624 # ffffffffc0207628 <commands+0xec8>
ffffffffc0202c88:	d8cfd0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0202c8c <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0202c8c:	7139                	addi	sp,sp,-64
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0202c8e:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0202c90:	f822                	sd	s0,48(sp)
ffffffffc0202c92:	f426                	sd	s1,40(sp)
ffffffffc0202c94:	fc06                	sd	ra,56(sp)
ffffffffc0202c96:	f04a                	sd	s2,32(sp)
ffffffffc0202c98:	ec4e                	sd	s3,24(sp)
ffffffffc0202c9a:	8432                	mv	s0,a2
ffffffffc0202c9c:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0202c9e:	f86ff0ef          	jal	ra,ffffffffc0202424 <find_vma>

    pgfault_num++;
ffffffffc0202ca2:	000aa797          	auipc	a5,0xaa
ffffffffc0202ca6:	bc678793          	addi	a5,a5,-1082 # ffffffffc02ac868 <pgfault_num>
ffffffffc0202caa:	439c                	lw	a5,0(a5)
ffffffffc0202cac:	2785                	addiw	a5,a5,1
ffffffffc0202cae:	000aa717          	auipc	a4,0xaa
ffffffffc0202cb2:	baf72d23          	sw	a5,-1094(a4) # ffffffffc02ac868 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0202cb6:	c555                	beqz	a0,ffffffffc0202d62 <do_pgfault+0xd6>
ffffffffc0202cb8:	651c                	ld	a5,8(a0)
ffffffffc0202cba:	0af46463          	bltu	s0,a5,ffffffffc0202d62 <do_pgfault+0xd6>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0202cbe:	4d1c                	lw	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc0202cc0:	49c1                	li	s3,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0202cc2:	8b89                	andi	a5,a5,2
ffffffffc0202cc4:	e3a5                	bnez	a5,ffffffffc0202d24 <do_pgfault+0x98>
        perm |= READ_WRITE;
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0202cc6:	767d                	lui	a2,0xfffff

    pte_t *ptep=NULL;
  
    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0202cc8:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0202cca:	8c71                	and	s0,s0,a2
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0202ccc:	85a2                	mv	a1,s0
ffffffffc0202cce:	4605                	li	a2,1
ffffffffc0202cd0:	a98fe0ef          	jal	ra,ffffffffc0200f68 <get_pte>
ffffffffc0202cd4:	c945                	beqz	a0,ffffffffc0202d84 <do_pgfault+0xf8>
        cprintf("get_pte in do_pgfault failed\n");
        goto failed;
    }
    
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
ffffffffc0202cd6:	610c                	ld	a1,0(a0)
ffffffffc0202cd8:	c5b5                	beqz	a1,ffffffffc0202d44 <do_pgfault+0xb8>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc0202cda:	000aa797          	auipc	a5,0xaa
ffffffffc0202cde:	b9e78793          	addi	a5,a5,-1122 # ffffffffc02ac878 <swap_init_ok>
ffffffffc0202ce2:	439c                	lw	a5,0(a5)
ffffffffc0202ce4:	2781                	sext.w	a5,a5
ffffffffc0202ce6:	c7d9                	beqz	a5,ffffffffc0202d74 <do_pgfault+0xe8>
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            //(3) make the page swappable.

            if ((ret = swap_in(mm, addr, &page)) != 0) {
ffffffffc0202ce8:	0030                	addi	a2,sp,8
ffffffffc0202cea:	85a2                	mv	a1,s0
ffffffffc0202cec:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc0202cee:	e402                	sd	zero,8(sp)
            if ((ret = swap_in(mm, addr, &page)) != 0) {
ffffffffc0202cf0:	1ed000ef          	jal	ra,ffffffffc02036dc <swap_in>
ffffffffc0202cf4:	892a                	mv	s2,a0
ffffffffc0202cf6:	e90d                	bnez	a0,ffffffffc0202d28 <do_pgfault+0x9c>
                cprintf("swap_in in do_pgfault failed\n");
                goto failed;
            }
            page_insert(mm->pgdir,page,addr,perm);//建立内存页 page 的物理地址和线性地址 addr 之间的映射
ffffffffc0202cf8:	65a2                	ld	a1,8(sp)
ffffffffc0202cfa:	6c88                	ld	a0,24(s1)
ffffffffc0202cfc:	86ce                	mv	a3,s3
ffffffffc0202cfe:	8622                	mv	a2,s0
ffffffffc0202d00:	875fe0ef          	jal	ra,ffffffffc0201574 <page_insert>
            swap_map_swappable(mm, addr, page, 1);//将页面标记为可交换
ffffffffc0202d04:	6622                	ld	a2,8(sp)
ffffffffc0202d06:	4685                	li	a3,1
ffffffffc0202d08:	85a2                	mv	a1,s0
ffffffffc0202d0a:	8526                	mv	a0,s1
ffffffffc0202d0c:	0ad000ef          	jal	ra,ffffffffc02035b8 <swap_map_swappable>
            page->pra_vaddr = addr;//跟踪页面映射的线性地址
ffffffffc0202d10:	67a2                	ld	a5,8(sp)
ffffffffc0202d12:	ff80                	sd	s0,56(a5)
        }
   }
   ret = 0;
failed:
    return ret;
}
ffffffffc0202d14:	70e2                	ld	ra,56(sp)
ffffffffc0202d16:	7442                	ld	s0,48(sp)
ffffffffc0202d18:	854a                	mv	a0,s2
ffffffffc0202d1a:	74a2                	ld	s1,40(sp)
ffffffffc0202d1c:	7902                	ld	s2,32(sp)
ffffffffc0202d1e:	69e2                	ld	s3,24(sp)
ffffffffc0202d20:	6121                	addi	sp,sp,64
ffffffffc0202d22:	8082                	ret
        perm |= READ_WRITE;
ffffffffc0202d24:	49dd                	li	s3,23
ffffffffc0202d26:	b745                	j	ffffffffc0202cc6 <do_pgfault+0x3a>
                cprintf("swap_in in do_pgfault failed\n");
ffffffffc0202d28:	00005517          	auipc	a0,0x5
ffffffffc0202d2c:	98850513          	addi	a0,a0,-1656 # ffffffffc02076b0 <commands+0xf50>
ffffffffc0202d30:	ba0fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
}
ffffffffc0202d34:	70e2                	ld	ra,56(sp)
ffffffffc0202d36:	7442                	ld	s0,48(sp)
ffffffffc0202d38:	854a                	mv	a0,s2
ffffffffc0202d3a:	74a2                	ld	s1,40(sp)
ffffffffc0202d3c:	7902                	ld	s2,32(sp)
ffffffffc0202d3e:	69e2                	ld	s3,24(sp)
ffffffffc0202d40:	6121                	addi	sp,sp,64
ffffffffc0202d42:	8082                	ret
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0202d44:	6c88                	ld	a0,24(s1)
ffffffffc0202d46:	864e                	mv	a2,s3
ffffffffc0202d48:	85a2                	mv	a1,s0
ffffffffc0202d4a:	da8ff0ef          	jal	ra,ffffffffc02022f2 <pgdir_alloc_page>
   ret = 0;
ffffffffc0202d4e:	4901                	li	s2,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0202d50:	f171                	bnez	a0,ffffffffc0202d14 <do_pgfault+0x88>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0202d52:	00005517          	auipc	a0,0x5
ffffffffc0202d56:	93650513          	addi	a0,a0,-1738 # ffffffffc0207688 <commands+0xf28>
ffffffffc0202d5a:	b76fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0202d5e:	5971                	li	s2,-4
            goto failed;
ffffffffc0202d60:	bf55                	j	ffffffffc0202d14 <do_pgfault+0x88>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0202d62:	85a2                	mv	a1,s0
ffffffffc0202d64:	00005517          	auipc	a0,0x5
ffffffffc0202d68:	8d450513          	addi	a0,a0,-1836 # ffffffffc0207638 <commands+0xed8>
ffffffffc0202d6c:	b64fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    int ret = -E_INVAL;
ffffffffc0202d70:	5975                	li	s2,-3
        goto failed;
ffffffffc0202d72:	b74d                	j	ffffffffc0202d14 <do_pgfault+0x88>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc0202d74:	00005517          	auipc	a0,0x5
ffffffffc0202d78:	95c50513          	addi	a0,a0,-1700 # ffffffffc02076d0 <commands+0xf70>
ffffffffc0202d7c:	b54fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0202d80:	5971                	li	s2,-4
            goto failed;
ffffffffc0202d82:	bf49                	j	ffffffffc0202d14 <do_pgfault+0x88>
        cprintf("get_pte in do_pgfault failed\n");
ffffffffc0202d84:	00005517          	auipc	a0,0x5
ffffffffc0202d88:	8e450513          	addi	a0,a0,-1820 # ffffffffc0207668 <commands+0xf08>
ffffffffc0202d8c:	b44fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0202d90:	5971                	li	s2,-4
        goto failed;
ffffffffc0202d92:	b749                	j	ffffffffc0202d14 <do_pgfault+0x88>

ffffffffc0202d94 <user_mem_check>:

bool
user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write) {
ffffffffc0202d94:	7179                	addi	sp,sp,-48
ffffffffc0202d96:	f022                	sd	s0,32(sp)
ffffffffc0202d98:	f406                	sd	ra,40(sp)
ffffffffc0202d9a:	ec26                	sd	s1,24(sp)
ffffffffc0202d9c:	e84a                	sd	s2,16(sp)
ffffffffc0202d9e:	e44e                	sd	s3,8(sp)
ffffffffc0202da0:	e052                	sd	s4,0(sp)
ffffffffc0202da2:	842e                	mv	s0,a1
    if (mm != NULL) {
ffffffffc0202da4:	c135                	beqz	a0,ffffffffc0202e08 <user_mem_check+0x74>
        if (!USER_ACCESS(addr, addr + len)) {
ffffffffc0202da6:	002007b7          	lui	a5,0x200
ffffffffc0202daa:	04f5e663          	bltu	a1,a5,ffffffffc0202df6 <user_mem_check+0x62>
ffffffffc0202dae:	00c584b3          	add	s1,a1,a2
ffffffffc0202db2:	0495f263          	bgeu	a1,s1,ffffffffc0202df6 <user_mem_check+0x62>
ffffffffc0202db6:	4785                	li	a5,1
ffffffffc0202db8:	07fe                	slli	a5,a5,0x1f
ffffffffc0202dba:	0297ee63          	bltu	a5,s1,ffffffffc0202df6 <user_mem_check+0x62>
ffffffffc0202dbe:	892a                	mv	s2,a0
ffffffffc0202dc0:	89b6                	mv	s3,a3
            }
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
                return 0;
            }
            if (write && (vma->vm_flags & VM_STACK)) {
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0202dc2:	6a05                	lui	s4,0x1
ffffffffc0202dc4:	a821                	j	ffffffffc0202ddc <user_mem_check+0x48>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0202dc6:	0027f693          	andi	a3,a5,2
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0202dca:	9752                	add	a4,a4,s4
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc0202dcc:	8ba1                	andi	a5,a5,8
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0202dce:	c685                	beqz	a3,ffffffffc0202df6 <user_mem_check+0x62>
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc0202dd0:	c399                	beqz	a5,ffffffffc0202dd6 <user_mem_check+0x42>
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0202dd2:	02e46263          	bltu	s0,a4,ffffffffc0202df6 <user_mem_check+0x62>
                    return 0;
                }
            }
            start = vma->vm_end;
ffffffffc0202dd6:	6900                	ld	s0,16(a0)
        while (start < end) {
ffffffffc0202dd8:	04947663          	bgeu	s0,s1,ffffffffc0202e24 <user_mem_check+0x90>
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start) {
ffffffffc0202ddc:	85a2                	mv	a1,s0
ffffffffc0202dde:	854a                	mv	a0,s2
ffffffffc0202de0:	e44ff0ef          	jal	ra,ffffffffc0202424 <find_vma>
ffffffffc0202de4:	c909                	beqz	a0,ffffffffc0202df6 <user_mem_check+0x62>
ffffffffc0202de6:	6518                	ld	a4,8(a0)
ffffffffc0202de8:	00e46763          	bltu	s0,a4,ffffffffc0202df6 <user_mem_check+0x62>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0202dec:	4d1c                	lw	a5,24(a0)
ffffffffc0202dee:	fc099ce3          	bnez	s3,ffffffffc0202dc6 <user_mem_check+0x32>
ffffffffc0202df2:	8b85                	andi	a5,a5,1
ffffffffc0202df4:	f3ed                	bnez	a5,ffffffffc0202dd6 <user_mem_check+0x42>
            return 0;
ffffffffc0202df6:	4501                	li	a0,0
        }
        return 1;
    }
    return KERN_ACCESS(addr, addr + len);
}
ffffffffc0202df8:	70a2                	ld	ra,40(sp)
ffffffffc0202dfa:	7402                	ld	s0,32(sp)
ffffffffc0202dfc:	64e2                	ld	s1,24(sp)
ffffffffc0202dfe:	6942                	ld	s2,16(sp)
ffffffffc0202e00:	69a2                	ld	s3,8(sp)
ffffffffc0202e02:	6a02                	ld	s4,0(sp)
ffffffffc0202e04:	6145                	addi	sp,sp,48
ffffffffc0202e06:	8082                	ret
    return KERN_ACCESS(addr, addr + len);
ffffffffc0202e08:	c02007b7          	lui	a5,0xc0200
ffffffffc0202e0c:	4501                	li	a0,0
ffffffffc0202e0e:	fef5e5e3          	bltu	a1,a5,ffffffffc0202df8 <user_mem_check+0x64>
ffffffffc0202e12:	962e                	add	a2,a2,a1
ffffffffc0202e14:	fec5f2e3          	bgeu	a1,a2,ffffffffc0202df8 <user_mem_check+0x64>
ffffffffc0202e18:	c8000537          	lui	a0,0xc8000
ffffffffc0202e1c:	0505                	addi	a0,a0,1
ffffffffc0202e1e:	00a63533          	sltu	a0,a2,a0
ffffffffc0202e22:	bfd9                	j	ffffffffc0202df8 <user_mem_check+0x64>
        return 1;
ffffffffc0202e24:	4505                	li	a0,1
ffffffffc0202e26:	bfc9                	j	ffffffffc0202df8 <user_mem_check+0x64>

ffffffffc0202e28 <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc0202e28:	7135                	addi	sp,sp,-160
ffffffffc0202e2a:	ed06                	sd	ra,152(sp)
ffffffffc0202e2c:	e922                	sd	s0,144(sp)
ffffffffc0202e2e:	e526                	sd	s1,136(sp)
ffffffffc0202e30:	e14a                	sd	s2,128(sp)
ffffffffc0202e32:	fcce                	sd	s3,120(sp)
ffffffffc0202e34:	f8d2                	sd	s4,112(sp)
ffffffffc0202e36:	f4d6                	sd	s5,104(sp)
ffffffffc0202e38:	f0da                	sd	s6,96(sp)
ffffffffc0202e3a:	ecde                	sd	s7,88(sp)
ffffffffc0202e3c:	e8e2                	sd	s8,80(sp)
ffffffffc0202e3e:	e4e6                	sd	s9,72(sp)
ffffffffc0202e40:	e0ea                	sd	s10,64(sp)
ffffffffc0202e42:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc0202e44:	4c9010ef          	jal	ra,ffffffffc0204b0c <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc0202e48:	000aa797          	auipc	a5,0xaa
ffffffffc0202e4c:	b1878793          	addi	a5,a5,-1256 # ffffffffc02ac960 <max_swap_offset>
ffffffffc0202e50:	6394                	ld	a3,0(a5)
ffffffffc0202e52:	010007b7          	lui	a5,0x1000
ffffffffc0202e56:	17e1                	addi	a5,a5,-8
ffffffffc0202e58:	ff968713          	addi	a4,a3,-7
ffffffffc0202e5c:	4ae7ee63          	bltu	a5,a4,ffffffffc0203318 <swap_init+0x4f0>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }
     

     sm = &swap_manager_fifo;
ffffffffc0202e60:	0009e797          	auipc	a5,0x9e
ffffffffc0202e64:	59878793          	addi	a5,a5,1432 # ffffffffc02a13f8 <swap_manager_fifo>
     int r = sm->init();
ffffffffc0202e68:	6798                	ld	a4,8(a5)
     sm = &swap_manager_fifo;
ffffffffc0202e6a:	000aa697          	auipc	a3,0xaa
ffffffffc0202e6e:	a0f6b323          	sd	a5,-1530(a3) # ffffffffc02ac870 <sm>
     int r = sm->init();
ffffffffc0202e72:	9702                	jalr	a4
ffffffffc0202e74:	8aaa                	mv	s5,a0
     
     if (r == 0)
ffffffffc0202e76:	c10d                	beqz	a0,ffffffffc0202e98 <swap_init+0x70>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc0202e78:	60ea                	ld	ra,152(sp)
ffffffffc0202e7a:	644a                	ld	s0,144(sp)
ffffffffc0202e7c:	8556                	mv	a0,s5
ffffffffc0202e7e:	64aa                	ld	s1,136(sp)
ffffffffc0202e80:	690a                	ld	s2,128(sp)
ffffffffc0202e82:	79e6                	ld	s3,120(sp)
ffffffffc0202e84:	7a46                	ld	s4,112(sp)
ffffffffc0202e86:	7aa6                	ld	s5,104(sp)
ffffffffc0202e88:	7b06                	ld	s6,96(sp)
ffffffffc0202e8a:	6be6                	ld	s7,88(sp)
ffffffffc0202e8c:	6c46                	ld	s8,80(sp)
ffffffffc0202e8e:	6ca6                	ld	s9,72(sp)
ffffffffc0202e90:	6d06                	ld	s10,64(sp)
ffffffffc0202e92:	7de2                	ld	s11,56(sp)
ffffffffc0202e94:	610d                	addi	sp,sp,160
ffffffffc0202e96:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0202e98:	000aa797          	auipc	a5,0xaa
ffffffffc0202e9c:	9d878793          	addi	a5,a5,-1576 # ffffffffc02ac870 <sm>
ffffffffc0202ea0:	639c                	ld	a5,0(a5)
ffffffffc0202ea2:	00005517          	auipc	a0,0x5
ffffffffc0202ea6:	bc650513          	addi	a0,a0,-1082 # ffffffffc0207a68 <commands+0x1308>
ffffffffc0202eaa:	000aa417          	auipc	s0,0xaa
ffffffffc0202eae:	b0640413          	addi	s0,s0,-1274 # ffffffffc02ac9b0 <free_area>
ffffffffc0202eb2:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc0202eb4:	4785                	li	a5,1
ffffffffc0202eb6:	000aa717          	auipc	a4,0xaa
ffffffffc0202eba:	9cf72123          	sw	a5,-1598(a4) # ffffffffc02ac878 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0202ebe:	a12fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc0202ec2:	641c                	ld	a5,8(s0)
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202ec4:	36878e63          	beq	a5,s0,ffffffffc0203240 <swap_init+0x418>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0202ec8:	ff07b703          	ld	a4,-16(a5)
ffffffffc0202ecc:	8305                	srli	a4,a4,0x1
ffffffffc0202ece:	8b05                	andi	a4,a4,1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0202ed0:	36070c63          	beqz	a4,ffffffffc0203248 <swap_init+0x420>
     int ret, count = 0, total = 0, i;
ffffffffc0202ed4:	4481                	li	s1,0
ffffffffc0202ed6:	4901                	li	s2,0
ffffffffc0202ed8:	a031                	j	ffffffffc0202ee4 <swap_init+0xbc>
ffffffffc0202eda:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc0202ede:	8b09                	andi	a4,a4,2
ffffffffc0202ee0:	36070463          	beqz	a4,ffffffffc0203248 <swap_init+0x420>
        count ++, total += p->property;
ffffffffc0202ee4:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202ee8:	679c                	ld	a5,8(a5)
ffffffffc0202eea:	2905                	addiw	s2,s2,1
ffffffffc0202eec:	9cb9                	addw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202eee:	fe8796e3          	bne	a5,s0,ffffffffc0202eda <swap_init+0xb2>
ffffffffc0202ef2:	89a6                	mv	s3,s1
     }
     assert(total == nr_free_pages());
ffffffffc0202ef4:	834fe0ef          	jal	ra,ffffffffc0200f28 <nr_free_pages>
ffffffffc0202ef8:	69351863          	bne	a0,s3,ffffffffc0203588 <swap_init+0x760>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc0202efc:	8626                	mv	a2,s1
ffffffffc0202efe:	85ca                	mv	a1,s2
ffffffffc0202f00:	00005517          	auipc	a0,0x5
ffffffffc0202f04:	bb050513          	addi	a0,a0,-1104 # ffffffffc0207ab0 <commands+0x1350>
ffffffffc0202f08:	9c8fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc0202f0c:	c9eff0ef          	jal	ra,ffffffffc02023aa <mm_create>
ffffffffc0202f10:	8baa                	mv	s7,a0
     assert(mm != NULL);
ffffffffc0202f12:	60050b63          	beqz	a0,ffffffffc0203528 <swap_init+0x700>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc0202f16:	000aa797          	auipc	a5,0xaa
ffffffffc0202f1a:	9ba78793          	addi	a5,a5,-1606 # ffffffffc02ac8d0 <check_mm_struct>
ffffffffc0202f1e:	639c                	ld	a5,0(a5)
ffffffffc0202f20:	62079463          	bnez	a5,ffffffffc0203548 <swap_init+0x720>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202f24:	000aa797          	auipc	a5,0xaa
ffffffffc0202f28:	93478793          	addi	a5,a5,-1740 # ffffffffc02ac858 <boot_pgdir>
ffffffffc0202f2c:	0007bb03          	ld	s6,0(a5)
     check_mm_struct = mm;
ffffffffc0202f30:	000aa797          	auipc	a5,0xaa
ffffffffc0202f34:	9aa7b023          	sd	a0,-1632(a5) # ffffffffc02ac8d0 <check_mm_struct>
     assert(pgdir[0] == 0);
ffffffffc0202f38:	000b3783          	ld	a5,0(s6) # 80000 <_binary_obj___user_exit_out_size+0x75538>
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202f3c:	01653c23          	sd	s6,24(a0)
     assert(pgdir[0] == 0);
ffffffffc0202f40:	4e079863          	bnez	a5,ffffffffc0203430 <swap_init+0x608>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc0202f44:	6599                	lui	a1,0x6
ffffffffc0202f46:	460d                	li	a2,3
ffffffffc0202f48:	6505                	lui	a0,0x1
ffffffffc0202f4a:	cacff0ef          	jal	ra,ffffffffc02023f6 <vma_create>
ffffffffc0202f4e:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc0202f50:	50050063          	beqz	a0,ffffffffc0203450 <swap_init+0x628>

     insert_vma_struct(mm, vma);
ffffffffc0202f54:	855e                	mv	a0,s7
ffffffffc0202f56:	d0cff0ef          	jal	ra,ffffffffc0202462 <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc0202f5a:	00005517          	auipc	a0,0x5
ffffffffc0202f5e:	b9650513          	addi	a0,a0,-1130 # ffffffffc0207af0 <commands+0x1390>
ffffffffc0202f62:	96efd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc0202f66:	018bb503          	ld	a0,24(s7)
ffffffffc0202f6a:	4605                	li	a2,1
ffffffffc0202f6c:	6585                	lui	a1,0x1
ffffffffc0202f6e:	ffbfd0ef          	jal	ra,ffffffffc0200f68 <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc0202f72:	4e050f63          	beqz	a0,ffffffffc0203470 <swap_init+0x648>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202f76:	00005517          	auipc	a0,0x5
ffffffffc0202f7a:	bca50513          	addi	a0,a0,-1078 # ffffffffc0207b40 <commands+0x13e0>
ffffffffc0202f7e:	000aa997          	auipc	s3,0xaa
ffffffffc0202f82:	95a98993          	addi	s3,s3,-1702 # ffffffffc02ac8d8 <check_rp>
ffffffffc0202f86:	94afd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202f8a:	000aaa17          	auipc	s4,0xaa
ffffffffc0202f8e:	96ea0a13          	addi	s4,s4,-1682 # ffffffffc02ac8f8 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202f92:	8c4e                	mv	s8,s3
          check_rp[i] = alloc_page();
ffffffffc0202f94:	4505                	li	a0,1
ffffffffc0202f96:	ec5fd0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0202f9a:	00ac3023          	sd	a0,0(s8)
          assert(check_rp[i] != NULL );
ffffffffc0202f9e:	32050d63          	beqz	a0,ffffffffc02032d8 <swap_init+0x4b0>
ffffffffc0202fa2:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc0202fa4:	8b89                	andi	a5,a5,2
ffffffffc0202fa6:	30079963          	bnez	a5,ffffffffc02032b8 <swap_init+0x490>
ffffffffc0202faa:	0c21                	addi	s8,s8,8
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202fac:	ff4c14e3          	bne	s8,s4,ffffffffc0202f94 <swap_init+0x16c>
     }
     list_entry_t free_list_store = free_list;
ffffffffc0202fb0:	601c                	ld	a5,0(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc0202fb2:	000aac17          	auipc	s8,0xaa
ffffffffc0202fb6:	926c0c13          	addi	s8,s8,-1754 # ffffffffc02ac8d8 <check_rp>
     list_entry_t free_list_store = free_list;
ffffffffc0202fba:	ec3e                	sd	a5,24(sp)
ffffffffc0202fbc:	641c                	ld	a5,8(s0)
ffffffffc0202fbe:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc0202fc0:	481c                	lw	a5,16(s0)
ffffffffc0202fc2:	f43e                	sd	a5,40(sp)
    elm->prev = elm->next = elm;
ffffffffc0202fc4:	000aa797          	auipc	a5,0xaa
ffffffffc0202fc8:	9e87ba23          	sd	s0,-1548(a5) # ffffffffc02ac9b8 <free_area+0x8>
ffffffffc0202fcc:	000aa797          	auipc	a5,0xaa
ffffffffc0202fd0:	9e87b223          	sd	s0,-1564(a5) # ffffffffc02ac9b0 <free_area>
     nr_free = 0;
ffffffffc0202fd4:	000aa797          	auipc	a5,0xaa
ffffffffc0202fd8:	9e07a623          	sw	zero,-1556(a5) # ffffffffc02ac9c0 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc0202fdc:	000c3503          	ld	a0,0(s8)
ffffffffc0202fe0:	4585                	li	a1,1
ffffffffc0202fe2:	0c21                	addi	s8,s8,8
ffffffffc0202fe4:	efffd0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202fe8:	ff4c1ae3          	bne	s8,s4,ffffffffc0202fdc <swap_init+0x1b4>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0202fec:	01042c03          	lw	s8,16(s0)
ffffffffc0202ff0:	4791                	li	a5,4
ffffffffc0202ff2:	50fc1b63          	bne	s8,a5,ffffffffc0203508 <swap_init+0x6e0>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc0202ff6:	00005517          	auipc	a0,0x5
ffffffffc0202ffa:	bd250513          	addi	a0,a0,-1070 # ffffffffc0207bc8 <commands+0x1468>
ffffffffc0202ffe:	8d2fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203002:	6685                	lui	a3,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc0203004:	000aa797          	auipc	a5,0xaa
ffffffffc0203008:	8607a223          	sw	zero,-1948(a5) # ffffffffc02ac868 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc020300c:	4629                	li	a2,10
     pgfault_num=0;
ffffffffc020300e:	000aa797          	auipc	a5,0xaa
ffffffffc0203012:	85a78793          	addi	a5,a5,-1958 # ffffffffc02ac868 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203016:	00c68023          	sb	a2,0(a3) # 1000 <_binary_obj___user_faultread_out_size-0x85c8>
     assert(pgfault_num==1);
ffffffffc020301a:	4398                	lw	a4,0(a5)
ffffffffc020301c:	4585                	li	a1,1
ffffffffc020301e:	2701                	sext.w	a4,a4
ffffffffc0203020:	38b71863          	bne	a4,a1,ffffffffc02033b0 <swap_init+0x588>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc0203024:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==1);
ffffffffc0203028:	4394                	lw	a3,0(a5)
ffffffffc020302a:	2681                	sext.w	a3,a3
ffffffffc020302c:	3ae69263          	bne	a3,a4,ffffffffc02033d0 <swap_init+0x5a8>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203030:	6689                	lui	a3,0x2
ffffffffc0203032:	462d                	li	a2,11
ffffffffc0203034:	00c68023          	sb	a2,0(a3) # 2000 <_binary_obj___user_faultread_out_size-0x75c8>
     assert(pgfault_num==2);
ffffffffc0203038:	4398                	lw	a4,0(a5)
ffffffffc020303a:	4589                	li	a1,2
ffffffffc020303c:	2701                	sext.w	a4,a4
ffffffffc020303e:	2eb71963          	bne	a4,a1,ffffffffc0203330 <swap_init+0x508>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc0203042:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc0203046:	4394                	lw	a3,0(a5)
ffffffffc0203048:	2681                	sext.w	a3,a3
ffffffffc020304a:	30e69363          	bne	a3,a4,ffffffffc0203350 <swap_init+0x528>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc020304e:	668d                	lui	a3,0x3
ffffffffc0203050:	4631                	li	a2,12
ffffffffc0203052:	00c68023          	sb	a2,0(a3) # 3000 <_binary_obj___user_faultread_out_size-0x65c8>
     assert(pgfault_num==3);
ffffffffc0203056:	4398                	lw	a4,0(a5)
ffffffffc0203058:	458d                	li	a1,3
ffffffffc020305a:	2701                	sext.w	a4,a4
ffffffffc020305c:	30b71a63          	bne	a4,a1,ffffffffc0203370 <swap_init+0x548>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc0203060:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc0203064:	4394                	lw	a3,0(a5)
ffffffffc0203066:	2681                	sext.w	a3,a3
ffffffffc0203068:	32e69463          	bne	a3,a4,ffffffffc0203390 <swap_init+0x568>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc020306c:	6691                	lui	a3,0x4
ffffffffc020306e:	4635                	li	a2,13
ffffffffc0203070:	00c68023          	sb	a2,0(a3) # 4000 <_binary_obj___user_faultread_out_size-0x55c8>
     assert(pgfault_num==4);
ffffffffc0203074:	4398                	lw	a4,0(a5)
ffffffffc0203076:	2701                	sext.w	a4,a4
ffffffffc0203078:	37871c63          	bne	a4,s8,ffffffffc02033f0 <swap_init+0x5c8>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc020307c:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc0203080:	439c                	lw	a5,0(a5)
ffffffffc0203082:	2781                	sext.w	a5,a5
ffffffffc0203084:	38e79663          	bne	a5,a4,ffffffffc0203410 <swap_init+0x5e8>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc0203088:	481c                	lw	a5,16(s0)
ffffffffc020308a:	40079363          	bnez	a5,ffffffffc0203490 <swap_init+0x668>
ffffffffc020308e:	000aa797          	auipc	a5,0xaa
ffffffffc0203092:	86a78793          	addi	a5,a5,-1942 # ffffffffc02ac8f8 <swap_in_seq_no>
ffffffffc0203096:	000aa717          	auipc	a4,0xaa
ffffffffc020309a:	88a70713          	addi	a4,a4,-1910 # ffffffffc02ac920 <swap_out_seq_no>
ffffffffc020309e:	000aa617          	auipc	a2,0xaa
ffffffffc02030a2:	88260613          	addi	a2,a2,-1918 # ffffffffc02ac920 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc02030a6:	56fd                	li	a3,-1
ffffffffc02030a8:	c394                	sw	a3,0(a5)
ffffffffc02030aa:	c314                	sw	a3,0(a4)
ffffffffc02030ac:	0791                	addi	a5,a5,4
ffffffffc02030ae:	0711                	addi	a4,a4,4
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc02030b0:	fef61ce3          	bne	a2,a5,ffffffffc02030a8 <swap_init+0x280>
ffffffffc02030b4:	000aa697          	auipc	a3,0xaa
ffffffffc02030b8:	8cc68693          	addi	a3,a3,-1844 # ffffffffc02ac980 <check_ptep>
ffffffffc02030bc:	000aa817          	auipc	a6,0xaa
ffffffffc02030c0:	81c80813          	addi	a6,a6,-2020 # ffffffffc02ac8d8 <check_rp>
ffffffffc02030c4:	6d05                	lui	s10,0x1
    if (PPN(pa) >= npage) {
ffffffffc02030c6:	000a9c97          	auipc	s9,0xa9
ffffffffc02030ca:	79ac8c93          	addi	s9,s9,1946 # ffffffffc02ac860 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc02030ce:	00006d97          	auipc	s11,0x6
ffffffffc02030d2:	c1ad8d93          	addi	s11,s11,-998 # ffffffffc0208ce8 <nbase>
ffffffffc02030d6:	000a9c17          	auipc	s8,0xa9
ffffffffc02030da:	7f2c0c13          	addi	s8,s8,2034 # ffffffffc02ac8c8 <pages>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc02030de:	0006b023          	sd	zero,0(a3)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc02030e2:	4601                	li	a2,0
ffffffffc02030e4:	85ea                	mv	a1,s10
ffffffffc02030e6:	855a                	mv	a0,s6
ffffffffc02030e8:	e842                	sd	a6,16(sp)
         check_ptep[i]=0;
ffffffffc02030ea:	e436                	sd	a3,8(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc02030ec:	e7dfd0ef          	jal	ra,ffffffffc0200f68 <get_pte>
ffffffffc02030f0:	66a2                	ld	a3,8(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc02030f2:	6842                	ld	a6,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc02030f4:	e288                	sd	a0,0(a3)
         assert(check_ptep[i] != NULL);
ffffffffc02030f6:	20050163          	beqz	a0,ffffffffc02032f8 <swap_init+0x4d0>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc02030fa:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02030fc:	0017f613          	andi	a2,a5,1
ffffffffc0203100:	1a060063          	beqz	a2,ffffffffc02032a0 <swap_init+0x478>
    if (PPN(pa) >= npage) {
ffffffffc0203104:	000cb603          	ld	a2,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc0203108:	078a                	slli	a5,a5,0x2
ffffffffc020310a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020310c:	14c7fe63          	bgeu	a5,a2,ffffffffc0203268 <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc0203110:	000db703          	ld	a4,0(s11)
ffffffffc0203114:	000c3603          	ld	a2,0(s8)
ffffffffc0203118:	00083583          	ld	a1,0(a6)
ffffffffc020311c:	8f99                	sub	a5,a5,a4
ffffffffc020311e:	079a                	slli	a5,a5,0x6
ffffffffc0203120:	e43a                	sd	a4,8(sp)
ffffffffc0203122:	97b2                	add	a5,a5,a2
ffffffffc0203124:	14f59e63          	bne	a1,a5,ffffffffc0203280 <swap_init+0x458>
ffffffffc0203128:	6785                	lui	a5,0x1
ffffffffc020312a:	9d3e                	add	s10,s10,a5
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020312c:	6795                	lui	a5,0x5
ffffffffc020312e:	06a1                	addi	a3,a3,8
ffffffffc0203130:	0821                	addi	a6,a6,8
ffffffffc0203132:	fafd16e3          	bne	s10,a5,ffffffffc02030de <swap_init+0x2b6>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc0203136:	00005517          	auipc	a0,0x5
ffffffffc020313a:	b4a50513          	addi	a0,a0,-1206 # ffffffffc0207c80 <commands+0x1520>
ffffffffc020313e:	f93fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    int ret = sm->check_swap();
ffffffffc0203142:	000a9797          	auipc	a5,0xa9
ffffffffc0203146:	72e78793          	addi	a5,a5,1838 # ffffffffc02ac870 <sm>
ffffffffc020314a:	639c                	ld	a5,0(a5)
ffffffffc020314c:	7f9c                	ld	a5,56(a5)
ffffffffc020314e:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc0203150:	40051c63          	bnez	a0,ffffffffc0203568 <swap_init+0x740>

     nr_free = nr_free_store;
ffffffffc0203154:	77a2                	ld	a5,40(sp)
ffffffffc0203156:	000aa717          	auipc	a4,0xaa
ffffffffc020315a:	86f72523          	sw	a5,-1942(a4) # ffffffffc02ac9c0 <free_area+0x10>
     free_list = free_list_store;
ffffffffc020315e:	67e2                	ld	a5,24(sp)
ffffffffc0203160:	000aa717          	auipc	a4,0xaa
ffffffffc0203164:	84f73823          	sd	a5,-1968(a4) # ffffffffc02ac9b0 <free_area>
ffffffffc0203168:	7782                	ld	a5,32(sp)
ffffffffc020316a:	000aa717          	auipc	a4,0xaa
ffffffffc020316e:	84f73723          	sd	a5,-1970(a4) # ffffffffc02ac9b8 <free_area+0x8>

     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc0203172:	0009b503          	ld	a0,0(s3)
ffffffffc0203176:	4585                	li	a1,1
ffffffffc0203178:	09a1                	addi	s3,s3,8
ffffffffc020317a:	d69fd0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020317e:	ff499ae3          	bne	s3,s4,ffffffffc0203172 <swap_init+0x34a>
     } 

     //free_page(pte2page(*temp_ptep));

     mm->pgdir = NULL;
ffffffffc0203182:	000bbc23          	sd	zero,24(s7)
     mm_destroy(mm);
ffffffffc0203186:	855e                	mv	a0,s7
ffffffffc0203188:	ba8ff0ef          	jal	ra,ffffffffc0202530 <mm_destroy>
     check_mm_struct = NULL;

     pde_t *pd1=pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc020318c:	000a9797          	auipc	a5,0xa9
ffffffffc0203190:	6cc78793          	addi	a5,a5,1740 # ffffffffc02ac858 <boot_pgdir>
ffffffffc0203194:	639c                	ld	a5,0(a5)
     check_mm_struct = NULL;
ffffffffc0203196:	000a9697          	auipc	a3,0xa9
ffffffffc020319a:	7206bd23          	sd	zero,1850(a3) # ffffffffc02ac8d0 <check_mm_struct>
    if (PPN(pa) >= npage) {
ffffffffc020319e:	000cb703          	ld	a4,0(s9)
    return pa2page(PDE_ADDR(pde));
ffffffffc02031a2:	6394                	ld	a3,0(a5)
ffffffffc02031a4:	068a                	slli	a3,a3,0x2
ffffffffc02031a6:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc02031a8:	0ce6f063          	bgeu	a3,a4,ffffffffc0203268 <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc02031ac:	67a2                	ld	a5,8(sp)
ffffffffc02031ae:	000c3503          	ld	a0,0(s8)
ffffffffc02031b2:	8e9d                	sub	a3,a3,a5
ffffffffc02031b4:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc02031b6:	8699                	srai	a3,a3,0x6
ffffffffc02031b8:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc02031ba:	00c69793          	slli	a5,a3,0xc
ffffffffc02031be:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02031c0:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02031c2:	2ee7f763          	bgeu	a5,a4,ffffffffc02034b0 <swap_init+0x688>
     free_page(pde2page(pd0[0]));
ffffffffc02031c6:	000a9797          	auipc	a5,0xa9
ffffffffc02031ca:	6f278793          	addi	a5,a5,1778 # ffffffffc02ac8b8 <va_pa_offset>
ffffffffc02031ce:	639c                	ld	a5,0(a5)
ffffffffc02031d0:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc02031d2:	629c                	ld	a5,0(a3)
ffffffffc02031d4:	078a                	slli	a5,a5,0x2
ffffffffc02031d6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02031d8:	08e7f863          	bgeu	a5,a4,ffffffffc0203268 <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc02031dc:	69a2                	ld	s3,8(sp)
ffffffffc02031de:	4585                	li	a1,1
ffffffffc02031e0:	413787b3          	sub	a5,a5,s3
ffffffffc02031e4:	079a                	slli	a5,a5,0x6
ffffffffc02031e6:	953e                	add	a0,a0,a5
ffffffffc02031e8:	cfbfd0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc02031ec:	000b3783          	ld	a5,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc02031f0:	000cb703          	ld	a4,0(s9)
    return pa2page(PDE_ADDR(pde));
ffffffffc02031f4:	078a                	slli	a5,a5,0x2
ffffffffc02031f6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02031f8:	06e7f863          	bgeu	a5,a4,ffffffffc0203268 <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc02031fc:	000c3503          	ld	a0,0(s8)
ffffffffc0203200:	413787b3          	sub	a5,a5,s3
ffffffffc0203204:	079a                	slli	a5,a5,0x6
     free_page(pde2page(pd1[0]));
ffffffffc0203206:	4585                	li	a1,1
ffffffffc0203208:	953e                	add	a0,a0,a5
ffffffffc020320a:	cd9fd0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
     pgdir[0] = 0;
ffffffffc020320e:	000b3023          	sd	zero,0(s6)
  asm volatile("sfence.vma");
ffffffffc0203212:	12000073          	sfence.vma
    return listelm->next;
ffffffffc0203216:	641c                	ld	a5,8(s0)
     flush_tlb();

     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203218:	00878963          	beq	a5,s0,ffffffffc020322a <swap_init+0x402>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc020321c:	ff87a703          	lw	a4,-8(a5)
ffffffffc0203220:	679c                	ld	a5,8(a5)
ffffffffc0203222:	397d                	addiw	s2,s2,-1
ffffffffc0203224:	9c99                	subw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203226:	fe879be3          	bne	a5,s0,ffffffffc020321c <swap_init+0x3f4>
     }
     assert(count==0);
ffffffffc020322a:	28091f63          	bnez	s2,ffffffffc02034c8 <swap_init+0x6a0>
     assert(total==0);
ffffffffc020322e:	2a049d63          	bnez	s1,ffffffffc02034e8 <swap_init+0x6c0>

     cprintf("check_swap() succeeded!\n");
ffffffffc0203232:	00005517          	auipc	a0,0x5
ffffffffc0203236:	a9e50513          	addi	a0,a0,-1378 # ffffffffc0207cd0 <commands+0x1570>
ffffffffc020323a:	e97fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc020323e:	b92d                	j	ffffffffc0202e78 <swap_init+0x50>
     int ret, count = 0, total = 0, i;
ffffffffc0203240:	4481                	li	s1,0
ffffffffc0203242:	4901                	li	s2,0
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203244:	4981                	li	s3,0
ffffffffc0203246:	b17d                	j	ffffffffc0202ef4 <swap_init+0xcc>
        assert(PageProperty(p));
ffffffffc0203248:	00005697          	auipc	a3,0x5
ffffffffc020324c:	83868693          	addi	a3,a3,-1992 # ffffffffc0207a80 <commands+0x1320>
ffffffffc0203250:	00004617          	auipc	a2,0x4
ffffffffc0203254:	99060613          	addi	a2,a2,-1648 # ffffffffc0206be0 <commands+0x480>
ffffffffc0203258:	0bc00593          	li	a1,188
ffffffffc020325c:	00004517          	auipc	a0,0x4
ffffffffc0203260:	7fc50513          	addi	a0,a0,2044 # ffffffffc0207a58 <commands+0x12f8>
ffffffffc0203264:	fb1fc0ef          	jal	ra,ffffffffc0200214 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0203268:	00004617          	auipc	a2,0x4
ffffffffc020326c:	d9860613          	addi	a2,a2,-616 # ffffffffc0207000 <commands+0x8a0>
ffffffffc0203270:	06200593          	li	a1,98
ffffffffc0203274:	00004517          	auipc	a0,0x4
ffffffffc0203278:	dac50513          	addi	a0,a0,-596 # ffffffffc0207020 <commands+0x8c0>
ffffffffc020327c:	f99fc0ef          	jal	ra,ffffffffc0200214 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0203280:	00005697          	auipc	a3,0x5
ffffffffc0203284:	9d868693          	addi	a3,a3,-1576 # ffffffffc0207c58 <commands+0x14f8>
ffffffffc0203288:	00004617          	auipc	a2,0x4
ffffffffc020328c:	95860613          	addi	a2,a2,-1704 # ffffffffc0206be0 <commands+0x480>
ffffffffc0203290:	0fc00593          	li	a1,252
ffffffffc0203294:	00004517          	auipc	a0,0x4
ffffffffc0203298:	7c450513          	addi	a0,a0,1988 # ffffffffc0207a58 <commands+0x12f8>
ffffffffc020329c:	f79fc0ef          	jal	ra,ffffffffc0200214 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc02032a0:	00004617          	auipc	a2,0x4
ffffffffc02032a4:	f4060613          	addi	a2,a2,-192 # ffffffffc02071e0 <commands+0xa80>
ffffffffc02032a8:	07400593          	li	a1,116
ffffffffc02032ac:	00004517          	auipc	a0,0x4
ffffffffc02032b0:	d7450513          	addi	a0,a0,-652 # ffffffffc0207020 <commands+0x8c0>
ffffffffc02032b4:	f61fc0ef          	jal	ra,ffffffffc0200214 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc02032b8:	00005697          	auipc	a3,0x5
ffffffffc02032bc:	8c868693          	addi	a3,a3,-1848 # ffffffffc0207b80 <commands+0x1420>
ffffffffc02032c0:	00004617          	auipc	a2,0x4
ffffffffc02032c4:	92060613          	addi	a2,a2,-1760 # ffffffffc0206be0 <commands+0x480>
ffffffffc02032c8:	0dd00593          	li	a1,221
ffffffffc02032cc:	00004517          	auipc	a0,0x4
ffffffffc02032d0:	78c50513          	addi	a0,a0,1932 # ffffffffc0207a58 <commands+0x12f8>
ffffffffc02032d4:	f41fc0ef          	jal	ra,ffffffffc0200214 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc02032d8:	00005697          	auipc	a3,0x5
ffffffffc02032dc:	89068693          	addi	a3,a3,-1904 # ffffffffc0207b68 <commands+0x1408>
ffffffffc02032e0:	00004617          	auipc	a2,0x4
ffffffffc02032e4:	90060613          	addi	a2,a2,-1792 # ffffffffc0206be0 <commands+0x480>
ffffffffc02032e8:	0dc00593          	li	a1,220
ffffffffc02032ec:	00004517          	auipc	a0,0x4
ffffffffc02032f0:	76c50513          	addi	a0,a0,1900 # ffffffffc0207a58 <commands+0x12f8>
ffffffffc02032f4:	f21fc0ef          	jal	ra,ffffffffc0200214 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc02032f8:	00005697          	auipc	a3,0x5
ffffffffc02032fc:	94868693          	addi	a3,a3,-1720 # ffffffffc0207c40 <commands+0x14e0>
ffffffffc0203300:	00004617          	auipc	a2,0x4
ffffffffc0203304:	8e060613          	addi	a2,a2,-1824 # ffffffffc0206be0 <commands+0x480>
ffffffffc0203308:	0fb00593          	li	a1,251
ffffffffc020330c:	00004517          	auipc	a0,0x4
ffffffffc0203310:	74c50513          	addi	a0,a0,1868 # ffffffffc0207a58 <commands+0x12f8>
ffffffffc0203314:	f01fc0ef          	jal	ra,ffffffffc0200214 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc0203318:	00004617          	auipc	a2,0x4
ffffffffc020331c:	72060613          	addi	a2,a2,1824 # ffffffffc0207a38 <commands+0x12d8>
ffffffffc0203320:	02800593          	li	a1,40
ffffffffc0203324:	00004517          	auipc	a0,0x4
ffffffffc0203328:	73450513          	addi	a0,a0,1844 # ffffffffc0207a58 <commands+0x12f8>
ffffffffc020332c:	ee9fc0ef          	jal	ra,ffffffffc0200214 <__panic>
     assert(pgfault_num==2);
ffffffffc0203330:	00005697          	auipc	a3,0x5
ffffffffc0203334:	8d068693          	addi	a3,a3,-1840 # ffffffffc0207c00 <commands+0x14a0>
ffffffffc0203338:	00004617          	auipc	a2,0x4
ffffffffc020333c:	8a860613          	addi	a2,a2,-1880 # ffffffffc0206be0 <commands+0x480>
ffffffffc0203340:	09700593          	li	a1,151
ffffffffc0203344:	00004517          	auipc	a0,0x4
ffffffffc0203348:	71450513          	addi	a0,a0,1812 # ffffffffc0207a58 <commands+0x12f8>
ffffffffc020334c:	ec9fc0ef          	jal	ra,ffffffffc0200214 <__panic>
     assert(pgfault_num==2);
ffffffffc0203350:	00005697          	auipc	a3,0x5
ffffffffc0203354:	8b068693          	addi	a3,a3,-1872 # ffffffffc0207c00 <commands+0x14a0>
ffffffffc0203358:	00004617          	auipc	a2,0x4
ffffffffc020335c:	88860613          	addi	a2,a2,-1912 # ffffffffc0206be0 <commands+0x480>
ffffffffc0203360:	09900593          	li	a1,153
ffffffffc0203364:	00004517          	auipc	a0,0x4
ffffffffc0203368:	6f450513          	addi	a0,a0,1780 # ffffffffc0207a58 <commands+0x12f8>
ffffffffc020336c:	ea9fc0ef          	jal	ra,ffffffffc0200214 <__panic>
     assert(pgfault_num==3);
ffffffffc0203370:	00005697          	auipc	a3,0x5
ffffffffc0203374:	8a068693          	addi	a3,a3,-1888 # ffffffffc0207c10 <commands+0x14b0>
ffffffffc0203378:	00004617          	auipc	a2,0x4
ffffffffc020337c:	86860613          	addi	a2,a2,-1944 # ffffffffc0206be0 <commands+0x480>
ffffffffc0203380:	09b00593          	li	a1,155
ffffffffc0203384:	00004517          	auipc	a0,0x4
ffffffffc0203388:	6d450513          	addi	a0,a0,1748 # ffffffffc0207a58 <commands+0x12f8>
ffffffffc020338c:	e89fc0ef          	jal	ra,ffffffffc0200214 <__panic>
     assert(pgfault_num==3);
ffffffffc0203390:	00005697          	auipc	a3,0x5
ffffffffc0203394:	88068693          	addi	a3,a3,-1920 # ffffffffc0207c10 <commands+0x14b0>
ffffffffc0203398:	00004617          	auipc	a2,0x4
ffffffffc020339c:	84860613          	addi	a2,a2,-1976 # ffffffffc0206be0 <commands+0x480>
ffffffffc02033a0:	09d00593          	li	a1,157
ffffffffc02033a4:	00004517          	auipc	a0,0x4
ffffffffc02033a8:	6b450513          	addi	a0,a0,1716 # ffffffffc0207a58 <commands+0x12f8>
ffffffffc02033ac:	e69fc0ef          	jal	ra,ffffffffc0200214 <__panic>
     assert(pgfault_num==1);
ffffffffc02033b0:	00005697          	auipc	a3,0x5
ffffffffc02033b4:	84068693          	addi	a3,a3,-1984 # ffffffffc0207bf0 <commands+0x1490>
ffffffffc02033b8:	00004617          	auipc	a2,0x4
ffffffffc02033bc:	82860613          	addi	a2,a2,-2008 # ffffffffc0206be0 <commands+0x480>
ffffffffc02033c0:	09300593          	li	a1,147
ffffffffc02033c4:	00004517          	auipc	a0,0x4
ffffffffc02033c8:	69450513          	addi	a0,a0,1684 # ffffffffc0207a58 <commands+0x12f8>
ffffffffc02033cc:	e49fc0ef          	jal	ra,ffffffffc0200214 <__panic>
     assert(pgfault_num==1);
ffffffffc02033d0:	00005697          	auipc	a3,0x5
ffffffffc02033d4:	82068693          	addi	a3,a3,-2016 # ffffffffc0207bf0 <commands+0x1490>
ffffffffc02033d8:	00004617          	auipc	a2,0x4
ffffffffc02033dc:	80860613          	addi	a2,a2,-2040 # ffffffffc0206be0 <commands+0x480>
ffffffffc02033e0:	09500593          	li	a1,149
ffffffffc02033e4:	00004517          	auipc	a0,0x4
ffffffffc02033e8:	67450513          	addi	a0,a0,1652 # ffffffffc0207a58 <commands+0x12f8>
ffffffffc02033ec:	e29fc0ef          	jal	ra,ffffffffc0200214 <__panic>
     assert(pgfault_num==4);
ffffffffc02033f0:	00005697          	auipc	a3,0x5
ffffffffc02033f4:	83068693          	addi	a3,a3,-2000 # ffffffffc0207c20 <commands+0x14c0>
ffffffffc02033f8:	00003617          	auipc	a2,0x3
ffffffffc02033fc:	7e860613          	addi	a2,a2,2024 # ffffffffc0206be0 <commands+0x480>
ffffffffc0203400:	09f00593          	li	a1,159
ffffffffc0203404:	00004517          	auipc	a0,0x4
ffffffffc0203408:	65450513          	addi	a0,a0,1620 # ffffffffc0207a58 <commands+0x12f8>
ffffffffc020340c:	e09fc0ef          	jal	ra,ffffffffc0200214 <__panic>
     assert(pgfault_num==4);
ffffffffc0203410:	00005697          	auipc	a3,0x5
ffffffffc0203414:	81068693          	addi	a3,a3,-2032 # ffffffffc0207c20 <commands+0x14c0>
ffffffffc0203418:	00003617          	auipc	a2,0x3
ffffffffc020341c:	7c860613          	addi	a2,a2,1992 # ffffffffc0206be0 <commands+0x480>
ffffffffc0203420:	0a100593          	li	a1,161
ffffffffc0203424:	00004517          	auipc	a0,0x4
ffffffffc0203428:	63450513          	addi	a0,a0,1588 # ffffffffc0207a58 <commands+0x12f8>
ffffffffc020342c:	de9fc0ef          	jal	ra,ffffffffc0200214 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0203430:	00004697          	auipc	a3,0x4
ffffffffc0203434:	50868693          	addi	a3,a3,1288 # ffffffffc0207938 <commands+0x11d8>
ffffffffc0203438:	00003617          	auipc	a2,0x3
ffffffffc020343c:	7a860613          	addi	a2,a2,1960 # ffffffffc0206be0 <commands+0x480>
ffffffffc0203440:	0cc00593          	li	a1,204
ffffffffc0203444:	00004517          	auipc	a0,0x4
ffffffffc0203448:	61450513          	addi	a0,a0,1556 # ffffffffc0207a58 <commands+0x12f8>
ffffffffc020344c:	dc9fc0ef          	jal	ra,ffffffffc0200214 <__panic>
     assert(vma != NULL);
ffffffffc0203450:	00004697          	auipc	a3,0x4
ffffffffc0203454:	58868693          	addi	a3,a3,1416 # ffffffffc02079d8 <commands+0x1278>
ffffffffc0203458:	00003617          	auipc	a2,0x3
ffffffffc020345c:	78860613          	addi	a2,a2,1928 # ffffffffc0206be0 <commands+0x480>
ffffffffc0203460:	0cf00593          	li	a1,207
ffffffffc0203464:	00004517          	auipc	a0,0x4
ffffffffc0203468:	5f450513          	addi	a0,a0,1524 # ffffffffc0207a58 <commands+0x12f8>
ffffffffc020346c:	da9fc0ef          	jal	ra,ffffffffc0200214 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc0203470:	00004697          	auipc	a3,0x4
ffffffffc0203474:	6b868693          	addi	a3,a3,1720 # ffffffffc0207b28 <commands+0x13c8>
ffffffffc0203478:	00003617          	auipc	a2,0x3
ffffffffc020347c:	76860613          	addi	a2,a2,1896 # ffffffffc0206be0 <commands+0x480>
ffffffffc0203480:	0d700593          	li	a1,215
ffffffffc0203484:	00004517          	auipc	a0,0x4
ffffffffc0203488:	5d450513          	addi	a0,a0,1492 # ffffffffc0207a58 <commands+0x12f8>
ffffffffc020348c:	d89fc0ef          	jal	ra,ffffffffc0200214 <__panic>
     assert( nr_free == 0);         
ffffffffc0203490:	00004697          	auipc	a3,0x4
ffffffffc0203494:	7a068693          	addi	a3,a3,1952 # ffffffffc0207c30 <commands+0x14d0>
ffffffffc0203498:	00003617          	auipc	a2,0x3
ffffffffc020349c:	74860613          	addi	a2,a2,1864 # ffffffffc0206be0 <commands+0x480>
ffffffffc02034a0:	0f300593          	li	a1,243
ffffffffc02034a4:	00004517          	auipc	a0,0x4
ffffffffc02034a8:	5b450513          	addi	a0,a0,1460 # ffffffffc0207a58 <commands+0x12f8>
ffffffffc02034ac:	d69fc0ef          	jal	ra,ffffffffc0200214 <__panic>
    return KADDR(page2pa(page));
ffffffffc02034b0:	00004617          	auipc	a2,0x4
ffffffffc02034b4:	b1860613          	addi	a2,a2,-1256 # ffffffffc0206fc8 <commands+0x868>
ffffffffc02034b8:	06900593          	li	a1,105
ffffffffc02034bc:	00004517          	auipc	a0,0x4
ffffffffc02034c0:	b6450513          	addi	a0,a0,-1180 # ffffffffc0207020 <commands+0x8c0>
ffffffffc02034c4:	d51fc0ef          	jal	ra,ffffffffc0200214 <__panic>
     assert(count==0);
ffffffffc02034c8:	00004697          	auipc	a3,0x4
ffffffffc02034cc:	7e868693          	addi	a3,a3,2024 # ffffffffc0207cb0 <commands+0x1550>
ffffffffc02034d0:	00003617          	auipc	a2,0x3
ffffffffc02034d4:	71060613          	addi	a2,a2,1808 # ffffffffc0206be0 <commands+0x480>
ffffffffc02034d8:	11d00593          	li	a1,285
ffffffffc02034dc:	00004517          	auipc	a0,0x4
ffffffffc02034e0:	57c50513          	addi	a0,a0,1404 # ffffffffc0207a58 <commands+0x12f8>
ffffffffc02034e4:	d31fc0ef          	jal	ra,ffffffffc0200214 <__panic>
     assert(total==0);
ffffffffc02034e8:	00004697          	auipc	a3,0x4
ffffffffc02034ec:	7d868693          	addi	a3,a3,2008 # ffffffffc0207cc0 <commands+0x1560>
ffffffffc02034f0:	00003617          	auipc	a2,0x3
ffffffffc02034f4:	6f060613          	addi	a2,a2,1776 # ffffffffc0206be0 <commands+0x480>
ffffffffc02034f8:	11e00593          	li	a1,286
ffffffffc02034fc:	00004517          	auipc	a0,0x4
ffffffffc0203500:	55c50513          	addi	a0,a0,1372 # ffffffffc0207a58 <commands+0x12f8>
ffffffffc0203504:	d11fc0ef          	jal	ra,ffffffffc0200214 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0203508:	00004697          	auipc	a3,0x4
ffffffffc020350c:	69868693          	addi	a3,a3,1688 # ffffffffc0207ba0 <commands+0x1440>
ffffffffc0203510:	00003617          	auipc	a2,0x3
ffffffffc0203514:	6d060613          	addi	a2,a2,1744 # ffffffffc0206be0 <commands+0x480>
ffffffffc0203518:	0ea00593          	li	a1,234
ffffffffc020351c:	00004517          	auipc	a0,0x4
ffffffffc0203520:	53c50513          	addi	a0,a0,1340 # ffffffffc0207a58 <commands+0x12f8>
ffffffffc0203524:	cf1fc0ef          	jal	ra,ffffffffc0200214 <__panic>
     assert(mm != NULL);
ffffffffc0203528:	00004697          	auipc	a3,0x4
ffffffffc020352c:	28868693          	addi	a3,a3,648 # ffffffffc02077b0 <commands+0x1050>
ffffffffc0203530:	00003617          	auipc	a2,0x3
ffffffffc0203534:	6b060613          	addi	a2,a2,1712 # ffffffffc0206be0 <commands+0x480>
ffffffffc0203538:	0c400593          	li	a1,196
ffffffffc020353c:	00004517          	auipc	a0,0x4
ffffffffc0203540:	51c50513          	addi	a0,a0,1308 # ffffffffc0207a58 <commands+0x12f8>
ffffffffc0203544:	cd1fc0ef          	jal	ra,ffffffffc0200214 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0203548:	00004697          	auipc	a3,0x4
ffffffffc020354c:	59068693          	addi	a3,a3,1424 # ffffffffc0207ad8 <commands+0x1378>
ffffffffc0203550:	00003617          	auipc	a2,0x3
ffffffffc0203554:	69060613          	addi	a2,a2,1680 # ffffffffc0206be0 <commands+0x480>
ffffffffc0203558:	0c700593          	li	a1,199
ffffffffc020355c:	00004517          	auipc	a0,0x4
ffffffffc0203560:	4fc50513          	addi	a0,a0,1276 # ffffffffc0207a58 <commands+0x12f8>
ffffffffc0203564:	cb1fc0ef          	jal	ra,ffffffffc0200214 <__panic>
     assert(ret==0);
ffffffffc0203568:	00004697          	auipc	a3,0x4
ffffffffc020356c:	74068693          	addi	a3,a3,1856 # ffffffffc0207ca8 <commands+0x1548>
ffffffffc0203570:	00003617          	auipc	a2,0x3
ffffffffc0203574:	67060613          	addi	a2,a2,1648 # ffffffffc0206be0 <commands+0x480>
ffffffffc0203578:	10200593          	li	a1,258
ffffffffc020357c:	00004517          	auipc	a0,0x4
ffffffffc0203580:	4dc50513          	addi	a0,a0,1244 # ffffffffc0207a58 <commands+0x12f8>
ffffffffc0203584:	c91fc0ef          	jal	ra,ffffffffc0200214 <__panic>
     assert(total == nr_free_pages());
ffffffffc0203588:	00004697          	auipc	a3,0x4
ffffffffc020358c:	50868693          	addi	a3,a3,1288 # ffffffffc0207a90 <commands+0x1330>
ffffffffc0203590:	00003617          	auipc	a2,0x3
ffffffffc0203594:	65060613          	addi	a2,a2,1616 # ffffffffc0206be0 <commands+0x480>
ffffffffc0203598:	0bf00593          	li	a1,191
ffffffffc020359c:	00004517          	auipc	a0,0x4
ffffffffc02035a0:	4bc50513          	addi	a0,a0,1212 # ffffffffc0207a58 <commands+0x12f8>
ffffffffc02035a4:	c71fc0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc02035a8 <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc02035a8:	000a9797          	auipc	a5,0xa9
ffffffffc02035ac:	2c878793          	addi	a5,a5,712 # ffffffffc02ac870 <sm>
ffffffffc02035b0:	639c                	ld	a5,0(a5)
ffffffffc02035b2:	0107b303          	ld	t1,16(a5)
ffffffffc02035b6:	8302                	jr	t1

ffffffffc02035b8 <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc02035b8:	000a9797          	auipc	a5,0xa9
ffffffffc02035bc:	2b878793          	addi	a5,a5,696 # ffffffffc02ac870 <sm>
ffffffffc02035c0:	639c                	ld	a5,0(a5)
ffffffffc02035c2:	0207b303          	ld	t1,32(a5)
ffffffffc02035c6:	8302                	jr	t1

ffffffffc02035c8 <swap_out>:
{
ffffffffc02035c8:	711d                	addi	sp,sp,-96
ffffffffc02035ca:	ec86                	sd	ra,88(sp)
ffffffffc02035cc:	e8a2                	sd	s0,80(sp)
ffffffffc02035ce:	e4a6                	sd	s1,72(sp)
ffffffffc02035d0:	e0ca                	sd	s2,64(sp)
ffffffffc02035d2:	fc4e                	sd	s3,56(sp)
ffffffffc02035d4:	f852                	sd	s4,48(sp)
ffffffffc02035d6:	f456                	sd	s5,40(sp)
ffffffffc02035d8:	f05a                	sd	s6,32(sp)
ffffffffc02035da:	ec5e                	sd	s7,24(sp)
ffffffffc02035dc:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc02035de:	cde9                	beqz	a1,ffffffffc02036b8 <swap_out+0xf0>
ffffffffc02035e0:	8ab2                	mv	s5,a2
ffffffffc02035e2:	892a                	mv	s2,a0
ffffffffc02035e4:	8a2e                	mv	s4,a1
ffffffffc02035e6:	4401                	li	s0,0
ffffffffc02035e8:	000a9997          	auipc	s3,0xa9
ffffffffc02035ec:	28898993          	addi	s3,s3,648 # ffffffffc02ac870 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc02035f0:	00004b17          	auipc	s6,0x4
ffffffffc02035f4:	760b0b13          	addi	s6,s6,1888 # ffffffffc0207d50 <commands+0x15f0>
                    cprintf("SWAP: failed to save\n");
ffffffffc02035f8:	00004b97          	auipc	s7,0x4
ffffffffc02035fc:	740b8b93          	addi	s7,s7,1856 # ffffffffc0207d38 <commands+0x15d8>
ffffffffc0203600:	a825                	j	ffffffffc0203638 <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203602:	67a2                	ld	a5,8(sp)
ffffffffc0203604:	8626                	mv	a2,s1
ffffffffc0203606:	85a2                	mv	a1,s0
ffffffffc0203608:	7f94                	ld	a3,56(a5)
ffffffffc020360a:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc020360c:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc020360e:	82b1                	srli	a3,a3,0xc
ffffffffc0203610:	0685                	addi	a3,a3,1
ffffffffc0203612:	abffc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0203616:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0203618:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc020361a:	7d1c                	ld	a5,56(a0)
ffffffffc020361c:	83b1                	srli	a5,a5,0xc
ffffffffc020361e:	0785                	addi	a5,a5,1
ffffffffc0203620:	07a2                	slli	a5,a5,0x8
ffffffffc0203622:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc0203626:	8bdfd0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc020362a:	01893503          	ld	a0,24(s2)
ffffffffc020362e:	85a6                	mv	a1,s1
ffffffffc0203630:	cbdfe0ef          	jal	ra,ffffffffc02022ec <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0203634:	048a0d63          	beq	s4,s0,ffffffffc020368e <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0203638:	0009b783          	ld	a5,0(s3)
ffffffffc020363c:	8656                	mv	a2,s5
ffffffffc020363e:	002c                	addi	a1,sp,8
ffffffffc0203640:	7b9c                	ld	a5,48(a5)
ffffffffc0203642:	854a                	mv	a0,s2
ffffffffc0203644:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0203646:	e12d                	bnez	a0,ffffffffc02036a8 <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0203648:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc020364a:	01893503          	ld	a0,24(s2)
ffffffffc020364e:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0203650:	7f84                	ld	s1,56(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203652:	85a6                	mv	a1,s1
ffffffffc0203654:	915fd0ef          	jal	ra,ffffffffc0200f68 <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203658:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc020365a:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc020365c:	8b85                	andi	a5,a5,1
ffffffffc020365e:	cfb9                	beqz	a5,ffffffffc02036bc <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0203660:	65a2                	ld	a1,8(sp)
ffffffffc0203662:	7d9c                	ld	a5,56(a1)
ffffffffc0203664:	83b1                	srli	a5,a5,0xc
ffffffffc0203666:	00178513          	addi	a0,a5,1
ffffffffc020366a:	0522                	slli	a0,a0,0x8
ffffffffc020366c:	570010ef          	jal	ra,ffffffffc0204bdc <swapfs_write>
ffffffffc0203670:	d949                	beqz	a0,ffffffffc0203602 <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203672:	855e                	mv	a0,s7
ffffffffc0203674:	a5dfc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203678:	0009b783          	ld	a5,0(s3)
ffffffffc020367c:	6622                	ld	a2,8(sp)
ffffffffc020367e:	4681                	li	a3,0
ffffffffc0203680:	739c                	ld	a5,32(a5)
ffffffffc0203682:	85a6                	mv	a1,s1
ffffffffc0203684:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0203686:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203688:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc020368a:	fa8a17e3          	bne	s4,s0,ffffffffc0203638 <swap_out+0x70>
}
ffffffffc020368e:	8522                	mv	a0,s0
ffffffffc0203690:	60e6                	ld	ra,88(sp)
ffffffffc0203692:	6446                	ld	s0,80(sp)
ffffffffc0203694:	64a6                	ld	s1,72(sp)
ffffffffc0203696:	6906                	ld	s2,64(sp)
ffffffffc0203698:	79e2                	ld	s3,56(sp)
ffffffffc020369a:	7a42                	ld	s4,48(sp)
ffffffffc020369c:	7aa2                	ld	s5,40(sp)
ffffffffc020369e:	7b02                	ld	s6,32(sp)
ffffffffc02036a0:	6be2                	ld	s7,24(sp)
ffffffffc02036a2:	6c42                	ld	s8,16(sp)
ffffffffc02036a4:	6125                	addi	sp,sp,96
ffffffffc02036a6:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc02036a8:	85a2                	mv	a1,s0
ffffffffc02036aa:	00004517          	auipc	a0,0x4
ffffffffc02036ae:	64650513          	addi	a0,a0,1606 # ffffffffc0207cf0 <commands+0x1590>
ffffffffc02036b2:	a1ffc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
                  break;
ffffffffc02036b6:	bfe1                	j	ffffffffc020368e <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc02036b8:	4401                	li	s0,0
ffffffffc02036ba:	bfd1                	j	ffffffffc020368e <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc02036bc:	00004697          	auipc	a3,0x4
ffffffffc02036c0:	66468693          	addi	a3,a3,1636 # ffffffffc0207d20 <commands+0x15c0>
ffffffffc02036c4:	00003617          	auipc	a2,0x3
ffffffffc02036c8:	51c60613          	addi	a2,a2,1308 # ffffffffc0206be0 <commands+0x480>
ffffffffc02036cc:	06800593          	li	a1,104
ffffffffc02036d0:	00004517          	auipc	a0,0x4
ffffffffc02036d4:	38850513          	addi	a0,a0,904 # ffffffffc0207a58 <commands+0x12f8>
ffffffffc02036d8:	b3dfc0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc02036dc <swap_in>:
{
ffffffffc02036dc:	7179                	addi	sp,sp,-48
ffffffffc02036de:	e84a                	sd	s2,16(sp)
ffffffffc02036e0:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc02036e2:	4505                	li	a0,1
{
ffffffffc02036e4:	ec26                	sd	s1,24(sp)
ffffffffc02036e6:	e44e                	sd	s3,8(sp)
ffffffffc02036e8:	f406                	sd	ra,40(sp)
ffffffffc02036ea:	f022                	sd	s0,32(sp)
ffffffffc02036ec:	84ae                	mv	s1,a1
ffffffffc02036ee:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc02036f0:	f6afd0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
     assert(result!=NULL);
ffffffffc02036f4:	c129                	beqz	a0,ffffffffc0203736 <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc02036f6:	842a                	mv	s0,a0
ffffffffc02036f8:	01893503          	ld	a0,24(s2)
ffffffffc02036fc:	4601                	li	a2,0
ffffffffc02036fe:	85a6                	mv	a1,s1
ffffffffc0203700:	869fd0ef          	jal	ra,ffffffffc0200f68 <get_pte>
ffffffffc0203704:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc0203706:	6108                	ld	a0,0(a0)
ffffffffc0203708:	85a2                	mv	a1,s0
ffffffffc020370a:	43a010ef          	jal	ra,ffffffffc0204b44 <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc020370e:	00093583          	ld	a1,0(s2)
ffffffffc0203712:	8626                	mv	a2,s1
ffffffffc0203714:	00004517          	auipc	a0,0x4
ffffffffc0203718:	2e450513          	addi	a0,a0,740 # ffffffffc02079f8 <commands+0x1298>
ffffffffc020371c:	81a1                	srli	a1,a1,0x8
ffffffffc020371e:	9b3fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
}
ffffffffc0203722:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc0203724:	0089b023          	sd	s0,0(s3)
}
ffffffffc0203728:	7402                	ld	s0,32(sp)
ffffffffc020372a:	64e2                	ld	s1,24(sp)
ffffffffc020372c:	6942                	ld	s2,16(sp)
ffffffffc020372e:	69a2                	ld	s3,8(sp)
ffffffffc0203730:	4501                	li	a0,0
ffffffffc0203732:	6145                	addi	sp,sp,48
ffffffffc0203734:	8082                	ret
     assert(result!=NULL);
ffffffffc0203736:	00004697          	auipc	a3,0x4
ffffffffc020373a:	2b268693          	addi	a3,a3,690 # ffffffffc02079e8 <commands+0x1288>
ffffffffc020373e:	00003617          	auipc	a2,0x3
ffffffffc0203742:	4a260613          	addi	a2,a2,1186 # ffffffffc0206be0 <commands+0x480>
ffffffffc0203746:	07e00593          	li	a1,126
ffffffffc020374a:	00004517          	auipc	a0,0x4
ffffffffc020374e:	30e50513          	addi	a0,a0,782 # ffffffffc0207a58 <commands+0x12f8>
ffffffffc0203752:	ac3fc0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0203756 <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc0203756:	c125                	beqz	a0,ffffffffc02037b6 <slob_free+0x60>
		return;

	if (size)
ffffffffc0203758:	e1a5                	bnez	a1,ffffffffc02037b8 <slob_free+0x62>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020375a:	100027f3          	csrr	a5,sstatus
ffffffffc020375e:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0203760:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203762:	e3bd                	bnez	a5,ffffffffc02037c8 <slob_free+0x72>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0203764:	0009e797          	auipc	a5,0x9e
ffffffffc0203768:	cd478793          	addi	a5,a5,-812 # ffffffffc02a1438 <slobfree>
ffffffffc020376c:	639c                	ld	a5,0(a5)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc020376e:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0203770:	00a7fa63          	bgeu	a5,a0,ffffffffc0203784 <slob_free+0x2e>
ffffffffc0203774:	00e56c63          	bltu	a0,a4,ffffffffc020378c <slob_free+0x36>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0203778:	00e7fa63          	bgeu	a5,a4,ffffffffc020378c <slob_free+0x36>
    return 0;
ffffffffc020377c:	87ba                	mv	a5,a4
ffffffffc020377e:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0203780:	fea7eae3          	bltu	a5,a0,ffffffffc0203774 <slob_free+0x1e>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0203784:	fee7ece3          	bltu	a5,a4,ffffffffc020377c <slob_free+0x26>
ffffffffc0203788:	fee57ae3          	bgeu	a0,a4,ffffffffc020377c <slob_free+0x26>
			break;

	if (b + b->units == cur->next) {
ffffffffc020378c:	4110                	lw	a2,0(a0)
ffffffffc020378e:	00461693          	slli	a3,a2,0x4
ffffffffc0203792:	96aa                	add	a3,a3,a0
ffffffffc0203794:	08d70b63          	beq	a4,a3,ffffffffc020382a <slob_free+0xd4>
		b->units += cur->next->units;
		b->next = cur->next->next;
	} else
		b->next = cur->next;

	if (cur + cur->units == b) {
ffffffffc0203798:	4394                	lw	a3,0(a5)
		b->next = cur->next;
ffffffffc020379a:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc020379c:	00469713          	slli	a4,a3,0x4
ffffffffc02037a0:	973e                	add	a4,a4,a5
ffffffffc02037a2:	08e50f63          	beq	a0,a4,ffffffffc0203840 <slob_free+0xea>
		cur->units += b->units;
		cur->next = b->next;
	} else
		cur->next = b;
ffffffffc02037a6:	e788                	sd	a0,8(a5)

	slobfree = cur;
ffffffffc02037a8:	0009e717          	auipc	a4,0x9e
ffffffffc02037ac:	c8f73823          	sd	a5,-880(a4) # ffffffffc02a1438 <slobfree>
    if (flag) {
ffffffffc02037b0:	c199                	beqz	a1,ffffffffc02037b6 <slob_free+0x60>
        intr_enable();
ffffffffc02037b2:	e9dfc06f          	j	ffffffffc020064e <intr_enable>
ffffffffc02037b6:	8082                	ret
		b->units = SLOB_UNITS(size);
ffffffffc02037b8:	05bd                	addi	a1,a1,15
ffffffffc02037ba:	8191                	srli	a1,a1,0x4
ffffffffc02037bc:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02037be:	100027f3          	csrr	a5,sstatus
ffffffffc02037c2:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02037c4:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02037c6:	dfd9                	beqz	a5,ffffffffc0203764 <slob_free+0xe>
{
ffffffffc02037c8:	1101                	addi	sp,sp,-32
ffffffffc02037ca:	e42a                	sd	a0,8(sp)
ffffffffc02037cc:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc02037ce:	e87fc0ef          	jal	ra,ffffffffc0200654 <intr_disable>
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02037d2:	0009e797          	auipc	a5,0x9e
ffffffffc02037d6:	c6678793          	addi	a5,a5,-922 # ffffffffc02a1438 <slobfree>
ffffffffc02037da:	639c                	ld	a5,0(a5)
        return 1;
ffffffffc02037dc:	6522                	ld	a0,8(sp)
ffffffffc02037de:	4585                	li	a1,1
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02037e0:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02037e2:	00a7fa63          	bgeu	a5,a0,ffffffffc02037f6 <slob_free+0xa0>
ffffffffc02037e6:	00e56c63          	bltu	a0,a4,ffffffffc02037fe <slob_free+0xa8>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02037ea:	00e7fa63          	bgeu	a5,a4,ffffffffc02037fe <slob_free+0xa8>
    return 0;
ffffffffc02037ee:	87ba                	mv	a5,a4
ffffffffc02037f0:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02037f2:	fea7eae3          	bltu	a5,a0,ffffffffc02037e6 <slob_free+0x90>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02037f6:	fee7ece3          	bltu	a5,a4,ffffffffc02037ee <slob_free+0x98>
ffffffffc02037fa:	fee57ae3          	bgeu	a0,a4,ffffffffc02037ee <slob_free+0x98>
	if (b + b->units == cur->next) {
ffffffffc02037fe:	4110                	lw	a2,0(a0)
ffffffffc0203800:	00461693          	slli	a3,a2,0x4
ffffffffc0203804:	96aa                	add	a3,a3,a0
ffffffffc0203806:	04d70763          	beq	a4,a3,ffffffffc0203854 <slob_free+0xfe>
		b->next = cur->next;
ffffffffc020380a:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc020380c:	4394                	lw	a3,0(a5)
ffffffffc020380e:	00469713          	slli	a4,a3,0x4
ffffffffc0203812:	973e                	add	a4,a4,a5
ffffffffc0203814:	04e50663          	beq	a0,a4,ffffffffc0203860 <slob_free+0x10a>
		cur->next = b;
ffffffffc0203818:	e788                	sd	a0,8(a5)
	slobfree = cur;
ffffffffc020381a:	0009e717          	auipc	a4,0x9e
ffffffffc020381e:	c0f73f23          	sd	a5,-994(a4) # ffffffffc02a1438 <slobfree>
    if (flag) {
ffffffffc0203822:	e58d                	bnez	a1,ffffffffc020384c <slob_free+0xf6>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc0203824:	60e2                	ld	ra,24(sp)
ffffffffc0203826:	6105                	addi	sp,sp,32
ffffffffc0203828:	8082                	ret
		b->units += cur->next->units;
ffffffffc020382a:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc020382c:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc020382e:	9e35                	addw	a2,a2,a3
ffffffffc0203830:	c110                	sw	a2,0(a0)
	if (cur + cur->units == b) {
ffffffffc0203832:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc0203834:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc0203836:	00469713          	slli	a4,a3,0x4
ffffffffc020383a:	973e                	add	a4,a4,a5
ffffffffc020383c:	f6e515e3          	bne	a0,a4,ffffffffc02037a6 <slob_free+0x50>
		cur->units += b->units;
ffffffffc0203840:	4118                	lw	a4,0(a0)
		cur->next = b->next;
ffffffffc0203842:	6510                	ld	a2,8(a0)
		cur->units += b->units;
ffffffffc0203844:	9eb9                	addw	a3,a3,a4
ffffffffc0203846:	c394                	sw	a3,0(a5)
		cur->next = b->next;
ffffffffc0203848:	e790                	sd	a2,8(a5)
ffffffffc020384a:	bfb9                	j	ffffffffc02037a8 <slob_free+0x52>
}
ffffffffc020384c:	60e2                	ld	ra,24(sp)
ffffffffc020384e:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0203850:	dfffc06f          	j	ffffffffc020064e <intr_enable>
		b->units += cur->next->units;
ffffffffc0203854:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0203856:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc0203858:	9e35                	addw	a2,a2,a3
ffffffffc020385a:	c110                	sw	a2,0(a0)
		b->next = cur->next->next;
ffffffffc020385c:	e518                	sd	a4,8(a0)
ffffffffc020385e:	b77d                	j	ffffffffc020380c <slob_free+0xb6>
		cur->units += b->units;
ffffffffc0203860:	4118                	lw	a4,0(a0)
		cur->next = b->next;
ffffffffc0203862:	6510                	ld	a2,8(a0)
		cur->units += b->units;
ffffffffc0203864:	9eb9                	addw	a3,a3,a4
ffffffffc0203866:	c394                	sw	a3,0(a5)
		cur->next = b->next;
ffffffffc0203868:	e790                	sd	a2,8(a5)
ffffffffc020386a:	bf45                	j	ffffffffc020381a <slob_free+0xc4>

ffffffffc020386c <__slob_get_free_pages.isra.0>:
  struct Page * page = alloc_pages(1 << order);
ffffffffc020386c:	4785                	li	a5,1
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc020386e:	1141                	addi	sp,sp,-16
  struct Page * page = alloc_pages(1 << order);
ffffffffc0203870:	00a7953b          	sllw	a0,a5,a0
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0203874:	e406                	sd	ra,8(sp)
  struct Page * page = alloc_pages(1 << order);
ffffffffc0203876:	de4fd0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
  if(!page)
ffffffffc020387a:	cd1d                	beqz	a0,ffffffffc02038b8 <__slob_get_free_pages.isra.0+0x4c>
    return page - pages + nbase;
ffffffffc020387c:	000a9797          	auipc	a5,0xa9
ffffffffc0203880:	04c78793          	addi	a5,a5,76 # ffffffffc02ac8c8 <pages>
ffffffffc0203884:	6394                	ld	a3,0(a5)
ffffffffc0203886:	00005797          	auipc	a5,0x5
ffffffffc020388a:	46278793          	addi	a5,a5,1122 # ffffffffc0208ce8 <nbase>
ffffffffc020388e:	8d15                	sub	a0,a0,a3
ffffffffc0203890:	6394                	ld	a3,0(a5)
ffffffffc0203892:	8519                	srai	a0,a0,0x6
    return KADDR(page2pa(page));
ffffffffc0203894:	000a9797          	auipc	a5,0xa9
ffffffffc0203898:	fcc78793          	addi	a5,a5,-52 # ffffffffc02ac860 <npage>
    return page - pages + nbase;
ffffffffc020389c:	9536                	add	a0,a0,a3
    return KADDR(page2pa(page));
ffffffffc020389e:	6398                	ld	a4,0(a5)
ffffffffc02038a0:	00c51793          	slli	a5,a0,0xc
ffffffffc02038a4:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02038a6:	0532                	slli	a0,a0,0xc
    return KADDR(page2pa(page));
ffffffffc02038a8:	00e7fb63          	bgeu	a5,a4,ffffffffc02038be <__slob_get_free_pages.isra.0+0x52>
ffffffffc02038ac:	000a9797          	auipc	a5,0xa9
ffffffffc02038b0:	00c78793          	addi	a5,a5,12 # ffffffffc02ac8b8 <va_pa_offset>
ffffffffc02038b4:	6394                	ld	a3,0(a5)
ffffffffc02038b6:	9536                	add	a0,a0,a3
}
ffffffffc02038b8:	60a2                	ld	ra,8(sp)
ffffffffc02038ba:	0141                	addi	sp,sp,16
ffffffffc02038bc:	8082                	ret
ffffffffc02038be:	86aa                	mv	a3,a0
ffffffffc02038c0:	00003617          	auipc	a2,0x3
ffffffffc02038c4:	70860613          	addi	a2,a2,1800 # ffffffffc0206fc8 <commands+0x868>
ffffffffc02038c8:	06900593          	li	a1,105
ffffffffc02038cc:	00003517          	auipc	a0,0x3
ffffffffc02038d0:	75450513          	addi	a0,a0,1876 # ffffffffc0207020 <commands+0x8c0>
ffffffffc02038d4:	941fc0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc02038d8 <slob_alloc.isra.1.constprop.3>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc02038d8:	1101                	addi	sp,sp,-32
ffffffffc02038da:	ec06                	sd	ra,24(sp)
ffffffffc02038dc:	e822                	sd	s0,16(sp)
ffffffffc02038de:	e426                	sd	s1,8(sp)
ffffffffc02038e0:	e04a                	sd	s2,0(sp)
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc02038e2:	01050713          	addi	a4,a0,16
ffffffffc02038e6:	6785                	lui	a5,0x1
ffffffffc02038e8:	0cf77563          	bgeu	a4,a5,ffffffffc02039b2 <slob_alloc.isra.1.constprop.3+0xda>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc02038ec:	00f50493          	addi	s1,a0,15
ffffffffc02038f0:	8091                	srli	s1,s1,0x4
ffffffffc02038f2:	2481                	sext.w	s1,s1
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02038f4:	10002673          	csrr	a2,sstatus
ffffffffc02038f8:	8a09                	andi	a2,a2,2
ffffffffc02038fa:	e64d                	bnez	a2,ffffffffc02039a4 <slob_alloc.isra.1.constprop.3+0xcc>
	prev = slobfree;
ffffffffc02038fc:	0009e917          	auipc	s2,0x9e
ffffffffc0203900:	b3c90913          	addi	s2,s2,-1220 # ffffffffc02a1438 <slobfree>
ffffffffc0203904:	00093683          	ld	a3,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0203908:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc020390a:	4398                	lw	a4,0(a5)
ffffffffc020390c:	0a975063          	bge	a4,s1,ffffffffc02039ac <slob_alloc.isra.1.constprop.3+0xd4>
		if (cur == slobfree) {
ffffffffc0203910:	00d78b63          	beq	a5,a3,ffffffffc0203926 <slob_alloc.isra.1.constprop.3+0x4e>
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0203914:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0203916:	4018                	lw	a4,0(s0)
ffffffffc0203918:	02975a63          	bge	a4,s1,ffffffffc020394c <slob_alloc.isra.1.constprop.3+0x74>
ffffffffc020391c:	00093683          	ld	a3,0(s2)
ffffffffc0203920:	87a2                	mv	a5,s0
		if (cur == slobfree) {
ffffffffc0203922:	fed799e3          	bne	a5,a3,ffffffffc0203914 <slob_alloc.isra.1.constprop.3+0x3c>
    if (flag) {
ffffffffc0203926:	e225                	bnez	a2,ffffffffc0203986 <slob_alloc.isra.1.constprop.3+0xae>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0203928:	4501                	li	a0,0
ffffffffc020392a:	f43ff0ef          	jal	ra,ffffffffc020386c <__slob_get_free_pages.isra.0>
ffffffffc020392e:	842a                	mv	s0,a0
			if (!cur)
ffffffffc0203930:	cd15                	beqz	a0,ffffffffc020396c <slob_alloc.isra.1.constprop.3+0x94>
			slob_free(cur, PAGE_SIZE);
ffffffffc0203932:	6585                	lui	a1,0x1
ffffffffc0203934:	e23ff0ef          	jal	ra,ffffffffc0203756 <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203938:	10002673          	csrr	a2,sstatus
ffffffffc020393c:	8a09                	andi	a2,a2,2
ffffffffc020393e:	ee15                	bnez	a2,ffffffffc020397a <slob_alloc.isra.1.constprop.3+0xa2>
			cur = slobfree;
ffffffffc0203940:	00093783          	ld	a5,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0203944:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0203946:	4018                	lw	a4,0(s0)
ffffffffc0203948:	fc974ae3          	blt	a4,s1,ffffffffc020391c <slob_alloc.isra.1.constprop.3+0x44>
			if (cur->units == units) /* exact fit? */
ffffffffc020394c:	04e48963          	beq	s1,a4,ffffffffc020399e <slob_alloc.isra.1.constprop.3+0xc6>
				prev->next = cur + units;
ffffffffc0203950:	00449693          	slli	a3,s1,0x4
ffffffffc0203954:	96a2                	add	a3,a3,s0
ffffffffc0203956:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc0203958:	640c                	ld	a1,8(s0)
				prev->next->units = cur->units - units;
ffffffffc020395a:	9f05                	subw	a4,a4,s1
ffffffffc020395c:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc020395e:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc0203960:	c004                	sw	s1,0(s0)
			slobfree = prev;
ffffffffc0203962:	0009e717          	auipc	a4,0x9e
ffffffffc0203966:	acf73b23          	sd	a5,-1322(a4) # ffffffffc02a1438 <slobfree>
    if (flag) {
ffffffffc020396a:	e20d                	bnez	a2,ffffffffc020398c <slob_alloc.isra.1.constprop.3+0xb4>
}
ffffffffc020396c:	8522                	mv	a0,s0
ffffffffc020396e:	60e2                	ld	ra,24(sp)
ffffffffc0203970:	6442                	ld	s0,16(sp)
ffffffffc0203972:	64a2                	ld	s1,8(sp)
ffffffffc0203974:	6902                	ld	s2,0(sp)
ffffffffc0203976:	6105                	addi	sp,sp,32
ffffffffc0203978:	8082                	ret
        intr_disable();
ffffffffc020397a:	cdbfc0ef          	jal	ra,ffffffffc0200654 <intr_disable>
ffffffffc020397e:	4605                	li	a2,1
			cur = slobfree;
ffffffffc0203980:	00093783          	ld	a5,0(s2)
ffffffffc0203984:	b7c1                	j	ffffffffc0203944 <slob_alloc.isra.1.constprop.3+0x6c>
        intr_enable();
ffffffffc0203986:	cc9fc0ef          	jal	ra,ffffffffc020064e <intr_enable>
ffffffffc020398a:	bf79                	j	ffffffffc0203928 <slob_alloc.isra.1.constprop.3+0x50>
ffffffffc020398c:	cc3fc0ef          	jal	ra,ffffffffc020064e <intr_enable>
}
ffffffffc0203990:	8522                	mv	a0,s0
ffffffffc0203992:	60e2                	ld	ra,24(sp)
ffffffffc0203994:	6442                	ld	s0,16(sp)
ffffffffc0203996:	64a2                	ld	s1,8(sp)
ffffffffc0203998:	6902                	ld	s2,0(sp)
ffffffffc020399a:	6105                	addi	sp,sp,32
ffffffffc020399c:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc020399e:	6418                	ld	a4,8(s0)
ffffffffc02039a0:	e798                	sd	a4,8(a5)
ffffffffc02039a2:	b7c1                	j	ffffffffc0203962 <slob_alloc.isra.1.constprop.3+0x8a>
        intr_disable();
ffffffffc02039a4:	cb1fc0ef          	jal	ra,ffffffffc0200654 <intr_disable>
ffffffffc02039a8:	4605                	li	a2,1
ffffffffc02039aa:	bf89                	j	ffffffffc02038fc <slob_alloc.isra.1.constprop.3+0x24>
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc02039ac:	843e                	mv	s0,a5
ffffffffc02039ae:	87b6                	mv	a5,a3
ffffffffc02039b0:	bf71                	j	ffffffffc020394c <slob_alloc.isra.1.constprop.3+0x74>
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc02039b2:	00004697          	auipc	a3,0x4
ffffffffc02039b6:	3fe68693          	addi	a3,a3,1022 # ffffffffc0207db0 <commands+0x1650>
ffffffffc02039ba:	00003617          	auipc	a2,0x3
ffffffffc02039be:	22660613          	addi	a2,a2,550 # ffffffffc0206be0 <commands+0x480>
ffffffffc02039c2:	06400593          	li	a1,100
ffffffffc02039c6:	00004517          	auipc	a0,0x4
ffffffffc02039ca:	40a50513          	addi	a0,a0,1034 # ffffffffc0207dd0 <commands+0x1670>
ffffffffc02039ce:	847fc0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc02039d2 <kmalloc_init>:
slob_init(void) {
  cprintf("use SLOB allocator\n");
}

inline void 
kmalloc_init(void) {
ffffffffc02039d2:	1141                	addi	sp,sp,-16
  cprintf("use SLOB allocator\n");
ffffffffc02039d4:	00004517          	auipc	a0,0x4
ffffffffc02039d8:	41450513          	addi	a0,a0,1044 # ffffffffc0207de8 <commands+0x1688>
kmalloc_init(void) {
ffffffffc02039dc:	e406                	sd	ra,8(sp)
  cprintf("use SLOB allocator\n");
ffffffffc02039de:	ef2fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    slob_init();
    cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc02039e2:	60a2                	ld	ra,8(sp)
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc02039e4:	00004517          	auipc	a0,0x4
ffffffffc02039e8:	3ac50513          	addi	a0,a0,940 # ffffffffc0207d90 <commands+0x1630>
}
ffffffffc02039ec:	0141                	addi	sp,sp,16
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc02039ee:	ee2fc06f          	j	ffffffffc02000d0 <cprintf>

ffffffffc02039f2 <kallocated>:
}

size_t
kallocated(void) {
   return slob_allocated();
}
ffffffffc02039f2:	4501                	li	a0,0
ffffffffc02039f4:	8082                	ret

ffffffffc02039f6 <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc02039f6:	1101                	addi	sp,sp,-32
ffffffffc02039f8:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc02039fa:	6905                	lui	s2,0x1
{
ffffffffc02039fc:	e822                	sd	s0,16(sp)
ffffffffc02039fe:	ec06                	sd	ra,24(sp)
ffffffffc0203a00:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0203a02:	fef90793          	addi	a5,s2,-17 # fef <_binary_obj___user_faultread_out_size-0x85d9>
{
ffffffffc0203a06:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0203a08:	04a7fc63          	bgeu	a5,a0,ffffffffc0203a60 <kmalloc+0x6a>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc0203a0c:	4561                	li	a0,24
ffffffffc0203a0e:	ecbff0ef          	jal	ra,ffffffffc02038d8 <slob_alloc.isra.1.constprop.3>
ffffffffc0203a12:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc0203a14:	cd21                	beqz	a0,ffffffffc0203a6c <kmalloc+0x76>
	bb->order = find_order(size);
ffffffffc0203a16:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc0203a1a:	4501                	li	a0,0
	for ( ; size > 4096 ; size >>=1)
ffffffffc0203a1c:	00f95763          	bge	s2,a5,ffffffffc0203a2a <kmalloc+0x34>
ffffffffc0203a20:	6705                	lui	a4,0x1
ffffffffc0203a22:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc0203a24:	2505                	addiw	a0,a0,1
	for ( ; size > 4096 ; size >>=1)
ffffffffc0203a26:	fef74ee3          	blt	a4,a5,ffffffffc0203a22 <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc0203a2a:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc0203a2c:	e41ff0ef          	jal	ra,ffffffffc020386c <__slob_get_free_pages.isra.0>
ffffffffc0203a30:	e488                	sd	a0,8(s1)
ffffffffc0203a32:	842a                	mv	s0,a0
	if (bb->pages) {
ffffffffc0203a34:	c935                	beqz	a0,ffffffffc0203aa8 <kmalloc+0xb2>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203a36:	100027f3          	csrr	a5,sstatus
ffffffffc0203a3a:	8b89                	andi	a5,a5,2
ffffffffc0203a3c:	e3a1                	bnez	a5,ffffffffc0203a7c <kmalloc+0x86>
		bb->next = bigblocks;
ffffffffc0203a3e:	000a9797          	auipc	a5,0xa9
ffffffffc0203a42:	e4278793          	addi	a5,a5,-446 # ffffffffc02ac880 <bigblocks>
ffffffffc0203a46:	639c                	ld	a5,0(a5)
		bigblocks = bb;
ffffffffc0203a48:	000a9717          	auipc	a4,0xa9
ffffffffc0203a4c:	e2973c23          	sd	s1,-456(a4) # ffffffffc02ac880 <bigblocks>
		bb->next = bigblocks;
ffffffffc0203a50:	e89c                	sd	a5,16(s1)
  return __kmalloc(size, 0);
}
ffffffffc0203a52:	8522                	mv	a0,s0
ffffffffc0203a54:	60e2                	ld	ra,24(sp)
ffffffffc0203a56:	6442                	ld	s0,16(sp)
ffffffffc0203a58:	64a2                	ld	s1,8(sp)
ffffffffc0203a5a:	6902                	ld	s2,0(sp)
ffffffffc0203a5c:	6105                	addi	sp,sp,32
ffffffffc0203a5e:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc0203a60:	0541                	addi	a0,a0,16
ffffffffc0203a62:	e77ff0ef          	jal	ra,ffffffffc02038d8 <slob_alloc.isra.1.constprop.3>
		return m ? (void *)(m + 1) : 0;
ffffffffc0203a66:	01050413          	addi	s0,a0,16
ffffffffc0203a6a:	f565                	bnez	a0,ffffffffc0203a52 <kmalloc+0x5c>
ffffffffc0203a6c:	4401                	li	s0,0
}
ffffffffc0203a6e:	8522                	mv	a0,s0
ffffffffc0203a70:	60e2                	ld	ra,24(sp)
ffffffffc0203a72:	6442                	ld	s0,16(sp)
ffffffffc0203a74:	64a2                	ld	s1,8(sp)
ffffffffc0203a76:	6902                	ld	s2,0(sp)
ffffffffc0203a78:	6105                	addi	sp,sp,32
ffffffffc0203a7a:	8082                	ret
        intr_disable();
ffffffffc0203a7c:	bd9fc0ef          	jal	ra,ffffffffc0200654 <intr_disable>
		bb->next = bigblocks;
ffffffffc0203a80:	000a9797          	auipc	a5,0xa9
ffffffffc0203a84:	e0078793          	addi	a5,a5,-512 # ffffffffc02ac880 <bigblocks>
ffffffffc0203a88:	639c                	ld	a5,0(a5)
		bigblocks = bb;
ffffffffc0203a8a:	000a9717          	auipc	a4,0xa9
ffffffffc0203a8e:	de973b23          	sd	s1,-522(a4) # ffffffffc02ac880 <bigblocks>
		bb->next = bigblocks;
ffffffffc0203a92:	e89c                	sd	a5,16(s1)
        intr_enable();
ffffffffc0203a94:	bbbfc0ef          	jal	ra,ffffffffc020064e <intr_enable>
ffffffffc0203a98:	6480                	ld	s0,8(s1)
}
ffffffffc0203a9a:	60e2                	ld	ra,24(sp)
ffffffffc0203a9c:	64a2                	ld	s1,8(sp)
ffffffffc0203a9e:	8522                	mv	a0,s0
ffffffffc0203aa0:	6442                	ld	s0,16(sp)
ffffffffc0203aa2:	6902                	ld	s2,0(sp)
ffffffffc0203aa4:	6105                	addi	sp,sp,32
ffffffffc0203aa6:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0203aa8:	45e1                	li	a1,24
ffffffffc0203aaa:	8526                	mv	a0,s1
ffffffffc0203aac:	cabff0ef          	jal	ra,ffffffffc0203756 <slob_free>
  return __kmalloc(size, 0);
ffffffffc0203ab0:	b74d                	j	ffffffffc0203a52 <kmalloc+0x5c>

ffffffffc0203ab2 <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc0203ab2:	c175                	beqz	a0,ffffffffc0203b96 <kfree+0xe4>
{
ffffffffc0203ab4:	1101                	addi	sp,sp,-32
ffffffffc0203ab6:	e426                	sd	s1,8(sp)
ffffffffc0203ab8:	ec06                	sd	ra,24(sp)
ffffffffc0203aba:	e822                	sd	s0,16(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
ffffffffc0203abc:	03451793          	slli	a5,a0,0x34
ffffffffc0203ac0:	84aa                	mv	s1,a0
ffffffffc0203ac2:	eb8d                	bnez	a5,ffffffffc0203af4 <kfree+0x42>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203ac4:	100027f3          	csrr	a5,sstatus
ffffffffc0203ac8:	8b89                	andi	a5,a5,2
ffffffffc0203aca:	efc9                	bnez	a5,ffffffffc0203b64 <kfree+0xb2>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0203acc:	000a9797          	auipc	a5,0xa9
ffffffffc0203ad0:	db478793          	addi	a5,a5,-588 # ffffffffc02ac880 <bigblocks>
ffffffffc0203ad4:	6394                	ld	a3,0(a5)
ffffffffc0203ad6:	ce99                	beqz	a3,ffffffffc0203af4 <kfree+0x42>
			if (bb->pages == block) {
ffffffffc0203ad8:	669c                	ld	a5,8(a3)
ffffffffc0203ada:	6a80                	ld	s0,16(a3)
ffffffffc0203adc:	0af50e63          	beq	a0,a5,ffffffffc0203b98 <kfree+0xe6>
    return 0;
ffffffffc0203ae0:	4601                	li	a2,0
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0203ae2:	c801                	beqz	s0,ffffffffc0203af2 <kfree+0x40>
			if (bb->pages == block) {
ffffffffc0203ae4:	6418                	ld	a4,8(s0)
ffffffffc0203ae6:	681c                	ld	a5,16(s0)
ffffffffc0203ae8:	00970f63          	beq	a4,s1,ffffffffc0203b06 <kfree+0x54>
ffffffffc0203aec:	86a2                	mv	a3,s0
ffffffffc0203aee:	843e                	mv	s0,a5
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0203af0:	f875                	bnez	s0,ffffffffc0203ae4 <kfree+0x32>
    if (flag) {
ffffffffc0203af2:	e659                	bnez	a2,ffffffffc0203b80 <kfree+0xce>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc0203af4:	6442                	ld	s0,16(sp)
ffffffffc0203af6:	60e2                	ld	ra,24(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0203af8:	ff048513          	addi	a0,s1,-16
}
ffffffffc0203afc:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0203afe:	4581                	li	a1,0
}
ffffffffc0203b00:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0203b02:	c55ff06f          	j	ffffffffc0203756 <slob_free>
				*last = bb->next;
ffffffffc0203b06:	ea9c                	sd	a5,16(a3)
ffffffffc0203b08:	e641                	bnez	a2,ffffffffc0203b90 <kfree+0xde>
    return pa2page(PADDR(kva));
ffffffffc0203b0a:	c02007b7          	lui	a5,0xc0200
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc0203b0e:	4018                	lw	a4,0(s0)
ffffffffc0203b10:	08f4ea63          	bltu	s1,a5,ffffffffc0203ba4 <kfree+0xf2>
ffffffffc0203b14:	000a9797          	auipc	a5,0xa9
ffffffffc0203b18:	da478793          	addi	a5,a5,-604 # ffffffffc02ac8b8 <va_pa_offset>
ffffffffc0203b1c:	6394                	ld	a3,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0203b1e:	000a9797          	auipc	a5,0xa9
ffffffffc0203b22:	d4278793          	addi	a5,a5,-702 # ffffffffc02ac860 <npage>
ffffffffc0203b26:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc0203b28:	8c95                	sub	s1,s1,a3
    if (PPN(pa) >= npage) {
ffffffffc0203b2a:	80b1                	srli	s1,s1,0xc
ffffffffc0203b2c:	08f4f963          	bgeu	s1,a5,ffffffffc0203bbe <kfree+0x10c>
    return &pages[PPN(pa) - nbase];
ffffffffc0203b30:	00005797          	auipc	a5,0x5
ffffffffc0203b34:	1b878793          	addi	a5,a5,440 # ffffffffc0208ce8 <nbase>
ffffffffc0203b38:	639c                	ld	a5,0(a5)
ffffffffc0203b3a:	000a9697          	auipc	a3,0xa9
ffffffffc0203b3e:	d8e68693          	addi	a3,a3,-626 # ffffffffc02ac8c8 <pages>
ffffffffc0203b42:	6288                	ld	a0,0(a3)
ffffffffc0203b44:	8c9d                	sub	s1,s1,a5
ffffffffc0203b46:	049a                	slli	s1,s1,0x6
  free_pages(kva2page(kva), 1 << order);
ffffffffc0203b48:	4585                	li	a1,1
ffffffffc0203b4a:	9526                	add	a0,a0,s1
ffffffffc0203b4c:	00e595bb          	sllw	a1,a1,a4
ffffffffc0203b50:	b92fd0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0203b54:	8522                	mv	a0,s0
}
ffffffffc0203b56:	6442                	ld	s0,16(sp)
ffffffffc0203b58:	60e2                	ld	ra,24(sp)
ffffffffc0203b5a:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0203b5c:	45e1                	li	a1,24
}
ffffffffc0203b5e:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0203b60:	bf7ff06f          	j	ffffffffc0203756 <slob_free>
        intr_disable();
ffffffffc0203b64:	af1fc0ef          	jal	ra,ffffffffc0200654 <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0203b68:	000a9797          	auipc	a5,0xa9
ffffffffc0203b6c:	d1878793          	addi	a5,a5,-744 # ffffffffc02ac880 <bigblocks>
ffffffffc0203b70:	6394                	ld	a3,0(a5)
ffffffffc0203b72:	c699                	beqz	a3,ffffffffc0203b80 <kfree+0xce>
			if (bb->pages == block) {
ffffffffc0203b74:	669c                	ld	a5,8(a3)
ffffffffc0203b76:	6a80                	ld	s0,16(a3)
ffffffffc0203b78:	00f48763          	beq	s1,a5,ffffffffc0203b86 <kfree+0xd4>
        return 1;
ffffffffc0203b7c:	4605                	li	a2,1
ffffffffc0203b7e:	b795                	j	ffffffffc0203ae2 <kfree+0x30>
        intr_enable();
ffffffffc0203b80:	acffc0ef          	jal	ra,ffffffffc020064e <intr_enable>
ffffffffc0203b84:	bf85                	j	ffffffffc0203af4 <kfree+0x42>
				*last = bb->next;
ffffffffc0203b86:	000a9797          	auipc	a5,0xa9
ffffffffc0203b8a:	ce87bd23          	sd	s0,-774(a5) # ffffffffc02ac880 <bigblocks>
ffffffffc0203b8e:	8436                	mv	s0,a3
ffffffffc0203b90:	abffc0ef          	jal	ra,ffffffffc020064e <intr_enable>
ffffffffc0203b94:	bf9d                	j	ffffffffc0203b0a <kfree+0x58>
ffffffffc0203b96:	8082                	ret
ffffffffc0203b98:	000a9797          	auipc	a5,0xa9
ffffffffc0203b9c:	ce87b423          	sd	s0,-792(a5) # ffffffffc02ac880 <bigblocks>
ffffffffc0203ba0:	8436                	mv	s0,a3
ffffffffc0203ba2:	b7a5                	j	ffffffffc0203b0a <kfree+0x58>
    return pa2page(PADDR(kva));
ffffffffc0203ba4:	86a6                	mv	a3,s1
ffffffffc0203ba6:	00003617          	auipc	a2,0x3
ffffffffc0203baa:	4fa60613          	addi	a2,a2,1274 # ffffffffc02070a0 <commands+0x940>
ffffffffc0203bae:	06e00593          	li	a1,110
ffffffffc0203bb2:	00003517          	auipc	a0,0x3
ffffffffc0203bb6:	46e50513          	addi	a0,a0,1134 # ffffffffc0207020 <commands+0x8c0>
ffffffffc0203bba:	e5afc0ef          	jal	ra,ffffffffc0200214 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0203bbe:	00003617          	auipc	a2,0x3
ffffffffc0203bc2:	44260613          	addi	a2,a2,1090 # ffffffffc0207000 <commands+0x8a0>
ffffffffc0203bc6:	06200593          	li	a1,98
ffffffffc0203bca:	00003517          	auipc	a0,0x3
ffffffffc0203bce:	45650513          	addi	a0,a0,1110 # ffffffffc0207020 <commands+0x8c0>
ffffffffc0203bd2:	e42fc0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0203bd6 <_fifo_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc0203bd6:	000a9797          	auipc	a5,0xa9
ffffffffc0203bda:	dca78793          	addi	a5,a5,-566 # ffffffffc02ac9a0 <pra_list_head>
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
ffffffffc0203bde:	f51c                	sd	a5,40(a0)
ffffffffc0203be0:	e79c                	sd	a5,8(a5)
ffffffffc0203be2:	e39c                	sd	a5,0(a5)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc0203be4:	4501                	li	a0,0
ffffffffc0203be6:	8082                	ret

ffffffffc0203be8 <_fifo_init>:

static int
_fifo_init(void)
{
    return 0;
}
ffffffffc0203be8:	4501                	li	a0,0
ffffffffc0203bea:	8082                	ret

ffffffffc0203bec <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc0203bec:	4501                	li	a0,0
ffffffffc0203bee:	8082                	ret

ffffffffc0203bf0 <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc0203bf0:	4501                	li	a0,0
ffffffffc0203bf2:	8082                	ret

ffffffffc0203bf4 <_fifo_check_swap>:
_fifo_check_swap(void) {
ffffffffc0203bf4:	711d                	addi	sp,sp,-96
ffffffffc0203bf6:	fc4e                	sd	s3,56(sp)
ffffffffc0203bf8:	f852                	sd	s4,48(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203bfa:	00004517          	auipc	a0,0x4
ffffffffc0203bfe:	20650513          	addi	a0,a0,518 # ffffffffc0207e00 <commands+0x16a0>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203c02:	698d                	lui	s3,0x3
ffffffffc0203c04:	4a31                	li	s4,12
_fifo_check_swap(void) {
ffffffffc0203c06:	e8a2                	sd	s0,80(sp)
ffffffffc0203c08:	e4a6                	sd	s1,72(sp)
ffffffffc0203c0a:	ec86                	sd	ra,88(sp)
ffffffffc0203c0c:	e0ca                	sd	s2,64(sp)
ffffffffc0203c0e:	f456                	sd	s5,40(sp)
ffffffffc0203c10:	f05a                	sd	s6,32(sp)
ffffffffc0203c12:	ec5e                	sd	s7,24(sp)
ffffffffc0203c14:	e862                	sd	s8,16(sp)
ffffffffc0203c16:	e466                	sd	s9,8(sp)
    assert(pgfault_num==4);
ffffffffc0203c18:	000a9417          	auipc	s0,0xa9
ffffffffc0203c1c:	c5040413          	addi	s0,s0,-944 # ffffffffc02ac868 <pgfault_num>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203c20:	cb0fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203c24:	01498023          	sb	s4,0(s3) # 3000 <_binary_obj___user_faultread_out_size-0x65c8>
    assert(pgfault_num==4);
ffffffffc0203c28:	4004                	lw	s1,0(s0)
ffffffffc0203c2a:	4791                	li	a5,4
ffffffffc0203c2c:	2481                	sext.w	s1,s1
ffffffffc0203c2e:	14f49963          	bne	s1,a5,ffffffffc0203d80 <_fifo_check_swap+0x18c>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203c32:	00004517          	auipc	a0,0x4
ffffffffc0203c36:	20e50513          	addi	a0,a0,526 # ffffffffc0207e40 <commands+0x16e0>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203c3a:	6a85                	lui	s5,0x1
ffffffffc0203c3c:	4b29                	li	s6,10
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203c3e:	c92fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203c42:	016a8023          	sb	s6,0(s5) # 1000 <_binary_obj___user_faultread_out_size-0x85c8>
    assert(pgfault_num==4);
ffffffffc0203c46:	00042903          	lw	s2,0(s0)
ffffffffc0203c4a:	2901                	sext.w	s2,s2
ffffffffc0203c4c:	2a991a63          	bne	s2,s1,ffffffffc0203f00 <_fifo_check_swap+0x30c>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203c50:	00004517          	auipc	a0,0x4
ffffffffc0203c54:	21850513          	addi	a0,a0,536 # ffffffffc0207e68 <commands+0x1708>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203c58:	6b91                	lui	s7,0x4
ffffffffc0203c5a:	4c35                	li	s8,13
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203c5c:	c74fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203c60:	018b8023          	sb	s8,0(s7) # 4000 <_binary_obj___user_faultread_out_size-0x55c8>
    assert(pgfault_num==4);
ffffffffc0203c64:	4004                	lw	s1,0(s0)
ffffffffc0203c66:	2481                	sext.w	s1,s1
ffffffffc0203c68:	27249c63          	bne	s1,s2,ffffffffc0203ee0 <_fifo_check_swap+0x2ec>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203c6c:	00004517          	auipc	a0,0x4
ffffffffc0203c70:	22450513          	addi	a0,a0,548 # ffffffffc0207e90 <commands+0x1730>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203c74:	6909                	lui	s2,0x2
ffffffffc0203c76:	4cad                	li	s9,11
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203c78:	c58fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203c7c:	01990023          	sb	s9,0(s2) # 2000 <_binary_obj___user_faultread_out_size-0x75c8>
    assert(pgfault_num==4);
ffffffffc0203c80:	401c                	lw	a5,0(s0)
ffffffffc0203c82:	2781                	sext.w	a5,a5
ffffffffc0203c84:	22979e63          	bne	a5,s1,ffffffffc0203ec0 <_fifo_check_swap+0x2cc>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0203c88:	00004517          	auipc	a0,0x4
ffffffffc0203c8c:	23050513          	addi	a0,a0,560 # ffffffffc0207eb8 <commands+0x1758>
ffffffffc0203c90:	c40fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203c94:	6795                	lui	a5,0x5
ffffffffc0203c96:	4739                	li	a4,14
ffffffffc0203c98:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x45c8>
    assert(pgfault_num==5);
ffffffffc0203c9c:	4004                	lw	s1,0(s0)
ffffffffc0203c9e:	4795                	li	a5,5
ffffffffc0203ca0:	2481                	sext.w	s1,s1
ffffffffc0203ca2:	1ef49f63          	bne	s1,a5,ffffffffc0203ea0 <_fifo_check_swap+0x2ac>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203ca6:	00004517          	auipc	a0,0x4
ffffffffc0203caa:	1ea50513          	addi	a0,a0,490 # ffffffffc0207e90 <commands+0x1730>
ffffffffc0203cae:	c22fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203cb2:	01990023          	sb	s9,0(s2)
    assert(pgfault_num==5);
ffffffffc0203cb6:	401c                	lw	a5,0(s0)
ffffffffc0203cb8:	2781                	sext.w	a5,a5
ffffffffc0203cba:	1c979363          	bne	a5,s1,ffffffffc0203e80 <_fifo_check_swap+0x28c>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203cbe:	00004517          	auipc	a0,0x4
ffffffffc0203cc2:	18250513          	addi	a0,a0,386 # ffffffffc0207e40 <commands+0x16e0>
ffffffffc0203cc6:	c0afc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203cca:	016a8023          	sb	s6,0(s5)
    assert(pgfault_num==6);
ffffffffc0203cce:	401c                	lw	a5,0(s0)
ffffffffc0203cd0:	4719                	li	a4,6
ffffffffc0203cd2:	2781                	sext.w	a5,a5
ffffffffc0203cd4:	18e79663          	bne	a5,a4,ffffffffc0203e60 <_fifo_check_swap+0x26c>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203cd8:	00004517          	auipc	a0,0x4
ffffffffc0203cdc:	1b850513          	addi	a0,a0,440 # ffffffffc0207e90 <commands+0x1730>
ffffffffc0203ce0:	bf0fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203ce4:	01990023          	sb	s9,0(s2)
    assert(pgfault_num==7);
ffffffffc0203ce8:	401c                	lw	a5,0(s0)
ffffffffc0203cea:	471d                	li	a4,7
ffffffffc0203cec:	2781                	sext.w	a5,a5
ffffffffc0203cee:	14e79963          	bne	a5,a4,ffffffffc0203e40 <_fifo_check_swap+0x24c>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203cf2:	00004517          	auipc	a0,0x4
ffffffffc0203cf6:	10e50513          	addi	a0,a0,270 # ffffffffc0207e00 <commands+0x16a0>
ffffffffc0203cfa:	bd6fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203cfe:	01498023          	sb	s4,0(s3)
    assert(pgfault_num==8);
ffffffffc0203d02:	401c                	lw	a5,0(s0)
ffffffffc0203d04:	4721                	li	a4,8
ffffffffc0203d06:	2781                	sext.w	a5,a5
ffffffffc0203d08:	10e79c63          	bne	a5,a4,ffffffffc0203e20 <_fifo_check_swap+0x22c>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203d0c:	00004517          	auipc	a0,0x4
ffffffffc0203d10:	15c50513          	addi	a0,a0,348 # ffffffffc0207e68 <commands+0x1708>
ffffffffc0203d14:	bbcfc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203d18:	018b8023          	sb	s8,0(s7)
    assert(pgfault_num==9);
ffffffffc0203d1c:	401c                	lw	a5,0(s0)
ffffffffc0203d1e:	4725                	li	a4,9
ffffffffc0203d20:	2781                	sext.w	a5,a5
ffffffffc0203d22:	0ce79f63          	bne	a5,a4,ffffffffc0203e00 <_fifo_check_swap+0x20c>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0203d26:	00004517          	auipc	a0,0x4
ffffffffc0203d2a:	19250513          	addi	a0,a0,402 # ffffffffc0207eb8 <commands+0x1758>
ffffffffc0203d2e:	ba2fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203d32:	6795                	lui	a5,0x5
ffffffffc0203d34:	4739                	li	a4,14
ffffffffc0203d36:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x45c8>
    assert(pgfault_num==10);
ffffffffc0203d3a:	4004                	lw	s1,0(s0)
ffffffffc0203d3c:	47a9                	li	a5,10
ffffffffc0203d3e:	2481                	sext.w	s1,s1
ffffffffc0203d40:	0af49063          	bne	s1,a5,ffffffffc0203de0 <_fifo_check_swap+0x1ec>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203d44:	00004517          	auipc	a0,0x4
ffffffffc0203d48:	0fc50513          	addi	a0,a0,252 # ffffffffc0207e40 <commands+0x16e0>
ffffffffc0203d4c:	b84fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203d50:	6785                	lui	a5,0x1
ffffffffc0203d52:	0007c783          	lbu	a5,0(a5) # 1000 <_binary_obj___user_faultread_out_size-0x85c8>
ffffffffc0203d56:	06979563          	bne	a5,s1,ffffffffc0203dc0 <_fifo_check_swap+0x1cc>
    assert(pgfault_num==11);
ffffffffc0203d5a:	401c                	lw	a5,0(s0)
ffffffffc0203d5c:	472d                	li	a4,11
ffffffffc0203d5e:	2781                	sext.w	a5,a5
ffffffffc0203d60:	04e79063          	bne	a5,a4,ffffffffc0203da0 <_fifo_check_swap+0x1ac>
}
ffffffffc0203d64:	60e6                	ld	ra,88(sp)
ffffffffc0203d66:	6446                	ld	s0,80(sp)
ffffffffc0203d68:	64a6                	ld	s1,72(sp)
ffffffffc0203d6a:	6906                	ld	s2,64(sp)
ffffffffc0203d6c:	79e2                	ld	s3,56(sp)
ffffffffc0203d6e:	7a42                	ld	s4,48(sp)
ffffffffc0203d70:	7aa2                	ld	s5,40(sp)
ffffffffc0203d72:	7b02                	ld	s6,32(sp)
ffffffffc0203d74:	6be2                	ld	s7,24(sp)
ffffffffc0203d76:	6c42                	ld	s8,16(sp)
ffffffffc0203d78:	6ca2                	ld	s9,8(sp)
ffffffffc0203d7a:	4501                	li	a0,0
ffffffffc0203d7c:	6125                	addi	sp,sp,96
ffffffffc0203d7e:	8082                	ret
    assert(pgfault_num==4);
ffffffffc0203d80:	00004697          	auipc	a3,0x4
ffffffffc0203d84:	ea068693          	addi	a3,a3,-352 # ffffffffc0207c20 <commands+0x14c0>
ffffffffc0203d88:	00003617          	auipc	a2,0x3
ffffffffc0203d8c:	e5860613          	addi	a2,a2,-424 # ffffffffc0206be0 <commands+0x480>
ffffffffc0203d90:	05100593          	li	a1,81
ffffffffc0203d94:	00004517          	auipc	a0,0x4
ffffffffc0203d98:	09450513          	addi	a0,a0,148 # ffffffffc0207e28 <commands+0x16c8>
ffffffffc0203d9c:	c78fc0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(pgfault_num==11);
ffffffffc0203da0:	00004697          	auipc	a3,0x4
ffffffffc0203da4:	1c868693          	addi	a3,a3,456 # ffffffffc0207f68 <commands+0x1808>
ffffffffc0203da8:	00003617          	auipc	a2,0x3
ffffffffc0203dac:	e3860613          	addi	a2,a2,-456 # ffffffffc0206be0 <commands+0x480>
ffffffffc0203db0:	07300593          	li	a1,115
ffffffffc0203db4:	00004517          	auipc	a0,0x4
ffffffffc0203db8:	07450513          	addi	a0,a0,116 # ffffffffc0207e28 <commands+0x16c8>
ffffffffc0203dbc:	c58fc0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203dc0:	00004697          	auipc	a3,0x4
ffffffffc0203dc4:	18068693          	addi	a3,a3,384 # ffffffffc0207f40 <commands+0x17e0>
ffffffffc0203dc8:	00003617          	auipc	a2,0x3
ffffffffc0203dcc:	e1860613          	addi	a2,a2,-488 # ffffffffc0206be0 <commands+0x480>
ffffffffc0203dd0:	07100593          	li	a1,113
ffffffffc0203dd4:	00004517          	auipc	a0,0x4
ffffffffc0203dd8:	05450513          	addi	a0,a0,84 # ffffffffc0207e28 <commands+0x16c8>
ffffffffc0203ddc:	c38fc0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(pgfault_num==10);
ffffffffc0203de0:	00004697          	auipc	a3,0x4
ffffffffc0203de4:	15068693          	addi	a3,a3,336 # ffffffffc0207f30 <commands+0x17d0>
ffffffffc0203de8:	00003617          	auipc	a2,0x3
ffffffffc0203dec:	df860613          	addi	a2,a2,-520 # ffffffffc0206be0 <commands+0x480>
ffffffffc0203df0:	06f00593          	li	a1,111
ffffffffc0203df4:	00004517          	auipc	a0,0x4
ffffffffc0203df8:	03450513          	addi	a0,a0,52 # ffffffffc0207e28 <commands+0x16c8>
ffffffffc0203dfc:	c18fc0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(pgfault_num==9);
ffffffffc0203e00:	00004697          	auipc	a3,0x4
ffffffffc0203e04:	12068693          	addi	a3,a3,288 # ffffffffc0207f20 <commands+0x17c0>
ffffffffc0203e08:	00003617          	auipc	a2,0x3
ffffffffc0203e0c:	dd860613          	addi	a2,a2,-552 # ffffffffc0206be0 <commands+0x480>
ffffffffc0203e10:	06c00593          	li	a1,108
ffffffffc0203e14:	00004517          	auipc	a0,0x4
ffffffffc0203e18:	01450513          	addi	a0,a0,20 # ffffffffc0207e28 <commands+0x16c8>
ffffffffc0203e1c:	bf8fc0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(pgfault_num==8);
ffffffffc0203e20:	00004697          	auipc	a3,0x4
ffffffffc0203e24:	0f068693          	addi	a3,a3,240 # ffffffffc0207f10 <commands+0x17b0>
ffffffffc0203e28:	00003617          	auipc	a2,0x3
ffffffffc0203e2c:	db860613          	addi	a2,a2,-584 # ffffffffc0206be0 <commands+0x480>
ffffffffc0203e30:	06900593          	li	a1,105
ffffffffc0203e34:	00004517          	auipc	a0,0x4
ffffffffc0203e38:	ff450513          	addi	a0,a0,-12 # ffffffffc0207e28 <commands+0x16c8>
ffffffffc0203e3c:	bd8fc0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(pgfault_num==7);
ffffffffc0203e40:	00004697          	auipc	a3,0x4
ffffffffc0203e44:	0c068693          	addi	a3,a3,192 # ffffffffc0207f00 <commands+0x17a0>
ffffffffc0203e48:	00003617          	auipc	a2,0x3
ffffffffc0203e4c:	d9860613          	addi	a2,a2,-616 # ffffffffc0206be0 <commands+0x480>
ffffffffc0203e50:	06600593          	li	a1,102
ffffffffc0203e54:	00004517          	auipc	a0,0x4
ffffffffc0203e58:	fd450513          	addi	a0,a0,-44 # ffffffffc0207e28 <commands+0x16c8>
ffffffffc0203e5c:	bb8fc0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(pgfault_num==6);
ffffffffc0203e60:	00004697          	auipc	a3,0x4
ffffffffc0203e64:	09068693          	addi	a3,a3,144 # ffffffffc0207ef0 <commands+0x1790>
ffffffffc0203e68:	00003617          	auipc	a2,0x3
ffffffffc0203e6c:	d7860613          	addi	a2,a2,-648 # ffffffffc0206be0 <commands+0x480>
ffffffffc0203e70:	06300593          	li	a1,99
ffffffffc0203e74:	00004517          	auipc	a0,0x4
ffffffffc0203e78:	fb450513          	addi	a0,a0,-76 # ffffffffc0207e28 <commands+0x16c8>
ffffffffc0203e7c:	b98fc0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(pgfault_num==5);
ffffffffc0203e80:	00004697          	auipc	a3,0x4
ffffffffc0203e84:	06068693          	addi	a3,a3,96 # ffffffffc0207ee0 <commands+0x1780>
ffffffffc0203e88:	00003617          	auipc	a2,0x3
ffffffffc0203e8c:	d5860613          	addi	a2,a2,-680 # ffffffffc0206be0 <commands+0x480>
ffffffffc0203e90:	06000593          	li	a1,96
ffffffffc0203e94:	00004517          	auipc	a0,0x4
ffffffffc0203e98:	f9450513          	addi	a0,a0,-108 # ffffffffc0207e28 <commands+0x16c8>
ffffffffc0203e9c:	b78fc0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(pgfault_num==5);
ffffffffc0203ea0:	00004697          	auipc	a3,0x4
ffffffffc0203ea4:	04068693          	addi	a3,a3,64 # ffffffffc0207ee0 <commands+0x1780>
ffffffffc0203ea8:	00003617          	auipc	a2,0x3
ffffffffc0203eac:	d3860613          	addi	a2,a2,-712 # ffffffffc0206be0 <commands+0x480>
ffffffffc0203eb0:	05d00593          	li	a1,93
ffffffffc0203eb4:	00004517          	auipc	a0,0x4
ffffffffc0203eb8:	f7450513          	addi	a0,a0,-140 # ffffffffc0207e28 <commands+0x16c8>
ffffffffc0203ebc:	b58fc0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(pgfault_num==4);
ffffffffc0203ec0:	00004697          	auipc	a3,0x4
ffffffffc0203ec4:	d6068693          	addi	a3,a3,-672 # ffffffffc0207c20 <commands+0x14c0>
ffffffffc0203ec8:	00003617          	auipc	a2,0x3
ffffffffc0203ecc:	d1860613          	addi	a2,a2,-744 # ffffffffc0206be0 <commands+0x480>
ffffffffc0203ed0:	05a00593          	li	a1,90
ffffffffc0203ed4:	00004517          	auipc	a0,0x4
ffffffffc0203ed8:	f5450513          	addi	a0,a0,-172 # ffffffffc0207e28 <commands+0x16c8>
ffffffffc0203edc:	b38fc0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(pgfault_num==4);
ffffffffc0203ee0:	00004697          	auipc	a3,0x4
ffffffffc0203ee4:	d4068693          	addi	a3,a3,-704 # ffffffffc0207c20 <commands+0x14c0>
ffffffffc0203ee8:	00003617          	auipc	a2,0x3
ffffffffc0203eec:	cf860613          	addi	a2,a2,-776 # ffffffffc0206be0 <commands+0x480>
ffffffffc0203ef0:	05700593          	li	a1,87
ffffffffc0203ef4:	00004517          	auipc	a0,0x4
ffffffffc0203ef8:	f3450513          	addi	a0,a0,-204 # ffffffffc0207e28 <commands+0x16c8>
ffffffffc0203efc:	b18fc0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(pgfault_num==4);
ffffffffc0203f00:	00004697          	auipc	a3,0x4
ffffffffc0203f04:	d2068693          	addi	a3,a3,-736 # ffffffffc0207c20 <commands+0x14c0>
ffffffffc0203f08:	00003617          	auipc	a2,0x3
ffffffffc0203f0c:	cd860613          	addi	a2,a2,-808 # ffffffffc0206be0 <commands+0x480>
ffffffffc0203f10:	05400593          	li	a1,84
ffffffffc0203f14:	00004517          	auipc	a0,0x4
ffffffffc0203f18:	f1450513          	addi	a0,a0,-236 # ffffffffc0207e28 <commands+0x16c8>
ffffffffc0203f1c:	af8fc0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0203f20 <_fifo_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0203f20:	751c                	ld	a5,40(a0)
{
ffffffffc0203f22:	1141                	addi	sp,sp,-16
ffffffffc0203f24:	e406                	sd	ra,8(sp)
         assert(head != NULL);
ffffffffc0203f26:	cf91                	beqz	a5,ffffffffc0203f42 <_fifo_swap_out_victim+0x22>
     assert(in_tick==0);
ffffffffc0203f28:	ee0d                	bnez	a2,ffffffffc0203f62 <_fifo_swap_out_victim+0x42>
    return listelm->next;
ffffffffc0203f2a:	679c                	ld	a5,8(a5)
}
ffffffffc0203f2c:	60a2                	ld	ra,8(sp)
ffffffffc0203f2e:	4501                	li	a0,0
    __list_del(listelm->prev, listelm->next);
ffffffffc0203f30:	6394                	ld	a3,0(a5)
ffffffffc0203f32:	6798                	ld	a4,8(a5)
    *ptr_page = le2page(entry, pra_page_link);
ffffffffc0203f34:	fd878793          	addi	a5,a5,-40
    prev->next = next;
ffffffffc0203f38:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc0203f3a:	e314                	sd	a3,0(a4)
ffffffffc0203f3c:	e19c                	sd	a5,0(a1)
}
ffffffffc0203f3e:	0141                	addi	sp,sp,16
ffffffffc0203f40:	8082                	ret
         assert(head != NULL);
ffffffffc0203f42:	00004697          	auipc	a3,0x4
ffffffffc0203f46:	05668693          	addi	a3,a3,86 # ffffffffc0207f98 <commands+0x1838>
ffffffffc0203f4a:	00003617          	auipc	a2,0x3
ffffffffc0203f4e:	c9660613          	addi	a2,a2,-874 # ffffffffc0206be0 <commands+0x480>
ffffffffc0203f52:	04100593          	li	a1,65
ffffffffc0203f56:	00004517          	auipc	a0,0x4
ffffffffc0203f5a:	ed250513          	addi	a0,a0,-302 # ffffffffc0207e28 <commands+0x16c8>
ffffffffc0203f5e:	ab6fc0ef          	jal	ra,ffffffffc0200214 <__panic>
     assert(in_tick==0);
ffffffffc0203f62:	00004697          	auipc	a3,0x4
ffffffffc0203f66:	04668693          	addi	a3,a3,70 # ffffffffc0207fa8 <commands+0x1848>
ffffffffc0203f6a:	00003617          	auipc	a2,0x3
ffffffffc0203f6e:	c7660613          	addi	a2,a2,-906 # ffffffffc0206be0 <commands+0x480>
ffffffffc0203f72:	04200593          	li	a1,66
ffffffffc0203f76:	00004517          	auipc	a0,0x4
ffffffffc0203f7a:	eb250513          	addi	a0,a0,-334 # ffffffffc0207e28 <commands+0x16c8>
ffffffffc0203f7e:	a96fc0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0203f82 <_fifo_map_swappable>:
    list_entry_t *entry=&(page->pra_page_link);
ffffffffc0203f82:	02860713          	addi	a4,a2,40
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0203f86:	751c                	ld	a5,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc0203f88:	cb09                	beqz	a4,ffffffffc0203f9a <_fifo_map_swappable+0x18>
ffffffffc0203f8a:	cb81                	beqz	a5,ffffffffc0203f9a <_fifo_map_swappable+0x18>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0203f8c:	6394                	ld	a3,0(a5)
    prev->next = next->prev = elm;
ffffffffc0203f8e:	e398                	sd	a4,0(a5)
}
ffffffffc0203f90:	4501                	li	a0,0
ffffffffc0203f92:	e698                	sd	a4,8(a3)
    elm->next = next;
ffffffffc0203f94:	fa1c                	sd	a5,48(a2)
    elm->prev = prev;
ffffffffc0203f96:	f614                	sd	a3,40(a2)
ffffffffc0203f98:	8082                	ret
{
ffffffffc0203f9a:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc0203f9c:	00004697          	auipc	a3,0x4
ffffffffc0203fa0:	fdc68693          	addi	a3,a3,-36 # ffffffffc0207f78 <commands+0x1818>
ffffffffc0203fa4:	00003617          	auipc	a2,0x3
ffffffffc0203fa8:	c3c60613          	addi	a2,a2,-964 # ffffffffc0206be0 <commands+0x480>
ffffffffc0203fac:	03200593          	li	a1,50
ffffffffc0203fb0:	00004517          	auipc	a0,0x4
ffffffffc0203fb4:	e7850513          	addi	a0,a0,-392 # ffffffffc0207e28 <commands+0x16c8>
{
ffffffffc0203fb8:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc0203fba:	a5afc0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0203fbe <default_init>:
    elm->prev = elm->next = elm;
ffffffffc0203fbe:	000a9797          	auipc	a5,0xa9
ffffffffc0203fc2:	9f278793          	addi	a5,a5,-1550 # ffffffffc02ac9b0 <free_area>
ffffffffc0203fc6:	e79c                	sd	a5,8(a5)
ffffffffc0203fc8:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0203fca:	0007a823          	sw	zero,16(a5)
}
ffffffffc0203fce:	8082                	ret

ffffffffc0203fd0 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0203fd0:	000a9517          	auipc	a0,0xa9
ffffffffc0203fd4:	9f056503          	lwu	a0,-1552(a0) # ffffffffc02ac9c0 <free_area+0x10>
ffffffffc0203fd8:	8082                	ret

ffffffffc0203fda <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0203fda:	715d                	addi	sp,sp,-80
ffffffffc0203fdc:	f84a                	sd	s2,48(sp)
    return listelm->next;
ffffffffc0203fde:	000a9917          	auipc	s2,0xa9
ffffffffc0203fe2:	9d290913          	addi	s2,s2,-1582 # ffffffffc02ac9b0 <free_area>
ffffffffc0203fe6:	00893783          	ld	a5,8(s2)
ffffffffc0203fea:	e486                	sd	ra,72(sp)
ffffffffc0203fec:	e0a2                	sd	s0,64(sp)
ffffffffc0203fee:	fc26                	sd	s1,56(sp)
ffffffffc0203ff0:	f44e                	sd	s3,40(sp)
ffffffffc0203ff2:	f052                	sd	s4,32(sp)
ffffffffc0203ff4:	ec56                	sd	s5,24(sp)
ffffffffc0203ff6:	e85a                	sd	s6,16(sp)
ffffffffc0203ff8:	e45e                	sd	s7,8(sp)
ffffffffc0203ffa:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0203ffc:	31278463          	beq	a5,s2,ffffffffc0204304 <default_check+0x32a>
ffffffffc0204000:	ff07b703          	ld	a4,-16(a5)
ffffffffc0204004:	8305                	srli	a4,a4,0x1
ffffffffc0204006:	8b05                	andi	a4,a4,1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0204008:	30070263          	beqz	a4,ffffffffc020430c <default_check+0x332>
    int count = 0, total = 0;
ffffffffc020400c:	4401                	li	s0,0
ffffffffc020400e:	4481                	li	s1,0
ffffffffc0204010:	a031                	j	ffffffffc020401c <default_check+0x42>
ffffffffc0204012:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc0204016:	8b09                	andi	a4,a4,2
ffffffffc0204018:	2e070a63          	beqz	a4,ffffffffc020430c <default_check+0x332>
        count ++, total += p->property;
ffffffffc020401c:	ff87a703          	lw	a4,-8(a5)
ffffffffc0204020:	679c                	ld	a5,8(a5)
ffffffffc0204022:	2485                	addiw	s1,s1,1
ffffffffc0204024:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0204026:	ff2796e3          	bne	a5,s2,ffffffffc0204012 <default_check+0x38>
ffffffffc020402a:	89a2                	mv	s3,s0
    }
    assert(total == nr_free_pages());
ffffffffc020402c:	efdfc0ef          	jal	ra,ffffffffc0200f28 <nr_free_pages>
ffffffffc0204030:	73351e63          	bne	a0,s3,ffffffffc020476c <default_check+0x792>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0204034:	4505                	li	a0,1
ffffffffc0204036:	e25fc0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc020403a:	8a2a                	mv	s4,a0
ffffffffc020403c:	46050863          	beqz	a0,ffffffffc02044ac <default_check+0x4d2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0204040:	4505                	li	a0,1
ffffffffc0204042:	e19fc0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0204046:	89aa                	mv	s3,a0
ffffffffc0204048:	74050263          	beqz	a0,ffffffffc020478c <default_check+0x7b2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc020404c:	4505                	li	a0,1
ffffffffc020404e:	e0dfc0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0204052:	8aaa                	mv	s5,a0
ffffffffc0204054:	4c050c63          	beqz	a0,ffffffffc020452c <default_check+0x552>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0204058:	2d3a0a63          	beq	s4,s3,ffffffffc020432c <default_check+0x352>
ffffffffc020405c:	2caa0863          	beq	s4,a0,ffffffffc020432c <default_check+0x352>
ffffffffc0204060:	2ca98663          	beq	s3,a0,ffffffffc020432c <default_check+0x352>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0204064:	000a2783          	lw	a5,0(s4)
ffffffffc0204068:	2e079263          	bnez	a5,ffffffffc020434c <default_check+0x372>
ffffffffc020406c:	0009a783          	lw	a5,0(s3)
ffffffffc0204070:	2c079e63          	bnez	a5,ffffffffc020434c <default_check+0x372>
ffffffffc0204074:	411c                	lw	a5,0(a0)
ffffffffc0204076:	2c079b63          	bnez	a5,ffffffffc020434c <default_check+0x372>
    return page - pages + nbase;
ffffffffc020407a:	000a9797          	auipc	a5,0xa9
ffffffffc020407e:	84e78793          	addi	a5,a5,-1970 # ffffffffc02ac8c8 <pages>
ffffffffc0204082:	639c                	ld	a5,0(a5)
ffffffffc0204084:	00005717          	auipc	a4,0x5
ffffffffc0204088:	c6470713          	addi	a4,a4,-924 # ffffffffc0208ce8 <nbase>
ffffffffc020408c:	6310                	ld	a2,0(a4)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc020408e:	000a8717          	auipc	a4,0xa8
ffffffffc0204092:	7d270713          	addi	a4,a4,2002 # ffffffffc02ac860 <npage>
ffffffffc0204096:	6314                	ld	a3,0(a4)
ffffffffc0204098:	40fa0733          	sub	a4,s4,a5
ffffffffc020409c:	8719                	srai	a4,a4,0x6
ffffffffc020409e:	9732                	add	a4,a4,a2
ffffffffc02040a0:	06b2                	slli	a3,a3,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02040a2:	0732                	slli	a4,a4,0xc
ffffffffc02040a4:	2cd77463          	bgeu	a4,a3,ffffffffc020436c <default_check+0x392>
    return page - pages + nbase;
ffffffffc02040a8:	40f98733          	sub	a4,s3,a5
ffffffffc02040ac:	8719                	srai	a4,a4,0x6
ffffffffc02040ae:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02040b0:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02040b2:	4ed77d63          	bgeu	a4,a3,ffffffffc02045ac <default_check+0x5d2>
    return page - pages + nbase;
ffffffffc02040b6:	40f507b3          	sub	a5,a0,a5
ffffffffc02040ba:	8799                	srai	a5,a5,0x6
ffffffffc02040bc:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02040be:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc02040c0:	34d7f663          	bgeu	a5,a3,ffffffffc020440c <default_check+0x432>
    assert(alloc_page() == NULL);
ffffffffc02040c4:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc02040c6:	00093c03          	ld	s8,0(s2)
ffffffffc02040ca:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc02040ce:	01092b03          	lw	s6,16(s2)
    elm->prev = elm->next = elm;
ffffffffc02040d2:	000a9797          	auipc	a5,0xa9
ffffffffc02040d6:	8f27b323          	sd	s2,-1818(a5) # ffffffffc02ac9b8 <free_area+0x8>
ffffffffc02040da:	000a9797          	auipc	a5,0xa9
ffffffffc02040de:	8d27bb23          	sd	s2,-1834(a5) # ffffffffc02ac9b0 <free_area>
    nr_free = 0;
ffffffffc02040e2:	000a9797          	auipc	a5,0xa9
ffffffffc02040e6:	8c07af23          	sw	zero,-1826(a5) # ffffffffc02ac9c0 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc02040ea:	d71fc0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc02040ee:	2e051f63          	bnez	a0,ffffffffc02043ec <default_check+0x412>
    free_page(p0);
ffffffffc02040f2:	4585                	li	a1,1
ffffffffc02040f4:	8552                	mv	a0,s4
ffffffffc02040f6:	dedfc0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
    free_page(p1);
ffffffffc02040fa:	4585                	li	a1,1
ffffffffc02040fc:	854e                	mv	a0,s3
ffffffffc02040fe:	de5fc0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
    free_page(p2);
ffffffffc0204102:	4585                	li	a1,1
ffffffffc0204104:	8556                	mv	a0,s5
ffffffffc0204106:	dddfc0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
    assert(nr_free == 3);
ffffffffc020410a:	01092703          	lw	a4,16(s2)
ffffffffc020410e:	478d                	li	a5,3
ffffffffc0204110:	2af71e63          	bne	a4,a5,ffffffffc02043cc <default_check+0x3f2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0204114:	4505                	li	a0,1
ffffffffc0204116:	d45fc0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc020411a:	89aa                	mv	s3,a0
ffffffffc020411c:	28050863          	beqz	a0,ffffffffc02043ac <default_check+0x3d2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0204120:	4505                	li	a0,1
ffffffffc0204122:	d39fc0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0204126:	8aaa                	mv	s5,a0
ffffffffc0204128:	3e050263          	beqz	a0,ffffffffc020450c <default_check+0x532>
    assert((p2 = alloc_page()) != NULL);
ffffffffc020412c:	4505                	li	a0,1
ffffffffc020412e:	d2dfc0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0204132:	8a2a                	mv	s4,a0
ffffffffc0204134:	3a050c63          	beqz	a0,ffffffffc02044ec <default_check+0x512>
    assert(alloc_page() == NULL);
ffffffffc0204138:	4505                	li	a0,1
ffffffffc020413a:	d21fc0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc020413e:	38051763          	bnez	a0,ffffffffc02044cc <default_check+0x4f2>
    free_page(p0);
ffffffffc0204142:	4585                	li	a1,1
ffffffffc0204144:	854e                	mv	a0,s3
ffffffffc0204146:	d9dfc0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc020414a:	00893783          	ld	a5,8(s2)
ffffffffc020414e:	23278f63          	beq	a5,s2,ffffffffc020438c <default_check+0x3b2>
    assert((p = alloc_page()) == p0);
ffffffffc0204152:	4505                	li	a0,1
ffffffffc0204154:	d07fc0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0204158:	32a99a63          	bne	s3,a0,ffffffffc020448c <default_check+0x4b2>
    assert(alloc_page() == NULL);
ffffffffc020415c:	4505                	li	a0,1
ffffffffc020415e:	cfdfc0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0204162:	30051563          	bnez	a0,ffffffffc020446c <default_check+0x492>
    assert(nr_free == 0);
ffffffffc0204166:	01092783          	lw	a5,16(s2)
ffffffffc020416a:	2e079163          	bnez	a5,ffffffffc020444c <default_check+0x472>
    free_page(p);
ffffffffc020416e:	854e                	mv	a0,s3
ffffffffc0204170:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0204172:	000a9797          	auipc	a5,0xa9
ffffffffc0204176:	8387bf23          	sd	s8,-1986(a5) # ffffffffc02ac9b0 <free_area>
ffffffffc020417a:	000a9797          	auipc	a5,0xa9
ffffffffc020417e:	8377bf23          	sd	s7,-1986(a5) # ffffffffc02ac9b8 <free_area+0x8>
    nr_free = nr_free_store;
ffffffffc0204182:	000a9797          	auipc	a5,0xa9
ffffffffc0204186:	8367af23          	sw	s6,-1986(a5) # ffffffffc02ac9c0 <free_area+0x10>
    free_page(p);
ffffffffc020418a:	d59fc0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
    free_page(p1);
ffffffffc020418e:	4585                	li	a1,1
ffffffffc0204190:	8556                	mv	a0,s5
ffffffffc0204192:	d51fc0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
    free_page(p2);
ffffffffc0204196:	4585                	li	a1,1
ffffffffc0204198:	8552                	mv	a0,s4
ffffffffc020419a:	d49fc0ef          	jal	ra,ffffffffc0200ee2 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc020419e:	4515                	li	a0,5
ffffffffc02041a0:	cbbfc0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc02041a4:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc02041a6:	28050363          	beqz	a0,ffffffffc020442c <default_check+0x452>
ffffffffc02041aa:	651c                	ld	a5,8(a0)
ffffffffc02041ac:	8385                	srli	a5,a5,0x1
ffffffffc02041ae:	8b85                	andi	a5,a5,1
    assert(!PageProperty(p0));
ffffffffc02041b0:	54079e63          	bnez	a5,ffffffffc020470c <default_check+0x732>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc02041b4:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc02041b6:	00093b03          	ld	s6,0(s2)
ffffffffc02041ba:	00893a83          	ld	s5,8(s2)
ffffffffc02041be:	000a8797          	auipc	a5,0xa8
ffffffffc02041c2:	7f27b923          	sd	s2,2034(a5) # ffffffffc02ac9b0 <free_area>
ffffffffc02041c6:	000a8797          	auipc	a5,0xa8
ffffffffc02041ca:	7f27b923          	sd	s2,2034(a5) # ffffffffc02ac9b8 <free_area+0x8>
    assert(alloc_page() == NULL);
ffffffffc02041ce:	c8dfc0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc02041d2:	50051d63          	bnez	a0,ffffffffc02046ec <default_check+0x712>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc02041d6:	08098a13          	addi	s4,s3,128
ffffffffc02041da:	8552                	mv	a0,s4
ffffffffc02041dc:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc02041de:	01092b83          	lw	s7,16(s2)
    nr_free = 0;
ffffffffc02041e2:	000a8797          	auipc	a5,0xa8
ffffffffc02041e6:	7c07af23          	sw	zero,2014(a5) # ffffffffc02ac9c0 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc02041ea:	cf9fc0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc02041ee:	4511                	li	a0,4
ffffffffc02041f0:	c6bfc0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc02041f4:	4c051c63          	bnez	a0,ffffffffc02046cc <default_check+0x6f2>
ffffffffc02041f8:	0889b783          	ld	a5,136(s3)
ffffffffc02041fc:	8385                	srli	a5,a5,0x1
ffffffffc02041fe:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0204200:	4a078663          	beqz	a5,ffffffffc02046ac <default_check+0x6d2>
ffffffffc0204204:	0909a703          	lw	a4,144(s3)
ffffffffc0204208:	478d                	li	a5,3
ffffffffc020420a:	4af71163          	bne	a4,a5,ffffffffc02046ac <default_check+0x6d2>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc020420e:	450d                	li	a0,3
ffffffffc0204210:	c4bfc0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0204214:	8c2a                	mv	s8,a0
ffffffffc0204216:	46050b63          	beqz	a0,ffffffffc020468c <default_check+0x6b2>
    assert(alloc_page() == NULL);
ffffffffc020421a:	4505                	li	a0,1
ffffffffc020421c:	c3ffc0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0204220:	44051663          	bnez	a0,ffffffffc020466c <default_check+0x692>
    assert(p0 + 2 == p1);
ffffffffc0204224:	438a1463          	bne	s4,s8,ffffffffc020464c <default_check+0x672>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0204228:	4585                	li	a1,1
ffffffffc020422a:	854e                	mv	a0,s3
ffffffffc020422c:	cb7fc0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
    free_pages(p1, 3);
ffffffffc0204230:	458d                	li	a1,3
ffffffffc0204232:	8552                	mv	a0,s4
ffffffffc0204234:	caffc0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
ffffffffc0204238:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc020423c:	04098c13          	addi	s8,s3,64
ffffffffc0204240:	8385                	srli	a5,a5,0x1
ffffffffc0204242:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0204244:	3e078463          	beqz	a5,ffffffffc020462c <default_check+0x652>
ffffffffc0204248:	0109a703          	lw	a4,16(s3)
ffffffffc020424c:	4785                	li	a5,1
ffffffffc020424e:	3cf71f63          	bne	a4,a5,ffffffffc020462c <default_check+0x652>
ffffffffc0204252:	008a3783          	ld	a5,8(s4)
ffffffffc0204256:	8385                	srli	a5,a5,0x1
ffffffffc0204258:	8b85                	andi	a5,a5,1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc020425a:	3a078963          	beqz	a5,ffffffffc020460c <default_check+0x632>
ffffffffc020425e:	010a2703          	lw	a4,16(s4)
ffffffffc0204262:	478d                	li	a5,3
ffffffffc0204264:	3af71463          	bne	a4,a5,ffffffffc020460c <default_check+0x632>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0204268:	4505                	li	a0,1
ffffffffc020426a:	bf1fc0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc020426e:	36a99f63          	bne	s3,a0,ffffffffc02045ec <default_check+0x612>
    free_page(p0);
ffffffffc0204272:	4585                	li	a1,1
ffffffffc0204274:	c6ffc0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0204278:	4509                	li	a0,2
ffffffffc020427a:	be1fc0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc020427e:	34aa1763          	bne	s4,a0,ffffffffc02045cc <default_check+0x5f2>

    free_pages(p0, 2);
ffffffffc0204282:	4589                	li	a1,2
ffffffffc0204284:	c5ffc0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
    free_page(p2);
ffffffffc0204288:	4585                	li	a1,1
ffffffffc020428a:	8562                	mv	a0,s8
ffffffffc020428c:	c57fc0ef          	jal	ra,ffffffffc0200ee2 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0204290:	4515                	li	a0,5
ffffffffc0204292:	bc9fc0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0204296:	89aa                	mv	s3,a0
ffffffffc0204298:	48050a63          	beqz	a0,ffffffffc020472c <default_check+0x752>
    assert(alloc_page() == NULL);
ffffffffc020429c:	4505                	li	a0,1
ffffffffc020429e:	bbdfc0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc02042a2:	2e051563          	bnez	a0,ffffffffc020458c <default_check+0x5b2>

    assert(nr_free == 0);
ffffffffc02042a6:	01092783          	lw	a5,16(s2)
ffffffffc02042aa:	2c079163          	bnez	a5,ffffffffc020456c <default_check+0x592>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc02042ae:	4595                	li	a1,5
ffffffffc02042b0:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc02042b2:	000a8797          	auipc	a5,0xa8
ffffffffc02042b6:	7177a723          	sw	s7,1806(a5) # ffffffffc02ac9c0 <free_area+0x10>
    free_list = free_list_store;
ffffffffc02042ba:	000a8797          	auipc	a5,0xa8
ffffffffc02042be:	6f67bb23          	sd	s6,1782(a5) # ffffffffc02ac9b0 <free_area>
ffffffffc02042c2:	000a8797          	auipc	a5,0xa8
ffffffffc02042c6:	6f57bb23          	sd	s5,1782(a5) # ffffffffc02ac9b8 <free_area+0x8>
    free_pages(p0, 5);
ffffffffc02042ca:	c19fc0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
    return listelm->next;
ffffffffc02042ce:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc02042d2:	01278963          	beq	a5,s2,ffffffffc02042e4 <default_check+0x30a>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc02042d6:	ff87a703          	lw	a4,-8(a5)
ffffffffc02042da:	679c                	ld	a5,8(a5)
ffffffffc02042dc:	34fd                	addiw	s1,s1,-1
ffffffffc02042de:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc02042e0:	ff279be3          	bne	a5,s2,ffffffffc02042d6 <default_check+0x2fc>
    }
    assert(count == 0);
ffffffffc02042e4:	26049463          	bnez	s1,ffffffffc020454c <default_check+0x572>
    assert(total == 0);
ffffffffc02042e8:	46041263          	bnez	s0,ffffffffc020474c <default_check+0x772>
}
ffffffffc02042ec:	60a6                	ld	ra,72(sp)
ffffffffc02042ee:	6406                	ld	s0,64(sp)
ffffffffc02042f0:	74e2                	ld	s1,56(sp)
ffffffffc02042f2:	7942                	ld	s2,48(sp)
ffffffffc02042f4:	79a2                	ld	s3,40(sp)
ffffffffc02042f6:	7a02                	ld	s4,32(sp)
ffffffffc02042f8:	6ae2                	ld	s5,24(sp)
ffffffffc02042fa:	6b42                	ld	s6,16(sp)
ffffffffc02042fc:	6ba2                	ld	s7,8(sp)
ffffffffc02042fe:	6c02                	ld	s8,0(sp)
ffffffffc0204300:	6161                	addi	sp,sp,80
ffffffffc0204302:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0204304:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0204306:	4401                	li	s0,0
ffffffffc0204308:	4481                	li	s1,0
ffffffffc020430a:	b30d                	j	ffffffffc020402c <default_check+0x52>
        assert(PageProperty(p));
ffffffffc020430c:	00003697          	auipc	a3,0x3
ffffffffc0204310:	77468693          	addi	a3,a3,1908 # ffffffffc0207a80 <commands+0x1320>
ffffffffc0204314:	00003617          	auipc	a2,0x3
ffffffffc0204318:	8cc60613          	addi	a2,a2,-1844 # ffffffffc0206be0 <commands+0x480>
ffffffffc020431c:	0f000593          	li	a1,240
ffffffffc0204320:	00004517          	auipc	a0,0x4
ffffffffc0204324:	cb050513          	addi	a0,a0,-848 # ffffffffc0207fd0 <commands+0x1870>
ffffffffc0204328:	eedfb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc020432c:	00004697          	auipc	a3,0x4
ffffffffc0204330:	d1c68693          	addi	a3,a3,-740 # ffffffffc0208048 <commands+0x18e8>
ffffffffc0204334:	00003617          	auipc	a2,0x3
ffffffffc0204338:	8ac60613          	addi	a2,a2,-1876 # ffffffffc0206be0 <commands+0x480>
ffffffffc020433c:	0bd00593          	li	a1,189
ffffffffc0204340:	00004517          	auipc	a0,0x4
ffffffffc0204344:	c9050513          	addi	a0,a0,-880 # ffffffffc0207fd0 <commands+0x1870>
ffffffffc0204348:	ecdfb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc020434c:	00004697          	auipc	a3,0x4
ffffffffc0204350:	d2468693          	addi	a3,a3,-732 # ffffffffc0208070 <commands+0x1910>
ffffffffc0204354:	00003617          	auipc	a2,0x3
ffffffffc0204358:	88c60613          	addi	a2,a2,-1908 # ffffffffc0206be0 <commands+0x480>
ffffffffc020435c:	0be00593          	li	a1,190
ffffffffc0204360:	00004517          	auipc	a0,0x4
ffffffffc0204364:	c7050513          	addi	a0,a0,-912 # ffffffffc0207fd0 <commands+0x1870>
ffffffffc0204368:	eadfb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc020436c:	00004697          	auipc	a3,0x4
ffffffffc0204370:	d4468693          	addi	a3,a3,-700 # ffffffffc02080b0 <commands+0x1950>
ffffffffc0204374:	00003617          	auipc	a2,0x3
ffffffffc0204378:	86c60613          	addi	a2,a2,-1940 # ffffffffc0206be0 <commands+0x480>
ffffffffc020437c:	0c000593          	li	a1,192
ffffffffc0204380:	00004517          	auipc	a0,0x4
ffffffffc0204384:	c5050513          	addi	a0,a0,-944 # ffffffffc0207fd0 <commands+0x1870>
ffffffffc0204388:	e8dfb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(!list_empty(&free_list));
ffffffffc020438c:	00004697          	auipc	a3,0x4
ffffffffc0204390:	dac68693          	addi	a3,a3,-596 # ffffffffc0208138 <commands+0x19d8>
ffffffffc0204394:	00003617          	auipc	a2,0x3
ffffffffc0204398:	84c60613          	addi	a2,a2,-1972 # ffffffffc0206be0 <commands+0x480>
ffffffffc020439c:	0d900593          	li	a1,217
ffffffffc02043a0:	00004517          	auipc	a0,0x4
ffffffffc02043a4:	c3050513          	addi	a0,a0,-976 # ffffffffc0207fd0 <commands+0x1870>
ffffffffc02043a8:	e6dfb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02043ac:	00004697          	auipc	a3,0x4
ffffffffc02043b0:	c3c68693          	addi	a3,a3,-964 # ffffffffc0207fe8 <commands+0x1888>
ffffffffc02043b4:	00003617          	auipc	a2,0x3
ffffffffc02043b8:	82c60613          	addi	a2,a2,-2004 # ffffffffc0206be0 <commands+0x480>
ffffffffc02043bc:	0d200593          	li	a1,210
ffffffffc02043c0:	00004517          	auipc	a0,0x4
ffffffffc02043c4:	c1050513          	addi	a0,a0,-1008 # ffffffffc0207fd0 <commands+0x1870>
ffffffffc02043c8:	e4dfb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(nr_free == 3);
ffffffffc02043cc:	00004697          	auipc	a3,0x4
ffffffffc02043d0:	d5c68693          	addi	a3,a3,-676 # ffffffffc0208128 <commands+0x19c8>
ffffffffc02043d4:	00003617          	auipc	a2,0x3
ffffffffc02043d8:	80c60613          	addi	a2,a2,-2036 # ffffffffc0206be0 <commands+0x480>
ffffffffc02043dc:	0d000593          	li	a1,208
ffffffffc02043e0:	00004517          	auipc	a0,0x4
ffffffffc02043e4:	bf050513          	addi	a0,a0,-1040 # ffffffffc0207fd0 <commands+0x1870>
ffffffffc02043e8:	e2dfb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02043ec:	00004697          	auipc	a3,0x4
ffffffffc02043f0:	d2468693          	addi	a3,a3,-732 # ffffffffc0208110 <commands+0x19b0>
ffffffffc02043f4:	00002617          	auipc	a2,0x2
ffffffffc02043f8:	7ec60613          	addi	a2,a2,2028 # ffffffffc0206be0 <commands+0x480>
ffffffffc02043fc:	0cb00593          	li	a1,203
ffffffffc0204400:	00004517          	auipc	a0,0x4
ffffffffc0204404:	bd050513          	addi	a0,a0,-1072 # ffffffffc0207fd0 <commands+0x1870>
ffffffffc0204408:	e0dfb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc020440c:	00004697          	auipc	a3,0x4
ffffffffc0204410:	ce468693          	addi	a3,a3,-796 # ffffffffc02080f0 <commands+0x1990>
ffffffffc0204414:	00002617          	auipc	a2,0x2
ffffffffc0204418:	7cc60613          	addi	a2,a2,1996 # ffffffffc0206be0 <commands+0x480>
ffffffffc020441c:	0c200593          	li	a1,194
ffffffffc0204420:	00004517          	auipc	a0,0x4
ffffffffc0204424:	bb050513          	addi	a0,a0,-1104 # ffffffffc0207fd0 <commands+0x1870>
ffffffffc0204428:	dedfb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(p0 != NULL);
ffffffffc020442c:	00004697          	auipc	a3,0x4
ffffffffc0204430:	d4468693          	addi	a3,a3,-700 # ffffffffc0208170 <commands+0x1a10>
ffffffffc0204434:	00002617          	auipc	a2,0x2
ffffffffc0204438:	7ac60613          	addi	a2,a2,1964 # ffffffffc0206be0 <commands+0x480>
ffffffffc020443c:	0f800593          	li	a1,248
ffffffffc0204440:	00004517          	auipc	a0,0x4
ffffffffc0204444:	b9050513          	addi	a0,a0,-1136 # ffffffffc0207fd0 <commands+0x1870>
ffffffffc0204448:	dcdfb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(nr_free == 0);
ffffffffc020444c:	00003697          	auipc	a3,0x3
ffffffffc0204450:	7e468693          	addi	a3,a3,2020 # ffffffffc0207c30 <commands+0x14d0>
ffffffffc0204454:	00002617          	auipc	a2,0x2
ffffffffc0204458:	78c60613          	addi	a2,a2,1932 # ffffffffc0206be0 <commands+0x480>
ffffffffc020445c:	0df00593          	li	a1,223
ffffffffc0204460:	00004517          	auipc	a0,0x4
ffffffffc0204464:	b7050513          	addi	a0,a0,-1168 # ffffffffc0207fd0 <commands+0x1870>
ffffffffc0204468:	dadfb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020446c:	00004697          	auipc	a3,0x4
ffffffffc0204470:	ca468693          	addi	a3,a3,-860 # ffffffffc0208110 <commands+0x19b0>
ffffffffc0204474:	00002617          	auipc	a2,0x2
ffffffffc0204478:	76c60613          	addi	a2,a2,1900 # ffffffffc0206be0 <commands+0x480>
ffffffffc020447c:	0dd00593          	li	a1,221
ffffffffc0204480:	00004517          	auipc	a0,0x4
ffffffffc0204484:	b5050513          	addi	a0,a0,-1200 # ffffffffc0207fd0 <commands+0x1870>
ffffffffc0204488:	d8dfb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc020448c:	00004697          	auipc	a3,0x4
ffffffffc0204490:	cc468693          	addi	a3,a3,-828 # ffffffffc0208150 <commands+0x19f0>
ffffffffc0204494:	00002617          	auipc	a2,0x2
ffffffffc0204498:	74c60613          	addi	a2,a2,1868 # ffffffffc0206be0 <commands+0x480>
ffffffffc020449c:	0dc00593          	li	a1,220
ffffffffc02044a0:	00004517          	auipc	a0,0x4
ffffffffc02044a4:	b3050513          	addi	a0,a0,-1232 # ffffffffc0207fd0 <commands+0x1870>
ffffffffc02044a8:	d6dfb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02044ac:	00004697          	auipc	a3,0x4
ffffffffc02044b0:	b3c68693          	addi	a3,a3,-1220 # ffffffffc0207fe8 <commands+0x1888>
ffffffffc02044b4:	00002617          	auipc	a2,0x2
ffffffffc02044b8:	72c60613          	addi	a2,a2,1836 # ffffffffc0206be0 <commands+0x480>
ffffffffc02044bc:	0b900593          	li	a1,185
ffffffffc02044c0:	00004517          	auipc	a0,0x4
ffffffffc02044c4:	b1050513          	addi	a0,a0,-1264 # ffffffffc0207fd0 <commands+0x1870>
ffffffffc02044c8:	d4dfb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02044cc:	00004697          	auipc	a3,0x4
ffffffffc02044d0:	c4468693          	addi	a3,a3,-956 # ffffffffc0208110 <commands+0x19b0>
ffffffffc02044d4:	00002617          	auipc	a2,0x2
ffffffffc02044d8:	70c60613          	addi	a2,a2,1804 # ffffffffc0206be0 <commands+0x480>
ffffffffc02044dc:	0d600593          	li	a1,214
ffffffffc02044e0:	00004517          	auipc	a0,0x4
ffffffffc02044e4:	af050513          	addi	a0,a0,-1296 # ffffffffc0207fd0 <commands+0x1870>
ffffffffc02044e8:	d2dfb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02044ec:	00004697          	auipc	a3,0x4
ffffffffc02044f0:	b3c68693          	addi	a3,a3,-1220 # ffffffffc0208028 <commands+0x18c8>
ffffffffc02044f4:	00002617          	auipc	a2,0x2
ffffffffc02044f8:	6ec60613          	addi	a2,a2,1772 # ffffffffc0206be0 <commands+0x480>
ffffffffc02044fc:	0d400593          	li	a1,212
ffffffffc0204500:	00004517          	auipc	a0,0x4
ffffffffc0204504:	ad050513          	addi	a0,a0,-1328 # ffffffffc0207fd0 <commands+0x1870>
ffffffffc0204508:	d0dfb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020450c:	00004697          	auipc	a3,0x4
ffffffffc0204510:	afc68693          	addi	a3,a3,-1284 # ffffffffc0208008 <commands+0x18a8>
ffffffffc0204514:	00002617          	auipc	a2,0x2
ffffffffc0204518:	6cc60613          	addi	a2,a2,1740 # ffffffffc0206be0 <commands+0x480>
ffffffffc020451c:	0d300593          	li	a1,211
ffffffffc0204520:	00004517          	auipc	a0,0x4
ffffffffc0204524:	ab050513          	addi	a0,a0,-1360 # ffffffffc0207fd0 <commands+0x1870>
ffffffffc0204528:	cedfb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc020452c:	00004697          	auipc	a3,0x4
ffffffffc0204530:	afc68693          	addi	a3,a3,-1284 # ffffffffc0208028 <commands+0x18c8>
ffffffffc0204534:	00002617          	auipc	a2,0x2
ffffffffc0204538:	6ac60613          	addi	a2,a2,1708 # ffffffffc0206be0 <commands+0x480>
ffffffffc020453c:	0bb00593          	li	a1,187
ffffffffc0204540:	00004517          	auipc	a0,0x4
ffffffffc0204544:	a9050513          	addi	a0,a0,-1392 # ffffffffc0207fd0 <commands+0x1870>
ffffffffc0204548:	ccdfb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(count == 0);
ffffffffc020454c:	00004697          	auipc	a3,0x4
ffffffffc0204550:	d7468693          	addi	a3,a3,-652 # ffffffffc02082c0 <commands+0x1b60>
ffffffffc0204554:	00002617          	auipc	a2,0x2
ffffffffc0204558:	68c60613          	addi	a2,a2,1676 # ffffffffc0206be0 <commands+0x480>
ffffffffc020455c:	12500593          	li	a1,293
ffffffffc0204560:	00004517          	auipc	a0,0x4
ffffffffc0204564:	a7050513          	addi	a0,a0,-1424 # ffffffffc0207fd0 <commands+0x1870>
ffffffffc0204568:	cadfb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(nr_free == 0);
ffffffffc020456c:	00003697          	auipc	a3,0x3
ffffffffc0204570:	6c468693          	addi	a3,a3,1732 # ffffffffc0207c30 <commands+0x14d0>
ffffffffc0204574:	00002617          	auipc	a2,0x2
ffffffffc0204578:	66c60613          	addi	a2,a2,1644 # ffffffffc0206be0 <commands+0x480>
ffffffffc020457c:	11a00593          	li	a1,282
ffffffffc0204580:	00004517          	auipc	a0,0x4
ffffffffc0204584:	a5050513          	addi	a0,a0,-1456 # ffffffffc0207fd0 <commands+0x1870>
ffffffffc0204588:	c8dfb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020458c:	00004697          	auipc	a3,0x4
ffffffffc0204590:	b8468693          	addi	a3,a3,-1148 # ffffffffc0208110 <commands+0x19b0>
ffffffffc0204594:	00002617          	auipc	a2,0x2
ffffffffc0204598:	64c60613          	addi	a2,a2,1612 # ffffffffc0206be0 <commands+0x480>
ffffffffc020459c:	11800593          	li	a1,280
ffffffffc02045a0:	00004517          	auipc	a0,0x4
ffffffffc02045a4:	a3050513          	addi	a0,a0,-1488 # ffffffffc0207fd0 <commands+0x1870>
ffffffffc02045a8:	c6dfb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02045ac:	00004697          	auipc	a3,0x4
ffffffffc02045b0:	b2468693          	addi	a3,a3,-1244 # ffffffffc02080d0 <commands+0x1970>
ffffffffc02045b4:	00002617          	auipc	a2,0x2
ffffffffc02045b8:	62c60613          	addi	a2,a2,1580 # ffffffffc0206be0 <commands+0x480>
ffffffffc02045bc:	0c100593          	li	a1,193
ffffffffc02045c0:	00004517          	auipc	a0,0x4
ffffffffc02045c4:	a1050513          	addi	a0,a0,-1520 # ffffffffc0207fd0 <commands+0x1870>
ffffffffc02045c8:	c4dfb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc02045cc:	00004697          	auipc	a3,0x4
ffffffffc02045d0:	cb468693          	addi	a3,a3,-844 # ffffffffc0208280 <commands+0x1b20>
ffffffffc02045d4:	00002617          	auipc	a2,0x2
ffffffffc02045d8:	60c60613          	addi	a2,a2,1548 # ffffffffc0206be0 <commands+0x480>
ffffffffc02045dc:	11200593          	li	a1,274
ffffffffc02045e0:	00004517          	auipc	a0,0x4
ffffffffc02045e4:	9f050513          	addi	a0,a0,-1552 # ffffffffc0207fd0 <commands+0x1870>
ffffffffc02045e8:	c2dfb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02045ec:	00004697          	auipc	a3,0x4
ffffffffc02045f0:	c7468693          	addi	a3,a3,-908 # ffffffffc0208260 <commands+0x1b00>
ffffffffc02045f4:	00002617          	auipc	a2,0x2
ffffffffc02045f8:	5ec60613          	addi	a2,a2,1516 # ffffffffc0206be0 <commands+0x480>
ffffffffc02045fc:	11000593          	li	a1,272
ffffffffc0204600:	00004517          	auipc	a0,0x4
ffffffffc0204604:	9d050513          	addi	a0,a0,-1584 # ffffffffc0207fd0 <commands+0x1870>
ffffffffc0204608:	c0dfb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc020460c:	00004697          	auipc	a3,0x4
ffffffffc0204610:	c2c68693          	addi	a3,a3,-980 # ffffffffc0208238 <commands+0x1ad8>
ffffffffc0204614:	00002617          	auipc	a2,0x2
ffffffffc0204618:	5cc60613          	addi	a2,a2,1484 # ffffffffc0206be0 <commands+0x480>
ffffffffc020461c:	10e00593          	li	a1,270
ffffffffc0204620:	00004517          	auipc	a0,0x4
ffffffffc0204624:	9b050513          	addi	a0,a0,-1616 # ffffffffc0207fd0 <commands+0x1870>
ffffffffc0204628:	bedfb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc020462c:	00004697          	auipc	a3,0x4
ffffffffc0204630:	be468693          	addi	a3,a3,-1052 # ffffffffc0208210 <commands+0x1ab0>
ffffffffc0204634:	00002617          	auipc	a2,0x2
ffffffffc0204638:	5ac60613          	addi	a2,a2,1452 # ffffffffc0206be0 <commands+0x480>
ffffffffc020463c:	10d00593          	li	a1,269
ffffffffc0204640:	00004517          	auipc	a0,0x4
ffffffffc0204644:	99050513          	addi	a0,a0,-1648 # ffffffffc0207fd0 <commands+0x1870>
ffffffffc0204648:	bcdfb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(p0 + 2 == p1);
ffffffffc020464c:	00004697          	auipc	a3,0x4
ffffffffc0204650:	bb468693          	addi	a3,a3,-1100 # ffffffffc0208200 <commands+0x1aa0>
ffffffffc0204654:	00002617          	auipc	a2,0x2
ffffffffc0204658:	58c60613          	addi	a2,a2,1420 # ffffffffc0206be0 <commands+0x480>
ffffffffc020465c:	10800593          	li	a1,264
ffffffffc0204660:	00004517          	auipc	a0,0x4
ffffffffc0204664:	97050513          	addi	a0,a0,-1680 # ffffffffc0207fd0 <commands+0x1870>
ffffffffc0204668:	badfb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020466c:	00004697          	auipc	a3,0x4
ffffffffc0204670:	aa468693          	addi	a3,a3,-1372 # ffffffffc0208110 <commands+0x19b0>
ffffffffc0204674:	00002617          	auipc	a2,0x2
ffffffffc0204678:	56c60613          	addi	a2,a2,1388 # ffffffffc0206be0 <commands+0x480>
ffffffffc020467c:	10700593          	li	a1,263
ffffffffc0204680:	00004517          	auipc	a0,0x4
ffffffffc0204684:	95050513          	addi	a0,a0,-1712 # ffffffffc0207fd0 <commands+0x1870>
ffffffffc0204688:	b8dfb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc020468c:	00004697          	auipc	a3,0x4
ffffffffc0204690:	b5468693          	addi	a3,a3,-1196 # ffffffffc02081e0 <commands+0x1a80>
ffffffffc0204694:	00002617          	auipc	a2,0x2
ffffffffc0204698:	54c60613          	addi	a2,a2,1356 # ffffffffc0206be0 <commands+0x480>
ffffffffc020469c:	10600593          	li	a1,262
ffffffffc02046a0:	00004517          	auipc	a0,0x4
ffffffffc02046a4:	93050513          	addi	a0,a0,-1744 # ffffffffc0207fd0 <commands+0x1870>
ffffffffc02046a8:	b6dfb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc02046ac:	00004697          	auipc	a3,0x4
ffffffffc02046b0:	b0468693          	addi	a3,a3,-1276 # ffffffffc02081b0 <commands+0x1a50>
ffffffffc02046b4:	00002617          	auipc	a2,0x2
ffffffffc02046b8:	52c60613          	addi	a2,a2,1324 # ffffffffc0206be0 <commands+0x480>
ffffffffc02046bc:	10500593          	li	a1,261
ffffffffc02046c0:	00004517          	auipc	a0,0x4
ffffffffc02046c4:	91050513          	addi	a0,a0,-1776 # ffffffffc0207fd0 <commands+0x1870>
ffffffffc02046c8:	b4dfb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc02046cc:	00004697          	auipc	a3,0x4
ffffffffc02046d0:	acc68693          	addi	a3,a3,-1332 # ffffffffc0208198 <commands+0x1a38>
ffffffffc02046d4:	00002617          	auipc	a2,0x2
ffffffffc02046d8:	50c60613          	addi	a2,a2,1292 # ffffffffc0206be0 <commands+0x480>
ffffffffc02046dc:	10400593          	li	a1,260
ffffffffc02046e0:	00004517          	auipc	a0,0x4
ffffffffc02046e4:	8f050513          	addi	a0,a0,-1808 # ffffffffc0207fd0 <commands+0x1870>
ffffffffc02046e8:	b2dfb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02046ec:	00004697          	auipc	a3,0x4
ffffffffc02046f0:	a2468693          	addi	a3,a3,-1500 # ffffffffc0208110 <commands+0x19b0>
ffffffffc02046f4:	00002617          	auipc	a2,0x2
ffffffffc02046f8:	4ec60613          	addi	a2,a2,1260 # ffffffffc0206be0 <commands+0x480>
ffffffffc02046fc:	0fe00593          	li	a1,254
ffffffffc0204700:	00004517          	auipc	a0,0x4
ffffffffc0204704:	8d050513          	addi	a0,a0,-1840 # ffffffffc0207fd0 <commands+0x1870>
ffffffffc0204708:	b0dfb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(!PageProperty(p0));
ffffffffc020470c:	00004697          	auipc	a3,0x4
ffffffffc0204710:	a7468693          	addi	a3,a3,-1420 # ffffffffc0208180 <commands+0x1a20>
ffffffffc0204714:	00002617          	auipc	a2,0x2
ffffffffc0204718:	4cc60613          	addi	a2,a2,1228 # ffffffffc0206be0 <commands+0x480>
ffffffffc020471c:	0f900593          	li	a1,249
ffffffffc0204720:	00004517          	auipc	a0,0x4
ffffffffc0204724:	8b050513          	addi	a0,a0,-1872 # ffffffffc0207fd0 <commands+0x1870>
ffffffffc0204728:	aedfb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc020472c:	00004697          	auipc	a3,0x4
ffffffffc0204730:	b7468693          	addi	a3,a3,-1164 # ffffffffc02082a0 <commands+0x1b40>
ffffffffc0204734:	00002617          	auipc	a2,0x2
ffffffffc0204738:	4ac60613          	addi	a2,a2,1196 # ffffffffc0206be0 <commands+0x480>
ffffffffc020473c:	11700593          	li	a1,279
ffffffffc0204740:	00004517          	auipc	a0,0x4
ffffffffc0204744:	89050513          	addi	a0,a0,-1904 # ffffffffc0207fd0 <commands+0x1870>
ffffffffc0204748:	acdfb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(total == 0);
ffffffffc020474c:	00004697          	auipc	a3,0x4
ffffffffc0204750:	b8468693          	addi	a3,a3,-1148 # ffffffffc02082d0 <commands+0x1b70>
ffffffffc0204754:	00002617          	auipc	a2,0x2
ffffffffc0204758:	48c60613          	addi	a2,a2,1164 # ffffffffc0206be0 <commands+0x480>
ffffffffc020475c:	12600593          	li	a1,294
ffffffffc0204760:	00004517          	auipc	a0,0x4
ffffffffc0204764:	87050513          	addi	a0,a0,-1936 # ffffffffc0207fd0 <commands+0x1870>
ffffffffc0204768:	aadfb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(total == nr_free_pages());
ffffffffc020476c:	00003697          	auipc	a3,0x3
ffffffffc0204770:	32468693          	addi	a3,a3,804 # ffffffffc0207a90 <commands+0x1330>
ffffffffc0204774:	00002617          	auipc	a2,0x2
ffffffffc0204778:	46c60613          	addi	a2,a2,1132 # ffffffffc0206be0 <commands+0x480>
ffffffffc020477c:	0f300593          	li	a1,243
ffffffffc0204780:	00004517          	auipc	a0,0x4
ffffffffc0204784:	85050513          	addi	a0,a0,-1968 # ffffffffc0207fd0 <commands+0x1870>
ffffffffc0204788:	a8dfb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020478c:	00004697          	auipc	a3,0x4
ffffffffc0204790:	87c68693          	addi	a3,a3,-1924 # ffffffffc0208008 <commands+0x18a8>
ffffffffc0204794:	00002617          	auipc	a2,0x2
ffffffffc0204798:	44c60613          	addi	a2,a2,1100 # ffffffffc0206be0 <commands+0x480>
ffffffffc020479c:	0ba00593          	li	a1,186
ffffffffc02047a0:	00004517          	auipc	a0,0x4
ffffffffc02047a4:	83050513          	addi	a0,a0,-2000 # ffffffffc0207fd0 <commands+0x1870>
ffffffffc02047a8:	a6dfb0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc02047ac <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc02047ac:	1141                	addi	sp,sp,-16
ffffffffc02047ae:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02047b0:	16058e63          	beqz	a1,ffffffffc020492c <default_free_pages+0x180>
    for (; p != base + n; p ++) {
ffffffffc02047b4:	00659693          	slli	a3,a1,0x6
ffffffffc02047b8:	96aa                	add	a3,a3,a0
ffffffffc02047ba:	02d50d63          	beq	a0,a3,ffffffffc02047f4 <default_free_pages+0x48>
ffffffffc02047be:	651c                	ld	a5,8(a0)
ffffffffc02047c0:	8b85                	andi	a5,a5,1
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02047c2:	14079563          	bnez	a5,ffffffffc020490c <default_free_pages+0x160>
ffffffffc02047c6:	651c                	ld	a5,8(a0)
ffffffffc02047c8:	8385                	srli	a5,a5,0x1
ffffffffc02047ca:	8b85                	andi	a5,a5,1
ffffffffc02047cc:	14079063          	bnez	a5,ffffffffc020490c <default_free_pages+0x160>
ffffffffc02047d0:	87aa                	mv	a5,a0
ffffffffc02047d2:	a809                	j	ffffffffc02047e4 <default_free_pages+0x38>
ffffffffc02047d4:	6798                	ld	a4,8(a5)
ffffffffc02047d6:	8b05                	andi	a4,a4,1
ffffffffc02047d8:	12071a63          	bnez	a4,ffffffffc020490c <default_free_pages+0x160>
ffffffffc02047dc:	6798                	ld	a4,8(a5)
ffffffffc02047de:	8b09                	andi	a4,a4,2
ffffffffc02047e0:	12071663          	bnez	a4,ffffffffc020490c <default_free_pages+0x160>
        p->flags = 0;
ffffffffc02047e4:	0007b423          	sd	zero,8(a5)
    page->ref = val;
ffffffffc02047e8:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02047ec:	04078793          	addi	a5,a5,64
ffffffffc02047f0:	fed792e3          	bne	a5,a3,ffffffffc02047d4 <default_free_pages+0x28>
    base->property = n;
ffffffffc02047f4:	2581                	sext.w	a1,a1
ffffffffc02047f6:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc02047f8:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02047fc:	4789                	li	a5,2
ffffffffc02047fe:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc0204802:	000a8697          	auipc	a3,0xa8
ffffffffc0204806:	1ae68693          	addi	a3,a3,430 # ffffffffc02ac9b0 <free_area>
ffffffffc020480a:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc020480c:	669c                	ld	a5,8(a3)
ffffffffc020480e:	9db9                	addw	a1,a1,a4
ffffffffc0204810:	000a8717          	auipc	a4,0xa8
ffffffffc0204814:	1ab72823          	sw	a1,432(a4) # ffffffffc02ac9c0 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc0204818:	0cd78163          	beq	a5,a3,ffffffffc02048da <default_free_pages+0x12e>
            struct Page* page = le2page(le, page_link);
ffffffffc020481c:	fe878713          	addi	a4,a5,-24
ffffffffc0204820:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0204822:	4801                	li	a6,0
ffffffffc0204824:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc0204828:	00e56a63          	bltu	a0,a4,ffffffffc020483c <default_free_pages+0x90>
    return listelm->next;
ffffffffc020482c:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc020482e:	04d70f63          	beq	a4,a3,ffffffffc020488c <default_free_pages+0xe0>
        while ((le = list_next(le)) != &free_list) {
ffffffffc0204832:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0204834:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0204838:	fee57ae3          	bgeu	a0,a4,ffffffffc020482c <default_free_pages+0x80>
ffffffffc020483c:	00080663          	beqz	a6,ffffffffc0204848 <default_free_pages+0x9c>
ffffffffc0204840:	000a8817          	auipc	a6,0xa8
ffffffffc0204844:	16b83823          	sd	a1,368(a6) # ffffffffc02ac9b0 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0204848:	638c                	ld	a1,0(a5)
    prev->next = next->prev = elm;
ffffffffc020484a:	e390                	sd	a2,0(a5)
ffffffffc020484c:	e590                	sd	a2,8(a1)
    elm->next = next;
ffffffffc020484e:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0204850:	ed0c                	sd	a1,24(a0)
    if (le != &free_list) {
ffffffffc0204852:	06d58a63          	beq	a1,a3,ffffffffc02048c6 <default_free_pages+0x11a>
        if (p + p->property == base) {
ffffffffc0204856:	ff85a603          	lw	a2,-8(a1) # ff8 <_binary_obj___user_faultread_out_size-0x85d0>
        p = le2page(le, page_link);
ffffffffc020485a:	fe858713          	addi	a4,a1,-24
        if (p + p->property == base) {
ffffffffc020485e:	02061793          	slli	a5,a2,0x20
ffffffffc0204862:	83e9                	srli	a5,a5,0x1a
ffffffffc0204864:	97ba                	add	a5,a5,a4
ffffffffc0204866:	04f51b63          	bne	a0,a5,ffffffffc02048bc <default_free_pages+0x110>
            p->property += base->property;
ffffffffc020486a:	491c                	lw	a5,16(a0)
ffffffffc020486c:	9e3d                	addw	a2,a2,a5
ffffffffc020486e:	fec5ac23          	sw	a2,-8(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0204872:	57f5                	li	a5,-3
ffffffffc0204874:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0204878:	01853803          	ld	a6,24(a0)
ffffffffc020487c:	7110                	ld	a2,32(a0)
            base = p;
ffffffffc020487e:	853a                	mv	a0,a4
    prev->next = next;
ffffffffc0204880:	00c83423          	sd	a2,8(a6)
    next->prev = prev;
ffffffffc0204884:	659c                	ld	a5,8(a1)
ffffffffc0204886:	01063023          	sd	a6,0(a2)
ffffffffc020488a:	a815                	j	ffffffffc02048be <default_free_pages+0x112>
    prev->next = next->prev = elm;
ffffffffc020488c:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020488e:	f114                	sd	a3,32(a0)
ffffffffc0204890:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0204892:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc0204894:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0204896:	00d70563          	beq	a4,a3,ffffffffc02048a0 <default_free_pages+0xf4>
ffffffffc020489a:	4805                	li	a6,1
ffffffffc020489c:	87ba                	mv	a5,a4
ffffffffc020489e:	bf59                	j	ffffffffc0204834 <default_free_pages+0x88>
ffffffffc02048a0:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc02048a2:	85be                	mv	a1,a5
    if (le != &free_list) {
ffffffffc02048a4:	00d78d63          	beq	a5,a3,ffffffffc02048be <default_free_pages+0x112>
        if (p + p->property == base) {
ffffffffc02048a8:	ff85a603          	lw	a2,-8(a1)
        p = le2page(le, page_link);
ffffffffc02048ac:	fe858713          	addi	a4,a1,-24
        if (p + p->property == base) {
ffffffffc02048b0:	02061793          	slli	a5,a2,0x20
ffffffffc02048b4:	83e9                	srli	a5,a5,0x1a
ffffffffc02048b6:	97ba                	add	a5,a5,a4
ffffffffc02048b8:	faf509e3          	beq	a0,a5,ffffffffc020486a <default_free_pages+0xbe>
ffffffffc02048bc:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc02048be:	fe878713          	addi	a4,a5,-24
ffffffffc02048c2:	00d78963          	beq	a5,a3,ffffffffc02048d4 <default_free_pages+0x128>
        if (base + base->property == p) {
ffffffffc02048c6:	4910                	lw	a2,16(a0)
ffffffffc02048c8:	02061693          	slli	a3,a2,0x20
ffffffffc02048cc:	82e9                	srli	a3,a3,0x1a
ffffffffc02048ce:	96aa                	add	a3,a3,a0
ffffffffc02048d0:	00d70e63          	beq	a4,a3,ffffffffc02048ec <default_free_pages+0x140>
}
ffffffffc02048d4:	60a2                	ld	ra,8(sp)
ffffffffc02048d6:	0141                	addi	sp,sp,16
ffffffffc02048d8:	8082                	ret
ffffffffc02048da:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc02048dc:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc02048e0:	e398                	sd	a4,0(a5)
ffffffffc02048e2:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc02048e4:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02048e6:	ed1c                	sd	a5,24(a0)
}
ffffffffc02048e8:	0141                	addi	sp,sp,16
ffffffffc02048ea:	8082                	ret
            base->property += p->property;
ffffffffc02048ec:	ff87a703          	lw	a4,-8(a5)
ffffffffc02048f0:	ff078693          	addi	a3,a5,-16
ffffffffc02048f4:	9e39                	addw	a2,a2,a4
ffffffffc02048f6:	c910                	sw	a2,16(a0)
ffffffffc02048f8:	5775                	li	a4,-3
ffffffffc02048fa:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02048fe:	6398                	ld	a4,0(a5)
ffffffffc0204900:	679c                	ld	a5,8(a5)
}
ffffffffc0204902:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0204904:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0204906:	e398                	sd	a4,0(a5)
ffffffffc0204908:	0141                	addi	sp,sp,16
ffffffffc020490a:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020490c:	00004697          	auipc	a3,0x4
ffffffffc0204910:	9d468693          	addi	a3,a3,-1580 # ffffffffc02082e0 <commands+0x1b80>
ffffffffc0204914:	00002617          	auipc	a2,0x2
ffffffffc0204918:	2cc60613          	addi	a2,a2,716 # ffffffffc0206be0 <commands+0x480>
ffffffffc020491c:	08300593          	li	a1,131
ffffffffc0204920:	00003517          	auipc	a0,0x3
ffffffffc0204924:	6b050513          	addi	a0,a0,1712 # ffffffffc0207fd0 <commands+0x1870>
ffffffffc0204928:	8edfb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(n > 0);
ffffffffc020492c:	00004697          	auipc	a3,0x4
ffffffffc0204930:	9dc68693          	addi	a3,a3,-1572 # ffffffffc0208308 <commands+0x1ba8>
ffffffffc0204934:	00002617          	auipc	a2,0x2
ffffffffc0204938:	2ac60613          	addi	a2,a2,684 # ffffffffc0206be0 <commands+0x480>
ffffffffc020493c:	08000593          	li	a1,128
ffffffffc0204940:	00003517          	auipc	a0,0x3
ffffffffc0204944:	69050513          	addi	a0,a0,1680 # ffffffffc0207fd0 <commands+0x1870>
ffffffffc0204948:	8cdfb0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc020494c <default_alloc_pages>:
    assert(n > 0);
ffffffffc020494c:	c959                	beqz	a0,ffffffffc02049e2 <default_alloc_pages+0x96>
    if (n > nr_free) {
ffffffffc020494e:	000a8597          	auipc	a1,0xa8
ffffffffc0204952:	06258593          	addi	a1,a1,98 # ffffffffc02ac9b0 <free_area>
ffffffffc0204956:	0105a803          	lw	a6,16(a1)
ffffffffc020495a:	862a                	mv	a2,a0
ffffffffc020495c:	02081793          	slli	a5,a6,0x20
ffffffffc0204960:	9381                	srli	a5,a5,0x20
ffffffffc0204962:	00a7ee63          	bltu	a5,a0,ffffffffc020497e <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc0204966:	87ae                	mv	a5,a1
ffffffffc0204968:	a801                	j	ffffffffc0204978 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc020496a:	ff87a703          	lw	a4,-8(a5)
ffffffffc020496e:	02071693          	slli	a3,a4,0x20
ffffffffc0204972:	9281                	srli	a3,a3,0x20
ffffffffc0204974:	00c6f763          	bgeu	a3,a2,ffffffffc0204982 <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc0204978:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc020497a:	feb798e3          	bne	a5,a1,ffffffffc020496a <default_alloc_pages+0x1e>
        return NULL;
ffffffffc020497e:	4501                	li	a0,0
}
ffffffffc0204980:	8082                	ret
        struct Page *p = le2page(le, page_link);
ffffffffc0204982:	fe878513          	addi	a0,a5,-24
    if (page != NULL) {
ffffffffc0204986:	dd6d                	beqz	a0,ffffffffc0204980 <default_alloc_pages+0x34>
    return listelm->prev;
ffffffffc0204988:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc020498c:	0087b303          	ld	t1,8(a5)
    prev->next = next;
ffffffffc0204990:	00060e1b          	sext.w	t3,a2
ffffffffc0204994:	0068b423          	sd	t1,8(a7) # fffffffffff80008 <end+0x3fcd3630>
    next->prev = prev;
ffffffffc0204998:	01133023          	sd	a7,0(t1) # ffffffffc0000000 <_binary_obj___user_exit_out_size+0xffffffffbfff5538>
        if (page->property > n) {
ffffffffc020499c:	02d67863          	bgeu	a2,a3,ffffffffc02049cc <default_alloc_pages+0x80>
            struct Page *p = page + n;
ffffffffc02049a0:	061a                	slli	a2,a2,0x6
ffffffffc02049a2:	962a                	add	a2,a2,a0
            p->property = page->property - n;
ffffffffc02049a4:	41c7073b          	subw	a4,a4,t3
ffffffffc02049a8:	ca18                	sw	a4,16(a2)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02049aa:	00860693          	addi	a3,a2,8
ffffffffc02049ae:	4709                	li	a4,2
ffffffffc02049b0:	40e6b02f          	amoor.d	zero,a4,(a3)
    __list_add(elm, listelm, listelm->next);
ffffffffc02049b4:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc02049b8:	01860693          	addi	a3,a2,24
    prev->next = next->prev = elm;
ffffffffc02049bc:	0105a803          	lw	a6,16(a1)
ffffffffc02049c0:	e314                	sd	a3,0(a4)
ffffffffc02049c2:	00d8b423          	sd	a3,8(a7)
    elm->next = next;
ffffffffc02049c6:	f218                	sd	a4,32(a2)
    elm->prev = prev;
ffffffffc02049c8:	01163c23          	sd	a7,24(a2)
        nr_free -= n;
ffffffffc02049cc:	41c8083b          	subw	a6,a6,t3
ffffffffc02049d0:	000a8717          	auipc	a4,0xa8
ffffffffc02049d4:	ff072823          	sw	a6,-16(a4) # ffffffffc02ac9c0 <free_area+0x10>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02049d8:	5775                	li	a4,-3
ffffffffc02049da:	17c1                	addi	a5,a5,-16
ffffffffc02049dc:	60e7b02f          	amoand.d	zero,a4,(a5)
ffffffffc02049e0:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc02049e2:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc02049e4:	00004697          	auipc	a3,0x4
ffffffffc02049e8:	92468693          	addi	a3,a3,-1756 # ffffffffc0208308 <commands+0x1ba8>
ffffffffc02049ec:	00002617          	auipc	a2,0x2
ffffffffc02049f0:	1f460613          	addi	a2,a2,500 # ffffffffc0206be0 <commands+0x480>
ffffffffc02049f4:	06200593          	li	a1,98
ffffffffc02049f8:	00003517          	auipc	a0,0x3
ffffffffc02049fc:	5d850513          	addi	a0,a0,1496 # ffffffffc0207fd0 <commands+0x1870>
default_alloc_pages(size_t n) {
ffffffffc0204a00:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0204a02:	813fb0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0204a06 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc0204a06:	1141                	addi	sp,sp,-16
ffffffffc0204a08:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0204a0a:	c1ed                	beqz	a1,ffffffffc0204aec <default_init_memmap+0xe6>
    for (; p != base + n; p ++) {
ffffffffc0204a0c:	00659693          	slli	a3,a1,0x6
ffffffffc0204a10:	96aa                	add	a3,a3,a0
ffffffffc0204a12:	02d50463          	beq	a0,a3,ffffffffc0204a3a <default_init_memmap+0x34>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0204a16:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc0204a18:	87aa                	mv	a5,a0
ffffffffc0204a1a:	8b05                	andi	a4,a4,1
ffffffffc0204a1c:	e709                	bnez	a4,ffffffffc0204a26 <default_init_memmap+0x20>
ffffffffc0204a1e:	a07d                	j	ffffffffc0204acc <default_init_memmap+0xc6>
ffffffffc0204a20:	6798                	ld	a4,8(a5)
ffffffffc0204a22:	8b05                	andi	a4,a4,1
ffffffffc0204a24:	c745                	beqz	a4,ffffffffc0204acc <default_init_memmap+0xc6>
        p->flags = p->property = 0;
ffffffffc0204a26:	0007a823          	sw	zero,16(a5)
ffffffffc0204a2a:	0007b423          	sd	zero,8(a5)
ffffffffc0204a2e:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0204a32:	04078793          	addi	a5,a5,64
ffffffffc0204a36:	fed795e3          	bne	a5,a3,ffffffffc0204a20 <default_init_memmap+0x1a>
    base->property = n;
ffffffffc0204a3a:	2581                	sext.w	a1,a1
ffffffffc0204a3c:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0204a3e:	4789                	li	a5,2
ffffffffc0204a40:	00850713          	addi	a4,a0,8
ffffffffc0204a44:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0204a48:	000a8697          	auipc	a3,0xa8
ffffffffc0204a4c:	f6868693          	addi	a3,a3,-152 # ffffffffc02ac9b0 <free_area>
ffffffffc0204a50:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0204a52:	669c                	ld	a5,8(a3)
ffffffffc0204a54:	9db9                	addw	a1,a1,a4
ffffffffc0204a56:	000a8717          	auipc	a4,0xa8
ffffffffc0204a5a:	f6b72523          	sw	a1,-150(a4) # ffffffffc02ac9c0 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc0204a5e:	04d78a63          	beq	a5,a3,ffffffffc0204ab2 <default_init_memmap+0xac>
            struct Page* page = le2page(le, page_link);
ffffffffc0204a62:	fe878713          	addi	a4,a5,-24
ffffffffc0204a66:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0204a68:	4801                	li	a6,0
ffffffffc0204a6a:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc0204a6e:	00e56a63          	bltu	a0,a4,ffffffffc0204a82 <default_init_memmap+0x7c>
    return listelm->next;
ffffffffc0204a72:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0204a74:	02d70563          	beq	a4,a3,ffffffffc0204a9e <default_init_memmap+0x98>
        while ((le = list_next(le)) != &free_list) {
ffffffffc0204a78:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0204a7a:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0204a7e:	fee57ae3          	bgeu	a0,a4,ffffffffc0204a72 <default_init_memmap+0x6c>
ffffffffc0204a82:	00080663          	beqz	a6,ffffffffc0204a8e <default_init_memmap+0x88>
ffffffffc0204a86:	000a8717          	auipc	a4,0xa8
ffffffffc0204a8a:	f2b73523          	sd	a1,-214(a4) # ffffffffc02ac9b0 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0204a8e:	6398                	ld	a4,0(a5)
}
ffffffffc0204a90:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0204a92:	e390                	sd	a2,0(a5)
ffffffffc0204a94:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0204a96:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0204a98:	ed18                	sd	a4,24(a0)
ffffffffc0204a9a:	0141                	addi	sp,sp,16
ffffffffc0204a9c:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0204a9e:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0204aa0:	f114                	sd	a3,32(a0)
ffffffffc0204aa2:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0204aa4:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc0204aa6:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0204aa8:	00d70e63          	beq	a4,a3,ffffffffc0204ac4 <default_init_memmap+0xbe>
ffffffffc0204aac:	4805                	li	a6,1
ffffffffc0204aae:	87ba                	mv	a5,a4
ffffffffc0204ab0:	b7e9                	j	ffffffffc0204a7a <default_init_memmap+0x74>
}
ffffffffc0204ab2:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0204ab4:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc0204ab8:	e398                	sd	a4,0(a5)
ffffffffc0204aba:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0204abc:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0204abe:	ed1c                	sd	a5,24(a0)
}
ffffffffc0204ac0:	0141                	addi	sp,sp,16
ffffffffc0204ac2:	8082                	ret
ffffffffc0204ac4:	60a2                	ld	ra,8(sp)
ffffffffc0204ac6:	e290                	sd	a2,0(a3)
ffffffffc0204ac8:	0141                	addi	sp,sp,16
ffffffffc0204aca:	8082                	ret
        assert(PageReserved(p));
ffffffffc0204acc:	00004697          	auipc	a3,0x4
ffffffffc0204ad0:	84468693          	addi	a3,a3,-1980 # ffffffffc0208310 <commands+0x1bb0>
ffffffffc0204ad4:	00002617          	auipc	a2,0x2
ffffffffc0204ad8:	10c60613          	addi	a2,a2,268 # ffffffffc0206be0 <commands+0x480>
ffffffffc0204adc:	04900593          	li	a1,73
ffffffffc0204ae0:	00003517          	auipc	a0,0x3
ffffffffc0204ae4:	4f050513          	addi	a0,a0,1264 # ffffffffc0207fd0 <commands+0x1870>
ffffffffc0204ae8:	f2cfb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(n > 0);
ffffffffc0204aec:	00004697          	auipc	a3,0x4
ffffffffc0204af0:	81c68693          	addi	a3,a3,-2020 # ffffffffc0208308 <commands+0x1ba8>
ffffffffc0204af4:	00002617          	auipc	a2,0x2
ffffffffc0204af8:	0ec60613          	addi	a2,a2,236 # ffffffffc0206be0 <commands+0x480>
ffffffffc0204afc:	04600593          	li	a1,70
ffffffffc0204b00:	00003517          	auipc	a0,0x3
ffffffffc0204b04:	4d050513          	addi	a0,a0,1232 # ffffffffc0207fd0 <commands+0x1870>
ffffffffc0204b08:	f0cfb0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0204b0c <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0204b0c:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204b0e:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0204b10:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204b12:	a1ffb0ef          	jal	ra,ffffffffc0200530 <ide_device_valid>
ffffffffc0204b16:	cd01                	beqz	a0,ffffffffc0204b2e <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204b18:	4505                	li	a0,1
ffffffffc0204b1a:	a1dfb0ef          	jal	ra,ffffffffc0200536 <ide_device_size>
}
ffffffffc0204b1e:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204b20:	810d                	srli	a0,a0,0x3
ffffffffc0204b22:	000a8797          	auipc	a5,0xa8
ffffffffc0204b26:	e2a7bf23          	sd	a0,-450(a5) # ffffffffc02ac960 <max_swap_offset>
}
ffffffffc0204b2a:	0141                	addi	sp,sp,16
ffffffffc0204b2c:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0204b2e:	00004617          	auipc	a2,0x4
ffffffffc0204b32:	84260613          	addi	a2,a2,-1982 # ffffffffc0208370 <default_pmm_manager+0x50>
ffffffffc0204b36:	45b5                	li	a1,13
ffffffffc0204b38:	00004517          	auipc	a0,0x4
ffffffffc0204b3c:	85850513          	addi	a0,a0,-1960 # ffffffffc0208390 <default_pmm_manager+0x70>
ffffffffc0204b40:	ed4fb0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0204b44 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0204b44:	1141                	addi	sp,sp,-16
ffffffffc0204b46:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204b48:	00855793          	srli	a5,a0,0x8
ffffffffc0204b4c:	cfb9                	beqz	a5,ffffffffc0204baa <swapfs_read+0x66>
ffffffffc0204b4e:	000a8717          	auipc	a4,0xa8
ffffffffc0204b52:	e1270713          	addi	a4,a4,-494 # ffffffffc02ac960 <max_swap_offset>
ffffffffc0204b56:	6318                	ld	a4,0(a4)
ffffffffc0204b58:	04e7f963          	bgeu	a5,a4,ffffffffc0204baa <swapfs_read+0x66>
    return page - pages + nbase;
ffffffffc0204b5c:	000a8717          	auipc	a4,0xa8
ffffffffc0204b60:	d6c70713          	addi	a4,a4,-660 # ffffffffc02ac8c8 <pages>
ffffffffc0204b64:	6310                	ld	a2,0(a4)
ffffffffc0204b66:	00004717          	auipc	a4,0x4
ffffffffc0204b6a:	18270713          	addi	a4,a4,386 # ffffffffc0208ce8 <nbase>
ffffffffc0204b6e:	40c58633          	sub	a2,a1,a2
ffffffffc0204b72:	630c                	ld	a1,0(a4)
ffffffffc0204b74:	8619                	srai	a2,a2,0x6
    return KADDR(page2pa(page));
ffffffffc0204b76:	000a8717          	auipc	a4,0xa8
ffffffffc0204b7a:	cea70713          	addi	a4,a4,-790 # ffffffffc02ac860 <npage>
    return page - pages + nbase;
ffffffffc0204b7e:	962e                	add	a2,a2,a1
    return KADDR(page2pa(page));
ffffffffc0204b80:	6314                	ld	a3,0(a4)
ffffffffc0204b82:	00c61713          	slli	a4,a2,0xc
ffffffffc0204b86:	8331                	srli	a4,a4,0xc
ffffffffc0204b88:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204b8c:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204b8e:	02d77a63          	bgeu	a4,a3,ffffffffc0204bc2 <swapfs_read+0x7e>
ffffffffc0204b92:	000a8797          	auipc	a5,0xa8
ffffffffc0204b96:	d2678793          	addi	a5,a5,-730 # ffffffffc02ac8b8 <va_pa_offset>
ffffffffc0204b9a:	639c                	ld	a5,0(a5)
}
ffffffffc0204b9c:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204b9e:	46a1                	li	a3,8
ffffffffc0204ba0:	963e                	add	a2,a2,a5
ffffffffc0204ba2:	4505                	li	a0,1
}
ffffffffc0204ba4:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204ba6:	997fb06f          	j	ffffffffc020053c <ide_read_secs>
ffffffffc0204baa:	86aa                	mv	a3,a0
ffffffffc0204bac:	00003617          	auipc	a2,0x3
ffffffffc0204bb0:	7fc60613          	addi	a2,a2,2044 # ffffffffc02083a8 <default_pmm_manager+0x88>
ffffffffc0204bb4:	45d1                	li	a1,20
ffffffffc0204bb6:	00003517          	auipc	a0,0x3
ffffffffc0204bba:	7da50513          	addi	a0,a0,2010 # ffffffffc0208390 <default_pmm_manager+0x70>
ffffffffc0204bbe:	e56fb0ef          	jal	ra,ffffffffc0200214 <__panic>
ffffffffc0204bc2:	86b2                	mv	a3,a2
ffffffffc0204bc4:	06900593          	li	a1,105
ffffffffc0204bc8:	00002617          	auipc	a2,0x2
ffffffffc0204bcc:	40060613          	addi	a2,a2,1024 # ffffffffc0206fc8 <commands+0x868>
ffffffffc0204bd0:	00002517          	auipc	a0,0x2
ffffffffc0204bd4:	45050513          	addi	a0,a0,1104 # ffffffffc0207020 <commands+0x8c0>
ffffffffc0204bd8:	e3cfb0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0204bdc <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0204bdc:	1141                	addi	sp,sp,-16
ffffffffc0204bde:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204be0:	00855793          	srli	a5,a0,0x8
ffffffffc0204be4:	cfb9                	beqz	a5,ffffffffc0204c42 <swapfs_write+0x66>
ffffffffc0204be6:	000a8717          	auipc	a4,0xa8
ffffffffc0204bea:	d7a70713          	addi	a4,a4,-646 # ffffffffc02ac960 <max_swap_offset>
ffffffffc0204bee:	6318                	ld	a4,0(a4)
ffffffffc0204bf0:	04e7f963          	bgeu	a5,a4,ffffffffc0204c42 <swapfs_write+0x66>
    return page - pages + nbase;
ffffffffc0204bf4:	000a8717          	auipc	a4,0xa8
ffffffffc0204bf8:	cd470713          	addi	a4,a4,-812 # ffffffffc02ac8c8 <pages>
ffffffffc0204bfc:	6310                	ld	a2,0(a4)
ffffffffc0204bfe:	00004717          	auipc	a4,0x4
ffffffffc0204c02:	0ea70713          	addi	a4,a4,234 # ffffffffc0208ce8 <nbase>
ffffffffc0204c06:	40c58633          	sub	a2,a1,a2
ffffffffc0204c0a:	630c                	ld	a1,0(a4)
ffffffffc0204c0c:	8619                	srai	a2,a2,0x6
    return KADDR(page2pa(page));
ffffffffc0204c0e:	000a8717          	auipc	a4,0xa8
ffffffffc0204c12:	c5270713          	addi	a4,a4,-942 # ffffffffc02ac860 <npage>
    return page - pages + nbase;
ffffffffc0204c16:	962e                	add	a2,a2,a1
    return KADDR(page2pa(page));
ffffffffc0204c18:	6314                	ld	a3,0(a4)
ffffffffc0204c1a:	00c61713          	slli	a4,a2,0xc
ffffffffc0204c1e:	8331                	srli	a4,a4,0xc
ffffffffc0204c20:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204c24:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204c26:	02d77a63          	bgeu	a4,a3,ffffffffc0204c5a <swapfs_write+0x7e>
ffffffffc0204c2a:	000a8797          	auipc	a5,0xa8
ffffffffc0204c2e:	c8e78793          	addi	a5,a5,-882 # ffffffffc02ac8b8 <va_pa_offset>
ffffffffc0204c32:	639c                	ld	a5,0(a5)
}
ffffffffc0204c34:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204c36:	46a1                	li	a3,8
ffffffffc0204c38:	963e                	add	a2,a2,a5
ffffffffc0204c3a:	4505                	li	a0,1
}
ffffffffc0204c3c:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204c3e:	923fb06f          	j	ffffffffc0200560 <ide_write_secs>
ffffffffc0204c42:	86aa                	mv	a3,a0
ffffffffc0204c44:	00003617          	auipc	a2,0x3
ffffffffc0204c48:	76460613          	addi	a2,a2,1892 # ffffffffc02083a8 <default_pmm_manager+0x88>
ffffffffc0204c4c:	45e5                	li	a1,25
ffffffffc0204c4e:	00003517          	auipc	a0,0x3
ffffffffc0204c52:	74250513          	addi	a0,a0,1858 # ffffffffc0208390 <default_pmm_manager+0x70>
ffffffffc0204c56:	dbefb0ef          	jal	ra,ffffffffc0200214 <__panic>
ffffffffc0204c5a:	86b2                	mv	a3,a2
ffffffffc0204c5c:	06900593          	li	a1,105
ffffffffc0204c60:	00002617          	auipc	a2,0x2
ffffffffc0204c64:	36860613          	addi	a2,a2,872 # ffffffffc0206fc8 <commands+0x868>
ffffffffc0204c68:	00002517          	auipc	a0,0x2
ffffffffc0204c6c:	3b850513          	addi	a0,a0,952 # ffffffffc0207020 <commands+0x8c0>
ffffffffc0204c70:	da4fb0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0204c74 <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc0204c74:	8526                	mv	a0,s1
	jalr s0
ffffffffc0204c76:	9402                	jalr	s0

	jal do_exit
ffffffffc0204c78:	79c000ef          	jal	ra,ffffffffc0205414 <do_exit>

ffffffffc0204c7c <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc0204c7c:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc0204c80:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc0204c84:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc0204c86:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc0204c88:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc0204c8c:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc0204c90:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc0204c94:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc0204c98:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc0204c9c:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc0204ca0:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc0204ca4:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc0204ca8:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc0204cac:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc0204cb0:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc0204cb4:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc0204cb8:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc0204cba:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc0204cbc:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc0204cc0:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc0204cc4:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc0204cc8:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc0204ccc:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc0204cd0:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc0204cd4:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc0204cd8:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc0204cdc:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc0204ce0:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc0204ce4:	8082                	ret

ffffffffc0204ce6 <alloc_proc>:
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
ffffffffc0204ce6:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204ce8:	10800513          	li	a0,264
alloc_proc(void) {
ffffffffc0204cec:	e022                	sd	s0,0(sp)
ffffffffc0204cee:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204cf0:	d07fe0ef          	jal	ra,ffffffffc02039f6 <kmalloc>
ffffffffc0204cf4:	842a                	mv	s0,a0
    if (proc != NULL) {
ffffffffc0204cf6:	cd29                	beqz	a0,ffffffffc0204d50 <alloc_proc+0x6a>
     *       struct trapframe *tf;                       // Trap frame for current interrupt
     *       uintptr_t cr3;                              // CR3 register: the base addr of Page Directroy Table(PDT)
     *       uint32_t flags;                             // Process flag
     *       char name[PROC_NAME_LEN + 1];               // Process name
     */
    proc->state = PROC_UNINIT;
ffffffffc0204cf8:	57fd                	li	a5,-1
ffffffffc0204cfa:	1782                	slli	a5,a5,0x20
ffffffffc0204cfc:	e11c                	sd	a5,0(a0)
    proc->runs = 0;
    proc->kstack = 0;
    proc->need_resched = 0;
    proc->parent = NULL;
    proc->mm = NULL;
    memset(&(proc->context),0,sizeof(struct context));
ffffffffc0204cfe:	07000613          	li	a2,112
ffffffffc0204d02:	4581                	li	a1,0
    proc->runs = 0;
ffffffffc0204d04:	00052423          	sw	zero,8(a0)
    proc->kstack = 0;
ffffffffc0204d08:	00053823          	sd	zero,16(a0)
    proc->need_resched = 0;
ffffffffc0204d0c:	00053c23          	sd	zero,24(a0)
    proc->parent = NULL;
ffffffffc0204d10:	02053023          	sd	zero,32(a0)
    proc->mm = NULL;
ffffffffc0204d14:	02053423          	sd	zero,40(a0)
    memset(&(proc->context),0,sizeof(struct context));
ffffffffc0204d18:	03050513          	addi	a0,a0,48
ffffffffc0204d1c:	4a4010ef          	jal	ra,ffffffffc02061c0 <memset>
    proc->tf = NULL;
    proc->cr3 = boot_cr3;
ffffffffc0204d20:	000a8797          	auipc	a5,0xa8
ffffffffc0204d24:	ba078793          	addi	a5,a5,-1120 # ffffffffc02ac8c0 <boot_cr3>
ffffffffc0204d28:	639c                	ld	a5,0(a5)
    proc->tf = NULL;
ffffffffc0204d2a:	0a043023          	sd	zero,160(s0)
    proc->flags = 0;
ffffffffc0204d2e:	0a042823          	sw	zero,176(s0)
    proc->cr3 = boot_cr3;
ffffffffc0204d32:	f45c                	sd	a5,168(s0)
    memset(&(proc->name),0,PROC_NAME_LEN);
ffffffffc0204d34:	463d                	li	a2,15
ffffffffc0204d36:	4581                	li	a1,0
ffffffffc0204d38:	0b440513          	addi	a0,s0,180
ffffffffc0204d3c:	484010ef          	jal	ra,ffffffffc02061c0 <memset>
     /*
     * below fields(add in LAB5) in proc_struct need to be initialized  
     *       uint32_t wait_state;                        // waiting state
     *       struct proc_struct *cptr, *yptr, *optr;     // relations between processes
     */
    proc->wait_state = 0;                                
ffffffffc0204d40:	0e042623          	sw	zero,236(s0)
    proc->cptr = proc->optr = proc->yptr = NULL;         
ffffffffc0204d44:	0e043c23          	sd	zero,248(s0)
ffffffffc0204d48:	10043023          	sd	zero,256(s0)
ffffffffc0204d4c:	0e043823          	sd	zero,240(s0)

    }
    return proc;
}
ffffffffc0204d50:	8522                	mv	a0,s0
ffffffffc0204d52:	60a2                	ld	ra,8(sp)
ffffffffc0204d54:	6402                	ld	s0,0(sp)
ffffffffc0204d56:	0141                	addi	sp,sp,16
ffffffffc0204d58:	8082                	ret

ffffffffc0204d5a <forkret>:
// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
    forkrets(current->tf);
ffffffffc0204d5a:	000a8797          	auipc	a5,0xa8
ffffffffc0204d5e:	b2e78793          	addi	a5,a5,-1234 # ffffffffc02ac888 <current>
ffffffffc0204d62:	639c                	ld	a5,0(a5)
ffffffffc0204d64:	73c8                	ld	a0,160(a5)
ffffffffc0204d66:	82cfc06f          	j	ffffffffc0200d92 <forkrets>

ffffffffc0204d6a <user_main>:

// user_main - kernel thread used to exec a user program
static int
user_main(void *arg) {
#ifdef TEST
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204d6a:	000a8797          	auipc	a5,0xa8
ffffffffc0204d6e:	b1e78793          	addi	a5,a5,-1250 # ffffffffc02ac888 <current>
ffffffffc0204d72:	639c                	ld	a5,0(a5)
user_main(void *arg) {
ffffffffc0204d74:	7139                	addi	sp,sp,-64
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204d76:	00004617          	auipc	a2,0x4
ffffffffc0204d7a:	a4260613          	addi	a2,a2,-1470 # ffffffffc02087b8 <default_pmm_manager+0x498>
ffffffffc0204d7e:	43cc                	lw	a1,4(a5)
ffffffffc0204d80:	00004517          	auipc	a0,0x4
ffffffffc0204d84:	a4850513          	addi	a0,a0,-1464 # ffffffffc02087c8 <default_pmm_manager+0x4a8>
user_main(void *arg) {
ffffffffc0204d88:	fc06                	sd	ra,56(sp)
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204d8a:	b46fb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc0204d8e:	00004797          	auipc	a5,0x4
ffffffffc0204d92:	a2a78793          	addi	a5,a5,-1494 # ffffffffc02087b8 <default_pmm_manager+0x498>
ffffffffc0204d96:	3fe05717          	auipc	a4,0x3fe05
ffffffffc0204d9a:	58270713          	addi	a4,a4,1410 # a318 <_binary_obj___user_forktest_out_size>
ffffffffc0204d9e:	e43a                	sd	a4,8(sp)
    int64_t ret=0, len = strlen(name);
ffffffffc0204da0:	853e                	mv	a0,a5
ffffffffc0204da2:	00092717          	auipc	a4,0x92
ffffffffc0204da6:	32e70713          	addi	a4,a4,814 # ffffffffc02970d0 <_binary_obj___user_forktest_out_start>
ffffffffc0204daa:	f03a                	sd	a4,32(sp)
ffffffffc0204dac:	f43e                	sd	a5,40(sp)
ffffffffc0204dae:	e802                	sd	zero,16(sp)
ffffffffc0204db0:	372010ef          	jal	ra,ffffffffc0206122 <strlen>
ffffffffc0204db4:	ec2a                	sd	a0,24(sp)
    asm volatile(
ffffffffc0204db6:	4511                	li	a0,4
ffffffffc0204db8:	55a2                	lw	a1,40(sp)
ffffffffc0204dba:	4662                	lw	a2,24(sp)
ffffffffc0204dbc:	5682                	lw	a3,32(sp)
ffffffffc0204dbe:	4722                	lw	a4,8(sp)
ffffffffc0204dc0:	48a9                	li	a7,10
ffffffffc0204dc2:	9002                	ebreak
ffffffffc0204dc4:	c82a                	sw	a0,16(sp)
    cprintf("ret = %d\n", ret);
ffffffffc0204dc6:	65c2                	ld	a1,16(sp)
ffffffffc0204dc8:	00004517          	auipc	a0,0x4
ffffffffc0204dcc:	a2850513          	addi	a0,a0,-1496 # ffffffffc02087f0 <default_pmm_manager+0x4d0>
ffffffffc0204dd0:	b00fb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
#else
    KERNEL_EXECVE(exit);
#endif
    panic("user_main execve failed.\n");
ffffffffc0204dd4:	00004617          	auipc	a2,0x4
ffffffffc0204dd8:	a2c60613          	addi	a2,a2,-1492 # ffffffffc0208800 <default_pmm_manager+0x4e0>
ffffffffc0204ddc:	35400593          	li	a1,852
ffffffffc0204de0:	00004517          	auipc	a0,0x4
ffffffffc0204de4:	a4050513          	addi	a0,a0,-1472 # ffffffffc0208820 <default_pmm_manager+0x500>
ffffffffc0204de8:	c2cfb0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0204dec <put_pgdir>:
    return pa2page(PADDR(kva));
ffffffffc0204dec:	6d14                	ld	a3,24(a0)
put_pgdir(struct mm_struct *mm) {
ffffffffc0204dee:	1141                	addi	sp,sp,-16
ffffffffc0204df0:	e406                	sd	ra,8(sp)
ffffffffc0204df2:	c02007b7          	lui	a5,0xc0200
ffffffffc0204df6:	04f6e263          	bltu	a3,a5,ffffffffc0204e3a <put_pgdir+0x4e>
ffffffffc0204dfa:	000a8797          	auipc	a5,0xa8
ffffffffc0204dfe:	abe78793          	addi	a5,a5,-1346 # ffffffffc02ac8b8 <va_pa_offset>
ffffffffc0204e02:	6388                	ld	a0,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0204e04:	000a8797          	auipc	a5,0xa8
ffffffffc0204e08:	a5c78793          	addi	a5,a5,-1444 # ffffffffc02ac860 <npage>
ffffffffc0204e0c:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc0204e0e:	8e89                	sub	a3,a3,a0
    if (PPN(pa) >= npage) {
ffffffffc0204e10:	82b1                	srli	a3,a3,0xc
ffffffffc0204e12:	04f6f063          	bgeu	a3,a5,ffffffffc0204e52 <put_pgdir+0x66>
    return &pages[PPN(pa) - nbase];
ffffffffc0204e16:	00004797          	auipc	a5,0x4
ffffffffc0204e1a:	ed278793          	addi	a5,a5,-302 # ffffffffc0208ce8 <nbase>
ffffffffc0204e1e:	639c                	ld	a5,0(a5)
ffffffffc0204e20:	000a8717          	auipc	a4,0xa8
ffffffffc0204e24:	aa870713          	addi	a4,a4,-1368 # ffffffffc02ac8c8 <pages>
ffffffffc0204e28:	6308                	ld	a0,0(a4)
}
ffffffffc0204e2a:	60a2                	ld	ra,8(sp)
ffffffffc0204e2c:	8e9d                	sub	a3,a3,a5
ffffffffc0204e2e:	069a                	slli	a3,a3,0x6
    free_page(kva2page(mm->pgdir));
ffffffffc0204e30:	4585                	li	a1,1
ffffffffc0204e32:	9536                	add	a0,a0,a3
}
ffffffffc0204e34:	0141                	addi	sp,sp,16
    free_page(kva2page(mm->pgdir));
ffffffffc0204e36:	8acfc06f          	j	ffffffffc0200ee2 <free_pages>
    return pa2page(PADDR(kva));
ffffffffc0204e3a:	00002617          	auipc	a2,0x2
ffffffffc0204e3e:	26660613          	addi	a2,a2,614 # ffffffffc02070a0 <commands+0x940>
ffffffffc0204e42:	06e00593          	li	a1,110
ffffffffc0204e46:	00002517          	auipc	a0,0x2
ffffffffc0204e4a:	1da50513          	addi	a0,a0,474 # ffffffffc0207020 <commands+0x8c0>
ffffffffc0204e4e:	bc6fb0ef          	jal	ra,ffffffffc0200214 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0204e52:	00002617          	auipc	a2,0x2
ffffffffc0204e56:	1ae60613          	addi	a2,a2,430 # ffffffffc0207000 <commands+0x8a0>
ffffffffc0204e5a:	06200593          	li	a1,98
ffffffffc0204e5e:	00002517          	auipc	a0,0x2
ffffffffc0204e62:	1c250513          	addi	a0,a0,450 # ffffffffc0207020 <commands+0x8c0>
ffffffffc0204e66:	baefb0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0204e6a <setup_pgdir>:
setup_pgdir(struct mm_struct *mm) {
ffffffffc0204e6a:	1101                	addi	sp,sp,-32
ffffffffc0204e6c:	e426                	sd	s1,8(sp)
ffffffffc0204e6e:	84aa                	mv	s1,a0
    if ((page = alloc_page()) == NULL) {
ffffffffc0204e70:	4505                	li	a0,1
setup_pgdir(struct mm_struct *mm) {
ffffffffc0204e72:	ec06                	sd	ra,24(sp)
ffffffffc0204e74:	e822                	sd	s0,16(sp)
    if ((page = alloc_page()) == NULL) {
ffffffffc0204e76:	fe5fb0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
ffffffffc0204e7a:	c125                	beqz	a0,ffffffffc0204eda <setup_pgdir+0x70>
    return page - pages + nbase;
ffffffffc0204e7c:	000a8797          	auipc	a5,0xa8
ffffffffc0204e80:	a4c78793          	addi	a5,a5,-1460 # ffffffffc02ac8c8 <pages>
ffffffffc0204e84:	6394                	ld	a3,0(a5)
ffffffffc0204e86:	00004797          	auipc	a5,0x4
ffffffffc0204e8a:	e6278793          	addi	a5,a5,-414 # ffffffffc0208ce8 <nbase>
ffffffffc0204e8e:	6380                	ld	s0,0(a5)
ffffffffc0204e90:	40d506b3          	sub	a3,a0,a3
    return KADDR(page2pa(page));
ffffffffc0204e94:	000a8797          	auipc	a5,0xa8
ffffffffc0204e98:	9cc78793          	addi	a5,a5,-1588 # ffffffffc02ac860 <npage>
    return page - pages + nbase;
ffffffffc0204e9c:	8699                	srai	a3,a3,0x6
ffffffffc0204e9e:	96a2                	add	a3,a3,s0
    return KADDR(page2pa(page));
ffffffffc0204ea0:	6398                	ld	a4,0(a5)
ffffffffc0204ea2:	00c69793          	slli	a5,a3,0xc
ffffffffc0204ea6:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0204ea8:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204eaa:	02e7fa63          	bgeu	a5,a4,ffffffffc0204ede <setup_pgdir+0x74>
ffffffffc0204eae:	000a8797          	auipc	a5,0xa8
ffffffffc0204eb2:	a0a78793          	addi	a5,a5,-1526 # ffffffffc02ac8b8 <va_pa_offset>
ffffffffc0204eb6:	6380                	ld	s0,0(a5)
    memcpy(pgdir, boot_pgdir, PGSIZE);
ffffffffc0204eb8:	000a8797          	auipc	a5,0xa8
ffffffffc0204ebc:	9a078793          	addi	a5,a5,-1632 # ffffffffc02ac858 <boot_pgdir>
ffffffffc0204ec0:	638c                	ld	a1,0(a5)
ffffffffc0204ec2:	9436                	add	s0,s0,a3
ffffffffc0204ec4:	6605                	lui	a2,0x1
ffffffffc0204ec6:	8522                	mv	a0,s0
ffffffffc0204ec8:	30a010ef          	jal	ra,ffffffffc02061d2 <memcpy>
    return 0;
ffffffffc0204ecc:	4501                	li	a0,0
    mm->pgdir = pgdir;
ffffffffc0204ece:	ec80                	sd	s0,24(s1)
}
ffffffffc0204ed0:	60e2                	ld	ra,24(sp)
ffffffffc0204ed2:	6442                	ld	s0,16(sp)
ffffffffc0204ed4:	64a2                	ld	s1,8(sp)
ffffffffc0204ed6:	6105                	addi	sp,sp,32
ffffffffc0204ed8:	8082                	ret
        return -E_NO_MEM;
ffffffffc0204eda:	5571                	li	a0,-4
ffffffffc0204edc:	bfd5                	j	ffffffffc0204ed0 <setup_pgdir+0x66>
ffffffffc0204ede:	00002617          	auipc	a2,0x2
ffffffffc0204ee2:	0ea60613          	addi	a2,a2,234 # ffffffffc0206fc8 <commands+0x868>
ffffffffc0204ee6:	06900593          	li	a1,105
ffffffffc0204eea:	00002517          	auipc	a0,0x2
ffffffffc0204eee:	13650513          	addi	a0,a0,310 # ffffffffc0207020 <commands+0x8c0>
ffffffffc0204ef2:	b22fb0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0204ef6 <set_proc_name>:
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204ef6:	1101                	addi	sp,sp,-32
ffffffffc0204ef8:	e822                	sd	s0,16(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204efa:	0b450413          	addi	s0,a0,180
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204efe:	e426                	sd	s1,8(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204f00:	4641                	li	a2,16
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204f02:	84ae                	mv	s1,a1
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204f04:	8522                	mv	a0,s0
ffffffffc0204f06:	4581                	li	a1,0
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204f08:	ec06                	sd	ra,24(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204f0a:	2b6010ef          	jal	ra,ffffffffc02061c0 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204f0e:	8522                	mv	a0,s0
}
ffffffffc0204f10:	6442                	ld	s0,16(sp)
ffffffffc0204f12:	60e2                	ld	ra,24(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204f14:	85a6                	mv	a1,s1
}
ffffffffc0204f16:	64a2                	ld	s1,8(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204f18:	463d                	li	a2,15
}
ffffffffc0204f1a:	6105                	addi	sp,sp,32
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204f1c:	2b60106f          	j	ffffffffc02061d2 <memcpy>

ffffffffc0204f20 <proc_run>:
proc_run(struct proc_struct *proc) {
ffffffffc0204f20:	1101                	addi	sp,sp,-32
    if (proc != current) {
ffffffffc0204f22:	000a8797          	auipc	a5,0xa8
ffffffffc0204f26:	96678793          	addi	a5,a5,-1690 # ffffffffc02ac888 <current>
proc_run(struct proc_struct *proc) {
ffffffffc0204f2a:	e426                	sd	s1,8(sp)
    if (proc != current) {
ffffffffc0204f2c:	6384                	ld	s1,0(a5)
proc_run(struct proc_struct *proc) {
ffffffffc0204f2e:	ec06                	sd	ra,24(sp)
ffffffffc0204f30:	e822                	sd	s0,16(sp)
ffffffffc0204f32:	e04a                	sd	s2,0(sp)
    if (proc != current) {
ffffffffc0204f34:	02a48b63          	beq	s1,a0,ffffffffc0204f6a <proc_run+0x4a>
ffffffffc0204f38:	842a                	mv	s0,a0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204f3a:	100027f3          	csrr	a5,sstatus
ffffffffc0204f3e:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204f40:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204f42:	e3a9                	bnez	a5,ffffffffc0204f84 <proc_run+0x64>

#define barrier() __asm__ __volatile__ ("fence" ::: "memory")

static inline void
lcr3(unsigned long cr3) {
    write_csr(satp, 0x8000000000000000 | (cr3 >> RISCV_PGSHIFT));
ffffffffc0204f44:	745c                	ld	a5,168(s0)
            current = proc;//前一个进程和后一个进程,就两个进程
ffffffffc0204f46:	000a8717          	auipc	a4,0xa8
ffffffffc0204f4a:	94873123          	sd	s0,-1726(a4) # ffffffffc02ac888 <current>
ffffffffc0204f4e:	577d                	li	a4,-1
ffffffffc0204f50:	177e                	slli	a4,a4,0x3f
ffffffffc0204f52:	83b1                	srli	a5,a5,0xc
ffffffffc0204f54:	8fd9                	or	a5,a5,a4
ffffffffc0204f56:	18079073          	csrw	satp,a5
            switch_to(&(prev->context), &(current->context));
ffffffffc0204f5a:	03040593          	addi	a1,s0,48
ffffffffc0204f5e:	03048513          	addi	a0,s1,48
ffffffffc0204f62:	d1bff0ef          	jal	ra,ffffffffc0204c7c <switch_to>
    if (flag) {
ffffffffc0204f66:	00091863          	bnez	s2,ffffffffc0204f76 <proc_run+0x56>
}
ffffffffc0204f6a:	60e2                	ld	ra,24(sp)
ffffffffc0204f6c:	6442                	ld	s0,16(sp)
ffffffffc0204f6e:	64a2                	ld	s1,8(sp)
ffffffffc0204f70:	6902                	ld	s2,0(sp)
ffffffffc0204f72:	6105                	addi	sp,sp,32
ffffffffc0204f74:	8082                	ret
ffffffffc0204f76:	6442                	ld	s0,16(sp)
ffffffffc0204f78:	60e2                	ld	ra,24(sp)
ffffffffc0204f7a:	64a2                	ld	s1,8(sp)
ffffffffc0204f7c:	6902                	ld	s2,0(sp)
ffffffffc0204f7e:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0204f80:	ecefb06f          	j	ffffffffc020064e <intr_enable>
        intr_disable();
ffffffffc0204f84:	ed0fb0ef          	jal	ra,ffffffffc0200654 <intr_disable>
        return 1;
ffffffffc0204f88:	4905                	li	s2,1
ffffffffc0204f8a:	bf6d                	j	ffffffffc0204f44 <proc_run+0x24>

ffffffffc0204f8c <find_proc>:
    if (0 < pid && pid < MAX_PID) {
ffffffffc0204f8c:	0005071b          	sext.w	a4,a0
ffffffffc0204f90:	6789                	lui	a5,0x2
ffffffffc0204f92:	fff7069b          	addiw	a3,a4,-1
ffffffffc0204f96:	17f9                	addi	a5,a5,-2
ffffffffc0204f98:	04d7e063          	bltu	a5,a3,ffffffffc0204fd8 <find_proc+0x4c>
find_proc(int pid) {
ffffffffc0204f9c:	1141                	addi	sp,sp,-16
ffffffffc0204f9e:	e022                	sd	s0,0(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204fa0:	45a9                	li	a1,10
ffffffffc0204fa2:	842a                	mv	s0,a0
ffffffffc0204fa4:	853a                	mv	a0,a4
find_proc(int pid) {
ffffffffc0204fa6:	e406                	sd	ra,8(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204fa8:	62e010ef          	jal	ra,ffffffffc02065d6 <hash32>
ffffffffc0204fac:	02051693          	slli	a3,a0,0x20
ffffffffc0204fb0:	82f1                	srli	a3,a3,0x1c
ffffffffc0204fb2:	000a4517          	auipc	a0,0xa4
ffffffffc0204fb6:	89650513          	addi	a0,a0,-1898 # ffffffffc02a8848 <hash_list>
ffffffffc0204fba:	96aa                	add	a3,a3,a0
ffffffffc0204fbc:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list) {
ffffffffc0204fbe:	a029                	j	ffffffffc0204fc8 <find_proc+0x3c>
            if (proc->pid == pid) {
ffffffffc0204fc0:	f2c7a703          	lw	a4,-212(a5) # 1f2c <_binary_obj___user_faultread_out_size-0x769c>
ffffffffc0204fc4:	00870c63          	beq	a4,s0,ffffffffc0204fdc <find_proc+0x50>
    return listelm->next;
ffffffffc0204fc8:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0204fca:	fef69be3          	bne	a3,a5,ffffffffc0204fc0 <find_proc+0x34>
}
ffffffffc0204fce:	60a2                	ld	ra,8(sp)
ffffffffc0204fd0:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc0204fd2:	4501                	li	a0,0
}
ffffffffc0204fd4:	0141                	addi	sp,sp,16
ffffffffc0204fd6:	8082                	ret
    return NULL;
ffffffffc0204fd8:	4501                	li	a0,0
}
ffffffffc0204fda:	8082                	ret
ffffffffc0204fdc:	60a2                	ld	ra,8(sp)
ffffffffc0204fde:	6402                	ld	s0,0(sp)
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0204fe0:	f2878513          	addi	a0,a5,-216
}
ffffffffc0204fe4:	0141                	addi	sp,sp,16
ffffffffc0204fe6:	8082                	ret

ffffffffc0204fe8 <do_fork>:
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc0204fe8:	7159                	addi	sp,sp,-112
ffffffffc0204fea:	e0d2                	sd	s4,64(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc0204fec:	000a8a17          	auipc	s4,0xa8
ffffffffc0204ff0:	8b4a0a13          	addi	s4,s4,-1868 # ffffffffc02ac8a0 <nr_process>
ffffffffc0204ff4:	000a2703          	lw	a4,0(s4)
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc0204ff8:	f486                	sd	ra,104(sp)
ffffffffc0204ffa:	f0a2                	sd	s0,96(sp)
ffffffffc0204ffc:	eca6                	sd	s1,88(sp)
ffffffffc0204ffe:	e8ca                	sd	s2,80(sp)
ffffffffc0205000:	e4ce                	sd	s3,72(sp)
ffffffffc0205002:	fc56                	sd	s5,56(sp)
ffffffffc0205004:	f85a                	sd	s6,48(sp)
ffffffffc0205006:	f45e                	sd	s7,40(sp)
ffffffffc0205008:	f062                	sd	s8,32(sp)
ffffffffc020500a:	ec66                	sd	s9,24(sp)
ffffffffc020500c:	e86a                	sd	s10,16(sp)
ffffffffc020500e:	e46e                	sd	s11,8(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc0205010:	6785                	lui	a5,0x1
ffffffffc0205012:	30f75a63          	bge	a4,a5,ffffffffc0205326 <do_fork+0x33e>
ffffffffc0205016:	89aa                	mv	s3,a0
ffffffffc0205018:	892e                	mv	s2,a1
ffffffffc020501a:	84b2                	mv	s1,a2
    if ((proc = alloc_proc()) == NULL) {
ffffffffc020501c:	ccbff0ef          	jal	ra,ffffffffc0204ce6 <alloc_proc>
ffffffffc0205020:	842a                	mv	s0,a0
ffffffffc0205022:	2e050463          	beqz	a0,ffffffffc020530a <do_fork+0x322>
    proc->parent = current;//将子进程的父节点设置为当前进程
ffffffffc0205026:	000a8c17          	auipc	s8,0xa8
ffffffffc020502a:	862c0c13          	addi	s8,s8,-1950 # ffffffffc02ac888 <current>
ffffffffc020502e:	000c3783          	ld	a5,0(s8)
    assert(current->wait_state == 0); //确保进程在等待
ffffffffc0205032:	0ec7a703          	lw	a4,236(a5) # 10ec <_binary_obj___user_faultread_out_size-0x84dc>
    proc->parent = current;//将子进程的父节点设置为当前进程
ffffffffc0205036:	f11c                	sd	a5,32(a0)
    assert(current->wait_state == 0); //确保进程在等待
ffffffffc0205038:	30071563          	bnez	a4,ffffffffc0205342 <do_fork+0x35a>
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc020503c:	4509                	li	a0,2
ffffffffc020503e:	e1dfb0ef          	jal	ra,ffffffffc0200e5a <alloc_pages>
    if (page != NULL) {
ffffffffc0205042:	2c050163          	beqz	a0,ffffffffc0205304 <do_fork+0x31c>
    return page - pages + nbase;
ffffffffc0205046:	000a8a97          	auipc	s5,0xa8
ffffffffc020504a:	882a8a93          	addi	s5,s5,-1918 # ffffffffc02ac8c8 <pages>
ffffffffc020504e:	000ab683          	ld	a3,0(s5)
ffffffffc0205052:	00004b17          	auipc	s6,0x4
ffffffffc0205056:	c96b0b13          	addi	s6,s6,-874 # ffffffffc0208ce8 <nbase>
ffffffffc020505a:	000b3783          	ld	a5,0(s6)
ffffffffc020505e:	40d506b3          	sub	a3,a0,a3
ffffffffc0205062:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0205064:	000a7b97          	auipc	s7,0xa7
ffffffffc0205068:	7fcb8b93          	addi	s7,s7,2044 # ffffffffc02ac860 <npage>
    return page - pages + nbase;
ffffffffc020506c:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc020506e:	000bb703          	ld	a4,0(s7)
ffffffffc0205072:	00c69793          	slli	a5,a3,0xc
ffffffffc0205076:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0205078:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020507a:	2ae7f863          	bgeu	a5,a4,ffffffffc020532a <do_fork+0x342>
ffffffffc020507e:	000a8c97          	auipc	s9,0xa8
ffffffffc0205082:	83ac8c93          	addi	s9,s9,-1990 # ffffffffc02ac8b8 <va_pa_offset>
    struct mm_struct *mm, *oldmm = current->mm;
ffffffffc0205086:	000c3703          	ld	a4,0(s8)
ffffffffc020508a:	000cb783          	ld	a5,0(s9)
ffffffffc020508e:	02873c03          	ld	s8,40(a4)
ffffffffc0205092:	96be                	add	a3,a3,a5
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc0205094:	e814                	sd	a3,16(s0)
    if (oldmm == NULL) {
ffffffffc0205096:	020c0863          	beqz	s8,ffffffffc02050c6 <do_fork+0xde>
    if (clone_flags & CLONE_VM) {
ffffffffc020509a:	1009f993          	andi	s3,s3,256
ffffffffc020509e:	1e098163          	beqz	s3,ffffffffc0205280 <do_fork+0x298>
}

static inline int
mm_count_inc(struct mm_struct *mm) {
    mm->mm_count += 1;
ffffffffc02050a2:	030c2703          	lw	a4,48(s8)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc02050a6:	018c3783          	ld	a5,24(s8)
ffffffffc02050aa:	c02006b7          	lui	a3,0xc0200
ffffffffc02050ae:	2705                	addiw	a4,a4,1
ffffffffc02050b0:	02ec2823          	sw	a4,48(s8)
    proc->mm = mm;
ffffffffc02050b4:	03843423          	sd	s8,40(s0)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc02050b8:	2ad7e563          	bltu	a5,a3,ffffffffc0205362 <do_fork+0x37a>
ffffffffc02050bc:	000cb703          	ld	a4,0(s9)
ffffffffc02050c0:	6814                	ld	a3,16(s0)
ffffffffc02050c2:	8f99                	sub	a5,a5,a4
ffffffffc02050c4:	f45c                	sd	a5,168(s0)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc02050c6:	6789                	lui	a5,0x2
ffffffffc02050c8:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x76e8>
ffffffffc02050cc:	96be                	add	a3,a3,a5
ffffffffc02050ce:	f054                	sd	a3,160(s0)
    *(proc->tf) = *tf;
ffffffffc02050d0:	87b6                	mv	a5,a3
ffffffffc02050d2:	12048813          	addi	a6,s1,288
ffffffffc02050d6:	6088                	ld	a0,0(s1)
ffffffffc02050d8:	648c                	ld	a1,8(s1)
ffffffffc02050da:	6890                	ld	a2,16(s1)
ffffffffc02050dc:	6c98                	ld	a4,24(s1)
ffffffffc02050de:	e388                	sd	a0,0(a5)
ffffffffc02050e0:	e78c                	sd	a1,8(a5)
ffffffffc02050e2:	eb90                	sd	a2,16(a5)
ffffffffc02050e4:	ef98                	sd	a4,24(a5)
ffffffffc02050e6:	02048493          	addi	s1,s1,32
ffffffffc02050ea:	02078793          	addi	a5,a5,32
ffffffffc02050ee:	ff0494e3          	bne	s1,a6,ffffffffc02050d6 <do_fork+0xee>
    proc->tf->gpr.a0 = 0;
ffffffffc02050f2:	0406b823          	sd	zero,80(a3) # ffffffffc0200050 <kern_init+0x1a>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc02050f6:	12090e63          	beqz	s2,ffffffffc0205232 <do_fork+0x24a>
ffffffffc02050fa:	0126b823          	sd	s2,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc02050fe:	00000797          	auipc	a5,0x0
ffffffffc0205102:	c5c78793          	addi	a5,a5,-932 # ffffffffc0204d5a <forkret>
ffffffffc0205106:	f81c                	sd	a5,48(s0)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc0205108:	fc14                	sd	a3,56(s0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020510a:	100027f3          	csrr	a5,sstatus
ffffffffc020510e:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205110:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205112:	12079f63          	bnez	a5,ffffffffc0205250 <do_fork+0x268>
    if (++ last_pid >= MAX_PID) {
ffffffffc0205116:	0009c797          	auipc	a5,0x9c
ffffffffc020511a:	32a78793          	addi	a5,a5,810 # ffffffffc02a1440 <last_pid.1691>
ffffffffc020511e:	439c                	lw	a5,0(a5)
ffffffffc0205120:	6709                	lui	a4,0x2
ffffffffc0205122:	0017851b          	addiw	a0,a5,1
ffffffffc0205126:	0009c697          	auipc	a3,0x9c
ffffffffc020512a:	30a6ad23          	sw	a0,794(a3) # ffffffffc02a1440 <last_pid.1691>
ffffffffc020512e:	14e55263          	bge	a0,a4,ffffffffc0205272 <do_fork+0x28a>
    if (last_pid >= next_safe) {
ffffffffc0205132:	0009c797          	auipc	a5,0x9c
ffffffffc0205136:	31278793          	addi	a5,a5,786 # ffffffffc02a1444 <next_safe.1690>
ffffffffc020513a:	439c                	lw	a5,0(a5)
ffffffffc020513c:	000a8497          	auipc	s1,0xa8
ffffffffc0205140:	88c48493          	addi	s1,s1,-1908 # ffffffffc02ac9c8 <proc_list>
ffffffffc0205144:	06f54063          	blt	a0,a5,ffffffffc02051a4 <do_fork+0x1bc>
        next_safe = MAX_PID;
ffffffffc0205148:	6789                	lui	a5,0x2
ffffffffc020514a:	0009c717          	auipc	a4,0x9c
ffffffffc020514e:	2ef72d23          	sw	a5,762(a4) # ffffffffc02a1444 <next_safe.1690>
ffffffffc0205152:	4581                	li	a1,0
ffffffffc0205154:	87aa                	mv	a5,a0
ffffffffc0205156:	000a8497          	auipc	s1,0xa8
ffffffffc020515a:	87248493          	addi	s1,s1,-1934 # ffffffffc02ac9c8 <proc_list>
    repeat:
ffffffffc020515e:	6889                	lui	a7,0x2
ffffffffc0205160:	882e                	mv	a6,a1
ffffffffc0205162:	6609                	lui	a2,0x2
        le = list;
ffffffffc0205164:	000a8697          	auipc	a3,0xa8
ffffffffc0205168:	86468693          	addi	a3,a3,-1948 # ffffffffc02ac9c8 <proc_list>
ffffffffc020516c:	6694                	ld	a3,8(a3)
        while ((le = list_next(le)) != list) {
ffffffffc020516e:	00968f63          	beq	a3,s1,ffffffffc020518c <do_fork+0x1a4>
            if (proc->pid == last_pid) {
ffffffffc0205172:	f3c6a703          	lw	a4,-196(a3)
ffffffffc0205176:	0ae78963          	beq	a5,a4,ffffffffc0205228 <do_fork+0x240>
            else if (proc->pid > last_pid && next_safe > proc->pid) {
ffffffffc020517a:	fee7d9e3          	bge	a5,a4,ffffffffc020516c <do_fork+0x184>
ffffffffc020517e:	fec757e3          	bge	a4,a2,ffffffffc020516c <do_fork+0x184>
ffffffffc0205182:	6694                	ld	a3,8(a3)
ffffffffc0205184:	863a                	mv	a2,a4
ffffffffc0205186:	4805                	li	a6,1
        while ((le = list_next(le)) != list) {
ffffffffc0205188:	fe9695e3          	bne	a3,s1,ffffffffc0205172 <do_fork+0x18a>
ffffffffc020518c:	c591                	beqz	a1,ffffffffc0205198 <do_fork+0x1b0>
ffffffffc020518e:	0009c717          	auipc	a4,0x9c
ffffffffc0205192:	2af72923          	sw	a5,690(a4) # ffffffffc02a1440 <last_pid.1691>
ffffffffc0205196:	853e                	mv	a0,a5
ffffffffc0205198:	00080663          	beqz	a6,ffffffffc02051a4 <do_fork+0x1bc>
ffffffffc020519c:	0009c797          	auipc	a5,0x9c
ffffffffc02051a0:	2ac7a423          	sw	a2,680(a5) # ffffffffc02a1444 <next_safe.1690>
        proc->pid = get_pid();//获取当前进程PID
ffffffffc02051a4:	c048                	sw	a0,4(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc02051a6:	45a9                	li	a1,10
ffffffffc02051a8:	2501                	sext.w	a0,a0
ffffffffc02051aa:	42c010ef          	jal	ra,ffffffffc02065d6 <hash32>
ffffffffc02051ae:	1502                	slli	a0,a0,0x20
ffffffffc02051b0:	000a3797          	auipc	a5,0xa3
ffffffffc02051b4:	69878793          	addi	a5,a5,1688 # ffffffffc02a8848 <hash_list>
ffffffffc02051b8:	8171                	srli	a0,a0,0x1c
ffffffffc02051ba:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc02051bc:	650c                	ld	a1,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc02051be:	7014                	ld	a3,32(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc02051c0:	0d840793          	addi	a5,s0,216
    prev->next = next->prev = elm;
ffffffffc02051c4:	e19c                	sd	a5,0(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc02051c6:	6490                	ld	a2,8(s1)
    prev->next = next->prev = elm;
ffffffffc02051c8:	e51c                	sd	a5,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc02051ca:	7af8                	ld	a4,240(a3)
    list_add(&proc_list, &(proc->list_link));
ffffffffc02051cc:	0c840793          	addi	a5,s0,200
    elm->next = next;
ffffffffc02051d0:	f06c                	sd	a1,224(s0)
    elm->prev = prev;
ffffffffc02051d2:	ec68                	sd	a0,216(s0)
    prev->next = next->prev = elm;
ffffffffc02051d4:	e21c                	sd	a5,0(a2)
ffffffffc02051d6:	000a7597          	auipc	a1,0xa7
ffffffffc02051da:	7ef5bd23          	sd	a5,2042(a1) # ffffffffc02ac9d0 <proc_list+0x8>
    elm->next = next;
ffffffffc02051de:	e870                	sd	a2,208(s0)
    elm->prev = prev;
ffffffffc02051e0:	e464                	sd	s1,200(s0)
    proc->yptr = NULL;
ffffffffc02051e2:	0e043c23          	sd	zero,248(s0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc02051e6:	10e43023          	sd	a4,256(s0)
ffffffffc02051ea:	c311                	beqz	a4,ffffffffc02051ee <do_fork+0x206>
        proc->optr->yptr = proc;
ffffffffc02051ec:	ff60                	sd	s0,248(a4)
    nr_process ++;
ffffffffc02051ee:	000a2783          	lw	a5,0(s4)
    proc->parent->cptr = proc;
ffffffffc02051f2:	fae0                	sd	s0,240(a3)
    nr_process ++;
ffffffffc02051f4:	2785                	addiw	a5,a5,1
ffffffffc02051f6:	000a7717          	auipc	a4,0xa7
ffffffffc02051fa:	6af72523          	sw	a5,1706(a4) # ffffffffc02ac8a0 <nr_process>
    if (flag) {
ffffffffc02051fe:	10091863          	bnez	s2,ffffffffc020530e <do_fork+0x326>
    wakeup_proc(proc);
ffffffffc0205202:	8522                	mv	a0,s0
ffffffffc0205204:	52d000ef          	jal	ra,ffffffffc0205f30 <wakeup_proc>
    ret = proc->pid;//返回当前进程的PID
ffffffffc0205208:	4048                	lw	a0,4(s0)
}
ffffffffc020520a:	70a6                	ld	ra,104(sp)
ffffffffc020520c:	7406                	ld	s0,96(sp)
ffffffffc020520e:	64e6                	ld	s1,88(sp)
ffffffffc0205210:	6946                	ld	s2,80(sp)
ffffffffc0205212:	69a6                	ld	s3,72(sp)
ffffffffc0205214:	6a06                	ld	s4,64(sp)
ffffffffc0205216:	7ae2                	ld	s5,56(sp)
ffffffffc0205218:	7b42                	ld	s6,48(sp)
ffffffffc020521a:	7ba2                	ld	s7,40(sp)
ffffffffc020521c:	7c02                	ld	s8,32(sp)
ffffffffc020521e:	6ce2                	ld	s9,24(sp)
ffffffffc0205220:	6d42                	ld	s10,16(sp)
ffffffffc0205222:	6da2                	ld	s11,8(sp)
ffffffffc0205224:	6165                	addi	sp,sp,112
ffffffffc0205226:	8082                	ret
                if (++ last_pid >= next_safe) {
ffffffffc0205228:	2785                	addiw	a5,a5,1
ffffffffc020522a:	0ec7d563          	bge	a5,a2,ffffffffc0205314 <do_fork+0x32c>
ffffffffc020522e:	4585                	li	a1,1
ffffffffc0205230:	bf35                	j	ffffffffc020516c <do_fork+0x184>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0205232:	8936                	mv	s2,a3
ffffffffc0205234:	0126b823          	sd	s2,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0205238:	00000797          	auipc	a5,0x0
ffffffffc020523c:	b2278793          	addi	a5,a5,-1246 # ffffffffc0204d5a <forkret>
ffffffffc0205240:	f81c                	sd	a5,48(s0)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc0205242:	fc14                	sd	a3,56(s0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205244:	100027f3          	csrr	a5,sstatus
ffffffffc0205248:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020524a:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020524c:	ec0785e3          	beqz	a5,ffffffffc0205116 <do_fork+0x12e>
        intr_disable();
ffffffffc0205250:	c04fb0ef          	jal	ra,ffffffffc0200654 <intr_disable>
    if (++ last_pid >= MAX_PID) {
ffffffffc0205254:	0009c797          	auipc	a5,0x9c
ffffffffc0205258:	1ec78793          	addi	a5,a5,492 # ffffffffc02a1440 <last_pid.1691>
ffffffffc020525c:	439c                	lw	a5,0(a5)
ffffffffc020525e:	6709                	lui	a4,0x2
        return 1;
ffffffffc0205260:	4905                	li	s2,1
ffffffffc0205262:	0017851b          	addiw	a0,a5,1
ffffffffc0205266:	0009c697          	auipc	a3,0x9c
ffffffffc020526a:	1ca6ad23          	sw	a0,474(a3) # ffffffffc02a1440 <last_pid.1691>
ffffffffc020526e:	ece542e3          	blt	a0,a4,ffffffffc0205132 <do_fork+0x14a>
        last_pid = 1;
ffffffffc0205272:	4785                	li	a5,1
ffffffffc0205274:	0009c717          	auipc	a4,0x9c
ffffffffc0205278:	1cf72623          	sw	a5,460(a4) # ffffffffc02a1440 <last_pid.1691>
ffffffffc020527c:	4505                	li	a0,1
ffffffffc020527e:	b5e9                	j	ffffffffc0205148 <do_fork+0x160>
    if ((mm = mm_create()) == NULL) {
ffffffffc0205280:	92afd0ef          	jal	ra,ffffffffc02023aa <mm_create>
ffffffffc0205284:	8d2a                	mv	s10,a0
ffffffffc0205286:	c539                	beqz	a0,ffffffffc02052d4 <do_fork+0x2ec>
    if (setup_pgdir(mm) != 0) {
ffffffffc0205288:	be3ff0ef          	jal	ra,ffffffffc0204e6a <setup_pgdir>
ffffffffc020528c:	e949                	bnez	a0,ffffffffc020531e <do_fork+0x336>
}

static inline void
lock_mm(struct mm_struct *mm) {
    if (mm != NULL) {
        lock(&(mm->mm_lock));
ffffffffc020528e:	038c0d93          	addi	s11,s8,56
 * test_and_set_bit - Atomically set a bit and return its old value
 * @nr:     the bit to set
 * @addr:   the address to count from
 * */
static inline bool test_and_set_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0205292:	4785                	li	a5,1
ffffffffc0205294:	40fdb7af          	amoor.d	a5,a5,(s11)
ffffffffc0205298:	8b85                	andi	a5,a5,1
ffffffffc020529a:	4985                	li	s3,1
    return !test_and_set_bit(0, lock);
}

static inline void
lock(lock_t *lock) {
    while (!try_lock(lock)) {
ffffffffc020529c:	c799                	beqz	a5,ffffffffc02052aa <do_fork+0x2c2>
        schedule();
ffffffffc020529e:	50f000ef          	jal	ra,ffffffffc0205fac <schedule>
ffffffffc02052a2:	413db7af          	amoor.d	a5,s3,(s11)
ffffffffc02052a6:	8b85                	andi	a5,a5,1
    while (!try_lock(lock)) {
ffffffffc02052a8:	fbfd                	bnez	a5,ffffffffc020529e <do_fork+0x2b6>
        ret = dup_mmap(mm, oldmm);
ffffffffc02052aa:	85e2                	mv	a1,s8
ffffffffc02052ac:	856a                	mv	a0,s10
ffffffffc02052ae:	b86fd0ef          	jal	ra,ffffffffc0202634 <dup_mmap>
 * test_and_clear_bit - Atomically clear a bit and return its old value
 * @nr:     the bit to clear
 * @addr:   the address to count from
 * */
static inline bool test_and_clear_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02052b2:	57f9                	li	a5,-2
ffffffffc02052b4:	60fdb7af          	amoand.d	a5,a5,(s11)
ffffffffc02052b8:	8b85                	andi	a5,a5,1
    }
}

static inline void
unlock(lock_t *lock) {
    if (!test_and_clear_bit(0, lock)) {
ffffffffc02052ba:	c3e9                	beqz	a5,ffffffffc020537c <do_fork+0x394>
    if (ret != 0) {
ffffffffc02052bc:	8c6a                	mv	s8,s10
ffffffffc02052be:	de0502e3          	beqz	a0,ffffffffc02050a2 <do_fork+0xba>
    exit_mmap(mm);
ffffffffc02052c2:	856a                	mv	a0,s10
ffffffffc02052c4:	c0cfd0ef          	jal	ra,ffffffffc02026d0 <exit_mmap>
    put_pgdir(mm);
ffffffffc02052c8:	856a                	mv	a0,s10
ffffffffc02052ca:	b23ff0ef          	jal	ra,ffffffffc0204dec <put_pgdir>
    mm_destroy(mm);
ffffffffc02052ce:	856a                	mv	a0,s10
ffffffffc02052d0:	a60fd0ef          	jal	ra,ffffffffc0202530 <mm_destroy>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc02052d4:	6814                	ld	a3,16(s0)
    return pa2page(PADDR(kva));
ffffffffc02052d6:	c02007b7          	lui	a5,0xc0200
ffffffffc02052da:	0cf6e963          	bltu	a3,a5,ffffffffc02053ac <do_fork+0x3c4>
ffffffffc02052de:	000cb783          	ld	a5,0(s9)
    if (PPN(pa) >= npage) {
ffffffffc02052e2:	000bb703          	ld	a4,0(s7)
    return pa2page(PADDR(kva));
ffffffffc02052e6:	40f687b3          	sub	a5,a3,a5
    if (PPN(pa) >= npage) {
ffffffffc02052ea:	83b1                	srli	a5,a5,0xc
ffffffffc02052ec:	0ae7f463          	bgeu	a5,a4,ffffffffc0205394 <do_fork+0x3ac>
    return &pages[PPN(pa) - nbase];
ffffffffc02052f0:	000b3703          	ld	a4,0(s6)
ffffffffc02052f4:	000ab503          	ld	a0,0(s5)
ffffffffc02052f8:	4589                	li	a1,2
ffffffffc02052fa:	8f99                	sub	a5,a5,a4
ffffffffc02052fc:	079a                	slli	a5,a5,0x6
ffffffffc02052fe:	953e                	add	a0,a0,a5
ffffffffc0205300:	be3fb0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
    kfree(proc);
ffffffffc0205304:	8522                	mv	a0,s0
ffffffffc0205306:	facfe0ef          	jal	ra,ffffffffc0203ab2 <kfree>
    ret = -E_NO_MEM;
ffffffffc020530a:	5571                	li	a0,-4
    return ret;
ffffffffc020530c:	bdfd                	j	ffffffffc020520a <do_fork+0x222>
        intr_enable();
ffffffffc020530e:	b40fb0ef          	jal	ra,ffffffffc020064e <intr_enable>
ffffffffc0205312:	bdc5                	j	ffffffffc0205202 <do_fork+0x21a>
                    if (last_pid >= MAX_PID) {
ffffffffc0205314:	0117c363          	blt	a5,a7,ffffffffc020531a <do_fork+0x332>
                        last_pid = 1;
ffffffffc0205318:	4785                	li	a5,1
                    goto repeat;
ffffffffc020531a:	4585                	li	a1,1
ffffffffc020531c:	b591                	j	ffffffffc0205160 <do_fork+0x178>
    mm_destroy(mm);
ffffffffc020531e:	856a                	mv	a0,s10
ffffffffc0205320:	a10fd0ef          	jal	ra,ffffffffc0202530 <mm_destroy>
ffffffffc0205324:	bf45                	j	ffffffffc02052d4 <do_fork+0x2ec>
    int ret = -E_NO_FREE_PROC;
ffffffffc0205326:	556d                	li	a0,-5
ffffffffc0205328:	b5cd                	j	ffffffffc020520a <do_fork+0x222>
    return KADDR(page2pa(page));
ffffffffc020532a:	00002617          	auipc	a2,0x2
ffffffffc020532e:	c9e60613          	addi	a2,a2,-866 # ffffffffc0206fc8 <commands+0x868>
ffffffffc0205332:	06900593          	li	a1,105
ffffffffc0205336:	00002517          	auipc	a0,0x2
ffffffffc020533a:	cea50513          	addi	a0,a0,-790 # ffffffffc0207020 <commands+0x8c0>
ffffffffc020533e:	ed7fa0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(current->wait_state == 0); //确保进程在等待
ffffffffc0205342:	00003697          	auipc	a3,0x3
ffffffffc0205346:	24e68693          	addi	a3,a3,590 # ffffffffc0208590 <default_pmm_manager+0x270>
ffffffffc020534a:	00002617          	auipc	a2,0x2
ffffffffc020534e:	89660613          	addi	a2,a2,-1898 # ffffffffc0206be0 <commands+0x480>
ffffffffc0205352:	1b400593          	li	a1,436
ffffffffc0205356:	00003517          	auipc	a0,0x3
ffffffffc020535a:	4ca50513          	addi	a0,a0,1226 # ffffffffc0208820 <default_pmm_manager+0x500>
ffffffffc020535e:	eb7fa0ef          	jal	ra,ffffffffc0200214 <__panic>
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0205362:	86be                	mv	a3,a5
ffffffffc0205364:	00002617          	auipc	a2,0x2
ffffffffc0205368:	d3c60613          	addi	a2,a2,-708 # ffffffffc02070a0 <commands+0x940>
ffffffffc020536c:	16600593          	li	a1,358
ffffffffc0205370:	00003517          	auipc	a0,0x3
ffffffffc0205374:	4b050513          	addi	a0,a0,1200 # ffffffffc0208820 <default_pmm_manager+0x500>
ffffffffc0205378:	e9dfa0ef          	jal	ra,ffffffffc0200214 <__panic>
        panic("Unlock failed.\n");
ffffffffc020537c:	00003617          	auipc	a2,0x3
ffffffffc0205380:	23460613          	addi	a2,a2,564 # ffffffffc02085b0 <default_pmm_manager+0x290>
ffffffffc0205384:	03100593          	li	a1,49
ffffffffc0205388:	00003517          	auipc	a0,0x3
ffffffffc020538c:	23850513          	addi	a0,a0,568 # ffffffffc02085c0 <default_pmm_manager+0x2a0>
ffffffffc0205390:	e85fa0ef          	jal	ra,ffffffffc0200214 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0205394:	00002617          	auipc	a2,0x2
ffffffffc0205398:	c6c60613          	addi	a2,a2,-916 # ffffffffc0207000 <commands+0x8a0>
ffffffffc020539c:	06200593          	li	a1,98
ffffffffc02053a0:	00002517          	auipc	a0,0x2
ffffffffc02053a4:	c8050513          	addi	a0,a0,-896 # ffffffffc0207020 <commands+0x8c0>
ffffffffc02053a8:	e6dfa0ef          	jal	ra,ffffffffc0200214 <__panic>
    return pa2page(PADDR(kva));
ffffffffc02053ac:	00002617          	auipc	a2,0x2
ffffffffc02053b0:	cf460613          	addi	a2,a2,-780 # ffffffffc02070a0 <commands+0x940>
ffffffffc02053b4:	06e00593          	li	a1,110
ffffffffc02053b8:	00002517          	auipc	a0,0x2
ffffffffc02053bc:	c6850513          	addi	a0,a0,-920 # ffffffffc0207020 <commands+0x8c0>
ffffffffc02053c0:	e55fa0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc02053c4 <kernel_thread>:
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc02053c4:	7129                	addi	sp,sp,-320
ffffffffc02053c6:	fa22                	sd	s0,304(sp)
ffffffffc02053c8:	f626                	sd	s1,296(sp)
ffffffffc02053ca:	f24a                	sd	s2,288(sp)
ffffffffc02053cc:	84ae                	mv	s1,a1
ffffffffc02053ce:	892a                	mv	s2,a0
ffffffffc02053d0:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc02053d2:	4581                	li	a1,0
ffffffffc02053d4:	12000613          	li	a2,288
ffffffffc02053d8:	850a                	mv	a0,sp
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc02053da:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc02053dc:	5e5000ef          	jal	ra,ffffffffc02061c0 <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc02053e0:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc02053e2:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc02053e4:	100027f3          	csrr	a5,sstatus
ffffffffc02053e8:	edd7f793          	andi	a5,a5,-291
ffffffffc02053ec:	1207e793          	ori	a5,a5,288
ffffffffc02053f0:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02053f2:	860a                	mv	a2,sp
ffffffffc02053f4:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc02053f8:	00000797          	auipc	a5,0x0
ffffffffc02053fc:	87c78793          	addi	a5,a5,-1924 # ffffffffc0204c74 <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0205400:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc0205402:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0205404:	be5ff0ef          	jal	ra,ffffffffc0204fe8 <do_fork>
}
ffffffffc0205408:	70f2                	ld	ra,312(sp)
ffffffffc020540a:	7452                	ld	s0,304(sp)
ffffffffc020540c:	74b2                	ld	s1,296(sp)
ffffffffc020540e:	7912                	ld	s2,288(sp)
ffffffffc0205410:	6131                	addi	sp,sp,320
ffffffffc0205412:	8082                	ret

ffffffffc0205414 <do_exit>:
do_exit(int error_code) {
ffffffffc0205414:	7179                	addi	sp,sp,-48
ffffffffc0205416:	e84a                	sd	s2,16(sp)
    if (current == idleproc) {
ffffffffc0205418:	000a7717          	auipc	a4,0xa7
ffffffffc020541c:	47870713          	addi	a4,a4,1144 # ffffffffc02ac890 <idleproc>
ffffffffc0205420:	000a7917          	auipc	s2,0xa7
ffffffffc0205424:	46890913          	addi	s2,s2,1128 # ffffffffc02ac888 <current>
ffffffffc0205428:	00093783          	ld	a5,0(s2)
ffffffffc020542c:	6318                	ld	a4,0(a4)
do_exit(int error_code) {
ffffffffc020542e:	f406                	sd	ra,40(sp)
ffffffffc0205430:	f022                	sd	s0,32(sp)
ffffffffc0205432:	ec26                	sd	s1,24(sp)
ffffffffc0205434:	e44e                	sd	s3,8(sp)
ffffffffc0205436:	e052                	sd	s4,0(sp)
    if (current == idleproc) {
ffffffffc0205438:	0ce78c63          	beq	a5,a4,ffffffffc0205510 <do_exit+0xfc>
    if (current == initproc) {
ffffffffc020543c:	000a7417          	auipc	s0,0xa7
ffffffffc0205440:	45c40413          	addi	s0,s0,1116 # ffffffffc02ac898 <initproc>
ffffffffc0205444:	6018                	ld	a4,0(s0)
ffffffffc0205446:	0ee78b63          	beq	a5,a4,ffffffffc020553c <do_exit+0x128>
    struct mm_struct *mm = current->mm;
ffffffffc020544a:	7784                	ld	s1,40(a5)
ffffffffc020544c:	89aa                	mv	s3,a0
    if (mm != NULL) {
ffffffffc020544e:	c48d                	beqz	s1,ffffffffc0205478 <do_exit+0x64>
        lcr3(boot_cr3);
ffffffffc0205450:	000a7797          	auipc	a5,0xa7
ffffffffc0205454:	47078793          	addi	a5,a5,1136 # ffffffffc02ac8c0 <boot_cr3>
ffffffffc0205458:	639c                	ld	a5,0(a5)
ffffffffc020545a:	577d                	li	a4,-1
ffffffffc020545c:	177e                	slli	a4,a4,0x3f
ffffffffc020545e:	83b1                	srli	a5,a5,0xc
ffffffffc0205460:	8fd9                	or	a5,a5,a4
ffffffffc0205462:	18079073          	csrw	satp,a5
    mm->mm_count -= 1;
ffffffffc0205466:	589c                	lw	a5,48(s1)
ffffffffc0205468:	fff7871b          	addiw	a4,a5,-1
ffffffffc020546c:	d898                	sw	a4,48(s1)
        if (mm_count_dec(mm) == 0) {
ffffffffc020546e:	cf4d                	beqz	a4,ffffffffc0205528 <do_exit+0x114>
        current->mm = NULL;
ffffffffc0205470:	00093783          	ld	a5,0(s2)
ffffffffc0205474:	0207b423          	sd	zero,40(a5)
    current->state = PROC_ZOMBIE;
ffffffffc0205478:	00093783          	ld	a5,0(s2)
ffffffffc020547c:	470d                	li	a4,3
ffffffffc020547e:	c398                	sw	a4,0(a5)
    current->exit_code = error_code;
ffffffffc0205480:	0f37a423          	sw	s3,232(a5)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205484:	100027f3          	csrr	a5,sstatus
ffffffffc0205488:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020548a:	4a01                	li	s4,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020548c:	e7e1                	bnez	a5,ffffffffc0205554 <do_exit+0x140>
        proc = current->parent;
ffffffffc020548e:	00093703          	ld	a4,0(s2)
        if (proc->wait_state == WT_CHILD) {
ffffffffc0205492:	800007b7          	lui	a5,0x80000
ffffffffc0205496:	0785                	addi	a5,a5,1
        proc = current->parent;
ffffffffc0205498:	7308                	ld	a0,32(a4)
        if (proc->wait_state == WT_CHILD) {
ffffffffc020549a:	0ec52703          	lw	a4,236(a0)
ffffffffc020549e:	0af70f63          	beq	a4,a5,ffffffffc020555c <do_exit+0x148>
ffffffffc02054a2:	00093683          	ld	a3,0(s2)
                if (initproc->wait_state == WT_CHILD) {
ffffffffc02054a6:	800009b7          	lui	s3,0x80000
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02054aa:	448d                	li	s1,3
                if (initproc->wait_state == WT_CHILD) {
ffffffffc02054ac:	0985                	addi	s3,s3,1
        while (current->cptr != NULL) {
ffffffffc02054ae:	7afc                	ld	a5,240(a3)
ffffffffc02054b0:	cb95                	beqz	a5,ffffffffc02054e4 <do_exit+0xd0>
            current->cptr = proc->optr;
ffffffffc02054b2:	1007b703          	ld	a4,256(a5) # ffffffff80000100 <_binary_obj___user_exit_out_size+0xffffffff7fff5638>
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc02054b6:	6008                	ld	a0,0(s0)
            current->cptr = proc->optr;
ffffffffc02054b8:	faf8                	sd	a4,240(a3)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc02054ba:	7978                	ld	a4,240(a0)
            proc->yptr = NULL;
ffffffffc02054bc:	0e07bc23          	sd	zero,248(a5)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc02054c0:	10e7b023          	sd	a4,256(a5)
ffffffffc02054c4:	c311                	beqz	a4,ffffffffc02054c8 <do_exit+0xb4>
                initproc->cptr->yptr = proc;
ffffffffc02054c6:	ff7c                	sd	a5,248(a4)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02054c8:	4398                	lw	a4,0(a5)
            proc->parent = initproc;
ffffffffc02054ca:	f388                	sd	a0,32(a5)
            initproc->cptr = proc;
ffffffffc02054cc:	f97c                	sd	a5,240(a0)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02054ce:	fe9710e3          	bne	a4,s1,ffffffffc02054ae <do_exit+0x9a>
                if (initproc->wait_state == WT_CHILD) {
ffffffffc02054d2:	0ec52783          	lw	a5,236(a0)
ffffffffc02054d6:	fd379ce3          	bne	a5,s3,ffffffffc02054ae <do_exit+0x9a>
                    wakeup_proc(initproc);
ffffffffc02054da:	257000ef          	jal	ra,ffffffffc0205f30 <wakeup_proc>
ffffffffc02054de:	00093683          	ld	a3,0(s2)
ffffffffc02054e2:	b7f1                	j	ffffffffc02054ae <do_exit+0x9a>
    if (flag) {
ffffffffc02054e4:	020a1363          	bnez	s4,ffffffffc020550a <do_exit+0xf6>
    schedule();
ffffffffc02054e8:	2c5000ef          	jal	ra,ffffffffc0205fac <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
ffffffffc02054ec:	00093783          	ld	a5,0(s2)
ffffffffc02054f0:	00003617          	auipc	a2,0x3
ffffffffc02054f4:	08060613          	addi	a2,a2,128 # ffffffffc0208570 <default_pmm_manager+0x250>
ffffffffc02054f8:	20600593          	li	a1,518
ffffffffc02054fc:	43d4                	lw	a3,4(a5)
ffffffffc02054fe:	00003517          	auipc	a0,0x3
ffffffffc0205502:	32250513          	addi	a0,a0,802 # ffffffffc0208820 <default_pmm_manager+0x500>
ffffffffc0205506:	d0ffa0ef          	jal	ra,ffffffffc0200214 <__panic>
        intr_enable();
ffffffffc020550a:	944fb0ef          	jal	ra,ffffffffc020064e <intr_enable>
ffffffffc020550e:	bfe9                	j	ffffffffc02054e8 <do_exit+0xd4>
        panic("idleproc exit.\n");
ffffffffc0205510:	00003617          	auipc	a2,0x3
ffffffffc0205514:	04060613          	addi	a2,a2,64 # ffffffffc0208550 <default_pmm_manager+0x230>
ffffffffc0205518:	1da00593          	li	a1,474
ffffffffc020551c:	00003517          	auipc	a0,0x3
ffffffffc0205520:	30450513          	addi	a0,a0,772 # ffffffffc0208820 <default_pmm_manager+0x500>
ffffffffc0205524:	cf1fa0ef          	jal	ra,ffffffffc0200214 <__panic>
            exit_mmap(mm);
ffffffffc0205528:	8526                	mv	a0,s1
ffffffffc020552a:	9a6fd0ef          	jal	ra,ffffffffc02026d0 <exit_mmap>
            put_pgdir(mm);
ffffffffc020552e:	8526                	mv	a0,s1
ffffffffc0205530:	8bdff0ef          	jal	ra,ffffffffc0204dec <put_pgdir>
            mm_destroy(mm);
ffffffffc0205534:	8526                	mv	a0,s1
ffffffffc0205536:	ffbfc0ef          	jal	ra,ffffffffc0202530 <mm_destroy>
ffffffffc020553a:	bf1d                	j	ffffffffc0205470 <do_exit+0x5c>
        panic("initproc exit.\n");
ffffffffc020553c:	00003617          	auipc	a2,0x3
ffffffffc0205540:	02460613          	addi	a2,a2,36 # ffffffffc0208560 <default_pmm_manager+0x240>
ffffffffc0205544:	1dd00593          	li	a1,477
ffffffffc0205548:	00003517          	auipc	a0,0x3
ffffffffc020554c:	2d850513          	addi	a0,a0,728 # ffffffffc0208820 <default_pmm_manager+0x500>
ffffffffc0205550:	cc5fa0ef          	jal	ra,ffffffffc0200214 <__panic>
        intr_disable();
ffffffffc0205554:	900fb0ef          	jal	ra,ffffffffc0200654 <intr_disable>
        return 1;
ffffffffc0205558:	4a05                	li	s4,1
ffffffffc020555a:	bf15                	j	ffffffffc020548e <do_exit+0x7a>
            wakeup_proc(proc);
ffffffffc020555c:	1d5000ef          	jal	ra,ffffffffc0205f30 <wakeup_proc>
ffffffffc0205560:	b789                	j	ffffffffc02054a2 <do_exit+0x8e>

ffffffffc0205562 <do_wait.part.1>:
do_wait(int pid, int *code_store) {
ffffffffc0205562:	7139                	addi	sp,sp,-64
ffffffffc0205564:	e852                	sd	s4,16(sp)
        current->wait_state = WT_CHILD;
ffffffffc0205566:	80000a37          	lui	s4,0x80000
do_wait(int pid, int *code_store) {
ffffffffc020556a:	f426                	sd	s1,40(sp)
ffffffffc020556c:	f04a                	sd	s2,32(sp)
ffffffffc020556e:	ec4e                	sd	s3,24(sp)
ffffffffc0205570:	e456                	sd	s5,8(sp)
ffffffffc0205572:	e05a                	sd	s6,0(sp)
ffffffffc0205574:	fc06                	sd	ra,56(sp)
ffffffffc0205576:	f822                	sd	s0,48(sp)
ffffffffc0205578:	89aa                	mv	s3,a0
ffffffffc020557a:	8b2e                	mv	s6,a1
        proc = current->cptr;
ffffffffc020557c:	000a7917          	auipc	s2,0xa7
ffffffffc0205580:	30c90913          	addi	s2,s2,780 # ffffffffc02ac888 <current>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205584:	448d                	li	s1,3
        current->state = PROC_SLEEPING;
ffffffffc0205586:	4a85                	li	s5,1
        current->wait_state = WT_CHILD;
ffffffffc0205588:	0a05                	addi	s4,s4,1
    if (pid != 0) {
ffffffffc020558a:	02098f63          	beqz	s3,ffffffffc02055c8 <do_wait.part.1+0x66>
        proc = find_proc(pid);
ffffffffc020558e:	854e                	mv	a0,s3
ffffffffc0205590:	9fdff0ef          	jal	ra,ffffffffc0204f8c <find_proc>
ffffffffc0205594:	842a                	mv	s0,a0
        if (proc != NULL && proc->parent == current) {
ffffffffc0205596:	12050063          	beqz	a0,ffffffffc02056b6 <do_wait.part.1+0x154>
ffffffffc020559a:	00093703          	ld	a4,0(s2)
ffffffffc020559e:	711c                	ld	a5,32(a0)
ffffffffc02055a0:	10e79b63          	bne	a5,a4,ffffffffc02056b6 <do_wait.part.1+0x154>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02055a4:	411c                	lw	a5,0(a0)
ffffffffc02055a6:	02978c63          	beq	a5,s1,ffffffffc02055de <do_wait.part.1+0x7c>
        current->state = PROC_SLEEPING;
ffffffffc02055aa:	01572023          	sw	s5,0(a4)
        current->wait_state = WT_CHILD;
ffffffffc02055ae:	0f472623          	sw	s4,236(a4)
        schedule();
ffffffffc02055b2:	1fb000ef          	jal	ra,ffffffffc0205fac <schedule>
        if (current->flags & PF_EXITING) {
ffffffffc02055b6:	00093783          	ld	a5,0(s2)
ffffffffc02055ba:	0b07a783          	lw	a5,176(a5)
ffffffffc02055be:	8b85                	andi	a5,a5,1
ffffffffc02055c0:	d7e9                	beqz	a5,ffffffffc020558a <do_wait.part.1+0x28>
            do_exit(-E_KILLED);
ffffffffc02055c2:	555d                	li	a0,-9
ffffffffc02055c4:	e51ff0ef          	jal	ra,ffffffffc0205414 <do_exit>
        proc = current->cptr;
ffffffffc02055c8:	00093703          	ld	a4,0(s2)
ffffffffc02055cc:	7b60                	ld	s0,240(a4)
        for (; proc != NULL; proc = proc->optr) {
ffffffffc02055ce:	e409                	bnez	s0,ffffffffc02055d8 <do_wait.part.1+0x76>
ffffffffc02055d0:	a0dd                	j	ffffffffc02056b6 <do_wait.part.1+0x154>
ffffffffc02055d2:	10043403          	ld	s0,256(s0)
ffffffffc02055d6:	d871                	beqz	s0,ffffffffc02055aa <do_wait.part.1+0x48>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02055d8:	401c                	lw	a5,0(s0)
ffffffffc02055da:	fe979ce3          	bne	a5,s1,ffffffffc02055d2 <do_wait.part.1+0x70>
    if (proc == idleproc || proc == initproc) {
ffffffffc02055de:	000a7797          	auipc	a5,0xa7
ffffffffc02055e2:	2b278793          	addi	a5,a5,690 # ffffffffc02ac890 <idleproc>
ffffffffc02055e6:	639c                	ld	a5,0(a5)
ffffffffc02055e8:	0c878d63          	beq	a5,s0,ffffffffc02056c2 <do_wait.part.1+0x160>
ffffffffc02055ec:	000a7797          	auipc	a5,0xa7
ffffffffc02055f0:	2ac78793          	addi	a5,a5,684 # ffffffffc02ac898 <initproc>
ffffffffc02055f4:	639c                	ld	a5,0(a5)
ffffffffc02055f6:	0cf40663          	beq	s0,a5,ffffffffc02056c2 <do_wait.part.1+0x160>
    if (code_store != NULL) {
ffffffffc02055fa:	000b0663          	beqz	s6,ffffffffc0205606 <do_wait.part.1+0xa4>
        *code_store = proc->exit_code;
ffffffffc02055fe:	0e842783          	lw	a5,232(s0)
ffffffffc0205602:	00fb2023          	sw	a5,0(s6)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205606:	100027f3          	csrr	a5,sstatus
ffffffffc020560a:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020560c:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020560e:	e7d5                	bnez	a5,ffffffffc02056ba <do_wait.part.1+0x158>
    __list_del(listelm->prev, listelm->next);
ffffffffc0205610:	6c70                	ld	a2,216(s0)
ffffffffc0205612:	7074                	ld	a3,224(s0)
    if (proc->optr != NULL) {
ffffffffc0205614:	10043703          	ld	a4,256(s0)
ffffffffc0205618:	7c7c                	ld	a5,248(s0)
    prev->next = next;
ffffffffc020561a:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc020561c:	e290                	sd	a2,0(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc020561e:	6470                	ld	a2,200(s0)
ffffffffc0205620:	6874                	ld	a3,208(s0)
    prev->next = next;
ffffffffc0205622:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc0205624:	e290                	sd	a2,0(a3)
ffffffffc0205626:	c319                	beqz	a4,ffffffffc020562c <do_wait.part.1+0xca>
        proc->optr->yptr = proc->yptr;
ffffffffc0205628:	ff7c                	sd	a5,248(a4)
ffffffffc020562a:	7c7c                	ld	a5,248(s0)
    if (proc->yptr != NULL) {
ffffffffc020562c:	c3d1                	beqz	a5,ffffffffc02056b0 <do_wait.part.1+0x14e>
        proc->yptr->optr = proc->optr;
ffffffffc020562e:	10e7b023          	sd	a4,256(a5)
    nr_process --;
ffffffffc0205632:	000a7797          	auipc	a5,0xa7
ffffffffc0205636:	26e78793          	addi	a5,a5,622 # ffffffffc02ac8a0 <nr_process>
ffffffffc020563a:	439c                	lw	a5,0(a5)
ffffffffc020563c:	37fd                	addiw	a5,a5,-1
ffffffffc020563e:	000a7717          	auipc	a4,0xa7
ffffffffc0205642:	26f72123          	sw	a5,610(a4) # ffffffffc02ac8a0 <nr_process>
    if (flag) {
ffffffffc0205646:	e1b5                	bnez	a1,ffffffffc02056aa <do_wait.part.1+0x148>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc0205648:	6814                	ld	a3,16(s0)
ffffffffc020564a:	c02007b7          	lui	a5,0xc0200
ffffffffc020564e:	0af6e263          	bltu	a3,a5,ffffffffc02056f2 <do_wait.part.1+0x190>
ffffffffc0205652:	000a7797          	auipc	a5,0xa7
ffffffffc0205656:	26678793          	addi	a5,a5,614 # ffffffffc02ac8b8 <va_pa_offset>
ffffffffc020565a:	6398                	ld	a4,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc020565c:	000a7797          	auipc	a5,0xa7
ffffffffc0205660:	20478793          	addi	a5,a5,516 # ffffffffc02ac860 <npage>
ffffffffc0205664:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc0205666:	8e99                	sub	a3,a3,a4
    if (PPN(pa) >= npage) {
ffffffffc0205668:	82b1                	srli	a3,a3,0xc
ffffffffc020566a:	06f6f863          	bgeu	a3,a5,ffffffffc02056da <do_wait.part.1+0x178>
    return &pages[PPN(pa) - nbase];
ffffffffc020566e:	00003797          	auipc	a5,0x3
ffffffffc0205672:	67a78793          	addi	a5,a5,1658 # ffffffffc0208ce8 <nbase>
ffffffffc0205676:	639c                	ld	a5,0(a5)
ffffffffc0205678:	000a7717          	auipc	a4,0xa7
ffffffffc020567c:	25070713          	addi	a4,a4,592 # ffffffffc02ac8c8 <pages>
ffffffffc0205680:	6308                	ld	a0,0(a4)
ffffffffc0205682:	8e9d                	sub	a3,a3,a5
ffffffffc0205684:	069a                	slli	a3,a3,0x6
ffffffffc0205686:	9536                	add	a0,a0,a3
ffffffffc0205688:	4589                	li	a1,2
ffffffffc020568a:	859fb0ef          	jal	ra,ffffffffc0200ee2 <free_pages>
    kfree(proc);
ffffffffc020568e:	8522                	mv	a0,s0
ffffffffc0205690:	c22fe0ef          	jal	ra,ffffffffc0203ab2 <kfree>
    return 0;
ffffffffc0205694:	4501                	li	a0,0
}
ffffffffc0205696:	70e2                	ld	ra,56(sp)
ffffffffc0205698:	7442                	ld	s0,48(sp)
ffffffffc020569a:	74a2                	ld	s1,40(sp)
ffffffffc020569c:	7902                	ld	s2,32(sp)
ffffffffc020569e:	69e2                	ld	s3,24(sp)
ffffffffc02056a0:	6a42                	ld	s4,16(sp)
ffffffffc02056a2:	6aa2                	ld	s5,8(sp)
ffffffffc02056a4:	6b02                	ld	s6,0(sp)
ffffffffc02056a6:	6121                	addi	sp,sp,64
ffffffffc02056a8:	8082                	ret
        intr_enable();
ffffffffc02056aa:	fa5fa0ef          	jal	ra,ffffffffc020064e <intr_enable>
ffffffffc02056ae:	bf69                	j	ffffffffc0205648 <do_wait.part.1+0xe6>
       proc->parent->cptr = proc->optr;
ffffffffc02056b0:	701c                	ld	a5,32(s0)
ffffffffc02056b2:	fbf8                	sd	a4,240(a5)
ffffffffc02056b4:	bfbd                	j	ffffffffc0205632 <do_wait.part.1+0xd0>
    return -E_BAD_PROC;
ffffffffc02056b6:	5579                	li	a0,-2
ffffffffc02056b8:	bff9                	j	ffffffffc0205696 <do_wait.part.1+0x134>
        intr_disable();
ffffffffc02056ba:	f9bfa0ef          	jal	ra,ffffffffc0200654 <intr_disable>
        return 1;
ffffffffc02056be:	4585                	li	a1,1
ffffffffc02056c0:	bf81                	j	ffffffffc0205610 <do_wait.part.1+0xae>
        panic("wait idleproc or initproc.\n");
ffffffffc02056c2:	00003617          	auipc	a2,0x3
ffffffffc02056c6:	f1660613          	addi	a2,a2,-234 # ffffffffc02085d8 <default_pmm_manager+0x2b8>
ffffffffc02056ca:	30200593          	li	a1,770
ffffffffc02056ce:	00003517          	auipc	a0,0x3
ffffffffc02056d2:	15250513          	addi	a0,a0,338 # ffffffffc0208820 <default_pmm_manager+0x500>
ffffffffc02056d6:	b3ffa0ef          	jal	ra,ffffffffc0200214 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02056da:	00002617          	auipc	a2,0x2
ffffffffc02056de:	92660613          	addi	a2,a2,-1754 # ffffffffc0207000 <commands+0x8a0>
ffffffffc02056e2:	06200593          	li	a1,98
ffffffffc02056e6:	00002517          	auipc	a0,0x2
ffffffffc02056ea:	93a50513          	addi	a0,a0,-1734 # ffffffffc0207020 <commands+0x8c0>
ffffffffc02056ee:	b27fa0ef          	jal	ra,ffffffffc0200214 <__panic>
    return pa2page(PADDR(kva));
ffffffffc02056f2:	00002617          	auipc	a2,0x2
ffffffffc02056f6:	9ae60613          	addi	a2,a2,-1618 # ffffffffc02070a0 <commands+0x940>
ffffffffc02056fa:	06e00593          	li	a1,110
ffffffffc02056fe:	00002517          	auipc	a0,0x2
ffffffffc0205702:	92250513          	addi	a0,a0,-1758 # ffffffffc0207020 <commands+0x8c0>
ffffffffc0205706:	b0ffa0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc020570a <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
ffffffffc020570a:	1141                	addi	sp,sp,-16
ffffffffc020570c:	e406                	sd	ra,8(sp)
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc020570e:	81bfb0ef          	jal	ra,ffffffffc0200f28 <nr_free_pages>
    size_t kernel_allocated_store = kallocated();
ffffffffc0205712:	ae0fe0ef          	jal	ra,ffffffffc02039f2 <kallocated>

    int pid = kernel_thread(user_main, NULL, 0);
ffffffffc0205716:	4601                	li	a2,0
ffffffffc0205718:	4581                	li	a1,0
ffffffffc020571a:	fffff517          	auipc	a0,0xfffff
ffffffffc020571e:	65050513          	addi	a0,a0,1616 # ffffffffc0204d6a <user_main>
ffffffffc0205722:	ca3ff0ef          	jal	ra,ffffffffc02053c4 <kernel_thread>
    if (pid <= 0) {
ffffffffc0205726:	00a04563          	bgtz	a0,ffffffffc0205730 <init_main+0x26>
ffffffffc020572a:	a841                	j	ffffffffc02057ba <init_main+0xb0>
        panic("create user_main failed.\n");
    }

    while (do_wait(0, NULL) == 0) {
        schedule();
ffffffffc020572c:	081000ef          	jal	ra,ffffffffc0205fac <schedule>
    if (code_store != NULL) {
ffffffffc0205730:	4581                	li	a1,0
ffffffffc0205732:	4501                	li	a0,0
ffffffffc0205734:	e2fff0ef          	jal	ra,ffffffffc0205562 <do_wait.part.1>
    while (do_wait(0, NULL) == 0) {
ffffffffc0205738:	d975                	beqz	a0,ffffffffc020572c <init_main+0x22>
    }

    cprintf("all user-mode processes have quit.\n");
ffffffffc020573a:	00003517          	auipc	a0,0x3
ffffffffc020573e:	ede50513          	addi	a0,a0,-290 # ffffffffc0208618 <default_pmm_manager+0x2f8>
ffffffffc0205742:	98ffa0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc0205746:	000a7797          	auipc	a5,0xa7
ffffffffc020574a:	15278793          	addi	a5,a5,338 # ffffffffc02ac898 <initproc>
ffffffffc020574e:	639c                	ld	a5,0(a5)
ffffffffc0205750:	7bf8                	ld	a4,240(a5)
ffffffffc0205752:	e721                	bnez	a4,ffffffffc020579a <init_main+0x90>
ffffffffc0205754:	7ff8                	ld	a4,248(a5)
ffffffffc0205756:	e331                	bnez	a4,ffffffffc020579a <init_main+0x90>
ffffffffc0205758:	1007b703          	ld	a4,256(a5)
ffffffffc020575c:	ef1d                	bnez	a4,ffffffffc020579a <init_main+0x90>
    assert(nr_process == 2);
ffffffffc020575e:	000a7717          	auipc	a4,0xa7
ffffffffc0205762:	14270713          	addi	a4,a4,322 # ffffffffc02ac8a0 <nr_process>
ffffffffc0205766:	4314                	lw	a3,0(a4)
ffffffffc0205768:	4709                	li	a4,2
ffffffffc020576a:	0ae69463          	bne	a3,a4,ffffffffc0205812 <init_main+0x108>
    return listelm->next;
ffffffffc020576e:	000a7697          	auipc	a3,0xa7
ffffffffc0205772:	25a68693          	addi	a3,a3,602 # ffffffffc02ac9c8 <proc_list>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc0205776:	6698                	ld	a4,8(a3)
ffffffffc0205778:	0c878793          	addi	a5,a5,200
ffffffffc020577c:	06f71b63          	bne	a4,a5,ffffffffc02057f2 <init_main+0xe8>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc0205780:	629c                	ld	a5,0(a3)
ffffffffc0205782:	04f71863          	bne	a4,a5,ffffffffc02057d2 <init_main+0xc8>

    cprintf("init check memory pass.\n");
ffffffffc0205786:	00003517          	auipc	a0,0x3
ffffffffc020578a:	f7a50513          	addi	a0,a0,-134 # ffffffffc0208700 <default_pmm_manager+0x3e0>
ffffffffc020578e:	943fa0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    return 0;
}
ffffffffc0205792:	60a2                	ld	ra,8(sp)
ffffffffc0205794:	4501                	li	a0,0
ffffffffc0205796:	0141                	addi	sp,sp,16
ffffffffc0205798:	8082                	ret
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc020579a:	00003697          	auipc	a3,0x3
ffffffffc020579e:	ea668693          	addi	a3,a3,-346 # ffffffffc0208640 <default_pmm_manager+0x320>
ffffffffc02057a2:	00001617          	auipc	a2,0x1
ffffffffc02057a6:	43e60613          	addi	a2,a2,1086 # ffffffffc0206be0 <commands+0x480>
ffffffffc02057aa:	36700593          	li	a1,871
ffffffffc02057ae:	00003517          	auipc	a0,0x3
ffffffffc02057b2:	07250513          	addi	a0,a0,114 # ffffffffc0208820 <default_pmm_manager+0x500>
ffffffffc02057b6:	a5ffa0ef          	jal	ra,ffffffffc0200214 <__panic>
        panic("create user_main failed.\n");
ffffffffc02057ba:	00003617          	auipc	a2,0x3
ffffffffc02057be:	e3e60613          	addi	a2,a2,-450 # ffffffffc02085f8 <default_pmm_manager+0x2d8>
ffffffffc02057c2:	35f00593          	li	a1,863
ffffffffc02057c6:	00003517          	auipc	a0,0x3
ffffffffc02057ca:	05a50513          	addi	a0,a0,90 # ffffffffc0208820 <default_pmm_manager+0x500>
ffffffffc02057ce:	a47fa0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc02057d2:	00003697          	auipc	a3,0x3
ffffffffc02057d6:	efe68693          	addi	a3,a3,-258 # ffffffffc02086d0 <default_pmm_manager+0x3b0>
ffffffffc02057da:	00001617          	auipc	a2,0x1
ffffffffc02057de:	40660613          	addi	a2,a2,1030 # ffffffffc0206be0 <commands+0x480>
ffffffffc02057e2:	36a00593          	li	a1,874
ffffffffc02057e6:	00003517          	auipc	a0,0x3
ffffffffc02057ea:	03a50513          	addi	a0,a0,58 # ffffffffc0208820 <default_pmm_manager+0x500>
ffffffffc02057ee:	a27fa0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc02057f2:	00003697          	auipc	a3,0x3
ffffffffc02057f6:	eae68693          	addi	a3,a3,-338 # ffffffffc02086a0 <default_pmm_manager+0x380>
ffffffffc02057fa:	00001617          	auipc	a2,0x1
ffffffffc02057fe:	3e660613          	addi	a2,a2,998 # ffffffffc0206be0 <commands+0x480>
ffffffffc0205802:	36900593          	li	a1,873
ffffffffc0205806:	00003517          	auipc	a0,0x3
ffffffffc020580a:	01a50513          	addi	a0,a0,26 # ffffffffc0208820 <default_pmm_manager+0x500>
ffffffffc020580e:	a07fa0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(nr_process == 2);
ffffffffc0205812:	00003697          	auipc	a3,0x3
ffffffffc0205816:	e7e68693          	addi	a3,a3,-386 # ffffffffc0208690 <default_pmm_manager+0x370>
ffffffffc020581a:	00001617          	auipc	a2,0x1
ffffffffc020581e:	3c660613          	addi	a2,a2,966 # ffffffffc0206be0 <commands+0x480>
ffffffffc0205822:	36800593          	li	a1,872
ffffffffc0205826:	00003517          	auipc	a0,0x3
ffffffffc020582a:	ffa50513          	addi	a0,a0,-6 # ffffffffc0208820 <default_pmm_manager+0x500>
ffffffffc020582e:	9e7fa0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0205832 <do_execve>:
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0205832:	7135                	addi	sp,sp,-160
ffffffffc0205834:	f8d2                	sd	s4,112(sp)
    struct mm_struct *mm = current->mm;
ffffffffc0205836:	000a7a17          	auipc	s4,0xa7
ffffffffc020583a:	052a0a13          	addi	s4,s4,82 # ffffffffc02ac888 <current>
ffffffffc020583e:	000a3783          	ld	a5,0(s4)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0205842:	e14a                	sd	s2,128(sp)
ffffffffc0205844:	e922                	sd	s0,144(sp)
    struct mm_struct *mm = current->mm;
ffffffffc0205846:	0287b903          	ld	s2,40(a5)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc020584a:	fcce                	sd	s3,120(sp)
ffffffffc020584c:	f0da                	sd	s6,96(sp)
ffffffffc020584e:	89aa                	mv	s3,a0
ffffffffc0205850:	842e                	mv	s0,a1
ffffffffc0205852:	8b32                	mv	s6,a2
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc0205854:	4681                	li	a3,0
ffffffffc0205856:	862e                	mv	a2,a1
ffffffffc0205858:	85aa                	mv	a1,a0
ffffffffc020585a:	854a                	mv	a0,s2
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc020585c:	ed06                	sd	ra,152(sp)
ffffffffc020585e:	e526                	sd	s1,136(sp)
ffffffffc0205860:	f4d6                	sd	s5,104(sp)
ffffffffc0205862:	ecde                	sd	s7,88(sp)
ffffffffc0205864:	e8e2                	sd	s8,80(sp)
ffffffffc0205866:	e4e6                	sd	s9,72(sp)
ffffffffc0205868:	e0ea                	sd	s10,64(sp)
ffffffffc020586a:	fc6e                	sd	s11,56(sp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc020586c:	d28fd0ef          	jal	ra,ffffffffc0202d94 <user_mem_check>
ffffffffc0205870:	40050463          	beqz	a0,ffffffffc0205c78 <do_execve+0x446>
    memset(local_name, 0, sizeof(local_name));
ffffffffc0205874:	4641                	li	a2,16
ffffffffc0205876:	4581                	li	a1,0
ffffffffc0205878:	1008                	addi	a0,sp,32
ffffffffc020587a:	147000ef          	jal	ra,ffffffffc02061c0 <memset>
    memcpy(local_name, name, len);
ffffffffc020587e:	47bd                	li	a5,15
ffffffffc0205880:	8622                	mv	a2,s0
ffffffffc0205882:	0687ee63          	bltu	a5,s0,ffffffffc02058fe <do_execve+0xcc>
ffffffffc0205886:	85ce                	mv	a1,s3
ffffffffc0205888:	1008                	addi	a0,sp,32
ffffffffc020588a:	149000ef          	jal	ra,ffffffffc02061d2 <memcpy>
    if (mm != NULL) {
ffffffffc020588e:	06090f63          	beqz	s2,ffffffffc020590c <do_execve+0xda>
        cputs("mm != NULL");
ffffffffc0205892:	00002517          	auipc	a0,0x2
ffffffffc0205896:	f1e50513          	addi	a0,a0,-226 # ffffffffc02077b0 <commands+0x1050>
ffffffffc020589a:	86dfa0ef          	jal	ra,ffffffffc0200106 <cputs>
        lcr3(boot_cr3);
ffffffffc020589e:	000a7797          	auipc	a5,0xa7
ffffffffc02058a2:	02278793          	addi	a5,a5,34 # ffffffffc02ac8c0 <boot_cr3>
ffffffffc02058a6:	639c                	ld	a5,0(a5)
ffffffffc02058a8:	577d                	li	a4,-1
ffffffffc02058aa:	177e                	slli	a4,a4,0x3f
ffffffffc02058ac:	83b1                	srli	a5,a5,0xc
ffffffffc02058ae:	8fd9                	or	a5,a5,a4
ffffffffc02058b0:	18079073          	csrw	satp,a5
ffffffffc02058b4:	03092783          	lw	a5,48(s2)
ffffffffc02058b8:	fff7871b          	addiw	a4,a5,-1
ffffffffc02058bc:	02e92823          	sw	a4,48(s2)
        if (mm_count_dec(mm) == 0) {
ffffffffc02058c0:	28070e63          	beqz	a4,ffffffffc0205b5c <do_execve+0x32a>
        current->mm = NULL;
ffffffffc02058c4:	000a3783          	ld	a5,0(s4)
ffffffffc02058c8:	0207b423          	sd	zero,40(a5)
    if ((mm = mm_create()) == NULL) {
ffffffffc02058cc:	adffc0ef          	jal	ra,ffffffffc02023aa <mm_create>
ffffffffc02058d0:	892a                	mv	s2,a0
ffffffffc02058d2:	c135                	beqz	a0,ffffffffc0205936 <do_execve+0x104>
    if (setup_pgdir(mm) != 0) {
ffffffffc02058d4:	d96ff0ef          	jal	ra,ffffffffc0204e6a <setup_pgdir>
ffffffffc02058d8:	e931                	bnez	a0,ffffffffc020592c <do_execve+0xfa>
    if (elf->e_magic != ELF_MAGIC) {
ffffffffc02058da:	000b2703          	lw	a4,0(s6)
ffffffffc02058de:	464c47b7          	lui	a5,0x464c4
ffffffffc02058e2:	57f78793          	addi	a5,a5,1407 # 464c457f <_binary_obj___user_exit_out_size+0x464b9ab7>
ffffffffc02058e6:	04f70a63          	beq	a4,a5,ffffffffc020593a <do_execve+0x108>
    put_pgdir(mm);
ffffffffc02058ea:	854a                	mv	a0,s2
ffffffffc02058ec:	d00ff0ef          	jal	ra,ffffffffc0204dec <put_pgdir>
    mm_destroy(mm);
ffffffffc02058f0:	854a                	mv	a0,s2
ffffffffc02058f2:	c3ffc0ef          	jal	ra,ffffffffc0202530 <mm_destroy>
        ret = -E_INVAL_ELF;
ffffffffc02058f6:	59e1                	li	s3,-8
    do_exit(ret);
ffffffffc02058f8:	854e                	mv	a0,s3
ffffffffc02058fa:	b1bff0ef          	jal	ra,ffffffffc0205414 <do_exit>
    memcpy(local_name, name, len);
ffffffffc02058fe:	463d                	li	a2,15
ffffffffc0205900:	85ce                	mv	a1,s3
ffffffffc0205902:	1008                	addi	a0,sp,32
ffffffffc0205904:	0cf000ef          	jal	ra,ffffffffc02061d2 <memcpy>
    if (mm != NULL) {
ffffffffc0205908:	f80915e3          	bnez	s2,ffffffffc0205892 <do_execve+0x60>
    if (current->mm != NULL) {
ffffffffc020590c:	000a3783          	ld	a5,0(s4)
ffffffffc0205910:	779c                	ld	a5,40(a5)
ffffffffc0205912:	dfcd                	beqz	a5,ffffffffc02058cc <do_execve+0x9a>
        panic("load_icode: current->mm must be empty.\n");
ffffffffc0205914:	00003617          	auipc	a2,0x3
ffffffffc0205918:	ab460613          	addi	a2,a2,-1356 # ffffffffc02083c8 <default_pmm_manager+0xa8>
ffffffffc020591c:	21000593          	li	a1,528
ffffffffc0205920:	00003517          	auipc	a0,0x3
ffffffffc0205924:	f0050513          	addi	a0,a0,-256 # ffffffffc0208820 <default_pmm_manager+0x500>
ffffffffc0205928:	8edfa0ef          	jal	ra,ffffffffc0200214 <__panic>
    mm_destroy(mm);
ffffffffc020592c:	854a                	mv	a0,s2
ffffffffc020592e:	c03fc0ef          	jal	ra,ffffffffc0202530 <mm_destroy>
    int ret = -E_NO_MEM;
ffffffffc0205932:	59f1                	li	s3,-4
ffffffffc0205934:	b7d1                	j	ffffffffc02058f8 <do_execve+0xc6>
ffffffffc0205936:	59f1                	li	s3,-4
ffffffffc0205938:	b7c1                	j	ffffffffc02058f8 <do_execve+0xc6>
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc020593a:	038b5703          	lhu	a4,56(s6)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc020593e:	020b3403          	ld	s0,32(s6)
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0205942:	00371793          	slli	a5,a4,0x3
ffffffffc0205946:	8f99                	sub	a5,a5,a4
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0205948:	945a                	add	s0,s0,s6
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc020594a:	078e                	slli	a5,a5,0x3
ffffffffc020594c:	97a2                	add	a5,a5,s0
ffffffffc020594e:	ec3e                	sd	a5,24(sp)
    for (; ph < ph_end; ph ++) {
ffffffffc0205950:	02f47b63          	bgeu	s0,a5,ffffffffc0205986 <do_execve+0x154>
    return KADDR(page2pa(page));
ffffffffc0205954:	5bfd                	li	s7,-1
ffffffffc0205956:	00cbd793          	srli	a5,s7,0xc
    return page - pages + nbase;
ffffffffc020595a:	000a7d97          	auipc	s11,0xa7
ffffffffc020595e:	f6ed8d93          	addi	s11,s11,-146 # ffffffffc02ac8c8 <pages>
ffffffffc0205962:	00003d17          	auipc	s10,0x3
ffffffffc0205966:	386d0d13          	addi	s10,s10,902 # ffffffffc0208ce8 <nbase>
    return KADDR(page2pa(page));
ffffffffc020596a:	e43e                	sd	a5,8(sp)
ffffffffc020596c:	000a7c97          	auipc	s9,0xa7
ffffffffc0205970:	ef4c8c93          	addi	s9,s9,-268 # ffffffffc02ac860 <npage>
        if (ph->p_type != ELF_PT_LOAD) {
ffffffffc0205974:	4018                	lw	a4,0(s0)
ffffffffc0205976:	4785                	li	a5,1
ffffffffc0205978:	0ef70f63          	beq	a4,a5,ffffffffc0205a76 <do_execve+0x244>
    for (; ph < ph_end; ph ++) {
ffffffffc020597c:	67e2                	ld	a5,24(sp)
ffffffffc020597e:	03840413          	addi	s0,s0,56
ffffffffc0205982:	fef469e3          	bltu	s0,a5,ffffffffc0205974 <do_execve+0x142>
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0) {
ffffffffc0205986:	4701                	li	a4,0
ffffffffc0205988:	46ad                	li	a3,11
ffffffffc020598a:	00100637          	lui	a2,0x100
ffffffffc020598e:	7ff005b7          	lui	a1,0x7ff00
ffffffffc0205992:	854a                	mv	a0,s2
ffffffffc0205994:	beffc0ef          	jal	ra,ffffffffc0202582 <mm_map>
ffffffffc0205998:	89aa                	mv	s3,a0
ffffffffc020599a:	1a051763          	bnez	a0,ffffffffc0205b48 <do_execve+0x316>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc020599e:	01893503          	ld	a0,24(s2)
ffffffffc02059a2:	467d                	li	a2,31
ffffffffc02059a4:	7ffff5b7          	lui	a1,0x7ffff
ffffffffc02059a8:	94bfc0ef          	jal	ra,ffffffffc02022f2 <pgdir_alloc_page>
ffffffffc02059ac:	36050263          	beqz	a0,ffffffffc0205d10 <do_execve+0x4de>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc02059b0:	01893503          	ld	a0,24(s2)
ffffffffc02059b4:	467d                	li	a2,31
ffffffffc02059b6:	7fffe5b7          	lui	a1,0x7fffe
ffffffffc02059ba:	939fc0ef          	jal	ra,ffffffffc02022f2 <pgdir_alloc_page>
ffffffffc02059be:	32050963          	beqz	a0,ffffffffc0205cf0 <do_execve+0x4be>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc02059c2:	01893503          	ld	a0,24(s2)
ffffffffc02059c6:	467d                	li	a2,31
ffffffffc02059c8:	7fffd5b7          	lui	a1,0x7fffd
ffffffffc02059cc:	927fc0ef          	jal	ra,ffffffffc02022f2 <pgdir_alloc_page>
ffffffffc02059d0:	30050063          	beqz	a0,ffffffffc0205cd0 <do_execve+0x49e>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc02059d4:	01893503          	ld	a0,24(s2)
ffffffffc02059d8:	467d                	li	a2,31
ffffffffc02059da:	7fffc5b7          	lui	a1,0x7fffc
ffffffffc02059de:	915fc0ef          	jal	ra,ffffffffc02022f2 <pgdir_alloc_page>
ffffffffc02059e2:	2c050763          	beqz	a0,ffffffffc0205cb0 <do_execve+0x47e>
    mm->mm_count += 1;
ffffffffc02059e6:	03092783          	lw	a5,48(s2)
    current->mm = mm;
ffffffffc02059ea:	000a3603          	ld	a2,0(s4)
    current->cr3 = PADDR(mm->pgdir);
ffffffffc02059ee:	01893683          	ld	a3,24(s2)
ffffffffc02059f2:	2785                	addiw	a5,a5,1
ffffffffc02059f4:	02f92823          	sw	a5,48(s2)
    current->mm = mm;
ffffffffc02059f8:	03263423          	sd	s2,40(a2) # 100028 <_binary_obj___user_exit_out_size+0xf5560>
    current->cr3 = PADDR(mm->pgdir);
ffffffffc02059fc:	c02007b7          	lui	a5,0xc0200
ffffffffc0205a00:	28f6ec63          	bltu	a3,a5,ffffffffc0205c98 <do_execve+0x466>
ffffffffc0205a04:	000a7797          	auipc	a5,0xa7
ffffffffc0205a08:	eb478793          	addi	a5,a5,-332 # ffffffffc02ac8b8 <va_pa_offset>
ffffffffc0205a0c:	639c                	ld	a5,0(a5)
ffffffffc0205a0e:	577d                	li	a4,-1
ffffffffc0205a10:	177e                	slli	a4,a4,0x3f
ffffffffc0205a12:	8e9d                	sub	a3,a3,a5
ffffffffc0205a14:	00c6d793          	srli	a5,a3,0xc
ffffffffc0205a18:	f654                	sd	a3,168(a2)
ffffffffc0205a1a:	8fd9                	or	a5,a5,a4
ffffffffc0205a1c:	18079073          	csrw	satp,a5
    struct trapframe *tf = current->tf;
ffffffffc0205a20:	7240                	ld	s0,160(a2)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc0205a22:	4581                	li	a1,0
ffffffffc0205a24:	12000613          	li	a2,288
ffffffffc0205a28:	8522                	mv	a0,s0
ffffffffc0205a2a:	796000ef          	jal	ra,ffffffffc02061c0 <memset>
    tf->epc = elf->e_entry;
ffffffffc0205a2e:	018b3703          	ld	a4,24(s6)
    tf->gpr.sp = USTACKTOP;
ffffffffc0205a32:	4785                	li	a5,1
ffffffffc0205a34:	07fe                	slli	a5,a5,0x1f
ffffffffc0205a36:	e81c                	sd	a5,16(s0)
    tf->epc = elf->e_entry;
ffffffffc0205a38:	10e43423          	sd	a4,264(s0)
    tf->status = (read_csr(sstatus) & ~SSTATUS_SPP) | SSTATUS_SPIE;
ffffffffc0205a3c:	100027f3          	csrr	a5,sstatus
ffffffffc0205a40:	edf7f793          	andi	a5,a5,-289
    set_proc_name(current, local_name);
ffffffffc0205a44:	000a3503          	ld	a0,0(s4)
    tf->status = (read_csr(sstatus) & ~SSTATUS_SPP) | SSTATUS_SPIE;
ffffffffc0205a48:	0207e793          	ori	a5,a5,32
ffffffffc0205a4c:	10f43023          	sd	a5,256(s0)
    set_proc_name(current, local_name);
ffffffffc0205a50:	100c                	addi	a1,sp,32
ffffffffc0205a52:	ca4ff0ef          	jal	ra,ffffffffc0204ef6 <set_proc_name>
}
ffffffffc0205a56:	60ea                	ld	ra,152(sp)
ffffffffc0205a58:	644a                	ld	s0,144(sp)
ffffffffc0205a5a:	854e                	mv	a0,s3
ffffffffc0205a5c:	64aa                	ld	s1,136(sp)
ffffffffc0205a5e:	690a                	ld	s2,128(sp)
ffffffffc0205a60:	79e6                	ld	s3,120(sp)
ffffffffc0205a62:	7a46                	ld	s4,112(sp)
ffffffffc0205a64:	7aa6                	ld	s5,104(sp)
ffffffffc0205a66:	7b06                	ld	s6,96(sp)
ffffffffc0205a68:	6be6                	ld	s7,88(sp)
ffffffffc0205a6a:	6c46                	ld	s8,80(sp)
ffffffffc0205a6c:	6ca6                	ld	s9,72(sp)
ffffffffc0205a6e:	6d06                	ld	s10,64(sp)
ffffffffc0205a70:	7de2                	ld	s11,56(sp)
ffffffffc0205a72:	610d                	addi	sp,sp,160
ffffffffc0205a74:	8082                	ret
        if (ph->p_filesz > ph->p_memsz) {
ffffffffc0205a76:	7410                	ld	a2,40(s0)
ffffffffc0205a78:	701c                	ld	a5,32(s0)
ffffffffc0205a7a:	20f66163          	bltu	a2,a5,ffffffffc0205c7c <do_execve+0x44a>
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
ffffffffc0205a7e:	405c                	lw	a5,4(s0)
ffffffffc0205a80:	0017f693          	andi	a3,a5,1
ffffffffc0205a84:	c291                	beqz	a3,ffffffffc0205a88 <do_execve+0x256>
ffffffffc0205a86:	4691                	li	a3,4
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205a88:	0027f713          	andi	a4,a5,2
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205a8c:	8b91                	andi	a5,a5,4
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205a8e:	0e071163          	bnez	a4,ffffffffc0205b70 <do_execve+0x33e>
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc0205a92:	4745                	li	a4,17
ffffffffc0205a94:	e03a                	sd	a4,0(sp)
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205a96:	c789                	beqz	a5,ffffffffc0205aa0 <do_execve+0x26e>
        if (vm_flags & VM_READ) perm |= PTE_R;
ffffffffc0205a98:	47cd                	li	a5,19
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205a9a:	0016e693          	ori	a3,a3,1
        if (vm_flags & VM_READ) perm |= PTE_R;
ffffffffc0205a9e:	e03e                	sd	a5,0(sp)
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc0205aa0:	0026f793          	andi	a5,a3,2
ffffffffc0205aa4:	ebe9                	bnez	a5,ffffffffc0205b76 <do_execve+0x344>
        if (vm_flags & VM_EXEC) perm |= PTE_X;
ffffffffc0205aa6:	0046f793          	andi	a5,a3,4
ffffffffc0205aaa:	c789                	beqz	a5,ffffffffc0205ab4 <do_execve+0x282>
ffffffffc0205aac:	6782                	ld	a5,0(sp)
ffffffffc0205aae:	0087e793          	ori	a5,a5,8
ffffffffc0205ab2:	e03e                	sd	a5,0(sp)
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0) {
ffffffffc0205ab4:	680c                	ld	a1,16(s0)
ffffffffc0205ab6:	4701                	li	a4,0
ffffffffc0205ab8:	854a                	mv	a0,s2
ffffffffc0205aba:	ac9fc0ef          	jal	ra,ffffffffc0202582 <mm_map>
ffffffffc0205abe:	89aa                	mv	s3,a0
ffffffffc0205ac0:	e541                	bnez	a0,ffffffffc0205b48 <do_execve+0x316>
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205ac2:	01043b83          	ld	s7,16(s0)
        end = ph->p_va + ph->p_filesz;
ffffffffc0205ac6:	02043983          	ld	s3,32(s0)
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205aca:	00843a83          	ld	s5,8(s0)
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205ace:	77fd                	lui	a5,0xfffff
        end = ph->p_va + ph->p_filesz;
ffffffffc0205ad0:	99de                	add	s3,s3,s7
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205ad2:	9ada                	add	s5,s5,s6
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205ad4:	00fbfc33          	and	s8,s7,a5
        while (start < end) {
ffffffffc0205ad8:	053bef63          	bltu	s7,s3,ffffffffc0205b36 <do_execve+0x304>
ffffffffc0205adc:	aa61                	j	ffffffffc0205c74 <do_execve+0x442>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205ade:	6785                	lui	a5,0x1
ffffffffc0205ae0:	418b8533          	sub	a0,s7,s8
ffffffffc0205ae4:	9c3e                	add	s8,s8,a5
ffffffffc0205ae6:	417c0833          	sub	a6,s8,s7
            if (end < la) {
ffffffffc0205aea:	0189f463          	bgeu	s3,s8,ffffffffc0205af2 <do_execve+0x2c0>
                size -= la - end;
ffffffffc0205aee:	41798833          	sub	a6,s3,s7
    return page - pages + nbase;
ffffffffc0205af2:	000db683          	ld	a3,0(s11)
ffffffffc0205af6:	000d3583          	ld	a1,0(s10)
    return KADDR(page2pa(page));
ffffffffc0205afa:	67a2                	ld	a5,8(sp)
    return page - pages + nbase;
ffffffffc0205afc:	40d486b3          	sub	a3,s1,a3
ffffffffc0205b00:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0205b02:	000cb603          	ld	a2,0(s9)
    return page - pages + nbase;
ffffffffc0205b06:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc0205b08:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205b0c:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205b0e:	16c5f963          	bgeu	a1,a2,ffffffffc0205c80 <do_execve+0x44e>
ffffffffc0205b12:	000a7797          	auipc	a5,0xa7
ffffffffc0205b16:	da678793          	addi	a5,a5,-602 # ffffffffc02ac8b8 <va_pa_offset>
ffffffffc0205b1a:	0007b883          	ld	a7,0(a5)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205b1e:	85d6                	mv	a1,s5
ffffffffc0205b20:	8642                	mv	a2,a6
ffffffffc0205b22:	96c6                	add	a3,a3,a7
ffffffffc0205b24:	9536                	add	a0,a0,a3
            start += size, from += size;
ffffffffc0205b26:	9bc2                	add	s7,s7,a6
ffffffffc0205b28:	e842                	sd	a6,16(sp)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205b2a:	6a8000ef          	jal	ra,ffffffffc02061d2 <memcpy>
            start += size, from += size;
ffffffffc0205b2e:	6842                	ld	a6,16(sp)
ffffffffc0205b30:	9ac2                	add	s5,s5,a6
        while (start < end) {
ffffffffc0205b32:	053bf563          	bgeu	s7,s3,ffffffffc0205b7c <do_execve+0x34a>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc0205b36:	01893503          	ld	a0,24(s2)
ffffffffc0205b3a:	6602                	ld	a2,0(sp)
ffffffffc0205b3c:	85e2                	mv	a1,s8
ffffffffc0205b3e:	fb4fc0ef          	jal	ra,ffffffffc02022f2 <pgdir_alloc_page>
ffffffffc0205b42:	84aa                	mv	s1,a0
ffffffffc0205b44:	fd49                	bnez	a0,ffffffffc0205ade <do_execve+0x2ac>
        ret = -E_NO_MEM;
ffffffffc0205b46:	59f1                	li	s3,-4
    exit_mmap(mm);
ffffffffc0205b48:	854a                	mv	a0,s2
ffffffffc0205b4a:	b87fc0ef          	jal	ra,ffffffffc02026d0 <exit_mmap>
    put_pgdir(mm);
ffffffffc0205b4e:	854a                	mv	a0,s2
ffffffffc0205b50:	a9cff0ef          	jal	ra,ffffffffc0204dec <put_pgdir>
    mm_destroy(mm);
ffffffffc0205b54:	854a                	mv	a0,s2
ffffffffc0205b56:	9dbfc0ef          	jal	ra,ffffffffc0202530 <mm_destroy>
    return ret;
ffffffffc0205b5a:	bb79                	j	ffffffffc02058f8 <do_execve+0xc6>
            exit_mmap(mm);
ffffffffc0205b5c:	854a                	mv	a0,s2
ffffffffc0205b5e:	b73fc0ef          	jal	ra,ffffffffc02026d0 <exit_mmap>
            put_pgdir(mm);
ffffffffc0205b62:	854a                	mv	a0,s2
ffffffffc0205b64:	a88ff0ef          	jal	ra,ffffffffc0204dec <put_pgdir>
            mm_destroy(mm);
ffffffffc0205b68:	854a                	mv	a0,s2
ffffffffc0205b6a:	9c7fc0ef          	jal	ra,ffffffffc0202530 <mm_destroy>
ffffffffc0205b6e:	bb99                	j	ffffffffc02058c4 <do_execve+0x92>
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205b70:	0026e693          	ori	a3,a3,2
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205b74:	f395                	bnez	a5,ffffffffc0205a98 <do_execve+0x266>
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc0205b76:	47dd                	li	a5,23
ffffffffc0205b78:	e03e                	sd	a5,0(sp)
ffffffffc0205b7a:	b735                	j	ffffffffc0205aa6 <do_execve+0x274>
ffffffffc0205b7c:	01043983          	ld	s3,16(s0)
        end = ph->p_va + ph->p_memsz;
ffffffffc0205b80:	7414                	ld	a3,40(s0)
ffffffffc0205b82:	99b6                	add	s3,s3,a3
        if (start < la) {
ffffffffc0205b84:	098bf163          	bgeu	s7,s8,ffffffffc0205c06 <do_execve+0x3d4>
            if (start == end) {
ffffffffc0205b88:	df798ae3          	beq	s3,s7,ffffffffc020597c <do_execve+0x14a>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0205b8c:	6505                	lui	a0,0x1
ffffffffc0205b8e:	955e                	add	a0,a0,s7
ffffffffc0205b90:	41850533          	sub	a0,a0,s8
                size -= la - end;
ffffffffc0205b94:	41798ab3          	sub	s5,s3,s7
            if (end < la) {
ffffffffc0205b98:	0d89fb63          	bgeu	s3,s8,ffffffffc0205c6e <do_execve+0x43c>
    return page - pages + nbase;
ffffffffc0205b9c:	000db683          	ld	a3,0(s11)
ffffffffc0205ba0:	000d3583          	ld	a1,0(s10)
    return KADDR(page2pa(page));
ffffffffc0205ba4:	67a2                	ld	a5,8(sp)
    return page - pages + nbase;
ffffffffc0205ba6:	40d486b3          	sub	a3,s1,a3
ffffffffc0205baa:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0205bac:	000cb603          	ld	a2,0(s9)
    return page - pages + nbase;
ffffffffc0205bb0:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc0205bb2:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205bb6:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205bb8:	0cc5f463          	bgeu	a1,a2,ffffffffc0205c80 <do_execve+0x44e>
ffffffffc0205bbc:	000a7617          	auipc	a2,0xa7
ffffffffc0205bc0:	cfc60613          	addi	a2,a2,-772 # ffffffffc02ac8b8 <va_pa_offset>
ffffffffc0205bc4:	00063803          	ld	a6,0(a2)
            memset(page2kva(page) + off, 0, size);
ffffffffc0205bc8:	4581                	li	a1,0
ffffffffc0205bca:	8656                	mv	a2,s5
ffffffffc0205bcc:	96c2                	add	a3,a3,a6
ffffffffc0205bce:	9536                	add	a0,a0,a3
ffffffffc0205bd0:	5f0000ef          	jal	ra,ffffffffc02061c0 <memset>
            start += size;
ffffffffc0205bd4:	017a8733          	add	a4,s5,s7
            assert((end < la && start == end) || (end >= la && start == la));
ffffffffc0205bd8:	0389f463          	bgeu	s3,s8,ffffffffc0205c00 <do_execve+0x3ce>
ffffffffc0205bdc:	dae980e3          	beq	s3,a4,ffffffffc020597c <do_execve+0x14a>
ffffffffc0205be0:	00003697          	auipc	a3,0x3
ffffffffc0205be4:	81068693          	addi	a3,a3,-2032 # ffffffffc02083f0 <default_pmm_manager+0xd0>
ffffffffc0205be8:	00001617          	auipc	a2,0x1
ffffffffc0205bec:	ff860613          	addi	a2,a2,-8 # ffffffffc0206be0 <commands+0x480>
ffffffffc0205bf0:	26500593          	li	a1,613
ffffffffc0205bf4:	00003517          	auipc	a0,0x3
ffffffffc0205bf8:	c2c50513          	addi	a0,a0,-980 # ffffffffc0208820 <default_pmm_manager+0x500>
ffffffffc0205bfc:	e18fa0ef          	jal	ra,ffffffffc0200214 <__panic>
ffffffffc0205c00:	ff8710e3          	bne	a4,s8,ffffffffc0205be0 <do_execve+0x3ae>
ffffffffc0205c04:	8be2                	mv	s7,s8
ffffffffc0205c06:	000a7a97          	auipc	s5,0xa7
ffffffffc0205c0a:	cb2a8a93          	addi	s5,s5,-846 # ffffffffc02ac8b8 <va_pa_offset>
        while (start < end) {
ffffffffc0205c0e:	053be763          	bltu	s7,s3,ffffffffc0205c5c <do_execve+0x42a>
ffffffffc0205c12:	b3ad                	j	ffffffffc020597c <do_execve+0x14a>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205c14:	6785                	lui	a5,0x1
ffffffffc0205c16:	418b8533          	sub	a0,s7,s8
ffffffffc0205c1a:	9c3e                	add	s8,s8,a5
ffffffffc0205c1c:	417c0633          	sub	a2,s8,s7
            if (end < la) {
ffffffffc0205c20:	0189f463          	bgeu	s3,s8,ffffffffc0205c28 <do_execve+0x3f6>
                size -= la - end;
ffffffffc0205c24:	41798633          	sub	a2,s3,s7
    return page - pages + nbase;
ffffffffc0205c28:	000db683          	ld	a3,0(s11)
ffffffffc0205c2c:	000d3803          	ld	a6,0(s10)
    return KADDR(page2pa(page));
ffffffffc0205c30:	67a2                	ld	a5,8(sp)
    return page - pages + nbase;
ffffffffc0205c32:	40d486b3          	sub	a3,s1,a3
ffffffffc0205c36:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0205c38:	000cb583          	ld	a1,0(s9)
    return page - pages + nbase;
ffffffffc0205c3c:	96c2                	add	a3,a3,a6
    return KADDR(page2pa(page));
ffffffffc0205c3e:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205c42:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205c44:	02b87e63          	bgeu	a6,a1,ffffffffc0205c80 <do_execve+0x44e>
ffffffffc0205c48:	000ab803          	ld	a6,0(s5)
            start += size;
ffffffffc0205c4c:	9bb2                	add	s7,s7,a2
            memset(page2kva(page) + off, 0, size);
ffffffffc0205c4e:	4581                	li	a1,0
ffffffffc0205c50:	96c2                	add	a3,a3,a6
ffffffffc0205c52:	9536                	add	a0,a0,a3
ffffffffc0205c54:	56c000ef          	jal	ra,ffffffffc02061c0 <memset>
        while (start < end) {
ffffffffc0205c58:	d33bf2e3          	bgeu	s7,s3,ffffffffc020597c <do_execve+0x14a>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc0205c5c:	01893503          	ld	a0,24(s2)
ffffffffc0205c60:	6602                	ld	a2,0(sp)
ffffffffc0205c62:	85e2                	mv	a1,s8
ffffffffc0205c64:	e8efc0ef          	jal	ra,ffffffffc02022f2 <pgdir_alloc_page>
ffffffffc0205c68:	84aa                	mv	s1,a0
ffffffffc0205c6a:	f54d                	bnez	a0,ffffffffc0205c14 <do_execve+0x3e2>
ffffffffc0205c6c:	bde9                	j	ffffffffc0205b46 <do_execve+0x314>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0205c6e:	417c0ab3          	sub	s5,s8,s7
ffffffffc0205c72:	b72d                	j	ffffffffc0205b9c <do_execve+0x36a>
        while (start < end) {
ffffffffc0205c74:	89de                	mv	s3,s7
ffffffffc0205c76:	b729                	j	ffffffffc0205b80 <do_execve+0x34e>
        return -E_INVAL;
ffffffffc0205c78:	59f5                	li	s3,-3
ffffffffc0205c7a:	bbf1                	j	ffffffffc0205a56 <do_execve+0x224>
            ret = -E_INVAL_ELF;
ffffffffc0205c7c:	59e1                	li	s3,-8
ffffffffc0205c7e:	b5e9                	j	ffffffffc0205b48 <do_execve+0x316>
ffffffffc0205c80:	00001617          	auipc	a2,0x1
ffffffffc0205c84:	34860613          	addi	a2,a2,840 # ffffffffc0206fc8 <commands+0x868>
ffffffffc0205c88:	06900593          	li	a1,105
ffffffffc0205c8c:	00001517          	auipc	a0,0x1
ffffffffc0205c90:	39450513          	addi	a0,a0,916 # ffffffffc0207020 <commands+0x8c0>
ffffffffc0205c94:	d80fa0ef          	jal	ra,ffffffffc0200214 <__panic>
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205c98:	00001617          	auipc	a2,0x1
ffffffffc0205c9c:	40860613          	addi	a2,a2,1032 # ffffffffc02070a0 <commands+0x940>
ffffffffc0205ca0:	28000593          	li	a1,640
ffffffffc0205ca4:	00003517          	auipc	a0,0x3
ffffffffc0205ca8:	b7c50513          	addi	a0,a0,-1156 # ffffffffc0208820 <default_pmm_manager+0x500>
ffffffffc0205cac:	d68fa0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc0205cb0:	00003697          	auipc	a3,0x3
ffffffffc0205cb4:	85868693          	addi	a3,a3,-1960 # ffffffffc0208508 <default_pmm_manager+0x1e8>
ffffffffc0205cb8:	00001617          	auipc	a2,0x1
ffffffffc0205cbc:	f2860613          	addi	a2,a2,-216 # ffffffffc0206be0 <commands+0x480>
ffffffffc0205cc0:	27b00593          	li	a1,635
ffffffffc0205cc4:	00003517          	auipc	a0,0x3
ffffffffc0205cc8:	b5c50513          	addi	a0,a0,-1188 # ffffffffc0208820 <default_pmm_manager+0x500>
ffffffffc0205ccc:	d48fa0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc0205cd0:	00002697          	auipc	a3,0x2
ffffffffc0205cd4:	7f068693          	addi	a3,a3,2032 # ffffffffc02084c0 <default_pmm_manager+0x1a0>
ffffffffc0205cd8:	00001617          	auipc	a2,0x1
ffffffffc0205cdc:	f0860613          	addi	a2,a2,-248 # ffffffffc0206be0 <commands+0x480>
ffffffffc0205ce0:	27a00593          	li	a1,634
ffffffffc0205ce4:	00003517          	auipc	a0,0x3
ffffffffc0205ce8:	b3c50513          	addi	a0,a0,-1220 # ffffffffc0208820 <default_pmm_manager+0x500>
ffffffffc0205cec:	d28fa0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc0205cf0:	00002697          	auipc	a3,0x2
ffffffffc0205cf4:	78868693          	addi	a3,a3,1928 # ffffffffc0208478 <default_pmm_manager+0x158>
ffffffffc0205cf8:	00001617          	auipc	a2,0x1
ffffffffc0205cfc:	ee860613          	addi	a2,a2,-280 # ffffffffc0206be0 <commands+0x480>
ffffffffc0205d00:	27900593          	li	a1,633
ffffffffc0205d04:	00003517          	auipc	a0,0x3
ffffffffc0205d08:	b1c50513          	addi	a0,a0,-1252 # ffffffffc0208820 <default_pmm_manager+0x500>
ffffffffc0205d0c:	d08fa0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc0205d10:	00002697          	auipc	a3,0x2
ffffffffc0205d14:	72068693          	addi	a3,a3,1824 # ffffffffc0208430 <default_pmm_manager+0x110>
ffffffffc0205d18:	00001617          	auipc	a2,0x1
ffffffffc0205d1c:	ec860613          	addi	a2,a2,-312 # ffffffffc0206be0 <commands+0x480>
ffffffffc0205d20:	27800593          	li	a1,632
ffffffffc0205d24:	00003517          	auipc	a0,0x3
ffffffffc0205d28:	afc50513          	addi	a0,a0,-1284 # ffffffffc0208820 <default_pmm_manager+0x500>
ffffffffc0205d2c:	ce8fa0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0205d30 <do_yield>:
    current->need_resched = 1;
ffffffffc0205d30:	000a7797          	auipc	a5,0xa7
ffffffffc0205d34:	b5878793          	addi	a5,a5,-1192 # ffffffffc02ac888 <current>
ffffffffc0205d38:	639c                	ld	a5,0(a5)
ffffffffc0205d3a:	4705                	li	a4,1
}
ffffffffc0205d3c:	4501                	li	a0,0
    current->need_resched = 1;
ffffffffc0205d3e:	ef98                	sd	a4,24(a5)
}
ffffffffc0205d40:	8082                	ret

ffffffffc0205d42 <do_wait>:
do_wait(int pid, int *code_store) {
ffffffffc0205d42:	1101                	addi	sp,sp,-32
ffffffffc0205d44:	e822                	sd	s0,16(sp)
ffffffffc0205d46:	e426                	sd	s1,8(sp)
ffffffffc0205d48:	ec06                	sd	ra,24(sp)
ffffffffc0205d4a:	842e                	mv	s0,a1
ffffffffc0205d4c:	84aa                	mv	s1,a0
    if (code_store != NULL) {
ffffffffc0205d4e:	cd81                	beqz	a1,ffffffffc0205d66 <do_wait+0x24>
    struct mm_struct *mm = current->mm;
ffffffffc0205d50:	000a7797          	auipc	a5,0xa7
ffffffffc0205d54:	b3878793          	addi	a5,a5,-1224 # ffffffffc02ac888 <current>
ffffffffc0205d58:	639c                	ld	a5,0(a5)
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1)) {
ffffffffc0205d5a:	4685                	li	a3,1
ffffffffc0205d5c:	4611                	li	a2,4
ffffffffc0205d5e:	7788                	ld	a0,40(a5)
ffffffffc0205d60:	834fd0ef          	jal	ra,ffffffffc0202d94 <user_mem_check>
ffffffffc0205d64:	c909                	beqz	a0,ffffffffc0205d76 <do_wait+0x34>
ffffffffc0205d66:	85a2                	mv	a1,s0
}
ffffffffc0205d68:	6442                	ld	s0,16(sp)
ffffffffc0205d6a:	60e2                	ld	ra,24(sp)
ffffffffc0205d6c:	8526                	mv	a0,s1
ffffffffc0205d6e:	64a2                	ld	s1,8(sp)
ffffffffc0205d70:	6105                	addi	sp,sp,32
ffffffffc0205d72:	ff0ff06f          	j	ffffffffc0205562 <do_wait.part.1>
ffffffffc0205d76:	60e2                	ld	ra,24(sp)
ffffffffc0205d78:	6442                	ld	s0,16(sp)
ffffffffc0205d7a:	64a2                	ld	s1,8(sp)
ffffffffc0205d7c:	5575                	li	a0,-3
ffffffffc0205d7e:	6105                	addi	sp,sp,32
ffffffffc0205d80:	8082                	ret

ffffffffc0205d82 <do_kill>:
do_kill(int pid) {
ffffffffc0205d82:	1141                	addi	sp,sp,-16
ffffffffc0205d84:	e406                	sd	ra,8(sp)
ffffffffc0205d86:	e022                	sd	s0,0(sp)
    if ((proc = find_proc(pid)) != NULL) {
ffffffffc0205d88:	a04ff0ef          	jal	ra,ffffffffc0204f8c <find_proc>
ffffffffc0205d8c:	cd0d                	beqz	a0,ffffffffc0205dc6 <do_kill+0x44>
        if (!(proc->flags & PF_EXITING)) {
ffffffffc0205d8e:	0b052703          	lw	a4,176(a0)
ffffffffc0205d92:	00177693          	andi	a3,a4,1
ffffffffc0205d96:	e695                	bnez	a3,ffffffffc0205dc2 <do_kill+0x40>
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205d98:	0ec52683          	lw	a3,236(a0)
            proc->flags |= PF_EXITING;
ffffffffc0205d9c:	00176713          	ori	a4,a4,1
ffffffffc0205da0:	0ae52823          	sw	a4,176(a0)
            return 0;
ffffffffc0205da4:	4401                	li	s0,0
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205da6:	0006c763          	bltz	a3,ffffffffc0205db4 <do_kill+0x32>
}
ffffffffc0205daa:	8522                	mv	a0,s0
ffffffffc0205dac:	60a2                	ld	ra,8(sp)
ffffffffc0205dae:	6402                	ld	s0,0(sp)
ffffffffc0205db0:	0141                	addi	sp,sp,16
ffffffffc0205db2:	8082                	ret
                wakeup_proc(proc);
ffffffffc0205db4:	17c000ef          	jal	ra,ffffffffc0205f30 <wakeup_proc>
}
ffffffffc0205db8:	8522                	mv	a0,s0
ffffffffc0205dba:	60a2                	ld	ra,8(sp)
ffffffffc0205dbc:	6402                	ld	s0,0(sp)
ffffffffc0205dbe:	0141                	addi	sp,sp,16
ffffffffc0205dc0:	8082                	ret
        return -E_KILLED;
ffffffffc0205dc2:	545d                	li	s0,-9
ffffffffc0205dc4:	b7dd                	j	ffffffffc0205daa <do_kill+0x28>
    return -E_INVAL;
ffffffffc0205dc6:	5475                	li	s0,-3
ffffffffc0205dc8:	b7cd                	j	ffffffffc0205daa <do_kill+0x28>

ffffffffc0205dca <proc_init>:
    elm->prev = elm->next = elm;
ffffffffc0205dca:	000a7797          	auipc	a5,0xa7
ffffffffc0205dce:	bfe78793          	addi	a5,a5,-1026 # ffffffffc02ac9c8 <proc_list>

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
ffffffffc0205dd2:	1101                	addi	sp,sp,-32
ffffffffc0205dd4:	000a7717          	auipc	a4,0xa7
ffffffffc0205dd8:	bef73e23          	sd	a5,-1028(a4) # ffffffffc02ac9d0 <proc_list+0x8>
ffffffffc0205ddc:	000a7717          	auipc	a4,0xa7
ffffffffc0205de0:	bef73623          	sd	a5,-1044(a4) # ffffffffc02ac9c8 <proc_list>
ffffffffc0205de4:	ec06                	sd	ra,24(sp)
ffffffffc0205de6:	e822                	sd	s0,16(sp)
ffffffffc0205de8:	e426                	sd	s1,8(sp)
ffffffffc0205dea:	000a3797          	auipc	a5,0xa3
ffffffffc0205dee:	a5e78793          	addi	a5,a5,-1442 # ffffffffc02a8848 <hash_list>
ffffffffc0205df2:	000a7717          	auipc	a4,0xa7
ffffffffc0205df6:	a5670713          	addi	a4,a4,-1450 # ffffffffc02ac848 <is_panic>
ffffffffc0205dfa:	e79c                	sd	a5,8(a5)
ffffffffc0205dfc:	e39c                	sd	a5,0(a5)
ffffffffc0205dfe:	07c1                	addi	a5,a5,16
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
ffffffffc0205e00:	fee79de3          	bne	a5,a4,ffffffffc0205dfa <proc_init+0x30>
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) {
ffffffffc0205e04:	ee3fe0ef          	jal	ra,ffffffffc0204ce6 <alloc_proc>
ffffffffc0205e08:	000a7717          	auipc	a4,0xa7
ffffffffc0205e0c:	a8a73423          	sd	a0,-1400(a4) # ffffffffc02ac890 <idleproc>
ffffffffc0205e10:	000a7497          	auipc	s1,0xa7
ffffffffc0205e14:	a8048493          	addi	s1,s1,-1408 # ffffffffc02ac890 <idleproc>
ffffffffc0205e18:	c559                	beqz	a0,ffffffffc0205ea6 <proc_init+0xdc>
        panic("cannot alloc idleproc.\n");
    }

    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc0205e1a:	4709                	li	a4,2
ffffffffc0205e1c:	e118                	sd	a4,0(a0)
    idleproc->kstack = (uintptr_t)bootstack;
    idleproc->need_resched = 1;
ffffffffc0205e1e:	4405                	li	s0,1
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205e20:	00003717          	auipc	a4,0x3
ffffffffc0205e24:	1e070713          	addi	a4,a4,480 # ffffffffc0209000 <bootstack>
    set_proc_name(idleproc, "idle");
ffffffffc0205e28:	00003597          	auipc	a1,0x3
ffffffffc0205e2c:	91058593          	addi	a1,a1,-1776 # ffffffffc0208738 <default_pmm_manager+0x418>
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205e30:	e918                	sd	a4,16(a0)
    idleproc->need_resched = 1;
ffffffffc0205e32:	ed00                	sd	s0,24(a0)
    set_proc_name(idleproc, "idle");
ffffffffc0205e34:	8c2ff0ef          	jal	ra,ffffffffc0204ef6 <set_proc_name>
    nr_process ++;
ffffffffc0205e38:	000a7797          	auipc	a5,0xa7
ffffffffc0205e3c:	a6878793          	addi	a5,a5,-1432 # ffffffffc02ac8a0 <nr_process>
ffffffffc0205e40:	439c                	lw	a5,0(a5)

    current = idleproc;
ffffffffc0205e42:	6098                	ld	a4,0(s1)

    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205e44:	4601                	li	a2,0
    nr_process ++;
ffffffffc0205e46:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205e48:	4581                	li	a1,0
ffffffffc0205e4a:	00000517          	auipc	a0,0x0
ffffffffc0205e4e:	8c050513          	addi	a0,a0,-1856 # ffffffffc020570a <init_main>
    nr_process ++;
ffffffffc0205e52:	000a7697          	auipc	a3,0xa7
ffffffffc0205e56:	a4f6a723          	sw	a5,-1458(a3) # ffffffffc02ac8a0 <nr_process>
    current = idleproc;
ffffffffc0205e5a:	000a7797          	auipc	a5,0xa7
ffffffffc0205e5e:	a2e7b723          	sd	a4,-1490(a5) # ffffffffc02ac888 <current>
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205e62:	d62ff0ef          	jal	ra,ffffffffc02053c4 <kernel_thread>
    if (pid <= 0) {
ffffffffc0205e66:	08a05c63          	blez	a0,ffffffffc0205efe <proc_init+0x134>
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc0205e6a:	922ff0ef          	jal	ra,ffffffffc0204f8c <find_proc>
    set_proc_name(initproc, "init");
ffffffffc0205e6e:	00003597          	auipc	a1,0x3
ffffffffc0205e72:	8f258593          	addi	a1,a1,-1806 # ffffffffc0208760 <default_pmm_manager+0x440>
    initproc = find_proc(pid);
ffffffffc0205e76:	000a7797          	auipc	a5,0xa7
ffffffffc0205e7a:	a2a7b123          	sd	a0,-1502(a5) # ffffffffc02ac898 <initproc>
    set_proc_name(initproc, "init");
ffffffffc0205e7e:	878ff0ef          	jal	ra,ffffffffc0204ef6 <set_proc_name>

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205e82:	609c                	ld	a5,0(s1)
ffffffffc0205e84:	cfa9                	beqz	a5,ffffffffc0205ede <proc_init+0x114>
ffffffffc0205e86:	43dc                	lw	a5,4(a5)
ffffffffc0205e88:	ebb9                	bnez	a5,ffffffffc0205ede <proc_init+0x114>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205e8a:	000a7797          	auipc	a5,0xa7
ffffffffc0205e8e:	a0e78793          	addi	a5,a5,-1522 # ffffffffc02ac898 <initproc>
ffffffffc0205e92:	639c                	ld	a5,0(a5)
ffffffffc0205e94:	c78d                	beqz	a5,ffffffffc0205ebe <proc_init+0xf4>
ffffffffc0205e96:	43dc                	lw	a5,4(a5)
ffffffffc0205e98:	02879363          	bne	a5,s0,ffffffffc0205ebe <proc_init+0xf4>
}
ffffffffc0205e9c:	60e2                	ld	ra,24(sp)
ffffffffc0205e9e:	6442                	ld	s0,16(sp)
ffffffffc0205ea0:	64a2                	ld	s1,8(sp)
ffffffffc0205ea2:	6105                	addi	sp,sp,32
ffffffffc0205ea4:	8082                	ret
        panic("cannot alloc idleproc.\n");
ffffffffc0205ea6:	00003617          	auipc	a2,0x3
ffffffffc0205eaa:	87a60613          	addi	a2,a2,-1926 # ffffffffc0208720 <default_pmm_manager+0x400>
ffffffffc0205eae:	37c00593          	li	a1,892
ffffffffc0205eb2:	00003517          	auipc	a0,0x3
ffffffffc0205eb6:	96e50513          	addi	a0,a0,-1682 # ffffffffc0208820 <default_pmm_manager+0x500>
ffffffffc0205eba:	b5afa0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205ebe:	00003697          	auipc	a3,0x3
ffffffffc0205ec2:	8d268693          	addi	a3,a3,-1838 # ffffffffc0208790 <default_pmm_manager+0x470>
ffffffffc0205ec6:	00001617          	auipc	a2,0x1
ffffffffc0205eca:	d1a60613          	addi	a2,a2,-742 # ffffffffc0206be0 <commands+0x480>
ffffffffc0205ece:	39100593          	li	a1,913
ffffffffc0205ed2:	00003517          	auipc	a0,0x3
ffffffffc0205ed6:	94e50513          	addi	a0,a0,-1714 # ffffffffc0208820 <default_pmm_manager+0x500>
ffffffffc0205eda:	b3afa0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205ede:	00003697          	auipc	a3,0x3
ffffffffc0205ee2:	88a68693          	addi	a3,a3,-1910 # ffffffffc0208768 <default_pmm_manager+0x448>
ffffffffc0205ee6:	00001617          	auipc	a2,0x1
ffffffffc0205eea:	cfa60613          	addi	a2,a2,-774 # ffffffffc0206be0 <commands+0x480>
ffffffffc0205eee:	39000593          	li	a1,912
ffffffffc0205ef2:	00003517          	auipc	a0,0x3
ffffffffc0205ef6:	92e50513          	addi	a0,a0,-1746 # ffffffffc0208820 <default_pmm_manager+0x500>
ffffffffc0205efa:	b1afa0ef          	jal	ra,ffffffffc0200214 <__panic>
        panic("create init_main failed.\n");
ffffffffc0205efe:	00003617          	auipc	a2,0x3
ffffffffc0205f02:	84260613          	addi	a2,a2,-1982 # ffffffffc0208740 <default_pmm_manager+0x420>
ffffffffc0205f06:	38a00593          	li	a1,906
ffffffffc0205f0a:	00003517          	auipc	a0,0x3
ffffffffc0205f0e:	91650513          	addi	a0,a0,-1770 # ffffffffc0208820 <default_pmm_manager+0x500>
ffffffffc0205f12:	b02fa0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0205f16 <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
ffffffffc0205f16:	1141                	addi	sp,sp,-16
ffffffffc0205f18:	e022                	sd	s0,0(sp)
ffffffffc0205f1a:	e406                	sd	ra,8(sp)
ffffffffc0205f1c:	000a7417          	auipc	s0,0xa7
ffffffffc0205f20:	96c40413          	addi	s0,s0,-1684 # ffffffffc02ac888 <current>
    while (1) {
        if (current->need_resched) {
ffffffffc0205f24:	6018                	ld	a4,0(s0)
ffffffffc0205f26:	6f1c                	ld	a5,24(a4)
ffffffffc0205f28:	dffd                	beqz	a5,ffffffffc0205f26 <cpu_idle+0x10>
            schedule();
ffffffffc0205f2a:	082000ef          	jal	ra,ffffffffc0205fac <schedule>
ffffffffc0205f2e:	bfdd                	j	ffffffffc0205f24 <cpu_idle+0xe>

ffffffffc0205f30 <wakeup_proc>:
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205f30:	4118                	lw	a4,0(a0)
wakeup_proc(struct proc_struct *proc) {
ffffffffc0205f32:	1101                	addi	sp,sp,-32
ffffffffc0205f34:	ec06                	sd	ra,24(sp)
ffffffffc0205f36:	e822                	sd	s0,16(sp)
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205f38:	478d                	li	a5,3
ffffffffc0205f3a:	04f70a63          	beq	a4,a5,ffffffffc0205f8e <wakeup_proc+0x5e>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205f3e:	100027f3          	csrr	a5,sstatus
ffffffffc0205f42:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205f44:	4401                	li	s0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205f46:	ef8d                	bnez	a5,ffffffffc0205f80 <wakeup_proc+0x50>
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        if (proc->state != PROC_RUNNABLE) {
ffffffffc0205f48:	4789                	li	a5,2
ffffffffc0205f4a:	00f70f63          	beq	a4,a5,ffffffffc0205f68 <wakeup_proc+0x38>
            proc->state = PROC_RUNNABLE;
ffffffffc0205f4e:	c11c                	sw	a5,0(a0)
            proc->wait_state = 0;
ffffffffc0205f50:	0e052623          	sw	zero,236(a0)
    if (flag) {
ffffffffc0205f54:	e409                	bnez	s0,ffffffffc0205f5e <wakeup_proc+0x2e>
        else {
            warn("wakeup runnable process.\n");
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0205f56:	60e2                	ld	ra,24(sp)
ffffffffc0205f58:	6442                	ld	s0,16(sp)
ffffffffc0205f5a:	6105                	addi	sp,sp,32
ffffffffc0205f5c:	8082                	ret
ffffffffc0205f5e:	6442                	ld	s0,16(sp)
ffffffffc0205f60:	60e2                	ld	ra,24(sp)
ffffffffc0205f62:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0205f64:	eeafa06f          	j	ffffffffc020064e <intr_enable>
            warn("wakeup runnable process.\n");
ffffffffc0205f68:	00003617          	auipc	a2,0x3
ffffffffc0205f6c:	90860613          	addi	a2,a2,-1784 # ffffffffc0208870 <default_pmm_manager+0x550>
ffffffffc0205f70:	45c9                	li	a1,18
ffffffffc0205f72:	00003517          	auipc	a0,0x3
ffffffffc0205f76:	8e650513          	addi	a0,a0,-1818 # ffffffffc0208858 <default_pmm_manager+0x538>
ffffffffc0205f7a:	b06fa0ef          	jal	ra,ffffffffc0200280 <__warn>
ffffffffc0205f7e:	bfd9                	j	ffffffffc0205f54 <wakeup_proc+0x24>
ffffffffc0205f80:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0205f82:	ed2fa0ef          	jal	ra,ffffffffc0200654 <intr_disable>
        return 1;
ffffffffc0205f86:	6522                	ld	a0,8(sp)
ffffffffc0205f88:	4405                	li	s0,1
ffffffffc0205f8a:	4118                	lw	a4,0(a0)
ffffffffc0205f8c:	bf75                	j	ffffffffc0205f48 <wakeup_proc+0x18>
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205f8e:	00003697          	auipc	a3,0x3
ffffffffc0205f92:	8aa68693          	addi	a3,a3,-1878 # ffffffffc0208838 <default_pmm_manager+0x518>
ffffffffc0205f96:	00001617          	auipc	a2,0x1
ffffffffc0205f9a:	c4a60613          	addi	a2,a2,-950 # ffffffffc0206be0 <commands+0x480>
ffffffffc0205f9e:	45a5                	li	a1,9
ffffffffc0205fa0:	00003517          	auipc	a0,0x3
ffffffffc0205fa4:	8b850513          	addi	a0,a0,-1864 # ffffffffc0208858 <default_pmm_manager+0x538>
ffffffffc0205fa8:	a6cfa0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0205fac <schedule>:

void
schedule(void) {
ffffffffc0205fac:	1141                	addi	sp,sp,-16
ffffffffc0205fae:	e406                	sd	ra,8(sp)
ffffffffc0205fb0:	e022                	sd	s0,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205fb2:	100027f3          	csrr	a5,sstatus
ffffffffc0205fb6:	8b89                	andi	a5,a5,2
ffffffffc0205fb8:	4401                	li	s0,0
ffffffffc0205fba:	e3d1                	bnez	a5,ffffffffc020603e <schedule+0x92>
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc0205fbc:	000a7797          	auipc	a5,0xa7
ffffffffc0205fc0:	8cc78793          	addi	a5,a5,-1844 # ffffffffc02ac888 <current>
ffffffffc0205fc4:	0007b883          	ld	a7,0(a5)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0205fc8:	000a7797          	auipc	a5,0xa7
ffffffffc0205fcc:	8c878793          	addi	a5,a5,-1848 # ffffffffc02ac890 <idleproc>
ffffffffc0205fd0:	6388                	ld	a0,0(a5)
        current->need_resched = 0;
ffffffffc0205fd2:	0008bc23          	sd	zero,24(a7) # 2018 <_binary_obj___user_faultread_out_size-0x75b0>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0205fd6:	04a88e63          	beq	a7,a0,ffffffffc0206032 <schedule+0x86>
ffffffffc0205fda:	0c888693          	addi	a3,a7,200
ffffffffc0205fde:	000a7617          	auipc	a2,0xa7
ffffffffc0205fe2:	9ea60613          	addi	a2,a2,-1558 # ffffffffc02ac9c8 <proc_list>
        le = last;
ffffffffc0205fe6:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;
ffffffffc0205fe8:	4581                	li	a1,0
        do {
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE) {
ffffffffc0205fea:	4809                	li	a6,2
    return listelm->next;
ffffffffc0205fec:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list) {
ffffffffc0205fee:	00c78863          	beq	a5,a2,ffffffffc0205ffe <schedule+0x52>
                if (next->state == PROC_RUNNABLE) {
ffffffffc0205ff2:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc0205ff6:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE) {
ffffffffc0205ffa:	01070463          	beq	a4,a6,ffffffffc0206002 <schedule+0x56>
                    break;
                }
            }
        } while (le != last);
ffffffffc0205ffe:	fef697e3          	bne	a3,a5,ffffffffc0205fec <schedule+0x40>
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc0206002:	c589                	beqz	a1,ffffffffc020600c <schedule+0x60>
ffffffffc0206004:	4198                	lw	a4,0(a1)
ffffffffc0206006:	4789                	li	a5,2
ffffffffc0206008:	00f70e63          	beq	a4,a5,ffffffffc0206024 <schedule+0x78>
            next = idleproc;
        }
        next->runs ++;
ffffffffc020600c:	451c                	lw	a5,8(a0)
ffffffffc020600e:	2785                	addiw	a5,a5,1
ffffffffc0206010:	c51c                	sw	a5,8(a0)
        if (next != current) {
ffffffffc0206012:	00a88463          	beq	a7,a0,ffffffffc020601a <schedule+0x6e>
            proc_run(next);
ffffffffc0206016:	f0bfe0ef          	jal	ra,ffffffffc0204f20 <proc_run>
    if (flag) {
ffffffffc020601a:	e419                	bnez	s0,ffffffffc0206028 <schedule+0x7c>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc020601c:	60a2                	ld	ra,8(sp)
ffffffffc020601e:	6402                	ld	s0,0(sp)
ffffffffc0206020:	0141                	addi	sp,sp,16
ffffffffc0206022:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc0206024:	852e                	mv	a0,a1
ffffffffc0206026:	b7dd                	j	ffffffffc020600c <schedule+0x60>
}
ffffffffc0206028:	6402                	ld	s0,0(sp)
ffffffffc020602a:	60a2                	ld	ra,8(sp)
ffffffffc020602c:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc020602e:	e20fa06f          	j	ffffffffc020064e <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0206032:	000a7617          	auipc	a2,0xa7
ffffffffc0206036:	99660613          	addi	a2,a2,-1642 # ffffffffc02ac9c8 <proc_list>
ffffffffc020603a:	86b2                	mv	a3,a2
ffffffffc020603c:	b76d                	j	ffffffffc0205fe6 <schedule+0x3a>
        intr_disable();
ffffffffc020603e:	e16fa0ef          	jal	ra,ffffffffc0200654 <intr_disable>
        return 1;
ffffffffc0206042:	4405                	li	s0,1
ffffffffc0206044:	bfa5                	j	ffffffffc0205fbc <schedule+0x10>

ffffffffc0206046 <sys_getpid>:
    return do_kill(pid);
}

static int
sys_getpid(uint64_t arg[]) {
    return current->pid;
ffffffffc0206046:	000a7797          	auipc	a5,0xa7
ffffffffc020604a:	84278793          	addi	a5,a5,-1982 # ffffffffc02ac888 <current>
ffffffffc020604e:	639c                	ld	a5,0(a5)
}
ffffffffc0206050:	43c8                	lw	a0,4(a5)
ffffffffc0206052:	8082                	ret

ffffffffc0206054 <sys_pgdir>:

static int
sys_pgdir(uint64_t arg[]) {
    //print_pgdir();
    return 0;
}
ffffffffc0206054:	4501                	li	a0,0
ffffffffc0206056:	8082                	ret

ffffffffc0206058 <sys_putc>:
    cputchar(c);
ffffffffc0206058:	4108                	lw	a0,0(a0)
sys_putc(uint64_t arg[]) {
ffffffffc020605a:	1141                	addi	sp,sp,-16
ffffffffc020605c:	e406                	sd	ra,8(sp)
    cputchar(c);
ffffffffc020605e:	8a6fa0ef          	jal	ra,ffffffffc0200104 <cputchar>
}
ffffffffc0206062:	60a2                	ld	ra,8(sp)
ffffffffc0206064:	4501                	li	a0,0
ffffffffc0206066:	0141                	addi	sp,sp,16
ffffffffc0206068:	8082                	ret

ffffffffc020606a <sys_kill>:
    return do_kill(pid);
ffffffffc020606a:	4108                	lw	a0,0(a0)
ffffffffc020606c:	d17ff06f          	j	ffffffffc0205d82 <do_kill>

ffffffffc0206070 <sys_yield>:
    return do_yield();
ffffffffc0206070:	cc1ff06f          	j	ffffffffc0205d30 <do_yield>

ffffffffc0206074 <sys_exec>:
    return do_execve(name, len, binary, size);
ffffffffc0206074:	6d14                	ld	a3,24(a0)
ffffffffc0206076:	6910                	ld	a2,16(a0)
ffffffffc0206078:	650c                	ld	a1,8(a0)
ffffffffc020607a:	6108                	ld	a0,0(a0)
ffffffffc020607c:	fb6ff06f          	j	ffffffffc0205832 <do_execve>

ffffffffc0206080 <sys_wait>:
    return do_wait(pid, store);
ffffffffc0206080:	650c                	ld	a1,8(a0)
ffffffffc0206082:	4108                	lw	a0,0(a0)
ffffffffc0206084:	cbfff06f          	j	ffffffffc0205d42 <do_wait>

ffffffffc0206088 <sys_fork>:
    struct trapframe *tf = current->tf;
ffffffffc0206088:	000a7797          	auipc	a5,0xa7
ffffffffc020608c:	80078793          	addi	a5,a5,-2048 # ffffffffc02ac888 <current>
ffffffffc0206090:	639c                	ld	a5,0(a5)
    return do_fork(0, stack, tf);
ffffffffc0206092:	4501                	li	a0,0
    struct trapframe *tf = current->tf;
ffffffffc0206094:	73d0                	ld	a2,160(a5)
    return do_fork(0, stack, tf);
ffffffffc0206096:	6a0c                	ld	a1,16(a2)
ffffffffc0206098:	f51fe06f          	j	ffffffffc0204fe8 <do_fork>

ffffffffc020609c <sys_exit>:
    return do_exit(error_code);
ffffffffc020609c:	4108                	lw	a0,0(a0)
ffffffffc020609e:	b76ff06f          	j	ffffffffc0205414 <do_exit>

ffffffffc02060a2 <syscall>:
};

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

void
syscall(void) {
ffffffffc02060a2:	715d                	addi	sp,sp,-80
ffffffffc02060a4:	fc26                	sd	s1,56(sp)
    struct trapframe *tf = current->tf;
ffffffffc02060a6:	000a6497          	auipc	s1,0xa6
ffffffffc02060aa:	7e248493          	addi	s1,s1,2018 # ffffffffc02ac888 <current>
ffffffffc02060ae:	6098                	ld	a4,0(s1)
syscall(void) {
ffffffffc02060b0:	e0a2                	sd	s0,64(sp)
ffffffffc02060b2:	f84a                	sd	s2,48(sp)
    struct trapframe *tf = current->tf;
ffffffffc02060b4:	7340                	ld	s0,160(a4)
syscall(void) {
ffffffffc02060b6:	e486                	sd	ra,72(sp)
    uint64_t arg[5];
    int num = tf->gpr.a0;
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc02060b8:	47fd                	li	a5,31
    int num = tf->gpr.a0;
ffffffffc02060ba:	05042903          	lw	s2,80(s0)
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc02060be:	0327ee63          	bltu	a5,s2,ffffffffc02060fa <syscall+0x58>
        if (syscalls[num] != NULL) {
ffffffffc02060c2:	00391713          	slli	a4,s2,0x3
ffffffffc02060c6:	00003797          	auipc	a5,0x3
ffffffffc02060ca:	81278793          	addi	a5,a5,-2030 # ffffffffc02088d8 <syscalls>
ffffffffc02060ce:	97ba                	add	a5,a5,a4
ffffffffc02060d0:	639c                	ld	a5,0(a5)
ffffffffc02060d2:	c785                	beqz	a5,ffffffffc02060fa <syscall+0x58>
            arg[0] = tf->gpr.a1;
ffffffffc02060d4:	6c28                	ld	a0,88(s0)
            arg[1] = tf->gpr.a2;
ffffffffc02060d6:	702c                	ld	a1,96(s0)
            arg[2] = tf->gpr.a3;
ffffffffc02060d8:	7430                	ld	a2,104(s0)
            arg[3] = tf->gpr.a4;
ffffffffc02060da:	7834                	ld	a3,112(s0)
            arg[4] = tf->gpr.a5;
ffffffffc02060dc:	7c38                	ld	a4,120(s0)
            arg[0] = tf->gpr.a1;
ffffffffc02060de:	e42a                	sd	a0,8(sp)
            arg[1] = tf->gpr.a2;
ffffffffc02060e0:	e82e                	sd	a1,16(sp)
            arg[2] = tf->gpr.a3;
ffffffffc02060e2:	ec32                	sd	a2,24(sp)
            arg[3] = tf->gpr.a4;
ffffffffc02060e4:	f036                	sd	a3,32(sp)
            arg[4] = tf->gpr.a5;
ffffffffc02060e6:	f43a                	sd	a4,40(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc02060e8:	0028                	addi	a0,sp,8
ffffffffc02060ea:	9782                	jalr	a5
ffffffffc02060ec:	e828                	sd	a0,80(s0)
        }
    }
    print_trapframe(tf);
    panic("undefined syscall %d, pid = %d, name = %s.\n",
            num, current->pid, current->name);
}
ffffffffc02060ee:	60a6                	ld	ra,72(sp)
ffffffffc02060f0:	6406                	ld	s0,64(sp)
ffffffffc02060f2:	74e2                	ld	s1,56(sp)
ffffffffc02060f4:	7942                	ld	s2,48(sp)
ffffffffc02060f6:	6161                	addi	sp,sp,80
ffffffffc02060f8:	8082                	ret
    print_trapframe(tf);
ffffffffc02060fa:	8522                	mv	a0,s0
ffffffffc02060fc:	f46fa0ef          	jal	ra,ffffffffc0200842 <print_trapframe>
    panic("undefined syscall %d, pid = %d, name = %s.\n",
ffffffffc0206100:	609c                	ld	a5,0(s1)
ffffffffc0206102:	86ca                	mv	a3,s2
ffffffffc0206104:	00002617          	auipc	a2,0x2
ffffffffc0206108:	78c60613          	addi	a2,a2,1932 # ffffffffc0208890 <default_pmm_manager+0x570>
ffffffffc020610c:	43d8                	lw	a4,4(a5)
ffffffffc020610e:	06300593          	li	a1,99
ffffffffc0206112:	0b478793          	addi	a5,a5,180
ffffffffc0206116:	00002517          	auipc	a0,0x2
ffffffffc020611a:	7aa50513          	addi	a0,a0,1962 # ffffffffc02088c0 <default_pmm_manager+0x5a0>
ffffffffc020611e:	8f6fa0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0206122 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0206122:	00054783          	lbu	a5,0(a0)
ffffffffc0206126:	cb91                	beqz	a5,ffffffffc020613a <strlen+0x18>
    size_t cnt = 0;
ffffffffc0206128:	4781                	li	a5,0
        cnt ++;
ffffffffc020612a:	0785                	addi	a5,a5,1
    while (*s ++ != '\0') {
ffffffffc020612c:	00f50733          	add	a4,a0,a5
ffffffffc0206130:	00074703          	lbu	a4,0(a4)
ffffffffc0206134:	fb7d                	bnez	a4,ffffffffc020612a <strlen+0x8>
    }
    return cnt;
}
ffffffffc0206136:	853e                	mv	a0,a5
ffffffffc0206138:	8082                	ret
    size_t cnt = 0;
ffffffffc020613a:	4781                	li	a5,0
}
ffffffffc020613c:	853e                	mv	a0,a5
ffffffffc020613e:	8082                	ret

ffffffffc0206140 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc0206140:	c185                	beqz	a1,ffffffffc0206160 <strnlen+0x20>
ffffffffc0206142:	00054783          	lbu	a5,0(a0)
ffffffffc0206146:	cf89                	beqz	a5,ffffffffc0206160 <strnlen+0x20>
    size_t cnt = 0;
ffffffffc0206148:	4781                	li	a5,0
ffffffffc020614a:	a021                	j	ffffffffc0206152 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc020614c:	00074703          	lbu	a4,0(a4)
ffffffffc0206150:	c711                	beqz	a4,ffffffffc020615c <strnlen+0x1c>
        cnt ++;
ffffffffc0206152:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0206154:	00f50733          	add	a4,a0,a5
ffffffffc0206158:	fef59ae3          	bne	a1,a5,ffffffffc020614c <strnlen+0xc>
    }
    return cnt;
}
ffffffffc020615c:	853e                	mv	a0,a5
ffffffffc020615e:	8082                	ret
    size_t cnt = 0;
ffffffffc0206160:	4781                	li	a5,0
}
ffffffffc0206162:	853e                	mv	a0,a5
ffffffffc0206164:	8082                	ret

ffffffffc0206166 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0206166:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0206168:	0585                	addi	a1,a1,1
ffffffffc020616a:	fff5c703          	lbu	a4,-1(a1)
ffffffffc020616e:	0785                	addi	a5,a5,1
ffffffffc0206170:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0206174:	fb75                	bnez	a4,ffffffffc0206168 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0206176:	8082                	ret

ffffffffc0206178 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0206178:	00054783          	lbu	a5,0(a0)
ffffffffc020617c:	0005c703          	lbu	a4,0(a1)
ffffffffc0206180:	cb91                	beqz	a5,ffffffffc0206194 <strcmp+0x1c>
ffffffffc0206182:	00e79c63          	bne	a5,a4,ffffffffc020619a <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc0206186:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0206188:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc020618c:	0585                	addi	a1,a1,1
ffffffffc020618e:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0206192:	fbe5                	bnez	a5,ffffffffc0206182 <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0206194:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0206196:	9d19                	subw	a0,a0,a4
ffffffffc0206198:	8082                	ret
ffffffffc020619a:	0007851b          	sext.w	a0,a5
ffffffffc020619e:	9d19                	subw	a0,a0,a4
ffffffffc02061a0:	8082                	ret

ffffffffc02061a2 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc02061a2:	00054783          	lbu	a5,0(a0)
ffffffffc02061a6:	cb91                	beqz	a5,ffffffffc02061ba <strchr+0x18>
        if (*s == c) {
ffffffffc02061a8:	00b79563          	bne	a5,a1,ffffffffc02061b2 <strchr+0x10>
ffffffffc02061ac:	a809                	j	ffffffffc02061be <strchr+0x1c>
ffffffffc02061ae:	00b78763          	beq	a5,a1,ffffffffc02061bc <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc02061b2:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc02061b4:	00054783          	lbu	a5,0(a0)
ffffffffc02061b8:	fbfd                	bnez	a5,ffffffffc02061ae <strchr+0xc>
    }
    return NULL;
ffffffffc02061ba:	4501                	li	a0,0
}
ffffffffc02061bc:	8082                	ret
ffffffffc02061be:	8082                	ret

ffffffffc02061c0 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc02061c0:	ca01                	beqz	a2,ffffffffc02061d0 <memset+0x10>
ffffffffc02061c2:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc02061c4:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc02061c6:	0785                	addi	a5,a5,1
ffffffffc02061c8:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc02061cc:	fec79de3          	bne	a5,a2,ffffffffc02061c6 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc02061d0:	8082                	ret

ffffffffc02061d2 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc02061d2:	ca19                	beqz	a2,ffffffffc02061e8 <memcpy+0x16>
ffffffffc02061d4:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc02061d6:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc02061d8:	0585                	addi	a1,a1,1
ffffffffc02061da:	fff5c703          	lbu	a4,-1(a1)
ffffffffc02061de:	0785                	addi	a5,a5,1
ffffffffc02061e0:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc02061e4:	fec59ae3          	bne	a1,a2,ffffffffc02061d8 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc02061e8:	8082                	ret

ffffffffc02061ea <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc02061ea:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02061ee:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc02061f0:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02061f4:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc02061f6:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02061fa:	f022                	sd	s0,32(sp)
ffffffffc02061fc:	ec26                	sd	s1,24(sp)
ffffffffc02061fe:	e84a                	sd	s2,16(sp)
ffffffffc0206200:	f406                	sd	ra,40(sp)
ffffffffc0206202:	e44e                	sd	s3,8(sp)
ffffffffc0206204:	84aa                	mv	s1,a0
ffffffffc0206206:	892e                	mv	s2,a1
ffffffffc0206208:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc020620c:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc020620e:	03067e63          	bgeu	a2,a6,ffffffffc020624a <printnum+0x60>
ffffffffc0206212:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0206214:	00805763          	blez	s0,ffffffffc0206222 <printnum+0x38>
ffffffffc0206218:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc020621a:	85ca                	mv	a1,s2
ffffffffc020621c:	854e                	mv	a0,s3
ffffffffc020621e:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0206220:	fc65                	bnez	s0,ffffffffc0206218 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0206222:	1a02                	slli	s4,s4,0x20
ffffffffc0206224:	020a5a13          	srli	s4,s4,0x20
ffffffffc0206228:	00003797          	auipc	a5,0x3
ffffffffc020622c:	9d078793          	addi	a5,a5,-1584 # ffffffffc0208bf8 <error_string+0xc8>
ffffffffc0206230:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
ffffffffc0206232:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0206234:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0206238:	70a2                	ld	ra,40(sp)
ffffffffc020623a:	69a2                	ld	s3,8(sp)
ffffffffc020623c:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020623e:	85ca                	mv	a1,s2
ffffffffc0206240:	8326                	mv	t1,s1
}
ffffffffc0206242:	6942                	ld	s2,16(sp)
ffffffffc0206244:	64e2                	ld	s1,24(sp)
ffffffffc0206246:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0206248:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc020624a:	03065633          	divu	a2,a2,a6
ffffffffc020624e:	8722                	mv	a4,s0
ffffffffc0206250:	f9bff0ef          	jal	ra,ffffffffc02061ea <printnum>
ffffffffc0206254:	b7f9                	j	ffffffffc0206222 <printnum+0x38>

ffffffffc0206256 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0206256:	7119                	addi	sp,sp,-128
ffffffffc0206258:	f4a6                	sd	s1,104(sp)
ffffffffc020625a:	f0ca                	sd	s2,96(sp)
ffffffffc020625c:	e8d2                	sd	s4,80(sp)
ffffffffc020625e:	e4d6                	sd	s5,72(sp)
ffffffffc0206260:	e0da                	sd	s6,64(sp)
ffffffffc0206262:	fc5e                	sd	s7,56(sp)
ffffffffc0206264:	f862                	sd	s8,48(sp)
ffffffffc0206266:	f06a                	sd	s10,32(sp)
ffffffffc0206268:	fc86                	sd	ra,120(sp)
ffffffffc020626a:	f8a2                	sd	s0,112(sp)
ffffffffc020626c:	ecce                	sd	s3,88(sp)
ffffffffc020626e:	f466                	sd	s9,40(sp)
ffffffffc0206270:	ec6e                	sd	s11,24(sp)
ffffffffc0206272:	892a                	mv	s2,a0
ffffffffc0206274:	84ae                	mv	s1,a1
ffffffffc0206276:	8d32                	mv	s10,a2
ffffffffc0206278:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc020627a:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020627c:	00002a17          	auipc	s4,0x2
ffffffffc0206280:	75ca0a13          	addi	s4,s4,1884 # ffffffffc02089d8 <syscalls+0x100>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0206284:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0206288:	00003c17          	auipc	s8,0x3
ffffffffc020628c:	8a8c0c13          	addi	s8,s8,-1880 # ffffffffc0208b30 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0206290:	000d4503          	lbu	a0,0(s10)
ffffffffc0206294:	02500793          	li	a5,37
ffffffffc0206298:	001d0413          	addi	s0,s10,1
ffffffffc020629c:	00f50e63          	beq	a0,a5,ffffffffc02062b8 <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc02062a0:	c521                	beqz	a0,ffffffffc02062e8 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02062a2:	02500993          	li	s3,37
ffffffffc02062a6:	a011                	j	ffffffffc02062aa <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc02062a8:	c121                	beqz	a0,ffffffffc02062e8 <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc02062aa:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02062ac:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc02062ae:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02062b0:	fff44503          	lbu	a0,-1(s0)
ffffffffc02062b4:	ff351ae3          	bne	a0,s3,ffffffffc02062a8 <vprintfmt+0x52>
ffffffffc02062b8:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc02062bc:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc02062c0:	4981                	li	s3,0
ffffffffc02062c2:	4801                	li	a6,0
        width = precision = -1;
ffffffffc02062c4:	5cfd                	li	s9,-1
ffffffffc02062c6:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02062c8:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc02062cc:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02062ce:	fdd6069b          	addiw	a3,a2,-35
ffffffffc02062d2:	0ff6f693          	andi	a3,a3,255
ffffffffc02062d6:	00140d13          	addi	s10,s0,1
ffffffffc02062da:	1ed5ef63          	bltu	a1,a3,ffffffffc02064d8 <vprintfmt+0x282>
ffffffffc02062de:	068a                	slli	a3,a3,0x2
ffffffffc02062e0:	96d2                	add	a3,a3,s4
ffffffffc02062e2:	4294                	lw	a3,0(a3)
ffffffffc02062e4:	96d2                	add	a3,a3,s4
ffffffffc02062e6:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc02062e8:	70e6                	ld	ra,120(sp)
ffffffffc02062ea:	7446                	ld	s0,112(sp)
ffffffffc02062ec:	74a6                	ld	s1,104(sp)
ffffffffc02062ee:	7906                	ld	s2,96(sp)
ffffffffc02062f0:	69e6                	ld	s3,88(sp)
ffffffffc02062f2:	6a46                	ld	s4,80(sp)
ffffffffc02062f4:	6aa6                	ld	s5,72(sp)
ffffffffc02062f6:	6b06                	ld	s6,64(sp)
ffffffffc02062f8:	7be2                	ld	s7,56(sp)
ffffffffc02062fa:	7c42                	ld	s8,48(sp)
ffffffffc02062fc:	7ca2                	ld	s9,40(sp)
ffffffffc02062fe:	7d02                	ld	s10,32(sp)
ffffffffc0206300:	6de2                	ld	s11,24(sp)
ffffffffc0206302:	6109                	addi	sp,sp,128
ffffffffc0206304:	8082                	ret
            padc = '-';
ffffffffc0206306:	87b2                	mv	a5,a2
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206308:	00144603          	lbu	a2,1(s0)
ffffffffc020630c:	846a                	mv	s0,s10
ffffffffc020630e:	b7c1                	j	ffffffffc02062ce <vprintfmt+0x78>
            precision = va_arg(ap, int);
ffffffffc0206310:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc0206314:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0206318:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020631a:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc020631c:	fa0dd9e3          	bgez	s11,ffffffffc02062ce <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc0206320:	8de6                	mv	s11,s9
ffffffffc0206322:	5cfd                	li	s9,-1
ffffffffc0206324:	b76d                	j	ffffffffc02062ce <vprintfmt+0x78>
            if (width < 0)
ffffffffc0206326:	fffdc693          	not	a3,s11
ffffffffc020632a:	96fd                	srai	a3,a3,0x3f
ffffffffc020632c:	00ddfdb3          	and	s11,s11,a3
ffffffffc0206330:	00144603          	lbu	a2,1(s0)
ffffffffc0206334:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206336:	846a                	mv	s0,s10
ffffffffc0206338:	bf59                	j	ffffffffc02062ce <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc020633a:	4705                	li	a4,1
ffffffffc020633c:	008a8593          	addi	a1,s5,8
ffffffffc0206340:	01074463          	blt	a4,a6,ffffffffc0206348 <vprintfmt+0xf2>
    else if (lflag) {
ffffffffc0206344:	22080863          	beqz	a6,ffffffffc0206574 <vprintfmt+0x31e>
        return va_arg(*ap, unsigned long);
ffffffffc0206348:	000ab603          	ld	a2,0(s5)
ffffffffc020634c:	46c1                	li	a3,16
ffffffffc020634e:	8aae                	mv	s5,a1
ffffffffc0206350:	a291                	j	ffffffffc0206494 <vprintfmt+0x23e>
                precision = precision * 10 + ch - '0';
ffffffffc0206352:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc0206356:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020635a:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc020635c:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0206360:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0206364:	fad56ce3          	bltu	a0,a3,ffffffffc020631c <vprintfmt+0xc6>
            for (precision = 0; ; ++ fmt) {
ffffffffc0206368:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc020636a:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc020636e:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0206372:	0196873b          	addw	a4,a3,s9
ffffffffc0206376:	0017171b          	slliw	a4,a4,0x1
ffffffffc020637a:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc020637e:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc0206382:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc0206386:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc020638a:	fcd57fe3          	bgeu	a0,a3,ffffffffc0206368 <vprintfmt+0x112>
ffffffffc020638e:	b779                	j	ffffffffc020631c <vprintfmt+0xc6>
            putch(va_arg(ap, int), putdat);
ffffffffc0206390:	000aa503          	lw	a0,0(s5)
ffffffffc0206394:	85a6                	mv	a1,s1
ffffffffc0206396:	0aa1                	addi	s5,s5,8
ffffffffc0206398:	9902                	jalr	s2
            break;
ffffffffc020639a:	bddd                	j	ffffffffc0206290 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020639c:	4705                	li	a4,1
ffffffffc020639e:	008a8993          	addi	s3,s5,8
ffffffffc02063a2:	01074463          	blt	a4,a6,ffffffffc02063aa <vprintfmt+0x154>
    else if (lflag) {
ffffffffc02063a6:	1c080463          	beqz	a6,ffffffffc020656e <vprintfmt+0x318>
        return va_arg(*ap, long);
ffffffffc02063aa:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc02063ae:	1c044a63          	bltz	s0,ffffffffc0206582 <vprintfmt+0x32c>
            num = getint(&ap, lflag);
ffffffffc02063b2:	8622                	mv	a2,s0
ffffffffc02063b4:	8ace                	mv	s5,s3
ffffffffc02063b6:	46a9                	li	a3,10
ffffffffc02063b8:	a8f1                	j	ffffffffc0206494 <vprintfmt+0x23e>
            err = va_arg(ap, int);
ffffffffc02063ba:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02063be:	4761                	li	a4,24
            err = va_arg(ap, int);
ffffffffc02063c0:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc02063c2:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02063c6:	8fb5                	xor	a5,a5,a3
ffffffffc02063c8:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02063cc:	12d74963          	blt	a4,a3,ffffffffc02064fe <vprintfmt+0x2a8>
ffffffffc02063d0:	00369793          	slli	a5,a3,0x3
ffffffffc02063d4:	97e2                	add	a5,a5,s8
ffffffffc02063d6:	639c                	ld	a5,0(a5)
ffffffffc02063d8:	12078363          	beqz	a5,ffffffffc02064fe <vprintfmt+0x2a8>
                printfmt(putch, putdat, "%s", p);
ffffffffc02063dc:	86be                	mv	a3,a5
ffffffffc02063de:	00000617          	auipc	a2,0x0
ffffffffc02063e2:	23a60613          	addi	a2,a2,570 # ffffffffc0206618 <etext+0x2a>
ffffffffc02063e6:	85a6                	mv	a1,s1
ffffffffc02063e8:	854a                	mv	a0,s2
ffffffffc02063ea:	1cc000ef          	jal	ra,ffffffffc02065b6 <printfmt>
ffffffffc02063ee:	b54d                	j	ffffffffc0206290 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02063f0:	000ab603          	ld	a2,0(s5)
ffffffffc02063f4:	0aa1                	addi	s5,s5,8
ffffffffc02063f6:	1a060163          	beqz	a2,ffffffffc0206598 <vprintfmt+0x342>
            if (width > 0 && padc != '-') {
ffffffffc02063fa:	00160413          	addi	s0,a2,1
ffffffffc02063fe:	15b05763          	blez	s11,ffffffffc020654c <vprintfmt+0x2f6>
ffffffffc0206402:	02d00593          	li	a1,45
ffffffffc0206406:	10b79d63          	bne	a5,a1,ffffffffc0206520 <vprintfmt+0x2ca>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020640a:	00064783          	lbu	a5,0(a2)
ffffffffc020640e:	0007851b          	sext.w	a0,a5
ffffffffc0206412:	c905                	beqz	a0,ffffffffc0206442 <vprintfmt+0x1ec>
ffffffffc0206414:	000cc563          	bltz	s9,ffffffffc020641e <vprintfmt+0x1c8>
ffffffffc0206418:	3cfd                	addiw	s9,s9,-1
ffffffffc020641a:	036c8263          	beq	s9,s6,ffffffffc020643e <vprintfmt+0x1e8>
                    putch('?', putdat);
ffffffffc020641e:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0206420:	14098f63          	beqz	s3,ffffffffc020657e <vprintfmt+0x328>
ffffffffc0206424:	3781                	addiw	a5,a5,-32
ffffffffc0206426:	14fbfc63          	bgeu	s7,a5,ffffffffc020657e <vprintfmt+0x328>
                    putch('?', putdat);
ffffffffc020642a:	03f00513          	li	a0,63
ffffffffc020642e:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0206430:	0405                	addi	s0,s0,1
ffffffffc0206432:	fff44783          	lbu	a5,-1(s0)
ffffffffc0206436:	3dfd                	addiw	s11,s11,-1
ffffffffc0206438:	0007851b          	sext.w	a0,a5
ffffffffc020643c:	fd61                	bnez	a0,ffffffffc0206414 <vprintfmt+0x1be>
            for (; width > 0; width --) {
ffffffffc020643e:	e5b059e3          	blez	s11,ffffffffc0206290 <vprintfmt+0x3a>
ffffffffc0206442:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0206444:	85a6                	mv	a1,s1
ffffffffc0206446:	02000513          	li	a0,32
ffffffffc020644a:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc020644c:	e40d82e3          	beqz	s11,ffffffffc0206290 <vprintfmt+0x3a>
ffffffffc0206450:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0206452:	85a6                	mv	a1,s1
ffffffffc0206454:	02000513          	li	a0,32
ffffffffc0206458:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc020645a:	fe0d94e3          	bnez	s11,ffffffffc0206442 <vprintfmt+0x1ec>
ffffffffc020645e:	bd0d                	j	ffffffffc0206290 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0206460:	4705                	li	a4,1
ffffffffc0206462:	008a8593          	addi	a1,s5,8
ffffffffc0206466:	01074463          	blt	a4,a6,ffffffffc020646e <vprintfmt+0x218>
    else if (lflag) {
ffffffffc020646a:	0e080863          	beqz	a6,ffffffffc020655a <vprintfmt+0x304>
        return va_arg(*ap, unsigned long);
ffffffffc020646e:	000ab603          	ld	a2,0(s5)
ffffffffc0206472:	46a1                	li	a3,8
ffffffffc0206474:	8aae                	mv	s5,a1
ffffffffc0206476:	a839                	j	ffffffffc0206494 <vprintfmt+0x23e>
            putch('0', putdat);
ffffffffc0206478:	03000513          	li	a0,48
ffffffffc020647c:	85a6                	mv	a1,s1
ffffffffc020647e:	e03e                	sd	a5,0(sp)
ffffffffc0206480:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0206482:	85a6                	mv	a1,s1
ffffffffc0206484:	07800513          	li	a0,120
ffffffffc0206488:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020648a:	0aa1                	addi	s5,s5,8
ffffffffc020648c:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc0206490:	6782                	ld	a5,0(sp)
ffffffffc0206492:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0206494:	2781                	sext.w	a5,a5
ffffffffc0206496:	876e                	mv	a4,s11
ffffffffc0206498:	85a6                	mv	a1,s1
ffffffffc020649a:	854a                	mv	a0,s2
ffffffffc020649c:	d4fff0ef          	jal	ra,ffffffffc02061ea <printnum>
            break;
ffffffffc02064a0:	bbc5                	j	ffffffffc0206290 <vprintfmt+0x3a>
            lflag ++;
ffffffffc02064a2:	00144603          	lbu	a2,1(s0)
ffffffffc02064a6:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02064a8:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02064aa:	b515                	j	ffffffffc02062ce <vprintfmt+0x78>
            goto reswitch;
ffffffffc02064ac:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc02064b0:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02064b2:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02064b4:	bd29                	j	ffffffffc02062ce <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc02064b6:	85a6                	mv	a1,s1
ffffffffc02064b8:	02500513          	li	a0,37
ffffffffc02064bc:	9902                	jalr	s2
            break;
ffffffffc02064be:	bbc9                	j	ffffffffc0206290 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02064c0:	4705                	li	a4,1
ffffffffc02064c2:	008a8593          	addi	a1,s5,8
ffffffffc02064c6:	01074463          	blt	a4,a6,ffffffffc02064ce <vprintfmt+0x278>
    else if (lflag) {
ffffffffc02064ca:	08080d63          	beqz	a6,ffffffffc0206564 <vprintfmt+0x30e>
        return va_arg(*ap, unsigned long);
ffffffffc02064ce:	000ab603          	ld	a2,0(s5)
ffffffffc02064d2:	46a9                	li	a3,10
ffffffffc02064d4:	8aae                	mv	s5,a1
ffffffffc02064d6:	bf7d                	j	ffffffffc0206494 <vprintfmt+0x23e>
            putch('%', putdat);
ffffffffc02064d8:	85a6                	mv	a1,s1
ffffffffc02064da:	02500513          	li	a0,37
ffffffffc02064de:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc02064e0:	fff44703          	lbu	a4,-1(s0)
ffffffffc02064e4:	02500793          	li	a5,37
ffffffffc02064e8:	8d22                	mv	s10,s0
ffffffffc02064ea:	daf703e3          	beq	a4,a5,ffffffffc0206290 <vprintfmt+0x3a>
ffffffffc02064ee:	02500713          	li	a4,37
ffffffffc02064f2:	1d7d                	addi	s10,s10,-1
ffffffffc02064f4:	fffd4783          	lbu	a5,-1(s10)
ffffffffc02064f8:	fee79de3          	bne	a5,a4,ffffffffc02064f2 <vprintfmt+0x29c>
ffffffffc02064fc:	bb51                	j	ffffffffc0206290 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc02064fe:	00002617          	auipc	a2,0x2
ffffffffc0206502:	7da60613          	addi	a2,a2,2010 # ffffffffc0208cd8 <error_string+0x1a8>
ffffffffc0206506:	85a6                	mv	a1,s1
ffffffffc0206508:	854a                	mv	a0,s2
ffffffffc020650a:	0ac000ef          	jal	ra,ffffffffc02065b6 <printfmt>
ffffffffc020650e:	b349                	j	ffffffffc0206290 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0206510:	00002617          	auipc	a2,0x2
ffffffffc0206514:	7c060613          	addi	a2,a2,1984 # ffffffffc0208cd0 <error_string+0x1a0>
            if (width > 0 && padc != '-') {
ffffffffc0206518:	00002417          	auipc	s0,0x2
ffffffffc020651c:	7b940413          	addi	s0,s0,1977 # ffffffffc0208cd1 <error_string+0x1a1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0206520:	8532                	mv	a0,a2
ffffffffc0206522:	85e6                	mv	a1,s9
ffffffffc0206524:	e032                	sd	a2,0(sp)
ffffffffc0206526:	e43e                	sd	a5,8(sp)
ffffffffc0206528:	c19ff0ef          	jal	ra,ffffffffc0206140 <strnlen>
ffffffffc020652c:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0206530:	6602                	ld	a2,0(sp)
ffffffffc0206532:	01b05d63          	blez	s11,ffffffffc020654c <vprintfmt+0x2f6>
ffffffffc0206536:	67a2                	ld	a5,8(sp)
ffffffffc0206538:	2781                	sext.w	a5,a5
ffffffffc020653a:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc020653c:	6522                	ld	a0,8(sp)
ffffffffc020653e:	85a6                	mv	a1,s1
ffffffffc0206540:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0206542:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0206544:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0206546:	6602                	ld	a2,0(sp)
ffffffffc0206548:	fe0d9ae3          	bnez	s11,ffffffffc020653c <vprintfmt+0x2e6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020654c:	00064783          	lbu	a5,0(a2)
ffffffffc0206550:	0007851b          	sext.w	a0,a5
ffffffffc0206554:	ec0510e3          	bnez	a0,ffffffffc0206414 <vprintfmt+0x1be>
ffffffffc0206558:	bb25                	j	ffffffffc0206290 <vprintfmt+0x3a>
        return va_arg(*ap, unsigned int);
ffffffffc020655a:	000ae603          	lwu	a2,0(s5)
ffffffffc020655e:	46a1                	li	a3,8
ffffffffc0206560:	8aae                	mv	s5,a1
ffffffffc0206562:	bf0d                	j	ffffffffc0206494 <vprintfmt+0x23e>
ffffffffc0206564:	000ae603          	lwu	a2,0(s5)
ffffffffc0206568:	46a9                	li	a3,10
ffffffffc020656a:	8aae                	mv	s5,a1
ffffffffc020656c:	b725                	j	ffffffffc0206494 <vprintfmt+0x23e>
        return va_arg(*ap, int);
ffffffffc020656e:	000aa403          	lw	s0,0(s5)
ffffffffc0206572:	bd35                	j	ffffffffc02063ae <vprintfmt+0x158>
        return va_arg(*ap, unsigned int);
ffffffffc0206574:	000ae603          	lwu	a2,0(s5)
ffffffffc0206578:	46c1                	li	a3,16
ffffffffc020657a:	8aae                	mv	s5,a1
ffffffffc020657c:	bf21                	j	ffffffffc0206494 <vprintfmt+0x23e>
                    putch(ch, putdat);
ffffffffc020657e:	9902                	jalr	s2
ffffffffc0206580:	bd45                	j	ffffffffc0206430 <vprintfmt+0x1da>
                putch('-', putdat);
ffffffffc0206582:	85a6                	mv	a1,s1
ffffffffc0206584:	02d00513          	li	a0,45
ffffffffc0206588:	e03e                	sd	a5,0(sp)
ffffffffc020658a:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc020658c:	8ace                	mv	s5,s3
ffffffffc020658e:	40800633          	neg	a2,s0
ffffffffc0206592:	46a9                	li	a3,10
ffffffffc0206594:	6782                	ld	a5,0(sp)
ffffffffc0206596:	bdfd                	j	ffffffffc0206494 <vprintfmt+0x23e>
            if (width > 0 && padc != '-') {
ffffffffc0206598:	01b05663          	blez	s11,ffffffffc02065a4 <vprintfmt+0x34e>
ffffffffc020659c:	02d00693          	li	a3,45
ffffffffc02065a0:	f6d798e3          	bne	a5,a3,ffffffffc0206510 <vprintfmt+0x2ba>
ffffffffc02065a4:	00002417          	auipc	s0,0x2
ffffffffc02065a8:	72d40413          	addi	s0,s0,1837 # ffffffffc0208cd1 <error_string+0x1a1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02065ac:	02800513          	li	a0,40
ffffffffc02065b0:	02800793          	li	a5,40
ffffffffc02065b4:	b585                	j	ffffffffc0206414 <vprintfmt+0x1be>

ffffffffc02065b6 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02065b6:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02065b8:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02065bc:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02065be:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02065c0:	ec06                	sd	ra,24(sp)
ffffffffc02065c2:	f83a                	sd	a4,48(sp)
ffffffffc02065c4:	fc3e                	sd	a5,56(sp)
ffffffffc02065c6:	e0c2                	sd	a6,64(sp)
ffffffffc02065c8:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02065ca:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02065cc:	c8bff0ef          	jal	ra,ffffffffc0206256 <vprintfmt>
}
ffffffffc02065d0:	60e2                	ld	ra,24(sp)
ffffffffc02065d2:	6161                	addi	sp,sp,80
ffffffffc02065d4:	8082                	ret

ffffffffc02065d6 <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc02065d6:	9e3707b7          	lui	a5,0x9e370
ffffffffc02065da:	2785                	addiw	a5,a5,1
ffffffffc02065dc:	02f5053b          	mulw	a0,a0,a5
    return (hash >> (32 - bits));
ffffffffc02065e0:	02000793          	li	a5,32
ffffffffc02065e4:	40b785bb          	subw	a1,a5,a1
}
ffffffffc02065e8:	00b5553b          	srlw	a0,a0,a1
ffffffffc02065ec:	8082                	ret
