" VNC Setttings
" github.com/mike325/.vim

if !executable('vnc') || !has#async()
    finish
endif

command! -bang -nargs=1 -complete=customlist,vnc#KnownHosts VNC call vnc#RunVNC(<q-args>, <bang>0)
command! -nargs=1 -complete=customlist,vnc#VNCSessions VNCStop call vnc#StopVNC(<q-args>)

