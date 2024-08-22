if ( -Not (Get-Command "git.exe" -ErrorAction SilentlyContinue) ) {
    Write-Host " Missing git executable" -ForegroundColor Red
    exit 1
}

if ( -Not (Get-Command "nvim.exe" -ErrorAction SilentlyContinue) ) {
    Write-Host " Missing neovim executable" -ForegroundColor Red
    exit 1
}

$mini_dir = "$env:USERPROFILE\AppData\Local\nvim-data\site\pack\host"

if ( -Not (Test-Path("$mini_dir\opt")) -And -Not (Test-Path("$mini_dir\start")) ) {
    mkdir -p "$mini_dir\opt"
}

if ( Test-Path("$mini_dir\opt") ) {
    $mini_dir = "$mini_dir\opt"
}
else {
    $mini_dir = "$mini_dir\start"
}


if ( -Not (Test-Path("$mini_dir\mini.nvim")) ) {
    git clone --recursive "https://github.com/echasnovski/mini.nvim" "$mini_dir\mini.nvim"
}

nvim -V1 --version
nvim --noplugin --headless --cmd 'let g:minimal=1' --cmd "let g:no_output=1" -c "lua MiniTest.execute(MiniTest.collect())"

exit $LASTEXITCODE
