#ifndef __KERN_MM_BUDDY_PMM_H__
#define  __KERN_MM_BUDDY_PMM_H__

#include <pmm.h>

extern const struct pmm_manager buddy_pmm_manager;

#define LEFT_LEAF(index) ((index) * 2 + 1)
#define RIGHT_LEAF(index) ((index) * 2 + 2)
#define PARENT(index) ( ( (index) + 1 ) / 2 - 1 )

#define IS_POWER_OF_2(x) (!( (x) & ((x) - 1) ))
#define MAX(a, b) ((a) > (b) ? (a) : (b))

#define MAX_NUM_BUDDY_ZONE 10

#define KADDR(pa)                                                \
    ({                                                           \
        uintptr_t __m_pa = (pa);                                 \
        size_t __m_ppn = PPN(__m_pa);                            \
        if (__m_ppn >= npage) {                                  \
            panic("KADDR called with invalid pa %08lx", __m_pa); \
        }                                                        \
        (void *)(__m_pa + va_pa_offset);                         \
    })
    
#endif 

static inline void *
page2kva(struct Page *page) {
    return KADDR(page2pa(page));
}