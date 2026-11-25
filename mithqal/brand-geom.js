/**
 * v56.0 — هندسة رمز MITHQAL (المصدر الوحيد): يستعملها مكوّن الواجهة BrandSymbol ومولّد الملفات scripts/brand-build.mjs.
 * شبكة 100×100، محور رأسي x=50 — المواصفة: PROJECT_AUDIT/V56/design/LOGO_GEOMETRY_SPEC_V56.md
 *  • ساقان (الكحلي): كتلتان عرضهما w من القاعدة bot إلى top، بشطف علوي 45° يهبط نحو الداخل.
 *  • ذراعان (الذهبي): متوازيان مع الشطف بفراغ ثابت gap، سماكتهما الرأسية t، يلتقيان على المحور في مركز الرمز.
 */
export const MQ_GEOM = Object.freeze({ x0: 8, w: 18, top: 14, bot: 86, gap: 7, t: 24 });
export function mqSymbolShapes(g = MQ_GEOM) {
  const xi = g.x0 + g.w, xa = xi + g.gap, k1 = g.top - xa;
  const leg = [[g.x0, g.bot], [xi, g.bot], [xi, g.top + g.w], [g.x0, g.top]];
  const arm = [[xa, g.top], [50, 50 + k1], [50, 50 + k1 + g.t], [xa, g.top + g.t]];
  const mir = (p) => p.map(([x, y]) => [100 - x, y]).reverse();
  return { outer: [leg, mir(leg)], inner: [arm, mir(arm)] };
}
export const mqPoints = (p) => p.map(([x, y]) => x + ',' + y).join(' ');
