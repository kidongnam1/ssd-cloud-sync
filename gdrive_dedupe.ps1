[Console]::OutputEncoding = [Text.Encoding]::UTF8
$out = "$env:USERPROFILE\Desktop\gdrive_duplicates.txt"
"" | Out-File $out -Encoding UTF8

$big = @('D:', 'F:', 'G:', 'Takeout', 'old  사진')
$dirs = rclone lsf "gdrive:" --dirs-only | ForEach-Object { $_.TrimEnd('/') }

Write-Host "=== [1/3] 업무 폴더 24개 초고속 중복 검사 시작 ===" -ForegroundColor Green
foreach ($d in ($dirs | Where-Object { $big -notcontains $_ })) {
    Write-Host "[FAST] $(Get-Date -Format 'HH:mm:ss') gdrive:$d" -ForegroundColor Cyan
    Add-Content $out "=== [$d] ===" -Encoding UTF8
    rclone dedupe --by-hash --dedupe-mode list "gdrive:$d" --tpslimit 8 --checkers 4 2>&1 | Tee-Object -FilePath $out -Append
}

Write-Host "=== [2/3] 최상위(루트) 파일 중복 검사 시작 ===" -ForegroundColor Green
Add-Content $out "=== [ROOT] ===" -Encoding UTF8
rclone dedupe --by-hash --dedupe-mode list "gdrive:" --max-depth 1 --tpslimit 8 2>&1 | Tee-Object -FilePath $out -Append

Write-Host "=== [3/3] 대용량 백업 폴더(D:, F:, G:, Takeout, old 사진) 실시간 검사 ===" -ForegroundColor Yellow
foreach ($d in ($dirs | Where-Object { $big -contains $_ })) {
    Write-Host "[BIG]  $(Get-Date -Format 'HH:mm:ss') gdrive:$d" -ForegroundColor Yellow
    Add-Content $out "=== [$d] ===" -Encoding UTF8
    rclone dedupe --by-hash --dedupe-mode list "gdrive:$d" --tpslimit 8 --checkers 4 -v 2>&1 | ForEach-Object {
        if ($_ -match 'Reading|Found') { Write-Host $_ -ForegroundColor DarkGray }
        $_
    } | Tee-Object -FilePath $out -Append
}

Write-Host "=== 전체 중복 검사 완료! 메모장을 엽니다 ===" -ForegroundColor Green
notepad $out