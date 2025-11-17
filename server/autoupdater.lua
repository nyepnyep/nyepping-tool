-- Auto-updater for NMT

-- Auto-updater configuration
local AUTO_UPDATE_ENABLED = false -- Disabled due to nested directory issues with MTA file API
local AUTO_UPDATE_INTERVAL = 3600000 -- Check every hour (in milliseconds)
-- Raw GitHub URL for the repository where updates are hosted. (Updated to the provided repo)
local GITHUB_REPO_URL = "https://raw.githubusercontent.com/nyepnyep/nyepping-tool/main/"
local NMT_VERSION = "1.0.18"

-- Helper function to compare versions
local function compareVersions(v1, v2)
    local v1Parts = {}
    local v2Parts = {}
    
    for part in v1:gmatch("%d+") do
        table.insert(v1Parts, tonumber(part))
    end
    
    for part in v2:gmatch("%d+") do
        table.insert(v2Parts, tonumber(part))
    end
    
    for i = 1, math.max(#v1Parts, #v2Parts) do
        local p1 = v1Parts[i] or 0
        local p2 = v2Parts[i] or 0
        
        if p1 > p2 then
            return 1
        elseif p1 < p2 then
            return -1
        end
    end
    
    return 0
end

-- Auto-updater function
function checkForUpdates(forceCheck)
    if not AUTO_UPDATE_ENABLED and not forceCheck then
        return
    end
    
    outputDebugString("[NMT] Checking for updates...")
    
    -- Fetch the latest meta.xml to check version (with cache buster to avoid stale data)
    local cacheBuster = "?t=" .. tostring(getRealTime().timestamp)
    fetchRemote(GITHUB_REPO_URL .. "meta.xml" .. cacheBuster, function(responseData, errno)
        if errno == 0 and responseData then
            -- Parse version from meta.xml
            local latestVersion = responseData:match('version="([^"]+)"')
            
            if latestVersion then
                local comparison = compareVersions(latestVersion, NMT_VERSION)
                
                if comparison > 0 then
                    -- latestVersion is newer than NMT_VERSION
                    outputDebugString("[NMT] Update available: " .. latestVersion .. " (current: " .. NMT_VERSION .. ")")
                    outputChatBox("[NMT] Update available! New version: " .. latestVersion, root, 255, 165, 0)
                    outputChatBox("[NMT] Downloading update...", root, 255, 165, 0)
                    
                    -- Download updated files
                    downloadUpdate()
                elseif comparison < 0 then
                    outputDebugString("[NMT] Local version (" .. NMT_VERSION .. ") is newer than repository version (" .. latestVersion .. ")")
                else
                    outputDebugString("[NMT] Already up to date (version " .. NMT_VERSION .. ")")
                end
            end
        else
            -- Better error handling
            if errno == 404 then
                outputDebugString("[NMT] Update check failed: Repository or file not found (404). Check GITHUB_REPO_URL configuration.")
            elseif errno == 1 then
                outputDebugString("[NMT] Update check failed: Invalid URL")
            elseif errno == 2 then
                outputDebugString("[NMT] Update check failed: No response from server")
            elseif errno == 3 then
                outputDebugString("[NMT] Update check failed: Connection error")
            else
                outputDebugString("[NMT] Failed to check for updates: Error " .. tostring(errno))
            end
        end
    end)
end

function downloadUpdate()
    -- Dynamic downloader: fetch meta.xml from the repo, parse file entries, then download each file.
    outputDebugString("[NMT] [DEBUG] Starting downloadUpdate()")
    
    -- Add cache buster to prevent stale cached responses
    local cacheBuster = "?t=" .. tostring(getRealTime().timestamp)
    local metaURL = GITHUB_REPO_URL .. "meta.xml" .. cacheBuster
    outputDebugString("[NMT] [DEBUG] Fetching meta.xml from: " .. metaURL)
    
    fetchRemote(metaURL, function(metaData, metaErr)
        if not (metaErr == 0 and metaData) then
            outputDebugString("[NMT] Failed to fetch meta.xml for dynamic update: " .. tostring(metaErr))
            outputChatBox("[NMT] Update failed: Could not fetch meta.xml (error: " .. tostring(metaErr) .. ")", root, 255, 0, 0)
            return
        end

        outputDebugString("[NMT] [DEBUG] Successfully fetched meta.xml (" .. string.len(metaData) .. " bytes)")

        -- Collect files from meta.xml in a deterministic order.
        local filesSet = {}
        local filesList = {}

        local function addFile(path)
            if not path or path == "" then return end
            -- normalize (remove leading ./)
            path = path:gsub("^%./", "")
            if not filesSet[path] then
                filesSet[path] = true
                table.insert(filesList, path)
                outputDebugString("[NMT] [DEBUG] Added file to download list: " .. path)
            end
        end

        -- Always ensure meta.xml itself is included
        addFile("meta.xml")

        -- Parse <script src="..."> and <file src="..."> entries in meta.xml
        -- Pattern handles src attribute anywhere in the tag (before or after type, cache, etc.)
        for src in metaData:gmatch('<script[^>]+src="([^"]+)"') do
            addFile(src)
        end
        for src in metaData:gmatch('<file[^>]+src="([^"]+)"') do
            addFile(src)
        end

        if #filesList == 0 then
            outputDebugString("[NMT] No files found in meta.xml to update")
            outputChatBox("[NMT] Update failed: No files found in meta.xml", root, 255, 0, 0)
            return
        end

        outputDebugString("[NMT] [DEBUG] Total files to download: " .. #filesList)

        local resourcePath = ":" .. getResourceName(getThisResource()) .. "/"
        outputDebugString("[NMT] [DEBUG] Resource path: " .. resourcePath)
        
        local totalFiles = #filesList
        local updateCount = 0
        local successCount = 0
        local failCount = 0

        for _, fileName in ipairs(filesList) do
            -- Add cache buster to each file download to prevent stale data
            local fileCacheBuster = "?t=" .. tostring(getRealTime().timestamp)
            local downloadURL = GITHUB_REPO_URL .. fileName .. fileCacheBuster
            outputDebugString("[NMT] [DEBUG] Downloading: " .. downloadURL)
            
            fetchRemote(downloadURL, function(responseData, errno)
                updateCount = updateCount + 1
                
                if errno == 0 and responseData then
                    outputDebugString("[NMT] [DEBUG] Downloaded " .. fileName .. " (" .. string.len(responseData) .. " bytes)")
                    local filePath = resourcePath .. fileName

                    outputDebugString("[NMT] [DEBUG] Attempting to write to: " .. filePath)

                    -- Try to delete existing file first
                    if fileExists(filePath) then
                        local deleteResult = fileDelete(filePath)
                        outputDebugString("[NMT] [DEBUG] Deleted existing file: " .. filePath .. " (result: " .. tostring(deleteResult) .. ")")
                    else
                        outputDebugString("[NMT] [DEBUG] File doesn't exist yet: " .. filePath)
                    end

                    local file = fileCreate(filePath)
                    if file then
                        local writeResult = fileWrite(file, responseData)
                        fileClose(file)
                        successCount = successCount + 1
                        outputDebugString("[NMT] [DEBUG] Successfully wrote " .. fileName .. " (wrote " .. tostring(writeResult) .. " bytes)")
                        outputDebugString("[NMT] Updated: " .. fileName)

                        if updateCount == totalFiles then
                            outputDebugString("[NMT] [DEBUG] All downloads complete. Success: " .. successCount .. ", Failed: " .. failCount)
                            outputChatBox("[NMT] Update complete! Downloaded " .. successCount .. "/" .. totalFiles .. " files. Restarting resource...", root, 0, 255, 0)
                            setTimer(function()
                                restartResource(getThisResource())
                            end, 2000, 1)
                        end
                    else
                        outputDebugString("[NMT] [DEBUG] fileCreate() failed for: " .. filePath)
                        -- Likely failed due to nested directories not existing. Fall back to writing the basename and warn.
                        local basename = fileName:match("([^/\\]+)$") or fileName
                        local fallbackPath = resourcePath .. basename
                        outputDebugString("[NMT] [DEBUG] Trying fallback path: " .. fallbackPath)
                        
                        local f2 = fileCreate(fallbackPath)
                        if f2 then
                            local writeResult = fileWrite(f2, responseData)
                            fileClose(f2)
                            successCount = successCount + 1
                            outputDebugString("[NMT] [DEBUG] Fallback write successful (wrote " .. tostring(writeResult) .. " bytes)")
                            outputDebugString("[NMT] Wrote (fallback): " .. fallbackPath .. " for original " .. fileName)

                            if updateCount == totalFiles then
                                outputDebugString("[NMT] [DEBUG] All downloads complete. Success: " .. successCount .. ", Failed: " .. failCount)
                                outputChatBox("[NMT] Update complete! Downloaded " .. successCount .. "/" .. totalFiles .. " files. Restarting resource...", root, 0, 255, 0)
                                setTimer(function()
                                    restartResource(getThisResource())
                                end, 2000, 1)
                            end
                        else
                            failCount = failCount + 1
                            outputDebugString("[NMT] [DEBUG] Fallback fileCreate() also failed for: " .. fallbackPath)
                            outputDebugString("[NMT] Failed to write file (create failed): " .. fileName)
                            
                            if updateCount == totalFiles then
                                outputDebugString("[NMT] [DEBUG] All downloads complete. Success: " .. successCount .. ", Failed: " .. failCount)
                                outputChatBox("[NMT] Update incomplete! Downloaded " .. successCount .. "/" .. totalFiles .. " files. " .. failCount .. " failed.", root, 255, 165, 0)
                            end
                        end
                        outputDebugString("[NMT] Note: Could not create nested directories for '" .. fileName .. "'. Ensure resource folder structure exists on the server for full path writes.")
                    end
                else
                    failCount = failCount + 1
                    outputDebugString("[NMT] [DEBUG] Download failed for " .. fileName .. " with error: " .. tostring(errno))
                    outputDebugString("[NMT] Failed to download: " .. fileName .. " (error: " .. tostring(errno) .. ")")
                    
                    if updateCount == totalFiles then
                        outputDebugString("[NMT] [DEBUG] All downloads complete. Success: " .. successCount .. ", Failed: " .. failCount)
                        outputChatBox("[NMT] Update incomplete! Downloaded " .. successCount .. "/" .. totalFiles .. " files. " .. failCount .. " failed.", root, 255, 165, 0)
                    end
                end
            end)
        end
    end)
end

-- Start auto-updater timer on resource start
addEventHandler("onResourceStart", resourceRoot, function()
    outputChatBox("[NMT] Current version: " .. NMT_VERSION, root, 100, 200, 255)
    
    if AUTO_UPDATE_ENABLED then
        outputDebugString("[NMT] Auto-updater enabled. Checking every " .. (AUTO_UPDATE_INTERVAL / 60000) .. " minutes")
        setTimer(checkForUpdates, AUTO_UPDATE_INTERVAL, 0)
        -- Check immediately on start
        checkForUpdates()
    end
end)

-- Manual update command
addCommandHandler("nmtupdate", function(player)
    if hasObjectPermissionTo(player, "function.kickPlayer", false) then
        outputChatBox("[NMT] Current version: " .. NMT_VERSION, player, 100, 200, 255)
        outputChatBox("[NMT] Manually checking for updates...", player, 255, 165, 0)
        checkForUpdates(true) -- Pass true to force check even when auto-update is disabled
    else
        outputChatBox("[NMT] You don't have permission to use this command", player, 255, 0, 0)
    end
end)
