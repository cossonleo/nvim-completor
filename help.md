lua 下标从1开始
本插件下标从0开始

v:complete_item 每次pum select 都会赋选中的值
TextChangedP 每次调用complete时，都会触发， popup在弹出状态时，每次文本变动会被触发，当输入触发popup关闭时，会触发
TextChangedI 当输入触发popup关闭时，会触发, popup不存在时， 输入会触发， 触发complete时待定
CompleteDone 补全完成便会触发 之后会出发text changed i
CompleteDonePre

positon: {"textDocument": {"uri": "file://"}, "position": {"character": 0, "line": 1}}

vim.fn

v:lua.xxx

nvim_get_current_buf()
nvim_buf_set_option({buffer}, {name}, {value})
                    {buffer}  Buffer handle, or 0 for current buffer
nvim_buf_get_option({buffer}, {name})
nvim_set_option({name}, {value})
nvim_get_current_line()
nvim_win_get_cursor({window})
				(row, col)(1, 0) -- index


vim.tbl_isempty({t})
vim.tbl_islist({t})
vim.tbl_keys({t})
vim.tbl_values({t})
vim.trim({s})
vim.deep_equal()
startswith({s},

incomplete 未完善

complete item

{
	abbr: 展示在候选窗口中， 用于展示补全的目标
	word: 不展示在候选窗口中
	menu: 对候项的描述
}
