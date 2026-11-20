"""يولّد dist/tokens.css وdist/tokens.dart من tokens.json (المصدر الوحيد). الاستخدام: python3 build.py"""
import json, pathlib, re
root = pathlib.Path(__file__).parent
t = json.loads((root / "tokens.json").read_text(encoding="utf-8"))
def flat(d, pre=""):
    for k, v in d.items():
        if k.startswith("$"): continue
        key = f"{pre}-{k}" if pre else k
        if isinstance(v, dict): yield from flat(v, key)
        elif isinstance(v, list):
            for i, x in enumerate(v, 1): yield f"{key}-{i}", x
        else: yield key, v
PX = ("space", "radius", "size", "font-size")
css = ["/* مولَّد آلياً من tokens.json — لا تعدّله يدوياً */", ":root {"]
for k, v in flat(t):
    val = f"{v}px" if isinstance(v, (int, float)) and k.startswith(PX) else v
    css.append(f"  --lq-{k}: {val};")
css.append("}")
(root / "dist/tokens.css").write_text("\n".join(css) + "\n", encoding="utf-8")
def camel(k): return re.sub(r"[-_](\w)", lambda m: m.group(1).upper(), "x" + k.replace(".", "_"))[1:] if k[0].isdigit() else re.sub(r"[-_](\w)", lambda m: m.group(1).upper(), k)
dart = ["// مولَّد آلياً من tokens.json — لا تعدّله يدوياً", "import 'package:flutter/painting.dart';", "", "class LqTokens {", "  LqTokens._();"]
for k, v in flat(t):
    name = camel(k)
    if isinstance(v, str) and re.fullmatch(r"#[0-9A-Fa-f]{6}", v):
        dart.append(f"  static const Color {name} = Color(0xFF{v[1:].upper()});")
    elif isinstance(v, (int, float)):
        dart.append(f"  static const double {name} = {float(v)};")
    else:
        dart.append(f"  static const String {name} = {json.dumps(v, ensure_ascii=False)};")
dart.append("}")
(root / "dist/tokens.dart").write_text("\n".join(dart) + "\n", encoding="utf-8")
print("ok", sum(1 for _ in flat(t)), "tokens")
