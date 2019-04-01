; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -S -loop-predication -loop-predication-skip-profitability-checks=false < %s 2>&1 | FileCheck %s
; RUN: opt -S -loop-predication-skip-profitability-checks=false -passes='require<scalar-evolution>,require<branch-prob>,loop(loop-predication)' < %s 2>&1 | FileCheck %s

; latch block exits to a speculation block. BPI already knows (without prof
; data) that deopt is very rarely
; taken. So we do not predicate this loop using that coarse latch check.
; LatchExitProbability: 0x04000000 / 0x80000000 = 3.12%
; ExitingBlockProbability: 0x7ffa572a / 0x80000000 = 99.98%
define i64 @donot_predicate(i64* nocapture readonly %arg, i32 %length, i64* nocapture readonly %arg2, i64* nocapture readonly %n_addr, i64 %i) {
; CHECK-LABEL: @donot_predicate(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[LENGTH_EXT:%.*]] = zext i32 [[LENGTH:%.*]] to i64
; CHECK-NEXT:    [[N_PRE:%.*]] = load i64, i64* [[N_ADDR:%.*]], align 4
; CHECK-NEXT:    br label [[HEADER:%.*]]
; CHECK:       Header:
; CHECK-NEXT:    [[RESULT_IN3:%.*]] = phi i64* [ [[ARG2:%.*]], [[ENTRY:%.*]] ], [ [[ARG:%.*]], [[LATCH:%.*]] ]
; CHECK-NEXT:    [[J2:%.*]] = phi i64 [ 0, [[ENTRY]] ], [ [[J_NEXT:%.*]], [[LATCH]] ]
; CHECK-NEXT:    [[WITHIN_BOUNDS:%.*]] = icmp ult i64 [[J2]], [[LENGTH_EXT]]
; CHECK-NEXT:    call void (i1, ...) @llvm.experimental.guard(i1 [[WITHIN_BOUNDS]], i32 9) [ "deopt"() ]
; CHECK-NEXT:    [[INNERCMP:%.*]] = icmp eq i64 [[J2]], [[N_PRE]]
; CHECK-NEXT:    [[J_NEXT]] = add nuw nsw i64 [[J2]], 1
; CHECK-NEXT:    br i1 [[INNERCMP]], label [[LATCH]], label [[EXIT:%.*]], !prof !0
; CHECK:       Latch:
; CHECK-NEXT:    [[SPECULATE_TRIP_COUNT:%.*]] = icmp ult i64 [[J_NEXT]], 1048576
; CHECK-NEXT:    br i1 [[SPECULATE_TRIP_COUNT]], label [[HEADER]], label [[DEOPT:%.*]]
; CHECK:       deopt:
; CHECK-NEXT:    [[COUNTED_SPECULATION_FAILED:%.*]] = call i64 (...) @llvm.experimental.deoptimize.i64(i64 30) [ "deopt"(i32 0) ]
; CHECK-NEXT:    ret i64 [[COUNTED_SPECULATION_FAILED]]
; CHECK:       exit:
; CHECK-NEXT:    [[RESULT_IN3_LCSSA:%.*]] = phi i64* [ [[RESULT_IN3]], [[HEADER]] ]
; CHECK-NEXT:    [[RESULT_LE:%.*]] = load i64, i64* [[RESULT_IN3_LCSSA]], align 8
; CHECK-NEXT:    ret i64 [[RESULT_LE]]
;
entry:
  %length.ext = zext i32 %length to i64
  %n.pre = load i64, i64* %n_addr, align 4
  br label %Header

Header:                                          ; preds = %entry, %Latch
  %result.in3 = phi i64* [ %arg2, %entry ], [ %arg, %Latch ]
  %j2 = phi i64 [ 0, %entry ], [ %j.next, %Latch ]
  %within.bounds = icmp ult i64 %j2, %length.ext
  call void (i1, ...) @llvm.experimental.guard(i1 %within.bounds, i32 9) [ "deopt"() ]
  %innercmp = icmp eq i64 %j2, %n.pre
  %j.next = add nuw nsw i64 %j2, 1
  br i1 %innercmp, label %Latch, label %exit, !prof !0

Latch:                                           ; preds = %Header
  %speculate_trip_count = icmp ult i64 %j.next, 1048576
  br i1 %speculate_trip_count, label %Header, label %deopt

deopt:                                            ; preds = %Latch
  %counted_speculation_failed = call i64 (...) @llvm.experimental.deoptimize.i64(i64 30) [ "deopt"(i32 0) ]
  ret i64 %counted_speculation_failed

exit:                                             ; preds = %Header
  %result.in3.lcssa = phi i64* [ %result.in3, %Header ]
  %result.le = load i64, i64* %result.in3.lcssa, align 8
  ret i64 %result.le
}
!0 = !{!"branch_weights", i32 18, i32 104200}

; predicate loop since there's no profile information and BPI concluded all
; exiting blocks have same probability of exiting from loop.
define i64 @predicate(i64* nocapture readonly %arg, i32 %length, i64* nocapture readonly %arg2, i64* nocapture readonly %n_addr, i64 %i) {
; CHECK-LABEL: @predicate(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[LENGTH_EXT:%.*]] = zext i32 [[LENGTH:%.*]] to i64
; CHECK-NEXT:    [[N_PRE:%.*]] = load i64, i64* [[N_ADDR:%.*]], align 4
; CHECK-NEXT:    [[TMP0:%.*]] = icmp ule i64 1048576, [[LENGTH_EXT]]
; CHECK-NEXT:    [[TMP1:%.*]] = icmp ult i64 0, [[LENGTH_EXT]]
; CHECK-NEXT:    [[TMP2:%.*]] = and i1 [[TMP1]], [[TMP0]]
; CHECK-NEXT:    br label [[HEADER:%.*]]
; CHECK:       Header:
; CHECK-NEXT:    [[RESULT_IN3:%.*]] = phi i64* [ [[ARG2:%.*]], [[ENTRY:%.*]] ], [ [[ARG:%.*]], [[LATCH:%.*]] ]
; CHECK-NEXT:    [[J2:%.*]] = phi i64 [ 0, [[ENTRY]] ], [ [[J_NEXT:%.*]], [[LATCH]] ]
; CHECK-NEXT:    [[WITHIN_BOUNDS:%.*]] = icmp ult i64 [[J2]], [[LENGTH_EXT]]
; CHECK-NEXT:    call void (i1, ...) @llvm.experimental.guard(i1 [[TMP2]], i32 9) [ "deopt"() ]
; CHECK-NEXT:    [[INNERCMP:%.*]] = icmp eq i64 [[J2]], [[N_PRE]]
; CHECK-NEXT:    [[J_NEXT]] = add nuw nsw i64 [[J2]], 1
; CHECK-NEXT:    br i1 [[INNERCMP]], label [[LATCH]], label [[EXIT:%.*]]
; CHECK:       Latch:
; CHECK-NEXT:    [[SPECULATE_TRIP_COUNT:%.*]] = icmp ult i64 [[J_NEXT]], 1048576
; CHECK-NEXT:    br i1 [[SPECULATE_TRIP_COUNT]], label [[HEADER]], label [[EXITLATCH:%.*]]
; CHECK:       exitLatch:
; CHECK-NEXT:    ret i64 1
; CHECK:       exit:
; CHECK-NEXT:    [[RESULT_IN3_LCSSA:%.*]] = phi i64* [ [[RESULT_IN3]], [[HEADER]] ]
; CHECK-NEXT:    [[RESULT_LE:%.*]] = load i64, i64* [[RESULT_IN3_LCSSA]], align 8
; CHECK-NEXT:    ret i64 [[RESULT_LE]]
;
entry:
  %length.ext = zext i32 %length to i64
  %n.pre = load i64, i64* %n_addr, align 4
  br label %Header

Header:                                          ; preds = %entry, %Latch
  %result.in3 = phi i64* [ %arg2, %entry ], [ %arg, %Latch ]
  %j2 = phi i64 [ 0, %entry ], [ %j.next, %Latch ]
  %within.bounds = icmp ult i64 %j2, %length.ext
  call void (i1, ...) @llvm.experimental.guard(i1 %within.bounds, i32 9) [ "deopt"() ]
  %innercmp = icmp eq i64 %j2, %n.pre
  %j.next = add nuw nsw i64 %j2, 1
  br i1 %innercmp, label %Latch, label %exit

Latch:                                           ; preds = %Header
  %speculate_trip_count = icmp ult i64 %j.next, 1048576
  br i1 %speculate_trip_count, label %Header, label %exitLatch

exitLatch:                                            ; preds = %Latch
  ret i64 1

exit:                                             ; preds = %Header
  %result.in3.lcssa = phi i64* [ %result.in3, %Header ]
  %result.le = load i64, i64* %result.in3.lcssa, align 8
  ret i64 %result.le
}

; Same as test above but with profiling data that the most probable exit from
; the loop is the header exiting block (not the latch block). So do not predicate.
; LatchExitProbability: 0x000020e1 / 0x80000000 = 0.00%
; ExitingBlockProbability: 0x7ffcbb86 / 0x80000000 = 99.99%
define i64 @donot_predicate_prof(i64* nocapture readonly %arg, i32 %length, i64* nocapture readonly %arg2, i64* nocapture readonly %n_addr, i64 %i) {
; CHECK-LABEL: @donot_predicate_prof(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[LENGTH_EXT:%.*]] = zext i32 [[LENGTH:%.*]] to i64
; CHECK-NEXT:    [[N_PRE:%.*]] = load i64, i64* [[N_ADDR:%.*]], align 4
; CHECK-NEXT:    br label [[HEADER:%.*]]
; CHECK:       Header:
; CHECK-NEXT:    [[RESULT_IN3:%.*]] = phi i64* [ [[ARG2:%.*]], [[ENTRY:%.*]] ], [ [[ARG:%.*]], [[LATCH:%.*]] ]
; CHECK-NEXT:    [[J2:%.*]] = phi i64 [ 0, [[ENTRY]] ], [ [[J_NEXT:%.*]], [[LATCH]] ]
; CHECK-NEXT:    [[WITHIN_BOUNDS:%.*]] = icmp ult i64 [[J2]], [[LENGTH_EXT]]
; CHECK-NEXT:    call void (i1, ...) @llvm.experimental.guard(i1 [[WITHIN_BOUNDS]], i32 9) [ "deopt"() ]
; CHECK-NEXT:    [[INNERCMP:%.*]] = icmp eq i64 [[J2]], [[N_PRE]]
; CHECK-NEXT:    [[J_NEXT]] = add nuw nsw i64 [[J2]], 1
; CHECK-NEXT:    br i1 [[INNERCMP]], label [[LATCH]], label [[EXIT:%.*]], !prof !1
; CHECK:       Latch:
; CHECK-NEXT:    [[SPECULATE_TRIP_COUNT:%.*]] = icmp ult i64 [[J_NEXT]], 1048576
; CHECK-NEXT:    br i1 [[SPECULATE_TRIP_COUNT]], label [[HEADER]], label [[EXITLATCH:%.*]], !prof !2
; CHECK:       exitLatch:
; CHECK-NEXT:    ret i64 1
; CHECK:       exit:
; CHECK-NEXT:    [[RESULT_IN3_LCSSA:%.*]] = phi i64* [ [[RESULT_IN3]], [[HEADER]] ]
; CHECK-NEXT:    [[RESULT_LE:%.*]] = load i64, i64* [[RESULT_IN3_LCSSA]], align 8
; CHECK-NEXT:    ret i64 [[RESULT_LE]]
;
entry:
  %length.ext = zext i32 %length to i64
  %n.pre = load i64, i64* %n_addr, align 4
  br label %Header

Header:                                          ; preds = %entry, %Latch
  %result.in3 = phi i64* [ %arg2, %entry ], [ %arg, %Latch ]
  %j2 = phi i64 [ 0, %entry ], [ %j.next, %Latch ]
  %within.bounds = icmp ult i64 %j2, %length.ext
  call void (i1, ...) @llvm.experimental.guard(i1 %within.bounds, i32 9) [ "deopt"() ]
  %innercmp = icmp eq i64 %j2, %n.pre
  %j.next = add nuw nsw i64 %j2, 1
  br i1 %innercmp, label %Latch, label %exit, !prof !1

Latch:                                           ; preds = %Header
  %speculate_trip_count = icmp ult i64 %j.next, 1048576
  br i1 %speculate_trip_count, label %Header, label %exitLatch, !prof !2

exitLatch:                                            ; preds = %Latch
  ret i64 1

exit:                                             ; preds = %Header
  %result.in3.lcssa = phi i64* [ %result.in3, %Header ]
  %result.le = load i64, i64* %result.in3.lcssa, align 8
  ret i64 %result.le
}
declare i64 @llvm.experimental.deoptimize.i64(...)
declare void @llvm.experimental.guard(i1, ...)

!1 = !{!"branch_weights", i32 104, i32 1042861}
!2 = !{!"branch_weights", i32 255129, i32 1}
