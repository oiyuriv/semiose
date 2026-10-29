# Gera lembrete/HHMM.ics (das 6h às 23h30, de meia em meia hora): um evento diário com alarme,
# que o perfil do app oferece para pôr no calendário do celular. A hora é "flutuante" (sem fuso),
# então vale a hora local de quem adiciona.
param([string]$AppUrl = 'https://oiyuriv.github.io/semiose/')
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$out = [IO.Path]::GetFullPath((Join-Path $here '../lembrete'))
New-Item -ItemType Directory -Force $out | Out-Null
$utf8 = New-Object Text.UTF8Encoding $false
$n = 0
for ($h = 6; $h -le 23; $h++) {
  foreach ($m in 0, 30) {
    $hm = '{0:D2}{1:D2}' -f $h, $m
    $lines = @(
      'BEGIN:VCALENDAR', 'VERSION:2.0', 'PRODID:-//Semiose//Lembrete//PT', 'CALSCALE:GREGORIAN', 'METHOD:PUBLISH',
      'BEGIN:VEVENT',
      "UID:semiose-lembrete-$hm@semiose",
      'DTSTAMP:20261029T120000Z',
      "DTSTART:20261029T$($hm)00",
      'DURATION:PT15M',
      'RRULE:FREQ=DAILY',
      'SUMMARY:Hora da leitura · Semiose',
      "DESCRIPTION:Sua seleção de hoje está pronta: $AppUrl",
      "URL:$AppUrl",
      'BEGIN:VALARM', 'ACTION:DISPLAY', 'DESCRIPTION:Hora da leitura no Semiose', 'TRIGGER:PT0M', 'END:VALARM',
      'END:VEVENT', 'END:VCALENDAR'
    )
    [IO.File]::WriteAllText((Join-Path $out "$hm.ics"), ($lines -join "`r`n") + "`r`n", $utf8)
    $n++
  }
}
Write-Host "$n lembretes gravados em $out"
