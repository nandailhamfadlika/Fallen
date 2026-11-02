import os
from PIL import Image

CANVAS_W = 560
CANVAS_H = 480
BASELINE_Y = 408
X_CENTER = 194

OUT_BASE = r'A:\Game\Fallen\assets\characters\butler'
EXTRACTED_DIR = r'A:\Game\Fallen\assets\characters\butler\extracted'

def extract_and_save(sheet_name, clusters, out_files, scale, y_bottoms=None):
    sheet_path = os.path.join(EXTRACTED_DIR, sheet_name)
    im = Image.open(sheet_path)
    print(f"Extracting {sheet_name} ({len(clusters)} frames)...")
    
    for i, box in enumerate(clusters):
        crop = im.crop(box)
        nw = int(crop.width * scale)
        nh = int(crop.height * scale)
        scaled = crop.resize((nw, nh), Image.Resampling.LANCZOS)
        
        canvas = Image.new('RGBA', (CANVAS_W, CANVAS_H), (0, 0, 0, 0))
        pos_x = X_CENTER - (nw // 2)
        target_y = y_bottoms[i] if y_bottoms else BASELINE_Y
        pos_y = target_y - nh
        
        canvas.paste(scaled, (pos_x, pos_y), scaled)
        out_path = os.path.join(OUT_BASE, out_files[i])
        os.makedirs(os.path.dirname(out_path), exist_ok=True)
        canvas.save(out_path)
        bbox = canvas.getbbox()
        w = bbox[2] - bbox[0]
        h = bbox[3] - bbox[1]
        print(f"  Saved {out_files[i]}: {w}x{h} at bbox {bbox}")

def main():
    # 1. RUN (4 frames, scale 0.50 matching Aron run and Butler idle head width 51px)
    extract_and_save(
        'butler_run_clean.png',
        [(10, 165, 453, 649), (497, 159, 903, 658), (933, 165, 1450, 644), (1475, 133, 1917, 610)],
        ['run/run_01.png', 'run/run_02.png', 'run/run_03.png', 'run/run_04.png'],
        scale=0.50,
        y_bottoms=[BASELINE_Y, BASELINE_Y, BASELINE_Y, BASELINE_Y]
    )
    
    # 2. JUMP (3 frames: rise, apex, fall)
    extract_and_save(
        'butler_jump_clean.png',
        [(162, 182, 855, 1411), (1027, 103, 1709, 1264), (1878, 150, 2510, 1410)],
        ['jump/jump_rise.png', 'jump/jump_apex.png', 'jump/jump_fall.png'],
        scale=0.26,
        y_bottoms=[BASELINE_Y, 385, 395]
    )
    
    # 3. WALL (2 frames: cling, slide)
    extract_and_save(
        'butler_wall_clean.png',
        [(188, 104, 1200, 1426), (1388, 188, 2554, 1414)],
        ['wall/wall_cling.png', 'wall/wall_slide.png'],
        scale=0.255,
        y_bottoms=[BASELINE_Y, BASELINE_Y]
    )
    
    # 4. HURT (2 frames: stagger, reeling)
    extract_and_save(
        'butler_hurt_clean.png',
        [(135, 104, 1328, 1430), (1478, 252, 2618, 1430)],
        ['hurt/hurt_stagger.png', 'hurt/hurt_reeling.png'],
        scale=0.255,
        y_bottoms=[BASELINE_Y, BASELINE_Y]
    )

if __name__ == '__main__':
    main()
