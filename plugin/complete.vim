
setlocal completeopt-=longest
setlocal completeopt+=menuone
setlocal completeopt-=menu
setlocal completeopt+=noselect

"autocmd TextChangedI * call On_text_changed()
func! On_text_changed()
	lua << EOF
	local cm = require("complete")
	cm.text_changed()
EOF
endfunc
