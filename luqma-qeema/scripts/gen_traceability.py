"""يولّد MASTER_REQUIREMENTS.md ومصفوفة التتبع CSV من المصدر الوحيد docs/_source/requirements.psv"""
import csv, sys, pathlib, collections

root = pathlib.Path(sys.argv[1])
src = root / "docs/_source/requirements.psv"

PATHS = {
    "gov": "docs/", "prj": "docs/MASTER_REQUIREMENTS.md", "brand": "design/brand/",
    "ux": "packages/ui/", "ds": "packages/design-tokens/", "arch": "infra/ + apps/",
    "settings": "apps/api/src/modules/settings/", "db": "apps/api/prisma/",
    "dash": "apps/admin/src/app/dashboard/", "products": "apps/api/src/modules/catalog/",
    "pricing": "apps/api/src/modules/pricing/", "inventory": "apps/api/src/modules/inventory/",
    "purchasing": "apps/api/src/modules/purchasing/", "pos": "apps/pos/",
    "app": "apps/mobile/", "crm": "apps/api/src/modules/customers/",
    "loyalty": "apps/api/src/modules/loyalty/", "orders": "apps/api/src/modules/orders/",
    "delivery": "apps/api/src/modules/delivery/", "accounting": "apps/api/src/modules/accounting/",
    "integration": "apps/api/src/modules/integrations/", "security": "apps/api/src/modules/auth/",
    "reports": "apps/api/src/modules/reports/", "compliance": "docs/COMPLIANCE_REGISTER.md",
    "qa": "tests/", "docs": "docs/", "handover": "docs/DEPLOYMENT_GUIDE.md",
}
PRI = {"P0": "شرط للتشغيل التجريبي", "P1": "شرط للإطلاق التجاري", "P2": "أساس معماري للتوسع"}

sections, rows, cur = [], [], None
for line in src.read_text(encoding="utf-8").splitlines():
    if line.startswith("## "):
        cur = line[3:].strip(); sections.append(cur); continue
    if not line.strip() or line.startswith("#"):
        continue
    f = [x.strip() for x in line.split("|")]
    rid, mod, desc, pri, phase = f[:5]
    status = f[5] if len(f) > 5 and f[5] else "موثّق – لم يبدأ التنفيذ"
    path = f[6] if len(f) > 6 and f[6] else PATHS[mod]
    rows.append(dict(id=rid, section=cur, module=mod, desc=desc, pri=pri, phase=int(phase),
                     path=path, test=f"T-{rid}", status=status, accept="معلّق"))

ids = [r["id"] for r in rows]
dups = [i for i, c in collections.Counter(ids).items() if c > 1]
assert not dups, f"معرفات مكررة: {dups}"

with open(root / "docs/TRACEABILITY_MATRIX.csv", "w", encoding="utf-8-sig", newline="") as f:
    w = csv.writer(f)
    w.writerow(["رقم المتطلب", "وصف المتطلب", "الوحدة", "الأولوية", "المرحلة", "الحالة",
                "ملف التنفيذ", "الاختبار", "نتيجة القبول"])
    for r in rows:
        w.writerow([r["id"], r["desc"], r["section"], r["pri"], r["phase"], r["status"],
                    r["path"], r["test"], r["accept"]])

by_phase = collections.Counter(r["phase"] for r in rows)
by_pri = collections.Counter(r["pri"] for r in rows)
out = ["# MASTER_REQUIREMENTS — سجل المتطلبات الرئيسي لمنظومة «لقمة وقيمة»", "",
       "> **مولَّد آلياً** من `docs/_source/requirements.psv` عبر `scripts/gen_traceability.py`. "
       "لا يُعدَّل هذا الملف يدوياً؛ يُعدَّل المصدر ثم يُعاد التوليد.", "",
       "**الإصدار:** 0.2 (المرحلة 1 – مسودة معدّلة بعد المراجعة) · **التاريخ:** 2026-11-19", "",
       "## القواعد", "",
       "- كل متطلب له رقم مرجعي ثابت لا يُعاد استخدامه، ومقابله اختبار `T-<الرقم>`.",
       "- **لا يُحذف أي متطلب.** الأولوية تحدد ترتيب التنفيذ فقط، لا الإسقاط.",
       "- الأولويات: " + " · ".join(f"**{k}** {v}" for k, v in PRI.items()) + ".",
       "- لا تتغير «الحالة» إلى «منفّذ» إلا بوجود ملف تنفيذ فعلي، ولا «نتيجة القبول» إلى «مقبول» إلا بدليل اختبار موثق في TEST_PLAN.",
       "- الحالات: «موثّق – لم يبدأ التنفيذ» · «منفّذ – بانتظار القبول» · «قاعدة سارية – تُطبَّق في كل مرحلة» (تُعد مستوفاة لبوابة أي مرحلة ما لم تُسجَّل مخالفة لها) · «منفّذ» · «مقبول».",
       "- مسارات «ملف التنفيذ» حالياً **مخططة** وفق المعمارية المقترحة، وتُحدَّث عند التنفيذ.", "",
       "## الإحصاء", "",
       f"- إجمالي المتطلبات: **{len(rows)}**",
       "- حسب الأولوية: " + " · ".join(f"{k}: {by_pri[k]}" for k in sorted(by_pri)),
       "- حسب المرحلة: " + " · ".join(f"م{k}: {by_phase[k]}" for k in sorted(by_phase)), "",
       "## مصفوفة التتبع", "",
       "الأعمدة: رقم المتطلب | الوصف | الوحدة (عنوان القسم) | الأولوية | المرحلة | الحالة | ملف التنفيذ | الاختبار | القبول. "
       "النسخة القابلة للفرز في Excel: `TRACEABILITY_MATRIX.csv`.", ""]
for s in sections:
    out += [f"### {s}", "", "| الرقم | المتطلب | أولوية | مرحلة | الحالة | ملف التنفيذ | الاختبار | القبول |",
            "|---|---|---|---|---|---|---|---|"]
    for r in (r for r in rows if r["section"] == s):
        out.append(f"| {r['id']} | {r['desc']} | {r['pri']} | {r['phase']} | {r['status']} | `{r['path']}` | {r['test']} | {r['accept']} |")
    out.append("")
(root / "docs/MASTER_REQUIREMENTS.md").write_text("\n".join(out), encoding="utf-8")
print(len(rows), dict(by_pri), dict(sorted(by_phase.items())))
