import re, numpy as np, cairosvg, sys
S='/tmp/claude-0/-home-user-Archive/e656dd00-4263-5273-b5c1-2a7bcbed0be2/scratchpad/vec/'
T=10
def part(name, file):
    a=np.load(S+f'idx_{name}.npy'); ys,xs=np.nonzero(a!=T)
    body=open(S+file).read(); inner=re.search(r'<svg[^>]*>(.*)</svg>',body,re.S).group(1)
    inner=re.sub(r'<title>.*?</title>','',inner)
    return dict(inner=inner, x0=xs.min(), y0=ys.min(), w=xs.max()+1-xs.min(), h=ys.max()+1-ys.min())
P={'symbol':part('symbol','final_symbol.svg'),'word':part('wordmark','final_wordmark.svg'),
   'luqma':part('luqma','part_luqma.svg'),'qeema':part('qeema','part_qeema.svg'),'pill':part('pill','part_pill.svg')}
X=680
def place(p, cx=None, x=None, y=0, s=1.0):
    q=P[p]; w,h=q['w']*s,q['h']*s
    if cx is not None: x=cx-w/2
    return dict(g=f'<g transform="translate({x-q["x0"]*s:.1f},{y-q["y0"]*s:.1f}) scale({s})">{q["inner"]}</g>', x=x,y=y,w=w,h=h)
def svg(items, name, label):
    x0=min(i['x'] for i in items); y0=min(i['y'] for i in items); x1=max(i['x']+i['w'] for i in items); y1=max(i['y']+i['h'] for i in items)
    W,H=x1-x0,y1-y0
    out=f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="{x0:.0f} {y0:.0f} {W:.0f} {H:.0f}" width="{W/4:.0f}" height="{H/4:.0f}" role="img" aria-label="لقمة وقيمة — جودة أعلى بسعر أوفر"><title>لقمة وقيمة — {label}</title>'+''.join(i['g'] for i in items)+'</svg>'
    open(S+name+'.svg','w').write(out); return W,H
g=0.3*X
# V1 vertical compact: symbol / wordmark / pill
it=[]; y=0
a=place('symbol',cx=0,y=y); it.append(a); y+=a['h']+g
b=place('word',cx=0,y=y); it.append(b); y+=b['h']+g
c=place('pill',cx=0,y=y,s=0.9); it.append(c)
print('V1',svg(it,'lay_v1','عمودي'))
# V2 vertical tall: symbol / لقمة / وقيمة / pill (scaled to word width)
it=[]; y=0
a=place('symbol',cx=0,y=y,s=1.1); it.append(a); y+=a['h']+g
b=place('luqma',cx=0,y=y); it.append(b); y+=b['h']+0.18*X
c=place('qeema',cx=0,y=y); it.append(c); y+=c['h']+g
wmax=max(P['luqma']['w'],P['qeema']['w']); d=place('pill',cx=0,y=y,s=wmax*1.2/P['pill']['w']); it.append(d)
print('V2',svg(it,'lay_v2','عمودي بسطرين'))
# H1 horizontal: symbol right, wordmark left, vertically centred
sw=P['symbol']; ww=P['word']; s_sym=ww['h']*1.25/sw['h']
a=place('symbol',x=0,y=0,s=s_sym); hgt=a['h']
b=place('word',x=-(0.35*X)-ww['w'],y=(hgt-ww['h'])/2+0.05*X)
print('H1',svg([a,b],'lay_h1','أفقي'))
# H2 horizontal with tagline: symbol right; wordmark over pill on the left
blk_h=ww['h']+0.2*X+P['pill']['h']*(ww['w']/P['pill']['w'])
s_sym2=blk_h/sw['h']
a=place('symbol',x=0,y=0,s=s_sym2)
b=place('word',x=-(0.35*X)-ww['w'],y=0)
c=place('pill',x=-(0.35*X)-ww['w'],y=ww['h']+0.2*X,s=ww['w']/P['pill']['w'])
print('H2',svg([a,b,c],'lay_h2','أفقي مع الشعار التسويقي'))
