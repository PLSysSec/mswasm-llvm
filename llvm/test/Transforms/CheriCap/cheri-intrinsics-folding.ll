; RUN: %cheri_opt -S -cheri-fold-intrisics %s -o %t.ll
; RUN: FileCheck %s -input-file %t.ll
; Check that the dynamic GEP is folded properly
; RUN: %cheri_llc -O2 %t.ll -o - | FileCheck %s -check-prefix DYNAMIC-GEP-ASM
target datalayout = "E-m:e-pf200:256:256-i8:8:32-i16:16:32-i64:64-n32:64-S128-A200"
target triple = "cheri-unknown-freebsd"

declare i64 @check_fold(i64) #1
declare i8 addrspace(200)* @check_fold_i8ptr(i8 addrspace(200)*) #1

declare i64 @llvm.cheri.cap.base.get.i64(i8 addrspace(200)*) #1
declare i8 addrspace(200)* @llvm.cheri.cap.base.set(i8 addrspace(200)*, i64) #1
declare i64 @llvm.cheri.cap.offset.get.i64(i8 addrspace(200)*) #1
declare i64 @llvm.cheri.cap.address.get.i64(i8 addrspace(200)*) #1
declare i8 addrspace(200)* @llvm.cheri.cap.offset.set.i64(i8 addrspace(200)*, i64) #1
declare i8 addrspace(200)* @llvm.cheri.cap.address.set.i64(i8 addrspace(200)*, i64) #1
declare i8 addrspace(200)* @llvm.cheri.cap.offset.increment.i64(i8 addrspace(200)*, i64) #1
declare i64 @llvm.cheri.cap.length.get.i64(i8 addrspace(200)*) #1
declare i8 addrspace(200)* @llvm.cheri.cap.length.set(i8 addrspace(200)*, i64) #1
declare i64 @llvm.cheri.cap.perms.get.i64(i8 addrspace(200)*) #1
declare i8 addrspace(200)* @llvm.cheri.cap.perms.and.i64(i8 addrspace(200)*, i64) #1
declare i64 @llvm.cheri.cap.flags.get.i64(i8 addrspace(200)*) #1
declare i64 @llvm.cheri.cap.type.get.i64(i8 addrspace(200)*) #1
declare i1 @llvm.cheri.cap.sealed.get(i8 addrspace(200)*) #1
declare i1 @llvm.cheri.cap.tag.get(i8 addrspace(200)*) #1

define i64 @null_get_length() #1 {
  %ret = tail call i64 @llvm.cheri.cap.length.get.i64(i8 addrspace(200)* null)
  ret i64 %ret
  ; CHECK-LABEL: @null_get_length()
  ; CHECK-NEXT: ret i64 -1
}

define i64 @null_get_offset() #1 {
  %ret = tail call i64 @llvm.cheri.cap.offset.get.i64(i8 addrspace(200)* null)
  ret i64 %ret
  ; CHECK-LABEL: @null_get_offset()
  ; CHECK-NEXT: ret i64 0
}

define i64 @null_get_base() #1 {
  %ret = tail call i64 @llvm.cheri.cap.base.get.i64(i8 addrspace(200)* null)
  ret i64 %ret
  ; CHECK-LABEL: @null_get_base()
  ; CHECK-NEXT: ret i64 0
}

define i64 @null_get_address() #1 {
  %ret = tail call i64 @llvm.cheri.cap.address.get.i64(i8 addrspace(200)* null)
  ret i64 %ret
  ; CHECK-LABEL: @null_get_address()
  ; CHECK-NEXT: ret i64 0
}

define i64 @null_get_perms() #1 {
  %ret = tail call i64 @llvm.cheri.cap.perms.get.i64(i8 addrspace(200)* null)
  ret i64 %ret
  ; CHECK-LABEL: @null_get_perms()
  ; CHECK-NEXT: ret i64 0
}

define i64 @null_get_flags() #1 {
  %ret = tail call i64 @llvm.cheri.cap.flags.get.i64(i8 addrspace(200)* null)
  ret i64 %ret
  ; CHECK-LABEL: @null_get_flags()
  ; CHECK-NEXT: ret i64 0
}

define i64 @null_get_type() #1 {
  %ret = tail call i64 @llvm.cheri.cap.type.get.i64(i8 addrspace(200)* null)
  ret i64 %ret
  ; CHECK-LABEL: @null_get_type()
  ; CHECK-NEXT: ret i64 -1
}

define i64 @null_get_sealed() #1 {
  %ret = tail call i1 @llvm.cheri.cap.sealed.get(i8 addrspace(200)* null)
  %ret.ext = zext i1 %ret to i64
  ret i64 %ret.ext
  ; CHECK-LABEL: @null_get_sealed()
  ; CHECK-NEXT: %ret.ext = zext i1 false to i64
  ; CHECK-NEXT: ret i64 %ret.ext
}

define i64 @null_get_tag() #1 {
  %ret = tail call i1 @llvm.cheri.cap.tag.get(i8 addrspace(200)* null)
  %ret.ext = zext i1 %ret to i64
  ret i64 %ret.ext
  ; CHECK-LABEL: @null_get_tag()
  ; CHECK-NEXT: %ret.ext = zext i1 false to i64
  ; CHECK-NEXT: ret i64 %ret.ext
}

define void @infer_values_from_null_set_offset() #1 {
  ; CHECK-LABEL: @infer_values_from_null_set_offset()
  %with_offset = tail call i8 addrspace(200)* @llvm.cheri.cap.offset.set.i64(i8 addrspace(200)* null, i64 123456)

  %base = tail call i64 @llvm.cheri.cap.base.get.i64(i8 addrspace(200)* %with_offset)
  %base_check = tail call i64 @check_fold(i64 %base)
  ; CHECK:  %base_check = tail call i64 @check_fold(i64 0)

  %length = tail call i64 @llvm.cheri.cap.length.get.i64(i8 addrspace(200)* %with_offset)
  %length_check = tail call i64 @check_fold(i64 %length)
  ; CHECK:  %length_check = tail call i64 @check_fold(i64 -1)

  %offset = tail call i64 @llvm.cheri.cap.offset.get.i64(i8 addrspace(200)* %with_offset)
  %offset_check = tail call i64 @check_fold(i64 %offset)
  ; CHECK:  %offset_check = tail call i64 @check_fold(i64 123456)

  %address = tail call i64 @llvm.cheri.cap.address.get.i64(i8 addrspace(200)* %with_offset)
  %address_check = tail call i64 @check_fold(i64 %address)
  ; CHECK:  %address_check = tail call i64 @check_fold(i64 123456)

  %type = tail call i64 @llvm.cheri.cap.type.get.i64(i8 addrspace(200)* %with_offset)
  %type_check = tail call i64 @check_fold(i64 %type)
  ; CHECK:  %type_check = tail call i64 @check_fold(i64 -1)

  %sealed = tail call i1 @llvm.cheri.cap.sealed.get(i8 addrspace(200)* %with_offset)
  %sealed.ext = zext i1 %sealed to i64
  %sealed_check = tail call i64 @check_fold(i64 %sealed.ext)
  ; CHECK:  %sealed.ext = zext i1 false to i64
  ; CHECK:  %sealed_check = tail call i64 @check_fold(i64 %sealed.ext)

  %perms = tail call i64 @llvm.cheri.cap.perms.get.i64(i8 addrspace(200)* %with_offset)
  %perms_check = tail call i64 @check_fold(i64 %perms)
  ; CHECK:  %perms_check = tail call i64 @check_fold(i64 0)

  %flags = tail call i64 @llvm.cheri.cap.flags.get.i64(i8 addrspace(200)* %with_offset)
  %flags_check = tail call i64 @check_fold(i64 %flags)
  ; CHECK:  %flags_check = tail call i64 @check_fold(i64 0)

  %tag = tail call i1 @llvm.cheri.cap.tag.get(i8 addrspace(200)* %with_offset)
  %tag.ext = zext i1 %tag to i64
  %tag_check = tail call i64 @check_fold(i64 %tag.ext)
  ; CHECK:  %tag.ext = zext i1 false to i64
  ; CHECK:  %tag_check = tail call i64 @check_fold(i64 %tag.ext)

  ret void
  ; CHECK: ret void
}

define void @infer_values_from_null_set_address() #1 {
  ; CHECK-LABEL: @infer_values_from_null_set_address()
  %with_offset = tail call i8 addrspace(200)* @llvm.cheri.cap.address.set.i64(i8 addrspace(200)* null, i64 123456)

  %base = tail call i64 @llvm.cheri.cap.base.get.i64(i8 addrspace(200)* %with_offset)
  %base_check = tail call i64 @check_fold(i64 %base)
  ; CHECK:  %base_check = tail call i64 @check_fold(i64 0)

  %length = tail call i64 @llvm.cheri.cap.length.get.i64(i8 addrspace(200)* %with_offset)
  %length_check = tail call i64 @check_fold(i64 %length)
  ; CHECK:  %length_check = tail call i64 @check_fold(i64 -1)

  %offset = tail call i64 @llvm.cheri.cap.offset.get.i64(i8 addrspace(200)* %with_offset)
  %offset_check = tail call i64 @check_fold(i64 %offset)
  ; CHECK:  %offset_check = tail call i64 @check_fold(i64 123456)

  %address = tail call i64 @llvm.cheri.cap.address.get.i64(i8 addrspace(200)* %with_offset)
  %address_check = tail call i64 @check_fold(i64 %address)
  ; CHECK:  %address_check = tail call i64 @check_fold(i64 123456)

  %type = tail call i64 @llvm.cheri.cap.type.get.i64(i8 addrspace(200)* %with_offset)
  %type_check = tail call i64 @check_fold(i64 %type)
  ; CHECK:  %type_check = tail call i64 @check_fold(i64 -1)

  %sealed = tail call i1 @llvm.cheri.cap.sealed.get(i8 addrspace(200)* %with_offset)
  %sealed.ext = zext i1 %sealed to i64
  %sealed_check = tail call i64 @check_fold(i64 %sealed.ext)
  ; CHECK:  %sealed.ext = zext i1 false to i64
  ; CHECK:  %sealed_check = tail call i64 @check_fold(i64 %sealed.ext)

  %perms = tail call i64 @llvm.cheri.cap.perms.get.i64(i8 addrspace(200)* %with_offset)
  %perms_check = tail call i64 @check_fold(i64 %perms)
  ; CHECK:  %perms_check = tail call i64 @check_fold(i64 0)

  %flags = tail call i64 @llvm.cheri.cap.flags.get.i64(i8 addrspace(200)* %with_offset)
  %flags_check = tail call i64 @check_fold(i64 %flags)
  ; CHECK:  %flags_check = tail call i64 @check_fold(i64 0)

  %tag = tail call i1 @llvm.cheri.cap.tag.get(i8 addrspace(200)* %with_offset)
  %tag.ext = zext i1 %tag to i64
  %tag_check = tail call i64 @check_fold(i64 %tag.ext)
  ; CHECK:  %tag.ext = zext i1 false to i64
  ; CHECK:  %tag_check = tail call i64 @check_fold(i64 %tag.ext)

  ret void
  ; CHECK: ret void
}

; Only the getaddr should be inferred, all other values are unknown if we call setaddr on an unknown value:
define void @infer_values_from_arg_set_address(i8 addrspace(200)* %arg) #1 {
  ; CHECK-LABEL: @infer_values_from_arg_set_address(i8 addrspace(200)*
  %with_offset = tail call i8 addrspace(200)* @llvm.cheri.cap.address.set.i64(i8 addrspace(200)* %arg, i64 123456)

  %base = tail call i64 @llvm.cheri.cap.base.get.i64(i8 addrspace(200)* %with_offset)
  %base_check = tail call i64 @check_fold(i64 %base)
  ; CHECK: %base = tail call i64 @llvm.cheri.cap.base.get.i64(i8 addrspace(200)* %with_offset)
  ; CHECK: %base_check = tail call i64 @check_fold(i64 %base)

  %length = tail call i64 @llvm.cheri.cap.length.get.i64(i8 addrspace(200)* %with_offset)
  %length_check = tail call i64 @check_fold(i64 %length)
  ; CHECK: %length = tail call i64 @llvm.cheri.cap.length.get.i64(i8 addrspace(200)* %with_offset)
  ; CHECK: %length_check = tail call i64 @check_fold(i64 %length)

  %offset = tail call i64 @llvm.cheri.cap.offset.get.i64(i8 addrspace(200)* %with_offset)
  %offset_check = tail call i64 @check_fold(i64 %offset)
  ; CHECK: %offset = tail call i64 @llvm.cheri.cap.offset.get.i64(i8 addrspace(200)* %with_offset)
  ; CHECK: %offset_check = tail call i64 @check_fold(i64 %offset)

  %address = tail call i64 @llvm.cheri.cap.address.get.i64(i8 addrspace(200)* %with_offset)
  %address_check = tail call i64 @check_fold(i64 %address)
  ; CHECK-NOT: @llvm.cheri.cap.address.get.i64
  ; CHECK: %address_check = tail call i64 @check_fold(i64 123456)

  %type = tail call i64 @llvm.cheri.cap.type.get.i64(i8 addrspace(200)* %with_offset)
  %type_check = tail call i64 @check_fold(i64 %type)
  ; CHECK: %type = tail call i64 @llvm.cheri.cap.type.get.i64(i8 addrspace(200)* %with_offset)
  ; CHECK: %type_check = tail call i64 @check_fold(i64 %type)

  %sealed = tail call i1 @llvm.cheri.cap.sealed.get(i8 addrspace(200)* %with_offset)
  %sealed.ext = zext i1 %sealed to i64
  %sealed_check = tail call i64 @check_fold(i64 %sealed.ext)
  ; CHECK: %sealed = tail call i1 @llvm.cheri.cap.sealed.get(i8 addrspace(200)* %with_offset)
  ; CHECK: %sealed.ext = zext i1 %sealed to i64
  ; CHECK: %sealed_check = tail call i64 @check_fold(i64 %sealed.ext)

  %perms = tail call i64 @llvm.cheri.cap.perms.get.i64(i8 addrspace(200)* %with_offset)
  %perms_check = tail call i64 @check_fold(i64 %perms)
  ; CHECK: %perms = tail call i64 @llvm.cheri.cap.perms.get.i64(i8 addrspace(200)* %with_offset)
  ; CHECK: %perms_check = tail call i64 @check_fold(i64 %perms)

  %flags = tail call i64 @llvm.cheri.cap.flags.get.i64(i8 addrspace(200)* %with_offset)
  %flags_check = tail call i64 @check_fold(i64 %flags)
  ; CHECK: %flags = tail call i64 @llvm.cheri.cap.flags.get.i64(i8 addrspace(200)* %with_offset)
  ; CHECK: %flags_check = tail call i64 @check_fold(i64 %flags)

  %tag = tail call i1 @llvm.cheri.cap.tag.get(i8 addrspace(200)* %with_offset)
  %tag.ext = zext i1 %tag to i64
  %tag_check = tail call i64 @check_fold(i64 %tag.ext)
  ; CHECK: %tag = tail call i1 @llvm.cheri.cap.tag.get(i8 addrspace(200)* %with_offset)
  ; CHECK: %tag.ext = zext i1 %tag to i64
  ; CHECK: %tag_check = tail call i64 @check_fold(i64 %tag.ext)

  ret void
  ; CHECK: ret void
}

; Only the getoffset should be inferred, all other values are unknown if we call setoffset on an unknown value:
define void @infer_values_from_arg_set_offset(i8 addrspace(200)* %arg) #1 {
  ; CHECK-LABEL: @infer_values_from_arg_set_offset(i8 addrspace(200)*
  %with_offset = tail call i8 addrspace(200)* @llvm.cheri.cap.offset.set.i64(i8 addrspace(200)* %arg, i64 123456)

  %base = tail call i64 @llvm.cheri.cap.base.get.i64(i8 addrspace(200)* %with_offset)
  %base_check = tail call i64 @check_fold(i64 %base)
  ; CHECK: %base = tail call i64 @llvm.cheri.cap.base.get.i64(i8 addrspace(200)* %with_offset)
  ; CHECK: %base_check = tail call i64 @check_fold(i64 %base)

  %length = tail call i64 @llvm.cheri.cap.length.get.i64(i8 addrspace(200)* %with_offset)
  %length_check = tail call i64 @check_fold(i64 %length)
  ; CHECK: %length = tail call i64 @llvm.cheri.cap.length.get.i64(i8 addrspace(200)* %with_offset)
  ; CHECK: %length_check = tail call i64 @check_fold(i64 %length)

  %offset = tail call i64 @llvm.cheri.cap.offset.get.i64(i8 addrspace(200)* %with_offset)
  %offset_check = tail call i64 @check_fold(i64 %offset)
  ; CHECK-NOT: @llvm.cheri.cap.offset.get.i64
  ; CHECK: %offset_check = tail call i64 @check_fold(i64 123456)

  %address = tail call i64 @llvm.cheri.cap.address.get.i64(i8 addrspace(200)* %with_offset)
  %address_check = tail call i64 @check_fold(i64 %address)
  ; CHECK: %address = tail call i64 @llvm.cheri.cap.address.get.i64(i8 addrspace(200)* %with_offset)
  ; CHECK: %address_check = tail call i64 @check_fold(i64 %address)

  %type = tail call i64 @llvm.cheri.cap.type.get.i64(i8 addrspace(200)* %with_offset)
  %type_check = tail call i64 @check_fold(i64 %type)
  ; CHECK: %type = tail call i64 @llvm.cheri.cap.type.get.i64(i8 addrspace(200)* %with_offset)
  ; CHECK: %type_check = tail call i64 @check_fold(i64 %type)

  %sealed = tail call i1 @llvm.cheri.cap.sealed.get(i8 addrspace(200)* %with_offset)
  %sealed.ext = zext i1 %sealed to i64
  %sealed_check = tail call i64 @check_fold(i64 %sealed.ext)
  ; CHECK: %sealed = tail call i1 @llvm.cheri.cap.sealed.get(i8 addrspace(200)* %with_offset)
  ; CHECK: %sealed.ext = zext i1 %sealed to i64
  ; CHECK: %sealed_check = tail call i64 @check_fold(i64 %sealed.ext)

  %perms = tail call i64 @llvm.cheri.cap.perms.get.i64(i8 addrspace(200)* %with_offset)
  %perms_check = tail call i64 @check_fold(i64 %perms)
  ; CHECK: %perms = tail call i64 @llvm.cheri.cap.perms.get.i64(i8 addrspace(200)* %with_offset)
  ; CHECK: %perms_check = tail call i64 @check_fold(i64 %perms)

  %flags = tail call i64 @llvm.cheri.cap.flags.get.i64(i8 addrspace(200)* %with_offset)
  %flags_check = tail call i64 @check_fold(i64 %flags)
  ; CHECK: %flags = tail call i64 @llvm.cheri.cap.flags.get.i64(i8 addrspace(200)* %with_offset)
  ; CHECK: %flags_check = tail call i64 @check_fold(i64 %flags)

  %tag = tail call i1 @llvm.cheri.cap.tag.get(i8 addrspace(200)* %with_offset)
  %tag.ext = zext i1 %tag to i64
  %tag_check = tail call i64 @check_fold(i64 %tag.ext)
  ; CHECK: %tag = tail call i1 @llvm.cheri.cap.tag.get(i8 addrspace(200)* %with_offset)
  ; CHECK: %tag.ext = zext i1 %tag to i64
  ; CHECK: %tag_check = tail call i64 @check_fold(i64 %tag.ext)

  ret void
  ; CHECK: ret void
}


define i64 @fold_set_offset_arg(i8 addrspace(200)* %arg) #1 {
  %with_offset = tail call i8 addrspace(200)* @llvm.cheri.cap.offset.set.i64(i8 addrspace(200)* %arg, i64 42)
  %ret = tail call i64 @llvm.cheri.cap.offset.get.i64(i8 addrspace(200)* %with_offset)
  ret i64 %ret
  ; CHECK-LABEL: @fold_set_offset_arg(i8 addrspace(200)* %arg)
  ; CHECK: ret i64 42
}

define i64 @no_fold_set_offset_get_address(i8 addrspace(200)* %arg) #1 {
  %with_offset = tail call i8 addrspace(200)* @llvm.cheri.cap.offset.set.i64(i8 addrspace(200)* %arg, i64 42)
  %ret = tail call i64 @llvm.cheri.cap.address.get.i64(i8 addrspace(200)* %with_offset)
  ret i64 %ret
  ; Since the base is not know we shouldn't fold anything here:
  ; CHECK-LABEL: @no_fold_set_offset_get_address(i8 addrspace(200)* %arg)
  ; CHECK: %with_offset = tail call i8 addrspace(200)* @llvm.cheri.cap.offset.set.i64(i8 addrspace(200)* %arg, i64 42)
  ; CHECK: %ret = tail call i64 @llvm.cheri.cap.address.get.i64(i8 addrspace(200)* %with_offset)
  ; CHECK: ret i64 %ret
}

define i64 @fold_set_address_get_address(i8 addrspace(200)* %arg) #1 {
  %with_offset = tail call i8 addrspace(200)* @llvm.cheri.cap.address.set.i64(i8 addrspace(200)* %arg, i64 42)
  %ret = tail call i64 @llvm.cheri.cap.address.get.i64(i8 addrspace(200)* %with_offset)
  ret i64 %ret
  ; The resulting address will always be 42 but we don't know if it will be tagged or not after this operation
  ; CHECK-LABEL: @fold_set_address_get_address(i8 addrspace(200)* %arg)
  ; CHECK: ret i64 42
}

define i64 @no_fold_set_offset_get_tag(i8 addrspace(200)* %arg) #1 {
  %with_offset = tail call i8 addrspace(200)* @llvm.cheri.cap.address.set.i64(i8 addrspace(200)* %arg, i64 42)
  %ret = tail call i1 @llvm.cheri.cap.tag.get(i8 addrspace(200)* %with_offset)
  %ret.ext = zext i1 %ret to i64
  ret i64 %ret.ext
  ; Since the value might be unrepresentable after setting the address we can't infer the tag:
  ; CHECK-LABEL: @no_fold_set_offset_get_tag(i8 addrspace(200)* %arg)
  ; CHECK: %with_offset = tail call i8 addrspace(200)* @llvm.cheri.cap.address.set.i64(i8 addrspace(200)* %arg, i64 42)
  ; CHECK: %ret = tail call i1 @llvm.cheri.cap.tag.get(i8 addrspace(200)* %with_offset)
  ; CHECK: %ret.ext = zext i1 %ret to i64
  ; CHECK: ret i64 %ret.ext
}

define i64 @fold_null_inc_offset() #1 {
  %inc_offset = tail call i8 addrspace(200)* @llvm.cheri.cap.offset.increment.i64(i8 addrspace(200)* null, i64 100)
  %ret = tail call i64 @llvm.cheri.cap.offset.get.i64(i8 addrspace(200)* %inc_offset)
  ret i64 %ret
  ; CHECK-LABEL: @fold_null_inc_offset()
  ; CHECK: ret i64 100
}

define i64 @fold_null_inc_offset_get_address() #1 {
  %inc_offset = tail call i8 addrspace(200)* @llvm.cheri.cap.offset.increment.i64(i8 addrspace(200)* null, i64 100)
  %ret = tail call i64 @llvm.cheri.cap.address.get.i64(i8 addrspace(200)* %inc_offset)
  ret i64 %ret
  ; CHECK-LABEL: @fold_null_inc_offset_get_address()
  ; CHECK: ret i64 100
}

define i64 @fold_null_set_address_get_offset() #1 {
  %setaddr = tail call i8 addrspace(200)* @llvm.cheri.cap.address.set.i64(i8 addrspace(200)* null, i64 100)
  %ret = tail call i64 @llvm.cheri.cap.offset.get.i64(i8 addrspace(200)* %setaddr)
  ret i64 %ret
  ; CHECK-LABEL: @fold_null_set_address_get_offset()
  ; CHECK: ret i64 100
}

define i64 @fold_null_set_address_offset_get_address() #1 {
  %setaddr = tail call i8 addrspace(200)* @llvm.cheri.cap.address.set.i64(i8 addrspace(200)* null, i64 100)
  %ret = tail call i64 @llvm.cheri.cap.address.get.i64(i8 addrspace(200)* %setaddr)
  ret i64 %ret
  ; CHECK-LABEL: @fold_null_set_address_offset_get_address()
  ; CHECK: ret i64 100
}

define i64 @fold_set_and_inc_offset_get_offset(i8 addrspace(200)* %arg) #1 {
  %with_offset = tail call i8 addrspace(200)* @llvm.cheri.cap.offset.set.i64(i8 addrspace(200)* %arg, i64 42)
  %inc_offset = tail call i8 addrspace(200)* @llvm.cheri.cap.offset.increment.i64(i8 addrspace(200)* %with_offset, i64 100)
  %ret = tail call i64 @llvm.cheri.cap.offset.get.i64(i8 addrspace(200)* %inc_offset)
  ret i64 %ret
  ; CHECK-LABEL: @fold_set_and_inc_offset_get_offset(i8 addrspace(200)* %arg)
  ; CHECK: ret i64 142
}

define i64 @no_fold_set_and_inc_offset_get_addr(i8 addrspace(200)* %arg) #1 {
  ; a getaddr can no be inferred from a setoffset since we don't know the base:
  ; However the offset increment can be folded into a single setoffset
  %with_offset = tail call i8 addrspace(200)* @llvm.cheri.cap.offset.set.i64(i8 addrspace(200)* %arg, i64 42)
  %inc_offset = tail call i8 addrspace(200)* @llvm.cheri.cap.offset.increment.i64(i8 addrspace(200)* %with_offset, i64 100)
  %ret = tail call i64 @llvm.cheri.cap.address.get.i64(i8 addrspace(200)* %inc_offset)
  ret i64 %ret
  ; The %with_offset will be removed by dead code elimination later in the pipeline
  ; CHECK-LABEL: @no_fold_set_and_inc_offset_get_addr(i8 addrspace(200)* %arg)
  ; CHECK: %with_offset = tail call i8 addrspace(200)* @llvm.cheri.cap.offset.set.i64(i8 addrspace(200)* %arg, i64 142)
  ; CHECK: %ret = tail call i64 @llvm.cheri.cap.address.get.i64(i8 addrspace(200)* %with_offset)
  ; CHECK: ret i64 %ret
}

define i64 @fold_set_and_multiple_inc_offset_get_offset(i8 addrspace(200)* %arg) #1 {
  %with_offset = tail call i8 addrspace(200)* @llvm.cheri.cap.offset.set.i64(i8 addrspace(200)* %arg, i64 42)
  %inc_offset = tail call i8 addrspace(200)* @llvm.cheri.cap.offset.increment.i64(i8 addrspace(200)* %with_offset, i64 100)
  %inc_offset2 = tail call i8 addrspace(200)* @llvm.cheri.cap.offset.increment.i64(i8 addrspace(200)* %inc_offset, i64 100)
  %ret = tail call i64 @llvm.cheri.cap.offset.get.i64(i8 addrspace(200)* %inc_offset2)
  ret i64 %ret
  ; CHECK-LABEL: @fold_set_and_multiple_inc_offset_get_offset(i8 addrspace(200)* %arg)
  ; CHECK: ret i64 242
}

define i64 @fold_set_addr_and_inc_offset_get_offset(i8 addrspace(200)* %arg) #1 {
  ; a getoffset can no be inferred from a setaddr since we don't know the base:
  ; But we acn fold the inc-offset into the setaddr:
  %with_offset = tail call i8 addrspace(200)* @llvm.cheri.cap.address.set.i64(i8 addrspace(200)* %arg, i64 42)
  %inc_offset = tail call i8 addrspace(200)* @llvm.cheri.cap.offset.increment.i64(i8 addrspace(200)* %with_offset, i64 100)
  %ret = tail call i64 @llvm.cheri.cap.offset.get.i64(i8 addrspace(200)* %inc_offset)
  ret i64 %ret
  ; CHECK-LABEL: @fold_set_addr_and_inc_offset_get_offset(i8 addrspace(200)* %arg)
  ; CHECK: %with_offset = tail call i8 addrspace(200)* @llvm.cheri.cap.address.set.i64(i8 addrspace(200)* %arg, i64 142)
  ; CHECK: %ret = tail call i64 @llvm.cheri.cap.offset.get.i64(i8 addrspace(200)* %with_offset)
  ; CHECK: ret i64 %ret
}

define i64 @fold_set_addr_and_inc_offset_get_addr(i8 addrspace(200)* %arg) #1 {
  ; a getoffset can no be inferred from a setaddr since we don't know the base:
  %with_offset = tail call i8 addrspace(200)* @llvm.cheri.cap.address.set.i64(i8 addrspace(200)* %arg, i64 42)
  %inc_offset = tail call i8 addrspace(200)* @llvm.cheri.cap.offset.increment.i64(i8 addrspace(200)* %with_offset, i64 100)
  %ret = tail call i64 @llvm.cheri.cap.address.get.i64(i8 addrspace(200)* %inc_offset)
  ret i64 %ret
  ; CHECK-LABEL: @fold_set_addr_and_inc_offset_get_addr(i8 addrspace(200)* %arg)
  ; CHECK: ret i64 142
}

define i64 @fold_set_addr_and_multiple_inc_offset_get_addr(i8 addrspace(200)* %arg) #1 {
  %with_offset = tail call i8 addrspace(200)* @llvm.cheri.cap.address.set.i64(i8 addrspace(200)* %arg, i64 42)
  %inc_offset = tail call i8 addrspace(200)* @llvm.cheri.cap.offset.increment.i64(i8 addrspace(200)* %with_offset, i64 100)
  %inc_offset2 = tail call i8 addrspace(200)* @llvm.cheri.cap.offset.increment.i64(i8 addrspace(200)* %inc_offset, i64 100)
  %ret = tail call i64 @llvm.cheri.cap.address.get.i64(i8 addrspace(200)* %inc_offset2)
  ret i64 %ret
  ; CHECK-LABEL: @fold_set_addr_and_multiple_inc_offset_get_addr(i8 addrspace(200)* %arg)
  ; CHECK: ret i64 242
}

define i64 @fold_base_get_inttoptr() #1 {
  %ret = tail call i64 @llvm.cheri.cap.base.get.i64(i8 addrspace(200)* inttoptr (i64 100 to i8 addrspace(200)*))
  ret i64 %ret
  ; CHECK-LABEL: @fold_base_get_inttoptr()
  ; CHECK: ret i64 0
}

define i64 @fold_length_get_inttoptr() #1 {
  %ret = tail call i64 @llvm.cheri.cap.length.get.i64(i8 addrspace(200)* inttoptr (i64 100 to i8 addrspace(200)*))
  ret i64 %ret
  ; CHECK-LABEL: @fold_length_get_inttoptr()
  ; CHECK: ret i64 -1
}

define i64 @fold_tag_get_inttoptr() #1 {
  %ret = tail call i1 @llvm.cheri.cap.tag.get(i8 addrspace(200)* inttoptr (i64 100 to i8 addrspace(200)*))
  %ret.ext = zext i1 %ret to i64
  ret i64 %ret.ext
  ; CHECK-LABEL: @fold_tag_get_inttoptr()
  ; CHECK: %ret.ext = zext i1 false to i64
  ; CHECK: ret i64 %ret.ext
}

define i64 @fold_type_get_inttoptr() #1 {
  %ret = tail call i64 @llvm.cheri.cap.type.get.i64(i8 addrspace(200)* inttoptr (i64 100 to i8 addrspace(200)*))
  ret i64 %ret
  ; CHECK-LABEL: @fold_type_get_inttoptr()
  ; CHECK: ret i64 -1
}

define i64 @fold_offset_get_inttoptr() #1 {
  %ret = tail call i64 @llvm.cheri.cap.offset.get.i64(i8 addrspace(200)* inttoptr (i64 100 to i8 addrspace(200)*))
  ret i64 %ret
  ; CHECK-LABEL: @fold_offset_get_inttoptr()
  ; CHECK: ret i64 100
}

define i64 @fold_address_get_inttoptr() #1 {
  %ret = tail call i64 @llvm.cheri.cap.address.get.i64(i8 addrspace(200)* inttoptr (i64 100 to i8 addrspace(200)*))
  ret i64 %ret
  ; CHECK-LABEL: @fold_address_get_inttoptr()
  ; CHECK: ret i64 100
}

define i8 addrspace(200)* @fold_set_offset_inc_offset(i8 addrspace(200)* %arg) #1 {
  %with_offset = tail call i8 addrspace(200)* @llvm.cheri.cap.offset.set.i64(i8 addrspace(200)* %arg, i64 42)
  %inc_offset = tail call i8 addrspace(200)* @llvm.cheri.cap.offset.increment.i64(i8 addrspace(200)* %with_offset, i64 100)
  %inc_offset2 = tail call i8 addrspace(200)* @llvm.cheri.cap.offset.increment.i64(i8 addrspace(200)* %inc_offset, i64 100)
  ret i8 addrspace(200)* %inc_offset2
  ; CHECK-LABEL: @fold_set_offset_inc_offset(i8 addrspace(200)* %arg)
  ; CHECK: call i8 addrspace(200)* @llvm.cheri.cap.offset.set.i64(i8 addrspace(200)* %arg, i64 242)
}

define i8 addrspace(200)* @fold_set_inc_gep_sequence() local_unnamed_addr #1 {
entry:
  %set = tail call i8 addrspace(200)* @llvm.cheri.cap.offset.set.i64(i8 addrspace(200)* null, i64 100)
  %gep1 = getelementptr inbounds i8, i8 addrspace(200)* %set, i64 -4
  %gep2 = getelementptr inbounds i8, i8 addrspace(200)* %gep1, i64 -4
  %gep3 = getelementptr inbounds i8, i8 addrspace(200)* %gep2, i64 -2
  %inc = tail call i8 addrspace(200)* @llvm.cheri.cap.offset.increment.i64(i8 addrspace(200)* %gep3, i64 -10)

  ret i8 addrspace(200)* %inc
  ; CHECK-LABEL: @fold_set_inc_gep_sequence()
  ; CHECK: %set = tail call i8 addrspace(200)* @llvm.cheri.cap.offset.set.i64(i8 addrspace(200)* null, i64 80)
  ; CHECK: ret i8 addrspace(200)* %set
}

define i8 addrspace(200)* @fold_set_addr_inc_gep_sequence() local_unnamed_addr #1 {
entry:
  %set = tail call i8 addrspace(200)* @llvm.cheri.cap.address.set.i64(i8 addrspace(200)* null, i64 100)
  %gep1 = getelementptr inbounds i8, i8 addrspace(200)* %set, i64 -4
  %gep2 = getelementptr inbounds i8, i8 addrspace(200)* %gep1, i64 -4
  %gep3 = getelementptr inbounds i8, i8 addrspace(200)* %gep2, i64 -2
  %inc = tail call i8 addrspace(200)* @llvm.cheri.cap.offset.increment.i64(i8 addrspace(200)* %gep3, i64 -10)

  ret i8 addrspace(200)* %inc
  ; CHECK-LABEL: @fold_set_addr_inc_gep_sequence()
  ; The %set/getp/inc will be removed later
  ; CHECK:  %set = tail call i8 addrspace(200)* @llvm.cheri.cap.address.set.i64(i8 addrspace(200)* null, i64 80)
  ; CHECK:  ret i8 addrspace(200)* %set
}

define i8 addrspace(200)* @fold_set_inc_gep_sequence_arg(i8 addrspace(200)* %arg) local_unnamed_addr #1 {
entry:
  %set = tail call i8 addrspace(200)* @llvm.cheri.cap.offset.set.i64(i8 addrspace(200)* %arg, i64 100)
  %gep1 = getelementptr inbounds i8, i8 addrspace(200)* %set, i64 -4
  %gep2 = getelementptr inbounds i8, i8 addrspace(200)* %gep1, i64 -4
  %gep3 = getelementptr inbounds i8, i8 addrspace(200)* %gep2, i64 -2
  %inc = tail call i8 addrspace(200)* @llvm.cheri.cap.offset.increment.i64(i8 addrspace(200)* %gep3, i64 -10)
  ret i8 addrspace(200)* %inc
  ; CHECK-LABEL: @fold_set_inc_gep_sequence_arg(i8 addrspace(200)* %arg)
  ; CHECK: tail call i8 addrspace(200)* @llvm.cheri.cap.offset.set.i64(i8 addrspace(200)* %arg, i64 80)
}

define i8 addrspace(200)* @fold_set_addr_inc_gep_sequence_arg(i8 addrspace(200)* %arg) local_unnamed_addr #1 {
entry:
  %set = tail call i8 addrspace(200)* @llvm.cheri.cap.address.set.i64(i8 addrspace(200)* %arg, i64 100)
  %gep1 = getelementptr inbounds i8, i8 addrspace(200)* %set, i64 -4
  %gep2 = getelementptr inbounds i8, i8 addrspace(200)* %gep1, i64 -4
  %gep3 = getelementptr inbounds i8, i8 addrspace(200)* %gep2, i64 -2
  %inc = tail call i8 addrspace(200)* @llvm.cheri.cap.offset.increment.i64(i8 addrspace(200)* %gep3, i64 -10)
  ret i8 addrspace(200)* %inc
  ; CHECK-LABEL: @fold_set_addr_inc_gep_sequence_arg(i8 addrspace(200)* %arg)
  ; CHECK: %set = tail call i8 addrspace(200)* @llvm.cheri.cap.address.set.i64(i8 addrspace(200)* %arg, i64 80)
  ; CHECK: ret i8 addrspace(200)* %set
}

define i8 addrspace(200)* @fold_inc_gep_sequence_null() local_unnamed_addr #1 {
  %src = tail call i8 addrspace(200)* @llvm.cheri.cap.offset.increment.i64(i8 addrspace(200)* null, i64 100)
  %gep1 = getelementptr inbounds i8, i8 addrspace(200)* %src, i64 -4
  %gep2 = getelementptr inbounds i8, i8 addrspace(200)* %gep1, i64 -4
  %inc = tail call i8 addrspace(200)* @llvm.cheri.cap.offset.increment.i64(i8 addrspace(200)* %gep2, i64 -10)
  ret i8 addrspace(200)* %inc
  ; CHECK-LABEL: @fold_inc_gep_sequence_null()
  ; CHECK: tail call i8 addrspace(200)* @llvm.cheri.cap.offset.increment.i64(i8 addrspace(200)* null, i64 82)
}

define i8 addrspace(200)* @fold_inc_gep_sequence_arg(i8 addrspace(200)* %arg) local_unnamed_addr #1 {
entry:
  %0 = tail call i8 addrspace(200)* @llvm.cheri.cap.offset.increment.i64(i8 addrspace(200)* %arg, i64 100)
  %gep1 = getelementptr inbounds i8, i8 addrspace(200)* %0, i64 -4
  %gep2 = getelementptr inbounds i8, i8 addrspace(200)* %gep1, i64 -4
  %inc = tail call i8 addrspace(200)* @llvm.cheri.cap.offset.increment.i64(i8 addrspace(200)* %gep2, i64 -10)
  ret i8 addrspace(200)* %inc
  ; CHECK-LABEL: @fold_inc_gep_sequence_arg(i8 addrspace(200)* %arg)
  ; CHECK: tail call i8 addrspace(200)* @llvm.cheri.cap.offset.increment.i64(i8 addrspace(200)* %arg, i64 82)
}

define i8 addrspace(200)* @fold_gep_incoffset(i8 addrspace(200)* %arg) local_unnamed_addr #1 {
entry:
  ; CHECK-LABEL: @fold_gep_incoffset(i8 addrspace(200)* %arg)
  ; CHECK: tail call i8 addrspace(200)* @llvm.cheri.cap.offset.increment.i64(i8 addrspace(200)* %arg, i64 96)
  %inc = tail call i8 addrspace(200)* @llvm.cheri.cap.offset.increment.i64(i8 addrspace(200)* %arg, i64 100)
  %gep = getelementptr inbounds i8, i8 addrspace(200)* %inc, i64 -4
  ret i8 addrspace(200)* %gep
}

; TODO: Order of GEP vs incoffset should not matter:
define i8 addrspace(200)* @fold_gep_incoffset2(i8 addrspace(200)* %arg) local_unnamed_addr #1 {
entry:
  ; CHECK-LABEL: @fold_gep_incoffset2(i8 addrspace(200)* %arg)
  ; CHECK-NOT: tail call i8 addrspace(200)* @llvm.cheri.cap.offset.increment.i64(i8 addrspace(200)* %arg, i64 96)
  %gep = getelementptr inbounds i8, i8 addrspace(200)* %arg, i64 -4
  %inc = tail call i8 addrspace(200)* @llvm.cheri.cap.offset.increment.i64(i8 addrspace(200)* %gep, i64 100)
  ret i8 addrspace(200)* %inc
}

; TODO: this can't be folded into adds since it breaks the IR
; I'm also not sure it makes sense anyway since CIncOffset and add are the same
define i8 addrspace(200)* @fold_set_dynamic_gep_arg(i8 addrspace(200)* %arg, i64 %increment) local_unnamed_addr #1 {
entry:
  %0 = tail call i8 addrspace(200)* @llvm.cheri.cap.offset.set.i64(i8 addrspace(200)* %arg, i64 100)
  %gep1 = getelementptr inbounds i8, i8 addrspace(200)* %0, i64 %increment
  %inc = tail call i8 addrspace(200)* @llvm.cheri.cap.offset.increment.i64(i8 addrspace(200)* %gep1, i64 -10)
  ret i8 addrspace(200)* %inc
  ; CHECK-LABEL: @fold_set_dynamic_gep_arg(i8 addrspace(200)* %arg, i64 %increment)
  ; NOCHECK:      %0 = tail call i8 addrspace(200)* @llvm.cheri.cap.offset.set.i64(i8 addrspace(200)* %arg, i64 100)
  ; NOCHECK-NEXT: %gep1 = getelementptr inbounds i8, i8 addrspace(200)* %0, i64 %increment
  ; NOCHECK-NEXT: %inc = tail call i8 addrspace(200)* @llvm.cheri.cap.offset.increment.i64(i8 addrspace(200)* %gep1, i64 -10)
  ; NOCHECK-NEXT: ret i8 addrspace(200)* %inc
  ; CHECK: [[ADD:%.+]] = add i64 100, %increment
  ; CHECK: [[NEW_OFFSET:%.+]] = add i64 [[ADD]], -10
  ; CHECK: [[RESULT:%.+]] = tail call i8 addrspace(200)* @llvm.cheri.cap.offset.set.i64(i8 addrspace(200)* %arg, i64 [[NEW_OFFSET]])
  ; CHECK: ret i8 addrspace(200)* [[RESULT]]
  ; DYNAMIC-GEP-ASM-LABEL: fold_set_dynamic_gep_arg
  ; DYNAMIC-GEP-ASM:       daddiu  $1, $4, 90
  ; DYNAMIC-GEP-ASM-NEXT:  jr      $ra
  ; DYNAMIC-GEP-ASM-NEXT:  csetoffset      $c3, $c3, $1
}

define i8 addrspace(200)* @fold_null_setaddr_zero() #1 {
  %arg = tail call i8 addrspace(200)* @llvm.cheri.cap.address.set.i64(i8 addrspace(200)* null, i64 0)
  %ret = call i8 addrspace(200)* @check_fold_i8ptr(i8 addrspace(200)* %arg)
  ret i8 addrspace(200)* %ret
  ; CHECK-LABEL: @fold_null_setaddr_zero()
  ; CHECK: %ret = call i8 addrspace(200)* @check_fold_i8ptr(i8 addrspace(200)* null)
  ; CHECK: ret i8 addrspace(200)* %ret
}

define i8 addrspace(200)* @fold_null_setoffest_zero() #1 {
  %arg = tail call i8 addrspace(200)* @llvm.cheri.cap.offset.set.i64(i8 addrspace(200)* null, i64 0)
  %ret = call i8 addrspace(200)* @check_fold_i8ptr(i8 addrspace(200)* %arg)
  ret i8 addrspace(200)* %ret
  ; CHECK-LABEL: @fold_null_setoffest_zero()
  ; CHECK: %ret = call i8 addrspace(200)* @check_fold_i8ptr(i8 addrspace(200)* null)
  ; CHECK: ret i8 addrspace(200)* %ret
}

define i8 addrspace(200)* @fold_null_incoffest_zero() #1 {
  %arg = tail call i8 addrspace(200)* @llvm.cheri.cap.offset.increment.i64(i8 addrspace(200)* null, i64 0)
  %ret = call i8 addrspace(200)* @check_fold_i8ptr(i8 addrspace(200)* %arg)
  ret i8 addrspace(200)* %ret
  ; CHECK-LABEL: @fold_null_incoffest_zero()
  ; CHECK: %ret = call i8 addrspace(200)* @check_fold_i8ptr(i8 addrspace(200)* null)
  ; CHECK: ret i8 addrspace(200)* %ret
}

define i8 addrspace(200)* @fold_incoffest_zero(i8 addrspace(200)* %arg) #1 {
  %inc0 = tail call i8 addrspace(200)* @llvm.cheri.cap.offset.increment.i64(i8 addrspace(200)* %arg, i64 0)
  %ret = call i8 addrspace(200)* @check_fold_i8ptr(i8 addrspace(200)* %inc0)
  ret i8 addrspace(200)* %ret
  ; CHECK-LABEL: @fold_incoffest_zero(i8 addrspace(200)* %arg)
  ; CHECK: %ret = call i8 addrspace(200)* @check_fold_i8ptr(i8 addrspace(200)* %arg)
  ; CHECK: ret i8 addrspace(200)* %ret
}

; This used to produce a nonnull attribute on a null parameter
define i8 addrspace(200)* @inline_align_down() local_unnamed_addr #1 {
entry:
  %0 = tail call i8 addrspace(200)* @llvm.cheri.cap.address.set.i64(i8 addrspace(200)* null, i64 100)
  %1 = tail call i64 @llvm.cheri.cap.address.get.i64(i8 addrspace(200)* nonnull %0) #3
  %2 = and i64 %1, -32
  %3 = tail call i8 addrspace(200)* @llvm.cheri.cap.address.set.i64(i8 addrspace(200)* nonnull %0, i64 %2) #3
  ret i8 addrspace(200)* %3
  ; CHECK-LABEL: @inline_align_down()
  ; CHECK: %0 = and i64 100, -32
  ; CHECK: %1 = tail call i8 addrspace(200)* @llvm.cheri.cap.address.set.i64(i8 addrspace(200)* null, i64 %0)
  ; CHECK: ret i8 addrspace(200)* %1
}

attributes #0 = { nounwind }
attributes #1 = { nounwind readnone }
