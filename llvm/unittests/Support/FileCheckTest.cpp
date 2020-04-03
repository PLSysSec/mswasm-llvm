//===- llvm/unittest/Support/FileCheckTest.cpp - FileCheck tests --===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "llvm/Support/FileCheck.h"
#include "../lib/Support/FileCheckImpl.h"
#include "llvm/Support/Regex.h"
#include "llvm/Testing/Support/Error.h"
#include "gtest/gtest.h"
#include <tuple>
#include <unordered_set>

using namespace llvm;

namespace {

class FileCheckTest : public ::testing::Test {};

static StringRef bufferize(SourceMgr &SM, StringRef Str) {
  std::unique_ptr<MemoryBuffer> Buffer =
      MemoryBuffer::getMemBufferCopy(Str, "TestBuffer");
  StringRef StrBufferRef = Buffer->getBuffer();
  SM.AddNewSourceBuffer(std::move(Buffer), SMLoc());
  return StrBufferRef;
}

template <typename ErrorT>
static void expectError(StringRef ExpectedMsg, Error Err) {
  bool ErrorHandled = false;
  EXPECT_THAT_ERROR(handleErrors(std::move(Err),
                                 [&](const ErrorT &E) {
                                   EXPECT_NE(
                                       E.message().find(ExpectedMsg.str()),
                                       std::string::npos);
                                   ErrorHandled = true;
                                 }),
                    Succeeded());
  EXPECT_TRUE(ErrorHandled);
}

static void expectDiagnosticError(StringRef ExpectedMsg, Error Err) {
  expectError<ErrorDiagnostic>(ExpectedMsg, std::move(Err));
}

struct ExpressionFormatParameterisedFixture
    : public ::testing::TestWithParam<
          std::tuple<ExpressionFormat::Kind, bool, bool>> {
  void SetUp() { std::tie(Kind, AllowHex, AllowUpperHex) = GetParam(); }

  ExpressionFormat::Kind Kind;
  bool AllowHex;
  bool AllowUpperHex;
};

TEST_P(ExpressionFormatParameterisedFixture, Format) {
  SourceMgr SM;
  ExpressionFormat Format(Kind);

  Expected<StringRef> WildcardPattern = Format.getWildcardRegex();
  ASSERT_THAT_EXPECTED(WildcardPattern, Succeeded());
  Regex WildcardRegex(*WildcardPattern);
  ASSERT_TRUE(WildcardRegex.isValid());
  // Does not match empty string.
  EXPECT_FALSE(WildcardRegex.match(""));
  // Matches all decimal digits and matches several of them.
  SmallVector<StringRef, 4> Matches;
  StringRef DecimalDigits = "0123456789";
  ASSERT_TRUE(WildcardRegex.match(DecimalDigits, &Matches));
  EXPECT_EQ(Matches[0], DecimalDigits);
  // Check non digits or digits with wrong casing are not matched.
  if (AllowHex) {
    StringRef HexOnlyDigits[] = {"abcdef", "ABCDEF"};
    StringRef AcceptedHexOnlyDigits =
        AllowUpperHex ? HexOnlyDigits[1] : HexOnlyDigits[0];
    StringRef RefusedHexOnlyDigits =
        AllowUpperHex ? HexOnlyDigits[0] : HexOnlyDigits[1];
    ASSERT_TRUE(WildcardRegex.match(AcceptedHexOnlyDigits, &Matches));
    EXPECT_EQ(Matches[0], AcceptedHexOnlyDigits);
    EXPECT_FALSE(WildcardRegex.match(RefusedHexOnlyDigits));

    EXPECT_FALSE(WildcardRegex.match("g"));
    EXPECT_FALSE(WildcardRegex.match("G"));
  } else {
    EXPECT_FALSE(WildcardRegex.match("a"));
    EXPECT_FALSE(WildcardRegex.match("A"));
  }

  Expected<std::string> MatchingString = Format.getMatchingString(0U);
  ASSERT_THAT_EXPECTED(MatchingString, Succeeded());
  EXPECT_EQ(*MatchingString, "0");
  MatchingString = Format.getMatchingString(9U);
  ASSERT_THAT_EXPECTED(MatchingString, Succeeded());
  EXPECT_EQ(*MatchingString, "9");
  Expected<std::string> TenMatchingString = Format.getMatchingString(10U);
  ASSERT_THAT_EXPECTED(TenMatchingString, Succeeded());
  Expected<std::string> FifteenMatchingString = Format.getMatchingString(15U);
  ASSERT_THAT_EXPECTED(FifteenMatchingString, Succeeded());
  StringRef ExpectedTenMatchingString, ExpectedFifteenMatchingString;
  if (AllowHex) {
    if (AllowUpperHex) {
      ExpectedTenMatchingString = "A";
      ExpectedFifteenMatchingString = "F";
    } else {
      ExpectedTenMatchingString = "a";
      ExpectedFifteenMatchingString = "f";
    }
  } else {
    ExpectedTenMatchingString = "10";
    ExpectedFifteenMatchingString = "15";
  }
  EXPECT_EQ(*TenMatchingString, ExpectedTenMatchingString);
  EXPECT_EQ(*FifteenMatchingString, ExpectedFifteenMatchingString);

  StringRef BufferizedValidValueStr = bufferize(SM, "0");
  Expected<uint64_t> Val =
      Format.valueFromStringRepr(BufferizedValidValueStr, SM);
  ASSERT_THAT_EXPECTED(Val, Succeeded());
  EXPECT_EQ(*Val, 0U);
  BufferizedValidValueStr = bufferize(SM, "9");
  Val = Format.valueFromStringRepr(BufferizedValidValueStr, SM);
  ASSERT_THAT_EXPECTED(Val, Succeeded());
  EXPECT_EQ(*Val, 9U);
  StringRef BufferizedTenStr, BufferizedInvalidTenStr, BufferizedFifteenStr;
  StringRef TenStr, FifteenStr, InvalidTenStr;
  if (AllowHex) {
    if (AllowUpperHex) {
      TenStr = "A";
      FifteenStr = "F";
      InvalidTenStr = "a";
    } else {
      TenStr = "a";
      FifteenStr = "f";
      InvalidTenStr = "A";
    }
  } else {
    TenStr = "10";
    FifteenStr = "15";
    InvalidTenStr = "A";
  }
  BufferizedTenStr = bufferize(SM, TenStr);
  Val = Format.valueFromStringRepr(BufferizedTenStr, SM);
  ASSERT_THAT_EXPECTED(Val, Succeeded());
  EXPECT_EQ(*Val, 10U);
  BufferizedFifteenStr = bufferize(SM, FifteenStr);
  Val = Format.valueFromStringRepr(BufferizedFifteenStr, SM);
  ASSERT_THAT_EXPECTED(Val, Succeeded());
  EXPECT_EQ(*Val, 15U);
  // Wrong casing is not tested because valueFromStringRepr() relies on
  // StringRef's getAsInteger() which does not allow to restrict casing.
  BufferizedInvalidTenStr = bufferize(SM, InvalidTenStr);
  expectDiagnosticError(
      "unable to represent numeric value",
      Format.valueFromStringRepr(bufferize(SM, "G"), SM).takeError());

  // Check boolean operator.
  EXPECT_TRUE(bool(Format));
}

INSTANTIATE_TEST_CASE_P(
    AllowedExplicitExpressionFormat, ExpressionFormatParameterisedFixture,
    ::testing::Values(
        std::make_tuple(ExpressionFormat::Kind::Unsigned, /*AllowHex=*/false,
                        /*AllowUpperHex=*/false),
        std::make_tuple(ExpressionFormat::Kind::HexLower, /*AllowHex=*/true,
                        /*AllowUpperHex=*/false),
        std::make_tuple(ExpressionFormat::Kind::HexUpper, /*AllowHex=*/true,
                        /*AllowUpperHex=*/true)), );

TEST_F(FileCheckTest, NoFormatProperties) {
  ExpressionFormat NoFormat(ExpressionFormat::Kind::NoFormat);
  expectError<StringError>("trying to match value with invalid format",
                           NoFormat.getWildcardRegex().takeError());
  expectError<StringError>("trying to match value with invalid format",
                           NoFormat.getMatchingString(18).takeError());
  EXPECT_FALSE(bool(NoFormat));
}

TEST_F(FileCheckTest, ConflictFormatProperties) {
  ExpressionFormat ConflictFormat(ExpressionFormat::Kind::Conflict);
  expectError<StringError>("trying to match value with invalid format",
                           ConflictFormat.getWildcardRegex().takeError());
  expectError<StringError>("trying to match value with invalid format",
                           ConflictFormat.getMatchingString(18).takeError());
  EXPECT_FALSE(bool(ConflictFormat));
}

TEST_F(FileCheckTest, FormatEqualityOperators) {
  ExpressionFormat UnsignedFormat(ExpressionFormat::Kind::Unsigned);
  ExpressionFormat UnsignedFormat2(ExpressionFormat::Kind::Unsigned);
  EXPECT_TRUE(UnsignedFormat == UnsignedFormat2);
  EXPECT_FALSE(UnsignedFormat != UnsignedFormat2);

  ExpressionFormat HexLowerFormat(ExpressionFormat::Kind::HexLower);
  EXPECT_FALSE(UnsignedFormat == HexLowerFormat);
  EXPECT_TRUE(UnsignedFormat != HexLowerFormat);

  ExpressionFormat NoFormat(ExpressionFormat::Kind::NoFormat);
  ExpressionFormat NoFormat2(ExpressionFormat::Kind::NoFormat);
  EXPECT_FALSE(NoFormat == NoFormat2);
  EXPECT_TRUE(NoFormat != NoFormat2);

  ExpressionFormat ConflictFormat(ExpressionFormat::Kind::Conflict);
  ExpressionFormat ConflictFormat2(ExpressionFormat::Kind::Conflict);
  EXPECT_TRUE(ConflictFormat == ConflictFormat2);
  EXPECT_FALSE(ConflictFormat != ConflictFormat2);
}

TEST_F(FileCheckTest, FormatKindEqualityOperators) {
  ExpressionFormat UnsignedFormat(ExpressionFormat::Kind::Unsigned);
  EXPECT_TRUE(UnsignedFormat == ExpressionFormat::Kind::Unsigned);
  EXPECT_FALSE(UnsignedFormat != ExpressionFormat::Kind::Unsigned);
  EXPECT_FALSE(UnsignedFormat == ExpressionFormat::Kind::HexLower);
  EXPECT_TRUE(UnsignedFormat != ExpressionFormat::Kind::HexLower);
  ExpressionFormat ConflictFormat(ExpressionFormat::Kind::Conflict);
  EXPECT_TRUE(ConflictFormat == ExpressionFormat::Kind::Conflict);
  EXPECT_FALSE(ConflictFormat != ExpressionFormat::Kind::Conflict);
  ExpressionFormat NoFormat(ExpressionFormat::Kind::NoFormat);
  EXPECT_TRUE(NoFormat == ExpressionFormat::Kind::NoFormat);
  EXPECT_FALSE(NoFormat != ExpressionFormat::Kind::NoFormat);
}

TEST_F(FileCheckTest, Literal) {
  // Eval returns the literal's value.
  ExpressionLiteral Ten(10);
  Expected<uint64_t> Value = Ten.eval();
  ASSERT_THAT_EXPECTED(Value, Succeeded());
  EXPECT_EQ(10U, *Value);
  EXPECT_EQ(Ten.getImplicitFormat(), ExpressionFormat::Kind::NoFormat);

  // Max value can be correctly represented.
  ExpressionLiteral Max(std::numeric_limits<uint64_t>::max());
  Value = Max.eval();
  ASSERT_THAT_EXPECTED(Value, Succeeded());
  EXPECT_EQ(std::numeric_limits<uint64_t>::max(), *Value);
}

static std::string toString(const std::unordered_set<std::string> &Set) {
  bool First = true;
  std::string Str;
  for (StringRef S : Set) {
    Str += Twine(First ? "{" + S : ", " + S).str();
    First = false;
  }
  Str += '}';
  return Str;
}

TEST_F(FileCheckTest, Expression) {
  std::unique_ptr<ExpressionLiteral> Ten =
      std::make_unique<ExpressionLiteral>(10);
  ExpressionLiteral *TenPtr = Ten.get();
  Expression Expr(std::move(Ten),
                  ExpressionFormat(ExpressionFormat::Kind::HexLower));
  EXPECT_EQ(Expr.getAST(), TenPtr);
  EXPECT_EQ(Expr.getFormat(), ExpressionFormat::Kind::HexLower);
}

static void
expectUndefErrors(std::unordered_set<std::string> ExpectedUndefVarNames,
                  Error Err) {
  EXPECT_THAT_ERROR(handleErrors(std::move(Err),
                                 [&](const UndefVarError &E) {
                                   EXPECT_EQ(ExpectedUndefVarNames.erase(
                                                 std::string(E.getVarName())),
                                             1U);
                                 }),
                    Succeeded());
  EXPECT_TRUE(ExpectedUndefVarNames.empty()) << toString(ExpectedUndefVarNames);
}

uint64_t doAdd(uint64_t OpL, uint64_t OpR) { return OpL + OpR; }

TEST_F(FileCheckTest, NumericVariable) {
  // Undefined variable: getValue and eval fail, error returned by eval holds
  // the name of the undefined variable.
  NumericVariable FooVar("FOO",
                         ExpressionFormat(ExpressionFormat::Kind::Unsigned), 1);
  EXPECT_EQ("FOO", FooVar.getName());
  EXPECT_EQ(FooVar.getImplicitFormat(), ExpressionFormat::Kind::Unsigned);
  NumericVariableUse FooVarUse("FOO", &FooVar);
  EXPECT_EQ(FooVarUse.getImplicitFormat(), ExpressionFormat::Kind::Unsigned);
  EXPECT_FALSE(FooVar.getValue());
  Expected<uint64_t> EvalResult = FooVarUse.eval();
  expectUndefErrors({"FOO"}, EvalResult.takeError());

  FooVar.setValue(42);

  // Defined variable: getValue and eval return value set.
  Optional<uint64_t> Value = FooVar.getValue();
  ASSERT_TRUE(Value);
  EXPECT_EQ(42U, *Value);
  EvalResult = FooVarUse.eval();
  ASSERT_THAT_EXPECTED(EvalResult, Succeeded());
  EXPECT_EQ(42U, *EvalResult);

  // Clearing variable: getValue and eval fail. Error returned by eval holds
  // the name of the cleared variable.
  FooVar.clearValue();
  EXPECT_FALSE(FooVar.getValue());
  EvalResult = FooVarUse.eval();
  expectUndefErrors({"FOO"}, EvalResult.takeError());
}

TEST_F(FileCheckTest, Binop) {
  NumericVariable FooVar("FOO",
                         ExpressionFormat(ExpressionFormat::Kind::Unsigned), 1);
  FooVar.setValue(42);
  std::unique_ptr<NumericVariableUse> FooVarUse =
      std::make_unique<NumericVariableUse>("FOO", &FooVar);
  NumericVariable BarVar("BAR",
                         ExpressionFormat(ExpressionFormat::Kind::Unsigned), 2);
  BarVar.setValue(18);
  std::unique_ptr<NumericVariableUse> BarVarUse =
      std::make_unique<NumericVariableUse>("BAR", &BarVar);
  BinaryOperation Binop(doAdd, std::move(FooVarUse), std::move(BarVarUse));

  // Defined variables: eval returns right value; implicit format is as
  // expected.
  Expected<uint64_t> Value = Binop.eval();
  ASSERT_THAT_EXPECTED(Value, Succeeded());
  EXPECT_EQ(60U, *Value);
  EXPECT_EQ(Binop.getImplicitFormat(), ExpressionFormat::Kind::Unsigned);

  // 1 undefined variable: eval fails, error contains name of undefined
  // variable.
  FooVar.clearValue();
  Value = Binop.eval();
  expectUndefErrors({"FOO"}, Value.takeError());

  // 2 undefined variables: eval fails, error contains names of all undefined
  // variables.
  BarVar.clearValue();
  Value = Binop.eval();
  expectUndefErrors({"FOO", "BAR"}, Value.takeError());

  // Literal + Variable has format of variable.
  FooVarUse = std::make_unique<NumericVariableUse>("FOO", &FooVar);
  std::unique_ptr<ExpressionLiteral> Eighteen =
      std::make_unique<ExpressionLiteral>(18);
  Binop = BinaryOperation(doAdd, std::move(FooVarUse), std::move(Eighteen));
  EXPECT_EQ(Binop.getImplicitFormat(), ExpressionFormat::Kind::Unsigned);
  FooVarUse = std::make_unique<NumericVariableUse>("FOO", &FooVar);
  Eighteen = std::make_unique<ExpressionLiteral>(18);
  Binop = BinaryOperation(doAdd, std::move(Eighteen), std::move(FooVarUse));
  EXPECT_EQ(Binop.getImplicitFormat(), ExpressionFormat::Kind::Unsigned);

  // Variables with different implicit format conflict.
  NumericVariable BazVar("BAZ",
                         ExpressionFormat(ExpressionFormat::Kind::HexLower), 3);
  FooVarUse = std::make_unique<NumericVariableUse>("BAZ", &FooVar);
  std::unique_ptr<NumericVariableUse> BazVarUse =
      std::make_unique<NumericVariableUse>("BAZ", &BazVar);
  Binop = BinaryOperation(doAdd, std::move(FooVarUse), std::move(BazVarUse));
  EXPECT_EQ(Binop.getImplicitFormat(), ExpressionFormat::Kind::Conflict);
}

TEST_F(FileCheckTest, ValidVarNameStart) {
  EXPECT_TRUE(Pattern::isValidVarNameStart('a'));
  EXPECT_TRUE(Pattern::isValidVarNameStart('G'));
  EXPECT_TRUE(Pattern::isValidVarNameStart('_'));
  EXPECT_FALSE(Pattern::isValidVarNameStart('2'));
  EXPECT_FALSE(Pattern::isValidVarNameStart('$'));
  EXPECT_FALSE(Pattern::isValidVarNameStart('@'));
  EXPECT_FALSE(Pattern::isValidVarNameStart('+'));
  EXPECT_FALSE(Pattern::isValidVarNameStart('-'));
  EXPECT_FALSE(Pattern::isValidVarNameStart(':'));
}

TEST_F(FileCheckTest, ParseVar) {
  SourceMgr SM;
  StringRef OrigVarName = bufferize(SM, "GoodVar42");
  StringRef VarName = OrigVarName;
  Expected<Pattern::VariableProperties> ParsedVarResult =
      Pattern::parseVariable(VarName, SM);
  ASSERT_THAT_EXPECTED(ParsedVarResult, Succeeded());
  EXPECT_EQ(ParsedVarResult->Name, OrigVarName);
  EXPECT_TRUE(VarName.empty());
  EXPECT_FALSE(ParsedVarResult->IsPseudo);

  VarName = OrigVarName = bufferize(SM, "$GoodGlobalVar");
  ParsedVarResult = Pattern::parseVariable(VarName, SM);
  ASSERT_THAT_EXPECTED(ParsedVarResult, Succeeded());
  EXPECT_EQ(ParsedVarResult->Name, OrigVarName);
  EXPECT_TRUE(VarName.empty());
  EXPECT_FALSE(ParsedVarResult->IsPseudo);

  VarName = OrigVarName = bufferize(SM, "@GoodPseudoVar");
  ParsedVarResult = Pattern::parseVariable(VarName, SM);
  ASSERT_THAT_EXPECTED(ParsedVarResult, Succeeded());
  EXPECT_EQ(ParsedVarResult->Name, OrigVarName);
  EXPECT_TRUE(VarName.empty());
  EXPECT_TRUE(ParsedVarResult->IsPseudo);

  VarName = bufferize(SM, "42BadVar");
  ParsedVarResult = Pattern::parseVariable(VarName, SM);
  expectDiagnosticError("invalid variable name", ParsedVarResult.takeError());

  VarName = bufferize(SM, "$@");
  ParsedVarResult = Pattern::parseVariable(VarName, SM);
  expectDiagnosticError("invalid variable name", ParsedVarResult.takeError());

  VarName = OrigVarName = bufferize(SM, "B@dVar");
  ParsedVarResult = Pattern::parseVariable(VarName, SM);
  ASSERT_THAT_EXPECTED(ParsedVarResult, Succeeded());
  EXPECT_EQ(VarName, OrigVarName.substr(1));
  EXPECT_EQ(ParsedVarResult->Name, "B");
  EXPECT_FALSE(ParsedVarResult->IsPseudo);

  VarName = OrigVarName = bufferize(SM, "B$dVar");
  ParsedVarResult = Pattern::parseVariable(VarName, SM);
  ASSERT_THAT_EXPECTED(ParsedVarResult, Succeeded());
  EXPECT_EQ(VarName, OrigVarName.substr(1));
  EXPECT_EQ(ParsedVarResult->Name, "B");
  EXPECT_FALSE(ParsedVarResult->IsPseudo);

  VarName = bufferize(SM, "BadVar+");
  ParsedVarResult = Pattern::parseVariable(VarName, SM);
  ASSERT_THAT_EXPECTED(ParsedVarResult, Succeeded());
  EXPECT_EQ(VarName, "+");
  EXPECT_EQ(ParsedVarResult->Name, "BadVar");
  EXPECT_FALSE(ParsedVarResult->IsPseudo);

  VarName = bufferize(SM, "BadVar-");
  ParsedVarResult = Pattern::parseVariable(VarName, SM);
  ASSERT_THAT_EXPECTED(ParsedVarResult, Succeeded());
  EXPECT_EQ(VarName, "-");
  EXPECT_EQ(ParsedVarResult->Name, "BadVar");
  EXPECT_FALSE(ParsedVarResult->IsPseudo);

  VarName = bufferize(SM, "BadVar:");
  ParsedVarResult = Pattern::parseVariable(VarName, SM);
  ASSERT_THAT_EXPECTED(ParsedVarResult, Succeeded());
  EXPECT_EQ(VarName, ":");
  EXPECT_EQ(ParsedVarResult->Name, "BadVar");
  EXPECT_FALSE(ParsedVarResult->IsPseudo);
}

static void expectNotFoundError(Error Err) {
  expectError<NotFoundError>("String not found in input", std::move(Err));
}

class PatternTester {
private:
  size_t LineNumber = 1;
  SourceMgr SM;
  FileCheckRequest Req;
  FileCheckPatternContext Context;
  Pattern P{Check::CheckPlain, &Context, LineNumber};

public:
  PatternTester() {
    std::vector<std::string> GlobalDefines;
    GlobalDefines.emplace_back(std::string("#FOO=42"));
    GlobalDefines.emplace_back(std::string("BAR=BAZ"));
    // An ASSERT_FALSE would make more sense but cannot be used in a
    // constructor.
    EXPECT_THAT_ERROR(Context.defineCmdlineVariables(GlobalDefines, SM),
                      Succeeded());
    Context.createLineVariable();
    // Call parsePattern to have @LINE defined.
    P.parsePattern("N/A", "CHECK", SM, Req);
    // parsePattern does not expect to be called twice for the same line and
    // will set FixedStr and RegExStr incorrectly if it is. Therefore prepare
    // a pattern for a different line.
    initNextPattern();
  }

  void initNextPattern() {
    P = Pattern(Check::CheckPlain, &Context, ++LineNumber);
  }

  size_t getLineNumber() const { return LineNumber; }

  Expected<std::unique_ptr<Expression>>
  parseSubst(StringRef Expr, bool IsLegacyLineExpr = false) {
    StringRef ExprBufferRef = bufferize(SM, Expr);
    Optional<NumericVariable *> DefinedNumericVariable;
    return P.parseNumericSubstitutionBlock(
        ExprBufferRef, DefinedNumericVariable, IsLegacyLineExpr, LineNumber,
        &Context, SM);
  }

  bool parsePattern(StringRef Pattern) {
    StringRef PatBufferRef = bufferize(SM, Pattern);
    return P.parsePattern(PatBufferRef, "CHECK", SM, Req);
  }

  Expected<size_t> match(StringRef Buffer) {
    StringRef BufferRef = bufferize(SM, Buffer);
    size_t MatchLen;
    return P.match(BufferRef, MatchLen, SM);
  }
};

TEST_F(FileCheckTest, ParseNumericSubstitutionBlock) {
  PatternTester Tester;

  // Variable definition.

  expectDiagnosticError("invalid variable name",
                        Tester.parseSubst("%VAR:").takeError());

  expectDiagnosticError("definition of pseudo numeric variable unsupported",
                        Tester.parseSubst("@LINE:").takeError());

  expectDiagnosticError("string variable with name 'BAR' already exists",
                        Tester.parseSubst("BAR:").takeError());

  expectDiagnosticError("unexpected characters after numeric variable name",
                        Tester.parseSubst("VAR GARBAGE:").takeError());

  // Change of format.
  expectDiagnosticError("format different from previous variable definition",
                        Tester.parseSubst("%X,FOO:").takeError());

  // Invalid format.
  expectDiagnosticError("invalid matching format specification in expression",
                        Tester.parseSubst("X,VAR1:").takeError());
  expectDiagnosticError("invalid format specifier in expression",
                        Tester.parseSubst("%F,VAR1:").takeError());
  expectDiagnosticError("invalid matching format specification in expression",
                        Tester.parseSubst("%X a,VAR1:").takeError());

  // Acceptable variable definition.
  EXPECT_THAT_EXPECTED(Tester.parseSubst("VAR1:"), Succeeded());
  EXPECT_THAT_EXPECTED(Tester.parseSubst("  VAR2:"), Succeeded());
  EXPECT_THAT_EXPECTED(Tester.parseSubst("VAR3  :"), Succeeded());
  EXPECT_THAT_EXPECTED(Tester.parseSubst("VAR3:  "), Succeeded());

  // Acceptable variable definition with format specifier. Use parsePattern for
  // variables whose definition needs to be visible for later checks.
  EXPECT_FALSE(Tester.parsePattern("[[#%u, VAR_UNSIGNED:]]"));
  EXPECT_FALSE(Tester.parsePattern("[[#%x, VAR_LOWER_HEX:]]"));
  EXPECT_THAT_EXPECTED(Tester.parseSubst("%X, VAR_UPPER_HEX:"), Succeeded());

  // Acceptable variable definition from a numeric expression.
  EXPECT_THAT_EXPECTED(Tester.parseSubst("FOOBAR: FOO+1"), Succeeded());

  // Numeric expression. Switch to next line to make above valid definition
  // available in expressions.
  Tester.initNextPattern();

  // Invalid variable name.
  expectDiagnosticError("invalid operand format '%VAR'",
                        Tester.parseSubst("%VAR").takeError());

  expectDiagnosticError("invalid pseudo numeric variable '@FOO'",
                        Tester.parseSubst("@FOO").takeError());

  // parsePattern() is used here instead of parseSubst() for the variable to be
  // recorded in GlobalNumericVariableTable and thus appear defined to
  // parseNumericVariableUse(). Note that the same pattern object is used for
  // the parsePattern() and parseSubst() since no initNextPattern() is called,
  // thus appearing as being on the same line from the pattern's point of view.
  ASSERT_FALSE(Tester.parsePattern("[[#SAME_LINE_VAR:]]"));
  expectDiagnosticError("numeric variable 'SAME_LINE_VAR' defined earlier in "
                        "the same CHECK directive",
                        Tester.parseSubst("SAME_LINE_VAR").takeError());

  // Invalid use of variable defined on the same line from an expression not
  // using any variable defined on the same line.
  ASSERT_FALSE(Tester.parsePattern("[[#SAME_LINE_EXPR_VAR:@LINE+1]]"));
  expectDiagnosticError("numeric variable 'SAME_LINE_EXPR_VAR' defined earlier "
                        "in the same CHECK directive",
                        Tester.parseSubst("SAME_LINE_EXPR_VAR").takeError());

  // Valid use of undefined variable which creates the variable and record it
  // in GlobalNumericVariableTable.
  ASSERT_THAT_EXPECTED(Tester.parseSubst("UNDEF"), Succeeded());
  EXPECT_TRUE(Tester.parsePattern("[[UNDEF:.*]]"));

  // Invalid literal.
  expectDiagnosticError("unsupported operation 'U'",
                        Tester.parseSubst("42U").takeError());

  // Valid empty expression.
  EXPECT_THAT_EXPECTED(Tester.parseSubst(""), Succeeded());

  // Valid single operand expression.
  EXPECT_THAT_EXPECTED(Tester.parseSubst("FOO"), Succeeded());

  // Invalid format.
  expectDiagnosticError("invalid matching format specification in expression",
                        Tester.parseSubst("X,FOO:").takeError());
  expectDiagnosticError("invalid format specifier in expression",
                        Tester.parseSubst("%F,FOO").takeError());
  expectDiagnosticError("invalid matching format specification in expression",
                        Tester.parseSubst("%X a,FOO").takeError());

  // Valid expression with 2 or more operands.
  EXPECT_THAT_EXPECTED(Tester.parseSubst("FOO+3"), Succeeded());
  EXPECT_THAT_EXPECTED(Tester.parseSubst("FOO+0xC"), Succeeded());
  EXPECT_THAT_EXPECTED(Tester.parseSubst("FOO-3+FOO"), Succeeded());

  expectDiagnosticError("unsupported operation '^'",
                        Tester.parseSubst("@LINE^2").takeError());

  expectDiagnosticError("missing operand in expression",
                        Tester.parseSubst("@LINE+").takeError());

  // Errors in RHS operand are bubbled up by parseBinop() to
  // parseNumericSubstitutionBlock().
  expectDiagnosticError("invalid operand format '%VAR'",
                        Tester.parseSubst("@LINE+%VAR").takeError());

  // Invalid legacy @LINE expression with non literal rhs.
  expectDiagnosticError(
      "invalid operand format '@LINE'",
      Tester.parseSubst("@LINE+@LINE", /*IsLegacyNumExpr=*/true).takeError());

  // Invalid legacy @LINE expression made of a single literal.
  expectDiagnosticError(
      "invalid variable name",
      Tester.parseSubst("2", /*IsLegacyNumExpr=*/true).takeError());

  // Invalid hex literal in legacy @LINE expression.
  expectDiagnosticError(
      "unexpected characters at end of expression 'xC'",
      Tester.parseSubst("@LINE+0xC", /*LegacyLineExpr=*/true).takeError());

  // Valid expression with format specifier.
  EXPECT_THAT_EXPECTED(Tester.parseSubst("%u, FOO"), Succeeded());
  EXPECT_THAT_EXPECTED(Tester.parseSubst("%x, FOO"), Succeeded());
  EXPECT_THAT_EXPECTED(Tester.parseSubst("%X, FOO"), Succeeded());

  // Valid legacy @LINE expression.
  EXPECT_THAT_EXPECTED(Tester.parseSubst("@LINE+2", /*IsLegacyNumExpr=*/true),
                       Succeeded());

  // Invalid legacy @LINE expression with more than 2 operands.
  expectDiagnosticError(
      "unexpected characters at end of expression '+@LINE'",
      Tester.parseSubst("@LINE+2+@LINE", /*IsLegacyNumExpr=*/true).takeError());
  expectDiagnosticError(
      "unexpected characters at end of expression '+2'",
      Tester.parseSubst("@LINE+2+2", /*IsLegacyNumExpr=*/true).takeError());

  // Valid expression with several variables when their implicit formats do not
  // conflict.
  EXPECT_THAT_EXPECTED(Tester.parseSubst("FOO+VAR_UNSIGNED"), Succeeded());

  // Valid implicit format conflict in presence of explicit formats.
  EXPECT_THAT_EXPECTED(Tester.parseSubst("%X,FOO+VAR_LOWER_HEX"), Succeeded());

  // Implicit format conflict.
  expectDiagnosticError(
      "variables with conflicting format specifier: need an explicit one",
      Tester.parseSubst("FOO+VAR_LOWER_HEX").takeError());


  // Simple parenthesized expressions:
  EXPECT_THAT_EXPECTED(Tester.parseSubst("(1)"), Succeeded());
  EXPECT_THAT_EXPECTED(Tester.parseSubst("(1+1)"), Succeeded());
  EXPECT_THAT_EXPECTED(Tester.parseSubst("(1)+1"), Succeeded());
  EXPECT_THAT_EXPECTED(Tester.parseSubst("((1)+1)"), Succeeded());
  EXPECT_THAT_EXPECTED(Tester.parseSubst("((1)+X)"), Succeeded());
  EXPECT_THAT_EXPECTED(Tester.parseSubst("((X)+Y)"), Succeeded());

  expectDiagnosticError("missing operand in expression",
                        Tester.parseSubst("(").takeError());
  expectDiagnosticError("missing ')' at end of nested expression",
                        Tester.parseSubst("(1").takeError());
  expectDiagnosticError("missing operand in expression",
                        Tester.parseSubst("(1+").takeError());
  expectDiagnosticError("missing ')' at end of nested expression",
                        Tester.parseSubst("(1+1").takeError());
  expectDiagnosticError("missing ')' at end of nested expression",
                        Tester.parseSubst("((1+2+3").takeError());
  expectDiagnosticError("missing ')' at end of nested expression",
                        Tester.parseSubst("((1+2)+3").takeError());
  // Valid empty expression.
}

TEST_F(FileCheckTest, ParsePattern) {
  PatternTester Tester;

  // Invalid space in string substitution.
  EXPECT_TRUE(Tester.parsePattern("[[ BAR]]"));

  // Invalid variable name in string substitution.
  EXPECT_TRUE(Tester.parsePattern("[[42INVALID]]"));

  // Invalid string variable definition.
  EXPECT_TRUE(Tester.parsePattern("[[@PAT:]]"));
  EXPECT_TRUE(Tester.parsePattern("[[PAT+2:]]"));

  // Collision with numeric variable.
  EXPECT_TRUE(Tester.parsePattern("[[FOO:]]"));

  // Valid use of string variable.
  EXPECT_FALSE(Tester.parsePattern("[[BAR]]"));

  // Valid string variable definition.
  EXPECT_FALSE(Tester.parsePattern("[[PAT:[0-9]+]]"));

  // Invalid numeric substitution.
  EXPECT_TRUE(Tester.parsePattern("[[#42INVALID]]"));

  // Valid numeric substitution.
  EXPECT_FALSE(Tester.parsePattern("[[#FOO]]"));

  // Valid legacy @LINE expression.
  EXPECT_FALSE(Tester.parsePattern("[[@LINE+2]]"));

  // Invalid legacy @LINE expression with non decimal literal.
  EXPECT_TRUE(Tester.parsePattern("[[@LINE+0x3]]"));
}

TEST_F(FileCheckTest, Match) {
  PatternTester Tester;

  // Check matching an empty expression only matches a number.
  ASSERT_FALSE(Tester.parsePattern("[[#]]"));
  expectNotFoundError(Tester.match("FAIL").takeError());
  EXPECT_THAT_EXPECTED(Tester.match("18"), Succeeded());

  // Check matching a definition only matches a number with the right format.
  Tester.initNextPattern();
  ASSERT_FALSE(Tester.parsePattern("[[#NUMVAR:]]"));
  expectNotFoundError(Tester.match("FAIL").takeError());
  expectNotFoundError(Tester.match("").takeError());
  EXPECT_THAT_EXPECTED(Tester.match("18"), Succeeded());
  Tester.initNextPattern();
  Tester.parsePattern("[[#%u,NUMVAR_UNSIGNED:]]");
  expectNotFoundError(Tester.match("C").takeError());
  EXPECT_THAT_EXPECTED(Tester.match("20"), Succeeded());
  Tester.initNextPattern();
  Tester.parsePattern("[[#%x,NUMVAR_LOWER_HEX:]]");
  expectNotFoundError(Tester.match("g").takeError());
  expectNotFoundError(Tester.match("C").takeError());
  EXPECT_THAT_EXPECTED(Tester.match("c"), Succeeded());
  Tester.initNextPattern();
  Tester.parsePattern("[[#%X,NUMVAR_UPPER_HEX:]]");
  expectNotFoundError(Tester.match("H").takeError());
  expectNotFoundError(Tester.match("b").takeError());
  EXPECT_THAT_EXPECTED(Tester.match("B"), Succeeded());

  // Check matching expressions with no explicit format matches the values in
  // the right format.
  Tester.initNextPattern();
  Tester.parsePattern("[[#NUMVAR_UNSIGNED-5]]");
  expectNotFoundError(Tester.match("f").takeError());
  expectNotFoundError(Tester.match("F").takeError());
  EXPECT_THAT_EXPECTED(Tester.match("15"), Succeeded());
  Tester.initNextPattern();
  Tester.parsePattern("[[#NUMVAR_LOWER_HEX+1]]");
  expectNotFoundError(Tester.match("13").takeError());
  expectNotFoundError(Tester.match("D").takeError());
  EXPECT_THAT_EXPECTED(Tester.match("d"), Succeeded());
  Tester.initNextPattern();
  Tester.parsePattern("[[#NUMVAR_UPPER_HEX+1]]");
  expectNotFoundError(Tester.match("12").takeError());
  expectNotFoundError(Tester.match("c").takeError());
  EXPECT_THAT_EXPECTED(Tester.match("C"), Succeeded());

  // Check matching an undefined variable returns a NotFound error.
  Tester.initNextPattern();
  ASSERT_FALSE(Tester.parsePattern("100"));
  expectNotFoundError(Tester.match("101").takeError());

  // Check matching the defined variable matches the correct number only.
  Tester.initNextPattern();
  ASSERT_FALSE(Tester.parsePattern("[[#NUMVAR]]"));
  EXPECT_THAT_EXPECTED(Tester.match("18"), Succeeded());

  // Check matching several substitutions does not match them independently.
  Tester.initNextPattern();
  ASSERT_FALSE(Tester.parsePattern("[[#NUMVAR]] [[#NUMVAR+2]]"));
  expectNotFoundError(Tester.match("19 21").takeError());
  expectNotFoundError(Tester.match("18 21").takeError());
  EXPECT_THAT_EXPECTED(Tester.match("18 20"), Succeeded());

  // Check matching a numeric expression using @LINE after a match failure uses
  // the correct value for @LINE.
  Tester.initNextPattern();
  ASSERT_FALSE(Tester.parsePattern("[[#@LINE]]"));
  // Ok, @LINE matches the current line number.
  EXPECT_THAT_EXPECTED(Tester.match(std::to_string(Tester.getLineNumber())),
                       Succeeded());
  Tester.initNextPattern();
  // Match with substitution failure.
  ASSERT_FALSE(Tester.parsePattern("[[#UNKNOWN]]"));
  expectUndefErrors({"UNKNOWN"}, Tester.match("FOO").takeError());
  Tester.initNextPattern();
  // Check that @LINE matches the later (given the calls to initNextPattern())
  // line number.
  EXPECT_FALSE(Tester.parsePattern("[[#@LINE]]"));
  EXPECT_THAT_EXPECTED(Tester.match(std::to_string(Tester.getLineNumber())),
                       Succeeded());
}

TEST_F(FileCheckTest, MatchParen) {
  PatternTester Tester;
  // Check simple parenthesized expressions
  Tester.initNextPattern();
  ASSERT_FALSE(Tester.parsePattern("[[#NUMVAR:]]"));
  expectNotFoundError(Tester.match("FAIL").takeError());
  expectNotFoundError(Tester.match("").takeError());
  EXPECT_THAT_EXPECTED(Tester.match("18"), Succeeded());

  Tester.initNextPattern();
  ASSERT_FALSE(Tester.parsePattern("[[#NUMVAR + (2 + 2)]]"));
  expectNotFoundError(Tester.match("21").takeError());
  EXPECT_THAT_EXPECTED(Tester.match("22"), Succeeded());
  Tester.initNextPattern();
  ASSERT_FALSE(Tester.parsePattern("[[#NUMVAR + (2)]]"));
  EXPECT_THAT_EXPECTED(Tester.match("20"), Succeeded());
  Tester.initNextPattern();
  ASSERT_FALSE(Tester.parsePattern("[[#NUMVAR+(2)]]"));
  EXPECT_THAT_EXPECTED(Tester.match("20"), Succeeded());
  Tester.initNextPattern();
  ASSERT_FALSE(Tester.parsePattern("[[#NUMVAR+(NUMVAR)]]"));
  EXPECT_THAT_EXPECTED(Tester.match("36"), Succeeded());

  // Check nested parenthesized expressions:
  Tester.initNextPattern();
  ASSERT_FALSE(Tester.parsePattern("[[#NUMVAR+(2+(2))]]"));
  EXPECT_THAT_EXPECTED(Tester.match("22"), Succeeded());
  Tester.initNextPattern();
  ASSERT_FALSE(Tester.parsePattern("[[#NUMVAR+(2+(NUMVAR))]]"));
  EXPECT_THAT_EXPECTED(Tester.match("38"), Succeeded());
  Tester.initNextPattern();
  ASSERT_FALSE(Tester.parsePattern("[[#NUMVAR+((((NUMVAR))))]]"));
  EXPECT_THAT_EXPECTED(Tester.match("36"), Succeeded());
  Tester.initNextPattern();
  ASSERT_FALSE(Tester.parsePattern("[[#NUMVAR+((((NUMVAR)))-1)-1]]"));
  EXPECT_THAT_EXPECTED(Tester.match("34"), Succeeded());

  // Parentheses can also be the first character after the '#':
  Tester.initNextPattern();
  ASSERT_FALSE(Tester.parsePattern("[[#(NUMVAR)]]"));
  EXPECT_THAT_EXPECTED(Tester.match("18"), Succeeded());
  Tester.initNextPattern();
  ASSERT_FALSE(Tester.parsePattern("[[#(NUMVAR+2)]]"));
  EXPECT_THAT_EXPECTED(Tester.match("20"), Succeeded());
}

TEST_F(FileCheckTest, Substitution) {
  SourceMgr SM;
  FileCheckPatternContext Context;
  std::vector<std::string> GlobalDefines;
  GlobalDefines.emplace_back(std::string("FOO=BAR"));
  EXPECT_THAT_ERROR(Context.defineCmdlineVariables(GlobalDefines, SM),
                    Succeeded());

  // Substitution of an undefined string variable fails and error holds that
  // variable's name.
  StringSubstitution StringSubstitution(&Context, "VAR404", 42);
  Expected<std::string> SubstValue = StringSubstitution.getResult();
  expectUndefErrors({"VAR404"}, SubstValue.takeError());

  // Numeric substitution blocks constituted of defined numeric variables are
  // substituted for the variable's value.
  NumericVariable NVar("N", ExpressionFormat(ExpressionFormat::Kind::Unsigned),
                       1);
  NVar.setValue(10);
  auto NVarUse = std::make_unique<NumericVariableUse>("N", &NVar);
  auto ExpressionN = std::make_unique<Expression>(
      std::move(NVarUse), ExpressionFormat(ExpressionFormat::Kind::HexUpper));
  NumericSubstitution SubstitutionN(&Context, "N", std::move(ExpressionN),
                                    /*InsertIdx=*/30);
  SubstValue = SubstitutionN.getResult();
  ASSERT_THAT_EXPECTED(SubstValue, Succeeded());
  EXPECT_EQ("A", *SubstValue);

  // Substitution of an undefined numeric variable fails, error holds name of
  // undefined variable.
  NVar.clearValue();
  SubstValue = SubstitutionN.getResult();
  expectUndefErrors({"N"}, SubstValue.takeError());

  // Substitution of a defined string variable returns the right value.
  Pattern P(Check::CheckPlain, &Context, 1);
  StringSubstitution = llvm::StringSubstitution(&Context, "FOO", 42);
  SubstValue = StringSubstitution.getResult();
  ASSERT_THAT_EXPECTED(SubstValue, Succeeded());
  EXPECT_EQ("BAR", *SubstValue);
}

TEST_F(FileCheckTest, FileCheckContext) {
  FileCheckPatternContext Cxt;
  std::vector<std::string> GlobalDefines;
  SourceMgr SM;

  // No definition.
  EXPECT_THAT_ERROR(Cxt.defineCmdlineVariables(GlobalDefines, SM), Succeeded());

  // Missing equal sign.
  GlobalDefines.emplace_back(std::string("LocalVar"));
  expectDiagnosticError("missing equal sign in global definition",
                        Cxt.defineCmdlineVariables(GlobalDefines, SM));
  GlobalDefines.clear();
  GlobalDefines.emplace_back(std::string("#LocalNumVar"));
  expectDiagnosticError("missing equal sign in global definition",
                        Cxt.defineCmdlineVariables(GlobalDefines, SM));

  // Empty variable name.
  GlobalDefines.clear();
  GlobalDefines.emplace_back(std::string("=18"));
  expectDiagnosticError("empty variable name",
                        Cxt.defineCmdlineVariables(GlobalDefines, SM));
  GlobalDefines.clear();
  GlobalDefines.emplace_back(std::string("#=18"));
  expectDiagnosticError("empty variable name",
                        Cxt.defineCmdlineVariables(GlobalDefines, SM));

  // Invalid variable name.
  GlobalDefines.clear();
  GlobalDefines.emplace_back(std::string("18LocalVar=18"));
  expectDiagnosticError("invalid variable name",
                        Cxt.defineCmdlineVariables(GlobalDefines, SM));
  GlobalDefines.clear();
  GlobalDefines.emplace_back(std::string("#18LocalNumVar=18"));
  expectDiagnosticError("invalid variable name",
                        Cxt.defineCmdlineVariables(GlobalDefines, SM));

  // Name conflict between pattern and numeric variable.
  GlobalDefines.clear();
  GlobalDefines.emplace_back(std::string("LocalVar=18"));
  GlobalDefines.emplace_back(std::string("#LocalVar=36"));
  expectDiagnosticError("string variable with name 'LocalVar' already exists",
                        Cxt.defineCmdlineVariables(GlobalDefines, SM));
  Cxt = FileCheckPatternContext();
  GlobalDefines.clear();
  GlobalDefines.emplace_back(std::string("#LocalNumVar=18"));
  GlobalDefines.emplace_back(std::string("LocalNumVar=36"));
  expectDiagnosticError(
      "numeric variable with name 'LocalNumVar' already exists",
      Cxt.defineCmdlineVariables(GlobalDefines, SM));
  Cxt = FileCheckPatternContext();

  // Invalid numeric value for numeric variable.
  GlobalDefines.clear();
  GlobalDefines.emplace_back(std::string("#LocalNumVar=x"));
  expectUndefErrors({"x"}, Cxt.defineCmdlineVariables(GlobalDefines, SM));

  // Define local variables from command-line.
  GlobalDefines.clear();
  // Clear local variables to remove dummy numeric variable x that
  // parseNumericSubstitutionBlock would have created and stored in
  // GlobalNumericVariableTable.
  Cxt.clearLocalVars();
  GlobalDefines.emplace_back(std::string("LocalVar=FOO"));
  GlobalDefines.emplace_back(std::string("EmptyVar="));
  GlobalDefines.emplace_back(std::string("#LocalNumVar1=18"));
  GlobalDefines.emplace_back(std::string("#%x,LocalNumVar2=LocalNumVar1+2"));
  GlobalDefines.emplace_back(std::string("#LocalNumVar3=0xc"));
  ASSERT_THAT_ERROR(Cxt.defineCmdlineVariables(GlobalDefines, SM), Succeeded());

  // Create @LINE pseudo numeric variable and check it is present by matching
  // it.
  size_t LineNumber = 1;
  Pattern P(Check::CheckPlain, &Cxt, LineNumber);
  FileCheckRequest Req;
  Cxt.createLineVariable();
  ASSERT_FALSE(P.parsePattern("[[@LINE]]", "CHECK", SM, Req));
  size_t MatchLen;
  ASSERT_THAT_EXPECTED(P.match("1", MatchLen, SM), Succeeded());

#ifndef NDEBUG
  // Recreating @LINE pseudo numeric variable fails.
  EXPECT_DEATH(Cxt.createLineVariable(),
               "@LINE pseudo numeric variable already created");
#endif

  // Check defined variables are present and undefined ones are absent.
  StringRef LocalVarStr = "LocalVar";
  StringRef LocalNumVar1Ref = bufferize(SM, "LocalNumVar1");
  StringRef LocalNumVar2Ref = bufferize(SM, "LocalNumVar2");
  StringRef LocalNumVar3Ref = bufferize(SM, "LocalNumVar3");
  StringRef EmptyVarStr = "EmptyVar";
  StringRef UnknownVarStr = "UnknownVar";
  Expected<StringRef> LocalVar = Cxt.getPatternVarValue(LocalVarStr);
  P = Pattern(Check::CheckPlain, &Cxt, ++LineNumber);
  Optional<NumericVariable *> DefinedNumericVariable;
  Expected<std::unique_ptr<Expression>> ExpressionPointer =
      P.parseNumericSubstitutionBlock(LocalNumVar1Ref, DefinedNumericVariable,
                                      /*IsLegacyLineExpr=*/false, LineNumber,
                                      &Cxt, SM);
  ASSERT_THAT_EXPECTED(LocalVar, Succeeded());
  EXPECT_EQ(*LocalVar, "FOO");
  Expected<StringRef> EmptyVar = Cxt.getPatternVarValue(EmptyVarStr);
  Expected<StringRef> UnknownVar = Cxt.getPatternVarValue(UnknownVarStr);
  ASSERT_THAT_EXPECTED(ExpressionPointer, Succeeded());
  Expected<uint64_t> ExpressionVal = (*ExpressionPointer)->getAST()->eval();
  ASSERT_THAT_EXPECTED(ExpressionVal, Succeeded());
  EXPECT_EQ(*ExpressionVal, 18U);
  ExpressionPointer = P.parseNumericSubstitutionBlock(
      LocalNumVar2Ref, DefinedNumericVariable,
      /*IsLegacyLineExpr=*/false, LineNumber, &Cxt, SM);
  ASSERT_THAT_EXPECTED(ExpressionPointer, Succeeded());
  ExpressionVal = (*ExpressionPointer)->getAST()->eval();
  ASSERT_THAT_EXPECTED(ExpressionVal, Succeeded());
  EXPECT_EQ(*ExpressionVal, 20U);
  ExpressionPointer =
      P.parseNumericSubstitutionBlock(LocalNumVar3Ref, DefinedNumericVariable,
                                      /*IsLegacyLineExpr=*/false,
                                      LineNumber, &Cxt, SM);
  ASSERT_THAT_EXPECTED(ExpressionPointer, Succeeded());
  ExpressionVal = (*ExpressionPointer)->getAST()->eval();
  ASSERT_THAT_EXPECTED(ExpressionVal, Succeeded());
  EXPECT_EQ(*ExpressionVal, 12U);
  ASSERT_THAT_EXPECTED(EmptyVar, Succeeded());
  EXPECT_EQ(*EmptyVar, "");
  expectUndefErrors({std::string(UnknownVarStr)}, UnknownVar.takeError());

  // Clear local variables and check they become absent.
  Cxt.clearLocalVars();
  LocalVar = Cxt.getPatternVarValue(LocalVarStr);
  expectUndefErrors({std::string(LocalVarStr)}, LocalVar.takeError());
  // Check a numeric expression's evaluation fails if called after clearing of
  // local variables, if it was created before. This is important because local
  // variable clearing due to --enable-var-scope happens after numeric
  // expressions are linked to the numeric variables they use.
  expectUndefErrors({"LocalNumVar3"},
                    (*ExpressionPointer)->getAST()->eval().takeError());
  P = Pattern(Check::CheckPlain, &Cxt, ++LineNumber);
  ExpressionPointer = P.parseNumericSubstitutionBlock(
      LocalNumVar1Ref, DefinedNumericVariable, /*IsLegacyLineExpr=*/false,
      LineNumber, &Cxt, SM);
  ASSERT_THAT_EXPECTED(ExpressionPointer, Succeeded());
  ExpressionVal = (*ExpressionPointer)->getAST()->eval();
  expectUndefErrors({"LocalNumVar1"}, ExpressionVal.takeError());
  ExpressionPointer = P.parseNumericSubstitutionBlock(
      LocalNumVar2Ref, DefinedNumericVariable, /*IsLegacyLineExpr=*/false,
      LineNumber, &Cxt, SM);
  ASSERT_THAT_EXPECTED(ExpressionPointer, Succeeded());
  ExpressionVal = (*ExpressionPointer)->getAST()->eval();
  expectUndefErrors({"LocalNumVar2"}, ExpressionVal.takeError());
  EmptyVar = Cxt.getPatternVarValue(EmptyVarStr);
  expectUndefErrors({"EmptyVar"}, EmptyVar.takeError());
  // Clear again because parseNumericSubstitutionBlock would have created a
  // dummy variable and stored it in GlobalNumericVariableTable.
  Cxt.clearLocalVars();

  // Redefine global variables and check variables are defined again.
  GlobalDefines.emplace_back(std::string("$GlobalVar=BAR"));
  GlobalDefines.emplace_back(std::string("#$GlobalNumVar=36"));
  ASSERT_THAT_ERROR(Cxt.defineCmdlineVariables(GlobalDefines, SM), Succeeded());
  StringRef GlobalVarStr = "$GlobalVar";
  StringRef GlobalNumVarRef = bufferize(SM, "$GlobalNumVar");
  Expected<StringRef> GlobalVar = Cxt.getPatternVarValue(GlobalVarStr);
  ASSERT_THAT_EXPECTED(GlobalVar, Succeeded());
  EXPECT_EQ(*GlobalVar, "BAR");
  P = Pattern(Check::CheckPlain, &Cxt, ++LineNumber);
  ExpressionPointer = P.parseNumericSubstitutionBlock(
      GlobalNumVarRef, DefinedNumericVariable, /*IsLegacyLineExpr=*/false,
      LineNumber, &Cxt, SM);
  ASSERT_THAT_EXPECTED(ExpressionPointer, Succeeded());
  ExpressionVal = (*ExpressionPointer)->getAST()->eval();
  ASSERT_THAT_EXPECTED(ExpressionVal, Succeeded());
  EXPECT_EQ(*ExpressionVal, 36U);

  // Clear local variables and check global variables remain defined.
  Cxt.clearLocalVars();
  EXPECT_THAT_EXPECTED(Cxt.getPatternVarValue(GlobalVarStr), Succeeded());
  P = Pattern(Check::CheckPlain, &Cxt, ++LineNumber);
  ExpressionPointer = P.parseNumericSubstitutionBlock(
      GlobalNumVarRef, DefinedNumericVariable, /*IsLegacyLineExpr=*/false,
      LineNumber, &Cxt, SM);
  ASSERT_THAT_EXPECTED(ExpressionPointer, Succeeded());
  ExpressionVal = (*ExpressionPointer)->getAST()->eval();
  ASSERT_THAT_EXPECTED(ExpressionVal, Succeeded());
  EXPECT_EQ(*ExpressionVal, 36U);
}
} // namespace
