-- ============================================================
-- ALLIANCE TOWER DEFENSE - MACRO v5.5
-- RECORD / STOP / PLAY + zapis do pliku
-- ============================================================

local lp = game:GetService("Players").LocalPlayer
local CoreGui = game:GetService("CoreGui")

-- ===== GUI =====
local old = CoreGui:FindFirstChild("MacroUI")
if old then old:Destroy() end

local sg = Instance.new("ScreenGui")
sg.Name = "MacroUI"
sg.DisplayOrder = 999
sg.IgnoreGuiInset = true
sg.ResetOnSpawn = false
sg.Parent = CoreGui

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 340, 0, 280)
main.Position = UDim2.new(1, -360, 0, 60)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
main.Parent = sg

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 28)
title.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.Text = "TD MACRO v5.5"
title.Parent = main

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 20)
statusLabel.Position = UDim2.new(0, 10, 0, 34)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
statusLabel.Font = Enum.Font.Code
statusLabel.TextSize = 12
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Text = "Status: Idle"
statusLabel.Parent = main

local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(1, -20, 0, 20)
infoLabel.Position = UDim2.new(0, 10, 0, 56)
infoLabel.BackgroundTransparency = 1
infoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
infoLabel.Font = Enum.Font.Code
infoLabel.TextSize = 11
infoLabel.TextXAlignment = Enum.TextXAlignment.Left
infoLabel.Text = "Akcje: 0"
infoLabel.Parent = main

local btnContainer = Instance.new("Frame")
btnContainer.Size = UDim2.new(1, -20, 0, 40)
btnContainer.Position = UDim2.new(0, 10, 0, 82)
btnContainer.BackgroundTransparency = 1
btnContainer.Parent = main

local btnLayout = Instance.new("UIListLayout")
btnLayout.FillDirection = Enum.FillDirection.Horizontal
btnLayout.Padding = UDim.new(0, 8)
btnLayout.Parent = btnContainer

local logFrame = Instance.new("ScrollingFrame")
logFrame.Size = UDim2.new(1, -20, 0, 130)
logFrame.Position = UDim2.new(0, 10, 0, 130)
logFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
logFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
logFrame.ScrollBarThickness = 4
logFrame.Parent = main

local logLayout = Instance.new("UIListLayout")
logLayout.Parent = logFrame

local function log(s, color)
    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1, -6, 0, 14)
    t.BackgroundTransparency = 1
    t.TextColor3 = color or Color3.fromRGB(150, 255, 150)
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.Font = Enum.Font.Code
    t.TextSize = 10
    t.Text = s
    t.Parent = logFrame
end

-- ===== STAN =====
local SAVE_FILE = "makro_td.json"
local state = {
    mode = "idle",
    actions = {},
    recordStart = 0,
}

local function getCash()
    local c = lp.leaderstats and lp.leaderstats:FindFirstChild("Cash")
    return c and c.Value or 0
end

local function updateStatus()
    if state.mode == "recording" then
        statusLabel.Text = "Status: NAGRYWANIE..."
        statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
    elseif state.mode == "playing" then
        statusLabel.Text = "Status: ODTWARZANIE..."
        statusLabel.TextColor3 = Color3.fromRGB(80, 200, 255)
    else
        statusLabel.Text = "Status: Idle"
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
    end
    infoLabel.Text = "Akcje: " .. #state.actions .. "  |  Kasa: " .. getCash()
end

-- LENIWE POBIERANIE REMOTOW
local _Place = nil
local function getPlace()
    if _Place then return _Place end
    local RS = game:GetService("ReplicatedStorage")
    local RF = RS:FindFirstChild("RemoteFunctions")
    if not RF then
        log("BLAD: brak RemoteFunctions", Color3.fromRGB(255, 100, 100))
        return nil
    end
    local p = RF:FindFirstChild("PlaceTower")
    if not p then
        log("BLAD: brak PlaceTower", Color3.fromRGB(255, 100, 100))
        return nil
    end
    _Place = p
    log("PlaceTower znalezione", Color3.fromRGB(0, 255, 100))
    return _Place
end

-- ZAPIS
local function saveToFile()
    local ok, err = pcall(function()
        local lines = {}
        table.insert(lines, "{")
        table.insert(lines, '  "version": 1,')
        table.insert(lines, '  "actions": [')
        for i, a in ipairs(state.actions) do
            local parts = {}
            for k, v in pairs(a) do
                if type(v) == "string" then
                    table.insert(parts, '"' .. k .. '":"' .. v .. '"')
                else
                    table.insert(parts, '"' .. k .. '":' .. tostring(v))
                end
            end
            local comma = (i < #state.actions) and "," or ""
            table.insert(lines, '    {' .. table.concat(parts, ",") .. '}' .. comma)
        end
        table.insert(lines, '  ]')
        table.insert(lines, '}')
        writefile(SAVE_FILE, table.concat(lines, "\n"))
    end)
    if ok then
        log("Zapisano " .. #state.actions .. " akcji", Color3.fromRGB(0, 255, 100))
    else
        log("BLAD zapisu: " .. tostring(err), Color3.fromRGB(255, 100, 100))
    end
end

local function loadFromFile()
    if not isfile(SAVE_FILE) then
        log("Brak pliku " .. SAVE_FILE, Color3.fromRGB(255, 200, 0))
        return false
    end
    local ok, content = pcall(function() return readfile(SAVE_FILE) end)
    if not ok then
        log("BLAD readfile: " .. tostring(content), Color3.fromRGB(255, 100, 100))
        return false
    end
    state.actions = {}
    for line in content:gmatch("[^\n]+") do
        local t = line:match('"t":([%d%.]+)')
        local typ = line:match('"type":"([^"]+)"')
        local unit = line:match('"unit":"([^"]+)"')
        local x = line:match('"x":(%-?[%d%.]+)')
        local y = line:match('"y":(%-?[%d%.]+)')
        local z = line:match('"z":(%-?[%d%.]+)')
        if t and typ then
            local action = {t = tonumber(t), type = typ}
            if unit then action.unit = unit end
            if x and y and z then
                action.x = tonumber(x); action.y = tonumber(y); action.z = tonumber(z)
            end
            table.insert(state.actions, action)
        end
    end
    log("Wczytano " .. #state.actions .. " akcji", Color3.fromRGB(0, 255, 100))
    return true
end

-- HOOK
local recordingHook = false
local function startRecordingHook()
    if recordingHook then return end
    recordingHook = true
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        if state.mode == "recording" and typeof(self) == "Instance" and self.Name == "PlaceTower" then
            if method == "InvokeServer" or method == "FireServer" then
                local args = {...}
                local unit = args[1]
                local cf = args[2]
                local t = tick() - state.recordStart
                if typeof(cf) == "CFrame" then
                    table.insert(state.actions, {
                        t = tonumber(string.format("%.2f", t)),
                        type = "PlaceTower",
                        unit = tostring(unit),
                        x = tonumber(string.format("%.2f", cf.Position.X)),
                        y = tonumber(string.format("%.2f", cf.Position.Y)),
                        z = tonumber(string.format("%.2f", cf.Position.Z)),
                    })
                    log(string.format("[REC] %.2fs %s", t, tostring(unit)), Color3.fromRGB(255, 100, 100))
                    updateStatus()
                end
            end
        end
        return oldNamecall(self, ...)
    end)
end

local function playActions()
    if #state.actions == 0 then
        log("Brak akcji!", Color3.fromRGB(255, 200, 0))
        return
    end
    local Place = getPlace()
    if not Place then
        log("Nie moge odtworzyc - brak PlaceTower", Color3.fromRGB(255, 100, 100))
        return
    end
    state.mode = "playing"
    updateStatus()
    task.spawn(function()
        local startT = tick()
        for i, a in ipairs(state.actions) do
            if state.mode ~= "playing" then return end
            local targetTime = startT + a.t
            local waitTime = targetTime - tick()
            if waitTime > 0 then task.wait(waitTime) end
            if a.type == "PlaceTower" then
                local placed = false
                local attempts = 0
                while not placed and attempts < 20 do
                    if state.mode ~= "playing" then return end
                    local cashBefore = getCash()
                    if cashBefore < 100 then
                        task.wait(1)
                        attempts = attempts + 1
                    else
                        pcall(function()
                            Place:InvokeServer(a.unit, CFrame.new(a.x, a.y, a.z))
                        end)
                        task.wait(0.3)
                        if getCash() < cashBefore then
                            placed = true
                            log(string.format("[%d/%d] OK", i, #state.actions), Color3.fromRGB(0, 255, 100))
                        else
                            attempts = attempts + 1
                            task.wait(0.8)
                        end
                    end
                end
                if not placed then
                    log(string.format("[%d/%d] FAIL", i, #state.actions), Color3.fromRGB(255, 100, 100))
                end
            end
            updateStatus()
        end
        log("=== KONIEC ===", Color3.fromRGB(0, 255, 100))
        state.mode = "idle"
        updateStatus()
    end)
end

-- PRZYCISKI
local function makeButton(text, color, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 100, 1, 0)
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.Text = text
    btn.Parent = btnContainer
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = btn
    btn.MouseButton1Click:Connect(callback)
    return btn
end

makeButton("RECORD", Color3.fromRGB(200, 60, 60), function()
    if state.mode ~= "idle" then return end
    state.actions = {}
    state.recordStart = tick()
    state.mode = "recording"
    startRecordingHook()
    log("=== REC START ===", Color3.fromRGB(255, 100, 100))
    updateStatus()
end)

makeButton("STOP", Color3.fromRGB(200, 150, 60), function()
    if state.mode == "recording" then
        state.mode = "idle"
        log("=== REC STOP ===", Color3.fromRGB(255, 200, 0))
        saveToFile()
    elseif state.mode == "playing" then
        state.mode = "idle"
        log("=== PLAY STOP ===", Color3.fromRGB(255, 200, 0))
    end
    updateStatus()
end)

makeButton("PLAY", Color3.fromRGB(60, 150, 60), function()
    if state.mode ~= "idle" then return end
    if #state.actions == 0 then
        loadFromFile()
    end
    if #state.actions == 0 then
        log("Brak nagrania!", Color3.fromRGB(255, 200, 0))
        return
    end
    playActions()
end)

-- Start
log("=== TD MACRO v5.5 ===", Color3.fromRGB(0, 255, 255))
log("Kliknij RECORD aby nagrac", Color3.fromRGB(200, 200, 200))
log("Plik: " .. SAVE_FILE .. " (" .. (isfile(SAVE_FILE) and "ISTNIEJE" or "brak") .. ")", Color3.fromRGB(200, 200, 200))
updateStatus()
