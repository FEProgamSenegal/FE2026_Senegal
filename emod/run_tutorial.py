#!/usr/bin/env python3
"""Course launcher checkpoint.

The instructor replaces `run_validated_emod` with the currently validated
official emodpy-malaria Tutorial 1 workflow before student delivery. Keeping
this guard prevents a successful placeholder from being mistaken for EMOD.
"""
import argparse
import json
import pathlib
import platform
import sys


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--seed", type=int, required=True)
    parser.add_argument("--output", type=pathlib.Path, required=True)
    return parser.parse_args()


def validate_environment(output, seed):
    import emodpy_malaria  # noqa: F401
    import idmtools  # noqa: F401
    output.mkdir(parents=True, exist_ok=True)
    report = {
        "checkpoint": "imports-only",
        "seed": seed,
        "python": sys.version,
        "host": platform.node(),
        "warning": "Instructor must integrate and validate official Tutorial 1 before class.",
    }
    (output / "environment.json").write_text(json.dumps(report, indent=2))


if __name__ == "__main__":
    args = parse_args()
    validate_environment(args.output, args.seed)
    raise SystemExit(
        "Environment validated, but EMOD was intentionally not run. "
        "Instructor: complete instructor/EMOD_VALIDATION.md."
    )
