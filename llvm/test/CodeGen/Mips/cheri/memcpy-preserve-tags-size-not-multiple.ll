; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: %cheri128_purecap_llc -o - -O0 -verify-machineinstrs %s | FileCheck %s -check-prefixes CHECK

declare void @llvm.memmove.p200i8.p200i8.i64(i8 addrspace(200)* nocapture, i8 addrspace(200)* nocapture readonly, i64, i1) addrspace(200) #1
declare void @llvm.memcpy.p200i8.p200i8.i64(i8 addrspace(200)* nocapture, i8 addrspace(200)* nocapture readonly, i64, i1) addrspace(200) #1

define void @test_string_memmove(i8 addrspace(200)* %dst, i8 addrspace(200)* %src) addrspace(200) #0 {
; CHECK-LABEL: test_string_memmove:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    clc [[CAP0:\$c[0-9]+]], $zero, 0($c4)
; CHECK-NEXT:    clc [[CAP16:\$c[0-9]+]], $zero, 16($c4)
; CHECK-NEXT:    clc [[CAP32:\$c[0-9]+]], $zero, 32($c4)
; CHECK-NEXT:    clc [[CAP48:\$c[0-9]+]], $zero, 48($c4)
; CHECK-NEXT:    cld $1, $zero, 64($c4)
; CHECK-NEXT:    clw $2, $zero, 72($c4)
; CHECK-NEXT:    clb $3, $zero, 76($c4)
; CHECK-NEXT:    csb $3, $zero, 76($c3)
; CHECK-NEXT:    csw $2, $zero, 72($c3)
; CHECK-NEXT:    csd $1, $zero, 64($c3)
; CHECK-NEXT:    csc [[CAP48]], $zero, 48($c3)
; CHECK-NEXT:    csc [[CAP32]], $zero, 32($c3)
; CHECK-NEXT:    csc [[CAP16]], $zero, 16($c3)
; CHECK-NEXT:    csc [[CAP0]], $zero, 0($c3)
; CHECK-NEXT:    cjr $c17
; CHECK-NEXT:    nop
entry:
  call void @llvm.memmove.p200i8.p200i8.i64(i8 addrspace(200)* align 32 %dst, i8 addrspace(200)* align 32 %src, i64 77, i1 false) #2
  ret void
}

define void @test_string_memcpy(i8 addrspace(200)* %dst, i8 addrspace(200)* %src) addrspace(200) #0 {
; CHECK-LABEL: test_string_memcpy:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    clc [[CAP0:\$c[0-9]+]], $zero, 0($c4)
; CHECK-NEXT:    csc [[CAP0]], $zero, 0($c3)
; CHECK-NEXT:    clb $1, $zero, 76($c4)
; CHECK-NEXT:    csb $1, $zero, 76($c3)
; CHECK-NEXT:    clw $1, $zero, 72($c4)
; CHECK-NEXT:    csw $1, $zero, 72($c3)
; CHECK-NEXT:    cld $1, $zero, 64($c4)
; CHECK-NEXT:    csd $1, $zero, 64($c3)
; CHECK-NEXT:    clc [[CAP48:\$c[0-9]+]], $zero, 48($c4)
; CHECK-NEXT:    csc [[CAP48]], $zero, 48($c3)
; CHECK-NEXT:    clc [[CAP32:\$c[0-9]+]], $zero, 32($c4)
; CHECK-NEXT:    csc [[CAP32]], $zero, 32($c3)
; CHECK-NEXT:    clc [[CAP16:\$c[0-9]+]], $zero, 16($c4)
; CHECK-NEXT:    csc [[CAP16]], $zero, 16($c3)
; CHECK-NEXT:    cjr $c17
; CHECK-NEXT:    nop
entry:
  call void @llvm.memcpy.p200i8.p200i8.i64(i8 addrspace(200)* align 32 %dst, i8 addrspace(200)* align 32 %src, i64 77, i1 false) #2
  ret void
}

; Function Attrs: argmemonly nounwind
attributes #0 = { nounwind }
attributes #1 = { argmemonly nounwind }
attributes #2 = { "frontend-memtransfer-type"="'struct Test'" "must-preserve-cheri-tags" }
