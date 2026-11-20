import sys, re, numpy as np, vtracer
sys.path.insert(0,'/tmp/claude-0/-home-user-Archive/e656dd00-4263-5273-b5c1-2a7bcbed0be2/scratchpad/vec')
from scipy import ndimage as ndi
from PIL import Image
S='/tmp/claude-0/-home-user-Archive/e656dd00-4263-5273-b5c1-2a7bcbed0be2/scratchpad/vec/'
NAMES=['emerald','orange','gold','gold_light','gold_dark','leaf','leaf_light','white','cream','bg']
PAL=np.array([(11,74,40),(244,122,20),(240,174,42),(246,210,126),(222,150,30),(44,128,28),(120,176,48),(255,254,248),(246,214,150),(252,248,236),(0,0,0)],np.uint8)
T=10; EM=0; LEAF=(5,6); SC=4; CROP=(128,-2,1448,928)
def px(ox,oy): return int((ox-CROP[0])*SC), int((oy-CROP[1])*SC)
def separate(idx, cut=816, d=32):
    x0,y0=px(cut-8,350); x1,y1=px(1440-d,705)
    win=idx[y0:y1,x0:x1]
    em=(win==EM); band=np.zeros_like(em); band[(px(0,425)[1]-y0):,:]=True
    lab,n=ndi.label(em&band); sel=np.zeros_like(em)
    for i,sl in enumerate(ndi.find_objects(lab),1):
        if sl[1].start>=(px(cut,0)[0]-x0)-2*SC: sel[sl]|=(lab[sl]==i)
    lf=np.isin(win,LEAF); labl,_=ndi.label(lf)
    for i,sl in enumerate(ndi.find_objects(labl),1): sel[sl]|=(labl[sl]==i)
    region=ndi.binary_fill_holes(sel)
    s=d*SC; new=win.copy(); new[region]=T
    ty,tx=np.nonzero(region); k=tx+s<win.shape[1]
    new[ty[k],tx[k]+s]=win[ty[k],tx[k]]
    out=idx.copy(); out[y0:y1,x0:x1]=new; return out
def trace(idx,out,speck=28):
    Image.fromarray(np.dstack([PAL[idx],np.where(idx==T,0,255).astype(np.uint8)]),'RGBA').save(S+out+'.png')
    vtracer.convert_image_to_svg_py(S+out+'.png', S+out+'.svg', colormode='color', hierarchical='cutout', mode='spline', filter_speckle=speck, color_precision=8, layer_difference=1, corner_threshold=60, length_threshold=4.0, max_iterations=10, splice_threshold=45, path_precision=2)
    t=open(S+out+'.svg').read(); t=re.sub(r'<path[^>]*fill="#000000"[^>]*/>\s*','',t); open(S+out+'.svg','w').write(t)
if __name__=='__main__':
    idx=np.load(S+'idx.npy').astype(np.uint8)
    if sys.argv[1]=='faithful': trace(idx,'faithful3')
    else: o=separate(idx); np.save(S+'idx_spaced.npy',o); trace(o,'spaced3')
    print('ok')
