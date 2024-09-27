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

