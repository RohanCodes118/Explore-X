Add-Type -AssemblyName System.Drawing
$bmp = New-Object System.Drawing.Bitmap("c:\Users\rohan\OneDrive\Documents\explore-x\assets\images\Rix Sprites 2.png")
$outDir = "c:\Users\rohan\OneDrive\Documents\explore-x\assets\images\rix\crash_recovery"
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

# In Row 4 (Y: 740..900):
# 1. Prone on ground 1: X=540..760, Y=780..880
# 2. Prone on ground 2: X=770..1040, Y=780..880
# 3. Kneeling pushing up: X=270..410, Y=740..880
# 4. Crouched: X=130..260, Y=740..880

function Crop-Rect($bmp, $rect, $savePath) {
    # Trim transparent borders
    $minX = 9999; $maxX = -1; $minY = 9999; $maxY = -1
    for ($y = $rect.Y; $y -lt ($rect.Y + $rect.Height); $y++) {
        for ($x = $rect.X; $x -lt ($rect.X + $rect.Width); $x++) {
            if ($x -lt $bmp.Width -and $y -lt $bmp.Height) {
                if ($bmp.GetPixel($x, $y).A -gt 25) {
                    if ($x -lt $minX) { $minX = $x }
                    if ($x -gt $maxX) { $maxX = $x }
                    if ($y -lt $minY) { $minY = $y }
                    if ($y -gt $maxY) { $maxY = $y }
                }
            }
        }
    }
    if ($maxX -ge $minX -and $maxY -ge $minY) {
        $w = $maxX - $minX + 1
        $h = $maxY - $minY + 1
        $target = New-Object System.Drawing.Bitmap($w, $h, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
        $g = [System.Drawing.Graphics]::FromImage($target)
        $g.Clear([System.Drawing.Color]::Transparent)
        $g.DrawImage($bmp, 0, 0, (New-Object System.Drawing.Rectangle($minX, $minY, $w, $h)), [System.Drawing.GraphicsUnit]::Pixel)
        $g.Dispose()
        $target.Save($savePath, [System.Drawing.Imaging.ImageFormat]::Png)
        $target.Dispose()
        Write-Output "Saved $savePath (${w}x${h})"
    }
}

Crop-Rect $bmp (New-Object System.Drawing.Rectangle(540, 780, 240, 110)) (Join-Path $outDir "recovery_00_prone.png")
Crop-Rect $bmp (New-Object System.Drawing.Rectangle(780, 780, 270, 110)) (Join-Path $outDir "recovery_01_stirring.png")
Crop-Rect $bmp (New-Object System.Drawing.Rectangle(410, 740, 140, 140)) (Join-Path $outDir "recovery_02_kneeling.png")
Crop-Rect $bmp (New-Object System.Drawing.Rectangle(270, 740, 140, 140)) (Join-Path $outDir "recovery_03_rising.png")
Crop-Rect $bmp (New-Object System.Drawing.Rectangle(130, 740, 140, 140)) (Join-Path $outDir "recovery_04_crouched.png")

# Also crop an expressive portrait from Row 5 (X=10..100, Y=885..995)
Crop-Rect $bmp (New-Object System.Drawing.Rectangle(15, 885, 85, 105)) "c:\Users\rohan\OneDrive\Documents\explore-x\assets\images\rix_portrait_stern.png"
Crop-Rect $bmp (New-Object System.Drawing.Rectangle(180, 885, 85, 105)) "c:\Users\rohan\OneDrive\Documents\explore-x\assets\images\rix_portrait_focused.png"

$bmp.Dispose()
