local function getallfiles(path, out_table)
	local flist, dlist = file.Find(path .. "*", "DATA")

	if #dlist > 0 then
		for k, v in pairs(dlist) do
			table.insert(out_table, path .. v .. "/")
			getallfiles(path .. v .. "/", out_table)
		end
	end

	for k, v in pairs(flist) do
		table.insert(out_table, path .. v)
	end
end

local function print_todo(todo, filelist)
	for k, v in pairs(todo) do
		print(Format("%s => %s", v[1], v[2]))
	end

	for k, v in pairs(filelist) do
		print(Format("Leftover file : %s", v))
	end

end

function gmodstore.get_extraction_scheme(id)
	local todo = {}
	local filelist = {}
	local base_folder = string.format("gmodstore_tmp_zips/%i_tmp/", id)
	assert(file.IsDir(base_folder, "DATA"), "Could not find the extracted archive")
	getallfiles(base_folder, filelist)
	local flist, dlist = file.Find(base_folder .. "*", "DATA")


	 -- let's scan for gmod merge type .zips, like underdone, only with implicit garrysmod type
	local recognizedfolders = {"addons/", "gamemodes/"}
	for k, v in pairs(filelist) do
		for k2, v2 in pairs(recognizedfolders) do
			if string.EndsWith(v, v2) then
				local subpath = string.gsub(v,v2,"")
				table.insert(todo, {subpath .. "*", Format("./garrysmod/addons/%i/", id)})
				for k3, v3 in pairs(filelist) do
					if string.StartWith(v3, subpath) then
						filelist[k3] = nil
					end
				end
				break
			end
		end
	end

	-- let's scan for garrysmod folder so we know what to merge directlu
	if table.HasValue(dlist,"garrysmod") then
		local subpath = base_folder .. "garrysmod/"
		table.insert(todo, {subpath .. "*", Format("./garrysmod/addons/%i/", id)})
		for k, v in pairs(filelist) do
			if string.StartWith(v, subpath) then
				filelist[k] = nil
			end
		end
	end


	 -- if there is any addon.txt then it's auto detected as an addon folder
	for k, v in pairs(filelist) do
		if string.EndsWith(v, "addon.txt") then
			local subpath = string.gsub(v, "addon.txt", "")
			table.insert(todo, {subpath .. "*", Format("./garrysmod/addons/%i/", id)})

			for k2, v2 in pairs(filelist) do
				if string.StartWith(v2, subpath) then
					filelist[k2] = nil
				end
			end
		end
	end



	-- if any of the left folder got lua folder in it, most propable case but we give the priority to any addon with addon.txt
	for k, v in pairs(dlist) do
		local flist2, dlist2 = file.Find(base_folder .. v .. "/*", "DATA")
		if table.HasValue(dlist2, "lua") then
			local subpath = base_folder .. v .. "/"
			table.insert(todo, {subpath .. "*" , Format("./garrysmod/addons/%i/", id)})

			for k2, v2 in pairs(filelist) do
				if string.StartWith(v2, subpath) then
					filelist[k2] = nil
				end
			end
		end
	end

	print_todo(todo, filelist) -- this is where i stopped working too lazy to finish it
end