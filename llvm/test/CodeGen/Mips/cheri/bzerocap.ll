; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: %cheri_purecap_llc -O1 %s -o - | FileCheck %s
; ModuleID = 'cmpcap.c'
; This test assumes cheri128, since on 256 a 16 byte aligned pointer won't be expanded
; REQUIRES: cheri_is_128
source_filename = "cmpcap.c"

%struct.bigbuf = type { [5 x i8 addrspace(200)*] }

; Function Attrs: nounwind
; CHECK-LABEL: zero64
define void @zero64(%struct.bigbuf addrspace(200)* nocapture %out) local_unnamed_addr #0 {
; CHECK-LABEL: zero64:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    csc $cnull, $zero, 0($c3)
; CHECK-NEXT:    csc $cnull, $zero, 48($c3)
; CHECK-NEXT:    csc $cnull, $zero, 32($c3)
; CHECK-NEXT:    cjr $c17
; CHECK-NEXT:    csc $cnull, $zero, 16($c3)
entry:
  %.compoundliteral.sroa.0.0..sroa_cast1 = bitcast %struct.bigbuf addrspace(200)* %out to i8 addrspace(200)*
  call void @llvm.memset.p200i8.i64(i8 addrspace(200)* align 16 %.compoundliteral.sroa.0.0..sroa_cast1, i8 0, i64 64, i1 false)
  ret void
}

; Function Attrs: nounwind
; CHECK-LABEL: zero64_unaligned
define void @zero64_unaligned(%struct.bigbuf addrspace(200)* nocapture %out) local_unnamed_addr #0 {
; CHECK-LABEL: zero64_unaligned:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    csd $zero, $zero, 0($c3)
; CHECK-NEXT:    csd $zero, $zero, 56($c3)
; CHECK-NEXT:    csd $zero, $zero, 48($c3)
; CHECK-NEXT:    csd $zero, $zero, 40($c3)
; CHECK-NEXT:    csd $zero, $zero, 32($c3)
; CHECK-NEXT:    csd $zero, $zero, 24($c3)
; CHECK-NEXT:    csd $zero, $zero, 16($c3)
; CHECK-NEXT:    cjr $c17
; CHECK-NEXT:    csd $zero, $zero, 8($c3)
; If the buffer is not aligned to cap_size we cannot use csc:

entry:
  %.compoundliteral.sroa.0.0..sroa_cast1 = bitcast %struct.bigbuf addrspace(200)* %out to i8 addrspace(200)*
  call void @llvm.memset.p200i8.i64(i8 addrspace(200)* align 8 %.compoundliteral.sroa.0.0..sroa_cast1, i8 0, i64 64, i1 false)
  ret void
}

; Function Attrs: nounwind
; CHECK-LABEL: zero65
define void @zero65(%struct.bigbuf addrspace(200)* nocapture %out) local_unnamed_addr #0 {
; CHECK-LABEL: zero65:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    csc $cnull, $zero, 0($c3)
; CHECK-NEXT:    csb $zero, $zero, 64($c3)
; CHECK-NEXT:    csc $cnull, $zero, 48($c3)
; CHECK-NEXT:    csc $cnull, $zero, 32($c3)
; CHECK-NEXT:    cjr $c17
; CHECK-NEXT:    csc $cnull, $zero, 16($c3)
entry:
  %.compoundliteral.sroa.0.0..sroa_cast1 = bitcast %struct.bigbuf addrspace(200)* %out to i8 addrspace(200)*
  call void @llvm.memset.p200i8.i64(i8 addrspace(200)* align 16 %.compoundliteral.sroa.0.0..sroa_cast1, i8 0, i64 65, i1 false)
  ret void
}

; Function Attrs: nounwind
; CHECK-LABEL: zero66
define void @zero66(%struct.bigbuf addrspace(200)* nocapture %out) local_unnamed_addr #0 {
; CHECK-LABEL: zero66:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    csc $cnull, $zero, 0($c3)
; CHECK-NEXT:    csh $zero, $zero, 64($c3)
; CHECK-NEXT:    csc $cnull, $zero, 48($c3)
; CHECK-NEXT:    csc $cnull, $zero, 32($c3)
; CHECK-NEXT:    cjr $c17
; CHECK-NEXT:    csc $cnull, $zero, 16($c3)
entry:
  %.compoundliteral.sroa.0.0..sroa_cast1 = bitcast %struct.bigbuf addrspace(200)* %out to i8 addrspace(200)*
  call void @llvm.memset.p200i8.i64(i8 addrspace(200)* align 16 %.compoundliteral.sroa.0.0..sroa_cast1, i8 0, i64 66, i1 false)
  ret void
}

; Function Attrs: nounwind
; CHECK-LABEL: zero67
define void @zero67(%struct.bigbuf addrspace(200)* nocapture %out) local_unnamed_addr #0 {
; CHECK-LABEL: zero67:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    csc $cnull, $zero, 0($c3)
; CHECK-NEXT:    cincoffset $c1, $c3, 63
; CHECK-NEXT:    csw $zero, $zero, 0($c1)
; CHECK-NEXT:    csc $cnull, $zero, 48($c3)
; CHECK-NEXT:    csc $cnull, $zero, 32($c3)
; CHECK-NEXT:    cjr $c17
; CHECK-NEXT:    csc $cnull, $zero, 16($c3)
entry:
  %.compoundliteral.sroa.0.0..sroa_cast1 = bitcast %struct.bigbuf addrspace(200)* %out to i8 addrspace(200)*
  call void @llvm.memset.p200i8.i64(i8 addrspace(200)* align 16 %.compoundliteral.sroa.0.0..sroa_cast1, i8 0, i64 67, i1 false)
  ret void
}

; Function Attrs: nounwind
; CHECK-LABEL: zero68
define void @zero68(%struct.bigbuf addrspace(200)* nocapture %out) local_unnamed_addr #0 {
; CHECK-LABEL: zero68:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    csc $cnull, $zero, 0($c3)
; CHECK-NEXT:    csw $zero, $zero, 64($c3)
; CHECK-NEXT:    csc $cnull, $zero, 48($c3)
; CHECK-NEXT:    csc $cnull, $zero, 32($c3)
; CHECK-NEXT:    cjr $c17
; CHECK-NEXT:    csc $cnull, $zero, 16($c3)
entry:
  %.compoundliteral.sroa.0.0..sroa_cast1 = bitcast %struct.bigbuf addrspace(200)* %out to i8 addrspace(200)*
  call void @llvm.memset.p200i8.i64(i8 addrspace(200)* align 16 %.compoundliteral.sroa.0.0..sroa_cast1, i8 0, i64 68, i1 false)
  ret void
}

; Function Attrs: nounwind
; CHECK-LABEL: zero69
define void @zero69(%struct.bigbuf addrspace(200)* nocapture %out) local_unnamed_addr #0 {
; CHECK-LABEL: zero69:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    csc $cnull, $zero, 0($c3)
; CHECK-NEXT:    cincoffset $c1, $c3, 61
; CHECK-NEXT:    csd $zero, $zero, 0($c1)
; CHECK-NEXT:    csc $cnull, $zero, 48($c3)
; CHECK-NEXT:    csc $cnull, $zero, 32($c3)
; CHECK-NEXT:    cjr $c17
; CHECK-NEXT:    csc $cnull, $zero, 16($c3)
entry:
  %.compoundliteral.sroa.0.0..sroa_cast1 = bitcast %struct.bigbuf addrspace(200)* %out to i8 addrspace(200)*
  call void @llvm.memset.p200i8.i64(i8 addrspace(200)* align 16 %.compoundliteral.sroa.0.0..sroa_cast1, i8 0, i64 69, i1 false)
  ret void
}

; Function Attrs: nounwind
; CHECK-LABEL: zero70
define void @zero70(%struct.bigbuf addrspace(200)* nocapture %out) local_unnamed_addr #0 {
; CHECK-LABEL: zero70:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    csc $cnull, $zero, 0($c3)
; CHECK-NEXT:    cincoffset $c1, $c3, 62
; CHECK-NEXT:    csd $zero, $zero, 0($c1)
; CHECK-NEXT:    csc $cnull, $zero, 48($c3)
; CHECK-NEXT:    csc $cnull, $zero, 32($c3)
; CHECK-NEXT:    cjr $c17
; CHECK-NEXT:    csc $cnull, $zero, 16($c3)
entry:
  %.compoundliteral.sroa.0.0..sroa_cast1 = bitcast %struct.bigbuf addrspace(200)* %out to i8 addrspace(200)*
  call void @llvm.memset.p200i8.i64(i8 addrspace(200)* align 16 %.compoundliteral.sroa.0.0..sroa_cast1, i8 0, i64 70, i1 false)
  ret void
}

; Function Attrs: nounwind
; CHECK-LABEL: zero71
define void @zero71(%struct.bigbuf addrspace(200)* nocapture %out) local_unnamed_addr #0 {
; CHECK-LABEL: zero71:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    csc $cnull, $zero, 0($c3)
; CHECK-NEXT:    cincoffset $c1, $c3, 63
; CHECK-NEXT:    csd $zero, $zero, 0($c1)
; CHECK-NEXT:    csc $cnull, $zero, 48($c3)
; CHECK-NEXT:    csc $cnull, $zero, 32($c3)
; CHECK-NEXT:    cjr $c17
; CHECK-NEXT:    csc $cnull, $zero, 16($c3)
entry:
  %.compoundliteral.sroa.0.0..sroa_cast1 = bitcast %struct.bigbuf addrspace(200)* %out to i8 addrspace(200)*
  call void @llvm.memset.p200i8.i64(i8 addrspace(200)* align 16 %.compoundliteral.sroa.0.0..sroa_cast1, i8 0, i64 71, i1 false)
; We can't do two aligned stores for the end region here, so instead do an
; unaligned doubleword store.
  ret void
}

; Function Attrs: nounwind
; CHECK-LABEL: zero72
define void @zero72(%struct.bigbuf addrspace(200)* nocapture %out) local_unnamed_addr #0 {
; CHECK-LABEL: zero72:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    csc $cnull, $zero, 0($c3)
; CHECK-NEXT:    csd $zero, $zero, 64($c3)
; CHECK-NEXT:    csc $cnull, $zero, 48($c3)
; CHECK-NEXT:    csc $cnull, $zero, 32($c3)
; CHECK-NEXT:    cjr $c17
; CHECK-NEXT:    csc $cnull, $zero, 16($c3)
entry:
  %.compoundliteral.sroa.0.0..sroa_cast1 = bitcast %struct.bigbuf addrspace(200)* %out to i8 addrspace(200)*
  call void @llvm.memset.p200i8.i64(i8 addrspace(200)* align 16 %.compoundliteral.sroa.0.0..sroa_cast1, i8 0, i64 72, i1 false)
  ret void
}

; Function Attrs: nounwind
; CHECK-LABEL: zero73
define void @zero73(%struct.bigbuf addrspace(200)* nocapture %out) local_unnamed_addr #0 {
; CHECK-LABEL: zero73:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    csc $cnull, $zero, 0($c3)
; CHECK-NEXT:    csb $zero, $zero, 72($c3)
; CHECK-NEXT:    csd $zero, $zero, 64($c3)
; CHECK-NEXT:    csc $cnull, $zero, 48($c3)
; CHECK-NEXT:    csc $cnull, $zero, 32($c3)
; CHECK-NEXT:    cjr $c17
; CHECK-NEXT:    csc $cnull, $zero, 16($c3)
entry:
  %.compoundliteral.sroa.0.0..sroa_cast1 = bitcast %struct.bigbuf addrspace(200)* %out to i8 addrspace(200)*
  call void @llvm.memset.p200i8.i64(i8 addrspace(200)* align 16 %.compoundliteral.sroa.0.0..sroa_cast1, i8 0, i64 73, i1 false)
  ret void
}

; Function Attrs: nounwind
; CHECK-LABEL: zero74
define void @zero74(%struct.bigbuf addrspace(200)* nocapture %out) local_unnamed_addr #0 {
; CHECK-LABEL: zero74:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    csc $cnull, $zero, 0($c3)
; CHECK-NEXT:    csh $zero, $zero, 72($c3)
; CHECK-NEXT:    csd $zero, $zero, 64($c3)
; CHECK-NEXT:    csc $cnull, $zero, 48($c3)
; CHECK-NEXT:    csc $cnull, $zero, 32($c3)
; CHECK-NEXT:    cjr $c17
; CHECK-NEXT:    csc $cnull, $zero, 16($c3)
entry:
  %.compoundliteral.sroa.0.0..sroa_cast1 = bitcast %struct.bigbuf addrspace(200)* %out to i8 addrspace(200)*
  call void @llvm.memset.p200i8.i64(i8 addrspace(200)* align 16 %.compoundliteral.sroa.0.0..sroa_cast1, i8 0, i64 74, i1 false)
  ret void
}

; Function Attrs: nounwind
; CHECK-LABEL: zero75
define void @zero75(%struct.bigbuf addrspace(200)* nocapture %out) local_unnamed_addr #0 {
; CHECK-LABEL: zero75:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    csc $cnull, $zero, 0($c3)
; CHECK-NEXT:    cincoffset $c1, $c3, 71
; CHECK-NEXT:    csw $zero, $zero, 0($c1)
; CHECK-NEXT:    csd $zero, $zero, 64($c3)
; CHECK-NEXT:    csc $cnull, $zero, 48($c3)
; CHECK-NEXT:    csc $cnull, $zero, 32($c3)
; CHECK-NEXT:    cjr $c17
; CHECK-NEXT:    csc $cnull, $zero, 16($c3)
entry:
  %.compoundliteral.sroa.0.0..sroa_cast1 = bitcast %struct.bigbuf addrspace(200)* %out to i8 addrspace(200)*
  call void @llvm.memset.p200i8.i64(i8 addrspace(200)* align 16 %.compoundliteral.sroa.0.0..sroa_cast1, i8 0, i64 75, i1 false)
  ret void
}

; Function Attrs: nounwind
; CHECK-LABEL: zero76
define void @zero76(%struct.bigbuf addrspace(200)* nocapture %out) local_unnamed_addr #0 {
; CHECK-LABEL: zero76:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    csc $cnull, $zero, 0($c3)
; CHECK-NEXT:    csw $zero, $zero, 72($c3)
; CHECK-NEXT:    csd $zero, $zero, 64($c3)
; CHECK-NEXT:    csc $cnull, $zero, 48($c3)
; CHECK-NEXT:    csc $cnull, $zero, 32($c3)
; CHECK-NEXT:    cjr $c17
; CHECK-NEXT:    csc $cnull, $zero, 16($c3)
entry:
  %.compoundliteral.sroa.0.0..sroa_cast1 = bitcast %struct.bigbuf addrspace(200)* %out to i8 addrspace(200)*
  call void @llvm.memset.p200i8.i64(i8 addrspace(200)* align 16 %.compoundliteral.sroa.0.0..sroa_cast1, i8 0, i64 76, i1 false)
  ret void
}

; Function Attrs: nounwind
; CHECK-LABEL: zero77
define void @zero77(%struct.bigbuf addrspace(200)* nocapture %out) local_unnamed_addr #0 {
; CHECK-LABEL: zero77:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    csc $cnull, $zero, 0($c3)
; CHECK-NEXT:    cincoffset $c1, $c3, 69
; CHECK-NEXT:    csd $zero, $zero, 0($c1)
; CHECK-NEXT:    csd $zero, $zero, 64($c3)
; CHECK-NEXT:    csc $cnull, $zero, 48($c3)
; CHECK-NEXT:    csc $cnull, $zero, 32($c3)
; CHECK-NEXT:    cjr $c17
; CHECK-NEXT:    csc $cnull, $zero, 16($c3)
entry:
  %.compoundliteral.sroa.0.0..sroa_cast1 = bitcast %struct.bigbuf addrspace(200)* %out to i8 addrspace(200)*
  call void @llvm.memset.p200i8.i64(i8 addrspace(200)* align 16 %.compoundliteral.sroa.0.0..sroa_cast1, i8 0, i64 77, i1 false)
  ret void
}

; Function Attrs: nounwind
; CHECK-LABEL: zero78
define void @zero78(%struct.bigbuf addrspace(200)* nocapture %out) local_unnamed_addr #0 {
; CHECK-LABEL: zero78:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    csc $cnull, $zero, 0($c3)
; CHECK-NEXT:    cincoffset $c1, $c3, 70
; CHECK-NEXT:    csd $zero, $zero, 0($c1)
; CHECK-NEXT:    csd $zero, $zero, 64($c3)
; CHECK-NEXT:    csc $cnull, $zero, 48($c3)
; CHECK-NEXT:    csc $cnull, $zero, 32($c3)
; CHECK-NEXT:    cjr $c17
; CHECK-NEXT:    csc $cnull, $zero, 16($c3)
entry:
  %.compoundliteral.sroa.0.0..sroa_cast1 = bitcast %struct.bigbuf addrspace(200)* %out to i8 addrspace(200)*
  call void @llvm.memset.p200i8.i64(i8 addrspace(200)* align 16 %.compoundliteral.sroa.0.0..sroa_cast1, i8 0, i64 78, i1 false)
  ret void
}

; Function Attrs: nounwind
; CHECK-LABEL: zero79
define void @zero79(%struct.bigbuf addrspace(200)* nocapture %out) local_unnamed_addr #0 {
; CHECK-LABEL: zero79:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    csc $cnull, $zero, 0($c3)
; CHECK-NEXT:    cincoffset $c1, $c3, 71
; CHECK-NEXT:    csd $zero, $zero, 0($c1)
; CHECK-NEXT:    csd $zero, $zero, 64($c3)
; CHECK-NEXT:    csc $cnull, $zero, 48($c3)
; CHECK-NEXT:    csc $cnull, $zero, 32($c3)
; CHECK-NEXT:    cjr $c17
; CHECK-NEXT:    csc $cnull, $zero, 16($c3)
entry:
  %.compoundliteral.sroa.0.0..sroa_cast1 = bitcast %struct.bigbuf addrspace(200)* %out to i8 addrspace(200)*
  call void @llvm.memset.p200i8.i64(i8 addrspace(200)* align 16 %.compoundliteral.sroa.0.0..sroa_cast1, i8 0, i64 79, i1 false)
  ret void
}

; Function Attrs: argmemonly nounwind
declare void @llvm.memset.p200i8.i64(i8 addrspace(200)* nocapture writeonly, i8, i64, i1) #1

attributes #0 = { nounwind }
attributes #1 = { argmemonly nounwind }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 2}
!2 = !{!"clang version 7.0.0 (ssh://dc552@vica.cl.cam.ac.uk:/home/dc552/CHERISDK/llvm/tools/clang f77d651cc0da68f4b1dfb357d7212fbadc5e1725) (ssh://dc552@vica.cl.cam.ac.uk:/home/dc552/CHERISDK/llvm 726657ee8ccc6ad3a8c0b2b189d9db24171c3f8f)"}
