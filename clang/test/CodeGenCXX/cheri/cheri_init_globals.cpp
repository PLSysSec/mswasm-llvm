// NOTE: Assertions have been autogenerated by utils/update_cc_test_checks.py UTC_ARGS: --function-signature
// REQUIRES: mips-registered-target, riscv-registered-target
/// Check that cheri_init_globals.h can be compiled without warnings as C++ (MIPS&RISC-V)
/// We turn on -Wsystem-headers for this check but disable warnings that would be annoying to fix
// RUN: %cheri_purecap_cc1 %s -o /dev/null -Wall -Wextra -Wpedantic -Wsystem-headers -verify -emit-obj
// RUN: %riscv64_cheri_purecap_cc1 %s -o /dev/null -Wall -Wextra -Wpedantic -Wsystem-headers -verify -emit-obj
// RUN: %riscv32_cheri_purecap_cc1 %s -o /dev/null -Wall -Wextra -Wpedantic -Wsystem-headers -verify -emit-obj
/// Check that C also doesn't emit any warnings (and generates the same code as C++)
// RUN: %cheri_purecap_cc1 -xc %s -o /dev/null -Wall -Wextra -Wpedantic -Wsystem-headers -verify -emit-obj
// RUN: %riscv64_cheri_purecap_cc1 -xc %s -o /dev/null -Wall -Wextra -Wpedantic -Wsystem-headers -verify -emit-obj
// RUN: %riscv32_cheri_purecap_cc1 -xc %s -o /dev/null -Wall -Wextra -Wpedantic -Wsystem-headers -verify -emit-obj

// expected-no-diagnostics
#include <cheri_init_globals.h>

#ifdef __cplusplus
extern "C"
#endif
void _start(void);

#if defined(__mips__)
DEFINE_CHERI_START_FUNCTION(_start)
#endif

void _start(void) {
  cheri_init_globals();
}
