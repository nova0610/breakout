-- (2021/11/14) scene template v1.0.0 created
local scene = Scene() -- create Scene object(must be in the topmost line)

-- scene이 맨 처음 생성될 때 수행되어야 하는 코드를 여기에 작성
-- 예: 변수 생성, 고정된 Image 표시 등

Text('게임오버',{fontSize=150}):setY(600)
local btn1 = Button('재도전'):setY(1200)
local btn2 = Button('타이틀로'):setY(1400)

function btn1:onPress(e)
    Scene.goto('scn_ingame','fade',1500)
end

function btn2:onPress(e)
    Scene.goto('scn_title','fade',1000)
end




-- 아래의 함수 네 개 중 필요한 것만 선택하여 작성한다.
--[[
function scene:beforeShow(stage)
    -- 화면에 scene이 들어오기 직전에 수행되어야 하는 코드 작성
end
--]]

--[[
function scene:afterHide(stage)
    -- 화면에서 scene이 나간 직후에 수행되어야 하는 코드 작성
end
--]]


--[[
function scene:afterShow(stage)
    -- 화면에 scene이 들어온 직후에 수행되어야 하는 코드 작성
end
--]]

--[[
function scene:beforeHide(stage)
    -- 화면에서 scene이 나가기 직전에 수행되어야 하는 코드 작성
end
--]]

return scene