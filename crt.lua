-- Configuration des conteneurs
local storageController = "storagedrawers:controller" -- Stockage pour cuir et fil
local pagesChest = "ironchest:crystal_chest" -- Coffre contenant les pages imprimées

-- Fonction pour récupérer un élément depuis un stockage
local function fetchItem(itemName, quantity, from)
    turtle.select(1)
    peripheral.call(from, "pullItems", storageController, itemName, quantity)
end

-- Fonction pour crafter un objet
local function craftItem()
    if turtle.craft() then
        print("Craft réussi.")
        return true
    else
        print("Échec du craft.")
        return false
    end
end

-- Fonction principale d'assemblage des pages
local function assembleBook()
    while true do
        -- Récupérer les pages imprimées
        local pages = peripheral.call(pagesChest, "list")
        if #pages == 0 then
            print("Aucune page disponible.")
            break
        end

        -- Calculer le nombre de paquets nécessaires
        local pagesToProcess = math.min(8, #pages)
        fetchItem("printed_page", pagesToProcess, pagesChest)

        -- Ajouter un fil pour assembler les pages
        fetchItem("string", 1, storageController)

        -- Crafter les pages liées
        if not craftItem() then
            print("Impossible d'assembler les pages.")
            break
        end

        -- Récupérer les paquets de pages liés
        fetchItem("linked_pages", 1, storageController)

        -- Ajouter un cuir pour finaliser le livre
        fetchItem("leather", 1, storageController)

        -- Crafter le livre final
        if not craftItem() then
            print("Impossible de lier les pages en un livre.")
            break
        end

        print("Livre assemblé avec succès.")
    end
end

-- Exécuter le programme
assembleBook()
