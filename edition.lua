-- Initialisation des variables
local printer = peripheral.find("printer")
local pastebinURL = "https://pastebin.com/raw/"

-- Fonction pour dessiner l'interface utilisateur
local function drawUI()
    term.clear()
    term.setCursorPos(1, 1)
    term.write("Entrez le lien Pastebin ou le code:")
    term.setCursorPos(1, 2)
    term.write("Lien: ")
    term.setCursorPos(1, 3)
    term.write("Code: ")
    term.setCursorPos(1, 4)
    term.write("Appuyez sur Entrée pour imprimer le livre.")
end

-- Fonction pour récupérer le contenu du Pastebin
local function getPastebinContent(code)
    local response = http.get(pastebinURL .. code)
    if response then
        return response.readAll()
    else
        return nil
    end
end

-- Fonction pour imprimer le livre
local function printBook(content)
    local book = {}
    for line in content:gmatch("[^\r\n]+") do
        table.insert(book, line)
    end
    printer.setPageTitle("Livre Pastebin")
    printer.setPageText(book)
    printer.printBook()
end

-- Boucle principale
while true do
    drawUI()
    term.setCursorPos(1, 5)
    term.write("Choisissez une option (1 pour lien, 2 pour code): ")
    local choice = read()

    if choice == "1" then
        term.setCursorPos(1, 6)
        term.write("Entrez le lien Pastebin: ")
        local url = read()
        local code = url:match("pastebin%.com/([%w]+)")
        if code then
            local content = getPastebinContent(code)
            if content then
                printBook(content)
            else
                term.setCursorPos(1, 7)
                term.write("Erreur: Impossible de récupérer le contenu du Pastebin.")
            end
        else
            term.setCursorPos(1, 7)
            term.write("Erreur: Lien Pastebin invalide.")
        end
    elseif choice == "2" then
        term.setCursorPos(1, 6)
        term.write("Entrez le code Pastebin: ")
        local code = read()
        local content = getPastebinContent(code)
        if content then
            printBook(content)
        else
            term.setCursorPos(1, 7)
            term.write("Erreur: Impossible de récupérer le contenu du Pastebin.")
        end
    else
        term.setCursorPos(1, 7)
        term.write("Erreur: Choix invalide.")
    end

    term.setCursorPos(1, 8)
    term.write("Appuyez sur une touche pour continuer...")
    os.pullEvent("key")
end
