#!/usr/bin/env python3
# /// script
# requires-python = ">=3.10"
# dependencies = ["puzpy==0.6.1"]
# ///

import glob
import sys
import puz

def check(path: str) -> list[str]:
    issues = []

    with open(path, 'rb') as f:
        original = f.read()

    try:
        p = puz.load(original)
    except puz.PuzzleFormatError as e:
        issues.append(f"parse error: {e.message}")
        return issues

    if not p.width or not p.height:
        issues.append("zero width or height")
    if not p.solution or len(p.solution) != p.width * p.height:
        issues.append(f"solution length {len(p.solution)} != {p.width * p.height}")
    if not p.clues:
        issues.append("no clues")

    roundtripped = p.tobytes()
    if roundtripped != original:
        issues.append(f"round-trip mismatch ({len(original)} -> {len(roundtripped)} bytes)")

    return issues


args = sys.argv[1:]
if not args:
    print("usage: check-puz.py file.puz [file.puz ...] or check-puz.py /dir/*.puz")
    sys.exit(1)

paths = []
for arg in args:
    expanded = glob.glob(arg)
    paths.extend(expanded if expanded else [arg])

failures = 0
for path in paths:
    issues = check(path)
    status = "FAIL" if issues else "OK"
    print(f"{status}  {path}")
    for issue in issues:
        print(f"      {issue}")
    if issues:
        failures += 1

print(f"\n{len(paths) - failures}/{len(paths)} passed")
sys.exit(0 if failures == 0 else 1)
