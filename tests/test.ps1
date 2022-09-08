if ( -Not (Get-Command "git.exe" -ErrorAction SilentlyContinue) ) {
    Write-Host " Missing git executable" -ForegroundColor Red
    exit 1
}

if ( -Not (Get-Command "nvim.exe" -ErrorAction SilentlyContinue) ) {
    Write-Host " Missing neovim executable" -ForegroundColor Red
    exit 1
}

$plenary_dir = "$env:USERPROFILE\AppData\Local\nvim-data\site\pack\packer\start"

if ( -Not (Test-Path($plenary_dir)) ) {
    mkdir -p "$plenary_dir"
}

if ( -Not (Test-Path("$plenary_dir\plenary.nvim")) ) {
    git clone --recursive "https://github.com/nvim-lua/plenary.nvim" "$plenary_dir\plenary.nvim"
}

nvim --version

$exit_code = 0
# nvim --noplugin -u tests/min.lua --headless -c "PlenaryBustedDirectory lua/tests/ {minimal_init = 'tests/min.lua'}"
Get-ChildItem -Path .\lua\tests\ | Where-Object {$_.PSIsContainer -eq $false} | ForEach {
    nvim --noplugin -u "tests/min.lua" --headless -c "PlenaryBustedFile lua/tests/$_"
    if ( -not $? ) {
        $exit_code = 1
    }
}

exit $exit_code
