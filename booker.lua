if not fs.exists("basalt.lua") then
    shell.run("wget run https://basalt.madefor.cc/install.lua release latest.lua")
end

local basalt = require("basalt")

local main = basalt.createFrame()

local titleInput = main:addInput()
    :setPosition(2, 2)
    :setSize(30, 3)
    :setDefaultText("Entrez le titre du livre")

local pastebinInput = main:addInput()
    :setPosition(2, 6)
    :setSize(30, 3)
    :setDefaultText("Lien Pastebin (ex: abc123)")

local downloadButton = main:addButton()
    :setPosition(2, 10)
    :setSize(30, 3)
    :setText("Télécharger et imprimer")

local favoritesFrame = main:addFrame()
    :setPosition(35, 2)
    :setSize(25, 20)
    :setScrollable()

local favoritesTitle = favoritesFrame:addLabel()
    :setPosition(2, 1)
    :setText("⭐ Favoris")

local favoritesList = favoritesFrame:addList()
    :setPosition(2, 3)
    :setSize(20, 15)

local addFavoriteButton = main:addButton()
    :setPosition(2, 14)
    :setSize(30, 3)
    :setText("Ajouter aux Favoris")

local removeFavoriteButton = main:addButton()
    :setPosition(2, 18)
    :setSize(30, 3)
    :setText("Supprimer des Favoris")

local function formatTextToPages(text, linesPerPage)
    local pages = {}
    local currentPage = {}
    for line in text:gmatch("[^\r\n]+") do
        table.insert(currentPage, line)
        if #currentPage >= linesPerPage then
            table.insert(pages, table.concat(currentPage, "\n"))
            currentPage = {}
        end
    end
    if #currentPage > 0 then
        table.insert(pages, table.concat(currentPage, "\n"))
    end
    return pages
end

local function downloadTextFromPastebin(pastebinID)
    local url = "https://pastebin.com/raw/" .. pastebinID
    local handle, errorMessage = http.get(url)
    if handle then
        local content = handle.readAll()
        handle.close()
        return content
    else
        return nil, "Erreur de téléchargement : " .. (errorMessage or "Inconnu")
    end
end

local function printBook(title, text)
    local pages = formatTextToPages(text, 14)
    for i, page in ipairs(pages) do
        print("📘 Impression de la page " .. i .. "...")
        print(page)
    end
    print("📚 Livre imprimé avec succès !")
end

downloadButton:onClick(function()
    local title = titleInput:getValue()
    local pastebinID = pastebinInput:getValue()
    if title == "" or pastebinID == "" then
        basalt.debug("Erreur : Le titre et le lien Pastebin doivent être renseignés.")
        return
    end
    basalt.debug("Téléchargement du texte depuis Pastebin...")
    local content, errorMessage = downloadTextFromPastebin(pastebinID)
    if content then
        basalt.debug("✅ Téléchargement réussi. Impression du livre...")
        printBook(title, content)
    else
        basalt.debug(errorMessage)
    end
end)

local function loadFavorites()
    if fs.exists("favoris.txt") then
        local file = fs.open("favoris.txt", "r")
        local favorites = textutils.unserialize(file.readAll())
        file.close()
        return favorites or {}
    else
        return {}
    end
end

local function saveFavorites(favorites)
    local file = fs.open("favoris.txt", "w")
    file.write(textutils.serialize(favorites))
    file.close()
end

local function updateFavoritesList()
    favoritesList:clear()
    for _, favorite in ipairs(loadFavorites()) do
        favoritesList:addItem(favorite.title)
    end
end

addFavoriteButton:onClick(function()
    local title = titleInput:getValue()
    local pastebinID = pastebinInput:getValue()
    if title == "" or pastebinID == "" then
        basalt.debug("Erreur : Le titre et le lien Pastebin doivent être renseignés.")
        return
    end
    local favorites = loadFavorites()
    table.insert(favorites, { title = title, pastebinID = pastebinID })
    saveFavorites(favorites)
    updateFavoritesList()
    basalt.debug("✅ Livre ajouté aux favoris.")
end)

removeFavoriteButton:onClick(function()
    local selected = favoritesList:getSelectedItem()
    if not selected then
        basalt.debug("Erreur : Aucun livre sélectionné.")
        return
    end
    local favorites = loadFavorites()
    for i, favorite in ipairs(favorites) do
        if favorite.title == selected.text then
            table.remove(favorites, i)
            break
        end
    end
    saveFavorites(favorites)
    updateFavoritesList()
    basalt.debug("🗑️ Livre supprimé des favoris.")
end)

updateFavoritesList()

basalt.autoUpdate()
