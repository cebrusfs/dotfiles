" Compile
nmap <buffer> <Leader>c   :w<CR>
                \:!pandoc -f markdown -o %:r.pdf %
                \ --latex-engine xelatex --template=chinese
                \ -M graphics
                \ -V CJKmainfont:LiSongPro -V CJKboldfont:LiHei\ Pro
                \ -V CJKmonofont:LiSongPro -V monofont:Monaco<CR>

" Execute
nmap <buffer> <Leader>p   :!open %:r.pdf<CR>
