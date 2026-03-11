# Technical Documentation

Complete reference for recreating or extending these experiments.

## Environment Setup

```bash
python3 -m venv venv
source venv/bin/activate
pip install pillow
```

## Core Pattern: Frame-by-Frame Generation

Every experiment follows this structure:

```python
from PIL import Image, ImageDraw, ImageFont
import random
import math

W, H = 600, 600  # Canvas size
frames = []
fps = 20
duration = 60  # seconds
total_frames = fps * duration

for frame_num in range(total_frames):
    img = Image.new('RGB', (W, H), (5, 5, 15))  # Dark background
    draw = ImageDraw.Draw(img)

    # Your logic here
    # - Update particle positions
    # - Calculate behaviors
    # - Draw elements

    frames.append(img)

# Save as GIF
frames[0].save(
    'output.gif',
    save_all=True,
    append_images=frames[1:],
    duration=int(1000/fps),  # milliseconds per frame
    loop=0
)
```

## Particle System Template

```python
# Initialize particles
particles = []
for _ in range(150):
    particles.append({
        'x': random.uniform(0, W),
        'y': random.uniform(0, H),
        'vx': random.uniform(-2, 2),  # velocity x
        'vy': random.uniform(-2, 2),  # velocity y
        'brightness': random.uniform(0.3, 1.0)
    })

# Update loop (per frame)
for p in particles:
    # Add forces
    p['vx'] += random.uniform(-0.1, 0.1)  # noise
    p['vy'] += random.uniform(-0.1, 0.1)

    # Apply damping
    p['vx'] *= 0.95
    p['vy'] *= 0.95

    # Move
    p['x'] += p['vx']
    p['y'] += p['vy']

    # Wrap edges
    if p['x'] < 0: p['x'] = W
    if p['x'] > W: p['x'] = 0
    if p['y'] < 0: p['y'] = H
    if p['y'] > H: p['y'] = 0

    # Draw
    size = 2
    brightness = int(p['brightness'] * 200)
    draw.ellipse([p['x']-size, p['y']-size, p['x']+size, p['y']+size],
                fill=(brightness, brightness, brightness+50))
```

## Attraction/Repulsion

```python
# Between two particles
dx = p2['x'] - p1['x']
dy = p2['y'] - p1['y']
dist = math.sqrt(dx*dx + dy*dy)

if dist < threshold and dist > 0:
    force = strength / dist  # Inverse relationship
    p1['vx'] += dx * force
    p1['vy'] += dy * force
```

## Coherence/Organization

```python
# Particles organize toward a target
target_x, target_y = W/2, H/2
coherence = 0.5  # 0=chaos, 1=organized

for p in particles:
    if coherence > 0.3:
        # Pull toward target
        dx = target_x - p['x']
        dy = target_y - p['y']
        p['vx'] += dx * 0.002 * coherence
        p['vy'] += dy * 0.002 * coherence
    else:
        # Random drift
        p['vx'] += random.uniform(-0.3, 0.3)
        p['vy'] += random.uniform(-0.3, 0.3)
```

## Text Fading

```python
# Fade in/hold/fade out cycle
cycle_length = 120  # frames
cycle_pos = frame_num % cycle_length

if cycle_pos < 20:
    alpha = cycle_pos / 20  # Fade in
elif cycle_pos < 100:
    alpha = 1.0  # Hold
else:
    alpha = 1.0 - (cycle_pos - 100) / 20  # Fade out

alpha = max(0, min(1, alpha))

# Apply to color
color_val = int(200 * alpha)
draw.text((x, y), text, fill=(color_val, color_val, color_val+50))
```

## Easing Functions

```python
def ease_in_out(t):
    """Smooth acceleration and deceleration"""
    return t * t * (3 - 2 * t)

def ease_in(t):
    """Accelerate from zero"""
    return t * t

def ease_out(t):
    """Decelerate to zero"""
    return 1 - (1 - t) * (1 - t)
```

## Color Helpers

```python
def fade_color(color, alpha):
    """Apply alpha to RGB tuple"""
    return tuple(int(c * alpha) for c in color)

# Usage
RED = (227, 26, 34)
faded_red = fade_color(RED, 0.5)  # 50% opacity
```

## Font Loading

```python
try:
    font_large = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 60)
    font_med = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 40)
    font_small = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 20)
except:
    font_large = ImageFont.load_default()
    font_med = ImageFont.load_default()
    font_small = ImageFont.load_default()
```

## Text Centering

```python
text = "Hello World"
bbox = draw.textbbox((0, 0), text, font=font)
text_width = bbox[2] - bbox[0]
text_height = bbox[3] - bbox[1]

x = W/2 - text_width/2
y = H/2 - text_height/2

draw.text((x, y), text, fill=(255, 255, 255), font=font)
```

## GIF to MP4 Conversion

```bash
ffmpeg -i input.gif -movflags faststart -pix_fmt yuv420p output.mp4
```

## Specific Experiments

### Attention

**Concept:** Token activation map

**Key mechanic:** Each word has attention weight, activated randomly with probability proportional to weight

```python
attention_map = {
    "build": 1.0,
    "deploy": 1.0,
    "this": 0.2,
    "the": 0.2
}

if random.random() < token.attention * 0.2:
    token.activated = True
    token.activation_time = frame_num
```

### Emergence

**Concept:** Particles organizing/dissolving

**Key mechanic:** Coherence oscillates via sine wave, particles respond

```python
phase = math.sin(frame_num * 0.015) * 0.5 + 0.5
target_coherence = phase

p['coherence'] += (target_coherence - p['coherence']) * 0.05
```

### Forgetting

**Concept:** Context window visualization

**Key mechanic:** Memories fade based on position, hard boundary

```python
position = len(memories) - memories.index(m)

if position > max_memories:
    # Outside window
    m['brightness'] *= 0.92  # Rapid fade
else:
    # Inside window
    m['brightness'] *= 0.997  # Slow fade

# Remove faded
memories = [m for m in memories if m['brightness'] > 0.05]
```

### Trust

**Concept:** Two entities collaborating

**Key mechanic:** Trust grows when both approach goal, occasionally doubts

```python
dist_a = math.sqrt(dx_a**2 + dy_a**2)
dist_b = math.sqrt(dx_b**2 + dy_b**2)

if dist_a < 200 and dist_b < 200:
    entity_a['trust'] = min(1.0, entity_a['trust'] + 0.003)
    entity_b['trust'] = min(1.0, entity_b['trust'] + 0.003)

# Occasional doubt
if random.random() < 0.01:
    entity_a['trust'] = max(0.3, entity_a['trust'] - 0.2)
```

## Performance Tips

**Frame count vs file size:**
- 900 frames (45s @ 20fps) ≈ 1-5MB
- 1200 frames (60s @ 20fps) ≈ 2-6MB
- Depends heavily on complexity

**Optimization:**
- Lower FPS (15 instead of 20) reduces file size significantly
- Simpler backgrounds help (solid colors vs gradients)
- Fewer particles = smaller files
- Text overlays have minimal impact

**Progress tracking:**
```python
if frame_num % 100 == 0:
    print(f"  {frame_num}/{total_frames}")
```

## Common Patterns

**Pulsing effect:**
```python
pulse = math.sin(frame_num * 0.2) * amplitude + baseline
```

**Spiral motion:**
```python
angle = (progress + offset) * math.pi * 2
x = center_x + math.cos(angle) * radius
y = center_y + math.sin(angle) * radius
```

**Wobble:**
```python
wobble_x = math.sin(frame_num * 0.1) * 10
wobble_y = math.cos(frame_num * 0.15) * 10
x = base_x + wobble_x
y = base_y + wobble_y
```

**Float up:**
```python
y_offset = (1 - fade) * 50  # Starts at +50, moves to 0
final_y = base_y - y_offset
```

## Color Palette

```python
RED = (227, 26, 34)        # Action, truth, intensity
WHITE = (255, 255, 255)    # Clarity, emphasis
CYAN = (0, 200, 255)       # Questions, uncertainty
YELLOW = (255, 220, 0)     # Consciousness, phi
MAGENTA = (255, 0, 255)    # Hoffman, interfaces
BLUE = (100, 150, 255)     # Tegmark, mathematics
GREEN = (0, 255, 100)      # Tokens, mechanics

# Dark backgrounds
BG_DARK_BLUE = (5, 5, 15)
BG_DARK_GREEN = (5, 10, 5)
BG_BLACK = (10, 5, 15)
```

## Debugging

**Preview single frame:**
```python
img.save(f'frame_{frame_num}.png')
```

**Check timing:**
```python
import time
start = time.time()
# ... generation code ...
elapsed = time.time() - start
print(f"Generated {total_frames} frames in {elapsed:.1f}s")
print(f"Average: {total_frames/elapsed:.1f} fps")
```

**File size check:**
```python
import os
size = os.path.getsize('output.gif')
print(f"File size: {size/1024/1024:.1f}MB")
```

## Next Steps

To extend these experiments:

1. **Add audio:** Generate procedural audio to match visuals
2. **Interactive version:** Convert to p5.js for web interaction
3. **3D:** Use three.js or Processing for depth
4. **Longer form:** 2-5 minute explorations (file size challenge)
5. **Real data:** Use actual token probabilities, attention weights
6. **Biometric:** Incorporate heart rate, typing patterns
7. **Multi-agent:** Visualize team collaboration

## References

- PIL Documentation: https://pillow.readthedocs.io/
- Processing (for more complex visuals): https://processing.org/
- p5.js (web version): https://p5js.org/
- ffmpeg for conversion: https://ffmpeg.org/

---

The beauty is in the simplicity. Pixels + time + simple rules = emergent complexity.
