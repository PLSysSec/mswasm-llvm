
// WebAssemblyInstrInteger.td-WebAssembly Integer codegen -------*- tablegen -*-
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
///
/// \file
/// WebAssembly CHERI instruction patterns.
///
//===----------------------------------------------------------------------===//

def : Pat<(int_cheri_cap_address_set iFATPTR64:$src, I32:$off), (HANDLE_ADD iFATPTR64:$src, I32:$off)>;
def : Pat<(int_cheri_cap_address_get iFATPTR64:$src), (HANDLE_GET_OFFSET iFATPTR64:$src)>;

// We don't have a use for these currently, so these are just hacky placeholders to let us compile
def : Pat<(int_cheri_cap_bounds_set iFATPTR64:$src, I32:$off), (HANDLE_ADD iFATPTR64:$src, 0)>;
def : Pat<(int_cheri_round_representable_length I32:$op), (CONST_I32 I32:$op)>;
def : Pat<(int_cheri_representable_alignment_mask I32:$op), (CONST_I32 I32:$op)>;
