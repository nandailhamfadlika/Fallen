import wave
import math
import struct
import random

sample_rate = 44100
duration_ms = 44
num_samples = int(sample_rate * (duration_ms / 1000.0))

samples = []
random.seed(101)

# Generate authentic mechanical typewriter keystroke:
# Part 1: High crisp mechanical key latch / snap (metal contact)
# Part 2: Solid typebar strike impact (platen cylinder thud)
# Part 3: Tiny metallic spring resonance decay

for i in range(num_samples):
    t = float(i) / sample_rate
    
    # --- 1. Strike transient (First 0-7 ms): sharp click/snap ---
    snap = 0.0
    if t < 0.007:
        snap_env = math.exp(-t * 850.0)
        # Crisp multi-frequency snap (2800 Hz + 4200 Hz + high noise)
        snap_tone = math.sin(2.0 * math.pi * 3200.0 * t) * 0.4 + math.sin(2.0 * math.pi * 4600.0 * t) * 0.35
        snap_noise = (random.random() * 2.0 - 1.0) * 0.75
        snap = (snap_tone + snap_noise) * snap_env

    # --- 2. Mechanical hammer body & platen impact (0 to 35 ms) ---
    body = 0.0
    if t < 0.035:
        # Fast 1.2ms attack, smooth exponential decay
        if t < 0.0012:
            body_env = t / 0.0012
        else:
            body_env = math.exp(-(t - 0.0012) * 110.0)
        
        # Heavy pitch bend down from 680 Hz to 240 Hz (physical hammer impact)
        body_freq = 680.0 * math.exp(-t * 55.0) + 240.0
        phase = 2.0 * math.pi * body_freq * t
        
        # Resonant mechanical harmonics
        body_tone = (
            math.sin(phase) * 0.65 +
            math.sin(phase * 2.1) * 0.32 +
            math.sin(phase * 3.4) * 0.18 +
            math.sin(phase * 4.8) * 0.08
        )
        body = body_tone * body_env

    # --- 3. Subtle metallic spring & carriage resonance (0 to 44 ms) ---
    spring_env = math.exp(-t * 70.0)
    spring = (
        math.sin(2.0 * math.pi * 1850.0 * t) * 0.15 +
        math.sin(2.0 * math.pi * 2350.0 * t) * 0.12
    ) * spring_env

    # Combined waveform
    total = (snap * 0.68) + (body * 0.55) + (spring * 0.25)
    
    # Soft limiter / clamp
    total = math.tanh(total * 1.35)
    sample_val = int(total * 22000.0) # Crisp, punchy ~ -3.5 dB
    samples.append(sample_val)

wav_path = "assets/musics/sfx/sfx_text_blip.wav"
with wave.open(wav_path, "wb") as wf:
    wf.setnchannels(1)
    wf.setsampwidth(2)
    wf.setframerate(sample_rate)
    data = struct.pack("<" + "h" * len(samples), *samples)
    wf.writeframes(data)

print(f"Generated mechanical typewriter SFX: {wav_path} ({len(samples)} samples, {duration_ms}ms)")
