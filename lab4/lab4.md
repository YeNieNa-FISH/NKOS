### 练习

对实验报告的要求：
 - 基于markdown格式来完成，以文本方式为主
 - 填写各个基本练习中要求完成的报告内容
 - 列出你认为本实验中重要的知识点，以及与对应的OS原理中的知识点，并简要说明你对二者的含义，关系，差异等方面的理解（也可能出现实验中的知识点没有对应的原理知识点）
 - 列出你认为OS原理中很重要，但在实验中没有对应上的知识点
 
#### 练习0：填写已有实验
本实验依赖实验2/3。请把你做的实验2/3的代码填入本实验中代码中有“LAB2”,“LAB3”的注释相应部分。

#### 练习1：分配并初始化一个进程控制块（需要编码）
在proc.h中，进程管理信息的结构组成是这样的：
```
struct proc_struct {
    enum proc_state state;                  // Process state
    int pid;                                // Process ID
    int runs;                               // the running times of Proces
    uintptr_t kstack;                       // Process kernel stack
    volatile bool need_resched;             // bool value: need to be rescheduled to release CPU?
    struct proc_struct *parent;             // the parent process
    struct mm_struct *mm;                   // Process's memory management field
    struct context context;                 // Switch here to run process
    struct trapframe *tf;                   // Trap frame for current interrupt
    uintptr_t cr3;                          // CR3 register: the base addr of Page Directroy Table(PDT)
    uint32_t flags;                         // Process flag
    char name[PROC_NAME_LEN + 1];           // Process name
    list_entry_t list_link;                 // Process link list 
    list_entry_t hash_link;                 // Process hash list
};
```
其中比较重要的属性，即本次实验中初始化的属性包括：

 - `state`为进程所处的状态。uCore中进程状态有四种：
  `PROC_UNINIT`表示进程尚未被完全初始化。在这个状态下，进程还不完整，可能是因为它正在被创建，但其资源尚未完全分配。
  `PROC_SLEEPING`表示进程正在等待某些事件的发生，例如等待I/O操作完成或者等待一个定时器。处于这个状态的进程不会被调度器选中执行。
  `PROC_RUNNABLE`表示进程已经准备好运行，它可能正在运行或者等待CPU时间片的分配。在操作系统中，可运行状态的进程集合通常形成一个运行队列，由调度器根据某种策略（如轮转调度、优先级调度等）来选择哪个进程获得CPU时间。
  `PROC_ZOMBIE`表示进程已经结束了运行，但是其父进程尚未回收该进程的退出状态和资源。处于僵尸状态的进程仅仅保留了一个最小的内存空间以保存其退出状态，以便父进程能够获取相关信息。僵尸进程不能被杀死，只能通过其父进程进行回收。如果父进程没有正确地回收僵尸进程，它们就会一直占用系统资源，造成资源泄漏。
 - `pid`为进程的id
 - `runs`为进程被调度运行的次数
 - `kstack`为进程的内核栈地址。每个进程都有一个独立的内核栈，用于在内核态执行时的栈空间。
 - `need_resched`表示进程是否需要被重新调度。如果设置为 true，则表示当前进程需要释放CPU，以便其他进程可以运行。
 - `parent`是指向父进程的指针。除了初始进程，每个进程都有一个父进程。
 - `mm`指向进程的内存管理结构。这个结构体通常包含了进程的虚拟内存空间信息，如页表、内存映射等。
 - `context`是上下文结构，用于在进程切换时保存和恢复进程的寄存器状态，以便能够在下次调度时继续执行。
 - `tf`用于指向中断帧。中断帧包含了进程在发生中断时寄存器的状态，用于在中断处理完成后恢复执行。
 - `cr3`里存储着CR3寄存器的值，它指向进程的页目录表（Page Directory Table），用于虚拟内存管理。
 - `flags`是进程的标志符
 - `name`为进程的名称字符串，通常用于调试和显示。
  
在理解了这些属性的用处之后，就可以开始初始化进程了。这里可以参考proc.c的这段代码来进行初始化：
```
if(idleproc->cr3 == boot_cr3 && idleproc->tf == NULL && !context_init_flag
        && idleproc->state == PROC_UNINIT && idleproc->pid == -1 && idleproc->runs == 0
        && idleproc->kstack == 0 && idleproc->need_resched == 0 && idleproc->parent == NULL
        && idleproc->mm == NULL && idleproc->flags == 0 && !proc_name_flag
    )
```

**请说明proc_struct中struct context context和struct trapframe *tf成员变量含义和在本实验中的作用是啥？（提示通过看代码和编程调试可以判断出来）**

首先是context的含义与作用。在switch.S文件中，我们可以看到context主要保存了前一个进程的现场（各个寄存器的状态）。在uCore中，所有的进程在内核中也是相对独立的。使用context保存寄存器的目的就在于在内核态中能够进行上下文之间的切换。

其次是tf的含义与作用。在proc.c的kernel_thread函数中，采用局部变量tf来放置保存内核线程的临时中断帧，并把中断帧的指针传递给do_fork函数。而do_fork函数会调用copy_thread函数来在新创建的进程内核栈上专门给进程的中断帧分配一块空间。

```
int kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
    // 对trameframe，也就是我们程序的一些上下文进行一些初始化
    struct trapframe tf;
    memset(&tf, 0, sizeof(struct trapframe));

    // 设置内核线程的参数和函数指针
    tf.gpr.s0 = (uintptr_t)fn; // s0 寄存器保存函数指针
    tf.gpr.s1 = (uintptr_t)arg; // s1 寄存器保存函数参数

    // 设置 trapframe 中的 status 寄存器（SSTATUS）
    // SSTATUS_SPP：Supervisor Previous Privilege（设置为 supervisor 模式，因为这是一个内核线程）
    // SSTATUS_SPIE：Supervisor Previous Interrupt Enable（设置为启用中断，因为这是一个内核线程）
    // SSTATUS_SIE：Supervisor Interrupt Enable（设置为禁用中断，因为我们不希望该线程被中断）
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;

    // 将入口点（epc）设置为 kernel_thread_entry 函数，作用实际上是将pc指针指向它(*trapentry.S会用到)
    tf.epc = (uintptr_t)kernel_thread_entry;

    // 使用 do_fork 创建一个新进程（内核线程），这样才真正用设置的tf创建新进程。
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
}
```
除此之外还有copy_thread等函数，都涉及到tf的使用。通过这些函数可以看到tf作为中断帧的指针，总是指向内核栈的某个位置。当进程从用户空间跳到内核空间时，中断帧记录了进程在被中断前的状态。当内核需要跳回用户空间时，需要调整中断帧以恢复让进程继续执行的各寄存器值。

#### 练习2：为新创建的内核线程分配资源（需要编码）
创建一个内核线程需要分配和设置好很多资源。kernel_thread函数通过调用do_fork函数完成具体内核线程的创建工作。do_kernel函数会调用alloc_proc函数来分配并初始化一个进程控制块，但alloc_proc只是找到了一小块内存用以记录进程的必要信息，并没有实际分配这些资源。ucore一般通过do_fork实际创建新的内核线程。do_fork的作用是，创建当前内核线程的一个副本，它们的执行上下文、代码、数据都一样，但是存储位置不同。因此，我们实际需要"fork"的东西就是stack和trapframe。在这个过程中，需要给新内核线程分配资源，并且复制原进程的状态。你需要完成在kern/process/proc.c中的do_fork函数中的处理过程。它的大致执行步骤包括：

 - 调用alloc_proc，首先获得一块用户信息块。
 - 为进程分配一个内核栈。
 - 复制原进程的内存管理信息到新进程（但内核线程不必做此事）
 - 复制原进程上下文到新进程
 - 将新进程添加到进程列表
 - 唤醒新进程
 - 返回新进程号

请在实验报告中简要说明你的设计实现过程。请回答如下问题：

 - 请说明ucore是否做到给每个新fork的线程一个唯一的id？请说明你的分析和理由。

##### 2.1 设计过程
根据注释，do_fork函数分为如下7步：

1.调用alloc_proc
```
if ((proc = alloc_proc()) == NULL) {
        goto fork_out;
    }
    proc->parent = current;
```
调用`alloc_proc()`函数来分配内存块，如果分配失败，则立即返回并进行相应处理。
2.为进程分配一个内核栈
```
if (setup_kstack(proc)) {
        goto bad_fork_cleanup_proc;
    }
```
调用setup_kstack()函数为进程分配一个内核栈。
3.复制原进程的内存管理信息到新进程
```
if(copy_mm(clone_flags, proc)){
        goto bad_fork_cleanup_kstack;
    }
```
调用copy_mm()函数，复制父进程的内存信息到子进程。
4.复制原进程上下文到新进程
```
copy_thread(proc, stack, tf);
```
调用copy_thread()函数以复制父进程的中断帧和上下文信息。
5. 将新进程添加到进程列表
```
bool intr_flag;
    local_intr_save(intr_flag);//屏蔽中断，intr_flag置为1
    {
        proc->pid = get_pid();//获取当前进程PID
        hash_proc(proc); //建立hash映射
        list_add(&proc_list, &(proc->list_link));//加入进程链表
        nr_process ++;//进程数加一
    }
    local_intr_restore(intr_flag);//恢复中断
```
调用hash_proc()函数将新进程的PCB插入哈希进程控制链表，接着通过list_add()函数将PCB插入进程控制链表，并将总进程数加一。在将PCB添加到进程链表的过程中，使用local_intr_save()和local_intr_restore()函数来屏蔽和恢复中断，以确保添加进程操作不会被中断打断。
6.唤醒新进程
```
wakeup_proc(proc);
```
调用wakeup_proc()函数来把当前进程的state设置为PROC_RUNNABLE。
7.返回新进程号
```
ret = proc->pid;
```

##### 2.2请说明 ucore 是否做到给每个新 fork 的线程一个唯一的 id？请说明你的分析和理由。

我们可以查看实验中获取进程id的函数：get_pid(void)
```
static int
get_pid(void) {
    static_assert(MAX_PID > MAX_PROCESS);
    struct proc_struct *proc;
    list_entry_t *list = &proc_list, *le;
    static int next_safe = MAX_PID, last_pid = MAX_PID;
    if (++ last_pid >= MAX_PID) {
        last_pid = 1;
        goto inside;
    }
    if (last_pid >= next_safe) {
    inside:
        next_safe = MAX_PID;
    repeat:
        le = list;
        while ((le = list_next(le)) != list) {
            proc = le2proc(le, list_link);
            if (proc->pid == last_pid) {
                if (++ last_pid >= next_safe) {
                    if (last_pid >= MAX_PID) {
                        last_pid = 1;
                    }
                    next_safe = MAX_PID;
                    goto repeat;
                }
            }
            else if (proc->pid > last_pid && next_safe > proc->pid) {
                next_safe = proc->pid;
            }
        }
    }
    return last_pid;
}
```
这段代码通过遍历进程列表，确保分配的PID是唯一的。它使用last_pid和next_safe来跟踪和调整PID的分配，避免重复和超出范围的情况。每次分配PID时，都会检查当前PID是否已经被使用，如果没有，则返回该PID；否则，继续寻找下一个可用的PID。

这样，通过这个机制，每次调用get_pid都会尽力确保分配一个未被使用的唯一pid给新fork的线程。

#### 练习3：编写proc_run 函数（需要编码）
proc_run用于将指定的进程切换到CPU上运行。它的大致执行步骤包括：

 - 检查要切换的进程是否与当前正在运行的进程相同，如果相同则不需要切换。
 - 禁用中断。你可以使用/kern/sync/sync.h中定义好的宏local_intr_save(x)和local_intr_restore(x)来实现关、开中断。
 - 切换当前进程为要运行的进程。
 - 切换页表，以便使用新进程的地址空间。/libs/riscv.h中提供了lcr3(unsigned int cr3)函数，可实现修改CR3寄存器值的功能。
 - 实现上下文切换。/kern/process中已经预先编写好了switch.S，其中定义了switch_to()函数。可实现两个进程的context切换。
 - 允许中断。

请回答如下问题：

 - 在本实验的执行过程中，创建且运行了几个内核线程？

完成代码编写后，编译并运行代码：make qemu

如果可以得到如 附录A所示的显示内容（仅供参考，不是标准答案输出），则基本正确。


#### 扩展练习 Challenge：
 - 说明语句```local_intr_save(intr_flag);....local_intr_restore(intr_flag);``` 是如何实现开关中断的？

这段代码出现的位置主要集中在pmm.c和console.c中。在很多情况下需要使用开关中断，例如在进行原子操纵、临界区保护等不能被中断的操作时。通过阅读这些代码和两个函数的宏定义可以看到，local_intr_save 和 local_intr_restore 宏用于在执行某些操作之前保存当前的中断状态，并在操作完成后恢复之前的中断状态。
```
#define local_intr_save(x)      do { x = __intr_save(); } while (0)
#define local_intr_restore(x)   __intr_restore(x);

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
        intr_disable();
        return 1;
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
    }
}
```

`__intr_save()`这个函数用于保存当前的中断使能状态，并禁用中断。`__intr_restore()`用于根据之前保存的状态恢复中断使能。在代码中我们可以看到，`__intr_save()`先是读取RISC-V CPU的状态寄存器（sstatus）的值和SSTATUS_SIE位掩码。sstatus寄存器包含了关于当前CPU状态的信息，包括中断是否使能，而SIE则表示是否允许中断。如果中断是使能的，这个函数会清除sstatus寄存器中的SIE位，然后返回1，表示中断状态已被保存并且已禁用。否则返回0,表示中断之前是禁用的。`__intr_restore()`则是根据`__intr_save()`返回的flag值来恢复中断使能。
