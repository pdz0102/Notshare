--!strict
--[[
    ============================================================================
      NN HUB — LIQUID GLASS UI FRAMEWORK v2.0 (DARK & WHITE GLASS EDITION)
      Pure Roblox Luau | 100% Vector Icons (Zero Missing Glyphs) | 60-120FPS
      Upgrades:
        [1] Concentric CanvasGroup Glass Rounding + Floating Inset Sidebar
        [2] Custom Vector Icons for Search / Theme / Menu / Tabs / Rows / Close
        [3] Live Roblox Profile Card (HeadShot Avatar + DisplayName + Game Name)
        [4] Spring-Gliding Liquid Glass Active Tab Pill (Fixed UIListLayout)
        [5] In-Place Morphing Running Telemetry Pill with Vector Close (X)
        [6] Minimal Dynamic Island (Tap = Toggle GUI | Pull Down = Card + X)
    ============================================================================
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local MarketplaceService = game:GetService("MarketplaceService")
local Lighting = game:GetService("Lighting")
local Stats = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer

-- ============================================================================
-- 1. SAFE PARENT & CLEANUP
-- ============================================================================
local GUI_NAME = "NNHub_LiquidGlass_UI"

local function getSafeParent(): Instance
	local ok, target = pcall(function()
		local gethuiFn = (getfenv() :: any).gethui
		if type(gethuiFn) == "function" then
			return gethuiFn()
		end
		return game:GetService("CoreGui")
	end)
	if ok and target then
		return target
	end
	return LocalPlayer:WaitForChild("PlayerGui")
end

local SafeParent = getSafeParent()
do
	local old = SafeParent:FindFirstChild(GUI_NAME)
	if old then
		old:Destroy()
	end
	local oldBlur = Lighting:FindFirstChild("NNHub_IntroBlur")
	if oldBlur then
		oldBlur:Destroy()
	end
end

-- ============================================================================
-- 2. 2ND-ORDER DAMPED SPRING PHYSICS ENGINE
-- ============================================================================
local Spring = {}
Spring.__index = Spring

type SpringObject = {
	Position: number,
	Velocity: number,
	Target: number,
	Stiffness: number,
	Damping: number,
	Update: (self: SpringObject, dt: number) -> number,
	IsSettled: (self: SpringObject) -> boolean,
}

function Spring.new(initial: number, stiffness: number?, damping: number?): SpringObject
	local self = setmetatable({
		Position = initial,
		Velocity = 0,
		Target = initial,
		Stiffness = stiffness or 260,
		Damping = damping or 24,
	}, Spring)
	return self :: any
end

function Spring:Update(dt: number): number
	local clampedDt = math.min(dt, 1 / 20)
	local force = -self.Stiffness * (self.Position - self.Target)
	local damper = -self.Damping * self.Velocity
	self.Velocity += (force + damper) * clampedDt
	self.Position += self.Velocity * clampedDt
	return self.Position
end

function Spring:IsSettled(): boolean
	return math.abs(self.Target - self.Position) < 0.001 and math.abs(self.Velocity) < 0.005
end

-- ============================================================================
-- 3. THEME PALETTES (DARK, WHITE GLASS, MIDNIGHT, GRAPHITE, OLED, HALLOWEEN)
-- ============================================================================
type ThemePalette = {
	Name: string,
	IsLight: boolean,
	WindowBg: Color3,
	WindowTrans: number,
	SidebarBg: Color3,
	SidebarTrans: number,
	ProfileBg: Color3,
	ProfileTrans: number,
	CardBg: Color3,
	CardTrans: number,
	CardHoverBg: Color3,
	CardHoverTrans: number,
	ControlBg: Color3,
	ControlTrans: number,
	PopoverBg: Color3,
	PopoverTrans: number,
	Stroke: Color3,
	StrokeTrans: number,
	OuterStroke: Color3,
	OuterStrokeTrans: number,
	Sheen: Color3,
	SheenTransTop: number,
	TextPrimary: Color3,
	TextSecondary: Color3,
	TextMuted: Color3,
	Accent: Color3,
	ToggleOn: Color3,
	ToggleOff: Color3,
	ToggleKnob: Color3,
	TabActiveBg: Color3,
	TabActiveTrans: number,
	IslandBg: Color3,
	IslandTrans: number,
	IslandText: Color3,
	IslandStroke: Color3,
	IslandStrokeTrans: number,
	StatusBg: Color3,
	StatusExpandedBg: Color3,
	StatusDot: Color3,
	StatusText: Color3,
}

local Themes: { [string]: ThemePalette } = {
	Dark = {
		Name = "Dark",
		IsLight = false,
		WindowBg = Color3.fromRGB(18, 20, 26),
		WindowTrans = 0.10,
		SidebarBg = Color3.fromRGB(26, 29, 38),
		SidebarTrans = 0.34,
		ProfileBg = Color3.fromRGB(36, 40, 52),
		ProfileTrans = 0.30,
		CardBg = Color3.fromRGB(32, 35, 44),
		CardTrans = 0.30,
		CardHoverBg = Color3.fromRGB(46, 50, 62),
		CardHoverTrans = 0.18,
		ControlBg = Color3.fromRGB(46, 49, 60),
		ControlTrans = 0.18,
		PopoverBg = Color3.fromRGB(24, 26, 34),
		PopoverTrans = 0.04,
		Stroke = Color3.fromRGB(255, 255, 255),
		StrokeTrans = 0.84,
		OuterStroke = Color3.fromRGB(255, 255, 255),
		OuterStrokeTrans = 0.78,
		Sheen = Color3.fromRGB(255, 255, 255),
		SheenTransTop = 0.88,
		TextPrimary = Color3.fromRGB(245, 247, 252),
		TextSecondary = Color3.fromRGB(154, 162, 178),
		TextMuted = Color3.fromRGB(110, 118, 134),
		Accent = Color3.fromRGB(52, 199, 89),
		ToggleOn = Color3.fromRGB(52, 199, 89),
		ToggleOff = Color3.fromRGB(66, 70, 82),
		ToggleKnob = Color3.fromRGB(255, 255, 255),
		TabActiveBg = Color3.fromRGB(255, 255, 255),
		TabActiveTrans = 0.86,
		IslandBg = Color3.fromRGB(12, 13, 18),
		IslandTrans = 0.06,
		IslandText = Color3.fromRGB(248, 250, 255),
		IslandStroke = Color3.fromRGB(255, 255, 255),
		IslandStrokeTrans = 0.78,
		StatusBg = Color3.fromRGB(20, 48, 36),
		StatusExpandedBg = Color3.fromRGB(22, 26, 34),
		StatusDot = Color3.fromRGB(52, 211, 153),
		StatusText = Color3.fromRGB(110, 231, 183),
	},
	Light = {
		Name = "Light",
		IsLight = true,
		WindowBg = Color3.fromRGB(244, 247, 253),
		WindowTrans = 0.10,
		SidebarBg = Color3.fromRGB(232, 238, 248),
		SidebarTrans = 0.24,
		ProfileBg = Color3.fromRGB(255, 255, 255),
		ProfileTrans = 0.22,
		CardBg = Color3.fromRGB(255, 255, 255),
		CardTrans = 0.22,
		CardHoverBg = Color3.fromRGB(255, 255, 255),
		CardHoverTrans = 0.04,
		ControlBg = Color3.fromRGB(224, 230, 240),
		ControlTrans = 0.12,
		PopoverBg = Color3.fromRGB(250, 252, 255),
		PopoverTrans = 0.03,
		Stroke = Color3.fromRGB(15, 23, 42),
		StrokeTrans = 0.88,
		OuterStroke = Color3.fromRGB(255, 255, 255),
		OuterStrokeTrans = 0.18,
		Sheen = Color3.fromRGB(255, 255, 255),
		SheenTransTop = 0.52,
		TextPrimary = Color3.fromRGB(18, 22, 34),
		TextSecondary = Color3.fromRGB(88, 96, 114),
		TextMuted = Color3.fromRGB(124, 134, 152),
		Accent = Color3.fromRGB(48, 188, 84),
		ToggleOn = Color3.fromRGB(52, 199, 89),
		ToggleOff = Color3.fromRGB(194, 202, 216),
		ToggleKnob = Color3.fromRGB(255, 255, 255),
		TabActiveBg = Color3.fromRGB(15, 23, 42),
		TabActiveTrans = 0.89,
		IslandBg = Color3.fromRGB(246, 249, 255),
		IslandTrans = 0.07,
		IslandText = Color3.fromRGB(18, 22, 34),
		IslandStroke = Color3.fromRGB(255, 255, 255),
		IslandStrokeTrans = 0.16,
		StatusBg = Color3.fromRGB(218, 245, 229),
		StatusExpandedBg = Color3.fromRGB(248, 251, 255),
		StatusDot = Color3.fromRGB(22, 163, 74),
		StatusText = Color3.fromRGB(21, 128, 61),
	},
	Midnight = {
		Name = "Midnight",
		IsLight = false,
		WindowBg = Color3.fromRGB(14, 16, 28),
		WindowTrans = 0.08,
		SidebarBg = Color3.fromRGB(22, 24, 42),
		SidebarTrans = 0.30,
		ProfileBg = Color3.fromRGB(30, 34, 58),
		ProfileTrans = 0.26,
		CardBg = Color3.fromRGB(26, 29, 48),
		CardTrans = 0.26,
		CardHoverBg = Color3.fromRGB(38, 42, 68),
		CardHoverTrans = 0.16,
		ControlBg = Color3.fromRGB(40, 44, 70),
		ControlTrans = 0.18,
		PopoverBg = Color3.fromRGB(20, 22, 38),
		PopoverTrans = 0.04,
		Stroke = Color3.fromRGB(172, 178, 255),
		StrokeTrans = 0.84,
		OuterStroke = Color3.fromRGB(160, 168, 255),
		OuterStrokeTrans = 0.78,
		Sheen = Color3.fromRGB(210, 218, 255),
		SheenTransTop = 0.88,
		TextPrimary = Color3.fromRGB(242, 244, 255),
		TextSecondary = Color3.fromRGB(146, 154, 188),
		TextMuted = Color3.fromRGB(102, 110, 144),
		Accent = Color3.fromRGB(124, 114, 255),
		ToggleOn = Color3.fromRGB(124, 114, 255),
		ToggleOff = Color3.fromRGB(54, 58, 84),
		ToggleKnob = Color3.fromRGB(255, 255, 255),
		TabActiveBg = Color3.fromRGB(124, 114, 255),
		TabActiveTrans = 0.80,
		IslandBg = Color3.fromRGB(12, 14, 24),
		IslandTrans = 0.06,
		IslandText = Color3.fromRGB(242, 244, 255),
		IslandStroke = Color3.fromRGB(150, 158, 255),
		IslandStrokeTrans = 0.76,
		StatusBg = Color3.fromRGB(18, 46, 44),
		StatusExpandedBg = Color3.fromRGB(18, 22, 38),
		StatusDot = Color3.fromRGB(52, 211, 153),
		StatusText = Color3.fromRGB(110, 231, 183),
	},
	Graphite = {
		Name = "Graphite",
		IsLight = false,
		WindowBg = Color3.fromRGB(36, 38, 45),
		WindowTrans = 0.12,
		SidebarBg = Color3.fromRGB(46, 49, 58),
		SidebarTrans = 0.34,
		ProfileBg = Color3.fromRGB(56, 60, 70),
		ProfileTrans = 0.28,
		CardBg = Color3.fromRGB(52, 56, 65),
		CardTrans = 0.30,
		CardHoverBg = Color3.fromRGB(66, 70, 82),
		CardHoverTrans = 0.18,
		ControlBg = Color3.fromRGB(64, 68, 78),
		ControlTrans = 0.18,
		PopoverBg = Color3.fromRGB(42, 45, 54),
		PopoverTrans = 0.04,
		Stroke = Color3.fromRGB(255, 255, 255),
		StrokeTrans = 0.82,
		OuterStroke = Color3.fromRGB(255, 255, 255),
		OuterStrokeTrans = 0.76,
		Sheen = Color3.fromRGB(255, 255, 255),
		SheenTransTop = 0.84,
		TextPrimary = Color3.fromRGB(246, 248, 252),
		TextSecondary = Color3.fromRGB(178, 184, 196),
		TextMuted = Color3.fromRGB(134, 140, 154),
		Accent = Color3.fromRGB(56, 189, 248),
		ToggleOn = Color3.fromRGB(52, 199, 89),
		ToggleOff = Color3.fromRGB(82, 86, 98),
		ToggleKnob = Color3.fromRGB(255, 255, 255),
		TabActiveBg = Color3.fromRGB(255, 255, 255),
		TabActiveTrans = 0.85,
		IslandBg = Color3.fromRGB(26, 28, 34),
		IslandTrans = 0.06,
		IslandText = Color3.fromRGB(246, 248, 252),
		IslandStroke = Color3.fromRGB(255, 255, 255),
		IslandStrokeTrans = 0.75,
		StatusBg = Color3.fromRGB(24, 52, 44),
		StatusExpandedBg = Color3.fromRGB(38, 42, 50),
		StatusDot = Color3.fromRGB(52, 211, 153),
		StatusText = Color3.fromRGB(110, 231, 183),
	},
	OLED = {
		Name = "OLED",
		IsLight = false,
		WindowBg = Color3.fromRGB(6, 6, 9),
		WindowTrans = 0.05,
		SidebarBg = Color3.fromRGB(14, 14, 18),
		SidebarTrans = 0.24,
		ProfileBg = Color3.fromRGB(22, 22, 28),
		ProfileTrans = 0.22,
		CardBg = Color3.fromRGB(18, 18, 24),
		CardTrans = 0.22,
		CardHoverBg = Color3.fromRGB(28, 28, 36),
		CardHoverTrans = 0.12,
		ControlBg = Color3.fromRGB(26, 26, 34),
		ControlTrans = 0.14,
		PopoverBg = Color3.fromRGB(12, 12, 16),
		PopoverTrans = 0.03,
		Stroke = Color3.fromRGB(255, 255, 255),
		StrokeTrans = 0.86,
		OuterStroke = Color3.fromRGB(255, 255, 255),
		OuterStrokeTrans = 0.82,
		Sheen = Color3.fromRGB(255, 255, 255),
		SheenTransTop = 0.90,
		TextPrimary = Color3.fromRGB(255, 255, 255),
		TextSecondary = Color3.fromRGB(148, 150, 162),
		TextMuted = Color3.fromRGB(100, 104, 118),
		Accent = Color3.fromRGB(52, 199, 89),
		ToggleOn = Color3.fromRGB(52, 199, 89),
		ToggleOff = Color3.fromRGB(44, 44, 54),
		ToggleKnob = Color3.fromRGB(255, 255, 255),
		TabActiveBg = Color3.fromRGB(255, 255, 255),
		TabActiveTrans = 0.86,
		IslandBg = Color3.fromRGB(0, 0, 0),
		IslandTrans = 0.03,
		IslandText = Color3.fromRGB(255, 255, 255),
		IslandStroke = Color3.fromRGB(255, 255, 255),
		IslandStrokeTrans = 0.80,
		StatusBg = Color3.fromRGB(14, 38, 28),
		StatusExpandedBg = Color3.fromRGB(12, 14, 18),
		StatusDot = Color3.fromRGB(52, 211, 153),
		StatusText = Color3.fromRGB(110, 231, 183),
	},
	Halloween = {
		Name = "Halloween",
		IsLight = false,
		WindowBg = Color3.fromRGB(20, 14, 26),
		WindowTrans = 0.10,
		SidebarBg = Color3.fromRGB(28, 20, 36),
		SidebarTrans = 0.30,
		ProfileBg = Color3.fromRGB(40, 28, 52),
		ProfileTrans = 0.26,
		CardBg = Color3.fromRGB(36, 26, 46),
		CardTrans = 0.28,
		CardHoverBg = Color3.fromRGB(50, 36, 64),
		CardHoverTrans = 0.18,
		ControlBg = Color3.fromRGB(48, 34, 60),
		ControlTrans = 0.18,
		PopoverBg = Color3.fromRGB(26, 18, 34),
		PopoverTrans = 0.04,
		Stroke = Color3.fromRGB(255, 156, 68),
		StrokeTrans = 0.82,
		OuterStroke = Color3.fromRGB(255, 146, 58),
		OuterStrokeTrans = 0.76,
		Sheen = Color3.fromRGB(255, 190, 120),
		SheenTransTop = 0.88,
		TextPrimary = Color3.fromRGB(255, 246, 238),
		TextSecondary = Color3.fromRGB(192, 168, 186),
		TextMuted = Color3.fromRGB(140, 118, 142),
		Accent = Color3.fromRGB(249, 115, 22),
		ToggleOn = Color3.fromRGB(249, 115, 22),
		ToggleOff = Color3.fromRGB(68, 52, 78),
		ToggleKnob = Color3.fromRGB(255, 255, 255),
		TabActiveBg = Color3.fromRGB(249, 115, 22),
		TabActiveTrans = 0.78,
		IslandBg = Color3.fromRGB(16, 10, 20),
		IslandTrans = 0.06,
		IslandText = Color3.fromRGB(255, 224, 190),
		IslandStroke = Color3.fromRGB(249, 115, 22),
		IslandStrokeTrans = 0.70,
		StatusBg = Color3.fromRGB(58, 30, 16),
		StatusExpandedBg = Color3.fromRGB(28, 18, 34),
		StatusDot = Color3.fromRGB(251, 146, 60),
		StatusText = Color3.fromRGB(253, 186, 116),
	},
}

-- ============================================================================
-- 4. UI UTILITIES & PURE-LUAU VECTOR ICON ENGINE (ZERO MISSING GLYPHS!)
-- ============================================================================
local NNHub = {}
NNHub.__index = NNHub

local function create(className: string, props: { [string]: any }, parent: Instance?): any
	local inst = Instance.new(className)
	for k, v in pairs(props) do
		(inst :: any)[k] = v
	end
	if parent then
		inst.Parent = parent
	end
	return inst
end

local function addCorner(parent: Instance, radius: number): UICorner
	return create("UICorner", { CornerRadius = UDim.new(0, radius) }, parent)
end

local function addStroke(parent: Instance, color: Color3, thickness: number?, trans: number?): UIStroke
	return create("UIStroke", {
		Color = color,
		Thickness = thickness or 1,
		Transparency = trans or 0.82,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	}, parent)
end

-- Pure-Luau Crisp Geometric Vector Icons (Works 100% on PC & Mobile, Zero Tofu Boxes!)
local function createVectorIcon(iconType: string, parent: Instance, color: Color3, zIndex: number?): { Root: Frame, SetColor: (Color3) -> (), Parts: { Instance } }
	local z = zIndex or 25
	local root = create("Frame", {
		Name = "Vec_" .. iconType,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(14, 14),
		BackgroundTransparency = 1,
		ZIndex = z,
	}, parent)

	local fillParts: { Frame } = {}
	local strokeParts: { UIStroke } = {}
	local allParts: { Instance } = {}

	local function bar(x: number, y: number, w: number, h: number, rot: number?, radius: number?): Frame
		local f = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset(x, y),
			Size = UDim2.fromOffset(w, h),
			Rotation = rot or 0,
			BackgroundColor3 = color,
			BorderSizePixel = 0,
			ZIndex = z + 1,
		}, root)
		addCorner(f, radius or 999)
		table.insert(fillParts, f)
		table.insert(allParts, f)
		return f
	end

	local function ring(x: number, y: number, w: number, h: number, thick: number?, radius: number?): Frame
		local f = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset(x, y),
			Size = UDim2.fromOffset(w, h),
			BackgroundTransparency = 1,
			ZIndex = z + 1,
		}, root)
		addCorner(f, radius or 999)
		local st = addStroke(f, color, thick or 1.6, 0)
		table.insert(strokeParts, st)
		table.insert(allParts, f)
		return f
	end

	if iconType == "search" then
		ring(6, 6, 8, 8, 1.6, 999)
		bar(11, 11, 5, 1.7, 45)
	elseif iconType == "theme" then
		ring(7, 7, 11, 11, 1.5, 999)
		local clip = create("Frame", {
			Position = UDim2.fromOffset(7, 1.5),
			Size = UDim2.fromOffset(5.5, 11),
			BackgroundTransparency = 1,
			ClipsDescendants = true,
			ZIndex = z + 1,
		}, root)
		local half = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset(0, 5.5),
			Size = UDim2.fromOffset(9.5, 9.5),
			BackgroundColor3 = color,
			BorderSizePixel = 0,
			ZIndex = z + 2,
		}, clip)
		addCorner(half, 999)
		table.insert(fillParts, half)
		table.insert(allParts, half)
	elseif iconType == "menu" then
		bar(7, 3.5, 11, 1.7, 0)
		bar(5.8, 7, 8.6, 1.7, 0)
		bar(7, 10.5, 11, 1.7, 0)
	elseif iconType == "close" then
		bar(7, 7, 11, 1.8, 45)
		bar(7, 7, 11, 1.8, -45)
	elseif iconType == "chevron" then
		bar(5, 7.5, 5.5, 1.6, 40)
		bar(9, 7.5, 5.5, 1.6, -40)
	elseif iconType == "check" then
		bar(4.5, 8.2, 4.5, 1.7, 45)
		bar(8.6, 6.8, 7.5, 1.7, -45)
	elseif iconType == "home" then
		bar(4.5, 4.8, 6.8, 1.6, -42)
		bar(9.5, 4.8, 6.8, 1.6, 42)
		ring(7, 9, 8, 6.5, 1.5, 2)
	elseif iconType == "farm" then
		bar(7, 7, 10, 1.6, 0)
		bar(7, 7, 10, 1.6, 90)
		bar(7, 7, 6.5, 6.5, 45, 2)
	elseif iconType == "visual" then
		ring(7, 7, 12, 7.5, 1.5, 999)
		bar(7, 7, 3.6, 3.6, 0, 999)
	elseif iconType == "halloween" then
		ring(7, 7, 10, 10, 1.5, 999)
		bar(7, 7, 6, 6, 45, 2)
	elseif iconType == "settings" then
		ring(7, 7, 7.5, 7.5, 1.6, 999)
		bar(7, 1.8, 2, 2.5, 0)
		bar(7, 12.2, 2, 2.5, 0)
		bar(1.8, 7, 2.5, 2, 0)
		bar(12.2, 7, 2.5, 2, 0)
	elseif iconType == "target" then
		ring(7, 7, 11, 11, 1.4, 999)
		bar(7, 7, 4, 4, 0, 999)
	elseif iconType == "bolt" then
		bar(6.2, 4.8, 6, 1.8, -58)
		bar(7, 7, 5, 1.7, 0)
		bar(7.8, 9.2, 6, 1.8, -58)
	elseif iconType == "moon" then
		ring(7, 7, 9.5, 9.5, 1.6, 999)
		bar(9.5, 4.5, 3, 3, 0, 999)
	elseif iconType == "sword" then
		bar(7, 7, 11, 1.8, -45)
		bar(5, 9, 5.5, 1.6, 45)
	elseif iconType == "key" then
		ring(4.8, 7, 5.5, 5.5, 1.5, 999)
		bar(9.8, 7, 5.5, 1.6, 0)
		bar(11, 8.6, 1.6, 2.5, 0)
	elseif iconType == "palette" then
		ring(7, 7, 11, 11, 1.5, 999)
		bar(5, 5.5, 2.3, 2.3, 0, 999)
		bar(9, 5.5, 2.3, 2.3, 0, 999)
		bar(7, 9.2, 2.3, 2.3, 0, 999)
	elseif iconType == "layout" then
		ring(4.2, 4.2, 4.5, 4.5, 1.3, 1)
		ring(9.8, 4.2, 4.5, 4.5, 1.3, 1)
		ring(4.2, 9.8, 4.5, 4.5, 1.3, 1)
		ring(9.8, 9.8, 4.5, 4.5, 1.3, 1)
	elseif iconType == "save" then
		bar(7, 5.5, 1.7, 7, 0)
		bar(5.3, 7.3, 4.4, 1.6, 45)
		bar(8.7, 7.3, 4.4, 1.6, -45)
		bar(7, 11.5, 9.5, 1.6, 0)
	elseif iconType == "replay" then
		ring(7, 7, 10, 10, 1.5, 999)
		bar(10.5, 3.8, 4, 1.6, 15)
		bar(10.8, 5.5, 1.6, 3.8, 15)
	elseif iconType == "return" then
		bar(7.5, 7, 8, 1.6, 0)
		bar(4.8, 5.5, 4.5, 1.6, -40)
		bar(4.8, 8.5, 4.5, 1.6, 40)
	else
		bar(7, 7, 6.5, 6.5, 45, 2)
	end

	return {
		Root = root,
		Parts = allParts,
		SetColor = function(newColor: Color3)
			for _, f in ipairs(fillParts) do
				f.BackgroundColor3 = newColor
			end
			for _, st in ipairs(strokeParts) do
				st.Color = newColor
			end
		end,
	}
end

-- Catmull-Rom spline for handwritten "hello" intro
local function catmullRom(p0: Vector2, p1: Vector2, p2: Vector2, p3: Vector2, t: number): Vector2
	local t2 = t * t
	local t3 = t2 * t
	return 0.5 * (
		(2 * p1)
		+ (-p0 + p2) * t
		+ (2 * p0 - 5 * p1 + 4 * p2 - p3) * t2
		+ (-p0 + 3 * p1 - 3 * p2 + p3) * t3
	)
end

local function sampleSpline(points: { Vector2 }, stepsPerSegment: number): { Vector2 }
	local out = {}
	local n = #points
	for i = 1, n - 1 do
		local p0 = points[math.max(1, i - 1)]
		local p1 = points[i]
		local p2 = points[i + 1]
		local p3 = points[math.min(n, i + 2)]
		for s = 0, stepsPerSegment - 1 do
			table.insert(out, catmullRom(p0, p1, p2, p3, s / stepsPerSegment))
		end
	end
	table.insert(out, points[n])
	return out
end

-- ============================================================================
-- 5. LIBRARY CONSTRUCTOR: NNHub:CreateWindow(config)
-- ============================================================================
function NNHub:CreateWindow(config: {
	Title: string?,
	SubTitle: string?,
	Theme: string?,
	TabPosition: string?,
	PlayIntro: boolean?,
	ToggleKey: Enum.KeyCode?,
}?)
	local cfg = config or {}
	local titleText = cfg.Title or "NN Hub"
	local subTitleText = cfg.SubTitle or "Liquid Glass"
	local currentThemeName = Themes[cfg.Theme or "Dark"] and (cfg.Theme or "Dark") or "Dark"
	local currentTabPos = cfg.TabPosition or "Left"
	local playIntro = if cfg.PlayIntro == nil then true else cfg.PlayIntro
	local toggleKey = cfg.ToggleKey or Enum.KeyCode.RightShift

	local ReduceMotion = false
	local CompactRows = false
	local IsWindowOpen = false
	local IsIslandExpanded = false
	local IsSearchOpen = false
	local IsStatusExpanded = false
	local SessionStart = os.clock()
	local ActiveDropdownClose: (() -> ())? = nil

	local Connections: { RBXScriptConnection } = {}
	local ActiveSprings: { { Spring: SpringObject, Callback: (number) -> () } } = {}
	local ThemeHandlers: { (ThemePalette, number) -> () } = {}

	local function connect(sig: RBXScriptSignal, fn: (...any) -> ()): RBXScriptConnection
		local c = sig:Connect(fn)
		table.insert(Connections, c)
		return c
	end

	local function getDur(base: number): number
		return ReduceMotion and (base * 0.35) or base
	end

	local function tween(inst: Instance, dur: number, props: { [string]: any }, style: Enum.EasingStyle?, dir: Enum.EasingDirection?)
		local tw = TweenService:Create(
			inst,
			TweenInfo.new(getDur(dur), style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out),
			props
		)
		tw:Play()
		return tw
	end

	local function registerSpring(initial: number, stiffness: number, damping: number, callback: (number) -> ()): SpringObject
		local sp = Spring.new(initial, stiffness, damping)
		table.insert(ActiveSprings, { Spring = sp, Callback = callback })
		return sp
	end

	local function bindTheme(handler: (ThemePalette, number) -> ())
		table.insert(ThemeHandlers, handler)
		handler(Themes[currentThemeName], 0)
	end

	-- Tactile Ripple Wave on click/touch
	local function spawnRipple(target: GuiObject, customColor: Color3?)
		local theme = Themes[currentThemeName]
		local mouseLoc = UserInputService:GetMouseLocation()
		local relX = mouseLoc.X - target.AbsolutePosition.X
		local relY = mouseLoc.Y - target.AbsolutePosition.Y
		local maxDim = math.max(target.AbsoluteSize.X, target.AbsoluteSize.Y) * 2.1

		local clipHolder = target:FindFirstChild("_RippleClip") :: Frame?
		if not clipHolder then
			local existingCorner = target:FindFirstChildOfClass("UICorner")
			clipHolder = create("Frame", {
				Name = "_RippleClip",
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				ClipsDescendants = true,
				ZIndex = target.ZIndex + 1,
			}, target)
			if existingCorner then
				create("UICorner", { CornerRadius = existingCorner.CornerRadius }, clipHolder)
			end
		end

		local ripple = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset(relX, relY),
			Size = UDim2.fromOffset(6, 6),
			BackgroundColor3 = customColor or (theme.IsLight and Color3.fromRGB(15, 23, 42) or Color3.fromRGB(255, 255, 255)),
			BackgroundTransparency = theme.IsLight and 0.85 or 0.78,
			BorderSizePixel = 0,
			ZIndex = (clipHolder :: Frame).ZIndex + 1,
		}, clipHolder)
		addCorner(ripple, 999)

		local tw = tween(ripple, 0.45, {
			Size = UDim2.fromOffset(maxDim, maxDim),
			BackgroundTransparency = 1,
		}, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
		tw.Completed:Connect(function()
			ripple:Destroy()
		end)
	end

	-- Spring Press Squish on buttons
	local function bindPressSquish(button: GuiButton, scaleTarget: GuiObject?, downScale: number?)
		local target = scaleTarget or button
		local uiScale = target:FindFirstChildOfClass("UIScale") or create("UIScale", { Scale = 1 }, target)
		local pressedScale = downScale or 0.94
		local sp = registerSpring(1, 440, 22, function(val)
			if uiScale.Parent then
				uiScale.Scale = val
			end
		end)
		connect(button.MouseButton1Down, function()
			sp.Target = pressedScale
		end)
		connect(button.MouseButton1Up, function()
			sp.Target = 1
		end)
		connect(button.MouseLeave, function()
			sp.Target = 1
		end)
	end

	-- ============================================================================
	-- 6. ROOT SCREENGUI & LAYERS
	-- ============================================================================
	local ScreenGui = create("ScreenGui", {
		Name = GUI_NAME,
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 999,
	}, SafeParent)

	local RootContainer = create("Frame", {
		Name = "Root",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
	}, ScreenGui)

	local OverlayLayer = create("Frame", {
		Name = "OverlayLayer",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ZIndex = 200,
	}, RootContainer)

	local IntroLayer = create("Frame", {
		Name = "IntroLayer",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ZIndex = 300,
	}, RootContainer)

	local ToastContainer = create("Frame", {
		Name = "Toasts",
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -18, 1, -18),
		Size = UDim2.fromOffset(292, 320),
		BackgroundTransparency = 1,
		ZIndex = 250,
	}, RootContainer)
	create("UIListLayout", {
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, ToastContainer)

	local WIN_W, WIN_H = 656, 428
	local MainWindowHolder = create("Frame", {
		Name = "MainWindowHolder",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.52),
		Size = UDim2.fromOffset(WIN_W, WIN_H),
		BackgroundTransparency = 1,
		Visible = false,
		ZIndex = 10,
	}, RootContainer)

	local WindowScale = create("UIScale", { Scale = 0.85 }, MainWindowHolder)

	local function getResponsiveScale(): number
		local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
		local scaleX = (vp.X - 36) / WIN_W
		local scaleY = (vp.Y - 96) / WIN_H
		return math.clamp(math.min(1, scaleX, scaleY), 0.62, 1)
	end

	-- ============================================================================
	-- 7. DYNAMIC ISLAND (MINIMAL COLLAPSED PILL + PULL-DOWN CARD WITH X CLOSE)
	--    • Collapsed: NO right icon/button. Tap directly to Toggle GUI.
	--    • Expanded: NO "Open GUI" button. Has crisp Vector X button to collapse.
	-- ============================================================================
	local IslandFrame = create("Frame", {
		Name = "DynamicIsland",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, -54),
		Size = UDim2.fromOffset(120, 30),
		BackgroundColor3 = Themes[currentThemeName].IslandBg,
		BackgroundTransparency = Themes[currentThemeName].IslandTrans,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		ZIndex = 120,
	}, RootContainer)
	local IslandCorner = addCorner(IslandFrame, 15)
	local IslandStroke = addStroke(IslandFrame, Themes[currentThemeName].IslandStroke, 1.15, Themes[currentThemeName].IslandStrokeTrans)

	-- Liquid Glass Top Sheen on Dynamic Island
	local IslandSheen = create("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 0.90,
		BorderSizePixel = 0,
		ZIndex = 121,
	}, IslandFrame)
	addCorner(IslandSheen, 15)
	create("UIGradient", {
		Rotation = 90,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.45),
			NumberSequenceKeypoint.new(0.45, 0.94),
			NumberSequenceKeypoint.new(1, 1),
		}),
	}, IslandSheen)

	-- Top Row (Tap when collapsed = Toggle GUI | Pull Down = Expand)
	local IslandCompactRow = create("TextButton", {
		Name = "CompactBtn",
		Size = UDim2.new(1, 0, 0, 30),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		ZIndex = 125,
	}, IslandFrame)

	-- Centered Status Dot + Title Group (Clean, zero right icon when collapsed!)
	local IslandBrandGroup = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(92, 20),
		BackgroundTransparency = 1,
		ZIndex = 126,
	}, IslandCompactRow)
	create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 7),
	}, IslandBrandGroup)

	local IslandDot = create("Frame", {
		Size = UDim2.fromOffset(7, 7),
		BackgroundColor3 = Color3.fromRGB(52, 211, 153),
		BorderSizePixel = 0,
		ZIndex = 127,
	}, IslandBrandGroup)
	addCorner(IslandDot, 999)

	local IslandLogoLabel = create("TextLabel", {
		Size = UDim2.fromOffset(64, 18),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Text = titleText,
		TextSize = 12,
		TextColor3 = Themes[currentThemeName].IslandText,
		ZIndex = 127,
	}, IslandBrandGroup)

	-- Vector X Button on Top-Right (ONLY visible when Dynamic Island is Expanded!)
	local IslandCloseBtn = create("TextButton", {
		Name = "CloseExpandedBtn",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -8, 0.5, 0),
		Size = UDim2.fromOffset(22, 22),
		BackgroundColor3 = Themes[currentThemeName].ControlBg,
		BackgroundTransparency = 0.45,
		Text = "",
		Visible = false,
		AutoButtonColor = false,
		ZIndex = 130,
	}, IslandCompactRow)
	addCorner(IslandCloseBtn, 999)
	local IslandCloseIcon = createVectorIcon("close", IslandCloseBtn, Themes[currentThemeName].IslandText, 131)
	local IslandCloseScale = create("UIScale", { Scale = 0.6 }, IslandCloseBtn)
	bindPressSquish(IslandCloseBtn, IslandCloseBtn, 0.86)

	connect(IslandCloseBtn.MouseEnter, function()
		tween(IslandCloseBtn, 0.16, { BackgroundTransparency = 0.15 })
		tween(IslandCloseIcon.Root, 0.22, { Rotation = 90 }, Enum.EasingStyle.Back)
	end)
	connect(IslandCloseBtn.MouseLeave, function()
		tween(IslandCloseBtn, 0.18, { BackgroundTransparency = 0.45 })
		tween(IslandCloseIcon.Root, 0.22, { Rotation = 0 })
	end)

	-- Expanded Pull-Down Card Body (Telemetry + Quick Theme Switch, NO "Open GUI" button!)
	local IslandExpandedBody = create("CanvasGroup", {
		Name = "ExpandedBody",
		Position = UDim2.fromOffset(0, 32),
		Size = UDim2.new(1, 0, 1, -32),
		BackgroundTransparency = 1,
		GroupTransparency = 1,
		Visible = false,
		ZIndex = 124,
	}, IslandFrame)

	local IslandStatsLabel = create("TextLabel", {
		Position = UDim2.fromOffset(14, 2),
		Size = UDim2.new(1, -28, 0, 18),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		Text = "FPS: 60  •  Ping: 32ms  •  00:00",
		TextSize = 11,
		TextColor3 = Themes[currentThemeName].TextSecondary,
		TextXAlignment = Enum.TextXAlignment.Center,
		ZIndex = 125,
	}, IslandExpandedBody)

	local IslandThemeBtn = create("TextButton", {
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 26),
		Size = UDim2.fromOffset(158, 28),
		BackgroundColor3 = Themes[currentThemeName].ControlBg,
		BackgroundTransparency = 0.20,
		Font = Enum.Font.GothamSemibold,
		Text = "Chuyển Nền Trắng",
		TextSize = 11,
		TextColor3 = Themes[currentThemeName].IslandText,
		AutoButtonColor = false,
		ZIndex = 126,
	}, IslandExpandedBody)
	addCorner(IslandThemeBtn, 14)
	local IslandThemeBtnStroke = addStroke(IslandThemeBtn, Themes[currentThemeName].Stroke, 1, Themes[currentThemeName].StrokeTrans)
	bindPressSquish(IslandThemeBtn, IslandThemeBtn, 0.93)

	local IslandHandle = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -6),
		Size = UDim2.fromOffset(34, 3),
		BackgroundColor3 = Themes[currentThemeName].TextMuted,
		BackgroundTransparency = 0.55,
		BorderSizePixel = 0,
		ZIndex = 126,
	}, IslandExpandedBody)
	addCorner(IslandHandle, 999)

	-- Dynamic Island Springs
	local islandW = registerSpring(120, 310, 24, function(v)
		IslandFrame.Size = UDim2.fromOffset(math.round(v), IslandFrame.Size.Y.Offset)
	end)
	local islandH = registerSpring(30, 310, 24, function(v)
		IslandFrame.Size = UDim2.fromOffset(IslandFrame.Size.X.Offset, math.round(v))
		local r = math.round(math.clamp(15 + (v - 30) * 0.10, 15, 22))
		IslandCorner.CornerRadius = UDim.new(0, r)
	end)
	local islandY = registerSpring(-54, 240, 20, function(v)
		IslandFrame.Position = UDim2.new(0.5, 0, 0, math.round(v))
	end)

	local function setIslandExpanded(expanded: boolean)
		IsIslandExpanded = expanded
		if expanded then
			IslandExpandedBody.Visible = true
			IslandCloseBtn.Visible = true
			islandW.Target = 264
			islandH.Target = 102
			tween(IslandExpandedBody, 0.24, { GroupTransparency = 0 })
			tween(IslandCloseScale, 0.28, { Scale = 1 }, Enum.EasingStyle.Back)
			tween(IslandBrandGroup, 0.24, { Position = UDim2.new(0, 60, 0.5, 0) })
		else
			islandW.Target = 120
			islandH.Target = 30
			tween(IslandExpandedBody, 0.16, { GroupTransparency = 1 })
			tween(IslandCloseScale, 0.16, { Scale = 0.6 })
			tween(IslandBrandGroup, 0.24, { Position = UDim2.fromScale(0.5, 0.5) })
			task.delay(0.18, function()
				if not IsIslandExpanded then
					IslandExpandedBody.Visible = false
					IslandCloseBtn.Visible = false
				end
			end)
		end
	end

	connect(IslandCloseBtn.MouseButton1Click, function()
		spawnRipple(IslandCloseBtn)
		setIslandExpanded(false)
	end)

	-- Hover + Elastic Pull-Down Drag on Dynamic Island
	local islandDragging = false
	local islandDragStartY = 0
	local islandMoved = false

	connect(IslandCompactRow.MouseEnter, function()
		if not IsIslandExpanded then
			islandW.Target = 134
			islandH.Target = 32
		end
	end)
	connect(IslandCompactRow.MouseLeave, function()
		if not IsIslandExpanded and not islandDragging then
			islandW.Target = 120
			islandH.Target = 30
		end
	end)
	connect(IslandCompactRow.InputBegan, function(input: InputObject)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			islandDragging = true
			islandMoved = false
			islandDragStartY = input.Position.Y
		end
	end)
	connect(UserInputService.InputChanged, function(input: InputObject)
		if islandDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local dy = input.Position.Y - islandDragStartY
			if math.abs(dy) > 8 then
				islandMoved = true
			end
			if not IsIslandExpanded and dy > 0 then
				local pull = math.min(dy * 0.65, 76)
				islandH.Target = 30 + pull
				islandW.Target = 120 + pull * 1.85
				if pull > 24 then
					IslandExpandedBody.Visible = true
					IslandExpandedBody.GroupTransparency = math.clamp(1 - (pull - 24) / 40, 0, 1)
				end
			elseif IsIslandExpanded and dy < 0 then
				local pullUp = math.min(-dy * 0.65, 68)
				islandH.Target = 102 - pullUp
				islandW.Target = 264 - pullUp * 1.85
			end
		end
	end)

	-- ============================================================================
	-- 8. MAIN LIQUID GLASS WINDOW (CONCENTRIC ROUNDING VIA CANVASGROUP!)
	-- ============================================================================
	local WindowShadow = create("Frame", {
		Name = "Shadow",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 10),
		Size = UDim2.new(1, 22, 1, 22),
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 0.72,
		BorderSizePixel = 0,
		ZIndex = 9,
	}, MainWindowHolder)
	addCorner(WindowShadow, 26)

	-- CanvasGroup masks EVERY child cleanly to the exact 18px rounded corners!
	local WindowFrame = create("CanvasGroup", {
		Name = "WindowFrame",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Themes[currentThemeName].WindowBg,
		BackgroundTransparency = Themes[currentThemeName].WindowTrans,
		GroupTransparency = 0,
		BorderSizePixel = 0,
		ZIndex = 10,
	}, MainWindowHolder)
	addCorner(WindowFrame, 18)
	local WindowOuterStroke = addStroke(WindowFrame, Themes[currentThemeName].OuterStroke, 1.25, Themes[currentThemeName].OuterStrokeTrans)

	-- Specular Diagonal Crystal Glass Sheen
	local GlassSheen = create("Frame", {
		Name = "GlassSheen",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		ZIndex = 11,
	}, WindowFrame)
	addCorner(GlassSheen, 18)
	local GlassSheenGrad = create("UIGradient", {
		Rotation = 132,
		Color = ColorSequence.new(Color3.fromRGB(255, 255, 255)),
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0.00, 0.88),
			NumberSequenceKeypoint.new(0.18, 0.96),
			NumberSequenceKeypoint.new(0.38, 0.91),
			NumberSequenceKeypoint.new(0.55, 0.99),
			NumberSequenceKeypoint.new(0.82, 0.97),
			NumberSequenceKeypoint.new(1.00, 0.90),
		}),
	}, GlassSheen)

	-- Top Specular Edge Reflection Streak
	local TopGlassLine = create("Frame", {
		Position = UDim2.new(0, 20, 0, 1),
		Size = UDim2.new(1, -40, 0, 1),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 0.62,
		BorderSizePixel = 0,
		ZIndex = 12,
	}, WindowFrame)
	create("UIGradient", {
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.25, 0.25),
			NumberSequenceKeypoint.new(0.5, 0.05),
			NumberSequenceKeypoint.new(0.75, 0.25),
			NumberSequenceKeypoint.new(1, 1),
		}),
	}, TopGlassLine)

	local WindowInterior = create("Frame", {
		Name = "Interior",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ZIndex = 15,
	}, WindowFrame)

	-- Drag Bar (Top area of window)
	local DragZone = create("Frame", {
		Name = "DragZone",
		Size = UDim2.new(1, 0, 0, 50),
		BackgroundTransparency = 1,
		ZIndex = 16,
	}, WindowInterior)

	-- ============================================================================
	-- 8B. FLOATING CONCENTRIC SIDEBAR + ROBLOX PROFILE CARD (FIX #1 & #4!)
	-- ============================================================================
	local Sidebar = create("Frame", {
		Name = "Sidebar",
		Position = UDim2.fromOffset(8, 8),
		Size = UDim2.new(0, 182, 1, -16),
		BackgroundColor3 = Themes[currentThemeName].SidebarBg,
		BackgroundTransparency = Themes[currentThemeName].SidebarTrans,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		ZIndex = 18,
	}, WindowInterior)
	local SidebarCorner = addCorner(Sidebar, 12)
	local SidebarStroke = addStroke(Sidebar, Themes[currentThemeName].Stroke, 1, Themes[currentThemeName].StrokeTrans)

	-- Brand Header (Cleanly clipped inside Sidebar — NEVER overflows!)
	local BrandHeader = create("Frame", {
		Name = "BrandHeader",
		Position = UDim2.fromOffset(10, 10),
		Size = UDim2.new(1, -20, 0, 34),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		ZIndex = 22,
	}, Sidebar)

	-- macOS Traffic Light Buttons
	local TrafficRow = create("Frame", {
		Position = UDim2.fromOffset(0, 4),
		Size = UDim2.fromOffset(46, 14),
		BackgroundTransparency = 1,
		ZIndex = 23,
	}, BrandHeader)
	create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 6),
	}, TrafficRow)

	local function makeTrafficDot(color: Color3, onClick: () -> ())
		local dot = create("TextButton", {
			Size = UDim2.fromOffset(11, 11),
			BackgroundColor3 = color,
			BorderSizePixel = 0,
			Text = "",
			AutoButtonColor = false,
			ZIndex = 24,
		}, TrafficRow)
		addCorner(dot, 999)
		local sc = create("UIScale", { Scale = 1 }, dot)
		connect(dot.MouseEnter, function()
			tween(sc, 0.16, { Scale = 1.24 }, Enum.EasingStyle.Back)
		end)
		connect(dot.MouseLeave, function()
			tween(sc, 0.18, { Scale = 1 })
		end)
		connect(dot.MouseButton1Click, function()
			tween(sc, 0.10, { Scale = 0.82 })
			task.delay(0.10, function()
				tween(sc, 0.20, { Scale = 1 }, Enum.EasingStyle.Back)
			end)
			onClick()
		end)
		return dot
	end

	local BrandTitle = create("TextLabel", {
		Position = UDim2.fromOffset(52, 0),
		Size = UDim2.new(1, -54, 0, 16),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Text = titleText,
		TextSize = 13,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = Themes[currentThemeName].TextPrimary,
		ZIndex = 23,
	}, BrandHeader)

	local BrandSub = create("TextLabel", {
		Position = UDim2.fromOffset(52, 16),
		Size = UDim2.new(1, -54, 0, 13),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Text = subTitleText,
		TextSize = 10,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = Themes[currentThemeName].TextSecondary,
		ZIndex = 23,
	}, BrandHeader)

	-- LIVE ROBLOX PROFILE CARD (Avatar + DisplayName/Username + Current Game Name!)
	local ProfileCard = create("Frame", {
		Name = "ProfileCard",
		Position = UDim2.fromOffset(8, 50),
		Size = UDim2.new(1, -16, 0, 50),
		BackgroundColor3 = Themes[currentThemeName].ProfileBg,
		BackgroundTransparency = Themes[currentThemeName].ProfileTrans,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		ZIndex = 21,
	}, Sidebar)
	addCorner(ProfileCard, 10)
	local ProfileStroke = addStroke(ProfileCard, Themes[currentThemeName].Stroke, 1, Themes[currentThemeName].StrokeTrans)

	local AvatarRing = create("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 8, 0.5, 0),
		Size = UDim2.fromOffset(34, 34),
		BackgroundColor3 = Themes[currentThemeName].ControlBg,
		BackgroundTransparency = 0.25,
		BorderSizePixel = 0,
		ZIndex = 22,
	}, ProfileCard)
	addCorner(AvatarRing, 999)
	local AvatarStroke = addStroke(AvatarRing, Themes[currentThemeName].Accent, 1.3, 0.35)

	local AvatarImage = create("ImageLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(1, -2, 1, -2),
		BackgroundTransparency = 1,
		Image = "",
		ScaleType = Enum.ScaleType.Crop,
		ZIndex = 23,
	}, AvatarRing)
	addCorner(AvatarImage, 999)

	local AvatarOnlineDot = create("Frame", {
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, 1, 1, 1),
		Size = UDim2.fromOffset(9, 9),
		BackgroundColor3 = Color3.fromRGB(52, 211, 153),
		BorderSizePixel = 0,
		ZIndex = 24,
	}, AvatarRing)
	addCorner(AvatarOnlineDot, 999)
	addStroke(AvatarOnlineDot, Themes[currentThemeName].SidebarBg, 1.8, 0)

	local ProfileNameLbl = create("TextLabel", {
		Position = UDim2.fromOffset(48, 8),
		Size = UDim2.new(1, -54, 0, 16),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Text = LocalPlayer.DisplayName or LocalPlayer.Name,
		TextSize = 11,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = Themes[currentThemeName].TextPrimary,
		ZIndex = 22,
	}, ProfileCard)

	local ProfileGameLbl = create("TextLabel", {
		Position = UDim2.fromOffset(48, 25),
		Size = UDim2.new(1, -54, 0, 14),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		Text = "Loading game...",
		TextSize = 10,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = Themes[currentThemeName].TextSecondary,
		ZIndex = 22,
	}, ProfileCard)

	-- Async fetch real Roblox Avatar & Current Place Name (Never blocks UI!)
	task.spawn(function()
		local okThumb, thumbUrl = pcall(function()
			return Players:GetUserThumbnailAsync(
				LocalPlayer.UserId,
				Enum.ThumbnailType.HeadShot,
				Enum.ThumbnailSize.Size100x100
			)
		end)
		if okThumb and type(thumbUrl) == "string" and AvatarImage.Parent then
			AvatarImage.Image = thumbUrl
		end

		local okInfo, info = pcall(function()
			return MarketplaceService:GetProductInfo(game.PlaceId)
		end)
		if ProfileGameLbl.Parent then
			if okInfo and info and info.Name then
				ProfileGameLbl.Text = info.Name
			else
				ProfileGameLbl.Text = "@" .. LocalPlayer.Name
			end
		end
	end)

	-- ============================================================================
	-- 8C. TAB LIST + SPRING-GLIDING LIQUID GLASS ACTIVE PILL (FIX #5!)
	--     ActiveTabPill is a SIBLING of TabListHolder so UIListLayout NEVER traps it!
	-- ============================================================================
	local TabScroll = create("ScrollingFrame", {
		Name = "TabScroll",
		Position = UDim2.fromOffset(8, 108),
		Size = UDim2.new(1, -16, 1, -116),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 0,
		AutomaticCanvasSize = Enum.AutomaticSize.XY,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ClipsDescendants = true,
		ZIndex = 19,
	}, Sidebar)

	-- Floating Animated Liquid Glass Active Tab Pill (Glides smoothly!)
	local ActiveTabPill = create("Frame", {
		Name = "ActiveTabPill",
		Size = UDim2.fromOffset(166, 36),
		Position = UDim2.fromOffset(0, 0),
		BackgroundColor3 = Themes[currentThemeName].TabActiveBg,
		BackgroundTransparency = Themes[currentThemeName].TabActiveTrans,
		BorderSizePixel = 0,
		Visible = false,
		ZIndex = 20,
	}, TabScroll)
	addCorner(ActiveTabPill, 10)
	local ActiveTabPillStroke = addStroke(ActiveTabPill, Themes[currentThemeName].Stroke, 1, Themes[currentThemeName].StrokeTrans)

	-- Subtle Liquid Glass Sheen inside Active Tab Pill
	local ActiveTabSheen = create("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 0.88,
		BorderSizePixel = 0,
		ZIndex = 20,
	}, ActiveTabPill)
	addCorner(ActiveTabSheen, 10)
	create("UIGradient", {
		Rotation = 90,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.35),
			NumberSequenceKeypoint.new(0.55, 0.92),
			NumberSequenceKeypoint.new(1, 1),
		}),
	}, ActiveTabSheen)

	-- Glowing Accent Edge Indicator Bar on Active Tab Pill
	local ActiveTabAccent = create("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 3, 0.5, 0),
		Size = UDim2.fromOffset(3, 18),
		BackgroundColor3 = Themes[currentThemeName].Accent,
		BorderSizePixel = 0,
		ZIndex = 21,
	}, ActiveTabPill)
	addCorner(ActiveTabAccent, 999)

	-- Tab Buttons Holder (Owns UIListLayout — Completely separate from ActiveTabPill!)
	local TabListHolder = create("Frame", {
		Name = "TabListHolder",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundTransparency = 1,
		ZIndex = 22,
	}, TabScroll)

	local TabListLayout = create("UIListLayout", {
		FillDirection = Enum.FillDirection.Vertical,
		Padding = UDim.new(0, 5),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, TabListHolder)

	local pillX = registerSpring(0, 340, 26, function(v)
		ActiveTabPill.Position = UDim2.fromOffset(math.round(v), ActiveTabPill.Position.Y.Offset)
	end)
	local pillY = registerSpring(0, 340, 26, function(v)
		ActiveTabPill.Position = UDim2.fromOffset(ActiveTabPill.Position.X.Offset, math.round(v))
	end)
	local pillW = registerSpring(166, 340, 26, function(v)
		ActiveTabPill.Size = UDim2.fromOffset(math.round(v), ActiveTabPill.Size.Y.Offset)
	end)
	local pillH = registerSpring(36, 340, 26, function(v)
		ActiveTabPill.Size = UDim2.fromOffset(ActiveTabPill.Size.X.Offset, math.round(v))
	end)

	-- ============================================================================
	-- 8D. MAIN CONTENT PANE + HEADER (STATUS PILL MORPH + 3 VECTOR BUTTONS!)
	-- ============================================================================
	local ContentPane = create("Frame", {
		Name = "ContentPane",
		Position = UDim2.fromOffset(198, 0),
		Size = UDim2.new(1, -198, 1, 0),
		BackgroundTransparency = 1,
		ZIndex = 17,
	}, WindowInterior)

	local PageHeader = create("Frame", {
		Name = "PageHeader",
		Position = UDim2.fromOffset(14, 12),
		Size = UDim2.new(1, -28, 0, 38),
		BackgroundTransparency = 1,
		ZIndex = 40,
	}, ContentPane)

	local PageTitleLabel = create("TextLabel", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 2, 0.5, 0),
		Size = UDim2.fromOffset(150, 28),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Text = "Main",
		TextSize = 18,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = Themes[currentThemeName].TextPrimary,
		ZIndex = 41,
	}, PageHeader)

	-- ------------------------------------------------------------------------
	-- IN-PLACE MORPHING STATUS PILL (FIX #6: EXPANDS ITSELF + VECTOR X CLOSE!)
	-- ------------------------------------------------------------------------
	local StatusPill = create("Frame", {
		Name = "StatusPill",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -108, 0, 5),
		Size = UDim2.fromOffset(118, 28),
		BackgroundColor3 = Themes[currentThemeName].StatusBg,
		BackgroundTransparency = 0.14,
		ClipsDescendants = true,
		ZIndex = 65,
	}, PageHeader)
	local StatusPillCorner = addCorner(StatusPill, 14)
	local StatusPillStroke = addStroke(StatusPill, Themes[currentThemeName].StatusDot, 1.1, 0.65)

	-- Compact Clickable Header inside StatusPill
	local StatusTopBtn = create("TextButton", {
		Name = "TopHit",
		Size = UDim2.new(1, 0, 0, 28),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		ZIndex = 67,
	}, StatusPill)

	local StatusDot = create("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 11, 0.5, 0),
		Size = UDim2.fromOffset(7, 7),
		BackgroundColor3 = Themes[currentThemeName].StatusDot,
		BorderSizePixel = 0,
		ZIndex = 68,
	}, StatusTopBtn)
	addCorner(StatusDot, 999)

	local StatusText = create("TextLabel", {
		Position = UDim2.fromOffset(24, 0),
		Size = UDim2.new(1, -34, 1, 0),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamSemibold,
		Text = "Running · 00:00",
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = Themes[currentThemeName].StatusText,
		ZIndex = 68,
	}, StatusTopBtn)

	-- Vector X Button inside Expanded StatusPill (To collapse back in-place!)
	local StatusCloseBtn = create("TextButton", {
		Name = "CloseStatusBtn",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -7, 0.5, 0),
		Size = UDim2.fromOffset(20, 20),
		BackgroundColor3 = Themes[currentThemeName].ControlBg,
		BackgroundTransparency = 0.35,
		Text = "",
		Visible = false,
		AutoButtonColor = false,
		ZIndex = 70,
	}, StatusTopBtn)
	addCorner(StatusCloseBtn, 999)
	local StatusCloseIcon = createVectorIcon("close", StatusCloseBtn, Themes[currentThemeName].TextPrimary, 71)
	bindPressSquish(StatusCloseBtn, StatusCloseBtn, 0.86)

	connect(StatusCloseBtn.MouseEnter, function()
		tween(StatusCloseBtn, 0.16, { BackgroundTransparency = 0.12 })
		tween(StatusCloseIcon.Root, 0.22, { Rotation = 90 }, Enum.EasingStyle.Back)
	end)
	connect(StatusCloseBtn.MouseLeave, function()
		tween(StatusCloseBtn, 0.18, { BackgroundTransparency = 0.35 })
		tween(StatusCloseIcon.Root, 0.22, { Rotation = 0 })
	end)

	-- Live Telemetry Grid INSIDE StatusPill (Reveals when pill expands in-place!)
	local StatusTelemetryBody = create("CanvasGroup", {
		Name = "TelemetryBody",
		Position = UDim2.fromOffset(10, 34),
		Size = UDim2.new(1, -20, 0, 56),
		BackgroundTransparency = 1,
		GroupTransparency = 1,
		Visible = false,
		ZIndex = 67,
	}, StatusPill)
	create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 7),
	}, StatusTelemetryBody)

	local LiveFpsValLbl: TextLabel
	local LivePingValLbl: TextLabel
	local LiveSessValLbl: TextLabel
	local StatBoxRefs: { { Box: Frame, Title: TextLabel, Val: TextLabel, Stroke: UIStroke } } = {}

	local function createStatTile(label: string, defaultVal: string): TextLabel
		local t = Themes[currentThemeName]
		local box = create("Frame", {
			Size = UDim2.fromOffset(74, 50),
			BackgroundColor3 = t.CardBg,
			BackgroundTransparency = 0.28,
			ZIndex = 68,
		}, StatusTelemetryBody)
		addCorner(box, 9)
		local st = addStroke(box, t.Stroke, 1, t.StrokeTrans)

		local titleL = create("TextLabel", {
			Position = UDim2.fromOffset(8, 7),
			Size = UDim2.new(1, -14, 0, 13),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamMedium,
			Text = label,
			TextSize = 10,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = t.TextSecondary,
			ZIndex = 69,
		}, box)

		local valL = create("TextLabel", {
			Position = UDim2.fromOffset(8, 23),
			Size = UDim2.new(1, -14, 0, 20),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Text = defaultVal,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = t.TextPrimary,
			ZIndex = 69,
		}, box)

		table.insert(StatBoxRefs, { Box = box, Title = titleL, Val = valL, Stroke = st })
		return valL
	end

	LiveFpsValLbl = createStatTile("FPS", "60")
	LivePingValLbl = createStatTile("Ping", "32ms")
	LiveSessValLbl = createStatTile("Session", "00:00")

	local statusW = registerSpring(118, 300, 24, function(v)
		StatusPill.Size = UDim2.fromOffset(math.round(v), StatusPill.Size.Y.Offset)
	end)
	local statusH = registerSpring(28, 300, 24, function(v)
		StatusPill.Size = UDim2.fromOffset(StatusPill.Size.X.Offset, math.round(v))
	end)

	local function setStatusExpanded(expanded: boolean)
		if IsStatusExpanded == expanded then
			return
		end
		IsStatusExpanded = expanded
		local t = Themes[currentThemeName]

		if expanded then
			StatusTelemetryBody.Visible = true
			StatusCloseBtn.Visible = true
			StatusText.Text = "Running Live Telemetry"
			statusW.Target = 256
			statusH.Target = 100
			tween(StatusPill, 0.28, {
				BackgroundColor3 = t.StatusExpandedBg,
				BackgroundTransparency = 0.05,
			})
			tween(StatusPillCorner, 0.28, { CornerRadius = UDim.new(0, 15) })
			tween(StatusPillStroke, 0.28, { Color = t.Stroke, Transparency = t.StrokeTrans })
			task.delay(0.06, function()
				if IsStatusExpanded then
					tween(StatusTelemetryBody, 0.22, { GroupTransparency = 0 })
				end
			end)
		else
			local elapsed = math.floor(os.clock() - SessionStart)
			StatusText.Text = string.format("Running · %02d:%02d", math.floor(elapsed / 60), elapsed % 60)
			tween(StatusTelemetryBody, 0.14, { GroupTransparency = 1 })
			statusW.Target = 118
			statusH.Target = 28
			tween(StatusPill, 0.26, {
				BackgroundColor3 = t.StatusBg,
				BackgroundTransparency = 0.14,
			})
			tween(StatusPillCorner, 0.26, { CornerRadius = UDim.new(0, 14) })
			tween(StatusPillStroke, 0.26, { Color = t.StatusDot, Transparency = 0.65 })
			task.delay(0.16, function()
				if not IsStatusExpanded then
					StatusTelemetryBody.Visible = false
					StatusCloseBtn.Visible = false
				end
			end)
		end
	end

	connect(StatusCloseBtn.MouseButton1Click, function()
		spawnRipple(StatusCloseBtn)
		setStatusExpanded(false)
	end)

	-- ------------------------------------------------------------------------
	-- ACTION CLUSTER: 3 CRISP VECTOR BUTTONS (SEARCH / THEME / MENU) (FIX #2!)
	-- ------------------------------------------------------------------------
	local ActionCluster = create("Frame", {
		Name = "ActionCluster",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 5),
		Size = UDim2.fromOffset(100, 28),
		BackgroundColor3 = Themes[currentThemeName].ControlBg,
		BackgroundTransparency = 0.22,
		ClipsDescendants = true,
		ZIndex = 45,
	}, PageHeader)
	addCorner(ActionCluster, 14)
	local ActionClusterStroke = addStroke(ActionCluster, Themes[currentThemeName].Stroke, 1, Themes[currentThemeName].StrokeTrans)

	local ActionIconRefs: { { Btn: TextButton, Icon: { Root: Frame, SetColor: (Color3) -> (), Parts: { Instance } } } } = {}

	local function makeVectorActionBtn(iconName: string, xPos: number, onHoverAnim: (Frame, boolean) -> (), onClick: (Frame) -> ())
		local btn = create("TextButton", {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, xPos, 0.5, 0),
			Size = UDim2.fromOffset(28, 24),
			BackgroundColor3 = Themes[currentThemeName].TabActiveBg,
			BackgroundTransparency = 1,
			Text = "",
			AutoButtonColor = false,
			ZIndex = 46,
		}, ActionCluster)
		addCorner(btn, 12)
		bindPressSquish(btn, btn, 0.86)

		local vec = createVectorIcon(iconName, btn, Themes[currentThemeName].TextSecondary, 47)
		table.insert(ActionIconRefs, { Btn = btn, Icon = vec })

		connect(btn.MouseEnter, function()
			local t = Themes[currentThemeName]
			tween(btn, 0.16, { BackgroundTransparency = 0.84 })
			vec.SetColor(t.TextPrimary)
			onHoverAnim(vec.Root, true)
		end)
		connect(btn.MouseLeave, function()
			local t = Themes[currentThemeName]
			tween(btn, 0.18, { BackgroundTransparency = 1 })
			vec.SetColor(t.TextSecondary)
			onHoverAnim(vec.Root, false)
		end)
		connect(btn.MouseButton1Click, function()
			spawnRipple(btn)
			onClick(vec.Root)
		end)
		return btn, vec
	end

	-- Search Input inside Morphing ActionCluster
	local SearchBox = create("TextBox", {
		Position = UDim2.fromOffset(32, 0),
		Size = UDim2.new(1, -60, 1, 0),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		PlaceholderText = "Search features...",
		Text = "",
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = Themes[currentThemeName].TextPrimary,
		PlaceholderColor3 = Themes[currentThemeName].TextMuted,
		ClearTextOnFocus = false,
		Visible = false,
		ZIndex = 48,
	}, ActionCluster)

	local SearchCloseBtn = create("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -4, 0.5, 0),
		Size = UDim2.fromOffset(22, 22),
		BackgroundTransparency = 1,
		Text = "",
		Visible = false,
		AutoButtonColor = false,
		ZIndex = 48,
	}, ActionCluster)
	local SearchCloseVec = createVectorIcon("close", SearchCloseBtn, Themes[currentThemeName].TextSecondary, 49)
	bindPressSquish(SearchCloseBtn, SearchCloseBtn, 0.85)

	-- Pages Scrolling Container
	local PagesHolder = create("Frame", {
		Name = "PagesHolder",
		Position = UDim2.fromOffset(12, 54),
		Size = UDim2.new(1, -24, 1, -64),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		ZIndex = 18,
	}, ContentPane)

	-- ============================================================================
	-- 9. WINDOW VISIBILITY, DRAGGING & POPOVER CLEANUP
	-- ============================================================================
	local windowScaleSpring = registerSpring(0.84, 280, 23, function(v)
		WindowScale.Scale = math.max(0.01, v)
	end)

	local function closeAllPopovers()
		if ActiveDropdownClose then
			ActiveDropdownClose()
			ActiveDropdownClose = nil
		end
	end

	local function setWindowVisible(open: boolean)
		IsWindowOpen = open
		closeAllPopovers()
		if not open and IsStatusExpanded then
			setStatusExpanded(false)
		end
		local targetScale = getResponsiveScale()

		if open then
			MainWindowHolder.Visible = true
			windowScaleSpring.Target = targetScale
			tween(WindowFrame, 0.30, { GroupTransparency = 0 })
			tween(WindowShadow, 0.30, { BackgroundTransparency = 0.72 })
		else
			windowScaleSpring.Target = targetScale * 0.86
			tween(WindowFrame, 0.22, { GroupTransparency = 1 })
			tween(WindowShadow, 0.20, { BackgroundTransparency = 1 })
			task.delay(0.24, function()
				if not IsWindowOpen then
					MainWindowHolder.Visible = false
				end
			end)
		end
	end

	-- Dynamic Island Release Handler (Tap when collapsed = Toggle GUI!)
	connect(UserInputService.InputEnded, function(input: InputObject)
		if islandDragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
			islandDragging = false
			if islandMoved then
				local dy = input.Position.Y - islandDragStartY
				if not IsIslandExpanded and dy > 24 then
					setIslandExpanded(true)
				elseif IsIslandExpanded and dy < -18 then
					setIslandExpanded(false)
				else
					setIslandExpanded(IsIslandExpanded)
				end
			else
				-- Only toggle Main GUI when tapping collapsed Dynamic Island!
				if not IsIslandExpanded then
					spawnRipple(IslandFrame)
					islandW.Target = 112
					task.delay(0.08, function()
						if not IsIslandExpanded then
							islandW.Target = 120
						end
					end)
					setWindowVisible(not IsWindowOpen)
				end
			end
		end
	end)

	-- Inertial Window Dragging
	local draggingWin = false
	local dragStartPos = Vector2.zero
	local winStartOffset = Vector2.zero
	local winPosX = registerSpring(0, 260, 25, function(v)
		MainWindowHolder.Position = UDim2.new(0.5, math.round(v), 0.52, MainWindowHolder.Position.Y.Offset)
	end)
	local winPosY = registerSpring(0, 260, 25, function(v)
		MainWindowHolder.Position = UDim2.new(0.5, MainWindowHolder.Position.X.Offset, 0.52, math.round(v))
	end)

	connect(DragZone.InputBegan, function(input: InputObject)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			draggingWin = true
			dragStartPos = Vector2.new(input.Position.X, input.Position.Y)
			winStartOffset = Vector2.new(winPosX.Target, winPosY.Target)
			closeAllPopovers()
		end
	end)
	connect(UserInputService.InputChanged, function(input: InputObject)
		if draggingWin and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = Vector2.new(input.Position.X, input.Position.Y) - dragStartPos
			winPosX.Target = winStartOffset.X + delta.X
			winPosY.Target = winStartOffset.Y + delta.Y
		end
	end)
	connect(UserInputService.InputEnded, function(input: InputObject)
		if draggingWin and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
			draggingWin = false
		end
	end)

	connect(UserInputService.InputBegan, function(input: InputObject, gpe: boolean)
		if not gpe and input.KeyCode == toggleKey then
			setWindowVisible(not IsWindowOpen)
		end
	end)

	-- ============================================================================
	-- 10. THEME ENGINE (LIQUID CROSSFADE BETWEEN DARK & WHITE GLASS)
	-- ============================================================================
	local function setTheme(themeName: string)
		local palette = Themes[themeName]
		if not palette then
			return
		end
		currentThemeName = themeName
		local d = 0.34
		for _, fn in ipairs(ThemeHandlers) do
			fn(palette, d)
		end
	end

	connect(IslandThemeBtn.MouseButton1Click, function()
		spawnRipple(IslandThemeBtn)
		setTheme(currentThemeName == "Light" and "Dark" or "Light")
	end)

	bindTheme(function(t, d)
		tween(WindowFrame, d, { BackgroundColor3 = t.WindowBg, BackgroundTransparency = t.WindowTrans })
		tween(WindowOuterStroke, d, { Color = t.OuterStroke, Transparency = t.OuterStrokeTrans })
		tween(Sidebar, d, { BackgroundColor3 = t.SidebarBg, BackgroundTransparency = t.SidebarTrans })
		tween(SidebarStroke, d, { Color = t.Stroke, Transparency = t.StrokeTrans })
		tween(ProfileCard, d, { BackgroundColor3 = t.ProfileBg, BackgroundTransparency = t.ProfileTrans })
		tween(ProfileStroke, d, { Color = t.Stroke, Transparency = t.StrokeTrans })
		tween(AvatarStroke, d, { Color = t.Accent })
		tween(ProfileNameLbl, d, { TextColor3 = t.TextPrimary })
		tween(ProfileGameLbl, d, { TextColor3 = t.TextSecondary })
		tween(BrandTitle, d, { TextColor3 = t.TextPrimary })
		tween(BrandSub, d, { TextColor3 = t.TextSecondary })
		tween(PageTitleLabel, d, { TextColor3 = t.TextPrimary })

		tween(ActiveTabPill, d, { BackgroundColor3 = t.TabActiveBg, BackgroundTransparency = t.TabActiveTrans })
		tween(ActiveTabPillStroke, d, { Color = t.Stroke, Transparency = t.StrokeTrans })
		tween(ActiveTabAccent, d, { BackgroundColor3 = t.Accent })

		tween(ActionCluster, d, { BackgroundColor3 = t.ControlBg })
		tween(ActionClusterStroke, d, { Color = t.Stroke, Transparency = t.StrokeTrans })
		tween(SearchBox, d, { TextColor3 = t.TextPrimary, PlaceholderColor3 = t.TextMuted })
		SearchCloseVec.SetColor(t.TextSecondary)
		for _, ref in ipairs(ActionIconRefs) do
			tween(ref.Btn, d, { BackgroundColor3 = t.TabActiveBg })
			ref.Icon.SetColor(t.TextSecondary)
		end

		tween(StatusPill, d, {
			BackgroundColor3 = IsStatusExpanded and t.StatusExpandedBg or t.StatusBg,
		})
		tween(StatusPillStroke, d, {
			Color = IsStatusExpanded and t.Stroke or t.StatusDot,
			Transparency = IsStatusExpanded and t.StrokeTrans or 0.65,
		})
		tween(StatusDot, d, { BackgroundColor3 = t.StatusDot })
		tween(StatusText, d, { TextColor3 = t.StatusText })
		tween(StatusCloseBtn, d, { BackgroundColor3 = t.ControlBg })
		StatusCloseIcon.SetColor(t.TextPrimary)
		for _, sb in ipairs(StatBoxRefs) do
			tween(sb.Box, d, { BackgroundColor3 = t.CardBg })
			tween(sb.Stroke, d, { Color = t.Stroke, Transparency = t.StrokeTrans })
			tween(sb.Title, d, { TextColor3 = t.TextSecondary })
			tween(sb.Val, d, { TextColor3 = t.TextPrimary })
		end

		-- Dynamic Island Theme Sync
		tween(IslandFrame, d, { BackgroundColor3 = t.IslandBg, BackgroundTransparency = t.IslandTrans })
		tween(IslandStroke, d, { Color = t.IslandStroke, Transparency = t.IslandStrokeTrans })
		tween(IslandLogoLabel, d, { TextColor3 = t.IslandText })
		tween(IslandStatsLabel, d, { TextColor3 = t.TextSecondary })
		tween(IslandCloseBtn, d, { BackgroundColor3 = t.ControlBg })
		IslandCloseIcon.SetColor(t.IslandText)
		tween(IslandThemeBtn, d, { BackgroundColor3 = t.ControlBg, TextColor3 = t.IslandText })
		tween(IslandThemeBtnStroke, d, { Color = t.Stroke, Transparency = t.StrokeTrans })
		IslandThemeBtn.Text = t.IsLight and "Chuyển Nền Đen" or "Chuyển Nền Trắng"

		GlassSheenGrad.Color = ColorSequence.new(t.Sheen)
		GlassSheenGrad.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0.00, t.SheenTransTop),
			NumberSequenceKeypoint.new(0.20, 0.96),
			NumberSequenceKeypoint.new(0.42, math.min(0.95, t.SheenTransTop + 0.06)),
			NumberSequenceKeypoint.new(0.60, 0.99),
			NumberSequenceKeypoint.new(1.00, math.min(0.96, t.SheenTransTop + 0.04)),
		})
	end)

	-- ============================================================================
	-- 11. POPOVER ENGINE (FOR DROPDOWNS & OVERFLOW MENU)
	-- ============================================================================
	local function openLiquidPopover(anchor: GuiObject, targetW: number, targetH: number, alignRight: boolean, buildFn: (CanvasGroup, () -> ()) -> ())
		closeAllPopovers()

		local theme = Themes[currentThemeName]
		local overlayPos = OverlayLayer.AbsolutePosition
		local anchorPos = anchor.AbsolutePosition - overlayPos
		local anchorSize = anchor.AbsoluteSize

		local posX = alignRight and (anchorPos.X + anchorSize.X - targetW) or anchorPos.X
		local posY = anchorPos.Y + anchorSize.Y + 6

		local vp = OverlayLayer.AbsoluteSize
		posX = math.clamp(posX, 12, math.max(12, vp.X - targetW - 12))
		posY = math.clamp(posY, 12, math.max(12, vp.Y - targetH - 12))

		local backdrop = create("TextButton", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Text = "",
			ZIndex = 205,
		}, OverlayLayer)

		local startX = alignRight and (anchorPos.X + anchorSize.X - 48) or anchorPos.X
		local popover = create("Frame", {
			Position = UDim2.fromOffset(startX, anchorPos.Y + anchorSize.Y * 0.5),
			Size = UDim2.fromOffset(48, 26),
			BackgroundColor3 = theme.PopoverBg,
			BackgroundTransparency = 0.25,
			ClipsDescendants = true,
			ZIndex = 210,
		}, OverlayLayer)
		local popCorner = addCorner(popover, 16)
		addStroke(popover, theme.Stroke, 1.1, theme.StrokeTrans)

		local innerGroup = create("CanvasGroup", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			GroupTransparency = 1,
			ZIndex = 211,
		}, popover)

		local closed = false
		local function closePopover()
			if closed then
				return
			end
			closed = true
			if ActiveDropdownClose == closePopover then
				ActiveDropdownClose = nil
			end
			tween(innerGroup, 0.14, { GroupTransparency = 1 })
			tween(popCorner, 0.22, { CornerRadius = UDim.new(0, 18) })
			local tw = tween(popover, 0.22, {
				Size = UDim2.fromOffset(44, 24),
				Position = UDim2.fromOffset(startX, anchorPos.Y + anchorSize.Y * 0.5),
				BackgroundTransparency = 1,
			}, Enum.EasingStyle.Back, Enum.EasingDirection.In)
			tw.Completed:Connect(function()
				backdrop:Destroy()
				popover:Destroy()
			end)
		end

		ActiveDropdownClose = closePopover
		connect(backdrop.MouseButton1Click, closePopover)

		buildFn(innerGroup, closePopover)

		tween(popover, 0.30, {
			Position = UDim2.fromOffset(posX, posY),
			Size = UDim2.fromOffset(targetW, targetH),
			BackgroundTransparency = theme.PopoverTrans,
		}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		tween(popCorner, 0.26, { CornerRadius = UDim.new(0, 13) })
		task.delay(0.05, function()
			if not closed then
				tween(innerGroup, 0.20, { GroupTransparency = 0 })
			end
		end)
	end

	-- ============================================================================
	-- 12. SEARCH MORPH, STATUS EXPAND & 3 ACTION VECTOR BUTTONS
	-- ============================================================================
	local SearchQuery = ""
	local AllRowFilters: { { Row: Frame, SearchText: string } } = {}

	local function applySearchFilter()
		local q = string.lower(SearchQuery)
		for _, item in ipairs(AllRowFilters) do
			if item.Row.Parent then
				item.Row.Visible = (q == "") or (string.find(item.SearchText, q, 1, true) ~= nil)
			end
		end
	end

	local SearchIconBtn: TextButton
	local ThemeIconBtn: TextButton
	local MenuIconBtn: TextButton
	local WindowAPI = {} :: any

	local function setSearchOpen(open: boolean)
		IsSearchOpen = open
		if open then
			if IsStatusExpanded then
				setStatusExpanded(false)
			end
			ThemeIconBtn.Visible = false
			MenuIconBtn.Visible = false
			SearchBox.Visible = true
			SearchCloseBtn.Visible = true
			tween(StatusPill, 0.24, { Position = UDim2.new(1, -214, 0, 5) })
			tween(ActionCluster, 0.30, { Size = UDim2.fromOffset(204, 28) }, Enum.EasingStyle.Back)
			task.delay(0.08, function()
				SearchBox:CaptureFocus()
			end)
		else
			SearchBox.Text = ""
			SearchQuery = ""
			applySearchFilter()
			SearchBox.Visible = false
			SearchCloseBtn.Visible = false
			tween(ActionCluster, 0.26, { Size = UDim2.fromOffset(100, 28) })
			tween(StatusPill, 0.26, { Position = UDim2.new(1, -108, 0, 5) })
			task.delay(0.10, function()
				if not IsSearchOpen then
					ThemeIconBtn.Visible = true
					MenuIconBtn.Visible = true
				end
			end)
		end
	end

	-- Tap on StatusPill -> Expand in-place!
	connect(StatusTopBtn.MouseButton1Click, function()
		if not IsStatusExpanded then
			if IsSearchOpen then
				setSearchOpen(false)
			end
			spawnRipple(StatusPill, Themes[currentThemeName].StatusDot)
			setStatusExpanded(true)
		end
	end)

	-- Button 1: Vector Search Icon
	SearchIconBtn = makeVectorActionBtn("search", 4, function(iconRoot, hovering)
		tween(iconRoot, 0.20, { Rotation = hovering and -10 or 0 }, Enum.EasingStyle.Back)
	end, function()
		if not IsSearchOpen then
			setSearchOpen(true)
		end
	end)

	-- Button 2: Vector Theme Toggle (Smooth 180° Spin Animation!)
	local themeSpinDeg = 0
	ThemeIconBtn = makeVectorActionBtn("theme", 36, function(iconRoot, hovering)
		tween(iconRoot, 0.22, { Rotation = themeSpinDeg + (hovering and 28 or 0) }, Enum.EasingStyle.Back)
	end, function(iconRoot)
		themeSpinDeg += 180
		tween(iconRoot, 0.42, { Rotation = themeSpinDeg }, Enum.EasingStyle.Back)
		setTheme(currentThemeName == "Light" and "Dark" or "Light")
	end)

	-- Button 3: Vector Menu Icon (Smooth Staggered Hover + Overflow Popover)
	MenuIconBtn = makeVectorActionBtn("menu", 68, function(iconRoot, hovering)
		tween(iconRoot, 0.20, { Rotation = hovering and 90 or 0 }, Enum.EasingStyle.Back)
	end, function()
		openLiquidPopover(MenuIconBtn, 174, 144, true, function(container, closeFn)
			local t = Themes[currentThemeName]
			local list = create("Frame", {
				Position = UDim2.fromOffset(6, 6),
				Size = UDim2.new(1, -12, 1, -12),
				BackgroundTransparency = 1,
				ZIndex = 212,
			}, container)
			create("UIListLayout", { Padding = UDim.new(0, 3) }, list)

			local options = {
				{
					Text = CompactRows and "Normal rows" or "Compact rows",
					Fn = function()
						CompactRows = not CompactRows
						WindowAPI:Notify("Layout", CompactRows and "Đã bật chế độ dòng gọn" or "Đã chuyển về dòng tiêu chuẩn")
					end,
				},
				{
					Text = t.IsLight and "Switch to Dark Glass" or "Switch to White Glass",
					Fn = function()
						setTheme(t.IsLight and "Dark" or "Light")
					end,
				},
				{
					Text = "Replay Hello Intro",
					Fn = function()
						WindowAPI:PlayIntro()
					end,
				},
				{
					Text = "Minimize to Island",
					Fn = function()
						setWindowVisible(false)
					end,
				},
			}

			for _, opt in ipairs(options) do
				local btn = create("TextButton", {
					Size = UDim2.new(1, 0, 0, 30),
					BackgroundColor3 = t.TabActiveBg,
					BackgroundTransparency = 1,
					Font = Enum.Font.GothamMedium,
					Text = "  " .. opt.Text,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextColor3 = t.TextPrimary,
					AutoButtonColor = false,
					ZIndex = 213,
				}, list)
				addCorner(btn, 8)
				bindPressSquish(btn, btn, 0.96)
				connect(btn.MouseEnter, function()
					tween(btn, 0.14, { BackgroundTransparency = 0.85 })
				end)
				connect(btn.MouseLeave, function()
					tween(btn, 0.16, { BackgroundTransparency = 1 })
				end)
				connect(btn.MouseButton1Click, function()
					spawnRipple(btn)
					closeFn()
					opt.Fn()
				end)
			end
		end)
	end)

	connect(SearchCloseBtn.MouseButton1Click, function()
		setSearchOpen(false)
	end)
	connect(SearchBox:GetPropertyChangedSignal("Text"), function()
		SearchQuery = SearchBox.Text
		applySearchFilter()
	end)

	-- Traffic Light Actions
	makeTrafficDot(Color3.fromRGB(255, 95, 86), function()
		setWindowVisible(false)
	end)
	makeTrafficDot(Color3.fromRGB(255, 189, 46), function()
		setWindowVisible(false)
	end)
	local isExpandedWin = false
	makeTrafficDot(Color3.fromRGB(39, 201, 63), function()
		isExpandedWin = not isExpandedWin
		tween(MainWindowHolder, 0.34, {
			Size = isExpandedWin and UDim2.fromOffset(728, 470) or UDim2.fromOffset(WIN_W, WIN_H),
		}, Enum.EasingStyle.Back)
	end)

	-- ============================================================================
	-- 13. TOAST NOTIFICATION SYSTEM
	-- ============================================================================
	function WindowAPI:Notify(nTitle: string, nDesc: string, duration: number?)
		local t = Themes[currentThemeName]
		local card = create("Frame", {
			Size = UDim2.fromOffset(278, 56),
			BackgroundColor3 = t.PopoverBg,
			BackgroundTransparency = 1,
			ClipsDescendants = true,
			ZIndex = 251,
		}, ToastContainer)
		addCorner(card, 13)
		addStroke(card, t.Stroke, 1, t.StrokeTrans)

		local sc = create("UIScale", { Scale = 0.88 }, card)

		local accentBar = create("Frame", {
			Position = UDim2.fromOffset(10, 12),
			Size = UDim2.fromOffset(4, 32),
			BackgroundColor3 = t.Accent,
			BorderSizePixel = 0,
			ZIndex = 252,
		}, card)
		addCorner(accentBar, 999)

		create("TextLabel", {
			Position = UDim2.fromOffset(22, 9),
			Size = UDim2.new(1, -32, 0, 18),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Text = nTitle,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = t.TextPrimary,
			ZIndex = 252,
		}, card)

		create("TextLabel", {
			Position = UDim2.fromOffset(22, 28),
			Size = UDim2.new(1, -32, 0, 16),
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			Text = nDesc,
			TextSize = 11,
			TextTruncate = Enum.TextTruncate.AtEnd,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = t.TextSecondary,
			ZIndex = 252,
		}, card)

		local prog = create("Frame", {
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.fromScale(0, 1),
			Size = UDim2.new(1, 0, 0, 2),
			BackgroundColor3 = t.Accent,
			BackgroundTransparency = 0.35,
			BorderSizePixel = 0,
			ZIndex = 253,
		}, card)

		tween(card, 0.28, { BackgroundTransparency = t.PopoverTrans })
		tween(sc, 0.32, { Scale = 1 }, Enum.EasingStyle.Back)

		local dur = duration or 2.8
		tween(prog, dur, { Size = UDim2.new(0, 0, 0, 2) }, Enum.EasingStyle.Linear)

		task.delay(dur, function()
			tween(sc, 0.22, { Scale = 0.88 })
			local tw = tween(card, 0.22, { BackgroundTransparency = 1, Size = UDim2.fromOffset(278, 0) })
			tw.Completed:Connect(function()
				card:Destroy()
			end)
		end)
	end

	-- ============================================================================
	-- 14. TAB SYSTEM + SMOOTH SPRING GLIDE + 5 LAYOUT POSITIONS
	-- ============================================================================
	local Tabs: { { Name: string, Button: TextButton, Page: ScrollingFrame, Label: TextLabel, Accent: Color3 } } = {}
	local ActiveTabIndex = 0

	local function moveActivePillTo(tabIndex: number, instant: boolean?)
		local tab = Tabs[tabIndex]
		if not tab then
			return
		end
		ActiveTabPill.Visible = true

		local tx, ty, tw, th = 0, 0, 166, 36
		local isHorizontal = (currentTabPos == "Top" or currentTabPos == "Bottom" or currentTabPos == "Dock")

		if not isHorizontal then
			-- Deterministic exact vertical geometry (100% glitch-free even while window scales!)
			local btnH = 36
			local pad = 5
			tx = 0
			ty = (tabIndex - 1) * (btnH + pad)
			tw = TabScroll.AbsoluteSize.X / math.max(WindowScale.Scale, 0.05)
			if tw < 80 then
				tw = 166
			end
			th = btnH
			ActiveTabAccent.AnchorPoint = Vector2.new(0, 0.5)
			ActiveTabAccent.Position = UDim2.new(0, 3, 0.5, 0)
			ActiveTabAccent.Size = UDim2.fromOffset(3, 18)
		else
			-- Horizontal layout exact reading
			local scale = math.max(WindowScale.Scale, 0.05)
			local relPos = tab.Button.AbsolutePosition - TabListHolder.AbsolutePosition
			tx = relPos.X / scale
			ty = relPos.Y / scale
			tw = tab.Button.AbsoluteSize.X / scale
			th = tab.Button.AbsoluteSize.Y / scale
			ActiveTabAccent.AnchorPoint = Vector2.new(0.5, 1)
			ActiveTabAccent.Position = UDim2.new(0.5, 0, 1, -2)
			ActiveTabAccent.Size = UDim2.fromOffset(22, 3)
		end

		tween(ActiveTabAccent, 0.25, { BackgroundColor3 = tab.Accent })

		if instant then
			pillX.Position, pillX.Target = tx, tx
			pillY.Position, pillY.Target = ty, ty
			pillW.Position, pillW.Target = tw, tw
			pillH.Position, pillH.Target = th, th
			ActiveTabPill.Position = UDim2.fromOffset(math.round(tx), math.round(ty))
			ActiveTabPill.Size = UDim2.fromOffset(math.round(tw), math.round(th))
		else
			pillX.Target = tx
			pillY.Target = ty
			pillW.Target = tw
			pillH.Target = th
		end
	end

	local function selectTab(index: number, instant: boolean?)
		local targetTab = Tabs[index]
		if not targetTab or ActiveTabIndex == index then
			return
		end
		closeAllPopovers()
		ActiveTabIndex = index

		local t = Themes[currentThemeName]
		PageTitleLabel.Text = targetTab.Name
		PageTitleLabel.Position = UDim2.new(0, -6, 0.5, 0)
		tween(PageTitleLabel, 0.24, { Position = UDim2.new(0, 2, 0.5, 0) })

		for i, tab in ipairs(Tabs) do
			local isSelected = (i == index)
			tween(tab.Label, 0.20, {
				TextColor3 = isSelected and t.TextPrimary or t.TextSecondary,
			})
			if isSelected then
				tab.Page.Visible = true
				if not instant then
					tab.Page.Position = UDim2.fromOffset(0, 14)
					tween(tab.Page, 0.30, { Position = UDim2.fromOffset(0, 0) }, Enum.EasingStyle.Quart)
				else
					tab.Page.Position = UDim2.fromOffset(0, 0)
				end
				task.defer(function()
					moveActivePillTo(index, instant)
				end)
			else
				tab.Page.Visible = false
			end
		end
	end

	local function setTabPosition(posName: string)
		currentTabPos = posName
		local dur = 0.32
		local isVert = (posName == "Left" or posName == "Right")
		ProfileCard.Visible = isVert
		BrandHeader.Visible = isVert

		if posName == "Left" then
			TabListLayout.FillDirection = Enum.FillDirection.Vertical
			TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
			TabListHolder.Size = UDim2.new(1, 0, 0, 0)
			tween(Sidebar, dur, { Position = UDim2.fromOffset(8, 8), Size = UDim2.new(0, 182, 1, -16) })
			tween(SidebarCorner, dur, { CornerRadius = UDim.new(0, 12) })
			tween(TabScroll, dur, { Position = UDim2.fromOffset(8, 108), Size = UDim2.new(1, -16, 1, -116) })
			tween(ContentPane, dur, { Position = UDim2.fromOffset(198, 0), Size = UDim2.new(1, -198, 1, 0) })
			for _, tab in ipairs(Tabs) do
				tween(tab.Button, dur, { Size = UDim2.new(1, 0, 0, 36) })
			end
		elseif posName == "Right" then
			TabListLayout.FillDirection = Enum.FillDirection.Vertical
			TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
			TabListHolder.Size = UDim2.new(1, 0, 0, 0)
			tween(Sidebar, dur, { Position = UDim2.new(1, -190, 0, 8), Size = UDim2.new(0, 182, 1, -16) })
			tween(SidebarCorner, dur, { CornerRadius = UDim.new(0, 12) })
			tween(TabScroll, dur, { Position = UDim2.fromOffset(8, 108), Size = UDim2.new(1, -16, 1, -116) })
			tween(ContentPane, dur, { Position = UDim2.fromOffset(0, 0), Size = UDim2.new(1, -198, 1, 0) })
			for _, tab in ipairs(Tabs) do
				tween(tab.Button, dur, { Size = UDim2.new(1, 0, 0, 36) })
			end
		elseif posName == "Top" then
			TabListLayout.FillDirection = Enum.FillDirection.Horizontal
			TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
			TabListHolder.Size = UDim2.new(0, 0, 1, 0)
			tween(Sidebar, dur, { Position = UDim2.fromOffset(8, 8), Size = UDim2.new(1, -16, 0, 44) })
			tween(SidebarCorner, dur, { CornerRadius = UDim.new(0, 12) })
			tween(TabScroll, dur, { Position = UDim2.fromOffset(8, 5), Size = UDim2.new(1, -16, 0, 34) })
			tween(ContentPane, dur, { Position = UDim2.fromOffset(0, 56), Size = UDim2.new(1, 0, 1, -56) })
			for _, tab in ipairs(Tabs) do
				tween(tab.Button, dur, { Size = UDim2.fromOffset(112, 34) })
			end
		elseif posName == "Bottom" then
			TabListLayout.FillDirection = Enum.FillDirection.Horizontal
			TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
			TabListHolder.Size = UDim2.new(1, 0, 1, 0)
			tween(Sidebar, dur, { Position = UDim2.new(0, 8, 1, -52), Size = UDim2.new(1, -16, 0, 44) })
			tween(SidebarCorner, dur, { CornerRadius = UDim.new(0, 12) })
			tween(TabScroll, dur, { Position = UDim2.fromOffset(8, 5), Size = UDim2.new(1, -16, 0, 34) })
			tween(ContentPane, dur, { Position = UDim2.fromOffset(0, 0), Size = UDim2.new(1, 0, 1, -56) })
			for _, tab in ipairs(Tabs) do
				tween(tab.Button, dur, { Size = UDim2.fromOffset(108, 34) })
			end
		elseif posName == "Dock" then
			TabListLayout.FillDirection = Enum.FillDirection.Horizontal
			TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
			TabListHolder.Size = UDim2.new(1, 0, 1, 0)
			tween(Sidebar, dur, { Position = UDim2.new(0.5, -256, 1, -52), Size = UDim2.fromOffset(512, 42) })
			tween(SidebarCorner, dur, { CornerRadius = UDim.new(0, 18) })
			tween(TabScroll, dur, { Position = UDim2.fromOffset(8, 4), Size = UDim2.new(1, -16, 0, 34) })
			tween(ContentPane, dur, { Position = UDim2.fromOffset(0, 0), Size = UDim2.new(1, 0, 1, -58) })
			for _, tab in ipairs(Tabs) do
				tween(tab.Button, dur, { Size = UDim2.fromOffset(94, 34) })
			end
		end

		task.delay(0.36, function()
			if ActiveTabIndex > 0 then
				moveActivePillTo(ActiveTabIndex, false)
			end
		end)
	end

	-- ============================================================================
	-- 15. COMPONENT BUILDERS (100% VECTOR ICONS — ZERO MISSING GLYPHS!)
	-- ============================================================================
	function WindowAPI:AddTab(tabCfg: { Name: string, Icon: string?, Accent: Color3? })
		local tabName = tabCfg.Name or "Tab"
		local tabIcon = tabCfg.Icon or "home"
		local iconColor = tabCfg.Accent or Color3.fromRGB(96, 165, 250)
		local myIndex = #Tabs + 1

		local tabBtn = create("TextButton", {
			Name = "Tab_" .. tabName,
			Size = UDim2.new(1, 0, 0, 36),
			BackgroundTransparency = 1,
			Text = "",
			AutoButtonColor = false,
			LayoutOrder = myIndex,
			ZIndex = 23,
		}, TabListHolder)
		addCorner(tabBtn, 10)
		bindPressSquish(tabBtn, tabBtn, 0.96)

		local iconBg = create("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 11, 0.5, 0),
			Size = UDim2.fromOffset(22, 22),
			BackgroundColor3 = iconColor,
			BackgroundTransparency = 0.80,
			BorderSizePixel = 0,
			ZIndex = 24,
		}, tabBtn)
		addCorner(iconBg, 7)
		createVectorIcon(tabIcon, iconBg, iconColor, 25)

		local tabLabel = create("TextLabel", {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 41, 0.5, 0),
			Size = UDim2.new(1, -46, 1, 0),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamSemibold,
			Text = tabName,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			TextColor3 = Themes[currentThemeName].TextSecondary,
			ZIndex = 24,
		}, tabBtn)

		local page = create("ScrollingFrame", {
			Name = "Page_" .. tabName,
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 3,
			ScrollBarImageTransparency = 0.65,
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			Visible = false,
			ZIndex = 19,
		}, PagesHolder)
		create("UIListLayout", {
			Padding = UDim.new(0, 10),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}, page)
		create("UIPadding", {
			PaddingTop = UDim.new(0, 2),
			PaddingBottom = UDim.new(0, 14),
			PaddingLeft = UDim.new(0, 2),
			PaddingRight = UDim.new(0, 6),
		}, page)

		table.insert(Tabs, {
			Name = tabName,
			Button = tabBtn,
			Page = page,
			Label = tabLabel,
			Accent = iconColor,
		})

		bindTheme(function(t, d)
			tween(tabLabel, d, {
				TextColor3 = (ActiveTabIndex == myIndex) and t.TextPrimary or t.TextSecondary,
			})
			page.ScrollBarImageColor3 = t.TextMuted
		end)

		connect(tabBtn.MouseEnter, function()
			if ActiveTabIndex ~= myIndex then
				tween(tabLabel, 0.16, { TextColor3 = Themes[currentThemeName].TextPrimary })
			end
		end)
		connect(tabBtn.MouseLeave, function()
			if ActiveTabIndex ~= myIndex then
				tween(tabLabel, 0.18, { TextColor3 = Themes[currentThemeName].TextSecondary })
			end
		end)
		connect(tabBtn.MouseButton1Click, function()
			spawnRipple(tabBtn)
			selectTab(myIndex, false)
		end)

		if myIndex == 1 then
			selectTab(1, true)
		end

		local TabAPI = {}
		local sectionOrder = 0

		function TabAPI:AddSection(sectionName: string)
			sectionOrder += 1
			local secWrap = create("Frame", {
				Name = "Section_" .. sectionName,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				LayoutOrder = sectionOrder,
				ZIndex = 20,
			}, page)
			create("UIListLayout", {
				Padding = UDim.new(0, 6),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}, secWrap)

			local secTitle = create("TextLabel", {
				Size = UDim2.new(1, 0, 0, 18),
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamSemibold,
				Text = sectionName,
				TextSize = 11,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextColor3 = Themes[currentThemeName].TextSecondary,
				LayoutOrder = 0,
				ZIndex = 21,
			}, secWrap)

			bindTheme(function(t, d)
				tween(secTitle, d, { TextColor3 = t.TextSecondary })
			end)

			local SectionAPI = {}
			local itemOrder = 0

			local function makeRowCard(rTitle: string, rDesc: string?, rIcon: string?, rColor: Color3?)
				itemOrder += 1
				local row = create("Frame", {
					Name = "Row_" .. rTitle,
					Size = UDim2.new(1, 0, 0, rDesc and 52 or 44),
					BackgroundColor3 = Themes[currentThemeName].CardBg,
					BackgroundTransparency = Themes[currentThemeName].CardTrans,
					BorderSizePixel = 0,
					LayoutOrder = itemOrder,
					ZIndex = 21,
				}, secWrap)
				addCorner(row, 11)
				local rowStroke = addStroke(row, Themes[currentThemeName].Stroke, 1, Themes[currentThemeName].StrokeTrans)

				local badgeColor = rColor or Color3.fromRGB(96, 165, 250)
				local iconBox = create("Frame", {
					AnchorPoint = Vector2.new(0, 0.5),
					Position = UDim2.new(0, 11, 0.5, 0),
					Size = UDim2.fromOffset(30, 30),
					BackgroundColor3 = badgeColor,
					BackgroundTransparency = 0.82,
					BorderSizePixel = 0,
					ZIndex = 22,
				}, row)
				addCorner(iconBox, 9)
				addStroke(iconBox, badgeColor, 1, 0.65)
				createVectorIcon(rIcon or "farm", iconBox, badgeColor, 23)

				local titleLbl = create("TextLabel", {
					Position = UDim2.fromOffset(51, rDesc and 9 or 13),
					Size = UDim2.new(1, -182, 0, 17),
					BackgroundTransparency = 1,
					Font = Enum.Font.GothamSemibold,
					Text = rTitle,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextTruncate = Enum.TextTruncate.AtEnd,
					TextColor3 = Themes[currentThemeName].TextPrimary,
					ZIndex = 22,
				}, row)

				local descLbl: TextLabel? = nil
				if rDesc then
					descLbl = create("TextLabel", {
						Position = UDim2.fromOffset(51, 27),
						Size = UDim2.new(1, -182, 0, 14),
						BackgroundTransparency = 1,
						Font = Enum.Font.Gotham,
						Text = rDesc,
						TextSize = 10,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextTruncate = Enum.TextTruncate.AtEnd,
						TextColor3 = Themes[currentThemeName].TextSecondary,
						ZIndex = 22,
					}, row)
				end

				connect(row.MouseEnter, function()
					local t = Themes[currentThemeName]
					tween(row, 0.16, { BackgroundColor3 = t.CardHoverBg, BackgroundTransparency = t.CardHoverTrans })
					tween(rowStroke, 0.16, { Transparency = math.max(0.45, t.StrokeTrans - 0.12) })
				end)
				connect(row.MouseLeave, function()
					local t = Themes[currentThemeName]
					tween(row, 0.20, { BackgroundColor3 = t.CardBg, BackgroundTransparency = t.CardTrans })
					tween(rowStroke, 0.20, { Transparency = t.StrokeTrans })
				end)

				bindTheme(function(t, d)
					tween(row, d, { BackgroundColor3 = t.CardBg, BackgroundTransparency = t.CardTrans })
					tween(rowStroke, d, { Color = t.Stroke, Transparency = t.StrokeTrans })
					tween(titleLbl, d, { TextColor3 = t.TextPrimary })
					if descLbl then
						tween(descLbl, d, { TextColor3 = t.TextSecondary })
					end
				end)

				table.insert(AllRowFilters, {
					Row = row,
					SearchText = string.lower(rTitle .. " " .. (rDesc or "")),
				})

				return row
			end

			-- A. LIQUID SQUISH-AND-STRETCH TOGGLE
			function SectionAPI:AddToggle(opt: {
				Title: string,
				Desc: string?,
				Icon: string?,
				Color: Color3?,
				Default: boolean?,
				Callback: ((boolean) -> ())?,
			})
				local row = makeRowCard(opt.Title, opt.Desc, opt.Icon, opt.Color)
				local state = opt.Default == true

				local switchBtn = create("TextButton", {
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, -12, 0.5, 0),
					Size = UDim2.fromOffset(42, 24),
					BackgroundColor3 = state and Themes[currentThemeName].ToggleOn or Themes[currentThemeName].ToggleOff,
					Text = "",
					AutoButtonColor = false,
					ZIndex = 24,
				}, row)
				addCorner(switchBtn, 999)

				local knob = create("Frame", {
					AnchorPoint = Vector2.new(0, 0.5),
					Position = UDim2.new(0, state and 21 or 3, 0.5, 0),
					Size = UDim2.fromOffset(18, 18),
					BackgroundColor3 = Themes[currentThemeName].ToggleKnob,
					BorderSizePixel = 0,
					ZIndex = 25,
				}, switchBtn)
				addCorner(knob, 999)

				local knobX = registerSpring(state and 21 or 3, 380, 24, function(v)
					knob.Position = UDim2.new(0, math.round(v), 0.5, 0)
				end)
				local knobW = registerSpring(18, 420, 22, function(v)
					knob.Size = UDim2.fromOffset(math.round(v), 18)
				end)

				local function setState(newVal: boolean, fireCb: boolean?)
					state = newVal
					local t = Themes[currentThemeName]
					tween(switchBtn, 0.24, { BackgroundColor3 = state and t.ToggleOn or t.ToggleOff })
					knobW.Target = 25
					knobX.Target = state and 14 or 3
					task.delay(0.08, function()
						knobW.Target = 18
						knobX.Target = state and 21 or 3
					end)
					if fireCb and opt.Callback then
						task.spawn(opt.Callback, state)
					end
				end

				connect(switchBtn.MouseButton1Down, function()
					knobW.Target = 24
					if state then
						knobX.Target = 15
					end
				end)
				connect(switchBtn.MouseLeave, function()
					knobW.Target = 18
					knobX.Target = state and 21 or 3
				end)
				connect(switchBtn.MouseButton1Click, function()
					spawnRipple(row, state and Themes[currentThemeName].ToggleOff or Themes[currentThemeName].ToggleOn)
					setState(not state, true)
				end)

				bindTheme(function(t, d)
					tween(switchBtn, d, { BackgroundColor3 = state and t.ToggleOn or t.ToggleOff })
					tween(knob, d, { BackgroundColor3 = t.ToggleKnob })
				end)

				return {
					Set = function(_, v: boolean)
						setState(v, true)
					end,
					Get = function()
						return state
					end,
				}
			end

			-- B. SPRING FLUID SLIDER
			function SectionAPI:AddSlider(opt: {
				Title: string,
				Desc: string?,
				Icon: string?,
				Color: Color3?,
				Min: number,
				Max: number,
				Default: number?,
				Step: number?,
				Callback: ((number) -> ())?,
			})
				local row = makeRowCard(opt.Title, opt.Desc, opt.Icon, opt.Color)
				local minV = opt.Min or 0
				local maxV = opt.Max or 100
				local step = opt.Step or 1
				local curVal = math.clamp(opt.Default or minV, minV, maxV)

				local valLbl = create("TextLabel", {
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, -138, 0.5, 0),
					Size = UDim2.fromOffset(38, 18),
					BackgroundTransparency = 1,
					Font = Enum.Font.GothamBold,
					Text = tostring(curVal),
					TextSize = 11,
					TextXAlignment = Enum.TextXAlignment.Right,
					TextColor3 = Themes[currentThemeName].TextSecondary,
					ZIndex = 23,
				}, row)

				local trackHit = create("TextButton", {
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, -14, 0.5, 0),
					Size = UDim2.fromOffset(116, 24),
					BackgroundTransparency = 1,
					Text = "",
					AutoButtonColor = false,
					ZIndex = 24,
				}, row)

				local track = create("Frame", {
					AnchorPoint = Vector2.new(0, 0.5),
					Position = UDim2.new(0, 0, 0.5, 0),
					Size = UDim2.new(1, 0, 0, 5),
					BackgroundColor3 = Themes[currentThemeName].ToggleOff,
					BorderSizePixel = 0,
					ZIndex = 24,
				}, trackHit)
				addCorner(track, 999)

				local initAlpha = (curVal - minV) / math.max(maxV - minV, 0.001)
				local fill = create("Frame", {
					Size = UDim2.new(initAlpha, 0, 1, 0),
					BackgroundColor3 = Themes[currentThemeName].TextPrimary,
					BorderSizePixel = 0,
					ZIndex = 25,
				}, track)
				addCorner(fill, 999)

				local thumb = create("Frame", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.new(initAlpha, 0, 0.5, 0),
					Size = UDim2.fromOffset(14, 14),
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BorderSizePixel = 0,
					ZIndex = 26,
				}, track)
				addCorner(thumb, 999)
				local thumbHalo = addStroke(thumb, Themes[currentThemeName].TextPrimary, 2.5, 0.88)

				local thumbScale = create("UIScale", { Scale = 1 }, thumb)
				local alphaSpring = registerSpring(initAlpha, 340, 26, function(a)
					local ca = math.clamp(a, 0, 1)
					fill.Size = UDim2.new(ca, 0, 1, 0)
					thumb.Position = UDim2.new(ca, 0, 0.5, 0)
				end)

				local draggingSlider = false
				local function updateFromX(absX: number)
					local rel = math.clamp((absX - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
					local raw = minV + (maxV - minV) * rel
					local snapped = math.clamp(math.round(raw / step) * step, minV, maxV)
					alphaSpring.Target = (snapped - minV) / math.max(maxV - minV, 0.001)
					if snapped ~= curVal then
						curVal = snapped
						valLbl.Text = tostring(curVal)
						if opt.Callback then
							task.spawn(opt.Callback, curVal)
						end
					end
				end

				connect(trackHit.MouseEnter, function()
					tween(thumbScale, 0.16, { Scale = 1.18 }, Enum.EasingStyle.Back)
					tween(thumbHalo, 0.16, { Transparency = 0.65 })
				end)
				connect(trackHit.MouseLeave, function()
					if not draggingSlider then
						tween(thumbScale, 0.18, { Scale = 1 })
						tween(thumbHalo, 0.18, { Transparency = 0.88 })
					end
				end)
				connect(trackHit.InputBegan, function(input: InputObject)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						draggingSlider = true
						tween(thumbScale, 0.14, { Scale = 1.32 }, Enum.EasingStyle.Back)
						tween(valLbl, 0.14, { TextColor3 = Themes[currentThemeName].TextPrimary })
						updateFromX(input.Position.X)
					end
				end)
				connect(UserInputService.InputChanged, function(input: InputObject)
					if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
						updateFromX(input.Position.X)
					end
				end)
				connect(UserInputService.InputEnded, function(input: InputObject)
					if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
						draggingSlider = false
						tween(thumbScale, 0.20, { Scale = 1 })
						tween(thumbHalo, 0.20, { Transparency = 0.88 })
						tween(valLbl, 0.20, { TextColor3 = Themes[currentThemeName].TextSecondary })
					end
				end)

				bindTheme(function(t, d)
					tween(valLbl, d, { TextColor3 = t.TextSecondary })
					tween(track, d, { BackgroundColor3 = t.ToggleOff })
					tween(fill, d, { BackgroundColor3 = t.IsLight and t.TextPrimary or Color3.fromRGB(240, 242, 248) })
					tween(thumbHalo, d, { Color = t.TextPrimary })
				end)

				return {
					Set = function(_, v: number)
						curVal = math.clamp(v, minV, maxV)
						valLbl.Text = tostring(curVal)
						alphaSpring.Target = (curVal - minV) / math.max(maxV - minV, 0.001)
					end,
				}
			end

			-- C. LIQUID CAPSULE DROPDOWN (WITH VECTOR CHEVRON & CHECKMARK!)
			function SectionAPI:AddDropdown(opt: {
				Title: string,
				Desc: string?,
				Icon: string?,
				Color: Color3?,
				Options: { string },
				Default: string?,
				Callback: ((string) -> ())?,
			})
				local row = makeRowCard(opt.Title, opt.Desc, opt.Icon, opt.Color)
				local selected = opt.Default or opt.Options[1] or "None"

				local dropBtn = create("TextButton", {
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, -12, 0.5, 0),
					Size = UDim2.fromOffset(120, 28),
					BackgroundColor3 = Themes[currentThemeName].ControlBg,
					BackgroundTransparency = Themes[currentThemeName].ControlTrans,
					Text = "",
					AutoButtonColor = false,
					ZIndex = 24,
				}, row)
				addCorner(dropBtn, 9)
				local dropStroke = addStroke(dropBtn, Themes[currentThemeName].Stroke, 1, Themes[currentThemeName].StrokeTrans)
				bindPressSquish(dropBtn, dropBtn, 0.94)

				local valText = create("TextLabel", {
					Position = UDim2.fromOffset(10, 0),
					Size = UDim2.new(1, -28, 1, 0),
					BackgroundTransparency = 1,
					Font = Enum.Font.GothamMedium,
					Text = selected,
					TextSize = 11,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextTruncate = Enum.TextTruncate.AtEnd,
					TextColor3 = Themes[currentThemeName].TextPrimary,
					ZIndex = 25,
				}, dropBtn)

				local chevronHolder = create("Frame", {
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, -6, 0.5, 0),
					Size = UDim2.fromOffset(16, 16),
					BackgroundTransparency = 1,
					ZIndex = 25,
				}, dropBtn)
				local chevronVec = createVectorIcon("chevron", chevronHolder, Themes[currentThemeName].TextSecondary, 26)

				connect(dropBtn.MouseButton1Click, function()
					spawnRipple(dropBtn)
					tween(chevronVec.Root, 0.24, { Rotation = 180 })
					local menuH = math.min(#opt.Options * 31 + 12, 210)

					openLiquidPopover(dropBtn, 156, menuH, true, function(container, closeFn)
						local t = Themes[currentThemeName]
						local scroll = create("ScrollingFrame", {
							Position = UDim2.fromOffset(5, 5),
							Size = UDim2.new(1, -10, 1, -10),
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							ScrollBarThickness = 2,
							AutomaticCanvasSize = Enum.AutomaticSize.Y,
							CanvasSize = UDim2.new(0, 0, 0, 0),
							ZIndex = 212,
						}, container)
						create("UIListLayout", { Padding = UDim.new(0, 3) }, scroll)

						for _, choice in ipairs(opt.Options) do
							local isSel = (choice == selected)
							local itemBtn = create("TextButton", {
								Size = UDim2.new(1, 0, 0, 28),
								BackgroundColor3 = t.TabActiveBg,
								BackgroundTransparency = isSel and 0.84 or 1,
								Text = "",
								AutoButtonColor = false,
								ZIndex = 213,
							}, scroll)
							addCorner(itemBtn, 8)
							bindPressSquish(itemBtn, itemBtn, 0.96)

							create("TextLabel", {
								Position = UDim2.fromOffset(10, 0),
								Size = UDim2.new(1, -30, 1, 0),
								BackgroundTransparency = 1,
								Font = isSel and Enum.Font.GothamBold or Enum.Font.GothamMedium,
								Text = choice,
								TextSize = 11,
								TextXAlignment = Enum.TextXAlignment.Left,
								TextColor3 = isSel and t.TextPrimary or t.TextSecondary,
								ZIndex = 214,
							}, itemBtn)

							if isSel then
								local ckHolder = create("Frame", {
									AnchorPoint = Vector2.new(1, 0.5),
									Position = UDim2.new(1, -8, 0.5, 0),
									Size = UDim2.fromOffset(14, 14),
									BackgroundTransparency = 1,
									ZIndex = 214,
								}, itemBtn)
								createVectorIcon("check", ckHolder, t.Accent, 215)
							end

							connect(itemBtn.MouseEnter, function()
								tween(itemBtn, 0.14, { BackgroundTransparency = 0.82 })
							end)
							connect(itemBtn.MouseLeave, function()
								tween(itemBtn, 0.16, { BackgroundTransparency = isSel and 0.84 or 1 })
							end)
							connect(itemBtn.MouseButton1Click, function()
								spawnRipple(itemBtn)
								selected = choice
								valText.Text = choice
								tween(chevronVec.Root, 0.24, { Rotation = 0 })
								closeFn()
								if opt.Callback then
									task.spawn(opt.Callback, choice)
								end
							end)
						end
					end)

					task.delay(0.35, function()
						if not ActiveDropdownClose then
							tween(chevronVec.Root, 0.22, { Rotation = 0 })
						end
					end)
				end)

				bindTheme(function(t, d)
					tween(dropBtn, d, { BackgroundColor3 = t.ControlBg, BackgroundTransparency = t.ControlTrans })
					tween(dropStroke, d, { Color = t.Stroke, Transparency = t.StrokeTrans })
					tween(valText, d, { TextColor3 = t.TextPrimary })
					chevronVec.SetColor(t.TextSecondary)
				end)

				return {
					Set = function(_, v: string)
						selected = v
						valText.Text = v
					end,
				}
			end

			-- D. ACTION BUTTON
			function SectionAPI:AddButton(opt: {
				Title: string,
				Desc: string?,
				Icon: string?,
				Color: Color3?,
				ButtonText: string?,
				Callback: (() -> ())?,
			})
				local row = makeRowCard(opt.Title, opt.Desc, opt.Icon, opt.Color)

				local actBtn = create("TextButton", {
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, -12, 0.5, 0),
					Size = UDim2.fromOffset(74, 28),
					BackgroundColor3 = Themes[currentThemeName].ControlBg,
					BackgroundTransparency = Themes[currentThemeName].ControlTrans,
					Font = Enum.Font.GothamSemibold,
					Text = opt.ButtonText or "Go",
					TextSize = 11,
					TextColor3 = Themes[currentThemeName].TextPrimary,
					AutoButtonColor = false,
					ZIndex = 24,
				}, row)
				addCorner(actBtn, 9)
				local actStroke = addStroke(actBtn, Themes[currentThemeName].Stroke, 1, Themes[currentThemeName].StrokeTrans)
				bindPressSquish(actBtn, actBtn, 0.92)

				connect(actBtn.MouseEnter, function()
					tween(actBtn, 0.16, { BackgroundTransparency = 0.08 })
				end)
				connect(actBtn.MouseLeave, function()
					tween(actBtn, 0.18, { BackgroundTransparency = Themes[currentThemeName].ControlTrans })
				end)
				connect(actBtn.MouseButton1Click, function()
					spawnRipple(actBtn)
					if opt.Callback then
						task.spawn(opt.Callback)
					end
				end)

				bindTheme(function(t, d)
					tween(actBtn, d, {
						BackgroundColor3 = t.ControlBg,
						BackgroundTransparency = t.ControlTrans,
						TextColor3 = t.TextPrimary,
					})
					tween(actStroke, d, { Color = t.Stroke, Transparency = t.StrokeTrans })
				end)
			end

			return SectionAPI
		end

		return TabAPI
	end

	-- ============================================================================
	-- 16. HANDWRITTEN "hello" INTRO + DUAL SPIRAL MORPH
	-- ============================================================================
	function WindowAPI:PlayIntro()
		IntroLayer:ClearAllChildren()
		IntroLayer.Visible = true
		MainWindowHolder.Visible = false
		IsWindowOpen = false

		islandY.Position, islandY.Target = -54, -54
		islandW.Position, islandW.Target = 54, 54
		islandH.Position, islandH.Target = 24, 24

		local blur = Lighting:FindFirstChild("NNHub_IntroBlur") :: BlurEffect?
		if not blur then
			blur = create("BlurEffect", { Name = "NNHub_IntroBlur", Size = 0 }, Lighting)
		end
		tween(blur :: BlurEffect, 0.45, { Size = 20 })

		local canvas = create("CanvasGroup", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(360, 140),
			BackgroundTransparency = 1,
			GroupTransparency = 0,
			ZIndex = 305,
		}, IntroLayer)
		local canvasScale = create("UIScale", { Scale = 1 }, canvas)

		local rawHello = {
			Vector2.new(58, 84), Vector2.new(74, 62), Vector2.new(88, 30), Vector2.new(90, 18),
			Vector2.new(82, 20), Vector2.new(74, 46), Vector2.new(66, 90), Vector2.new(70, 74),
			Vector2.new(84, 62), Vector2.new(95, 68), Vector2.new(96, 86), Vector2.new(108, 86),
			Vector2.new(124, 74), Vector2.new(135, 62), Vector2.new(129, 55), Vector2.new(117, 63),
			Vector2.new(116, 80), Vector2.new(128, 88), Vector2.new(144, 78),
			Vector2.new(160, 48), Vector2.new(172, 20), Vector2.new(167, 16), Vector2.new(158, 34),
			Vector2.new(152, 76), Vector2.new(160, 88), Vector2.new(175, 76),
			Vector2.new(192, 46), Vector2.new(204, 20), Vector2.new(199, 16), Vector2.new(190, 34),
			Vector2.new(184, 76), Vector2.new(192, 88), Vector2.new(208, 76),
			Vector2.new(224, 62), Vector2.new(238, 60), Vector2.new(242, 74), Vector2.new(232, 88),
			Vector2.new(217, 84), Vector2.new(216, 68), Vector2.new(228, 60), Vector2.new(242, 68),
			Vector2.new(258, 72), Vector2.new(272, 65),
		}

		local pathPts = sampleSpline(rawHello, 5)
		local totalSegs = #pathPts - 1
		local strokeThick = 3.2

		local penTip = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.fromOffset(10, 10),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 0.2,
			BorderSizePixel = 0,
			ZIndex = 310,
		}, canvas)
		addCorner(penTip, 999)

		task.spawn(function()
			local drawDur = ReduceMotion and 0.65 or 1.60
			local drawnCount = 0
			local t0 = os.clock()

			while drawnCount < totalSegs do
				local p = math.clamp((os.clock() - t0) / drawDur, 0, 1)
				local eased = p < 0.5 and (2 * p * p) or (1 - ((-2 * p + 2) ^ 2) / 2)
				local targetCount = math.floor(eased * totalSegs)

				while drawnCount < targetCount do
					drawnCount += 1
					local a = pathPts[drawnCount]
					local b = pathPts[drawnCount + 1]
					local diff = b - a
					local len = diff.Magnitude
					local mid = (a + b) * 0.5
					local rot = math.deg(math.atan2(diff.Y, diff.X))

					local glow = create("Frame", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromOffset(mid.X, mid.Y),
						Size = UDim2.fromOffset(len + strokeThick * 2.2, strokeThick * 2.6),
						Rotation = rot,
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 0.86,
						BorderSizePixel = 0,
						ZIndex = 306,
					}, canvas)
					addCorner(glow, 999)

					local seg = create("Frame", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromOffset(mid.X, mid.Y),
						Size = UDim2.fromOffset(len + strokeThick, strokeThick),
						Rotation = rot,
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 0.04,
						BorderSizePixel = 0,
						ZIndex = 308,
					}, canvas)
					addCorner(seg, 999)

					penTip.Position = UDim2.fromOffset(b.X, b.Y)
				end
				RunService.RenderStepped:Wait()
			end

			tween(penTip, 0.20, { BackgroundTransparency = 1, Size = UDim2.fromOffset(2, 2) })
			tween(canvasScale, 0.80, { Scale = 1.04 }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
			task.wait(ReduceMotion and 0.35 or 0.90)

			tween(canvas, 0.32, { GroupTransparency = 1 })
			tween(canvasScale, 0.32, { Scale = 0.94 })
			task.wait(0.34)
			canvas:Destroy()

			local spiralHolder = create("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromOffset(400, 400),
				BackgroundTransparency = 1,
				ZIndex = 305,
			}, IntroLayer)

			local orbColor = Themes[currentThemeName].IsLight and Color3.fromRGB(250, 252, 255) or Color3.fromRGB(16, 18, 24)
			local trailCount = 14
			local trailA: { Frame } = {}
			local trailB: { Frame } = {}
			for i = 1, trailCount do
				local frac = 1 - (i - 1) / trailCount
				local sz = math.max(3, math.round(12 * frac))
				local dotA = create("Frame", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Size = UDim2.fromOffset(sz, sz),
					BackgroundColor3 = orbColor,
					BackgroundTransparency = (1 - frac) * 0.65,
					BorderSizePixel = 0,
					ZIndex = 306,
				}, spiralHolder)
				addCorner(dotA, 999)
				trailA[i] = dotA

				local dotB = create("Frame", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Size = UDim2.fromOffset(sz, sz),
					BackgroundColor3 = orbColor,
					BackgroundTransparency = (1 - frac) * 0.65,
					BorderSizePixel = 0,
					ZIndex = 306,
				}, spiralHolder)
				addCorner(dotB, 999)
				trailB[i] = dotB
			end

			local spiralDur = ReduceMotion and 0.45 or 1.10
			local st0 = os.clock()
			while true do
				local u = math.clamp((os.clock() - st0) / spiralDur, 0, 1)
				for i = 1, trailCount do
					local tu = math.clamp(u - (i - 1) * 0.018, 0, 1)
					local radius: number
					if tu < 0.45 then
						local k = tu / 0.45
						radius = 170 * (1 - k) ^ 2 + 42
					else
						local k = (tu - 0.45) / 0.55
						radius = 42 * (1 - k * k)
					end
					local angle = tu * math.pi * 4.4
					trailA[i].Position = UDim2.fromOffset(200 + math.cos(angle) * radius, 200 + math.sin(angle) * radius)
					trailB[i].Position = UDim2.fromOffset(200 + math.cos(angle + math.pi) * radius, 200 + math.sin(angle + math.pi) * radius)
				end
				if u >= 1 then
					break
				end
				RunService.RenderStepped:Wait()
			end

			local centerOrb = create("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromOffset(26, 26),
				BackgroundColor3 = Themes[currentThemeName].WindowBg,
				BackgroundTransparency = 0.08,
				BorderSizePixel = 0,
				ZIndex = 309,
			}, IntroLayer)
			local orbCorner = addCorner(centerOrb, 999)
			spiralHolder:Destroy()

			-- Drop Minimal Dynamic Island at Top Center!
			islandY.Target = 12
			islandW.Target = 120
			islandH.Target = 30

			local targetScale = getResponsiveScale()
			tween(orbCorner, 0.40, { CornerRadius = UDim.new(0, 18) })
			tween(centerOrb, 0.42, {
				Position = UDim2.fromScale(0.5, 0.52),
				Size = UDim2.fromOffset(WIN_W * targetScale, WIN_H * targetScale),
				BackgroundTransparency = Themes[currentThemeName].WindowTrans,
			}, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

			task.wait(0.35)

			WindowFrame.GroupTransparency = 1
			WindowScale.Scale = targetScale
			windowScaleSpring.Position = targetScale
			windowScaleSpring.Target = targetScale
			MainWindowHolder.Visible = true
			IsWindowOpen = true

			if ActiveTabIndex > 0 then
				moveActivePillTo(ActiveTabIndex, true)
			end

			tween(centerOrb, 0.22, { BackgroundTransparency = 1 })
			tween(WindowFrame, 0.34, { GroupTransparency = 0 })
			tween(blur :: BlurEffect, 0.50, { Size = 0 })

			task.delay(0.55, function()
				IntroLayer:ClearAllChildren()
				IntroLayer.Visible = false
				if blur and blur.Parent then
					blur:Destroy()
				end
			end)
		end)
	end

	-- ============================================================================
	-- 17. MASTER RENDERSTEPPED SPRING & LIVE TELEMETRY LOOP
	-- ============================================================================
	local fpsAccum = 0
	local fpsFrames = 0
	local currentFps = 60
	local lastTelemetryTick = 0

	connect(RunService.RenderStepped, function(dt: number)
		local speedMul = ReduceMotion and 2.2 or 1
		for i = #ActiveSprings, 1, -1 do
			local entry = ActiveSprings[i]
			if not entry.Spring:IsSettled() then
				local val = entry.Spring:Update(dt * speedMul)
				entry.Callback(val)
			end
		end

		fpsAccum += dt
		fpsFrames += 1
		if fpsAccum >= 0.5 then
			currentFps = math.round(fpsFrames / fpsAccum)
			fpsAccum = 0
			fpsFrames = 0
		end

		local now = os.clock()
		if now - lastTelemetryTick >= 1 then
			lastTelemetryTick = now
			local elapsed = math.floor(now - SessionStart)
			local timeStr = string.format("%02d:%02d", math.floor(elapsed / 60), elapsed % 60)

			local pingMs = 0
			pcall(function()
				pingMs = math.round(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
			end)

			if not IsStatusExpanded then
				StatusText.Text = "Running · " .. timeStr
			end
			LiveFpsValLbl.Text = tostring(currentFps)
			LivePingValLbl.Text = tostring(pingMs) .. "ms"
			LiveSessValLbl.Text = timeStr
			IslandStatsLabel.Text = string.format("FPS: %d  •  Ping: %dms  •  %s", currentFps, pingMs, timeStr)

			tween(StatusDot, 0.45, { BackgroundTransparency = 0.45 })
			tween(IslandDot, 0.45, { BackgroundTransparency = 0.45 })
			task.delay(0.45, function()
				tween(StatusDot, 0.45, { BackgroundTransparency = 0 })
				tween(IslandDot, 0.45, { BackgroundTransparency = 0 })
			end)
		end
	end)

	WindowAPI.SetTheme = function(_, name: string)
		setTheme(name)
	end
	WindowAPI.SetTabPosition = function(_, pos: string)
		setTabPosition(pos)
	end
	WindowAPI.SetReduceMotion = function(_, v: boolean)
		ReduceMotion = v
	end
	WindowAPI.Toggle = function(_, open: boolean?)
		setWindowVisible(if open == nil then not IsWindowOpen else open)
	end
	WindowAPI.Destroy = function()
		for _, c in ipairs(Connections) do
			c:Disconnect()
		end
		local blur = Lighting:FindFirstChild("NNHub_IntroBlur")
		if blur then
			blur:Destroy()
		end
		ScreenGui:Destroy()
	end

	if playIntro then
		WindowAPI:PlayIntro()
	else
		islandY.Target = 12
		setWindowVisible(true)
	end

	return WindowAPI
end

-- ============================================================================
-- 18. DEMO HUB SETUP (ALL VECTOR ICONS — ZERO MISSING GLYPHS!)
-- ============================================================================
local Window = NNHub:CreateWindow({
	Title = "NN Hub",
	SubTitle = "Liquid Glass v2",
	Theme = "Dark",
	TabPosition = "Left",
	PlayIntro = true,
	ToggleKey = Enum.KeyCode.RightShift,
})

-- TAB 1: MAIN
local MainTab = Window:AddTab({ Name = "Main", Icon = "home", Accent = Color3.fromRGB(96, 165, 250) })

local StealSec = MainTab:AddSection("Steal")
StealSec:AddToggle({
	Title = "Auto steal",
	Desc = "Grabs eggs and brings them home",
	Icon = "target",
	Color = Color3.fromRGB(56, 189, 248),
	Default = true,
	Callback = function(v)
		Window:Notify("Auto steal", v and "Đã bật tự động thu thập" or "Đã tắt Auto steal", 2.2)
	end,
})
StealSec:AddToggle({
	Title = "Egg camp",
	Desc = "Waits at spawns for fresh eggs",
	Icon = "farm",
	Color = Color3.fromRGB(168, 85, 247),
	Default = false,
})
StealSec:AddDropdown({
	Title = "Target zone",
	Desc = "Where to look for eggs",
	Icon = "target",
	Color = Color3.fromRGB(52, 211, 153),
	Options = { "Zone 1", "Zone 2", "Zone 3", "Event Zone", "Secret Island" },
	Default = "Zone 3",
	Callback = function(v)
		Window:Notify("Target zone", "Đã chọn khu vực: " .. v, 2)
	end,
})

local MoveSec = MainTab:AddSection("Movement")
MoveSec:AddSlider({
	Title = "Run speed",
	Desc = "Speed while carrying an egg",
	Icon = "bolt",
	Color = Color3.fromRGB(251, 191, 36),
	Min = 16,
	Max = 180,
	Default = 80,
	Step = 1,
	Callback = function(v)
		local char = LocalPlayer.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.WalkSpeed = v
		end
	end,
})
MoveSec:AddToggle({
	Title = "Night shelter",
	Desc = "Stays safe when night falls",
	Icon = "moon",
	Color = Color3.fromRGB(129, 140, 248),
	Default = true,
})
MoveSec:AddButton({
	Title = "Return to base",
	Desc = "Sends you home instantly",
	Icon = "return",
	Color = Color3.fromRGB(244, 114, 182),
	ButtonText = "Go",
	Callback = function()
		Window:Notify("Teleport", "Đang dịch chuyển về căn cứ...", 2.2)
	end,
})

-- TAB 2: FARM
local FarmTab = Window:AddTab({ Name = "Farm", Icon = "farm", Accent = Color3.fromRGB(52, 211, 153) })
local HatchSec = FarmTab:AddSection("Hatch")
HatchSec:AddToggle({
	Title = "Auto hatch",
	Desc = "Hatches ready eggs automatically",
	Icon = "target",
	Color = Color3.fromRGB(52, 211, 153),
	Default = true,
})
HatchSec:AddToggle({
	Title = "Auto plant",
	Desc = "Fills empty plots automatically",
	Icon = "farm",
	Color = Color3.fromRGB(74, 222, 128),
	Default = false,
})
HatchSec:AddSlider({
	Title = "Hatch delay",
	Desc = "Seconds between hatches",
	Icon = "bolt",
	Color = Color3.fromRGB(96, 165, 250),
	Min = 0,
	Max = 30,
	Default = 5,
	Step = 1,
})

local SellSec = FarmTab:AddSection("Sell")
SellSec:AddToggle({
	Title = "Auto sell",
	Desc = "Sells pets below your rarity",
	Icon = "farm",
	Color = Color3.fromRGB(251, 146, 60),
	Default = false,
})
SellSec:AddDropdown({
	Title = "Keep rarity",
	Desc = "Lowest rarity to keep",
	Icon = "palette",
	Color = Color3.fromRGB(192, 132, 252),
	Options = { "Rare", "Epic", "Legendary", "Secret" },
	Default = "Legendary",
})

-- TAB 3: VISUAL
local VisualTab = Window:AddTab({ Name = "Visual", Icon = "visual", Accent = Color3.fromRGB(192, 132, 252) })
local EspSec = VisualTab:AddSection("ESP")
EspSec:AddToggle({
	Title = "Egg ESP",
	Desc = "Shows eggs through walls",
	Icon = "visual",
	Color = Color3.fromRGB(56, 189, 248),
	Default = true,
})
EspSec:AddToggle({
	Title = "Player ESP",
	Desc = "Shows players through walls",
	Icon = "target",
	Color = Color3.fromRGB(52, 211, 153),
	Default = true,
})
local WorldSec = VisualTab:AddSection("World")
WorldSec:AddSlider({
	Title = "Field of view",
	Desc = "Camera zoom angle",
	Icon = "visual",
	Color = Color3.fromRGB(251, 191, 36),
	Min = 50,
	Max = 120,
	Default = 70,
	Step = 1,
	Callback = function(v)
		if workspace.CurrentCamera then
			workspace.CurrentCamera.FieldOfView = v
		end
	end,
})

-- TAB 4: HALLOWEEN
local EventTab = Window:AddTab({ Name = "Halloween", Icon = "halloween", Accent = Color3.fromRGB(251, 146, 60) })
local DimSec = EventTab:AddSection("Dimension")
DimSec:AddToggle({
	Title = "Auto fishing",
	Desc = "Fishes the haunted pond",
	Icon = "target",
	Color = Color3.fromRGB(56, 189, 248),
	Default = true,
})
DimSec:AddToggle({
	Title = "Pumpkin moon",
	Desc = "Collects runaway pumpkins",
	Icon = "moon",
	Color = Color3.fromRGB(251, 146, 60),
	Default = false,
})
DimSec:AddToggle({
	Title = "Ghost dog",
	Desc = "Invades the dog's yard",
	Icon = "farm",
	Color = Color3.fromRGB(244, 114, 182),
	Default = true,
})
local BossSec = EventTab:AddSection("Bosses")
BossSec:AddToggle({
	Title = "Auto Ghouler",
	Desc = "Fights the ghoul boss",
	Icon = "sword",
	Color = Color3.fromRGB(248, 113, 113),
	Default = false,
})
BossSec:AddToggle({
	Title = "Auto manor key",
	Desc = "Opens the manor gate",
	Icon = "key",
	Color = Color3.fromRGB(250, 204, 21),
	Default = false,
})

-- TAB 5: SETTINGS
local SettingsTab = Window:AddTab({ Name = "Settings", Icon = "settings", Accent = Color3.fromRGB(148, 163, 184) })
local UiSec = SettingsTab:AddSection("Interface")
UiSec:AddDropdown({
	Title = "Theme",
	Desc = "Colors of the window (Dark & White Glass)",
	Icon = "palette",
	Color = Color3.fromRGB(96, 165, 250),
	Options = { "Dark", "Light", "Midnight", "Graphite", "OLED", "Halloween" },
	Default = "Dark",
	Callback = function(v)
		Window:SetTheme(v)
		Window:Notify("Theme", "Đã chuyển giao diện: " .. v, 2)
	end,
})
UiSec:AddDropdown({
	Title = "Tab position",
	Desc = "Where the tabs sit",
	Icon = "layout",
	Color = Color3.fromRGB(168, 85, 247),
	Options = { "Left", "Top", "Right", "Bottom", "Dock" },
	Default = "Left",
	Callback = function(v)
		Window:SetTabPosition(v)
	end,
})
UiSec:AddToggle({
	Title = "Reduce motion",
	Desc = "Fewer & snappier animations",
	Icon = "bolt",
	Color = Color3.fromRGB(148, 163, 184),
	Default = false,
	Callback = function(v)
		Window:SetReduceMotion(v)
	end,
})

local CfgSec = SettingsTab:AddSection("Config")
CfgSec:AddButton({
	Title = "Save config",
	Desc = "Writes settings now",
	Icon = "save",
	Color = Color3.fromRGB(56, 189, 248),
	ButtonText = "Save",
	Callback = function()
		Window:Notify("Config Saved", "Đã lưu cấu hình NN Hub thành công!", 2.5)
	end,
})
CfgSec:AddButton({
	Title = "Replay Intro",
	Desc = "Xem lại hiệu ứng vẽ chữ hello & mở GUI",
	Icon = "replay",
	Color = Color3.fromRGB(192, 132, 252),
	ButtonText = "Play",
	Callback = function()
		Window:PlayIntro()
	end,
})
