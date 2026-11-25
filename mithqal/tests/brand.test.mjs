/* v50.4 — حارس الهوية الرسمية MITHQAL ERP: لا ألوان الهوية القديمة في الشاشات والمطبوعات، والملفات الرسمية كما هي في الحزمة */
import { test } from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs'; import path from 'node:path'; import { fileURLToPath } from 'node:url';
const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const files = ['App.jsx', ...fs.readdirSync(path.join(root, 'mods'), { recursive: true }).filter(f => f.endsWith('.jsx')).map(f => 'mods/' + f)];
test('لا ألوان الهوية القديمة (البني/النحاسي/الإسبريسو) في الشاشات والمطبوعات', () => {
  const OLD = /#(C8A24A|8C6F2C|5a4a1e|4a3f22|14110F|241F1B|efe8d8|d9cba5|e6ddc8|e5dcc5|faf6ee|101D35|0B1F3A|C7A45B)\b/i;
  const bad = files.flatMap(f => fs.readFileSync(path.join(root, f), 'utf8').split('\n').map((l, i) => OLD.test(l) && !/THEME_META|mizan: \{ name/.test(l) ? f + ':' + (i + 1) : null).filter(Boolean));
  assert.deepEqual(bad, []);
});
test('ملف التوكنات والرمز مطابقان للحزمة الرسمية', () => {
  const css = fs.readFileSync(path.join(root, 'brand', 'mithqal-brand-tokens.css'), 'utf8');
  for (const [k, v] of [['navy', '#10294A'], ['gold', '#D9A83E'], ['deep-navy', '#091A30'], ['tech-blue', '#2671B9'], ['white', '#FFFFFF'], ['soft-gray', '#F3F5F8']]) assert.match(css, new RegExp('--mithqal-' + k + ':\\s*' + v));
  // v56.0 (أمر التصميم — قرار المالك: «النموذج الأول · Refine · Geometric · Flat»): الرمز القديم بالخطوط استُبدل بهندسة الكتل.
  // الحارس الآن يقفل الهندسة الجديدة: مضلعات الرمز في ملف الواجهة = المصدر الموحّد brand-geom.js، ولا نص حي ولا تدرجات في ملفات الشعار.
  const sym = fs.readFileSync(path.join(root, 'public', 'brand', 'mithqal-symbol.svg'), 'utf8');
  for (const p of ['8,86 26,86 26,32 8,14', '33,14 50,31 50,55 33,38']) assert.ok(sym.includes(p), 'مضلع الرمز ' + p);
  assert.match(fs.readFileSync(path.join(root, 'brand-geom.js'), 'utf8'), /MQ_GEOM = Object\.freeze\(\{ x0: 8, w: 18, top: 14, bot: 86, gap: 7, t: 24 \}\)/);
  assert.match(fs.readFileSync(path.join(root, 'App.jsx'), 'utf8'), /mqSymbolShapes\(\)/, 'مكوّن الواجهة من الهندسة الموحّدة');
  const svgs = fs.readdirSync(path.join(root, 'brand', 'logo'), { recursive: true }).filter(f => f.endsWith('.svg'));
  assert.ok(svgs.length >= 23, 'كل نسخ الشعار موجودة');
  for (const f of svgs) assert.doesNotMatch(fs.readFileSync(path.join(root, 'brand', 'logo', f), 'utf8'), /<text|Gradient|<filter|<image/, f + ' بلا نص حي ولا تدرج ولا مؤثر');
  assert.equal(fs.readFileSync(path.join(root, 'public', 'icon.svg'), 'utf8'), fs.readFileSync(path.join(root, 'public', 'brand', 'mithqal-app-icon.svg'), 'utf8'));
});
