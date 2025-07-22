------------------------------------------------------------------------------------------------
--
--  PROJECT:         Trident Sky Company
--  VERSION:         1.0
--  FILE:            compilerC.lua
--  PURPOSE:         Automatic Compilation Tool
--  DEVELOPERS:      [BranD] - Lead Developer
--  CONTACT:         tridentskycompany@gmail.com | Discord: BrandSilva
--  COPYRIGHT:       © 2025 Brando Silva All rights reserved.
--                   This software is protected by copyright laws.
--                   Unauthorized distribution or modification is strictly prohibited.
--
------------------------------------------------------------------------------------------------

local compilationBrowser = nil
local compilationGui = nil
local isMinimized = false

function createCompilationPanel()
    if (compilationGui) then
        destroyElement(compilationGui)
        compilationGui = nil
        compilationBrowser = nil
    end
    
    local screenW, screenH = guiGetScreenSize()
    compilationGui = guiCreateBrowser(0, 0, screenW, screenH, true, true, false)
    
    if (compilationGui) then
        compilationBrowser = guiGetBrowser(compilationGui)
        addEventHandler("onClientBrowserCreated", compilationGui, onBrowserCreated)
        addEventHandler("onClientBrowserDocumentReady", compilationGui, function () end)
        guiSetVisible(compilationGui, true)
        guiBringToFront(compilationGui)
        showCursor(true)
        return true
    end
    
    return false
end

function onBrowserCreated()
    if (compilationBrowser) then
        loadBrowserURL(compilationBrowser, "http://mta/local/index.html")
        focusBrowser(compilationBrowser)
    end
end

function openCompilationPanel(scripts)
    if (not compilationGui) then
        if (createCompilationPanel()) then
            loadScriptsFromServer(scripts)
        end
    else
        if (not guiGetVisible(compilationGui)) then
            guiSetVisible(compilationGui, true)
            guiBringToFront(compilationGui)
            showCursor(true)
            focusBrowser(compilationBrowser)
            isMinimized = false
            loadScriptsFromServer(scripts)
        end
    end
end

function closePanel()
    if (compilationGui) then
        removeEventHandler("onClientBrowserDocumentReady", compilationGui, function () end)
        removeEventHandler("onClientBrowserCreated", compilationGui, onBrowserCreated)
        destroyElement(compilationGui)
        compilationGui = nil
        compilationBrowser = nil
        showCursor(false)
        isMinimized = false
    end
end
addEvent("closePanel", true)
addEventHandler("closePanel", root, closePanel)

function minimizePanel()
    if (compilationGui and guiGetVisible(compilationGui)) then
        guiSetVisible(compilationGui, false)
        showCursor(false)
        isMinimized = true
    end
end
addEvent("minimizePanel", true)
addEventHandler("minimizePanel", root, minimizePanel)

function restoreCompilationPanel()
    if (compilationGui and isMinimized) then
        guiSetVisible(compilationGui, true)
        guiBringToFront(compilationGui)
        showCursor(true)
        focusBrowser(compilationBrowser)
        isMinimized = false
    end
end

function refreshScriptsList()
    triggerServerEvent("TScompiler.requestScriptsList", localPlayer)
end
addEvent("refreshScriptsList", true)
addEventHandler("refreshScriptsList", root, refreshScriptsList)

function requestScriptsList()
    triggerServerEvent("TScompiler.requestScriptsList", localPlayer)
end
addEvent("requestScriptsList", true)
addEventHandler("requestScriptsList", root, requestScriptsList)

function startCompilation(data)
    if (data and type(data) == "string") then
        local success, result = pcall(function()
            local compilationTasks = {}
            local jsonStr = data
            
            if (string.find(jsonStr, "%[") and string.find(jsonStr, "%]")) then
                jsonStr = string.sub(jsonStr, 2, -2)
                
                local taskPattern = '{(.-)}' 
                for taskStr in string.gmatch(jsonStr, taskPattern) do
                    local task = {}
                    
                    for key, value in string.gmatch(taskStr, '"([^"]+)":([^,}]+)') do
                        value = string.gsub(value, '"', '')
                        if (value == "true") then
                            task[key] = true
                        elseif (value == "false") then
                            task[key] = false
                        else
                            task[key] = value
                        end
                    end
                    
                    if (task.resourceName) then
                        table.insert(compilationTasks, task)
                    end
                end
            end
            
            return compilationTasks
        end)
        
        if (success and result and #result > 0) then
            triggerServerEvent("TScompiler.startCompilation", localPlayer, result)
        end
    end
end
addEvent("startCompilation", true)
addEventHandler("startCompilation", root, startCompilation)

function loadScriptsFromServer(scripts)
    if (not compilationBrowser or not guiGetVisible(compilationGui)) then return end
    
    if (scripts and #scripts > 0) then
        setTimer(function()
            if (compilationBrowser and guiGetVisible(compilationGui)) then
                local jsArray = "["
                for i, script in ipairs(scripts) do
                    if (i > 1) then jsArray = jsArray .. "," end
                    
                    local clientFiles = "["
                    if (script.clientFiles) then
                        for j, file in ipairs(script.clientFiles) do
                            if (j > 1) then clientFiles = clientFiles .. "," end
                            clientFiles = clientFiles .. '"' .. file .. '"'
                        end
                    end
                    clientFiles = clientFiles .. "]"
                    
                    local serverFiles = "["
                    if (script.serverFiles) then
                        for j, file in ipairs(script.serverFiles) do
                            if (j > 1) then serverFiles = serverFiles .. "," end
                            serverFiles = serverFiles .. '"' .. file .. '"'
                        end
                    end
                    serverFiles = serverFiles .. "]"
                    
                    jsArray = jsArray .. '{'
                    jsArray = jsArray .. 'name:"' .. script.name .. '",'
                    jsArray = jsArray .. 'clientFiles:' .. clientFiles .. ','
                    jsArray = jsArray .. 'serverFiles:' .. serverFiles .. ','
                    jsArray = jsArray .. 'hasProtection:' .. (script.hasProtection and "true" or "false") .. ','
                    jsArray = jsArray .. 'clientCompiled:' .. (script.clientCompiled and "true" or "false")
                    jsArray = jsArray .. '}'
                end
                jsArray = jsArray .. "]"
                
                executeBrowserJavascript(compilationBrowser, "loadScriptsData(" .. jsArray .. ");")
            end
        end, 2000, 1)
    end
end

function updateCompilationStatus(statusData)
    if (compilationBrowser and guiGetVisible(compilationGui)) then
        executeBrowserJavascript(compilationBrowser, "updateCompilationProgress(" .. toJSON(statusData) .. ");")
    end
end

function onOpenPanel(scripts)
    openCompilationPanel(scripts)
end
addEvent("TScompiler.openPanel", true)
addEventHandler("TScompiler.openPanel", localPlayer, onOpenPanel)

function onScriptsReceived(scripts)
    loadScriptsFromServer(scripts)
end
addEvent("TScompiler.loadScripts", true)
addEventHandler("TScompiler.loadScripts", localPlayer, onScriptsReceived)

function onStatusUpdate(statusData)
    updateCompilationStatus(statusData)
end
addEvent("TScompiler.updateStatus", true)
addEventHandler("TScompiler.updateStatus", localPlayer, onStatusUpdate)