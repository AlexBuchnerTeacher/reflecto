#!/usr/bin/env bash
# Pre-commit hook for Reflecto
# Runs formatting and analysis checks before commit
#
# Installation:
#   cp scripts/pre-commit.sh .git/hooks/pre-commit
#   chmod +x .git/hooks/pre-commit
#
# Or use in CI: ./scripts/pre-commit.sh

set -e

echo "🔍 Running pre-commit checks..."

# 1. Format check
echo "📝 Checking Dart formatting..."
if ! dart format --output=none --set-exit-if-changed .; then
  echo "❌ Format check failed!"
  echo "Run: dart format ."
  exit 1
fi
echo "✅ Formatting OK"

# 2. Flutter analyze
echo "🔎 Running flutter analyze..."
if ! flutter analyze --fatal-infos; then
  echo "❌ Analysis failed!"
  echo "Fix lint errors before committing."
  exit 1
fi
echo "✅ Analysis OK"

# 3. Check for debug code (optional, non-blocking)
echo "🐛 Checking for debug code..."
if grep -rn --include="*.dart" --exclude-dir={build,test,.dart_tool} -E "print\(|debugPrint\(|TODO:|FIXME:" lib/ 2>/dev/null | grep -v "// ignore:"; then
  echo "⚠️  Warning: Found debug code or TODOs (non-blocking)"
else
  echo "✅ No debug code found"
fi

# 4. Run quick tests (optional, can be slow - uncomment if needed)
# echo "🧪 Running unit tests..."
# if ! flutter test --no-pub test/unit/; then
#   echo "❌ Tests failed!"
#   exit 1
# fi
# echo "✅ Tests OK"

echo "✅ Pre-commit checks passed!"
exit 0
