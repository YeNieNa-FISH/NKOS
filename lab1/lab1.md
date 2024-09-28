# LAB0.5  
## 练习一 使用GDB验证启动流程  
使用示例代码 Makefile 中的 `make debug`指令启动qemu后，使用`make gdb`连接到qemu，终端输出如下：  
```  
--Type <RET> for more, q to quit, c to continue without paging--c
Remote debugging using localhost:1234
0x0000000000001000 in ?? ()
(gdb)  
```  
即RISC-V加电后复位到0x1000。使用`x/10i $pc`查看接下来的10条指令。  
```  
(gdb) x/10i $pc
=> 0x1000:      auipc   t0,0x0
   0x1004:      addi    a1,t0,32
   0x1008:      csrr    a0,mhartid
   0x100c:      ld      t0,24(t0)
   0x1010:      jr      t0
   0x1014:      unimp
   0x1016:      unimp
   0x1018:      unimp
   0x101a:      0x8000
   0x101c:      unimp  
```  
经过这几条指令，t0的值首先是`0x1000`（4096），然后经`addi`与32相加，此时a1值为`0x1020`（4128），csrr将mhartid的值存到a0中，a0值为0.ld从内存地址t0偏移24的地方（`0x1018`）读取了八个字节，并写入到了寄存器t0。 此时寄存器t0的值为：`0x80000000`（2147483648）。最后，jr跳转到地址`0x80000000`，根据实验指导书，作为bootloader的OpenSBI.bin被加载到物理内存以物理地址 `0x80000000`开头的区域上，同时内核镜像 os.bin 被加载到以物理地址`0x80200000`开头的区域上。这一过程完成了把操作系统加载到内存的工作，并将控制权转移到操作系统。  
然后我们通过`break *0x80200000`在`0x80200000`设置断点，gdb提示如下：
```  
(gdb) break *0x80200000
Breakpoint 1 at 0x80200000: file kern/init/entry.S, line 7.  
```  
此提示表明断点在`entry.S`的第七行。  
```  
#include <mmu.h>
#include <memlayout.h>

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    la sp, bootstacktop

    tail kern_init

.section .data
    # .align 2^12
    .align PGSHIFT
    .global bootstack
bootstack:
    .space KSTACKSIZE
    .global bootstacktop
bootstacktop:  
```  
断点设置在kern_entry代码块。continue执行到断点处。使用` x/10i $pc `得到后10条指令。  
```  
(gdb) continue
Continuing.

Breakpoint 1, kern_entry () at kern/init/entry.S:7
7           la sp, bootstacktop
(gdb)  x/10i $pc
=> 0x80200000 <kern_entry>:     auipc   sp,0x3
   0x80200004 <kern_entry+4>:   mv      sp,sp
   0x80200008 <kern_entry+8>:   j       0x8020000a <kern_init>
   0x8020000a <kern_init>:      auipc   a0,0x3
   0x8020000e <kern_init+4>:    addi    a0,a0,-2
   0x80200012 <kern_init+8>:    auipc   a2,0x3
   0x80200016 <kern_init+12>:   addi    a2,a2,-10
   0x8020001a <kern_init+16>:   addi    sp,sp,-16
   0x8020001c <kern_init+18>:   li      a1,0
   0x8020001e <kern_init+20>:   sub     a2,a2,a0  
```  
在 /lab0/obj中，存在编译得到的 kernel.asm 文件，查看该文件，其中 kern_entry 块等代码与 GDB 显示代码对应。这说明 `0x80200000` 确实是内核的起始地址。


# LAB1
## 练习1：理解内核启动中的程序入口操作
### 阅读 kern/init/entry.S 内容代码，结合操作系统内核启动流程，说明指令 `la sp, bootstacktop` 完成了什么操作，目的是什么？`tail kern_init` 完成了什么操作，目的是什么？

entry.S 的代码量很小，它用于设置操作系统内核的入口点以及初始化栈空间。

指令 `la sp, bootstacktop` 用于将 `bootstacktop` 地址加载到栈指针寄存器 sp 中，即将 sp 设置为指向内核栈的顶部。这段代码可以确保栈指针指向正确的位置，这样在内核初始化过程中或之后的函数调用中，当压栈（push）操作发生时，有足够的空间来存储返回地址、局部变量、函数参数等。 同时它可以防止栈溢出，因为如果栈指针没有正确设置，可能会导致栈空间被错误地覆盖，进而引发不可预测的行为甚至系统崩溃。

指令`tail kern_init`的作用是 跳转到 `kern_init` 函数，并将返回地址设置为 `kern_init` 函数的结束地址。`tail`是一个跳转伪指令，一般用于实现一种特定的尾调用优化（当一个函数的最后操作是调用另一个函数时，编译器可以复用当前函数的栈帧来调用下一个函数，从而节省栈 空间并避免额外的返回操作）。
## 练习2：完善中断处理 （需要编程）
### 请编程完善 trap.c 中的中断处理函数`trap`，在对时钟中断进行处理的部分填写 kern/trap/trap.c 函数中处理时钟中断的部分，使操作系统每遇到 100 次时钟中断后，调用 `print_ticks` 子程序，向屏幕上打印一行文字 “100 ticks”，在打印完 10 行后调用 sbi.h 中的`shut_down()` 函数关机。

### 要求完成问题1提出的相关函数实现，提交改进后的源代码包（可以编译执行），并在实验报告中简要说明实现过程和定时器中断中断处理的流程。实现要求的部分代码后，运行整个系统，大约每1秒会输出一次 “100 ticks”，输出 10 行。

源代码中`trap`函数调用了`trap_dispatch`函数，而`trap_dispatch`又调用了`interrupt_handler`，因此只在`interrupt_handler`函数里修改就行了。
```
static int interrupt_ticks = 0;
static int print_times = 0;

……

case IRQ_S_TIMER:
    /*(1)设置下次时钟中断- clock_set_next_event()
     *(2)计数器（ticks）加一
     *(3)当计数器加到100的时候，我们会输出一个`100ticks`表示我们触发了100次时钟中断，同时打印次数（num）加一
     * (4)判断打印次数，当打印次数为10时，调用<sbi.h>中的关机函数关机
    */
    clock_set_next_event();
    interrupt_ticks ++;
    if(interrupt_ticks == 100)
    {
        interrupt_ticks = 0;
        print_ticks();
        print_times ++;
    }
    if(print_times == 10)
    {
        sbi_shutdown();
    }
    break;
```

运行结果如下
```
Special kernel symbols:
  entry  0x000000008020000a (virtual)
  etext  0x0000000080200a14 (virtual)
  edata  0x0000000080204010 (virtual)
  end    0x0000000080204028 (virtual)
Kernel executable memory footprint: 17KB
++ setup timer interrupts
100 ticks
100 ticks
100 ticks
100 ticks
100 ticks
100 ticks
100 ticks
100 ticks
100 ticks
100 ticks
```

## 扩展练习 Challenge1：描述与理解中断流程
### 回答：描述 ucore 中处理中断异常的流程（从异常的产生开始），其中`mov a0，sp`的目的是什么？`SAVE_ALL` 中寄寄存器保存在栈中的位置是什么确定的？对于任何中断，`__alltraps` 中都需要保存所有寄存器吗？请说明理由。

在 trapentry.S 文件中写了出现中断时如何处理的代码。首先是当出现中断时，它会先跳转到 `__alltraps` 标签。
```
alltraps:
    SAVE_ALL
    move  a0, sp
    jal trap
    # sp should be the same as before "jal trap"
```
接着执行`SAVE_ALL`。`SAVE_ALL`会在分配完栈空间之后把所有的通用寄存器和控制寄存器保存到栈上，然后`move a0, sp`将栈指针的当前值复制到寄存器 a0，用于记录中断时的状态，以便处理完中断之后能够恢复到之前的状态。 最后跳转到`trap`函数， 并通过a0获取和修改被中断 时的寄存器状态.

在`SAVE_ALL`中，`addi sp, sp, -36 * REGBYTES`给32个寄存器分配了存储的位置，并且按照固定顺序为他们分配空间。在代码中，我们可以看到第 x 号寄存器存放的位置是 `x*REGBYTES`。

任何中断下`__alltraps` 中都需要保存所有寄存器吗？如果这个中断不涉及到某个寄存器的更改，是可以不用保存相应的寄存器的。但是实际情况十分复杂，我们无法判定哪个寄存器不会被使用，或者判断的成本十分昂贵。因此不论是考虑实际情况还是按照所给的代码，发生任何中断时，寄存器 都应该按照`SAVE_ALL`的规矩按顺序保存进栈里。

## 扩展练习 Challenge2：理解上下文切换机制
### 回答：在trapentry.S中汇编代码 `csrw sscratch, sp`；`csrrw s0, sscratch, x0`实现了什么操作，目的是什么？`SAVE_ALL`里面保存了 stval， scause 这些 csr ，而在`RESTORE_ALL`里面却不还原它们？那这样store的意义何在呢？

代码`csrw sscratch, sp`将当前的栈指针写入到 sscratch 特权级寄存器（sscratch 寄存器通常用于在用户模式和内核模式之间切换时保存和恢复栈指针。）中。这是为了保存中断发生时的栈指针，以便在中断处理过程中可以访问到它。

`csrrw s0, sscratch, x0`先将 sscratch 的值保存到 s0 里面，再将其设置为0。这样的话如果发生递归异常（即中断处理过程中又发生中断），异常向量表就可以识别出异常来自内核空间。这是因为 sscratch 在用户模式下的值通常是0，而在内核模式下会设置为非0值。

stval 和 scause 两个CSR寄存器包含了有关中断或异常的重要信息。stval包含导致异常的虚拟地址，scause 则包含了异常的原因。在中断处理过程中，这些信息是非常必要的。但在中断处理结束后，我们是不需要继续关注这些寄存器内的值的。而且 stval 和 scause 会在下一次异常发生时被覆盖或者在中断返回时被自动重置，因此我们要在`SAVE_ALL`的时候保存他们而不在`RESTORE_ALL`中还原它们。

## 扩展练习 Challenge3：完善异常中断
### 编程完善在触发一条非法指令异常 mret和，在 kern/trap/trap.c的异常处理函数中捕获，并对其进行处理，简单输出异常类型和异常指令触发地址，即“Illegal instruction caught at 0x(地址)”，“ebreak caught at 0x（地址）”与“Exception type:Illegal instruction"，“Exception type: breakpoint”。

在 trap.S 文件中，完善异常中断需要补充`exception_handler`这一函数。
```
case CAUSE_ILLEGAL_INSTRUCTION:
    // 非法指令异常处理
    /* LAB1 CHALLENGE3   YOUR CODE :  */
    /*(1)输出指令异常类型（ Illegal instruction）
     *(2)输出异常指令地址
     *(3)更新 tf->epc寄存器
    */
    cprintf("Exception type : Illegal instruction ; Illegal instruction caught at %p\n", tf->epc);
    tf->epc += 4;
    break;
case CAUSE_BREAKPOINT:
    //断点异常处理
    /* LAB1 CHALLLENGE3   YOUR CODE :  */
    /*(1)输出指令异常类型（ breakpoint）
     *(2)输出异常指令地址
     *(3)更新 tf->epc寄存器
    */
    cprintf("Exception type : breakpoint ; ebreak caught at %p\n", tf->epc);
    tf->epc += 2;
    break;
```
其中，breakpoint 报错中的`tf->epc += 2`是因为`ebreak`为 16 位的指令，不像其他 32 位指令那样加 4。

我使用 ebreak 和 mret 进行中断的模仿。当 ebreak 指令执行时，处理器进入异常处理模式，并且跳转到异常向量表中的断点异常处理程序，即 breakpoint。mret 本身不会触发中断，它是用来返回到触发异常的指令之后的那个指令。但如果 mret 在异常处理程序之外执行，或者异常处理程序没有正确设置返回地址和环境，便会触发额外的异常，即 Illegal instruction。

测试结果如下：
```
Kernel executable memory footprint: 17KB
++ setup timer interrupts
Exception type : breakpoint ; ebreak caught at 0x8020004e
sbi_emulate_csr_read: hartid0: invalid csr_num=0x302
Exception type : Illegal instruction ; Illegal instruction caught at 0x80200050
```
## make grade评测结果
```
try to run qemu
qemu pid=46953
qemu-system-riscv64: terminating on signal 15 from pid 46759 (sh)
  -100 ticks:                                OK
Total Score: 100/100
```

