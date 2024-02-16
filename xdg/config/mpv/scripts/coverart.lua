--[[
    mpv-coverart

    This script automatically loads external coverart files into mpv as additional video tracks.

    By default the script searches the folder that the current file is in, but it can also search in
    the parent folder and the current playlist. By default the script will automatically search the playlist
    if it can't access the directory of the current file (usually when playing a network file).

    For full documentation see: https://github.com/CogentRedTester/mpv-coverart
]]--

--list of options
local o = {
    --list of names of valid cover art, must be separated by semicolons with no spaces
    --the script is not case specific
    --any file with valid names and valid image extensions are loaded
    --if set to blank then image files with any name will be loaded
    names = "cover;folder;album;front",

    --valid image extensions, same syntax as the names option
    --leaving it blank will load files of any type (with the matching filename)
    --leaving both lists blank is not a good idea
    imageExts = 'jpg;jpeg;png;bmp;gif',

    --by default it only loads coverart if it detects the file is an audio file
    --an audio file is a file with audio streams and no video streams above 1 fps
    always_scan_coverart = false,

    --if false stops looking for coverart after finding a single valid file
    --and doesn't look at all if the file already has internal coverart
    load_extra_files = true,

    --file path of a placeholder image to use if no cover art is found
    --will only be used if force-window is enabled
    --leaving it blank will be the same as disabling it
    placeholder = "",

    --searches for valid coverart in the filesystem
    load_from_filesystem = true,

    --search for valid coverart in the current playlist
    --this may seem pointless, but it's useful for streaming from
    --network file servers which mpv can't usually scan
    --this entry causes the script to always search the playlist,
    --for the default behaviour described in the README see below
    load_from_playlist = false,

    --attempts to load from playlist automatically if it can't find anything on the file system
    --this overrides the load_from_playlist entry above
    auto_load_from_playlist = true,

    --If this is enabled then only valid coverart in the playlist that is
    --also in the same directory as the currently playing file will be loaded.
    --If disabled, then any valid coverart in the playlist will be loaded.
    enforce_playlist_directory = true,

    --When the file has icy-name metadata saved, search for coverart matching the file's icy-name inside
    --this directory. This is for providing coverart for radio streams, and is still experimental.
    icy_directory = "",

    --scans the parent directory for coverart as well, this
    --currently doesn't do anything when loading from a playlist
    check_parent = false,

    --skip coverart files if they are in the playlist
    skip_coverart = false,

    --this is an experimental feature
    --loads coverart synchronously during the preloading phase (after file is loaded,
    --but before playback start or track selection)
    --what this means in practice is the following:
    --  -mpv player will not start playback until all coverart is loaded
    --  -this means that on slow file/network systems playback may be delayed
    --  -'track added' messages are not printed to the console
    --  -the --vid=x property is supported since mpv doesn't attempt to select x until after covers are loaded
    --  -no more awkward switch from the black no-video screen to cover art at the start of every file (force-window=yes)
    --  -window doesn't close and reopen in-between files when playing from the terminal (force-window=no)
    --  -external coverart will be loaded by default instead of embedded images (see below to change behaviour)
    --  -may provide better compatibility with some other scripts
    preload = false,

    --tell mpv to load the given video as album art, this provides a number of optimisations and makes the
    --coverart behave more like embedded albumart
    --this is only available in mpv v0.34 (not yet released)
    --this option effectively enforces prefer_embedded
    use_albumart_flag = false,

    --prefer embedded video tracks over new external files when preload=true
    --by default mpv will select external video tracks first
    --this setting forces the first embedded file to be played first instead
    --to be specific this option just sets --vid to 1 when it is on auto
    prefer_embedded = false
}
local mp = require 'mp'
local utils = require 'mp.utils'
local msg = require 'mp.msg'
local opt = require 'mp.options'
opt.read_options(o, 'coverart')

local names = {}
local imageExts = {}
local prev = {
    directory = "",
    coverart = {}
}

o.placeholder = mp.command_native({"expand-path", o.placeholder})
o.icy_directory = mp.command_native({"expand-path", o.icy_directory})

--splits the string into a table on the semicolons
local function create_table(input)
    local t={}
    for str in string.gmatch(input, "([^;]+)") do
            t[str] = true
    end
    return t
end

--processes the option strings to ensure they work with the script
local function processStrings()
    --sets everything to lowercase to avoid confusion
    o.names = string.lower(o.names)
    o.imageExts = string.lower(o.imageExts)

    --splits the strings into tables
    names = create_table(o.names)
    imageExts = create_table(o.imageExts)
end

processStrings()

--a music file is one where mpv returns an audio stream or coverart as the first track
local function is_audio_file()
    local track_list = mp.get_property_native("track-list")

    local has_audio = false
    for _, track in ipairs(track_list) do
        if track.type == "audio" then has_audio = true
        elseif not track.albumart and (track["demux-fps"] or 2) > 1 then return false end
    end
    return has_audio
end

local function hasVideo()
    local tracks = mp.get_property_native('track-list')
    for _,v in ipairs(tracks) do
        if (v.type == "video") then
            return true
        end
    end
end

--splits filename into a name and extension
local function splitFileName(file)
    file = string.lower(file)

    --finds the file extension
    local index = file:find([[.[^.]*$]])
    if not index then return file, "" end
    local fileext = file:sub(index + 1)

    --find filename
    local filename = file:sub(0, index - 1)

    return filename, fileext
end

--checks if the given file matches the cover art requirements
local function isValidCoverart(file, icy)
    msg.debug('testing if "' .. file .. '" is valid coverart')
    local filename, fileext = splitFileName(file)

    if o.imageExts ~= "" and not imageExts[fileext] then
        msg.debug('"' .. fileext .. '" not in whitelist')
        return false
    else
        msg.debug('"' .. fileext .. '" valid, checking for valid name...')
    end

    if icy then
        if filename == mp.get_property('metadata/by-key/icy-name', ''):lower() then
            msg.debug('filename valid')
            return true
        end
    elseif  o.names == "" or names[filename] then
        msg.debug('filename valid')
        return true
    end
    msg.debug('filename invalid')
    return false
end

--a wrapper for the video-add command to choose which version of the command to send
local function videoAddWrapper(path, flag)
    if o.use_albumart_flag then mp.commandv("video-add", path, flag, "", "", "yes")
    else mp.commandv("video-add", path, flag) end
end

--adds the new file to the playing list
--if there is no video track currently selected then it autoloads track #1
local function addVideo(path, force)
    --if preload is enabled we'll add everything the same way
    --and let mpv decide the track selection based on the --vid setting
    if o.preload then
        if force then
            videoAddWrapper(path, "select")
        else
            videoAddWrapper(path, "auto")
        end

        if not o.use_albumart_flag and o.prefer_embedded and mp.get_property('options/vid', "") == "auto" then
            mp.set_property_number('file-local-options/vid', 1)
        end
        return
    end

    if  force or
        (mp.get_property_number('vid', 0) == 0
        and mp.get_property('options/vid') == "auto")
    then
        videoAddWrapper(path, "select")
    else
        videoAddWrapper(path, "auto")
    end
end

--loads a placeholder image as cover art for the file
local function loadPlaceholder()
    if  o.placeholder == ""
        or not mp.get_property_bool('force-window', false)
        or hasVideo()
    then
        return
    end

    msg.verbose('file does not have video track, loading placeholder')
    addVideo(o.placeholder)
end

--loads the coverart
local function loadCover(path)
    table.insert(prev.coverart, path)
    addVideo(path)
end

--searches and adds valid coverart from the specified directory
local function addFromDirectory(directory, is_icy)
    local files = utils.readdir(directory, "files")
    if files == nil then
        msg.verbose('no files could be loaded from "' .. directory .. '"')
        return nil
    end
    msg.verbose('scanning files in "' .. directory .. '"')

    --loops through the all the files in the directory to find if any are valid cover art
    local success = false
    for i, file in ipairs(files) do
        --if the name matches one in the whitelist then load it
        if isValidCoverart(file, is_icy) then
            msg.verbose('"' .. file .. '" is valid coverart - adding as extra video track...')
            success = true
            if not is_icy then
                loadCover(utils.join_path(directory, file))
            else
                addVideo(utils.join_path(directory, file), true)
            end
            if not o.load_extra_files then return 1 end
        end
    end
    return success
end

--finds directory information for the current file
local function findDirectory()
        --finds the local directory of the file
        local workingDirectory = mp.get_property('working-directory')
        local filepath = mp.get_property('path')
        local exact_path = utils.join_path(workingDirectory, filepath)

        --splits the directory and filename apart
        local directory = utils.split_path(exact_path)
        return workingDirectory, filepath, exact_path, directory
end

--does the actual coverart loading
local function main(workingDirectory, filepath, exact_path, directory)
    msg.verbose('loading coverart for "' .. exact_path  .. '"')

    local succeeded = false
    if o.load_from_filesystem then
        --loads the files from the directory
        succeeded = addFromDirectory(directory)
        if not o.load_extra_files and succeeded then return end

        if o.check_parent and succeeded then
            succeeded = addFromDirectory(directory .. "/../")
            if not o.load_extra_files and succeeded then return end
        end
    end
    if (succeeded == nil and o.auto_load_from_playlist) or o.load_from_playlist then
        --loads files from playlist
        msg.verbose('searching for coverart in current playlist')
        local pls = mp.get_property_native('playlist')

        for i,v in ipairs(pls)do
            local dir, name = utils.split_path(v.filename)
            if (not o.enforce_playlist_directory) or utils.join_path(workingDirectory, dir) == directory then
                if isValidCoverart(name) then
                    msg.verbose('found cover in playlist')
                    loadCover(v.filename)
                    if not o.load_extra_files then return end
                    succeeded = true
                end
            end
        end
    end

    --loads a placeholder image if no covers were found and a window is forced
    if not succeeded then loadPlaceholder() end
end

--checks if the file requires a coverart search
local function autoRunCoverart()
    --aborts the script if audio-display is disabled
    if mp.get_property('audio-display', "no") == "no" then
        msg.verbose('audio-display is disabled, aborting script')
        return
    end

    --does not look for cover art if the file is not an audio file
    if not o.always_scan_coverart and not is_audio_file() then
        msg.verbose('file is not an audio file, aborting coverart search')
        return
    end

    --if the file has video tracks then we cancel the cover lookup
    --this check won't work when preload is active
    if (not o.load_extra_files) and (mp.get_property_number('vid', 0) ~= 0) and not o.preload then
        return
    end

    --if auto is not selected, then we need to scan the tracklist to
    --see if there is existing coverart
    if  (not o.load_extra_files)
        and (mp.get_property('options/vid') ~= "auto" or o.preload)
        and hasVideo()
    then
        return
    end

    local a,b,c,directory = findDirectory()

    --checks if the directory is the same as the previous file, and if so just reloads
    --the same coverart again
    if directory == prev.directory then
        msg.verbose('Same directory as previous file, skipping coverart check')
        for _,path in ipairs(prev.coverart) do
            addVideo(path)
        end
        if #prev.coverart < 1 then
            loadPlaceholder()
        end
        return
    else
        prev.directory = directory
        prev.coverart = {}
    end

    main(a,b,c,directory)
end

--runs automatically whenever a file is loaded
if (o.preload) then
    mp.add_hook('on_preloaded', 50, autoRunCoverart)
else
    mp.register_event('file-loaded', autoRunCoverart)
end

--to force an update during runtime
mp.register_script_message('load-coverart', function()
    main(findDirectory())
end)

--resets the cache of coverart for 
mp.observe_property('playlist-count', 'number', function()
    prev.directory = ""
end)

--skips coverart in the playlist
if o.skip_coverart then
    local cover_next = true
    mp.add_hook('on_unload', 50, function()
        local playing = mp.get_property_number('playlist-playing-pos')
        local current = mp.get_property_number('playlist-current-pos')
        local count = mp.get_property_number('playlist-count')

        --handles looping front end of playing to start and vice versa
        if playing == 0 and current == count-1 then
            cover_next = false
        elseif playing == count-1 and current == 0 then
            cover_next = true

        --this is the main condition
        --when playback continues naturally playing == current
        else
            cover_next = playing <= current
        end
    end)

    mp.add_hook('on_load', 30, function()
        local filename = mp.get_property('filename', '')
        if isValidCoverart(filename) and mp.get_property_number('playlist-count') > 1 then
            msg.info('skipping coverart in playlist')
            if cover_next then
                mp.command('playlist-next')
            else
                mp.command('playlist-prev')
            end
        end
    end)
end

if o.icy_directory ~= "" then
    mp.observe_property('metadata/by-key/icy-name', 'string', function(_, name)
        if name == nil then return end
        msg.verbose('icy stream detected - loading coverart')
        addFromDirectory(o.icy_directory, true)
    end)
end
