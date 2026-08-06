#ifndef IOS_JIT_COMPILER_H
#define IOS_JIT_COMPILER_H

#include <stddef.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

// JIT Compiler Memory Page Structure
typedef struct {
    void* rx_buffer;          // Executable (Read-Execute) memory page
    void* rw_buffer;          // Writable (Read-Write) memory page
    size_t size;              // Allocation size
    int is_dual_mapped;       // 1 if dual-mapped (mach vm_remap), 0 if pthread_jit managed
} iOSJITPage;

/**
 * Initialize On-Device iOS JIT Compiler Subsystem.
 * Uses Mach VM dual-mapping or pthread_jit_write_protect_np.
 */
int iOS_JIT_Initialize(void);

/**
 * Allocate a W^X compliant executable JIT memory page on iOS.
 */
iOSJITPage* iOS_JIT_AllocatePage(size_t size);

/**
 * Emit x86/x64 translated instruction bytes into iOS JIT executable page.
 */
int iOS_JIT_EmitCode(iOSJITPage* page, const uint8_t* code_bytes, size_t length);

/**
 * Execute compiled JIT function block on ARM64 hardware.
 */
typedef void (*iOSJITFunc)(void);
void iOS_JIT_Execute(iOSJITPage* page);

/**
 * Free JIT memory page.
 */
void iOS_JIT_FreePage(iOSJITPage* page);

#ifdef __cplusplus
}
#endif

#endif // IOS_JIT_COMPILER_H
