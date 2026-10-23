import os

def generate_tscn():
    # Gather textures
    p1_textures = [
        ("p1_idle_01", "res://assets/characters/the_first_fallen/phase1/idle/idle_01.png"),
        ("p1_idle_02", "res://assets/characters/the_first_fallen/phase1/idle/idle_02.png"),
        ("p1_idle_03", "res://assets/characters/the_first_fallen/phase1/idle/idle_03.png"),
        ("p1_idle_04", "res://assets/characters/the_first_fallen/phase1/idle/idle_04.png"),
        ("p1_run_01", "res://assets/characters/the_first_fallen/phase1/run/run_01.png"),
        ("p1_run_02", "res://assets/characters/the_first_fallen/phase1/run/run_02.png"),
        ("p1_run_03", "res://assets/characters/the_first_fallen/phase1/run/run_03.png"),
        ("p1_jump_rise", "res://assets/characters/the_first_fallen/phase1/jump/jump_rise.png"),
        ("p1_jump_apex", "res://assets/characters/the_first_fallen/phase1/jump/jump_apex.png"),
        ("p1_jump_fall", "res://assets/characters/the_first_fallen/phase1/jump/jump_fall.png"),
        ("p1_jump_land", "res://assets/characters/the_first_fallen/phase1/jump/jump_land.png"),
        ("p1_wall_slide", "res://assets/characters/the_first_fallen/phase1/wall/wall_slide.png"),
        ("p1_c1_wind", "res://assets/characters/the_first_fallen/phase1/combo/combo_01_windup.png"),
        ("p1_c1_strike", "res://assets/characters/the_first_fallen/phase1/combo/combo_01_strike.png"),
        ("p1_c1_recov", "res://assets/characters/the_first_fallen/phase1/combo/combo_01_recover.png"),
        ("p1_c2_wind", "res://assets/characters/the_first_fallen/phase1/combo/combo_02_windup.png"),
        ("p1_c2_strike", "res://assets/characters/the_first_fallen/phase1/combo/combo_02_strike.png"),
        ("p1_c2_recov", "res://assets/characters/the_first_fallen/phase1/combo/combo_02_recover.png"),
        ("p1_c3_wind", "res://assets/characters/the_first_fallen/phase1/combo/combo_03_windup.png"),
        ("p1_c3_strike", "res://assets/characters/the_first_fallen/phase1/combo/combo_03_strike.png"),
        ("p1_c3_recov", "res://assets/characters/the_first_fallen/phase1/combo/combo_03_recover.png"),
        ("p1_hurt_01", "res://assets/characters/the_first_fallen/phase1/hurt/hurt_01.png"),
        ("p1_hurt_02", "res://assets/characters/the_first_fallen/phase1/hurt/hurt_02.png"),
        ("p1_hurt_03", "res://assets/characters/the_first_fallen/phase1/hurt/hurt_03.png"),
    ]

    p2_textures = [
        ("p2_idle_01", "res://assets/characters/the_first_fallen/phase2/idle/idle_01.png"),
        ("p2_idle_02", "res://assets/characters/the_first_fallen/phase2/idle/idle_02.png"),
        ("p2_idle_03", "res://assets/characters/the_first_fallen/phase2/idle/idle_03.png"),
        ("p2_idle_04", "res://assets/characters/the_first_fallen/phase2/idle/idle_04.png"),
        ("p2_walk_01", "res://assets/characters/the_first_fallen/phase2/walk/walk_01.png"),
        ("p2_walk_02", "res://assets/characters/the_first_fallen/phase2/walk/walk_02.png"),
        ("p2_walk_03", "res://assets/characters/the_first_fallen/phase2/walk/walk_03.png"),
        ("p2_walk_04", "res://assets/characters/the_first_fallen/phase2/walk/walk_04.png"),
        ("p2_jump_rise", "res://assets/characters/the_first_fallen/phase2/jump/jump_rise.png"),
        ("p2_jump_apex", "res://assets/characters/the_first_fallen/phase2/jump/jump_apex.png"),
        ("p2_jump_fall", "res://assets/characters/the_first_fallen/phase2/jump/jump_fall.png"),
        ("p2_jump_land", "res://assets/characters/the_first_fallen/phase2/jump/jump_land.png"),
        ("p2_wall_slide", "res://assets/characters/the_first_fallen/phase2/wall/wall_slide.png"),
        ("p2_c1_wind", "res://assets/characters/the_first_fallen/phase2/combo/combo_01_windup.png"),
        ("p2_c1_strike", "res://assets/characters/the_first_fallen/phase2/combo/combo_01_strike.png"),
        ("p2_c1_recov", "res://assets/characters/the_first_fallen/phase2/combo/combo_01_recover.png"),
        ("p2_c2_wind", "res://assets/characters/the_first_fallen/phase2/combo/combo_02_windup.png"),
        ("p2_c2_strike", "res://assets/characters/the_first_fallen/phase2/combo/combo_02_strike.png"),
        ("p2_c2_recov", "res://assets/characters/the_first_fallen/phase2/combo/combo_02_recover.png"),
        ("p2_c3_wind", "res://assets/characters/the_first_fallen/phase2/combo/combo_03_windup.png"),
        ("p2_c3_strike", "res://assets/characters/the_first_fallen/phase2/combo/combo_03_strike.png"),
        ("p2_c3_recov", "res://assets/characters/the_first_fallen/phase2/combo/combo_03_recover.png"),
        ("p2_hurt_01", "res://assets/characters/the_first_fallen/phase2/hurt/hurt_01.png"),
        ("p2_hurt_02", "res://assets/characters/the_first_fallen/phase2/hurt/hurt_02.png"),
        ("p2_hurt_03", "res://assets/characters/the_first_fallen/phase2/hurt/hurt_03.png"),
    ]

    all_textures = p1_textures + p2_textures
    ext_resources = []
    ext_map = {}
    
    # 1 is script
    ext_resources.append('[ext_resource type="Script" path="res://src/characters/TheFirstFallen.gd" id="1_boss"]')
    ext_resources.append('[ext_resource type="Script" path="res://src/combat/Hurtbox.gd" id="2_hurtbox"]')
    ext_resources.append('[ext_resource type="Script" path="res://src/combat/Hitbox.gd" id="3_hitbox"]')

    res_idx = 4
    for key, path in all_textures:
        id_str = f"{res_idx}_{key}"
        ext_map[key] = id_str
        ext_resources.append(f'[ext_resource type="Texture2D" path="{path}" id="{id_str}"]')
        res_idx += 1

    sub_resources = []
    
    # Body shapes
    sub_resources.append('''[sub_resource type="CapsuleShape2D" id="CapsuleShape2D_body"]
radius = 26.0
height = 110.0''')

    sub_resources.append('''[sub_resource type="CapsuleShape2D" id="CapsuleShape2D_hurt"]
radius = 30.0
height = 116.0''')

    sub_resources.append('''[sub_resource type="RectangleShape2D" id="RectangleShape2D_hit"]
size = Vector2(110, 75)''')

    # Void Particles
    sub_resources.append('''[sub_resource type="Gradient" id="Gradient_void"]
offsets = PackedFloat32Array(0, 0.35, 0.75, 1)
colors = PackedColorArray(0.9, 0.15, 0.25, 0.9, 0.5, 0.05, 0.55, 0.8, 0.15, 0.02, 0.25, 0.6, 0.02, 0.01, 0.04, 0)''')

    sub_resources.append('''[sub_resource type="ParticleProcessMaterial" id="ParticleProcessMaterial_void"]
particle_flag_disable_z = true
emission_shape = 1
emission_sphere_radius = 28.0
direction = Vector3(0, -1, 0)
spread = 45.0
initial_velocity_min = 30.0
initial_velocity_max = 75.0
gravity = Vector3(0, -40, 0)
scale_min = 3.5
scale_max = 7.0
color = Color(0.85, 0.15, 0.35, 0.8)''')

    # Animations helper
    def make_anim(name, length, loop, keys, method_track=None):
        out = [f'[sub_resource type="Animation" id="Animation_{name}"]',
               f'resource_name = "{name}"',
               f'length = {length}',
               f'loop_mode = {1 if loop else 0}',
               f'step = 0.02',
               f'tracks/0/type = "value"',
               f'tracks/0/imported = false',
               f'tracks/0/enabled = true',
               f'tracks/0/path = NodePath("Sprite2D:texture")',
               f'tracks/0/interp = 1',
               f'tracks/0/loop_wrap = true']
        
        times_str = ", ".join([str(t[0]) for t in keys])
        trans_str = ", ".join(["1" for _ in keys])
        vals_str = ", ".join([f'ExtResource("{ext_map[t[1]]}")' for t in keys])
        
        out.append('tracks/0/keys = {')
        out.append(f'"times": PackedFloat32Array({times_str}),')
        out.append(f'"transitions": PackedFloat32Array({trans_str}),')
        out.append(f'"update": 1,')
        out.append(f'"values": [{vals_str}]')
        out.append('}')
        
        if method_track:
            out.append('tracks/1/type = "method"')
            out.append('tracks/1/imported = false')
            out.append('tracks/1/enabled = true')
            out.append('tracks/1/path = NodePath(".")')
            out.append('tracks/1/interp = 1')
            out.append('tracks/1/loop_wrap = true')
            mtimes = ", ".join([str(m[0]) for m in method_track])
            mtrans = ", ".join(["1" for _ in method_track])
            mvals = ", ".join(['{\n"args": [],\n"method": &"' + m[1] + '"\n}' for m in method_track])
            out.append('tracks/1/keys = {')
            out.append(f'"times": PackedFloat32Array({mtimes}),')
            out.append(f'"transitions": PackedFloat32Array({mtrans}),')
            out.append(f'"values": [{mvals}]')
            out.append('}')
            
        return "\n".join(out)

    # Standard combo method track
    def combo_methods(hit_time, open_time, disable_time, end_time):
        return [
            (hit_time, "enable_hitbox"),
            (open_time, "open_combo_window"),
            (disable_time, "disable_hitbox"),
            (end_time, "finish_combo_animation")
        ]

    # PHASE 1 Animations
    sub_resources.append(make_anim("p1_idle", 0.64, True, [
        (0.0, "p1_idle_01"), (0.16, "p1_idle_02"), (0.32, "p1_idle_03"), (0.48, "p1_idle_04")
    ]))
    sub_resources.append(make_anim("p1_run", 0.45, True, [
        (0.0, "p1_run_01"), (0.15, "p1_run_02"), (0.30, "p1_run_03")
    ]))
    sub_resources.append(make_anim("p1_jump", 0.40, False, [
        (0.0, "p1_jump_rise"), (0.15, "p1_jump_apex")
    ]))
    sub_resources.append(make_anim("p1_fall", 0.30, True, [
        (0.0, "p1_jump_fall")
    ]))
    sub_resources.append(make_anim("p1_wall_slide", 0.30, True, [
        (0.0, "p1_wall_slide")
    ]))
    sub_resources.append(make_anim("p1_hurt", 0.36, False, [
        (0.0, "p1_hurt_01"), (0.12, "p1_hurt_02"), (0.24, "p1_hurt_03")
    ]))
    sub_resources.append(make_anim("p1_combo_1", 0.32, False, [
        (0.0, "p1_c1_wind"), (0.08, "p1_c1_strike"), (0.22, "p1_c1_recov")
    ], combo_methods(0.08, 0.16, 0.22, 0.32)))
    sub_resources.append(make_anim("p1_combo_2", 0.36, False, [
        (0.0, "p1_c2_wind"), (0.10, "p1_c2_strike"), (0.24, "p1_c2_recov")
    ], combo_methods(0.10, 0.18, 0.24, 0.36)))
    sub_resources.append(make_anim("p1_combo_3", 0.50, False, [
        (0.0, "p1_c3_wind"), (0.14, "p1_c3_strike"), (0.34, "p1_c3_recov")
    ], combo_methods(0.14, 0.26, 0.34, 0.50)))

    # PHASE 2 Animations
    sub_resources.append(make_anim("p2_idle", 0.64, True, [
        (0.0, "p2_idle_01"), (0.16, "p2_idle_02"), (0.32, "p2_idle_03"), (0.48, "p2_idle_04")
    ]))
    sub_resources.append(make_anim("p2_walk", 0.52, True, [
        (0.0, "p2_walk_01"), (0.13, "p2_walk_02"), (0.26, "p2_walk_03"), (0.39, "p2_walk_04")
    ]))
    sub_resources.append(make_anim("p2_jump", 0.40, False, [
        (0.0, "p2_jump_rise"), (0.15, "p2_jump_apex")
    ]))
    sub_resources.append(make_anim("p2_fall", 0.30, True, [
        (0.0, "p2_jump_fall")
    ]))
    sub_resources.append(make_anim("p2_wall_slide", 0.30, True, [
        (0.0, "p2_wall_slide")
    ]))
    sub_resources.append(make_anim("p2_hurt", 0.36, False, [
        (0.0, "p2_hurt_01"), (0.12, "p2_hurt_02"), (0.24, "p2_hurt_03")
    ]))
    sub_resources.append(make_anim("p2_combo_1", 0.28, False, [
        (0.0, "p2_c1_wind"), (0.06, "p2_c1_strike"), (0.18, "p2_c1_recov")
    ], combo_methods(0.06, 0.12, 0.18, 0.28)))
    sub_resources.append(make_anim("p2_combo_2", 0.30, False, [
        (0.0, "p2_c2_wind"), (0.08, "p2_c2_strike"), (0.20, "p2_c2_recov")
    ], combo_methods(0.08, 0.14, 0.20, 0.30)))
    sub_resources.append(make_anim("p2_combo_3", 0.44, False, [
        (0.0, "p2_c3_wind"), (0.12, "p2_c3_strike"), (0.28, "p2_c3_recov")
    ], combo_methods(0.12, 0.22, 0.28, 0.44)))

    # AnimationLibrary
    anim_names = [
        "p1_idle", "p1_run", "p1_jump", "p1_fall", "p1_wall_slide", "p1_hurt", "p1_combo_1", "p1_combo_2", "p1_combo_3",
        "p2_idle", "p2_walk", "p2_jump", "p2_fall", "p2_wall_slide", "p2_hurt", "p2_combo_1", "p2_combo_2", "p2_combo_3"
    ]
    lib_lines = ['[sub_resource type="AnimationLibrary" id="AnimationLibrary_boss"]', '_data = {']
    for nm in anim_names:
        lib_lines.append(f'"{nm}": SubResource("Animation_{nm}"),')
    lib_lines.append('}')
    sub_resources.append("\n".join(lib_lines))

    # Construct complete scene file
    total_steps = len(ext_resources) + len(sub_resources) + 5
    header = f'[gd_scene load_steps={total_steps} format=3 uid="uid://thefirstfallen01"]\n\n'
    
    ext_sec = "\n".join(ext_resources) + "\n\n"
    sub_sec = "\n\n".join(sub_resources) + "\n\n"
    
    nodes = '''[node name="TheFirstFallen" type="CharacterBody2D"]
collision_layer = 2
collision_mask = 1
script = ExtResource("1_boss")

[node name="AnimationPlayer" type="AnimationPlayer" parent="."]
libraries = {
"": SubResource("AnimationLibrary_boss")
}

[node name="CollisionShape2D" type="CollisionShape2D" parent="."]
position = Vector2(0, -55)
shape = SubResource("CapsuleShape2D_body")

[node name="VoidParticles" type="GPUParticles2D" parent="."]
show_behind_parent = true
position = Vector2(0, -55)
amount = 28
process_material = SubResource("ParticleProcessMaterial_void")
lifetime = 0.9
preprocess = 0.5

[node name="Sprite2D" type="Sprite2D" parent="."]
texture_filter = 1
position = Vector2(0, -96)
scale = Vector2(0.35, 0.35)
texture = ExtResource("''' + ext_map["p1_idle_01"] + '''")

[node name="Hurtbox" type="Area2D" parent="."]
collision_layer = 8
collision_mask = 0
script = ExtResource("2_hurtbox")

[node name="CollisionShape2D" type="CollisionShape2D" parent="Hurtbox"]
position = Vector2(0, -55)
shape = SubResource("CapsuleShape2D_hurt")
debug_color = Color(0.9, 0.2, 0.2, 0.3)

[node name="AttackHitbox" type="Area2D" parent="."]
collision_layer = 4
collision_mask = 8
script = ExtResource("3_hitbox")

[node name="CollisionShape2D" type="CollisionShape2D" parent="AttackHitbox"]
position = Vector2(55, -55)
shape = SubResource("RectangleShape2D_hit")
debug_color = Color(0.85, 0.1, 0.1, 0.4)
'''

    content = header + ext_sec + sub_sec + nodes
    with open('src/characters/TheFirstFallen.tscn', 'w', encoding='utf-8') as f:
        f.write(content)
    print("Successfully generated src/characters/TheFirstFallen.tscn!")

if __name__ == '__main__':
    generate_tscn()
