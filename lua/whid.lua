-- in lua/whid.luaw

local api = vim.api
local buf, win

local function open_window()
	print("open_window")
	buf = api.nvim_create_buf(false, true)

	api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')

	-- get dimensions
	local width = api.nvim_get_option('columns')
	local height = api.nvim_get_option('lines')

	-- calculate window size
 	local win_height = math.ceil(height * 0.8 - 4)
 	local win_width = math.ceil(width * 0.8)

 	-- calculate window position
	local row = math.ceil((height - win_height) / 2 - 1)
	local col = math.ceil((width - win_width) / 2)

	-- set some options
	local opts = {
		style = 'minimal',
		relative = 'editor',
		width = win_width,
		height = win_height,
		row = row,
		col = col
	}

	local border_opts = {
		style = 'minimal',
		relative = 'editor',
		width = win_width + 2,
		height = win_height + 2,
		row = row - 1,
		col = col - 1
	}

	local border_buf = api.nvim_create_buf(false, true)

	local border_lines = {
		"╭" .. string.rep("─", win_width) .. "╮"}
	local middle_line = 	"│" .. string.rep(" ", win_width) .. "│"
	for i=1, win_height do
		table.insert(border_lines, middle_line)
	end
	table.insert(border_lines, 	"╰" .. string.rep("─", win_width) .. "╯")


	api.nvim_buf_set_lines(border_buf, 0, -1, false, border_lines)
	
	-- create window
	local border_win = api.nvim_open_win(border_buf, true, border_opts)
	win = api.nvim_open_win(buf, true, opts)
	api.nvim_command("autocmd BufWipeout <buffer> exe 'silent bwipeout! '" .. border_buf)

end

local function center(text)
	local width = api.nvim_win_get_width(0)
	local shift = math.floor(width/2) - math.floor(string.len(text)/2)
	return string.rep(" ", shift) .. text
end

local function set_mappings()
	local mappings = {
		['['] = 'update_view(-1)',
		[']'] = 'update_view(1)',
		['<cr>'] = 'open_file()',
		h = 'update_view(-1)',
		l = 'update_view(1)',
		k = 'move_cursor()',
		['q'] = 'close_window()'
	}

	for k,v in pairs(mappings) do
		api.nvim_buf_set_keymap(buf, 'n', k, ':lua require"whid".'..v..'<cr>', {nowait = true, noremap = true, silent = true})
	end
	local other_chars = {
		'a', 'b', 'c', 'd', 'e', 'f', 'g', 'i', 'n', 'o', 'p', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'
	}
	for k,v in ipairs(other_chars) do
		api.nvim_buf_set_keymap(buf, 'n', v, '', { nowait = true, noremap = true, silent = true })
		api.nvim_buf_set_keymap(buf, 'n', v:upper(), '', { nowait = true, noremap = true, silent = true })
		api.nvim_buf_set_keymap(buf, 'n',  '<c-'..v..'>', '', { nowait = true, noremap = true, silent = true })
	end
end

local function close_window()
	api.nvim_win_close(win, true)
end

local function open_file()
  local str = api.nvim_get_current_line()
  close_window()
  api.nvim_command('edit '..str)
end

local function move_cursor()
	local line = api.nvim_win_get_cursor(win)[1]
	local file = api.nvim_buf_get_lines(buf, line-1, line, false)[1]
	local path = vim.fn.expand(file)
	local row = vim.fn.line("'\""..path)
	local col = vim.fn.col("'\""..path)
	api.nvim_command('edit '..path)
	api.nvim_win_set_cursor(0, {row, col})
	close_window()
end

local position = 0

local function update_view(direction)
	position = position + direction
	if position < 0 then
		position = 0
	end

	local result = vim.fn.systemlist("git diff-tree --no-commit-id --name-only -r HEAD~" .. position)

	for k, v in pairs(result) do
		result[k] = ' '..result[k]
	end

	api.nvim_buf_set_lines(buf, 0, -1, false, {
		center('What have I done?'),
		center("HEAD~" .. position),
		''
	})

	api.nvim_buf_set_lines(buf, 3, -1, false, result)

	api.nvim_buf_add_highlight(buf, -1, "WhidHeader", 0, 0, -1)
	api.nvim_buf_add_highlight(buf, -1, "WhidSubHeader", 1, 0, -1)
end


local function whid()
	print("whid")
	position = 0
	--open_window()
--	set_mappings()
--	update_view(0)
	api.nvim_win_set_cursor(win, {4, 0})
end

return {
	whid = whid,
	open_file = open_file(),
	update_view = update_view(),
	move_cursor = move_cursor(),
	close_window = close_window()

}

-- jl
-- kh

