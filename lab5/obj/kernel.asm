
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
ffffffffc020003a:	40a50513          	addi	a0,a0,1034 # ffffffffc02a1440 <edata>
ffffffffc020003e:	000ad617          	auipc	a2,0xad
ffffffffc0200042:	99260613          	addi	a2,a2,-1646 # ffffffffc02ac9d0 <end>
kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	736050ef          	jal	ra,ffffffffc0205784 <memset>
    cons_init();                // init the console
ffffffffc0200052:	564000ef          	jal	ra,ffffffffc02005b6 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200056:	00006597          	auipc	a1,0x6
ffffffffc020005a:	b6258593          	addi	a1,a1,-1182 # ffffffffc0205bb8 <etext+0x6>
ffffffffc020005e:	00006517          	auipc	a0,0x6
ffffffffc0200062:	b7a50513          	addi	a0,a0,-1158 # ffffffffc0205bd8 <etext+0x26>
ffffffffc0200066:	06a000ef          	jal	ra,ffffffffc02000d0 <cprintf>

    print_kerninfo();
ffffffffc020006a:	258000ef          	jal	ra,ffffffffc02002c2 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006e:	5a0010ef          	jal	ra,ffffffffc020160e <pmm_init>

    pic_init();                 // init interrupt controller
ffffffffc0200072:	5b6000ef          	jal	ra,ffffffffc0200628 <pic_init>
    idt_init();                 // init interrupt descriptor table
ffffffffc0200076:	5c0000ef          	jal	ra,ffffffffc0200636 <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc020007a:	3d8020ef          	jal	ra,ffffffffc0202452 <vmm_init>
    proc_init();                // init process table
ffffffffc020007e:	30c050ef          	jal	ra,ffffffffc020538a <proc_init>
    
    ide_init();                 // init ide devices
ffffffffc0200082:	4ac000ef          	jal	ra,ffffffffc020052e <ide_init>
    swap_init();                // init swap
ffffffffc0200086:	269020ef          	jal	ra,ffffffffc0202aee <swap_init>

    clock_init();               // init clock interrupt
ffffffffc020008a:	4d8000ef          	jal	ra,ffffffffc0200562 <clock_init>
    intr_enable();              // enable irq interrupt
ffffffffc020008e:	59c000ef          	jal	ra,ffffffffc020062a <intr_enable>
    
    cpu_idle();                 // run idle process
ffffffffc0200092:	448050ef          	jal	ra,ffffffffc02054da <cpu_idle>

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
ffffffffc020009e:	51a000ef          	jal	ra,ffffffffc02005b8 <cons_putc>
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
ffffffffc02000c4:	756050ef          	jal	ra,ffffffffc020581a <vprintfmt>
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
ffffffffc02000f8:	722050ef          	jal	ra,ffffffffc020581a <vprintfmt>
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
ffffffffc0200104:	a955                	j	ffffffffc02005b8 <cons_putc>

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
ffffffffc020011c:	49c000ef          	jal	ra,ffffffffc02005b8 <cons_putc>
    (*cnt) ++;
ffffffffc0200120:	008487bb          	addw	a5,s1,s0
    while ((c = *str ++) != '\0') {
ffffffffc0200124:	0405                	addi	s0,s0,1
ffffffffc0200126:	fff44503          	lbu	a0,-1(s0)
ffffffffc020012a:	f96d                	bnez	a0,ffffffffc020011c <cputs+0x16>
ffffffffc020012c:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc0200130:	4529                	li	a0,10
ffffffffc0200132:	486000ef          	jal	ra,ffffffffc02005b8 <cons_putc>
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
ffffffffc020014a:	4a2000ef          	jal	ra,ffffffffc02005ec <cons_getc>
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
ffffffffc0200172:	a7250513          	addi	a0,a0,-1422 # ffffffffc0205be0 <etext+0x2e>
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
ffffffffc0200188:	2bcb8b93          	addi	s7,s7,700 # ffffffffc02a1440 <edata>
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
ffffffffc02001ea:	25a50513          	addi	a0,a0,602 # ffffffffc02a1440 <edata>
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
ffffffffc0200218:	62c30313          	addi	t1,t1,1580 # ffffffffc02ac840 <is_panic>
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
ffffffffc020023c:	60f73423          	sd	a5,1544(a4) # ffffffffc02ac840 <is_panic>

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
ffffffffc020024a:	9a250513          	addi	a0,a0,-1630 # ffffffffc0205be8 <etext+0x36>
    va_start(ap, fmt);
ffffffffc020024e:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200250:	e81ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200254:	65a2                	ld	a1,8(sp)
ffffffffc0200256:	8522                	mv	a0,s0
ffffffffc0200258:	e59ff0ef          	jal	ra,ffffffffc02000b0 <vcprintf>
    cprintf("\n");
ffffffffc020025c:	00006517          	auipc	a0,0x6
ffffffffc0200260:	74450513          	addi	a0,a0,1860 # ffffffffc02069a0 <commands+0xc78>
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
ffffffffc0200274:	3bc000ef          	jal	ra,ffffffffc0200630 <intr_disable>
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
ffffffffc0200292:	97a50513          	addi	a0,a0,-1670 # ffffffffc0205c08 <etext+0x56>
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
ffffffffc02002ae:	00006517          	auipc	a0,0x6
ffffffffc02002b2:	6f250513          	addi	a0,a0,1778 # ffffffffc02069a0 <commands+0xc78>
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
ffffffffc02002c8:	99450513          	addi	a0,a0,-1644 # ffffffffc0205c58 <etext+0xa6>
void print_kerninfo(void) {
ffffffffc02002cc:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc02002ce:	e03ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc02002d2:	00000597          	auipc	a1,0x0
ffffffffc02002d6:	d6458593          	addi	a1,a1,-668 # ffffffffc0200036 <kern_init>
ffffffffc02002da:	00006517          	auipc	a0,0x6
ffffffffc02002de:	99e50513          	addi	a0,a0,-1634 # ffffffffc0205c78 <etext+0xc6>
ffffffffc02002e2:	defff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc02002e6:	00006597          	auipc	a1,0x6
ffffffffc02002ea:	8cc58593          	addi	a1,a1,-1844 # ffffffffc0205bb2 <etext>
ffffffffc02002ee:	00006517          	auipc	a0,0x6
ffffffffc02002f2:	9aa50513          	addi	a0,a0,-1622 # ffffffffc0205c98 <etext+0xe6>
ffffffffc02002f6:	ddbff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc02002fa:	000a1597          	auipc	a1,0xa1
ffffffffc02002fe:	14658593          	addi	a1,a1,326 # ffffffffc02a1440 <edata>
ffffffffc0200302:	00006517          	auipc	a0,0x6
ffffffffc0200306:	9b650513          	addi	a0,a0,-1610 # ffffffffc0205cb8 <etext+0x106>
ffffffffc020030a:	dc7ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc020030e:	000ac597          	auipc	a1,0xac
ffffffffc0200312:	6c258593          	addi	a1,a1,1730 # ffffffffc02ac9d0 <end>
ffffffffc0200316:	00006517          	auipc	a0,0x6
ffffffffc020031a:	9c250513          	addi	a0,a0,-1598 # ffffffffc0205cd8 <etext+0x126>
ffffffffc020031e:	db3ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200322:	000ad597          	auipc	a1,0xad
ffffffffc0200326:	aad58593          	addi	a1,a1,-1363 # ffffffffc02acdcf <end+0x3ff>
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
ffffffffc0200348:	9b450513          	addi	a0,a0,-1612 # ffffffffc0205cf8 <etext+0x146>
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
ffffffffc0200356:	8d660613          	addi	a2,a2,-1834 # ffffffffc0205c28 <etext+0x76>
ffffffffc020035a:	04d00593          	li	a1,77
ffffffffc020035e:	00006517          	auipc	a0,0x6
ffffffffc0200362:	8e250513          	addi	a0,a0,-1822 # ffffffffc0205c40 <etext+0x8e>
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
ffffffffc0200372:	a9a60613          	addi	a2,a2,-1382 # ffffffffc0205e08 <commands+0xe0>
ffffffffc0200376:	00006597          	auipc	a1,0x6
ffffffffc020037a:	ab258593          	addi	a1,a1,-1358 # ffffffffc0205e28 <commands+0x100>
ffffffffc020037e:	00006517          	auipc	a0,0x6
ffffffffc0200382:	ab250513          	addi	a0,a0,-1358 # ffffffffc0205e30 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200386:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200388:	d49ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc020038c:	00006617          	auipc	a2,0x6
ffffffffc0200390:	ab460613          	addi	a2,a2,-1356 # ffffffffc0205e40 <commands+0x118>
ffffffffc0200394:	00006597          	auipc	a1,0x6
ffffffffc0200398:	ad458593          	addi	a1,a1,-1324 # ffffffffc0205e68 <commands+0x140>
ffffffffc020039c:	00006517          	auipc	a0,0x6
ffffffffc02003a0:	a9450513          	addi	a0,a0,-1388 # ffffffffc0205e30 <commands+0x108>
ffffffffc02003a4:	d2dff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc02003a8:	00006617          	auipc	a2,0x6
ffffffffc02003ac:	ad060613          	addi	a2,a2,-1328 # ffffffffc0205e78 <commands+0x150>
ffffffffc02003b0:	00006597          	auipc	a1,0x6
ffffffffc02003b4:	ae858593          	addi	a1,a1,-1304 # ffffffffc0205e98 <commands+0x170>
ffffffffc02003b8:	00006517          	auipc	a0,0x6
ffffffffc02003bc:	a7850513          	addi	a0,a0,-1416 # ffffffffc0205e30 <commands+0x108>
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
ffffffffc02003f6:	97e50513          	addi	a0,a0,-1666 # ffffffffc0205d70 <commands+0x48>
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
ffffffffc0200418:	98450513          	addi	a0,a0,-1660 # ffffffffc0205d98 <commands+0x70>
ffffffffc020041c:	cb5ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    if (tf != NULL) {
ffffffffc0200420:	000c0563          	beqz	s8,ffffffffc020042a <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc0200424:	8562                	mv	a0,s8
ffffffffc0200426:	3f8000ef          	jal	ra,ffffffffc020081e <print_trapframe>
ffffffffc020042a:	00006c97          	auipc	s9,0x6
ffffffffc020042e:	8fec8c93          	addi	s9,s9,-1794 # ffffffffc0205d28 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200432:	00006997          	auipc	s3,0x6
ffffffffc0200436:	98e98993          	addi	s3,s3,-1650 # ffffffffc0205dc0 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020043a:	00006917          	auipc	s2,0x6
ffffffffc020043e:	98e90913          	addi	s2,s2,-1650 # ffffffffc0205dc8 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc0200442:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200444:	00006b17          	auipc	s6,0x6
ffffffffc0200448:	98cb0b13          	addi	s6,s6,-1652 # ffffffffc0205dd0 <commands+0xa8>
    if (argc == 0) {
ffffffffc020044c:	00006a97          	auipc	s5,0x6
ffffffffc0200450:	9dca8a93          	addi	s5,s5,-1572 # ffffffffc0205e28 <commands+0x100>
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
ffffffffc020046a:	2fc050ef          	jal	ra,ffffffffc0205766 <strchr>
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
ffffffffc0200484:	8a8d0d13          	addi	s10,s10,-1880 # ffffffffc0205d28 <commands>
    if (argc == 0) {
ffffffffc0200488:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020048a:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020048c:	0d61                	addi	s10,s10,24
ffffffffc020048e:	2ae050ef          	jal	ra,ffffffffc020573c <strcmp>
ffffffffc0200492:	c919                	beqz	a0,ffffffffc02004a8 <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200494:	2405                	addiw	s0,s0,1
ffffffffc0200496:	09740463          	beq	s0,s7,ffffffffc020051e <kmonitor+0x132>
ffffffffc020049a:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020049e:	6582                	ld	a1,0(sp)
ffffffffc02004a0:	0d61                	addi	s10,s10,24
ffffffffc02004a2:	29a050ef          	jal	ra,ffffffffc020573c <strcmp>
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
ffffffffc0200508:	25e050ef          	jal	ra,ffffffffc0205766 <strchr>
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
ffffffffc0200524:	8d050513          	addi	a0,a0,-1840 # ffffffffc0205df0 <commands+0xc8>
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

ffffffffc020053c <ide_write_secs>:
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
    return 0;
}

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
ffffffffc020053c:	8732                	mv	a4,a2
    int iobase = secno * SECTSIZE;
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc020053e:	0095979b          	slliw	a5,a1,0x9
ffffffffc0200542:	000a1517          	auipc	a0,0xa1
ffffffffc0200546:	2fe50513          	addi	a0,a0,766 # ffffffffc02a1840 <ide>
                   size_t nsecs) {
ffffffffc020054a:	1141                	addi	sp,sp,-16
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc020054c:	00969613          	slli	a2,a3,0x9
ffffffffc0200550:	85ba                	mv	a1,a4
ffffffffc0200552:	953e                	add	a0,a0,a5
                   size_t nsecs) {
ffffffffc0200554:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200556:	240050ef          	jal	ra,ffffffffc0205796 <memcpy>
    return 0;
}
ffffffffc020055a:	60a2                	ld	ra,8(sp)
ffffffffc020055c:	4501                	li	a0,0
ffffffffc020055e:	0141                	addi	sp,sp,16
ffffffffc0200560:	8082                	ret

ffffffffc0200562 <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc0200562:	67e1                	lui	a5,0x18
ffffffffc0200564:	6a078793          	addi	a5,a5,1696 # 186a0 <_binary_obj___user_exit_out_size+0xdbd8>
ffffffffc0200568:	000ac717          	auipc	a4,0xac
ffffffffc020056c:	2ef73023          	sd	a5,736(a4) # ffffffffc02ac848 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200570:	c0102573          	rdtime	a0
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc0200574:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200576:	953e                	add	a0,a0,a5
ffffffffc0200578:	4601                	li	a2,0
ffffffffc020057a:	4881                	li	a7,0
ffffffffc020057c:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc0200580:	02000793          	li	a5,32
ffffffffc0200584:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc0200588:	00006517          	auipc	a0,0x6
ffffffffc020058c:	92050513          	addi	a0,a0,-1760 # ffffffffc0205ea8 <commands+0x180>
    ticks = 0;
ffffffffc0200590:	000ac797          	auipc	a5,0xac
ffffffffc0200594:	3007b823          	sd	zero,784(a5) # ffffffffc02ac8a0 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200598:	be25                	j	ffffffffc02000d0 <cprintf>

ffffffffc020059a <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020059a:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020059e:	000ac797          	auipc	a5,0xac
ffffffffc02005a2:	2aa78793          	addi	a5,a5,682 # ffffffffc02ac848 <timebase>
ffffffffc02005a6:	639c                	ld	a5,0(a5)
ffffffffc02005a8:	4581                	li	a1,0
ffffffffc02005aa:	4601                	li	a2,0
ffffffffc02005ac:	953e                	add	a0,a0,a5
ffffffffc02005ae:	4881                	li	a7,0
ffffffffc02005b0:	00000073          	ecall
ffffffffc02005b4:	8082                	ret

ffffffffc02005b6 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc02005b6:	8082                	ret

ffffffffc02005b8 <cons_putc>:
#include <sched.h>
#include <riscv.h>
#include <assert.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02005b8:	100027f3          	csrr	a5,sstatus
ffffffffc02005bc:	8b89                	andi	a5,a5,2
ffffffffc02005be:	0ff57513          	andi	a0,a0,255
ffffffffc02005c2:	e799                	bnez	a5,ffffffffc02005d0 <cons_putc+0x18>
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc02005c4:	4581                	li	a1,0
ffffffffc02005c6:	4601                	li	a2,0
ffffffffc02005c8:	4885                	li	a7,1
ffffffffc02005ca:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc02005ce:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc02005d0:	1101                	addi	sp,sp,-32
ffffffffc02005d2:	ec06                	sd	ra,24(sp)
ffffffffc02005d4:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02005d6:	05a000ef          	jal	ra,ffffffffc0200630 <intr_disable>
ffffffffc02005da:	6522                	ld	a0,8(sp)
ffffffffc02005dc:	4581                	li	a1,0
ffffffffc02005de:	4601                	li	a2,0
ffffffffc02005e0:	4885                	li	a7,1
ffffffffc02005e2:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc02005e6:	60e2                	ld	ra,24(sp)
ffffffffc02005e8:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02005ea:	a081                	j	ffffffffc020062a <intr_enable>

ffffffffc02005ec <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02005ec:	100027f3          	csrr	a5,sstatus
ffffffffc02005f0:	8b89                	andi	a5,a5,2
ffffffffc02005f2:	eb89                	bnez	a5,ffffffffc0200604 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc02005f4:	4501                	li	a0,0
ffffffffc02005f6:	4581                	li	a1,0
ffffffffc02005f8:	4601                	li	a2,0
ffffffffc02005fa:	4889                	li	a7,2
ffffffffc02005fc:	00000073          	ecall
ffffffffc0200600:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc0200602:	8082                	ret
int cons_getc(void) {
ffffffffc0200604:	1101                	addi	sp,sp,-32
ffffffffc0200606:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0200608:	028000ef          	jal	ra,ffffffffc0200630 <intr_disable>
ffffffffc020060c:	4501                	li	a0,0
ffffffffc020060e:	4581                	li	a1,0
ffffffffc0200610:	4601                	li	a2,0
ffffffffc0200612:	4889                	li	a7,2
ffffffffc0200614:	00000073          	ecall
ffffffffc0200618:	2501                	sext.w	a0,a0
ffffffffc020061a:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc020061c:	00e000ef          	jal	ra,ffffffffc020062a <intr_enable>
}
ffffffffc0200620:	60e2                	ld	ra,24(sp)
ffffffffc0200622:	6522                	ld	a0,8(sp)
ffffffffc0200624:	6105                	addi	sp,sp,32
ffffffffc0200626:	8082                	ret

ffffffffc0200628 <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
ffffffffc0200628:	8082                	ret

ffffffffc020062a <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc020062a:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc020062e:	8082                	ret

ffffffffc0200630 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200630:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200634:	8082                	ret

ffffffffc0200636 <idt_init>:
void
idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc0200636:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc020063a:	00000797          	auipc	a5,0x0
ffffffffc020063e:	66a78793          	addi	a5,a5,1642 # ffffffffc0200ca4 <__alltraps>
ffffffffc0200642:	10579073          	csrw	stvec,a5
    /* Allow kernel to access user memory */
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc0200646:	000407b7          	lui	a5,0x40
ffffffffc020064a:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc020064e:	8082                	ret

ffffffffc0200650 <print_regs>:
    cprintf("  tval 0x%08x\n", tf->tval);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs* gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200650:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs* gpr) {
ffffffffc0200652:	1141                	addi	sp,sp,-16
ffffffffc0200654:	e022                	sd	s0,0(sp)
ffffffffc0200656:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200658:	00006517          	auipc	a0,0x6
ffffffffc020065c:	b9850513          	addi	a0,a0,-1128 # ffffffffc02061f0 <commands+0x4c8>
void print_regs(struct pushregs* gpr) {
ffffffffc0200660:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200662:	a6fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200666:	640c                	ld	a1,8(s0)
ffffffffc0200668:	00006517          	auipc	a0,0x6
ffffffffc020066c:	ba050513          	addi	a0,a0,-1120 # ffffffffc0206208 <commands+0x4e0>
ffffffffc0200670:	a61ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc0200674:	680c                	ld	a1,16(s0)
ffffffffc0200676:	00006517          	auipc	a0,0x6
ffffffffc020067a:	baa50513          	addi	a0,a0,-1110 # ffffffffc0206220 <commands+0x4f8>
ffffffffc020067e:	a53ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc0200682:	6c0c                	ld	a1,24(s0)
ffffffffc0200684:	00006517          	auipc	a0,0x6
ffffffffc0200688:	bb450513          	addi	a0,a0,-1100 # ffffffffc0206238 <commands+0x510>
ffffffffc020068c:	a45ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc0200690:	700c                	ld	a1,32(s0)
ffffffffc0200692:	00006517          	auipc	a0,0x6
ffffffffc0200696:	bbe50513          	addi	a0,a0,-1090 # ffffffffc0206250 <commands+0x528>
ffffffffc020069a:	a37ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc020069e:	740c                	ld	a1,40(s0)
ffffffffc02006a0:	00006517          	auipc	a0,0x6
ffffffffc02006a4:	bc850513          	addi	a0,a0,-1080 # ffffffffc0206268 <commands+0x540>
ffffffffc02006a8:	a29ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02006ac:	780c                	ld	a1,48(s0)
ffffffffc02006ae:	00006517          	auipc	a0,0x6
ffffffffc02006b2:	bd250513          	addi	a0,a0,-1070 # ffffffffc0206280 <commands+0x558>
ffffffffc02006b6:	a1bff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02006ba:	7c0c                	ld	a1,56(s0)
ffffffffc02006bc:	00006517          	auipc	a0,0x6
ffffffffc02006c0:	bdc50513          	addi	a0,a0,-1060 # ffffffffc0206298 <commands+0x570>
ffffffffc02006c4:	a0dff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02006c8:	602c                	ld	a1,64(s0)
ffffffffc02006ca:	00006517          	auipc	a0,0x6
ffffffffc02006ce:	be650513          	addi	a0,a0,-1050 # ffffffffc02062b0 <commands+0x588>
ffffffffc02006d2:	9ffff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02006d6:	642c                	ld	a1,72(s0)
ffffffffc02006d8:	00006517          	auipc	a0,0x6
ffffffffc02006dc:	bf050513          	addi	a0,a0,-1040 # ffffffffc02062c8 <commands+0x5a0>
ffffffffc02006e0:	9f1ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc02006e4:	682c                	ld	a1,80(s0)
ffffffffc02006e6:	00006517          	auipc	a0,0x6
ffffffffc02006ea:	bfa50513          	addi	a0,a0,-1030 # ffffffffc02062e0 <commands+0x5b8>
ffffffffc02006ee:	9e3ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc02006f2:	6c2c                	ld	a1,88(s0)
ffffffffc02006f4:	00006517          	auipc	a0,0x6
ffffffffc02006f8:	c0450513          	addi	a0,a0,-1020 # ffffffffc02062f8 <commands+0x5d0>
ffffffffc02006fc:	9d5ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200700:	702c                	ld	a1,96(s0)
ffffffffc0200702:	00006517          	auipc	a0,0x6
ffffffffc0200706:	c0e50513          	addi	a0,a0,-1010 # ffffffffc0206310 <commands+0x5e8>
ffffffffc020070a:	9c7ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020070e:	742c                	ld	a1,104(s0)
ffffffffc0200710:	00006517          	auipc	a0,0x6
ffffffffc0200714:	c1850513          	addi	a0,a0,-1000 # ffffffffc0206328 <commands+0x600>
ffffffffc0200718:	9b9ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc020071c:	782c                	ld	a1,112(s0)
ffffffffc020071e:	00006517          	auipc	a0,0x6
ffffffffc0200722:	c2250513          	addi	a0,a0,-990 # ffffffffc0206340 <commands+0x618>
ffffffffc0200726:	9abff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc020072a:	7c2c                	ld	a1,120(s0)
ffffffffc020072c:	00006517          	auipc	a0,0x6
ffffffffc0200730:	c2c50513          	addi	a0,a0,-980 # ffffffffc0206358 <commands+0x630>
ffffffffc0200734:	99dff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200738:	604c                	ld	a1,128(s0)
ffffffffc020073a:	00006517          	auipc	a0,0x6
ffffffffc020073e:	c3650513          	addi	a0,a0,-970 # ffffffffc0206370 <commands+0x648>
ffffffffc0200742:	98fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200746:	644c                	ld	a1,136(s0)
ffffffffc0200748:	00006517          	auipc	a0,0x6
ffffffffc020074c:	c4050513          	addi	a0,a0,-960 # ffffffffc0206388 <commands+0x660>
ffffffffc0200750:	981ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200754:	684c                	ld	a1,144(s0)
ffffffffc0200756:	00006517          	auipc	a0,0x6
ffffffffc020075a:	c4a50513          	addi	a0,a0,-950 # ffffffffc02063a0 <commands+0x678>
ffffffffc020075e:	973ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200762:	6c4c                	ld	a1,152(s0)
ffffffffc0200764:	00006517          	auipc	a0,0x6
ffffffffc0200768:	c5450513          	addi	a0,a0,-940 # ffffffffc02063b8 <commands+0x690>
ffffffffc020076c:	965ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200770:	704c                	ld	a1,160(s0)
ffffffffc0200772:	00006517          	auipc	a0,0x6
ffffffffc0200776:	c5e50513          	addi	a0,a0,-930 # ffffffffc02063d0 <commands+0x6a8>
ffffffffc020077a:	957ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc020077e:	744c                	ld	a1,168(s0)
ffffffffc0200780:	00006517          	auipc	a0,0x6
ffffffffc0200784:	c6850513          	addi	a0,a0,-920 # ffffffffc02063e8 <commands+0x6c0>
ffffffffc0200788:	949ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc020078c:	784c                	ld	a1,176(s0)
ffffffffc020078e:	00006517          	auipc	a0,0x6
ffffffffc0200792:	c7250513          	addi	a0,a0,-910 # ffffffffc0206400 <commands+0x6d8>
ffffffffc0200796:	93bff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc020079a:	7c4c                	ld	a1,184(s0)
ffffffffc020079c:	00006517          	auipc	a0,0x6
ffffffffc02007a0:	c7c50513          	addi	a0,a0,-900 # ffffffffc0206418 <commands+0x6f0>
ffffffffc02007a4:	92dff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02007a8:	606c                	ld	a1,192(s0)
ffffffffc02007aa:	00006517          	auipc	a0,0x6
ffffffffc02007ae:	c8650513          	addi	a0,a0,-890 # ffffffffc0206430 <commands+0x708>
ffffffffc02007b2:	91fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02007b6:	646c                	ld	a1,200(s0)
ffffffffc02007b8:	00006517          	auipc	a0,0x6
ffffffffc02007bc:	c9050513          	addi	a0,a0,-880 # ffffffffc0206448 <commands+0x720>
ffffffffc02007c0:	911ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02007c4:	686c                	ld	a1,208(s0)
ffffffffc02007c6:	00006517          	auipc	a0,0x6
ffffffffc02007ca:	c9a50513          	addi	a0,a0,-870 # ffffffffc0206460 <commands+0x738>
ffffffffc02007ce:	903ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02007d2:	6c6c                	ld	a1,216(s0)
ffffffffc02007d4:	00006517          	auipc	a0,0x6
ffffffffc02007d8:	ca450513          	addi	a0,a0,-860 # ffffffffc0206478 <commands+0x750>
ffffffffc02007dc:	8f5ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc02007e0:	706c                	ld	a1,224(s0)
ffffffffc02007e2:	00006517          	auipc	a0,0x6
ffffffffc02007e6:	cae50513          	addi	a0,a0,-850 # ffffffffc0206490 <commands+0x768>
ffffffffc02007ea:	8e7ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc02007ee:	746c                	ld	a1,232(s0)
ffffffffc02007f0:	00006517          	auipc	a0,0x6
ffffffffc02007f4:	cb850513          	addi	a0,a0,-840 # ffffffffc02064a8 <commands+0x780>
ffffffffc02007f8:	8d9ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc02007fc:	786c                	ld	a1,240(s0)
ffffffffc02007fe:	00006517          	auipc	a0,0x6
ffffffffc0200802:	cc250513          	addi	a0,a0,-830 # ffffffffc02064c0 <commands+0x798>
ffffffffc0200806:	8cbff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020080a:	7c6c                	ld	a1,248(s0)
}
ffffffffc020080c:	6402                	ld	s0,0(sp)
ffffffffc020080e:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200810:	00006517          	auipc	a0,0x6
ffffffffc0200814:	cc850513          	addi	a0,a0,-824 # ffffffffc02064d8 <commands+0x7b0>
}
ffffffffc0200818:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020081a:	8b7ff06f          	j	ffffffffc02000d0 <cprintf>

ffffffffc020081e <print_trapframe>:
print_trapframe(struct trapframe *tf) {
ffffffffc020081e:	1141                	addi	sp,sp,-16
ffffffffc0200820:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200822:	85aa                	mv	a1,a0
print_trapframe(struct trapframe *tf) {
ffffffffc0200824:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200826:	00006517          	auipc	a0,0x6
ffffffffc020082a:	cca50513          	addi	a0,a0,-822 # ffffffffc02064f0 <commands+0x7c8>
print_trapframe(struct trapframe *tf) {
ffffffffc020082e:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200830:	8a1ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200834:	8522                	mv	a0,s0
ffffffffc0200836:	e1bff0ef          	jal	ra,ffffffffc0200650 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020083a:	10043583          	ld	a1,256(s0)
ffffffffc020083e:	00006517          	auipc	a0,0x6
ffffffffc0200842:	cca50513          	addi	a0,a0,-822 # ffffffffc0206508 <commands+0x7e0>
ffffffffc0200846:	88bff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020084a:	10843583          	ld	a1,264(s0)
ffffffffc020084e:	00006517          	auipc	a0,0x6
ffffffffc0200852:	cd250513          	addi	a0,a0,-814 # ffffffffc0206520 <commands+0x7f8>
ffffffffc0200856:	87bff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  tval 0x%08x\n", tf->tval);
ffffffffc020085a:	11043583          	ld	a1,272(s0)
ffffffffc020085e:	00006517          	auipc	a0,0x6
ffffffffc0200862:	cda50513          	addi	a0,a0,-806 # ffffffffc0206538 <commands+0x810>
ffffffffc0200866:	86bff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020086a:	11843583          	ld	a1,280(s0)
}
ffffffffc020086e:	6402                	ld	s0,0(sp)
ffffffffc0200870:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200872:	00006517          	auipc	a0,0x6
ffffffffc0200876:	cd650513          	addi	a0,a0,-810 # ffffffffc0206548 <commands+0x820>
}
ffffffffc020087a:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020087c:	855ff06f          	j	ffffffffc02000d0 <cprintf>

ffffffffc0200880 <pgfault_handler>:
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int
pgfault_handler(struct trapframe *tf) {
ffffffffc0200880:	1101                	addi	sp,sp,-32
ffffffffc0200882:	e426                	sd	s1,8(sp)
    extern struct mm_struct *check_mm_struct;
    if(check_mm_struct !=NULL) { //used for test check_swap
ffffffffc0200884:	000ac497          	auipc	s1,0xac
ffffffffc0200888:	04448493          	addi	s1,s1,68 # ffffffffc02ac8c8 <check_mm_struct>
ffffffffc020088c:	609c                	ld	a5,0(s1)
pgfault_handler(struct trapframe *tf) {
ffffffffc020088e:	e822                	sd	s0,16(sp)
ffffffffc0200890:	ec06                	sd	ra,24(sp)
ffffffffc0200892:	842a                	mv	s0,a0
    if(check_mm_struct !=NULL) { //used for test check_swap
ffffffffc0200894:	cbbd                	beqz	a5,ffffffffc020090a <pgfault_handler+0x8a>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200896:	10053783          	ld	a5,256(a0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc020089a:	11053583          	ld	a1,272(a0)
ffffffffc020089e:	04b00613          	li	a2,75
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02008a2:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02008a6:	cba1                	beqz	a5,ffffffffc02008f6 <pgfault_handler+0x76>
ffffffffc02008a8:	11843703          	ld	a4,280(s0)
ffffffffc02008ac:	47bd                	li	a5,15
ffffffffc02008ae:	05700693          	li	a3,87
ffffffffc02008b2:	00f70463          	beq	a4,a5,ffffffffc02008ba <pgfault_handler+0x3a>
ffffffffc02008b6:	05200693          	li	a3,82
ffffffffc02008ba:	00006517          	auipc	a0,0x6
ffffffffc02008be:	8b650513          	addi	a0,a0,-1866 # ffffffffc0206170 <commands+0x448>
ffffffffc02008c2:	80fff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            print_pgfault(tf);
        }
    struct mm_struct *mm;
    if (check_mm_struct != NULL) {
ffffffffc02008c6:	6088                	ld	a0,0(s1)
ffffffffc02008c8:	c129                	beqz	a0,ffffffffc020090a <pgfault_handler+0x8a>
        assert(current == idleproc);
ffffffffc02008ca:	000ac797          	auipc	a5,0xac
ffffffffc02008ce:	fb678793          	addi	a5,a5,-74 # ffffffffc02ac880 <current>
ffffffffc02008d2:	6398                	ld	a4,0(a5)
ffffffffc02008d4:	000ac797          	auipc	a5,0xac
ffffffffc02008d8:	fb478793          	addi	a5,a5,-76 # ffffffffc02ac888 <idleproc>
ffffffffc02008dc:	639c                	ld	a5,0(a5)
ffffffffc02008de:	04f71763          	bne	a4,a5,ffffffffc020092c <pgfault_handler+0xac>
            print_pgfault(tf);
            panic("unhandled page fault.\n");
        }
        mm = current->mm;
    }
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc02008e2:	11043603          	ld	a2,272(s0)
ffffffffc02008e6:	11843583          	ld	a1,280(s0)
}
ffffffffc02008ea:	6442                	ld	s0,16(sp)
ffffffffc02008ec:	60e2                	ld	ra,24(sp)
ffffffffc02008ee:	64a2                	ld	s1,8(sp)
ffffffffc02008f0:	6105                	addi	sp,sp,32
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc02008f2:	0a60206f          	j	ffffffffc0202998 <do_pgfault>
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02008f6:	11843703          	ld	a4,280(s0)
ffffffffc02008fa:	47bd                	li	a5,15
ffffffffc02008fc:	05500613          	li	a2,85
ffffffffc0200900:	05700693          	li	a3,87
ffffffffc0200904:	faf719e3          	bne	a4,a5,ffffffffc02008b6 <pgfault_handler+0x36>
ffffffffc0200908:	bf4d                	j	ffffffffc02008ba <pgfault_handler+0x3a>
        if (current == NULL) {
ffffffffc020090a:	000ac797          	auipc	a5,0xac
ffffffffc020090e:	f7678793          	addi	a5,a5,-138 # ffffffffc02ac880 <current>
ffffffffc0200912:	639c                	ld	a5,0(a5)
ffffffffc0200914:	cf85                	beqz	a5,ffffffffc020094c <pgfault_handler+0xcc>
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200916:	11043603          	ld	a2,272(s0)
ffffffffc020091a:	11843583          	ld	a1,280(s0)
}
ffffffffc020091e:	6442                	ld	s0,16(sp)
ffffffffc0200920:	60e2                	ld	ra,24(sp)
ffffffffc0200922:	64a2                	ld	s1,8(sp)
        mm = current->mm;
ffffffffc0200924:	7788                	ld	a0,40(a5)
}
ffffffffc0200926:	6105                	addi	sp,sp,32
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200928:	0700206f          	j	ffffffffc0202998 <do_pgfault>
        assert(current == idleproc);
ffffffffc020092c:	00006697          	auipc	a3,0x6
ffffffffc0200930:	86468693          	addi	a3,a3,-1948 # ffffffffc0206190 <commands+0x468>
ffffffffc0200934:	00006617          	auipc	a2,0x6
ffffffffc0200938:	87460613          	addi	a2,a2,-1932 # ffffffffc02061a8 <commands+0x480>
ffffffffc020093c:	06b00593          	li	a1,107
ffffffffc0200940:	00006517          	auipc	a0,0x6
ffffffffc0200944:	88050513          	addi	a0,a0,-1920 # ffffffffc02061c0 <commands+0x498>
ffffffffc0200948:	8cdff0ef          	jal	ra,ffffffffc0200214 <__panic>
            print_trapframe(tf);
ffffffffc020094c:	8522                	mv	a0,s0
ffffffffc020094e:	ed1ff0ef          	jal	ra,ffffffffc020081e <print_trapframe>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200952:	10043783          	ld	a5,256(s0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200956:	11043583          	ld	a1,272(s0)
ffffffffc020095a:	04b00613          	li	a2,75
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc020095e:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200962:	e399                	bnez	a5,ffffffffc0200968 <pgfault_handler+0xe8>
ffffffffc0200964:	05500613          	li	a2,85
ffffffffc0200968:	11843703          	ld	a4,280(s0)
ffffffffc020096c:	47bd                	li	a5,15
ffffffffc020096e:	02f70663          	beq	a4,a5,ffffffffc020099a <pgfault_handler+0x11a>
ffffffffc0200972:	05200693          	li	a3,82
ffffffffc0200976:	00005517          	auipc	a0,0x5
ffffffffc020097a:	7fa50513          	addi	a0,a0,2042 # ffffffffc0206170 <commands+0x448>
ffffffffc020097e:	f52ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            panic("unhandled page fault.\n");
ffffffffc0200982:	00006617          	auipc	a2,0x6
ffffffffc0200986:	85660613          	addi	a2,a2,-1962 # ffffffffc02061d8 <commands+0x4b0>
ffffffffc020098a:	07200593          	li	a1,114
ffffffffc020098e:	00006517          	auipc	a0,0x6
ffffffffc0200992:	83250513          	addi	a0,a0,-1998 # ffffffffc02061c0 <commands+0x498>
ffffffffc0200996:	87fff0ef          	jal	ra,ffffffffc0200214 <__panic>
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc020099a:	05700693          	li	a3,87
ffffffffc020099e:	bfe1                	j	ffffffffc0200976 <pgfault_handler+0xf6>

ffffffffc02009a0 <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02009a0:	11853783          	ld	a5,280(a0)
    switch (cause) {
ffffffffc02009a4:	472d                	li	a4,11
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02009a6:	0786                	slli	a5,a5,0x1
ffffffffc02009a8:	8385                	srli	a5,a5,0x1
    switch (cause) {
ffffffffc02009aa:	08f76763          	bltu	a4,a5,ffffffffc0200a38 <interrupt_handler+0x98>
ffffffffc02009ae:	00005717          	auipc	a4,0x5
ffffffffc02009b2:	51670713          	addi	a4,a4,1302 # ffffffffc0205ec4 <commands+0x19c>
ffffffffc02009b6:	078a                	slli	a5,a5,0x2
ffffffffc02009b8:	97ba                	add	a5,a5,a4
ffffffffc02009ba:	439c                	lw	a5,0(a5)
ffffffffc02009bc:	97ba                	add	a5,a5,a4
ffffffffc02009be:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02009c0:	00005517          	auipc	a0,0x5
ffffffffc02009c4:	77050513          	addi	a0,a0,1904 # ffffffffc0206130 <commands+0x408>
ffffffffc02009c8:	f08ff06f          	j	ffffffffc02000d0 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02009cc:	00005517          	auipc	a0,0x5
ffffffffc02009d0:	74450513          	addi	a0,a0,1860 # ffffffffc0206110 <commands+0x3e8>
ffffffffc02009d4:	efcff06f          	j	ffffffffc02000d0 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02009d8:	00005517          	auipc	a0,0x5
ffffffffc02009dc:	6f850513          	addi	a0,a0,1784 # ffffffffc02060d0 <commands+0x3a8>
ffffffffc02009e0:	ef0ff06f          	j	ffffffffc02000d0 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02009e4:	00005517          	auipc	a0,0x5
ffffffffc02009e8:	70c50513          	addi	a0,a0,1804 # ffffffffc02060f0 <commands+0x3c8>
ffffffffc02009ec:	ee4ff06f          	j	ffffffffc02000d0 <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
ffffffffc02009f0:	00005517          	auipc	a0,0x5
ffffffffc02009f4:	76050513          	addi	a0,a0,1888 # ffffffffc0206150 <commands+0x428>
ffffffffc02009f8:	ed8ff06f          	j	ffffffffc02000d0 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02009fc:	1141                	addi	sp,sp,-16
ffffffffc02009fe:	e406                	sd	ra,8(sp)
            clock_set_next_event();
ffffffffc0200a00:	b9bff0ef          	jal	ra,ffffffffc020059a <clock_set_next_event>
            if (++ticks % TICK_NUM == 0 && current) {
ffffffffc0200a04:	000ac797          	auipc	a5,0xac
ffffffffc0200a08:	e9c78793          	addi	a5,a5,-356 # ffffffffc02ac8a0 <ticks>
ffffffffc0200a0c:	639c                	ld	a5,0(a5)
ffffffffc0200a0e:	06400713          	li	a4,100
ffffffffc0200a12:	0785                	addi	a5,a5,1
ffffffffc0200a14:	02e7f733          	remu	a4,a5,a4
ffffffffc0200a18:	000ac697          	auipc	a3,0xac
ffffffffc0200a1c:	e8f6b423          	sd	a5,-376(a3) # ffffffffc02ac8a0 <ticks>
ffffffffc0200a20:	eb09                	bnez	a4,ffffffffc0200a32 <interrupt_handler+0x92>
ffffffffc0200a22:	000ac797          	auipc	a5,0xac
ffffffffc0200a26:	e5e78793          	addi	a5,a5,-418 # ffffffffc02ac880 <current>
ffffffffc0200a2a:	639c                	ld	a5,0(a5)
ffffffffc0200a2c:	c399                	beqz	a5,ffffffffc0200a32 <interrupt_handler+0x92>
                current->need_resched = 1;
ffffffffc0200a2e:	4705                	li	a4,1
ffffffffc0200a30:	ef98                	sd	a4,24(a5)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200a32:	60a2                	ld	ra,8(sp)
ffffffffc0200a34:	0141                	addi	sp,sp,16
ffffffffc0200a36:	8082                	ret
            print_trapframe(tf);
ffffffffc0200a38:	b3dd                	j	ffffffffc020081e <print_trapframe>

ffffffffc0200a3a <exception_handler>:
void kernel_execve_ret(struct trapframe *tf,uintptr_t kstacktop);
void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc0200a3a:	11853783          	ld	a5,280(a0)
ffffffffc0200a3e:	473d                	li	a4,15
ffffffffc0200a40:	1af76c63          	bltu	a4,a5,ffffffffc0200bf8 <exception_handler+0x1be>
ffffffffc0200a44:	00005717          	auipc	a4,0x5
ffffffffc0200a48:	4b070713          	addi	a4,a4,1200 # ffffffffc0205ef4 <commands+0x1cc>
ffffffffc0200a4c:	078a                	slli	a5,a5,0x2
ffffffffc0200a4e:	97ba                	add	a5,a5,a4
ffffffffc0200a50:	439c                	lw	a5,0(a5)
void exception_handler(struct trapframe *tf) {
ffffffffc0200a52:	1101                	addi	sp,sp,-32
ffffffffc0200a54:	e822                	sd	s0,16(sp)
ffffffffc0200a56:	ec06                	sd	ra,24(sp)
ffffffffc0200a58:	e426                	sd	s1,8(sp)
    switch (tf->cause) {
ffffffffc0200a5a:	97ba                	add	a5,a5,a4
ffffffffc0200a5c:	842a                	mv	s0,a0
ffffffffc0200a5e:	8782                	jr	a5
            //cprintf("Environment call from U-mode\n");
            tf->epc += 4;
            syscall();
            break;
        case CAUSE_SUPERVISOR_ECALL:
            cprintf("Environment call from S-mode\n");
ffffffffc0200a60:	00005517          	auipc	a0,0x5
ffffffffc0200a64:	5c850513          	addi	a0,a0,1480 # ffffffffc0206028 <commands+0x300>
ffffffffc0200a68:	e68ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            tf->epc += 4;
ffffffffc0200a6c:	10843783          	ld	a5,264(s0)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200a70:	60e2                	ld	ra,24(sp)
ffffffffc0200a72:	64a2                	ld	s1,8(sp)
            tf->epc += 4;
ffffffffc0200a74:	0791                	addi	a5,a5,4
ffffffffc0200a76:	10f43423          	sd	a5,264(s0)
}
ffffffffc0200a7a:	6442                	ld	s0,16(sp)
ffffffffc0200a7c:	6105                	addi	sp,sp,32
            syscall();
ffffffffc0200a7e:	3e90406f          	j	ffffffffc0205666 <syscall>
            cprintf("Environment call from H-mode\n");
ffffffffc0200a82:	00005517          	auipc	a0,0x5
ffffffffc0200a86:	5c650513          	addi	a0,a0,1478 # ffffffffc0206048 <commands+0x320>
}
ffffffffc0200a8a:	6442                	ld	s0,16(sp)
ffffffffc0200a8c:	60e2                	ld	ra,24(sp)
ffffffffc0200a8e:	64a2                	ld	s1,8(sp)
ffffffffc0200a90:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc0200a92:	e3eff06f          	j	ffffffffc02000d0 <cprintf>
            cprintf("Environment call from M-mode\n");
ffffffffc0200a96:	00005517          	auipc	a0,0x5
ffffffffc0200a9a:	5d250513          	addi	a0,a0,1490 # ffffffffc0206068 <commands+0x340>
ffffffffc0200a9e:	b7f5                	j	ffffffffc0200a8a <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200aa0:	00005517          	auipc	a0,0x5
ffffffffc0200aa4:	5e850513          	addi	a0,a0,1512 # ffffffffc0206088 <commands+0x360>
ffffffffc0200aa8:	b7cd                	j	ffffffffc0200a8a <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200aaa:	00005517          	auipc	a0,0x5
ffffffffc0200aae:	5f650513          	addi	a0,a0,1526 # ffffffffc02060a0 <commands+0x378>
ffffffffc0200ab2:	e1eff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200ab6:	8522                	mv	a0,s0
ffffffffc0200ab8:	dc9ff0ef          	jal	ra,ffffffffc0200880 <pgfault_handler>
ffffffffc0200abc:	84aa                	mv	s1,a0
ffffffffc0200abe:	12051e63          	bnez	a0,ffffffffc0200bfa <exception_handler+0x1c0>
}
ffffffffc0200ac2:	60e2                	ld	ra,24(sp)
ffffffffc0200ac4:	6442                	ld	s0,16(sp)
ffffffffc0200ac6:	64a2                	ld	s1,8(sp)
ffffffffc0200ac8:	6105                	addi	sp,sp,32
ffffffffc0200aca:	8082                	ret
            cprintf("Store/AMO page fault\n");
ffffffffc0200acc:	00005517          	auipc	a0,0x5
ffffffffc0200ad0:	5ec50513          	addi	a0,a0,1516 # ffffffffc02060b8 <commands+0x390>
ffffffffc0200ad4:	dfcff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200ad8:	8522                	mv	a0,s0
ffffffffc0200ada:	da7ff0ef          	jal	ra,ffffffffc0200880 <pgfault_handler>
ffffffffc0200ade:	84aa                	mv	s1,a0
ffffffffc0200ae0:	d16d                	beqz	a0,ffffffffc0200ac2 <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200ae2:	8522                	mv	a0,s0
ffffffffc0200ae4:	d3bff0ef          	jal	ra,ffffffffc020081e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200ae8:	86a6                	mv	a3,s1
ffffffffc0200aea:	00005617          	auipc	a2,0x5
ffffffffc0200aee:	4ee60613          	addi	a2,a2,1262 # ffffffffc0205fd8 <commands+0x2b0>
ffffffffc0200af2:	0f800593          	li	a1,248
ffffffffc0200af6:	00005517          	auipc	a0,0x5
ffffffffc0200afa:	6ca50513          	addi	a0,a0,1738 # ffffffffc02061c0 <commands+0x498>
ffffffffc0200afe:	f16ff0ef          	jal	ra,ffffffffc0200214 <__panic>
            cprintf("Instruction address misaligned\n");
ffffffffc0200b02:	00005517          	auipc	a0,0x5
ffffffffc0200b06:	43650513          	addi	a0,a0,1078 # ffffffffc0205f38 <commands+0x210>
ffffffffc0200b0a:	b741                	j	ffffffffc0200a8a <exception_handler+0x50>
            cprintf("Instruction access fault\n");
ffffffffc0200b0c:	00005517          	auipc	a0,0x5
ffffffffc0200b10:	44c50513          	addi	a0,a0,1100 # ffffffffc0205f58 <commands+0x230>
ffffffffc0200b14:	bf9d                	j	ffffffffc0200a8a <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc0200b16:	00005517          	auipc	a0,0x5
ffffffffc0200b1a:	46250513          	addi	a0,a0,1122 # ffffffffc0205f78 <commands+0x250>
ffffffffc0200b1e:	b7b5                	j	ffffffffc0200a8a <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc0200b20:	00005517          	auipc	a0,0x5
ffffffffc0200b24:	47050513          	addi	a0,a0,1136 # ffffffffc0205f90 <commands+0x268>
ffffffffc0200b28:	da8ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            if(tf->gpr.a7 == 10){
ffffffffc0200b2c:	6458                	ld	a4,136(s0)
ffffffffc0200b2e:	47a9                	li	a5,10
ffffffffc0200b30:	f8f719e3          	bne	a4,a5,ffffffffc0200ac2 <exception_handler+0x88>
                tf->epc += 4;
ffffffffc0200b34:	10843783          	ld	a5,264(s0)
ffffffffc0200b38:	0791                	addi	a5,a5,4
ffffffffc0200b3a:	10f43423          	sd	a5,264(s0)
                syscall();
ffffffffc0200b3e:	329040ef          	jal	ra,ffffffffc0205666 <syscall>
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b42:	000ac797          	auipc	a5,0xac
ffffffffc0200b46:	d3e78793          	addi	a5,a5,-706 # ffffffffc02ac880 <current>
ffffffffc0200b4a:	639c                	ld	a5,0(a5)
ffffffffc0200b4c:	8522                	mv	a0,s0
}
ffffffffc0200b4e:	6442                	ld	s0,16(sp)
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b50:	6b9c                	ld	a5,16(a5)
}
ffffffffc0200b52:	60e2                	ld	ra,24(sp)
ffffffffc0200b54:	64a2                	ld	s1,8(sp)
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b56:	6589                	lui	a1,0x2
ffffffffc0200b58:	95be                	add	a1,a1,a5
}
ffffffffc0200b5a:	6105                	addi	sp,sp,32
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b5c:	ac19                	j	ffffffffc0200d72 <kernel_execve_ret>
            cprintf("Load address misaligned\n");
ffffffffc0200b5e:	00005517          	auipc	a0,0x5
ffffffffc0200b62:	44250513          	addi	a0,a0,1090 # ffffffffc0205fa0 <commands+0x278>
ffffffffc0200b66:	b715                	j	ffffffffc0200a8a <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc0200b68:	00005517          	auipc	a0,0x5
ffffffffc0200b6c:	45850513          	addi	a0,a0,1112 # ffffffffc0205fc0 <commands+0x298>
ffffffffc0200b70:	d60ff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200b74:	8522                	mv	a0,s0
ffffffffc0200b76:	d0bff0ef          	jal	ra,ffffffffc0200880 <pgfault_handler>
ffffffffc0200b7a:	84aa                	mv	s1,a0
ffffffffc0200b7c:	d139                	beqz	a0,ffffffffc0200ac2 <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200b7e:	8522                	mv	a0,s0
ffffffffc0200b80:	c9fff0ef          	jal	ra,ffffffffc020081e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200b84:	86a6                	mv	a3,s1
ffffffffc0200b86:	00005617          	auipc	a2,0x5
ffffffffc0200b8a:	45260613          	addi	a2,a2,1106 # ffffffffc0205fd8 <commands+0x2b0>
ffffffffc0200b8e:	0cd00593          	li	a1,205
ffffffffc0200b92:	00005517          	auipc	a0,0x5
ffffffffc0200b96:	62e50513          	addi	a0,a0,1582 # ffffffffc02061c0 <commands+0x498>
ffffffffc0200b9a:	e7aff0ef          	jal	ra,ffffffffc0200214 <__panic>
            cprintf("Store/AMO access fault\n");
ffffffffc0200b9e:	00005517          	auipc	a0,0x5
ffffffffc0200ba2:	47250513          	addi	a0,a0,1138 # ffffffffc0206010 <commands+0x2e8>
ffffffffc0200ba6:	d2aff0ef          	jal	ra,ffffffffc02000d0 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200baa:	8522                	mv	a0,s0
ffffffffc0200bac:	cd5ff0ef          	jal	ra,ffffffffc0200880 <pgfault_handler>
ffffffffc0200bb0:	84aa                	mv	s1,a0
ffffffffc0200bb2:	f00508e3          	beqz	a0,ffffffffc0200ac2 <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200bb6:	8522                	mv	a0,s0
ffffffffc0200bb8:	c67ff0ef          	jal	ra,ffffffffc020081e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200bbc:	86a6                	mv	a3,s1
ffffffffc0200bbe:	00005617          	auipc	a2,0x5
ffffffffc0200bc2:	41a60613          	addi	a2,a2,1050 # ffffffffc0205fd8 <commands+0x2b0>
ffffffffc0200bc6:	0d700593          	li	a1,215
ffffffffc0200bca:	00005517          	auipc	a0,0x5
ffffffffc0200bce:	5f650513          	addi	a0,a0,1526 # ffffffffc02061c0 <commands+0x498>
ffffffffc0200bd2:	e42ff0ef          	jal	ra,ffffffffc0200214 <__panic>
}
ffffffffc0200bd6:	6442                	ld	s0,16(sp)
ffffffffc0200bd8:	60e2                	ld	ra,24(sp)
ffffffffc0200bda:	64a2                	ld	s1,8(sp)
ffffffffc0200bdc:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc0200bde:	b181                	j	ffffffffc020081e <print_trapframe>
            panic("AMO address misaligned\n");
ffffffffc0200be0:	00005617          	auipc	a2,0x5
ffffffffc0200be4:	41860613          	addi	a2,a2,1048 # ffffffffc0205ff8 <commands+0x2d0>
ffffffffc0200be8:	0d100593          	li	a1,209
ffffffffc0200bec:	00005517          	auipc	a0,0x5
ffffffffc0200bf0:	5d450513          	addi	a0,a0,1492 # ffffffffc02061c0 <commands+0x498>
ffffffffc0200bf4:	e20ff0ef          	jal	ra,ffffffffc0200214 <__panic>
            print_trapframe(tf);
ffffffffc0200bf8:	b11d                	j	ffffffffc020081e <print_trapframe>
                print_trapframe(tf);
ffffffffc0200bfa:	8522                	mv	a0,s0
ffffffffc0200bfc:	c23ff0ef          	jal	ra,ffffffffc020081e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200c00:	86a6                	mv	a3,s1
ffffffffc0200c02:	00005617          	auipc	a2,0x5
ffffffffc0200c06:	3d660613          	addi	a2,a2,982 # ffffffffc0205fd8 <commands+0x2b0>
ffffffffc0200c0a:	0f100593          	li	a1,241
ffffffffc0200c0e:	00005517          	auipc	a0,0x5
ffffffffc0200c12:	5b250513          	addi	a0,a0,1458 # ffffffffc02061c0 <commands+0x498>
ffffffffc0200c16:	dfeff0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0200c1a <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
ffffffffc0200c1a:	1101                	addi	sp,sp,-32
ffffffffc0200c1c:	e822                	sd	s0,16(sp)
    // dispatch based on what type of trap occurred
//    cputs("some trap");
    if (current == NULL) {
ffffffffc0200c1e:	000ac417          	auipc	s0,0xac
ffffffffc0200c22:	c6240413          	addi	s0,s0,-926 # ffffffffc02ac880 <current>
ffffffffc0200c26:	6018                	ld	a4,0(s0)
trap(struct trapframe *tf) {
ffffffffc0200c28:	ec06                	sd	ra,24(sp)
ffffffffc0200c2a:	e426                	sd	s1,8(sp)
ffffffffc0200c2c:	e04a                	sd	s2,0(sp)
ffffffffc0200c2e:	11853683          	ld	a3,280(a0)
    if (current == NULL) {
ffffffffc0200c32:	cf1d                	beqz	a4,ffffffffc0200c70 <trap+0x56>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c34:	10053483          	ld	s1,256(a0)
        trap_dispatch(tf);
    } else {
        struct trapframe *otf = current->tf;
ffffffffc0200c38:	0a073903          	ld	s2,160(a4)
        current->tf = tf;
ffffffffc0200c3c:	f348                	sd	a0,160(a4)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c3e:	1004f493          	andi	s1,s1,256
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c42:	0206c463          	bltz	a3,ffffffffc0200c6a <trap+0x50>
        exception_handler(tf);
ffffffffc0200c46:	df5ff0ef          	jal	ra,ffffffffc0200a3a <exception_handler>

        bool in_kernel = trap_in_kernel(tf);

        trap_dispatch(tf);

        current->tf = otf;
ffffffffc0200c4a:	601c                	ld	a5,0(s0)
ffffffffc0200c4c:	0b27b023          	sd	s2,160(a5)
        if (!in_kernel) {
ffffffffc0200c50:	e499                	bnez	s1,ffffffffc0200c5e <trap+0x44>
            if (current->flags & PF_EXITING) {
ffffffffc0200c52:	0b07a703          	lw	a4,176(a5)
ffffffffc0200c56:	8b05                	andi	a4,a4,1
ffffffffc0200c58:	e329                	bnez	a4,ffffffffc0200c9a <trap+0x80>
                do_exit(-E_KILLED);
            }
            if (current->need_resched) {
ffffffffc0200c5a:	6f9c                	ld	a5,24(a5)
ffffffffc0200c5c:	eb85                	bnez	a5,ffffffffc0200c8c <trap+0x72>
                schedule();
            }
        }
    }
}
ffffffffc0200c5e:	60e2                	ld	ra,24(sp)
ffffffffc0200c60:	6442                	ld	s0,16(sp)
ffffffffc0200c62:	64a2                	ld	s1,8(sp)
ffffffffc0200c64:	6902                	ld	s2,0(sp)
ffffffffc0200c66:	6105                	addi	sp,sp,32
ffffffffc0200c68:	8082                	ret
        interrupt_handler(tf);
ffffffffc0200c6a:	d37ff0ef          	jal	ra,ffffffffc02009a0 <interrupt_handler>
ffffffffc0200c6e:	bff1                	j	ffffffffc0200c4a <trap+0x30>
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c70:	0006c863          	bltz	a3,ffffffffc0200c80 <trap+0x66>
}
ffffffffc0200c74:	6442                	ld	s0,16(sp)
ffffffffc0200c76:	60e2                	ld	ra,24(sp)
ffffffffc0200c78:	64a2                	ld	s1,8(sp)
ffffffffc0200c7a:	6902                	ld	s2,0(sp)
ffffffffc0200c7c:	6105                	addi	sp,sp,32
        exception_handler(tf);
ffffffffc0200c7e:	bb75                	j	ffffffffc0200a3a <exception_handler>
}
ffffffffc0200c80:	6442                	ld	s0,16(sp)
ffffffffc0200c82:	60e2                	ld	ra,24(sp)
ffffffffc0200c84:	64a2                	ld	s1,8(sp)
ffffffffc0200c86:	6902                	ld	s2,0(sp)
ffffffffc0200c88:	6105                	addi	sp,sp,32
        interrupt_handler(tf);
ffffffffc0200c8a:	bb19                	j	ffffffffc02009a0 <interrupt_handler>
}
ffffffffc0200c8c:	6442                	ld	s0,16(sp)
ffffffffc0200c8e:	60e2                	ld	ra,24(sp)
ffffffffc0200c90:	64a2                	ld	s1,8(sp)
ffffffffc0200c92:	6902                	ld	s2,0(sp)
ffffffffc0200c94:	6105                	addi	sp,sp,32
                schedule();
ffffffffc0200c96:	0db0406f          	j	ffffffffc0205570 <schedule>
                do_exit(-E_KILLED);
ffffffffc0200c9a:	555d                	li	a0,-9
ffffffffc0200c9c:	555030ef          	jal	ra,ffffffffc02049f0 <do_exit>
ffffffffc0200ca0:	601c                	ld	a5,0(s0)
ffffffffc0200ca2:	bf65                	j	ffffffffc0200c5a <trap+0x40>

ffffffffc0200ca4 <__alltraps>:
    LOAD x2, 2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200ca4:	14011173          	csrrw	sp,sscratch,sp
ffffffffc0200ca8:	00011463          	bnez	sp,ffffffffc0200cb0 <__alltraps+0xc>
ffffffffc0200cac:	14002173          	csrr	sp,sscratch
ffffffffc0200cb0:	712d                	addi	sp,sp,-288
ffffffffc0200cb2:	e002                	sd	zero,0(sp)
ffffffffc0200cb4:	e406                	sd	ra,8(sp)
ffffffffc0200cb6:	ec0e                	sd	gp,24(sp)
ffffffffc0200cb8:	f012                	sd	tp,32(sp)
ffffffffc0200cba:	f416                	sd	t0,40(sp)
ffffffffc0200cbc:	f81a                	sd	t1,48(sp)
ffffffffc0200cbe:	fc1e                	sd	t2,56(sp)
ffffffffc0200cc0:	e0a2                	sd	s0,64(sp)
ffffffffc0200cc2:	e4a6                	sd	s1,72(sp)
ffffffffc0200cc4:	e8aa                	sd	a0,80(sp)
ffffffffc0200cc6:	ecae                	sd	a1,88(sp)
ffffffffc0200cc8:	f0b2                	sd	a2,96(sp)
ffffffffc0200cca:	f4b6                	sd	a3,104(sp)
ffffffffc0200ccc:	f8ba                	sd	a4,112(sp)
ffffffffc0200cce:	fcbe                	sd	a5,120(sp)
ffffffffc0200cd0:	e142                	sd	a6,128(sp)
ffffffffc0200cd2:	e546                	sd	a7,136(sp)
ffffffffc0200cd4:	e94a                	sd	s2,144(sp)
ffffffffc0200cd6:	ed4e                	sd	s3,152(sp)
ffffffffc0200cd8:	f152                	sd	s4,160(sp)
ffffffffc0200cda:	f556                	sd	s5,168(sp)
ffffffffc0200cdc:	f95a                	sd	s6,176(sp)
ffffffffc0200cde:	fd5e                	sd	s7,184(sp)
ffffffffc0200ce0:	e1e2                	sd	s8,192(sp)
ffffffffc0200ce2:	e5e6                	sd	s9,200(sp)
ffffffffc0200ce4:	e9ea                	sd	s10,208(sp)
ffffffffc0200ce6:	edee                	sd	s11,216(sp)
ffffffffc0200ce8:	f1f2                	sd	t3,224(sp)
ffffffffc0200cea:	f5f6                	sd	t4,232(sp)
ffffffffc0200cec:	f9fa                	sd	t5,240(sp)
ffffffffc0200cee:	fdfe                	sd	t6,248(sp)
ffffffffc0200cf0:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200cf4:	100024f3          	csrr	s1,sstatus
ffffffffc0200cf8:	14102973          	csrr	s2,sepc
ffffffffc0200cfc:	143029f3          	csrr	s3,stval
ffffffffc0200d00:	14202a73          	csrr	s4,scause
ffffffffc0200d04:	e822                	sd	s0,16(sp)
ffffffffc0200d06:	e226                	sd	s1,256(sp)
ffffffffc0200d08:	e64a                	sd	s2,264(sp)
ffffffffc0200d0a:	ea4e                	sd	s3,272(sp)
ffffffffc0200d0c:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200d0e:	850a                	mv	a0,sp
    jal trap
ffffffffc0200d10:	f0bff0ef          	jal	ra,ffffffffc0200c1a <trap>

ffffffffc0200d14 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200d14:	6492                	ld	s1,256(sp)
ffffffffc0200d16:	6932                	ld	s2,264(sp)
ffffffffc0200d18:	1004f413          	andi	s0,s1,256
ffffffffc0200d1c:	e401                	bnez	s0,ffffffffc0200d24 <__trapret+0x10>
ffffffffc0200d1e:	1200                	addi	s0,sp,288
ffffffffc0200d20:	14041073          	csrw	sscratch,s0
ffffffffc0200d24:	10049073          	csrw	sstatus,s1
ffffffffc0200d28:	14191073          	csrw	sepc,s2
ffffffffc0200d2c:	60a2                	ld	ra,8(sp)
ffffffffc0200d2e:	61e2                	ld	gp,24(sp)
ffffffffc0200d30:	7202                	ld	tp,32(sp)
ffffffffc0200d32:	72a2                	ld	t0,40(sp)
ffffffffc0200d34:	7342                	ld	t1,48(sp)
ffffffffc0200d36:	73e2                	ld	t2,56(sp)
ffffffffc0200d38:	6406                	ld	s0,64(sp)
ffffffffc0200d3a:	64a6                	ld	s1,72(sp)
ffffffffc0200d3c:	6546                	ld	a0,80(sp)
ffffffffc0200d3e:	65e6                	ld	a1,88(sp)
ffffffffc0200d40:	7606                	ld	a2,96(sp)
ffffffffc0200d42:	76a6                	ld	a3,104(sp)
ffffffffc0200d44:	7746                	ld	a4,112(sp)
ffffffffc0200d46:	77e6                	ld	a5,120(sp)
ffffffffc0200d48:	680a                	ld	a6,128(sp)
ffffffffc0200d4a:	68aa                	ld	a7,136(sp)
ffffffffc0200d4c:	694a                	ld	s2,144(sp)
ffffffffc0200d4e:	69ea                	ld	s3,152(sp)
ffffffffc0200d50:	7a0a                	ld	s4,160(sp)
ffffffffc0200d52:	7aaa                	ld	s5,168(sp)
ffffffffc0200d54:	7b4a                	ld	s6,176(sp)
ffffffffc0200d56:	7bea                	ld	s7,184(sp)
ffffffffc0200d58:	6c0e                	ld	s8,192(sp)
ffffffffc0200d5a:	6cae                	ld	s9,200(sp)
ffffffffc0200d5c:	6d4e                	ld	s10,208(sp)
ffffffffc0200d5e:	6dee                	ld	s11,216(sp)
ffffffffc0200d60:	7e0e                	ld	t3,224(sp)
ffffffffc0200d62:	7eae                	ld	t4,232(sp)
ffffffffc0200d64:	7f4e                	ld	t5,240(sp)
ffffffffc0200d66:	7fee                	ld	t6,248(sp)
ffffffffc0200d68:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200d6a:	10200073          	sret

ffffffffc0200d6e <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200d6e:	812a                	mv	sp,a0
    j __trapret
ffffffffc0200d70:	b755                	j	ffffffffc0200d14 <__trapret>

ffffffffc0200d72 <kernel_execve_ret>:

    .global kernel_execve_ret
kernel_execve_ret:
    // adjust sp to beneath kstacktop of current process
    addi a1, a1, -36*REGBYTES
ffffffffc0200d72:	ee058593          	addi	a1,a1,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x76e8>

    // copy from previous trapframe to new trapframe
    LOAD s1, 35*REGBYTES(a0)
ffffffffc0200d76:	11853483          	ld	s1,280(a0)
    STORE s1, 35*REGBYTES(a1)
ffffffffc0200d7a:	1095bc23          	sd	s1,280(a1)
    LOAD s1, 34*REGBYTES(a0)
ffffffffc0200d7e:	11053483          	ld	s1,272(a0)
    STORE s1, 34*REGBYTES(a1)
ffffffffc0200d82:	1095b823          	sd	s1,272(a1)
    LOAD s1, 33*REGBYTES(a0)
ffffffffc0200d86:	10853483          	ld	s1,264(a0)
    STORE s1, 33*REGBYTES(a1)
ffffffffc0200d8a:	1095b423          	sd	s1,264(a1)
    LOAD s1, 32*REGBYTES(a0)
ffffffffc0200d8e:	10053483          	ld	s1,256(a0)
    STORE s1, 32*REGBYTES(a1)
ffffffffc0200d92:	1095b023          	sd	s1,256(a1)
    LOAD s1, 31*REGBYTES(a0)
ffffffffc0200d96:	7d64                	ld	s1,248(a0)
    STORE s1, 31*REGBYTES(a1)
ffffffffc0200d98:	fde4                	sd	s1,248(a1)
    LOAD s1, 30*REGBYTES(a0)
ffffffffc0200d9a:	7964                	ld	s1,240(a0)
    STORE s1, 30*REGBYTES(a1)
ffffffffc0200d9c:	f9e4                	sd	s1,240(a1)
    LOAD s1, 29*REGBYTES(a0)
ffffffffc0200d9e:	7564                	ld	s1,232(a0)
    STORE s1, 29*REGBYTES(a1)
ffffffffc0200da0:	f5e4                	sd	s1,232(a1)
    LOAD s1, 28*REGBYTES(a0)
ffffffffc0200da2:	7164                	ld	s1,224(a0)
    STORE s1, 28*REGBYTES(a1)
ffffffffc0200da4:	f1e4                	sd	s1,224(a1)
    LOAD s1, 27*REGBYTES(a0)
ffffffffc0200da6:	6d64                	ld	s1,216(a0)
    STORE s1, 27*REGBYTES(a1)
ffffffffc0200da8:	ede4                	sd	s1,216(a1)
    LOAD s1, 26*REGBYTES(a0)
ffffffffc0200daa:	6964                	ld	s1,208(a0)
    STORE s1, 26*REGBYTES(a1)
ffffffffc0200dac:	e9e4                	sd	s1,208(a1)
    LOAD s1, 25*REGBYTES(a0)
ffffffffc0200dae:	6564                	ld	s1,200(a0)
    STORE s1, 25*REGBYTES(a1)
ffffffffc0200db0:	e5e4                	sd	s1,200(a1)
    LOAD s1, 24*REGBYTES(a0)
ffffffffc0200db2:	6164                	ld	s1,192(a0)
    STORE s1, 24*REGBYTES(a1)
ffffffffc0200db4:	e1e4                	sd	s1,192(a1)
    LOAD s1, 23*REGBYTES(a0)
ffffffffc0200db6:	7d44                	ld	s1,184(a0)
    STORE s1, 23*REGBYTES(a1)
ffffffffc0200db8:	fdc4                	sd	s1,184(a1)
    LOAD s1, 22*REGBYTES(a0)
ffffffffc0200dba:	7944                	ld	s1,176(a0)
    STORE s1, 22*REGBYTES(a1)
ffffffffc0200dbc:	f9c4                	sd	s1,176(a1)
    LOAD s1, 21*REGBYTES(a0)
ffffffffc0200dbe:	7544                	ld	s1,168(a0)
    STORE s1, 21*REGBYTES(a1)
ffffffffc0200dc0:	f5c4                	sd	s1,168(a1)
    LOAD s1, 20*REGBYTES(a0)
ffffffffc0200dc2:	7144                	ld	s1,160(a0)
    STORE s1, 20*REGBYTES(a1)
ffffffffc0200dc4:	f1c4                	sd	s1,160(a1)
    LOAD s1, 19*REGBYTES(a0)
ffffffffc0200dc6:	6d44                	ld	s1,152(a0)
    STORE s1, 19*REGBYTES(a1)
ffffffffc0200dc8:	edc4                	sd	s1,152(a1)
    LOAD s1, 18*REGBYTES(a0)
ffffffffc0200dca:	6944                	ld	s1,144(a0)
    STORE s1, 18*REGBYTES(a1)
ffffffffc0200dcc:	e9c4                	sd	s1,144(a1)
    LOAD s1, 17*REGBYTES(a0)
ffffffffc0200dce:	6544                	ld	s1,136(a0)
    STORE s1, 17*REGBYTES(a1)
ffffffffc0200dd0:	e5c4                	sd	s1,136(a1)
    LOAD s1, 16*REGBYTES(a0)
ffffffffc0200dd2:	6144                	ld	s1,128(a0)
    STORE s1, 16*REGBYTES(a1)
ffffffffc0200dd4:	e1c4                	sd	s1,128(a1)
    LOAD s1, 15*REGBYTES(a0)
ffffffffc0200dd6:	7d24                	ld	s1,120(a0)
    STORE s1, 15*REGBYTES(a1)
ffffffffc0200dd8:	fda4                	sd	s1,120(a1)
    LOAD s1, 14*REGBYTES(a0)
ffffffffc0200dda:	7924                	ld	s1,112(a0)
    STORE s1, 14*REGBYTES(a1)
ffffffffc0200ddc:	f9a4                	sd	s1,112(a1)
    LOAD s1, 13*REGBYTES(a0)
ffffffffc0200dde:	7524                	ld	s1,104(a0)
    STORE s1, 13*REGBYTES(a1)
ffffffffc0200de0:	f5a4                	sd	s1,104(a1)
    LOAD s1, 12*REGBYTES(a0)
ffffffffc0200de2:	7124                	ld	s1,96(a0)
    STORE s1, 12*REGBYTES(a1)
ffffffffc0200de4:	f1a4                	sd	s1,96(a1)
    LOAD s1, 11*REGBYTES(a0)
ffffffffc0200de6:	6d24                	ld	s1,88(a0)
    STORE s1, 11*REGBYTES(a1)
ffffffffc0200de8:	eda4                	sd	s1,88(a1)
    LOAD s1, 10*REGBYTES(a0)
ffffffffc0200dea:	6924                	ld	s1,80(a0)
    STORE s1, 10*REGBYTES(a1)
ffffffffc0200dec:	e9a4                	sd	s1,80(a1)
    LOAD s1, 9*REGBYTES(a0)
ffffffffc0200dee:	6524                	ld	s1,72(a0)
    STORE s1, 9*REGBYTES(a1)
ffffffffc0200df0:	e5a4                	sd	s1,72(a1)
    LOAD s1, 8*REGBYTES(a0)
ffffffffc0200df2:	6124                	ld	s1,64(a0)
    STORE s1, 8*REGBYTES(a1)
ffffffffc0200df4:	e1a4                	sd	s1,64(a1)
    LOAD s1, 7*REGBYTES(a0)
ffffffffc0200df6:	7d04                	ld	s1,56(a0)
    STORE s1, 7*REGBYTES(a1)
ffffffffc0200df8:	fd84                	sd	s1,56(a1)
    LOAD s1, 6*REGBYTES(a0)
ffffffffc0200dfa:	7904                	ld	s1,48(a0)
    STORE s1, 6*REGBYTES(a1)
ffffffffc0200dfc:	f984                	sd	s1,48(a1)
    LOAD s1, 5*REGBYTES(a0)
ffffffffc0200dfe:	7504                	ld	s1,40(a0)
    STORE s1, 5*REGBYTES(a1)
ffffffffc0200e00:	f584                	sd	s1,40(a1)
    LOAD s1, 4*REGBYTES(a0)
ffffffffc0200e02:	7104                	ld	s1,32(a0)
    STORE s1, 4*REGBYTES(a1)
ffffffffc0200e04:	f184                	sd	s1,32(a1)
    LOAD s1, 3*REGBYTES(a0)
ffffffffc0200e06:	6d04                	ld	s1,24(a0)
    STORE s1, 3*REGBYTES(a1)
ffffffffc0200e08:	ed84                	sd	s1,24(a1)
    LOAD s1, 2*REGBYTES(a0)
ffffffffc0200e0a:	6904                	ld	s1,16(a0)
    STORE s1, 2*REGBYTES(a1)
ffffffffc0200e0c:	e984                	sd	s1,16(a1)
    LOAD s1, 1*REGBYTES(a0)
ffffffffc0200e0e:	6504                	ld	s1,8(a0)
    STORE s1, 1*REGBYTES(a1)
ffffffffc0200e10:	e584                	sd	s1,8(a1)
    LOAD s1, 0*REGBYTES(a0)
ffffffffc0200e12:	6104                	ld	s1,0(a0)
    STORE s1, 0*REGBYTES(a1)
ffffffffc0200e14:	e184                	sd	s1,0(a1)

    // acutually adjust sp
    move sp, a1
ffffffffc0200e16:	812e                	mv	sp,a1
ffffffffc0200e18:	bdf5                	j	ffffffffc0200d14 <__trapret>

ffffffffc0200e1a <pa2page.part.4>:
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
}

static inline struct Page *
pa2page(uintptr_t pa) {
ffffffffc0200e1a:	1141                	addi	sp,sp,-16
    if (PPN(pa) >= npage) {
        panic("pa2page called with invalid pa");
ffffffffc0200e1c:	00005617          	auipc	a2,0x5
ffffffffc0200e20:	77c60613          	addi	a2,a2,1916 # ffffffffc0206598 <commands+0x870>
ffffffffc0200e24:	06200593          	li	a1,98
ffffffffc0200e28:	00005517          	auipc	a0,0x5
ffffffffc0200e2c:	79050513          	addi	a0,a0,1936 # ffffffffc02065b8 <commands+0x890>
pa2page(uintptr_t pa) {
ffffffffc0200e30:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0200e32:	be2ff0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0200e36 <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc0200e36:	715d                	addi	sp,sp,-80
ffffffffc0200e38:	e0a2                	sd	s0,64(sp)
ffffffffc0200e3a:	fc26                	sd	s1,56(sp)
ffffffffc0200e3c:	f84a                	sd	s2,48(sp)
ffffffffc0200e3e:	f44e                	sd	s3,40(sp)
ffffffffc0200e40:	f052                	sd	s4,32(sp)
ffffffffc0200e42:	ec56                	sd	s5,24(sp)
ffffffffc0200e44:	e486                	sd	ra,72(sp)
ffffffffc0200e46:	842a                	mv	s0,a0
ffffffffc0200e48:	000ac497          	auipc	s1,0xac
ffffffffc0200e4c:	a6048493          	addi	s1,s1,-1440 # ffffffffc02ac8a8 <pmm_manager>
        {
            page = pmm_manager->alloc_pages(n);
        }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0200e50:	4985                	li	s3,1
ffffffffc0200e52:	000aca17          	auipc	s4,0xac
ffffffffc0200e56:	a1ea0a13          	addi	s4,s4,-1506 # ffffffffc02ac870 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0200e5a:	0005091b          	sext.w	s2,a0
ffffffffc0200e5e:	000aca97          	auipc	s5,0xac
ffffffffc0200e62:	a6aa8a93          	addi	s5,s5,-1430 # ffffffffc02ac8c8 <check_mm_struct>
ffffffffc0200e66:	a00d                	j	ffffffffc0200e88 <alloc_pages+0x52>
            page = pmm_manager->alloc_pages(n);
ffffffffc0200e68:	609c                	ld	a5,0(s1)
ffffffffc0200e6a:	6f9c                	ld	a5,24(a5)
ffffffffc0200e6c:	9782                	jalr	a5
        swap_out(check_mm_struct, n, 0);
ffffffffc0200e6e:	4601                	li	a2,0
ffffffffc0200e70:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0200e72:	ed0d                	bnez	a0,ffffffffc0200eac <alloc_pages+0x76>
ffffffffc0200e74:	0289ec63          	bltu	s3,s0,ffffffffc0200eac <alloc_pages+0x76>
ffffffffc0200e78:	000a2783          	lw	a5,0(s4)
ffffffffc0200e7c:	2781                	sext.w	a5,a5
ffffffffc0200e7e:	c79d                	beqz	a5,ffffffffc0200eac <alloc_pages+0x76>
        swap_out(check_mm_struct, n, 0);
ffffffffc0200e80:	000ab503          	ld	a0,0(s5)
ffffffffc0200e84:	40a020ef          	jal	ra,ffffffffc020328e <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200e88:	100027f3          	csrr	a5,sstatus
ffffffffc0200e8c:	8b89                	andi	a5,a5,2
            page = pmm_manager->alloc_pages(n);
ffffffffc0200e8e:	8522                	mv	a0,s0
ffffffffc0200e90:	dfe1                	beqz	a5,ffffffffc0200e68 <alloc_pages+0x32>
        intr_disable();
ffffffffc0200e92:	f9eff0ef          	jal	ra,ffffffffc0200630 <intr_disable>
ffffffffc0200e96:	609c                	ld	a5,0(s1)
ffffffffc0200e98:	8522                	mv	a0,s0
ffffffffc0200e9a:	6f9c                	ld	a5,24(a5)
ffffffffc0200e9c:	9782                	jalr	a5
ffffffffc0200e9e:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0200ea0:	f8aff0ef          	jal	ra,ffffffffc020062a <intr_enable>
ffffffffc0200ea4:	6522                	ld	a0,8(sp)
        swap_out(check_mm_struct, n, 0);
ffffffffc0200ea6:	4601                	li	a2,0
ffffffffc0200ea8:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0200eaa:	d569                	beqz	a0,ffffffffc0200e74 <alloc_pages+0x3e>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0200eac:	60a6                	ld	ra,72(sp)
ffffffffc0200eae:	6406                	ld	s0,64(sp)
ffffffffc0200eb0:	74e2                	ld	s1,56(sp)
ffffffffc0200eb2:	7942                	ld	s2,48(sp)
ffffffffc0200eb4:	79a2                	ld	s3,40(sp)
ffffffffc0200eb6:	7a02                	ld	s4,32(sp)
ffffffffc0200eb8:	6ae2                	ld	s5,24(sp)
ffffffffc0200eba:	6161                	addi	sp,sp,80
ffffffffc0200ebc:	8082                	ret

ffffffffc0200ebe <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200ebe:	100027f3          	csrr	a5,sstatus
ffffffffc0200ec2:	8b89                	andi	a5,a5,2
ffffffffc0200ec4:	eb89                	bnez	a5,ffffffffc0200ed6 <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0200ec6:	000ac797          	auipc	a5,0xac
ffffffffc0200eca:	9e278793          	addi	a5,a5,-1566 # ffffffffc02ac8a8 <pmm_manager>
ffffffffc0200ece:	639c                	ld	a5,0(a5)
ffffffffc0200ed0:	0207b303          	ld	t1,32(a5)
ffffffffc0200ed4:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc0200ed6:	1101                	addi	sp,sp,-32
ffffffffc0200ed8:	ec06                	sd	ra,24(sp)
ffffffffc0200eda:	e822                	sd	s0,16(sp)
ffffffffc0200edc:	e426                	sd	s1,8(sp)
ffffffffc0200ede:	842a                	mv	s0,a0
ffffffffc0200ee0:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0200ee2:	f4eff0ef          	jal	ra,ffffffffc0200630 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0200ee6:	000ac797          	auipc	a5,0xac
ffffffffc0200eea:	9c278793          	addi	a5,a5,-1598 # ffffffffc02ac8a8 <pmm_manager>
ffffffffc0200eee:	639c                	ld	a5,0(a5)
ffffffffc0200ef0:	85a6                	mv	a1,s1
ffffffffc0200ef2:	8522                	mv	a0,s0
ffffffffc0200ef4:	739c                	ld	a5,32(a5)
ffffffffc0200ef6:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200ef8:	6442                	ld	s0,16(sp)
ffffffffc0200efa:	60e2                	ld	ra,24(sp)
ffffffffc0200efc:	64a2                	ld	s1,8(sp)
ffffffffc0200efe:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200f00:	f2aff06f          	j	ffffffffc020062a <intr_enable>

ffffffffc0200f04 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200f04:	100027f3          	csrr	a5,sstatus
ffffffffc0200f08:	8b89                	andi	a5,a5,2
ffffffffc0200f0a:	eb89                	bnez	a5,ffffffffc0200f1c <nr_free_pages+0x18>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0200f0c:	000ac797          	auipc	a5,0xac
ffffffffc0200f10:	99c78793          	addi	a5,a5,-1636 # ffffffffc02ac8a8 <pmm_manager>
ffffffffc0200f14:	639c                	ld	a5,0(a5)
ffffffffc0200f16:	0287b303          	ld	t1,40(a5)
ffffffffc0200f1a:	8302                	jr	t1
size_t nr_free_pages(void) {
ffffffffc0200f1c:	1141                	addi	sp,sp,-16
ffffffffc0200f1e:	e406                	sd	ra,8(sp)
ffffffffc0200f20:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0200f22:	f0eff0ef          	jal	ra,ffffffffc0200630 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0200f26:	000ac797          	auipc	a5,0xac
ffffffffc0200f2a:	98278793          	addi	a5,a5,-1662 # ffffffffc02ac8a8 <pmm_manager>
ffffffffc0200f2e:	639c                	ld	a5,0(a5)
ffffffffc0200f30:	779c                	ld	a5,40(a5)
ffffffffc0200f32:	9782                	jalr	a5
ffffffffc0200f34:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0200f36:	ef4ff0ef          	jal	ra,ffffffffc020062a <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0200f3a:	8522                	mv	a0,s0
ffffffffc0200f3c:	60a2                	ld	ra,8(sp)
ffffffffc0200f3e:	6402                	ld	s0,0(sp)
ffffffffc0200f40:	0141                	addi	sp,sp,16
ffffffffc0200f42:	8082                	ret

ffffffffc0200f44 <get_pte>:
// parameter:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0200f44:	7139                	addi	sp,sp,-64
ffffffffc0200f46:	f426                	sd	s1,40(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0200f48:	01e5d493          	srli	s1,a1,0x1e
ffffffffc0200f4c:	1ff4f493          	andi	s1,s1,511
ffffffffc0200f50:	048e                	slli	s1,s1,0x3
ffffffffc0200f52:	94aa                	add	s1,s1,a0
    if (!(*pdep1 & PTE_V)) {
ffffffffc0200f54:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0200f56:	f04a                	sd	s2,32(sp)
ffffffffc0200f58:	ec4e                	sd	s3,24(sp)
ffffffffc0200f5a:	e852                	sd	s4,16(sp)
ffffffffc0200f5c:	fc06                	sd	ra,56(sp)
ffffffffc0200f5e:	f822                	sd	s0,48(sp)
ffffffffc0200f60:	e456                	sd	s5,8(sp)
ffffffffc0200f62:	e05a                	sd	s6,0(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc0200f64:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0200f68:	892e                	mv	s2,a1
ffffffffc0200f6a:	8a32                	mv	s4,a2
ffffffffc0200f6c:	000ac997          	auipc	s3,0xac
ffffffffc0200f70:	8ec98993          	addi	s3,s3,-1812 # ffffffffc02ac858 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0200f74:	e7bd                	bnez	a5,ffffffffc0200fe2 <get_pte+0x9e>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0200f76:	12060c63          	beqz	a2,ffffffffc02010ae <get_pte+0x16a>
ffffffffc0200f7a:	4505                	li	a0,1
ffffffffc0200f7c:	ebbff0ef          	jal	ra,ffffffffc0200e36 <alloc_pages>
ffffffffc0200f80:	842a                	mv	s0,a0
ffffffffc0200f82:	12050663          	beqz	a0,ffffffffc02010ae <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0200f86:	000acb17          	auipc	s6,0xac
ffffffffc0200f8a:	93ab0b13          	addi	s6,s6,-1734 # ffffffffc02ac8c0 <pages>
ffffffffc0200f8e:	000b3503          	ld	a0,0(s6)
ffffffffc0200f92:	00080ab7          	lui	s5,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0200f96:	000ac997          	auipc	s3,0xac
ffffffffc0200f9a:	8c298993          	addi	s3,s3,-1854 # ffffffffc02ac858 <npage>
ffffffffc0200f9e:	40a40533          	sub	a0,s0,a0
ffffffffc0200fa2:	8519                	srai	a0,a0,0x6
ffffffffc0200fa4:	9556                	add	a0,a0,s5
ffffffffc0200fa6:	0009b703          	ld	a4,0(s3)
ffffffffc0200faa:	00c51793          	slli	a5,a0,0xc
    return page->ref;
}

static inline void
set_page_ref(struct Page *page, int val) {
    page->ref = val;
ffffffffc0200fae:	4685                	li	a3,1
ffffffffc0200fb0:	c014                	sw	a3,0(s0)
ffffffffc0200fb2:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0200fb4:	0532                	slli	a0,a0,0xc
ffffffffc0200fb6:	14e7f363          	bgeu	a5,a4,ffffffffc02010fc <get_pte+0x1b8>
ffffffffc0200fba:	000ac797          	auipc	a5,0xac
ffffffffc0200fbe:	8f678793          	addi	a5,a5,-1802 # ffffffffc02ac8b0 <va_pa_offset>
ffffffffc0200fc2:	639c                	ld	a5,0(a5)
ffffffffc0200fc4:	6605                	lui	a2,0x1
ffffffffc0200fc6:	4581                	li	a1,0
ffffffffc0200fc8:	953e                	add	a0,a0,a5
ffffffffc0200fca:	7ba040ef          	jal	ra,ffffffffc0205784 <memset>
    return page - pages + nbase;
ffffffffc0200fce:	000b3683          	ld	a3,0(s6)
ffffffffc0200fd2:	40d406b3          	sub	a3,s0,a3
ffffffffc0200fd6:	8699                	srai	a3,a3,0x6
ffffffffc0200fd8:	96d6                	add	a3,a3,s5
  asm volatile("sfence.vma");
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0200fda:	06aa                	slli	a3,a3,0xa
ffffffffc0200fdc:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0200fe0:	e094                	sd	a3,0(s1)
    }

    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0200fe2:	77fd                	lui	a5,0xfffff
ffffffffc0200fe4:	068a                	slli	a3,a3,0x2
ffffffffc0200fe6:	0009b703          	ld	a4,0(s3)
ffffffffc0200fea:	8efd                	and	a3,a3,a5
ffffffffc0200fec:	00c6d793          	srli	a5,a3,0xc
ffffffffc0200ff0:	0ce7f163          	bgeu	a5,a4,ffffffffc02010b2 <get_pte+0x16e>
ffffffffc0200ff4:	000aca97          	auipc	s5,0xac
ffffffffc0200ff8:	8bca8a93          	addi	s5,s5,-1860 # ffffffffc02ac8b0 <va_pa_offset>
ffffffffc0200ffc:	000ab403          	ld	s0,0(s5)
ffffffffc0201000:	01595793          	srli	a5,s2,0x15
ffffffffc0201004:	1ff7f793          	andi	a5,a5,511
ffffffffc0201008:	96a2                	add	a3,a3,s0
ffffffffc020100a:	00379413          	slli	s0,a5,0x3
ffffffffc020100e:	9436                	add	s0,s0,a3
    if (!(*pdep0 & PTE_V)) {
ffffffffc0201010:	6014                	ld	a3,0(s0)
ffffffffc0201012:	0016f793          	andi	a5,a3,1
ffffffffc0201016:	e3ad                	bnez	a5,ffffffffc0201078 <get_pte+0x134>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201018:	080a0b63          	beqz	s4,ffffffffc02010ae <get_pte+0x16a>
ffffffffc020101c:	4505                	li	a0,1
ffffffffc020101e:	e19ff0ef          	jal	ra,ffffffffc0200e36 <alloc_pages>
ffffffffc0201022:	84aa                	mv	s1,a0
ffffffffc0201024:	c549                	beqz	a0,ffffffffc02010ae <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0201026:	000acb17          	auipc	s6,0xac
ffffffffc020102a:	89ab0b13          	addi	s6,s6,-1894 # ffffffffc02ac8c0 <pages>
ffffffffc020102e:	000b3503          	ld	a0,0(s6)
ffffffffc0201032:	00080a37          	lui	s4,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201036:	0009b703          	ld	a4,0(s3)
ffffffffc020103a:	40a48533          	sub	a0,s1,a0
ffffffffc020103e:	8519                	srai	a0,a0,0x6
ffffffffc0201040:	9552                	add	a0,a0,s4
ffffffffc0201042:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc0201046:	4685                	li	a3,1
ffffffffc0201048:	c094                	sw	a3,0(s1)
ffffffffc020104a:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc020104c:	0532                	slli	a0,a0,0xc
ffffffffc020104e:	08e7fa63          	bgeu	a5,a4,ffffffffc02010e2 <get_pte+0x19e>
ffffffffc0201052:	000ab783          	ld	a5,0(s5)
ffffffffc0201056:	6605                	lui	a2,0x1
ffffffffc0201058:	4581                	li	a1,0
ffffffffc020105a:	953e                	add	a0,a0,a5
ffffffffc020105c:	728040ef          	jal	ra,ffffffffc0205784 <memset>
    return page - pages + nbase;
ffffffffc0201060:	000b3683          	ld	a3,0(s6)
ffffffffc0201064:	40d486b3          	sub	a3,s1,a3
ffffffffc0201068:	8699                	srai	a3,a3,0x6
ffffffffc020106a:	96d2                	add	a3,a3,s4
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc020106c:	06aa                	slli	a3,a3,0xa
ffffffffc020106e:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201072:	e014                	sd	a3,0(s0)
ffffffffc0201074:	0009b703          	ld	a4,0(s3)
        }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0201078:	068a                	slli	a3,a3,0x2
ffffffffc020107a:	757d                	lui	a0,0xfffff
ffffffffc020107c:	8ee9                	and	a3,a3,a0
ffffffffc020107e:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201082:	04e7f463          	bgeu	a5,a4,ffffffffc02010ca <get_pte+0x186>
ffffffffc0201086:	000ab503          	ld	a0,0(s5)
ffffffffc020108a:	00c95913          	srli	s2,s2,0xc
ffffffffc020108e:	1ff97913          	andi	s2,s2,511
ffffffffc0201092:	96aa                	add	a3,a3,a0
ffffffffc0201094:	00391513          	slli	a0,s2,0x3
ffffffffc0201098:	9536                	add	a0,a0,a3
}
ffffffffc020109a:	70e2                	ld	ra,56(sp)
ffffffffc020109c:	7442                	ld	s0,48(sp)
ffffffffc020109e:	74a2                	ld	s1,40(sp)
ffffffffc02010a0:	7902                	ld	s2,32(sp)
ffffffffc02010a2:	69e2                	ld	s3,24(sp)
ffffffffc02010a4:	6a42                	ld	s4,16(sp)
ffffffffc02010a6:	6aa2                	ld	s5,8(sp)
ffffffffc02010a8:	6b02                	ld	s6,0(sp)
ffffffffc02010aa:	6121                	addi	sp,sp,64
ffffffffc02010ac:	8082                	ret
            return NULL;
ffffffffc02010ae:	4501                	li	a0,0
ffffffffc02010b0:	b7ed                	j	ffffffffc020109a <get_pte+0x156>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc02010b2:	00005617          	auipc	a2,0x5
ffffffffc02010b6:	4ae60613          	addi	a2,a2,1198 # ffffffffc0206560 <commands+0x838>
ffffffffc02010ba:	0e300593          	li	a1,227
ffffffffc02010be:	00005517          	auipc	a0,0x5
ffffffffc02010c2:	4ca50513          	addi	a0,a0,1226 # ffffffffc0206588 <commands+0x860>
ffffffffc02010c6:	94eff0ef          	jal	ra,ffffffffc0200214 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc02010ca:	00005617          	auipc	a2,0x5
ffffffffc02010ce:	49660613          	addi	a2,a2,1174 # ffffffffc0206560 <commands+0x838>
ffffffffc02010d2:	0ee00593          	li	a1,238
ffffffffc02010d6:	00005517          	auipc	a0,0x5
ffffffffc02010da:	4b250513          	addi	a0,a0,1202 # ffffffffc0206588 <commands+0x860>
ffffffffc02010de:	936ff0ef          	jal	ra,ffffffffc0200214 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02010e2:	86aa                	mv	a3,a0
ffffffffc02010e4:	00005617          	auipc	a2,0x5
ffffffffc02010e8:	47c60613          	addi	a2,a2,1148 # ffffffffc0206560 <commands+0x838>
ffffffffc02010ec:	0eb00593          	li	a1,235
ffffffffc02010f0:	00005517          	auipc	a0,0x5
ffffffffc02010f4:	49850513          	addi	a0,a0,1176 # ffffffffc0206588 <commands+0x860>
ffffffffc02010f8:	91cff0ef          	jal	ra,ffffffffc0200214 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02010fc:	86aa                	mv	a3,a0
ffffffffc02010fe:	00005617          	auipc	a2,0x5
ffffffffc0201102:	46260613          	addi	a2,a2,1122 # ffffffffc0206560 <commands+0x838>
ffffffffc0201106:	0df00593          	li	a1,223
ffffffffc020110a:	00005517          	auipc	a0,0x5
ffffffffc020110e:	47e50513          	addi	a0,a0,1150 # ffffffffc0206588 <commands+0x860>
ffffffffc0201112:	902ff0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0201116 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0201116:	1141                	addi	sp,sp,-16
ffffffffc0201118:	e022                	sd	s0,0(sp)
ffffffffc020111a:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020111c:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc020111e:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201120:	e25ff0ef          	jal	ra,ffffffffc0200f44 <get_pte>
    if (ptep_store != NULL) {
ffffffffc0201124:	c011                	beqz	s0,ffffffffc0201128 <get_page+0x12>
        *ptep_store = ptep;
ffffffffc0201126:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0201128:	c511                	beqz	a0,ffffffffc0201134 <get_page+0x1e>
ffffffffc020112a:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc020112c:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc020112e:	0017f713          	andi	a4,a5,1
ffffffffc0201132:	e709                	bnez	a4,ffffffffc020113c <get_page+0x26>
}
ffffffffc0201134:	60a2                	ld	ra,8(sp)
ffffffffc0201136:	6402                	ld	s0,0(sp)
ffffffffc0201138:	0141                	addi	sp,sp,16
ffffffffc020113a:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc020113c:	000ab717          	auipc	a4,0xab
ffffffffc0201140:	71c70713          	addi	a4,a4,1820 # ffffffffc02ac858 <npage>
ffffffffc0201144:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201146:	078a                	slli	a5,a5,0x2
ffffffffc0201148:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020114a:	02e7f063          	bgeu	a5,a4,ffffffffc020116a <get_page+0x54>
    return &pages[PPN(pa) - nbase];
ffffffffc020114e:	000ab717          	auipc	a4,0xab
ffffffffc0201152:	77270713          	addi	a4,a4,1906 # ffffffffc02ac8c0 <pages>
ffffffffc0201156:	6308                	ld	a0,0(a4)
ffffffffc0201158:	60a2                	ld	ra,8(sp)
ffffffffc020115a:	6402                	ld	s0,0(sp)
ffffffffc020115c:	fff80737          	lui	a4,0xfff80
ffffffffc0201160:	97ba                	add	a5,a5,a4
ffffffffc0201162:	079a                	slli	a5,a5,0x6
ffffffffc0201164:	953e                	add	a0,a0,a5
ffffffffc0201166:	0141                	addi	sp,sp,16
ffffffffc0201168:	8082                	ret
ffffffffc020116a:	cb1ff0ef          	jal	ra,ffffffffc0200e1a <pa2page.part.4>

ffffffffc020116e <unmap_range>:
        *ptep = 0;                  //(5) clear second page table entry
        tlb_invalidate(pgdir, la);  //(6) flush tlb
    }
}

void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc020116e:	711d                	addi	sp,sp,-96
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0201170:	00c5e7b3          	or	a5,a1,a2
void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc0201174:	ec86                	sd	ra,88(sp)
ffffffffc0201176:	e8a2                	sd	s0,80(sp)
ffffffffc0201178:	e4a6                	sd	s1,72(sp)
ffffffffc020117a:	e0ca                	sd	s2,64(sp)
ffffffffc020117c:	fc4e                	sd	s3,56(sp)
ffffffffc020117e:	f852                	sd	s4,48(sp)
ffffffffc0201180:	f456                	sd	s5,40(sp)
ffffffffc0201182:	f05a                	sd	s6,32(sp)
ffffffffc0201184:	ec5e                	sd	s7,24(sp)
ffffffffc0201186:	e862                	sd	s8,16(sp)
ffffffffc0201188:	e466                	sd	s9,8(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020118a:	03479713          	slli	a4,a5,0x34
ffffffffc020118e:	eb71                	bnez	a4,ffffffffc0201262 <unmap_range+0xf4>
    assert(USER_ACCESS(start, end));
ffffffffc0201190:	002007b7          	lui	a5,0x200
ffffffffc0201194:	842e                	mv	s0,a1
ffffffffc0201196:	0af5e663          	bltu	a1,a5,ffffffffc0201242 <unmap_range+0xd4>
ffffffffc020119a:	8932                	mv	s2,a2
ffffffffc020119c:	0ac5f363          	bgeu	a1,a2,ffffffffc0201242 <unmap_range+0xd4>
ffffffffc02011a0:	4785                	li	a5,1
ffffffffc02011a2:	07fe                	slli	a5,a5,0x1f
ffffffffc02011a4:	08c7ef63          	bltu	a5,a2,ffffffffc0201242 <unmap_range+0xd4>
ffffffffc02011a8:	89aa                	mv	s3,a0
            continue;
        }
        if (*ptep != 0) {
            page_remove_pte(pgdir, start, ptep);
        }
        start += PGSIZE;
ffffffffc02011aa:	6a05                	lui	s4,0x1
    if (PPN(pa) >= npage) {
ffffffffc02011ac:	000abc97          	auipc	s9,0xab
ffffffffc02011b0:	6acc8c93          	addi	s9,s9,1708 # ffffffffc02ac858 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc02011b4:	000abc17          	auipc	s8,0xab
ffffffffc02011b8:	70cc0c13          	addi	s8,s8,1804 # ffffffffc02ac8c0 <pages>
ffffffffc02011bc:	fff80bb7          	lui	s7,0xfff80
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc02011c0:	00200b37          	lui	s6,0x200
ffffffffc02011c4:	ffe00ab7          	lui	s5,0xffe00
        pte_t *ptep = get_pte(pgdir, start, 0);
ffffffffc02011c8:	4601                	li	a2,0
ffffffffc02011ca:	85a2                	mv	a1,s0
ffffffffc02011cc:	854e                	mv	a0,s3
ffffffffc02011ce:	d77ff0ef          	jal	ra,ffffffffc0200f44 <get_pte>
ffffffffc02011d2:	84aa                	mv	s1,a0
        if (ptep == NULL) {
ffffffffc02011d4:	cd21                	beqz	a0,ffffffffc020122c <unmap_range+0xbe>
        if (*ptep != 0) {
ffffffffc02011d6:	611c                	ld	a5,0(a0)
ffffffffc02011d8:	e38d                	bnez	a5,ffffffffc02011fa <unmap_range+0x8c>
        start += PGSIZE;
ffffffffc02011da:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc02011dc:	ff2466e3          	bltu	s0,s2,ffffffffc02011c8 <unmap_range+0x5a>
}
ffffffffc02011e0:	60e6                	ld	ra,88(sp)
ffffffffc02011e2:	6446                	ld	s0,80(sp)
ffffffffc02011e4:	64a6                	ld	s1,72(sp)
ffffffffc02011e6:	6906                	ld	s2,64(sp)
ffffffffc02011e8:	79e2                	ld	s3,56(sp)
ffffffffc02011ea:	7a42                	ld	s4,48(sp)
ffffffffc02011ec:	7aa2                	ld	s5,40(sp)
ffffffffc02011ee:	7b02                	ld	s6,32(sp)
ffffffffc02011f0:	6be2                	ld	s7,24(sp)
ffffffffc02011f2:	6c42                	ld	s8,16(sp)
ffffffffc02011f4:	6ca2                	ld	s9,8(sp)
ffffffffc02011f6:	6125                	addi	sp,sp,96
ffffffffc02011f8:	8082                	ret
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc02011fa:	0017f713          	andi	a4,a5,1
ffffffffc02011fe:	df71                	beqz	a4,ffffffffc02011da <unmap_range+0x6c>
    if (PPN(pa) >= npage) {
ffffffffc0201200:	000cb703          	ld	a4,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201204:	078a                	slli	a5,a5,0x2
ffffffffc0201206:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201208:	06e7fd63          	bgeu	a5,a4,ffffffffc0201282 <unmap_range+0x114>
    return &pages[PPN(pa) - nbase];
ffffffffc020120c:	000c3503          	ld	a0,0(s8)
ffffffffc0201210:	97de                	add	a5,a5,s7
ffffffffc0201212:	079a                	slli	a5,a5,0x6
ffffffffc0201214:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0201216:	411c                	lw	a5,0(a0)
ffffffffc0201218:	fff7871b          	addiw	a4,a5,-1
ffffffffc020121c:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc020121e:	cf11                	beqz	a4,ffffffffc020123a <unmap_range+0xcc>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0201220:	0004b023          	sd	zero,0(s1)
}

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la) {
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201224:	12040073          	sfence.vma	s0
        start += PGSIZE;
ffffffffc0201228:	9452                	add	s0,s0,s4
ffffffffc020122a:	bf4d                	j	ffffffffc02011dc <unmap_range+0x6e>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc020122c:	945a                	add	s0,s0,s6
ffffffffc020122e:	01547433          	and	s0,s0,s5
    } while (start != 0 && start < end);
ffffffffc0201232:	d45d                	beqz	s0,ffffffffc02011e0 <unmap_range+0x72>
ffffffffc0201234:	f9246ae3          	bltu	s0,s2,ffffffffc02011c8 <unmap_range+0x5a>
ffffffffc0201238:	b765                	j	ffffffffc02011e0 <unmap_range+0x72>
            free_page(page);
ffffffffc020123a:	4585                	li	a1,1
ffffffffc020123c:	c83ff0ef          	jal	ra,ffffffffc0200ebe <free_pages>
ffffffffc0201240:	b7c5                	j	ffffffffc0201220 <unmap_range+0xb2>
    assert(USER_ACCESS(start, end));
ffffffffc0201242:	00006697          	auipc	a3,0x6
ffffffffc0201246:	94668693          	addi	a3,a3,-1722 # ffffffffc0206b88 <commands+0xe60>
ffffffffc020124a:	00005617          	auipc	a2,0x5
ffffffffc020124e:	f5e60613          	addi	a2,a2,-162 # ffffffffc02061a8 <commands+0x480>
ffffffffc0201252:	11000593          	li	a1,272
ffffffffc0201256:	00005517          	auipc	a0,0x5
ffffffffc020125a:	33250513          	addi	a0,a0,818 # ffffffffc0206588 <commands+0x860>
ffffffffc020125e:	fb7fe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0201262:	00006697          	auipc	a3,0x6
ffffffffc0201266:	8f668693          	addi	a3,a3,-1802 # ffffffffc0206b58 <commands+0xe30>
ffffffffc020126a:	00005617          	auipc	a2,0x5
ffffffffc020126e:	f3e60613          	addi	a2,a2,-194 # ffffffffc02061a8 <commands+0x480>
ffffffffc0201272:	10f00593          	li	a1,271
ffffffffc0201276:	00005517          	auipc	a0,0x5
ffffffffc020127a:	31250513          	addi	a0,a0,786 # ffffffffc0206588 <commands+0x860>
ffffffffc020127e:	f97fe0ef          	jal	ra,ffffffffc0200214 <__panic>
ffffffffc0201282:	b99ff0ef          	jal	ra,ffffffffc0200e1a <pa2page.part.4>

ffffffffc0201286 <exit_range>:
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc0201286:	7119                	addi	sp,sp,-128
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0201288:	00c5e7b3          	or	a5,a1,a2
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc020128c:	fc86                	sd	ra,120(sp)
ffffffffc020128e:	f8a2                	sd	s0,112(sp)
ffffffffc0201290:	f4a6                	sd	s1,104(sp)
ffffffffc0201292:	f0ca                	sd	s2,96(sp)
ffffffffc0201294:	ecce                	sd	s3,88(sp)
ffffffffc0201296:	e8d2                	sd	s4,80(sp)
ffffffffc0201298:	e4d6                	sd	s5,72(sp)
ffffffffc020129a:	e0da                	sd	s6,64(sp)
ffffffffc020129c:	fc5e                	sd	s7,56(sp)
ffffffffc020129e:	f862                	sd	s8,48(sp)
ffffffffc02012a0:	f466                	sd	s9,40(sp)
ffffffffc02012a2:	f06a                	sd	s10,32(sp)
ffffffffc02012a4:	ec6e                	sd	s11,24(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02012a6:	03479713          	slli	a4,a5,0x34
ffffffffc02012aa:	1c071163          	bnez	a4,ffffffffc020146c <exit_range+0x1e6>
    assert(USER_ACCESS(start, end));
ffffffffc02012ae:	002007b7          	lui	a5,0x200
ffffffffc02012b2:	20f5e563          	bltu	a1,a5,ffffffffc02014bc <exit_range+0x236>
ffffffffc02012b6:	8b32                	mv	s6,a2
ffffffffc02012b8:	20c5f263          	bgeu	a1,a2,ffffffffc02014bc <exit_range+0x236>
ffffffffc02012bc:	4785                	li	a5,1
ffffffffc02012be:	07fe                	slli	a5,a5,0x1f
ffffffffc02012c0:	1ec7ee63          	bltu	a5,a2,ffffffffc02014bc <exit_range+0x236>
    d1start = ROUNDDOWN(start, PDSIZE);
ffffffffc02012c4:	c00009b7          	lui	s3,0xc0000
ffffffffc02012c8:	400007b7          	lui	a5,0x40000
ffffffffc02012cc:	0135f9b3          	and	s3,a1,s3
ffffffffc02012d0:	99be                	add	s3,s3,a5
        pde1 = pgdir[PDX1(d1start)];
ffffffffc02012d2:	c0000337          	lui	t1,0xc0000
ffffffffc02012d6:	00698933          	add	s2,s3,t1
ffffffffc02012da:	01e95913          	srli	s2,s2,0x1e
ffffffffc02012de:	1ff97913          	andi	s2,s2,511
ffffffffc02012e2:	8e2a                	mv	t3,a0
ffffffffc02012e4:	090e                	slli	s2,s2,0x3
ffffffffc02012e6:	9972                	add	s2,s2,t3
ffffffffc02012e8:	00093b83          	ld	s7,0(s2)
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc02012ec:	ffe004b7          	lui	s1,0xffe00
    return KADDR(page2pa(page));
ffffffffc02012f0:	5dfd                	li	s11,-1
        if (pde1&PTE_V){
ffffffffc02012f2:	001bf793          	andi	a5,s7,1
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc02012f6:	8ced                	and	s1,s1,a1
    if (PPN(pa) >= npage) {
ffffffffc02012f8:	000abd17          	auipc	s10,0xab
ffffffffc02012fc:	560d0d13          	addi	s10,s10,1376 # ffffffffc02ac858 <npage>
    return KADDR(page2pa(page));
ffffffffc0201300:	00cddd93          	srli	s11,s11,0xc
ffffffffc0201304:	000ab717          	auipc	a4,0xab
ffffffffc0201308:	5ac70713          	addi	a4,a4,1452 # ffffffffc02ac8b0 <va_pa_offset>
    return &pages[PPN(pa) - nbase];
ffffffffc020130c:	000abe97          	auipc	t4,0xab
ffffffffc0201310:	5b4e8e93          	addi	t4,t4,1460 # ffffffffc02ac8c0 <pages>
        if (pde1&PTE_V){
ffffffffc0201314:	e79d                	bnez	a5,ffffffffc0201342 <exit_range+0xbc>
    } while (d1start != 0 && d1start < end);
ffffffffc0201316:	12098963          	beqz	s3,ffffffffc0201448 <exit_range+0x1c2>
ffffffffc020131a:	400007b7          	lui	a5,0x40000
ffffffffc020131e:	84ce                	mv	s1,s3
ffffffffc0201320:	97ce                	add	a5,a5,s3
ffffffffc0201322:	1369f363          	bgeu	s3,s6,ffffffffc0201448 <exit_range+0x1c2>
ffffffffc0201326:	89be                	mv	s3,a5
        pde1 = pgdir[PDX1(d1start)];
ffffffffc0201328:	00698933          	add	s2,s3,t1
ffffffffc020132c:	01e95913          	srli	s2,s2,0x1e
ffffffffc0201330:	1ff97913          	andi	s2,s2,511
ffffffffc0201334:	090e                	slli	s2,s2,0x3
ffffffffc0201336:	9972                	add	s2,s2,t3
ffffffffc0201338:	00093b83          	ld	s7,0(s2)
        if (pde1&PTE_V){
ffffffffc020133c:	001bf793          	andi	a5,s7,1
ffffffffc0201340:	dbf9                	beqz	a5,ffffffffc0201316 <exit_range+0x90>
    if (PPN(pa) >= npage) {
ffffffffc0201342:	000d3783          	ld	a5,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201346:	0b8a                	slli	s7,s7,0x2
ffffffffc0201348:	00cbdb93          	srli	s7,s7,0xc
    if (PPN(pa) >= npage) {
ffffffffc020134c:	14fbfc63          	bgeu	s7,a5,ffffffffc02014a4 <exit_range+0x21e>
    return &pages[PPN(pa) - nbase];
ffffffffc0201350:	fff80ab7          	lui	s5,0xfff80
ffffffffc0201354:	9ade                	add	s5,s5,s7
    return page - pages + nbase;
ffffffffc0201356:	000806b7          	lui	a3,0x80
ffffffffc020135a:	96d6                	add	a3,a3,s5
ffffffffc020135c:	006a9593          	slli	a1,s5,0x6
    return KADDR(page2pa(page));
ffffffffc0201360:	01b6f633          	and	a2,a3,s11
    return page - pages + nbase;
ffffffffc0201364:	e42e                	sd	a1,8(sp)
    return page2ppn(page) << PGSHIFT;
ffffffffc0201366:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0201368:	12f67263          	bgeu	a2,a5,ffffffffc020148c <exit_range+0x206>
ffffffffc020136c:	00073a03          	ld	s4,0(a4)
            free_pd0 = 1;
ffffffffc0201370:	4c85                	li	s9,1
    return &pages[PPN(pa) - nbase];
ffffffffc0201372:	fff808b7          	lui	a7,0xfff80
    return KADDR(page2pa(page));
ffffffffc0201376:	9a36                	add	s4,s4,a3
    return page - pages + nbase;
ffffffffc0201378:	00080837          	lui	a6,0x80
ffffffffc020137c:	6a85                	lui	s5,0x1
                d0start += PTSIZE;
ffffffffc020137e:	00200c37          	lui	s8,0x200
ffffffffc0201382:	a801                	j	ffffffffc0201392 <exit_range+0x10c>
                    free_pd0 = 0;
ffffffffc0201384:	4c81                	li	s9,0
                d0start += PTSIZE;
ffffffffc0201386:	94e2                	add	s1,s1,s8
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc0201388:	c0d9                	beqz	s1,ffffffffc020140e <exit_range+0x188>
ffffffffc020138a:	0934f263          	bgeu	s1,s3,ffffffffc020140e <exit_range+0x188>
ffffffffc020138e:	0d64fc63          	bgeu	s1,s6,ffffffffc0201466 <exit_range+0x1e0>
                pde0 = pd0[PDX0(d0start)];
ffffffffc0201392:	0154d413          	srli	s0,s1,0x15
ffffffffc0201396:	1ff47413          	andi	s0,s0,511
ffffffffc020139a:	040e                	slli	s0,s0,0x3
ffffffffc020139c:	9452                	add	s0,s0,s4
ffffffffc020139e:	601c                	ld	a5,0(s0)
                if (pde0&PTE_V) {
ffffffffc02013a0:	0017f693          	andi	a3,a5,1
ffffffffc02013a4:	d2e5                	beqz	a3,ffffffffc0201384 <exit_range+0xfe>
    if (PPN(pa) >= npage) {
ffffffffc02013a6:	000d3583          	ld	a1,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc02013aa:	00279513          	slli	a0,a5,0x2
ffffffffc02013ae:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc02013b0:	0eb57a63          	bgeu	a0,a1,ffffffffc02014a4 <exit_range+0x21e>
    return &pages[PPN(pa) - nbase];
ffffffffc02013b4:	9546                	add	a0,a0,a7
    return page - pages + nbase;
ffffffffc02013b6:	010506b3          	add	a3,a0,a6
    return KADDR(page2pa(page));
ffffffffc02013ba:	01b6f7b3          	and	a5,a3,s11
    return page - pages + nbase;
ffffffffc02013be:	051a                	slli	a0,a0,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc02013c0:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02013c2:	0cb7f563          	bgeu	a5,a1,ffffffffc020148c <exit_range+0x206>
ffffffffc02013c6:	631c                	ld	a5,0(a4)
ffffffffc02013c8:	96be                	add	a3,a3,a5
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc02013ca:	015685b3          	add	a1,a3,s5
                        if (pt[i]&PTE_V){
ffffffffc02013ce:	629c                	ld	a5,0(a3)
ffffffffc02013d0:	8b85                	andi	a5,a5,1
ffffffffc02013d2:	fbd5                	bnez	a5,ffffffffc0201386 <exit_range+0x100>
ffffffffc02013d4:	06a1                	addi	a3,a3,8
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc02013d6:	fed59ce3          	bne	a1,a3,ffffffffc02013ce <exit_range+0x148>
    return &pages[PPN(pa) - nbase];
ffffffffc02013da:	000eb783          	ld	a5,0(t4)
                        free_page(pde2page(pde0));
ffffffffc02013de:	4585                	li	a1,1
ffffffffc02013e0:	e072                	sd	t3,0(sp)
ffffffffc02013e2:	953e                	add	a0,a0,a5
ffffffffc02013e4:	adbff0ef          	jal	ra,ffffffffc0200ebe <free_pages>
                d0start += PTSIZE;
ffffffffc02013e8:	94e2                	add	s1,s1,s8
                        pd0[PDX0(d0start)] = 0;
ffffffffc02013ea:	00043023          	sd	zero,0(s0)
ffffffffc02013ee:	000abe97          	auipc	t4,0xab
ffffffffc02013f2:	4d2e8e93          	addi	t4,t4,1234 # ffffffffc02ac8c0 <pages>
ffffffffc02013f6:	6e02                	ld	t3,0(sp)
ffffffffc02013f8:	c0000337          	lui	t1,0xc0000
ffffffffc02013fc:	fff808b7          	lui	a7,0xfff80
ffffffffc0201400:	00080837          	lui	a6,0x80
ffffffffc0201404:	000ab717          	auipc	a4,0xab
ffffffffc0201408:	4ac70713          	addi	a4,a4,1196 # ffffffffc02ac8b0 <va_pa_offset>
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc020140c:	fcbd                	bnez	s1,ffffffffc020138a <exit_range+0x104>
            if (free_pd0) {
ffffffffc020140e:	f00c84e3          	beqz	s9,ffffffffc0201316 <exit_range+0x90>
    if (PPN(pa) >= npage) {
ffffffffc0201412:	000d3783          	ld	a5,0(s10)
ffffffffc0201416:	e072                	sd	t3,0(sp)
ffffffffc0201418:	08fbf663          	bgeu	s7,a5,ffffffffc02014a4 <exit_range+0x21e>
    return &pages[PPN(pa) - nbase];
ffffffffc020141c:	000eb503          	ld	a0,0(t4)
                free_page(pde2page(pde1));
ffffffffc0201420:	67a2                	ld	a5,8(sp)
ffffffffc0201422:	4585                	li	a1,1
ffffffffc0201424:	953e                	add	a0,a0,a5
ffffffffc0201426:	a99ff0ef          	jal	ra,ffffffffc0200ebe <free_pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc020142a:	00093023          	sd	zero,0(s2)
ffffffffc020142e:	000ab717          	auipc	a4,0xab
ffffffffc0201432:	48270713          	addi	a4,a4,1154 # ffffffffc02ac8b0 <va_pa_offset>
ffffffffc0201436:	c0000337          	lui	t1,0xc0000
ffffffffc020143a:	6e02                	ld	t3,0(sp)
ffffffffc020143c:	000abe97          	auipc	t4,0xab
ffffffffc0201440:	484e8e93          	addi	t4,t4,1156 # ffffffffc02ac8c0 <pages>
    } while (d1start != 0 && d1start < end);
ffffffffc0201444:	ec099be3          	bnez	s3,ffffffffc020131a <exit_range+0x94>
}
ffffffffc0201448:	70e6                	ld	ra,120(sp)
ffffffffc020144a:	7446                	ld	s0,112(sp)
ffffffffc020144c:	74a6                	ld	s1,104(sp)
ffffffffc020144e:	7906                	ld	s2,96(sp)
ffffffffc0201450:	69e6                	ld	s3,88(sp)
ffffffffc0201452:	6a46                	ld	s4,80(sp)
ffffffffc0201454:	6aa6                	ld	s5,72(sp)
ffffffffc0201456:	6b06                	ld	s6,64(sp)
ffffffffc0201458:	7be2                	ld	s7,56(sp)
ffffffffc020145a:	7c42                	ld	s8,48(sp)
ffffffffc020145c:	7ca2                	ld	s9,40(sp)
ffffffffc020145e:	7d02                	ld	s10,32(sp)
ffffffffc0201460:	6de2                	ld	s11,24(sp)
ffffffffc0201462:	6109                	addi	sp,sp,128
ffffffffc0201464:	8082                	ret
            if (free_pd0) {
ffffffffc0201466:	ea0c8ae3          	beqz	s9,ffffffffc020131a <exit_range+0x94>
ffffffffc020146a:	b765                	j	ffffffffc0201412 <exit_range+0x18c>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020146c:	00005697          	auipc	a3,0x5
ffffffffc0201470:	6ec68693          	addi	a3,a3,1772 # ffffffffc0206b58 <commands+0xe30>
ffffffffc0201474:	00005617          	auipc	a2,0x5
ffffffffc0201478:	d3460613          	addi	a2,a2,-716 # ffffffffc02061a8 <commands+0x480>
ffffffffc020147c:	12000593          	li	a1,288
ffffffffc0201480:	00005517          	auipc	a0,0x5
ffffffffc0201484:	10850513          	addi	a0,a0,264 # ffffffffc0206588 <commands+0x860>
ffffffffc0201488:	d8dfe0ef          	jal	ra,ffffffffc0200214 <__panic>
    return KADDR(page2pa(page));
ffffffffc020148c:	00005617          	auipc	a2,0x5
ffffffffc0201490:	0d460613          	addi	a2,a2,212 # ffffffffc0206560 <commands+0x838>
ffffffffc0201494:	06900593          	li	a1,105
ffffffffc0201498:	00005517          	auipc	a0,0x5
ffffffffc020149c:	12050513          	addi	a0,a0,288 # ffffffffc02065b8 <commands+0x890>
ffffffffc02014a0:	d75fe0ef          	jal	ra,ffffffffc0200214 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02014a4:	00005617          	auipc	a2,0x5
ffffffffc02014a8:	0f460613          	addi	a2,a2,244 # ffffffffc0206598 <commands+0x870>
ffffffffc02014ac:	06200593          	li	a1,98
ffffffffc02014b0:	00005517          	auipc	a0,0x5
ffffffffc02014b4:	10850513          	addi	a0,a0,264 # ffffffffc02065b8 <commands+0x890>
ffffffffc02014b8:	d5dfe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc02014bc:	00005697          	auipc	a3,0x5
ffffffffc02014c0:	6cc68693          	addi	a3,a3,1740 # ffffffffc0206b88 <commands+0xe60>
ffffffffc02014c4:	00005617          	auipc	a2,0x5
ffffffffc02014c8:	ce460613          	addi	a2,a2,-796 # ffffffffc02061a8 <commands+0x480>
ffffffffc02014cc:	12100593          	li	a1,289
ffffffffc02014d0:	00005517          	auipc	a0,0x5
ffffffffc02014d4:	0b850513          	addi	a0,a0,184 # ffffffffc0206588 <commands+0x860>
ffffffffc02014d8:	d3dfe0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc02014dc <page_remove>:
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc02014dc:	1101                	addi	sp,sp,-32
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02014de:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc02014e0:	e426                	sd	s1,8(sp)
ffffffffc02014e2:	ec06                	sd	ra,24(sp)
ffffffffc02014e4:	e822                	sd	s0,16(sp)
ffffffffc02014e6:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02014e8:	a5dff0ef          	jal	ra,ffffffffc0200f44 <get_pte>
    if (ptep != NULL) {
ffffffffc02014ec:	c511                	beqz	a0,ffffffffc02014f8 <page_remove+0x1c>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc02014ee:	611c                	ld	a5,0(a0)
ffffffffc02014f0:	842a                	mv	s0,a0
ffffffffc02014f2:	0017f713          	andi	a4,a5,1
ffffffffc02014f6:	e711                	bnez	a4,ffffffffc0201502 <page_remove+0x26>
}
ffffffffc02014f8:	60e2                	ld	ra,24(sp)
ffffffffc02014fa:	6442                	ld	s0,16(sp)
ffffffffc02014fc:	64a2                	ld	s1,8(sp)
ffffffffc02014fe:	6105                	addi	sp,sp,32
ffffffffc0201500:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0201502:	000ab717          	auipc	a4,0xab
ffffffffc0201506:	35670713          	addi	a4,a4,854 # ffffffffc02ac858 <npage>
ffffffffc020150a:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc020150c:	078a                	slli	a5,a5,0x2
ffffffffc020150e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201510:	02e7fe63          	bgeu	a5,a4,ffffffffc020154c <page_remove+0x70>
    return &pages[PPN(pa) - nbase];
ffffffffc0201514:	000ab717          	auipc	a4,0xab
ffffffffc0201518:	3ac70713          	addi	a4,a4,940 # ffffffffc02ac8c0 <pages>
ffffffffc020151c:	6308                	ld	a0,0(a4)
ffffffffc020151e:	fff80737          	lui	a4,0xfff80
ffffffffc0201522:	97ba                	add	a5,a5,a4
ffffffffc0201524:	079a                	slli	a5,a5,0x6
ffffffffc0201526:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0201528:	411c                	lw	a5,0(a0)
ffffffffc020152a:	fff7871b          	addiw	a4,a5,-1
ffffffffc020152e:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0201530:	cb11                	beqz	a4,ffffffffc0201544 <page_remove+0x68>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0201532:	00043023          	sd	zero,0(s0)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201536:	12048073          	sfence.vma	s1
}
ffffffffc020153a:	60e2                	ld	ra,24(sp)
ffffffffc020153c:	6442                	ld	s0,16(sp)
ffffffffc020153e:	64a2                	ld	s1,8(sp)
ffffffffc0201540:	6105                	addi	sp,sp,32
ffffffffc0201542:	8082                	ret
            free_page(page);
ffffffffc0201544:	4585                	li	a1,1
ffffffffc0201546:	979ff0ef          	jal	ra,ffffffffc0200ebe <free_pages>
ffffffffc020154a:	b7e5                	j	ffffffffc0201532 <page_remove+0x56>
ffffffffc020154c:	8cfff0ef          	jal	ra,ffffffffc0200e1a <pa2page.part.4>

ffffffffc0201550 <page_insert>:
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201550:	7179                	addi	sp,sp,-48
ffffffffc0201552:	e44e                	sd	s3,8(sp)
ffffffffc0201554:	89b2                	mv	s3,a2
ffffffffc0201556:	f022                	sd	s0,32(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201558:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc020155a:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc020155c:	85ce                	mv	a1,s3
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc020155e:	ec26                	sd	s1,24(sp)
ffffffffc0201560:	f406                	sd	ra,40(sp)
ffffffffc0201562:	e84a                	sd	s2,16(sp)
ffffffffc0201564:	e052                	sd	s4,0(sp)
ffffffffc0201566:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201568:	9ddff0ef          	jal	ra,ffffffffc0200f44 <get_pte>
    if (ptep == NULL) {
ffffffffc020156c:	cd49                	beqz	a0,ffffffffc0201606 <page_insert+0xb6>
    page->ref += 1;
ffffffffc020156e:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V) {
ffffffffc0201570:	611c                	ld	a5,0(a0)
ffffffffc0201572:	892a                	mv	s2,a0
ffffffffc0201574:	0016871b          	addiw	a4,a3,1
ffffffffc0201578:	c018                	sw	a4,0(s0)
ffffffffc020157a:	0017f713          	andi	a4,a5,1
ffffffffc020157e:	ef05                	bnez	a4,ffffffffc02015b6 <page_insert+0x66>
ffffffffc0201580:	000ab797          	auipc	a5,0xab
ffffffffc0201584:	34078793          	addi	a5,a5,832 # ffffffffc02ac8c0 <pages>
ffffffffc0201588:	6398                	ld	a4,0(a5)
    return page - pages + nbase;
ffffffffc020158a:	8c19                	sub	s0,s0,a4
ffffffffc020158c:	000806b7          	lui	a3,0x80
ffffffffc0201590:	8419                	srai	s0,s0,0x6
ffffffffc0201592:	9436                	add	s0,s0,a3
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201594:	042a                	slli	s0,s0,0xa
ffffffffc0201596:	8c45                	or	s0,s0,s1
ffffffffc0201598:	00146413          	ori	s0,s0,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc020159c:	00893023          	sd	s0,0(s2)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02015a0:	12098073          	sfence.vma	s3
    return 0;
ffffffffc02015a4:	4501                	li	a0,0
}
ffffffffc02015a6:	70a2                	ld	ra,40(sp)
ffffffffc02015a8:	7402                	ld	s0,32(sp)
ffffffffc02015aa:	64e2                	ld	s1,24(sp)
ffffffffc02015ac:	6942                	ld	s2,16(sp)
ffffffffc02015ae:	69a2                	ld	s3,8(sp)
ffffffffc02015b0:	6a02                	ld	s4,0(sp)
ffffffffc02015b2:	6145                	addi	sp,sp,48
ffffffffc02015b4:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc02015b6:	000ab717          	auipc	a4,0xab
ffffffffc02015ba:	2a270713          	addi	a4,a4,674 # ffffffffc02ac858 <npage>
ffffffffc02015be:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc02015c0:	078a                	slli	a5,a5,0x2
ffffffffc02015c2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02015c4:	04e7f363          	bgeu	a5,a4,ffffffffc020160a <page_insert+0xba>
    return &pages[PPN(pa) - nbase];
ffffffffc02015c8:	000aba17          	auipc	s4,0xab
ffffffffc02015cc:	2f8a0a13          	addi	s4,s4,760 # ffffffffc02ac8c0 <pages>
ffffffffc02015d0:	000a3703          	ld	a4,0(s4)
ffffffffc02015d4:	fff80537          	lui	a0,0xfff80
ffffffffc02015d8:	953e                	add	a0,a0,a5
ffffffffc02015da:	051a                	slli	a0,a0,0x6
ffffffffc02015dc:	953a                	add	a0,a0,a4
        if (p == page) {
ffffffffc02015de:	00a40a63          	beq	s0,a0,ffffffffc02015f2 <page_insert+0xa2>
    page->ref -= 1;
ffffffffc02015e2:	411c                	lw	a5,0(a0)
ffffffffc02015e4:	fff7869b          	addiw	a3,a5,-1
ffffffffc02015e8:	c114                	sw	a3,0(a0)
        if (page_ref(page) ==
ffffffffc02015ea:	c691                	beqz	a3,ffffffffc02015f6 <page_insert+0xa6>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02015ec:	12098073          	sfence.vma	s3
ffffffffc02015f0:	bf69                	j	ffffffffc020158a <page_insert+0x3a>
ffffffffc02015f2:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc02015f4:	bf59                	j	ffffffffc020158a <page_insert+0x3a>
            free_page(page);
ffffffffc02015f6:	4585                	li	a1,1
ffffffffc02015f8:	8c7ff0ef          	jal	ra,ffffffffc0200ebe <free_pages>
ffffffffc02015fc:	000a3703          	ld	a4,0(s4)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201600:	12098073          	sfence.vma	s3
ffffffffc0201604:	b759                	j	ffffffffc020158a <page_insert+0x3a>
        return -E_NO_MEM;
ffffffffc0201606:	5571                	li	a0,-4
ffffffffc0201608:	bf79                	j	ffffffffc02015a6 <page_insert+0x56>
ffffffffc020160a:	811ff0ef          	jal	ra,ffffffffc0200e1a <pa2page.part.4>

ffffffffc020160e <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc020160e:	00006797          	auipc	a5,0x6
ffffffffc0201612:	21a78793          	addi	a5,a5,538 # ffffffffc0207828 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201616:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0201618:	715d                	addi	sp,sp,-80
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020161a:	00005517          	auipc	a0,0x5
ffffffffc020161e:	fc650513          	addi	a0,a0,-58 # ffffffffc02065e0 <commands+0x8b8>
void pmm_init(void) {
ffffffffc0201622:	e486                	sd	ra,72(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0201624:	000ab717          	auipc	a4,0xab
ffffffffc0201628:	28f73223          	sd	a5,644(a4) # ffffffffc02ac8a8 <pmm_manager>
void pmm_init(void) {
ffffffffc020162c:	e0a2                	sd	s0,64(sp)
ffffffffc020162e:	fc26                	sd	s1,56(sp)
ffffffffc0201630:	f84a                	sd	s2,48(sp)
ffffffffc0201632:	f44e                	sd	s3,40(sp)
ffffffffc0201634:	f052                	sd	s4,32(sp)
ffffffffc0201636:	ec56                	sd	s5,24(sp)
ffffffffc0201638:	e85a                	sd	s6,16(sp)
ffffffffc020163a:	e45e                	sd	s7,8(sp)
ffffffffc020163c:	e062                	sd	s8,0(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc020163e:	000ab417          	auipc	s0,0xab
ffffffffc0201642:	26a40413          	addi	s0,s0,618 # ffffffffc02ac8a8 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201646:	a8bfe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    pmm_manager->init();
ffffffffc020164a:	601c                	ld	a5,0(s0)
ffffffffc020164c:	000ab497          	auipc	s1,0xab
ffffffffc0201650:	20c48493          	addi	s1,s1,524 # ffffffffc02ac858 <npage>
ffffffffc0201654:	000ab917          	auipc	s2,0xab
ffffffffc0201658:	26c90913          	addi	s2,s2,620 # ffffffffc02ac8c0 <pages>
ffffffffc020165c:	679c                	ld	a5,8(a5)
ffffffffc020165e:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201660:	57f5                	li	a5,-3
ffffffffc0201662:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0201664:	00005517          	auipc	a0,0x5
ffffffffc0201668:	f9450513          	addi	a0,a0,-108 # ffffffffc02065f8 <commands+0x8d0>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc020166c:	000ab717          	auipc	a4,0xab
ffffffffc0201670:	24f73223          	sd	a5,580(a4) # ffffffffc02ac8b0 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc0201674:	a5dfe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0201678:	46c5                	li	a3,17
ffffffffc020167a:	06ee                	slli	a3,a3,0x1b
ffffffffc020167c:	40100613          	li	a2,1025
ffffffffc0201680:	16fd                	addi	a3,a3,-1
ffffffffc0201682:	0656                	slli	a2,a2,0x15
ffffffffc0201684:	07e005b7          	lui	a1,0x7e00
ffffffffc0201688:	00005517          	auipc	a0,0x5
ffffffffc020168c:	f8850513          	addi	a0,a0,-120 # ffffffffc0206610 <commands+0x8e8>
ffffffffc0201690:	a41fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201694:	777d                	lui	a4,0xfffff
ffffffffc0201696:	000ac797          	auipc	a5,0xac
ffffffffc020169a:	33978793          	addi	a5,a5,825 # ffffffffc02ad9cf <end+0xfff>
ffffffffc020169e:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc02016a0:	00088737          	lui	a4,0x88
ffffffffc02016a4:	000ab697          	auipc	a3,0xab
ffffffffc02016a8:	1ae6ba23          	sd	a4,436(a3) # ffffffffc02ac858 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02016ac:	000ab717          	auipc	a4,0xab
ffffffffc02016b0:	20f73a23          	sd	a5,532(a4) # ffffffffc02ac8c0 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02016b4:	4701                	li	a4,0
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02016b6:	4685                	li	a3,1
ffffffffc02016b8:	fff80837          	lui	a6,0xfff80
ffffffffc02016bc:	a019                	j	ffffffffc02016c2 <pmm_init+0xb4>
ffffffffc02016be:	00093783          	ld	a5,0(s2)
        SetPageReserved(pages + i);
ffffffffc02016c2:	00671613          	slli	a2,a4,0x6
ffffffffc02016c6:	97b2                	add	a5,a5,a2
ffffffffc02016c8:	07a1                	addi	a5,a5,8
ffffffffc02016ca:	40d7b02f          	amoor.d	zero,a3,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02016ce:	6090                	ld	a2,0(s1)
ffffffffc02016d0:	0705                	addi	a4,a4,1
ffffffffc02016d2:	010607b3          	add	a5,a2,a6
ffffffffc02016d6:	fef764e3          	bltu	a4,a5,ffffffffc02016be <pmm_init+0xb0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02016da:	00093503          	ld	a0,0(s2)
ffffffffc02016de:	fe0007b7          	lui	a5,0xfe000
ffffffffc02016e2:	00661693          	slli	a3,a2,0x6
ffffffffc02016e6:	97aa                	add	a5,a5,a0
ffffffffc02016e8:	96be                	add	a3,a3,a5
ffffffffc02016ea:	c02007b7          	lui	a5,0xc0200
ffffffffc02016ee:	7af6eb63          	bltu	a3,a5,ffffffffc0201ea4 <pmm_init+0x896>
ffffffffc02016f2:	000ab997          	auipc	s3,0xab
ffffffffc02016f6:	1be98993          	addi	s3,s3,446 # ffffffffc02ac8b0 <va_pa_offset>
ffffffffc02016fa:	0009b583          	ld	a1,0(s3)
    if (freemem < mem_end) {
ffffffffc02016fe:	47c5                	li	a5,17
ffffffffc0201700:	07ee                	slli	a5,a5,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201702:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end) {
ffffffffc0201704:	02f6f763          	bgeu	a3,a5,ffffffffc0201732 <pmm_init+0x124>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0201708:	6585                	lui	a1,0x1
ffffffffc020170a:	15fd                	addi	a1,a1,-1
ffffffffc020170c:	96ae                	add	a3,a3,a1
    if (PPN(pa) >= npage) {
ffffffffc020170e:	00c6d713          	srli	a4,a3,0xc
ffffffffc0201712:	48c77863          	bgeu	a4,a2,ffffffffc0201ba2 <pmm_init+0x594>
    pmm_manager->init_memmap(base, n);
ffffffffc0201716:	6010                	ld	a2,0(s0)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0201718:	75fd                	lui	a1,0xfffff
ffffffffc020171a:	8eed                	and	a3,a3,a1
    return &pages[PPN(pa) - nbase];
ffffffffc020171c:	9742                	add	a4,a4,a6
    pmm_manager->init_memmap(base, n);
ffffffffc020171e:	6a10                	ld	a2,16(a2)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0201720:	40d786b3          	sub	a3,a5,a3
ffffffffc0201724:	071a                	slli	a4,a4,0x6
    pmm_manager->init_memmap(base, n);
ffffffffc0201726:	00c6d593          	srli	a1,a3,0xc
ffffffffc020172a:	953a                	add	a0,a0,a4
ffffffffc020172c:	9602                	jalr	a2
ffffffffc020172e:	0009b583          	ld	a1,0(s3)
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc0201732:	00005517          	auipc	a0,0x5
ffffffffc0201736:	f2e50513          	addi	a0,a0,-210 # ffffffffc0206660 <commands+0x938>
ffffffffc020173a:	997fe0ef          	jal	ra,ffffffffc02000d0 <cprintf>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc020173e:	601c                	ld	a5,0(s0)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0201740:	000ab417          	auipc	s0,0xab
ffffffffc0201744:	11040413          	addi	s0,s0,272 # ffffffffc02ac850 <boot_pgdir>
    pmm_manager->check();
ffffffffc0201748:	7b9c                	ld	a5,48(a5)
ffffffffc020174a:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc020174c:	00005517          	auipc	a0,0x5
ffffffffc0201750:	f2c50513          	addi	a0,a0,-212 # ffffffffc0206678 <commands+0x950>
ffffffffc0201754:	97dfe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0201758:	0000a697          	auipc	a3,0xa
ffffffffc020175c:	8a868693          	addi	a3,a3,-1880 # ffffffffc020b000 <boot_page_table_sv39>
ffffffffc0201760:	000ab797          	auipc	a5,0xab
ffffffffc0201764:	0ed7b823          	sd	a3,240(a5) # ffffffffc02ac850 <boot_pgdir>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0201768:	c02007b7          	lui	a5,0xc0200
ffffffffc020176c:	10f6e8e3          	bltu	a3,a5,ffffffffc020207c <pmm_init+0xa6e>
ffffffffc0201770:	0009b783          	ld	a5,0(s3)
ffffffffc0201774:	8e9d                	sub	a3,a3,a5
ffffffffc0201776:	000ab797          	auipc	a5,0xab
ffffffffc020177a:	14d7b123          	sd	a3,322(a5) # ffffffffc02ac8b8 <boot_cr3>
    // assert(npage <= KMEMSIZE / PGSIZE);
    // The memory starts at 2GB in RISC-V
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();
ffffffffc020177e:	f86ff0ef          	jal	ra,ffffffffc0200f04 <nr_free_pages>

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0201782:	6098                	ld	a4,0(s1)
ffffffffc0201784:	c80007b7          	lui	a5,0xc8000
ffffffffc0201788:	83b1                	srli	a5,a5,0xc
    nr_free_store=nr_free_pages();
ffffffffc020178a:	8a2a                	mv	s4,a0
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc020178c:	0ce7e8e3          	bltu	a5,a4,ffffffffc020205c <pmm_init+0xa4e>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0201790:	6008                	ld	a0,0(s0)
ffffffffc0201792:	44050263          	beqz	a0,ffffffffc0201bd6 <pmm_init+0x5c8>
ffffffffc0201796:	03451793          	slli	a5,a0,0x34
ffffffffc020179a:	42079e63          	bnez	a5,ffffffffc0201bd6 <pmm_init+0x5c8>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc020179e:	4601                	li	a2,0
ffffffffc02017a0:	4581                	li	a1,0
ffffffffc02017a2:	975ff0ef          	jal	ra,ffffffffc0201116 <get_page>
ffffffffc02017a6:	78051b63          	bnez	a0,ffffffffc0201f3c <pmm_init+0x92e>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc02017aa:	4505                	li	a0,1
ffffffffc02017ac:	e8aff0ef          	jal	ra,ffffffffc0200e36 <alloc_pages>
ffffffffc02017b0:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc02017b2:	6008                	ld	a0,0(s0)
ffffffffc02017b4:	4681                	li	a3,0
ffffffffc02017b6:	4601                	li	a2,0
ffffffffc02017b8:	85d6                	mv	a1,s5
ffffffffc02017ba:	d97ff0ef          	jal	ra,ffffffffc0201550 <page_insert>
ffffffffc02017be:	7a051f63          	bnez	a0,ffffffffc0201f7c <pmm_init+0x96e>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc02017c2:	6008                	ld	a0,0(s0)
ffffffffc02017c4:	4601                	li	a2,0
ffffffffc02017c6:	4581                	li	a1,0
ffffffffc02017c8:	f7cff0ef          	jal	ra,ffffffffc0200f44 <get_pte>
ffffffffc02017cc:	78050863          	beqz	a0,ffffffffc0201f5c <pmm_init+0x94e>
    assert(pte2page(*ptep) == p1);
ffffffffc02017d0:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02017d2:	0017f713          	andi	a4,a5,1
ffffffffc02017d6:	3e070463          	beqz	a4,ffffffffc0201bbe <pmm_init+0x5b0>
    if (PPN(pa) >= npage) {
ffffffffc02017da:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc02017dc:	078a                	slli	a5,a5,0x2
ffffffffc02017de:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02017e0:	3ce7f163          	bgeu	a5,a4,ffffffffc0201ba2 <pmm_init+0x594>
    return &pages[PPN(pa) - nbase];
ffffffffc02017e4:	00093683          	ld	a3,0(s2)
ffffffffc02017e8:	fff80637          	lui	a2,0xfff80
ffffffffc02017ec:	97b2                	add	a5,a5,a2
ffffffffc02017ee:	079a                	slli	a5,a5,0x6
ffffffffc02017f0:	97b6                	add	a5,a5,a3
ffffffffc02017f2:	72fa9563          	bne	s5,a5,ffffffffc0201f1c <pmm_init+0x90e>
    assert(page_ref(p1) == 1);
ffffffffc02017f6:	000aab83          	lw	s7,0(s5) # 1000 <_binary_obj___user_faultread_out_size-0x85c8>
ffffffffc02017fa:	4785                	li	a5,1
ffffffffc02017fc:	70fb9063          	bne	s7,a5,ffffffffc0201efc <pmm_init+0x8ee>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0201800:	6008                	ld	a0,0(s0)
ffffffffc0201802:	76fd                	lui	a3,0xfffff
ffffffffc0201804:	611c                	ld	a5,0(a0)
ffffffffc0201806:	078a                	slli	a5,a5,0x2
ffffffffc0201808:	8ff5                	and	a5,a5,a3
ffffffffc020180a:	00c7d613          	srli	a2,a5,0xc
ffffffffc020180e:	66e67e63          	bgeu	a2,a4,ffffffffc0201e8a <pmm_init+0x87c>
ffffffffc0201812:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201816:	97e2                	add	a5,a5,s8
ffffffffc0201818:	0007bb03          	ld	s6,0(a5) # ffffffffc8000000 <end+0x7d53630>
ffffffffc020181c:	0b0a                	slli	s6,s6,0x2
ffffffffc020181e:	00db7b33          	and	s6,s6,a3
ffffffffc0201822:	00cb5793          	srli	a5,s6,0xc
ffffffffc0201826:	56e7f863          	bgeu	a5,a4,ffffffffc0201d96 <pmm_init+0x788>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc020182a:	4601                	li	a2,0
ffffffffc020182c:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020182e:	9b62                	add	s6,s6,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201830:	f14ff0ef          	jal	ra,ffffffffc0200f44 <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201834:	0b21                	addi	s6,s6,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201836:	55651063          	bne	a0,s6,ffffffffc0201d76 <pmm_init+0x768>

    p2 = alloc_page();
ffffffffc020183a:	4505                	li	a0,1
ffffffffc020183c:	dfaff0ef          	jal	ra,ffffffffc0200e36 <alloc_pages>
ffffffffc0201840:	8b2a                	mv	s6,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0201842:	6008                	ld	a0,0(s0)
ffffffffc0201844:	46d1                	li	a3,20
ffffffffc0201846:	6605                	lui	a2,0x1
ffffffffc0201848:	85da                	mv	a1,s6
ffffffffc020184a:	d07ff0ef          	jal	ra,ffffffffc0201550 <page_insert>
ffffffffc020184e:	50051463          	bnez	a0,ffffffffc0201d56 <pmm_init+0x748>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201852:	6008                	ld	a0,0(s0)
ffffffffc0201854:	4601                	li	a2,0
ffffffffc0201856:	6585                	lui	a1,0x1
ffffffffc0201858:	eecff0ef          	jal	ra,ffffffffc0200f44 <get_pte>
ffffffffc020185c:	4c050d63          	beqz	a0,ffffffffc0201d36 <pmm_init+0x728>
    assert(*ptep & PTE_U);
ffffffffc0201860:	611c                	ld	a5,0(a0)
ffffffffc0201862:	0107f713          	andi	a4,a5,16
ffffffffc0201866:	4a070863          	beqz	a4,ffffffffc0201d16 <pmm_init+0x708>
    assert(*ptep & PTE_W);
ffffffffc020186a:	8b91                	andi	a5,a5,4
ffffffffc020186c:	48078563          	beqz	a5,ffffffffc0201cf6 <pmm_init+0x6e8>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0201870:	6008                	ld	a0,0(s0)
ffffffffc0201872:	611c                	ld	a5,0(a0)
ffffffffc0201874:	8bc1                	andi	a5,a5,16
ffffffffc0201876:	46078063          	beqz	a5,ffffffffc0201cd6 <pmm_init+0x6c8>
    assert(page_ref(p2) == 1);
ffffffffc020187a:	000b2783          	lw	a5,0(s6) # 200000 <_binary_obj___user_exit_out_size+0x1f5538>
ffffffffc020187e:	43779c63          	bne	a5,s7,ffffffffc0201cb6 <pmm_init+0x6a8>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0201882:	4681                	li	a3,0
ffffffffc0201884:	6605                	lui	a2,0x1
ffffffffc0201886:	85d6                	mv	a1,s5
ffffffffc0201888:	cc9ff0ef          	jal	ra,ffffffffc0201550 <page_insert>
ffffffffc020188c:	40051563          	bnez	a0,ffffffffc0201c96 <pmm_init+0x688>
    assert(page_ref(p1) == 2);
ffffffffc0201890:	000aa703          	lw	a4,0(s5)
ffffffffc0201894:	4789                	li	a5,2
ffffffffc0201896:	3ef71063          	bne	a4,a5,ffffffffc0201c76 <pmm_init+0x668>
    assert(page_ref(p2) == 0);
ffffffffc020189a:	000b2783          	lw	a5,0(s6)
ffffffffc020189e:	3a079c63          	bnez	a5,ffffffffc0201c56 <pmm_init+0x648>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02018a2:	6008                	ld	a0,0(s0)
ffffffffc02018a4:	4601                	li	a2,0
ffffffffc02018a6:	6585                	lui	a1,0x1
ffffffffc02018a8:	e9cff0ef          	jal	ra,ffffffffc0200f44 <get_pte>
ffffffffc02018ac:	38050563          	beqz	a0,ffffffffc0201c36 <pmm_init+0x628>
    assert(pte2page(*ptep) == p1);
ffffffffc02018b0:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02018b2:	00177793          	andi	a5,a4,1
ffffffffc02018b6:	30078463          	beqz	a5,ffffffffc0201bbe <pmm_init+0x5b0>
    if (PPN(pa) >= npage) {
ffffffffc02018ba:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc02018bc:	00271793          	slli	a5,a4,0x2
ffffffffc02018c0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02018c2:	2ed7f063          	bgeu	a5,a3,ffffffffc0201ba2 <pmm_init+0x594>
    return &pages[PPN(pa) - nbase];
ffffffffc02018c6:	00093683          	ld	a3,0(s2)
ffffffffc02018ca:	fff80637          	lui	a2,0xfff80
ffffffffc02018ce:	97b2                	add	a5,a5,a2
ffffffffc02018d0:	079a                	slli	a5,a5,0x6
ffffffffc02018d2:	97b6                	add	a5,a5,a3
ffffffffc02018d4:	32fa9163          	bne	s5,a5,ffffffffc0201bf6 <pmm_init+0x5e8>
    assert((*ptep & PTE_U) == 0);
ffffffffc02018d8:	8b41                	andi	a4,a4,16
ffffffffc02018da:	70071163          	bnez	a4,ffffffffc0201fdc <pmm_init+0x9ce>

    page_remove(boot_pgdir, 0x0);
ffffffffc02018de:	6008                	ld	a0,0(s0)
ffffffffc02018e0:	4581                	li	a1,0
ffffffffc02018e2:	bfbff0ef          	jal	ra,ffffffffc02014dc <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc02018e6:	000aa703          	lw	a4,0(s5)
ffffffffc02018ea:	4785                	li	a5,1
ffffffffc02018ec:	6cf71863          	bne	a4,a5,ffffffffc0201fbc <pmm_init+0x9ae>
    assert(page_ref(p2) == 0);
ffffffffc02018f0:	000b2783          	lw	a5,0(s6)
ffffffffc02018f4:	6a079463          	bnez	a5,ffffffffc0201f9c <pmm_init+0x98e>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc02018f8:	6008                	ld	a0,0(s0)
ffffffffc02018fa:	6585                	lui	a1,0x1
ffffffffc02018fc:	be1ff0ef          	jal	ra,ffffffffc02014dc <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0201900:	000aa783          	lw	a5,0(s5)
ffffffffc0201904:	50079363          	bnez	a5,ffffffffc0201e0a <pmm_init+0x7fc>
    assert(page_ref(p2) == 0);
ffffffffc0201908:	000b2783          	lw	a5,0(s6)
ffffffffc020190c:	4c079f63          	bnez	a5,ffffffffc0201dea <pmm_init+0x7dc>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0201910:	00043b03          	ld	s6,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0201914:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201916:	000b3783          	ld	a5,0(s6)
ffffffffc020191a:	078a                	slli	a5,a5,0x2
ffffffffc020191c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020191e:	28e7f263          	bgeu	a5,a4,ffffffffc0201ba2 <pmm_init+0x594>
    return &pages[PPN(pa) - nbase];
ffffffffc0201922:	fff806b7          	lui	a3,0xfff80
ffffffffc0201926:	00093503          	ld	a0,0(s2)
ffffffffc020192a:	97b6                	add	a5,a5,a3
ffffffffc020192c:	079a                	slli	a5,a5,0x6
ffffffffc020192e:	00f506b3          	add	a3,a0,a5
ffffffffc0201932:	4290                	lw	a2,0(a3)
ffffffffc0201934:	4685                	li	a3,1
ffffffffc0201936:	48d61a63          	bne	a2,a3,ffffffffc0201dca <pmm_init+0x7bc>
    return page - pages + nbase;
ffffffffc020193a:	8799                	srai	a5,a5,0x6
ffffffffc020193c:	00080ab7          	lui	s5,0x80
ffffffffc0201940:	97d6                	add	a5,a5,s5
    return KADDR(page2pa(page));
ffffffffc0201942:	00c79693          	slli	a3,a5,0xc
ffffffffc0201946:	82b1                	srli	a3,a3,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201948:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc020194a:	46e6f363          	bgeu	a3,a4,ffffffffc0201db0 <pmm_init+0x7a2>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc020194e:	0009b683          	ld	a3,0(s3)
ffffffffc0201952:	97b6                	add	a5,a5,a3
    return pa2page(PDE_ADDR(pde));
ffffffffc0201954:	639c                	ld	a5,0(a5)
ffffffffc0201956:	078a                	slli	a5,a5,0x2
ffffffffc0201958:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020195a:	24e7f463          	bgeu	a5,a4,ffffffffc0201ba2 <pmm_init+0x594>
    return &pages[PPN(pa) - nbase];
ffffffffc020195e:	415787b3          	sub	a5,a5,s5
ffffffffc0201962:	079a                	slli	a5,a5,0x6
ffffffffc0201964:	953e                	add	a0,a0,a5
ffffffffc0201966:	4585                	li	a1,1
ffffffffc0201968:	d56ff0ef          	jal	ra,ffffffffc0200ebe <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc020196c:	000b3783          	ld	a5,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc0201970:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201972:	078a                	slli	a5,a5,0x2
ffffffffc0201974:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201976:	22e7f663          	bgeu	a5,a4,ffffffffc0201ba2 <pmm_init+0x594>
    return &pages[PPN(pa) - nbase];
ffffffffc020197a:	00093503          	ld	a0,0(s2)
ffffffffc020197e:	415787b3          	sub	a5,a5,s5
ffffffffc0201982:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0201984:	953e                	add	a0,a0,a5
ffffffffc0201986:	4585                	li	a1,1
ffffffffc0201988:	d36ff0ef          	jal	ra,ffffffffc0200ebe <free_pages>
    boot_pgdir[0] = 0;
ffffffffc020198c:	601c                	ld	a5,0(s0)
ffffffffc020198e:	0007b023          	sd	zero,0(a5)
  asm volatile("sfence.vma");
ffffffffc0201992:	12000073          	sfence.vma
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0201996:	d6eff0ef          	jal	ra,ffffffffc0200f04 <nr_free_pages>
ffffffffc020199a:	68aa1163          	bne	s4,a0,ffffffffc020201c <pmm_init+0xa0e>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc020199e:	00005517          	auipc	a0,0x5
ffffffffc02019a2:	fea50513          	addi	a0,a0,-22 # ffffffffc0206988 <commands+0xc60>
ffffffffc02019a6:	f2afe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
static void check_boot_pgdir(void) {
    size_t nr_free_store;
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();
ffffffffc02019aa:	d5aff0ef          	jal	ra,ffffffffc0200f04 <nr_free_pages>

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02019ae:	6098                	ld	a4,0(s1)
ffffffffc02019b0:	c02007b7          	lui	a5,0xc0200
    nr_free_store=nr_free_pages();
ffffffffc02019b4:	8a2a                	mv	s4,a0
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02019b6:	00c71693          	slli	a3,a4,0xc
ffffffffc02019ba:	18d7f563          	bgeu	a5,a3,ffffffffc0201b44 <pmm_init+0x536>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02019be:	83b1                	srli	a5,a5,0xc
ffffffffc02019c0:	6008                	ld	a0,0(s0)
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02019c2:	c0200ab7          	lui	s5,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02019c6:	1ae7f163          	bgeu	a5,a4,ffffffffc0201b68 <pmm_init+0x55a>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02019ca:	7bfd                	lui	s7,0xfffff
ffffffffc02019cc:	6b05                	lui	s6,0x1
ffffffffc02019ce:	a029                	j	ffffffffc02019d8 <pmm_init+0x3ca>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02019d0:	00cad713          	srli	a4,s5,0xc
ffffffffc02019d4:	18f77a63          	bgeu	a4,a5,ffffffffc0201b68 <pmm_init+0x55a>
ffffffffc02019d8:	0009b583          	ld	a1,0(s3)
ffffffffc02019dc:	4601                	li	a2,0
ffffffffc02019de:	95d6                	add	a1,a1,s5
ffffffffc02019e0:	d64ff0ef          	jal	ra,ffffffffc0200f44 <get_pte>
ffffffffc02019e4:	16050263          	beqz	a0,ffffffffc0201b48 <pmm_init+0x53a>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02019e8:	611c                	ld	a5,0(a0)
ffffffffc02019ea:	078a                	slli	a5,a5,0x2
ffffffffc02019ec:	0177f7b3          	and	a5,a5,s7
ffffffffc02019f0:	19579963          	bne	a5,s5,ffffffffc0201b82 <pmm_init+0x574>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02019f4:	609c                	ld	a5,0(s1)
ffffffffc02019f6:	9ada                	add	s5,s5,s6
ffffffffc02019f8:	6008                	ld	a0,0(s0)
ffffffffc02019fa:	00c79713          	slli	a4,a5,0xc
ffffffffc02019fe:	fceae9e3          	bltu	s5,a4,ffffffffc02019d0 <pmm_init+0x3c2>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc0201a02:	611c                	ld	a5,0(a0)
ffffffffc0201a04:	62079c63          	bnez	a5,ffffffffc020203c <pmm_init+0xa2e>

    struct Page *p;
    p = alloc_page();
ffffffffc0201a08:	4505                	li	a0,1
ffffffffc0201a0a:	c2cff0ef          	jal	ra,ffffffffc0200e36 <alloc_pages>
ffffffffc0201a0e:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0201a10:	6008                	ld	a0,0(s0)
ffffffffc0201a12:	4699                	li	a3,6
ffffffffc0201a14:	10000613          	li	a2,256
ffffffffc0201a18:	85d6                	mv	a1,s5
ffffffffc0201a1a:	b37ff0ef          	jal	ra,ffffffffc0201550 <page_insert>
ffffffffc0201a1e:	1e051c63          	bnez	a0,ffffffffc0201c16 <pmm_init+0x608>
    assert(page_ref(p) == 1);
ffffffffc0201a22:	000aa703          	lw	a4,0(s5) # ffffffffc0200000 <kern_entry>
ffffffffc0201a26:	4785                	li	a5,1
ffffffffc0201a28:	44f71163          	bne	a4,a5,ffffffffc0201e6a <pmm_init+0x85c>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0201a2c:	6008                	ld	a0,0(s0)
ffffffffc0201a2e:	6b05                	lui	s6,0x1
ffffffffc0201a30:	4699                	li	a3,6
ffffffffc0201a32:	100b0613          	addi	a2,s6,256 # 1100 <_binary_obj___user_faultread_out_size-0x84c8>
ffffffffc0201a36:	85d6                	mv	a1,s5
ffffffffc0201a38:	b19ff0ef          	jal	ra,ffffffffc0201550 <page_insert>
ffffffffc0201a3c:	40051763          	bnez	a0,ffffffffc0201e4a <pmm_init+0x83c>
    assert(page_ref(p) == 2);
ffffffffc0201a40:	000aa703          	lw	a4,0(s5)
ffffffffc0201a44:	4789                	li	a5,2
ffffffffc0201a46:	3ef71263          	bne	a4,a5,ffffffffc0201e2a <pmm_init+0x81c>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0201a4a:	00005597          	auipc	a1,0x5
ffffffffc0201a4e:	07658593          	addi	a1,a1,118 # ffffffffc0206ac0 <commands+0xd98>
ffffffffc0201a52:	10000513          	li	a0,256
ffffffffc0201a56:	4d5030ef          	jal	ra,ffffffffc020572a <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0201a5a:	100b0593          	addi	a1,s6,256
ffffffffc0201a5e:	10000513          	li	a0,256
ffffffffc0201a62:	4db030ef          	jal	ra,ffffffffc020573c <strcmp>
ffffffffc0201a66:	44051b63          	bnez	a0,ffffffffc0201ebc <pmm_init+0x8ae>
    return page - pages + nbase;
ffffffffc0201a6a:	00093683          	ld	a3,0(s2)
ffffffffc0201a6e:	00080737          	lui	a4,0x80
    return KADDR(page2pa(page));
ffffffffc0201a72:	5b7d                	li	s6,-1
    return page - pages + nbase;
ffffffffc0201a74:	40da86b3          	sub	a3,s5,a3
ffffffffc0201a78:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0201a7a:	609c                	ld	a5,0(s1)
    return page - pages + nbase;
ffffffffc0201a7c:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc0201a7e:	00cb5b13          	srli	s6,s6,0xc
ffffffffc0201a82:	0166f733          	and	a4,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc0201a86:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0201a88:	10f77f63          	bgeu	a4,a5,ffffffffc0201ba6 <pmm_init+0x598>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0201a8c:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0201a90:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0201a94:	96be                	add	a3,a3,a5
ffffffffc0201a96:	10068023          	sb	zero,256(a3) # fffffffffff80100 <end+0x3fcd3730>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0201a9a:	44d030ef          	jal	ra,ffffffffc02056e6 <strlen>
ffffffffc0201a9e:	54051f63          	bnez	a0,ffffffffc0201ffc <pmm_init+0x9ee>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0201aa2:	00043b83          	ld	s7,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0201aa6:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201aa8:	000bb683          	ld	a3,0(s7) # fffffffffffff000 <end+0x3fd52630>
ffffffffc0201aac:	068a                	slli	a3,a3,0x2
ffffffffc0201aae:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201ab0:	0ef6f963          	bgeu	a3,a5,ffffffffc0201ba2 <pmm_init+0x594>
    return KADDR(page2pa(page));
ffffffffc0201ab4:	0166fb33          	and	s6,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc0201ab8:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0201aba:	0efb7663          	bgeu	s6,a5,ffffffffc0201ba6 <pmm_init+0x598>
ffffffffc0201abe:	0009b983          	ld	s3,0(s3)
    free_page(p);
ffffffffc0201ac2:	4585                	li	a1,1
ffffffffc0201ac4:	8556                	mv	a0,s5
ffffffffc0201ac6:	99b6                	add	s3,s3,a3
ffffffffc0201ac8:	bf6ff0ef          	jal	ra,ffffffffc0200ebe <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0201acc:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc0201ad0:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201ad2:	078a                	slli	a5,a5,0x2
ffffffffc0201ad4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201ad6:	0ce7f663          	bgeu	a5,a4,ffffffffc0201ba2 <pmm_init+0x594>
    return &pages[PPN(pa) - nbase];
ffffffffc0201ada:	00093503          	ld	a0,0(s2)
ffffffffc0201ade:	fff809b7          	lui	s3,0xfff80
ffffffffc0201ae2:	97ce                	add	a5,a5,s3
ffffffffc0201ae4:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc0201ae6:	953e                	add	a0,a0,a5
ffffffffc0201ae8:	4585                	li	a1,1
ffffffffc0201aea:	bd4ff0ef          	jal	ra,ffffffffc0200ebe <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0201aee:	000bb783          	ld	a5,0(s7)
    if (PPN(pa) >= npage) {
ffffffffc0201af2:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201af4:	078a                	slli	a5,a5,0x2
ffffffffc0201af6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201af8:	0ae7f563          	bgeu	a5,a4,ffffffffc0201ba2 <pmm_init+0x594>
    return &pages[PPN(pa) - nbase];
ffffffffc0201afc:	00093503          	ld	a0,0(s2)
ffffffffc0201b00:	97ce                	add	a5,a5,s3
ffffffffc0201b02:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0201b04:	953e                	add	a0,a0,a5
ffffffffc0201b06:	4585                	li	a1,1
ffffffffc0201b08:	bb6ff0ef          	jal	ra,ffffffffc0200ebe <free_pages>
    boot_pgdir[0] = 0;
ffffffffc0201b0c:	601c                	ld	a5,0(s0)
ffffffffc0201b0e:	0007b023          	sd	zero,0(a5) # ffffffffc0200000 <kern_entry>
  asm volatile("sfence.vma");
ffffffffc0201b12:	12000073          	sfence.vma
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0201b16:	beeff0ef          	jal	ra,ffffffffc0200f04 <nr_free_pages>
ffffffffc0201b1a:	3caa1163          	bne	s4,a0,ffffffffc0201edc <pmm_init+0x8ce>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0201b1e:	00005517          	auipc	a0,0x5
ffffffffc0201b22:	01a50513          	addi	a0,a0,26 # ffffffffc0206b38 <commands+0xe10>
ffffffffc0201b26:	daafe0ef          	jal	ra,ffffffffc02000d0 <cprintf>
}
ffffffffc0201b2a:	6406                	ld	s0,64(sp)
ffffffffc0201b2c:	60a6                	ld	ra,72(sp)
ffffffffc0201b2e:	74e2                	ld	s1,56(sp)
ffffffffc0201b30:	7942                	ld	s2,48(sp)
ffffffffc0201b32:	79a2                	ld	s3,40(sp)
ffffffffc0201b34:	7a02                	ld	s4,32(sp)
ffffffffc0201b36:	6ae2                	ld	s5,24(sp)
ffffffffc0201b38:	6b42                	ld	s6,16(sp)
ffffffffc0201b3a:	6ba2                	ld	s7,8(sp)
ffffffffc0201b3c:	6c02                	ld	s8,0(sp)
ffffffffc0201b3e:	6161                	addi	sp,sp,80
    kmalloc_init();
ffffffffc0201b40:	2df0106f          	j	ffffffffc020361e <kmalloc_init>
ffffffffc0201b44:	6008                	ld	a0,0(s0)
ffffffffc0201b46:	bd75                	j	ffffffffc0201a02 <pmm_init+0x3f4>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201b48:	00005697          	auipc	a3,0x5
ffffffffc0201b4c:	e6068693          	addi	a3,a3,-416 # ffffffffc02069a8 <commands+0xc80>
ffffffffc0201b50:	00004617          	auipc	a2,0x4
ffffffffc0201b54:	65860613          	addi	a2,a2,1624 # ffffffffc02061a8 <commands+0x480>
ffffffffc0201b58:	22a00593          	li	a1,554
ffffffffc0201b5c:	00005517          	auipc	a0,0x5
ffffffffc0201b60:	a2c50513          	addi	a0,a0,-1492 # ffffffffc0206588 <commands+0x860>
ffffffffc0201b64:	eb0fe0ef          	jal	ra,ffffffffc0200214 <__panic>
ffffffffc0201b68:	86d6                	mv	a3,s5
ffffffffc0201b6a:	00005617          	auipc	a2,0x5
ffffffffc0201b6e:	9f660613          	addi	a2,a2,-1546 # ffffffffc0206560 <commands+0x838>
ffffffffc0201b72:	22a00593          	li	a1,554
ffffffffc0201b76:	00005517          	auipc	a0,0x5
ffffffffc0201b7a:	a1250513          	addi	a0,a0,-1518 # ffffffffc0206588 <commands+0x860>
ffffffffc0201b7e:	e96fe0ef          	jal	ra,ffffffffc0200214 <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201b82:	00005697          	auipc	a3,0x5
ffffffffc0201b86:	e6668693          	addi	a3,a3,-410 # ffffffffc02069e8 <commands+0xcc0>
ffffffffc0201b8a:	00004617          	auipc	a2,0x4
ffffffffc0201b8e:	61e60613          	addi	a2,a2,1566 # ffffffffc02061a8 <commands+0x480>
ffffffffc0201b92:	22b00593          	li	a1,555
ffffffffc0201b96:	00005517          	auipc	a0,0x5
ffffffffc0201b9a:	9f250513          	addi	a0,a0,-1550 # ffffffffc0206588 <commands+0x860>
ffffffffc0201b9e:	e76fe0ef          	jal	ra,ffffffffc0200214 <__panic>
ffffffffc0201ba2:	a78ff0ef          	jal	ra,ffffffffc0200e1a <pa2page.part.4>
    return KADDR(page2pa(page));
ffffffffc0201ba6:	00005617          	auipc	a2,0x5
ffffffffc0201baa:	9ba60613          	addi	a2,a2,-1606 # ffffffffc0206560 <commands+0x838>
ffffffffc0201bae:	06900593          	li	a1,105
ffffffffc0201bb2:	00005517          	auipc	a0,0x5
ffffffffc0201bb6:	a0650513          	addi	a0,a0,-1530 # ffffffffc02065b8 <commands+0x890>
ffffffffc0201bba:	e5afe0ef          	jal	ra,ffffffffc0200214 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0201bbe:	00005617          	auipc	a2,0x5
ffffffffc0201bc2:	bba60613          	addi	a2,a2,-1094 # ffffffffc0206778 <commands+0xa50>
ffffffffc0201bc6:	07400593          	li	a1,116
ffffffffc0201bca:	00005517          	auipc	a0,0x5
ffffffffc0201bce:	9ee50513          	addi	a0,a0,-1554 # ffffffffc02065b8 <commands+0x890>
ffffffffc0201bd2:	e42fe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0201bd6:	00005697          	auipc	a3,0x5
ffffffffc0201bda:	ae268693          	addi	a3,a3,-1310 # ffffffffc02066b8 <commands+0x990>
ffffffffc0201bde:	00004617          	auipc	a2,0x4
ffffffffc0201be2:	5ca60613          	addi	a2,a2,1482 # ffffffffc02061a8 <commands+0x480>
ffffffffc0201be6:	1ee00593          	li	a1,494
ffffffffc0201bea:	00005517          	auipc	a0,0x5
ffffffffc0201bee:	99e50513          	addi	a0,a0,-1634 # ffffffffc0206588 <commands+0x860>
ffffffffc0201bf2:	e22fe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0201bf6:	00005697          	auipc	a3,0x5
ffffffffc0201bfa:	baa68693          	addi	a3,a3,-1110 # ffffffffc02067a0 <commands+0xa78>
ffffffffc0201bfe:	00004617          	auipc	a2,0x4
ffffffffc0201c02:	5aa60613          	addi	a2,a2,1450 # ffffffffc02061a8 <commands+0x480>
ffffffffc0201c06:	20a00593          	li	a1,522
ffffffffc0201c0a:	00005517          	auipc	a0,0x5
ffffffffc0201c0e:	97e50513          	addi	a0,a0,-1666 # ffffffffc0206588 <commands+0x860>
ffffffffc0201c12:	e02fe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0201c16:	00005697          	auipc	a3,0x5
ffffffffc0201c1a:	e0268693          	addi	a3,a3,-510 # ffffffffc0206a18 <commands+0xcf0>
ffffffffc0201c1e:	00004617          	auipc	a2,0x4
ffffffffc0201c22:	58a60613          	addi	a2,a2,1418 # ffffffffc02061a8 <commands+0x480>
ffffffffc0201c26:	23300593          	li	a1,563
ffffffffc0201c2a:	00005517          	auipc	a0,0x5
ffffffffc0201c2e:	95e50513          	addi	a0,a0,-1698 # ffffffffc0206588 <commands+0x860>
ffffffffc0201c32:	de2fe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201c36:	00005697          	auipc	a3,0x5
ffffffffc0201c3a:	bfa68693          	addi	a3,a3,-1030 # ffffffffc0206830 <commands+0xb08>
ffffffffc0201c3e:	00004617          	auipc	a2,0x4
ffffffffc0201c42:	56a60613          	addi	a2,a2,1386 # ffffffffc02061a8 <commands+0x480>
ffffffffc0201c46:	20900593          	li	a1,521
ffffffffc0201c4a:	00005517          	auipc	a0,0x5
ffffffffc0201c4e:	93e50513          	addi	a0,a0,-1730 # ffffffffc0206588 <commands+0x860>
ffffffffc0201c52:	dc2fe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0201c56:	00005697          	auipc	a3,0x5
ffffffffc0201c5a:	ca268693          	addi	a3,a3,-862 # ffffffffc02068f8 <commands+0xbd0>
ffffffffc0201c5e:	00004617          	auipc	a2,0x4
ffffffffc0201c62:	54a60613          	addi	a2,a2,1354 # ffffffffc02061a8 <commands+0x480>
ffffffffc0201c66:	20800593          	li	a1,520
ffffffffc0201c6a:	00005517          	auipc	a0,0x5
ffffffffc0201c6e:	91e50513          	addi	a0,a0,-1762 # ffffffffc0206588 <commands+0x860>
ffffffffc0201c72:	da2fe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0201c76:	00005697          	auipc	a3,0x5
ffffffffc0201c7a:	c6a68693          	addi	a3,a3,-918 # ffffffffc02068e0 <commands+0xbb8>
ffffffffc0201c7e:	00004617          	auipc	a2,0x4
ffffffffc0201c82:	52a60613          	addi	a2,a2,1322 # ffffffffc02061a8 <commands+0x480>
ffffffffc0201c86:	20700593          	li	a1,519
ffffffffc0201c8a:	00005517          	auipc	a0,0x5
ffffffffc0201c8e:	8fe50513          	addi	a0,a0,-1794 # ffffffffc0206588 <commands+0x860>
ffffffffc0201c92:	d82fe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0201c96:	00005697          	auipc	a3,0x5
ffffffffc0201c9a:	c1a68693          	addi	a3,a3,-998 # ffffffffc02068b0 <commands+0xb88>
ffffffffc0201c9e:	00004617          	auipc	a2,0x4
ffffffffc0201ca2:	50a60613          	addi	a2,a2,1290 # ffffffffc02061a8 <commands+0x480>
ffffffffc0201ca6:	20600593          	li	a1,518
ffffffffc0201caa:	00005517          	auipc	a0,0x5
ffffffffc0201cae:	8de50513          	addi	a0,a0,-1826 # ffffffffc0206588 <commands+0x860>
ffffffffc0201cb2:	d62fe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0201cb6:	00005697          	auipc	a3,0x5
ffffffffc0201cba:	be268693          	addi	a3,a3,-1054 # ffffffffc0206898 <commands+0xb70>
ffffffffc0201cbe:	00004617          	auipc	a2,0x4
ffffffffc0201cc2:	4ea60613          	addi	a2,a2,1258 # ffffffffc02061a8 <commands+0x480>
ffffffffc0201cc6:	20400593          	li	a1,516
ffffffffc0201cca:	00005517          	auipc	a0,0x5
ffffffffc0201cce:	8be50513          	addi	a0,a0,-1858 # ffffffffc0206588 <commands+0x860>
ffffffffc0201cd2:	d42fe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0201cd6:	00005697          	auipc	a3,0x5
ffffffffc0201cda:	baa68693          	addi	a3,a3,-1110 # ffffffffc0206880 <commands+0xb58>
ffffffffc0201cde:	00004617          	auipc	a2,0x4
ffffffffc0201ce2:	4ca60613          	addi	a2,a2,1226 # ffffffffc02061a8 <commands+0x480>
ffffffffc0201ce6:	20300593          	li	a1,515
ffffffffc0201cea:	00005517          	auipc	a0,0x5
ffffffffc0201cee:	89e50513          	addi	a0,a0,-1890 # ffffffffc0206588 <commands+0x860>
ffffffffc0201cf2:	d22fe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(*ptep & PTE_W);
ffffffffc0201cf6:	00005697          	auipc	a3,0x5
ffffffffc0201cfa:	b7a68693          	addi	a3,a3,-1158 # ffffffffc0206870 <commands+0xb48>
ffffffffc0201cfe:	00004617          	auipc	a2,0x4
ffffffffc0201d02:	4aa60613          	addi	a2,a2,1194 # ffffffffc02061a8 <commands+0x480>
ffffffffc0201d06:	20200593          	li	a1,514
ffffffffc0201d0a:	00005517          	auipc	a0,0x5
ffffffffc0201d0e:	87e50513          	addi	a0,a0,-1922 # ffffffffc0206588 <commands+0x860>
ffffffffc0201d12:	d02fe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(*ptep & PTE_U);
ffffffffc0201d16:	00005697          	auipc	a3,0x5
ffffffffc0201d1a:	b4a68693          	addi	a3,a3,-1206 # ffffffffc0206860 <commands+0xb38>
ffffffffc0201d1e:	00004617          	auipc	a2,0x4
ffffffffc0201d22:	48a60613          	addi	a2,a2,1162 # ffffffffc02061a8 <commands+0x480>
ffffffffc0201d26:	20100593          	li	a1,513
ffffffffc0201d2a:	00005517          	auipc	a0,0x5
ffffffffc0201d2e:	85e50513          	addi	a0,a0,-1954 # ffffffffc0206588 <commands+0x860>
ffffffffc0201d32:	ce2fe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201d36:	00005697          	auipc	a3,0x5
ffffffffc0201d3a:	afa68693          	addi	a3,a3,-1286 # ffffffffc0206830 <commands+0xb08>
ffffffffc0201d3e:	00004617          	auipc	a2,0x4
ffffffffc0201d42:	46a60613          	addi	a2,a2,1130 # ffffffffc02061a8 <commands+0x480>
ffffffffc0201d46:	20000593          	li	a1,512
ffffffffc0201d4a:	00005517          	auipc	a0,0x5
ffffffffc0201d4e:	83e50513          	addi	a0,a0,-1986 # ffffffffc0206588 <commands+0x860>
ffffffffc0201d52:	cc2fe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0201d56:	00005697          	auipc	a3,0x5
ffffffffc0201d5a:	aa268693          	addi	a3,a3,-1374 # ffffffffc02067f8 <commands+0xad0>
ffffffffc0201d5e:	00004617          	auipc	a2,0x4
ffffffffc0201d62:	44a60613          	addi	a2,a2,1098 # ffffffffc02061a8 <commands+0x480>
ffffffffc0201d66:	1ff00593          	li	a1,511
ffffffffc0201d6a:	00005517          	auipc	a0,0x5
ffffffffc0201d6e:	81e50513          	addi	a0,a0,-2018 # ffffffffc0206588 <commands+0x860>
ffffffffc0201d72:	ca2fe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201d76:	00005697          	auipc	a3,0x5
ffffffffc0201d7a:	a5a68693          	addi	a3,a3,-1446 # ffffffffc02067d0 <commands+0xaa8>
ffffffffc0201d7e:	00004617          	auipc	a2,0x4
ffffffffc0201d82:	42a60613          	addi	a2,a2,1066 # ffffffffc02061a8 <commands+0x480>
ffffffffc0201d86:	1fc00593          	li	a1,508
ffffffffc0201d8a:	00004517          	auipc	a0,0x4
ffffffffc0201d8e:	7fe50513          	addi	a0,a0,2046 # ffffffffc0206588 <commands+0x860>
ffffffffc0201d92:	c82fe0ef          	jal	ra,ffffffffc0200214 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201d96:	86da                	mv	a3,s6
ffffffffc0201d98:	00004617          	auipc	a2,0x4
ffffffffc0201d9c:	7c860613          	addi	a2,a2,1992 # ffffffffc0206560 <commands+0x838>
ffffffffc0201da0:	1fb00593          	li	a1,507
ffffffffc0201da4:	00004517          	auipc	a0,0x4
ffffffffc0201da8:	7e450513          	addi	a0,a0,2020 # ffffffffc0206588 <commands+0x860>
ffffffffc0201dac:	c68fe0ef          	jal	ra,ffffffffc0200214 <__panic>
    return KADDR(page2pa(page));
ffffffffc0201db0:	86be                	mv	a3,a5
ffffffffc0201db2:	00004617          	auipc	a2,0x4
ffffffffc0201db6:	7ae60613          	addi	a2,a2,1966 # ffffffffc0206560 <commands+0x838>
ffffffffc0201dba:	06900593          	li	a1,105
ffffffffc0201dbe:	00004517          	auipc	a0,0x4
ffffffffc0201dc2:	7fa50513          	addi	a0,a0,2042 # ffffffffc02065b8 <commands+0x890>
ffffffffc0201dc6:	c4efe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0201dca:	00005697          	auipc	a3,0x5
ffffffffc0201dce:	b7668693          	addi	a3,a3,-1162 # ffffffffc0206940 <commands+0xc18>
ffffffffc0201dd2:	00004617          	auipc	a2,0x4
ffffffffc0201dd6:	3d660613          	addi	a2,a2,982 # ffffffffc02061a8 <commands+0x480>
ffffffffc0201dda:	21500593          	li	a1,533
ffffffffc0201dde:	00004517          	auipc	a0,0x4
ffffffffc0201de2:	7aa50513          	addi	a0,a0,1962 # ffffffffc0206588 <commands+0x860>
ffffffffc0201de6:	c2efe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0201dea:	00005697          	auipc	a3,0x5
ffffffffc0201dee:	b0e68693          	addi	a3,a3,-1266 # ffffffffc02068f8 <commands+0xbd0>
ffffffffc0201df2:	00004617          	auipc	a2,0x4
ffffffffc0201df6:	3b660613          	addi	a2,a2,950 # ffffffffc02061a8 <commands+0x480>
ffffffffc0201dfa:	21300593          	li	a1,531
ffffffffc0201dfe:	00004517          	auipc	a0,0x4
ffffffffc0201e02:	78a50513          	addi	a0,a0,1930 # ffffffffc0206588 <commands+0x860>
ffffffffc0201e06:	c0efe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0201e0a:	00005697          	auipc	a3,0x5
ffffffffc0201e0e:	b1e68693          	addi	a3,a3,-1250 # ffffffffc0206928 <commands+0xc00>
ffffffffc0201e12:	00004617          	auipc	a2,0x4
ffffffffc0201e16:	39660613          	addi	a2,a2,918 # ffffffffc02061a8 <commands+0x480>
ffffffffc0201e1a:	21200593          	li	a1,530
ffffffffc0201e1e:	00004517          	auipc	a0,0x4
ffffffffc0201e22:	76a50513          	addi	a0,a0,1898 # ffffffffc0206588 <commands+0x860>
ffffffffc0201e26:	beefe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(page_ref(p) == 2);
ffffffffc0201e2a:	00005697          	auipc	a3,0x5
ffffffffc0201e2e:	c7e68693          	addi	a3,a3,-898 # ffffffffc0206aa8 <commands+0xd80>
ffffffffc0201e32:	00004617          	auipc	a2,0x4
ffffffffc0201e36:	37660613          	addi	a2,a2,886 # ffffffffc02061a8 <commands+0x480>
ffffffffc0201e3a:	23600593          	li	a1,566
ffffffffc0201e3e:	00004517          	auipc	a0,0x4
ffffffffc0201e42:	74a50513          	addi	a0,a0,1866 # ffffffffc0206588 <commands+0x860>
ffffffffc0201e46:	bcefe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0201e4a:	00005697          	auipc	a3,0x5
ffffffffc0201e4e:	c1e68693          	addi	a3,a3,-994 # ffffffffc0206a68 <commands+0xd40>
ffffffffc0201e52:	00004617          	auipc	a2,0x4
ffffffffc0201e56:	35660613          	addi	a2,a2,854 # ffffffffc02061a8 <commands+0x480>
ffffffffc0201e5a:	23500593          	li	a1,565
ffffffffc0201e5e:	00004517          	auipc	a0,0x4
ffffffffc0201e62:	72a50513          	addi	a0,a0,1834 # ffffffffc0206588 <commands+0x860>
ffffffffc0201e66:	baefe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0201e6a:	00005697          	auipc	a3,0x5
ffffffffc0201e6e:	be668693          	addi	a3,a3,-1050 # ffffffffc0206a50 <commands+0xd28>
ffffffffc0201e72:	00004617          	auipc	a2,0x4
ffffffffc0201e76:	33660613          	addi	a2,a2,822 # ffffffffc02061a8 <commands+0x480>
ffffffffc0201e7a:	23400593          	li	a1,564
ffffffffc0201e7e:	00004517          	auipc	a0,0x4
ffffffffc0201e82:	70a50513          	addi	a0,a0,1802 # ffffffffc0206588 <commands+0x860>
ffffffffc0201e86:	b8efe0ef          	jal	ra,ffffffffc0200214 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0201e8a:	86be                	mv	a3,a5
ffffffffc0201e8c:	00004617          	auipc	a2,0x4
ffffffffc0201e90:	6d460613          	addi	a2,a2,1748 # ffffffffc0206560 <commands+0x838>
ffffffffc0201e94:	1fa00593          	li	a1,506
ffffffffc0201e98:	00004517          	auipc	a0,0x4
ffffffffc0201e9c:	6f050513          	addi	a0,a0,1776 # ffffffffc0206588 <commands+0x860>
ffffffffc0201ea0:	b74fe0ef          	jal	ra,ffffffffc0200214 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201ea4:	00004617          	auipc	a2,0x4
ffffffffc0201ea8:	79460613          	addi	a2,a2,1940 # ffffffffc0206638 <commands+0x910>
ffffffffc0201eac:	07f00593          	li	a1,127
ffffffffc0201eb0:	00004517          	auipc	a0,0x4
ffffffffc0201eb4:	6d850513          	addi	a0,a0,1752 # ffffffffc0206588 <commands+0x860>
ffffffffc0201eb8:	b5cfe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0201ebc:	00005697          	auipc	a3,0x5
ffffffffc0201ec0:	c1c68693          	addi	a3,a3,-996 # ffffffffc0206ad8 <commands+0xdb0>
ffffffffc0201ec4:	00004617          	auipc	a2,0x4
ffffffffc0201ec8:	2e460613          	addi	a2,a2,740 # ffffffffc02061a8 <commands+0x480>
ffffffffc0201ecc:	23a00593          	li	a1,570
ffffffffc0201ed0:	00004517          	auipc	a0,0x4
ffffffffc0201ed4:	6b850513          	addi	a0,a0,1720 # ffffffffc0206588 <commands+0x860>
ffffffffc0201ed8:	b3cfe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0201edc:	00005697          	auipc	a3,0x5
ffffffffc0201ee0:	a8c68693          	addi	a3,a3,-1396 # ffffffffc0206968 <commands+0xc40>
ffffffffc0201ee4:	00004617          	auipc	a2,0x4
ffffffffc0201ee8:	2c460613          	addi	a2,a2,708 # ffffffffc02061a8 <commands+0x480>
ffffffffc0201eec:	24600593          	li	a1,582
ffffffffc0201ef0:	00004517          	auipc	a0,0x4
ffffffffc0201ef4:	69850513          	addi	a0,a0,1688 # ffffffffc0206588 <commands+0x860>
ffffffffc0201ef8:	b1cfe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0201efc:	00005697          	auipc	a3,0x5
ffffffffc0201f00:	8bc68693          	addi	a3,a3,-1860 # ffffffffc02067b8 <commands+0xa90>
ffffffffc0201f04:	00004617          	auipc	a2,0x4
ffffffffc0201f08:	2a460613          	addi	a2,a2,676 # ffffffffc02061a8 <commands+0x480>
ffffffffc0201f0c:	1f800593          	li	a1,504
ffffffffc0201f10:	00004517          	auipc	a0,0x4
ffffffffc0201f14:	67850513          	addi	a0,a0,1656 # ffffffffc0206588 <commands+0x860>
ffffffffc0201f18:	afcfe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0201f1c:	00005697          	auipc	a3,0x5
ffffffffc0201f20:	88468693          	addi	a3,a3,-1916 # ffffffffc02067a0 <commands+0xa78>
ffffffffc0201f24:	00004617          	auipc	a2,0x4
ffffffffc0201f28:	28460613          	addi	a2,a2,644 # ffffffffc02061a8 <commands+0x480>
ffffffffc0201f2c:	1f700593          	li	a1,503
ffffffffc0201f30:	00004517          	auipc	a0,0x4
ffffffffc0201f34:	65850513          	addi	a0,a0,1624 # ffffffffc0206588 <commands+0x860>
ffffffffc0201f38:	adcfe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0201f3c:	00004697          	auipc	a3,0x4
ffffffffc0201f40:	7b468693          	addi	a3,a3,1972 # ffffffffc02066f0 <commands+0x9c8>
ffffffffc0201f44:	00004617          	auipc	a2,0x4
ffffffffc0201f48:	26460613          	addi	a2,a2,612 # ffffffffc02061a8 <commands+0x480>
ffffffffc0201f4c:	1ef00593          	li	a1,495
ffffffffc0201f50:	00004517          	auipc	a0,0x4
ffffffffc0201f54:	63850513          	addi	a0,a0,1592 # ffffffffc0206588 <commands+0x860>
ffffffffc0201f58:	abcfe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0201f5c:	00004697          	auipc	a3,0x4
ffffffffc0201f60:	7ec68693          	addi	a3,a3,2028 # ffffffffc0206748 <commands+0xa20>
ffffffffc0201f64:	00004617          	auipc	a2,0x4
ffffffffc0201f68:	24460613          	addi	a2,a2,580 # ffffffffc02061a8 <commands+0x480>
ffffffffc0201f6c:	1f600593          	li	a1,502
ffffffffc0201f70:	00004517          	auipc	a0,0x4
ffffffffc0201f74:	61850513          	addi	a0,a0,1560 # ffffffffc0206588 <commands+0x860>
ffffffffc0201f78:	a9cfe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0201f7c:	00004697          	auipc	a3,0x4
ffffffffc0201f80:	79c68693          	addi	a3,a3,1948 # ffffffffc0206718 <commands+0x9f0>
ffffffffc0201f84:	00004617          	auipc	a2,0x4
ffffffffc0201f88:	22460613          	addi	a2,a2,548 # ffffffffc02061a8 <commands+0x480>
ffffffffc0201f8c:	1f300593          	li	a1,499
ffffffffc0201f90:	00004517          	auipc	a0,0x4
ffffffffc0201f94:	5f850513          	addi	a0,a0,1528 # ffffffffc0206588 <commands+0x860>
ffffffffc0201f98:	a7cfe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0201f9c:	00005697          	auipc	a3,0x5
ffffffffc0201fa0:	95c68693          	addi	a3,a3,-1700 # ffffffffc02068f8 <commands+0xbd0>
ffffffffc0201fa4:	00004617          	auipc	a2,0x4
ffffffffc0201fa8:	20460613          	addi	a2,a2,516 # ffffffffc02061a8 <commands+0x480>
ffffffffc0201fac:	20f00593          	li	a1,527
ffffffffc0201fb0:	00004517          	auipc	a0,0x4
ffffffffc0201fb4:	5d850513          	addi	a0,a0,1496 # ffffffffc0206588 <commands+0x860>
ffffffffc0201fb8:	a5cfe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0201fbc:	00004697          	auipc	a3,0x4
ffffffffc0201fc0:	7fc68693          	addi	a3,a3,2044 # ffffffffc02067b8 <commands+0xa90>
ffffffffc0201fc4:	00004617          	auipc	a2,0x4
ffffffffc0201fc8:	1e460613          	addi	a2,a2,484 # ffffffffc02061a8 <commands+0x480>
ffffffffc0201fcc:	20e00593          	li	a1,526
ffffffffc0201fd0:	00004517          	auipc	a0,0x4
ffffffffc0201fd4:	5b850513          	addi	a0,a0,1464 # ffffffffc0206588 <commands+0x860>
ffffffffc0201fd8:	a3cfe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc0201fdc:	00005697          	auipc	a3,0x5
ffffffffc0201fe0:	93468693          	addi	a3,a3,-1740 # ffffffffc0206910 <commands+0xbe8>
ffffffffc0201fe4:	00004617          	auipc	a2,0x4
ffffffffc0201fe8:	1c460613          	addi	a2,a2,452 # ffffffffc02061a8 <commands+0x480>
ffffffffc0201fec:	20b00593          	li	a1,523
ffffffffc0201ff0:	00004517          	auipc	a0,0x4
ffffffffc0201ff4:	59850513          	addi	a0,a0,1432 # ffffffffc0206588 <commands+0x860>
ffffffffc0201ff8:	a1cfe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0201ffc:	00005697          	auipc	a3,0x5
ffffffffc0202000:	b1468693          	addi	a3,a3,-1260 # ffffffffc0206b10 <commands+0xde8>
ffffffffc0202004:	00004617          	auipc	a2,0x4
ffffffffc0202008:	1a460613          	addi	a2,a2,420 # ffffffffc02061a8 <commands+0x480>
ffffffffc020200c:	23d00593          	li	a1,573
ffffffffc0202010:	00004517          	auipc	a0,0x4
ffffffffc0202014:	57850513          	addi	a0,a0,1400 # ffffffffc0206588 <commands+0x860>
ffffffffc0202018:	9fcfe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc020201c:	00005697          	auipc	a3,0x5
ffffffffc0202020:	94c68693          	addi	a3,a3,-1716 # ffffffffc0206968 <commands+0xc40>
ffffffffc0202024:	00004617          	auipc	a2,0x4
ffffffffc0202028:	18460613          	addi	a2,a2,388 # ffffffffc02061a8 <commands+0x480>
ffffffffc020202c:	21d00593          	li	a1,541
ffffffffc0202030:	00004517          	auipc	a0,0x4
ffffffffc0202034:	55850513          	addi	a0,a0,1368 # ffffffffc0206588 <commands+0x860>
ffffffffc0202038:	9dcfe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc020203c:	00005697          	auipc	a3,0x5
ffffffffc0202040:	9c468693          	addi	a3,a3,-1596 # ffffffffc0206a00 <commands+0xcd8>
ffffffffc0202044:	00004617          	auipc	a2,0x4
ffffffffc0202048:	16460613          	addi	a2,a2,356 # ffffffffc02061a8 <commands+0x480>
ffffffffc020204c:	22f00593          	li	a1,559
ffffffffc0202050:	00004517          	auipc	a0,0x4
ffffffffc0202054:	53850513          	addi	a0,a0,1336 # ffffffffc0206588 <commands+0x860>
ffffffffc0202058:	9bcfe0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc020205c:	00004697          	auipc	a3,0x4
ffffffffc0202060:	63c68693          	addi	a3,a3,1596 # ffffffffc0206698 <commands+0x970>
ffffffffc0202064:	00004617          	auipc	a2,0x4
ffffffffc0202068:	14460613          	addi	a2,a2,324 # ffffffffc02061a8 <commands+0x480>
ffffffffc020206c:	1ed00593          	li	a1,493
ffffffffc0202070:	00004517          	auipc	a0,0x4
ffffffffc0202074:	51850513          	addi	a0,a0,1304 # ffffffffc0206588 <commands+0x860>
ffffffffc0202078:	99cfe0ef          	jal	ra,ffffffffc0200214 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc020207c:	00004617          	auipc	a2,0x4
ffffffffc0202080:	5bc60613          	addi	a2,a2,1468 # ffffffffc0206638 <commands+0x910>
ffffffffc0202084:	0c100593          	li	a1,193
ffffffffc0202088:	00004517          	auipc	a0,0x4
ffffffffc020208c:	50050513          	addi	a0,a0,1280 # ffffffffc0206588 <commands+0x860>
ffffffffc0202090:	984fe0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0202094 <tlb_invalidate>:
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202094:	12058073          	sfence.vma	a1
}
ffffffffc0202098:	8082                	ret

ffffffffc020209a <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc020209a:	7179                	addi	sp,sp,-48
ffffffffc020209c:	e84a                	sd	s2,16(sp)
ffffffffc020209e:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc02020a0:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc02020a2:	f022                	sd	s0,32(sp)
ffffffffc02020a4:	ec26                	sd	s1,24(sp)
ffffffffc02020a6:	e44e                	sd	s3,8(sp)
ffffffffc02020a8:	f406                	sd	ra,40(sp)
ffffffffc02020aa:	84ae                	mv	s1,a1
ffffffffc02020ac:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc02020ae:	d89fe0ef          	jal	ra,ffffffffc0200e36 <alloc_pages>
ffffffffc02020b2:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc02020b4:	cd1d                	beqz	a0,ffffffffc02020f2 <pgdir_alloc_page+0x58>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc02020b6:	85aa                	mv	a1,a0
ffffffffc02020b8:	86ce                	mv	a3,s3
ffffffffc02020ba:	8626                	mv	a2,s1
ffffffffc02020bc:	854a                	mv	a0,s2
ffffffffc02020be:	c92ff0ef          	jal	ra,ffffffffc0201550 <page_insert>
ffffffffc02020c2:	e121                	bnez	a0,ffffffffc0202102 <pgdir_alloc_page+0x68>
        if (swap_init_ok) {
ffffffffc02020c4:	000aa797          	auipc	a5,0xaa
ffffffffc02020c8:	7ac78793          	addi	a5,a5,1964 # ffffffffc02ac870 <swap_init_ok>
ffffffffc02020cc:	439c                	lw	a5,0(a5)
ffffffffc02020ce:	2781                	sext.w	a5,a5
ffffffffc02020d0:	c38d                	beqz	a5,ffffffffc02020f2 <pgdir_alloc_page+0x58>
            if (check_mm_struct != NULL) {
ffffffffc02020d2:	000aa797          	auipc	a5,0xaa
ffffffffc02020d6:	7f678793          	addi	a5,a5,2038 # ffffffffc02ac8c8 <check_mm_struct>
ffffffffc02020da:	6388                	ld	a0,0(a5)
ffffffffc02020dc:	c919                	beqz	a0,ffffffffc02020f2 <pgdir_alloc_page+0x58>
                swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc02020de:	4681                	li	a3,0
ffffffffc02020e0:	8622                	mv	a2,s0
ffffffffc02020e2:	85a6                	mv	a1,s1
ffffffffc02020e4:	19a010ef          	jal	ra,ffffffffc020327e <swap_map_swappable>
                assert(page_ref(page) == 1);
ffffffffc02020e8:	4018                	lw	a4,0(s0)
                page->pra_vaddr = la;
ffffffffc02020ea:	fc04                	sd	s1,56(s0)
                assert(page_ref(page) == 1);
ffffffffc02020ec:	4785                	li	a5,1
ffffffffc02020ee:	02f71063          	bne	a4,a5,ffffffffc020210e <pgdir_alloc_page+0x74>
}
ffffffffc02020f2:	8522                	mv	a0,s0
ffffffffc02020f4:	70a2                	ld	ra,40(sp)
ffffffffc02020f6:	7402                	ld	s0,32(sp)
ffffffffc02020f8:	64e2                	ld	s1,24(sp)
ffffffffc02020fa:	6942                	ld	s2,16(sp)
ffffffffc02020fc:	69a2                	ld	s3,8(sp)
ffffffffc02020fe:	6145                	addi	sp,sp,48
ffffffffc0202100:	8082                	ret
            free_page(page);
ffffffffc0202102:	8522                	mv	a0,s0
ffffffffc0202104:	4585                	li	a1,1
ffffffffc0202106:	db9fe0ef          	jal	ra,ffffffffc0200ebe <free_pages>
            return NULL;
ffffffffc020210a:	4401                	li	s0,0
ffffffffc020210c:	b7dd                	j	ffffffffc02020f2 <pgdir_alloc_page+0x58>
                assert(page_ref(page) == 1);
ffffffffc020210e:	00004697          	auipc	a3,0x4
ffffffffc0202112:	4ba68693          	addi	a3,a3,1210 # ffffffffc02065c8 <commands+0x8a0>
ffffffffc0202116:	00004617          	auipc	a2,0x4
ffffffffc020211a:	09260613          	addi	a2,a2,146 # ffffffffc02061a8 <commands+0x480>
ffffffffc020211e:	1ce00593          	li	a1,462
ffffffffc0202122:	00004517          	auipc	a0,0x4
ffffffffc0202126:	46650513          	addi	a0,a0,1126 # ffffffffc0206588 <commands+0x860>
ffffffffc020212a:	8eafe0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc020212e <check_vma_overlap.isra.0.part.1>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc020212e:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc0202130:	00005697          	auipc	a3,0x5
ffffffffc0202134:	a7068693          	addi	a3,a3,-1424 # ffffffffc0206ba0 <commands+0xe78>
ffffffffc0202138:	00004617          	auipc	a2,0x4
ffffffffc020213c:	07060613          	addi	a2,a2,112 # ffffffffc02061a8 <commands+0x480>
ffffffffc0202140:	06d00593          	li	a1,109
ffffffffc0202144:	00005517          	auipc	a0,0x5
ffffffffc0202148:	a7c50513          	addi	a0,a0,-1412 # ffffffffc0206bc0 <commands+0xe98>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc020214c:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc020214e:	8c6fe0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0202152 <mm_create>:
mm_create(void) {
ffffffffc0202152:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0202154:	04000513          	li	a0,64
mm_create(void) {
ffffffffc0202158:	e022                	sd	s0,0(sp)
ffffffffc020215a:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc020215c:	4e6010ef          	jal	ra,ffffffffc0203642 <kmalloc>
ffffffffc0202160:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0202162:	c515                	beqz	a0,ffffffffc020218e <mm_create+0x3c>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0202164:	000aa797          	auipc	a5,0xaa
ffffffffc0202168:	70c78793          	addi	a5,a5,1804 # ffffffffc02ac870 <swap_init_ok>
ffffffffc020216c:	439c                	lw	a5,0(a5)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc020216e:	e408                	sd	a0,8(s0)
ffffffffc0202170:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc0202172:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0202176:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc020217a:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc020217e:	2781                	sext.w	a5,a5
ffffffffc0202180:	ef81                	bnez	a5,ffffffffc0202198 <mm_create+0x46>
        else mm->sm_priv = NULL;
ffffffffc0202182:	02053423          	sd	zero,40(a0)
    return mm->mm_count;
}

static inline void
set_mm_count(struct mm_struct *mm, int val) {
    mm->mm_count = val;
ffffffffc0202186:	02042823          	sw	zero,48(s0)

typedef volatile bool lock_t;

static inline void
lock_init(lock_t *lock) {
    *lock = 0;
ffffffffc020218a:	02043c23          	sd	zero,56(s0)
}
ffffffffc020218e:	8522                	mv	a0,s0
ffffffffc0202190:	60a2                	ld	ra,8(sp)
ffffffffc0202192:	6402                	ld	s0,0(sp)
ffffffffc0202194:	0141                	addi	sp,sp,16
ffffffffc0202196:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0202198:	0d6010ef          	jal	ra,ffffffffc020326e <swap_init_mm>
ffffffffc020219c:	b7ed                	j	ffffffffc0202186 <mm_create+0x34>

ffffffffc020219e <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc020219e:	1101                	addi	sp,sp,-32
ffffffffc02021a0:	e04a                	sd	s2,0(sp)
ffffffffc02021a2:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02021a4:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc02021a8:	e822                	sd	s0,16(sp)
ffffffffc02021aa:	e426                	sd	s1,8(sp)
ffffffffc02021ac:	ec06                	sd	ra,24(sp)
ffffffffc02021ae:	84ae                	mv	s1,a1
ffffffffc02021b0:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02021b2:	490010ef          	jal	ra,ffffffffc0203642 <kmalloc>
    if (vma != NULL) {
ffffffffc02021b6:	c509                	beqz	a0,ffffffffc02021c0 <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc02021b8:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc02021bc:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02021be:	cd00                	sw	s0,24(a0)
}
ffffffffc02021c0:	60e2                	ld	ra,24(sp)
ffffffffc02021c2:	6442                	ld	s0,16(sp)
ffffffffc02021c4:	64a2                	ld	s1,8(sp)
ffffffffc02021c6:	6902                	ld	s2,0(sp)
ffffffffc02021c8:	6105                	addi	sp,sp,32
ffffffffc02021ca:	8082                	ret

ffffffffc02021cc <find_vma>:
    if (mm != NULL) {
ffffffffc02021cc:	c51d                	beqz	a0,ffffffffc02021fa <find_vma+0x2e>
        vma = mm->mmap_cache;
ffffffffc02021ce:	691c                	ld	a5,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc02021d0:	c781                	beqz	a5,ffffffffc02021d8 <find_vma+0xc>
ffffffffc02021d2:	6798                	ld	a4,8(a5)
ffffffffc02021d4:	02e5f663          	bgeu	a1,a4,ffffffffc0202200 <find_vma+0x34>
                list_entry_t *list = &(mm->mmap_list), *le = list;
ffffffffc02021d8:	87aa                	mv	a5,a0
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc02021da:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc02021dc:	00f50f63          	beq	a0,a5,ffffffffc02021fa <find_vma+0x2e>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc02021e0:	fe87b703          	ld	a4,-24(a5)
ffffffffc02021e4:	fee5ebe3          	bltu	a1,a4,ffffffffc02021da <find_vma+0xe>
ffffffffc02021e8:	ff07b703          	ld	a4,-16(a5)
ffffffffc02021ec:	fee5f7e3          	bgeu	a1,a4,ffffffffc02021da <find_vma+0xe>
                    vma = le2vma(le, list_link);
ffffffffc02021f0:	1781                	addi	a5,a5,-32
        if (vma != NULL) {
ffffffffc02021f2:	c781                	beqz	a5,ffffffffc02021fa <find_vma+0x2e>
            mm->mmap_cache = vma;
ffffffffc02021f4:	e91c                	sd	a5,16(a0)
}
ffffffffc02021f6:	853e                	mv	a0,a5
ffffffffc02021f8:	8082                	ret
    struct vma_struct *vma = NULL;
ffffffffc02021fa:	4781                	li	a5,0
}
ffffffffc02021fc:	853e                	mv	a0,a5
ffffffffc02021fe:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0202200:	6b98                	ld	a4,16(a5)
ffffffffc0202202:	fce5fbe3          	bgeu	a1,a4,ffffffffc02021d8 <find_vma+0xc>
            mm->mmap_cache = vma;
ffffffffc0202206:	e91c                	sd	a5,16(a0)
    return vma;
ffffffffc0202208:	b7fd                	j	ffffffffc02021f6 <find_vma+0x2a>

ffffffffc020220a <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc020220a:	6590                	ld	a2,8(a1)
ffffffffc020220c:	0105b803          	ld	a6,16(a1)
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc0202210:	1141                	addi	sp,sp,-16
ffffffffc0202212:	e406                	sd	ra,8(sp)
ffffffffc0202214:	872a                	mv	a4,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0202216:	01066863          	bltu	a2,a6,ffffffffc0202226 <insert_vma_struct+0x1c>
ffffffffc020221a:	a8b9                	j	ffffffffc0202278 <insert_vma_struct+0x6e>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc020221c:	fe87b683          	ld	a3,-24(a5)
ffffffffc0202220:	04d66763          	bltu	a2,a3,ffffffffc020226e <insert_vma_struct+0x64>
ffffffffc0202224:	873e                	mv	a4,a5
ffffffffc0202226:	671c                	ld	a5,8(a4)
        while ((le = list_next(le)) != list) {
ffffffffc0202228:	fef51ae3          	bne	a0,a5,ffffffffc020221c <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc020222c:	02a70463          	beq	a4,a0,ffffffffc0202254 <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0202230:	ff073683          	ld	a3,-16(a4) # 7fff0 <_binary_obj___user_exit_out_size+0x75528>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0202234:	fe873883          	ld	a7,-24(a4)
ffffffffc0202238:	08d8f063          	bgeu	a7,a3,ffffffffc02022b8 <insert_vma_struct+0xae>
    assert(prev->vm_end <= next->vm_start);
ffffffffc020223c:	04d66e63          	bltu	a2,a3,ffffffffc0202298 <insert_vma_struct+0x8e>
    }
    if (le_next != list) {
ffffffffc0202240:	00f50a63          	beq	a0,a5,ffffffffc0202254 <insert_vma_struct+0x4a>
ffffffffc0202244:	fe87b683          	ld	a3,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc0202248:	0506e863          	bltu	a3,a6,ffffffffc0202298 <insert_vma_struct+0x8e>
    assert(next->vm_start < next->vm_end);
ffffffffc020224c:	ff07b603          	ld	a2,-16(a5)
ffffffffc0202250:	02c6f263          	bgeu	a3,a2,ffffffffc0202274 <insert_vma_struct+0x6a>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc0202254:	5114                	lw	a3,32(a0)
    vma->vm_mm = mm;
ffffffffc0202256:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc0202258:	02058613          	addi	a2,a1,32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc020225c:	e390                	sd	a2,0(a5)
ffffffffc020225e:	e710                	sd	a2,8(a4)
}
ffffffffc0202260:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc0202262:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc0202264:	f198                	sd	a4,32(a1)
    mm->map_count ++;
ffffffffc0202266:	2685                	addiw	a3,a3,1
ffffffffc0202268:	d114                	sw	a3,32(a0)
}
ffffffffc020226a:	0141                	addi	sp,sp,16
ffffffffc020226c:	8082                	ret
    if (le_prev != list) {
ffffffffc020226e:	fca711e3          	bne	a4,a0,ffffffffc0202230 <insert_vma_struct+0x26>
ffffffffc0202272:	bfd9                	j	ffffffffc0202248 <insert_vma_struct+0x3e>
ffffffffc0202274:	ebbff0ef          	jal	ra,ffffffffc020212e <check_vma_overlap.isra.0.part.1>
    assert(vma->vm_start < vma->vm_end);
ffffffffc0202278:	00005697          	auipc	a3,0x5
ffffffffc020227c:	a1868693          	addi	a3,a3,-1512 # ffffffffc0206c90 <commands+0xf68>
ffffffffc0202280:	00004617          	auipc	a2,0x4
ffffffffc0202284:	f2860613          	addi	a2,a2,-216 # ffffffffc02061a8 <commands+0x480>
ffffffffc0202288:	07400593          	li	a1,116
ffffffffc020228c:	00005517          	auipc	a0,0x5
ffffffffc0202290:	93450513          	addi	a0,a0,-1740 # ffffffffc0206bc0 <commands+0xe98>
ffffffffc0202294:	f81fd0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0202298:	00005697          	auipc	a3,0x5
ffffffffc020229c:	a3868693          	addi	a3,a3,-1480 # ffffffffc0206cd0 <commands+0xfa8>
ffffffffc02022a0:	00004617          	auipc	a2,0x4
ffffffffc02022a4:	f0860613          	addi	a2,a2,-248 # ffffffffc02061a8 <commands+0x480>
ffffffffc02022a8:	06c00593          	li	a1,108
ffffffffc02022ac:	00005517          	auipc	a0,0x5
ffffffffc02022b0:	91450513          	addi	a0,a0,-1772 # ffffffffc0206bc0 <commands+0xe98>
ffffffffc02022b4:	f61fd0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc02022b8:	00005697          	auipc	a3,0x5
ffffffffc02022bc:	9f868693          	addi	a3,a3,-1544 # ffffffffc0206cb0 <commands+0xf88>
ffffffffc02022c0:	00004617          	auipc	a2,0x4
ffffffffc02022c4:	ee860613          	addi	a2,a2,-280 # ffffffffc02061a8 <commands+0x480>
ffffffffc02022c8:	06b00593          	li	a1,107
ffffffffc02022cc:	00005517          	auipc	a0,0x5
ffffffffc02022d0:	8f450513          	addi	a0,a0,-1804 # ffffffffc0206bc0 <commands+0xe98>
ffffffffc02022d4:	f41fd0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc02022d8 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
    assert(mm_count(mm) == 0);
ffffffffc02022d8:	591c                	lw	a5,48(a0)
mm_destroy(struct mm_struct *mm) {
ffffffffc02022da:	1141                	addi	sp,sp,-16
ffffffffc02022dc:	e406                	sd	ra,8(sp)
ffffffffc02022de:	e022                	sd	s0,0(sp)
    assert(mm_count(mm) == 0);
ffffffffc02022e0:	e78d                	bnez	a5,ffffffffc020230a <mm_destroy+0x32>
ffffffffc02022e2:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc02022e4:	6508                	ld	a0,8(a0)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc02022e6:	00a40c63          	beq	s0,a0,ffffffffc02022fe <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc02022ea:	6118                	ld	a4,0(a0)
ffffffffc02022ec:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc02022ee:	1501                	addi	a0,a0,-32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc02022f0:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02022f2:	e398                	sd	a4,0(a5)
ffffffffc02022f4:	40a010ef          	jal	ra,ffffffffc02036fe <kfree>
    return listelm->next;
ffffffffc02022f8:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc02022fa:	fea418e3          	bne	s0,a0,ffffffffc02022ea <mm_destroy+0x12>
    }
    kfree(mm); //kfree mm
ffffffffc02022fe:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc0202300:	6402                	ld	s0,0(sp)
ffffffffc0202302:	60a2                	ld	ra,8(sp)
ffffffffc0202304:	0141                	addi	sp,sp,16
    kfree(mm); //kfree mm
ffffffffc0202306:	3f80106f          	j	ffffffffc02036fe <kfree>
    assert(mm_count(mm) == 0);
ffffffffc020230a:	00005697          	auipc	a3,0x5
ffffffffc020230e:	9e668693          	addi	a3,a3,-1562 # ffffffffc0206cf0 <commands+0xfc8>
ffffffffc0202312:	00004617          	auipc	a2,0x4
ffffffffc0202316:	e9660613          	addi	a2,a2,-362 # ffffffffc02061a8 <commands+0x480>
ffffffffc020231a:	09400593          	li	a1,148
ffffffffc020231e:	00005517          	auipc	a0,0x5
ffffffffc0202322:	8a250513          	addi	a0,a0,-1886 # ffffffffc0206bc0 <commands+0xe98>
ffffffffc0202326:	eeffd0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc020232a <mm_map>:

int
mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
       struct vma_struct **vma_store) {
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc020232a:	6785                	lui	a5,0x1
       struct vma_struct **vma_store) {
ffffffffc020232c:	7139                	addi	sp,sp,-64
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc020232e:	17fd                	addi	a5,a5,-1
ffffffffc0202330:	787d                	lui	a6,0xfffff
       struct vma_struct **vma_store) {
ffffffffc0202332:	f822                	sd	s0,48(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0202334:	00f60433          	add	s0,a2,a5
       struct vma_struct **vma_store) {
ffffffffc0202338:	f426                	sd	s1,40(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc020233a:	942e                	add	s0,s0,a1
       struct vma_struct **vma_store) {
ffffffffc020233c:	fc06                	sd	ra,56(sp)
ffffffffc020233e:	f04a                	sd	s2,32(sp)
ffffffffc0202340:	ec4e                	sd	s3,24(sp)
ffffffffc0202342:	e852                	sd	s4,16(sp)
ffffffffc0202344:	e456                	sd	s5,8(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0202346:	0105f4b3          	and	s1,a1,a6
    if (!USER_ACCESS(start, end)) {
ffffffffc020234a:	002007b7          	lui	a5,0x200
ffffffffc020234e:	01047433          	and	s0,s0,a6
ffffffffc0202352:	06f4e363          	bltu	s1,a5,ffffffffc02023b8 <mm_map+0x8e>
ffffffffc0202356:	0684f163          	bgeu	s1,s0,ffffffffc02023b8 <mm_map+0x8e>
ffffffffc020235a:	4785                	li	a5,1
ffffffffc020235c:	07fe                	slli	a5,a5,0x1f
ffffffffc020235e:	0487ed63          	bltu	a5,s0,ffffffffc02023b8 <mm_map+0x8e>
ffffffffc0202362:	89aa                	mv	s3,a0
ffffffffc0202364:	8a3a                	mv	s4,a4
ffffffffc0202366:	8ab6                	mv	s5,a3
        return -E_INVAL;
    }

    assert(mm != NULL);
ffffffffc0202368:	c931                	beqz	a0,ffffffffc02023bc <mm_map+0x92>

    int ret = -E_INVAL;

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start) {
ffffffffc020236a:	85a6                	mv	a1,s1
ffffffffc020236c:	e61ff0ef          	jal	ra,ffffffffc02021cc <find_vma>
ffffffffc0202370:	c501                	beqz	a0,ffffffffc0202378 <mm_map+0x4e>
ffffffffc0202372:	651c                	ld	a5,8(a0)
ffffffffc0202374:	0487e263          	bltu	a5,s0,ffffffffc02023b8 <mm_map+0x8e>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0202378:	03000513          	li	a0,48
ffffffffc020237c:	2c6010ef          	jal	ra,ffffffffc0203642 <kmalloc>
ffffffffc0202380:	892a                	mv	s2,a0
        goto out;
    }
    ret = -E_NO_MEM;
ffffffffc0202382:	5571                	li	a0,-4
    if (vma != NULL) {
ffffffffc0202384:	02090163          	beqz	s2,ffffffffc02023a6 <mm_map+0x7c>

    if ((vma = vma_create(start, end, vm_flags)) == NULL) {
        goto out;
    }
    insert_vma_struct(mm, vma);
ffffffffc0202388:	854e                	mv	a0,s3
        vma->vm_start = vm_start;
ffffffffc020238a:	00993423          	sd	s1,8(s2)
        vma->vm_end = vm_end;
ffffffffc020238e:	00893823          	sd	s0,16(s2)
        vma->vm_flags = vm_flags;
ffffffffc0202392:	01592c23          	sw	s5,24(s2)
    insert_vma_struct(mm, vma);
ffffffffc0202396:	85ca                	mv	a1,s2
ffffffffc0202398:	e73ff0ef          	jal	ra,ffffffffc020220a <insert_vma_struct>
    if (vma_store != NULL) {
        *vma_store = vma;
    }
    ret = 0;
ffffffffc020239c:	4501                	li	a0,0
    if (vma_store != NULL) {
ffffffffc020239e:	000a0463          	beqz	s4,ffffffffc02023a6 <mm_map+0x7c>
        *vma_store = vma;
ffffffffc02023a2:	012a3023          	sd	s2,0(s4)

out:
    return ret;
}
ffffffffc02023a6:	70e2                	ld	ra,56(sp)
ffffffffc02023a8:	7442                	ld	s0,48(sp)
ffffffffc02023aa:	74a2                	ld	s1,40(sp)
ffffffffc02023ac:	7902                	ld	s2,32(sp)
ffffffffc02023ae:	69e2                	ld	s3,24(sp)
ffffffffc02023b0:	6a42                	ld	s4,16(sp)
ffffffffc02023b2:	6aa2                	ld	s5,8(sp)
ffffffffc02023b4:	6121                	addi	sp,sp,64
ffffffffc02023b6:	8082                	ret
        return -E_INVAL;
ffffffffc02023b8:	5575                	li	a0,-3
ffffffffc02023ba:	b7f5                	j	ffffffffc02023a6 <mm_map+0x7c>
    assert(mm != NULL);
ffffffffc02023bc:	00005697          	auipc	a3,0x5
ffffffffc02023c0:	94c68693          	addi	a3,a3,-1716 # ffffffffc0206d08 <commands+0xfe0>
ffffffffc02023c4:	00004617          	auipc	a2,0x4
ffffffffc02023c8:	de460613          	addi	a2,a2,-540 # ffffffffc02061a8 <commands+0x480>
ffffffffc02023cc:	0a700593          	li	a1,167
ffffffffc02023d0:	00004517          	auipc	a0,0x4
ffffffffc02023d4:	7f050513          	addi	a0,a0,2032 # ffffffffc0206bc0 <commands+0xe98>
ffffffffc02023d8:	e3dfd0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc02023dc <exit_mmap>:
    }
    return 0;
}

void
exit_mmap(struct mm_struct *mm) {
ffffffffc02023dc:	1101                	addi	sp,sp,-32
ffffffffc02023de:	ec06                	sd	ra,24(sp)
ffffffffc02023e0:	e822                	sd	s0,16(sp)
ffffffffc02023e2:	e426                	sd	s1,8(sp)
ffffffffc02023e4:	e04a                	sd	s2,0(sp)
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc02023e6:	c531                	beqz	a0,ffffffffc0202432 <exit_mmap+0x56>
ffffffffc02023e8:	591c                	lw	a5,48(a0)
ffffffffc02023ea:	84aa                	mv	s1,a0
ffffffffc02023ec:	e3b9                	bnez	a5,ffffffffc0202432 <exit_mmap+0x56>
ffffffffc02023ee:	6500                	ld	s0,8(a0)
    pde_t *pgdir = mm->pgdir;
ffffffffc02023f0:	01853903          	ld	s2,24(a0)
    list_entry_t *list = &(mm->mmap_list), *le = list;
    while ((le = list_next(le)) != list) {
ffffffffc02023f4:	02850663          	beq	a0,s0,ffffffffc0202420 <exit_mmap+0x44>
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc02023f8:	ff043603          	ld	a2,-16(s0)
ffffffffc02023fc:	fe843583          	ld	a1,-24(s0)
ffffffffc0202400:	854a                	mv	a0,s2
ffffffffc0202402:	d6dfe0ef          	jal	ra,ffffffffc020116e <unmap_range>
ffffffffc0202406:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc0202408:	fe8498e3          	bne	s1,s0,ffffffffc02023f8 <exit_mmap+0x1c>
ffffffffc020240c:	6400                	ld	s0,8(s0)
    }
    while ((le = list_next(le)) != list) {
ffffffffc020240e:	00848c63          	beq	s1,s0,ffffffffc0202426 <exit_mmap+0x4a>
        struct vma_struct *vma = le2vma(le, list_link);
        exit_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc0202412:	ff043603          	ld	a2,-16(s0)
ffffffffc0202416:	fe843583          	ld	a1,-24(s0)
ffffffffc020241a:	854a                	mv	a0,s2
ffffffffc020241c:	e6bfe0ef          	jal	ra,ffffffffc0201286 <exit_range>
ffffffffc0202420:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc0202422:	fe8498e3          	bne	s1,s0,ffffffffc0202412 <exit_mmap+0x36>
    }
}
ffffffffc0202426:	60e2                	ld	ra,24(sp)
ffffffffc0202428:	6442                	ld	s0,16(sp)
ffffffffc020242a:	64a2                	ld	s1,8(sp)
ffffffffc020242c:	6902                	ld	s2,0(sp)
ffffffffc020242e:	6105                	addi	sp,sp,32
ffffffffc0202430:	8082                	ret
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0202432:	00005697          	auipc	a3,0x5
ffffffffc0202436:	83e68693          	addi	a3,a3,-1986 # ffffffffc0206c70 <commands+0xf48>
ffffffffc020243a:	00004617          	auipc	a2,0x4
ffffffffc020243e:	d6e60613          	addi	a2,a2,-658 # ffffffffc02061a8 <commands+0x480>
ffffffffc0202442:	0d600593          	li	a1,214
ffffffffc0202446:	00004517          	auipc	a0,0x4
ffffffffc020244a:	77a50513          	addi	a0,a0,1914 # ffffffffc0206bc0 <commands+0xe98>
ffffffffc020244e:	dc7fd0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0202452 <vmm_init>:
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc0202452:	7139                	addi	sp,sp,-64
ffffffffc0202454:	f822                	sd	s0,48(sp)
ffffffffc0202456:	f426                	sd	s1,40(sp)
ffffffffc0202458:	fc06                	sd	ra,56(sp)
ffffffffc020245a:	f04a                	sd	s2,32(sp)
ffffffffc020245c:	ec4e                	sd	s3,24(sp)
ffffffffc020245e:	e852                	sd	s4,16(sp)
ffffffffc0202460:	e456                	sd	s5,8(sp)

static void
check_vma_struct(void) {
    // size_t nr_free_pages_store = nr_free_pages();

    struct mm_struct *mm = mm_create();
ffffffffc0202462:	cf1ff0ef          	jal	ra,ffffffffc0202152 <mm_create>
    assert(mm != NULL);
ffffffffc0202466:	842a                	mv	s0,a0
ffffffffc0202468:	03200493          	li	s1,50
ffffffffc020246c:	e919                	bnez	a0,ffffffffc0202482 <vmm_init+0x30>
ffffffffc020246e:	a989                	j	ffffffffc02028c0 <vmm_init+0x46e>
        vma->vm_start = vm_start;
ffffffffc0202470:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc0202472:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0202474:	00052c23          	sw	zero,24(a0)

    int i;
    for (i = step1; i >= 1; i --) {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0202478:	14ed                	addi	s1,s1,-5
ffffffffc020247a:	8522                	mv	a0,s0
ffffffffc020247c:	d8fff0ef          	jal	ra,ffffffffc020220a <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc0202480:	c88d                	beqz	s1,ffffffffc02024b2 <vmm_init+0x60>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0202482:	03000513          	li	a0,48
ffffffffc0202486:	1bc010ef          	jal	ra,ffffffffc0203642 <kmalloc>
ffffffffc020248a:	85aa                	mv	a1,a0
ffffffffc020248c:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc0202490:	f165                	bnez	a0,ffffffffc0202470 <vmm_init+0x1e>
        assert(vma != NULL);
ffffffffc0202492:	00005697          	auipc	a3,0x5
ffffffffc0202496:	a9e68693          	addi	a3,a3,-1378 # ffffffffc0206f30 <commands+0x1208>
ffffffffc020249a:	00004617          	auipc	a2,0x4
ffffffffc020249e:	d0e60613          	addi	a2,a2,-754 # ffffffffc02061a8 <commands+0x480>
ffffffffc02024a2:	11300593          	li	a1,275
ffffffffc02024a6:	00004517          	auipc	a0,0x4
ffffffffc02024aa:	71a50513          	addi	a0,a0,1818 # ffffffffc0206bc0 <commands+0xe98>
ffffffffc02024ae:	d67fd0ef          	jal	ra,ffffffffc0200214 <__panic>
    for (i = step1; i >= 1; i --) {
ffffffffc02024b2:	03700493          	li	s1,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc02024b6:	1f900913          	li	s2,505
ffffffffc02024ba:	a819                	j	ffffffffc02024d0 <vmm_init+0x7e>
        vma->vm_start = vm_start;
ffffffffc02024bc:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc02024be:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02024c0:	00052c23          	sw	zero,24(a0)
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc02024c4:	0495                	addi	s1,s1,5
ffffffffc02024c6:	8522                	mv	a0,s0
ffffffffc02024c8:	d43ff0ef          	jal	ra,ffffffffc020220a <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc02024cc:	03248a63          	beq	s1,s2,ffffffffc0202500 <vmm_init+0xae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02024d0:	03000513          	li	a0,48
ffffffffc02024d4:	16e010ef          	jal	ra,ffffffffc0203642 <kmalloc>
ffffffffc02024d8:	85aa                	mv	a1,a0
ffffffffc02024da:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc02024de:	fd79                	bnez	a0,ffffffffc02024bc <vmm_init+0x6a>
        assert(vma != NULL);
ffffffffc02024e0:	00005697          	auipc	a3,0x5
ffffffffc02024e4:	a5068693          	addi	a3,a3,-1456 # ffffffffc0206f30 <commands+0x1208>
ffffffffc02024e8:	00004617          	auipc	a2,0x4
ffffffffc02024ec:	cc060613          	addi	a2,a2,-832 # ffffffffc02061a8 <commands+0x480>
ffffffffc02024f0:	11900593          	li	a1,281
ffffffffc02024f4:	00004517          	auipc	a0,0x4
ffffffffc02024f8:	6cc50513          	addi	a0,a0,1740 # ffffffffc0206bc0 <commands+0xe98>
ffffffffc02024fc:	d19fd0ef          	jal	ra,ffffffffc0200214 <__panic>
ffffffffc0202500:	6418                	ld	a4,8(s0)
ffffffffc0202502:	479d                	li	a5,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc0202504:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc0202508:	2ee40063          	beq	s0,a4,ffffffffc02027e8 <vmm_init+0x396>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc020250c:	fe873603          	ld	a2,-24(a4)
ffffffffc0202510:	ffe78693          	addi	a3,a5,-2 # 1ffffe <_binary_obj___user_exit_out_size+0x1f5536>
ffffffffc0202514:	24d61a63          	bne	a2,a3,ffffffffc0202768 <vmm_init+0x316>
ffffffffc0202518:	ff073683          	ld	a3,-16(a4)
ffffffffc020251c:	24f69663          	bne	a3,a5,ffffffffc0202768 <vmm_init+0x316>
ffffffffc0202520:	0795                	addi	a5,a5,5
ffffffffc0202522:	6718                	ld	a4,8(a4)
    for (i = 1; i <= step2; i ++) {
ffffffffc0202524:	feb792e3          	bne	a5,a1,ffffffffc0202508 <vmm_init+0xb6>
ffffffffc0202528:	491d                	li	s2,7
ffffffffc020252a:	4495                	li	s1,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc020252c:	1f900a93          	li	s5,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0202530:	85a6                	mv	a1,s1
ffffffffc0202532:	8522                	mv	a0,s0
ffffffffc0202534:	c99ff0ef          	jal	ra,ffffffffc02021cc <find_vma>
ffffffffc0202538:	8a2a                	mv	s4,a0
        assert(vma1 != NULL);
ffffffffc020253a:	30050763          	beqz	a0,ffffffffc0202848 <vmm_init+0x3f6>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc020253e:	00148593          	addi	a1,s1,1
ffffffffc0202542:	8522                	mv	a0,s0
ffffffffc0202544:	c89ff0ef          	jal	ra,ffffffffc02021cc <find_vma>
ffffffffc0202548:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc020254a:	2c050f63          	beqz	a0,ffffffffc0202828 <vmm_init+0x3d6>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc020254e:	85ca                	mv	a1,s2
ffffffffc0202550:	8522                	mv	a0,s0
ffffffffc0202552:	c7bff0ef          	jal	ra,ffffffffc02021cc <find_vma>
        assert(vma3 == NULL);
ffffffffc0202556:	2a051963          	bnez	a0,ffffffffc0202808 <vmm_init+0x3b6>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc020255a:	00348593          	addi	a1,s1,3
ffffffffc020255e:	8522                	mv	a0,s0
ffffffffc0202560:	c6dff0ef          	jal	ra,ffffffffc02021cc <find_vma>
        assert(vma4 == NULL);
ffffffffc0202564:	32051263          	bnez	a0,ffffffffc0202888 <vmm_init+0x436>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc0202568:	00448593          	addi	a1,s1,4
ffffffffc020256c:	8522                	mv	a0,s0
ffffffffc020256e:	c5fff0ef          	jal	ra,ffffffffc02021cc <find_vma>
        assert(vma5 == NULL);
ffffffffc0202572:	2e051b63          	bnez	a0,ffffffffc0202868 <vmm_init+0x416>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0202576:	008a3783          	ld	a5,8(s4)
ffffffffc020257a:	20979763          	bne	a5,s1,ffffffffc0202788 <vmm_init+0x336>
ffffffffc020257e:	010a3783          	ld	a5,16(s4)
ffffffffc0202582:	21279363          	bne	a5,s2,ffffffffc0202788 <vmm_init+0x336>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0202586:	0089b783          	ld	a5,8(s3) # fffffffffff80008 <end+0x3fcd3638>
ffffffffc020258a:	20979f63          	bne	a5,s1,ffffffffc02027a8 <vmm_init+0x356>
ffffffffc020258e:	0109b783          	ld	a5,16(s3)
ffffffffc0202592:	21279b63          	bne	a5,s2,ffffffffc02027a8 <vmm_init+0x356>
ffffffffc0202596:	0495                	addi	s1,s1,5
ffffffffc0202598:	0915                	addi	s2,s2,5
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc020259a:	f9549be3          	bne	s1,s5,ffffffffc0202530 <vmm_init+0xde>
ffffffffc020259e:	4491                	li	s1,4
    }

    for (i =4; i>=0; i--) {
ffffffffc02025a0:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc02025a2:	85a6                	mv	a1,s1
ffffffffc02025a4:	8522                	mv	a0,s0
ffffffffc02025a6:	c27ff0ef          	jal	ra,ffffffffc02021cc <find_vma>
ffffffffc02025aa:	0004859b          	sext.w	a1,s1
        if (vma_below_5 != NULL ) {
ffffffffc02025ae:	c90d                	beqz	a0,ffffffffc02025e0 <vmm_init+0x18e>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc02025b0:	6914                	ld	a3,16(a0)
ffffffffc02025b2:	6510                	ld	a2,8(a0)
ffffffffc02025b4:	00005517          	auipc	a0,0x5
ffffffffc02025b8:	86450513          	addi	a0,a0,-1948 # ffffffffc0206e18 <commands+0x10f0>
ffffffffc02025bc:	b15fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc02025c0:	00005697          	auipc	a3,0x5
ffffffffc02025c4:	88068693          	addi	a3,a3,-1920 # ffffffffc0206e40 <commands+0x1118>
ffffffffc02025c8:	00004617          	auipc	a2,0x4
ffffffffc02025cc:	be060613          	addi	a2,a2,-1056 # ffffffffc02061a8 <commands+0x480>
ffffffffc02025d0:	13b00593          	li	a1,315
ffffffffc02025d4:	00004517          	auipc	a0,0x4
ffffffffc02025d8:	5ec50513          	addi	a0,a0,1516 # ffffffffc0206bc0 <commands+0xe98>
ffffffffc02025dc:	c39fd0ef          	jal	ra,ffffffffc0200214 <__panic>
ffffffffc02025e0:	14fd                	addi	s1,s1,-1
    for (i =4; i>=0; i--) {
ffffffffc02025e2:	fd2490e3          	bne	s1,s2,ffffffffc02025a2 <vmm_init+0x150>
    }

    mm_destroy(mm);
ffffffffc02025e6:	8522                	mv	a0,s0
ffffffffc02025e8:	cf1ff0ef          	jal	ra,ffffffffc02022d8 <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc02025ec:	00005517          	auipc	a0,0x5
ffffffffc02025f0:	86c50513          	addi	a0,a0,-1940 # ffffffffc0206e58 <commands+0x1130>
ffffffffc02025f4:	addfd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc02025f8:	90dfe0ef          	jal	ra,ffffffffc0200f04 <nr_free_pages>
ffffffffc02025fc:	89aa                	mv	s3,a0

    check_mm_struct = mm_create();
ffffffffc02025fe:	b55ff0ef          	jal	ra,ffffffffc0202152 <mm_create>
ffffffffc0202602:	000aa797          	auipc	a5,0xaa
ffffffffc0202606:	2ca7b323          	sd	a0,710(a5) # ffffffffc02ac8c8 <check_mm_struct>
ffffffffc020260a:	84aa                	mv	s1,a0
    assert(check_mm_struct != NULL);
ffffffffc020260c:	36050663          	beqz	a0,ffffffffc0202978 <vmm_init+0x526>

    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202610:	000aa797          	auipc	a5,0xaa
ffffffffc0202614:	24078793          	addi	a5,a5,576 # ffffffffc02ac850 <boot_pgdir>
ffffffffc0202618:	0007b903          	ld	s2,0(a5)
    assert(pgdir[0] == 0);
ffffffffc020261c:	00093783          	ld	a5,0(s2)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202620:	01253c23          	sd	s2,24(a0)
    assert(pgdir[0] == 0);
ffffffffc0202624:	2c079e63          	bnez	a5,ffffffffc0202900 <vmm_init+0x4ae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0202628:	03000513          	li	a0,48
ffffffffc020262c:	016010ef          	jal	ra,ffffffffc0203642 <kmalloc>
ffffffffc0202630:	842a                	mv	s0,a0
    if (vma != NULL) {
ffffffffc0202632:	18050b63          	beqz	a0,ffffffffc02027c8 <vmm_init+0x376>
        vma->vm_end = vm_end;
ffffffffc0202636:	002007b7          	lui	a5,0x200
ffffffffc020263a:	e81c                	sd	a5,16(s0)
        vma->vm_flags = vm_flags;
ffffffffc020263c:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc020263e:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc0202640:	cc1c                	sw	a5,24(s0)
    insert_vma_struct(mm, vma);
ffffffffc0202642:	8526                	mv	a0,s1
        vma->vm_start = vm_start;
ffffffffc0202644:	00043423          	sd	zero,8(s0)
    insert_vma_struct(mm, vma);
ffffffffc0202648:	bc3ff0ef          	jal	ra,ffffffffc020220a <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc020264c:	10000593          	li	a1,256
ffffffffc0202650:	8526                	mv	a0,s1
ffffffffc0202652:	b7bff0ef          	jal	ra,ffffffffc02021cc <find_vma>
ffffffffc0202656:	10000793          	li	a5,256

    int i, sum = 0;

    for (i = 0; i < 100; i ++) {
ffffffffc020265a:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc020265e:	2ca41163          	bne	s0,a0,ffffffffc0202920 <vmm_init+0x4ce>
        *(char *)(addr + i) = i;
ffffffffc0202662:	00f78023          	sb	a5,0(a5) # 200000 <_binary_obj___user_exit_out_size+0x1f5538>
        sum += i;
ffffffffc0202666:	0785                	addi	a5,a5,1
    for (i = 0; i < 100; i ++) {
ffffffffc0202668:	fee79de3          	bne	a5,a4,ffffffffc0202662 <vmm_init+0x210>
        sum += i;
ffffffffc020266c:	6705                	lui	a4,0x1
    for (i = 0; i < 100; i ++) {
ffffffffc020266e:	10000793          	li	a5,256
        sum += i;
ffffffffc0202672:	35670713          	addi	a4,a4,854 # 1356 <_binary_obj___user_faultread_out_size-0x8272>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc0202676:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc020267a:	0007c683          	lbu	a3,0(a5)
ffffffffc020267e:	0785                	addi	a5,a5,1
ffffffffc0202680:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc0202682:	fec79ce3          	bne	a5,a2,ffffffffc020267a <vmm_init+0x228>
    }

    assert(sum == 0);
ffffffffc0202686:	2c071963          	bnez	a4,ffffffffc0202958 <vmm_init+0x506>
    return pa2page(PDE_ADDR(pde));
ffffffffc020268a:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc020268e:	000aaa97          	auipc	s5,0xaa
ffffffffc0202692:	1caa8a93          	addi	s5,s5,458 # ffffffffc02ac858 <npage>
ffffffffc0202696:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc020269a:	078a                	slli	a5,a5,0x2
ffffffffc020269c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020269e:	20e7f563          	bgeu	a5,a4,ffffffffc02028a8 <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc02026a2:	00006697          	auipc	a3,0x6
ffffffffc02026a6:	b0668693          	addi	a3,a3,-1274 # ffffffffc02081a8 <nbase>
ffffffffc02026aa:	0006ba03          	ld	s4,0(a3)
ffffffffc02026ae:	414786b3          	sub	a3,a5,s4
ffffffffc02026b2:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc02026b4:	8699                	srai	a3,a3,0x6
ffffffffc02026b6:	96d2                	add	a3,a3,s4
    return KADDR(page2pa(page));
ffffffffc02026b8:	00c69793          	slli	a5,a3,0xc
ffffffffc02026bc:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02026be:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02026c0:	28e7f063          	bgeu	a5,a4,ffffffffc0202940 <vmm_init+0x4ee>
ffffffffc02026c4:	000aa797          	auipc	a5,0xaa
ffffffffc02026c8:	1ec78793          	addi	a5,a5,492 # ffffffffc02ac8b0 <va_pa_offset>
ffffffffc02026cc:	6380                	ld	s0,0(a5)

    pde_t *pd1=pgdir,*pd0=page2kva(pde2page(pgdir[0]));
    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc02026ce:	4581                	li	a1,0
ffffffffc02026d0:	854a                	mv	a0,s2
ffffffffc02026d2:	9436                	add	s0,s0,a3
ffffffffc02026d4:	e09fe0ef          	jal	ra,ffffffffc02014dc <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc02026d8:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc02026da:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc02026de:	078a                	slli	a5,a5,0x2
ffffffffc02026e0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02026e2:	1ce7f363          	bgeu	a5,a4,ffffffffc02028a8 <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc02026e6:	000aa417          	auipc	s0,0xaa
ffffffffc02026ea:	1da40413          	addi	s0,s0,474 # ffffffffc02ac8c0 <pages>
ffffffffc02026ee:	6008                	ld	a0,0(s0)
ffffffffc02026f0:	414787b3          	sub	a5,a5,s4
ffffffffc02026f4:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc02026f6:	953e                	add	a0,a0,a5
ffffffffc02026f8:	4585                	li	a1,1
ffffffffc02026fa:	fc4fe0ef          	jal	ra,ffffffffc0200ebe <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc02026fe:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0202702:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202706:	078a                	slli	a5,a5,0x2
ffffffffc0202708:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020270a:	18e7ff63          	bgeu	a5,a4,ffffffffc02028a8 <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc020270e:	6008                	ld	a0,0(s0)
ffffffffc0202710:	414787b3          	sub	a5,a5,s4
ffffffffc0202714:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0202716:	4585                	li	a1,1
ffffffffc0202718:	953e                	add	a0,a0,a5
ffffffffc020271a:	fa4fe0ef          	jal	ra,ffffffffc0200ebe <free_pages>
    pgdir[0] = 0;
ffffffffc020271e:	00093023          	sd	zero,0(s2)
  asm volatile("sfence.vma");
ffffffffc0202722:	12000073          	sfence.vma
    flush_tlb();

    mm->pgdir = NULL;
ffffffffc0202726:	0004bc23          	sd	zero,24(s1)
    mm_destroy(mm);
ffffffffc020272a:	8526                	mv	a0,s1
ffffffffc020272c:	badff0ef          	jal	ra,ffffffffc02022d8 <mm_destroy>
    check_mm_struct = NULL;
ffffffffc0202730:	000aa797          	auipc	a5,0xaa
ffffffffc0202734:	1807bc23          	sd	zero,408(a5) # ffffffffc02ac8c8 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0202738:	fccfe0ef          	jal	ra,ffffffffc0200f04 <nr_free_pages>
ffffffffc020273c:	1aa99263          	bne	s3,a0,ffffffffc02028e0 <vmm_init+0x48e>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc0202740:	00004517          	auipc	a0,0x4
ffffffffc0202744:	7b850513          	addi	a0,a0,1976 # ffffffffc0206ef8 <commands+0x11d0>
ffffffffc0202748:	989fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
}
ffffffffc020274c:	7442                	ld	s0,48(sp)
ffffffffc020274e:	70e2                	ld	ra,56(sp)
ffffffffc0202750:	74a2                	ld	s1,40(sp)
ffffffffc0202752:	7902                	ld	s2,32(sp)
ffffffffc0202754:	69e2                	ld	s3,24(sp)
ffffffffc0202756:	6a42                	ld	s4,16(sp)
ffffffffc0202758:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc020275a:	00004517          	auipc	a0,0x4
ffffffffc020275e:	7be50513          	addi	a0,a0,1982 # ffffffffc0206f18 <commands+0x11f0>
}
ffffffffc0202762:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc0202764:	96dfd06f          	j	ffffffffc02000d0 <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0202768:	00004697          	auipc	a3,0x4
ffffffffc020276c:	5c868693          	addi	a3,a3,1480 # ffffffffc0206d30 <commands+0x1008>
ffffffffc0202770:	00004617          	auipc	a2,0x4
ffffffffc0202774:	a3860613          	addi	a2,a2,-1480 # ffffffffc02061a8 <commands+0x480>
ffffffffc0202778:	12200593          	li	a1,290
ffffffffc020277c:	00004517          	auipc	a0,0x4
ffffffffc0202780:	44450513          	addi	a0,a0,1092 # ffffffffc0206bc0 <commands+0xe98>
ffffffffc0202784:	a91fd0ef          	jal	ra,ffffffffc0200214 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0202788:	00004697          	auipc	a3,0x4
ffffffffc020278c:	63068693          	addi	a3,a3,1584 # ffffffffc0206db8 <commands+0x1090>
ffffffffc0202790:	00004617          	auipc	a2,0x4
ffffffffc0202794:	a1860613          	addi	a2,a2,-1512 # ffffffffc02061a8 <commands+0x480>
ffffffffc0202798:	13200593          	li	a1,306
ffffffffc020279c:	00004517          	auipc	a0,0x4
ffffffffc02027a0:	42450513          	addi	a0,a0,1060 # ffffffffc0206bc0 <commands+0xe98>
ffffffffc02027a4:	a71fd0ef          	jal	ra,ffffffffc0200214 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc02027a8:	00004697          	auipc	a3,0x4
ffffffffc02027ac:	64068693          	addi	a3,a3,1600 # ffffffffc0206de8 <commands+0x10c0>
ffffffffc02027b0:	00004617          	auipc	a2,0x4
ffffffffc02027b4:	9f860613          	addi	a2,a2,-1544 # ffffffffc02061a8 <commands+0x480>
ffffffffc02027b8:	13300593          	li	a1,307
ffffffffc02027bc:	00004517          	auipc	a0,0x4
ffffffffc02027c0:	40450513          	addi	a0,a0,1028 # ffffffffc0206bc0 <commands+0xe98>
ffffffffc02027c4:	a51fd0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(vma != NULL);
ffffffffc02027c8:	00004697          	auipc	a3,0x4
ffffffffc02027cc:	76868693          	addi	a3,a3,1896 # ffffffffc0206f30 <commands+0x1208>
ffffffffc02027d0:	00004617          	auipc	a2,0x4
ffffffffc02027d4:	9d860613          	addi	a2,a2,-1576 # ffffffffc02061a8 <commands+0x480>
ffffffffc02027d8:	15200593          	li	a1,338
ffffffffc02027dc:	00004517          	auipc	a0,0x4
ffffffffc02027e0:	3e450513          	addi	a0,a0,996 # ffffffffc0206bc0 <commands+0xe98>
ffffffffc02027e4:	a31fd0ef          	jal	ra,ffffffffc0200214 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc02027e8:	00004697          	auipc	a3,0x4
ffffffffc02027ec:	53068693          	addi	a3,a3,1328 # ffffffffc0206d18 <commands+0xff0>
ffffffffc02027f0:	00004617          	auipc	a2,0x4
ffffffffc02027f4:	9b860613          	addi	a2,a2,-1608 # ffffffffc02061a8 <commands+0x480>
ffffffffc02027f8:	12000593          	li	a1,288
ffffffffc02027fc:	00004517          	auipc	a0,0x4
ffffffffc0202800:	3c450513          	addi	a0,a0,964 # ffffffffc0206bc0 <commands+0xe98>
ffffffffc0202804:	a11fd0ef          	jal	ra,ffffffffc0200214 <__panic>
        assert(vma3 == NULL);
ffffffffc0202808:	00004697          	auipc	a3,0x4
ffffffffc020280c:	58068693          	addi	a3,a3,1408 # ffffffffc0206d88 <commands+0x1060>
ffffffffc0202810:	00004617          	auipc	a2,0x4
ffffffffc0202814:	99860613          	addi	a2,a2,-1640 # ffffffffc02061a8 <commands+0x480>
ffffffffc0202818:	12c00593          	li	a1,300
ffffffffc020281c:	00004517          	auipc	a0,0x4
ffffffffc0202820:	3a450513          	addi	a0,a0,932 # ffffffffc0206bc0 <commands+0xe98>
ffffffffc0202824:	9f1fd0ef          	jal	ra,ffffffffc0200214 <__panic>
        assert(vma2 != NULL);
ffffffffc0202828:	00004697          	auipc	a3,0x4
ffffffffc020282c:	55068693          	addi	a3,a3,1360 # ffffffffc0206d78 <commands+0x1050>
ffffffffc0202830:	00004617          	auipc	a2,0x4
ffffffffc0202834:	97860613          	addi	a2,a2,-1672 # ffffffffc02061a8 <commands+0x480>
ffffffffc0202838:	12a00593          	li	a1,298
ffffffffc020283c:	00004517          	auipc	a0,0x4
ffffffffc0202840:	38450513          	addi	a0,a0,900 # ffffffffc0206bc0 <commands+0xe98>
ffffffffc0202844:	9d1fd0ef          	jal	ra,ffffffffc0200214 <__panic>
        assert(vma1 != NULL);
ffffffffc0202848:	00004697          	auipc	a3,0x4
ffffffffc020284c:	52068693          	addi	a3,a3,1312 # ffffffffc0206d68 <commands+0x1040>
ffffffffc0202850:	00004617          	auipc	a2,0x4
ffffffffc0202854:	95860613          	addi	a2,a2,-1704 # ffffffffc02061a8 <commands+0x480>
ffffffffc0202858:	12800593          	li	a1,296
ffffffffc020285c:	00004517          	auipc	a0,0x4
ffffffffc0202860:	36450513          	addi	a0,a0,868 # ffffffffc0206bc0 <commands+0xe98>
ffffffffc0202864:	9b1fd0ef          	jal	ra,ffffffffc0200214 <__panic>
        assert(vma5 == NULL);
ffffffffc0202868:	00004697          	auipc	a3,0x4
ffffffffc020286c:	54068693          	addi	a3,a3,1344 # ffffffffc0206da8 <commands+0x1080>
ffffffffc0202870:	00004617          	auipc	a2,0x4
ffffffffc0202874:	93860613          	addi	a2,a2,-1736 # ffffffffc02061a8 <commands+0x480>
ffffffffc0202878:	13000593          	li	a1,304
ffffffffc020287c:	00004517          	auipc	a0,0x4
ffffffffc0202880:	34450513          	addi	a0,a0,836 # ffffffffc0206bc0 <commands+0xe98>
ffffffffc0202884:	991fd0ef          	jal	ra,ffffffffc0200214 <__panic>
        assert(vma4 == NULL);
ffffffffc0202888:	00004697          	auipc	a3,0x4
ffffffffc020288c:	51068693          	addi	a3,a3,1296 # ffffffffc0206d98 <commands+0x1070>
ffffffffc0202890:	00004617          	auipc	a2,0x4
ffffffffc0202894:	91860613          	addi	a2,a2,-1768 # ffffffffc02061a8 <commands+0x480>
ffffffffc0202898:	12e00593          	li	a1,302
ffffffffc020289c:	00004517          	auipc	a0,0x4
ffffffffc02028a0:	32450513          	addi	a0,a0,804 # ffffffffc0206bc0 <commands+0xe98>
ffffffffc02028a4:	971fd0ef          	jal	ra,ffffffffc0200214 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02028a8:	00004617          	auipc	a2,0x4
ffffffffc02028ac:	cf060613          	addi	a2,a2,-784 # ffffffffc0206598 <commands+0x870>
ffffffffc02028b0:	06200593          	li	a1,98
ffffffffc02028b4:	00004517          	auipc	a0,0x4
ffffffffc02028b8:	d0450513          	addi	a0,a0,-764 # ffffffffc02065b8 <commands+0x890>
ffffffffc02028bc:	959fd0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(mm != NULL);
ffffffffc02028c0:	00004697          	auipc	a3,0x4
ffffffffc02028c4:	44868693          	addi	a3,a3,1096 # ffffffffc0206d08 <commands+0xfe0>
ffffffffc02028c8:	00004617          	auipc	a2,0x4
ffffffffc02028cc:	8e060613          	addi	a2,a2,-1824 # ffffffffc02061a8 <commands+0x480>
ffffffffc02028d0:	10c00593          	li	a1,268
ffffffffc02028d4:	00004517          	auipc	a0,0x4
ffffffffc02028d8:	2ec50513          	addi	a0,a0,748 # ffffffffc0206bc0 <commands+0xe98>
ffffffffc02028dc:	939fd0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02028e0:	00004697          	auipc	a3,0x4
ffffffffc02028e4:	5f068693          	addi	a3,a3,1520 # ffffffffc0206ed0 <commands+0x11a8>
ffffffffc02028e8:	00004617          	auipc	a2,0x4
ffffffffc02028ec:	8c060613          	addi	a2,a2,-1856 # ffffffffc02061a8 <commands+0x480>
ffffffffc02028f0:	17000593          	li	a1,368
ffffffffc02028f4:	00004517          	auipc	a0,0x4
ffffffffc02028f8:	2cc50513          	addi	a0,a0,716 # ffffffffc0206bc0 <commands+0xe98>
ffffffffc02028fc:	919fd0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(pgdir[0] == 0);
ffffffffc0202900:	00004697          	auipc	a3,0x4
ffffffffc0202904:	59068693          	addi	a3,a3,1424 # ffffffffc0206e90 <commands+0x1168>
ffffffffc0202908:	00004617          	auipc	a2,0x4
ffffffffc020290c:	8a060613          	addi	a2,a2,-1888 # ffffffffc02061a8 <commands+0x480>
ffffffffc0202910:	14f00593          	li	a1,335
ffffffffc0202914:	00004517          	auipc	a0,0x4
ffffffffc0202918:	2ac50513          	addi	a0,a0,684 # ffffffffc0206bc0 <commands+0xe98>
ffffffffc020291c:	8f9fd0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc0202920:	00004697          	auipc	a3,0x4
ffffffffc0202924:	58068693          	addi	a3,a3,1408 # ffffffffc0206ea0 <commands+0x1178>
ffffffffc0202928:	00004617          	auipc	a2,0x4
ffffffffc020292c:	88060613          	addi	a2,a2,-1920 # ffffffffc02061a8 <commands+0x480>
ffffffffc0202930:	15700593          	li	a1,343
ffffffffc0202934:	00004517          	auipc	a0,0x4
ffffffffc0202938:	28c50513          	addi	a0,a0,652 # ffffffffc0206bc0 <commands+0xe98>
ffffffffc020293c:	8d9fd0ef          	jal	ra,ffffffffc0200214 <__panic>
    return KADDR(page2pa(page));
ffffffffc0202940:	00004617          	auipc	a2,0x4
ffffffffc0202944:	c2060613          	addi	a2,a2,-992 # ffffffffc0206560 <commands+0x838>
ffffffffc0202948:	06900593          	li	a1,105
ffffffffc020294c:	00004517          	auipc	a0,0x4
ffffffffc0202950:	c6c50513          	addi	a0,a0,-916 # ffffffffc02065b8 <commands+0x890>
ffffffffc0202954:	8c1fd0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(sum == 0);
ffffffffc0202958:	00004697          	auipc	a3,0x4
ffffffffc020295c:	56868693          	addi	a3,a3,1384 # ffffffffc0206ec0 <commands+0x1198>
ffffffffc0202960:	00004617          	auipc	a2,0x4
ffffffffc0202964:	84860613          	addi	a2,a2,-1976 # ffffffffc02061a8 <commands+0x480>
ffffffffc0202968:	16300593          	li	a1,355
ffffffffc020296c:	00004517          	auipc	a0,0x4
ffffffffc0202970:	25450513          	addi	a0,a0,596 # ffffffffc0206bc0 <commands+0xe98>
ffffffffc0202974:	8a1fd0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc0202978:	00004697          	auipc	a3,0x4
ffffffffc020297c:	50068693          	addi	a3,a3,1280 # ffffffffc0206e78 <commands+0x1150>
ffffffffc0202980:	00004617          	auipc	a2,0x4
ffffffffc0202984:	82860613          	addi	a2,a2,-2008 # ffffffffc02061a8 <commands+0x480>
ffffffffc0202988:	14b00593          	li	a1,331
ffffffffc020298c:	00004517          	auipc	a0,0x4
ffffffffc0202990:	23450513          	addi	a0,a0,564 # ffffffffc0206bc0 <commands+0xe98>
ffffffffc0202994:	881fd0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0202998 <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0202998:	1101                	addi	sp,sp,-32
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc020299a:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc020299c:	e822                	sd	s0,16(sp)
ffffffffc020299e:	e426                	sd	s1,8(sp)
ffffffffc02029a0:	ec06                	sd	ra,24(sp)
ffffffffc02029a2:	e04a                	sd	s2,0(sp)
ffffffffc02029a4:	8432                	mv	s0,a2
ffffffffc02029a6:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc02029a8:	825ff0ef          	jal	ra,ffffffffc02021cc <find_vma>

    pgfault_num++;
ffffffffc02029ac:	000aa797          	auipc	a5,0xaa
ffffffffc02029b0:	eb478793          	addi	a5,a5,-332 # ffffffffc02ac860 <pgfault_num>
ffffffffc02029b4:	439c                	lw	a5,0(a5)
ffffffffc02029b6:	2785                	addiw	a5,a5,1
ffffffffc02029b8:	000aa717          	auipc	a4,0xaa
ffffffffc02029bc:	eaf72423          	sw	a5,-344(a4) # ffffffffc02ac860 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc02029c0:	cd21                	beqz	a0,ffffffffc0202a18 <do_pgfault+0x80>
ffffffffc02029c2:	651c                	ld	a5,8(a0)
ffffffffc02029c4:	04f46a63          	bltu	s0,a5,ffffffffc0202a18 <do_pgfault+0x80>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc02029c8:	4d1c                	lw	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc02029ca:	4941                	li	s2,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc02029cc:	8b89                	andi	a5,a5,2
ffffffffc02029ce:	e78d                	bnez	a5,ffffffffc02029f8 <do_pgfault+0x60>
        perm |= READ_WRITE;
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc02029d0:	767d                	lui	a2,0xfffff

    pte_t *ptep=NULL;
  
    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc02029d2:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc02029d4:	8c71                	and	s0,s0,a2
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc02029d6:	85a2                	mv	a1,s0
ffffffffc02029d8:	4605                	li	a2,1
ffffffffc02029da:	d6afe0ef          	jal	ra,ffffffffc0200f44 <get_pte>
ffffffffc02029de:	cd31                	beqz	a0,ffffffffc0202a3a <do_pgfault+0xa2>
        cprintf("get_pte in do_pgfault failed\n");
        goto failed;
    }
    
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
ffffffffc02029e0:	610c                	ld	a1,0(a0)
ffffffffc02029e2:	cd89                	beqz	a1,ffffffffc02029fc <do_pgfault+0x64>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc02029e4:	000aa797          	auipc	a5,0xaa
ffffffffc02029e8:	e8c78793          	addi	a5,a5,-372 # ffffffffc02ac870 <swap_init_ok>
ffffffffc02029ec:	439c                	lw	a5,0(a5)
ffffffffc02029ee:	2781                	sext.w	a5,a5
ffffffffc02029f0:	cf8d                	beqz	a5,ffffffffc0202a2a <do_pgfault+0x92>
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            //(3) make the page swappable.
            page->pra_vaddr = addr;
ffffffffc02029f2:	02003c23          	sd	zero,56(zero) # 38 <_binary_obj___user_faultread_out_size-0x9590>
ffffffffc02029f6:	9002                	ebreak
        perm |= READ_WRITE;
ffffffffc02029f8:	495d                	li	s2,23
ffffffffc02029fa:	bfd9                	j	ffffffffc02029d0 <do_pgfault+0x38>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc02029fc:	6c88                	ld	a0,24(s1)
ffffffffc02029fe:	864a                	mv	a2,s2
ffffffffc0202a00:	85a2                	mv	a1,s0
ffffffffc0202a02:	e98ff0ef          	jal	ra,ffffffffc020209a <pgdir_alloc_page>
        } else {
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
   }
   ret = 0;
ffffffffc0202a06:	4781                	li	a5,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0202a08:	c129                	beqz	a0,ffffffffc0202a4a <do_pgfault+0xb2>
failed:
    return ret;
}
ffffffffc0202a0a:	60e2                	ld	ra,24(sp)
ffffffffc0202a0c:	6442                	ld	s0,16(sp)
ffffffffc0202a0e:	64a2                	ld	s1,8(sp)
ffffffffc0202a10:	6902                	ld	s2,0(sp)
ffffffffc0202a12:	853e                	mv	a0,a5
ffffffffc0202a14:	6105                	addi	sp,sp,32
ffffffffc0202a16:	8082                	ret
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0202a18:	85a2                	mv	a1,s0
ffffffffc0202a1a:	00004517          	auipc	a0,0x4
ffffffffc0202a1e:	1b650513          	addi	a0,a0,438 # ffffffffc0206bd0 <commands+0xea8>
ffffffffc0202a22:	eaefd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    int ret = -E_INVAL;
ffffffffc0202a26:	57f5                	li	a5,-3
        goto failed;
ffffffffc0202a28:	b7cd                	j	ffffffffc0202a0a <do_pgfault+0x72>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc0202a2a:	00004517          	auipc	a0,0x4
ffffffffc0202a2e:	21e50513          	addi	a0,a0,542 # ffffffffc0206c48 <commands+0xf20>
ffffffffc0202a32:	e9efd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0202a36:	57f1                	li	a5,-4
            goto failed;
ffffffffc0202a38:	bfc9                	j	ffffffffc0202a0a <do_pgfault+0x72>
        cprintf("get_pte in do_pgfault failed\n");
ffffffffc0202a3a:	00004517          	auipc	a0,0x4
ffffffffc0202a3e:	1c650513          	addi	a0,a0,454 # ffffffffc0206c00 <commands+0xed8>
ffffffffc0202a42:	e8efd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0202a46:	57f1                	li	a5,-4
        goto failed;
ffffffffc0202a48:	b7c9                	j	ffffffffc0202a0a <do_pgfault+0x72>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0202a4a:	00004517          	auipc	a0,0x4
ffffffffc0202a4e:	1d650513          	addi	a0,a0,470 # ffffffffc0206c20 <commands+0xef8>
ffffffffc0202a52:	e7efd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0202a56:	57f1                	li	a5,-4
            goto failed;
ffffffffc0202a58:	bf4d                	j	ffffffffc0202a0a <do_pgfault+0x72>

ffffffffc0202a5a <user_mem_check>:

bool
user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write) {
ffffffffc0202a5a:	7179                	addi	sp,sp,-48
ffffffffc0202a5c:	f022                	sd	s0,32(sp)
ffffffffc0202a5e:	f406                	sd	ra,40(sp)
ffffffffc0202a60:	ec26                	sd	s1,24(sp)
ffffffffc0202a62:	e84a                	sd	s2,16(sp)
ffffffffc0202a64:	e44e                	sd	s3,8(sp)
ffffffffc0202a66:	e052                	sd	s4,0(sp)
ffffffffc0202a68:	842e                	mv	s0,a1
    if (mm != NULL) {
ffffffffc0202a6a:	c135                	beqz	a0,ffffffffc0202ace <user_mem_check+0x74>
        if (!USER_ACCESS(addr, addr + len)) {
ffffffffc0202a6c:	002007b7          	lui	a5,0x200
ffffffffc0202a70:	04f5e663          	bltu	a1,a5,ffffffffc0202abc <user_mem_check+0x62>
ffffffffc0202a74:	00c584b3          	add	s1,a1,a2
ffffffffc0202a78:	0495f263          	bgeu	a1,s1,ffffffffc0202abc <user_mem_check+0x62>
ffffffffc0202a7c:	4785                	li	a5,1
ffffffffc0202a7e:	07fe                	slli	a5,a5,0x1f
ffffffffc0202a80:	0297ee63          	bltu	a5,s1,ffffffffc0202abc <user_mem_check+0x62>
ffffffffc0202a84:	892a                	mv	s2,a0
ffffffffc0202a86:	89b6                	mv	s3,a3
            }
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
                return 0;
            }
            if (write && (vma->vm_flags & VM_STACK)) {
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0202a88:	6a05                	lui	s4,0x1
ffffffffc0202a8a:	a821                	j	ffffffffc0202aa2 <user_mem_check+0x48>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0202a8c:	0027f693          	andi	a3,a5,2
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0202a90:	9752                	add	a4,a4,s4
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc0202a92:	8ba1                	andi	a5,a5,8
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0202a94:	c685                	beqz	a3,ffffffffc0202abc <user_mem_check+0x62>
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc0202a96:	c399                	beqz	a5,ffffffffc0202a9c <user_mem_check+0x42>
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0202a98:	02e46263          	bltu	s0,a4,ffffffffc0202abc <user_mem_check+0x62>
                    return 0;
                }
            }
            start = vma->vm_end;
ffffffffc0202a9c:	6900                	ld	s0,16(a0)
        while (start < end) {
ffffffffc0202a9e:	04947663          	bgeu	s0,s1,ffffffffc0202aea <user_mem_check+0x90>
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start) {
ffffffffc0202aa2:	85a2                	mv	a1,s0
ffffffffc0202aa4:	854a                	mv	a0,s2
ffffffffc0202aa6:	f26ff0ef          	jal	ra,ffffffffc02021cc <find_vma>
ffffffffc0202aaa:	c909                	beqz	a0,ffffffffc0202abc <user_mem_check+0x62>
ffffffffc0202aac:	6518                	ld	a4,8(a0)
ffffffffc0202aae:	00e46763          	bltu	s0,a4,ffffffffc0202abc <user_mem_check+0x62>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0202ab2:	4d1c                	lw	a5,24(a0)
ffffffffc0202ab4:	fc099ce3          	bnez	s3,ffffffffc0202a8c <user_mem_check+0x32>
ffffffffc0202ab8:	8b85                	andi	a5,a5,1
ffffffffc0202aba:	f3ed                	bnez	a5,ffffffffc0202a9c <user_mem_check+0x42>
            return 0;
ffffffffc0202abc:	4501                	li	a0,0
        }
        return 1;
    }
    return KERN_ACCESS(addr, addr + len);
}
ffffffffc0202abe:	70a2                	ld	ra,40(sp)
ffffffffc0202ac0:	7402                	ld	s0,32(sp)
ffffffffc0202ac2:	64e2                	ld	s1,24(sp)
ffffffffc0202ac4:	6942                	ld	s2,16(sp)
ffffffffc0202ac6:	69a2                	ld	s3,8(sp)
ffffffffc0202ac8:	6a02                	ld	s4,0(sp)
ffffffffc0202aca:	6145                	addi	sp,sp,48
ffffffffc0202acc:	8082                	ret
    return KERN_ACCESS(addr, addr + len);
ffffffffc0202ace:	c02007b7          	lui	a5,0xc0200
ffffffffc0202ad2:	4501                	li	a0,0
ffffffffc0202ad4:	fef5e5e3          	bltu	a1,a5,ffffffffc0202abe <user_mem_check+0x64>
ffffffffc0202ad8:	962e                	add	a2,a2,a1
ffffffffc0202ada:	fec5f2e3          	bgeu	a1,a2,ffffffffc0202abe <user_mem_check+0x64>
ffffffffc0202ade:	c8000537          	lui	a0,0xc8000
ffffffffc0202ae2:	0505                	addi	a0,a0,1
ffffffffc0202ae4:	00a63533          	sltu	a0,a2,a0
ffffffffc0202ae8:	bfd9                	j	ffffffffc0202abe <user_mem_check+0x64>
        return 1;
ffffffffc0202aea:	4505                	li	a0,1
ffffffffc0202aec:	bfc9                	j	ffffffffc0202abe <user_mem_check+0x64>

ffffffffc0202aee <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc0202aee:	7135                	addi	sp,sp,-160
ffffffffc0202af0:	ed06                	sd	ra,152(sp)
ffffffffc0202af2:	e922                	sd	s0,144(sp)
ffffffffc0202af4:	e526                	sd	s1,136(sp)
ffffffffc0202af6:	e14a                	sd	s2,128(sp)
ffffffffc0202af8:	fcce                	sd	s3,120(sp)
ffffffffc0202afa:	f8d2                	sd	s4,112(sp)
ffffffffc0202afc:	f4d6                	sd	s5,104(sp)
ffffffffc0202afe:	f0da                	sd	s6,96(sp)
ffffffffc0202b00:	ecde                	sd	s7,88(sp)
ffffffffc0202b02:	e8e2                	sd	s8,80(sp)
ffffffffc0202b04:	e4e6                	sd	s9,72(sp)
ffffffffc0202b06:	e0ea                	sd	s10,64(sp)
ffffffffc0202b08:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc0202b0a:	44f010ef          	jal	ra,ffffffffc0204758 <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc0202b0e:	000aa797          	auipc	a5,0xaa
ffffffffc0202b12:	e4a78793          	addi	a5,a5,-438 # ffffffffc02ac958 <max_swap_offset>
ffffffffc0202b16:	6394                	ld	a3,0(a5)
ffffffffc0202b18:	010007b7          	lui	a5,0x1000
ffffffffc0202b1c:	17e1                	addi	a5,a5,-8
ffffffffc0202b1e:	ff968713          	addi	a4,a3,-7
ffffffffc0202b22:	4ae7ee63          	bltu	a5,a4,ffffffffc0202fde <swap_init+0x4f0>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }
     

     sm = &swap_manager_fifo;
ffffffffc0202b26:	0009f797          	auipc	a5,0x9f
ffffffffc0202b2a:	8d278793          	addi	a5,a5,-1838 # ffffffffc02a13f8 <swap_manager_fifo>
     int r = sm->init();
ffffffffc0202b2e:	6798                	ld	a4,8(a5)
     sm = &swap_manager_fifo;
ffffffffc0202b30:	000aa697          	auipc	a3,0xaa
ffffffffc0202b34:	d2f6bc23          	sd	a5,-712(a3) # ffffffffc02ac868 <sm>
     int r = sm->init();
ffffffffc0202b38:	9702                	jalr	a4
ffffffffc0202b3a:	8aaa                	mv	s5,a0
     
     if (r == 0)
ffffffffc0202b3c:	c10d                	beqz	a0,ffffffffc0202b5e <swap_init+0x70>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc0202b3e:	60ea                	ld	ra,152(sp)
ffffffffc0202b40:	644a                	ld	s0,144(sp)
ffffffffc0202b42:	8556                	mv	a0,s5
ffffffffc0202b44:	64aa                	ld	s1,136(sp)
ffffffffc0202b46:	690a                	ld	s2,128(sp)
ffffffffc0202b48:	79e6                	ld	s3,120(sp)
ffffffffc0202b4a:	7a46                	ld	s4,112(sp)
ffffffffc0202b4c:	7aa6                	ld	s5,104(sp)
ffffffffc0202b4e:	7b06                	ld	s6,96(sp)
ffffffffc0202b50:	6be6                	ld	s7,88(sp)
ffffffffc0202b52:	6c46                	ld	s8,80(sp)
ffffffffc0202b54:	6ca6                	ld	s9,72(sp)
ffffffffc0202b56:	6d06                	ld	s10,64(sp)
ffffffffc0202b58:	7de2                	ld	s11,56(sp)
ffffffffc0202b5a:	610d                	addi	sp,sp,160
ffffffffc0202b5c:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0202b5e:	000aa797          	auipc	a5,0xaa
ffffffffc0202b62:	d0a78793          	addi	a5,a5,-758 # ffffffffc02ac868 <sm>
ffffffffc0202b66:	639c                	ld	a5,0(a5)
ffffffffc0202b68:	00004517          	auipc	a0,0x4
ffffffffc0202b6c:	40850513          	addi	a0,a0,1032 # ffffffffc0206f70 <commands+0x1248>
ffffffffc0202b70:	000aa417          	auipc	s0,0xaa
ffffffffc0202b74:	e3840413          	addi	s0,s0,-456 # ffffffffc02ac9a8 <free_area>
ffffffffc0202b78:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc0202b7a:	4785                	li	a5,1
ffffffffc0202b7c:	000aa717          	auipc	a4,0xaa
ffffffffc0202b80:	cef72a23          	sw	a5,-780(a4) # ffffffffc02ac870 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0202b84:	d4cfd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc0202b88:	641c                	ld	a5,8(s0)
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202b8a:	36878e63          	beq	a5,s0,ffffffffc0202f06 <swap_init+0x418>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0202b8e:	ff07b703          	ld	a4,-16(a5)
ffffffffc0202b92:	8305                	srli	a4,a4,0x1
ffffffffc0202b94:	8b05                	andi	a4,a4,1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0202b96:	36070c63          	beqz	a4,ffffffffc0202f0e <swap_init+0x420>
     int ret, count = 0, total = 0, i;
ffffffffc0202b9a:	4481                	li	s1,0
ffffffffc0202b9c:	4901                	li	s2,0
ffffffffc0202b9e:	a031                	j	ffffffffc0202baa <swap_init+0xbc>
ffffffffc0202ba0:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc0202ba4:	8b09                	andi	a4,a4,2
ffffffffc0202ba6:	36070463          	beqz	a4,ffffffffc0202f0e <swap_init+0x420>
        count ++, total += p->property;
ffffffffc0202baa:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202bae:	679c                	ld	a5,8(a5)
ffffffffc0202bb0:	2905                	addiw	s2,s2,1
ffffffffc0202bb2:	9cb9                	addw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202bb4:	fe8796e3          	bne	a5,s0,ffffffffc0202ba0 <swap_init+0xb2>
ffffffffc0202bb8:	89a6                	mv	s3,s1
     }
     assert(total == nr_free_pages());
ffffffffc0202bba:	b4afe0ef          	jal	ra,ffffffffc0200f04 <nr_free_pages>
ffffffffc0202bbe:	69351863          	bne	a0,s3,ffffffffc020324e <swap_init+0x760>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc0202bc2:	8626                	mv	a2,s1
ffffffffc0202bc4:	85ca                	mv	a1,s2
ffffffffc0202bc6:	00004517          	auipc	a0,0x4
ffffffffc0202bca:	3f250513          	addi	a0,a0,1010 # ffffffffc0206fb8 <commands+0x1290>
ffffffffc0202bce:	d02fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc0202bd2:	d80ff0ef          	jal	ra,ffffffffc0202152 <mm_create>
ffffffffc0202bd6:	8baa                	mv	s7,a0
     assert(mm != NULL);
ffffffffc0202bd8:	60050b63          	beqz	a0,ffffffffc02031ee <swap_init+0x700>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc0202bdc:	000aa797          	auipc	a5,0xaa
ffffffffc0202be0:	cec78793          	addi	a5,a5,-788 # ffffffffc02ac8c8 <check_mm_struct>
ffffffffc0202be4:	639c                	ld	a5,0(a5)
ffffffffc0202be6:	62079463          	bnez	a5,ffffffffc020320e <swap_init+0x720>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202bea:	000aa797          	auipc	a5,0xaa
ffffffffc0202bee:	c6678793          	addi	a5,a5,-922 # ffffffffc02ac850 <boot_pgdir>
ffffffffc0202bf2:	0007bb03          	ld	s6,0(a5)
     check_mm_struct = mm;
ffffffffc0202bf6:	000aa797          	auipc	a5,0xaa
ffffffffc0202bfa:	cca7b923          	sd	a0,-814(a5) # ffffffffc02ac8c8 <check_mm_struct>
     assert(pgdir[0] == 0);
ffffffffc0202bfe:	000b3783          	ld	a5,0(s6)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202c02:	01653c23          	sd	s6,24(a0)
     assert(pgdir[0] == 0);
ffffffffc0202c06:	4e079863          	bnez	a5,ffffffffc02030f6 <swap_init+0x608>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc0202c0a:	6599                	lui	a1,0x6
ffffffffc0202c0c:	460d                	li	a2,3
ffffffffc0202c0e:	6505                	lui	a0,0x1
ffffffffc0202c10:	d8eff0ef          	jal	ra,ffffffffc020219e <vma_create>
ffffffffc0202c14:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc0202c16:	50050063          	beqz	a0,ffffffffc0203116 <swap_init+0x628>

     insert_vma_struct(mm, vma);
ffffffffc0202c1a:	855e                	mv	a0,s7
ffffffffc0202c1c:	deeff0ef          	jal	ra,ffffffffc020220a <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc0202c20:	00004517          	auipc	a0,0x4
ffffffffc0202c24:	3d850513          	addi	a0,a0,984 # ffffffffc0206ff8 <commands+0x12d0>
ffffffffc0202c28:	ca8fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc0202c2c:	018bb503          	ld	a0,24(s7)
ffffffffc0202c30:	4605                	li	a2,1
ffffffffc0202c32:	6585                	lui	a1,0x1
ffffffffc0202c34:	b10fe0ef          	jal	ra,ffffffffc0200f44 <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc0202c38:	4e050f63          	beqz	a0,ffffffffc0203136 <swap_init+0x648>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202c3c:	00004517          	auipc	a0,0x4
ffffffffc0202c40:	40c50513          	addi	a0,a0,1036 # ffffffffc0207048 <commands+0x1320>
ffffffffc0202c44:	000aa997          	auipc	s3,0xaa
ffffffffc0202c48:	c8c98993          	addi	s3,s3,-884 # ffffffffc02ac8d0 <check_rp>
ffffffffc0202c4c:	c84fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202c50:	000aaa17          	auipc	s4,0xaa
ffffffffc0202c54:	ca0a0a13          	addi	s4,s4,-864 # ffffffffc02ac8f0 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202c58:	8c4e                	mv	s8,s3
          check_rp[i] = alloc_page();
ffffffffc0202c5a:	4505                	li	a0,1
ffffffffc0202c5c:	9dafe0ef          	jal	ra,ffffffffc0200e36 <alloc_pages>
ffffffffc0202c60:	00ac3023          	sd	a0,0(s8) # 200000 <_binary_obj___user_exit_out_size+0x1f5538>
          assert(check_rp[i] != NULL );
ffffffffc0202c64:	32050d63          	beqz	a0,ffffffffc0202f9e <swap_init+0x4b0>
ffffffffc0202c68:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc0202c6a:	8b89                	andi	a5,a5,2
ffffffffc0202c6c:	30079963          	bnez	a5,ffffffffc0202f7e <swap_init+0x490>
ffffffffc0202c70:	0c21                	addi	s8,s8,8
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202c72:	ff4c14e3          	bne	s8,s4,ffffffffc0202c5a <swap_init+0x16c>
     }
     list_entry_t free_list_store = free_list;
ffffffffc0202c76:	601c                	ld	a5,0(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc0202c78:	000aac17          	auipc	s8,0xaa
ffffffffc0202c7c:	c58c0c13          	addi	s8,s8,-936 # ffffffffc02ac8d0 <check_rp>
     list_entry_t free_list_store = free_list;
ffffffffc0202c80:	ec3e                	sd	a5,24(sp)
ffffffffc0202c82:	641c                	ld	a5,8(s0)
ffffffffc0202c84:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc0202c86:	481c                	lw	a5,16(s0)
ffffffffc0202c88:	f43e                	sd	a5,40(sp)
    elm->prev = elm->next = elm;
ffffffffc0202c8a:	000aa797          	auipc	a5,0xaa
ffffffffc0202c8e:	d287b323          	sd	s0,-730(a5) # ffffffffc02ac9b0 <free_area+0x8>
ffffffffc0202c92:	000aa797          	auipc	a5,0xaa
ffffffffc0202c96:	d087bb23          	sd	s0,-746(a5) # ffffffffc02ac9a8 <free_area>
     nr_free = 0;
ffffffffc0202c9a:	000aa797          	auipc	a5,0xaa
ffffffffc0202c9e:	d007af23          	sw	zero,-738(a5) # ffffffffc02ac9b8 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc0202ca2:	000c3503          	ld	a0,0(s8)
ffffffffc0202ca6:	4585                	li	a1,1
ffffffffc0202ca8:	0c21                	addi	s8,s8,8
ffffffffc0202caa:	a14fe0ef          	jal	ra,ffffffffc0200ebe <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202cae:	ff4c1ae3          	bne	s8,s4,ffffffffc0202ca2 <swap_init+0x1b4>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0202cb2:	01042c03          	lw	s8,16(s0)
ffffffffc0202cb6:	4791                	li	a5,4
ffffffffc0202cb8:	50fc1b63          	bne	s8,a5,ffffffffc02031ce <swap_init+0x6e0>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc0202cbc:	00004517          	auipc	a0,0x4
ffffffffc0202cc0:	41450513          	addi	a0,a0,1044 # ffffffffc02070d0 <commands+0x13a8>
ffffffffc0202cc4:	c0cfd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202cc8:	6685                	lui	a3,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc0202cca:	000aa797          	auipc	a5,0xaa
ffffffffc0202cce:	b807ab23          	sw	zero,-1130(a5) # ffffffffc02ac860 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202cd2:	4629                	li	a2,10
     pgfault_num=0;
ffffffffc0202cd4:	000aa797          	auipc	a5,0xaa
ffffffffc0202cd8:	b8c78793          	addi	a5,a5,-1140 # ffffffffc02ac860 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202cdc:	00c68023          	sb	a2,0(a3) # 1000 <_binary_obj___user_faultread_out_size-0x85c8>
     assert(pgfault_num==1);
ffffffffc0202ce0:	4398                	lw	a4,0(a5)
ffffffffc0202ce2:	4585                	li	a1,1
ffffffffc0202ce4:	2701                	sext.w	a4,a4
ffffffffc0202ce6:	38b71863          	bne	a4,a1,ffffffffc0203076 <swap_init+0x588>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc0202cea:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==1);
ffffffffc0202cee:	4394                	lw	a3,0(a5)
ffffffffc0202cf0:	2681                	sext.w	a3,a3
ffffffffc0202cf2:	3ae69263          	bne	a3,a4,ffffffffc0203096 <swap_init+0x5a8>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc0202cf6:	6689                	lui	a3,0x2
ffffffffc0202cf8:	462d                	li	a2,11
ffffffffc0202cfa:	00c68023          	sb	a2,0(a3) # 2000 <_binary_obj___user_faultread_out_size-0x75c8>
     assert(pgfault_num==2);
ffffffffc0202cfe:	4398                	lw	a4,0(a5)
ffffffffc0202d00:	4589                	li	a1,2
ffffffffc0202d02:	2701                	sext.w	a4,a4
ffffffffc0202d04:	2eb71963          	bne	a4,a1,ffffffffc0202ff6 <swap_init+0x508>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc0202d08:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc0202d0c:	4394                	lw	a3,0(a5)
ffffffffc0202d0e:	2681                	sext.w	a3,a3
ffffffffc0202d10:	30e69363          	bne	a3,a4,ffffffffc0203016 <swap_init+0x528>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc0202d14:	668d                	lui	a3,0x3
ffffffffc0202d16:	4631                	li	a2,12
ffffffffc0202d18:	00c68023          	sb	a2,0(a3) # 3000 <_binary_obj___user_faultread_out_size-0x65c8>
     assert(pgfault_num==3);
ffffffffc0202d1c:	4398                	lw	a4,0(a5)
ffffffffc0202d1e:	458d                	li	a1,3
ffffffffc0202d20:	2701                	sext.w	a4,a4
ffffffffc0202d22:	30b71a63          	bne	a4,a1,ffffffffc0203036 <swap_init+0x548>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc0202d26:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc0202d2a:	4394                	lw	a3,0(a5)
ffffffffc0202d2c:	2681                	sext.w	a3,a3
ffffffffc0202d2e:	32e69463          	bne	a3,a4,ffffffffc0203056 <swap_init+0x568>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc0202d32:	6691                	lui	a3,0x4
ffffffffc0202d34:	4635                	li	a2,13
ffffffffc0202d36:	00c68023          	sb	a2,0(a3) # 4000 <_binary_obj___user_faultread_out_size-0x55c8>
     assert(pgfault_num==4);
ffffffffc0202d3a:	4398                	lw	a4,0(a5)
ffffffffc0202d3c:	2701                	sext.w	a4,a4
ffffffffc0202d3e:	37871c63          	bne	a4,s8,ffffffffc02030b6 <swap_init+0x5c8>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc0202d42:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc0202d46:	439c                	lw	a5,0(a5)
ffffffffc0202d48:	2781                	sext.w	a5,a5
ffffffffc0202d4a:	38e79663          	bne	a5,a4,ffffffffc02030d6 <swap_init+0x5e8>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc0202d4e:	481c                	lw	a5,16(s0)
ffffffffc0202d50:	40079363          	bnez	a5,ffffffffc0203156 <swap_init+0x668>
ffffffffc0202d54:	000aa797          	auipc	a5,0xaa
ffffffffc0202d58:	b9c78793          	addi	a5,a5,-1124 # ffffffffc02ac8f0 <swap_in_seq_no>
ffffffffc0202d5c:	000aa717          	auipc	a4,0xaa
ffffffffc0202d60:	bbc70713          	addi	a4,a4,-1092 # ffffffffc02ac918 <swap_out_seq_no>
ffffffffc0202d64:	000aa617          	auipc	a2,0xaa
ffffffffc0202d68:	bb460613          	addi	a2,a2,-1100 # ffffffffc02ac918 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc0202d6c:	56fd                	li	a3,-1
ffffffffc0202d6e:	c394                	sw	a3,0(a5)
ffffffffc0202d70:	c314                	sw	a3,0(a4)
ffffffffc0202d72:	0791                	addi	a5,a5,4
ffffffffc0202d74:	0711                	addi	a4,a4,4
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0202d76:	fef61ce3          	bne	a2,a5,ffffffffc0202d6e <swap_init+0x280>
ffffffffc0202d7a:	000aa697          	auipc	a3,0xaa
ffffffffc0202d7e:	bfe68693          	addi	a3,a3,-1026 # ffffffffc02ac978 <check_ptep>
ffffffffc0202d82:	000aa817          	auipc	a6,0xaa
ffffffffc0202d86:	b4e80813          	addi	a6,a6,-1202 # ffffffffc02ac8d0 <check_rp>
ffffffffc0202d8a:	6d05                	lui	s10,0x1
    if (PPN(pa) >= npage) {
ffffffffc0202d8c:	000aac97          	auipc	s9,0xaa
ffffffffc0202d90:	accc8c93          	addi	s9,s9,-1332 # ffffffffc02ac858 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0202d94:	00005d97          	auipc	s11,0x5
ffffffffc0202d98:	414d8d93          	addi	s11,s11,1044 # ffffffffc02081a8 <nbase>
ffffffffc0202d9c:	000aac17          	auipc	s8,0xaa
ffffffffc0202da0:	b24c0c13          	addi	s8,s8,-1244 # ffffffffc02ac8c0 <pages>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc0202da4:	0006b023          	sd	zero,0(a3)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202da8:	4601                	li	a2,0
ffffffffc0202daa:	85ea                	mv	a1,s10
ffffffffc0202dac:	855a                	mv	a0,s6
ffffffffc0202dae:	e842                	sd	a6,16(sp)
         check_ptep[i]=0;
ffffffffc0202db0:	e436                	sd	a3,8(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202db2:	992fe0ef          	jal	ra,ffffffffc0200f44 <get_pte>
ffffffffc0202db6:	66a2                	ld	a3,8(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0202db8:	6842                	ld	a6,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202dba:	e288                	sd	a0,0(a3)
         assert(check_ptep[i] != NULL);
ffffffffc0202dbc:	20050163          	beqz	a0,ffffffffc0202fbe <swap_init+0x4d0>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202dc0:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0202dc2:	0017f613          	andi	a2,a5,1
ffffffffc0202dc6:	1a060063          	beqz	a2,ffffffffc0202f66 <swap_init+0x478>
    if (PPN(pa) >= npage) {
ffffffffc0202dca:	000cb603          	ld	a2,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202dce:	078a                	slli	a5,a5,0x2
ffffffffc0202dd0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202dd2:	14c7fe63          	bgeu	a5,a2,ffffffffc0202f2e <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc0202dd6:	000db703          	ld	a4,0(s11)
ffffffffc0202dda:	000c3603          	ld	a2,0(s8)
ffffffffc0202dde:	00083583          	ld	a1,0(a6)
ffffffffc0202de2:	8f99                	sub	a5,a5,a4
ffffffffc0202de4:	079a                	slli	a5,a5,0x6
ffffffffc0202de6:	e43a                	sd	a4,8(sp)
ffffffffc0202de8:	97b2                	add	a5,a5,a2
ffffffffc0202dea:	14f59e63          	bne	a1,a5,ffffffffc0202f46 <swap_init+0x458>
ffffffffc0202dee:	6785                	lui	a5,0x1
ffffffffc0202df0:	9d3e                	add	s10,s10,a5
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202df2:	6795                	lui	a5,0x5
ffffffffc0202df4:	06a1                	addi	a3,a3,8
ffffffffc0202df6:	0821                	addi	a6,a6,8
ffffffffc0202df8:	fafd16e3          	bne	s10,a5,ffffffffc0202da4 <swap_init+0x2b6>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc0202dfc:	00004517          	auipc	a0,0x4
ffffffffc0202e00:	38c50513          	addi	a0,a0,908 # ffffffffc0207188 <commands+0x1460>
ffffffffc0202e04:	accfd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    int ret = sm->check_swap();
ffffffffc0202e08:	000aa797          	auipc	a5,0xaa
ffffffffc0202e0c:	a6078793          	addi	a5,a5,-1440 # ffffffffc02ac868 <sm>
ffffffffc0202e10:	639c                	ld	a5,0(a5)
ffffffffc0202e12:	7f9c                	ld	a5,56(a5)
ffffffffc0202e14:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc0202e16:	40051c63          	bnez	a0,ffffffffc020322e <swap_init+0x740>

     nr_free = nr_free_store;
ffffffffc0202e1a:	77a2                	ld	a5,40(sp)
ffffffffc0202e1c:	000aa717          	auipc	a4,0xaa
ffffffffc0202e20:	b8f72e23          	sw	a5,-1124(a4) # ffffffffc02ac9b8 <free_area+0x10>
     free_list = free_list_store;
ffffffffc0202e24:	67e2                	ld	a5,24(sp)
ffffffffc0202e26:	000aa717          	auipc	a4,0xaa
ffffffffc0202e2a:	b8f73123          	sd	a5,-1150(a4) # ffffffffc02ac9a8 <free_area>
ffffffffc0202e2e:	7782                	ld	a5,32(sp)
ffffffffc0202e30:	000aa717          	auipc	a4,0xaa
ffffffffc0202e34:	b8f73023          	sd	a5,-1152(a4) # ffffffffc02ac9b0 <free_area+0x8>

     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc0202e38:	0009b503          	ld	a0,0(s3)
ffffffffc0202e3c:	4585                	li	a1,1
ffffffffc0202e3e:	09a1                	addi	s3,s3,8
ffffffffc0202e40:	87efe0ef          	jal	ra,ffffffffc0200ebe <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202e44:	ff499ae3          	bne	s3,s4,ffffffffc0202e38 <swap_init+0x34a>
     } 

     //free_page(pte2page(*temp_ptep));

     mm->pgdir = NULL;
ffffffffc0202e48:	000bbc23          	sd	zero,24(s7)
     mm_destroy(mm);
ffffffffc0202e4c:	855e                	mv	a0,s7
ffffffffc0202e4e:	c8aff0ef          	jal	ra,ffffffffc02022d8 <mm_destroy>
     check_mm_struct = NULL;

     pde_t *pd1=pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0202e52:	000aa797          	auipc	a5,0xaa
ffffffffc0202e56:	9fe78793          	addi	a5,a5,-1538 # ffffffffc02ac850 <boot_pgdir>
ffffffffc0202e5a:	639c                	ld	a5,0(a5)
     check_mm_struct = NULL;
ffffffffc0202e5c:	000aa697          	auipc	a3,0xaa
ffffffffc0202e60:	a606b623          	sd	zero,-1428(a3) # ffffffffc02ac8c8 <check_mm_struct>
    if (PPN(pa) >= npage) {
ffffffffc0202e64:	000cb703          	ld	a4,0(s9)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202e68:	6394                	ld	a3,0(a5)
ffffffffc0202e6a:	068a                	slli	a3,a3,0x2
ffffffffc0202e6c:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202e6e:	0ce6f063          	bgeu	a3,a4,ffffffffc0202f2e <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc0202e72:	67a2                	ld	a5,8(sp)
ffffffffc0202e74:	000c3503          	ld	a0,0(s8)
ffffffffc0202e78:	8e9d                	sub	a3,a3,a5
ffffffffc0202e7a:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc0202e7c:	8699                	srai	a3,a3,0x6
ffffffffc0202e7e:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0202e80:	00c69793          	slli	a5,a3,0xc
ffffffffc0202e84:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202e86:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202e88:	2ee7f763          	bgeu	a5,a4,ffffffffc0203176 <swap_init+0x688>
     free_page(pde2page(pd0[0]));
ffffffffc0202e8c:	000aa797          	auipc	a5,0xaa
ffffffffc0202e90:	a2478793          	addi	a5,a5,-1500 # ffffffffc02ac8b0 <va_pa_offset>
ffffffffc0202e94:	639c                	ld	a5,0(a5)
ffffffffc0202e96:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202e98:	629c                	ld	a5,0(a3)
ffffffffc0202e9a:	078a                	slli	a5,a5,0x2
ffffffffc0202e9c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202e9e:	08e7f863          	bgeu	a5,a4,ffffffffc0202f2e <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc0202ea2:	69a2                	ld	s3,8(sp)
ffffffffc0202ea4:	4585                	li	a1,1
ffffffffc0202ea6:	413787b3          	sub	a5,a5,s3
ffffffffc0202eaa:	079a                	slli	a5,a5,0x6
ffffffffc0202eac:	953e                	add	a0,a0,a5
ffffffffc0202eae:	810fe0ef          	jal	ra,ffffffffc0200ebe <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202eb2:	000b3783          	ld	a5,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc0202eb6:	000cb703          	ld	a4,0(s9)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202eba:	078a                	slli	a5,a5,0x2
ffffffffc0202ebc:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202ebe:	06e7f863          	bgeu	a5,a4,ffffffffc0202f2e <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc0202ec2:	000c3503          	ld	a0,0(s8)
ffffffffc0202ec6:	413787b3          	sub	a5,a5,s3
ffffffffc0202eca:	079a                	slli	a5,a5,0x6
     free_page(pde2page(pd1[0]));
ffffffffc0202ecc:	4585                	li	a1,1
ffffffffc0202ece:	953e                	add	a0,a0,a5
ffffffffc0202ed0:	feffd0ef          	jal	ra,ffffffffc0200ebe <free_pages>
     pgdir[0] = 0;
ffffffffc0202ed4:	000b3023          	sd	zero,0(s6)
  asm volatile("sfence.vma");
ffffffffc0202ed8:	12000073          	sfence.vma
    return listelm->next;
ffffffffc0202edc:	641c                	ld	a5,8(s0)
     flush_tlb();

     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202ede:	00878963          	beq	a5,s0,ffffffffc0202ef0 <swap_init+0x402>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0202ee2:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202ee6:	679c                	ld	a5,8(a5)
ffffffffc0202ee8:	397d                	addiw	s2,s2,-1
ffffffffc0202eea:	9c99                	subw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202eec:	fe879be3          	bne	a5,s0,ffffffffc0202ee2 <swap_init+0x3f4>
     }
     assert(count==0);
ffffffffc0202ef0:	28091f63          	bnez	s2,ffffffffc020318e <swap_init+0x6a0>
     assert(total==0);
ffffffffc0202ef4:	2a049d63          	bnez	s1,ffffffffc02031ae <swap_init+0x6c0>

     cprintf("check_swap() succeeded!\n");
ffffffffc0202ef8:	00004517          	auipc	a0,0x4
ffffffffc0202efc:	2e050513          	addi	a0,a0,736 # ffffffffc02071d8 <commands+0x14b0>
ffffffffc0202f00:	9d0fd0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc0202f04:	b92d                	j	ffffffffc0202b3e <swap_init+0x50>
     int ret, count = 0, total = 0, i;
ffffffffc0202f06:	4481                	li	s1,0
ffffffffc0202f08:	4901                	li	s2,0
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202f0a:	4981                	li	s3,0
ffffffffc0202f0c:	b17d                	j	ffffffffc0202bba <swap_init+0xcc>
        assert(PageProperty(p));
ffffffffc0202f0e:	00004697          	auipc	a3,0x4
ffffffffc0202f12:	07a68693          	addi	a3,a3,122 # ffffffffc0206f88 <commands+0x1260>
ffffffffc0202f16:	00003617          	auipc	a2,0x3
ffffffffc0202f1a:	29260613          	addi	a2,a2,658 # ffffffffc02061a8 <commands+0x480>
ffffffffc0202f1e:	0bc00593          	li	a1,188
ffffffffc0202f22:	00004517          	auipc	a0,0x4
ffffffffc0202f26:	03e50513          	addi	a0,a0,62 # ffffffffc0206f60 <commands+0x1238>
ffffffffc0202f2a:	aeafd0ef          	jal	ra,ffffffffc0200214 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0202f2e:	00003617          	auipc	a2,0x3
ffffffffc0202f32:	66a60613          	addi	a2,a2,1642 # ffffffffc0206598 <commands+0x870>
ffffffffc0202f36:	06200593          	li	a1,98
ffffffffc0202f3a:	00003517          	auipc	a0,0x3
ffffffffc0202f3e:	67e50513          	addi	a0,a0,1662 # ffffffffc02065b8 <commands+0x890>
ffffffffc0202f42:	ad2fd0ef          	jal	ra,ffffffffc0200214 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202f46:	00004697          	auipc	a3,0x4
ffffffffc0202f4a:	21a68693          	addi	a3,a3,538 # ffffffffc0207160 <commands+0x1438>
ffffffffc0202f4e:	00003617          	auipc	a2,0x3
ffffffffc0202f52:	25a60613          	addi	a2,a2,602 # ffffffffc02061a8 <commands+0x480>
ffffffffc0202f56:	0fc00593          	li	a1,252
ffffffffc0202f5a:	00004517          	auipc	a0,0x4
ffffffffc0202f5e:	00650513          	addi	a0,a0,6 # ffffffffc0206f60 <commands+0x1238>
ffffffffc0202f62:	ab2fd0ef          	jal	ra,ffffffffc0200214 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0202f66:	00004617          	auipc	a2,0x4
ffffffffc0202f6a:	81260613          	addi	a2,a2,-2030 # ffffffffc0206778 <commands+0xa50>
ffffffffc0202f6e:	07400593          	li	a1,116
ffffffffc0202f72:	00003517          	auipc	a0,0x3
ffffffffc0202f76:	64650513          	addi	a0,a0,1606 # ffffffffc02065b8 <commands+0x890>
ffffffffc0202f7a:	a9afd0ef          	jal	ra,ffffffffc0200214 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc0202f7e:	00004697          	auipc	a3,0x4
ffffffffc0202f82:	10a68693          	addi	a3,a3,266 # ffffffffc0207088 <commands+0x1360>
ffffffffc0202f86:	00003617          	auipc	a2,0x3
ffffffffc0202f8a:	22260613          	addi	a2,a2,546 # ffffffffc02061a8 <commands+0x480>
ffffffffc0202f8e:	0dd00593          	li	a1,221
ffffffffc0202f92:	00004517          	auipc	a0,0x4
ffffffffc0202f96:	fce50513          	addi	a0,a0,-50 # ffffffffc0206f60 <commands+0x1238>
ffffffffc0202f9a:	a7afd0ef          	jal	ra,ffffffffc0200214 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc0202f9e:	00004697          	auipc	a3,0x4
ffffffffc0202fa2:	0d268693          	addi	a3,a3,210 # ffffffffc0207070 <commands+0x1348>
ffffffffc0202fa6:	00003617          	auipc	a2,0x3
ffffffffc0202faa:	20260613          	addi	a2,a2,514 # ffffffffc02061a8 <commands+0x480>
ffffffffc0202fae:	0dc00593          	li	a1,220
ffffffffc0202fb2:	00004517          	auipc	a0,0x4
ffffffffc0202fb6:	fae50513          	addi	a0,a0,-82 # ffffffffc0206f60 <commands+0x1238>
ffffffffc0202fba:	a5afd0ef          	jal	ra,ffffffffc0200214 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc0202fbe:	00004697          	auipc	a3,0x4
ffffffffc0202fc2:	18a68693          	addi	a3,a3,394 # ffffffffc0207148 <commands+0x1420>
ffffffffc0202fc6:	00003617          	auipc	a2,0x3
ffffffffc0202fca:	1e260613          	addi	a2,a2,482 # ffffffffc02061a8 <commands+0x480>
ffffffffc0202fce:	0fb00593          	li	a1,251
ffffffffc0202fd2:	00004517          	auipc	a0,0x4
ffffffffc0202fd6:	f8e50513          	addi	a0,a0,-114 # ffffffffc0206f60 <commands+0x1238>
ffffffffc0202fda:	a3afd0ef          	jal	ra,ffffffffc0200214 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc0202fde:	00004617          	auipc	a2,0x4
ffffffffc0202fe2:	f6260613          	addi	a2,a2,-158 # ffffffffc0206f40 <commands+0x1218>
ffffffffc0202fe6:	02800593          	li	a1,40
ffffffffc0202fea:	00004517          	auipc	a0,0x4
ffffffffc0202fee:	f7650513          	addi	a0,a0,-138 # ffffffffc0206f60 <commands+0x1238>
ffffffffc0202ff2:	a22fd0ef          	jal	ra,ffffffffc0200214 <__panic>
     assert(pgfault_num==2);
ffffffffc0202ff6:	00004697          	auipc	a3,0x4
ffffffffc0202ffa:	11268693          	addi	a3,a3,274 # ffffffffc0207108 <commands+0x13e0>
ffffffffc0202ffe:	00003617          	auipc	a2,0x3
ffffffffc0203002:	1aa60613          	addi	a2,a2,426 # ffffffffc02061a8 <commands+0x480>
ffffffffc0203006:	09700593          	li	a1,151
ffffffffc020300a:	00004517          	auipc	a0,0x4
ffffffffc020300e:	f5650513          	addi	a0,a0,-170 # ffffffffc0206f60 <commands+0x1238>
ffffffffc0203012:	a02fd0ef          	jal	ra,ffffffffc0200214 <__panic>
     assert(pgfault_num==2);
ffffffffc0203016:	00004697          	auipc	a3,0x4
ffffffffc020301a:	0f268693          	addi	a3,a3,242 # ffffffffc0207108 <commands+0x13e0>
ffffffffc020301e:	00003617          	auipc	a2,0x3
ffffffffc0203022:	18a60613          	addi	a2,a2,394 # ffffffffc02061a8 <commands+0x480>
ffffffffc0203026:	09900593          	li	a1,153
ffffffffc020302a:	00004517          	auipc	a0,0x4
ffffffffc020302e:	f3650513          	addi	a0,a0,-202 # ffffffffc0206f60 <commands+0x1238>
ffffffffc0203032:	9e2fd0ef          	jal	ra,ffffffffc0200214 <__panic>
     assert(pgfault_num==3);
ffffffffc0203036:	00004697          	auipc	a3,0x4
ffffffffc020303a:	0e268693          	addi	a3,a3,226 # ffffffffc0207118 <commands+0x13f0>
ffffffffc020303e:	00003617          	auipc	a2,0x3
ffffffffc0203042:	16a60613          	addi	a2,a2,362 # ffffffffc02061a8 <commands+0x480>
ffffffffc0203046:	09b00593          	li	a1,155
ffffffffc020304a:	00004517          	auipc	a0,0x4
ffffffffc020304e:	f1650513          	addi	a0,a0,-234 # ffffffffc0206f60 <commands+0x1238>
ffffffffc0203052:	9c2fd0ef          	jal	ra,ffffffffc0200214 <__panic>
     assert(pgfault_num==3);
ffffffffc0203056:	00004697          	auipc	a3,0x4
ffffffffc020305a:	0c268693          	addi	a3,a3,194 # ffffffffc0207118 <commands+0x13f0>
ffffffffc020305e:	00003617          	auipc	a2,0x3
ffffffffc0203062:	14a60613          	addi	a2,a2,330 # ffffffffc02061a8 <commands+0x480>
ffffffffc0203066:	09d00593          	li	a1,157
ffffffffc020306a:	00004517          	auipc	a0,0x4
ffffffffc020306e:	ef650513          	addi	a0,a0,-266 # ffffffffc0206f60 <commands+0x1238>
ffffffffc0203072:	9a2fd0ef          	jal	ra,ffffffffc0200214 <__panic>
     assert(pgfault_num==1);
ffffffffc0203076:	00004697          	auipc	a3,0x4
ffffffffc020307a:	08268693          	addi	a3,a3,130 # ffffffffc02070f8 <commands+0x13d0>
ffffffffc020307e:	00003617          	auipc	a2,0x3
ffffffffc0203082:	12a60613          	addi	a2,a2,298 # ffffffffc02061a8 <commands+0x480>
ffffffffc0203086:	09300593          	li	a1,147
ffffffffc020308a:	00004517          	auipc	a0,0x4
ffffffffc020308e:	ed650513          	addi	a0,a0,-298 # ffffffffc0206f60 <commands+0x1238>
ffffffffc0203092:	982fd0ef          	jal	ra,ffffffffc0200214 <__panic>
     assert(pgfault_num==1);
ffffffffc0203096:	00004697          	auipc	a3,0x4
ffffffffc020309a:	06268693          	addi	a3,a3,98 # ffffffffc02070f8 <commands+0x13d0>
ffffffffc020309e:	00003617          	auipc	a2,0x3
ffffffffc02030a2:	10a60613          	addi	a2,a2,266 # ffffffffc02061a8 <commands+0x480>
ffffffffc02030a6:	09500593          	li	a1,149
ffffffffc02030aa:	00004517          	auipc	a0,0x4
ffffffffc02030ae:	eb650513          	addi	a0,a0,-330 # ffffffffc0206f60 <commands+0x1238>
ffffffffc02030b2:	962fd0ef          	jal	ra,ffffffffc0200214 <__panic>
     assert(pgfault_num==4);
ffffffffc02030b6:	00004697          	auipc	a3,0x4
ffffffffc02030ba:	07268693          	addi	a3,a3,114 # ffffffffc0207128 <commands+0x1400>
ffffffffc02030be:	00003617          	auipc	a2,0x3
ffffffffc02030c2:	0ea60613          	addi	a2,a2,234 # ffffffffc02061a8 <commands+0x480>
ffffffffc02030c6:	09f00593          	li	a1,159
ffffffffc02030ca:	00004517          	auipc	a0,0x4
ffffffffc02030ce:	e9650513          	addi	a0,a0,-362 # ffffffffc0206f60 <commands+0x1238>
ffffffffc02030d2:	942fd0ef          	jal	ra,ffffffffc0200214 <__panic>
     assert(pgfault_num==4);
ffffffffc02030d6:	00004697          	auipc	a3,0x4
ffffffffc02030da:	05268693          	addi	a3,a3,82 # ffffffffc0207128 <commands+0x1400>
ffffffffc02030de:	00003617          	auipc	a2,0x3
ffffffffc02030e2:	0ca60613          	addi	a2,a2,202 # ffffffffc02061a8 <commands+0x480>
ffffffffc02030e6:	0a100593          	li	a1,161
ffffffffc02030ea:	00004517          	auipc	a0,0x4
ffffffffc02030ee:	e7650513          	addi	a0,a0,-394 # ffffffffc0206f60 <commands+0x1238>
ffffffffc02030f2:	922fd0ef          	jal	ra,ffffffffc0200214 <__panic>
     assert(pgdir[0] == 0);
ffffffffc02030f6:	00004697          	auipc	a3,0x4
ffffffffc02030fa:	d9a68693          	addi	a3,a3,-614 # ffffffffc0206e90 <commands+0x1168>
ffffffffc02030fe:	00003617          	auipc	a2,0x3
ffffffffc0203102:	0aa60613          	addi	a2,a2,170 # ffffffffc02061a8 <commands+0x480>
ffffffffc0203106:	0cc00593          	li	a1,204
ffffffffc020310a:	00004517          	auipc	a0,0x4
ffffffffc020310e:	e5650513          	addi	a0,a0,-426 # ffffffffc0206f60 <commands+0x1238>
ffffffffc0203112:	902fd0ef          	jal	ra,ffffffffc0200214 <__panic>
     assert(vma != NULL);
ffffffffc0203116:	00004697          	auipc	a3,0x4
ffffffffc020311a:	e1a68693          	addi	a3,a3,-486 # ffffffffc0206f30 <commands+0x1208>
ffffffffc020311e:	00003617          	auipc	a2,0x3
ffffffffc0203122:	08a60613          	addi	a2,a2,138 # ffffffffc02061a8 <commands+0x480>
ffffffffc0203126:	0cf00593          	li	a1,207
ffffffffc020312a:	00004517          	auipc	a0,0x4
ffffffffc020312e:	e3650513          	addi	a0,a0,-458 # ffffffffc0206f60 <commands+0x1238>
ffffffffc0203132:	8e2fd0ef          	jal	ra,ffffffffc0200214 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc0203136:	00004697          	auipc	a3,0x4
ffffffffc020313a:	efa68693          	addi	a3,a3,-262 # ffffffffc0207030 <commands+0x1308>
ffffffffc020313e:	00003617          	auipc	a2,0x3
ffffffffc0203142:	06a60613          	addi	a2,a2,106 # ffffffffc02061a8 <commands+0x480>
ffffffffc0203146:	0d700593          	li	a1,215
ffffffffc020314a:	00004517          	auipc	a0,0x4
ffffffffc020314e:	e1650513          	addi	a0,a0,-490 # ffffffffc0206f60 <commands+0x1238>
ffffffffc0203152:	8c2fd0ef          	jal	ra,ffffffffc0200214 <__panic>
     assert( nr_free == 0);         
ffffffffc0203156:	00004697          	auipc	a3,0x4
ffffffffc020315a:	fe268693          	addi	a3,a3,-30 # ffffffffc0207138 <commands+0x1410>
ffffffffc020315e:	00003617          	auipc	a2,0x3
ffffffffc0203162:	04a60613          	addi	a2,a2,74 # ffffffffc02061a8 <commands+0x480>
ffffffffc0203166:	0f300593          	li	a1,243
ffffffffc020316a:	00004517          	auipc	a0,0x4
ffffffffc020316e:	df650513          	addi	a0,a0,-522 # ffffffffc0206f60 <commands+0x1238>
ffffffffc0203172:	8a2fd0ef          	jal	ra,ffffffffc0200214 <__panic>
    return KADDR(page2pa(page));
ffffffffc0203176:	00003617          	auipc	a2,0x3
ffffffffc020317a:	3ea60613          	addi	a2,a2,1002 # ffffffffc0206560 <commands+0x838>
ffffffffc020317e:	06900593          	li	a1,105
ffffffffc0203182:	00003517          	auipc	a0,0x3
ffffffffc0203186:	43650513          	addi	a0,a0,1078 # ffffffffc02065b8 <commands+0x890>
ffffffffc020318a:	88afd0ef          	jal	ra,ffffffffc0200214 <__panic>
     assert(count==0);
ffffffffc020318e:	00004697          	auipc	a3,0x4
ffffffffc0203192:	02a68693          	addi	a3,a3,42 # ffffffffc02071b8 <commands+0x1490>
ffffffffc0203196:	00003617          	auipc	a2,0x3
ffffffffc020319a:	01260613          	addi	a2,a2,18 # ffffffffc02061a8 <commands+0x480>
ffffffffc020319e:	11d00593          	li	a1,285
ffffffffc02031a2:	00004517          	auipc	a0,0x4
ffffffffc02031a6:	dbe50513          	addi	a0,a0,-578 # ffffffffc0206f60 <commands+0x1238>
ffffffffc02031aa:	86afd0ef          	jal	ra,ffffffffc0200214 <__panic>
     assert(total==0);
ffffffffc02031ae:	00004697          	auipc	a3,0x4
ffffffffc02031b2:	01a68693          	addi	a3,a3,26 # ffffffffc02071c8 <commands+0x14a0>
ffffffffc02031b6:	00003617          	auipc	a2,0x3
ffffffffc02031ba:	ff260613          	addi	a2,a2,-14 # ffffffffc02061a8 <commands+0x480>
ffffffffc02031be:	11e00593          	li	a1,286
ffffffffc02031c2:	00004517          	auipc	a0,0x4
ffffffffc02031c6:	d9e50513          	addi	a0,a0,-610 # ffffffffc0206f60 <commands+0x1238>
ffffffffc02031ca:	84afd0ef          	jal	ra,ffffffffc0200214 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc02031ce:	00004697          	auipc	a3,0x4
ffffffffc02031d2:	eda68693          	addi	a3,a3,-294 # ffffffffc02070a8 <commands+0x1380>
ffffffffc02031d6:	00003617          	auipc	a2,0x3
ffffffffc02031da:	fd260613          	addi	a2,a2,-46 # ffffffffc02061a8 <commands+0x480>
ffffffffc02031de:	0ea00593          	li	a1,234
ffffffffc02031e2:	00004517          	auipc	a0,0x4
ffffffffc02031e6:	d7e50513          	addi	a0,a0,-642 # ffffffffc0206f60 <commands+0x1238>
ffffffffc02031ea:	82afd0ef          	jal	ra,ffffffffc0200214 <__panic>
     assert(mm != NULL);
ffffffffc02031ee:	00004697          	auipc	a3,0x4
ffffffffc02031f2:	b1a68693          	addi	a3,a3,-1254 # ffffffffc0206d08 <commands+0xfe0>
ffffffffc02031f6:	00003617          	auipc	a2,0x3
ffffffffc02031fa:	fb260613          	addi	a2,a2,-78 # ffffffffc02061a8 <commands+0x480>
ffffffffc02031fe:	0c400593          	li	a1,196
ffffffffc0203202:	00004517          	auipc	a0,0x4
ffffffffc0203206:	d5e50513          	addi	a0,a0,-674 # ffffffffc0206f60 <commands+0x1238>
ffffffffc020320a:	80afd0ef          	jal	ra,ffffffffc0200214 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc020320e:	00004697          	auipc	a3,0x4
ffffffffc0203212:	dd268693          	addi	a3,a3,-558 # ffffffffc0206fe0 <commands+0x12b8>
ffffffffc0203216:	00003617          	auipc	a2,0x3
ffffffffc020321a:	f9260613          	addi	a2,a2,-110 # ffffffffc02061a8 <commands+0x480>
ffffffffc020321e:	0c700593          	li	a1,199
ffffffffc0203222:	00004517          	auipc	a0,0x4
ffffffffc0203226:	d3e50513          	addi	a0,a0,-706 # ffffffffc0206f60 <commands+0x1238>
ffffffffc020322a:	febfc0ef          	jal	ra,ffffffffc0200214 <__panic>
     assert(ret==0);
ffffffffc020322e:	00004697          	auipc	a3,0x4
ffffffffc0203232:	f8268693          	addi	a3,a3,-126 # ffffffffc02071b0 <commands+0x1488>
ffffffffc0203236:	00003617          	auipc	a2,0x3
ffffffffc020323a:	f7260613          	addi	a2,a2,-142 # ffffffffc02061a8 <commands+0x480>
ffffffffc020323e:	10200593          	li	a1,258
ffffffffc0203242:	00004517          	auipc	a0,0x4
ffffffffc0203246:	d1e50513          	addi	a0,a0,-738 # ffffffffc0206f60 <commands+0x1238>
ffffffffc020324a:	fcbfc0ef          	jal	ra,ffffffffc0200214 <__panic>
     assert(total == nr_free_pages());
ffffffffc020324e:	00004697          	auipc	a3,0x4
ffffffffc0203252:	d4a68693          	addi	a3,a3,-694 # ffffffffc0206f98 <commands+0x1270>
ffffffffc0203256:	00003617          	auipc	a2,0x3
ffffffffc020325a:	f5260613          	addi	a2,a2,-174 # ffffffffc02061a8 <commands+0x480>
ffffffffc020325e:	0bf00593          	li	a1,191
ffffffffc0203262:	00004517          	auipc	a0,0x4
ffffffffc0203266:	cfe50513          	addi	a0,a0,-770 # ffffffffc0206f60 <commands+0x1238>
ffffffffc020326a:	fabfc0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc020326e <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc020326e:	000a9797          	auipc	a5,0xa9
ffffffffc0203272:	5fa78793          	addi	a5,a5,1530 # ffffffffc02ac868 <sm>
ffffffffc0203276:	639c                	ld	a5,0(a5)
ffffffffc0203278:	0107b303          	ld	t1,16(a5)
ffffffffc020327c:	8302                	jr	t1

ffffffffc020327e <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc020327e:	000a9797          	auipc	a5,0xa9
ffffffffc0203282:	5ea78793          	addi	a5,a5,1514 # ffffffffc02ac868 <sm>
ffffffffc0203286:	639c                	ld	a5,0(a5)
ffffffffc0203288:	0207b303          	ld	t1,32(a5)
ffffffffc020328c:	8302                	jr	t1

ffffffffc020328e <swap_out>:
{
ffffffffc020328e:	711d                	addi	sp,sp,-96
ffffffffc0203290:	ec86                	sd	ra,88(sp)
ffffffffc0203292:	e8a2                	sd	s0,80(sp)
ffffffffc0203294:	e4a6                	sd	s1,72(sp)
ffffffffc0203296:	e0ca                	sd	s2,64(sp)
ffffffffc0203298:	fc4e                	sd	s3,56(sp)
ffffffffc020329a:	f852                	sd	s4,48(sp)
ffffffffc020329c:	f456                	sd	s5,40(sp)
ffffffffc020329e:	f05a                	sd	s6,32(sp)
ffffffffc02032a0:	ec5e                	sd	s7,24(sp)
ffffffffc02032a2:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc02032a4:	cde9                	beqz	a1,ffffffffc020337e <swap_out+0xf0>
ffffffffc02032a6:	8ab2                	mv	s5,a2
ffffffffc02032a8:	892a                	mv	s2,a0
ffffffffc02032aa:	8a2e                	mv	s4,a1
ffffffffc02032ac:	4401                	li	s0,0
ffffffffc02032ae:	000a9997          	auipc	s3,0xa9
ffffffffc02032b2:	5ba98993          	addi	s3,s3,1466 # ffffffffc02ac868 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc02032b6:	00004b17          	auipc	s6,0x4
ffffffffc02032ba:	fa2b0b13          	addi	s6,s6,-94 # ffffffffc0207258 <commands+0x1530>
                    cprintf("SWAP: failed to save\n");
ffffffffc02032be:	00004b97          	auipc	s7,0x4
ffffffffc02032c2:	f82b8b93          	addi	s7,s7,-126 # ffffffffc0207240 <commands+0x1518>
ffffffffc02032c6:	a825                	j	ffffffffc02032fe <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc02032c8:	67a2                	ld	a5,8(sp)
ffffffffc02032ca:	8626                	mv	a2,s1
ffffffffc02032cc:	85a2                	mv	a1,s0
ffffffffc02032ce:	7f94                	ld	a3,56(a5)
ffffffffc02032d0:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc02032d2:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc02032d4:	82b1                	srli	a3,a3,0xc
ffffffffc02032d6:	0685                	addi	a3,a3,1
ffffffffc02032d8:	df9fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc02032dc:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc02032de:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc02032e0:	7d1c                	ld	a5,56(a0)
ffffffffc02032e2:	83b1                	srli	a5,a5,0xc
ffffffffc02032e4:	0785                	addi	a5,a5,1
ffffffffc02032e6:	07a2                	slli	a5,a5,0x8
ffffffffc02032e8:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc02032ec:	bd3fd0ef          	jal	ra,ffffffffc0200ebe <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc02032f0:	01893503          	ld	a0,24(s2)
ffffffffc02032f4:	85a6                	mv	a1,s1
ffffffffc02032f6:	d9ffe0ef          	jal	ra,ffffffffc0202094 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc02032fa:	048a0d63          	beq	s4,s0,ffffffffc0203354 <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc02032fe:	0009b783          	ld	a5,0(s3)
ffffffffc0203302:	8656                	mv	a2,s5
ffffffffc0203304:	002c                	addi	a1,sp,8
ffffffffc0203306:	7b9c                	ld	a5,48(a5)
ffffffffc0203308:	854a                	mv	a0,s2
ffffffffc020330a:	9782                	jalr	a5
          if (r != 0) {
ffffffffc020330c:	e12d                	bnez	a0,ffffffffc020336e <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc020330e:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203310:	01893503          	ld	a0,24(s2)
ffffffffc0203314:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0203316:	7f84                	ld	s1,56(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203318:	85a6                	mv	a1,s1
ffffffffc020331a:	c2bfd0ef          	jal	ra,ffffffffc0200f44 <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc020331e:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203320:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0203322:	8b85                	andi	a5,a5,1
ffffffffc0203324:	cfb9                	beqz	a5,ffffffffc0203382 <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0203326:	65a2                	ld	a1,8(sp)
ffffffffc0203328:	7d9c                	ld	a5,56(a1)
ffffffffc020332a:	83b1                	srli	a5,a5,0xc
ffffffffc020332c:	00178513          	addi	a0,a5,1
ffffffffc0203330:	0522                	slli	a0,a0,0x8
ffffffffc0203332:	45e010ef          	jal	ra,ffffffffc0204790 <swapfs_write>
ffffffffc0203336:	d949                	beqz	a0,ffffffffc02032c8 <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203338:	855e                	mv	a0,s7
ffffffffc020333a:	d97fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc020333e:	0009b783          	ld	a5,0(s3)
ffffffffc0203342:	6622                	ld	a2,8(sp)
ffffffffc0203344:	4681                	li	a3,0
ffffffffc0203346:	739c                	ld	a5,32(a5)
ffffffffc0203348:	85a6                	mv	a1,s1
ffffffffc020334a:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc020334c:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc020334e:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0203350:	fa8a17e3          	bne	s4,s0,ffffffffc02032fe <swap_out+0x70>
}
ffffffffc0203354:	8522                	mv	a0,s0
ffffffffc0203356:	60e6                	ld	ra,88(sp)
ffffffffc0203358:	6446                	ld	s0,80(sp)
ffffffffc020335a:	64a6                	ld	s1,72(sp)
ffffffffc020335c:	6906                	ld	s2,64(sp)
ffffffffc020335e:	79e2                	ld	s3,56(sp)
ffffffffc0203360:	7a42                	ld	s4,48(sp)
ffffffffc0203362:	7aa2                	ld	s5,40(sp)
ffffffffc0203364:	7b02                	ld	s6,32(sp)
ffffffffc0203366:	6be2                	ld	s7,24(sp)
ffffffffc0203368:	6c42                	ld	s8,16(sp)
ffffffffc020336a:	6125                	addi	sp,sp,96
ffffffffc020336c:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc020336e:	85a2                	mv	a1,s0
ffffffffc0203370:	00004517          	auipc	a0,0x4
ffffffffc0203374:	e8850513          	addi	a0,a0,-376 # ffffffffc02071f8 <commands+0x14d0>
ffffffffc0203378:	d59fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
                  break;
ffffffffc020337c:	bfe1                	j	ffffffffc0203354 <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc020337e:	4401                	li	s0,0
ffffffffc0203380:	bfd1                	j	ffffffffc0203354 <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203382:	00004697          	auipc	a3,0x4
ffffffffc0203386:	ea668693          	addi	a3,a3,-346 # ffffffffc0207228 <commands+0x1500>
ffffffffc020338a:	00003617          	auipc	a2,0x3
ffffffffc020338e:	e1e60613          	addi	a2,a2,-482 # ffffffffc02061a8 <commands+0x480>
ffffffffc0203392:	06800593          	li	a1,104
ffffffffc0203396:	00004517          	auipc	a0,0x4
ffffffffc020339a:	bca50513          	addi	a0,a0,-1078 # ffffffffc0206f60 <commands+0x1238>
ffffffffc020339e:	e77fc0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc02033a2 <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc02033a2:	c125                	beqz	a0,ffffffffc0203402 <slob_free+0x60>
		return;

	if (size)
ffffffffc02033a4:	e1a5                	bnez	a1,ffffffffc0203404 <slob_free+0x62>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02033a6:	100027f3          	csrr	a5,sstatus
ffffffffc02033aa:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02033ac:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02033ae:	e3bd                	bnez	a5,ffffffffc0203414 <slob_free+0x72>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02033b0:	0009e797          	auipc	a5,0x9e
ffffffffc02033b4:	08878793          	addi	a5,a5,136 # ffffffffc02a1438 <slobfree>
ffffffffc02033b8:	639c                	ld	a5,0(a5)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02033ba:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02033bc:	00a7fa63          	bgeu	a5,a0,ffffffffc02033d0 <slob_free+0x2e>
ffffffffc02033c0:	00e56c63          	bltu	a0,a4,ffffffffc02033d8 <slob_free+0x36>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02033c4:	00e7fa63          	bgeu	a5,a4,ffffffffc02033d8 <slob_free+0x36>
    return 0;
ffffffffc02033c8:	87ba                	mv	a5,a4
ffffffffc02033ca:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02033cc:	fea7eae3          	bltu	a5,a0,ffffffffc02033c0 <slob_free+0x1e>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02033d0:	fee7ece3          	bltu	a5,a4,ffffffffc02033c8 <slob_free+0x26>
ffffffffc02033d4:	fee57ae3          	bgeu	a0,a4,ffffffffc02033c8 <slob_free+0x26>
			break;

	if (b + b->units == cur->next) {
ffffffffc02033d8:	4110                	lw	a2,0(a0)
ffffffffc02033da:	00461693          	slli	a3,a2,0x4
ffffffffc02033de:	96aa                	add	a3,a3,a0
ffffffffc02033e0:	08d70b63          	beq	a4,a3,ffffffffc0203476 <slob_free+0xd4>
		b->units += cur->next->units;
		b->next = cur->next->next;
	} else
		b->next = cur->next;

	if (cur + cur->units == b) {
ffffffffc02033e4:	4394                	lw	a3,0(a5)
		b->next = cur->next;
ffffffffc02033e6:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc02033e8:	00469713          	slli	a4,a3,0x4
ffffffffc02033ec:	973e                	add	a4,a4,a5
ffffffffc02033ee:	08e50f63          	beq	a0,a4,ffffffffc020348c <slob_free+0xea>
		cur->units += b->units;
		cur->next = b->next;
	} else
		cur->next = b;
ffffffffc02033f2:	e788                	sd	a0,8(a5)

	slobfree = cur;
ffffffffc02033f4:	0009e717          	auipc	a4,0x9e
ffffffffc02033f8:	04f73223          	sd	a5,68(a4) # ffffffffc02a1438 <slobfree>
    if (flag) {
ffffffffc02033fc:	c199                	beqz	a1,ffffffffc0203402 <slob_free+0x60>
        intr_enable();
ffffffffc02033fe:	a2cfd06f          	j	ffffffffc020062a <intr_enable>
ffffffffc0203402:	8082                	ret
		b->units = SLOB_UNITS(size);
ffffffffc0203404:	05bd                	addi	a1,a1,15
ffffffffc0203406:	8191                	srli	a1,a1,0x4
ffffffffc0203408:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020340a:	100027f3          	csrr	a5,sstatus
ffffffffc020340e:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0203410:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203412:	dfd9                	beqz	a5,ffffffffc02033b0 <slob_free+0xe>
{
ffffffffc0203414:	1101                	addi	sp,sp,-32
ffffffffc0203416:	e42a                	sd	a0,8(sp)
ffffffffc0203418:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc020341a:	a16fd0ef          	jal	ra,ffffffffc0200630 <intr_disable>
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc020341e:	0009e797          	auipc	a5,0x9e
ffffffffc0203422:	01a78793          	addi	a5,a5,26 # ffffffffc02a1438 <slobfree>
ffffffffc0203426:	639c                	ld	a5,0(a5)
        return 1;
ffffffffc0203428:	6522                	ld	a0,8(sp)
ffffffffc020342a:	4585                	li	a1,1
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc020342c:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc020342e:	00a7fa63          	bgeu	a5,a0,ffffffffc0203442 <slob_free+0xa0>
ffffffffc0203432:	00e56c63          	bltu	a0,a4,ffffffffc020344a <slob_free+0xa8>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0203436:	00e7fa63          	bgeu	a5,a4,ffffffffc020344a <slob_free+0xa8>
    return 0;
ffffffffc020343a:	87ba                	mv	a5,a4
ffffffffc020343c:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc020343e:	fea7eae3          	bltu	a5,a0,ffffffffc0203432 <slob_free+0x90>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0203442:	fee7ece3          	bltu	a5,a4,ffffffffc020343a <slob_free+0x98>
ffffffffc0203446:	fee57ae3          	bgeu	a0,a4,ffffffffc020343a <slob_free+0x98>
	if (b + b->units == cur->next) {
ffffffffc020344a:	4110                	lw	a2,0(a0)
ffffffffc020344c:	00461693          	slli	a3,a2,0x4
ffffffffc0203450:	96aa                	add	a3,a3,a0
ffffffffc0203452:	04d70763          	beq	a4,a3,ffffffffc02034a0 <slob_free+0xfe>
		b->next = cur->next;
ffffffffc0203456:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc0203458:	4394                	lw	a3,0(a5)
ffffffffc020345a:	00469713          	slli	a4,a3,0x4
ffffffffc020345e:	973e                	add	a4,a4,a5
ffffffffc0203460:	04e50663          	beq	a0,a4,ffffffffc02034ac <slob_free+0x10a>
		cur->next = b;
ffffffffc0203464:	e788                	sd	a0,8(a5)
	slobfree = cur;
ffffffffc0203466:	0009e717          	auipc	a4,0x9e
ffffffffc020346a:	fcf73923          	sd	a5,-46(a4) # ffffffffc02a1438 <slobfree>
    if (flag) {
ffffffffc020346e:	e58d                	bnez	a1,ffffffffc0203498 <slob_free+0xf6>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc0203470:	60e2                	ld	ra,24(sp)
ffffffffc0203472:	6105                	addi	sp,sp,32
ffffffffc0203474:	8082                	ret
		b->units += cur->next->units;
ffffffffc0203476:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0203478:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc020347a:	9e35                	addw	a2,a2,a3
ffffffffc020347c:	c110                	sw	a2,0(a0)
	if (cur + cur->units == b) {
ffffffffc020347e:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc0203480:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc0203482:	00469713          	slli	a4,a3,0x4
ffffffffc0203486:	973e                	add	a4,a4,a5
ffffffffc0203488:	f6e515e3          	bne	a0,a4,ffffffffc02033f2 <slob_free+0x50>
		cur->units += b->units;
ffffffffc020348c:	4118                	lw	a4,0(a0)
		cur->next = b->next;
ffffffffc020348e:	6510                	ld	a2,8(a0)
		cur->units += b->units;
ffffffffc0203490:	9eb9                	addw	a3,a3,a4
ffffffffc0203492:	c394                	sw	a3,0(a5)
		cur->next = b->next;
ffffffffc0203494:	e790                	sd	a2,8(a5)
ffffffffc0203496:	bfb9                	j	ffffffffc02033f4 <slob_free+0x52>
}
ffffffffc0203498:	60e2                	ld	ra,24(sp)
ffffffffc020349a:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020349c:	98efd06f          	j	ffffffffc020062a <intr_enable>
		b->units += cur->next->units;
ffffffffc02034a0:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc02034a2:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc02034a4:	9e35                	addw	a2,a2,a3
ffffffffc02034a6:	c110                	sw	a2,0(a0)
		b->next = cur->next->next;
ffffffffc02034a8:	e518                	sd	a4,8(a0)
ffffffffc02034aa:	b77d                	j	ffffffffc0203458 <slob_free+0xb6>
		cur->units += b->units;
ffffffffc02034ac:	4118                	lw	a4,0(a0)
		cur->next = b->next;
ffffffffc02034ae:	6510                	ld	a2,8(a0)
		cur->units += b->units;
ffffffffc02034b0:	9eb9                	addw	a3,a3,a4
ffffffffc02034b2:	c394                	sw	a3,0(a5)
		cur->next = b->next;
ffffffffc02034b4:	e790                	sd	a2,8(a5)
ffffffffc02034b6:	bf45                	j	ffffffffc0203466 <slob_free+0xc4>

ffffffffc02034b8 <__slob_get_free_pages.isra.0>:
  struct Page * page = alloc_pages(1 << order);
ffffffffc02034b8:	4785                	li	a5,1
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc02034ba:	1141                	addi	sp,sp,-16
  struct Page * page = alloc_pages(1 << order);
ffffffffc02034bc:	00a7953b          	sllw	a0,a5,a0
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc02034c0:	e406                	sd	ra,8(sp)
  struct Page * page = alloc_pages(1 << order);
ffffffffc02034c2:	975fd0ef          	jal	ra,ffffffffc0200e36 <alloc_pages>
  if(!page)
ffffffffc02034c6:	cd1d                	beqz	a0,ffffffffc0203504 <__slob_get_free_pages.isra.0+0x4c>
    return page - pages + nbase;
ffffffffc02034c8:	000a9797          	auipc	a5,0xa9
ffffffffc02034cc:	3f878793          	addi	a5,a5,1016 # ffffffffc02ac8c0 <pages>
ffffffffc02034d0:	6394                	ld	a3,0(a5)
ffffffffc02034d2:	00005797          	auipc	a5,0x5
ffffffffc02034d6:	cd678793          	addi	a5,a5,-810 # ffffffffc02081a8 <nbase>
ffffffffc02034da:	8d15                	sub	a0,a0,a3
ffffffffc02034dc:	6394                	ld	a3,0(a5)
ffffffffc02034de:	8519                	srai	a0,a0,0x6
    return KADDR(page2pa(page));
ffffffffc02034e0:	000a9797          	auipc	a5,0xa9
ffffffffc02034e4:	37878793          	addi	a5,a5,888 # ffffffffc02ac858 <npage>
    return page - pages + nbase;
ffffffffc02034e8:	9536                	add	a0,a0,a3
    return KADDR(page2pa(page));
ffffffffc02034ea:	6398                	ld	a4,0(a5)
ffffffffc02034ec:	00c51793          	slli	a5,a0,0xc
ffffffffc02034f0:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02034f2:	0532                	slli	a0,a0,0xc
    return KADDR(page2pa(page));
ffffffffc02034f4:	00e7fb63          	bgeu	a5,a4,ffffffffc020350a <__slob_get_free_pages.isra.0+0x52>
ffffffffc02034f8:	000a9797          	auipc	a5,0xa9
ffffffffc02034fc:	3b878793          	addi	a5,a5,952 # ffffffffc02ac8b0 <va_pa_offset>
ffffffffc0203500:	6394                	ld	a3,0(a5)
ffffffffc0203502:	9536                	add	a0,a0,a3
}
ffffffffc0203504:	60a2                	ld	ra,8(sp)
ffffffffc0203506:	0141                	addi	sp,sp,16
ffffffffc0203508:	8082                	ret
ffffffffc020350a:	86aa                	mv	a3,a0
ffffffffc020350c:	00003617          	auipc	a2,0x3
ffffffffc0203510:	05460613          	addi	a2,a2,84 # ffffffffc0206560 <commands+0x838>
ffffffffc0203514:	06900593          	li	a1,105
ffffffffc0203518:	00003517          	auipc	a0,0x3
ffffffffc020351c:	0a050513          	addi	a0,a0,160 # ffffffffc02065b8 <commands+0x890>
ffffffffc0203520:	cf5fc0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0203524 <slob_alloc.isra.1.constprop.3>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc0203524:	1101                	addi	sp,sp,-32
ffffffffc0203526:	ec06                	sd	ra,24(sp)
ffffffffc0203528:	e822                	sd	s0,16(sp)
ffffffffc020352a:	e426                	sd	s1,8(sp)
ffffffffc020352c:	e04a                	sd	s2,0(sp)
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc020352e:	01050713          	addi	a4,a0,16
ffffffffc0203532:	6785                	lui	a5,0x1
ffffffffc0203534:	0cf77563          	bgeu	a4,a5,ffffffffc02035fe <slob_alloc.isra.1.constprop.3+0xda>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc0203538:	00f50493          	addi	s1,a0,15
ffffffffc020353c:	8091                	srli	s1,s1,0x4
ffffffffc020353e:	2481                	sext.w	s1,s1
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203540:	10002673          	csrr	a2,sstatus
ffffffffc0203544:	8a09                	andi	a2,a2,2
ffffffffc0203546:	e64d                	bnez	a2,ffffffffc02035f0 <slob_alloc.isra.1.constprop.3+0xcc>
	prev = slobfree;
ffffffffc0203548:	0009e917          	auipc	s2,0x9e
ffffffffc020354c:	ef090913          	addi	s2,s2,-272 # ffffffffc02a1438 <slobfree>
ffffffffc0203550:	00093683          	ld	a3,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0203554:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0203556:	4398                	lw	a4,0(a5)
ffffffffc0203558:	0a975063          	bge	a4,s1,ffffffffc02035f8 <slob_alloc.isra.1.constprop.3+0xd4>
		if (cur == slobfree) {
ffffffffc020355c:	00d78b63          	beq	a5,a3,ffffffffc0203572 <slob_alloc.isra.1.constprop.3+0x4e>
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0203560:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0203562:	4018                	lw	a4,0(s0)
ffffffffc0203564:	02975a63          	bge	a4,s1,ffffffffc0203598 <slob_alloc.isra.1.constprop.3+0x74>
ffffffffc0203568:	00093683          	ld	a3,0(s2)
ffffffffc020356c:	87a2                	mv	a5,s0
		if (cur == slobfree) {
ffffffffc020356e:	fed799e3          	bne	a5,a3,ffffffffc0203560 <slob_alloc.isra.1.constprop.3+0x3c>
    if (flag) {
ffffffffc0203572:	e225                	bnez	a2,ffffffffc02035d2 <slob_alloc.isra.1.constprop.3+0xae>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0203574:	4501                	li	a0,0
ffffffffc0203576:	f43ff0ef          	jal	ra,ffffffffc02034b8 <__slob_get_free_pages.isra.0>
ffffffffc020357a:	842a                	mv	s0,a0
			if (!cur)
ffffffffc020357c:	cd15                	beqz	a0,ffffffffc02035b8 <slob_alloc.isra.1.constprop.3+0x94>
			slob_free(cur, PAGE_SIZE);
ffffffffc020357e:	6585                	lui	a1,0x1
ffffffffc0203580:	e23ff0ef          	jal	ra,ffffffffc02033a2 <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203584:	10002673          	csrr	a2,sstatus
ffffffffc0203588:	8a09                	andi	a2,a2,2
ffffffffc020358a:	ee15                	bnez	a2,ffffffffc02035c6 <slob_alloc.isra.1.constprop.3+0xa2>
			cur = slobfree;
ffffffffc020358c:	00093783          	ld	a5,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0203590:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0203592:	4018                	lw	a4,0(s0)
ffffffffc0203594:	fc974ae3          	blt	a4,s1,ffffffffc0203568 <slob_alloc.isra.1.constprop.3+0x44>
			if (cur->units == units) /* exact fit? */
ffffffffc0203598:	04e48963          	beq	s1,a4,ffffffffc02035ea <slob_alloc.isra.1.constprop.3+0xc6>
				prev->next = cur + units;
ffffffffc020359c:	00449693          	slli	a3,s1,0x4
ffffffffc02035a0:	96a2                	add	a3,a3,s0
ffffffffc02035a2:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc02035a4:	640c                	ld	a1,8(s0)
				prev->next->units = cur->units - units;
ffffffffc02035a6:	9f05                	subw	a4,a4,s1
ffffffffc02035a8:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc02035aa:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc02035ac:	c004                	sw	s1,0(s0)
			slobfree = prev;
ffffffffc02035ae:	0009e717          	auipc	a4,0x9e
ffffffffc02035b2:	e8f73523          	sd	a5,-374(a4) # ffffffffc02a1438 <slobfree>
    if (flag) {
ffffffffc02035b6:	e20d                	bnez	a2,ffffffffc02035d8 <slob_alloc.isra.1.constprop.3+0xb4>
}
ffffffffc02035b8:	8522                	mv	a0,s0
ffffffffc02035ba:	60e2                	ld	ra,24(sp)
ffffffffc02035bc:	6442                	ld	s0,16(sp)
ffffffffc02035be:	64a2                	ld	s1,8(sp)
ffffffffc02035c0:	6902                	ld	s2,0(sp)
ffffffffc02035c2:	6105                	addi	sp,sp,32
ffffffffc02035c4:	8082                	ret
        intr_disable();
ffffffffc02035c6:	86afd0ef          	jal	ra,ffffffffc0200630 <intr_disable>
ffffffffc02035ca:	4605                	li	a2,1
			cur = slobfree;
ffffffffc02035cc:	00093783          	ld	a5,0(s2)
ffffffffc02035d0:	b7c1                	j	ffffffffc0203590 <slob_alloc.isra.1.constprop.3+0x6c>
        intr_enable();
ffffffffc02035d2:	858fd0ef          	jal	ra,ffffffffc020062a <intr_enable>
ffffffffc02035d6:	bf79                	j	ffffffffc0203574 <slob_alloc.isra.1.constprop.3+0x50>
ffffffffc02035d8:	852fd0ef          	jal	ra,ffffffffc020062a <intr_enable>
}
ffffffffc02035dc:	8522                	mv	a0,s0
ffffffffc02035de:	60e2                	ld	ra,24(sp)
ffffffffc02035e0:	6442                	ld	s0,16(sp)
ffffffffc02035e2:	64a2                	ld	s1,8(sp)
ffffffffc02035e4:	6902                	ld	s2,0(sp)
ffffffffc02035e6:	6105                	addi	sp,sp,32
ffffffffc02035e8:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc02035ea:	6418                	ld	a4,8(s0)
ffffffffc02035ec:	e798                	sd	a4,8(a5)
ffffffffc02035ee:	b7c1                	j	ffffffffc02035ae <slob_alloc.isra.1.constprop.3+0x8a>
        intr_disable();
ffffffffc02035f0:	840fd0ef          	jal	ra,ffffffffc0200630 <intr_disable>
ffffffffc02035f4:	4605                	li	a2,1
ffffffffc02035f6:	bf89                	j	ffffffffc0203548 <slob_alloc.isra.1.constprop.3+0x24>
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc02035f8:	843e                	mv	s0,a5
ffffffffc02035fa:	87b6                	mv	a5,a3
ffffffffc02035fc:	bf71                	j	ffffffffc0203598 <slob_alloc.isra.1.constprop.3+0x74>
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc02035fe:	00004697          	auipc	a3,0x4
ffffffffc0203602:	cba68693          	addi	a3,a3,-838 # ffffffffc02072b8 <commands+0x1590>
ffffffffc0203606:	00003617          	auipc	a2,0x3
ffffffffc020360a:	ba260613          	addi	a2,a2,-1118 # ffffffffc02061a8 <commands+0x480>
ffffffffc020360e:	06400593          	li	a1,100
ffffffffc0203612:	00004517          	auipc	a0,0x4
ffffffffc0203616:	cc650513          	addi	a0,a0,-826 # ffffffffc02072d8 <commands+0x15b0>
ffffffffc020361a:	bfbfc0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc020361e <kmalloc_init>:
slob_init(void) {
  cprintf("use SLOB allocator\n");
}

inline void 
kmalloc_init(void) {
ffffffffc020361e:	1141                	addi	sp,sp,-16
  cprintf("use SLOB allocator\n");
ffffffffc0203620:	00004517          	auipc	a0,0x4
ffffffffc0203624:	cd050513          	addi	a0,a0,-816 # ffffffffc02072f0 <commands+0x15c8>
kmalloc_init(void) {
ffffffffc0203628:	e406                	sd	ra,8(sp)
  cprintf("use SLOB allocator\n");
ffffffffc020362a:	aa7fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    slob_init();
    cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc020362e:	60a2                	ld	ra,8(sp)
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0203630:	00004517          	auipc	a0,0x4
ffffffffc0203634:	c6850513          	addi	a0,a0,-920 # ffffffffc0207298 <commands+0x1570>
}
ffffffffc0203638:	0141                	addi	sp,sp,16
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc020363a:	a97fc06f          	j	ffffffffc02000d0 <cprintf>

ffffffffc020363e <kallocated>:
}

size_t
kallocated(void) {
   return slob_allocated();
}
ffffffffc020363e:	4501                	li	a0,0
ffffffffc0203640:	8082                	ret

ffffffffc0203642 <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc0203642:	1101                	addi	sp,sp,-32
ffffffffc0203644:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0203646:	6905                	lui	s2,0x1
{
ffffffffc0203648:	e822                	sd	s0,16(sp)
ffffffffc020364a:	ec06                	sd	ra,24(sp)
ffffffffc020364c:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc020364e:	fef90793          	addi	a5,s2,-17 # fef <_binary_obj___user_faultread_out_size-0x85d9>
{
ffffffffc0203652:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0203654:	04a7fc63          	bgeu	a5,a0,ffffffffc02036ac <kmalloc+0x6a>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc0203658:	4561                	li	a0,24
ffffffffc020365a:	ecbff0ef          	jal	ra,ffffffffc0203524 <slob_alloc.isra.1.constprop.3>
ffffffffc020365e:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc0203660:	cd21                	beqz	a0,ffffffffc02036b8 <kmalloc+0x76>
	bb->order = find_order(size);
ffffffffc0203662:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc0203666:	4501                	li	a0,0
	for ( ; size > 4096 ; size >>=1)
ffffffffc0203668:	00f95763          	bge	s2,a5,ffffffffc0203676 <kmalloc+0x34>
ffffffffc020366c:	6705                	lui	a4,0x1
ffffffffc020366e:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc0203670:	2505                	addiw	a0,a0,1
	for ( ; size > 4096 ; size >>=1)
ffffffffc0203672:	fef74ee3          	blt	a4,a5,ffffffffc020366e <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc0203676:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc0203678:	e41ff0ef          	jal	ra,ffffffffc02034b8 <__slob_get_free_pages.isra.0>
ffffffffc020367c:	e488                	sd	a0,8(s1)
ffffffffc020367e:	842a                	mv	s0,a0
	if (bb->pages) {
ffffffffc0203680:	c935                	beqz	a0,ffffffffc02036f4 <kmalloc+0xb2>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203682:	100027f3          	csrr	a5,sstatus
ffffffffc0203686:	8b89                	andi	a5,a5,2
ffffffffc0203688:	e3a1                	bnez	a5,ffffffffc02036c8 <kmalloc+0x86>
		bb->next = bigblocks;
ffffffffc020368a:	000a9797          	auipc	a5,0xa9
ffffffffc020368e:	1ee78793          	addi	a5,a5,494 # ffffffffc02ac878 <bigblocks>
ffffffffc0203692:	639c                	ld	a5,0(a5)
		bigblocks = bb;
ffffffffc0203694:	000a9717          	auipc	a4,0xa9
ffffffffc0203698:	1e973223          	sd	s1,484(a4) # ffffffffc02ac878 <bigblocks>
		bb->next = bigblocks;
ffffffffc020369c:	e89c                	sd	a5,16(s1)
  return __kmalloc(size, 0);
}
ffffffffc020369e:	8522                	mv	a0,s0
ffffffffc02036a0:	60e2                	ld	ra,24(sp)
ffffffffc02036a2:	6442                	ld	s0,16(sp)
ffffffffc02036a4:	64a2                	ld	s1,8(sp)
ffffffffc02036a6:	6902                	ld	s2,0(sp)
ffffffffc02036a8:	6105                	addi	sp,sp,32
ffffffffc02036aa:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc02036ac:	0541                	addi	a0,a0,16
ffffffffc02036ae:	e77ff0ef          	jal	ra,ffffffffc0203524 <slob_alloc.isra.1.constprop.3>
		return m ? (void *)(m + 1) : 0;
ffffffffc02036b2:	01050413          	addi	s0,a0,16
ffffffffc02036b6:	f565                	bnez	a0,ffffffffc020369e <kmalloc+0x5c>
ffffffffc02036b8:	4401                	li	s0,0
}
ffffffffc02036ba:	8522                	mv	a0,s0
ffffffffc02036bc:	60e2                	ld	ra,24(sp)
ffffffffc02036be:	6442                	ld	s0,16(sp)
ffffffffc02036c0:	64a2                	ld	s1,8(sp)
ffffffffc02036c2:	6902                	ld	s2,0(sp)
ffffffffc02036c4:	6105                	addi	sp,sp,32
ffffffffc02036c6:	8082                	ret
        intr_disable();
ffffffffc02036c8:	f69fc0ef          	jal	ra,ffffffffc0200630 <intr_disable>
		bb->next = bigblocks;
ffffffffc02036cc:	000a9797          	auipc	a5,0xa9
ffffffffc02036d0:	1ac78793          	addi	a5,a5,428 # ffffffffc02ac878 <bigblocks>
ffffffffc02036d4:	639c                	ld	a5,0(a5)
		bigblocks = bb;
ffffffffc02036d6:	000a9717          	auipc	a4,0xa9
ffffffffc02036da:	1a973123          	sd	s1,418(a4) # ffffffffc02ac878 <bigblocks>
		bb->next = bigblocks;
ffffffffc02036de:	e89c                	sd	a5,16(s1)
        intr_enable();
ffffffffc02036e0:	f4bfc0ef          	jal	ra,ffffffffc020062a <intr_enable>
ffffffffc02036e4:	6480                	ld	s0,8(s1)
}
ffffffffc02036e6:	60e2                	ld	ra,24(sp)
ffffffffc02036e8:	64a2                	ld	s1,8(sp)
ffffffffc02036ea:	8522                	mv	a0,s0
ffffffffc02036ec:	6442                	ld	s0,16(sp)
ffffffffc02036ee:	6902                	ld	s2,0(sp)
ffffffffc02036f0:	6105                	addi	sp,sp,32
ffffffffc02036f2:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc02036f4:	45e1                	li	a1,24
ffffffffc02036f6:	8526                	mv	a0,s1
ffffffffc02036f8:	cabff0ef          	jal	ra,ffffffffc02033a2 <slob_free>
  return __kmalloc(size, 0);
ffffffffc02036fc:	b74d                	j	ffffffffc020369e <kmalloc+0x5c>

ffffffffc02036fe <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc02036fe:	c175                	beqz	a0,ffffffffc02037e2 <kfree+0xe4>
{
ffffffffc0203700:	1101                	addi	sp,sp,-32
ffffffffc0203702:	e426                	sd	s1,8(sp)
ffffffffc0203704:	ec06                	sd	ra,24(sp)
ffffffffc0203706:	e822                	sd	s0,16(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
ffffffffc0203708:	03451793          	slli	a5,a0,0x34
ffffffffc020370c:	84aa                	mv	s1,a0
ffffffffc020370e:	eb8d                	bnez	a5,ffffffffc0203740 <kfree+0x42>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203710:	100027f3          	csrr	a5,sstatus
ffffffffc0203714:	8b89                	andi	a5,a5,2
ffffffffc0203716:	efc9                	bnez	a5,ffffffffc02037b0 <kfree+0xb2>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0203718:	000a9797          	auipc	a5,0xa9
ffffffffc020371c:	16078793          	addi	a5,a5,352 # ffffffffc02ac878 <bigblocks>
ffffffffc0203720:	6394                	ld	a3,0(a5)
ffffffffc0203722:	ce99                	beqz	a3,ffffffffc0203740 <kfree+0x42>
			if (bb->pages == block) {
ffffffffc0203724:	669c                	ld	a5,8(a3)
ffffffffc0203726:	6a80                	ld	s0,16(a3)
ffffffffc0203728:	0af50e63          	beq	a0,a5,ffffffffc02037e4 <kfree+0xe6>
    return 0;
ffffffffc020372c:	4601                	li	a2,0
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc020372e:	c801                	beqz	s0,ffffffffc020373e <kfree+0x40>
			if (bb->pages == block) {
ffffffffc0203730:	6418                	ld	a4,8(s0)
ffffffffc0203732:	681c                	ld	a5,16(s0)
ffffffffc0203734:	00970f63          	beq	a4,s1,ffffffffc0203752 <kfree+0x54>
ffffffffc0203738:	86a2                	mv	a3,s0
ffffffffc020373a:	843e                	mv	s0,a5
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc020373c:	f875                	bnez	s0,ffffffffc0203730 <kfree+0x32>
    if (flag) {
ffffffffc020373e:	e659                	bnez	a2,ffffffffc02037cc <kfree+0xce>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc0203740:	6442                	ld	s0,16(sp)
ffffffffc0203742:	60e2                	ld	ra,24(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0203744:	ff048513          	addi	a0,s1,-16
}
ffffffffc0203748:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc020374a:	4581                	li	a1,0
}
ffffffffc020374c:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc020374e:	c55ff06f          	j	ffffffffc02033a2 <slob_free>
				*last = bb->next;
ffffffffc0203752:	ea9c                	sd	a5,16(a3)
ffffffffc0203754:	e641                	bnez	a2,ffffffffc02037dc <kfree+0xde>
    return pa2page(PADDR(kva));
ffffffffc0203756:	c02007b7          	lui	a5,0xc0200
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc020375a:	4018                	lw	a4,0(s0)
ffffffffc020375c:	08f4ea63          	bltu	s1,a5,ffffffffc02037f0 <kfree+0xf2>
ffffffffc0203760:	000a9797          	auipc	a5,0xa9
ffffffffc0203764:	15078793          	addi	a5,a5,336 # ffffffffc02ac8b0 <va_pa_offset>
ffffffffc0203768:	6394                	ld	a3,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc020376a:	000a9797          	auipc	a5,0xa9
ffffffffc020376e:	0ee78793          	addi	a5,a5,238 # ffffffffc02ac858 <npage>
ffffffffc0203772:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc0203774:	8c95                	sub	s1,s1,a3
    if (PPN(pa) >= npage) {
ffffffffc0203776:	80b1                	srli	s1,s1,0xc
ffffffffc0203778:	08f4f963          	bgeu	s1,a5,ffffffffc020380a <kfree+0x10c>
    return &pages[PPN(pa) - nbase];
ffffffffc020377c:	00005797          	auipc	a5,0x5
ffffffffc0203780:	a2c78793          	addi	a5,a5,-1492 # ffffffffc02081a8 <nbase>
ffffffffc0203784:	639c                	ld	a5,0(a5)
ffffffffc0203786:	000a9697          	auipc	a3,0xa9
ffffffffc020378a:	13a68693          	addi	a3,a3,314 # ffffffffc02ac8c0 <pages>
ffffffffc020378e:	6288                	ld	a0,0(a3)
ffffffffc0203790:	8c9d                	sub	s1,s1,a5
ffffffffc0203792:	049a                	slli	s1,s1,0x6
  free_pages(kva2page(kva), 1 << order);
ffffffffc0203794:	4585                	li	a1,1
ffffffffc0203796:	9526                	add	a0,a0,s1
ffffffffc0203798:	00e595bb          	sllw	a1,a1,a4
ffffffffc020379c:	f22fd0ef          	jal	ra,ffffffffc0200ebe <free_pages>
				slob_free(bb, sizeof(bigblock_t));
ffffffffc02037a0:	8522                	mv	a0,s0
}
ffffffffc02037a2:	6442                	ld	s0,16(sp)
ffffffffc02037a4:	60e2                	ld	ra,24(sp)
ffffffffc02037a6:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc02037a8:	45e1                	li	a1,24
}
ffffffffc02037aa:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc02037ac:	bf7ff06f          	j	ffffffffc02033a2 <slob_free>
        intr_disable();
ffffffffc02037b0:	e81fc0ef          	jal	ra,ffffffffc0200630 <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc02037b4:	000a9797          	auipc	a5,0xa9
ffffffffc02037b8:	0c478793          	addi	a5,a5,196 # ffffffffc02ac878 <bigblocks>
ffffffffc02037bc:	6394                	ld	a3,0(a5)
ffffffffc02037be:	c699                	beqz	a3,ffffffffc02037cc <kfree+0xce>
			if (bb->pages == block) {
ffffffffc02037c0:	669c                	ld	a5,8(a3)
ffffffffc02037c2:	6a80                	ld	s0,16(a3)
ffffffffc02037c4:	00f48763          	beq	s1,a5,ffffffffc02037d2 <kfree+0xd4>
        return 1;
ffffffffc02037c8:	4605                	li	a2,1
ffffffffc02037ca:	b795                	j	ffffffffc020372e <kfree+0x30>
        intr_enable();
ffffffffc02037cc:	e5ffc0ef          	jal	ra,ffffffffc020062a <intr_enable>
ffffffffc02037d0:	bf85                	j	ffffffffc0203740 <kfree+0x42>
				*last = bb->next;
ffffffffc02037d2:	000a9797          	auipc	a5,0xa9
ffffffffc02037d6:	0a87b323          	sd	s0,166(a5) # ffffffffc02ac878 <bigblocks>
ffffffffc02037da:	8436                	mv	s0,a3
ffffffffc02037dc:	e4ffc0ef          	jal	ra,ffffffffc020062a <intr_enable>
ffffffffc02037e0:	bf9d                	j	ffffffffc0203756 <kfree+0x58>
ffffffffc02037e2:	8082                	ret
ffffffffc02037e4:	000a9797          	auipc	a5,0xa9
ffffffffc02037e8:	0887ba23          	sd	s0,148(a5) # ffffffffc02ac878 <bigblocks>
ffffffffc02037ec:	8436                	mv	s0,a3
ffffffffc02037ee:	b7a5                	j	ffffffffc0203756 <kfree+0x58>
    return pa2page(PADDR(kva));
ffffffffc02037f0:	86a6                	mv	a3,s1
ffffffffc02037f2:	00003617          	auipc	a2,0x3
ffffffffc02037f6:	e4660613          	addi	a2,a2,-442 # ffffffffc0206638 <commands+0x910>
ffffffffc02037fa:	06e00593          	li	a1,110
ffffffffc02037fe:	00003517          	auipc	a0,0x3
ffffffffc0203802:	dba50513          	addi	a0,a0,-582 # ffffffffc02065b8 <commands+0x890>
ffffffffc0203806:	a0ffc0ef          	jal	ra,ffffffffc0200214 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020380a:	00003617          	auipc	a2,0x3
ffffffffc020380e:	d8e60613          	addi	a2,a2,-626 # ffffffffc0206598 <commands+0x870>
ffffffffc0203812:	06200593          	li	a1,98
ffffffffc0203816:	00003517          	auipc	a0,0x3
ffffffffc020381a:	da250513          	addi	a0,a0,-606 # ffffffffc02065b8 <commands+0x890>
ffffffffc020381e:	9f7fc0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0203822 <_fifo_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc0203822:	000a9797          	auipc	a5,0xa9
ffffffffc0203826:	17678793          	addi	a5,a5,374 # ffffffffc02ac998 <pra_list_head>
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
ffffffffc020382a:	f51c                	sd	a5,40(a0)
ffffffffc020382c:	e79c                	sd	a5,8(a5)
ffffffffc020382e:	e39c                	sd	a5,0(a5)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc0203830:	4501                	li	a0,0
ffffffffc0203832:	8082                	ret

ffffffffc0203834 <_fifo_init>:

static int
_fifo_init(void)
{
    return 0;
}
ffffffffc0203834:	4501                	li	a0,0
ffffffffc0203836:	8082                	ret

ffffffffc0203838 <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc0203838:	4501                	li	a0,0
ffffffffc020383a:	8082                	ret

ffffffffc020383c <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc020383c:	4501                	li	a0,0
ffffffffc020383e:	8082                	ret

ffffffffc0203840 <_fifo_check_swap>:
_fifo_check_swap(void) {
ffffffffc0203840:	711d                	addi	sp,sp,-96
ffffffffc0203842:	fc4e                	sd	s3,56(sp)
ffffffffc0203844:	f852                	sd	s4,48(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203846:	00004517          	auipc	a0,0x4
ffffffffc020384a:	ac250513          	addi	a0,a0,-1342 # ffffffffc0207308 <commands+0x15e0>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc020384e:	698d                	lui	s3,0x3
ffffffffc0203850:	4a31                	li	s4,12
_fifo_check_swap(void) {
ffffffffc0203852:	e8a2                	sd	s0,80(sp)
ffffffffc0203854:	e4a6                	sd	s1,72(sp)
ffffffffc0203856:	ec86                	sd	ra,88(sp)
ffffffffc0203858:	e0ca                	sd	s2,64(sp)
ffffffffc020385a:	f456                	sd	s5,40(sp)
ffffffffc020385c:	f05a                	sd	s6,32(sp)
ffffffffc020385e:	ec5e                	sd	s7,24(sp)
ffffffffc0203860:	e862                	sd	s8,16(sp)
ffffffffc0203862:	e466                	sd	s9,8(sp)
    assert(pgfault_num==4);
ffffffffc0203864:	000a9417          	auipc	s0,0xa9
ffffffffc0203868:	ffc40413          	addi	s0,s0,-4 # ffffffffc02ac860 <pgfault_num>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc020386c:	865fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203870:	01498023          	sb	s4,0(s3) # 3000 <_binary_obj___user_faultread_out_size-0x65c8>
    assert(pgfault_num==4);
ffffffffc0203874:	4004                	lw	s1,0(s0)
ffffffffc0203876:	4791                	li	a5,4
ffffffffc0203878:	2481                	sext.w	s1,s1
ffffffffc020387a:	14f49963          	bne	s1,a5,ffffffffc02039cc <_fifo_check_swap+0x18c>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc020387e:	00004517          	auipc	a0,0x4
ffffffffc0203882:	aca50513          	addi	a0,a0,-1334 # ffffffffc0207348 <commands+0x1620>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203886:	6a85                	lui	s5,0x1
ffffffffc0203888:	4b29                	li	s6,10
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc020388a:	847fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc020388e:	016a8023          	sb	s6,0(s5) # 1000 <_binary_obj___user_faultread_out_size-0x85c8>
    assert(pgfault_num==4);
ffffffffc0203892:	00042903          	lw	s2,0(s0)
ffffffffc0203896:	2901                	sext.w	s2,s2
ffffffffc0203898:	2a991a63          	bne	s2,s1,ffffffffc0203b4c <_fifo_check_swap+0x30c>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc020389c:	00004517          	auipc	a0,0x4
ffffffffc02038a0:	ad450513          	addi	a0,a0,-1324 # ffffffffc0207370 <commands+0x1648>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc02038a4:	6b91                	lui	s7,0x4
ffffffffc02038a6:	4c35                	li	s8,13
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc02038a8:	829fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc02038ac:	018b8023          	sb	s8,0(s7) # 4000 <_binary_obj___user_faultread_out_size-0x55c8>
    assert(pgfault_num==4);
ffffffffc02038b0:	4004                	lw	s1,0(s0)
ffffffffc02038b2:	2481                	sext.w	s1,s1
ffffffffc02038b4:	27249c63          	bne	s1,s2,ffffffffc0203b2c <_fifo_check_swap+0x2ec>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc02038b8:	00004517          	auipc	a0,0x4
ffffffffc02038bc:	ae050513          	addi	a0,a0,-1312 # ffffffffc0207398 <commands+0x1670>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc02038c0:	6909                	lui	s2,0x2
ffffffffc02038c2:	4cad                	li	s9,11
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc02038c4:	80dfc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc02038c8:	01990023          	sb	s9,0(s2) # 2000 <_binary_obj___user_faultread_out_size-0x75c8>
    assert(pgfault_num==4);
ffffffffc02038cc:	401c                	lw	a5,0(s0)
ffffffffc02038ce:	2781                	sext.w	a5,a5
ffffffffc02038d0:	22979e63          	bne	a5,s1,ffffffffc0203b0c <_fifo_check_swap+0x2cc>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc02038d4:	00004517          	auipc	a0,0x4
ffffffffc02038d8:	aec50513          	addi	a0,a0,-1300 # ffffffffc02073c0 <commands+0x1698>
ffffffffc02038dc:	ff4fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc02038e0:	6795                	lui	a5,0x5
ffffffffc02038e2:	4739                	li	a4,14
ffffffffc02038e4:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x45c8>
    assert(pgfault_num==5);
ffffffffc02038e8:	4004                	lw	s1,0(s0)
ffffffffc02038ea:	4795                	li	a5,5
ffffffffc02038ec:	2481                	sext.w	s1,s1
ffffffffc02038ee:	1ef49f63          	bne	s1,a5,ffffffffc0203aec <_fifo_check_swap+0x2ac>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc02038f2:	00004517          	auipc	a0,0x4
ffffffffc02038f6:	aa650513          	addi	a0,a0,-1370 # ffffffffc0207398 <commands+0x1670>
ffffffffc02038fa:	fd6fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc02038fe:	01990023          	sb	s9,0(s2)
    assert(pgfault_num==5);
ffffffffc0203902:	401c                	lw	a5,0(s0)
ffffffffc0203904:	2781                	sext.w	a5,a5
ffffffffc0203906:	1c979363          	bne	a5,s1,ffffffffc0203acc <_fifo_check_swap+0x28c>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc020390a:	00004517          	auipc	a0,0x4
ffffffffc020390e:	a3e50513          	addi	a0,a0,-1474 # ffffffffc0207348 <commands+0x1620>
ffffffffc0203912:	fbefc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203916:	016a8023          	sb	s6,0(s5)
    assert(pgfault_num==6);
ffffffffc020391a:	401c                	lw	a5,0(s0)
ffffffffc020391c:	4719                	li	a4,6
ffffffffc020391e:	2781                	sext.w	a5,a5
ffffffffc0203920:	18e79663          	bne	a5,a4,ffffffffc0203aac <_fifo_check_swap+0x26c>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203924:	00004517          	auipc	a0,0x4
ffffffffc0203928:	a7450513          	addi	a0,a0,-1420 # ffffffffc0207398 <commands+0x1670>
ffffffffc020392c:	fa4fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203930:	01990023          	sb	s9,0(s2)
    assert(pgfault_num==7);
ffffffffc0203934:	401c                	lw	a5,0(s0)
ffffffffc0203936:	471d                	li	a4,7
ffffffffc0203938:	2781                	sext.w	a5,a5
ffffffffc020393a:	14e79963          	bne	a5,a4,ffffffffc0203a8c <_fifo_check_swap+0x24c>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc020393e:	00004517          	auipc	a0,0x4
ffffffffc0203942:	9ca50513          	addi	a0,a0,-1590 # ffffffffc0207308 <commands+0x15e0>
ffffffffc0203946:	f8afc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc020394a:	01498023          	sb	s4,0(s3)
    assert(pgfault_num==8);
ffffffffc020394e:	401c                	lw	a5,0(s0)
ffffffffc0203950:	4721                	li	a4,8
ffffffffc0203952:	2781                	sext.w	a5,a5
ffffffffc0203954:	10e79c63          	bne	a5,a4,ffffffffc0203a6c <_fifo_check_swap+0x22c>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203958:	00004517          	auipc	a0,0x4
ffffffffc020395c:	a1850513          	addi	a0,a0,-1512 # ffffffffc0207370 <commands+0x1648>
ffffffffc0203960:	f70fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203964:	018b8023          	sb	s8,0(s7)
    assert(pgfault_num==9);
ffffffffc0203968:	401c                	lw	a5,0(s0)
ffffffffc020396a:	4725                	li	a4,9
ffffffffc020396c:	2781                	sext.w	a5,a5
ffffffffc020396e:	0ce79f63          	bne	a5,a4,ffffffffc0203a4c <_fifo_check_swap+0x20c>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0203972:	00004517          	auipc	a0,0x4
ffffffffc0203976:	a4e50513          	addi	a0,a0,-1458 # ffffffffc02073c0 <commands+0x1698>
ffffffffc020397a:	f56fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc020397e:	6795                	lui	a5,0x5
ffffffffc0203980:	4739                	li	a4,14
ffffffffc0203982:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x45c8>
    assert(pgfault_num==10);
ffffffffc0203986:	4004                	lw	s1,0(s0)
ffffffffc0203988:	47a9                	li	a5,10
ffffffffc020398a:	2481                	sext.w	s1,s1
ffffffffc020398c:	0af49063          	bne	s1,a5,ffffffffc0203a2c <_fifo_check_swap+0x1ec>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203990:	00004517          	auipc	a0,0x4
ffffffffc0203994:	9b850513          	addi	a0,a0,-1608 # ffffffffc0207348 <commands+0x1620>
ffffffffc0203998:	f38fc0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc020399c:	6785                	lui	a5,0x1
ffffffffc020399e:	0007c783          	lbu	a5,0(a5) # 1000 <_binary_obj___user_faultread_out_size-0x85c8>
ffffffffc02039a2:	06979563          	bne	a5,s1,ffffffffc0203a0c <_fifo_check_swap+0x1cc>
    assert(pgfault_num==11);
ffffffffc02039a6:	401c                	lw	a5,0(s0)
ffffffffc02039a8:	472d                	li	a4,11
ffffffffc02039aa:	2781                	sext.w	a5,a5
ffffffffc02039ac:	04e79063          	bne	a5,a4,ffffffffc02039ec <_fifo_check_swap+0x1ac>
}
ffffffffc02039b0:	60e6                	ld	ra,88(sp)
ffffffffc02039b2:	6446                	ld	s0,80(sp)
ffffffffc02039b4:	64a6                	ld	s1,72(sp)
ffffffffc02039b6:	6906                	ld	s2,64(sp)
ffffffffc02039b8:	79e2                	ld	s3,56(sp)
ffffffffc02039ba:	7a42                	ld	s4,48(sp)
ffffffffc02039bc:	7aa2                	ld	s5,40(sp)
ffffffffc02039be:	7b02                	ld	s6,32(sp)
ffffffffc02039c0:	6be2                	ld	s7,24(sp)
ffffffffc02039c2:	6c42                	ld	s8,16(sp)
ffffffffc02039c4:	6ca2                	ld	s9,8(sp)
ffffffffc02039c6:	4501                	li	a0,0
ffffffffc02039c8:	6125                	addi	sp,sp,96
ffffffffc02039ca:	8082                	ret
    assert(pgfault_num==4);
ffffffffc02039cc:	00003697          	auipc	a3,0x3
ffffffffc02039d0:	75c68693          	addi	a3,a3,1884 # ffffffffc0207128 <commands+0x1400>
ffffffffc02039d4:	00002617          	auipc	a2,0x2
ffffffffc02039d8:	7d460613          	addi	a2,a2,2004 # ffffffffc02061a8 <commands+0x480>
ffffffffc02039dc:	05100593          	li	a1,81
ffffffffc02039e0:	00004517          	auipc	a0,0x4
ffffffffc02039e4:	95050513          	addi	a0,a0,-1712 # ffffffffc0207330 <commands+0x1608>
ffffffffc02039e8:	82dfc0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(pgfault_num==11);
ffffffffc02039ec:	00004697          	auipc	a3,0x4
ffffffffc02039f0:	a8468693          	addi	a3,a3,-1404 # ffffffffc0207470 <commands+0x1748>
ffffffffc02039f4:	00002617          	auipc	a2,0x2
ffffffffc02039f8:	7b460613          	addi	a2,a2,1972 # ffffffffc02061a8 <commands+0x480>
ffffffffc02039fc:	07300593          	li	a1,115
ffffffffc0203a00:	00004517          	auipc	a0,0x4
ffffffffc0203a04:	93050513          	addi	a0,a0,-1744 # ffffffffc0207330 <commands+0x1608>
ffffffffc0203a08:	80dfc0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203a0c:	00004697          	auipc	a3,0x4
ffffffffc0203a10:	a3c68693          	addi	a3,a3,-1476 # ffffffffc0207448 <commands+0x1720>
ffffffffc0203a14:	00002617          	auipc	a2,0x2
ffffffffc0203a18:	79460613          	addi	a2,a2,1940 # ffffffffc02061a8 <commands+0x480>
ffffffffc0203a1c:	07100593          	li	a1,113
ffffffffc0203a20:	00004517          	auipc	a0,0x4
ffffffffc0203a24:	91050513          	addi	a0,a0,-1776 # ffffffffc0207330 <commands+0x1608>
ffffffffc0203a28:	fecfc0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(pgfault_num==10);
ffffffffc0203a2c:	00004697          	auipc	a3,0x4
ffffffffc0203a30:	a0c68693          	addi	a3,a3,-1524 # ffffffffc0207438 <commands+0x1710>
ffffffffc0203a34:	00002617          	auipc	a2,0x2
ffffffffc0203a38:	77460613          	addi	a2,a2,1908 # ffffffffc02061a8 <commands+0x480>
ffffffffc0203a3c:	06f00593          	li	a1,111
ffffffffc0203a40:	00004517          	auipc	a0,0x4
ffffffffc0203a44:	8f050513          	addi	a0,a0,-1808 # ffffffffc0207330 <commands+0x1608>
ffffffffc0203a48:	fccfc0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(pgfault_num==9);
ffffffffc0203a4c:	00004697          	auipc	a3,0x4
ffffffffc0203a50:	9dc68693          	addi	a3,a3,-1572 # ffffffffc0207428 <commands+0x1700>
ffffffffc0203a54:	00002617          	auipc	a2,0x2
ffffffffc0203a58:	75460613          	addi	a2,a2,1876 # ffffffffc02061a8 <commands+0x480>
ffffffffc0203a5c:	06c00593          	li	a1,108
ffffffffc0203a60:	00004517          	auipc	a0,0x4
ffffffffc0203a64:	8d050513          	addi	a0,a0,-1840 # ffffffffc0207330 <commands+0x1608>
ffffffffc0203a68:	facfc0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(pgfault_num==8);
ffffffffc0203a6c:	00004697          	auipc	a3,0x4
ffffffffc0203a70:	9ac68693          	addi	a3,a3,-1620 # ffffffffc0207418 <commands+0x16f0>
ffffffffc0203a74:	00002617          	auipc	a2,0x2
ffffffffc0203a78:	73460613          	addi	a2,a2,1844 # ffffffffc02061a8 <commands+0x480>
ffffffffc0203a7c:	06900593          	li	a1,105
ffffffffc0203a80:	00004517          	auipc	a0,0x4
ffffffffc0203a84:	8b050513          	addi	a0,a0,-1872 # ffffffffc0207330 <commands+0x1608>
ffffffffc0203a88:	f8cfc0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(pgfault_num==7);
ffffffffc0203a8c:	00004697          	auipc	a3,0x4
ffffffffc0203a90:	97c68693          	addi	a3,a3,-1668 # ffffffffc0207408 <commands+0x16e0>
ffffffffc0203a94:	00002617          	auipc	a2,0x2
ffffffffc0203a98:	71460613          	addi	a2,a2,1812 # ffffffffc02061a8 <commands+0x480>
ffffffffc0203a9c:	06600593          	li	a1,102
ffffffffc0203aa0:	00004517          	auipc	a0,0x4
ffffffffc0203aa4:	89050513          	addi	a0,a0,-1904 # ffffffffc0207330 <commands+0x1608>
ffffffffc0203aa8:	f6cfc0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(pgfault_num==6);
ffffffffc0203aac:	00004697          	auipc	a3,0x4
ffffffffc0203ab0:	94c68693          	addi	a3,a3,-1716 # ffffffffc02073f8 <commands+0x16d0>
ffffffffc0203ab4:	00002617          	auipc	a2,0x2
ffffffffc0203ab8:	6f460613          	addi	a2,a2,1780 # ffffffffc02061a8 <commands+0x480>
ffffffffc0203abc:	06300593          	li	a1,99
ffffffffc0203ac0:	00004517          	auipc	a0,0x4
ffffffffc0203ac4:	87050513          	addi	a0,a0,-1936 # ffffffffc0207330 <commands+0x1608>
ffffffffc0203ac8:	f4cfc0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(pgfault_num==5);
ffffffffc0203acc:	00004697          	auipc	a3,0x4
ffffffffc0203ad0:	91c68693          	addi	a3,a3,-1764 # ffffffffc02073e8 <commands+0x16c0>
ffffffffc0203ad4:	00002617          	auipc	a2,0x2
ffffffffc0203ad8:	6d460613          	addi	a2,a2,1748 # ffffffffc02061a8 <commands+0x480>
ffffffffc0203adc:	06000593          	li	a1,96
ffffffffc0203ae0:	00004517          	auipc	a0,0x4
ffffffffc0203ae4:	85050513          	addi	a0,a0,-1968 # ffffffffc0207330 <commands+0x1608>
ffffffffc0203ae8:	f2cfc0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(pgfault_num==5);
ffffffffc0203aec:	00004697          	auipc	a3,0x4
ffffffffc0203af0:	8fc68693          	addi	a3,a3,-1796 # ffffffffc02073e8 <commands+0x16c0>
ffffffffc0203af4:	00002617          	auipc	a2,0x2
ffffffffc0203af8:	6b460613          	addi	a2,a2,1716 # ffffffffc02061a8 <commands+0x480>
ffffffffc0203afc:	05d00593          	li	a1,93
ffffffffc0203b00:	00004517          	auipc	a0,0x4
ffffffffc0203b04:	83050513          	addi	a0,a0,-2000 # ffffffffc0207330 <commands+0x1608>
ffffffffc0203b08:	f0cfc0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(pgfault_num==4);
ffffffffc0203b0c:	00003697          	auipc	a3,0x3
ffffffffc0203b10:	61c68693          	addi	a3,a3,1564 # ffffffffc0207128 <commands+0x1400>
ffffffffc0203b14:	00002617          	auipc	a2,0x2
ffffffffc0203b18:	69460613          	addi	a2,a2,1684 # ffffffffc02061a8 <commands+0x480>
ffffffffc0203b1c:	05a00593          	li	a1,90
ffffffffc0203b20:	00004517          	auipc	a0,0x4
ffffffffc0203b24:	81050513          	addi	a0,a0,-2032 # ffffffffc0207330 <commands+0x1608>
ffffffffc0203b28:	eecfc0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(pgfault_num==4);
ffffffffc0203b2c:	00003697          	auipc	a3,0x3
ffffffffc0203b30:	5fc68693          	addi	a3,a3,1532 # ffffffffc0207128 <commands+0x1400>
ffffffffc0203b34:	00002617          	auipc	a2,0x2
ffffffffc0203b38:	67460613          	addi	a2,a2,1652 # ffffffffc02061a8 <commands+0x480>
ffffffffc0203b3c:	05700593          	li	a1,87
ffffffffc0203b40:	00003517          	auipc	a0,0x3
ffffffffc0203b44:	7f050513          	addi	a0,a0,2032 # ffffffffc0207330 <commands+0x1608>
ffffffffc0203b48:	eccfc0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(pgfault_num==4);
ffffffffc0203b4c:	00003697          	auipc	a3,0x3
ffffffffc0203b50:	5dc68693          	addi	a3,a3,1500 # ffffffffc0207128 <commands+0x1400>
ffffffffc0203b54:	00002617          	auipc	a2,0x2
ffffffffc0203b58:	65460613          	addi	a2,a2,1620 # ffffffffc02061a8 <commands+0x480>
ffffffffc0203b5c:	05400593          	li	a1,84
ffffffffc0203b60:	00003517          	auipc	a0,0x3
ffffffffc0203b64:	7d050513          	addi	a0,a0,2000 # ffffffffc0207330 <commands+0x1608>
ffffffffc0203b68:	eacfc0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0203b6c <_fifo_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0203b6c:	751c                	ld	a5,40(a0)
{
ffffffffc0203b6e:	1141                	addi	sp,sp,-16
ffffffffc0203b70:	e406                	sd	ra,8(sp)
         assert(head != NULL);
ffffffffc0203b72:	cf91                	beqz	a5,ffffffffc0203b8e <_fifo_swap_out_victim+0x22>
     assert(in_tick==0);
ffffffffc0203b74:	ee0d                	bnez	a2,ffffffffc0203bae <_fifo_swap_out_victim+0x42>
    return listelm->next;
ffffffffc0203b76:	679c                	ld	a5,8(a5)
}
ffffffffc0203b78:	60a2                	ld	ra,8(sp)
ffffffffc0203b7a:	4501                	li	a0,0
    __list_del(listelm->prev, listelm->next);
ffffffffc0203b7c:	6394                	ld	a3,0(a5)
ffffffffc0203b7e:	6798                	ld	a4,8(a5)
    *ptr_page = le2page(entry, pra_page_link);
ffffffffc0203b80:	fd878793          	addi	a5,a5,-40
    prev->next = next;
ffffffffc0203b84:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc0203b86:	e314                	sd	a3,0(a4)
ffffffffc0203b88:	e19c                	sd	a5,0(a1)
}
ffffffffc0203b8a:	0141                	addi	sp,sp,16
ffffffffc0203b8c:	8082                	ret
         assert(head != NULL);
ffffffffc0203b8e:	00004697          	auipc	a3,0x4
ffffffffc0203b92:	91268693          	addi	a3,a3,-1774 # ffffffffc02074a0 <commands+0x1778>
ffffffffc0203b96:	00002617          	auipc	a2,0x2
ffffffffc0203b9a:	61260613          	addi	a2,a2,1554 # ffffffffc02061a8 <commands+0x480>
ffffffffc0203b9e:	04100593          	li	a1,65
ffffffffc0203ba2:	00003517          	auipc	a0,0x3
ffffffffc0203ba6:	78e50513          	addi	a0,a0,1934 # ffffffffc0207330 <commands+0x1608>
ffffffffc0203baa:	e6afc0ef          	jal	ra,ffffffffc0200214 <__panic>
     assert(in_tick==0);
ffffffffc0203bae:	00004697          	auipc	a3,0x4
ffffffffc0203bb2:	90268693          	addi	a3,a3,-1790 # ffffffffc02074b0 <commands+0x1788>
ffffffffc0203bb6:	00002617          	auipc	a2,0x2
ffffffffc0203bba:	5f260613          	addi	a2,a2,1522 # ffffffffc02061a8 <commands+0x480>
ffffffffc0203bbe:	04200593          	li	a1,66
ffffffffc0203bc2:	00003517          	auipc	a0,0x3
ffffffffc0203bc6:	76e50513          	addi	a0,a0,1902 # ffffffffc0207330 <commands+0x1608>
ffffffffc0203bca:	e4afc0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0203bce <_fifo_map_swappable>:
    list_entry_t *entry=&(page->pra_page_link);
ffffffffc0203bce:	02860713          	addi	a4,a2,40
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0203bd2:	751c                	ld	a5,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc0203bd4:	cb09                	beqz	a4,ffffffffc0203be6 <_fifo_map_swappable+0x18>
ffffffffc0203bd6:	cb81                	beqz	a5,ffffffffc0203be6 <_fifo_map_swappable+0x18>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0203bd8:	6394                	ld	a3,0(a5)
    prev->next = next->prev = elm;
ffffffffc0203bda:	e398                	sd	a4,0(a5)
}
ffffffffc0203bdc:	4501                	li	a0,0
ffffffffc0203bde:	e698                	sd	a4,8(a3)
    elm->next = next;
ffffffffc0203be0:	fa1c                	sd	a5,48(a2)
    elm->prev = prev;
ffffffffc0203be2:	f614                	sd	a3,40(a2)
ffffffffc0203be4:	8082                	ret
{
ffffffffc0203be6:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc0203be8:	00004697          	auipc	a3,0x4
ffffffffc0203bec:	89868693          	addi	a3,a3,-1896 # ffffffffc0207480 <commands+0x1758>
ffffffffc0203bf0:	00002617          	auipc	a2,0x2
ffffffffc0203bf4:	5b860613          	addi	a2,a2,1464 # ffffffffc02061a8 <commands+0x480>
ffffffffc0203bf8:	03200593          	li	a1,50
ffffffffc0203bfc:	00003517          	auipc	a0,0x3
ffffffffc0203c00:	73450513          	addi	a0,a0,1844 # ffffffffc0207330 <commands+0x1608>
{
ffffffffc0203c04:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc0203c06:	e0efc0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0203c0a <default_init>:
    elm->prev = elm->next = elm;
ffffffffc0203c0a:	000a9797          	auipc	a5,0xa9
ffffffffc0203c0e:	d9e78793          	addi	a5,a5,-610 # ffffffffc02ac9a8 <free_area>
ffffffffc0203c12:	e79c                	sd	a5,8(a5)
ffffffffc0203c14:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0203c16:	0007a823          	sw	zero,16(a5)
}
ffffffffc0203c1a:	8082                	ret

ffffffffc0203c1c <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0203c1c:	000a9517          	auipc	a0,0xa9
ffffffffc0203c20:	d9c56503          	lwu	a0,-612(a0) # ffffffffc02ac9b8 <free_area+0x10>
ffffffffc0203c24:	8082                	ret

ffffffffc0203c26 <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0203c26:	715d                	addi	sp,sp,-80
ffffffffc0203c28:	f84a                	sd	s2,48(sp)
    return listelm->next;
ffffffffc0203c2a:	000a9917          	auipc	s2,0xa9
ffffffffc0203c2e:	d7e90913          	addi	s2,s2,-642 # ffffffffc02ac9a8 <free_area>
ffffffffc0203c32:	00893783          	ld	a5,8(s2)
ffffffffc0203c36:	e486                	sd	ra,72(sp)
ffffffffc0203c38:	e0a2                	sd	s0,64(sp)
ffffffffc0203c3a:	fc26                	sd	s1,56(sp)
ffffffffc0203c3c:	f44e                	sd	s3,40(sp)
ffffffffc0203c3e:	f052                	sd	s4,32(sp)
ffffffffc0203c40:	ec56                	sd	s5,24(sp)
ffffffffc0203c42:	e85a                	sd	s6,16(sp)
ffffffffc0203c44:	e45e                	sd	s7,8(sp)
ffffffffc0203c46:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0203c48:	31278463          	beq	a5,s2,ffffffffc0203f50 <default_check+0x32a>
ffffffffc0203c4c:	ff07b703          	ld	a4,-16(a5)
ffffffffc0203c50:	8305                	srli	a4,a4,0x1
ffffffffc0203c52:	8b05                	andi	a4,a4,1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0203c54:	30070263          	beqz	a4,ffffffffc0203f58 <default_check+0x332>
    int count = 0, total = 0;
ffffffffc0203c58:	4401                	li	s0,0
ffffffffc0203c5a:	4481                	li	s1,0
ffffffffc0203c5c:	a031                	j	ffffffffc0203c68 <default_check+0x42>
ffffffffc0203c5e:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc0203c62:	8b09                	andi	a4,a4,2
ffffffffc0203c64:	2e070a63          	beqz	a4,ffffffffc0203f58 <default_check+0x332>
        count ++, total += p->property;
ffffffffc0203c68:	ff87a703          	lw	a4,-8(a5)
ffffffffc0203c6c:	679c                	ld	a5,8(a5)
ffffffffc0203c6e:	2485                	addiw	s1,s1,1
ffffffffc0203c70:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0203c72:	ff2796e3          	bne	a5,s2,ffffffffc0203c5e <default_check+0x38>
ffffffffc0203c76:	89a2                	mv	s3,s0
    }
    assert(total == nr_free_pages());
ffffffffc0203c78:	a8cfd0ef          	jal	ra,ffffffffc0200f04 <nr_free_pages>
ffffffffc0203c7c:	73351e63          	bne	a0,s3,ffffffffc02043b8 <default_check+0x792>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0203c80:	4505                	li	a0,1
ffffffffc0203c82:	9b4fd0ef          	jal	ra,ffffffffc0200e36 <alloc_pages>
ffffffffc0203c86:	8a2a                	mv	s4,a0
ffffffffc0203c88:	46050863          	beqz	a0,ffffffffc02040f8 <default_check+0x4d2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0203c8c:	4505                	li	a0,1
ffffffffc0203c8e:	9a8fd0ef          	jal	ra,ffffffffc0200e36 <alloc_pages>
ffffffffc0203c92:	89aa                	mv	s3,a0
ffffffffc0203c94:	74050263          	beqz	a0,ffffffffc02043d8 <default_check+0x7b2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0203c98:	4505                	li	a0,1
ffffffffc0203c9a:	99cfd0ef          	jal	ra,ffffffffc0200e36 <alloc_pages>
ffffffffc0203c9e:	8aaa                	mv	s5,a0
ffffffffc0203ca0:	4c050c63          	beqz	a0,ffffffffc0204178 <default_check+0x552>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0203ca4:	2d3a0a63          	beq	s4,s3,ffffffffc0203f78 <default_check+0x352>
ffffffffc0203ca8:	2caa0863          	beq	s4,a0,ffffffffc0203f78 <default_check+0x352>
ffffffffc0203cac:	2ca98663          	beq	s3,a0,ffffffffc0203f78 <default_check+0x352>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0203cb0:	000a2783          	lw	a5,0(s4)
ffffffffc0203cb4:	2e079263          	bnez	a5,ffffffffc0203f98 <default_check+0x372>
ffffffffc0203cb8:	0009a783          	lw	a5,0(s3)
ffffffffc0203cbc:	2c079e63          	bnez	a5,ffffffffc0203f98 <default_check+0x372>
ffffffffc0203cc0:	411c                	lw	a5,0(a0)
ffffffffc0203cc2:	2c079b63          	bnez	a5,ffffffffc0203f98 <default_check+0x372>
    return page - pages + nbase;
ffffffffc0203cc6:	000a9797          	auipc	a5,0xa9
ffffffffc0203cca:	bfa78793          	addi	a5,a5,-1030 # ffffffffc02ac8c0 <pages>
ffffffffc0203cce:	639c                	ld	a5,0(a5)
ffffffffc0203cd0:	00004717          	auipc	a4,0x4
ffffffffc0203cd4:	4d870713          	addi	a4,a4,1240 # ffffffffc02081a8 <nbase>
ffffffffc0203cd8:	6310                	ld	a2,0(a4)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0203cda:	000a9717          	auipc	a4,0xa9
ffffffffc0203cde:	b7e70713          	addi	a4,a4,-1154 # ffffffffc02ac858 <npage>
ffffffffc0203ce2:	6314                	ld	a3,0(a4)
ffffffffc0203ce4:	40fa0733          	sub	a4,s4,a5
ffffffffc0203ce8:	8719                	srai	a4,a4,0x6
ffffffffc0203cea:	9732                	add	a4,a4,a2
ffffffffc0203cec:	06b2                	slli	a3,a3,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203cee:	0732                	slli	a4,a4,0xc
ffffffffc0203cf0:	2cd77463          	bgeu	a4,a3,ffffffffc0203fb8 <default_check+0x392>
    return page - pages + nbase;
ffffffffc0203cf4:	40f98733          	sub	a4,s3,a5
ffffffffc0203cf8:	8719                	srai	a4,a4,0x6
ffffffffc0203cfa:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0203cfc:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0203cfe:	4ed77d63          	bgeu	a4,a3,ffffffffc02041f8 <default_check+0x5d2>
    return page - pages + nbase;
ffffffffc0203d02:	40f507b3          	sub	a5,a0,a5
ffffffffc0203d06:	8799                	srai	a5,a5,0x6
ffffffffc0203d08:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0203d0a:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0203d0c:	34d7f663          	bgeu	a5,a3,ffffffffc0204058 <default_check+0x432>
    assert(alloc_page() == NULL);
ffffffffc0203d10:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0203d12:	00093c03          	ld	s8,0(s2)
ffffffffc0203d16:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc0203d1a:	01092b03          	lw	s6,16(s2)
    elm->prev = elm->next = elm;
ffffffffc0203d1e:	000a9797          	auipc	a5,0xa9
ffffffffc0203d22:	c927b923          	sd	s2,-878(a5) # ffffffffc02ac9b0 <free_area+0x8>
ffffffffc0203d26:	000a9797          	auipc	a5,0xa9
ffffffffc0203d2a:	c927b123          	sd	s2,-894(a5) # ffffffffc02ac9a8 <free_area>
    nr_free = 0;
ffffffffc0203d2e:	000a9797          	auipc	a5,0xa9
ffffffffc0203d32:	c807a523          	sw	zero,-886(a5) # ffffffffc02ac9b8 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0203d36:	900fd0ef          	jal	ra,ffffffffc0200e36 <alloc_pages>
ffffffffc0203d3a:	2e051f63          	bnez	a0,ffffffffc0204038 <default_check+0x412>
    free_page(p0);
ffffffffc0203d3e:	4585                	li	a1,1
ffffffffc0203d40:	8552                	mv	a0,s4
ffffffffc0203d42:	97cfd0ef          	jal	ra,ffffffffc0200ebe <free_pages>
    free_page(p1);
ffffffffc0203d46:	4585                	li	a1,1
ffffffffc0203d48:	854e                	mv	a0,s3
ffffffffc0203d4a:	974fd0ef          	jal	ra,ffffffffc0200ebe <free_pages>
    free_page(p2);
ffffffffc0203d4e:	4585                	li	a1,1
ffffffffc0203d50:	8556                	mv	a0,s5
ffffffffc0203d52:	96cfd0ef          	jal	ra,ffffffffc0200ebe <free_pages>
    assert(nr_free == 3);
ffffffffc0203d56:	01092703          	lw	a4,16(s2)
ffffffffc0203d5a:	478d                	li	a5,3
ffffffffc0203d5c:	2af71e63          	bne	a4,a5,ffffffffc0204018 <default_check+0x3f2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0203d60:	4505                	li	a0,1
ffffffffc0203d62:	8d4fd0ef          	jal	ra,ffffffffc0200e36 <alloc_pages>
ffffffffc0203d66:	89aa                	mv	s3,a0
ffffffffc0203d68:	28050863          	beqz	a0,ffffffffc0203ff8 <default_check+0x3d2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0203d6c:	4505                	li	a0,1
ffffffffc0203d6e:	8c8fd0ef          	jal	ra,ffffffffc0200e36 <alloc_pages>
ffffffffc0203d72:	8aaa                	mv	s5,a0
ffffffffc0203d74:	3e050263          	beqz	a0,ffffffffc0204158 <default_check+0x532>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0203d78:	4505                	li	a0,1
ffffffffc0203d7a:	8bcfd0ef          	jal	ra,ffffffffc0200e36 <alloc_pages>
ffffffffc0203d7e:	8a2a                	mv	s4,a0
ffffffffc0203d80:	3a050c63          	beqz	a0,ffffffffc0204138 <default_check+0x512>
    assert(alloc_page() == NULL);
ffffffffc0203d84:	4505                	li	a0,1
ffffffffc0203d86:	8b0fd0ef          	jal	ra,ffffffffc0200e36 <alloc_pages>
ffffffffc0203d8a:	38051763          	bnez	a0,ffffffffc0204118 <default_check+0x4f2>
    free_page(p0);
ffffffffc0203d8e:	4585                	li	a1,1
ffffffffc0203d90:	854e                	mv	a0,s3
ffffffffc0203d92:	92cfd0ef          	jal	ra,ffffffffc0200ebe <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0203d96:	00893783          	ld	a5,8(s2)
ffffffffc0203d9a:	23278f63          	beq	a5,s2,ffffffffc0203fd8 <default_check+0x3b2>
    assert((p = alloc_page()) == p0);
ffffffffc0203d9e:	4505                	li	a0,1
ffffffffc0203da0:	896fd0ef          	jal	ra,ffffffffc0200e36 <alloc_pages>
ffffffffc0203da4:	32a99a63          	bne	s3,a0,ffffffffc02040d8 <default_check+0x4b2>
    assert(alloc_page() == NULL);
ffffffffc0203da8:	4505                	li	a0,1
ffffffffc0203daa:	88cfd0ef          	jal	ra,ffffffffc0200e36 <alloc_pages>
ffffffffc0203dae:	30051563          	bnez	a0,ffffffffc02040b8 <default_check+0x492>
    assert(nr_free == 0);
ffffffffc0203db2:	01092783          	lw	a5,16(s2)
ffffffffc0203db6:	2e079163          	bnez	a5,ffffffffc0204098 <default_check+0x472>
    free_page(p);
ffffffffc0203dba:	854e                	mv	a0,s3
ffffffffc0203dbc:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0203dbe:	000a9797          	auipc	a5,0xa9
ffffffffc0203dc2:	bf87b523          	sd	s8,-1046(a5) # ffffffffc02ac9a8 <free_area>
ffffffffc0203dc6:	000a9797          	auipc	a5,0xa9
ffffffffc0203dca:	bf77b523          	sd	s7,-1046(a5) # ffffffffc02ac9b0 <free_area+0x8>
    nr_free = nr_free_store;
ffffffffc0203dce:	000a9797          	auipc	a5,0xa9
ffffffffc0203dd2:	bf67a523          	sw	s6,-1046(a5) # ffffffffc02ac9b8 <free_area+0x10>
    free_page(p);
ffffffffc0203dd6:	8e8fd0ef          	jal	ra,ffffffffc0200ebe <free_pages>
    free_page(p1);
ffffffffc0203dda:	4585                	li	a1,1
ffffffffc0203ddc:	8556                	mv	a0,s5
ffffffffc0203dde:	8e0fd0ef          	jal	ra,ffffffffc0200ebe <free_pages>
    free_page(p2);
ffffffffc0203de2:	4585                	li	a1,1
ffffffffc0203de4:	8552                	mv	a0,s4
ffffffffc0203de6:	8d8fd0ef          	jal	ra,ffffffffc0200ebe <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0203dea:	4515                	li	a0,5
ffffffffc0203dec:	84afd0ef          	jal	ra,ffffffffc0200e36 <alloc_pages>
ffffffffc0203df0:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0203df2:	28050363          	beqz	a0,ffffffffc0204078 <default_check+0x452>
ffffffffc0203df6:	651c                	ld	a5,8(a0)
ffffffffc0203df8:	8385                	srli	a5,a5,0x1
ffffffffc0203dfa:	8b85                	andi	a5,a5,1
    assert(!PageProperty(p0));
ffffffffc0203dfc:	54079e63          	bnez	a5,ffffffffc0204358 <default_check+0x732>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0203e00:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0203e02:	00093b03          	ld	s6,0(s2)
ffffffffc0203e06:	00893a83          	ld	s5,8(s2)
ffffffffc0203e0a:	000a9797          	auipc	a5,0xa9
ffffffffc0203e0e:	b927bf23          	sd	s2,-1122(a5) # ffffffffc02ac9a8 <free_area>
ffffffffc0203e12:	000a9797          	auipc	a5,0xa9
ffffffffc0203e16:	b927bf23          	sd	s2,-1122(a5) # ffffffffc02ac9b0 <free_area+0x8>
    assert(alloc_page() == NULL);
ffffffffc0203e1a:	81cfd0ef          	jal	ra,ffffffffc0200e36 <alloc_pages>
ffffffffc0203e1e:	50051d63          	bnez	a0,ffffffffc0204338 <default_check+0x712>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0203e22:	08098a13          	addi	s4,s3,128
ffffffffc0203e26:	8552                	mv	a0,s4
ffffffffc0203e28:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0203e2a:	01092b83          	lw	s7,16(s2)
    nr_free = 0;
ffffffffc0203e2e:	000a9797          	auipc	a5,0xa9
ffffffffc0203e32:	b807a523          	sw	zero,-1142(a5) # ffffffffc02ac9b8 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0203e36:	888fd0ef          	jal	ra,ffffffffc0200ebe <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0203e3a:	4511                	li	a0,4
ffffffffc0203e3c:	ffbfc0ef          	jal	ra,ffffffffc0200e36 <alloc_pages>
ffffffffc0203e40:	4c051c63          	bnez	a0,ffffffffc0204318 <default_check+0x6f2>
ffffffffc0203e44:	0889b783          	ld	a5,136(s3)
ffffffffc0203e48:	8385                	srli	a5,a5,0x1
ffffffffc0203e4a:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0203e4c:	4a078663          	beqz	a5,ffffffffc02042f8 <default_check+0x6d2>
ffffffffc0203e50:	0909a703          	lw	a4,144(s3)
ffffffffc0203e54:	478d                	li	a5,3
ffffffffc0203e56:	4af71163          	bne	a4,a5,ffffffffc02042f8 <default_check+0x6d2>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0203e5a:	450d                	li	a0,3
ffffffffc0203e5c:	fdbfc0ef          	jal	ra,ffffffffc0200e36 <alloc_pages>
ffffffffc0203e60:	8c2a                	mv	s8,a0
ffffffffc0203e62:	46050b63          	beqz	a0,ffffffffc02042d8 <default_check+0x6b2>
    assert(alloc_page() == NULL);
ffffffffc0203e66:	4505                	li	a0,1
ffffffffc0203e68:	fcffc0ef          	jal	ra,ffffffffc0200e36 <alloc_pages>
ffffffffc0203e6c:	44051663          	bnez	a0,ffffffffc02042b8 <default_check+0x692>
    assert(p0 + 2 == p1);
ffffffffc0203e70:	438a1463          	bne	s4,s8,ffffffffc0204298 <default_check+0x672>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0203e74:	4585                	li	a1,1
ffffffffc0203e76:	854e                	mv	a0,s3
ffffffffc0203e78:	846fd0ef          	jal	ra,ffffffffc0200ebe <free_pages>
    free_pages(p1, 3);
ffffffffc0203e7c:	458d                	li	a1,3
ffffffffc0203e7e:	8552                	mv	a0,s4
ffffffffc0203e80:	83efd0ef          	jal	ra,ffffffffc0200ebe <free_pages>
ffffffffc0203e84:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0203e88:	04098c13          	addi	s8,s3,64
ffffffffc0203e8c:	8385                	srli	a5,a5,0x1
ffffffffc0203e8e:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0203e90:	3e078463          	beqz	a5,ffffffffc0204278 <default_check+0x652>
ffffffffc0203e94:	0109a703          	lw	a4,16(s3)
ffffffffc0203e98:	4785                	li	a5,1
ffffffffc0203e9a:	3cf71f63          	bne	a4,a5,ffffffffc0204278 <default_check+0x652>
ffffffffc0203e9e:	008a3783          	ld	a5,8(s4)
ffffffffc0203ea2:	8385                	srli	a5,a5,0x1
ffffffffc0203ea4:	8b85                	andi	a5,a5,1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0203ea6:	3a078963          	beqz	a5,ffffffffc0204258 <default_check+0x632>
ffffffffc0203eaa:	010a2703          	lw	a4,16(s4)
ffffffffc0203eae:	478d                	li	a5,3
ffffffffc0203eb0:	3af71463          	bne	a4,a5,ffffffffc0204258 <default_check+0x632>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0203eb4:	4505                	li	a0,1
ffffffffc0203eb6:	f81fc0ef          	jal	ra,ffffffffc0200e36 <alloc_pages>
ffffffffc0203eba:	36a99f63          	bne	s3,a0,ffffffffc0204238 <default_check+0x612>
    free_page(p0);
ffffffffc0203ebe:	4585                	li	a1,1
ffffffffc0203ec0:	ffffc0ef          	jal	ra,ffffffffc0200ebe <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0203ec4:	4509                	li	a0,2
ffffffffc0203ec6:	f71fc0ef          	jal	ra,ffffffffc0200e36 <alloc_pages>
ffffffffc0203eca:	34aa1763          	bne	s4,a0,ffffffffc0204218 <default_check+0x5f2>

    free_pages(p0, 2);
ffffffffc0203ece:	4589                	li	a1,2
ffffffffc0203ed0:	feffc0ef          	jal	ra,ffffffffc0200ebe <free_pages>
    free_page(p2);
ffffffffc0203ed4:	4585                	li	a1,1
ffffffffc0203ed6:	8562                	mv	a0,s8
ffffffffc0203ed8:	fe7fc0ef          	jal	ra,ffffffffc0200ebe <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0203edc:	4515                	li	a0,5
ffffffffc0203ede:	f59fc0ef          	jal	ra,ffffffffc0200e36 <alloc_pages>
ffffffffc0203ee2:	89aa                	mv	s3,a0
ffffffffc0203ee4:	48050a63          	beqz	a0,ffffffffc0204378 <default_check+0x752>
    assert(alloc_page() == NULL);
ffffffffc0203ee8:	4505                	li	a0,1
ffffffffc0203eea:	f4dfc0ef          	jal	ra,ffffffffc0200e36 <alloc_pages>
ffffffffc0203eee:	2e051563          	bnez	a0,ffffffffc02041d8 <default_check+0x5b2>

    assert(nr_free == 0);
ffffffffc0203ef2:	01092783          	lw	a5,16(s2)
ffffffffc0203ef6:	2c079163          	bnez	a5,ffffffffc02041b8 <default_check+0x592>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0203efa:	4595                	li	a1,5
ffffffffc0203efc:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0203efe:	000a9797          	auipc	a5,0xa9
ffffffffc0203f02:	ab77ad23          	sw	s7,-1350(a5) # ffffffffc02ac9b8 <free_area+0x10>
    free_list = free_list_store;
ffffffffc0203f06:	000a9797          	auipc	a5,0xa9
ffffffffc0203f0a:	ab67b123          	sd	s6,-1374(a5) # ffffffffc02ac9a8 <free_area>
ffffffffc0203f0e:	000a9797          	auipc	a5,0xa9
ffffffffc0203f12:	ab57b123          	sd	s5,-1374(a5) # ffffffffc02ac9b0 <free_area+0x8>
    free_pages(p0, 5);
ffffffffc0203f16:	fa9fc0ef          	jal	ra,ffffffffc0200ebe <free_pages>
    return listelm->next;
ffffffffc0203f1a:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0203f1e:	01278963          	beq	a5,s2,ffffffffc0203f30 <default_check+0x30a>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0203f22:	ff87a703          	lw	a4,-8(a5)
ffffffffc0203f26:	679c                	ld	a5,8(a5)
ffffffffc0203f28:	34fd                	addiw	s1,s1,-1
ffffffffc0203f2a:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0203f2c:	ff279be3          	bne	a5,s2,ffffffffc0203f22 <default_check+0x2fc>
    }
    assert(count == 0);
ffffffffc0203f30:	26049463          	bnez	s1,ffffffffc0204198 <default_check+0x572>
    assert(total == 0);
ffffffffc0203f34:	46041263          	bnez	s0,ffffffffc0204398 <default_check+0x772>
}
ffffffffc0203f38:	60a6                	ld	ra,72(sp)
ffffffffc0203f3a:	6406                	ld	s0,64(sp)
ffffffffc0203f3c:	74e2                	ld	s1,56(sp)
ffffffffc0203f3e:	7942                	ld	s2,48(sp)
ffffffffc0203f40:	79a2                	ld	s3,40(sp)
ffffffffc0203f42:	7a02                	ld	s4,32(sp)
ffffffffc0203f44:	6ae2                	ld	s5,24(sp)
ffffffffc0203f46:	6b42                	ld	s6,16(sp)
ffffffffc0203f48:	6ba2                	ld	s7,8(sp)
ffffffffc0203f4a:	6c02                	ld	s8,0(sp)
ffffffffc0203f4c:	6161                	addi	sp,sp,80
ffffffffc0203f4e:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0203f50:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0203f52:	4401                	li	s0,0
ffffffffc0203f54:	4481                	li	s1,0
ffffffffc0203f56:	b30d                	j	ffffffffc0203c78 <default_check+0x52>
        assert(PageProperty(p));
ffffffffc0203f58:	00003697          	auipc	a3,0x3
ffffffffc0203f5c:	03068693          	addi	a3,a3,48 # ffffffffc0206f88 <commands+0x1260>
ffffffffc0203f60:	00002617          	auipc	a2,0x2
ffffffffc0203f64:	24860613          	addi	a2,a2,584 # ffffffffc02061a8 <commands+0x480>
ffffffffc0203f68:	0f000593          	li	a1,240
ffffffffc0203f6c:	00003517          	auipc	a0,0x3
ffffffffc0203f70:	56c50513          	addi	a0,a0,1388 # ffffffffc02074d8 <commands+0x17b0>
ffffffffc0203f74:	aa0fc0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0203f78:	00003697          	auipc	a3,0x3
ffffffffc0203f7c:	5d868693          	addi	a3,a3,1496 # ffffffffc0207550 <commands+0x1828>
ffffffffc0203f80:	00002617          	auipc	a2,0x2
ffffffffc0203f84:	22860613          	addi	a2,a2,552 # ffffffffc02061a8 <commands+0x480>
ffffffffc0203f88:	0bd00593          	li	a1,189
ffffffffc0203f8c:	00003517          	auipc	a0,0x3
ffffffffc0203f90:	54c50513          	addi	a0,a0,1356 # ffffffffc02074d8 <commands+0x17b0>
ffffffffc0203f94:	a80fc0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0203f98:	00003697          	auipc	a3,0x3
ffffffffc0203f9c:	5e068693          	addi	a3,a3,1504 # ffffffffc0207578 <commands+0x1850>
ffffffffc0203fa0:	00002617          	auipc	a2,0x2
ffffffffc0203fa4:	20860613          	addi	a2,a2,520 # ffffffffc02061a8 <commands+0x480>
ffffffffc0203fa8:	0be00593          	li	a1,190
ffffffffc0203fac:	00003517          	auipc	a0,0x3
ffffffffc0203fb0:	52c50513          	addi	a0,a0,1324 # ffffffffc02074d8 <commands+0x17b0>
ffffffffc0203fb4:	a60fc0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0203fb8:	00003697          	auipc	a3,0x3
ffffffffc0203fbc:	60068693          	addi	a3,a3,1536 # ffffffffc02075b8 <commands+0x1890>
ffffffffc0203fc0:	00002617          	auipc	a2,0x2
ffffffffc0203fc4:	1e860613          	addi	a2,a2,488 # ffffffffc02061a8 <commands+0x480>
ffffffffc0203fc8:	0c000593          	li	a1,192
ffffffffc0203fcc:	00003517          	auipc	a0,0x3
ffffffffc0203fd0:	50c50513          	addi	a0,a0,1292 # ffffffffc02074d8 <commands+0x17b0>
ffffffffc0203fd4:	a40fc0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0203fd8:	00003697          	auipc	a3,0x3
ffffffffc0203fdc:	66868693          	addi	a3,a3,1640 # ffffffffc0207640 <commands+0x1918>
ffffffffc0203fe0:	00002617          	auipc	a2,0x2
ffffffffc0203fe4:	1c860613          	addi	a2,a2,456 # ffffffffc02061a8 <commands+0x480>
ffffffffc0203fe8:	0d900593          	li	a1,217
ffffffffc0203fec:	00003517          	auipc	a0,0x3
ffffffffc0203ff0:	4ec50513          	addi	a0,a0,1260 # ffffffffc02074d8 <commands+0x17b0>
ffffffffc0203ff4:	a20fc0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0203ff8:	00003697          	auipc	a3,0x3
ffffffffc0203ffc:	4f868693          	addi	a3,a3,1272 # ffffffffc02074f0 <commands+0x17c8>
ffffffffc0204000:	00002617          	auipc	a2,0x2
ffffffffc0204004:	1a860613          	addi	a2,a2,424 # ffffffffc02061a8 <commands+0x480>
ffffffffc0204008:	0d200593          	li	a1,210
ffffffffc020400c:	00003517          	auipc	a0,0x3
ffffffffc0204010:	4cc50513          	addi	a0,a0,1228 # ffffffffc02074d8 <commands+0x17b0>
ffffffffc0204014:	a00fc0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(nr_free == 3);
ffffffffc0204018:	00003697          	auipc	a3,0x3
ffffffffc020401c:	61868693          	addi	a3,a3,1560 # ffffffffc0207630 <commands+0x1908>
ffffffffc0204020:	00002617          	auipc	a2,0x2
ffffffffc0204024:	18860613          	addi	a2,a2,392 # ffffffffc02061a8 <commands+0x480>
ffffffffc0204028:	0d000593          	li	a1,208
ffffffffc020402c:	00003517          	auipc	a0,0x3
ffffffffc0204030:	4ac50513          	addi	a0,a0,1196 # ffffffffc02074d8 <commands+0x17b0>
ffffffffc0204034:	9e0fc0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0204038:	00003697          	auipc	a3,0x3
ffffffffc020403c:	5e068693          	addi	a3,a3,1504 # ffffffffc0207618 <commands+0x18f0>
ffffffffc0204040:	00002617          	auipc	a2,0x2
ffffffffc0204044:	16860613          	addi	a2,a2,360 # ffffffffc02061a8 <commands+0x480>
ffffffffc0204048:	0cb00593          	li	a1,203
ffffffffc020404c:	00003517          	auipc	a0,0x3
ffffffffc0204050:	48c50513          	addi	a0,a0,1164 # ffffffffc02074d8 <commands+0x17b0>
ffffffffc0204054:	9c0fc0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0204058:	00003697          	auipc	a3,0x3
ffffffffc020405c:	5a068693          	addi	a3,a3,1440 # ffffffffc02075f8 <commands+0x18d0>
ffffffffc0204060:	00002617          	auipc	a2,0x2
ffffffffc0204064:	14860613          	addi	a2,a2,328 # ffffffffc02061a8 <commands+0x480>
ffffffffc0204068:	0c200593          	li	a1,194
ffffffffc020406c:	00003517          	auipc	a0,0x3
ffffffffc0204070:	46c50513          	addi	a0,a0,1132 # ffffffffc02074d8 <commands+0x17b0>
ffffffffc0204074:	9a0fc0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(p0 != NULL);
ffffffffc0204078:	00003697          	auipc	a3,0x3
ffffffffc020407c:	60068693          	addi	a3,a3,1536 # ffffffffc0207678 <commands+0x1950>
ffffffffc0204080:	00002617          	auipc	a2,0x2
ffffffffc0204084:	12860613          	addi	a2,a2,296 # ffffffffc02061a8 <commands+0x480>
ffffffffc0204088:	0f800593          	li	a1,248
ffffffffc020408c:	00003517          	auipc	a0,0x3
ffffffffc0204090:	44c50513          	addi	a0,a0,1100 # ffffffffc02074d8 <commands+0x17b0>
ffffffffc0204094:	980fc0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(nr_free == 0);
ffffffffc0204098:	00003697          	auipc	a3,0x3
ffffffffc020409c:	0a068693          	addi	a3,a3,160 # ffffffffc0207138 <commands+0x1410>
ffffffffc02040a0:	00002617          	auipc	a2,0x2
ffffffffc02040a4:	10860613          	addi	a2,a2,264 # ffffffffc02061a8 <commands+0x480>
ffffffffc02040a8:	0df00593          	li	a1,223
ffffffffc02040ac:	00003517          	auipc	a0,0x3
ffffffffc02040b0:	42c50513          	addi	a0,a0,1068 # ffffffffc02074d8 <commands+0x17b0>
ffffffffc02040b4:	960fc0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02040b8:	00003697          	auipc	a3,0x3
ffffffffc02040bc:	56068693          	addi	a3,a3,1376 # ffffffffc0207618 <commands+0x18f0>
ffffffffc02040c0:	00002617          	auipc	a2,0x2
ffffffffc02040c4:	0e860613          	addi	a2,a2,232 # ffffffffc02061a8 <commands+0x480>
ffffffffc02040c8:	0dd00593          	li	a1,221
ffffffffc02040cc:	00003517          	auipc	a0,0x3
ffffffffc02040d0:	40c50513          	addi	a0,a0,1036 # ffffffffc02074d8 <commands+0x17b0>
ffffffffc02040d4:	940fc0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc02040d8:	00003697          	auipc	a3,0x3
ffffffffc02040dc:	58068693          	addi	a3,a3,1408 # ffffffffc0207658 <commands+0x1930>
ffffffffc02040e0:	00002617          	auipc	a2,0x2
ffffffffc02040e4:	0c860613          	addi	a2,a2,200 # ffffffffc02061a8 <commands+0x480>
ffffffffc02040e8:	0dc00593          	li	a1,220
ffffffffc02040ec:	00003517          	auipc	a0,0x3
ffffffffc02040f0:	3ec50513          	addi	a0,a0,1004 # ffffffffc02074d8 <commands+0x17b0>
ffffffffc02040f4:	920fc0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02040f8:	00003697          	auipc	a3,0x3
ffffffffc02040fc:	3f868693          	addi	a3,a3,1016 # ffffffffc02074f0 <commands+0x17c8>
ffffffffc0204100:	00002617          	auipc	a2,0x2
ffffffffc0204104:	0a860613          	addi	a2,a2,168 # ffffffffc02061a8 <commands+0x480>
ffffffffc0204108:	0b900593          	li	a1,185
ffffffffc020410c:	00003517          	auipc	a0,0x3
ffffffffc0204110:	3cc50513          	addi	a0,a0,972 # ffffffffc02074d8 <commands+0x17b0>
ffffffffc0204114:	900fc0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0204118:	00003697          	auipc	a3,0x3
ffffffffc020411c:	50068693          	addi	a3,a3,1280 # ffffffffc0207618 <commands+0x18f0>
ffffffffc0204120:	00002617          	auipc	a2,0x2
ffffffffc0204124:	08860613          	addi	a2,a2,136 # ffffffffc02061a8 <commands+0x480>
ffffffffc0204128:	0d600593          	li	a1,214
ffffffffc020412c:	00003517          	auipc	a0,0x3
ffffffffc0204130:	3ac50513          	addi	a0,a0,940 # ffffffffc02074d8 <commands+0x17b0>
ffffffffc0204134:	8e0fc0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0204138:	00003697          	auipc	a3,0x3
ffffffffc020413c:	3f868693          	addi	a3,a3,1016 # ffffffffc0207530 <commands+0x1808>
ffffffffc0204140:	00002617          	auipc	a2,0x2
ffffffffc0204144:	06860613          	addi	a2,a2,104 # ffffffffc02061a8 <commands+0x480>
ffffffffc0204148:	0d400593          	li	a1,212
ffffffffc020414c:	00003517          	auipc	a0,0x3
ffffffffc0204150:	38c50513          	addi	a0,a0,908 # ffffffffc02074d8 <commands+0x17b0>
ffffffffc0204154:	8c0fc0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0204158:	00003697          	auipc	a3,0x3
ffffffffc020415c:	3b868693          	addi	a3,a3,952 # ffffffffc0207510 <commands+0x17e8>
ffffffffc0204160:	00002617          	auipc	a2,0x2
ffffffffc0204164:	04860613          	addi	a2,a2,72 # ffffffffc02061a8 <commands+0x480>
ffffffffc0204168:	0d300593          	li	a1,211
ffffffffc020416c:	00003517          	auipc	a0,0x3
ffffffffc0204170:	36c50513          	addi	a0,a0,876 # ffffffffc02074d8 <commands+0x17b0>
ffffffffc0204174:	8a0fc0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0204178:	00003697          	auipc	a3,0x3
ffffffffc020417c:	3b868693          	addi	a3,a3,952 # ffffffffc0207530 <commands+0x1808>
ffffffffc0204180:	00002617          	auipc	a2,0x2
ffffffffc0204184:	02860613          	addi	a2,a2,40 # ffffffffc02061a8 <commands+0x480>
ffffffffc0204188:	0bb00593          	li	a1,187
ffffffffc020418c:	00003517          	auipc	a0,0x3
ffffffffc0204190:	34c50513          	addi	a0,a0,844 # ffffffffc02074d8 <commands+0x17b0>
ffffffffc0204194:	880fc0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(count == 0);
ffffffffc0204198:	00003697          	auipc	a3,0x3
ffffffffc020419c:	63068693          	addi	a3,a3,1584 # ffffffffc02077c8 <commands+0x1aa0>
ffffffffc02041a0:	00002617          	auipc	a2,0x2
ffffffffc02041a4:	00860613          	addi	a2,a2,8 # ffffffffc02061a8 <commands+0x480>
ffffffffc02041a8:	12500593          	li	a1,293
ffffffffc02041ac:	00003517          	auipc	a0,0x3
ffffffffc02041b0:	32c50513          	addi	a0,a0,812 # ffffffffc02074d8 <commands+0x17b0>
ffffffffc02041b4:	860fc0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(nr_free == 0);
ffffffffc02041b8:	00003697          	auipc	a3,0x3
ffffffffc02041bc:	f8068693          	addi	a3,a3,-128 # ffffffffc0207138 <commands+0x1410>
ffffffffc02041c0:	00002617          	auipc	a2,0x2
ffffffffc02041c4:	fe860613          	addi	a2,a2,-24 # ffffffffc02061a8 <commands+0x480>
ffffffffc02041c8:	11a00593          	li	a1,282
ffffffffc02041cc:	00003517          	auipc	a0,0x3
ffffffffc02041d0:	30c50513          	addi	a0,a0,780 # ffffffffc02074d8 <commands+0x17b0>
ffffffffc02041d4:	840fc0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02041d8:	00003697          	auipc	a3,0x3
ffffffffc02041dc:	44068693          	addi	a3,a3,1088 # ffffffffc0207618 <commands+0x18f0>
ffffffffc02041e0:	00002617          	auipc	a2,0x2
ffffffffc02041e4:	fc860613          	addi	a2,a2,-56 # ffffffffc02061a8 <commands+0x480>
ffffffffc02041e8:	11800593          	li	a1,280
ffffffffc02041ec:	00003517          	auipc	a0,0x3
ffffffffc02041f0:	2ec50513          	addi	a0,a0,748 # ffffffffc02074d8 <commands+0x17b0>
ffffffffc02041f4:	820fc0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02041f8:	00003697          	auipc	a3,0x3
ffffffffc02041fc:	3e068693          	addi	a3,a3,992 # ffffffffc02075d8 <commands+0x18b0>
ffffffffc0204200:	00002617          	auipc	a2,0x2
ffffffffc0204204:	fa860613          	addi	a2,a2,-88 # ffffffffc02061a8 <commands+0x480>
ffffffffc0204208:	0c100593          	li	a1,193
ffffffffc020420c:	00003517          	auipc	a0,0x3
ffffffffc0204210:	2cc50513          	addi	a0,a0,716 # ffffffffc02074d8 <commands+0x17b0>
ffffffffc0204214:	800fc0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0204218:	00003697          	auipc	a3,0x3
ffffffffc020421c:	57068693          	addi	a3,a3,1392 # ffffffffc0207788 <commands+0x1a60>
ffffffffc0204220:	00002617          	auipc	a2,0x2
ffffffffc0204224:	f8860613          	addi	a2,a2,-120 # ffffffffc02061a8 <commands+0x480>
ffffffffc0204228:	11200593          	li	a1,274
ffffffffc020422c:	00003517          	auipc	a0,0x3
ffffffffc0204230:	2ac50513          	addi	a0,a0,684 # ffffffffc02074d8 <commands+0x17b0>
ffffffffc0204234:	fe1fb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0204238:	00003697          	auipc	a3,0x3
ffffffffc020423c:	53068693          	addi	a3,a3,1328 # ffffffffc0207768 <commands+0x1a40>
ffffffffc0204240:	00002617          	auipc	a2,0x2
ffffffffc0204244:	f6860613          	addi	a2,a2,-152 # ffffffffc02061a8 <commands+0x480>
ffffffffc0204248:	11000593          	li	a1,272
ffffffffc020424c:	00003517          	auipc	a0,0x3
ffffffffc0204250:	28c50513          	addi	a0,a0,652 # ffffffffc02074d8 <commands+0x17b0>
ffffffffc0204254:	fc1fb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0204258:	00003697          	auipc	a3,0x3
ffffffffc020425c:	4e868693          	addi	a3,a3,1256 # ffffffffc0207740 <commands+0x1a18>
ffffffffc0204260:	00002617          	auipc	a2,0x2
ffffffffc0204264:	f4860613          	addi	a2,a2,-184 # ffffffffc02061a8 <commands+0x480>
ffffffffc0204268:	10e00593          	li	a1,270
ffffffffc020426c:	00003517          	auipc	a0,0x3
ffffffffc0204270:	26c50513          	addi	a0,a0,620 # ffffffffc02074d8 <commands+0x17b0>
ffffffffc0204274:	fa1fb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0204278:	00003697          	auipc	a3,0x3
ffffffffc020427c:	4a068693          	addi	a3,a3,1184 # ffffffffc0207718 <commands+0x19f0>
ffffffffc0204280:	00002617          	auipc	a2,0x2
ffffffffc0204284:	f2860613          	addi	a2,a2,-216 # ffffffffc02061a8 <commands+0x480>
ffffffffc0204288:	10d00593          	li	a1,269
ffffffffc020428c:	00003517          	auipc	a0,0x3
ffffffffc0204290:	24c50513          	addi	a0,a0,588 # ffffffffc02074d8 <commands+0x17b0>
ffffffffc0204294:	f81fb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(p0 + 2 == p1);
ffffffffc0204298:	00003697          	auipc	a3,0x3
ffffffffc020429c:	47068693          	addi	a3,a3,1136 # ffffffffc0207708 <commands+0x19e0>
ffffffffc02042a0:	00002617          	auipc	a2,0x2
ffffffffc02042a4:	f0860613          	addi	a2,a2,-248 # ffffffffc02061a8 <commands+0x480>
ffffffffc02042a8:	10800593          	li	a1,264
ffffffffc02042ac:	00003517          	auipc	a0,0x3
ffffffffc02042b0:	22c50513          	addi	a0,a0,556 # ffffffffc02074d8 <commands+0x17b0>
ffffffffc02042b4:	f61fb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02042b8:	00003697          	auipc	a3,0x3
ffffffffc02042bc:	36068693          	addi	a3,a3,864 # ffffffffc0207618 <commands+0x18f0>
ffffffffc02042c0:	00002617          	auipc	a2,0x2
ffffffffc02042c4:	ee860613          	addi	a2,a2,-280 # ffffffffc02061a8 <commands+0x480>
ffffffffc02042c8:	10700593          	li	a1,263
ffffffffc02042cc:	00003517          	auipc	a0,0x3
ffffffffc02042d0:	20c50513          	addi	a0,a0,524 # ffffffffc02074d8 <commands+0x17b0>
ffffffffc02042d4:	f41fb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc02042d8:	00003697          	auipc	a3,0x3
ffffffffc02042dc:	41068693          	addi	a3,a3,1040 # ffffffffc02076e8 <commands+0x19c0>
ffffffffc02042e0:	00002617          	auipc	a2,0x2
ffffffffc02042e4:	ec860613          	addi	a2,a2,-312 # ffffffffc02061a8 <commands+0x480>
ffffffffc02042e8:	10600593          	li	a1,262
ffffffffc02042ec:	00003517          	auipc	a0,0x3
ffffffffc02042f0:	1ec50513          	addi	a0,a0,492 # ffffffffc02074d8 <commands+0x17b0>
ffffffffc02042f4:	f21fb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc02042f8:	00003697          	auipc	a3,0x3
ffffffffc02042fc:	3c068693          	addi	a3,a3,960 # ffffffffc02076b8 <commands+0x1990>
ffffffffc0204300:	00002617          	auipc	a2,0x2
ffffffffc0204304:	ea860613          	addi	a2,a2,-344 # ffffffffc02061a8 <commands+0x480>
ffffffffc0204308:	10500593          	li	a1,261
ffffffffc020430c:	00003517          	auipc	a0,0x3
ffffffffc0204310:	1cc50513          	addi	a0,a0,460 # ffffffffc02074d8 <commands+0x17b0>
ffffffffc0204314:	f01fb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0204318:	00003697          	auipc	a3,0x3
ffffffffc020431c:	38868693          	addi	a3,a3,904 # ffffffffc02076a0 <commands+0x1978>
ffffffffc0204320:	00002617          	auipc	a2,0x2
ffffffffc0204324:	e8860613          	addi	a2,a2,-376 # ffffffffc02061a8 <commands+0x480>
ffffffffc0204328:	10400593          	li	a1,260
ffffffffc020432c:	00003517          	auipc	a0,0x3
ffffffffc0204330:	1ac50513          	addi	a0,a0,428 # ffffffffc02074d8 <commands+0x17b0>
ffffffffc0204334:	ee1fb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0204338:	00003697          	auipc	a3,0x3
ffffffffc020433c:	2e068693          	addi	a3,a3,736 # ffffffffc0207618 <commands+0x18f0>
ffffffffc0204340:	00002617          	auipc	a2,0x2
ffffffffc0204344:	e6860613          	addi	a2,a2,-408 # ffffffffc02061a8 <commands+0x480>
ffffffffc0204348:	0fe00593          	li	a1,254
ffffffffc020434c:	00003517          	auipc	a0,0x3
ffffffffc0204350:	18c50513          	addi	a0,a0,396 # ffffffffc02074d8 <commands+0x17b0>
ffffffffc0204354:	ec1fb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(!PageProperty(p0));
ffffffffc0204358:	00003697          	auipc	a3,0x3
ffffffffc020435c:	33068693          	addi	a3,a3,816 # ffffffffc0207688 <commands+0x1960>
ffffffffc0204360:	00002617          	auipc	a2,0x2
ffffffffc0204364:	e4860613          	addi	a2,a2,-440 # ffffffffc02061a8 <commands+0x480>
ffffffffc0204368:	0f900593          	li	a1,249
ffffffffc020436c:	00003517          	auipc	a0,0x3
ffffffffc0204370:	16c50513          	addi	a0,a0,364 # ffffffffc02074d8 <commands+0x17b0>
ffffffffc0204374:	ea1fb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0204378:	00003697          	auipc	a3,0x3
ffffffffc020437c:	43068693          	addi	a3,a3,1072 # ffffffffc02077a8 <commands+0x1a80>
ffffffffc0204380:	00002617          	auipc	a2,0x2
ffffffffc0204384:	e2860613          	addi	a2,a2,-472 # ffffffffc02061a8 <commands+0x480>
ffffffffc0204388:	11700593          	li	a1,279
ffffffffc020438c:	00003517          	auipc	a0,0x3
ffffffffc0204390:	14c50513          	addi	a0,a0,332 # ffffffffc02074d8 <commands+0x17b0>
ffffffffc0204394:	e81fb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(total == 0);
ffffffffc0204398:	00003697          	auipc	a3,0x3
ffffffffc020439c:	44068693          	addi	a3,a3,1088 # ffffffffc02077d8 <commands+0x1ab0>
ffffffffc02043a0:	00002617          	auipc	a2,0x2
ffffffffc02043a4:	e0860613          	addi	a2,a2,-504 # ffffffffc02061a8 <commands+0x480>
ffffffffc02043a8:	12600593          	li	a1,294
ffffffffc02043ac:	00003517          	auipc	a0,0x3
ffffffffc02043b0:	12c50513          	addi	a0,a0,300 # ffffffffc02074d8 <commands+0x17b0>
ffffffffc02043b4:	e61fb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(total == nr_free_pages());
ffffffffc02043b8:	00003697          	auipc	a3,0x3
ffffffffc02043bc:	be068693          	addi	a3,a3,-1056 # ffffffffc0206f98 <commands+0x1270>
ffffffffc02043c0:	00002617          	auipc	a2,0x2
ffffffffc02043c4:	de860613          	addi	a2,a2,-536 # ffffffffc02061a8 <commands+0x480>
ffffffffc02043c8:	0f300593          	li	a1,243
ffffffffc02043cc:	00003517          	auipc	a0,0x3
ffffffffc02043d0:	10c50513          	addi	a0,a0,268 # ffffffffc02074d8 <commands+0x17b0>
ffffffffc02043d4:	e41fb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02043d8:	00003697          	auipc	a3,0x3
ffffffffc02043dc:	13868693          	addi	a3,a3,312 # ffffffffc0207510 <commands+0x17e8>
ffffffffc02043e0:	00002617          	auipc	a2,0x2
ffffffffc02043e4:	dc860613          	addi	a2,a2,-568 # ffffffffc02061a8 <commands+0x480>
ffffffffc02043e8:	0ba00593          	li	a1,186
ffffffffc02043ec:	00003517          	auipc	a0,0x3
ffffffffc02043f0:	0ec50513          	addi	a0,a0,236 # ffffffffc02074d8 <commands+0x17b0>
ffffffffc02043f4:	e21fb0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc02043f8 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc02043f8:	1141                	addi	sp,sp,-16
ffffffffc02043fa:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02043fc:	16058e63          	beqz	a1,ffffffffc0204578 <default_free_pages+0x180>
    for (; p != base + n; p ++) {
ffffffffc0204400:	00659693          	slli	a3,a1,0x6
ffffffffc0204404:	96aa                	add	a3,a3,a0
ffffffffc0204406:	02d50d63          	beq	a0,a3,ffffffffc0204440 <default_free_pages+0x48>
ffffffffc020440a:	651c                	ld	a5,8(a0)
ffffffffc020440c:	8b85                	andi	a5,a5,1
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020440e:	14079563          	bnez	a5,ffffffffc0204558 <default_free_pages+0x160>
ffffffffc0204412:	651c                	ld	a5,8(a0)
ffffffffc0204414:	8385                	srli	a5,a5,0x1
ffffffffc0204416:	8b85                	andi	a5,a5,1
ffffffffc0204418:	14079063          	bnez	a5,ffffffffc0204558 <default_free_pages+0x160>
ffffffffc020441c:	87aa                	mv	a5,a0
ffffffffc020441e:	a809                	j	ffffffffc0204430 <default_free_pages+0x38>
ffffffffc0204420:	6798                	ld	a4,8(a5)
ffffffffc0204422:	8b05                	andi	a4,a4,1
ffffffffc0204424:	12071a63          	bnez	a4,ffffffffc0204558 <default_free_pages+0x160>
ffffffffc0204428:	6798                	ld	a4,8(a5)
ffffffffc020442a:	8b09                	andi	a4,a4,2
ffffffffc020442c:	12071663          	bnez	a4,ffffffffc0204558 <default_free_pages+0x160>
        p->flags = 0;
ffffffffc0204430:	0007b423          	sd	zero,8(a5)
    page->ref = val;
ffffffffc0204434:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0204438:	04078793          	addi	a5,a5,64
ffffffffc020443c:	fed792e3          	bne	a5,a3,ffffffffc0204420 <default_free_pages+0x28>
    base->property = n;
ffffffffc0204440:	2581                	sext.w	a1,a1
ffffffffc0204442:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc0204444:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0204448:	4789                	li	a5,2
ffffffffc020444a:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc020444e:	000a8697          	auipc	a3,0xa8
ffffffffc0204452:	55a68693          	addi	a3,a3,1370 # ffffffffc02ac9a8 <free_area>
ffffffffc0204456:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0204458:	669c                	ld	a5,8(a3)
ffffffffc020445a:	9db9                	addw	a1,a1,a4
ffffffffc020445c:	000a8717          	auipc	a4,0xa8
ffffffffc0204460:	54b72e23          	sw	a1,1372(a4) # ffffffffc02ac9b8 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc0204464:	0cd78163          	beq	a5,a3,ffffffffc0204526 <default_free_pages+0x12e>
            struct Page* page = le2page(le, page_link);
ffffffffc0204468:	fe878713          	addi	a4,a5,-24
ffffffffc020446c:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc020446e:	4801                	li	a6,0
ffffffffc0204470:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc0204474:	00e56a63          	bltu	a0,a4,ffffffffc0204488 <default_free_pages+0x90>
    return listelm->next;
ffffffffc0204478:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc020447a:	04d70f63          	beq	a4,a3,ffffffffc02044d8 <default_free_pages+0xe0>
        while ((le = list_next(le)) != &free_list) {
ffffffffc020447e:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0204480:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0204484:	fee57ae3          	bgeu	a0,a4,ffffffffc0204478 <default_free_pages+0x80>
ffffffffc0204488:	00080663          	beqz	a6,ffffffffc0204494 <default_free_pages+0x9c>
ffffffffc020448c:	000a8817          	auipc	a6,0xa8
ffffffffc0204490:	50b83e23          	sd	a1,1308(a6) # ffffffffc02ac9a8 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0204494:	638c                	ld	a1,0(a5)
    prev->next = next->prev = elm;
ffffffffc0204496:	e390                	sd	a2,0(a5)
ffffffffc0204498:	e590                	sd	a2,8(a1)
    elm->next = next;
ffffffffc020449a:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020449c:	ed0c                	sd	a1,24(a0)
    if (le != &free_list) {
ffffffffc020449e:	06d58a63          	beq	a1,a3,ffffffffc0204512 <default_free_pages+0x11a>
        if (p + p->property == base) {
ffffffffc02044a2:	ff85a603          	lw	a2,-8(a1) # ff8 <_binary_obj___user_faultread_out_size-0x85d0>
        p = le2page(le, page_link);
ffffffffc02044a6:	fe858713          	addi	a4,a1,-24
        if (p + p->property == base) {
ffffffffc02044aa:	02061793          	slli	a5,a2,0x20
ffffffffc02044ae:	83e9                	srli	a5,a5,0x1a
ffffffffc02044b0:	97ba                	add	a5,a5,a4
ffffffffc02044b2:	04f51b63          	bne	a0,a5,ffffffffc0204508 <default_free_pages+0x110>
            p->property += base->property;
ffffffffc02044b6:	491c                	lw	a5,16(a0)
ffffffffc02044b8:	9e3d                	addw	a2,a2,a5
ffffffffc02044ba:	fec5ac23          	sw	a2,-8(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02044be:	57f5                	li	a5,-3
ffffffffc02044c0:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc02044c4:	01853803          	ld	a6,24(a0)
ffffffffc02044c8:	7110                	ld	a2,32(a0)
            base = p;
ffffffffc02044ca:	853a                	mv	a0,a4
    prev->next = next;
ffffffffc02044cc:	00c83423          	sd	a2,8(a6)
    next->prev = prev;
ffffffffc02044d0:	659c                	ld	a5,8(a1)
ffffffffc02044d2:	01063023          	sd	a6,0(a2)
ffffffffc02044d6:	a815                	j	ffffffffc020450a <default_free_pages+0x112>
    prev->next = next->prev = elm;
ffffffffc02044d8:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02044da:	f114                	sd	a3,32(a0)
ffffffffc02044dc:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02044de:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc02044e0:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc02044e2:	00d70563          	beq	a4,a3,ffffffffc02044ec <default_free_pages+0xf4>
ffffffffc02044e6:	4805                	li	a6,1
ffffffffc02044e8:	87ba                	mv	a5,a4
ffffffffc02044ea:	bf59                	j	ffffffffc0204480 <default_free_pages+0x88>
ffffffffc02044ec:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc02044ee:	85be                	mv	a1,a5
    if (le != &free_list) {
ffffffffc02044f0:	00d78d63          	beq	a5,a3,ffffffffc020450a <default_free_pages+0x112>
        if (p + p->property == base) {
ffffffffc02044f4:	ff85a603          	lw	a2,-8(a1)
        p = le2page(le, page_link);
ffffffffc02044f8:	fe858713          	addi	a4,a1,-24
        if (p + p->property == base) {
ffffffffc02044fc:	02061793          	slli	a5,a2,0x20
ffffffffc0204500:	83e9                	srli	a5,a5,0x1a
ffffffffc0204502:	97ba                	add	a5,a5,a4
ffffffffc0204504:	faf509e3          	beq	a0,a5,ffffffffc02044b6 <default_free_pages+0xbe>
ffffffffc0204508:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc020450a:	fe878713          	addi	a4,a5,-24
ffffffffc020450e:	00d78963          	beq	a5,a3,ffffffffc0204520 <default_free_pages+0x128>
        if (base + base->property == p) {
ffffffffc0204512:	4910                	lw	a2,16(a0)
ffffffffc0204514:	02061693          	slli	a3,a2,0x20
ffffffffc0204518:	82e9                	srli	a3,a3,0x1a
ffffffffc020451a:	96aa                	add	a3,a3,a0
ffffffffc020451c:	00d70e63          	beq	a4,a3,ffffffffc0204538 <default_free_pages+0x140>
}
ffffffffc0204520:	60a2                	ld	ra,8(sp)
ffffffffc0204522:	0141                	addi	sp,sp,16
ffffffffc0204524:	8082                	ret
ffffffffc0204526:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0204528:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc020452c:	e398                	sd	a4,0(a5)
ffffffffc020452e:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0204530:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0204532:	ed1c                	sd	a5,24(a0)
}
ffffffffc0204534:	0141                	addi	sp,sp,16
ffffffffc0204536:	8082                	ret
            base->property += p->property;
ffffffffc0204538:	ff87a703          	lw	a4,-8(a5)
ffffffffc020453c:	ff078693          	addi	a3,a5,-16
ffffffffc0204540:	9e39                	addw	a2,a2,a4
ffffffffc0204542:	c910                	sw	a2,16(a0)
ffffffffc0204544:	5775                	li	a4,-3
ffffffffc0204546:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc020454a:	6398                	ld	a4,0(a5)
ffffffffc020454c:	679c                	ld	a5,8(a5)
}
ffffffffc020454e:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0204550:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0204552:	e398                	sd	a4,0(a5)
ffffffffc0204554:	0141                	addi	sp,sp,16
ffffffffc0204556:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0204558:	00003697          	auipc	a3,0x3
ffffffffc020455c:	29068693          	addi	a3,a3,656 # ffffffffc02077e8 <commands+0x1ac0>
ffffffffc0204560:	00002617          	auipc	a2,0x2
ffffffffc0204564:	c4860613          	addi	a2,a2,-952 # ffffffffc02061a8 <commands+0x480>
ffffffffc0204568:	08300593          	li	a1,131
ffffffffc020456c:	00003517          	auipc	a0,0x3
ffffffffc0204570:	f6c50513          	addi	a0,a0,-148 # ffffffffc02074d8 <commands+0x17b0>
ffffffffc0204574:	ca1fb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(n > 0);
ffffffffc0204578:	00003697          	auipc	a3,0x3
ffffffffc020457c:	29868693          	addi	a3,a3,664 # ffffffffc0207810 <commands+0x1ae8>
ffffffffc0204580:	00002617          	auipc	a2,0x2
ffffffffc0204584:	c2860613          	addi	a2,a2,-984 # ffffffffc02061a8 <commands+0x480>
ffffffffc0204588:	08000593          	li	a1,128
ffffffffc020458c:	00003517          	auipc	a0,0x3
ffffffffc0204590:	f4c50513          	addi	a0,a0,-180 # ffffffffc02074d8 <commands+0x17b0>
ffffffffc0204594:	c81fb0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0204598 <default_alloc_pages>:
    assert(n > 0);
ffffffffc0204598:	c959                	beqz	a0,ffffffffc020462e <default_alloc_pages+0x96>
    if (n > nr_free) {
ffffffffc020459a:	000a8597          	auipc	a1,0xa8
ffffffffc020459e:	40e58593          	addi	a1,a1,1038 # ffffffffc02ac9a8 <free_area>
ffffffffc02045a2:	0105a803          	lw	a6,16(a1)
ffffffffc02045a6:	862a                	mv	a2,a0
ffffffffc02045a8:	02081793          	slli	a5,a6,0x20
ffffffffc02045ac:	9381                	srli	a5,a5,0x20
ffffffffc02045ae:	00a7ee63          	bltu	a5,a0,ffffffffc02045ca <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc02045b2:	87ae                	mv	a5,a1
ffffffffc02045b4:	a801                	j	ffffffffc02045c4 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc02045b6:	ff87a703          	lw	a4,-8(a5)
ffffffffc02045ba:	02071693          	slli	a3,a4,0x20
ffffffffc02045be:	9281                	srli	a3,a3,0x20
ffffffffc02045c0:	00c6f763          	bgeu	a3,a2,ffffffffc02045ce <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc02045c4:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc02045c6:	feb798e3          	bne	a5,a1,ffffffffc02045b6 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc02045ca:	4501                	li	a0,0
}
ffffffffc02045cc:	8082                	ret
        struct Page *p = le2page(le, page_link);
ffffffffc02045ce:	fe878513          	addi	a0,a5,-24
    if (page != NULL) {
ffffffffc02045d2:	dd6d                	beqz	a0,ffffffffc02045cc <default_alloc_pages+0x34>
    return listelm->prev;
ffffffffc02045d4:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc02045d8:	0087b303          	ld	t1,8(a5)
    prev->next = next;
ffffffffc02045dc:	00060e1b          	sext.w	t3,a2
ffffffffc02045e0:	0068b423          	sd	t1,8(a7) # fffffffffff80008 <end+0x3fcd3638>
    next->prev = prev;
ffffffffc02045e4:	01133023          	sd	a7,0(t1) # ffffffffc0000000 <_binary_obj___user_exit_out_size+0xffffffffbfff5538>
        if (page->property > n) {
ffffffffc02045e8:	02d67863          	bgeu	a2,a3,ffffffffc0204618 <default_alloc_pages+0x80>
            struct Page *p = page + n;
ffffffffc02045ec:	061a                	slli	a2,a2,0x6
ffffffffc02045ee:	962a                	add	a2,a2,a0
            p->property = page->property - n;
ffffffffc02045f0:	41c7073b          	subw	a4,a4,t3
ffffffffc02045f4:	ca18                	sw	a4,16(a2)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02045f6:	00860693          	addi	a3,a2,8
ffffffffc02045fa:	4709                	li	a4,2
ffffffffc02045fc:	40e6b02f          	amoor.d	zero,a4,(a3)
    __list_add(elm, listelm, listelm->next);
ffffffffc0204600:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc0204604:	01860693          	addi	a3,a2,24
    prev->next = next->prev = elm;
ffffffffc0204608:	0105a803          	lw	a6,16(a1)
ffffffffc020460c:	e314                	sd	a3,0(a4)
ffffffffc020460e:	00d8b423          	sd	a3,8(a7)
    elm->next = next;
ffffffffc0204612:	f218                	sd	a4,32(a2)
    elm->prev = prev;
ffffffffc0204614:	01163c23          	sd	a7,24(a2)
        nr_free -= n;
ffffffffc0204618:	41c8083b          	subw	a6,a6,t3
ffffffffc020461c:	000a8717          	auipc	a4,0xa8
ffffffffc0204620:	39072e23          	sw	a6,924(a4) # ffffffffc02ac9b8 <free_area+0x10>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0204624:	5775                	li	a4,-3
ffffffffc0204626:	17c1                	addi	a5,a5,-16
ffffffffc0204628:	60e7b02f          	amoand.d	zero,a4,(a5)
ffffffffc020462c:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc020462e:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0204630:	00003697          	auipc	a3,0x3
ffffffffc0204634:	1e068693          	addi	a3,a3,480 # ffffffffc0207810 <commands+0x1ae8>
ffffffffc0204638:	00002617          	auipc	a2,0x2
ffffffffc020463c:	b7060613          	addi	a2,a2,-1168 # ffffffffc02061a8 <commands+0x480>
ffffffffc0204640:	06200593          	li	a1,98
ffffffffc0204644:	00003517          	auipc	a0,0x3
ffffffffc0204648:	e9450513          	addi	a0,a0,-364 # ffffffffc02074d8 <commands+0x17b0>
default_alloc_pages(size_t n) {
ffffffffc020464c:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020464e:	bc7fb0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0204652 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc0204652:	1141                	addi	sp,sp,-16
ffffffffc0204654:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0204656:	c1ed                	beqz	a1,ffffffffc0204738 <default_init_memmap+0xe6>
    for (; p != base + n; p ++) {
ffffffffc0204658:	00659693          	slli	a3,a1,0x6
ffffffffc020465c:	96aa                	add	a3,a3,a0
ffffffffc020465e:	02d50463          	beq	a0,a3,ffffffffc0204686 <default_init_memmap+0x34>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0204662:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc0204664:	87aa                	mv	a5,a0
ffffffffc0204666:	8b05                	andi	a4,a4,1
ffffffffc0204668:	e709                	bnez	a4,ffffffffc0204672 <default_init_memmap+0x20>
ffffffffc020466a:	a07d                	j	ffffffffc0204718 <default_init_memmap+0xc6>
ffffffffc020466c:	6798                	ld	a4,8(a5)
ffffffffc020466e:	8b05                	andi	a4,a4,1
ffffffffc0204670:	c745                	beqz	a4,ffffffffc0204718 <default_init_memmap+0xc6>
        p->flags = p->property = 0;
ffffffffc0204672:	0007a823          	sw	zero,16(a5)
ffffffffc0204676:	0007b423          	sd	zero,8(a5)
ffffffffc020467a:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc020467e:	04078793          	addi	a5,a5,64
ffffffffc0204682:	fed795e3          	bne	a5,a3,ffffffffc020466c <default_init_memmap+0x1a>
    base->property = n;
ffffffffc0204686:	2581                	sext.w	a1,a1
ffffffffc0204688:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020468a:	4789                	li	a5,2
ffffffffc020468c:	00850713          	addi	a4,a0,8
ffffffffc0204690:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0204694:	000a8697          	auipc	a3,0xa8
ffffffffc0204698:	31468693          	addi	a3,a3,788 # ffffffffc02ac9a8 <free_area>
ffffffffc020469c:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc020469e:	669c                	ld	a5,8(a3)
ffffffffc02046a0:	9db9                	addw	a1,a1,a4
ffffffffc02046a2:	000a8717          	auipc	a4,0xa8
ffffffffc02046a6:	30b72b23          	sw	a1,790(a4) # ffffffffc02ac9b8 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc02046aa:	04d78a63          	beq	a5,a3,ffffffffc02046fe <default_init_memmap+0xac>
            struct Page* page = le2page(le, page_link);
ffffffffc02046ae:	fe878713          	addi	a4,a5,-24
ffffffffc02046b2:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02046b4:	4801                	li	a6,0
ffffffffc02046b6:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc02046ba:	00e56a63          	bltu	a0,a4,ffffffffc02046ce <default_init_memmap+0x7c>
    return listelm->next;
ffffffffc02046be:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02046c0:	02d70563          	beq	a4,a3,ffffffffc02046ea <default_init_memmap+0x98>
        while ((le = list_next(le)) != &free_list) {
ffffffffc02046c4:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02046c6:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc02046ca:	fee57ae3          	bgeu	a0,a4,ffffffffc02046be <default_init_memmap+0x6c>
ffffffffc02046ce:	00080663          	beqz	a6,ffffffffc02046da <default_init_memmap+0x88>
ffffffffc02046d2:	000a8717          	auipc	a4,0xa8
ffffffffc02046d6:	2cb73b23          	sd	a1,726(a4) # ffffffffc02ac9a8 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc02046da:	6398                	ld	a4,0(a5)
}
ffffffffc02046dc:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc02046de:	e390                	sd	a2,0(a5)
ffffffffc02046e0:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02046e2:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02046e4:	ed18                	sd	a4,24(a0)
ffffffffc02046e6:	0141                	addi	sp,sp,16
ffffffffc02046e8:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02046ea:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02046ec:	f114                	sd	a3,32(a0)
ffffffffc02046ee:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02046f0:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc02046f2:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc02046f4:	00d70e63          	beq	a4,a3,ffffffffc0204710 <default_init_memmap+0xbe>
ffffffffc02046f8:	4805                	li	a6,1
ffffffffc02046fa:	87ba                	mv	a5,a4
ffffffffc02046fc:	b7e9                	j	ffffffffc02046c6 <default_init_memmap+0x74>
}
ffffffffc02046fe:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0204700:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc0204704:	e398                	sd	a4,0(a5)
ffffffffc0204706:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0204708:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020470a:	ed1c                	sd	a5,24(a0)
}
ffffffffc020470c:	0141                	addi	sp,sp,16
ffffffffc020470e:	8082                	ret
ffffffffc0204710:	60a2                	ld	ra,8(sp)
ffffffffc0204712:	e290                	sd	a2,0(a3)
ffffffffc0204714:	0141                	addi	sp,sp,16
ffffffffc0204716:	8082                	ret
        assert(PageReserved(p));
ffffffffc0204718:	00003697          	auipc	a3,0x3
ffffffffc020471c:	10068693          	addi	a3,a3,256 # ffffffffc0207818 <commands+0x1af0>
ffffffffc0204720:	00002617          	auipc	a2,0x2
ffffffffc0204724:	a8860613          	addi	a2,a2,-1400 # ffffffffc02061a8 <commands+0x480>
ffffffffc0204728:	04900593          	li	a1,73
ffffffffc020472c:	00003517          	auipc	a0,0x3
ffffffffc0204730:	dac50513          	addi	a0,a0,-596 # ffffffffc02074d8 <commands+0x17b0>
ffffffffc0204734:	ae1fb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(n > 0);
ffffffffc0204738:	00003697          	auipc	a3,0x3
ffffffffc020473c:	0d868693          	addi	a3,a3,216 # ffffffffc0207810 <commands+0x1ae8>
ffffffffc0204740:	00002617          	auipc	a2,0x2
ffffffffc0204744:	a6860613          	addi	a2,a2,-1432 # ffffffffc02061a8 <commands+0x480>
ffffffffc0204748:	04600593          	li	a1,70
ffffffffc020474c:	00003517          	auipc	a0,0x3
ffffffffc0204750:	d8c50513          	addi	a0,a0,-628 # ffffffffc02074d8 <commands+0x17b0>
ffffffffc0204754:	ac1fb0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0204758 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0204758:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc020475a:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc020475c:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc020475e:	dd3fb0ef          	jal	ra,ffffffffc0200530 <ide_device_valid>
ffffffffc0204762:	cd01                	beqz	a0,ffffffffc020477a <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204764:	4505                	li	a0,1
ffffffffc0204766:	dd1fb0ef          	jal	ra,ffffffffc0200536 <ide_device_size>
}
ffffffffc020476a:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc020476c:	810d                	srli	a0,a0,0x3
ffffffffc020476e:	000a8797          	auipc	a5,0xa8
ffffffffc0204772:	1ea7b523          	sd	a0,490(a5) # ffffffffc02ac958 <max_swap_offset>
}
ffffffffc0204776:	0141                	addi	sp,sp,16
ffffffffc0204778:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc020477a:	00003617          	auipc	a2,0x3
ffffffffc020477e:	0fe60613          	addi	a2,a2,254 # ffffffffc0207878 <default_pmm_manager+0x50>
ffffffffc0204782:	45b5                	li	a1,13
ffffffffc0204784:	00003517          	auipc	a0,0x3
ffffffffc0204788:	11450513          	addi	a0,a0,276 # ffffffffc0207898 <default_pmm_manager+0x70>
ffffffffc020478c:	a89fb0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0204790 <swapfs_write>:
swapfs_read(swap_entry_t entry, struct Page *page) {
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
}

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0204790:	1141                	addi	sp,sp,-16
ffffffffc0204792:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204794:	00855793          	srli	a5,a0,0x8
ffffffffc0204798:	cfb9                	beqz	a5,ffffffffc02047f6 <swapfs_write+0x66>
ffffffffc020479a:	000a8717          	auipc	a4,0xa8
ffffffffc020479e:	1be70713          	addi	a4,a4,446 # ffffffffc02ac958 <max_swap_offset>
ffffffffc02047a2:	6318                	ld	a4,0(a4)
ffffffffc02047a4:	04e7f963          	bgeu	a5,a4,ffffffffc02047f6 <swapfs_write+0x66>
    return page - pages + nbase;
ffffffffc02047a8:	000a8717          	auipc	a4,0xa8
ffffffffc02047ac:	11870713          	addi	a4,a4,280 # ffffffffc02ac8c0 <pages>
ffffffffc02047b0:	6310                	ld	a2,0(a4)
ffffffffc02047b2:	00004717          	auipc	a4,0x4
ffffffffc02047b6:	9f670713          	addi	a4,a4,-1546 # ffffffffc02081a8 <nbase>
ffffffffc02047ba:	40c58633          	sub	a2,a1,a2
ffffffffc02047be:	630c                	ld	a1,0(a4)
ffffffffc02047c0:	8619                	srai	a2,a2,0x6
    return KADDR(page2pa(page));
ffffffffc02047c2:	000a8717          	auipc	a4,0xa8
ffffffffc02047c6:	09670713          	addi	a4,a4,150 # ffffffffc02ac858 <npage>
    return page - pages + nbase;
ffffffffc02047ca:	962e                	add	a2,a2,a1
    return KADDR(page2pa(page));
ffffffffc02047cc:	6314                	ld	a3,0(a4)
ffffffffc02047ce:	00c61713          	slli	a4,a2,0xc
ffffffffc02047d2:	8331                	srli	a4,a4,0xc
ffffffffc02047d4:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc02047d8:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc02047da:	02d77a63          	bgeu	a4,a3,ffffffffc020480e <swapfs_write+0x7e>
ffffffffc02047de:	000a8797          	auipc	a5,0xa8
ffffffffc02047e2:	0d278793          	addi	a5,a5,210 # ffffffffc02ac8b0 <va_pa_offset>
ffffffffc02047e6:	639c                	ld	a5,0(a5)
}
ffffffffc02047e8:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc02047ea:	46a1                	li	a3,8
ffffffffc02047ec:	963e                	add	a2,a2,a5
ffffffffc02047ee:	4505                	li	a0,1
}
ffffffffc02047f0:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc02047f2:	d4bfb06f          	j	ffffffffc020053c <ide_write_secs>
ffffffffc02047f6:	86aa                	mv	a3,a0
ffffffffc02047f8:	00003617          	auipc	a2,0x3
ffffffffc02047fc:	0b860613          	addi	a2,a2,184 # ffffffffc02078b0 <default_pmm_manager+0x88>
ffffffffc0204800:	45e5                	li	a1,25
ffffffffc0204802:	00003517          	auipc	a0,0x3
ffffffffc0204806:	09650513          	addi	a0,a0,150 # ffffffffc0207898 <default_pmm_manager+0x70>
ffffffffc020480a:	a0bfb0ef          	jal	ra,ffffffffc0200214 <__panic>
ffffffffc020480e:	86b2                	mv	a3,a2
ffffffffc0204810:	06900593          	li	a1,105
ffffffffc0204814:	00002617          	auipc	a2,0x2
ffffffffc0204818:	d4c60613          	addi	a2,a2,-692 # ffffffffc0206560 <commands+0x838>
ffffffffc020481c:	00002517          	auipc	a0,0x2
ffffffffc0204820:	d9c50513          	addi	a0,a0,-612 # ffffffffc02065b8 <commands+0x890>
ffffffffc0204824:	9f1fb0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0204828 <user_main>:

// user_main - kernel thread used to exec a user program
static int
user_main(void *arg) {
#ifdef TEST
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204828:	000a8797          	auipc	a5,0xa8
ffffffffc020482c:	05878793          	addi	a5,a5,88 # ffffffffc02ac880 <current>
ffffffffc0204830:	639c                	ld	a5,0(a5)
user_main(void *arg) {
ffffffffc0204832:	7139                	addi	sp,sp,-64
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204834:	00003617          	auipc	a2,0x3
ffffffffc0204838:	44460613          	addi	a2,a2,1092 # ffffffffc0207c78 <default_pmm_manager+0x450>
ffffffffc020483c:	43cc                	lw	a1,4(a5)
ffffffffc020483e:	00003517          	auipc	a0,0x3
ffffffffc0204842:	44a50513          	addi	a0,a0,1098 # ffffffffc0207c88 <default_pmm_manager+0x460>
user_main(void *arg) {
ffffffffc0204846:	fc06                	sd	ra,56(sp)
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204848:	889fb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
ffffffffc020484c:	00003797          	auipc	a5,0x3
ffffffffc0204850:	42c78793          	addi	a5,a5,1068 # ffffffffc0207c78 <default_pmm_manager+0x450>
ffffffffc0204854:	3fe06717          	auipc	a4,0x3fe06
ffffffffc0204858:	ac470713          	addi	a4,a4,-1340 # a318 <_binary_obj___user_forktest_out_size>
ffffffffc020485c:	e43a                	sd	a4,8(sp)
    int64_t ret=0, len = strlen(name);
ffffffffc020485e:	853e                	mv	a0,a5
ffffffffc0204860:	00093717          	auipc	a4,0x93
ffffffffc0204864:	87070713          	addi	a4,a4,-1936 # ffffffffc02970d0 <_binary_obj___user_forktest_out_start>
ffffffffc0204868:	f03a                	sd	a4,32(sp)
ffffffffc020486a:	f43e                	sd	a5,40(sp)
ffffffffc020486c:	e802                	sd	zero,16(sp)
ffffffffc020486e:	679000ef          	jal	ra,ffffffffc02056e6 <strlen>
ffffffffc0204872:	ec2a                	sd	a0,24(sp)
    asm volatile(
ffffffffc0204874:	4511                	li	a0,4
ffffffffc0204876:	55a2                	lw	a1,40(sp)
ffffffffc0204878:	4662                	lw	a2,24(sp)
ffffffffc020487a:	5682                	lw	a3,32(sp)
ffffffffc020487c:	4722                	lw	a4,8(sp)
ffffffffc020487e:	48a9                	li	a7,10
ffffffffc0204880:	9002                	ebreak
ffffffffc0204882:	c82a                	sw	a0,16(sp)
    cprintf("ret = %d\n", ret);
ffffffffc0204884:	65c2                	ld	a1,16(sp)
ffffffffc0204886:	00003517          	auipc	a0,0x3
ffffffffc020488a:	42a50513          	addi	a0,a0,1066 # ffffffffc0207cb0 <default_pmm_manager+0x488>
ffffffffc020488e:	843fb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
#else
    KERNEL_EXECVE(exit);
#endif
    panic("user_main execve failed.\n");
ffffffffc0204892:	00003617          	auipc	a2,0x3
ffffffffc0204896:	42e60613          	addi	a2,a2,1070 # ffffffffc0207cc0 <default_pmm_manager+0x498>
ffffffffc020489a:	31b00593          	li	a1,795
ffffffffc020489e:	00003517          	auipc	a0,0x3
ffffffffc02048a2:	44250513          	addi	a0,a0,1090 # ffffffffc0207ce0 <default_pmm_manager+0x4b8>
ffffffffc02048a6:	96ffb0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc02048aa <put_pgdir>:
    return pa2page(PADDR(kva));
ffffffffc02048aa:	6d14                	ld	a3,24(a0)
put_pgdir(struct mm_struct *mm) {
ffffffffc02048ac:	1141                	addi	sp,sp,-16
ffffffffc02048ae:	e406                	sd	ra,8(sp)
ffffffffc02048b0:	c02007b7          	lui	a5,0xc0200
ffffffffc02048b4:	04f6e263          	bltu	a3,a5,ffffffffc02048f8 <put_pgdir+0x4e>
ffffffffc02048b8:	000a8797          	auipc	a5,0xa8
ffffffffc02048bc:	ff878793          	addi	a5,a5,-8 # ffffffffc02ac8b0 <va_pa_offset>
ffffffffc02048c0:	6388                	ld	a0,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc02048c2:	000a8797          	auipc	a5,0xa8
ffffffffc02048c6:	f9678793          	addi	a5,a5,-106 # ffffffffc02ac858 <npage>
ffffffffc02048ca:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc02048cc:	8e89                	sub	a3,a3,a0
    if (PPN(pa) >= npage) {
ffffffffc02048ce:	82b1                	srli	a3,a3,0xc
ffffffffc02048d0:	04f6f063          	bgeu	a3,a5,ffffffffc0204910 <put_pgdir+0x66>
    return &pages[PPN(pa) - nbase];
ffffffffc02048d4:	00004797          	auipc	a5,0x4
ffffffffc02048d8:	8d478793          	addi	a5,a5,-1836 # ffffffffc02081a8 <nbase>
ffffffffc02048dc:	639c                	ld	a5,0(a5)
ffffffffc02048de:	000a8717          	auipc	a4,0xa8
ffffffffc02048e2:	fe270713          	addi	a4,a4,-30 # ffffffffc02ac8c0 <pages>
ffffffffc02048e6:	6308                	ld	a0,0(a4)
}
ffffffffc02048e8:	60a2                	ld	ra,8(sp)
ffffffffc02048ea:	8e9d                	sub	a3,a3,a5
ffffffffc02048ec:	069a                	slli	a3,a3,0x6
    free_page(kva2page(mm->pgdir));
ffffffffc02048ee:	4585                	li	a1,1
ffffffffc02048f0:	9536                	add	a0,a0,a3
}
ffffffffc02048f2:	0141                	addi	sp,sp,16
    free_page(kva2page(mm->pgdir));
ffffffffc02048f4:	dcafc06f          	j	ffffffffc0200ebe <free_pages>
    return pa2page(PADDR(kva));
ffffffffc02048f8:	00002617          	auipc	a2,0x2
ffffffffc02048fc:	d4060613          	addi	a2,a2,-704 # ffffffffc0206638 <commands+0x910>
ffffffffc0204900:	06e00593          	li	a1,110
ffffffffc0204904:	00002517          	auipc	a0,0x2
ffffffffc0204908:	cb450513          	addi	a0,a0,-844 # ffffffffc02065b8 <commands+0x890>
ffffffffc020490c:	909fb0ef          	jal	ra,ffffffffc0200214 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0204910:	00002617          	auipc	a2,0x2
ffffffffc0204914:	c8860613          	addi	a2,a2,-888 # ffffffffc0206598 <commands+0x870>
ffffffffc0204918:	06200593          	li	a1,98
ffffffffc020491c:	00002517          	auipc	a0,0x2
ffffffffc0204920:	c9c50513          	addi	a0,a0,-868 # ffffffffc02065b8 <commands+0x890>
ffffffffc0204924:	8f1fb0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0204928 <set_proc_name>:
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204928:	1101                	addi	sp,sp,-32
ffffffffc020492a:	e822                	sd	s0,16(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc020492c:	0b450413          	addi	s0,a0,180
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204930:	e426                	sd	s1,8(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204932:	4641                	li	a2,16
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204934:	84ae                	mv	s1,a1
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204936:	8522                	mv	a0,s0
ffffffffc0204938:	4581                	li	a1,0
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc020493a:	ec06                	sd	ra,24(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc020493c:	649000ef          	jal	ra,ffffffffc0205784 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204940:	8522                	mv	a0,s0
}
ffffffffc0204942:	6442                	ld	s0,16(sp)
ffffffffc0204944:	60e2                	ld	ra,24(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204946:	85a6                	mv	a1,s1
}
ffffffffc0204948:	64a2                	ld	s1,8(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc020494a:	463d                	li	a2,15
}
ffffffffc020494c:	6105                	addi	sp,sp,32
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc020494e:	6490006f          	j	ffffffffc0205796 <memcpy>

ffffffffc0204952 <proc_run>:
}
ffffffffc0204952:	8082                	ret

ffffffffc0204954 <find_proc>:
    if (0 < pid && pid < MAX_PID) {
ffffffffc0204954:	0005071b          	sext.w	a4,a0
ffffffffc0204958:	6789                	lui	a5,0x2
ffffffffc020495a:	fff7069b          	addiw	a3,a4,-1
ffffffffc020495e:	17f9                	addi	a5,a5,-2
ffffffffc0204960:	04d7e063          	bltu	a5,a3,ffffffffc02049a0 <find_proc+0x4c>
find_proc(int pid) {
ffffffffc0204964:	1141                	addi	sp,sp,-16
ffffffffc0204966:	e022                	sd	s0,0(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204968:	45a9                	li	a1,10
ffffffffc020496a:	842a                	mv	s0,a0
ffffffffc020496c:	853a                	mv	a0,a4
find_proc(int pid) {
ffffffffc020496e:	e406                	sd	ra,8(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204970:	22a010ef          	jal	ra,ffffffffc0205b9a <hash32>
ffffffffc0204974:	02051693          	slli	a3,a0,0x20
ffffffffc0204978:	82f1                	srli	a3,a3,0x1c
ffffffffc020497a:	000a4517          	auipc	a0,0xa4
ffffffffc020497e:	ec650513          	addi	a0,a0,-314 # ffffffffc02a8840 <hash_list>
ffffffffc0204982:	96aa                	add	a3,a3,a0
ffffffffc0204984:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list) {
ffffffffc0204986:	a029                	j	ffffffffc0204990 <find_proc+0x3c>
            if (proc->pid == pid) {
ffffffffc0204988:	f2c7a703          	lw	a4,-212(a5) # 1f2c <_binary_obj___user_faultread_out_size-0x769c>
ffffffffc020498c:	00870c63          	beq	a4,s0,ffffffffc02049a4 <find_proc+0x50>
    return listelm->next;
ffffffffc0204990:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0204992:	fef69be3          	bne	a3,a5,ffffffffc0204988 <find_proc+0x34>
}
ffffffffc0204996:	60a2                	ld	ra,8(sp)
ffffffffc0204998:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc020499a:	4501                	li	a0,0
}
ffffffffc020499c:	0141                	addi	sp,sp,16
ffffffffc020499e:	8082                	ret
    return NULL;
ffffffffc02049a0:	4501                	li	a0,0
}
ffffffffc02049a2:	8082                	ret
ffffffffc02049a4:	60a2                	ld	ra,8(sp)
ffffffffc02049a6:	6402                	ld	s0,0(sp)
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc02049a8:	f2878513          	addi	a0,a5,-216
}
ffffffffc02049ac:	0141                	addi	sp,sp,16
ffffffffc02049ae:	8082                	ret

ffffffffc02049b0 <kernel_thread>:
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc02049b0:	7169                	addi	sp,sp,-304
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc02049b2:	12000613          	li	a2,288
ffffffffc02049b6:	4581                	li	a1,0
ffffffffc02049b8:	850a                	mv	a0,sp
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc02049ba:	f606                	sd	ra,296(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc02049bc:	5c9000ef          	jal	ra,ffffffffc0205784 <memset>
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc02049c0:	100027f3          	csrr	a5,sstatus
    if (nr_process >= MAX_PROCESS) {
ffffffffc02049c4:	000a8797          	auipc	a5,0xa8
ffffffffc02049c8:	ed478793          	addi	a5,a5,-300 # ffffffffc02ac898 <nr_process>
ffffffffc02049cc:	4388                	lw	a0,0(a5)
}
ffffffffc02049ce:	70b2                	ld	ra,296(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc02049d0:	6785                	lui	a5,0x1
    int ret = -E_NO_FREE_PROC;
ffffffffc02049d2:	00f52533          	slt	a0,a0,a5
}
ffffffffc02049d6:	156d                	addi	a0,a0,-5
ffffffffc02049d8:	6155                	addi	sp,sp,304
ffffffffc02049da:	8082                	ret

ffffffffc02049dc <do_fork>:
    if (nr_process >= MAX_PROCESS) {
ffffffffc02049dc:	000a8797          	auipc	a5,0xa8
ffffffffc02049e0:	ebc78793          	addi	a5,a5,-324 # ffffffffc02ac898 <nr_process>
ffffffffc02049e4:	4388                	lw	a0,0(a5)
ffffffffc02049e6:	6785                	lui	a5,0x1
    int ret = -E_NO_FREE_PROC;
ffffffffc02049e8:	00f52533          	slt	a0,a0,a5
}
ffffffffc02049ec:	156d                	addi	a0,a0,-5
ffffffffc02049ee:	8082                	ret

ffffffffc02049f0 <do_exit>:
do_exit(int error_code) {
ffffffffc02049f0:	7179                	addi	sp,sp,-48
ffffffffc02049f2:	e84a                	sd	s2,16(sp)
    if (current == idleproc) {
ffffffffc02049f4:	000a8717          	auipc	a4,0xa8
ffffffffc02049f8:	e9470713          	addi	a4,a4,-364 # ffffffffc02ac888 <idleproc>
ffffffffc02049fc:	000a8917          	auipc	s2,0xa8
ffffffffc0204a00:	e8490913          	addi	s2,s2,-380 # ffffffffc02ac880 <current>
ffffffffc0204a04:	00093783          	ld	a5,0(s2)
ffffffffc0204a08:	6318                	ld	a4,0(a4)
do_exit(int error_code) {
ffffffffc0204a0a:	f406                	sd	ra,40(sp)
ffffffffc0204a0c:	f022                	sd	s0,32(sp)
ffffffffc0204a0e:	ec26                	sd	s1,24(sp)
ffffffffc0204a10:	e44e                	sd	s3,8(sp)
ffffffffc0204a12:	e052                	sd	s4,0(sp)
    if (current == idleproc) {
ffffffffc0204a14:	0ce78c63          	beq	a5,a4,ffffffffc0204aec <do_exit+0xfc>
    if (current == initproc) {
ffffffffc0204a18:	000a8417          	auipc	s0,0xa8
ffffffffc0204a1c:	e7840413          	addi	s0,s0,-392 # ffffffffc02ac890 <initproc>
ffffffffc0204a20:	6018                	ld	a4,0(s0)
ffffffffc0204a22:	0ee78b63          	beq	a5,a4,ffffffffc0204b18 <do_exit+0x128>
    struct mm_struct *mm = current->mm;
ffffffffc0204a26:	7784                	ld	s1,40(a5)
ffffffffc0204a28:	89aa                	mv	s3,a0
    if (mm != NULL) {
ffffffffc0204a2a:	c48d                	beqz	s1,ffffffffc0204a54 <do_exit+0x64>
        lcr3(boot_cr3);
ffffffffc0204a2c:	000a8797          	auipc	a5,0xa8
ffffffffc0204a30:	e8c78793          	addi	a5,a5,-372 # ffffffffc02ac8b8 <boot_cr3>

#define barrier() __asm__ __volatile__ ("fence" ::: "memory")

static inline void
lcr3(unsigned long cr3) {
    write_csr(satp, 0x8000000000000000 | (cr3 >> RISCV_PGSHIFT));
ffffffffc0204a34:	639c                	ld	a5,0(a5)
ffffffffc0204a36:	577d                	li	a4,-1
ffffffffc0204a38:	177e                	slli	a4,a4,0x3f
ffffffffc0204a3a:	83b1                	srli	a5,a5,0xc
ffffffffc0204a3c:	8fd9                	or	a5,a5,a4
ffffffffc0204a3e:	18079073          	csrw	satp,a5
    return mm->mm_count;
}

static inline int
mm_count_dec(struct mm_struct *mm) {
    mm->mm_count -= 1;
ffffffffc0204a42:	589c                	lw	a5,48(s1)
ffffffffc0204a44:	fff7871b          	addiw	a4,a5,-1
ffffffffc0204a48:	d898                	sw	a4,48(s1)
        if (mm_count_dec(mm) == 0) {
ffffffffc0204a4a:	cf4d                	beqz	a4,ffffffffc0204b04 <do_exit+0x114>
        current->mm = NULL;
ffffffffc0204a4c:	00093783          	ld	a5,0(s2)
ffffffffc0204a50:	0207b423          	sd	zero,40(a5)
    current->state = PROC_ZOMBIE;
ffffffffc0204a54:	00093783          	ld	a5,0(s2)
ffffffffc0204a58:	470d                	li	a4,3
ffffffffc0204a5a:	c398                	sw	a4,0(a5)
    current->exit_code = error_code;
ffffffffc0204a5c:	0f37a423          	sw	s3,232(a5)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204a60:	100027f3          	csrr	a5,sstatus
ffffffffc0204a64:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204a66:	4a01                	li	s4,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204a68:	e7e1                	bnez	a5,ffffffffc0204b30 <do_exit+0x140>
        proc = current->parent;
ffffffffc0204a6a:	00093703          	ld	a4,0(s2)
        if (proc->wait_state == WT_CHILD) {
ffffffffc0204a6e:	800007b7          	lui	a5,0x80000
ffffffffc0204a72:	0785                	addi	a5,a5,1
        proc = current->parent;
ffffffffc0204a74:	7308                	ld	a0,32(a4)
        if (proc->wait_state == WT_CHILD) {
ffffffffc0204a76:	0ec52703          	lw	a4,236(a0)
ffffffffc0204a7a:	0af70f63          	beq	a4,a5,ffffffffc0204b38 <do_exit+0x148>
ffffffffc0204a7e:	00093683          	ld	a3,0(s2)
                if (initproc->wait_state == WT_CHILD) {
ffffffffc0204a82:	800009b7          	lui	s3,0x80000
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0204a86:	448d                	li	s1,3
                if (initproc->wait_state == WT_CHILD) {
ffffffffc0204a88:	0985                	addi	s3,s3,1
        while (current->cptr != NULL) {
ffffffffc0204a8a:	7afc                	ld	a5,240(a3)
ffffffffc0204a8c:	cb95                	beqz	a5,ffffffffc0204ac0 <do_exit+0xd0>
            current->cptr = proc->optr;
ffffffffc0204a8e:	1007b703          	ld	a4,256(a5) # ffffffff80000100 <_binary_obj___user_exit_out_size+0xffffffff7fff5638>
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc0204a92:	6008                	ld	a0,0(s0)
            current->cptr = proc->optr;
ffffffffc0204a94:	faf8                	sd	a4,240(a3)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc0204a96:	7978                	ld	a4,240(a0)
            proc->yptr = NULL;
ffffffffc0204a98:	0e07bc23          	sd	zero,248(a5)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc0204a9c:	10e7b023          	sd	a4,256(a5)
ffffffffc0204aa0:	c311                	beqz	a4,ffffffffc0204aa4 <do_exit+0xb4>
                initproc->cptr->yptr = proc;
ffffffffc0204aa2:	ff7c                	sd	a5,248(a4)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0204aa4:	4398                	lw	a4,0(a5)
            proc->parent = initproc;
ffffffffc0204aa6:	f388                	sd	a0,32(a5)
            initproc->cptr = proc;
ffffffffc0204aa8:	f97c                	sd	a5,240(a0)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0204aaa:	fe9710e3          	bne	a4,s1,ffffffffc0204a8a <do_exit+0x9a>
                if (initproc->wait_state == WT_CHILD) {
ffffffffc0204aae:	0ec52783          	lw	a5,236(a0)
ffffffffc0204ab2:	fd379ce3          	bne	a5,s3,ffffffffc0204a8a <do_exit+0x9a>
                    wakeup_proc(initproc);
ffffffffc0204ab6:	23f000ef          	jal	ra,ffffffffc02054f4 <wakeup_proc>
ffffffffc0204aba:	00093683          	ld	a3,0(s2)
ffffffffc0204abe:	b7f1                	j	ffffffffc0204a8a <do_exit+0x9a>
    if (flag) {
ffffffffc0204ac0:	020a1363          	bnez	s4,ffffffffc0204ae6 <do_exit+0xf6>
    schedule();
ffffffffc0204ac4:	2ad000ef          	jal	ra,ffffffffc0205570 <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
ffffffffc0204ac8:	00093783          	ld	a5,0(s2)
ffffffffc0204acc:	00003617          	auipc	a2,0x3
ffffffffc0204ad0:	fac60613          	addi	a2,a2,-84 # ffffffffc0207a78 <default_pmm_manager+0x250>
ffffffffc0204ad4:	1d400593          	li	a1,468
ffffffffc0204ad8:	43d4                	lw	a3,4(a5)
ffffffffc0204ada:	00003517          	auipc	a0,0x3
ffffffffc0204ade:	20650513          	addi	a0,a0,518 # ffffffffc0207ce0 <default_pmm_manager+0x4b8>
ffffffffc0204ae2:	f32fb0ef          	jal	ra,ffffffffc0200214 <__panic>
        intr_enable();
ffffffffc0204ae6:	b45fb0ef          	jal	ra,ffffffffc020062a <intr_enable>
ffffffffc0204aea:	bfe9                	j	ffffffffc0204ac4 <do_exit+0xd4>
        panic("idleproc exit.\n");
ffffffffc0204aec:	00003617          	auipc	a2,0x3
ffffffffc0204af0:	f6c60613          	addi	a2,a2,-148 # ffffffffc0207a58 <default_pmm_manager+0x230>
ffffffffc0204af4:	1a800593          	li	a1,424
ffffffffc0204af8:	00003517          	auipc	a0,0x3
ffffffffc0204afc:	1e850513          	addi	a0,a0,488 # ffffffffc0207ce0 <default_pmm_manager+0x4b8>
ffffffffc0204b00:	f14fb0ef          	jal	ra,ffffffffc0200214 <__panic>
            exit_mmap(mm);
ffffffffc0204b04:	8526                	mv	a0,s1
ffffffffc0204b06:	8d7fd0ef          	jal	ra,ffffffffc02023dc <exit_mmap>
            put_pgdir(mm);
ffffffffc0204b0a:	8526                	mv	a0,s1
ffffffffc0204b0c:	d9fff0ef          	jal	ra,ffffffffc02048aa <put_pgdir>
            mm_destroy(mm);
ffffffffc0204b10:	8526                	mv	a0,s1
ffffffffc0204b12:	fc6fd0ef          	jal	ra,ffffffffc02022d8 <mm_destroy>
ffffffffc0204b16:	bf1d                	j	ffffffffc0204a4c <do_exit+0x5c>
        panic("initproc exit.\n");
ffffffffc0204b18:	00003617          	auipc	a2,0x3
ffffffffc0204b1c:	f5060613          	addi	a2,a2,-176 # ffffffffc0207a68 <default_pmm_manager+0x240>
ffffffffc0204b20:	1ab00593          	li	a1,427
ffffffffc0204b24:	00003517          	auipc	a0,0x3
ffffffffc0204b28:	1bc50513          	addi	a0,a0,444 # ffffffffc0207ce0 <default_pmm_manager+0x4b8>
ffffffffc0204b2c:	ee8fb0ef          	jal	ra,ffffffffc0200214 <__panic>
        intr_disable();
ffffffffc0204b30:	b01fb0ef          	jal	ra,ffffffffc0200630 <intr_disable>
        return 1;
ffffffffc0204b34:	4a05                	li	s4,1
ffffffffc0204b36:	bf15                	j	ffffffffc0204a6a <do_exit+0x7a>
            wakeup_proc(proc);
ffffffffc0204b38:	1bd000ef          	jal	ra,ffffffffc02054f4 <wakeup_proc>
ffffffffc0204b3c:	b789                	j	ffffffffc0204a7e <do_exit+0x8e>

ffffffffc0204b3e <do_wait.part.1>:
do_wait(int pid, int *code_store) {
ffffffffc0204b3e:	7139                	addi	sp,sp,-64
ffffffffc0204b40:	e852                	sd	s4,16(sp)
        current->wait_state = WT_CHILD;
ffffffffc0204b42:	80000a37          	lui	s4,0x80000
do_wait(int pid, int *code_store) {
ffffffffc0204b46:	f426                	sd	s1,40(sp)
ffffffffc0204b48:	f04a                	sd	s2,32(sp)
ffffffffc0204b4a:	ec4e                	sd	s3,24(sp)
ffffffffc0204b4c:	e456                	sd	s5,8(sp)
ffffffffc0204b4e:	e05a                	sd	s6,0(sp)
ffffffffc0204b50:	fc06                	sd	ra,56(sp)
ffffffffc0204b52:	f822                	sd	s0,48(sp)
ffffffffc0204b54:	89aa                	mv	s3,a0
ffffffffc0204b56:	8b2e                	mv	s6,a1
        proc = current->cptr;
ffffffffc0204b58:	000a8917          	auipc	s2,0xa8
ffffffffc0204b5c:	d2890913          	addi	s2,s2,-728 # ffffffffc02ac880 <current>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0204b60:	448d                	li	s1,3
        current->state = PROC_SLEEPING;
ffffffffc0204b62:	4a85                	li	s5,1
        current->wait_state = WT_CHILD;
ffffffffc0204b64:	0a05                	addi	s4,s4,1
    if (pid != 0) {
ffffffffc0204b66:	02098f63          	beqz	s3,ffffffffc0204ba4 <do_wait.part.1+0x66>
        proc = find_proc(pid);
ffffffffc0204b6a:	854e                	mv	a0,s3
ffffffffc0204b6c:	de9ff0ef          	jal	ra,ffffffffc0204954 <find_proc>
ffffffffc0204b70:	842a                	mv	s0,a0
        if (proc != NULL && proc->parent == current) {
ffffffffc0204b72:	12050063          	beqz	a0,ffffffffc0204c92 <do_wait.part.1+0x154>
ffffffffc0204b76:	00093703          	ld	a4,0(s2)
ffffffffc0204b7a:	711c                	ld	a5,32(a0)
ffffffffc0204b7c:	10e79b63          	bne	a5,a4,ffffffffc0204c92 <do_wait.part.1+0x154>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0204b80:	411c                	lw	a5,0(a0)
ffffffffc0204b82:	02978c63          	beq	a5,s1,ffffffffc0204bba <do_wait.part.1+0x7c>
        current->state = PROC_SLEEPING;
ffffffffc0204b86:	01572023          	sw	s5,0(a4)
        current->wait_state = WT_CHILD;
ffffffffc0204b8a:	0f472623          	sw	s4,236(a4)
        schedule();
ffffffffc0204b8e:	1e3000ef          	jal	ra,ffffffffc0205570 <schedule>
        if (current->flags & PF_EXITING) {
ffffffffc0204b92:	00093783          	ld	a5,0(s2)
ffffffffc0204b96:	0b07a783          	lw	a5,176(a5)
ffffffffc0204b9a:	8b85                	andi	a5,a5,1
ffffffffc0204b9c:	d7e9                	beqz	a5,ffffffffc0204b66 <do_wait.part.1+0x28>
            do_exit(-E_KILLED);
ffffffffc0204b9e:	555d                	li	a0,-9
ffffffffc0204ba0:	e51ff0ef          	jal	ra,ffffffffc02049f0 <do_exit>
        proc = current->cptr;
ffffffffc0204ba4:	00093703          	ld	a4,0(s2)
ffffffffc0204ba8:	7b60                	ld	s0,240(a4)
        for (; proc != NULL; proc = proc->optr) {
ffffffffc0204baa:	e409                	bnez	s0,ffffffffc0204bb4 <do_wait.part.1+0x76>
ffffffffc0204bac:	a0dd                	j	ffffffffc0204c92 <do_wait.part.1+0x154>
ffffffffc0204bae:	10043403          	ld	s0,256(s0)
ffffffffc0204bb2:	d871                	beqz	s0,ffffffffc0204b86 <do_wait.part.1+0x48>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0204bb4:	401c                	lw	a5,0(s0)
ffffffffc0204bb6:	fe979ce3          	bne	a5,s1,ffffffffc0204bae <do_wait.part.1+0x70>
    if (proc == idleproc || proc == initproc) {
ffffffffc0204bba:	000a8797          	auipc	a5,0xa8
ffffffffc0204bbe:	cce78793          	addi	a5,a5,-818 # ffffffffc02ac888 <idleproc>
ffffffffc0204bc2:	639c                	ld	a5,0(a5)
ffffffffc0204bc4:	0c878d63          	beq	a5,s0,ffffffffc0204c9e <do_wait.part.1+0x160>
ffffffffc0204bc8:	000a8797          	auipc	a5,0xa8
ffffffffc0204bcc:	cc878793          	addi	a5,a5,-824 # ffffffffc02ac890 <initproc>
ffffffffc0204bd0:	639c                	ld	a5,0(a5)
ffffffffc0204bd2:	0cf40663          	beq	s0,a5,ffffffffc0204c9e <do_wait.part.1+0x160>
    if (code_store != NULL) {
ffffffffc0204bd6:	000b0663          	beqz	s6,ffffffffc0204be2 <do_wait.part.1+0xa4>
        *code_store = proc->exit_code;
ffffffffc0204bda:	0e842783          	lw	a5,232(s0)
ffffffffc0204bde:	00fb2023          	sw	a5,0(s6)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204be2:	100027f3          	csrr	a5,sstatus
ffffffffc0204be6:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204be8:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204bea:	e7d5                	bnez	a5,ffffffffc0204c96 <do_wait.part.1+0x158>
    __list_del(listelm->prev, listelm->next);
ffffffffc0204bec:	6c70                	ld	a2,216(s0)
ffffffffc0204bee:	7074                	ld	a3,224(s0)
    if (proc->optr != NULL) {
ffffffffc0204bf0:	10043703          	ld	a4,256(s0)
ffffffffc0204bf4:	7c7c                	ld	a5,248(s0)
    prev->next = next;
ffffffffc0204bf6:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc0204bf8:	e290                	sd	a2,0(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0204bfa:	6470                	ld	a2,200(s0)
ffffffffc0204bfc:	6874                	ld	a3,208(s0)
    prev->next = next;
ffffffffc0204bfe:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc0204c00:	e290                	sd	a2,0(a3)
ffffffffc0204c02:	c319                	beqz	a4,ffffffffc0204c08 <do_wait.part.1+0xca>
        proc->optr->yptr = proc->yptr;
ffffffffc0204c04:	ff7c                	sd	a5,248(a4)
ffffffffc0204c06:	7c7c                	ld	a5,248(s0)
    if (proc->yptr != NULL) {
ffffffffc0204c08:	c3d1                	beqz	a5,ffffffffc0204c8c <do_wait.part.1+0x14e>
        proc->yptr->optr = proc->optr;
ffffffffc0204c0a:	10e7b023          	sd	a4,256(a5)
    nr_process --;
ffffffffc0204c0e:	000a8797          	auipc	a5,0xa8
ffffffffc0204c12:	c8a78793          	addi	a5,a5,-886 # ffffffffc02ac898 <nr_process>
ffffffffc0204c16:	439c                	lw	a5,0(a5)
ffffffffc0204c18:	37fd                	addiw	a5,a5,-1
ffffffffc0204c1a:	000a8717          	auipc	a4,0xa8
ffffffffc0204c1e:	c6f72f23          	sw	a5,-898(a4) # ffffffffc02ac898 <nr_process>
    if (flag) {
ffffffffc0204c22:	e1b5                	bnez	a1,ffffffffc0204c86 <do_wait.part.1+0x148>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc0204c24:	6814                	ld	a3,16(s0)
    return pa2page(PADDR(kva));
ffffffffc0204c26:	c02007b7          	lui	a5,0xc0200
ffffffffc0204c2a:	0af6e263          	bltu	a3,a5,ffffffffc0204cce <do_wait.part.1+0x190>
ffffffffc0204c2e:	000a8797          	auipc	a5,0xa8
ffffffffc0204c32:	c8278793          	addi	a5,a5,-894 # ffffffffc02ac8b0 <va_pa_offset>
ffffffffc0204c36:	6398                	ld	a4,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0204c38:	000a8797          	auipc	a5,0xa8
ffffffffc0204c3c:	c2078793          	addi	a5,a5,-992 # ffffffffc02ac858 <npage>
ffffffffc0204c40:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc0204c42:	8e99                	sub	a3,a3,a4
    if (PPN(pa) >= npage) {
ffffffffc0204c44:	82b1                	srli	a3,a3,0xc
ffffffffc0204c46:	06f6f863          	bgeu	a3,a5,ffffffffc0204cb6 <do_wait.part.1+0x178>
    return &pages[PPN(pa) - nbase];
ffffffffc0204c4a:	00003797          	auipc	a5,0x3
ffffffffc0204c4e:	55e78793          	addi	a5,a5,1374 # ffffffffc02081a8 <nbase>
ffffffffc0204c52:	639c                	ld	a5,0(a5)
ffffffffc0204c54:	000a8717          	auipc	a4,0xa8
ffffffffc0204c58:	c6c70713          	addi	a4,a4,-916 # ffffffffc02ac8c0 <pages>
ffffffffc0204c5c:	6308                	ld	a0,0(a4)
ffffffffc0204c5e:	8e9d                	sub	a3,a3,a5
ffffffffc0204c60:	069a                	slli	a3,a3,0x6
ffffffffc0204c62:	9536                	add	a0,a0,a3
ffffffffc0204c64:	4589                	li	a1,2
ffffffffc0204c66:	a58fc0ef          	jal	ra,ffffffffc0200ebe <free_pages>
    kfree(proc);
ffffffffc0204c6a:	8522                	mv	a0,s0
ffffffffc0204c6c:	a93fe0ef          	jal	ra,ffffffffc02036fe <kfree>
    return 0;
ffffffffc0204c70:	4501                	li	a0,0
}
ffffffffc0204c72:	70e2                	ld	ra,56(sp)
ffffffffc0204c74:	7442                	ld	s0,48(sp)
ffffffffc0204c76:	74a2                	ld	s1,40(sp)
ffffffffc0204c78:	7902                	ld	s2,32(sp)
ffffffffc0204c7a:	69e2                	ld	s3,24(sp)
ffffffffc0204c7c:	6a42                	ld	s4,16(sp)
ffffffffc0204c7e:	6aa2                	ld	s5,8(sp)
ffffffffc0204c80:	6b02                	ld	s6,0(sp)
ffffffffc0204c82:	6121                	addi	sp,sp,64
ffffffffc0204c84:	8082                	ret
        intr_enable();
ffffffffc0204c86:	9a5fb0ef          	jal	ra,ffffffffc020062a <intr_enable>
ffffffffc0204c8a:	bf69                	j	ffffffffc0204c24 <do_wait.part.1+0xe6>
       proc->parent->cptr = proc->optr;
ffffffffc0204c8c:	701c                	ld	a5,32(s0)
ffffffffc0204c8e:	fbf8                	sd	a4,240(a5)
ffffffffc0204c90:	bfbd                	j	ffffffffc0204c0e <do_wait.part.1+0xd0>
    return -E_BAD_PROC;
ffffffffc0204c92:	5579                	li	a0,-2
ffffffffc0204c94:	bff9                	j	ffffffffc0204c72 <do_wait.part.1+0x134>
        intr_disable();
ffffffffc0204c96:	99bfb0ef          	jal	ra,ffffffffc0200630 <intr_disable>
        return 1;
ffffffffc0204c9a:	4585                	li	a1,1
ffffffffc0204c9c:	bf81                	j	ffffffffc0204bec <do_wait.part.1+0xae>
        panic("wait idleproc or initproc.\n");
ffffffffc0204c9e:	00003617          	auipc	a2,0x3
ffffffffc0204ca2:	dfa60613          	addi	a2,a2,-518 # ffffffffc0207a98 <default_pmm_manager+0x270>
ffffffffc0204ca6:	2c900593          	li	a1,713
ffffffffc0204caa:	00003517          	auipc	a0,0x3
ffffffffc0204cae:	03650513          	addi	a0,a0,54 # ffffffffc0207ce0 <default_pmm_manager+0x4b8>
ffffffffc0204cb2:	d62fb0ef          	jal	ra,ffffffffc0200214 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0204cb6:	00002617          	auipc	a2,0x2
ffffffffc0204cba:	8e260613          	addi	a2,a2,-1822 # ffffffffc0206598 <commands+0x870>
ffffffffc0204cbe:	06200593          	li	a1,98
ffffffffc0204cc2:	00002517          	auipc	a0,0x2
ffffffffc0204cc6:	8f650513          	addi	a0,a0,-1802 # ffffffffc02065b8 <commands+0x890>
ffffffffc0204cca:	d4afb0ef          	jal	ra,ffffffffc0200214 <__panic>
    return pa2page(PADDR(kva));
ffffffffc0204cce:	00002617          	auipc	a2,0x2
ffffffffc0204cd2:	96a60613          	addi	a2,a2,-1686 # ffffffffc0206638 <commands+0x910>
ffffffffc0204cd6:	06e00593          	li	a1,110
ffffffffc0204cda:	00002517          	auipc	a0,0x2
ffffffffc0204cde:	8de50513          	addi	a0,a0,-1826 # ffffffffc02065b8 <commands+0x890>
ffffffffc0204ce2:	d32fb0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0204ce6 <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
ffffffffc0204ce6:	1141                	addi	sp,sp,-16
ffffffffc0204ce8:	e406                	sd	ra,8(sp)
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0204cea:	a1afc0ef          	jal	ra,ffffffffc0200f04 <nr_free_pages>
    size_t kernel_allocated_store = kallocated();
ffffffffc0204cee:	951fe0ef          	jal	ra,ffffffffc020363e <kallocated>

    int pid = kernel_thread(user_main, NULL, 0);
ffffffffc0204cf2:	4601                	li	a2,0
ffffffffc0204cf4:	4581                	li	a1,0
ffffffffc0204cf6:	00000517          	auipc	a0,0x0
ffffffffc0204cfa:	b3250513          	addi	a0,a0,-1230 # ffffffffc0204828 <user_main>
ffffffffc0204cfe:	cb3ff0ef          	jal	ra,ffffffffc02049b0 <kernel_thread>
    if (pid <= 0) {
ffffffffc0204d02:	00a04563          	bgtz	a0,ffffffffc0204d0c <init_main+0x26>
ffffffffc0204d06:	a841                	j	ffffffffc0204d96 <init_main+0xb0>
        panic("create user_main failed.\n");
    }

    while (do_wait(0, NULL) == 0) {
        schedule();
ffffffffc0204d08:	069000ef          	jal	ra,ffffffffc0205570 <schedule>
    if (code_store != NULL) {
ffffffffc0204d0c:	4581                	li	a1,0
ffffffffc0204d0e:	4501                	li	a0,0
ffffffffc0204d10:	e2fff0ef          	jal	ra,ffffffffc0204b3e <do_wait.part.1>
    while (do_wait(0, NULL) == 0) {
ffffffffc0204d14:	d975                	beqz	a0,ffffffffc0204d08 <init_main+0x22>
    }

    cprintf("all user-mode processes have quit.\n");
ffffffffc0204d16:	00003517          	auipc	a0,0x3
ffffffffc0204d1a:	dc250513          	addi	a0,a0,-574 # ffffffffc0207ad8 <default_pmm_manager+0x2b0>
ffffffffc0204d1e:	bb2fb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc0204d22:	000a8797          	auipc	a5,0xa8
ffffffffc0204d26:	b6e78793          	addi	a5,a5,-1170 # ffffffffc02ac890 <initproc>
ffffffffc0204d2a:	639c                	ld	a5,0(a5)
ffffffffc0204d2c:	7bf8                	ld	a4,240(a5)
ffffffffc0204d2e:	e721                	bnez	a4,ffffffffc0204d76 <init_main+0x90>
ffffffffc0204d30:	7ff8                	ld	a4,248(a5)
ffffffffc0204d32:	e331                	bnez	a4,ffffffffc0204d76 <init_main+0x90>
ffffffffc0204d34:	1007b703          	ld	a4,256(a5)
ffffffffc0204d38:	ef1d                	bnez	a4,ffffffffc0204d76 <init_main+0x90>
    assert(nr_process == 2);
ffffffffc0204d3a:	000a8717          	auipc	a4,0xa8
ffffffffc0204d3e:	b5e70713          	addi	a4,a4,-1186 # ffffffffc02ac898 <nr_process>
ffffffffc0204d42:	4314                	lw	a3,0(a4)
ffffffffc0204d44:	4709                	li	a4,2
ffffffffc0204d46:	0ae69463          	bne	a3,a4,ffffffffc0204dee <init_main+0x108>
    return listelm->next;
ffffffffc0204d4a:	000a8697          	auipc	a3,0xa8
ffffffffc0204d4e:	c7668693          	addi	a3,a3,-906 # ffffffffc02ac9c0 <proc_list>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc0204d52:	6698                	ld	a4,8(a3)
ffffffffc0204d54:	0c878793          	addi	a5,a5,200
ffffffffc0204d58:	06f71b63          	bne	a4,a5,ffffffffc0204dce <init_main+0xe8>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc0204d5c:	629c                	ld	a5,0(a3)
ffffffffc0204d5e:	04f71863          	bne	a4,a5,ffffffffc0204dae <init_main+0xc8>

    cprintf("init check memory pass.\n");
ffffffffc0204d62:	00003517          	auipc	a0,0x3
ffffffffc0204d66:	e5e50513          	addi	a0,a0,-418 # ffffffffc0207bc0 <default_pmm_manager+0x398>
ffffffffc0204d6a:	b66fb0ef          	jal	ra,ffffffffc02000d0 <cprintf>
    return 0;
}
ffffffffc0204d6e:	60a2                	ld	ra,8(sp)
ffffffffc0204d70:	4501                	li	a0,0
ffffffffc0204d72:	0141                	addi	sp,sp,16
ffffffffc0204d74:	8082                	ret
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc0204d76:	00003697          	auipc	a3,0x3
ffffffffc0204d7a:	d8a68693          	addi	a3,a3,-630 # ffffffffc0207b00 <default_pmm_manager+0x2d8>
ffffffffc0204d7e:	00001617          	auipc	a2,0x1
ffffffffc0204d82:	42a60613          	addi	a2,a2,1066 # ffffffffc02061a8 <commands+0x480>
ffffffffc0204d86:	32e00593          	li	a1,814
ffffffffc0204d8a:	00003517          	auipc	a0,0x3
ffffffffc0204d8e:	f5650513          	addi	a0,a0,-170 # ffffffffc0207ce0 <default_pmm_manager+0x4b8>
ffffffffc0204d92:	c82fb0ef          	jal	ra,ffffffffc0200214 <__panic>
        panic("create user_main failed.\n");
ffffffffc0204d96:	00003617          	auipc	a2,0x3
ffffffffc0204d9a:	d2260613          	addi	a2,a2,-734 # ffffffffc0207ab8 <default_pmm_manager+0x290>
ffffffffc0204d9e:	32600593          	li	a1,806
ffffffffc0204da2:	00003517          	auipc	a0,0x3
ffffffffc0204da6:	f3e50513          	addi	a0,a0,-194 # ffffffffc0207ce0 <default_pmm_manager+0x4b8>
ffffffffc0204daa:	c6afb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc0204dae:	00003697          	auipc	a3,0x3
ffffffffc0204db2:	de268693          	addi	a3,a3,-542 # ffffffffc0207b90 <default_pmm_manager+0x368>
ffffffffc0204db6:	00001617          	auipc	a2,0x1
ffffffffc0204dba:	3f260613          	addi	a2,a2,1010 # ffffffffc02061a8 <commands+0x480>
ffffffffc0204dbe:	33100593          	li	a1,817
ffffffffc0204dc2:	00003517          	auipc	a0,0x3
ffffffffc0204dc6:	f1e50513          	addi	a0,a0,-226 # ffffffffc0207ce0 <default_pmm_manager+0x4b8>
ffffffffc0204dca:	c4afb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc0204dce:	00003697          	auipc	a3,0x3
ffffffffc0204dd2:	d9268693          	addi	a3,a3,-622 # ffffffffc0207b60 <default_pmm_manager+0x338>
ffffffffc0204dd6:	00001617          	auipc	a2,0x1
ffffffffc0204dda:	3d260613          	addi	a2,a2,978 # ffffffffc02061a8 <commands+0x480>
ffffffffc0204dde:	33000593          	li	a1,816
ffffffffc0204de2:	00003517          	auipc	a0,0x3
ffffffffc0204de6:	efe50513          	addi	a0,a0,-258 # ffffffffc0207ce0 <default_pmm_manager+0x4b8>
ffffffffc0204dea:	c2afb0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(nr_process == 2);
ffffffffc0204dee:	00003697          	auipc	a3,0x3
ffffffffc0204df2:	d6268693          	addi	a3,a3,-670 # ffffffffc0207b50 <default_pmm_manager+0x328>
ffffffffc0204df6:	00001617          	auipc	a2,0x1
ffffffffc0204dfa:	3b260613          	addi	a2,a2,946 # ffffffffc02061a8 <commands+0x480>
ffffffffc0204dfe:	32f00593          	li	a1,815
ffffffffc0204e02:	00003517          	auipc	a0,0x3
ffffffffc0204e06:	ede50513          	addi	a0,a0,-290 # ffffffffc0207ce0 <default_pmm_manager+0x4b8>
ffffffffc0204e0a:	c0afb0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0204e0e <do_execve>:
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0204e0e:	7171                	addi	sp,sp,-176
ffffffffc0204e10:	fcd6                	sd	s5,120(sp)
    struct mm_struct *mm = current->mm;
ffffffffc0204e12:	000a8a97          	auipc	s5,0xa8
ffffffffc0204e16:	a6ea8a93          	addi	s5,s5,-1426 # ffffffffc02ac880 <current>
ffffffffc0204e1a:	000ab783          	ld	a5,0(s5)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0204e1e:	ed26                	sd	s1,152(sp)
ffffffffc0204e20:	f122                	sd	s0,160(sp)
    struct mm_struct *mm = current->mm;
ffffffffc0204e22:	7784                	ld	s1,40(a5)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0204e24:	e54e                	sd	s3,136(sp)
ffffffffc0204e26:	e8ea                	sd	s10,80(sp)
ffffffffc0204e28:	89aa                	mv	s3,a0
ffffffffc0204e2a:	842e                	mv	s0,a1
ffffffffc0204e2c:	8d32                	mv	s10,a2
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc0204e2e:	4681                	li	a3,0
ffffffffc0204e30:	862e                	mv	a2,a1
ffffffffc0204e32:	85aa                	mv	a1,a0
ffffffffc0204e34:	8526                	mv	a0,s1
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0204e36:	f506                	sd	ra,168(sp)
ffffffffc0204e38:	e94a                	sd	s2,144(sp)
ffffffffc0204e3a:	e152                	sd	s4,128(sp)
ffffffffc0204e3c:	f8da                	sd	s6,112(sp)
ffffffffc0204e3e:	f4de                	sd	s7,104(sp)
ffffffffc0204e40:	f0e2                	sd	s8,96(sp)
ffffffffc0204e42:	ece6                	sd	s9,88(sp)
ffffffffc0204e44:	e4ee                	sd	s11,72(sp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc0204e46:	c15fd0ef          	jal	ra,ffffffffc0202a5a <user_mem_check>
ffffffffc0204e4a:	3e050563          	beqz	a0,ffffffffc0205234 <do_execve+0x426>
    memset(local_name, 0, sizeof(local_name));
ffffffffc0204e4e:	4641                	li	a2,16
ffffffffc0204e50:	4581                	li	a1,0
ffffffffc0204e52:	1808                	addi	a0,sp,48
ffffffffc0204e54:	131000ef          	jal	ra,ffffffffc0205784 <memset>
    memcpy(local_name, name, len);
ffffffffc0204e58:	47bd                	li	a5,15
ffffffffc0204e5a:	8622                	mv	a2,s0
ffffffffc0204e5c:	1a87e863          	bltu	a5,s0,ffffffffc020500c <do_execve+0x1fe>
ffffffffc0204e60:	85ce                	mv	a1,s3
ffffffffc0204e62:	1808                	addi	a0,sp,48
ffffffffc0204e64:	133000ef          	jal	ra,ffffffffc0205796 <memcpy>
    if (mm != NULL) {
ffffffffc0204e68:	1a048963          	beqz	s1,ffffffffc020501a <do_execve+0x20c>
        cputs("mm != NULL");
ffffffffc0204e6c:	00002517          	auipc	a0,0x2
ffffffffc0204e70:	e9c50513          	addi	a0,a0,-356 # ffffffffc0206d08 <commands+0xfe0>
ffffffffc0204e74:	a92fb0ef          	jal	ra,ffffffffc0200106 <cputs>
        lcr3(boot_cr3);
ffffffffc0204e78:	000a8797          	auipc	a5,0xa8
ffffffffc0204e7c:	a4078793          	addi	a5,a5,-1472 # ffffffffc02ac8b8 <boot_cr3>
ffffffffc0204e80:	639c                	ld	a5,0(a5)
ffffffffc0204e82:	577d                	li	a4,-1
ffffffffc0204e84:	177e                	slli	a4,a4,0x3f
ffffffffc0204e86:	83b1                	srli	a5,a5,0xc
ffffffffc0204e88:	8fd9                	or	a5,a5,a4
ffffffffc0204e8a:	18079073          	csrw	satp,a5
ffffffffc0204e8e:	589c                	lw	a5,48(s1)
ffffffffc0204e90:	fff7871b          	addiw	a4,a5,-1
ffffffffc0204e94:	d898                	sw	a4,48(s1)
        if (mm_count_dec(mm) == 0) {
ffffffffc0204e96:	28070b63          	beqz	a4,ffffffffc020512c <do_execve+0x31e>
        current->mm = NULL;
ffffffffc0204e9a:	000ab783          	ld	a5,0(s5)
ffffffffc0204e9e:	0207b423          	sd	zero,40(a5)
    if ((mm = mm_create()) == NULL) {
ffffffffc0204ea2:	ab0fd0ef          	jal	ra,ffffffffc0202152 <mm_create>
ffffffffc0204ea6:	84aa                	mv	s1,a0
ffffffffc0204ea8:	1a050463          	beqz	a0,ffffffffc0205050 <do_execve+0x242>
    if ((page = alloc_page()) == NULL) {
ffffffffc0204eac:	4505                	li	a0,1
ffffffffc0204eae:	f89fb0ef          	jal	ra,ffffffffc0200e36 <alloc_pages>
ffffffffc0204eb2:	38050363          	beqz	a0,ffffffffc0205238 <do_execve+0x42a>
    return page - pages + nbase;
ffffffffc0204eb6:	000a8c17          	auipc	s8,0xa8
ffffffffc0204eba:	a0ac0c13          	addi	s8,s8,-1526 # ffffffffc02ac8c0 <pages>
ffffffffc0204ebe:	000c3683          	ld	a3,0(s8)
ffffffffc0204ec2:	00003797          	auipc	a5,0x3
ffffffffc0204ec6:	2e678793          	addi	a5,a5,742 # ffffffffc02081a8 <nbase>
ffffffffc0204eca:	6398                	ld	a4,0(a5)
ffffffffc0204ecc:	40d506b3          	sub	a3,a0,a3
    return KADDR(page2pa(page));
ffffffffc0204ed0:	000a8b97          	auipc	s7,0xa8
ffffffffc0204ed4:	988b8b93          	addi	s7,s7,-1656 # ffffffffc02ac858 <npage>
    return page - pages + nbase;
ffffffffc0204ed8:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0204eda:	5a7d                	li	s4,-1
ffffffffc0204edc:	000bb783          	ld	a5,0(s7)
    return page - pages + nbase;
ffffffffc0204ee0:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc0204ee2:	00ca5a13          	srli	s4,s4,0xc
    return page - pages + nbase;
ffffffffc0204ee6:	e43a                	sd	a4,8(sp)
    return KADDR(page2pa(page));
ffffffffc0204ee8:	0146f733          	and	a4,a3,s4
    return page2ppn(page) << PGSHIFT;
ffffffffc0204eec:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204eee:	34f77963          	bgeu	a4,a5,ffffffffc0205240 <do_execve+0x432>
ffffffffc0204ef2:	000a8997          	auipc	s3,0xa8
ffffffffc0204ef6:	9be98993          	addi	s3,s3,-1602 # ffffffffc02ac8b0 <va_pa_offset>
ffffffffc0204efa:	0009b403          	ld	s0,0(s3)
    memcpy(pgdir, boot_pgdir, PGSIZE);
ffffffffc0204efe:	000a8797          	auipc	a5,0xa8
ffffffffc0204f02:	95278793          	addi	a5,a5,-1710 # ffffffffc02ac850 <boot_pgdir>
ffffffffc0204f06:	638c                	ld	a1,0(a5)
ffffffffc0204f08:	9436                	add	s0,s0,a3
ffffffffc0204f0a:	6605                	lui	a2,0x1
ffffffffc0204f0c:	8522                	mv	a0,s0
ffffffffc0204f0e:	089000ef          	jal	ra,ffffffffc0205796 <memcpy>
    if (elf->e_magic != ELF_MAGIC) {
ffffffffc0204f12:	000d2703          	lw	a4,0(s10) # 1000 <_binary_obj___user_faultread_out_size-0x85c8>
ffffffffc0204f16:	464c47b7          	lui	a5,0x464c4
    mm->pgdir = pgdir;
ffffffffc0204f1a:	ec80                	sd	s0,24(s1)
    if (elf->e_magic != ELF_MAGIC) {
ffffffffc0204f1c:	57f78793          	addi	a5,a5,1407 # 464c457f <_binary_obj___user_exit_out_size+0x464b9ab7>
ffffffffc0204f20:	10f71e63          	bne	a4,a5,ffffffffc020503c <do_execve+0x22e>
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0204f24:	038d5703          	lhu	a4,56(s10)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0204f28:	020d3403          	ld	s0,32(s10)
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0204f2c:	00371793          	slli	a5,a4,0x3
ffffffffc0204f30:	8f99                	sub	a5,a5,a4
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0204f32:	946a                	add	s0,s0,s10
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0204f34:	078e                	slli	a5,a5,0x3
ffffffffc0204f36:	97a2                	add	a5,a5,s0
ffffffffc0204f38:	f43e                	sd	a5,40(sp)
    for (; ph < ph_end; ph ++) {
ffffffffc0204f3a:	00f47c63          	bgeu	s0,a5,ffffffffc0204f52 <do_execve+0x144>
ffffffffc0204f3e:	ec52                	sd	s4,24(sp)
        if (ph->p_type != ELF_PT_LOAD) {
ffffffffc0204f40:	401c                	lw	a5,0(s0)
ffffffffc0204f42:	4705                	li	a4,1
ffffffffc0204f44:	10e78863          	beq	a5,a4,ffffffffc0205054 <do_execve+0x246>
    for (; ph < ph_end; ph ++) {
ffffffffc0204f48:	77a2                	ld	a5,40(sp)
ffffffffc0204f4a:	03840413          	addi	s0,s0,56
ffffffffc0204f4e:	fef469e3          	bltu	s0,a5,ffffffffc0204f40 <do_execve+0x132>
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0) {
ffffffffc0204f52:	4701                	li	a4,0
ffffffffc0204f54:	46ad                	li	a3,11
ffffffffc0204f56:	00100637          	lui	a2,0x100
ffffffffc0204f5a:	7ff005b7          	lui	a1,0x7ff00
ffffffffc0204f5e:	8526                	mv	a0,s1
ffffffffc0204f60:	bcafd0ef          	jal	ra,ffffffffc020232a <mm_map>
ffffffffc0204f64:	8a2a                	mv	s4,a0
ffffffffc0204f66:	1a051963          	bnez	a0,ffffffffc0205118 <do_execve+0x30a>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc0204f6a:	6c88                	ld	a0,24(s1)
ffffffffc0204f6c:	467d                	li	a2,31
ffffffffc0204f6e:	7ffff5b7          	lui	a1,0x7ffff
ffffffffc0204f72:	928fd0ef          	jal	ra,ffffffffc020209a <pgdir_alloc_page>
ffffffffc0204f76:	34050d63          	beqz	a0,ffffffffc02052d0 <do_execve+0x4c2>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc0204f7a:	6c88                	ld	a0,24(s1)
ffffffffc0204f7c:	467d                	li	a2,31
ffffffffc0204f7e:	7fffe5b7          	lui	a1,0x7fffe
ffffffffc0204f82:	918fd0ef          	jal	ra,ffffffffc020209a <pgdir_alloc_page>
ffffffffc0204f86:	32050563          	beqz	a0,ffffffffc02052b0 <do_execve+0x4a2>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc0204f8a:	6c88                	ld	a0,24(s1)
ffffffffc0204f8c:	467d                	li	a2,31
ffffffffc0204f8e:	7fffd5b7          	lui	a1,0x7fffd
ffffffffc0204f92:	908fd0ef          	jal	ra,ffffffffc020209a <pgdir_alloc_page>
ffffffffc0204f96:	2e050d63          	beqz	a0,ffffffffc0205290 <do_execve+0x482>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc0204f9a:	6c88                	ld	a0,24(s1)
ffffffffc0204f9c:	467d                	li	a2,31
ffffffffc0204f9e:	7fffc5b7          	lui	a1,0x7fffc
ffffffffc0204fa2:	8f8fd0ef          	jal	ra,ffffffffc020209a <pgdir_alloc_page>
ffffffffc0204fa6:	2c050563          	beqz	a0,ffffffffc0205270 <do_execve+0x462>
    mm->mm_count += 1;
ffffffffc0204faa:	589c                	lw	a5,48(s1)
    current->mm = mm;
ffffffffc0204fac:	000ab603          	ld	a2,0(s5)
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0204fb0:	6c94                	ld	a3,24(s1)
ffffffffc0204fb2:	2785                	addiw	a5,a5,1
ffffffffc0204fb4:	d89c                	sw	a5,48(s1)
    current->mm = mm;
ffffffffc0204fb6:	f604                	sd	s1,40(a2)
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0204fb8:	c02007b7          	lui	a5,0xc0200
ffffffffc0204fbc:	28f6ee63          	bltu	a3,a5,ffffffffc0205258 <do_execve+0x44a>
ffffffffc0204fc0:	0009b783          	ld	a5,0(s3)
ffffffffc0204fc4:	577d                	li	a4,-1
ffffffffc0204fc6:	177e                	slli	a4,a4,0x3f
ffffffffc0204fc8:	8e9d                	sub	a3,a3,a5
ffffffffc0204fca:	00c6d793          	srli	a5,a3,0xc
ffffffffc0204fce:	f654                	sd	a3,168(a2)
ffffffffc0204fd0:	8fd9                	or	a5,a5,a4
ffffffffc0204fd2:	18079073          	csrw	satp,a5
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc0204fd6:	7248                	ld	a0,160(a2)
ffffffffc0204fd8:	4581                	li	a1,0
ffffffffc0204fda:	12000613          	li	a2,288
ffffffffc0204fde:	7a6000ef          	jal	ra,ffffffffc0205784 <memset>
    set_proc_name(current, local_name);
ffffffffc0204fe2:	000ab503          	ld	a0,0(s5)
ffffffffc0204fe6:	180c                	addi	a1,sp,48
ffffffffc0204fe8:	941ff0ef          	jal	ra,ffffffffc0204928 <set_proc_name>
}
ffffffffc0204fec:	70aa                	ld	ra,168(sp)
ffffffffc0204fee:	740a                	ld	s0,160(sp)
ffffffffc0204ff0:	8552                	mv	a0,s4
ffffffffc0204ff2:	64ea                	ld	s1,152(sp)
ffffffffc0204ff4:	694a                	ld	s2,144(sp)
ffffffffc0204ff6:	69aa                	ld	s3,136(sp)
ffffffffc0204ff8:	6a0a                	ld	s4,128(sp)
ffffffffc0204ffa:	7ae6                	ld	s5,120(sp)
ffffffffc0204ffc:	7b46                	ld	s6,112(sp)
ffffffffc0204ffe:	7ba6                	ld	s7,104(sp)
ffffffffc0205000:	7c06                	ld	s8,96(sp)
ffffffffc0205002:	6ce6                	ld	s9,88(sp)
ffffffffc0205004:	6d46                	ld	s10,80(sp)
ffffffffc0205006:	6da6                	ld	s11,72(sp)
ffffffffc0205008:	614d                	addi	sp,sp,176
ffffffffc020500a:	8082                	ret
    memcpy(local_name, name, len);
ffffffffc020500c:	463d                	li	a2,15
ffffffffc020500e:	85ce                	mv	a1,s3
ffffffffc0205010:	1808                	addi	a0,sp,48
ffffffffc0205012:	784000ef          	jal	ra,ffffffffc0205796 <memcpy>
    if (mm != NULL) {
ffffffffc0205016:	e4049be3          	bnez	s1,ffffffffc0204e6c <do_execve+0x5e>
    if (current->mm != NULL) {
ffffffffc020501a:	000ab783          	ld	a5,0(s5)
ffffffffc020501e:	779c                	ld	a5,40(a5)
ffffffffc0205020:	e80781e3          	beqz	a5,ffffffffc0204ea2 <do_execve+0x94>
        panic("load_icode: current->mm must be empty.\n");
ffffffffc0205024:	00003617          	auipc	a2,0x3
ffffffffc0205028:	8ac60613          	addi	a2,a2,-1876 # ffffffffc02078d0 <default_pmm_manager+0xa8>
ffffffffc020502c:	1de00593          	li	a1,478
ffffffffc0205030:	00003517          	auipc	a0,0x3
ffffffffc0205034:	cb050513          	addi	a0,a0,-848 # ffffffffc0207ce0 <default_pmm_manager+0x4b8>
ffffffffc0205038:	9dcfb0ef          	jal	ra,ffffffffc0200214 <__panic>
    put_pgdir(mm);
ffffffffc020503c:	8526                	mv	a0,s1
ffffffffc020503e:	86dff0ef          	jal	ra,ffffffffc02048aa <put_pgdir>
    mm_destroy(mm);
ffffffffc0205042:	8526                	mv	a0,s1
ffffffffc0205044:	a94fd0ef          	jal	ra,ffffffffc02022d8 <mm_destroy>
        ret = -E_INVAL_ELF;
ffffffffc0205048:	5a61                	li	s4,-8
    do_exit(ret);
ffffffffc020504a:	8552                	mv	a0,s4
ffffffffc020504c:	9a5ff0ef          	jal	ra,ffffffffc02049f0 <do_exit>
    int ret = -E_NO_MEM;
ffffffffc0205050:	5a71                	li	s4,-4
ffffffffc0205052:	bfe5                	j	ffffffffc020504a <do_execve+0x23c>
        if (ph->p_filesz > ph->p_memsz) {
ffffffffc0205054:	7410                	ld	a2,40(s0)
ffffffffc0205056:	701c                	ld	a5,32(s0)
ffffffffc0205058:	1ef66263          	bltu	a2,a5,ffffffffc020523c <do_execve+0x42e>
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
ffffffffc020505c:	405c                	lw	a5,4(s0)
ffffffffc020505e:	0017f693          	andi	a3,a5,1
ffffffffc0205062:	c291                	beqz	a3,ffffffffc0205066 <do_execve+0x258>
ffffffffc0205064:	4691                	li	a3,4
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205066:	0027f713          	andi	a4,a5,2
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc020506a:	8b91                	andi	a5,a5,4
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc020506c:	eb71                	bnez	a4,ffffffffc0205140 <do_execve+0x332>
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc020506e:	4745                	li	a4,17
ffffffffc0205070:	e83a                	sd	a4,16(sp)
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205072:	c789                	beqz	a5,ffffffffc020507c <do_execve+0x26e>
        if (vm_flags & VM_READ) perm |= PTE_R;
ffffffffc0205074:	47cd                	li	a5,19
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205076:	0016e693          	ori	a3,a3,1
        if (vm_flags & VM_READ) perm |= PTE_R;
ffffffffc020507a:	e83e                	sd	a5,16(sp)
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc020507c:	0026f793          	andi	a5,a3,2
ffffffffc0205080:	e3f9                	bnez	a5,ffffffffc0205146 <do_execve+0x338>
        if (vm_flags & VM_EXEC) perm |= PTE_X;
ffffffffc0205082:	0046f793          	andi	a5,a3,4
ffffffffc0205086:	c789                	beqz	a5,ffffffffc0205090 <do_execve+0x282>
ffffffffc0205088:	67c2                	ld	a5,16(sp)
ffffffffc020508a:	0087e793          	ori	a5,a5,8
ffffffffc020508e:	e83e                	sd	a5,16(sp)
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0) {
ffffffffc0205090:	680c                	ld	a1,16(s0)
ffffffffc0205092:	4701                	li	a4,0
ffffffffc0205094:	8526                	mv	a0,s1
ffffffffc0205096:	a94fd0ef          	jal	ra,ffffffffc020232a <mm_map>
ffffffffc020509a:	8a2a                	mv	s4,a0
ffffffffc020509c:	ed35                	bnez	a0,ffffffffc0205118 <do_execve+0x30a>
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc020509e:	01043d83          	ld	s11,16(s0)
        end = ph->p_va + ph->p_filesz;
ffffffffc02050a2:	02043a03          	ld	s4,32(s0)
        unsigned char *from = binary + ph->p_offset;
ffffffffc02050a6:	00843b03          	ld	s6,8(s0)
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc02050aa:	77fd                	lui	a5,0xfffff
        end = ph->p_va + ph->p_filesz;
ffffffffc02050ac:	9a6e                	add	s4,s4,s11
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc02050ae:	00fdfcb3          	and	s9,s11,a5
        unsigned char *from = binary + ph->p_offset;
ffffffffc02050b2:	9b6a                	add	s6,s6,s10
        while (start < end) {
ffffffffc02050b4:	054dea63          	bltu	s11,s4,ffffffffc0205108 <do_execve+0x2fa>
ffffffffc02050b8:	aaa5                	j	ffffffffc0205230 <do_execve+0x422>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc02050ba:	6785                	lui	a5,0x1
ffffffffc02050bc:	419d8533          	sub	a0,s11,s9
ffffffffc02050c0:	9cbe                	add	s9,s9,a5
ffffffffc02050c2:	41bc8833          	sub	a6,s9,s11
            if (end < la) {
ffffffffc02050c6:	019a7463          	bgeu	s4,s9,ffffffffc02050ce <do_execve+0x2c0>
                size -= la - end;
ffffffffc02050ca:	41ba0833          	sub	a6,s4,s11
    return page - pages + nbase;
ffffffffc02050ce:	000c3683          	ld	a3,0(s8)
ffffffffc02050d2:	67a2                	ld	a5,8(sp)
    return KADDR(page2pa(page));
ffffffffc02050d4:	000bb603          	ld	a2,0(s7)
    return page - pages + nbase;
ffffffffc02050d8:	40d906b3          	sub	a3,s2,a3
ffffffffc02050dc:	8699                	srai	a3,a3,0x6
ffffffffc02050de:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc02050e0:	67e2                	ld	a5,24(sp)
ffffffffc02050e2:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc02050e6:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02050e8:	14c5fc63          	bgeu	a1,a2,ffffffffc0205240 <do_execve+0x432>
ffffffffc02050ec:	0009b883          	ld	a7,0(s3)
            memcpy(page2kva(page) + off, from, size);
ffffffffc02050f0:	85da                	mv	a1,s6
ffffffffc02050f2:	8642                	mv	a2,a6
ffffffffc02050f4:	96c6                	add	a3,a3,a7
ffffffffc02050f6:	9536                	add	a0,a0,a3
            start += size, from += size;
ffffffffc02050f8:	9dc2                	add	s11,s11,a6
ffffffffc02050fa:	f042                	sd	a6,32(sp)
            memcpy(page2kva(page) + off, from, size);
ffffffffc02050fc:	69a000ef          	jal	ra,ffffffffc0205796 <memcpy>
            start += size, from += size;
ffffffffc0205100:	7802                	ld	a6,32(sp)
ffffffffc0205102:	9b42                	add	s6,s6,a6
        while (start < end) {
ffffffffc0205104:	054df463          	bgeu	s11,s4,ffffffffc020514c <do_execve+0x33e>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc0205108:	6c88                	ld	a0,24(s1)
ffffffffc020510a:	6642                	ld	a2,16(sp)
ffffffffc020510c:	85e6                	mv	a1,s9
ffffffffc020510e:	f8dfc0ef          	jal	ra,ffffffffc020209a <pgdir_alloc_page>
ffffffffc0205112:	892a                	mv	s2,a0
ffffffffc0205114:	f15d                	bnez	a0,ffffffffc02050ba <do_execve+0x2ac>
        ret = -E_NO_MEM;
ffffffffc0205116:	5a71                	li	s4,-4
    exit_mmap(mm);
ffffffffc0205118:	8526                	mv	a0,s1
ffffffffc020511a:	ac2fd0ef          	jal	ra,ffffffffc02023dc <exit_mmap>
    put_pgdir(mm);
ffffffffc020511e:	8526                	mv	a0,s1
ffffffffc0205120:	f8aff0ef          	jal	ra,ffffffffc02048aa <put_pgdir>
    mm_destroy(mm);
ffffffffc0205124:	8526                	mv	a0,s1
ffffffffc0205126:	9b2fd0ef          	jal	ra,ffffffffc02022d8 <mm_destroy>
    return ret;
ffffffffc020512a:	b705                	j	ffffffffc020504a <do_execve+0x23c>
            exit_mmap(mm);
ffffffffc020512c:	8526                	mv	a0,s1
ffffffffc020512e:	aaefd0ef          	jal	ra,ffffffffc02023dc <exit_mmap>
            put_pgdir(mm);
ffffffffc0205132:	8526                	mv	a0,s1
ffffffffc0205134:	f76ff0ef          	jal	ra,ffffffffc02048aa <put_pgdir>
            mm_destroy(mm);
ffffffffc0205138:	8526                	mv	a0,s1
ffffffffc020513a:	99efd0ef          	jal	ra,ffffffffc02022d8 <mm_destroy>
ffffffffc020513e:	bbb1                	j	ffffffffc0204e9a <do_execve+0x8c>
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205140:	0026e693          	ori	a3,a3,2
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205144:	fb85                	bnez	a5,ffffffffc0205074 <do_execve+0x266>
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc0205146:	47dd                	li	a5,23
ffffffffc0205148:	e83e                	sd	a5,16(sp)
ffffffffc020514a:	bf25                	j	ffffffffc0205082 <do_execve+0x274>
ffffffffc020514c:	01043a03          	ld	s4,16(s0)
        end = ph->p_va + ph->p_memsz;
ffffffffc0205150:	7414                	ld	a3,40(s0)
ffffffffc0205152:	9a36                	add	s4,s4,a3
        if (start < la) {
ffffffffc0205154:	079dfd63          	bgeu	s11,s9,ffffffffc02051ce <do_execve+0x3c0>
            if (start == end) {
ffffffffc0205158:	dfba08e3          	beq	s4,s11,ffffffffc0204f48 <do_execve+0x13a>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc020515c:	6785                	lui	a5,0x1
ffffffffc020515e:	00fd8533          	add	a0,s11,a5
ffffffffc0205162:	41950533          	sub	a0,a0,s9
                size -= la - end;
ffffffffc0205166:	41ba0b33          	sub	s6,s4,s11
            if (end < la) {
ffffffffc020516a:	0d9a7063          	bgeu	s4,s9,ffffffffc020522a <do_execve+0x41c>
    return page - pages + nbase;
ffffffffc020516e:	000c3683          	ld	a3,0(s8)
ffffffffc0205172:	67a2                	ld	a5,8(sp)
    return KADDR(page2pa(page));
ffffffffc0205174:	000bb603          	ld	a2,0(s7)
    return page - pages + nbase;
ffffffffc0205178:	40d906b3          	sub	a3,s2,a3
ffffffffc020517c:	8699                	srai	a3,a3,0x6
ffffffffc020517e:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0205180:	67e2                	ld	a5,24(sp)
ffffffffc0205182:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205186:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205188:	0ac5fc63          	bgeu	a1,a2,ffffffffc0205240 <do_execve+0x432>
ffffffffc020518c:	0009b803          	ld	a6,0(s3)
            memset(page2kva(page) + off, 0, size);
ffffffffc0205190:	865a                	mv	a2,s6
ffffffffc0205192:	4581                	li	a1,0
ffffffffc0205194:	96c2                	add	a3,a3,a6
ffffffffc0205196:	9536                	add	a0,a0,a3
ffffffffc0205198:	5ec000ef          	jal	ra,ffffffffc0205784 <memset>
            start += size;
ffffffffc020519c:	01bb07b3          	add	a5,s6,s11
            assert((end < la && start == end) || (end >= la && start == la));
ffffffffc02051a0:	039a7463          	bgeu	s4,s9,ffffffffc02051c8 <do_execve+0x3ba>
ffffffffc02051a4:	dafa02e3          	beq	s4,a5,ffffffffc0204f48 <do_execve+0x13a>
ffffffffc02051a8:	00002697          	auipc	a3,0x2
ffffffffc02051ac:	75068693          	addi	a3,a3,1872 # ffffffffc02078f8 <default_pmm_manager+0xd0>
ffffffffc02051b0:	00001617          	auipc	a2,0x1
ffffffffc02051b4:	ff860613          	addi	a2,a2,-8 # ffffffffc02061a8 <commands+0x480>
ffffffffc02051b8:	23300593          	li	a1,563
ffffffffc02051bc:	00003517          	auipc	a0,0x3
ffffffffc02051c0:	b2450513          	addi	a0,a0,-1244 # ffffffffc0207ce0 <default_pmm_manager+0x4b8>
ffffffffc02051c4:	850fb0ef          	jal	ra,ffffffffc0200214 <__panic>
ffffffffc02051c8:	ff9790e3          	bne	a5,s9,ffffffffc02051a8 <do_execve+0x39a>
ffffffffc02051cc:	8de6                	mv	s11,s9
        while (start < end) {
ffffffffc02051ce:	054de663          	bltu	s11,s4,ffffffffc020521a <do_execve+0x40c>
ffffffffc02051d2:	bb9d                	j	ffffffffc0204f48 <do_execve+0x13a>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc02051d4:	6785                	lui	a5,0x1
ffffffffc02051d6:	419d8533          	sub	a0,s11,s9
ffffffffc02051da:	9cbe                	add	s9,s9,a5
ffffffffc02051dc:	41bc8633          	sub	a2,s9,s11
            if (end < la) {
ffffffffc02051e0:	019a7463          	bgeu	s4,s9,ffffffffc02051e8 <do_execve+0x3da>
                size -= la - end;
ffffffffc02051e4:	41ba0633          	sub	a2,s4,s11
    return page - pages + nbase;
ffffffffc02051e8:	000c3683          	ld	a3,0(s8)
ffffffffc02051ec:	67a2                	ld	a5,8(sp)
    return KADDR(page2pa(page));
ffffffffc02051ee:	000bb583          	ld	a1,0(s7)
    return page - pages + nbase;
ffffffffc02051f2:	40d906b3          	sub	a3,s2,a3
ffffffffc02051f6:	8699                	srai	a3,a3,0x6
ffffffffc02051f8:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc02051fa:	67e2                	ld	a5,24(sp)
ffffffffc02051fc:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205200:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205202:	02b87f63          	bgeu	a6,a1,ffffffffc0205240 <do_execve+0x432>
ffffffffc0205206:	0009b803          	ld	a6,0(s3)
            start += size;
ffffffffc020520a:	9db2                	add	s11,s11,a2
            memset(page2kva(page) + off, 0, size);
ffffffffc020520c:	4581                	li	a1,0
ffffffffc020520e:	96c2                	add	a3,a3,a6
ffffffffc0205210:	9536                	add	a0,a0,a3
ffffffffc0205212:	572000ef          	jal	ra,ffffffffc0205784 <memset>
        while (start < end) {
ffffffffc0205216:	d34df9e3          	bgeu	s11,s4,ffffffffc0204f48 <do_execve+0x13a>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc020521a:	6c88                	ld	a0,24(s1)
ffffffffc020521c:	6642                	ld	a2,16(sp)
ffffffffc020521e:	85e6                	mv	a1,s9
ffffffffc0205220:	e7bfc0ef          	jal	ra,ffffffffc020209a <pgdir_alloc_page>
ffffffffc0205224:	892a                	mv	s2,a0
ffffffffc0205226:	f55d                	bnez	a0,ffffffffc02051d4 <do_execve+0x3c6>
ffffffffc0205228:	b5fd                	j	ffffffffc0205116 <do_execve+0x308>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc020522a:	41bc8b33          	sub	s6,s9,s11
ffffffffc020522e:	b781                	j	ffffffffc020516e <do_execve+0x360>
        while (start < end) {
ffffffffc0205230:	8a6e                	mv	s4,s11
ffffffffc0205232:	bf39                	j	ffffffffc0205150 <do_execve+0x342>
        return -E_INVAL;
ffffffffc0205234:	5a75                	li	s4,-3
ffffffffc0205236:	bb5d                	j	ffffffffc0204fec <do_execve+0x1de>
    int ret = -E_NO_MEM;
ffffffffc0205238:	5a71                	li	s4,-4
ffffffffc020523a:	b5ed                	j	ffffffffc0205124 <do_execve+0x316>
            ret = -E_INVAL_ELF;
ffffffffc020523c:	5a61                	li	s4,-8
ffffffffc020523e:	bde9                	j	ffffffffc0205118 <do_execve+0x30a>
ffffffffc0205240:	00001617          	auipc	a2,0x1
ffffffffc0205244:	32060613          	addi	a2,a2,800 # ffffffffc0206560 <commands+0x838>
ffffffffc0205248:	06900593          	li	a1,105
ffffffffc020524c:	00001517          	auipc	a0,0x1
ffffffffc0205250:	36c50513          	addi	a0,a0,876 # ffffffffc02065b8 <commands+0x890>
ffffffffc0205254:	fc1fa0ef          	jal	ra,ffffffffc0200214 <__panic>
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205258:	00001617          	auipc	a2,0x1
ffffffffc020525c:	3e060613          	addi	a2,a2,992 # ffffffffc0206638 <commands+0x910>
ffffffffc0205260:	24e00593          	li	a1,590
ffffffffc0205264:	00003517          	auipc	a0,0x3
ffffffffc0205268:	a7c50513          	addi	a0,a0,-1412 # ffffffffc0207ce0 <default_pmm_manager+0x4b8>
ffffffffc020526c:	fa9fa0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc0205270:	00002697          	auipc	a3,0x2
ffffffffc0205274:	7a068693          	addi	a3,a3,1952 # ffffffffc0207a10 <default_pmm_manager+0x1e8>
ffffffffc0205278:	00001617          	auipc	a2,0x1
ffffffffc020527c:	f3060613          	addi	a2,a2,-208 # ffffffffc02061a8 <commands+0x480>
ffffffffc0205280:	24900593          	li	a1,585
ffffffffc0205284:	00003517          	auipc	a0,0x3
ffffffffc0205288:	a5c50513          	addi	a0,a0,-1444 # ffffffffc0207ce0 <default_pmm_manager+0x4b8>
ffffffffc020528c:	f89fa0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc0205290:	00002697          	auipc	a3,0x2
ffffffffc0205294:	73868693          	addi	a3,a3,1848 # ffffffffc02079c8 <default_pmm_manager+0x1a0>
ffffffffc0205298:	00001617          	auipc	a2,0x1
ffffffffc020529c:	f1060613          	addi	a2,a2,-240 # ffffffffc02061a8 <commands+0x480>
ffffffffc02052a0:	24800593          	li	a1,584
ffffffffc02052a4:	00003517          	auipc	a0,0x3
ffffffffc02052a8:	a3c50513          	addi	a0,a0,-1476 # ffffffffc0207ce0 <default_pmm_manager+0x4b8>
ffffffffc02052ac:	f69fa0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc02052b0:	00002697          	auipc	a3,0x2
ffffffffc02052b4:	6d068693          	addi	a3,a3,1744 # ffffffffc0207980 <default_pmm_manager+0x158>
ffffffffc02052b8:	00001617          	auipc	a2,0x1
ffffffffc02052bc:	ef060613          	addi	a2,a2,-272 # ffffffffc02061a8 <commands+0x480>
ffffffffc02052c0:	24700593          	li	a1,583
ffffffffc02052c4:	00003517          	auipc	a0,0x3
ffffffffc02052c8:	a1c50513          	addi	a0,a0,-1508 # ffffffffc0207ce0 <default_pmm_manager+0x4b8>
ffffffffc02052cc:	f49fa0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc02052d0:	00002697          	auipc	a3,0x2
ffffffffc02052d4:	66868693          	addi	a3,a3,1640 # ffffffffc0207938 <default_pmm_manager+0x110>
ffffffffc02052d8:	00001617          	auipc	a2,0x1
ffffffffc02052dc:	ed060613          	addi	a2,a2,-304 # ffffffffc02061a8 <commands+0x480>
ffffffffc02052e0:	24600593          	li	a1,582
ffffffffc02052e4:	00003517          	auipc	a0,0x3
ffffffffc02052e8:	9fc50513          	addi	a0,a0,-1540 # ffffffffc0207ce0 <default_pmm_manager+0x4b8>
ffffffffc02052ec:	f29fa0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc02052f0 <do_yield>:
    current->need_resched = 1;
ffffffffc02052f0:	000a7797          	auipc	a5,0xa7
ffffffffc02052f4:	59078793          	addi	a5,a5,1424 # ffffffffc02ac880 <current>
ffffffffc02052f8:	639c                	ld	a5,0(a5)
ffffffffc02052fa:	4705                	li	a4,1
}
ffffffffc02052fc:	4501                	li	a0,0
    current->need_resched = 1;
ffffffffc02052fe:	ef98                	sd	a4,24(a5)
}
ffffffffc0205300:	8082                	ret

ffffffffc0205302 <do_wait>:
do_wait(int pid, int *code_store) {
ffffffffc0205302:	1101                	addi	sp,sp,-32
ffffffffc0205304:	e822                	sd	s0,16(sp)
ffffffffc0205306:	e426                	sd	s1,8(sp)
ffffffffc0205308:	ec06                	sd	ra,24(sp)
ffffffffc020530a:	842e                	mv	s0,a1
ffffffffc020530c:	84aa                	mv	s1,a0
    if (code_store != NULL) {
ffffffffc020530e:	cd81                	beqz	a1,ffffffffc0205326 <do_wait+0x24>
    struct mm_struct *mm = current->mm;
ffffffffc0205310:	000a7797          	auipc	a5,0xa7
ffffffffc0205314:	57078793          	addi	a5,a5,1392 # ffffffffc02ac880 <current>
ffffffffc0205318:	639c                	ld	a5,0(a5)
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1)) {
ffffffffc020531a:	4685                	li	a3,1
ffffffffc020531c:	4611                	li	a2,4
ffffffffc020531e:	7788                	ld	a0,40(a5)
ffffffffc0205320:	f3afd0ef          	jal	ra,ffffffffc0202a5a <user_mem_check>
ffffffffc0205324:	c909                	beqz	a0,ffffffffc0205336 <do_wait+0x34>
ffffffffc0205326:	85a2                	mv	a1,s0
}
ffffffffc0205328:	6442                	ld	s0,16(sp)
ffffffffc020532a:	60e2                	ld	ra,24(sp)
ffffffffc020532c:	8526                	mv	a0,s1
ffffffffc020532e:	64a2                	ld	s1,8(sp)
ffffffffc0205330:	6105                	addi	sp,sp,32
ffffffffc0205332:	80dff06f          	j	ffffffffc0204b3e <do_wait.part.1>
ffffffffc0205336:	60e2                	ld	ra,24(sp)
ffffffffc0205338:	6442                	ld	s0,16(sp)
ffffffffc020533a:	64a2                	ld	s1,8(sp)
ffffffffc020533c:	5575                	li	a0,-3
ffffffffc020533e:	6105                	addi	sp,sp,32
ffffffffc0205340:	8082                	ret

ffffffffc0205342 <do_kill>:
do_kill(int pid) {
ffffffffc0205342:	1141                	addi	sp,sp,-16
ffffffffc0205344:	e406                	sd	ra,8(sp)
ffffffffc0205346:	e022                	sd	s0,0(sp)
    if ((proc = find_proc(pid)) != NULL) {
ffffffffc0205348:	e0cff0ef          	jal	ra,ffffffffc0204954 <find_proc>
ffffffffc020534c:	cd0d                	beqz	a0,ffffffffc0205386 <do_kill+0x44>
        if (!(proc->flags & PF_EXITING)) {
ffffffffc020534e:	0b052703          	lw	a4,176(a0)
ffffffffc0205352:	00177693          	andi	a3,a4,1
ffffffffc0205356:	e695                	bnez	a3,ffffffffc0205382 <do_kill+0x40>
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205358:	0ec52683          	lw	a3,236(a0)
            proc->flags |= PF_EXITING;
ffffffffc020535c:	00176713          	ori	a4,a4,1
ffffffffc0205360:	0ae52823          	sw	a4,176(a0)
            return 0;
ffffffffc0205364:	4401                	li	s0,0
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205366:	0006c763          	bltz	a3,ffffffffc0205374 <do_kill+0x32>
}
ffffffffc020536a:	8522                	mv	a0,s0
ffffffffc020536c:	60a2                	ld	ra,8(sp)
ffffffffc020536e:	6402                	ld	s0,0(sp)
ffffffffc0205370:	0141                	addi	sp,sp,16
ffffffffc0205372:	8082                	ret
                wakeup_proc(proc);
ffffffffc0205374:	180000ef          	jal	ra,ffffffffc02054f4 <wakeup_proc>
}
ffffffffc0205378:	8522                	mv	a0,s0
ffffffffc020537a:	60a2                	ld	ra,8(sp)
ffffffffc020537c:	6402                	ld	s0,0(sp)
ffffffffc020537e:	0141                	addi	sp,sp,16
ffffffffc0205380:	8082                	ret
        return -E_KILLED;
ffffffffc0205382:	545d                	li	s0,-9
ffffffffc0205384:	b7dd                	j	ffffffffc020536a <do_kill+0x28>
    return -E_INVAL;
ffffffffc0205386:	5475                	li	s0,-3
ffffffffc0205388:	b7cd                	j	ffffffffc020536a <do_kill+0x28>

ffffffffc020538a <proc_init>:
    elm->prev = elm->next = elm;
ffffffffc020538a:	000a7797          	auipc	a5,0xa7
ffffffffc020538e:	63678793          	addi	a5,a5,1590 # ffffffffc02ac9c0 <proc_list>

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
ffffffffc0205392:	1101                	addi	sp,sp,-32
ffffffffc0205394:	000a7717          	auipc	a4,0xa7
ffffffffc0205398:	62f73a23          	sd	a5,1588(a4) # ffffffffc02ac9c8 <proc_list+0x8>
ffffffffc020539c:	000a7717          	auipc	a4,0xa7
ffffffffc02053a0:	62f73223          	sd	a5,1572(a4) # ffffffffc02ac9c0 <proc_list>
ffffffffc02053a4:	ec06                	sd	ra,24(sp)
ffffffffc02053a6:	e822                	sd	s0,16(sp)
ffffffffc02053a8:	e426                	sd	s1,8(sp)
ffffffffc02053aa:	000a3797          	auipc	a5,0xa3
ffffffffc02053ae:	49678793          	addi	a5,a5,1174 # ffffffffc02a8840 <hash_list>
ffffffffc02053b2:	000a7717          	auipc	a4,0xa7
ffffffffc02053b6:	48e70713          	addi	a4,a4,1166 # ffffffffc02ac840 <is_panic>
ffffffffc02053ba:	e79c                	sd	a5,8(a5)
ffffffffc02053bc:	e39c                	sd	a5,0(a5)
ffffffffc02053be:	07c1                	addi	a5,a5,16
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
ffffffffc02053c0:	fee79de3          	bne	a5,a4,ffffffffc02053ba <proc_init+0x30>
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc02053c4:	10800513          	li	a0,264
ffffffffc02053c8:	a7afe0ef          	jal	ra,ffffffffc0203642 <kmalloc>
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) {
ffffffffc02053cc:	000a7717          	auipc	a4,0xa7
ffffffffc02053d0:	4aa73e23          	sd	a0,1212(a4) # ffffffffc02ac888 <idleproc>
ffffffffc02053d4:	000a7497          	auipc	s1,0xa7
ffffffffc02053d8:	4b448493          	addi	s1,s1,1204 # ffffffffc02ac888 <idleproc>
ffffffffc02053dc:	c559                	beqz	a0,ffffffffc020546a <proc_init+0xe0>
        panic("cannot alloc idleproc.\n");
    }

    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc02053de:	4709                	li	a4,2
ffffffffc02053e0:	e118                	sd	a4,0(a0)
    idleproc->kstack = (uintptr_t)bootstack;
    idleproc->need_resched = 1;
ffffffffc02053e2:	4405                	li	s0,1
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc02053e4:	00004717          	auipc	a4,0x4
ffffffffc02053e8:	c1c70713          	addi	a4,a4,-996 # ffffffffc0209000 <bootstack>
    set_proc_name(idleproc, "idle");
ffffffffc02053ec:	00003597          	auipc	a1,0x3
ffffffffc02053f0:	80c58593          	addi	a1,a1,-2036 # ffffffffc0207bf8 <default_pmm_manager+0x3d0>
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc02053f4:	e918                	sd	a4,16(a0)
    idleproc->need_resched = 1;
ffffffffc02053f6:	ed00                	sd	s0,24(a0)
    set_proc_name(idleproc, "idle");
ffffffffc02053f8:	d30ff0ef          	jal	ra,ffffffffc0204928 <set_proc_name>
    nr_process ++;
ffffffffc02053fc:	000a7797          	auipc	a5,0xa7
ffffffffc0205400:	49c78793          	addi	a5,a5,1180 # ffffffffc02ac898 <nr_process>
ffffffffc0205404:	439c                	lw	a5,0(a5)

    current = idleproc;
ffffffffc0205406:	6098                	ld	a4,0(s1)

    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205408:	4601                	li	a2,0
    nr_process ++;
ffffffffc020540a:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc020540c:	4581                	li	a1,0
ffffffffc020540e:	00000517          	auipc	a0,0x0
ffffffffc0205412:	8d850513          	addi	a0,a0,-1832 # ffffffffc0204ce6 <init_main>
    nr_process ++;
ffffffffc0205416:	000a7697          	auipc	a3,0xa7
ffffffffc020541a:	48f6a123          	sw	a5,1154(a3) # ffffffffc02ac898 <nr_process>
    current = idleproc;
ffffffffc020541e:	000a7797          	auipc	a5,0xa7
ffffffffc0205422:	46e7b123          	sd	a4,1122(a5) # ffffffffc02ac880 <current>
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205426:	d8aff0ef          	jal	ra,ffffffffc02049b0 <kernel_thread>
    if (pid <= 0) {
ffffffffc020542a:	08a05c63          	blez	a0,ffffffffc02054c2 <proc_init+0x138>
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc020542e:	d26ff0ef          	jal	ra,ffffffffc0204954 <find_proc>
    set_proc_name(initproc, "init");
ffffffffc0205432:	00002597          	auipc	a1,0x2
ffffffffc0205436:	7ee58593          	addi	a1,a1,2030 # ffffffffc0207c20 <default_pmm_manager+0x3f8>
    initproc = find_proc(pid);
ffffffffc020543a:	000a7797          	auipc	a5,0xa7
ffffffffc020543e:	44a7bb23          	sd	a0,1110(a5) # ffffffffc02ac890 <initproc>
    set_proc_name(initproc, "init");
ffffffffc0205442:	ce6ff0ef          	jal	ra,ffffffffc0204928 <set_proc_name>

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205446:	609c                	ld	a5,0(s1)
ffffffffc0205448:	cfa9                	beqz	a5,ffffffffc02054a2 <proc_init+0x118>
ffffffffc020544a:	43dc                	lw	a5,4(a5)
ffffffffc020544c:	ebb9                	bnez	a5,ffffffffc02054a2 <proc_init+0x118>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc020544e:	000a7797          	auipc	a5,0xa7
ffffffffc0205452:	44278793          	addi	a5,a5,1090 # ffffffffc02ac890 <initproc>
ffffffffc0205456:	639c                	ld	a5,0(a5)
ffffffffc0205458:	c78d                	beqz	a5,ffffffffc0205482 <proc_init+0xf8>
ffffffffc020545a:	43dc                	lw	a5,4(a5)
ffffffffc020545c:	02879363          	bne	a5,s0,ffffffffc0205482 <proc_init+0xf8>
}
ffffffffc0205460:	60e2                	ld	ra,24(sp)
ffffffffc0205462:	6442                	ld	s0,16(sp)
ffffffffc0205464:	64a2                	ld	s1,8(sp)
ffffffffc0205466:	6105                	addi	sp,sp,32
ffffffffc0205468:	8082                	ret
        panic("cannot alloc idleproc.\n");
ffffffffc020546a:	00002617          	auipc	a2,0x2
ffffffffc020546e:	77660613          	addi	a2,a2,1910 # ffffffffc0207be0 <default_pmm_manager+0x3b8>
ffffffffc0205472:	34300593          	li	a1,835
ffffffffc0205476:	00003517          	auipc	a0,0x3
ffffffffc020547a:	86a50513          	addi	a0,a0,-1942 # ffffffffc0207ce0 <default_pmm_manager+0x4b8>
ffffffffc020547e:	d97fa0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205482:	00002697          	auipc	a3,0x2
ffffffffc0205486:	7ce68693          	addi	a3,a3,1998 # ffffffffc0207c50 <default_pmm_manager+0x428>
ffffffffc020548a:	00001617          	auipc	a2,0x1
ffffffffc020548e:	d1e60613          	addi	a2,a2,-738 # ffffffffc02061a8 <commands+0x480>
ffffffffc0205492:	35800593          	li	a1,856
ffffffffc0205496:	00003517          	auipc	a0,0x3
ffffffffc020549a:	84a50513          	addi	a0,a0,-1974 # ffffffffc0207ce0 <default_pmm_manager+0x4b8>
ffffffffc020549e:	d77fa0ef          	jal	ra,ffffffffc0200214 <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc02054a2:	00002697          	auipc	a3,0x2
ffffffffc02054a6:	78668693          	addi	a3,a3,1926 # ffffffffc0207c28 <default_pmm_manager+0x400>
ffffffffc02054aa:	00001617          	auipc	a2,0x1
ffffffffc02054ae:	cfe60613          	addi	a2,a2,-770 # ffffffffc02061a8 <commands+0x480>
ffffffffc02054b2:	35700593          	li	a1,855
ffffffffc02054b6:	00003517          	auipc	a0,0x3
ffffffffc02054ba:	82a50513          	addi	a0,a0,-2006 # ffffffffc0207ce0 <default_pmm_manager+0x4b8>
ffffffffc02054be:	d57fa0ef          	jal	ra,ffffffffc0200214 <__panic>
        panic("create init_main failed.\n");
ffffffffc02054c2:	00002617          	auipc	a2,0x2
ffffffffc02054c6:	73e60613          	addi	a2,a2,1854 # ffffffffc0207c00 <default_pmm_manager+0x3d8>
ffffffffc02054ca:	35100593          	li	a1,849
ffffffffc02054ce:	00003517          	auipc	a0,0x3
ffffffffc02054d2:	81250513          	addi	a0,a0,-2030 # ffffffffc0207ce0 <default_pmm_manager+0x4b8>
ffffffffc02054d6:	d3ffa0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc02054da <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
ffffffffc02054da:	1141                	addi	sp,sp,-16
ffffffffc02054dc:	e022                	sd	s0,0(sp)
ffffffffc02054de:	e406                	sd	ra,8(sp)
ffffffffc02054e0:	000a7417          	auipc	s0,0xa7
ffffffffc02054e4:	3a040413          	addi	s0,s0,928 # ffffffffc02ac880 <current>
    while (1) {
        if (current->need_resched) {
ffffffffc02054e8:	6018                	ld	a4,0(s0)
ffffffffc02054ea:	6f1c                	ld	a5,24(a4)
ffffffffc02054ec:	dffd                	beqz	a5,ffffffffc02054ea <cpu_idle+0x10>
            schedule();
ffffffffc02054ee:	082000ef          	jal	ra,ffffffffc0205570 <schedule>
ffffffffc02054f2:	bfdd                	j	ffffffffc02054e8 <cpu_idle+0xe>

ffffffffc02054f4 <wakeup_proc>:
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE);
ffffffffc02054f4:	4118                	lw	a4,0(a0)
wakeup_proc(struct proc_struct *proc) {
ffffffffc02054f6:	1101                	addi	sp,sp,-32
ffffffffc02054f8:	ec06                	sd	ra,24(sp)
ffffffffc02054fa:	e822                	sd	s0,16(sp)
    assert(proc->state != PROC_ZOMBIE);
ffffffffc02054fc:	478d                	li	a5,3
ffffffffc02054fe:	04f70a63          	beq	a4,a5,ffffffffc0205552 <wakeup_proc+0x5e>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205502:	100027f3          	csrr	a5,sstatus
ffffffffc0205506:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205508:	4401                	li	s0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020550a:	ef8d                	bnez	a5,ffffffffc0205544 <wakeup_proc+0x50>
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        if (proc->state != PROC_RUNNABLE) {
ffffffffc020550c:	4789                	li	a5,2
ffffffffc020550e:	00f70f63          	beq	a4,a5,ffffffffc020552c <wakeup_proc+0x38>
            proc->state = PROC_RUNNABLE;
ffffffffc0205512:	c11c                	sw	a5,0(a0)
            proc->wait_state = 0;
ffffffffc0205514:	0e052623          	sw	zero,236(a0)
    if (flag) {
ffffffffc0205518:	e409                	bnez	s0,ffffffffc0205522 <wakeup_proc+0x2e>
        else {
            warn("wakeup runnable process.\n");
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc020551a:	60e2                	ld	ra,24(sp)
ffffffffc020551c:	6442                	ld	s0,16(sp)
ffffffffc020551e:	6105                	addi	sp,sp,32
ffffffffc0205520:	8082                	ret
ffffffffc0205522:	6442                	ld	s0,16(sp)
ffffffffc0205524:	60e2                	ld	ra,24(sp)
ffffffffc0205526:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0205528:	902fb06f          	j	ffffffffc020062a <intr_enable>
            warn("wakeup runnable process.\n");
ffffffffc020552c:	00003617          	auipc	a2,0x3
ffffffffc0205530:	80460613          	addi	a2,a2,-2044 # ffffffffc0207d30 <default_pmm_manager+0x508>
ffffffffc0205534:	45c9                	li	a1,18
ffffffffc0205536:	00002517          	auipc	a0,0x2
ffffffffc020553a:	7e250513          	addi	a0,a0,2018 # ffffffffc0207d18 <default_pmm_manager+0x4f0>
ffffffffc020553e:	d43fa0ef          	jal	ra,ffffffffc0200280 <__warn>
ffffffffc0205542:	bfd9                	j	ffffffffc0205518 <wakeup_proc+0x24>
ffffffffc0205544:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0205546:	8eafb0ef          	jal	ra,ffffffffc0200630 <intr_disable>
        return 1;
ffffffffc020554a:	6522                	ld	a0,8(sp)
ffffffffc020554c:	4405                	li	s0,1
ffffffffc020554e:	4118                	lw	a4,0(a0)
ffffffffc0205550:	bf75                	j	ffffffffc020550c <wakeup_proc+0x18>
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205552:	00002697          	auipc	a3,0x2
ffffffffc0205556:	7a668693          	addi	a3,a3,1958 # ffffffffc0207cf8 <default_pmm_manager+0x4d0>
ffffffffc020555a:	00001617          	auipc	a2,0x1
ffffffffc020555e:	c4e60613          	addi	a2,a2,-946 # ffffffffc02061a8 <commands+0x480>
ffffffffc0205562:	45a5                	li	a1,9
ffffffffc0205564:	00002517          	auipc	a0,0x2
ffffffffc0205568:	7b450513          	addi	a0,a0,1972 # ffffffffc0207d18 <default_pmm_manager+0x4f0>
ffffffffc020556c:	ca9fa0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc0205570 <schedule>:

void
schedule(void) {
ffffffffc0205570:	1141                	addi	sp,sp,-16
ffffffffc0205572:	e406                	sd	ra,8(sp)
ffffffffc0205574:	e022                	sd	s0,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205576:	100027f3          	csrr	a5,sstatus
ffffffffc020557a:	8b89                	andi	a5,a5,2
ffffffffc020557c:	4401                	li	s0,0
ffffffffc020557e:	e3d1                	bnez	a5,ffffffffc0205602 <schedule+0x92>
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc0205580:	000a7797          	auipc	a5,0xa7
ffffffffc0205584:	30078793          	addi	a5,a5,768 # ffffffffc02ac880 <current>
ffffffffc0205588:	0007b883          	ld	a7,0(a5)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc020558c:	000a7797          	auipc	a5,0xa7
ffffffffc0205590:	2fc78793          	addi	a5,a5,764 # ffffffffc02ac888 <idleproc>
ffffffffc0205594:	6388                	ld	a0,0(a5)
        current->need_resched = 0;
ffffffffc0205596:	0008bc23          	sd	zero,24(a7)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc020559a:	04a88e63          	beq	a7,a0,ffffffffc02055f6 <schedule+0x86>
ffffffffc020559e:	0c888693          	addi	a3,a7,200
ffffffffc02055a2:	000a7617          	auipc	a2,0xa7
ffffffffc02055a6:	41e60613          	addi	a2,a2,1054 # ffffffffc02ac9c0 <proc_list>
        le = last;
ffffffffc02055aa:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;
ffffffffc02055ac:	4581                	li	a1,0
        do {
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE) {
ffffffffc02055ae:	4809                	li	a6,2
    return listelm->next;
ffffffffc02055b0:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list) {
ffffffffc02055b2:	00c78863          	beq	a5,a2,ffffffffc02055c2 <schedule+0x52>
                if (next->state == PROC_RUNNABLE) {
ffffffffc02055b6:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc02055ba:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE) {
ffffffffc02055be:	01070463          	beq	a4,a6,ffffffffc02055c6 <schedule+0x56>
                    break;
                }
            }
        } while (le != last);
ffffffffc02055c2:	fef697e3          	bne	a3,a5,ffffffffc02055b0 <schedule+0x40>
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc02055c6:	c589                	beqz	a1,ffffffffc02055d0 <schedule+0x60>
ffffffffc02055c8:	4198                	lw	a4,0(a1)
ffffffffc02055ca:	4789                	li	a5,2
ffffffffc02055cc:	00f70e63          	beq	a4,a5,ffffffffc02055e8 <schedule+0x78>
            next = idleproc;
        }
        next->runs ++;
ffffffffc02055d0:	451c                	lw	a5,8(a0)
ffffffffc02055d2:	2785                	addiw	a5,a5,1
ffffffffc02055d4:	c51c                	sw	a5,8(a0)
        if (next != current) {
ffffffffc02055d6:	00a88463          	beq	a7,a0,ffffffffc02055de <schedule+0x6e>
            proc_run(next);
ffffffffc02055da:	b78ff0ef          	jal	ra,ffffffffc0204952 <proc_run>
    if (flag) {
ffffffffc02055de:	e419                	bnez	s0,ffffffffc02055ec <schedule+0x7c>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc02055e0:	60a2                	ld	ra,8(sp)
ffffffffc02055e2:	6402                	ld	s0,0(sp)
ffffffffc02055e4:	0141                	addi	sp,sp,16
ffffffffc02055e6:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc02055e8:	852e                	mv	a0,a1
ffffffffc02055ea:	b7dd                	j	ffffffffc02055d0 <schedule+0x60>
}
ffffffffc02055ec:	6402                	ld	s0,0(sp)
ffffffffc02055ee:	60a2                	ld	ra,8(sp)
ffffffffc02055f0:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc02055f2:	838fb06f          	j	ffffffffc020062a <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc02055f6:	000a7617          	auipc	a2,0xa7
ffffffffc02055fa:	3ca60613          	addi	a2,a2,970 # ffffffffc02ac9c0 <proc_list>
ffffffffc02055fe:	86b2                	mv	a3,a2
ffffffffc0205600:	b76d                	j	ffffffffc02055aa <schedule+0x3a>
        intr_disable();
ffffffffc0205602:	82efb0ef          	jal	ra,ffffffffc0200630 <intr_disable>
        return 1;
ffffffffc0205606:	4405                	li	s0,1
ffffffffc0205608:	bfa5                	j	ffffffffc0205580 <schedule+0x10>

ffffffffc020560a <sys_getpid>:
    return do_kill(pid);
}

static int
sys_getpid(uint64_t arg[]) {
    return current->pid;
ffffffffc020560a:	000a7797          	auipc	a5,0xa7
ffffffffc020560e:	27678793          	addi	a5,a5,630 # ffffffffc02ac880 <current>
ffffffffc0205612:	639c                	ld	a5,0(a5)
}
ffffffffc0205614:	43c8                	lw	a0,4(a5)
ffffffffc0205616:	8082                	ret

ffffffffc0205618 <sys_pgdir>:

static int
sys_pgdir(uint64_t arg[]) {
    //print_pgdir();
    return 0;
}
ffffffffc0205618:	4501                	li	a0,0
ffffffffc020561a:	8082                	ret

ffffffffc020561c <sys_putc>:
    cputchar(c);
ffffffffc020561c:	4108                	lw	a0,0(a0)
sys_putc(uint64_t arg[]) {
ffffffffc020561e:	1141                	addi	sp,sp,-16
ffffffffc0205620:	e406                	sd	ra,8(sp)
    cputchar(c);
ffffffffc0205622:	ae3fa0ef          	jal	ra,ffffffffc0200104 <cputchar>
}
ffffffffc0205626:	60a2                	ld	ra,8(sp)
ffffffffc0205628:	4501                	li	a0,0
ffffffffc020562a:	0141                	addi	sp,sp,16
ffffffffc020562c:	8082                	ret

ffffffffc020562e <sys_kill>:
    return do_kill(pid);
ffffffffc020562e:	4108                	lw	a0,0(a0)
ffffffffc0205630:	d13ff06f          	j	ffffffffc0205342 <do_kill>

ffffffffc0205634 <sys_yield>:
    return do_yield();
ffffffffc0205634:	cbdff06f          	j	ffffffffc02052f0 <do_yield>

ffffffffc0205638 <sys_exec>:
    return do_execve(name, len, binary, size);
ffffffffc0205638:	6d14                	ld	a3,24(a0)
ffffffffc020563a:	6910                	ld	a2,16(a0)
ffffffffc020563c:	650c                	ld	a1,8(a0)
ffffffffc020563e:	6108                	ld	a0,0(a0)
ffffffffc0205640:	fceff06f          	j	ffffffffc0204e0e <do_execve>

ffffffffc0205644 <sys_wait>:
    return do_wait(pid, store);
ffffffffc0205644:	650c                	ld	a1,8(a0)
ffffffffc0205646:	4108                	lw	a0,0(a0)
ffffffffc0205648:	cbbff06f          	j	ffffffffc0205302 <do_wait>

ffffffffc020564c <sys_fork>:
    struct trapframe *tf = current->tf;
ffffffffc020564c:	000a7797          	auipc	a5,0xa7
ffffffffc0205650:	23478793          	addi	a5,a5,564 # ffffffffc02ac880 <current>
ffffffffc0205654:	639c                	ld	a5,0(a5)
    return do_fork(0, stack, tf);
ffffffffc0205656:	4501                	li	a0,0
    struct trapframe *tf = current->tf;
ffffffffc0205658:	73d0                	ld	a2,160(a5)
    return do_fork(0, stack, tf);
ffffffffc020565a:	6a0c                	ld	a1,16(a2)
ffffffffc020565c:	b80ff06f          	j	ffffffffc02049dc <do_fork>

ffffffffc0205660 <sys_exit>:
    return do_exit(error_code);
ffffffffc0205660:	4108                	lw	a0,0(a0)
ffffffffc0205662:	b8eff06f          	j	ffffffffc02049f0 <do_exit>

ffffffffc0205666 <syscall>:
};

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

void
syscall(void) {
ffffffffc0205666:	715d                	addi	sp,sp,-80
ffffffffc0205668:	fc26                	sd	s1,56(sp)
    struct trapframe *tf = current->tf;
ffffffffc020566a:	000a7497          	auipc	s1,0xa7
ffffffffc020566e:	21648493          	addi	s1,s1,534 # ffffffffc02ac880 <current>
ffffffffc0205672:	6098                	ld	a4,0(s1)
syscall(void) {
ffffffffc0205674:	e0a2                	sd	s0,64(sp)
ffffffffc0205676:	f84a                	sd	s2,48(sp)
    struct trapframe *tf = current->tf;
ffffffffc0205678:	7340                	ld	s0,160(a4)
syscall(void) {
ffffffffc020567a:	e486                	sd	ra,72(sp)
    uint64_t arg[5];
    int num = tf->gpr.a0;
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc020567c:	47fd                	li	a5,31
    int num = tf->gpr.a0;
ffffffffc020567e:	05042903          	lw	s2,80(s0)
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc0205682:	0327ee63          	bltu	a5,s2,ffffffffc02056be <syscall+0x58>
        if (syscalls[num] != NULL) {
ffffffffc0205686:	00391713          	slli	a4,s2,0x3
ffffffffc020568a:	00002797          	auipc	a5,0x2
ffffffffc020568e:	70e78793          	addi	a5,a5,1806 # ffffffffc0207d98 <syscalls>
ffffffffc0205692:	97ba                	add	a5,a5,a4
ffffffffc0205694:	639c                	ld	a5,0(a5)
ffffffffc0205696:	c785                	beqz	a5,ffffffffc02056be <syscall+0x58>
            arg[0] = tf->gpr.a1;
ffffffffc0205698:	6c28                	ld	a0,88(s0)
            arg[1] = tf->gpr.a2;
ffffffffc020569a:	702c                	ld	a1,96(s0)
            arg[2] = tf->gpr.a3;
ffffffffc020569c:	7430                	ld	a2,104(s0)
            arg[3] = tf->gpr.a4;
ffffffffc020569e:	7834                	ld	a3,112(s0)
            arg[4] = tf->gpr.a5;
ffffffffc02056a0:	7c38                	ld	a4,120(s0)
            arg[0] = tf->gpr.a1;
ffffffffc02056a2:	e42a                	sd	a0,8(sp)
            arg[1] = tf->gpr.a2;
ffffffffc02056a4:	e82e                	sd	a1,16(sp)
            arg[2] = tf->gpr.a3;
ffffffffc02056a6:	ec32                	sd	a2,24(sp)
            arg[3] = tf->gpr.a4;
ffffffffc02056a8:	f036                	sd	a3,32(sp)
            arg[4] = tf->gpr.a5;
ffffffffc02056aa:	f43a                	sd	a4,40(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc02056ac:	0028                	addi	a0,sp,8
ffffffffc02056ae:	9782                	jalr	a5
ffffffffc02056b0:	e828                	sd	a0,80(s0)
        }
    }
    print_trapframe(tf);
    panic("undefined syscall %d, pid = %d, name = %s.\n",
            num, current->pid, current->name);
}
ffffffffc02056b2:	60a6                	ld	ra,72(sp)
ffffffffc02056b4:	6406                	ld	s0,64(sp)
ffffffffc02056b6:	74e2                	ld	s1,56(sp)
ffffffffc02056b8:	7942                	ld	s2,48(sp)
ffffffffc02056ba:	6161                	addi	sp,sp,80
ffffffffc02056bc:	8082                	ret
    print_trapframe(tf);
ffffffffc02056be:	8522                	mv	a0,s0
ffffffffc02056c0:	95efb0ef          	jal	ra,ffffffffc020081e <print_trapframe>
    panic("undefined syscall %d, pid = %d, name = %s.\n",
ffffffffc02056c4:	609c                	ld	a5,0(s1)
ffffffffc02056c6:	86ca                	mv	a3,s2
ffffffffc02056c8:	00002617          	auipc	a2,0x2
ffffffffc02056cc:	68860613          	addi	a2,a2,1672 # ffffffffc0207d50 <default_pmm_manager+0x528>
ffffffffc02056d0:	43d8                	lw	a4,4(a5)
ffffffffc02056d2:	06300593          	li	a1,99
ffffffffc02056d6:	0b478793          	addi	a5,a5,180
ffffffffc02056da:	00002517          	auipc	a0,0x2
ffffffffc02056de:	6a650513          	addi	a0,a0,1702 # ffffffffc0207d80 <default_pmm_manager+0x558>
ffffffffc02056e2:	b33fa0ef          	jal	ra,ffffffffc0200214 <__panic>

ffffffffc02056e6 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc02056e6:	00054783          	lbu	a5,0(a0)
ffffffffc02056ea:	cb91                	beqz	a5,ffffffffc02056fe <strlen+0x18>
    size_t cnt = 0;
ffffffffc02056ec:	4781                	li	a5,0
        cnt ++;
ffffffffc02056ee:	0785                	addi	a5,a5,1
    while (*s ++ != '\0') {
ffffffffc02056f0:	00f50733          	add	a4,a0,a5
ffffffffc02056f4:	00074703          	lbu	a4,0(a4)
ffffffffc02056f8:	fb7d                	bnez	a4,ffffffffc02056ee <strlen+0x8>
    }
    return cnt;
}
ffffffffc02056fa:	853e                	mv	a0,a5
ffffffffc02056fc:	8082                	ret
    size_t cnt = 0;
ffffffffc02056fe:	4781                	li	a5,0
}
ffffffffc0205700:	853e                	mv	a0,a5
ffffffffc0205702:	8082                	ret

ffffffffc0205704 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc0205704:	c185                	beqz	a1,ffffffffc0205724 <strnlen+0x20>
ffffffffc0205706:	00054783          	lbu	a5,0(a0)
ffffffffc020570a:	cf89                	beqz	a5,ffffffffc0205724 <strnlen+0x20>
    size_t cnt = 0;
ffffffffc020570c:	4781                	li	a5,0
ffffffffc020570e:	a021                	j	ffffffffc0205716 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc0205710:	00074703          	lbu	a4,0(a4)
ffffffffc0205714:	c711                	beqz	a4,ffffffffc0205720 <strnlen+0x1c>
        cnt ++;
ffffffffc0205716:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0205718:	00f50733          	add	a4,a0,a5
ffffffffc020571c:	fef59ae3          	bne	a1,a5,ffffffffc0205710 <strnlen+0xc>
    }
    return cnt;
}
ffffffffc0205720:	853e                	mv	a0,a5
ffffffffc0205722:	8082                	ret
    size_t cnt = 0;
ffffffffc0205724:	4781                	li	a5,0
}
ffffffffc0205726:	853e                	mv	a0,a5
ffffffffc0205728:	8082                	ret

ffffffffc020572a <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc020572a:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc020572c:	0585                	addi	a1,a1,1
ffffffffc020572e:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0205732:	0785                	addi	a5,a5,1
ffffffffc0205734:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0205738:	fb75                	bnez	a4,ffffffffc020572c <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc020573a:	8082                	ret

ffffffffc020573c <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020573c:	00054783          	lbu	a5,0(a0)
ffffffffc0205740:	0005c703          	lbu	a4,0(a1)
ffffffffc0205744:	cb91                	beqz	a5,ffffffffc0205758 <strcmp+0x1c>
ffffffffc0205746:	00e79c63          	bne	a5,a4,ffffffffc020575e <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc020574a:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020574c:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc0205750:	0585                	addi	a1,a1,1
ffffffffc0205752:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0205756:	fbe5                	bnez	a5,ffffffffc0205746 <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0205758:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc020575a:	9d19                	subw	a0,a0,a4
ffffffffc020575c:	8082                	ret
ffffffffc020575e:	0007851b          	sext.w	a0,a5
ffffffffc0205762:	9d19                	subw	a0,a0,a4
ffffffffc0205764:	8082                	ret

ffffffffc0205766 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0205766:	00054783          	lbu	a5,0(a0)
ffffffffc020576a:	cb91                	beqz	a5,ffffffffc020577e <strchr+0x18>
        if (*s == c) {
ffffffffc020576c:	00b79563          	bne	a5,a1,ffffffffc0205776 <strchr+0x10>
ffffffffc0205770:	a809                	j	ffffffffc0205782 <strchr+0x1c>
ffffffffc0205772:	00b78763          	beq	a5,a1,ffffffffc0205780 <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc0205776:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0205778:	00054783          	lbu	a5,0(a0)
ffffffffc020577c:	fbfd                	bnez	a5,ffffffffc0205772 <strchr+0xc>
    }
    return NULL;
ffffffffc020577e:	4501                	li	a0,0
}
ffffffffc0205780:	8082                	ret
ffffffffc0205782:	8082                	ret

ffffffffc0205784 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0205784:	ca01                	beqz	a2,ffffffffc0205794 <memset+0x10>
ffffffffc0205786:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0205788:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc020578a:	0785                	addi	a5,a5,1
ffffffffc020578c:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0205790:	fec79de3          	bne	a5,a2,ffffffffc020578a <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0205794:	8082                	ret

ffffffffc0205796 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0205796:	ca19                	beqz	a2,ffffffffc02057ac <memcpy+0x16>
ffffffffc0205798:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc020579a:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc020579c:	0585                	addi	a1,a1,1
ffffffffc020579e:	fff5c703          	lbu	a4,-1(a1)
ffffffffc02057a2:	0785                	addi	a5,a5,1
ffffffffc02057a4:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc02057a8:	fec59ae3          	bne	a1,a2,ffffffffc020579c <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc02057ac:	8082                	ret

ffffffffc02057ae <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc02057ae:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02057b2:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc02057b4:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02057b8:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc02057ba:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02057be:	f022                	sd	s0,32(sp)
ffffffffc02057c0:	ec26                	sd	s1,24(sp)
ffffffffc02057c2:	e84a                	sd	s2,16(sp)
ffffffffc02057c4:	f406                	sd	ra,40(sp)
ffffffffc02057c6:	e44e                	sd	s3,8(sp)
ffffffffc02057c8:	84aa                	mv	s1,a0
ffffffffc02057ca:	892e                	mv	s2,a1
ffffffffc02057cc:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc02057d0:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc02057d2:	03067e63          	bgeu	a2,a6,ffffffffc020580e <printnum+0x60>
ffffffffc02057d6:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc02057d8:	00805763          	blez	s0,ffffffffc02057e6 <printnum+0x38>
ffffffffc02057dc:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc02057de:	85ca                	mv	a1,s2
ffffffffc02057e0:	854e                	mv	a0,s3
ffffffffc02057e2:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc02057e4:	fc65                	bnez	s0,ffffffffc02057dc <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02057e6:	1a02                	slli	s4,s4,0x20
ffffffffc02057e8:	020a5a13          	srli	s4,s4,0x20
ffffffffc02057ec:	00003797          	auipc	a5,0x3
ffffffffc02057f0:	8cc78793          	addi	a5,a5,-1844 # ffffffffc02080b8 <error_string+0xc8>
ffffffffc02057f4:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
ffffffffc02057f6:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02057f8:	000a4503          	lbu	a0,0(s4) # ffffffff80000000 <_binary_obj___user_exit_out_size+0xffffffff7fff5538>
}
ffffffffc02057fc:	70a2                	ld	ra,40(sp)
ffffffffc02057fe:	69a2                	ld	s3,8(sp)
ffffffffc0205800:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0205802:	85ca                	mv	a1,s2
ffffffffc0205804:	8326                	mv	t1,s1
}
ffffffffc0205806:	6942                	ld	s2,16(sp)
ffffffffc0205808:	64e2                	ld	s1,24(sp)
ffffffffc020580a:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020580c:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc020580e:	03065633          	divu	a2,a2,a6
ffffffffc0205812:	8722                	mv	a4,s0
ffffffffc0205814:	f9bff0ef          	jal	ra,ffffffffc02057ae <printnum>
ffffffffc0205818:	b7f9                	j	ffffffffc02057e6 <printnum+0x38>

ffffffffc020581a <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc020581a:	7119                	addi	sp,sp,-128
ffffffffc020581c:	f4a6                	sd	s1,104(sp)
ffffffffc020581e:	f0ca                	sd	s2,96(sp)
ffffffffc0205820:	e8d2                	sd	s4,80(sp)
ffffffffc0205822:	e4d6                	sd	s5,72(sp)
ffffffffc0205824:	e0da                	sd	s6,64(sp)
ffffffffc0205826:	fc5e                	sd	s7,56(sp)
ffffffffc0205828:	f862                	sd	s8,48(sp)
ffffffffc020582a:	f06a                	sd	s10,32(sp)
ffffffffc020582c:	fc86                	sd	ra,120(sp)
ffffffffc020582e:	f8a2                	sd	s0,112(sp)
ffffffffc0205830:	ecce                	sd	s3,88(sp)
ffffffffc0205832:	f466                	sd	s9,40(sp)
ffffffffc0205834:	ec6e                	sd	s11,24(sp)
ffffffffc0205836:	892a                	mv	s2,a0
ffffffffc0205838:	84ae                	mv	s1,a1
ffffffffc020583a:	8d32                	mv	s10,a2
ffffffffc020583c:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc020583e:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205840:	00002a17          	auipc	s4,0x2
ffffffffc0205844:	658a0a13          	addi	s4,s4,1624 # ffffffffc0207e98 <syscalls+0x100>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0205848:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020584c:	00002c17          	auipc	s8,0x2
ffffffffc0205850:	7a4c0c13          	addi	s8,s8,1956 # ffffffffc0207ff0 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0205854:	000d4503          	lbu	a0,0(s10)
ffffffffc0205858:	02500793          	li	a5,37
ffffffffc020585c:	001d0413          	addi	s0,s10,1
ffffffffc0205860:	00f50e63          	beq	a0,a5,ffffffffc020587c <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc0205864:	c521                	beqz	a0,ffffffffc02058ac <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0205866:	02500993          	li	s3,37
ffffffffc020586a:	a011                	j	ffffffffc020586e <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc020586c:	c121                	beqz	a0,ffffffffc02058ac <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc020586e:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0205870:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0205872:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0205874:	fff44503          	lbu	a0,-1(s0)
ffffffffc0205878:	ff351ae3          	bne	a0,s3,ffffffffc020586c <vprintfmt+0x52>
ffffffffc020587c:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0205880:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0205884:	4981                	li	s3,0
ffffffffc0205886:	4801                	li	a6,0
        width = precision = -1;
ffffffffc0205888:	5cfd                	li	s9,-1
ffffffffc020588a:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020588c:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc0205890:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205892:	fdd6069b          	addiw	a3,a2,-35
ffffffffc0205896:	0ff6f693          	andi	a3,a3,255
ffffffffc020589a:	00140d13          	addi	s10,s0,1
ffffffffc020589e:	1ed5ef63          	bltu	a1,a3,ffffffffc0205a9c <vprintfmt+0x282>
ffffffffc02058a2:	068a                	slli	a3,a3,0x2
ffffffffc02058a4:	96d2                	add	a3,a3,s4
ffffffffc02058a6:	4294                	lw	a3,0(a3)
ffffffffc02058a8:	96d2                	add	a3,a3,s4
ffffffffc02058aa:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc02058ac:	70e6                	ld	ra,120(sp)
ffffffffc02058ae:	7446                	ld	s0,112(sp)
ffffffffc02058b0:	74a6                	ld	s1,104(sp)
ffffffffc02058b2:	7906                	ld	s2,96(sp)
ffffffffc02058b4:	69e6                	ld	s3,88(sp)
ffffffffc02058b6:	6a46                	ld	s4,80(sp)
ffffffffc02058b8:	6aa6                	ld	s5,72(sp)
ffffffffc02058ba:	6b06                	ld	s6,64(sp)
ffffffffc02058bc:	7be2                	ld	s7,56(sp)
ffffffffc02058be:	7c42                	ld	s8,48(sp)
ffffffffc02058c0:	7ca2                	ld	s9,40(sp)
ffffffffc02058c2:	7d02                	ld	s10,32(sp)
ffffffffc02058c4:	6de2                	ld	s11,24(sp)
ffffffffc02058c6:	6109                	addi	sp,sp,128
ffffffffc02058c8:	8082                	ret
            padc = '-';
ffffffffc02058ca:	87b2                	mv	a5,a2
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02058cc:	00144603          	lbu	a2,1(s0)
ffffffffc02058d0:	846a                	mv	s0,s10
ffffffffc02058d2:	b7c1                	j	ffffffffc0205892 <vprintfmt+0x78>
            precision = va_arg(ap, int);
ffffffffc02058d4:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc02058d8:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc02058dc:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02058de:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc02058e0:	fa0dd9e3          	bgez	s11,ffffffffc0205892 <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc02058e4:	8de6                	mv	s11,s9
ffffffffc02058e6:	5cfd                	li	s9,-1
ffffffffc02058e8:	b76d                	j	ffffffffc0205892 <vprintfmt+0x78>
            if (width < 0)
ffffffffc02058ea:	fffdc693          	not	a3,s11
ffffffffc02058ee:	96fd                	srai	a3,a3,0x3f
ffffffffc02058f0:	00ddfdb3          	and	s11,s11,a3
ffffffffc02058f4:	00144603          	lbu	a2,1(s0)
ffffffffc02058f8:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02058fa:	846a                	mv	s0,s10
ffffffffc02058fc:	bf59                	j	ffffffffc0205892 <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc02058fe:	4705                	li	a4,1
ffffffffc0205900:	008a8593          	addi	a1,s5,8
ffffffffc0205904:	01074463          	blt	a4,a6,ffffffffc020590c <vprintfmt+0xf2>
    else if (lflag) {
ffffffffc0205908:	22080863          	beqz	a6,ffffffffc0205b38 <vprintfmt+0x31e>
        return va_arg(*ap, unsigned long);
ffffffffc020590c:	000ab603          	ld	a2,0(s5)
ffffffffc0205910:	46c1                	li	a3,16
ffffffffc0205912:	8aae                	mv	s5,a1
ffffffffc0205914:	a291                	j	ffffffffc0205a58 <vprintfmt+0x23e>
                precision = precision * 10 + ch - '0';
ffffffffc0205916:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc020591a:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020591e:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0205920:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0205924:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0205928:	fad56ce3          	bltu	a0,a3,ffffffffc02058e0 <vprintfmt+0xc6>
            for (precision = 0; ; ++ fmt) {
ffffffffc020592c:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc020592e:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc0205932:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0205936:	0196873b          	addw	a4,a3,s9
ffffffffc020593a:	0017171b          	slliw	a4,a4,0x1
ffffffffc020593e:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc0205942:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc0205946:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc020594a:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc020594e:	fcd57fe3          	bgeu	a0,a3,ffffffffc020592c <vprintfmt+0x112>
ffffffffc0205952:	b779                	j	ffffffffc02058e0 <vprintfmt+0xc6>
            putch(va_arg(ap, int), putdat);
ffffffffc0205954:	000aa503          	lw	a0,0(s5)
ffffffffc0205958:	85a6                	mv	a1,s1
ffffffffc020595a:	0aa1                	addi	s5,s5,8
ffffffffc020595c:	9902                	jalr	s2
            break;
ffffffffc020595e:	bddd                	j	ffffffffc0205854 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0205960:	4705                	li	a4,1
ffffffffc0205962:	008a8993          	addi	s3,s5,8
ffffffffc0205966:	01074463          	blt	a4,a6,ffffffffc020596e <vprintfmt+0x154>
    else if (lflag) {
ffffffffc020596a:	1c080463          	beqz	a6,ffffffffc0205b32 <vprintfmt+0x318>
        return va_arg(*ap, long);
ffffffffc020596e:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc0205972:	1c044a63          	bltz	s0,ffffffffc0205b46 <vprintfmt+0x32c>
            num = getint(&ap, lflag);
ffffffffc0205976:	8622                	mv	a2,s0
ffffffffc0205978:	8ace                	mv	s5,s3
ffffffffc020597a:	46a9                	li	a3,10
ffffffffc020597c:	a8f1                	j	ffffffffc0205a58 <vprintfmt+0x23e>
            err = va_arg(ap, int);
ffffffffc020597e:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0205982:	4761                	li	a4,24
            err = va_arg(ap, int);
ffffffffc0205984:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc0205986:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc020598a:	8fb5                	xor	a5,a5,a3
ffffffffc020598c:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0205990:	12d74963          	blt	a4,a3,ffffffffc0205ac2 <vprintfmt+0x2a8>
ffffffffc0205994:	00369793          	slli	a5,a3,0x3
ffffffffc0205998:	97e2                	add	a5,a5,s8
ffffffffc020599a:	639c                	ld	a5,0(a5)
ffffffffc020599c:	12078363          	beqz	a5,ffffffffc0205ac2 <vprintfmt+0x2a8>
                printfmt(putch, putdat, "%s", p);
ffffffffc02059a0:	86be                	mv	a3,a5
ffffffffc02059a2:	00000617          	auipc	a2,0x0
ffffffffc02059a6:	23e60613          	addi	a2,a2,574 # ffffffffc0205be0 <etext+0x2e>
ffffffffc02059aa:	85a6                	mv	a1,s1
ffffffffc02059ac:	854a                	mv	a0,s2
ffffffffc02059ae:	1cc000ef          	jal	ra,ffffffffc0205b7a <printfmt>
ffffffffc02059b2:	b54d                	j	ffffffffc0205854 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02059b4:	000ab603          	ld	a2,0(s5)
ffffffffc02059b8:	0aa1                	addi	s5,s5,8
ffffffffc02059ba:	1a060163          	beqz	a2,ffffffffc0205b5c <vprintfmt+0x342>
            if (width > 0 && padc != '-') {
ffffffffc02059be:	00160413          	addi	s0,a2,1
ffffffffc02059c2:	15b05763          	blez	s11,ffffffffc0205b10 <vprintfmt+0x2f6>
ffffffffc02059c6:	02d00593          	li	a1,45
ffffffffc02059ca:	10b79d63          	bne	a5,a1,ffffffffc0205ae4 <vprintfmt+0x2ca>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02059ce:	00064783          	lbu	a5,0(a2)
ffffffffc02059d2:	0007851b          	sext.w	a0,a5
ffffffffc02059d6:	c905                	beqz	a0,ffffffffc0205a06 <vprintfmt+0x1ec>
ffffffffc02059d8:	000cc563          	bltz	s9,ffffffffc02059e2 <vprintfmt+0x1c8>
ffffffffc02059dc:	3cfd                	addiw	s9,s9,-1
ffffffffc02059de:	036c8263          	beq	s9,s6,ffffffffc0205a02 <vprintfmt+0x1e8>
                    putch('?', putdat);
ffffffffc02059e2:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02059e4:	14098f63          	beqz	s3,ffffffffc0205b42 <vprintfmt+0x328>
ffffffffc02059e8:	3781                	addiw	a5,a5,-32
ffffffffc02059ea:	14fbfc63          	bgeu	s7,a5,ffffffffc0205b42 <vprintfmt+0x328>
                    putch('?', putdat);
ffffffffc02059ee:	03f00513          	li	a0,63
ffffffffc02059f2:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02059f4:	0405                	addi	s0,s0,1
ffffffffc02059f6:	fff44783          	lbu	a5,-1(s0)
ffffffffc02059fa:	3dfd                	addiw	s11,s11,-1
ffffffffc02059fc:	0007851b          	sext.w	a0,a5
ffffffffc0205a00:	fd61                	bnez	a0,ffffffffc02059d8 <vprintfmt+0x1be>
            for (; width > 0; width --) {
ffffffffc0205a02:	e5b059e3          	blez	s11,ffffffffc0205854 <vprintfmt+0x3a>
ffffffffc0205a06:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0205a08:	85a6                	mv	a1,s1
ffffffffc0205a0a:	02000513          	li	a0,32
ffffffffc0205a0e:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0205a10:	e40d82e3          	beqz	s11,ffffffffc0205854 <vprintfmt+0x3a>
ffffffffc0205a14:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0205a16:	85a6                	mv	a1,s1
ffffffffc0205a18:	02000513          	li	a0,32
ffffffffc0205a1c:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0205a1e:	fe0d94e3          	bnez	s11,ffffffffc0205a06 <vprintfmt+0x1ec>
ffffffffc0205a22:	bd0d                	j	ffffffffc0205854 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0205a24:	4705                	li	a4,1
ffffffffc0205a26:	008a8593          	addi	a1,s5,8
ffffffffc0205a2a:	01074463          	blt	a4,a6,ffffffffc0205a32 <vprintfmt+0x218>
    else if (lflag) {
ffffffffc0205a2e:	0e080863          	beqz	a6,ffffffffc0205b1e <vprintfmt+0x304>
        return va_arg(*ap, unsigned long);
ffffffffc0205a32:	000ab603          	ld	a2,0(s5)
ffffffffc0205a36:	46a1                	li	a3,8
ffffffffc0205a38:	8aae                	mv	s5,a1
ffffffffc0205a3a:	a839                	j	ffffffffc0205a58 <vprintfmt+0x23e>
            putch('0', putdat);
ffffffffc0205a3c:	03000513          	li	a0,48
ffffffffc0205a40:	85a6                	mv	a1,s1
ffffffffc0205a42:	e03e                	sd	a5,0(sp)
ffffffffc0205a44:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0205a46:	85a6                	mv	a1,s1
ffffffffc0205a48:	07800513          	li	a0,120
ffffffffc0205a4c:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0205a4e:	0aa1                	addi	s5,s5,8
ffffffffc0205a50:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc0205a54:	6782                	ld	a5,0(sp)
ffffffffc0205a56:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0205a58:	2781                	sext.w	a5,a5
ffffffffc0205a5a:	876e                	mv	a4,s11
ffffffffc0205a5c:	85a6                	mv	a1,s1
ffffffffc0205a5e:	854a                	mv	a0,s2
ffffffffc0205a60:	d4fff0ef          	jal	ra,ffffffffc02057ae <printnum>
            break;
ffffffffc0205a64:	bbc5                	j	ffffffffc0205854 <vprintfmt+0x3a>
            lflag ++;
ffffffffc0205a66:	00144603          	lbu	a2,1(s0)
ffffffffc0205a6a:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205a6c:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0205a6e:	b515                	j	ffffffffc0205892 <vprintfmt+0x78>
            goto reswitch;
ffffffffc0205a70:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0205a74:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205a76:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0205a78:	bd29                	j	ffffffffc0205892 <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc0205a7a:	85a6                	mv	a1,s1
ffffffffc0205a7c:	02500513          	li	a0,37
ffffffffc0205a80:	9902                	jalr	s2
            break;
ffffffffc0205a82:	bbc9                	j	ffffffffc0205854 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0205a84:	4705                	li	a4,1
ffffffffc0205a86:	008a8593          	addi	a1,s5,8
ffffffffc0205a8a:	01074463          	blt	a4,a6,ffffffffc0205a92 <vprintfmt+0x278>
    else if (lflag) {
ffffffffc0205a8e:	08080d63          	beqz	a6,ffffffffc0205b28 <vprintfmt+0x30e>
        return va_arg(*ap, unsigned long);
ffffffffc0205a92:	000ab603          	ld	a2,0(s5)
ffffffffc0205a96:	46a9                	li	a3,10
ffffffffc0205a98:	8aae                	mv	s5,a1
ffffffffc0205a9a:	bf7d                	j	ffffffffc0205a58 <vprintfmt+0x23e>
            putch('%', putdat);
ffffffffc0205a9c:	85a6                	mv	a1,s1
ffffffffc0205a9e:	02500513          	li	a0,37
ffffffffc0205aa2:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0205aa4:	fff44703          	lbu	a4,-1(s0)
ffffffffc0205aa8:	02500793          	li	a5,37
ffffffffc0205aac:	8d22                	mv	s10,s0
ffffffffc0205aae:	daf703e3          	beq	a4,a5,ffffffffc0205854 <vprintfmt+0x3a>
ffffffffc0205ab2:	02500713          	li	a4,37
ffffffffc0205ab6:	1d7d                	addi	s10,s10,-1
ffffffffc0205ab8:	fffd4783          	lbu	a5,-1(s10)
ffffffffc0205abc:	fee79de3          	bne	a5,a4,ffffffffc0205ab6 <vprintfmt+0x29c>
ffffffffc0205ac0:	bb51                	j	ffffffffc0205854 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0205ac2:	00002617          	auipc	a2,0x2
ffffffffc0205ac6:	6d660613          	addi	a2,a2,1750 # ffffffffc0208198 <error_string+0x1a8>
ffffffffc0205aca:	85a6                	mv	a1,s1
ffffffffc0205acc:	854a                	mv	a0,s2
ffffffffc0205ace:	0ac000ef          	jal	ra,ffffffffc0205b7a <printfmt>
ffffffffc0205ad2:	b349                	j	ffffffffc0205854 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0205ad4:	00002617          	auipc	a2,0x2
ffffffffc0205ad8:	6bc60613          	addi	a2,a2,1724 # ffffffffc0208190 <error_string+0x1a0>
            if (width > 0 && padc != '-') {
ffffffffc0205adc:	00002417          	auipc	s0,0x2
ffffffffc0205ae0:	6b540413          	addi	s0,s0,1717 # ffffffffc0208191 <error_string+0x1a1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0205ae4:	8532                	mv	a0,a2
ffffffffc0205ae6:	85e6                	mv	a1,s9
ffffffffc0205ae8:	e032                	sd	a2,0(sp)
ffffffffc0205aea:	e43e                	sd	a5,8(sp)
ffffffffc0205aec:	c19ff0ef          	jal	ra,ffffffffc0205704 <strnlen>
ffffffffc0205af0:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0205af4:	6602                	ld	a2,0(sp)
ffffffffc0205af6:	01b05d63          	blez	s11,ffffffffc0205b10 <vprintfmt+0x2f6>
ffffffffc0205afa:	67a2                	ld	a5,8(sp)
ffffffffc0205afc:	2781                	sext.w	a5,a5
ffffffffc0205afe:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc0205b00:	6522                	ld	a0,8(sp)
ffffffffc0205b02:	85a6                	mv	a1,s1
ffffffffc0205b04:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0205b06:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0205b08:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0205b0a:	6602                	ld	a2,0(sp)
ffffffffc0205b0c:	fe0d9ae3          	bnez	s11,ffffffffc0205b00 <vprintfmt+0x2e6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0205b10:	00064783          	lbu	a5,0(a2)
ffffffffc0205b14:	0007851b          	sext.w	a0,a5
ffffffffc0205b18:	ec0510e3          	bnez	a0,ffffffffc02059d8 <vprintfmt+0x1be>
ffffffffc0205b1c:	bb25                	j	ffffffffc0205854 <vprintfmt+0x3a>
        return va_arg(*ap, unsigned int);
ffffffffc0205b1e:	000ae603          	lwu	a2,0(s5)
ffffffffc0205b22:	46a1                	li	a3,8
ffffffffc0205b24:	8aae                	mv	s5,a1
ffffffffc0205b26:	bf0d                	j	ffffffffc0205a58 <vprintfmt+0x23e>
ffffffffc0205b28:	000ae603          	lwu	a2,0(s5)
ffffffffc0205b2c:	46a9                	li	a3,10
ffffffffc0205b2e:	8aae                	mv	s5,a1
ffffffffc0205b30:	b725                	j	ffffffffc0205a58 <vprintfmt+0x23e>
        return va_arg(*ap, int);
ffffffffc0205b32:	000aa403          	lw	s0,0(s5)
ffffffffc0205b36:	bd35                	j	ffffffffc0205972 <vprintfmt+0x158>
        return va_arg(*ap, unsigned int);
ffffffffc0205b38:	000ae603          	lwu	a2,0(s5)
ffffffffc0205b3c:	46c1                	li	a3,16
ffffffffc0205b3e:	8aae                	mv	s5,a1
ffffffffc0205b40:	bf21                	j	ffffffffc0205a58 <vprintfmt+0x23e>
                    putch(ch, putdat);
ffffffffc0205b42:	9902                	jalr	s2
ffffffffc0205b44:	bd45                	j	ffffffffc02059f4 <vprintfmt+0x1da>
                putch('-', putdat);
ffffffffc0205b46:	85a6                	mv	a1,s1
ffffffffc0205b48:	02d00513          	li	a0,45
ffffffffc0205b4c:	e03e                	sd	a5,0(sp)
ffffffffc0205b4e:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0205b50:	8ace                	mv	s5,s3
ffffffffc0205b52:	40800633          	neg	a2,s0
ffffffffc0205b56:	46a9                	li	a3,10
ffffffffc0205b58:	6782                	ld	a5,0(sp)
ffffffffc0205b5a:	bdfd                	j	ffffffffc0205a58 <vprintfmt+0x23e>
            if (width > 0 && padc != '-') {
ffffffffc0205b5c:	01b05663          	blez	s11,ffffffffc0205b68 <vprintfmt+0x34e>
ffffffffc0205b60:	02d00693          	li	a3,45
ffffffffc0205b64:	f6d798e3          	bne	a5,a3,ffffffffc0205ad4 <vprintfmt+0x2ba>
ffffffffc0205b68:	00002417          	auipc	s0,0x2
ffffffffc0205b6c:	62940413          	addi	s0,s0,1577 # ffffffffc0208191 <error_string+0x1a1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0205b70:	02800513          	li	a0,40
ffffffffc0205b74:	02800793          	li	a5,40
ffffffffc0205b78:	b585                	j	ffffffffc02059d8 <vprintfmt+0x1be>

ffffffffc0205b7a <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0205b7a:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0205b7c:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0205b80:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0205b82:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0205b84:	ec06                	sd	ra,24(sp)
ffffffffc0205b86:	f83a                	sd	a4,48(sp)
ffffffffc0205b88:	fc3e                	sd	a5,56(sp)
ffffffffc0205b8a:	e0c2                	sd	a6,64(sp)
ffffffffc0205b8c:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0205b8e:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0205b90:	c8bff0ef          	jal	ra,ffffffffc020581a <vprintfmt>
}
ffffffffc0205b94:	60e2                	ld	ra,24(sp)
ffffffffc0205b96:	6161                	addi	sp,sp,80
ffffffffc0205b98:	8082                	ret

ffffffffc0205b9a <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc0205b9a:	9e3707b7          	lui	a5,0x9e370
ffffffffc0205b9e:	2785                	addiw	a5,a5,1
ffffffffc0205ba0:	02f5053b          	mulw	a0,a0,a5
    return (hash >> (32 - bits));
ffffffffc0205ba4:	02000793          	li	a5,32
ffffffffc0205ba8:	40b785bb          	subw	a1,a5,a1
}
ffffffffc0205bac:	00b5553b          	srlw	a0,a0,a1
ffffffffc0205bb0:	8082                	ret
