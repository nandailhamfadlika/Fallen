import os
import io
import zipfile
import numpy as np
from PIL import Image

CANVAS_W = 560
CANVAS_H = 480
BASELINE_Y = 408
X_CENTER = 280

ZIP_PATH = r"A:\Game\Fallen\assets\characters\aron\Aron.zip"
OUT_BASE = r"A:\Game\Fallen\assets\characters\aron"

def clean_alpha_border(img: Image.Image, min_alpha=15) -> Image.Image:
    """Trims stray semi-transparent edge artifacts and returns tight cropped RGBA image."""
    alpha = np.array(img.split()[-1])
    mask = alpha > min_alpha
    if not np.any(mask):
        return img
    coords = np.argwhere(mask)
    y0, x0 = coords.min(axis=0)
    y1, x1 = coords.max(axis=0) + 1
    return img.crop((x0, y0, x1, y1))

def place_on_canvas(crop_img: Image.Image, scale: float, x_center=X_CENTER, y_bottom=BASELINE_Y, center_y=None) -> Image.Image:
    nw = max(1, int(crop_img.width * scale))
    nh = max(1, int(crop_img.height * scale))
    scaled = crop_img.resize((nw, nh), Image.Resampling.LANCZOS)
    
    canvas = Image.new("RGBA", (CANVAS_W, CANVAS_H), (0, 0, 0, 0))
    pos_x = x_center - (nw // 2)
    if center_y is not None:
        pos_y = center_y - (nh // 2)
    else:
        pos_y = y_bottom - nh
    
    canvas.paste(scaled, (pos_x, pos_y), scaled)
    return canvas

def extract_and_save(z: zipfile.ZipFile, zip_filename: str, boxes: list, out_rel_paths: list, scale: float, y_bottoms=None, center_ys=None, x_centers=None):
    im = Image.open(io.BytesIO(z.read(zip_filename)))
    for i, box in enumerate(boxes):
        crop = im.crop(box)
        clean = clean_alpha_border(crop)
        
        yb = y_bottoms[i] if y_bottoms else BASELINE_Y
        cy = center_ys[i] if center_ys else None
        xc = x_centers[i] if x_centers else X_CENTER
        
        canvas = place_on_canvas(clean, scale, x_center=xc, y_bottom=yb, center_y=cy)
        out_path = os.path.join(OUT_BASE, out_rel_paths[i])
        os.makedirs(os.path.dirname(out_path), exist_ok=True)
        canvas.save(out_path)
        bbox = canvas.getbbox()
        print(f"Saved {out_rel_paths[i]}: bbox={bbox}, w={bbox[2]-bbox[0] if bbox else 0}, h={bbox[3]-bbox[1] if bbox else 0}")

def main():
    print("Opening Aron.zip...")
    with zipfile.ZipFile(ZIP_PATH) as z:
        # 1. IDLE (4 frames, 1 row)
        extract_and_save(
            z, "Aron idle.png",
            [(108, 81, 541, 956), (686, 116, 1136, 956), (1300, 70, 1725, 956), (1894, 80, 2328, 956)],
            ["idle/idle_01.png", "idle/idle_02.png", "idle/idle_03.png", "idle/idle_04.png"],
            scale=0.377,
            y_bottoms=[BASELINE_Y, BASELINE_Y, BASELINE_Y, BASELINE_Y]
        )

        # 2. RUN (6 frames, 2 rows of 3) - Resized to match idle proportions cleanly
        extract_and_save(
            z, "Aron run.png",
            [
                (153, 60, 637, 655), (987, 78, 1442, 655), (1804, 57, 2259, 640),
                (153, 710, 629, 1305), (978, 713, 1443, 1305), (1805, 703, 2257, 1287)
            ],
            [
                "run/run_01.png", "run/run_02.png", "run/run_03.png",
                "run/run_04.png", "run/run_05.png", "run/run_06.png"
            ],
            scale=0.395,
            y_bottoms=[BASELINE_Y, BASELINE_Y, BASELINE_Y - 6, BASELINE_Y, BASELINE_Y, BASELINE_Y - 6]
        )

        # 3. JUMP & FALL (6 frames: Takeoff, Rise, Apex, Fall Start, Fast Fall, Land Reach) - Rescaled to match idle
        extract_and_save(
            z, "Aron jump.png",
            [
                (310, 140, 660, 661), (1081, 48, 1423, 645), (1890, 41, 2140, 530),
                (240, 710, 600, 1304), (1107, 711, 1399, 1276), (1883, 767, 2194, 1319)
            ],
            [
                "jump/jump_01_takeoff.png", "jump/jump_02_rise.png", "jump/jump_03_apex.png",
                "jump/jump_04_fall_start.png", "jump/jump_05_fast_fall.png", "jump/jump_06_land_prep.png"
            ],
            scale=0.470,
            y_bottoms=[BASELINE_Y, BASELINE_Y, BASELINE_Y - 20, BASELINE_Y - 8, BASELINE_Y, BASELINE_Y]
        )

        # 4. WALL (4 frames: grab, slide, cling, crouch)
        extract_and_save(
            z, "Aron wall.png",
            [(114, 218, 612, 1126), (714, 312, 1196, 1166), (1289, 218, 1671, 1151), (1874, 298, 2241, 1011)],
            ["wall/wall_01_grab.png", "wall/wall_02_slide.png", "wall/wall_03_cling.png", "wall/wall_04_prep.png"],
            scale=0.32,
            center_ys=[240, 248, 240, 235],
            x_centers=[265, 265, 265, 265]
        )

        # 5. HURT (4 frames, 2 rows of 2) - Resized to match idle proportions cleanly
        extract_and_save(
            z, "Aron hurt.png",
            [
                (409, 37, 797, 546), (1618, 74, 2030, 541),
                (432, 645, 800, 1145), (1665, 650, 1987, 1149)
            ],
            ["hurt/hurt_01.png", "hurt/hurt_02.png", "hurt/hurt_03.png", "hurt/hurt_04.png"],
            scale=0.360,
            y_bottoms=[BASELINE_Y, BASELINE_Y, BASELINE_Y, BASELINE_Y]
        )

        # 6. BLOCK (4 frames: raise, hold, impact recoil, recover)
        extract_and_save(
            z, "Aron block.png",
            [(98, 233, 602, 1217), (658, 282, 1184, 1217), (1228, 263, 1770, 1217), (1780, 238, 2332, 1217)],
            ["block/block_01.png", "block/block_02.png", "block/block_03_impact.png", "block/block_04.png"],
            scale=0.335,
            y_bottoms=[BASELINE_Y, BASELINE_Y, BASELINE_Y, BASELINE_Y]
        )

        # 7. DASH (6 frames: crouch burst, slip forward, glide, brake, friction, recover) - Resized
        extract_and_save(
            z, "Aron dash.png",
            [
                (184, 128, 660, 627), (848, 143, 1527, 627), (1720, 110, 2310, 627),
                (169, 727, 581, 1306), (994, 756, 1491, 1303), (1864, 692, 2216, 1307)
            ],
            [
                "dash/dash_01.png", "dash/dash_02.png", "dash/dash_03.png",
                "dash/dash_04.png", "dash/dash_05.png", "dash/dash_06.png"
            ],
            scale=0.385,
            y_bottoms=[BASELINE_Y, BASELINE_Y, BASELINE_Y, BASELINE_Y, BASELINE_Y, BASELINE_Y]
        )

        # 8. GROUND COMBO: HIT 1 (3 frames: windup, jab, snapback)
        extract_and_save(
            z, "Aron hit 1.png",
            [(120, 178, 649, 1258), (863, 207, 1682, 1244), (1782, 179, 2309, 1258)],
            ["combo/hit1_01_windup.png", "combo/hit1_02_jab.png", "combo/hit1_03_recover.png"],
            scale=0.306,
            y_bottoms=[BASELINE_Y, BASELINE_Y, BASELINE_Y],
            x_centers=[260, 310, 260]
        )

        # 9. GROUND COMBO: HIT 2 (3 frames: windup, cross, recover)
        extract_and_save(
            z, "Aron hit 2.png",
            [(95, 160, 639, 968), (874, 117, 1639, 968), (1799, 115, 2286, 968)],
            ["combo/hit2_01_windup.png", "combo/hit2_02_cross.png", "combo/hit2_03_recover.png"],
            scale=0.33,
            y_bottoms=[BASELINE_Y, BASELINE_Y, BASELINE_Y],
            x_centers=[260, 315, 265]
        )

        # 10. GROUND COMBO: HIT 3 (3 frames: crouch dip, rising uppercut, apex finish) - Rescaled to match idle
        extract_and_save(
            z, "Aron hit 3.png",
            [(131, 478, 578, 982), (1066, 83, 1641, 934), (1944, 20, 2272, 795)],
            ["combo/hit3_01_crouch.png", "combo/hit3_02_rise.png", "combo/hit3_03_apex.png"],
            scale=0.490,
            y_bottoms=[BASELINE_Y, BASELINE_Y + 22, BASELINE_Y + 4],
            x_centers=[270, 290, 290]
        )

        # 11. MID-AIR COMBO: AIR HIT 1 (3 frames: windup, jab, snapback) - Rescaled to match idle
        extract_and_save(
            z, "Aron hit air 1.png",
            [(139, 126, 594, 892), (870, 166, 1555, 913), (1861, 134, 2249, 909)],
            ["combo_air/air1_01_windup.png", "combo_air/air1_02_jab.png", "combo_air/air1_03_recover.png"],
            scale=0.435,
            center_ys=[240, 240, 240],
            x_centers=[260, 305, 265]
        )

        # 12. MID-AIR COMBO: AIR HIT 2 (3 frames: windup, hook, recover) - Rescaled to match idle
        extract_and_save(
            z, "aron hit air 2.png",
            [(147, 135, 559, 886), (895, 151, 1580, 914), (1871, 135, 2253, 909)],
            ["combo_air/air2_01_windup.png", "combo_air/air2_02_hook.png", "combo_air/air2_03_recover.png"],
            scale=0.435,
            center_ys=[240, 240, 240],
            x_centers=[260, 305, 265]
        )

        # 13. MID-AIR COMBO: AIR HIT 3 (3 frames: windup overhead, downward slam, recovery) - Rescaled to match idle
        extract_and_save(
            z, "Aron hit air 3.png",
            [(229, 72, 603, 1076), (759, 153, 1572, 1206), (1739, 283, 2215, 1087)],
            ["combo_air/air3_01_windup.png", "combo_air/air3_02_slam.png", "combo_air/air3_03_recover.png"],
            scale=0.400,
            center_ys=[230, 245, 240],
            x_centers=[275, 305, 275]
        )

    print("All Aron sprites successfully extracted and normalized!")

if __name__ == "__main__":
    main()
