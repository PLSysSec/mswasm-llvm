// RUN: %cheri_purecap_cc1 -emit-obj -target-cpu mips4 -Os -std=c++1z -fdeprecated-macro -fvisibility hidden -fvisibility-inlines-hidden -pthread -fcolor-diagnostics -vectorize-loops -vectorize-slp -o - %s

// These two reduced tests were previously crashing with the following
// assertion failure in LLVM's SROA transform when compiling qtbase:
//
// Assertion `Offset.getBitWidth() == DL.getPointerBaseSizeInBits(getPointerAddressSpace()) && "The offset must have exactly as many bits as our pointer."' failed.
//
// The two QtBase files from which the reduced test cases were produced are named before each test

// from qquaternion.cpp

class a {
  public:
    a(float);
    float b, c, e, d;
};
a operator*(a &h, float) { return h.d; }
inline a operator-(a) {}
float f;
void g(a h) {
  a i(h);
  -i = i * f;
}

// from qvector4d.cpp

bool d(double);
class e {
  constexpr e(float, float, float, float);
  e f() const;
  float g, h, i, j;
};
constexpr e::e(float, float, float, float) : g(), h(), i(), j() {}
e e::f() const {
  if (d(1.0f))
    return *this;
  return e(float(), float(), float(), float());
}
