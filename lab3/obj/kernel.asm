
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


int
kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200036:	0000a517          	auipc	a0,0xa
ffffffffc020003a:	00a50513          	addi	a0,a0,10 # ffffffffc020a040 <edata>
ffffffffc020003e:	00011617          	auipc	a2,0x11
ffffffffc0200042:	56260613          	addi	a2,a2,1378 # ffffffffc02115a0 <end>
kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	5a3030ef          	jal	ra,ffffffffc0203df0 <memset>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200052:	00004597          	auipc	a1,0x4
ffffffffc0200056:	27658593          	addi	a1,a1,630 # ffffffffc02042c8 <etext+0x4>
ffffffffc020005a:	00004517          	auipc	a0,0x4
ffffffffc020005e:	28e50513          	addi	a0,a0,654 # ffffffffc02042e8 <etext+0x24>
ffffffffc0200062:	05c000ef          	jal	ra,ffffffffc02000be <cprintf>

    print_kerninfo();
ffffffffc0200066:	0fe000ef          	jal	ra,ffffffffc0200164 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006a:	711000ef          	jal	ra,ffffffffc0200f7a <pmm_init>

    idt_init();                 // init interrupt descriptor table
ffffffffc020006e:	4fc000ef          	jal	ra,ffffffffc020056a <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc0200072:	5d9010ef          	jal	ra,ffffffffc0201e4a <vmm_init>

    ide_init();                 // init ide devices
ffffffffc0200076:	35a000ef          	jal	ra,ffffffffc02003d0 <ide_init>
    swap_init();                // init swap
ffffffffc020007a:	404020ef          	jal	ra,ffffffffc020247e <swap_init>

    clock_init();               // init clock interrupt
ffffffffc020007e:	3aa000ef          	jal	ra,ffffffffc0200428 <clock_init>
    // intr_enable();              // enable irq interrupt



    /* do nothing */
    while (1);
ffffffffc0200082:	a001                	j	ffffffffc0200082 <kern_init+0x4c>

ffffffffc0200084 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200084:	1141                	addi	sp,sp,-16
ffffffffc0200086:	e022                	sd	s0,0(sp)
ffffffffc0200088:	e406                	sd	ra,8(sp)
ffffffffc020008a:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc020008c:	3f0000ef          	jal	ra,ffffffffc020047c <cons_putc>
    (*cnt) ++;
ffffffffc0200090:	401c                	lw	a5,0(s0)
}
ffffffffc0200092:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200094:	2785                	addiw	a5,a5,1
ffffffffc0200096:	c01c                	sw	a5,0(s0)
}
ffffffffc0200098:	6402                	ld	s0,0(sp)
ffffffffc020009a:	0141                	addi	sp,sp,16
ffffffffc020009c:	8082                	ret

ffffffffc020009e <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc020009e:	1101                	addi	sp,sp,-32
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000a0:	86ae                	mv	a3,a1
ffffffffc02000a2:	862a                	mv	a2,a0
ffffffffc02000a4:	006c                	addi	a1,sp,12
ffffffffc02000a6:	00000517          	auipc	a0,0x0
ffffffffc02000aa:	fde50513          	addi	a0,a0,-34 # ffffffffc0200084 <cputch>
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000ae:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000b0:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000b2:	5d5030ef          	jal	ra,ffffffffc0203e86 <vprintfmt>
    return cnt;
}
ffffffffc02000b6:	60e2                	ld	ra,24(sp)
ffffffffc02000b8:	4532                	lw	a0,12(sp)
ffffffffc02000ba:	6105                	addi	sp,sp,32
ffffffffc02000bc:	8082                	ret

ffffffffc02000be <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000be:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000c0:	02810313          	addi	t1,sp,40 # ffffffffc0209028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000c4:	f42e                	sd	a1,40(sp)
ffffffffc02000c6:	f832                	sd	a2,48(sp)
ffffffffc02000c8:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000ca:	862a                	mv	a2,a0
ffffffffc02000cc:	004c                	addi	a1,sp,4
ffffffffc02000ce:	00000517          	auipc	a0,0x0
ffffffffc02000d2:	fb650513          	addi	a0,a0,-74 # ffffffffc0200084 <cputch>
ffffffffc02000d6:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
ffffffffc02000d8:	ec06                	sd	ra,24(sp)
ffffffffc02000da:	e0ba                	sd	a4,64(sp)
ffffffffc02000dc:	e4be                	sd	a5,72(sp)
ffffffffc02000de:	e8c2                	sd	a6,80(sp)
ffffffffc02000e0:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000e2:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000e4:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000e6:	5a1030ef          	jal	ra,ffffffffc0203e86 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000ea:	60e2                	ld	ra,24(sp)
ffffffffc02000ec:	4512                	lw	a0,4(sp)
ffffffffc02000ee:	6125                	addi	sp,sp,96
ffffffffc02000f0:	8082                	ret

ffffffffc02000f2 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000f2:	a669                	j	ffffffffc020047c <cons_putc>

ffffffffc02000f4 <getchar>:
    return cnt;
}

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc02000f4:	1141                	addi	sp,sp,-16
ffffffffc02000f6:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc02000f8:	3b8000ef          	jal	ra,ffffffffc02004b0 <cons_getc>
ffffffffc02000fc:	dd75                	beqz	a0,ffffffffc02000f8 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc02000fe:	60a2                	ld	ra,8(sp)
ffffffffc0200100:	0141                	addi	sp,sp,16
ffffffffc0200102:	8082                	ret

ffffffffc0200104 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc0200104:	00011317          	auipc	t1,0x11
ffffffffc0200108:	33c30313          	addi	t1,t1,828 # ffffffffc0211440 <is_panic>
ffffffffc020010c:	00032303          	lw	t1,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc0200110:	715d                	addi	sp,sp,-80
ffffffffc0200112:	ec06                	sd	ra,24(sp)
ffffffffc0200114:	e822                	sd	s0,16(sp)
ffffffffc0200116:	f436                	sd	a3,40(sp)
ffffffffc0200118:	f83a                	sd	a4,48(sp)
ffffffffc020011a:	fc3e                	sd	a5,56(sp)
ffffffffc020011c:	e0c2                	sd	a6,64(sp)
ffffffffc020011e:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc0200120:	02031c63          	bnez	t1,ffffffffc0200158 <__panic+0x54>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc0200124:	4785                	li	a5,1
ffffffffc0200126:	8432                	mv	s0,a2
ffffffffc0200128:	00011717          	auipc	a4,0x11
ffffffffc020012c:	30f72c23          	sw	a5,792(a4) # ffffffffc0211440 <is_panic>

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200130:	862e                	mv	a2,a1
    va_start(ap, fmt);
ffffffffc0200132:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200134:	85aa                	mv	a1,a0
ffffffffc0200136:	00004517          	auipc	a0,0x4
ffffffffc020013a:	1ba50513          	addi	a0,a0,442 # ffffffffc02042f0 <etext+0x2c>
    va_start(ap, fmt);
ffffffffc020013e:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200140:	f7fff0ef          	jal	ra,ffffffffc02000be <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200144:	65a2                	ld	a1,8(sp)
ffffffffc0200146:	8522                	mv	a0,s0
ffffffffc0200148:	f57ff0ef          	jal	ra,ffffffffc020009e <vcprintf>
    cprintf("\n");
ffffffffc020014c:	00005517          	auipc	a0,0x5
ffffffffc0200150:	fb450513          	addi	a0,a0,-76 # ffffffffc0205100 <commands+0xcf0>
ffffffffc0200154:	f6bff0ef          	jal	ra,ffffffffc02000be <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc0200158:	39a000ef          	jal	ra,ffffffffc02004f2 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc020015c:	4501                	li	a0,0
ffffffffc020015e:	130000ef          	jal	ra,ffffffffc020028e <kmonitor>
ffffffffc0200162:	bfed                	j	ffffffffc020015c <__panic+0x58>

ffffffffc0200164 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc0200164:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200166:	00004517          	auipc	a0,0x4
ffffffffc020016a:	1da50513          	addi	a0,a0,474 # ffffffffc0204340 <etext+0x7c>
void print_kerninfo(void) {
ffffffffc020016e:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200170:	f4fff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc0200174:	00000597          	auipc	a1,0x0
ffffffffc0200178:	ec258593          	addi	a1,a1,-318 # ffffffffc0200036 <kern_init>
ffffffffc020017c:	00004517          	auipc	a0,0x4
ffffffffc0200180:	1e450513          	addi	a0,a0,484 # ffffffffc0204360 <etext+0x9c>
ffffffffc0200184:	f3bff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc0200188:	00004597          	auipc	a1,0x4
ffffffffc020018c:	13c58593          	addi	a1,a1,316 # ffffffffc02042c4 <etext>
ffffffffc0200190:	00004517          	auipc	a0,0x4
ffffffffc0200194:	1f050513          	addi	a0,a0,496 # ffffffffc0204380 <etext+0xbc>
ffffffffc0200198:	f27ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc020019c:	0000a597          	auipc	a1,0xa
ffffffffc02001a0:	ea458593          	addi	a1,a1,-348 # ffffffffc020a040 <edata>
ffffffffc02001a4:	00004517          	auipc	a0,0x4
ffffffffc02001a8:	1fc50513          	addi	a0,a0,508 # ffffffffc02043a0 <etext+0xdc>
ffffffffc02001ac:	f13ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc02001b0:	00011597          	auipc	a1,0x11
ffffffffc02001b4:	3f058593          	addi	a1,a1,1008 # ffffffffc02115a0 <end>
ffffffffc02001b8:	00004517          	auipc	a0,0x4
ffffffffc02001bc:	20850513          	addi	a0,a0,520 # ffffffffc02043c0 <etext+0xfc>
ffffffffc02001c0:	effff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc02001c4:	00011597          	auipc	a1,0x11
ffffffffc02001c8:	7db58593          	addi	a1,a1,2011 # ffffffffc021199f <end+0x3ff>
ffffffffc02001cc:	00000797          	auipc	a5,0x0
ffffffffc02001d0:	e6a78793          	addi	a5,a5,-406 # ffffffffc0200036 <kern_init>
ffffffffc02001d4:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001d8:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02001dc:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001de:	3ff5f593          	andi	a1,a1,1023
ffffffffc02001e2:	95be                	add	a1,a1,a5
ffffffffc02001e4:	85a9                	srai	a1,a1,0xa
ffffffffc02001e6:	00004517          	auipc	a0,0x4
ffffffffc02001ea:	1fa50513          	addi	a0,a0,506 # ffffffffc02043e0 <etext+0x11c>
}
ffffffffc02001ee:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001f0:	b5f9                	j	ffffffffc02000be <cprintf>

ffffffffc02001f2 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02001f2:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc02001f4:	00004617          	auipc	a2,0x4
ffffffffc02001f8:	11c60613          	addi	a2,a2,284 # ffffffffc0204310 <etext+0x4c>
ffffffffc02001fc:	04e00593          	li	a1,78
ffffffffc0200200:	00004517          	auipc	a0,0x4
ffffffffc0200204:	12850513          	addi	a0,a0,296 # ffffffffc0204328 <etext+0x64>
void print_stackframe(void) {
ffffffffc0200208:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc020020a:	efbff0ef          	jal	ra,ffffffffc0200104 <__panic>

ffffffffc020020e <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc020020e:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200210:	00004617          	auipc	a2,0x4
ffffffffc0200214:	2d860613          	addi	a2,a2,728 # ffffffffc02044e8 <commands+0xd8>
ffffffffc0200218:	00004597          	auipc	a1,0x4
ffffffffc020021c:	2f058593          	addi	a1,a1,752 # ffffffffc0204508 <commands+0xf8>
ffffffffc0200220:	00004517          	auipc	a0,0x4
ffffffffc0200224:	2f050513          	addi	a0,a0,752 # ffffffffc0204510 <commands+0x100>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200228:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc020022a:	e95ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc020022e:	00004617          	auipc	a2,0x4
ffffffffc0200232:	2f260613          	addi	a2,a2,754 # ffffffffc0204520 <commands+0x110>
ffffffffc0200236:	00004597          	auipc	a1,0x4
ffffffffc020023a:	31258593          	addi	a1,a1,786 # ffffffffc0204548 <commands+0x138>
ffffffffc020023e:	00004517          	auipc	a0,0x4
ffffffffc0200242:	2d250513          	addi	a0,a0,722 # ffffffffc0204510 <commands+0x100>
ffffffffc0200246:	e79ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc020024a:	00004617          	auipc	a2,0x4
ffffffffc020024e:	30e60613          	addi	a2,a2,782 # ffffffffc0204558 <commands+0x148>
ffffffffc0200252:	00004597          	auipc	a1,0x4
ffffffffc0200256:	32658593          	addi	a1,a1,806 # ffffffffc0204578 <commands+0x168>
ffffffffc020025a:	00004517          	auipc	a0,0x4
ffffffffc020025e:	2b650513          	addi	a0,a0,694 # ffffffffc0204510 <commands+0x100>
ffffffffc0200262:	e5dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    }
    return 0;
}
ffffffffc0200266:	60a2                	ld	ra,8(sp)
ffffffffc0200268:	4501                	li	a0,0
ffffffffc020026a:	0141                	addi	sp,sp,16
ffffffffc020026c:	8082                	ret

ffffffffc020026e <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc020026e:	1141                	addi	sp,sp,-16
ffffffffc0200270:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200272:	ef3ff0ef          	jal	ra,ffffffffc0200164 <print_kerninfo>
    return 0;
}
ffffffffc0200276:	60a2                	ld	ra,8(sp)
ffffffffc0200278:	4501                	li	a0,0
ffffffffc020027a:	0141                	addi	sp,sp,16
ffffffffc020027c:	8082                	ret

ffffffffc020027e <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc020027e:	1141                	addi	sp,sp,-16
ffffffffc0200280:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200282:	f71ff0ef          	jal	ra,ffffffffc02001f2 <print_stackframe>
    return 0;
}
ffffffffc0200286:	60a2                	ld	ra,8(sp)
ffffffffc0200288:	4501                	li	a0,0
ffffffffc020028a:	0141                	addi	sp,sp,16
ffffffffc020028c:	8082                	ret

ffffffffc020028e <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc020028e:	7115                	addi	sp,sp,-224
ffffffffc0200290:	e962                	sd	s8,144(sp)
ffffffffc0200292:	8c2a                	mv	s8,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200294:	00004517          	auipc	a0,0x4
ffffffffc0200298:	1c450513          	addi	a0,a0,452 # ffffffffc0204458 <commands+0x48>
kmonitor(struct trapframe *tf) {
ffffffffc020029c:	ed86                	sd	ra,216(sp)
ffffffffc020029e:	e9a2                	sd	s0,208(sp)
ffffffffc02002a0:	e5a6                	sd	s1,200(sp)
ffffffffc02002a2:	e1ca                	sd	s2,192(sp)
ffffffffc02002a4:	fd4e                	sd	s3,184(sp)
ffffffffc02002a6:	f952                	sd	s4,176(sp)
ffffffffc02002a8:	f556                	sd	s5,168(sp)
ffffffffc02002aa:	f15a                	sd	s6,160(sp)
ffffffffc02002ac:	ed5e                	sd	s7,152(sp)
ffffffffc02002ae:	e566                	sd	s9,136(sp)
ffffffffc02002b0:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02002b2:	e0dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc02002b6:	00004517          	auipc	a0,0x4
ffffffffc02002ba:	1ca50513          	addi	a0,a0,458 # ffffffffc0204480 <commands+0x70>
ffffffffc02002be:	e01ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    if (tf != NULL) {
ffffffffc02002c2:	000c0563          	beqz	s8,ffffffffc02002cc <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc02002c6:	8562                	mv	a0,s8
ffffffffc02002c8:	48c000ef          	jal	ra,ffffffffc0200754 <print_trapframe>
ffffffffc02002cc:	00004c97          	auipc	s9,0x4
ffffffffc02002d0:	144c8c93          	addi	s9,s9,324 # ffffffffc0204410 <commands>
        if ((buf = readline("")) != NULL) {
ffffffffc02002d4:	00005997          	auipc	s3,0x5
ffffffffc02002d8:	64c98993          	addi	s3,s3,1612 # ffffffffc0205920 <commands+0x1510>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002dc:	00004917          	auipc	s2,0x4
ffffffffc02002e0:	1cc90913          	addi	s2,s2,460 # ffffffffc02044a8 <commands+0x98>
        if (argc == MAXARGS - 1) {
ffffffffc02002e4:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002e6:	00004b17          	auipc	s6,0x4
ffffffffc02002ea:	1cab0b13          	addi	s6,s6,458 # ffffffffc02044b0 <commands+0xa0>
    if (argc == 0) {
ffffffffc02002ee:	00004a97          	auipc	s5,0x4
ffffffffc02002f2:	21aa8a93          	addi	s5,s5,538 # ffffffffc0204508 <commands+0xf8>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002f6:	4b8d                	li	s7,3
        if ((buf = readline("")) != NULL) {
ffffffffc02002f8:	854e                	mv	a0,s3
ffffffffc02002fa:	70d030ef          	jal	ra,ffffffffc0204206 <readline>
ffffffffc02002fe:	842a                	mv	s0,a0
ffffffffc0200300:	dd65                	beqz	a0,ffffffffc02002f8 <kmonitor+0x6a>
ffffffffc0200302:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc0200306:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200308:	c999                	beqz	a1,ffffffffc020031e <kmonitor+0x90>
ffffffffc020030a:	854a                	mv	a0,s2
ffffffffc020030c:	2c7030ef          	jal	ra,ffffffffc0203dd2 <strchr>
ffffffffc0200310:	c925                	beqz	a0,ffffffffc0200380 <kmonitor+0xf2>
            *buf ++ = '\0';
ffffffffc0200312:	00144583          	lbu	a1,1(s0)
ffffffffc0200316:	00040023          	sb	zero,0(s0)
ffffffffc020031a:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020031c:	f5fd                	bnez	a1,ffffffffc020030a <kmonitor+0x7c>
    if (argc == 0) {
ffffffffc020031e:	dce9                	beqz	s1,ffffffffc02002f8 <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200320:	6582                	ld	a1,0(sp)
ffffffffc0200322:	00004d17          	auipc	s10,0x4
ffffffffc0200326:	0eed0d13          	addi	s10,s10,238 # ffffffffc0204410 <commands>
    if (argc == 0) {
ffffffffc020032a:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020032c:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020032e:	0d61                	addi	s10,s10,24
ffffffffc0200330:	279030ef          	jal	ra,ffffffffc0203da8 <strcmp>
ffffffffc0200334:	c919                	beqz	a0,ffffffffc020034a <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200336:	2405                	addiw	s0,s0,1
ffffffffc0200338:	09740463          	beq	s0,s7,ffffffffc02003c0 <kmonitor+0x132>
ffffffffc020033c:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200340:	6582                	ld	a1,0(sp)
ffffffffc0200342:	0d61                	addi	s10,s10,24
ffffffffc0200344:	265030ef          	jal	ra,ffffffffc0203da8 <strcmp>
ffffffffc0200348:	f57d                	bnez	a0,ffffffffc0200336 <kmonitor+0xa8>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc020034a:	00141793          	slli	a5,s0,0x1
ffffffffc020034e:	97a2                	add	a5,a5,s0
ffffffffc0200350:	078e                	slli	a5,a5,0x3
ffffffffc0200352:	97e6                	add	a5,a5,s9
ffffffffc0200354:	6b9c                	ld	a5,16(a5)
ffffffffc0200356:	8662                	mv	a2,s8
ffffffffc0200358:	002c                	addi	a1,sp,8
ffffffffc020035a:	fff4851b          	addiw	a0,s1,-1
ffffffffc020035e:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200360:	f8055ce3          	bgez	a0,ffffffffc02002f8 <kmonitor+0x6a>
}
ffffffffc0200364:	60ee                	ld	ra,216(sp)
ffffffffc0200366:	644e                	ld	s0,208(sp)
ffffffffc0200368:	64ae                	ld	s1,200(sp)
ffffffffc020036a:	690e                	ld	s2,192(sp)
ffffffffc020036c:	79ea                	ld	s3,184(sp)
ffffffffc020036e:	7a4a                	ld	s4,176(sp)
ffffffffc0200370:	7aaa                	ld	s5,168(sp)
ffffffffc0200372:	7b0a                	ld	s6,160(sp)
ffffffffc0200374:	6bea                	ld	s7,152(sp)
ffffffffc0200376:	6c4a                	ld	s8,144(sp)
ffffffffc0200378:	6caa                	ld	s9,136(sp)
ffffffffc020037a:	6d0a                	ld	s10,128(sp)
ffffffffc020037c:	612d                	addi	sp,sp,224
ffffffffc020037e:	8082                	ret
        if (*buf == '\0') {
ffffffffc0200380:	00044783          	lbu	a5,0(s0)
ffffffffc0200384:	dfc9                	beqz	a5,ffffffffc020031e <kmonitor+0x90>
        if (argc == MAXARGS - 1) {
ffffffffc0200386:	03448863          	beq	s1,s4,ffffffffc02003b6 <kmonitor+0x128>
        argv[argc ++] = buf;
ffffffffc020038a:	00349793          	slli	a5,s1,0x3
ffffffffc020038e:	0118                	addi	a4,sp,128
ffffffffc0200390:	97ba                	add	a5,a5,a4
ffffffffc0200392:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200396:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc020039a:	2485                	addiw	s1,s1,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020039c:	e591                	bnez	a1,ffffffffc02003a8 <kmonitor+0x11a>
ffffffffc020039e:	b749                	j	ffffffffc0200320 <kmonitor+0x92>
            buf ++;
ffffffffc02003a0:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003a2:	00044583          	lbu	a1,0(s0)
ffffffffc02003a6:	ddad                	beqz	a1,ffffffffc0200320 <kmonitor+0x92>
ffffffffc02003a8:	854a                	mv	a0,s2
ffffffffc02003aa:	229030ef          	jal	ra,ffffffffc0203dd2 <strchr>
ffffffffc02003ae:	d96d                	beqz	a0,ffffffffc02003a0 <kmonitor+0x112>
ffffffffc02003b0:	00044583          	lbu	a1,0(s0)
ffffffffc02003b4:	bf91                	j	ffffffffc0200308 <kmonitor+0x7a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02003b6:	45c1                	li	a1,16
ffffffffc02003b8:	855a                	mv	a0,s6
ffffffffc02003ba:	d05ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc02003be:	b7f1                	j	ffffffffc020038a <kmonitor+0xfc>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc02003c0:	6582                	ld	a1,0(sp)
ffffffffc02003c2:	00004517          	auipc	a0,0x4
ffffffffc02003c6:	10e50513          	addi	a0,a0,270 # ffffffffc02044d0 <commands+0xc0>
ffffffffc02003ca:	cf5ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    return 0;
ffffffffc02003ce:	b72d                	j	ffffffffc02002f8 <kmonitor+0x6a>

ffffffffc02003d0 <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc02003d0:	8082                	ret

ffffffffc02003d2 <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc02003d2:	00253513          	sltiu	a0,a0,2
ffffffffc02003d6:	8082                	ret

ffffffffc02003d8 <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc02003d8:	03800513          	li	a0,56
ffffffffc02003dc:	8082                	ret

ffffffffc02003de <ide_read_secs>:

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02003de:	0000a797          	auipc	a5,0xa
ffffffffc02003e2:	c6278793          	addi	a5,a5,-926 # ffffffffc020a040 <edata>
ffffffffc02003e6:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {
ffffffffc02003ea:	1141                	addi	sp,sp,-16
ffffffffc02003ec:	8532                	mv	a0,a2
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02003ee:	95be                	add	a1,a1,a5
ffffffffc02003f0:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {
ffffffffc02003f4:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02003f6:	20d030ef          	jal	ra,ffffffffc0203e02 <memcpy>
    return 0;
}
ffffffffc02003fa:	60a2                	ld	ra,8(sp)
ffffffffc02003fc:	4501                	li	a0,0
ffffffffc02003fe:	0141                	addi	sp,sp,16
ffffffffc0200400:	8082                	ret

ffffffffc0200402 <ide_write_secs>:

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
ffffffffc0200402:	8732                	mv	a4,a2
    int iobase = secno * SECTSIZE;
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200404:	0095979b          	slliw	a5,a1,0x9
ffffffffc0200408:	0000a517          	auipc	a0,0xa
ffffffffc020040c:	c3850513          	addi	a0,a0,-968 # ffffffffc020a040 <edata>
                   size_t nsecs) {
ffffffffc0200410:	1141                	addi	sp,sp,-16
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200412:	00969613          	slli	a2,a3,0x9
ffffffffc0200416:	85ba                	mv	a1,a4
ffffffffc0200418:	953e                	add	a0,a0,a5
                   size_t nsecs) {
ffffffffc020041a:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc020041c:	1e7030ef          	jal	ra,ffffffffc0203e02 <memcpy>
    return 0;
}
ffffffffc0200420:	60a2                	ld	ra,8(sp)
ffffffffc0200422:	4501                	li	a0,0
ffffffffc0200424:	0141                	addi	sp,sp,16
ffffffffc0200426:	8082                	ret

ffffffffc0200428 <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc0200428:	67e1                	lui	a5,0x18
ffffffffc020042a:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc020042e:	00011717          	auipc	a4,0x11
ffffffffc0200432:	00f73d23          	sd	a5,26(a4) # ffffffffc0211448 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200436:	c0102573          	rdtime	a0
static inline void sbi_set_timer(uint64_t stime_value)
{
#if __riscv_xlen == 32
	SBI_CALL_2(SBI_SET_TIMER, stime_value, stime_value >> 32);
#else
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc020043a:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020043c:	953e                	add	a0,a0,a5
ffffffffc020043e:	4601                	li	a2,0
ffffffffc0200440:	4881                	li	a7,0
ffffffffc0200442:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc0200446:	02000793          	li	a5,32
ffffffffc020044a:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc020044e:	00004517          	auipc	a0,0x4
ffffffffc0200452:	13a50513          	addi	a0,a0,314 # ffffffffc0204588 <commands+0x178>
    ticks = 0;
ffffffffc0200456:	00011797          	auipc	a5,0x11
ffffffffc020045a:	0207b123          	sd	zero,34(a5) # ffffffffc0211478 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020045e:	b185                	j	ffffffffc02000be <cprintf>

ffffffffc0200460 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200460:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200464:	00011797          	auipc	a5,0x11
ffffffffc0200468:	fe478793          	addi	a5,a5,-28 # ffffffffc0211448 <timebase>
ffffffffc020046c:	639c                	ld	a5,0(a5)
ffffffffc020046e:	4581                	li	a1,0
ffffffffc0200470:	4601                	li	a2,0
ffffffffc0200472:	953e                	add	a0,a0,a5
ffffffffc0200474:	4881                	li	a7,0
ffffffffc0200476:	00000073          	ecall
ffffffffc020047a:	8082                	ret

ffffffffc020047c <cons_putc>:
#include <intr.h>
#include <mmu.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020047c:	100027f3          	csrr	a5,sstatus
ffffffffc0200480:	8b89                	andi	a5,a5,2
ffffffffc0200482:	0ff57513          	andi	a0,a0,255
ffffffffc0200486:	e799                	bnez	a5,ffffffffc0200494 <cons_putc+0x18>
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc0200488:	4581                	li	a1,0
ffffffffc020048a:	4601                	li	a2,0
ffffffffc020048c:	4885                	li	a7,1
ffffffffc020048e:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc0200492:	8082                	ret

/* cons_init - initializes the console devices */
void cons_init(void) {}

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc0200494:	1101                	addi	sp,sp,-32
ffffffffc0200496:	ec06                	sd	ra,24(sp)
ffffffffc0200498:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc020049a:	058000ef          	jal	ra,ffffffffc02004f2 <intr_disable>
ffffffffc020049e:	6522                	ld	a0,8(sp)
ffffffffc02004a0:	4581                	li	a1,0
ffffffffc02004a2:	4601                	li	a2,0
ffffffffc02004a4:	4885                	li	a7,1
ffffffffc02004a6:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc02004aa:	60e2                	ld	ra,24(sp)
ffffffffc02004ac:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02004ae:	a83d                	j	ffffffffc02004ec <intr_enable>

ffffffffc02004b0 <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02004b0:	100027f3          	csrr	a5,sstatus
ffffffffc02004b4:	8b89                	andi	a5,a5,2
ffffffffc02004b6:	eb89                	bnez	a5,ffffffffc02004c8 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc02004b8:	4501                	li	a0,0
ffffffffc02004ba:	4581                	li	a1,0
ffffffffc02004bc:	4601                	li	a2,0
ffffffffc02004be:	4889                	li	a7,2
ffffffffc02004c0:	00000073          	ecall
ffffffffc02004c4:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc02004c6:	8082                	ret
int cons_getc(void) {
ffffffffc02004c8:	1101                	addi	sp,sp,-32
ffffffffc02004ca:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc02004cc:	026000ef          	jal	ra,ffffffffc02004f2 <intr_disable>
ffffffffc02004d0:	4501                	li	a0,0
ffffffffc02004d2:	4581                	li	a1,0
ffffffffc02004d4:	4601                	li	a2,0
ffffffffc02004d6:	4889                	li	a7,2
ffffffffc02004d8:	00000073          	ecall
ffffffffc02004dc:	2501                	sext.w	a0,a0
ffffffffc02004de:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc02004e0:	00c000ef          	jal	ra,ffffffffc02004ec <intr_enable>
}
ffffffffc02004e4:	60e2                	ld	ra,24(sp)
ffffffffc02004e6:	6522                	ld	a0,8(sp)
ffffffffc02004e8:	6105                	addi	sp,sp,32
ffffffffc02004ea:	8082                	ret

ffffffffc02004ec <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc02004ec:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc02004f0:	8082                	ret

ffffffffc02004f2 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc02004f2:	100177f3          	csrrci	a5,sstatus,2
ffffffffc02004f6:	8082                	ret

ffffffffc02004f8 <pgfault_handler>:
    set_csr(sstatus, SSTATUS_SUM);
}

/* trap_in_kernel - test if trap happened in kernel */
bool trap_in_kernel(struct trapframe *tf) {
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02004f8:	10053783          	ld	a5,256(a0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int pgfault_handler(struct trapframe *tf) {
ffffffffc02004fc:	1141                	addi	sp,sp,-16
ffffffffc02004fe:	e022                	sd	s0,0(sp)
ffffffffc0200500:	e406                	sd	ra,8(sp)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200502:	1007f793          	andi	a5,a5,256
static int pgfault_handler(struct trapframe *tf) {
ffffffffc0200506:	842a                	mv	s0,a0
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc0200508:	11053583          	ld	a1,272(a0)
ffffffffc020050c:	05500613          	li	a2,85
ffffffffc0200510:	c399                	beqz	a5,ffffffffc0200516 <pgfault_handler+0x1e>
ffffffffc0200512:	04b00613          	li	a2,75
ffffffffc0200516:	11843703          	ld	a4,280(s0)
ffffffffc020051a:	47bd                	li	a5,15
ffffffffc020051c:	05700693          	li	a3,87
ffffffffc0200520:	00f70463          	beq	a4,a5,ffffffffc0200528 <pgfault_handler+0x30>
ffffffffc0200524:	05200693          	li	a3,82
ffffffffc0200528:	00004517          	auipc	a0,0x4
ffffffffc020052c:	35850513          	addi	a0,a0,856 # ffffffffc0204880 <commands+0x470>
ffffffffc0200530:	b8fff0ef          	jal	ra,ffffffffc02000be <cprintf>
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
    if (check_mm_struct != NULL) {
ffffffffc0200534:	00011797          	auipc	a5,0x11
ffffffffc0200538:	f6c78793          	addi	a5,a5,-148 # ffffffffc02114a0 <check_mm_struct>
ffffffffc020053c:	6388                	ld	a0,0(a5)
ffffffffc020053e:	c911                	beqz	a0,ffffffffc0200552 <pgfault_handler+0x5a>
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc0200540:	11043603          	ld	a2,272(s0)
ffffffffc0200544:	11843583          	ld	a1,280(s0)
    }
    panic("unhandled page fault.\n");
}
ffffffffc0200548:	6402                	ld	s0,0(sp)
ffffffffc020054a:	60a2                	ld	ra,8(sp)
ffffffffc020054c:	0141                	addi	sp,sp,16
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc020054e:	63b0106f          	j	ffffffffc0202388 <do_pgfault>
    panic("unhandled page fault.\n");
ffffffffc0200552:	00004617          	auipc	a2,0x4
ffffffffc0200556:	34e60613          	addi	a2,a2,846 # ffffffffc02048a0 <commands+0x490>
ffffffffc020055a:	07800593          	li	a1,120
ffffffffc020055e:	00004517          	auipc	a0,0x4
ffffffffc0200562:	35a50513          	addi	a0,a0,858 # ffffffffc02048b8 <commands+0x4a8>
ffffffffc0200566:	b9fff0ef          	jal	ra,ffffffffc0200104 <__panic>

ffffffffc020056a <idt_init>:
    write_csr(sscratch, 0);
ffffffffc020056a:	14005073          	csrwi	sscratch,0
    write_csr(stvec, &__alltraps);
ffffffffc020056e:	00000797          	auipc	a5,0x0
ffffffffc0200572:	48278793          	addi	a5,a5,1154 # ffffffffc02009f0 <__alltraps>
ffffffffc0200576:	10579073          	csrw	stvec,a5
    set_csr(sstatus, SSTATUS_SIE);
ffffffffc020057a:	100167f3          	csrrsi	a5,sstatus,2
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc020057e:	000407b7          	lui	a5,0x40
ffffffffc0200582:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc0200586:	8082                	ret

ffffffffc0200588 <print_regs>:
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200588:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc020058a:	1141                	addi	sp,sp,-16
ffffffffc020058c:	e022                	sd	s0,0(sp)
ffffffffc020058e:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200590:	00004517          	auipc	a0,0x4
ffffffffc0200594:	34050513          	addi	a0,a0,832 # ffffffffc02048d0 <commands+0x4c0>
void print_regs(struct pushregs *gpr) {
ffffffffc0200598:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020059a:	b25ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020059e:	640c                	ld	a1,8(s0)
ffffffffc02005a0:	00004517          	auipc	a0,0x4
ffffffffc02005a4:	34850513          	addi	a0,a0,840 # ffffffffc02048e8 <commands+0x4d8>
ffffffffc02005a8:	b17ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02005ac:	680c                	ld	a1,16(s0)
ffffffffc02005ae:	00004517          	auipc	a0,0x4
ffffffffc02005b2:	35250513          	addi	a0,a0,850 # ffffffffc0204900 <commands+0x4f0>
ffffffffc02005b6:	b09ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02005ba:	6c0c                	ld	a1,24(s0)
ffffffffc02005bc:	00004517          	auipc	a0,0x4
ffffffffc02005c0:	35c50513          	addi	a0,a0,860 # ffffffffc0204918 <commands+0x508>
ffffffffc02005c4:	afbff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02005c8:	700c                	ld	a1,32(s0)
ffffffffc02005ca:	00004517          	auipc	a0,0x4
ffffffffc02005ce:	36650513          	addi	a0,a0,870 # ffffffffc0204930 <commands+0x520>
ffffffffc02005d2:	aedff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02005d6:	740c                	ld	a1,40(s0)
ffffffffc02005d8:	00004517          	auipc	a0,0x4
ffffffffc02005dc:	37050513          	addi	a0,a0,880 # ffffffffc0204948 <commands+0x538>
ffffffffc02005e0:	adfff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02005e4:	780c                	ld	a1,48(s0)
ffffffffc02005e6:	00004517          	auipc	a0,0x4
ffffffffc02005ea:	37a50513          	addi	a0,a0,890 # ffffffffc0204960 <commands+0x550>
ffffffffc02005ee:	ad1ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02005f2:	7c0c                	ld	a1,56(s0)
ffffffffc02005f4:	00004517          	auipc	a0,0x4
ffffffffc02005f8:	38450513          	addi	a0,a0,900 # ffffffffc0204978 <commands+0x568>
ffffffffc02005fc:	ac3ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc0200600:	602c                	ld	a1,64(s0)
ffffffffc0200602:	00004517          	auipc	a0,0x4
ffffffffc0200606:	38e50513          	addi	a0,a0,910 # ffffffffc0204990 <commands+0x580>
ffffffffc020060a:	ab5ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc020060e:	642c                	ld	a1,72(s0)
ffffffffc0200610:	00004517          	auipc	a0,0x4
ffffffffc0200614:	39850513          	addi	a0,a0,920 # ffffffffc02049a8 <commands+0x598>
ffffffffc0200618:	aa7ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc020061c:	682c                	ld	a1,80(s0)
ffffffffc020061e:	00004517          	auipc	a0,0x4
ffffffffc0200622:	3a250513          	addi	a0,a0,930 # ffffffffc02049c0 <commands+0x5b0>
ffffffffc0200626:	a99ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc020062a:	6c2c                	ld	a1,88(s0)
ffffffffc020062c:	00004517          	auipc	a0,0x4
ffffffffc0200630:	3ac50513          	addi	a0,a0,940 # ffffffffc02049d8 <commands+0x5c8>
ffffffffc0200634:	a8bff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200638:	702c                	ld	a1,96(s0)
ffffffffc020063a:	00004517          	auipc	a0,0x4
ffffffffc020063e:	3b650513          	addi	a0,a0,950 # ffffffffc02049f0 <commands+0x5e0>
ffffffffc0200642:	a7dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200646:	742c                	ld	a1,104(s0)
ffffffffc0200648:	00004517          	auipc	a0,0x4
ffffffffc020064c:	3c050513          	addi	a0,a0,960 # ffffffffc0204a08 <commands+0x5f8>
ffffffffc0200650:	a6fff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200654:	782c                	ld	a1,112(s0)
ffffffffc0200656:	00004517          	auipc	a0,0x4
ffffffffc020065a:	3ca50513          	addi	a0,a0,970 # ffffffffc0204a20 <commands+0x610>
ffffffffc020065e:	a61ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200662:	7c2c                	ld	a1,120(s0)
ffffffffc0200664:	00004517          	auipc	a0,0x4
ffffffffc0200668:	3d450513          	addi	a0,a0,980 # ffffffffc0204a38 <commands+0x628>
ffffffffc020066c:	a53ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200670:	604c                	ld	a1,128(s0)
ffffffffc0200672:	00004517          	auipc	a0,0x4
ffffffffc0200676:	3de50513          	addi	a0,a0,990 # ffffffffc0204a50 <commands+0x640>
ffffffffc020067a:	a45ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020067e:	644c                	ld	a1,136(s0)
ffffffffc0200680:	00004517          	auipc	a0,0x4
ffffffffc0200684:	3e850513          	addi	a0,a0,1000 # ffffffffc0204a68 <commands+0x658>
ffffffffc0200688:	a37ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020068c:	684c                	ld	a1,144(s0)
ffffffffc020068e:	00004517          	auipc	a0,0x4
ffffffffc0200692:	3f250513          	addi	a0,a0,1010 # ffffffffc0204a80 <commands+0x670>
ffffffffc0200696:	a29ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc020069a:	6c4c                	ld	a1,152(s0)
ffffffffc020069c:	00004517          	auipc	a0,0x4
ffffffffc02006a0:	3fc50513          	addi	a0,a0,1020 # ffffffffc0204a98 <commands+0x688>
ffffffffc02006a4:	a1bff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc02006a8:	704c                	ld	a1,160(s0)
ffffffffc02006aa:	00004517          	auipc	a0,0x4
ffffffffc02006ae:	40650513          	addi	a0,a0,1030 # ffffffffc0204ab0 <commands+0x6a0>
ffffffffc02006b2:	a0dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02006b6:	744c                	ld	a1,168(s0)
ffffffffc02006b8:	00004517          	auipc	a0,0x4
ffffffffc02006bc:	41050513          	addi	a0,a0,1040 # ffffffffc0204ac8 <commands+0x6b8>
ffffffffc02006c0:	9ffff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02006c4:	784c                	ld	a1,176(s0)
ffffffffc02006c6:	00004517          	auipc	a0,0x4
ffffffffc02006ca:	41a50513          	addi	a0,a0,1050 # ffffffffc0204ae0 <commands+0x6d0>
ffffffffc02006ce:	9f1ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02006d2:	7c4c                	ld	a1,184(s0)
ffffffffc02006d4:	00004517          	auipc	a0,0x4
ffffffffc02006d8:	42450513          	addi	a0,a0,1060 # ffffffffc0204af8 <commands+0x6e8>
ffffffffc02006dc:	9e3ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02006e0:	606c                	ld	a1,192(s0)
ffffffffc02006e2:	00004517          	auipc	a0,0x4
ffffffffc02006e6:	42e50513          	addi	a0,a0,1070 # ffffffffc0204b10 <commands+0x700>
ffffffffc02006ea:	9d5ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02006ee:	646c                	ld	a1,200(s0)
ffffffffc02006f0:	00004517          	auipc	a0,0x4
ffffffffc02006f4:	43850513          	addi	a0,a0,1080 # ffffffffc0204b28 <commands+0x718>
ffffffffc02006f8:	9c7ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02006fc:	686c                	ld	a1,208(s0)
ffffffffc02006fe:	00004517          	auipc	a0,0x4
ffffffffc0200702:	44250513          	addi	a0,a0,1090 # ffffffffc0204b40 <commands+0x730>
ffffffffc0200706:	9b9ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc020070a:	6c6c                	ld	a1,216(s0)
ffffffffc020070c:	00004517          	auipc	a0,0x4
ffffffffc0200710:	44c50513          	addi	a0,a0,1100 # ffffffffc0204b58 <commands+0x748>
ffffffffc0200714:	9abff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200718:	706c                	ld	a1,224(s0)
ffffffffc020071a:	00004517          	auipc	a0,0x4
ffffffffc020071e:	45650513          	addi	a0,a0,1110 # ffffffffc0204b70 <commands+0x760>
ffffffffc0200722:	99dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200726:	746c                	ld	a1,232(s0)
ffffffffc0200728:	00004517          	auipc	a0,0x4
ffffffffc020072c:	46050513          	addi	a0,a0,1120 # ffffffffc0204b88 <commands+0x778>
ffffffffc0200730:	98fff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200734:	786c                	ld	a1,240(s0)
ffffffffc0200736:	00004517          	auipc	a0,0x4
ffffffffc020073a:	46a50513          	addi	a0,a0,1130 # ffffffffc0204ba0 <commands+0x790>
ffffffffc020073e:	981ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200742:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200744:	6402                	ld	s0,0(sp)
ffffffffc0200746:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200748:	00004517          	auipc	a0,0x4
ffffffffc020074c:	47050513          	addi	a0,a0,1136 # ffffffffc0204bb8 <commands+0x7a8>
}
ffffffffc0200750:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200752:	b2b5                	j	ffffffffc02000be <cprintf>

ffffffffc0200754 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc0200754:	1141                	addi	sp,sp,-16
ffffffffc0200756:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200758:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc020075a:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc020075c:	00004517          	auipc	a0,0x4
ffffffffc0200760:	47450513          	addi	a0,a0,1140 # ffffffffc0204bd0 <commands+0x7c0>
void print_trapframe(struct trapframe *tf) {
ffffffffc0200764:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200766:	959ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    print_regs(&tf->gpr);
ffffffffc020076a:	8522                	mv	a0,s0
ffffffffc020076c:	e1dff0ef          	jal	ra,ffffffffc0200588 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200770:	10043583          	ld	a1,256(s0)
ffffffffc0200774:	00004517          	auipc	a0,0x4
ffffffffc0200778:	47450513          	addi	a0,a0,1140 # ffffffffc0204be8 <commands+0x7d8>
ffffffffc020077c:	943ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200780:	10843583          	ld	a1,264(s0)
ffffffffc0200784:	00004517          	auipc	a0,0x4
ffffffffc0200788:	47c50513          	addi	a0,a0,1148 # ffffffffc0204c00 <commands+0x7f0>
ffffffffc020078c:	933ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc0200790:	11043583          	ld	a1,272(s0)
ffffffffc0200794:	00004517          	auipc	a0,0x4
ffffffffc0200798:	48450513          	addi	a0,a0,1156 # ffffffffc0204c18 <commands+0x808>
ffffffffc020079c:	923ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007a0:	11843583          	ld	a1,280(s0)
}
ffffffffc02007a4:	6402                	ld	s0,0(sp)
ffffffffc02007a6:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007a8:	00004517          	auipc	a0,0x4
ffffffffc02007ac:	48850513          	addi	a0,a0,1160 # ffffffffc0204c30 <commands+0x820>
}
ffffffffc02007b0:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007b2:	90dff06f          	j	ffffffffc02000be <cprintf>

ffffffffc02007b6 <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02007b6:	11853783          	ld	a5,280(a0)
    switch (cause) {
ffffffffc02007ba:	472d                	li	a4,11
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02007bc:	0786                	slli	a5,a5,0x1
ffffffffc02007be:	8385                	srli	a5,a5,0x1
    switch (cause) {
ffffffffc02007c0:	06f76f63          	bltu	a4,a5,ffffffffc020083e <interrupt_handler+0x88>
ffffffffc02007c4:	00004717          	auipc	a4,0x4
ffffffffc02007c8:	de070713          	addi	a4,a4,-544 # ffffffffc02045a4 <commands+0x194>
ffffffffc02007cc:	078a                	slli	a5,a5,0x2
ffffffffc02007ce:	97ba                	add	a5,a5,a4
ffffffffc02007d0:	439c                	lw	a5,0(a5)
ffffffffc02007d2:	97ba                	add	a5,a5,a4
ffffffffc02007d4:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02007d6:	00004517          	auipc	a0,0x4
ffffffffc02007da:	05a50513          	addi	a0,a0,90 # ffffffffc0204830 <commands+0x420>
ffffffffc02007de:	8e1ff06f          	j	ffffffffc02000be <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02007e2:	00004517          	auipc	a0,0x4
ffffffffc02007e6:	02e50513          	addi	a0,a0,46 # ffffffffc0204810 <commands+0x400>
ffffffffc02007ea:	8d5ff06f          	j	ffffffffc02000be <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02007ee:	00004517          	auipc	a0,0x4
ffffffffc02007f2:	fe250513          	addi	a0,a0,-30 # ffffffffc02047d0 <commands+0x3c0>
ffffffffc02007f6:	8c9ff06f          	j	ffffffffc02000be <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02007fa:	00004517          	auipc	a0,0x4
ffffffffc02007fe:	ff650513          	addi	a0,a0,-10 # ffffffffc02047f0 <commands+0x3e0>
ffffffffc0200802:	8bdff06f          	j	ffffffffc02000be <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
ffffffffc0200806:	00004517          	auipc	a0,0x4
ffffffffc020080a:	05a50513          	addi	a0,a0,90 # ffffffffc0204860 <commands+0x450>
ffffffffc020080e:	8b1ff06f          	j	ffffffffc02000be <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc0200812:	1141                	addi	sp,sp,-16
ffffffffc0200814:	e406                	sd	ra,8(sp)
            clock_set_next_event();
ffffffffc0200816:	c4bff0ef          	jal	ra,ffffffffc0200460 <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc020081a:	00011797          	auipc	a5,0x11
ffffffffc020081e:	c5e78793          	addi	a5,a5,-930 # ffffffffc0211478 <ticks>
ffffffffc0200822:	639c                	ld	a5,0(a5)
ffffffffc0200824:	06400713          	li	a4,100
ffffffffc0200828:	0785                	addi	a5,a5,1
ffffffffc020082a:	02e7f733          	remu	a4,a5,a4
ffffffffc020082e:	00011697          	auipc	a3,0x11
ffffffffc0200832:	c4f6b523          	sd	a5,-950(a3) # ffffffffc0211478 <ticks>
ffffffffc0200836:	c709                	beqz	a4,ffffffffc0200840 <interrupt_handler+0x8a>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200838:	60a2                	ld	ra,8(sp)
ffffffffc020083a:	0141                	addi	sp,sp,16
ffffffffc020083c:	8082                	ret
            print_trapframe(tf);
ffffffffc020083e:	bf19                	j	ffffffffc0200754 <print_trapframe>
}
ffffffffc0200840:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200842:	06400593          	li	a1,100
ffffffffc0200846:	00004517          	auipc	a0,0x4
ffffffffc020084a:	00a50513          	addi	a0,a0,10 # ffffffffc0204850 <commands+0x440>
}
ffffffffc020084e:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200850:	86fff06f          	j	ffffffffc02000be <cprintf>

ffffffffc0200854 <exception_handler>:


void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc0200854:	11853783          	ld	a5,280(a0)
ffffffffc0200858:	473d                	li	a4,15
ffffffffc020085a:	16f76463          	bltu	a4,a5,ffffffffc02009c2 <exception_handler+0x16e>
ffffffffc020085e:	00004717          	auipc	a4,0x4
ffffffffc0200862:	d7670713          	addi	a4,a4,-650 # ffffffffc02045d4 <commands+0x1c4>
ffffffffc0200866:	078a                	slli	a5,a5,0x2
ffffffffc0200868:	97ba                	add	a5,a5,a4
ffffffffc020086a:	439c                	lw	a5,0(a5)
void exception_handler(struct trapframe *tf) {
ffffffffc020086c:	1101                	addi	sp,sp,-32
ffffffffc020086e:	e822                	sd	s0,16(sp)
ffffffffc0200870:	ec06                	sd	ra,24(sp)
ffffffffc0200872:	e426                	sd	s1,8(sp)
    switch (tf->cause) {
ffffffffc0200874:	97ba                	add	a5,a5,a4
ffffffffc0200876:	842a                	mv	s0,a0
ffffffffc0200878:	8782                	jr	a5
                print_trapframe(tf);
                panic("handle pgfault failed. %e\n", ret);
            }
            break;
        case CAUSE_STORE_PAGE_FAULT:
            cprintf("Store/AMO page fault\n");
ffffffffc020087a:	00004517          	auipc	a0,0x4
ffffffffc020087e:	f3e50513          	addi	a0,a0,-194 # ffffffffc02047b8 <commands+0x3a8>
ffffffffc0200882:	83dff0ef          	jal	ra,ffffffffc02000be <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200886:	8522                	mv	a0,s0
ffffffffc0200888:	c71ff0ef          	jal	ra,ffffffffc02004f8 <pgfault_handler>
ffffffffc020088c:	84aa                	mv	s1,a0
ffffffffc020088e:	12051b63          	bnez	a0,ffffffffc02009c4 <exception_handler+0x170>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200892:	60e2                	ld	ra,24(sp)
ffffffffc0200894:	6442                	ld	s0,16(sp)
ffffffffc0200896:	64a2                	ld	s1,8(sp)
ffffffffc0200898:	6105                	addi	sp,sp,32
ffffffffc020089a:	8082                	ret
            cprintf("Instruction address misaligned\n");
ffffffffc020089c:	00004517          	auipc	a0,0x4
ffffffffc02008a0:	d7c50513          	addi	a0,a0,-644 # ffffffffc0204618 <commands+0x208>
}
ffffffffc02008a4:	6442                	ld	s0,16(sp)
ffffffffc02008a6:	60e2                	ld	ra,24(sp)
ffffffffc02008a8:	64a2                	ld	s1,8(sp)
ffffffffc02008aa:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc02008ac:	813ff06f          	j	ffffffffc02000be <cprintf>
ffffffffc02008b0:	00004517          	auipc	a0,0x4
ffffffffc02008b4:	d8850513          	addi	a0,a0,-632 # ffffffffc0204638 <commands+0x228>
ffffffffc02008b8:	b7f5                	j	ffffffffc02008a4 <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc02008ba:	00004517          	auipc	a0,0x4
ffffffffc02008be:	d9e50513          	addi	a0,a0,-610 # ffffffffc0204658 <commands+0x248>
ffffffffc02008c2:	b7cd                	j	ffffffffc02008a4 <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc02008c4:	00004517          	auipc	a0,0x4
ffffffffc02008c8:	dac50513          	addi	a0,a0,-596 # ffffffffc0204670 <commands+0x260>
ffffffffc02008cc:	bfe1                	j	ffffffffc02008a4 <exception_handler+0x50>
            cprintf("Load address misaligned\n");
ffffffffc02008ce:	00004517          	auipc	a0,0x4
ffffffffc02008d2:	db250513          	addi	a0,a0,-590 # ffffffffc0204680 <commands+0x270>
ffffffffc02008d6:	b7f9                	j	ffffffffc02008a4 <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc02008d8:	00004517          	auipc	a0,0x4
ffffffffc02008dc:	dc850513          	addi	a0,a0,-568 # ffffffffc02046a0 <commands+0x290>
ffffffffc02008e0:	fdeff0ef          	jal	ra,ffffffffc02000be <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02008e4:	8522                	mv	a0,s0
ffffffffc02008e6:	c13ff0ef          	jal	ra,ffffffffc02004f8 <pgfault_handler>
ffffffffc02008ea:	84aa                	mv	s1,a0
ffffffffc02008ec:	d15d                	beqz	a0,ffffffffc0200892 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc02008ee:	8522                	mv	a0,s0
ffffffffc02008f0:	e65ff0ef          	jal	ra,ffffffffc0200754 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02008f4:	86a6                	mv	a3,s1
ffffffffc02008f6:	00004617          	auipc	a2,0x4
ffffffffc02008fa:	dc260613          	addi	a2,a2,-574 # ffffffffc02046b8 <commands+0x2a8>
ffffffffc02008fe:	0ca00593          	li	a1,202
ffffffffc0200902:	00004517          	auipc	a0,0x4
ffffffffc0200906:	fb650513          	addi	a0,a0,-74 # ffffffffc02048b8 <commands+0x4a8>
ffffffffc020090a:	ffaff0ef          	jal	ra,ffffffffc0200104 <__panic>
            cprintf("AMO address misaligned\n");
ffffffffc020090e:	00004517          	auipc	a0,0x4
ffffffffc0200912:	dca50513          	addi	a0,a0,-566 # ffffffffc02046d8 <commands+0x2c8>
ffffffffc0200916:	b779                	j	ffffffffc02008a4 <exception_handler+0x50>
            cprintf("Store/AMO access fault\n");
ffffffffc0200918:	00004517          	auipc	a0,0x4
ffffffffc020091c:	dd850513          	addi	a0,a0,-552 # ffffffffc02046f0 <commands+0x2e0>
ffffffffc0200920:	f9eff0ef          	jal	ra,ffffffffc02000be <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200924:	8522                	mv	a0,s0
ffffffffc0200926:	bd3ff0ef          	jal	ra,ffffffffc02004f8 <pgfault_handler>
ffffffffc020092a:	84aa                	mv	s1,a0
ffffffffc020092c:	d13d                	beqz	a0,ffffffffc0200892 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc020092e:	8522                	mv	a0,s0
ffffffffc0200930:	e25ff0ef          	jal	ra,ffffffffc0200754 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200934:	86a6                	mv	a3,s1
ffffffffc0200936:	00004617          	auipc	a2,0x4
ffffffffc020093a:	d8260613          	addi	a2,a2,-638 # ffffffffc02046b8 <commands+0x2a8>
ffffffffc020093e:	0d400593          	li	a1,212
ffffffffc0200942:	00004517          	auipc	a0,0x4
ffffffffc0200946:	f7650513          	addi	a0,a0,-138 # ffffffffc02048b8 <commands+0x4a8>
ffffffffc020094a:	fbaff0ef          	jal	ra,ffffffffc0200104 <__panic>
            cprintf("Environment call from U-mode\n");
ffffffffc020094e:	00004517          	auipc	a0,0x4
ffffffffc0200952:	dba50513          	addi	a0,a0,-582 # ffffffffc0204708 <commands+0x2f8>
ffffffffc0200956:	b7b9                	j	ffffffffc02008a4 <exception_handler+0x50>
            cprintf("Environment call from S-mode\n");
ffffffffc0200958:	00004517          	auipc	a0,0x4
ffffffffc020095c:	dd050513          	addi	a0,a0,-560 # ffffffffc0204728 <commands+0x318>
ffffffffc0200960:	b791                	j	ffffffffc02008a4 <exception_handler+0x50>
            cprintf("Environment call from H-mode\n");
ffffffffc0200962:	00004517          	auipc	a0,0x4
ffffffffc0200966:	de650513          	addi	a0,a0,-538 # ffffffffc0204748 <commands+0x338>
ffffffffc020096a:	bf2d                	j	ffffffffc02008a4 <exception_handler+0x50>
            cprintf("Environment call from M-mode\n");
ffffffffc020096c:	00004517          	auipc	a0,0x4
ffffffffc0200970:	dfc50513          	addi	a0,a0,-516 # ffffffffc0204768 <commands+0x358>
ffffffffc0200974:	bf05                	j	ffffffffc02008a4 <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200976:	00004517          	auipc	a0,0x4
ffffffffc020097a:	e1250513          	addi	a0,a0,-494 # ffffffffc0204788 <commands+0x378>
ffffffffc020097e:	b71d                	j	ffffffffc02008a4 <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200980:	00004517          	auipc	a0,0x4
ffffffffc0200984:	e2050513          	addi	a0,a0,-480 # ffffffffc02047a0 <commands+0x390>
ffffffffc0200988:	f36ff0ef          	jal	ra,ffffffffc02000be <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc020098c:	8522                	mv	a0,s0
ffffffffc020098e:	b6bff0ef          	jal	ra,ffffffffc02004f8 <pgfault_handler>
ffffffffc0200992:	84aa                	mv	s1,a0
ffffffffc0200994:	ee050fe3          	beqz	a0,ffffffffc0200892 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc0200998:	8522                	mv	a0,s0
ffffffffc020099a:	dbbff0ef          	jal	ra,ffffffffc0200754 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc020099e:	86a6                	mv	a3,s1
ffffffffc02009a0:	00004617          	auipc	a2,0x4
ffffffffc02009a4:	d1860613          	addi	a2,a2,-744 # ffffffffc02046b8 <commands+0x2a8>
ffffffffc02009a8:	0ea00593          	li	a1,234
ffffffffc02009ac:	00004517          	auipc	a0,0x4
ffffffffc02009b0:	f0c50513          	addi	a0,a0,-244 # ffffffffc02048b8 <commands+0x4a8>
ffffffffc02009b4:	f50ff0ef          	jal	ra,ffffffffc0200104 <__panic>
}
ffffffffc02009b8:	6442                	ld	s0,16(sp)
ffffffffc02009ba:	60e2                	ld	ra,24(sp)
ffffffffc02009bc:	64a2                	ld	s1,8(sp)
ffffffffc02009be:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc02009c0:	bb51                	j	ffffffffc0200754 <print_trapframe>
ffffffffc02009c2:	bb49                	j	ffffffffc0200754 <print_trapframe>
                print_trapframe(tf);
ffffffffc02009c4:	8522                	mv	a0,s0
ffffffffc02009c6:	d8fff0ef          	jal	ra,ffffffffc0200754 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02009ca:	86a6                	mv	a3,s1
ffffffffc02009cc:	00004617          	auipc	a2,0x4
ffffffffc02009d0:	cec60613          	addi	a2,a2,-788 # ffffffffc02046b8 <commands+0x2a8>
ffffffffc02009d4:	0f100593          	li	a1,241
ffffffffc02009d8:	00004517          	auipc	a0,0x4
ffffffffc02009dc:	ee050513          	addi	a0,a0,-288 # ffffffffc02048b8 <commands+0x4a8>
ffffffffc02009e0:	f24ff0ef          	jal	ra,ffffffffc0200104 <__panic>

ffffffffc02009e4 <trap>:
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    if ((intptr_t)tf->cause < 0) {
ffffffffc02009e4:	11853783          	ld	a5,280(a0)
ffffffffc02009e8:	0007c363          	bltz	a5,ffffffffc02009ee <trap+0xa>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
ffffffffc02009ec:	b5a5                	j	ffffffffc0200854 <exception_handler>
        interrupt_handler(tf);
ffffffffc02009ee:	b3e1                	j	ffffffffc02007b6 <interrupt_handler>

ffffffffc02009f0 <__alltraps>:
    .endm

    .align 4
    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc02009f0:	14011073          	csrw	sscratch,sp
ffffffffc02009f4:	712d                	addi	sp,sp,-288
ffffffffc02009f6:	e406                	sd	ra,8(sp)
ffffffffc02009f8:	ec0e                	sd	gp,24(sp)
ffffffffc02009fa:	f012                	sd	tp,32(sp)
ffffffffc02009fc:	f416                	sd	t0,40(sp)
ffffffffc02009fe:	f81a                	sd	t1,48(sp)
ffffffffc0200a00:	fc1e                	sd	t2,56(sp)
ffffffffc0200a02:	e0a2                	sd	s0,64(sp)
ffffffffc0200a04:	e4a6                	sd	s1,72(sp)
ffffffffc0200a06:	e8aa                	sd	a0,80(sp)
ffffffffc0200a08:	ecae                	sd	a1,88(sp)
ffffffffc0200a0a:	f0b2                	sd	a2,96(sp)
ffffffffc0200a0c:	f4b6                	sd	a3,104(sp)
ffffffffc0200a0e:	f8ba                	sd	a4,112(sp)
ffffffffc0200a10:	fcbe                	sd	a5,120(sp)
ffffffffc0200a12:	e142                	sd	a6,128(sp)
ffffffffc0200a14:	e546                	sd	a7,136(sp)
ffffffffc0200a16:	e94a                	sd	s2,144(sp)
ffffffffc0200a18:	ed4e                	sd	s3,152(sp)
ffffffffc0200a1a:	f152                	sd	s4,160(sp)
ffffffffc0200a1c:	f556                	sd	s5,168(sp)
ffffffffc0200a1e:	f95a                	sd	s6,176(sp)
ffffffffc0200a20:	fd5e                	sd	s7,184(sp)
ffffffffc0200a22:	e1e2                	sd	s8,192(sp)
ffffffffc0200a24:	e5e6                	sd	s9,200(sp)
ffffffffc0200a26:	e9ea                	sd	s10,208(sp)
ffffffffc0200a28:	edee                	sd	s11,216(sp)
ffffffffc0200a2a:	f1f2                	sd	t3,224(sp)
ffffffffc0200a2c:	f5f6                	sd	t4,232(sp)
ffffffffc0200a2e:	f9fa                	sd	t5,240(sp)
ffffffffc0200a30:	fdfe                	sd	t6,248(sp)
ffffffffc0200a32:	14002473          	csrr	s0,sscratch
ffffffffc0200a36:	100024f3          	csrr	s1,sstatus
ffffffffc0200a3a:	14102973          	csrr	s2,sepc
ffffffffc0200a3e:	143029f3          	csrr	s3,stval
ffffffffc0200a42:	14202a73          	csrr	s4,scause
ffffffffc0200a46:	e822                	sd	s0,16(sp)
ffffffffc0200a48:	e226                	sd	s1,256(sp)
ffffffffc0200a4a:	e64a                	sd	s2,264(sp)
ffffffffc0200a4c:	ea4e                	sd	s3,272(sp)
ffffffffc0200a4e:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200a50:	850a                	mv	a0,sp
    jal trap
ffffffffc0200a52:	f93ff0ef          	jal	ra,ffffffffc02009e4 <trap>

ffffffffc0200a56 <__trapret>:
    // sp should be the same as before "jal trap"
    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200a56:	6492                	ld	s1,256(sp)
ffffffffc0200a58:	6932                	ld	s2,264(sp)
ffffffffc0200a5a:	10049073          	csrw	sstatus,s1
ffffffffc0200a5e:	14191073          	csrw	sepc,s2
ffffffffc0200a62:	60a2                	ld	ra,8(sp)
ffffffffc0200a64:	61e2                	ld	gp,24(sp)
ffffffffc0200a66:	7202                	ld	tp,32(sp)
ffffffffc0200a68:	72a2                	ld	t0,40(sp)
ffffffffc0200a6a:	7342                	ld	t1,48(sp)
ffffffffc0200a6c:	73e2                	ld	t2,56(sp)
ffffffffc0200a6e:	6406                	ld	s0,64(sp)
ffffffffc0200a70:	64a6                	ld	s1,72(sp)
ffffffffc0200a72:	6546                	ld	a0,80(sp)
ffffffffc0200a74:	65e6                	ld	a1,88(sp)
ffffffffc0200a76:	7606                	ld	a2,96(sp)
ffffffffc0200a78:	76a6                	ld	a3,104(sp)
ffffffffc0200a7a:	7746                	ld	a4,112(sp)
ffffffffc0200a7c:	77e6                	ld	a5,120(sp)
ffffffffc0200a7e:	680a                	ld	a6,128(sp)
ffffffffc0200a80:	68aa                	ld	a7,136(sp)
ffffffffc0200a82:	694a                	ld	s2,144(sp)
ffffffffc0200a84:	69ea                	ld	s3,152(sp)
ffffffffc0200a86:	7a0a                	ld	s4,160(sp)
ffffffffc0200a88:	7aaa                	ld	s5,168(sp)
ffffffffc0200a8a:	7b4a                	ld	s6,176(sp)
ffffffffc0200a8c:	7bea                	ld	s7,184(sp)
ffffffffc0200a8e:	6c0e                	ld	s8,192(sp)
ffffffffc0200a90:	6cae                	ld	s9,200(sp)
ffffffffc0200a92:	6d4e                	ld	s10,208(sp)
ffffffffc0200a94:	6dee                	ld	s11,216(sp)
ffffffffc0200a96:	7e0e                	ld	t3,224(sp)
ffffffffc0200a98:	7eae                	ld	t4,232(sp)
ffffffffc0200a9a:	7f4e                	ld	t5,240(sp)
ffffffffc0200a9c:	7fee                	ld	t6,248(sp)
ffffffffc0200a9e:	6142                	ld	sp,16(sp)
    // go back from supervisor call
    sret
ffffffffc0200aa0:	10200073          	sret
	...

ffffffffc0200ab0 <pa2page.part.4>:

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
}

static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc0200ab0:	1141                	addi	sp,sp,-16
    if (PPN(pa) >= npage) {
        panic("pa2page called with invalid pa");
ffffffffc0200ab2:	00004617          	auipc	a2,0x4
ffffffffc0200ab6:	21660613          	addi	a2,a2,534 # ffffffffc0204cc8 <commands+0x8b8>
ffffffffc0200aba:	06500593          	li	a1,101
ffffffffc0200abe:	00004517          	auipc	a0,0x4
ffffffffc0200ac2:	22a50513          	addi	a0,a0,554 # ffffffffc0204ce8 <commands+0x8d8>
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc0200ac6:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0200ac8:	e3cff0ef          	jal	ra,ffffffffc0200104 <__panic>

ffffffffc0200acc <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc0200acc:	715d                	addi	sp,sp,-80
ffffffffc0200ace:	e0a2                	sd	s0,64(sp)
ffffffffc0200ad0:	fc26                	sd	s1,56(sp)
ffffffffc0200ad2:	f84a                	sd	s2,48(sp)
ffffffffc0200ad4:	f44e                	sd	s3,40(sp)
ffffffffc0200ad6:	f052                	sd	s4,32(sp)
ffffffffc0200ad8:	ec56                	sd	s5,24(sp)
ffffffffc0200ada:	e486                	sd	ra,72(sp)
ffffffffc0200adc:	842a                	mv	s0,a0
ffffffffc0200ade:	00011497          	auipc	s1,0x11
ffffffffc0200ae2:	9a248493          	addi	s1,s1,-1630 # ffffffffc0211480 <pmm_manager>
    while (1) {
        local_intr_save(intr_flag);
        { page = pmm_manager->alloc_pages(n); }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0200ae6:	4985                	li	s3,1
ffffffffc0200ae8:	00011a17          	auipc	s4,0x11
ffffffffc0200aec:	988a0a13          	addi	s4,s4,-1656 # ffffffffc0211470 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0200af0:	0005091b          	sext.w	s2,a0
ffffffffc0200af4:	00011a97          	auipc	s5,0x11
ffffffffc0200af8:	9aca8a93          	addi	s5,s5,-1620 # ffffffffc02114a0 <check_mm_struct>
ffffffffc0200afc:	a00d                	j	ffffffffc0200b1e <alloc_pages+0x52>
        { page = pmm_manager->alloc_pages(n); }
ffffffffc0200afe:	609c                	ld	a5,0(s1)
ffffffffc0200b00:	6f9c                	ld	a5,24(a5)
ffffffffc0200b02:	9782                	jalr	a5
        swap_out(check_mm_struct, n, 0);
ffffffffc0200b04:	4601                	li	a2,0
ffffffffc0200b06:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0200b08:	ed0d                	bnez	a0,ffffffffc0200b42 <alloc_pages+0x76>
ffffffffc0200b0a:	0289ec63          	bltu	s3,s0,ffffffffc0200b42 <alloc_pages+0x76>
ffffffffc0200b0e:	000a2783          	lw	a5,0(s4)
ffffffffc0200b12:	2781                	sext.w	a5,a5
ffffffffc0200b14:	c79d                	beqz	a5,ffffffffc0200b42 <alloc_pages+0x76>
        swap_out(check_mm_struct, n, 0);
ffffffffc0200b16:	000ab503          	ld	a0,0(s5)
ffffffffc0200b1a:	024020ef          	jal	ra,ffffffffc0202b3e <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200b1e:	100027f3          	csrr	a5,sstatus
ffffffffc0200b22:	8b89                	andi	a5,a5,2
        { page = pmm_manager->alloc_pages(n); }
ffffffffc0200b24:	8522                	mv	a0,s0
ffffffffc0200b26:	dfe1                	beqz	a5,ffffffffc0200afe <alloc_pages+0x32>
        intr_disable();
ffffffffc0200b28:	9cbff0ef          	jal	ra,ffffffffc02004f2 <intr_disable>
ffffffffc0200b2c:	609c                	ld	a5,0(s1)
ffffffffc0200b2e:	8522                	mv	a0,s0
ffffffffc0200b30:	6f9c                	ld	a5,24(a5)
ffffffffc0200b32:	9782                	jalr	a5
ffffffffc0200b34:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0200b36:	9b7ff0ef          	jal	ra,ffffffffc02004ec <intr_enable>
ffffffffc0200b3a:	6522                	ld	a0,8(sp)
        swap_out(check_mm_struct, n, 0);
ffffffffc0200b3c:	4601                	li	a2,0
ffffffffc0200b3e:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0200b40:	d569                	beqz	a0,ffffffffc0200b0a <alloc_pages+0x3e>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0200b42:	60a6                	ld	ra,72(sp)
ffffffffc0200b44:	6406                	ld	s0,64(sp)
ffffffffc0200b46:	74e2                	ld	s1,56(sp)
ffffffffc0200b48:	7942                	ld	s2,48(sp)
ffffffffc0200b4a:	79a2                	ld	s3,40(sp)
ffffffffc0200b4c:	7a02                	ld	s4,32(sp)
ffffffffc0200b4e:	6ae2                	ld	s5,24(sp)
ffffffffc0200b50:	6161                	addi	sp,sp,80
ffffffffc0200b52:	8082                	ret

ffffffffc0200b54 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200b54:	100027f3          	csrr	a5,sstatus
ffffffffc0200b58:	8b89                	andi	a5,a5,2
ffffffffc0200b5a:	eb89                	bnez	a5,ffffffffc0200b6c <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;

    local_intr_save(intr_flag);
    { pmm_manager->free_pages(base, n); }
ffffffffc0200b5c:	00011797          	auipc	a5,0x11
ffffffffc0200b60:	92478793          	addi	a5,a5,-1756 # ffffffffc0211480 <pmm_manager>
ffffffffc0200b64:	639c                	ld	a5,0(a5)
ffffffffc0200b66:	0207b303          	ld	t1,32(a5)
ffffffffc0200b6a:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc0200b6c:	1101                	addi	sp,sp,-32
ffffffffc0200b6e:	ec06                	sd	ra,24(sp)
ffffffffc0200b70:	e822                	sd	s0,16(sp)
ffffffffc0200b72:	e426                	sd	s1,8(sp)
ffffffffc0200b74:	842a                	mv	s0,a0
ffffffffc0200b76:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0200b78:	97bff0ef          	jal	ra,ffffffffc02004f2 <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc0200b7c:	00011797          	auipc	a5,0x11
ffffffffc0200b80:	90478793          	addi	a5,a5,-1788 # ffffffffc0211480 <pmm_manager>
ffffffffc0200b84:	639c                	ld	a5,0(a5)
ffffffffc0200b86:	85a6                	mv	a1,s1
ffffffffc0200b88:	8522                	mv	a0,s0
ffffffffc0200b8a:	739c                	ld	a5,32(a5)
ffffffffc0200b8c:	9782                	jalr	a5
    local_intr_restore(intr_flag);
}
ffffffffc0200b8e:	6442                	ld	s0,16(sp)
ffffffffc0200b90:	60e2                	ld	ra,24(sp)
ffffffffc0200b92:	64a2                	ld	s1,8(sp)
ffffffffc0200b94:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200b96:	957ff06f          	j	ffffffffc02004ec <intr_enable>

ffffffffc0200b9a <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200b9a:	100027f3          	csrr	a5,sstatus
ffffffffc0200b9e:	8b89                	andi	a5,a5,2
ffffffffc0200ba0:	eb89                	bnez	a5,ffffffffc0200bb2 <nr_free_pages+0x18>
// of current free memory
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0200ba2:	00011797          	auipc	a5,0x11
ffffffffc0200ba6:	8de78793          	addi	a5,a5,-1826 # ffffffffc0211480 <pmm_manager>
ffffffffc0200baa:	639c                	ld	a5,0(a5)
ffffffffc0200bac:	0287b303          	ld	t1,40(a5)
ffffffffc0200bb0:	8302                	jr	t1
size_t nr_free_pages(void) {
ffffffffc0200bb2:	1141                	addi	sp,sp,-16
ffffffffc0200bb4:	e406                	sd	ra,8(sp)
ffffffffc0200bb6:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0200bb8:	93bff0ef          	jal	ra,ffffffffc02004f2 <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0200bbc:	00011797          	auipc	a5,0x11
ffffffffc0200bc0:	8c478793          	addi	a5,a5,-1852 # ffffffffc0211480 <pmm_manager>
ffffffffc0200bc4:	639c                	ld	a5,0(a5)
ffffffffc0200bc6:	779c                	ld	a5,40(a5)
ffffffffc0200bc8:	9782                	jalr	a5
ffffffffc0200bca:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0200bcc:	921ff0ef          	jal	ra,ffffffffc02004ec <intr_enable>
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0200bd0:	8522                	mv	a0,s0
ffffffffc0200bd2:	60a2                	ld	ra,8(sp)
ffffffffc0200bd4:	6402                	ld	s0,0(sp)
ffffffffc0200bd6:	0141                	addi	sp,sp,16
ffffffffc0200bd8:	8082                	ret

ffffffffc0200bda <get_pte>:
// parameter:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0200bda:	715d                	addi	sp,sp,-80
ffffffffc0200bdc:	fc26                	sd	s1,56(sp)
     *   PTE_W           0x002                   // page table/directory entry
     * flags bit : Writeable
     *   PTE_U           0x004                   // page table/directory entry
     * flags bit : User can access
     */
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0200bde:	01e5d493          	srli	s1,a1,0x1e
ffffffffc0200be2:	1ff4f493          	andi	s1,s1,511
ffffffffc0200be6:	048e                	slli	s1,s1,0x3
ffffffffc0200be8:	94aa                	add	s1,s1,a0
    if (!(*pdep1 & PTE_V)) {
ffffffffc0200bea:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0200bec:	f84a                	sd	s2,48(sp)
ffffffffc0200bee:	f44e                	sd	s3,40(sp)
ffffffffc0200bf0:	f052                	sd	s4,32(sp)
ffffffffc0200bf2:	e486                	sd	ra,72(sp)
ffffffffc0200bf4:	e0a2                	sd	s0,64(sp)
ffffffffc0200bf6:	ec56                	sd	s5,24(sp)
ffffffffc0200bf8:	e85a                	sd	s6,16(sp)
ffffffffc0200bfa:	e45e                	sd	s7,8(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc0200bfc:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0200c00:	892e                	mv	s2,a1
ffffffffc0200c02:	8a32                	mv	s4,a2
ffffffffc0200c04:	00011997          	auipc	s3,0x11
ffffffffc0200c08:	85498993          	addi	s3,s3,-1964 # ffffffffc0211458 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0200c0c:	e3c9                	bnez	a5,ffffffffc0200c8e <get_pte+0xb4>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0200c0e:	16060163          	beqz	a2,ffffffffc0200d70 <get_pte+0x196>
ffffffffc0200c12:	4505                	li	a0,1
ffffffffc0200c14:	eb9ff0ef          	jal	ra,ffffffffc0200acc <alloc_pages>
ffffffffc0200c18:	842a                	mv	s0,a0
ffffffffc0200c1a:	14050b63          	beqz	a0,ffffffffc0200d70 <get_pte+0x196>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200c1e:	00011b97          	auipc	s7,0x11
ffffffffc0200c22:	87ab8b93          	addi	s7,s7,-1926 # ffffffffc0211498 <pages>
ffffffffc0200c26:	000bb503          	ld	a0,0(s7)
ffffffffc0200c2a:	00004797          	auipc	a5,0x4
ffffffffc0200c2e:	01e78793          	addi	a5,a5,30 # ffffffffc0204c48 <commands+0x838>
ffffffffc0200c32:	0007bb03          	ld	s6,0(a5)
ffffffffc0200c36:	40a40533          	sub	a0,s0,a0
ffffffffc0200c3a:	850d                	srai	a0,a0,0x3
ffffffffc0200c3c:	03650533          	mul	a0,a0,s6
ffffffffc0200c40:	00080ab7          	lui	s5,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0200c44:	00011997          	auipc	s3,0x11
ffffffffc0200c48:	81498993          	addi	s3,s3,-2028 # ffffffffc0211458 <npage>
    return pa2page(PDE_ADDR(pde));
}

static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200c4c:	4785                	li	a5,1
ffffffffc0200c4e:	0009b703          	ld	a4,0(s3)
ffffffffc0200c52:	c01c                	sw	a5,0(s0)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200c54:	9556                	add	a0,a0,s5
ffffffffc0200c56:	00c51793          	slli	a5,a0,0xc
ffffffffc0200c5a:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0200c5c:	0532                	slli	a0,a0,0xc
ffffffffc0200c5e:	16e7f063          	bgeu	a5,a4,ffffffffc0200dbe <get_pte+0x1e4>
ffffffffc0200c62:	00011797          	auipc	a5,0x11
ffffffffc0200c66:	82678793          	addi	a5,a5,-2010 # ffffffffc0211488 <va_pa_offset>
ffffffffc0200c6a:	639c                	ld	a5,0(a5)
ffffffffc0200c6c:	6605                	lui	a2,0x1
ffffffffc0200c6e:	4581                	li	a1,0
ffffffffc0200c70:	953e                	add	a0,a0,a5
ffffffffc0200c72:	17e030ef          	jal	ra,ffffffffc0203df0 <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200c76:	000bb683          	ld	a3,0(s7)
ffffffffc0200c7a:	40d406b3          	sub	a3,s0,a3
ffffffffc0200c7e:	868d                	srai	a3,a3,0x3
ffffffffc0200c80:	036686b3          	mul	a3,a3,s6
ffffffffc0200c84:	96d6                	add	a3,a3,s5

static inline void flush_tlb() { asm volatile("sfence.vma"); }

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0200c86:	06aa                	slli	a3,a3,0xa
ffffffffc0200c88:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0200c8c:	e094                	sd	a3,0(s1)
    }
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0200c8e:	77fd                	lui	a5,0xfffff
ffffffffc0200c90:	068a                	slli	a3,a3,0x2
ffffffffc0200c92:	0009b703          	ld	a4,0(s3)
ffffffffc0200c96:	8efd                	and	a3,a3,a5
ffffffffc0200c98:	00c6d793          	srli	a5,a3,0xc
ffffffffc0200c9c:	0ce7fc63          	bgeu	a5,a4,ffffffffc0200d74 <get_pte+0x19a>
ffffffffc0200ca0:	00010a97          	auipc	s5,0x10
ffffffffc0200ca4:	7e8a8a93          	addi	s5,s5,2024 # ffffffffc0211488 <va_pa_offset>
ffffffffc0200ca8:	000ab403          	ld	s0,0(s5)
ffffffffc0200cac:	01595793          	srli	a5,s2,0x15
ffffffffc0200cb0:	1ff7f793          	andi	a5,a5,511
ffffffffc0200cb4:	96a2                	add	a3,a3,s0
ffffffffc0200cb6:	00379413          	slli	s0,a5,0x3
ffffffffc0200cba:	9436                	add	s0,s0,a3
//    pde_t *pdep0 = &((pde_t *)(PDE_ADDR(*pdep1)))[PDX0(la)];
    if (!(*pdep0 & PTE_V)) {
ffffffffc0200cbc:	6014                	ld	a3,0(s0)
ffffffffc0200cbe:	0016f793          	andi	a5,a3,1
ffffffffc0200cc2:	ebbd                	bnez	a5,ffffffffc0200d38 <get_pte+0x15e>
    	struct Page *page;
    	if (!create || (page = alloc_page()) == NULL) {
ffffffffc0200cc4:	0a0a0663          	beqz	s4,ffffffffc0200d70 <get_pte+0x196>
ffffffffc0200cc8:	4505                	li	a0,1
ffffffffc0200cca:	e03ff0ef          	jal	ra,ffffffffc0200acc <alloc_pages>
ffffffffc0200cce:	84aa                	mv	s1,a0
ffffffffc0200cd0:	c145                	beqz	a0,ffffffffc0200d70 <get_pte+0x196>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200cd2:	00010b97          	auipc	s7,0x10
ffffffffc0200cd6:	7c6b8b93          	addi	s7,s7,1990 # ffffffffc0211498 <pages>
ffffffffc0200cda:	000bb503          	ld	a0,0(s7)
ffffffffc0200cde:	00004797          	auipc	a5,0x4
ffffffffc0200ce2:	f6a78793          	addi	a5,a5,-150 # ffffffffc0204c48 <commands+0x838>
ffffffffc0200ce6:	0007bb03          	ld	s6,0(a5)
ffffffffc0200cea:	40a48533          	sub	a0,s1,a0
ffffffffc0200cee:	850d                	srai	a0,a0,0x3
ffffffffc0200cf0:	03650533          	mul	a0,a0,s6
ffffffffc0200cf4:	00080a37          	lui	s4,0x80
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200cf8:	4785                	li	a5,1
    		return NULL;
    	}
    	set_page_ref(page, 1);
    	uintptr_t pa = page2pa(page);
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc0200cfa:	0009b703          	ld	a4,0(s3)
ffffffffc0200cfe:	c09c                	sw	a5,0(s1)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200d00:	9552                	add	a0,a0,s4
ffffffffc0200d02:	00c51793          	slli	a5,a0,0xc
ffffffffc0200d06:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0200d08:	0532                	slli	a0,a0,0xc
ffffffffc0200d0a:	08e7fd63          	bgeu	a5,a4,ffffffffc0200da4 <get_pte+0x1ca>
ffffffffc0200d0e:	000ab783          	ld	a5,0(s5)
ffffffffc0200d12:	6605                	lui	a2,0x1
ffffffffc0200d14:	4581                	li	a1,0
ffffffffc0200d16:	953e                	add	a0,a0,a5
ffffffffc0200d18:	0d8030ef          	jal	ra,ffffffffc0203df0 <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200d1c:	000bb683          	ld	a3,0(s7)
ffffffffc0200d20:	40d486b3          	sub	a3,s1,a3
ffffffffc0200d24:	868d                	srai	a3,a3,0x3
ffffffffc0200d26:	036686b3          	mul	a3,a3,s6
ffffffffc0200d2a:	96d2                	add	a3,a3,s4
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0200d2c:	06aa                	slli	a3,a3,0xa
ffffffffc0200d2e:	0116e693          	ori	a3,a3,17
 //   	memset(pa, 0, PGSIZE);
    	*pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0200d32:	e014                	sd	a3,0(s0)
ffffffffc0200d34:	0009b703          	ld	a4,0(s3)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0200d38:	068a                	slli	a3,a3,0x2
ffffffffc0200d3a:	757d                	lui	a0,0xfffff
ffffffffc0200d3c:	8ee9                	and	a3,a3,a0
ffffffffc0200d3e:	00c6d793          	srli	a5,a3,0xc
ffffffffc0200d42:	04e7f563          	bgeu	a5,a4,ffffffffc0200d8c <get_pte+0x1b2>
ffffffffc0200d46:	000ab503          	ld	a0,0(s5)
ffffffffc0200d4a:	00c95793          	srli	a5,s2,0xc
ffffffffc0200d4e:	1ff7f793          	andi	a5,a5,511
ffffffffc0200d52:	96aa                	add	a3,a3,a0
ffffffffc0200d54:	00379513          	slli	a0,a5,0x3
ffffffffc0200d58:	9536                	add	a0,a0,a3
}
ffffffffc0200d5a:	60a6                	ld	ra,72(sp)
ffffffffc0200d5c:	6406                	ld	s0,64(sp)
ffffffffc0200d5e:	74e2                	ld	s1,56(sp)
ffffffffc0200d60:	7942                	ld	s2,48(sp)
ffffffffc0200d62:	79a2                	ld	s3,40(sp)
ffffffffc0200d64:	7a02                	ld	s4,32(sp)
ffffffffc0200d66:	6ae2                	ld	s5,24(sp)
ffffffffc0200d68:	6b42                	ld	s6,16(sp)
ffffffffc0200d6a:	6ba2                	ld	s7,8(sp)
ffffffffc0200d6c:	6161                	addi	sp,sp,80
ffffffffc0200d6e:	8082                	ret
            return NULL;
ffffffffc0200d70:	4501                	li	a0,0
ffffffffc0200d72:	b7e5                	j	ffffffffc0200d5a <get_pte+0x180>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0200d74:	00004617          	auipc	a2,0x4
ffffffffc0200d78:	edc60613          	addi	a2,a2,-292 # ffffffffc0204c50 <commands+0x840>
ffffffffc0200d7c:	10200593          	li	a1,258
ffffffffc0200d80:	00004517          	auipc	a0,0x4
ffffffffc0200d84:	ef850513          	addi	a0,a0,-264 # ffffffffc0204c78 <commands+0x868>
ffffffffc0200d88:	b7cff0ef          	jal	ra,ffffffffc0200104 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0200d8c:	00004617          	auipc	a2,0x4
ffffffffc0200d90:	ec460613          	addi	a2,a2,-316 # ffffffffc0204c50 <commands+0x840>
ffffffffc0200d94:	10f00593          	li	a1,271
ffffffffc0200d98:	00004517          	auipc	a0,0x4
ffffffffc0200d9c:	ee050513          	addi	a0,a0,-288 # ffffffffc0204c78 <commands+0x868>
ffffffffc0200da0:	b64ff0ef          	jal	ra,ffffffffc0200104 <__panic>
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc0200da4:	86aa                	mv	a3,a0
ffffffffc0200da6:	00004617          	auipc	a2,0x4
ffffffffc0200daa:	eaa60613          	addi	a2,a2,-342 # ffffffffc0204c50 <commands+0x840>
ffffffffc0200dae:	10b00593          	li	a1,267
ffffffffc0200db2:	00004517          	auipc	a0,0x4
ffffffffc0200db6:	ec650513          	addi	a0,a0,-314 # ffffffffc0204c78 <commands+0x868>
ffffffffc0200dba:	b4aff0ef          	jal	ra,ffffffffc0200104 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0200dbe:	86aa                	mv	a3,a0
ffffffffc0200dc0:	00004617          	auipc	a2,0x4
ffffffffc0200dc4:	e9060613          	addi	a2,a2,-368 # ffffffffc0204c50 <commands+0x840>
ffffffffc0200dc8:	0ff00593          	li	a1,255
ffffffffc0200dcc:	00004517          	auipc	a0,0x4
ffffffffc0200dd0:	eac50513          	addi	a0,a0,-340 # ffffffffc0204c78 <commands+0x868>
ffffffffc0200dd4:	b30ff0ef          	jal	ra,ffffffffc0200104 <__panic>

ffffffffc0200dd8 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0200dd8:	1141                	addi	sp,sp,-16
ffffffffc0200dda:	e022                	sd	s0,0(sp)
ffffffffc0200ddc:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0200dde:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0200de0:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0200de2:	df9ff0ef          	jal	ra,ffffffffc0200bda <get_pte>
    if (ptep_store != NULL) {
ffffffffc0200de6:	c011                	beqz	s0,ffffffffc0200dea <get_page+0x12>
        *ptep_store = ptep;
ffffffffc0200de8:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0200dea:	c511                	beqz	a0,ffffffffc0200df6 <get_page+0x1e>
ffffffffc0200dec:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0200dee:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0200df0:	0017f713          	andi	a4,a5,1
ffffffffc0200df4:	e709                	bnez	a4,ffffffffc0200dfe <get_page+0x26>
}
ffffffffc0200df6:	60a2                	ld	ra,8(sp)
ffffffffc0200df8:	6402                	ld	s0,0(sp)
ffffffffc0200dfa:	0141                	addi	sp,sp,16
ffffffffc0200dfc:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0200dfe:	00010717          	auipc	a4,0x10
ffffffffc0200e02:	65a70713          	addi	a4,a4,1626 # ffffffffc0211458 <npage>
ffffffffc0200e06:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0200e08:	078a                	slli	a5,a5,0x2
ffffffffc0200e0a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0200e0c:	02e7f363          	bgeu	a5,a4,ffffffffc0200e32 <get_page+0x5a>
    return &pages[PPN(pa) - nbase];
ffffffffc0200e10:	fff80537          	lui	a0,0xfff80
ffffffffc0200e14:	97aa                	add	a5,a5,a0
ffffffffc0200e16:	00010697          	auipc	a3,0x10
ffffffffc0200e1a:	68268693          	addi	a3,a3,1666 # ffffffffc0211498 <pages>
ffffffffc0200e1e:	6288                	ld	a0,0(a3)
ffffffffc0200e20:	60a2                	ld	ra,8(sp)
ffffffffc0200e22:	6402                	ld	s0,0(sp)
ffffffffc0200e24:	00379713          	slli	a4,a5,0x3
ffffffffc0200e28:	97ba                	add	a5,a5,a4
ffffffffc0200e2a:	078e                	slli	a5,a5,0x3
ffffffffc0200e2c:	953e                	add	a0,a0,a5
ffffffffc0200e2e:	0141                	addi	sp,sp,16
ffffffffc0200e30:	8082                	ret
ffffffffc0200e32:	c7fff0ef          	jal	ra,ffffffffc0200ab0 <pa2page.part.4>

ffffffffc0200e36 <page_remove>:
    }
}

// page_remove - free an Page which is related linear address la and has an
// validated pte
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0200e36:	1141                	addi	sp,sp,-16
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0200e38:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0200e3a:	e406                	sd	ra,8(sp)
ffffffffc0200e3c:	e022                	sd	s0,0(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0200e3e:	d9dff0ef          	jal	ra,ffffffffc0200bda <get_pte>
    if (ptep != NULL) {
ffffffffc0200e42:	c511                	beqz	a0,ffffffffc0200e4e <page_remove+0x18>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0200e44:	611c                	ld	a5,0(a0)
ffffffffc0200e46:	842a                	mv	s0,a0
ffffffffc0200e48:	0017f713          	andi	a4,a5,1
ffffffffc0200e4c:	e709                	bnez	a4,ffffffffc0200e56 <page_remove+0x20>
        page_remove_pte(pgdir, la, ptep);
    }
}
ffffffffc0200e4e:	60a2                	ld	ra,8(sp)
ffffffffc0200e50:	6402                	ld	s0,0(sp)
ffffffffc0200e52:	0141                	addi	sp,sp,16
ffffffffc0200e54:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0200e56:	00010717          	auipc	a4,0x10
ffffffffc0200e5a:	60270713          	addi	a4,a4,1538 # ffffffffc0211458 <npage>
ffffffffc0200e5e:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0200e60:	078a                	slli	a5,a5,0x2
ffffffffc0200e62:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0200e64:	04e7f063          	bgeu	a5,a4,ffffffffc0200ea4 <page_remove+0x6e>
    return &pages[PPN(pa) - nbase];
ffffffffc0200e68:	fff80737          	lui	a4,0xfff80
ffffffffc0200e6c:	97ba                	add	a5,a5,a4
ffffffffc0200e6e:	00010717          	auipc	a4,0x10
ffffffffc0200e72:	62a70713          	addi	a4,a4,1578 # ffffffffc0211498 <pages>
ffffffffc0200e76:	6308                	ld	a0,0(a4)
ffffffffc0200e78:	00379713          	slli	a4,a5,0x3
ffffffffc0200e7c:	97ba                	add	a5,a5,a4
ffffffffc0200e7e:	078e                	slli	a5,a5,0x3
ffffffffc0200e80:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0200e82:	411c                	lw	a5,0(a0)
ffffffffc0200e84:	fff7871b          	addiw	a4,a5,-1
ffffffffc0200e88:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0200e8a:	cb09                	beqz	a4,ffffffffc0200e9c <page_remove+0x66>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0200e8c:	00043023          	sd	zero,0(s0)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0200e90:	12000073          	sfence.vma
}
ffffffffc0200e94:	60a2                	ld	ra,8(sp)
ffffffffc0200e96:	6402                	ld	s0,0(sp)
ffffffffc0200e98:	0141                	addi	sp,sp,16
ffffffffc0200e9a:	8082                	ret
            free_page(page);
ffffffffc0200e9c:	4585                	li	a1,1
ffffffffc0200e9e:	cb7ff0ef          	jal	ra,ffffffffc0200b54 <free_pages>
ffffffffc0200ea2:	b7ed                	j	ffffffffc0200e8c <page_remove+0x56>
ffffffffc0200ea4:	c0dff0ef          	jal	ra,ffffffffc0200ab0 <pa2page.part.4>

ffffffffc0200ea8 <page_insert>:
//  page:  the Page which need to map
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
// note: PT is changed, so the TLB need to be invalidate
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0200ea8:	7179                	addi	sp,sp,-48
ffffffffc0200eaa:	87b2                	mv	a5,a2
ffffffffc0200eac:	f022                	sd	s0,32(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0200eae:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0200eb0:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0200eb2:	85be                	mv	a1,a5
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0200eb4:	ec26                	sd	s1,24(sp)
ffffffffc0200eb6:	f406                	sd	ra,40(sp)
ffffffffc0200eb8:	e84a                	sd	s2,16(sp)
ffffffffc0200eba:	e44e                	sd	s3,8(sp)
ffffffffc0200ebc:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0200ebe:	d1dff0ef          	jal	ra,ffffffffc0200bda <get_pte>
    if (ptep == NULL) {
ffffffffc0200ec2:	c945                	beqz	a0,ffffffffc0200f72 <page_insert+0xca>
    page->ref += 1;
ffffffffc0200ec4:	4014                	lw	a3,0(s0)
        return -E_NO_MEM;
    }
    page_ref_inc(page);
    if (*ptep & PTE_V) {
ffffffffc0200ec6:	611c                	ld	a5,0(a0)
ffffffffc0200ec8:	892a                	mv	s2,a0
ffffffffc0200eca:	0016871b          	addiw	a4,a3,1
ffffffffc0200ece:	c018                	sw	a4,0(s0)
ffffffffc0200ed0:	0017f713          	andi	a4,a5,1
ffffffffc0200ed4:	e339                	bnez	a4,ffffffffc0200f1a <page_insert+0x72>
ffffffffc0200ed6:	00010797          	auipc	a5,0x10
ffffffffc0200eda:	5c278793          	addi	a5,a5,1474 # ffffffffc0211498 <pages>
ffffffffc0200ede:	639c                	ld	a5,0(a5)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200ee0:	00004717          	auipc	a4,0x4
ffffffffc0200ee4:	d6870713          	addi	a4,a4,-664 # ffffffffc0204c48 <commands+0x838>
ffffffffc0200ee8:	40f407b3          	sub	a5,s0,a5
ffffffffc0200eec:	6300                	ld	s0,0(a4)
ffffffffc0200eee:	878d                	srai	a5,a5,0x3
ffffffffc0200ef0:	000806b7          	lui	a3,0x80
ffffffffc0200ef4:	028787b3          	mul	a5,a5,s0
ffffffffc0200ef8:	97b6                	add	a5,a5,a3
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0200efa:	07aa                	slli	a5,a5,0xa
ffffffffc0200efc:	8fc5                	or	a5,a5,s1
ffffffffc0200efe:	0017e793          	ori	a5,a5,1
            page_ref_dec(page);
        } else {
            page_remove_pte(pgdir, la, ptep);
        }
    }
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0200f02:	00f93023          	sd	a5,0(s2)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0200f06:	12000073          	sfence.vma
    tlb_invalidate(pgdir, la);
    return 0;
ffffffffc0200f0a:	4501                	li	a0,0
}
ffffffffc0200f0c:	70a2                	ld	ra,40(sp)
ffffffffc0200f0e:	7402                	ld	s0,32(sp)
ffffffffc0200f10:	64e2                	ld	s1,24(sp)
ffffffffc0200f12:	6942                	ld	s2,16(sp)
ffffffffc0200f14:	69a2                	ld	s3,8(sp)
ffffffffc0200f16:	6145                	addi	sp,sp,48
ffffffffc0200f18:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0200f1a:	00010717          	auipc	a4,0x10
ffffffffc0200f1e:	53e70713          	addi	a4,a4,1342 # ffffffffc0211458 <npage>
ffffffffc0200f22:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0200f24:	00279513          	slli	a0,a5,0x2
ffffffffc0200f28:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc0200f2a:	04e57663          	bgeu	a0,a4,ffffffffc0200f76 <page_insert+0xce>
    return &pages[PPN(pa) - nbase];
ffffffffc0200f2e:	fff807b7          	lui	a5,0xfff80
ffffffffc0200f32:	953e                	add	a0,a0,a5
ffffffffc0200f34:	00010997          	auipc	s3,0x10
ffffffffc0200f38:	56498993          	addi	s3,s3,1380 # ffffffffc0211498 <pages>
ffffffffc0200f3c:	0009b783          	ld	a5,0(s3)
ffffffffc0200f40:	00351713          	slli	a4,a0,0x3
ffffffffc0200f44:	953a                	add	a0,a0,a4
ffffffffc0200f46:	050e                	slli	a0,a0,0x3
ffffffffc0200f48:	953e                	add	a0,a0,a5
        if (p == page) {
ffffffffc0200f4a:	00a40e63          	beq	s0,a0,ffffffffc0200f66 <page_insert+0xbe>
    page->ref -= 1;
ffffffffc0200f4e:	411c                	lw	a5,0(a0)
ffffffffc0200f50:	fff7871b          	addiw	a4,a5,-1
ffffffffc0200f54:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0200f56:	cb11                	beqz	a4,ffffffffc0200f6a <page_insert+0xc2>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0200f58:	00093023          	sd	zero,0(s2)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0200f5c:	12000073          	sfence.vma
ffffffffc0200f60:	0009b783          	ld	a5,0(s3)
ffffffffc0200f64:	bfb5                	j	ffffffffc0200ee0 <page_insert+0x38>
    page->ref -= 1;
ffffffffc0200f66:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0200f68:	bfa5                	j	ffffffffc0200ee0 <page_insert+0x38>
            free_page(page);
ffffffffc0200f6a:	4585                	li	a1,1
ffffffffc0200f6c:	be9ff0ef          	jal	ra,ffffffffc0200b54 <free_pages>
ffffffffc0200f70:	b7e5                	j	ffffffffc0200f58 <page_insert+0xb0>
        return -E_NO_MEM;
ffffffffc0200f72:	5571                	li	a0,-4
ffffffffc0200f74:	bf61                	j	ffffffffc0200f0c <page_insert+0x64>
ffffffffc0200f76:	b3bff0ef          	jal	ra,ffffffffc0200ab0 <pa2page.part.4>

ffffffffc0200f7a <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0200f7a:	00005797          	auipc	a5,0x5
ffffffffc0200f7e:	d9e78793          	addi	a5,a5,-610 # ffffffffc0205d18 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200f82:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0200f84:	711d                	addi	sp,sp,-96
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200f86:	00004517          	auipc	a0,0x4
ffffffffc0200f8a:	d8a50513          	addi	a0,a0,-630 # ffffffffc0204d10 <commands+0x900>
void pmm_init(void) {
ffffffffc0200f8e:	ec86                	sd	ra,88(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0200f90:	00010717          	auipc	a4,0x10
ffffffffc0200f94:	4ef73823          	sd	a5,1264(a4) # ffffffffc0211480 <pmm_manager>
void pmm_init(void) {
ffffffffc0200f98:	e8a2                	sd	s0,80(sp)
ffffffffc0200f9a:	e4a6                	sd	s1,72(sp)
ffffffffc0200f9c:	e0ca                	sd	s2,64(sp)
ffffffffc0200f9e:	fc4e                	sd	s3,56(sp)
ffffffffc0200fa0:	f852                	sd	s4,48(sp)
ffffffffc0200fa2:	f456                	sd	s5,40(sp)
ffffffffc0200fa4:	f05a                	sd	s6,32(sp)
ffffffffc0200fa6:	ec5e                	sd	s7,24(sp)
ffffffffc0200fa8:	e862                	sd	s8,16(sp)
ffffffffc0200faa:	e466                	sd	s9,8(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0200fac:	00010417          	auipc	s0,0x10
ffffffffc0200fb0:	4d440413          	addi	s0,s0,1236 # ffffffffc0211480 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200fb4:	90aff0ef          	jal	ra,ffffffffc02000be <cprintf>
    pmm_manager->init();
ffffffffc0200fb8:	601c                	ld	a5,0(s0)
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0200fba:	49c5                	li	s3,17
ffffffffc0200fbc:	40100a13          	li	s4,1025
    pmm_manager->init();
ffffffffc0200fc0:	679c                	ld	a5,8(a5)
ffffffffc0200fc2:	00010497          	auipc	s1,0x10
ffffffffc0200fc6:	49648493          	addi	s1,s1,1174 # ffffffffc0211458 <npage>
ffffffffc0200fca:	00010917          	auipc	s2,0x10
ffffffffc0200fce:	4ce90913          	addi	s2,s2,1230 # ffffffffc0211498 <pages>
ffffffffc0200fd2:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0200fd4:	57f5                	li	a5,-3
ffffffffc0200fd6:	07fa                	slli	a5,a5,0x1e
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0200fd8:	07e006b7          	lui	a3,0x7e00
ffffffffc0200fdc:	01b99613          	slli	a2,s3,0x1b
ffffffffc0200fe0:	015a1593          	slli	a1,s4,0x15
ffffffffc0200fe4:	00004517          	auipc	a0,0x4
ffffffffc0200fe8:	d4450513          	addi	a0,a0,-700 # ffffffffc0204d28 <commands+0x918>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0200fec:	00010717          	auipc	a4,0x10
ffffffffc0200ff0:	48f73e23          	sd	a5,1180(a4) # ffffffffc0211488 <va_pa_offset>
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0200ff4:	8caff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("physcial memory map:\n");
ffffffffc0200ff8:	00004517          	auipc	a0,0x4
ffffffffc0200ffc:	d6050513          	addi	a0,a0,-672 # ffffffffc0204d58 <commands+0x948>
ffffffffc0201000:	8beff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0201004:	01b99693          	slli	a3,s3,0x1b
ffffffffc0201008:	16fd                	addi	a3,a3,-1
ffffffffc020100a:	015a1613          	slli	a2,s4,0x15
ffffffffc020100e:	07e005b7          	lui	a1,0x7e00
ffffffffc0201012:	00004517          	auipc	a0,0x4
ffffffffc0201016:	d5e50513          	addi	a0,a0,-674 # ffffffffc0204d70 <commands+0x960>
ffffffffc020101a:	8a4ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020101e:	777d                	lui	a4,0xfffff
ffffffffc0201020:	00011797          	auipc	a5,0x11
ffffffffc0201024:	57f78793          	addi	a5,a5,1407 # ffffffffc021259f <end+0xfff>
ffffffffc0201028:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc020102a:	00088737          	lui	a4,0x88
ffffffffc020102e:	00010697          	auipc	a3,0x10
ffffffffc0201032:	42e6b523          	sd	a4,1066(a3) # ffffffffc0211458 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201036:	00010717          	auipc	a4,0x10
ffffffffc020103a:	46f73123          	sd	a5,1122(a4) # ffffffffc0211498 <pages>
ffffffffc020103e:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201040:	4701                	li	a4,0
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201042:	4585                	li	a1,1
ffffffffc0201044:	fff80637          	lui	a2,0xfff80
ffffffffc0201048:	a019                	j	ffffffffc020104e <pmm_init+0xd4>
ffffffffc020104a:	00093783          	ld	a5,0(s2)
        SetPageReserved(pages + i);
ffffffffc020104e:	97b6                	add	a5,a5,a3
ffffffffc0201050:	07a1                	addi	a5,a5,8
ffffffffc0201052:	40b7b02f          	amoor.d	zero,a1,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201056:	609c                	ld	a5,0(s1)
ffffffffc0201058:	0705                	addi	a4,a4,1
ffffffffc020105a:	04868693          	addi	a3,a3,72
ffffffffc020105e:	00c78533          	add	a0,a5,a2
ffffffffc0201062:	fea764e3          	bltu	a4,a0,ffffffffc020104a <pmm_init+0xd0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201066:	00093503          	ld	a0,0(s2)
ffffffffc020106a:	00379693          	slli	a3,a5,0x3
ffffffffc020106e:	96be                	add	a3,a3,a5
ffffffffc0201070:	fdc00737          	lui	a4,0xfdc00
ffffffffc0201074:	972a                	add	a4,a4,a0
ffffffffc0201076:	068e                	slli	a3,a3,0x3
ffffffffc0201078:	96ba                	add	a3,a3,a4
ffffffffc020107a:	c0200737          	lui	a4,0xc0200
ffffffffc020107e:	58e6e863          	bltu	a3,a4,ffffffffc020160e <pmm_init+0x694>
ffffffffc0201082:	00010997          	auipc	s3,0x10
ffffffffc0201086:	40698993          	addi	s3,s3,1030 # ffffffffc0211488 <va_pa_offset>
ffffffffc020108a:	0009b703          	ld	a4,0(s3)
    if (freemem < mem_end) {
ffffffffc020108e:	45c5                	li	a1,17
ffffffffc0201090:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201092:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc0201094:	44b6ed63          	bltu	a3,a1,ffffffffc02014ee <pmm_init+0x574>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0201098:	601c                	ld	a5,0(s0)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc020109a:	00010417          	auipc	s0,0x10
ffffffffc020109e:	3b640413          	addi	s0,s0,950 # ffffffffc0211450 <boot_pgdir>
    pmm_manager->check();
ffffffffc02010a2:	7b9c                	ld	a5,48(a5)
ffffffffc02010a4:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc02010a6:	00004517          	auipc	a0,0x4
ffffffffc02010aa:	d1a50513          	addi	a0,a0,-742 # ffffffffc0204dc0 <commands+0x9b0>
ffffffffc02010ae:	810ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc02010b2:	00008697          	auipc	a3,0x8
ffffffffc02010b6:	f4e68693          	addi	a3,a3,-178 # ffffffffc0209000 <boot_page_table_sv39>
ffffffffc02010ba:	00010797          	auipc	a5,0x10
ffffffffc02010be:	38d7bb23          	sd	a3,918(a5) # ffffffffc0211450 <boot_pgdir>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc02010c2:	c02007b7          	lui	a5,0xc0200
ffffffffc02010c6:	0ef6eae3          	bltu	a3,a5,ffffffffc02019ba <pmm_init+0xa40>
ffffffffc02010ca:	0009b783          	ld	a5,0(s3)
ffffffffc02010ce:	8e9d                	sub	a3,a3,a5
ffffffffc02010d0:	00010797          	auipc	a5,0x10
ffffffffc02010d4:	3cd7b023          	sd	a3,960(a5) # ffffffffc0211490 <boot_cr3>
    // assert(npage <= KMEMSIZE / PGSIZE);
    // The memory starts at 2GB in RISC-V
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();
ffffffffc02010d8:	ac3ff0ef          	jal	ra,ffffffffc0200b9a <nr_free_pages>

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02010dc:	6098                	ld	a4,0(s1)
ffffffffc02010de:	c80007b7          	lui	a5,0xc8000
ffffffffc02010e2:	83b1                	srli	a5,a5,0xc
    nr_free_store=nr_free_pages();
ffffffffc02010e4:	8a2a                	mv	s4,a0
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02010e6:	0ae7eae3          	bltu	a5,a4,ffffffffc020199a <pmm_init+0xa20>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc02010ea:	6008                	ld	a0,0(s0)
ffffffffc02010ec:	4c050163          	beqz	a0,ffffffffc02015ae <pmm_init+0x634>
ffffffffc02010f0:	03451793          	slli	a5,a0,0x34
ffffffffc02010f4:	4a079d63          	bnez	a5,ffffffffc02015ae <pmm_init+0x634>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc02010f8:	4601                	li	a2,0
ffffffffc02010fa:	4581                	li	a1,0
ffffffffc02010fc:	cddff0ef          	jal	ra,ffffffffc0200dd8 <get_page>
ffffffffc0201100:	4c051763          	bnez	a0,ffffffffc02015ce <pmm_init+0x654>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc0201104:	4505                	li	a0,1
ffffffffc0201106:	9c7ff0ef          	jal	ra,ffffffffc0200acc <alloc_pages>
ffffffffc020110a:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc020110c:	6008                	ld	a0,0(s0)
ffffffffc020110e:	4681                	li	a3,0
ffffffffc0201110:	4601                	li	a2,0
ffffffffc0201112:	85d6                	mv	a1,s5
ffffffffc0201114:	d95ff0ef          	jal	ra,ffffffffc0200ea8 <page_insert>
ffffffffc0201118:	52051763          	bnez	a0,ffffffffc0201646 <pmm_init+0x6cc>
    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc020111c:	6008                	ld	a0,0(s0)
ffffffffc020111e:	4601                	li	a2,0
ffffffffc0201120:	4581                	li	a1,0
ffffffffc0201122:	ab9ff0ef          	jal	ra,ffffffffc0200bda <get_pte>
ffffffffc0201126:	50050063          	beqz	a0,ffffffffc0201626 <pmm_init+0x6ac>
    assert(pte2page(*ptep) == p1);
ffffffffc020112a:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc020112c:	0017f713          	andi	a4,a5,1
ffffffffc0201130:	46070363          	beqz	a4,ffffffffc0201596 <pmm_init+0x61c>
    if (PPN(pa) >= npage) {
ffffffffc0201134:	6090                	ld	a2,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201136:	078a                	slli	a5,a5,0x2
ffffffffc0201138:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020113a:	44c7f063          	bgeu	a5,a2,ffffffffc020157a <pmm_init+0x600>
    return &pages[PPN(pa) - nbase];
ffffffffc020113e:	fff80737          	lui	a4,0xfff80
ffffffffc0201142:	97ba                	add	a5,a5,a4
ffffffffc0201144:	00379713          	slli	a4,a5,0x3
ffffffffc0201148:	00093683          	ld	a3,0(s2)
ffffffffc020114c:	97ba                	add	a5,a5,a4
ffffffffc020114e:	078e                	slli	a5,a5,0x3
ffffffffc0201150:	97b6                	add	a5,a5,a3
ffffffffc0201152:	5efa9463          	bne	s5,a5,ffffffffc020173a <pmm_init+0x7c0>
    assert(page_ref(p1) == 1);
ffffffffc0201156:	000aab83          	lw	s7,0(s5)
ffffffffc020115a:	4785                	li	a5,1
ffffffffc020115c:	5afb9f63          	bne	s7,a5,ffffffffc020171a <pmm_init+0x7a0>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0201160:	6008                	ld	a0,0(s0)
ffffffffc0201162:	76fd                	lui	a3,0xfffff
ffffffffc0201164:	611c                	ld	a5,0(a0)
ffffffffc0201166:	078a                	slli	a5,a5,0x2
ffffffffc0201168:	8ff5                	and	a5,a5,a3
ffffffffc020116a:	00c7d713          	srli	a4,a5,0xc
ffffffffc020116e:	58c77963          	bgeu	a4,a2,ffffffffc0201700 <pmm_init+0x786>
ffffffffc0201172:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201176:	97e2                	add	a5,a5,s8
ffffffffc0201178:	0007bb03          	ld	s6,0(a5) # ffffffffc8000000 <end+0x7deea60>
ffffffffc020117c:	0b0a                	slli	s6,s6,0x2
ffffffffc020117e:	00db7b33          	and	s6,s6,a3
ffffffffc0201182:	00cb5793          	srli	a5,s6,0xc
ffffffffc0201186:	56c7f063          	bgeu	a5,a2,ffffffffc02016e6 <pmm_init+0x76c>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc020118a:	4601                	li	a2,0
ffffffffc020118c:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020118e:	9b62                	add	s6,s6,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201190:	a4bff0ef          	jal	ra,ffffffffc0200bda <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201194:	0b21                	addi	s6,s6,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201196:	53651863          	bne	a0,s6,ffffffffc02016c6 <pmm_init+0x74c>

    p2 = alloc_page();
ffffffffc020119a:	4505                	li	a0,1
ffffffffc020119c:	931ff0ef          	jal	ra,ffffffffc0200acc <alloc_pages>
ffffffffc02011a0:	8b2a                	mv	s6,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc02011a2:	6008                	ld	a0,0(s0)
ffffffffc02011a4:	46d1                	li	a3,20
ffffffffc02011a6:	6605                	lui	a2,0x1
ffffffffc02011a8:	85da                	mv	a1,s6
ffffffffc02011aa:	cffff0ef          	jal	ra,ffffffffc0200ea8 <page_insert>
ffffffffc02011ae:	4e051c63          	bnez	a0,ffffffffc02016a6 <pmm_init+0x72c>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02011b2:	6008                	ld	a0,0(s0)
ffffffffc02011b4:	4601                	li	a2,0
ffffffffc02011b6:	6585                	lui	a1,0x1
ffffffffc02011b8:	a23ff0ef          	jal	ra,ffffffffc0200bda <get_pte>
ffffffffc02011bc:	4c050563          	beqz	a0,ffffffffc0201686 <pmm_init+0x70c>
    assert(*ptep & PTE_U);
ffffffffc02011c0:	611c                	ld	a5,0(a0)
ffffffffc02011c2:	0107f713          	andi	a4,a5,16
ffffffffc02011c6:	4a070063          	beqz	a4,ffffffffc0201666 <pmm_init+0x6ec>
    assert(*ptep & PTE_W);
ffffffffc02011ca:	8b91                	andi	a5,a5,4
ffffffffc02011cc:	66078763          	beqz	a5,ffffffffc020183a <pmm_init+0x8c0>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc02011d0:	6008                	ld	a0,0(s0)
ffffffffc02011d2:	611c                	ld	a5,0(a0)
ffffffffc02011d4:	8bc1                	andi	a5,a5,16
ffffffffc02011d6:	64078263          	beqz	a5,ffffffffc020181a <pmm_init+0x8a0>
    assert(page_ref(p2) == 1);
ffffffffc02011da:	000b2783          	lw	a5,0(s6)
ffffffffc02011de:	61779e63          	bne	a5,s7,ffffffffc02017fa <pmm_init+0x880>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc02011e2:	4681                	li	a3,0
ffffffffc02011e4:	6605                	lui	a2,0x1
ffffffffc02011e6:	85d6                	mv	a1,s5
ffffffffc02011e8:	cc1ff0ef          	jal	ra,ffffffffc0200ea8 <page_insert>
ffffffffc02011ec:	5e051763          	bnez	a0,ffffffffc02017da <pmm_init+0x860>
    assert(page_ref(p1) == 2);
ffffffffc02011f0:	000aa703          	lw	a4,0(s5)
ffffffffc02011f4:	4789                	li	a5,2
ffffffffc02011f6:	5cf71263          	bne	a4,a5,ffffffffc02017ba <pmm_init+0x840>
    assert(page_ref(p2) == 0);
ffffffffc02011fa:	000b2783          	lw	a5,0(s6)
ffffffffc02011fe:	58079e63          	bnez	a5,ffffffffc020179a <pmm_init+0x820>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201202:	6008                	ld	a0,0(s0)
ffffffffc0201204:	4601                	li	a2,0
ffffffffc0201206:	6585                	lui	a1,0x1
ffffffffc0201208:	9d3ff0ef          	jal	ra,ffffffffc0200bda <get_pte>
ffffffffc020120c:	56050763          	beqz	a0,ffffffffc020177a <pmm_init+0x800>
    assert(pte2page(*ptep) == p1);
ffffffffc0201210:	6114                	ld	a3,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201212:	0016f793          	andi	a5,a3,1
ffffffffc0201216:	38078063          	beqz	a5,ffffffffc0201596 <pmm_init+0x61c>
    if (PPN(pa) >= npage) {
ffffffffc020121a:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc020121c:	00269793          	slli	a5,a3,0x2
ffffffffc0201220:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201222:	34e7fc63          	bgeu	a5,a4,ffffffffc020157a <pmm_init+0x600>
    return &pages[PPN(pa) - nbase];
ffffffffc0201226:	fff80737          	lui	a4,0xfff80
ffffffffc020122a:	97ba                	add	a5,a5,a4
ffffffffc020122c:	00379713          	slli	a4,a5,0x3
ffffffffc0201230:	00093603          	ld	a2,0(s2)
ffffffffc0201234:	97ba                	add	a5,a5,a4
ffffffffc0201236:	078e                	slli	a5,a5,0x3
ffffffffc0201238:	97b2                	add	a5,a5,a2
ffffffffc020123a:	52fa9063          	bne	s5,a5,ffffffffc020175a <pmm_init+0x7e0>
    assert((*ptep & PTE_U) == 0);
ffffffffc020123e:	8ac1                	andi	a3,a3,16
ffffffffc0201240:	6e069d63          	bnez	a3,ffffffffc020193a <pmm_init+0x9c0>

    page_remove(boot_pgdir, 0x0);
ffffffffc0201244:	6008                	ld	a0,0(s0)
ffffffffc0201246:	4581                	li	a1,0
ffffffffc0201248:	befff0ef          	jal	ra,ffffffffc0200e36 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc020124c:	000aa703          	lw	a4,0(s5)
ffffffffc0201250:	4785                	li	a5,1
ffffffffc0201252:	6cf71463          	bne	a4,a5,ffffffffc020191a <pmm_init+0x9a0>
    assert(page_ref(p2) == 0);
ffffffffc0201256:	000b2783          	lw	a5,0(s6)
ffffffffc020125a:	6a079063          	bnez	a5,ffffffffc02018fa <pmm_init+0x980>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc020125e:	6008                	ld	a0,0(s0)
ffffffffc0201260:	6585                	lui	a1,0x1
ffffffffc0201262:	bd5ff0ef          	jal	ra,ffffffffc0200e36 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0201266:	000aa783          	lw	a5,0(s5)
ffffffffc020126a:	66079863          	bnez	a5,ffffffffc02018da <pmm_init+0x960>
    assert(page_ref(p2) == 0);
ffffffffc020126e:	000b2783          	lw	a5,0(s6)
ffffffffc0201272:	70079463          	bnez	a5,ffffffffc020197a <pmm_init+0xa00>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0201276:	00043b03          	ld	s6,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc020127a:	6090                	ld	a2,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020127c:	000b3783          	ld	a5,0(s6)
ffffffffc0201280:	078a                	slli	a5,a5,0x2
ffffffffc0201282:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201284:	2ec7fb63          	bgeu	a5,a2,ffffffffc020157a <pmm_init+0x600>
    return &pages[PPN(pa) - nbase];
ffffffffc0201288:	fff80737          	lui	a4,0xfff80
ffffffffc020128c:	973e                	add	a4,a4,a5
ffffffffc020128e:	00371793          	slli	a5,a4,0x3
ffffffffc0201292:	00093803          	ld	a6,0(s2)
ffffffffc0201296:	97ba                	add	a5,a5,a4
ffffffffc0201298:	078e                	slli	a5,a5,0x3
ffffffffc020129a:	00f80733          	add	a4,a6,a5
ffffffffc020129e:	4314                	lw	a3,0(a4)
ffffffffc02012a0:	4705                	li	a4,1
ffffffffc02012a2:	6ae69c63          	bne	a3,a4,ffffffffc020195a <pmm_init+0x9e0>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02012a6:	00004a97          	auipc	s5,0x4
ffffffffc02012aa:	9a2a8a93          	addi	s5,s5,-1630 # ffffffffc0204c48 <commands+0x838>
ffffffffc02012ae:	000ab703          	ld	a4,0(s5)
ffffffffc02012b2:	4037d693          	srai	a3,a5,0x3
ffffffffc02012b6:	00080bb7          	lui	s7,0x80
ffffffffc02012ba:	02e686b3          	mul	a3,a3,a4
ffffffffc02012be:	96de                	add	a3,a3,s7
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02012c0:	00c69793          	slli	a5,a3,0xc
ffffffffc02012c4:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02012c6:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02012c8:	2ac7fb63          	bgeu	a5,a2,ffffffffc020157e <pmm_init+0x604>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc02012cc:	0009b703          	ld	a4,0(s3)
ffffffffc02012d0:	96ba                	add	a3,a3,a4
    return pa2page(PDE_ADDR(pde));
ffffffffc02012d2:	629c                	ld	a5,0(a3)
ffffffffc02012d4:	078a                	slli	a5,a5,0x2
ffffffffc02012d6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02012d8:	2ac7f163          	bgeu	a5,a2,ffffffffc020157a <pmm_init+0x600>
    return &pages[PPN(pa) - nbase];
ffffffffc02012dc:	417787b3          	sub	a5,a5,s7
ffffffffc02012e0:	00379513          	slli	a0,a5,0x3
ffffffffc02012e4:	97aa                	add	a5,a5,a0
ffffffffc02012e6:	00379513          	slli	a0,a5,0x3
ffffffffc02012ea:	9542                	add	a0,a0,a6
ffffffffc02012ec:	4585                	li	a1,1
ffffffffc02012ee:	867ff0ef          	jal	ra,ffffffffc0200b54 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc02012f2:	000b3503          	ld	a0,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc02012f6:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02012f8:	050a                	slli	a0,a0,0x2
ffffffffc02012fa:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc02012fc:	26f57f63          	bgeu	a0,a5,ffffffffc020157a <pmm_init+0x600>
    return &pages[PPN(pa) - nbase];
ffffffffc0201300:	417507b3          	sub	a5,a0,s7
ffffffffc0201304:	00379513          	slli	a0,a5,0x3
ffffffffc0201308:	00093703          	ld	a4,0(s2)
ffffffffc020130c:	953e                	add	a0,a0,a5
ffffffffc020130e:	050e                	slli	a0,a0,0x3
    free_page(pde2page(pd1[0]));
ffffffffc0201310:	4585                	li	a1,1
ffffffffc0201312:	953a                	add	a0,a0,a4
ffffffffc0201314:	841ff0ef          	jal	ra,ffffffffc0200b54 <free_pages>
    boot_pgdir[0] = 0;
ffffffffc0201318:	601c                	ld	a5,0(s0)
ffffffffc020131a:	0007b023          	sd	zero,0(a5)

    assert(nr_free_store==nr_free_pages());
ffffffffc020131e:	87dff0ef          	jal	ra,ffffffffc0200b9a <nr_free_pages>
ffffffffc0201322:	2caa1663          	bne	s4,a0,ffffffffc02015ee <pmm_init+0x674>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc0201326:	00004517          	auipc	a0,0x4
ffffffffc020132a:	dc250513          	addi	a0,a0,-574 # ffffffffc02050e8 <commands+0xcd8>
ffffffffc020132e:	d91fe0ef          	jal	ra,ffffffffc02000be <cprintf>
static void check_boot_pgdir(void) {
    size_t nr_free_store;
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();
ffffffffc0201332:	869ff0ef          	jal	ra,ffffffffc0200b9a <nr_free_pages>

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201336:	6098                	ld	a4,0(s1)
ffffffffc0201338:	c02007b7          	lui	a5,0xc0200
    nr_free_store=nr_free_pages();
ffffffffc020133c:	8b2a                	mv	s6,a0
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc020133e:	00c71693          	slli	a3,a4,0xc
ffffffffc0201342:	1cd7fd63          	bgeu	a5,a3,ffffffffc020151c <pmm_init+0x5a2>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201346:	83b1                	srli	a5,a5,0xc
ffffffffc0201348:	6008                	ld	a0,0(s0)
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc020134a:	c0200a37          	lui	s4,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc020134e:	1ce7f963          	bgeu	a5,a4,ffffffffc0201520 <pmm_init+0x5a6>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201352:	7c7d                	lui	s8,0xfffff
ffffffffc0201354:	6b85                	lui	s7,0x1
ffffffffc0201356:	a029                	j	ffffffffc0201360 <pmm_init+0x3e6>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201358:	00ca5713          	srli	a4,s4,0xc
ffffffffc020135c:	1cf77263          	bgeu	a4,a5,ffffffffc0201520 <pmm_init+0x5a6>
ffffffffc0201360:	0009b583          	ld	a1,0(s3)
ffffffffc0201364:	4601                	li	a2,0
ffffffffc0201366:	95d2                	add	a1,a1,s4
ffffffffc0201368:	873ff0ef          	jal	ra,ffffffffc0200bda <get_pte>
ffffffffc020136c:	1c050763          	beqz	a0,ffffffffc020153a <pmm_init+0x5c0>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201370:	611c                	ld	a5,0(a0)
ffffffffc0201372:	078a                	slli	a5,a5,0x2
ffffffffc0201374:	0187f7b3          	and	a5,a5,s8
ffffffffc0201378:	1f479163          	bne	a5,s4,ffffffffc020155a <pmm_init+0x5e0>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc020137c:	609c                	ld	a5,0(s1)
ffffffffc020137e:	9a5e                	add	s4,s4,s7
ffffffffc0201380:	6008                	ld	a0,0(s0)
ffffffffc0201382:	00c79713          	slli	a4,a5,0xc
ffffffffc0201386:	fcea69e3          	bltu	s4,a4,ffffffffc0201358 <pmm_init+0x3de>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc020138a:	611c                	ld	a5,0(a0)
ffffffffc020138c:	6a079363          	bnez	a5,ffffffffc0201a32 <pmm_init+0xab8>

    struct Page *p;
    p = alloc_page();
ffffffffc0201390:	4505                	li	a0,1
ffffffffc0201392:	f3aff0ef          	jal	ra,ffffffffc0200acc <alloc_pages>
ffffffffc0201396:	8a2a                	mv	s4,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0201398:	6008                	ld	a0,0(s0)
ffffffffc020139a:	4699                	li	a3,6
ffffffffc020139c:	10000613          	li	a2,256
ffffffffc02013a0:	85d2                	mv	a1,s4
ffffffffc02013a2:	b07ff0ef          	jal	ra,ffffffffc0200ea8 <page_insert>
ffffffffc02013a6:	66051663          	bnez	a0,ffffffffc0201a12 <pmm_init+0xa98>
    assert(page_ref(p) == 1);
ffffffffc02013aa:	000a2703          	lw	a4,0(s4) # ffffffffc0200000 <kern_entry>
ffffffffc02013ae:	4785                	li	a5,1
ffffffffc02013b0:	64f71163          	bne	a4,a5,ffffffffc02019f2 <pmm_init+0xa78>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc02013b4:	6008                	ld	a0,0(s0)
ffffffffc02013b6:	6b85                	lui	s7,0x1
ffffffffc02013b8:	4699                	li	a3,6
ffffffffc02013ba:	100b8613          	addi	a2,s7,256 # 1100 <BASE_ADDRESS-0xffffffffc01fef00>
ffffffffc02013be:	85d2                	mv	a1,s4
ffffffffc02013c0:	ae9ff0ef          	jal	ra,ffffffffc0200ea8 <page_insert>
ffffffffc02013c4:	60051763          	bnez	a0,ffffffffc02019d2 <pmm_init+0xa58>
    assert(page_ref(p) == 2);
ffffffffc02013c8:	000a2703          	lw	a4,0(s4)
ffffffffc02013cc:	4789                	li	a5,2
ffffffffc02013ce:	4ef71663          	bne	a4,a5,ffffffffc02018ba <pmm_init+0x940>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc02013d2:	00004597          	auipc	a1,0x4
ffffffffc02013d6:	e4e58593          	addi	a1,a1,-434 # ffffffffc0205220 <commands+0xe10>
ffffffffc02013da:	10000513          	li	a0,256
ffffffffc02013de:	1b9020ef          	jal	ra,ffffffffc0203d96 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc02013e2:	100b8593          	addi	a1,s7,256
ffffffffc02013e6:	10000513          	li	a0,256
ffffffffc02013ea:	1bf020ef          	jal	ra,ffffffffc0203da8 <strcmp>
ffffffffc02013ee:	4a051663          	bnez	a0,ffffffffc020189a <pmm_init+0x920>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02013f2:	00093683          	ld	a3,0(s2)
ffffffffc02013f6:	000abc83          	ld	s9,0(s5)
ffffffffc02013fa:	00080c37          	lui	s8,0x80
ffffffffc02013fe:	40da06b3          	sub	a3,s4,a3
ffffffffc0201402:	868d                	srai	a3,a3,0x3
ffffffffc0201404:	039686b3          	mul	a3,a3,s9
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201408:	5afd                	li	s5,-1
ffffffffc020140a:	609c                	ld	a5,0(s1)
ffffffffc020140c:	00cada93          	srli	s5,s5,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201410:	96e2                	add	a3,a3,s8
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201412:	0156f733          	and	a4,a3,s5
    return page2ppn(page) << PGSHIFT;
ffffffffc0201416:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201418:	16f77363          	bgeu	a4,a5,ffffffffc020157e <pmm_init+0x604>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc020141c:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0201420:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0201424:	96be                	add	a3,a3,a5
ffffffffc0201426:	10068023          	sb	zero,256(a3) # fffffffffffff100 <end+0x3fdedb60>
    assert(strlen((const char *)0x100) == 0);
ffffffffc020142a:	129020ef          	jal	ra,ffffffffc0203d52 <strlen>
ffffffffc020142e:	44051663          	bnez	a0,ffffffffc020187a <pmm_init+0x900>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0201432:	00043b83          	ld	s7,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0201436:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201438:	000bb783          	ld	a5,0(s7)
ffffffffc020143c:	078a                	slli	a5,a5,0x2
ffffffffc020143e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201440:	12e7fd63          	bgeu	a5,a4,ffffffffc020157a <pmm_init+0x600>
    return &pages[PPN(pa) - nbase];
ffffffffc0201444:	418787b3          	sub	a5,a5,s8
ffffffffc0201448:	00379693          	slli	a3,a5,0x3
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020144c:	96be                	add	a3,a3,a5
ffffffffc020144e:	039686b3          	mul	a3,a3,s9
ffffffffc0201452:	96e2                	add	a3,a3,s8
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201454:	0156fab3          	and	s5,a3,s5
    return page2ppn(page) << PGSHIFT;
ffffffffc0201458:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020145a:	12eaf263          	bgeu	s5,a4,ffffffffc020157e <pmm_init+0x604>
ffffffffc020145e:	0009b983          	ld	s3,0(s3)
    free_page(p);
ffffffffc0201462:	4585                	li	a1,1
ffffffffc0201464:	8552                	mv	a0,s4
ffffffffc0201466:	99b6                	add	s3,s3,a3
ffffffffc0201468:	eecff0ef          	jal	ra,ffffffffc0200b54 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc020146c:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc0201470:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201472:	078a                	slli	a5,a5,0x2
ffffffffc0201474:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201476:	10e7f263          	bgeu	a5,a4,ffffffffc020157a <pmm_init+0x600>
    return &pages[PPN(pa) - nbase];
ffffffffc020147a:	fff809b7          	lui	s3,0xfff80
ffffffffc020147e:	97ce                	add	a5,a5,s3
ffffffffc0201480:	00379513          	slli	a0,a5,0x3
ffffffffc0201484:	00093703          	ld	a4,0(s2)
ffffffffc0201488:	97aa                	add	a5,a5,a0
ffffffffc020148a:	00379513          	slli	a0,a5,0x3
    free_page(pde2page(pd0[0]));
ffffffffc020148e:	953a                	add	a0,a0,a4
ffffffffc0201490:	4585                	li	a1,1
ffffffffc0201492:	ec2ff0ef          	jal	ra,ffffffffc0200b54 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0201496:	000bb503          	ld	a0,0(s7)
    if (PPN(pa) >= npage) {
ffffffffc020149a:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020149c:	050a                	slli	a0,a0,0x2
ffffffffc020149e:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc02014a0:	0cf57d63          	bgeu	a0,a5,ffffffffc020157a <pmm_init+0x600>
    return &pages[PPN(pa) - nbase];
ffffffffc02014a4:	013507b3          	add	a5,a0,s3
ffffffffc02014a8:	00379513          	slli	a0,a5,0x3
ffffffffc02014ac:	00093703          	ld	a4,0(s2)
ffffffffc02014b0:	953e                	add	a0,a0,a5
ffffffffc02014b2:	050e                	slli	a0,a0,0x3
    free_page(pde2page(pd1[0]));
ffffffffc02014b4:	4585                	li	a1,1
ffffffffc02014b6:	953a                	add	a0,a0,a4
ffffffffc02014b8:	e9cff0ef          	jal	ra,ffffffffc0200b54 <free_pages>
    boot_pgdir[0] = 0;
ffffffffc02014bc:	601c                	ld	a5,0(s0)
ffffffffc02014be:	0007b023          	sd	zero,0(a5) # ffffffffc0200000 <kern_entry>

    assert(nr_free_store==nr_free_pages());
ffffffffc02014c2:	ed8ff0ef          	jal	ra,ffffffffc0200b9a <nr_free_pages>
ffffffffc02014c6:	38ab1a63          	bne	s6,a0,ffffffffc020185a <pmm_init+0x8e0>
}
ffffffffc02014ca:	6446                	ld	s0,80(sp)
ffffffffc02014cc:	60e6                	ld	ra,88(sp)
ffffffffc02014ce:	64a6                	ld	s1,72(sp)
ffffffffc02014d0:	6906                	ld	s2,64(sp)
ffffffffc02014d2:	79e2                	ld	s3,56(sp)
ffffffffc02014d4:	7a42                	ld	s4,48(sp)
ffffffffc02014d6:	7aa2                	ld	s5,40(sp)
ffffffffc02014d8:	7b02                	ld	s6,32(sp)
ffffffffc02014da:	6be2                	ld	s7,24(sp)
ffffffffc02014dc:	6c42                	ld	s8,16(sp)
ffffffffc02014de:	6ca2                	ld	s9,8(sp)

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc02014e0:	00004517          	auipc	a0,0x4
ffffffffc02014e4:	db850513          	addi	a0,a0,-584 # ffffffffc0205298 <commands+0xe88>
}
ffffffffc02014e8:	6125                	addi	sp,sp,96
    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc02014ea:	bd5fe06f          	j	ffffffffc02000be <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02014ee:	6705                	lui	a4,0x1
ffffffffc02014f0:	177d                	addi	a4,a4,-1
ffffffffc02014f2:	96ba                	add	a3,a3,a4
    if (PPN(pa) >= npage) {
ffffffffc02014f4:	00c6d713          	srli	a4,a3,0xc
ffffffffc02014f8:	08f77163          	bgeu	a4,a5,ffffffffc020157a <pmm_init+0x600>
    pmm_manager->init_memmap(base, n);
ffffffffc02014fc:	00043803          	ld	a6,0(s0)
    return &pages[PPN(pa) - nbase];
ffffffffc0201500:	9732                	add	a4,a4,a2
ffffffffc0201502:	00371793          	slli	a5,a4,0x3
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0201506:	767d                	lui	a2,0xfffff
ffffffffc0201508:	8ef1                	and	a3,a3,a2
ffffffffc020150a:	97ba                	add	a5,a5,a4
    pmm_manager->init_memmap(base, n);
ffffffffc020150c:	01083703          	ld	a4,16(a6)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0201510:	8d95                	sub	a1,a1,a3
ffffffffc0201512:	078e                	slli	a5,a5,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0201514:	81b1                	srli	a1,a1,0xc
ffffffffc0201516:	953e                	add	a0,a0,a5
ffffffffc0201518:	9702                	jalr	a4
ffffffffc020151a:	bebd                	j	ffffffffc0201098 <pmm_init+0x11e>
ffffffffc020151c:	6008                	ld	a0,0(s0)
ffffffffc020151e:	b5b5                	j	ffffffffc020138a <pmm_init+0x410>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201520:	86d2                	mv	a3,s4
ffffffffc0201522:	00003617          	auipc	a2,0x3
ffffffffc0201526:	72e60613          	addi	a2,a2,1838 # ffffffffc0204c50 <commands+0x840>
ffffffffc020152a:	1cd00593          	li	a1,461
ffffffffc020152e:	00003517          	auipc	a0,0x3
ffffffffc0201532:	74a50513          	addi	a0,a0,1866 # ffffffffc0204c78 <commands+0x868>
ffffffffc0201536:	bcffe0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc020153a:	00004697          	auipc	a3,0x4
ffffffffc020153e:	bce68693          	addi	a3,a3,-1074 # ffffffffc0205108 <commands+0xcf8>
ffffffffc0201542:	00004617          	auipc	a2,0x4
ffffffffc0201546:	8be60613          	addi	a2,a2,-1858 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc020154a:	1cd00593          	li	a1,461
ffffffffc020154e:	00003517          	auipc	a0,0x3
ffffffffc0201552:	72a50513          	addi	a0,a0,1834 # ffffffffc0204c78 <commands+0x868>
ffffffffc0201556:	baffe0ef          	jal	ra,ffffffffc0200104 <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc020155a:	00004697          	auipc	a3,0x4
ffffffffc020155e:	bee68693          	addi	a3,a3,-1042 # ffffffffc0205148 <commands+0xd38>
ffffffffc0201562:	00004617          	auipc	a2,0x4
ffffffffc0201566:	89e60613          	addi	a2,a2,-1890 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc020156a:	1ce00593          	li	a1,462
ffffffffc020156e:	00003517          	auipc	a0,0x3
ffffffffc0201572:	70a50513          	addi	a0,a0,1802 # ffffffffc0204c78 <commands+0x868>
ffffffffc0201576:	b8ffe0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc020157a:	d36ff0ef          	jal	ra,ffffffffc0200ab0 <pa2page.part.4>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020157e:	00003617          	auipc	a2,0x3
ffffffffc0201582:	6d260613          	addi	a2,a2,1746 # ffffffffc0204c50 <commands+0x840>
ffffffffc0201586:	06a00593          	li	a1,106
ffffffffc020158a:	00003517          	auipc	a0,0x3
ffffffffc020158e:	75e50513          	addi	a0,a0,1886 # ffffffffc0204ce8 <commands+0x8d8>
ffffffffc0201592:	b73fe0ef          	jal	ra,ffffffffc0200104 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0201596:	00004617          	auipc	a2,0x4
ffffffffc020159a:	94260613          	addi	a2,a2,-1726 # ffffffffc0204ed8 <commands+0xac8>
ffffffffc020159e:	07000593          	li	a1,112
ffffffffc02015a2:	00003517          	auipc	a0,0x3
ffffffffc02015a6:	74650513          	addi	a0,a0,1862 # ffffffffc0204ce8 <commands+0x8d8>
ffffffffc02015aa:	b5bfe0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc02015ae:	00004697          	auipc	a3,0x4
ffffffffc02015b2:	86a68693          	addi	a3,a3,-1942 # ffffffffc0204e18 <commands+0xa08>
ffffffffc02015b6:	00004617          	auipc	a2,0x4
ffffffffc02015ba:	84a60613          	addi	a2,a2,-1974 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc02015be:	19300593          	li	a1,403
ffffffffc02015c2:	00003517          	auipc	a0,0x3
ffffffffc02015c6:	6b650513          	addi	a0,a0,1718 # ffffffffc0204c78 <commands+0x868>
ffffffffc02015ca:	b3bfe0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc02015ce:	00004697          	auipc	a3,0x4
ffffffffc02015d2:	88268693          	addi	a3,a3,-1918 # ffffffffc0204e50 <commands+0xa40>
ffffffffc02015d6:	00004617          	auipc	a2,0x4
ffffffffc02015da:	82a60613          	addi	a2,a2,-2006 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc02015de:	19400593          	li	a1,404
ffffffffc02015e2:	00003517          	auipc	a0,0x3
ffffffffc02015e6:	69650513          	addi	a0,a0,1686 # ffffffffc0204c78 <commands+0x868>
ffffffffc02015ea:	b1bfe0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc02015ee:	00004697          	auipc	a3,0x4
ffffffffc02015f2:	ada68693          	addi	a3,a3,-1318 # ffffffffc02050c8 <commands+0xcb8>
ffffffffc02015f6:	00004617          	auipc	a2,0x4
ffffffffc02015fa:	80a60613          	addi	a2,a2,-2038 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc02015fe:	1c000593          	li	a1,448
ffffffffc0201602:	00003517          	auipc	a0,0x3
ffffffffc0201606:	67650513          	addi	a0,a0,1654 # ffffffffc0204c78 <commands+0x868>
ffffffffc020160a:	afbfe0ef          	jal	ra,ffffffffc0200104 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020160e:	00003617          	auipc	a2,0x3
ffffffffc0201612:	78a60613          	addi	a2,a2,1930 # ffffffffc0204d98 <commands+0x988>
ffffffffc0201616:	07700593          	li	a1,119
ffffffffc020161a:	00003517          	auipc	a0,0x3
ffffffffc020161e:	65e50513          	addi	a0,a0,1630 # ffffffffc0204c78 <commands+0x868>
ffffffffc0201622:	ae3fe0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0201626:	00004697          	auipc	a3,0x4
ffffffffc020162a:	88268693          	addi	a3,a3,-1918 # ffffffffc0204ea8 <commands+0xa98>
ffffffffc020162e:	00003617          	auipc	a2,0x3
ffffffffc0201632:	7d260613          	addi	a2,a2,2002 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc0201636:	19a00593          	li	a1,410
ffffffffc020163a:	00003517          	auipc	a0,0x3
ffffffffc020163e:	63e50513          	addi	a0,a0,1598 # ffffffffc0204c78 <commands+0x868>
ffffffffc0201642:	ac3fe0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0201646:	00004697          	auipc	a3,0x4
ffffffffc020164a:	83268693          	addi	a3,a3,-1998 # ffffffffc0204e78 <commands+0xa68>
ffffffffc020164e:	00003617          	auipc	a2,0x3
ffffffffc0201652:	7b260613          	addi	a2,a2,1970 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc0201656:	19800593          	li	a1,408
ffffffffc020165a:	00003517          	auipc	a0,0x3
ffffffffc020165e:	61e50513          	addi	a0,a0,1566 # ffffffffc0204c78 <commands+0x868>
ffffffffc0201662:	aa3fe0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert(*ptep & PTE_U);
ffffffffc0201666:	00004697          	auipc	a3,0x4
ffffffffc020166a:	95a68693          	addi	a3,a3,-1702 # ffffffffc0204fc0 <commands+0xbb0>
ffffffffc020166e:	00003617          	auipc	a2,0x3
ffffffffc0201672:	79260613          	addi	a2,a2,1938 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc0201676:	1a500593          	li	a1,421
ffffffffc020167a:	00003517          	auipc	a0,0x3
ffffffffc020167e:	5fe50513          	addi	a0,a0,1534 # ffffffffc0204c78 <commands+0x868>
ffffffffc0201682:	a83fe0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201686:	00004697          	auipc	a3,0x4
ffffffffc020168a:	90a68693          	addi	a3,a3,-1782 # ffffffffc0204f90 <commands+0xb80>
ffffffffc020168e:	00003617          	auipc	a2,0x3
ffffffffc0201692:	77260613          	addi	a2,a2,1906 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc0201696:	1a400593          	li	a1,420
ffffffffc020169a:	00003517          	auipc	a0,0x3
ffffffffc020169e:	5de50513          	addi	a0,a0,1502 # ffffffffc0204c78 <commands+0x868>
ffffffffc02016a2:	a63fe0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc02016a6:	00004697          	auipc	a3,0x4
ffffffffc02016aa:	8b268693          	addi	a3,a3,-1870 # ffffffffc0204f58 <commands+0xb48>
ffffffffc02016ae:	00003617          	auipc	a2,0x3
ffffffffc02016b2:	75260613          	addi	a2,a2,1874 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc02016b6:	1a300593          	li	a1,419
ffffffffc02016ba:	00003517          	auipc	a0,0x3
ffffffffc02016be:	5be50513          	addi	a0,a0,1470 # ffffffffc0204c78 <commands+0x868>
ffffffffc02016c2:	a43fe0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02016c6:	00004697          	auipc	a3,0x4
ffffffffc02016ca:	86a68693          	addi	a3,a3,-1942 # ffffffffc0204f30 <commands+0xb20>
ffffffffc02016ce:	00003617          	auipc	a2,0x3
ffffffffc02016d2:	73260613          	addi	a2,a2,1842 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc02016d6:	1a000593          	li	a1,416
ffffffffc02016da:	00003517          	auipc	a0,0x3
ffffffffc02016de:	59e50513          	addi	a0,a0,1438 # ffffffffc0204c78 <commands+0x868>
ffffffffc02016e2:	a23fe0ef          	jal	ra,ffffffffc0200104 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02016e6:	86da                	mv	a3,s6
ffffffffc02016e8:	00003617          	auipc	a2,0x3
ffffffffc02016ec:	56860613          	addi	a2,a2,1384 # ffffffffc0204c50 <commands+0x840>
ffffffffc02016f0:	19f00593          	li	a1,415
ffffffffc02016f4:	00003517          	auipc	a0,0x3
ffffffffc02016f8:	58450513          	addi	a0,a0,1412 # ffffffffc0204c78 <commands+0x868>
ffffffffc02016fc:	a09fe0ef          	jal	ra,ffffffffc0200104 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0201700:	86be                	mv	a3,a5
ffffffffc0201702:	00003617          	auipc	a2,0x3
ffffffffc0201706:	54e60613          	addi	a2,a2,1358 # ffffffffc0204c50 <commands+0x840>
ffffffffc020170a:	19e00593          	li	a1,414
ffffffffc020170e:	00003517          	auipc	a0,0x3
ffffffffc0201712:	56a50513          	addi	a0,a0,1386 # ffffffffc0204c78 <commands+0x868>
ffffffffc0201716:	9effe0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc020171a:	00003697          	auipc	a3,0x3
ffffffffc020171e:	7fe68693          	addi	a3,a3,2046 # ffffffffc0204f18 <commands+0xb08>
ffffffffc0201722:	00003617          	auipc	a2,0x3
ffffffffc0201726:	6de60613          	addi	a2,a2,1758 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc020172a:	19c00593          	li	a1,412
ffffffffc020172e:	00003517          	auipc	a0,0x3
ffffffffc0201732:	54a50513          	addi	a0,a0,1354 # ffffffffc0204c78 <commands+0x868>
ffffffffc0201736:	9cffe0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc020173a:	00003697          	auipc	a3,0x3
ffffffffc020173e:	7c668693          	addi	a3,a3,1990 # ffffffffc0204f00 <commands+0xaf0>
ffffffffc0201742:	00003617          	auipc	a2,0x3
ffffffffc0201746:	6be60613          	addi	a2,a2,1726 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc020174a:	19b00593          	li	a1,411
ffffffffc020174e:	00003517          	auipc	a0,0x3
ffffffffc0201752:	52a50513          	addi	a0,a0,1322 # ffffffffc0204c78 <commands+0x868>
ffffffffc0201756:	9affe0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc020175a:	00003697          	auipc	a3,0x3
ffffffffc020175e:	7a668693          	addi	a3,a3,1958 # ffffffffc0204f00 <commands+0xaf0>
ffffffffc0201762:	00003617          	auipc	a2,0x3
ffffffffc0201766:	69e60613          	addi	a2,a2,1694 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc020176a:	1ae00593          	li	a1,430
ffffffffc020176e:	00003517          	auipc	a0,0x3
ffffffffc0201772:	50a50513          	addi	a0,a0,1290 # ffffffffc0204c78 <commands+0x868>
ffffffffc0201776:	98ffe0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc020177a:	00004697          	auipc	a3,0x4
ffffffffc020177e:	81668693          	addi	a3,a3,-2026 # ffffffffc0204f90 <commands+0xb80>
ffffffffc0201782:	00003617          	auipc	a2,0x3
ffffffffc0201786:	67e60613          	addi	a2,a2,1662 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc020178a:	1ad00593          	li	a1,429
ffffffffc020178e:	00003517          	auipc	a0,0x3
ffffffffc0201792:	4ea50513          	addi	a0,a0,1258 # ffffffffc0204c78 <commands+0x868>
ffffffffc0201796:	96ffe0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc020179a:	00004697          	auipc	a3,0x4
ffffffffc020179e:	8be68693          	addi	a3,a3,-1858 # ffffffffc0205058 <commands+0xc48>
ffffffffc02017a2:	00003617          	auipc	a2,0x3
ffffffffc02017a6:	65e60613          	addi	a2,a2,1630 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc02017aa:	1ac00593          	li	a1,428
ffffffffc02017ae:	00003517          	auipc	a0,0x3
ffffffffc02017b2:	4ca50513          	addi	a0,a0,1226 # ffffffffc0204c78 <commands+0x868>
ffffffffc02017b6:	94ffe0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc02017ba:	00004697          	auipc	a3,0x4
ffffffffc02017be:	88668693          	addi	a3,a3,-1914 # ffffffffc0205040 <commands+0xc30>
ffffffffc02017c2:	00003617          	auipc	a2,0x3
ffffffffc02017c6:	63e60613          	addi	a2,a2,1598 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc02017ca:	1ab00593          	li	a1,427
ffffffffc02017ce:	00003517          	auipc	a0,0x3
ffffffffc02017d2:	4aa50513          	addi	a0,a0,1194 # ffffffffc0204c78 <commands+0x868>
ffffffffc02017d6:	92ffe0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc02017da:	00004697          	auipc	a3,0x4
ffffffffc02017de:	83668693          	addi	a3,a3,-1994 # ffffffffc0205010 <commands+0xc00>
ffffffffc02017e2:	00003617          	auipc	a2,0x3
ffffffffc02017e6:	61e60613          	addi	a2,a2,1566 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc02017ea:	1aa00593          	li	a1,426
ffffffffc02017ee:	00003517          	auipc	a0,0x3
ffffffffc02017f2:	48a50513          	addi	a0,a0,1162 # ffffffffc0204c78 <commands+0x868>
ffffffffc02017f6:	90ffe0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc02017fa:	00003697          	auipc	a3,0x3
ffffffffc02017fe:	7fe68693          	addi	a3,a3,2046 # ffffffffc0204ff8 <commands+0xbe8>
ffffffffc0201802:	00003617          	auipc	a2,0x3
ffffffffc0201806:	5fe60613          	addi	a2,a2,1534 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc020180a:	1a800593          	li	a1,424
ffffffffc020180e:	00003517          	auipc	a0,0x3
ffffffffc0201812:	46a50513          	addi	a0,a0,1130 # ffffffffc0204c78 <commands+0x868>
ffffffffc0201816:	8effe0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc020181a:	00003697          	auipc	a3,0x3
ffffffffc020181e:	7c668693          	addi	a3,a3,1990 # ffffffffc0204fe0 <commands+0xbd0>
ffffffffc0201822:	00003617          	auipc	a2,0x3
ffffffffc0201826:	5de60613          	addi	a2,a2,1502 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc020182a:	1a700593          	li	a1,423
ffffffffc020182e:	00003517          	auipc	a0,0x3
ffffffffc0201832:	44a50513          	addi	a0,a0,1098 # ffffffffc0204c78 <commands+0x868>
ffffffffc0201836:	8cffe0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert(*ptep & PTE_W);
ffffffffc020183a:	00003697          	auipc	a3,0x3
ffffffffc020183e:	79668693          	addi	a3,a3,1942 # ffffffffc0204fd0 <commands+0xbc0>
ffffffffc0201842:	00003617          	auipc	a2,0x3
ffffffffc0201846:	5be60613          	addi	a2,a2,1470 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc020184a:	1a600593          	li	a1,422
ffffffffc020184e:	00003517          	auipc	a0,0x3
ffffffffc0201852:	42a50513          	addi	a0,a0,1066 # ffffffffc0204c78 <commands+0x868>
ffffffffc0201856:	8affe0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc020185a:	00004697          	auipc	a3,0x4
ffffffffc020185e:	86e68693          	addi	a3,a3,-1938 # ffffffffc02050c8 <commands+0xcb8>
ffffffffc0201862:	00003617          	auipc	a2,0x3
ffffffffc0201866:	59e60613          	addi	a2,a2,1438 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc020186a:	1e800593          	li	a1,488
ffffffffc020186e:	00003517          	auipc	a0,0x3
ffffffffc0201872:	40a50513          	addi	a0,a0,1034 # ffffffffc0204c78 <commands+0x868>
ffffffffc0201876:	88ffe0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc020187a:	00004697          	auipc	a3,0x4
ffffffffc020187e:	9f668693          	addi	a3,a3,-1546 # ffffffffc0205270 <commands+0xe60>
ffffffffc0201882:	00003617          	auipc	a2,0x3
ffffffffc0201886:	57e60613          	addi	a2,a2,1406 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc020188a:	1e000593          	li	a1,480
ffffffffc020188e:	00003517          	auipc	a0,0x3
ffffffffc0201892:	3ea50513          	addi	a0,a0,1002 # ffffffffc0204c78 <commands+0x868>
ffffffffc0201896:	86ffe0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc020189a:	00004697          	auipc	a3,0x4
ffffffffc020189e:	99e68693          	addi	a3,a3,-1634 # ffffffffc0205238 <commands+0xe28>
ffffffffc02018a2:	00003617          	auipc	a2,0x3
ffffffffc02018a6:	55e60613          	addi	a2,a2,1374 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc02018aa:	1dd00593          	li	a1,477
ffffffffc02018ae:	00003517          	auipc	a0,0x3
ffffffffc02018b2:	3ca50513          	addi	a0,a0,970 # ffffffffc0204c78 <commands+0x868>
ffffffffc02018b6:	84ffe0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert(page_ref(p) == 2);
ffffffffc02018ba:	00004697          	auipc	a3,0x4
ffffffffc02018be:	94e68693          	addi	a3,a3,-1714 # ffffffffc0205208 <commands+0xdf8>
ffffffffc02018c2:	00003617          	auipc	a2,0x3
ffffffffc02018c6:	53e60613          	addi	a2,a2,1342 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc02018ca:	1d900593          	li	a1,473
ffffffffc02018ce:	00003517          	auipc	a0,0x3
ffffffffc02018d2:	3aa50513          	addi	a0,a0,938 # ffffffffc0204c78 <commands+0x868>
ffffffffc02018d6:	82ffe0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc02018da:	00003697          	auipc	a3,0x3
ffffffffc02018de:	7ae68693          	addi	a3,a3,1966 # ffffffffc0205088 <commands+0xc78>
ffffffffc02018e2:	00003617          	auipc	a2,0x3
ffffffffc02018e6:	51e60613          	addi	a2,a2,1310 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc02018ea:	1b600593          	li	a1,438
ffffffffc02018ee:	00003517          	auipc	a0,0x3
ffffffffc02018f2:	38a50513          	addi	a0,a0,906 # ffffffffc0204c78 <commands+0x868>
ffffffffc02018f6:	80ffe0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02018fa:	00003697          	auipc	a3,0x3
ffffffffc02018fe:	75e68693          	addi	a3,a3,1886 # ffffffffc0205058 <commands+0xc48>
ffffffffc0201902:	00003617          	auipc	a2,0x3
ffffffffc0201906:	4fe60613          	addi	a2,a2,1278 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc020190a:	1b300593          	li	a1,435
ffffffffc020190e:	00003517          	auipc	a0,0x3
ffffffffc0201912:	36a50513          	addi	a0,a0,874 # ffffffffc0204c78 <commands+0x868>
ffffffffc0201916:	feefe0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc020191a:	00003697          	auipc	a3,0x3
ffffffffc020191e:	5fe68693          	addi	a3,a3,1534 # ffffffffc0204f18 <commands+0xb08>
ffffffffc0201922:	00003617          	auipc	a2,0x3
ffffffffc0201926:	4de60613          	addi	a2,a2,1246 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc020192a:	1b200593          	li	a1,434
ffffffffc020192e:	00003517          	auipc	a0,0x3
ffffffffc0201932:	34a50513          	addi	a0,a0,842 # ffffffffc0204c78 <commands+0x868>
ffffffffc0201936:	fcefe0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc020193a:	00003697          	auipc	a3,0x3
ffffffffc020193e:	73668693          	addi	a3,a3,1846 # ffffffffc0205070 <commands+0xc60>
ffffffffc0201942:	00003617          	auipc	a2,0x3
ffffffffc0201946:	4be60613          	addi	a2,a2,1214 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc020194a:	1af00593          	li	a1,431
ffffffffc020194e:	00003517          	auipc	a0,0x3
ffffffffc0201952:	32a50513          	addi	a0,a0,810 # ffffffffc0204c78 <commands+0x868>
ffffffffc0201956:	faefe0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc020195a:	00003697          	auipc	a3,0x3
ffffffffc020195e:	74668693          	addi	a3,a3,1862 # ffffffffc02050a0 <commands+0xc90>
ffffffffc0201962:	00003617          	auipc	a2,0x3
ffffffffc0201966:	49e60613          	addi	a2,a2,1182 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc020196a:	1b900593          	li	a1,441
ffffffffc020196e:	00003517          	auipc	a0,0x3
ffffffffc0201972:	30a50513          	addi	a0,a0,778 # ffffffffc0204c78 <commands+0x868>
ffffffffc0201976:	f8efe0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc020197a:	00003697          	auipc	a3,0x3
ffffffffc020197e:	6de68693          	addi	a3,a3,1758 # ffffffffc0205058 <commands+0xc48>
ffffffffc0201982:	00003617          	auipc	a2,0x3
ffffffffc0201986:	47e60613          	addi	a2,a2,1150 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc020198a:	1b700593          	li	a1,439
ffffffffc020198e:	00003517          	auipc	a0,0x3
ffffffffc0201992:	2ea50513          	addi	a0,a0,746 # ffffffffc0204c78 <commands+0x868>
ffffffffc0201996:	f6efe0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc020199a:	00003697          	auipc	a3,0x3
ffffffffc020199e:	44668693          	addi	a3,a3,1094 # ffffffffc0204de0 <commands+0x9d0>
ffffffffc02019a2:	00003617          	auipc	a2,0x3
ffffffffc02019a6:	45e60613          	addi	a2,a2,1118 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc02019aa:	19200593          	li	a1,402
ffffffffc02019ae:	00003517          	auipc	a0,0x3
ffffffffc02019b2:	2ca50513          	addi	a0,a0,714 # ffffffffc0204c78 <commands+0x868>
ffffffffc02019b6:	f4efe0ef          	jal	ra,ffffffffc0200104 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc02019ba:	00003617          	auipc	a2,0x3
ffffffffc02019be:	3de60613          	addi	a2,a2,990 # ffffffffc0204d98 <commands+0x988>
ffffffffc02019c2:	0bd00593          	li	a1,189
ffffffffc02019c6:	00003517          	auipc	a0,0x3
ffffffffc02019ca:	2b250513          	addi	a0,a0,690 # ffffffffc0204c78 <commands+0x868>
ffffffffc02019ce:	f36fe0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc02019d2:	00003697          	auipc	a3,0x3
ffffffffc02019d6:	7f668693          	addi	a3,a3,2038 # ffffffffc02051c8 <commands+0xdb8>
ffffffffc02019da:	00003617          	auipc	a2,0x3
ffffffffc02019de:	42660613          	addi	a2,a2,1062 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc02019e2:	1d800593          	li	a1,472
ffffffffc02019e6:	00003517          	auipc	a0,0x3
ffffffffc02019ea:	29250513          	addi	a0,a0,658 # ffffffffc0204c78 <commands+0x868>
ffffffffc02019ee:	f16fe0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert(page_ref(p) == 1);
ffffffffc02019f2:	00003697          	auipc	a3,0x3
ffffffffc02019f6:	7be68693          	addi	a3,a3,1982 # ffffffffc02051b0 <commands+0xda0>
ffffffffc02019fa:	00003617          	auipc	a2,0x3
ffffffffc02019fe:	40660613          	addi	a2,a2,1030 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc0201a02:	1d700593          	li	a1,471
ffffffffc0201a06:	00003517          	auipc	a0,0x3
ffffffffc0201a0a:	27250513          	addi	a0,a0,626 # ffffffffc0204c78 <commands+0x868>
ffffffffc0201a0e:	ef6fe0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0201a12:	00003697          	auipc	a3,0x3
ffffffffc0201a16:	76668693          	addi	a3,a3,1894 # ffffffffc0205178 <commands+0xd68>
ffffffffc0201a1a:	00003617          	auipc	a2,0x3
ffffffffc0201a1e:	3e660613          	addi	a2,a2,998 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc0201a22:	1d600593          	li	a1,470
ffffffffc0201a26:	00003517          	auipc	a0,0x3
ffffffffc0201a2a:	25250513          	addi	a0,a0,594 # ffffffffc0204c78 <commands+0x868>
ffffffffc0201a2e:	ed6fe0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc0201a32:	00003697          	auipc	a3,0x3
ffffffffc0201a36:	72e68693          	addi	a3,a3,1838 # ffffffffc0205160 <commands+0xd50>
ffffffffc0201a3a:	00003617          	auipc	a2,0x3
ffffffffc0201a3e:	3c660613          	addi	a2,a2,966 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc0201a42:	1d200593          	li	a1,466
ffffffffc0201a46:	00003517          	auipc	a0,0x3
ffffffffc0201a4a:	23250513          	addi	a0,a0,562 # ffffffffc0204c78 <commands+0x868>
ffffffffc0201a4e:	eb6fe0ef          	jal	ra,ffffffffc0200104 <__panic>

ffffffffc0201a52 <tlb_invalidate>:
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0201a52:	12000073          	sfence.vma
void tlb_invalidate(pde_t *pgdir, uintptr_t la) { flush_tlb(); }
ffffffffc0201a56:	8082                	ret

ffffffffc0201a58 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0201a58:	7179                	addi	sp,sp,-48
ffffffffc0201a5a:	e84a                	sd	s2,16(sp)
ffffffffc0201a5c:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc0201a5e:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0201a60:	f022                	sd	s0,32(sp)
ffffffffc0201a62:	ec26                	sd	s1,24(sp)
ffffffffc0201a64:	e44e                	sd	s3,8(sp)
ffffffffc0201a66:	f406                	sd	ra,40(sp)
ffffffffc0201a68:	84ae                	mv	s1,a1
ffffffffc0201a6a:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc0201a6c:	860ff0ef          	jal	ra,ffffffffc0200acc <alloc_pages>
ffffffffc0201a70:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc0201a72:	cd19                	beqz	a0,ffffffffc0201a90 <pgdir_alloc_page+0x38>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc0201a74:	85aa                	mv	a1,a0
ffffffffc0201a76:	86ce                	mv	a3,s3
ffffffffc0201a78:	8626                	mv	a2,s1
ffffffffc0201a7a:	854a                	mv	a0,s2
ffffffffc0201a7c:	c2cff0ef          	jal	ra,ffffffffc0200ea8 <page_insert>
ffffffffc0201a80:	ed39                	bnez	a0,ffffffffc0201ade <pgdir_alloc_page+0x86>
        if (swap_init_ok) {
ffffffffc0201a82:	00010797          	auipc	a5,0x10
ffffffffc0201a86:	9ee78793          	addi	a5,a5,-1554 # ffffffffc0211470 <swap_init_ok>
ffffffffc0201a8a:	439c                	lw	a5,0(a5)
ffffffffc0201a8c:	2781                	sext.w	a5,a5
ffffffffc0201a8e:	eb89                	bnez	a5,ffffffffc0201aa0 <pgdir_alloc_page+0x48>
}
ffffffffc0201a90:	8522                	mv	a0,s0
ffffffffc0201a92:	70a2                	ld	ra,40(sp)
ffffffffc0201a94:	7402                	ld	s0,32(sp)
ffffffffc0201a96:	64e2                	ld	s1,24(sp)
ffffffffc0201a98:	6942                	ld	s2,16(sp)
ffffffffc0201a9a:	69a2                	ld	s3,8(sp)
ffffffffc0201a9c:	6145                	addi	sp,sp,48
ffffffffc0201a9e:	8082                	ret
            swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0201aa0:	00010797          	auipc	a5,0x10
ffffffffc0201aa4:	a0078793          	addi	a5,a5,-1536 # ffffffffc02114a0 <check_mm_struct>
ffffffffc0201aa8:	6388                	ld	a0,0(a5)
ffffffffc0201aaa:	4681                	li	a3,0
ffffffffc0201aac:	8622                	mv	a2,s0
ffffffffc0201aae:	85a6                	mv	a1,s1
ffffffffc0201ab0:	07e010ef          	jal	ra,ffffffffc0202b2e <swap_map_swappable>
            assert(page_ref(page) == 1);
ffffffffc0201ab4:	4018                	lw	a4,0(s0)
            page->pra_vaddr = la;
ffffffffc0201ab6:	e024                	sd	s1,64(s0)
            assert(page_ref(page) == 1);
ffffffffc0201ab8:	4785                	li	a5,1
ffffffffc0201aba:	fcf70be3          	beq	a4,a5,ffffffffc0201a90 <pgdir_alloc_page+0x38>
ffffffffc0201abe:	00003697          	auipc	a3,0x3
ffffffffc0201ac2:	23a68693          	addi	a3,a3,570 # ffffffffc0204cf8 <commands+0x8e8>
ffffffffc0201ac6:	00003617          	auipc	a2,0x3
ffffffffc0201aca:	33a60613          	addi	a2,a2,826 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc0201ace:	17a00593          	li	a1,378
ffffffffc0201ad2:	00003517          	auipc	a0,0x3
ffffffffc0201ad6:	1a650513          	addi	a0,a0,422 # ffffffffc0204c78 <commands+0x868>
ffffffffc0201ada:	e2afe0ef          	jal	ra,ffffffffc0200104 <__panic>
            free_page(page);
ffffffffc0201ade:	8522                	mv	a0,s0
ffffffffc0201ae0:	4585                	li	a1,1
ffffffffc0201ae2:	872ff0ef          	jal	ra,ffffffffc0200b54 <free_pages>
            return NULL;
ffffffffc0201ae6:	4401                	li	s0,0
ffffffffc0201ae8:	b765                	j	ffffffffc0201a90 <pgdir_alloc_page+0x38>

ffffffffc0201aea <kmalloc>:
}

void *kmalloc(size_t n) {
ffffffffc0201aea:	1141                	addi	sp,sp,-16
    void *ptr = NULL;
    struct Page *base = NULL;
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0201aec:	67d5                	lui	a5,0x15
void *kmalloc(size_t n) {
ffffffffc0201aee:	e406                	sd	ra,8(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0201af0:	fff50713          	addi	a4,a0,-1
ffffffffc0201af4:	17f9                	addi	a5,a5,-2
ffffffffc0201af6:	04e7ee63          	bltu	a5,a4,ffffffffc0201b52 <kmalloc+0x68>
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc0201afa:	6785                	lui	a5,0x1
ffffffffc0201afc:	17fd                	addi	a5,a5,-1
ffffffffc0201afe:	953e                	add	a0,a0,a5
    base = alloc_pages(num_pages);
ffffffffc0201b00:	8131                	srli	a0,a0,0xc
ffffffffc0201b02:	fcbfe0ef          	jal	ra,ffffffffc0200acc <alloc_pages>
    assert(base != NULL);
ffffffffc0201b06:	c159                	beqz	a0,ffffffffc0201b8c <kmalloc+0xa2>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201b08:	00010797          	auipc	a5,0x10
ffffffffc0201b0c:	99078793          	addi	a5,a5,-1648 # ffffffffc0211498 <pages>
ffffffffc0201b10:	639c                	ld	a5,0(a5)
ffffffffc0201b12:	8d1d                	sub	a0,a0,a5
ffffffffc0201b14:	00003797          	auipc	a5,0x3
ffffffffc0201b18:	13478793          	addi	a5,a5,308 # ffffffffc0204c48 <commands+0x838>
ffffffffc0201b1c:	6394                	ld	a3,0(a5)
ffffffffc0201b1e:	850d                	srai	a0,a0,0x3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201b20:	00010797          	auipc	a5,0x10
ffffffffc0201b24:	93878793          	addi	a5,a5,-1736 # ffffffffc0211458 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201b28:	02d50533          	mul	a0,a0,a3
ffffffffc0201b2c:	000806b7          	lui	a3,0x80
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201b30:	6398                	ld	a4,0(a5)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201b32:	9536                	add	a0,a0,a3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201b34:	00c51793          	slli	a5,a0,0xc
ffffffffc0201b38:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201b3a:	0532                	slli	a0,a0,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201b3c:	02e7fb63          	bgeu	a5,a4,ffffffffc0201b72 <kmalloc+0x88>
ffffffffc0201b40:	00010797          	auipc	a5,0x10
ffffffffc0201b44:	94878793          	addi	a5,a5,-1720 # ffffffffc0211488 <va_pa_offset>
ffffffffc0201b48:	639c                	ld	a5,0(a5)
    ptr = page2kva(base);
    return ptr;
}
ffffffffc0201b4a:	60a2                	ld	ra,8(sp)
ffffffffc0201b4c:	953e                	add	a0,a0,a5
ffffffffc0201b4e:	0141                	addi	sp,sp,16
ffffffffc0201b50:	8082                	ret
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0201b52:	00003697          	auipc	a3,0x3
ffffffffc0201b56:	14668693          	addi	a3,a3,326 # ffffffffc0204c98 <commands+0x888>
ffffffffc0201b5a:	00003617          	auipc	a2,0x3
ffffffffc0201b5e:	2a660613          	addi	a2,a2,678 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc0201b62:	1f000593          	li	a1,496
ffffffffc0201b66:	00003517          	auipc	a0,0x3
ffffffffc0201b6a:	11250513          	addi	a0,a0,274 # ffffffffc0204c78 <commands+0x868>
ffffffffc0201b6e:	d96fe0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0201b72:	86aa                	mv	a3,a0
ffffffffc0201b74:	00003617          	auipc	a2,0x3
ffffffffc0201b78:	0dc60613          	addi	a2,a2,220 # ffffffffc0204c50 <commands+0x840>
ffffffffc0201b7c:	06a00593          	li	a1,106
ffffffffc0201b80:	00003517          	auipc	a0,0x3
ffffffffc0201b84:	16850513          	addi	a0,a0,360 # ffffffffc0204ce8 <commands+0x8d8>
ffffffffc0201b88:	d7cfe0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert(base != NULL);
ffffffffc0201b8c:	00003697          	auipc	a3,0x3
ffffffffc0201b90:	12c68693          	addi	a3,a3,300 # ffffffffc0204cb8 <commands+0x8a8>
ffffffffc0201b94:	00003617          	auipc	a2,0x3
ffffffffc0201b98:	26c60613          	addi	a2,a2,620 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc0201b9c:	1f300593          	li	a1,499
ffffffffc0201ba0:	00003517          	auipc	a0,0x3
ffffffffc0201ba4:	0d850513          	addi	a0,a0,216 # ffffffffc0204c78 <commands+0x868>
ffffffffc0201ba8:	d5cfe0ef          	jal	ra,ffffffffc0200104 <__panic>

ffffffffc0201bac <kfree>:

void kfree(void *ptr, size_t n) {
ffffffffc0201bac:	1141                	addi	sp,sp,-16
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0201bae:	67d5                	lui	a5,0x15
void kfree(void *ptr, size_t n) {
ffffffffc0201bb0:	e406                	sd	ra,8(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0201bb2:	fff58713          	addi	a4,a1,-1
ffffffffc0201bb6:	17f9                	addi	a5,a5,-2
ffffffffc0201bb8:	04e7eb63          	bltu	a5,a4,ffffffffc0201c0e <kfree+0x62>
    assert(ptr != NULL);
ffffffffc0201bbc:	c941                	beqz	a0,ffffffffc0201c4c <kfree+0xa0>
    struct Page *base = NULL;
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc0201bbe:	6785                	lui	a5,0x1
ffffffffc0201bc0:	17fd                	addi	a5,a5,-1
ffffffffc0201bc2:	95be                	add	a1,a1,a5
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc0201bc4:	c02007b7          	lui	a5,0xc0200
ffffffffc0201bc8:	81b1                	srli	a1,a1,0xc
ffffffffc0201bca:	06f56463          	bltu	a0,a5,ffffffffc0201c32 <kfree+0x86>
ffffffffc0201bce:	00010797          	auipc	a5,0x10
ffffffffc0201bd2:	8ba78793          	addi	a5,a5,-1862 # ffffffffc0211488 <va_pa_offset>
ffffffffc0201bd6:	639c                	ld	a5,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0201bd8:	00010717          	auipc	a4,0x10
ffffffffc0201bdc:	88070713          	addi	a4,a4,-1920 # ffffffffc0211458 <npage>
ffffffffc0201be0:	6318                	ld	a4,0(a4)
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc0201be2:	40f507b3          	sub	a5,a0,a5
    if (PPN(pa) >= npage) {
ffffffffc0201be6:	83b1                	srli	a5,a5,0xc
ffffffffc0201be8:	04e7f363          	bgeu	a5,a4,ffffffffc0201c2e <kfree+0x82>
    return &pages[PPN(pa) - nbase];
ffffffffc0201bec:	fff80537          	lui	a0,0xfff80
ffffffffc0201bf0:	97aa                	add	a5,a5,a0
ffffffffc0201bf2:	00010697          	auipc	a3,0x10
ffffffffc0201bf6:	8a668693          	addi	a3,a3,-1882 # ffffffffc0211498 <pages>
ffffffffc0201bfa:	6288                	ld	a0,0(a3)
ffffffffc0201bfc:	00379713          	slli	a4,a5,0x3
    base = kva2page(ptr);
    free_pages(base, num_pages);
}
ffffffffc0201c00:	60a2                	ld	ra,8(sp)
ffffffffc0201c02:	97ba                	add	a5,a5,a4
ffffffffc0201c04:	078e                	slli	a5,a5,0x3
    free_pages(base, num_pages);
ffffffffc0201c06:	953e                	add	a0,a0,a5
}
ffffffffc0201c08:	0141                	addi	sp,sp,16
    free_pages(base, num_pages);
ffffffffc0201c0a:	f4bfe06f          	j	ffffffffc0200b54 <free_pages>
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0201c0e:	00003697          	auipc	a3,0x3
ffffffffc0201c12:	08a68693          	addi	a3,a3,138 # ffffffffc0204c98 <commands+0x888>
ffffffffc0201c16:	00003617          	auipc	a2,0x3
ffffffffc0201c1a:	1ea60613          	addi	a2,a2,490 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc0201c1e:	1f900593          	li	a1,505
ffffffffc0201c22:	00003517          	auipc	a0,0x3
ffffffffc0201c26:	05650513          	addi	a0,a0,86 # ffffffffc0204c78 <commands+0x868>
ffffffffc0201c2a:	cdafe0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0201c2e:	e83fe0ef          	jal	ra,ffffffffc0200ab0 <pa2page.part.4>
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc0201c32:	86aa                	mv	a3,a0
ffffffffc0201c34:	00003617          	auipc	a2,0x3
ffffffffc0201c38:	16460613          	addi	a2,a2,356 # ffffffffc0204d98 <commands+0x988>
ffffffffc0201c3c:	06c00593          	li	a1,108
ffffffffc0201c40:	00003517          	auipc	a0,0x3
ffffffffc0201c44:	0a850513          	addi	a0,a0,168 # ffffffffc0204ce8 <commands+0x8d8>
ffffffffc0201c48:	cbcfe0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert(ptr != NULL);
ffffffffc0201c4c:	00003697          	auipc	a3,0x3
ffffffffc0201c50:	03c68693          	addi	a3,a3,60 # ffffffffc0204c88 <commands+0x878>
ffffffffc0201c54:	00003617          	auipc	a2,0x3
ffffffffc0201c58:	1ac60613          	addi	a2,a2,428 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc0201c5c:	1fa00593          	li	a1,506
ffffffffc0201c60:	00003517          	auipc	a0,0x3
ffffffffc0201c64:	01850513          	addi	a0,a0,24 # ffffffffc0204c78 <commands+0x868>
ffffffffc0201c68:	c9cfe0ef          	jal	ra,ffffffffc0200104 <__panic>

ffffffffc0201c6c <check_vma_overlap.isra.0.part.1>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0201c6c:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc0201c6e:	00003697          	auipc	a3,0x3
ffffffffc0201c72:	64a68693          	addi	a3,a3,1610 # ffffffffc02052b8 <commands+0xea8>
ffffffffc0201c76:	00003617          	auipc	a2,0x3
ffffffffc0201c7a:	18a60613          	addi	a2,a2,394 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc0201c7e:	07d00593          	li	a1,125
ffffffffc0201c82:	00003517          	auipc	a0,0x3
ffffffffc0201c86:	65650513          	addi	a0,a0,1622 # ffffffffc02052d8 <commands+0xec8>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0201c8a:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc0201c8c:	c78fe0ef          	jal	ra,ffffffffc0200104 <__panic>

ffffffffc0201c90 <mm_create>:
mm_create(void) {
ffffffffc0201c90:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0201c92:	03000513          	li	a0,48
mm_create(void) {
ffffffffc0201c96:	e022                	sd	s0,0(sp)
ffffffffc0201c98:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0201c9a:	e51ff0ef          	jal	ra,ffffffffc0201aea <kmalloc>
ffffffffc0201c9e:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0201ca0:	c115                	beqz	a0,ffffffffc0201cc4 <mm_create+0x34>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0201ca2:	0000f797          	auipc	a5,0xf
ffffffffc0201ca6:	7ce78793          	addi	a5,a5,1998 # ffffffffc0211470 <swap_init_ok>
ffffffffc0201caa:	439c                	lw	a5,0(a5)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0201cac:	e408                	sd	a0,8(s0)
ffffffffc0201cae:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc0201cb0:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0201cb4:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0201cb8:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0201cbc:	2781                	sext.w	a5,a5
ffffffffc0201cbe:	eb81                	bnez	a5,ffffffffc0201cce <mm_create+0x3e>
        else mm->sm_priv = NULL;
ffffffffc0201cc0:	02053423          	sd	zero,40(a0)
}
ffffffffc0201cc4:	8522                	mv	a0,s0
ffffffffc0201cc6:	60a2                	ld	ra,8(sp)
ffffffffc0201cc8:	6402                	ld	s0,0(sp)
ffffffffc0201cca:	0141                	addi	sp,sp,16
ffffffffc0201ccc:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0201cce:	651000ef          	jal	ra,ffffffffc0202b1e <swap_init_mm>
}
ffffffffc0201cd2:	8522                	mv	a0,s0
ffffffffc0201cd4:	60a2                	ld	ra,8(sp)
ffffffffc0201cd6:	6402                	ld	s0,0(sp)
ffffffffc0201cd8:	0141                	addi	sp,sp,16
ffffffffc0201cda:	8082                	ret

ffffffffc0201cdc <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {
ffffffffc0201cdc:	1101                	addi	sp,sp,-32
ffffffffc0201cde:	e04a                	sd	s2,0(sp)
ffffffffc0201ce0:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201ce2:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {
ffffffffc0201ce6:	e822                	sd	s0,16(sp)
ffffffffc0201ce8:	e426                	sd	s1,8(sp)
ffffffffc0201cea:	ec06                	sd	ra,24(sp)
ffffffffc0201cec:	84ae                	mv	s1,a1
ffffffffc0201cee:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201cf0:	dfbff0ef          	jal	ra,ffffffffc0201aea <kmalloc>
    if (vma != NULL) {
ffffffffc0201cf4:	c509                	beqz	a0,ffffffffc0201cfe <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc0201cf6:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc0201cfa:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0201cfc:	ed00                	sd	s0,24(a0)
}
ffffffffc0201cfe:	60e2                	ld	ra,24(sp)
ffffffffc0201d00:	6442                	ld	s0,16(sp)
ffffffffc0201d02:	64a2                	ld	s1,8(sp)
ffffffffc0201d04:	6902                	ld	s2,0(sp)
ffffffffc0201d06:	6105                	addi	sp,sp,32
ffffffffc0201d08:	8082                	ret

ffffffffc0201d0a <find_vma>:
    if (mm != NULL) {
ffffffffc0201d0a:	c51d                	beqz	a0,ffffffffc0201d38 <find_vma+0x2e>
        vma = mm->mmap_cache;
ffffffffc0201d0c:	691c                	ld	a5,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0201d0e:	c781                	beqz	a5,ffffffffc0201d16 <find_vma+0xc>
ffffffffc0201d10:	6798                	ld	a4,8(a5)
ffffffffc0201d12:	02e5f663          	bgeu	a1,a4,ffffffffc0201d3e <find_vma+0x34>
                list_entry_t *list = &(mm->mmap_list), *le = list;
ffffffffc0201d16:	87aa                	mv	a5,a0
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0201d18:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc0201d1a:	00f50f63          	beq	a0,a5,ffffffffc0201d38 <find_vma+0x2e>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc0201d1e:	fe87b703          	ld	a4,-24(a5)
ffffffffc0201d22:	fee5ebe3          	bltu	a1,a4,ffffffffc0201d18 <find_vma+0xe>
ffffffffc0201d26:	ff07b703          	ld	a4,-16(a5)
ffffffffc0201d2a:	fee5f7e3          	bgeu	a1,a4,ffffffffc0201d18 <find_vma+0xe>
                    vma = le2vma(le, list_link);
ffffffffc0201d2e:	1781                	addi	a5,a5,-32
        if (vma != NULL) {
ffffffffc0201d30:	c781                	beqz	a5,ffffffffc0201d38 <find_vma+0x2e>
            mm->mmap_cache = vma;
ffffffffc0201d32:	e91c                	sd	a5,16(a0)
}
ffffffffc0201d34:	853e                	mv	a0,a5
ffffffffc0201d36:	8082                	ret
    struct vma_struct *vma = NULL;
ffffffffc0201d38:	4781                	li	a5,0
}
ffffffffc0201d3a:	853e                	mv	a0,a5
ffffffffc0201d3c:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0201d3e:	6b98                	ld	a4,16(a5)
ffffffffc0201d40:	fce5fbe3          	bgeu	a1,a4,ffffffffc0201d16 <find_vma+0xc>
            mm->mmap_cache = vma;
ffffffffc0201d44:	e91c                	sd	a5,16(a0)
    return vma;
ffffffffc0201d46:	b7fd                	j	ffffffffc0201d34 <find_vma+0x2a>

ffffffffc0201d48 <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc0201d48:	6590                	ld	a2,8(a1)
ffffffffc0201d4a:	0105b803          	ld	a6,16(a1)
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc0201d4e:	1141                	addi	sp,sp,-16
ffffffffc0201d50:	e406                	sd	ra,8(sp)
ffffffffc0201d52:	872a                	mv	a4,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0201d54:	01066863          	bltu	a2,a6,ffffffffc0201d64 <insert_vma_struct+0x1c>
ffffffffc0201d58:	a8b9                	j	ffffffffc0201db6 <insert_vma_struct+0x6e>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0201d5a:	fe87b683          	ld	a3,-24(a5)
ffffffffc0201d5e:	04d66763          	bltu	a2,a3,ffffffffc0201dac <insert_vma_struct+0x64>
ffffffffc0201d62:	873e                	mv	a4,a5
ffffffffc0201d64:	671c                	ld	a5,8(a4)
        while ((le = list_next(le)) != list) {
ffffffffc0201d66:	fef51ae3          	bne	a0,a5,ffffffffc0201d5a <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc0201d6a:	02a70463          	beq	a4,a0,ffffffffc0201d92 <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0201d6e:	ff073683          	ld	a3,-16(a4)
    assert(prev->vm_start < prev->vm_end);
ffffffffc0201d72:	fe873883          	ld	a7,-24(a4)
ffffffffc0201d76:	08d8f063          	bgeu	a7,a3,ffffffffc0201df6 <insert_vma_struct+0xae>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0201d7a:	04d66e63          	bltu	a2,a3,ffffffffc0201dd6 <insert_vma_struct+0x8e>
    }
    if (le_next != list) {
ffffffffc0201d7e:	00f50a63          	beq	a0,a5,ffffffffc0201d92 <insert_vma_struct+0x4a>
ffffffffc0201d82:	fe87b683          	ld	a3,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc0201d86:	0506e863          	bltu	a3,a6,ffffffffc0201dd6 <insert_vma_struct+0x8e>
    assert(next->vm_start < next->vm_end);
ffffffffc0201d8a:	ff07b603          	ld	a2,-16(a5)
ffffffffc0201d8e:	02c6f263          	bgeu	a3,a2,ffffffffc0201db2 <insert_vma_struct+0x6a>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc0201d92:	5114                	lw	a3,32(a0)
    vma->vm_mm = mm;
ffffffffc0201d94:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc0201d96:	02058613          	addi	a2,a1,32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0201d9a:	e390                	sd	a2,0(a5)
ffffffffc0201d9c:	e710                	sd	a2,8(a4)
}
ffffffffc0201d9e:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc0201da0:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc0201da2:	f198                	sd	a4,32(a1)
    mm->map_count ++;
ffffffffc0201da4:	2685                	addiw	a3,a3,1
ffffffffc0201da6:	d114                	sw	a3,32(a0)
}
ffffffffc0201da8:	0141                	addi	sp,sp,16
ffffffffc0201daa:	8082                	ret
    if (le_prev != list) {
ffffffffc0201dac:	fca711e3          	bne	a4,a0,ffffffffc0201d6e <insert_vma_struct+0x26>
ffffffffc0201db0:	bfd9                	j	ffffffffc0201d86 <insert_vma_struct+0x3e>
ffffffffc0201db2:	ebbff0ef          	jal	ra,ffffffffc0201c6c <check_vma_overlap.isra.0.part.1>
    assert(vma->vm_start < vma->vm_end);
ffffffffc0201db6:	00003697          	auipc	a3,0x3
ffffffffc0201dba:	5d268693          	addi	a3,a3,1490 # ffffffffc0205388 <commands+0xf78>
ffffffffc0201dbe:	00003617          	auipc	a2,0x3
ffffffffc0201dc2:	04260613          	addi	a2,a2,66 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc0201dc6:	08400593          	li	a1,132
ffffffffc0201dca:	00003517          	auipc	a0,0x3
ffffffffc0201dce:	50e50513          	addi	a0,a0,1294 # ffffffffc02052d8 <commands+0xec8>
ffffffffc0201dd2:	b32fe0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0201dd6:	00003697          	auipc	a3,0x3
ffffffffc0201dda:	5f268693          	addi	a3,a3,1522 # ffffffffc02053c8 <commands+0xfb8>
ffffffffc0201dde:	00003617          	auipc	a2,0x3
ffffffffc0201de2:	02260613          	addi	a2,a2,34 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc0201de6:	07c00593          	li	a1,124
ffffffffc0201dea:	00003517          	auipc	a0,0x3
ffffffffc0201dee:	4ee50513          	addi	a0,a0,1262 # ffffffffc02052d8 <commands+0xec8>
ffffffffc0201df2:	b12fe0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0201df6:	00003697          	auipc	a3,0x3
ffffffffc0201dfa:	5b268693          	addi	a3,a3,1458 # ffffffffc02053a8 <commands+0xf98>
ffffffffc0201dfe:	00003617          	auipc	a2,0x3
ffffffffc0201e02:	00260613          	addi	a2,a2,2 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc0201e06:	07b00593          	li	a1,123
ffffffffc0201e0a:	00003517          	auipc	a0,0x3
ffffffffc0201e0e:	4ce50513          	addi	a0,a0,1230 # ffffffffc02052d8 <commands+0xec8>
ffffffffc0201e12:	af2fe0ef          	jal	ra,ffffffffc0200104 <__panic>

ffffffffc0201e16 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
ffffffffc0201e16:	1141                	addi	sp,sp,-16
ffffffffc0201e18:	e022                	sd	s0,0(sp)
ffffffffc0201e1a:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc0201e1c:	6508                	ld	a0,8(a0)
ffffffffc0201e1e:	e406                	sd	ra,8(sp)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc0201e20:	00a40e63          	beq	s0,a0,ffffffffc0201e3c <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc0201e24:	6118                	ld	a4,0(a0)
ffffffffc0201e26:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
ffffffffc0201e28:	03000593          	li	a1,48
ffffffffc0201e2c:	1501                	addi	a0,a0,-32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0201e2e:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0201e30:	e398                	sd	a4,0(a5)
ffffffffc0201e32:	d7bff0ef          	jal	ra,ffffffffc0201bac <kfree>
    return listelm->next;
ffffffffc0201e36:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0201e38:	fea416e3          	bne	s0,a0,ffffffffc0201e24 <mm_destroy+0xe>
    }
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0201e3c:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc0201e3e:	6402                	ld	s0,0(sp)
ffffffffc0201e40:	60a2                	ld	ra,8(sp)
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0201e42:	03000593          	li	a1,48
}
ffffffffc0201e46:	0141                	addi	sp,sp,16
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0201e48:	b395                	j	ffffffffc0201bac <kfree>

ffffffffc0201e4a <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc0201e4a:	715d                	addi	sp,sp,-80
ffffffffc0201e4c:	e486                	sd	ra,72(sp)
ffffffffc0201e4e:	e0a2                	sd	s0,64(sp)
ffffffffc0201e50:	fc26                	sd	s1,56(sp)
ffffffffc0201e52:	f84a                	sd	s2,48(sp)
ffffffffc0201e54:	f052                	sd	s4,32(sp)
ffffffffc0201e56:	f44e                	sd	s3,40(sp)
ffffffffc0201e58:	ec56                	sd	s5,24(sp)
ffffffffc0201e5a:	e85a                	sd	s6,16(sp)
ffffffffc0201e5c:	e45e                	sd	s7,8(sp)
}

// check_vmm - check correctness of vmm
static void
check_vmm(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0201e5e:	d3dfe0ef          	jal	ra,ffffffffc0200b9a <nr_free_pages>
ffffffffc0201e62:	892a                	mv	s2,a0
    cprintf("check_vmm() succeeded.\n");
}

static void
check_vma_struct(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0201e64:	d37fe0ef          	jal	ra,ffffffffc0200b9a <nr_free_pages>
ffffffffc0201e68:	8a2a                	mv	s4,a0

    struct mm_struct *mm = mm_create();
ffffffffc0201e6a:	e27ff0ef          	jal	ra,ffffffffc0201c90 <mm_create>
    assert(mm != NULL);
ffffffffc0201e6e:	842a                	mv	s0,a0
ffffffffc0201e70:	03200493          	li	s1,50
ffffffffc0201e74:	e919                	bnez	a0,ffffffffc0201e8a <vmm_init+0x40>
ffffffffc0201e76:	aeed                	j	ffffffffc0202270 <vmm_init+0x426>
        vma->vm_start = vm_start;
ffffffffc0201e78:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc0201e7a:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0201e7c:	00053c23          	sd	zero,24(a0)

    int i;
    for (i = step1; i >= 1; i --) {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0201e80:	14ed                	addi	s1,s1,-5
ffffffffc0201e82:	8522                	mv	a0,s0
ffffffffc0201e84:	ec5ff0ef          	jal	ra,ffffffffc0201d48 <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc0201e88:	c88d                	beqz	s1,ffffffffc0201eba <vmm_init+0x70>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201e8a:	03000513          	li	a0,48
ffffffffc0201e8e:	c5dff0ef          	jal	ra,ffffffffc0201aea <kmalloc>
ffffffffc0201e92:	85aa                	mv	a1,a0
ffffffffc0201e94:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc0201e98:	f165                	bnez	a0,ffffffffc0201e78 <vmm_init+0x2e>
        assert(vma != NULL);
ffffffffc0201e9a:	00003697          	auipc	a3,0x3
ffffffffc0201e9e:	77668693          	addi	a3,a3,1910 # ffffffffc0205610 <commands+0x1200>
ffffffffc0201ea2:	00003617          	auipc	a2,0x3
ffffffffc0201ea6:	f5e60613          	addi	a2,a2,-162 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc0201eaa:	0ce00593          	li	a1,206
ffffffffc0201eae:	00003517          	auipc	a0,0x3
ffffffffc0201eb2:	42a50513          	addi	a0,a0,1066 # ffffffffc02052d8 <commands+0xec8>
ffffffffc0201eb6:	a4efe0ef          	jal	ra,ffffffffc0200104 <__panic>
    for (i = step1; i >= 1; i --) {
ffffffffc0201eba:	03700493          	li	s1,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0201ebe:	1f900993          	li	s3,505
ffffffffc0201ec2:	a819                	j	ffffffffc0201ed8 <vmm_init+0x8e>
        vma->vm_start = vm_start;
ffffffffc0201ec4:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc0201ec6:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0201ec8:	00053c23          	sd	zero,24(a0)
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0201ecc:	0495                	addi	s1,s1,5
ffffffffc0201ece:	8522                	mv	a0,s0
ffffffffc0201ed0:	e79ff0ef          	jal	ra,ffffffffc0201d48 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0201ed4:	03348a63          	beq	s1,s3,ffffffffc0201f08 <vmm_init+0xbe>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201ed8:	03000513          	li	a0,48
ffffffffc0201edc:	c0fff0ef          	jal	ra,ffffffffc0201aea <kmalloc>
ffffffffc0201ee0:	85aa                	mv	a1,a0
ffffffffc0201ee2:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc0201ee6:	fd79                	bnez	a0,ffffffffc0201ec4 <vmm_init+0x7a>
        assert(vma != NULL);
ffffffffc0201ee8:	00003697          	auipc	a3,0x3
ffffffffc0201eec:	72868693          	addi	a3,a3,1832 # ffffffffc0205610 <commands+0x1200>
ffffffffc0201ef0:	00003617          	auipc	a2,0x3
ffffffffc0201ef4:	f1060613          	addi	a2,a2,-240 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc0201ef8:	0d400593          	li	a1,212
ffffffffc0201efc:	00003517          	auipc	a0,0x3
ffffffffc0201f00:	3dc50513          	addi	a0,a0,988 # ffffffffc02052d8 <commands+0xec8>
ffffffffc0201f04:	a00fe0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0201f08:	6418                	ld	a4,8(s0)
ffffffffc0201f0a:	479d                	li	a5,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc0201f0c:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc0201f10:	2ae40063          	beq	s0,a4,ffffffffc02021b0 <vmm_init+0x366>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0201f14:	fe873603          	ld	a2,-24(a4)
ffffffffc0201f18:	ffe78693          	addi	a3,a5,-2
ffffffffc0201f1c:	20d61a63          	bne	a2,a3,ffffffffc0202130 <vmm_init+0x2e6>
ffffffffc0201f20:	ff073683          	ld	a3,-16(a4)
ffffffffc0201f24:	20d79663          	bne	a5,a3,ffffffffc0202130 <vmm_init+0x2e6>
ffffffffc0201f28:	0795                	addi	a5,a5,5
ffffffffc0201f2a:	6718                	ld	a4,8(a4)
    for (i = 1; i <= step2; i ++) {
ffffffffc0201f2c:	feb792e3          	bne	a5,a1,ffffffffc0201f10 <vmm_init+0xc6>
ffffffffc0201f30:	499d                	li	s3,7
ffffffffc0201f32:	4495                	li	s1,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0201f34:	1f900b93          	li	s7,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0201f38:	85a6                	mv	a1,s1
ffffffffc0201f3a:	8522                	mv	a0,s0
ffffffffc0201f3c:	dcfff0ef          	jal	ra,ffffffffc0201d0a <find_vma>
ffffffffc0201f40:	8b2a                	mv	s6,a0
        assert(vma1 != NULL);
ffffffffc0201f42:	2e050763          	beqz	a0,ffffffffc0202230 <vmm_init+0x3e6>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc0201f46:	00148593          	addi	a1,s1,1
ffffffffc0201f4a:	8522                	mv	a0,s0
ffffffffc0201f4c:	dbfff0ef          	jal	ra,ffffffffc0201d0a <find_vma>
ffffffffc0201f50:	8aaa                	mv	s5,a0
        assert(vma2 != NULL);
ffffffffc0201f52:	2a050f63          	beqz	a0,ffffffffc0202210 <vmm_init+0x3c6>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc0201f56:	85ce                	mv	a1,s3
ffffffffc0201f58:	8522                	mv	a0,s0
ffffffffc0201f5a:	db1ff0ef          	jal	ra,ffffffffc0201d0a <find_vma>
        assert(vma3 == NULL);
ffffffffc0201f5e:	28051963          	bnez	a0,ffffffffc02021f0 <vmm_init+0x3a6>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc0201f62:	00348593          	addi	a1,s1,3
ffffffffc0201f66:	8522                	mv	a0,s0
ffffffffc0201f68:	da3ff0ef          	jal	ra,ffffffffc0201d0a <find_vma>
        assert(vma4 == NULL);
ffffffffc0201f6c:	26051263          	bnez	a0,ffffffffc02021d0 <vmm_init+0x386>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc0201f70:	00448593          	addi	a1,s1,4
ffffffffc0201f74:	8522                	mv	a0,s0
ffffffffc0201f76:	d95ff0ef          	jal	ra,ffffffffc0201d0a <find_vma>
        assert(vma5 == NULL);
ffffffffc0201f7a:	2c051b63          	bnez	a0,ffffffffc0202250 <vmm_init+0x406>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0201f7e:	008b3783          	ld	a5,8(s6)
ffffffffc0201f82:	1c979763          	bne	a5,s1,ffffffffc0202150 <vmm_init+0x306>
ffffffffc0201f86:	010b3783          	ld	a5,16(s6)
ffffffffc0201f8a:	1d379363          	bne	a5,s3,ffffffffc0202150 <vmm_init+0x306>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0201f8e:	008ab783          	ld	a5,8(s5)
ffffffffc0201f92:	1c979f63          	bne	a5,s1,ffffffffc0202170 <vmm_init+0x326>
ffffffffc0201f96:	010ab783          	ld	a5,16(s5)
ffffffffc0201f9a:	1d379b63          	bne	a5,s3,ffffffffc0202170 <vmm_init+0x326>
ffffffffc0201f9e:	0495                	addi	s1,s1,5
ffffffffc0201fa0:	0995                	addi	s3,s3,5
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0201fa2:	f9749be3          	bne	s1,s7,ffffffffc0201f38 <vmm_init+0xee>
ffffffffc0201fa6:	4491                	li	s1,4
    }

    for (i =4; i>=0; i--) {
ffffffffc0201fa8:	59fd                	li	s3,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc0201faa:	85a6                	mv	a1,s1
ffffffffc0201fac:	8522                	mv	a0,s0
ffffffffc0201fae:	d5dff0ef          	jal	ra,ffffffffc0201d0a <find_vma>
ffffffffc0201fb2:	0004859b          	sext.w	a1,s1
        if (vma_below_5 != NULL ) {
ffffffffc0201fb6:	c90d                	beqz	a0,ffffffffc0201fe8 <vmm_init+0x19e>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc0201fb8:	6914                	ld	a3,16(a0)
ffffffffc0201fba:	6510                	ld	a2,8(a0)
ffffffffc0201fbc:	00003517          	auipc	a0,0x3
ffffffffc0201fc0:	53c50513          	addi	a0,a0,1340 # ffffffffc02054f8 <commands+0x10e8>
ffffffffc0201fc4:	8fafe0ef          	jal	ra,ffffffffc02000be <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc0201fc8:	00003697          	auipc	a3,0x3
ffffffffc0201fcc:	55868693          	addi	a3,a3,1368 # ffffffffc0205520 <commands+0x1110>
ffffffffc0201fd0:	00003617          	auipc	a2,0x3
ffffffffc0201fd4:	e3060613          	addi	a2,a2,-464 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc0201fd8:	0f600593          	li	a1,246
ffffffffc0201fdc:	00003517          	auipc	a0,0x3
ffffffffc0201fe0:	2fc50513          	addi	a0,a0,764 # ffffffffc02052d8 <commands+0xec8>
ffffffffc0201fe4:	920fe0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0201fe8:	14fd                	addi	s1,s1,-1
    for (i =4; i>=0; i--) {
ffffffffc0201fea:	fd3490e3          	bne	s1,s3,ffffffffc0201faa <vmm_init+0x160>
    }

    mm_destroy(mm);
ffffffffc0201fee:	8522                	mv	a0,s0
ffffffffc0201ff0:	e27ff0ef          	jal	ra,ffffffffc0201e16 <mm_destroy>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0201ff4:	ba7fe0ef          	jal	ra,ffffffffc0200b9a <nr_free_pages>
ffffffffc0201ff8:	28aa1c63          	bne	s4,a0,ffffffffc0202290 <vmm_init+0x446>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0201ffc:	00003517          	auipc	a0,0x3
ffffffffc0202000:	56450513          	addi	a0,a0,1380 # ffffffffc0205560 <commands+0x1150>
ffffffffc0202004:	8bafe0ef          	jal	ra,ffffffffc02000be <cprintf>

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
	// char *name = "check_pgfault";
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0202008:	b93fe0ef          	jal	ra,ffffffffc0200b9a <nr_free_pages>
ffffffffc020200c:	89aa                	mv	s3,a0

    check_mm_struct = mm_create();
ffffffffc020200e:	c83ff0ef          	jal	ra,ffffffffc0201c90 <mm_create>
ffffffffc0202012:	0000f797          	auipc	a5,0xf
ffffffffc0202016:	48a7b723          	sd	a0,1166(a5) # ffffffffc02114a0 <check_mm_struct>
ffffffffc020201a:	842a                	mv	s0,a0

    assert(check_mm_struct != NULL);
ffffffffc020201c:	2a050a63          	beqz	a0,ffffffffc02022d0 <vmm_init+0x486>
    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202020:	0000f797          	auipc	a5,0xf
ffffffffc0202024:	43078793          	addi	a5,a5,1072 # ffffffffc0211450 <boot_pgdir>
ffffffffc0202028:	6384                	ld	s1,0(a5)
    assert(pgdir[0] == 0);
ffffffffc020202a:	609c                	ld	a5,0(s1)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc020202c:	ed04                	sd	s1,24(a0)
    assert(pgdir[0] == 0);
ffffffffc020202e:	32079d63          	bnez	a5,ffffffffc0202368 <vmm_init+0x51e>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0202032:	03000513          	li	a0,48
ffffffffc0202036:	ab5ff0ef          	jal	ra,ffffffffc0201aea <kmalloc>
ffffffffc020203a:	8a2a                	mv	s4,a0
    if (vma != NULL) {
ffffffffc020203c:	14050a63          	beqz	a0,ffffffffc0202190 <vmm_init+0x346>
        vma->vm_end = vm_end;
ffffffffc0202040:	002007b7          	lui	a5,0x200
ffffffffc0202044:	00fa3823          	sd	a5,16(s4)
        vma->vm_flags = vm_flags;
ffffffffc0202048:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);

    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc020204a:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc020204c:	00fa3c23          	sd	a5,24(s4)
    insert_vma_struct(mm, vma);
ffffffffc0202050:	8522                	mv	a0,s0
        vma->vm_start = vm_start;
ffffffffc0202052:	000a3423          	sd	zero,8(s4)
    insert_vma_struct(mm, vma);
ffffffffc0202056:	cf3ff0ef          	jal	ra,ffffffffc0201d48 <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc020205a:	10000593          	li	a1,256
ffffffffc020205e:	8522                	mv	a0,s0
ffffffffc0202060:	cabff0ef          	jal	ra,ffffffffc0201d0a <find_vma>
ffffffffc0202064:	10000793          	li	a5,256

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
ffffffffc0202068:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc020206c:	2aaa1263          	bne	s4,a0,ffffffffc0202310 <vmm_init+0x4c6>
        *(char *)(addr + i) = i;
ffffffffc0202070:	00f78023          	sb	a5,0(a5) # 200000 <BASE_ADDRESS-0xffffffffc0000000>
        sum += i;
ffffffffc0202074:	0785                	addi	a5,a5,1
    for (i = 0; i < 100; i ++) {
ffffffffc0202076:	fee79de3          	bne	a5,a4,ffffffffc0202070 <vmm_init+0x226>
        sum += i;
ffffffffc020207a:	6705                	lui	a4,0x1
    for (i = 0; i < 100; i ++) {
ffffffffc020207c:	10000793          	li	a5,256
        sum += i;
ffffffffc0202080:	35670713          	addi	a4,a4,854 # 1356 <BASE_ADDRESS-0xffffffffc01fecaa>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc0202084:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc0202088:	0007c683          	lbu	a3,0(a5)
ffffffffc020208c:	0785                	addi	a5,a5,1
ffffffffc020208e:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc0202090:	fec79ce3          	bne	a5,a2,ffffffffc0202088 <vmm_init+0x23e>
    }
    assert(sum == 0);
ffffffffc0202094:	2a071a63          	bnez	a4,ffffffffc0202348 <vmm_init+0x4fe>

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc0202098:	4581                	li	a1,0
ffffffffc020209a:	8526                	mv	a0,s1
ffffffffc020209c:	d9bfe0ef          	jal	ra,ffffffffc0200e36 <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc02020a0:	609c                	ld	a5,0(s1)
    if (PPN(pa) >= npage) {
ffffffffc02020a2:	0000f717          	auipc	a4,0xf
ffffffffc02020a6:	3b670713          	addi	a4,a4,950 # ffffffffc0211458 <npage>
ffffffffc02020aa:	6318                	ld	a4,0(a4)
    return pa2page(PDE_ADDR(pde));
ffffffffc02020ac:	078a                	slli	a5,a5,0x2
ffffffffc02020ae:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02020b0:	28e7f063          	bgeu	a5,a4,ffffffffc0202330 <vmm_init+0x4e6>
    return &pages[PPN(pa) - nbase];
ffffffffc02020b4:	00004717          	auipc	a4,0x4
ffffffffc02020b8:	03470713          	addi	a4,a4,52 # ffffffffc02060e8 <nbase>
ffffffffc02020bc:	6318                	ld	a4,0(a4)
ffffffffc02020be:	0000f697          	auipc	a3,0xf
ffffffffc02020c2:	3da68693          	addi	a3,a3,986 # ffffffffc0211498 <pages>
ffffffffc02020c6:	6288                	ld	a0,0(a3)
ffffffffc02020c8:	8f99                	sub	a5,a5,a4
ffffffffc02020ca:	00379713          	slli	a4,a5,0x3
ffffffffc02020ce:	97ba                	add	a5,a5,a4
ffffffffc02020d0:	078e                	slli	a5,a5,0x3

    free_page(pde2page(pgdir[0]));
ffffffffc02020d2:	953e                	add	a0,a0,a5
ffffffffc02020d4:	4585                	li	a1,1
ffffffffc02020d6:	a7ffe0ef          	jal	ra,ffffffffc0200b54 <free_pages>

    pgdir[0] = 0;
ffffffffc02020da:	0004b023          	sd	zero,0(s1)

    mm->pgdir = NULL;
    mm_destroy(mm);
ffffffffc02020de:	8522                	mv	a0,s0
    mm->pgdir = NULL;
ffffffffc02020e0:	00043c23          	sd	zero,24(s0)
    mm_destroy(mm);
ffffffffc02020e4:	d33ff0ef          	jal	ra,ffffffffc0201e16 <mm_destroy>

    check_mm_struct = NULL;
    nr_free_pages_store--;	// szx : Sv39第二级页表多占了一个内存页，所以执行此操作
ffffffffc02020e8:	19fd                	addi	s3,s3,-1
    check_mm_struct = NULL;
ffffffffc02020ea:	0000f797          	auipc	a5,0xf
ffffffffc02020ee:	3a07bb23          	sd	zero,950(a5) # ffffffffc02114a0 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02020f2:	aa9fe0ef          	jal	ra,ffffffffc0200b9a <nr_free_pages>
ffffffffc02020f6:	1aa99d63          	bne	s3,a0,ffffffffc02022b0 <vmm_init+0x466>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc02020fa:	00003517          	auipc	a0,0x3
ffffffffc02020fe:	4de50513          	addi	a0,a0,1246 # ffffffffc02055d8 <commands+0x11c8>
ffffffffc0202102:	fbdfd0ef          	jal	ra,ffffffffc02000be <cprintf>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0202106:	a95fe0ef          	jal	ra,ffffffffc0200b9a <nr_free_pages>
    nr_free_pages_store--;	// szx : Sv39三级页表多占一个内存页，所以执行此操作
ffffffffc020210a:	197d                	addi	s2,s2,-1
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc020210c:	1ea91263          	bne	s2,a0,ffffffffc02022f0 <vmm_init+0x4a6>
}
ffffffffc0202110:	6406                	ld	s0,64(sp)
ffffffffc0202112:	60a6                	ld	ra,72(sp)
ffffffffc0202114:	74e2                	ld	s1,56(sp)
ffffffffc0202116:	7942                	ld	s2,48(sp)
ffffffffc0202118:	79a2                	ld	s3,40(sp)
ffffffffc020211a:	7a02                	ld	s4,32(sp)
ffffffffc020211c:	6ae2                	ld	s5,24(sp)
ffffffffc020211e:	6b42                	ld	s6,16(sp)
ffffffffc0202120:	6ba2                	ld	s7,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0202122:	00003517          	auipc	a0,0x3
ffffffffc0202126:	4d650513          	addi	a0,a0,1238 # ffffffffc02055f8 <commands+0x11e8>
}
ffffffffc020212a:	6161                	addi	sp,sp,80
    cprintf("check_vmm() succeeded.\n");
ffffffffc020212c:	f93fd06f          	j	ffffffffc02000be <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0202130:	00003697          	auipc	a3,0x3
ffffffffc0202134:	2e068693          	addi	a3,a3,736 # ffffffffc0205410 <commands+0x1000>
ffffffffc0202138:	00003617          	auipc	a2,0x3
ffffffffc020213c:	cc860613          	addi	a2,a2,-824 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc0202140:	0dd00593          	li	a1,221
ffffffffc0202144:	00003517          	auipc	a0,0x3
ffffffffc0202148:	19450513          	addi	a0,a0,404 # ffffffffc02052d8 <commands+0xec8>
ffffffffc020214c:	fb9fd0ef          	jal	ra,ffffffffc0200104 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0202150:	00003697          	auipc	a3,0x3
ffffffffc0202154:	34868693          	addi	a3,a3,840 # ffffffffc0205498 <commands+0x1088>
ffffffffc0202158:	00003617          	auipc	a2,0x3
ffffffffc020215c:	ca860613          	addi	a2,a2,-856 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc0202160:	0ed00593          	li	a1,237
ffffffffc0202164:	00003517          	auipc	a0,0x3
ffffffffc0202168:	17450513          	addi	a0,a0,372 # ffffffffc02052d8 <commands+0xec8>
ffffffffc020216c:	f99fd0ef          	jal	ra,ffffffffc0200104 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0202170:	00003697          	auipc	a3,0x3
ffffffffc0202174:	35868693          	addi	a3,a3,856 # ffffffffc02054c8 <commands+0x10b8>
ffffffffc0202178:	00003617          	auipc	a2,0x3
ffffffffc020217c:	c8860613          	addi	a2,a2,-888 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc0202180:	0ee00593          	li	a1,238
ffffffffc0202184:	00003517          	auipc	a0,0x3
ffffffffc0202188:	15450513          	addi	a0,a0,340 # ffffffffc02052d8 <commands+0xec8>
ffffffffc020218c:	f79fd0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert(vma != NULL);
ffffffffc0202190:	00003697          	auipc	a3,0x3
ffffffffc0202194:	48068693          	addi	a3,a3,1152 # ffffffffc0205610 <commands+0x1200>
ffffffffc0202198:	00003617          	auipc	a2,0x3
ffffffffc020219c:	c6860613          	addi	a2,a2,-920 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc02021a0:	11100593          	li	a1,273
ffffffffc02021a4:	00003517          	auipc	a0,0x3
ffffffffc02021a8:	13450513          	addi	a0,a0,308 # ffffffffc02052d8 <commands+0xec8>
ffffffffc02021ac:	f59fd0ef          	jal	ra,ffffffffc0200104 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc02021b0:	00003697          	auipc	a3,0x3
ffffffffc02021b4:	24868693          	addi	a3,a3,584 # ffffffffc02053f8 <commands+0xfe8>
ffffffffc02021b8:	00003617          	auipc	a2,0x3
ffffffffc02021bc:	c4860613          	addi	a2,a2,-952 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc02021c0:	0db00593          	li	a1,219
ffffffffc02021c4:	00003517          	auipc	a0,0x3
ffffffffc02021c8:	11450513          	addi	a0,a0,276 # ffffffffc02052d8 <commands+0xec8>
ffffffffc02021cc:	f39fd0ef          	jal	ra,ffffffffc0200104 <__panic>
        assert(vma4 == NULL);
ffffffffc02021d0:	00003697          	auipc	a3,0x3
ffffffffc02021d4:	2a868693          	addi	a3,a3,680 # ffffffffc0205478 <commands+0x1068>
ffffffffc02021d8:	00003617          	auipc	a2,0x3
ffffffffc02021dc:	c2860613          	addi	a2,a2,-984 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc02021e0:	0e900593          	li	a1,233
ffffffffc02021e4:	00003517          	auipc	a0,0x3
ffffffffc02021e8:	0f450513          	addi	a0,a0,244 # ffffffffc02052d8 <commands+0xec8>
ffffffffc02021ec:	f19fd0ef          	jal	ra,ffffffffc0200104 <__panic>
        assert(vma3 == NULL);
ffffffffc02021f0:	00003697          	auipc	a3,0x3
ffffffffc02021f4:	27868693          	addi	a3,a3,632 # ffffffffc0205468 <commands+0x1058>
ffffffffc02021f8:	00003617          	auipc	a2,0x3
ffffffffc02021fc:	c0860613          	addi	a2,a2,-1016 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc0202200:	0e700593          	li	a1,231
ffffffffc0202204:	00003517          	auipc	a0,0x3
ffffffffc0202208:	0d450513          	addi	a0,a0,212 # ffffffffc02052d8 <commands+0xec8>
ffffffffc020220c:	ef9fd0ef          	jal	ra,ffffffffc0200104 <__panic>
        assert(vma2 != NULL);
ffffffffc0202210:	00003697          	auipc	a3,0x3
ffffffffc0202214:	24868693          	addi	a3,a3,584 # ffffffffc0205458 <commands+0x1048>
ffffffffc0202218:	00003617          	auipc	a2,0x3
ffffffffc020221c:	be860613          	addi	a2,a2,-1048 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc0202220:	0e500593          	li	a1,229
ffffffffc0202224:	00003517          	auipc	a0,0x3
ffffffffc0202228:	0b450513          	addi	a0,a0,180 # ffffffffc02052d8 <commands+0xec8>
ffffffffc020222c:	ed9fd0ef          	jal	ra,ffffffffc0200104 <__panic>
        assert(vma1 != NULL);
ffffffffc0202230:	00003697          	auipc	a3,0x3
ffffffffc0202234:	21868693          	addi	a3,a3,536 # ffffffffc0205448 <commands+0x1038>
ffffffffc0202238:	00003617          	auipc	a2,0x3
ffffffffc020223c:	bc860613          	addi	a2,a2,-1080 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc0202240:	0e300593          	li	a1,227
ffffffffc0202244:	00003517          	auipc	a0,0x3
ffffffffc0202248:	09450513          	addi	a0,a0,148 # ffffffffc02052d8 <commands+0xec8>
ffffffffc020224c:	eb9fd0ef          	jal	ra,ffffffffc0200104 <__panic>
        assert(vma5 == NULL);
ffffffffc0202250:	00003697          	auipc	a3,0x3
ffffffffc0202254:	23868693          	addi	a3,a3,568 # ffffffffc0205488 <commands+0x1078>
ffffffffc0202258:	00003617          	auipc	a2,0x3
ffffffffc020225c:	ba860613          	addi	a2,a2,-1112 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc0202260:	0eb00593          	li	a1,235
ffffffffc0202264:	00003517          	auipc	a0,0x3
ffffffffc0202268:	07450513          	addi	a0,a0,116 # ffffffffc02052d8 <commands+0xec8>
ffffffffc020226c:	e99fd0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert(mm != NULL);
ffffffffc0202270:	00003697          	auipc	a3,0x3
ffffffffc0202274:	17868693          	addi	a3,a3,376 # ffffffffc02053e8 <commands+0xfd8>
ffffffffc0202278:	00003617          	auipc	a2,0x3
ffffffffc020227c:	b8860613          	addi	a2,a2,-1144 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc0202280:	0c700593          	li	a1,199
ffffffffc0202284:	00003517          	auipc	a0,0x3
ffffffffc0202288:	05450513          	addi	a0,a0,84 # ffffffffc02052d8 <commands+0xec8>
ffffffffc020228c:	e79fd0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0202290:	00003697          	auipc	a3,0x3
ffffffffc0202294:	2a868693          	addi	a3,a3,680 # ffffffffc0205538 <commands+0x1128>
ffffffffc0202298:	00003617          	auipc	a2,0x3
ffffffffc020229c:	b6860613          	addi	a2,a2,-1176 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc02022a0:	0fb00593          	li	a1,251
ffffffffc02022a4:	00003517          	auipc	a0,0x3
ffffffffc02022a8:	03450513          	addi	a0,a0,52 # ffffffffc02052d8 <commands+0xec8>
ffffffffc02022ac:	e59fd0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02022b0:	00003697          	auipc	a3,0x3
ffffffffc02022b4:	28868693          	addi	a3,a3,648 # ffffffffc0205538 <commands+0x1128>
ffffffffc02022b8:	00003617          	auipc	a2,0x3
ffffffffc02022bc:	b4860613          	addi	a2,a2,-1208 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc02022c0:	12e00593          	li	a1,302
ffffffffc02022c4:	00003517          	auipc	a0,0x3
ffffffffc02022c8:	01450513          	addi	a0,a0,20 # ffffffffc02052d8 <commands+0xec8>
ffffffffc02022cc:	e39fd0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc02022d0:	00003697          	auipc	a3,0x3
ffffffffc02022d4:	2b068693          	addi	a3,a3,688 # ffffffffc0205580 <commands+0x1170>
ffffffffc02022d8:	00003617          	auipc	a2,0x3
ffffffffc02022dc:	b2860613          	addi	a2,a2,-1240 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc02022e0:	10a00593          	li	a1,266
ffffffffc02022e4:	00003517          	auipc	a0,0x3
ffffffffc02022e8:	ff450513          	addi	a0,a0,-12 # ffffffffc02052d8 <commands+0xec8>
ffffffffc02022ec:	e19fd0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02022f0:	00003697          	auipc	a3,0x3
ffffffffc02022f4:	24868693          	addi	a3,a3,584 # ffffffffc0205538 <commands+0x1128>
ffffffffc02022f8:	00003617          	auipc	a2,0x3
ffffffffc02022fc:	b0860613          	addi	a2,a2,-1272 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc0202300:	0bd00593          	li	a1,189
ffffffffc0202304:	00003517          	auipc	a0,0x3
ffffffffc0202308:	fd450513          	addi	a0,a0,-44 # ffffffffc02052d8 <commands+0xec8>
ffffffffc020230c:	df9fd0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc0202310:	00003697          	auipc	a3,0x3
ffffffffc0202314:	29868693          	addi	a3,a3,664 # ffffffffc02055a8 <commands+0x1198>
ffffffffc0202318:	00003617          	auipc	a2,0x3
ffffffffc020231c:	ae860613          	addi	a2,a2,-1304 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc0202320:	11600593          	li	a1,278
ffffffffc0202324:	00003517          	auipc	a0,0x3
ffffffffc0202328:	fb450513          	addi	a0,a0,-76 # ffffffffc02052d8 <commands+0xec8>
ffffffffc020232c:	dd9fd0ef          	jal	ra,ffffffffc0200104 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0202330:	00003617          	auipc	a2,0x3
ffffffffc0202334:	99860613          	addi	a2,a2,-1640 # ffffffffc0204cc8 <commands+0x8b8>
ffffffffc0202338:	06500593          	li	a1,101
ffffffffc020233c:	00003517          	auipc	a0,0x3
ffffffffc0202340:	9ac50513          	addi	a0,a0,-1620 # ffffffffc0204ce8 <commands+0x8d8>
ffffffffc0202344:	dc1fd0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert(sum == 0);
ffffffffc0202348:	00003697          	auipc	a3,0x3
ffffffffc020234c:	28068693          	addi	a3,a3,640 # ffffffffc02055c8 <commands+0x11b8>
ffffffffc0202350:	00003617          	auipc	a2,0x3
ffffffffc0202354:	ab060613          	addi	a2,a2,-1360 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc0202358:	12000593          	li	a1,288
ffffffffc020235c:	00003517          	auipc	a0,0x3
ffffffffc0202360:	f7c50513          	addi	a0,a0,-132 # ffffffffc02052d8 <commands+0xec8>
ffffffffc0202364:	da1fd0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert(pgdir[0] == 0);
ffffffffc0202368:	00003697          	auipc	a3,0x3
ffffffffc020236c:	23068693          	addi	a3,a3,560 # ffffffffc0205598 <commands+0x1188>
ffffffffc0202370:	00003617          	auipc	a2,0x3
ffffffffc0202374:	a9060613          	addi	a2,a2,-1392 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc0202378:	10d00593          	li	a1,269
ffffffffc020237c:	00003517          	auipc	a0,0x3
ffffffffc0202380:	f5c50513          	addi	a0,a0,-164 # ffffffffc02052d8 <commands+0xec8>
ffffffffc0202384:	d81fd0ef          	jal	ra,ffffffffc0200104 <__panic>

ffffffffc0202388 <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0202388:	7139                	addi	sp,sp,-64
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc020238a:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc020238c:	f822                	sd	s0,48(sp)
ffffffffc020238e:	f426                	sd	s1,40(sp)
ffffffffc0202390:	fc06                	sd	ra,56(sp)
ffffffffc0202392:	f04a                	sd	s2,32(sp)
ffffffffc0202394:	ec4e                	sd	s3,24(sp)
ffffffffc0202396:	8432                	mv	s0,a2
ffffffffc0202398:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc020239a:	971ff0ef          	jal	ra,ffffffffc0201d0a <find_vma>

    pgfault_num++;
ffffffffc020239e:	0000f797          	auipc	a5,0xf
ffffffffc02023a2:	0c278793          	addi	a5,a5,194 # ffffffffc0211460 <pgfault_num>
ffffffffc02023a6:	439c                	lw	a5,0(a5)
ffffffffc02023a8:	2785                	addiw	a5,a5,1
ffffffffc02023aa:	0000f717          	auipc	a4,0xf
ffffffffc02023ae:	0af72b23          	sw	a5,182(a4) # ffffffffc0211460 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc02023b2:	c54d                	beqz	a0,ffffffffc020245c <do_pgfault+0xd4>
ffffffffc02023b4:	651c                	ld	a5,8(a0)
ffffffffc02023b6:	0af46363          	bltu	s0,a5,ffffffffc020245c <do_pgfault+0xd4>
     */



    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc02023ba:	6d1c                	ld	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc02023bc:	49c1                	li	s3,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc02023be:	8b89                	andi	a5,a5,2
ffffffffc02023c0:	efb9                	bnez	a5,ffffffffc020241e <do_pgfault+0x96>
        perm |= (PTE_R | PTE_W);
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc02023c2:	767d                	lui	a2,0xfffff
    *   mm->pgdir : the PDT of these vma
    *
    */


    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc02023c4:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc02023c6:	8c71                	and	s0,s0,a2
    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc02023c8:	85a2                	mv	a1,s0
ffffffffc02023ca:	4605                	li	a2,1
ffffffffc02023cc:	80ffe0ef          	jal	ra,ffffffffc0200bda <get_pte>
                                         //PT(Page Table) isn't existed, then
                                         //create a PT.
    if (*ptep == 0) {
ffffffffc02023d0:	610c                	ld	a1,0(a0)
ffffffffc02023d2:	c5b5                	beqz	a1,ffffffffc020243e <do_pgfault+0xb6>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc02023d4:	0000f797          	auipc	a5,0xf
ffffffffc02023d8:	09c78793          	addi	a5,a5,156 # ffffffffc0211470 <swap_init_ok>
ffffffffc02023dc:	439c                	lw	a5,0(a5)
ffffffffc02023de:	2781                	sext.w	a5,a5
ffffffffc02023e0:	c7d9                	beqz	a5,ffffffffc020246e <do_pgfault+0xe6>
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            //(3) make the page swappable.
            if ((ret = swap_in(mm, addr, &page)) != 0) {
ffffffffc02023e2:	0030                	addi	a2,sp,8
ffffffffc02023e4:	85a2                	mv	a1,s0
ffffffffc02023e6:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc02023e8:	e402                	sd	zero,8(sp)
            if ((ret = swap_in(mm, addr, &page)) != 0) {
ffffffffc02023ea:	069000ef          	jal	ra,ffffffffc0202c52 <swap_in>
ffffffffc02023ee:	892a                	mv	s2,a0
ffffffffc02023f0:	e90d                	bnez	a0,ffffffffc0202422 <do_pgfault+0x9a>
                cprintf("swap_in in do_pgfault failed\n");
                goto failed;
            }   
            page_insert(mm->pgdir, page, addr, perm);//建立虚拟地址和物理地址之间的对应关系，perm设置物理页权限，为了保证和它对应的虚拟页权限一致
ffffffffc02023f2:	65a2                	ld	a1,8(sp)
ffffffffc02023f4:	6c88                	ld	a0,24(s1)
ffffffffc02023f6:	86ce                	mv	a3,s3
ffffffffc02023f8:	8622                	mv	a2,s0
ffffffffc02023fa:	aaffe0ef          	jal	ra,ffffffffc0200ea8 <page_insert>
            swap_map_swappable(mm, addr, page, 1);//将此页面设置为可交换的 ,也添加到算法所维护的次序队列
ffffffffc02023fe:	6622                	ld	a2,8(sp)
ffffffffc0202400:	4685                	li	a3,1
ffffffffc0202402:	85a2                	mv	a1,s0
ffffffffc0202404:	8526                	mv	a0,s1
ffffffffc0202406:	728000ef          	jal	ra,ffffffffc0202b2e <swap_map_swappable>
	        page->pra_vaddr = addr;		//设置页对应的虚拟地址
ffffffffc020240a:	67a2                	ld	a5,8(sp)
ffffffffc020240c:	e3a0                	sd	s0,64(a5)
   }

   ret = 0;
failed:
    return ret;
}
ffffffffc020240e:	70e2                	ld	ra,56(sp)
ffffffffc0202410:	7442                	ld	s0,48(sp)
ffffffffc0202412:	854a                	mv	a0,s2
ffffffffc0202414:	74a2                	ld	s1,40(sp)
ffffffffc0202416:	7902                	ld	s2,32(sp)
ffffffffc0202418:	69e2                	ld	s3,24(sp)
ffffffffc020241a:	6121                	addi	sp,sp,64
ffffffffc020241c:	8082                	ret
        perm |= (PTE_R | PTE_W);
ffffffffc020241e:	49d9                	li	s3,22
ffffffffc0202420:	b74d                	j	ffffffffc02023c2 <do_pgfault+0x3a>
                cprintf("swap_in in do_pgfault failed\n");
ffffffffc0202422:	00003517          	auipc	a0,0x3
ffffffffc0202426:	f1e50513          	addi	a0,a0,-226 # ffffffffc0205340 <commands+0xf30>
ffffffffc020242a:	c95fd0ef          	jal	ra,ffffffffc02000be <cprintf>
}
ffffffffc020242e:	70e2                	ld	ra,56(sp)
ffffffffc0202430:	7442                	ld	s0,48(sp)
ffffffffc0202432:	854a                	mv	a0,s2
ffffffffc0202434:	74a2                	ld	s1,40(sp)
ffffffffc0202436:	7902                	ld	s2,32(sp)
ffffffffc0202438:	69e2                	ld	s3,24(sp)
ffffffffc020243a:	6121                	addi	sp,sp,64
ffffffffc020243c:	8082                	ret
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc020243e:	6c88                	ld	a0,24(s1)
ffffffffc0202440:	864e                	mv	a2,s3
ffffffffc0202442:	85a2                	mv	a1,s0
ffffffffc0202444:	e14ff0ef          	jal	ra,ffffffffc0201a58 <pgdir_alloc_page>
   ret = 0;
ffffffffc0202448:	4901                	li	s2,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc020244a:	f171                	bnez	a0,ffffffffc020240e <do_pgfault+0x86>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc020244c:	00003517          	auipc	a0,0x3
ffffffffc0202450:	ecc50513          	addi	a0,a0,-308 # ffffffffc0205318 <commands+0xf08>
ffffffffc0202454:	c6bfd0ef          	jal	ra,ffffffffc02000be <cprintf>
    ret = -E_NO_MEM;
ffffffffc0202458:	5971                	li	s2,-4
            goto failed;
ffffffffc020245a:	bf55                	j	ffffffffc020240e <do_pgfault+0x86>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc020245c:	85a2                	mv	a1,s0
ffffffffc020245e:	00003517          	auipc	a0,0x3
ffffffffc0202462:	e8a50513          	addi	a0,a0,-374 # ffffffffc02052e8 <commands+0xed8>
ffffffffc0202466:	c59fd0ef          	jal	ra,ffffffffc02000be <cprintf>
    int ret = -E_INVAL;
ffffffffc020246a:	5975                	li	s2,-3
        goto failed;
ffffffffc020246c:	b74d                	j	ffffffffc020240e <do_pgfault+0x86>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc020246e:	00003517          	auipc	a0,0x3
ffffffffc0202472:	ef250513          	addi	a0,a0,-270 # ffffffffc0205360 <commands+0xf50>
ffffffffc0202476:	c49fd0ef          	jal	ra,ffffffffc02000be <cprintf>
    ret = -E_NO_MEM;
ffffffffc020247a:	5971                	li	s2,-4
            goto failed;
ffffffffc020247c:	bf49                	j	ffffffffc020240e <do_pgfault+0x86>

ffffffffc020247e <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc020247e:	7135                	addi	sp,sp,-160
ffffffffc0202480:	ed06                	sd	ra,152(sp)
ffffffffc0202482:	e922                	sd	s0,144(sp)
ffffffffc0202484:	e526                	sd	s1,136(sp)
ffffffffc0202486:	e14a                	sd	s2,128(sp)
ffffffffc0202488:	fcce                	sd	s3,120(sp)
ffffffffc020248a:	f8d2                	sd	s4,112(sp)
ffffffffc020248c:	f4d6                	sd	s5,104(sp)
ffffffffc020248e:	f0da                	sd	s6,96(sp)
ffffffffc0202490:	ecde                	sd	s7,88(sp)
ffffffffc0202492:	e8e2                	sd	s8,80(sp)
ffffffffc0202494:	e4e6                	sd	s9,72(sp)
ffffffffc0202496:	e0ea                	sd	s10,64(sp)
ffffffffc0202498:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc020249a:	734010ef          	jal	ra,ffffffffc0203bce <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc020249e:	0000f797          	auipc	a5,0xf
ffffffffc02024a2:	09278793          	addi	a5,a5,146 # ffffffffc0211530 <max_swap_offset>
ffffffffc02024a6:	6394                	ld	a3,0(a5)
ffffffffc02024a8:	010007b7          	lui	a5,0x1000
ffffffffc02024ac:	17e1                	addi	a5,a5,-8
ffffffffc02024ae:	ff968713          	addi	a4,a3,-7
ffffffffc02024b2:	42e7ea63          	bltu	a5,a4,ffffffffc02028e6 <swap_init+0x468>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }

     sm = &swap_manager_clock;//use first in first out Page Replacement Algorithm
ffffffffc02024b6:	00008797          	auipc	a5,0x8
ffffffffc02024ba:	b4a78793          	addi	a5,a5,-1206 # ffffffffc020a000 <swap_manager_clock>
     int r = sm->init();
ffffffffc02024be:	6798                	ld	a4,8(a5)
     sm = &swap_manager_clock;//use first in first out Page Replacement Algorithm
ffffffffc02024c0:	0000f697          	auipc	a3,0xf
ffffffffc02024c4:	faf6b423          	sd	a5,-88(a3) # ffffffffc0211468 <sm>
     int r = sm->init();
ffffffffc02024c8:	9702                	jalr	a4
ffffffffc02024ca:	8b2a                	mv	s6,a0
     
     if (r == 0)
ffffffffc02024cc:	c10d                	beqz	a0,ffffffffc02024ee <swap_init+0x70>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc02024ce:	60ea                	ld	ra,152(sp)
ffffffffc02024d0:	644a                	ld	s0,144(sp)
ffffffffc02024d2:	855a                	mv	a0,s6
ffffffffc02024d4:	64aa                	ld	s1,136(sp)
ffffffffc02024d6:	690a                	ld	s2,128(sp)
ffffffffc02024d8:	79e6                	ld	s3,120(sp)
ffffffffc02024da:	7a46                	ld	s4,112(sp)
ffffffffc02024dc:	7aa6                	ld	s5,104(sp)
ffffffffc02024de:	7b06                	ld	s6,96(sp)
ffffffffc02024e0:	6be6                	ld	s7,88(sp)
ffffffffc02024e2:	6c46                	ld	s8,80(sp)
ffffffffc02024e4:	6ca6                	ld	s9,72(sp)
ffffffffc02024e6:	6d06                	ld	s10,64(sp)
ffffffffc02024e8:	7de2                	ld	s11,56(sp)
ffffffffc02024ea:	610d                	addi	sp,sp,160
ffffffffc02024ec:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02024ee:	0000f797          	auipc	a5,0xf
ffffffffc02024f2:	f7a78793          	addi	a5,a5,-134 # ffffffffc0211468 <sm>
ffffffffc02024f6:	639c                	ld	a5,0(a5)
ffffffffc02024f8:	00003517          	auipc	a0,0x3
ffffffffc02024fc:	1a850513          	addi	a0,a0,424 # ffffffffc02056a0 <commands+0x1290>
ffffffffc0202500:	0000f417          	auipc	s0,0xf
ffffffffc0202504:	07040413          	addi	s0,s0,112 # ffffffffc0211570 <free_area_bf>
ffffffffc0202508:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc020250a:	4785                	li	a5,1
ffffffffc020250c:	0000f717          	auipc	a4,0xf
ffffffffc0202510:	f6f72223          	sw	a5,-156(a4) # ffffffffc0211470 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0202514:	babfd0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc0202518:	641c                	ld	a5,8(s0)
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc020251a:	2e878a63          	beq	a5,s0,ffffffffc020280e <swap_init+0x390>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020251e:	fe87b703          	ld	a4,-24(a5)
ffffffffc0202522:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0202524:	8b05                	andi	a4,a4,1
ffffffffc0202526:	2e070863          	beqz	a4,ffffffffc0202816 <swap_init+0x398>
     int ret, count = 0, total = 0, i;
ffffffffc020252a:	4481                	li	s1,0
ffffffffc020252c:	4901                	li	s2,0
ffffffffc020252e:	a031                	j	ffffffffc020253a <swap_init+0xbc>
ffffffffc0202530:	fe87b703          	ld	a4,-24(a5)
        assert(PageProperty(p));
ffffffffc0202534:	8b09                	andi	a4,a4,2
ffffffffc0202536:	2e070063          	beqz	a4,ffffffffc0202816 <swap_init+0x398>
        count ++, total += p->property;
ffffffffc020253a:	ff87a703          	lw	a4,-8(a5)
ffffffffc020253e:	679c                	ld	a5,8(a5)
ffffffffc0202540:	2905                	addiw	s2,s2,1
ffffffffc0202542:	9cb9                	addw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202544:	fe8796e3          	bne	a5,s0,ffffffffc0202530 <swap_init+0xb2>
ffffffffc0202548:	89a6                	mv	s3,s1
     }
     assert(total == nr_free_pages());
ffffffffc020254a:	e50fe0ef          	jal	ra,ffffffffc0200b9a <nr_free_pages>
ffffffffc020254e:	5b351863          	bne	a0,s3,ffffffffc0202afe <swap_init+0x680>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc0202552:	8626                	mv	a2,s1
ffffffffc0202554:	85ca                	mv	a1,s2
ffffffffc0202556:	00003517          	auipc	a0,0x3
ffffffffc020255a:	19250513          	addi	a0,a0,402 # ffffffffc02056e8 <commands+0x12d8>
ffffffffc020255e:	b61fd0ef          	jal	ra,ffffffffc02000be <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc0202562:	f2eff0ef          	jal	ra,ffffffffc0201c90 <mm_create>
ffffffffc0202566:	8baa                	mv	s7,a0
     assert(mm != NULL);
ffffffffc0202568:	50050b63          	beqz	a0,ffffffffc0202a7e <swap_init+0x600>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc020256c:	0000f797          	auipc	a5,0xf
ffffffffc0202570:	f3478793          	addi	a5,a5,-204 # ffffffffc02114a0 <check_mm_struct>
ffffffffc0202574:	639c                	ld	a5,0(a5)
ffffffffc0202576:	52079463          	bnez	a5,ffffffffc0202a9e <swap_init+0x620>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc020257a:	0000f797          	auipc	a5,0xf
ffffffffc020257e:	ed678793          	addi	a5,a5,-298 # ffffffffc0211450 <boot_pgdir>
ffffffffc0202582:	6398                	ld	a4,0(a5)
     check_mm_struct = mm;
ffffffffc0202584:	0000f797          	auipc	a5,0xf
ffffffffc0202588:	f0a7be23          	sd	a0,-228(a5) # ffffffffc02114a0 <check_mm_struct>
     assert(pgdir[0] == 0);
ffffffffc020258c:	631c                	ld	a5,0(a4)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc020258e:	ec3a                	sd	a4,24(sp)
ffffffffc0202590:	ed18                	sd	a4,24(a0)
     assert(pgdir[0] == 0);
ffffffffc0202592:	52079663          	bnez	a5,ffffffffc0202abe <swap_init+0x640>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc0202596:	6599                	lui	a1,0x6
ffffffffc0202598:	460d                	li	a2,3
ffffffffc020259a:	6505                	lui	a0,0x1
ffffffffc020259c:	f40ff0ef          	jal	ra,ffffffffc0201cdc <vma_create>
ffffffffc02025a0:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc02025a2:	52050e63          	beqz	a0,ffffffffc0202ade <swap_init+0x660>

     insert_vma_struct(mm, vma);
ffffffffc02025a6:	855e                	mv	a0,s7
ffffffffc02025a8:	fa0ff0ef          	jal	ra,ffffffffc0201d48 <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc02025ac:	00003517          	auipc	a0,0x3
ffffffffc02025b0:	17c50513          	addi	a0,a0,380 # ffffffffc0205728 <commands+0x1318>
ffffffffc02025b4:	b0bfd0ef          	jal	ra,ffffffffc02000be <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc02025b8:	018bb503          	ld	a0,24(s7)
ffffffffc02025bc:	4605                	li	a2,1
ffffffffc02025be:	6585                	lui	a1,0x1
ffffffffc02025c0:	e1afe0ef          	jal	ra,ffffffffc0200bda <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc02025c4:	40050d63          	beqz	a0,ffffffffc02029de <swap_init+0x560>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc02025c8:	00003517          	auipc	a0,0x3
ffffffffc02025cc:	1b050513          	addi	a0,a0,432 # ffffffffc0205778 <commands+0x1368>
ffffffffc02025d0:	0000fa17          	auipc	s4,0xf
ffffffffc02025d4:	ed8a0a13          	addi	s4,s4,-296 # ffffffffc02114a8 <check_rp>
ffffffffc02025d8:	ae7fd0ef          	jal	ra,ffffffffc02000be <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02025dc:	0000fa97          	auipc	s5,0xf
ffffffffc02025e0:	eeca8a93          	addi	s5,s5,-276 # ffffffffc02114c8 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc02025e4:	89d2                	mv	s3,s4
          check_rp[i] = alloc_page();
ffffffffc02025e6:	4505                	li	a0,1
ffffffffc02025e8:	ce4fe0ef          	jal	ra,ffffffffc0200acc <alloc_pages>
ffffffffc02025ec:	00a9b023          	sd	a0,0(s3) # fffffffffff80000 <end+0x3fd6ea60>
          assert(check_rp[i] != NULL );
ffffffffc02025f0:	2a050b63          	beqz	a0,ffffffffc02028a6 <swap_init+0x428>
ffffffffc02025f4:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc02025f6:	8b89                	andi	a5,a5,2
ffffffffc02025f8:	28079763          	bnez	a5,ffffffffc0202886 <swap_init+0x408>
ffffffffc02025fc:	09a1                	addi	s3,s3,8
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02025fe:	ff5994e3          	bne	s3,s5,ffffffffc02025e6 <swap_init+0x168>
     }
     list_entry_t free_list_store = free_list;
ffffffffc0202602:	601c                	ld	a5,0(s0)
ffffffffc0202604:	00843983          	ld	s3,8(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc0202608:	0000fd17          	auipc	s10,0xf
ffffffffc020260c:	ea0d0d13          	addi	s10,s10,-352 # ffffffffc02114a8 <check_rp>
     list_entry_t free_list_store = free_list;
ffffffffc0202610:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc0202612:	481c                	lw	a5,16(s0)
ffffffffc0202614:	f43e                	sd	a5,40(sp)
    elm->prev = elm->next = elm;
ffffffffc0202616:	0000f797          	auipc	a5,0xf
ffffffffc020261a:	f687b123          	sd	s0,-158(a5) # ffffffffc0211578 <free_area_bf+0x8>
ffffffffc020261e:	0000f797          	auipc	a5,0xf
ffffffffc0202622:	f487b923          	sd	s0,-174(a5) # ffffffffc0211570 <free_area_bf>
     nr_free = 0;
ffffffffc0202626:	0000f797          	auipc	a5,0xf
ffffffffc020262a:	f407ad23          	sw	zero,-166(a5) # ffffffffc0211580 <free_area_bf+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc020262e:	000d3503          	ld	a0,0(s10)
ffffffffc0202632:	4585                	li	a1,1
ffffffffc0202634:	0d21                	addi	s10,s10,8
ffffffffc0202636:	d1efe0ef          	jal	ra,ffffffffc0200b54 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020263a:	ff5d1ae3          	bne	s10,s5,ffffffffc020262e <swap_init+0x1b0>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc020263e:	01042d03          	lw	s10,16(s0)
ffffffffc0202642:	4791                	li	a5,4
ffffffffc0202644:	36fd1d63          	bne	s10,a5,ffffffffc02029be <swap_init+0x540>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc0202648:	00003517          	auipc	a0,0x3
ffffffffc020264c:	1b850513          	addi	a0,a0,440 # ffffffffc0205800 <commands+0x13f0>
ffffffffc0202650:	a6ffd0ef          	jal	ra,ffffffffc02000be <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202654:	6685                	lui	a3,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc0202656:	0000f797          	auipc	a5,0xf
ffffffffc020265a:	e007a523          	sw	zero,-502(a5) # ffffffffc0211460 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc020265e:	4629                	li	a2,10
     pgfault_num=0;
ffffffffc0202660:	0000f797          	auipc	a5,0xf
ffffffffc0202664:	e0078793          	addi	a5,a5,-512 # ffffffffc0211460 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202668:	00c68023          	sb	a2,0(a3) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
     assert(pgfault_num==1);
ffffffffc020266c:	4398                	lw	a4,0(a5)
ffffffffc020266e:	4585                	li	a1,1
ffffffffc0202670:	2701                	sext.w	a4,a4
ffffffffc0202672:	30b71663          	bne	a4,a1,ffffffffc020297e <swap_init+0x500>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc0202676:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==1);
ffffffffc020267a:	4394                	lw	a3,0(a5)
ffffffffc020267c:	2681                	sext.w	a3,a3
ffffffffc020267e:	32e69063          	bne	a3,a4,ffffffffc020299e <swap_init+0x520>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc0202682:	6689                	lui	a3,0x2
ffffffffc0202684:	462d                	li	a2,11
ffffffffc0202686:	00c68023          	sb	a2,0(a3) # 2000 <BASE_ADDRESS-0xffffffffc01fe000>
     assert(pgfault_num==2);
ffffffffc020268a:	4398                	lw	a4,0(a5)
ffffffffc020268c:	4589                	li	a1,2
ffffffffc020268e:	2701                	sext.w	a4,a4
ffffffffc0202690:	26b71763          	bne	a4,a1,ffffffffc02028fe <swap_init+0x480>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc0202694:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc0202698:	4394                	lw	a3,0(a5)
ffffffffc020269a:	2681                	sext.w	a3,a3
ffffffffc020269c:	28e69163          	bne	a3,a4,ffffffffc020291e <swap_init+0x4a0>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc02026a0:	668d                	lui	a3,0x3
ffffffffc02026a2:	4631                	li	a2,12
ffffffffc02026a4:	00c68023          	sb	a2,0(a3) # 3000 <BASE_ADDRESS-0xffffffffc01fd000>
     assert(pgfault_num==3);
ffffffffc02026a8:	4398                	lw	a4,0(a5)
ffffffffc02026aa:	458d                	li	a1,3
ffffffffc02026ac:	2701                	sext.w	a4,a4
ffffffffc02026ae:	28b71863          	bne	a4,a1,ffffffffc020293e <swap_init+0x4c0>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc02026b2:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc02026b6:	4394                	lw	a3,0(a5)
ffffffffc02026b8:	2681                	sext.w	a3,a3
ffffffffc02026ba:	2ae69263          	bne	a3,a4,ffffffffc020295e <swap_init+0x4e0>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc02026be:	6691                	lui	a3,0x4
ffffffffc02026c0:	4635                	li	a2,13
ffffffffc02026c2:	00c68023          	sb	a2,0(a3) # 4000 <BASE_ADDRESS-0xffffffffc01fc000>
     assert(pgfault_num==4);
ffffffffc02026c6:	4398                	lw	a4,0(a5)
ffffffffc02026c8:	2701                	sext.w	a4,a4
ffffffffc02026ca:	33a71a63          	bne	a4,s10,ffffffffc02029fe <swap_init+0x580>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc02026ce:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc02026d2:	439c                	lw	a5,0(a5)
ffffffffc02026d4:	2781                	sext.w	a5,a5
ffffffffc02026d6:	34e79463          	bne	a5,a4,ffffffffc0202a1e <swap_init+0x5a0>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc02026da:	481c                	lw	a5,16(s0)
ffffffffc02026dc:	36079163          	bnez	a5,ffffffffc0202a3e <swap_init+0x5c0>
ffffffffc02026e0:	0000f797          	auipc	a5,0xf
ffffffffc02026e4:	de878793          	addi	a5,a5,-536 # ffffffffc02114c8 <swap_in_seq_no>
ffffffffc02026e8:	0000f717          	auipc	a4,0xf
ffffffffc02026ec:	e0870713          	addi	a4,a4,-504 # ffffffffc02114f0 <swap_out_seq_no>
ffffffffc02026f0:	0000f617          	auipc	a2,0xf
ffffffffc02026f4:	e0060613          	addi	a2,a2,-512 # ffffffffc02114f0 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc02026f8:	56fd                	li	a3,-1
ffffffffc02026fa:	c394                	sw	a3,0(a5)
ffffffffc02026fc:	c314                	sw	a3,0(a4)
ffffffffc02026fe:	0791                	addi	a5,a5,4
ffffffffc0202700:	0711                	addi	a4,a4,4
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0202702:	fec79ce3          	bne	a5,a2,ffffffffc02026fa <swap_init+0x27c>
ffffffffc0202706:	0000f697          	auipc	a3,0xf
ffffffffc020270a:	e4a68693          	addi	a3,a3,-438 # ffffffffc0211550 <check_ptep>
ffffffffc020270e:	0000f817          	auipc	a6,0xf
ffffffffc0202712:	d9a80813          	addi	a6,a6,-614 # ffffffffc02114a8 <check_rp>
ffffffffc0202716:	6c05                	lui	s8,0x1
    if (PPN(pa) >= npage) {
ffffffffc0202718:	0000fc97          	auipc	s9,0xf
ffffffffc020271c:	d40c8c93          	addi	s9,s9,-704 # ffffffffc0211458 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0202720:	0000fd97          	auipc	s11,0xf
ffffffffc0202724:	d78d8d93          	addi	s11,s11,-648 # ffffffffc0211498 <pages>
ffffffffc0202728:	00004d17          	auipc	s10,0x4
ffffffffc020272c:	9c0d0d13          	addi	s10,s10,-1600 # ffffffffc02060e8 <nbase>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202730:	6562                	ld	a0,24(sp)
         check_ptep[i]=0;
ffffffffc0202732:	0006b023          	sd	zero,0(a3)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202736:	4601                	li	a2,0
ffffffffc0202738:	85e2                	mv	a1,s8
ffffffffc020273a:	e842                	sd	a6,16(sp)
         check_ptep[i]=0;
ffffffffc020273c:	e436                	sd	a3,8(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc020273e:	c9cfe0ef          	jal	ra,ffffffffc0200bda <get_pte>
ffffffffc0202742:	66a2                	ld	a3,8(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0202744:	6842                	ld	a6,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202746:	e288                	sd	a0,0(a3)
         assert(check_ptep[i] != NULL);
ffffffffc0202748:	16050f63          	beqz	a0,ffffffffc02028c6 <swap_init+0x448>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc020274c:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc020274e:	0017f613          	andi	a2,a5,1
ffffffffc0202752:	10060263          	beqz	a2,ffffffffc0202856 <swap_init+0x3d8>
    if (PPN(pa) >= npage) {
ffffffffc0202756:	000cb603          	ld	a2,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc020275a:	078a                	slli	a5,a5,0x2
ffffffffc020275c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020275e:	10c7f863          	bgeu	a5,a2,ffffffffc020286e <swap_init+0x3f0>
    return &pages[PPN(pa) - nbase];
ffffffffc0202762:	000d3603          	ld	a2,0(s10)
ffffffffc0202766:	000db583          	ld	a1,0(s11)
ffffffffc020276a:	00083503          	ld	a0,0(a6)
ffffffffc020276e:	8f91                	sub	a5,a5,a2
ffffffffc0202770:	00379613          	slli	a2,a5,0x3
ffffffffc0202774:	97b2                	add	a5,a5,a2
ffffffffc0202776:	078e                	slli	a5,a5,0x3
ffffffffc0202778:	97ae                	add	a5,a5,a1
ffffffffc020277a:	0af51e63          	bne	a0,a5,ffffffffc0202836 <swap_init+0x3b8>
ffffffffc020277e:	6785                	lui	a5,0x1
ffffffffc0202780:	9c3e                	add	s8,s8,a5
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202782:	6795                	lui	a5,0x5
ffffffffc0202784:	06a1                	addi	a3,a3,8
ffffffffc0202786:	0821                	addi	a6,a6,8
ffffffffc0202788:	fafc14e3          	bne	s8,a5,ffffffffc0202730 <swap_init+0x2b2>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc020278c:	00003517          	auipc	a0,0x3
ffffffffc0202790:	12c50513          	addi	a0,a0,300 # ffffffffc02058b8 <commands+0x14a8>
ffffffffc0202794:	92bfd0ef          	jal	ra,ffffffffc02000be <cprintf>
    int ret = sm->check_swap();
ffffffffc0202798:	0000f797          	auipc	a5,0xf
ffffffffc020279c:	cd078793          	addi	a5,a5,-816 # ffffffffc0211468 <sm>
ffffffffc02027a0:	639c                	ld	a5,0(a5)
ffffffffc02027a2:	7f9c                	ld	a5,56(a5)
ffffffffc02027a4:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc02027a6:	2a051c63          	bnez	a0,ffffffffc0202a5e <swap_init+0x5e0>
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc02027aa:	000a3503          	ld	a0,0(s4)
ffffffffc02027ae:	4585                	li	a1,1
ffffffffc02027b0:	0a21                	addi	s4,s4,8
ffffffffc02027b2:	ba2fe0ef          	jal	ra,ffffffffc0200b54 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02027b6:	ff5a1ae3          	bne	s4,s5,ffffffffc02027aa <swap_init+0x32c>
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
ffffffffc02027ba:	855e                	mv	a0,s7
ffffffffc02027bc:	e5aff0ef          	jal	ra,ffffffffc0201e16 <mm_destroy>
         
     nr_free = nr_free_store;
ffffffffc02027c0:	77a2                	ld	a5,40(sp)
ffffffffc02027c2:	0000f717          	auipc	a4,0xf
ffffffffc02027c6:	daf72f23          	sw	a5,-578(a4) # ffffffffc0211580 <free_area_bf+0x10>
     free_list = free_list_store;
ffffffffc02027ca:	7782                	ld	a5,32(sp)
ffffffffc02027cc:	0000f717          	auipc	a4,0xf
ffffffffc02027d0:	daf73223          	sd	a5,-604(a4) # ffffffffc0211570 <free_area_bf>
ffffffffc02027d4:	0000f797          	auipc	a5,0xf
ffffffffc02027d8:	db37b223          	sd	s3,-604(a5) # ffffffffc0211578 <free_area_bf+0x8>

     
     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc02027dc:	00898a63          	beq	s3,s0,ffffffffc02027f0 <swap_init+0x372>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc02027e0:	ff89a783          	lw	a5,-8(s3)
    return listelm->next;
ffffffffc02027e4:	0089b983          	ld	s3,8(s3)
ffffffffc02027e8:	397d                	addiw	s2,s2,-1
ffffffffc02027ea:	9c9d                	subw	s1,s1,a5
     while ((le = list_next(le)) != &free_list) {
ffffffffc02027ec:	fe899ae3          	bne	s3,s0,ffffffffc02027e0 <swap_init+0x362>
     }
     cprintf("count is %d, total is %d\n",count,total);
ffffffffc02027f0:	8626                	mv	a2,s1
ffffffffc02027f2:	85ca                	mv	a1,s2
ffffffffc02027f4:	00003517          	auipc	a0,0x3
ffffffffc02027f8:	0f450513          	addi	a0,a0,244 # ffffffffc02058e8 <commands+0x14d8>
ffffffffc02027fc:	8c3fd0ef          	jal	ra,ffffffffc02000be <cprintf>
     //assert(count == 0);
     
     cprintf("check_swap() succeeded!\n");
ffffffffc0202800:	00003517          	auipc	a0,0x3
ffffffffc0202804:	10850513          	addi	a0,a0,264 # ffffffffc0205908 <commands+0x14f8>
ffffffffc0202808:	8b7fd0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc020280c:	b1c9                	j	ffffffffc02024ce <swap_init+0x50>
     int ret, count = 0, total = 0, i;
ffffffffc020280e:	4481                	li	s1,0
ffffffffc0202810:	4901                	li	s2,0
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202812:	4981                	li	s3,0
ffffffffc0202814:	bb1d                	j	ffffffffc020254a <swap_init+0xcc>
        assert(PageProperty(p));
ffffffffc0202816:	00003697          	auipc	a3,0x3
ffffffffc020281a:	ea268693          	addi	a3,a3,-350 # ffffffffc02056b8 <commands+0x12a8>
ffffffffc020281e:	00002617          	auipc	a2,0x2
ffffffffc0202822:	5e260613          	addi	a2,a2,1506 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc0202826:	0ba00593          	li	a1,186
ffffffffc020282a:	00003517          	auipc	a0,0x3
ffffffffc020282e:	e6650513          	addi	a0,a0,-410 # ffffffffc0205690 <commands+0x1280>
ffffffffc0202832:	8d3fd0ef          	jal	ra,ffffffffc0200104 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202836:	00003697          	auipc	a3,0x3
ffffffffc020283a:	05a68693          	addi	a3,a3,90 # ffffffffc0205890 <commands+0x1480>
ffffffffc020283e:	00002617          	auipc	a2,0x2
ffffffffc0202842:	5c260613          	addi	a2,a2,1474 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc0202846:	0fa00593          	li	a1,250
ffffffffc020284a:	00003517          	auipc	a0,0x3
ffffffffc020284e:	e4650513          	addi	a0,a0,-442 # ffffffffc0205690 <commands+0x1280>
ffffffffc0202852:	8b3fd0ef          	jal	ra,ffffffffc0200104 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0202856:	00002617          	auipc	a2,0x2
ffffffffc020285a:	68260613          	addi	a2,a2,1666 # ffffffffc0204ed8 <commands+0xac8>
ffffffffc020285e:	07000593          	li	a1,112
ffffffffc0202862:	00002517          	auipc	a0,0x2
ffffffffc0202866:	48650513          	addi	a0,a0,1158 # ffffffffc0204ce8 <commands+0x8d8>
ffffffffc020286a:	89bfd0ef          	jal	ra,ffffffffc0200104 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020286e:	00002617          	auipc	a2,0x2
ffffffffc0202872:	45a60613          	addi	a2,a2,1114 # ffffffffc0204cc8 <commands+0x8b8>
ffffffffc0202876:	06500593          	li	a1,101
ffffffffc020287a:	00002517          	auipc	a0,0x2
ffffffffc020287e:	46e50513          	addi	a0,a0,1134 # ffffffffc0204ce8 <commands+0x8d8>
ffffffffc0202882:	883fd0ef          	jal	ra,ffffffffc0200104 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc0202886:	00003697          	auipc	a3,0x3
ffffffffc020288a:	f3268693          	addi	a3,a3,-206 # ffffffffc02057b8 <commands+0x13a8>
ffffffffc020288e:	00002617          	auipc	a2,0x2
ffffffffc0202892:	57260613          	addi	a2,a2,1394 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc0202896:	0db00593          	li	a1,219
ffffffffc020289a:	00003517          	auipc	a0,0x3
ffffffffc020289e:	df650513          	addi	a0,a0,-522 # ffffffffc0205690 <commands+0x1280>
ffffffffc02028a2:	863fd0ef          	jal	ra,ffffffffc0200104 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc02028a6:	00003697          	auipc	a3,0x3
ffffffffc02028aa:	efa68693          	addi	a3,a3,-262 # ffffffffc02057a0 <commands+0x1390>
ffffffffc02028ae:	00002617          	auipc	a2,0x2
ffffffffc02028b2:	55260613          	addi	a2,a2,1362 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc02028b6:	0da00593          	li	a1,218
ffffffffc02028ba:	00003517          	auipc	a0,0x3
ffffffffc02028be:	dd650513          	addi	a0,a0,-554 # ffffffffc0205690 <commands+0x1280>
ffffffffc02028c2:	843fd0ef          	jal	ra,ffffffffc0200104 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc02028c6:	00003697          	auipc	a3,0x3
ffffffffc02028ca:	fb268693          	addi	a3,a3,-78 # ffffffffc0205878 <commands+0x1468>
ffffffffc02028ce:	00002617          	auipc	a2,0x2
ffffffffc02028d2:	53260613          	addi	a2,a2,1330 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc02028d6:	0f900593          	li	a1,249
ffffffffc02028da:	00003517          	auipc	a0,0x3
ffffffffc02028de:	db650513          	addi	a0,a0,-586 # ffffffffc0205690 <commands+0x1280>
ffffffffc02028e2:	823fd0ef          	jal	ra,ffffffffc0200104 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc02028e6:	00003617          	auipc	a2,0x3
ffffffffc02028ea:	d8a60613          	addi	a2,a2,-630 # ffffffffc0205670 <commands+0x1260>
ffffffffc02028ee:	02700593          	li	a1,39
ffffffffc02028f2:	00003517          	auipc	a0,0x3
ffffffffc02028f6:	d9e50513          	addi	a0,a0,-610 # ffffffffc0205690 <commands+0x1280>
ffffffffc02028fa:	80bfd0ef          	jal	ra,ffffffffc0200104 <__panic>
     assert(pgfault_num==2);
ffffffffc02028fe:	00003697          	auipc	a3,0x3
ffffffffc0202902:	f3a68693          	addi	a3,a3,-198 # ffffffffc0205838 <commands+0x1428>
ffffffffc0202906:	00002617          	auipc	a2,0x2
ffffffffc020290a:	4fa60613          	addi	a2,a2,1274 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc020290e:	09500593          	li	a1,149
ffffffffc0202912:	00003517          	auipc	a0,0x3
ffffffffc0202916:	d7e50513          	addi	a0,a0,-642 # ffffffffc0205690 <commands+0x1280>
ffffffffc020291a:	feafd0ef          	jal	ra,ffffffffc0200104 <__panic>
     assert(pgfault_num==2);
ffffffffc020291e:	00003697          	auipc	a3,0x3
ffffffffc0202922:	f1a68693          	addi	a3,a3,-230 # ffffffffc0205838 <commands+0x1428>
ffffffffc0202926:	00002617          	auipc	a2,0x2
ffffffffc020292a:	4da60613          	addi	a2,a2,1242 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc020292e:	09700593          	li	a1,151
ffffffffc0202932:	00003517          	auipc	a0,0x3
ffffffffc0202936:	d5e50513          	addi	a0,a0,-674 # ffffffffc0205690 <commands+0x1280>
ffffffffc020293a:	fcafd0ef          	jal	ra,ffffffffc0200104 <__panic>
     assert(pgfault_num==3);
ffffffffc020293e:	00003697          	auipc	a3,0x3
ffffffffc0202942:	f0a68693          	addi	a3,a3,-246 # ffffffffc0205848 <commands+0x1438>
ffffffffc0202946:	00002617          	auipc	a2,0x2
ffffffffc020294a:	4ba60613          	addi	a2,a2,1210 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc020294e:	09900593          	li	a1,153
ffffffffc0202952:	00003517          	auipc	a0,0x3
ffffffffc0202956:	d3e50513          	addi	a0,a0,-706 # ffffffffc0205690 <commands+0x1280>
ffffffffc020295a:	faafd0ef          	jal	ra,ffffffffc0200104 <__panic>
     assert(pgfault_num==3);
ffffffffc020295e:	00003697          	auipc	a3,0x3
ffffffffc0202962:	eea68693          	addi	a3,a3,-278 # ffffffffc0205848 <commands+0x1438>
ffffffffc0202966:	00002617          	auipc	a2,0x2
ffffffffc020296a:	49a60613          	addi	a2,a2,1178 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc020296e:	09b00593          	li	a1,155
ffffffffc0202972:	00003517          	auipc	a0,0x3
ffffffffc0202976:	d1e50513          	addi	a0,a0,-738 # ffffffffc0205690 <commands+0x1280>
ffffffffc020297a:	f8afd0ef          	jal	ra,ffffffffc0200104 <__panic>
     assert(pgfault_num==1);
ffffffffc020297e:	00003697          	auipc	a3,0x3
ffffffffc0202982:	eaa68693          	addi	a3,a3,-342 # ffffffffc0205828 <commands+0x1418>
ffffffffc0202986:	00002617          	auipc	a2,0x2
ffffffffc020298a:	47a60613          	addi	a2,a2,1146 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc020298e:	09100593          	li	a1,145
ffffffffc0202992:	00003517          	auipc	a0,0x3
ffffffffc0202996:	cfe50513          	addi	a0,a0,-770 # ffffffffc0205690 <commands+0x1280>
ffffffffc020299a:	f6afd0ef          	jal	ra,ffffffffc0200104 <__panic>
     assert(pgfault_num==1);
ffffffffc020299e:	00003697          	auipc	a3,0x3
ffffffffc02029a2:	e8a68693          	addi	a3,a3,-374 # ffffffffc0205828 <commands+0x1418>
ffffffffc02029a6:	00002617          	auipc	a2,0x2
ffffffffc02029aa:	45a60613          	addi	a2,a2,1114 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc02029ae:	09300593          	li	a1,147
ffffffffc02029b2:	00003517          	auipc	a0,0x3
ffffffffc02029b6:	cde50513          	addi	a0,a0,-802 # ffffffffc0205690 <commands+0x1280>
ffffffffc02029ba:	f4afd0ef          	jal	ra,ffffffffc0200104 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc02029be:	00003697          	auipc	a3,0x3
ffffffffc02029c2:	e1a68693          	addi	a3,a3,-486 # ffffffffc02057d8 <commands+0x13c8>
ffffffffc02029c6:	00002617          	auipc	a2,0x2
ffffffffc02029ca:	43a60613          	addi	a2,a2,1082 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc02029ce:	0e800593          	li	a1,232
ffffffffc02029d2:	00003517          	auipc	a0,0x3
ffffffffc02029d6:	cbe50513          	addi	a0,a0,-834 # ffffffffc0205690 <commands+0x1280>
ffffffffc02029da:	f2afd0ef          	jal	ra,ffffffffc0200104 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc02029de:	00003697          	auipc	a3,0x3
ffffffffc02029e2:	d8268693          	addi	a3,a3,-638 # ffffffffc0205760 <commands+0x1350>
ffffffffc02029e6:	00002617          	auipc	a2,0x2
ffffffffc02029ea:	41a60613          	addi	a2,a2,1050 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc02029ee:	0d500593          	li	a1,213
ffffffffc02029f2:	00003517          	auipc	a0,0x3
ffffffffc02029f6:	c9e50513          	addi	a0,a0,-866 # ffffffffc0205690 <commands+0x1280>
ffffffffc02029fa:	f0afd0ef          	jal	ra,ffffffffc0200104 <__panic>
     assert(pgfault_num==4);
ffffffffc02029fe:	00003697          	auipc	a3,0x3
ffffffffc0202a02:	e5a68693          	addi	a3,a3,-422 # ffffffffc0205858 <commands+0x1448>
ffffffffc0202a06:	00002617          	auipc	a2,0x2
ffffffffc0202a0a:	3fa60613          	addi	a2,a2,1018 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc0202a0e:	09d00593          	li	a1,157
ffffffffc0202a12:	00003517          	auipc	a0,0x3
ffffffffc0202a16:	c7e50513          	addi	a0,a0,-898 # ffffffffc0205690 <commands+0x1280>
ffffffffc0202a1a:	eeafd0ef          	jal	ra,ffffffffc0200104 <__panic>
     assert(pgfault_num==4);
ffffffffc0202a1e:	00003697          	auipc	a3,0x3
ffffffffc0202a22:	e3a68693          	addi	a3,a3,-454 # ffffffffc0205858 <commands+0x1448>
ffffffffc0202a26:	00002617          	auipc	a2,0x2
ffffffffc0202a2a:	3da60613          	addi	a2,a2,986 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc0202a2e:	09f00593          	li	a1,159
ffffffffc0202a32:	00003517          	auipc	a0,0x3
ffffffffc0202a36:	c5e50513          	addi	a0,a0,-930 # ffffffffc0205690 <commands+0x1280>
ffffffffc0202a3a:	ecafd0ef          	jal	ra,ffffffffc0200104 <__panic>
     assert( nr_free == 0);         
ffffffffc0202a3e:	00003697          	auipc	a3,0x3
ffffffffc0202a42:	e2a68693          	addi	a3,a3,-470 # ffffffffc0205868 <commands+0x1458>
ffffffffc0202a46:	00002617          	auipc	a2,0x2
ffffffffc0202a4a:	3ba60613          	addi	a2,a2,954 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc0202a4e:	0f100593          	li	a1,241
ffffffffc0202a52:	00003517          	auipc	a0,0x3
ffffffffc0202a56:	c3e50513          	addi	a0,a0,-962 # ffffffffc0205690 <commands+0x1280>
ffffffffc0202a5a:	eaafd0ef          	jal	ra,ffffffffc0200104 <__panic>
     assert(ret==0);
ffffffffc0202a5e:	00003697          	auipc	a3,0x3
ffffffffc0202a62:	e8268693          	addi	a3,a3,-382 # ffffffffc02058e0 <commands+0x14d0>
ffffffffc0202a66:	00002617          	auipc	a2,0x2
ffffffffc0202a6a:	39a60613          	addi	a2,a2,922 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc0202a6e:	10000593          	li	a1,256
ffffffffc0202a72:	00003517          	auipc	a0,0x3
ffffffffc0202a76:	c1e50513          	addi	a0,a0,-994 # ffffffffc0205690 <commands+0x1280>
ffffffffc0202a7a:	e8afd0ef          	jal	ra,ffffffffc0200104 <__panic>
     assert(mm != NULL);
ffffffffc0202a7e:	00003697          	auipc	a3,0x3
ffffffffc0202a82:	96a68693          	addi	a3,a3,-1686 # ffffffffc02053e8 <commands+0xfd8>
ffffffffc0202a86:	00002617          	auipc	a2,0x2
ffffffffc0202a8a:	37a60613          	addi	a2,a2,890 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc0202a8e:	0c200593          	li	a1,194
ffffffffc0202a92:	00003517          	auipc	a0,0x3
ffffffffc0202a96:	bfe50513          	addi	a0,a0,-1026 # ffffffffc0205690 <commands+0x1280>
ffffffffc0202a9a:	e6afd0ef          	jal	ra,ffffffffc0200104 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0202a9e:	00003697          	auipc	a3,0x3
ffffffffc0202aa2:	c7268693          	addi	a3,a3,-910 # ffffffffc0205710 <commands+0x1300>
ffffffffc0202aa6:	00002617          	auipc	a2,0x2
ffffffffc0202aaa:	35a60613          	addi	a2,a2,858 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc0202aae:	0c500593          	li	a1,197
ffffffffc0202ab2:	00003517          	auipc	a0,0x3
ffffffffc0202ab6:	bde50513          	addi	a0,a0,-1058 # ffffffffc0205690 <commands+0x1280>
ffffffffc0202aba:	e4afd0ef          	jal	ra,ffffffffc0200104 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0202abe:	00003697          	auipc	a3,0x3
ffffffffc0202ac2:	ada68693          	addi	a3,a3,-1318 # ffffffffc0205598 <commands+0x1188>
ffffffffc0202ac6:	00002617          	auipc	a2,0x2
ffffffffc0202aca:	33a60613          	addi	a2,a2,826 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc0202ace:	0ca00593          	li	a1,202
ffffffffc0202ad2:	00003517          	auipc	a0,0x3
ffffffffc0202ad6:	bbe50513          	addi	a0,a0,-1090 # ffffffffc0205690 <commands+0x1280>
ffffffffc0202ada:	e2afd0ef          	jal	ra,ffffffffc0200104 <__panic>
     assert(vma != NULL);
ffffffffc0202ade:	00003697          	auipc	a3,0x3
ffffffffc0202ae2:	b3268693          	addi	a3,a3,-1230 # ffffffffc0205610 <commands+0x1200>
ffffffffc0202ae6:	00002617          	auipc	a2,0x2
ffffffffc0202aea:	31a60613          	addi	a2,a2,794 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc0202aee:	0cd00593          	li	a1,205
ffffffffc0202af2:	00003517          	auipc	a0,0x3
ffffffffc0202af6:	b9e50513          	addi	a0,a0,-1122 # ffffffffc0205690 <commands+0x1280>
ffffffffc0202afa:	e0afd0ef          	jal	ra,ffffffffc0200104 <__panic>
     assert(total == nr_free_pages());
ffffffffc0202afe:	00003697          	auipc	a3,0x3
ffffffffc0202b02:	bca68693          	addi	a3,a3,-1078 # ffffffffc02056c8 <commands+0x12b8>
ffffffffc0202b06:	00002617          	auipc	a2,0x2
ffffffffc0202b0a:	2fa60613          	addi	a2,a2,762 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc0202b0e:	0bd00593          	li	a1,189
ffffffffc0202b12:	00003517          	auipc	a0,0x3
ffffffffc0202b16:	b7e50513          	addi	a0,a0,-1154 # ffffffffc0205690 <commands+0x1280>
ffffffffc0202b1a:	deafd0ef          	jal	ra,ffffffffc0200104 <__panic>

ffffffffc0202b1e <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0202b1e:	0000f797          	auipc	a5,0xf
ffffffffc0202b22:	94a78793          	addi	a5,a5,-1718 # ffffffffc0211468 <sm>
ffffffffc0202b26:	639c                	ld	a5,0(a5)
ffffffffc0202b28:	0107b303          	ld	t1,16(a5)
ffffffffc0202b2c:	8302                	jr	t1

ffffffffc0202b2e <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0202b2e:	0000f797          	auipc	a5,0xf
ffffffffc0202b32:	93a78793          	addi	a5,a5,-1734 # ffffffffc0211468 <sm>
ffffffffc0202b36:	639c                	ld	a5,0(a5)
ffffffffc0202b38:	0207b303          	ld	t1,32(a5)
ffffffffc0202b3c:	8302                	jr	t1

ffffffffc0202b3e <swap_out>:
{
ffffffffc0202b3e:	711d                	addi	sp,sp,-96
ffffffffc0202b40:	ec86                	sd	ra,88(sp)
ffffffffc0202b42:	e8a2                	sd	s0,80(sp)
ffffffffc0202b44:	e4a6                	sd	s1,72(sp)
ffffffffc0202b46:	e0ca                	sd	s2,64(sp)
ffffffffc0202b48:	fc4e                	sd	s3,56(sp)
ffffffffc0202b4a:	f852                	sd	s4,48(sp)
ffffffffc0202b4c:	f456                	sd	s5,40(sp)
ffffffffc0202b4e:	f05a                	sd	s6,32(sp)
ffffffffc0202b50:	ec5e                	sd	s7,24(sp)
ffffffffc0202b52:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc0202b54:	cde9                	beqz	a1,ffffffffc0202c2e <swap_out+0xf0>
ffffffffc0202b56:	8ab2                	mv	s5,a2
ffffffffc0202b58:	892a                	mv	s2,a0
ffffffffc0202b5a:	8a2e                	mv	s4,a1
ffffffffc0202b5c:	4401                	li	s0,0
ffffffffc0202b5e:	0000f997          	auipc	s3,0xf
ffffffffc0202b62:	90a98993          	addi	s3,s3,-1782 # ffffffffc0211468 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202b66:	00003b17          	auipc	s6,0x3
ffffffffc0202b6a:	e22b0b13          	addi	s6,s6,-478 # ffffffffc0205988 <commands+0x1578>
                    cprintf("SWAP: failed to save\n");
ffffffffc0202b6e:	00003b97          	auipc	s7,0x3
ffffffffc0202b72:	e02b8b93          	addi	s7,s7,-510 # ffffffffc0205970 <commands+0x1560>
ffffffffc0202b76:	a825                	j	ffffffffc0202bae <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202b78:	67a2                	ld	a5,8(sp)
ffffffffc0202b7a:	8626                	mv	a2,s1
ffffffffc0202b7c:	85a2                	mv	a1,s0
ffffffffc0202b7e:	63b4                	ld	a3,64(a5)
ffffffffc0202b80:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0202b82:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202b84:	82b1                	srli	a3,a3,0xc
ffffffffc0202b86:	0685                	addi	a3,a3,1
ffffffffc0202b88:	d36fd0ef          	jal	ra,ffffffffc02000be <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0202b8c:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0202b8e:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0202b90:	613c                	ld	a5,64(a0)
ffffffffc0202b92:	83b1                	srli	a5,a5,0xc
ffffffffc0202b94:	0785                	addi	a5,a5,1
ffffffffc0202b96:	07a2                	slli	a5,a5,0x8
ffffffffc0202b98:	00fc3023          	sd	a5,0(s8) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
                    free_page(page);
ffffffffc0202b9c:	fb9fd0ef          	jal	ra,ffffffffc0200b54 <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0202ba0:	01893503          	ld	a0,24(s2)
ffffffffc0202ba4:	85a6                	mv	a1,s1
ffffffffc0202ba6:	eadfe0ef          	jal	ra,ffffffffc0201a52 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0202baa:	048a0d63          	beq	s4,s0,ffffffffc0202c04 <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0202bae:	0009b783          	ld	a5,0(s3)
ffffffffc0202bb2:	8656                	mv	a2,s5
ffffffffc0202bb4:	002c                	addi	a1,sp,8
ffffffffc0202bb6:	7b9c                	ld	a5,48(a5)
ffffffffc0202bb8:	854a                	mv	a0,s2
ffffffffc0202bba:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0202bbc:	e12d                	bnez	a0,ffffffffc0202c1e <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0202bbe:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202bc0:	01893503          	ld	a0,24(s2)
ffffffffc0202bc4:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0202bc6:	63a4                	ld	s1,64(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202bc8:	85a6                	mv	a1,s1
ffffffffc0202bca:	810fe0ef          	jal	ra,ffffffffc0200bda <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0202bce:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202bd0:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0202bd2:	8b85                	andi	a5,a5,1
ffffffffc0202bd4:	cfb9                	beqz	a5,ffffffffc0202c32 <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0202bd6:	65a2                	ld	a1,8(sp)
ffffffffc0202bd8:	61bc                	ld	a5,64(a1)
ffffffffc0202bda:	83b1                	srli	a5,a5,0xc
ffffffffc0202bdc:	00178513          	addi	a0,a5,1
ffffffffc0202be0:	0522                	slli	a0,a0,0x8
ffffffffc0202be2:	0ca010ef          	jal	ra,ffffffffc0203cac <swapfs_write>
ffffffffc0202be6:	d949                	beqz	a0,ffffffffc0202b78 <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0202be8:	855e                	mv	a0,s7
ffffffffc0202bea:	cd4fd0ef          	jal	ra,ffffffffc02000be <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0202bee:	0009b783          	ld	a5,0(s3)
ffffffffc0202bf2:	6622                	ld	a2,8(sp)
ffffffffc0202bf4:	4681                	li	a3,0
ffffffffc0202bf6:	739c                	ld	a5,32(a5)
ffffffffc0202bf8:	85a6                	mv	a1,s1
ffffffffc0202bfa:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0202bfc:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0202bfe:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0202c00:	fa8a17e3          	bne	s4,s0,ffffffffc0202bae <swap_out+0x70>
}
ffffffffc0202c04:	8522                	mv	a0,s0
ffffffffc0202c06:	60e6                	ld	ra,88(sp)
ffffffffc0202c08:	6446                	ld	s0,80(sp)
ffffffffc0202c0a:	64a6                	ld	s1,72(sp)
ffffffffc0202c0c:	6906                	ld	s2,64(sp)
ffffffffc0202c0e:	79e2                	ld	s3,56(sp)
ffffffffc0202c10:	7a42                	ld	s4,48(sp)
ffffffffc0202c12:	7aa2                	ld	s5,40(sp)
ffffffffc0202c14:	7b02                	ld	s6,32(sp)
ffffffffc0202c16:	6be2                	ld	s7,24(sp)
ffffffffc0202c18:	6c42                	ld	s8,16(sp)
ffffffffc0202c1a:	6125                	addi	sp,sp,96
ffffffffc0202c1c:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc0202c1e:	85a2                	mv	a1,s0
ffffffffc0202c20:	00003517          	auipc	a0,0x3
ffffffffc0202c24:	d0850513          	addi	a0,a0,-760 # ffffffffc0205928 <commands+0x1518>
ffffffffc0202c28:	c96fd0ef          	jal	ra,ffffffffc02000be <cprintf>
                  break;
ffffffffc0202c2c:	bfe1                	j	ffffffffc0202c04 <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc0202c2e:	4401                	li	s0,0
ffffffffc0202c30:	bfd1                	j	ffffffffc0202c04 <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0202c32:	00003697          	auipc	a3,0x3
ffffffffc0202c36:	d2668693          	addi	a3,a3,-730 # ffffffffc0205958 <commands+0x1548>
ffffffffc0202c3a:	00002617          	auipc	a2,0x2
ffffffffc0202c3e:	1c660613          	addi	a2,a2,454 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc0202c42:	06600593          	li	a1,102
ffffffffc0202c46:	00003517          	auipc	a0,0x3
ffffffffc0202c4a:	a4a50513          	addi	a0,a0,-1462 # ffffffffc0205690 <commands+0x1280>
ffffffffc0202c4e:	cb6fd0ef          	jal	ra,ffffffffc0200104 <__panic>

ffffffffc0202c52 <swap_in>:
{
ffffffffc0202c52:	7179                	addi	sp,sp,-48
ffffffffc0202c54:	e84a                	sd	s2,16(sp)
ffffffffc0202c56:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc0202c58:	4505                	li	a0,1
{
ffffffffc0202c5a:	ec26                	sd	s1,24(sp)
ffffffffc0202c5c:	e44e                	sd	s3,8(sp)
ffffffffc0202c5e:	f406                	sd	ra,40(sp)
ffffffffc0202c60:	f022                	sd	s0,32(sp)
ffffffffc0202c62:	84ae                	mv	s1,a1
ffffffffc0202c64:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc0202c66:	e67fd0ef          	jal	ra,ffffffffc0200acc <alloc_pages>
     assert(result!=NULL);
ffffffffc0202c6a:	c129                	beqz	a0,ffffffffc0202cac <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc0202c6c:	842a                	mv	s0,a0
ffffffffc0202c6e:	01893503          	ld	a0,24(s2)
ffffffffc0202c72:	4601                	li	a2,0
ffffffffc0202c74:	85a6                	mv	a1,s1
ffffffffc0202c76:	f65fd0ef          	jal	ra,ffffffffc0200bda <get_pte>
ffffffffc0202c7a:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc0202c7c:	6108                	ld	a0,0(a0)
ffffffffc0202c7e:	85a2                	mv	a1,s0
ffffffffc0202c80:	787000ef          	jal	ra,ffffffffc0203c06 <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc0202c84:	00093583          	ld	a1,0(s2)
ffffffffc0202c88:	8626                	mv	a2,s1
ffffffffc0202c8a:	00003517          	auipc	a0,0x3
ffffffffc0202c8e:	9a650513          	addi	a0,a0,-1626 # ffffffffc0205630 <commands+0x1220>
ffffffffc0202c92:	81a1                	srli	a1,a1,0x8
ffffffffc0202c94:	c2afd0ef          	jal	ra,ffffffffc02000be <cprintf>
}
ffffffffc0202c98:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc0202c9a:	0089b023          	sd	s0,0(s3)
}
ffffffffc0202c9e:	7402                	ld	s0,32(sp)
ffffffffc0202ca0:	64e2                	ld	s1,24(sp)
ffffffffc0202ca2:	6942                	ld	s2,16(sp)
ffffffffc0202ca4:	69a2                	ld	s3,8(sp)
ffffffffc0202ca6:	4501                	li	a0,0
ffffffffc0202ca8:	6145                	addi	sp,sp,48
ffffffffc0202caa:	8082                	ret
     assert(result!=NULL);
ffffffffc0202cac:	00003697          	auipc	a3,0x3
ffffffffc0202cb0:	97468693          	addi	a3,a3,-1676 # ffffffffc0205620 <commands+0x1210>
ffffffffc0202cb4:	00002617          	auipc	a2,0x2
ffffffffc0202cb8:	14c60613          	addi	a2,a2,332 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc0202cbc:	07c00593          	li	a1,124
ffffffffc0202cc0:	00003517          	auipc	a0,0x3
ffffffffc0202cc4:	9d050513          	addi	a0,a0,-1584 # ffffffffc0205690 <commands+0x1280>
ffffffffc0202cc8:	c3cfd0ef          	jal	ra,ffffffffc0200104 <__panic>

ffffffffc0202ccc <default_init>:
    elm->prev = elm->next = elm;
ffffffffc0202ccc:	0000f797          	auipc	a5,0xf
ffffffffc0202cd0:	8a478793          	addi	a5,a5,-1884 # ffffffffc0211570 <free_area_bf>
ffffffffc0202cd4:	e79c                	sd	a5,8(a5)
ffffffffc0202cd6:	e39c                	sd	a5,0(a5)
#define nr_free (free_area_bf.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0202cd8:	0007a823          	sw	zero,16(a5)
}
ffffffffc0202cdc:	8082                	ret

ffffffffc0202cde <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0202cde:	0000f517          	auipc	a0,0xf
ffffffffc0202ce2:	8a256503          	lwu	a0,-1886(a0) # ffffffffc0211580 <free_area_bf+0x10>
ffffffffc0202ce6:	8082                	ret

ffffffffc0202ce8 <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0202ce8:	715d                	addi	sp,sp,-80
ffffffffc0202cea:	f84a                	sd	s2,48(sp)
    return listelm->next;
ffffffffc0202cec:	0000f917          	auipc	s2,0xf
ffffffffc0202cf0:	88490913          	addi	s2,s2,-1916 # ffffffffc0211570 <free_area_bf>
ffffffffc0202cf4:	00893783          	ld	a5,8(s2)
ffffffffc0202cf8:	e486                	sd	ra,72(sp)
ffffffffc0202cfa:	e0a2                	sd	s0,64(sp)
ffffffffc0202cfc:	fc26                	sd	s1,56(sp)
ffffffffc0202cfe:	f44e                	sd	s3,40(sp)
ffffffffc0202d00:	f052                	sd	s4,32(sp)
ffffffffc0202d02:	ec56                	sd	s5,24(sp)
ffffffffc0202d04:	e85a                	sd	s6,16(sp)
ffffffffc0202d06:	e45e                	sd	s7,8(sp)
ffffffffc0202d08:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202d0a:	31278f63          	beq	a5,s2,ffffffffc0203028 <default_check+0x340>
ffffffffc0202d0e:	fe87b703          	ld	a4,-24(a5)
ffffffffc0202d12:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0202d14:	8b05                	andi	a4,a4,1
ffffffffc0202d16:	30070d63          	beqz	a4,ffffffffc0203030 <default_check+0x348>
    int count = 0, total = 0;
ffffffffc0202d1a:	4401                	li	s0,0
ffffffffc0202d1c:	4481                	li	s1,0
ffffffffc0202d1e:	a031                	j	ffffffffc0202d2a <default_check+0x42>
ffffffffc0202d20:	fe87b703          	ld	a4,-24(a5)
        assert(PageProperty(p));
ffffffffc0202d24:	8b09                	andi	a4,a4,2
ffffffffc0202d26:	30070563          	beqz	a4,ffffffffc0203030 <default_check+0x348>
        count ++, total += p->property;
ffffffffc0202d2a:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202d2e:	679c                	ld	a5,8(a5)
ffffffffc0202d30:	2485                	addiw	s1,s1,1
ffffffffc0202d32:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202d34:	ff2796e3          	bne	a5,s2,ffffffffc0202d20 <default_check+0x38>
ffffffffc0202d38:	89a2                	mv	s3,s0
    }
    assert(total == nr_free_pages());
ffffffffc0202d3a:	e61fd0ef          	jal	ra,ffffffffc0200b9a <nr_free_pages>
ffffffffc0202d3e:	75351963          	bne	a0,s3,ffffffffc0203490 <default_check+0x7a8>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0202d42:	4505                	li	a0,1
ffffffffc0202d44:	d89fd0ef          	jal	ra,ffffffffc0200acc <alloc_pages>
ffffffffc0202d48:	8a2a                	mv	s4,a0
ffffffffc0202d4a:	48050363          	beqz	a0,ffffffffc02031d0 <default_check+0x4e8>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0202d4e:	4505                	li	a0,1
ffffffffc0202d50:	d7dfd0ef          	jal	ra,ffffffffc0200acc <alloc_pages>
ffffffffc0202d54:	89aa                	mv	s3,a0
ffffffffc0202d56:	74050d63          	beqz	a0,ffffffffc02034b0 <default_check+0x7c8>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0202d5a:	4505                	li	a0,1
ffffffffc0202d5c:	d71fd0ef          	jal	ra,ffffffffc0200acc <alloc_pages>
ffffffffc0202d60:	8aaa                	mv	s5,a0
ffffffffc0202d62:	4e050763          	beqz	a0,ffffffffc0203250 <default_check+0x568>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0202d66:	2f3a0563          	beq	s4,s3,ffffffffc0203050 <default_check+0x368>
ffffffffc0202d6a:	2eaa0363          	beq	s4,a0,ffffffffc0203050 <default_check+0x368>
ffffffffc0202d6e:	2ea98163          	beq	s3,a0,ffffffffc0203050 <default_check+0x368>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0202d72:	000a2783          	lw	a5,0(s4)
ffffffffc0202d76:	2e079d63          	bnez	a5,ffffffffc0203070 <default_check+0x388>
ffffffffc0202d7a:	0009a783          	lw	a5,0(s3)
ffffffffc0202d7e:	2e079963          	bnez	a5,ffffffffc0203070 <default_check+0x388>
ffffffffc0202d82:	411c                	lw	a5,0(a0)
ffffffffc0202d84:	2e079663          	bnez	a5,ffffffffc0203070 <default_check+0x388>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202d88:	0000e797          	auipc	a5,0xe
ffffffffc0202d8c:	71078793          	addi	a5,a5,1808 # ffffffffc0211498 <pages>
ffffffffc0202d90:	639c                	ld	a5,0(a5)
ffffffffc0202d92:	00002717          	auipc	a4,0x2
ffffffffc0202d96:	eb670713          	addi	a4,a4,-330 # ffffffffc0204c48 <commands+0x838>
ffffffffc0202d9a:	630c                	ld	a1,0(a4)
ffffffffc0202d9c:	40fa0733          	sub	a4,s4,a5
ffffffffc0202da0:	870d                	srai	a4,a4,0x3
ffffffffc0202da2:	02b70733          	mul	a4,a4,a1
ffffffffc0202da6:	00003697          	auipc	a3,0x3
ffffffffc0202daa:	34268693          	addi	a3,a3,834 # ffffffffc02060e8 <nbase>
ffffffffc0202dae:	6290                	ld	a2,0(a3)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0202db0:	0000e697          	auipc	a3,0xe
ffffffffc0202db4:	6a868693          	addi	a3,a3,1704 # ffffffffc0211458 <npage>
ffffffffc0202db8:	6294                	ld	a3,0(a3)
ffffffffc0202dba:	06b2                	slli	a3,a3,0xc
ffffffffc0202dbc:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0202dbe:	0732                	slli	a4,a4,0xc
ffffffffc0202dc0:	2cd77863          	bgeu	a4,a3,ffffffffc0203090 <default_check+0x3a8>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202dc4:	40f98733          	sub	a4,s3,a5
ffffffffc0202dc8:	870d                	srai	a4,a4,0x3
ffffffffc0202dca:	02b70733          	mul	a4,a4,a1
ffffffffc0202dce:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0202dd0:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0202dd2:	4ed77f63          	bgeu	a4,a3,ffffffffc02032d0 <default_check+0x5e8>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202dd6:	40f507b3          	sub	a5,a0,a5
ffffffffc0202dda:	878d                	srai	a5,a5,0x3
ffffffffc0202ddc:	02b787b3          	mul	a5,a5,a1
ffffffffc0202de0:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0202de2:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0202de4:	34d7f663          	bgeu	a5,a3,ffffffffc0203130 <default_check+0x448>
    assert(alloc_page() == NULL);
ffffffffc0202de8:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0202dea:	00093c03          	ld	s8,0(s2)
ffffffffc0202dee:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc0202df2:	01092b03          	lw	s6,16(s2)
    elm->prev = elm->next = elm;
ffffffffc0202df6:	0000e797          	auipc	a5,0xe
ffffffffc0202dfa:	7927b123          	sd	s2,1922(a5) # ffffffffc0211578 <free_area_bf+0x8>
ffffffffc0202dfe:	0000e797          	auipc	a5,0xe
ffffffffc0202e02:	7727b923          	sd	s2,1906(a5) # ffffffffc0211570 <free_area_bf>
    nr_free = 0;
ffffffffc0202e06:	0000e797          	auipc	a5,0xe
ffffffffc0202e0a:	7607ad23          	sw	zero,1914(a5) # ffffffffc0211580 <free_area_bf+0x10>
    assert(alloc_page() == NULL);
ffffffffc0202e0e:	cbffd0ef          	jal	ra,ffffffffc0200acc <alloc_pages>
ffffffffc0202e12:	2e051f63          	bnez	a0,ffffffffc0203110 <default_check+0x428>
    free_page(p0);
ffffffffc0202e16:	4585                	li	a1,1
ffffffffc0202e18:	8552                	mv	a0,s4
ffffffffc0202e1a:	d3bfd0ef          	jal	ra,ffffffffc0200b54 <free_pages>
    free_page(p1);
ffffffffc0202e1e:	4585                	li	a1,1
ffffffffc0202e20:	854e                	mv	a0,s3
ffffffffc0202e22:	d33fd0ef          	jal	ra,ffffffffc0200b54 <free_pages>
    free_page(p2);
ffffffffc0202e26:	4585                	li	a1,1
ffffffffc0202e28:	8556                	mv	a0,s5
ffffffffc0202e2a:	d2bfd0ef          	jal	ra,ffffffffc0200b54 <free_pages>
    assert(nr_free == 3);
ffffffffc0202e2e:	01092703          	lw	a4,16(s2)
ffffffffc0202e32:	478d                	li	a5,3
ffffffffc0202e34:	2af71e63          	bne	a4,a5,ffffffffc02030f0 <default_check+0x408>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0202e38:	4505                	li	a0,1
ffffffffc0202e3a:	c93fd0ef          	jal	ra,ffffffffc0200acc <alloc_pages>
ffffffffc0202e3e:	89aa                	mv	s3,a0
ffffffffc0202e40:	28050863          	beqz	a0,ffffffffc02030d0 <default_check+0x3e8>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0202e44:	4505                	li	a0,1
ffffffffc0202e46:	c87fd0ef          	jal	ra,ffffffffc0200acc <alloc_pages>
ffffffffc0202e4a:	8aaa                	mv	s5,a0
ffffffffc0202e4c:	3e050263          	beqz	a0,ffffffffc0203230 <default_check+0x548>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0202e50:	4505                	li	a0,1
ffffffffc0202e52:	c7bfd0ef          	jal	ra,ffffffffc0200acc <alloc_pages>
ffffffffc0202e56:	8a2a                	mv	s4,a0
ffffffffc0202e58:	3a050c63          	beqz	a0,ffffffffc0203210 <default_check+0x528>
    assert(alloc_page() == NULL);
ffffffffc0202e5c:	4505                	li	a0,1
ffffffffc0202e5e:	c6ffd0ef          	jal	ra,ffffffffc0200acc <alloc_pages>
ffffffffc0202e62:	38051763          	bnez	a0,ffffffffc02031f0 <default_check+0x508>
    free_page(p0);
ffffffffc0202e66:	4585                	li	a1,1
ffffffffc0202e68:	854e                	mv	a0,s3
ffffffffc0202e6a:	cebfd0ef          	jal	ra,ffffffffc0200b54 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0202e6e:	00893783          	ld	a5,8(s2)
ffffffffc0202e72:	23278f63          	beq	a5,s2,ffffffffc02030b0 <default_check+0x3c8>
    assert((p = alloc_page()) == p0);
ffffffffc0202e76:	4505                	li	a0,1
ffffffffc0202e78:	c55fd0ef          	jal	ra,ffffffffc0200acc <alloc_pages>
ffffffffc0202e7c:	32a99a63          	bne	s3,a0,ffffffffc02031b0 <default_check+0x4c8>
    assert(alloc_page() == NULL);
ffffffffc0202e80:	4505                	li	a0,1
ffffffffc0202e82:	c4bfd0ef          	jal	ra,ffffffffc0200acc <alloc_pages>
ffffffffc0202e86:	30051563          	bnez	a0,ffffffffc0203190 <default_check+0x4a8>
    assert(nr_free == 0);
ffffffffc0202e8a:	01092783          	lw	a5,16(s2)
ffffffffc0202e8e:	2e079163          	bnez	a5,ffffffffc0203170 <default_check+0x488>
    free_page(p);
ffffffffc0202e92:	854e                	mv	a0,s3
ffffffffc0202e94:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0202e96:	0000e797          	auipc	a5,0xe
ffffffffc0202e9a:	6d87bd23          	sd	s8,1754(a5) # ffffffffc0211570 <free_area_bf>
ffffffffc0202e9e:	0000e797          	auipc	a5,0xe
ffffffffc0202ea2:	6d77bd23          	sd	s7,1754(a5) # ffffffffc0211578 <free_area_bf+0x8>
    nr_free = nr_free_store;
ffffffffc0202ea6:	0000e797          	auipc	a5,0xe
ffffffffc0202eaa:	6d67ad23          	sw	s6,1754(a5) # ffffffffc0211580 <free_area_bf+0x10>
    free_page(p);
ffffffffc0202eae:	ca7fd0ef          	jal	ra,ffffffffc0200b54 <free_pages>
    free_page(p1);
ffffffffc0202eb2:	4585                	li	a1,1
ffffffffc0202eb4:	8556                	mv	a0,s5
ffffffffc0202eb6:	c9ffd0ef          	jal	ra,ffffffffc0200b54 <free_pages>
    free_page(p2);
ffffffffc0202eba:	4585                	li	a1,1
ffffffffc0202ebc:	8552                	mv	a0,s4
ffffffffc0202ebe:	c97fd0ef          	jal	ra,ffffffffc0200b54 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0202ec2:	4515                	li	a0,5
ffffffffc0202ec4:	c09fd0ef          	jal	ra,ffffffffc0200acc <alloc_pages>
ffffffffc0202ec8:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0202eca:	28050363          	beqz	a0,ffffffffc0203150 <default_check+0x468>
ffffffffc0202ece:	651c                	ld	a5,8(a0)
ffffffffc0202ed0:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0202ed2:	8b85                	andi	a5,a5,1
ffffffffc0202ed4:	54079e63          	bnez	a5,ffffffffc0203430 <default_check+0x748>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0202ed8:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0202eda:	00093b03          	ld	s6,0(s2)
ffffffffc0202ede:	00893a83          	ld	s5,8(s2)
ffffffffc0202ee2:	0000e797          	auipc	a5,0xe
ffffffffc0202ee6:	6927b723          	sd	s2,1678(a5) # ffffffffc0211570 <free_area_bf>
ffffffffc0202eea:	0000e797          	auipc	a5,0xe
ffffffffc0202eee:	6927b723          	sd	s2,1678(a5) # ffffffffc0211578 <free_area_bf+0x8>
    assert(alloc_page() == NULL);
ffffffffc0202ef2:	bdbfd0ef          	jal	ra,ffffffffc0200acc <alloc_pages>
ffffffffc0202ef6:	50051d63          	bnez	a0,ffffffffc0203410 <default_check+0x728>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0202efa:	09098a13          	addi	s4,s3,144
ffffffffc0202efe:	8552                	mv	a0,s4
ffffffffc0202f00:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0202f02:	01092b83          	lw	s7,16(s2)
    nr_free = 0;
ffffffffc0202f06:	0000e797          	auipc	a5,0xe
ffffffffc0202f0a:	6607ad23          	sw	zero,1658(a5) # ffffffffc0211580 <free_area_bf+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0202f0e:	c47fd0ef          	jal	ra,ffffffffc0200b54 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0202f12:	4511                	li	a0,4
ffffffffc0202f14:	bb9fd0ef          	jal	ra,ffffffffc0200acc <alloc_pages>
ffffffffc0202f18:	4c051c63          	bnez	a0,ffffffffc02033f0 <default_check+0x708>
ffffffffc0202f1c:	0989b783          	ld	a5,152(s3)
ffffffffc0202f20:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0202f22:	8b85                	andi	a5,a5,1
ffffffffc0202f24:	4a078663          	beqz	a5,ffffffffc02033d0 <default_check+0x6e8>
ffffffffc0202f28:	0a89a703          	lw	a4,168(s3)
ffffffffc0202f2c:	478d                	li	a5,3
ffffffffc0202f2e:	4af71163          	bne	a4,a5,ffffffffc02033d0 <default_check+0x6e8>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0202f32:	450d                	li	a0,3
ffffffffc0202f34:	b99fd0ef          	jal	ra,ffffffffc0200acc <alloc_pages>
ffffffffc0202f38:	8c2a                	mv	s8,a0
ffffffffc0202f3a:	46050b63          	beqz	a0,ffffffffc02033b0 <default_check+0x6c8>
    assert(alloc_page() == NULL);
ffffffffc0202f3e:	4505                	li	a0,1
ffffffffc0202f40:	b8dfd0ef          	jal	ra,ffffffffc0200acc <alloc_pages>
ffffffffc0202f44:	44051663          	bnez	a0,ffffffffc0203390 <default_check+0x6a8>
    assert(p0 + 2 == p1);
ffffffffc0202f48:	438a1463          	bne	s4,s8,ffffffffc0203370 <default_check+0x688>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0202f4c:	4585                	li	a1,1
ffffffffc0202f4e:	854e                	mv	a0,s3
ffffffffc0202f50:	c05fd0ef          	jal	ra,ffffffffc0200b54 <free_pages>
    free_pages(p1, 3);
ffffffffc0202f54:	458d                	li	a1,3
ffffffffc0202f56:	8552                	mv	a0,s4
ffffffffc0202f58:	bfdfd0ef          	jal	ra,ffffffffc0200b54 <free_pages>
ffffffffc0202f5c:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0202f60:	04898c13          	addi	s8,s3,72
ffffffffc0202f64:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0202f66:	8b85                	andi	a5,a5,1
ffffffffc0202f68:	3e078463          	beqz	a5,ffffffffc0203350 <default_check+0x668>
ffffffffc0202f6c:	0189a703          	lw	a4,24(s3)
ffffffffc0202f70:	4785                	li	a5,1
ffffffffc0202f72:	3cf71f63          	bne	a4,a5,ffffffffc0203350 <default_check+0x668>
ffffffffc0202f76:	008a3783          	ld	a5,8(s4)
ffffffffc0202f7a:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0202f7c:	8b85                	andi	a5,a5,1
ffffffffc0202f7e:	3a078963          	beqz	a5,ffffffffc0203330 <default_check+0x648>
ffffffffc0202f82:	018a2703          	lw	a4,24(s4)
ffffffffc0202f86:	478d                	li	a5,3
ffffffffc0202f88:	3af71463          	bne	a4,a5,ffffffffc0203330 <default_check+0x648>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0202f8c:	4505                	li	a0,1
ffffffffc0202f8e:	b3ffd0ef          	jal	ra,ffffffffc0200acc <alloc_pages>
ffffffffc0202f92:	36a99f63          	bne	s3,a0,ffffffffc0203310 <default_check+0x628>
    free_page(p0);
ffffffffc0202f96:	4585                	li	a1,1
ffffffffc0202f98:	bbdfd0ef          	jal	ra,ffffffffc0200b54 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0202f9c:	4509                	li	a0,2
ffffffffc0202f9e:	b2ffd0ef          	jal	ra,ffffffffc0200acc <alloc_pages>
ffffffffc0202fa2:	34aa1763          	bne	s4,a0,ffffffffc02032f0 <default_check+0x608>

    free_pages(p0, 2);
ffffffffc0202fa6:	4589                	li	a1,2
ffffffffc0202fa8:	badfd0ef          	jal	ra,ffffffffc0200b54 <free_pages>
    free_page(p2);
ffffffffc0202fac:	4585                	li	a1,1
ffffffffc0202fae:	8562                	mv	a0,s8
ffffffffc0202fb0:	ba5fd0ef          	jal	ra,ffffffffc0200b54 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0202fb4:	4515                	li	a0,5
ffffffffc0202fb6:	b17fd0ef          	jal	ra,ffffffffc0200acc <alloc_pages>
ffffffffc0202fba:	89aa                	mv	s3,a0
ffffffffc0202fbc:	48050a63          	beqz	a0,ffffffffc0203450 <default_check+0x768>
    assert(alloc_page() == NULL);
ffffffffc0202fc0:	4505                	li	a0,1
ffffffffc0202fc2:	b0bfd0ef          	jal	ra,ffffffffc0200acc <alloc_pages>
ffffffffc0202fc6:	2e051563          	bnez	a0,ffffffffc02032b0 <default_check+0x5c8>

    assert(nr_free == 0);
ffffffffc0202fca:	01092783          	lw	a5,16(s2)
ffffffffc0202fce:	2c079163          	bnez	a5,ffffffffc0203290 <default_check+0x5a8>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0202fd2:	4595                	li	a1,5
ffffffffc0202fd4:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0202fd6:	0000e797          	auipc	a5,0xe
ffffffffc0202fda:	5b77a523          	sw	s7,1450(a5) # ffffffffc0211580 <free_area_bf+0x10>
    free_list = free_list_store;
ffffffffc0202fde:	0000e797          	auipc	a5,0xe
ffffffffc0202fe2:	5967b923          	sd	s6,1426(a5) # ffffffffc0211570 <free_area_bf>
ffffffffc0202fe6:	0000e797          	auipc	a5,0xe
ffffffffc0202fea:	5957b923          	sd	s5,1426(a5) # ffffffffc0211578 <free_area_bf+0x8>
    free_pages(p0, 5);
ffffffffc0202fee:	b67fd0ef          	jal	ra,ffffffffc0200b54 <free_pages>
    return listelm->next;
ffffffffc0202ff2:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202ff6:	01278963          	beq	a5,s2,ffffffffc0203008 <default_check+0x320>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0202ffa:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202ffe:	679c                	ld	a5,8(a5)
ffffffffc0203000:	34fd                	addiw	s1,s1,-1
ffffffffc0203002:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0203004:	ff279be3          	bne	a5,s2,ffffffffc0202ffa <default_check+0x312>
    }
    assert(count == 0);
ffffffffc0203008:	26049463          	bnez	s1,ffffffffc0203270 <default_check+0x588>
    assert(total == 0);
ffffffffc020300c:	46041263          	bnez	s0,ffffffffc0203470 <default_check+0x788>
}
ffffffffc0203010:	60a6                	ld	ra,72(sp)
ffffffffc0203012:	6406                	ld	s0,64(sp)
ffffffffc0203014:	74e2                	ld	s1,56(sp)
ffffffffc0203016:	7942                	ld	s2,48(sp)
ffffffffc0203018:	79a2                	ld	s3,40(sp)
ffffffffc020301a:	7a02                	ld	s4,32(sp)
ffffffffc020301c:	6ae2                	ld	s5,24(sp)
ffffffffc020301e:	6b42                	ld	s6,16(sp)
ffffffffc0203020:	6ba2                	ld	s7,8(sp)
ffffffffc0203022:	6c02                	ld	s8,0(sp)
ffffffffc0203024:	6161                	addi	sp,sp,80
ffffffffc0203026:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0203028:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc020302a:	4401                	li	s0,0
ffffffffc020302c:	4481                	li	s1,0
ffffffffc020302e:	b331                	j	ffffffffc0202d3a <default_check+0x52>
        assert(PageProperty(p));
ffffffffc0203030:	00002697          	auipc	a3,0x2
ffffffffc0203034:	68868693          	addi	a3,a3,1672 # ffffffffc02056b8 <commands+0x12a8>
ffffffffc0203038:	00002617          	auipc	a2,0x2
ffffffffc020303c:	dc860613          	addi	a2,a2,-568 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc0203040:	0f000593          	li	a1,240
ffffffffc0203044:	00003517          	auipc	a0,0x3
ffffffffc0203048:	98450513          	addi	a0,a0,-1660 # ffffffffc02059c8 <commands+0x15b8>
ffffffffc020304c:	8b8fd0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0203050:	00003697          	auipc	a3,0x3
ffffffffc0203054:	9f068693          	addi	a3,a3,-1552 # ffffffffc0205a40 <commands+0x1630>
ffffffffc0203058:	00002617          	auipc	a2,0x2
ffffffffc020305c:	da860613          	addi	a2,a2,-600 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc0203060:	0bd00593          	li	a1,189
ffffffffc0203064:	00003517          	auipc	a0,0x3
ffffffffc0203068:	96450513          	addi	a0,a0,-1692 # ffffffffc02059c8 <commands+0x15b8>
ffffffffc020306c:	898fd0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0203070:	00003697          	auipc	a3,0x3
ffffffffc0203074:	9f868693          	addi	a3,a3,-1544 # ffffffffc0205a68 <commands+0x1658>
ffffffffc0203078:	00002617          	auipc	a2,0x2
ffffffffc020307c:	d8860613          	addi	a2,a2,-632 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc0203080:	0be00593          	li	a1,190
ffffffffc0203084:	00003517          	auipc	a0,0x3
ffffffffc0203088:	94450513          	addi	a0,a0,-1724 # ffffffffc02059c8 <commands+0x15b8>
ffffffffc020308c:	878fd0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0203090:	00003697          	auipc	a3,0x3
ffffffffc0203094:	a1868693          	addi	a3,a3,-1512 # ffffffffc0205aa8 <commands+0x1698>
ffffffffc0203098:	00002617          	auipc	a2,0x2
ffffffffc020309c:	d6860613          	addi	a2,a2,-664 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc02030a0:	0c000593          	li	a1,192
ffffffffc02030a4:	00003517          	auipc	a0,0x3
ffffffffc02030a8:	92450513          	addi	a0,a0,-1756 # ffffffffc02059c8 <commands+0x15b8>
ffffffffc02030ac:	858fd0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert(!list_empty(&free_list));
ffffffffc02030b0:	00003697          	auipc	a3,0x3
ffffffffc02030b4:	a8068693          	addi	a3,a3,-1408 # ffffffffc0205b30 <commands+0x1720>
ffffffffc02030b8:	00002617          	auipc	a2,0x2
ffffffffc02030bc:	d4860613          	addi	a2,a2,-696 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc02030c0:	0d900593          	li	a1,217
ffffffffc02030c4:	00003517          	auipc	a0,0x3
ffffffffc02030c8:	90450513          	addi	a0,a0,-1788 # ffffffffc02059c8 <commands+0x15b8>
ffffffffc02030cc:	838fd0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02030d0:	00003697          	auipc	a3,0x3
ffffffffc02030d4:	91068693          	addi	a3,a3,-1776 # ffffffffc02059e0 <commands+0x15d0>
ffffffffc02030d8:	00002617          	auipc	a2,0x2
ffffffffc02030dc:	d2860613          	addi	a2,a2,-728 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc02030e0:	0d200593          	li	a1,210
ffffffffc02030e4:	00003517          	auipc	a0,0x3
ffffffffc02030e8:	8e450513          	addi	a0,a0,-1820 # ffffffffc02059c8 <commands+0x15b8>
ffffffffc02030ec:	818fd0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert(nr_free == 3);
ffffffffc02030f0:	00003697          	auipc	a3,0x3
ffffffffc02030f4:	a3068693          	addi	a3,a3,-1488 # ffffffffc0205b20 <commands+0x1710>
ffffffffc02030f8:	00002617          	auipc	a2,0x2
ffffffffc02030fc:	d0860613          	addi	a2,a2,-760 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc0203100:	0d000593          	li	a1,208
ffffffffc0203104:	00003517          	auipc	a0,0x3
ffffffffc0203108:	8c450513          	addi	a0,a0,-1852 # ffffffffc02059c8 <commands+0x15b8>
ffffffffc020310c:	ff9fc0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0203110:	00003697          	auipc	a3,0x3
ffffffffc0203114:	9f868693          	addi	a3,a3,-1544 # ffffffffc0205b08 <commands+0x16f8>
ffffffffc0203118:	00002617          	auipc	a2,0x2
ffffffffc020311c:	ce860613          	addi	a2,a2,-792 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc0203120:	0cb00593          	li	a1,203
ffffffffc0203124:	00003517          	auipc	a0,0x3
ffffffffc0203128:	8a450513          	addi	a0,a0,-1884 # ffffffffc02059c8 <commands+0x15b8>
ffffffffc020312c:	fd9fc0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0203130:	00003697          	auipc	a3,0x3
ffffffffc0203134:	9b868693          	addi	a3,a3,-1608 # ffffffffc0205ae8 <commands+0x16d8>
ffffffffc0203138:	00002617          	auipc	a2,0x2
ffffffffc020313c:	cc860613          	addi	a2,a2,-824 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc0203140:	0c200593          	li	a1,194
ffffffffc0203144:	00003517          	auipc	a0,0x3
ffffffffc0203148:	88450513          	addi	a0,a0,-1916 # ffffffffc02059c8 <commands+0x15b8>
ffffffffc020314c:	fb9fc0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert(p0 != NULL);
ffffffffc0203150:	00003697          	auipc	a3,0x3
ffffffffc0203154:	a1868693          	addi	a3,a3,-1512 # ffffffffc0205b68 <commands+0x1758>
ffffffffc0203158:	00002617          	auipc	a2,0x2
ffffffffc020315c:	ca860613          	addi	a2,a2,-856 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc0203160:	0f800593          	li	a1,248
ffffffffc0203164:	00003517          	auipc	a0,0x3
ffffffffc0203168:	86450513          	addi	a0,a0,-1948 # ffffffffc02059c8 <commands+0x15b8>
ffffffffc020316c:	f99fc0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert(nr_free == 0);
ffffffffc0203170:	00002697          	auipc	a3,0x2
ffffffffc0203174:	6f868693          	addi	a3,a3,1784 # ffffffffc0205868 <commands+0x1458>
ffffffffc0203178:	00002617          	auipc	a2,0x2
ffffffffc020317c:	c8860613          	addi	a2,a2,-888 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc0203180:	0df00593          	li	a1,223
ffffffffc0203184:	00003517          	auipc	a0,0x3
ffffffffc0203188:	84450513          	addi	a0,a0,-1980 # ffffffffc02059c8 <commands+0x15b8>
ffffffffc020318c:	f79fc0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0203190:	00003697          	auipc	a3,0x3
ffffffffc0203194:	97868693          	addi	a3,a3,-1672 # ffffffffc0205b08 <commands+0x16f8>
ffffffffc0203198:	00002617          	auipc	a2,0x2
ffffffffc020319c:	c6860613          	addi	a2,a2,-920 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc02031a0:	0dd00593          	li	a1,221
ffffffffc02031a4:	00003517          	auipc	a0,0x3
ffffffffc02031a8:	82450513          	addi	a0,a0,-2012 # ffffffffc02059c8 <commands+0x15b8>
ffffffffc02031ac:	f59fc0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc02031b0:	00003697          	auipc	a3,0x3
ffffffffc02031b4:	99868693          	addi	a3,a3,-1640 # ffffffffc0205b48 <commands+0x1738>
ffffffffc02031b8:	00002617          	auipc	a2,0x2
ffffffffc02031bc:	c4860613          	addi	a2,a2,-952 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc02031c0:	0dc00593          	li	a1,220
ffffffffc02031c4:	00003517          	auipc	a0,0x3
ffffffffc02031c8:	80450513          	addi	a0,a0,-2044 # ffffffffc02059c8 <commands+0x15b8>
ffffffffc02031cc:	f39fc0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02031d0:	00003697          	auipc	a3,0x3
ffffffffc02031d4:	81068693          	addi	a3,a3,-2032 # ffffffffc02059e0 <commands+0x15d0>
ffffffffc02031d8:	00002617          	auipc	a2,0x2
ffffffffc02031dc:	c2860613          	addi	a2,a2,-984 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc02031e0:	0b900593          	li	a1,185
ffffffffc02031e4:	00002517          	auipc	a0,0x2
ffffffffc02031e8:	7e450513          	addi	a0,a0,2020 # ffffffffc02059c8 <commands+0x15b8>
ffffffffc02031ec:	f19fc0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02031f0:	00003697          	auipc	a3,0x3
ffffffffc02031f4:	91868693          	addi	a3,a3,-1768 # ffffffffc0205b08 <commands+0x16f8>
ffffffffc02031f8:	00002617          	auipc	a2,0x2
ffffffffc02031fc:	c0860613          	addi	a2,a2,-1016 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc0203200:	0d600593          	li	a1,214
ffffffffc0203204:	00002517          	auipc	a0,0x2
ffffffffc0203208:	7c450513          	addi	a0,a0,1988 # ffffffffc02059c8 <commands+0x15b8>
ffffffffc020320c:	ef9fc0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0203210:	00003697          	auipc	a3,0x3
ffffffffc0203214:	81068693          	addi	a3,a3,-2032 # ffffffffc0205a20 <commands+0x1610>
ffffffffc0203218:	00002617          	auipc	a2,0x2
ffffffffc020321c:	be860613          	addi	a2,a2,-1048 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc0203220:	0d400593          	li	a1,212
ffffffffc0203224:	00002517          	auipc	a0,0x2
ffffffffc0203228:	7a450513          	addi	a0,a0,1956 # ffffffffc02059c8 <commands+0x15b8>
ffffffffc020322c:	ed9fc0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0203230:	00002697          	auipc	a3,0x2
ffffffffc0203234:	7d068693          	addi	a3,a3,2000 # ffffffffc0205a00 <commands+0x15f0>
ffffffffc0203238:	00002617          	auipc	a2,0x2
ffffffffc020323c:	bc860613          	addi	a2,a2,-1080 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc0203240:	0d300593          	li	a1,211
ffffffffc0203244:	00002517          	auipc	a0,0x2
ffffffffc0203248:	78450513          	addi	a0,a0,1924 # ffffffffc02059c8 <commands+0x15b8>
ffffffffc020324c:	eb9fc0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0203250:	00002697          	auipc	a3,0x2
ffffffffc0203254:	7d068693          	addi	a3,a3,2000 # ffffffffc0205a20 <commands+0x1610>
ffffffffc0203258:	00002617          	auipc	a2,0x2
ffffffffc020325c:	ba860613          	addi	a2,a2,-1112 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc0203260:	0bb00593          	li	a1,187
ffffffffc0203264:	00002517          	auipc	a0,0x2
ffffffffc0203268:	76450513          	addi	a0,a0,1892 # ffffffffc02059c8 <commands+0x15b8>
ffffffffc020326c:	e99fc0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert(count == 0);
ffffffffc0203270:	00003697          	auipc	a3,0x3
ffffffffc0203274:	a4868693          	addi	a3,a3,-1464 # ffffffffc0205cb8 <commands+0x18a8>
ffffffffc0203278:	00002617          	auipc	a2,0x2
ffffffffc020327c:	b8860613          	addi	a2,a2,-1144 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc0203280:	12500593          	li	a1,293
ffffffffc0203284:	00002517          	auipc	a0,0x2
ffffffffc0203288:	74450513          	addi	a0,a0,1860 # ffffffffc02059c8 <commands+0x15b8>
ffffffffc020328c:	e79fc0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert(nr_free == 0);
ffffffffc0203290:	00002697          	auipc	a3,0x2
ffffffffc0203294:	5d868693          	addi	a3,a3,1496 # ffffffffc0205868 <commands+0x1458>
ffffffffc0203298:	00002617          	auipc	a2,0x2
ffffffffc020329c:	b6860613          	addi	a2,a2,-1176 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc02032a0:	11a00593          	li	a1,282
ffffffffc02032a4:	00002517          	auipc	a0,0x2
ffffffffc02032a8:	72450513          	addi	a0,a0,1828 # ffffffffc02059c8 <commands+0x15b8>
ffffffffc02032ac:	e59fc0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02032b0:	00003697          	auipc	a3,0x3
ffffffffc02032b4:	85868693          	addi	a3,a3,-1960 # ffffffffc0205b08 <commands+0x16f8>
ffffffffc02032b8:	00002617          	auipc	a2,0x2
ffffffffc02032bc:	b4860613          	addi	a2,a2,-1208 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc02032c0:	11800593          	li	a1,280
ffffffffc02032c4:	00002517          	auipc	a0,0x2
ffffffffc02032c8:	70450513          	addi	a0,a0,1796 # ffffffffc02059c8 <commands+0x15b8>
ffffffffc02032cc:	e39fc0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02032d0:	00002697          	auipc	a3,0x2
ffffffffc02032d4:	7f868693          	addi	a3,a3,2040 # ffffffffc0205ac8 <commands+0x16b8>
ffffffffc02032d8:	00002617          	auipc	a2,0x2
ffffffffc02032dc:	b2860613          	addi	a2,a2,-1240 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc02032e0:	0c100593          	li	a1,193
ffffffffc02032e4:	00002517          	auipc	a0,0x2
ffffffffc02032e8:	6e450513          	addi	a0,a0,1764 # ffffffffc02059c8 <commands+0x15b8>
ffffffffc02032ec:	e19fc0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc02032f0:	00003697          	auipc	a3,0x3
ffffffffc02032f4:	98868693          	addi	a3,a3,-1656 # ffffffffc0205c78 <commands+0x1868>
ffffffffc02032f8:	00002617          	auipc	a2,0x2
ffffffffc02032fc:	b0860613          	addi	a2,a2,-1272 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc0203300:	11200593          	li	a1,274
ffffffffc0203304:	00002517          	auipc	a0,0x2
ffffffffc0203308:	6c450513          	addi	a0,a0,1732 # ffffffffc02059c8 <commands+0x15b8>
ffffffffc020330c:	df9fc0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0203310:	00003697          	auipc	a3,0x3
ffffffffc0203314:	94868693          	addi	a3,a3,-1720 # ffffffffc0205c58 <commands+0x1848>
ffffffffc0203318:	00002617          	auipc	a2,0x2
ffffffffc020331c:	ae860613          	addi	a2,a2,-1304 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc0203320:	11000593          	li	a1,272
ffffffffc0203324:	00002517          	auipc	a0,0x2
ffffffffc0203328:	6a450513          	addi	a0,a0,1700 # ffffffffc02059c8 <commands+0x15b8>
ffffffffc020332c:	dd9fc0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0203330:	00003697          	auipc	a3,0x3
ffffffffc0203334:	90068693          	addi	a3,a3,-1792 # ffffffffc0205c30 <commands+0x1820>
ffffffffc0203338:	00002617          	auipc	a2,0x2
ffffffffc020333c:	ac860613          	addi	a2,a2,-1336 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc0203340:	10e00593          	li	a1,270
ffffffffc0203344:	00002517          	auipc	a0,0x2
ffffffffc0203348:	68450513          	addi	a0,a0,1668 # ffffffffc02059c8 <commands+0x15b8>
ffffffffc020334c:	db9fc0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0203350:	00003697          	auipc	a3,0x3
ffffffffc0203354:	8b868693          	addi	a3,a3,-1864 # ffffffffc0205c08 <commands+0x17f8>
ffffffffc0203358:	00002617          	auipc	a2,0x2
ffffffffc020335c:	aa860613          	addi	a2,a2,-1368 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc0203360:	10d00593          	li	a1,269
ffffffffc0203364:	00002517          	auipc	a0,0x2
ffffffffc0203368:	66450513          	addi	a0,a0,1636 # ffffffffc02059c8 <commands+0x15b8>
ffffffffc020336c:	d99fc0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert(p0 + 2 == p1);
ffffffffc0203370:	00003697          	auipc	a3,0x3
ffffffffc0203374:	88868693          	addi	a3,a3,-1912 # ffffffffc0205bf8 <commands+0x17e8>
ffffffffc0203378:	00002617          	auipc	a2,0x2
ffffffffc020337c:	a8860613          	addi	a2,a2,-1400 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc0203380:	10800593          	li	a1,264
ffffffffc0203384:	00002517          	auipc	a0,0x2
ffffffffc0203388:	64450513          	addi	a0,a0,1604 # ffffffffc02059c8 <commands+0x15b8>
ffffffffc020338c:	d79fc0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0203390:	00002697          	auipc	a3,0x2
ffffffffc0203394:	77868693          	addi	a3,a3,1912 # ffffffffc0205b08 <commands+0x16f8>
ffffffffc0203398:	00002617          	auipc	a2,0x2
ffffffffc020339c:	a6860613          	addi	a2,a2,-1432 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc02033a0:	10700593          	li	a1,263
ffffffffc02033a4:	00002517          	auipc	a0,0x2
ffffffffc02033a8:	62450513          	addi	a0,a0,1572 # ffffffffc02059c8 <commands+0x15b8>
ffffffffc02033ac:	d59fc0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc02033b0:	00003697          	auipc	a3,0x3
ffffffffc02033b4:	82868693          	addi	a3,a3,-2008 # ffffffffc0205bd8 <commands+0x17c8>
ffffffffc02033b8:	00002617          	auipc	a2,0x2
ffffffffc02033bc:	a4860613          	addi	a2,a2,-1464 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc02033c0:	10600593          	li	a1,262
ffffffffc02033c4:	00002517          	auipc	a0,0x2
ffffffffc02033c8:	60450513          	addi	a0,a0,1540 # ffffffffc02059c8 <commands+0x15b8>
ffffffffc02033cc:	d39fc0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc02033d0:	00002697          	auipc	a3,0x2
ffffffffc02033d4:	7d868693          	addi	a3,a3,2008 # ffffffffc0205ba8 <commands+0x1798>
ffffffffc02033d8:	00002617          	auipc	a2,0x2
ffffffffc02033dc:	a2860613          	addi	a2,a2,-1496 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc02033e0:	10500593          	li	a1,261
ffffffffc02033e4:	00002517          	auipc	a0,0x2
ffffffffc02033e8:	5e450513          	addi	a0,a0,1508 # ffffffffc02059c8 <commands+0x15b8>
ffffffffc02033ec:	d19fc0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc02033f0:	00002697          	auipc	a3,0x2
ffffffffc02033f4:	7a068693          	addi	a3,a3,1952 # ffffffffc0205b90 <commands+0x1780>
ffffffffc02033f8:	00002617          	auipc	a2,0x2
ffffffffc02033fc:	a0860613          	addi	a2,a2,-1528 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc0203400:	10400593          	li	a1,260
ffffffffc0203404:	00002517          	auipc	a0,0x2
ffffffffc0203408:	5c450513          	addi	a0,a0,1476 # ffffffffc02059c8 <commands+0x15b8>
ffffffffc020340c:	cf9fc0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0203410:	00002697          	auipc	a3,0x2
ffffffffc0203414:	6f868693          	addi	a3,a3,1784 # ffffffffc0205b08 <commands+0x16f8>
ffffffffc0203418:	00002617          	auipc	a2,0x2
ffffffffc020341c:	9e860613          	addi	a2,a2,-1560 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc0203420:	0fe00593          	li	a1,254
ffffffffc0203424:	00002517          	auipc	a0,0x2
ffffffffc0203428:	5a450513          	addi	a0,a0,1444 # ffffffffc02059c8 <commands+0x15b8>
ffffffffc020342c:	cd9fc0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert(!PageProperty(p0));
ffffffffc0203430:	00002697          	auipc	a3,0x2
ffffffffc0203434:	74868693          	addi	a3,a3,1864 # ffffffffc0205b78 <commands+0x1768>
ffffffffc0203438:	00002617          	auipc	a2,0x2
ffffffffc020343c:	9c860613          	addi	a2,a2,-1592 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc0203440:	0f900593          	li	a1,249
ffffffffc0203444:	00002517          	auipc	a0,0x2
ffffffffc0203448:	58450513          	addi	a0,a0,1412 # ffffffffc02059c8 <commands+0x15b8>
ffffffffc020344c:	cb9fc0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0203450:	00003697          	auipc	a3,0x3
ffffffffc0203454:	84868693          	addi	a3,a3,-1976 # ffffffffc0205c98 <commands+0x1888>
ffffffffc0203458:	00002617          	auipc	a2,0x2
ffffffffc020345c:	9a860613          	addi	a2,a2,-1624 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc0203460:	11700593          	li	a1,279
ffffffffc0203464:	00002517          	auipc	a0,0x2
ffffffffc0203468:	56450513          	addi	a0,a0,1380 # ffffffffc02059c8 <commands+0x15b8>
ffffffffc020346c:	c99fc0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert(total == 0);
ffffffffc0203470:	00003697          	auipc	a3,0x3
ffffffffc0203474:	85868693          	addi	a3,a3,-1960 # ffffffffc0205cc8 <commands+0x18b8>
ffffffffc0203478:	00002617          	auipc	a2,0x2
ffffffffc020347c:	98860613          	addi	a2,a2,-1656 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc0203480:	12600593          	li	a1,294
ffffffffc0203484:	00002517          	auipc	a0,0x2
ffffffffc0203488:	54450513          	addi	a0,a0,1348 # ffffffffc02059c8 <commands+0x15b8>
ffffffffc020348c:	c79fc0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert(total == nr_free_pages());
ffffffffc0203490:	00002697          	auipc	a3,0x2
ffffffffc0203494:	23868693          	addi	a3,a3,568 # ffffffffc02056c8 <commands+0x12b8>
ffffffffc0203498:	00002617          	auipc	a2,0x2
ffffffffc020349c:	96860613          	addi	a2,a2,-1688 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc02034a0:	0f300593          	li	a1,243
ffffffffc02034a4:	00002517          	auipc	a0,0x2
ffffffffc02034a8:	52450513          	addi	a0,a0,1316 # ffffffffc02059c8 <commands+0x15b8>
ffffffffc02034ac:	c59fc0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02034b0:	00002697          	auipc	a3,0x2
ffffffffc02034b4:	55068693          	addi	a3,a3,1360 # ffffffffc0205a00 <commands+0x15f0>
ffffffffc02034b8:	00002617          	auipc	a2,0x2
ffffffffc02034bc:	94860613          	addi	a2,a2,-1720 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc02034c0:	0ba00593          	li	a1,186
ffffffffc02034c4:	00002517          	auipc	a0,0x2
ffffffffc02034c8:	50450513          	addi	a0,a0,1284 # ffffffffc02059c8 <commands+0x15b8>
ffffffffc02034cc:	c39fc0ef          	jal	ra,ffffffffc0200104 <__panic>

ffffffffc02034d0 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc02034d0:	1141                	addi	sp,sp,-16
ffffffffc02034d2:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02034d4:	18058063          	beqz	a1,ffffffffc0203654 <default_free_pages+0x184>
    for (; p != base + n; p ++) {
ffffffffc02034d8:	00359693          	slli	a3,a1,0x3
ffffffffc02034dc:	96ae                	add	a3,a3,a1
ffffffffc02034de:	068e                	slli	a3,a3,0x3
ffffffffc02034e0:	96aa                	add	a3,a3,a0
ffffffffc02034e2:	02d50d63          	beq	a0,a3,ffffffffc020351c <default_free_pages+0x4c>
ffffffffc02034e6:	651c                	ld	a5,8(a0)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02034e8:	8b85                	andi	a5,a5,1
ffffffffc02034ea:	14079563          	bnez	a5,ffffffffc0203634 <default_free_pages+0x164>
ffffffffc02034ee:	651c                	ld	a5,8(a0)
ffffffffc02034f0:	8385                	srli	a5,a5,0x1
ffffffffc02034f2:	8b85                	andi	a5,a5,1
ffffffffc02034f4:	14079063          	bnez	a5,ffffffffc0203634 <default_free_pages+0x164>
ffffffffc02034f8:	87aa                	mv	a5,a0
ffffffffc02034fa:	a809                	j	ffffffffc020350c <default_free_pages+0x3c>
ffffffffc02034fc:	6798                	ld	a4,8(a5)
ffffffffc02034fe:	8b05                	andi	a4,a4,1
ffffffffc0203500:	12071a63          	bnez	a4,ffffffffc0203634 <default_free_pages+0x164>
ffffffffc0203504:	6798                	ld	a4,8(a5)
ffffffffc0203506:	8b09                	andi	a4,a4,2
ffffffffc0203508:	12071663          	bnez	a4,ffffffffc0203634 <default_free_pages+0x164>
        p->flags = 0;
ffffffffc020350c:	0007b423          	sd	zero,8(a5)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0203510:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0203514:	04878793          	addi	a5,a5,72
ffffffffc0203518:	fed792e3          	bne	a5,a3,ffffffffc02034fc <default_free_pages+0x2c>
    base->property = n;
ffffffffc020351c:	2581                	sext.w	a1,a1
ffffffffc020351e:	cd0c                	sw	a1,24(a0)
    SetPageProperty(base);
ffffffffc0203520:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0203524:	4789                	li	a5,2
ffffffffc0203526:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc020352a:	0000e697          	auipc	a3,0xe
ffffffffc020352e:	04668693          	addi	a3,a3,70 # ffffffffc0211570 <free_area_bf>
ffffffffc0203532:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0203534:	669c                	ld	a5,8(a3)
ffffffffc0203536:	9db9                	addw	a1,a1,a4
ffffffffc0203538:	0000e717          	auipc	a4,0xe
ffffffffc020353c:	04b72423          	sw	a1,72(a4) # ffffffffc0211580 <free_area_bf+0x10>
    if (list_empty(&free_list)) {
ffffffffc0203540:	08d78f63          	beq	a5,a3,ffffffffc02035de <default_free_pages+0x10e>
            struct Page* page = le2page(le, page_link);
ffffffffc0203544:	fe078713          	addi	a4,a5,-32
ffffffffc0203548:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc020354a:	4801                	li	a6,0
ffffffffc020354c:	02050613          	addi	a2,a0,32
            if (base < page) {
ffffffffc0203550:	00e56a63          	bltu	a0,a4,ffffffffc0203564 <default_free_pages+0x94>
    return listelm->next;
ffffffffc0203554:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0203556:	02d70563          	beq	a4,a3,ffffffffc0203580 <default_free_pages+0xb0>
        while ((le = list_next(le)) != &free_list) {
ffffffffc020355a:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc020355c:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc0203560:	fee57ae3          	bgeu	a0,a4,ffffffffc0203554 <default_free_pages+0x84>
ffffffffc0203564:	00080663          	beqz	a6,ffffffffc0203570 <default_free_pages+0xa0>
ffffffffc0203568:	0000e817          	auipc	a6,0xe
ffffffffc020356c:	00b83423          	sd	a1,8(a6) # ffffffffc0211570 <free_area_bf>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0203570:	638c                	ld	a1,0(a5)
    prev->next = next->prev = elm;
ffffffffc0203572:	e390                	sd	a2,0(a5)
ffffffffc0203574:	e590                	sd	a2,8(a1)
    elm->next = next;
ffffffffc0203576:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc0203578:	f10c                	sd	a1,32(a0)
    if (le != &free_list) {
ffffffffc020357a:	02d59163          	bne	a1,a3,ffffffffc020359c <default_free_pages+0xcc>
ffffffffc020357e:	a091                	j	ffffffffc02035c2 <default_free_pages+0xf2>
    prev->next = next->prev = elm;
ffffffffc0203580:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0203582:	f514                	sd	a3,40(a0)
ffffffffc0203584:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0203586:	f11c                	sd	a5,32(a0)
                list_add(le, &(base->page_link));
ffffffffc0203588:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc020358a:	00d70563          	beq	a4,a3,ffffffffc0203594 <default_free_pages+0xc4>
ffffffffc020358e:	4805                	li	a6,1
ffffffffc0203590:	87ba                	mv	a5,a4
ffffffffc0203592:	b7e9                	j	ffffffffc020355c <default_free_pages+0x8c>
ffffffffc0203594:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc0203596:	85be                	mv	a1,a5
    if (le != &free_list) {
ffffffffc0203598:	02d78163          	beq	a5,a3,ffffffffc02035ba <default_free_pages+0xea>
        if (p + p->property == base) {
ffffffffc020359c:	ff85a803          	lw	a6,-8(a1) # ff8 <BASE_ADDRESS-0xffffffffc01ff008>
        p = le2page(le, page_link);
ffffffffc02035a0:	fe058613          	addi	a2,a1,-32
        if (p + p->property == base) {
ffffffffc02035a4:	02081713          	slli	a4,a6,0x20
ffffffffc02035a8:	9301                	srli	a4,a4,0x20
ffffffffc02035aa:	00371793          	slli	a5,a4,0x3
ffffffffc02035ae:	97ba                	add	a5,a5,a4
ffffffffc02035b0:	078e                	slli	a5,a5,0x3
ffffffffc02035b2:	97b2                	add	a5,a5,a2
ffffffffc02035b4:	02f50e63          	beq	a0,a5,ffffffffc02035f0 <default_free_pages+0x120>
ffffffffc02035b8:	751c                	ld	a5,40(a0)
    if (le != &free_list) {
ffffffffc02035ba:	fe078713          	addi	a4,a5,-32
ffffffffc02035be:	00d78d63          	beq	a5,a3,ffffffffc02035d8 <default_free_pages+0x108>
        if (base + base->property == p) {
ffffffffc02035c2:	4d0c                	lw	a1,24(a0)
ffffffffc02035c4:	02059613          	slli	a2,a1,0x20
ffffffffc02035c8:	9201                	srli	a2,a2,0x20
ffffffffc02035ca:	00361693          	slli	a3,a2,0x3
ffffffffc02035ce:	96b2                	add	a3,a3,a2
ffffffffc02035d0:	068e                	slli	a3,a3,0x3
ffffffffc02035d2:	96aa                	add	a3,a3,a0
ffffffffc02035d4:	04d70063          	beq	a4,a3,ffffffffc0203614 <default_free_pages+0x144>
}
ffffffffc02035d8:	60a2                	ld	ra,8(sp)
ffffffffc02035da:	0141                	addi	sp,sp,16
ffffffffc02035dc:	8082                	ret
ffffffffc02035de:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc02035e0:	02050713          	addi	a4,a0,32
    prev->next = next->prev = elm;
ffffffffc02035e4:	e398                	sd	a4,0(a5)
ffffffffc02035e6:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc02035e8:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc02035ea:	f11c                	sd	a5,32(a0)
}
ffffffffc02035ec:	0141                	addi	sp,sp,16
ffffffffc02035ee:	8082                	ret
            p->property += base->property;
ffffffffc02035f0:	4d1c                	lw	a5,24(a0)
ffffffffc02035f2:	0107883b          	addw	a6,a5,a6
ffffffffc02035f6:	ff05ac23          	sw	a6,-8(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02035fa:	57f5                	li	a5,-3
ffffffffc02035fc:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0203600:	02053803          	ld	a6,32(a0)
ffffffffc0203604:	7518                	ld	a4,40(a0)
            base = p;
ffffffffc0203606:	8532                	mv	a0,a2
    prev->next = next;
ffffffffc0203608:	00e83423          	sd	a4,8(a6)
    next->prev = prev;
ffffffffc020360c:	659c                	ld	a5,8(a1)
ffffffffc020360e:	01073023          	sd	a6,0(a4)
ffffffffc0203612:	b765                	j	ffffffffc02035ba <default_free_pages+0xea>
            base->property += p->property;
ffffffffc0203614:	ff87a703          	lw	a4,-8(a5)
ffffffffc0203618:	fe878693          	addi	a3,a5,-24
ffffffffc020361c:	9db9                	addw	a1,a1,a4
ffffffffc020361e:	cd0c                	sw	a1,24(a0)
ffffffffc0203620:	5775                	li	a4,-3
ffffffffc0203622:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0203626:	6398                	ld	a4,0(a5)
ffffffffc0203628:	679c                	ld	a5,8(a5)
}
ffffffffc020362a:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc020362c:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc020362e:	e398                	sd	a4,0(a5)
ffffffffc0203630:	0141                	addi	sp,sp,16
ffffffffc0203632:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0203634:	00002697          	auipc	a3,0x2
ffffffffc0203638:	6a468693          	addi	a3,a3,1700 # ffffffffc0205cd8 <commands+0x18c8>
ffffffffc020363c:	00001617          	auipc	a2,0x1
ffffffffc0203640:	7c460613          	addi	a2,a2,1988 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc0203644:	08300593          	li	a1,131
ffffffffc0203648:	00002517          	auipc	a0,0x2
ffffffffc020364c:	38050513          	addi	a0,a0,896 # ffffffffc02059c8 <commands+0x15b8>
ffffffffc0203650:	ab5fc0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert(n > 0);
ffffffffc0203654:	00002697          	auipc	a3,0x2
ffffffffc0203658:	6ac68693          	addi	a3,a3,1708 # ffffffffc0205d00 <commands+0x18f0>
ffffffffc020365c:	00001617          	auipc	a2,0x1
ffffffffc0203660:	7a460613          	addi	a2,a2,1956 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc0203664:	08000593          	li	a1,128
ffffffffc0203668:	00002517          	auipc	a0,0x2
ffffffffc020366c:	36050513          	addi	a0,a0,864 # ffffffffc02059c8 <commands+0x15b8>
ffffffffc0203670:	a95fc0ef          	jal	ra,ffffffffc0200104 <__panic>

ffffffffc0203674 <default_alloc_pages>:
    assert(n > 0);
ffffffffc0203674:	cd51                	beqz	a0,ffffffffc0203710 <default_alloc_pages+0x9c>
    if (n > nr_free) {
ffffffffc0203676:	0000e597          	auipc	a1,0xe
ffffffffc020367a:	efa58593          	addi	a1,a1,-262 # ffffffffc0211570 <free_area_bf>
ffffffffc020367e:	0105a803          	lw	a6,16(a1)
ffffffffc0203682:	862a                	mv	a2,a0
ffffffffc0203684:	02081793          	slli	a5,a6,0x20
ffffffffc0203688:	9381                	srli	a5,a5,0x20
ffffffffc020368a:	00a7ee63          	bltu	a5,a0,ffffffffc02036a6 <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc020368e:	87ae                	mv	a5,a1
ffffffffc0203690:	a801                	j	ffffffffc02036a0 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc0203692:	ff87a703          	lw	a4,-8(a5)
ffffffffc0203696:	02071693          	slli	a3,a4,0x20
ffffffffc020369a:	9281                	srli	a3,a3,0x20
ffffffffc020369c:	00c6f763          	bgeu	a3,a2,ffffffffc02036aa <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc02036a0:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc02036a2:	feb798e3          	bne	a5,a1,ffffffffc0203692 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc02036a6:	4501                	li	a0,0
}
ffffffffc02036a8:	8082                	ret
        struct Page *p = le2page(le, page_link);
ffffffffc02036aa:	fe078513          	addi	a0,a5,-32
    if (page != NULL) {
ffffffffc02036ae:	dd6d                	beqz	a0,ffffffffc02036a8 <default_alloc_pages+0x34>
    return listelm->prev;
ffffffffc02036b0:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc02036b4:	0087b303          	ld	t1,8(a5)
    prev->next = next;
ffffffffc02036b8:	00060e1b          	sext.w	t3,a2
ffffffffc02036bc:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc02036c0:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc02036c4:	02d67b63          	bgeu	a2,a3,ffffffffc02036fa <default_alloc_pages+0x86>
            struct Page *p = page + n;
ffffffffc02036c8:	00361693          	slli	a3,a2,0x3
ffffffffc02036cc:	96b2                	add	a3,a3,a2
ffffffffc02036ce:	068e                	slli	a3,a3,0x3
ffffffffc02036d0:	96aa                	add	a3,a3,a0
            p->property = page->property - n;
ffffffffc02036d2:	41c7073b          	subw	a4,a4,t3
ffffffffc02036d6:	ce98                	sw	a4,24(a3)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02036d8:	00868613          	addi	a2,a3,8
ffffffffc02036dc:	4709                	li	a4,2
ffffffffc02036de:	40e6302f          	amoor.d	zero,a4,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc02036e2:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc02036e6:	02068613          	addi	a2,a3,32
    prev->next = next->prev = elm;
ffffffffc02036ea:	0105a803          	lw	a6,16(a1)
ffffffffc02036ee:	e310                	sd	a2,0(a4)
ffffffffc02036f0:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc02036f4:	f698                	sd	a4,40(a3)
    elm->prev = prev;
ffffffffc02036f6:	0316b023          	sd	a7,32(a3)
        nr_free -= n;
ffffffffc02036fa:	41c8083b          	subw	a6,a6,t3
ffffffffc02036fe:	0000e717          	auipc	a4,0xe
ffffffffc0203702:	e9072123          	sw	a6,-382(a4) # ffffffffc0211580 <free_area_bf+0x10>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0203706:	5775                	li	a4,-3
ffffffffc0203708:	17a1                	addi	a5,a5,-24
ffffffffc020370a:	60e7b02f          	amoand.d	zero,a4,(a5)
ffffffffc020370e:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc0203710:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0203712:	00002697          	auipc	a3,0x2
ffffffffc0203716:	5ee68693          	addi	a3,a3,1518 # ffffffffc0205d00 <commands+0x18f0>
ffffffffc020371a:	00001617          	auipc	a2,0x1
ffffffffc020371e:	6e660613          	addi	a2,a2,1766 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc0203722:	06200593          	li	a1,98
ffffffffc0203726:	00002517          	auipc	a0,0x2
ffffffffc020372a:	2a250513          	addi	a0,a0,674 # ffffffffc02059c8 <commands+0x15b8>
default_alloc_pages(size_t n) {
ffffffffc020372e:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0203730:	9d5fc0ef          	jal	ra,ffffffffc0200104 <__panic>

ffffffffc0203734 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc0203734:	1141                	addi	sp,sp,-16
ffffffffc0203736:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0203738:	c1fd                	beqz	a1,ffffffffc020381e <default_init_memmap+0xea>
    for (; p != base + n; p ++) {
ffffffffc020373a:	00359693          	slli	a3,a1,0x3
ffffffffc020373e:	96ae                	add	a3,a3,a1
ffffffffc0203740:	068e                	slli	a3,a3,0x3
ffffffffc0203742:	96aa                	add	a3,a3,a0
ffffffffc0203744:	02d50463          	beq	a0,a3,ffffffffc020376c <default_init_memmap+0x38>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0203748:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc020374a:	87aa                	mv	a5,a0
ffffffffc020374c:	8b05                	andi	a4,a4,1
ffffffffc020374e:	e709                	bnez	a4,ffffffffc0203758 <default_init_memmap+0x24>
ffffffffc0203750:	a07d                	j	ffffffffc02037fe <default_init_memmap+0xca>
ffffffffc0203752:	6798                	ld	a4,8(a5)
ffffffffc0203754:	8b05                	andi	a4,a4,1
ffffffffc0203756:	c745                	beqz	a4,ffffffffc02037fe <default_init_memmap+0xca>
        p->flags = p->property = 0;
ffffffffc0203758:	0007ac23          	sw	zero,24(a5)
ffffffffc020375c:	0007b423          	sd	zero,8(a5)
ffffffffc0203760:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0203764:	04878793          	addi	a5,a5,72
ffffffffc0203768:	fed795e3          	bne	a5,a3,ffffffffc0203752 <default_init_memmap+0x1e>
    base->property = n;
ffffffffc020376c:	2581                	sext.w	a1,a1
ffffffffc020376e:	cd0c                	sw	a1,24(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0203770:	4789                	li	a5,2
ffffffffc0203772:	00850713          	addi	a4,a0,8
ffffffffc0203776:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc020377a:	0000e697          	auipc	a3,0xe
ffffffffc020377e:	df668693          	addi	a3,a3,-522 # ffffffffc0211570 <free_area_bf>
ffffffffc0203782:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0203784:	669c                	ld	a5,8(a3)
ffffffffc0203786:	9db9                	addw	a1,a1,a4
ffffffffc0203788:	0000e717          	auipc	a4,0xe
ffffffffc020378c:	deb72c23          	sw	a1,-520(a4) # ffffffffc0211580 <free_area_bf+0x10>
    if (list_empty(&free_list)) {
ffffffffc0203790:	04d78a63          	beq	a5,a3,ffffffffc02037e4 <default_init_memmap+0xb0>
            struct Page* page = le2page(le, page_link);
ffffffffc0203794:	fe078713          	addi	a4,a5,-32
ffffffffc0203798:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc020379a:	4801                	li	a6,0
ffffffffc020379c:	02050613          	addi	a2,a0,32
            if (base < page) {
ffffffffc02037a0:	00e56a63          	bltu	a0,a4,ffffffffc02037b4 <default_init_memmap+0x80>
    return listelm->next;
ffffffffc02037a4:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02037a6:	02d70563          	beq	a4,a3,ffffffffc02037d0 <default_init_memmap+0x9c>
        while ((le = list_next(le)) != &free_list) {
ffffffffc02037aa:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02037ac:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc02037b0:	fee57ae3          	bgeu	a0,a4,ffffffffc02037a4 <default_init_memmap+0x70>
ffffffffc02037b4:	00080663          	beqz	a6,ffffffffc02037c0 <default_init_memmap+0x8c>
ffffffffc02037b8:	0000e717          	auipc	a4,0xe
ffffffffc02037bc:	dab73c23          	sd	a1,-584(a4) # ffffffffc0211570 <free_area_bf>
    __list_add(elm, listelm->prev, listelm);
ffffffffc02037c0:	6398                	ld	a4,0(a5)
}
ffffffffc02037c2:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc02037c4:	e390                	sd	a2,0(a5)
ffffffffc02037c6:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02037c8:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc02037ca:	f118                	sd	a4,32(a0)
ffffffffc02037cc:	0141                	addi	sp,sp,16
ffffffffc02037ce:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02037d0:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02037d2:	f514                	sd	a3,40(a0)
ffffffffc02037d4:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02037d6:	f11c                	sd	a5,32(a0)
                list_add(le, &(base->page_link));
ffffffffc02037d8:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc02037da:	00d70e63          	beq	a4,a3,ffffffffc02037f6 <default_init_memmap+0xc2>
ffffffffc02037de:	4805                	li	a6,1
ffffffffc02037e0:	87ba                	mv	a5,a4
ffffffffc02037e2:	b7e9                	j	ffffffffc02037ac <default_init_memmap+0x78>
}
ffffffffc02037e4:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc02037e6:	02050713          	addi	a4,a0,32
    prev->next = next->prev = elm;
ffffffffc02037ea:	e398                	sd	a4,0(a5)
ffffffffc02037ec:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc02037ee:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc02037f0:	f11c                	sd	a5,32(a0)
}
ffffffffc02037f2:	0141                	addi	sp,sp,16
ffffffffc02037f4:	8082                	ret
ffffffffc02037f6:	60a2                	ld	ra,8(sp)
ffffffffc02037f8:	e290                	sd	a2,0(a3)
ffffffffc02037fa:	0141                	addi	sp,sp,16
ffffffffc02037fc:	8082                	ret
        assert(PageReserved(p));
ffffffffc02037fe:	00002697          	auipc	a3,0x2
ffffffffc0203802:	50a68693          	addi	a3,a3,1290 # ffffffffc0205d08 <commands+0x18f8>
ffffffffc0203806:	00001617          	auipc	a2,0x1
ffffffffc020380a:	5fa60613          	addi	a2,a2,1530 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc020380e:	04900593          	li	a1,73
ffffffffc0203812:	00002517          	auipc	a0,0x2
ffffffffc0203816:	1b650513          	addi	a0,a0,438 # ffffffffc02059c8 <commands+0x15b8>
ffffffffc020381a:	8ebfc0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert(n > 0);
ffffffffc020381e:	00002697          	auipc	a3,0x2
ffffffffc0203822:	4e268693          	addi	a3,a3,1250 # ffffffffc0205d00 <commands+0x18f0>
ffffffffc0203826:	00001617          	auipc	a2,0x1
ffffffffc020382a:	5da60613          	addi	a2,a2,1498 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc020382e:	04600593          	li	a1,70
ffffffffc0203832:	00002517          	auipc	a0,0x2
ffffffffc0203836:	19650513          	addi	a0,a0,406 # ffffffffc02059c8 <commands+0x15b8>
ffffffffc020383a:	8cbfc0ef          	jal	ra,ffffffffc0200104 <__panic>

ffffffffc020383e <_clock_init>:

static int
_clock_init(void)
{
    return 0;
}
ffffffffc020383e:	4501                	li	a0,0
ffffffffc0203840:	8082                	ret

ffffffffc0203842 <_clock_set_unswappable>:

static int
_clock_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc0203842:	4501                	li	a0,0
ffffffffc0203844:	8082                	ret

ffffffffc0203846 <_clock_tick_event>:

static int
_clock_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc0203846:	4501                	li	a0,0
ffffffffc0203848:	8082                	ret

ffffffffc020384a <_clock_check_swap>:
_clock_check_swap(void) {
ffffffffc020384a:	1141                	addi	sp,sp,-16
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc020384c:	678d                	lui	a5,0x3
ffffffffc020384e:	4731                	li	a4,12
_clock_check_swap(void) {
ffffffffc0203850:	e406                	sd	ra,8(sp)
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203852:	00e78023          	sb	a4,0(a5) # 3000 <BASE_ADDRESS-0xffffffffc01fd000>
    assert(pgfault_num==4);
ffffffffc0203856:	0000e797          	auipc	a5,0xe
ffffffffc020385a:	c0a78793          	addi	a5,a5,-1014 # ffffffffc0211460 <pgfault_num>
ffffffffc020385e:	4398                	lw	a4,0(a5)
ffffffffc0203860:	4691                	li	a3,4
ffffffffc0203862:	2701                	sext.w	a4,a4
ffffffffc0203864:	08d71f63          	bne	a4,a3,ffffffffc0203902 <_clock_check_swap+0xb8>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203868:	6685                	lui	a3,0x1
ffffffffc020386a:	4629                	li	a2,10
ffffffffc020386c:	00c68023          	sb	a2,0(a3) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
    assert(pgfault_num==4);
ffffffffc0203870:	4394                	lw	a3,0(a5)
ffffffffc0203872:	2681                	sext.w	a3,a3
ffffffffc0203874:	20e69763          	bne	a3,a4,ffffffffc0203a82 <_clock_check_swap+0x238>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203878:	6711                	lui	a4,0x4
ffffffffc020387a:	4635                	li	a2,13
ffffffffc020387c:	00c70023          	sb	a2,0(a4) # 4000 <BASE_ADDRESS-0xffffffffc01fc000>
    assert(pgfault_num==4);
ffffffffc0203880:	4398                	lw	a4,0(a5)
ffffffffc0203882:	2701                	sext.w	a4,a4
ffffffffc0203884:	1cd71f63          	bne	a4,a3,ffffffffc0203a62 <_clock_check_swap+0x218>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203888:	6689                	lui	a3,0x2
ffffffffc020388a:	462d                	li	a2,11
ffffffffc020388c:	00c68023          	sb	a2,0(a3) # 2000 <BASE_ADDRESS-0xffffffffc01fe000>
    assert(pgfault_num==4);
ffffffffc0203890:	4394                	lw	a3,0(a5)
ffffffffc0203892:	2681                	sext.w	a3,a3
ffffffffc0203894:	1ae69763          	bne	a3,a4,ffffffffc0203a42 <_clock_check_swap+0x1f8>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203898:	6715                	lui	a4,0x5
ffffffffc020389a:	46b9                	li	a3,14
ffffffffc020389c:	00d70023          	sb	a3,0(a4) # 5000 <BASE_ADDRESS-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc02038a0:	4398                	lw	a4,0(a5)
ffffffffc02038a2:	4695                	li	a3,5
ffffffffc02038a4:	2701                	sext.w	a4,a4
ffffffffc02038a6:	16d71e63          	bne	a4,a3,ffffffffc0203a22 <_clock_check_swap+0x1d8>
    assert(pgfault_num==5);
ffffffffc02038aa:	4394                	lw	a3,0(a5)
ffffffffc02038ac:	2681                	sext.w	a3,a3
ffffffffc02038ae:	14e69a63          	bne	a3,a4,ffffffffc0203a02 <_clock_check_swap+0x1b8>
    assert(pgfault_num==5);
ffffffffc02038b2:	4398                	lw	a4,0(a5)
ffffffffc02038b4:	2701                	sext.w	a4,a4
ffffffffc02038b6:	12d71663          	bne	a4,a3,ffffffffc02039e2 <_clock_check_swap+0x198>
    assert(pgfault_num==5);
ffffffffc02038ba:	4394                	lw	a3,0(a5)
ffffffffc02038bc:	2681                	sext.w	a3,a3
ffffffffc02038be:	10e69263          	bne	a3,a4,ffffffffc02039c2 <_clock_check_swap+0x178>
    assert(pgfault_num==5);
ffffffffc02038c2:	4398                	lw	a4,0(a5)
ffffffffc02038c4:	2701                	sext.w	a4,a4
ffffffffc02038c6:	0cd71e63          	bne	a4,a3,ffffffffc02039a2 <_clock_check_swap+0x158>
    assert(pgfault_num==5);
ffffffffc02038ca:	4394                	lw	a3,0(a5)
ffffffffc02038cc:	2681                	sext.w	a3,a3
ffffffffc02038ce:	0ae69a63          	bne	a3,a4,ffffffffc0203982 <_clock_check_swap+0x138>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc02038d2:	6715                	lui	a4,0x5
ffffffffc02038d4:	46b9                	li	a3,14
ffffffffc02038d6:	00d70023          	sb	a3,0(a4) # 5000 <BASE_ADDRESS-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc02038da:	4398                	lw	a4,0(a5)
ffffffffc02038dc:	4695                	li	a3,5
ffffffffc02038de:	2701                	sext.w	a4,a4
ffffffffc02038e0:	08d71163          	bne	a4,a3,ffffffffc0203962 <_clock_check_swap+0x118>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc02038e4:	6705                	lui	a4,0x1
ffffffffc02038e6:	00074683          	lbu	a3,0(a4) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
ffffffffc02038ea:	4729                	li	a4,10
ffffffffc02038ec:	04e69b63          	bne	a3,a4,ffffffffc0203942 <_clock_check_swap+0xf8>
    assert(pgfault_num==6);
ffffffffc02038f0:	439c                	lw	a5,0(a5)
ffffffffc02038f2:	4719                	li	a4,6
ffffffffc02038f4:	2781                	sext.w	a5,a5
ffffffffc02038f6:	02e79663          	bne	a5,a4,ffffffffc0203922 <_clock_check_swap+0xd8>
}
ffffffffc02038fa:	60a2                	ld	ra,8(sp)
ffffffffc02038fc:	4501                	li	a0,0
ffffffffc02038fe:	0141                	addi	sp,sp,16
ffffffffc0203900:	8082                	ret
    assert(pgfault_num==4);
ffffffffc0203902:	00002697          	auipc	a3,0x2
ffffffffc0203906:	f5668693          	addi	a3,a3,-170 # ffffffffc0205858 <commands+0x1448>
ffffffffc020390a:	00001617          	auipc	a2,0x1
ffffffffc020390e:	4f660613          	addi	a2,a2,1270 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc0203912:	08f00593          	li	a1,143
ffffffffc0203916:	00002517          	auipc	a0,0x2
ffffffffc020391a:	45250513          	addi	a0,a0,1106 # ffffffffc0205d68 <default_pmm_manager+0x50>
ffffffffc020391e:	fe6fc0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert(pgfault_num==6);
ffffffffc0203922:	00002697          	auipc	a3,0x2
ffffffffc0203926:	49668693          	addi	a3,a3,1174 # ffffffffc0205db8 <default_pmm_manager+0xa0>
ffffffffc020392a:	00001617          	auipc	a2,0x1
ffffffffc020392e:	4d660613          	addi	a2,a2,1238 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc0203932:	0a600593          	li	a1,166
ffffffffc0203936:	00002517          	auipc	a0,0x2
ffffffffc020393a:	43250513          	addi	a0,a0,1074 # ffffffffc0205d68 <default_pmm_manager+0x50>
ffffffffc020393e:	fc6fc0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203942:	00002697          	auipc	a3,0x2
ffffffffc0203946:	44e68693          	addi	a3,a3,1102 # ffffffffc0205d90 <default_pmm_manager+0x78>
ffffffffc020394a:	00001617          	auipc	a2,0x1
ffffffffc020394e:	4b660613          	addi	a2,a2,1206 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc0203952:	0a400593          	li	a1,164
ffffffffc0203956:	00002517          	auipc	a0,0x2
ffffffffc020395a:	41250513          	addi	a0,a0,1042 # ffffffffc0205d68 <default_pmm_manager+0x50>
ffffffffc020395e:	fa6fc0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert(pgfault_num==5);
ffffffffc0203962:	00002697          	auipc	a3,0x2
ffffffffc0203966:	41e68693          	addi	a3,a3,1054 # ffffffffc0205d80 <default_pmm_manager+0x68>
ffffffffc020396a:	00001617          	auipc	a2,0x1
ffffffffc020396e:	49660613          	addi	a2,a2,1174 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc0203972:	0a300593          	li	a1,163
ffffffffc0203976:	00002517          	auipc	a0,0x2
ffffffffc020397a:	3f250513          	addi	a0,a0,1010 # ffffffffc0205d68 <default_pmm_manager+0x50>
ffffffffc020397e:	f86fc0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert(pgfault_num==5);
ffffffffc0203982:	00002697          	auipc	a3,0x2
ffffffffc0203986:	3fe68693          	addi	a3,a3,1022 # ffffffffc0205d80 <default_pmm_manager+0x68>
ffffffffc020398a:	00001617          	auipc	a2,0x1
ffffffffc020398e:	47660613          	addi	a2,a2,1142 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc0203992:	0a100593          	li	a1,161
ffffffffc0203996:	00002517          	auipc	a0,0x2
ffffffffc020399a:	3d250513          	addi	a0,a0,978 # ffffffffc0205d68 <default_pmm_manager+0x50>
ffffffffc020399e:	f66fc0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert(pgfault_num==5);
ffffffffc02039a2:	00002697          	auipc	a3,0x2
ffffffffc02039a6:	3de68693          	addi	a3,a3,990 # ffffffffc0205d80 <default_pmm_manager+0x68>
ffffffffc02039aa:	00001617          	auipc	a2,0x1
ffffffffc02039ae:	45660613          	addi	a2,a2,1110 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc02039b2:	09f00593          	li	a1,159
ffffffffc02039b6:	00002517          	auipc	a0,0x2
ffffffffc02039ba:	3b250513          	addi	a0,a0,946 # ffffffffc0205d68 <default_pmm_manager+0x50>
ffffffffc02039be:	f46fc0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert(pgfault_num==5);
ffffffffc02039c2:	00002697          	auipc	a3,0x2
ffffffffc02039c6:	3be68693          	addi	a3,a3,958 # ffffffffc0205d80 <default_pmm_manager+0x68>
ffffffffc02039ca:	00001617          	auipc	a2,0x1
ffffffffc02039ce:	43660613          	addi	a2,a2,1078 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc02039d2:	09d00593          	li	a1,157
ffffffffc02039d6:	00002517          	auipc	a0,0x2
ffffffffc02039da:	39250513          	addi	a0,a0,914 # ffffffffc0205d68 <default_pmm_manager+0x50>
ffffffffc02039de:	f26fc0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert(pgfault_num==5);
ffffffffc02039e2:	00002697          	auipc	a3,0x2
ffffffffc02039e6:	39e68693          	addi	a3,a3,926 # ffffffffc0205d80 <default_pmm_manager+0x68>
ffffffffc02039ea:	00001617          	auipc	a2,0x1
ffffffffc02039ee:	41660613          	addi	a2,a2,1046 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc02039f2:	09b00593          	li	a1,155
ffffffffc02039f6:	00002517          	auipc	a0,0x2
ffffffffc02039fa:	37250513          	addi	a0,a0,882 # ffffffffc0205d68 <default_pmm_manager+0x50>
ffffffffc02039fe:	f06fc0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert(pgfault_num==5);
ffffffffc0203a02:	00002697          	auipc	a3,0x2
ffffffffc0203a06:	37e68693          	addi	a3,a3,894 # ffffffffc0205d80 <default_pmm_manager+0x68>
ffffffffc0203a0a:	00001617          	auipc	a2,0x1
ffffffffc0203a0e:	3f660613          	addi	a2,a2,1014 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc0203a12:	09900593          	li	a1,153
ffffffffc0203a16:	00002517          	auipc	a0,0x2
ffffffffc0203a1a:	35250513          	addi	a0,a0,850 # ffffffffc0205d68 <default_pmm_manager+0x50>
ffffffffc0203a1e:	ee6fc0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert(pgfault_num==5);
ffffffffc0203a22:	00002697          	auipc	a3,0x2
ffffffffc0203a26:	35e68693          	addi	a3,a3,862 # ffffffffc0205d80 <default_pmm_manager+0x68>
ffffffffc0203a2a:	00001617          	auipc	a2,0x1
ffffffffc0203a2e:	3d660613          	addi	a2,a2,982 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc0203a32:	09700593          	li	a1,151
ffffffffc0203a36:	00002517          	auipc	a0,0x2
ffffffffc0203a3a:	33250513          	addi	a0,a0,818 # ffffffffc0205d68 <default_pmm_manager+0x50>
ffffffffc0203a3e:	ec6fc0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert(pgfault_num==4);
ffffffffc0203a42:	00002697          	auipc	a3,0x2
ffffffffc0203a46:	e1668693          	addi	a3,a3,-490 # ffffffffc0205858 <commands+0x1448>
ffffffffc0203a4a:	00001617          	auipc	a2,0x1
ffffffffc0203a4e:	3b660613          	addi	a2,a2,950 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc0203a52:	09500593          	li	a1,149
ffffffffc0203a56:	00002517          	auipc	a0,0x2
ffffffffc0203a5a:	31250513          	addi	a0,a0,786 # ffffffffc0205d68 <default_pmm_manager+0x50>
ffffffffc0203a5e:	ea6fc0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert(pgfault_num==4);
ffffffffc0203a62:	00002697          	auipc	a3,0x2
ffffffffc0203a66:	df668693          	addi	a3,a3,-522 # ffffffffc0205858 <commands+0x1448>
ffffffffc0203a6a:	00001617          	auipc	a2,0x1
ffffffffc0203a6e:	39660613          	addi	a2,a2,918 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc0203a72:	09300593          	li	a1,147
ffffffffc0203a76:	00002517          	auipc	a0,0x2
ffffffffc0203a7a:	2f250513          	addi	a0,a0,754 # ffffffffc0205d68 <default_pmm_manager+0x50>
ffffffffc0203a7e:	e86fc0ef          	jal	ra,ffffffffc0200104 <__panic>
    assert(pgfault_num==4);
ffffffffc0203a82:	00002697          	auipc	a3,0x2
ffffffffc0203a86:	dd668693          	addi	a3,a3,-554 # ffffffffc0205858 <commands+0x1448>
ffffffffc0203a8a:	00001617          	auipc	a2,0x1
ffffffffc0203a8e:	37660613          	addi	a2,a2,886 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc0203a92:	09100593          	li	a1,145
ffffffffc0203a96:	00002517          	auipc	a0,0x2
ffffffffc0203a9a:	2d250513          	addi	a0,a0,722 # ffffffffc0205d68 <default_pmm_manager+0x50>
ffffffffc0203a9e:	e66fc0ef          	jal	ra,ffffffffc0200104 <__panic>

ffffffffc0203aa2 <_clock_init_mm>:
{     
ffffffffc0203aa2:	1141                	addi	sp,sp,-16
ffffffffc0203aa4:	e406                	sd	ra,8(sp)
    elm->prev = elm->next = elm;
ffffffffc0203aa6:	0000e797          	auipc	a5,0xe
ffffffffc0203aaa:	ae278793          	addi	a5,a5,-1310 # ffffffffc0211588 <pra_list_head>
     mm->sm_priv = &pra_list_head;
ffffffffc0203aae:	f51c                	sd	a5,40(a0)
     cprintf(" curr_ptr %x in clock_init_mm\n",curr_ptr);
ffffffffc0203ab0:	85be                	mv	a1,a5
ffffffffc0203ab2:	00002517          	auipc	a0,0x2
ffffffffc0203ab6:	31650513          	addi	a0,a0,790 # ffffffffc0205dc8 <default_pmm_manager+0xb0>
ffffffffc0203aba:	e79c                	sd	a5,8(a5)
ffffffffc0203abc:	e39c                	sd	a5,0(a5)
     curr_ptr = &pra_list_head;
ffffffffc0203abe:	0000e717          	auipc	a4,0xe
ffffffffc0203ac2:	acf73d23          	sd	a5,-1318(a4) # ffffffffc0211598 <curr_ptr>
     cprintf(" curr_ptr %x in clock_init_mm\n",curr_ptr);
ffffffffc0203ac6:	df8fc0ef          	jal	ra,ffffffffc02000be <cprintf>
}
ffffffffc0203aca:	60a2                	ld	ra,8(sp)
ffffffffc0203acc:	4501                	li	a0,0
ffffffffc0203ace:	0141                	addi	sp,sp,16
ffffffffc0203ad0:	8082                	ret

ffffffffc0203ad2 <_clock_map_swappable>:
    list_entry_t *entry=&(page->pra_page_link);
ffffffffc0203ad2:	03060713          	addi	a4,a2,48
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc0203ad6:	c305                	beqz	a4,ffffffffc0203af6 <_clock_map_swappable+0x24>
ffffffffc0203ad8:	0000e797          	auipc	a5,0xe
ffffffffc0203adc:	ac078793          	addi	a5,a5,-1344 # ffffffffc0211598 <curr_ptr>
ffffffffc0203ae0:	639c                	ld	a5,0(a5)
ffffffffc0203ae2:	cb91                	beqz	a5,ffffffffc0203af6 <_clock_map_swappable+0x24>
    __list_add(elm, listelm, listelm->next);
ffffffffc0203ae4:	6794                	ld	a3,8(a5)
}
ffffffffc0203ae6:	4501                	li	a0,0
    prev->next = next->prev = elm;
ffffffffc0203ae8:	e298                	sd	a4,0(a3)
ffffffffc0203aea:	e798                	sd	a4,8(a5)
    elm->prev = prev;
ffffffffc0203aec:	fa1c                	sd	a5,48(a2)
    page->visited=1;
ffffffffc0203aee:	4785                	li	a5,1
    elm->next = next;
ffffffffc0203af0:	fe14                	sd	a3,56(a2)
ffffffffc0203af2:	ea1c                	sd	a5,16(a2)
}
ffffffffc0203af4:	8082                	ret
{
ffffffffc0203af6:	1141                	addi	sp,sp,-16
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc0203af8:	00002697          	auipc	a3,0x2
ffffffffc0203afc:	2f068693          	addi	a3,a3,752 # ffffffffc0205de8 <default_pmm_manager+0xd0>
ffffffffc0203b00:	00001617          	auipc	a2,0x1
ffffffffc0203b04:	30060613          	addi	a2,a2,768 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc0203b08:	03600593          	li	a1,54
ffffffffc0203b0c:	00002517          	auipc	a0,0x2
ffffffffc0203b10:	25c50513          	addi	a0,a0,604 # ffffffffc0205d68 <default_pmm_manager+0x50>
{
ffffffffc0203b14:	e406                	sd	ra,8(sp)
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc0203b16:	deefc0ef          	jal	ra,ffffffffc0200104 <__panic>

ffffffffc0203b1a <_clock_swap_out_victim>:
{
ffffffffc0203b1a:	7179                	addi	sp,sp,-48
ffffffffc0203b1c:	ec26                	sd	s1,24(sp)
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0203b1e:	7504                	ld	s1,40(a0)
{
ffffffffc0203b20:	f406                	sd	ra,40(sp)
ffffffffc0203b22:	f022                	sd	s0,32(sp)
ffffffffc0203b24:	e84a                	sd	s2,16(sp)
ffffffffc0203b26:	e44e                	sd	s3,8(sp)
ffffffffc0203b28:	e052                	sd	s4,0(sp)
         assert(head != NULL);
ffffffffc0203b2a:	c0b5                	beqz	s1,ffffffffc0203b8e <_clock_swap_out_victim+0x74>
ffffffffc0203b2c:	892a                	mv	s2,a0
ffffffffc0203b2e:	8a2e                	mv	s4,a1
     assert(in_tick==0);
ffffffffc0203b30:	8426                	mv	s0,s1
         if (ptr->visited== 1) {
ffffffffc0203b32:	4985                	li	s3,1
     assert(in_tick==0);
ffffffffc0203b34:	ce11                	beqz	a2,ffffffffc0203b50 <_clock_swap_out_victim+0x36>
ffffffffc0203b36:	a8a5                	j	ffffffffc0203bae <_clock_swap_out_victim+0x94>
         pte_t *pte = get_pte(mm -> pgdir, ptr -> pra_vaddr, 0);
ffffffffc0203b38:	680c                	ld	a1,16(s0)
ffffffffc0203b3a:	01893503          	ld	a0,24(s2)
ffffffffc0203b3e:	4601                	li	a2,0
ffffffffc0203b40:	89afd0ef          	jal	ra,ffffffffc0200bda <get_pte>
         if (ptr->visited== 1) {
ffffffffc0203b44:	fe043783          	ld	a5,-32(s0)
ffffffffc0203b48:	03379263          	bne	a5,s3,ffffffffc0203b6c <_clock_swap_out_victim+0x52>
             ptr->visited=0;
ffffffffc0203b4c:	fe043023          	sd	zero,-32(s0)
    return listelm->prev;
ffffffffc0203b50:	6000                	ld	s0,0(s0)
        if (p == head) {
ffffffffc0203b52:	fe8493e3          	bne	s1,s0,ffffffffc0203b38 <_clock_swap_out_victim+0x1e>
ffffffffc0203b56:	6080                	ld	s0,0(s1)
         pte_t *pte = get_pte(mm -> pgdir, ptr -> pra_vaddr, 0);
ffffffffc0203b58:	01893503          	ld	a0,24(s2)
ffffffffc0203b5c:	4601                	li	a2,0
ffffffffc0203b5e:	680c                	ld	a1,16(s0)
ffffffffc0203b60:	87afd0ef          	jal	ra,ffffffffc0200bda <get_pte>
         if (ptr->visited== 1) {
ffffffffc0203b64:	fe043783          	ld	a5,-32(s0)
ffffffffc0203b68:	ff3782e3          	beq	a5,s3,ffffffffc0203b4c <_clock_swap_out_victim+0x32>
    __list_del(listelm->prev, listelm->next);
ffffffffc0203b6c:	6018                	ld	a4,0(s0)
ffffffffc0203b6e:	641c                	ld	a5,8(s0)
         struct Page *ptr = le2page(p, pra_page_link);
ffffffffc0203b70:	fd040413          	addi	s0,s0,-48
             *ptr_page = ptr;
ffffffffc0203b74:	008a3023          	sd	s0,0(s4)
}
ffffffffc0203b78:	70a2                	ld	ra,40(sp)
ffffffffc0203b7a:	7402                	ld	s0,32(sp)
    prev->next = next;
ffffffffc0203b7c:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0203b7e:	e398                	sd	a4,0(a5)
ffffffffc0203b80:	64e2                	ld	s1,24(sp)
ffffffffc0203b82:	6942                	ld	s2,16(sp)
ffffffffc0203b84:	69a2                	ld	s3,8(sp)
ffffffffc0203b86:	6a02                	ld	s4,0(sp)
ffffffffc0203b88:	4501                	li	a0,0
ffffffffc0203b8a:	6145                	addi	sp,sp,48
ffffffffc0203b8c:	8082                	ret
         assert(head != NULL);
ffffffffc0203b8e:	00002697          	auipc	a3,0x2
ffffffffc0203b92:	28268693          	addi	a3,a3,642 # ffffffffc0205e10 <default_pmm_manager+0xf8>
ffffffffc0203b96:	00001617          	auipc	a2,0x1
ffffffffc0203b9a:	26a60613          	addi	a2,a2,618 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc0203b9e:	04900593          	li	a1,73
ffffffffc0203ba2:	00002517          	auipc	a0,0x2
ffffffffc0203ba6:	1c650513          	addi	a0,a0,454 # ffffffffc0205d68 <default_pmm_manager+0x50>
ffffffffc0203baa:	d5afc0ef          	jal	ra,ffffffffc0200104 <__panic>
     assert(in_tick==0);
ffffffffc0203bae:	00002697          	auipc	a3,0x2
ffffffffc0203bb2:	27268693          	addi	a3,a3,626 # ffffffffc0205e20 <default_pmm_manager+0x108>
ffffffffc0203bb6:	00001617          	auipc	a2,0x1
ffffffffc0203bba:	24a60613          	addi	a2,a2,586 # ffffffffc0204e00 <commands+0x9f0>
ffffffffc0203bbe:	04a00593          	li	a1,74
ffffffffc0203bc2:	00002517          	auipc	a0,0x2
ffffffffc0203bc6:	1a650513          	addi	a0,a0,422 # ffffffffc0205d68 <default_pmm_manager+0x50>
ffffffffc0203bca:	d3afc0ef          	jal	ra,ffffffffc0200104 <__panic>

ffffffffc0203bce <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0203bce:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203bd0:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0203bd2:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203bd4:	ffefc0ef          	jal	ra,ffffffffc02003d2 <ide_device_valid>
ffffffffc0203bd8:	cd01                	beqz	a0,ffffffffc0203bf0 <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203bda:	4505                	li	a0,1
ffffffffc0203bdc:	ffcfc0ef          	jal	ra,ffffffffc02003d8 <ide_device_size>
}
ffffffffc0203be0:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203be2:	810d                	srli	a0,a0,0x3
ffffffffc0203be4:	0000e797          	auipc	a5,0xe
ffffffffc0203be8:	94a7b623          	sd	a0,-1716(a5) # ffffffffc0211530 <max_swap_offset>
}
ffffffffc0203bec:	0141                	addi	sp,sp,16
ffffffffc0203bee:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0203bf0:	00002617          	auipc	a2,0x2
ffffffffc0203bf4:	25860613          	addi	a2,a2,600 # ffffffffc0205e48 <default_pmm_manager+0x130>
ffffffffc0203bf8:	45b5                	li	a1,13
ffffffffc0203bfa:	00002517          	auipc	a0,0x2
ffffffffc0203bfe:	26e50513          	addi	a0,a0,622 # ffffffffc0205e68 <default_pmm_manager+0x150>
ffffffffc0203c02:	d02fc0ef          	jal	ra,ffffffffc0200104 <__panic>

ffffffffc0203c06 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0203c06:	1141                	addi	sp,sp,-16
ffffffffc0203c08:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203c0a:	00855793          	srli	a5,a0,0x8
ffffffffc0203c0e:	c7b5                	beqz	a5,ffffffffc0203c7a <swapfs_read+0x74>
ffffffffc0203c10:	0000e717          	auipc	a4,0xe
ffffffffc0203c14:	92070713          	addi	a4,a4,-1760 # ffffffffc0211530 <max_swap_offset>
ffffffffc0203c18:	6318                	ld	a4,0(a4)
ffffffffc0203c1a:	06e7f063          	bgeu	a5,a4,ffffffffc0203c7a <swapfs_read+0x74>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203c1e:	0000e717          	auipc	a4,0xe
ffffffffc0203c22:	87a70713          	addi	a4,a4,-1926 # ffffffffc0211498 <pages>
ffffffffc0203c26:	6310                	ld	a2,0(a4)
ffffffffc0203c28:	00001717          	auipc	a4,0x1
ffffffffc0203c2c:	02070713          	addi	a4,a4,32 # ffffffffc0204c48 <commands+0x838>
ffffffffc0203c30:	00002697          	auipc	a3,0x2
ffffffffc0203c34:	4b868693          	addi	a3,a3,1208 # ffffffffc02060e8 <nbase>
ffffffffc0203c38:	40c58633          	sub	a2,a1,a2
ffffffffc0203c3c:	630c                	ld	a1,0(a4)
ffffffffc0203c3e:	860d                	srai	a2,a2,0x3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203c40:	0000e717          	auipc	a4,0xe
ffffffffc0203c44:	81870713          	addi	a4,a4,-2024 # ffffffffc0211458 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203c48:	02b60633          	mul	a2,a2,a1
ffffffffc0203c4c:	0037959b          	slliw	a1,a5,0x3
ffffffffc0203c50:	629c                	ld	a5,0(a3)
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203c52:	6318                	ld	a4,0(a4)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203c54:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203c56:	00c61793          	slli	a5,a2,0xc
ffffffffc0203c5a:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203c5c:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203c5e:	02e7fa63          	bgeu	a5,a4,ffffffffc0203c92 <swapfs_read+0x8c>
ffffffffc0203c62:	0000e797          	auipc	a5,0xe
ffffffffc0203c66:	82678793          	addi	a5,a5,-2010 # ffffffffc0211488 <va_pa_offset>
ffffffffc0203c6a:	639c                	ld	a5,0(a5)
}
ffffffffc0203c6c:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203c6e:	46a1                	li	a3,8
ffffffffc0203c70:	963e                	add	a2,a2,a5
ffffffffc0203c72:	4505                	li	a0,1
}
ffffffffc0203c74:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203c76:	f68fc06f          	j	ffffffffc02003de <ide_read_secs>
ffffffffc0203c7a:	86aa                	mv	a3,a0
ffffffffc0203c7c:	00002617          	auipc	a2,0x2
ffffffffc0203c80:	20460613          	addi	a2,a2,516 # ffffffffc0205e80 <default_pmm_manager+0x168>
ffffffffc0203c84:	45d1                	li	a1,20
ffffffffc0203c86:	00002517          	auipc	a0,0x2
ffffffffc0203c8a:	1e250513          	addi	a0,a0,482 # ffffffffc0205e68 <default_pmm_manager+0x150>
ffffffffc0203c8e:	c76fc0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0203c92:	86b2                	mv	a3,a2
ffffffffc0203c94:	06a00593          	li	a1,106
ffffffffc0203c98:	00001617          	auipc	a2,0x1
ffffffffc0203c9c:	fb860613          	addi	a2,a2,-72 # ffffffffc0204c50 <commands+0x840>
ffffffffc0203ca0:	00001517          	auipc	a0,0x1
ffffffffc0203ca4:	04850513          	addi	a0,a0,72 # ffffffffc0204ce8 <commands+0x8d8>
ffffffffc0203ca8:	c5cfc0ef          	jal	ra,ffffffffc0200104 <__panic>

ffffffffc0203cac <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0203cac:	1141                	addi	sp,sp,-16
ffffffffc0203cae:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203cb0:	00855793          	srli	a5,a0,0x8
ffffffffc0203cb4:	c7b5                	beqz	a5,ffffffffc0203d20 <swapfs_write+0x74>
ffffffffc0203cb6:	0000e717          	auipc	a4,0xe
ffffffffc0203cba:	87a70713          	addi	a4,a4,-1926 # ffffffffc0211530 <max_swap_offset>
ffffffffc0203cbe:	6318                	ld	a4,0(a4)
ffffffffc0203cc0:	06e7f063          	bgeu	a5,a4,ffffffffc0203d20 <swapfs_write+0x74>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203cc4:	0000d717          	auipc	a4,0xd
ffffffffc0203cc8:	7d470713          	addi	a4,a4,2004 # ffffffffc0211498 <pages>
ffffffffc0203ccc:	6310                	ld	a2,0(a4)
ffffffffc0203cce:	00001717          	auipc	a4,0x1
ffffffffc0203cd2:	f7a70713          	addi	a4,a4,-134 # ffffffffc0204c48 <commands+0x838>
ffffffffc0203cd6:	00002697          	auipc	a3,0x2
ffffffffc0203cda:	41268693          	addi	a3,a3,1042 # ffffffffc02060e8 <nbase>
ffffffffc0203cde:	40c58633          	sub	a2,a1,a2
ffffffffc0203ce2:	630c                	ld	a1,0(a4)
ffffffffc0203ce4:	860d                	srai	a2,a2,0x3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203ce6:	0000d717          	auipc	a4,0xd
ffffffffc0203cea:	77270713          	addi	a4,a4,1906 # ffffffffc0211458 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203cee:	02b60633          	mul	a2,a2,a1
ffffffffc0203cf2:	0037959b          	slliw	a1,a5,0x3
ffffffffc0203cf6:	629c                	ld	a5,0(a3)
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203cf8:	6318                	ld	a4,0(a4)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203cfa:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203cfc:	00c61793          	slli	a5,a2,0xc
ffffffffc0203d00:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203d02:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203d04:	02e7fa63          	bgeu	a5,a4,ffffffffc0203d38 <swapfs_write+0x8c>
ffffffffc0203d08:	0000d797          	auipc	a5,0xd
ffffffffc0203d0c:	78078793          	addi	a5,a5,1920 # ffffffffc0211488 <va_pa_offset>
ffffffffc0203d10:	639c                	ld	a5,0(a5)
}
ffffffffc0203d12:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203d14:	46a1                	li	a3,8
ffffffffc0203d16:	963e                	add	a2,a2,a5
ffffffffc0203d18:	4505                	li	a0,1
}
ffffffffc0203d1a:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203d1c:	ee6fc06f          	j	ffffffffc0200402 <ide_write_secs>
ffffffffc0203d20:	86aa                	mv	a3,a0
ffffffffc0203d22:	00002617          	auipc	a2,0x2
ffffffffc0203d26:	15e60613          	addi	a2,a2,350 # ffffffffc0205e80 <default_pmm_manager+0x168>
ffffffffc0203d2a:	45e5                	li	a1,25
ffffffffc0203d2c:	00002517          	auipc	a0,0x2
ffffffffc0203d30:	13c50513          	addi	a0,a0,316 # ffffffffc0205e68 <default_pmm_manager+0x150>
ffffffffc0203d34:	bd0fc0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0203d38:	86b2                	mv	a3,a2
ffffffffc0203d3a:	06a00593          	li	a1,106
ffffffffc0203d3e:	00001617          	auipc	a2,0x1
ffffffffc0203d42:	f1260613          	addi	a2,a2,-238 # ffffffffc0204c50 <commands+0x840>
ffffffffc0203d46:	00001517          	auipc	a0,0x1
ffffffffc0203d4a:	fa250513          	addi	a0,a0,-94 # ffffffffc0204ce8 <commands+0x8d8>
ffffffffc0203d4e:	bb6fc0ef          	jal	ra,ffffffffc0200104 <__panic>

ffffffffc0203d52 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0203d52:	00054783          	lbu	a5,0(a0)
ffffffffc0203d56:	cb91                	beqz	a5,ffffffffc0203d6a <strlen+0x18>
    size_t cnt = 0;
ffffffffc0203d58:	4781                	li	a5,0
        cnt ++;
ffffffffc0203d5a:	0785                	addi	a5,a5,1
    while (*s ++ != '\0') {
ffffffffc0203d5c:	00f50733          	add	a4,a0,a5
ffffffffc0203d60:	00074703          	lbu	a4,0(a4)
ffffffffc0203d64:	fb7d                	bnez	a4,ffffffffc0203d5a <strlen+0x8>
    }
    return cnt;
}
ffffffffc0203d66:	853e                	mv	a0,a5
ffffffffc0203d68:	8082                	ret
    size_t cnt = 0;
ffffffffc0203d6a:	4781                	li	a5,0
}
ffffffffc0203d6c:	853e                	mv	a0,a5
ffffffffc0203d6e:	8082                	ret

ffffffffc0203d70 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc0203d70:	c185                	beqz	a1,ffffffffc0203d90 <strnlen+0x20>
ffffffffc0203d72:	00054783          	lbu	a5,0(a0)
ffffffffc0203d76:	cf89                	beqz	a5,ffffffffc0203d90 <strnlen+0x20>
    size_t cnt = 0;
ffffffffc0203d78:	4781                	li	a5,0
ffffffffc0203d7a:	a021                	j	ffffffffc0203d82 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc0203d7c:	00074703          	lbu	a4,0(a4)
ffffffffc0203d80:	c711                	beqz	a4,ffffffffc0203d8c <strnlen+0x1c>
        cnt ++;
ffffffffc0203d82:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0203d84:	00f50733          	add	a4,a0,a5
ffffffffc0203d88:	fef59ae3          	bne	a1,a5,ffffffffc0203d7c <strnlen+0xc>
    }
    return cnt;
}
ffffffffc0203d8c:	853e                	mv	a0,a5
ffffffffc0203d8e:	8082                	ret
    size_t cnt = 0;
ffffffffc0203d90:	4781                	li	a5,0
}
ffffffffc0203d92:	853e                	mv	a0,a5
ffffffffc0203d94:	8082                	ret

ffffffffc0203d96 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0203d96:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0203d98:	0585                	addi	a1,a1,1
ffffffffc0203d9a:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0203d9e:	0785                	addi	a5,a5,1
ffffffffc0203da0:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0203da4:	fb75                	bnez	a4,ffffffffc0203d98 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0203da6:	8082                	ret

ffffffffc0203da8 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0203da8:	00054783          	lbu	a5,0(a0)
ffffffffc0203dac:	0005c703          	lbu	a4,0(a1)
ffffffffc0203db0:	cb91                	beqz	a5,ffffffffc0203dc4 <strcmp+0x1c>
ffffffffc0203db2:	00e79c63          	bne	a5,a4,ffffffffc0203dca <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc0203db6:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0203db8:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc0203dbc:	0585                	addi	a1,a1,1
ffffffffc0203dbe:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0203dc2:	fbe5                	bnez	a5,ffffffffc0203db2 <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0203dc4:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0203dc6:	9d19                	subw	a0,a0,a4
ffffffffc0203dc8:	8082                	ret
ffffffffc0203dca:	0007851b          	sext.w	a0,a5
ffffffffc0203dce:	9d19                	subw	a0,a0,a4
ffffffffc0203dd0:	8082                	ret

ffffffffc0203dd2 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0203dd2:	00054783          	lbu	a5,0(a0)
ffffffffc0203dd6:	cb91                	beqz	a5,ffffffffc0203dea <strchr+0x18>
        if (*s == c) {
ffffffffc0203dd8:	00b79563          	bne	a5,a1,ffffffffc0203de2 <strchr+0x10>
ffffffffc0203ddc:	a809                	j	ffffffffc0203dee <strchr+0x1c>
ffffffffc0203dde:	00b78763          	beq	a5,a1,ffffffffc0203dec <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc0203de2:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0203de4:	00054783          	lbu	a5,0(a0)
ffffffffc0203de8:	fbfd                	bnez	a5,ffffffffc0203dde <strchr+0xc>
    }
    return NULL;
ffffffffc0203dea:	4501                	li	a0,0
}
ffffffffc0203dec:	8082                	ret
ffffffffc0203dee:	8082                	ret

ffffffffc0203df0 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0203df0:	ca01                	beqz	a2,ffffffffc0203e00 <memset+0x10>
ffffffffc0203df2:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0203df4:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0203df6:	0785                	addi	a5,a5,1
ffffffffc0203df8:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0203dfc:	fec79de3          	bne	a5,a2,ffffffffc0203df6 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0203e00:	8082                	ret

ffffffffc0203e02 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0203e02:	ca19                	beqz	a2,ffffffffc0203e18 <memcpy+0x16>
ffffffffc0203e04:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc0203e06:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0203e08:	0585                	addi	a1,a1,1
ffffffffc0203e0a:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0203e0e:	0785                	addi	a5,a5,1
ffffffffc0203e10:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0203e14:	fec59ae3          	bne	a1,a2,ffffffffc0203e08 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0203e18:	8082                	ret

ffffffffc0203e1a <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0203e1a:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203e1e:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0203e20:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203e24:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0203e26:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203e2a:	f022                	sd	s0,32(sp)
ffffffffc0203e2c:	ec26                	sd	s1,24(sp)
ffffffffc0203e2e:	e84a                	sd	s2,16(sp)
ffffffffc0203e30:	f406                	sd	ra,40(sp)
ffffffffc0203e32:	e44e                	sd	s3,8(sp)
ffffffffc0203e34:	84aa                	mv	s1,a0
ffffffffc0203e36:	892e                	mv	s2,a1
ffffffffc0203e38:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0203e3c:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc0203e3e:	03067e63          	bgeu	a2,a6,ffffffffc0203e7a <printnum+0x60>
ffffffffc0203e42:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0203e44:	00805763          	blez	s0,ffffffffc0203e52 <printnum+0x38>
ffffffffc0203e48:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0203e4a:	85ca                	mv	a1,s2
ffffffffc0203e4c:	854e                	mv	a0,s3
ffffffffc0203e4e:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0203e50:	fc65                	bnez	s0,ffffffffc0203e48 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203e52:	1a02                	slli	s4,s4,0x20
ffffffffc0203e54:	020a5a13          	srli	s4,s4,0x20
ffffffffc0203e58:	00002797          	auipc	a5,0x2
ffffffffc0203e5c:	1d878793          	addi	a5,a5,472 # ffffffffc0206030 <error_string+0x38>
ffffffffc0203e60:	9a3e                	add	s4,s4,a5
}
ffffffffc0203e62:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203e64:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0203e68:	70a2                	ld	ra,40(sp)
ffffffffc0203e6a:	69a2                	ld	s3,8(sp)
ffffffffc0203e6c:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203e6e:	85ca                	mv	a1,s2
ffffffffc0203e70:	8326                	mv	t1,s1
}
ffffffffc0203e72:	6942                	ld	s2,16(sp)
ffffffffc0203e74:	64e2                	ld	s1,24(sp)
ffffffffc0203e76:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203e78:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0203e7a:	03065633          	divu	a2,a2,a6
ffffffffc0203e7e:	8722                	mv	a4,s0
ffffffffc0203e80:	f9bff0ef          	jal	ra,ffffffffc0203e1a <printnum>
ffffffffc0203e84:	b7f9                	j	ffffffffc0203e52 <printnum+0x38>

ffffffffc0203e86 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0203e86:	7119                	addi	sp,sp,-128
ffffffffc0203e88:	f4a6                	sd	s1,104(sp)
ffffffffc0203e8a:	f0ca                	sd	s2,96(sp)
ffffffffc0203e8c:	e8d2                	sd	s4,80(sp)
ffffffffc0203e8e:	e4d6                	sd	s5,72(sp)
ffffffffc0203e90:	e0da                	sd	s6,64(sp)
ffffffffc0203e92:	fc5e                	sd	s7,56(sp)
ffffffffc0203e94:	f862                	sd	s8,48(sp)
ffffffffc0203e96:	f06a                	sd	s10,32(sp)
ffffffffc0203e98:	fc86                	sd	ra,120(sp)
ffffffffc0203e9a:	f8a2                	sd	s0,112(sp)
ffffffffc0203e9c:	ecce                	sd	s3,88(sp)
ffffffffc0203e9e:	f466                	sd	s9,40(sp)
ffffffffc0203ea0:	ec6e                	sd	s11,24(sp)
ffffffffc0203ea2:	892a                	mv	s2,a0
ffffffffc0203ea4:	84ae                	mv	s1,a1
ffffffffc0203ea6:	8d32                	mv	s10,a2
ffffffffc0203ea8:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0203eaa:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203eac:	00002a17          	auipc	s4,0x2
ffffffffc0203eb0:	ff4a0a13          	addi	s4,s4,-12 # ffffffffc0205ea0 <default_pmm_manager+0x188>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0203eb4:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203eb8:	00002c17          	auipc	s8,0x2
ffffffffc0203ebc:	140c0c13          	addi	s8,s8,320 # ffffffffc0205ff8 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203ec0:	000d4503          	lbu	a0,0(s10)
ffffffffc0203ec4:	02500793          	li	a5,37
ffffffffc0203ec8:	001d0413          	addi	s0,s10,1
ffffffffc0203ecc:	00f50e63          	beq	a0,a5,ffffffffc0203ee8 <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc0203ed0:	c521                	beqz	a0,ffffffffc0203f18 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203ed2:	02500993          	li	s3,37
ffffffffc0203ed6:	a011                	j	ffffffffc0203eda <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc0203ed8:	c121                	beqz	a0,ffffffffc0203f18 <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc0203eda:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203edc:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0203ede:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203ee0:	fff44503          	lbu	a0,-1(s0)
ffffffffc0203ee4:	ff351ae3          	bne	a0,s3,ffffffffc0203ed8 <vprintfmt+0x52>
ffffffffc0203ee8:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0203eec:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0203ef0:	4981                	li	s3,0
ffffffffc0203ef2:	4801                	li	a6,0
        width = precision = -1;
ffffffffc0203ef4:	5cfd                	li	s9,-1
ffffffffc0203ef6:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203ef8:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc0203efc:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203efe:	fdd6069b          	addiw	a3,a2,-35
ffffffffc0203f02:	0ff6f693          	andi	a3,a3,255
ffffffffc0203f06:	00140d13          	addi	s10,s0,1
ffffffffc0203f0a:	1ed5ef63          	bltu	a1,a3,ffffffffc0204108 <vprintfmt+0x282>
ffffffffc0203f0e:	068a                	slli	a3,a3,0x2
ffffffffc0203f10:	96d2                	add	a3,a3,s4
ffffffffc0203f12:	4294                	lw	a3,0(a3)
ffffffffc0203f14:	96d2                	add	a3,a3,s4
ffffffffc0203f16:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0203f18:	70e6                	ld	ra,120(sp)
ffffffffc0203f1a:	7446                	ld	s0,112(sp)
ffffffffc0203f1c:	74a6                	ld	s1,104(sp)
ffffffffc0203f1e:	7906                	ld	s2,96(sp)
ffffffffc0203f20:	69e6                	ld	s3,88(sp)
ffffffffc0203f22:	6a46                	ld	s4,80(sp)
ffffffffc0203f24:	6aa6                	ld	s5,72(sp)
ffffffffc0203f26:	6b06                	ld	s6,64(sp)
ffffffffc0203f28:	7be2                	ld	s7,56(sp)
ffffffffc0203f2a:	7c42                	ld	s8,48(sp)
ffffffffc0203f2c:	7ca2                	ld	s9,40(sp)
ffffffffc0203f2e:	7d02                	ld	s10,32(sp)
ffffffffc0203f30:	6de2                	ld	s11,24(sp)
ffffffffc0203f32:	6109                	addi	sp,sp,128
ffffffffc0203f34:	8082                	ret
            padc = '-';
ffffffffc0203f36:	87b2                	mv	a5,a2
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203f38:	00144603          	lbu	a2,1(s0)
ffffffffc0203f3c:	846a                	mv	s0,s10
ffffffffc0203f3e:	b7c1                	j	ffffffffc0203efe <vprintfmt+0x78>
            precision = va_arg(ap, int);
ffffffffc0203f40:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc0203f44:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0203f48:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203f4a:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc0203f4c:	fa0dd9e3          	bgez	s11,ffffffffc0203efe <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc0203f50:	8de6                	mv	s11,s9
ffffffffc0203f52:	5cfd                	li	s9,-1
ffffffffc0203f54:	b76d                	j	ffffffffc0203efe <vprintfmt+0x78>
            if (width < 0)
ffffffffc0203f56:	fffdc693          	not	a3,s11
ffffffffc0203f5a:	96fd                	srai	a3,a3,0x3f
ffffffffc0203f5c:	00ddfdb3          	and	s11,s11,a3
ffffffffc0203f60:	00144603          	lbu	a2,1(s0)
ffffffffc0203f64:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203f66:	846a                	mv	s0,s10
ffffffffc0203f68:	bf59                	j	ffffffffc0203efe <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc0203f6a:	4705                	li	a4,1
ffffffffc0203f6c:	008a8593          	addi	a1,s5,8
ffffffffc0203f70:	01074463          	blt	a4,a6,ffffffffc0203f78 <vprintfmt+0xf2>
    else if (lflag) {
ffffffffc0203f74:	22080863          	beqz	a6,ffffffffc02041a4 <vprintfmt+0x31e>
        return va_arg(*ap, unsigned long);
ffffffffc0203f78:	000ab603          	ld	a2,0(s5)
ffffffffc0203f7c:	46c1                	li	a3,16
ffffffffc0203f7e:	8aae                	mv	s5,a1
ffffffffc0203f80:	a291                	j	ffffffffc02040c4 <vprintfmt+0x23e>
                precision = precision * 10 + ch - '0';
ffffffffc0203f82:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc0203f86:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203f8a:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0203f8c:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0203f90:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0203f94:	fad56ce3          	bltu	a0,a3,ffffffffc0203f4c <vprintfmt+0xc6>
            for (precision = 0; ; ++ fmt) {
ffffffffc0203f98:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0203f9a:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc0203f9e:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0203fa2:	0196873b          	addw	a4,a3,s9
ffffffffc0203fa6:	0017171b          	slliw	a4,a4,0x1
ffffffffc0203faa:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc0203fae:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc0203fb2:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc0203fb6:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0203fba:	fcd57fe3          	bgeu	a0,a3,ffffffffc0203f98 <vprintfmt+0x112>
ffffffffc0203fbe:	b779                	j	ffffffffc0203f4c <vprintfmt+0xc6>
            putch(va_arg(ap, int), putdat);
ffffffffc0203fc0:	000aa503          	lw	a0,0(s5)
ffffffffc0203fc4:	85a6                	mv	a1,s1
ffffffffc0203fc6:	0aa1                	addi	s5,s5,8
ffffffffc0203fc8:	9902                	jalr	s2
            break;
ffffffffc0203fca:	bddd                	j	ffffffffc0203ec0 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0203fcc:	4705                	li	a4,1
ffffffffc0203fce:	008a8993          	addi	s3,s5,8
ffffffffc0203fd2:	01074463          	blt	a4,a6,ffffffffc0203fda <vprintfmt+0x154>
    else if (lflag) {
ffffffffc0203fd6:	1c080463          	beqz	a6,ffffffffc020419e <vprintfmt+0x318>
        return va_arg(*ap, long);
ffffffffc0203fda:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc0203fde:	1c044a63          	bltz	s0,ffffffffc02041b2 <vprintfmt+0x32c>
            num = getint(&ap, lflag);
ffffffffc0203fe2:	8622                	mv	a2,s0
ffffffffc0203fe4:	8ace                	mv	s5,s3
ffffffffc0203fe6:	46a9                	li	a3,10
ffffffffc0203fe8:	a8f1                	j	ffffffffc02040c4 <vprintfmt+0x23e>
            err = va_arg(ap, int);
ffffffffc0203fea:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203fee:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0203ff0:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc0203ff2:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0203ff6:	8fb5                	xor	a5,a5,a3
ffffffffc0203ff8:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203ffc:	12d74963          	blt	a4,a3,ffffffffc020412e <vprintfmt+0x2a8>
ffffffffc0204000:	00369793          	slli	a5,a3,0x3
ffffffffc0204004:	97e2                	add	a5,a5,s8
ffffffffc0204006:	639c                	ld	a5,0(a5)
ffffffffc0204008:	12078363          	beqz	a5,ffffffffc020412e <vprintfmt+0x2a8>
                printfmt(putch, putdat, "%s", p);
ffffffffc020400c:	86be                	mv	a3,a5
ffffffffc020400e:	00002617          	auipc	a2,0x2
ffffffffc0204012:	0d260613          	addi	a2,a2,210 # ffffffffc02060e0 <error_string+0xe8>
ffffffffc0204016:	85a6                	mv	a1,s1
ffffffffc0204018:	854a                	mv	a0,s2
ffffffffc020401a:	1cc000ef          	jal	ra,ffffffffc02041e6 <printfmt>
ffffffffc020401e:	b54d                	j	ffffffffc0203ec0 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0204020:	000ab603          	ld	a2,0(s5)
ffffffffc0204024:	0aa1                	addi	s5,s5,8
ffffffffc0204026:	1a060163          	beqz	a2,ffffffffc02041c8 <vprintfmt+0x342>
            if (width > 0 && padc != '-') {
ffffffffc020402a:	00160413          	addi	s0,a2,1
ffffffffc020402e:	15b05763          	blez	s11,ffffffffc020417c <vprintfmt+0x2f6>
ffffffffc0204032:	02d00593          	li	a1,45
ffffffffc0204036:	10b79d63          	bne	a5,a1,ffffffffc0204150 <vprintfmt+0x2ca>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020403a:	00064783          	lbu	a5,0(a2)
ffffffffc020403e:	0007851b          	sext.w	a0,a5
ffffffffc0204042:	c905                	beqz	a0,ffffffffc0204072 <vprintfmt+0x1ec>
ffffffffc0204044:	000cc563          	bltz	s9,ffffffffc020404e <vprintfmt+0x1c8>
ffffffffc0204048:	3cfd                	addiw	s9,s9,-1
ffffffffc020404a:	036c8263          	beq	s9,s6,ffffffffc020406e <vprintfmt+0x1e8>
                    putch('?', putdat);
ffffffffc020404e:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204050:	14098f63          	beqz	s3,ffffffffc02041ae <vprintfmt+0x328>
ffffffffc0204054:	3781                	addiw	a5,a5,-32
ffffffffc0204056:	14fbfc63          	bgeu	s7,a5,ffffffffc02041ae <vprintfmt+0x328>
                    putch('?', putdat);
ffffffffc020405a:	03f00513          	li	a0,63
ffffffffc020405e:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204060:	0405                	addi	s0,s0,1
ffffffffc0204062:	fff44783          	lbu	a5,-1(s0)
ffffffffc0204066:	3dfd                	addiw	s11,s11,-1
ffffffffc0204068:	0007851b          	sext.w	a0,a5
ffffffffc020406c:	fd61                	bnez	a0,ffffffffc0204044 <vprintfmt+0x1be>
            for (; width > 0; width --) {
ffffffffc020406e:	e5b059e3          	blez	s11,ffffffffc0203ec0 <vprintfmt+0x3a>
ffffffffc0204072:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0204074:	85a6                	mv	a1,s1
ffffffffc0204076:	02000513          	li	a0,32
ffffffffc020407a:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc020407c:	e40d82e3          	beqz	s11,ffffffffc0203ec0 <vprintfmt+0x3a>
ffffffffc0204080:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0204082:	85a6                	mv	a1,s1
ffffffffc0204084:	02000513          	li	a0,32
ffffffffc0204088:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc020408a:	fe0d94e3          	bnez	s11,ffffffffc0204072 <vprintfmt+0x1ec>
ffffffffc020408e:	bd0d                	j	ffffffffc0203ec0 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0204090:	4705                	li	a4,1
ffffffffc0204092:	008a8593          	addi	a1,s5,8
ffffffffc0204096:	01074463          	blt	a4,a6,ffffffffc020409e <vprintfmt+0x218>
    else if (lflag) {
ffffffffc020409a:	0e080863          	beqz	a6,ffffffffc020418a <vprintfmt+0x304>
        return va_arg(*ap, unsigned long);
ffffffffc020409e:	000ab603          	ld	a2,0(s5)
ffffffffc02040a2:	46a1                	li	a3,8
ffffffffc02040a4:	8aae                	mv	s5,a1
ffffffffc02040a6:	a839                	j	ffffffffc02040c4 <vprintfmt+0x23e>
            putch('0', putdat);
ffffffffc02040a8:	03000513          	li	a0,48
ffffffffc02040ac:	85a6                	mv	a1,s1
ffffffffc02040ae:	e03e                	sd	a5,0(sp)
ffffffffc02040b0:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc02040b2:	85a6                	mv	a1,s1
ffffffffc02040b4:	07800513          	li	a0,120
ffffffffc02040b8:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02040ba:	0aa1                	addi	s5,s5,8
ffffffffc02040bc:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc02040c0:	6782                	ld	a5,0(sp)
ffffffffc02040c2:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc02040c4:	2781                	sext.w	a5,a5
ffffffffc02040c6:	876e                	mv	a4,s11
ffffffffc02040c8:	85a6                	mv	a1,s1
ffffffffc02040ca:	854a                	mv	a0,s2
ffffffffc02040cc:	d4fff0ef          	jal	ra,ffffffffc0203e1a <printnum>
            break;
ffffffffc02040d0:	bbc5                	j	ffffffffc0203ec0 <vprintfmt+0x3a>
            lflag ++;
ffffffffc02040d2:	00144603          	lbu	a2,1(s0)
ffffffffc02040d6:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02040d8:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02040da:	b515                	j	ffffffffc0203efe <vprintfmt+0x78>
            goto reswitch;
ffffffffc02040dc:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc02040e0:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02040e2:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02040e4:	bd29                	j	ffffffffc0203efe <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc02040e6:	85a6                	mv	a1,s1
ffffffffc02040e8:	02500513          	li	a0,37
ffffffffc02040ec:	9902                	jalr	s2
            break;
ffffffffc02040ee:	bbc9                	j	ffffffffc0203ec0 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02040f0:	4705                	li	a4,1
ffffffffc02040f2:	008a8593          	addi	a1,s5,8
ffffffffc02040f6:	01074463          	blt	a4,a6,ffffffffc02040fe <vprintfmt+0x278>
    else if (lflag) {
ffffffffc02040fa:	08080d63          	beqz	a6,ffffffffc0204194 <vprintfmt+0x30e>
        return va_arg(*ap, unsigned long);
ffffffffc02040fe:	000ab603          	ld	a2,0(s5)
ffffffffc0204102:	46a9                	li	a3,10
ffffffffc0204104:	8aae                	mv	s5,a1
ffffffffc0204106:	bf7d                	j	ffffffffc02040c4 <vprintfmt+0x23e>
            putch('%', putdat);
ffffffffc0204108:	85a6                	mv	a1,s1
ffffffffc020410a:	02500513          	li	a0,37
ffffffffc020410e:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0204110:	fff44703          	lbu	a4,-1(s0)
ffffffffc0204114:	02500793          	li	a5,37
ffffffffc0204118:	8d22                	mv	s10,s0
ffffffffc020411a:	daf703e3          	beq	a4,a5,ffffffffc0203ec0 <vprintfmt+0x3a>
ffffffffc020411e:	02500713          	li	a4,37
ffffffffc0204122:	1d7d                	addi	s10,s10,-1
ffffffffc0204124:	fffd4783          	lbu	a5,-1(s10)
ffffffffc0204128:	fee79de3          	bne	a5,a4,ffffffffc0204122 <vprintfmt+0x29c>
ffffffffc020412c:	bb51                	j	ffffffffc0203ec0 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc020412e:	00002617          	auipc	a2,0x2
ffffffffc0204132:	fa260613          	addi	a2,a2,-94 # ffffffffc02060d0 <error_string+0xd8>
ffffffffc0204136:	85a6                	mv	a1,s1
ffffffffc0204138:	854a                	mv	a0,s2
ffffffffc020413a:	0ac000ef          	jal	ra,ffffffffc02041e6 <printfmt>
ffffffffc020413e:	b349                	j	ffffffffc0203ec0 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0204140:	00002617          	auipc	a2,0x2
ffffffffc0204144:	f8860613          	addi	a2,a2,-120 # ffffffffc02060c8 <error_string+0xd0>
            if (width > 0 && padc != '-') {
ffffffffc0204148:	00002417          	auipc	s0,0x2
ffffffffc020414c:	f8140413          	addi	s0,s0,-127 # ffffffffc02060c9 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204150:	8532                	mv	a0,a2
ffffffffc0204152:	85e6                	mv	a1,s9
ffffffffc0204154:	e032                	sd	a2,0(sp)
ffffffffc0204156:	e43e                	sd	a5,8(sp)
ffffffffc0204158:	c19ff0ef          	jal	ra,ffffffffc0203d70 <strnlen>
ffffffffc020415c:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0204160:	6602                	ld	a2,0(sp)
ffffffffc0204162:	01b05d63          	blez	s11,ffffffffc020417c <vprintfmt+0x2f6>
ffffffffc0204166:	67a2                	ld	a5,8(sp)
ffffffffc0204168:	2781                	sext.w	a5,a5
ffffffffc020416a:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc020416c:	6522                	ld	a0,8(sp)
ffffffffc020416e:	85a6                	mv	a1,s1
ffffffffc0204170:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204172:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0204174:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204176:	6602                	ld	a2,0(sp)
ffffffffc0204178:	fe0d9ae3          	bnez	s11,ffffffffc020416c <vprintfmt+0x2e6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020417c:	00064783          	lbu	a5,0(a2)
ffffffffc0204180:	0007851b          	sext.w	a0,a5
ffffffffc0204184:	ec0510e3          	bnez	a0,ffffffffc0204044 <vprintfmt+0x1be>
ffffffffc0204188:	bb25                	j	ffffffffc0203ec0 <vprintfmt+0x3a>
        return va_arg(*ap, unsigned int);
ffffffffc020418a:	000ae603          	lwu	a2,0(s5)
ffffffffc020418e:	46a1                	li	a3,8
ffffffffc0204190:	8aae                	mv	s5,a1
ffffffffc0204192:	bf0d                	j	ffffffffc02040c4 <vprintfmt+0x23e>
ffffffffc0204194:	000ae603          	lwu	a2,0(s5)
ffffffffc0204198:	46a9                	li	a3,10
ffffffffc020419a:	8aae                	mv	s5,a1
ffffffffc020419c:	b725                	j	ffffffffc02040c4 <vprintfmt+0x23e>
        return va_arg(*ap, int);
ffffffffc020419e:	000aa403          	lw	s0,0(s5)
ffffffffc02041a2:	bd35                	j	ffffffffc0203fde <vprintfmt+0x158>
        return va_arg(*ap, unsigned int);
ffffffffc02041a4:	000ae603          	lwu	a2,0(s5)
ffffffffc02041a8:	46c1                	li	a3,16
ffffffffc02041aa:	8aae                	mv	s5,a1
ffffffffc02041ac:	bf21                	j	ffffffffc02040c4 <vprintfmt+0x23e>
                    putch(ch, putdat);
ffffffffc02041ae:	9902                	jalr	s2
ffffffffc02041b0:	bd45                	j	ffffffffc0204060 <vprintfmt+0x1da>
                putch('-', putdat);
ffffffffc02041b2:	85a6                	mv	a1,s1
ffffffffc02041b4:	02d00513          	li	a0,45
ffffffffc02041b8:	e03e                	sd	a5,0(sp)
ffffffffc02041ba:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc02041bc:	8ace                	mv	s5,s3
ffffffffc02041be:	40800633          	neg	a2,s0
ffffffffc02041c2:	46a9                	li	a3,10
ffffffffc02041c4:	6782                	ld	a5,0(sp)
ffffffffc02041c6:	bdfd                	j	ffffffffc02040c4 <vprintfmt+0x23e>
            if (width > 0 && padc != '-') {
ffffffffc02041c8:	01b05663          	blez	s11,ffffffffc02041d4 <vprintfmt+0x34e>
ffffffffc02041cc:	02d00693          	li	a3,45
ffffffffc02041d0:	f6d798e3          	bne	a5,a3,ffffffffc0204140 <vprintfmt+0x2ba>
ffffffffc02041d4:	00002417          	auipc	s0,0x2
ffffffffc02041d8:	ef540413          	addi	s0,s0,-267 # ffffffffc02060c9 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02041dc:	02800513          	li	a0,40
ffffffffc02041e0:	02800793          	li	a5,40
ffffffffc02041e4:	b585                	j	ffffffffc0204044 <vprintfmt+0x1be>

ffffffffc02041e6 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02041e6:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02041e8:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02041ec:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02041ee:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02041f0:	ec06                	sd	ra,24(sp)
ffffffffc02041f2:	f83a                	sd	a4,48(sp)
ffffffffc02041f4:	fc3e                	sd	a5,56(sp)
ffffffffc02041f6:	e0c2                	sd	a6,64(sp)
ffffffffc02041f8:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02041fa:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02041fc:	c8bff0ef          	jal	ra,ffffffffc0203e86 <vprintfmt>
}
ffffffffc0204200:	60e2                	ld	ra,24(sp)
ffffffffc0204202:	6161                	addi	sp,sp,80
ffffffffc0204204:	8082                	ret

ffffffffc0204206 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0204206:	715d                	addi	sp,sp,-80
ffffffffc0204208:	e486                	sd	ra,72(sp)
ffffffffc020420a:	e0a2                	sd	s0,64(sp)
ffffffffc020420c:	fc26                	sd	s1,56(sp)
ffffffffc020420e:	f84a                	sd	s2,48(sp)
ffffffffc0204210:	f44e                	sd	s3,40(sp)
ffffffffc0204212:	f052                	sd	s4,32(sp)
ffffffffc0204214:	ec56                	sd	s5,24(sp)
ffffffffc0204216:	e85a                	sd	s6,16(sp)
ffffffffc0204218:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc020421a:	c901                	beqz	a0,ffffffffc020422a <readline+0x24>
        cprintf("%s", prompt);
ffffffffc020421c:	85aa                	mv	a1,a0
ffffffffc020421e:	00002517          	auipc	a0,0x2
ffffffffc0204222:	ec250513          	addi	a0,a0,-318 # ffffffffc02060e0 <error_string+0xe8>
ffffffffc0204226:	e99fb0ef          	jal	ra,ffffffffc02000be <cprintf>
readline(const char *prompt) {
ffffffffc020422a:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020422c:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc020422e:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0204230:	4aa9                	li	s5,10
ffffffffc0204232:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0204234:	0000db97          	auipc	s7,0xd
ffffffffc0204238:	e0cb8b93          	addi	s7,s7,-500 # ffffffffc0211040 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020423c:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0204240:	eb5fb0ef          	jal	ra,ffffffffc02000f4 <getchar>
ffffffffc0204244:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0204246:	00054b63          	bltz	a0,ffffffffc020425c <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020424a:	00a95b63          	bge	s2,a0,ffffffffc0204260 <readline+0x5a>
ffffffffc020424e:	029a5463          	bge	s4,s1,ffffffffc0204276 <readline+0x70>
        c = getchar();
ffffffffc0204252:	ea3fb0ef          	jal	ra,ffffffffc02000f4 <getchar>
ffffffffc0204256:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0204258:	fe0559e3          	bgez	a0,ffffffffc020424a <readline+0x44>
            return NULL;
ffffffffc020425c:	4501                	li	a0,0
ffffffffc020425e:	a099                	j	ffffffffc02042a4 <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc0204260:	03341463          	bne	s0,s3,ffffffffc0204288 <readline+0x82>
ffffffffc0204264:	e8b9                	bnez	s1,ffffffffc02042ba <readline+0xb4>
        c = getchar();
ffffffffc0204266:	e8ffb0ef          	jal	ra,ffffffffc02000f4 <getchar>
ffffffffc020426a:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc020426c:	fe0548e3          	bltz	a0,ffffffffc020425c <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0204270:	fea958e3          	bge	s2,a0,ffffffffc0204260 <readline+0x5a>
ffffffffc0204274:	4481                	li	s1,0
            cputchar(c);
ffffffffc0204276:	8522                	mv	a0,s0
ffffffffc0204278:	e7bfb0ef          	jal	ra,ffffffffc02000f2 <cputchar>
            buf[i ++] = c;
ffffffffc020427c:	009b87b3          	add	a5,s7,s1
ffffffffc0204280:	00878023          	sb	s0,0(a5)
ffffffffc0204284:	2485                	addiw	s1,s1,1
ffffffffc0204286:	bf6d                	j	ffffffffc0204240 <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc0204288:	01540463          	beq	s0,s5,ffffffffc0204290 <readline+0x8a>
ffffffffc020428c:	fb641ae3          	bne	s0,s6,ffffffffc0204240 <readline+0x3a>
            cputchar(c);
ffffffffc0204290:	8522                	mv	a0,s0
ffffffffc0204292:	e61fb0ef          	jal	ra,ffffffffc02000f2 <cputchar>
            buf[i] = '\0';
ffffffffc0204296:	0000d517          	auipc	a0,0xd
ffffffffc020429a:	daa50513          	addi	a0,a0,-598 # ffffffffc0211040 <buf>
ffffffffc020429e:	94aa                	add	s1,s1,a0
ffffffffc02042a0:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc02042a4:	60a6                	ld	ra,72(sp)
ffffffffc02042a6:	6406                	ld	s0,64(sp)
ffffffffc02042a8:	74e2                	ld	s1,56(sp)
ffffffffc02042aa:	7942                	ld	s2,48(sp)
ffffffffc02042ac:	79a2                	ld	s3,40(sp)
ffffffffc02042ae:	7a02                	ld	s4,32(sp)
ffffffffc02042b0:	6ae2                	ld	s5,24(sp)
ffffffffc02042b2:	6b42                	ld	s6,16(sp)
ffffffffc02042b4:	6ba2                	ld	s7,8(sp)
ffffffffc02042b6:	6161                	addi	sp,sp,80
ffffffffc02042b8:	8082                	ret
            cputchar(c);
ffffffffc02042ba:	4521                	li	a0,8
ffffffffc02042bc:	e37fb0ef          	jal	ra,ffffffffc02000f2 <cputchar>
            i --;
ffffffffc02042c0:	34fd                	addiw	s1,s1,-1
ffffffffc02042c2:	bfbd                	j	ffffffffc0204240 <readline+0x3a>
