; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -S -loop-predication < %s 2>&1 | FileCheck %s
; RUN: opt -S -passes='require<scalar-evolution>,loop(loop-predication)' < %s 2>&1 | FileCheck %s

declare void @llvm.experimental.guard(i1, ...)

define i32 @signed_loop_0_to_n_nested_0_to_l_inner_index_check(i32* %array, i32 %length, i32 %n, i32 %l) {
; CHECK-LABEL: @signed_loop_0_to_n_nested_0_to_l_inner_index_check(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP5:%.*]] = icmp sle i32 [[N:%.*]], 0
; CHECK-NEXT:    br i1 [[TMP5]], label [[EXIT:%.*]], label [[OUTER_LOOP_PREHEADER:%.*]]
; CHECK:       outer.loop.preheader:
; CHECK-NEXT:    br label [[OUTER_LOOP:%.*]]
; CHECK:       outer.loop:
; CHECK-NEXT:    [[OUTER_LOOP_ACC:%.*]] = phi i32 [ [[OUTER_LOOP_ACC_NEXT:%.*]], [[OUTER_LOOP_INC:%.*]] ], [ 0, [[OUTER_LOOP_PREHEADER]] ]
; CHECK-NEXT:    [[I:%.*]] = phi i32 [ [[I_NEXT:%.*]], [[OUTER_LOOP_INC]] ], [ 0, [[OUTER_LOOP_PREHEADER]] ]
; CHECK-NEXT:    [[TMP6:%.*]] = icmp sle i32 [[L:%.*]], 0
; CHECK-NEXT:    br i1 [[TMP6]], label [[OUTER_LOOP_INC]], label [[INNER_LOOP_PREHEADER:%.*]]
; CHECK:       inner.loop.preheader:
; CHECK-NEXT:    [[TMP0:%.*]] = icmp sle i32 [[L]], [[LENGTH:%.*]]
; CHECK-NEXT:    [[TMP1:%.*]] = icmp ult i32 0, [[LENGTH]]
; CHECK-NEXT:    [[TMP2:%.*]] = and i1 [[TMP1]], [[TMP0]]
; CHECK-NEXT:    br label [[INNER_LOOP:%.*]]
; CHECK:       inner.loop:
; CHECK-NEXT:    [[INNER_LOOP_ACC:%.*]] = phi i32 [ [[INNER_LOOP_ACC_NEXT:%.*]], [[INNER_LOOP]] ], [ [[OUTER_LOOP_ACC]], [[INNER_LOOP_PREHEADER]] ]
; CHECK-NEXT:    [[J:%.*]] = phi i32 [ [[J_NEXT:%.*]], [[INNER_LOOP]] ], [ 0, [[INNER_LOOP_PREHEADER]] ]
; CHECK-NEXT:    [[WITHIN_BOUNDS:%.*]] = icmp ult i32 [[J]], [[LENGTH]]
; CHECK-NEXT:    call void (i1, ...) @llvm.experimental.guard(i1 [[TMP2]], i32 9) [ "deopt"() ]
; CHECK-NEXT:    [[J_I64:%.*]] = zext i32 [[J]] to i64
; CHECK-NEXT:    [[ARRAY_J_PTR:%.*]] = getelementptr inbounds i32, i32* [[ARRAY:%.*]], i64 [[J_I64]]
; CHECK-NEXT:    [[ARRAY_J:%.*]] = load i32, i32* [[ARRAY_J_PTR]], align 4
; CHECK-NEXT:    [[INNER_LOOP_ACC_NEXT]] = add i32 [[INNER_LOOP_ACC]], [[ARRAY_J]]
; CHECK-NEXT:    [[J_NEXT]] = add nsw i32 [[J]], 1
; CHECK-NEXT:    [[INNER_CONTINUE:%.*]] = icmp slt i32 [[J_NEXT]], [[L]]
; CHECK-NEXT:    br i1 [[INNER_CONTINUE]], label [[INNER_LOOP]], label [[OUTER_LOOP_INC_LOOPEXIT:%.*]]
; CHECK:       outer.loop.inc.loopexit:
; CHECK-NEXT:    [[INNER_LOOP_ACC_NEXT_LCSSA:%.*]] = phi i32 [ [[INNER_LOOP_ACC_NEXT]], [[INNER_LOOP]] ]
; CHECK-NEXT:    br label [[OUTER_LOOP_INC]]
; CHECK:       outer.loop.inc:
; CHECK-NEXT:    [[OUTER_LOOP_ACC_NEXT]] = phi i32 [ [[OUTER_LOOP_ACC]], [[OUTER_LOOP]] ], [ [[INNER_LOOP_ACC_NEXT_LCSSA]], [[OUTER_LOOP_INC_LOOPEXIT]] ]
; CHECK-NEXT:    [[I_NEXT]] = add nsw i32 [[I]], 1
; CHECK-NEXT:    [[OUTER_CONTINUE:%.*]] = icmp slt i32 [[I_NEXT]], [[N]]
; CHECK-NEXT:    br i1 [[OUTER_CONTINUE]], label [[OUTER_LOOP]], label [[EXIT_LOOPEXIT:%.*]]
; CHECK:       exit.loopexit:
; CHECK-NEXT:    [[OUTER_LOOP_ACC_NEXT_LCSSA:%.*]] = phi i32 [ [[OUTER_LOOP_ACC_NEXT]], [[OUTER_LOOP_INC]] ]
; CHECK-NEXT:    br label [[EXIT]]
; CHECK:       exit:
; CHECK-NEXT:    [[RESULT:%.*]] = phi i32 [ 0, [[ENTRY:%.*]] ], [ [[OUTER_LOOP_ACC_NEXT_LCSSA]], [[EXIT_LOOPEXIT]] ]
; CHECK-NEXT:    ret i32 [[RESULT]]
;
entry:
  %tmp5 = icmp sle i32 %n, 0
  br i1 %tmp5, label %exit, label %outer.loop.preheader

outer.loop.preheader:
  br label %outer.loop

outer.loop:
  %outer.loop.acc = phi i32 [ %outer.loop.acc.next, %outer.loop.inc ], [ 0, %outer.loop.preheader ]
  %i = phi i32 [ %i.next, %outer.loop.inc ], [ 0, %outer.loop.preheader ]
  %tmp6 = icmp sle i32 %l, 0
  br i1 %tmp6, label %outer.loop.inc, label %inner.loop.preheader

inner.loop.preheader:
  br label %inner.loop

inner.loop:
  %inner.loop.acc = phi i32 [ %inner.loop.acc.next, %inner.loop ], [ %outer.loop.acc, %inner.loop.preheader ]
  %j = phi i32 [ %j.next, %inner.loop ], [ 0, %inner.loop.preheader ]

  %within.bounds = icmp ult i32 %j, %length
  call void (i1, ...) @llvm.experimental.guard(i1 %within.bounds, i32 9) [ "deopt"() ]

  %j.i64 = zext i32 %j to i64
  %array.j.ptr = getelementptr inbounds i32, i32* %array, i64 %j.i64
  %array.j = load i32, i32* %array.j.ptr, align 4
  %inner.loop.acc.next = add i32 %inner.loop.acc, %array.j

  %j.next = add nsw i32 %j, 1
  %inner.continue = icmp slt i32 %j.next, %l
  br i1 %inner.continue, label %inner.loop, label %outer.loop.inc

outer.loop.inc:
  %outer.loop.acc.next = phi i32 [ %inner.loop.acc.next, %inner.loop ], [ %outer.loop.acc, %outer.loop ]
  %i.next = add nsw i32 %i, 1
  %outer.continue = icmp slt i32 %i.next, %n
  br i1 %outer.continue, label %outer.loop, label %exit

exit:
  %result = phi i32 [ 0, %entry ], [ %outer.loop.acc.next, %outer.loop.inc ]
  ret i32 %result
}

define i32 @signed_loop_0_to_n_nested_0_to_l_outer_index_check(i32* %array, i32 %length, i32 %n, i32 %l) {
; CHECK-LABEL: @signed_loop_0_to_n_nested_0_to_l_outer_index_check(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP5:%.*]] = icmp sle i32 [[N:%.*]], 0
; CHECK-NEXT:    br i1 [[TMP5]], label [[EXIT:%.*]], label [[OUTER_LOOP_PREHEADER:%.*]]
; CHECK:       outer.loop.preheader:
; CHECK-NEXT:    [[TMP0:%.*]] = icmp sle i32 [[N]], [[LENGTH:%.*]]
; CHECK-NEXT:    [[TMP1:%.*]] = icmp ult i32 0, [[LENGTH]]
; CHECK-NEXT:    [[TMP2:%.*]] = and i1 [[TMP1]], [[TMP0]]
; CHECK-NEXT:    br label [[OUTER_LOOP:%.*]]
; CHECK:       outer.loop:
; CHECK-NEXT:    [[OUTER_LOOP_ACC:%.*]] = phi i32 [ [[OUTER_LOOP_ACC_NEXT:%.*]], [[OUTER_LOOP_INC:%.*]] ], [ 0, [[OUTER_LOOP_PREHEADER]] ]
; CHECK-NEXT:    [[I:%.*]] = phi i32 [ [[I_NEXT:%.*]], [[OUTER_LOOP_INC]] ], [ 0, [[OUTER_LOOP_PREHEADER]] ]
; CHECK-NEXT:    [[TMP6:%.*]] = icmp sle i32 [[L:%.*]], 0
; CHECK-NEXT:    br i1 [[TMP6]], label [[OUTER_LOOP_INC]], label [[INNER_LOOP_PREHEADER:%.*]]
; CHECK:       inner.loop.preheader:
; CHECK-NEXT:    br label [[INNER_LOOP:%.*]]
; CHECK:       inner.loop:
; CHECK-NEXT:    [[INNER_LOOP_ACC:%.*]] = phi i32 [ [[INNER_LOOP_ACC_NEXT:%.*]], [[INNER_LOOP]] ], [ [[OUTER_LOOP_ACC]], [[INNER_LOOP_PREHEADER]] ]
; CHECK-NEXT:    [[J:%.*]] = phi i32 [ [[J_NEXT:%.*]], [[INNER_LOOP]] ], [ 0, [[INNER_LOOP_PREHEADER]] ]
; CHECK-NEXT:    [[WITHIN_BOUNDS:%.*]] = icmp ult i32 [[I]], [[LENGTH]]
; CHECK-NEXT:    call void (i1, ...) @llvm.experimental.guard(i1 [[TMP2]], i32 9) [ "deopt"() ]
; CHECK-NEXT:    [[I_I64:%.*]] = zext i32 [[I]] to i64
; CHECK-NEXT:    [[ARRAY_I_PTR:%.*]] = getelementptr inbounds i32, i32* [[ARRAY:%.*]], i64 [[I_I64]]
; CHECK-NEXT:    [[ARRAY_I:%.*]] = load i32, i32* [[ARRAY_I_PTR]], align 4
; CHECK-NEXT:    [[INNER_LOOP_ACC_NEXT]] = add i32 [[INNER_LOOP_ACC]], [[ARRAY_I]]
; CHECK-NEXT:    [[J_NEXT]] = add nsw i32 [[J]], 1
; CHECK-NEXT:    [[INNER_CONTINUE:%.*]] = icmp slt i32 [[J_NEXT]], [[L]]
; CHECK-NEXT:    br i1 [[INNER_CONTINUE]], label [[INNER_LOOP]], label [[OUTER_LOOP_INC_LOOPEXIT:%.*]]
; CHECK:       outer.loop.inc.loopexit:
; CHECK-NEXT:    [[INNER_LOOP_ACC_NEXT_LCSSA:%.*]] = phi i32 [ [[INNER_LOOP_ACC_NEXT]], [[INNER_LOOP]] ]
; CHECK-NEXT:    br label [[OUTER_LOOP_INC]]
; CHECK:       outer.loop.inc:
; CHECK-NEXT:    [[OUTER_LOOP_ACC_NEXT]] = phi i32 [ [[OUTER_LOOP_ACC]], [[OUTER_LOOP]] ], [ [[INNER_LOOP_ACC_NEXT_LCSSA]], [[OUTER_LOOP_INC_LOOPEXIT]] ]
; CHECK-NEXT:    [[I_NEXT]] = add nsw i32 [[I]], 1
; CHECK-NEXT:    [[OUTER_CONTINUE:%.*]] = icmp slt i32 [[I_NEXT]], [[N]]
; CHECK-NEXT:    br i1 [[OUTER_CONTINUE]], label [[OUTER_LOOP]], label [[EXIT_LOOPEXIT:%.*]]
; CHECK:       exit.loopexit:
; CHECK-NEXT:    [[OUTER_LOOP_ACC_NEXT_LCSSA:%.*]] = phi i32 [ [[OUTER_LOOP_ACC_NEXT]], [[OUTER_LOOP_INC]] ]
; CHECK-NEXT:    br label [[EXIT]]
; CHECK:       exit:
; CHECK-NEXT:    [[RESULT:%.*]] = phi i32 [ 0, [[ENTRY:%.*]] ], [ [[OUTER_LOOP_ACC_NEXT_LCSSA]], [[EXIT_LOOPEXIT]] ]
; CHECK-NEXT:    ret i32 [[RESULT]]
;
entry:
  %tmp5 = icmp sle i32 %n, 0
  br i1 %tmp5, label %exit, label %outer.loop.preheader

outer.loop.preheader:
  br label %outer.loop

outer.loop:
  %outer.loop.acc = phi i32 [ %outer.loop.acc.next, %outer.loop.inc ], [ 0, %outer.loop.preheader ]
  %i = phi i32 [ %i.next, %outer.loop.inc ], [ 0, %outer.loop.preheader ]
  %tmp6 = icmp sle i32 %l, 0
  br i1 %tmp6, label %outer.loop.inc, label %inner.loop.preheader

inner.loop.preheader:
  br label %inner.loop

inner.loop:

  %inner.loop.acc = phi i32 [ %inner.loop.acc.next, %inner.loop ], [ %outer.loop.acc, %inner.loop.preheader ]
  %j = phi i32 [ %j.next, %inner.loop ], [ 0, %inner.loop.preheader ]

  %within.bounds = icmp ult i32 %i, %length
  call void (i1, ...) @llvm.experimental.guard(i1 %within.bounds, i32 9) [ "deopt"() ]

  %i.i64 = zext i32 %i to i64
  %array.i.ptr = getelementptr inbounds i32, i32* %array, i64 %i.i64
  %array.i = load i32, i32* %array.i.ptr, align 4
  %inner.loop.acc.next = add i32 %inner.loop.acc, %array.i

  %j.next = add nsw i32 %j, 1
  %inner.continue = icmp slt i32 %j.next, %l
  br i1 %inner.continue, label %inner.loop, label %outer.loop.inc

outer.loop.inc:
  %outer.loop.acc.next = phi i32 [ %inner.loop.acc.next, %inner.loop ], [ %outer.loop.acc, %outer.loop ]
  %i.next = add nsw i32 %i, 1
  %outer.continue = icmp slt i32 %i.next, %n
  br i1 %outer.continue, label %outer.loop, label %exit

exit:
  %result = phi i32 [ 0, %entry ], [ %outer.loop.acc.next, %outer.loop.inc ]
  ret i32 %result
}

define i32 @signed_loop_0_to_n_nested_i_to_l_inner_index_check(i32* %array, i32 %length, i32 %n, i32 %l) {
; CHECK-LABEL: @signed_loop_0_to_n_nested_i_to_l_inner_index_check(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP5:%.*]] = icmp sle i32 [[N:%.*]], 0
; CHECK-NEXT:    br i1 [[TMP5]], label [[EXIT:%.*]], label [[OUTER_LOOP_PREHEADER:%.*]]
; CHECK:       outer.loop.preheader:
; CHECK-NEXT:    [[TMP0:%.*]] = icmp sle i32 [[N]], [[LENGTH:%.*]]
; CHECK-NEXT:    [[TMP1:%.*]] = icmp ult i32 0, [[LENGTH]]
; CHECK-NEXT:    [[TMP2:%.*]] = and i1 [[TMP1]], [[TMP0]]
; CHECK-NEXT:    br label [[OUTER_LOOP:%.*]]
; CHECK:       outer.loop:
; CHECK-NEXT:    [[OUTER_LOOP_ACC:%.*]] = phi i32 [ [[OUTER_LOOP_ACC_NEXT:%.*]], [[OUTER_LOOP_INC:%.*]] ], [ 0, [[OUTER_LOOP_PREHEADER]] ]
; CHECK-NEXT:    [[I:%.*]] = phi i32 [ [[I_NEXT:%.*]], [[OUTER_LOOP_INC]] ], [ 0, [[OUTER_LOOP_PREHEADER]] ]
; CHECK-NEXT:    [[TMP6:%.*]] = icmp sle i32 [[L:%.*]], 0
; CHECK-NEXT:    br i1 [[TMP6]], label [[OUTER_LOOP_INC]], label [[INNER_LOOP_PREHEADER:%.*]]
; CHECK:       inner.loop.preheader:
; CHECK-NEXT:    [[TMP3:%.*]] = icmp sle i32 [[L]], [[LENGTH]]
; CHECK-NEXT:    [[TMP4:%.*]] = icmp ult i32 [[I]], [[LENGTH]]
; CHECK-NEXT:    [[TMP5:%.*]] = and i1 [[TMP4]], [[TMP3]]
; CHECK-NEXT:    br label [[INNER_LOOP:%.*]]
; CHECK:       inner.loop:
; CHECK-NEXT:    [[INNER_LOOP_ACC:%.*]] = phi i32 [ [[INNER_LOOP_ACC_NEXT:%.*]], [[INNER_LOOP]] ], [ [[OUTER_LOOP_ACC]], [[INNER_LOOP_PREHEADER]] ]
; CHECK-NEXT:    [[J:%.*]] = phi i32 [ [[J_NEXT:%.*]], [[INNER_LOOP]] ], [ [[I]], [[INNER_LOOP_PREHEADER]] ]
; CHECK-NEXT:    [[WITHIN_BOUNDS:%.*]] = icmp ult i32 [[J]], [[LENGTH]]
; CHECK-NEXT:    [[TMP6:%.*]] = and i1 [[TMP3]], [[TMP2]]
; CHECK-NEXT:    call void (i1, ...) @llvm.experimental.guard(i1 [[TMP6]], i32 9) [ "deopt"() ]
; CHECK-NEXT:    [[J_I64:%.*]] = zext i32 [[J]] to i64
; CHECK-NEXT:    [[ARRAY_J_PTR:%.*]] = getelementptr inbounds i32, i32* [[ARRAY:%.*]], i64 [[J_I64]]
; CHECK-NEXT:    [[ARRAY_J:%.*]] = load i32, i32* [[ARRAY_J_PTR]], align 4
; CHECK-NEXT:    [[INNER_LOOP_ACC_NEXT]] = add i32 [[INNER_LOOP_ACC]], [[ARRAY_J]]
; CHECK-NEXT:    [[J_NEXT]] = add nsw i32 [[J]], 1
; CHECK-NEXT:    [[INNER_CONTINUE:%.*]] = icmp slt i32 [[J_NEXT]], [[L]]
; CHECK-NEXT:    br i1 [[INNER_CONTINUE]], label [[INNER_LOOP]], label [[OUTER_LOOP_INC_LOOPEXIT:%.*]]
; CHECK:       outer.loop.inc.loopexit:
; CHECK-NEXT:    [[INNER_LOOP_ACC_NEXT_LCSSA:%.*]] = phi i32 [ [[INNER_LOOP_ACC_NEXT]], [[INNER_LOOP]] ]
; CHECK-NEXT:    br label [[OUTER_LOOP_INC]]
; CHECK:       outer.loop.inc:
; CHECK-NEXT:    [[OUTER_LOOP_ACC_NEXT]] = phi i32 [ [[OUTER_LOOP_ACC]], [[OUTER_LOOP]] ], [ [[INNER_LOOP_ACC_NEXT_LCSSA]], [[OUTER_LOOP_INC_LOOPEXIT]] ]
; CHECK-NEXT:    [[I_NEXT]] = add nsw i32 [[I]], 1
; CHECK-NEXT:    [[OUTER_CONTINUE:%.*]] = icmp slt i32 [[I_NEXT]], [[N]]
; CHECK-NEXT:    br i1 [[OUTER_CONTINUE]], label [[OUTER_LOOP]], label [[EXIT_LOOPEXIT:%.*]]
; CHECK:       exit.loopexit:
; CHECK-NEXT:    [[OUTER_LOOP_ACC_NEXT_LCSSA:%.*]] = phi i32 [ [[OUTER_LOOP_ACC_NEXT]], [[OUTER_LOOP_INC]] ]
; CHECK-NEXT:    br label [[EXIT]]
; CHECK:       exit:
; CHECK-NEXT:    [[RESULT:%.*]] = phi i32 [ 0, [[ENTRY:%.*]] ], [ [[OUTER_LOOP_ACC_NEXT_LCSSA]], [[EXIT_LOOPEXIT]] ]
; CHECK-NEXT:    ret i32 [[RESULT]]
;
entry:
  %tmp5 = icmp sle i32 %n, 0
  br i1 %tmp5, label %exit, label %outer.loop.preheader

outer.loop.preheader:
  br label %outer.loop

outer.loop:
  %outer.loop.acc = phi i32 [ %outer.loop.acc.next, %outer.loop.inc ], [ 0, %outer.loop.preheader ]
  %i = phi i32 [ %i.next, %outer.loop.inc ], [ 0, %outer.loop.preheader ]
  %tmp6 = icmp sle i32 %l, 0
  br i1 %tmp6, label %outer.loop.inc, label %inner.loop.preheader

inner.loop.preheader:
  br label %inner.loop

inner.loop:
  %inner.loop.acc = phi i32 [ %inner.loop.acc.next, %inner.loop ], [ %outer.loop.acc, %inner.loop.preheader ]
  %j = phi i32 [ %j.next, %inner.loop ], [ %i, %inner.loop.preheader ]

  %within.bounds = icmp ult i32 %j, %length
  call void (i1, ...) @llvm.experimental.guard(i1 %within.bounds, i32 9) [ "deopt"() ]

  %j.i64 = zext i32 %j to i64
  %array.j.ptr = getelementptr inbounds i32, i32* %array, i64 %j.i64
  %array.j = load i32, i32* %array.j.ptr, align 4
  %inner.loop.acc.next = add i32 %inner.loop.acc, %array.j

  %j.next = add nsw i32 %j, 1
  %inner.continue = icmp slt i32 %j.next, %l
  br i1 %inner.continue, label %inner.loop, label %outer.loop.inc

outer.loop.inc:
  %outer.loop.acc.next = phi i32 [ %inner.loop.acc.next, %inner.loop ], [ %outer.loop.acc, %outer.loop ]
  %i.next = add nsw i32 %i, 1
  %outer.continue = icmp slt i32 %i.next, %n
  br i1 %outer.continue, label %outer.loop, label %exit

exit:
  %result = phi i32 [ 0, %entry ], [ %outer.loop.acc.next, %outer.loop.inc ]
  ret i32 %result
}

define i32 @cant_expand_guard_check_start(i32* %array, i32 %length, i32 %n, i32 %l, i32 %maybezero) {
; CHECK-LABEL: @cant_expand_guard_check_start(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP5:%.*]] = icmp sle i32 [[N:%.*]], 0
; CHECK-NEXT:    br i1 [[TMP5]], label [[EXIT:%.*]], label [[OUTER_LOOP_PREHEADER:%.*]]
; CHECK:       outer.loop.preheader:
; CHECK-NEXT:    br label [[OUTER_LOOP:%.*]]
; CHECK:       outer.loop:
; CHECK-NEXT:    [[OUTER_LOOP_ACC:%.*]] = phi i32 [ [[OUTER_LOOP_ACC_NEXT:%.*]], [[OUTER_LOOP_INC:%.*]] ], [ 0, [[OUTER_LOOP_PREHEADER]] ]
; CHECK-NEXT:    [[I:%.*]] = phi i32 [ [[I_NEXT:%.*]], [[OUTER_LOOP_INC]] ], [ 0, [[OUTER_LOOP_PREHEADER]] ]
; CHECK-NEXT:    [[TMP6:%.*]] = icmp sle i32 [[L:%.*]], 0
; CHECK-NEXT:    [[DIV:%.*]] = udiv i32 [[I]], [[MAYBEZERO:%.*]]
; CHECK-NEXT:    br i1 [[TMP6]], label [[OUTER_LOOP_INC]], label [[INNER_LOOP_PREHEADER:%.*]]
; CHECK:       inner.loop.preheader:
; CHECK-NEXT:    br label [[INNER_LOOP:%.*]]
; CHECK:       inner.loop:
; CHECK-NEXT:    [[INNER_LOOP_ACC:%.*]] = phi i32 [ [[INNER_LOOP_ACC_NEXT:%.*]], [[INNER_LOOP]] ], [ [[OUTER_LOOP_ACC]], [[INNER_LOOP_PREHEADER]] ]
; CHECK-NEXT:    [[J:%.*]] = phi i32 [ [[J_NEXT:%.*]], [[INNER_LOOP]] ], [ [[DIV]], [[INNER_LOOP_PREHEADER]] ]
; CHECK-NEXT:    [[WITHIN_BOUNDS:%.*]] = icmp ult i32 [[J]], [[LENGTH:%.*]]
; CHECK-NEXT:    call void (i1, ...) @llvm.experimental.guard(i1 [[WITHIN_BOUNDS]], i32 9) [ "deopt"() ]
; CHECK-NEXT:    [[J_I64:%.*]] = zext i32 [[J]] to i64
; CHECK-NEXT:    [[ARRAY_J_PTR:%.*]] = getelementptr inbounds i32, i32* [[ARRAY:%.*]], i64 [[J_I64]]
; CHECK-NEXT:    [[ARRAY_J:%.*]] = load i32, i32* [[ARRAY_J_PTR]], align 4
; CHECK-NEXT:    [[INNER_LOOP_ACC_NEXT]] = add i32 [[INNER_LOOP_ACC]], [[ARRAY_J]]
; CHECK-NEXT:    [[J_NEXT]] = add nsw i32 [[J]], 1
; CHECK-NEXT:    [[INNER_CONTINUE:%.*]] = icmp slt i32 [[J_NEXT]], [[L]]
; CHECK-NEXT:    br i1 [[INNER_CONTINUE]], label [[INNER_LOOP]], label [[OUTER_LOOP_INC_LOOPEXIT:%.*]]
; CHECK:       outer.loop.inc.loopexit:
; CHECK-NEXT:    [[INNER_LOOP_ACC_NEXT_LCSSA:%.*]] = phi i32 [ [[INNER_LOOP_ACC_NEXT]], [[INNER_LOOP]] ]
; CHECK-NEXT:    br label [[OUTER_LOOP_INC]]
; CHECK:       outer.loop.inc:
; CHECK-NEXT:    [[OUTER_LOOP_ACC_NEXT]] = phi i32 [ [[OUTER_LOOP_ACC]], [[OUTER_LOOP]] ], [ [[INNER_LOOP_ACC_NEXT_LCSSA]], [[OUTER_LOOP_INC_LOOPEXIT]] ]
; CHECK-NEXT:    [[I_NEXT]] = add nsw i32 [[I]], 1
; CHECK-NEXT:    [[OUTER_CONTINUE:%.*]] = icmp slt i32 [[I_NEXT]], [[N]]
; CHECK-NEXT:    br i1 [[OUTER_CONTINUE]], label [[OUTER_LOOP]], label [[EXIT_LOOPEXIT:%.*]]
; CHECK:       exit.loopexit:
; CHECK-NEXT:    [[OUTER_LOOP_ACC_NEXT_LCSSA:%.*]] = phi i32 [ [[OUTER_LOOP_ACC_NEXT]], [[OUTER_LOOP_INC]] ]
; CHECK-NEXT:    br label [[EXIT]]
; CHECK:       exit:
; CHECK-NEXT:    [[RESULT:%.*]] = phi i32 [ 0, [[ENTRY:%.*]] ], [ [[OUTER_LOOP_ACC_NEXT_LCSSA]], [[EXIT_LOOPEXIT]] ]
; CHECK-NEXT:    ret i32 [[RESULT]]
;
entry:
  %tmp5 = icmp sle i32 %n, 0
  br i1 %tmp5, label %exit, label %outer.loop.preheader

outer.loop.preheader:
  br label %outer.loop

outer.loop:
  %outer.loop.acc = phi i32 [ %outer.loop.acc.next, %outer.loop.inc ], [ 0, %outer.loop.preheader ]
  %i = phi i32 [ %i.next, %outer.loop.inc ], [ 0, %outer.loop.preheader ]
  %tmp6 = icmp sle i32 %l, 0
  %div = udiv i32 %i, %maybezero
  br i1 %tmp6, label %outer.loop.inc, label %inner.loop.preheader

inner.loop.preheader:
  br label %inner.loop

inner.loop:
  %inner.loop.acc = phi i32 [ %inner.loop.acc.next, %inner.loop ], [ %outer.loop.acc, %inner.loop.preheader ]
  %j = phi i32 [ %j.next, %inner.loop ], [ %div, %inner.loop.preheader ]

  %within.bounds = icmp ult i32 %j, %length
  call void (i1, ...) @llvm.experimental.guard(i1 %within.bounds, i32 9) [ "deopt"() ]

  %j.i64 = zext i32 %j to i64
  %array.j.ptr = getelementptr inbounds i32, i32* %array, i64 %j.i64
  %array.j = load i32, i32* %array.j.ptr, align 4
  %inner.loop.acc.next = add i32 %inner.loop.acc, %array.j

  %j.next = add nsw i32 %j, 1
  %inner.continue = icmp slt i32 %j.next, %l
  br i1 %inner.continue, label %inner.loop, label %outer.loop.inc

outer.loop.inc:
  %outer.loop.acc.next = phi i32 [ %inner.loop.acc.next, %inner.loop ], [ %outer.loop.acc, %outer.loop ]
  %i.next = add nsw i32 %i, 1
  %outer.continue = icmp slt i32 %i.next, %n
  br i1 %outer.continue, label %outer.loop, label %exit

exit:
  %result = phi i32 [ 0, %entry ], [ %outer.loop.acc.next, %outer.loop.inc ]
  ret i32 %result
}
