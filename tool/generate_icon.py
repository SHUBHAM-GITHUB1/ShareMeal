"""
Generates assets/icon/app_icon.png  (1024x1024 full icon)
Generates assets/icon/app_icon_fg.png (foreground only, transparent bg)

Run from project root:
    python tool/generate_icon.py

Requires: pip install Pillow
"""

import math
import os
from PIL import Image, ImageDraw

SIZE = 1024
OUT_DIR = os.path.join(os.path.dirname(__file__), '..', 'assets', 'icon')
os.makedirs(OUT_DIR, exist_ok=True)


def lerp_color(c1, c2, t):
    return tuple(int(c1[i] + (c2[i] - c1[i]) * t) for i in range(3))


def draw_icon(with_background: bool) -> Image.Image:
    img = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    cx, cy = SIZE // 2, SIZE // 2
    r = SIZE // 2

    if with_background:
        # Amber gradient circle — simulate with concentric rings
        amber_lt = (253, 230, 138)   # #FDE68A
        amber    = (245, 158, 11)    # #F59E0B
        amber_dk = (180, 83,  9)     # #B45309
        for i in range(r, 0, -1):
            t = 1.0 - (i / r)
            if t < 0.5:
                color = lerp_color(amber_lt, amber, t * 2)
            else:
                color = lerp_color(amber, amber_dk, (t - 0.5) * 2)
            draw.ellipse(
                [cx - i, cy - i, cx + i, cy + i],
                fill=(*color, 255)
            )

    # ── Heart ──────────────────────────────────────────────────────────
    heart_color = (245, 245, 245, 245) if with_background else (245, 158, 11, 255)
    heart_size  = SIZE * 0.52
    _draw_heart(draw, cx, cy + SIZE * 0.03, heart_size, heart_color)

    # ── Handshake ──────────────────────────────────────────────────────
    shake_color = (146, 64, 14, 255)   # #92400E
    _draw_handshake(draw, cx, cy + SIZE * 0.04, SIZE * 0.26, shake_color)

    return img


def _draw_heart(draw, cx, cy, size, color):
    """Draw a filled heart using bezier approximation via polygon."""
    points = []
    steps  = 200
    for i in range(steps):
        t = 2 * math.pi * i / steps
        # Parametric heart
        x = 16 * (math.sin(t) ** 3)
        y = -(13 * math.cos(t) - 5 * math.cos(2*t) - 2 * math.cos(3*t) - math.cos(4*t))
        scale = size / 34
        points.append((cx + x * scale, cy + y * scale))
    draw.polygon(points, fill=color)


def _draw_handshake(draw, cx, cy, size, color):
    """Draw a simplified handshake (two overlapping rounded rectangles + clasp)."""
    s = size
    # Left arm
    draw.rounded_rectangle(
        [cx - s*0.58, cy - s*0.12, cx + s*0.02, cy + s*0.28],
        radius=s*0.08, fill=color
    )
    # Right arm
    draw.rounded_rectangle(
        [cx - s*0.02, cy - s*0.12, cx + s*0.58, cy + s*0.28],
        radius=s*0.08, fill=color
    )
    # Clasp highlight (slightly lighter)
    clasp_color = (180, 90, 20, 255)
    draw.rounded_rectangle(
        [cx - s*0.14, cy - s*0.22, cx + s*0.14, cy + s*0.32],
        radius=s*0.06, fill=clasp_color
    )


# ── Generate full icon ────────────────────────────────────────────────────────
full = draw_icon(with_background=True)
full.save(os.path.join(OUT_DIR, 'app_icon.png'))
print(f'✅ Saved app_icon.png ({SIZE}x{SIZE})')

# ── Generate foreground only ──────────────────────────────────────────────────
fg = draw_icon(with_background=False)
fg.save(os.path.join(OUT_DIR, 'app_icon_fg.png'))
print(f'✅ Saved app_icon_fg.png ({SIZE}x{SIZE})')
print('\nNow run:  flutter pub get && dart run flutter_launcher_icons')
