
local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LP   = Players.LocalPlayer
local PGui = LP:WaitForChild("PlayerGui")

-- ══════════════════════════════════════════
--  CẤU HÌNH ẢNH NÚT TOGGLE
--  Thay ID số vào đây
-- ══════════════════════════════════════════
-- ToggleBtn.Image = rbxassetid://
local IMAGE_OPEN  = "rbxassetid://0"   -- ảnh khi UI đang bật
-- ToggleBtn.Image = rbxassetid://
local IMAGE_CLOSE = "rbxassetid://0"   -- ảnh khi UI đang tắt

-- ══════════════════════════════════════════
--  SCREEN GUI
-- ══════════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name           = "BananaCatHub"
ScreenGui.ResetOnSpawn   = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent         = PGui

-- ══════════════════════════════════════════
--  NÚT TOGGLE TRÒN TRẮNG (không viền)
-- ══════════════════════════════════════════
local ToggleBtn = Instance.new("ImageButton")
ToggleBtn.Name             = "ToggleBtn"
ToggleBtn.Size             = UDim2.new(0, 48, 0, 48)
ToggleBtn.Position         = UDim2.new(0, 16, 0.5, -24)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.BorderSizePixel  = 0
ToggleBtn.Image            = IMAGE_OPEN
ToggleBtn.ZIndex           = 20
ToggleBtn.Parent           = ScreenGui

local TCorner = Instance.new("UICorner")
TCorner.CornerRadius = UDim.new(1, 0)
TCorner.Parent = ToggleBtn

-- Icon mặc định nếu không có ảnh
local TIcon = Instance.new("TextLabel")
TIcon.Size               = UDim2.new(1, 0, 1, 0)
TIcon.BackgroundTransparency = 1
TIcon.Text               = IMAGE_OPEN == "rbxassetid://0" and "☰" or ""
TIcon.TextColor3         = Color3.fromRGB(30, 30, 40)
TIcon.TextSize           = 22
TIcon.Font               = Enum.Font.GothamBold
TIcon.ZIndex             = 21
TIcon.Parent             = ToggleBtn

-- ══════════════════════════════════════════
--  MAIN WINDOW
-- ══════════════════════════════════════════
local WIN_W, WIN_H = 760, 490

local Main = Instance.new("Frame")
Main.Name             = "Main"
Main.Size             = UDim2.new(0, WIN_W, 0, WIN_H)
Main.Position         = UDim2.new(0.5, -WIN_W/2, 0.5, -WIN_H/2)
Main.BackgroundColor3 = Color3.fromRGB(16, 16, 24)
Main.BorderSizePixel  = 0
Main.ClipsDescendants = true
Main.Parent           = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color     = Color3.fromRGB(38, 38, 60)
MainStroke.Thickness = 1.5
MainStroke.Parent    = Main

-- ══════════════════════════════════════════
--  TITLE BAR
-- ══════════════════════════════════════════
local TitleBar = Instance.new("Frame")
TitleBar.Size             = UDim2.new(1, 0, 0, 44)
TitleBar.BackgroundColor3 = Color3.fromRGB(12, 12, 20)
TitleBar.BorderSizePixel  = 0
TitleBar.Parent           = Main

local TLine = Instance.new("Frame")
TLine.Size             = UDim2.new(1, 0, 0, 1)
TLine.Position         = UDim2.new(0, 0, 1, -1)
TLine.BackgroundColor3 = Color3.fromRGB(38, 38, 60)
TLine.BorderSizePixel  = 0
TLine.Parent           = TitleBar

local TitleLbl = Instance.new("TextLabel")
TitleLbl.Size               = UDim2.new(1, 0, 1, 0)
TitleLbl.BackgroundTransparency = 1
TitleLbl.RichText           = true
TitleLbl.Text               = '<font color="#F5C542"><b>Water Cat Hub</b></font>  <font color="#888899">- Blox Fruit</font>'
TitleLbl.TextSize           = 15
TitleLbl.Font               = Enum.Font.Gotham
TitleLbl.TextXAlignment     = Enum.TextXAlignment.Center
TitleLbl.Parent             = TitleBar

local Badge = Instance.new("Frame")
Badge.Size             = UDim2.new(0, 56, 0, 24)
Badge.Position         = UDim2.new(1, -66, 0.5, -12)
Badge.BackgroundColor3 = Color3.fromRGB(25, 22, 6)
Badge.BorderSizePixel  = 0
Badge.Parent           = TitleBar
local BadgeC = Instance.new("UICorner"); BadgeC.CornerRadius = UDim.new(1,0); BadgeC.Parent = Badge
local BadgeS = Instance.new("UIStroke"); BadgeS.Color = Color3.fromRGB(160,120,20); BadgeS.Thickness = 1; BadgeS.Parent = Badge
local BadgeTxt = Instance.new("TextLabel")
BadgeTxt.Size               = UDim2.new(1,0,1,0)
BadgeTxt.BackgroundTransparency = 1
BadgeTxt.Text               = "4471"
BadgeTxt.TextColor3         = Color3.fromRGB(245,197,66)
BadgeTxt.TextSize           = 12
BadgeTxt.Font               = Enum.Font.GothamBold
BadgeTxt.Parent             = Badge

-- ══════════════════════════════════════════
--  BODY
-- ══════════════════════════════════════════
local Body = Instance.new("Frame")
Body.Size               = UDim2.new(1, 0, 1, -44)
Body.Position           = UDim2.new(0, 0, 0, 44)
Body.BackgroundTransparency = 1
Body.Parent             = Main

-- ──────────────────────────────────────────
--  SIDEBAR
-- ──────────────────────────────────────────
local Sidebar = Instance.new("Frame")
Sidebar.Size             = UDim2.new(0, 195, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(11, 11, 17)
Sidebar.BorderSizePixel  = 0
Sidebar.Parent           = Body

local SLine = Instance.new("Frame")
SLine.Size             = UDim2.new(0, 1, 1, 0)
SLine.Position         = UDim2.new(1, -1, 0, 0)
SLine.BackgroundColor3 = Color3.fromRGB(38, 38, 60)
SLine.BorderSizePixel  = 0
SLine.Parent           = Sidebar

-- Search box
local SearchWrap = Instance.new("Frame")
SearchWrap.Size             = UDim2.new(1, -14, 0, 34)
SearchWrap.Position         = UDim2.new(0, 7, 0, 7)
SearchWrap.BackgroundColor3 = Color3.fromRGB(22, 22, 34)
SearchWrap.BorderSizePixel  = 0
SearchWrap.Parent           = Sidebar
local SWC = Instance.new("UICorner"); SWC.CornerRadius = UDim.new(0,7); SWC.Parent = SearchWrap
local SWS = Instance.new("UIStroke"); SWS.Color = Color3.fromRGB(38,38,60); SWS.Thickness = 1; SWS.Parent = SearchWrap

local SearchLabel = Instance.new("TextLabel")
SearchLabel.Size               = UDim2.new(0, 22, 1, 0)
SearchLabel.Position           = UDim2.new(0, 7, 0, 0)
SearchLabel.BackgroundTransparency = 1
SearchLabel.Text               = "🔍"
SearchLabel.TextSize           = 13
SearchLabel.Font               = Enum.Font.Gotham
SearchLabel.Parent             = SearchWrap

local SearchBox = Instance.new("TextBox")
SearchBox.Size               = UDim2.new(1, -32, 1, 0)
SearchBox.Position           = UDim2.new(0, 28, 0, 0)
SearchBox.BackgroundTransparency = 1
SearchBox.PlaceholderText    = "Search section or Func"
SearchBox.PlaceholderColor3  = Color3.fromRGB(80, 80, 100)
SearchBox.Text               = ""
SearchBox.TextColor3         = Color3.fromRGB(200, 200, 220)
SearchBox.TextSize           = 12
SearchBox.Font               = Enum.Font.Gotham
SearchBox.ClearTextOnFocus   = false
SearchBox.BorderSizePixel    = 0
SearchBox.Parent             = SearchWrap

-- Nav scroll
local NavScroll = Instance.new("ScrollingFrame")
NavScroll.Size               = UDim2.new(1, 0, 1, -52)
NavScroll.Position           = UDim2.new(0, 0, 0, 52)
NavScroll.BackgroundTransparency = 1
NavScroll.BorderSizePixel    = 0
NavScroll.ScrollBarThickness = 2
NavScroll.ScrollBarImageColor3 = Color3.fromRGB(50,50,80)
NavScroll.CanvasSize         = UDim2.new(0,0,0,0)
NavScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
NavScroll.Parent             = Sidebar

local NavLayout = Instance.new("UIListLayout")
NavLayout.SortOrder = Enum.SortOrder.LayoutOrder
NavLayout.Parent    = NavScroll

-- ──────────────────────────────────────────
--  CONTENT
-- ──────────────────────────────────────────
local ContentPanel = Instance.new("Frame")
ContentPanel.Size               = UDim2.new(1, -195, 1, 0)
ContentPanel.Position           = UDim2.new(0, 195, 0, 0)
ContentPanel.BackgroundTransparency = 1
ContentPanel.Parent             = Body

local CHdr = Instance.new("Frame")
CHdr.Size               = UDim2.new(1, 0, 0, 40)
CHdr.BackgroundTransparency = 1
CHdr.Parent             = ContentPanel

local ContentTitle = Instance.new("TextLabel")
ContentTitle.Size               = UDim2.new(1, -50, 1, 0)
ContentTitle.Position           = UDim2.new(0, 14, 0, 0)
ContentTitle.BackgroundTransparency = 1
ContentTitle.Text               = "Farming Other"
ContentTitle.TextColor3         = Color3.fromRGB(240, 240, 255)
ContentTitle.TextSize           = 15
ContentTitle.Font               = Enum.Font.GothamBold
ContentTitle.TextXAlignment     = Enum.TextXAlignment.Left
ContentTitle.Parent             = CHdr

local CHLine = Instance.new("Frame")
CHLine.Size             = UDim2.new(1, 0, 0, 1)
CHLine.Position         = UDim2.new(0, 0, 1, -1)
CHLine.BackgroundColor3 = Color3.fromRGB(38, 38, 60)
CHLine.BorderSizePixel  = 0
CHLine.Parent           = CHdr

local CScroll = Instance.new("ScrollingFrame")
CScroll.Size               = UDim2.new(1, 0, 1, -40)
CScroll.Position           = UDim2.new(0, 0, 0, 40)
CScroll.BackgroundTransparency = 1
CScroll.BorderSizePixel    = 0
CScroll.ScrollBarThickness = 3
CScroll.ScrollBarImageColor3 = Color3.fromRGB(50,50,80)
CScroll.CanvasSize         = UDim2.new(0,0,0,0)
CScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
CScroll.Parent             = ContentPanel

local CLayout = Instance.new("UIListLayout")
CLayout.SortOrder = Enum.SortOrder.LayoutOrder
CLayout.Padding   = UDim.new(0, 0)
CLayout.Parent    = CScroll

local CPad = Instance.new("UIPadding")
CPad.PaddingLeft   = UDim.new(0, 0)
CPad.PaddingRight  = UDim.new(0, 0)
CPad.PaddingTop    = UDim.new(0, 0)
CPad.PaddingBottom = UDim.new(0, 8)
CPad.Parent        = CScroll

-- ══════════════════════════════════════════
--  HELPERS
-- ══════════════════════════════════════════
local rowOrder = 0
local function O() rowOrder += 1; return rowOrder end

local function MakeSection(title)
    local F = Instance.new("Frame")
    F.Size             = UDim2.new(1, 0, 0, 28)
    F.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    F.BorderSizePixel  = 0
    F.LayoutOrder      = O()
    F.Parent           = CScroll
    local L = Instance.new("TextLabel")
    L.Size               = UDim2.new(1,0,1,0)
    L.BackgroundTransparency = 1
    L.Text               = title
    L.TextColor3         = Color3.fromRGB(210,210,230)
    L.TextSize           = 13
    L.Font               = Enum.Font.GothamSemibold
    L.Parent             = F
    local Line = Instance.new("Frame")
    Line.Size             = UDim2.new(1,0,0,1)
    Line.Position         = UDim2.new(0,0,1,-1)
    Line.BackgroundColor3 = Color3.fromRGB(140,100,10)
    Line.BorderSizePixel  = 0
    Line.Parent           = F
end

-- Nút Click vàng → hiện OK xanh → reset
local function MakeClickRow(labelText, callback)
    local Row = Instance.new("Frame")
    Row.Size             = UDim2.new(1, 0, 0, 42)
    Row.BackgroundColor3 = Color3.fromRGB(18, 18, 27)
    Row.BorderSizePixel  = 0
    Row.LayoutOrder      = O()
    Row.Parent           = CScroll

    local BotLine = Instance.new("Frame")
    BotLine.Size             = UDim2.new(1,0,0,1)
    BotLine.Position         = UDim2.new(0,0,1,-1)
    BotLine.BackgroundColor3 = Color3.fromRGB(30,30,45)
    BotLine.BorderSizePixel  = 0
    BotLine.Parent           = Row

    local Lbl = Instance.new("TextLabel")
    Lbl.Size               = UDim2.new(1,-130,1,0)
    Lbl.Position           = UDim2.new(0,14,0,0)
    Lbl.BackgroundTransparency = 1
    Lbl.Text               = labelText
    Lbl.TextColor3         = Color3.fromRGB(230,230,245)
    Lbl.TextSize           = 13
    Lbl.Font               = Enum.Font.GothamBold
    Lbl.TextXAlignment     = Enum.TextXAlignment.Left
    Lbl.Parent             = Row

    local Btn = Instance.new("TextButton")
    Btn.Size             = UDim2.new(0, 96, 0, 30)
    Btn.Position         = UDim2.new(1, -108, 0.5, -15)
    Btn.BackgroundColor3 = Color3.fromRGB(170, 128, 22)
    Btn.Text             = "Click"
    Btn.TextColor3       = Color3.fromRGB(18, 13, 0)
    Btn.TextSize         = 13
    Btn.Font             = Enum.Font.GothamBold
    Btn.BorderSizePixel  = 0
    Btn.AutoButtonColor  = false
    Btn.Parent           = Row
    local BC = Instance.new("UICorner"); BC.CornerRadius = UDim.new(0,8); BC.Parent = Btn

    local busy = false
    Btn.MouseButton1Click:Connect(function()
        if busy then return end
        busy = true
        -- Hiện OK xanh
        Btn.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
        Btn.TextColor3       = Color3.fromRGB(255, 255, 255)
        Btn.Text             = "OK"
        if callback then
            task.spawn(callback)
        end
        task.wait(1.2)
        -- Reset
        Btn.BackgroundColor3 = Color3.fromRGB(170, 128, 22)
        Btn.TextColor3       = Color3.fromRGB(18, 13, 0)
        Btn.Text             = "Click"
        busy = false
    end)
end

-- ══════════════════════════════════════════
--  NAV TABS
-- ══════════════════════════════════════════
local TABS = {
    "Main",
    "Auto bounty",
    "hop sever",
    "kaitun v4",
    "kaitun levi",
    "kaitun",
    "Orther",
}

local activeNavBtn = nil
local function SetActive(btn, name)
    if activeNavBtn then
        activeNavBtn.BackgroundTransparency = 1
        activeNavBtn.TextColor3 = Color3.fromRGB(140,140,180)
        for _, c in ipairs(activeNavBtn:GetChildren()) do
            if c.Name == "LeftBar" then c:Destroy() end
        end
    end
    activeNavBtn = btn
    btn.BackgroundColor3      = Color3.fromRGB(245,197,66)
    btn.BackgroundTransparency = 0.9
    btn.TextColor3            = Color3.fromRGB(245,197,66)
    local Bar = Instance.new("Frame")
    Bar.Name             = "LeftBar"
    Bar.Size             = UDim2.new(0,3,1,0)
    Bar.BackgroundColor3 = Color3.fromRGB(245,197,66)
    Bar.BorderSizePixel  = 0
    Bar.Parent           = btn
    ContentTitle.Text = name
end

for i, name in ipairs(TABS) do
    local Btn = Instance.new("TextButton")
    Btn.Size               = UDim2.new(1,0,0,37)
    Btn.BackgroundTransparency = 1
    Btn.Text               = name
    Btn.TextColor3         = Color3.fromRGB(140,140,180)
    Btn.TextSize           = 13
    Btn.Font               = Enum.Font.GothamSemibold
    Btn.TextXAlignment     = Enum.TextXAlignment.Left
    Btn.LayoutOrder        = i
    Btn.ClipsDescendants   = true
    Btn.BorderSizePixel    = 0
    Btn.Parent             = NavScroll
    local NP = Instance.new("UIPadding"); NP.PaddingLeft = UDim.new(0,14); NP.Parent = Btn
    local NLine = Instance.new("Frame")
    NLine.Size             = UDim2.new(1,0,0,1)
    NLine.Position         = UDim2.new(0,0,1,-1)
    NLine.BackgroundColor3 = Color3.fromRGB(25,25,38)
    NLine.BorderSizePixel  = 0
    NLine.Parent           = Btn
    Btn.MouseButton1Click:Connect(function() SetActive(Btn, name) end)
    if name == "Farming Other" then SetActive(Btn, name) end
end

-- ══════════════════════════════════════════
--  CONTENT: EVENT EASTER
-- ══════════════════════════════════════════
MakeSection("Event Easter")

MakeClickRow("Mở cửa hàng lễ Phục sinh", function()
    -- TODO: thêm script mở shop tại đây
    print("[BananaCat] Mở shop Phục sinh")
end)

-- ══════════════════════════════════════════
--  CONTENT: EXECUTE SCRIPTS
-- ══════════════════════════════════════════
MakeSection("Execute Scripts")

MakeClickRow("Auto Farm Mastery", function()
    -- TODO: script auto farm mastery
    print("[BananaCat] Auto Farm Mastery")
end)

MakeClickRow("Kill Aura", function()
    -- TODO: script kill aura
    print("[BananaCat] Kill Aura")
end)

MakeClickRow("Auto Raid", function()
    -- TODO: script auto raid
    print("[BananaCat] Auto Raid")
end)

MakeClickRow("Teleport to Boss", function()
    -- TODO: script teleport boss
    print("[BananaCat] Teleport to Boss")
end)

MakeClickRow("Auto Chest Farm", function()
    -- TODO: script auto chest
    print("[BananaCat] Auto Chest Farm")
end)

-- ══════════════════════════════════════════
--  DRAG TITLEBAR
-- ══════════════════════════════════════════
local dragging, dragStart, frameStart, dragInput

TitleBar.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1
    or inp.UserInputType == Enum.UserInputType.Touch then
        dragging   = true
        dragStart  = inp.Position
        frameStart = Main.Position
        inp.Changed:Connect(function()
            if inp.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

TitleBar.InputChanged:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseMovement
    or inp.UserInputType == Enum.UserInputType.Touch then
        dragInput = inp
    end
end)

UserInputService.InputChanged:Connect(function(inp)
    if dragging and inp == dragInput then
        local d = inp.Position - dragStart
        Main.Position = UDim2.new(
            frameStart.X.Scale, frameStart.X.Offset + d.X,
            frameStart.Y.Scale, frameStart.Y.Offset + d.Y
        )
    end
end)

-- ══════════════════════════════════════════
--  TOGGLE NÚT TRÒN TRẮNG
-- ══════════════════════════════════════════
local guiOpen = true

local function UpdateToggleImage()
    if guiOpen then
        ToggleBtn.Image = IMAGE_OPEN
        TIcon.Text = IMAGE_OPEN == "rbxassetid://0" and "☰" or ""
    else
        ToggleBtn.Image = IMAGE_CLOSE
        TIcon.Text = IMAGE_CLOSE == "rbxassetid://0" and "▶" or ""
    end
end

ToggleBtn.MouseButton1Click:Connect(function()
    guiOpen = not guiOpen
    Main.Visible = guiOpen
    UpdateToggleImage()
end)

UpdateToggleImage()
print("✅ Banana Cat Hub loaded!")
