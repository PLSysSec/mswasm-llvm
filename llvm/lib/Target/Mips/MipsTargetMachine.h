//===-- MipsTargetMachine.h - Define TargetMachine for Mips -----*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file declares the Mips specific subclass of TargetMachine.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_MIPS_MIPSTARGETMACHINE_H
#define LLVM_LIB_TARGET_MIPS_MIPSTARGETMACHINE_H

#include "MCTargetDesc/MipsABIInfo.h"
#include "MipsSubtarget.h"
#include "llvm/CodeGen/BasicTTIImpl.h"
#include "llvm/CodeGen/Passes.h"
#include "llvm/CodeGen/SelectionDAGISel.h"
#include "llvm/Target/TargetFrameLowering.h"
#include "llvm/Target/TargetMachine.h"

namespace llvm {
class formatted_raw_ostream;
class MipsRegisterInfo;

class MipsTargetMachine : public LLVMTargetMachine {
  bool isLittle;
  std::unique_ptr<TargetLoweringObjectFile> TLOF;
  // Selected ABI
  MipsABIInfo ABI;
  MipsSubtarget *Subtarget;
  MipsSubtarget DefaultSubtarget;
  MipsSubtarget NoMips16Subtarget;
  MipsSubtarget Mips16Subtarget;

  mutable StringMap<std::unique_ptr<MipsSubtarget>> SubtargetMap;

public:
  MipsTargetMachine(const Target &T, const Triple &TT, StringRef CPU,
                    StringRef FS, const TargetOptions &Options, Reloc::Model RM,
                    CodeModel::Model CM, CodeGenOpt::Level OL, bool isLittle);
  ~MipsTargetMachine() override;

  TargetIRAnalysis getTargetIRAnalysis() override;

  const MipsSubtarget *getSubtargetImpl() const {
    if (Subtarget)
      return Subtarget;
    return &DefaultSubtarget;
  }

  const MipsSubtarget *getSubtargetImpl(const Function &F) const override;

  /// \brief Reset the subtarget for the Mips target.
  void resetSubtarget(MachineFunction *MF);

  // Pass Pipeline Configuration
  TargetPassConfig *createPassConfig(PassManagerBase &PM) override;

  TargetLoweringObjectFile *getObjFileLowering() const override {
    return TLOF.get();
  }

  bool isLittleEndian() const { return isLittle; }
  const MipsABIInfo &getABI() const { return ABI; }
};

/// MipsebTargetMachine - Mips32/64 big endian target machine.
///
class MipsebTargetMachine : public MipsTargetMachine {
  virtual void anchor();
public:
  MipsebTargetMachine(const Target &T, const Triple &TT, StringRef CPU,
                      StringRef FS, const TargetOptions &Options,
                      Reloc::Model RM, CodeModel::Model CM,
                      CodeGenOpt::Level OL);
};

/// MipselTargetMachine - Mips32/64 little endian target machine.
///
class MipselTargetMachine : public MipsTargetMachine {
  virtual void anchor();
public:
  MipselTargetMachine(const Target &T, const Triple &TT, StringRef CPU,
                      StringRef FS, const TargetOptions &Options,
                      Reloc::Model RM, CodeModel::Model CM,
                      CodeGenOpt::Level OL);
};

/// MipsCheriTargetMachine - MIPS with CHERI capability extensions.
class MipsCheriTargetMachine : public MipsebTargetMachine {
  virtual void anchor();
public:
  MipsCheriTargetMachine(const Target &T, const Triple &TT,
                        StringRef CPU, StringRef FS,
                        const TargetOptions &Options,
                        Reloc::Model RM, CodeModel::Model CM,
                        CodeGenOpt::Level OL);
  bool isCompatibleDataLayout(const DataLayout &Candidate) const override {
    if (TargetMachine::isCompatibleDataLayout(Candidate))
      return true;
    DataLayout MutableCandidate(Candidate);
    MutableCandidate.setAllocaAS(getDataLayout().getAllocaAS());
    return TargetMachine::isCompatibleDataLayout(MutableCandidate);
  }
};

} // End llvm namespace

#endif
