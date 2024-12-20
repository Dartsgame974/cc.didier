--[[
    Programme : Imprimante de livres avec gestion des favoris
    Auteur : ComputerCraft Genie
    Description : Permet d'imprimer des livres à partir d'un lien Pastebin,
                  de gérer des favoris et de personnaliser les titres.
]]--

-- Chemin de sauvegarde des favoris
local FAVORITES_FILE = "book_favorites.txt"

-- Fonction pour diviser une chaîne de texte en lignes d'une certaine longueur
local function splitIntoLines(text, maxWidth)
    local lines = {}
    for line in text:gmatch("[^\r\n]+") do
        while #line > maxWidth do
            table.insert(lines, line:sub(1, maxWidth))
            line = line:sub(maxWidth + 1)
        end
        table.insert(lines, line)
    end
    return lines
end

-- Fonction pour charger le contenu d'un Pastebin
local function loadFromPastebin(pastebinID)
    local url = "https://pastebin.com/raw/" .. pastebinID
    local response = http.get(url)
    if response then
        local content = response.readAll()
        response.close()
        return content
    else
        return nil, "Impossible de récupérer le contenu de Pastebin."
    end
end

-- Fonction pour imprimer un livre
local function printBook(title, content)
    if not peripheral.find("printer") then
        print("Imprimante introuvable.")
        return
    end

    local printer = peripheral.find("printer")
    printer.newPage()
    printer.setPageTitle(title)

    local lines = splitIntoLines(content, 25) -- Largeur maximale d'une ligne (25 caractères)

    for i, line in ipairs(lines) do
        printer.write(line)
        if i % 21 == 0 then -- 21 lignes par page
            printer.endPage()
            printer.newPage()
        else
            printer.write("\n")
        end
    end

    printer.endPage()
    print("Le livre a été imprimé avec succès !")
end

-- Fonction pour sauvegarder les favoris
local function saveFavorites(favorites)
    local file = fs.open(FAVORITES_FILE, "w")
    file.write(textutils.serialize(favorites))
    file.close()
end

-- Fonction pour charger les favoris
local function loadFavorites()
    if not fs.exists(FAVORITES_FILE) then return {} end
    local file = fs.open(FAVORITES_FILE, "r")
    local content = file.readAll()
    file.close()
    return textutils.unserialize(content) or {}
end

-- Fonction principale de l'interface utilisateur
local function mainMenu()
    local favorites = loadFavorites()
    while true do
        term.clear()
        term.setCursorPos(1, 1)
        print("===== Imprimante de livres =====")
        print("[1] Imprimer un livre depuis un lien Pastebin")
        print("[2] Afficher la liste des favoris")
        print("[3] Quitter")
        
        local choice = read()
        
        if choice == "1" then
            print("\nEntrez le lien Pastebin (seulement l'ID) :")
            local pastebinID = read()
            print("Entrez le titre du livre :")
            local title = read()
            local content, err = loadFromPastebin(pastebinID)
            if content then
                print("Contenu chargé ! Impression en cours...")
                printBook(title, content)
            else
                print("Erreur : " .. (err or "Inconnue"))
            end
            print("Appuyez sur une touche pour continuer.")
            read()
            
        elseif choice == "2" then
            while true do
                term.clear()
                term.setCursorPos(1, 1)
                print("===== Favoris =====")
                for i, fav in ipairs(favorites) do
                    print("[" .. i .. "] " .. fav.title)
                end
                print("[A] Ajouter un nouveau favori")
                print("[S] Supprimer un favori")
                print("[Q] Retour au menu principal")
                
                local favChoice = read()
                if favChoice == "A" or favChoice == "a" then
                    print("\nEntrez le lien Pastebin (seulement l'ID) :")
                    local pastebinID = read()
                    print("Entrez le titre du favori :")
                    local title = read()
                    table.insert(favorites, { id = pastebinID, title = title })
                    saveFavorites(favorites)
                    print("Favori ajouté avec succès !")
                    
                elseif favChoice == "S" or favChoice == "s" then
                    print("\nEntrez le numéro du favori à supprimer :")
                    local index = tonumber(read())
                    if index and favorites[index] then
                        table.remove(favorites, index)
                        saveFavorites(favorites)
                        print("Favori supprimé avec succès !")
                    else
                        print("Favori non valide.")
                    end
                    
                elseif favChoice == "Q" or favChoice == "q" then
                    break
                else
                    local index = tonumber(favChoice)
                    if index and favorites[index] then
                        local fav = favorites[index]
                        print("Chargement du favori " .. fav.title)
                        local content, err = loadFromPastebin(fav.id)
                        if content then
                            printBook(fav.title, content)
                        else
                            print("Erreur : " .. (err or "Inconnue"))
                        end
                    end
                end
                print("Appuyez sur une touche pour continuer.")
                read()
            end
            
        elseif choice == "3" then
            print("Au revoir !")
            break
            
        else
            print("Choix invalide.")
            sleep(1)
        end
    end
end

-- Lancer le programme principal
mainMenu()
