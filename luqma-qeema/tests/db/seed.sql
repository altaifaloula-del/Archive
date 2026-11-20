-- بيانات اختبار فقط (لا تُستخدم في الإنتاج — GOV-03)
INSERT INTO companies (id, "legalNameAr", "updatedAt") VALUES ('00000000-0000-0000-0000-000000000001','شركة اختبار', now());
INSERT INTO branches (id, "companyId", code, "nameAr", "updatedAt") VALUES ('00000000-0000-0000-0000-000000000002','00000000-0000-0000-0000-000000000001','B1','فرع اختبار', now());
INSERT INTO warehouses (id, "branchId", code, "nameAr") VALUES ('00000000-0000-0000-0000-000000000003','00000000-0000-0000-0000-000000000002','W1','مستودع');
INSERT INTO units (id, code, "nameAr") VALUES ('00000000-0000-0000-0000-000000000004','g','جرام');
INSERT INTO items (id, sku, type, "nameAr", "baseUnitId", "updatedAt") VALUES ('00000000-0000-0000-0000-000000000005','RAW-CHICKEN','RAW','دجاج','00000000-0000-0000-0000-000000000004', now());
INSERT INTO fiscal_periods (id, year, month, "startsAt", "endsAt") VALUES ('00000000-0000-0000-0000-000000000006',2026,11,'2026-11-01','2026-12-01');
INSERT INTO fiscal_periods (id, year, month, "startsAt", "endsAt", "closedAt") VALUES ('00000000-0000-0000-0000-000000000007',2026,10,'2026-10-01','2026-11-01', now());
INSERT INTO accounts (id, code, "nameAr", type) VALUES ('00000000-0000-0000-0000-000000000010','1101','الصندوق','ASSET'),('00000000-0000-0000-0000-000000000011','4101','إيراد المبيعات','REVENUE'),('00000000-0000-0000-0000-000000000012','2201','ضريبة مخرجات','LIABILITY');
INSERT INTO stock_balances ("itemId","warehouseId","onHand","reserved") VALUES ('00000000-0000-0000-0000-000000000005','00000000-0000-0000-0000-000000000003',1000,0);
