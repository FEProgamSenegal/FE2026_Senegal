#!/usr/bin/env bash
set -u
check() {
  if command -v "$1" >/dev/null 2>&1; then
    printf 'OK          %s\n' "$1"
  else
    printf 'À INSTALLER %s\n' "$1"
  fi
}
check git
check ssh
check scp
check python3
printf '\nGit: '; git --version 2>/dev/null || true
printf 'Python: '; python3 --version 2>/dev/null || true
