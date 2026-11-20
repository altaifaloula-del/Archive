"""فحص ملفات الهوية الإلزامية (BRAND_DIRECTIVE §11-12، المتطلب BRD-29).
الاستخدام: python3 scripts/check_brand.py <جذر المشروع>
يخرج برمز 1 إن نقص أي ملف إلزامي. فحص الألوان والخطوط المخالفة يُضاف بعد اعتماد color-palette.json."""
import sys, pathlib

REQUIRED = [
    "master-logo/logo-master.svg", "master-logo/logo-master.pdf", "master-logo/logo-master.png",
    "logo-variants/logo-horizontal.svg", "logo-variants/logo-vertical.svg", "logo-variants/logo-symbol.svg",
    "logo-variants/logo-white.svg", "logo-variants/logo-black.svg",
    "colors/color-palette.json", "colors/color-specifications.pdf",
    "BRAND_GUIDELINES.md", "LOGO_GEOMETRY.md", "DESIGN_SYSTEM.md", "DIGITAL_APPLICATIONS.md",
    "PRINT_SPECIFICATIONS.md", "BRAND_ASSET_REGISTER.md", "BRAND_CHANGE_CONTROL.md",
]
brand = pathlib.Path(sys.argv[1] if len(sys.argv) > 1 else ".") / "brand"
missing = [f for f in REQUIRED if not (brand / f).is_file() or (brand / f).stat().st_size == 0]
for f in REQUIRED:
    print(("✗ ناقص  " if f in missing else "✓ موجود ") + f)
print(f"\n{len(REQUIRED) - len(missing)}/{len(REQUIRED)} موجود")
sys.exit(1 if missing else 0)
