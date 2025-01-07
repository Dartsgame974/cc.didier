local function printBook(title, text, copies)
    local pages = splitIntoPages(text)
    local printer = peripheral.find("printer")
    if not printer then
        return false, "Aucune imprimante trouvée"
    end

    -- Suppression de la page de "préparation"
    printer.endPage()

    for copy = 1, copies do
        for i, page in ipairs(pages) do
            if not printer.newPage() then
                printer.endPage()
                if not printer.newPage() then
                    return false, "Plus de papier ou d'encre"
                end
            end

            -- Définir le titre spécifique de la page
            local pageTitle = string.format("%s - Page %d", title, i)
            printer.setPageTitle(pageTitle) -- Définit le titre affiché sur l'item "Printed Page"

            -- Écrire le contenu de la page
            printer.setCursorPos(1, 1)
            printer.write(pageTitle)

            for lineNum, line in ipairs(page) do
                printer.setCursorPos(1, lineNum + 2)
                printer.write(line)
            end
        end
    end

    printer.endPage()
    return true, string.format("Livre imprimé avec succès (%d exemplaire%s)", copies, copies > 1 and "s" or "")
end
