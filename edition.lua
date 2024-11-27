-- Nom du programme : PrintBookFromPastebin.lua

-- Vérification de la présence de l'imprimante
local printer = peripheral.find("printer")
if not printer then
    print("Erreur : Aucun périphérique 'printer' détecté.")
    return
end

-- Fonction pour dessiner une interface simple
local function drawUI()
    term.clear()
    term.setCursorPos(1, 1)
    print("=== Imprimeur de Livres Pastebin ===")
    print("1. Entrer un lien complet")
    print("2. Entrer un code seulement")
    print("3. Quitter")
end

-- Fonction pour récupérer du contenu depuis Pastebin
local function fetchFromPastebin(codeOrLink)
    local code
    if codeOrLink:find("pastebin.com/") then
        code = codeOrLink:match("pastebin.com/([%w]+)$")
    else
        code = codeOrLink
    end

    if not code then
        print("Erreur : Lien ou code invalide.")
        return nil
    end

    local response = http.get("https://pastebin.com/raw/" .. code)
    if not response then
        print("Erreur : Impossible de récupérer les données.")
        return nil
    end

    local content = response.readAll()
    response.close()
    return content
end

-- Fonction pour imprimer du texte sur un livre
local function printToBook(content)
    printer.newPage()
    printer.setPageTitle("Livre de Pastebin")

    local x, y = 1, 1
    for line in content:gmatch("[^\r\n]+") do
        if not printer.write(line) then
            -- Si une page est pleine
            printer.endPage()
            printer.newPage()
        end
        printer.write("\n")
    end

    printer.endPage()
    print("Impression terminée. Vérifiez l'imprimante.")
end

-- Boucle principale
while true do
    drawUI()
    write("Votre choix : ")
    local choice = read()

    if choice == "1" then
        write("Entrez le lien complet : ")
        local link = read()
        local content = fetchFromPastebin(link)
        if content then
            printToBook(content)
        end
    elseif choice == "2" then
        write("Entrez le code Pastebin : ")
        local code = read()
        local content = fetchFromPastebin(code)
        if content then
            printToBook(content)
        end
    elseif choice == "3" then
        print("Au revoir !")
        break
    else
        print("Choix invalide. Essayez encore.")
    end

    sleep(1)
end
