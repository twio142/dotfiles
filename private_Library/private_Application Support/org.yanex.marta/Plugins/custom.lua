plugin {
	id = "custom",
	name = "Custom",
	apiVersion = "2.1"
}

action {
	id = "file.open",
	name = "Open Files / Launch Applications",

	isApplicable = function(context)
		return context.activePane.model.hasActiveFiles
	end,

	apply = function(context)
		local files = context.activePane.model.activeFileInfos
		for _, file in ipairs(files) do
			if file.isApplication then
				martax.launchApplication(file.path)
			elseif not file.isFolder or file.isPackage then
				martax.openFiles(file.path)
			elseif file.isFolder then
				context.activePane.model:load(file)
			end
		end
	end
}

action {
	id = "paste.open",
	name = "Open Copied Path",

	apply = function(context)
		local path = martax.clipboard.getString()
		path = string.gsub(path, '/$', '')
		local target = marta.localFileSystem:get(path)
		if not target:exists() then
			print('Copied path not exists')
			return
		end
		if martax.getUti(path) == 'public.folder' then
			context.activePane.model:load(target)
		else
			context.activePane.model:load(target.parent, target.name)
		end
	end
}

action {
	id = "paste.open.newtab",
	name = "Open Copied Path in New Tab",

	apply = function(context)
		local path = martax.clipboard.getString()
		path = string.gsub(path, '/$', '')
		if not marta.localFileSystem:get(path):exists() then
			print('Copied path not exists')
			return
		end
		martax.openFiles(path, 'org.yanex.marta')
	end
}

action {
	id = "folder.open.inactivePane",
	name = "Open Folder in Inactive Pane",

	isApplicable = function(context)
		return context.activePane.model.hasCurrent and martax.getUti(context.activePane.model.currentFile.path) == 'public.folder'
	end,

	apply = function(context)
		local target = context.activePane.model.currentFile
		context.inactivePane.model:load(target)
		local action = marta.globalContext.actions:getById('core.change.current.pane')
		context.window:runAction(action)
	end
}

action {
	id = "git.pull",
	name = "Git Pull",

	isApplicable = function(context)
		return context.activePane.model.isNotEmpty
	end,

	apply = function(context)
		local currentDir = context.activePane.model.folder
		martax.execute('/usr/bin/git', 'pull', currentDir)
	end
}

action {
	id = "quickselect",
	name = "Get Quick Select String",

	apply = function(context)
		local qs = context.activePane.model.quickSelect
		print(qs)
		-- local group = marta.globalContext.actions:getById('core.select.group')
		-- context.window:runAction(group)
		for _, file in ipairs(context.activePane.model.activeFileInfos) do
			print(file.name)
			print(file.isFolder)
		end
	end
}

action {
	id = "selected.buffer",
	name = "Add selected file(s) to Alfred buffer",

	isApplicable = function(context)
		return context.activePane.model.hasActiveFiles or context.activePane.model.selectedCount + context.inactivePane.model.selectedCount > 0
	end,

	apply = function(context)
		local selected = {}
		for _, file in ipairs(context.activePane.model.activeFiles) do
			table.insert(selected, file.path)
		end
		for _, file in ipairs(context.inactivePane.model.activeFiles) do
			table.insert(selected, file.path)
		end
		martax.execute(os.getenv('HOME')..'/bin/altr', { '-t', 'buffer', '-w', 'com.nyako520.syspre', '-a', '-', table.unpack(selected) })
		context.activePane.model:deselectAll()
		context.inactivePane.model:deselectAll()
	end
}

action {
	id = "selected.copy",
	name = "Copy selected file(s) to here",

	isApplicable = function(context)
		return context.activePane.model.hasCurrent and context.activePane.model.selectedCount + context.inactivePane.model.selectedCount > 0
	end,

	apply = function(context)
		local target = context.activePane.model.currentFile or context.activePane.model.folder.parent
		if target == nil then return end
		if martax.getUti(target.path) ~= 'public.folder' then
			target = target.parent
		end
		local files = {}
		for _, file in ipairs(context.activePane.model.selectedFiles) do
			table.insert(files, file.path)
		end
		for _, file in ipairs(context.inactivePane.model.selectedFiles) do
			table.insert(files, file.path)
		end
		martax.execute(os.getenv('HOME')..'/bin/altr', { '-t', 'copyToHere', '-w', 'com.nyako520.fileaction', '-v', 'target='..target.path, '-a', '-', table.unpack(files) })
		context.activePane.model:deselectAll()
		context.inactivePane.model:deselectAll()
	end
}

action {
	id = "selected.move",
	name = "Move selected file(s) to here",

	isApplicable = function(context)
		return context.activePane.model.hasCurrent and context.activePane.model.selectedCount + context.inactivePane.model.selectedCount > 0
	end,

	apply = function(context)
		local target = context.activePane.model.currentFile or context.activePane.model.folder.parent
		if target == nil then return end
		if martax.getUti(target.path) ~= 'public.folder' then
			target = target.parent
		end
		for _, file in ipairs(context.activePane.model.selectedFiles) do
			file:rename(target:append(file.name).path)
		end
		for _, file in ipairs(context.inactivePane.model.selectedFiles) do
			file:rename(target:append(file.name).path)
		end
		context.activePane.model:deselectAll()
		context.inactivePane.model:deselectAll()
	end
}
