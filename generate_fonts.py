import os

fonts = {
    "cinzel": ("Cinzel-Bold.woff2", ["Arial", "Helvetica", "sans-serif"]),
    "cormorant": ("CormorantGaramond-SemiBold.woff2", ["Georgia", "Times New Roman", "serif"]),
    "source_serif": ("SourceSerifPro-Regular.woff2", ["Georgia", "Times New Roman", "serif"]),
    "open_sans": ("OpenSans-SemiBold.woff2", ["Arial", "Helvetica", "sans-serif"]),
    "eb_garamond": ("EBGaramond-Regular.woff2", ["Georgia", "Times New Roman", "serif"]),
    "inter": ("Inter-Regular.woff2", ["Arial", "Helvetica", "sans-serif"]),
    "roboto_mono": ("RobotoMono-Regular.woff2", ["Courier New", "monospace"])
}

os.makedirs("assets/fonts", exist_ok=True)

for uid_name, (file_name, fallbacks) in fonts.items():
    fallback_array = ", ".join([f'"{f}"' for f in fallbacks])
    
    # Create SystemFont for fallback
    sys_font_tres = f"""[gd_resource type="SystemFont" format=3]
[resource]
font_names = PackedStringArray({fallback_array})
subpixel_positioning = 0
"""
    with open(f"assets/fonts/fallback_{uid_name}.tres", "w", encoding="utf-8") as f:
        f.write(sys_font_tres)
        
    # Create FontVariation
    font_tres = f"""[gd_resource type="FontVariation" load_steps=3 format=3]

[ext_resource type="FontFile" path="res://assets/fonts/{file_name}" id="1_base"]
[ext_resource type="SystemFont" path="res://assets/fonts/fallback_{uid_name}.tres" id="2_fallback"]

[resource]
base_font = ExtResource("1_base")
fallbacks = Array[Font]([ExtResource("2_fallback")])
"""
    with open(f"assets/fonts/{uid_name}.tres", "w", encoding="utf-8") as f:
        f.write(font_tres)

print("Font resources created.")
