local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

local vulnerableRemotes = {}

-- Create UI
local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
local Frame = Instance.new("Frame", ScreenGui)
local TextLabel = Instance.new("TextLabel", Frame)
local TextBox = Instance.new("TextBox", Frame)
local ExecuteButton = Instance.new("TextButton", Frame)
local LogLabel = Instance.new("TextLabel", Frame)

-- UI Styling
Frame.Size = UDim2.new(0, 300, 0, 250)
Frame.Position = UDim2.new(0.5, -150, 0.5, -125)
Frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Frame.Visible = false

TextLabel.Text = "Vulnerable Remote Scanner"
TextLabel.Size = UDim2.new(1, 0, 0, 30)
TextLabel.TextColor3 = Color3.new(1, 1, 1)
TextLabel.BackgroundTransparency = 1

TextBox.Size = UDim2.new(1, -20, 0, 50)
TextBox.Position = UDim2.new(0, 10, 0, 40)
TextBox.PlaceholderText = "Enter server command"

ExecuteButton.Text = "Execute"
ExecuteButton.Size = UDim2.new(1, -20, 0, 40)
ExecuteButton.Position = UDim2.new(0, 10, 0, 100)
ExecuteButton.BackgroundColor3 = Color3.fromRGB(100, 100, 255)

LogLabel.Size = UDim2.new(1, -20, 0, 50)
LogLabel.Position = UDim2.new(0, 10, 0, 150)
LogLabel.Text = "Execution Log:"
LogLabel.TextColor3 = Color3.new(1, 1, 1)
LogLabel.BackgroundTransparency = 1

-- Scan for remotes
for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
    if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
        local success, response
        if obj:IsA("RemoteEvent") then
            success, response = pcall(function()
                obj:FireServer("Ethical Test Payload")
            end)
            if success then
                table.insert(vulnerableRemotes, obj)
            end
        elseif obj:IsA("RemoteFunction") then
            success, response = pcall(function()
                return obj:InvokeServer("Ethical Test Payload")
            end)
            if success then
                table.insert(vulnerableRemotes, obj)
            end
        end
    end
end

-- Handle UI interaction
if #vulnerableRemotes > 0 then
    print("[SSW Scanner] Vulnerabilities found! Press 'P' to open the UI.")

    -- Toggle UI visibility when 'P' is pressed
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if input.KeyCode == Enum.KeyCode.P and not gameProcessed then
            Frame.Visible = not Frame.Visible
        end
    end)

    -- Execute commands on remotes
    ExecuteButton.MouseButton1Click:Connect(function()
        local command = TextBox.Text
        if command ~= "" then
            for _, remote in pairs(vulnerableRemotes) do
                local success, result
                if remote:IsA("RemoteEvent") then
                    success, result = pcall(function()
                        remote:FireServer(command)
                    end)
                    if success then
                        LogLabel.Text = "Sent command to " .. remote.Name
                        print("[SSW Scanner] Sent to", remote.Name)
                    else
                        LogLabel.Text = "Execution failed: " .. result
                        print("[SSW Scanner] Execution failed:", result)
                    end
                elseif remote:IsA("RemoteFunction") then
                    success, result = pcall(function()
                        return remote:InvokeServer(command)
                    end)
                    if success then
                        LogLabel.Text = "Response: " .. tostring(result)
                        print("[SSW Scanner] Result:", result)
                    else
                        LogLabel.Text = "Execution failed: " .. result
                        print("[SSW Scanner] Execution failed:", result)
                    end
                end

                -- Add a random delay (1-3 seconds) after each command execution
                task.wait(math.random(1, 3))
            end
        else
            LogLabel.Text = "Please enter a command!"
        end
    end)
else
    print("[SSW Scanner] No vulnerabilities found.")
end
