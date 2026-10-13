Add-Type -AssemblyName System.Drawing
$bmp = New-Object System.Drawing.Bitmap("c:\Users\rohan\OneDrive\Documents\explore-x\assets\images\Rix Sprites.png")
$outDir = "c:\Users\rohan\OneDrive\Documents\explore-x\assets\images\rix\attack_side"
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

$attackRects = @(
    (New-Object System.Drawing.Rectangle(10, 750, 115, 150)),
    (New-Object System.Drawing.Rectangle(120, 750, 115, 150)),
    (New-Object System.Drawing.Rectangle(230, 750, 120, 150)),
    (New-Object System.Drawing.Rectangle(345, 750, 130, 150))
)

for ($i = 0; $i -lt $attackRects.Count; $i++) {
    $r = $attackRects[$i]
    $dest = New-Object System.Drawing.Bitmap(150, 170, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($dest)
    $g.Clear([System.Drawing.Color]::Transparent)
    $g.DrawImage($bmp, 10, 10, $r, [System.Drawing.GraphicsUnit]::Pixel)
    $g.Dispose()
    $dest.Save((Join-Path $outDir ("frame_{0:D2}.png" -f $i)), [System.Drawing.Imaging.ImageFormat]::Png)
    $dest.Dispose()
}

# Also let's extract RUN (SIDE) accurately: 5 frames located at X=480..960, Y=415..565
$runSideDir = "c:\Users\rohan\OneDrive\Documents\explore-x\assets\images\rix\run_side"
New-Item -ItemType Directory -Force -Path $runSideDir | Out-Null
$runRects = @(
    (New-Object System.Drawing.Rectangle(485, 415, 95, 150)),
    (New-Object System.Drawing.Rectangle(580, 415, 95, 150)),
    (New-Object System.Drawing.Rectangle(680, 415, 95, 150)),
    (New-Object System.Drawing.Rectangle(780, 415, 95, 150)),
    (New-Object System.Drawing.Rectangle(875, 415, 95, 150))
)
for ($i = 0; $i -lt $runRects.Count; $i++) {
    $r = $runRects[$i]
    $dest = New-Object System.Drawing.Bitmap(120, 170, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($dest)
    $g.Clear([System.Drawing.Color]::Transparent)
    $g.DrawImage($bmp, 10, 10, $r, [System.Drawing.GraphicsUnit]::Pixel)
    $g.Dispose()
    $dest.Save((Join-Path $runSideDir ("frame_{0:D2}.png" -f $i)), [System.Drawing.Imaging.ImageFormat]::Png)
    $dest.Dispose()
}

$bmp.Dispose()
Write-Output "Extracted attack_side (4 frames) and run_side (5 frames)."
