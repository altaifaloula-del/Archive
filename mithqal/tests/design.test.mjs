/** v56.0 — البنود المتبقية من أمر التصميم: البحث العام، اختصارات لوحة المفاتيح، محدد المنشأة، لوحات الأدوار. */
import { test, before } from 'node:test';
import assert from 'node:assert/strict';
import { buildEngine } from './build-engine.mjs';
let E; before(async () => { E = await buildEngine(); });

const org = { suppliers: [{ id: 's1', name: 'مؤسسة الإمداد', code: 'S-01' }], employees: [{ id: 'e1', name: 'أحمد الحربي', baseSalary: 9000 }],
  items: [{ id: 'i1', name: 'زيت زيتون', unit: 'لتر' }], products: [{ id: 'p1', name: 'كبسة لحم', sellPrice: 45 }] };
const ops = { invoices: [{ id: 'pi1', invoiceNo: 'A-778', supplierName: 'مؤسسة الإمداد', date: '2026-03-01', amount: 1150 }],
  salesInvoices: [{ id: 'si1', no: 'INV-2026-00012', buyer: { name: 'شركة النور' }, date: '2026-03-02', total: 575 }],
  journalManual: [{ id: 'j1', title: 'إيجار مارس', date: '2026-03-31' }], cashVouchers: [{ id: 'v1', no: 'PV-000004', date: '2026-03-03', amount: 300, note: 'سداد' }],
  closings: [{ id: 'c1', closingNo: 'TR-20260310-b1', branchName: 'العليا', date: '2026-03-10', totalRevenue: 1150 }] };
const screens = [{ id: 'acct', label: 'المالية والمحاسبة' }, { id: 'people', label: 'شؤون الموظفين' }, { id: 'purchasing', label: 'المشتريات' }];
const ALL = ['acct', 'people', 'purchasing', 'sales', 'closing', 'partners', 'inv', 'treasury'];

test('البحث العام: تطبيع العربية والأرقام — الهمزات والتاء المربوطة والتشكيل والأرقام الهندية', () => {
  assert.equal(E.gsNorm('أَحْمَد'), 'احمد'); assert.equal(E.gsNorm('مؤسسة'), 'مؤسسه'); assert.equal(E.gsNorm('٧٧٨'), '778');
  assert.equal(E.gsearch(org, ops, ALL, screens, 'احمد')[0].label, 'أحمد الحربي', 'بلا همزة يجد بالهمزة');
  assert.equal(E.gsearch(org, ops, ALL, screens, '٧٧٨')[0].go.peek.inv, 'pi1', 'أرقام هندية');
});

test('البحث العام: كل نوع يفتح مستنده أو شاشته', () => {
  const g = (q) => E.gsearch(org, ops, ALL, screens, q)[0];
  assert.deepEqual(g('INV-2026-00012').go, { peek: { si: 'si1' }, tab: 'sales' });
  assert.deepEqual(g('إيجار').go, { peek: { e: 'man:j1' }, tab: 'acct' });
  assert.deepEqual(g('PV-000004').go, { peek: { cv: 'v1' }, tab: 'acct' });
  assert.equal(g('TR-20260310').go.tab, 'closing'); assert.equal(g('كبسة').kind, 'prod'); assert.equal(g('زيت').kind, 'item');
  assert.equal(g('المشتريات').kind, 'screen'); assert.equal(E.gsearch(org, ops, ALL, screens, 'ا').length, 0, 'حرف واحد لا يبحث');
});

test('البحث العام يحترم الصلاحيات: لا شاشة ولا سجل خارج تبويبات المستخدم (كاشير بلا محاسبة ولا موظفين)', () => {
  const R = (q) => E.gsearch(org, ops, ['closing', 'pos'], screens, q);
  assert.equal(R('أحمد').length, 0, 'لا موظفين'); assert.equal(R('A-778').length, 0, 'لا فواتير موردين'); assert.equal(R('إيجار').length, 0, 'لا قيود');
  assert.equal(R('المالية').length, 0, 'لا شاشة المحاسبة'); assert.equal(R('TR-2026').length, 1, 'إغلاقاته فقط');
  assert.ok(!JSON.stringify(E.gsearch(org, ops, ALL, screens, 'أحمد')).includes('9000'), 'النتيجة لا تكشف الراتب');
});

test('اختصارات لوحة المفاتيح: الأوامر، ولا تعمل أثناء الكتابة عدا Ctrl/⌘+K', () => {
  const ev = (x, tag = 'BODY') => ({ key: '', code: '', ctrlKey: false, metaKey: false, altKey: false, target: { tagName: tag }, ...x });
  assert.equal(E.kbAction(ev({ key: 'k', ctrlKey: true })), 'search'); assert.equal(E.kbAction(ev({ key: 'k', metaKey: true }, 'INPUT')), 'search', 'حتى داخل حقل');
  assert.equal(E.kbAction(ev({ key: '/' })), 'search'); assert.equal(E.kbAction(ev({ key: '/' }, 'INPUT')), '', 'الكتابة لا تُقاطع');
  assert.equal(E.kbAction(ev({ key: '?' })), 'help');
  for (const [code, a] of [['KeyH', 'home'], ['KeyB', 'back'], ['KeyM', 'side'], ['KeyD', 'mode'], ['KeyL', 'lang']]) assert.equal(E.kbAction(ev({ code, altKey: true })), a);
  assert.equal(E.kbAction(ev({ code: 'KeyH', altKey: true }, 'TEXTAREA')), ''); assert.equal(E.kbAction(ev({ key: 'p', ctrlKey: true })), '', 'لا يمس اختصارات المتصفح');
});

test('محدد المنشأة: قائمة الجهاز (الأحدث أولًا، بلا تكرار، حد 12، معرّفات صالحة) ورابط الانتقال ?t= فقط', () => {
  let L = E.tnRemember([], 'oasis', 'مطاعم الواحة'); L = E.tnRemember(L, 'sunbula', 'السنبلة'); L = E.tnRemember(L, 'oasis', 'الواحة <b>');
  assert.deepEqual(L.map(x => x.id), ['oasis', 'sunbula']); assert.equal(L[0].name, 'الواحة b');
  assert.deepEqual(E.tnRemember(L, '../evil', 'x'), L, 'معرّف غير صالح لا يُحفظ');
  for (let i = 0; i < 20; i++) L = E.tnRemember(L, 't' + i + 'x', 'n'); assert.equal(L.length, 12);
  assert.equal(E.tnHref({ pathname: '/mithqal/' }, 'oasis'), '/mithqal/?t=oasis');
  assert.equal(E.tnHref({ pathname: '/' }, 'https://evil.com'), '', 'لا روابط خارجية'); assert.equal(E.tnHref({ pathname: '/' }, 'a'), '', 'قصير جدًا');
});
