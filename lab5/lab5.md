### 练习

对实验报告的要求：
 - 基于markdown格式来完成，以文本方式为主
 - 填写各个基本练习中要求完成的报告内容
 - 列出你认为本实验中重要的知识点，以及与对应的OS原理中的知识点，并简要说明你对二者的含义，关系，差异等方面的理解（也可能出现实验中的知识点没有对应的原理知识点）
 - 列出你认为OS原理中很重要，但在实验中没有对应上的知识点
 
#### 练习0：填写已有实验
本实验依赖实验2/3/4。请把你做的实验2/3/4的代码填入本实验中代码中有“LAB2”/“LAB3”/“LAB4”的注释相应部分。注意：为了能够正确执行lab5的测试应用程序，可能需对已完成的实验2/3/4的代码进行进一步改进。


#### 练习2：为父进程复制自己的内存空间给子进程（需要编码）
创创建子进程的函数do_fork在执行中将拷贝当前进程（即父进程）的用户内存地址空间中的合法内容到新进程中（子进程），完成内存资源的复制。具体是通过copy_range函数（位于kern/mm/pmm.c中）实现的，请补充copy_range的实现，确保能够正确执行。

请在实验报告中简要说明你的设计实现过程。
 - 如何设计实现Copy on Write机制？给出概要设计，鼓励给出详细设计。

 ```
            * (1) find src_kvaddr: the kernel virtual address of page
             * (2) find dst_kvaddr: the kernel virtual address of npage
             * (3) memory copy from src_kvaddr to dst_kvaddr, size is PGSIZE
             * (4) build the map of phy addr of  nage with the linear addr start
             */
            //1.找寻父进程的内核虚拟页地址
            void * kva_src = page2kva(page);
            //2.找寻子进程的内核虚拟页地址   
            void * kva_dst = page2kva(npage);
            //3.复制父进程内容到子进程 
            memcpy(kva_dst, kva_src, PGSIZE);
            //4.建立物理地址与子进程的页地址起始位置的映射关系
            ret = page_insert(to, npage, start, perm);
```
回答：找到父子进程的内核虚拟地址，然后拷贝父进程的到子进程中，最后为子进程当前分配这一物理页映射上对应的在子进程虚拟地址空间里的一个虚拟页。
回答：给新对象一个指针指向内存，该页面设置为只读，在对这段内容进行写操作时候便会引发Page Fault，这时候我们便知道这段内容是需要去写的，然后重新为进程分配页面、拷贝页面内容、建立映射关系