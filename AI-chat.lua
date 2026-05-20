-- ============================================
-- CYBER AI CHAT V3 - DELTA EXECUTOR OPTIMIZED
-- Small UI, No Emoji, Crop/Reset, SysPrompt
-- ============================================

local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

-- Delta executor: dùng gethui() nếu có, fallback về CoreGui
local parentGui = gethui and gethui() or CoreGui

-- Tự động check hàm request phù hợp với mọi loại executor
local request_func = request or http_request or (syn and syn.request)
if not request_func then
    warn("Executor does not support HTTP Request")
    return
end

-- ========== DANH SÁCH MODEL GROQ ==========
local MODELS = {
    {id = "llama-3.1-8b-instant", name = "Llama 3.1 8B", desc = "Fast, free tier friendly"},
    {id = "llama-3.3-70b-versatile", name = "Llama 3.3 70B", desc = "High quality"},
    {id = "meta-llama/llama-4-scout-17b-16e-instruct", name = "Llama 4 Scout", desc = "Latest, 128k context"},
    {id = "qwen/qwen3-32b", name = "Qwen3 32B", desc = "Code & multilingual"},
    {id = "moonshotai/kimi-k2-instruct", name = "Kimi K2", desc = "Multilingual AI"},
    {id = "openai/gpt-oss-120b", name = "GPT-OSS 120B", desc = "OpenAI open source"},
    {id = "openai/gpt-oss-20b", name = "GPT-OSS 20B", desc = "Lightweight, 1000 TPS"},
    {id = "deepseek-r1-distill-llama-70b", name = "DeepSeek R1", desc = "Deep reasoning model"},
}

local CURRENT_MODEL = MODELS[1].id -- Default model

-- ========== SYS PROMPT ÉP AI TRẢ VỀ ĐÚNG ĐỊNH DẠNG ==========
local SYSTEM_PROMPT = [[You are a helpful AI assistant in a Roblox game UI. 
IMPORTANT RULES:
1. Respond ONLY in plain text format
2. Do NOT use markdown formatting (no **, no ```, no # headers)
3. Do NOT use emojis or special unicode characters
4. Keep responses concise and direct
5. Use simple English words
6. If asked to code, provide clean Lua code blocks only
7. Never return HTML, JSON, or formatted markdown
8. Maximum response length: 500 characters unless specifically asked for more]]

-- ========== TẠO SCREEN GUI ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CyberAIChatV3_" .. tostring(math.random(1000,9999))
ScreenGui.Parent = parentGui
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- ========== KHUNG CHÍNH (NHỎ GỌN) ==========
-- Default size: nhỏ gọn cho mobile
local DEFAULT_SIZE = UDim2.new(0, 280, 0, 340)
local DEFAULT_POS = UDim2.new(0.5, -140, 0.5, -170)

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = DEFAULT_SIZE
MainFrame.Position = DEFAULT_POS
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

-- Gradient background
local UIGradient = Instance.new("UIGradient")
UIGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 15, 25)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(10, 10, 18)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 8, 15))
})
UIGradient.Rotation = 45
UIGradient.Parent = MainFrame

-- Neon border
local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(0, 170, 255)
UIStroke.Thickness = 1.2
UIStroke.Transparency = 0.35
UIStroke.Parent = MainFrame

-- ========== HEADER ==========
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 36)
Header.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Header.BackgroundTransparency = 0.5
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderGradient = Instance.new("UIGradient")
HeaderGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 90, 180)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 40, 120))
})
HeaderGradient.Rotation = 90
HeaderGradient.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -130, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "  AI CHAT"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 12
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

-- Model indicator
local ModelLabel = Instance.new("TextLabel")
ModelLabel.Size = UDim2.new(0, 100, 0, 14)
ModelLabel.Position = UDim2.new(0, 10, 0, 22)
ModelLabel.BackgroundTransparency = 1
ModelLabel.Text = "Llama 3.1 8B"
ModelLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
ModelLabel.TextSize = 9
ModelLabel.Font = Enum.Font.Gotham
ModelLabel.TextXAlignment = Enum.TextXAlignment.Left
ModelLabel.Parent = Header

-- NÚT CROP (FIT SCREEN)
local CropBtn = Instance.new("TextButton")
CropBtn.Name = "CropBtn"
CropBtn.Size = UDim2.new(0, 26, 0, 26)
CropBtn.Position = UDim2.new(1, -98, 0, 5)
CropBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
CropBtn.Text = "[ ]"
CropBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CropBtn.TextSize = 10
CropBtn.Font = Enum.Font.GothamBold
CropBtn.Parent = Header

local CropCorner = Instance.new("UICorner")
CropCorner.CornerRadius = UDim.new(0, 6)
CropCorner.Parent = CropBtn

-- NÚT RESET SIZE
local ResetBtn = Instance.new("TextButton")
ResetBtn.Name = "ResetBtn"
ResetBtn.Size = UDim2.new(0, 26, 0, 26)
ResetBtn.Position = UDim2.new(1, -70, 0, 5)
ResetBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
ResetBtn.Text = "R"
ResetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ResetBtn.TextSize = 12
ResetBtn.Font = Enum.Font.GothamBold
ResetBtn.Parent = Header

local ResetCorner = Instance.new("UICorner")
ResetCorner.CornerRadius = UDim.new(0, 6)
ResetCorner.Parent = ResetBtn

-- NÚT THU NHỎ "-"
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Name = "MinimizeBtn"
MinimizeBtn.Size = UDim2.new(0, 26, 0, 26)
MinimizeBtn.Position = UDim2.new(1, -42, 0, 5)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.TextSize = 16
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.Parent = Header

local MinimizeCorner = Instance.new("UICorner")
MinimizeCorner.CornerRadius = UDim.new(0, 6)
MinimizeCorner.Parent = MinimizeBtn

-- NÚT ĐÓNG "x"
local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Size = UDim2.new(0, 26, 0, 26)
CloseBtn.Position = UDim2.new(1, -14, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseBtn.Text = "x"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

-- ========== MODEL SELECTOR DROPDOWN ==========
local ModelDropdown = Instance.new("Frame")
ModelDropdown.Name = "ModelDropdown"
ModelDropdown.Size = UDim2.new(1, -16, 0, 0)
ModelDropdown.Position = UDim2.new(0, 8, 0, 40)
ModelDropdown.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
ModelDropdown.BackgroundTransparency = 0.1
ModelDropdown.BorderSizePixel = 0
ModelDropdown.ClipsDescendants = true
ModelDropdown.ZIndex = 10
ModelDropdown.Parent = MainFrame

local DropdownCorner = Instance.new("UICorner")
DropdownCorner.CornerRadius = UDim.new(0, 10)
DropdownCorner.Parent = ModelDropdown

local DropdownStroke = Instance.new("UIStroke")
DropdownStroke.Color = Color3.fromRGB(0, 150, 255)
DropdownStroke.Thickness = 1
DropdownStroke.Transparency = 0.5
DropdownStroke.Parent = ModelDropdown

local DropdownList = Instance.new("ScrollingFrame")
DropdownList.Size = UDim2.new(1, -8, 1, -8)
DropdownList.Position = UDim2.new(0, 4, 0, 4)
DropdownList.BackgroundTransparency = 1
DropdownList.ScrollBarThickness = 3
DropdownList.ScrollBarImageColor3 = Color3.fromRGB(0, 170, 255)
DropdownList.AutomaticCanvasSize = Enum.AutomaticSize.Y
DropdownList.ZIndex = 10
DropdownList.Parent = ModelDropdown

local DropdownLayout = Instance.new("UIListLayout")
DropdownLayout.SortOrder = Enum.SortOrder.LayoutOrder
DropdownLayout.Padding = UDim.new(0, 3)
DropdownLayout.Parent = DropdownList

-- Nút mở dropdown
local ModelBtn = Instance.new("TextButton")
ModelBtn.Name = "ModelBtn"
ModelBtn.Size = UDim2.new(0, 80, 0, 20)
ModelBtn.Position = UDim2.new(1, -92, 0, 22)
ModelBtn.BackgroundColor3 = Color3.fromRGB(0, 80, 160)
ModelBtn.Text = "Switch Model"
ModelBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ModelBtn.TextSize = 8
ModelBtn.Font = Enum.Font.GothamBold
ModelBtn.Parent = Header

local ModelBtnCorner = Instance.new("UICorner")
ModelBtnCorner.CornerRadius = UDim.new(0, 5)
ModelBtnCorner.Parent = ModelBtn

-- Tạo các option trong dropdown
for i, model in ipairs(MODELS) do
    local Option = Instance.new("TextButton")
    Option.Size = UDim2.new(1, 0, 0, 32)
    Option.BackgroundColor3 = Color3.fromRGB(22, 22, 35)
    Option.BackgroundTransparency = 0.5
    Option.Text = ""
    Option.ZIndex = 10
    Option.Parent = DropdownList

    local OptionCorner = Instance.new("UICorner")
    OptionCorner.CornerRadius = UDim.new(0, 6)
    OptionCorner.Parent = Option

    local OptionName = Instance.new("TextLabel")
    OptionName.Size = UDim2.new(1, -8, 0, 16)
    OptionName.Position = UDim2.new(0, 6, 0, 2)
    OptionName.BackgroundTransparency = 1
    OptionName.Text = model.name
    OptionName.TextColor3 = Color3.fromRGB(255, 255, 255)
    OptionName.TextSize = 11
    OptionName.Font = Enum.Font.GothamBold
    OptionName.TextXAlignment = Enum.TextXAlignment.Left
    OptionName.ZIndex = 10
    OptionName.Parent = Option

    local OptionDesc = Instance.new("TextLabel")
    OptionDesc.Size = UDim2.new(1, -8, 0, 12)
    OptionDesc.Position = UDim2.new(0, 6, 0, 18)
    OptionDesc.BackgroundTransparency = 1
    OptionDesc.Text = model.desc
    OptionDesc.TextColor3 = Color3.fromRGB(130, 130, 150)
    OptionDesc.TextSize = 8
    OptionDesc.Font = Enum.Font.Gotham
    OptionDesc.TextXAlignment = Enum.TextXAlignment.Left
    OptionDesc.ZIndex = 10
    OptionDesc.Parent = Option

    -- Hover effect
    Option.MouseEnter:Connect(function()
        TweenService:Create(Option, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(0, 90, 180)}):Play()
    end)
    Option.MouseLeave:Connect(function()
        TweenService:Create(Option, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(22, 22, 35)}):Play()
    end)

    Option.MouseButton1Click:Connect(function()
        CURRENT_MODEL = model.id
        ModelLabel.Text = model.name
        TweenService:Create(ModelDropdown, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {Size = UDim2.new(1, -16, 0, 0)}):Play()
        addMessage("System", "Switched to: " .. model.name)
    end)
end

-- Toggle dropdown
local dropdownOpen = false
ModelBtn.MouseButton1Click:Connect(function()
    dropdownOpen = not dropdownOpen
    local targetSize = dropdownOpen and UDim2.new(1, -16, 0, math.min(220, #MODELS * 35 + 8)) or UDim2.new(1, -16, 0, 0)
    TweenService:Create(ModelDropdown, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {Size = targetSize}):Play()
end)

-- ========== KHU VỰC CHAT ==========
local ChatContainer = Instance.new("Frame")
ChatContainer.Name = "ChatContainer"
ChatContainer.Size = UDim2.new(1, -16, 1, -120)
ChatContainer.Position = UDim2.new(0, 8, 0, 42)
ChatContainer.BackgroundColor3 = Color3.fromRGB(5, 5, 10)
ChatContainer.BackgroundTransparency = 0.3
ChatContainer.BorderSizePixel = 0
ChatContainer.Parent = MainFrame

local ContainerCorner = Instance.new("UICorner")
ContainerCorner.CornerRadius = UDim.new(0, 10)
ContainerCorner.Parent = ChatContainer

local ContainerStroke = Instance.new("UIStroke")
ContainerStroke.Color = Color3.fromRGB(25, 25, 40)
ContainerStroke.Thickness = 1
ContainerStroke.Transparency = 0.5
ContainerStroke.Parent = ChatContainer

local ChatLog = Instance.new("ScrollingFrame")
ChatLog.Name = "ChatLog"
ChatLog.Size = UDim2.new(1, -8, 1, -8)
ChatLog.Position = UDim2.new(0, 4, 0, 4)
ChatLog.BackgroundTransparency = 1
ChatLog.CanvasSize = UDim2.new(0, 0, 0, 0)
ChatLog.AutomaticCanvasSize = Enum.AutomaticSize.Y
ChatLog.ScrollBarThickness = 3
ChatLog.ScrollBarImageColor3 = Color3.fromRGB(0, 170, 255)
ChatLog.Parent = ChatContainer

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 6)
UIListLayout.Parent = ChatLog

-- ========== TYPING INDICATOR ==========
local TypingIndicator = Instance.new("Frame")
TypingIndicator.Name = "TypingIndicator"
TypingIndicator.Size = UDim2.new(1, 0, 0, 20)
TypingIndicator.BackgroundTransparency = 1
TypingIndicator.Visible = false
TypingIndicator.LayoutOrder = 999999
TypingIndicator.Parent = ChatLog

local TypingText = Instance.new("TextLabel")
TypingText.Size = UDim2.new(1, 0, 1, 0)
TypingText.BackgroundTransparency = 1
TypingText.Text = "AI is thinking..."
TypingText.TextColor3 = Color3.fromRGB(0, 180, 255)
TypingText.TextSize = 10
TypingText.Font = Enum.Font.Gotham
TypingText.TextXAlignment = Enum.TextXAlignment.Left
TypingText.Parent = TypingIndicator

-- Animation dots
local dots = 0
task.spawn(function()
    while true do
        if TypingIndicator.Visible then
            dots = (dots + 1) % 4
            local text = "AI is thinking"
            for i = 1, dots do text = text .. "." end
            TypingText.Text = text
        end
        task.wait(0.4)
    end
end)

-- ========== HÀM THÊM TIN NHẮN ==========
local function addMessage(sender, text)
    local isUser = sender == "You"
    local isAI = sender == "AI"

    local MsgContainer = Instance.new("Frame")
    MsgContainer.Size = UDim2.new(1, 0, 0, 0)
    MsgContainer.AutomaticSize = Enum.AutomaticSize.Y
    MsgContainer.BackgroundTransparency = 1
    MsgContainer.LayoutOrder = #ChatLog:GetChildren()
    MsgContainer.Parent = ChatLog

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, isUser and 30 or 0)
    padding.PaddingRight = UDim.new(0, isUser and 0 or 30)
    padding.PaddingTop = UDim.new(0, 2)
    padding.PaddingBottom = UDim.new(0, 2)
    padding.Parent = MsgContainer

    local Bubble = Instance.new("Frame")
    Bubble.Size = UDim2.new(0.88, 0, 0, 0)
    Bubble.AutomaticSize = Enum.AutomaticSize.Y
    Bubble.Position = UDim2.new(isUser and 0.12 or 0, 0, 0, 0)
    Bubble.BackgroundColor3 = isUser and Color3.fromRGB(0, 90, 180) or (isAI and Color3.fromRGB(22, 22, 35) or Color3.fromRGB(50, 20, 20))
    Bubble.BorderSizePixel = 0
    Bubble.Parent = MsgContainer

    local BubbleCorner = Instance.new("UICorner")
    BubbleCorner.CornerRadius = UDim.new(0, 10)
    BubbleCorner.Parent = Bubble

    -- Gradient cho bubble
    if isUser then
        local BubbleGradient = Instance.new("UIGradient")
        BubbleGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 110, 200)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 70, 160))
        })
        BubbleGradient.Rotation = 135
        BubbleGradient.Parent = Bubble
    elseif isAI then
        local BubbleGradient = Instance.new("UIGradient")
        BubbleGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(28, 28, 45)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(18, 18, 30))
        })
        BubbleGradient.Rotation = 135
        BubbleGradient.Parent = Bubble
    end

    local MsgText = Instance.new("TextLabel")
    MsgText.Size = UDim2.new(1, -12, 0, 0)
    MsgText.Position = UDim2.new(0, 8, 0, 6)
    MsgText.AutomaticSize = Enum.AutomaticSize.Y
    MsgText.BackgroundTransparency = 1
    MsgText.Text = "[" .. sender .. "]: " .. text
    MsgText.TextColor3 = isUser and Color3.fromRGB(255, 255, 255) or (isAI and Color3.fromRGB(210, 230, 255) or Color3.fromRGB(255, 100, 100))
    MsgText.TextSize = 11
    MsgText.Font = Enum.Font.Gotham
    MsgText.TextWrapped = true
    MsgText.RichText = false -- TẮT RICHTEXT ĐỂ TRÁNH LỖI FONT
    MsgText.TextXAlignment = Enum.TextXAlignment.Left
    MsgText.Parent = Bubble

    -- Tự động resize bubble theo text
    local function updateSize()
        Bubble.Size = UDim2.new(0.88, 0, 0, MsgText.AbsoluteSize.Y + 12)
    end
    MsgText:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateSize)
    updateSize()

    -- Animation vào
    Bubble.BackgroundTransparency = 1
    MsgText.TextTransparency = 1
    TweenService:Create(Bubble, TweenInfo.new(0.25), {BackgroundTransparency = 0}):Play()
    TweenService:Create(MsgText, TweenInfo.new(0.25), {TextTransparency = 0}):Play()

    -- Tự cuộn xuống
    task.defer(function()
        ChatLog.CanvasPosition = Vector2.new(0, ChatLog.AbsoluteCanvasSize.Y)
    end)
end

-- Tin nhắn chào mừng
addMessage("System", "Welcome! Ask me anything. Press [-] to minimize, [ ] to fit screen.")

-- ========== Ô NHẬP TIN NHẮN ==========
local InputContainer = Instance.new("Frame")
InputContainer.Name = "InputContainer"
InputContainer.Size = UDim2.new(1, -16, 0, 38)
InputContainer.Position = UDim2.new(0, 8, 1, -46)
InputContainer.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
InputContainer.BackgroundTransparency = 0.2
InputContainer.BorderSizePixel = 0
InputContainer.Parent = MainFrame

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 10)
InputCorner.Parent = InputContainer

local InputStroke = Instance.new("UIStroke")
InputStroke.Color = Color3.fromRGB(0, 130, 255)
InputStroke.Thickness = 1.2
InputStroke.Transparency = 0.4
InputStroke.Parent = InputContainer

local TextBox = Instance.new("TextBox")
TextBox.Size = UDim2.new(1, -42, 1, -8)
TextBox.Position = UDim2.new(0, 8, 0, 4)
TextBox.BackgroundTransparency = 1
TextBox.PlaceholderText = "Type message here..."
TextBox.Text = ""
TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
TextBox.PlaceholderColor3 = Color3.fromRGB(90, 90, 110)
TextBox.TextSize = 11
TextBox.Font = Enum.Font.Gotham
TextBox.TextXAlignment = Enum.TextXAlignment.Left
TextBox.ClearTextOnFocus = false
TextBox.Parent = InputContainer

-- Nút gửi
local SendBtn = Instance.new("TextButton")
SendBtn.Size = UDim2.new(0, 30, 0, 30)
SendBtn.Position = UDim2.new(1, -36, 0, 4)
SendBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
SendBtn.Text = ">"
SendBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SendBtn.TextSize = 14
SendBtn.Font = Enum.Font.GothamBold
SendBtn.Parent = InputContainer

local SendCorner = Instance.new("UICorner")
SendCorner.CornerRadius = UDim.new(0, 8)
SendCorner.Parent = SendBtn

-- Hover send button
SendBtn.MouseEnter:Connect(function()
    TweenService:Create(SendBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(0, 180, 255)}):Play()
end)
SendBtn.MouseLeave:Connect(function()
    TweenService:Create(SendBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(0, 150, 255)}):Play()
end)

-- ========== XỬ LÝ GỬI TIN NHẮN ==========
local function sendMessage()
    local query = TextBox.Text
    if query == "" then return end
    TextBox.Text = ""
    TextBox:ReleaseFocus()

    addMessage("You", query)

    -- Hiện typing indicator
    TypingIndicator.Visible = true

    task.spawn(function()
        local success, response = pcall(function()
            return request_func({
                Url = "https://apikeys.datlun2k11.workers.dev/",
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json",
                    ["X-Custom-Auth"] = "BradarMatKhauSieuCapVip123"
                },
                Body = HttpService:JSONEncode({ 
                    message = query,
                    model = CURRENT_MODEL,
                    system_prompt = SYSTEM_PROMPT -- GỬI SYS PROMPT ÉP AI
                })
            })
        end)

        -- Ẩn typing indicator
        TypingIndicator.Visible = false

        if success and response.StatusCode == 200 then
            local data = HttpService:JSONDecode(response.Body)
            if data and data.reply then
                -- LÀM SẠCH RESPONSE (bỏ markdown, emoji)
                local cleanReply = tostring(data.reply)
                cleanReply = cleanReply:gsub("%*%*", "") -- Bỏ bold markdown
                cleanReply = cleanReply:gsub("%*", "") -- Bỏ italic
                cleanReply = cleanReply:gsub("`", "") -- Bỏ code ticks
                cleanReply = cleanReply:gsub("#+", "") -- Bỏ headers
                cleanReply = cleanReply:gsub("[%z-]", "") -- Bỏ control chars
                cleanReply = cleanReply:sub(1, 800) -- Giới hạn độ dài

                addMessage("AI", cleanReply)
            else
                addMessage("System", "Invalid response format from server")
            end
        else
            local code = response and response.StatusCode or "Unknown"
            local errMsg = "Connection error (Code: " .. tostring(code) .. ")"
            if code == 429 then
                errMsg = "Rate limited! Please wait a moment."
            elseif code == 401 then
                errMsg = "Auth failed! Check worker config."
            elseif code == 500 then
                errMsg = "Server error! Try again later."
            elseif code == "Unknown" then
                errMsg = "Network error! Check your connection."
            end
            addMessage("System", errMsg)
        end
    end)
end

TextBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then sendMessage() end
end)

SendBtn.MouseButton1Click:Connect(sendMessage)

-- ========== NÚT TOGGLE (MOBILE) ==========
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "ToggleBtn"
ToggleBtn.Size = UDim2.new(0, 42, 0, 42)
ToggleBtn.Position = UDim2.new(0, 12, 0.4, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
ToggleBtn.Text = "AI"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 14
ToggleBtn.Parent = ScreenGui

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(1, 0)
ToggleCorner.Parent = ToggleBtn

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Color = Color3.fromRGB(255, 255, 255)
ToggleStroke.Thickness = 1.5
ToggleStroke.Transparency = 0.5
ToggleStroke.Parent = ToggleBtn

-- Toggle glow
local ToggleGlow = Instance.new("ImageLabel")
ToggleGlow.Size = UDim2.new(1, 16, 1, 16)
ToggleGlow.Position = UDim2.new(0, -8, 0, -8)
ToggleGlow.BackgroundTransparency = 1
ToggleGlow.Image = "rbxassetid://5028857084"
ToggleGlow.ImageColor3 = Color3.fromRGB(0, 150, 255)
ToggleGlow.ImageTransparency = 0.85
ToggleGlow.Parent = ToggleBtn

-- ========== CHỨC NĂNG CROP / FIT SCREEN ==========
local isCropped = false
local isMinimized = false
local isTweening = false
local originalSize = MainFrame.Size
local originalPosition = MainFrame.Position

local function cropToScreen()
    if isTweening then return end
    isTweening = true
    isCropped = true

    -- Lấy kích thước màn hình
    local screenSize = workspace.CurrentCamera.ViewportSize
    local padding = 20
    local targetSize = UDim2.new(0, screenSize.X - padding * 2, 0, screenSize.Y - padding * 2)
    local targetPos = UDim2.new(0, padding, 0, padding)

    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    local tween = TweenService:Create(MainFrame, tweenInfo, {Size = targetSize, Position = targetPos})
    tween.Completed:Connect(function()
        isTweening = false
    end)
    tween:Play()

    CropBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    addMessage("System", "UI fitted to screen. Press R to reset.")
end

local function resetSize()
    if isTweening then return end
    isTweening = true
    isCropped = false
    isMinimized = false

    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    local tween = TweenService:Create(MainFrame, tweenInfo, {Size = DEFAULT_SIZE, Position = DEFAULT_POS})
    tween.Completed:Connect(function()
        isTweening = false
        -- Hiện lại các phần tử nếu đang minimized
        for _, child in ipairs(MainFrame:GetChildren()) do
            if child.Name ~= "Header" and child:IsA("GuiObject") then
                child.Visible = true
            end
        end
        Header.Size = UDim2.new(1, 0, 0, 36)
        Title.Text = "  AI CHAT"
        ModelLabel.Visible = true
        ModelBtn.Visible = true
        CloseBtn.Visible = true
        MinimizeBtn.Text = "-"
        MinimizeBtn.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
        dropdownOpen = false
        ModelDropdown.Size = UDim2.new(1, -16, 0, 0)
    end)
    tween:Play()

    CropBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
end

local function minimizeUI()
    if isTweening then return end
    isTweening = true
    isMinimized = true
    isCropped = false

    local targetSize = UDim2.new(0, 160, 0, 36)
    local targetPos = UDim2.new(1, -180, 1, -56)

    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)

    for _, child in ipairs(MainFrame:GetChildren()) do
        if child.Name ~= "Header" and child:IsA("GuiObject") then
            child.Visible = false
        end
    end

    Header.Size = UDim2.new(1, 0, 1, 0)
    Title.Text = "  AI"
    ModelLabel.Visible = false
    ModelBtn.Visible = false
    CloseBtn.Visible = false
    CropBtn.Visible = false
    ResetBtn.Visible = false
    MinimizeBtn.Text = "+"
    MinimizeBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 100)

    local tween = TweenService:Create(MainFrame, tweenInfo, {Size = targetSize, Position = targetPos})
    tween.Completed:Connect(function()
        isTweening = false
    end)
    tween:Play()
end

local function restoreUI()
    if isTweening then return end
    isTweening = true
    isMinimized = false

    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    for _, child in ipairs(MainFrame:GetChildren()) do
        if child.Name ~= "Header" and child:IsA("GuiObject") then
            child.Visible = true
        end
    end

    Header.Size = UDim2.new(1, 0, 0, 36)
    Title.Text = "  AI CHAT"
    ModelLabel.Visible = true
    ModelBtn.Visible = true
    CloseBtn.Visible = true
    CropBtn.Visible = true
    ResetBtn.Visible = true
    MinimizeBtn.Text = "-"
    MinimizeBtn.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
    dropdownOpen = false
    ModelDropdown.Size = UDim2.new(1, -16, 0, 0)

    local tween = TweenService:Create(MainFrame, tweenInfo, {Size = DEFAULT_SIZE, Position = DEFAULT_POS})
    tween.Completed:Connect(function()
        isTweening = false
    end)
    tween:Play()
end

-- Nút Crop
CropBtn.MouseButton1Click:Connect(function()
    if isCropped then
        resetSize()
    else
        cropToScreen()
    end
end)

-- Nút Reset
ResetBtn.MouseButton1Click:Connect(function()
    resetSize()
end)

-- Nút Minimize
MinimizeBtn.MouseButton1Click:Connect(function()
    if isMinimized then
        restoreUI()
    else
        minimizeUI()
    end
end)

-- Nút Close
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui.Enabled = false
    ToggleBtn.Visible = true
end)

-- Toggle button
ToggleBtn.MouseButton1Click:Connect(function()
    if not ScreenGui.Enabled then
        ScreenGui.Enabled = true
        if isMinimized then
            restoreUI()
        end
    else
        if MainFrame.Visible then
            MainFrame.Visible = false
        else
            MainFrame.Visible = true
            if isMinimized then
                restoreUI()
            end
        end
    end
end)

-- ========== DRAGGABLE CHO MOBILE ==========
local dragging = false
local dragStart, startPos

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- ========== ANIMATION MỞ ĐẦU ==========
MainFrame.Size = UDim2.new(0, 0, 0, 0)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)

local openTween = TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = DEFAULT_SIZE,
    Position = DEFAULT_POS
})
openTween:Play()

-- Pulse animation cho toggle button
task.spawn(function()
    while true do
        if ToggleBtn.Visible then
            TweenService:Create(ToggleGlow, TweenInfo.new(1.5), {ImageTransparency = 0.7}):Play()
            task.wait(1.5)
            TweenService:Create(ToggleGlow, TweenInfo.new(1.5), {ImageTransparency = 0.85}):Play()
            task.wait(1.5)
        else
            task.wait(2)
        end
    end
end)

print("Cyber AI Chat V3 loaded! Small UI, no emoji, sys prompt enforced.")
