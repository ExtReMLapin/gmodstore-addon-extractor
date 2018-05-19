
require("gmodstore")
assert(gmodstore, "Failed to load gmodstore lib")


gmodstore.APIKEY = "" -- get it here https://www.gmodstore.com/dashboard/settings/api
-- if required, make a new one with "script read" rights only
-- it's much better for securities issues to add a launch option of the game (linux or windows something like ) :
--[[
-gmodstorekey YOUR___32___LETTERS___LONG___KEY
]]
gmodstore.purchases = {}

if not gmodstore.getAPIKey() then
	gmodstore.setAPIKey(gmodstore.APIKEY)
else
	gmodstore.APIKEY = gmodstore.getAPIKey()
end

assert(gmodstore.getAPIKey(), "Aborting ! Please specify an API KEY")


if not file.Exists("gmodstore_tmp_zips", "DATA") then
	MsgC(Color(255,50,50), "Creating gmodstore tmp folder in data ...\n")
	file.CreateDir("gmodstore_tmp_zips")
end


function gmodstore.get_purchases()
	return gmodstore.purchases
end

