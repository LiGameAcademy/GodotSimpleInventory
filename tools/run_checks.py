"""Run the source project's rules, UI isolation and distributable-host checks."""
import argparse
from pathlib import Path
import re
import subprocess
import sys


def run(command, marker=None, expected_errors=()):
    result = subprocess.run(command, capture_output=True, text=True,
                            encoding="utf-8", errors="replace", timeout=240)
    output = result.stdout + result.stderr
    print(output, flush=True)
    errors = re.findall(r"^ERROR: (.*)$", output, re.MULTILINE)
    errors = [line.rstrip() for line in errors]
    if (result.returncode or re.search(r"SCRIPT ERROR:|Parse Error:", output)
            or errors != list(expected_errors)):
        raise RuntimeError("Inventory validation failed")
    if marker and marker not in output:
        raise RuntimeError("Inventory completion marker missing")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--godot", required=True)
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[1]
    engine = [args.godot, "--headless", "--path", str(root)]
    run([*engine, "--editor", "--import"])
    # The invalid-ID negative case deliberately reports this one engine error.
    run([*engine, "res://tests/test_main.tscn"], "总测试数: 169",
        ("ItemManager: 未找到物品配置: invalid_id",))
    run([*engine, "res://tests/test_ui_isolation.tscn"], "UI isolation: 10 passed, 0 failed")
    run([sys.executable, str(root / "addons/simple_inventory/tools/run_tests.py"),
         "--godot", args.godot], "INVENTORY CONTRACTS: 9 checks, 0 failures")


if __name__ == "__main__":
    main()
