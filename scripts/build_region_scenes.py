import os

# Script to build the three detailed exploration region scenes for Echoes of Eternity

def generate_ember_wastes():
    tscn = """[gd_scene format=3]

[ext_resource type="Script" path="res://scripts/regions/region_scene.gd" id="1_script"]
[ext_resource type="PackedScene" path="res://scenes/gameplay/player.tscn" id="2_player"]
[ext_resource type="Script" path="res://scripts/gameplay/component_pickup.gd" id="3_pickup"]
[ext_resource type="Texture2D" path="res://assets/images/plasma_regulator.png" id="4_regulator"]
[ext_resource type="Script" path="res://scripts/gameplay/teleport_relay.gd" id="5_relay"]
[ext_resource type="PackedScene" path="res://scenes/ui/region_map.tscn" id="6_map"]
[ext_resource type="Texture2D" path="res://assets/images/rix_portrait.png" id="7_portrait"]
[ext_resource type="Texture2D" path="res://assets/images/env/ember_sand_ground.png" id="8_ground"]
[ext_resource type="Texture2D" path="res://assets/images/env/ember_sandstone_cliff.png" id="9_cliff"]
[ext_resource type="Texture2D" path="res://assets/images/env/ember_volcanic_rocks.png" id="10_rocks"]
[ext_resource type="Texture2D" path="res://assets/images/env/ember_glowing_fissure.png" id="11_fissure"]
[ext_resource type="Texture2D" path="res://assets/images/env/ember_reactor_platform.png" id="12_platform"]

[sub_resource type="Gradient" id="Gradient_embers"]
offsets = PackedFloat32Array(0, 0.3, 0.8, 1)
colors = PackedColorArray(1, 0.8, 0.3, 0.9, 1, 0.4, 0.1, 0.8, 0.8, 0.15, 0.05, 0.5, 0, 0, 0, 0)

[sub_resource type="Gradient" id="Gradient_smoke"]
offsets = PackedFloat32Array(0, 0.4, 1)
colors = PackedColorArray(0.4, 0.2, 0.15, 0.6, 0.25, 0.15, 0.1, 0.4, 0.1, 0.05, 0.05, 0)

[sub_resource type="Gradient" id="Gradient_relay"]
offsets = PackedFloat32Array(0, 0.4, 1)
colors = PackedColorArray(1, 0.7, 0.2, 0.9, 1, 0.4, 0.1, 0.6, 0.5, 0.1, 0, 0)

[sub_resource type="CircleShape2D" id="CircleShape2D_pickup"]
radius = 52.0

[sub_resource type="CircleShape2D" id="CircleShape2D_relay"]
radius = 60.0

[sub_resource type="CapsuleShape2D" id="CapsuleShape2D_rock"]
radius = 45.0
height = 140.0

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

[node name="EmberWastes" type="Node2D"]
script = ExtResource("1_script")
region_id = "ember_wastes"
region_display_name = "EMBER WASTES"
base_lat = -12.408
base_lon = 148.912

[node name="GroundTexture" type="TextureRect" parent="."]
offset_left = -2500.0
offset_top = -1800.0
offset_right = 2500.0
offset_bottom = 1800.0
texture = ExtResource("8_ground")
stretch_mode = 1

[node name="CanyonWarmthTint" type="ColorRect" parent="."]
offset_left = -2500.0
offset_top = -1800.0
offset_right = 2500.0
offset_bottom = 1800.0
color = Color(0.65, 0.2, 0.05, 0.22)

[node name="EmberParticles" type="CPUParticles2D" parent="."]
amount = 160
lifetime = 6.0
preprocess = 3.0
emission_shape = 3
emission_rect_extents = Vector2(2200, 1500)
gravity = Vector2(30, -50)
initial_velocity_min = 20.0
initial_velocity_max = 60.0
scale_amount_min = 3.0
scale_amount_max = 8.0
color_ramp = SubResource("Gradient_embers")

[node name="NorthCliff" type="StaticBody2D" parent="."]
position = Vector2(0, -520)

[node name="Sprite2D" type="Sprite2D" parent="NorthCliff"]
scale = Vector2(1.8, 1.8)
texture = ExtResource("9_cliff")

[node name="CollisionPolygon2D" type="CollisionPolygon2D" parent="NorthCliff"]
polygon = PackedVector2Array(-380, 120, -320, 20, 0, -40, 320, 20, 380, 120)

[node name="SouthCliff" type="StaticBody2D" parent="."]
position = Vector2(100, 560)

[node name="Sprite2D" type="Sprite2D" parent="SouthCliff"]
scale = Vector2(1.8, 1.8)
texture = ExtResource("9_cliff")
flip_v = true

[node name="CollisionPolygon2D" type="CollisionPolygon2D" parent="SouthCliff"]
polygon = PackedVector2Array(-380, -120, -320, -20, 0, 40, 320, -20, 380, -120)

[node name="WestRocks" type="StaticBody2D" parent="."]
position = Vector2(-700, 0)

[node name="Sprite2D" type="Sprite2D" parent="WestRocks"]
scale = Vector2(1.4, 1.4)
texture = ExtResource("10_rocks")

[node name="CollisionShape2D" type="CollisionShape2D" parent="WestRocks"]
position = Vector2(0, 10)
rotation = 1.5708
shape = SubResource("CapsuleShape2D_rock")

[node name="EastRocks" type="StaticBody2D" parent="."]
position = Vector2(820, -80)

[node name="Sprite2D" type="Sprite2D" parent="EastRocks"]
scale = Vector2(1.5, 1.5)
texture = ExtResource("10_rocks")
flip_h = true

[node name="CollisionShape2D" type="CollisionShape2D" parent="EastRocks"]
position = Vector2(0, 10)
rotation = 1.5708
shape = SubResource("CapsuleShape2D_rock")

[node name="MidRocks" type="StaticBody2D" parent="."]
position = Vector2(-60, 260)

[node name="Sprite2D" type="Sprite2D" parent="MidRocks"]
scale = Vector2(1.2, 1.2)
texture = ExtResource("10_rocks")

[node name="CollisionShape2D" type="CollisionShape2D" parent="MidRocks"]
position = Vector2(0, 10)
rotation = 1.5708
shape = SubResource("CapsuleShape2D_rock")

[node name="Fissure1" type="Node2D" parent="."]
position = Vector2(120, -60)

[node name="Sprite2D" type="Sprite2D" parent="Fissure1"]
texture = ExtResource("11_fissure")

[node name="Smoke" type="CPUParticles2D" parent="Fissure1"]
position = Vector2(20, -10)
amount = 45
lifetime = 3.5
emission_shape = 1
emission_sphere_radius = 35.0
gravity = Vector2(25, -45)
scale_amount_min = 12.0
scale_amount_max = 35.0
color_ramp = SubResource("Gradient_smoke")

[node name="Fissure2" type="Node2D" parent="."]
position = Vector2(-420, -280)

[node name="Sprite2D" type="Sprite2D" parent="Fissure2"]
texture = ExtResource("11_fissure")

[node name="Smoke" type="CPUParticles2D" parent="Fissure2"]
amount = 35
lifetime = 3.0
emission_shape = 1
emission_sphere_radius = 25.0
gravity = Vector2(20, -40)
scale_amount_min = 10.0
scale_amount_max = 28.0
color_ramp = SubResource("Gradient_smoke")

[node name="ReactorPlatform" type="StaticBody2D" parent="."]
position = Vector2(450, -160)

[node name="Sprite2D" type="Sprite2D" parent="ReactorPlatform"]
texture = ExtResource("12_platform")

[node name="CollisionPolygon2D" type="CollisionPolygon2D" parent="ReactorPlatform"]
polygon = PackedVector2Array(-140, 90, -150, 20, -90, -70, 90, -70, 150, 20, 140, 90)

[node name="ExtractionRelay" type="Area2D" parent="."]
position = Vector2(-380, 120)
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

[node name="ComponentPickup" type="Area2D" parent="."]
position = Vector2(450, -160)
script = ExtResource("3_pickup")
component_id = "plasma_regulator"
component_name = "Plasma Regulator"
prompt_message = "[E] RECOVER PLASMA REGULATOR"

[node name="CollisionShape2D" type="CollisionShape2D" parent="ComponentPickup"]
unique_name_in_owner = true
shape = SubResource("CircleShape2D_pickup")

[node name="Sprite2D" type="Sprite2D" parent="ComponentPickup"]
unique_name_in_owner = true
scale = Vector2(0.18, 0.18)
texture = ExtResource("4_regulator")

[node name="AuraParticles" type="CPUParticles2D" parent="ComponentPickup"]
unique_name_in_owner = true
amount = 20
lifetime = 1.8
emission_shape = 1
emission_sphere_radius = 24.0
gravity = Vector2(0, -25)
scale_amount_min = 3.0
scale_amount_max = 7.0
color_ramp = SubResource("Gradient_embers")

[node name="SparkParticles" type="CPUParticles2D" parent="ComponentPickup"]
unique_name_in_owner = true
emitting = false
amount = 35
lifetime = 0.5
one_shot = true
explosiveness = 0.8
emission_shape = 1
emission_sphere_radius = 20.0
gravity = Vector2(0, 0)
initial_velocity_min = 100.0
initial_velocity_max = 250.0
scale_amount_min = 3.0
scale_amount_max = 8.0
color_ramp = SubResource("Gradient_embers")

[node name="Player" parent="." instance=ExtResource("2_player")]
unique_name_in_owner = true
position = Vector2(-250, 80)

[node name="Camera2D" type="Camera2D" parent="."]
unique_name_in_owner = true
position = Vector2(-250, 80)
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
theme_override_colors/font_color = Color(0.3, 0.85, 1, 1)
theme_override_constants/letter_spacing = 2
theme_override_font_sizes/font_size = 14
text = "SECTOR // EMBER WASTES"

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
theme_override_colors/font_color = Color(1, 0.8, 0.3, 1)
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
text = "PLASMA REGULATOR SECURED."
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
    with open("scenes/regions/ember_wastes.tscn", "w", encoding="utf-8") as f:
        f.write(tscn)
    print("Wrote scenes/regions/ember_wastes.tscn")

def generate_verdant_ruins():
    tscn = """[gd_scene format=3]

[ext_resource type="Script" path="res://scripts/regions/region_scene.gd" id="1_script"]
[ext_resource type="PackedScene" path="res://scenes/gameplay/player.tscn" id="2_player"]
[ext_resource type="Script" path="res://scripts/gameplay/component_pickup.gd" id="3_pickup"]
[ext_resource type="Texture2D" path="res://assets/images/navigation_core.png" id="4_nav_core"]
[ext_resource type="Script" path="res://scripts/gameplay/teleport_relay.gd" id="5_relay"]
[ext_resource type="PackedScene" path="res://scenes/ui/region_map.tscn" id="6_map"]
[ext_resource type="Texture2D" path="res://assets/images/rix_portrait.png" id="7_portrait"]
[ext_resource type="Texture2D" path="res://assets/images/env/verdant_moss_ground.png" id="8_ground"]
[ext_resource type="Texture2D" path="res://assets/images/env/verdant_temple_archway.png" id="9_arch"]
[ext_resource type="Texture2D" path="res://assets/images/env/verdant_ancient_pillar.png" id="10_pillar"]
[ext_resource type="Texture2D" path="res://assets/images/env/verdant_biolum_flora.png" id="11_flora"]
[ext_resource type="Texture2D" path="res://assets/images/env/verdant_navigation_shrine.png" id="12_shrine"]

[sub_resource type="Gradient" id="Gradient_spores"]
offsets = PackedFloat32Array(0, 0.4, 0.8, 1)
colors = PackedColorArray(0.2, 1, 0.8, 0.9, 0.1, 0.8, 0.5, 0.7, 0.05, 0.4, 0.2, 0.4, 0, 0, 0, 0)

[sub_resource type="Gradient" id="Gradient_relay"]
offsets = PackedFloat32Array(0, 0.4, 1)
colors = PackedColorArray(0.2, 1, 0.7, 0.9, 0.1, 0.7, 0.5, 0.6, 0, 0.3, 0.1, 0)

[sub_resource type="CircleShape2D" id="CircleShape2D_pickup"]
radius = 52.0

[sub_resource type="CircleShape2D" id="CircleShape2D_relay"]
radius = 60.0

[sub_resource type="CapsuleShape2D" id="CapsuleShape2D_pillar"]
radius = 28.0
height = 180.0

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

[node name="VerdantRuins" type="Node2D"]
script = ExtResource("1_script")
region_id = "verdant_ruins"
region_display_name = "VERDANT RUINS"
base_lat = -4.182
base_lon = 88.354

[node name="GroundTexture" type="TextureRect" parent="."]
offset_left = -2500.0
offset_top = -1800.0
offset_right = 2500.0
offset_bottom = 1800.0
texture = ExtResource("8_ground")
stretch_mode = 1

[node name="SanctuaryAtmosphereTint" type="ColorRect" parent="."]
offset_left = -2500.0
offset_top = -1800.0
offset_right = 2500.0
offset_bottom = 1800.0
color = Color(0.05, 0.35, 0.22, 0.2)

[node name="SporeParticles" type="CPUParticles2D" parent="."]
amount = 140
lifetime = 5.0
preprocess = 2.0
emission_shape = 3
emission_rect_extents = Vector2(2200, 1500)
gravity = Vector2(10, -25)
initial_velocity_min = 10.0
initial_velocity_max = 35.0
scale_amount_min = 2.5
scale_amount_max = 6.0
color_ramp = SubResource("Gradient_spores")

[node name="TempleArchway" type="StaticBody2D" parent="."]
position = Vector2(0, -420)

[node name="Sprite2D" type="Sprite2D" parent="TempleArchway"]
scale = Vector2(1.5, 1.5)
texture = ExtResource("9_arch")

[node name="CollisionPolygon2D" type="CollisionPolygon2D" parent="TempleArchway"]
polygon = PackedVector2Array(-240, 140, -180, -20, 0, -80, 180, -20, 240, 140)

[node name="PillarLeft1" type="StaticBody2D" parent="."]
position = Vector2(-600, -120)

[node name="Sprite2D" type="Sprite2D" parent="PillarLeft1"]
texture = ExtResource("10_pillar")

[node name="CollisionShape2D" type="CollisionShape2D" parent="PillarLeft1"]
position = Vector2(0, 40)
shape = SubResource("CapsuleShape2D_pillar")

[node name="PillarLeft2" type="StaticBody2D" parent="."]
position = Vector2(-600, 220)

[node name="Sprite2D" type="Sprite2D" parent="PillarLeft2"]
texture = ExtResource("10_pillar")

[node name="CollisionShape2D" type="CollisionShape2D" parent="PillarLeft2"]
position = Vector2(0, 40)
shape = SubResource("CapsuleShape2D_pillar")

[node name="PillarRight1" type="StaticBody2D" parent="."]
position = Vector2(750, -120)

[node name="Sprite2D" type="Sprite2D" parent="PillarRight1"]
texture = ExtResource("10_pillar")
flip_h = true

[node name="CollisionShape2D" type="CollisionShape2D" parent="PillarRight1"]
position = Vector2(0, 40)
shape = SubResource("CapsuleShape2D_pillar")

[node name="PillarRight2" type="StaticBody2D" parent="."]
position = Vector2(750, 220)

[node name="Sprite2D" type="Sprite2D" parent="PillarRight2"]
texture = ExtResource("10_pillar")
flip_h = true

[node name="CollisionShape2D" type="CollisionShape2D" parent="PillarRight2"]
position = Vector2(0, 40)
shape = SubResource("CapsuleShape2D_pillar")

[node name="BiolumFlora1" type="Node2D" parent="."]
position = Vector2(-150, -180)

[node name="Sprite2D" type="Sprite2D" parent="BiolumFlora1"]
scale = Vector2(1.2, 1.2)
texture = ExtResource("11_flora")

[node name="BiolumFlora2" type="Node2D" parent="."]
position = Vector2(180, 240)

[node name="Sprite2D" type="Sprite2D" parent="BiolumFlora2"]
scale = Vector2(1.3, 1.3)
texture = ExtResource("11_flora")
flip_h = true

[node name="NavigationShrine" type="StaticBody2D" parent="."]
position = Vector2(460, -150)

[node name="Sprite2D" type="Sprite2D" parent="NavigationShrine"]
texture = ExtResource("12_shrine")

[node name="CollisionPolygon2D" type="CollisionPolygon2D" parent="NavigationShrine"]
polygon = PackedVector2Array(-130, 90, -110, 10, -50, -60, 50, -60, 110, 10, 130, 90)

[node name="ExtractionRelay" type="Area2D" parent="."]
position = Vector2(-380, 120)
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

[node name="ComponentPickup" type="Area2D" parent="."]
position = Vector2(460, -150)
script = ExtResource("3_pickup")
component_id = "navigation_core"
component_name = "Navigation Core"
prompt_message = "[E] RECOVER NAVIGATION CORE"

[node name="CollisionShape2D" type="CollisionShape2D" parent="ComponentPickup"]
unique_name_in_owner = true
shape = SubResource("CircleShape2D_pickup")

[node name="Sprite2D" type="Sprite2D" parent="ComponentPickup"]
unique_name_in_owner = true
scale = Vector2(0.18, 0.18)
texture = ExtResource("4_nav_core")

[node name="AuraParticles" type="CPUParticles2D" parent="ComponentPickup"]
unique_name_in_owner = true
amount = 20
lifetime = 1.8
emission_shape = 1
emission_sphere_radius = 24.0
gravity = Vector2(0, -25)
scale_amount_min = 3.0
scale_amount_max = 7.0
color_ramp = SubResource("Gradient_spores")

[node name="SparkParticles" type="CPUParticles2D" parent="ComponentPickup"]
unique_name_in_owner = true
emitting = false
amount = 35
lifetime = 0.5
one_shot = true
explosiveness = 0.8
emission_shape = 1
emission_sphere_radius = 20.0
gravity = Vector2(0, 0)
initial_velocity_min = 100.0
initial_velocity_max = 250.0
scale_amount_min = 3.0
scale_amount_max = 8.0
color_ramp = SubResource("Gradient_spores")

[node name="Player" parent="." instance=ExtResource("2_player")]
unique_name_in_owner = true
position = Vector2(-250, 80)

[node name="Camera2D" type="Camera2D" parent="."]
unique_name_in_owner = true
position = Vector2(-250, 80)
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
theme_override_colors/font_color = Color(0.3, 0.95, 0.5, 1)
theme_override_constants/letter_spacing = 2
theme_override_font_sizes/font_size = 14
text = "SECTOR // VERDANT RUINS"

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
theme_override_colors/font_color = Color(0.3, 0.95, 0.5, 1)
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
text = "NAVIGATION CORE SECURED."
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
    with open("scenes/regions/verdant_ruins.tscn", "w", encoding="utf-8") as f:
        f.write(tscn)
    print("Wrote scenes/regions/verdant_ruins.tscn")

def generate_frostfall_expanse():
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

[sub_resource type="Gradient" id="Gradient_snow"]
offsets = PackedFloat32Array(0, 0.3, 0.8, 1)
colors = PackedColorArray(0.9, 0.95, 1, 0.9, 0.7, 0.85, 1, 0.7, 0.4, 0.7, 0.9, 0.3, 0, 0, 0, 0)

[sub_resource type="Gradient" id="Gradient_relay"]
offsets = PackedFloat32Array(0, 0.4, 1)
colors = PackedColorArray(0.3, 0.85, 1, 0.9, 0.1, 0.6, 1, 0.6, 0, 0.2, 0.5, 0)

[sub_resource type="CircleShape2D" id="CircleShape2D_pickup"]
radius = 52.0

[sub_resource type="CircleShape2D" id="CircleShape2D_relay"]
radius = 60.0

[sub_resource type="CapsuleShape2D" id="CapsuleShape2D_monolith"]
radius = 35.0
height = 240.0

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
script = ExtResource("1_script")
region_id = "frostfall_expanse"
region_display_name = "FROSTFALL EXPANSE"
base_lat = -68.742
base_lon = 210.155

[node name="GroundTexture" type="TextureRect" parent="."]
offset_left = -2500.0
offset_top = -1800.0
offset_right = 2500.0
offset_bottom = 1800.0
texture = ExtResource("8_ground")
stretch_mode = 1

[node name="GlacialAtmosphereTint" type="ColorRect" parent="."]
offset_left = -2500.0
offset_top = -1800.0
offset_right = 2500.0
offset_bottom = 1800.0
color = Color(0.1, 0.35, 0.65, 0.22)

[node name="BlizzardParticles" type="CPUParticles2D" parent="."]
amount = 220
lifetime = 4.0
preprocess = 2.0
emission_shape = 3
emission_rect_extents = Vector2(2200, 1500)
gravity = Vector2(160, 40)
initial_velocity_min = 40.0
initial_velocity_max = 120.0
scale_amount_min = 2.5
scale_amount_max = 7.0
color_ramp = SubResource("Gradient_snow")

[node name="NorthGlacier" type="StaticBody2D" parent="."]
position = Vector2(0, -480)

[node name="Sprite2D" type="Sprite2D" parent="NorthGlacier"]
scale = Vector2(1.8, 1.8)
texture = ExtResource("9_glacier")

[node name="CollisionPolygon2D" type="CollisionPolygon2D" parent="NorthGlacier"]
polygon = PackedVector2Array(-380, 120, -320, 20, 0, -40, 320, 20, 380, 120)

[node name="SouthGlacier" type="StaticBody2D" parent="."]
position = Vector2(80, 520)

[node name="Sprite2D" type="Sprite2D" parent="SouthGlacier"]
scale = Vector2(1.8, 1.8)
texture = ExtResource("9_glacier")
flip_v = true

[node name="CollisionPolygon2D" type="CollisionPolygon2D" parent="SouthGlacier"]
polygon = PackedVector2Array(-380, -120, -320, -20, 0, 40, 320, -20, 380, -120)

[node name="MonolithLeft" type="StaticBody2D" parent="."]
position = Vector2(-650, 0)

[node name="Sprite2D" type="Sprite2D" parent="MonolithLeft"]
scale = Vector2(1.2, 1.2)
texture = ExtResource("10_monolith")

[node name="CollisionShape2D" type="CollisionShape2D" parent="MonolithLeft"]
position = Vector2(0, 30)
shape = SubResource("CapsuleShape2D_monolith")

[node name="MonolithRight" type="StaticBody2D" parent="."]
position = Vector2(780, -60)

[node name="Sprite2D" type="Sprite2D" parent="MonolithRight"]
scale = Vector2(1.3, 1.3)
texture = ExtResource("10_monolith")
flip_h = true

[node name="CollisionShape2D" type="CollisionShape2D" parent="MonolithRight"]
position = Vector2(0, 30)
shape = SubResource("CapsuleShape2D_monolith")

[node name="FrozenDebris1" type="Node2D" parent="."]
position = Vector2(-120, 240)

[node name="Sprite2D" type="Sprite2D" parent="FrozenDebris1"]
scale = Vector2(1.2, 1.2)
texture = ExtResource("11_debris")

[node name="FrozenDebris2" type="Node2D" parent="."]
position = Vector2(180, -220)

[node name="Sprite2D" type="Sprite2D" parent="FrozenDebris2"]
scale = Vector2(1.2, 1.2)
texture = ExtResource("11_debris")
flip_h = true

[node name="CryoFacility" type="StaticBody2D" parent="."]
position = Vector2(450, -150)

[node name="Sprite2D" type="Sprite2D" parent="CryoFacility"]
texture = ExtResource("12_facility")

[node name="CollisionPolygon2D" type="CollisionPolygon2D" parent="CryoFacility"]
polygon = PackedVector2Array(-140, 90, -120, 20, -60, -60, 60, -60, 120, 20, 140, 90)

[node name="ExtractionRelay" type="Area2D" parent="."]
position = Vector2(-380, 120)
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

[node name="ComponentPickup" type="Area2D" parent="."]
position = Vector2(450, -150)
script = ExtResource("3_pickup")
component_id = "quantum_power_cell"
component_name = "Quantum Power Cell"
prompt_message = "[E] RECOVER QUANTUM POWER CELL"

[node name="CollisionShape2D" type="CollisionShape2D" parent="ComponentPickup"]
unique_name_in_owner = true
shape = SubResource("CircleShape2D_pickup")

[node name="Sprite2D" type="Sprite2D" parent="ComponentPickup"]
unique_name_in_owner = true
scale = Vector2(0.18, 0.18)
texture = ExtResource("4_power_cell")

[node name="AuraParticles" type="CPUParticles2D" parent="ComponentPickup"]
unique_name_in_owner = true
amount = 20
lifetime = 1.8
emission_shape = 1
emission_sphere_radius = 24.0
gravity = Vector2(0, -25)
scale_amount_min = 3.0
scale_amount_max = 7.0
color_ramp = SubResource("Gradient_snow")

[node name="SparkParticles" type="CPUParticles2D" parent="ComponentPickup"]
unique_name_in_owner = true
emitting = false
amount = 35
lifetime = 0.5
one_shot = true
explosiveness = 0.8
emission_shape = 1
emission_sphere_radius = 20.0
gravity = Vector2(0, 0)
initial_velocity_min = 100.0
initial_velocity_max = 250.0
scale_amount_min = 3.0
scale_amount_max = 8.0
color_ramp = SubResource("Gradient_snow")

[node name="Player" parent="." instance=ExtResource("2_player")]
unique_name_in_owner = true
position = Vector2(-250, 80)

[node name="Camera2D" type="Camera2D" parent="."]
unique_name_in_owner = true
position = Vector2(-250, 80)
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
    print("Wrote scenes/regions/frostfall_expanse.tscn")

generate_ember_wastes()
generate_verdant_ruins()
generate_frostfall_expanse()
print("All 3 detailed regions generated successfully!")
