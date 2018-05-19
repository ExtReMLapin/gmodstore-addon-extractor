# gmodstore-addon-extractor


It provides some tools to download, extract and install gmodstore addons

gmodstore.get_extraction_scheme(id) -> unfinished function

gmodstore.load_scripts() 

gmodstore.setAPIKey() with verification in the module to check if the key is not shit.

You can set the key in the lua file main.lua or in a [launch parameter](https://github.com/ExtReMLapin/gmodstore-addon-extractor/blob/master/module_source/example/src/gm_example.cpp#L154) argument like `-gmodstorekey URKEY`


Zip are downloaded in ` string.format("gmodstore_tmp_zips/%i.zip.dat", id)`

And are then extracted in `string.format("gmodstore_tmp_zips/%i_tmp/", id)` you CANNOT chose the extract path, [the module decides](https://github.com/ExtReMLapin/gmodstore-addon-extractor/blob/master/module_source/example/src/gm_example.cpp#L114) where it's extracted, it's based on the script id

too lazy to make the build work on linux


also the "extractor" tries to guess where and how to extract the addon, not perfect but it does the job.

And i stopped here, if you want to finish it you need to add a "mv" function to the module
