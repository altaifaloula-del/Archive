import numpy as np, vtracer, re, sys
from PIL import Image
S='/tmp/claude-0/-home-user-Archive/e656dd00-4263-5273-b5c1-2a7bcbed0be2/scratchpad/vec/'
sys.path.insert(0,S); import build5
KEYPAL=build5.PAL.copy(); KEYPAL[10]=(255,0,255)
# class -> final brand hex (approved palette + artwork-only tones)
FINAL=['#084828','#F07810','#F0B028','#F6D27E','#DE961E','#2C801C','#78B030','#FCF8EC','#F6D696','#FCF8EC',None]
def trace(idx, name):
    Image.fromarray(KEYPAL[idx],'RGB').save(S+name+'_key.png')
    vtracer.convert_image_to_svg_py(S+name+'_key.png', S+name+'_raw.svg', colormode='color', hierarchical='cutout', mode='spline', filter_speckle=28, color_precision=8, layer_difference=1, corner_threshold=60, length_threshold=4.0, max_iterations=10, splice_threshold=45, path_precision=2)
    t=open(S+name+'_raw.svg').read()
    P=KEYPAL.astype(int)
    def fix(m):
        tag=m.group(0); h=re.search(r'fill="#([0-9A-Fa-f]{6})"',tag).group(1)
        c=np.array([int(h[i:i+2],16) for i in (0,2,4)]); k=int(((P-c)**2).sum(1).argmin())
        if FINAL[k] is None: return ''
        return tag.replace('#'+h, FINAL[k])
    body=re.sub(r'<path[^>]*/>\s*', fix, t)
    W,H=idx.shape[1],idx.shape[0]
    body=re.sub(r'<svg[^>]*>', f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {W} {H}" width="{W//4}" height="{H//4}" role="img" aria-label="لقمة وقيمة — جودة أعلى بسعر أوفر"><title>لقمة وقيمة</title>', body, count=1)
    body=re.sub(r'<\?xml[^>]*>\s*','',body)
    open(S+name+'.svg','w').write(body)
    return S+name+'.svg', body.count('<path'), len(body)//1024
if __name__=='__main__':
    n=sys.argv[1]
    idx=np.load(S+('idx.npy' if n=='faithful' else 'idx_spaced.npy')).astype(np.uint8)
    print(trace(idx, 'final_'+n))
