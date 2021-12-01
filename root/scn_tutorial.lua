-- (2021/11/14) scene template v1.0.0 created
local scene = Scene() -- create Scene object(must be in the topmost line)

-- scene이 맨 처음 생성될 때 수행되어야 하는 코드를 여기에 작성
-- 예: 변수 생성, 고정된 Image 표시 등

local title = Text('게임설명',{fontSize=100}):setY(700)
local title = Text('막대기를 움직여서 모든 벽돌을 파괴하세요')
local btn = Button('시작'):setY(1500)

function btn:onPress(e)
    Scene.goto('scn_ingame')
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