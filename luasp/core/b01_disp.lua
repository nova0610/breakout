--------------------------------------------------------------------------------
-- 2021/08/17:scale에 대해서 아래와 같이 정한다.
-- self.__bds, self.__bdxs, self.__bdys를 둔다
-- setxscale(xs) 나 setyscale(ys)은 scale값도 (xs+ys)/2값으로 갱신한다.
--------------------------------------------------------------------------------
local Timer = Timer
local timers = Timer.__tmrs -- 2020/06/24:Disp:remove()함수 내에서 직접 접근
local luasp = _luasopia
-- local cx, cy = luasp.centerx, luasp.centery -- 정수값들이다
local _nxt = next

local int, min = math.floor, math.min
local rand = rand
--------------------------------------------------------------------------------
-- 2020/02/06: 모든 set함수는 self를 반환하도록 수정됨
-- 향후: 내부코드는 속도를 조금이라도 높이기 위해서 self.__bd객체를 직접 접근한다
----------------------------------------------------------------------------------
Display = class()
--------------------------------------------------------------------------------
-- static members of this class ------------------------------------------------
--------------------------------------------------------------------------------
local dobjs = {} -- Display OBJectS
Display.__dobjs = dobjs

-- tagged display object (tdobj) 들의 객체를 저장하는 테이블
local tdobj = {}  -- Display Tagged OBJect
Display.__tdobj = tdobj
-------------------------------------------------------------------------------
-- static public method
-------------------------------------------------------------------------------
--2020/06/20 dobj[self]=self로 저장하기 때문에 self:remove()안에서 바로 삭제 가능
-- 따라서 updateAll()함수의 구조가 (위의 함수와 비교해서) 매우 간단해 진다
Display.updateAll = function(isoddfrm)

    -- for _, obj in pairs(dobjs) do --for k = #dobjs,1,-1 do local obj = dobjs[k]
    for _, obj in _nxt, dobjs do

        obj:__upd__()

        -- 2021/09/03: 홀수프레임과 짝수 프레임에서만 호출할 upd함수들 실행
        -- 궂이 매프레임마다 호출할 필요가 없는 update함수는
        -- iupd1, iupd2 둘 중 하나를 임의로 선정해서 거기에 집어넣는다
        for _, fn in _nxt, obj.__iupd12[isoddfrm] do
            if fn(obj) then -- 만약 fn(self)==true 라면 곧바로 삭제하고 리턴
                obj:remove()
                break
            end
        end
        
    end

end


-- debugmode 일 때만 사용되는 함수 (따라서 약간의 overhead는 상관없음)
Display.__getNumObjs = function() 

    local cnt = 0
    for _, obj in _nxt, dobjs do
        if not obj.__nocnt then
            cnt = cnt + 1
        end
    end
    return cnt
    
end

-------------------------------------------------------------------------------
-- public methods
-------------------------------------------------------------------------------

function Display:init()

    --2020/02/16: screen에 add하는 경우 중앙에 위치시킨다.
    --2020/08/23: parent가 파라메터로 넘어오지 않게금 수정
    self.__pr = luasp.stage
    self.__pr:add(self)

    --2021/08/15:pixelmode에서 cx,cy값이 변하므로 luasp.centerx/y값을 직접 읽어야 한다
    -- xy()메서드 안에서 self.__bdx, self.__bdy가 생성된다.
    self:setxy(luasp.centerx, luasp.centery)

    self.__bd.__obj = self -- body에 원객체를 등록 (_Grp의 __del함수에서 사용)
    
    dobjs[self] = self
    self.__iupds = {} -- 내부 update함수들을 저장할 테이블(모든 frame에서 호출)
    self.__iupd12 = {
        [true]={},  -- 홀수frm(isoddfrm==true)에 호출될 update함수들을 저장할 테이블
        [false]={},  -- 짝수frm(isoddfrm==false)에 호출될 update함수들을 저장할 테이블
    }
    
    --2021/08/14:pixel모드에서 xy값을 정위치에 놓기위해
    -- __bdx,__bdy 저장된 (실수)값을 int()변환하여 설정한다.
    self.__bda = 1  -- alpha of the body
    self.__bdrd = 0 -- rotational angle in deg of the body
    self.__bds, self.__bdxs, self.__bdys = 1, 1, 1 -- scale, xscale, yscale

end


-- This function is called in every frames
function Display:__upd__()
    
    if self.ontouch and self.__tch==nil then self:__touchon() end
    if self.ontap and self.__tap==nil then self:__tapon() end

    if self.__noupd then return end -- self.__noupd==true이면 갱신 금지------------

    -- if self.__mv then self:__playmv__() end  -- move{}
    -- if self.__tr then self:__playtr__() end -- shift{}
    
    -- 2020/02/16 call user-defined update() if exists
    if self.update and self:update() then

        return self:remove() -- 꼬리호출로 즉시 종료

    end

    --2020/07/01 내부갱신함수들이 있다면 호출
    -- self.__iupds가 nil인지를 check하는 것이 성능에 별로 효과가 없을 것 같다
    for _, fn in _nxt, self.__iupds do

        if fn(self) then -- 만약 fn(self)==true 라면 곧바로 삭제하고 리턴

            return self:remove()
            
        end

    end

end


-- 2021/08/10: addtimer()로 이름을 바꿈
function Display:addtimer(...)

    self.__tmrs = self.__tmrs or {}
    local tmr = Timer(...)
    tmr.__dobj = self -- callback함수의 첫 번째 인자로 넘긴다.
    self.__tmrs[tmr] = tmr
    --return self
    return tmr -- 2020/03/27 수정

end
-- Display.timer = Display.addtimer -- will be deprecaed in future



function Display:resumeupdate()

    self.__noupd = false
    --타이머도 다시 시작해야 한다.(2020/07/01)
    return self

end


function Display:stopupdate()

    self.__noupd = true
    --타이머도 다 멈추어야 한다.(2020/07/01)
    return self

end


--2020/03/02: group:add(child) returns child
function Display:addto(group)

    group:add(self) -- this returns group object
    return self

end


--function Display:remove() self.__rm = true end
function Display:isremoved() return self.__bd==nil end


--2020/06/12
function Display:getparent() return self.__pr end


--2020/07/01 : handle Internal UPDateS (__iupds)
function Display:__addupd__( fn )

    -- self.__iupds = self.__iupds or {}
    self.__iupds[fn] = fn
    return self

end

--2021/09/03 : 격프레임마다 호출되는 함수 등록
-- 홀수프레임, 짝수프레임 어느 쪽일지는 성능 분산을 위해서 임의로 정한다
function Display:__addupd12__( fn )

    self.__iupd12[rand(2)==1][fn] = fn -- rand(2)는 1과 2중 하나만 발생
    return self

end


--2021/08/09 : remove internal update function
function Display:__rmupd__( fn )

    -- if self.__iupds == nil or fn==nil then return end
    if fn==nil then return end
    self.__iupds[fn] = nil

    -- if self.__iupds is empty then set that nil
    -- if _nxt(self.__iupds) == nil then  self.__iupds = nil  end

end


--2020/08/27: added
function Display:getwidth()

    return self.__wdt or 0

end


function Display:getheight()

    return self.__hgt or 0

end


--2020/03/03 추가
function Display:tag(name)

    -- 2021/05/25에 아래 if문 추가
    -- tag()메서드를 통해서 기존의 name을 바꿀 수 있다
    if self.__tag then -- 기존의 이름이 있다면 
        tdobj[self.__tag][self] = nil -- tdobj테이블에서 제거
    end

    self.__tag = name
    -- 2020/06/21 tagged객체는 아래와 같이 tdobj에 별도로 (중복) 저장
    if tdobj[name] == nil then
        tdobj[name] = {[self]=self}
    else
        tdobj[name][self] = self
    end
    return self

end

--2020/06/21 tdobj에 tagged객체를 따로 저장하기 때문에
-- collect()함수에서 매번 for반복문으로 tagged객체를 모을 필요가 없어졌음
function Display.collect(name)

    return tdobj[name] or {}

end

--2021/05/25 added : 기존의 tag를 제거
function Display:detag()

    if self.__tag then -- 기존의 이름이 있다면 
        tdobj[self.__tag][self] = nil -- tdobj테이블에서 제거
        self.__tag = nil
    end
    return self

end


-- 2021/08/14
function Display:getanchor()
    -- return self.__bd:getAnchorPosition()
    -- return self.__bd.anchorX, self.__bd.anchorY --solar2d
    return self.__apx, self.__apy
end


function Display:getx()
    -- return self.__bd:getX() -- gid
    -- return self.__bd.x --solar2d
    return self.__bdx
end


function Display:gety()
    -- return self.__bd:getY() --gid
     -- return self.__bd.y --solar2d
    return self.__bdy
end


function Display:getxy()
    -- return self.__bd:getPosition() --gid
    -- return self.__bd.x, self.__bd.y --solar2d
    return self.__bdx, self.__bdy
end


function Display:getalpha()
    -- return self.__bd:getAlpha() -- gideros
    -- return self.__bd.alpha -- solar2d
    return self.__bda
end


function Display:getrot()
    -- return self.__bd:getRotation() end -- gideros(2020/02/26)
    -- return self.__bd.rotation --solar2d
    return self.__bdrd
end


function Display:getxscale()

    -- return self.__bd:getScaleX() -- gideros
    -- return self.__bd.xScale -- solar2d
    return self.__bdxs

end


function Display:getyscale()

    -- return self.__bd:getScaleY() -- gideros
    -- return self.__bd.yScale -- gideros
    return self.__bdys

end


function Display:getscale()

    -- gideros getScale() returns xScale, yScale, and zScale
    -- local sx, sy = self.__bd:getScale(); return (sx+sy)/2 -- gideros
    -- return (self.__bd.xScale + self.__bd.yScale)/2 -- solar2d
    return self.__bds

end

-- 2020/02/04:args.init을 제거하고 대신 set()메서드 추가
-- 2021/08/17:set()메서드를 공통으로 변경
function Display:set(arg)
    
    if arg.x        then self:setx(arg.x) end
    if arg.y        then self:sety(arg.y) end
    if arg.alpha    then self:setalpha(arg.alpha) end
    if arg.rot      then self:setrot(arg.rot) end
    if arg.xscale   then self:setxscale(arg.xscale) end
    if arg.yscale   then self:setyscale(arg.yscale) end
    if arg.scale    then self:setscale(arg.scale) end

    if arg.dx        then self:setdx(arg.dx) end
    if arg.dy        then self:setdy(arg.dy) end
    if arg.dalpha    then self:setdalpha(arg.dalpha) end
    if arg.drot      then self:setdrot(arg.drot) end
    if arg.dxscale   then self:setdxscale(arg.dxscale) end
    if arg.dyscale   then self:setdyscale(arg.dyscale) end
    if arg.dscale    then self:setdscale(arg.dscale) end

    return self

end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
if _Gideros then -- gideros
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
    
    function Display:isvisible()

        return self.__bd:isVisible()

    end


    -- 2020/02/18 (Gideros), 2021/04/22 다시 정리 ##################################
    function Display:setx(v)

        self.__bdx = v
        self.__bd:setX(int(v))
        return self

    end


    function Display:sety(v)

        self.__bdy = v
        self.__bd:setY(int(v))
        return self

    end


    function Display:setxy(x,y)

        self.__bdx, self.__bdy = x, y
        self.__bd:setPosition(int(x),int(y))
        return self

    end


    -- Gideros는 1이 넘으면 이미지가 열화(?)되고, Solar2D는 자동으로 1로 세팅됨
    function Display:setalpha(v)

        self.__bda = v>1 and 1 or v
        self.__bd:setAlpha(self.__bda)
        return self

    end


    function Display:setrot(deg) -- gideros

        self.__bdrd = deg
        self.__bd:setRotation(deg)
        return self

    end -- 2020/02/26


    -- gid는 setScale(v)라고 하면 scaleX, scaleY(, scaleZ)에 모두 v가 적용됨
    function Display:setscale(s)

        self.__bds, self.__bdxs, self.__bdys = s, s, s
        self.__bd:setScale(s)


        -- -- setscale()메서드가 호출되었을 때만 hit.r을 재조정한다.
        -- if self.__ccc then -- 2021/08/21:added
        --     local r = self.__ccc.r0*s
        --     self.__ccc.r = r
        --     self.__ccc.r2 = r, r*r
        -- end

        return self

    end


    function Display:setxyscale(xs, ys)

        self.__bds, self.__bdxs, self.__bdys = (xs+ys)*0.5, xs, ys
        self.__bd:setScale(xs, ys)

        -- -- setscale()메서드가 호출되었을 때만 hit.r을 재조정한다.
        -- -- xscale과 yscale가 다를 경우에는 작은 값을 기준으로 한다.
        -- if self.__ccc then -- 2021/08/21:added
        --     local mins = min(xs, ys)
        --     local r = self.__ccc.r0*mins
        --     self.__ccc.r = r
        --     self.__ccc.r2 = r, r*r
        -- end

        return self

    end


    -- 2020/04/26 : alpha가 1초과면 1로 세팅한다.
    -- xs()와 ys()는 x and scale, y and scale로 혼동할 여지가 있어서 삭제
    function Display:setxscale(xs)

        self.__bdxs = xs
        self.__bds = (xs+self.__bdys)*0.5 --2021/08/17
        self.__bd:setScaleX(xs)

        -- -- setscale()메서드가 호출되었을 때만 hit.r을 재조정한다.
        -- -- xscale과 yscale가 다를 경우에는 작은 값을 기준으로 한다.
        -- if self.__ccc then -- 2021/08/21:added
        --     local mins = min(xs, self.__bdys)
        --     local r = self.__ccc.r0*mins
        --     self.__ccc.r = r
        --     self.__ccc.r2 = r, r*r
        -- end

        return self

    end

    function Display:setyscale(ys)

        self.__bdys = ys
        self.__bds = (self.__bdxs+ys)*0.5 --2021/08/17
        self.__bd:setScaleY(ys)

        -- -- setscale()메서드가 호출되었을 때만 hit.r을 재조정한다.
        -- -- xscale과 yscale가 다를 경우에는 작은 값을 기준으로 한다.
        -- if self.__ccc then -- 2021/08/21:added
        --     local mins = min(self.__bdxs, ys)
        --     local r = self.__ccc.r0*mins
        --     self.__ccc.r = r
        --     self.__ccc.r2 = r, r*r
        -- end

        return self

    end
    

    --[[
    function Display:setxyrot(x,y,deg)

        self.__bdx, self.__bdy, self.__bdrd = x,y,deg
        self.__bd:setPosition(x,y)
        self.__bd:setRotation(deg)
        return self

    end
    --]]


    -- setanchor()는 각각의 클래스에서 별도로 오버로딩된다
    function Display:setanchor(ax, ay)

        self.__apx, self.__apy = ax, ay
        self.__bd:setAnchorPoint(ax, ay)
        return self

    end
    
    -- 2020/02/18 ---------------------------------------------------------
    
    function Display:hide() self.__bd:setVisible(false); return self end
    function Display:show() self.__bd:setVisible(true); return self end
    function Display:setvisible(v) self.__bd:setVisible(v); return self end

    function Display:tint(r,g,b)

        self.__bd:setColorTransform(r, g ,b)
        return self

    end
    

    -- 2020/06/08 : 추가 
    function Display:getglobalxy(x,y)

        return self.__bd:localToGlobal(x or 0,y or 0)
        
    end

--------------------------------------------------------------------------------    
--------------------------------------------------------------------------------    
elseif _Corona then -- if coronaSDK
--------------------------------------------------------------------------------    
--------------------------------------------------------------------------------    
    
    function Display:isvisible()
        return self.__bd.isVisible
    end


    -- 2020/02/18 시험메서드 (Solar2D)###############################################
    function Display:setx(v)

        self.__bdx = v
        self.__bd.x = int(v)
        return self

    end
    
    function Display:sety(v)

        self.__bdy = v
        self.__bd.y = int(v)
        return self

    end

    function Display:setxy(x,y)

        self.__bdx, self.__bdy = x, y
        self.__bd.x, self.__bd.y = int(x), int(y)
        return self

    end


    function Display:setrot(deg) -- solar2d

        self.__bdrd = deg
        self.__bd.rotation = deg
        return self

    end

    
    function Display:setscale(s)

        self.__bds, self.__bdxs, self.__bdys = s, s, s
        self.__bd.xScale, self.__bd.yScale = s, s

        -- -- setscale()메서드가 호출되었을 때만 hit.r을 재조정한다.
        -- -- xscale과 yscale가 틀릴 경우에는 ccc.r을 조정하지 않는다.
        -- if self.__ccc then -- 2021/08/21:added
        --     local r = self.__ccc.r0*s
        --     self.__ccc.r = r
        --     self.__ccc.r2 = r, r*r
        -- end

        return self

    end


    function Display:setxyscale(xs, ys)

        self.__bds, self.__bdxs, self.__bdys = (xs+ys)*0.5, xs, ys
        self.__bd.xScale, self.__bd.yScale = xs, ys

        -- -- setscale()메서드가 호출되었을 때만 hit.r을 재조정한다.
        -- -- xscale과 yscale가 다를 경우에는 작은 값을 기준으로 한다.
        -- if self.__ccc then -- 2021/08/21:added
        --     local mins = min(xs, ys)
        --     local r = self.__ccc.r0*mins
        --     self.__ccc.r = r
        --     self.__ccc.r2 = r, r*r
        -- end


        return self

    end


    function Display:setalpha(v)
        
        self.__bda = v
        self.__bd.alpha = v, v
        return self

    end

    
    function Display:setxscale(xs)

        self.__bdxs = xs
        self.__bds = (xs+self.__bdys)*0.5 --2021/08/17
        self.__bd.xScale = xs

        -- -- setscale()메서드가 호출되었을 때만 hit.r을 재조정한다.
        -- -- xscale과 yscale가 다를 경우에는 작은 값을 기준으로 한다.
        -- if self.__ccc then -- 2021/08/21:added
        --     local mins = min(xs, self.__bdys)
        --     local r = self.__ccc.r0*mins
        --     self.__ccc.r = r
        --     self.__ccc.r2 = r, r*r
        -- end


        return self

    end


    function Display:setyscale(ys)

        self.__bdys = ys
        self.__bds = (self.__bdxs+ys)*0.5 --2021/08/17
        self.__bd.yScale = ys

        -- -- setscale()메서드가 호출되었을 때만 hit.r을 재조정한다.
        -- -- xscale과 yscale가 다를 경우에는 작은 값을 기준으로 한다.
        -- if self.__ccc then -- 2021/08/21:added
        --     local mins = min(self.__bdxs, ys)
        --     local r = self.__ccc.r0*mins
        --     self.__ccc.r = r
        --     self.__ccc.r2 = r, r*r
        -- end

        return self

    end


    --[[ will be deprecated
    function Display:setxyrot(x,y,deg)

        self.__bdx, self.__bdy, self.__bdrd = x,y,deg
        self.__bd.x, self.__bd.y = x, y
        self.__bd.rotation = deg
        return self

    end
    --]]

    
    -- 추상메서드:차일드에서 각자 구현해야한다
    function Display:setanchor(x, y)

        self.__apx, self.__apy = ax, ay
        self.__bd.anchorX, self.__bd.anchorY = x,y
        return self

    end

    -- 2020/02/18 ---------------------------------------------------------

    function Display:hide() self.__bd.isVisible = false; return self end
    function Display:show() self.__bd.isVisible = true; return self end
    function Display:setvisible(v) self.__bd.isVisible = v;return self end
    

    -- 2020/06/08 : 추가 
    function Display:getglobalxy(x,y)

        return self.__bd:localToContent(x or 0,y or 0)
        
    end


    function Display:tint(r,g,b)

        self.__bd:setFillColor(r,g,b)
        return self
        
    end


end -- elseif _Corona then

--2021/04/21 :set메서드의 축명함수들 추가
-- (set method는 혼동을 줄이기위해서 아래의 두 개만으로 정리)
-- Display.x = Display.setx
-- Display.y = Display.sety
-- Display.rot = Display.setrot
-- Display.alpha = Display.setalpha
-- Display.scale = Display.setscale
-- Display.xyscale = Display.setxyscale
-- Display.xscale = Display.setxscale
-- Display.yscale = Display.setyscale

-- Display.xy = Display.setxy
-- -- Display.xyrot = Display.setxyrot -- deprecated
-- Display.anchor = Display.setanchor