"""فحص الهوية (BRAND_DIRECTIVE §11-12، BRD-29).
1) وجود ملفات الهوية الإلزامية.
2) كل لون HEX في شيفرة apps/ وpackages/ موجود في packages/design-tokens/tokens.json.
الاستخدام: python3 scripts/check_brand.py <جذر المشروع>   — يخرج برمز 1 عند أي نقص أو مخالفة."""
import sys, pathlib, json, re

root = pathlib.Path(sys.argv[1] if len(sys.argv) > 1 else ".")
brand = root / "brand"
REQUIRED = [
    "master-logo/logo-master.svg", "master-logo/logo-master.pdf", "master-logo/logo-master.png",
    "logo-variants/logo-horizontal.svg", "logo-variants/logo-vertical.svg", "logo-variants/logo-symbol.svg",
    "logo-variants/logo-white.svg", "logo-variants/logo-black.svg",
    "colors/color-palette.json", "colors/color-specifications.pdf",
    "BRAND_GUIDELINES.md", "LOGO_GEOMETRY.md", "DESIGN_SYSTEM.md", "DIGITAL_APPLICATIONS.md",
    "PRINT_SPECIFICATIONS.md", "BRAND_ASSET_REGISTER.md", "BRAND_CHANGE_CONTROL.md",
]
missing = [f for f in REQUIRED if not (brand / f).is_file() or (brand / f).stat().st_size == 0]
print("— ملفات الهوية —")
for f in REQUIRED:
    print(("✗ ناقص  " if f in missing else "✓ موجود ") + f)
print(f"{len(REQUIRED) - len(missing)}/{len(REQUIRED)} موجود\n")

tokens_file = root / "packages/design-tokens/tokens.json"
allowed = set(h.upper() for h in re.findall(r"#[0-9A-Fa-f]{6}", tokens_file.read_text(encoding="utf-8"))) if tokens_file.exists() else set()
EXT = {".ts", ".tsx", ".js", ".jsx", ".css", ".scss", ".dart", ".html", ".vue"}
SKIP = ("packages/design-tokens/", "node_modules/", "/build/", "/dist/", "/.dart_tool/")
violations = []
for base in ("apps", "packages"):
    for p in (root / base).rglob("*") if (root / base).exists() else []:
        rel = p.relative_to(root).as_posix()
        if not p.is_file() or p.suffix not in EXT or any(s in rel + "/" for s in SKIP):
            continue
        for n, line in enumerate(p.read_text(encoding="utf-8", errors="ignore").splitlines(), 1):
            for h in re.findall(r"#[0-9A-Fa-f]{6}\b", line):
                if h.upper() not in allowed:
                    violations.append(f"{rel}:{n}: {h}")
print("— الألوان المخالفة —")
print("\n".join(violations) if violations else f"لا مخالفات ({len(allowed)} لوناً معتمداً)")
sys.exit(1 if missing or violations else 0)
