local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

-- Tự động check hàm request phù hợp với mọi loại executor
local request_func = request or http_request or (syn and syn.request)
if not request_func then
    print("Executor cùi bắp k hỗ trợ HTTP Request r bro 🥀")
    return
end

-- ========== DANH SÁCH MODEL GROQ ==========
local MODELS = {
    {id = "llama-3.1-8b-instant", name = "⚡ Llama 3.1 8B", desc = "Nhanh, free tier thoải mái"},
    {id = "llama-3.3-70b-versatile", name = "🧠 Llama 3.3 70B", desc = "Chất lượng cao"},
    {id = "meta-llama/llama-4-scout-17b-16e-instruct", name = "🔥 Llama 4 Scout", desc = "Model mới nhất 128k context"},
    {id = "qwen/qwen3-32b", name = "💻 Qwen3 32B", name = "Code & đa ngôn ngữ"},
    {id = "moonshotai/kimi-k2-instruct", name = "🌙 Kimi K2", desc = "Kimi AI đa năng"},
    {id = "openai/gpt-oss-120b", name = "🤖 GPT-OSS 120B", desc = "OpenAI open source"},
    {id = "openai/gpt-oss-20b", name = "⚡ GPT-OSS 20B", desc = "Nhẹ, nhanh, 1000 TPS"},
    {id = "deepseek-r1-distill-llama-70b", name = "🎯 DeepSeek R1", desc = "Reasoning model suy nghĩ sâu"},
}

local CURRENT_MODEL = MODELS[1].id -- Default model

-- ========== TẠO SCREEN GUI ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CyberAIChatV2"
ScreenGui.Parent = CoreGui or Players.LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- ========== KHUNG CHÍNH (GLASSMORPHISM) ==========
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 380, 0, 480)
MainFrame.Position = UDim2.new(0.5, -190, 0.5, -240)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 18)
MainFrame.BackgroundTransparency = 0.15
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 20)
MainCorner.Parent = MainFrame

-- Gradient background effect
local UIGradient = Instance.new("UIGradient")
UIGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 15, 30)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(10, 10, 20)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(5, 5, 15))
})
UIGradient.Rotation = 45
UIGradient.Parent = MainFrame

-- Neon viền glow
local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(0, 200, 255)
UIStroke.Thickness = 1.5
UIStroke.Transparency = 0.3
UIStroke.Parent = MainFrame

-- Glow effect bên ngoài
local Glow = Instance.new("ImageLabel")
Glow.Name = "Glow"
Glow.Size = UDim2.new(1, 40, 1, 40)
Glow.Position = UDim2.new(0, -20, 0, -20)
Glow.BackgroundTransparency = 1
Glow.Image = "rbxassetid://5028857084"
Glow.ImageColor3 = Color3.fromRGB(0, 170, 255)
Glow.ImageTransparency = 0.85
Glow.ZIndex = 0
Glow.Parent = MainFrame

-- ========== HEADER ==========
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 50)
Header.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Header.BackgroundTransparency = 0.5
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 0)
HeaderCorner.Parent = Header

-- Header gradient
local HeaderGradient = Instance.new("UIGradient")
HeaderGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 100, 200)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 50, 150))
})
HeaderGradient.Rotation = 90
HeaderGradient.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -100, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "  🤖 CYBER AI CHAT"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

-- Model indicator
local ModelLabel = Instance.new("TextLabel")
ModelLabel.Size = UDim2.new(0, 120, 0, 16)
ModelLabel.Position = UDim2.new(0, 15, 0, 32)
ModelLabel.BackgroundTransparency = 1
ModelLabel.Text = "⚡ Llama 3.1 8B"
ModelLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
ModelLabel.TextSize = 10
ModelLabel.Font = Enum.Font.Gotham
ModelLabel.TextXAlignment = Enum.TextXAlignment.Left
ModelLabel.Parent = Header

-- NÚT THU NHỎ "-" (cho mobile)
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Name = "MinimizeBtn"
MinimizeBtn.Size = UDim2.new(0, 32, 0, 32)
MinimizeBtn.Position = UDim2.new(1, -72, 0, 9)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
MinimizeBtn.Text = "−"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.TextSize = 18
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.Parent = Header

local MinimizeCorner = Instance.new("UICorner")
MinimizeCorner.CornerRadius = UDim.new(0, 8)
MinimizeCorner.Parent = MinimizeBtn

-- NÚT ĐÓNG "×"
local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -38, 0, 9)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 18
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

-- ========== MODEL SELECTOR DROPDOWN ==========
local ModelDropdown = Instance.new("Frame")
ModelDropdown.Name = "ModelDropdown"
ModelDropdown.Size = UDim2.new(1, -20, 0, 0) -- Ẩn ban đầu
ModelDropdown.Position = UDim2.new(0, 10, 0, 55)
ModelDropdown.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
ModelDropdown.BackgroundTransparency = 0.1
ModelDropdown.BorderSizePixel = 0
ModelDropdown.ClipsDescendants = true
ModelDropdown.ZIndex = 10
ModelDropdown.Parent = MainFrame

local DropdownCorner = Instance.new("UICorner")
DropdownCorner.CornerRadius = UDim.new(0, 12)
DropdownCorner.Parent = ModelDropdown

local DropdownStroke = Instance.new("UIStroke")
DropdownStroke.Color = Color3.fromRGB(0, 170, 255)
DropdownStroke.Thickness = 1
DropdownStroke.Transparency = 0.5
DropdownStroke.Parent = ModelDropdown

local DropdownList = Instance.new("ScrollingFrame")
DropdownList.Size = UDim2.new(1, -10, 1, -10)
DropdownList.Position = UDim2.new(0, 5, 0, 5)
DropdownList.BackgroundTransparency = 1
DropdownList.ScrollBarThickness = 3
DropdownList.ScrollBarImageColor3 = Color3.fromRGB(0, 170, 255)
DropdownList.AutomaticCanvasSize = Enum.AutomaticSize.Y
DropdownList.ZIndex = 10
DropdownList.Parent = ModelDropdown

local DropdownLayout = Instance.new("UIListLayout")
DropdownLayout.SortOrder = Enum.SortOrder.LayoutOrder
DropdownLayout.Padding = UDim.new(0, 4)
DropdownLayout.Parent = DropdownList

-- Nút mở dropdown
local ModelBtn = Instance.new("TextButton")
ModelBtn.Name = "ModelBtn"
ModelBtn.Size = UDim2.new(0, 100, 0, 24)
ModelBtn.Position = UDim2.new(1, -115, 0, 28)
ModelBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
ModelBtn.Text = "🔄 Đổi Model"
ModelBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ModelBtn.TextSize = 10
ModelBtn.Font = Enum.Font.GothamBold
ModelBtn.Parent = Header

local ModelBtnCorner = Instance.new("UICorner")
ModelBtnCorner.CornerRadius = UDim.new(0, 6)
ModelBtnCorner.Parent = ModelBtn

-- Tạo các option trong dropdown
for i, model in ipairs(MODELS) do
    local Option = Instance.new("TextButton")
    Option.Size = UDim2.new(1, 0, 0, 36)
    Option.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
    Option.BackgroundTransparency = 0.5
    Option.Text = ""
    Option.ZIndex = 10
    Option.Parent = DropdownList
    
    local OptionCorner = Instance.new("UICorner")
    OptionCorner.CornerRadius = UDim.new(0, 8)
    OptionCorner.Parent = Option
    
    local OptionName = Instance.new("TextLabel")
    OptionName.Size = UDim2.new(1, -10, 0, 18)
    OptionName.Position = UDim2.new(0, 8, 0, 2)
    OptionName.BackgroundTransparency = 1
    OptionName.Text = model.name
    OptionName.TextColor3 = Color3.fromRGB(255, 255, 255)
    OptionName.TextSize = 12
    OptionName.Font = Enum.Font.GothamBold
    OptionName.TextXAlignment = Enum.TextXAlignment.Left
    OptionName.ZIndex = 10
    OptionName.Parent = Option
    
    local OptionDesc = Instance.new("TextLabel")
    OptionDesc.Size = UDim2.new(1, -10, 0, 14)
    OptionDesc.Position = UDim2.new(0, 8, 0, 20)
    OptionDesc.BackgroundTransparency = 1
    OptionDesc.Text = model.desc
    OptionDesc.TextColor3 = Color3.fromRGB(150, 150, 170)
    OptionDesc.TextSize = 9
    OptionDesc.Font = Enum.Font.Gotham
    OptionDesc.TextXAlignment = Enum.TextXAlignment.Left
    OptionDesc.ZIndex = 10
    OptionDesc.Parent = Option
    
    -- Hover effect
    Option.MouseEnter:Connect(function()
        TweenService:Create(Option, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 100, 200)}):Play()
    end)
    Option.MouseLeave:Connect(function()
        TweenService:Create(Option, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(25, 25, 40)}):Play()
    end)
    
    Option.MouseButton1Click:Connect(function()
        CURRENT_MODEL = model.id
        ModelLabel.Text = model.name
        -- Animation đóng dropdown
        TweenService:Create(ModelDropdown, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = UDim2.new(1, -20, 0, 0)}):Play()
        addMessage("Hệ thống", "Đã chuyển sang model: " .. model.name .. " 💀")
    end)
end

-- Toggle dropdown
local dropdownOpen = false
ModelBtn.MouseButton1Click:Connect(function()
    dropdownOpen = not dropdownOpen
    local targetSize = dropdownOpen and UDim2.new(1, -20, 0, math.min(280, #MODELS * 40 + 10)) or UDim2.new(1, -20, 0, 0)
    TweenService:Create(ModelDropdown, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = targetSize}):Play()
end)

-- ========== KHU VỰC CHAT ==========
local ChatContainer = Instance.new("Frame")
ChatContainer.Name = "ChatContainer"
ChatContainer.Size = UDim2.new(1, -20, 1, -160)
ChatContainer.Position = UDim2.new(0, 10, 0, 60)
ChatContainer.BackgroundColor3 = Color3.fromRGB(5, 5, 12)
ChatContainer.BackgroundTransparency = 0.3
ChatContainer.BorderSizePixel = 0
ChatContainer.Parent = MainFrame

local ContainerCorner = Instance.new("UICorner")
ContainerCorner.CornerRadius = UDim.new(0, 14)
ContainerCorner.Parent = ChatContainer

local ContainerStroke = Instance.new("UIStroke")
ContainerStroke.Color = Color3.fromRGB(30, 30, 50)
ContainerStroke.Thickness = 1
ContainerStroke.Transparency = 0.5
ContainerStroke.Parent = ChatContainer

local ChatLog = Instance.new("ScrollingFrame")
ChatLog.Name = "ChatLog"
ChatLog.Size = UDim2.new(1, -10, 1, -10)
ChatLog.Position = UDim2.new(0, 5, 0, 5)
ChatLog.BackgroundTransparency = 1
ChatLog.CanvasSize = UDim2.new(0, 0, 0, 0)
ChatLog.AutomaticCanvasSize = Enum.AutomaticSize.Y
ChatLog.ScrollBarThickness = 4
ChatLog.ScrollBarImageColor3 = Color3.fromRGB(0, 170, 255)
ChatLog.Parent = ChatContainer

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.Parent = ChatLog

-- ========== TYPING INDICATOR ==========
local TypingIndicator = Instance.new("Frame")
TypingIndicator.Name = "TypingIndicator"
TypingIndicator.Size = UDim2.new(1, 0, 0, 30)
TypingIndicator.BackgroundTransparency = 1
TypingIndicator.Visible = false
TypingIndicator.LayoutOrder = 999999
TypingIndicator.Parent = ChatLog

local TypingText = Instance.new("TextLabel")
TypingText.Size = UDim2.new(1, 0, 1, 0)
TypingText.BackgroundTransparency = 1
TypingText.Text = "AI đang suy nghĩ"
TypingText.TextColor3 = Color3.fromRGB(0, 200, 255)
TypingText.TextSize = 12
TypingText.Font = Enum.Font.Gotham
TypingText.TextXAlignment = Enum.TextXAlignment.Left
TypingText.Parent = TypingIndicator

-- Animation dots
local dots = 0
task.spawn(function()
    while true do
        if TypingIndicator.Visible then
            dots = (dots + 1) % 4
            local text = "AI đang suy nghĩ"
            for i = 1, dots do text = text .. "." end
            TypingText.Text = text
        end
        task.wait(0.4)
    end
end)

-- ========== HÀM THÊM TIN NHẮN (XỊN HƠN) ==========
local function addMessage(sender, text)
    local isUser = sender == "Bạn"
    local isAI = sender == "AI"
    
    local MsgContainer = Instance.new("Frame")
    MsgContainer.Size = UDim2.new(1, 0, 0, 0)
    MsgContainer.AutomaticSize = Enum.AutomaticSize.Y
    MsgContainer.BackgroundTransparency = 1
    MsgContainer.LayoutOrder = #ChatLog:GetChildren()
    MsgContainer.Parent = ChatLog
    
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, isUser and 40 or 0)
    padding.PaddingRight = UDim.new(0, isUser and 0 or 40)
    padding.PaddingTop = UDim.new(0, 4)
    padding.PaddingBottom = UDim.new(0, 4)
    padding.Parent = MsgContainer
    
    local Bubble = Instance.new("Frame")
    Bubble.Size = UDim2.new(0.85, 0, 0, 0)
    Bubble.AutomaticSize = Enum.AutomaticSize.Y
    Bubble.Position = UDim2.new(isUser and 0.15 or 0, 0, 0, 0)
    Bubble.BackgroundColor3 = isUser and Color3.fromRGB(0, 100, 200) or (isAI and Color3.fromRGB(25, 25, 40) or Color3.fromRGB(50, 20, 20))
    Bubble.BorderSizePixel = 0
    Bubble.Parent = MsgContainer
    
    local BubbleCorner = Instance.new("UICorner")
    BubbleCorner.CornerRadius = UDim.new(0, isUser and 16 or 16)
    BubbleCorner.Parent = Bubble
    
    -- Gradient cho bubble
    if isUser then
        local BubbleGradient = Instance.new("UIGradient")
        BubbleGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 120, 220)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 80, 180))
        })
        BubbleGradient.Rotation = 135
        BubbleGradient.Parent = Bubble
    elseif isAI then
        local BubbleGradient = Instance.new("UIGradient")
        BubbleGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 50)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 35))
        })
        BubbleGradient.Rotation = 135
        BubbleGradient.Parent = Bubble
    end
    
    local MsgText = Instance.new("TextLabel")
    MsgText.Size = UDim2.new(1, -16, 0, 0)
    MsgText.Position = UDim2.new(0, 10, 0, 8)
    MsgText.AutomaticSize = Enum.AutomaticSize.Y
    MsgText.BackgroundTransparency = 1
    MsgText.Text = "<b>[" .. sender .. "]:</b> " .. text
    MsgText.TextColor3 = isUser and Color3.fromRGB(255, 255, 255) or (isAI and Color3.fromRGB(220, 240, 255) or Color3.fromRGB(255, 120, 120))
    MsgText.TextSize = 13
    MsgText.Font = Enum.Font.Gotham
    MsgText.TextWrapped = true
    MsgText.RichText = true
    MsgText.TextXAlignment = Enum.TextXAlignment.Left
    MsgText.Parent = Bubble
    
    -- Tự động resize bubble theo text
    local function updateSize()
        Bubble.Size = UDim2.new(0.85, 0, 0, MsgText.AbsoluteSize.Y + 16)
    end
    MsgText:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateSize)
    updateSize()
    
    -- Animation vào
    Bubble.BackgroundTransparency = 1
    MsgText.TextTransparency = 1
    TweenService:Create(Bubble, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
    TweenService:Create(MsgText, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    
    -- Tự cuộn xuống
    task.defer(function()
        ChatLog.CanvasPosition = Vector2.new(0, ChatLog.AbsoluteCanvasSize.Y)
    end)
end

-- Tin nhắn chào mừng
addMessage("Hệ thống", "Chào m! Hỏi gì hỏi đi 🔥 Nhấn [−] để thu nhỏ, bấm 🔄 để đổi model AI 💀")

-- ========== Ô NHẬP TIN NHẮN ==========
local InputContainer = Instance.new("Frame")
InputContainer.Name = "InputContainer"
InputContainer.Size = UDim2.new(1, -20, 0, 50)
InputContainer.Position = UDim2.new(0, 10, 1, -60)
InputContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
InputContainer.BackgroundTransparency = 0.2
InputContainer.BorderSizePixel = 0
InputContainer.Parent = MainFrame

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 14)
InputCorner.Parent = InputContainer

local InputStroke = Instance.new("UIStroke")
InputStroke.Color = Color3.fromRGB(0, 150, 255)
InputStroke.Thickness = 1.5
InputStroke.Transparency = 0.4
InputStroke.Parent = InputContainer

local TextBox = Instance.new("TextBox")
TextBox.Size = UDim2.new(1, -50, 1, -10)
TextBox.Position = UDim2.new(0, 10, 0, 5)
TextBox.BackgroundTransparency = 1
TextBox.PlaceholderText = "Nhập tin nhắn vào đây bradar..."
TextBox.Text = ""
TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
TextBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 120)
TextBox.TextSize = 13
TextBox.Font = Enum.Font.Gotham
TextBox.TextXAlignment = Enum.TextXAlignment.Left
TextBox.ClearTextOnFocus = false
TextBox.Parent = InputContainer

-- Nút gửi
local SendBtn = Instance.new("TextButton")
SendBtn.Size = UDim2.new(0, 36, 0, 36)
SendBtn.Position = UDim2.new(1, -42, 0, 7)
SendBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
SendBtn.Text = "➤"
SendBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SendBtn.TextSize = 16
SendBtn.Font = Enum.Font.GothamBold
SendBtn.Parent = InputContainer

local SendCorner = Instance.new("UICorner")
SendCorner.CornerRadius = UDim.new(0, 10)
SendCorner.Parent = SendBtn

-- Hover send button
SendBtn.MouseEnter:Connect(function()
    TweenService:Create(SendBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 200, 255)}):Play()
end)
SendBtn.MouseLeave:Connect(function()
    TweenService:Create(SendBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 170, 255)}):Play()
end)

-- ========== XỬ LÝ GỬI TIN NHẮN ==========
local function sendMessage()
    local query = TextBox.Text
    if query == "" then return end
    TextBox.Text = ""
    TextBox:ReleaseFocus()
    
    addMessage("Bạn", query)
    
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
                    model = CURRENT_MODEL
                })
            })
        end)
        
        -- Ẩn typing indicator
        TypingIndicator.Visible = false
        
        if success and response.StatusCode == 200 then
            local data = HttpService:JSONDecode(response.Body)
            if data and data.reply then
                addMessage("AI", data.reply)
            else
                addMessage("Hệ thống", "Data trả về bị lỗi định dạng r 🦧")
            end
        else
            local code = response and response.StatusCode or "Unknown"
            local errMsg = "Lỗi kết nối r đcm ☠️ (Mã: " .. tostring(code) .. ")"
            if code == 429 then
                errMsg = "Rate limit r bro! Đợi xíu r hỏi lại 🥀"
            end
            addMessage("Hệ thống", errMsg)
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
ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleBtn.Position = UDim2.new(0, 15, 0.4, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
ToggleBtn.Text = "🤖"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 20
ToggleBtn.Parent = ScreenGui

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(1, 0)
ToggleCorner.Parent = ToggleBtn

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Color = Color3.fromRGB(255, 255, 255)
ToggleStroke.Thickness = 2
ToggleStroke.Transparency = 0.5
ToggleStroke.Parent = ToggleBtn

-- Toggle glow
local ToggleGlow = Instance.new("ImageLabel")
ToggleGlow.Size = UDim2.new(1, 20, 1, 20)
ToggleGlow.Position = UDim2.new(0, -10, 0, -10)
ToggleGlow.BackgroundTransparency = 1
ToggleGlow.Image = "rbxassetid://5028857084"
ToggleGlow.ImageColor3 = Color3.fromRGB(0, 170, 255)
ToggleGlow.ImageTransparency = 0.8
ToggleGlow.Parent = ToggleBtn

-- ========== CHỨC NĂNG THU NHỎ / PHỤC HỒI ==========
local isMinimized = false
local isTweening = false
local originalSize = MainFrame.Size
local originalPosition = MainFrame.Position

local function minimizeUI()
    if isTweening then return end
    isTweening = true
    isMinimized = true
    
    -- Thu nhỏ xuống góc dưới bên phải
    local targetSize = UDim2.new(0, 180, 0, 50)
    local targetPos = UDim2.new(1, -200, 1, -70)
    
    local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In)
    
    -- Ẩn các phần tử bên trong
    for _, child in ipairs(MainFrame:GetChildren()) do
        if child.Name ~= "Header" and child:IsA("GuiObject") then
            child.Visible = false
        end
    end
    
    -- Header thu nhỏ
    Header.Size = UDim2.new(1, 0, 1, 0)
    Title.Text = "  🤖 AI Chat"
    ModelLabel.Visible = false
    ModelBtn.Visible = false
    CloseBtn.Visible = false
    
    -- Đổi nút minimize thành maximize
    MinimizeBtn.Text = "+"
    MinimizeBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    
    local tween = TweenService:Create(MainFrame, tweenInfo, {Size = targetSize, Position = targetPos})
    tween.Completed:Connect(function()
        isTweening = false
        MainFrame.Active = true
        MainFrame.Draggable = true
    end)
    tween:Play()
end

local function restoreUI()
    if isTweening then return end
    isTweening = true
    isMinimized = false
    
    local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    
    -- Hiện lại các phần tử
    for _, child in ipairs(MainFrame:GetChildren()) do
        if child.Name ~= "Header" and child:IsA("GuiObject") then
            child.Visible = true
        end
    end
    
    -- Khôi phục header
    Header.Size = UDim2.new(1, 0, 0, 50)
    Title.Text = "  🤖 CYBER AI CHAT"
    ModelLabel.Visible = true
    ModelBtn.Visible = true
    CloseBtn.Visible = true
    
    -- Đổi lại nút
    MinimizeBtn.Text = "−"
    MinimizeBtn.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
    
    -- Đóng dropdown nếu đang mở
    dropdownOpen = false
    ModelDropdown.Size = UDim2.new(1, -20, 0, 0)
    
    local tween = TweenService:Create(MainFrame, tweenInfo, {Size = originalSize, Position = originalPosition})
    tween.Completed:Connect(function()
        isTweening = false
        MainFrame.Active = true
        MainFrame.Draggable = true
    end)
    tween:Play()
end

MinimizeBtn.MouseButton1Click:Connect(function()
    if isMinimized then
        restoreUI()
    else
        minimizeUI()
    end
end)

-- Close button
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui.Enabled = false
    ToggleBtn.Visible = true
end)

-- Toggle button (mở lại UI khi đã đóng)
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

local openTween = TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = originalSize,
    Position = originalPosition
})
openTween:Play()

-- Pulse animation cho toggle button
task.spawn(function()
    while true do
        if ToggleBtn.Visible then
            TweenService:Create(ToggleGlow, TweenInfo.new(1.5), {ImageTransparency = 0.6}):Play()
            task.wait(1.5)
            TweenService:Create(ToggleGlow, TweenInfo.new(1.5), {ImageTransparency = 0.8}):Play()
            task.wait(1.5)
        else
            task.wait(2)
        end
    end
end)

print("Cyber AI Chat V2 loaded! 🤖💀 Chọn model và chat thôi bro!")