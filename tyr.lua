-- Slots:
-- Slot 1: Ficelle
-- Slot 2: Cuir
-- Slots 3-5: Pages imprimées

local function gatherItems()
    -- Récupérer la ficelle (coffre à droite)
    turtle.turnRight()
    turtle.suck(1)
    turtle.turnLeft()
    
    -- Récupérer le cuir (coffre à l'arrière)
    turtle.turnAround()
    turtle.suck(1)
    turtle.turnAround()
    
    -- Récupérer les pages imprimées (coffre à gauche)
    turtle.suck(3)
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
    turtle.turnUp()
    turtle.dropUp()
end

gatherItems()
craftBook()
storeResult()
