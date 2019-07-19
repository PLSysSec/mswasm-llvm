; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt %s -instcombine -S | FileCheck %s

; If we have some pattern that leaves only some low bits set, and then performs
; left-shift of those bits, if none of the bits that are left after the final
; shift are modified by the mask, we can omit the mask.

; There are many variants to this pattern:
;   c)  (x & (-1 >> maskNbits)) << shiftNbits
; simplify to:
;   x << shiftNbits
; iff (shiftNbits-maskNbits) s>= 0 (i.e. shiftNbits u>= maskNbits)

; Simple tests. We don't care about extra uses.

declare void @use32(i32)

define i32 @t0_basic(i32 %x, i32 %nbits) {
; CHECK-LABEL: @t0_basic(
; CHECK-NEXT:    [[T0:%.*]] = lshr i32 -1, [[NBITS:%.*]]
; CHECK-NEXT:    [[T1:%.*]] = and i32 [[T0]], [[X:%.*]]
; CHECK-NEXT:    call void @use32(i32 [[T0]])
; CHECK-NEXT:    call void @use32(i32 [[T1]])
; CHECK-NEXT:    [[T2:%.*]] = shl i32 [[X]], [[NBITS]]
; CHECK-NEXT:    ret i32 [[T2]]
;
  %t0 = lshr i32 -1, %nbits
  %t1 = and i32 %t0, %x
  call void @use32(i32 %t0)
  call void @use32(i32 %t1)
  %t2 = shl i32 %t1, %nbits
  ret i32 %t2
}

define i32 @t1_bigger_shift(i32 %x, i32 %nbits) {
; CHECK-LABEL: @t1_bigger_shift(
; CHECK-NEXT:    [[T0:%.*]] = lshr i32 -1, [[NBITS:%.*]]
; CHECK-NEXT:    [[T1:%.*]] = and i32 [[T0]], [[X:%.*]]
; CHECK-NEXT:    [[T2:%.*]] = add i32 [[NBITS]], 1
; CHECK-NEXT:    call void @use32(i32 [[T0]])
; CHECK-NEXT:    call void @use32(i32 [[T1]])
; CHECK-NEXT:    call void @use32(i32 [[T2]])
; CHECK-NEXT:    [[T3:%.*]] = shl i32 [[X]], [[T2]]
; CHECK-NEXT:    ret i32 [[T3]]
;
  %t0 = lshr i32 -1, %nbits
  %t1 = and i32 %t0, %x
  %t2 = add i32 %nbits, 1
  call void @use32(i32 %t0)
  call void @use32(i32 %t1)
  call void @use32(i32 %t2)
  %t3 = shl i32 %t1, %t2
  ret i32 %t3
}

; Vectors

declare void @use3xi32(<3 x i32>)

define <3 x i32> @t2_vec_splat(<3 x i32> %x, <3 x i32> %nbits) {
; CHECK-LABEL: @t2_vec_splat(
; CHECK-NEXT:    [[T0:%.*]] = lshr <3 x i32> <i32 -1, i32 -1, i32 -1>, [[NBITS:%.*]]
; CHECK-NEXT:    [[T1:%.*]] = and <3 x i32> [[T0]], [[X:%.*]]
; CHECK-NEXT:    [[T2:%.*]] = add <3 x i32> [[NBITS]], <i32 1, i32 1, i32 1>
; CHECK-NEXT:    call void @use3xi32(<3 x i32> [[T0]])
; CHECK-NEXT:    call void @use3xi32(<3 x i32> [[T1]])
; CHECK-NEXT:    call void @use3xi32(<3 x i32> [[T2]])
; CHECK-NEXT:    [[T3:%.*]] = shl <3 x i32> [[X]], [[T2]]
; CHECK-NEXT:    ret <3 x i32> [[T3]]
;
  %t0 = lshr <3 x i32> <i32 -1, i32 -1, i32 -1>, %nbits
  %t1 = and <3 x i32> %t0, %x
  %t2 = add <3 x i32> %nbits, <i32 1, i32 1, i32 1>
  call void @use3xi32(<3 x i32> %t0)
  call void @use3xi32(<3 x i32> %t1)
  call void @use3xi32(<3 x i32> %t2)
  %t3 = shl <3 x i32> %t1, %t2
  ret <3 x i32> %t3
}

define <3 x i32> @t3_vec_nonsplat(<3 x i32> %x, <3 x i32> %nbits) {
; CHECK-LABEL: @t3_vec_nonsplat(
; CHECK-NEXT:    [[T0:%.*]] = lshr <3 x i32> <i32 -1, i32 -1, i32 -1>, [[NBITS:%.*]]
; CHECK-NEXT:    [[T1:%.*]] = and <3 x i32> [[T0]], [[X:%.*]]
; CHECK-NEXT:    [[T2:%.*]] = add <3 x i32> [[NBITS]], <i32 1, i32 0, i32 2>
; CHECK-NEXT:    call void @use3xi32(<3 x i32> [[T0]])
; CHECK-NEXT:    call void @use3xi32(<3 x i32> [[T1]])
; CHECK-NEXT:    call void @use3xi32(<3 x i32> [[T2]])
; CHECK-NEXT:    [[T3:%.*]] = shl <3 x i32> [[X]], [[T2]]
; CHECK-NEXT:    ret <3 x i32> [[T3]]
;
  %t0 = lshr <3 x i32> <i32 -1, i32 -1, i32 -1>, %nbits
  %t1 = and <3 x i32> %t0, %x
  %t2 = add <3 x i32> %nbits, <i32 1, i32 0, i32 2>
  call void @use3xi32(<3 x i32> %t0)
  call void @use3xi32(<3 x i32> %t1)
  call void @use3xi32(<3 x i32> %t2)
  %t3 = shl <3 x i32> %t1, %t2
  ret <3 x i32> %t3
}

define <3 x i32> @t4_vec_undef(<3 x i32> %x, <3 x i32> %nbits) {
; CHECK-LABEL: @t4_vec_undef(
; CHECK-NEXT:    [[T0:%.*]] = lshr <3 x i32> <i32 -1, i32 undef, i32 -1>, [[NBITS:%.*]]
; CHECK-NEXT:    [[T1:%.*]] = and <3 x i32> [[T0]], [[X:%.*]]
; CHECK-NEXT:    [[T2:%.*]] = add <3 x i32> [[NBITS]], <i32 1, i32 undef, i32 1>
; CHECK-NEXT:    call void @use3xi32(<3 x i32> [[T0]])
; CHECK-NEXT:    call void @use3xi32(<3 x i32> [[T1]])
; CHECK-NEXT:    call void @use3xi32(<3 x i32> [[T2]])
; CHECK-NEXT:    [[T3:%.*]] = shl <3 x i32> [[X]], [[T2]]
; CHECK-NEXT:    ret <3 x i32> [[T3]]
;
  %t0 = lshr <3 x i32> <i32 -1, i32 undef, i32 -1>, %nbits
  %t1 = and <3 x i32> %t0, %x
  %t2 = add <3 x i32> %nbits, <i32 1, i32 undef, i32 1>
  call void @use3xi32(<3 x i32> %t0)
  call void @use3xi32(<3 x i32> %t1)
  call void @use3xi32(<3 x i32> %t2)
  %t3 = shl <3 x i32> %t1, %t2
  ret <3 x i32> %t3
}

; Commutativity

declare i32 @gen32()

define i32 @t5_commutativity0(i32 %nbits) {
; CHECK-LABEL: @t5_commutativity0(
; CHECK-NEXT:    [[X:%.*]] = call i32 @gen32()
; CHECK-NEXT:    [[T0:%.*]] = lshr i32 -1, [[NBITS:%.*]]
; CHECK-NEXT:    [[T1:%.*]] = and i32 [[X]], [[T0]]
; CHECK-NEXT:    call void @use32(i32 [[T0]])
; CHECK-NEXT:    call void @use32(i32 [[T1]])
; CHECK-NEXT:    [[T2:%.*]] = shl i32 [[X]], [[NBITS]]
; CHECK-NEXT:    ret i32 [[T2]]
;
  %x = call i32 @gen32()
  %t0 = lshr i32 -1, %nbits
  %t1 = and i32 %x, %t0 ; swapped
  call void @use32(i32 %t0)
  call void @use32(i32 %t1)
  %t2 = shl i32 %t1, %nbits
  ret i32 %t2
}

define i32 @t6_commutativity1(i32 %nbits0, i32 %nbits1) {
; CHECK-LABEL: @t6_commutativity1(
; CHECK-NEXT:    [[T0:%.*]] = lshr i32 -1, [[NBITS0:%.*]]
; CHECK-NEXT:    [[T1:%.*]] = lshr i32 -1, [[NBITS1:%.*]]
; CHECK-NEXT:    [[T2:%.*]] = and i32 [[T0]], [[T1]]
; CHECK-NEXT:    call void @use32(i32 [[T0]])
; CHECK-NEXT:    call void @use32(i32 [[T1]])
; CHECK-NEXT:    call void @use32(i32 [[T2]])
; CHECK-NEXT:    [[T3:%.*]] = shl i32 [[T1]], [[NBITS0]]
; CHECK-NEXT:    ret i32 [[T3]]
;
  %t0 = lshr i32 -1, %nbits0
  %t1 = lshr i32 -1, %nbits1
  %t2 = and i32 %t0, %t1 ; both hands of 'and' could be mask..
  call void @use32(i32 %t0)
  call void @use32(i32 %t1)
  call void @use32(i32 %t2)
  %t3 = shl i32 %t2, %nbits0
  ret i32 %t3
}
define i32 @t7_commutativity2(i32 %nbits0, i32 %nbits1) {
; CHECK-LABEL: @t7_commutativity2(
; CHECK-NEXT:    [[T0:%.*]] = lshr i32 -1, [[NBITS0:%.*]]
; CHECK-NEXT:    [[T1:%.*]] = lshr i32 -1, [[NBITS1:%.*]]
; CHECK-NEXT:    [[T2:%.*]] = and i32 [[T0]], [[T1]]
; CHECK-NEXT:    call void @use32(i32 [[T0]])
; CHECK-NEXT:    call void @use32(i32 [[T1]])
; CHECK-NEXT:    call void @use32(i32 [[T2]])
; CHECK-NEXT:    [[T3:%.*]] = shl i32 [[T2]], [[NBITS1]]
; CHECK-NEXT:    ret i32 [[T3]]
;
  %t0 = lshr i32 -1, %nbits0
  %t1 = lshr i32 -1, %nbits1
  %t2 = and i32 %t0, %t1 ; both hands of 'and' could be mask..
  call void @use32(i32 %t0)
  call void @use32(i32 %t1)
  call void @use32(i32 %t2)
  %t3 = shl i32 %t2, %nbits1
  ret i32 %t3
}

; Fast-math flags. We must not preserve them!

define i32 @t8_nuw(i32 %x, i32 %nbits) {
; CHECK-LABEL: @t8_nuw(
; CHECK-NEXT:    [[T0:%.*]] = lshr i32 -1, [[NBITS:%.*]]
; CHECK-NEXT:    [[T1:%.*]] = and i32 [[T0]], [[X:%.*]]
; CHECK-NEXT:    call void @use32(i32 [[T0]])
; CHECK-NEXT:    call void @use32(i32 [[T1]])
; CHECK-NEXT:    [[T2:%.*]] = shl i32 [[X]], [[NBITS]]
; CHECK-NEXT:    ret i32 [[T2]]
;
  %t0 = lshr i32 -1, %nbits
  %t1 = and i32 %t0, %x
  call void @use32(i32 %t0)
  call void @use32(i32 %t1)
  %t2 = shl nuw i32 %t1, %nbits
  ret i32 %t2
}

define i32 @t9_nsw(i32 %x, i32 %nbits) {
; CHECK-LABEL: @t9_nsw(
; CHECK-NEXT:    [[T0:%.*]] = lshr i32 -1, [[NBITS:%.*]]
; CHECK-NEXT:    [[T1:%.*]] = and i32 [[T0]], [[X:%.*]]
; CHECK-NEXT:    call void @use32(i32 [[T0]])
; CHECK-NEXT:    call void @use32(i32 [[T1]])
; CHECK-NEXT:    [[T2:%.*]] = shl i32 [[X]], [[NBITS]]
; CHECK-NEXT:    ret i32 [[T2]]
;
  %t0 = lshr i32 -1, %nbits
  %t1 = and i32 %t0, %x
  call void @use32(i32 %t0)
  call void @use32(i32 %t1)
  %t2 = shl nsw i32 %t1, %nbits
  ret i32 %t2
}

define i32 @t10_nuw_nsw(i32 %x, i32 %nbits) {
; CHECK-LABEL: @t10_nuw_nsw(
; CHECK-NEXT:    [[T0:%.*]] = lshr i32 -1, [[NBITS:%.*]]
; CHECK-NEXT:    [[T1:%.*]] = and i32 [[T0]], [[X:%.*]]
; CHECK-NEXT:    call void @use32(i32 [[T0]])
; CHECK-NEXT:    call void @use32(i32 [[T1]])
; CHECK-NEXT:    [[T2:%.*]] = shl i32 [[X]], [[NBITS]]
; CHECK-NEXT:    ret i32 [[T2]]
;
  %t0 = lshr i32 -1, %nbits
  %t1 = and i32 %t0, %x
  call void @use32(i32 %t0)
  call void @use32(i32 %t1)
  %t2 = shl nuw nsw i32 %t1, %nbits
  ret i32 %t2
}

; Special test

declare void @llvm.assume(i1 %cond)

; We can't simplify (%shiftnbits-%masknbits) but we have an assumption.
define i32 @t11_assume_uge(i32 %x, i32 %masknbits, i32 %shiftnbits) {
; CHECK-LABEL: @t11_assume_uge(
; CHECK-NEXT:    [[CMP:%.*]] = icmp uge i32 [[SHIFTNBITS:%.*]], [[MASKNBITS:%.*]]
; CHECK-NEXT:    call void @llvm.assume(i1 [[CMP]])
; CHECK-NEXT:    [[T0:%.*]] = lshr i32 -1, [[MASKNBITS]]
; CHECK-NEXT:    [[T1:%.*]] = and i32 [[T0]], [[X:%.*]]
; CHECK-NEXT:    call void @use32(i32 [[T0]])
; CHECK-NEXT:    call void @use32(i32 [[T1]])
; CHECK-NEXT:    [[T2:%.*]] = shl i32 [[T1]], [[SHIFTNBITS]]
; CHECK-NEXT:    ret i32 [[T2]]
;
  %cmp = icmp uge i32 %shiftnbits, %masknbits
  call void @llvm.assume(i1 %cmp)
  %t0 = lshr i32 -1, %masknbits
  %t1 = and i32 %t0, %x
  call void @use32(i32 %t0)
  call void @use32(i32 %t1)
  %t2 = shl i32 %t1, %shiftnbits
  ret i32 %t2
}

; Negative tests

define i32 @n12_not_minus_one(i32 %x, i32 %nbits) {
; CHECK-LABEL: @n12_not_minus_one(
; CHECK-NEXT:    [[T0:%.*]] = lshr i32 -2, [[NBITS:%.*]]
; CHECK-NEXT:    [[T1:%.*]] = and i32 [[T0]], [[X:%.*]]
; CHECK-NEXT:    call void @use32(i32 [[T0]])
; CHECK-NEXT:    call void @use32(i32 [[T1]])
; CHECK-NEXT:    [[T2:%.*]] = shl i32 [[T1]], [[NBITS]]
; CHECK-NEXT:    ret i32 [[T2]]
;
  %t0 = lshr i32 -2, %nbits ; shifting not '-1'
  %t1 = and i32 %t0, %x
  call void @use32(i32 %t0)
  call void @use32(i32 %t1)
  %t2 = shl i32 %t1, %nbits
  ret i32 %t2
}

define i32 @n13_shamt_is_smaller(i32 %x, i32 %nbits) {
; CHECK-LABEL: @n13_shamt_is_smaller(
; CHECK-NEXT:    [[T0:%.*]] = lshr i32 -1, [[NBITS:%.*]]
; CHECK-NEXT:    [[T1:%.*]] = and i32 [[T0]], [[X:%.*]]
; CHECK-NEXT:    [[T2:%.*]] = add i32 [[NBITS]], -1
; CHECK-NEXT:    call void @use32(i32 [[T0]])
; CHECK-NEXT:    call void @use32(i32 [[T1]])
; CHECK-NEXT:    call void @use32(i32 [[T2]])
; CHECK-NEXT:    ret i32 [[T2]]
;
  %t0 = lshr i32 -1, %nbits
  %t1 = and i32 %t0, %x
  %t2 = add i32 %nbits, -1
  call void @use32(i32 %t0)
  call void @use32(i32 %t1)
  call void @use32(i32 %t2)
  %t3 = shl i32 %t1, %t2 ; shift is smaller than mask
  ret i32 %t2
}
