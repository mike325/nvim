if ( -Not (Get-Command "git.exe" -ErrorAction SilentlyContinue) ) {
    Write-Host " Missing git executable" -ForegroundColor Red
    exit 1
}

if ( -Not (Get-Command "nvim.exe" -ErrorAction SilentlyContinue) ) {
    Write-Host " Missing neovim executable" -ForegroundColor Red
    exit 1
}

$mini_dir = "$env:USERPROFILE\AppData\Local\nvim-data\site\pack\deps"

if ( -Not (Test-Path("$mini_dir\start")) -And -Not (Test-Path("$mini_dir\start")) ) {
    mkdir -p "$mini_dir\start"
}

if ( Test-Path("$mini_dir\start") ) {
    $mini_dir = "$mini_dir\start"
}
else {
    $mini_dir = "$mini_dir\start"
}

if ( -Not (Test-Path("$mini_dir\mini.nvim")) ) {
    git clone --recursive "https://github.com/echasnovski/mini.nvim" "$mini_dir\mini.nvim"
}

nvim -V1 --version
nvim --headless --cmd 'let g:minimal=1' --cmd "let g:no_output=1" -c "lua require'nvim'.setup(true)" -c "lua MiniTest.execute(MiniTest.collect())"

exit $LASTEXITCODE
