if ( -Not (Get-Command "git.exe" -ErrorAction SilentlyContinue) ) {
    Write-Host " Missing git executable" -ForegroundColor Red
    exit 1
}

if ( -Not (Get-Command "nvim.exe" -ErrorAction SilentlyContinue) ) {
    Write-Host " Missing neovim executable" -ForegroundColor Red
    exit 1
}

$mini_dir = "$env:USERPROFILE\AppData\Local\nvim-data\site\pack\deps\start"

if ( -Not (Test-Path("$mini_dir")))  {
    Write-Host "Creating mini plugin dir" -ForegroundColor Green
    mkdir -p "$mini_dir\start"
}

if ( -Not (Test-Path("$mini_dir\mini.nvim")) ) {
    Write-Host "Clonning mini to $mini_dir\mini.nvim" -ForegroundColor Green
    git clone --recursive "https://github.com/echasnovski/mini.nvim" "$mini_dir\mini.nvim"
}

nvim -V1 --version
Write-Host "Starting unittests" -ForegroundColor Green
nvim --headless --cmd 'let g:minimal=1' --cmd "let g:no_output=1" --cmd "lua require'nvim'.setup(true)" -c "lua MiniTest.execute(MiniTest.collect())"

exit $LASTEXITCODE
