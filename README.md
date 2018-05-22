#description i provided on the gmodstore dev forums


So last day i was bored and i decided to do like billy and make a gmodstore addon auto installer that could allow you to setup your gmodstore addons in game, without using FTP, without using your browser.


So it's basically using your API Key to check the addon you own and the ones you made (yeah, also the ones you made), downloading them to `string.format("gmodstore_tmp_zips/%i.zip.dat", id)`, and then unzip them to `string.format("gmodstore_tmp_zips/%i_tmp/", id)`

For securities reasons you can either set your api key in the lua code or in the launch parameters using something like `srcds.exe -gmodstorekey YOUR___32___LETTERS___LONG___KEY`

i didn't start porting it for linux, i just used functions that should work on both (you gonna need a *linux-way* to get the command-line used to start the app)


Then after extracting the addon to `string.format("gmodstore_tmp_zips/%i_tmp/", id)` it need to "guess" how to install it, [and this is the tricky part](https://github.com/ExtReMLapin/gmodstore-addon-extractor/blob/master/addons/gmodstore/lua/gmodstore_installer/server/extraction.lua)

Because there is a shit ton of possible things to handle, the best way would be to do like modorganizer, but i was too lazy to finish this part.

I stopped on this part.

the todo table was supposed to return arrays or (size-2) arrays of string, things like


``` Lua 
todo = {
{"source/folder/*", "destination/folder/"},
[etc]



}

```


`__lua_async void gmodstore.load_scripts(void);` loads the scripts you own and made in gmodstore.purchases

`__lua_async void gmodstore.script_get_infos(int id);` moads more info about the scripts, it's called by gmodstore.load_scripts()

`__lua_async void gmodstore.download_script(id, versionid);` download the script it to data -> `string.format("gmodstore_tmp_zips/%i.zip.dat", id)` didn't check if the versionid argument is working 


`__cpp_sync void gmodstore.extractZIP(int id)` extracts `string.format("gmodstore_tmp_zips/%i.zip.dat", id)` to `string.format("gmodstore_tmp_zips/%i_tmp/", id)`


`__lua_sync char ***gmodstore.get_extraction_scheme(int id);` returns the extraction scheme of the addon it HAS TO BE EXTRACTED

`__cpp_sync char *gmodstore.getAPIKey(void)` returns your 32char long api key

`__cpp_sync char *gmodstore.setAPIKey(char *key)` call it to set the key, it will error if the key format is incorrect, **not if the key is incorrect**

All functions listed here are called from Lua, __lua mean it's coded in Lua, __cpp means it's imported from the binary module

_sync mean ... it's synchronous and _async mean it's ... not
