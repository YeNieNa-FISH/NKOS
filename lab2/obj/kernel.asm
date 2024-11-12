
bin/kernel：     文件格式 elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:
ffffffffc0200000:	c02052b7          	lui	t0,0xc0205
ffffffffc0200004:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200008:	01e31313          	slli	t1,t1,0x1e
ffffffffc020000c:	406282b3          	sub	t0,t0,t1
ffffffffc0200010:	00c2d293          	srli	t0,t0,0xc
ffffffffc0200014:	fff0031b          	addiw	t1,zero,-1
ffffffffc0200018:	03f31313          	slli	t1,t1,0x3f
ffffffffc020001c:	0062e2b3          	or	t0,t0,t1
ffffffffc0200020:	18029073          	csrw	satp,t0
ffffffffc0200024:	12000073          	sfence.vma
ffffffffc0200028:	c0205137          	lui	sp,0xc0205
ffffffffc020002c:	c02002b7          	lui	t0,0xc0200
ffffffffc0200030:	03628293          	addi	t0,t0,54 # ffffffffc0200036 <kern_init>
ffffffffc0200034:	8282                	jr	t0

ffffffffc0200036 <kern_init>:
void grade_backtrace(void);


int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200036:	00006517          	auipc	a0,0x6
ffffffffc020003a:	fda50513          	addi	a0,a0,-38 # ffffffffc0206010 <mem_buddy>
ffffffffc020003e:	00006617          	auipc	a2,0x6
ffffffffc0200042:	5fa60613          	addi	a2,a2,1530 # ffffffffc0206638 <end>
int kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
int kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	357010ef          	jal	ra,ffffffffc0201ba4 <memset>
    cons_init();  // init the console
ffffffffc0200052:	3f8000ef          	jal	ra,ffffffffc020044a <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200056:	00002517          	auipc	a0,0x2
ffffffffc020005a:	b6250513          	addi	a0,a0,-1182 # ffffffffc0201bb8 <etext+0x2>
ffffffffc020005e:	08e000ef          	jal	ra,ffffffffc02000ec <cputs>

    print_kerninfo();
ffffffffc0200062:	0da000ef          	jal	ra,ffffffffc020013c <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200066:	3fe000ef          	jal	ra,ffffffffc0200464 <idt_init>

    pmm_init();  // init physical memory management
ffffffffc020006a:	438010ef          	jal	ra,ffffffffc02014a2 <pmm_init>

    idt_init();  // init interrupt descriptor table
ffffffffc020006e:	3f6000ef          	jal	ra,ffffffffc0200464 <idt_init>

    clock_init();   // init clock interrupt
ffffffffc0200072:	396000ef          	jal	ra,ffffffffc0200408 <clock_init>
    intr_enable();  // enable irq interrupt
ffffffffc0200076:	3e2000ef          	jal	ra,ffffffffc0200458 <intr_enable>



    /* do nothing */
    while (1)
ffffffffc020007a:	a001                	j	ffffffffc020007a <kern_init+0x44>

ffffffffc020007c <cputch>:
ffffffffc020007c:	1141                	addi	sp,sp,-16
ffffffffc020007e:	e022                	sd	s0,0(sp)
ffffffffc0200080:	e406                	sd	ra,8(sp)
ffffffffc0200082:	842e                	mv	s0,a1
ffffffffc0200084:	3c8000ef          	jal	ra,ffffffffc020044c <cons_putc>
ffffffffc0200088:	401c                	lw	a5,0(s0)
ffffffffc020008a:	60a2                	ld	ra,8(sp)
ffffffffc020008c:	2785                	addiw	a5,a5,1
ffffffffc020008e:	c01c                	sw	a5,0(s0)
ffffffffc0200090:	6402                	ld	s0,0(sp)
ffffffffc0200092:	0141                	addi	sp,sp,16
ffffffffc0200094:	8082                	ret

ffffffffc0200096 <vcprintf>:
ffffffffc0200096:	1101                	addi	sp,sp,-32
ffffffffc0200098:	86ae                	mv	a3,a1
ffffffffc020009a:	862a                	mv	a2,a0
ffffffffc020009c:	006c                	addi	a1,sp,12
ffffffffc020009e:	00000517          	auipc	a0,0x0
ffffffffc02000a2:	fde50513          	addi	a0,a0,-34 # ffffffffc020007c <cputch>
ffffffffc02000a6:	ec06                	sd	ra,24(sp)
ffffffffc02000a8:	c602                	sw	zero,12(sp)
ffffffffc02000aa:	5f8010ef          	jal	ra,ffffffffc02016a2 <vprintfmt>
ffffffffc02000ae:	60e2                	ld	ra,24(sp)
ffffffffc02000b0:	4532                	lw	a0,12(sp)
ffffffffc02000b2:	6105                	addi	sp,sp,32
ffffffffc02000b4:	8082                	ret

ffffffffc02000b6 <cprintf>:
ffffffffc02000b6:	711d                	addi	sp,sp,-96
ffffffffc02000b8:	02810313          	addi	t1,sp,40 # ffffffffc0205028 <boot_page_table_sv39+0x28>
ffffffffc02000bc:	f42e                	sd	a1,40(sp)
ffffffffc02000be:	f832                	sd	a2,48(sp)
ffffffffc02000c0:	fc36                	sd	a3,56(sp)
ffffffffc02000c2:	862a                	mv	a2,a0
ffffffffc02000c4:	004c                	addi	a1,sp,4
ffffffffc02000c6:	00000517          	auipc	a0,0x0
ffffffffc02000ca:	fb650513          	addi	a0,a0,-74 # ffffffffc020007c <cputch>
ffffffffc02000ce:	869a                	mv	a3,t1
ffffffffc02000d0:	ec06                	sd	ra,24(sp)
ffffffffc02000d2:	e0ba                	sd	a4,64(sp)
ffffffffc02000d4:	e4be                	sd	a5,72(sp)
ffffffffc02000d6:	e8c2                	sd	a6,80(sp)
ffffffffc02000d8:	ecc6                	sd	a7,88(sp)
ffffffffc02000da:	e41a                	sd	t1,8(sp)
ffffffffc02000dc:	c202                	sw	zero,4(sp)
ffffffffc02000de:	5c4010ef          	jal	ra,ffffffffc02016a2 <vprintfmt>
ffffffffc02000e2:	60e2                	ld	ra,24(sp)
ffffffffc02000e4:	4512                	lw	a0,4(sp)
ffffffffc02000e6:	6125                	addi	sp,sp,96
ffffffffc02000e8:	8082                	ret

ffffffffc02000ea <cputchar>:
ffffffffc02000ea:	a68d                	j	ffffffffc020044c <cons_putc>

ffffffffc02000ec <cputs>:
ffffffffc02000ec:	1101                	addi	sp,sp,-32
ffffffffc02000ee:	e822                	sd	s0,16(sp)
ffffffffc02000f0:	ec06                	sd	ra,24(sp)
ffffffffc02000f2:	e426                	sd	s1,8(sp)
ffffffffc02000f4:	842a                	mv	s0,a0
ffffffffc02000f6:	00054503          	lbu	a0,0(a0)
ffffffffc02000fa:	c51d                	beqz	a0,ffffffffc0200128 <cputs+0x3c>
ffffffffc02000fc:	0405                	addi	s0,s0,1
ffffffffc02000fe:	4485                	li	s1,1
ffffffffc0200100:	9c81                	subw	s1,s1,s0
ffffffffc0200102:	34a000ef          	jal	ra,ffffffffc020044c <cons_putc>
ffffffffc0200106:	008487bb          	addw	a5,s1,s0
ffffffffc020010a:	0405                	addi	s0,s0,1
ffffffffc020010c:	fff44503          	lbu	a0,-1(s0)
ffffffffc0200110:	f96d                	bnez	a0,ffffffffc0200102 <cputs+0x16>
ffffffffc0200112:	0017841b          	addiw	s0,a5,1
ffffffffc0200116:	4529                	li	a0,10
ffffffffc0200118:	334000ef          	jal	ra,ffffffffc020044c <cons_putc>
ffffffffc020011c:	8522                	mv	a0,s0
ffffffffc020011e:	60e2                	ld	ra,24(sp)
ffffffffc0200120:	6442                	ld	s0,16(sp)
ffffffffc0200122:	64a2                	ld	s1,8(sp)
ffffffffc0200124:	6105                	addi	sp,sp,32
ffffffffc0200126:	8082                	ret
ffffffffc0200128:	4405                	li	s0,1
ffffffffc020012a:	b7f5                	j	ffffffffc0200116 <cputs+0x2a>

ffffffffc020012c <getchar>:
ffffffffc020012c:	1141                	addi	sp,sp,-16
ffffffffc020012e:	e406                	sd	ra,8(sp)
ffffffffc0200130:	324000ef          	jal	ra,ffffffffc0200454 <cons_getc>
ffffffffc0200134:	dd75                	beqz	a0,ffffffffc0200130 <getchar+0x4>
ffffffffc0200136:	60a2                	ld	ra,8(sp)
ffffffffc0200138:	0141                	addi	sp,sp,16
ffffffffc020013a:	8082                	ret

ffffffffc020013c <print_kerninfo>:
ffffffffc020013c:	1141                	addi	sp,sp,-16
ffffffffc020013e:	00002517          	auipc	a0,0x2
ffffffffc0200142:	aca50513          	addi	a0,a0,-1334 # ffffffffc0201c08 <etext+0x52>
ffffffffc0200146:	e406                	sd	ra,8(sp)
ffffffffc0200148:	f6fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020014c:	00000597          	auipc	a1,0x0
ffffffffc0200150:	eea58593          	addi	a1,a1,-278 # ffffffffc0200036 <kern_init>
ffffffffc0200154:	00002517          	auipc	a0,0x2
ffffffffc0200158:	ad450513          	addi	a0,a0,-1324 # ffffffffc0201c28 <etext+0x72>
ffffffffc020015c:	f5bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200160:	00002597          	auipc	a1,0x2
ffffffffc0200164:	a5658593          	addi	a1,a1,-1450 # ffffffffc0201bb6 <etext>
ffffffffc0200168:	00002517          	auipc	a0,0x2
ffffffffc020016c:	ae050513          	addi	a0,a0,-1312 # ffffffffc0201c48 <etext+0x92>
ffffffffc0200170:	f47ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200174:	00006597          	auipc	a1,0x6
ffffffffc0200178:	e9c58593          	addi	a1,a1,-356 # ffffffffc0206010 <mem_buddy>
ffffffffc020017c:	00002517          	auipc	a0,0x2
ffffffffc0200180:	aec50513          	addi	a0,a0,-1300 # ffffffffc0201c68 <etext+0xb2>
ffffffffc0200184:	f33ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200188:	00006597          	auipc	a1,0x6
ffffffffc020018c:	4b058593          	addi	a1,a1,1200 # ffffffffc0206638 <end>
ffffffffc0200190:	00002517          	auipc	a0,0x2
ffffffffc0200194:	af850513          	addi	a0,a0,-1288 # ffffffffc0201c88 <etext+0xd2>
ffffffffc0200198:	f1fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020019c:	00007597          	auipc	a1,0x7
ffffffffc02001a0:	89b58593          	addi	a1,a1,-1893 # ffffffffc0206a37 <end+0x3ff>
ffffffffc02001a4:	00000797          	auipc	a5,0x0
ffffffffc02001a8:	e9278793          	addi	a5,a5,-366 # ffffffffc0200036 <kern_init>
ffffffffc02001ac:	40f587b3          	sub	a5,a1,a5
ffffffffc02001b0:	43f7d593          	srai	a1,a5,0x3f
ffffffffc02001b4:	60a2                	ld	ra,8(sp)
ffffffffc02001b6:	3ff5f593          	andi	a1,a1,1023
ffffffffc02001ba:	95be                	add	a1,a1,a5
ffffffffc02001bc:	85a9                	srai	a1,a1,0xa
ffffffffc02001be:	00002517          	auipc	a0,0x2
ffffffffc02001c2:	aea50513          	addi	a0,a0,-1302 # ffffffffc0201ca8 <etext+0xf2>
ffffffffc02001c6:	0141                	addi	sp,sp,16
ffffffffc02001c8:	b5fd                	j	ffffffffc02000b6 <cprintf>

ffffffffc02001ca <print_stackframe>:
ffffffffc02001ca:	1141                	addi	sp,sp,-16
ffffffffc02001cc:	00002617          	auipc	a2,0x2
ffffffffc02001d0:	a0c60613          	addi	a2,a2,-1524 # ffffffffc0201bd8 <etext+0x22>
ffffffffc02001d4:	04e00593          	li	a1,78
ffffffffc02001d8:	00002517          	auipc	a0,0x2
ffffffffc02001dc:	a1850513          	addi	a0,a0,-1512 # ffffffffc0201bf0 <etext+0x3a>
ffffffffc02001e0:	e406                	sd	ra,8(sp)
ffffffffc02001e2:	1c6000ef          	jal	ra,ffffffffc02003a8 <__panic>

ffffffffc02001e6 <mon_help>:
ffffffffc02001e6:	1141                	addi	sp,sp,-16
ffffffffc02001e8:	00002617          	auipc	a2,0x2
ffffffffc02001ec:	bd060613          	addi	a2,a2,-1072 # ffffffffc0201db8 <commands+0xe0>
ffffffffc02001f0:	00002597          	auipc	a1,0x2
ffffffffc02001f4:	be858593          	addi	a1,a1,-1048 # ffffffffc0201dd8 <commands+0x100>
ffffffffc02001f8:	00002517          	auipc	a0,0x2
ffffffffc02001fc:	be850513          	addi	a0,a0,-1048 # ffffffffc0201de0 <commands+0x108>
ffffffffc0200200:	e406                	sd	ra,8(sp)
ffffffffc0200202:	eb5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200206:	00002617          	auipc	a2,0x2
ffffffffc020020a:	bea60613          	addi	a2,a2,-1046 # ffffffffc0201df0 <commands+0x118>
ffffffffc020020e:	00002597          	auipc	a1,0x2
ffffffffc0200212:	c0a58593          	addi	a1,a1,-1014 # ffffffffc0201e18 <commands+0x140>
ffffffffc0200216:	00002517          	auipc	a0,0x2
ffffffffc020021a:	bca50513          	addi	a0,a0,-1078 # ffffffffc0201de0 <commands+0x108>
ffffffffc020021e:	e99ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200222:	00002617          	auipc	a2,0x2
ffffffffc0200226:	c0660613          	addi	a2,a2,-1018 # ffffffffc0201e28 <commands+0x150>
ffffffffc020022a:	00002597          	auipc	a1,0x2
ffffffffc020022e:	c1e58593          	addi	a1,a1,-994 # ffffffffc0201e48 <commands+0x170>
ffffffffc0200232:	00002517          	auipc	a0,0x2
ffffffffc0200236:	bae50513          	addi	a0,a0,-1106 # ffffffffc0201de0 <commands+0x108>
ffffffffc020023a:	e7dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020023e:	60a2                	ld	ra,8(sp)
ffffffffc0200240:	4501                	li	a0,0
ffffffffc0200242:	0141                	addi	sp,sp,16
ffffffffc0200244:	8082                	ret

ffffffffc0200246 <mon_kerninfo>:
ffffffffc0200246:	1141                	addi	sp,sp,-16
ffffffffc0200248:	e406                	sd	ra,8(sp)
ffffffffc020024a:	ef3ff0ef          	jal	ra,ffffffffc020013c <print_kerninfo>
ffffffffc020024e:	60a2                	ld	ra,8(sp)
ffffffffc0200250:	4501                	li	a0,0
ffffffffc0200252:	0141                	addi	sp,sp,16
ffffffffc0200254:	8082                	ret

ffffffffc0200256 <mon_backtrace>:
ffffffffc0200256:	1141                	addi	sp,sp,-16
ffffffffc0200258:	e406                	sd	ra,8(sp)
ffffffffc020025a:	f71ff0ef          	jal	ra,ffffffffc02001ca <print_stackframe>
ffffffffc020025e:	60a2                	ld	ra,8(sp)
ffffffffc0200260:	4501                	li	a0,0
ffffffffc0200262:	0141                	addi	sp,sp,16
ffffffffc0200264:	8082                	ret

ffffffffc0200266 <kmonitor>:
ffffffffc0200266:	7115                	addi	sp,sp,-224
ffffffffc0200268:	e962                	sd	s8,144(sp)
ffffffffc020026a:	8c2a                	mv	s8,a0
ffffffffc020026c:	00002517          	auipc	a0,0x2
ffffffffc0200270:	ab450513          	addi	a0,a0,-1356 # ffffffffc0201d20 <commands+0x48>
ffffffffc0200274:	ed86                	sd	ra,216(sp)
ffffffffc0200276:	e9a2                	sd	s0,208(sp)
ffffffffc0200278:	e5a6                	sd	s1,200(sp)
ffffffffc020027a:	e1ca                	sd	s2,192(sp)
ffffffffc020027c:	fd4e                	sd	s3,184(sp)
ffffffffc020027e:	f952                	sd	s4,176(sp)
ffffffffc0200280:	f556                	sd	s5,168(sp)
ffffffffc0200282:	f15a                	sd	s6,160(sp)
ffffffffc0200284:	ed5e                	sd	s7,152(sp)
ffffffffc0200286:	e566                	sd	s9,136(sp)
ffffffffc0200288:	e16a                	sd	s10,128(sp)
ffffffffc020028a:	e2dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020028e:	00002517          	auipc	a0,0x2
ffffffffc0200292:	aba50513          	addi	a0,a0,-1350 # ffffffffc0201d48 <commands+0x70>
ffffffffc0200296:	e21ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020029a:	000c0563          	beqz	s8,ffffffffc02002a4 <kmonitor+0x3e>
ffffffffc020029e:	8562                	mv	a0,s8
ffffffffc02002a0:	3a2000ef          	jal	ra,ffffffffc0200642 <print_trapframe>
ffffffffc02002a4:	00002c97          	auipc	s9,0x2
ffffffffc02002a8:	a34c8c93          	addi	s9,s9,-1484 # ffffffffc0201cd8 <commands>
ffffffffc02002ac:	00002997          	auipc	s3,0x2
ffffffffc02002b0:	ac498993          	addi	s3,s3,-1340 # ffffffffc0201d70 <commands+0x98>
ffffffffc02002b4:	00002917          	auipc	s2,0x2
ffffffffc02002b8:	ac490913          	addi	s2,s2,-1340 # ffffffffc0201d78 <commands+0xa0>
ffffffffc02002bc:	4a3d                	li	s4,15
ffffffffc02002be:	00002b17          	auipc	s6,0x2
ffffffffc02002c2:	ac2b0b13          	addi	s6,s6,-1342 # ffffffffc0201d80 <commands+0xa8>
ffffffffc02002c6:	00002a97          	auipc	s5,0x2
ffffffffc02002ca:	b12a8a93          	addi	s5,s5,-1262 # ffffffffc0201dd8 <commands+0x100>
ffffffffc02002ce:	4b8d                	li	s7,3
ffffffffc02002d0:	854e                	mv	a0,s3
ffffffffc02002d2:	750010ef          	jal	ra,ffffffffc0201a22 <readline>
ffffffffc02002d6:	842a                	mv	s0,a0
ffffffffc02002d8:	dd65                	beqz	a0,ffffffffc02002d0 <kmonitor+0x6a>
ffffffffc02002da:	00054583          	lbu	a1,0(a0)
ffffffffc02002de:	4481                	li	s1,0
ffffffffc02002e0:	c999                	beqz	a1,ffffffffc02002f6 <kmonitor+0x90>
ffffffffc02002e2:	854a                	mv	a0,s2
ffffffffc02002e4:	0a3010ef          	jal	ra,ffffffffc0201b86 <strchr>
ffffffffc02002e8:	c925                	beqz	a0,ffffffffc0200358 <kmonitor+0xf2>
ffffffffc02002ea:	00144583          	lbu	a1,1(s0)
ffffffffc02002ee:	00040023          	sb	zero,0(s0)
ffffffffc02002f2:	0405                	addi	s0,s0,1
ffffffffc02002f4:	f5fd                	bnez	a1,ffffffffc02002e2 <kmonitor+0x7c>
ffffffffc02002f6:	dce9                	beqz	s1,ffffffffc02002d0 <kmonitor+0x6a>
ffffffffc02002f8:	6582                	ld	a1,0(sp)
ffffffffc02002fa:	00002d17          	auipc	s10,0x2
ffffffffc02002fe:	9ded0d13          	addi	s10,s10,-1570 # ffffffffc0201cd8 <commands>
ffffffffc0200302:	8556                	mv	a0,s5
ffffffffc0200304:	4401                	li	s0,0
ffffffffc0200306:	0d61                	addi	s10,s10,24
ffffffffc0200308:	055010ef          	jal	ra,ffffffffc0201b5c <strcmp>
ffffffffc020030c:	c919                	beqz	a0,ffffffffc0200322 <kmonitor+0xbc>
ffffffffc020030e:	2405                	addiw	s0,s0,1
ffffffffc0200310:	09740463          	beq	s0,s7,ffffffffc0200398 <kmonitor+0x132>
ffffffffc0200314:	000d3503          	ld	a0,0(s10)
ffffffffc0200318:	6582                	ld	a1,0(sp)
ffffffffc020031a:	0d61                	addi	s10,s10,24
ffffffffc020031c:	041010ef          	jal	ra,ffffffffc0201b5c <strcmp>
ffffffffc0200320:	f57d                	bnez	a0,ffffffffc020030e <kmonitor+0xa8>
ffffffffc0200322:	00141793          	slli	a5,s0,0x1
ffffffffc0200326:	97a2                	add	a5,a5,s0
ffffffffc0200328:	078e                	slli	a5,a5,0x3
ffffffffc020032a:	97e6                	add	a5,a5,s9
ffffffffc020032c:	6b9c                	ld	a5,16(a5)
ffffffffc020032e:	8662                	mv	a2,s8
ffffffffc0200330:	002c                	addi	a1,sp,8
ffffffffc0200332:	fff4851b          	addiw	a0,s1,-1
ffffffffc0200336:	9782                	jalr	a5
ffffffffc0200338:	f8055ce3          	bgez	a0,ffffffffc02002d0 <kmonitor+0x6a>
ffffffffc020033c:	60ee                	ld	ra,216(sp)
ffffffffc020033e:	644e                	ld	s0,208(sp)
ffffffffc0200340:	64ae                	ld	s1,200(sp)
ffffffffc0200342:	690e                	ld	s2,192(sp)
ffffffffc0200344:	79ea                	ld	s3,184(sp)
ffffffffc0200346:	7a4a                	ld	s4,176(sp)
ffffffffc0200348:	7aaa                	ld	s5,168(sp)
ffffffffc020034a:	7b0a                	ld	s6,160(sp)
ffffffffc020034c:	6bea                	ld	s7,152(sp)
ffffffffc020034e:	6c4a                	ld	s8,144(sp)
ffffffffc0200350:	6caa                	ld	s9,136(sp)
ffffffffc0200352:	6d0a                	ld	s10,128(sp)
ffffffffc0200354:	612d                	addi	sp,sp,224
ffffffffc0200356:	8082                	ret
ffffffffc0200358:	00044783          	lbu	a5,0(s0)
ffffffffc020035c:	dfc9                	beqz	a5,ffffffffc02002f6 <kmonitor+0x90>
ffffffffc020035e:	03448863          	beq	s1,s4,ffffffffc020038e <kmonitor+0x128>
ffffffffc0200362:	00349793          	slli	a5,s1,0x3
ffffffffc0200366:	0118                	addi	a4,sp,128
ffffffffc0200368:	97ba                	add	a5,a5,a4
ffffffffc020036a:	f887b023          	sd	s0,-128(a5)
ffffffffc020036e:	00044583          	lbu	a1,0(s0)
ffffffffc0200372:	2485                	addiw	s1,s1,1
ffffffffc0200374:	e591                	bnez	a1,ffffffffc0200380 <kmonitor+0x11a>
ffffffffc0200376:	b749                	j	ffffffffc02002f8 <kmonitor+0x92>
ffffffffc0200378:	0405                	addi	s0,s0,1
ffffffffc020037a:	00044583          	lbu	a1,0(s0)
ffffffffc020037e:	ddad                	beqz	a1,ffffffffc02002f8 <kmonitor+0x92>
ffffffffc0200380:	854a                	mv	a0,s2
ffffffffc0200382:	005010ef          	jal	ra,ffffffffc0201b86 <strchr>
ffffffffc0200386:	d96d                	beqz	a0,ffffffffc0200378 <kmonitor+0x112>
ffffffffc0200388:	00044583          	lbu	a1,0(s0)
ffffffffc020038c:	bf91                	j	ffffffffc02002e0 <kmonitor+0x7a>
ffffffffc020038e:	45c1                	li	a1,16
ffffffffc0200390:	855a                	mv	a0,s6
ffffffffc0200392:	d25ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200396:	b7f1                	j	ffffffffc0200362 <kmonitor+0xfc>
ffffffffc0200398:	6582                	ld	a1,0(sp)
ffffffffc020039a:	00002517          	auipc	a0,0x2
ffffffffc020039e:	a0650513          	addi	a0,a0,-1530 # ffffffffc0201da0 <commands+0xc8>
ffffffffc02003a2:	d15ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc02003a6:	b72d                	j	ffffffffc02002d0 <kmonitor+0x6a>

ffffffffc02003a8 <__panic>:
ffffffffc02003a8:	00006317          	auipc	t1,0x6
ffffffffc02003ac:	24830313          	addi	t1,t1,584 # ffffffffc02065f0 <is_panic>
ffffffffc02003b0:	00032303          	lw	t1,0(t1)
ffffffffc02003b4:	715d                	addi	sp,sp,-80
ffffffffc02003b6:	ec06                	sd	ra,24(sp)
ffffffffc02003b8:	e822                	sd	s0,16(sp)
ffffffffc02003ba:	f436                	sd	a3,40(sp)
ffffffffc02003bc:	f83a                	sd	a4,48(sp)
ffffffffc02003be:	fc3e                	sd	a5,56(sp)
ffffffffc02003c0:	e0c2                	sd	a6,64(sp)
ffffffffc02003c2:	e4c6                	sd	a7,72(sp)
ffffffffc02003c4:	02031c63          	bnez	t1,ffffffffc02003fc <__panic+0x54>
ffffffffc02003c8:	4785                	li	a5,1
ffffffffc02003ca:	8432                	mv	s0,a2
ffffffffc02003cc:	00006717          	auipc	a4,0x6
ffffffffc02003d0:	22f72223          	sw	a5,548(a4) # ffffffffc02065f0 <is_panic>
ffffffffc02003d4:	862e                	mv	a2,a1
ffffffffc02003d6:	103c                	addi	a5,sp,40
ffffffffc02003d8:	85aa                	mv	a1,a0
ffffffffc02003da:	00002517          	auipc	a0,0x2
ffffffffc02003de:	a7e50513          	addi	a0,a0,-1410 # ffffffffc0201e58 <commands+0x180>
ffffffffc02003e2:	e43e                	sd	a5,8(sp)
ffffffffc02003e4:	cd3ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc02003e8:	65a2                	ld	a1,8(sp)
ffffffffc02003ea:	8522                	mv	a0,s0
ffffffffc02003ec:	cabff0ef          	jal	ra,ffffffffc0200096 <vcprintf>
ffffffffc02003f0:	00002517          	auipc	a0,0x2
ffffffffc02003f4:	8e050513          	addi	a0,a0,-1824 # ffffffffc0201cd0 <etext+0x11a>
ffffffffc02003f8:	cbfff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc02003fc:	062000ef          	jal	ra,ffffffffc020045e <intr_disable>
ffffffffc0200400:	4501                	li	a0,0
ffffffffc0200402:	e65ff0ef          	jal	ra,ffffffffc0200266 <kmonitor>
ffffffffc0200406:	bfed                	j	ffffffffc0200400 <__panic+0x58>

ffffffffc0200408 <clock_init>:
ffffffffc0200408:	1141                	addi	sp,sp,-16
ffffffffc020040a:	e406                	sd	ra,8(sp)
ffffffffc020040c:	02000793          	li	a5,32
ffffffffc0200410:	1047a7f3          	csrrs	a5,sie,a5
ffffffffc0200414:	c0102573          	rdtime	a0
ffffffffc0200418:	67e1                	lui	a5,0x18
ffffffffc020041a:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc020041e:	953e                	add	a0,a0,a5
ffffffffc0200420:	6dc010ef          	jal	ra,ffffffffc0201afc <sbi_set_timer>
ffffffffc0200424:	60a2                	ld	ra,8(sp)
ffffffffc0200426:	00006797          	auipc	a5,0x6
ffffffffc020042a:	2007b523          	sd	zero,522(a5) # ffffffffc0206630 <ticks>
ffffffffc020042e:	00002517          	auipc	a0,0x2
ffffffffc0200432:	a4a50513          	addi	a0,a0,-1462 # ffffffffc0201e78 <commands+0x1a0>
ffffffffc0200436:	0141                	addi	sp,sp,16
ffffffffc0200438:	b9bd                	j	ffffffffc02000b6 <cprintf>

ffffffffc020043a <clock_set_next_event>:
ffffffffc020043a:	c0102573          	rdtime	a0
ffffffffc020043e:	67e1                	lui	a5,0x18
ffffffffc0200440:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc0200444:	953e                	add	a0,a0,a5
ffffffffc0200446:	6b60106f          	j	ffffffffc0201afc <sbi_set_timer>

ffffffffc020044a <cons_init>:
ffffffffc020044a:	8082                	ret

ffffffffc020044c <cons_putc>:
ffffffffc020044c:	0ff57513          	andi	a0,a0,255
ffffffffc0200450:	6900106f          	j	ffffffffc0201ae0 <sbi_console_putchar>

ffffffffc0200454 <cons_getc>:
ffffffffc0200454:	6c40106f          	j	ffffffffc0201b18 <sbi_console_getchar>

ffffffffc0200458 <intr_enable>:
ffffffffc0200458:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc020045c:	8082                	ret

ffffffffc020045e <intr_disable>:
ffffffffc020045e:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200462:	8082                	ret

ffffffffc0200464 <idt_init>:
ffffffffc0200464:	14005073          	csrwi	sscratch,0
ffffffffc0200468:	00000797          	auipc	a5,0x0
ffffffffc020046c:	2ec78793          	addi	a5,a5,748 # ffffffffc0200754 <__alltraps>
ffffffffc0200470:	10579073          	csrw	stvec,a5
ffffffffc0200474:	8082                	ret

ffffffffc0200476 <print_regs>:
ffffffffc0200476:	610c                	ld	a1,0(a0)
ffffffffc0200478:	1141                	addi	sp,sp,-16
ffffffffc020047a:	e022                	sd	s0,0(sp)
ffffffffc020047c:	842a                	mv	s0,a0
ffffffffc020047e:	00002517          	auipc	a0,0x2
ffffffffc0200482:	b1250513          	addi	a0,a0,-1262 # ffffffffc0201f90 <commands+0x2b8>
ffffffffc0200486:	e406                	sd	ra,8(sp)
ffffffffc0200488:	c2fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020048c:	640c                	ld	a1,8(s0)
ffffffffc020048e:	00002517          	auipc	a0,0x2
ffffffffc0200492:	b1a50513          	addi	a0,a0,-1254 # ffffffffc0201fa8 <commands+0x2d0>
ffffffffc0200496:	c21ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020049a:	680c                	ld	a1,16(s0)
ffffffffc020049c:	00002517          	auipc	a0,0x2
ffffffffc02004a0:	b2450513          	addi	a0,a0,-1244 # ffffffffc0201fc0 <commands+0x2e8>
ffffffffc02004a4:	c13ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc02004a8:	6c0c                	ld	a1,24(s0)
ffffffffc02004aa:	00002517          	auipc	a0,0x2
ffffffffc02004ae:	b2e50513          	addi	a0,a0,-1234 # ffffffffc0201fd8 <commands+0x300>
ffffffffc02004b2:	c05ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc02004b6:	700c                	ld	a1,32(s0)
ffffffffc02004b8:	00002517          	auipc	a0,0x2
ffffffffc02004bc:	b3850513          	addi	a0,a0,-1224 # ffffffffc0201ff0 <commands+0x318>
ffffffffc02004c0:	bf7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc02004c4:	740c                	ld	a1,40(s0)
ffffffffc02004c6:	00002517          	auipc	a0,0x2
ffffffffc02004ca:	b4250513          	addi	a0,a0,-1214 # ffffffffc0202008 <commands+0x330>
ffffffffc02004ce:	be9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc02004d2:	780c                	ld	a1,48(s0)
ffffffffc02004d4:	00002517          	auipc	a0,0x2
ffffffffc02004d8:	b4c50513          	addi	a0,a0,-1204 # ffffffffc0202020 <commands+0x348>
ffffffffc02004dc:	bdbff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc02004e0:	7c0c                	ld	a1,56(s0)
ffffffffc02004e2:	00002517          	auipc	a0,0x2
ffffffffc02004e6:	b5650513          	addi	a0,a0,-1194 # ffffffffc0202038 <commands+0x360>
ffffffffc02004ea:	bcdff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc02004ee:	602c                	ld	a1,64(s0)
ffffffffc02004f0:	00002517          	auipc	a0,0x2
ffffffffc02004f4:	b6050513          	addi	a0,a0,-1184 # ffffffffc0202050 <commands+0x378>
ffffffffc02004f8:	bbfff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc02004fc:	642c                	ld	a1,72(s0)
ffffffffc02004fe:	00002517          	auipc	a0,0x2
ffffffffc0200502:	b6a50513          	addi	a0,a0,-1174 # ffffffffc0202068 <commands+0x390>
ffffffffc0200506:	bb1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020050a:	682c                	ld	a1,80(s0)
ffffffffc020050c:	00002517          	auipc	a0,0x2
ffffffffc0200510:	b7450513          	addi	a0,a0,-1164 # ffffffffc0202080 <commands+0x3a8>
ffffffffc0200514:	ba3ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200518:	6c2c                	ld	a1,88(s0)
ffffffffc020051a:	00002517          	auipc	a0,0x2
ffffffffc020051e:	b7e50513          	addi	a0,a0,-1154 # ffffffffc0202098 <commands+0x3c0>
ffffffffc0200522:	b95ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200526:	702c                	ld	a1,96(s0)
ffffffffc0200528:	00002517          	auipc	a0,0x2
ffffffffc020052c:	b8850513          	addi	a0,a0,-1144 # ffffffffc02020b0 <commands+0x3d8>
ffffffffc0200530:	b87ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200534:	742c                	ld	a1,104(s0)
ffffffffc0200536:	00002517          	auipc	a0,0x2
ffffffffc020053a:	b9250513          	addi	a0,a0,-1134 # ffffffffc02020c8 <commands+0x3f0>
ffffffffc020053e:	b79ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200542:	782c                	ld	a1,112(s0)
ffffffffc0200544:	00002517          	auipc	a0,0x2
ffffffffc0200548:	b9c50513          	addi	a0,a0,-1124 # ffffffffc02020e0 <commands+0x408>
ffffffffc020054c:	b6bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200550:	7c2c                	ld	a1,120(s0)
ffffffffc0200552:	00002517          	auipc	a0,0x2
ffffffffc0200556:	ba650513          	addi	a0,a0,-1114 # ffffffffc02020f8 <commands+0x420>
ffffffffc020055a:	b5dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020055e:	604c                	ld	a1,128(s0)
ffffffffc0200560:	00002517          	auipc	a0,0x2
ffffffffc0200564:	bb050513          	addi	a0,a0,-1104 # ffffffffc0202110 <commands+0x438>
ffffffffc0200568:	b4fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020056c:	644c                	ld	a1,136(s0)
ffffffffc020056e:	00002517          	auipc	a0,0x2
ffffffffc0200572:	bba50513          	addi	a0,a0,-1094 # ffffffffc0202128 <commands+0x450>
ffffffffc0200576:	b41ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020057a:	684c                	ld	a1,144(s0)
ffffffffc020057c:	00002517          	auipc	a0,0x2
ffffffffc0200580:	bc450513          	addi	a0,a0,-1084 # ffffffffc0202140 <commands+0x468>
ffffffffc0200584:	b33ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200588:	6c4c                	ld	a1,152(s0)
ffffffffc020058a:	00002517          	auipc	a0,0x2
ffffffffc020058e:	bce50513          	addi	a0,a0,-1074 # ffffffffc0202158 <commands+0x480>
ffffffffc0200592:	b25ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200596:	704c                	ld	a1,160(s0)
ffffffffc0200598:	00002517          	auipc	a0,0x2
ffffffffc020059c:	bd850513          	addi	a0,a0,-1064 # ffffffffc0202170 <commands+0x498>
ffffffffc02005a0:	b17ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc02005a4:	744c                	ld	a1,168(s0)
ffffffffc02005a6:	00002517          	auipc	a0,0x2
ffffffffc02005aa:	be250513          	addi	a0,a0,-1054 # ffffffffc0202188 <commands+0x4b0>
ffffffffc02005ae:	b09ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc02005b2:	784c                	ld	a1,176(s0)
ffffffffc02005b4:	00002517          	auipc	a0,0x2
ffffffffc02005b8:	bec50513          	addi	a0,a0,-1044 # ffffffffc02021a0 <commands+0x4c8>
ffffffffc02005bc:	afbff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc02005c0:	7c4c                	ld	a1,184(s0)
ffffffffc02005c2:	00002517          	auipc	a0,0x2
ffffffffc02005c6:	bf650513          	addi	a0,a0,-1034 # ffffffffc02021b8 <commands+0x4e0>
ffffffffc02005ca:	aedff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc02005ce:	606c                	ld	a1,192(s0)
ffffffffc02005d0:	00002517          	auipc	a0,0x2
ffffffffc02005d4:	c0050513          	addi	a0,a0,-1024 # ffffffffc02021d0 <commands+0x4f8>
ffffffffc02005d8:	adfff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc02005dc:	646c                	ld	a1,200(s0)
ffffffffc02005de:	00002517          	auipc	a0,0x2
ffffffffc02005e2:	c0a50513          	addi	a0,a0,-1014 # ffffffffc02021e8 <commands+0x510>
ffffffffc02005e6:	ad1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc02005ea:	686c                	ld	a1,208(s0)
ffffffffc02005ec:	00002517          	auipc	a0,0x2
ffffffffc02005f0:	c1450513          	addi	a0,a0,-1004 # ffffffffc0202200 <commands+0x528>
ffffffffc02005f4:	ac3ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc02005f8:	6c6c                	ld	a1,216(s0)
ffffffffc02005fa:	00002517          	auipc	a0,0x2
ffffffffc02005fe:	c1e50513          	addi	a0,a0,-994 # ffffffffc0202218 <commands+0x540>
ffffffffc0200602:	ab5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200606:	706c                	ld	a1,224(s0)
ffffffffc0200608:	00002517          	auipc	a0,0x2
ffffffffc020060c:	c2850513          	addi	a0,a0,-984 # ffffffffc0202230 <commands+0x558>
ffffffffc0200610:	aa7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200614:	746c                	ld	a1,232(s0)
ffffffffc0200616:	00002517          	auipc	a0,0x2
ffffffffc020061a:	c3250513          	addi	a0,a0,-974 # ffffffffc0202248 <commands+0x570>
ffffffffc020061e:	a99ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200622:	786c                	ld	a1,240(s0)
ffffffffc0200624:	00002517          	auipc	a0,0x2
ffffffffc0200628:	c3c50513          	addi	a0,a0,-964 # ffffffffc0202260 <commands+0x588>
ffffffffc020062c:	a8bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200630:	7c6c                	ld	a1,248(s0)
ffffffffc0200632:	6402                	ld	s0,0(sp)
ffffffffc0200634:	60a2                	ld	ra,8(sp)
ffffffffc0200636:	00002517          	auipc	a0,0x2
ffffffffc020063a:	c4250513          	addi	a0,a0,-958 # ffffffffc0202278 <commands+0x5a0>
ffffffffc020063e:	0141                	addi	sp,sp,16
ffffffffc0200640:	bc9d                	j	ffffffffc02000b6 <cprintf>

ffffffffc0200642 <print_trapframe>:
ffffffffc0200642:	1141                	addi	sp,sp,-16
ffffffffc0200644:	e022                	sd	s0,0(sp)
ffffffffc0200646:	85aa                	mv	a1,a0
ffffffffc0200648:	842a                	mv	s0,a0
ffffffffc020064a:	00002517          	auipc	a0,0x2
ffffffffc020064e:	c4650513          	addi	a0,a0,-954 # ffffffffc0202290 <commands+0x5b8>
ffffffffc0200652:	e406                	sd	ra,8(sp)
ffffffffc0200654:	a63ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200658:	8522                	mv	a0,s0
ffffffffc020065a:	e1dff0ef          	jal	ra,ffffffffc0200476 <print_regs>
ffffffffc020065e:	10043583          	ld	a1,256(s0)
ffffffffc0200662:	00002517          	auipc	a0,0x2
ffffffffc0200666:	c4650513          	addi	a0,a0,-954 # ffffffffc02022a8 <commands+0x5d0>
ffffffffc020066a:	a4dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020066e:	10843583          	ld	a1,264(s0)
ffffffffc0200672:	00002517          	auipc	a0,0x2
ffffffffc0200676:	c4e50513          	addi	a0,a0,-946 # ffffffffc02022c0 <commands+0x5e8>
ffffffffc020067a:	a3dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020067e:	11043583          	ld	a1,272(s0)
ffffffffc0200682:	00002517          	auipc	a0,0x2
ffffffffc0200686:	c5650513          	addi	a0,a0,-938 # ffffffffc02022d8 <commands+0x600>
ffffffffc020068a:	a2dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020068e:	11843583          	ld	a1,280(s0)
ffffffffc0200692:	6402                	ld	s0,0(sp)
ffffffffc0200694:	60a2                	ld	ra,8(sp)
ffffffffc0200696:	00002517          	auipc	a0,0x2
ffffffffc020069a:	c5a50513          	addi	a0,a0,-934 # ffffffffc02022f0 <commands+0x618>
ffffffffc020069e:	0141                	addi	sp,sp,16
ffffffffc02006a0:	bc19                	j	ffffffffc02000b6 <cprintf>

ffffffffc02006a2 <interrupt_handler>:
ffffffffc02006a2:	11853783          	ld	a5,280(a0)
ffffffffc02006a6:	472d                	li	a4,11
ffffffffc02006a8:	0786                	slli	a5,a5,0x1
ffffffffc02006aa:	8385                	srli	a5,a5,0x1
ffffffffc02006ac:	06f76f63          	bltu	a4,a5,ffffffffc020072a <interrupt_handler+0x88>
ffffffffc02006b0:	00001717          	auipc	a4,0x1
ffffffffc02006b4:	7e470713          	addi	a4,a4,2020 # ffffffffc0201e94 <commands+0x1bc>
ffffffffc02006b8:	078a                	slli	a5,a5,0x2
ffffffffc02006ba:	97ba                	add	a5,a5,a4
ffffffffc02006bc:	439c                	lw	a5,0(a5)
ffffffffc02006be:	97ba                	add	a5,a5,a4
ffffffffc02006c0:	8782                	jr	a5
ffffffffc02006c2:	00002517          	auipc	a0,0x2
ffffffffc02006c6:	86650513          	addi	a0,a0,-1946 # ffffffffc0201f28 <commands+0x250>
ffffffffc02006ca:	b2f5                	j	ffffffffc02000b6 <cprintf>
ffffffffc02006cc:	00002517          	auipc	a0,0x2
ffffffffc02006d0:	83c50513          	addi	a0,a0,-1988 # ffffffffc0201f08 <commands+0x230>
ffffffffc02006d4:	b2cd                	j	ffffffffc02000b6 <cprintf>
ffffffffc02006d6:	00001517          	auipc	a0,0x1
ffffffffc02006da:	7f250513          	addi	a0,a0,2034 # ffffffffc0201ec8 <commands+0x1f0>
ffffffffc02006de:	bae1                	j	ffffffffc02000b6 <cprintf>
ffffffffc02006e0:	00002517          	auipc	a0,0x2
ffffffffc02006e4:	86850513          	addi	a0,a0,-1944 # ffffffffc0201f48 <commands+0x270>
ffffffffc02006e8:	b2f9                	j	ffffffffc02000b6 <cprintf>
ffffffffc02006ea:	1141                	addi	sp,sp,-16
ffffffffc02006ec:	e406                	sd	ra,8(sp)
ffffffffc02006ee:	d4dff0ef          	jal	ra,ffffffffc020043a <clock_set_next_event>
ffffffffc02006f2:	00006797          	auipc	a5,0x6
ffffffffc02006f6:	f3e78793          	addi	a5,a5,-194 # ffffffffc0206630 <ticks>
ffffffffc02006fa:	639c                	ld	a5,0(a5)
ffffffffc02006fc:	06400713          	li	a4,100
ffffffffc0200700:	0785                	addi	a5,a5,1
ffffffffc0200702:	02e7f733          	remu	a4,a5,a4
ffffffffc0200706:	00006697          	auipc	a3,0x6
ffffffffc020070a:	f2f6b523          	sd	a5,-214(a3) # ffffffffc0206630 <ticks>
ffffffffc020070e:	cf19                	beqz	a4,ffffffffc020072c <interrupt_handler+0x8a>
ffffffffc0200710:	60a2                	ld	ra,8(sp)
ffffffffc0200712:	0141                	addi	sp,sp,16
ffffffffc0200714:	8082                	ret
ffffffffc0200716:	00002517          	auipc	a0,0x2
ffffffffc020071a:	85a50513          	addi	a0,a0,-1958 # ffffffffc0201f70 <commands+0x298>
ffffffffc020071e:	ba61                	j	ffffffffc02000b6 <cprintf>
ffffffffc0200720:	00001517          	auipc	a0,0x1
ffffffffc0200724:	7c850513          	addi	a0,a0,1992 # ffffffffc0201ee8 <commands+0x210>
ffffffffc0200728:	b279                	j	ffffffffc02000b6 <cprintf>
ffffffffc020072a:	bf21                	j	ffffffffc0200642 <print_trapframe>
ffffffffc020072c:	60a2                	ld	ra,8(sp)
ffffffffc020072e:	06400593          	li	a1,100
ffffffffc0200732:	00002517          	auipc	a0,0x2
ffffffffc0200736:	82e50513          	addi	a0,a0,-2002 # ffffffffc0201f60 <commands+0x288>
ffffffffc020073a:	0141                	addi	sp,sp,16
ffffffffc020073c:	baad                	j	ffffffffc02000b6 <cprintf>

ffffffffc020073e <trap>:
ffffffffc020073e:	11853783          	ld	a5,280(a0)
ffffffffc0200742:	0007c763          	bltz	a5,ffffffffc0200750 <trap+0x12>
ffffffffc0200746:	472d                	li	a4,11
ffffffffc0200748:	00f76363          	bltu	a4,a5,ffffffffc020074e <trap+0x10>
ffffffffc020074c:	8082                	ret
ffffffffc020074e:	bdd5                	j	ffffffffc0200642 <print_trapframe>
ffffffffc0200750:	bf89                	j	ffffffffc02006a2 <interrupt_handler>
	...

ffffffffc0200754 <__alltraps>:
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
ffffffffc02007b6:	850a                	mv	a0,sp
ffffffffc02007b8:	f87ff0ef          	jal	ra,ffffffffc020073e <trap>

ffffffffc02007bc <__trapret>:
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
ffffffffc0200806:	10200073          	sret

ffffffffc020080a <buddy_init>:
    size |= size >> 8;
    size |= size >> 16;
    return size + 1;
}

static void buddy_init() {}
ffffffffc020080a:	8082                	ret

ffffffffc020080c <buddy_nr_free_pages>:


static size_t
buddy_nr_free_pages(void) {
    size_t total_free_pages = 0;
    for (int i = 0; i < num_buddy_zone; i++) {
ffffffffc020080c:	00006697          	auipc	a3,0x6
ffffffffc0200810:	de86a683          	lw	a3,-536(a3) # ffffffffc02065f4 <num_buddy_zone>
ffffffffc0200814:	02d05b63          	blez	a3,ffffffffc020084a <buddy_nr_free_pages+0x3e>
ffffffffc0200818:	36fd                	addiw	a3,a3,-1
ffffffffc020081a:	02069793          	slli	a5,a3,0x20
ffffffffc020081e:	9381                	srli	a5,a5,0x20
ffffffffc0200820:	00179693          	slli	a3,a5,0x1
ffffffffc0200824:	96be                	add	a3,a3,a5
ffffffffc0200826:	0692                	slli	a3,a3,0x4
ffffffffc0200828:	00006717          	auipc	a4,0x6
ffffffffc020082c:	83870713          	addi	a4,a4,-1992 # ffffffffc0206060 <mem_buddy+0x50>
ffffffffc0200830:	00006797          	auipc	a5,0x6
ffffffffc0200834:	80078793          	addi	a5,a5,-2048 # ffffffffc0206030 <mem_buddy+0x20>
ffffffffc0200838:	96ba                	add	a3,a3,a4
    size_t total_free_pages = 0;
ffffffffc020083a:	4501                	li	a0,0
        total_free_pages += mem_buddy[i].free_size;
ffffffffc020083c:	6398                	ld	a4,0(a5)
    for (int i = 0; i < num_buddy_zone; i++) {
ffffffffc020083e:	03078793          	addi	a5,a5,48
        total_free_pages += mem_buddy[i].free_size;
ffffffffc0200842:	953a                	add	a0,a0,a4
    for (int i = 0; i < num_buddy_zone; i++) {
ffffffffc0200844:	fed79ce3          	bne	a5,a3,ffffffffc020083c <buddy_nr_free_pages+0x30>
ffffffffc0200848:	8082                	ret
    size_t total_free_pages = 0;
ffffffffc020084a:	4501                	li	a0,0
    }
    return total_free_pages;
}
ffffffffc020084c:	8082                	ret

ffffffffc020084e <buddy_free_pages>:
    for (int i = 0; i < num_buddy_zone; i++) {
ffffffffc020084e:	00006617          	auipc	a2,0x6
ffffffffc0200852:	da662603          	lw	a2,-602(a2) # ffffffffc02065f4 <num_buddy_zone>
ffffffffc0200856:	10c05963          	blez	a2,ffffffffc0200968 <buddy_free_pages+0x11a>
ffffffffc020085a:	367d                	addiw	a2,a2,-1
ffffffffc020085c:	02061793          	slli	a5,a2,0x20
ffffffffc0200860:	9381                	srli	a5,a5,0x20
ffffffffc0200862:	00179613          	slli	a2,a5,0x1
ffffffffc0200866:	963e                	add	a2,a2,a5
ffffffffc0200868:	0612                	slli	a2,a2,0x4
ffffffffc020086a:	00005717          	auipc	a4,0x5
ffffffffc020086e:	7d670713          	addi	a4,a4,2006 # ffffffffc0206040 <mem_buddy+0x30>
ffffffffc0200872:	00005797          	auipc	a5,0x5
ffffffffc0200876:	79e78793          	addi	a5,a5,1950 # ffffffffc0206010 <mem_buddy>
ffffffffc020087a:	963a                	add	a2,a2,a4
    struct buddy *buddy = NULL;
ffffffffc020087c:	4581                	li	a1,0
        if (base >= t->begin_page && base < t->begin_page + t->size) {
ffffffffc020087e:	7798                	ld	a4,40(a5)
ffffffffc0200880:	00e56c63          	bltu	a0,a4,ffffffffc0200898 <buddy_free_pages+0x4a>
ffffffffc0200884:	0007b803          	ld	a6,0(a5)
ffffffffc0200888:	00281693          	slli	a3,a6,0x2
ffffffffc020088c:	96c2                	add	a3,a3,a6
ffffffffc020088e:	068e                	slli	a3,a3,0x3
ffffffffc0200890:	9736                	add	a4,a4,a3
ffffffffc0200892:	00e57363          	bgeu	a0,a4,ffffffffc0200898 <buddy_free_pages+0x4a>
ffffffffc0200896:	85be                	mv	a1,a5
    for (int i = 0; i < num_buddy_zone; i++) {
ffffffffc0200898:	03078793          	addi	a5,a5,48
ffffffffc020089c:	fef611e3          	bne	a2,a5,ffffffffc020087e <buddy_free_pages+0x30>
    if (!buddy) return;
ffffffffc02008a0:	c5e1                	beqz	a1,ffffffffc0200968 <buddy_free_pages+0x11a>
    unsigned offset = base - buddy->begin_page;
ffffffffc02008a2:	759c                	ld	a5,40(a1)
    assert(offset >= 0 && offset < buddy->size);
ffffffffc02008a4:	6198                	ld	a4,0(a1)
    unsigned offset = base - buddy->begin_page;
ffffffffc02008a6:	40f507b3          	sub	a5,a0,a5
ffffffffc02008aa:	878d                	srai	a5,a5,0x3
ffffffffc02008ac:	00002517          	auipc	a0,0x2
ffffffffc02008b0:	19c53503          	ld	a0,412(a0) # ffffffffc0202a48 <error_string+0xf0>
ffffffffc02008b4:	02a787b3          	mul	a5,a5,a0
    assert(offset >= 0 && offset < buddy->size);
ffffffffc02008b8:	02079693          	slli	a3,a5,0x20
ffffffffc02008bc:	9281                	srli	a3,a3,0x20
    unsigned offset = base - buddy->begin_page;
ffffffffc02008be:	0007851b          	sext.w	a0,a5
    assert(offset >= 0 && offset < buddy->size);
ffffffffc02008c2:	0ae6fb63          	bgeu	a3,a4,ffffffffc0200978 <buddy_free_pages+0x12a>
    index = offset + buddy->size - 1;
ffffffffc02008c6:	fff7079b          	addiw	a5,a4,-1
    for (; buddy->longest[index]; index = PARENT(index)) {
ffffffffc02008ca:	0085b803          	ld	a6,8(a1)
    index = offset + buddy->size - 1;
ffffffffc02008ce:	9fa9                	addw	a5,a5,a0
    for (; buddy->longest[index]; index = PARENT(index)) {
ffffffffc02008d0:	02079693          	slli	a3,a5,0x20
ffffffffc02008d4:	01d6d713          	srli	a4,a3,0x1d
ffffffffc02008d8:	9742                	add	a4,a4,a6
ffffffffc02008da:	6314                	ld	a3,0(a4)
ffffffffc02008dc:	cad9                	beqz	a3,ffffffffc0200972 <buddy_free_pages+0x124>
        if (index == 0)
ffffffffc02008de:	c7c9                	beqz	a5,ffffffffc0200968 <buddy_free_pages+0x11a>
        node_size *= 2;
ffffffffc02008e0:	4689                	li	a3,2
ffffffffc02008e2:	a021                	j	ffffffffc02008ea <buddy_free_pages+0x9c>
ffffffffc02008e4:	0016969b          	slliw	a3,a3,0x1
        if (index == 0)
ffffffffc02008e8:	c3c1                	beqz	a5,ffffffffc0200968 <buddy_free_pages+0x11a>
    for (; buddy->longest[index]; index = PARENT(index)) {
ffffffffc02008ea:	2785                	addiw	a5,a5,1
ffffffffc02008ec:	0017d79b          	srliw	a5,a5,0x1
ffffffffc02008f0:	37fd                	addiw	a5,a5,-1
ffffffffc02008f2:	02079613          	slli	a2,a5,0x20
ffffffffc02008f6:	01d65713          	srli	a4,a2,0x1d
ffffffffc02008fa:	9742                	add	a4,a4,a6
ffffffffc02008fc:	6310                	ld	a2,0(a4)
ffffffffc02008fe:	f27d                	bnez	a2,ffffffffc02008e4 <buddy_free_pages+0x96>
    buddy->longest[index] = node_size;
ffffffffc0200900:	02069613          	slli	a2,a3,0x20
ffffffffc0200904:	9201                	srli	a2,a2,0x20
ffffffffc0200906:	e310                	sd	a2,0(a4)
    buddy->free_size += node_size;
ffffffffc0200908:	7198                	ld	a4,32(a1)
ffffffffc020090a:	9732                	add	a4,a4,a2
ffffffffc020090c:	f198                	sd	a4,32(a1)
    while (index) {
ffffffffc020090e:	cfa9                	beqz	a5,ffffffffc0200968 <buddy_free_pages+0x11a>
        index = PARENT(index);
ffffffffc0200910:	2785                	addiw	a5,a5,1
ffffffffc0200912:	0017d59b          	srliw	a1,a5,0x1
ffffffffc0200916:	35fd                	addiw	a1,a1,-1
        right_longest = buddy->longest[RIGHT_LEAF(index)];
ffffffffc0200918:	ffe7f713          	andi	a4,a5,-2
        left_longest = buddy->longest[LEFT_LEAF(index)];
ffffffffc020091c:	0015961b          	slliw	a2,a1,0x1
ffffffffc0200920:	2605                	addiw	a2,a2,1
        right_longest = buddy->longest[RIGHT_LEAF(index)];
ffffffffc0200922:	1702                	slli	a4,a4,0x20
        left_longest = buddy->longest[LEFT_LEAF(index)];
ffffffffc0200924:	02061793          	slli	a5,a2,0x20
        right_longest = buddy->longest[RIGHT_LEAF(index)];
ffffffffc0200928:	9301                	srli	a4,a4,0x20
        left_longest = buddy->longest[LEFT_LEAF(index)];
ffffffffc020092a:	01d7d613          	srli	a2,a5,0x1d
        right_longest = buddy->longest[RIGHT_LEAF(index)];
ffffffffc020092e:	070e                	slli	a4,a4,0x3
ffffffffc0200930:	9742                	add	a4,a4,a6
        left_longest = buddy->longest[LEFT_LEAF(index)];
ffffffffc0200932:	9642                	add	a2,a2,a6
        right_longest = buddy->longest[RIGHT_LEAF(index)];
ffffffffc0200934:	00072883          	lw	a7,0(a4)
        left_longest = buddy->longest[LEFT_LEAF(index)];
ffffffffc0200938:	4210                	lw	a2,0(a2)
            buddy->longest[index] = node_size;
ffffffffc020093a:	02059793          	slli	a5,a1,0x20
        node_size *= 2;
ffffffffc020093e:	0016951b          	slliw	a0,a3,0x1
            buddy->longest[index] = node_size;
ffffffffc0200942:	01d7d713          	srli	a4,a5,0x1d
        node_size *= 2;
ffffffffc0200946:	0005069b          	sext.w	a3,a0
        if (left_longest + right_longest == node_size)
ffffffffc020094a:	0116033b          	addw	t1,a2,a7
        index = PARENT(index);
ffffffffc020094e:	0005879b          	sext.w	a5,a1
            buddy->longest[index] = node_size;
ffffffffc0200952:	9742                	add	a4,a4,a6
        if (left_longest + right_longest == node_size)
ffffffffc0200954:	00d30b63          	beq	t1,a3,ffffffffc020096a <buddy_free_pages+0x11c>
            buddy->longest[index] = MAX(left_longest, right_longest);
ffffffffc0200958:	85b2                	mv	a1,a2
ffffffffc020095a:	01167363          	bgeu	a2,a7,ffffffffc0200960 <buddy_free_pages+0x112>
ffffffffc020095e:	85c6                	mv	a1,a7
ffffffffc0200960:	1582                	slli	a1,a1,0x20
ffffffffc0200962:	9181                	srli	a1,a1,0x20
ffffffffc0200964:	e30c                	sd	a1,0(a4)
    while (index) {
ffffffffc0200966:	f7cd                	bnez	a5,ffffffffc0200910 <buddy_free_pages+0xc2>
ffffffffc0200968:	8082                	ret
            buddy->longest[index] = node_size;
ffffffffc020096a:	1502                	slli	a0,a0,0x20
ffffffffc020096c:	9101                	srli	a0,a0,0x20
ffffffffc020096e:	e308                	sd	a0,0(a4)
ffffffffc0200970:	bf79                	j	ffffffffc020090e <buddy_free_pages+0xc0>
    for (; buddy->longest[index]; index = PARENT(index)) {
ffffffffc0200972:	4605                	li	a2,1
    node_size = 1;
ffffffffc0200974:	4685                	li	a3,1
ffffffffc0200976:	bf41                	j	ffffffffc0200906 <buddy_free_pages+0xb8>
buddy_free_pages(struct Page *base, size_t n) {
ffffffffc0200978:	1141                	addi	sp,sp,-16
    assert(offset >= 0 && offset < buddy->size);
ffffffffc020097a:	00002697          	auipc	a3,0x2
ffffffffc020097e:	98e68693          	addi	a3,a3,-1650 # ffffffffc0202308 <commands+0x630>
ffffffffc0200982:	00002617          	auipc	a2,0x2
ffffffffc0200986:	9ae60613          	addi	a2,a2,-1618 # ffffffffc0202330 <commands+0x658>
ffffffffc020098a:	08c00593          	li	a1,140
ffffffffc020098e:	00002517          	auipc	a0,0x2
ffffffffc0200992:	9ba50513          	addi	a0,a0,-1606 # ffffffffc0202348 <commands+0x670>
buddy_free_pages(struct Page *base, size_t n) {
ffffffffc0200996:	e406                	sd	ra,8(sp)
    assert(offset >= 0 && offset < buddy->size);
ffffffffc0200998:	a11ff0ef          	jal	ra,ffffffffc02003a8 <__panic>

ffffffffc020099c <buddy_init_memmap>:
static void buddy_init_memmap(struct Page *base, size_t pagenum) {
ffffffffc020099c:	1101                	addi	sp,sp,-32
ffffffffc020099e:	ec06                	sd	ra,24(sp)
ffffffffc02009a0:	e822                	sd	s0,16(sp)
ffffffffc02009a2:	e426                	sd	s1,8(sp)
    assert(pagenum > 0);
ffffffffc02009a4:	20058363          	beqz	a1,ffffffffc0200baa <buddy_init_memmap+0x20e>
    cprintf("n: %d\n", pagenum);
ffffffffc02009a8:	842a                	mv	s0,a0
ffffffffc02009aa:	00002517          	auipc	a0,0x2
ffffffffc02009ae:	9c650513          	addi	a0,a0,-1594 # ffffffffc0202370 <commands+0x698>
ffffffffc02009b2:	84ae                	mv	s1,a1
ffffffffc02009b4:	f02ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    size |= size >> 1;
ffffffffc02009b8:	0014d793          	srli	a5,s1,0x1
ffffffffc02009bc:	8fc5                	or	a5,a5,s1
    size |= size >> 2;
ffffffffc02009be:	0027d713          	srli	a4,a5,0x2
ffffffffc02009c2:	8fd9                	or	a5,a5,a4
    size |= size >> 4;
ffffffffc02009c4:	0047d713          	srli	a4,a5,0x4
ffffffffc02009c8:	8fd9                	or	a5,a5,a4
    size |= size >> 8;
ffffffffc02009ca:	0087d713          	srli	a4,a5,0x8
ffffffffc02009ce:	8fd9                	or	a5,a5,a4
    size |= size >> 16;
ffffffffc02009d0:	0107d713          	srli	a4,a5,0x10
extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint64_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02009d4:	00006597          	auipc	a1,0x6
ffffffffc02009d8:	c2c5b583          	ld	a1,-980(a1) # ffffffffc0206600 <pages>
ffffffffc02009dc:	8fd9                	or	a5,a5,a4
ffffffffc02009de:	40b40e33          	sub	t3,s0,a1
    return size + 1;
ffffffffc02009e2:	00178693          	addi	a3,a5,1
ffffffffc02009e6:	403e5e13          	srai	t3,t3,0x3
ffffffffc02009ea:	00002e97          	auipc	t4,0x2
ffffffffc02009ee:	05eebe83          	ld	t4,94(t4) # ffffffffc0202a48 <error_string+0xf0>
    size_t v_alloced_size = GetSizePof2(v_size - pagenum);
ffffffffc02009f2:	40968733          	sub	a4,a3,s1
ffffffffc02009f6:	03de0e33          	mul	t3,t3,t4
    size |= size >> 1;
ffffffffc02009fa:	00175313          	srli	t1,a4,0x1
ffffffffc02009fe:	00e36333          	or	t1,t1,a4
    size |= size >> 2;
ffffffffc0200a02:	00235713          	srli	a4,t1,0x2
    struct buddy *buddy = &mem_buddy[num_buddy_zone++];
ffffffffc0200a06:	00006f97          	auipc	t6,0x6
ffffffffc0200a0a:	beef8f93          	addi	t6,t6,-1042 # ffffffffc02065f4 <num_buddy_zone>
    size |= size >> 2;
ffffffffc0200a0e:	00e36333          	or	t1,t1,a4
    struct buddy *buddy = &mem_buddy[num_buddy_zone++];
ffffffffc0200a12:	000fa883          	lw	a7,0(t6)
    size |= size >> 4;
ffffffffc0200a16:	00435713          	srli	a4,t1,0x4
ffffffffc0200a1a:	00e36333          	or	t1,t1,a4
    size |= size >> 8;
ffffffffc0200a1e:	00835713          	srli	a4,t1,0x8
ffffffffc0200a22:	00e36333          	or	t1,t1,a4
    buddy->size = v_size;
ffffffffc0200a26:	00189513          	slli	a0,a7,0x1
    size |= size >> 16;
ffffffffc0200a2a:	01035713          	srli	a4,t1,0x10
    buddy->size = v_size;
ffffffffc0200a2e:	01150633          	add	a2,a0,a7
ffffffffc0200a32:	00002f17          	auipc	t5,0x2
ffffffffc0200a36:	01ef3f03          	ld	t5,30(t5) # ffffffffc0202a50 <nbase>
    size |= size >> 16;
ffffffffc0200a3a:	00e36333          	or	t1,t1,a4
ffffffffc0200a3e:	9e7a                	add	t3,t3,t5
    buddy->size = v_size;
ffffffffc0200a40:	00005817          	auipc	a6,0x5
ffffffffc0200a44:	5d080813          	addi	a6,a6,1488 # ffffffffc0206010 <mem_buddy>
ffffffffc0200a48:	0612                	slli	a2,a2,0x4
    buddy->free_size = v_size - v_alloced_size;
ffffffffc0200a4a:	406787b3          	sub	a5,a5,t1
    buddy->size = v_size;
ffffffffc0200a4e:	9642                	add	a2,a2,a6
    struct buddy *buddy = &mem_buddy[num_buddy_zone++];
ffffffffc0200a50:	0018829b          	addiw	t0,a7,1
    
#endif 

static inline void *
page2kva(struct Page *page) {
    return KADDR(page2pa(page));
ffffffffc0200a54:	00ce1713          	slli	a4,t3,0xc
ffffffffc0200a58:	005fa023          	sw	t0,0(t6)
    buddy->free_size = v_size - v_alloced_size;
ffffffffc0200a5c:	f21c                	sd	a5,32(a2)
    buddy->size = v_size;
ffffffffc0200a5e:	e214                	sd	a3,0(a2)
ffffffffc0200a60:	00006f97          	auipc	t6,0x6
ffffffffc0200a64:	b98fbf83          	ld	t6,-1128(t6) # ffffffffc02065f8 <npage>
ffffffffc0200a68:	00c75793          	srli	a5,a4,0xc
    return size + 1;
ffffffffc0200a6c:	0305                	addi	t1,t1,1
ffffffffc0200a6e:	19f7f763          	bgeu	a5,t6,ffffffffc0200bfc <buddy_init_memmap+0x260>
ffffffffc0200a72:	00006297          	auipc	t0,0x6
ffffffffc0200a76:	bae2b283          	ld	t0,-1106(t0) # ffffffffc0206620 <va_pa_offset>
ffffffffc0200a7a:	00570e33          	add	t3,a4,t0
    buddy->begin_page = pa2page(PADDR(ROUNDUP(buddy->longest + 2 * v_size * sizeof(uintptr_t), PGSIZE)));
ffffffffc0200a7e:	6785                	lui	a5,0x1
ffffffffc0200a80:	00769713          	slli	a4,a3,0x7
ffffffffc0200a84:	17fd                	addi	a5,a5,-1
ffffffffc0200a86:	9772                	add	a4,a4,t3
ffffffffc0200a88:	973e                	add	a4,a4,a5
ffffffffc0200a8a:	77fd                	lui	a5,0xfffff
ffffffffc0200a8c:	8ff9                	and	a5,a5,a4
    buddy->longest = page2kva(base);
ffffffffc0200a8e:	01c63423          	sd	t3,8(a2)
    buddy->begin_page = pa2page(PADDR(ROUNDUP(buddy->longest + 2 * v_size * sizeof(uintptr_t), PGSIZE)));
ffffffffc0200a92:	c0200737          	lui	a4,0xc0200
ffffffffc0200a96:	12e7ea63          	bltu	a5,a4,ffffffffc0200bca <buddy_init_memmap+0x22e>
ffffffffc0200a9a:	405787b3          	sub	a5,a5,t0
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc0200a9e:	83b1                	srli	a5,a5,0xc
ffffffffc0200aa0:	15f7f263          	bgeu	a5,t6,ffffffffc0200be4 <buddy_init_memmap+0x248>
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0200aa4:	41e787b3          	sub	a5,a5,t5
ffffffffc0200aa8:	00279713          	slli	a4,a5,0x2
ffffffffc0200aac:	97ba                	add	a5,a5,a4
ffffffffc0200aae:	078e                	slli	a5,a5,0x3
ffffffffc0200ab0:	95be                	add	a1,a1,a5
    buddy->longest_num_page = buddy->begin_page - base;
ffffffffc0200ab2:	408587b3          	sub	a5,a1,s0
ffffffffc0200ab6:	878d                	srai	a5,a5,0x3
ffffffffc0200ab8:	03d78eb3          	mul	t4,a5,t4
    buddy->begin_page = pa2page(PADDR(ROUNDUP(buddy->longest + 2 * v_size * sizeof(uintptr_t), PGSIZE)));
ffffffffc0200abc:	f60c                	sd	a1,40(a2)
    size_t node_size = buddy->size * 2;
ffffffffc0200abe:	0686                	slli	a3,a3,0x1
    for (int i = 0; i < 2 * buddy->size - 1; i++) {
ffffffffc0200ac0:	4781                	li	a5,0
    buddy->total_num_page = pagenum - buddy->longest_num_page;
ffffffffc0200ac2:	41d484b3          	sub	s1,s1,t4
    buddy->longest_num_page = buddy->begin_page - base;
ffffffffc0200ac6:	01d63823          	sd	t4,16(a2)
    buddy->total_num_page = pagenum - buddy->longest_num_page;
ffffffffc0200aca:	ee04                	sd	s1,24(a2)
        if (IS_POWER_OF_2(i + 1)) {
ffffffffc0200acc:	0017871b          	addiw	a4,a5,1
ffffffffc0200ad0:	8f7d                	and	a4,a4,a5
ffffffffc0200ad2:	2701                	sext.w	a4,a4
ffffffffc0200ad4:	e311                	bnez	a4,ffffffffc0200ad8 <buddy_init_memmap+0x13c>
            node_size /= 2;
ffffffffc0200ad6:	8285                	srli	a3,a3,0x1
        buddy->longest[i] = node_size;
ffffffffc0200ad8:	6618                	ld	a4,8(a2)
ffffffffc0200ada:	00379593          	slli	a1,a5,0x3
ffffffffc0200ade:	0785                	addi	a5,a5,1
ffffffffc0200ae0:	972e                	add	a4,a4,a1
ffffffffc0200ae2:	e314                	sd	a3,0(a4)
    for (int i = 0; i < 2 * buddy->size - 1; i++) {
ffffffffc0200ae4:	6218                	ld	a4,0(a2)
ffffffffc0200ae6:	0706                	slli	a4,a4,0x1
ffffffffc0200ae8:	177d                	addi	a4,a4,-1
ffffffffc0200aea:	fee7e1e3          	bltu	a5,a4,ffffffffc0200acc <buddy_init_memmap+0x130>
        if (buddy->longest[index] == v_alloced_size) {
ffffffffc0200aee:	6610                	ld	a2,8(a2)
    int index = 0;
ffffffffc0200af0:	4781                	li	a5,0
        if (buddy->longest[index] == v_alloced_size) {
ffffffffc0200af2:	6218                	ld	a4,0(a2)
ffffffffc0200af4:	08670863          	beq	a4,t1,ffffffffc0200b84 <buddy_init_memmap+0x1e8>
        index = RIGHT_LEAF(index);
ffffffffc0200af8:	2785                	addiw	a5,a5,1
ffffffffc0200afa:	0017979b          	slliw	a5,a5,0x1
        if (buddy->longest[index] == v_alloced_size) {
ffffffffc0200afe:	00379713          	slli	a4,a5,0x3
ffffffffc0200b02:	9732                	add	a4,a4,a2
ffffffffc0200b04:	6314                	ld	a3,0(a4)
ffffffffc0200b06:	fe6699e3          	bne	a3,t1,ffffffffc0200af8 <buddy_init_memmap+0x15c>
        buddy->longest[index] = MAX(buddy->longest[LEFT_LEAF(index)], buddy->longest[RIGHT_LEAF(index)]);
ffffffffc0200b0a:	01150333          	add	t1,a0,a7
ffffffffc0200b0e:	0312                	slli	t1,t1,0x4
            buddy->longest[index] = 0;
ffffffffc0200b10:	00073023          	sd	zero,0(a4) # ffffffffc0200000 <kern_entry>
        buddy->longest[index] = MAX(buddy->longest[LEFT_LEAF(index)], buddy->longest[RIGHT_LEAF(index)]);
ffffffffc0200b14:	9342                	add	t1,t1,a6
        index = PARENT(index);
ffffffffc0200b16:	2785                	addiw	a5,a5,1
ffffffffc0200b18:	4017d79b          	sraiw	a5,a5,0x1
ffffffffc0200b1c:	37fd                	addiw	a5,a5,-1
        buddy->longest[index] = MAX(buddy->longest[LEFT_LEAF(index)], buddy->longest[RIGHT_LEAF(index)]);
ffffffffc0200b1e:	00833683          	ld	a3,8(t1)
ffffffffc0200b22:	0017971b          	slliw	a4,a5,0x1
ffffffffc0200b26:	0027061b          	addiw	a2,a4,2
ffffffffc0200b2a:	2705                	addiw	a4,a4,1
ffffffffc0200b2c:	060e                	slli	a2,a2,0x3
ffffffffc0200b2e:	070e                	slli	a4,a4,0x3
ffffffffc0200b30:	9636                	add	a2,a2,a3
ffffffffc0200b32:	9736                	add	a4,a4,a3
ffffffffc0200b34:	630c                	ld	a1,0(a4)
ffffffffc0200b36:	6218                	ld	a4,0(a2)
ffffffffc0200b38:	00379613          	slli	a2,a5,0x3
ffffffffc0200b3c:	96b2                	add	a3,a3,a2
ffffffffc0200b3e:	00b77363          	bgeu	a4,a1,ffffffffc0200b44 <buddy_init_memmap+0x1a8>
ffffffffc0200b42:	872e                	mv	a4,a1
ffffffffc0200b44:	e298                	sd	a4,0(a3)
    while (index) {
ffffffffc0200b46:	fbe1                	bnez	a5,ffffffffc0200b16 <buddy_init_memmap+0x17a>
    struct Page *p = buddy->begin_page;
ffffffffc0200b48:	9546                	add	a0,a0,a7
ffffffffc0200b4a:	0512                	slli	a0,a0,0x4
ffffffffc0200b4c:	9542                	add	a0,a0,a6
    for (; p != base + buddy->free_size; p ++) {
ffffffffc0200b4e:	7114                	ld	a3,32(a0)
    struct Page *p = buddy->begin_page;
ffffffffc0200b50:	751c                	ld	a5,40(a0)
    for (; p != base + buddy->free_size; p ++) {
ffffffffc0200b52:	00269713          	slli	a4,a3,0x2
ffffffffc0200b56:	9736                	add	a4,a4,a3
ffffffffc0200b58:	070e                	slli	a4,a4,0x3
ffffffffc0200b5a:	943a                	add	s0,s0,a4
ffffffffc0200b5c:	00878f63          	beq	a5,s0,ffffffffc0200b7a <buddy_init_memmap+0x1de>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200b60:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc0200b62:	8b05                	andi	a4,a4,1
ffffffffc0200b64:	c31d                	beqz	a4,ffffffffc0200b8a <buddy_init_memmap+0x1ee>
        p->flags = p->property = 0;
ffffffffc0200b66:	0007a823          	sw	zero,16(a5) # fffffffffffff010 <end+0x3fdf89d8>
ffffffffc0200b6a:	0007b423          	sd	zero,8(a5)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200b6e:	0007a023          	sw	zero,0(a5)
    for (; p != base + buddy->free_size; p ++) {
ffffffffc0200b72:	02878793          	addi	a5,a5,40
ffffffffc0200b76:	fe8795e3          	bne	a5,s0,ffffffffc0200b60 <buddy_init_memmap+0x1c4>
}
ffffffffc0200b7a:	60e2                	ld	ra,24(sp)
ffffffffc0200b7c:	6442                	ld	s0,16(sp)
ffffffffc0200b7e:	64a2                	ld	s1,8(sp)
ffffffffc0200b80:	6105                	addi	sp,sp,32
ffffffffc0200b82:	8082                	ret
            buddy->longest[index] = 0;
ffffffffc0200b84:	00063023          	sd	zero,0(a2)
    while (index) {
ffffffffc0200b88:	b7c1                	j	ffffffffc0200b48 <buddy_init_memmap+0x1ac>
        assert(PageReserved(p));
ffffffffc0200b8a:	00002697          	auipc	a3,0x2
ffffffffc0200b8e:	88668693          	addi	a3,a3,-1914 # ffffffffc0202410 <commands+0x738>
ffffffffc0200b92:	00001617          	auipc	a2,0x1
ffffffffc0200b96:	79e60613          	addi	a2,a2,1950 # ffffffffc0202330 <commands+0x658>
ffffffffc0200b9a:	04a00593          	li	a1,74
ffffffffc0200b9e:	00001517          	auipc	a0,0x1
ffffffffc0200ba2:	7aa50513          	addi	a0,a0,1962 # ffffffffc0202348 <commands+0x670>
ffffffffc0200ba6:	803ff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(pagenum > 0);
ffffffffc0200baa:	00001697          	auipc	a3,0x1
ffffffffc0200bae:	7b668693          	addi	a3,a3,1974 # ffffffffc0202360 <commands+0x688>
ffffffffc0200bb2:	00001617          	auipc	a2,0x1
ffffffffc0200bb6:	77e60613          	addi	a2,a2,1918 # ffffffffc0202330 <commands+0x658>
ffffffffc0200bba:	02400593          	li	a1,36
ffffffffc0200bbe:	00001517          	auipc	a0,0x1
ffffffffc0200bc2:	78a50513          	addi	a0,a0,1930 # ffffffffc0202348 <commands+0x670>
ffffffffc0200bc6:	fe2ff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    buddy->begin_page = pa2page(PADDR(ROUNDUP(buddy->longest + 2 * v_size * sizeof(uintptr_t), PGSIZE)));
ffffffffc0200bca:	86be                	mv	a3,a5
ffffffffc0200bcc:	00001617          	auipc	a2,0x1
ffffffffc0200bd0:	7ec60613          	addi	a2,a2,2028 # ffffffffc02023b8 <commands+0x6e0>
ffffffffc0200bd4:	02e00593          	li	a1,46
ffffffffc0200bd8:	00001517          	auipc	a0,0x1
ffffffffc0200bdc:	77050513          	addi	a0,a0,1904 # ffffffffc0202348 <commands+0x670>
ffffffffc0200be0:	fc8ff0ef          	jal	ra,ffffffffc02003a8 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0200be4:	00001617          	auipc	a2,0x1
ffffffffc0200be8:	7fc60613          	addi	a2,a2,2044 # ffffffffc02023e0 <commands+0x708>
ffffffffc0200bec:	06b00593          	li	a1,107
ffffffffc0200bf0:	00002517          	auipc	a0,0x2
ffffffffc0200bf4:	81050513          	addi	a0,a0,-2032 # ffffffffc0202400 <commands+0x728>
ffffffffc0200bf8:	fb0ff0ef          	jal	ra,ffffffffc02003a8 <__panic>
ffffffffc0200bfc:	86ba                	mv	a3,a4
ffffffffc0200bfe:	00001617          	auipc	a2,0x1
ffffffffc0200c02:	77a60613          	addi	a2,a2,1914 # ffffffffc0202378 <commands+0x6a0>
ffffffffc0200c06:	45fd                	li	a1,31
ffffffffc0200c08:	00001517          	auipc	a0,0x1
ffffffffc0200c0c:	79850513          	addi	a0,a0,1944 # ffffffffc02023a0 <commands+0x6c8>
ffffffffc0200c10:	f98ff0ef          	jal	ra,ffffffffc02003a8 <__panic>

ffffffffc0200c14 <buddy_alloc_pages>:
    assert(n > 0);
ffffffffc0200c14:	10050c63          	beqz	a0,ffffffffc0200d2c <buddy_alloc_pages+0x118>
    if (!IS_POWER_OF_2(n))
ffffffffc0200c18:	fff50793          	addi	a5,a0,-1
ffffffffc0200c1c:	8fe9                	and	a5,a5,a0
ffffffffc0200c1e:	eff1                	bnez	a5,ffffffffc0200cfa <buddy_alloc_pages+0xe6>
    for (int i = 0; i < num_buddy_zone; i++) {
ffffffffc0200c20:	00006697          	auipc	a3,0x6
ffffffffc0200c24:	9d46a683          	lw	a3,-1580(a3) # ffffffffc02065f4 <num_buddy_zone>
ffffffffc0200c28:	0cd05763          	blez	a3,ffffffffc0200cf6 <buddy_alloc_pages+0xe2>
ffffffffc0200c2c:	00005797          	auipc	a5,0x5
ffffffffc0200c30:	3ec78793          	addi	a5,a5,1004 # ffffffffc0206018 <mem_buddy+0x8>
ffffffffc0200c34:	4801                	li	a6,0
ffffffffc0200c36:	a031                	j	ffffffffc0200c42 <buddy_alloc_pages+0x2e>
ffffffffc0200c38:	2805                	addiw	a6,a6,1
ffffffffc0200c3a:	03078793          	addi	a5,a5,48
ffffffffc0200c3e:	0b068c63          	beq	a3,a6,ffffffffc0200cf6 <buddy_alloc_pages+0xe2>
        if (mem_buddy[i].longest[index] >= n) {
ffffffffc0200c42:	638c                	ld	a1,0(a5)
ffffffffc0200c44:	6198                	ld	a4,0(a1)
ffffffffc0200c46:	fea769e3          	bltu	a4,a0,ffffffffc0200c38 <buddy_alloc_pages+0x24>
    for (node_size = buddy->size; node_size != n; node_size /= 2) {
ffffffffc0200c4a:	00181893          	slli	a7,a6,0x1
ffffffffc0200c4e:	01088733          	add	a4,a7,a6
ffffffffc0200c52:	00005317          	auipc	t1,0x5
ffffffffc0200c56:	3be30313          	addi	t1,t1,958 # ffffffffc0206010 <mem_buddy>
ffffffffc0200c5a:	0712                	slli	a4,a4,0x4
ffffffffc0200c5c:	971a                	add	a4,a4,t1
ffffffffc0200c5e:	6314                	ld	a3,0(a4)
    size_t index = 0;
ffffffffc0200c60:	4781                	li	a5,0
    for (node_size = buddy->size; node_size != n; node_size /= 2) {
ffffffffc0200c62:	00d51863          	bne	a0,a3,ffffffffc0200c72 <buddy_alloc_pages+0x5e>
ffffffffc0200c66:	a86d                	j	ffffffffc0200d20 <buddy_alloc_pages+0x10c>
            index = LEFT_LEAF(index);
ffffffffc0200c68:	0786                	slli	a5,a5,0x1
    for (node_size = buddy->size; node_size != n; node_size /= 2) {
ffffffffc0200c6a:	8285                	srli	a3,a3,0x1
            index = LEFT_LEAF(index);
ffffffffc0200c6c:	0785                	addi	a5,a5,1
    for (node_size = buddy->size; node_size != n; node_size /= 2) {
ffffffffc0200c6e:	00d50d63          	beq	a0,a3,ffffffffc0200c88 <buddy_alloc_pages+0x74>
        if (buddy->longest[LEFT_LEAF(index)] >= n)
ffffffffc0200c72:	00479713          	slli	a4,a5,0x4
ffffffffc0200c76:	972e                	add	a4,a4,a1
ffffffffc0200c78:	6718                	ld	a4,8(a4)
ffffffffc0200c7a:	fea777e3          	bgeu	a4,a0,ffffffffc0200c68 <buddy_alloc_pages+0x54>
            index = RIGHT_LEAF(index);
ffffffffc0200c7e:	0785                	addi	a5,a5,1
    for (node_size = buddy->size; node_size != n; node_size /= 2) {
ffffffffc0200c80:	8285                	srli	a3,a3,0x1
            index = RIGHT_LEAF(index);
ffffffffc0200c82:	0786                	slli	a5,a5,0x1
    for (node_size = buddy->size; node_size != n; node_size /= 2) {
ffffffffc0200c84:	fed517e3          	bne	a0,a3,ffffffffc0200c72 <buddy_alloc_pages+0x5e>
    offset = (index + 1) * node_size - buddy->size;
ffffffffc0200c88:	00178713          	addi	a4,a5,1
ffffffffc0200c8c:	02a70e33          	mul	t3,a4,a0
    buddy->longest[index] = 0;
ffffffffc0200c90:	00379613          	slli	a2,a5,0x3
    offset = (index + 1) * node_size - buddy->size;
ffffffffc0200c94:	010886b3          	add	a3,a7,a6
    buddy->longest[index] = 0;
ffffffffc0200c98:	962e                	add	a2,a2,a1
    offset = (index + 1) * node_size - buddy->size;
ffffffffc0200c9a:	0692                	slli	a3,a3,0x4
    buddy->longest[index] = 0;
ffffffffc0200c9c:	00063023          	sd	zero,0(a2)
    offset = (index + 1) * node_size - buddy->size;
ffffffffc0200ca0:	969a                	add	a3,a3,t1
ffffffffc0200ca2:	6294                	ld	a3,0(a3)
ffffffffc0200ca4:	40de0e33          	sub	t3,t3,a3
    while (index) {
ffffffffc0200ca8:	e781                	bnez	a5,ffffffffc0200cb0 <buddy_alloc_pages+0x9c>
ffffffffc0200caa:	a02d                	j	ffffffffc0200cd4 <buddy_alloc_pages+0xc0>
ffffffffc0200cac:	00178713          	addi	a4,a5,1
        index = PARENT(index);
ffffffffc0200cb0:	8305                	srli	a4,a4,0x1
ffffffffc0200cb2:	fff70793          	addi	a5,a4,-1
        buddy->longest[index] = MAX(buddy->longest[LEFT_LEAF(index)], buddy->longest[RIGHT_LEAF(index)]);
ffffffffc0200cb6:	00479693          	slli	a3,a5,0x4
ffffffffc0200cba:	0712                	slli	a4,a4,0x4
ffffffffc0200cbc:	972e                	add	a4,a4,a1
ffffffffc0200cbe:	96ae                	add	a3,a3,a1
ffffffffc0200cc0:	6310                	ld	a2,0(a4)
ffffffffc0200cc2:	6694                	ld	a3,8(a3)
ffffffffc0200cc4:	00379713          	slli	a4,a5,0x3
ffffffffc0200cc8:	972e                	add	a4,a4,a1
ffffffffc0200cca:	00c6f363          	bgeu	a3,a2,ffffffffc0200cd0 <buddy_alloc_pages+0xbc>
ffffffffc0200cce:	86b2                	mv	a3,a2
ffffffffc0200cd0:	e314                	sd	a3,0(a4)
    while (index) {
ffffffffc0200cd2:	ffe9                	bnez	a5,ffffffffc0200cac <buddy_alloc_pages+0x98>
    buddy->free_size -= n;
ffffffffc0200cd4:	9846                	add	a6,a6,a7
ffffffffc0200cd6:	0812                	slli	a6,a6,0x4
ffffffffc0200cd8:	981a                	add	a6,a6,t1
ffffffffc0200cda:	02083783          	ld	a5,32(a6)
    return buddy->begin_page + offset;
ffffffffc0200cde:	02883683          	ld	a3,40(a6)
ffffffffc0200ce2:	002e1713          	slli	a4,t3,0x2
ffffffffc0200ce6:	9772                	add	a4,a4,t3
    buddy->free_size -= n;
ffffffffc0200ce8:	8f89                	sub	a5,a5,a0
    return buddy->begin_page + offset;
ffffffffc0200cea:	070e                	slli	a4,a4,0x3
    buddy->free_size -= n;
ffffffffc0200cec:	02f83023          	sd	a5,32(a6)
    return buddy->begin_page + offset;
ffffffffc0200cf0:	00e68533          	add	a0,a3,a4
ffffffffc0200cf4:	8082                	ret
        return NULL;
ffffffffc0200cf6:	4501                	li	a0,0
}
ffffffffc0200cf8:	8082                	ret
    size |= size >> 1;
ffffffffc0200cfa:	00155713          	srli	a4,a0,0x1
ffffffffc0200cfe:	00a767b3          	or	a5,a4,a0
    size |= size >> 2;
ffffffffc0200d02:	0027d713          	srli	a4,a5,0x2
ffffffffc0200d06:	8fd9                	or	a5,a5,a4
    size |= size >> 4;
ffffffffc0200d08:	0047d713          	srli	a4,a5,0x4
ffffffffc0200d0c:	8fd9                	or	a5,a5,a4
    size |= size >> 8;
ffffffffc0200d0e:	0087d713          	srli	a4,a5,0x8
ffffffffc0200d12:	8fd9                	or	a5,a5,a4
    size |= size >> 16;
ffffffffc0200d14:	0107d713          	srli	a4,a5,0x10
ffffffffc0200d18:	8fd9                	or	a5,a5,a4
    return size + 1;
ffffffffc0200d1a:	00178513          	addi	a0,a5,1
ffffffffc0200d1e:	b709                	j	ffffffffc0200c20 <buddy_alloc_pages+0xc>
    buddy->longest[index] = 0;
ffffffffc0200d20:	0005b023          	sd	zero,0(a1)
    offset = (index + 1) * node_size - buddy->size;
ffffffffc0200d24:	6318                	ld	a4,0(a4)
ffffffffc0200d26:	40e50e33          	sub	t3,a0,a4
    while (index) {
ffffffffc0200d2a:	b76d                	j	ffffffffc0200cd4 <buddy_alloc_pages+0xc0>
buddy_alloc_pages(size_t n) {
ffffffffc0200d2c:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0200d2e:	00001697          	auipc	a3,0x1
ffffffffc0200d32:	6f268693          	addi	a3,a3,1778 # ffffffffc0202420 <commands+0x748>
ffffffffc0200d36:	00001617          	auipc	a2,0x1
ffffffffc0200d3a:	5fa60613          	addi	a2,a2,1530 # ffffffffc0202330 <commands+0x658>
ffffffffc0200d3e:	05200593          	li	a1,82
ffffffffc0200d42:	00001517          	auipc	a0,0x1
ffffffffc0200d46:	60650513          	addi	a0,a0,1542 # ffffffffc0202348 <commands+0x670>
buddy_alloc_pages(size_t n) {
ffffffffc0200d4a:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200d4c:	e5cff0ef          	jal	ra,ffffffffc02003a8 <__panic>

ffffffffc0200d50 <buddy_check>:


static void
buddy_check(void) {
ffffffffc0200d50:	715d                	addi	sp,sp,-80
ffffffffc0200d52:	e0a2                	sd	s0,64(sp)
    for (int i = 0; i < num_buddy_zone; i++) {
ffffffffc0200d54:	00006417          	auipc	s0,0x6
ffffffffc0200d58:	8a040413          	addi	s0,s0,-1888 # ffffffffc02065f4 <num_buddy_zone>
ffffffffc0200d5c:	4014                	lw	a3,0(s0)
buddy_check(void) {
ffffffffc0200d5e:	e486                	sd	ra,72(sp)
ffffffffc0200d60:	fc26                	sd	s1,56(sp)
ffffffffc0200d62:	f84a                	sd	s2,48(sp)
ffffffffc0200d64:	f44e                	sd	s3,40(sp)
ffffffffc0200d66:	f052                	sd	s4,32(sp)
ffffffffc0200d68:	ec56                	sd	s5,24(sp)
ffffffffc0200d6a:	e85a                	sd	s6,16(sp)
ffffffffc0200d6c:	e45e                	sd	s7,8(sp)
    for (int i = 0; i < num_buddy_zone; i++) {
ffffffffc0200d6e:	46d05363          	blez	a3,ffffffffc02011d4 <buddy_check+0x484>
ffffffffc0200d72:	36fd                	addiw	a3,a3,-1
ffffffffc0200d74:	02069793          	slli	a5,a3,0x20
ffffffffc0200d78:	9381                	srli	a5,a5,0x20
ffffffffc0200d7a:	00179693          	slli	a3,a5,0x1
ffffffffc0200d7e:	96be                	add	a3,a3,a5
ffffffffc0200d80:	0692                	slli	a3,a3,0x4
ffffffffc0200d82:	00005717          	auipc	a4,0x5
ffffffffc0200d86:	2de70713          	addi	a4,a4,734 # ffffffffc0206060 <mem_buddy+0x50>
ffffffffc0200d8a:	00005797          	auipc	a5,0x5
ffffffffc0200d8e:	2a678793          	addi	a5,a5,678 # ffffffffc0206030 <mem_buddy+0x20>
ffffffffc0200d92:	96ba                	add	a3,a3,a4
    size_t total_free_pages = 0;
ffffffffc0200d94:	4481                	li	s1,0
        total_free_pages += mem_buddy[i].free_size;
ffffffffc0200d96:	6398                	ld	a4,0(a5)
    for (int i = 0; i < num_buddy_zone; i++) {
ffffffffc0200d98:	03078793          	addi	a5,a5,48
        total_free_pages += mem_buddy[i].free_size;
ffffffffc0200d9c:	94ba                	add	s1,s1,a4
    for (int i = 0; i < num_buddy_zone; i++) {
ffffffffc0200d9e:	fed79ce3          	bne	a5,a3,ffffffffc0200d96 <buddy_check+0x46>
    size_t total = buddy_nr_free_pages();
    cprintf("total: %d\n", total);
ffffffffc0200da2:	85a6                	mv	a1,s1
ffffffffc0200da4:	00001517          	auipc	a0,0x1
ffffffffc0200da8:	68450513          	addi	a0,a0,1668 # ffffffffc0202428 <commands+0x750>
ffffffffc0200dac:	b0aff0ef          	jal	ra,ffffffffc02000b6 <cprintf>

    struct Page *p0 = alloc_page();
ffffffffc0200db0:	4505                	li	a0,1
ffffffffc0200db2:	6b2000ef          	jal	ra,ffffffffc0201464 <alloc_pages>
ffffffffc0200db6:	892a                	mv	s2,a0
    assert(p0 != NULL);
ffffffffc0200db8:	68050663          	beqz	a0,ffffffffc0201444 <buddy_check+0x6f4>
    for (int i = 0; i < num_buddy_zone; i++) {
ffffffffc0200dbc:	4010                	lw	a2,0(s0)
    size_t total_free_pages = 0;
ffffffffc0200dbe:	4701                	li	a4,0
    for (int i = 0; i < num_buddy_zone; i++) {
ffffffffc0200dc0:	02c05a63          	blez	a2,ffffffffc0200df4 <buddy_check+0xa4>
ffffffffc0200dc4:	367d                	addiw	a2,a2,-1
ffffffffc0200dc6:	02061793          	slli	a5,a2,0x20
ffffffffc0200dca:	9381                	srli	a5,a5,0x20
ffffffffc0200dcc:	00179613          	slli	a2,a5,0x1
ffffffffc0200dd0:	963e                	add	a2,a2,a5
ffffffffc0200dd2:	00005717          	auipc	a4,0x5
ffffffffc0200dd6:	28e70713          	addi	a4,a4,654 # ffffffffc0206060 <mem_buddy+0x50>
ffffffffc0200dda:	0612                	slli	a2,a2,0x4
ffffffffc0200ddc:	963a                	add	a2,a2,a4
ffffffffc0200dde:	00005797          	auipc	a5,0x5
ffffffffc0200de2:	25278793          	addi	a5,a5,594 # ffffffffc0206030 <mem_buddy+0x20>
    size_t total_free_pages = 0;
ffffffffc0200de6:	4701                	li	a4,0
        total_free_pages += mem_buddy[i].free_size;
ffffffffc0200de8:	6394                	ld	a3,0(a5)
    for (int i = 0; i < num_buddy_zone; i++) {
ffffffffc0200dea:	03078793          	addi	a5,a5,48
        total_free_pages += mem_buddy[i].free_size;
ffffffffc0200dee:	9736                	add	a4,a4,a3
    for (int i = 0; i < num_buddy_zone; i++) {
ffffffffc0200df0:	fec79ce3          	bne	a5,a2,ffffffffc0200de8 <buddy_check+0x98>
    assert(buddy_nr_free_pages() == total - 1);
ffffffffc0200df4:	fff48793          	addi	a5,s1,-1
ffffffffc0200df8:	62e79663          	bne	a5,a4,ffffffffc0201424 <buddy_check+0x6d4>
    assert(p0 == mem_buddy[0].begin_page);
ffffffffc0200dfc:	00005a17          	auipc	s4,0x5
ffffffffc0200e00:	214a0a13          	addi	s4,s4,532 # ffffffffc0206010 <mem_buddy>
ffffffffc0200e04:	028a3783          	ld	a5,40(s4)
ffffffffc0200e08:	5f279e63          	bne	a5,s2,ffffffffc0201404 <buddy_check+0x6b4>

    struct Page *p1 = alloc_page();
ffffffffc0200e0c:	4505                	li	a0,1
ffffffffc0200e0e:	656000ef          	jal	ra,ffffffffc0201464 <alloc_pages>
ffffffffc0200e12:	89aa                	mv	s3,a0
    assert(p1 != NULL);
ffffffffc0200e14:	5c050863          	beqz	a0,ffffffffc02013e4 <buddy_check+0x694>
    for (int i = 0; i < num_buddy_zone; i++) {
ffffffffc0200e18:	4010                	lw	a2,0(s0)
    size_t total_free_pages = 0;
ffffffffc0200e1a:	4701                	li	a4,0
    for (int i = 0; i < num_buddy_zone; i++) {
ffffffffc0200e1c:	02c05a63          	blez	a2,ffffffffc0200e50 <buddy_check+0x100>
ffffffffc0200e20:	367d                	addiw	a2,a2,-1
ffffffffc0200e22:	02061793          	slli	a5,a2,0x20
ffffffffc0200e26:	9381                	srli	a5,a5,0x20
ffffffffc0200e28:	00179613          	slli	a2,a5,0x1
ffffffffc0200e2c:	963e                	add	a2,a2,a5
ffffffffc0200e2e:	00005717          	auipc	a4,0x5
ffffffffc0200e32:	23270713          	addi	a4,a4,562 # ffffffffc0206060 <mem_buddy+0x50>
ffffffffc0200e36:	0612                	slli	a2,a2,0x4
ffffffffc0200e38:	963a                	add	a2,a2,a4
ffffffffc0200e3a:	00005797          	auipc	a5,0x5
ffffffffc0200e3e:	1f678793          	addi	a5,a5,502 # ffffffffc0206030 <mem_buddy+0x20>
    size_t total_free_pages = 0;
ffffffffc0200e42:	4701                	li	a4,0
        total_free_pages += mem_buddy[i].free_size;
ffffffffc0200e44:	6394                	ld	a3,0(a5)
    for (int i = 0; i < num_buddy_zone; i++) {
ffffffffc0200e46:	03078793          	addi	a5,a5,48
        total_free_pages += mem_buddy[i].free_size;
ffffffffc0200e4a:	9736                	add	a4,a4,a3
    for (int i = 0; i < num_buddy_zone; i++) {
ffffffffc0200e4c:	fec79ce3          	bne	a5,a2,ffffffffc0200e44 <buddy_check+0xf4>
    assert(buddy_nr_free_pages() == total - 2);
ffffffffc0200e50:	ffe48793          	addi	a5,s1,-2
ffffffffc0200e54:	56e79863          	bne	a5,a4,ffffffffc02013c4 <buddy_check+0x674>
    assert(p1 == mem_buddy[0].begin_page + 1);
ffffffffc0200e58:	028a3783          	ld	a5,40(s4)
ffffffffc0200e5c:	02878793          	addi	a5,a5,40
ffffffffc0200e60:	54f99263          	bne	s3,a5,ffffffffc02013a4 <buddy_check+0x654>

    assert(p1 == p0 + 1);
ffffffffc0200e64:	02890793          	addi	a5,s2,40
ffffffffc0200e68:	48f99e63          	bne	s3,a5,ffffffffc0201304 <buddy_check+0x5b4>

    buddy_free_pages(p0, 1);
ffffffffc0200e6c:	4585                	li	a1,1
ffffffffc0200e6e:	854a                	mv	a0,s2
ffffffffc0200e70:	9dfff0ef          	jal	ra,ffffffffc020084e <buddy_free_pages>
    buddy_free_pages(p1, 1);
ffffffffc0200e74:	4585                	li	a1,1
ffffffffc0200e76:	854e                	mv	a0,s3
ffffffffc0200e78:	9d7ff0ef          	jal	ra,ffffffffc020084e <buddy_free_pages>
    for (int i = 0; i < num_buddy_zone; i++) {
ffffffffc0200e7c:	4010                	lw	a2,0(s0)
ffffffffc0200e7e:	34c05d63          	blez	a2,ffffffffc02011d8 <buddy_check+0x488>
ffffffffc0200e82:	367d                	addiw	a2,a2,-1
ffffffffc0200e84:	02061793          	slli	a5,a2,0x20
ffffffffc0200e88:	9381                	srli	a5,a5,0x20
ffffffffc0200e8a:	00179613          	slli	a2,a5,0x1
ffffffffc0200e8e:	963e                	add	a2,a2,a5
ffffffffc0200e90:	00005717          	auipc	a4,0x5
ffffffffc0200e94:	1d070713          	addi	a4,a4,464 # ffffffffc0206060 <mem_buddy+0x50>
ffffffffc0200e98:	0612                	slli	a2,a2,0x4
ffffffffc0200e9a:	963a                	add	a2,a2,a4
ffffffffc0200e9c:	00005797          	auipc	a5,0x5
ffffffffc0200ea0:	19478793          	addi	a5,a5,404 # ffffffffc0206030 <mem_buddy+0x20>
    size_t total_free_pages = 0;
ffffffffc0200ea4:	4701                	li	a4,0
        total_free_pages += mem_buddy[i].free_size;
ffffffffc0200ea6:	6394                	ld	a3,0(a5)
    for (int i = 0; i < num_buddy_zone; i++) {
ffffffffc0200ea8:	03078793          	addi	a5,a5,48
        total_free_pages += mem_buddy[i].free_size;
ffffffffc0200eac:	9736                	add	a4,a4,a3
    for (int i = 0; i < num_buddy_zone; i++) {
ffffffffc0200eae:	fec79ce3          	bne	a5,a2,ffffffffc0200ea6 <buddy_check+0x156>
    assert(buddy_nr_free_pages() == total);
ffffffffc0200eb2:	42e49963          	bne	s1,a4,ffffffffc02012e4 <buddy_check+0x594>

    p0 = buddy_alloc_pages(11);
ffffffffc0200eb6:	452d                	li	a0,11
ffffffffc0200eb8:	d5dff0ef          	jal	ra,ffffffffc0200c14 <buddy_alloc_pages>
    for (int i = 0; i < num_buddy_zone; i++) {
ffffffffc0200ebc:	4010                	lw	a2,0(s0)
    p0 = buddy_alloc_pages(11);
ffffffffc0200ebe:	89aa                	mv	s3,a0
    for (int i = 0; i < num_buddy_zone; i++) {
ffffffffc0200ec0:	30c05e63          	blez	a2,ffffffffc02011dc <buddy_check+0x48c>
ffffffffc0200ec4:	367d                	addiw	a2,a2,-1
ffffffffc0200ec6:	02061793          	slli	a5,a2,0x20
ffffffffc0200eca:	9381                	srli	a5,a5,0x20
ffffffffc0200ecc:	00179613          	slli	a2,a5,0x1
ffffffffc0200ed0:	963e                	add	a2,a2,a5
ffffffffc0200ed2:	00005717          	auipc	a4,0x5
ffffffffc0200ed6:	18e70713          	addi	a4,a4,398 # ffffffffc0206060 <mem_buddy+0x50>
ffffffffc0200eda:	0612                	slli	a2,a2,0x4
ffffffffc0200edc:	963a                	add	a2,a2,a4
ffffffffc0200ede:	00005797          	auipc	a5,0x5
ffffffffc0200ee2:	15278793          	addi	a5,a5,338 # ffffffffc0206030 <mem_buddy+0x20>
    size_t total_free_pages = 0;
ffffffffc0200ee6:	4701                	li	a4,0
        total_free_pages += mem_buddy[i].free_size;
ffffffffc0200ee8:	6394                	ld	a3,0(a5)
    for (int i = 0; i < num_buddy_zone; i++) {
ffffffffc0200eea:	03078793          	addi	a5,a5,48
        total_free_pages += mem_buddy[i].free_size;
ffffffffc0200eee:	9736                	add	a4,a4,a3
    for (int i = 0; i < num_buddy_zone; i++) {
ffffffffc0200ef0:	fec79ce3          	bne	a5,a2,ffffffffc0200ee8 <buddy_check+0x198>
    assert(buddy_nr_free_pages() == total - 16);
ffffffffc0200ef4:	ff048793          	addi	a5,s1,-16
ffffffffc0200ef8:	34e79663          	bne	a5,a4,ffffffffc0201244 <buddy_check+0x4f4>

    p1 = buddy_alloc_pages(100);
ffffffffc0200efc:	06400513          	li	a0,100
ffffffffc0200f00:	d15ff0ef          	jal	ra,ffffffffc0200c14 <buddy_alloc_pages>
    for (int i = 0; i < num_buddy_zone; i++) {
ffffffffc0200f04:	4010                	lw	a2,0(s0)
    p1 = buddy_alloc_pages(100);
ffffffffc0200f06:	892a                	mv	s2,a0
    for (int i = 0; i < num_buddy_zone; i++) {
ffffffffc0200f08:	2cc05c63          	blez	a2,ffffffffc02011e0 <buddy_check+0x490>
ffffffffc0200f0c:	367d                	addiw	a2,a2,-1
ffffffffc0200f0e:	02061793          	slli	a5,a2,0x20
ffffffffc0200f12:	9381                	srli	a5,a5,0x20
ffffffffc0200f14:	00179613          	slli	a2,a5,0x1
ffffffffc0200f18:	963e                	add	a2,a2,a5
ffffffffc0200f1a:	00005717          	auipc	a4,0x5
ffffffffc0200f1e:	14670713          	addi	a4,a4,326 # ffffffffc0206060 <mem_buddy+0x50>
ffffffffc0200f22:	0612                	slli	a2,a2,0x4
ffffffffc0200f24:	963a                	add	a2,a2,a4
ffffffffc0200f26:	00005797          	auipc	a5,0x5
ffffffffc0200f2a:	10a78793          	addi	a5,a5,266 # ffffffffc0206030 <mem_buddy+0x20>
    size_t total_free_pages = 0;
ffffffffc0200f2e:	4701                	li	a4,0
        total_free_pages += mem_buddy[i].free_size;
ffffffffc0200f30:	6394                	ld	a3,0(a5)
    for (int i = 0; i < num_buddy_zone; i++) {
ffffffffc0200f32:	03078793          	addi	a5,a5,48
        total_free_pages += mem_buddy[i].free_size;
ffffffffc0200f36:	9736                	add	a4,a4,a3
    for (int i = 0; i < num_buddy_zone; i++) {
ffffffffc0200f38:	fec79ce3          	bne	a5,a2,ffffffffc0200f30 <buddy_check+0x1e0>
    assert(buddy_nr_free_pages() == total - 144);
ffffffffc0200f3c:	f7048793          	addi	a5,s1,-144
ffffffffc0200f40:	2ee79263          	bne	a5,a4,ffffffffc0201224 <buddy_check+0x4d4>

    buddy_free_pages(p0, -1);
ffffffffc0200f44:	55fd                	li	a1,-1
ffffffffc0200f46:	854e                	mv	a0,s3
ffffffffc0200f48:	907ff0ef          	jal	ra,ffffffffc020084e <buddy_free_pages>
    buddy_free_pages(p1, -1);
ffffffffc0200f4c:	55fd                	li	a1,-1
ffffffffc0200f4e:	854a                	mv	a0,s2
ffffffffc0200f50:	8ffff0ef          	jal	ra,ffffffffc020084e <buddy_free_pages>
    for (int i = 0; i < num_buddy_zone; i++) {
ffffffffc0200f54:	4010                	lw	a2,0(s0)
ffffffffc0200f56:	28c05763          	blez	a2,ffffffffc02011e4 <buddy_check+0x494>
ffffffffc0200f5a:	367d                	addiw	a2,a2,-1
ffffffffc0200f5c:	02061793          	slli	a5,a2,0x20
ffffffffc0200f60:	9381                	srli	a5,a5,0x20
ffffffffc0200f62:	00179613          	slli	a2,a5,0x1
ffffffffc0200f66:	963e                	add	a2,a2,a5
ffffffffc0200f68:	00005717          	auipc	a4,0x5
ffffffffc0200f6c:	0f870713          	addi	a4,a4,248 # ffffffffc0206060 <mem_buddy+0x50>
ffffffffc0200f70:	0612                	slli	a2,a2,0x4
ffffffffc0200f72:	963a                	add	a2,a2,a4
ffffffffc0200f74:	00005797          	auipc	a5,0x5
ffffffffc0200f78:	0bc78793          	addi	a5,a5,188 # ffffffffc0206030 <mem_buddy+0x20>
    size_t total_free_pages = 0;
ffffffffc0200f7c:	4701                	li	a4,0
        total_free_pages += mem_buddy[i].free_size;
ffffffffc0200f7e:	6394                	ld	a3,0(a5)
    for (int i = 0; i < num_buddy_zone; i++) {
ffffffffc0200f80:	03078793          	addi	a5,a5,48
        total_free_pages += mem_buddy[i].free_size;
ffffffffc0200f84:	9736                	add	a4,a4,a3
    for (int i = 0; i < num_buddy_zone; i++) {
ffffffffc0200f86:	fec79ce3          	bne	a5,a2,ffffffffc0200f7e <buddy_check+0x22e>
    assert(buddy_nr_free_pages() == total);
ffffffffc0200f8a:	3ae49d63          	bne	s1,a4,ffffffffc0201344 <buddy_check+0x5f4>

    p0 = buddy_alloc_pages(total);
ffffffffc0200f8e:	8526                	mv	a0,s1
ffffffffc0200f90:	c85ff0ef          	jal	ra,ffffffffc0200c14 <buddy_alloc_pages>
    assert(p0 == NULL);
ffffffffc0200f94:	38051863          	bnez	a0,ffffffffc0201324 <buddy_check+0x5d4>

    // debug_buddy_tree(7, "221, init");
    p0 = buddy_alloc_pages(512);
ffffffffc0200f98:	20000513          	li	a0,512
ffffffffc0200f9c:	c79ff0ef          	jal	ra,ffffffffc0200c14 <buddy_alloc_pages>
    for (int i = 0; i < num_buddy_zone; i++) {
ffffffffc0200fa0:	4010                	lw	a2,0(s0)
    p0 = buddy_alloc_pages(512);
ffffffffc0200fa2:	892a                	mv	s2,a0
    for (int i = 0; i < num_buddy_zone; i++) {
ffffffffc0200fa4:	24c05263          	blez	a2,ffffffffc02011e8 <buddy_check+0x498>
ffffffffc0200fa8:	367d                	addiw	a2,a2,-1
ffffffffc0200faa:	02061793          	slli	a5,a2,0x20
ffffffffc0200fae:	9381                	srli	a5,a5,0x20
ffffffffc0200fb0:	00179613          	slli	a2,a5,0x1
ffffffffc0200fb4:	963e                	add	a2,a2,a5
ffffffffc0200fb6:	00005717          	auipc	a4,0x5
ffffffffc0200fba:	0aa70713          	addi	a4,a4,170 # ffffffffc0206060 <mem_buddy+0x50>
ffffffffc0200fbe:	0612                	slli	a2,a2,0x4
ffffffffc0200fc0:	963a                	add	a2,a2,a4
ffffffffc0200fc2:	00005797          	auipc	a5,0x5
ffffffffc0200fc6:	06e78793          	addi	a5,a5,110 # ffffffffc0206030 <mem_buddy+0x20>
    size_t total_free_pages = 0;
ffffffffc0200fca:	4701                	li	a4,0
        total_free_pages += mem_buddy[i].free_size;
ffffffffc0200fcc:	6394                	ld	a3,0(a5)
    for (int i = 0; i < num_buddy_zone; i++) {
ffffffffc0200fce:	03078793          	addi	a5,a5,48
        total_free_pages += mem_buddy[i].free_size;
ffffffffc0200fd2:	9736                	add	a4,a4,a3
    for (int i = 0; i < num_buddy_zone; i++) {
ffffffffc0200fd4:	fec79ce3          	bne	a5,a2,ffffffffc0200fcc <buddy_check+0x27c>
    // debug_buddy_tree(7, "221, alloc 512");
    assert(buddy_nr_free_pages() == total - 512);
ffffffffc0200fd8:	e0048793          	addi	a5,s1,-512
ffffffffc0200fdc:	2ee79463          	bne	a5,a4,ffffffffc02012c4 <buddy_check+0x574>

    p1 = buddy_alloc_pages(1024);
ffffffffc0200fe0:	40000513          	li	a0,1024
ffffffffc0200fe4:	c31ff0ef          	jal	ra,ffffffffc0200c14 <buddy_alloc_pages>
    for (int i = 0; i < num_buddy_zone; i++) {
ffffffffc0200fe8:	4010                	lw	a2,0(s0)
    p1 = buddy_alloc_pages(1024);
ffffffffc0200fea:	89aa                	mv	s3,a0
    for (int i = 0; i < num_buddy_zone; i++) {
ffffffffc0200fec:	20c05063          	blez	a2,ffffffffc02011ec <buddy_check+0x49c>
ffffffffc0200ff0:	367d                	addiw	a2,a2,-1
ffffffffc0200ff2:	02061793          	slli	a5,a2,0x20
ffffffffc0200ff6:	9381                	srli	a5,a5,0x20
ffffffffc0200ff8:	00179613          	slli	a2,a5,0x1
ffffffffc0200ffc:	963e                	add	a2,a2,a5
ffffffffc0200ffe:	00005717          	auipc	a4,0x5
ffffffffc0201002:	06270713          	addi	a4,a4,98 # ffffffffc0206060 <mem_buddy+0x50>
ffffffffc0201006:	0612                	slli	a2,a2,0x4
ffffffffc0201008:	963a                	add	a2,a2,a4
ffffffffc020100a:	00005797          	auipc	a5,0x5
ffffffffc020100e:	02678793          	addi	a5,a5,38 # ffffffffc0206030 <mem_buddy+0x20>
    size_t total_free_pages = 0;
ffffffffc0201012:	4701                	li	a4,0
        total_free_pages += mem_buddy[i].free_size;
ffffffffc0201014:	6394                	ld	a3,0(a5)
    for (int i = 0; i < num_buddy_zone; i++) {
ffffffffc0201016:	03078793          	addi	a5,a5,48
        total_free_pages += mem_buddy[i].free_size;
ffffffffc020101a:	9736                	add	a4,a4,a3
    for (int i = 0; i < num_buddy_zone; i++) {
ffffffffc020101c:	fec79ce3          	bne	a5,a2,ffffffffc0201014 <buddy_check+0x2c4>
    // debug_buddy_tree(7, "225, alloc 1024");
    assert(buddy_nr_free_pages() == total - 512 - 1024);
ffffffffc0201020:	a0048793          	addi	a5,s1,-1536
ffffffffc0201024:	28e79063          	bne	a5,a4,ffffffffc02012a4 <buddy_check+0x554>

    struct Page *p2 = buddy_alloc_pages(2048);
ffffffffc0201028:	6505                	lui	a0,0x1
ffffffffc020102a:	80050513          	addi	a0,a0,-2048 # 800 <kern_entry-0xffffffffc01ff800>
ffffffffc020102e:	be7ff0ef          	jal	ra,ffffffffc0200c14 <buddy_alloc_pages>
    for (int i = 0; i < num_buddy_zone; i++) {
ffffffffc0201032:	4010                	lw	a2,0(s0)
    struct Page *p2 = buddy_alloc_pages(2048);
ffffffffc0201034:	8a2a                	mv	s4,a0
    for (int i = 0; i < num_buddy_zone; i++) {
ffffffffc0201036:	1ac05d63          	blez	a2,ffffffffc02011f0 <buddy_check+0x4a0>
ffffffffc020103a:	367d                	addiw	a2,a2,-1
ffffffffc020103c:	02061793          	slli	a5,a2,0x20
ffffffffc0201040:	9381                	srli	a5,a5,0x20
ffffffffc0201042:	00179613          	slli	a2,a5,0x1
ffffffffc0201046:	963e                	add	a2,a2,a5
ffffffffc0201048:	00005717          	auipc	a4,0x5
ffffffffc020104c:	01870713          	addi	a4,a4,24 # ffffffffc0206060 <mem_buddy+0x50>
ffffffffc0201050:	0612                	slli	a2,a2,0x4
ffffffffc0201052:	963a                	add	a2,a2,a4
ffffffffc0201054:	00005797          	auipc	a5,0x5
ffffffffc0201058:	fdc78793          	addi	a5,a5,-36 # ffffffffc0206030 <mem_buddy+0x20>
    size_t total_free_pages = 0;
ffffffffc020105c:	4701                	li	a4,0
        total_free_pages += mem_buddy[i].free_size;
ffffffffc020105e:	6394                	ld	a3,0(a5)
    for (int i = 0; i < num_buddy_zone; i++) {
ffffffffc0201060:	03078793          	addi	a5,a5,48
        total_free_pages += mem_buddy[i].free_size;
ffffffffc0201064:	9736                	add	a4,a4,a3
    for (int i = 0; i < num_buddy_zone; i++) {
ffffffffc0201066:	fec79ce3          	bne	a5,a2,ffffffffc020105e <buddy_check+0x30e>
    // debug_buddy_tree(7, "229, alloc 2048");
    assert(buddy_nr_free_pages() == total - 512 - 1024 - 2048);
ffffffffc020106a:	77fd                	lui	a5,0xfffff
ffffffffc020106c:	20078793          	addi	a5,a5,512 # fffffffffffff200 <end+0x3fdf8bc8>
ffffffffc0201070:	97a6                	add	a5,a5,s1
ffffffffc0201072:	30e79963          	bne	a5,a4,ffffffffc0201384 <buddy_check+0x634>

    struct Page *p3 = buddy_alloc_pages(4096);
ffffffffc0201076:	6505                	lui	a0,0x1
ffffffffc0201078:	b9dff0ef          	jal	ra,ffffffffc0200c14 <buddy_alloc_pages>
    for (int i = 0; i < num_buddy_zone; i++) {
ffffffffc020107c:	4010                	lw	a2,0(s0)
    struct Page *p3 = buddy_alloc_pages(4096);
ffffffffc020107e:	8aaa                	mv	s5,a0
    for (int i = 0; i < num_buddy_zone; i++) {
ffffffffc0201080:	16c05a63          	blez	a2,ffffffffc02011f4 <buddy_check+0x4a4>
ffffffffc0201084:	367d                	addiw	a2,a2,-1
ffffffffc0201086:	02061793          	slli	a5,a2,0x20
ffffffffc020108a:	9381                	srli	a5,a5,0x20
ffffffffc020108c:	00179613          	slli	a2,a5,0x1
ffffffffc0201090:	963e                	add	a2,a2,a5
ffffffffc0201092:	00005717          	auipc	a4,0x5
ffffffffc0201096:	fce70713          	addi	a4,a4,-50 # ffffffffc0206060 <mem_buddy+0x50>
ffffffffc020109a:	0612                	slli	a2,a2,0x4
ffffffffc020109c:	963a                	add	a2,a2,a4
ffffffffc020109e:	00005797          	auipc	a5,0x5
ffffffffc02010a2:	f9278793          	addi	a5,a5,-110 # ffffffffc0206030 <mem_buddy+0x20>
    size_t total_free_pages = 0;
ffffffffc02010a6:	4701                	li	a4,0
        total_free_pages += mem_buddy[i].free_size;
ffffffffc02010a8:	6394                	ld	a3,0(a5)
    for (int i = 0; i < num_buddy_zone; i++) {
ffffffffc02010aa:	03078793          	addi	a5,a5,48
        total_free_pages += mem_buddy[i].free_size;
ffffffffc02010ae:	9736                	add	a4,a4,a3
    for (int i = 0; i < num_buddy_zone; i++) {
ffffffffc02010b0:	fef61ce3          	bne	a2,a5,ffffffffc02010a8 <buddy_check+0x358>
    // debug_buddy_tree(7, "233, alloc 4096");
    assert(buddy_nr_free_pages() == total - 512 - 1024 - 2048 - 4096);
ffffffffc02010b4:	77f9                	lui	a5,0xffffe
ffffffffc02010b6:	20078793          	addi	a5,a5,512 # ffffffffffffe200 <end+0x3fdf7bc8>
ffffffffc02010ba:	97a6                	add	a5,a5,s1
ffffffffc02010bc:	2ae79463          	bne	a5,a4,ffffffffc0201364 <buddy_check+0x614>

    struct Page *p4 = buddy_alloc_pages(8192);
ffffffffc02010c0:	6509                	lui	a0,0x2
ffffffffc02010c2:	b53ff0ef          	jal	ra,ffffffffc0200c14 <buddy_alloc_pages>
    for (int i = 0; i < num_buddy_zone; i++) {
ffffffffc02010c6:	4010                	lw	a2,0(s0)
    struct Page *p4 = buddy_alloc_pages(8192);
ffffffffc02010c8:	8b2a                	mv	s6,a0
    for (int i = 0; i < num_buddy_zone; i++) {
ffffffffc02010ca:	12c05963          	blez	a2,ffffffffc02011fc <buddy_check+0x4ac>
ffffffffc02010ce:	367d                	addiw	a2,a2,-1
ffffffffc02010d0:	02061793          	slli	a5,a2,0x20
ffffffffc02010d4:	9381                	srli	a5,a5,0x20
ffffffffc02010d6:	00179613          	slli	a2,a5,0x1
ffffffffc02010da:	963e                	add	a2,a2,a5
ffffffffc02010dc:	00005717          	auipc	a4,0x5
ffffffffc02010e0:	f8470713          	addi	a4,a4,-124 # ffffffffc0206060 <mem_buddy+0x50>
ffffffffc02010e4:	0612                	slli	a2,a2,0x4
ffffffffc02010e6:	963a                	add	a2,a2,a4
ffffffffc02010e8:	00005797          	auipc	a5,0x5
ffffffffc02010ec:	f4878793          	addi	a5,a5,-184 # ffffffffc0206030 <mem_buddy+0x20>
    size_t total_free_pages = 0;
ffffffffc02010f0:	4701                	li	a4,0
        total_free_pages += mem_buddy[i].free_size;
ffffffffc02010f2:	6394                	ld	a3,0(a5)
    for (int i = 0; i < num_buddy_zone; i++) {
ffffffffc02010f4:	03078793          	addi	a5,a5,48
        total_free_pages += mem_buddy[i].free_size;
ffffffffc02010f8:	9736                	add	a4,a4,a3
    for (int i = 0; i < num_buddy_zone; i++) {
ffffffffc02010fa:	fec79ce3          	bne	a5,a2,ffffffffc02010f2 <buddy_check+0x3a2>
    // debug_buddy_tree(7, "237, alloc 8192");
    assert(buddy_nr_free_pages() == total - 512 - 1024 - 2048 - 4096 - 8192);
ffffffffc02010fe:	77f1                	lui	a5,0xffffc
ffffffffc0201100:	20078793          	addi	a5,a5,512 # ffffffffffffc200 <end+0x3fdf5bc8>
ffffffffc0201104:	97a6                	add	a5,a5,s1
ffffffffc0201106:	16e79f63          	bne	a5,a4,ffffffffc0201284 <buddy_check+0x534>

    struct Page *p5 = buddy_alloc_pages(8192);
ffffffffc020110a:	6509                	lui	a0,0x2
ffffffffc020110c:	b09ff0ef          	jal	ra,ffffffffc0200c14 <buddy_alloc_pages>
    for (int i = 0; i < num_buddy_zone; i++) {
ffffffffc0201110:	4010                	lw	a2,0(s0)
    struct Page *p5 = buddy_alloc_pages(8192);
ffffffffc0201112:	8baa                	mv	s7,a0
    for (int i = 0; i < num_buddy_zone; i++) {
ffffffffc0201114:	0ec05663          	blez	a2,ffffffffc0201200 <buddy_check+0x4b0>
ffffffffc0201118:	367d                	addiw	a2,a2,-1
ffffffffc020111a:	02061793          	slli	a5,a2,0x20
ffffffffc020111e:	9381                	srli	a5,a5,0x20
ffffffffc0201120:	00179613          	slli	a2,a5,0x1
ffffffffc0201124:	963e                	add	a2,a2,a5
ffffffffc0201126:	00005717          	auipc	a4,0x5
ffffffffc020112a:	f3a70713          	addi	a4,a4,-198 # ffffffffc0206060 <mem_buddy+0x50>
ffffffffc020112e:	0612                	slli	a2,a2,0x4
ffffffffc0201130:	963a                	add	a2,a2,a4
ffffffffc0201132:	00005797          	auipc	a5,0x5
ffffffffc0201136:	efe78793          	addi	a5,a5,-258 # ffffffffc0206030 <mem_buddy+0x20>
    size_t total_free_pages = 0;
ffffffffc020113a:	4701                	li	a4,0
        total_free_pages += mem_buddy[i].free_size;
ffffffffc020113c:	6394                	ld	a3,0(a5)
    for (int i = 0; i < num_buddy_zone; i++) {
ffffffffc020113e:	03078793          	addi	a5,a5,48
        total_free_pages += mem_buddy[i].free_size;
ffffffffc0201142:	9736                	add	a4,a4,a3
    for (int i = 0; i < num_buddy_zone; i++) {
ffffffffc0201144:	fec79ce3          	bne	a5,a2,ffffffffc020113c <buddy_check+0x3ec>
    // debug_buddy_tree(7, "241, alloc 8192");
    assert(buddy_nr_free_pages() == total - 512 - 1024 - 2048 - 4096 - 8192 - 8192);
ffffffffc0201148:	77e9                	lui	a5,0xffffa
ffffffffc020114a:	20078793          	addi	a5,a5,512 # ffffffffffffa200 <end+0x3fdf3bc8>
ffffffffc020114e:	97a6                	add	a5,a5,s1
ffffffffc0201150:	10e79a63          	bne	a5,a4,ffffffffc0201264 <buddy_check+0x514>

    buddy_free_pages(p0, -1);
ffffffffc0201154:	55fd                	li	a1,-1
ffffffffc0201156:	854a                	mv	a0,s2
ffffffffc0201158:	ef6ff0ef          	jal	ra,ffffffffc020084e <buddy_free_pages>
    buddy_free_pages(p1, -1);
ffffffffc020115c:	55fd                	li	a1,-1
ffffffffc020115e:	854e                	mv	a0,s3
ffffffffc0201160:	eeeff0ef          	jal	ra,ffffffffc020084e <buddy_free_pages>
    buddy_free_pages(p2, -1);
ffffffffc0201164:	55fd                	li	a1,-1
ffffffffc0201166:	8552                	mv	a0,s4
ffffffffc0201168:	ee6ff0ef          	jal	ra,ffffffffc020084e <buddy_free_pages>
    buddy_free_pages(p3, -1);
ffffffffc020116c:	55fd                	li	a1,-1
ffffffffc020116e:	8556                	mv	a0,s5
ffffffffc0201170:	edeff0ef          	jal	ra,ffffffffc020084e <buddy_free_pages>
    buddy_free_pages(p4, -1);
ffffffffc0201174:	55fd                	li	a1,-1
ffffffffc0201176:	855a                	mv	a0,s6
ffffffffc0201178:	ed6ff0ef          	jal	ra,ffffffffc020084e <buddy_free_pages>
    buddy_free_pages(p5, -1);
ffffffffc020117c:	55fd                	li	a1,-1
ffffffffc020117e:	855e                	mv	a0,s7
ffffffffc0201180:	eceff0ef          	jal	ra,ffffffffc020084e <buddy_free_pages>
    for (int i = 0; i < num_buddy_zone; i++) {
ffffffffc0201184:	4010                	lw	a2,0(s0)
ffffffffc0201186:	06c05963          	blez	a2,ffffffffc02011f8 <buddy_check+0x4a8>
ffffffffc020118a:	367d                	addiw	a2,a2,-1
ffffffffc020118c:	02061793          	slli	a5,a2,0x20
ffffffffc0201190:	9381                	srli	a5,a5,0x20
ffffffffc0201192:	00179613          	slli	a2,a5,0x1
ffffffffc0201196:	963e                	add	a2,a2,a5
ffffffffc0201198:	00005717          	auipc	a4,0x5
ffffffffc020119c:	ec870713          	addi	a4,a4,-312 # ffffffffc0206060 <mem_buddy+0x50>
ffffffffc02011a0:	0612                	slli	a2,a2,0x4
ffffffffc02011a2:	963a                	add	a2,a2,a4
ffffffffc02011a4:	00005797          	auipc	a5,0x5
ffffffffc02011a8:	e8c78793          	addi	a5,a5,-372 # ffffffffc0206030 <mem_buddy+0x20>
    size_t total_free_pages = 0;
ffffffffc02011ac:	4701                	li	a4,0
        total_free_pages += mem_buddy[i].free_size;
ffffffffc02011ae:	6394                	ld	a3,0(a5)
    for (int i = 0; i < num_buddy_zone; i++) {
ffffffffc02011b0:	03078793          	addi	a5,a5,48
        total_free_pages += mem_buddy[i].free_size;
ffffffffc02011b4:	9736                	add	a4,a4,a3
    for (int i = 0; i < num_buddy_zone; i++) {
ffffffffc02011b6:	fef61ce3          	bne	a2,a5,ffffffffc02011ae <buddy_check+0x45e>

    assert(buddy_nr_free_pages() == total);
ffffffffc02011ba:	04e49563          	bne	s1,a4,ffffffffc0201204 <buddy_check+0x4b4>

}
ffffffffc02011be:	60a6                	ld	ra,72(sp)
ffffffffc02011c0:	6406                	ld	s0,64(sp)
ffffffffc02011c2:	74e2                	ld	s1,56(sp)
ffffffffc02011c4:	7942                	ld	s2,48(sp)
ffffffffc02011c6:	79a2                	ld	s3,40(sp)
ffffffffc02011c8:	7a02                	ld	s4,32(sp)
ffffffffc02011ca:	6ae2                	ld	s5,24(sp)
ffffffffc02011cc:	6b42                	ld	s6,16(sp)
ffffffffc02011ce:	6ba2                	ld	s7,8(sp)
ffffffffc02011d0:	6161                	addi	sp,sp,80
ffffffffc02011d2:	8082                	ret
    size_t total_free_pages = 0;
ffffffffc02011d4:	4481                	li	s1,0
ffffffffc02011d6:	b6f1                	j	ffffffffc0200da2 <buddy_check+0x52>
ffffffffc02011d8:	4701                	li	a4,0
ffffffffc02011da:	b9e1                	j	ffffffffc0200eb2 <buddy_check+0x162>
ffffffffc02011dc:	4701                	li	a4,0
ffffffffc02011de:	bb19                	j	ffffffffc0200ef4 <buddy_check+0x1a4>
ffffffffc02011e0:	4701                	li	a4,0
ffffffffc02011e2:	bba9                	j	ffffffffc0200f3c <buddy_check+0x1ec>
ffffffffc02011e4:	4701                	li	a4,0
ffffffffc02011e6:	b355                	j	ffffffffc0200f8a <buddy_check+0x23a>
ffffffffc02011e8:	4701                	li	a4,0
ffffffffc02011ea:	b3fd                	j	ffffffffc0200fd8 <buddy_check+0x288>
ffffffffc02011ec:	4701                	li	a4,0
ffffffffc02011ee:	bd0d                	j	ffffffffc0201020 <buddy_check+0x2d0>
ffffffffc02011f0:	4701                	li	a4,0
ffffffffc02011f2:	bda5                	j	ffffffffc020106a <buddy_check+0x31a>
ffffffffc02011f4:	4701                	li	a4,0
ffffffffc02011f6:	bd7d                	j	ffffffffc02010b4 <buddy_check+0x364>
ffffffffc02011f8:	4701                	li	a4,0
ffffffffc02011fa:	b7c1                	j	ffffffffc02011ba <buddy_check+0x46a>
ffffffffc02011fc:	4701                	li	a4,0
ffffffffc02011fe:	b701                	j	ffffffffc02010fe <buddy_check+0x3ae>
ffffffffc0201200:	4701                	li	a4,0
ffffffffc0201202:	b799                	j	ffffffffc0201148 <buddy_check+0x3f8>
    assert(buddy_nr_free_pages() == total);
ffffffffc0201204:	00001697          	auipc	a3,0x1
ffffffffc0201208:	2fc68693          	addi	a3,a3,764 # ffffffffc0202500 <commands+0x828>
ffffffffc020120c:	00001617          	auipc	a2,0x1
ffffffffc0201210:	12460613          	addi	a2,a2,292 # ffffffffc0202330 <commands+0x658>
ffffffffc0201214:	0f600593          	li	a1,246
ffffffffc0201218:	00001517          	auipc	a0,0x1
ffffffffc020121c:	13050513          	addi	a0,a0,304 # ffffffffc0202348 <commands+0x670>
ffffffffc0201220:	988ff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(buddy_nr_free_pages() == total - 144);
ffffffffc0201224:	00001697          	auipc	a3,0x1
ffffffffc0201228:	32468693          	addi	a3,a3,804 # ffffffffc0202548 <commands+0x870>
ffffffffc020122c:	00001617          	auipc	a2,0x1
ffffffffc0201230:	10460613          	addi	a2,a2,260 # ffffffffc0202330 <commands+0x658>
ffffffffc0201234:	0cd00593          	li	a1,205
ffffffffc0201238:	00001517          	auipc	a0,0x1
ffffffffc020123c:	11050513          	addi	a0,a0,272 # ffffffffc0202348 <commands+0x670>
ffffffffc0201240:	968ff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(buddy_nr_free_pages() == total - 16);
ffffffffc0201244:	00001697          	auipc	a3,0x1
ffffffffc0201248:	2dc68693          	addi	a3,a3,732 # ffffffffc0202520 <commands+0x848>
ffffffffc020124c:	00001617          	auipc	a2,0x1
ffffffffc0201250:	0e460613          	addi	a2,a2,228 # ffffffffc0202330 <commands+0x658>
ffffffffc0201254:	0ca00593          	li	a1,202
ffffffffc0201258:	00001517          	auipc	a0,0x1
ffffffffc020125c:	0f050513          	addi	a0,a0,240 # ffffffffc0202348 <commands+0x670>
ffffffffc0201260:	948ff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(buddy_nr_free_pages() == total - 512 - 1024 - 2048 - 4096 - 8192 - 8192);
ffffffffc0201264:	00001697          	auipc	a3,0x1
ffffffffc0201268:	43468693          	addi	a3,a3,1076 # ffffffffc0202698 <commands+0x9c0>
ffffffffc020126c:	00001617          	auipc	a2,0x1
ffffffffc0201270:	0c460613          	addi	a2,a2,196 # ffffffffc0202330 <commands+0x658>
ffffffffc0201274:	0ed00593          	li	a1,237
ffffffffc0201278:	00001517          	auipc	a0,0x1
ffffffffc020127c:	0d050513          	addi	a0,a0,208 # ffffffffc0202348 <commands+0x670>
ffffffffc0201280:	928ff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(buddy_nr_free_pages() == total - 512 - 1024 - 2048 - 4096 - 8192);
ffffffffc0201284:	00001697          	auipc	a3,0x1
ffffffffc0201288:	3cc68693          	addi	a3,a3,972 # ffffffffc0202650 <commands+0x978>
ffffffffc020128c:	00001617          	auipc	a2,0x1
ffffffffc0201290:	0a460613          	addi	a2,a2,164 # ffffffffc0202330 <commands+0x658>
ffffffffc0201294:	0e900593          	li	a1,233
ffffffffc0201298:	00001517          	auipc	a0,0x1
ffffffffc020129c:	0b050513          	addi	a0,a0,176 # ffffffffc0202348 <commands+0x670>
ffffffffc02012a0:	908ff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(buddy_nr_free_pages() == total - 512 - 1024);
ffffffffc02012a4:	00001697          	auipc	a3,0x1
ffffffffc02012a8:	30468693          	addi	a3,a3,772 # ffffffffc02025a8 <commands+0x8d0>
ffffffffc02012ac:	00001617          	auipc	a2,0x1
ffffffffc02012b0:	08460613          	addi	a2,a2,132 # ffffffffc0202330 <commands+0x658>
ffffffffc02012b4:	0dd00593          	li	a1,221
ffffffffc02012b8:	00001517          	auipc	a0,0x1
ffffffffc02012bc:	09050513          	addi	a0,a0,144 # ffffffffc0202348 <commands+0x670>
ffffffffc02012c0:	8e8ff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(buddy_nr_free_pages() == total - 512);
ffffffffc02012c4:	00001697          	auipc	a3,0x1
ffffffffc02012c8:	2bc68693          	addi	a3,a3,700 # ffffffffc0202580 <commands+0x8a8>
ffffffffc02012cc:	00001617          	auipc	a2,0x1
ffffffffc02012d0:	06460613          	addi	a2,a2,100 # ffffffffc0202330 <commands+0x658>
ffffffffc02012d4:	0d900593          	li	a1,217
ffffffffc02012d8:	00001517          	auipc	a0,0x1
ffffffffc02012dc:	07050513          	addi	a0,a0,112 # ffffffffc0202348 <commands+0x670>
ffffffffc02012e0:	8c8ff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(buddy_nr_free_pages() == total);
ffffffffc02012e4:	00001697          	auipc	a3,0x1
ffffffffc02012e8:	21c68693          	addi	a3,a3,540 # ffffffffc0202500 <commands+0x828>
ffffffffc02012ec:	00001617          	auipc	a2,0x1
ffffffffc02012f0:	04460613          	addi	a2,a2,68 # ffffffffc0202330 <commands+0x658>
ffffffffc02012f4:	0c700593          	li	a1,199
ffffffffc02012f8:	00001517          	auipc	a0,0x1
ffffffffc02012fc:	05050513          	addi	a0,a0,80 # ffffffffc0202348 <commands+0x670>
ffffffffc0201300:	8a8ff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(p1 == p0 + 1);
ffffffffc0201304:	00001697          	auipc	a3,0x1
ffffffffc0201308:	1ec68693          	addi	a3,a3,492 # ffffffffc02024f0 <commands+0x818>
ffffffffc020130c:	00001617          	auipc	a2,0x1
ffffffffc0201310:	02460613          	addi	a2,a2,36 # ffffffffc0202330 <commands+0x658>
ffffffffc0201314:	0c300593          	li	a1,195
ffffffffc0201318:	00001517          	auipc	a0,0x1
ffffffffc020131c:	03050513          	addi	a0,a0,48 # ffffffffc0202348 <commands+0x670>
ffffffffc0201320:	888ff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(p0 == NULL);
ffffffffc0201324:	00001697          	auipc	a3,0x1
ffffffffc0201328:	24c68693          	addi	a3,a3,588 # ffffffffc0202570 <commands+0x898>
ffffffffc020132c:	00001617          	auipc	a2,0x1
ffffffffc0201330:	00460613          	addi	a2,a2,4 # ffffffffc0202330 <commands+0x658>
ffffffffc0201334:	0d400593          	li	a1,212
ffffffffc0201338:	00001517          	auipc	a0,0x1
ffffffffc020133c:	01050513          	addi	a0,a0,16 # ffffffffc0202348 <commands+0x670>
ffffffffc0201340:	868ff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(buddy_nr_free_pages() == total);
ffffffffc0201344:	00001697          	auipc	a3,0x1
ffffffffc0201348:	1bc68693          	addi	a3,a3,444 # ffffffffc0202500 <commands+0x828>
ffffffffc020134c:	00001617          	auipc	a2,0x1
ffffffffc0201350:	fe460613          	addi	a2,a2,-28 # ffffffffc0202330 <commands+0x658>
ffffffffc0201354:	0d100593          	li	a1,209
ffffffffc0201358:	00001517          	auipc	a0,0x1
ffffffffc020135c:	ff050513          	addi	a0,a0,-16 # ffffffffc0202348 <commands+0x670>
ffffffffc0201360:	848ff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(buddy_nr_free_pages() == total - 512 - 1024 - 2048 - 4096);
ffffffffc0201364:	00001697          	auipc	a3,0x1
ffffffffc0201368:	2ac68693          	addi	a3,a3,684 # ffffffffc0202610 <commands+0x938>
ffffffffc020136c:	00001617          	auipc	a2,0x1
ffffffffc0201370:	fc460613          	addi	a2,a2,-60 # ffffffffc0202330 <commands+0x658>
ffffffffc0201374:	0e500593          	li	a1,229
ffffffffc0201378:	00001517          	auipc	a0,0x1
ffffffffc020137c:	fd050513          	addi	a0,a0,-48 # ffffffffc0202348 <commands+0x670>
ffffffffc0201380:	828ff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(buddy_nr_free_pages() == total - 512 - 1024 - 2048);
ffffffffc0201384:	00001697          	auipc	a3,0x1
ffffffffc0201388:	25468693          	addi	a3,a3,596 # ffffffffc02025d8 <commands+0x900>
ffffffffc020138c:	00001617          	auipc	a2,0x1
ffffffffc0201390:	fa460613          	addi	a2,a2,-92 # ffffffffc0202330 <commands+0x658>
ffffffffc0201394:	0e100593          	li	a1,225
ffffffffc0201398:	00001517          	auipc	a0,0x1
ffffffffc020139c:	fb050513          	addi	a0,a0,-80 # ffffffffc0202348 <commands+0x670>
ffffffffc02013a0:	808ff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(p1 == mem_buddy[0].begin_page + 1);
ffffffffc02013a4:	00001697          	auipc	a3,0x1
ffffffffc02013a8:	12468693          	addi	a3,a3,292 # ffffffffc02024c8 <commands+0x7f0>
ffffffffc02013ac:	00001617          	auipc	a2,0x1
ffffffffc02013b0:	f8460613          	addi	a2,a2,-124 # ffffffffc0202330 <commands+0x658>
ffffffffc02013b4:	0c100593          	li	a1,193
ffffffffc02013b8:	00001517          	auipc	a0,0x1
ffffffffc02013bc:	f9050513          	addi	a0,a0,-112 # ffffffffc0202348 <commands+0x670>
ffffffffc02013c0:	fe9fe0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(buddy_nr_free_pages() == total - 2);
ffffffffc02013c4:	00001697          	auipc	a3,0x1
ffffffffc02013c8:	0dc68693          	addi	a3,a3,220 # ffffffffc02024a0 <commands+0x7c8>
ffffffffc02013cc:	00001617          	auipc	a2,0x1
ffffffffc02013d0:	f6460613          	addi	a2,a2,-156 # ffffffffc0202330 <commands+0x658>
ffffffffc02013d4:	0c000593          	li	a1,192
ffffffffc02013d8:	00001517          	auipc	a0,0x1
ffffffffc02013dc:	f7050513          	addi	a0,a0,-144 # ffffffffc0202348 <commands+0x670>
ffffffffc02013e0:	fc9fe0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(p1 != NULL);
ffffffffc02013e4:	00001697          	auipc	a3,0x1
ffffffffc02013e8:	0ac68693          	addi	a3,a3,172 # ffffffffc0202490 <commands+0x7b8>
ffffffffc02013ec:	00001617          	auipc	a2,0x1
ffffffffc02013f0:	f4460613          	addi	a2,a2,-188 # ffffffffc0202330 <commands+0x658>
ffffffffc02013f4:	0bf00593          	li	a1,191
ffffffffc02013f8:	00001517          	auipc	a0,0x1
ffffffffc02013fc:	f5050513          	addi	a0,a0,-176 # ffffffffc0202348 <commands+0x670>
ffffffffc0201400:	fa9fe0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(p0 == mem_buddy[0].begin_page);
ffffffffc0201404:	00001697          	auipc	a3,0x1
ffffffffc0201408:	06c68693          	addi	a3,a3,108 # ffffffffc0202470 <commands+0x798>
ffffffffc020140c:	00001617          	auipc	a2,0x1
ffffffffc0201410:	f2460613          	addi	a2,a2,-220 # ffffffffc0202330 <commands+0x658>
ffffffffc0201414:	0bc00593          	li	a1,188
ffffffffc0201418:	00001517          	auipc	a0,0x1
ffffffffc020141c:	f3050513          	addi	a0,a0,-208 # ffffffffc0202348 <commands+0x670>
ffffffffc0201420:	f89fe0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(buddy_nr_free_pages() == total - 1);
ffffffffc0201424:	00001697          	auipc	a3,0x1
ffffffffc0201428:	02468693          	addi	a3,a3,36 # ffffffffc0202448 <commands+0x770>
ffffffffc020142c:	00001617          	auipc	a2,0x1
ffffffffc0201430:	f0460613          	addi	a2,a2,-252 # ffffffffc0202330 <commands+0x658>
ffffffffc0201434:	0bb00593          	li	a1,187
ffffffffc0201438:	00001517          	auipc	a0,0x1
ffffffffc020143c:	f1050513          	addi	a0,a0,-240 # ffffffffc0202348 <commands+0x670>
ffffffffc0201440:	f69fe0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(p0 != NULL);
ffffffffc0201444:	00001697          	auipc	a3,0x1
ffffffffc0201448:	ff468693          	addi	a3,a3,-12 # ffffffffc0202438 <commands+0x760>
ffffffffc020144c:	00001617          	auipc	a2,0x1
ffffffffc0201450:	ee460613          	addi	a2,a2,-284 # ffffffffc0202330 <commands+0x658>
ffffffffc0201454:	0ba00593          	li	a1,186
ffffffffc0201458:	00001517          	auipc	a0,0x1
ffffffffc020145c:	ef050513          	addi	a0,a0,-272 # ffffffffc0202348 <commands+0x670>
ffffffffc0201460:	f49fe0ef          	jal	ra,ffffffffc02003a8 <__panic>

ffffffffc0201464 <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201464:	100027f3          	csrr	a5,sstatus
ffffffffc0201468:	8b89                	andi	a5,a5,2
ffffffffc020146a:	e799                	bnez	a5,ffffffffc0201478 <alloc_pages+0x14>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc020146c:	00005797          	auipc	a5,0x5
ffffffffc0201470:	19c7b783          	ld	a5,412(a5) # ffffffffc0206608 <pmm_manager>
ffffffffc0201474:	6f9c                	ld	a5,24(a5)
ffffffffc0201476:	8782                	jr	a5
struct Page *alloc_pages(size_t n) {
ffffffffc0201478:	1141                	addi	sp,sp,-16
ffffffffc020147a:	e406                	sd	ra,8(sp)
ffffffffc020147c:	e022                	sd	s0,0(sp)
ffffffffc020147e:	842a                	mv	s0,a0
        intr_disable();
ffffffffc0201480:	fdffe0ef          	jal	ra,ffffffffc020045e <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0201484:	00005797          	auipc	a5,0x5
ffffffffc0201488:	1847b783          	ld	a5,388(a5) # ffffffffc0206608 <pmm_manager>
ffffffffc020148c:	6f9c                	ld	a5,24(a5)
ffffffffc020148e:	8522                	mv	a0,s0
ffffffffc0201490:	9782                	jalr	a5
ffffffffc0201492:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc0201494:	fc5fe0ef          	jal	ra,ffffffffc0200458 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc0201498:	60a2                	ld	ra,8(sp)
ffffffffc020149a:	8522                	mv	a0,s0
ffffffffc020149c:	6402                	ld	s0,0(sp)
ffffffffc020149e:	0141                	addi	sp,sp,16
ffffffffc02014a0:	8082                	ret

ffffffffc02014a2 <pmm_init>:
    pmm_manager = &buddy_pmm_manager;
ffffffffc02014a2:	00001797          	auipc	a5,0x1
ffffffffc02014a6:	25678793          	addi	a5,a5,598 # ffffffffc02026f8 <buddy_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02014aa:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc02014ac:	1101                	addi	sp,sp,-32
ffffffffc02014ae:	e426                	sd	s1,8(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02014b0:	00001517          	auipc	a0,0x1
ffffffffc02014b4:	28050513          	addi	a0,a0,640 # ffffffffc0202730 <buddy_pmm_manager+0x38>
    pmm_manager = &buddy_pmm_manager;
ffffffffc02014b8:	00005497          	auipc	s1,0x5
ffffffffc02014bc:	15048493          	addi	s1,s1,336 # ffffffffc0206608 <pmm_manager>
void pmm_init(void) {
ffffffffc02014c0:	ec06                	sd	ra,24(sp)
ffffffffc02014c2:	e822                	sd	s0,16(sp)
    pmm_manager = &buddy_pmm_manager;
ffffffffc02014c4:	e09c                	sd	a5,0(s1)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02014c6:	bf1fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pmm_manager->init();
ffffffffc02014ca:	609c                	ld	a5,0(s1)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02014cc:	00005417          	auipc	s0,0x5
ffffffffc02014d0:	15440413          	addi	s0,s0,340 # ffffffffc0206620 <va_pa_offset>
    pmm_manager->init();
ffffffffc02014d4:	679c                	ld	a5,8(a5)
ffffffffc02014d6:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02014d8:	57f5                	li	a5,-3
ffffffffc02014da:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc02014dc:	00001517          	auipc	a0,0x1
ffffffffc02014e0:	26c50513          	addi	a0,a0,620 # ffffffffc0202748 <buddy_pmm_manager+0x50>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02014e4:	e01c                	sd	a5,0(s0)
    cprintf("physcial memory map:\n");
ffffffffc02014e6:	bd1fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc02014ea:	46c5                	li	a3,17
ffffffffc02014ec:	06ee                	slli	a3,a3,0x1b
ffffffffc02014ee:	40100613          	li	a2,1025
ffffffffc02014f2:	16fd                	addi	a3,a3,-1
ffffffffc02014f4:	07e005b7          	lui	a1,0x7e00
ffffffffc02014f8:	0656                	slli	a2,a2,0x15
ffffffffc02014fa:	00001517          	auipc	a0,0x1
ffffffffc02014fe:	26650513          	addi	a0,a0,614 # ffffffffc0202760 <buddy_pmm_manager+0x68>
ffffffffc0201502:	bb5fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201506:	777d                	lui	a4,0xfffff
ffffffffc0201508:	00006797          	auipc	a5,0x6
ffffffffc020150c:	12f78793          	addi	a5,a5,303 # ffffffffc0207637 <end+0xfff>
ffffffffc0201510:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0201512:	00005517          	auipc	a0,0x5
ffffffffc0201516:	0e650513          	addi	a0,a0,230 # ffffffffc02065f8 <npage>
ffffffffc020151a:	00088737          	lui	a4,0x88
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020151e:	00005597          	auipc	a1,0x5
ffffffffc0201522:	0e258593          	addi	a1,a1,226 # ffffffffc0206600 <pages>
    npage = maxpa / PGSIZE;
ffffffffc0201526:	e118                	sd	a4,0(a0)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201528:	e19c                	sd	a5,0(a1)
ffffffffc020152a:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020152c:	4701                	li	a4,0
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020152e:	4885                	li	a7,1
ffffffffc0201530:	fff80837          	lui	a6,0xfff80
ffffffffc0201534:	a011                	j	ffffffffc0201538 <pmm_init+0x96>
        SetPageReserved(pages + i);
ffffffffc0201536:	619c                	ld	a5,0(a1)
ffffffffc0201538:	97b6                	add	a5,a5,a3
ffffffffc020153a:	07a1                	addi	a5,a5,8
ffffffffc020153c:	4117b02f          	amoor.d	zero,a7,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201540:	611c                	ld	a5,0(a0)
ffffffffc0201542:	0705                	addi	a4,a4,1
ffffffffc0201544:	02868693          	addi	a3,a3,40
ffffffffc0201548:	01078633          	add	a2,a5,a6
ffffffffc020154c:	fec765e3          	bltu	a4,a2,ffffffffc0201536 <pmm_init+0x94>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201550:	6190                	ld	a2,0(a1)
ffffffffc0201552:	00279713          	slli	a4,a5,0x2
ffffffffc0201556:	973e                	add	a4,a4,a5
ffffffffc0201558:	fec006b7          	lui	a3,0xfec00
ffffffffc020155c:	070e                	slli	a4,a4,0x3
ffffffffc020155e:	96b2                	add	a3,a3,a2
ffffffffc0201560:	96ba                	add	a3,a3,a4
ffffffffc0201562:	c0200737          	lui	a4,0xc0200
ffffffffc0201566:	08e6ef63          	bltu	a3,a4,ffffffffc0201604 <pmm_init+0x162>
ffffffffc020156a:	6018                	ld	a4,0(s0)
    if (freemem < mem_end) {
ffffffffc020156c:	45c5                	li	a1,17
ffffffffc020156e:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201570:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc0201572:	04b6e863          	bltu	a3,a1,ffffffffc02015c2 <pmm_init+0x120>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0201576:	609c                	ld	a5,0(s1)
ffffffffc0201578:	7b9c                	ld	a5,48(a5)
ffffffffc020157a:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc020157c:	00001517          	auipc	a0,0x1
ffffffffc0201580:	22450513          	addi	a0,a0,548 # ffffffffc02027a0 <buddy_pmm_manager+0xa8>
ffffffffc0201584:	b33fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc0201588:	00004597          	auipc	a1,0x4
ffffffffc020158c:	a7858593          	addi	a1,a1,-1416 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc0201590:	00005797          	auipc	a5,0x5
ffffffffc0201594:	08b7b423          	sd	a1,136(a5) # ffffffffc0206618 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc0201598:	c02007b7          	lui	a5,0xc0200
ffffffffc020159c:	08f5e063          	bltu	a1,a5,ffffffffc020161c <pmm_init+0x17a>
ffffffffc02015a0:	6010                	ld	a2,0(s0)
}
ffffffffc02015a2:	6442                	ld	s0,16(sp)
ffffffffc02015a4:	60e2                	ld	ra,24(sp)
ffffffffc02015a6:	64a2                	ld	s1,8(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc02015a8:	40c58633          	sub	a2,a1,a2
ffffffffc02015ac:	00005797          	auipc	a5,0x5
ffffffffc02015b0:	06c7b223          	sd	a2,100(a5) # ffffffffc0206610 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02015b4:	00001517          	auipc	a0,0x1
ffffffffc02015b8:	20c50513          	addi	a0,a0,524 # ffffffffc02027c0 <buddy_pmm_manager+0xc8>
}
ffffffffc02015bc:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02015be:	af9fe06f          	j	ffffffffc02000b6 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02015c2:	6705                	lui	a4,0x1
ffffffffc02015c4:	177d                	addi	a4,a4,-1
ffffffffc02015c6:	96ba                	add	a3,a3,a4
ffffffffc02015c8:	777d                	lui	a4,0xfffff
ffffffffc02015ca:	8ef9                	and	a3,a3,a4
    if (PPN(pa) >= npage) {
ffffffffc02015cc:	00c6d513          	srli	a0,a3,0xc
ffffffffc02015d0:	00f57e63          	bgeu	a0,a5,ffffffffc02015ec <pmm_init+0x14a>
    pmm_manager->init_memmap(base, n);
ffffffffc02015d4:	609c                	ld	a5,0(s1)
    return &pages[PPN(pa) - nbase];
ffffffffc02015d6:	982a                	add	a6,a6,a0
ffffffffc02015d8:	00281513          	slli	a0,a6,0x2
ffffffffc02015dc:	9542                	add	a0,a0,a6
ffffffffc02015de:	6b9c                	ld	a5,16(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02015e0:	8d95                	sub	a1,a1,a3
ffffffffc02015e2:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc02015e4:	81b1                	srli	a1,a1,0xc
ffffffffc02015e6:	9532                	add	a0,a0,a2
ffffffffc02015e8:	9782                	jalr	a5
}
ffffffffc02015ea:	b771                	j	ffffffffc0201576 <pmm_init+0xd4>
        panic("pa2page called with invalid pa");
ffffffffc02015ec:	00001617          	auipc	a2,0x1
ffffffffc02015f0:	df460613          	addi	a2,a2,-524 # ffffffffc02023e0 <commands+0x708>
ffffffffc02015f4:	06b00593          	li	a1,107
ffffffffc02015f8:	00001517          	auipc	a0,0x1
ffffffffc02015fc:	e0850513          	addi	a0,a0,-504 # ffffffffc0202400 <commands+0x728>
ffffffffc0201600:	da9fe0ef          	jal	ra,ffffffffc02003a8 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201604:	00001617          	auipc	a2,0x1
ffffffffc0201608:	db460613          	addi	a2,a2,-588 # ffffffffc02023b8 <commands+0x6e0>
ffffffffc020160c:	06f00593          	li	a1,111
ffffffffc0201610:	00001517          	auipc	a0,0x1
ffffffffc0201614:	18050513          	addi	a0,a0,384 # ffffffffc0202790 <buddy_pmm_manager+0x98>
ffffffffc0201618:	d91fe0ef          	jal	ra,ffffffffc02003a8 <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc020161c:	86ae                	mv	a3,a1
ffffffffc020161e:	00001617          	auipc	a2,0x1
ffffffffc0201622:	d9a60613          	addi	a2,a2,-614 # ffffffffc02023b8 <commands+0x6e0>
ffffffffc0201626:	08a00593          	li	a1,138
ffffffffc020162a:	00001517          	auipc	a0,0x1
ffffffffc020162e:	16650513          	addi	a0,a0,358 # ffffffffc0202790 <buddy_pmm_manager+0x98>
ffffffffc0201632:	d77fe0ef          	jal	ra,ffffffffc02003a8 <__panic>

ffffffffc0201636 <printnum>:
ffffffffc0201636:	02069813          	slli	a6,a3,0x20
ffffffffc020163a:	7179                	addi	sp,sp,-48
ffffffffc020163c:	02085813          	srli	a6,a6,0x20
ffffffffc0201640:	e052                	sd	s4,0(sp)
ffffffffc0201642:	03067a33          	remu	s4,a2,a6
ffffffffc0201646:	f022                	sd	s0,32(sp)
ffffffffc0201648:	ec26                	sd	s1,24(sp)
ffffffffc020164a:	e84a                	sd	s2,16(sp)
ffffffffc020164c:	f406                	sd	ra,40(sp)
ffffffffc020164e:	e44e                	sd	s3,8(sp)
ffffffffc0201650:	84aa                	mv	s1,a0
ffffffffc0201652:	892e                	mv	s2,a1
ffffffffc0201654:	fff7041b          	addiw	s0,a4,-1
ffffffffc0201658:	2a01                	sext.w	s4,s4
ffffffffc020165a:	03067e63          	bgeu	a2,a6,ffffffffc0201696 <printnum+0x60>
ffffffffc020165e:	89be                	mv	s3,a5
ffffffffc0201660:	00805763          	blez	s0,ffffffffc020166e <printnum+0x38>
ffffffffc0201664:	347d                	addiw	s0,s0,-1
ffffffffc0201666:	85ca                	mv	a1,s2
ffffffffc0201668:	854e                	mv	a0,s3
ffffffffc020166a:	9482                	jalr	s1
ffffffffc020166c:	fc65                	bnez	s0,ffffffffc0201664 <printnum+0x2e>
ffffffffc020166e:	1a02                	slli	s4,s4,0x20
ffffffffc0201670:	020a5a13          	srli	s4,s4,0x20
ffffffffc0201674:	00001797          	auipc	a5,0x1
ffffffffc0201678:	31c78793          	addi	a5,a5,796 # ffffffffc0202990 <error_string+0x38>
ffffffffc020167c:	9a3e                	add	s4,s4,a5
ffffffffc020167e:	7402                	ld	s0,32(sp)
ffffffffc0201680:	000a4503          	lbu	a0,0(s4)
ffffffffc0201684:	70a2                	ld	ra,40(sp)
ffffffffc0201686:	69a2                	ld	s3,8(sp)
ffffffffc0201688:	6a02                	ld	s4,0(sp)
ffffffffc020168a:	85ca                	mv	a1,s2
ffffffffc020168c:	8326                	mv	t1,s1
ffffffffc020168e:	6942                	ld	s2,16(sp)
ffffffffc0201690:	64e2                	ld	s1,24(sp)
ffffffffc0201692:	6145                	addi	sp,sp,48
ffffffffc0201694:	8302                	jr	t1
ffffffffc0201696:	03065633          	divu	a2,a2,a6
ffffffffc020169a:	8722                	mv	a4,s0
ffffffffc020169c:	f9bff0ef          	jal	ra,ffffffffc0201636 <printnum>
ffffffffc02016a0:	b7f9                	j	ffffffffc020166e <printnum+0x38>

ffffffffc02016a2 <vprintfmt>:
ffffffffc02016a2:	7119                	addi	sp,sp,-128
ffffffffc02016a4:	f4a6                	sd	s1,104(sp)
ffffffffc02016a6:	f0ca                	sd	s2,96(sp)
ffffffffc02016a8:	e8d2                	sd	s4,80(sp)
ffffffffc02016aa:	e4d6                	sd	s5,72(sp)
ffffffffc02016ac:	e0da                	sd	s6,64(sp)
ffffffffc02016ae:	fc5e                	sd	s7,56(sp)
ffffffffc02016b0:	f862                	sd	s8,48(sp)
ffffffffc02016b2:	f06a                	sd	s10,32(sp)
ffffffffc02016b4:	fc86                	sd	ra,120(sp)
ffffffffc02016b6:	f8a2                	sd	s0,112(sp)
ffffffffc02016b8:	ecce                	sd	s3,88(sp)
ffffffffc02016ba:	f466                	sd	s9,40(sp)
ffffffffc02016bc:	ec6e                	sd	s11,24(sp)
ffffffffc02016be:	892a                	mv	s2,a0
ffffffffc02016c0:	84ae                	mv	s1,a1
ffffffffc02016c2:	8d32                	mv	s10,a2
ffffffffc02016c4:	8ab6                	mv	s5,a3
ffffffffc02016c6:	5b7d                	li	s6,-1
ffffffffc02016c8:	00001a17          	auipc	s4,0x1
ffffffffc02016cc:	138a0a13          	addi	s4,s4,312 # ffffffffc0202800 <buddy_pmm_manager+0x108>
ffffffffc02016d0:	05e00b93          	li	s7,94
ffffffffc02016d4:	00001c17          	auipc	s8,0x1
ffffffffc02016d8:	284c0c13          	addi	s8,s8,644 # ffffffffc0202958 <error_string>
ffffffffc02016dc:	000d4503          	lbu	a0,0(s10)
ffffffffc02016e0:	02500793          	li	a5,37
ffffffffc02016e4:	001d0413          	addi	s0,s10,1
ffffffffc02016e8:	00f50e63          	beq	a0,a5,ffffffffc0201704 <vprintfmt+0x62>
ffffffffc02016ec:	c521                	beqz	a0,ffffffffc0201734 <vprintfmt+0x92>
ffffffffc02016ee:	02500993          	li	s3,37
ffffffffc02016f2:	a011                	j	ffffffffc02016f6 <vprintfmt+0x54>
ffffffffc02016f4:	c121                	beqz	a0,ffffffffc0201734 <vprintfmt+0x92>
ffffffffc02016f6:	85a6                	mv	a1,s1
ffffffffc02016f8:	0405                	addi	s0,s0,1
ffffffffc02016fa:	9902                	jalr	s2
ffffffffc02016fc:	fff44503          	lbu	a0,-1(s0)
ffffffffc0201700:	ff351ae3          	bne	a0,s3,ffffffffc02016f4 <vprintfmt+0x52>
ffffffffc0201704:	00044603          	lbu	a2,0(s0)
ffffffffc0201708:	02000793          	li	a5,32
ffffffffc020170c:	4981                	li	s3,0
ffffffffc020170e:	4801                	li	a6,0
ffffffffc0201710:	5cfd                	li	s9,-1
ffffffffc0201712:	5dfd                	li	s11,-1
ffffffffc0201714:	05500593          	li	a1,85
ffffffffc0201718:	4525                	li	a0,9
ffffffffc020171a:	fdd6069b          	addiw	a3,a2,-35
ffffffffc020171e:	0ff6f693          	andi	a3,a3,255
ffffffffc0201722:	00140d13          	addi	s10,s0,1
ffffffffc0201726:	1ed5ef63          	bltu	a1,a3,ffffffffc0201924 <vprintfmt+0x282>
ffffffffc020172a:	068a                	slli	a3,a3,0x2
ffffffffc020172c:	96d2                	add	a3,a3,s4
ffffffffc020172e:	4294                	lw	a3,0(a3)
ffffffffc0201730:	96d2                	add	a3,a3,s4
ffffffffc0201732:	8682                	jr	a3
ffffffffc0201734:	70e6                	ld	ra,120(sp)
ffffffffc0201736:	7446                	ld	s0,112(sp)
ffffffffc0201738:	74a6                	ld	s1,104(sp)
ffffffffc020173a:	7906                	ld	s2,96(sp)
ffffffffc020173c:	69e6                	ld	s3,88(sp)
ffffffffc020173e:	6a46                	ld	s4,80(sp)
ffffffffc0201740:	6aa6                	ld	s5,72(sp)
ffffffffc0201742:	6b06                	ld	s6,64(sp)
ffffffffc0201744:	7be2                	ld	s7,56(sp)
ffffffffc0201746:	7c42                	ld	s8,48(sp)
ffffffffc0201748:	7ca2                	ld	s9,40(sp)
ffffffffc020174a:	7d02                	ld	s10,32(sp)
ffffffffc020174c:	6de2                	ld	s11,24(sp)
ffffffffc020174e:	6109                	addi	sp,sp,128
ffffffffc0201750:	8082                	ret
ffffffffc0201752:	87b2                	mv	a5,a2
ffffffffc0201754:	00144603          	lbu	a2,1(s0)
ffffffffc0201758:	846a                	mv	s0,s10
ffffffffc020175a:	b7c1                	j	ffffffffc020171a <vprintfmt+0x78>
ffffffffc020175c:	000aac83          	lw	s9,0(s5)
ffffffffc0201760:	00144603          	lbu	a2,1(s0)
ffffffffc0201764:	0aa1                	addi	s5,s5,8
ffffffffc0201766:	846a                	mv	s0,s10
ffffffffc0201768:	fa0dd9e3          	bgez	s11,ffffffffc020171a <vprintfmt+0x78>
ffffffffc020176c:	8de6                	mv	s11,s9
ffffffffc020176e:	5cfd                	li	s9,-1
ffffffffc0201770:	b76d                	j	ffffffffc020171a <vprintfmt+0x78>
ffffffffc0201772:	fffdc693          	not	a3,s11
ffffffffc0201776:	96fd                	srai	a3,a3,0x3f
ffffffffc0201778:	00ddfdb3          	and	s11,s11,a3
ffffffffc020177c:	00144603          	lbu	a2,1(s0)
ffffffffc0201780:	2d81                	sext.w	s11,s11
ffffffffc0201782:	846a                	mv	s0,s10
ffffffffc0201784:	bf59                	j	ffffffffc020171a <vprintfmt+0x78>
ffffffffc0201786:	4705                	li	a4,1
ffffffffc0201788:	008a8593          	addi	a1,s5,8
ffffffffc020178c:	01074463          	blt	a4,a6,ffffffffc0201794 <vprintfmt+0xf2>
ffffffffc0201790:	22080863          	beqz	a6,ffffffffc02019c0 <vprintfmt+0x31e>
ffffffffc0201794:	000ab603          	ld	a2,0(s5)
ffffffffc0201798:	46c1                	li	a3,16
ffffffffc020179a:	8aae                	mv	s5,a1
ffffffffc020179c:	a291                	j	ffffffffc02018e0 <vprintfmt+0x23e>
ffffffffc020179e:	fd060c9b          	addiw	s9,a2,-48
ffffffffc02017a2:	00144603          	lbu	a2,1(s0)
ffffffffc02017a6:	846a                	mv	s0,s10
ffffffffc02017a8:	fd06069b          	addiw	a3,a2,-48
ffffffffc02017ac:	0006089b          	sext.w	a7,a2
ffffffffc02017b0:	fad56ce3          	bltu	a0,a3,ffffffffc0201768 <vprintfmt+0xc6>
ffffffffc02017b4:	0405                	addi	s0,s0,1
ffffffffc02017b6:	002c969b          	slliw	a3,s9,0x2
ffffffffc02017ba:	00044603          	lbu	a2,0(s0)
ffffffffc02017be:	0196873b          	addw	a4,a3,s9
ffffffffc02017c2:	0017171b          	slliw	a4,a4,0x1
ffffffffc02017c6:	0117073b          	addw	a4,a4,a7
ffffffffc02017ca:	fd06069b          	addiw	a3,a2,-48
ffffffffc02017ce:	fd070c9b          	addiw	s9,a4,-48
ffffffffc02017d2:	0006089b          	sext.w	a7,a2
ffffffffc02017d6:	fcd57fe3          	bgeu	a0,a3,ffffffffc02017b4 <vprintfmt+0x112>
ffffffffc02017da:	b779                	j	ffffffffc0201768 <vprintfmt+0xc6>
ffffffffc02017dc:	000aa503          	lw	a0,0(s5)
ffffffffc02017e0:	85a6                	mv	a1,s1
ffffffffc02017e2:	0aa1                	addi	s5,s5,8
ffffffffc02017e4:	9902                	jalr	s2
ffffffffc02017e6:	bddd                	j	ffffffffc02016dc <vprintfmt+0x3a>
ffffffffc02017e8:	4705                	li	a4,1
ffffffffc02017ea:	008a8993          	addi	s3,s5,8
ffffffffc02017ee:	01074463          	blt	a4,a6,ffffffffc02017f6 <vprintfmt+0x154>
ffffffffc02017f2:	1c080463          	beqz	a6,ffffffffc02019ba <vprintfmt+0x318>
ffffffffc02017f6:	000ab403          	ld	s0,0(s5)
ffffffffc02017fa:	1c044a63          	bltz	s0,ffffffffc02019ce <vprintfmt+0x32c>
ffffffffc02017fe:	8622                	mv	a2,s0
ffffffffc0201800:	8ace                	mv	s5,s3
ffffffffc0201802:	46a9                	li	a3,10
ffffffffc0201804:	a8f1                	j	ffffffffc02018e0 <vprintfmt+0x23e>
ffffffffc0201806:	000aa783          	lw	a5,0(s5)
ffffffffc020180a:	4719                	li	a4,6
ffffffffc020180c:	0aa1                	addi	s5,s5,8
ffffffffc020180e:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0201812:	8fb5                	xor	a5,a5,a3
ffffffffc0201814:	40d786bb          	subw	a3,a5,a3
ffffffffc0201818:	12d74963          	blt	a4,a3,ffffffffc020194a <vprintfmt+0x2a8>
ffffffffc020181c:	00369793          	slli	a5,a3,0x3
ffffffffc0201820:	97e2                	add	a5,a5,s8
ffffffffc0201822:	639c                	ld	a5,0(a5)
ffffffffc0201824:	12078363          	beqz	a5,ffffffffc020194a <vprintfmt+0x2a8>
ffffffffc0201828:	86be                	mv	a3,a5
ffffffffc020182a:	00001617          	auipc	a2,0x1
ffffffffc020182e:	21660613          	addi	a2,a2,534 # ffffffffc0202a40 <error_string+0xe8>
ffffffffc0201832:	85a6                	mv	a1,s1
ffffffffc0201834:	854a                	mv	a0,s2
ffffffffc0201836:	1cc000ef          	jal	ra,ffffffffc0201a02 <printfmt>
ffffffffc020183a:	b54d                	j	ffffffffc02016dc <vprintfmt+0x3a>
ffffffffc020183c:	000ab603          	ld	a2,0(s5)
ffffffffc0201840:	0aa1                	addi	s5,s5,8
ffffffffc0201842:	1a060163          	beqz	a2,ffffffffc02019e4 <vprintfmt+0x342>
ffffffffc0201846:	00160413          	addi	s0,a2,1
ffffffffc020184a:	15b05763          	blez	s11,ffffffffc0201998 <vprintfmt+0x2f6>
ffffffffc020184e:	02d00593          	li	a1,45
ffffffffc0201852:	10b79d63          	bne	a5,a1,ffffffffc020196c <vprintfmt+0x2ca>
ffffffffc0201856:	00064783          	lbu	a5,0(a2)
ffffffffc020185a:	0007851b          	sext.w	a0,a5
ffffffffc020185e:	c905                	beqz	a0,ffffffffc020188e <vprintfmt+0x1ec>
ffffffffc0201860:	000cc563          	bltz	s9,ffffffffc020186a <vprintfmt+0x1c8>
ffffffffc0201864:	3cfd                	addiw	s9,s9,-1
ffffffffc0201866:	036c8263          	beq	s9,s6,ffffffffc020188a <vprintfmt+0x1e8>
ffffffffc020186a:	85a6                	mv	a1,s1
ffffffffc020186c:	14098f63          	beqz	s3,ffffffffc02019ca <vprintfmt+0x328>
ffffffffc0201870:	3781                	addiw	a5,a5,-32
ffffffffc0201872:	14fbfc63          	bgeu	s7,a5,ffffffffc02019ca <vprintfmt+0x328>
ffffffffc0201876:	03f00513          	li	a0,63
ffffffffc020187a:	9902                	jalr	s2
ffffffffc020187c:	0405                	addi	s0,s0,1
ffffffffc020187e:	fff44783          	lbu	a5,-1(s0)
ffffffffc0201882:	3dfd                	addiw	s11,s11,-1
ffffffffc0201884:	0007851b          	sext.w	a0,a5
ffffffffc0201888:	fd61                	bnez	a0,ffffffffc0201860 <vprintfmt+0x1be>
ffffffffc020188a:	e5b059e3          	blez	s11,ffffffffc02016dc <vprintfmt+0x3a>
ffffffffc020188e:	3dfd                	addiw	s11,s11,-1
ffffffffc0201890:	85a6                	mv	a1,s1
ffffffffc0201892:	02000513          	li	a0,32
ffffffffc0201896:	9902                	jalr	s2
ffffffffc0201898:	e40d82e3          	beqz	s11,ffffffffc02016dc <vprintfmt+0x3a>
ffffffffc020189c:	3dfd                	addiw	s11,s11,-1
ffffffffc020189e:	85a6                	mv	a1,s1
ffffffffc02018a0:	02000513          	li	a0,32
ffffffffc02018a4:	9902                	jalr	s2
ffffffffc02018a6:	fe0d94e3          	bnez	s11,ffffffffc020188e <vprintfmt+0x1ec>
ffffffffc02018aa:	bd0d                	j	ffffffffc02016dc <vprintfmt+0x3a>
ffffffffc02018ac:	4705                	li	a4,1
ffffffffc02018ae:	008a8593          	addi	a1,s5,8
ffffffffc02018b2:	01074463          	blt	a4,a6,ffffffffc02018ba <vprintfmt+0x218>
ffffffffc02018b6:	0e080863          	beqz	a6,ffffffffc02019a6 <vprintfmt+0x304>
ffffffffc02018ba:	000ab603          	ld	a2,0(s5)
ffffffffc02018be:	46a1                	li	a3,8
ffffffffc02018c0:	8aae                	mv	s5,a1
ffffffffc02018c2:	a839                	j	ffffffffc02018e0 <vprintfmt+0x23e>
ffffffffc02018c4:	03000513          	li	a0,48
ffffffffc02018c8:	85a6                	mv	a1,s1
ffffffffc02018ca:	e03e                	sd	a5,0(sp)
ffffffffc02018cc:	9902                	jalr	s2
ffffffffc02018ce:	85a6                	mv	a1,s1
ffffffffc02018d0:	07800513          	li	a0,120
ffffffffc02018d4:	9902                	jalr	s2
ffffffffc02018d6:	0aa1                	addi	s5,s5,8
ffffffffc02018d8:	ff8ab603          	ld	a2,-8(s5)
ffffffffc02018dc:	6782                	ld	a5,0(sp)
ffffffffc02018de:	46c1                	li	a3,16
ffffffffc02018e0:	2781                	sext.w	a5,a5
ffffffffc02018e2:	876e                	mv	a4,s11
ffffffffc02018e4:	85a6                	mv	a1,s1
ffffffffc02018e6:	854a                	mv	a0,s2
ffffffffc02018e8:	d4fff0ef          	jal	ra,ffffffffc0201636 <printnum>
ffffffffc02018ec:	bbc5                	j	ffffffffc02016dc <vprintfmt+0x3a>
ffffffffc02018ee:	00144603          	lbu	a2,1(s0)
ffffffffc02018f2:	2805                	addiw	a6,a6,1
ffffffffc02018f4:	846a                	mv	s0,s10
ffffffffc02018f6:	b515                	j	ffffffffc020171a <vprintfmt+0x78>
ffffffffc02018f8:	00144603          	lbu	a2,1(s0)
ffffffffc02018fc:	4985                	li	s3,1
ffffffffc02018fe:	846a                	mv	s0,s10
ffffffffc0201900:	bd29                	j	ffffffffc020171a <vprintfmt+0x78>
ffffffffc0201902:	85a6                	mv	a1,s1
ffffffffc0201904:	02500513          	li	a0,37
ffffffffc0201908:	9902                	jalr	s2
ffffffffc020190a:	bbc9                	j	ffffffffc02016dc <vprintfmt+0x3a>
ffffffffc020190c:	4705                	li	a4,1
ffffffffc020190e:	008a8593          	addi	a1,s5,8
ffffffffc0201912:	01074463          	blt	a4,a6,ffffffffc020191a <vprintfmt+0x278>
ffffffffc0201916:	08080d63          	beqz	a6,ffffffffc02019b0 <vprintfmt+0x30e>
ffffffffc020191a:	000ab603          	ld	a2,0(s5)
ffffffffc020191e:	46a9                	li	a3,10
ffffffffc0201920:	8aae                	mv	s5,a1
ffffffffc0201922:	bf7d                	j	ffffffffc02018e0 <vprintfmt+0x23e>
ffffffffc0201924:	85a6                	mv	a1,s1
ffffffffc0201926:	02500513          	li	a0,37
ffffffffc020192a:	9902                	jalr	s2
ffffffffc020192c:	fff44703          	lbu	a4,-1(s0)
ffffffffc0201930:	02500793          	li	a5,37
ffffffffc0201934:	8d22                	mv	s10,s0
ffffffffc0201936:	daf703e3          	beq	a4,a5,ffffffffc02016dc <vprintfmt+0x3a>
ffffffffc020193a:	02500713          	li	a4,37
ffffffffc020193e:	1d7d                	addi	s10,s10,-1
ffffffffc0201940:	fffd4783          	lbu	a5,-1(s10)
ffffffffc0201944:	fee79de3          	bne	a5,a4,ffffffffc020193e <vprintfmt+0x29c>
ffffffffc0201948:	bb51                	j	ffffffffc02016dc <vprintfmt+0x3a>
ffffffffc020194a:	00001617          	auipc	a2,0x1
ffffffffc020194e:	0e660613          	addi	a2,a2,230 # ffffffffc0202a30 <error_string+0xd8>
ffffffffc0201952:	85a6                	mv	a1,s1
ffffffffc0201954:	854a                	mv	a0,s2
ffffffffc0201956:	0ac000ef          	jal	ra,ffffffffc0201a02 <printfmt>
ffffffffc020195a:	b349                	j	ffffffffc02016dc <vprintfmt+0x3a>
ffffffffc020195c:	00001617          	auipc	a2,0x1
ffffffffc0201960:	0cc60613          	addi	a2,a2,204 # ffffffffc0202a28 <error_string+0xd0>
ffffffffc0201964:	00001417          	auipc	s0,0x1
ffffffffc0201968:	0c540413          	addi	s0,s0,197 # ffffffffc0202a29 <error_string+0xd1>
ffffffffc020196c:	8532                	mv	a0,a2
ffffffffc020196e:	85e6                	mv	a1,s9
ffffffffc0201970:	e032                	sd	a2,0(sp)
ffffffffc0201972:	e43e                	sd	a5,8(sp)
ffffffffc0201974:	1c2000ef          	jal	ra,ffffffffc0201b36 <strnlen>
ffffffffc0201978:	40ad8dbb          	subw	s11,s11,a0
ffffffffc020197c:	6602                	ld	a2,0(sp)
ffffffffc020197e:	01b05d63          	blez	s11,ffffffffc0201998 <vprintfmt+0x2f6>
ffffffffc0201982:	67a2                	ld	a5,8(sp)
ffffffffc0201984:	2781                	sext.w	a5,a5
ffffffffc0201986:	e43e                	sd	a5,8(sp)
ffffffffc0201988:	6522                	ld	a0,8(sp)
ffffffffc020198a:	85a6                	mv	a1,s1
ffffffffc020198c:	e032                	sd	a2,0(sp)
ffffffffc020198e:	3dfd                	addiw	s11,s11,-1
ffffffffc0201990:	9902                	jalr	s2
ffffffffc0201992:	6602                	ld	a2,0(sp)
ffffffffc0201994:	fe0d9ae3          	bnez	s11,ffffffffc0201988 <vprintfmt+0x2e6>
ffffffffc0201998:	00064783          	lbu	a5,0(a2)
ffffffffc020199c:	0007851b          	sext.w	a0,a5
ffffffffc02019a0:	ec0510e3          	bnez	a0,ffffffffc0201860 <vprintfmt+0x1be>
ffffffffc02019a4:	bb25                	j	ffffffffc02016dc <vprintfmt+0x3a>
ffffffffc02019a6:	000ae603          	lwu	a2,0(s5)
ffffffffc02019aa:	46a1                	li	a3,8
ffffffffc02019ac:	8aae                	mv	s5,a1
ffffffffc02019ae:	bf0d                	j	ffffffffc02018e0 <vprintfmt+0x23e>
ffffffffc02019b0:	000ae603          	lwu	a2,0(s5)
ffffffffc02019b4:	46a9                	li	a3,10
ffffffffc02019b6:	8aae                	mv	s5,a1
ffffffffc02019b8:	b725                	j	ffffffffc02018e0 <vprintfmt+0x23e>
ffffffffc02019ba:	000aa403          	lw	s0,0(s5)
ffffffffc02019be:	bd35                	j	ffffffffc02017fa <vprintfmt+0x158>
ffffffffc02019c0:	000ae603          	lwu	a2,0(s5)
ffffffffc02019c4:	46c1                	li	a3,16
ffffffffc02019c6:	8aae                	mv	s5,a1
ffffffffc02019c8:	bf21                	j	ffffffffc02018e0 <vprintfmt+0x23e>
ffffffffc02019ca:	9902                	jalr	s2
ffffffffc02019cc:	bd45                	j	ffffffffc020187c <vprintfmt+0x1da>
ffffffffc02019ce:	85a6                	mv	a1,s1
ffffffffc02019d0:	02d00513          	li	a0,45
ffffffffc02019d4:	e03e                	sd	a5,0(sp)
ffffffffc02019d6:	9902                	jalr	s2
ffffffffc02019d8:	8ace                	mv	s5,s3
ffffffffc02019da:	40800633          	neg	a2,s0
ffffffffc02019de:	46a9                	li	a3,10
ffffffffc02019e0:	6782                	ld	a5,0(sp)
ffffffffc02019e2:	bdfd                	j	ffffffffc02018e0 <vprintfmt+0x23e>
ffffffffc02019e4:	01b05663          	blez	s11,ffffffffc02019f0 <vprintfmt+0x34e>
ffffffffc02019e8:	02d00693          	li	a3,45
ffffffffc02019ec:	f6d798e3          	bne	a5,a3,ffffffffc020195c <vprintfmt+0x2ba>
ffffffffc02019f0:	00001417          	auipc	s0,0x1
ffffffffc02019f4:	03940413          	addi	s0,s0,57 # ffffffffc0202a29 <error_string+0xd1>
ffffffffc02019f8:	02800513          	li	a0,40
ffffffffc02019fc:	02800793          	li	a5,40
ffffffffc0201a00:	b585                	j	ffffffffc0201860 <vprintfmt+0x1be>

ffffffffc0201a02 <printfmt>:
ffffffffc0201a02:	715d                	addi	sp,sp,-80
ffffffffc0201a04:	02810313          	addi	t1,sp,40
ffffffffc0201a08:	f436                	sd	a3,40(sp)
ffffffffc0201a0a:	869a                	mv	a3,t1
ffffffffc0201a0c:	ec06                	sd	ra,24(sp)
ffffffffc0201a0e:	f83a                	sd	a4,48(sp)
ffffffffc0201a10:	fc3e                	sd	a5,56(sp)
ffffffffc0201a12:	e0c2                	sd	a6,64(sp)
ffffffffc0201a14:	e4c6                	sd	a7,72(sp)
ffffffffc0201a16:	e41a                	sd	t1,8(sp)
ffffffffc0201a18:	c8bff0ef          	jal	ra,ffffffffc02016a2 <vprintfmt>
ffffffffc0201a1c:	60e2                	ld	ra,24(sp)
ffffffffc0201a1e:	6161                	addi	sp,sp,80
ffffffffc0201a20:	8082                	ret

ffffffffc0201a22 <readline>:
ffffffffc0201a22:	715d                	addi	sp,sp,-80
ffffffffc0201a24:	e486                	sd	ra,72(sp)
ffffffffc0201a26:	e0a2                	sd	s0,64(sp)
ffffffffc0201a28:	fc26                	sd	s1,56(sp)
ffffffffc0201a2a:	f84a                	sd	s2,48(sp)
ffffffffc0201a2c:	f44e                	sd	s3,40(sp)
ffffffffc0201a2e:	f052                	sd	s4,32(sp)
ffffffffc0201a30:	ec56                	sd	s5,24(sp)
ffffffffc0201a32:	e85a                	sd	s6,16(sp)
ffffffffc0201a34:	e45e                	sd	s7,8(sp)
ffffffffc0201a36:	c901                	beqz	a0,ffffffffc0201a46 <readline+0x24>
ffffffffc0201a38:	85aa                	mv	a1,a0
ffffffffc0201a3a:	00001517          	auipc	a0,0x1
ffffffffc0201a3e:	00650513          	addi	a0,a0,6 # ffffffffc0202a40 <error_string+0xe8>
ffffffffc0201a42:	e74fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0201a46:	4481                	li	s1,0
ffffffffc0201a48:	497d                	li	s2,31
ffffffffc0201a4a:	49a1                	li	s3,8
ffffffffc0201a4c:	4aa9                	li	s5,10
ffffffffc0201a4e:	4b35                	li	s6,13
ffffffffc0201a50:	00004b97          	auipc	s7,0x4
ffffffffc0201a54:	7a0b8b93          	addi	s7,s7,1952 # ffffffffc02061f0 <buf>
ffffffffc0201a58:	3fe00a13          	li	s4,1022
ffffffffc0201a5c:	ed0fe0ef          	jal	ra,ffffffffc020012c <getchar>
ffffffffc0201a60:	842a                	mv	s0,a0
ffffffffc0201a62:	00054b63          	bltz	a0,ffffffffc0201a78 <readline+0x56>
ffffffffc0201a66:	00a95b63          	bge	s2,a0,ffffffffc0201a7c <readline+0x5a>
ffffffffc0201a6a:	029a5463          	bge	s4,s1,ffffffffc0201a92 <readline+0x70>
ffffffffc0201a6e:	ebefe0ef          	jal	ra,ffffffffc020012c <getchar>
ffffffffc0201a72:	842a                	mv	s0,a0
ffffffffc0201a74:	fe0559e3          	bgez	a0,ffffffffc0201a66 <readline+0x44>
ffffffffc0201a78:	4501                	li	a0,0
ffffffffc0201a7a:	a099                	j	ffffffffc0201ac0 <readline+0x9e>
ffffffffc0201a7c:	03341463          	bne	s0,s3,ffffffffc0201aa4 <readline+0x82>
ffffffffc0201a80:	e8b9                	bnez	s1,ffffffffc0201ad6 <readline+0xb4>
ffffffffc0201a82:	eaafe0ef          	jal	ra,ffffffffc020012c <getchar>
ffffffffc0201a86:	842a                	mv	s0,a0
ffffffffc0201a88:	fe0548e3          	bltz	a0,ffffffffc0201a78 <readline+0x56>
ffffffffc0201a8c:	fea958e3          	bge	s2,a0,ffffffffc0201a7c <readline+0x5a>
ffffffffc0201a90:	4481                	li	s1,0
ffffffffc0201a92:	8522                	mv	a0,s0
ffffffffc0201a94:	e56fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
ffffffffc0201a98:	009b87b3          	add	a5,s7,s1
ffffffffc0201a9c:	00878023          	sb	s0,0(a5)
ffffffffc0201aa0:	2485                	addiw	s1,s1,1
ffffffffc0201aa2:	bf6d                	j	ffffffffc0201a5c <readline+0x3a>
ffffffffc0201aa4:	01540463          	beq	s0,s5,ffffffffc0201aac <readline+0x8a>
ffffffffc0201aa8:	fb641ae3          	bne	s0,s6,ffffffffc0201a5c <readline+0x3a>
ffffffffc0201aac:	8522                	mv	a0,s0
ffffffffc0201aae:	e3cfe0ef          	jal	ra,ffffffffc02000ea <cputchar>
ffffffffc0201ab2:	00004517          	auipc	a0,0x4
ffffffffc0201ab6:	73e50513          	addi	a0,a0,1854 # ffffffffc02061f0 <buf>
ffffffffc0201aba:	94aa                	add	s1,s1,a0
ffffffffc0201abc:	00048023          	sb	zero,0(s1)
ffffffffc0201ac0:	60a6                	ld	ra,72(sp)
ffffffffc0201ac2:	6406                	ld	s0,64(sp)
ffffffffc0201ac4:	74e2                	ld	s1,56(sp)
ffffffffc0201ac6:	7942                	ld	s2,48(sp)
ffffffffc0201ac8:	79a2                	ld	s3,40(sp)
ffffffffc0201aca:	7a02                	ld	s4,32(sp)
ffffffffc0201acc:	6ae2                	ld	s5,24(sp)
ffffffffc0201ace:	6b42                	ld	s6,16(sp)
ffffffffc0201ad0:	6ba2                	ld	s7,8(sp)
ffffffffc0201ad2:	6161                	addi	sp,sp,80
ffffffffc0201ad4:	8082                	ret
ffffffffc0201ad6:	4521                	li	a0,8
ffffffffc0201ad8:	e12fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
ffffffffc0201adc:	34fd                	addiw	s1,s1,-1
ffffffffc0201ade:	bfbd                	j	ffffffffc0201a5c <readline+0x3a>

ffffffffc0201ae0 <sbi_console_putchar>:
ffffffffc0201ae0:	00004797          	auipc	a5,0x4
ffffffffc0201ae4:	52878793          	addi	a5,a5,1320 # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
ffffffffc0201ae8:	6398                	ld	a4,0(a5)
ffffffffc0201aea:	4781                	li	a5,0
ffffffffc0201aec:	88ba                	mv	a7,a4
ffffffffc0201aee:	852a                	mv	a0,a0
ffffffffc0201af0:	85be                	mv	a1,a5
ffffffffc0201af2:	863e                	mv	a2,a5
ffffffffc0201af4:	00000073          	ecall
ffffffffc0201af8:	87aa                	mv	a5,a0
ffffffffc0201afa:	8082                	ret

ffffffffc0201afc <sbi_set_timer>:
ffffffffc0201afc:	00005797          	auipc	a5,0x5
ffffffffc0201b00:	b2c78793          	addi	a5,a5,-1236 # ffffffffc0206628 <SBI_SET_TIMER>
ffffffffc0201b04:	6398                	ld	a4,0(a5)
ffffffffc0201b06:	4781                	li	a5,0
ffffffffc0201b08:	88ba                	mv	a7,a4
ffffffffc0201b0a:	852a                	mv	a0,a0
ffffffffc0201b0c:	85be                	mv	a1,a5
ffffffffc0201b0e:	863e                	mv	a2,a5
ffffffffc0201b10:	00000073          	ecall
ffffffffc0201b14:	87aa                	mv	a5,a0
ffffffffc0201b16:	8082                	ret

ffffffffc0201b18 <sbi_console_getchar>:
ffffffffc0201b18:	00004797          	auipc	a5,0x4
ffffffffc0201b1c:	4e878793          	addi	a5,a5,1256 # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
ffffffffc0201b20:	639c                	ld	a5,0(a5)
ffffffffc0201b22:	4501                	li	a0,0
ffffffffc0201b24:	88be                	mv	a7,a5
ffffffffc0201b26:	852a                	mv	a0,a0
ffffffffc0201b28:	85aa                	mv	a1,a0
ffffffffc0201b2a:	862a                	mv	a2,a0
ffffffffc0201b2c:	00000073          	ecall
ffffffffc0201b30:	852a                	mv	a0,a0
ffffffffc0201b32:	2501                	sext.w	a0,a0
ffffffffc0201b34:	8082                	ret

ffffffffc0201b36 <strnlen>:
ffffffffc0201b36:	c185                	beqz	a1,ffffffffc0201b56 <strnlen+0x20>
ffffffffc0201b38:	00054783          	lbu	a5,0(a0)
ffffffffc0201b3c:	cf89                	beqz	a5,ffffffffc0201b56 <strnlen+0x20>
ffffffffc0201b3e:	4781                	li	a5,0
ffffffffc0201b40:	a021                	j	ffffffffc0201b48 <strnlen+0x12>
ffffffffc0201b42:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0x3fdf89c8>
ffffffffc0201b46:	c711                	beqz	a4,ffffffffc0201b52 <strnlen+0x1c>
ffffffffc0201b48:	0785                	addi	a5,a5,1
ffffffffc0201b4a:	00f50733          	add	a4,a0,a5
ffffffffc0201b4e:	fef59ae3          	bne	a1,a5,ffffffffc0201b42 <strnlen+0xc>
ffffffffc0201b52:	853e                	mv	a0,a5
ffffffffc0201b54:	8082                	ret
ffffffffc0201b56:	4781                	li	a5,0
ffffffffc0201b58:	853e                	mv	a0,a5
ffffffffc0201b5a:	8082                	ret

ffffffffc0201b5c <strcmp>:
ffffffffc0201b5c:	00054783          	lbu	a5,0(a0)
ffffffffc0201b60:	0005c703          	lbu	a4,0(a1)
ffffffffc0201b64:	cb91                	beqz	a5,ffffffffc0201b78 <strcmp+0x1c>
ffffffffc0201b66:	00e79c63          	bne	a5,a4,ffffffffc0201b7e <strcmp+0x22>
ffffffffc0201b6a:	0505                	addi	a0,a0,1
ffffffffc0201b6c:	00054783          	lbu	a5,0(a0)
ffffffffc0201b70:	0585                	addi	a1,a1,1
ffffffffc0201b72:	0005c703          	lbu	a4,0(a1)
ffffffffc0201b76:	fbe5                	bnez	a5,ffffffffc0201b66 <strcmp+0xa>
ffffffffc0201b78:	4501                	li	a0,0
ffffffffc0201b7a:	9d19                	subw	a0,a0,a4
ffffffffc0201b7c:	8082                	ret
ffffffffc0201b7e:	0007851b          	sext.w	a0,a5
ffffffffc0201b82:	9d19                	subw	a0,a0,a4
ffffffffc0201b84:	8082                	ret

ffffffffc0201b86 <strchr>:
ffffffffc0201b86:	00054783          	lbu	a5,0(a0)
ffffffffc0201b8a:	cb91                	beqz	a5,ffffffffc0201b9e <strchr+0x18>
ffffffffc0201b8c:	00b79563          	bne	a5,a1,ffffffffc0201b96 <strchr+0x10>
ffffffffc0201b90:	a809                	j	ffffffffc0201ba2 <strchr+0x1c>
ffffffffc0201b92:	00b78763          	beq	a5,a1,ffffffffc0201ba0 <strchr+0x1a>
ffffffffc0201b96:	0505                	addi	a0,a0,1
ffffffffc0201b98:	00054783          	lbu	a5,0(a0)
ffffffffc0201b9c:	fbfd                	bnez	a5,ffffffffc0201b92 <strchr+0xc>
ffffffffc0201b9e:	4501                	li	a0,0
ffffffffc0201ba0:	8082                	ret
ffffffffc0201ba2:	8082                	ret

ffffffffc0201ba4 <memset>:
ffffffffc0201ba4:	ca01                	beqz	a2,ffffffffc0201bb4 <memset+0x10>
ffffffffc0201ba6:	962a                	add	a2,a2,a0
ffffffffc0201ba8:	87aa                	mv	a5,a0
ffffffffc0201baa:	0785                	addi	a5,a5,1
ffffffffc0201bac:	feb78fa3          	sb	a1,-1(a5)
ffffffffc0201bb0:	fec79de3          	bne	a5,a2,ffffffffc0201baa <memset+0x6>
ffffffffc0201bb4:	8082                	ret
