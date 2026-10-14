import os

tscn = """[gd_scene format=3]

[ext_resource type="Script" path="res://scripts/regions/region_scene.gd" id="1_script"]
[ext_resource type="PackedScene" path="res://scenes/gameplay/player.tscn" id="2_player"]
[ext_resource type="Script" path="res://scripts/gameplay/component_pickup.gd" id="3_pickup"]
[ext_resource type="Texture2D" path="res://assets/images/quantum_power_cell.png" id="4_power_cell"]
[ext_resource type="Script" path="res://scripts/gameplay/teleport_relay.gd" id="5_relay"]
[ext_resource type="PackedScene" path="res://scenes/ui/region_map.tscn" id="6_map"]
[ext_resource type="Texture2D" path="res://assets/images/rix_portrait.png" id="7_portrait"]
[ext_resource type="Texture2D" path="res://assets/images/env/frost_ice_ground.png" id="8_ground"]
[ext_resource type="Texture2D" path="res://assets/images/env/frost_glacier_wall.png" id="9_glacier"]
[ext_resource type="Texture2D" path="res://assets/images/env/frost_ice_monolith.png" id="10_monolith"]
[ext_resource type="Texture2D" path="res://assets/images/env/frost_frozen_debris.png" id="11_debris"]
[ext_resource type="Texture2D" path="res://assets/images/env/frost_cryo_facility.png" id="12_facility"]
[ext_resource type="PackedScene" path="res://scenes/characters/cryo_sentinel.tscn" id="13_sentinel"]
[ext_resource type="Texture2D" path="res://assets/images/env/frost_crystal_cluster.png" id="14_crystal"]
[ext_resource type="Texture2D" path="res://assets/images/env/frost_containment_pod.png" id="15_pod"]
[ext_resource type="Texture2D" path="res://assets/images/env/frost_conduit_pipe.png" id="16_pipe"]
[ext_resource type="Texture2D" path="res://assets/images/env/frost_forcefield_barrier.png" id="17_barrier"]
[ext_resource type="Texture2D" path="res://assets/images/env/frost_hazard_vent.png" id="18_vent"]

[sub_resource type="Gradient" id="Gradient_snow"]
offsets = PackedFloat32Array(0, 0.3, 0.8, 1)
colors = PackedColorArray(0.9, 0.95, 1, 0.9, 0.7, 0.85, 1, 0.7, 0.4, 0.7, 0.9, 0.3, 0, 0, 0, 0)

[sub_resource type="Gradient" id="Gradient_relay"]
offsets = PackedFloat32Array(0, 0.4, 1)
colors = PackedColorArray(0.3, 0.85, 1, 0.9, 0.1, 0.6, 1, 0.6, 0, 0.2, 0.5, 0)

[sub_resource type="Gradient" id="Gradient_steam"]
offsets = PackedFloat32Array(0, 0.25, 0.7, 1)
colors = PackedColorArray(0.8, 0.95, 1, 0.7, 0.4, 0.8, 1, 0.5, 0.1, 0.4, 0.9, 0.2, 0, 0, 0, 0)

[sub_resource type="Gradient" id="Gradient_barrier"]
offsets = PackedFloat32Array(0, 0.5, 1)
colors = PackedColorArray(0.2, 0.85, 1, 0.8, 0.6, 0.95, 1, 0.6, 0, 0.4, 0.9, 0)

[sub_resource type="CircleShape2D" id="CircleShape2D_pickup"]
radius = 85.0

[sub_resource type="CircleShape2D" id="CircleShape2D_relay"]
radius = 60.0

[sub_resource type="CapsuleShape2D" id="CapsuleShape2D_monolith"]
radius = 35.0
height = 240.0

[sub_resource type="CapsuleShape2D" id="CapsuleShape2D_crystal"]
radius = 45.0
height = 190.0

[sub_resource type="CapsuleShape2D" id="CapsuleShape2D_pod"]
radius = 28.0
height = 70.0

[sub_resource type="RectangleShape2D" id="RectangleShape2D_pipe"]
size = Vector2(210.0, 36.0)

[sub_resource type="RectangleShape2D" id="RectangleShape2D_barrier"]
size = Vector2(40.0, 220.0)

[sub_resource type="StyleBoxFlat" id="StyleBoxFlat_hud"]
bg_color = Color(0.02, 0.05, 0.1, 0.85)
border_width_left = 2
border_width_top = 1
border_width_right = 1
border_width_bottom = 1
border_color = Color(0.2, 0.7, 0.95, 0.7)
corner_radius_top_left = 6
corner_radius_top_right = 6
corner_radius_bottom_right = 6
corner_radius_bottom_left = 6

[sub_resource type="StyleBoxFlat" id="StyleBoxFlat_banner"]
bg_color = Color(0.04, 0.09, 0.16, 0.95)
border_width_left = 3
border_width_top = 2
border_width_right = 3
border_width_bottom = 2
border_color = Color(0.3, 0.9, 1, 0.9)
corner_radius_top_left = 8
corner_radius_top_right = 8
corner_radius_bottom_right = 8
corner_radius_bottom_left = 8
shadow_color = Color(0.1, 0.6, 1, 0.5)
shadow_size = 18

[sub_resource type="StyleBoxFlat" id="StyleBoxFlat_pause"]
bg_color = Color(0.03, 0.06, 0.12, 0.95)
border_width_left = 2
border_width_top = 2
border_width_right = 2
border_width_bottom = 2
border_color = Color(0.25, 0.75, 1, 0.8)
corner_radius_top_left = 10
corner_radius_top_right = 10
corner_radius_bottom_right = 10
corner_radius_bottom_left = 10

[sub_resource type="StyleBoxFlat" id="StyleBoxFlat_pbtn"]
bg_color = Color(0.06, 0.14, 0.24, 0.85)
border_width_left = 2
border_width_top = 1
border_width_right = 1
border_width_bottom = 1
border_color = Color(0.2, 0.7, 0.95, 0.5)
corner_radius_top_left = 4
corner_radius_top_right = 6
corner_radius_bottom_right = 6
corner_radius_bottom_left = 4

[node name="FrostfallExpanse" type="Node2D"]
y_sort_enabled = true
script = ExtResource("1_script")
region_id = "frostfall_expanse"
region_display_name = "FROSTFALL EXPANSE"
base_lat = -68.742
base_lon = 210.155

[node name="GroundTexture" type="TextureRect" parent="."]
z_index = -10
offset_left = -2500.0
offset_top = -1800.0
offset_right = 2500.0
offset_bottom = 1800.0
texture = ExtResource("8_ground")
stretch_mode = 1

[node name="GlacialAtmosphereTint" type="ColorRect" parent="."]
z_index = -9
offset_left = -2500.0
offset_top = -1800.0
offset_right = 2500.0
offset_bottom = 1800.0
mouse_filter = 2
color = Color(0.08, 0.28, 0.55, 0.24)

[node name="BlizzardParticles" type="CPUParticles2D" parent="."]
z_index = 8
amount = 260
lifetime = 4.0
preprocess = 2.0
emission_shape = 3
emission_rect_extents = Vector2(2400, 1600)
gravity = Vector2(170, 45)
initial_velocity_min = 45.0
initial_velocity_max = 130.0
scale_amount_min = 2.5
scale_amount_max = 7.5
color_ramp = SubResource("Gradient_snow")

[node name="NorthGlacier" type="StaticBody2D" parent="."]
position = Vector2(40, -520)

[node name="Sprite2D" type="Sprite2D" parent="NorthGlacier"]
scale = Vector2(2.0, 2.0)
texture = ExtResource("9_glacier")

[node name="CollisionPolygon2D" type="CollisionPolygon2D" parent="NorthGlacier"]
polygon = PackedVector2Array(-420, 140, -340, 30, 0, -30, 340, 30, 440, 140)

[node name="SouthGlacier" type="StaticBody2D" parent="."]
position = Vector2(60, 540)

[node name="Sprite2D" type="Sprite2D" parent="SouthGlacier"]
scale = Vector2(2.0, 2.0)
texture = ExtResource("9_glacier")
flip_v = true

[node name="CollisionPolygon2D" type="CollisionPolygon2D" parent="SouthGlacier"]
polygon = PackedVector2Array(-420, -140, -340, -30, 0, 30, 340, -30, 440, -140)

[node name="MonolithLeft" type="StaticBody2D" parent="."]
position = Vector2(-700, 20)

[node name="Sprite2D" type="Sprite2D" parent="MonolithLeft"]
scale = Vector2(1.3, 1.3)
texture = ExtResource("10_monolith")

[node name="CollisionShape2D" type="CollisionShape2D" parent="MonolithLeft"]
position = Vector2(0, 30)
shape = SubResource("CapsuleShape2D_monolith")

[node name="MonolithRight" type="StaticBody2D" parent="."]
position = Vector2(850, 40)

[node name="Sprite2D" type="Sprite2D" parent="MonolithRight"]
scale = Vector2(1.3, 1.3)
texture = ExtResource("10_monolith")
flip_h = true

[node name="CollisionShape2D" type="CollisionShape2D" parent="MonolithRight"]
position = Vector2(0, 30)
shape = SubResource("CapsuleShape2D_monolith")

[node name="CrystalCluster1" type="StaticBody2D" parent="."]
y_sort_enabled = true
position = Vector2(-180, -320)

[node name="Sprite2D" type="Sprite2D" parent="CrystalCluster1"]
position = Vector2(0, -90)
scale = Vector2(0.9, 0.9)
texture = ExtResource("14_crystal")

[node name="CollisionShape2D" type="CollisionShape2D" parent="CrystalCluster1"]
position = Vector2(0, -10)
rotation = 1.5708
shape = SubResource("CapsuleShape2D_crystal")

[node name="CrystalCluster2" type="StaticBody2D" parent="."]
y_sort_enabled = true
position = Vector2(180, 310)

[node name="Sprite2D" type="Sprite2D" parent="CrystalCluster2"]
position = Vector2(0, -90)
scale = Vector2(0.95, 0.95)
texture = ExtResource("14_crystal")
flip_h = true

[node name="CollisionShape2D" type="CollisionShape2D" parent="CrystalCluster2"]
position = Vector2(0, -10)
rotation = 1.5708
shape = SubResource("CapsuleShape2D_crystal")

[node name="ConduitPipes1" type="StaticBody2D" parent="."]
y_sort_enabled = true
position = Vector2(-160, 210)

[node name="Sprite2D" type="Sprite2D" parent="ConduitPipes1"]
position = Vector2(0, -30)
texture = ExtResource("16_pipe")

[node name="CollisionShape2D" type="CollisionShape2D" parent="ConduitPipes1"]
position = Vector2(0, -5)
shape = SubResource("RectangleShape2D_pipe")

[node name="ConduitPipes2" type="StaticBody2D" parent="."]
y_sort_enabled = true
position = Vector2(40, -250)

[node name="Sprite2D" type="Sprite2D" parent="ConduitPipes2"]
position = Vector2(0, -30)
texture = ExtResource("16_pipe")
flip_h = true

[node name="CollisionShape2D" type="CollisionShape2D" parent="ConduitPipes2"]
position = Vector2(0, -5)
shape = SubResource("RectangleShape2D_pipe")

[node name="ContainmentPod1" type="StaticBody2D" parent="."]
y_sort_enabled = true
position = Vector2(-280, -130)

[node name="Sprite2D" type="Sprite2D" parent="ContainmentPod1"]
position = Vector2(0, -50)
scale = Vector2(0.85, 0.85)
texture = ExtResource("15_pod")

[node name="CollisionShape2D" type="CollisionShape2D" parent="ContainmentPod1"]
position = Vector2(0, -6)
rotation = 1.5708
shape = SubResource("CapsuleShape2D_pod")

[node name="ContainmentPod2" type="StaticBody2D" parent="."]
y_sort_enabled = true
position = Vector2(100, -210)

[node name="Sprite2D" type="Sprite2D" parent="ContainmentPod2"]
position = Vector2(0, -50)
scale = Vector2(0.85, 0.85)
texture = ExtResource("15_pod")

[node name="CollisionShape2D" type="CollisionShape2D" parent="ContainmentPod2"]
position = Vector2(0, -6)
rotation = 1.5708
shape = SubResource("CapsuleShape2D_pod")

[node name="ContainmentPod3" type="StaticBody2D" parent="."]
y_sort_enabled = true
position = Vector2(220, 160)

[node name="Sprite2D" type="Sprite2D" parent="ContainmentPod3"]
position = Vector2(0, -50)
scale = Vector2(0.85, 0.85)
texture = ExtResource("15_pod")

[node name="CollisionShape2D" type="CollisionShape2D" parent="ContainmentPod3"]
position = Vector2(0, -6)
rotation = 1.5708
shape = SubResource("CapsuleShape2D_pod")

[node name="HazardVent1" type="Node2D" parent="."]
position = Vector2(-90, 50)

[node name="Sprite2D" type="Sprite2D" parent="HazardVent1"]
position = Vector2(0, -15)
scale = Vector2(0.8, 0.8)
texture = ExtResource("18_vent")

[node name="SteamParticles" type="CPUParticles2D" parent="HazardVent1"]
position = Vector2(0, -20)
amount = 22
lifetime = 1.2
emission_shape = 1
emission_sphere_radius = 18.0
gravity = Vector2(30, -55)
initial_velocity_min = 20.0
initial_velocity_max = 50.0
scale_amount_min = 3.0
scale_amount_max = 8.0
color_ramp = SubResource("Gradient_steam")

[node name="HazardVent2" type="Node2D" parent="."]
position = Vector2(170, -70)

[node name="Sprite2D" type="Sprite2D" parent="HazardVent2"]
position = Vector2(0, -15)
scale = Vector2(0.8, 0.8)
texture = ExtResource("18_vent")

[node name="SteamParticles" type="CPUParticles2D" parent="HazardVent2"]
position = Vector2(0, -20)
amount = 22
lifetime = 1.2
emission_shape = 1
emission_sphere_radius = 18.0
gravity = Vector2(30, -55)
initial_velocity_min = 20.0
initial_velocity_max = 50.0
scale_amount_min = 3.0
scale_amount_max = 8.0
color_ramp = SubResource("Gradient_steam")

[node name="FrozenDebris1" type="Node2D" parent="."]
position = Vector2(-340, 230)

[node name="Sprite2D" type="Sprite2D" parent="FrozenDebris1"]
scale = Vector2(1.2, 1.2)
texture = ExtResource("11_debris")

[node name="FrozenDebris2" type="Node2D" parent="."]
position = Vector2(310, 260)

[node name="Sprite2D" type="Sprite2D" parent="FrozenDebris2"]
scale = Vector2(1.2, 1.2)
texture = ExtResource("11_debris")
flip_h = true

[node name="ExtractionRelay" type="Area2D" parent="."]
position = Vector2(-490, 40)
script = ExtResource("5_relay")
prompt_message = "[E] ACCESS EXTRACTION RELAY // MAP"

[node name="CollisionShape2D" type="CollisionShape2D" parent="ExtractionRelay"]
shape = SubResource("CircleShape2D_relay")

[node name="AuraParticles" type="CPUParticles2D" parent="ExtractionRelay"]
amount = 25
lifetime = 2.0
emission_shape = 1
emission_sphere_radius = 25.0
gravity = Vector2(0, -30)
scale_amount_min = 3.0
scale_amount_max = 7.0
color_ramp = SubResource("Gradient_relay")

[node name="BeamParticles" type="CPUParticles2D" parent="ExtractionRelay"]
position = Vector2(0, -40)
amount = 15
lifetime = 1.0
emission_shape = 3
emission_rect_extents = Vector2(10, 60)
gravity = Vector2(0, -60)
scale_amount_min = 2.0
scale_amount_max = 5.0
color_ramp = SubResource("Gradient_relay")

[node name="ForcefieldBarrier" type="StaticBody2D" parent="."]
unique_name_in_owner = true
z_index = 4
position = Vector2(360, -120)

[node name="Sprite2D" type="Sprite2D" parent="ForcefieldBarrier"]
rotation = 1.5708
scale = Vector2(1.0, 1.1)
texture = ExtResource("17_barrier")

[node name="CollisionShape2D" type="CollisionShape2D" parent="ForcefieldBarrier"]
shape = SubResource("RectangleShape2D_barrier")

[node name="BarrierParticles" type="CPUParticles2D" parent="ForcefieldBarrier"]
amount = 30
lifetime = 1.0
emission_shape = 3
emission_rect_extents = Vector2(15, 100)
gravity = Vector2(0, 0)
initial_velocity_min = 10.0
initial_velocity_max = 30.0
scale_amount_min = 2.5
scale_amount_max = 6.0
color_ramp = SubResource("Gradient_barrier")

[node name="CryoFacility" type="StaticBody2D" parent="."]
position = Vector2(560, -120)

[node name="Sprite2D" type="Sprite2D" parent="CryoFacility"]
scale = Vector2(1.2, 1.2)
texture = ExtResource("12_facility")

[node name="CollisionPolygon2D" type="CollisionPolygon2D" parent="CryoFacility"]
polygon = PackedVector2Array(-150, -10, -80, -70, 80, -70, 150, -10, 120, 25, -120, 25)

[node name="ComponentPickup" type="Area2D" parent="."]
position = Vector2(490, -85)
script = ExtResource("3_pickup")
component_id = "quantum_power_cell"
component_name = "Quantum Power Cell"
prompt_message = "[E] RECOVER QUANTUM POWER CELL"

[node name="CollisionShape2D" type="CollisionShape2D" parent="ComponentPickup"]
unique_name_in_owner = true
shape = SubResource("CircleShape2D_pickup")

[node name="Sprite2D" type="Sprite2D" parent="ComponentPickup"]
unique_name_in_owner = true
scale = Vector2(0.2, 0.2)
texture = ExtResource("4_power_cell")

[node name="AuraParticles" type="CPUParticles2D" parent="ComponentPickup"]
unique_name_in_owner = true
amount = 25
lifetime = 1.8
emission_shape = 1
emission_sphere_radius = 28.0
gravity = Vector2(0, -25)
scale_amount_min = 3.0
scale_amount_max = 7.5
color_ramp = SubResource("Gradient_snow")

[node name="SparkParticles" type="CPUParticles2D" parent="ComponentPickup"]
unique_name_in_owner = true
emitting = false
amount = 40
lifetime = 0.5
one_shot = true
explosiveness = 0.8
emission_shape = 1
emission_sphere_radius = 22.0
gravity = Vector2(0, 0)
initial_velocity_min = 100.0
initial_velocity_max = 260.0
scale_amount_min = 3.0
scale_amount_max = 8.0
color_ramp = SubResource("Gradient_snow")

[node name="Sentinels" type="Node2D" parent="."]
y_sort_enabled = true

[node name="CryoSentinel1" parent="Sentinels" instance=ExtResource("13_sentinel")]
position = Vector2(-70, -90)
enemy_name = "CRYO SENTINEL V-1"
patrol_points = PackedVector2Array(-160, -140, 10, -50, -70, -90)

[node name="CryoSentinel2" parent="Sentinels" instance=ExtResource("13_sentinel")]
position = Vector2(90, 80)
enemy_name = "GLACIAL REAVER DROID"
patrol_points = PackedVector2Array(10, 40, 160, 130, 90, 80)

[node name="CryoSentinel3" parent="Sentinels" instance=ExtResource("13_sentinel")]
position = Vector2(210, -120)
enemy_name = "CRYO AEGIS GUARDIAN"
patrol_points = PackedVector2Array(170, -180, 240, -60, 210, -120)

[node name="Player" parent="." instance=ExtResource("2_player")]
unique_name_in_owner = true
position = Vector2(-420, 40)

[node name="Camera2D" type="Camera2D" parent="."]
unique_name_in_owner = true
position = Vector2(-420, 40)
zoom = Vector2(1.2, 1.2)
position_smoothing_enabled = true

[node name="CanvasLayer" type="CanvasLayer" parent="."]
layer = 5

[node name="HUD" type="Control" parent="CanvasLayer"]
layout_mode = 3
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
mouse_filter = 2

[node name="TopLeftBox" type="PanelContainer" parent="CanvasLayer/HUD"]
layout_mode = 0
offset_left = 32.0
offset_top = 28.0
offset_right = 440.0
offset_bottom = 160.0
theme_override_styles/panel = SubResource("StyleBoxFlat_hud")

[node name="Margin" type="MarginContainer" parent="CanvasLayer/HUD/TopLeftBox"]
layout_mode = 2
theme_override_constants/margin_left = 16
theme_override_constants/margin_top = 12
theme_override_constants/margin_right = 16
theme_override_constants/margin_bottom = 12

[node name="HBox" type="HBoxContainer" parent="CanvasLayer/HUD/TopLeftBox/Margin"]
layout_mode = 2
theme_override_constants/separation = 16

[node name="Avatar" type="TextureRect" parent="CanvasLayer/HUD/TopLeftBox/Margin/HBox"]
custom_minimum_size = Vector2(90, 90)
layout_mode = 2
texture = ExtResource("7_portrait")
expand_mode = 1
stretch_mode = 6

[node name="VBox" type="VBoxContainer" parent="CanvasLayer/HUD/TopLeftBox/Margin/HBox"]
layout_mode = 2
size_flags_horizontal = 3
theme_override_constants/separation = 6

[node name="RegionTag" type="Label" parent="CanvasLayer/HUD/TopLeftBox/Margin/HBox/VBox"]
unique_name_in_owner = true
layout_mode = 2
theme_override_colors/font_color = Color(0.4, 0.85, 1, 1)
theme_override_constants/letter_spacing = 2
theme_override_font_sizes/font_size = 14
text = "SECTOR // FROSTFALL EXPANSE"

[node name="BarSuit" type="HBoxContainer" parent="CanvasLayer/HUD/TopLeftBox/Margin/HBox/VBox"]
layout_mode = 2

[node name="Lbl" type="Label" parent="CanvasLayer/HUD/TopLeftBox/Margin/HBox/VBox/BarSuit"]
custom_minimum_size = Vector2(65, 0)
layout_mode = 2
theme_override_colors/font_color = Color(0.6, 0.8, 0.95, 0.8)
theme_override_font_sizes/font_size = 11
text = "SUIT"

[node name="HealthBar" type="ProgressBar" parent="CanvasLayer/HUD/TopLeftBox/Margin/HBox/VBox/BarSuit"]
unique_name_in_owner = true
custom_minimum_size = Vector2(0, 10)
layout_mode = 2
size_flags_horizontal = 3
size_flags_vertical = 4
value = 100.0
show_percentage = false

[node name="BarO2" type="HBoxContainer" parent="CanvasLayer/HUD/TopLeftBox/Margin/HBox/VBox"]
layout_mode = 2

[node name="Lbl" type="Label" parent="CanvasLayer/HUD/TopLeftBox/Margin/HBox/VBox/BarO2"]
custom_minimum_size = Vector2(65, 0)
layout_mode = 2
theme_override_colors/font_color = Color(0.6, 0.8, 0.95, 0.8)
theme_override_font_sizes/font_size = 11
text = "OXYGEN"

[node name="OxygenBar" type="ProgressBar" parent="CanvasLayer/HUD/TopLeftBox/Margin/HBox/VBox/BarO2"]
unique_name_in_owner = true
custom_minimum_size = Vector2(0, 10)
layout_mode = 2
size_flags_horizontal = 3
size_flags_vertical = 4
value = 100.0
show_percentage = false

[node name="BarStamina" type="HBoxContainer" parent="CanvasLayer/HUD/TopLeftBox/Margin/HBox/VBox"]
layout_mode = 2

[node name="Lbl" type="Label" parent="CanvasLayer/HUD/TopLeftBox/Margin/HBox/VBox/BarStamina"]
custom_minimum_size = Vector2(65, 0)
layout_mode = 2
theme_override_colors/font_color = Color(0.6, 0.8, 0.95, 0.8)
theme_override_font_sizes/font_size = 11
text = "STAMINA"

[node name="StaminaBar" type="ProgressBar" parent="CanvasLayer/HUD/TopLeftBox/Margin/HBox/VBox/BarStamina"]
unique_name_in_owner = true
custom_minimum_size = Vector2(0, 10)
layout_mode = 2
size_flags_horizontal = 3
size_flags_vertical = 4
value = 100.0
show_percentage = false

[node name="BottomBox" type="PanelContainer" parent="CanvasLayer/HUD"]
layout_mode = 1
anchors_preset = 12
anchor_top = 1.0
anchor_right = 1.0
anchor_bottom = 1.0
offset_left = 32.0
offset_top = -68.0
offset_right = -32.0
offset_bottom = -20.0
grow_horizontal = 2
grow_vertical = 0
theme_override_styles/panel = SubResource("StyleBoxFlat_hud")

[node name="Margin" type="MarginContainer" parent="CanvasLayer/HUD/BottomBox"]
layout_mode = 2
theme_override_constants/margin_left = 20
theme_override_constants/margin_top = 6
theme_override_constants/margin_right = 20
theme_override_constants/margin_bottom = 6

[node name="HBox" type="HBoxContainer" parent="CanvasLayer/HUD/BottomBox/Margin"]
layout_mode = 2

[node name="CoordsLabel" type="Label" parent="CanvasLayer/HUD/BottomBox/Margin/HBox"]
unique_name_in_owner = true
layout_mode = 2
size_flags_horizontal = 3
theme_override_colors/font_color = Color(0.4, 0.85, 1, 0.85)
theme_override_constants/letter_spacing = 2
theme_override_font_sizes/font_size = 13
text = "GRID TELEMETRY"

[node name="ObjectiveLabel" type="Label" parent="CanvasLayer/HUD/BottomBox/Margin/HBox"]
unique_name_in_owner = true
layout_mode = 2
size_flags_horizontal = 3
theme_override_colors/font_color = Color(0.4, 0.85, 1, 1)
theme_override_constants/letter_spacing = 1
theme_override_font_sizes/font_size = 13
text = "OBJECTIVE: Explore terrain — scan for missing propulsion component."
horizontal_alignment = 2

[node name="ObtainedBanner" type="PanelContainer" parent="CanvasLayer"]
unique_name_in_owner = true
visible = false
custom_minimum_size = Vector2(720, 100)
anchors_preset = 5
anchor_left = 0.5
anchor_right = 0.5
offset_left = -360.0
offset_top = 40.0
offset_right = 360.0
offset_bottom = 140.0
grow_horizontal = 2
theme_override_styles/panel = SubResource("StyleBoxFlat_banner")

[node name="Margin" type="MarginContainer" parent="CanvasLayer/ObtainedBanner"]
layout_mode = 2
theme_override_constants/margin_left = 25
theme_override_constants/margin_top = 15
theme_override_constants/margin_right = 25
theme_override_constants/margin_bottom = 15

[node name="VBox" type="VBoxContainer" parent="CanvasLayer/ObtainedBanner/Margin"]
layout_mode = 2
theme_override_constants/separation = 4

[node name="ObtainedTitle" type="Label" parent="CanvasLayer/ObtainedBanner/Margin/VBox"]
unique_name_in_owner = true
layout_mode = 2
theme_override_colors/font_color = Color(0.3, 0.95, 0.5, 1)
theme_override_constants/letter_spacing = 3
theme_override_font_sizes/font_size = 18
text = "CRITICAL COMPONENT RECOVERED!"
horizontal_alignment = 1

[node name="ObtainedDesc" type="Label" parent="CanvasLayer/ObtainedBanner/Margin/VBox"]
unique_name_in_owner = true
layout_mode = 2
theme_override_colors/font_color = Color(0.9, 0.95, 1, 0.9)
theme_override_constants/letter_spacing = 1
theme_override_font_sizes/font_size = 14
text = "QUANTUM POWER CELL SECURED."
horizontal_alignment = 1

[node name="PauseOverlay" type="Control" parent="CanvasLayer"]
unique_name_in_owner = true
visible = false
layout_mode = 3
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2

[node name="DarkBg" type="ColorRect" parent="CanvasLayer/PauseOverlay"]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
color = Color(0.01, 0.02, 0.05, 0.85)

[node name="Center" type="CenterContainer" parent="CanvasLayer/PauseOverlay"]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2

[node name="Panel" type="PanelContainer" parent="CanvasLayer/PauseOverlay/Center"]
custom_minimum_size = Vector2(440, 340)
layout_mode = 2
theme_override_styles/panel = SubResource("StyleBoxFlat_pause")

[node name="Margin" type="MarginContainer" parent="CanvasLayer/PauseOverlay/Center/Panel"]
layout_mode = 2
theme_override_constants/margin_left = 30
theme_override_constants/margin_top = 25
theme_override_constants/margin_right = 30
theme_override_constants/margin_bottom = 25

[node name="VBox" type="VBoxContainer" parent="CanvasLayer/PauseOverlay/Center/Panel/Margin"]
layout_mode = 2
theme_override_constants/separation = 16

[node name="Title" type="Label" parent="CanvasLayer/PauseOverlay/Center/Panel/Margin/VBox"]
layout_mode = 2
theme_override_colors/font_color = Color(0.3, 0.85, 1, 1)
theme_override_constants/letter_spacing = 3
theme_override_font_sizes/font_size = 22
text = "EXPEDITION PAUSED"
horizontal_alignment = 1

[node name="BtnResume" type="Button" parent="CanvasLayer/PauseOverlay/Center/Panel/Margin/VBox"]
unique_name_in_owner = true
custom_minimum_size = Vector2(0, 44)
layout_mode = 2
theme_override_colors/font_color = Color(0.85, 0.95, 1, 1)
theme_override_font_sizes/font_size = 14
theme_override_styles/normal = SubResource("StyleBoxFlat_pbtn")
text = "RESUME EXPEDITION"

[node name="BtnOpenMap" type="Button" parent="CanvasLayer/PauseOverlay/Center/Panel/Margin/VBox"]
unique_name_in_owner = true
custom_minimum_size = Vector2(0, 44)
layout_mode = 2
theme_override_colors/font_color = Color(0.85, 0.95, 1, 1)
theme_override_font_sizes/font_size = 14
theme_override_styles/normal = SubResource("StyleBoxFlat_pbtn")
text = "[M] HOLOGRAPHIC MAP"

[node name="BtnReturnCrash" type="Button" parent="CanvasLayer/PauseOverlay/Center/Panel/Margin/VBox"]
unique_name_in_owner = true
custom_minimum_size = Vector2(0, 44)
layout_mode = 2
theme_override_colors/font_color = Color(0.85, 0.95, 1, 1)
theme_override_font_sizes/font_size = 14
theme_override_styles/normal = SubResource("StyleBoxFlat_pbtn")
text = "RETURN TO CRASH SITE"

[node name="RegionMap" parent="CanvasLayer" instance=ExtResource("6_map")]
unique_name_in_owner = true
visible = false

[node name="FadeRect" type="ColorRect" parent="CanvasLayer"]
unique_name_in_owner = true
visible = false
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
mouse_filter = 2
color = Color(0.01, 0.02, 0.04, 1)
"""

with open("scenes/regions/frostfall_expanse.tscn", "w", encoding="utf-8") as f:
    f.write(tscn)
print("Updated scenes/regions/frostfall_expanse.tscn successfully!")
