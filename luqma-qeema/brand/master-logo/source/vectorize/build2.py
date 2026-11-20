import sys, numpy as np, vtracer
sys.path.insert(0,'/tmp/claude-0/-home-user-Archive/e656dd00-4263-5273-b5c1-2a7bcbed0be2/scratchpad/vec')
import build
from PIL import Image, ImageFilter, ImageDraw
S=build.S; names=list(build.PAL); P=np.array([build.PAL[n] for n in names],dtype=np.float32)
pairs=[('emerald','bg'),('orange','bg'),('gold','bg'),('emerald','orange'),('emerald','white'),('orange','white'),('emerald','gold'),('emerald','cream'),('leaf','bg'),('gold','white'),('emerald','leaf')]
PI=[(names.index(a),names.index(b)) for a,b in pairs]
def classify(chunk):
    x=chunk.astype(np.float32)
    d=((x[:,:,None,:]-P[None,None])**2).sum(-1); best=d.min(-1); idx=d.argmin(-1)
    for i,j in PI:
        A,B=P[i],P[j]; v=B-A; t=np.clip(((x-A)*v).sum(-1)/(v*v).sum(),0,1)
        proj=A+t[...,None]*v; dm=((x-proj)**2).sum(-1)
        better=(dm<best*0.5)&(t>0.08)&(t<0.92)
        idx=np.where(better, np.where(t<0.5,i,j), idx); best=np.where(better,dm,best)
    return idx
def run(scale=4, blur=1.0, speck=10, out='m'):
    im=Image.open('luqma-qeema/brand/master-logo/logo-master.png').convert('RGB').crop((128,-2,1408,928))
    big=np.asarray(im.resize((im.width*scale,im.height*scale),Image.LANCZOS).filter(ImageFilter.GaussianBlur(blur)))
    idx=np.vstack([classify(big[r:r+256]) for r in range(0,big.shape[0],256)])
    bgi=names.index('bg'); m=Image.fromarray(((idx==bgi)*255).astype(np.uint8)); H,W=idx.shape
    for p in [(0,0),(W-1,0),(0,H-1),(W-1,H-1)]: ImageDraw.floodfill(m,p,128)
    outside=np.asarray(m)==128; idx[(idx==bgi)&~outside]=names.index('white')
    rgb=P[idx].astype(np.uint8); Image.fromarray(np.dstack([rgb,np.where(outside,0,255).astype(np.uint8)]),'RGBA').save(S+out+'.png')
    vtracer.convert_image_to_svg_py(S+out+'.png', S+out+'.svg', colormode='color', hierarchical='stacked', mode='spline', filter_speckle=speck, color_precision=8, layer_difference=1, corner_threshold=60, length_threshold=4.0, max_iterations=10, splice_threshold=45, path_precision=2)
    return S+out+'.svg'
if __name__=='__main__':
    o=run(); print(build.score(o))
