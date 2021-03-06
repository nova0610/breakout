local luasp = _luasopia
local print0 = luasp.print0


local fileurls = {
    ['sun.png'] = 'https://raw.githubusercontent.com/luasopia/data/master/png/sun.png',
    ['earth.png'] = 'https://raw.githubusercontent.com/luasopia/data/master/png/earth.png',
    ['moon.png'] = 'https://raw.githubusercontent.com/luasopia/data/master/png/moon.png',
    ['gear.png'] = 'https://raw.githubusercontent.com/luasopia/data/master/png/gear.png',
    ['star.png'] = 'https://raw.githubusercontent.com/luasopia/data/master/png/star.png',
    ['birdfly.png'] = 'https://raw.githubusercontent.com/luasopia/data/master/png/birdfly.png',
    ['girlrun.png'] = 'https://raw.githubusercontent.com/luasopia/data/master/png/girlrun.png',
    ['smoke.png'] = 'https://raw.githubusercontent.com/luasopia/data/master/png/smoke.png',
    ['pipe.png'] = 'https://raw.githubusercontent.com/luasopia/data/master/png/pipe.png',
    ['windbar.png'] = 'https://raw.githubusercontent.com/luasopia/data/master/png/windbar.png',
    ['windblade.png'] = 'https://raw.githubusercontent.com/luasopia/data/master/png/windblade.png',
    ['singleblade.png'] = 'https://raw.githubusercontent.com/luasopia/data/master/png/singleblade.png',
    
    ['bounce.wav'] = 'https://raw.githubusercontent.com/luasopia/data/master/wav/bounce.wav',
    ['pong.wav'] = 'https://raw.githubusercontent.com/luasopia/data/master/wav/pong.wav',
    ['up.wav'] = 'https://raw.githubusercontent.com/luasopia/data/master/wav/up.wav',
    ['warn.wav'] = 'https://raw.githubusercontent.com/luasopia/data/master/wav/warn.wav',
    ['zet.wav'] = 'https://raw.githubusercontent.com/luasopia/data/master/wav/zet.wav',
    ['clear.wav'] = 'https://raw.githubusercontent.com/luasopia/data/master/wav/clear.wav',

    ['scene.lua'] = 'https://raw.githubusercontent.com/luasopia/data/master/scene.lua',
}

--------------------------------------------------------------------------------
luasp.allowGlobal() ------------------------------------------------------------
--------------------------------------------------------------------------------


function getfile(name)

    local url = fileurls[name]
    if url == nil then
        luasp.cli.print('Error: unknown file')
        return
    end

    local rootpath = luasp.resourceDir..'root/'

    local comm = 'curl -o "'..rootpath..name..'" "'..url..'"'

    --2021/09/14: gideros??? ??????????????? ??????????????? ????????? ?????? ????????? ??????
    -- solar2d??? ??? ????????? ????????? ????????? ?????? ?????? ?????????.
    if _Gideros then
        comm = 'start /min '..comm
    end


    --print(comm)
    if 0== os.execute(comm ) then
        luasp.cli.print('download success!')
        -- print('download success!')
    else
        luasp.cli.print('Error: fail to download')
        -- print('Error: fail to download')
    end


end


_require0 'lfs' -- ???????????? global?????? lfs??? ???????????? ??? ??????.

--------------------------------------------------------------------------------
luasp.banGlobal() ------------------------------------------------------------
--------------------------------------------------------------------------------




if _Corona then 


    -- 2021/09/07: ????????????????????? ?????? ????????? ???????????? ?????? ???????????????
    -- ????????? tmp????????? ?????? ???????????? ????????? ????????????????????? copy?????? ???????????? ??????
    function luasp.savefile(filename, contentStr)

        local path1 = system.pathForFile( filename, system.TemporaryDirectory )
        --print0(path1)
    
        local file, errormsg = io.open(path1,'w') -- ?????? ?????? ????????????
        if not file then
            print0('File error:'..errmsg)
        
        else
            file:write(contentStr)
            io.close(file)
        end
    
    
        local path2 = system.pathForFile( "root\\main.lua", system.ResourceDirectory )
        path2 = string.gsub(path2,'main.lua','data\\')
    
        -- print0(path2)
    
        local cmd = 'copy /y "'..path1.. '" "'..path2..'"'
        -- print0( cmd )
        if 0 == os.execute(cmd) then
            print0(filename ..' is successfully created.')
        end
    
    end


elseif _Gideros then


    function luasp.savefile(filename, contentStr)

        local path1 = _Gideros.application:get("temporaryDirectory")

    end
    

end








local function getFileListR(path, cache, strtype)

    if cache == nil then cache = {} end

    local properPath = string.gsub(path, '[.]', '/')

    -- local sysPath = system.pathForFile(properPath, system.ResourceDirectory)
    local sysPath = luasp.resourceDir .. properPath
    print0(sysPath)

    for entry in lfs.dir(sysPath) do

        local mode = lfs.attributes(sysPath .. '/' .. entry, 'mode')
        if mode == 'file' then

            -- local name = string.match(entry, '(.*).lua')

            local strmatch = '(.*)%('..strtype..'%).lua'
            local name = string.match(entry, strmatch)

            if name then
                -- cache[#cache + 1] = path .. '.' .. name 
                cache[#cache + 1] = string.format('%s.%s(%s)',path,name,strtype)
            end

        elseif mode == 'directory' then

            if not string.match(entry, '^[.].*') then
                getFileListR(path .. '.' .. entry, cache, strtype) -- ????????????
            end

        end
    end

    return cache
end

-- --[[
function luasp.findfiles(strtype)

    return getFileListR(luasp.root,{},strtype)

end
--]]

