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
	open_window()
	update_view()
	api.nvim_win_set_cursor(win, {4, 0})
end

return {
	whid = whid
}

-- jl
-- kh

