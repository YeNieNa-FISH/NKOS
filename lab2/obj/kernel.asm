
bin/kernel：     文件格式 elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02052b7          	lui	t0,0xc0205
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
ffffffffc0200028:	c0205137          	lui	sp,0xc0205

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


int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200036:	00006517          	auipc	a0,0x6
ffffffffc020003a:	fda50513          	addi	a0,a0,-38 # ffffffffc0206010 <edata>
ffffffffc020003e:	00006617          	auipc	a2,0x6
ffffffffc0200042:	43260613          	addi	a2,a2,1074 # ffffffffc0206470 <end>
int kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
int kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	54c010ef          	jal	ra,ffffffffc020159a <memset>
    cons_init();  // init the console
ffffffffc0200052:	3f8000ef          	jal	ra,ffffffffc020044a <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200056:	00002517          	auipc	a0,0x2
ffffffffc020005a:	a5a50513          	addi	a0,a0,-1446 # ffffffffc0201ab0 <etext+0x4>
ffffffffc020005e:	08e000ef          	jal	ra,ffffffffc02000ec <cputs>

    print_kerninfo();
ffffffffc0200062:	13a000ef          	jal	ra,ffffffffc020019c <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200066:	3fe000ef          	jal	ra,ffffffffc0200464 <idt_init>

    pmm_init();  // init physical memory management
ffffffffc020006a:	069000ef          	jal	ra,ffffffffc02008d2 <pmm_init>

    idt_init();  // init interrupt descriptor table
ffffffffc020006e:	3f6000ef          	jal	ra,ffffffffc0200464 <idt_init>

    clock_init();   // init clock interrupt
ffffffffc0200072:	396000ef          	jal	ra,ffffffffc0200408 <clock_init>
    intr_enable();  // enable irq interrupt
ffffffffc0200076:	3e2000ef          	jal	ra,ffffffffc0200458 <intr_enable>



    /* do nothing */
    while (1)
        ;
ffffffffc020007a:	a001                	j	ffffffffc020007a <kern_init+0x44>

ffffffffc020007c <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc020007c:	1141                	addi	sp,sp,-16
ffffffffc020007e:	e022                	sd	s0,0(sp)
ffffffffc0200080:	e406                	sd	ra,8(sp)
ffffffffc0200082:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc0200084:	3c8000ef          	jal	ra,ffffffffc020044c <cons_putc>
    (*cnt) ++;
ffffffffc0200088:	401c                	lw	a5,0(s0)
}
ffffffffc020008a:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc020008c:	2785                	addiw	a5,a5,1
ffffffffc020008e:	c01c                	sw	a5,0(s0)
}
ffffffffc0200090:	6402                	ld	s0,0(sp)
ffffffffc0200092:	0141                	addi	sp,sp,16
ffffffffc0200094:	8082                	ret

ffffffffc0200096 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200096:	1101                	addi	sp,sp,-32
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200098:	86ae                	mv	a3,a1
ffffffffc020009a:	862a                	mv	a2,a0
ffffffffc020009c:	006c                	addi	a1,sp,12
ffffffffc020009e:	00000517          	auipc	a0,0x0
ffffffffc02000a2:	fde50513          	addi	a0,a0,-34 # ffffffffc020007c <cputch>
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000a6:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000a8:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000aa:	56e010ef          	jal	ra,ffffffffc0201618 <vprintfmt>
    return cnt;
}
ffffffffc02000ae:	60e2                	ld	ra,24(sp)
ffffffffc02000b0:	4532                	lw	a0,12(sp)
ffffffffc02000b2:	6105                	addi	sp,sp,32
ffffffffc02000b4:	8082                	ret

ffffffffc02000b6 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000b6:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000b8:	02810313          	addi	t1,sp,40 # ffffffffc0205028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000bc:	f42e                	sd	a1,40(sp)
ffffffffc02000be:	f832                	sd	a2,48(sp)
ffffffffc02000c0:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c2:	862a                	mv	a2,a0
ffffffffc02000c4:	004c                	addi	a1,sp,4
ffffffffc02000c6:	00000517          	auipc	a0,0x0
ffffffffc02000ca:	fb650513          	addi	a0,a0,-74 # ffffffffc020007c <cputch>
ffffffffc02000ce:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
ffffffffc02000d0:	ec06                	sd	ra,24(sp)
ffffffffc02000d2:	e0ba                	sd	a4,64(sp)
ffffffffc02000d4:	e4be                	sd	a5,72(sp)
ffffffffc02000d6:	e8c2                	sd	a6,80(sp)
ffffffffc02000d8:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000da:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000dc:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000de:	53a010ef          	jal	ra,ffffffffc0201618 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000e2:	60e2                	ld	ra,24(sp)
ffffffffc02000e4:	4512                	lw	a0,4(sp)
ffffffffc02000e6:	6125                	addi	sp,sp,96
ffffffffc02000e8:	8082                	ret

ffffffffc02000ea <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000ea:	a68d                	j	ffffffffc020044c <cons_putc>

ffffffffc02000ec <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc02000ec:	1101                	addi	sp,sp,-32
ffffffffc02000ee:	e822                	sd	s0,16(sp)
ffffffffc02000f0:	ec06                	sd	ra,24(sp)
ffffffffc02000f2:	e426                	sd	s1,8(sp)
ffffffffc02000f4:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc02000f6:	00054503          	lbu	a0,0(a0)
ffffffffc02000fa:	c51d                	beqz	a0,ffffffffc0200128 <cputs+0x3c>
ffffffffc02000fc:	0405                	addi	s0,s0,1
ffffffffc02000fe:	4485                	li	s1,1
ffffffffc0200100:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc0200102:	34a000ef          	jal	ra,ffffffffc020044c <cons_putc>
    (*cnt) ++;
ffffffffc0200106:	008487bb          	addw	a5,s1,s0
    while ((c = *str ++) != '\0') {
ffffffffc020010a:	0405                	addi	s0,s0,1
ffffffffc020010c:	fff44503          	lbu	a0,-1(s0)
ffffffffc0200110:	f96d                	bnez	a0,ffffffffc0200102 <cputs+0x16>
ffffffffc0200112:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc0200116:	4529                	li	a0,10
ffffffffc0200118:	334000ef          	jal	ra,ffffffffc020044c <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc020011c:	8522                	mv	a0,s0
ffffffffc020011e:	60e2                	ld	ra,24(sp)
ffffffffc0200120:	6442                	ld	s0,16(sp)
ffffffffc0200122:	64a2                	ld	s1,8(sp)
ffffffffc0200124:	6105                	addi	sp,sp,32
ffffffffc0200126:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc0200128:	4405                	li	s0,1
ffffffffc020012a:	b7f5                	j	ffffffffc0200116 <cputs+0x2a>

ffffffffc020012c <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc020012c:	1141                	addi	sp,sp,-16
ffffffffc020012e:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc0200130:	324000ef          	jal	ra,ffffffffc0200454 <cons_getc>
ffffffffc0200134:	dd75                	beqz	a0,ffffffffc0200130 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200136:	60a2                	ld	ra,8(sp)
ffffffffc0200138:	0141                	addi	sp,sp,16
ffffffffc020013a:	8082                	ret

ffffffffc020013c <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc020013c:	00006317          	auipc	t1,0x6
ffffffffc0200140:	2d430313          	addi	t1,t1,724 # ffffffffc0206410 <is_panic>
ffffffffc0200144:	00032303          	lw	t1,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc0200148:	715d                	addi	sp,sp,-80
ffffffffc020014a:	ec06                	sd	ra,24(sp)
ffffffffc020014c:	e822                	sd	s0,16(sp)
ffffffffc020014e:	f436                	sd	a3,40(sp)
ffffffffc0200150:	f83a                	sd	a4,48(sp)
ffffffffc0200152:	fc3e                	sd	a5,56(sp)
ffffffffc0200154:	e0c2                	sd	a6,64(sp)
ffffffffc0200156:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc0200158:	02031c63          	bnez	t1,ffffffffc0200190 <__panic+0x54>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc020015c:	4785                	li	a5,1
ffffffffc020015e:	8432                	mv	s0,a2
ffffffffc0200160:	00006717          	auipc	a4,0x6
ffffffffc0200164:	2af72823          	sw	a5,688(a4) # ffffffffc0206410 <is_panic>

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200168:	862e                	mv	a2,a1
    va_start(ap, fmt);
ffffffffc020016a:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020016c:	85aa                	mv	a1,a0
ffffffffc020016e:	00002517          	auipc	a0,0x2
ffffffffc0200172:	96250513          	addi	a0,a0,-1694 # ffffffffc0201ad0 <etext+0x24>
    va_start(ap, fmt);
ffffffffc0200176:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200178:	f3fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    vcprintf(fmt, ap);
ffffffffc020017c:	65a2                	ld	a1,8(sp)
ffffffffc020017e:	8522                	mv	a0,s0
ffffffffc0200180:	f17ff0ef          	jal	ra,ffffffffc0200096 <vcprintf>
    cprintf("\n");
ffffffffc0200184:	00002517          	auipc	a0,0x2
ffffffffc0200188:	a6450513          	addi	a0,a0,-1436 # ffffffffc0201be8 <etext+0x13c>
ffffffffc020018c:	f2bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc0200190:	2ce000ef          	jal	ra,ffffffffc020045e <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc0200194:	4501                	li	a0,0
ffffffffc0200196:	130000ef          	jal	ra,ffffffffc02002c6 <kmonitor>
ffffffffc020019a:	bfed                	j	ffffffffc0200194 <__panic+0x58>

ffffffffc020019c <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc020019c:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc020019e:	00002517          	auipc	a0,0x2
ffffffffc02001a2:	98250513          	addi	a0,a0,-1662 # ffffffffc0201b20 <etext+0x74>
void print_kerninfo(void) {
ffffffffc02001a6:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc02001a8:	f0fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc02001ac:	00000597          	auipc	a1,0x0
ffffffffc02001b0:	e8a58593          	addi	a1,a1,-374 # ffffffffc0200036 <kern_init>
ffffffffc02001b4:	00002517          	auipc	a0,0x2
ffffffffc02001b8:	98c50513          	addi	a0,a0,-1652 # ffffffffc0201b40 <etext+0x94>
ffffffffc02001bc:	efbff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc02001c0:	00002597          	auipc	a1,0x2
ffffffffc02001c4:	8ec58593          	addi	a1,a1,-1812 # ffffffffc0201aac <etext>
ffffffffc02001c8:	00002517          	auipc	a0,0x2
ffffffffc02001cc:	99850513          	addi	a0,a0,-1640 # ffffffffc0201b60 <etext+0xb4>
ffffffffc02001d0:	ee7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc02001d4:	00006597          	auipc	a1,0x6
ffffffffc02001d8:	e3c58593          	addi	a1,a1,-452 # ffffffffc0206010 <edata>
ffffffffc02001dc:	00002517          	auipc	a0,0x2
ffffffffc02001e0:	9a450513          	addi	a0,a0,-1628 # ffffffffc0201b80 <etext+0xd4>
ffffffffc02001e4:	ed3ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc02001e8:	00006597          	auipc	a1,0x6
ffffffffc02001ec:	28858593          	addi	a1,a1,648 # ffffffffc0206470 <end>
ffffffffc02001f0:	00002517          	auipc	a0,0x2
ffffffffc02001f4:	9b050513          	addi	a0,a0,-1616 # ffffffffc0201ba0 <etext+0xf4>
ffffffffc02001f8:	ebfff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc02001fc:	00006597          	auipc	a1,0x6
ffffffffc0200200:	67358593          	addi	a1,a1,1651 # ffffffffc020686f <end+0x3ff>
ffffffffc0200204:	00000797          	auipc	a5,0x0
ffffffffc0200208:	e3278793          	addi	a5,a5,-462 # ffffffffc0200036 <kern_init>
ffffffffc020020c:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200210:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc0200214:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200216:	3ff5f593          	andi	a1,a1,1023
ffffffffc020021a:	95be                	add	a1,a1,a5
ffffffffc020021c:	85a9                	srai	a1,a1,0xa
ffffffffc020021e:	00002517          	auipc	a0,0x2
ffffffffc0200222:	9a250513          	addi	a0,a0,-1630 # ffffffffc0201bc0 <etext+0x114>
}
ffffffffc0200226:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200228:	b579                	j	ffffffffc02000b6 <cprintf>

ffffffffc020022a <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc020022a:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc020022c:	00002617          	auipc	a2,0x2
ffffffffc0200230:	8c460613          	addi	a2,a2,-1852 # ffffffffc0201af0 <etext+0x44>
ffffffffc0200234:	04e00593          	li	a1,78
ffffffffc0200238:	00002517          	auipc	a0,0x2
ffffffffc020023c:	8d050513          	addi	a0,a0,-1840 # ffffffffc0201b08 <etext+0x5c>
void print_stackframe(void) {
ffffffffc0200240:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc0200242:	efbff0ef          	jal	ra,ffffffffc020013c <__panic>

ffffffffc0200246 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200246:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200248:	00002617          	auipc	a2,0x2
ffffffffc020024c:	a8860613          	addi	a2,a2,-1400 # ffffffffc0201cd0 <commands+0xe0>
ffffffffc0200250:	00002597          	auipc	a1,0x2
ffffffffc0200254:	aa058593          	addi	a1,a1,-1376 # ffffffffc0201cf0 <commands+0x100>
ffffffffc0200258:	00002517          	auipc	a0,0x2
ffffffffc020025c:	aa050513          	addi	a0,a0,-1376 # ffffffffc0201cf8 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200260:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200262:	e55ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200266:	00002617          	auipc	a2,0x2
ffffffffc020026a:	aa260613          	addi	a2,a2,-1374 # ffffffffc0201d08 <commands+0x118>
ffffffffc020026e:	00002597          	auipc	a1,0x2
ffffffffc0200272:	ac258593          	addi	a1,a1,-1342 # ffffffffc0201d30 <commands+0x140>
ffffffffc0200276:	00002517          	auipc	a0,0x2
ffffffffc020027a:	a8250513          	addi	a0,a0,-1406 # ffffffffc0201cf8 <commands+0x108>
ffffffffc020027e:	e39ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200282:	00002617          	auipc	a2,0x2
ffffffffc0200286:	abe60613          	addi	a2,a2,-1346 # ffffffffc0201d40 <commands+0x150>
ffffffffc020028a:	00002597          	auipc	a1,0x2
ffffffffc020028e:	ad658593          	addi	a1,a1,-1322 # ffffffffc0201d60 <commands+0x170>
ffffffffc0200292:	00002517          	auipc	a0,0x2
ffffffffc0200296:	a6650513          	addi	a0,a0,-1434 # ffffffffc0201cf8 <commands+0x108>
ffffffffc020029a:	e1dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    }
    return 0;
}
ffffffffc020029e:	60a2                	ld	ra,8(sp)
ffffffffc02002a0:	4501                	li	a0,0
ffffffffc02002a2:	0141                	addi	sp,sp,16
ffffffffc02002a4:	8082                	ret

ffffffffc02002a6 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002a6:	1141                	addi	sp,sp,-16
ffffffffc02002a8:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc02002aa:	ef3ff0ef          	jal	ra,ffffffffc020019c <print_kerninfo>
    return 0;
}
ffffffffc02002ae:	60a2                	ld	ra,8(sp)
ffffffffc02002b0:	4501                	li	a0,0
ffffffffc02002b2:	0141                	addi	sp,sp,16
ffffffffc02002b4:	8082                	ret

ffffffffc02002b6 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002b6:	1141                	addi	sp,sp,-16
ffffffffc02002b8:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc02002ba:	f71ff0ef          	jal	ra,ffffffffc020022a <print_stackframe>
    return 0;
}
ffffffffc02002be:	60a2                	ld	ra,8(sp)
ffffffffc02002c0:	4501                	li	a0,0
ffffffffc02002c2:	0141                	addi	sp,sp,16
ffffffffc02002c4:	8082                	ret

ffffffffc02002c6 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc02002c6:	7115                	addi	sp,sp,-224
ffffffffc02002c8:	e962                	sd	s8,144(sp)
ffffffffc02002ca:	8c2a                	mv	s8,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02002cc:	00002517          	auipc	a0,0x2
ffffffffc02002d0:	96c50513          	addi	a0,a0,-1684 # ffffffffc0201c38 <commands+0x48>
kmonitor(struct trapframe *tf) {
ffffffffc02002d4:	ed86                	sd	ra,216(sp)
ffffffffc02002d6:	e9a2                	sd	s0,208(sp)
ffffffffc02002d8:	e5a6                	sd	s1,200(sp)
ffffffffc02002da:	e1ca                	sd	s2,192(sp)
ffffffffc02002dc:	fd4e                	sd	s3,184(sp)
ffffffffc02002de:	f952                	sd	s4,176(sp)
ffffffffc02002e0:	f556                	sd	s5,168(sp)
ffffffffc02002e2:	f15a                	sd	s6,160(sp)
ffffffffc02002e4:	ed5e                	sd	s7,152(sp)
ffffffffc02002e6:	e566                	sd	s9,136(sp)
ffffffffc02002e8:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02002ea:	dcdff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc02002ee:	00002517          	auipc	a0,0x2
ffffffffc02002f2:	97250513          	addi	a0,a0,-1678 # ffffffffc0201c60 <commands+0x70>
ffffffffc02002f6:	dc1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    if (tf != NULL) {
ffffffffc02002fa:	000c0563          	beqz	s8,ffffffffc0200304 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc02002fe:	8562                	mv	a0,s8
ffffffffc0200300:	342000ef          	jal	ra,ffffffffc0200642 <print_trapframe>
ffffffffc0200304:	00002c97          	auipc	s9,0x2
ffffffffc0200308:	8ecc8c93          	addi	s9,s9,-1812 # ffffffffc0201bf0 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc020030c:	00002997          	auipc	s3,0x2
ffffffffc0200310:	97c98993          	addi	s3,s3,-1668 # ffffffffc0201c88 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200314:	00002917          	auipc	s2,0x2
ffffffffc0200318:	97c90913          	addi	s2,s2,-1668 # ffffffffc0201c90 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc020031c:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020031e:	00002b17          	auipc	s6,0x2
ffffffffc0200322:	97ab0b13          	addi	s6,s6,-1670 # ffffffffc0201c98 <commands+0xa8>
    if (argc == 0) {
ffffffffc0200326:	00002a97          	auipc	s5,0x2
ffffffffc020032a:	9caa8a93          	addi	s5,s5,-1590 # ffffffffc0201cf0 <commands+0x100>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020032e:	4b8d                	li	s7,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200330:	854e                	mv	a0,s3
ffffffffc0200332:	666010ef          	jal	ra,ffffffffc0201998 <readline>
ffffffffc0200336:	842a                	mv	s0,a0
ffffffffc0200338:	dd65                	beqz	a0,ffffffffc0200330 <kmonitor+0x6a>
ffffffffc020033a:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc020033e:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200340:	c999                	beqz	a1,ffffffffc0200356 <kmonitor+0x90>
ffffffffc0200342:	854a                	mv	a0,s2
ffffffffc0200344:	238010ef          	jal	ra,ffffffffc020157c <strchr>
ffffffffc0200348:	c925                	beqz	a0,ffffffffc02003b8 <kmonitor+0xf2>
            *buf ++ = '\0';
ffffffffc020034a:	00144583          	lbu	a1,1(s0)
ffffffffc020034e:	00040023          	sb	zero,0(s0)
ffffffffc0200352:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200354:	f5fd                	bnez	a1,ffffffffc0200342 <kmonitor+0x7c>
    if (argc == 0) {
ffffffffc0200356:	dce9                	beqz	s1,ffffffffc0200330 <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200358:	6582                	ld	a1,0(sp)
ffffffffc020035a:	00002d17          	auipc	s10,0x2
ffffffffc020035e:	896d0d13          	addi	s10,s10,-1898 # ffffffffc0201bf0 <commands>
    if (argc == 0) {
ffffffffc0200362:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200364:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200366:	0d61                	addi	s10,s10,24
ffffffffc0200368:	1ea010ef          	jal	ra,ffffffffc0201552 <strcmp>
ffffffffc020036c:	c919                	beqz	a0,ffffffffc0200382 <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020036e:	2405                	addiw	s0,s0,1
ffffffffc0200370:	09740463          	beq	s0,s7,ffffffffc02003f8 <kmonitor+0x132>
ffffffffc0200374:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200378:	6582                	ld	a1,0(sp)
ffffffffc020037a:	0d61                	addi	s10,s10,24
ffffffffc020037c:	1d6010ef          	jal	ra,ffffffffc0201552 <strcmp>
ffffffffc0200380:	f57d                	bnez	a0,ffffffffc020036e <kmonitor+0xa8>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc0200382:	00141793          	slli	a5,s0,0x1
ffffffffc0200386:	97a2                	add	a5,a5,s0
ffffffffc0200388:	078e                	slli	a5,a5,0x3
ffffffffc020038a:	97e6                	add	a5,a5,s9
ffffffffc020038c:	6b9c                	ld	a5,16(a5)
ffffffffc020038e:	8662                	mv	a2,s8
ffffffffc0200390:	002c                	addi	a1,sp,8
ffffffffc0200392:	fff4851b          	addiw	a0,s1,-1
ffffffffc0200396:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200398:	f8055ce3          	bgez	a0,ffffffffc0200330 <kmonitor+0x6a>
}
ffffffffc020039c:	60ee                	ld	ra,216(sp)
ffffffffc020039e:	644e                	ld	s0,208(sp)
ffffffffc02003a0:	64ae                	ld	s1,200(sp)
ffffffffc02003a2:	690e                	ld	s2,192(sp)
ffffffffc02003a4:	79ea                	ld	s3,184(sp)
ffffffffc02003a6:	7a4a                	ld	s4,176(sp)
ffffffffc02003a8:	7aaa                	ld	s5,168(sp)
ffffffffc02003aa:	7b0a                	ld	s6,160(sp)
ffffffffc02003ac:	6bea                	ld	s7,152(sp)
ffffffffc02003ae:	6c4a                	ld	s8,144(sp)
ffffffffc02003b0:	6caa                	ld	s9,136(sp)
ffffffffc02003b2:	6d0a                	ld	s10,128(sp)
ffffffffc02003b4:	612d                	addi	sp,sp,224
ffffffffc02003b6:	8082                	ret
        if (*buf == '\0') {
ffffffffc02003b8:	00044783          	lbu	a5,0(s0)
ffffffffc02003bc:	dfc9                	beqz	a5,ffffffffc0200356 <kmonitor+0x90>
        if (argc == MAXARGS - 1) {
ffffffffc02003be:	03448863          	beq	s1,s4,ffffffffc02003ee <kmonitor+0x128>
        argv[argc ++] = buf;
ffffffffc02003c2:	00349793          	slli	a5,s1,0x3
ffffffffc02003c6:	0118                	addi	a4,sp,128
ffffffffc02003c8:	97ba                	add	a5,a5,a4
ffffffffc02003ca:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003ce:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc02003d2:	2485                	addiw	s1,s1,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003d4:	e591                	bnez	a1,ffffffffc02003e0 <kmonitor+0x11a>
ffffffffc02003d6:	b749                	j	ffffffffc0200358 <kmonitor+0x92>
            buf ++;
ffffffffc02003d8:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003da:	00044583          	lbu	a1,0(s0)
ffffffffc02003de:	ddad                	beqz	a1,ffffffffc0200358 <kmonitor+0x92>
ffffffffc02003e0:	854a                	mv	a0,s2
ffffffffc02003e2:	19a010ef          	jal	ra,ffffffffc020157c <strchr>
ffffffffc02003e6:	d96d                	beqz	a0,ffffffffc02003d8 <kmonitor+0x112>
ffffffffc02003e8:	00044583          	lbu	a1,0(s0)
ffffffffc02003ec:	bf91                	j	ffffffffc0200340 <kmonitor+0x7a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02003ee:	45c1                	li	a1,16
ffffffffc02003f0:	855a                	mv	a0,s6
ffffffffc02003f2:	cc5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc02003f6:	b7f1                	j	ffffffffc02003c2 <kmonitor+0xfc>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc02003f8:	6582                	ld	a1,0(sp)
ffffffffc02003fa:	00002517          	auipc	a0,0x2
ffffffffc02003fe:	8be50513          	addi	a0,a0,-1858 # ffffffffc0201cb8 <commands+0xc8>
ffffffffc0200402:	cb5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    return 0;
ffffffffc0200406:	b72d                	j	ffffffffc0200330 <kmonitor+0x6a>

ffffffffc0200408 <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
ffffffffc0200408:	1141                	addi	sp,sp,-16
ffffffffc020040a:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
ffffffffc020040c:	02000793          	li	a5,32
ffffffffc0200410:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200414:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200418:	67e1                	lui	a5,0x18
ffffffffc020041a:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc020041e:	953e                	add	a0,a0,a5
ffffffffc0200420:	652010ef          	jal	ra,ffffffffc0201a72 <sbi_set_timer>
}
ffffffffc0200424:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc0200426:	00006797          	auipc	a5,0x6
ffffffffc020042a:	0007b523          	sd	zero,10(a5) # ffffffffc0206430 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020042e:	00002517          	auipc	a0,0x2
ffffffffc0200432:	94250513          	addi	a0,a0,-1726 # ffffffffc0201d70 <commands+0x180>
}
ffffffffc0200436:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
ffffffffc0200438:	b9bd                	j	ffffffffc02000b6 <cprintf>

ffffffffc020043a <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020043a:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020043e:	67e1                	lui	a5,0x18
ffffffffc0200440:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc0200444:	953e                	add	a0,a0,a5
ffffffffc0200446:	62c0106f          	j	ffffffffc0201a72 <sbi_set_timer>

ffffffffc020044a <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc020044a:	8082                	ret

ffffffffc020044c <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
ffffffffc020044c:	0ff57513          	andi	a0,a0,255
ffffffffc0200450:	6060106f          	j	ffffffffc0201a56 <sbi_console_putchar>

ffffffffc0200454 <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc0200454:	63a0106f          	j	ffffffffc0201a8e <sbi_console_getchar>

ffffffffc0200458 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200458:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc020045c:	8082                	ret

ffffffffc020045e <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc020045e:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200462:	8082                	ret

ffffffffc0200464 <idt_init>:
     */

    extern void __alltraps(void);
    /* Set sup0 scratch register to 0, indicating to exception vector
       that we are presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc0200464:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc0200468:	00000797          	auipc	a5,0x0
ffffffffc020046c:	2ec78793          	addi	a5,a5,748 # ffffffffc0200754 <__alltraps>
ffffffffc0200470:	10579073          	csrw	stvec,a5
}
ffffffffc0200474:	8082                	ret

ffffffffc0200476 <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200476:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200478:	1141                	addi	sp,sp,-16
ffffffffc020047a:	e022                	sd	s0,0(sp)
ffffffffc020047c:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020047e:	00002517          	auipc	a0,0x2
ffffffffc0200482:	a0a50513          	addi	a0,a0,-1526 # ffffffffc0201e88 <commands+0x298>
void print_regs(struct pushregs *gpr) {
ffffffffc0200486:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200488:	c2fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020048c:	640c                	ld	a1,8(s0)
ffffffffc020048e:	00002517          	auipc	a0,0x2
ffffffffc0200492:	a1250513          	addi	a0,a0,-1518 # ffffffffc0201ea0 <commands+0x2b0>
ffffffffc0200496:	c21ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc020049a:	680c                	ld	a1,16(s0)
ffffffffc020049c:	00002517          	auipc	a0,0x2
ffffffffc02004a0:	a1c50513          	addi	a0,a0,-1508 # ffffffffc0201eb8 <commands+0x2c8>
ffffffffc02004a4:	c13ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004a8:	6c0c                	ld	a1,24(s0)
ffffffffc02004aa:	00002517          	auipc	a0,0x2
ffffffffc02004ae:	a2650513          	addi	a0,a0,-1498 # ffffffffc0201ed0 <commands+0x2e0>
ffffffffc02004b2:	c05ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004b6:	700c                	ld	a1,32(s0)
ffffffffc02004b8:	00002517          	auipc	a0,0x2
ffffffffc02004bc:	a3050513          	addi	a0,a0,-1488 # ffffffffc0201ee8 <commands+0x2f8>
ffffffffc02004c0:	bf7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004c4:	740c                	ld	a1,40(s0)
ffffffffc02004c6:	00002517          	auipc	a0,0x2
ffffffffc02004ca:	a3a50513          	addi	a0,a0,-1478 # ffffffffc0201f00 <commands+0x310>
ffffffffc02004ce:	be9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d2:	780c                	ld	a1,48(s0)
ffffffffc02004d4:	00002517          	auipc	a0,0x2
ffffffffc02004d8:	a4450513          	addi	a0,a0,-1468 # ffffffffc0201f18 <commands+0x328>
ffffffffc02004dc:	bdbff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e0:	7c0c                	ld	a1,56(s0)
ffffffffc02004e2:	00002517          	auipc	a0,0x2
ffffffffc02004e6:	a4e50513          	addi	a0,a0,-1458 # ffffffffc0201f30 <commands+0x340>
ffffffffc02004ea:	bcdff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004ee:	602c                	ld	a1,64(s0)
ffffffffc02004f0:	00002517          	auipc	a0,0x2
ffffffffc02004f4:	a5850513          	addi	a0,a0,-1448 # ffffffffc0201f48 <commands+0x358>
ffffffffc02004f8:	bbfff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02004fc:	642c                	ld	a1,72(s0)
ffffffffc02004fe:	00002517          	auipc	a0,0x2
ffffffffc0200502:	a6250513          	addi	a0,a0,-1438 # ffffffffc0201f60 <commands+0x370>
ffffffffc0200506:	bb1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc020050a:	682c                	ld	a1,80(s0)
ffffffffc020050c:	00002517          	auipc	a0,0x2
ffffffffc0200510:	a6c50513          	addi	a0,a0,-1428 # ffffffffc0201f78 <commands+0x388>
ffffffffc0200514:	ba3ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200518:	6c2c                	ld	a1,88(s0)
ffffffffc020051a:	00002517          	auipc	a0,0x2
ffffffffc020051e:	a7650513          	addi	a0,a0,-1418 # ffffffffc0201f90 <commands+0x3a0>
ffffffffc0200522:	b95ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200526:	702c                	ld	a1,96(s0)
ffffffffc0200528:	00002517          	auipc	a0,0x2
ffffffffc020052c:	a8050513          	addi	a0,a0,-1408 # ffffffffc0201fa8 <commands+0x3b8>
ffffffffc0200530:	b87ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200534:	742c                	ld	a1,104(s0)
ffffffffc0200536:	00002517          	auipc	a0,0x2
ffffffffc020053a:	a8a50513          	addi	a0,a0,-1398 # ffffffffc0201fc0 <commands+0x3d0>
ffffffffc020053e:	b79ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200542:	782c                	ld	a1,112(s0)
ffffffffc0200544:	00002517          	auipc	a0,0x2
ffffffffc0200548:	a9450513          	addi	a0,a0,-1388 # ffffffffc0201fd8 <commands+0x3e8>
ffffffffc020054c:	b6bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200550:	7c2c                	ld	a1,120(s0)
ffffffffc0200552:	00002517          	auipc	a0,0x2
ffffffffc0200556:	a9e50513          	addi	a0,a0,-1378 # ffffffffc0201ff0 <commands+0x400>
ffffffffc020055a:	b5dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020055e:	604c                	ld	a1,128(s0)
ffffffffc0200560:	00002517          	auipc	a0,0x2
ffffffffc0200564:	aa850513          	addi	a0,a0,-1368 # ffffffffc0202008 <commands+0x418>
ffffffffc0200568:	b4fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020056c:	644c                	ld	a1,136(s0)
ffffffffc020056e:	00002517          	auipc	a0,0x2
ffffffffc0200572:	ab250513          	addi	a0,a0,-1358 # ffffffffc0202020 <commands+0x430>
ffffffffc0200576:	b41ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020057a:	684c                	ld	a1,144(s0)
ffffffffc020057c:	00002517          	auipc	a0,0x2
ffffffffc0200580:	abc50513          	addi	a0,a0,-1348 # ffffffffc0202038 <commands+0x448>
ffffffffc0200584:	b33ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200588:	6c4c                	ld	a1,152(s0)
ffffffffc020058a:	00002517          	auipc	a0,0x2
ffffffffc020058e:	ac650513          	addi	a0,a0,-1338 # ffffffffc0202050 <commands+0x460>
ffffffffc0200592:	b25ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200596:	704c                	ld	a1,160(s0)
ffffffffc0200598:	00002517          	auipc	a0,0x2
ffffffffc020059c:	ad050513          	addi	a0,a0,-1328 # ffffffffc0202068 <commands+0x478>
ffffffffc02005a0:	b17ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005a4:	744c                	ld	a1,168(s0)
ffffffffc02005a6:	00002517          	auipc	a0,0x2
ffffffffc02005aa:	ada50513          	addi	a0,a0,-1318 # ffffffffc0202080 <commands+0x490>
ffffffffc02005ae:	b09ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b2:	784c                	ld	a1,176(s0)
ffffffffc02005b4:	00002517          	auipc	a0,0x2
ffffffffc02005b8:	ae450513          	addi	a0,a0,-1308 # ffffffffc0202098 <commands+0x4a8>
ffffffffc02005bc:	afbff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c0:	7c4c                	ld	a1,184(s0)
ffffffffc02005c2:	00002517          	auipc	a0,0x2
ffffffffc02005c6:	aee50513          	addi	a0,a0,-1298 # ffffffffc02020b0 <commands+0x4c0>
ffffffffc02005ca:	aedff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005ce:	606c                	ld	a1,192(s0)
ffffffffc02005d0:	00002517          	auipc	a0,0x2
ffffffffc02005d4:	af850513          	addi	a0,a0,-1288 # ffffffffc02020c8 <commands+0x4d8>
ffffffffc02005d8:	adfff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005dc:	646c                	ld	a1,200(s0)
ffffffffc02005de:	00002517          	auipc	a0,0x2
ffffffffc02005e2:	b0250513          	addi	a0,a0,-1278 # ffffffffc02020e0 <commands+0x4f0>
ffffffffc02005e6:	ad1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005ea:	686c                	ld	a1,208(s0)
ffffffffc02005ec:	00002517          	auipc	a0,0x2
ffffffffc02005f0:	b0c50513          	addi	a0,a0,-1268 # ffffffffc02020f8 <commands+0x508>
ffffffffc02005f4:	ac3ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005f8:	6c6c                	ld	a1,216(s0)
ffffffffc02005fa:	00002517          	auipc	a0,0x2
ffffffffc02005fe:	b1650513          	addi	a0,a0,-1258 # ffffffffc0202110 <commands+0x520>
ffffffffc0200602:	ab5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200606:	706c                	ld	a1,224(s0)
ffffffffc0200608:	00002517          	auipc	a0,0x2
ffffffffc020060c:	b2050513          	addi	a0,a0,-1248 # ffffffffc0202128 <commands+0x538>
ffffffffc0200610:	aa7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200614:	746c                	ld	a1,232(s0)
ffffffffc0200616:	00002517          	auipc	a0,0x2
ffffffffc020061a:	b2a50513          	addi	a0,a0,-1238 # ffffffffc0202140 <commands+0x550>
ffffffffc020061e:	a99ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200622:	786c                	ld	a1,240(s0)
ffffffffc0200624:	00002517          	auipc	a0,0x2
ffffffffc0200628:	b3450513          	addi	a0,a0,-1228 # ffffffffc0202158 <commands+0x568>
ffffffffc020062c:	a8bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200630:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200632:	6402                	ld	s0,0(sp)
ffffffffc0200634:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	00002517          	auipc	a0,0x2
ffffffffc020063a:	b3a50513          	addi	a0,a0,-1222 # ffffffffc0202170 <commands+0x580>
}
ffffffffc020063e:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200640:	bc9d                	j	ffffffffc02000b6 <cprintf>

ffffffffc0200642 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc0200642:	1141                	addi	sp,sp,-16
ffffffffc0200644:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200646:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200648:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc020064a:	00002517          	auipc	a0,0x2
ffffffffc020064e:	b3e50513          	addi	a0,a0,-1218 # ffffffffc0202188 <commands+0x598>
void print_trapframe(struct trapframe *tf) {
ffffffffc0200652:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200654:	a63ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200658:	8522                	mv	a0,s0
ffffffffc020065a:	e1dff0ef          	jal	ra,ffffffffc0200476 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020065e:	10043583          	ld	a1,256(s0)
ffffffffc0200662:	00002517          	auipc	a0,0x2
ffffffffc0200666:	b3e50513          	addi	a0,a0,-1218 # ffffffffc02021a0 <commands+0x5b0>
ffffffffc020066a:	a4dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020066e:	10843583          	ld	a1,264(s0)
ffffffffc0200672:	00002517          	auipc	a0,0x2
ffffffffc0200676:	b4650513          	addi	a0,a0,-1210 # ffffffffc02021b8 <commands+0x5c8>
ffffffffc020067a:	a3dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020067e:	11043583          	ld	a1,272(s0)
ffffffffc0200682:	00002517          	auipc	a0,0x2
ffffffffc0200686:	b4e50513          	addi	a0,a0,-1202 # ffffffffc02021d0 <commands+0x5e0>
ffffffffc020068a:	a2dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020068e:	11843583          	ld	a1,280(s0)
}
ffffffffc0200692:	6402                	ld	s0,0(sp)
ffffffffc0200694:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	00002517          	auipc	a0,0x2
ffffffffc020069a:	b5250513          	addi	a0,a0,-1198 # ffffffffc02021e8 <commands+0x5f8>
}
ffffffffc020069e:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02006a0:	bc19                	j	ffffffffc02000b6 <cprintf>

ffffffffc02006a2 <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02006a2:	11853783          	ld	a5,280(a0)
    switch (cause) {
ffffffffc02006a6:	472d                	li	a4,11
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02006a8:	0786                	slli	a5,a5,0x1
ffffffffc02006aa:	8385                	srli	a5,a5,0x1
    switch (cause) {
ffffffffc02006ac:	06f76f63          	bltu	a4,a5,ffffffffc020072a <interrupt_handler+0x88>
ffffffffc02006b0:	00001717          	auipc	a4,0x1
ffffffffc02006b4:	6dc70713          	addi	a4,a4,1756 # ffffffffc0201d8c <commands+0x19c>
ffffffffc02006b8:	078a                	slli	a5,a5,0x2
ffffffffc02006ba:	97ba                	add	a5,a5,a4
ffffffffc02006bc:	439c                	lw	a5,0(a5)
ffffffffc02006be:	97ba                	add	a5,a5,a4
ffffffffc02006c0:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02006c2:	00001517          	auipc	a0,0x1
ffffffffc02006c6:	75e50513          	addi	a0,a0,1886 # ffffffffc0201e20 <commands+0x230>
ffffffffc02006ca:	b2f5                	j	ffffffffc02000b6 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006cc:	00001517          	auipc	a0,0x1
ffffffffc02006d0:	73450513          	addi	a0,a0,1844 # ffffffffc0201e00 <commands+0x210>
ffffffffc02006d4:	b2cd                	j	ffffffffc02000b6 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006d6:	00001517          	auipc	a0,0x1
ffffffffc02006da:	6ea50513          	addi	a0,a0,1770 # ffffffffc0201dc0 <commands+0x1d0>
ffffffffc02006de:	bae1                	j	ffffffffc02000b6 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006e0:	00001517          	auipc	a0,0x1
ffffffffc02006e4:	76050513          	addi	a0,a0,1888 # ffffffffc0201e40 <commands+0x250>
ffffffffc02006e8:	b2f9                	j	ffffffffc02000b6 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02006ea:	1141                	addi	sp,sp,-16
ffffffffc02006ec:	e406                	sd	ra,8(sp)
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // cprintf("Supervisor timer interrupt\n");
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc02006ee:	d4dff0ef          	jal	ra,ffffffffc020043a <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc02006f2:	00006797          	auipc	a5,0x6
ffffffffc02006f6:	d3e78793          	addi	a5,a5,-706 # ffffffffc0206430 <ticks>
ffffffffc02006fa:	639c                	ld	a5,0(a5)
ffffffffc02006fc:	06400713          	li	a4,100
ffffffffc0200700:	0785                	addi	a5,a5,1
ffffffffc0200702:	02e7f733          	remu	a4,a5,a4
ffffffffc0200706:	00006697          	auipc	a3,0x6
ffffffffc020070a:	d2f6b523          	sd	a5,-726(a3) # ffffffffc0206430 <ticks>
ffffffffc020070e:	cf19                	beqz	a4,ffffffffc020072c <interrupt_handler+0x8a>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200710:	60a2                	ld	ra,8(sp)
ffffffffc0200712:	0141                	addi	sp,sp,16
ffffffffc0200714:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc0200716:	00001517          	auipc	a0,0x1
ffffffffc020071a:	75250513          	addi	a0,a0,1874 # ffffffffc0201e68 <commands+0x278>
ffffffffc020071e:	ba61                	j	ffffffffc02000b6 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200720:	00001517          	auipc	a0,0x1
ffffffffc0200724:	6c050513          	addi	a0,a0,1728 # ffffffffc0201de0 <commands+0x1f0>
ffffffffc0200728:	b279                	j	ffffffffc02000b6 <cprintf>
            print_trapframe(tf);
ffffffffc020072a:	bf21                	j	ffffffffc0200642 <print_trapframe>
}
ffffffffc020072c:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc020072e:	06400593          	li	a1,100
ffffffffc0200732:	00001517          	auipc	a0,0x1
ffffffffc0200736:	72650513          	addi	a0,a0,1830 # ffffffffc0201e58 <commands+0x268>
}
ffffffffc020073a:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc020073c:	baad                	j	ffffffffc02000b6 <cprintf>

ffffffffc020073e <trap>:
            break;
    }
}

static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
ffffffffc020073e:	11853783          	ld	a5,280(a0)
ffffffffc0200742:	0007c763          	bltz	a5,ffffffffc0200750 <trap+0x12>
    switch (tf->cause) {
ffffffffc0200746:	472d                	li	a4,11
ffffffffc0200748:	00f76363          	bltu	a4,a5,ffffffffc020074e <trap+0x10>
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
}
ffffffffc020074c:	8082                	ret
            print_trapframe(tf);
ffffffffc020074e:	bdd5                	j	ffffffffc0200642 <print_trapframe>
        interrupt_handler(tf);
ffffffffc0200750:	bf89                	j	ffffffffc02006a2 <interrupt_handler>
	...

ffffffffc0200754 <__alltraps>:
    .endm

    .globl __alltraps
    .align(2)
__alltraps:
    SAVE_ALL
ffffffffc0200754:	14011073          	csrw	sscratch,sp
ffffffffc0200758:	712d                	addi	sp,sp,-288
ffffffffc020075a:	e002                	sd	zero,0(sp)
ffffffffc020075c:	e406                	sd	ra,8(sp)
ffffffffc020075e:	ec0e                	sd	gp,24(sp)
ffffffffc0200760:	f012                	sd	tp,32(sp)
ffffffffc0200762:	f416                	sd	t0,40(sp)
ffffffffc0200764:	f81a                	sd	t1,48(sp)
ffffffffc0200766:	fc1e                	sd	t2,56(sp)
ffffffffc0200768:	e0a2                	sd	s0,64(sp)
ffffffffc020076a:	e4a6                	sd	s1,72(sp)
ffffffffc020076c:	e8aa                	sd	a0,80(sp)
ffffffffc020076e:	ecae                	sd	a1,88(sp)
ffffffffc0200770:	f0b2                	sd	a2,96(sp)
ffffffffc0200772:	f4b6                	sd	a3,104(sp)
ffffffffc0200774:	f8ba                	sd	a4,112(sp)
ffffffffc0200776:	fcbe                	sd	a5,120(sp)
ffffffffc0200778:	e142                	sd	a6,128(sp)
ffffffffc020077a:	e546                	sd	a7,136(sp)
ffffffffc020077c:	e94a                	sd	s2,144(sp)
ffffffffc020077e:	ed4e                	sd	s3,152(sp)
ffffffffc0200780:	f152                	sd	s4,160(sp)
ffffffffc0200782:	f556                	sd	s5,168(sp)
ffffffffc0200784:	f95a                	sd	s6,176(sp)
ffffffffc0200786:	fd5e                	sd	s7,184(sp)
ffffffffc0200788:	e1e2                	sd	s8,192(sp)
ffffffffc020078a:	e5e6                	sd	s9,200(sp)
ffffffffc020078c:	e9ea                	sd	s10,208(sp)
ffffffffc020078e:	edee                	sd	s11,216(sp)
ffffffffc0200790:	f1f2                	sd	t3,224(sp)
ffffffffc0200792:	f5f6                	sd	t4,232(sp)
ffffffffc0200794:	f9fa                	sd	t5,240(sp)
ffffffffc0200796:	fdfe                	sd	t6,248(sp)
ffffffffc0200798:	14001473          	csrrw	s0,sscratch,zero
ffffffffc020079c:	100024f3          	csrr	s1,sstatus
ffffffffc02007a0:	14102973          	csrr	s2,sepc
ffffffffc02007a4:	143029f3          	csrr	s3,stval
ffffffffc02007a8:	14202a73          	csrr	s4,scause
ffffffffc02007ac:	e822                	sd	s0,16(sp)
ffffffffc02007ae:	e226                	sd	s1,256(sp)
ffffffffc02007b0:	e64a                	sd	s2,264(sp)
ffffffffc02007b2:	ea4e                	sd	s3,272(sp)
ffffffffc02007b4:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc02007b6:	850a                	mv	a0,sp
    jal trap
ffffffffc02007b8:	f87ff0ef          	jal	ra,ffffffffc020073e <trap>

ffffffffc02007bc <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc02007bc:	6492                	ld	s1,256(sp)
ffffffffc02007be:	6932                	ld	s2,264(sp)
ffffffffc02007c0:	10049073          	csrw	sstatus,s1
ffffffffc02007c4:	14191073          	csrw	sepc,s2
ffffffffc02007c8:	60a2                	ld	ra,8(sp)
ffffffffc02007ca:	61e2                	ld	gp,24(sp)
ffffffffc02007cc:	7202                	ld	tp,32(sp)
ffffffffc02007ce:	72a2                	ld	t0,40(sp)
ffffffffc02007d0:	7342                	ld	t1,48(sp)
ffffffffc02007d2:	73e2                	ld	t2,56(sp)
ffffffffc02007d4:	6406                	ld	s0,64(sp)
ffffffffc02007d6:	64a6                	ld	s1,72(sp)
ffffffffc02007d8:	6546                	ld	a0,80(sp)
ffffffffc02007da:	65e6                	ld	a1,88(sp)
ffffffffc02007dc:	7606                	ld	a2,96(sp)
ffffffffc02007de:	76a6                	ld	a3,104(sp)
ffffffffc02007e0:	7746                	ld	a4,112(sp)
ffffffffc02007e2:	77e6                	ld	a5,120(sp)
ffffffffc02007e4:	680a                	ld	a6,128(sp)
ffffffffc02007e6:	68aa                	ld	a7,136(sp)
ffffffffc02007e8:	694a                	ld	s2,144(sp)
ffffffffc02007ea:	69ea                	ld	s3,152(sp)
ffffffffc02007ec:	7a0a                	ld	s4,160(sp)
ffffffffc02007ee:	7aaa                	ld	s5,168(sp)
ffffffffc02007f0:	7b4a                	ld	s6,176(sp)
ffffffffc02007f2:	7bea                	ld	s7,184(sp)
ffffffffc02007f4:	6c0e                	ld	s8,192(sp)
ffffffffc02007f6:	6cae                	ld	s9,200(sp)
ffffffffc02007f8:	6d4e                	ld	s10,208(sp)
ffffffffc02007fa:	6dee                	ld	s11,216(sp)
ffffffffc02007fc:	7e0e                	ld	t3,224(sp)
ffffffffc02007fe:	7eae                	ld	t4,232(sp)
ffffffffc0200800:	7f4e                	ld	t5,240(sp)
ffffffffc0200802:	7fee                	ld	t6,248(sp)
ffffffffc0200804:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200806:	10200073          	sret

ffffffffc020080a <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020080a:	100027f3          	csrr	a5,sstatus
ffffffffc020080e:	8b89                	andi	a5,a5,2
ffffffffc0200810:	eb89                	bnez	a5,ffffffffc0200822 <alloc_pages+0x18>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc0200812:	00006797          	auipc	a5,0x6
ffffffffc0200816:	c2e78793          	addi	a5,a5,-978 # ffffffffc0206440 <pmm_manager>
ffffffffc020081a:	639c                	ld	a5,0(a5)
ffffffffc020081c:	0187b303          	ld	t1,24(a5)
ffffffffc0200820:	8302                	jr	t1
struct Page *alloc_pages(size_t n) {
ffffffffc0200822:	1141                	addi	sp,sp,-16
ffffffffc0200824:	e406                	sd	ra,8(sp)
ffffffffc0200826:	e022                	sd	s0,0(sp)
ffffffffc0200828:	842a                	mv	s0,a0
        intr_disable();
ffffffffc020082a:	c35ff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc020082e:	00006797          	auipc	a5,0x6
ffffffffc0200832:	c1278793          	addi	a5,a5,-1006 # ffffffffc0206440 <pmm_manager>
ffffffffc0200836:	639c                	ld	a5,0(a5)
ffffffffc0200838:	8522                	mv	a0,s0
ffffffffc020083a:	6f9c                	ld	a5,24(a5)
ffffffffc020083c:	9782                	jalr	a5
ffffffffc020083e:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc0200840:	c19ff0ef          	jal	ra,ffffffffc0200458 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc0200844:	8522                	mv	a0,s0
ffffffffc0200846:	60a2                	ld	ra,8(sp)
ffffffffc0200848:	6402                	ld	s0,0(sp)
ffffffffc020084a:	0141                	addi	sp,sp,16
ffffffffc020084c:	8082                	ret

ffffffffc020084e <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020084e:	100027f3          	csrr	a5,sstatus
ffffffffc0200852:	8b89                	andi	a5,a5,2
ffffffffc0200854:	eb89                	bnez	a5,ffffffffc0200866 <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0200856:	00006797          	auipc	a5,0x6
ffffffffc020085a:	bea78793          	addi	a5,a5,-1046 # ffffffffc0206440 <pmm_manager>
ffffffffc020085e:	639c                	ld	a5,0(a5)
ffffffffc0200860:	0207b303          	ld	t1,32(a5)
ffffffffc0200864:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc0200866:	1101                	addi	sp,sp,-32
ffffffffc0200868:	ec06                	sd	ra,24(sp)
ffffffffc020086a:	e822                	sd	s0,16(sp)
ffffffffc020086c:	e426                	sd	s1,8(sp)
ffffffffc020086e:	842a                	mv	s0,a0
ffffffffc0200870:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0200872:	bedff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0200876:	00006797          	auipc	a5,0x6
ffffffffc020087a:	bca78793          	addi	a5,a5,-1078 # ffffffffc0206440 <pmm_manager>
ffffffffc020087e:	639c                	ld	a5,0(a5)
ffffffffc0200880:	85a6                	mv	a1,s1
ffffffffc0200882:	8522                	mv	a0,s0
ffffffffc0200884:	739c                	ld	a5,32(a5)
ffffffffc0200886:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200888:	6442                	ld	s0,16(sp)
ffffffffc020088a:	60e2                	ld	ra,24(sp)
ffffffffc020088c:	64a2                	ld	s1,8(sp)
ffffffffc020088e:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200890:	b6e1                	j	ffffffffc0200458 <intr_enable>

ffffffffc0200892 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200892:	100027f3          	csrr	a5,sstatus
ffffffffc0200896:	8b89                	andi	a5,a5,2
ffffffffc0200898:	eb89                	bnez	a5,ffffffffc02008aa <nr_free_pages+0x18>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc020089a:	00006797          	auipc	a5,0x6
ffffffffc020089e:	ba678793          	addi	a5,a5,-1114 # ffffffffc0206440 <pmm_manager>
ffffffffc02008a2:	639c                	ld	a5,0(a5)
ffffffffc02008a4:	0287b303          	ld	t1,40(a5)
ffffffffc02008a8:	8302                	jr	t1
size_t nr_free_pages(void) {
ffffffffc02008aa:	1141                	addi	sp,sp,-16
ffffffffc02008ac:	e406                	sd	ra,8(sp)
ffffffffc02008ae:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc02008b0:	bafff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc02008b4:	00006797          	auipc	a5,0x6
ffffffffc02008b8:	b8c78793          	addi	a5,a5,-1140 # ffffffffc0206440 <pmm_manager>
ffffffffc02008bc:	639c                	ld	a5,0(a5)
ffffffffc02008be:	779c                	ld	a5,40(a5)
ffffffffc02008c0:	9782                	jalr	a5
ffffffffc02008c2:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02008c4:	b95ff0ef          	jal	ra,ffffffffc0200458 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc02008c8:	8522                	mv	a0,s0
ffffffffc02008ca:	60a2                	ld	ra,8(sp)
ffffffffc02008cc:	6402                	ld	s0,0(sp)
ffffffffc02008ce:	0141                	addi	sp,sp,16
ffffffffc02008d0:	8082                	ret

ffffffffc02008d2 <pmm_init>:
    pmm_manager = &best_fit_pmm_manager;
ffffffffc02008d2:	00002797          	auipc	a5,0x2
ffffffffc02008d6:	d8e78793          	addi	a5,a5,-626 # ffffffffc0202660 <best_fit_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02008da:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc02008dc:	1101                	addi	sp,sp,-32
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02008de:	00002517          	auipc	a0,0x2
ffffffffc02008e2:	92250513          	addi	a0,a0,-1758 # ffffffffc0202200 <commands+0x610>
void pmm_init(void) {
ffffffffc02008e6:	ec06                	sd	ra,24(sp)
    pmm_manager = &best_fit_pmm_manager;
ffffffffc02008e8:	00006717          	auipc	a4,0x6
ffffffffc02008ec:	b4f73c23          	sd	a5,-1192(a4) # ffffffffc0206440 <pmm_manager>
void pmm_init(void) {
ffffffffc02008f0:	e822                	sd	s0,16(sp)
ffffffffc02008f2:	e426                	sd	s1,8(sp)
    pmm_manager = &best_fit_pmm_manager;
ffffffffc02008f4:	00006417          	auipc	s0,0x6
ffffffffc02008f8:	b4c40413          	addi	s0,s0,-1204 # ffffffffc0206440 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02008fc:	fbaff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pmm_manager->init();
ffffffffc0200900:	601c                	ld	a5,0(s0)
ffffffffc0200902:	679c                	ld	a5,8(a5)
ffffffffc0200904:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200906:	57f5                	li	a5,-3
ffffffffc0200908:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc020090a:	00002517          	auipc	a0,0x2
ffffffffc020090e:	90e50513          	addi	a0,a0,-1778 # ffffffffc0202218 <commands+0x628>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200912:	00006717          	auipc	a4,0x6
ffffffffc0200916:	b2f73b23          	sd	a5,-1226(a4) # ffffffffc0206448 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc020091a:	f9cff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc020091e:	46c5                	li	a3,17
ffffffffc0200920:	06ee                	slli	a3,a3,0x1b
ffffffffc0200922:	40100613          	li	a2,1025
ffffffffc0200926:	16fd                	addi	a3,a3,-1
ffffffffc0200928:	0656                	slli	a2,a2,0x15
ffffffffc020092a:	07e005b7          	lui	a1,0x7e00
ffffffffc020092e:	00002517          	auipc	a0,0x2
ffffffffc0200932:	90250513          	addi	a0,a0,-1790 # ffffffffc0202230 <commands+0x640>
ffffffffc0200936:	f80ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020093a:	777d                	lui	a4,0xfffff
ffffffffc020093c:	00007797          	auipc	a5,0x7
ffffffffc0200940:	b3378793          	addi	a5,a5,-1229 # ffffffffc020746f <end+0xfff>
ffffffffc0200944:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0200946:	00088737          	lui	a4,0x88
ffffffffc020094a:	00006697          	auipc	a3,0x6
ffffffffc020094e:	ace6b723          	sd	a4,-1330(a3) # ffffffffc0206418 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200952:	4601                	li	a2,0
ffffffffc0200954:	00006717          	auipc	a4,0x6
ffffffffc0200958:	aef73e23          	sd	a5,-1284(a4) # ffffffffc0206450 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020095c:	4681                	li	a3,0
ffffffffc020095e:	00006897          	auipc	a7,0x6
ffffffffc0200962:	aba88893          	addi	a7,a7,-1350 # ffffffffc0206418 <npage>
ffffffffc0200966:	00006597          	auipc	a1,0x6
ffffffffc020096a:	aea58593          	addi	a1,a1,-1302 # ffffffffc0206450 <pages>
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020096e:	4805                	li	a6,1
ffffffffc0200970:	fff80537          	lui	a0,0xfff80
ffffffffc0200974:	a011                	j	ffffffffc0200978 <pmm_init+0xa6>
ffffffffc0200976:	619c                	ld	a5,0(a1)
        SetPageReserved(pages + i);
ffffffffc0200978:	97b2                	add	a5,a5,a2
ffffffffc020097a:	07a1                	addi	a5,a5,8
ffffffffc020097c:	4107b02f          	amoor.d	zero,a6,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200980:	0008b703          	ld	a4,0(a7)
ffffffffc0200984:	0685                	addi	a3,a3,1
ffffffffc0200986:	02860613          	addi	a2,a2,40
ffffffffc020098a:	00a707b3          	add	a5,a4,a0
ffffffffc020098e:	fef6e4e3          	bltu	a3,a5,ffffffffc0200976 <pmm_init+0xa4>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200992:	6190                	ld	a2,0(a1)
ffffffffc0200994:	00271793          	slli	a5,a4,0x2
ffffffffc0200998:	97ba                	add	a5,a5,a4
ffffffffc020099a:	fec006b7          	lui	a3,0xfec00
ffffffffc020099e:	078e                	slli	a5,a5,0x3
ffffffffc02009a0:	96b2                	add	a3,a3,a2
ffffffffc02009a2:	96be                	add	a3,a3,a5
ffffffffc02009a4:	c02007b7          	lui	a5,0xc0200
ffffffffc02009a8:	08f6e863          	bltu	a3,a5,ffffffffc0200a38 <pmm_init+0x166>
ffffffffc02009ac:	00006497          	auipc	s1,0x6
ffffffffc02009b0:	a9c48493          	addi	s1,s1,-1380 # ffffffffc0206448 <va_pa_offset>
ffffffffc02009b4:	609c                	ld	a5,0(s1)
    if (freemem < mem_end) {
ffffffffc02009b6:	45c5                	li	a1,17
ffffffffc02009b8:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02009ba:	8e9d                	sub	a3,a3,a5
    if (freemem < mem_end) {
ffffffffc02009bc:	04b6e963          	bltu	a3,a1,ffffffffc0200a0e <pmm_init+0x13c>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc02009c0:	601c                	ld	a5,0(s0)
ffffffffc02009c2:	7b9c                	ld	a5,48(a5)
ffffffffc02009c4:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc02009c6:	00002517          	auipc	a0,0x2
ffffffffc02009ca:	90250513          	addi	a0,a0,-1790 # ffffffffc02022c8 <commands+0x6d8>
ffffffffc02009ce:	ee8ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc02009d2:	00004697          	auipc	a3,0x4
ffffffffc02009d6:	62e68693          	addi	a3,a3,1582 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc02009da:	00006797          	auipc	a5,0x6
ffffffffc02009de:	a4d7b323          	sd	a3,-1466(a5) # ffffffffc0206420 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc02009e2:	c02007b7          	lui	a5,0xc0200
ffffffffc02009e6:	06f6e563          	bltu	a3,a5,ffffffffc0200a50 <pmm_init+0x17e>
ffffffffc02009ea:	609c                	ld	a5,0(s1)
}
ffffffffc02009ec:	6442                	ld	s0,16(sp)
ffffffffc02009ee:	60e2                	ld	ra,24(sp)
ffffffffc02009f0:	64a2                	ld	s1,8(sp)
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02009f2:	85b6                	mv	a1,a3
    satp_physical = PADDR(satp_virtual);
ffffffffc02009f4:	8e9d                	sub	a3,a3,a5
ffffffffc02009f6:	00006797          	auipc	a5,0x6
ffffffffc02009fa:	a4d7b123          	sd	a3,-1470(a5) # ffffffffc0206438 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02009fe:	00002517          	auipc	a0,0x2
ffffffffc0200a02:	8ea50513          	addi	a0,a0,-1814 # ffffffffc02022e8 <commands+0x6f8>
ffffffffc0200a06:	8636                	mv	a2,a3
}
ffffffffc0200a08:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200a0a:	eacff06f          	j	ffffffffc02000b6 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0200a0e:	6785                	lui	a5,0x1
ffffffffc0200a10:	17fd                	addi	a5,a5,-1
ffffffffc0200a12:	96be                	add	a3,a3,a5
ffffffffc0200a14:	77fd                	lui	a5,0xfffff
ffffffffc0200a16:	8efd                	and	a3,a3,a5
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc0200a18:	00c6d793          	srli	a5,a3,0xc
ffffffffc0200a1c:	04e7f663          	bgeu	a5,a4,ffffffffc0200a68 <pmm_init+0x196>
    pmm_manager->init_memmap(base, n);
ffffffffc0200a20:	6018                	ld	a4,0(s0)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0200a22:	97aa                	add	a5,a5,a0
ffffffffc0200a24:	00279513          	slli	a0,a5,0x2
ffffffffc0200a28:	953e                	add	a0,a0,a5
ffffffffc0200a2a:	6b1c                	ld	a5,16(a4)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0200a2c:	8d95                	sub	a1,a1,a3
ffffffffc0200a2e:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0200a30:	81b1                	srli	a1,a1,0xc
ffffffffc0200a32:	9532                	add	a0,a0,a2
ffffffffc0200a34:	9782                	jalr	a5
ffffffffc0200a36:	b769                	j	ffffffffc02009c0 <pmm_init+0xee>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200a38:	00002617          	auipc	a2,0x2
ffffffffc0200a3c:	82860613          	addi	a2,a2,-2008 # ffffffffc0202260 <commands+0x670>
ffffffffc0200a40:	06e00593          	li	a1,110
ffffffffc0200a44:	00002517          	auipc	a0,0x2
ffffffffc0200a48:	84450513          	addi	a0,a0,-1980 # ffffffffc0202288 <commands+0x698>
ffffffffc0200a4c:	ef0ff0ef          	jal	ra,ffffffffc020013c <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc0200a50:	00002617          	auipc	a2,0x2
ffffffffc0200a54:	81060613          	addi	a2,a2,-2032 # ffffffffc0202260 <commands+0x670>
ffffffffc0200a58:	08900593          	li	a1,137
ffffffffc0200a5c:	00002517          	auipc	a0,0x2
ffffffffc0200a60:	82c50513          	addi	a0,a0,-2004 # ffffffffc0202288 <commands+0x698>
ffffffffc0200a64:	ed8ff0ef          	jal	ra,ffffffffc020013c <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0200a68:	00002617          	auipc	a2,0x2
ffffffffc0200a6c:	83060613          	addi	a2,a2,-2000 # ffffffffc0202298 <commands+0x6a8>
ffffffffc0200a70:	06b00593          	li	a1,107
ffffffffc0200a74:	00002517          	auipc	a0,0x2
ffffffffc0200a78:	84450513          	addi	a0,a0,-1980 # ffffffffc02022b8 <commands+0x6c8>
ffffffffc0200a7c:	ec0ff0ef          	jal	ra,ffffffffc020013c <__panic>

ffffffffc0200a80 <best_fit_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200a80:	00006797          	auipc	a5,0x6
ffffffffc0200a84:	9d878793          	addi	a5,a5,-1576 # ffffffffc0206458 <free_area>
ffffffffc0200a88:	e79c                	sd	a5,8(a5)
ffffffffc0200a8a:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
best_fit_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200a8c:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200a90:	8082                	ret

ffffffffc0200a92 <best_fit_nr_free_pages>:
}

static size_t
best_fit_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200a92:	00006517          	auipc	a0,0x6
ffffffffc0200a96:	9d656503          	lwu	a0,-1578(a0) # ffffffffc0206468 <free_area+0x10>
ffffffffc0200a9a:	8082                	ret

ffffffffc0200a9c <best_fit_check>:
}

// LAB2: below code is used to check the best fit allocation algorithm 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
best_fit_check(void) {
ffffffffc0200a9c:	715d                	addi	sp,sp,-80
ffffffffc0200a9e:	f84a                	sd	s2,48(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200aa0:	00006917          	auipc	s2,0x6
ffffffffc0200aa4:	9b890913          	addi	s2,s2,-1608 # ffffffffc0206458 <free_area>
ffffffffc0200aa8:	00893783          	ld	a5,8(s2)
ffffffffc0200aac:	e486                	sd	ra,72(sp)
ffffffffc0200aae:	e0a2                	sd	s0,64(sp)
ffffffffc0200ab0:	fc26                	sd	s1,56(sp)
ffffffffc0200ab2:	f44e                	sd	s3,40(sp)
ffffffffc0200ab4:	f052                	sd	s4,32(sp)
ffffffffc0200ab6:	ec56                	sd	s5,24(sp)
ffffffffc0200ab8:	e85a                	sd	s6,16(sp)
ffffffffc0200aba:	e45e                	sd	s7,8(sp)
ffffffffc0200abc:	e062                	sd	s8,0(sp)
    int score = 0 ,sumscore = 6;
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200abe:	2d278363          	beq	a5,s2,ffffffffc0200d84 <best_fit_check+0x2e8>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200ac2:	ff07b703          	ld	a4,-16(a5)
ffffffffc0200ac6:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200ac8:	8b05                	andi	a4,a4,1
ffffffffc0200aca:	2c070163          	beqz	a4,ffffffffc0200d8c <best_fit_check+0x2f0>
    int count = 0, total = 0;
ffffffffc0200ace:	4401                	li	s0,0
ffffffffc0200ad0:	4481                	li	s1,0
ffffffffc0200ad2:	a031                	j	ffffffffc0200ade <best_fit_check+0x42>
ffffffffc0200ad4:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc0200ad8:	8b09                	andi	a4,a4,2
ffffffffc0200ada:	2a070963          	beqz	a4,ffffffffc0200d8c <best_fit_check+0x2f0>
        count ++, total += p->property;
ffffffffc0200ade:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200ae2:	679c                	ld	a5,8(a5)
ffffffffc0200ae4:	2485                	addiw	s1,s1,1
ffffffffc0200ae6:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200ae8:	ff2796e3          	bne	a5,s2,ffffffffc0200ad4 <best_fit_check+0x38>
ffffffffc0200aec:	89a2                	mv	s3,s0
    }
    assert(total == nr_free_pages());
ffffffffc0200aee:	da5ff0ef          	jal	ra,ffffffffc0200892 <nr_free_pages>
ffffffffc0200af2:	37351d63          	bne	a0,s3,ffffffffc0200e6c <best_fit_check+0x3d0>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200af6:	4505                	li	a0,1
ffffffffc0200af8:	d13ff0ef          	jal	ra,ffffffffc020080a <alloc_pages>
ffffffffc0200afc:	8a2a                	mv	s4,a0
ffffffffc0200afe:	3a050763          	beqz	a0,ffffffffc0200eac <best_fit_check+0x410>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200b02:	4505                	li	a0,1
ffffffffc0200b04:	d07ff0ef          	jal	ra,ffffffffc020080a <alloc_pages>
ffffffffc0200b08:	89aa                	mv	s3,a0
ffffffffc0200b0a:	38050163          	beqz	a0,ffffffffc0200e8c <best_fit_check+0x3f0>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200b0e:	4505                	li	a0,1
ffffffffc0200b10:	cfbff0ef          	jal	ra,ffffffffc020080a <alloc_pages>
ffffffffc0200b14:	8aaa                	mv	s5,a0
ffffffffc0200b16:	30050b63          	beqz	a0,ffffffffc0200e2c <best_fit_check+0x390>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200b1a:	293a0963          	beq	s4,s3,ffffffffc0200dac <best_fit_check+0x310>
ffffffffc0200b1e:	28aa0763          	beq	s4,a0,ffffffffc0200dac <best_fit_check+0x310>
ffffffffc0200b22:	28a98563          	beq	s3,a0,ffffffffc0200dac <best_fit_check+0x310>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200b26:	000a2783          	lw	a5,0(s4)
ffffffffc0200b2a:	2a079163          	bnez	a5,ffffffffc0200dcc <best_fit_check+0x330>
ffffffffc0200b2e:	0009a783          	lw	a5,0(s3)
ffffffffc0200b32:	28079d63          	bnez	a5,ffffffffc0200dcc <best_fit_check+0x330>
ffffffffc0200b36:	411c                	lw	a5,0(a0)
ffffffffc0200b38:	28079a63          	bnez	a5,ffffffffc0200dcc <best_fit_check+0x330>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200b3c:	00006797          	auipc	a5,0x6
ffffffffc0200b40:	91478793          	addi	a5,a5,-1772 # ffffffffc0206450 <pages>
ffffffffc0200b44:	639c                	ld	a5,0(a5)
ffffffffc0200b46:	00001717          	auipc	a4,0x1
ffffffffc0200b4a:	7e270713          	addi	a4,a4,2018 # ffffffffc0202328 <commands+0x738>
ffffffffc0200b4e:	630c                	ld	a1,0(a4)
ffffffffc0200b50:	40fa0733          	sub	a4,s4,a5
ffffffffc0200b54:	870d                	srai	a4,a4,0x3
ffffffffc0200b56:	02b70733          	mul	a4,a4,a1
ffffffffc0200b5a:	00002697          	auipc	a3,0x2
ffffffffc0200b5e:	d9e68693          	addi	a3,a3,-610 # ffffffffc02028f8 <nbase>
ffffffffc0200b62:	6290                	ld	a2,0(a3)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200b64:	00006697          	auipc	a3,0x6
ffffffffc0200b68:	8b468693          	addi	a3,a3,-1868 # ffffffffc0206418 <npage>
ffffffffc0200b6c:	6294                	ld	a3,0(a3)
ffffffffc0200b6e:	06b2                	slli	a3,a3,0xc
ffffffffc0200b70:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200b72:	0732                	slli	a4,a4,0xc
ffffffffc0200b74:	26d77c63          	bgeu	a4,a3,ffffffffc0200dec <best_fit_check+0x350>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200b78:	40f98733          	sub	a4,s3,a5
ffffffffc0200b7c:	870d                	srai	a4,a4,0x3
ffffffffc0200b7e:	02b70733          	mul	a4,a4,a1
ffffffffc0200b82:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200b84:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200b86:	42d77363          	bgeu	a4,a3,ffffffffc0200fac <best_fit_check+0x510>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200b8a:	40f507b3          	sub	a5,a0,a5
ffffffffc0200b8e:	878d                	srai	a5,a5,0x3
ffffffffc0200b90:	02b787b3          	mul	a5,a5,a1
ffffffffc0200b94:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200b96:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200b98:	3ed7fa63          	bgeu	a5,a3,ffffffffc0200f8c <best_fit_check+0x4f0>
    assert(alloc_page() == NULL);
ffffffffc0200b9c:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200b9e:	00093c03          	ld	s8,0(s2)
ffffffffc0200ba2:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc0200ba6:	01092b03          	lw	s6,16(s2)
    elm->prev = elm->next = elm;
ffffffffc0200baa:	00006797          	auipc	a5,0x6
ffffffffc0200bae:	8b27bb23          	sd	s2,-1866(a5) # ffffffffc0206460 <free_area+0x8>
ffffffffc0200bb2:	00006797          	auipc	a5,0x6
ffffffffc0200bb6:	8b27b323          	sd	s2,-1882(a5) # ffffffffc0206458 <free_area>
    nr_free = 0;
ffffffffc0200bba:	00006797          	auipc	a5,0x6
ffffffffc0200bbe:	8a07a723          	sw	zero,-1874(a5) # ffffffffc0206468 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200bc2:	c49ff0ef          	jal	ra,ffffffffc020080a <alloc_pages>
ffffffffc0200bc6:	3a051363          	bnez	a0,ffffffffc0200f6c <best_fit_check+0x4d0>
    free_page(p0);
ffffffffc0200bca:	4585                	li	a1,1
ffffffffc0200bcc:	8552                	mv	a0,s4
ffffffffc0200bce:	c81ff0ef          	jal	ra,ffffffffc020084e <free_pages>
    free_page(p1);
ffffffffc0200bd2:	4585                	li	a1,1
ffffffffc0200bd4:	854e                	mv	a0,s3
ffffffffc0200bd6:	c79ff0ef          	jal	ra,ffffffffc020084e <free_pages>
    free_page(p2);
ffffffffc0200bda:	4585                	li	a1,1
ffffffffc0200bdc:	8556                	mv	a0,s5
ffffffffc0200bde:	c71ff0ef          	jal	ra,ffffffffc020084e <free_pages>
    assert(nr_free == 3);
ffffffffc0200be2:	01092703          	lw	a4,16(s2)
ffffffffc0200be6:	478d                	li	a5,3
ffffffffc0200be8:	36f71263          	bne	a4,a5,ffffffffc0200f4c <best_fit_check+0x4b0>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200bec:	4505                	li	a0,1
ffffffffc0200bee:	c1dff0ef          	jal	ra,ffffffffc020080a <alloc_pages>
ffffffffc0200bf2:	89aa                	mv	s3,a0
ffffffffc0200bf4:	32050c63          	beqz	a0,ffffffffc0200f2c <best_fit_check+0x490>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200bf8:	4505                	li	a0,1
ffffffffc0200bfa:	c11ff0ef          	jal	ra,ffffffffc020080a <alloc_pages>
ffffffffc0200bfe:	8aaa                	mv	s5,a0
ffffffffc0200c00:	30050663          	beqz	a0,ffffffffc0200f0c <best_fit_check+0x470>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200c04:	4505                	li	a0,1
ffffffffc0200c06:	c05ff0ef          	jal	ra,ffffffffc020080a <alloc_pages>
ffffffffc0200c0a:	8a2a                	mv	s4,a0
ffffffffc0200c0c:	2e050063          	beqz	a0,ffffffffc0200eec <best_fit_check+0x450>
    assert(alloc_page() == NULL);
ffffffffc0200c10:	4505                	li	a0,1
ffffffffc0200c12:	bf9ff0ef          	jal	ra,ffffffffc020080a <alloc_pages>
ffffffffc0200c16:	2a051b63          	bnez	a0,ffffffffc0200ecc <best_fit_check+0x430>
    free_page(p0);
ffffffffc0200c1a:	4585                	li	a1,1
ffffffffc0200c1c:	854e                	mv	a0,s3
ffffffffc0200c1e:	c31ff0ef          	jal	ra,ffffffffc020084e <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200c22:	00893783          	ld	a5,8(s2)
ffffffffc0200c26:	1f278363          	beq	a5,s2,ffffffffc0200e0c <best_fit_check+0x370>
    assert((p = alloc_page()) == p0);
ffffffffc0200c2a:	4505                	li	a0,1
ffffffffc0200c2c:	bdfff0ef          	jal	ra,ffffffffc020080a <alloc_pages>
ffffffffc0200c30:	54a99e63          	bne	s3,a0,ffffffffc020118c <best_fit_check+0x6f0>
    assert(alloc_page() == NULL);
ffffffffc0200c34:	4505                	li	a0,1
ffffffffc0200c36:	bd5ff0ef          	jal	ra,ffffffffc020080a <alloc_pages>
ffffffffc0200c3a:	52051963          	bnez	a0,ffffffffc020116c <best_fit_check+0x6d0>
    assert(nr_free == 0);
ffffffffc0200c3e:	01092783          	lw	a5,16(s2)
ffffffffc0200c42:	50079563          	bnez	a5,ffffffffc020114c <best_fit_check+0x6b0>
    free_page(p);
ffffffffc0200c46:	854e                	mv	a0,s3
ffffffffc0200c48:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200c4a:	00006797          	auipc	a5,0x6
ffffffffc0200c4e:	8187b723          	sd	s8,-2034(a5) # ffffffffc0206458 <free_area>
ffffffffc0200c52:	00006797          	auipc	a5,0x6
ffffffffc0200c56:	8177b723          	sd	s7,-2034(a5) # ffffffffc0206460 <free_area+0x8>
    nr_free = nr_free_store;
ffffffffc0200c5a:	00006797          	auipc	a5,0x6
ffffffffc0200c5e:	8167a723          	sw	s6,-2034(a5) # ffffffffc0206468 <free_area+0x10>
    free_page(p);
ffffffffc0200c62:	bedff0ef          	jal	ra,ffffffffc020084e <free_pages>
    free_page(p1);
ffffffffc0200c66:	4585                	li	a1,1
ffffffffc0200c68:	8556                	mv	a0,s5
ffffffffc0200c6a:	be5ff0ef          	jal	ra,ffffffffc020084e <free_pages>
    free_page(p2);
ffffffffc0200c6e:	4585                	li	a1,1
ffffffffc0200c70:	8552                	mv	a0,s4
ffffffffc0200c72:	bddff0ef          	jal	ra,ffffffffc020084e <free_pages>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200c76:	4515                	li	a0,5
ffffffffc0200c78:	b93ff0ef          	jal	ra,ffffffffc020080a <alloc_pages>
ffffffffc0200c7c:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200c7e:	4a050763          	beqz	a0,ffffffffc020112c <best_fit_check+0x690>
ffffffffc0200c82:	651c                	ld	a5,8(a0)
ffffffffc0200c84:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0200c86:	8b85                	andi	a5,a5,1
ffffffffc0200c88:	48079263          	bnez	a5,ffffffffc020110c <best_fit_check+0x670>
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200c8c:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200c8e:	00093b03          	ld	s6,0(s2)
ffffffffc0200c92:	00893a83          	ld	s5,8(s2)
ffffffffc0200c96:	00005797          	auipc	a5,0x5
ffffffffc0200c9a:	7d27b123          	sd	s2,1986(a5) # ffffffffc0206458 <free_area>
ffffffffc0200c9e:	00005797          	auipc	a5,0x5
ffffffffc0200ca2:	7d27b123          	sd	s2,1986(a5) # ffffffffc0206460 <free_area+0x8>
    assert(alloc_page() == NULL);
ffffffffc0200ca6:	b65ff0ef          	jal	ra,ffffffffc020080a <alloc_pages>
ffffffffc0200caa:	44051163          	bnez	a0,ffffffffc02010ec <best_fit_check+0x650>
    #endif
    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    // * - - * -
    free_pages(p0 + 1, 2);
ffffffffc0200cae:	4589                	li	a1,2
ffffffffc0200cb0:	02898513          	addi	a0,s3,40
    unsigned int nr_free_store = nr_free;
ffffffffc0200cb4:	01092b83          	lw	s7,16(s2)
    free_pages(p0 + 4, 1);
ffffffffc0200cb8:	0a098c13          	addi	s8,s3,160
    nr_free = 0;
ffffffffc0200cbc:	00005797          	auipc	a5,0x5
ffffffffc0200cc0:	7a07a623          	sw	zero,1964(a5) # ffffffffc0206468 <free_area+0x10>
    free_pages(p0 + 1, 2);
ffffffffc0200cc4:	b8bff0ef          	jal	ra,ffffffffc020084e <free_pages>
    free_pages(p0 + 4, 1);
ffffffffc0200cc8:	8562                	mv	a0,s8
ffffffffc0200cca:	4585                	li	a1,1
ffffffffc0200ccc:	b83ff0ef          	jal	ra,ffffffffc020084e <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200cd0:	4511                	li	a0,4
ffffffffc0200cd2:	b39ff0ef          	jal	ra,ffffffffc020080a <alloc_pages>
ffffffffc0200cd6:	3e051b63          	bnez	a0,ffffffffc02010cc <best_fit_check+0x630>
ffffffffc0200cda:	0309b783          	ld	a5,48(s3)
ffffffffc0200cde:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc0200ce0:	8b85                	andi	a5,a5,1
ffffffffc0200ce2:	3c078563          	beqz	a5,ffffffffc02010ac <best_fit_check+0x610>
ffffffffc0200ce6:	0389a703          	lw	a4,56(s3)
ffffffffc0200cea:	4789                	li	a5,2
ffffffffc0200cec:	3cf71063          	bne	a4,a5,ffffffffc02010ac <best_fit_check+0x610>
    // * - - * *
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc0200cf0:	4505                	li	a0,1
ffffffffc0200cf2:	b19ff0ef          	jal	ra,ffffffffc020080a <alloc_pages>
ffffffffc0200cf6:	8a2a                	mv	s4,a0
ffffffffc0200cf8:	38050a63          	beqz	a0,ffffffffc020108c <best_fit_check+0x5f0>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc0200cfc:	4509                	li	a0,2
ffffffffc0200cfe:	b0dff0ef          	jal	ra,ffffffffc020080a <alloc_pages>
ffffffffc0200d02:	36050563          	beqz	a0,ffffffffc020106c <best_fit_check+0x5d0>
    assert(p0 + 4 == p1);
ffffffffc0200d06:	354c1363          	bne	s8,s4,ffffffffc020104c <best_fit_check+0x5b0>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    p2 = p0 + 1;
    free_pages(p0, 5);
ffffffffc0200d0a:	854e                	mv	a0,s3
ffffffffc0200d0c:	4595                	li	a1,5
ffffffffc0200d0e:	b41ff0ef          	jal	ra,ffffffffc020084e <free_pages>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200d12:	4515                	li	a0,5
ffffffffc0200d14:	af7ff0ef          	jal	ra,ffffffffc020080a <alloc_pages>
ffffffffc0200d18:	89aa                	mv	s3,a0
ffffffffc0200d1a:	30050963          	beqz	a0,ffffffffc020102c <best_fit_check+0x590>
    assert(alloc_page() == NULL);
ffffffffc0200d1e:	4505                	li	a0,1
ffffffffc0200d20:	aebff0ef          	jal	ra,ffffffffc020080a <alloc_pages>
ffffffffc0200d24:	2e051463          	bnez	a0,ffffffffc020100c <best_fit_check+0x570>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    assert(nr_free == 0);
ffffffffc0200d28:	01092783          	lw	a5,16(s2)
ffffffffc0200d2c:	2c079063          	bnez	a5,ffffffffc0200fec <best_fit_check+0x550>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0200d30:	4595                	li	a1,5
ffffffffc0200d32:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0200d34:	00005797          	auipc	a5,0x5
ffffffffc0200d38:	7377aa23          	sw	s7,1844(a5) # ffffffffc0206468 <free_area+0x10>
    free_list = free_list_store;
ffffffffc0200d3c:	00005797          	auipc	a5,0x5
ffffffffc0200d40:	7167be23          	sd	s6,1820(a5) # ffffffffc0206458 <free_area>
ffffffffc0200d44:	00005797          	auipc	a5,0x5
ffffffffc0200d48:	7157be23          	sd	s5,1820(a5) # ffffffffc0206460 <free_area+0x8>
    free_pages(p0, 5);
ffffffffc0200d4c:	b03ff0ef          	jal	ra,ffffffffc020084e <free_pages>
    return listelm->next;
ffffffffc0200d50:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200d54:	01278963          	beq	a5,s2,ffffffffc0200d66 <best_fit_check+0x2ca>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0200d58:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200d5c:	679c                	ld	a5,8(a5)
ffffffffc0200d5e:	34fd                	addiw	s1,s1,-1
ffffffffc0200d60:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200d62:	ff279be3          	bne	a5,s2,ffffffffc0200d58 <best_fit_check+0x2bc>
    }
    assert(count == 0);
ffffffffc0200d66:	26049363          	bnez	s1,ffffffffc0200fcc <best_fit_check+0x530>
    assert(total == 0);
ffffffffc0200d6a:	e06d                	bnez	s0,ffffffffc0200e4c <best_fit_check+0x3b0>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
}
ffffffffc0200d6c:	60a6                	ld	ra,72(sp)
ffffffffc0200d6e:	6406                	ld	s0,64(sp)
ffffffffc0200d70:	74e2                	ld	s1,56(sp)
ffffffffc0200d72:	7942                	ld	s2,48(sp)
ffffffffc0200d74:	79a2                	ld	s3,40(sp)
ffffffffc0200d76:	7a02                	ld	s4,32(sp)
ffffffffc0200d78:	6ae2                	ld	s5,24(sp)
ffffffffc0200d7a:	6b42                	ld	s6,16(sp)
ffffffffc0200d7c:	6ba2                	ld	s7,8(sp)
ffffffffc0200d7e:	6c02                	ld	s8,0(sp)
ffffffffc0200d80:	6161                	addi	sp,sp,80
ffffffffc0200d82:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200d84:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200d86:	4401                	li	s0,0
ffffffffc0200d88:	4481                	li	s1,0
ffffffffc0200d8a:	b395                	j	ffffffffc0200aee <best_fit_check+0x52>
        assert(PageProperty(p));
ffffffffc0200d8c:	00001697          	auipc	a3,0x1
ffffffffc0200d90:	5a468693          	addi	a3,a3,1444 # ffffffffc0202330 <commands+0x740>
ffffffffc0200d94:	00001617          	auipc	a2,0x1
ffffffffc0200d98:	5ac60613          	addi	a2,a2,1452 # ffffffffc0202340 <commands+0x750>
ffffffffc0200d9c:	10c00593          	li	a1,268
ffffffffc0200da0:	00001517          	auipc	a0,0x1
ffffffffc0200da4:	5b850513          	addi	a0,a0,1464 # ffffffffc0202358 <commands+0x768>
ffffffffc0200da8:	b94ff0ef          	jal	ra,ffffffffc020013c <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200dac:	00001697          	auipc	a3,0x1
ffffffffc0200db0:	64468693          	addi	a3,a3,1604 # ffffffffc02023f0 <commands+0x800>
ffffffffc0200db4:	00001617          	auipc	a2,0x1
ffffffffc0200db8:	58c60613          	addi	a2,a2,1420 # ffffffffc0202340 <commands+0x750>
ffffffffc0200dbc:	0d800593          	li	a1,216
ffffffffc0200dc0:	00001517          	auipc	a0,0x1
ffffffffc0200dc4:	59850513          	addi	a0,a0,1432 # ffffffffc0202358 <commands+0x768>
ffffffffc0200dc8:	b74ff0ef          	jal	ra,ffffffffc020013c <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200dcc:	00001697          	auipc	a3,0x1
ffffffffc0200dd0:	64c68693          	addi	a3,a3,1612 # ffffffffc0202418 <commands+0x828>
ffffffffc0200dd4:	00001617          	auipc	a2,0x1
ffffffffc0200dd8:	56c60613          	addi	a2,a2,1388 # ffffffffc0202340 <commands+0x750>
ffffffffc0200ddc:	0d900593          	li	a1,217
ffffffffc0200de0:	00001517          	auipc	a0,0x1
ffffffffc0200de4:	57850513          	addi	a0,a0,1400 # ffffffffc0202358 <commands+0x768>
ffffffffc0200de8:	b54ff0ef          	jal	ra,ffffffffc020013c <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200dec:	00001697          	auipc	a3,0x1
ffffffffc0200df0:	66c68693          	addi	a3,a3,1644 # ffffffffc0202458 <commands+0x868>
ffffffffc0200df4:	00001617          	auipc	a2,0x1
ffffffffc0200df8:	54c60613          	addi	a2,a2,1356 # ffffffffc0202340 <commands+0x750>
ffffffffc0200dfc:	0db00593          	li	a1,219
ffffffffc0200e00:	00001517          	auipc	a0,0x1
ffffffffc0200e04:	55850513          	addi	a0,a0,1368 # ffffffffc0202358 <commands+0x768>
ffffffffc0200e08:	b34ff0ef          	jal	ra,ffffffffc020013c <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200e0c:	00001697          	auipc	a3,0x1
ffffffffc0200e10:	6d468693          	addi	a3,a3,1748 # ffffffffc02024e0 <commands+0x8f0>
ffffffffc0200e14:	00001617          	auipc	a2,0x1
ffffffffc0200e18:	52c60613          	addi	a2,a2,1324 # ffffffffc0202340 <commands+0x750>
ffffffffc0200e1c:	0f400593          	li	a1,244
ffffffffc0200e20:	00001517          	auipc	a0,0x1
ffffffffc0200e24:	53850513          	addi	a0,a0,1336 # ffffffffc0202358 <commands+0x768>
ffffffffc0200e28:	b14ff0ef          	jal	ra,ffffffffc020013c <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200e2c:	00001697          	auipc	a3,0x1
ffffffffc0200e30:	5a468693          	addi	a3,a3,1444 # ffffffffc02023d0 <commands+0x7e0>
ffffffffc0200e34:	00001617          	auipc	a2,0x1
ffffffffc0200e38:	50c60613          	addi	a2,a2,1292 # ffffffffc0202340 <commands+0x750>
ffffffffc0200e3c:	0d600593          	li	a1,214
ffffffffc0200e40:	00001517          	auipc	a0,0x1
ffffffffc0200e44:	51850513          	addi	a0,a0,1304 # ffffffffc0202358 <commands+0x768>
ffffffffc0200e48:	af4ff0ef          	jal	ra,ffffffffc020013c <__panic>
    assert(total == 0);
ffffffffc0200e4c:	00001697          	auipc	a3,0x1
ffffffffc0200e50:	7c468693          	addi	a3,a3,1988 # ffffffffc0202610 <commands+0xa20>
ffffffffc0200e54:	00001617          	auipc	a2,0x1
ffffffffc0200e58:	4ec60613          	addi	a2,a2,1260 # ffffffffc0202340 <commands+0x750>
ffffffffc0200e5c:	14e00593          	li	a1,334
ffffffffc0200e60:	00001517          	auipc	a0,0x1
ffffffffc0200e64:	4f850513          	addi	a0,a0,1272 # ffffffffc0202358 <commands+0x768>
ffffffffc0200e68:	ad4ff0ef          	jal	ra,ffffffffc020013c <__panic>
    assert(total == nr_free_pages());
ffffffffc0200e6c:	00001697          	auipc	a3,0x1
ffffffffc0200e70:	50468693          	addi	a3,a3,1284 # ffffffffc0202370 <commands+0x780>
ffffffffc0200e74:	00001617          	auipc	a2,0x1
ffffffffc0200e78:	4cc60613          	addi	a2,a2,1228 # ffffffffc0202340 <commands+0x750>
ffffffffc0200e7c:	10f00593          	li	a1,271
ffffffffc0200e80:	00001517          	auipc	a0,0x1
ffffffffc0200e84:	4d850513          	addi	a0,a0,1240 # ffffffffc0202358 <commands+0x768>
ffffffffc0200e88:	ab4ff0ef          	jal	ra,ffffffffc020013c <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200e8c:	00001697          	auipc	a3,0x1
ffffffffc0200e90:	52468693          	addi	a3,a3,1316 # ffffffffc02023b0 <commands+0x7c0>
ffffffffc0200e94:	00001617          	auipc	a2,0x1
ffffffffc0200e98:	4ac60613          	addi	a2,a2,1196 # ffffffffc0202340 <commands+0x750>
ffffffffc0200e9c:	0d500593          	li	a1,213
ffffffffc0200ea0:	00001517          	auipc	a0,0x1
ffffffffc0200ea4:	4b850513          	addi	a0,a0,1208 # ffffffffc0202358 <commands+0x768>
ffffffffc0200ea8:	a94ff0ef          	jal	ra,ffffffffc020013c <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200eac:	00001697          	auipc	a3,0x1
ffffffffc0200eb0:	4e468693          	addi	a3,a3,1252 # ffffffffc0202390 <commands+0x7a0>
ffffffffc0200eb4:	00001617          	auipc	a2,0x1
ffffffffc0200eb8:	48c60613          	addi	a2,a2,1164 # ffffffffc0202340 <commands+0x750>
ffffffffc0200ebc:	0d400593          	li	a1,212
ffffffffc0200ec0:	00001517          	auipc	a0,0x1
ffffffffc0200ec4:	49850513          	addi	a0,a0,1176 # ffffffffc0202358 <commands+0x768>
ffffffffc0200ec8:	a74ff0ef          	jal	ra,ffffffffc020013c <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200ecc:	00001697          	auipc	a3,0x1
ffffffffc0200ed0:	5ec68693          	addi	a3,a3,1516 # ffffffffc02024b8 <commands+0x8c8>
ffffffffc0200ed4:	00001617          	auipc	a2,0x1
ffffffffc0200ed8:	46c60613          	addi	a2,a2,1132 # ffffffffc0202340 <commands+0x750>
ffffffffc0200edc:	0f100593          	li	a1,241
ffffffffc0200ee0:	00001517          	auipc	a0,0x1
ffffffffc0200ee4:	47850513          	addi	a0,a0,1144 # ffffffffc0202358 <commands+0x768>
ffffffffc0200ee8:	a54ff0ef          	jal	ra,ffffffffc020013c <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200eec:	00001697          	auipc	a3,0x1
ffffffffc0200ef0:	4e468693          	addi	a3,a3,1252 # ffffffffc02023d0 <commands+0x7e0>
ffffffffc0200ef4:	00001617          	auipc	a2,0x1
ffffffffc0200ef8:	44c60613          	addi	a2,a2,1100 # ffffffffc0202340 <commands+0x750>
ffffffffc0200efc:	0ef00593          	li	a1,239
ffffffffc0200f00:	00001517          	auipc	a0,0x1
ffffffffc0200f04:	45850513          	addi	a0,a0,1112 # ffffffffc0202358 <commands+0x768>
ffffffffc0200f08:	a34ff0ef          	jal	ra,ffffffffc020013c <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200f0c:	00001697          	auipc	a3,0x1
ffffffffc0200f10:	4a468693          	addi	a3,a3,1188 # ffffffffc02023b0 <commands+0x7c0>
ffffffffc0200f14:	00001617          	auipc	a2,0x1
ffffffffc0200f18:	42c60613          	addi	a2,a2,1068 # ffffffffc0202340 <commands+0x750>
ffffffffc0200f1c:	0ee00593          	li	a1,238
ffffffffc0200f20:	00001517          	auipc	a0,0x1
ffffffffc0200f24:	43850513          	addi	a0,a0,1080 # ffffffffc0202358 <commands+0x768>
ffffffffc0200f28:	a14ff0ef          	jal	ra,ffffffffc020013c <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200f2c:	00001697          	auipc	a3,0x1
ffffffffc0200f30:	46468693          	addi	a3,a3,1124 # ffffffffc0202390 <commands+0x7a0>
ffffffffc0200f34:	00001617          	auipc	a2,0x1
ffffffffc0200f38:	40c60613          	addi	a2,a2,1036 # ffffffffc0202340 <commands+0x750>
ffffffffc0200f3c:	0ed00593          	li	a1,237
ffffffffc0200f40:	00001517          	auipc	a0,0x1
ffffffffc0200f44:	41850513          	addi	a0,a0,1048 # ffffffffc0202358 <commands+0x768>
ffffffffc0200f48:	9f4ff0ef          	jal	ra,ffffffffc020013c <__panic>
    assert(nr_free == 3);
ffffffffc0200f4c:	00001697          	auipc	a3,0x1
ffffffffc0200f50:	58468693          	addi	a3,a3,1412 # ffffffffc02024d0 <commands+0x8e0>
ffffffffc0200f54:	00001617          	auipc	a2,0x1
ffffffffc0200f58:	3ec60613          	addi	a2,a2,1004 # ffffffffc0202340 <commands+0x750>
ffffffffc0200f5c:	0eb00593          	li	a1,235
ffffffffc0200f60:	00001517          	auipc	a0,0x1
ffffffffc0200f64:	3f850513          	addi	a0,a0,1016 # ffffffffc0202358 <commands+0x768>
ffffffffc0200f68:	9d4ff0ef          	jal	ra,ffffffffc020013c <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200f6c:	00001697          	auipc	a3,0x1
ffffffffc0200f70:	54c68693          	addi	a3,a3,1356 # ffffffffc02024b8 <commands+0x8c8>
ffffffffc0200f74:	00001617          	auipc	a2,0x1
ffffffffc0200f78:	3cc60613          	addi	a2,a2,972 # ffffffffc0202340 <commands+0x750>
ffffffffc0200f7c:	0e600593          	li	a1,230
ffffffffc0200f80:	00001517          	auipc	a0,0x1
ffffffffc0200f84:	3d850513          	addi	a0,a0,984 # ffffffffc0202358 <commands+0x768>
ffffffffc0200f88:	9b4ff0ef          	jal	ra,ffffffffc020013c <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200f8c:	00001697          	auipc	a3,0x1
ffffffffc0200f90:	50c68693          	addi	a3,a3,1292 # ffffffffc0202498 <commands+0x8a8>
ffffffffc0200f94:	00001617          	auipc	a2,0x1
ffffffffc0200f98:	3ac60613          	addi	a2,a2,940 # ffffffffc0202340 <commands+0x750>
ffffffffc0200f9c:	0dd00593          	li	a1,221
ffffffffc0200fa0:	00001517          	auipc	a0,0x1
ffffffffc0200fa4:	3b850513          	addi	a0,a0,952 # ffffffffc0202358 <commands+0x768>
ffffffffc0200fa8:	994ff0ef          	jal	ra,ffffffffc020013c <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200fac:	00001697          	auipc	a3,0x1
ffffffffc0200fb0:	4cc68693          	addi	a3,a3,1228 # ffffffffc0202478 <commands+0x888>
ffffffffc0200fb4:	00001617          	auipc	a2,0x1
ffffffffc0200fb8:	38c60613          	addi	a2,a2,908 # ffffffffc0202340 <commands+0x750>
ffffffffc0200fbc:	0dc00593          	li	a1,220
ffffffffc0200fc0:	00001517          	auipc	a0,0x1
ffffffffc0200fc4:	39850513          	addi	a0,a0,920 # ffffffffc0202358 <commands+0x768>
ffffffffc0200fc8:	974ff0ef          	jal	ra,ffffffffc020013c <__panic>
    assert(count == 0);
ffffffffc0200fcc:	00001697          	auipc	a3,0x1
ffffffffc0200fd0:	63468693          	addi	a3,a3,1588 # ffffffffc0202600 <commands+0xa10>
ffffffffc0200fd4:	00001617          	auipc	a2,0x1
ffffffffc0200fd8:	36c60613          	addi	a2,a2,876 # ffffffffc0202340 <commands+0x750>
ffffffffc0200fdc:	14d00593          	li	a1,333
ffffffffc0200fe0:	00001517          	auipc	a0,0x1
ffffffffc0200fe4:	37850513          	addi	a0,a0,888 # ffffffffc0202358 <commands+0x768>
ffffffffc0200fe8:	954ff0ef          	jal	ra,ffffffffc020013c <__panic>
    assert(nr_free == 0);
ffffffffc0200fec:	00001697          	auipc	a3,0x1
ffffffffc0200ff0:	52c68693          	addi	a3,a3,1324 # ffffffffc0202518 <commands+0x928>
ffffffffc0200ff4:	00001617          	auipc	a2,0x1
ffffffffc0200ff8:	34c60613          	addi	a2,a2,844 # ffffffffc0202340 <commands+0x750>
ffffffffc0200ffc:	14200593          	li	a1,322
ffffffffc0201000:	00001517          	auipc	a0,0x1
ffffffffc0201004:	35850513          	addi	a0,a0,856 # ffffffffc0202358 <commands+0x768>
ffffffffc0201008:	934ff0ef          	jal	ra,ffffffffc020013c <__panic>
    assert(alloc_page() == NULL);
ffffffffc020100c:	00001697          	auipc	a3,0x1
ffffffffc0201010:	4ac68693          	addi	a3,a3,1196 # ffffffffc02024b8 <commands+0x8c8>
ffffffffc0201014:	00001617          	auipc	a2,0x1
ffffffffc0201018:	32c60613          	addi	a2,a2,812 # ffffffffc0202340 <commands+0x750>
ffffffffc020101c:	13c00593          	li	a1,316
ffffffffc0201020:	00001517          	auipc	a0,0x1
ffffffffc0201024:	33850513          	addi	a0,a0,824 # ffffffffc0202358 <commands+0x768>
ffffffffc0201028:	914ff0ef          	jal	ra,ffffffffc020013c <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc020102c:	00001697          	auipc	a3,0x1
ffffffffc0201030:	5b468693          	addi	a3,a3,1460 # ffffffffc02025e0 <commands+0x9f0>
ffffffffc0201034:	00001617          	auipc	a2,0x1
ffffffffc0201038:	30c60613          	addi	a2,a2,780 # ffffffffc0202340 <commands+0x750>
ffffffffc020103c:	13b00593          	li	a1,315
ffffffffc0201040:	00001517          	auipc	a0,0x1
ffffffffc0201044:	31850513          	addi	a0,a0,792 # ffffffffc0202358 <commands+0x768>
ffffffffc0201048:	8f4ff0ef          	jal	ra,ffffffffc020013c <__panic>
    assert(p0 + 4 == p1);
ffffffffc020104c:	00001697          	auipc	a3,0x1
ffffffffc0201050:	58468693          	addi	a3,a3,1412 # ffffffffc02025d0 <commands+0x9e0>
ffffffffc0201054:	00001617          	auipc	a2,0x1
ffffffffc0201058:	2ec60613          	addi	a2,a2,748 # ffffffffc0202340 <commands+0x750>
ffffffffc020105c:	13300593          	li	a1,307
ffffffffc0201060:	00001517          	auipc	a0,0x1
ffffffffc0201064:	2f850513          	addi	a0,a0,760 # ffffffffc0202358 <commands+0x768>
ffffffffc0201068:	8d4ff0ef          	jal	ra,ffffffffc020013c <__panic>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc020106c:	00001697          	auipc	a3,0x1
ffffffffc0201070:	54c68693          	addi	a3,a3,1356 # ffffffffc02025b8 <commands+0x9c8>
ffffffffc0201074:	00001617          	auipc	a2,0x1
ffffffffc0201078:	2cc60613          	addi	a2,a2,716 # ffffffffc0202340 <commands+0x750>
ffffffffc020107c:	13200593          	li	a1,306
ffffffffc0201080:	00001517          	auipc	a0,0x1
ffffffffc0201084:	2d850513          	addi	a0,a0,728 # ffffffffc0202358 <commands+0x768>
ffffffffc0201088:	8b4ff0ef          	jal	ra,ffffffffc020013c <__panic>
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc020108c:	00001697          	auipc	a3,0x1
ffffffffc0201090:	50c68693          	addi	a3,a3,1292 # ffffffffc0202598 <commands+0x9a8>
ffffffffc0201094:	00001617          	auipc	a2,0x1
ffffffffc0201098:	2ac60613          	addi	a2,a2,684 # ffffffffc0202340 <commands+0x750>
ffffffffc020109c:	13100593          	li	a1,305
ffffffffc02010a0:	00001517          	auipc	a0,0x1
ffffffffc02010a4:	2b850513          	addi	a0,a0,696 # ffffffffc0202358 <commands+0x768>
ffffffffc02010a8:	894ff0ef          	jal	ra,ffffffffc020013c <__panic>
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc02010ac:	00001697          	auipc	a3,0x1
ffffffffc02010b0:	4bc68693          	addi	a3,a3,1212 # ffffffffc0202568 <commands+0x978>
ffffffffc02010b4:	00001617          	auipc	a2,0x1
ffffffffc02010b8:	28c60613          	addi	a2,a2,652 # ffffffffc0202340 <commands+0x750>
ffffffffc02010bc:	12f00593          	li	a1,303
ffffffffc02010c0:	00001517          	auipc	a0,0x1
ffffffffc02010c4:	29850513          	addi	a0,a0,664 # ffffffffc0202358 <commands+0x768>
ffffffffc02010c8:	874ff0ef          	jal	ra,ffffffffc020013c <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc02010cc:	00001697          	auipc	a3,0x1
ffffffffc02010d0:	48468693          	addi	a3,a3,1156 # ffffffffc0202550 <commands+0x960>
ffffffffc02010d4:	00001617          	auipc	a2,0x1
ffffffffc02010d8:	26c60613          	addi	a2,a2,620 # ffffffffc0202340 <commands+0x750>
ffffffffc02010dc:	12e00593          	li	a1,302
ffffffffc02010e0:	00001517          	auipc	a0,0x1
ffffffffc02010e4:	27850513          	addi	a0,a0,632 # ffffffffc0202358 <commands+0x768>
ffffffffc02010e8:	854ff0ef          	jal	ra,ffffffffc020013c <__panic>
    assert(alloc_page() == NULL);
ffffffffc02010ec:	00001697          	auipc	a3,0x1
ffffffffc02010f0:	3cc68693          	addi	a3,a3,972 # ffffffffc02024b8 <commands+0x8c8>
ffffffffc02010f4:	00001617          	auipc	a2,0x1
ffffffffc02010f8:	24c60613          	addi	a2,a2,588 # ffffffffc0202340 <commands+0x750>
ffffffffc02010fc:	12200593          	li	a1,290
ffffffffc0201100:	00001517          	auipc	a0,0x1
ffffffffc0201104:	25850513          	addi	a0,a0,600 # ffffffffc0202358 <commands+0x768>
ffffffffc0201108:	834ff0ef          	jal	ra,ffffffffc020013c <__panic>
    assert(!PageProperty(p0));
ffffffffc020110c:	00001697          	auipc	a3,0x1
ffffffffc0201110:	42c68693          	addi	a3,a3,1068 # ffffffffc0202538 <commands+0x948>
ffffffffc0201114:	00001617          	auipc	a2,0x1
ffffffffc0201118:	22c60613          	addi	a2,a2,556 # ffffffffc0202340 <commands+0x750>
ffffffffc020111c:	11900593          	li	a1,281
ffffffffc0201120:	00001517          	auipc	a0,0x1
ffffffffc0201124:	23850513          	addi	a0,a0,568 # ffffffffc0202358 <commands+0x768>
ffffffffc0201128:	814ff0ef          	jal	ra,ffffffffc020013c <__panic>
    assert(p0 != NULL);
ffffffffc020112c:	00001697          	auipc	a3,0x1
ffffffffc0201130:	3fc68693          	addi	a3,a3,1020 # ffffffffc0202528 <commands+0x938>
ffffffffc0201134:	00001617          	auipc	a2,0x1
ffffffffc0201138:	20c60613          	addi	a2,a2,524 # ffffffffc0202340 <commands+0x750>
ffffffffc020113c:	11800593          	li	a1,280
ffffffffc0201140:	00001517          	auipc	a0,0x1
ffffffffc0201144:	21850513          	addi	a0,a0,536 # ffffffffc0202358 <commands+0x768>
ffffffffc0201148:	ff5fe0ef          	jal	ra,ffffffffc020013c <__panic>
    assert(nr_free == 0);
ffffffffc020114c:	00001697          	auipc	a3,0x1
ffffffffc0201150:	3cc68693          	addi	a3,a3,972 # ffffffffc0202518 <commands+0x928>
ffffffffc0201154:	00001617          	auipc	a2,0x1
ffffffffc0201158:	1ec60613          	addi	a2,a2,492 # ffffffffc0202340 <commands+0x750>
ffffffffc020115c:	0fa00593          	li	a1,250
ffffffffc0201160:	00001517          	auipc	a0,0x1
ffffffffc0201164:	1f850513          	addi	a0,a0,504 # ffffffffc0202358 <commands+0x768>
ffffffffc0201168:	fd5fe0ef          	jal	ra,ffffffffc020013c <__panic>
    assert(alloc_page() == NULL);
ffffffffc020116c:	00001697          	auipc	a3,0x1
ffffffffc0201170:	34c68693          	addi	a3,a3,844 # ffffffffc02024b8 <commands+0x8c8>
ffffffffc0201174:	00001617          	auipc	a2,0x1
ffffffffc0201178:	1cc60613          	addi	a2,a2,460 # ffffffffc0202340 <commands+0x750>
ffffffffc020117c:	0f800593          	li	a1,248
ffffffffc0201180:	00001517          	auipc	a0,0x1
ffffffffc0201184:	1d850513          	addi	a0,a0,472 # ffffffffc0202358 <commands+0x768>
ffffffffc0201188:	fb5fe0ef          	jal	ra,ffffffffc020013c <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc020118c:	00001697          	auipc	a3,0x1
ffffffffc0201190:	36c68693          	addi	a3,a3,876 # ffffffffc02024f8 <commands+0x908>
ffffffffc0201194:	00001617          	auipc	a2,0x1
ffffffffc0201198:	1ac60613          	addi	a2,a2,428 # ffffffffc0202340 <commands+0x750>
ffffffffc020119c:	0f700593          	li	a1,247
ffffffffc02011a0:	00001517          	auipc	a0,0x1
ffffffffc02011a4:	1b850513          	addi	a0,a0,440 # ffffffffc0202358 <commands+0x768>
ffffffffc02011a8:	f95fe0ef          	jal	ra,ffffffffc020013c <__panic>

ffffffffc02011ac <best_fit_free_pages>:
best_fit_free_pages(struct Page *base, size_t n) {
ffffffffc02011ac:	1141                	addi	sp,sp,-16
ffffffffc02011ae:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02011b0:	18058063          	beqz	a1,ffffffffc0201330 <best_fit_free_pages+0x184>
    for (; p != base + n; p ++) {
ffffffffc02011b4:	00259693          	slli	a3,a1,0x2
ffffffffc02011b8:	96ae                	add	a3,a3,a1
ffffffffc02011ba:	068e                	slli	a3,a3,0x3
ffffffffc02011bc:	96aa                	add	a3,a3,a0
ffffffffc02011be:	02d50d63          	beq	a0,a3,ffffffffc02011f8 <best_fit_free_pages+0x4c>
ffffffffc02011c2:	651c                	ld	a5,8(a0)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02011c4:	8b85                	andi	a5,a5,1
ffffffffc02011c6:	14079563          	bnez	a5,ffffffffc0201310 <best_fit_free_pages+0x164>
ffffffffc02011ca:	651c                	ld	a5,8(a0)
ffffffffc02011cc:	8385                	srli	a5,a5,0x1
ffffffffc02011ce:	8b85                	andi	a5,a5,1
ffffffffc02011d0:	14079063          	bnez	a5,ffffffffc0201310 <best_fit_free_pages+0x164>
ffffffffc02011d4:	87aa                	mv	a5,a0
ffffffffc02011d6:	a809                	j	ffffffffc02011e8 <best_fit_free_pages+0x3c>
ffffffffc02011d8:	6798                	ld	a4,8(a5)
ffffffffc02011da:	8b05                	andi	a4,a4,1
ffffffffc02011dc:	12071a63          	bnez	a4,ffffffffc0201310 <best_fit_free_pages+0x164>
ffffffffc02011e0:	6798                	ld	a4,8(a5)
ffffffffc02011e2:	8b09                	andi	a4,a4,2
ffffffffc02011e4:	12071663          	bnez	a4,ffffffffc0201310 <best_fit_free_pages+0x164>
        p->flags = 0;
ffffffffc02011e8:	0007b423          	sd	zero,8(a5)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc02011ec:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02011f0:	02878793          	addi	a5,a5,40
ffffffffc02011f4:	fed792e3          	bne	a5,a3,ffffffffc02011d8 <best_fit_free_pages+0x2c>
    base->property = n;
ffffffffc02011f8:	2581                	sext.w	a1,a1
ffffffffc02011fa:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc02011fc:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201200:	4789                	li	a5,2
ffffffffc0201202:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc0201206:	00005697          	auipc	a3,0x5
ffffffffc020120a:	25268693          	addi	a3,a3,594 # ffffffffc0206458 <free_area>
ffffffffc020120e:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201210:	669c                	ld	a5,8(a3)
ffffffffc0201212:	9db9                	addw	a1,a1,a4
ffffffffc0201214:	00005717          	auipc	a4,0x5
ffffffffc0201218:	24b72a23          	sw	a1,596(a4) # ffffffffc0206468 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc020121c:	08d78f63          	beq	a5,a3,ffffffffc02012ba <best_fit_free_pages+0x10e>
            struct Page* page = le2page(le, page_link);
ffffffffc0201220:	fe878713          	addi	a4,a5,-24
ffffffffc0201224:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0201226:	4801                	li	a6,0
ffffffffc0201228:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc020122c:	00e56a63          	bltu	a0,a4,ffffffffc0201240 <best_fit_free_pages+0x94>
    return listelm->next;
ffffffffc0201230:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0201232:	02d70563          	beq	a4,a3,ffffffffc020125c <best_fit_free_pages+0xb0>
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201236:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201238:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc020123c:	fee57ae3          	bgeu	a0,a4,ffffffffc0201230 <best_fit_free_pages+0x84>
ffffffffc0201240:	00080663          	beqz	a6,ffffffffc020124c <best_fit_free_pages+0xa0>
ffffffffc0201244:	00005817          	auipc	a6,0x5
ffffffffc0201248:	20b83a23          	sd	a1,532(a6) # ffffffffc0206458 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc020124c:	638c                	ld	a1,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc020124e:	e390                	sd	a2,0(a5)
ffffffffc0201250:	e590                	sd	a2,8(a1)
    elm->next = next;
ffffffffc0201252:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201254:	ed0c                	sd	a1,24(a0)
    if (le != &free_list) {
ffffffffc0201256:	02d59163          	bne	a1,a3,ffffffffc0201278 <best_fit_free_pages+0xcc>
ffffffffc020125a:	a091                	j	ffffffffc020129e <best_fit_free_pages+0xf2>
    prev->next = next->prev = elm;
ffffffffc020125c:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020125e:	f114                	sd	a3,32(a0)
ffffffffc0201260:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201262:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc0201264:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201266:	00d70563          	beq	a4,a3,ffffffffc0201270 <best_fit_free_pages+0xc4>
ffffffffc020126a:	4805                	li	a6,1
ffffffffc020126c:	87ba                	mv	a5,a4
ffffffffc020126e:	b7e9                	j	ffffffffc0201238 <best_fit_free_pages+0x8c>
ffffffffc0201270:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc0201272:	85be                	mv	a1,a5
    if (le != &free_list) {
ffffffffc0201274:	02d78163          	beq	a5,a3,ffffffffc0201296 <best_fit_free_pages+0xea>
        if (p + p->property == base) {
ffffffffc0201278:	ff85a803          	lw	a6,-8(a1)
        p = le2page(le, page_link);
ffffffffc020127c:	fe858613          	addi	a2,a1,-24
        if (p + p->property == base) {
ffffffffc0201280:	02081713          	slli	a4,a6,0x20
ffffffffc0201284:	9301                	srli	a4,a4,0x20
ffffffffc0201286:	00271793          	slli	a5,a4,0x2
ffffffffc020128a:	97ba                	add	a5,a5,a4
ffffffffc020128c:	078e                	slli	a5,a5,0x3
ffffffffc020128e:	97b2                	add	a5,a5,a2
ffffffffc0201290:	02f50e63          	beq	a0,a5,ffffffffc02012cc <best_fit_free_pages+0x120>
ffffffffc0201294:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc0201296:	fe878713          	addi	a4,a5,-24
ffffffffc020129a:	00d78d63          	beq	a5,a3,ffffffffc02012b4 <best_fit_free_pages+0x108>
        if (base + base->property == p) {
ffffffffc020129e:	490c                	lw	a1,16(a0)
ffffffffc02012a0:	02059613          	slli	a2,a1,0x20
ffffffffc02012a4:	9201                	srli	a2,a2,0x20
ffffffffc02012a6:	00261693          	slli	a3,a2,0x2
ffffffffc02012aa:	96b2                	add	a3,a3,a2
ffffffffc02012ac:	068e                	slli	a3,a3,0x3
ffffffffc02012ae:	96aa                	add	a3,a3,a0
ffffffffc02012b0:	04d70063          	beq	a4,a3,ffffffffc02012f0 <best_fit_free_pages+0x144>
}
ffffffffc02012b4:	60a2                	ld	ra,8(sp)
ffffffffc02012b6:	0141                	addi	sp,sp,16
ffffffffc02012b8:	8082                	ret
ffffffffc02012ba:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc02012bc:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc02012c0:	e398                	sd	a4,0(a5)
ffffffffc02012c2:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc02012c4:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02012c6:	ed1c                	sd	a5,24(a0)
}
ffffffffc02012c8:	0141                	addi	sp,sp,16
ffffffffc02012ca:	8082                	ret
            p->property += base->property;
ffffffffc02012cc:	491c                	lw	a5,16(a0)
ffffffffc02012ce:	0107883b          	addw	a6,a5,a6
ffffffffc02012d2:	ff05ac23          	sw	a6,-8(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02012d6:	57f5                	li	a5,-3
ffffffffc02012d8:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc02012dc:	01853803          	ld	a6,24(a0)
ffffffffc02012e0:	7118                	ld	a4,32(a0)
            base = p;
ffffffffc02012e2:	8532                	mv	a0,a2
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc02012e4:	00e83423          	sd	a4,8(a6)
    next->prev = prev;
ffffffffc02012e8:	659c                	ld	a5,8(a1)
ffffffffc02012ea:	01073023          	sd	a6,0(a4)
ffffffffc02012ee:	b765                	j	ffffffffc0201296 <best_fit_free_pages+0xea>
            base->property += p->property;
ffffffffc02012f0:	ff87a703          	lw	a4,-8(a5)
ffffffffc02012f4:	ff078693          	addi	a3,a5,-16
ffffffffc02012f8:	9db9                	addw	a1,a1,a4
ffffffffc02012fa:	c90c                	sw	a1,16(a0)
ffffffffc02012fc:	5775                	li	a4,-3
ffffffffc02012fe:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201302:	6398                	ld	a4,0(a5)
ffffffffc0201304:	679c                	ld	a5,8(a5)
}
ffffffffc0201306:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0201308:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc020130a:	e398                	sd	a4,0(a5)
ffffffffc020130c:	0141                	addi	sp,sp,16
ffffffffc020130e:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201310:	00001697          	auipc	a3,0x1
ffffffffc0201314:	31068693          	addi	a3,a3,784 # ffffffffc0202620 <commands+0xa30>
ffffffffc0201318:	00001617          	auipc	a2,0x1
ffffffffc020131c:	02860613          	addi	a2,a2,40 # ffffffffc0202340 <commands+0x750>
ffffffffc0201320:	09400593          	li	a1,148
ffffffffc0201324:	00001517          	auipc	a0,0x1
ffffffffc0201328:	03450513          	addi	a0,a0,52 # ffffffffc0202358 <commands+0x768>
ffffffffc020132c:	e11fe0ef          	jal	ra,ffffffffc020013c <__panic>
    assert(n > 0);
ffffffffc0201330:	00001697          	auipc	a3,0x1
ffffffffc0201334:	31868693          	addi	a3,a3,792 # ffffffffc0202648 <commands+0xa58>
ffffffffc0201338:	00001617          	auipc	a2,0x1
ffffffffc020133c:	00860613          	addi	a2,a2,8 # ffffffffc0202340 <commands+0x750>
ffffffffc0201340:	09100593          	li	a1,145
ffffffffc0201344:	00001517          	auipc	a0,0x1
ffffffffc0201348:	01450513          	addi	a0,a0,20 # ffffffffc0202358 <commands+0x768>
ffffffffc020134c:	df1fe0ef          	jal	ra,ffffffffc020013c <__panic>

ffffffffc0201350 <best_fit_alloc_pages>:
    assert(n > 0);
ffffffffc0201350:	c55d                	beqz	a0,ffffffffc02013fe <best_fit_alloc_pages+0xae>
    if (n > nr_free) {
ffffffffc0201352:	00005597          	auipc	a1,0x5
ffffffffc0201356:	10658593          	addi	a1,a1,262 # ffffffffc0206458 <free_area>
ffffffffc020135a:	0105a883          	lw	a7,16(a1)
ffffffffc020135e:	862a                	mv	a2,a0
ffffffffc0201360:	02089793          	slli	a5,a7,0x20
ffffffffc0201364:	9381                	srli	a5,a5,0x20
ffffffffc0201366:	08a7ea63          	bltu	a5,a0,ffffffffc02013fa <best_fit_alloc_pages+0xaa>
    int min=2147483647;
ffffffffc020136a:	80000837          	lui	a6,0x80000
ffffffffc020136e:	fff84813          	not	a6,a6
    list_entry_t *le = &free_list;
ffffffffc0201372:	87ae                	mv	a5,a1
    struct Page *page = NULL;
ffffffffc0201374:	4501                	li	a0,0
    return listelm->next;
ffffffffc0201376:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201378:	02b78263          	beq	a5,a1,ffffffffc020139c <best_fit_alloc_pages+0x4c>
        if (p->property >= n) {
ffffffffc020137c:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201380:	02071693          	slli	a3,a4,0x20
ffffffffc0201384:	9281                	srli	a3,a3,0x20
ffffffffc0201386:	fec6e8e3          	bltu	a3,a2,ffffffffc0201376 <best_fit_alloc_pages+0x26>
            if (p->property < min) {
ffffffffc020138a:	ff0776e3          	bgeu	a4,a6,ffffffffc0201376 <best_fit_alloc_pages+0x26>
        struct Page *p = le2page(le, page_link);
ffffffffc020138e:	fe878513          	addi	a0,a5,-24
ffffffffc0201392:	679c                	ld	a5,8(a5)
            	min = p->property; // 更新最小连续空闲页框数量
ffffffffc0201394:	0007081b          	sext.w	a6,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201398:	feb792e3          	bne	a5,a1,ffffffffc020137c <best_fit_alloc_pages+0x2c>
    if (page != NULL) {
ffffffffc020139c:	c125                	beqz	a0,ffffffffc02013fc <best_fit_alloc_pages+0xac>
    __list_del(listelm->prev, listelm->next);
ffffffffc020139e:	7118                	ld	a4,32(a0)
    return listelm->prev;
ffffffffc02013a0:	6d14                	ld	a3,24(a0)
        if (page->property > n) {
ffffffffc02013a2:	490c                	lw	a1,16(a0)
ffffffffc02013a4:	0006081b          	sext.w	a6,a2
    prev->next = next;
ffffffffc02013a8:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc02013aa:	e314                	sd	a3,0(a4)
ffffffffc02013ac:	02059713          	slli	a4,a1,0x20
ffffffffc02013b0:	9301                	srli	a4,a4,0x20
ffffffffc02013b2:	02e67863          	bgeu	a2,a4,ffffffffc02013e2 <best_fit_alloc_pages+0x92>
            struct Page *p = page + n;
ffffffffc02013b6:	00261713          	slli	a4,a2,0x2
ffffffffc02013ba:	9732                	add	a4,a4,a2
ffffffffc02013bc:	070e                	slli	a4,a4,0x3
ffffffffc02013be:	972a                	add	a4,a4,a0
            p->property = page->property - n;
ffffffffc02013c0:	410585bb          	subw	a1,a1,a6
ffffffffc02013c4:	cb0c                	sw	a1,16(a4)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02013c6:	4609                	li	a2,2
ffffffffc02013c8:	00870593          	addi	a1,a4,8
ffffffffc02013cc:	40c5b02f          	amoor.d	zero,a2,(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc02013d0:	6690                	ld	a2,8(a3)
            list_add(prev, &(p->page_link));
ffffffffc02013d2:	01870593          	addi	a1,a4,24
    prev->next = next->prev = elm;
ffffffffc02013d6:	0107a883          	lw	a7,16(a5)
ffffffffc02013da:	e20c                	sd	a1,0(a2)
ffffffffc02013dc:	e68c                	sd	a1,8(a3)
    elm->next = next;
ffffffffc02013de:	f310                	sd	a2,32(a4)
    elm->prev = prev;
ffffffffc02013e0:	ef14                	sd	a3,24(a4)
        nr_free -= n;
ffffffffc02013e2:	410888bb          	subw	a7,a7,a6
ffffffffc02013e6:	00005797          	auipc	a5,0x5
ffffffffc02013ea:	0917a123          	sw	a7,130(a5) # ffffffffc0206468 <free_area+0x10>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02013ee:	57f5                	li	a5,-3
ffffffffc02013f0:	00850713          	addi	a4,a0,8
ffffffffc02013f4:	60f7302f          	amoand.d	zero,a5,(a4)
ffffffffc02013f8:	8082                	ret
        return NULL;
ffffffffc02013fa:	4501                	li	a0,0
}
ffffffffc02013fc:	8082                	ret
best_fit_alloc_pages(size_t n) {
ffffffffc02013fe:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0201400:	00001697          	auipc	a3,0x1
ffffffffc0201404:	24868693          	addi	a3,a3,584 # ffffffffc0202648 <commands+0xa58>
ffffffffc0201408:	00001617          	auipc	a2,0x1
ffffffffc020140c:	f3860613          	addi	a2,a2,-200 # ffffffffc0202340 <commands+0x750>
ffffffffc0201410:	06a00593          	li	a1,106
ffffffffc0201414:	00001517          	auipc	a0,0x1
ffffffffc0201418:	f4450513          	addi	a0,a0,-188 # ffffffffc0202358 <commands+0x768>
best_fit_alloc_pages(size_t n) {
ffffffffc020141c:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020141e:	d1ffe0ef          	jal	ra,ffffffffc020013c <__panic>

ffffffffc0201422 <best_fit_init_memmap>:
best_fit_init_memmap(struct Page *base, size_t n) {
ffffffffc0201422:	1141                	addi	sp,sp,-16
ffffffffc0201424:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201426:	c1fd                	beqz	a1,ffffffffc020150c <best_fit_init_memmap+0xea>
    for (; p != base + n; p ++) {
ffffffffc0201428:	00259693          	slli	a3,a1,0x2
ffffffffc020142c:	96ae                	add	a3,a3,a1
ffffffffc020142e:	068e                	slli	a3,a3,0x3
ffffffffc0201430:	96aa                	add	a3,a3,a0
ffffffffc0201432:	02d50463          	beq	a0,a3,ffffffffc020145a <best_fit_init_memmap+0x38>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0201436:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc0201438:	87aa                	mv	a5,a0
ffffffffc020143a:	8b05                	andi	a4,a4,1
ffffffffc020143c:	e709                	bnez	a4,ffffffffc0201446 <best_fit_init_memmap+0x24>
ffffffffc020143e:	a07d                	j	ffffffffc02014ec <best_fit_init_memmap+0xca>
ffffffffc0201440:	6798                	ld	a4,8(a5)
ffffffffc0201442:	8b05                	andi	a4,a4,1
ffffffffc0201444:	c745                	beqz	a4,ffffffffc02014ec <best_fit_init_memmap+0xca>
        p->flags = p->property = 0;
ffffffffc0201446:	0007a823          	sw	zero,16(a5)
ffffffffc020144a:	0007b423          	sd	zero,8(a5)
ffffffffc020144e:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201452:	02878793          	addi	a5,a5,40
ffffffffc0201456:	fed795e3          	bne	a5,a3,ffffffffc0201440 <best_fit_init_memmap+0x1e>
    base->property = n;
ffffffffc020145a:	2581                	sext.w	a1,a1
ffffffffc020145c:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020145e:	4789                	li	a5,2
ffffffffc0201460:	00850713          	addi	a4,a0,8
ffffffffc0201464:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0201468:	00005697          	auipc	a3,0x5
ffffffffc020146c:	ff068693          	addi	a3,a3,-16 # ffffffffc0206458 <free_area>
ffffffffc0201470:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201472:	669c                	ld	a5,8(a3)
ffffffffc0201474:	9db9                	addw	a1,a1,a4
ffffffffc0201476:	00005717          	auipc	a4,0x5
ffffffffc020147a:	feb72923          	sw	a1,-14(a4) # ffffffffc0206468 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc020147e:	04d78a63          	beq	a5,a3,ffffffffc02014d2 <best_fit_init_memmap+0xb0>
            struct Page* page = le2page(le, page_link);
ffffffffc0201482:	fe878713          	addi	a4,a5,-24
ffffffffc0201486:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0201488:	4801                	li	a6,0
ffffffffc020148a:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc020148e:	00e56a63          	bltu	a0,a4,ffffffffc02014a2 <best_fit_init_memmap+0x80>
    return listelm->next;
ffffffffc0201492:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0201494:	02d70563          	beq	a4,a3,ffffffffc02014be <best_fit_init_memmap+0x9c>
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201498:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc020149a:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc020149e:	fee57ae3          	bgeu	a0,a4,ffffffffc0201492 <best_fit_init_memmap+0x70>
ffffffffc02014a2:	00080663          	beqz	a6,ffffffffc02014ae <best_fit_init_memmap+0x8c>
ffffffffc02014a6:	00005717          	auipc	a4,0x5
ffffffffc02014aa:	fab73923          	sd	a1,-78(a4) # ffffffffc0206458 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc02014ae:	6398                	ld	a4,0(a5)
}
ffffffffc02014b0:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc02014b2:	e390                	sd	a2,0(a5)
ffffffffc02014b4:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02014b6:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02014b8:	ed18                	sd	a4,24(a0)
ffffffffc02014ba:	0141                	addi	sp,sp,16
ffffffffc02014bc:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02014be:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02014c0:	f114                	sd	a3,32(a0)
ffffffffc02014c2:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02014c4:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc02014c6:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc02014c8:	00d70e63          	beq	a4,a3,ffffffffc02014e4 <best_fit_init_memmap+0xc2>
ffffffffc02014cc:	4805                	li	a6,1
ffffffffc02014ce:	87ba                	mv	a5,a4
ffffffffc02014d0:	b7e9                	j	ffffffffc020149a <best_fit_init_memmap+0x78>
}
ffffffffc02014d2:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc02014d4:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc02014d8:	e398                	sd	a4,0(a5)
ffffffffc02014da:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc02014dc:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02014de:	ed1c                	sd	a5,24(a0)
}
ffffffffc02014e0:	0141                	addi	sp,sp,16
ffffffffc02014e2:	8082                	ret
ffffffffc02014e4:	60a2                	ld	ra,8(sp)
ffffffffc02014e6:	e290                	sd	a2,0(a3)
ffffffffc02014e8:	0141                	addi	sp,sp,16
ffffffffc02014ea:	8082                	ret
        assert(PageReserved(p));
ffffffffc02014ec:	00001697          	auipc	a3,0x1
ffffffffc02014f0:	16468693          	addi	a3,a3,356 # ffffffffc0202650 <commands+0xa60>
ffffffffc02014f4:	00001617          	auipc	a2,0x1
ffffffffc02014f8:	e4c60613          	addi	a2,a2,-436 # ffffffffc0202340 <commands+0x750>
ffffffffc02014fc:	04a00593          	li	a1,74
ffffffffc0201500:	00001517          	auipc	a0,0x1
ffffffffc0201504:	e5850513          	addi	a0,a0,-424 # ffffffffc0202358 <commands+0x768>
ffffffffc0201508:	c35fe0ef          	jal	ra,ffffffffc020013c <__panic>
    assert(n > 0);
ffffffffc020150c:	00001697          	auipc	a3,0x1
ffffffffc0201510:	13c68693          	addi	a3,a3,316 # ffffffffc0202648 <commands+0xa58>
ffffffffc0201514:	00001617          	auipc	a2,0x1
ffffffffc0201518:	e2c60613          	addi	a2,a2,-468 # ffffffffc0202340 <commands+0x750>
ffffffffc020151c:	04700593          	li	a1,71
ffffffffc0201520:	00001517          	auipc	a0,0x1
ffffffffc0201524:	e3850513          	addi	a0,a0,-456 # ffffffffc0202358 <commands+0x768>
ffffffffc0201528:	c15fe0ef          	jal	ra,ffffffffc020013c <__panic>

ffffffffc020152c <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc020152c:	c185                	beqz	a1,ffffffffc020154c <strnlen+0x20>
ffffffffc020152e:	00054783          	lbu	a5,0(a0)
ffffffffc0201532:	cf89                	beqz	a5,ffffffffc020154c <strnlen+0x20>
    size_t cnt = 0;
ffffffffc0201534:	4781                	li	a5,0
ffffffffc0201536:	a021                	j	ffffffffc020153e <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201538:	00074703          	lbu	a4,0(a4)
ffffffffc020153c:	c711                	beqz	a4,ffffffffc0201548 <strnlen+0x1c>
        cnt ++;
ffffffffc020153e:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201540:	00f50733          	add	a4,a0,a5
ffffffffc0201544:	fef59ae3          	bne	a1,a5,ffffffffc0201538 <strnlen+0xc>
    }
    return cnt;
}
ffffffffc0201548:	853e                	mv	a0,a5
ffffffffc020154a:	8082                	ret
    size_t cnt = 0;
ffffffffc020154c:	4781                	li	a5,0
}
ffffffffc020154e:	853e                	mv	a0,a5
ffffffffc0201550:	8082                	ret

ffffffffc0201552 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201552:	00054783          	lbu	a5,0(a0)
ffffffffc0201556:	0005c703          	lbu	a4,0(a1)
ffffffffc020155a:	cb91                	beqz	a5,ffffffffc020156e <strcmp+0x1c>
ffffffffc020155c:	00e79c63          	bne	a5,a4,ffffffffc0201574 <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc0201560:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201562:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc0201566:	0585                	addi	a1,a1,1
ffffffffc0201568:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020156c:	fbe5                	bnez	a5,ffffffffc020155c <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020156e:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0201570:	9d19                	subw	a0,a0,a4
ffffffffc0201572:	8082                	ret
ffffffffc0201574:	0007851b          	sext.w	a0,a5
ffffffffc0201578:	9d19                	subw	a0,a0,a4
ffffffffc020157a:	8082                	ret

ffffffffc020157c <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc020157c:	00054783          	lbu	a5,0(a0)
ffffffffc0201580:	cb91                	beqz	a5,ffffffffc0201594 <strchr+0x18>
        if (*s == c) {
ffffffffc0201582:	00b79563          	bne	a5,a1,ffffffffc020158c <strchr+0x10>
ffffffffc0201586:	a809                	j	ffffffffc0201598 <strchr+0x1c>
ffffffffc0201588:	00b78763          	beq	a5,a1,ffffffffc0201596 <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc020158c:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc020158e:	00054783          	lbu	a5,0(a0)
ffffffffc0201592:	fbfd                	bnez	a5,ffffffffc0201588 <strchr+0xc>
    }
    return NULL;
ffffffffc0201594:	4501                	li	a0,0
}
ffffffffc0201596:	8082                	ret
ffffffffc0201598:	8082                	ret

ffffffffc020159a <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc020159a:	ca01                	beqz	a2,ffffffffc02015aa <memset+0x10>
ffffffffc020159c:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc020159e:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc02015a0:	0785                	addi	a5,a5,1
ffffffffc02015a2:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc02015a6:	fec79de3          	bne	a5,a2,ffffffffc02015a0 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc02015aa:	8082                	ret

ffffffffc02015ac <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc02015ac:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02015b0:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc02015b2:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02015b6:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc02015b8:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02015bc:	f022                	sd	s0,32(sp)
ffffffffc02015be:	ec26                	sd	s1,24(sp)
ffffffffc02015c0:	e84a                	sd	s2,16(sp)
ffffffffc02015c2:	f406                	sd	ra,40(sp)
ffffffffc02015c4:	e44e                	sd	s3,8(sp)
ffffffffc02015c6:	84aa                	mv	s1,a0
ffffffffc02015c8:	892e                	mv	s2,a1
ffffffffc02015ca:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc02015ce:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc02015d0:	03067e63          	bgeu	a2,a6,ffffffffc020160c <printnum+0x60>
ffffffffc02015d4:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc02015d6:	00805763          	blez	s0,ffffffffc02015e4 <printnum+0x38>
ffffffffc02015da:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc02015dc:	85ca                	mv	a1,s2
ffffffffc02015de:	854e                	mv	a0,s3
ffffffffc02015e0:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc02015e2:	fc65                	bnez	s0,ffffffffc02015da <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02015e4:	1a02                	slli	s4,s4,0x20
ffffffffc02015e6:	020a5a13          	srli	s4,s4,0x20
ffffffffc02015ea:	00001797          	auipc	a5,0x1
ffffffffc02015ee:	25678793          	addi	a5,a5,598 # ffffffffc0202840 <error_string+0x38>
ffffffffc02015f2:	9a3e                	add	s4,s4,a5
}
ffffffffc02015f4:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02015f6:	000a4503          	lbu	a0,0(s4)
}
ffffffffc02015fa:	70a2                	ld	ra,40(sp)
ffffffffc02015fc:	69a2                	ld	s3,8(sp)
ffffffffc02015fe:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201600:	85ca                	mv	a1,s2
ffffffffc0201602:	8326                	mv	t1,s1
}
ffffffffc0201604:	6942                	ld	s2,16(sp)
ffffffffc0201606:	64e2                	ld	s1,24(sp)
ffffffffc0201608:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020160a:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc020160c:	03065633          	divu	a2,a2,a6
ffffffffc0201610:	8722                	mv	a4,s0
ffffffffc0201612:	f9bff0ef          	jal	ra,ffffffffc02015ac <printnum>
ffffffffc0201616:	b7f9                	j	ffffffffc02015e4 <printnum+0x38>

ffffffffc0201618 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0201618:	7119                	addi	sp,sp,-128
ffffffffc020161a:	f4a6                	sd	s1,104(sp)
ffffffffc020161c:	f0ca                	sd	s2,96(sp)
ffffffffc020161e:	e8d2                	sd	s4,80(sp)
ffffffffc0201620:	e4d6                	sd	s5,72(sp)
ffffffffc0201622:	e0da                	sd	s6,64(sp)
ffffffffc0201624:	fc5e                	sd	s7,56(sp)
ffffffffc0201626:	f862                	sd	s8,48(sp)
ffffffffc0201628:	f06a                	sd	s10,32(sp)
ffffffffc020162a:	fc86                	sd	ra,120(sp)
ffffffffc020162c:	f8a2                	sd	s0,112(sp)
ffffffffc020162e:	ecce                	sd	s3,88(sp)
ffffffffc0201630:	f466                	sd	s9,40(sp)
ffffffffc0201632:	ec6e                	sd	s11,24(sp)
ffffffffc0201634:	892a                	mv	s2,a0
ffffffffc0201636:	84ae                	mv	s1,a1
ffffffffc0201638:	8d32                	mv	s10,a2
ffffffffc020163a:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc020163c:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020163e:	00001a17          	auipc	s4,0x1
ffffffffc0201642:	072a0a13          	addi	s4,s4,114 # ffffffffc02026b0 <best_fit_pmm_manager+0x50>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201646:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020164a:	00001c17          	auipc	s8,0x1
ffffffffc020164e:	1bec0c13          	addi	s8,s8,446 # ffffffffc0202808 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201652:	000d4503          	lbu	a0,0(s10)
ffffffffc0201656:	02500793          	li	a5,37
ffffffffc020165a:	001d0413          	addi	s0,s10,1
ffffffffc020165e:	00f50e63          	beq	a0,a5,ffffffffc020167a <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc0201662:	c521                	beqz	a0,ffffffffc02016aa <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201664:	02500993          	li	s3,37
ffffffffc0201668:	a011                	j	ffffffffc020166c <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc020166a:	c121                	beqz	a0,ffffffffc02016aa <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc020166c:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020166e:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0201670:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201672:	fff44503          	lbu	a0,-1(s0)
ffffffffc0201676:	ff351ae3          	bne	a0,s3,ffffffffc020166a <vprintfmt+0x52>
ffffffffc020167a:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc020167e:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0201682:	4981                	li	s3,0
ffffffffc0201684:	4801                	li	a6,0
        width = precision = -1;
ffffffffc0201686:	5cfd                	li	s9,-1
ffffffffc0201688:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020168a:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc020168e:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201690:	fdd6069b          	addiw	a3,a2,-35
ffffffffc0201694:	0ff6f693          	andi	a3,a3,255
ffffffffc0201698:	00140d13          	addi	s10,s0,1
ffffffffc020169c:	1ed5ef63          	bltu	a1,a3,ffffffffc020189a <vprintfmt+0x282>
ffffffffc02016a0:	068a                	slli	a3,a3,0x2
ffffffffc02016a2:	96d2                	add	a3,a3,s4
ffffffffc02016a4:	4294                	lw	a3,0(a3)
ffffffffc02016a6:	96d2                	add	a3,a3,s4
ffffffffc02016a8:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc02016aa:	70e6                	ld	ra,120(sp)
ffffffffc02016ac:	7446                	ld	s0,112(sp)
ffffffffc02016ae:	74a6                	ld	s1,104(sp)
ffffffffc02016b0:	7906                	ld	s2,96(sp)
ffffffffc02016b2:	69e6                	ld	s3,88(sp)
ffffffffc02016b4:	6a46                	ld	s4,80(sp)
ffffffffc02016b6:	6aa6                	ld	s5,72(sp)
ffffffffc02016b8:	6b06                	ld	s6,64(sp)
ffffffffc02016ba:	7be2                	ld	s7,56(sp)
ffffffffc02016bc:	7c42                	ld	s8,48(sp)
ffffffffc02016be:	7ca2                	ld	s9,40(sp)
ffffffffc02016c0:	7d02                	ld	s10,32(sp)
ffffffffc02016c2:	6de2                	ld	s11,24(sp)
ffffffffc02016c4:	6109                	addi	sp,sp,128
ffffffffc02016c6:	8082                	ret
            padc = '-';
ffffffffc02016c8:	87b2                	mv	a5,a2
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02016ca:	00144603          	lbu	a2,1(s0)
ffffffffc02016ce:	846a                	mv	s0,s10
ffffffffc02016d0:	b7c1                	j	ffffffffc0201690 <vprintfmt+0x78>
            precision = va_arg(ap, int);
ffffffffc02016d2:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc02016d6:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc02016da:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02016dc:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc02016de:	fa0dd9e3          	bgez	s11,ffffffffc0201690 <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc02016e2:	8de6                	mv	s11,s9
ffffffffc02016e4:	5cfd                	li	s9,-1
ffffffffc02016e6:	b76d                	j	ffffffffc0201690 <vprintfmt+0x78>
            if (width < 0)
ffffffffc02016e8:	fffdc693          	not	a3,s11
ffffffffc02016ec:	96fd                	srai	a3,a3,0x3f
ffffffffc02016ee:	00ddfdb3          	and	s11,s11,a3
ffffffffc02016f2:	00144603          	lbu	a2,1(s0)
ffffffffc02016f6:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02016f8:	846a                	mv	s0,s10
ffffffffc02016fa:	bf59                	j	ffffffffc0201690 <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc02016fc:	4705                	li	a4,1
ffffffffc02016fe:	008a8593          	addi	a1,s5,8
ffffffffc0201702:	01074463          	blt	a4,a6,ffffffffc020170a <vprintfmt+0xf2>
    else if (lflag) {
ffffffffc0201706:	22080863          	beqz	a6,ffffffffc0201936 <vprintfmt+0x31e>
        return va_arg(*ap, unsigned long);
ffffffffc020170a:	000ab603          	ld	a2,0(s5)
ffffffffc020170e:	46c1                	li	a3,16
ffffffffc0201710:	8aae                	mv	s5,a1
ffffffffc0201712:	a291                	j	ffffffffc0201856 <vprintfmt+0x23e>
                precision = precision * 10 + ch - '0';
ffffffffc0201714:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc0201718:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020171c:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc020171e:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0201722:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201726:	fad56ce3          	bltu	a0,a3,ffffffffc02016de <vprintfmt+0xc6>
            for (precision = 0; ; ++ fmt) {
ffffffffc020172a:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc020172c:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc0201730:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0201734:	0196873b          	addw	a4,a3,s9
ffffffffc0201738:	0017171b          	slliw	a4,a4,0x1
ffffffffc020173c:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc0201740:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc0201744:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc0201748:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc020174c:	fcd57fe3          	bgeu	a0,a3,ffffffffc020172a <vprintfmt+0x112>
ffffffffc0201750:	b779                	j	ffffffffc02016de <vprintfmt+0xc6>
            putch(va_arg(ap, int), putdat);
ffffffffc0201752:	000aa503          	lw	a0,0(s5)
ffffffffc0201756:	85a6                	mv	a1,s1
ffffffffc0201758:	0aa1                	addi	s5,s5,8
ffffffffc020175a:	9902                	jalr	s2
            break;
ffffffffc020175c:	bddd                	j	ffffffffc0201652 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020175e:	4705                	li	a4,1
ffffffffc0201760:	008a8993          	addi	s3,s5,8
ffffffffc0201764:	01074463          	blt	a4,a6,ffffffffc020176c <vprintfmt+0x154>
    else if (lflag) {
ffffffffc0201768:	1c080463          	beqz	a6,ffffffffc0201930 <vprintfmt+0x318>
        return va_arg(*ap, long);
ffffffffc020176c:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc0201770:	1c044a63          	bltz	s0,ffffffffc0201944 <vprintfmt+0x32c>
            num = getint(&ap, lflag);
ffffffffc0201774:	8622                	mv	a2,s0
ffffffffc0201776:	8ace                	mv	s5,s3
ffffffffc0201778:	46a9                	li	a3,10
ffffffffc020177a:	a8f1                	j	ffffffffc0201856 <vprintfmt+0x23e>
            err = va_arg(ap, int);
ffffffffc020177c:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201780:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0201782:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc0201784:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0201788:	8fb5                	xor	a5,a5,a3
ffffffffc020178a:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020178e:	12d74963          	blt	a4,a3,ffffffffc02018c0 <vprintfmt+0x2a8>
ffffffffc0201792:	00369793          	slli	a5,a3,0x3
ffffffffc0201796:	97e2                	add	a5,a5,s8
ffffffffc0201798:	639c                	ld	a5,0(a5)
ffffffffc020179a:	12078363          	beqz	a5,ffffffffc02018c0 <vprintfmt+0x2a8>
                printfmt(putch, putdat, "%s", p);
ffffffffc020179e:	86be                	mv	a3,a5
ffffffffc02017a0:	00001617          	auipc	a2,0x1
ffffffffc02017a4:	15060613          	addi	a2,a2,336 # ffffffffc02028f0 <error_string+0xe8>
ffffffffc02017a8:	85a6                	mv	a1,s1
ffffffffc02017aa:	854a                	mv	a0,s2
ffffffffc02017ac:	1cc000ef          	jal	ra,ffffffffc0201978 <printfmt>
ffffffffc02017b0:	b54d                	j	ffffffffc0201652 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02017b2:	000ab603          	ld	a2,0(s5)
ffffffffc02017b6:	0aa1                	addi	s5,s5,8
ffffffffc02017b8:	1a060163          	beqz	a2,ffffffffc020195a <vprintfmt+0x342>
            if (width > 0 && padc != '-') {
ffffffffc02017bc:	00160413          	addi	s0,a2,1
ffffffffc02017c0:	15b05763          	blez	s11,ffffffffc020190e <vprintfmt+0x2f6>
ffffffffc02017c4:	02d00593          	li	a1,45
ffffffffc02017c8:	10b79d63          	bne	a5,a1,ffffffffc02018e2 <vprintfmt+0x2ca>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02017cc:	00064783          	lbu	a5,0(a2)
ffffffffc02017d0:	0007851b          	sext.w	a0,a5
ffffffffc02017d4:	c905                	beqz	a0,ffffffffc0201804 <vprintfmt+0x1ec>
ffffffffc02017d6:	000cc563          	bltz	s9,ffffffffc02017e0 <vprintfmt+0x1c8>
ffffffffc02017da:	3cfd                	addiw	s9,s9,-1
ffffffffc02017dc:	036c8263          	beq	s9,s6,ffffffffc0201800 <vprintfmt+0x1e8>
                    putch('?', putdat);
ffffffffc02017e0:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02017e2:	14098f63          	beqz	s3,ffffffffc0201940 <vprintfmt+0x328>
ffffffffc02017e6:	3781                	addiw	a5,a5,-32
ffffffffc02017e8:	14fbfc63          	bgeu	s7,a5,ffffffffc0201940 <vprintfmt+0x328>
                    putch('?', putdat);
ffffffffc02017ec:	03f00513          	li	a0,63
ffffffffc02017f0:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02017f2:	0405                	addi	s0,s0,1
ffffffffc02017f4:	fff44783          	lbu	a5,-1(s0)
ffffffffc02017f8:	3dfd                	addiw	s11,s11,-1
ffffffffc02017fa:	0007851b          	sext.w	a0,a5
ffffffffc02017fe:	fd61                	bnez	a0,ffffffffc02017d6 <vprintfmt+0x1be>
            for (; width > 0; width --) {
ffffffffc0201800:	e5b059e3          	blez	s11,ffffffffc0201652 <vprintfmt+0x3a>
ffffffffc0201804:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0201806:	85a6                	mv	a1,s1
ffffffffc0201808:	02000513          	li	a0,32
ffffffffc020180c:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc020180e:	e40d82e3          	beqz	s11,ffffffffc0201652 <vprintfmt+0x3a>
ffffffffc0201812:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0201814:	85a6                	mv	a1,s1
ffffffffc0201816:	02000513          	li	a0,32
ffffffffc020181a:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc020181c:	fe0d94e3          	bnez	s11,ffffffffc0201804 <vprintfmt+0x1ec>
ffffffffc0201820:	bd0d                	j	ffffffffc0201652 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201822:	4705                	li	a4,1
ffffffffc0201824:	008a8593          	addi	a1,s5,8
ffffffffc0201828:	01074463          	blt	a4,a6,ffffffffc0201830 <vprintfmt+0x218>
    else if (lflag) {
ffffffffc020182c:	0e080863          	beqz	a6,ffffffffc020191c <vprintfmt+0x304>
        return va_arg(*ap, unsigned long);
ffffffffc0201830:	000ab603          	ld	a2,0(s5)
ffffffffc0201834:	46a1                	li	a3,8
ffffffffc0201836:	8aae                	mv	s5,a1
ffffffffc0201838:	a839                	j	ffffffffc0201856 <vprintfmt+0x23e>
            putch('0', putdat);
ffffffffc020183a:	03000513          	li	a0,48
ffffffffc020183e:	85a6                	mv	a1,s1
ffffffffc0201840:	e03e                	sd	a5,0(sp)
ffffffffc0201842:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0201844:	85a6                	mv	a1,s1
ffffffffc0201846:	07800513          	li	a0,120
ffffffffc020184a:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020184c:	0aa1                	addi	s5,s5,8
ffffffffc020184e:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc0201852:	6782                	ld	a5,0(sp)
ffffffffc0201854:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0201856:	2781                	sext.w	a5,a5
ffffffffc0201858:	876e                	mv	a4,s11
ffffffffc020185a:	85a6                	mv	a1,s1
ffffffffc020185c:	854a                	mv	a0,s2
ffffffffc020185e:	d4fff0ef          	jal	ra,ffffffffc02015ac <printnum>
            break;
ffffffffc0201862:	bbc5                	j	ffffffffc0201652 <vprintfmt+0x3a>
            lflag ++;
ffffffffc0201864:	00144603          	lbu	a2,1(s0)
ffffffffc0201868:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020186a:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020186c:	b515                	j	ffffffffc0201690 <vprintfmt+0x78>
            goto reswitch;
ffffffffc020186e:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0201872:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201874:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201876:	bd29                	j	ffffffffc0201690 <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc0201878:	85a6                	mv	a1,s1
ffffffffc020187a:	02500513          	li	a0,37
ffffffffc020187e:	9902                	jalr	s2
            break;
ffffffffc0201880:	bbc9                	j	ffffffffc0201652 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201882:	4705                	li	a4,1
ffffffffc0201884:	008a8593          	addi	a1,s5,8
ffffffffc0201888:	01074463          	blt	a4,a6,ffffffffc0201890 <vprintfmt+0x278>
    else if (lflag) {
ffffffffc020188c:	08080d63          	beqz	a6,ffffffffc0201926 <vprintfmt+0x30e>
        return va_arg(*ap, unsigned long);
ffffffffc0201890:	000ab603          	ld	a2,0(s5)
ffffffffc0201894:	46a9                	li	a3,10
ffffffffc0201896:	8aae                	mv	s5,a1
ffffffffc0201898:	bf7d                	j	ffffffffc0201856 <vprintfmt+0x23e>
            putch('%', putdat);
ffffffffc020189a:	85a6                	mv	a1,s1
ffffffffc020189c:	02500513          	li	a0,37
ffffffffc02018a0:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc02018a2:	fff44703          	lbu	a4,-1(s0)
ffffffffc02018a6:	02500793          	li	a5,37
ffffffffc02018aa:	8d22                	mv	s10,s0
ffffffffc02018ac:	daf703e3          	beq	a4,a5,ffffffffc0201652 <vprintfmt+0x3a>
ffffffffc02018b0:	02500713          	li	a4,37
ffffffffc02018b4:	1d7d                	addi	s10,s10,-1
ffffffffc02018b6:	fffd4783          	lbu	a5,-1(s10)
ffffffffc02018ba:	fee79de3          	bne	a5,a4,ffffffffc02018b4 <vprintfmt+0x29c>
ffffffffc02018be:	bb51                	j	ffffffffc0201652 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc02018c0:	00001617          	auipc	a2,0x1
ffffffffc02018c4:	02060613          	addi	a2,a2,32 # ffffffffc02028e0 <error_string+0xd8>
ffffffffc02018c8:	85a6                	mv	a1,s1
ffffffffc02018ca:	854a                	mv	a0,s2
ffffffffc02018cc:	0ac000ef          	jal	ra,ffffffffc0201978 <printfmt>
ffffffffc02018d0:	b349                	j	ffffffffc0201652 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc02018d2:	00001617          	auipc	a2,0x1
ffffffffc02018d6:	00660613          	addi	a2,a2,6 # ffffffffc02028d8 <error_string+0xd0>
            if (width > 0 && padc != '-') {
ffffffffc02018da:	00001417          	auipc	s0,0x1
ffffffffc02018de:	fff40413          	addi	s0,s0,-1 # ffffffffc02028d9 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02018e2:	8532                	mv	a0,a2
ffffffffc02018e4:	85e6                	mv	a1,s9
ffffffffc02018e6:	e032                	sd	a2,0(sp)
ffffffffc02018e8:	e43e                	sd	a5,8(sp)
ffffffffc02018ea:	c43ff0ef          	jal	ra,ffffffffc020152c <strnlen>
ffffffffc02018ee:	40ad8dbb          	subw	s11,s11,a0
ffffffffc02018f2:	6602                	ld	a2,0(sp)
ffffffffc02018f4:	01b05d63          	blez	s11,ffffffffc020190e <vprintfmt+0x2f6>
ffffffffc02018f8:	67a2                	ld	a5,8(sp)
ffffffffc02018fa:	2781                	sext.w	a5,a5
ffffffffc02018fc:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc02018fe:	6522                	ld	a0,8(sp)
ffffffffc0201900:	85a6                	mv	a1,s1
ffffffffc0201902:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201904:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0201906:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201908:	6602                	ld	a2,0(sp)
ffffffffc020190a:	fe0d9ae3          	bnez	s11,ffffffffc02018fe <vprintfmt+0x2e6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020190e:	00064783          	lbu	a5,0(a2)
ffffffffc0201912:	0007851b          	sext.w	a0,a5
ffffffffc0201916:	ec0510e3          	bnez	a0,ffffffffc02017d6 <vprintfmt+0x1be>
ffffffffc020191a:	bb25                	j	ffffffffc0201652 <vprintfmt+0x3a>
        return va_arg(*ap, unsigned int);
ffffffffc020191c:	000ae603          	lwu	a2,0(s5)
ffffffffc0201920:	46a1                	li	a3,8
ffffffffc0201922:	8aae                	mv	s5,a1
ffffffffc0201924:	bf0d                	j	ffffffffc0201856 <vprintfmt+0x23e>
ffffffffc0201926:	000ae603          	lwu	a2,0(s5)
ffffffffc020192a:	46a9                	li	a3,10
ffffffffc020192c:	8aae                	mv	s5,a1
ffffffffc020192e:	b725                	j	ffffffffc0201856 <vprintfmt+0x23e>
        return va_arg(*ap, int);
ffffffffc0201930:	000aa403          	lw	s0,0(s5)
ffffffffc0201934:	bd35                	j	ffffffffc0201770 <vprintfmt+0x158>
        return va_arg(*ap, unsigned int);
ffffffffc0201936:	000ae603          	lwu	a2,0(s5)
ffffffffc020193a:	46c1                	li	a3,16
ffffffffc020193c:	8aae                	mv	s5,a1
ffffffffc020193e:	bf21                	j	ffffffffc0201856 <vprintfmt+0x23e>
                    putch(ch, putdat);
ffffffffc0201940:	9902                	jalr	s2
ffffffffc0201942:	bd45                	j	ffffffffc02017f2 <vprintfmt+0x1da>
                putch('-', putdat);
ffffffffc0201944:	85a6                	mv	a1,s1
ffffffffc0201946:	02d00513          	li	a0,45
ffffffffc020194a:	e03e                	sd	a5,0(sp)
ffffffffc020194c:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc020194e:	8ace                	mv	s5,s3
ffffffffc0201950:	40800633          	neg	a2,s0
ffffffffc0201954:	46a9                	li	a3,10
ffffffffc0201956:	6782                	ld	a5,0(sp)
ffffffffc0201958:	bdfd                	j	ffffffffc0201856 <vprintfmt+0x23e>
            if (width > 0 && padc != '-') {
ffffffffc020195a:	01b05663          	blez	s11,ffffffffc0201966 <vprintfmt+0x34e>
ffffffffc020195e:	02d00693          	li	a3,45
ffffffffc0201962:	f6d798e3          	bne	a5,a3,ffffffffc02018d2 <vprintfmt+0x2ba>
ffffffffc0201966:	00001417          	auipc	s0,0x1
ffffffffc020196a:	f7340413          	addi	s0,s0,-141 # ffffffffc02028d9 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020196e:	02800513          	li	a0,40
ffffffffc0201972:	02800793          	li	a5,40
ffffffffc0201976:	b585                	j	ffffffffc02017d6 <vprintfmt+0x1be>

ffffffffc0201978 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201978:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc020197a:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020197e:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201980:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201982:	ec06                	sd	ra,24(sp)
ffffffffc0201984:	f83a                	sd	a4,48(sp)
ffffffffc0201986:	fc3e                	sd	a5,56(sp)
ffffffffc0201988:	e0c2                	sd	a6,64(sp)
ffffffffc020198a:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc020198c:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020198e:	c8bff0ef          	jal	ra,ffffffffc0201618 <vprintfmt>
}
ffffffffc0201992:	60e2                	ld	ra,24(sp)
ffffffffc0201994:	6161                	addi	sp,sp,80
ffffffffc0201996:	8082                	ret

ffffffffc0201998 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0201998:	715d                	addi	sp,sp,-80
ffffffffc020199a:	e486                	sd	ra,72(sp)
ffffffffc020199c:	e0a2                	sd	s0,64(sp)
ffffffffc020199e:	fc26                	sd	s1,56(sp)
ffffffffc02019a0:	f84a                	sd	s2,48(sp)
ffffffffc02019a2:	f44e                	sd	s3,40(sp)
ffffffffc02019a4:	f052                	sd	s4,32(sp)
ffffffffc02019a6:	ec56                	sd	s5,24(sp)
ffffffffc02019a8:	e85a                	sd	s6,16(sp)
ffffffffc02019aa:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc02019ac:	c901                	beqz	a0,ffffffffc02019bc <readline+0x24>
        cprintf("%s", prompt);
ffffffffc02019ae:	85aa                	mv	a1,a0
ffffffffc02019b0:	00001517          	auipc	a0,0x1
ffffffffc02019b4:	f4050513          	addi	a0,a0,-192 # ffffffffc02028f0 <error_string+0xe8>
ffffffffc02019b8:	efefe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
readline(const char *prompt) {
ffffffffc02019bc:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02019be:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc02019c0:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc02019c2:	4aa9                	li	s5,10
ffffffffc02019c4:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc02019c6:	00004b97          	auipc	s7,0x4
ffffffffc02019ca:	64ab8b93          	addi	s7,s7,1610 # ffffffffc0206010 <edata>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02019ce:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02019d2:	f5afe0ef          	jal	ra,ffffffffc020012c <getchar>
ffffffffc02019d6:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02019d8:	00054b63          	bltz	a0,ffffffffc02019ee <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02019dc:	00a95b63          	bge	s2,a0,ffffffffc02019f2 <readline+0x5a>
ffffffffc02019e0:	029a5463          	bge	s4,s1,ffffffffc0201a08 <readline+0x70>
        c = getchar();
ffffffffc02019e4:	f48fe0ef          	jal	ra,ffffffffc020012c <getchar>
ffffffffc02019e8:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02019ea:	fe0559e3          	bgez	a0,ffffffffc02019dc <readline+0x44>
            return NULL;
ffffffffc02019ee:	4501                	li	a0,0
ffffffffc02019f0:	a099                	j	ffffffffc0201a36 <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc02019f2:	03341463          	bne	s0,s3,ffffffffc0201a1a <readline+0x82>
ffffffffc02019f6:	e8b9                	bnez	s1,ffffffffc0201a4c <readline+0xb4>
        c = getchar();
ffffffffc02019f8:	f34fe0ef          	jal	ra,ffffffffc020012c <getchar>
ffffffffc02019fc:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02019fe:	fe0548e3          	bltz	a0,ffffffffc02019ee <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201a02:	fea958e3          	bge	s2,a0,ffffffffc02019f2 <readline+0x5a>
ffffffffc0201a06:	4481                	li	s1,0
            cputchar(c);
ffffffffc0201a08:	8522                	mv	a0,s0
ffffffffc0201a0a:	ee0fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i ++] = c;
ffffffffc0201a0e:	009b87b3          	add	a5,s7,s1
ffffffffc0201a12:	00878023          	sb	s0,0(a5)
ffffffffc0201a16:	2485                	addiw	s1,s1,1
ffffffffc0201a18:	bf6d                	j	ffffffffc02019d2 <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc0201a1a:	01540463          	beq	s0,s5,ffffffffc0201a22 <readline+0x8a>
ffffffffc0201a1e:	fb641ae3          	bne	s0,s6,ffffffffc02019d2 <readline+0x3a>
            cputchar(c);
ffffffffc0201a22:	8522                	mv	a0,s0
ffffffffc0201a24:	ec6fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i] = '\0';
ffffffffc0201a28:	00004517          	auipc	a0,0x4
ffffffffc0201a2c:	5e850513          	addi	a0,a0,1512 # ffffffffc0206010 <edata>
ffffffffc0201a30:	94aa                	add	s1,s1,a0
ffffffffc0201a32:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0201a36:	60a6                	ld	ra,72(sp)
ffffffffc0201a38:	6406                	ld	s0,64(sp)
ffffffffc0201a3a:	74e2                	ld	s1,56(sp)
ffffffffc0201a3c:	7942                	ld	s2,48(sp)
ffffffffc0201a3e:	79a2                	ld	s3,40(sp)
ffffffffc0201a40:	7a02                	ld	s4,32(sp)
ffffffffc0201a42:	6ae2                	ld	s5,24(sp)
ffffffffc0201a44:	6b42                	ld	s6,16(sp)
ffffffffc0201a46:	6ba2                	ld	s7,8(sp)
ffffffffc0201a48:	6161                	addi	sp,sp,80
ffffffffc0201a4a:	8082                	ret
            cputchar(c);
ffffffffc0201a4c:	4521                	li	a0,8
ffffffffc0201a4e:	e9cfe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            i --;
ffffffffc0201a52:	34fd                	addiw	s1,s1,-1
ffffffffc0201a54:	bfbd                	j	ffffffffc02019d2 <readline+0x3a>

ffffffffc0201a56 <sbi_console_putchar>:
    );
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
ffffffffc0201a56:	00004797          	auipc	a5,0x4
ffffffffc0201a5a:	5b278793          	addi	a5,a5,1458 # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
    __asm__ volatile (
ffffffffc0201a5e:	6398                	ld	a4,0(a5)
ffffffffc0201a60:	4781                	li	a5,0
ffffffffc0201a62:	88ba                	mv	a7,a4
ffffffffc0201a64:	852a                	mv	a0,a0
ffffffffc0201a66:	85be                	mv	a1,a5
ffffffffc0201a68:	863e                	mv	a2,a5
ffffffffc0201a6a:	00000073          	ecall
ffffffffc0201a6e:	87aa                	mv	a5,a0
}
ffffffffc0201a70:	8082                	ret

ffffffffc0201a72 <sbi_set_timer>:

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
ffffffffc0201a72:	00005797          	auipc	a5,0x5
ffffffffc0201a76:	9b678793          	addi	a5,a5,-1610 # ffffffffc0206428 <SBI_SET_TIMER>
    __asm__ volatile (
ffffffffc0201a7a:	6398                	ld	a4,0(a5)
ffffffffc0201a7c:	4781                	li	a5,0
ffffffffc0201a7e:	88ba                	mv	a7,a4
ffffffffc0201a80:	852a                	mv	a0,a0
ffffffffc0201a82:	85be                	mv	a1,a5
ffffffffc0201a84:	863e                	mv	a2,a5
ffffffffc0201a86:	00000073          	ecall
ffffffffc0201a8a:	87aa                	mv	a5,a0
}
ffffffffc0201a8c:	8082                	ret

ffffffffc0201a8e <sbi_console_getchar>:

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc0201a8e:	00004797          	auipc	a5,0x4
ffffffffc0201a92:	57278793          	addi	a5,a5,1394 # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
    __asm__ volatile (
ffffffffc0201a96:	639c                	ld	a5,0(a5)
ffffffffc0201a98:	4501                	li	a0,0
ffffffffc0201a9a:	88be                	mv	a7,a5
ffffffffc0201a9c:	852a                	mv	a0,a0
ffffffffc0201a9e:	85aa                	mv	a1,a0
ffffffffc0201aa0:	862a                	mv	a2,a0
ffffffffc0201aa2:	00000073          	ecall
ffffffffc0201aa6:	852a                	mv	a0,a0
ffffffffc0201aa8:	2501                	sext.w	a0,a0
ffffffffc0201aaa:	8082                	ret
