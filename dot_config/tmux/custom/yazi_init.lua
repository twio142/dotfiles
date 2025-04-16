vim.o.cmdheight = 0
vim.o.laststatus = 0
vim.o.shadafile = "NONE"
vim.o.termguicolors = true

vim.fn.jobstart({ "background" }, {
	on_stdout = function(_, data)
		if data and #data[1] > 0 then
			local fg = data[1]:match("light") and "#000000" or "#ffffff"
			vim.api.nvim_set_hl(0, "Normal", { fg = fg or "#999999", bg = "NONE", ctermbg = "NONE" })
		end
	end,
})

vim.api.nvim_create_autocmd("BufEnter", {
	once = true,
	pattern = "*",
	callback = function()
		local path = vim.fn.argv()[1]
		path = (path and path ~= "") and path or vim.fn.getcwd()
		vim.cmd("startinsert")
		vim.fn.termopen({ "yazi", path }, {
			on_exit = function()
				vim.cmd("q")
			end,
		})
	end,
})
