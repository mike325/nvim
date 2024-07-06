if ( -Not (Get-Command "git.exe" -ErrorAction SilentlyContinue) ) {
    Write-Host " Missing git executable" -ForegroundColor Red
    exit 1
}

if ( -Not (Get-Command "vim.exe" -ErrorAction SilentlyContinue) ) {
    Write-Host " Missing vim executable" -ForegroundColor Red
    exit 1
}

if ( -Not (Test-Path("$env:USERPROFILE/vimfiles")) ) {
    git clone --branch=vim --recursive "https://github.com/mike325/nvim.git" "$env:USERPROFILE/vimfiles"
}

vim -N --cmd 'let g:bare=1' --cmd version -Es -V2 -c 'autocmd VimEnter * qa!'
exit $LASTEXITCODE
