-- Programme d'impression de livres avec gestion des favoris
-- Nécessite un ordinateur et une imprimante

-- Configuration
local PAGE_WIDTH = 25  -- Largeur max d'une page
local PAGE_HEIGHT = 14 -- Hauteur max d'une page
local FAVORITES_FILE = "book_favorites.txt"

-- Fonction pour charger les favoris
local function loadFavorites()
    if not fs.exists(FAVORITES_FILE) then
        return {}
    end
    local file = fs.open(FAVORITES_FILE, "r")
    local data = textutils.unserialize(file.readAll())
    file.close()
    return data or {}
end

-- Fonction pour sauvegarder les favoris
local function saveFavorites(favorites)
    local file = fs.open(FAVORITES_FILE, "w")
    file.write(textutils.serialize(favorites))
    file.close()
end

-- Fonction pour diviser le texte en pages
local function splitIntoPages(text)
    local pages = {}
    local currentPage = {}
    local currentLine = ""
    
    for word in text:gmatch("%S+") do
        if #currentLine + #word + 1 <= PAGE_WIDTH then
            if #currentLine > 0 then
                currentLine = currentLine .. " " .. word
            else
                currentLine = word
            end
        else
            table.insert(currentPage, currentLine)
            currentLine = word
            
            if #currentPage >= PAGE_HEIGHT then
                table.insert(pages, currentPage)
                currentPage = {}
            end
        end
    end
    
    if #currentLine > 0 then
        table.insert(currentPage, currentLine)
    end
    
    if #currentPage > 0 then
        table.insert(pages, currentPage)
    end
    
    return pages
end

-- Fonction pour imprimer un livre
local function printBook(title, text)
    local pages = splitIntoPages(text)
    
    -- Vérifier si une imprimante est connectée
    local printer = peripheral.find("printer")
    if not printer then
        return false, "Aucune imprimante trouvée"
    end
    
    -- Imprimer chaque page
    for i, page in ipairs(pages) do
        if not printer.newPage() then
            return false, "Plus de papier ou d'encre"
        end
        
        -- Imprimer le titre en haut de la page
        printer.setCursorPos(1, 1)
        printer.write(title .. " - Page " .. i)
        
        -- Imprimer le contenu de la page
        for lineNum, line in ipairs(page) do
            printer.setCursorPos(1, lineNum + 2)
            printer.write(line)
        end
    end
    
    printer.endPage()
    return true, "Livre imprimé avec succès"
end

-- Interface utilisateur
local function drawMenu(selected, scroll, items, header)
    term.clear()
    term.setCursorPos(1, 1)
    print(header)
    print(string.rep("-", term.getSize()))
    
    local w, h = term.getSize()
    local maxItems = h - 5
    
    for i = scroll, math.min(scroll + maxItems - 1, #items) do
        if i == selected then
            term.setBackgroundColor(colors.gray)
            term.setTextColor(colors.white)
        else
            term.setBackgroundColor(colors.black)
            term.setTextColor(colors.white)
        end
        
        local text = items[i]
        if #text > w then
            text = text:sub(1, w - 3) .. "..."
        end
        
        term.setCursorPos(1, i - scroll + 3)
        term.write(string.rep(" ", w))
        term.setCursorPos(1, i - scroll + 3)
        print(text)
    end
    
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
end

-- Menu principal
local function mainMenu()
    local favorites = loadFavorites()
    local options = {
        "1. Imprimer depuis Pastebin",
        "2. Gérer les favoris",
        "3. Quitter"
    }
    local selected = 1
    
    while true do
        drawMenu(selected, 1, options, "Menu Principal")
        
        local event, key = os.pullEvent("key")
        if key == keys.up and selected > 1 then
            selected = selected - 1
        elseif key == keys.down and selected < #options then
            selected = selected + 1
        elseif key == keys.enter then
            if selected == 1 then
                term.clear()
                term.setCursorPos(1, 1)
                print("Entrez le lien Pastebin:")
                local link = read()
                print("Entrez le titre du livre:")
                local title = read()
                
                -- Télécharger le contenu
                local response = http.get("https://pastebin.com/raw/" .. link:match("pastebin.com/([^/]+)"))
                if response then
                    local content = response.readAll()
                    response.close()
                    
                    local success, message = printBook(title, content)
                    print(message)
                    
                    print("Voulez-vous sauvegarder ce livre en favori? (o/n)")
                    local save = read()
                    if save:lower() == "o" then
                        table.insert(favorites, {title = title, link = link})
                        saveFavorites(favorites)
                    end
                else
                    print("Erreur lors du téléchargement")
                end
                os.sleep(2)
                
            elseif selected == 2 then
                -- Menu des favoris
                local favSelected = 1
                local scroll = 1
                
                while true do
                    local favOptions = {}
                    for _, fav in ipairs(favorites) do
                        table.insert(favOptions, fav.title)
                    end
                    table.insert(favOptions, "Retour")
                    
                    drawMenu(favSelected, scroll, favOptions, "Favoris")
                    
                    local event, key = os.pullEvent("key")
                    if key == keys.up and favSelected > 1 then
                        favSelected = favSelected - 1
                        if favSelected < scroll then
                            scroll = scroll - 1
                        end
                    elseif key == keys.down and favSelected < #favOptions then
                        favSelected = favSelected + 1
                        if favSelected > scroll + (term.getSize() - 6) then
                            scroll = scroll + 1
                        end
                    elseif key == keys.enter then
                        if favSelected == #favOptions then
                            break
                        else
                            -- Imprimer le favori sélectionné
                            local fav = favorites[favSelected]
                            local response = http.get("https://pastebin.com/raw/" .. fav.link:match("pastebin.com/([^/]+)"))
                            if response then
                                local content = response.readAll()
                                response.close()
                                local success, message = printBook(fav.title, content)
                                term.clear()
                                term.setCursorPos(1, 1)
                                print(message)
                                os.sleep(2)
                            end
                        end
                    elseif key == keys.delete then
                        if favSelected < #favOptions then
                            table.remove(favorites, favSelected)
                            saveFavorites(favorites)
                            if favSelected > #favorites + 1 then
                                favSelected = #favorites + 1
                            end
                        end
                    end
                end
            elseif selected == 3 then
                term.clear()
                term.setCursorPos(1, 1)
                return
            end
        end
    end
end

-- Lancer le programme
mainMenu()
