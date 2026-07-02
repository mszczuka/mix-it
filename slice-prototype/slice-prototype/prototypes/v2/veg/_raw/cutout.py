import sys, glob, os
import numpy as np
from PIL import Image, ImageFilter
from scipy import ndimage

# Gemini bakes a 2-shade neutral-gray checkerboard as "transparency". We auto-detect the two
# shades from the border and key them out globally (also clears enclosed holes). A neutrality
# guard protects colored food + white highlights. Subjects that are themselves neutral+dark
# (e.g. sushi nori == black checker) collide and must be regenerated on a chroma background.
MAXDIM = 512   # sprites render at ~160px; 512 keeps headroom for hi-DPR while staying small

def _largest_only(alpha):
    # every sprite here is one connected blob -> keep only the largest opaque component (kills all specks)
    lbl, n = ndimage.label(alpha > 0)          # 4-connectivity: diagonal speck-chains stay separate
    if n <= 1:
        return alpha
    areas = np.bincount(lbl.ravel()); areas[0] = 0
    return np.where(lbl == int(areas.argmax()), alpha, 0).astype(np.uint8)

def finalize(rgb, alpha, dst, tag=""):
    out = Image.fromarray(np.dstack([rgb.astype(np.uint8), alpha]), "RGBA")
    A = out.split()[3].filter(ImageFilter.GaussianBlur(1.2))
    A = A.point(lambda p: 0 if p < 128 else 255)     # crisp edge, kill 1px halo
    out.putalpha(A)
    bbox = out.getbbox()
    if bbox: out = out.crop(bbox)
    if max(out.size) > MAXDIM:                        # downscale big renders
        s = MAXDIM / max(out.size)
        out = out.resize((max(1,round(out.width*s)), max(1,round(out.height*s))), Image.LANCZOS)
    out.save(dst, "WEBP", quality=88, method=6)       # alpha-preserving, ~9x smaller than PNG
    kb = os.path.getsize(dst) // 1024
    print(f"  {os.path.basename(dst):22s}{tag} -> {out.size}  {kb}KB")

def cutout_magenta(src, dst, tol=150):
    a = np.asarray(Image.open(src).convert("RGB")).astype(np.int16)
    dist = np.abs(a - np.array([255,0,255]).reshape(1,1,3)).sum(2)   # L1 to pure magenta
    bg = dist < tol                                                  # separates magenta from purple/pink skin
    alpha = _largest_only(np.where(bg, 0, 255).astype(np.uint8))
    finalize(a, alpha, dst, " (magenta)")

def cutout(src, dst, neutral_max=30):
    # Border-connected neutral flood: the checkerboard is neutral gray at ANY brightness and
    # connects to the frame edge; the subject's colored rim blocks the flood, so interior
    # highlights/holes are preserved. Shade-agnostic -> robust across every checker variant.
    a = np.asarray(Image.open(src).convert("RGB")).astype(np.int16)
    h, w, _ = a.shape
    neutral = (a.max(2) - a.min(2)) < neutral_max
    lbl, n = ndimage.label(neutral, structure=np.ones((3,3)))
    border = set(np.unique(np.concatenate([lbl[0], lbl[-1], lbl[:,0], lbl[:,-1]]))) - {0}
    bg = np.isin(lbl, list(border))
    alpha = _largest_only(np.where(bg, 0, 255).astype(np.uint8))
    finalize(a, alpha, dst)

if __name__ == "__main__":
    base = os.path.dirname(os.path.abspath(__file__))
    outdir = os.path.dirname(base)
    only = sys.argv[1] if len(sys.argv) > 1 else None
    for src in sorted(glob.glob(os.path.join(base, "*_raw.jpg"))):
        name = os.path.basename(src).replace("_raw.jpg", "")
        if only and only not in name:
            continue
        cutout(src, os.path.join(outdir, name + ".webp"))
