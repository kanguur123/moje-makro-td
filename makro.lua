local lp=game:GetService("Players").LocalPlayer
local CG=game:GetService("CoreGui")
local RS=game:GetService("ReplicatedStorage")
local SF="makro_td.json"
local old=CG:FindFirstChild("MacroUI")
if old then old:Destroy() end
local sg=Instance.new("ScreenGui")
sg.Name="MacroUI"
sg.DisplayOrder=999
sg.IgnoreGuiInset=true
sg.ResetOnSpawn=false
sg.Parent=CG
local main=Instance.new("Frame")
main.Size=UDim2.new(0,340,0,280)
main.Position=UDim2.new(1,-360,0,60)
main.BackgroundColor3=Color3.fromRGB(20,20,25)
main.Parent=sg
local cr=Instance.new("UICorner")
cr.CornerRadius=UDim.new(0,8)
cr.Parent=main
local ti=Instance.new("TextLabel")
ti.Size=UDim2.new(1,0,0,28)
ti.BackgroundColor3=Color3.fromRGB(30,30,40)
ti.TextColor3=Color3.fromRGB(255,255,255)
ti.Font=Enum.Font.GothamBold
ti.TextSize=14
ti.Text="TD MACRO v8.1"
ti.Parent=main
local sl=Instance.new("TextLabel")
sl.Size=UDim2.new(1,-20,0,20)
sl.Position=UDim2.new(0,10,0,34)
sl.BackgroundTransparency=1
sl.TextColor3=Color3.fromRGB(0,255,100)
sl.Font=Enum.Font.Code
sl.TextSize=12
sl.TextXAlignment=Enum.TextXAlignment.Left
sl.Text="Idle"
sl.Parent=main
local il=Instance.new("TextLabel")
il.Size=UDim2.new(1,-20,0,20)
il.Position=UDim2.new(0,10,0,56)
il.BackgroundTransparency=1
il.TextColor3=Color3.fromRGB(200,200,200)
il.Font=Enum.Font.Code
il.TextSize=11
il.TextXAlignment=Enum.TextXAlignment.Left
il.Text="Akcje: 0"
il.Parent=main
local bc=Instance.new("Frame")
bc.Size=UDim2.new(1,-20,0,40)
bc.Position=UDim2.new(0,10,0,82)
bc.BackgroundTransparency=1
bc.Parent=main
local bl=Instance.new("UIListLayout")
bl.FillDirection=Enum.FillDirection.Horizontal
bl.Padding=UDim.new(0,8)
bl.Parent=bc
local lf=Instance.new("ScrollingFrame")
lf.Size=UDim2.new(1,-20,0,130)
lf.Position=UDim2.new(0,10,0,130)
lf.BackgroundColor3=Color3.fromRGB(10,10,15)
lf.AutomaticCanvasSize=Enum.AutomaticSize.Y
lf.ScrollBarThickness=4
lf.Parent=main
local ll=Instance.new("UIListLayout")
ll.Parent=lf
local function log(s,c)
local t=Instance.new("TextLabel")
t.Size=UDim2.new(1,-6,0,14)
t.BackgroundTransparency=1
t.TextColor3=c or Color3.fromRGB(150,255,150)
t.TextXAlignment=Enum.TextXAlignment.Left
t.Font=Enum.Font.Code
t.TextSize=10
t.Text=s
t.Parent=lf
end
local st={mode="idle",actions={},t0=0,known={},lastT=0,recConn=nil}
local function gc()
local x=lp.leaderstats and lp.leaderstats:FindFirstChild("Cash")
return x and x.Value or 0
end
local function us()
if st.mode=="recording" then sl.Text="REC..." sl.TextColor3=Color3.fromRGB(255,80,80)
elseif st.mode=="playing" then sl.Text="PLAY..." sl.TextColor3=Color3.fromRGB(80,200,255)
else sl.Text="Idle" sl.TextColor3=Color3.fromRGB(0,255,100) end
il.Text="Akcje: "..#st.actions.." | $"..gc()
end
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
if not root then
log("["..tower.Name.."] brak Root",Color3.fromRGB(255,150,0))
return
end
task.wait(0.1)
local p=root.Position
local key=string.format("%.1f_%.1f_%.1f",p.X,p.Y,p.Z)
if st.known[key] then return end
st.known[key]=true
local now=tick()-st.t0
if now-st.lastT<0.05 then now=st.lastT+0.05 end
st.lastT=now
table.insert(st.actions,{t=tonumber(string.format("%.2f",now)),type="PlaceTower",unit=tower.Name,x=tonumber(string.format("%.2f",p.X)),y=tonumber(string.format("%.2f",p.Y)),z=tonumber(string.format("%.2f",p.Z))})
log(string.format("[REC] %.2fs %s @ %.1f,%.1f,%.1f",now,tower.Name,p.X,p.Y,p.Z),Color3.fromRGB(255,100,100))
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
log("Nasluchuje nowych wiez",Color3.fromRGB(200,200,200))
end
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
local _P=nil
local function gp()
if _P then return _P end
local RF=RS:FindFirstChild("RemoteFunctions")
if not RF then log("brak RF",Color3.fromRGB(255,100,100)) return nil end
local p=RF:FindFirstChild("PlaceTower")
if not p then log("brak PlaceTower",Color3.fromRGB(255,100,100)) return nil end
_P=p
return p
end
local function play()
if #st.actions==0 then log("brak akcji!",Color3.fromRGB(255,200,0)) return end
local P=gp()
if not P then return end
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
local function mb(txt,col,cb)
local b=Instance.new("TextButton")
b.Size=UDim2.new(0,100,1,0)
b.BackgroundColor3=col
b.TextColor3=Color3.fromRGB(255,255,255)
b.Font=Enum.Font.GothamBold
b.TextSize=13
b.Text=txt
b.Parent=bc
local cc=Instance.new("UICorner")
cc.CornerRadius=UDim.new(0,6)
cc.Parent=b
b.MouseButton1Click:Connect(cb)
end
mb("RECORD",Color3.fromRGB(200,60,60),function()
if st.mode~="idle" then return end
st.actions={}
st.t0=tick()
st.mode="recording"
startRec()
log("=== REC ===",Color3.fromRGB(255,100,100))
us()
end)
mb("STOP",Color3.fromRGB(200,150,60),function()
if st.mode=="recording" then
st.mode="idle"
if st.recConn then st.recConn:Disconnect() st.recConn=nil end
log("=== STOP ===",Color3.fromRGB(255,200,0))
save()
elseif st.mode=="playing" then st.mode="idle" log("=== STOP ===",Color3.fromRGB(255,200,0)) end
us()
end)
mb("PLAY",Color3.fromRGB(60,150,60),function()
if st.mode~="idle" then return end
if #st.actions==0 then load() end
if #st.actions==0 then log("brak nagrania!",Color3.fromRGB(255,200,0)) return end
play()
end)
log("=== TD MACRO v8.1 ===",Color3.fromRGB(0,255,255))
log("Plik: "..(isfile(SF) and "JEST" or "brak"),Color3.fromRGB(200,200,200))
us()
