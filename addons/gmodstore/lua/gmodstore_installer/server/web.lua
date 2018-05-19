
local red = Color(255, 50, 50)
local green = Color(50, 255, 50)
local blue = Color(50, 255, 255)

function gmodstore.download_script(id, versionid)
	assert(gmodstore.APIKEY, "api key is not set yet, aborting")
	local found = false;
	for k, v in pairs(gmodstore.purchases) do
		if v.id == id then found = true end
	end

	assert(found, "you don't seem to own the script")
	local adr

	if versionid then
		adr = Format("https://www.gmodstore.com/api/scripts/download/%i?api_key=%s&version=%s", id, gmodstore.APIKEY, versionid)
	else
		adr = Format("https://www.gmodstore.com/api/scripts/download/%i?api_key=%s", id, gmodstore.APIKEY)
	end

	MsgC(blue, Format("Started downloading the script number #%i ... ", id))

	http.Fetch(adr, function(body, len, headers, code)
		if code == 401 then
			Msg("\n")
			error("Could not get the addon download, your API/ID key is high likely incorrect!")
		end

		if code ~= 200 then
			Msg("\n")
			error("Could not DL the addon " .. adr)
		end

		local iszip = string.StartWith(body, "PK")

		if not iszip then
			body = util.JSONToTable(body).description
			error("Gmodstore didn't send us a file but this error message : " .. body)
		end

		local savepath = string.format("gmodstore_tmp_zips/%i.zip.dat", id)
		MsgC(blue, Format(" done ! Saving to -> %s\n", savepath))
		file.Write(savepath, body)
		file.CreateDir(string.format("gmodstore_tmp_zips/%i_tmp/", id))
		gmodstore.extractZIP(id)
		file.Delete(Format("gmodstore_tmp_zips/%i_tmp/LICENSE.txt", id)) -- we don't need it and you did read it when purchasing it nigga
	end, function(err)
		Msg("\n")
		error("Could not reach gmodstore : " .. err)
	end)
end

function gmodstore.script_get_infos(id, Calllback)
	assert(gmodstore.APIKEY, "api key is not set yet, aborting")
	local adr = Format("https://www.gmodstore.com/api/scripts/info/%i?api_key=%s", id, gmodstore.APIKEY)

	http.Fetch(adr, function(body, len, headers, code)
		if code == 401 then
			error("Could not get script infos, your API key is high likely incorrect!")
		end

		if code ~= 200 then
			error("Could not get script infos!")
		end

		local tbl = util.JSONToTable(body)

		if tbl["status"] ~= "success" then
			error("Gmodstore reported an error when trying to get the purchase list")
		end

		tbl = tbl.script

		for k, v in pairs(gmodstore.purchases) do
			if v.id == id then
				v.name = tbl.name
				v.banner = Format("https://media.gmodstore.com/script_banners/%s.png",tbl.banner )
				v.done = true
			end
		end
	end, function(err)
		for k, v in pairs(gmodstore.purchases) do
			if v.id == id then
				v.done = true
			end
		end

		error("Could not reach gmodstore : " .. err)
	end)
end

function gmodstore.load_scripts()
	assert(gmodstore.APIKEY, "api key is not set yet, aborting")
	gmodstore.purchases = {}

	http.Fetch(string.format("https://www.gmodstore.com/api/user/purchases?api_key=%s", gmodstore.APIKEY), function(body, len, headers, code)
		if code == 401 then
			error("Could not get purchase list, your API key is high likely incorrect!")
		end

		if code ~= 200 then
			error("Could not get purchase list!")
		end

		local tbl = util.JSONToTable(body)

		if tbl["status"] ~= "success" then
			error("Gmodstore reported an error when trying to get the purchase list")
		end

		for k, v in pairs(tbl["purchases"]) do
			local tbl2 = {}
			tbl2.id = tonumber(v.script_id)
			tbl2.revoked = tobool(v.revoked)
			tbl2.done = false
			table.insert(gmodstore.purchases, tbl2)
			gmodstore.script_get_infos(tbl2.id)
		end



		Msg("\n")
					http.Fetch(string.format("https://www.gmodstore.com/api/scripts/?api_key=%s", gmodstore.APIKEY), function(body, len, headers, code)

					if code ~= 200 then -- dev only so don't error, scripts you made are not returned by the purchased scripts api so yeah i have to make this query
						return;
					end

					local tbl = util.JSONToTable(body)

					if tbl["status"] ~= "success" then
						return
					end

					for k, v in pairs(tbl["scripts"]) do
						local tbl2 = {}
						tbl2.id = tonumber(v.id)
						tbl2.revoked = false
						tbl2.name = v.name
						tbl2.banner = Format("https://media.gmodstore.com/script_banners/%s.png", v.banner)
						tbl2.done = true
						table.insert(gmodstore.purchases, tbl2)
					end

					MsgC(green, string.format("Found %i scripts (including the ones you made) on your gmodstore account.", #gmodstore.purchases))
							local revok = 0
							for k, v in pairs(gmodstore.purchases) do
								if v.revoked then
									revok = revok + 1
								end
							end
							if (tobool(revok)) then
								MsgC(red, string.format(" But %i of them are revoked !", revok))
							end
					Msg("\n")
				end, function(err)
					error("Could not reach gmodstore : " .. err)
				end)
	end, function(err)
		error("Could not reach gmodstore : " .. err)
	end)
end

gmodstore.load_scripts()