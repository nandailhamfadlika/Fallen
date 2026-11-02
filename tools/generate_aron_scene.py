import os

def generate_aron_scene():
    out_path = r"A:\Game\Fallen\src\characters\Aron.tscn"

    # Texture resource definitions
    textures = [
        # Idle (4)
        ("2_idle01", "res://assets/characters/aron/idle/idle_01.png"),
        ("3_idle02", "res://assets/characters/aron/idle/idle_02.png"),
        ("4_idle03", "res://assets/characters/aron/idle/idle_03.png"),
        ("5_idle04", "res://assets/characters/aron/idle/idle_04.png"),
        # Run (6)
        ("6_run01", "res://assets/characters/aron/run/run_01.png"),
        ("7_run02", "res://assets/characters/aron/run/run_02.png"),
        ("8_run03", "res://assets/characters/aron/run/run_03.png"),
        ("9_run04", "res://assets/characters/aron/run/run_04.png"),
        ("10_run05", "res://assets/characters/aron/run/run_05.png"),
        ("11_run06", "res://assets/characters/aron/run/run_06.png"),
        # Jump & Fall (6)
        ("12_j01", "res://assets/characters/aron/jump/jump_01_takeoff.png"),
        ("13_j02", "res://assets/characters/aron/jump/jump_02_rise.png"),
        ("14_j03", "res://assets/characters/aron/jump/jump_03_apex.png"),
        ("15_j04", "res://assets/characters/aron/jump/jump_04_fall_start.png"),
        ("16_j05", "res://assets/characters/aron/jump/jump_05_fast_fall.png"),
        ("17_j06", "res://assets/characters/aron/jump/jump_06_land_prep.png"),
        # Wall (4)
        ("18_w01", "res://assets/characters/aron/wall/wall_01_grab.png"),
        ("19_w02", "res://assets/characters/aron/wall/wall_02_slide.png"),
        ("20_w03", "res://assets/characters/aron/wall/wall_03_cling.png"),
        ("21_w04", "res://assets/characters/aron/wall/wall_04_prep.png"),
        # Hurt (4)
        ("22_h01", "res://assets/characters/aron/hurt/hurt_01.png"),
        ("23_h02", "res://assets/characters/aron/hurt/hurt_02.png"),
        ("24_h03", "res://assets/characters/aron/hurt/hurt_03.png"),
        ("25_h04", "res://assets/characters/aron/hurt/hurt_04.png"),
        # Block (4)
        ("26_b01", "res://assets/characters/aron/block/block_01.png"),
        ("27_b02", "res://assets/characters/aron/block/block_02.png"),
        ("28_b03", "res://assets/characters/aron/block/block_03_impact.png"),
        ("29_b04", "res://assets/characters/aron/block/block_04.png"),
        # Dash (6)
        ("30_d01", "res://assets/characters/aron/dash/dash_01.png"),
        ("31_d02", "res://assets/characters/aron/dash/dash_02.png"),
        ("32_d03", "res://assets/characters/aron/dash/dash_03.png"),
        ("33_d04", "res://assets/characters/aron/dash/dash_04.png"),
        ("34_d05", "res://assets/characters/aron/dash/dash_05.png"),
        ("35_d06", "res://assets/characters/aron/dash/dash_06.png"),
        # Ground Combo (9)
        ("36_c1_01", "res://assets/characters/aron/combo/hit1_01_windup.png"),
        ("37_c1_02", "res://assets/characters/aron/combo/hit1_02_jab.png"),
        ("38_c1_03", "res://assets/characters/aron/combo/hit1_03_recover.png"),
        ("39_c2_01", "res://assets/characters/aron/combo/hit2_01_windup.png"),
        ("40_c2_02", "res://assets/characters/aron/combo/hit2_02_cross.png"),
        ("41_c2_03", "res://assets/characters/aron/combo/hit2_03_recover.png"),
        ("42_c3_01", "res://assets/characters/aron/combo/hit3_01_crouch.png"),
        ("43_c3_02", "res://assets/characters/aron/combo/hit3_02_rise.png"),
        ("44_c3_03", "res://assets/characters/aron/combo/hit3_03_apex.png"),
        # Air Combo (9)
        ("45_a1_01", "res://assets/characters/aron/combo_air/air1_01_windup.png"),
        ("46_a1_02", "res://assets/characters/aron/combo_air/air1_02_jab.png"),
        ("47_a1_03", "res://assets/characters/aron/combo_air/air1_03_recover.png"),
        ("48_a2_01", "res://assets/characters/aron/combo_air/air2_01_windup.png"),
        ("49_a2_02", "res://assets/characters/aron/combo_air/air2_02_hook.png"),
        ("50_a2_03", "res://assets/characters/aron/combo_air/air2_03_recover.png"),
        ("51_a3_01", "res://assets/characters/aron/combo_air/air3_01_windup.png"),
        ("52_a3_02", "res://assets/characters/aron/combo_air/air3_02_slam.png"),
        ("53_a3_03", "res://assets/characters/aron/combo_air/air3_03_recover.png"),
    ]

    lines = []
    lines.append('[gd_scene load_steps=81 format=3 uid="uid://aronfighter01"]')
    lines.append('')
    lines.append('[ext_resource type="Script" path="res://src/characters/Aron.gd" id="1_aron"]')

    for res_id, path in textures:
        lines.append(f'[ext_resource type="Texture2D" path="{path}" id="{res_id}"]')

    lines.append('[ext_resource type="Script" path="res://src/combat/Hurtbox.gd" id="54_hurtbox"]')
    lines.append('[ext_resource type="Script" path="res://src/combat/Hitbox.gd" id="55_hitbox"]')
    lines.append('')

    # Shapes
    lines.append('[sub_resource type="CapsuleShape2D" id="CapsuleShape2D_body"]')
    lines.append('radius = 17.0')
    lines.append('height = 80.0')
    lines.append('')
    lines.append('[sub_resource type="CapsuleShape2D" id="CapsuleShape2D_hurt"]')
    lines.append('radius = 21.0')
    lines.append('height = 86.0')
    lines.append('')
    lines.append('[sub_resource type="RectangleShape2D" id="RectangleShape2D_hit"]')
    lines.append('size = Vector2(70, 44)')
    lines.append('')

    # Cyan Aura Flame Particles
    lines.append('[sub_resource type="Gradient" id="Gradient_aura"]')
    lines.append('offsets = PackedFloat32Array(0, 0.22, 0.65, 1)')
    lines.append('colors = PackedColorArray(0.85, 1, 1, 0.95, 0.18, 0.88, 1, 0.85, 0.05, 0.45, 0.95, 0.55, 0.02, 0.15, 0.65, 0)')
    lines.append('')
    lines.append('[sub_resource type="GradientTexture1D" id="GradientTexture1D_aura"]')
    lines.append('gradient = SubResource("Gradient_aura")')
    lines.append('')
    lines.append('[sub_resource type="Curve" id="Curve_aura_scale"]')
    lines.append('_data = [Vector2(0, 0.75), 0.0, 0.0, 0, 0, Vector2(0.35, 1.25), 0.0, 0.0, 0, 0, Vector2(1, 0.2), 0.0, 0.0, 0, 0]')
    lines.append('point_count = 3')
    lines.append('')
    lines.append('[sub_resource type="CurveTexture" id="CurveTexture_aura"]')
    lines.append('curve = SubResource("Curve_aura_scale")')
    lines.append('')
    lines.append('[sub_resource type="ParticleProcessMaterial" id="ParticleProcessMaterial_aura"]')
    lines.append('particle_flag_disable_z = true')
    lines.append('emission_shape = 3')
    lines.append('emission_box_extents = Vector3(18, 38, 1)')
    lines.append('direction = Vector3(0, -1, 0)')
    lines.append('spread = 24.0')
    lines.append('initial_velocity_min = 22.0')
    lines.append('initial_velocity_max = 52.0')
    lines.append('gravity = Vector3(0, -55, 0)')
    lines.append('scale_min = 2.2')
    lines.append('scale_max = 3.8')
    lines.append('scale_curve = SubResource("CurveTexture_aura")')
    lines.append('color_ramp = SubResource("GradientTexture1D_aura")')
    lines.append('')

    # Animation helper functions
    def make_anim(name, length, loop_mode, step, keys_times, keys_values, method_times=None, method_values=None):
        out = []
        out.append(f'[sub_resource type="Animation" id="Animation_{name}"]')
        out.append(f'resource_name = "{name}"')
        out.append(f'length = {length}')
        if loop_mode:
            out.append(f'loop_mode = {loop_mode}')
        out.append(f'step = {step}')
        out.append('tracks/0/type = "value"')
        out.append('tracks/0/imported = false')
        out.append('tracks/0/enabled = true')
        out.append('tracks/0/path = NodePath("Sprite2D:texture")')
        out.append('tracks/0/interp = 1')
        out.append('tracks/0/loop_wrap = true')
        times_str = ", ".join(str(t) for t in keys_times)
        trans_str = ", ".join("1" for _ in keys_times)
        vals_str = ", ".join(f'ExtResource("{v}")' for v in keys_values)
        out.append('tracks/0/keys = {')
        out.append(f'"times": PackedFloat32Array({times_str}),')
        out.append(f'"transitions": PackedFloat32Array({trans_str}),')
        out.append('"update": 1,')
        out.append(f'"values": [{vals_str}]')
        out.append('}')

        if method_times and method_values:
            m_times_str = ", ".join(str(t) for t in method_times)
            m_trans_str = ", ".join("1" for _ in method_times)
            m_vals_list = []
            for m in method_values:
                m_vals_list.append(f'{{\n"args": [],\n"method": &"{m}"\n}}')
            m_vals_str = ", ".join(m_vals_list)
            out.append('tracks/1/type = "method"')
            out.append('tracks/1/imported = false')
            out.append('tracks/1/enabled = true')
            out.append('tracks/1/path = NodePath(".")')
            out.append('tracks/1/interp = 1')
            out.append('tracks/1/loop_wrap = true')
            out.append('tracks/1/keys = {')
            out.append(f'"times": PackedFloat32Array({m_times_str}),')
            out.append(f'"transitions": PackedFloat32Array({m_trans_str}),')
            out.append(f'"values": [{m_vals_str}]')
            out.append('}')

        out.append('')
        return "\n".join(out)

    # Idle (4 frames)
    lines.append(make_anim("idle", 0.60, 1, 0.15, [0, 0.15, 0.30, 0.45], ["2_idle01", "3_idle02", "4_idle03", "5_idle04"]))

    # Run (6 frames)
    lines.append(make_anim("run", 0.48, 1, 0.08, [0, 0.08, 0.16, 0.24, 0.32, 0.40], ["6_run01", "7_run02", "8_run03", "9_run04", "10_run05", "11_run06"]))

    # Jump (3 frames)
    lines.append(make_anim("jump", 0.24, 0, 0.08, [0, 0.08, 0.16], ["12_j01", "13_j02", "14_j03"]))

    # Fall (3 frames)
    lines.append(make_anim("fall", 0.24, 0, 0.08, [0, 0.08, 0.16], ["15_j04", "16_j05", "17_j06"]))

    # Wall slide (4 frames)
    lines.append(make_anim("wall_slide", 0.48, 1, 0.12, [0, 0.12, 0.24, 0.36], ["18_w01", "19_w02", "20_w03", "21_w04"]))

    # Hurt (4 frames)
    lines.append(make_anim("hurt", 0.36, 0, 0.09, [0, 0.09, 0.18, 0.27], ["22_h01", "23_h02", "24_h03", "25_h04"]))

    # Block (2 frames loop)
    lines.append(make_anim("block", 0.30, 1, 0.15, [0, 0.15], ["26_b01", "27_b02"]))

    # Block Impact (2 frames)
    lines.append(make_anim("block_impact", 0.20, 0, 0.10, [0, 0.10], ["28_b03", "29_b04"]))

    # Dash (6 frames)
    lines.append(make_anim("dash", 0.24, 0, 0.04, [0, 0.04, 0.08, 0.12, 0.16, 0.20], ["30_d01", "31_d02", "32_d03", "33_d04", "34_d05", "35_d06"]))

    # Combo Jab (3 frames)
    lines.append(make_anim(
        "combo_jab", 0.24, 0, 0.02,
        [0, 0.06, 0.18], ["36_c1_01", "37_c1_02", "38_c1_03"],
        [0.06, 0.12, 0.18, 0.24], ["enable_hitbox", "open_combo_window", "disable_hitbox", "finish_combo_animation"]
    ))

    # Combo Cross (3 frames)
    lines.append(make_anim(
        "combo_cross", 0.26, 0, 0.02,
        [0, 0.08, 0.20], ["39_c2_01", "40_c2_02", "41_c2_03"],
        [0.08, 0.14, 0.20, 0.26], ["enable_hitbox", "open_combo_window", "disable_hitbox", "finish_combo_animation"]
    ))

    # Combo Uppercut (3 frames with J curve finisher!)
    lines.append(make_anim(
        "combo_uppercut", 0.42, 0, 0.02,
        [0, 0.08, 0.24], ["42_c3_01", "43_c3_02", "44_c3_03"],
        [0.08, 0.10, 0.16, 0.24, 0.42], ["enable_hitbox", "apply_uppercut_impulse", "open_air_combo_window", "disable_hitbox", "finish_combo_animation"]
    ))

    # Air Combo 1 (3 frames)
    lines.append(make_anim(
        "air_combo_1", 0.22, 0, 0.02,
        [0, 0.06, 0.16], ["45_a1_01", "46_a1_02", "47_a1_03"],
        [0.06, 0.12, 0.16, 0.22], ["enable_hitbox", "open_air_combo_window", "disable_hitbox", "finish_air_combo_animation"]
    ))

    # Air Combo 2 (3 frames)
    lines.append(make_anim(
        "air_combo_2", 0.24, 0, 0.02,
        [0, 0.06, 0.18], ["48_a2_01", "49_a2_02", "50_a2_03"],
        [0.06, 0.12, 0.18, 0.24], ["enable_hitbox", "open_air_combo_window", "disable_hitbox", "finish_air_combo_animation"]
    ))

    # Air Combo 3 (3 frames)
    lines.append(make_anim(
        "air_combo_3", 0.36, 0, 0.02,
        [0, 0.10, 0.24], ["51_a3_01", "52_a3_02", "53_a3_03"],
        [0.10, 0.24, 0.36], ["enable_hitbox", "disable_hitbox", "finish_air_combo_animation"]
    ))

    # AnimationLibrary
    lines.append('[sub_resource type="AnimationLibrary" id="AnimationLibrary_aron"]')
    lines.append('_data = {')
    anims = [
        ("air_combo_1", "air_combo_1"),
        ("air_combo_2", "air_combo_2"),
        ("air_combo_3", "air_combo_3"),
        ("block", "block"),
        ("block_impact", "block_impact"),
        ("combo_cross", "combo_cross"),
        ("combo_jab", "combo_jab"),
        ("combo_uppercut", "combo_uppercut"),
        ("dash", "dash"),
        ("fall", "fall"),
        ("hurt", "hurt"),
        ("idle", "idle"),
        ("jump", "jump"),
        ("run", "run"),
        ("wall_slide", "wall_slide")
    ]
    for anim_name, sub_name in anims:
        lines.append(f'"{anim_name}": SubResource("Animation_{sub_name}"),')
    # remove trailing comma on last item for clean godot syntax
    lines[-1] = lines[-1].rstrip(',')
    lines.append('}')
    lines.append('')

    # Nodes
    lines.append('[node name="Aron" type="CharacterBody2D"]')
    lines.append('collision_layer = 2')
    lines.append('script = ExtResource("1_aron")')
    lines.append('')
    lines.append('[node name="CollisionShape2D" type="CollisionShape2D" parent="."] ')
    lines.append('position = Vector2(0, -40)')
    lines.append('shape = SubResource("CapsuleShape2D_body")')
    lines.append('')
    lines.append('[node name="Sprite2D" type="Sprite2D" parent="."] ')
    lines.append('texture_filter = 1')
    lines.append('position = Vector2(0, -52)')
    lines.append('scale = Vector2(0.31, 0.31)')
    lines.append('texture = ExtResource("2_idle01")')
    lines.append('')
    lines.append('[node name="AuraParticles" type="GPUParticles2D" parent="."] ')
    lines.append('show_behind_parent = true')
    lines.append('z_index = -1')
    lines.append('position = Vector2(0, -42)')
    lines.append('amount = 32')
    lines.append('process_material = SubResource("ParticleProcessMaterial_aura")')
    lines.append('lifetime = 0.55')
    lines.append('preprocess = 0.5')
    lines.append('explosiveness = 0.05')
    lines.append('')
    lines.append('[node name="Hurtbox" type="Area2D" parent="."] ')
    lines.append('collision_layer = 8')
    lines.append('collision_mask = 0')
    lines.append('script = ExtResource("54_hurtbox")')
    lines.append('')
    lines.append('[node name="CollisionShape2D" type="CollisionShape2D" parent="Hurtbox"]')
    lines.append('position = Vector2(0, -43)')
    lines.append('shape = SubResource("CapsuleShape2D_hurt")')
    lines.append('debug_color = Color(0, 0.6, 0.7, 0.3)')
    lines.append('')
    lines.append('[node name="AttackHitbox" type="Area2D" parent="."] ')
    lines.append('position = Vector2(52, -44)')
    lines.append('collision_layer = 4')
    lines.append('collision_mask = 8')
    lines.append('script = ExtResource("55_hitbox")')
    lines.append('')
    lines.append('[node name="CollisionShape2D" type="CollisionShape2D" parent="AttackHitbox"]')
    lines.append('shape = SubResource("RectangleShape2D_hit")')
    lines.append('debug_color = Color(0.9, 0.2, 0.1, 0.4)')
    lines.append('')
    lines.append('[node name="AnimationPlayer" type="AnimationPlayer" parent="."] ')
    lines.append('libraries = {')
    lines.append('"": SubResource("AnimationLibrary_aron")')
    lines.append('}')
    lines.append('autoplay = "idle"')
    lines.append('')

    content = "\n".join(lines)
    with open(out_path, "w", encoding="utf-8") as f:
        f.write(content)
    print(f"Aron.tscn successfully written to {out_path} ({len(lines)} lines)")

if __name__ == "__main__":
    generate_aron_scene()
