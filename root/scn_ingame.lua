-- (2021/11/14) scene template v1.0.0 created
local scene = Scene() -- create Scene object(must be in the topmost line)

-- scene이 맨 처음 생성될 때 수행되어야 하는 코드를 여기에 작성
-- 예: 변수 생성, 고정된 Image 표시 등

local x0, y0, endX, endY = screen.x0, screen.y0, screen.endX, screen.endY
local barY=1700
local barLength = 250
local brick = Group(br1,br2,br3,br4,br5,br6,br7,br8,br9,br10)
local brickLength = 150
local brickHeight = 50


local br1 =Rect(brickLength,brickHeight):setXY(100,200):tag('brick')
local br2 =Rect(brickLength,brickHeight):setXY(325,200):tag('brick')
local br3 =Rect(brickLength,brickHeight):setXY(550,200):tag('brick')
local br4 =Rect(brickLength,brickHeight):setXY(775,200):tag('brick')
local br5 =Rect(brickLength,brickHeight):setXY(1000,200):tag('brick')
local br6 =Rect(brickLength,brickHeight):setXY(100,400):tag('brick')
local br7 =Rect(brickLength,brickHeight):setXY(325,400):tag('brick')
local br8 =Rect(brickLength,brickHeight):setXY(550,400):tag('brick')
local br9 =Rect(brickLength,brickHeight):setXY(775,400):tag('brick')
local br10 =Rect(brickLength,brickHeight):setXY(1000,400):tag('brick')

local bar = Group():setY(barY)
local r=Rect(barLength,50):setAnchor(0.5,0):addTo(bar)

function screen:onTouch(e)
    if e.phase=='move' then
        bar:setX(bar:getX()+e.dx)
    end
end

local sndPong = Sound('pong.wav')

local score = 0
local txtScore=Text('0',{fontSize=100})

function scene:afterShow(stage)

    local ball = Circle(20):tag('ball')
    ball:setDxDy(rand(-10,-5,5,10),rand(5,10))

    function ball:update()

        local x,y = self:getXY()
        if y>endY then

            self:remove()
            Scene.goto('scn_gameover')
        
        end

        if x<x0 then
            self:setDx( rand(5,10) )
            self:fill(Color.RED)
            self:addTimer(100, function() self:fill(Color.WHITE) end)
            sndPong:play()
        elseif x>endX then
            self:setDx( rand(-10,-5) )
            self:fill(Color.RED)
            self:addTimer(100, function() self:fill(Color.WHITE) end)
            sndPong:play()
        elseif y<y0 then
            self:setDy( rand(-10,-5,5,10))
            self:fill(Color.RED)
            self:addTimer(100, function() self:fill(Color.WHITE) end)
            sndPong:play()
        elseif self:collectHit('brick') ~= nil then
            self:setDxDy( rand(-10,-5,5,10),rand(-10,-5,5,10))
            self:fill(Color.RED)
            self:addTimer(100, function() self:fill(Color.WHITE) end)
            sndPong:play()
        end

    



        local x1 = bar:getX()
        if barY-20<y and y<barY and x1-barLength/2<x and x<x1+barLength/2 then
            self:setDy( -rand(5,10) )
            self:fill(Color.RED)
            self:addTimer(100, function() self:fill(Color.WHITE) end)
            sndPong:play()
        end


    end

    function br1:update()
        local x,y = self:getXY()
        if self:collectHit('ball') ~= nil then
            self:fill(Color.RED)
            self:addTimer(100, function() self:fill(Color.WHITE) end)
            self:removeAfter(100)

            score=score+1
            txtScore:setString(tostring(score))
        end    
    end

    function br2:update()
        local x,y = self:getXY()
        if self:collectHit('ball') ~= nil then
            self:fill(Color.RED)
            self:addTimer(100, function() self:fill(Color.WHITE) end)
            self:removeAfter(100)
            
            score=score+1
            txtScore:setString(tostring(score))
        end    
    end

    function br3:update()
        local x,y = self:getXY()
        if self:collectHit('ball') ~= nil then
            self:fill(Color.RED)
            self:addTimer(100, function() self:fill(Color.WHITE) end)
            self:removeAfter(100)
            
            score=score+1
            txtScore:setString(tostring(score))
        end    
    end

    function br4:update()
        local x,y = self:getXY()
        if self:collectHit('ball') ~= nil then
            self:fill(Color.RED)
            self:addTimer(100, function() self:fill(Color.WHITE) end)
            self:removeAfter(100)
            
            score=score+1
            txtScore:setString(tostring(score))
        end    
    end

    function br5:update()
        local x,y = self:getXY()
        if self:collectHit('ball') ~= nil then
            self:fill(Color.RED)
            self:addTimer(100, function() self:fill(Color.WHITE) end)
            self:removeAfter(100)
            
            score=score+1
            txtScore:setString(tostring(score))
        end    
    end

    function br6:update()
        local x,y = self:getXY()
        if self:collectHit('ball') ~= nil then
            self:fill(Color.RED)
            self:addTimer(100, function() self:fill(Color.WHITE) end)
            self:removeAfter(100)
            
            score=score+1
            txtScore:setString(tostring(score))
        end    
    end

    function br7:update()
        local x,y = self:getXY()
        if self:collectHit('ball') ~= nil then
            self:fill(Color.RED)
            self:addTimer(100, function() self:fill(Color.WHITE) end)
            self:removeAfter(100)
            
            score=score+1
            txtScore:setString(tostring(score))
        end    
    end

    function br8:update()
        local x,y = self:getXY()
        if self:collectHit('ball') ~= nil then
            self:fill(Color.RED)
            self:addTimer(100, function() self:fill(Color.WHITE) end)
            self:removeAfter(100)
            
            score=score+1
            txtScore:setString(tostring(score))
        end    
    end

    function br9:update()
        local x,y = self:getXY()
        if self:collectHit('ball') ~= nil then
            self:fill(Color.RED)
            self:addTimer(100, function() self:fill(Color.WHITE) end)
            self:removeAfter(100)
            
            score=score+1
            txtScore:setString(tostring(score))
        end    
    end

    function br10:update()
        local x,y = self:getXY()
        if self:collectHit('ball') ~= nil then
            self:fill(Color.RED)
            self:addTimer(100, function() self:fill(Color.WHITE) end)
            self:removeAfter(100)
            
            score=score+1
            txtScore:setString(tostring(score))
        end    
    end

    


    








end








-- 아래의 함수 네 개 중 필요한 것만 선택하여 작성한다.
--[[
function scene:beforeShow(stage)
    -- 화면에 scene이 들어오기 직전에 수행되어야 하는 코드 작성
    print('ingame:beforshow()')
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
    print('ingame:afterShow()')
end
--]]

--[[
function scene:beforeHide(stage)
    -- 화면에서 scene이 나가기 직전에 수행되어야 하는 코드 작성
end
--]]

return scene