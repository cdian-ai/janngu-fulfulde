# rename-syllables-v6-2026-09-01.ps1
#
# Copies the recorded syllable clips into audio\syl\ under the names the course
# asks for: c<NN>v<N><l|s>.m4a
#
# Why v6 -- two real bugs, both found by running the script rather than reading it:
#
#   1. PowerShell variable names are CASE-INSENSITIVE, so the loop variable
#      $cons and the letter table $CONS were the same variable. The first file
#      processed replaced the whole 27-letter table with a single letter, and
#      every lookup from then on returned 0. That is why 256 clips landed on 50
#      names in v2, and why everything collapsed to c00 in v5. The loop variable
#      is now $letter.
#
#   2. The comma operator binds tighter than +, so @($LONGDIR + "aa", "a", $true)
#      was parsed as $LONGDIR + @("aa","a",$true) -- one joined string instead of
#      three items. That is why all five long-vowel folders reported MISSING.
#      The concatenation is now parenthesised.
#
# The script also contains no non-ASCII characters: the Fulfulde letters are
# built from Unicode code points at runtime, so no download or save can corrupt
# the table. It prints what it worked out before it copies anything.
#
# Copies only. Nothing in sounds\ is touched.

$ErrorActionPreference = "Stop"

# ---- the Fulfulde letters, built from code points so encoding cannot break them
$B_HOOK = [string][char]0x0253   # b with hook
$D_HOOK = [string][char]0x0257   # d with hook
$Y_HOOK = [string][char]0x01B4   # y with hook
$ENG    = [string][char]0x014B   # eng
$NTILDE = [string][char]0x00F1   # n with tilde
$RQUOTE = [string][char]0x2019   # right single quote, sometimes used for glottal

# the build's own order, from CONS in index.html -- do not reorder
$CONS = @("b", $B_HOOK, "c", "d", $D_HOOK, "f", "g", "h", "j", "k", "l", "m",
          "mb", "n", "nd", "ng", "nj", $ENG, $NTILDE, "p", "r", "s", "t",
          "w", "y", $Y_HOOK, "'")
$VOW = @("a", "e", "i", "o", "u")

$LONGDIR = "alkule_juutu" + $D_HOOK + "e_"

# folder -> vowel, long?
$FOLDERS = @(
  @("pecce_alkule_a",  "a", $false),
  @("pecce_alkule_e",  "e", $false),
  @("pecce_alkule_i",  "i", $false),
  @("pecce_alkule_o",  "o", $false),
  @("pecce_alkule_u",  "u", $false),
  @(($LONGDIR + "aa"),   "a", $true),
  @(($LONGDIR + "ee"),   "e", $true),
  @(($LONGDIR + "ii"),   "i", $true),
  @(($LONGDIR + "oo"),   "o", $true),
  @(($LONGDIR + "uu"),   "u", $true)
)

# ---- find the recordings, wherever they live
$SRC = $null
foreach ($cand in @("sounds", "..\sounds", "..\..\sounds", "..\..\..\sounds")) {
  $try = Join-Path $PWD $cand
  if (Test-Path (Join-Path $try "pecce_alkule_a")) { $SRC = (Resolve-Path $try).Path; break }
}
if (-not $SRC) {
  Write-Host "Could not find a sounds\ folder containing pecce_alkule_a." -ForegroundColor Red
  Write-Host "Looked in: .\sounds, ..\sounds, ..\..\sounds, ..\..\..\sounds" -ForegroundColor Red
  exit 1
}
Write-Host ""
Write-Host "Reading recordings from: $SRC" -ForegroundColor Cyan

# ---- prove the letter table survived, before anything is copied
Write-Host "Letter table (27 expected, got $($CONS.Count)):" -ForegroundColor Cyan
Write-Host ("   " + ($CONS -join " ")) -ForegroundColor Cyan
if ($CONS.Count -ne 27) {
  Write-Host "Letter table is the wrong size. Stopping." -ForegroundColor Red
  exit 1
}

$out = Join-Path $PWD "audio\syl"
New-Item -ItemType Directory -Force -Path $out | Out-Null

$copied = 0
$skipped = @()
$unmatched = @()
$seen = @{}
$sample = @()

foreach ($entry in $FOLDERS) {
  $folder = $entry[0]
  $vowel  = $entry[1]
  $long   = $entry[2]

  $dir = Join-Path $SRC $folder
  if (-not (Test-Path $dir)) { $unmatched += "MISSING FOLDER: $folder"; continue }

  if ($long) { $vstr = $vowel + $vowel; $len = "l" } else { $vstr = $vowel; $len = "s" }
  $vi = [array]::IndexOf($VOW, $vowel)

  $folderCopied = 0

  foreach ($f in Get-ChildItem $dir -File) {
    if ($f.Extension -ne ".m4a") { continue }        # leaves .story alone
    $stem = $f.BaseName

    # second takes: yaa2, nhoo2 -- keep the first, note the rest
    if ($stem -match '\d$') { $skipped += "$folder\$($f.Name)  (second take)"; continue }

    # strip the vowel, then any apostrophe; what is left is the consonant
    $letter = $stem.Replace($vstr, "")
    $letter = $letter.Replace("'", "").Replace($RQUOTE, "")
    $letter = $letter.ToLowerInvariant()

    # nh is how n-tilde was typed on the phone; empty means the glottal stop
    if ($letter -eq "nh") { $letter = $NTILDE }
    if ($letter -eq "")   { $letter = "'" }

    $ci = [array]::IndexOf($CONS, $letter)
    if ($ci -lt 0) { $unmatched += "$folder\$($f.Name)  -> '$letter' is not one of the 27"; continue }

    $name = "c{0:d2}v{1}{2}.m4a" -f $ci, $vi, $len
    if ($seen.ContainsKey($name)) {
      $unmatched += "$folder\$($f.Name)  -> $name  ALREADY WRITTEN by $($seen[$name])"
      continue
    }
    $seen[$name] = "$folder\$($f.Name)"

    if ($sample.Count -lt 6) { $sample += "   $($f.Name)  ->  $letter + $vstr  ->  $name" }

    Copy-Item $f.FullName (Join-Path $out $name) -Force
    $copied++
    $folderCopied++
  }

  Write-Host ("  {0,-24} {1,3} copied" -f $folder, $folderCopied)
}

Write-Host ""
Write-Host "How it read the first few:" -ForegroundColor DarkGray
$sample | ForEach-Object { Write-Host $_ -ForegroundColor DarkGray }

Write-Host ""
Write-Host "Copied $copied clips into audio\syl\" -ForegroundColor Green
Write-Host "Distinct names written: $($seen.Count)" -ForegroundColor Green

if ($skipped.Count) {
  Write-Host ""
  Write-Host "Skipped $($skipped.Count) second take(s):" -ForegroundColor DarkGray
  $skipped | ForEach-Object { Write-Host "   $_" -ForegroundColor DarkGray }
}

if ($unmatched.Count) {
  Write-Host ""
  Write-Host "$($unmatched.Count) file(s) could not be placed:" -ForegroundColor Yellow
  $unmatched | ForEach-Object { Write-Host "   $_" -ForegroundColor Yellow }
}

# ---- what a complete set would be, and what is absent
Write-Host ""
$missing = @()
for ($c = 0; $c -lt $CONS.Count; $c++) {
  for ($v = 0; $v -lt $VOW.Count; $v++) {
    foreach ($l in @("s", "l")) {
      $n = "c{0:d2}v{1}{2}.m4a" -f $c, $v, $l
      if (-not $seen.ContainsKey($n)) {
        if ($l -eq "l") { $syl = $CONS[$c] + $VOW[$v] + $VOW[$v] } else { $syl = $CONS[$c] + $VOW[$v] }
        $missing += ("{0}  =  {1}" -f $n, $syl)
      }
    }
  }
}
Write-Host "Complete set is 270 (27 consonants x 5 vowels x 2 lengths)."
if ($missing.Count -eq 0) {
  Write-Host "Nothing missing." -ForegroundColor Green
} else {
  Write-Host "$($missing.Count) still to record:" -ForegroundColor Cyan
  $missing | ForEach-Object { Write-Host "   $_" -ForegroundColor Cyan }
}
Write-Host ""
