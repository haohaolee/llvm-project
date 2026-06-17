# RUN: llvm-mc -filetype=obj -triple=mips-unknown-linux -mcpu=mips32r2 %s -o - \
# RUN:   | llvm-objdump --no-print-imm-hex -dr - \
# RUN:   | FileCheck %s
# RUN: llvm-mc -filetype=obj -triple=mips-unknown-linux -mcpu=mips32r2 \
# RUN:   -mc-relax-all %s -o - \
# RUN:   | llvm-objdump --no-print-imm-hex -dr - \
# RUN:   | FileCheck %s --check-prefixes=CHECK,RELAX

.option pic2

.rdata
backward_local:
  .asciz "backward"

.text
forward_local_plain:
  la $4, forward_local
# CHECK-LABEL: <forward_local_plain>:
# CHECK:      lw      $4, 0($gp)
# CHECK-NEXT: R_MIPS_GOT16
# CHECK:      addiu   $4, $4,
# CHECK-NEXT: R_MIPS_LO16

backward_local_plain:
  la $4, backward_local
# CHECK-LABEL: <backward_local_plain>:
# CHECK:      lw      $4, 0($gp)
# CHECK-NEXT: R_MIPS_GOT16
# CHECK:      addiu   $4, $4,
# CHECK-NEXT: R_MIPS_LO16

backward_plus_const:
  la $4, backward_local + 8
# CHECK-LABEL: <backward_plus_const>:
# CHECK:      lw      $4, 0($gp)
# CHECK-NEXT: R_MIPS_GOT16
# CHECK:      addiu   $4, $4, 8
# CHECK-NEXT: R_MIPS_LO16

undefined_external_plain:
  la $4, ext_undef
# CHECK-LABEL: <undefined_external_plain>:
# CHECK:      lw      $4, 0($gp)
# CHECK-NEXT: R_MIPS_GOT16 ext_undef
# CHECK-NOT:  R_MIPS_LO16
# RELAX-NEXT: addiu   $4, $4, 0
# CHECK-NOT:  R_MIPS_LO16

undefined_external_plus_const:
  la $4, ext_undef + 8
# CHECK-LABEL: <undefined_external_plus_const>:
# CHECK:      lw      $4, 0($gp)
# CHECK-NEXT: R_MIPS_GOT16 ext_undef
# CHECK-NOT:  R_MIPS_LO16
# CHECK:      addiu   $4, $4, 8
# CHECK-NOT:  R_MIPS_LO16

later_global_plain:
  la $4, global_later
# CHECK-LABEL: <later_global_plain>:
# CHECK:      lw      $4, 0($gp)
# CHECK-NEXT: R_MIPS_GOT16 global_later
# CHECK-NOT:  R_MIPS_LO16
# RELAX-NEXT: addiu   $4, $4, 0
# CHECK-NOT:  R_MIPS_LO16

later_global_plus_const:
  la $4, global_later + 8
# CHECK-LABEL: <later_global_plus_const>:
# CHECK:      lw      $4, 0($gp)
# CHECK-NEXT: R_MIPS_GOT16 global_later
# CHECK-NOT:  R_MIPS_LO16
# CHECK:      addiu   $4, $4, 8
# CHECK-NOT:  R_MIPS_LO16

later_weak_plain:
  la $4, weak_later
# CHECK-LABEL: <later_weak_plain>:
# CHECK:      lw      $4, 0($gp)
# CHECK-NEXT: R_MIPS_GOT16 weak_later
# CHECK-NOT:  R_MIPS_LO16
# RELAX-NEXT: addiu   $4, $4, 0
# CHECK-NOT:  R_MIPS_LO16

later_weak_plus_const:
  la $4, weak_later + 8
# CHECK-LABEL: <later_weak_plus_const>:
# CHECK:      lw      $4, 0($gp)
# CHECK-NEXT: R_MIPS_GOT16 weak_later
# CHECK-NOT:  R_MIPS_LO16
# CHECK:      addiu   $4, $4, 8
# CHECK-NOT:  R_MIPS_LO16

forward_dot_l_plain:
  la $4, .Lforward_local
# CHECK-LABEL: <forward_dot_l_plain>:
# CHECK:      lw      $4, 0($gp)
# CHECK-NEXT: R_MIPS_GOT16
# CHECK:      addiu   $4, $4,
# CHECK-NEXT: R_MIPS_LO16

forward_dollar_plain:
  la $4, $forward_local
# CHECK-LABEL: <forward_dollar_plain>:
# CHECK:      lw      $4, 0($gp)
# CHECK-NEXT: R_MIPS_GOT16
# CHECK:      addiu   $4, $4,
# CHECK-NEXT: R_MIPS_LO16

forward_plus_const:
  la $4, forward_local_plus_const + 8
# CHECK-LABEL: <forward_plus_const>:
# CHECK:      lw      $4, 0($gp)
# CHECK-NEXT: R_MIPS_GOT16
# CHECK:      addiu   $4, $4,
# CHECK-NEXT: R_MIPS_LO16

forward_local_with_base:
  la $4, forward_local_with_base_sym($4)
# CHECK-LABEL: <forward_local_with_base>:
# CHECK:      lw      $1, 0($gp)
# CHECK-NEXT: R_MIPS_GOT16
# CHECK:      addiu   $1, $1,
# CHECK-NEXT: R_MIPS_LO16
# CHECK:      addu    $4, $1, $4

.rdata
forward_local:
  .asciz "forward"

.globl global_later
global_later:
  .asciz "global"

.weak weak_later
weak_later:
  .asciz "weak"

.Lforward_local:
  .asciz "dot-l"

$forward_local:
  .asciz "dollar"

forward_local_plus_const:
  .asciz "plus-const"

forward_local_with_base_sym:
  .asciz "with-base"
