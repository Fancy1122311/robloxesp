-- Getting all the players in the game
local players = game:GetService("Players")
local userInputService = game:GetService("UserInputService")
local starterGui = game:GetService("StarterGui")
local player = game.Players.LocalPlayer

-- Flag to track the state (enabled/disabled)
local isEnabled = false
local isDisabled = false  -- Flag to track if the script is disabled via Home
local isMessageShown = false  -- Flag to track if the disable message has been shown

-- Tables to store highlight and name tags
local highlights = {}
local nameTags = {}

-- Reference to the created ScreenGui with text
local screenGui = nil

-- Function to highlight a player with outline
local function highlightPlayer(player)
    if player.Character then
        -- Make the highlight only if the character doesn't have it already
        if not player.Character:FindFirstChild("Highlight") then
            -- Create a Highlight object for the player
            local highlight = Instance.new("Highlight")
            highlight.Name = "Highlight"
            highlight.Parent = player.Character
            highlight.Adornee = player.Character

            -- Red fill color
            highlight.FillColor = Color3.fromRGB(255, 0, 0)  -- Red color
            highlight.FillTransparency = 0.5  -- Fill transparency

            -- Green outline
            highlight.OutlineColor = Color3.fromRGB(0, 255, 0)  -- Green outline
            highlight.OutlineTransparency = 0  -- Fully opaque outline

            -- Add the highlight to the table for tracking
            highlights[player] = highlight
        end
    end
end

-- Function to display player's name tag
local function displayPlayerName(player)
    if player.Character then
        local character = player.Character
        local head = character:FindFirstChild("Head")

        -- If the character has a head, create a BillboardGui for the name tag
        if head then
            if not character:FindFirstChild("NameTag") then
                local nameTag = Instance.new("BillboardGui")
                nameTag.Name = "NameTag"
                nameTag.Parent = head
                nameTag.Adornee = head
                nameTag.Size = UDim2.new(0, 200, 0, 50)  -- Size of the name tag
                nameTag.StudsOffset = Vector3.new(0, 3, 0)  -- Offset above the head
                nameTag.AlwaysOnTop = true  -- Keep the name tag always on top

                -- Set MaxDistance to a large value so the name is visible from a long distance
                nameTag.MaxDistance = 1000000  -- You can set this to 1000 or higher for large distances

                -- Create a TextLabel to display the player's name
                local textLabel = Instance.new("TextLabel")
                textLabel.Parent = nameTag
                textLabel.Size = UDim2.new(1, 0, 1, 0)  -- Size of the text label
                textLabel.Text = player.Name  -- Set the player's name
                textLabel.TextColor3 = Color3.fromRGB(0, 255, 0)  -- Green text color
                textLabel.TextStrokeTransparency = 0.5  -- Stroke around the text for better visibility
                textLabel.TextSize = 24  -- Text size
                textLabel.BackgroundTransparency = 1  -- Remove background
                textLabel.TextTransparency = 0  -- 50% transparency for the text

                -- Add the name tag to the table for tracking
                nameTags[player] = nameTag
            end
        end
    end
end

-- Function to handle highlighting and name tag when a player dies or respawns
local function onCharacterAdded(player)
    if isEnabled then
        -- If enabled, create highlight and name tag
        highlightPlayer(player)
        displayPlayerName(player)
    else
        -- If disabled, remove the highlight and name tag
        if highlights[player] then
            highlights[player]:Destroy()
            highlights[player] = nil
        end
        if nameTags[player] then
            nameTags[player]:Destroy()
            nameTags[player] = nil
        end
    end
end

-- Function to disable all effects and notify
local function disableAllEffectsAndNotify()
    isEnabled = false  -- Disable all effects

    -- Remove all highlights and name tags
    for _, player in pairs(players:GetPlayers()) do
        if player.Character then
            if highlights[player] then
                highlights[player]:Destroy()
                highlights[player] = nil
            end
            if nameTags[player] then
                nameTags[player]:Destroy()
                nameTags[player] = nil
            end
        end
    end

    -- Show a notification if it hasn't been shown yet
    if not isMessageShown then
        starterGui:SetCore("SendNotification", {
            Title = "ESP Hack",
            Text = "ESP Hack Disabled",
            Duration = 3  -- Notification duration
        })
        isMessageShown = true  -- Set the flag that the message has been shown
    end

    -- Set the disabled flag
    isDisabled = true

    -- Hide the text element
    if screenGui then
        screenGui.Enabled = false  -- Hide the text
    end
end

-- Highlight all players in the game
for _, player in pairs(players:GetPlayers()) do
    -- Connect the character added event to handle the highlight and name tag
    player.CharacterAdded:Connect(function(character)
        onCharacterAdded(player)
    end)

    -- Highlight the players if their characters already exist
    if player.Character then
        onCharacterAdded(player)
    end
end

-- Automatically highlight new players
players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        onCharacterAdded(player)
    end)
end)

-- Show a notification about successful script loading
starterGui:SetCore("SendNotification", {
    Title = "ESP Hack",
    Text = "ESP Hack Loaded Successfully",
    Duration = 3  -- Notification duration
})

-- Create the text "@scriptandgames" with 50% transparency and size increased by 2x
screenGui = Instance.new("ScreenGui")
screenGui.Parent = player.PlayerGui  -- Place the ScreenGui in PlayerGui

local textLabel = Instance.new("TextLabel")
textLabel.Parent = screenGui
textLabel.Size = UDim2.new(0, 600, 0, 100)  -- Increase the size by 2x
textLabel.Position = UDim2.new(0.5, -300, 0.75, -50)  -- Center between the middle and bottom of the screen
textLabel.Text = "@scriptandgames"  -- Text for the label
textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)  -- White text color
textLabel.TextStrokeTransparency = 0.5  -- Stroke around the text for better visibility
textLabel.TextSize = 48  -- Increase the text size by 2x (original was 24)
textLabel.BackgroundTransparency = 1  -- Remove background
textLabel.TextTransparency = 0  -- 50% transparency for the text

-- Function to toggle the visibility of highlights and name tags
local function toggleVisibility()
    if isDisabled then
        -- If the script is disabled via Home, ignore toggle attempts
        return
    end

    isEnabled = not isEnabled  -- Toggle the state

    -- Show or hide the highlights and name tags for all players
    for _, player in pairs(players:GetPlayers()) do
        if player.Character then
            if isEnabled then
                -- If enabled, restore the highlight and name tag
                onCharacterAdded(player)
            else
                -- If disabled, remove the highlight and name tag
                if highlights[player] then
                    highlights[player]:Destroy()
                    highlights[player] = nil
                end
                if nameTags[player] then
                    nameTags[player]:Destroy()
                    nameTags[player] = nil
                end
            end
        end
    end

    -- Send notification about the state change
    if isEnabled then
        starterGui:SetCore("SendNotification", {
            Title = "ESP Hack",
            Text = "ESP Hack Enabled",
            Duration = 3  -- Notification duration
        })
    else
        starterGui:SetCore("SendNotification", {
            Title = "ESP Hack",
            Text = "ESP Hack Disabled",
            Duration = 3  -- Notification duration
        })
    end
end

-- Keyboard input event handler
userInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end  -- Ignore if the event is already processed

    if input.UserInputType == Enum.UserInputType.Keyboard then
        if input.KeyCode == Enum.KeyCode.Insert then
            toggleVisibility()  -- Toggle the visibility of highlights and name tags
        elseif input.KeyCode == Enum.KeyCode.Home then
            if not isDisabled then
                disableAllEffectsAndNotify()  -- Disable all effects and show notification
            end
        end
    end
end)
