-- Slots:
-- Slot 1: Ficelle
-- Slot 2: Cuir
-- Slots 3-5: Pages imprimées

-- Fonction pour faire un demi-tour
local function turnAround()
    turtle.turnRight()
    turtle.turnRight()
end

local function gatherItems()
    -- Récupérer la ficelle (coffre à droite)
    turtle.turnRight()
    turtle.suck(1)
    turtle.turnLeft()
    
    -- Récupérer le cuir (coffre à l'arrière)
    turnAround()
    turtle.suck(1)
    turnAround()
    
    -- Récupérer les pages imprimées (coffre à gauche)
    turtle.turnLeft()
    turtle.suck(3)
    turtle.turnRight()
end

local function craftBook()
    turtle.select(1) -- Ficelle
    turtle.placeDown()
    turtle.select(2) -- Cuir
    turtle.placeDown()
    turtle.select(3) -- Pages
    turtle.placeDown()
    
    if turtle.craft() then
        print("Livre crafté avec succès !")
    else
        print("Échec du craft.")
    end
end

local function storeResult()
    turtle.turnUp() -- Remplacez par la bonne commande, `turtle.turnUp()` n'existe pas
    turtle.dropUp()
end

gatherItems()
craftBook()
storeResult()
