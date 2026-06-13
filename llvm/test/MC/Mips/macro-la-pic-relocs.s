# RUN: llvm-mc -filetype=obj -triple=mips-unknown-linux -mcpu=mips32r2 %s \
# RUN:   | llvm-readobj -r - | FileCheck %s

.option pic2
.text
  la $2, forward_local
  la $3, external_symbol
  la $4, late_global
  la $5, late_weak

.globl late_global
.weak late_weak

.rodata
forward_local:
  .word 0
late_global:
  .word 0
late_weak:
  .word 0

# CHECK-LABEL: Section ({{[0-9]+}}) .rel.text {
# CHECK-NEXT:    0x0 R_MIPS_GOT16 .rodata
# CHECK-NEXT:    0x4 R_MIPS_LO16 .rodata
# CHECK-NEXT:    0x8 R_MIPS_GOT16 external_symbol
# CHECK-NEXT:    0x10 R_MIPS_GOT16 late_global
# CHECK-NEXT:    0x18 R_MIPS_GOT16 late_weak
# CHECK-NEXT:  }
