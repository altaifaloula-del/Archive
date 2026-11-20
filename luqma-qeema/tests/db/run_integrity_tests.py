"""اختبارات قيود السلامة في قاعدة البيانات (T-ACC-16، T-ACC-17، T-ACC-13، T-ACC-19، T-INV-03، T-INV-11، T-POS-13، T-DB-10).
الاستخدام: PGURI=postgresql://... python3 tests/db/run_integrity_tests.py
يتطلب قاعدة فارغة طُبّقت عليها الترحيلات 0001 و0002."""
import os, subprocess, sys, pathlib
URI = os.environ.get("PGURI", "postgresql://postgres@/luqma?host=/var/tmp&port=55432")
here = pathlib.Path(__file__).parent
def psql(sql):
    r = subprocess.run(["psql", URI, "-v", "ON_ERROR_STOP=1", "-q", "-c", sql], capture_output=True, text=True)
    return r.returncode == 0, (r.stderr or r.stdout).strip()
ok, err = subprocess.run(["psql", URI, "-v", "ON_ERROR_STOP=1", "-q", "-f", str(here / "seed.sql")], capture_output=True, text=True).returncode == 0, ""
P, C, R, V = "'00000000-0000-0000-0000-000000000006'", "'00000000-0000-0000-0000-000000000010'", "'00000000-0000-0000-0000-000000000011'", "'00000000-0000-0000-0000-000000000012'"
def entry(eid, num, src, kind="SALE", period=P):
    return f"""INSERT INTO journal_entries (id, number, "periodId", "entryDate", description, status, "sourceType", "sourceId", "entryKind")
               VALUES ('{eid}', '{num}', {period}, now(), 'test', 'DRAFT', 'ORDER', '{src}', '{kind}');"""
def line(eid, acc, d, c):
    return f"""INSERT INTO journal_lines (id, "entryId", "accountId", debit, credit) VALUES (gen_random_uuid(), '{eid}', {acc}, {d}, {c});"""
E1 = "10000000-0000-0000-0000-000000000001"; S1 = "20000000-0000-0000-0000-000000000001"
cases = [
  ("T-ACC-16 قيد متوازن يُرحَّل", True,
   "BEGIN;" + entry(E1, "JE-1", S1) + line(E1, C, 115, 0) + line(E1, R, 0, 100) + line(E1, V, 0, 15) + f"UPDATE journal_entries SET status='POSTED' WHERE id='{E1}'; COMMIT;"),
  ("T-ACC-16/AC-05 قيد غير متوازن يُرفض عند الترحيل", False,
   "BEGIN;" + entry("10000000-0000-0000-0000-000000000002", "JE-2", "20000000-0000-0000-0000-000000000002") + line("10000000-0000-0000-0000-000000000002", C, 100, 0) + line("10000000-0000-0000-0000-000000000002", R, 0, 90) + "UPDATE journal_entries SET status='POSTED' WHERE id='10000000-0000-0000-0000-000000000002'; COMMIT;"),
  ("T-ACC-16 سطر بمدين ودائن معاً يُرفض", False,
   "BEGIN;" + entry("10000000-0000-0000-0000-000000000003", "JE-3", "20000000-0000-0000-0000-000000000003") + line("10000000-0000-0000-0000-000000000003", C, 10, 10) + "COMMIT;"),
  ("T-ACC-17 تعديل قيد مرحّل يُرفض", False, f"UPDATE journal_entries SET description='x' WHERE id='{E1}';"),
  ("T-ACC-17 حذف قيد مرحّل يُرفض", False, f"DELETE FROM journal_entries WHERE id='{E1}';"),
  ("T-ACC-17 تعديل سطور قيد مرحّل يُرفض", False, f"UPDATE journal_lines SET debit=999 WHERE \"entryId\"='{E1}' AND debit>0;"),
  ("T-ACC-17 إضافة سطر لقيد مرحّل تُرفض", False, line(E1, C, 1, 0)),
  ("T-ACC-13 قيد في فترة مقفلة يُرفض", False, entry("10000000-0000-0000-0000-000000000004", "JE-4", "20000000-0000-0000-0000-000000000004", period="'00000000-0000-0000-0000-000000000007'")),
  ("T-ACC-19 قيد مكرر لنفس المصدر والنوع يُرفض", False, entry("10000000-0000-0000-0000-000000000005", "JE-5", S1)),
  ("T-INV-03 تعديل حركة مخزنية يُرفض", False,
   "BEGIN; INSERT INTO stock_movements (id,\"itemId\",\"warehouseId\",type,quantity,\"unitCost\",\"sourceType\",\"sourceId\") VALUES ('30000000-0000-0000-0000-000000000001','00000000-0000-0000-0000-000000000005','00000000-0000-0000-0000-000000000003','ADJUSTMENT',5,1,'COUNT',gen_random_uuid()); UPDATE stock_movements SET quantity=6 WHERE id='30000000-0000-0000-0000-000000000001'; COMMIT;"),
  ("T-INV-11/AC-01 حجز يتجاوز الرصيد يُرفض", False, "UPDATE stock_balances SET reserved = \"onHand\" + 1;"),
  ("T-INV-11 رصيد سالب يُرفض", False, "UPDATE stock_balances SET \"onHand\" = -1, reserved = 0;"),
  ("T-POS-13/AC-03 طلب بمفتاح عدم تكرار مكرر يُرفض", False,
   "BEGIN; INSERT INTO orders (id,number,\"branchId\",channel,type,\"itemsSubtotal\",\"vatTotal\",\"grandTotal\",\"idempotencyKey\",\"updatedAt\") VALUES (gen_random_uuid(),'O-1','00000000-0000-0000-0000-000000000002','POS','TAKEAWAY',100,15,115,'idem-1',now()); INSERT INTO orders (id,number,\"branchId\",channel,type,\"itemsSubtotal\",\"vatTotal\",\"grandTotal\",\"idempotencyKey\",\"updatedAt\") VALUES (gen_random_uuid(),'O-2','00000000-0000-0000-0000-000000000002','POS','TAKEAWAY',100,15,115,'idem-1',now()); COMMIT;"),
  ("T-DB-10 تعديل مبلغ فاتورة صادرة يُرفض", False,
   "BEGIN; INSERT INTO invoices (id,number,kind,\"branchId\",\"issuedAt\",subtotal,\"vatTotal\",total,uuid,icv,pih,\"invoiceHash\",\"qrPayload\") VALUES ('40000000-0000-0000-0000-000000000001','INV-1','SIMPLIFIED_TAX_INVOICE','00000000-0000-0000-0000-000000000002',now(),100,15,115,gen_random_uuid(),1,'0','h','q'); UPDATE invoices SET total=1 WHERE id='40000000-0000-0000-0000-000000000001'; COMMIT;"),
  ("T-DB-10 تحديث حالة «فاتورة» فقط مسموح", True,
   "BEGIN; INSERT INTO invoices (id,number,kind,\"branchId\",\"issuedAt\",subtotal,\"vatTotal\",total,uuid,icv,pih,\"invoiceHash\",\"qrPayload\") VALUES ('40000000-0000-0000-0000-000000000002','INV-2','SIMPLIFIED_TAX_INVOICE','00000000-0000-0000-0000-000000000002',now(),100,15,115,gen_random_uuid(),2,'h','h2','q'); UPDATE invoices SET \"zatcaStatus\"='REPORTED' WHERE id='40000000-0000-0000-0000-000000000002'; COMMIT;"),
  ("T-DB-10 حذف فاتورة يُرفض", False, "DELETE FROM invoices WHERE id='40000000-0000-0000-0000-000000000002';"),
]
passed = 0
EXPECT = {"غير متوازن": "LQ-ACC-16", "مدين ودائن": "jl_one_side", "تعديل قيد مرحّل": "LQ-ACC-17", "حذف قيد مرحّل": "LQ-ACC-17",
          "تعديل سطور": "LQ-ACC-17", "إضافة سطر": "LQ-ACC-17", "فترة مقفلة": "LQ-ACC-13", "مكرر لنفس المصدر": "journal_entries_sourceType_sourceId_entryKind_key",
          "حركة مخزنية": "LQ-APPEND-ONLY", "يتجاوز الرصيد": "sb_reserved_le_onhand", "رصيد سالب": "sb_non_negative",
          "عدم تكرار مكرر": "orders_idempotencyKey_key", "مبلغ فاتورة": "LQ-INVOICE", "حذف فاتورة": "LQ-INVOICE"}
for name, expect_ok, sql in cases:
    got_ok, msg = psql(sql)
    code = next((v for k, v in EXPECT.items() if k in name), None)
    good = got_ok == expect_ok and (expect_ok or code is None or code in msg)
    passed += good
    print(f"{'✓' if good else '✗'} {name}" + ("" if good else f"  ← المتوقع {'نجاح' if expect_ok else 'رفض'}، والنتيجة {'نجاح' if got_ok else 'رفض'}: {msg[:160]}"))
print(f"\n{passed}/{len(cases)} ناجح")
sys.exit(0 if passed == len(cases) else 1)
