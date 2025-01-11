-- Получаем все игроки в игре
local players = game:GetService("Players")
local userInputService = game:GetService("UserInputService")
local starterGui = game:GetService("StarterGui")
local player = game.Players.LocalPlayer

-- Флаг для отслеживания состояния (включено/выключено)
local isEnabled = false
local isDisabled = false  -- Новый флаг для отслеживания, выключен ли скрипт через Home
local isMessageShown = false  -- Флаг для отслеживания, было ли уже выведено сообщение о выключении

-- Таблица для хранения объектов подсветки и никнеймов
local highlights = {}
local nameTags = {}

-- Ссылка на созданный ScreenGui с текстом
local screenGui = nil

-- Функция для подсветки игрока с обводкой
local function highlightPlayer(player)
    if player.Character then
        -- Делаем подсветку только если у персонажа нет подсветки
        if not player.Character:FindFirstChild("Highlight") then
            -- Создаем объект Highlight для подсветки
            local highlight = Instance.new("Highlight")
            highlight.Name = "Highlight"
            highlight.Parent = player.Character
            highlight.Adornee = player.Character

            -- Красная заливка
            highlight.FillColor = Color3.fromRGB(255, 0, 0)  -- Красный цвет
            highlight.FillTransparency = 0.5  -- Прозрачность заливки

            -- Зеленая обводка
            highlight.OutlineColor = Color3.fromRGB(0, 255, 0)  -- Зеленая обводка
            highlight.OutlineTransparency = 0  -- Обводка непрозрачная

            -- Добавляем подсветку в таблицу для контроля
            highlights[player] = highlight
        end
    end
end

-- Функция для отображения никнейма игрока
local function displayPlayerName(player)
    if player.Character then
        local character = player.Character
        local head = character:FindFirstChild("Head")

        -- Если у персонажа есть голова, создаем BillboardGui для отображения никнейма
        if head then
            if not character:FindFirstChild("NameTag") then
                local nameTag = Instance.new("BillboardGui")
                nameTag.Name = "NameTag"
                nameTag.Parent = head
                nameTag.Adornee = head
                nameTag.Size = UDim2.new(0, 200, 0, 50)  -- Размер текста
                nameTag.StudsOffset = Vector3.new(0, 3, 0)  -- Расстояние над головой
                nameTag.AlwaysOnTop = true  -- Никнейм всегда сверху

                -- Устанавливаем MaxDistance на большое значение, чтобы никнейм был виден на огромной дистанции
                nameTag.MaxDistance = 1000  -- Можно установить на 1000 или больше для больших дистанций

                -- Создаем TextLabel для отображения никнейма
                local textLabel = Instance.new("TextLabel")
                textLabel.Parent = nameTag
                textLabel.Size = UDim2.new(1, 0, 1, 0)  -- Размер текстового лейбла
                textLabel.Text = player.Name  -- Устанавливаем никнейм игрока
                textLabel.TextColor3 = Color3.fromRGB(0, 255, 0)  -- Зеленый цвет текста
                textLabel.TextStrokeTransparency = 0.5  -- Строка вокруг текста для лучшей видимости
                textLabel.TextSize = 24  -- Размер текста
                textLabel.BackgroundTransparency = 1  -- Отключаем фон
                textLabel.TextTransparency = 0.5  -- Прозрачность текста (50%)

                -- Добавляем никнейм в таблицу для контроля
                nameTags[player] = nameTag
            end
        end
    end
end

-- Функция для обработки подсветки и никнейма при смерти игрока
local function onCharacterAdded(player)
    if isEnabled then
        -- Если включено, создаем подсветку и никнейм
        highlightPlayer(player)
        displayPlayerName(player)
    else
        -- Если выключено, удаляем подсветку и никнейм, если они есть
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

-- Функция для выключения всех эффектов и вывода сообщения
local function disableAllEffectsAndNotify()
    isEnabled = false  -- Выключаем все эффекты

    -- Удаляем все подсветки и никнеймы
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

    -- Выводим сообщение в чат, если оно еще не было выведено
    if not isMessageShown then
        starterGui:SetCore("SendNotification", {
            Title = "ESP Hack",
            Text = "ESP Hack выключен",
            Duration = 3  -- Продолжительность уведомления
        })
        isMessageShown = true  -- Устанавливаем флаг, что сообщение было выведено
    end

    -- Переключаем флаг, что скрипт отключен
    isDisabled = true

    -- Скрываем текстовый элемент
    if screenGui then
        screenGui.Enabled = false  -- Скрыть текст
    end
end

-- Подсвечиваем всех игроков в игре
for _, player in pairs(players:GetPlayers()) do
    -- Подключаем событие создания скелетона при появлении персонажа
    player.CharacterAdded:Connect(function(character)
        onCharacterAdded(player)
    end)

    -- Подсвечиваем игроков, если их персонажи уже существуют
    if player.Character then
        onCharacterAdded(player)
    end
end

-- Автоматически подсвечиваем новых игроков
players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        onCharacterAdded(player)
    end)
end)

-- Выводим сообщение о том, что скрипт был успешно загружен
starterGui:SetCore("SendNotification", {
    Title = "ESP Hack",
    Text = "ESP Hack успешно загружен",
    Duration = 3  -- Продолжительность уведомления
})

-- Создаем надпись "@scriptandgames" с прозрачностью 50% и размером увеличенным в 2 раза
screenGui = Instance.new("ScreenGui")
screenGui.Parent = player.PlayerGui  -- Помещаем ScreenGui в PlayerGui

local textLabel = Instance.new("TextLabel")
textLabel.Parent = screenGui
textLabel.Size = UDim2.new(0, 600, 0, 100)  -- Увеличиваем размер в два раза
textLabel.Position = UDim2.new(0.5, -300, 0.75, -50)  -- Центрируем между серединой и низом экрана
textLabel.Text = "@scriptandgames"  -- Текст надписи
textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)  -- Белый цвет текста
textLabel.TextStrokeTransparency = 0.5  -- Строка вокруг текста для лучшей видимости
textLabel.TextSize = 48  -- Увеличиваем размер текста в 2 раза (изначально был 24)
textLabel.BackgroundTransparency = 1  -- Отключаем фон
textLabel.TextTransparency = 0.7  -- Прозрачность текста (50%)

-- Обработчик нажатия клавиши Insert для переключения состояния
local function toggleVisibility()
    if isDisabled then
        -- Если скрипт отключен через Home, игнорируем попытки включить его снова
        return
    end

    isEnabled = not isEnabled  -- Переключаем состояние

    -- Включаем или выключаем подсветку и никнеймы для всех игроков
    for _, player in pairs(players:GetPlayers()) do
        if player.Character then
            if isEnabled then
                -- Если состояние включено, восстанавливаем подсветку и никнейм
                onCharacterAdded(player)
            else
                -- Если состояние выключено, удаляем подсветку и никнейм
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
end

-- Обработчик нажатия клавиш
userInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end  -- Игнорируем, если событие уже обработано

    if input.UserInputType == Enum.UserInputType.Keyboard then
        if input.KeyCode == Enum.KeyCode.Insert then
            toggleVisibility()  -- Переключаем состояние подсветки и никнеймов
        elseif input.KeyCode == Enum.KeyCode.Home then
            if not isDisabled then
                disableAllEffectsAndNotify()  -- Отключаем все эффекты и показываем уведомление
            end
        end
    end
end)
