

v:complete_item 每次pum select 都会赋选中的值
TextChangedP 每次调用complete时，都会触发， popup在弹出状态时，每次文本变动会被触发，当输入触发popup关闭时，不会触发
TextChangedI 当输入触发popup关闭时，会触发, popup不存在时， 输入会触发， 触发complete时待定
CompleteDone 补全完成便会触发
CompleteDonePre

nvim_get_current_buf()
nvim_buf_set_option({buffer}, {name}, {value})
                    {buffer}  Buffer handle, or 0 for current buffer
nvim_buf_get_option({buffer}, {name})
nvim_set_option({name}, {value})
nvim_get_current_line()
