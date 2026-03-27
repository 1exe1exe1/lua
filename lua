-- ============================================================
--  SIGMA COMBINED PANEL  |  sigma + DevX2 + ¥harrz merged
--  UI: sigma.txt sidebar/theme + ¥harrz bubble toggle
--  Logic: best version of each feature, deduplicated
-- ============================================================

-- ── SERVICES ─────────────────────────────────────────────────
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService      = game:GetService("TweenService")
local TeleportService   = game:GetService("TeleportService")
local TextChatService   = game:GetService("TextChatService")
local Lighting          = game:GetService("Lighting")
local Workspace         = game:GetService("Workspace")
local StarterGui        = game:GetService("StarterGui")
local HttpService       = game:GetService("HttpService")

local lp               = Players.LocalPlayer
math.randomseed(os.clock() * 1000)

-- ── CONSTANTS ────────────────────────────────────────────────
local HANDSHAKE   = "both \u{1F91D}"
local ALL_SIDES_E = { Enum.NormalId.Front, Enum.NormalId.Back, Enum.NormalId.Top, Enum.NormalId.Bottom, Enum.NormalId.Right, Enum.NormalId.Left }
local ALL_SIDES_S = { "Front", "Back", "Top", "Bottom", "Left", "Right" }

-- TCO place IDs for ChatSpy
local TCO_PLACE_IDS = { 11137575513, 12943245078, 12943247001, 108097274488844 }
local function isTCOPlace()
    for _, id in ipairs(TCO_PLACE_IDS) do
        if game.PlaceId == id then return true end
    end
    return false
end

-- ── SHARED STATE ─────────────────────────────────────────────
-- Movement
local wsEnabled, wsValue, wsInfinite       = false, 16, false
local jpEnabled, jpValue, jpInfinite       = false, 50, false
local flyEnabled, flySpeed                 = false, 50
local infJumpEnabled                       = false
local shiftlockEnabled                     = false
local gravityEnabled, gravityValue         = false, 196.2
local boostFPSEnabled                      = false
-- Saved FPS data
local savedFPSData                         = {}

-- Anti (sigma originals)
local antiFlingEnabled    = false
local antiAfkEnabled      = false
local antiRagdollEnabled  = false
local antiVoidEnabled     = false
local antiKBEnabled       = false
local antiKickEnabled     = false
-- Anti (DevX2 / ¥harrz)
local antiGlitch          = false
local antiFreeze          = false
local antiJail            = false
local antiFog             = false
local antiBlind           = false
local antiMyopic          = false
local autoFixCam          = false
local lastSafePosition    = nil
local origFogDensity      = nil
do
    local atm = Lighting:FindFirstChildOfClass("Atmosphere")
    origFogDensity = atm and atm.Density or 0.3
end

-- Visual / ESP
local espEnabled          = true
local espNameEnabled      = false
local espDistEnabled      = false
local espOutlineEnabled   = false
local espMaxDist          = 1000
local espUseDisplay       = false
local espGuis             = {}

-- Anim / Misc
local animSpeedEnabled    = false
local animSpeedValue      = 1
local fakeLagEnabled      = false
local fakeLagValue        = 1
local spinEnabled         = false
local spinSpeed           = 1
local _cachedShovelEv     = nil
local _trailLastT         = nil

-- Character
local noclipEnabled       = false
local freezeAnimEnabled   = false
local godModeEnabled      = false
local godConnections      = {}

-- OP / Build (DevX2 origin)
local currentBlockColor    = Color3.fromRGB(163, 162, 165)
local currentSprayColor    = Color3.fromRGB(255, 255, 255)
local currentBrickText     = "Dev"
local currentOPMaterial    = "plastic"
local sideData             = {
    { side = Enum.NormalId.Top,    label = "Upside",    text = "Text", color = Color3.fromRGB(255,255,255) },
    { side = Enum.NormalId.Left,   label = "Leftside",  text = "Text", color = Color3.fromRGB(255,255,255) },
    { side = Enum.NormalId.Front,  label = "Frontside", text = "Text", color = Color3.fromRGB(255,255,255) },
    { side = Enum.NormalId.Right,  label = "Rightside", text = "Text", color = Color3.fromRGB(255,255,255) },
    { side = Enum.NormalId.Back,   label = "Backside",  text = "Text", color = Color3.fromRGB(255,255,255) },
    { side = Enum.NormalId.Bottom, label = "Downside",  text = "Text", color = Color3.fromRGB(255,255,255) },
}

-- Home auras (DevX2)
local rainbow              = false
local shovel               = false
local deleteAura           = false
local killAura             = false
local detailedPath         = false
local currentMaterial      = "smooth"
local currentBlockPathType = "detailed"
local GlobalRange          = 500
local rainbowH             = 0
local RainbowSpeed         = 0.005

-- Auras (DevX2)
local buildAura            = false
local signAura             = false
local paintAura            = false
local deleteAuraAdv        = false
local DeleteAuraRange      = 20
local PaintAuraRange       = 20
local auraH                = 0
local auraRainbowSpeed     = 0.005
local buildAuraSpeed       = 0.05
local signAuraSpeed        = 0.05
local paintAuraSpeed       = 0.05
local deleteAuraSpeed      = 0.05
local _buildAuraT          = 0
local _signAuraT           = 0
local _paintAuraT          = 0
local _deleteAuraT         = 0
local delCubesEnabled      = false
local voidAuraEnabled      = false

-- Autobuild
local mult                 = 4
local built                = false
local buildStopped         = false
local skipblock            = false
local tpToBlock            = true
local saveName             = ""

-- Target
local selectedTarget       = nil
local targetDelcubes       = false
local clickTPEnabled       = false

-- TCO
local spychat              = true
local arkSpyOn             = false
local donateSpyOn          = false
local mutedSpyOn           = false
local botReplyOn           = false
local botTrigger           = ""
local botReply             = ""
local botCaseSensitive     = false
local autoDropOnDeath      = false

-- Protection / Grief
local griefMonitorEnabled  = false
local griefDetectEnabled   = false
local griefFlingEnabled    = false
local whitelist            = {}
local enlightenLogEnabled  = false

-- Troll
local touchFlingEnabled    = false

-- Noclip Bypass (TCO)
local nnoclipEnabled       = false

-- GUI
local guiVisible           = false
local dragEnabled          = false
local activeTabName        = "Main"

-- Temporal features state
local rainbowSkyEnabled  = false
local rainbowSkyH        = 0
local sprayPaintEnabled  = false
local sprayPaintText     = "cool sandbox game!"
local deleteClickAura    = false
local _dcaBox            = nil
local _dcaPos            = nil
local showEnlightens     = false
local showInvis          = false
local selectedBlockMode  = false
local selectedBlock      = nil
local _tempBbId          = ""
local _tempBbNames       = {
    SuperFlyGoldBoombox=true, BoomboxGearThree=true,
    DualGoldenSuperFlyBoombox=true, DubstepBoombox=true, BeatUpBoombox=true,
}
local _dcaRayParams = RaycastParams.new()
_dcaRayParams.FilterType = Enum.RaycastFilterType.Exclude
local _sprayOverlapParams = nil
local _overlapSupported   = false
pcall(function()
    _sprayOverlapParams = OverlapParams.new()
    _sprayOverlapParams.FilterType = Enum.RaycastFilterType.Exclude
    _overlapSupported = true
end)


-- ── SHARED BRIDGE ────────────────────────────────────────────
shared.sendChat         = shared.sendChat or nil
shared.GriefLog         = shared.GriefLog or ""
shared.PaintLog         = shared.PaintLog or ""
shared.BuildLog         = shared.BuildLog or ""
shared.BKitLog          = shared.BKitLog  or ""
shared.GodModePaused    = false

-- ── UTILITY FUNCTIONS ────────────────────────────────────────
local function notify(title, text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title    = title or "Panel",
            Text     = text  or "",
            Duration = 4,
        })
    end)
end

local function sendChat(message)
    pcall(function()
        if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
            TextChatService.TextChannels.RBXGeneral:SendAsync(message)
        else
            ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(message, "All")
        end
    end)
end
shared.sendChat = sendChat

-- Find a tool regardless of whether it is in Backpack or equipped in Character
-- Find a tool in Character (equipped) or Backpack
local function findTool(toolName)
    return (lp.Character and lp.Character:FindFirstChild(toolName))
        or lp.Backpack:FindFirstChild(toolName)
end

-- Equip a tool and wait up to 0.15s for it to land in Character, then return it
local function forceEquip(toolName)
    local char = lp.Character
    if not char then return nil end
    local already = char:FindFirstChild(toolName)
    if already then return already end
    local tool = lp.Backpack:FindFirstChild(toolName)
    if not tool then return nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return nil end
    hum:EquipTool(tool)
    local deadline = tick() + 0.15
    while tick() < deadline do
        local t = char:FindFirstChild(toolName)
        if t then return t end
        task.wait()
    end
    return char:FindFirstChild(toolName)
end

-- Get the RemoteEvent from a tool, force-equipping it first.
-- Retries up to 0.2s for the Event to appear after equip (handles replication lag).
local function getToolRemote(toolName)
    local tool = forceEquip(toolName)
    if not tool then return nil end
    local deadline = tick() + 0.2
    repeat
        local ev = tool:FindFirstChild("Event", true)
                or tool:FindFirstChildWhichIsA("RemoteEvent", true)
        if ev then return ev end
        task.wait()
    until tick() > deadline
    return tool:FindFirstChild("Event", true)
        or tool:FindFirstChildWhichIsA("RemoteEvent", true)
end

-- Get a tool's Event child without equipping (fast path for already-equipped tools)
local function getToolEvent(toolName)
    local tool = findTool(toolName)
    return tool and tool:FindFirstChild("Event", true)
end

-- Equip a tool and immediately return its Event child (used in runtime loops)
local function equipAndGetEvent(toolName)
    local tool = forceEquip(toolName)
    return tool and tool:FindFirstChild("Event", true)
end

local function getPlayerNames()
    local names = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp then table.insert(names, p.Name) end
    end
    if #names == 0 then table.insert(names, "No Players") end
    return names
end

local function snapToGrid(pos)
    return Vector3.new(
        math.floor(pos.X / mult + 0.5) * mult,
        math.floor(pos.Y / mult + 0.5) * mult,
        math.floor(pos.Z / mult + 0.5) * mult
    )
end

local function getPositionAround(part, minR, maxR)
    local d = math.random() * (maxR - minR) + minR
    local t = math.random() * math.pi * 2
    local phi = math.acos(2 * math.random() - 1)
    return part.Position + Vector3.new(
        d * math.sin(phi) * math.cos(t),
        d * math.cos(phi),
        d * math.sin(phi) * math.sin(t)
    )
end

local function getNearestPart(maxRange)
    local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local folder = Workspace:FindFirstChild("Bricks") or Workspace:FindFirstChild("PlacedBlocks")
    if not folder then return end
    local candidates = {}
    for _, part in ipairs(folder:GetDescendants()) do
        if part:IsA("BasePart") and (hrp.Position - part.Position).Magnitude <= maxRange then
            table.insert(candidates, part)
        end
    end
    return #candidates > 0 and candidates[math.random(1, #candidates)] or nil
end

local function removeCollision(obj)
    if not obj then return end
    for _, part in ipairs(obj:GetDescendants()) do
        if part:IsA("BasePart") then part.CanCollide = false end
    end
end

local function fixPlayerState()
    pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, true) end)
    local cam = Workspace.CurrentCamera
    if lp.Character and lp.Character:FindFirstChild("Humanoid") then
        cam.CameraType    = Enum.CameraType.Custom
        cam.CameraSubject = lp.Character.Humanoid
        cam.FieldOfView   = 70
    end
end

-- ─────────────────────────────────────────────────────────────
-- SCREEN GUI SETUP
-- ─────────────────────────────────────────────────────────────
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name              = "SigmaCombinedPanel"
ScreenGui.ResetOnSpawn      = false
ScreenGui.ZIndexBehavior    = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset    = true
ScreenGui.DisplayOrder      = 999999999
ScreenGui.Parent            = lp.PlayerGui

-- ─────────────────────────────────────────────────────────────
-- THEME CONSTANTS  (sigma dark palette)
-- ─────────────────────────────────────────────────────────────
local C_BG        = Color3.fromRGB(23,  23,  23)
local C_SIDEBAR   = Color3.fromRGB(0,   0,   0)
local C_CONTENT   = Color3.fromRGB(0,   0,   0)
local C_GROUP     = Color3.fromRGB(17,  17,  17)
local C_BORDER    = Color3.fromRGB(58,  58,  58)
local C_ACCENT    = Color3.fromRGB(0,  124, 255)
local C_WHITE     = Color3.fromRGB(255,255,255)
local C_BTN       = Color3.fromRGB(25,  25,  25)
local C_TAB_ON    = Color3.fromRGB(0,  124, 255)
local C_TAB_OFF   = Color3.fromRGB(0,   0,   0)
local FONT_MAIN   = Font.new("rbxasset://fonts/families/Inconsolata.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
local FONT_SS     = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)

-- ─────────────────────────────────────────────────────────────
-- BUBBLE TOGGLE  (¥harrz style, sigma accent color)
-- ─────────────────────────────────────────────────────────────
local bubble = Instance.new("TextButton")
bubble.Name             = "PanelBubble"
bubble.Size             = UDim2.new(0, 52, 0, 52)
bubble.Position         = UDim2.new(0.5, -26, 0, 14)
bubble.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
bubble.Text             = ""
bubble.ZIndex           = 15
bubble.Parent           = ScreenGui
Instance.new("UICorner", bubble).CornerRadius = UDim.new(1, 0)

local bubbleStroke = Instance.new("UIStroke")
bubbleStroke.Color     = C_ACCENT
bubbleStroke.Thickness = 2.5
bubbleStroke.Parent    = bubble

local bubblePulse = TweenService:Create(bubbleStroke,
    TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
    { Thickness = 4 }
)
bubblePulse:Play()

local bubbleLbl = Instance.new("TextLabel")
bubbleLbl.Size               = UDim2.new(1,0,1,0)
bubbleLbl.BackgroundTransparency = 1
bubbleLbl.Text               = "Σ"
bubbleLbl.TextColor3         = C_ACCENT
bubbleLbl.FontFace            = FONT_MAIN
bubbleLbl.TextSize           = 22
bubbleLbl.ZIndex             = 16
bubbleLbl.Parent             = bubble

-- ─────────────────────────────────────────────────────────────
-- MAIN FRAME  (sigma sizing + dark theme)
-- ─────────────────────────────────────────────────────────────
local MainFrame = Instance.new("Frame")
MainFrame.Name            = "MainFrame"
MainFrame.Size            = UDim2.new(0, 500, 0, 340)
MainFrame.Position        = UDim2.new(0.5, -250, 0.5, -170)
MainFrame.BackgroundColor3= C_BG
MainFrame.BorderColor3    = C_BORDER
MainFrame.Active          = true
MainFrame.Draggable       = true
MainFrame.Visible         = false
MainFrame.ZIndex          = 5
MainFrame.Parent          = ScreenGui

-- TOP BAR
local TopBar = Instance.new("Frame")
TopBar.Name            = "TopBar"
TopBar.Size            = UDim2.new(1, 0, 0, 26)
TopBar.BackgroundColor3= Color3.fromRGB(10, 10, 10)
TopBar.BorderColor3    = C_BORDER
TopBar.ZIndex          = 6
TopBar.Parent          = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size               = UDim2.new(1, -80, 1, 0)
TitleLabel.Position           = UDim2.new(0, 8, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text               = "Sigma Panel v3.0"
TitleLabel.TextColor3         = C_WHITE
TitleLabel.FontFace           = FONT_MAIN
TitleLabel.TextSize           = 13
TitleLabel.TextXAlignment     = Enum.TextXAlignment.Left
TitleLabel.ZIndex             = 7
TitleLabel.Parent             = TopBar

-- FPS label in title (like sigma)
RunService.RenderStepped:Connect(function(dt)
    if guiVisible then
        TitleLabel.Text = "Sigma Panel  |  " .. math.floor(1 / dt) .. " fps  |  " .. #Players:GetPlayers() .. " players"
    end
end)

-- Minimize button
local MinBtn = Instance.new("TextButton")
MinBtn.Size             = UDim2.new(0, 22, 0, 20)
MinBtn.Position         = UDim2.new(1, -48, 0, 3)
MinBtn.BackgroundColor3 = C_BTN
MinBtn.BorderColor3     = C_BORDER
MinBtn.Text             = "-"
MinBtn.TextColor3       = C_WHITE
MinBtn.FontFace         = FONT_MAIN
MinBtn.TextSize         = 14
MinBtn.ZIndex           = 7
MinBtn.Parent           = TopBar

-- Close button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size             = UDim2.new(0, 22, 0, 20)
CloseBtn.Position         = UDim2.new(1, -24, 0, 3)
CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
CloseBtn.BorderColor3     = C_BORDER
CloseBtn.Text             = "×"
CloseBtn.TextColor3       = C_WHITE
CloseBtn.FontFace         = FONT_MAIN
CloseBtn.TextSize         = 14
CloseBtn.ZIndex           = 7
CloseBtn.Parent           = TopBar

-- ─────────────────────────────────────────────────────────────
-- SIDEBAR  (sigma style: vertical tab buttons)
-- ─────────────────────────────────────────────────────────────
local SideBar = Instance.new("ScrollingFrame")
SideBar.Name                = "SideBar"
SideBar.Size                = UDim2.new(0, 70, 1, -26)
SideBar.Position            = UDim2.new(0, 0, 0, 26)
SideBar.BackgroundColor3    = C_SIDEBAR
SideBar.BorderColor3        = C_BORDER
SideBar.ScrollBarThickness  = 0
SideBar.ScrollingDirection  = Enum.ScrollingDirection.Y
SideBar.AutomaticCanvasSize = Enum.AutomaticSize.Y
SideBar.CanvasSize          = UDim2.new(0,0,0,0)
SideBar.ZIndex              = 6
SideBar.Parent              = MainFrame

local SideLayout = Instance.new("UIListLayout")
SideLayout.SortOrder = Enum.SortOrder.LayoutOrder
SideLayout.Parent    = SideBar

-- ─────────────────────────────────────────────────────────────
-- CONTENT AREA
-- ─────────────────────────────────────────────────────────────
local ContentArea = Instance.new("Frame")
ContentArea.Name            = "ContentArea"
ContentArea.Size            = UDim2.new(1, -70, 1, -26)
ContentArea.Position        = UDim2.new(0, 70, 0, 26)
ContentArea.BackgroundColor3= C_CONTENT
ContentArea.BorderColor3    = C_BORDER
ContentArea.ZIndex          = 6
ContentArea.Parent          = MainFrame

-- ─────────────────────────────────────────────────────────────
-- UI WIDGET HELPERS  (sigma tick-box style)
-- ─────────────────────────────────────────────────────────────
local function makeScrollPage()
    local sf = Instance.new("ScrollingFrame")
    sf.Size                = UDim2.new(1, -6, 1, -6)
    sf.Position            = UDim2.new(0, 3, 0, 3)
    sf.BackgroundTransparency = 1
    sf.BorderSizePixel     = 0
    sf.ScrollBarThickness  = 3
    sf.ScrollBarImageColor3= C_ACCENT
    sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sf.CanvasSize          = UDim2.new(0,0,0,0)
    sf.Visible             = false
    sf.ZIndex              = 7
    sf.Parent              = ContentArea
    local layout = Instance.new("UIListLayout")
    layout.Padding     = UDim.new(0, 5)
    layout.SortOrder   = Enum.SortOrder.LayoutOrder
    layout.Parent      = sf
    local pad = Instance.new("UIPadding")
    pad.PaddingTop   = UDim.new(0,4)
    pad.PaddingLeft  = UDim.new(0,4)
    pad.PaddingRight = UDim.new(0,4)
    pad.Parent       = sf
    return sf
end

-- Group box (sigma style: dark box with colored top stripe + title)
local function makeGroup(parent, title)
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = C_GROUP
    frame.BorderColor3     = C_BORDER
    frame.BorderMode       = Enum.BorderMode.Middle
    frame.AutomaticSize    = Enum.AutomaticSize.Y
    frame.Size             = UDim2.new(1, 0, 0, 0)
    frame.ZIndex           = 7
    frame.Parent           = parent

    local accent = Instance.new("Frame")
    accent.BackgroundColor3 = C_ACCENT
    accent.BorderColor3     = C_ACCENT
    accent.Size             = UDim2.new(1, 0, 0, 2)
    accent.ZIndex           = 8
    accent.Parent           = frame

    local lbl = Instance.new("TextLabel")
    lbl.Size               = UDim2.new(1, 0, 0, 16)
    lbl.Position           = UDim2.new(0, 0, 0, 2)
    lbl.BackgroundColor3   = C_GROUP
    lbl.BackgroundTransparency = 0.05
    lbl.BorderSizePixel    = 0
    lbl.Text               = title
    lbl.TextColor3         = C_WHITE
    lbl.FontFace           = FONT_MAIN
    lbl.TextSize           = 12
    lbl.TextScaled         = false
    lbl.ZIndex             = 8
    lbl.Parent             = frame

    -- Minimize button on group
    local minBtn = Instance.new("TextButton")
    minBtn.Size             = UDim2.new(0, 18, 0, 14)
    minBtn.Position         = UDim2.new(1, -20, 0, 4)
    minBtn.BackgroundTransparency = 1
    minBtn.BorderSizePixel  = 0
    minBtn.Text             = "-"
    minBtn.TextColor3       = C_WHITE
    minBtn.FontFace         = FONT_MAIN
    minBtn.TextSize         = 14
    minBtn.ZIndex           = 9
    minBtn.Parent           = frame

    local inner = Instance.new("Frame")
    inner.Name             = "Inner"
    inner.BackgroundTransparency = 1
    inner.AutomaticSize    = Enum.AutomaticSize.Y
    inner.Size             = UDim2.new(1, 0, 0, 0)
    inner.Position         = UDim2.new(0, 0, 0, 18)
    inner.ZIndex           = 8
    inner.Parent           = frame

    local innerLayout = Instance.new("UIListLayout")
    innerLayout.SortOrder = Enum.SortOrder.LayoutOrder
    innerLayout.Parent    = inner

    -- Minimize logic
    local minimized = false
    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        inner.Visible = not minimized
        minBtn.Text   = minimized and "+" or "-"
    end)

    return inner
end

-- Row: tickbox + label + optional value input
local function makeToggleRow(parent, labelText, callback, defaultOn)
    local state = defaultOn or false
    local row   = Instance.new("Frame")
    row.Size               = UDim2.new(1, 0, 0, 20)
    row.BackgroundTransparency = 1
    row.ZIndex             = 8
    row.Parent             = parent

    local tick = Instance.new("TextButton")
    tick.Size             = UDim2.new(0, 16, 0, 16)
    tick.Position         = UDim2.new(0, 4, 0.5, -8)
    tick.BackgroundColor3 = state and C_ACCENT or Color3.new(0,0,0)
    tick.BorderColor3     = C_BORDER
    tick.Text             = ""
    tick.FontFace         = FONT_SS
    tick.TextSize         = 12
    tick.ZIndex           = 9
    tick.Parent           = row

    local lbl = Instance.new("TextLabel")
    lbl.Size              = UDim2.new(1, -28, 1, 0)
    lbl.Position          = UDim2.new(0, 24, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text              = labelText
    lbl.TextColor3        = C_WHITE
    lbl.FontFace          = FONT_MAIN
    lbl.TextSize          = 13
    lbl.TextXAlignment    = Enum.TextXAlignment.Left
    lbl.ZIndex            = 9
    lbl.Parent            = row

    tick.MouseButton1Click:Connect(function()
        state = not state
        tick.BackgroundColor3 = state and C_ACCENT or Color3.new(0,0,0)
        callback(state)
    end)

    return row, tick, function(v) state = v; tick.BackgroundColor3 = v and C_ACCENT or Color3.new(0,0,0) end
end

-- Row: tickbox + label + text input box
local function makeToggleInputRow(parent, labelText, placeholder, callback)
    local state = false
    local row   = Instance.new("Frame")
    row.Size               = UDim2.new(1, 0, 0, 20)
    row.BackgroundTransparency = 1
    row.ZIndex             = 8
    row.Parent             = parent

    local tick = Instance.new("TextButton")
    tick.Size             = UDim2.new(0, 16, 0, 16)
    tick.Position         = UDim2.new(0, 4, 0.5, -8)
    tick.BackgroundColor3 = Color3.new(0,0,0)
    tick.BorderColor3     = C_BORDER
    tick.Text             = ""
    tick.ZIndex           = 9
    tick.Parent           = row

    local lbl = Instance.new("TextLabel")
    lbl.Size              = UDim2.new(0, 100, 1, 0)
    lbl.Position          = UDim2.new(0, 24, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text              = labelText
    lbl.TextColor3        = C_WHITE
    lbl.FontFace          = FONT_MAIN
    lbl.TextSize          = 13
    lbl.TextXAlignment    = Enum.TextXAlignment.Left
    lbl.ZIndex            = 9
    lbl.Parent            = row

    local box = Instance.new("TextBox")
    box.Size              = UDim2.new(0, 52, 0, 16)
    box.Position          = UDim2.new(1, -56, 0.5, -8)
    box.BackgroundColor3  = Color3.new(0,0,0)
    box.BorderColor3      = C_BORDER
    box.Text              = ""
    box.PlaceholderText   = placeholder or ""
    box.TextColor3        = C_WHITE
    box.FontFace          = FONT_MAIN
    box.TextSize          = 12
    box.ZIndex            = 9
    box.Parent            = row

    tick.MouseButton1Click:Connect(function()
        state = not state
        tick.BackgroundColor3 = state and C_ACCENT or Color3.new(0,0,0)
        callback(state, box.Text)
    end)

    box.FocusLost:Connect(function()
        if state then callback(state, box.Text) end
    end)

    return row, tick, box
end

-- Row: full-width button
local function makeButtonRow(parent, labelText, callback)
    local row = Instance.new("Frame")
    row.Size               = UDim2.new(1, 0, 0, 20)
    row.BackgroundTransparency = 1
    row.ZIndex             = 8
    row.Parent             = parent

    local btn = Instance.new("TextButton")
    btn.Size             = UDim2.new(1, -8, 0, 16)
    btn.Position         = UDim2.new(0, 4, 0.5, -8)
    btn.BackgroundColor3 = C_BTN
    btn.BorderColor3     = C_BORDER
    btn.Text             = labelText
    btn.TextColor3       = C_WHITE
    btn.FontFace         = FONT_MAIN
    btn.TextSize         = 12
    btn.ZIndex           = 9
    btn.Parent           = row

    btn.MouseButton1Click:Connect(function()
        btn.Text = "..."
        task.spawn(function()
            callback(btn)
            task.wait(2)
            btn.Text = labelText
        end)
    end)

    return row, btn
end

-- Row: label + dropdown
local function makeDropdownRow(parent, labelText, options, default, callback)
    local selected = default or options[1]
    local open     = false

    local row = Instance.new("Frame")
    row.Size               = UDim2.new(1, 0, 0, 20)
    row.BackgroundTransparency = 1
    row.ZIndex             = 8
    row.Parent             = parent

    local btn = Instance.new("TextButton")
    btn.Size             = UDim2.new(1, -8, 0, 16)
    btn.Position         = UDim2.new(0, 4, 0.5, -8)
    btn.BackgroundColor3 = C_BTN
    btn.BorderColor3     = C_BORDER
    btn.Text             = labelText .. ": " .. selected .. " ▾"
    btn.TextColor3       = C_WHITE
    btn.FontFace         = FONT_MAIN
    btn.TextSize         = 11
    btn.ZIndex           = 9
    btn.Parent           = row

    -- Drop list in ScreenGui to avoid clipping
    -- Active=true on both frame and scroll so clicks are absorbed (not passed to game)
    local dropFrame = Instance.new("Frame")
    dropFrame.Size            = UDim2.new(0, 200, 0, math.min(#options,8)*20+4)
    dropFrame.BackgroundColor3= Color3.fromRGB(20,20,20)
    dropFrame.BorderColor3    = C_BORDER
    dropFrame.ZIndex          = 50
    dropFrame.Active          = true   -- absorb all input; prevents click-through to game
    dropFrame.Visible         = false
    dropFrame.Parent          = ScreenGui

    local dropScroll = Instance.new("ScrollingFrame")
    dropScroll.Size                = UDim2.new(1,0,1,0)
    dropScroll.BackgroundTransparency = 1
    dropScroll.BorderSizePixel     = 0
    dropScroll.ScrollBarThickness  = 3
    dropScroll.ScrollBarImageColor3= C_ACCENT
    -- AutomaticCanvasSize lets UIListLayout drive the canvas so all items are reachable
    dropScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    dropScroll.CanvasSize          = UDim2.new(0,0,0,0)
    dropScroll.ZIndex              = 51
    dropScroll.Active              = true
    dropScroll.ClipsDescendants    = true
    dropScroll.Parent              = dropFrame

    local dropLayout = Instance.new("UIListLayout")
    dropLayout.Padding    = UDim.new(0,2)
    dropLayout.SortOrder  = Enum.SortOrder.LayoutOrder
    dropLayout.Parent     = dropScroll
    -- Top + bottom padding so the last item is never flush against the scroll edge
    local dp = Instance.new("UIPadding")
    dp.PaddingTop    = UDim.new(0,2)
    dp.PaddingLeft   = UDim.new(0,2)
    dp.PaddingRight  = UDim.new(0,2)
    dp.PaddingBottom = UDim.new(0,40)  -- 40px extra at bottom = ~2 invisible rows of breathing room
    dp.Parent        = dropScroll

    local function makeOptionBtn(opt)
        local ob = Instance.new("TextButton")
        ob.Size             = UDim2.new(1,0,0,20)
        ob.BackgroundColor3 = Color3.fromRGB(28,28,28)
        ob.BorderColor3     = C_BORDER
        ob.Text             = opt
        ob.TextColor3       = C_WHITE
        ob.FontFace         = FONT_MAIN
        ob.TextSize         = 11
        ob.ZIndex           = 52
        ob.Active           = true
        ob.Parent           = dropScroll
        ob.MouseButton1Click:Connect(function()
            selected = opt
            btn.Text = labelText .. ": " .. selected .. " ▾"
            open = false; dropFrame.Visible = false
            callback(opt)
        end)
        return ob
    end

    for _, opt in ipairs(options) do
        makeOptionBtn(opt)
    end

    btn.MouseButton1Click:Connect(function()
        open = not open
        if open then
            local abs  = btn.AbsolutePosition
            local absS = btn.AbsoluteSize
            local h    = math.min(#options,8)*20+4
            local scH  = ScreenGui.AbsoluteSize.Y
            local posY = abs.Y + absS.Y + 2
            if posY + h > scH then posY = abs.Y - h - 2 end
            dropFrame.Position = UDim2.new(0, abs.X, 0, posY)
            dropFrame.Size     = UDim2.new(0, absS.X, 0, h)
            dropFrame.Visible  = true
        else
            dropFrame.Visible = false
        end
    end)

    UserInputService.InputBegan:Connect(function(inp)
        if not open then return end
        if inp.UserInputType ~= Enum.UserInputType.MouseButton1 and inp.UserInputType ~= Enum.UserInputType.Touch then return end
        task.wait()
        if not open then return end
        local mp = UserInputService:GetMouseLocation()
        local dfp,dfs = dropFrame.AbsolutePosition, dropFrame.AbsoluteSize
        local bp,bs   = btn.AbsolutePosition, btn.AbsoluteSize
        local inDrop = mp.X>=dfp.X and mp.X<=dfp.X+dfs.X and mp.Y>=dfp.Y and mp.Y<=dfp.Y+dfs.Y
        local inBtn  = mp.X>=bp.X  and mp.X<=bp.X+bs.X   and mp.Y>=bp.Y  and mp.Y<=bp.Y+bs.Y
        if not inDrop and not inBtn then dropFrame.Visible=false; open=false end
    end)

    local function setValues(newOpts, newSel)
        options = newOpts
        for _, c in ipairs(dropScroll:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
        for _, opt in ipairs(newOpts) do
            makeOptionBtn(opt)
        end
        if newSel then selected=newSel; btn.Text=labelText..": "..selected.." ▾" end
    end

    return row, setValues
end

-- Row: label + text input (fires on Enter or FocusLost)
local function makeInputRow(parent, labelText, placeholder, callback)
    local row = Instance.new("Frame")
    row.Size               = UDim2.new(1, 0, 0, 20)
    row.BackgroundTransparency = 1
    row.ZIndex             = 8
    row.Parent             = parent

    local lbl = Instance.new("TextLabel")
    lbl.Size              = UDim2.new(0, 110, 1, 0)
    lbl.Position          = UDim2.new(0, 4, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text              = labelText
    lbl.TextColor3        = C_WHITE
    lbl.FontFace          = FONT_MAIN
    lbl.TextSize          = 12
    lbl.TextXAlignment    = Enum.TextXAlignment.Left
    lbl.ZIndex            = 9
    lbl.Parent            = row

    local box = Instance.new("TextBox")
    box.Size             = UDim2.new(1, -120, 0, 16)
    box.Position         = UDim2.new(0, 116, 0.5, -8)
    box.BackgroundColor3 = Color3.new(0,0,0)
    box.BorderColor3     = C_BORDER
    box.Text             = ""
    box.PlaceholderText  = placeholder or ""
    box.TextColor3       = C_WHITE
    box.FontFace         = FONT_MAIN
    box.TextSize         = 12
    box.ZIndex           = 9
    box.Parent           = row

    box.FocusLost:Connect(function(entered)
        if entered or box.Text ~= "" then callback(box.Text) end
    end)

    return row, box
end

-- Section divider label
local function makeSection(parent, text)
    local lbl = Instance.new("TextLabel")
    lbl.Size               = UDim2.new(1, 0, 0, 16)
    lbl.BackgroundTransparency = 1
    lbl.Text               = "── " .. text .. " ──"
    lbl.TextColor3         = C_ACCENT
    lbl.FontFace           = FONT_MAIN
    lbl.TextSize           = 11
    lbl.ZIndex             = 8
    lbl.Parent             = parent
    return lbl
end

-- ─────────────────────────────────────────────────────────────
-- TAB SYSTEM
-- ─────────────────────────────────────────────────────────────
local tabButtons  = {}
local tabPages    = {}

local function setActiveTab(name)
    activeTabName = name
    for n, btn in pairs(tabButtons) do
        btn.BackgroundColor3 = (n == name) and C_TAB_ON or C_TAB_OFF
        btn.TextColor3       = C_WHITE
    end
    for n, page in pairs(tabPages) do
        page.Visible = (n == name)
    end
end

local function createTab(name, layoutOrder)
    local btn = Instance.new("TextButton")
    btn.Size             = UDim2.new(1, 0, 0, 28)
    btn.BackgroundColor3 = C_TAB_OFF
    btn.BorderColor3     = C_BORDER
    btn.Text             = name
    btn.TextColor3       = C_WHITE
    btn.FontFace         = FONT_MAIN
    btn.TextSize         = 11
    btn.TextWrapped      = true
    btn.LayoutOrder      = layoutOrder or 0
    btn.ZIndex           = 7
    btn.Parent           = SideBar

    local page = makeScrollPage()
    tabButtons[name] = btn
    tabPages[name]   = page

    btn.MouseButton1Click:Connect(function() setActiveTab(name) end)
    return page
end

-- ─────────────────────────────────────────────────────────────
-- TAB: MAIN
-- Movement + Character + Troll
-- ─────────────────────────────────────────────────────────────
local mainPage = createTab("Main", 1)

do
    local movGroup = makeGroup(mainPage, "Movement")

    -- Walk Speed
    makeToggleInputRow(movGroup, "Walk Speed", "(16)", function(on, val)
        wsEnabled = on
        local num = tonumber(val)
        if num then wsValue = num end
        wsInfinite = (val:lower() == "inf")
        local char = lp.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = on and (wsInfinite and math.huge or wsValue) or 16
            end
        end
    end)

    -- Jump Power
    makeToggleInputRow(movGroup, "Jump Power", "(50)", function(on, val)
        jpEnabled = on
        local num = tonumber(val)
        if num then jpValue = num end
        jpInfinite = (val:lower() == "inf")
        local char = lp.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.UseJumpPower = true
                hum.JumpPower = on and (jpInfinite and math.huge or jpValue) or 50
            end
        end
    end)

    -- Fly
    local flyNowe, flyTpwalking = false, false
    makeToggleInputRow(movGroup, "Fly (E=up Q=dn)", "(50)", function(on, val)
        flyEnabled = on
        local num = tonumber(val)
        if num then flySpeed = num end
        local chr = lp.Character
        if not chr then return end
        local hum = chr:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        if on then
            flyNowe    = true
            flyTpwalking = true
            for _, s in pairs(Enum.HumanoidStateType:GetEnumItems()) do
                pcall(function() hum:SetStateEnabled(s, false) end)
            end
            hum:ChangeState(Enum.HumanoidStateType.Swimming)
            hum.PlatformStand = true
            chr.Animate.Disabled = true
            task.wait()
            for _, t in pairs(hum:GetPlayingAnimationTracks()) do t:Stop(0) end
            local isR6 = hum.RigType == Enum.HumanoidRigType.R6
            local torso = isR6 and chr:FindFirstChild("Torso") or chr:FindFirstChild("UpperTorso")
            if not torso then return end
            local bg = Instance.new("BodyGyro"); bg.P=9e4; bg.MaxTorque=Vector3.new(9e9,9e9,9e9); bg.CFrame=torso.CFrame; bg.Parent=torso
            local bv = Instance.new("BodyVelocity"); bv.Velocity=Vector3.new(0,0.1,0); bv.MaxForce=Vector3.new(9e9,9e9,9e9); bv.Parent=torso
            task.spawn(function()
                while flyNowe do
                    RunService.RenderStepped:Wait()
                    local spd = flySpeed
                    local camCF = Workspace.CurrentCamera.CFrame
                    local f = UserInputService:IsKeyDown(Enum.KeyCode.W) and 1 or 0
                    local b = UserInputService:IsKeyDown(Enum.KeyCode.S) and -1 or 0
                    local l = UserInputService:IsKeyDown(Enum.KeyCode.A) and -1 or 0
                    local r = UserInputService:IsKeyDown(Enum.KeyCode.D) and 1 or 0
                    local flat = Vector3.new(camCF.LookVector.X,0,camCF.LookVector.Z).Unit
                    local right = Vector3.new(camCF.RightVector.X,0,camCF.RightVector.Z).Unit
                    bv.Velocity = (flat*(f+b) + right*(l+r)) * spd
                    bg.CFrame = camCF
                    if UserInputService:IsKeyDown(Enum.KeyCode.E) then torso.CFrame = torso.CFrame + Vector3.new(0,1,0)
                    elseif UserInputService:IsKeyDown(Enum.KeyCode.Q) then torso.CFrame = torso.CFrame + Vector3.new(0,-1,0) end
                end
                bg:Destroy(); bv:Destroy()
            end)
        else
            flyNowe = false; flyTpwalking = false
            for _, s in pairs(Enum.HumanoidStateType:GetEnumItems()) do pcall(function() hum:SetStateEnabled(s, true) end) end
            hum:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
            hum.PlatformStand = false
            chr.Animate.Disabled = false
        end
    end)

    -- Infinite Jump
    local infJumpConn = nil
    makeToggleRow(movGroup, "Infinite Jump", function(on)
        infJumpEnabled = on
        if on then
            infJumpConn = UserInputService.JumpRequest:Connect(function()
                local char = lp.Character
                if not char then return end
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
            end)
        else
            if infJumpConn then infJumpConn:Disconnect(); infJumpConn = nil end
        end
    end)

    -- Mobile Shiftlock
    local shiftLockGui, shiftImageBtn = nil, nil
    makeToggleRow(movGroup, "Mobile Shiftlock", function(on)
        shiftlockEnabled = on
        if on then
            local playerGui = lp:WaitForChild("PlayerGui")
            shiftLockGui = Instance.new("ScreenGui")
            shiftLockGui.Name = "ShiftLockGui"; shiftLockGui.ResetOnSpawn=false; shiftLockGui.DisplayOrder=999; shiftLockGui.Parent=playerGui
            shiftImageBtn = Instance.new("ImageButton")
            shiftImageBtn.BackgroundTransparency=1; shiftImageBtn.Image="rbxasset://textures/ui/mouseLock_off@2x.png"
            shiftImageBtn.Position=UDim2.new(0.92,0,0.55,0); shiftImageBtn.Size=UDim2.new(0.06,0,0.066,0)
            shiftImageBtn.SizeConstraint=Enum.SizeConstraint.RelativeXX; shiftImageBtn.Modal=true; shiftImageBtn.Parent=shiftLockGui
            local active, lastT = nil, 0
            local function enable()
                local hum,hrp,cam = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid"), lp.Character and lp.Character:FindFirstChild("HumanoidRootPart"), Workspace.CurrentCamera
                if not hum or not hrp then return end
                hum.AutoRotate=false
                hrp.CFrame=CFrame.new(hrp.Position,Vector3.new(cam.CFrame.LookVector.X*9e5,hrp.Position.Y,cam.CFrame.LookVector.Z*9e5))
                cam.CFrame=cam.CFrame*CFrame.new(1.7,0,0)
                shiftImageBtn.Image="rbxasset://textures/ui/mouseLock_on@2x.png"
            end
            local function disable()
                local hum,cam=lp.Character and lp.Character:FindFirstChildOfClass("Humanoid"),Workspace.CurrentCamera
                if hum then hum.AutoRotate=true end
                cam.CFrame=cam.CFrame*CFrame.new(-1.7,0,0)
                shiftImageBtn.Image="rbxasset://textures/ui/mouseLock_off@2x.png"
                if active then active:Disconnect(); active=nil end
            end
            shiftImageBtn.MouseButton1Click:Connect(function()
                if tick()-lastT < 0.2 then return end; lastT=tick()
                if not active then active=RunService.RenderStepped:Connect(enable) else disable() end
            end)
        else
            if shiftLockGui then shiftLockGui:Destroy(); shiftLockGui=nil; shiftImageBtn=nil end
        end
    end)
end

do
    local miscGroup = makeGroup(mainPage, "Misc")

    -- Gravity
    makeToggleInputRow(miscGroup, "Set Gravity", "(196.2)", function(on, val)
        gravityEnabled = on
        if on then
            local num = tonumber(val)
            Workspace.Gravity = num or 196.2
        else
            Workspace.Gravity = 196.2
        end
    end)

    -- Boost FPS
    local boostData = {}
    makeToggleRow(miscGroup, "Boost FPS", function(on)
        boostFPSEnabled = on
        if on then
            local L = Lighting
            boostData.GlobalShadows = L.GlobalShadows
            boostData.FogEnd = L.FogEnd
            L.GlobalShadows = false; L.FogEnd = 9e9
            pcall(function() settings().Rendering.QualityLevel = 1 end)
        else
            if boostData.GlobalShadows ~= nil then Lighting.GlobalShadows = boostData.GlobalShadows end
            if boostData.FogEnd then Lighting.FogEnd = boostData.FogEnd end
            pcall(function() settings().Rendering.QualityLevel = 0 end)
        end
    end)

    -- Touch Fling (moved from Troll)
    local flingConn = nil
    makeToggleRow(miscGroup, "Touch Fling", function(on)
        touchFlingEnabled = on
        if on then
            flingConn = RunService.Heartbeat:Connect(function()
                local char = lp.Character
                local hrp  = char and char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        local d = (p.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
                        if d < 4 then
                            hrp.Velocity = hrp.Velocity * 99999 + Vector3.new(0,99999,0)
                        end
                    end
                end
            end)
        else
            if flingConn then flingConn:Disconnect(); flingConn = nil end
        end
    end)
end

do
    local srvGroup = makeGroup(mainPage, "Server Manage")

    -- Rejoin
    makeButtonRow(srvGroup, "Rejoin Server", function(btn)
        btn.Text = "Rejoining..."
        task.wait(0.5)
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, lp)
    end)

    -- Joinxl (moved from OP)
    makeButtonRow(srvGroup, "Joinxl", function()
        game.ReplicatedStorage.System:FireServer("xl")
    end)

    -- Join Largest XL (moved from TCO)
    makeButtonRow(srvGroup, "Join Largest XL", function(btn)
        btn.Text = "Finding..."
        task.spawn(function()
            local PLACE_ID = 12943245078
            local bestId, bestCount = nil, -1
            local cursor = ""
            for _=1,5 do
                local url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Desc&limit=100"):format(PLACE_ID)
                if cursor~="" then url=url.."&cursor="..cursor end
                local ok,res = pcall(function() return HttpService:JSONDecode(game:HttpGet(url)) end)
                if not ok or not res or not res.data then break end
                for _, sv in ipairs(res.data) do
                    if (sv.playing or 0) > bestCount then bestCount=sv.playing; bestId=sv.id end
                end
                if not res.nextPageCursor or res.nextPageCursor==HttpService.null then break end
                cursor = res.nextPageCursor
            end
            if not bestId then btn.Text="Not found!"; return end
            if game.JobId==bestId then btn.Text="Already here!"; return end
            btn.Text="Joining ("..bestCount..")..."
            pcall(function() TeleportService:TeleportToPlaceInstance(PLACE_ID, bestId, lp) end)
        end)
    end)

    makeButtonRow(srvGroup, "JoinVC", function()
        pcall(function() game.ReplicatedStorage.System:FireServer("vc") end)
    end)

    makeButtonRow(srvGroup, "JoinOG", function()
        pcall(function() game.ReplicatedStorage.System:FireServer("og") end)
    end)
end

do
    local charGroup = makeGroup(mainPage, "Character")

    -- Noclip
    local noclipConn = nil
    makeToggleRow(charGroup, "Noclip", function(on)
        noclipEnabled = on
        if on then
            noclipConn = RunService.Stepped:Connect(function()
                local char = lp.Character
                if not char then return end
                for _, p in pairs(char:GetChildren()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
            end)
        else
            if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
            local char = lp.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum:ChangeState(Enum.HumanoidStateType.GettingUp) end
            end
        end
    end)

    -- Freeze Animation
    makeToggleRow(charGroup, "Freeze Animation", function(on)
        freezeAnimEnabled = on
        local char = lp.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        local anim = char:FindFirstChild("Animate")
        if on then
            if anim then anim.Disabled = true end
            for _, t in pairs(hum:GetPlayingAnimationTracks()) do t:AdjustSpeed(0) end
        else
            if anim then anim.Disabled = false end
            for _, t in pairs(hum:GetPlayingAnimationTracks()) do t:AdjustSpeed(1) end
        end
    end)

    -- God Mode
    makeToggleRow(charGroup, "God Mode", function(on)
        godModeEnabled = on
        for _, c in pairs(godConnections) do if c then c:Disconnect() end end
        godConnections = {}
        local char = lp.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        if on then
            hum.MaxHealth = math.huge; hum.Health = math.huge
            table.insert(godConnections, RunService.RenderStepped:Connect(function()
                if not godModeEnabled or shared.GodModePaused then return end
                if hum and hum.Parent then hum.MaxHealth=math.huge; hum.Health=math.huge end
            end))
        else
            hum.MaxHealth = 100; task.wait(); hum.Health = 100
        end
    end)

    -- TP To Spawn
    makeButtonRow(charGroup, "TP To Spawn", function()
        local char = lp.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local spawn = Workspace:FindFirstChildOfClass("SpawnLocation")
        hrp.CFrame = CFrame.new((spawn and spawn.Position or Vector3.new(0,5,0)) + Vector3.new(0,5,0))
    end)

    -- TP To Player
    local tpPlayerSetter
    local tpRow, tpSetter = makeDropdownRow(charGroup, "TP Target", getPlayerNames(), nil, function(val)
        selectedTarget = Players:FindFirstChild(val)
    end)
    tpPlayerSetter = tpSetter

    makeButtonRow(charGroup, "TP To Player", function()
        if selectedTarget and selectedTarget.Character and selectedTarget.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.CFrame = selectedTarget.Character.HumanoidRootPart.CFrame + Vector3.new(0,3,0) end
        end
    end)

    makeButtonRow(charGroup, "Refresh Players", function()
        local names = getPlayerNames()
        tpPlayerSetter(names, names[1])
        selectedTarget = Players:FindFirstChild(names[1])
    end)

    -- Reset
    makeButtonRow(charGroup, "Reset Character", function()
        local char = lp.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.MaxHealth=100; hum.Health=0 end
    end)
end

-- ─────────────────────────────────────────────────────────────
-- TAB: ANTI
-- ─────────────────────────────────────────────────────────────
local antiPage = createTab("Anti", 2)

do
    local antiFlingGroup = makeGroup(antiPage, "Anti (Sigma)")
    local antiFlingConn = nil
    makeToggleRow(antiFlingGroup, "Anti Fling", function(on)
        antiFlingEnabled = on
        if on then
            antiFlingConn = RunService.Stepped:Connect(function()
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= lp and p.Character then
                        for _, part in pairs(p.Character:GetDescendants()) do
                            if part:IsA("BasePart") then part.CanCollide = false end
                        end
                    end
                end
            end)
        else
            if antiFlingConn then antiFlingConn:Disconnect(); antiFlingConn=nil end
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= lp and p.Character then
                    for _, part in pairs(p.Character:GetDescendants()) do
                        if part:IsA("BasePart") then part.CanCollide = true end
                    end
                end
            end
        end
    end)

    makeToggleRow(antiFlingGroup, "Anti AFK", function(on)
        antiAfkEnabled = on
        if on then
            task.spawn(function()
                while antiAfkEnabled do
                    local vu = game:GetService("VirtualUser")
                    vu:CaptureController(); vu:ClickButton2(Vector2.new())
                    task.wait(60)
                end
            end)
        end
    end)

    local ragConn = nil
    makeToggleRow(antiFlingGroup, "Anti Ragdoll", function(on)
        antiRagdollEnabled = on
        if on then
            ragConn = RunService.Stepped:Connect(function()
                local char = lp.Character
                if not char then return end
                local hum = char:FindFirstChildOfClass("Humanoid")
                if not hum then return end
                -- Block all ragdoll/seated/fallingdown states
                hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,     false)
                hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown,  false)
                hum:SetStateEnabled(Enum.HumanoidStateType.Seated,       false)
                local st = hum:GetState()
                if st == Enum.HumanoidStateType.Ragdoll
                or st == Enum.HumanoidStateType.FallingDown
                or st == Enum.HumanoidStateType.Seated then
                    hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                end
                -- Destroy any ragdoll physics constraints inserted into the character
                for _, v in ipairs(char:GetDescendants()) do
                    if v:IsA("BallSocketConstraint") or v:IsA("HingeConstraint")
                    or v:IsA("NoCollisionConstraint") then
                        v:Destroy()
                    end
                end
            end)
        else
            if ragConn then ragConn:Disconnect(); ragConn=nil end
            local char=lp.Character; if not char then return end
            local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,    true)
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.Seated,      true)
        end
    end)

    -- Anti Void (sigma's detailed implementation)
    local avSteppedConn, avCharConn = nil, nil
    local avOrigDestroy = nil
    makeToggleRow(antiFlingGroup, "Anti Void", function(on)
        antiVoidEnabled = on
        if on then
            avOrigDestroy = Workspace.FallenPartsDestroyHeight
            Workspace.FallenPartsDestroyHeight = -50000
            local function doChar(char)
                local hrp = char:WaitForChild("HumanoidRootPart",5)
                if not hrp then return end
                avSteppedConn = RunService.Stepped:Connect(function()
                    if hrp.Position.Y < (avOrigDestroy + 5) then
                        local piv = char:GetPivot()
                        char:PivotTo(CFrame.new(piv.Position.X, avOrigDestroy+25, piv.Position.Z))
                    end
                end)
            end
            if lp.Character then doChar(lp.Character) end
            avCharConn = lp.CharacterAdded:Connect(doChar)
        else
            if avSteppedConn then avSteppedConn:Disconnect(); avSteppedConn=nil end
            if avCharConn   then avCharConn:Disconnect();   avCharConn=nil   end
            if avOrigDestroy then Workspace.FallenPartsDestroyHeight = avOrigDestroy end
        end
    end)

    local _antiKBConn = nil
    makeToggleRow(antiFlingGroup, "Anti Knockback", function(on)
        antiKBEnabled = on
        if on then
            _antiKBConn = RunService.Heartbeat:Connect(function()
                if not antiKBEnabled then return end
                local char = lp.Character
                local hrp  = char and char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                local vel = hrp.AssemblyLinearVelocity
                -- Only cancel horizontal velocity when it is unusually large (actual knockback)
                -- This avoids zeroing normal walk velocity which causes frozen animations
                if Vector2.new(vel.X, vel.Z).Magnitude > 40 then
                    hrp.AssemblyLinearVelocity = Vector3.new(0, vel.Y, 0)
                end
            end)
        else
            if _antiKBConn then _antiKBConn:Disconnect(); _antiKBConn = nil end
        end
    end)

    local _oldKickHook = nil
    local _oldKickFn   = nil
    makeToggleRow(antiFlingGroup, "Anti Kick (Client)", function(on)
        antiKickEnabled = on
        if on then
            pcall(function()
                if hookfunction then
                    _oldKickFn = hookfunction(lp.Kick, function() end)
                end
                if hookmetamethod then
                    _oldKickHook = hookmetamethod(game, "__namecall", function(self, ...)
                        if self == lp and getnamecallmethod():lower() == "kick" then return end
                        return _oldKickHook(self, ...)
                    end)
                end
            end)
        else
            pcall(function()
                if _oldKickFn   and hookfunction   then hookfunction(lp.Kick, _oldKickFn) end
                if _oldKickHook and hookmetamethod then hookmetamethod(game, "__namecall", _oldKickHook) end
            end)
            _oldKickHook = nil; _oldKickFn = nil
        end
    end)
end

do
    local antiDevGroup = makeGroup(antiPage, "Anti (DevX2/¥harrz)")

    makeToggleRow(antiDevGroup, "Auto-Fix Camera", function(on)
        autoFixCam = on
        if on then fixPlayerState() end
    end)

    makeButtonRow(antiDevGroup, "Manual UI Restore", function() fixPlayerState() end)

    local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
    makeToggleRow(antiDevGroup, "Anti-Fog", function(on)
        antiFog = on
        if not on and atmosphere then atmosphere.Density = origFogDensity end
    end)

    makeToggleRow(antiDevGroup, "Anti-Blind",  function(on) antiBlind  = on end)
    makeToggleRow(antiDevGroup, "Anti-Myopic", function(on) antiMyopic = on end)

    makeToggleRow(antiDevGroup, "Anti-Glitch", function(on)
        antiGlitch = on
    end)

    makeToggleRow(antiDevGroup, "Anti-Jail", function(on)
        antiJail = on
        if on and lp.Character and lp.Character:FindFirstChild("Jail") then
            removeCollision(lp.Character.Jail)
        end
    end)

    makeToggleRow(antiDevGroup, "Anti-Freeze (Hielo)", function(on)
        antiFreeze = on
        if on then
            -- Also handle if Hielo already exists right now
            local char = lp.Character
            if char then
                if char:FindFirstChild("Hielo") then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then hum.Health = 0 end
                end
            end
        end
    end)
end

-- ─────────────────────────────────────────────────────────────
-- TAB: VISUAL / ESP
-- ─────────────────────────────────────────────────────────────
local visualPage = createTab("Visual", 3)

do
    local espSettingsGroup = makeGroup(visualPage, "ESP Settings")

    makeToggleRow(espSettingsGroup, "Enable ESP", function(on)
        espEnabled = on
        -- Toggle name/distance BillboardGuis
        for _, data in pairs(espGuis) do
            if data and data.bb then data.bb.Enabled = on end
        end
        -- Toggle outline highlights
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= lp and p.Character then
                local h = p.Character:FindFirstChild("ESPHighlight")
                if h then h.Enabled = on end
            end
        end
    end, true)

    makeToggleRow(espSettingsGroup, "Show Display Names", function(on)
        espUseDisplay = on
        for plr, data in pairs(espGuis) do
            if data and data.lbl then
                data.lbl.Text = on and plr.DisplayName or plr.Name
            end
        end
    end)
end

do
    local espGroup = makeGroup(visualPage, "ESP Features")

    -- Name ESP
    local function createNameGui(p)
        if espGuis[p] and espGuis[p].bb then espGuis[p].bb:Destroy() end
        local char = p.Character; if not char then return end
        local head = char:FindFirstChild("Head"); if not head then return end
        local bb = Instance.new("BillboardGui")
        bb.Name="ESPNameGui_"..p.Name; bb.Size=UDim2.new(0,200,0,30)
        bb.StudsOffset=Vector3.new(0,3,0); bb.Adornee=head; bb.AlwaysOnTop=true
        bb.Enabled=espEnabled; bb.Parent=head
        local lbl = Instance.new("TextLabel")
        lbl.Name="NameLabel"; lbl.Size=UDim2.new(1,0,1,0); lbl.BackgroundTransparency=1
        lbl.Text=espUseDisplay and p.DisplayName or p.Name
        lbl.TextColor3=Color3.fromRGB(255,255,255); lbl.TextStrokeTransparency=0
        lbl.TextSize=13; lbl.FontFace=FONT_MAIN; lbl.Parent=bb
        espGuis[p] = {bb=bb, lbl=lbl}
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.Died:Connect(function()
            if espGuis[p] and espGuis[p].bb then espGuis[p].bb:Destroy() end
            espGuis[p] = nil
        end) end
    end
    local function removeNameGui(p)
        if espGuis[p] and espGuis[p].bb then espGuis[p].bb:Destroy() end
        espGuis[p] = nil
    end

    makeToggleRow(espGroup, "Name ESP", function(on)
        espNameEnabled = on
        if on then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= lp then createNameGui(p) end
            end
        else
            if not espDistEnabled then
                for p in pairs(espGuis) do removeNameGui(p) end
            end
        end
    end)

    makeToggleRow(espGroup, "Distance Label", function(on)
        espDistEnabled = on
    end)

    makeToggleInputRow(espGroup, "Max Distance", "(1000)", function(on, val)
        if on or val ~= "" then
            local n = tonumber(val)
            espMaxDist = n or 1000
        end
    end)

    -- Outline ESP
    makeToggleRow(espGroup, "Player Outline", function(on)
        espOutlineEnabled = on
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= lp and p.Character then
                local old = p.Character:FindFirstChild("ESPHighlight")
                if old then old:Destroy() end
                if on then
                    local h = Instance.new("Highlight")
                    h.Name="ESPHighlight"; h.FillTransparency=1
                    h.OutlineColor=Color3.fromRGB(255,255,255); h.OutlineTransparency=0
                    h.Enabled=true; h.Parent=p.Character
                end
            end
        end
        Players.PlayerAdded:Connect(function(p)
            if on and p ~= lp then
                p.CharacterAdded:Connect(function(char)
                    task.wait(0.5)
                    if espOutlineEnabled then
                        local h = Instance.new("Highlight")
                        h.Name="ESPHighlight"; h.FillTransparency=1
                        h.OutlineColor=Color3.fromRGB(255,255,255); h.OutlineTransparency=0; h.Parent=char
                    end
                end)
            end
        end)
    end)

    -- Enlightened Users ESP
    makeToggleRow(espGroup, "Enlightened ESP", function(on)
        showEnlightens = on
        if not on then
            for _, p in pairs(Players:GetPlayers()) do
                if p.Character then
                    local h = p.Character:FindFirstChild("enlightenHighlight")
                    if h then h:Destroy() end
                end
            end
        end
    end)

    -- Invisible Users ESP
    makeToggleRow(espGroup, "Invisible ESP", function(on)
        showInvis = on
        if not on then
            for _, p in pairs(Players:GetPlayers()) do
                if p.Character then
                    local ui = p.Character:FindFirstChild("invisAlert")
                    if ui then ui:Destroy() end
                end
            end
        end
    end)
end

do
    local animGroup = makeGroup(visualPage, "Animation / Misc")

    makeToggleInputRow(animGroup, "Anim Speed", "(1)", function(on, val)
        animSpeedEnabled = on
        animSpeedValue   = tonumber(val) or 1
        local char = lp.Character; if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then return end
        for _, t in pairs(hum:GetPlayingAnimationTracks()) do t:AdjustSpeed(on and animSpeedValue or 1) end
    end)

    makeToggleInputRow(animGroup, "Fake Lag", "(1)", function(on, val)
        fakeLagEnabled = on
        fakeLagValue   = tonumber(val) or 1
        if on then
            task.spawn(function()
                while fakeLagEnabled do
                    local char = lp.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local freeze = math.clamp(0.8/(fakeLagValue*3), 0.05, 0.8)
                        local unfreeze = math.clamp(0.2/(fakeLagValue*3), 0.05, 0.5)
                        hrp.Anchored = true; task.wait(freeze)
                        hrp.Anchored = false; task.wait(unfreeze)
                    else task.wait(0.2) end
                end
            end)
        else
            local char = lp.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.Anchored = false end
        end
    end)

    makeToggleInputRow(animGroup, "Spin", "(1)", function(on, val)
        spinEnabled = on
        spinSpeed   = tonumber(val) or 1
        if on then
            local angle = 0
            RunService.RenderStepped:Connect(function(dt)
                if not spinEnabled then return end
                local char = lp.Character
                local hrp  = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    angle = angle + (-spinSpeed * 3 * dt * 60)
                    hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, math.rad(angle), 0)
                end
            end)
        end
    end)
end


do
    local skyGroup = makeGroup(visualPage, "Rainbow Sky")
    makeToggleRow(skyGroup, "Rainbow Sky", function(on) rainbowSkyEnabled = on end)
end

do
    local sprayGroup = makeGroup(visualPage, "Spray Paint")
    makeInputRow(sprayGroup, "Spray Text", "cool sandbox game!", function(t) sprayPaintText = t end)
    makeToggleRow(sprayGroup, "Enable Spray Paint", function(on) sprayPaintEnabled = on end)
end

-- ─────────────────────────────────────────────────────────────
-- TAB: AURAS
-- ─────────────────────────────────────────────────────────────
local aurasPage = createTab("Auras", 4)

do
    local homeAuraGroup = makeGroup(aurasPage, "Home Tools")
    makeToggleRow(homeAuraGroup, "Rainbow Paint",  function(on) rainbow = on end)
    makeToggleRow(homeAuraGroup, "Shovel",          function(on) shovel  = on end)
    makeToggleRow(homeAuraGroup, "Kill Aura",       function(on) killAura = on end)
    makeToggleRow(homeAuraGroup, "Block Trail",     function(on) detailedPath = on end)
    makeDropdownRow(homeAuraGroup, "Material", {"smooth","plastic","tiles","bricks","planks","ice","neon","toxic","anchor"}, "smooth", function(v) currentMaterial=v end)
    makeDropdownRow(homeAuraGroup, "Trail Type", {"detailed","normal","rainbow detailed","rainbow normal"}, "detailed", function(v) currentBlockPathType=v end)
    makeInputRow(homeAuraGroup, "Rainbow Speed", "0.005", function(v) RainbowSpeed = tonumber(v) or 0.005 end)
    makeInputRow(homeAuraGroup, "Aura Range",    "500",   function(v) GlobalRange  = tonumber(v) or 500   end)
end

do
    local advAuraGroup = makeGroup(aurasPage, "Advanced Auras")
    makeToggleRow(advAuraGroup, "Build Aura",         function(on) buildAura    = on end)
    makeInputRow(advAuraGroup,  "Build Speed",  "0.05", function(v) buildAuraSpeed  = tonumber(v) or 0.05 end)
    makeToggleRow(advAuraGroup, "Sign Aura",           function(on) signAura     = on end)
    makeInputRow(advAuraGroup,  "Sign Speed",   "0.05", function(v) signAuraSpeed   = tonumber(v) or 0.05 end)
    makeToggleRow(advAuraGroup, "Delete Aura (Adv)",   function(on) deleteAuraAdv = on end)
    makeInputRow(advAuraGroup,  "Delete Speed", "0.05", function(v) deleteAuraSpeed = tonumber(v) or 0.05 end)
    makeInputRow(advAuraGroup,  "Delete Range", "20",   function(v) DeleteAuraRange = tonumber(v) or 20   end)
    makeToggleRow(advAuraGroup, "Rainbow Paint Aura",  function(on) paintAura    = on end)
    makeInputRow(advAuraGroup,  "Paint Speed",  "0.05", function(v) paintAuraSpeed  = tonumber(v) or 0.05 end)
    makeInputRow(advAuraGroup,  "Paint Range",  "20",   function(v) PaintAuraRange  = tonumber(v) or 20   end)
    makeInputRow(advAuraGroup,  "Rainbow Speed","0.005",function(v) auraRainbowSpeed = tonumber(v) or 0.005 end)
end

do
    local opAuraGroup = makeGroup(aurasPage, "OP Auras")

    -- Auto-Delete Bricks
    makeToggleRow(opAuraGroup, "Auto-Delete Bricks", function(on)
        delCubesEnabled = on
        task.spawn(function()
            while delCubesEnabled do
                local remote = getToolRemote("Delete")
                local hrp    = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
                if remote and hrp then
                    for _, v in pairs(Workspace:GetDescendants()) do
                        if not delCubesEnabled then break end
                        if v.Name=="Brick" and v:IsA("BasePart") then
                            remote:FireServer(v, hrp.Position); task.wait(0.01)
                        end
                    end
                end
                task.wait(0.5)
            end
        end)
    end)

    -- Void Aura
    makeToggleRow(opAuraGroup, "Void Aura", function(on)
        voidAuraEnabled = on
        task.spawn(function()
            local char = lp.Character or lp.CharacterAdded:Wait()
            local root = char:WaitForChild("HumanoidRootPart")
            local orig = root.CFrame
            local black = Color3.new(0,0,0)
            local isMob = UserInputService.TouchEnabled
            local syncT  = isMob and 0.08 or 0.05
            local batchP = isMob and 0.02 or 0.01
            local batchSz= isMob and 6 or 12
            local nConn
            local function setNC(e)
                if e then
                    if nConn then nConn:Disconnect() end
                    nConn=RunService.Stepped:Connect(function()
                        if char and char.Parent then for _,p in pairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end end
                    end)
                else
                    if nConn then nConn:Disconnect(); nConn=nil end
                    for _,p in pairs(char:GetDescendants()) do if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then p.CanCollide=true end end
                end
            end
            if not voidAuraEnabled then return end
            setNC(true)
            while voidAuraEnabled do
                local remote = getToolRemote("Paint")
                if remote and char and char:FindFirstChild("HumanoidRootPart") then
                    local targets = {}
                    for _,obj in pairs(Workspace:GetDescendants()) do
                        if not voidAuraEnabled then break end
                        if obj.Name=="Brick" and obj:IsA("BasePart") and obj.Color~=black then table.insert(targets,obj) end
                    end
                    for i,blk in ipairs(targets) do
                        if not voidAuraEnabled then break end
                        root.CFrame = blk.CFrame; task.wait(syncT)
                        task.spawn(function()
                            for _,side in ipairs(ALL_SIDES_S) do remote:FireServer(blk,side,blk.Position,HANDSHAKE,black,"spray"," ") end
                        end)
                        if i%batchSz==0 then task.wait(batchP) end
                    end
                end
                if voidAuraEnabled then root.CFrame=orig; task.wait(0.5) end
            end
            setNC(false); root.CFrame=orig
        end)
    end)
end


do
    local extraAuraGroup = makeGroup(aurasPage, "Extra Tools")

    -- Block Selector
    local _selLbl = nil
    makeButtonRow(extraAuraGroup, "Select Block (click)", function()
        selectedBlockMode = true
        notify("Panel", "Click a block to select it!")
    end)
    makeButtonRow(extraAuraGroup, "Clear Block Selection", function()
        selectedBlock = nil
        notify("Panel", "Block selection cleared.")
    end)

    -- Delete Click Aura
    makeToggleRow(extraAuraGroup, "Delete Click Aura", function(on)
        deleteClickAura = on
        if not on then
            _dcaPos = nil
            if _dcaBox and _dcaBox.Parent then _dcaBox:Destroy() end
            _dcaBox = nil
        end
    end)

    -- Boombox Detector
    local _bbLbl = makeSection(extraAuraGroup, "Boombox: none selected")
    makeButtonRow(extraAuraGroup, "Copy Boombox ID", function()
        if _tempBbId ~= "" then
            pcall(function() setclipboard(_tempBbId) end)
            notify("Panel", "Copied: " .. _tempBbId)
        else
            notify("Panel", "No boombox selected!")
        end
    end)
    -- expose label so unified handler can update it
    shared._bbLbl = _bbLbl
end

-- ─────────────────────────────────────────────────────────────
-- TAB: BUILD
-- ─────────────────────────────────────────────────────────────
local buildPage = createTab("Build", 5)

-- Ghost part cleanup on block placed
if Workspace:FindFirstChild("Bricks") and Workspace.Bricks:FindFirstChild(lp.Name) then
    Workspace.Bricks[lp.Name].ChildAdded:Connect(function()
        built = true
        for _, v in ipairs(Workspace:GetChildren()) do
            if v:IsA("BasePart") and v.Name=="Part" and v.Transparency>0.4 then v:Destroy() end
        end
    end)
end

local function buildblock(pos, bsize)
    task.wait(0.01)
    built = false; skipblock = false
    local attempts = 0
    repeat
        attempts += 1
        forceEquip("Build")
        local ev = getToolEvent("Build")
        if ev then ev:FireServer(Workspace.Terrain, Enum.NormalId.Top, pos, bsize or "normal") end
        if tpToBlock then
            local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.CFrame = CFrame.new(pos + Vector3.new(0,6,0)) end
        end
        task.wait(0.07)
    until built or buildStopped or skipblock or attempts > 40
    built = false
end

do
    local ctrlGroup = makeGroup(buildPage, "Build Controls")
    makeButtonRow(ctrlGroup, "Stop Building", function() buildStopped = true end)
    makeButtonRow(ctrlGroup, "Skip Block",    function() skipblock = true end)
    makeToggleRow(ctrlGroup, "TP to Block", function(on) tpToBlock = on end, true)
end

do
    local genGroup = makeGroup(buildPage, "Generation")
    local cubeSize, textToBuild = 3, ""

    makeInputRow(genGroup, "Cube Size", "e.g. 5", function(txt)
        cubeSize = tonumber(txt) or 3
    end)

    makeButtonRow(genGroup, "Build Cube ↵", function()
        local char = lp.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        buildStopped = false
        local startPos = snapToGrid(char.HumanoidRootPart.Position)
        task.spawn(function()
            for y=0,cubeSize-1 do for x=0,cubeSize-1 do for z=0,cubeSize-1 do
                if buildStopped then break end
                buildblock(startPos + Vector3.new(x*mult,y*mult,z*mult))
            end end end
        end)
    end)

    makeInputRow(genGroup, "Text to Build", "Enter text...", function(txt)
        textToBuild = txt
    end)

    makeButtonRow(genGroup, "Build Text ↵", function()
        local txtstuff
        pcall(function() txtstuff = loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Text-to-Blocks-WIP-20736"))() end)
        if not txtstuff or not lp.Character then return end
        buildStopped = false
        task.spawn(function()
            local blocks = txtstuff.getblocks(textToBuild)
            local _,ptt,cfr = txtstuff.displayblocks(blocks,lp.Character:GetPivot(),4,true,4,4,0,false,Enum.Material.ForceField)
            for _,v in pairs(cfr) do if buildStopped then break end; buildblock(snapToGrid(v.Position)) end
            if ptt then for _,p in pairs(ptt) do p:Destroy() end end
        end)
    end)
end

do
    local saveGroup = makeGroup(buildPage, "Save / Load")

    -- Helper: list saves (strips .json extension)
    local function listSaves()
        local files = {}
        pcall(function()
            if not isfolder("SigmaPanel_Builds") then makefolder("SigmaPanel_Builds") end
            for _, f in ipairs(listfiles("SigmaPanel_Builds")) do
                local name = f:match("([^\\/]+)%.json$")
                if name then table.insert(files, name) end
            end
        end)
        if #files == 0 then table.insert(files, "(no saves)") end
        return files
    end

    -- Dropdown for existing saves
    local saveListSetter
    local _, _setSaves = makeDropdownRow(saveGroup, "Select Save", listSaves(), nil, function(val)
        if val ~= "(no saves)" then saveName = val end
    end)
    saveListSetter = _setSaves

    -- Text input to type a new name (for saving)
    makeInputRow(saveGroup, "New Name", "Name...", function(t) saveName = t end)

    makeButtonRow(saveGroup, "Save Build", function(btn)
        if saveName == "" or saveName == "(no saves)" then btn.Text = "Enter name first!"; return end
        local data = {}
        local folder = Workspace.Bricks and Workspace.Bricks:FindFirstChild(lp.Name)
        if folder then
            for _, v in ipairs(folder:GetChildren()) do
                if v:IsA("BasePart") then table.insert(data, {p={v.Position.X,v.Position.Y,v.Position.Z}}) end
            end
        end
        if not isfolder("SigmaPanel_Builds") then makefolder("SigmaPanel_Builds") end
        writefile("SigmaPanel_Builds/"..saveName..".json", HttpService:JSONEncode(data))
        btn.Text = "Saved!"
        -- Refresh dropdown
        local saves = listSaves()
        saveListSetter(saves, saveName)
    end)

    makeButtonRow(saveGroup, "Load Build", function(btn)
        if saveName == "" or saveName == "(no saves)" then btn.Text = "Select a save first!"; return end
        local path = "SigmaPanel_Builds/"..saveName..".json"
        if not isfile(path) then btn.Text = "Not found!"; return end
        local data = HttpService:JSONDecode(readfile(path))
        buildStopped = false
        task.spawn(function()
            for _, v in ipairs(data) do
                if buildStopped then break end
                buildblock(Vector3.new(v.p[1],v.p[2],v.p[3]))
            end
        end)
    end)

    makeButtonRow(saveGroup, "Delete Save", function(btn)
        if saveName == "" or saveName == "(no saves)" then return end
        local path = "SigmaPanel_Builds/"..saveName..".json"
        pcall(function() if isfile(path) then delfile(path) end end)
        saveName = ""
        local saves = listSaves()
        saveListSetter(saves, saves[1])
        btn.Text = "Deleted!"
    end)
end

-- ─────────────────────────────────────────────────────────────
-- TAB: OP

-- ─────────────────────────────────────────────────────────────
-- COLOR PICKER  (ported from ¥harrz, library-less HSV picker)
-- ─────────────────────────────────────────────────────────────
local _cpFrame    = nil
local _cpCallback = nil

local function closeColorPicker()
    if _cpFrame then _cpFrame:Destroy(); _cpFrame = nil end
    _cpCallback = nil
end

local function openColorPicker(callback)
    closeColorPicker()
    _cpCallback = callback

    -- Frame
    local picker = Instance.new("Frame")
    picker.Name            = "SigmaColorPicker"
    picker.Size            = UDim2.new(0, 260, 0, 262)
    picker.Position        = UDim2.new(0.5, -130, 0.5, -131)
    picker.BackgroundColor3= Color3.fromRGB(16, 12, 28)
    picker.BorderSizePixel = 0
    picker.ZIndex          = 30
    picker.Parent          = ScreenGui
    _cpFrame = picker
    Instance.new("UICorner", picker).CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke"); stroke.Color=C_ACCENT; stroke.Thickness=1.5; stroke.Parent=picker

    -- Title + close
    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size=UDim2.new(1,-32,0,26); titleLbl.Position=UDim2.new(0,8,0,3)
    titleLbl.BackgroundTransparency=1; titleLbl.Text="Color Picker"
    titleLbl.TextColor3=Color3.fromRGB(210,230,210); titleLbl.FontFace=FONT_MAIN
    titleLbl.TextSize=12; titleLbl.TextXAlignment=Enum.TextXAlignment.Left
    titleLbl.ZIndex=31; titleLbl.Parent=picker

    local xBtn = Instance.new("TextButton")
    xBtn.Size=UDim2.new(0,22,0,22); xBtn.Position=UDim2.new(1,-26,0,3)
    xBtn.BackgroundColor3=Color3.fromRGB(180,40,40); xBtn.Text="✕"
    xBtn.TextColor3=Color3.fromRGB(255,255,255); xBtn.FontFace=FONT_MAIN
    xBtn.TextSize=10; xBtn.ZIndex=32; xBtn.Parent=picker
    Instance.new("UICorner",xBtn).CornerRadius=UDim.new(0,4)
    xBtn.MouseButton1Click:Connect(closeColorPicker)

    -- ── SV canvas ──────────────────────────────────────────────
    -- Layer 0 (svOuter): pure hue color background
    -- Layer 1 (satLayer): white, transparent on right  → desaturation gradient
    -- Layer 2 (valLayer): black, transparent on bottom → value/darkness gradient
    local svOuter = Instance.new("Frame")
    svOuter.Size=UDim2.new(1,-16,0,150); svOuter.Position=UDim2.new(0,8,0,32)
    svOuter.BackgroundColor3=Color3.fromRGB(255,0,0)
    svOuter.BorderSizePixel=0; svOuter.ClipsDescendants=true
    svOuter.ZIndex=31; svOuter.Parent=picker
    Instance.new("UICorner",svOuter).CornerRadius=UDim.new(0,5)

    -- Saturation layer: solid white fading to fully transparent left→right
    local satLayer = Instance.new("Frame")
    satLayer.Size=UDim2.new(1,0,1,0); satLayer.BackgroundColor3=Color3.fromRGB(255,255,255)
    satLayer.BackgroundTransparency=0; satLayer.BorderSizePixel=0; satLayer.ZIndex=32; satLayer.Parent=svOuter
    local satGrad = Instance.new("UIGradient")
    satGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),   -- left: fully opaque white
        NumberSequenceKeypoint.new(1, 1),   -- right: fully transparent
    })
    satGrad.Rotation = 0
    satGrad.Parent = satLayer

    -- Value layer: solid black fading to fully transparent bottom→top
    local valLayer = Instance.new("Frame")
    valLayer.Size=UDim2.new(1,0,1,0); valLayer.BackgroundColor3=Color3.fromRGB(0,0,0)
    valLayer.BackgroundTransparency=0; valLayer.BorderSizePixel=0; valLayer.ZIndex=33; valLayer.Parent=svOuter
    local valGrad = Instance.new("UIGradient")
    valGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),   -- top: fully transparent (bright)
        NumberSequenceKeypoint.new(1, 0),   -- bottom: fully opaque black (dark)
    })
    valGrad.Rotation = 90   -- 90° = top→bottom
    valGrad.Parent = valLayer

    -- SV cursor dot
    local svCursor = Instance.new("Frame"); svCursor.Size=UDim2.new(0,10,0,10)
    svCursor.AnchorPoint=Vector2.new(0.5,0.5); svCursor.Position=UDim2.new(1,0,0,0)
    svCursor.BackgroundColor3=Color3.fromRGB(255,255,255); svCursor.BorderSizePixel=0; svCursor.ZIndex=35; svCursor.Parent=svOuter
    Instance.new("UICorner",svCursor).CornerRadius=UDim.new(1,0)
    local scs=Instance.new("UIStroke"); scs.Color=Color3.fromRGB(0,0,0); scs.Thickness=1.5; scs.Parent=svCursor

    -- ── Hue bar ────────────────────────────────────────────────
    local hueBar = Instance.new("Frame"); hueBar.Size=UDim2.new(1,-16,0,14); hueBar.Position=UDim2.new(0,8,0,190)
    hueBar.BackgroundColor3=Color3.fromRGB(255,255,255); hueBar.BorderSizePixel=0; hueBar.ZIndex=31; hueBar.Parent=picker
    Instance.new("UICorner",hueBar).CornerRadius=UDim.new(0,4)
    local hueGrad = Instance.new("UIGradient")
    hueGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0/6, Color3.fromRGB(255,  0,  0)),
        ColorSequenceKeypoint.new(1/6, Color3.fromRGB(255,255,  0)),
        ColorSequenceKeypoint.new(2/6, Color3.fromRGB(  0,255,  0)),
        ColorSequenceKeypoint.new(3/6, Color3.fromRGB(  0,255,255)),
        ColorSequenceKeypoint.new(4/6, Color3.fromRGB(  0,  0,255)),
        ColorSequenceKeypoint.new(5/6, Color3.fromRGB(255,  0,255)),
        ColorSequenceKeypoint.new(6/6, Color3.fromRGB(255,  0,  0)),
    })
    hueGrad.Parent = hueBar
    local hueCursor = Instance.new("Frame"); hueCursor.Size=UDim2.new(0,6,1,4)
    hueCursor.AnchorPoint=Vector2.new(0.5,0.5); hueCursor.Position=UDim2.new(0,0,0.5,0)
    hueCursor.BackgroundColor3=Color3.fromRGB(255,255,255); hueCursor.BorderSizePixel=0; hueCursor.ZIndex=32; hueCursor.Parent=hueBar
    Instance.new("UICorner",hueCursor).CornerRadius=UDim.new(0,2)
    local hcs=Instance.new("UIStroke"); hcs.Color=Color3.fromRGB(0,0,0); hcs.Thickness=1.2; hcs.Parent=hueCursor

    -- ── Preview swatch ─────────────────────────────────────────
    local preview = Instance.new("Frame"); preview.Size=UDim2.new(0,34,0,34)
    preview.Position=UDim2.new(1,-42,0,210); preview.BackgroundColor3=Color3.fromRGB(255,0,0)
    preview.BorderSizePixel=0; preview.ZIndex=31; preview.Parent=picker
    Instance.new("UICorner",preview).CornerRadius=UDim.new(0,5)
    local pvs=Instance.new("UIStroke"); pvs.Color=C_ACCENT; pvs.Thickness=1.2; pvs.Parent=preview

    -- ── Hex + RGB inputs ───────────────────────────────────────
    local hexLbl=Instance.new("TextLabel"); hexLbl.Size=UDim2.new(0,28,0,14); hexLbl.Position=UDim2.new(0,8,0,212)
    hexLbl.BackgroundTransparency=1; hexLbl.Text="HEX"; hexLbl.TextColor3=Color3.fromRGB(190,190,190)
    hexLbl.FontFace=FONT_MAIN; hexLbl.TextSize=10; hexLbl.ZIndex=31; hexLbl.Parent=picker
    local hexBox=Instance.new("TextBox"); hexBox.Size=UDim2.new(0,72,0,14); hexBox.Position=UDim2.new(0,36,0,212)
    hexBox.BackgroundColor3=Color3.fromRGB(28,20,45); hexBox.TextColor3=Color3.fromRGB(230,230,230)
    hexBox.PlaceholderText="FF0000"; hexBox.Text="FF0000"; hexBox.FontFace=FONT_MAIN; hexBox.TextSize=10
    hexBox.ZIndex=31; hexBox.Parent=picker
    Instance.new("UICorner",hexBox).CornerRadius=UDim.new(0,3)
    local hs=Instance.new("UIStroke"); hs.Color=Color3.fromRGB(60,60,100); hs.Thickness=1; hs.Parent=hexBox

    local function makeNumBox(lx,ly,labelTxt)
        local lbl=Instance.new("TextLabel"); lbl.Size=UDim2.new(0,14,0,14); lbl.Position=UDim2.new(0,lx,0,ly)
        lbl.BackgroundTransparency=1; lbl.Text=labelTxt; lbl.TextColor3=Color3.fromRGB(190,190,190)
        lbl.FontFace=FONT_MAIN; lbl.TextSize=10; lbl.ZIndex=31; lbl.Parent=picker
        local box=Instance.new("TextBox"); box.Size=UDim2.new(0,34,0,14); box.Position=UDim2.new(0,lx+15,0,ly)
        box.BackgroundColor3=Color3.fromRGB(28,20,45); box.TextColor3=Color3.fromRGB(230,230,230)
        box.PlaceholderText="0"; box.Text="0"; box.FontFace=FONT_MAIN; box.TextSize=10
        box.ZIndex=31; box.Parent=picker
        Instance.new("UICorner",box).CornerRadius=UDim.new(0,3)
        local s2=Instance.new("UIStroke"); s2.Color=Color3.fromRGB(60,60,100); s2.Thickness=1; s2.Parent=box
        return box
    end
    local rBox=makeNumBox(8,232,"R"); local gBox=makeNumBox(62,232,"G"); local bBox=makeNumBox(116,232,"B")

    local selH,selS,selV = 0,1,1
    local suppress = false

    local function syncInputs()
        suppress=true
        local c=Color3.fromHSV(selH,selS,selV)
        local ri,gi,bi=math.floor(c.R*255+0.5),math.floor(c.G*255+0.5),math.floor(c.B*255+0.5)
        hexBox.Text=string.format("%02X%02X%02X",ri,gi,bi)
        rBox.Text=tostring(ri); gBox.Text=tostring(gi); bBox.Text=tostring(bi)
        preview.BackgroundColor3=c; suppress=false
    end

    local function updateColor()
        local c=Color3.fromHSV(selH,selS,selV)
        svOuter.BackgroundColor3=Color3.fromHSV(selH,1,1)
        hueCursor.Position=UDim2.new(selH,0,0.5,0)
        svCursor.Position=UDim2.new(selS,0,1-selV,0)
        preview.BackgroundColor3=c; syncInputs()
        if _cpCallback then _cpCallback(c) end
    end
    updateColor()

    local hueDrag,svDrag=false,false
    hueBar.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            hueDrag=true
            selH=math.clamp((UserInputService:GetMouseLocation().X-hueBar.AbsolutePosition.X)/hueBar.AbsoluteSize.X,0,1)
            updateColor()
        end
    end)
    hueBar.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then hueDrag=false end
    end)
    svOuter.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            svDrag=true
            local mp=UserInputService:GetMouseLocation()
            selS=math.clamp((mp.X-svOuter.AbsolutePosition.X)/svOuter.AbsoluteSize.X,0,1)
            selV=1-math.clamp((mp.Y-svOuter.AbsolutePosition.Y)/svOuter.AbsoluteSize.Y,0,1)
            updateColor()
        end
    end)
    svOuter.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then svDrag=false end
    end)

    local rsConn = RunService.RenderStepped:Connect(function()
        if not _cpFrame then return end
        local mp=UserInputService:GetMouseLocation()
        if hueDrag then
            selH=math.clamp((mp.X-hueBar.AbsolutePosition.X)/hueBar.AbsoluteSize.X,0,1); updateColor()
        end
        if svDrag then
            selS=math.clamp((mp.X-svOuter.AbsolutePosition.X)/svOuter.AbsoluteSize.X,0,1)
            selV=1-math.clamp((mp.Y-svOuter.AbsolutePosition.Y)/svOuter.AbsoluteSize.Y,0,1); updateColor()
        end
    end)
    picker.AncestryChanged:Connect(function() pcall(function() rsConn:Disconnect() end) end)

    hexBox.FocusLost:Connect(function()
        if suppress then return end
        local hex=hexBox.Text:gsub("#",""):upper()
        if #hex==6 then
            local r2=tonumber(hex:sub(1,2),16); local g2=tonumber(hex:sub(3,4),16); local b2=tonumber(hex:sub(5,6),16)
            if r2 and g2 and b2 then
                selH,selS,selV=Color3.toHSV(Color3.fromRGB(r2,g2,b2)); updateColor()
            end
        end
    end)
    local function applyRGB()
        if suppress then return end
        local r2=math.clamp(tonumber(rBox.Text) or 0,0,255)
        local g2=math.clamp(tonumber(gBox.Text) or 0,0,255)
        local b2=math.clamp(tonumber(bBox.Text) or 0,0,255)
        selH,selS,selV=Color3.toHSV(Color3.fromRGB(r2,g2,b2)); updateColor()
    end
    rBox.FocusLost:Connect(applyRGB); gBox.FocusLost:Connect(applyRGB); bBox.FocusLost:Connect(applyRGB)
end

-- Per-face brick text + block color
-- ─────────────────────────────────────────────────────────────
local opPage = createTab("OP", 6)

do
    local faceGroup = makeGroup(opPage, "Per-Face Text & Color")
    makeSection(faceGroup, "Enter text per face then Apply")

    local faceInputs = {}
    for i, data in ipairs(sideData) do
        local row = Instance.new("Frame")
        row.Size=UDim2.new(1,0,0,22); row.BackgroundTransparency=1; row.ZIndex=8; row.Parent=faceGroup

        local lbl = Instance.new("TextLabel")
        lbl.Size=UDim2.new(0,60,1,0); lbl.Position=UDim2.new(0,0,0,0)
        lbl.BackgroundTransparency=1; lbl.Text=data.label; lbl.TextColor3=C_ACCENT
        lbl.FontFace=FONT_MAIN; lbl.TextSize=11; lbl.TextXAlignment=Enum.TextXAlignment.Left
        lbl.ZIndex=9; lbl.Parent=row

        local tb = Instance.new("TextBox")
        tb.Size=UDim2.new(1,-88,0,18); tb.Position=UDim2.new(0,62,0.5,-9)
        tb.BackgroundColor3=Color3.new(0,0,0); tb.BorderColor3=C_BORDER
        tb.Text=data.text; tb.TextColor3=C_WHITE; tb.FontFace=FONT_MAIN; tb.TextSize=12
        tb.PlaceholderText=data.label; tb.ZIndex=9; tb.Parent=row
        tb.FocusLost:Connect(function() data.text=tb.Text end)

        local cbtn = Instance.new("TextButton")
        cbtn.Size=UDim2.new(0,22,0,18); cbtn.Position=UDim2.new(1,-24,0.5,-9)
        cbtn.BackgroundColor3=data.color; cbtn.Text=""; cbtn.ZIndex=9
        cbtn.BorderColor3=C_BORDER; cbtn.Parent=row

        faceInputs[i] = {tb=tb, cbtn=cbtn}
        local _data = data  -- upvalue capture
        local _cbtn = cbtn
        cbtn.MouseButton1Click:Connect(function()
            openColorPicker(function(c)
                _data.color = c
                _cbtn.BackgroundColor3 = c
            end)
        end)
    end

    makeButtonRow(faceGroup, "Apply Text to Brick", function()
        local remote = getToolRemote("Paint")
        local brick  = ReplicatedStorage:FindFirstChild("Brick")
        if not remote or not brick then notify("Panel","Paint tool or Brick not found!") return end
        local rootPos = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") and lp.Character.HumanoidRootPart.Position
        if not rootPos then return end
        for _, data in ipairs(sideData) do
            local r = math.floor(data.color.R*255)
            local g = math.floor(data.color.G*255)
            local b2= math.floor(data.color.B*255)
            local hex = string.format("%02X%02X%02X",r,g,b2)
            local styled = string.format('<font color="#%s">%s</font>', hex, data.text)
            remote:FireServer(brick, data.side, rootPos, HANDSHAKE, currentBlockColor, "spray", styled)
            task.wait(0.08)
        end
        notify("Panel","Applied text!")
    end)
end

do
    local opMiscGroup = makeGroup(opPage, "Block Settings")

    -- Brick Color swatch + picker (¥harrz style)
    do
        local bcRow = Instance.new("Frame")
        bcRow.Size=UDim2.new(1,0,0,22); bcRow.BackgroundTransparency=1; bcRow.ZIndex=8; bcRow.Parent=opMiscGroup
        local bcLbl = Instance.new("TextLabel")
        bcLbl.Size=UDim2.new(0.55,0,1,0); bcLbl.BackgroundTransparency=1
        bcLbl.Text="Brick Color"; bcLbl.TextColor3=C_WHITE; bcLbl.FontFace=FONT_MAIN
        bcLbl.TextSize=12; bcLbl.TextXAlignment=Enum.TextXAlignment.Left; bcLbl.ZIndex=9; bcLbl.Parent=bcRow
        local bcSwatch = Instance.new("Frame")
        bcSwatch.Size=UDim2.new(0,20,0,18); bcSwatch.Position=UDim2.new(0.55,0,0.5,-9)
        bcSwatch.BackgroundColor3=currentBlockColor; bcSwatch.BorderColor3=C_BORDER; bcSwatch.ZIndex=9; bcSwatch.Parent=bcRow
        local bcBtn = Instance.new("TextButton")
        bcBtn.Size=UDim2.new(0.42,0,0,18); bcBtn.Position=UDim2.new(0.58,2,0.5,-9)
        bcBtn.BackgroundColor3=C_BTN; bcBtn.BorderColor3=C_BORDER
        bcBtn.Text="Pick"; bcBtn.TextColor3=C_WHITE; bcBtn.FontFace=FONT_MAIN; bcBtn.TextSize=11; bcBtn.ZIndex=9; bcBtn.Parent=bcRow
        bcBtn.MouseButton1Click:Connect(function()
            openColorPicker(function(c)
                currentBlockColor = c
                bcSwatch.BackgroundColor3 = c
            end)
        end)
    end

    makeDropdownRow(opMiscGroup, "Brick Material", {
        "Smooth","Plastic","Tiles","Bricks","Planks","Ice","Grass","Sand","Snow","Glass","Wood","Stone","Neon","Toxic"
    }, "Plastic", function(val) currentOPMaterial = val:lower() end)

    -- Apply the selected block color AND material to the RepStorage brick in one shot
    makeButtonRow(opMiscGroup, "Apply Color & Material", function()
        local remote = getToolRemote("Paint")
        local brick  = ReplicatedStorage:FindFirstChild("Brick")
        if not remote or not brick then notify("Panel", "Paint tool or Brick not found!") return end
        local char = lp.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local rootPos = char.HumanoidRootPart.Position
        -- Fire: sets material + color on all sides via the Front face
        remote:FireServer(brick, Enum.NormalId.Front, rootPos, HANDSHAKE, currentBlockColor, currentOPMaterial, "")
        task.wait(0.3)
        -- Spray all sides with the block color to lock it in
        for _, side in ipairs(ALL_SIDES_E) do
            remote:FireServer(brick, side, rootPos, HANDSHAKE, currentBlockColor, "spray", " ")
            task.wait(0.05)
        end
        notify("Panel", "Applied: " .. currentOPMaterial .. " + color")
    end)

    makeButtonRow(opMiscGroup, "Anchor Brick", function()
        local r = getToolRemote("Paint"); local b = ReplicatedStorage:FindFirstChild("Brick")
        if r and b then r:FireServer(b,"Front",b.Position,HANDSHAKE,Color3.new(1,1,1),"anchor","") end
    end)

    makeButtonRow(opMiscGroup, "Toxic Brick", function()
        local r = getToolRemote("Paint"); local b = ReplicatedStorage:FindFirstChild("Brick")
        if r and b then r:FireServer(b,"Front",b.Position,HANDSHAKE,Color3.new(1,1,1),"toxic","") end
    end)
end

do
    local bkitGroup = makeGroup(opPage, "BKit")
    makeButtonRow(bkitGroup, "Fix BKit", function(btn)
        btn.Text = "Fixing..."
        local ok,err = pcall(function()
            local rs = ReplicatedStorage
            if not rs:FindFirstChild("Brick") then Instance.new("Part").Name="Brick"; local b=Instance.new("Part"); b.Name="Brick"; b.Parent=rs end
            for _,v in pairs(lp.Character:GetChildren()) do
                if v:IsA("Tool") then local s=v:FindFirstChild("Script"); if s then s.Disabled=true; task.wait(); s.Disabled=false end end
            end
        end)
        btn.Text = ok and "Fixed!" or "Failed"
    end)

    makeButtonRow(bkitGroup, "Break BKit", function(btn)
        btn.Text = "Breaking..."
        local ok = pcall(function()
            local char = lp.Character
            local del  = char and char:FindFirstChild("Delete")
            local brick = ReplicatedStorage:FindFirstChild("Brick")
            if del and brick then
                del.Script.Event:FireServer(brick, char.HumanoidRootPart.Position)
                del.Parent = lp.Backpack
            end
        end)
        btn.Text = ok and "Broken!" or "Failed"
    end)

    makeButtonRow(bkitGroup, "Anchor Brick", function()
        local remote = getToolRemote("Paint")
        local brick  = ReplicatedStorage:FindFirstChild("Brick")
        if remote and brick then remote:FireServer(brick,"Front",brick.Position,HANDSHAKE,Color3.new(1,1,1),"anchor","") end
    end)

    makeButtonRow(bkitGroup, "Revert RepStorage", function()
        local char   = lp.Character
        local brick  = ReplicatedStorage:FindFirstChild("Brick")
        local remote = getToolRemote("Paint")
        if not remote or not brick or not char then return end
        local rootPos = char.HumanoidRootPart.Position
        local GREY = Color3.fromRGB(211,211,211)
        remote:FireServer(brick,Enum.NormalId.Top,rootPos,HANDSHAKE,GREY,"plastic","")
        task.wait(0.5)
        for _,side in ipairs(ALL_SIDES_E) do remote:FireServer(brick,side,rootPos,HANDSHAKE,GREY,"spray"," "); task.wait(0.2) end
        notify("Panel","Reverted!")
    end)

    makeButtonRow(bkitGroup, "Toxic Brick", function()
        local remote = getToolRemote("Paint")
        local brick  = ReplicatedStorage:FindFirstChild("Brick")
        if remote and brick then remote:FireServer(brick,"Front",brick.Position,HANDSHAKE,Color3.new(1,1,1),"toxic","") end
    end)

    makeButtonRow(bkitGroup, "Delete RepStorage", function()
        local delEv = getToolRemote("Delete")
        local brick  = ReplicatedStorage:FindFirstChild("Brick")
        if delEv and brick and lp.Character then delEv:FireServer(brick, lp.Character.HumanoidRootPart.Position) end
    end)

    -- Auto Drop on Death (moved from TCO)
    makeToggleRow(bkitGroup, "Auto Drop on Death", function(on)
        autoDropOnDeath = on
        if on then
            lp.CharacterAdded:Connect(function(char)
                if not autoDropOnDeath then return end
                local hum = char:WaitForChild("Humanoid",5)
                if not hum then return end
                hum.Died:Connect(function()
                    task.wait(0.05)
                    for _, tool in ipairs(lp.Backpack:GetChildren()) do
                        if tool:IsA("Tool") then tool.Parent=char end
                    end
                    task.wait(0.05)
                    for _, tool in ipairs(char:GetChildren()) do
                        if tool:IsA("Tool") then tool:AddTag("ADO"); tool.Parent=Workspace end
                    end
                end)
            end)
        end
    end)
end

-- ─────────────────────────────────────────────────────────────
-- TAB: TCO
-- ChatSpy, Bot, BKit, TCO-specific misc
-- ─────────────────────────────────────────────────────────────
local tcoPage = createTab("TCO", 7)

do
    local tcoTCOCheck = Instance.new("TextLabel")
    tcoTCOCheck.Size=UDim2.new(1,0,0,18); tcoTCOCheck.BackgroundTransparency=1
    tcoTCOCheck.Text = isTCOPlace() and "✓ TCO detected" or "⚠ Not in TCO – some features may not work"
    tcoTCOCheck.TextColor3 = isTCOPlace() and Color3.fromRGB(0,200,100) or Color3.fromRGB(255,180,0)
    tcoTCOCheck.FontFace=FONT_MAIN; tcoTCOCheck.TextSize=11
    tcoTCOCheck.ZIndex=8; tcoTCOCheck.Parent=tcoPage

    local spyGroup = makeGroup(tcoPage, "Chat Spy")

    local _spyChatCallback
    _spyChatCallback = function(on)
        spychat = on
        if on then
            local namecolors = {
                peasant={150,103,102}, arken={4,175,236}, admin={245,205,48},
                hidden={255,0,0}, iqgenius={255,179,179}, iqdumb={200,0,0},
            }
            local nchex = {}
            for k,v in pairs(namecolors) do
                local c = Color3.fromRGB(v[1], v[2], v[3])
                nchex[k] = string.format("#%02X%02X%02X",
                    math.floor(c.R*255+0.5),
                    math.floor(c.G*255+0.5),
                    math.floor(c.B*255+0.5))
            end
            TextChatService.OnIncomingMessage = function(mdata)
                local plr = mdata.TextSource and mdata.TextSource.UserId and Players:GetPlayerByUserId(mdata.TextSource.UserId)
                if not plr then return end
                if not isTCOPlace() then return end
                local cn = plr.Neutral and (plr:GetAttribute("Arken")==true and "arken" or "peasant") or "admin"
                local muted = plr:HasTag("Muted")
                if muted then cn="hidden"; if not spychat then mdata.Text="" end end
                local hidden = mdata.Text:sub(1,1)==";"
                if hidden then
                    if spychat then cn="hidden" else mdata.Text="" end
                end
                local hex = nchex[cn] or "#ffffff"
                local v = namecolors[cn] or {255,255,255}
                local icon = ""
                if spychat then
                    if hidden then icon="[H] " elseif muted then icon="[M] " end
                end
                mdata.PrefixText = string.format('<font color="%s">%s(%s) </font>', hex, icon, plr.DisplayName)
            end
        else
            TextChatService.OnIncomingMessage = nil
        end
    end
    makeToggleRow(spyGroup, "Spy Chat", _spyChatCallback, true)
    _spyChatCallback(true)  -- auto-activate on load

    makeToggleRow(spyGroup, "Announce Donations", function(on) donateSpyOn = on end)
    makeToggleRow(spyGroup, "Announce Muted Chats", function(on) mutedSpyOn = on end)

    local botGroup = makeGroup(tcoPage, "Bot Replier")
    makeToggleRow(botGroup, "Bot Replier", function(on) botReplyOn = on end)
    makeToggleRow(botGroup, "Case Sensitive", function(on) botCaseSensitive = on end)
    makeInputRow(botGroup, "Trigger Word", "e.g. !help", function(t) botTrigger=t end)
    makeInputRow(botGroup, "Reply", "e.g. ;bring [Username]", function(t) botReply=t end)

    -- Bot reply listener
    TextChatService.OnIncomingMessage = function(mdata)
        if not botReplyOn or botTrigger=="" or botReply=="" then return end
        local plr = mdata.TextSource and mdata.TextSource.UserId and Players:GetPlayerByUserId(mdata.TextSource.UserId)
        if not plr or plr==lp then return end
        local msg = mdata.Text or ""
        local trigger = botCaseSensitive and botTrigger or botTrigger:lower()
        local msgCheck = botCaseSensitive and msg or msg:lower()
        if msgCheck:find(trigger, 1, true) then
            local reply = botReply:gsub("%[Username%]", plr.Name):gsub("%[Display%]", plr.DisplayName)
            task.spawn(function() sendChat(reply) end)
        end
    end

    local bkitTCOGroup = makeGroup(tcoPage, "BKit (TCO)")

    makeToggleRow(bkitTCOGroup, "Enlighten Log", function(on)
        enlightenLogEnabled = on
        if on then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= lp and p.Character then
                    p.Character.ChildAdded:Connect(function(item)
                        if item.Name=="The Arkenstone" and enlightenLogEnabled then
                            sendChat("[*] "..p.DisplayName.." received enlighten")
                        end
                    end)
                end
            end
        end
    end)

    local tcoMiscGroup = makeGroup(tcoPage, "TCO Misc")

    -- Noclip Bypass
    local nnConn = nil
    makeToggleRow(tcoMiscGroup, "Noclip Bypass", function(on)
        nnoclipEnabled = on
        if on then
            nnConn = RunService.RenderStepped:Connect(function()
                local char=lp.Character; if not char then return end
                local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
                local rp=RaycastParams.new(); rp.FilterType=Enum.RaycastFilterType.Exclude; rp.FilterDescendantsInstances={char}
                local hit=Workspace:Raycast(hrp.Position,Vector3.new(0,-6,0),rp)
                if hit then
                    local surfY=hit.Position.Y+2.1
                    if hrp.Position.Y<surfY then
                        local vel=hrp.AssemblyLinearVelocity
                        hrp.AssemblyLinearVelocity=Vector3.new(vel.X,0,vel.Z)
                        hrp.CFrame=CFrame.new(Vector3.new(hrp.Position.X,surfY,hrp.Position.Z))*CFrame.fromMatrix(Vector3.new(),hrp.CFrame.RightVector,hrp.CFrame.UpVector)
                    end
                end
            end)
        else
            if nnConn then nnConn:Disconnect(); nnConn=nil end
        end
    end)
end


do
    local iqGroup = makeGroup(tcoPage, "IQ Tag in Chat")
    makeToggleRow(iqGroup, "Show IQ Tags", function(on)
        shared._iqTagEnabled = on
    end)
end

-- ─────────────────────────────────────────────────────────────
-- TAB: TARGET
-- ─────────────────────────────────────────────────────────────
local targetPage = createTab("Target", 8)

do
    local selGroup = makeGroup(targetPage, "Select Player")
    local tDropSetter
    local _, tSetter = makeDropdownRow(selGroup, "Target", getPlayerNames(), nil, function(val)
        selectedTarget = Players:FindFirstChild(val)
    end)
    tDropSetter = tSetter

    makeButtonRow(selGroup, "Refresh List", function()
        local n = getPlayerNames()
        tDropSetter(n, n[1])
        selectedTarget = Players:FindFirstChild(n[1])
    end)

    local offGroup = makeGroup(targetPage, "Offensive")
    makeToggleRow(offGroup, "Delcubes Player", function(on) targetDelcubes = on end)

    local movGroup2 = makeGroup(targetPage, "Movement")
    makeToggleRow(movGroup2, "Click TP", function(on) clickTPEnabled = on end)

    makeButtonRow(movGroup2, "Teleport to Target", function()
        if selectedTarget and selectedTarget.Character and selectedTarget.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.CFrame = selectedTarget.Character.HumanoidRootPart.CFrame * CFrame.new(0,5,0) end
        end
    end)
end

-- ─────────────────────────────────────────────────────────────
-- TAB: SCRIPTS
-- ─────────────────────────────────────────────────────────────
local scriptsPage = createTab("Scripts", 9)

do
    local SCRIPTS = {
        { name="Infinite Yield",    url="https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"                                                      },
        { name="Simple Spy V3",     url="https://raw.githubusercontent.com/infyiff/backup/main/SimpleSpyV3/main.lua"                                               },
        { name="Fling GUI (bedw)",  url="https://rawscripts.net/raw/Universal-Script-Fling-gui-42897"                                                              },
        { name="Extra Stuff",       url="https://raw.githubusercontent.com/s0lmain/Scripts/refs/heads/main/ExtraStuff.txt"                                         },
        { name="ZTE Hub",           url="https://raw.githubusercontent.com/khanh-lol/Ztehub/refs/heads/main/ztebeta"                                               },
        { name="VPLI Hub",          url="https://raw.githubusercontent.com/Adam3mka/The-chosen-one-lukaku/refs/heads/main/Protected_6361979247750901.txt"           },
        { name="Annoyance Hub",     url="https://raw.githubusercontent.com/s0lmain/Scripts/refs/heads/main/Annoyance.txt"                                           },
        { name="Emote Wheel",       url="https://raw.githubusercontent.com/7yd7/Hub/refs/heads/Branch/GUIS/Emotes.lua"                                             },
    }

    local sg = makeGroup(scriptsPage, "Hub Scripts")
    for _, s in ipairs(SCRIPTS) do
        local name = s.name
        local url  = s.url
        makeButtonRow(sg, name, function(btn)
            btn.Text = "Loading..."
            task.spawn(function()
                local ok,err = pcall(function() loadstring(game:HttpGet(url))() end)
                btn.Text = ok and "Executed!" or "Failed"
                task.wait(3); btn.Text = name
            end)
        end)
    end
end

-- ─────────────────────────────────────────────────────────────
-- TAB: SETTINGS
-- ─────────────────────────────────────────────────────────────
local settingsPage = createTab("Settings", 10)

do
    local infoGroup = makeGroup(settingsPage, "Info & Keybinds")
    local info = Instance.new("TextLabel")
    info.Size=UDim2.new(1,0,0,0); info.AutomaticSize=Enum.AutomaticSize.Y
    info.BackgroundTransparency=1; info.TextWrapped=true
    info.Text="Σ Bubble = open/close panel\nClose (×) = hide panel\nDrag topbar = move GUI\n\nSigma Panel – merged from:\n  sigma.txt + DevX2 + ¥harrz v2"
    info.TextColor3=C_WHITE; info.FontFace=FONT_MAIN; info.TextSize=11
    info.TextXAlignment=Enum.TextXAlignment.Left; info.ZIndex=8; info.Parent=infoGroup

    local verLbl = Instance.new("TextLabel")
    verLbl.Size=UDim2.new(1,0,0,14); verLbl.BackgroundTransparency=1
    verLbl.Text="v3.0 Combined  |  by agarv/stik/yharzz"
    verLbl.TextColor3=Color3.fromRGB(120,120,120); verLbl.FontFace=FONT_MAIN; verLbl.TextSize=10
    verLbl.TextXAlignment=Enum.TextXAlignment.Left; verLbl.ZIndex=8; verLbl.Parent=infoGroup
end


-- ─────────────────────────────────────────────────────────────
-- TEMPORAL FEATURES: unified click handler + runtime loops
-- ─────────────────────────────────────────────────────────────

-- ONE InputBegan connection handles block selector, boombox, spray paint, DCA
UserInputService.InputBegan:Connect(function(input, processed)
    if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
    local mouse = lp:GetMouse()

    -- Block selector
    if not processed and selectedBlockMode then
        if mouse.Target and mouse.Target:IsA("BasePart") then
            selectedBlock = mouse.Target
            notify("Panel", "Selected: " .. mouse.Target.Name)
        end
        selectedBlockMode = false
        return
    end

    -- Boombox detector
    if not processed and mouse.Target then
        local par = mouse.Target.Parent
        if par and _tempBbNames[par.Name] then
            local sound = par:FindFirstChild("Sound", true)
            if sound and sound.SoundId and sound.SoundId ~= "" then
                _tempBbId = sound.SoundId:match("id=(%d+)") or sound.SoundId
                if shared._bbLbl then shared._bbLbl.Text = "Boombox ID: " .. _tempBbId end
            else
                _tempBbId = ""
                if shared._bbLbl then shared._bbLbl.Text = "Boombox: no sound" end
            end
        end
    end

    -- Spray paint
    if not processed and sprayPaintEnabled and _overlapSupported then
        local hitPos = mouse.Hit.Position
        local ev = equipAndGetEvent("Paint")
        if ev then
            _sprayOverlapParams.FilterDescendantsInstances = { Workspace.Terrain, lp.Character }
            local parts = Workspace:GetPartBoundsInBox(CFrame.new(hitPos), Vector3.new(4,4,4), _sprayOverlapParams)
            local col = Color3.fromHSV(rainbowSkyH, 1, 1)
            for _, part in ipairs(parts) do
                if part:IsA("BasePart") then
                    pcall(function()
                        ev:FireServer(part, Enum.NormalId.Top, hitPos, HANDSHAKE, col, "spray", sprayPaintText)
                    end)
                end
            end
        end
    end

    -- Delete Click Aura: record click position
    if not processed and deleteClickAura then
        local char = lp.Character
        if char then _dcaRayParams.FilterDescendantsInstances = { char } end
        local camCF = Workspace.CurrentCamera.CFrame
        local res = Workspace:Raycast(camCF.Position, (mouse.Hit.Position - camCF.Position).Unit * 1000, _dcaRayParams)
        if res then _dcaPos = res.Position end
    end
end)

-- Rainbow Sky loop
task.spawn(function()
    while true do
        task.wait(0.05)
        if not rainbowSkyEnabled then continue end
        rainbowSkyH = (rainbowSkyH + 0.005) % 1
        local col = Color3.fromHSV(rainbowSkyH, 1, 1)
        local ev = equipAndGetEvent("Paint")
        if ev then
            pcall(function()
                ev:FireServer(Workspace.Terrain, Enum.NormalId.Top,
                    Vector3.new(9468, 3084, 707), HANDSHAKE, col, "neon", "")
            end)
        end
    end
end)

-- Delete Click Aura loop
task.spawn(function()
    local _dcaOverlap = nil
    pcall(function()
        _dcaOverlap = OverlapParams.new()
        _dcaOverlap.FilterType = Enum.RaycastFilterType.Exclude
    end)
    while true do
        task.wait(0.1)
        if not deleteClickAura or not _dcaPos then continue end
        if not _dcaBox or not _dcaBox.Parent then
            _dcaBox = Instance.new("Part")
            _dcaBox.Name = "DeleteClickAura"
            _dcaBox.Size = Vector3.new(20,20,20)
            _dcaBox.Anchored = true
            _dcaBox.CanCollide = false
            _dcaBox.Transparency = 0.65
            _dcaBox.Color = Color3.fromRGB(255,0,0)
            _dcaBox.Material = Enum.Material.Neon
            _dcaBox.Parent = Workspace
        end
        _dcaBox.CFrame = CFrame.new(_dcaPos)
        local char = lp.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local delEv = equipAndGetEvent("Delete")
        if delEv and hrp and _dcaOverlap then
            _dcaOverlap.FilterDescendantsInstances = { _dcaBox, char }
            local parts = Workspace:GetPartBoundsInBox(_dcaBox.CFrame, _dcaBox.Size, _dcaOverlap)
            local brickFolder = Workspace:FindFirstChild("Bricks")
            for _, part in ipairs(parts) do
                if part:IsA("BasePart") and part ~= _dcaBox then
                    if not brickFolder or part:IsDescendantOf(brickFolder) then
                        pcall(function() delEv:FireServer(part, hrp.Position) end)
                    end
                end
            end
        end
    end
end)

-- Enlightened / Invisible ESP loop
task.spawn(function()
    while true do
        task.wait(0.5)
        if not showEnlightens and not showInvis then continue end
        for _, p in pairs(Players:GetPlayers()) do
            if p == lp or not p.Character then continue end
            local char = p.Character
            if showEnlightens then
                local hasArken = (p.Backpack and p.Backpack:FindFirstChild("The Arkenstone"))
                              or char:FindFirstChild("The Arkenstone")
                if hasArken then
                    if not char:FindFirstChild("enlightenHighlight") then
                        local h = Instance.new("Highlight")
                        h.Name = "enlightenHighlight"
                        h.FillColor = Color3.fromRGB(0,187,255)
                        h.FillTransparency = 0.5
                        h.OutlineColor = Color3.fromRGB(0,220,255)
                        h.OutlineTransparency = 0
                        h.Parent = char
                    end
                else
                    local h = char:FindFirstChild("enlightenHighlight")
                    if h then h:Destroy() end
                end
            end
            if showInvis then
                local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
                local isInvis = torso and torso.Transparency >= 0.9
                local existing = char:FindFirstChild("invisAlert")
                if isInvis and not existing then
                    local bb = Instance.new("BillboardGui")
                    bb.Name = "invisAlert"
                    bb.Size = UDim2.new(0,220,0,40)
                    bb.AlwaysOnTop = true
                    bb.StudsOffset = Vector3.new(0,3,0)
                    bb.Adornee = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
                    bb.Parent = char
                    local lbl2 = Instance.new("TextLabel")
                    lbl2.Size = UDim2.new(1,0,1,0)
                    lbl2.BackgroundTransparency = 1
                    lbl2.Text = "[INVIS] " .. p.Name
                    lbl2.TextColor3 = Color3.fromRGB(255,50,0)
                    lbl2.TextScaled = true
                    lbl2.FontFace = FONT_MAIN
                    lbl2.Parent = bb
                elseif not isInvis and existing then
                    existing:Destroy()
                end
            end
        end
    end
end)

-- ─────────────────────────────────────────────────────────────
-- RUNTIME LOOPS
-- ─────────────────────────────────────────────────────────────

-- Anti loops (DevX2/¥harrz)
RunService.RenderStepped:Connect(function()
    local char = lp.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")

    -- Anti Glitch (safe position tracking)
    if hrp then
        if antiGlitch and lastSafePosition then
            if (hrp.Position - lastSafePosition).Magnitude > 1000 then
                hrp.Velocity = Vector3.zero
                hrp.CFrame   = CFrame.new(lastSafePosition)
            end
        end
        if hrp.Position.Y > -50 and hrp.Position.Y < 5000 then
            lastSafePosition = hrp.Position
        end
    end

    -- Anti Blind
    if antiBlind then
        local b = lp.PlayerGui:FindFirstChild("Blind")
        if b then
            b.Enabled = false
            for _, v in ipairs(b:GetDescendants()) do
                if v:IsA("Frame") or v:IsA("ImageLabel") then v.Visible = false end
            end
        end
    end

    -- Anti Myopic
    if antiMyopic then
        local blur = Lighting:FindFirstChildOfClass("BlurEffect")
        if blur then blur.Enabled = false; blur.Size = 0 end
    end

    -- Auto Fix Cam
    if autoFixCam then
        local cam = Workspace.CurrentCamera
        if cam.CameraType ~= Enum.CameraType.Custom then cam.CameraType = Enum.CameraType.Custom end
    end

    -- Anti Fog
    local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
    if antiFog and atmosphere then atmosphere.Density = 0 end

    -- Anim Speed continuous
    if animSpeedEnabled and char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            for _, t in pairs(hum:GetPlayingAnimationTracks()) do t:AdjustSpeed(animSpeedValue) end
        end
    end
end)

-- Home auras loop (task.spawn, non-blocking)
-- Raycast params that exclude the local character so tools hit actual bricks
local _homeRayParams = RaycastParams.new()
_homeRayParams.FilterType = Enum.RaycastFilterType.Exclude

task.spawn(function()
    while true do
        task.wait(0)
        local char = lp.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then task.wait(0.05) continue end

        -- Idle guard: skip all heavy work if no home aura feature is active
        if not rainbow and not shovel and not deleteAura and not killAura and not detailedPath then
            task.wait(0.05) continue
        end

        -- Keep char excluded up-to-date each frame
        _homeRayParams.FilterDescendantsInstances = {char}

        rainbowH = (rainbowH + RainbowSpeed) % 1
        local col      = Color3.fromHSV(rainbowH, 1, 1)
        -- Raycast from camera through mouse to find the actual hovered part
        local mouse    = lp:GetMouse()
        local mouseHit = mouse.Hit.Position
        local unitRay  = Workspace.CurrentCamera:ScreenPointToRay(mouse.X, mouse.Y)
        local rayResult = Workspace:Raycast(unitRay.Origin, unitRay.Direction * 2000, _homeRayParams)
        local hoveredPart = rayResult and rayResult.Instance  -- nil if pointing at sky
        local hoveredPos  = rayResult and rayResult.Position or mouseHit

        if rainbow then
            -- Paint the hovered brick; force-equip Paint first
            local ev = equipAndGetEvent("Paint")
            if ev then
                local target = (hoveredPart and hoveredPart:IsA("BasePart") and hoveredPart.Name ~= "Terrain")
                    and hoveredPart or Workspace.Terrain
                ev:FireServer(target, Enum.NormalId.Top, hoveredPos, HANDSHAKE, col, currentMaterial, "")
            end
        end

        if shovel then
            -- Cache the shovel event; re-acquire only if it went missing
            if not _cachedShovelEv or not _cachedShovelEv.Parent then
                _cachedShovelEv = equipAndGetEvent("Shovel")
            end
            if _cachedShovelEv then
                local target = hoveredPart or Workspace.Terrain
                _cachedShovelEv:FireServer(target, Enum.NormalId.Top, hoveredPos, "dig")
            end
        else
            _cachedShovelEv = nil
        end

        if deleteAura then
            local ev = equipAndGetEvent("Delete")
            if ev and hoveredPart and hoveredPart:IsA("BasePart") then
                ev:FireServer(hoveredPart, hrp.Position)
            end
        end

        if killAura then
            -- Kill aura needs both Build and Paint; equip both and retrieve events
            local buildEv = equipAndGetEvent("Build")
            local paintEv = equipAndGetEvent("Paint")
            local tPart, dist = nil, 20
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local d = (p.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
                    if d < dist then tPart = p.Character.HumanoidRootPart; dist = d end
                end
            end
            if tPart and buildEv and paintEv then
                buildEv:FireServer(Workspace.Terrain, Enum.NormalId.Top, tPart.Position, "detailed")
                paintEv:FireServer(Workspace.Terrain, Enum.NormalId.Top, tPart.Position, HANDSHAKE, Color3.new(0,0,0), "toxic", "")
            end
        end

        if detailedPath then
            local now = tick()
            if not _trailLastT or (now - _trailLastT) >= 0.08 then
                _trailLastT = now
                -- Strip "rainbow " prefix to get the raw block type for Build tool
                local pType = currentBlockPathType:gsub("^rainbow ", "")
                -- Map friendly names to Build tool arguments
                if pType == "detailed" then pType = "detailed"
                elseif pType == "normal" then pType = "normal"
                end
                local buildEv = equipAndGetEvent("Build")
                if buildEv then
                    buildEv:FireServer(Workspace.Terrain, Enum.NormalId.Top, hrp.Position, pType)
                end
                -- Rainbow trail also paints the placed block
                if currentBlockPathType:find("rainbow") then
                    local paintEv = equipAndGetEvent("Paint")
                    if paintEv then
                        paintEv:FireServer(Workspace.Terrain, Enum.NormalId.Top, hrp.Position, HANDSHAKE, col, currentMaterial, "")
                    end
                end
            end
        else
            _trailLastT = nil
        end
    end
end)

-- Advanced auras loop – sequential tool cycle to prevent equip conflicts
task.spawn(function()
    while true do
        task.wait(0)
        local char = lp.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then task.wait(0.05) continue end

        -- Idle guard: skip all heavy work if no advanced aura feature is active
        if not buildAura and not signAura and not paintAura and not deleteAuraAdv then
            task.wait(0.05) continue
        end

        auraH = (auraH + auraRainbowSpeed) % 1
        local col = Color3.fromHSV(auraH, 1, 1)
        local now = tick()

        -- Build aura step
        if buildAura and (now - _buildAuraT) >= buildAuraSpeed then
            _buildAuraT = now
            local ev = equipAndGetEvent("Build")
            if ev then ev:FireServer(Workspace.Terrain, Enum.NormalId.Top, getPositionAround(hrp,3,15), "normal") end
            task.wait(0)
        end

        -- Sign aura step
        if signAura and (now - _signAuraT) >= signAuraSpeed then
            _signAuraT = now
            local ev = equipAndGetEvent("Sign")
            if ev then ev:FireServer(Workspace.Terrain, Enum.NormalId.Top, getPositionAround(hrp,3,15), "normal") end
            task.wait(0)
        end

        -- Paint (rainbow) aura step
        if paintAura and (now - _paintAuraT) >= paintAuraSpeed then
            _paintAuraT = now
            local ev  = equipAndGetEvent("Paint")
            local blk = getNearestPart(PaintAuraRange)
            if ev and blk then ev:FireServer(blk, Enum.NormalId.Top, hrp.Position, HANDSHAKE, col, "plastic", "") end
            task.wait(0)
        end

        -- Delete aura step
        if deleteAuraAdv and (now - _deleteAuraT) >= deleteAuraSpeed then
            _deleteAuraT = now
            local ev  = equipAndGetEvent("Delete")
            local blk = getNearestPart(DeleteAuraRange)
            if ev and blk then ev:FireServer(blk, hrp.Position) end
            task.wait(0)
        end
    end
end)

-- Target delcubes loop
task.spawn(function()
    while task.wait(0.5) do
        if targetDelcubes and selectedTarget then
            local bFolder = Workspace:FindFirstChild("Bricks")
            local tBricks = bFolder and bFolder:FindFirstChild(selectedTarget.Name)
            if tBricks and #tBricks:GetChildren() > 0 then
                local tool = forceEquip("Delete")
                local ev   = tool and tool:FindFirstChild("Event", true)
                if ev then
                    for _, cube in ipairs(tBricks:GetChildren()) do
                        if not targetDelcubes then break end
                        local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then ev:FireServer(cube, hrp.Position) end
                        task.wait(0.02)
                    end
                end
            end
        end
    end
end)

-- ESP render loop
RunService.RenderStepped:Connect(function()
    if not espEnabled then return end
    local myChar = lp.Character
    local myHRP  = myChar and myChar:FindFirstChild("HumanoidRootPart")
    for plr, data in pairs(espGuis) do
        if data and data.bb and data.lbl then
            local tChar = plr.Character
            local tHRP  = tChar and tChar:FindFirstChild("HumanoidRootPart")
            if myHRP and tHRP then
                local dist = (myHRP.Position - tHRP.Position).Magnitude
                data.bb.Enabled = dist <= espMaxDist
                local name = espUseDisplay and plr.DisplayName or plr.Name
                if espDistEnabled then
                    data.lbl.Text = name .. " | " .. math.floor(dist)
                else
                    data.lbl.Text = name
                end
            end
        end
    end
end)

-- Click TP – PC (MouseButton1) + Mobile (TouchTap)
local _clickTPParams = RaycastParams.new()
_clickTPParams.FilterType = Enum.RaycastFilterType.Exclude

local function doClickTP(screenPos)
    local char = lp.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    _clickTPParams.FilterDescendantsInstances = {char}
    local ray = Workspace.CurrentCamera:ScreenPointToRay(screenPos.X, screenPos.Y)
    local res = Workspace:Raycast(ray.Origin, ray.Direction * 2000, _clickTPParams)
    if res then hrp.CFrame = CFrame.new(res.Position + Vector3.new(0, 3, 0)) end
end

UserInputService.InputBegan:Connect(function(input, processed)
    if processed or not clickTPEnabled then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        doClickTP(UserInputService:GetMouseLocation())
    end
end)

UserInputService.TouchTapInWorld:Connect(function(touchPos, processed)
    if processed or not clickTPEnabled then return end
    doClickTP(touchPos)
end)

-- CharacterAdded handler
lp.CharacterAdded:Connect(function(char)
    -- Re-apply movement on respawn
    if autoFixCam then task.wait(0.5); fixPlayerState() end

    char.ChildAdded:Connect(function(inst)
        if inst.Name=="Hielo" and antiFreeze then
            inst:Destroy()  -- remove the freeze object immediately
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.Health = 0  -- oof / respawn
            end
        elseif inst.Name=="Jail" and antiJail then
            task.wait(0.1); removeCollision(inst)
        end
    end)

    task.wait(0.2)

    -- Re-apply WalkSpeed
    if wsEnabled then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = wsInfinite and math.huge or wsValue end
    end

    -- Re-apply JumpPower
    if jpEnabled then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.UseJumpPower=true; hum.JumpPower = jpInfinite and math.huge or jpValue end
    end

    -- Re-apply GodMode
    if godModeEnabled then
        for _, c in pairs(godConnections) do if c then c:Disconnect() end end
        godConnections = {}
        local hum = char:WaitForChild("Humanoid")
        hum.MaxHealth=math.huge; hum.Health=math.huge
        table.insert(godConnections, RunService.RenderStepped:Connect(function()
            if not godModeEnabled or shared.GodModePaused then return end
            if hum and hum.Parent then hum.MaxHealth=math.huge; hum.Health=math.huge end
        end))
    end

    -- Re-apply ESP
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= lp and espNameEnabled then
            local function makeEsp(pp)
                local c2 = pp.Character; if not c2 then return end
                local h2 = c2:FindFirstChild("Head"); if not h2 then return end
                if espGuis[pp] and espGuis[pp].bb then espGuis[pp].bb:Destroy() end
                local bb=Instance.new("BillboardGui"); bb.Name="ESPNameGui_"..pp.Name
                bb.Size=UDim2.new(0,200,0,30); bb.StudsOffset=Vector3.new(0,3,0)
                bb.Adornee=h2; bb.AlwaysOnTop=true; bb.Enabled=espEnabled; bb.Parent=h2
                local lbl=Instance.new("TextLabel"); lbl.Size=UDim2.new(1,0,1,0)
                lbl.BackgroundTransparency=1; lbl.TextColor3=Color3.fromRGB(255,255,255)
                lbl.TextStrokeTransparency=0; lbl.TextSize=13; lbl.FontFace=FONT_MAIN
                lbl.Text=espUseDisplay and pp.DisplayName or pp.Name; lbl.Parent=bb
                espGuis[pp]={bb=bb,lbl=lbl}
            end
            makeEsp(p)
        end
    end
end)

-- New players joining → attach ESP
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        task.wait(0.5)
        if (espNameEnabled or espDistEnabled) and p ~= lp then
            local char = p.Character; if not char then return end
            local head = char:FindFirstChild("Head"); if not head then return end
            if espGuis[p] and espGuis[p].bb then espGuis[p].bb:Destroy() end
            local bb=Instance.new("BillboardGui"); bb.Size=UDim2.new(0,200,0,30)
            bb.StudsOffset=Vector3.new(0,3,0); bb.Adornee=head; bb.AlwaysOnTop=true
            bb.Enabled=espEnabled; bb.Parent=head
            local lbl=Instance.new("TextLabel"); lbl.Size=UDim2.new(1,0,1,0)
            lbl.BackgroundTransparency=1; lbl.TextColor3=Color3.fromRGB(255,255,255)
            lbl.TextStrokeTransparency=0; lbl.TextSize=13; lbl.FontFace=FONT_MAIN
            lbl.Text=espUseDisplay and p.DisplayName or p.Name; lbl.Parent=bb
            espGuis[p]={bb=bb,lbl=lbl}
        end
    end)
end)

Players.PlayerRemoving:Connect(function(p)
    if espGuis[p] and espGuis[p].bb then espGuis[p].bb:Destroy() end
    espGuis[p] = nil
end)

-- ─────────────────────────────────────────────────────────────
-- GUI TOGGLE / DRAG / MINIMIZE LOGIC
-- ─────────────────────────────────────────────────────────────

-- Dragging
local dragging = false
local dragStart, startPos = nil, nil

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging  = true
        dragStart = input.Position
        startPos  = MainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not dragging then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- Bubble drag
local bubHolding  = false
local bubMoved    = false
local bubStart, bubStartPos = nil, nil

bubble.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        bubHolding = true
        bubMoved   = false
        bubStart   = input.Position
        bubStartPos = bubble.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not bubHolding then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - bubStart
        if delta.Magnitude > 6 then
            bubMoved = true
            bubble.Position = UDim2.new(bubStartPos.X.Scale, bubStartPos.X.Offset + delta.X, bubStartPos.Y.Scale, bubStartPos.Y.Offset + delta.Y)
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        bubHolding = false
    end
end)

-- Bubble click: toggle panel (only fires when not dragged)
bubble.MouseButton1Click:Connect(function()
    if bubMoved then bubMoved = false; return end
    guiVisible        = not guiVisible
    MainFrame.Visible = guiVisible
    if guiVisible then setActiveTab("Main") end
end)

-- Close button
CloseBtn.MouseButton1Click:Connect(function()
    guiVisible = false
    MainFrame.Visible = false
end)

-- Minimize button
local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    SideBar.Visible     = not minimized
    ContentArea.Visible = not minimized
    MinBtn.Text = minimized and "+" or "-"
    MainFrame.Size = minimized and UDim2.new(0,500,0,26) or UDim2.new(0,500,0,340)
end)

-- ─────────────────────────────────────────────────────────────
-- INIT
-- ─────────────────────────────────────────────────────────────
setActiveTab("Main")
notify("Sigma Panel", "Loaded! Tap Σ bubble to open.")
