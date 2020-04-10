// NOTE: Assertions have been autogenerated by utils/update_cc_test_checks.py
// REQUIRES: mips-registered-target

// RUN: %cheri_purecap_cc1 -std=c11 -O2 -emit-llvm -o - %s | %cheri_FileCheck %s
// RUN: %cheri_purecap_cc1 -mllvm -cheri-cap-table-abi=pcrel -std=c11 -O2 -S -o - %s | %cheri_FileCheck -check-prefixes=ASM,%cheri_type-ASM %s
int global;

// CHECK-LABEL: define {{[^@]+}}@sizeof_cap() local_unnamed_addr addrspace(200) #0
// CHECK-NEXT:  entry:
// CHECK-NEXT:    ret i64 16
//
unsigned long sizeof_cap(void) {
  return sizeof(void* __capability);
  // ASM-LABEL: sizeof_cap
  // ASM: cjr     $c17
  // ASM: daddiu   $2, $zero, [[#CAP_SIZE]]
}

typedef struct {
  __uintcap_t intptr;
} IntptrStruct;

// CHECK-LABEL: define {{[^@]+}}@set_int() local_unnamed_addr addrspace(200) #0
// CHECK-NEXT:  entry:
// CHECK-NEXT:    ret { i8 addrspace(200)* } zeroinitializer
//
IntptrStruct set_int() {
  IntptrStruct p;
  p.intptr = 0;
  return p;
  // ASM-LABEL: set_int
  // ASM:  cjr     $c17
  // ASM-NEXT:  cgetnull $c3
}

// CHECK-LABEL: define {{[^@]+}}@set_int2
// CHECK-SAME: (i8 addrspace(200)* inreg [[P_COERCE:%.*]]) local_unnamed_addr addrspace(200) #0
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[DOTFCA_0_INSERT:%.*]] = insertvalue { i8 addrspace(200)* } undef, i8 addrspace(200)* [[P_COERCE]], 0
// CHECK-NEXT:    ret { i8 addrspace(200)* } [[DOTFCA_0_INSERT]]
//
IntptrStruct set_int2(IntptrStruct p) {
  return p;
  // ASM-LABEL: set_int2
  // ASM:       cjr     $c17
  // ASM-NEXT:  nop
}

// CHECK-LABEL: define {{[^@]+}}@set_int3
// CHECK-SAME: (i8 addrspace(200)* inreg readnone returned [[P_COERCE:%.*]]) local_unnamed_addr addrspace(200) #0
// CHECK-NEXT:  entry:
// CHECK-NEXT:    ret i8 addrspace(200)* [[P_COERCE]]
//
__uintcap_t set_int3(IntptrStruct p) {
  return p.intptr;
  // ASM-LABEL: set_int3
  // ASM:       cjr     $c17
  // ASM-NEXT:  nop
}

typedef struct {
  __uintcap_t intptr;
  void* __capability ptr;
} TwoCapsStruct;

// CHECK-LABEL: define {{[^@]+}}@two_caps_struct
// CHECK-SAME: (%struct.TwoCapsStruct addrspace(200)* noalias nocapture sret align 16 [[AGG_RESULT:%.*]], i64 [[TMP0:%.*]], i8 addrspace(200)* inreg [[IN_COERCE0:%.*]], i8 addrspace(200)* inreg [[IN_COERCE1:%.*]]) local_unnamed_addr addrspace(200) #2
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP1:%.*]] = getelementptr i8, i8 addrspace(200)* [[IN_COERCE0]], i64 1
// CHECK-NEXT:    [[INTPTR1:%.*]] = getelementptr inbounds [[STRUCT_TWOCAPSSTRUCT:%.*]], [[STRUCT_TWOCAPSSTRUCT]] addrspace(200)* [[AGG_RESULT]], i64 0, i32 0
// CHECK-NEXT:    store i8 addrspace(200)* [[TMP1]], i8 addrspace(200)* addrspace(200)* [[INTPTR1]], align 16, !tbaa !2
// CHECK-NEXT:    [[PTR2:%.*]] = getelementptr inbounds [[STRUCT_TWOCAPSSTRUCT]], [[STRUCT_TWOCAPSSTRUCT]] addrspace(200)* [[AGG_RESULT]], i64 0, i32 1
// CHECK-NEXT:    store i8 addrspace(200)* [[IN_COERCE1]], i8 addrspace(200)* addrspace(200)* [[PTR2]], align 16, !tbaa !8
// CHECK-NEXT:    ret void
//
TwoCapsStruct two_caps_struct(TwoCapsStruct in) {
  TwoCapsStruct t;
  t.intptr = in.intptr + 1;
  t.ptr = in.ptr;
  return t;
  // argument is split up into two cap regs, but return value is indirect
  // ASM-LABEL: two_caps_struct:
  // ASM:       cincoffset      $c1, $c4, 1
  // ASM-NEXT:  csc     $c1, $zero, 0($c3)
  // ASM-NEXT:  cjr     $c17
  // ASM-NEXT:  csc     $c5, $zero, [[#CAP_SIZE]]($c3)
}

typedef struct {
  __uintcap_t cap1;
  __uintcap_t cap2;
  __uintcap_t cap3;
} ThreeCapsStruct;

// CHECK-LABEL: define {{[^@]+}}@three_caps_struct
// CHECK-SAME: (%struct.ThreeCapsStruct addrspace(200)* noalias nocapture sret align 16 [[AGG_RESULT:%.*]], i64 [[TMP0:%.*]], i8 addrspace(200)* inreg [[IN_COERCE0:%.*]], i8 addrspace(200)* inreg [[IN_COERCE1:%.*]], i8 addrspace(200)* inreg [[IN_COERCE2:%.*]]) local_unnamed_addr addrspace(200) #2
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP1:%.*]] = getelementptr i8, i8 addrspace(200)* [[IN_COERCE0]], i64 1
// CHECK-NEXT:    [[CAP11:%.*]] = getelementptr inbounds [[STRUCT_THREECAPSSTRUCT:%.*]], [[STRUCT_THREECAPSSTRUCT]] addrspace(200)* [[AGG_RESULT]], i64 0, i32 0
// CHECK-NEXT:    store i8 addrspace(200)* [[TMP1]], i8 addrspace(200)* addrspace(200)* [[CAP11]], align 16, !tbaa !9
// CHECK-NEXT:    [[TMP2:%.*]] = getelementptr i8, i8 addrspace(200)* [[IN_COERCE1]], i64 2
// CHECK-NEXT:    [[CAP23:%.*]] = getelementptr inbounds [[STRUCT_THREECAPSSTRUCT]], [[STRUCT_THREECAPSSTRUCT]] addrspace(200)* [[AGG_RESULT]], i64 0, i32 1
// CHECK-NEXT:    store i8 addrspace(200)* [[TMP2]], i8 addrspace(200)* addrspace(200)* [[CAP23]], align 16, !tbaa !11
// CHECK-NEXT:    [[TMP3:%.*]] = getelementptr i8, i8 addrspace(200)* [[IN_COERCE2]], i64 3
// CHECK-NEXT:    [[CAP35:%.*]] = getelementptr inbounds [[STRUCT_THREECAPSSTRUCT]], [[STRUCT_THREECAPSSTRUCT]] addrspace(200)* [[AGG_RESULT]], i64 0, i32 2
// CHECK-NEXT:    store i8 addrspace(200)* [[TMP3]], i8 addrspace(200)* addrspace(200)* [[CAP35]], align 16, !tbaa !12
// CHECK-NEXT:    ret void
//
ThreeCapsStruct three_caps_struct(ThreeCapsStruct in) {
  ThreeCapsStruct t;
  t.cap1 = in.cap1 + 1;
  t.cap2 = in.cap2 + 2;
  t.cap3 = in.cap3 + 3;
  return t;
  // argument is split up into two cap regs, but return value is indirect
  // ASM-LABEL: three_caps_struct:
  // ASM:       cincoffset $c1, $c4, 1
  // ASM-NEXT:  csc $c1, $zero, 0($c3)
  // ASM-NEXT:  cincoffset $c1, $c5, 2
  // ASM-NEXT:  csc $c1, $zero, [[#CAP_SIZE]]($c3)
  // ASM-NEXT:  cincoffset $c1, $c6, 3
  // ASM-NEXT:  cjr     $c17
  // ASM-NEXT:  csc     $c1, $zero, [[#CAP_SIZE * 2]]($c3)
}

typedef union {
  __uintcap_t intptr;
  void * __capability ptr;
  long longvalue;
} IntCapSizeUnion;
_Static_assert(sizeof(IntCapSizeUnion) == sizeof(void*), "");

// CHECK-LABEL: define {{[^@]+}}@intcap_size_union() local_unnamed_addr addrspace(200) #0
// CHECK-NEXT:  entry:
// CHECK-NEXT:    ret i8 addrspace(200)* bitcast (i32 addrspace(200)* @global to i8 addrspace(200)*)
//
IntCapSizeUnion intcap_size_union() {
  IntCapSizeUnion i;
  i.ptr = &global;
  return i;
  // ASM-LABEL: intcap_size_union
  // ASM: clcbi $c3, %captab20(global)($c{{.+}})
}

// Check that a union with size > intcap_t is not returned as a value
typedef union {
  __uintcap_t intptr;
  void* __capability ptr;
  long longvalue;
  char buffer[sizeof(__uintcap_t) + 1];
} GreaterThanIntCapSizeUnion;
_Static_assert(sizeof(GreaterThanIntCapSizeUnion) > sizeof(void*), "");

// CHECK-LABEL: define {{[^@]+}}@greater_than_intcap_size_union
// CHECK-SAME: (%union.GreaterThanIntCapSizeUnion addrspace(200)* noalias nocapture sret align 16 [[AGG_RESULT:%.*]]) local_unnamed_addr addrspace(200) #2
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[PTR:%.*]] = getelementptr inbounds [[UNION_GREATERTHANINTCAPSIZEUNION:%.*]], [[UNION_GREATERTHANINTCAPSIZEUNION]] addrspace(200)* [[AGG_RESULT]], i64 0, i32 0
// CHECK-NEXT:    store i8 addrspace(200)* bitcast (i32 addrspace(200)* @global to i8 addrspace(200)*), i8 addrspace(200)* addrspace(200)* [[PTR]], align 16, !tbaa !13
// CHECK-NEXT:    ret void
//
GreaterThanIntCapSizeUnion greater_than_intcap_size_union() {
  GreaterThanIntCapSizeUnion g;
  g.ptr = &global;
  return g;
  // ASM-LABEL: greater_than_intcap_size_union
  // ASM:       clcbi $c1, %captab20(global)($c{{.+}})
  // ASM-NEXT:  cjr     $c17
  // ASM-NEXT:  csc     $c1, $zero, 0($c3)
}

// Check that we didn't break the normal case of returning small structs in integer registers
typedef struct {
  long l1;
} OneLong;

// CHECK-LABEL: define {{[^@]+}}@one_long() local_unnamed_addr addrspace(200) #0
// CHECK-NEXT:  entry:
// CHECK-NEXT:    ret { i64 } { i64 1 }
//
OneLong one_long() {
  OneLong o = { 1 };
  return o;
  // ASM-LABEL: one_long
  // ASM:       cjr     $c17
  // ASM-NEXT:  daddiu  $2, $zero, 1
}
typedef struct {
  long l1;
  long l2;
} TwoLongs;

// CHECK-LABEL: define {{[^@]+}}@two_longs() local_unnamed_addr addrspace(200) #0
// CHECK-NEXT:  entry:
// CHECK-NEXT:    ret { i64, i64 } { i64 1, i64 2 }
//
TwoLongs two_longs() {
  TwoLongs t = { 1, 2 };
  return t;
  // ASM-LABEL: two_longs
  // ASM:       daddiu  $2, $zero, 1
  // ASM-NEXT:  cjr     $c17
  // ASM-NEXT:  daddiu  $3, $zero, 2
}

typedef struct {
  long l1;
  long l2;
  long l3;
} ThreeLongs;

// CHECK-LABEL: define {{[^@]+}}@three_longs
// CHECK-SAME: (%struct.ThreeLongs addrspace(200)* noalias nocapture sret align 8 [[AGG_RESULT:%.*]]) local_unnamed_addr addrspace(200) #3
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = bitcast [[STRUCT_THREELONGS:%.*]] addrspace(200)* [[AGG_RESULT]] to i8 addrspace(200)*
// CHECK-NEXT:    tail call void @llvm.memcpy.p200i8.p200i8.i64(i8 addrspace(200)* nonnull align 8 dereferenceable(24) [[TMP0]], i8 addrspace(200)* nonnull align 8 dereferenceable(24) bitcast (%struct.ThreeLongs addrspace(200)* @__const.three_longs.t to i8 addrspace(200)*), i64 24, i1 false)
// CHECK-NEXT:    ret void
//
ThreeLongs three_longs() {
  ThreeLongs t = { 1, 2, 3 };
  return t;
  // ASM-LABEL: three_longs
  // Clang now uses a memcpy from a global for cheri128
  // CHERI128-ASM: clcbi $c4, %captab20(.L__const.three_longs.t)($c{{.+}})
  // CHERI128-ASM: clcbi   $c12, %capcall20(memcpy)($c{{.+}})
  // For cheri256 clang will inline the memcpy from a global (since it is smaller than 1 cap)
  // CHERI256-ASM:      clcbi $c1, %captab20(.L__const.three_longs.t)($c{{.+}})
  // CHERI256-ASM-NEXT: cld	$1, $zero, 16($c1)
  // CHERI256-ASM-NEXT: cld	$2, $zero, 8($c1)
  // CHERI256-ASM-NEXT: cld	$3, $zero, 0($c1)
  // CHERI256-ASM-NEXT: csd	$1, $zero, 16($c3)
  // CHERI256-ASM-NEXT: csd	$2, $zero, 8($c3)
  // CHERI256-ASM-NEXT: cjr	$c17
  // CHERI256-ASM-NEXT: csd	$3, $zero, 0($c3)
}

typedef struct {
  int l1;
  long l2;
} IntAndLong;

// CHECK-LABEL: define {{[^@]+}}@int_and_long() local_unnamed_addr addrspace(200) #0
// CHECK-NEXT:  entry:
// CHECK-NEXT:    ret { i64, i64 } { i64 8589934592, i64 3 }
//
IntAndLong int_and_long() {
  // Note: this looks wrong, but we actually have to use the in-memory big-endian representation for the registers!
  // See: https://github.com/CTSRD-CHERI/llvm-project/issues/310#issuecomment-497094466
  // Structs, unions, or other composite types are treated as a sequence of doublewords,
  // and are passed in integer or floating point registers as though they were simple
  // scalar parameters to the extent that they fit, with any excess on the stack packed
  // according to the normal memory layout of the object.
  // More specifically:
  //   – Regardless of the struct field structure, it is treated as a
  //     sequence of 64-bit chunks. If a chunk consists solely of a double
  //     float field (but not a double, which is part of a union), it is
  //     passed in a floating point register. Any other chunk is passed in
  //     an integer register
  //
  // ASM-LABEL: int_and_long
  // ASM:      daddiu	$1, $zero, 1
  // ASM-NEXT: dsll	$2, $1, 33
  // ASM-NEXT: cjr	$c17
  // ASM-NEXT: daddiu	$3, $zero, 3
  IntAndLong t = { 2, 3 };
  return t;
}

extern IntAndLong extern_int_and_long();

// CHECK-LABEL: define {{[^@]+}}@read_int_and_long_1() local_unnamed_addr addrspace(200) #3
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[CALL:%.*]] = tail call inreg { i64, i64 } bitcast ({ i64, i64 } (...) addrspace(200)* @extern_int_and_long to { i64, i64 } () addrspace(200)*)() #5
// CHECK-NEXT:    [[TMP0:%.*]] = extractvalue { i64, i64 } [[CALL]], 0
// CHECK-NEXT:    [[COERCE_SROA_0_0_EXTRACT_SHIFT:%.*]] = lshr i64 [[TMP0]], 32
// CHECK-NEXT:    [[COERCE_SROA_0_0_EXTRACT_TRUNC:%.*]] = trunc i64 [[COERCE_SROA_0_0_EXTRACT_SHIFT]] to i32
// CHECK-NEXT:    ret i32 [[COERCE_SROA_0_0_EXTRACT_TRUNC]]
//
int read_int_and_long_1() {
  // This function needs to shift the l1 value by 32 to get the int value
  // (since the registers hold the in-memory representation)
  return extern_int_and_long().l1;
  // ASM-LABEL: read_int_and_long_1:
  // ASM: clcbi	$c12, %capcall20(extern_int_and_long)($c1)
  // ASM-NEXT: cjalr	$c12, $c17
  // ASM-NEXT: nop
  // This shift undoes the left-shift from int_and_long():
  // ASM-NEXT: dsra	$2, $2, 32
  // ASM-NEXT: clc	$c17, $zero, 0($c11)
  // ASM-NEXT: cjr	$c17
  // ASM-NEXT: cincoffset	$c11, $c11, [[#CAP_SIZE]]
}

// CHECK-LABEL: define {{[^@]+}}@read_int_and_long_2() local_unnamed_addr addrspace(200) #3
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[CALL:%.*]] = tail call inreg { i64, i64 } bitcast ({ i64, i64 } (...) addrspace(200)* @extern_int_and_long to { i64, i64 } () addrspace(200)*)() #5
// CHECK-NEXT:    [[TMP0:%.*]] = extractvalue { i64, i64 } [[CALL]], 1
// CHECK-NEXT:    ret i64 [[TMP0]]
//
long read_int_and_long_2() {
  // ASM-LABEL: read_int_and_long_2:
  // ASM: clcbi	$c12, %capcall20(extern_int_and_long)($c1)
  // ASM-NEXT: cjalr	$c12, $c17
  // ASM-NEXT: nop
  // Read the second 64-bit value from $v1 and move it to $v0
  // ASM-NEXT: move $2, $3
  // ASM-NEXT: clc	$c17, $zero, 0($c11)
  // ASM-NEXT: cjr	$c17
  // ASM-NEXT: cincoffset	$c11, $c11, [[#CAP_SIZE]]
  return extern_int_and_long().l2;
}

// CHECK-LABEL: define {{[^@]+}}@int_and_long2
// CHECK-SAME: (i64 inreg [[ARG_COERCE0:%.*]], i64 inreg [[ARG_COERCE1:%.*]]) local_unnamed_addr addrspace(200) #0
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[DOTFCA_0_INSERT:%.*]] = insertvalue { i64, i64 } undef, i64 [[ARG_COERCE0]], 0
// CHECK-NEXT:    [[DOTFCA_1_INSERT:%.*]] = insertvalue { i64, i64 } [[DOTFCA_0_INSERT]], i64 [[ARG_COERCE1]], 1
// CHECK-NEXT:    ret { i64, i64 } [[DOTFCA_1_INSERT]]
//
IntAndLong int_and_long2(IntAndLong arg) {
  // TODO-ASM: daddiu  $2, $zero, 3
  // ASM-LABEL: int_and_long2
  // ASM:     move     $2, $4
  // ASM-NEXT: cjr     $c17
  // ASM-NEXT: move     $3, $5
  return arg;
}
