
bin/kernel：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000080200000 <kern_entry>:
#include <memlayout.h>

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    la sp, bootstacktop
    80200000:	00004117          	auipc	sp,0x4
    80200004:	00010113          	mv	sp,sp

    tail kern_init
    80200008:	a009                	j	8020000a <kern_init>

000000008020000a <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);

int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
    8020000a:	00004517          	auipc	a0,0x4
    8020000e:	00650513          	addi	a0,a0,6 # 80204010 <ticks>
    80200012:	00004617          	auipc	a2,0x4
    80200016:	01660613          	addi	a2,a2,22 # 80204028 <end>
int kern_init(void) {
    8020001a:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
    8020001c:	8e09                	sub	a2,a2,a0
    8020001e:	4581                	li	a1,0
int kern_init(void) {
    80200020:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
    80200022:	179000ef          	jal	ra,8020099a <memset>

    cons_init();  // init the console
    80200026:	14a000ef          	jal	ra,80200170 <cons_init>

    const char *message = "(THU.CST) os is loading ...\n";
    cprintf("%s\n\n", message);
    8020002a:	00001597          	auipc	a1,0x1
    8020002e:	98658593          	addi	a1,a1,-1658 # 802009b0 <etext+0x4>
    80200032:	00001517          	auipc	a0,0x1
    80200036:	99e50513          	addi	a0,a0,-1634 # 802009d0 <etext+0x24>
    8020003a:	030000ef          	jal	ra,8020006a <cprintf>

    print_kerninfo();
    8020003e:	062000ef          	jal	ra,802000a0 <print_kerninfo>

    // grade_backtrace();

    idt_init();  // init interrupt descriptor table
    80200042:	13e000ef          	jal	ra,80200180 <idt_init>

    // rdtime in mbare mode crashes
    clock_init();  // init clock interrupt
    80200046:	0e8000ef          	jal	ra,8020012e <clock_init>

    intr_enable();  // enable irq interrupt
    8020004a:	130000ef          	jal	ra,8020017a <intr_enable>
    
    while (1)
    8020004e:	a001                	j	8020004e <kern_init+0x44>

0000000080200050 <cputch>:

/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void cputch(int c, int *cnt) {
    80200050:	1141                	addi	sp,sp,-16
    80200052:	e022                	sd	s0,0(sp)
    80200054:	e406                	sd	ra,8(sp)
    80200056:	842e                	mv	s0,a1
    cons_putc(c);
    80200058:	11a000ef          	jal	ra,80200172 <cons_putc>
    (*cnt)++;
    8020005c:	401c                	lw	a5,0(s0)
}
    8020005e:	60a2                	ld	ra,8(sp)
    (*cnt)++;
    80200060:	2785                	addiw	a5,a5,1
    80200062:	c01c                	sw	a5,0(s0)
}
    80200064:	6402                	ld	s0,0(sp)
    80200066:	0141                	addi	sp,sp,16
    80200068:	8082                	ret

000000008020006a <cprintf>:
 * cprintf - formats a string and writes it to stdout
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int cprintf(const char *fmt, ...) {
    8020006a:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
    8020006c:	02810313          	addi	t1,sp,40 # 80204028 <end>
int cprintf(const char *fmt, ...) {
    80200070:	8e2a                	mv	t3,a0
    80200072:	f42e                	sd	a1,40(sp)
    80200074:	f832                	sd	a2,48(sp)
    80200076:	fc36                	sd	a3,56(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    80200078:	00000517          	auipc	a0,0x0
    8020007c:	fd850513          	addi	a0,a0,-40 # 80200050 <cputch>
    80200080:	004c                	addi	a1,sp,4
    80200082:	869a                	mv	a3,t1
    80200084:	8672                	mv	a2,t3
int cprintf(const char *fmt, ...) {
    80200086:	ec06                	sd	ra,24(sp)
    80200088:	e0ba                	sd	a4,64(sp)
    8020008a:	e4be                	sd	a5,72(sp)
    8020008c:	e8c2                	sd	a6,80(sp)
    8020008e:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
    80200090:	e41a                	sd	t1,8(sp)
    int cnt = 0;
    80200092:	c202                	sw	zero,4(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    80200094:	51a000ef          	jal	ra,802005ae <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
    80200098:	60e2                	ld	ra,24(sp)
    8020009a:	4512                	lw	a0,4(sp)
    8020009c:	6125                	addi	sp,sp,96
    8020009e:	8082                	ret

00000000802000a0 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
    802000a0:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
    802000a2:	00001517          	auipc	a0,0x1
    802000a6:	93650513          	addi	a0,a0,-1738 # 802009d8 <etext+0x2c>
void print_kerninfo(void) {
    802000aa:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
    802000ac:	fbfff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  entry  0x%016x (virtual)\n", kern_init);
    802000b0:	00000597          	auipc	a1,0x0
    802000b4:	f5a58593          	addi	a1,a1,-166 # 8020000a <kern_init>
    802000b8:	00001517          	auipc	a0,0x1
    802000bc:	94050513          	addi	a0,a0,-1728 # 802009f8 <etext+0x4c>
    802000c0:	fabff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  etext  0x%016x (virtual)\n", etext);
    802000c4:	00001597          	auipc	a1,0x1
    802000c8:	8e858593          	addi	a1,a1,-1816 # 802009ac <etext>
    802000cc:	00001517          	auipc	a0,0x1
    802000d0:	94c50513          	addi	a0,a0,-1716 # 80200a18 <etext+0x6c>
    802000d4:	f97ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  edata  0x%016x (virtual)\n", edata);
    802000d8:	00004597          	auipc	a1,0x4
    802000dc:	f3858593          	addi	a1,a1,-200 # 80204010 <ticks>
    802000e0:	00001517          	auipc	a0,0x1
    802000e4:	95850513          	addi	a0,a0,-1704 # 80200a38 <etext+0x8c>
    802000e8:	f83ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  end    0x%016x (virtual)\n", end);
    802000ec:	00004597          	auipc	a1,0x4
    802000f0:	f3c58593          	addi	a1,a1,-196 # 80204028 <end>
    802000f4:	00001517          	auipc	a0,0x1
    802000f8:	96450513          	addi	a0,a0,-1692 # 80200a58 <etext+0xac>
    802000fc:	f6fff0ef          	jal	ra,8020006a <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
    80200100:	00004597          	auipc	a1,0x4
    80200104:	32758593          	addi	a1,a1,807 # 80204427 <end+0x3ff>
    80200108:	00000797          	auipc	a5,0x0
    8020010c:	f0278793          	addi	a5,a5,-254 # 8020000a <kern_init>
    80200110:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
    80200114:	43f7d593          	srai	a1,a5,0x3f
}
    80200118:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
    8020011a:	3ff5f593          	andi	a1,a1,1023
    8020011e:	95be                	add	a1,a1,a5
    80200120:	85a9                	srai	a1,a1,0xa
    80200122:	00001517          	auipc	a0,0x1
    80200126:	95650513          	addi	a0,a0,-1706 # 80200a78 <etext+0xcc>
}
    8020012a:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
    8020012c:	bf3d                	j	8020006a <cprintf>

000000008020012e <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    8020012e:	1141                	addi	sp,sp,-16
    80200130:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
    80200132:	02000793          	li	a5,32
    80200136:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
    8020013a:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
    8020013e:	67e1                	lui	a5,0x18
    80200140:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0x801e7960>
    80200144:	953e                	add	a0,a0,a5
    80200146:	005000ef          	jal	ra,8020094a <sbi_set_timer>
}
    8020014a:	60a2                	ld	ra,8(sp)
    ticks = 0;
    8020014c:	00004797          	auipc	a5,0x4
    80200150:	ec07b223          	sd	zero,-316(a5) # 80204010 <ticks>
    cprintf("++ setup timer interrupts\n");
    80200154:	00001517          	auipc	a0,0x1
    80200158:	95450513          	addi	a0,a0,-1708 # 80200aa8 <etext+0xfc>
}
    8020015c:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
    8020015e:	b731                	j	8020006a <cprintf>

0000000080200160 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
    80200160:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
    80200164:	67e1                	lui	a5,0x18
    80200166:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0x801e7960>
    8020016a:	953e                	add	a0,a0,a5
    8020016c:	7de0006f          	j	8020094a <sbi_set_timer>

0000000080200170 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
    80200170:	8082                	ret

0000000080200172 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
    80200172:	0ff57513          	andi	a0,a0,255
    80200176:	7ba0006f          	j	80200930 <sbi_console_putchar>

000000008020017a <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
    8020017a:	100167f3          	csrrsi	a5,sstatus,2
    8020017e:	8082                	ret

0000000080200180 <idt_init>:
 */
void idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
    80200180:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
    80200184:	00000797          	auipc	a5,0x0
    80200188:	30878793          	addi	a5,a5,776 # 8020048c <__alltraps>
    8020018c:	10579073          	csrw	stvec,a5
}
    80200190:	8082                	ret

0000000080200192 <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
    80200192:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
    80200194:	1141                	addi	sp,sp,-16
    80200196:	e022                	sd	s0,0(sp)
    80200198:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
    8020019a:	00001517          	auipc	a0,0x1
    8020019e:	92e50513          	addi	a0,a0,-1746 # 80200ac8 <etext+0x11c>
void print_regs(struct pushregs *gpr) {
    802001a2:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
    802001a4:	ec7ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
    802001a8:	640c                	ld	a1,8(s0)
    802001aa:	00001517          	auipc	a0,0x1
    802001ae:	93650513          	addi	a0,a0,-1738 # 80200ae0 <etext+0x134>
    802001b2:	eb9ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
    802001b6:	680c                	ld	a1,16(s0)
    802001b8:	00001517          	auipc	a0,0x1
    802001bc:	94050513          	addi	a0,a0,-1728 # 80200af8 <etext+0x14c>
    802001c0:	eabff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
    802001c4:	6c0c                	ld	a1,24(s0)
    802001c6:	00001517          	auipc	a0,0x1
    802001ca:	94a50513          	addi	a0,a0,-1718 # 80200b10 <etext+0x164>
    802001ce:	e9dff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
    802001d2:	700c                	ld	a1,32(s0)
    802001d4:	00001517          	auipc	a0,0x1
    802001d8:	95450513          	addi	a0,a0,-1708 # 80200b28 <etext+0x17c>
    802001dc:	e8fff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
    802001e0:	740c                	ld	a1,40(s0)
    802001e2:	00001517          	auipc	a0,0x1
    802001e6:	95e50513          	addi	a0,a0,-1698 # 80200b40 <etext+0x194>
    802001ea:	e81ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
    802001ee:	780c                	ld	a1,48(s0)
    802001f0:	00001517          	auipc	a0,0x1
    802001f4:	96850513          	addi	a0,a0,-1688 # 80200b58 <etext+0x1ac>
    802001f8:	e73ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
    802001fc:	7c0c                	ld	a1,56(s0)
    802001fe:	00001517          	auipc	a0,0x1
    80200202:	97250513          	addi	a0,a0,-1678 # 80200b70 <etext+0x1c4>
    80200206:	e65ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
    8020020a:	602c                	ld	a1,64(s0)
    8020020c:	00001517          	auipc	a0,0x1
    80200210:	97c50513          	addi	a0,a0,-1668 # 80200b88 <etext+0x1dc>
    80200214:	e57ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
    80200218:	642c                	ld	a1,72(s0)
    8020021a:	00001517          	auipc	a0,0x1
    8020021e:	98650513          	addi	a0,a0,-1658 # 80200ba0 <etext+0x1f4>
    80200222:	e49ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
    80200226:	682c                	ld	a1,80(s0)
    80200228:	00001517          	auipc	a0,0x1
    8020022c:	99050513          	addi	a0,a0,-1648 # 80200bb8 <etext+0x20c>
    80200230:	e3bff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
    80200234:	6c2c                	ld	a1,88(s0)
    80200236:	00001517          	auipc	a0,0x1
    8020023a:	99a50513          	addi	a0,a0,-1638 # 80200bd0 <etext+0x224>
    8020023e:	e2dff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
    80200242:	702c                	ld	a1,96(s0)
    80200244:	00001517          	auipc	a0,0x1
    80200248:	9a450513          	addi	a0,a0,-1628 # 80200be8 <etext+0x23c>
    8020024c:	e1fff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
    80200250:	742c                	ld	a1,104(s0)
    80200252:	00001517          	auipc	a0,0x1
    80200256:	9ae50513          	addi	a0,a0,-1618 # 80200c00 <etext+0x254>
    8020025a:	e11ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
    8020025e:	782c                	ld	a1,112(s0)
    80200260:	00001517          	auipc	a0,0x1
    80200264:	9b850513          	addi	a0,a0,-1608 # 80200c18 <etext+0x26c>
    80200268:	e03ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
    8020026c:	7c2c                	ld	a1,120(s0)
    8020026e:	00001517          	auipc	a0,0x1
    80200272:	9c250513          	addi	a0,a0,-1598 # 80200c30 <etext+0x284>
    80200276:	df5ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
    8020027a:	604c                	ld	a1,128(s0)
    8020027c:	00001517          	auipc	a0,0x1
    80200280:	9cc50513          	addi	a0,a0,-1588 # 80200c48 <etext+0x29c>
    80200284:	de7ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
    80200288:	644c                	ld	a1,136(s0)
    8020028a:	00001517          	auipc	a0,0x1
    8020028e:	9d650513          	addi	a0,a0,-1578 # 80200c60 <etext+0x2b4>
    80200292:	dd9ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
    80200296:	684c                	ld	a1,144(s0)
    80200298:	00001517          	auipc	a0,0x1
    8020029c:	9e050513          	addi	a0,a0,-1568 # 80200c78 <etext+0x2cc>
    802002a0:	dcbff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
    802002a4:	6c4c                	ld	a1,152(s0)
    802002a6:	00001517          	auipc	a0,0x1
    802002aa:	9ea50513          	addi	a0,a0,-1558 # 80200c90 <etext+0x2e4>
    802002ae:	dbdff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
    802002b2:	704c                	ld	a1,160(s0)
    802002b4:	00001517          	auipc	a0,0x1
    802002b8:	9f450513          	addi	a0,a0,-1548 # 80200ca8 <etext+0x2fc>
    802002bc:	dafff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
    802002c0:	744c                	ld	a1,168(s0)
    802002c2:	00001517          	auipc	a0,0x1
    802002c6:	9fe50513          	addi	a0,a0,-1538 # 80200cc0 <etext+0x314>
    802002ca:	da1ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
    802002ce:	784c                	ld	a1,176(s0)
    802002d0:	00001517          	auipc	a0,0x1
    802002d4:	a0850513          	addi	a0,a0,-1528 # 80200cd8 <etext+0x32c>
    802002d8:	d93ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
    802002dc:	7c4c                	ld	a1,184(s0)
    802002de:	00001517          	auipc	a0,0x1
    802002e2:	a1250513          	addi	a0,a0,-1518 # 80200cf0 <etext+0x344>
    802002e6:	d85ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
    802002ea:	606c                	ld	a1,192(s0)
    802002ec:	00001517          	auipc	a0,0x1
    802002f0:	a1c50513          	addi	a0,a0,-1508 # 80200d08 <etext+0x35c>
    802002f4:	d77ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
    802002f8:	646c                	ld	a1,200(s0)
    802002fa:	00001517          	auipc	a0,0x1
    802002fe:	a2650513          	addi	a0,a0,-1498 # 80200d20 <etext+0x374>
    80200302:	d69ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
    80200306:	686c                	ld	a1,208(s0)
    80200308:	00001517          	auipc	a0,0x1
    8020030c:	a3050513          	addi	a0,a0,-1488 # 80200d38 <etext+0x38c>
    80200310:	d5bff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
    80200314:	6c6c                	ld	a1,216(s0)
    80200316:	00001517          	auipc	a0,0x1
    8020031a:	a3a50513          	addi	a0,a0,-1478 # 80200d50 <etext+0x3a4>
    8020031e:	d4dff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
    80200322:	706c                	ld	a1,224(s0)
    80200324:	00001517          	auipc	a0,0x1
    80200328:	a4450513          	addi	a0,a0,-1468 # 80200d68 <etext+0x3bc>
    8020032c:	d3fff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
    80200330:	746c                	ld	a1,232(s0)
    80200332:	00001517          	auipc	a0,0x1
    80200336:	a4e50513          	addi	a0,a0,-1458 # 80200d80 <etext+0x3d4>
    8020033a:	d31ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
    8020033e:	786c                	ld	a1,240(s0)
    80200340:	00001517          	auipc	a0,0x1
    80200344:	a5850513          	addi	a0,a0,-1448 # 80200d98 <etext+0x3ec>
    80200348:	d23ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
    8020034c:	7c6c                	ld	a1,248(s0)
}
    8020034e:	6402                	ld	s0,0(sp)
    80200350:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200352:	00001517          	auipc	a0,0x1
    80200356:	a5e50513          	addi	a0,a0,-1442 # 80200db0 <etext+0x404>
}
    8020035a:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
    8020035c:	b339                	j	8020006a <cprintf>

000000008020035e <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
    8020035e:	1141                	addi	sp,sp,-16
    80200360:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
    80200362:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
    80200364:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
    80200366:	00001517          	auipc	a0,0x1
    8020036a:	a6250513          	addi	a0,a0,-1438 # 80200dc8 <etext+0x41c>
void print_trapframe(struct trapframe *tf) {
    8020036e:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
    80200370:	cfbff0ef          	jal	ra,8020006a <cprintf>
    print_regs(&tf->gpr);
    80200374:	8522                	mv	a0,s0
    80200376:	e1dff0ef          	jal	ra,80200192 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
    8020037a:	10043583          	ld	a1,256(s0)
    8020037e:	00001517          	auipc	a0,0x1
    80200382:	a6250513          	addi	a0,a0,-1438 # 80200de0 <etext+0x434>
    80200386:	ce5ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
    8020038a:	10843583          	ld	a1,264(s0)
    8020038e:	00001517          	auipc	a0,0x1
    80200392:	a6a50513          	addi	a0,a0,-1430 # 80200df8 <etext+0x44c>
    80200396:	cd5ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    8020039a:	11043583          	ld	a1,272(s0)
    8020039e:	00001517          	auipc	a0,0x1
    802003a2:	a7250513          	addi	a0,a0,-1422 # 80200e10 <etext+0x464>
    802003a6:	cc5ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
    802003aa:	11843583          	ld	a1,280(s0)
}
    802003ae:	6402                	ld	s0,0(sp)
    802003b0:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
    802003b2:	00001517          	auipc	a0,0x1
    802003b6:	a7650513          	addi	a0,a0,-1418 # 80200e28 <etext+0x47c>
}
    802003ba:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
    802003bc:	b17d                	j	8020006a <cprintf>

00000000802003be <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
    802003be:	11853783          	ld	a5,280(a0)
    802003c2:	472d                	li	a4,11
    802003c4:	0786                	slli	a5,a5,0x1
    802003c6:	8385                	srli	a5,a5,0x1
    802003c8:	06f76e63          	bltu	a4,a5,80200444 <interrupt_handler+0x86>
    802003cc:	00001717          	auipc	a4,0x1
    802003d0:	b2470713          	addi	a4,a4,-1244 # 80200ef0 <etext+0x544>
    802003d4:	078a                	slli	a5,a5,0x2
    802003d6:	97ba                	add	a5,a5,a4
    802003d8:	439c                	lw	a5,0(a5)
    802003da:	97ba                	add	a5,a5,a4
    802003dc:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
    802003de:	00001517          	auipc	a0,0x1
    802003e2:	ac250513          	addi	a0,a0,-1342 # 80200ea0 <etext+0x4f4>
    802003e6:	b151                	j	8020006a <cprintf>
            cprintf("Hypervisor software interrupt\n");
    802003e8:	00001517          	auipc	a0,0x1
    802003ec:	a9850513          	addi	a0,a0,-1384 # 80200e80 <etext+0x4d4>
    802003f0:	b9ad                	j	8020006a <cprintf>
            cprintf("User software interrupt\n");
    802003f2:	00001517          	auipc	a0,0x1
    802003f6:	a4e50513          	addi	a0,a0,-1458 # 80200e40 <etext+0x494>
    802003fa:	b985                	j	8020006a <cprintf>
            cprintf("Supervisor software interrupt\n");
    802003fc:	00001517          	auipc	a0,0x1
    80200400:	a6450513          	addi	a0,a0,-1436 # 80200e60 <etext+0x4b4>
    80200404:	b19d                	j	8020006a <cprintf>
void interrupt_handler(struct trapframe *tf) {
    80200406:	1141                	addi	sp,sp,-16
    80200408:	e406                	sd	ra,8(sp)
            /*(1)设置下次时钟中断- clock_set_next_event()
             *(2)计数器（ticks）加一
             *(3)当计数器加到100的时候，我们会输出一个`100ticks`表示我们触发了100次时钟中断，同时打印次数（num）加一
            * (4)判断打印次数，当打印次数为10时，调用<sbi.h>中的关机函数关机
            */
            clock_set_next_event();
    8020040a:	d57ff0ef          	jal	ra,80200160 <clock_set_next_event>
            interrupt_ticks ++;
    8020040e:	00004717          	auipc	a4,0x4
    80200412:	c0a70713          	addi	a4,a4,-1014 # 80204018 <interrupt_ticks>
    80200416:	431c                	lw	a5,0(a4)
            if(interrupt_ticks == 100)
    80200418:	06400693          	li	a3,100
            interrupt_ticks ++;
    8020041c:	0017861b          	addiw	a2,a5,1
    80200420:	c310                	sw	a2,0(a4)
            if(interrupt_ticks == 100)
    80200422:	02d60263          	beq	a2,a3,80200446 <interrupt_handler+0x88>
            {
                interrupt_ticks = 0;
                print_ticks();
                print_times ++;
            }
            if(print_times == 10)
    80200426:	00004717          	auipc	a4,0x4
    8020042a:	bf672703          	lw	a4,-1034(a4) # 8020401c <print_times>
    8020042e:	47a9                	li	a5,10
    80200430:	04f70063          	beq	a4,a5,80200470 <interrupt_handler+0xb2>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    80200434:	60a2                	ld	ra,8(sp)
    80200436:	0141                	addi	sp,sp,16
    80200438:	8082                	ret
            cprintf("Supervisor external interrupt\n");
    8020043a:	00001517          	auipc	a0,0x1
    8020043e:	a9650513          	addi	a0,a0,-1386 # 80200ed0 <etext+0x524>
    80200442:	b125                	j	8020006a <cprintf>
            print_trapframe(tf);
    80200444:	bf29                	j	8020035e <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
    80200446:	06400593          	li	a1,100
    8020044a:	00001517          	auipc	a0,0x1
    8020044e:	a7650513          	addi	a0,a0,-1418 # 80200ec0 <etext+0x514>
                interrupt_ticks = 0;
    80200452:	00004797          	auipc	a5,0x4
    80200456:	bc07a323          	sw	zero,-1082(a5) # 80204018 <interrupt_ticks>
    cprintf("%d ticks\n", TICK_NUM);
    8020045a:	c11ff0ef          	jal	ra,8020006a <cprintf>
                print_times ++;
    8020045e:	00004697          	auipc	a3,0x4
    80200462:	bbe68693          	addi	a3,a3,-1090 # 8020401c <print_times>
    80200466:	429c                	lw	a5,0(a3)
    80200468:	0017871b          	addiw	a4,a5,1
    8020046c:	c298                	sw	a4,0(a3)
    8020046e:	b7c1                	j	8020042e <interrupt_handler+0x70>
}
    80200470:	60a2                	ld	ra,8(sp)
    80200472:	0141                	addi	sp,sp,16
                sbi_shutdown();
    80200474:	a9c5                	j	80200964 <sbi_shutdown>

0000000080200476 <trap>:
    }
}

/* trap_dispatch - dispatch based on what type of trap occurred */
static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
    80200476:	11853783          	ld	a5,280(a0)
    8020047a:	0007c763          	bltz	a5,80200488 <trap+0x12>
    switch (tf->cause) {
    8020047e:	472d                	li	a4,11
    80200480:	00f76363          	bltu	a4,a5,80200486 <trap+0x10>
 * trap - handles or dispatches an exception/interrupt. if and when trap()
 * returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) { trap_dispatch(tf); }
    80200484:	8082                	ret
            print_trapframe(tf);
    80200486:	bde1                	j	8020035e <print_trapframe>
        interrupt_handler(tf);
    80200488:	bf1d                	j	802003be <interrupt_handler>
	...

000000008020048c <__alltraps>:
    .endm

    .globl __alltraps
.align(2)
__alltraps:
    SAVE_ALL
    8020048c:	14011073          	csrw	sscratch,sp
    80200490:	712d                	addi	sp,sp,-288
    80200492:	e002                	sd	zero,0(sp)
    80200494:	e406                	sd	ra,8(sp)
    80200496:	ec0e                	sd	gp,24(sp)
    80200498:	f012                	sd	tp,32(sp)
    8020049a:	f416                	sd	t0,40(sp)
    8020049c:	f81a                	sd	t1,48(sp)
    8020049e:	fc1e                	sd	t2,56(sp)
    802004a0:	e0a2                	sd	s0,64(sp)
    802004a2:	e4a6                	sd	s1,72(sp)
    802004a4:	e8aa                	sd	a0,80(sp)
    802004a6:	ecae                	sd	a1,88(sp)
    802004a8:	f0b2                	sd	a2,96(sp)
    802004aa:	f4b6                	sd	a3,104(sp)
    802004ac:	f8ba                	sd	a4,112(sp)
    802004ae:	fcbe                	sd	a5,120(sp)
    802004b0:	e142                	sd	a6,128(sp)
    802004b2:	e546                	sd	a7,136(sp)
    802004b4:	e94a                	sd	s2,144(sp)
    802004b6:	ed4e                	sd	s3,152(sp)
    802004b8:	f152                	sd	s4,160(sp)
    802004ba:	f556                	sd	s5,168(sp)
    802004bc:	f95a                	sd	s6,176(sp)
    802004be:	fd5e                	sd	s7,184(sp)
    802004c0:	e1e2                	sd	s8,192(sp)
    802004c2:	e5e6                	sd	s9,200(sp)
    802004c4:	e9ea                	sd	s10,208(sp)
    802004c6:	edee                	sd	s11,216(sp)
    802004c8:	f1f2                	sd	t3,224(sp)
    802004ca:	f5f6                	sd	t4,232(sp)
    802004cc:	f9fa                	sd	t5,240(sp)
    802004ce:	fdfe                	sd	t6,248(sp)
    802004d0:	14001473          	csrrw	s0,sscratch,zero
    802004d4:	100024f3          	csrr	s1,sstatus
    802004d8:	14102973          	csrr	s2,sepc
    802004dc:	143029f3          	csrr	s3,stval
    802004e0:	14202a73          	csrr	s4,scause
    802004e4:	e822                	sd	s0,16(sp)
    802004e6:	e226                	sd	s1,256(sp)
    802004e8:	e64a                	sd	s2,264(sp)
    802004ea:	ea4e                	sd	s3,272(sp)
    802004ec:	ee52                	sd	s4,280(sp)

    move  a0, sp
    802004ee:	850a                	mv	a0,sp
    jal trap
    802004f0:	f87ff0ef          	jal	ra,80200476 <trap>

00000000802004f4 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
    802004f4:	6492                	ld	s1,256(sp)
    802004f6:	6932                	ld	s2,264(sp)
    802004f8:	10049073          	csrw	sstatus,s1
    802004fc:	14191073          	csrw	sepc,s2
    80200500:	60a2                	ld	ra,8(sp)
    80200502:	61e2                	ld	gp,24(sp)
    80200504:	7202                	ld	tp,32(sp)
    80200506:	72a2                	ld	t0,40(sp)
    80200508:	7342                	ld	t1,48(sp)
    8020050a:	73e2                	ld	t2,56(sp)
    8020050c:	6406                	ld	s0,64(sp)
    8020050e:	64a6                	ld	s1,72(sp)
    80200510:	6546                	ld	a0,80(sp)
    80200512:	65e6                	ld	a1,88(sp)
    80200514:	7606                	ld	a2,96(sp)
    80200516:	76a6                	ld	a3,104(sp)
    80200518:	7746                	ld	a4,112(sp)
    8020051a:	77e6                	ld	a5,120(sp)
    8020051c:	680a                	ld	a6,128(sp)
    8020051e:	68aa                	ld	a7,136(sp)
    80200520:	694a                	ld	s2,144(sp)
    80200522:	69ea                	ld	s3,152(sp)
    80200524:	7a0a                	ld	s4,160(sp)
    80200526:	7aaa                	ld	s5,168(sp)
    80200528:	7b4a                	ld	s6,176(sp)
    8020052a:	7bea                	ld	s7,184(sp)
    8020052c:	6c0e                	ld	s8,192(sp)
    8020052e:	6cae                	ld	s9,200(sp)
    80200530:	6d4e                	ld	s10,208(sp)
    80200532:	6dee                	ld	s11,216(sp)
    80200534:	7e0e                	ld	t3,224(sp)
    80200536:	7eae                	ld	t4,232(sp)
    80200538:	7f4e                	ld	t5,240(sp)
    8020053a:	7fee                	ld	t6,248(sp)
    8020053c:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
    8020053e:	10200073          	sret

0000000080200542 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
    80200542:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    80200546:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
    80200548:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    8020054c:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
    8020054e:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
    80200552:	f022                	sd	s0,32(sp)
    80200554:	ec26                	sd	s1,24(sp)
    80200556:	e84a                	sd	s2,16(sp)
    80200558:	f406                	sd	ra,40(sp)
    8020055a:	e44e                	sd	s3,8(sp)
    8020055c:	84aa                	mv	s1,a0
    8020055e:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
    80200560:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
    80200564:	2a01                	sext.w	s4,s4
    if (num >= base) {
    80200566:	03067e63          	bgeu	a2,a6,802005a2 <printnum+0x60>
    8020056a:	89be                	mv	s3,a5
        while (-- width > 0)
    8020056c:	00805763          	blez	s0,8020057a <printnum+0x38>
    80200570:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
    80200572:	85ca                	mv	a1,s2
    80200574:	854e                	mv	a0,s3
    80200576:	9482                	jalr	s1
        while (-- width > 0)
    80200578:	fc65                	bnez	s0,80200570 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
    8020057a:	1a02                	slli	s4,s4,0x20
    8020057c:	00001797          	auipc	a5,0x1
    80200580:	9a478793          	addi	a5,a5,-1628 # 80200f20 <etext+0x574>
    80200584:	020a5a13          	srli	s4,s4,0x20
    80200588:	9a3e                	add	s4,s4,a5
}
    8020058a:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
    8020058c:	000a4503          	lbu	a0,0(s4)
}
    80200590:	70a2                	ld	ra,40(sp)
    80200592:	69a2                	ld	s3,8(sp)
    80200594:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
    80200596:	85ca                	mv	a1,s2
    80200598:	87a6                	mv	a5,s1
}
    8020059a:	6942                	ld	s2,16(sp)
    8020059c:	64e2                	ld	s1,24(sp)
    8020059e:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
    802005a0:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
    802005a2:	03065633          	divu	a2,a2,a6
    802005a6:	8722                	mv	a4,s0
    802005a8:	f9bff0ef          	jal	ra,80200542 <printnum>
    802005ac:	b7f9                	j	8020057a <printnum+0x38>

00000000802005ae <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
    802005ae:	7119                	addi	sp,sp,-128
    802005b0:	f4a6                	sd	s1,104(sp)
    802005b2:	f0ca                	sd	s2,96(sp)
    802005b4:	ecce                	sd	s3,88(sp)
    802005b6:	e8d2                	sd	s4,80(sp)
    802005b8:	e4d6                	sd	s5,72(sp)
    802005ba:	e0da                	sd	s6,64(sp)
    802005bc:	fc5e                	sd	s7,56(sp)
    802005be:	f06a                	sd	s10,32(sp)
    802005c0:	fc86                	sd	ra,120(sp)
    802005c2:	f8a2                	sd	s0,112(sp)
    802005c4:	f862                	sd	s8,48(sp)
    802005c6:	f466                	sd	s9,40(sp)
    802005c8:	ec6e                	sd	s11,24(sp)
    802005ca:	892a                	mv	s2,a0
    802005cc:	84ae                	mv	s1,a1
    802005ce:	8d32                	mv	s10,a2
    802005d0:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    802005d2:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
    802005d6:	5b7d                	li	s6,-1
    802005d8:	00001a97          	auipc	s5,0x1
    802005dc:	97ca8a93          	addi	s5,s5,-1668 # 80200f54 <etext+0x5a8>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    802005e0:	00001b97          	auipc	s7,0x1
    802005e4:	b50b8b93          	addi	s7,s7,-1200 # 80201130 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    802005e8:	000d4503          	lbu	a0,0(s10)
    802005ec:	001d0413          	addi	s0,s10,1
    802005f0:	01350a63          	beq	a0,s3,80200604 <vprintfmt+0x56>
            if (ch == '\0') {
    802005f4:	c121                	beqz	a0,80200634 <vprintfmt+0x86>
            putch(ch, putdat);
    802005f6:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    802005f8:	0405                	addi	s0,s0,1
            putch(ch, putdat);
    802005fa:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    802005fc:	fff44503          	lbu	a0,-1(s0)
    80200600:	ff351ae3          	bne	a0,s3,802005f4 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
    80200604:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
    80200608:	02000793          	li	a5,32
        lflag = altflag = 0;
    8020060c:	4c81                	li	s9,0
    8020060e:	4881                	li	a7,0
        width = precision = -1;
    80200610:	5c7d                	li	s8,-1
    80200612:	5dfd                	li	s11,-1
    80200614:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
    80200618:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
    8020061a:	fdd6059b          	addiw	a1,a2,-35
    8020061e:	0ff5f593          	andi	a1,a1,255
    80200622:	00140d13          	addi	s10,s0,1
    80200626:	04b56263          	bltu	a0,a1,8020066a <vprintfmt+0xbc>
    8020062a:	058a                	slli	a1,a1,0x2
    8020062c:	95d6                	add	a1,a1,s5
    8020062e:	4194                	lw	a3,0(a1)
    80200630:	96d6                	add	a3,a3,s5
    80200632:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
    80200634:	70e6                	ld	ra,120(sp)
    80200636:	7446                	ld	s0,112(sp)
    80200638:	74a6                	ld	s1,104(sp)
    8020063a:	7906                	ld	s2,96(sp)
    8020063c:	69e6                	ld	s3,88(sp)
    8020063e:	6a46                	ld	s4,80(sp)
    80200640:	6aa6                	ld	s5,72(sp)
    80200642:	6b06                	ld	s6,64(sp)
    80200644:	7be2                	ld	s7,56(sp)
    80200646:	7c42                	ld	s8,48(sp)
    80200648:	7ca2                	ld	s9,40(sp)
    8020064a:	7d02                	ld	s10,32(sp)
    8020064c:	6de2                	ld	s11,24(sp)
    8020064e:	6109                	addi	sp,sp,128
    80200650:	8082                	ret
            padc = '0';
    80200652:	87b2                	mv	a5,a2
            goto reswitch;
    80200654:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
    80200658:	846a                	mv	s0,s10
    8020065a:	00140d13          	addi	s10,s0,1
    8020065e:	fdd6059b          	addiw	a1,a2,-35
    80200662:	0ff5f593          	andi	a1,a1,255
    80200666:	fcb572e3          	bgeu	a0,a1,8020062a <vprintfmt+0x7c>
            putch('%', putdat);
    8020066a:	85a6                	mv	a1,s1
    8020066c:	02500513          	li	a0,37
    80200670:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
    80200672:	fff44783          	lbu	a5,-1(s0)
    80200676:	8d22                	mv	s10,s0
    80200678:	f73788e3          	beq	a5,s3,802005e8 <vprintfmt+0x3a>
    8020067c:	ffed4783          	lbu	a5,-2(s10)
    80200680:	1d7d                	addi	s10,s10,-1
    80200682:	ff379de3          	bne	a5,s3,8020067c <vprintfmt+0xce>
    80200686:	b78d                	j	802005e8 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
    80200688:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
    8020068c:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
    80200690:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
    80200692:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
    80200696:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
    8020069a:	02d86463          	bltu	a6,a3,802006c2 <vprintfmt+0x114>
                ch = *fmt;
    8020069e:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
    802006a2:	002c169b          	slliw	a3,s8,0x2
    802006a6:	0186873b          	addw	a4,a3,s8
    802006aa:	0017171b          	slliw	a4,a4,0x1
    802006ae:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
    802006b0:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
    802006b4:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
    802006b6:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
    802006ba:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
    802006be:	fed870e3          	bgeu	a6,a3,8020069e <vprintfmt+0xf0>
            if (width < 0)
    802006c2:	f40ddce3          	bgez	s11,8020061a <vprintfmt+0x6c>
                width = precision, precision = -1;
    802006c6:	8de2                	mv	s11,s8
    802006c8:	5c7d                	li	s8,-1
    802006ca:	bf81                	j	8020061a <vprintfmt+0x6c>
            if (width < 0)
    802006cc:	fffdc693          	not	a3,s11
    802006d0:	96fd                	srai	a3,a3,0x3f
    802006d2:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
    802006d6:	00144603          	lbu	a2,1(s0)
    802006da:	2d81                	sext.w	s11,s11
    802006dc:	846a                	mv	s0,s10
            goto reswitch;
    802006de:	bf35                	j	8020061a <vprintfmt+0x6c>
            precision = va_arg(ap, int);
    802006e0:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
    802006e4:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
    802006e8:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
    802006ea:	846a                	mv	s0,s10
            goto process_precision;
    802006ec:	bfd9                	j	802006c2 <vprintfmt+0x114>
    if (lflag >= 2) {
    802006ee:	4705                	li	a4,1
            precision = va_arg(ap, int);
    802006f0:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
    802006f4:	01174463          	blt	a4,a7,802006fc <vprintfmt+0x14e>
    else if (lflag) {
    802006f8:	1a088e63          	beqz	a7,802008b4 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
    802006fc:	000a3603          	ld	a2,0(s4)
    80200700:	46c1                	li	a3,16
    80200702:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
    80200704:	2781                	sext.w	a5,a5
    80200706:	876e                	mv	a4,s11
    80200708:	85a6                	mv	a1,s1
    8020070a:	854a                	mv	a0,s2
    8020070c:	e37ff0ef          	jal	ra,80200542 <printnum>
            break;
    80200710:	bde1                	j	802005e8 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
    80200712:	000a2503          	lw	a0,0(s4)
    80200716:	85a6                	mv	a1,s1
    80200718:	0a21                	addi	s4,s4,8
    8020071a:	9902                	jalr	s2
            break;
    8020071c:	b5f1                	j	802005e8 <vprintfmt+0x3a>
    if (lflag >= 2) {
    8020071e:	4705                	li	a4,1
            precision = va_arg(ap, int);
    80200720:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
    80200724:	01174463          	blt	a4,a7,8020072c <vprintfmt+0x17e>
    else if (lflag) {
    80200728:	18088163          	beqz	a7,802008aa <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
    8020072c:	000a3603          	ld	a2,0(s4)
    80200730:	46a9                	li	a3,10
    80200732:	8a2e                	mv	s4,a1
    80200734:	bfc1                	j	80200704 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
    80200736:	00144603          	lbu	a2,1(s0)
            altflag = 1;
    8020073a:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
    8020073c:	846a                	mv	s0,s10
            goto reswitch;
    8020073e:	bdf1                	j	8020061a <vprintfmt+0x6c>
            putch(ch, putdat);
    80200740:	85a6                	mv	a1,s1
    80200742:	02500513          	li	a0,37
    80200746:	9902                	jalr	s2
            break;
    80200748:	b545                	j	802005e8 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
    8020074a:	00144603          	lbu	a2,1(s0)
            lflag ++;
    8020074e:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
    80200750:	846a                	mv	s0,s10
            goto reswitch;
    80200752:	b5e1                	j	8020061a <vprintfmt+0x6c>
    if (lflag >= 2) {
    80200754:	4705                	li	a4,1
            precision = va_arg(ap, int);
    80200756:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
    8020075a:	01174463          	blt	a4,a7,80200762 <vprintfmt+0x1b4>
    else if (lflag) {
    8020075e:	14088163          	beqz	a7,802008a0 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
    80200762:	000a3603          	ld	a2,0(s4)
    80200766:	46a1                	li	a3,8
    80200768:	8a2e                	mv	s4,a1
    8020076a:	bf69                	j	80200704 <vprintfmt+0x156>
            putch('0', putdat);
    8020076c:	03000513          	li	a0,48
    80200770:	85a6                	mv	a1,s1
    80200772:	e03e                	sd	a5,0(sp)
    80200774:	9902                	jalr	s2
            putch('x', putdat);
    80200776:	85a6                	mv	a1,s1
    80200778:	07800513          	li	a0,120
    8020077c:	9902                	jalr	s2
            num = (unsigned long long)va_arg(ap, void *);
    8020077e:	0a21                	addi	s4,s4,8
            goto number;
    80200780:	6782                	ld	a5,0(sp)
    80200782:	46c1                	li	a3,16
            num = (unsigned long long)va_arg(ap, void *);
    80200784:	ff8a3603          	ld	a2,-8(s4)
            goto number;
    80200788:	bfb5                	j	80200704 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
    8020078a:	000a3403          	ld	s0,0(s4)
    8020078e:	008a0713          	addi	a4,s4,8
    80200792:	e03a                	sd	a4,0(sp)
    80200794:	14040263          	beqz	s0,802008d8 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
    80200798:	0fb05763          	blez	s11,80200886 <vprintfmt+0x2d8>
    8020079c:	02d00693          	li	a3,45
    802007a0:	0cd79163          	bne	a5,a3,80200862 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    802007a4:	00044783          	lbu	a5,0(s0)
    802007a8:	0007851b          	sext.w	a0,a5
    802007ac:	cf85                	beqz	a5,802007e4 <vprintfmt+0x236>
    802007ae:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
    802007b2:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    802007b6:	000c4563          	bltz	s8,802007c0 <vprintfmt+0x212>
    802007ba:	3c7d                	addiw	s8,s8,-1
    802007bc:	036c0263          	beq	s8,s6,802007e0 <vprintfmt+0x232>
                    putch('?', putdat);
    802007c0:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
    802007c2:	0e0c8e63          	beqz	s9,802008be <vprintfmt+0x310>
    802007c6:	3781                	addiw	a5,a5,-32
    802007c8:	0ef47b63          	bgeu	s0,a5,802008be <vprintfmt+0x310>
                    putch('?', putdat);
    802007cc:	03f00513          	li	a0,63
    802007d0:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    802007d2:	000a4783          	lbu	a5,0(s4)
    802007d6:	3dfd                	addiw	s11,s11,-1
    802007d8:	0a05                	addi	s4,s4,1
    802007da:	0007851b          	sext.w	a0,a5
    802007de:	ffe1                	bnez	a5,802007b6 <vprintfmt+0x208>
            for (; width > 0; width --) {
    802007e0:	01b05963          	blez	s11,802007f2 <vprintfmt+0x244>
    802007e4:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
    802007e6:	85a6                	mv	a1,s1
    802007e8:	02000513          	li	a0,32
    802007ec:	9902                	jalr	s2
            for (; width > 0; width --) {
    802007ee:	fe0d9be3          	bnez	s11,802007e4 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
    802007f2:	6a02                	ld	s4,0(sp)
    802007f4:	bbd5                	j	802005e8 <vprintfmt+0x3a>
    if (lflag >= 2) {
    802007f6:	4705                	li	a4,1
            precision = va_arg(ap, int);
    802007f8:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
    802007fc:	01174463          	blt	a4,a7,80200804 <vprintfmt+0x256>
    else if (lflag) {
    80200800:	08088d63          	beqz	a7,8020089a <vprintfmt+0x2ec>
        return va_arg(*ap, long);
    80200804:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
    80200808:	0a044d63          	bltz	s0,802008c2 <vprintfmt+0x314>
            num = getint(&ap, lflag);
    8020080c:	8622                	mv	a2,s0
    8020080e:	8a66                	mv	s4,s9
    80200810:	46a9                	li	a3,10
    80200812:	bdcd                	j	80200704 <vprintfmt+0x156>
            err = va_arg(ap, int);
    80200814:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    80200818:	4719                	li	a4,6
            err = va_arg(ap, int);
    8020081a:	0a21                	addi	s4,s4,8
            if (err < 0) {
    8020081c:	41f7d69b          	sraiw	a3,a5,0x1f
    80200820:	8fb5                	xor	a5,a5,a3
    80200822:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    80200826:	02d74163          	blt	a4,a3,80200848 <vprintfmt+0x29a>
    8020082a:	00369793          	slli	a5,a3,0x3
    8020082e:	97de                	add	a5,a5,s7
    80200830:	639c                	ld	a5,0(a5)
    80200832:	cb99                	beqz	a5,80200848 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
    80200834:	86be                	mv	a3,a5
    80200836:	00000617          	auipc	a2,0x0
    8020083a:	71a60613          	addi	a2,a2,1818 # 80200f50 <etext+0x5a4>
    8020083e:	85a6                	mv	a1,s1
    80200840:	854a                	mv	a0,s2
    80200842:	0ce000ef          	jal	ra,80200910 <printfmt>
    80200846:	b34d                	j	802005e8 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
    80200848:	00000617          	auipc	a2,0x0
    8020084c:	6f860613          	addi	a2,a2,1784 # 80200f40 <etext+0x594>
    80200850:	85a6                	mv	a1,s1
    80200852:	854a                	mv	a0,s2
    80200854:	0bc000ef          	jal	ra,80200910 <printfmt>
    80200858:	bb41                	j	802005e8 <vprintfmt+0x3a>
                p = "(null)";
    8020085a:	00000417          	auipc	s0,0x0
    8020085e:	6de40413          	addi	s0,s0,1758 # 80200f38 <etext+0x58c>
                for (width -= strnlen(p, precision); width > 0; width --) {
    80200862:	85e2                	mv	a1,s8
    80200864:	8522                	mv	a0,s0
    80200866:	e43e                	sd	a5,8(sp)
    80200868:	116000ef          	jal	ra,8020097e <strnlen>
    8020086c:	40ad8dbb          	subw	s11,s11,a0
    80200870:	01b05b63          	blez	s11,80200886 <vprintfmt+0x2d8>
                    putch(padc, putdat);
    80200874:	67a2                	ld	a5,8(sp)
    80200876:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
    8020087a:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
    8020087c:	85a6                	mv	a1,s1
    8020087e:	8552                	mv	a0,s4
    80200880:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
    80200882:	fe0d9ce3          	bnez	s11,8020087a <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200886:	00044783          	lbu	a5,0(s0)
    8020088a:	00140a13          	addi	s4,s0,1
    8020088e:	0007851b          	sext.w	a0,a5
    80200892:	d3a5                	beqz	a5,802007f2 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
    80200894:	05e00413          	li	s0,94
    80200898:	bf39                	j	802007b6 <vprintfmt+0x208>
        return va_arg(*ap, int);
    8020089a:	000a2403          	lw	s0,0(s4)
    8020089e:	b7ad                	j	80200808 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
    802008a0:	000a6603          	lwu	a2,0(s4)
    802008a4:	46a1                	li	a3,8
    802008a6:	8a2e                	mv	s4,a1
    802008a8:	bdb1                	j	80200704 <vprintfmt+0x156>
    802008aa:	000a6603          	lwu	a2,0(s4)
    802008ae:	46a9                	li	a3,10
    802008b0:	8a2e                	mv	s4,a1
    802008b2:	bd89                	j	80200704 <vprintfmt+0x156>
    802008b4:	000a6603          	lwu	a2,0(s4)
    802008b8:	46c1                	li	a3,16
    802008ba:	8a2e                	mv	s4,a1
    802008bc:	b5a1                	j	80200704 <vprintfmt+0x156>
                    putch(ch, putdat);
    802008be:	9902                	jalr	s2
    802008c0:	bf09                	j	802007d2 <vprintfmt+0x224>
                putch('-', putdat);
    802008c2:	85a6                	mv	a1,s1
    802008c4:	02d00513          	li	a0,45
    802008c8:	e03e                	sd	a5,0(sp)
    802008ca:	9902                	jalr	s2
                num = -(long long)num;
    802008cc:	6782                	ld	a5,0(sp)
    802008ce:	8a66                	mv	s4,s9
    802008d0:	40800633          	neg	a2,s0
    802008d4:	46a9                	li	a3,10
    802008d6:	b53d                	j	80200704 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
    802008d8:	03b05163          	blez	s11,802008fa <vprintfmt+0x34c>
    802008dc:	02d00693          	li	a3,45
    802008e0:	f6d79de3          	bne	a5,a3,8020085a <vprintfmt+0x2ac>
                p = "(null)";
    802008e4:	00000417          	auipc	s0,0x0
    802008e8:	65440413          	addi	s0,s0,1620 # 80200f38 <etext+0x58c>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    802008ec:	02800793          	li	a5,40
    802008f0:	02800513          	li	a0,40
    802008f4:	00140a13          	addi	s4,s0,1
    802008f8:	bd6d                	j	802007b2 <vprintfmt+0x204>
    802008fa:	00000a17          	auipc	s4,0x0
    802008fe:	63fa0a13          	addi	s4,s4,1599 # 80200f39 <etext+0x58d>
    80200902:	02800513          	li	a0,40
    80200906:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
    8020090a:	05e00413          	li	s0,94
    8020090e:	b565                	j	802007b6 <vprintfmt+0x208>

0000000080200910 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    80200910:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
    80200912:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    80200916:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
    80200918:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    8020091a:	ec06                	sd	ra,24(sp)
    8020091c:	f83a                	sd	a4,48(sp)
    8020091e:	fc3e                	sd	a5,56(sp)
    80200920:	e0c2                	sd	a6,64(sp)
    80200922:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
    80200924:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
    80200926:	c89ff0ef          	jal	ra,802005ae <vprintfmt>
}
    8020092a:	60e2                	ld	ra,24(sp)
    8020092c:	6161                	addi	sp,sp,80
    8020092e:	8082                	ret

0000000080200930 <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
    80200930:	4781                	li	a5,0
    80200932:	00003717          	auipc	a4,0x3
    80200936:	6ce73703          	ld	a4,1742(a4) # 80204000 <SBI_CONSOLE_PUTCHAR>
    8020093a:	88ba                	mv	a7,a4
    8020093c:	852a                	mv	a0,a0
    8020093e:	85be                	mv	a1,a5
    80200940:	863e                	mv	a2,a5
    80200942:	00000073          	ecall
    80200946:	87aa                	mv	a5,a0
int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
}
void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
    80200948:	8082                	ret

000000008020094a <sbi_set_timer>:
    __asm__ volatile (
    8020094a:	4781                	li	a5,0
    8020094c:	00003717          	auipc	a4,0x3
    80200950:	6d473703          	ld	a4,1748(a4) # 80204020 <SBI_SET_TIMER>
    80200954:	88ba                	mv	a7,a4
    80200956:	852a                	mv	a0,a0
    80200958:	85be                	mv	a1,a5
    8020095a:	863e                	mv	a2,a5
    8020095c:	00000073          	ecall
    80200960:	87aa                	mv	a5,a0

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
    80200962:	8082                	ret

0000000080200964 <sbi_shutdown>:
    __asm__ volatile (
    80200964:	4781                	li	a5,0
    80200966:	00003717          	auipc	a4,0x3
    8020096a:	6a273703          	ld	a4,1698(a4) # 80204008 <SBI_SHUTDOWN>
    8020096e:	88ba                	mv	a7,a4
    80200970:	853e                	mv	a0,a5
    80200972:	85be                	mv	a1,a5
    80200974:	863e                	mv	a2,a5
    80200976:	00000073          	ecall
    8020097a:	87aa                	mv	a5,a0


void sbi_shutdown(void)
{
    sbi_call(SBI_SHUTDOWN,0,0,0);
    8020097c:	8082                	ret

000000008020097e <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    8020097e:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
    80200980:	e589                	bnez	a1,8020098a <strnlen+0xc>
    80200982:	a811                	j	80200996 <strnlen+0x18>
        cnt ++;
    80200984:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
    80200986:	00f58863          	beq	a1,a5,80200996 <strnlen+0x18>
    8020098a:	00f50733          	add	a4,a0,a5
    8020098e:	00074703          	lbu	a4,0(a4)
    80200992:	fb6d                	bnez	a4,80200984 <strnlen+0x6>
    80200994:	85be                	mv	a1,a5
    }
    return cnt;
}
    80200996:	852e                	mv	a0,a1
    80200998:	8082                	ret

000000008020099a <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
    8020099a:	ca01                	beqz	a2,802009aa <memset+0x10>
    8020099c:	962a                	add	a2,a2,a0
    char *p = s;
    8020099e:	87aa                	mv	a5,a0
        *p ++ = c;
    802009a0:	0785                	addi	a5,a5,1
    802009a2:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
    802009a6:	fec79de3          	bne	a5,a2,802009a0 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
    802009aa:	8082                	ret
