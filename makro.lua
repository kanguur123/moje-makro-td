local lp=game:GetService("Players").LocalPlayer
local CG=game:GetService("CoreGui")
local RS=game:GetService("ReplicatedStorage")
local SF="makro_td.json"
local old=CG:FindFirstChild("MacroUI")
if old then old:Destroy() end

-- ==== CLEAN GUI ====
local sg=Instance.new("ScreenGui")
sg.Name="MacroUI"
sg.DisplayOrder=999
sg.IgnoreGuiInset=true
sg.ResetOnSpawn=false
sg.Parent=CG

local main=Instance.new("Frame")
main.Size=UDim2.new(0,300,0,340)
main.Position=UDim2.new(1,-320,0,60)
main.BackgroundColor3=Color3.fromRGB(15,15,18)
main.BorderSizePixel=0
main.Parent=sg
local c1=Instance.new("UICorner") c1.CornerRadius=UDim.new(0,10) c1.Parent=main
local stk=Instance.new("UIStroke") stk.Color=Color3.fromRGB(40,40,50) stk.Thickness=1 stk.Parent=main

local ti=Instance.new("TextLabel")
ti.Size=UDim2.new(1,0,0,32)
ti.BackgroundTransparency=1
ti.TextColor3=Color3.fromRGB(255,255,255)
ti.Font=Enum.Font.GothamBold
ti.TextSize=15
ti.Text="TD MACRO"
ti.Parent=main

local sep=Instance.new("Frame")
sep.Size=UDim2.new(1,-20,0,1)
sep.Position=UDim2.new(0,10,0,34)
sep.BackgroundColor3=Color3.fromRGB(40,40,50)
sep.BorderSizePixel=0
sep.Parent=main

local sl=Instance.new("TextLabel")
sl.Size=UDim2.new(1,-20,0,18)
sl.Position=UDim2.new(0,10,0,42)
sl.BackgroundTransparency=1
sl.TextColor3=Color3.fromRGB(120,120,130)
sl.Font=Enum.Font.Gotham
sl.TextSize=11
sl.TextXAlignment=Enum.TextXAlignment.Left
sl.Text="Status: Idle"
sl.Parent=main

local il=Instance.new("TextLabel")
il.Size=UDim2.new(1,-20,0,18)
il.Position=UDim2.new(0,10,0,60)
il.BackgroundTransparency=1
il.TextColor3=Color3.fromRGB(120,120,130)
il.Font=Enum.Font.Gotham
il.TextSize=11
il.TextXAlignment=Enum.TextXAlignment.Left
il.Text="Akcje: 0 | $0"
il.Parent=main

-- Toggle Auto Skip
local togFrame=Instance.new("Frame")
togFrame.Size=UDim2.new(1,-20,0,26)
togFrame.Position=UDim2.new(0,10,0,84)
togFrame.BackgroundTransparency=1
togFrame.Parent=main

local togLbl=Instance.new("TextLabel")
togLbl.Size=UDim2.new(0,150,1,0)
togLbl.BackgroundTransparency=1
togLbl.TextColor3=Color3.fromRGB(200,200,210)
togLbl.Font=Enum.Font.Gotham
togLbl.TextSize=12
togLbl.TextXAlignment=Enum.TextXAlignment.Left
togLbl.Text="Auto Skip"
togLbl.Parent=togFrame

local togBtn=Instance.new("TextButton")
togBtn.Size=UDim2.new(0,50,1,0)
togBtn.Position=UDim2.new(1,-50,0,0)
togBtn.BackgroundColor3=Color3.fromRGB(40,40,50)
togBtn.TextColor3=Color3.fromRGB(200,200,200)
togBtn.Font=Enum.Font.GothamBold
togBtn.TextSize=11
togBtn.Text="OFF"
togBtn.BorderSizePixel=0
togBtn.Parent=togFrame
local c2=Instance.new("UICorner") c2.CornerRadius=UDim.new(0,5) c2.Parent=togBtn

local btnRow=Instance.new("Frame")
btnRow.Size=UDim2.new(1,-20,0,36)
btnRow.Position=UDim2.new(0,10,0,118)
btnRow.BackgroundTransparency=1
btnRow.Parent=main
local brl=Instance.new("UIListLayout")
brl.FillDirection=Enum.FillDirection.Horizontal
brl.Padding=UDim.new(0,6)
brl.Parent=btnRow

local lf=Instance.new("ScrollingFrame")
lf.Size=UDim2.new(1,-20,0,170)
lf.Position=UDim2.new(0,10,0,162)
lf.BackgroundColor3=Color3.fromRGB(10,10,12)
lf.BorderSizePixel=0
lf.AutomaticCanvasSize=Enum.AutomaticSize.Y
lf.ScrollBarThickness=3
lf.ScrollBarImageColor3=Color3.fromRGB(60,60,70)
lf.Parent=main
local c3=Instance.new("UICorner") c3.CornerRadius=UDim.new(0,6) c3.Parent=lf
local ll=Instance.new("UIListLayout") ll.Parent=lf
ll.Padding=UDim.new(0,2)

local function log(s,c)
local t=Instance.new("TextLabel")
t.Size=UDim2.new(1,-8,0,13)
t.BackgroundTransparency=1
t.TextColor3=c or Color3.fromRGB(140,200,140)
t.TextXAlignment=Enum.TextXAlignment.Left
t.Font=Enum.Font.Code
t.TextSize=10
t.Text=s
t.Parent=lf
end

local st={mode="idle",actions={},t0=0,known={},lastT=0,recConn=nil,autoSkip=false,skipConn=nil}

local function gc()
local x=lp.leaderstats and lp.leaderstats:FindFirstChild("Cash")
return x and x.Value or 0
end

local function us()
if st.mode=="recording" then sl.Text="Status: REC" sl.TextColor3=Color3.fromRGB(255,80,80)
elseif st.mode=="playing" then sl.Text="Status: PLAY" sl.TextColor3=Color3.fromRGB(80,200,255)
else sl.Text="Status: Idle" sl.TextColor3=Color3.fromRGB(120,120,130) end
il.Text="Akcje: "..#st.actions.." | $"..gc()
end

-- ==== AUTO SKIP ====
local function findSkipButton()
local pg=lp:FindFirstChild("PlayerGui")
if not pg then return nil end
local mg=pg:FindFirstChild("MainGameUI")
if not mg then return nil end
local skip=mg:FindFirstChild("UpSide")
if not skip then return nil end
skip=skip:FindFirstChild("Skip")
if not skip then return nil end
return skip:FindFirstChildWhichIsA("TextButton",true) or skip:FindFirstChildWhichIsA("ImageButton",true)
end

local function findSkipRemote()
local RE=RS:FindFirstChild("RemoteEvents")
if not RE then return nil end
return RE:FindFirstChild("SkipWaveVote")
end

local function doSkip()
local remote=findSkipRemote()
if remote then
pcall(function() remote:FireServer() end)
log("[SKIP] glos",Color3.fromRGB(120,200,255))
return
end
local btn=findSkipButton()
if btn then
pcall(function() btn:Activate() end)
log("[SKIP] klik",Color3.fromRGB(120,200,255))
end
end

local function startAutoSkip()
if st.skipConn then st.skipConn:Disconnect() end
st.skipConn=task.spawn(function()
while st.autoSkip do
task.wait(1)
if st.mode=="playing" or st.mode=="idle" then
local remote=findSkipRemote()
if remote then
-- sprawdz czy mozna glosowac (proba)
pcall(function() remote:FireServer() end)
end
end
end
end)
log("[AUTO] Skip ON",Color3.fromRGB(0,255,100))
end

local function stopAutoSkip()
st.autoSkip=false
if st.skipConn then
pcall(function() task.cancel(st.skipConn) end)
st.skipConn=nil
end
log("[AUTO] Skip OFF",Color3.fromRGB(255,150,150))
end

togBtn.MouseButton1Click:Connect(function()
st.autoSkip=not st.autoSkip
if st.autoSkip then
togBtn.Text="ON"
togBtn.BackgroundColor3=Color3.fromRGB(40,140,60)
togBtn.TextColor3=Color3.fromRGB(255,255,255)
startAutoSkip()
else
togBtn.Text="OFF"
togBtn.BackgroundColor3=Color3.fromRGB(40,40,50)
togBtn.TextColor3=Color3.fromRGB(200,200,200)
stopAutoSkip()
end
end)

-- ==== NAGRYWANIE ====
local function towerKey(t)
local r=t:FindFirstChild("HumanoidRootPart")
if not r then return nil end
local p=r.Position
return string.format("%.1f_%.1f_%.1f",p.X,p.Y,p.Z),t.Name,p
end

local function onNewTower(tower)
if st.mode~="recording" then return end
task.spawn(function()
local root
for i=1,20 do
root=tower:FindFirstChild("HumanoidRootPart")
if root then break end
task.wait(0.05)
end
if not root then return end
task.wait(0.1)
local p=root.Position
local key=string.format("%.1f_%.1f_%.1f",p.X,p.Y,p.Z)
if st.known[key] then return end
st.known[key]=true
local now=tick()-st.t0
if now-st.lastT<0.05 then now=st.lastT+0.05 end
st.lastT=now
table.insert(st.actions,{t=tonumber(string.format("%.2f",now)),type="PlaceTower",unit=tower.Name,x=tonumber(string.format("%.2f",p.X)),y=tonumber(string.format("%.2f",p.Y)),z=tonumber(string.format("%.2f",p.Z))})
log(string.format("[REC] %.2fs %s",now,tower.Name),Color3.fromRGB(255,100,100))
us()
end)
end

local function startRec()
st.known={}
st.lastT=0
local towers=workspace:FindFirstChild("Towers")
if towers then
for _,t in ipairs(towers:GetChildren()) do
local key=towerKey(t)
if key then st.known[key]=true end
end
if st.recConn then st.recConn:Disconnect() end
st.recConn=towers.ChildAdded:Connect(onNewTower)
end
end

-- ==== ZAPIS / ODCZYT ====
local function save()
local ok,err=pcall(function()
local l={"{",'  "actions": ['}
for i,a in ipairs(st.actions) do
local p={}
for k,v in pairs(a) do
if type(v)=="string" then table.insert(p,'"'..k..'":"'..v..'"')
else table.insert(p,'"'..k..'":'..tostring(v)) end
end
local cm=(i<#st.actions) and "," or ""
table.insert(l,'    {'..table.concat(p,",")..'}'..cm)
end
table.insert(l,"  ]\n}")
writefile(SF,table.concat(l,"\n"))
end)
if ok then log("Zapisano "..#st.actions,Color3.fromRGB(0,255,100))
else log("BLAD: "..tostring(err),Color3.fromRGB(255,100,100)) end
end

local function load()
if not isfile(SF) then log("brak pliku",Color3.fromRGB(255,200,0)) return end
local ok,c=pcall(function() return readfile(SF) end)
if not ok then log("BLAD read",Color3.fromRGB(255,100,100)) return end
st.actions={}
for line in c:gmatch("[^\n]+") do
local t=line:match('"t":([%d%.]+)')
local ty=line:match('"type":"([^"]+)"')
local u=line:match('"unit":"([^"]+)"')
local x=line:match('"x":(%-?[%d%.]+)')
local y=line:match('"y":(%-?[%d%.]+)')
local z=line:match('"z":(%-?[%d%.]+)')
if t and ty then
local a={t=tonumber(t),type=ty}
if u then a.unit=u end
if x and y and z then a.x=tonumber(x) a.y=tonumber(y) a.z=tonumber(z) end
table.insert(st.actions,a)
end
end
log("Wczytano "..#st.actions,Color3.fromRGB(0,255,100))
end

-- ==== ODTWARZANIE ====
local _P=nil
local function gp()
if _P then return _P end
local RF=RS:FindFirstChild("RemoteFunctions")
if not RF then return nil end
local p=RF:FindFirstChild("PlaceTower")
if not p then return nil end
_P=p
return p
end

local function play()
if #st.actions==0 then log("brak akcji!",Color3.fromRGB(255,200,0)) return end
local P=gp()
if not P then log("brak PlaceTower",Color3.fromRGB(255,100,100)) return end
st.mode="playing"
us()
task.spawn(function()
local st0=tick()
for i,a in ipairs(st.actions) do
if st.mode~="playing" then return end
local wt=st0+a.t-tick()
if wt>0 then task.wait(wt) end
if a.type=="PlaceTower" then
local done=false
local at=0
while not done and at<20 do
if st.mode~="playing" then return end
local cb=gc()
if cb<100 then task.wait(1) at=at+1
else
pcall(function() P:InvokeServer(a.unit,CFrame.new(a.x,a.y,a.z)) end)
task.wait(0.3)
if gc()<cb then done=true log(string.format("[%d/%d] OK",i,#st.actions),Color3.fromRGB(0,255,100))
else at=at+1 task.wait(0.8) end
end
end
if not done then log(string.format("[%d/%d] FAIL",i,#st.actions),Color3.fromRGB(255,100,100)) end
end
us()
end
log("=== KONIEC ===",Color3.fromRGB(0,255,100))
st.mode="idle"
us()
end)
end

-- ==== PRZYCISKI ====
local function mb(txt,col,cb)
local b=Instance.new("TextButton")
b.Size=UDim2.new(0,88,1,0)
b.BackgroundColor3=col
b.TextColor3=Color3.fromRGB(255,255,255)
b.Font=Enum.Font.GothamBold
b.TextSize=12
b.Text=txt
b.BorderSizePixel=0
b.Parent=btnRow
local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,6) c.Parent=b
b.MouseButton1Click:Connect(cb)
end

mb("RECORD",Color3.fromRGB(180,55,55),function()
if st.mode~="idle" then return end
st.actions={}
st.t0=tick()
st.mode="recording"
startRec()
log("=== REC ===",Color3.fromRGB(255,100,100))
us()
end)

mb("STOP",Color3.fromRGB(180,130,50),function()
if st.mode=="recording" then
st.mode="idle"
if st.recConn then st.recConn:Disconnect() st.recConn=nil end
log("=== STOP ===",Color3.fromRGB(255,200,0))
save()
elseif st.mode=="playing" then st.mode="idle" log("=== STOP ===",Color3.fromRGB(255,200,0)) end
us()
end)

mb("PLAY",Color3.fromRGB(55,130,55),function()
if st.mode~="idle" then return end
if #st.actions==0 then load() end
if #st.actions==0 then log("brak nagrania!",Color3.fromRGB(255,200,0)) return end
play()
end)

log("=== TD MACRO v9.0 ===",Color3.fromRGB(0,255,255))
log("Plik: "..(isfile(SF) and "JEST" or "brak"),Color3.fromRGB(180,180,180))
us()
