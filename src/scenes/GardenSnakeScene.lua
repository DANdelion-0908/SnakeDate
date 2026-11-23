local SceneManager = require("src.scenes.SceneManager")
local SnakeGameSystem = require("src.systems.SnakeGameSystem")

local GardenSnakeScene = {}

function GardenSnakeScene:setup(gameState, eventBus)
    self.gameState = gameState
    self.eventBus = eventBus

    self.game = SnakeGameSystem.initialize()

    self.cellSize = 30

    self.rewardGranted = false
    self.receivedReward = false
end

function GardenSnakeScene:update(dt)
    SnakeGameSystem.update(self.game, dt)

    -- Entregar recompensa al completar el desafio.
    if self.game.status == "won" and not self.rewardGranted then

        if not self.gameState.gardenSnakeCompleted then
            self.gameState.stats.confidence =
                self.gameState.stats.confidence + 1

            self.gameState.gardenSnakeCompleted = true

            self.receivedReward = true
        end

        self.rewardGranted = true
    end
end

function GardenSnakeScene:render()
    local game = self.game
    local cellSize = self.cellSize

    love.graphics.clear(0.12, 0.28, 0.16)

    -- Cuadricula.
    love.graphics.setColor(0.2, 0.38, 0.22)

    for x = 0, game.width - 1 do
        for y = 0, game.height - 1 do
            love.graphics.rectangle(
                "line",
                x * cellSize,
                y * cellSize,
                cellSize,
                cellSize
            )
        end
    end

    -- Flor.
    if game.flower then
        love.graphics.setColor(1, 0.65, 0.8)

        love.graphics.circle(
            "fill",
            (game.flower.x - 0.5) * cellSize,
            (game.flower.y - 0.5) * cellSize,
            cellSize * 0.35
        )
    end

    -- Serpiente.
    for i, segment in ipairs(game.snake) do
        if i == 1 then
            love.graphics.setColor(0.85, 0.95, 0.35)
        else
            love.graphics.setColor(0.35, 0.75, 0.25)
        end

        love.graphics.rectangle(
            "fill",
            (segment.x - 1) * cellSize + 2,
            (segment.y - 1) * cellSize + 2,
            cellSize - 4,
            cellSize - 4,
            5,
            5
        )
    end

    -- Progreso.
    love.graphics.setColor(1, 1, 1)

    love.graphics.printf(
        "Flores: " .. game.flowersCollected ..
        " / " .. game.flowersToWin,
        0,
        460,
        800,
        "center"
    )

    -- Resultado.
    if game.status == "won" then
        love.graphics.setColor(0.7, 1, 0.5)

        love.graphics.printf(
            "¡Has completado el desafio!",
            0,
            490,
            800,
            "center"
        )

        love.graphics.setColor(1, 1, 1)

        if self.receivedReward then
            love.graphics.printf(
                "+1 de confianza",
                0,
                520,
                800,
                "center"
            )
        else
            love.graphics.printf(
                "Ya has obtenido la recompensa.",
                0,
                520,
                800,
                "center"
            )
        end

        love.graphics.printf(
            "Presiona ENTER para continuar",
            0,
            550,
            800,
            "center"
        )

        love.graphics.setColor(1, 1, 1)

    elseif game.status == "lost" then
        love.graphics.setColor(1, 0.5, 0.5)

        love.graphics.printf(
            "¡Fin del juego!",
            0,
            490,
            800,
            "center"
        )

        love.graphics.setColor(1, 1, 1)

        love.graphics.printf(
            "Presiona R para reintentar o ESC para salir",
            0,
            520,
            800,
            "center"
        )

    else
        love.graphics.setColor(1, 1, 1)

        love.graphics.printf(
            "WASD / Flechas para moverte | ESC para salir",
            0,
            510,
            800,
            "center"
        )
    end

    love.graphics.setColor(1, 1, 1)
end

function GardenSnakeScene:keypressed(key)
    local game = self.game

    if game.status == "won" then
        if key == "return" or key == "kpenter" then
            local MapScene = require("src.scenes.MapScene")
            SceneManager.change(MapScene)
        end

        return
    end

    if game.status == "lost" then
        if key == "r" then
            self.game = SnakeGameSystem.initialize()

        elseif key == "escape" then
            local MapScene = require("src.scenes.MapScene")
            SceneManager.change(MapScene)
        end

        return
    end

    if key == "up" or key == "w" then
        SnakeGameSystem.change_direction(game, 0, -1)

    elseif key == "down" or key == "s" then
        SnakeGameSystem.change_direction(game, 0, 1)

    elseif key == "left" or key == "a" then
        SnakeGameSystem.change_direction(game, -1, 0)

    elseif key == "right" or key == "d" then
        SnakeGameSystem.change_direction(game, 1, 0)

    elseif key == "escape" then
        local MapScene = require("src.scenes.MapScene")
        SceneManager.change(MapScene)
    end
end

return GardenSnakeScene