#!/usr/bin/env python3
"""Validate the skills in this repo.

Checks that every skills/<dir>/SKILL.md:
  - has YAML frontmatter
  - declares a name that matches its directory
  - declares a description long enough to be useful as a trigger

With --check-readme, also checks that every skill is linked from README.md.

No third-party dependencies: the frontmatter here is flat key/value, so it is
parsed directly rather than pulling in a YAML library.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SKILLS = ROOT / "skills"
MIN_DESC = 40
MAX_DESC = 1024


def parse_frontmatter(text: str) -> dict[str, str] | None:
    if not text.startswith("---"):
        return None
    end = text.find("\n---", 3)
    if end == -1:
        return None
    fields: dict[str, str] = {}
    for line in text[3:end].splitlines():
        if not line.strip() or line.lstrip().startswith("#"):
            continue
        m = re.match(r"^([A-Za-z0-9_-]+):\s*(.*)$", line)
        if m:
            fields[m.group(1)] = m.group(2).strip().strip('"').strip("'")
    return fields


def main(argv: list[str]) -> int:
    check_readme = "--check-readme" in argv
    readme = (ROOT / "README.md").read_text(encoding="utf-8") if (ROOT / "README.md").exists() else ""

    problems: list[str] = []
    dirs = sorted(p.name for p in SKILLS.iterdir() if p.is_dir()) if SKILLS.exists() else []
    if not dirs:
        problems.append("no skill directories found under skills/")

    for name in dirs:
        skill_file = SKILLS / name / "SKILL.md"
        if not skill_file.exists():
            problems.append(f"{name}: missing SKILL.md")
            continue
        fields = parse_frontmatter(skill_file.read_text(encoding="utf-8"))
        if fields is None:
            problems.append(f"{name}: SKILL.md has no frontmatter")
            continue
        declared = fields.get("name", "")
        desc = fields.get("description", "")
        if not declared:
            problems.append(f"{name}: frontmatter has no name")
        elif declared != name:
            problems.append(f"{name}: frontmatter name is {declared!r}, expected {name!r}")
        if not desc:
            problems.append(f"{name}: frontmatter has no description")
        elif len(desc) < MIN_DESC:
            problems.append(f"{name}: description is {len(desc)} chars, needs at least {MIN_DESC}")
        elif len(desc) > MAX_DESC:
            problems.append(f"{name}: description is {len(desc)} chars, max {MAX_DESC}")
        if check_readme and f"skills/{name}" not in readme:
            problems.append(f"{name}: not linked from README.md")

    if problems:
        print(f"{len(problems)} problem(s):")
        for p in problems:
            print(f"  - {p}")
        return 1

    print(f"{len(dirs)} skills ok" + (" (readme checked)" if check_readme else ""))
    for name in dirs:
        print(f"  - {name}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
