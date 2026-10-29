# Gera os ícones PNG do Semiose: fundo índigo e o triângulo semiótico (signo, objeto, interpretante) em branco.
# badge-96.png é o ícone pequeno, só o desenho branco, que o Android mostra na barra de avisos.
Add-Type -AssemblyName System.Drawing
$out = Join-Path $PSScriptRoot 'icons'
New-Item -ItemType Directory -Force $out | Out-Null

# o mesmo desenho do app (viewBox 24x24): três linhas e três círculos
function Draw-Mark($g, [single]$s, [single]$frac, [System.Drawing.Color]$color, [System.Drawing.Color]$dotFill) {
  $k = $frac * $s / 19.2
  $ox = $s / 2 - 12 * $k
  $oy = $s / 2 - 11.1 * $k
  $P = { param($x, $y) New-Object System.Drawing.PointF ([single]($ox + $x * $k)), ([single]($oy + $y * $k)) }
  $pen = New-Object System.Drawing.Pen $color, ([single](1.6 * $k))
  $pen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
  $pen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
  $g.DrawLine($pen, (& $P 10.77 6.89), (& $P 6.23 15.31))
  $g.DrawLine($pen, (& $P 13.23 6.89), (& $P 17.77 15.31))
  $g.DrawLine($pen, (& $P 7.6 17.6), (& $P 16.4 17.6))
  $r = 2.6 * $k
  $top = & $P 12 4.6
  $g.FillEllipse((New-Object System.Drawing.SolidBrush $dotFill), [single]($top.X - $r), [single]($top.Y - $r), [single](2 * $r), [single](2 * $r))
  foreach ($c in @((& $P 5 17.6), (& $P 19 17.6))) {
    $g.DrawEllipse($pen, [single]($c.X - $r), [single]($c.Y - $r), [single](2 * $r), [single](2 * $r))
  }
}

function New-Icon([int]$s, [string]$path) {
  $bmp = New-Object System.Drawing.Bitmap $s, $s
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
  $bg = New-Object System.Drawing.Drawing2D.LinearGradientBrush (New-Object System.Drawing.PointF 0, 0), (New-Object System.Drawing.PointF $s, $s), ([System.Drawing.Color]::FromArgb(255, 92, 112, 222)), ([System.Drawing.Color]::FromArgb(255, 47, 62, 160))
  $g.FillRectangle($bg, 0, 0, $s, $s)
  # brilho suave em cima à esquerda
  $gp = New-Object System.Drawing.Drawing2D.GraphicsPath
  $gp.AddEllipse([single](-0.35 * $s), [single](-0.45 * $s), [single](1.1 * $s), [single](1.0 * $s))
  $br = New-Object System.Drawing.Drawing2D.PathGradientBrush $gp
  $br.CenterColor = [System.Drawing.Color]::FromArgb(70, 222, 224, 255)
  $br.SurroundColors = @([System.Drawing.Color]::FromArgb(0, 222, 224, 255))
  $g.FillPath($br, $gp)
  Draw-Mark $g $s 0.56 ([System.Drawing.Color]::FromArgb(255, 255, 255, 255)) ([System.Drawing.Color]::FromArgb(255, 255, 216, 238))
  $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
  $g.Dispose(); $bmp.Dispose()
}

function New-Badge([int]$s, [string]$path) {
  $bmp = New-Object System.Drawing.Bitmap $s, $s
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $g.Clear([System.Drawing.Color]::Transparent)
  $white = [System.Drawing.Color]::FromArgb(255, 255, 255, 255)
  Draw-Mark $g $s 0.8 $white $white
  $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
  $g.Dispose(); $bmp.Dispose()
}

New-Icon 180 (Join-Path $out 'icon-180.png')
New-Icon 192 (Join-Path $out 'icon-192.png')
New-Icon 512 (Join-Path $out 'icon-512.png')
New-Badge 96 (Join-Path $out 'badge-96.png')
Write-Host 'Ícones gerados em' $out
