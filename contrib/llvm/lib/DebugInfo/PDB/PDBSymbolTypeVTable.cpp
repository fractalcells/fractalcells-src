//===- PDBSymbolTypeVTable.cpp - --------------------------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "llvm/DebugInfo/PDB/PDBSymbolTypeVTable.h"

#include "llvm/DebugInfo/PDB/PDBSymDumper.h"

#include <utility>

using namespace llvm;
using namespace llvm::pdb;

void PDBSymbolTypeVTable::dump(PDBSymDumper &Dumper) const {
  Dumper.dump(*this);
}
