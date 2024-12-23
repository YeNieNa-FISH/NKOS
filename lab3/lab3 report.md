### lab3:缺页异常和页面置换

#### 对实验报告的要求：
 - 基于markdown格式来完成，以文本方式为主
 - 填写各个基本练习中要求完成的报告内容
 - 完成实验后，请分析ucore_lab中提供的参考答案，并请在实验报告中说明你的实现与参考答案的区别
 - 列出你认为本实验中重要的知识点，以及与对应的OS原理中的知识点，并简要说明你对二者的含义，关系，差异等方面的理解（也可能出现实验中的知识点没有对应的原理知识点）
 - 列出你认为OS原理中很重要，但在实验中没有对应上的知识点
 
#### 练习0：填写已有实验

其实内容没那么多，就是把default_pmm.c的代码的first_fit改成实验2的best_fit。
#### 练习1：理解基于FIFO的页面替换算法（思考题）

FIFO作为先进先出的页面置换算法，基本思想是操作系统将内存中的所有页面维护在一个队列中，最近到达的页面放在队列的尾部，而最早到达的页面位于队列的前部。当需要替换一个页面时，位于队列前部的页面（即最老的页面）被选中进行替换。在我们的代码里，这个队列以双向链表的形式存在。pra_list_head_fifo用作FIFO页面替换算法的链表头。

在整个过程中，先由swap.c文件里的swap_init函数进行初始化。这个函数在初始化交换文件系统之后，在确保系统可以存储至少7页的情况下，设置交换管理器为swap_manager_fifo并进行初始化，之后便使用FIFO进行页面交换。初始化成功之后，将swap_init_ok设置为1,表示可以进行交换。

在往后需要分配页时，就会调用pmm.c的alloc_pages函数，在条件允许的情况下调用swap.c的swap_out函数。swap_out先用swap_out_victim将旧的页面从内存移动到磁盘，如果移动失败，再用map_swappable重新写回内存。

FIFO页面替换的过程如下：

- 检测到缺页异常之后，系统会调用dp_pgfault函数用于处理缺页异常。
- 先是调用find_vma尝试查找包含地址addr的虚拟内存区域，如果找到了有效的vma，就继续向下进行代码。
- 然后设置正确的页表项权限在上面三个步骤中，ret一直被设定为-E_INVAL，表示无效的参数（这里指虚拟内存无效），用于出现问题时返回。
- 接下来声明pte指针，用get_pte函数尝试获取页表项,如果页表不存在，就创建一个新的。
- 如果物理页面不存在，就调用pgdir_alloc_page函数在该页表项中分配一个页，同时设定这个页的虚拟地址和可以使用的权限。
- 如果页面存在，就可以尝试换页了。在确定交换管理其初始化成功的情况下，会调用swap_in函数，从磁盘交换区读取一个页面的内容到物理内存里。
- 成功读取之后，会调用page_insert建立虚拟地址addr和物理地址之间的映射，并用swap_map_swappable将page插入fifo的链表头中。
- 在一个页面从被换入到被换出的过程中，首先会经过_fifo_init_mm。这个函数初始化了初始化全局链表头pra_list_head_fifo并将mm->sm_priv指向pra_list_head_fifo的地址，从而可以通过内存控制结构mm_struct访问FIFO页面置换算法。
- 初始化之后，就可以进行页面的换入了。在_fifo_map_swappable这个函数里，先是从mm_struct结构中获取指向链表头的指针head，再获取获取指向页面结构中链表项的指针entry，接下来再用assert函数确保这两个指针不为空。最后使用list_add函数将页面链表项添加到链表的末尾。这里list_add是将节点加入到链表的最前端，即头节点的下一个位置。
- 若没有assert进行断言检查的话，假设出现了head或者entry存在空指针的情况，程序试图在空指针上执行操作，这将导致程序崩溃。如果head为空，list_add操作将会失败，因为它没有有效的链表头去添加新的元素。这可能会导致数据结构的不一致，从而在后续操作中引起不可预测的行为。如果entry是空指针，那么list_add将试图将一个空指针添加到链表中，这同样会损坏链表的结构。
- _fifo_swap_out_victim 函数的目的是从FIFO队列的前端移除最早到达的页面，并将其地址设置到提供的指针中。这个函数先获取链表头，并确保不为空之后，断言in_tick为0。
- 之后使用 list_prev函数找到队列头部的前一个元素，即最早到达的页面。
- 如果找到的元素不是头部本身（即队列不为空），则使用list_del函数从队列中移除该元素，并用le2page将该元素从链表项转换回页面结构指针。如果队列是空的，则将*ptr_page设置为NULL，表示没有节点可以删去。
- 如果没有le2page函数的话，因为我们获得的只是一个指向页面结构的指针，在之后要获取页面内容的时候会有很大的困难，我们将无法访问页面结构体中的其他成员，如页面状态、引用计数、物理地址。
  




#### 练习2：深入理解不同分页模式的工作原理（思考题）
get_pte()函数（位于`kern/mm/pmm.c`）用于在页表中查找或创建页表项，从而实现对指定线性地址对应的物理页的访问和映射操作。这在操作系统中的分页机制下，是实现虚拟内存与物理内存之间映射关系非常重要的内容。
 - get_pte()函数中有两段形式类似的代码， 结合sv32，sv39，sv48的异同，解释这两段代码为什么如此相像。
 - 目前get_pte()函数将页表项的查找和页表项的分配合并在一个函数里，你认为这种写法好吗？有没有必要把两个功能拆开？
 ```c
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
    /*
     *   PDX(la) = the index of page directory entry of VIRTUAL ADDRESS la.
     *   KADDR(pa) : takes a physical address and returns the corresponding
     * kernel virtual address.
     *   set_page_ref(page,1) : means the page be referenced by one time
     *   page2pa(page): get the physical address of memory which this (struct
     * Page *) page  manages
     *   struct Page * alloc_page() : allocation a page
     *   memset(void *s, char c, size_t n) : sets the first n bytes of the
     * memory area pointed by s
     *                                       to the specified value c.
     * DEFINEs:
     *   PTE_P           0x001                   // page table/directory entry
     * flags bit : Present
     *   PTE_W           0x002                   // page table/directory entry
     * flags bit : Writeable
     *   PTE_U           0x004                   // page table/directory entry
     * flags bit : User can access
     */
    pde_t *pdep1 = &pgdir[PDX1(la)];
    if (!(*pdep1 & PTE_V)) {
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
    }
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
//    pde_t *pdep0 = &((pde_t *)(PDE_ADDR(*pdep1)))[PDX0(la)];
    if (!(*pdep0 & PTE_V)) {
    	struct Page *page;
    	if (!create || (page = alloc_page()) == NULL) {
    		return NULL;
    	}
    	set_page_ref(page, 1);
    	uintptr_t pa = page2pa(page);
    	memset(KADDR(pa), 0, PGSIZE);
 //   	memset(pa, 0, PGSIZE);
    	*pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
}
```
回答：这些代码相似是因为它们是相同的逻辑，通过检查PTE_V标志位判断页表项，目录是否存在，如果不存在且允许创建，则分配一个新的页面，并设置相关的页表项。（对于SV32、SV39和SV48的页表层级和索引计算方式不同，但页表管理逻辑相同。多级每级管理是类似的。）将页表项的查找和分配合并在一个函数中简化了调用过程，易于理解。可以分开，分开后区分更加明确，灵活，错误处理也简便。

#### 练习3：给未被映射的地址映射上物理页（需要编程）

往内存里读页的时候，如果读不到想要的页，就会出现page fault。出现page fault后，会有一个中断状态指针tf，传到trap函数中处理。trap会调用trap_dispatch，trap_dispatch再调用pgfault_handler，最后调用do_pgfault。

在do_pgfault函数中，我们需要写的部分为“如何将想要的页换到内存里”。根据注释，我们需要实现：

1.将正确的磁盘页面内容加载到由该页面管理的内存中

```
if ((ret = swap_in(mm, addr, &page)) != 0) {
    cprintf("swap_in in do_pgfault failed\n");
    goto failed;
}   
```

2.设置物理地址<—>逻辑地址的映射

```
page_insert(mm->pgdir, page, addr, perm);
```

3.让页面可交换

```
swap_map_swappable(mm, addr, page, 1);
```

- 请描述页目录项（Page Directory Entry）和页表项（Page Table Entry）中组成部分对ucore实现页替换算法的潜在用处。
  
因为页替换算法需要将页在硬盘和内存之间来回转换，同时也需要物理地址和虚拟地址之间的对应关系，所以页表在这里起到巨大的作用。分页机制的实现，确保了虚拟地址和物理地址之间的对应关系，可以发现该地址是否是合法的，同时可以通过修改映射关系即可实现页替换操作。在实现页替换的换入时，它们可以帮助将某个虚拟地址对应的磁盘的一页内容读入到内存中；在换出时可以将某个虚拟页的内容写到磁盘中的某个位置。

同时，页表项和页目录项还有许多标记位，可以帮助页替换算法的实现。
```
// page table entry (PTE) fields
#define PTE_V     0x001 // Valid
#define PTE_R     0x002 // Read
#define PTE_W     0x004 // Write
#define PTE_X     0x008 // Execute
#define PTE_U     0x010 // User
#define PTE_G     0x020 // Global
#define PTE_A     0x040 // Accessed
#define PTE_D     0x080 // Dirty
#define PTE_SOFT  0x300 // Reserved for Software

#define PTE_PPN_SHIFT 10

#define PTE_TABLE(PTE) (((PTE) & (PTE_V | PTE_R | PTE_W | PTE_X)) == PTE_V)
// 宏，用于检查一个页表项是否表示一个有效的页表
```

- 如果ucore的缺页服务例程在执行过程中访问内存，出现了页访问异常，请问硬件要做哪些事情？

CPU首先会中断当前的执行，把异常的指令的地址、引起异常的虚拟地址和处理器的状态存储在寄存器中，然后根据异常类型（这里三缺页异常）查找异常向量表，跳转到异常处理程序do_pgfault进行处理。

- 数据结构Page的全局变量（其实是一个数组）的每一项与页表中的页目录项和页表项有无对应关系？如果有，其对应关系是啥？

pages数组与页表项有着直接的对应关系。在pages数组中，索引可以被视为物理页号。页表项中的物理页号部分通常指向pages数组中的一个Page结构体。假设有一个Page结构体在pages[42]位置，如果有一个PTE指向这个页帧，那么PTE的物理页号部分应该是42，当操作系统通过虚拟地址访问内存时，它就能通过PTE找到对应的Page结构体，进而获取页帧的状态信息。

而与页目录项的关系是间接的，PDE指向的页表是由一个或多个物理页帧组成的，而这些物理页帧在pages数组中有对应的Page结构体。页目录项与page数组在层级上是等价的，但两者没有直接关系。

#### 练习4：补充完成Clock页替换算法（需要编程）
通过之前的练习，相信大家对FIFO的页面替换算法有了更深入的了解，现在请在我们给出的框架上，填写代码，实现 Clock页替换算法（mm/swap_clock.c）。
请在实验报告中简要说明你的设计实现过程。请回答如下问题：
 - 比较Clock页替换算法和FIFO算法的不同。
 和fifo相同的初始化
```
clock_init_mm(struct mm_struct *mm)
{     
     /*LAB3 EXERCISE 4: YOUR CODE*/ 
     // 初始化pra_list_head为空链表
     // 初始化当前指针curr_ptr指向pra_list_head，表示当前页面替换位置为链表头
     // 将mm的私有成员指针指向pra_list_head，用于后续的页面替换算法操作
     list_init(&pra_list_head);
     curr_ptr = &pra_list_head;
     mm->sm_priv = &pra_list_head;
     cprintf(" curr_ptr %x in clock_init_mm\n",curr_ptr);
     return 0;
}
```

```
clock_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
    list_entry_t *entry=&(page->pra_page_link);
 
    assert(entry != NULL && curr_ptr != NULL);
    //record the page access situlation
    /*LAB3 EXERCISE 4: YOUR CODE*/ 
    // link the most recent arrival page at the back of the pra_list_head qeueue.
    // 将页面page插入到页面链表pra_list_head的末尾
    // 将页面的visited标志置为1，表示该页面已被访问
    list_add(curr_ptr, entry);
    page->visited=1;

    return 0;
}
```
```
_clock_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
{
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
         assert(head != NULL);
     assert(in_tick==0);
     /* Select the victim */
     //(1)  unlink the  earliest arrival page in front of pra_list_head qeueue
     //(2)  set the addr of addr of this page to ptr_page
     list_entry_t *p = head;
    while (1) {
        /*LAB3 EXERCISE 4: YOUR CODE*/ 
        // 编写代码
        // 遍历页面链表pra_list_head，查找最早未被访问的页面
        // 获取当前页面对应的Page结构指针
        // 如果当前页面未被访问，则将该页面从页面链表中删除，并将该页面指针赋值给ptr_page作为换出页面
        // 如果当前页面已被访问，则将visited标志置为0，表示该页面已被重新访问
        p=list_prev(p);
        if (p == head) {
             p = list_prev(p);
         }
         struct Page *ptr = le2page(p, pra_page_link);
         pte_t *pte = get_pte(mm -> pgdir, ptr -> pra_vaddr, 0);
         //获取页表项
         if (ptr->visited== 1) {
             ptr->visited=0;
         } 
         else 
         {
             *ptr_page = ptr;
             list_del(p);
             break;
         }
         
    }
    return 0;
}
```
回答：FIFO替换最久的页，可能替换掉常用的，clock淘汰掉了访问位为0的，可以减少不必要的页的替换


#### 练习5：阅读代码和实现手册，理解页表映射方式相关知识（思考题）
优势：

1.简化页表管理：采用大页的页表映射方式简化了页表的管理和操作。

2.提升访问速度：单一页表结构减少了页表查找的复杂性，从而加快了内存访问速度。

3.优化连续内存使用：大页能够更好地满足需要大量连续内存的应用程序，通过减少页表条目和TLB缺失来提升性能。

4.降低TLB缺失率：大页映射的内存范围更广，使得TLB中的单个条目能够覆盖更多的内存区域，从而减少TLB缺失的发生。

劣势：

1.内存利用率低：若应用程序仅使用大页的一部分，未使用的部分会造成内存浪费和碎片化。

2.适用性有限：大页不适合内存需求较小的应用程序，限制了其适用范围。

3.内存分配压力大：大页需要大量连续内存，可能导致内存分配困难和碎片化问题。

4.增加页错误风险：应用程序访问跨越多个大页的内存时，可能引发更多的页错误。

5.兼容性受限：并非所有硬件和操作系统都支持大页，存在兼容性问题。

6.安全风险增加：大页可能暴露更大范围的内存给恶意软件，增加安全风险。

7.置换成本高：置换大页会消耗更多的资源和性能，导致较大的性能损失。

8.标志位存储开销大：大页需要更多的标志位来记录相关信息，增加了存储空间的消耗。


#### 扩展练习 Challenge：实现不考虑实现开销和效率的LRU页替换算法（需要编程）
LRU 算法实现思路:

1. 数据结构

LRU 算法使用双向链表形式的队列来管理可交换的空闲页帧。pra_list_head 指针用于索引所有可交换的空闲页帧。当某个页帧被访问后，该页帧的指针 pra_page_link 会被更新到队列的尾部。当需要换出一个页帧时，选择队列首部指向的页帧进行置换，并更新队列。

2. 访问页帧的两种情况

当我们访问一个页帧时，可能会出现两种情况：

HIT：直接定位到相应页帧的物理地址进行读写操作。

FAULT：此时函数调用流程为（使用 LRU 替换算法）：

当物理内存足够时，调用 do_pgfault → _lru_map_swappable。

当物理内存不足时，调用 do_pgfault → _lru_swap_out_victim → _lru_map_swappable。

3. 具体实现

HIT 时的处理：

将此页帧的指针（已存在于队列中）移动到队列尾部，或者先删除然后添加到队列尾部。

处理函数为 _lru_hit_find，参数为 addr（申请内存时给的虚拟地址），通过比较 page 结构体的成员 pra_vaddr 来定位链表元素。

FAULT 时的处理：

当物理内存不足时，在 _lru_swap_out_victim 中从队列中删除换出去的页帧的 pra_page_link，然后在 _lru_map_swappable 中将换入的页帧的 pra_page_link 添加到队列尾部。

处理函数为 _lru_fault_find，参数为换入的 page 结构体指针，直接比较 pra_page_link 来定位链表元素。

4. 实现细节

HIT 处理函数：
```
static void _lru_hit_find(uintptr_t addr);
```
在 check 函数中每个测试用例下都调用 _lru_hit_find 函数来处理 HIT 时的操作。

FAULT 处理函数：
```
static void _lru_fault_find(struct Page *page);
```
在 _lru_map_swappable 和 _lru_swap_out_victim 函数中调用 _lru_fault_find 函数来处理 FAULT 时的操作。

全局变量 IsFault：
为了区分 HIT 和 FAULT 处理完成后的重新执行，设置全局变量 IsFault。在 FAULT 处理完成后，重新执行发生中断的代码时，通过 IsFault 来判断是否需要再次调用 _lru_hit_find。



