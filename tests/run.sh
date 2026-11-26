#!/usr/bin/env bash
# Runs each test script in this directory with `nanyx run` and compares what it prints with its `.expected` file.
# Give the compiler to use as NANYX (default: `nanyx` on the PATH).
#
# A script in the package's own directory would be one of its files, so the tests run from a temporary directory
# that holds a copy of the package, `nanyx.json`, beside them: each names it with `::install nanyx.json ./nanyx.json`.
set -u
nanyx="${NANYX:-nanyx}"
tests="$(cd "$(dirname "$0")" && pwd)"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
mkdir "$work/nanyx.json"
cp -r "$tests/../nanyx.json.nyxp" "$tests/../src" "$work/nanyx.json/"
cp "$tests"/*.nyx "$work/"
cd "$work"
failed=0
for test in *.nyx; do
  expected="$tests/${test%.nyx}.expected"
  if actual="$("$nanyx" run "$test" 2>&1)" && [ "$actual" == "$(cat "$expected")" ]; then
    echo "pass  $test"
  else
    echo "FAIL  $test"
    diff "$expected" <(printf '%s\n' "$actual") | sed 's/^/      /'
    failed=$((failed + 1))
  fi
done
echo
if [ "$failed" -gt 0 ]; then
  echo "$failed of $(ls *.nyx | wc -l) tests failed"
  exit 1
fi
echo "All $(ls *.nyx | wc -l) tests passed"
