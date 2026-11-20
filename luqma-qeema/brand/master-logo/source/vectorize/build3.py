import sys, numpy as np, vtracer
sys.path.insert(0,'/tmp/claude-0/-home-user-Archive/e656dd00-4263-5273-b5c1-2a7bcbed0be2/scratchpad/vec')
import build2
from PIL import Image, ImageFilter, ImageDraw
S=build2.S; names=build2.names; P=build2.P
SC=4; CROP=(128,-2,1448,928)   # in original coords; padded source avoids out-of-range
def classified(crop=CROP, blur=1.2):
    src=Image.open('luqma-qeema/brand/master-logo/logo-master.png').convert('RGB')
    pad=Image.new('RGB',(src.width+400,src.height+400),(252,248,236)); pad.paste(src,(200,200))
    im=pad.crop((crop[0]+200,crop[1]+200,crop[2]+200,crop[3]+200))
    big=np.asarray(im.resize((im.width*SC,im.height*SC),Image.LANCZOS).filter(ImageFilter.GaussianBlur(blur)))
    idx=np.vstack([build2.classify(big[r:r+256]) for r in range(0,big.shape[0],256)])
    bgi=names.index('bg'); m=Image.fromarray(((idx==bgi)*255).astype(np.uint8)).copy(); H,W=idx.shape
    for p in [(0,0),(W-1,0),(0,H-1),(W-1,H-1)]: ImageDraw.floodfill(m,p,128)
    outside=np.asarray(m)==128; idx[(idx==bgi)&~outside]=names.index('white')
    T=len(names); idx[outside]=T
    return idx
def separate(idx, cut=816, d=32, crop=CROP):
    T=len(names); H,W=idx.shape
    ys,xs=np.mgrid[0:H,0:W]; ox=xs/SC+crop[0]; oy=ys/SC+crop[1]
    orange=names.index('orange'); leafs=[names.index('leaf'),names.index('leaf_light')]
    band=(ox>=cut)&(oy>=436)&(oy<=700)&(idx!=T)&(idx!=orange)
    lam=(ox>=cut)&(oy>=410)&(oy<436)&(ox>=1180)&(idx==names.index('emerald'))
    leaf=(ox>=cut)&(oy>=360)&(oy<500)&np.isin(idx,leafs)
    mv=band|lam|leaf
    out=idx.copy(); out[mv]=T
    s=d*SC; ty,tx=np.nonzero(mv); keep=tx+s<W
    out[ty[keep],tx[keep]+s]=idx[ty[keep],tx[keep]]
    return out
def save_trace(idx, out, speck=28):
    T=len(names); P2=np.vstack([P,[[0,0,0]]]).astype(np.uint8)
    Image.fromarray(np.dstack([P2[idx], np.where(idx==T,0,255).astype(np.uint8)]),'RGBA').save(S+out+'.png')
    vtracer.convert_image_to_svg_py(S+out+'.png', S+out+'.svg', colormode='color', hierarchical='stacked', mode='spline', filter_speckle=speck, color_precision=8, layer_difference=1, corner_threshold=60, length_threshold=4.0, max_iterations=10, splice_threshold=45, path_precision=2)
    return S+out+'.svg'
if __name__=='__main__':
    idx=classified(); np.save(S+'idx.npy', idx)
    save_trace(idx,'faithful'); save_trace(separate(idx),'spaced'); print('ok')
