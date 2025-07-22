------------------------------------------------------------------------------------------------
--
--  PROJECT:         Trident Sky Company
--  VERSION:         1.0
--  FILE:            compilerS.lua
--  PURPOSE:         Automatic Compilation Tool
--  DEVELOPERS:      [BranD] - Lead Developer
--  CONTACT:         tridentskycompany@gmail.com | Discord: BrandSilva
--  COPYRIGHT:       © 2025 Brando Silva All rights reserved.
--                   This software is protected by copyright laws.
--                   Unauthorized distribution or modification is strictly prohibited.
--
------------------------------------------------------------------------------------------------

local compilationQueue = {}
local isCompiling = false
local currentCompilation = nil
local resourcesToRestart = {}
local permissionACL = "L5" --[[you admin ACL here]]

function isPlayerInACLGroup(player, ...)
	if (not player or not ...) then 
        return false 
    end
	if (not isElement(player) or getElementType(player) ~= "player") then 
        return false 
    end
	local account = getPlayerAccount(player)
	if (isGuestAccount(account)) then return false end
	
	local acl = {...}
	if (#acl == 1) then	
		return isObjectInACLGroup("user."..getAccountName(account), aclGetGroup(acl[1])) or false
	else
		for i,acl in ipairs(acl) do
			if (isObjectInACLGroup("user."..getAccountName(account), aclGetGroup(acl))) then
				return true
			end
		end
		return false
	end
end

function hasPermission(player)
    if (not player or not isElement(player)) then 
        return false 
    end
    local admin = isPlayerInACLGroup(player, permissionACL)
    if (admin) then
        return true
    end
    return false
end

function isPlayerOnline(player)
    return player and isElement(player) and getElementType(player) == "player"
end

function getResourceScripts(resourceName, includeServer)
    local resource = getResourceFromName(resourceName)
    if (not resource) then return nil end
    
    local scripts = { clientFiles = {}, serverFiles = {}, hasProtection = false, clientCompiled = true }
    local metaFile = xmlLoadFile(":" .. resourceName .. "/meta.xml")
    if (not metaFile) then return scripts end
    
    for i, node in ipairs(xmlNodeGetChildren(metaFile)) do
        if (xmlNodeGetName(node) == "script") then
            local scriptPath = xmlNodeGetAttribute(node, "src")
            local scriptType = xmlNodeGetAttribute(node, "type") or "server"
            local isProtected = xmlNodeGetAttribute(node, "protected")
            local hasCache = xmlNodeGetAttribute(node, "cache")
            
            if (scriptPath) then
                if (scriptType == "client") then
                    table.insert(scripts.clientFiles, scriptPath)
                    if (isProtected == "true" or hasCache == "false") then scripts.hasProtection = true end
                    if (not string.find(scriptPath, "c$")) then
                        scripts.clientCompiled = false
                    end
                elseif (scriptType == "server" and includeServer) then
                    table.insert(scripts.serverFiles, scriptPath)
                end
            end
        end
    end
    
    xmlUnloadFile(metaFile)
    return scripts
end

function getAllResourcesData()
    local resourcesData = {}
    for i, resource in ipairs(getResources()) do
        local resourceName = getResourceName(resource)
        if (resourceName) then
            local scriptData = getResourceScripts(resourceName, true)
            if (scriptData and (#scriptData.clientFiles > 0 or #scriptData.serverFiles > 0)) then
                scriptData.name = resourceName
                table.insert(resourcesData, scriptData)
            end
        end
    end
    return resourcesData
end

function openCompilerForPlayer(player)
    if (not hasPermission(player)) then
        exports.TShelp:dm("Access denied: Insufficient permissions", player, 255, 0, 0)
        return
    end
    
    local scriptsData = getAllResourcesData()
    triggerClientEvent(player, "TScompiler.openPanel", player, scriptsData)
end

function requestScriptsList()
    if (not hasPermission(client)) then
        exports.TShelp:dm("Access denied: Insufficient permissions", client, 255, 0, 0)
        return
    end
    local scriptsData = getAllResourcesData()
    triggerClientEvent(client, "TScompiler.loadScripts", client, scriptsData)
end
addEvent("TScompiler.requestScriptsList", true)
addEventHandler("TScompiler.requestScriptsList", root, requestScriptsList)

function startCompilation(compilationTasks)
    if (not hasPermission(client)) then
        exports.TShelp:dm("Access denied: Insufficient permissions", client, 255, 0, 0)
        return
    end
    
    if (isCompiling) then
        exports.TShelp:dm("Cannot start compilation: Another compilation process is already running. Please wait for it to finish.", client, 255, 165, 0)
        return
    end
    
    if (not compilationTasks or type(compilationTasks) ~= "table" or #compilationTasks == 0) then
        exports.TShelp:dm("Error: Invalid compilation tasks", client, 255, 0, 0)
        return
    end
    
    isCompiling = true
    compilationQueue = {}
    resourcesToRestart = {}
    
    for _, task in ipairs(compilationTasks) do
        if (task.resourceName == "ALL_SERVER_SCRIPTS") then
            local allResources = getAllResourcesData()
            for _, resourceData in ipairs(allResources) do
                if (task.compileClient and #resourceData.clientFiles > 0) then
                    for _, scriptPath in ipairs(resourceData.clientFiles) do
                        table.insert(compilationQueue, {
                            player = client,
                            resourceName = resourceData.name,
                            scriptPath = scriptPath,
                            scriptType = "client",
                            enableProtection = task.enableProtection,
                            restartAfterCompile = task.restartAfterCompile
                        })
                        
                        if (task.restartAfterCompile and not resourcesToRestart[resourceData.name]) then
                            resourcesToRestart[resourceData.name] = true
                        end
                    end
                end
                
                if (task.compileServer and #resourceData.serverFiles > 0) then
                    for _, scriptPath in ipairs(resourceData.serverFiles) do
                        table.insert(compilationQueue, {
                            player = client,
                            resourceName = resourceData.name,
                            scriptPath = scriptPath,
                            scriptType = "server",
                            enableProtection = false,
                            restartAfterCompile = task.restartAfterCompile
                        })
                        
                        if (task.restartAfterCompile and not resourcesToRestart[resourceData.name]) then
                            resourcesToRestart[resourceData.name] = true
                        end
                    end
                end
            end
        elseif (task.resourceName and (task.compileClient or task.compileServer)) then
            local scriptData = getResourceScripts(task.resourceName, task.compileServer)
            if (scriptData) then
                if (task.compileClient and #scriptData.clientFiles > 0) then
                    for _, scriptPath in ipairs(scriptData.clientFiles) do
                        table.insert(compilationQueue, {
                            player = client,
                            resourceName = task.resourceName,
                            scriptPath = scriptPath,
                            scriptType = "client",
                            enableProtection = task.enableProtection,
                            restartAfterCompile = task.restartAfterCompile
                        })
                        
                        if (task.restartAfterCompile and not resourcesToRestart[task.resourceName]) then
                            resourcesToRestart[task.resourceName] = true
                        end
                    end
                end
                
                if (task.compileServer and #scriptData.serverFiles > 0) then
                    for _, scriptPath in ipairs(scriptData.serverFiles) do
                        table.insert(compilationQueue, {
                            player = client,
                            resourceName = task.resourceName,
                            scriptPath = scriptPath,
                            scriptType = "server",
                            enableProtection = false,
                            restartAfterCompile = task.restartAfterCompile
                        })
                        
                        if (task.restartAfterCompile and not resourcesToRestart[task.resourceName]) then
                            resourcesToRestart[task.resourceName] = true
                        end
                    end
                end
            end
        end
    end
    
    if (#compilationQueue == 0) then
        isCompiling = false
        exports.TShelp:dm("No files to compile", client, 255, 165, 0)
        return
    end
    
    if (isPlayerOnline(client)) then
        triggerClientEvent(client, "TScompiler.updateStatus", client, {
            type = "status",
            message = "Starting compilation of " .. #compilationQueue .. " files..."
        })
    end
    
    processNextCompilation()
end
addEvent("TScompiler.startCompilation", true)
addEventHandler("TScompiler.startCompilation", root, startCompilation)

function processNextCompilation()
    if (#compilationQueue == 0) then
        if (currentCompilation and currentCompilation.player and isPlayerOnline(currentCompilation.player)) then
            triggerClientEvent(currentCompilation.player, "TScompiler.updateStatus", currentCompilation.player, {
                type = "complete",
                message = "All files compiled successfully"
            })
            exports.TShelp:dm("Compilation completed successfully", currentCompilation.player, 0, 255, 0)
            
            setTimer(function()
                local currentResourceName = getResourceName(getThisResource())
                for resourceName, _ in pairs(resourcesToRestart) do
                    if (resourceName == currentResourceName) then
                        if (currentCompilation and currentCompilation.player and isPlayerOnline(currentCompilation.player)) then
                            exports.TShelp:dm("Compiler script compiled but will not restart to avoid interrupting the process", currentCompilation.player, 255, 255, 0)
                        end
                    else
                        local resource = getResourceFromName(resourceName)
                        if (resource and getResourceState(resource) == "running") then
                            if (currentCompilation and currentCompilation.player and isPlayerOnline(currentCompilation.player)) then
                                exports.TShelp:dm("Script " .. resourceName .. " restarting automatically", currentCompilation.player, 0, 255, 255)
                            end
                            restartResource(resource)
                        end
                    end
                end
                resourcesToRestart = {}
            end, 1000, 1)
        end
        isCompiling = false
        currentCompilation = nil
        return
    end
    
    currentCompilation = table.remove(compilationQueue, 1)
    compileScript(currentCompilation)
end

function compileScript(compilationData)
    local player = compilationData.player
    local resourceName = compilationData.resourceName
    local scriptPath = compilationData.scriptPath
    local fullPath = ":" .. resourceName .. "/" .. scriptPath
    
    local actualPath = fullPath
    if (string.find(scriptPath, "c$")) then
        local pathParts = split(scriptPath, ".")
        local nameWithoutExt = table.concat(pathParts, ".", 1, #pathParts - 1)
        local extension = pathParts[#pathParts]
        local originalExtension = string.sub(extension, 1, -2)
        local originalPath = nameWithoutExt .. "." .. originalExtension
        local originalFullPath = ":" .. resourceName .. "/" .. originalPath
        
        if (fileExists(originalFullPath)) then
            actualPath = originalFullPath
            if (isPlayerOnline(player)) then
                exports.TShelp:dm("Found updated source file: " .. originalPath .. ", compiling from source", player, 0, 255, 255)
            end
        end
    end
    
    if (not fileExists(actualPath)) then
        if (isPlayerOnline(player)) then
            exports.TShelp:dm("Error: File does not exist - " .. (actualPath == fullPath and scriptPath or string.match(actualPath, "([^/]+)$")), player, 255, 0, 0)
        end
        setTimer(processNextCompilation, 100, 1)
        return
    end
    
    local fileHandle = fileOpen(actualPath, true)
    if (not fileHandle) then
        if (isPlayerOnline(player)) then
            exports.TShelp:dm("Error: Cannot open file - " .. (actualPath == fullPath and scriptPath or string.match(actualPath, "([^/]+)$")), player, 255, 0, 0)
        end
        setTimer(processNextCompilation, 100, 1)
        return
    end
    
    local fileContent = fileRead(fileHandle, fileGetSize(fileHandle))
    fileClose(fileHandle)
    
    if (string.byte(fileContent, 1) == 28) then
        if (isPlayerOnline(player)) then
            exports.TShelp:dm("File already compiled: " .. scriptPath, player, 255, 165, 0)
        end
        setTimer(processNextCompilation, 100, 1)
        return
    end
    
    if (isPlayerOnline(player)) then
        triggerClientEvent(player, "TScompiler.updateStatus", player, {
            type = "progress",
            current = 1,
            total = #compilationQueue + 1,
            message = "Compiling: " .. scriptPath
        })
    end
    
    local success = fetchRemote("http://luac.mtasa.com/?compile=1&debug=0&obfuscate=3", onCompilationResponse, fileContent, true, compilationData)
    
    if (not success and isPlayerOnline(player)) then
        exports.TShelp:dm("Error: Failed to start compilation for " .. scriptPath, player, 255, 0, 0)
        setTimer(processNextCompilation, 500, 1)
    end
end

function onCompilationResponse(responseData, errno, compilationData)
    local player = compilationData.player
    local resourceName = compilationData.resourceName
    local scriptPath = compilationData.scriptPath
    local scriptType = compilationData.scriptType
    local enableProtection = compilationData.enableProtection
    
    if (errno ~= 0 or not responseData) then
        if (isPlayerOnline(player)) then
            exports.TShelp:dm("Error: Compilation failed for " .. scriptPath, player, 255, 0, 0)
        end
        setTimer(processNextCompilation, 500, 1)
        return
    end
    
    if (string.find(responseData, "ERROR")) then
        if (isPlayerOnline(player)) then
            exports.TShelp:dm("Compilation error in " .. scriptPath .. ": " .. responseData, player, 255, 0, 0)
        end
        setTimer(processNextCompilation, 500, 1)
        return
    end
    
    local pathParts = split(scriptPath, ".")
    local nameWithoutExt = table.concat(pathParts, ".", 1, #pathParts - 1)
    local extension = pathParts[#pathParts]
    
    local compiledExtension = extension .. "c"
    if (string.find(extension, "c$")) then
        compiledExtension = extension
    end
    
    local compiledPath = nameWithoutExt .. "." .. compiledExtension
    local fullCompiledPath = ":" .. resourceName .. "/" .. compiledPath
    
    if (fileExists(fullCompiledPath)) then fileDelete(fullCompiledPath) end
    
    local compiledFile = fileCreate(fullCompiledPath)
    if (not compiledFile) then
        if (isPlayerOnline(player)) then
            exports.TShelp:dm("Error: Cannot create compiled file - " .. compiledPath, player, 255, 0, 0)
        end
        setTimer(processNextCompilation, 500, 1)
        return
    end
    
    fileWrite(compiledFile, responseData)
    fileClose(compiledFile)
    
    if (not updateMetaXML(resourceName, scriptPath, compiledPath, scriptType, enableProtection) and isPlayerOnline(player)) then
        exports.TShelp:dm("Warning: Failed to update meta.xml for " .. scriptPath, player, 255, 165, 0)
    end
    
    if (isPlayerOnline(player)) then
        exports.TShelp:dm("Successfully compiled: " .. resourceName .. ":" .. scriptPath, player, 0, 255, 0)
    end
    
    setTimer(processNextCompilation, 500, 1)
end

function updateMetaXML(resourceName, oldFileName, newFileName, scriptType, enableProtection)
    local metaFile = xmlLoadFile(":" .. resourceName .. "/meta.xml")
    if (not metaFile) then return false end
    
    for i, node in ipairs(xmlNodeGetChildren(metaFile)) do
        if (xmlNodeGetName(node) == "script") then
            local scriptSrc = xmlNodeGetAttribute(node, "src")
            local nodeType = xmlNodeGetAttribute(node, "type")
            
            if (scriptSrc == oldFileName and nodeType == scriptType) then
                xmlNodeSetAttribute(node, "src", newFileName)
                
                if (scriptType == "client") then
                    local currentProtected = xmlNodeGetAttribute(node, "protected")
                    local currentCache = xmlNodeGetAttribute(node, "cache")
                    
                    if (enableProtection) then
                        if (currentProtected) then xmlNodeSetAttribute(node, "protected", nil) end
                        xmlNodeSetAttribute(node, "cache", "false")
                    else
                        if (currentProtected) then xmlNodeSetAttribute(node, "protected", nil) end
                        if (currentCache) then xmlNodeSetAttribute(node, "cache", nil) end
                    end
                end
                
                xmlSaveFile(metaFile)
                xmlUnloadFile(metaFile)
                return true
            end
        end
    end
    
    xmlUnloadFile(metaFile)
    return false
end

function openCompilerForPlayer(player)
    if (not hasPermission(player)) then
        exports.TShelp:dm("Access denied: Insufficient permissions", player, 255, 0, 0)
        return
    end
    
    local scriptsData = getAllResourcesData()
    triggerClientEvent(player, "TScompiler.openPanel", player, scriptsData)
end
addCommandHandler("compiler", openCompilerForPlayer)