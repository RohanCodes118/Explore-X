Add-Type -AssemblyName System.Drawing

$size = 1024
$bmp = New-Object System.Drawing.Bitmap($size, $size, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$cx = $size / 2.0
$cy = $size / 2.0
$radius = 380.0

# Generate an icy-cyan / sapphire gas giant with atmospheric limb glow and layered bands
for ($y = 0; $y -lt $size; $y++) {
    for ($x = 0; $x -lt $size; $x++) {
        $dx = ($x - $cx)
        $dy = ($y - $cy)
        $dist = [Math]::Sqrt($dx * $dx + $dy * $dy)
        
        # Outer atmospheric glow halo
        if ($dist -gt $radius -and $dist -lt ($radius + 70.0)) {
            $glowT = 1.0 - (($dist - $radius) / 70.0)
            $glowAlpha = [int]([Math]::Pow($glowT, 2.0) * 140.0)
            # Rim lighting from upper-right
            $lightAngle = [Math]::Atan2(-$dy, $dx)
            $lightFacing = [Math]::Max(0.0, [Math]::Cos($lightAngle - 0.7))
            $glowAlpha = [int]($glowAlpha * (0.3 + 0.7 * $lightFacing))
            if ($glowAlpha -gt 0) {
                $bmp.SetPixel($x, $y, [System.Drawing.Color]::FromArgb($glowAlpha, 60, 180, 255))
            }
        }
        elseif ($dist -le $radius) {
            # 3D sphere normal
            $nx = $dx / $radius
            $ny = $dy / $radius
            $nz = [Math]::Sqrt([Math]::Max(0.0, 1.0 - ($nx * $nx + $ny * $ny)))
            
            # Light direction: upper right (0.6, -0.5, 0.6) normalized
            $lx = 0.55; $ly = -0.45; $lz = 0.7
            $diffuse = [Math]::Max(0.0, $nx * $lx + $ny * $ly + $nz * $lz)
            
            # Planetary latitude bands + turbulence
            $lat = ($ny * 6.0) + 0.15 * [Math]::Sin($nx * 12.0) + 0.08 * [Math]::Cos($nx * 24.0 + $ny * 8.0)
            $band = 0.5 + 0.5 * [Math]::Sin($lat * [Math]::PI)
            
            # Base colors: Deep navy, teal, and luminous cyan
            $r = (18.0 * (1.0 - $band) + 35.0 * $band) * $diffuse
            $g = (65.0 * (1.0 - $band) + 145.0 * $band) * $diffuse
            $b = (130.0 * (1.0 - $band) + 240.0 * $band) * $diffuse
            
            # Fresnel atmospheric rim
            $fresnel = [Math]::Pow(1.0 - $nz, 3.0)
            $r += 70.0 * $fresnel
            $g += 180.0 * $fresnel
            $b += 255.0 * $fresnel
            
            $clampedR = [Math]::Min(255, [Math]::Max(0, [int]$r))
            $clampedG = [Math]::Min(255, [Math]::Max(0, [int]$g))
            $clampedB = [Math]::Min(255, [Math]::Max(0, [int]$b))
            
            $bmp.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, $clampedR, $clampedG, $clampedB))
        }
    }
}

$savePath = "c:\Users\rohan\OneDrive\Documents\explore-x\assets\images\intermediate_planet.png"
$bmp.Save($savePath, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
Write-Output "Generated intermediate_planet.png successfully."
