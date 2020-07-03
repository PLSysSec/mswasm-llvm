// NOTE: Assertions have been autogenerated by utils/update_cc_test_checks.py
// RUN: %cheri_cc1 %s -std=c++14 -emit-llvm -O0 -o - | %cheri_FileCheck -check-prefix=HYBRID %s
// RUN: %cheri_purecap_cc1 %s -std=c++14 -emit-llvm -O0 -o - | %cheri_FileCheck -check-prefix=PURECAP %s

// Reduced test case from a crash compiling qdebug.cpp (caused by passing pointers-to-members as arguments)

class QTextStream {};
class QDebug {
  void putUcs4();
private:
  QTextStream ts;
};
typedef void (QTextStream::*g)();
class QTextStreamManipulator {
  g i;
};
QTextStream& operator<<(QTextStream&, QTextStreamManipulator);
QTextStreamManipulator qSetPadChar();

// HYBRID-LABEL: define {{[^@]+}}@_ZN6QDebug7putUcs4Ev
// HYBRID-SAME: (%class.QDebug* [[THIS:%.*]]) #0 align 2
// HYBRID-NEXT:  entry:
// HYBRID-NEXT:    [[THIS_ADDR:%.*]] = alloca %class.QDebug*, align 8
// HYBRID-NEXT:    [[AGG_TMP:%.*]] = alloca [[CLASS_QTEXTSTREAMMANIPULATOR:%.*]], align 8
// HYBRID-NEXT:    store %class.QDebug* [[THIS]], %class.QDebug** [[THIS_ADDR]], align 8
// HYBRID-NEXT:    [[THIS1:%.*]] = load %class.QDebug*, %class.QDebug** [[THIS_ADDR]], align 8
// HYBRID-NEXT:    [[TS:%.*]] = getelementptr inbounds [[CLASS_QDEBUG:%.*]], %class.QDebug* [[THIS1]], i32 0, i32 0
// HYBRID-NEXT:    [[CALL:%.*]] = call inreg { i64, i64 } @_Z11qSetPadCharv()
// HYBRID-NEXT:    [[COERCE_DIVE:%.*]] = getelementptr inbounds [[CLASS_QTEXTSTREAMMANIPULATOR]], %class.QTextStreamManipulator* [[AGG_TMP]], i32 0, i32 0
// HYBRID-NEXT:    [[TMP0:%.*]] = getelementptr inbounds { i64, i64 }, { i64, i64 }* [[COERCE_DIVE]], i32 0, i32 0
// HYBRID-NEXT:    [[TMP1:%.*]] = extractvalue { i64, i64 } [[CALL]], 0
// HYBRID-NEXT:    store i64 [[TMP1]], i64* [[TMP0]], align 8
// HYBRID-NEXT:    [[TMP2:%.*]] = getelementptr inbounds { i64, i64 }, { i64, i64 }* [[COERCE_DIVE]], i32 0, i32 1
// HYBRID-NEXT:    [[TMP3:%.*]] = extractvalue { i64, i64 } [[CALL]], 1
// HYBRID-NEXT:    store i64 [[TMP3]], i64* [[TMP2]], align 8
// HYBRID-NEXT:    [[TMP4:%.*]] = bitcast %class.QTextStreamManipulator* [[AGG_TMP]] to { i64, i64 }*
// HYBRID-NEXT:    [[TMP5:%.*]] = getelementptr inbounds { i64, i64 }, { i64, i64 }* [[TMP4]], i32 0, i32 0
// HYBRID-NEXT:    [[TMP6:%.*]] = load i64, i64* [[TMP5]], align 8
// HYBRID-NEXT:    [[TMP7:%.*]] = getelementptr inbounds { i64, i64 }, { i64, i64 }* [[TMP4]], i32 0, i32 1
// HYBRID-NEXT:    [[TMP8:%.*]] = load i64, i64* [[TMP7]], align 8
// HYBRID-NEXT:    [[CALL2:%.*]] = call nonnull align 1 dereferenceable(1) %class.QTextStream* @_ZlsR11QTextStream22QTextStreamManipulator(%class.QTextStream* nonnull align 1 dereferenceable(1) [[TS]], i64 inreg [[TMP6]], i64 inreg [[TMP8]])
// HYBRID-NEXT:    ret void
//
// PURECAP-LABEL: define {{[^@]+}}@_ZN6QDebug7putUcs4Ev
// PURECAP-SAME: (%class.QDebug addrspace(200)* [[THIS:%.*]]) addrspace(200) #0 align 2
// PURECAP-NEXT:  entry:
// PURECAP-NEXT:    [[THIS_ADDR:%.*]] = alloca [[CLASS_QDEBUG:%.*]] addrspace(200)*, align 16, addrspace(200)
// PURECAP-NEXT:    [[AGG_TMP:%.*]] = alloca [[CLASS_QTEXTSTREAMMANIPULATOR:%.*]], align 16, addrspace(200)
// PURECAP-NEXT:    store [[CLASS_QDEBUG]] addrspace(200)* [[THIS]], [[CLASS_QDEBUG]] addrspace(200)* addrspace(200)* [[THIS_ADDR]], align 16
// PURECAP-NEXT:    [[THIS1:%.*]] = load [[CLASS_QDEBUG]] addrspace(200)*, [[CLASS_QDEBUG]] addrspace(200)* addrspace(200)* [[THIS_ADDR]], align 16
// PURECAP-NEXT:    [[TS:%.*]] = getelementptr inbounds [[CLASS_QDEBUG]], [[CLASS_QDEBUG]] addrspace(200)* [[THIS1]], i32 0, i32 0
// PURECAP-NEXT:    [[CALL:%.*]] = call inreg { { i8 addrspace(200)*, i64 } } @_Z11qSetPadCharv()
// PURECAP-NEXT:    [[COERCE_DIVE:%.*]] = getelementptr inbounds [[CLASS_QTEXTSTREAMMANIPULATOR]], [[CLASS_QTEXTSTREAMMANIPULATOR]] addrspace(200)* [[AGG_TMP]], i32 0, i32 0
// PURECAP-NEXT:    [[TMP0:%.*]] = bitcast { i8 addrspace(200)*, i64 } addrspace(200)* [[COERCE_DIVE]] to { { i8 addrspace(200)*, i64 } } addrspace(200)*
// PURECAP-NEXT:    [[TMP1:%.*]] = getelementptr inbounds { { i8 addrspace(200)*, i64 } }, { { i8 addrspace(200)*, i64 } } addrspace(200)* [[TMP0]], i32 0, i32 0
// PURECAP-NEXT:    [[TMP2:%.*]] = extractvalue { { i8 addrspace(200)*, i64 } } [[CALL]], 0
// PURECAP-NEXT:    store { i8 addrspace(200)*, i64 } [[TMP2]], { i8 addrspace(200)*, i64 } addrspace(200)* [[TMP1]], align 16
// PURECAP-NEXT:    [[TMP3:%.*]] = bitcast [[CLASS_QTEXTSTREAMMANIPULATOR]] addrspace(200)* [[AGG_TMP]] to { { i8 addrspace(200)*, i64 } } addrspace(200)*
// PURECAP-NEXT:    [[TMP4:%.*]] = getelementptr inbounds { { i8 addrspace(200)*, i64 } }, { { i8 addrspace(200)*, i64 } } addrspace(200)* [[TMP3]], i32 0, i32 0
// PURECAP-NEXT:    [[TMP5:%.*]] = load { i8 addrspace(200)*, i64 }, { i8 addrspace(200)*, i64 } addrspace(200)* [[TMP4]], align 16
// PURECAP-NEXT:    [[CALL2:%.*]] = call nonnull align 1 dereferenceable(1) [[CLASS_QTEXTSTREAM:%.*]] addrspace(200)* @_ZlsR11QTextStream22QTextStreamManipulator(%class.QTextStream addrspace(200)* nonnull align 1 dereferenceable(1) [[TS]], { i8 addrspace(200)*, i64 } inreg [[TMP5]])
// PURECAP-NEXT:    ret void
//
void QDebug::putUcs4() {
  // Note: pointers-to-members are also returned inreg for purecap now
  ts << qSetPadChar();
}

