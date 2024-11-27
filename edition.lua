-- Initialisation des variables
local monitor = peripheral.find("monitor")
local printer = peripheral.find("printer")
local pastebinURL = "https://pastebin.com/raw/"

-- Fonction pour dessiner l'interface utilisateur
local function drawUI()
    monitor.clear()
    monitor.setCursorPos(1, 1)
    monitor.write("Entrez le lien Pastebin ou le code:")
    monitor.setCursorPos(1, 2)
    monitor.write("Lien: ")
    monitor.setCursorPos(1, 3)
    monitor.write("Code: ")
    monitor.setCursorPos(1, 4)
    monitor.write("Appuyez sur Entrée pour imprimer le livre.")
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
    local event, side, x, y = os.pullEvent("monitor_touch")
    if y == 2 then
        monitor.setCursorPos(7, 2)
        local url = read()
        local code = url:match("pastebin%.com/([%w]+)")
        if code then
            local content = getPastebinContent(code)
            if content then
                printBook(content)
            else
                monitor.setCursorPos(1, 5)
                monitor.write("Erreur: Impossible de récupérer le contenu du Pastebin.")
            end
        else
            monitor.setCursorPos(1, 5)
            monitor.write("Erreur: Lien Pastebin invalide.")
        end
    elseif y == 3 then
        monitor.setCursorPos(7, 3)
        local code = read()
        local content = getPastebinContent(code)
        if content then
            printBook(content)
        else
            monitor.setCursorPos(1, 5)
            monitor.write("Erreur: Impossible de récupérer le contenu du Pastebin.")
        end
    end
end
