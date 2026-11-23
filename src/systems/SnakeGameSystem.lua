local SnakeGameSystem = {}

local GRID_SIZE = 20
local MOVE_INTERVAL = 0.15
local FLOWERS_TO_WIN = 20

local function is_occupied(game, x, y)
    for _, segment in ipairs(game.snake) do
        if segment.x == x and segment.y == y then
            return true
        end
    end

    return false
end

local function spawn_flower(game)
    local availablePositions = {}

    for x = 1, game.width do
        for y = 1, game.height do
            if not is_occupied(game, x, y) then
                table.insert(availablePositions, {
                    x = x,
                    y = y
                })
            end
        end
    end

    if #availablePositions == 0 then
        return nil
    end

    return availablePositions[
        love.math.random(#availablePositions)
    ]
end

function SnakeGameSystem.initialize()
    local game = {
        gridSize = GRID_SIZE,
        moveInterval = MOVE_INTERVAL,
        moveTimer = 0,

        direction = {x = 1, y = 0},
        nextDirection = {x = 1, y = 0},

        snake = {
            {x = 10, y = 8},
            {x = 9, y = 8},
            {x = 8, y = 8}
        },

        width = 20,
        height = 15,

        flowersCollected = 0,
        flowersToWin = FLOWERS_TO_WIN,

        flower = nil,

        status = "playing"
    }

    game.flower = spawn_flower(game)

    return game
end

function SnakeGameSystem.change_direction(game, x, y)
    if game.status ~= "playing" then
        return
    end

    if x == -game.direction.x and
       y == -game.direction.y then
        return
    end

    game.nextDirection = {
        x = x,
        y = y
    }
end

function SnakeGameSystem.update(game, dt)
    if game.status ~= "playing" then
        return
    end

    game.moveTimer = game.moveTimer + dt

    if game.moveTimer < game.moveInterval then
        return
    end

    game.moveTimer = game.moveTimer - game.moveInterval

    game.direction = game.nextDirection

    local head = game.snake[1]

    local newHead = {
        x = head.x + game.direction.x,
        y = head.y + game.direction.y
    }

    -- Colision con los limites.
    if newHead.x < 1 or newHead.x > game.width or
       newHead.y < 1 or newHead.y > game.height then

        game.status = "lost"
        return
    end

    local eatingFlower =
        game.flower and
        newHead.x == game.flower.x and
        newHead.y == game.flower.y

    -- Si no come una flor, la cola se movera.
    -- Por eso no cuenta como colision su posicion actual.
    local lastSegment = game.snake[#game.snake]

    for i, segment in ipairs(game.snake) do
        local isTail = i == #game.snake

        if segment.x == newHead.x and
           segment.y == newHead.y and
           (not isTail or eatingFlower) then

            game.status = "lost"
            return
        end
    end

    table.insert(game.snake, 1, newHead)

    if eatingFlower then
        game.flowersCollected = game.flowersCollected + 1

        if game.flowersCollected >= game.flowersToWin then
            game.status = "won"
            return
        end

        game.flower = spawn_flower(game)
    else
        table.remove(game.snake)
    end
end

return SnakeGameSystem