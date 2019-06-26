; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; This test caused assertion failures in MIPS DAG->DAG Pattern Instruction Selection
; RUN: %cheri_purecap_llc %s -o - | %cheri_FileCheck %s
; we should really be getting an error when compiling this with n64 ABI (alloca in AS 200)
; RUNTODO: not %cheri_llc -target-abi n64 < %s 2>&1 | FileCheck %s -check-prefix BAD-ABI
; BAD-ABI: error: abc

%struct.Dwarf_Error = type { [1024 x i32] }

@a = common local_unnamed_addr addrspace(200) global %struct.Dwarf_Error zeroinitializer, align 4

; Function Attrs: nounwind
define i32 @fn1() local_unnamed_addr #0 {
; CHECK-LABEL: fn1:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    daddiu $1, $zero, -[[STACKFRAME_SIZE:4176|4256]]
; CHECK-NEXT:    cincoffset $c11, $c11, $1
; CHECK-NEXT:    csc $c19, $zero, [[@EXPR STACKFRAME_SIZE - $CAP_SIZE]]($c11)
; CHECK-NEXT:    csc $c18, $zero, [[@EXPR STACKFRAME_SIZE - (2 * $CAP_SIZE)]]($c11)
; CHECK-NEXT:    csc $c17, $zero, [[@EXPR STACKFRAME_SIZE - (3 * $CAP_SIZE)]]($c11)
; CHECK-NEXT:    lui $1, %hi(%neg(%captab_rel(fn1)))
; CHECK-NEXT:    daddiu $1, $1, %lo(%neg(%captab_rel(fn1)))
; CHECK-NEXT:    cincoffset $c19, $c12, $1
; CHECK-NEXT:    daddiu $1, $zero, 4096
; CHECK-NEXT:    cincoffset $c18, $c11, [[@EXPR (2 * $CAP_SIZE)]]
; CHECK-NEXT:    csetbounds $c18, $c18, $1
; CHECK-NEXT:    clcbi $c4, %captab20(a)($c19)
; CHECK-NEXT:    clcbi $c12, %capcall20(memcpy)($c19)
; CHECK-NEXT:    daddiu $4, $zero, 4096
; CHECK-NEXT:    cjalr $c12, $c17
; CHECK-NEXT:    cmove $c3, $c18
; CHECK-NEXT:    csc $c18, $zero, 0($c11)
; CHECK-NEXT:    csetbounds $c1, $c11, [[$CAP_SIZE]]
; CHECK-NEXT:    clcbi $c12, %capcall20(fn2)($c19)
; CHECK-NEXT:    ori $1, $zero, 65495
; CHECK-NEXT:    cjalr $c12, $c17
; CHECK-NEXT:    candperm $c13, $c1, $1
; CHECK-NEXT:    clc $c17, $zero, [[@EXPR STACKFRAME_SIZE - (3 * $CAP_SIZE)]]($c11)
; CHECK-NEXT:    clc $c18, $zero, [[@EXPR STACKFRAME_SIZE - (2 * $CAP_SIZE)]]($c11)
; CHECK-NEXT:    clc $c19, $zero, [[@EXPR STACKFRAME_SIZE - $CAP_SIZE]]($c11)
; CHECK-NEXT:    daddiu $1, $zero, [[STACKFRAME_SIZE]]
; CHECK-NEXT:    cjr $c17
; CHECK-NEXT:    cincoffset $c11, $c11, $1
entry:
  %tmp = alloca %struct.Dwarf_Error, align 8, addrspace(200)
  %0 = bitcast %struct.Dwarf_Error addrspace(200)* %tmp to i8 addrspace(200)*
  call void @llvm.memcpy.p200i8.p200i8.i64(i8 addrspace(200)* nonnull %0, i8 addrspace(200)* bitcast (%struct.Dwarf_Error addrspace(200)* @a to i8 addrspace(200)*), i64 4096, i32 4, i1 false), !tbaa.struct !1
  %call = call i32 (...) @fn2(%struct.Dwarf_Error addrspace(200)* byval nonnull align 8 %tmp) #3
  ret i32 undef
}

declare i32 @fn2(...) #1

; Function Attrs: argmemonly nounwind
declare void @llvm.memcpy.p200i8.p200i8.i64(i8 addrspace(200)* nocapture writeonly, i8 addrspace(200)* nocapture readonly, i64, i32, i1) #2

attributes #0 = { nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="cheri128" "target-features"="+cheri128,+soft-float" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="cheri128" "target-features"="+cheri128,+soft-float" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { argmemonly nounwind }
attributes #3 = { nounwind }

!llvm.ident = !{!0}

!0 = !{!"clang version 5.0.0 (https://github.com/llvm-mirror/clang.git 0c91ed96d08feda61fd68f0fe034787f01cb9fa7) (https://github.com/llvm-mirror/llvm.git 6952b345731e6ea7246b4bc5173140b7fce21719)"}
!1 = !{i64 0, i64 4096, !2}
!2 = !{!3, !3, i64 0}
!3 = !{!"omnipotent char", !4, i64 0}
!4 = !{!"Simple C/C++ TBAA"}
