# Start studio and run process command when src files change
start: build
    open FreezeTag.rbxl
    just serve

serve:
    just process
    rojo serve build.project.json & darklua process --config darklua.json --watch src/ out/

build: process
    rojo build build.project.json --output FreezeTag.rbxl

process: sourcemap
    rm -rf out/*
    darklua process --config darklua.json src/ out/

install-packages:
    wally install

    just sourcemap
    wally-package-types --sourcemap sourcemap.json Packages/
    wally-package-types --sourcemap sourcemap.json DevPackages/

    echo "local REQUIRED_MODULE = require(script.Parent.Parent[\"jsdotlua_jest-message-util@3.4.1\"][\"jest-message-util\"])\nreturn REQUIRED_MODULE" > DevPackages/_Index/jsdotlua_jest-reporters@3.4.1/JestMessageUtil.lua

analyze: process
    curl -O https://raw.githubusercontent.com/JohnnyMorganz/luau-lsp/main/scripts/globalTypes.d.lua

    echo "{ \"languageMode\": \"nocheck\" }" > Packages/.luaurc
    echo "{ \"languageMode\": \"nocheck\" }" > DevPackages/.luaurc

    just sourcemap
    luau-lsp analyze --definitions=globalTypes.d.lua --base-luaurc=.luaurc --sourcemap=sourcemap.json --settings=.vscode/settings.json src/

    rojo sourcemap build.project.json --output sourcemap.json
    luau-lsp analyze --definitions=globalTypes.d.lua --base-luaurc=.luaurc --sourcemap=sourcemap.json --settings=.vscode/settings.json src/

sourcemap:
   rojo sourcemap default.project.json --include-non-scripts --output sourcemap.json
