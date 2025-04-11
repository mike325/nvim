return {
    cmd = {
        'docker-langserver',
        '--stdio',
    },
    filetypes = { 'dockerfile' },
    root_markers = { 'Dockerfile', 'docker-compose.yml', '.git' },
}
