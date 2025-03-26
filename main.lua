local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/BeanyDio/script_hub/refs/heads/main/source.lua'))()

local Window = Rayfield:CreateWindow({
   Name = " Supernal Script Hub | Universal ",
   LoadingTitle = " Universal ",
   LoadingSubtitle = "by Supernal",
   ConfigurationSaving = {
      Enabled = false,
      FolderName = nil, -- Create a custom folder for your hub/game
      FileName = "Supernal Hub"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvitelink", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ABCD would be ABCD
      RememberJoins = true -- Set this to false to make them join the discord every time they load it up
   },
   KeySystem = false, -- Set this to true to use our key system
   KeySettings = {
      Title = "Key | Youtube Hub",
      Subtitle = "Key System",
      Note = "Key In Discord Server",
      FileName = "YoutubeHubKey1", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
      SaveKey = false, -- The user's key will be saved, but if you change the key, they will be unable to use your script
      GrabKeyFromSite = true, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      Key = {"https://pastebin.com/raw/AtgzSPWK"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
   }
})

local MainTab = Window:CreateTab("🏠 Home", nil) -- Title, Image
local MainSection = MainTab:CreateSection("Main")

Rayfield:Notify({
   Title = "You executed the script",
   Content = "Very cool gui",
   Duration = 5,
   Image = 0,
   Actions = { -- Notification Buttons
      Ignore = {
         Name = "Okay!",
         Callback = function()
         print("The user tapped Okay!")
      end
   },
},
})

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Настройки полета
local FLY_ENABLED = false
local FLY_SPEED = 50
local FLY_KEYBOARD_CONTROLS = {
    Forward = Enum.KeyCode.W,
    Backward = Enum.KeyCode.S,
    Left = Enum.KeyCode.A,
    Right = Enum.KeyCode.D,
    Up = Enum.KeyCode.Space,
    Down = Enum.KeyCode.LeftShift
}

-- Переменные для хранения объектов
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")
local bodyVelocity
local bodyGyro

-- Функция включения полета
local function EnableFly()
    if FLY_ENABLED then return end
    
    -- Запоминаем текущее состояние
    humanoid.PlatformStand = true
    
    -- Создаем BodyVelocity для движения
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVelocity.P = 1000
    bodyVelocity.Parent = rootPart
    
    -- Создаем BodyGyro для стабилизации
    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bodyGyro.P = 1000
    bodyGyro.D = 50
    bodyGyro.CFrame = rootPart.CFrame
    bodyGyro.Parent = rootPart
    
    FLY_ENABLED = true
end

-- Функция выключения полета
local function DisableFly()
    if not FLY_ENABLED then return end
    
    -- Восстанавливаем стандартное управление
    humanoid.PlatformStand = false
    
    -- Удаляем созданные объекты
    if bodyVelocity then
        bodyVelocity:Destroy()
        bodyVelocity = nil
    end
    
    if bodyGyro then
        bodyGyro:Destroy()
        bodyGyro = nil
    end
    
    FLY_ENABLED = false
end

-- Функция обработки управления
local function HandleFlightInput()
    if not FLY_ENABLED or not bodyVelocity or not bodyGyro then return end
    
    -- Получаем векторы направления камеры
    local camera = workspace.CurrentCamera
    local lookVector = camera.CFrame.LookVector
    local rightVector = camera.CFrame.RightVector
    local upVector = Vector3.new(0, 1, 0)
    
    -- Направление движения
    local direction = Vector3.new(0, 0, 0)
    
    -- Обработка клавиш
    if UserInputService:IsKeyDown(FLY_KEYBOARD_CONTROLS.Forward) then
        direction = direction + lookVector
    end
    if UserInputService:IsKeyDown(FLY_KEYBOARD_CONTROLS.Backward) then
        direction = direction - lookVector
    end
    if UserInputService:IsKeyDown(FLY_KEYBOARD_CONTROLS.Right) then
        direction = direction + rightVector
    end
    if UserInputService:IsKeyDown(FLY_KEYBOARD_CONTROLS.Left) then
        direction = direction - rightVector
    end
    if UserInputService:IsKeyDown(FLY_KEYBOARD_CONTROLS.Up) then
        direction = direction + upVector
    end
    if UserInputService:IsKeyDown(FLY_KEYBOARD_CONTROLS.Down) then
        direction = direction - upVector
    end
    
    -- Нормализация и применение скорости
    if direction.Magnitude > 0 then
        direction = direction.Unit * FLY_SPEED
    end
    
    -- Обновляем скорость и вращение
    bodyVelocity.Velocity = direction
    bodyGyro.CFrame = CFrame.new(rootPart.Position, rootPart.Position + lookVector)
end

-- Обработка изменения персонажа
LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoid = newCharacter:WaitForChild("Humanoid")
    rootPart = newCharacter:WaitForChild("HumanoidRootPart")
    
    -- Если полет был включен, пересоздаем объекты
    if FLY_ENABLED then
        DisableFly()
        EnableFly()
    end
end)

-- Подключение к Toggle кнопке
local ToggleFly = MainTab:CreateToggle({
    Name = "Enable Fly",
    Callback = function(value)
        if value then
            EnableFly()
        else
            DisableFly()
        end
    end
})

-- Постоянное обновление управления
RunService.Heartbeat:Connect(function()
    HandleFlightInput()
end)

local Slider = MainTab:CreateSlider({
    Name = "FlySpeed Slider",
    Range = {1, 350},
    Increment = 1,
    Suffix = "Speed",
    CurrentValue = 16,
    Flag = "FlySpeedSlider", -- Уникальный идентификатор
    Callback = function(Value)
        FLY_SPEED = Value -- Обновляем глобальную переменную скорости полета
    end,
 })

local Button = MainTab:CreateButton({
   Name = "Infinite Jump Toggle",
   Callback = function()
       --Toggles the infinite jump between on or off on every script run
_G.infinjump = not _G.infinjump

if _G.infinJumpStarted == nil then
  --Ensures this only runs once to save resources
  _G.infinJumpStarted = true
  
  --Notifies readiness
  game.StarterGui:SetCore("SendNotification", {Title="Supernal Hub"; Text="Infinite Jump Activated!"; Duration=5;})

  --The actual infinite jump
  local plr = game:GetService('Players').LocalPlayer
  local m = plr:GetMouse()
  m.KeyDown:connect(function(k)
    if _G.infinjump then
      if k:byte() == 32 then
      humanoid = game:GetService'Players'.LocalPlayer.Character:FindFirstChildOfClass('Humanoid')
      humanoid:ChangeState('Jumping')
      wait()
      humanoid:ChangeState('Seated')
      end
    end
  end)
end
   end,
})

local Slider = MainTab:CreateSlider({
   Name = "WalkSpeed Slider",
   Range = {1, 350},
   Increment = 1,
   Suffix = "Speed",
   CurrentValue = 16,
   Flag = "sliderws", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = (Value)
   end,
})

local Slider = MainTab:CreateSlider({
   Name = "JumpPower Slider",
   Range = {1, 350},
   Increment = 1,
   Suffix = "Power",
   CurrentValue = 16,
   Flag = "sliderjp", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
        game.Players.LocalPlayer.Character.Humanoid.JumpPower = (Value)
   end,
})

local Input = MainTab:CreateInput({
   Name = "Walkspeed",
   PlaceholderText = "1-500",
   RemoveTextAfterFocusLost = true,
   Callback = function(Text)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = (Text)
   end,
})

local OtherSection = MainTab:CreateSection("Other")

local TGButton = MainTab:CreateButton({
   Name = "t.me/SupernalRB",
   Callback = function(Value)
        print("Made by SUPERNAL (t.me/SupernalRB)")
end,
})

local NOSection = MainTab:CreateSection(" ")

local TPTab = Window:CreateTab("⚔️ ESP", nil) -- Title, Image

local ESPSection = TPTab:CreateSection("ESP")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Настройки ESP
local ESP_COLOR = Color3.fromRGB(255, 0, 0) -- Красный цвет по умолчанию
local ESP_THICKNESS = 1 -- Толщина линий
local ESP_TRANSPARENCY = 0.7 -- Прозрачность
local ESP_ENABLED = false -- Выключен по умолчанию

-- Хранилище для ESP элементов
local ESPItems = {}

-- Функция обновления цвета всех ESP элементов
local function UpdateESPColors()
    for character, espItems in pairs(ESPItems) do
        if character and character.Parent then
            -- Обновляем цвет рамки
            espItems[1].Color3 = ESP_COLOR
            
            -- Обновляем цвет текста
            if espItems[2] then
                espItems[2].TextLabel.TextColor3 = ESP_COLOR
            end
        end
    end
end

-- Функция создания ESP рамки
local function CreateESP(character)
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    -- Удаляем старый ESP если есть
    if ESPItems[character] then
        for _, item in pairs(ESPItems[character]) do
            if item then item:Destroy() end
        end
    end

    local Box = Instance.new("BoxHandleAdornment")
    Box.Name = "ESP_" .. character.Name
    Box.Adornee = character:WaitForChild("HumanoidRootPart")
    Box.AlwaysOnTop = true
    Box.ZIndex = 10
    Box.Size = character:GetExtentsSize() * 1.1
    Box.Color3 = ESP_COLOR
    Box.Transparency = ESP_TRANSPARENCY
    Box.Parent = character
    
    -- Добавляем текст с именем игрока
    local Billboard = Instance.new("BillboardGui")
    Billboard.Name = "ESP_Name_" .. character.Name
    Billboard.Adornee = character:WaitForChild("Head") or character:WaitForChild("HumanoidRootPart")
    Billboard.AlwaysOnTop = true
    Billboard.Size = UDim2.new(0, 100, 0, 40)
    Billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    
    local TextLabel = Instance.new("TextLabel")
    TextLabel.Text = character.Name
    TextLabel.TextColor3 = ESP_COLOR
    TextLabel.TextSize = 14
    TextLabel.Font = Enum.Font.SourceSansBold
    TextLabel.BackgroundTransparency = 1
    TextLabel.Size = UDim2.new(1, 0, 1, 0)
    TextLabel.Parent = Billboard
    
    Billboard.Parent = character
    
    ESPItems[character] = {Box, Billboard}
end

-- Функция удаления ESP
local function RemoveESP(character)
    if ESPItems[character] then
        for _, item in pairs(ESPItems[character]) do
            if item then item:Destroy() end
        end
        ESPItems[character] = nil
    end
end

-- Функция обновления ESP для всех игроков
local function UpdateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            if ESP_ENABLED then
                CreateESP(player.Character)
            else
                RemoveESP(player.Character)
            end
        end
    end
end

-- Обработчик добавления игрока
local function PlayerAdded(player)
    player.CharacterAdded:Connect(function(character)
        if ESP_ENABLED and player ~= LocalPlayer then
            CreateESP(character)
        end
    end)
    
    player.CharacterRemoving:Connect(function(character)
        RemoveESP(character)
    end)
end

-- Инициализация для существующих игроков
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        PlayerAdded(player)
        if player.Character and ESP_ENABLED then
            CreateESP(player.Character)
        end
    end
end

-- Обработка новых игроков
Players.PlayerAdded:Connect(PlayerAdded)

-- Обработка выхода игроков
Players.PlayerRemoving:Connect(function(player)
    if player.Character then
        RemoveESP(player.Character)
    end
end)

-- Подключение к вашему ToggleButton
local ToggleEsp = TPTab:CreateToggle({
    Name = "Enable ESP",
    Callback = function(value)
        ESP_ENABLED = value
        if ESP_ENABLED then
            UpdateESP()
        else
            for character, _ in pairs(ESPItems) do
                RemoveESP(character)
            end
        end
    end
})

-- Кнопка для установки красного цвета (по умолчанию)
local Button2 = TPTab:CreateButton({
    Name = "Default ESP Color",
    Callback = function()
        ESP_COLOR = Color3.fromRGB(255, 0, 0) -- Красный
        UpdateESPColors()
    end,
})

-- Кнопка для установки зеленого цвета
local Button3 = TPTab:CreateButton({
    Name = "Green ESP Color",
    Callback = function()
        ESP_COLOR = Color3.fromRGB(0, 255, 0) -- Зеленый
        UpdateESPColors()
    end,
})

-- Постоянное обновление ESP
RunService.Heartbeat:Connect(function()
    if ESP_ENABLED then
        for character, espItems in pairs(ESPItems) do
            if character and character:FindFirstChild("HumanoidRootPart") then
                -- Обновляем размер рамки
                espItems[1].Size = character:GetExtentsSize() * 1.1
                
                -- Обновляем позицию BillboardGui
                if character:FindFirstChild("Head") then
                    espItems[2].Adornee = character.Head
                else
                    espItems[2].Adornee = character.HumanoidRootPart
                end
            end
        end
    end
end)

local MiscTab = Window:CreateTab("🎲 Misc", nil) -- Title, Image

local ScriptSection = MiscTab:CreateSection("Popular Scripts")

local Button4 = MiscTab:CreateButton({
    Name = "Infinite Yield",
    Callback = function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
    end,
})

local NO2Section = MiscTab:CreateSection(" ")
