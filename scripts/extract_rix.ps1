Add-Type -AssemblyName System.Drawing

$src1 = "c:\Users\rohan\OneDrive\Documents\explore-x\assets\images\Rix Sprites.png"
$src2 = "c:\Users\rohan\OneDrive\Documents\explore-x\assets\images\Rix Sprites 2.png"
$outBase = "c:\Users\rohan\OneDrive\Documents\explore-x\assets\images\rix"
New-Item -ItemType Directory -Force -Path $outBase | Out-Null

$bmp1 = New-Object System.Drawing.Bitmap($src1)

# Helper to find boxes in X range
function Get-SubBoxes($bmp, $minY, $maxY, $minX, $maxX, $minW = 20) {
    $colHasPixels = @()
    for ($x = $minX; $x -le $maxX; $x++) {
        $found = $false
        for ($y = $minY; $y -le $maxY; $y++) {
            if ($bmp.GetPixel($x, $y).A -gt 25) { $found = $true; break }
        }
        if ($found) { $colHasPixels += $x }
    }
    
    $boxes = @()
    $startX = -1
    $prevX = -1
    foreach ($x in $colHasPixels) {
        if ($startX -eq -1) { $startX = $x; $prevX = $x; continue }
        if ($x - $prevX -gt 5) {
            $w = $prevX - $startX + 1
            if ($w -ge $minW) { $boxes += @{ X = $startX; W = $w; Right = $prevX } }
            $startX = $x
        }
        $prevX = $x
    }
    if ($startX -ne -1) {
        $w = $prevX - $startX + 1
        if ($w -ge $minW) { $boxes += @{ X = $startX; W = $w; Right = $prevX } }
    }
    return $boxes
}

function Save-Frames($bmp, $boxes, $minY, $maxY, $animName, $targetW = 120, $targetH = 170, $footY = 160) {
    $dir = Join-Path $outBase $animName
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
    
    for ($i = 0; $i -lt $boxes.Count; $i++) {
        $box = $boxes[$i]
        $tightMinX = 9999; $tightMaxX = -1; $tightMinY = 9999; $tightMaxY = -1
        for ($y = $minY; $y -le $maxY; $y++) {
            for ($x = $box.X; $x -le $box.Right; $x++) {
                if ($bmp.GetPixel($x, $y).A -gt 25) {
                    if ($x -lt $tightMinX) { $tightMinX = $x }
                    if ($x -gt $tightMaxX) { $tightMaxX = $x }
                    if ($y -lt $tightMinY) { $tightMinY = $y }
                    if ($y -gt $tightMaxY) { $tightMaxY = $y }
                }
            }
        }
        if ($tightMaxX -ge $tightMinX -and $tightMaxY -ge $tightMinY) {
            $charW = $tightMaxX - $tightMinX + 1
            $charH = $tightMaxY - $tightMinY + 1
            
            $destBmp = New-Object System.Drawing.Bitmap($targetW, $targetH, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
            $g = [System.Drawing.Graphics]::FromImage($destBmp)
            $g.Clear([System.Drawing.Color]::Transparent)
            
            $destX = [int](($targetW - $charW) / 2)
            $destY = $footY - $charH
            
            $srcRect = New-Object System.Drawing.Rectangle($tightMinX, $tightMinY, $charW, $charH)
            $destRect = New-Object System.Drawing.Rectangle($destX, $destY, $charW, $charH)
            $g.DrawImage($bmp, $destRect, $srcRect, [System.Drawing.GraphicsUnit]::Pixel)
            $g.Dispose()
            
            $outPath = Join-Path $dir ("frame_{0:D2}.png" -f $i)
            $destBmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
            $destBmp.Dispose()
        }
    }
    Write-Output "Saved $animName ($($boxes.Count) frames)"
}

# 1. IDLE (Y: 38..183)
# Down: X=0..500; Side: X=500..1000; Up: X=1000..1536
Save-Frames $bmp1 (Get-SubBoxes $bmp1 38 183 0 500) 38 183 "idle_down"
Save-Frames $bmp1 (Get-SubBoxes $bmp1 38 183 500 1000) 38 183 "idle_side"
Save-Frames $bmp1 (Get-SubBoxes $bmp1 38 183 1000 1536) 38 183 "idle_up"

# 2. WALK (Y: 220..370)
Save-Frames $bmp1 (Get-SubBoxes $bmp1 220 370 0 500) 220 370 "walk_down"
Save-Frames $bmp1 (Get-SubBoxes $bmp1 220 370 500 1000) 220 370 "walk_side"
Save-Frames $bmp1 (Get-SubBoxes $bmp1 220 370 1000 1536) 220 370 "walk_up"

# 3. RUN (Y: 410..570)
Save-Frames $bmp1 (Get-SubBoxes $bmp1 410 570 0 500) 410 570 "run_down"
Save-Frames $bmp1 (Get-SubBoxes $bmp1 410 570 500 1000) 410 570 "run_side"
Save-Frames $bmp1 (Get-SubBoxes $bmp1 410 570 1000 1536) 410 570 "run_up"

# 4. Row 4 (Y: 580..735)
# JUMP (SIDE): X=0..500
Save-Frames $bmp1 (Get-SubBoxes $bmp1 580 735 0 500) 580 735 "jump_side"
# CROUCH: Down (X=500..800), Side (X=800..1150), Up (X=1150..1536)
Save-Frames $bmp1 (Get-SubBoxes $bmp1 580 735 500 800) 580 735 "crouch_down"
Save-Frames $bmp1 (Get-SubBoxes $bmp1 580 735 800 1150) 580 735 "crouch_side"
Save-Frames $bmp1 (Get-SubBoxes $bmp1 580 735 1150 1536) 580 735 "crouch_up"

# 5. Row 5 (Y: 745..905)
# ATTACK (SIDE): X=0..450
Save-Frames $bmp1 (Get-SubBoxes $bmp1 745 905 0 450) 745 905 "attack_side" 160 170 160
# INTERACT / USE (DOWN): X=450..820
Save-Frames $bmp1 (Get-SubBoxes $bmp1 745 905 450 820) 745 905 "interact_down" 140 170 160
# HURT (DOWN): X=820..1150
Save-Frames $bmp1 (Get-SubBoxes $bmp1 745 905 820 1150) 745 905 "hurt_down"
# DEATH (DOWN): X=1150..1536
Save-Frames $bmp1 (Get-SubBoxes $bmp1 745 905 1150 1536) 745 905 "death_down" 160 170 160

# 6. Extract Portrait from Row 6 (X=170..270, Y=915..1010)
$portraitBox = New-Object System.Drawing.Rectangle(175, 915, 95, 95)
$portraitBmp = $bmp1.Clone($portraitBox, $bmp1.PixelFormat)
$portraitBmp.Save("c:\Users\rohan\OneDrive\Documents\explore-x\assets\images\rix_portrait.png", [System.Drawing.Imaging.ImageFormat]::Png)
$portraitBmp.Dispose()
Write-Output "Saved rix_portrait.png"

$bmp1.Dispose()
