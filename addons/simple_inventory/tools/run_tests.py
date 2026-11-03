"""Validate the distributable plugin in a disposable Godot host."""
import argparse
from pathlib import Path
import re
import shutil
import subprocess
import tempfile


def run(godot, host, arguments, marker=None):
    result = subprocess.run(
        [godot, "--headless", "--path", str(host), *arguments],
        capture_output=True, text=True, encoding="utf-8", errors="replace", timeout=180,
    )
    output = result.stdout + result.stderr
    print(output, flush=True)
    if result.returncode or re.search(r"SCRIPT ERROR:|ERROR:|Parse Error:", output):
        raise RuntimeError("Godot validation failed")
    if marker and marker not in output:
        raise RuntimeError("Godot completion marker missing")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--godot", required=True)
    args = parser.parse_args()
    plugin = Path(__file__).resolve().parents[1]
    with tempfile.TemporaryDirectory(prefix="inventory-distribution-") as temporary:
        host = Path(temporary)
        shutil.copytree(
            plugin, host / "addons/simple_inventory",
            ignore=shutil.ignore_patterns(".git", ".godot", "__pycache__"),
        )
        (host / "project.godot").write_text(
            'config_version=5\n[application]\nconfig/name="Inventory Distribution Contracts"\n'
            '[autoload]\nItemManager="*res://addons/simple_inventory/scripts/managers/item_manager.gd"\n'
            'ItemUseStrategyManager="*res://addons/simple_inventory/scripts/managers/item_use_strategy_manager.gd"\n'
            '[rendering]\nrenderer/rendering_method="gl_compatibility"\n',
            encoding="utf-8",
        )
        run(args.godot, host, ["--editor", "--import"])
        run(args.godot, host, ["res://addons/simple_inventory/tests/contracts.tscn"],
            "INVENTORY CONTRACTS: 9 checks, 0 failures")


if __name__ == "__main__":
    main()
