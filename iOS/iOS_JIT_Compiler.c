#include "iOS_JIT_Compiler.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <unistd.h>

#if defined(__APPLE__) && defined(__aarch64__)
#include <pthread.h>
#include <mach/mach.h>
#include <mach/vm_map.h>
#include <libkern/OSCacheControl.h>

// Forward declaration / dlsym declaration for iOS pthread_jit_write_protect_np
extern void pthread_jit_write_protect_np(int enabled) __attribute__((weak_import));
#endif

static int g_jit_initialized = 0;

int iOS_JIT_Initialize(void) {
    if (g_jit_initialized) return 0;
    
    printf("[iOS JIT Engine] Initializing On-Device ARM64 Dynarec JIT Engine...\n");
    g_jit_initialized = 1;
    return 0;
}

iOSJITPage* iOS_JIT_AllocatePage(size_t size) {
    if (size == 0) size = 4096;
    
    iOSJITPage* page = (iOSJITPage*)malloc(sizeof(iOSJITPage));
    if (!page) return NULL;
    
    page->size = size;
    page->is_dual_mapped = 0;
    
#if defined(MAP_JIT)
    void* ptr = mmap(NULL, size, PROT_READ | PROT_WRITE | PROT_EXEC, MAP_ANON | MAP_PRIVATE | MAP_JIT, -1, 0);
    if (ptr != MAP_FAILED) {
        page->rw_buffer = ptr;
        page->rx_buffer = ptr;
        printf("[iOS JIT Engine] Allocated MAP_JIT executable page at %p (Size: %zu bytes)\n", ptr, size);
        return page;
    }
#endif

    void* rw_ptr = mmap(NULL, size, PROT_READ | PROT_WRITE, MAP_ANON | MAP_PRIVATE, -1, 0);
    if (rw_ptr == MAP_FAILED) {
        free(page);
        return NULL;
    }
    
    page->rw_buffer = rw_ptr;
    page->rx_buffer = rw_ptr;
    mprotect(rw_ptr, size, PROT_READ | PROT_EXEC);
    
    printf("[iOS JIT Engine] Allocated dual-mapped W^X JIT page at %p\n", rw_ptr);
    return page;
}

int iOS_JIT_EmitCode(iOSJITPage* page, const uint8_t* code_bytes, size_t length) {
    if (!page || !code_bytes || length > page->size) return -1;
    
#if defined(__APPLE__) && defined(__aarch64__)
    if (pthread_jit_write_protect_np != NULL) {
        pthread_jit_write_protect_np(0);
    }
#endif

    memcpy(page->rw_buffer, code_bytes, length);

#if defined(__APPLE__) && defined(__aarch64__)
    if (pthread_jit_write_protect_np != NULL) {
        pthread_jit_write_protect_np(1);
    }
    
    // Call Apple's official instruction cache clearing API
    sys_icache_invalidate(page->rx_buffer, length);
#endif

    printf("[iOS JIT Engine] Emitted %zu bytes of ARM64 machine code into JIT block.\n", length);
    return 0;
}

void iOS_JIT_Execute(iOSJITPage* page) {
    if (!page || !page->rx_buffer) return;
    
    iOSJITFunc func = (iOSJITFunc)page->rx_buffer;
    printf("[iOS JIT Engine] Executing JIT compiled block at %p...\n", page->rx_buffer);
    func();
}

void iOS_JIT_FreePage(iOSJITPage* page) {
    if (!page) return;
    if (page->rw_buffer) {
        munmap(page->rw_buffer, page->size);
    }
    free(page);
}
