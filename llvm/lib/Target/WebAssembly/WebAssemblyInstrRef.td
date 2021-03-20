// WebAssemblyInstrRef.td - WebAssembly reference type codegen --*- tablegen -*-
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
///
/// \file
/// WebAssembly reference type operand codegen constructs.
///
//===----------------------------------------------------------------------===//

defm SELECT_EXNREF : I<(outs EXNREF:$dst),
                       (ins EXNREF:$lhs, EXNREF:$rhs, I32:$cond),
                       (outs), (ins),
                       [(set EXNREF:$dst,
                         (select I32:$cond, EXNREF:$lhs, EXNREF:$rhs))],
                       "exnref.select\t$dst, $lhs, $rhs, $cond",
                       "exnref.select", 0x1b>;

def : Pat<(select (i32 (setne I32:$cond, 0)), EXNREF:$lhs, EXNREF:$rhs),
          (SELECT_EXNREF EXNREF:$lhs, EXNREF:$rhs, I32:$cond)>;
def : Pat<(select (i32 (seteq I32:$cond, 0)), EXNREF:$lhs, EXNREF:$rhs),
          (SELECT_EXNREF EXNREF:$rhs, EXNREF:$lhs, I32:$cond)>;

defm SELECT_HANDLE : I<(outs HANDLE:$dst),
                       (ins HANDLE:$lhs, HANDLE:$rhs, I32:$cond),
                       (outs), (ins),
                       [(set HANDLE:$dst,
                         (select I32:$cond, HANDLE:$lhs, HANDLE:$rhs))],
                       "handle.select\t$dst, $lhs, $rhs, $cond",
                       "handle.select", 0xfb>; // TODO choose an actual opcode for this

def : Pat<(select (i32 (setne I32:$cond, 0)), HANDLE:$lhs, HANDLE:$rhs),
          (SELECT_HANDLE HANDLE:$lhs, HANDLE:$rhs, I32:$cond)>;
def : Pat<(select (i32 (seteq I32:$cond, 0)), HANDLE:$lhs, HANDLE:$rhs),
          (SELECT_HANDLE HANDLE:$rhs, HANDLE:$lhs, I32:$cond)>;
