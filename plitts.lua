script_name('plitts')
script_version('1.46')
script_authors('Akog Weinberg', 'Luis Casper')
require 'lib.moonloader'
require 'lib.sampfuncs'


local limgui, imgui = pcall(require, 'imgui')
local imgui = require 'imgui';
local imgui = require 'imgui'
local encoding = require 'encoding'
local key = require "vkeys"
local rkeys = require 'rkeys'
imgui.HotKey = require('imgui_addons').HotKey
local events = require "lib.samp.events"
local configuration = require "inicfg"
local limadd, imadd = pcall(require, 'imgui_addons')
local sf = require 'sampfuncs'
local sp = require 'lib.samp.events'
local copas = require 'copas'
local http = require 'copas.http'
local memory = require "memory"
local dlstatus = require('moonloader').download_status
local inicfg = require 'inicfg'
encoding.default = 'CP1251'
u8 = encoding.UTF8
local sampev = require 'samp.events'

local gol = "[Голос искажён аудио-чипом]:"
local directIni = "plitts\\settings.ini"
--local stateIni = inicfg.save(mainIni, directIni)
local mainIni = inicfg.load({
    config = {
        male = true
    };
    maincfg = {
        posX = 1566,
        posY = 916,
        widehud = 350,
        hud = false,
		spawncar = false,
		fsafecmd = "fswl",
		deletekiy = false,
		smskontr = false,
		uvedkontr = false,
		autobar = false,
		autodrugs = false,
		spcancel = false,
		fbankcmd = "fbwl",
		keys = encodeJson({112}),
		ctime = 200,
		clist = 1
    };
    fsafe = {      
		key = 123,
		ak = 0,
		m4 = 100,
		de = 50,
		ri = 15,
		sh = 10,
		delay = 200
    },
	getgun = {      
		key = 122,
		ak = 0,
		m4 = 2,
		de = 1,
		ri = 1,
		sh = 0,
		arm = true
    }
},directIni)

local main_window_state = imgui.ImBool(false)
local bhelper = imgui.ImBool(false)
local commandi = imgui.ImBool(false)
local infa = imgui.ImBool(false)
local rpmenu = imgui.ImBool(false)
local nastr = imgui.ImBool(false)
local fsafeguns = imgui.ImBool(false)
local infbar = imgui.ImBool(false);
local sw, sh = getScreenResolution()
local spawncaractive = false
local fsafeactive = false
local fbankactive = false
local activecancel = false
local captureactive = false

local departament = {}
local radio = {}
local sms = {}
local ads = {}
local smsid = -1
local smstoid = -1

local fsafe = false
local fslastd = false
local fsak = false
local fsm4 = false
local fsde = false
local fsri = false
local fssh = false

local fgg = false
local arm = false
local ggak2 = 0
local ggm42 = 0
local ggde2 = 0
local ggri2 = 0
local ggsh2 = 0

local calculatorWindow = imgui.ImBool(false);
local weight, height = getScreenResolution();
local result = '';
local inputBufferText = imgui.ImBuffer(256)

local changetextpos = false

local bindID = 0
local captHotkey = {
    v = decodeJson(mainIni.maincfg.keys)
}
local spawncar = imgui.ImBool(mainIni.maincfg.spawncar)
local fsafecmd = imgui.ImBuffer(u8(mainIni.maincfg.fsafecmd), 265)
local deletekiy = imgui.ImBool(mainIni.maincfg.deletekiy)
local smskontr = imgui.ImBool(mainIni.maincfg.smskontr)
local uvedkontr = imgui.ImBool(mainIni.maincfg.uvedkontr)
local autobar = imgui.ImBool(mainIni.maincfg.autobar)
local autodrugs = imgui.ImBool(mainIni.maincfg.autodrugs)
local spcancel = imgui.ImBool(mainIni.maincfg.spcancel)
local fbankcmd = imgui.ImBuffer(u8(mainIni.maincfg.fbankcmd), 265)
local ctime = imgui.ImInt(mainIni.maincfg.ctime)
local clist = imgui.ImInt(mainIni.maincfg.clist)
local infbarb = imgui.ImBool(mainIni.maincfg.hud)
local xcord = imgui.ImInt(mainIni.maincfg.posX)
local ycord = imgui.ImInt(mainIni.maincfg.posY)
local fskey = imgui.ImInt(mainIni.fsafe.key)
local fsdelay = imgui.ImInt(mainIni.fsafe.delay)
local fsakkol = imgui.ImInt(mainIni.fsafe.ak)
local fsm4kol = imgui.ImInt(mainIni.fsafe.m4)
local fsdekol = imgui.ImInt(mainIni.fsafe.de)
local fsrikol = imgui.ImInt(mainIni.fsafe.ri)
local fsshkol = imgui.ImInt(mainIni.fsafe.sh)

local ggkey = imgui.ImInt(mainIni.getgun.key)
local ggakkol = imgui.ImInt(mainIni.getgun.ak)
local ggm4kol = imgui.ImInt(mainIni.getgun.m4)
local ggdekol = imgui.ImInt(mainIni.getgun.de)
local ggrikol = imgui.ImInt(mainIni.getgun.ri)
local ggshkol = imgui.ImInt(mainIni.getgun.sh)
local ggarm = imgui.ImBool(mainIni.getgun.arm)

local tCarsName = {"Landstalker", "Bravura", "Buffalo", "Linerunner", "Perrenial", "Sentinel", "Dumper", "Firetruck", "Trashmaster", "Stretch", "Manana", "Infernus",
"Voodoo", "Pony", "Mule", "Cheetah", "Ambulance", "Leviathan", "Moonbeam", "Esperanto", "Taxi", "Washington", "Bobcat", "Whoopee", "BFInjection", "Hunter",
"Premier", "Enforcer", "Securicar", "Banshee", "Predator", "Bus", "Rhino", "Barracks", "Hotknife", "Trailer", "Previon", "Coach", "Cabbie", "Stallion", "Rumpo",
"RCBandit", "Romero","Packer", "Monster", "Admiral", "Squalo", "Seasparrow", "Pizzaboy", "Tram", "Trailer", "Turismo", "Speeder", "Reefer", "Tropic", "Flatbed",
"Yankee", "Caddy", "Solair", "Berkley'sRCVan", "Skimmer", "PCJ-600", "Faggio", "Freeway", "RCBaron", "RCRaider", "Glendale", "Oceanic", "Sanchez", "Sparrow",
"Patriot", "Quad", "Coastguard", "Dinghy", "Hermes", "Sabre", "Rustler", "ZR-350", "Walton", "Regina", "Comet", "BMX", "Burrito", "Camper", "Marquis", "Baggage",
"Dozer", "Maverick", "NewsChopper", "Rancher", "FBIRancher", "Virgo", "Greenwood", "Jetmax", "Hotring", "Sandking", "BlistaCompact", "PoliceMaverick",
"Boxvillde", "Benson", "Mesa", "RCGoblin", "HotringRacerA", "HotringRacerB", "BloodringBanger", "Rancher", "SuperGT", "Elegant", "Journey", "Bike",
"MountainBike", "Beagle", "Cropduster", "Stunt", "Tanker", "Roadtrain", "Nebula", "Majestic", "Buccaneer", "Shamal", "hydra", "FCR-900", "NRG-500", "HPV1000",
"CementTruck", "TowTruck", "Fortune", "Cadrona", "FBITruck", "Willard", "Forklift", "Tractor", "Combine", "Feltzer", "Remington", "Slamvan", "Blade", "Freight",
"Streak", "Vortex", "Vincent", "Bullet", "Clover", "Sadler", "Firetruck", "Hustler", "Intruder", "Primo", "Cargobob", "Tampa", "Sunrise", "Merit", "Utility", "Nevada",
"Yosemite", "Windsor", "Monster", "Monster", "Uranus", "Jester", "Sultan", "Stratum", "Elegy", "Raindance", "RCTiger", "Flash", "Tahoma", "Savanna", "Bandito",
"FreightFlat", "StreakCarriage", "Kart", "Mower", "Dune", "Sweeper", "Broadway", "Tornado", "AT-400", "DFT-30", "Huntley", "Stafford", "BF-400", "NewsVan",
"Tug", "Trailer", "Emperor", "Wayfarer", "Euros", "Hotdog", "Club", "FreightBox", "Trailer", "Andromada", "Dodo", "RCCam", "Launch", "PoliceCar", "PoliceCar",
"PoliceCar", "PoliceRanger", "Picador", "S.W.A.T", "Alpha", "Phoenix", "GlendaleShit", "SadlerShit", "Luggage A", "Luggage B", "Stairs", "Boxville", "Tiller",
"UtilityTrailer"}
local tCarsTypeName = {"Автомобиль", "Мотоицикл", "Вертолёт", "Самолёт", "Прицеп", "Лодка", "Другое", "Поезд", "Велосипед"}
local tCarsSpeed = {43, 40, 51, 30, 36, 45, 30, 41, 27, 43, 36, 61, 46, 30, 29, 53, 42, 30, 32, 41, 40, 42, 38, 27, 37,
54, 48, 45, 43, 55, 51, 36, 26, 30, 46, 0, 41, 43, 39, 46, 37, 21, 38, 35, 30, 45, 60, 35, 30, 52, 0, 53, 43, 16, 33, 43,
29, 26, 43, 37, 48, 43, 30, 29, 14, 13, 40, 39, 40, 34, 43, 30, 34, 29, 41, 48, 69, 51, 32, 38, 51, 20, 43, 34, 18, 27,
17, 47, 40, 38, 43, 41, 39, 49, 59, 49, 45, 48, 29, 34, 39, 8, 58, 59, 48, 38, 49, 46, 29, 21, 27, 40, 36, 45, 33, 39, 43,
43, 45, 75, 75, 43, 48, 41, 36, 44, 43, 41, 48, 41, 16, 19, 30, 46, 46, 43, 47, -1, -1, 27, 41, 56, 45, 41, 41, 40, 41,
39, 37, 42, 40, 43, 33, 64, 39, 43, 30, 30, 43, 49, 46, 42, 49, 39, 24, 45, 44, 49, 40, -1, -1, 25, 22, 30, 30, 43, 43, 75,
36, 43, 42, 42, 37, 23, 0, 42, 38, 45, 29, 45, 0, 0, 75, 52, 17, 32, 48, 48, 48, 44, 41, 30, 47, 47, 40, 41, 0, 0, 0, 29, 0, 0
}
local tCarsType = {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 3, 1, 1, 1, 1, 1, 1, 1,
3, 1, 1, 1, 1, 6, 1, 1, 1, 1, 5, 1, 1, 1, 1, 1, 7, 1, 1, 1, 1, 6, 3, 2, 8, 5, 1, 6, 6, 6, 1,
1, 1, 1, 1, 4, 2, 2, 2, 7, 7, 1, 1, 2, 3, 1, 7, 6, 6, 1, 1, 4, 1, 1, 1, 1, 9, 1, 1, 6, 1,
1, 3, 3, 1, 1, 1, 1, 6, 1, 1, 1, 3, 1, 1, 1, 7, 1, 1, 1, 1, 1, 1, 1, 9, 9, 4, 4, 4, 1, 1, 1,
1, 1, 4, 4, 2, 2, 2, 1, 1, 1, 1, 1, 1, 1, 1, 7, 1, 1, 1, 1, 8, 8, 7, 1, 1, 1, 1, 1, 1, 1,
1, 3, 1, 1, 1, 1, 4, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 7, 1, 1, 1, 1, 8, 8, 7, 1, 1, 1, 1, 1, 4,
1, 1, 1, 2, 1, 1, 5, 1, 2, 1, 1, 1, 7, 5, 4, 4, 7, 6, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 5, 5, 5, 1, 5, 5
}

function getweaponname(weapon)
    local names = {
    [0] = "Fist",
    [1] = "Brass Knuckles",
    [2] = "Golf Club",
    [3] = "Nightstick",
    [4] = "Knife",
    [5] = "Baseball Bat",
    [6] = "Shovel",
    [7] = "Pool Cue",
    [8] = "Katana",
    [9] = "Chainsaw",
    [10] = "Purple Dildo",
    [11] = "Dildo",
    [12] = "Vibrator",
    [13] = "Silver Vibrator",
    [14] = "Flowers",
    [15] = "Cane",
    [16] = "Grenade",
    [17] = "Tear Gas",
    [18] = "Molotov Cocktail",
    [22] = "9mm",
    [23] = "Silenced 9mm",
    [24] = "Desert Eagle",
    [25] = "Shotgun",
    [26] = "Sawnoff Shotgun",
    [27] = "Combat Shotgun",
    [28] = "Micro SMG/Uzi",
    [29] = "MP5",
    [30] = "AK-47",
    [31] = "M4",
    [32] = "Tec-9",
    [33] = "Country Rifle",
    [34] = "Sniper Rifle",
    [35] = "RPG",
    [36] = "HS Rocket",
    [37] = "Flamethrower",
    [38] = "Minigun",
    [39] = "Satchel Charge",
    [40] = "Detonator",
    [41] = "Spraycan",
    [42] = "Fire Extinguisher",
    [43] = "Camera",
    [44] = "Night Vis Goggles",
    [45] = "Thermal Goggles",
    [46] = "Parachute" }
    return names[weapon]
end

function sampGetPlayerIdByNickname(nick)
    local _, myid = sampGetPlayerIdByCharHandle(playerPed)
    if tostring(nick) == sampGetPlayerNickname(myid) then return myid end
    for i = 0, 1000 do if sampIsPlayerConnected(i) and sampGetPlayerNickname(i) == tostring(nick) then return i end end
end

function apply_custom_style()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4

    style.WindowRounding = 2.0
    style.WindowTitleAlign = imgui.ImVec2(0.5, 0.84)
    style.ChildWindowRounding = 2.0
    style.FrameRounding = 2.0
    style.ItemSpacing = imgui.ImVec2(5.0, 4.0)
    style.ScrollbarSize = 13.0
    style.ScrollbarRounding = 0
    style.GrabMinSize = 8.0
    style.GrabRounding = 1.0

    colors[clr.FrameBg]                = ImVec4(0.48, 0.16, 0.16, 0.54)
    colors[clr.FrameBgHovered]         = ImVec4(0.98, 0.26, 0.26, 0.40)
    colors[clr.FrameBgActive]          = ImVec4(0.98, 0.26, 0.26, 0.67)
    colors[clr.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)
    colors[clr.TitleBgActive]          = ImVec4(0.48, 0.16, 0.16, 1.00)
    colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
    colors[clr.CheckMark]              = ImVec4(0.98, 0.26, 0.26, 1.00)
    colors[clr.SliderGrab]             = ImVec4(0.88, 0.26, 0.24, 1.00)
    colors[clr.SliderGrabActive]       = ImVec4(0.98, 0.26, 0.26, 1.00)
    colors[clr.Button]                 = ImVec4(0.98, 0.26, 0.26, 0.40)
    colors[clr.ButtonHovered]          = ImVec4(0.98, 0.26, 0.26, 1.00)
    colors[clr.ButtonActive]           = ImVec4(0.98, 0.06, 0.06, 1.00)
    colors[clr.Header]                 = ImVec4(0.98, 0.26, 0.26, 0.31)
    colors[clr.HeaderHovered]          = ImVec4(0.98, 0.26, 0.26, 0.80)
    colors[clr.HeaderActive]           = ImVec4(0.98, 0.26, 0.26, 1.00)
    colors[clr.Separator]              = colors[clr.Border]
    colors[clr.SeparatorHovered]       = ImVec4(0.75, 0.10, 0.10, 0.78)
    colors[clr.SeparatorActive]        = ImVec4(0.75, 0.10, 0.10, 1.00)
    colors[clr.ResizeGrip]             = ImVec4(0.98, 0.26, 0.26, 0.25)
    colors[clr.ResizeGripHovered]      = ImVec4(0.98, 0.26, 0.26, 0.67)
    colors[clr.ResizeGripActive]       = ImVec4(0.98, 0.26, 0.26, 0.95)
    colors[clr.TextSelectedBg]         = ImVec4(0.98, 0.26, 0.26, 0.35)
    colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
    colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94)
    colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
    colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
    colors[clr.ComboBg]                = colors[clr.PopupBg]
    colors[clr.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
    colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
    colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
    colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
    colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
    colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
    colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
    colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
    colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00)
    colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
    colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
    colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
end
apply_custom_style()

function onScriptTerminate(scr)
    if scr == script.this then
		showCursor(false)
	end
end

function libs()
    if not limgui or not events or not limadd then
        sampAddChatMessage(('[Plitts]{ffffff}: Начата загрузка недостающих библиотек'), 0xae433d)
        sampAddChatMessage(('[Plitts]{ffffff}: По окончанию загрузки скрипт будет перезагружен'), 0xae433d)
        if limgui == false then
            imgui_download_status = 'proccess'
            downloadUrlToFile('https://raw.githubusercontent.com/048PVG/imgui/main/lib/imgui.lua', 'moonloader/lib/imgui.lua', function(id, status, p1, p2)
                if status == dlstatus.STATUS_DOWNLOADINGDATA then
                    imgui_download_status = 'proccess'
                    print(string.format('Загружено %d килобайт из %d килобайт.', p1, p2))
                elseif status == dlstatus.STATUS_ENDDOWNLOADDATA then
                    imgui_download_status = 'succ'
                elseif status == 64 then
                    imgui_download_status = 'failed'
                end
            end)
            while imgui_download_status == 'proccess' do wait(0) end
            if imgui_download_status == 'failed' then
                print('Не удалось загрузить: imgui.lua')
                thisScript():unload()
            else
                print('Файл: imgui.lua успешно загружен')
                if doesFileExist('moonloader/lib/MoonImGui.dll') then
                    print('Imgui был загружен')
                else
                    imgui_download_status = 'proccess'
                    downloadUrlToFile('https://raw.githubusercontent.com/048PVG/imgui/main/lib/MoonImGui.dll', 'moonloader/lib/MoonImGui.dll', function(id, status, p1, p2)
                        if status == dlstatus.STATUS_DOWNLOADINGDATA then
                            imgui_download_status = 'proccess'
                            print(string.format('Загружено %d килобайт из %d килобайт.', p1, p2))
                        elseif status == dlstatus.STATUS_ENDDOWNLOADDATA then
                            imgui_download_status = 'succ'
                        elseif status == 64 then
                            imgui_download_status = 'failed'
                        end
                    end)
                    while imgui_download_status == 'proccess' do wait(0) end
                    if imgui_download_status == 'failed' then
                        print('Не удалось загрузить Imgui')
                        thisScript():unload()
                    else
                        print('Imgui был загружен')
                    end
                end
            end
        end
        if not events then
            local folders = {'samp', 'samp/events'}
            local files = {'events.lua', 'raknet.lua', 'synchronization.lua', 'events/bitstream_io.lua', 'events/core.lua', 'events/extra_types.lua', 'events/handlers.lua', 'events/utils.lua'}
            for k, v in pairs(folders) do if not doesDirectoryExist('moonloader/lib/'..v) then createDirectory('moonloader/lib/'..v) end end
            for k, v in pairs(files) do
                sampev_download_status = 'proccess'
                downloadUrlToFile('https://raw.githubusercontent.com/048PVG/imgui/tree/main/lib/samp/'..v, 'moonloader/lib/samp/'..v, function(id, status, p1, p2)
                    if status == dlstatus.STATUS_DOWNLOADINGDATA then
                        sampev_download_status = 'proccess'
                        print(string.format('Загружено %d килобайт из %d килобайт.', p1, p2))
                    elseif status == dlstatus.STATUS_ENDDOWNLOADDATA then
                        sampev_download_status = 'succ'
                    elseif status == 64 then
                        sampev_download_status = 'failed'
                    end
                end)
                while sampev_download_status == 'proccess' do wait(0) end
                if sampev_download_status == 'failed' then
                    print('Не удалось загрузить sampev')
                    thisScript():unload()
                else
                    print(v..' был загружен')
                end
            end
        end
        if not limadd then
            imadd_download_status = 'proccess'
            downloadUrlToFile('https://raw.githubusercontent.com/048PVG/imgui/main/lib/imgui_addons.lua', 'moonloader/lib/imgui_addons.lua', function(id, status, p1, p2)
                if status == dlstatus.STATUS_DOWNLOADINGDATA then
                    imadd_download_status = 'proccess'
                    print(string.format('Загружено %d килобайт из %d килобайт.', p1, p2))
                elseif status == dlstatus.STATUS_ENDDOWNLOADDATA then
                    imadd_download_status = 'succ'
                elseif status == 64 then
                    imadd_download_status = 'failed'
                end
            end)
            while imadd_download_status == 'proccess' do wait(0) end
            if imadd_download_status == 'failed' then
                print('Не удалось загрузить imgui_addons.lua')
                thisScript():unload()
            else
                print('imgui_addons.lua был загружен')
            end
        end
        sampAddChatMessage(('[Plitts]{ffffff}: Все необходимые библиотеки были загружены'), 0xae433d)
        reloadScripts()
    else
        print('Все необходиме библиотеки были найдены и загружены')
    end
end

function getColorForSeconds(sec)
	if sec > 0 and sec <= 50 then
		return imgui.ImVec4(1, 1, 0, 1)
	elseif sec > 50 and sec <= 100 then
		return imgui.ImVec4(1, 159/255, 32/255, 1)
	elseif sec > 100 and sec <= 200 then
		return imgui.ImVec4(1, 93/255, 24/255, 1)
	elseif sec > 200 and sec <= 300 then
		return imgui.ImVec4(1, 43/255, 43/255, 1)
	elseif sec > 300 then
		return imgui.ImVec4(1, 0, 0, 1)
	end
end

function getColor(ID)
	PlayerColor = sampGetPlayerColor(ID)
	a, r, g, b = explode_argb(PlayerColor)
	return r/255, g/255, b/255, 1
end

function explode_argb(argb)
    local a = bit.band(bit.rshift(argb, 24), 0xFF)
    local r = bit.band(bit.rshift(argb, 16), 0xFF)
    local g = bit.band(bit.rshift(argb, 8), 0xFF)
    local b = bit.band(argb, 0xFF)
    return a, r, g, b
end

function httpRequest(request, body, handler)
    if not copas.running then
        copas.running = true
        lua_thread.create(function()
            wait(0)
            while not copas.finished() do
                local ok, err = copas.step(0)
                if ok == nil then error(err) end
                wait(0)
            end
            copas.running = false
        end)
    end
    if handler then
        return copas.addthread(function(r, b, h)
            copas.setErrorHandler(function(err) h(nil, err) end)
            h(http.request(r, b))
        end, request, body, handler)
    else
        local results
        local thread = copas.addthread(function(r, b)
            copas.setErrorHandler(function(err) results = {nil, err} end)
            results = table.pack(http.request(r, b))
        end, request, body)
        while coroutine.status(thread) ~= 'dead' do wait(0) end
        return table.unpack(results)
    end
end

function saveIniFile()
    local inicfgsaveparam = inicfg.save(mainIni,directIni)
end

function kvadrat1(param)
    local KV = {
        ["А"] = 1,
        ["Б"] = 2,
        ["В"] = 3,
        ["Г"] = 4,
        ["Д"] = 5,
        ["Ж"] = 6,
        ["З"] = 7,
        ["И"] = 8,
        ["К"] = 9,
        ["Л"] = 10,
        ["М"] = 11,
        ["Н"] = 12,
        ["О"] = 13,
        ["П"] = 14,
        ["Р"] = 15,
        ["С"] = 16,
        ["Т"] = 17,
        ["У"] = 18,
        ["Ф"] = 19,
        ["Х"] = 20,
        ["Ц"] = 21,
        ["Ч"] = 22,
        ["Ш"] = 23,
        ["Я"] = 24,
        ["а"] = 1,
        ["б"] = 2,
        ["в"] = 3,
        ["г"] = 4,
        ["д"] = 5,
        ["ж"] = 6,
        ["з"] = 7,
        ["и"] = 8,
        ["к"] = 9,
        ["л"] = 10,
        ["м"] = 11,
        ["н"] = 12,
        ["о"] = 13,
        ["п"] = 14,
        ["р"] = 15,
        ["с"] = 16,
        ["т"] = 17,
        ["у"] = 18,
        ["ф"] = 19,
        ["х"] = 20,
        ["ц"] = 21,
        ["ч"] = 22,
        ["ш"] = 23,
        ["я"] = 24,
    }
    return KV[param]
end

function kvadrat()
    local KV = {
        [1] = "А",
        [2] = "Б",
        [3] = "В",
        [4] = "Г",
        [5] = "Д",
        [6] = "Ж",
        [7] = "З",
        [8] = "И",
        [9] = "К",
        [10] = "Л",
        [11] = "М",
        [12] = "Н",
        [13] = "О",
        [14] = "П",
        [15] = "Р",
        [16] = "С",
        [17] = "Т",
        [18] = "У",
        [19] = "Ф",
        [20] = "Х",
        [21] = "Ц",
        [22] = "Ч",
        [23] = "Ш",
        [24] = "Я",
    }
    local X, Y, Z = getCharCoordinates(playerPed)
    X = math.ceil((X + 3000) / 250)
    Y = math.ceil((Y * - 1 + 3000) / 250)
    Y = KV[Y]
    local KVX = (Y.."-"..X)
    return KVX
end

function getFreeSeat()
    seat = 3
    if isCharInAnyCar(PLAYER_PED) then
        local veh = storeCarCharIsInNoSave(PLAYER_PED)
        for i = 1, 3 do
            if isCarPassengerSeatFree(veh, i) then
                seat = i
            end
        end
    end
    return seat
end

function isHudEnabled()
    local value = memory.read(0xBA6769, 1, true)
    if value == 1 then return true else return false end
end

function getNameSphere(id)
    local names =
    {
      [1] = 'АВ',
      [2] = 'АШ',
      [3] = 'СФа',
      [4] = 'В',
      [5] = 'А',
      [6] = 'СФн',
      [7] = 'Тоннель',
      [8] = 'Мэрия',
      [9] = 'Хот-Доги',
      [10] = 'Больница ЛС',
      [11] = 'АВ',
      [12] = 'Мост',
      [13] = 'Перекресток',
      [14] = 'Развилка',
      [15] = 'В',
      [16] = 'А',
      [17] = 'В',
      [18] = 'С',
      [19] = 'КПП',
      [20] = 'Порт ЛС',
      [21] = 'Опасный район',
      [32] = 'КПП',
      [33] = 'D',
      [34] = 'Холл Мэрии',
      [35] = 'Авторынок'
    }
    return names[id]
end

function saveData(table, path)
	if doesFileExist(path) then os.remove(path) end
    local sfa = io.open(path, "w")
    if sfa then
        sfa:write(encodeJson(table))
        sfa:close()
    end
end

function sampev.onServerMessage(color, text)
	if (string.find(text, "Выезд занят другим транспортным средством")) then
		spawncaractive = false
		return true
	end
	if (string.find(text, "Данный дом не привязан к Вашей семье")) then
		spawncaractive = false
		return true
	end
	if (string.find(text, "Отправитель: Контрабандист")) and mainIni.maincfg.smskontr then
		return false
	end
	if (string.find(text, "Сообщает: Контрабандист")) and mainIni.maincfg.uvedkontr then
		return false
	end
    if (string.find(text, "Семейный склад закрыт")) or (string.find(text, "Вы не можете взять со склада более")) or (string.find(text, "Недостаточно патронов")) then
		fsafe = false
		fsak = false
		sfm4 = false
		sfde = false
		fsri = false
		fssh = false
		return true
	end
	if (string.find(text, "Склад закрыт")) then
		fgg = false
		arm = false
		return true
	end
end

if limgui then
    function imgui.TextQuestion(text)
        imgui.TextDisabled('(?)')
        if imgui.IsItemHovered() then
            imgui.BeginTooltip()
            imgui.PushTextWrapPos(450)
            imgui.TextUnformatted(text)
            imgui.PopTextWrapPos()
            imgui.EndTooltip()
        end
    end
    function imgui.CentrText(text)
        local width = imgui.GetWindowWidth()
        local calc = imgui.CalcTextSize(text)
        imgui.SetCursorPosX( width / 2 - calc.x / 2 )
        imgui.Text(text)
    end
    function imgui.CustomButton(name, color, colorHovered, colorActive, size)
        local clr = imgui.Col
        imgui.PushStyleColor(clr.Button, color)
        imgui.PushStyleColor(clr.ButtonHovered, colorHovered)
        imgui.PushStyleColor(clr.ButtonActive, colorActive)
        if not size then size = imgui.ImVec2(0, 0) end
        local result = imgui.Button(name, size)
        imgui.PopStyleColor(3)
        return result
    end
function imgui.OnDrawFrame()

    if infbar.v then
        imgui.ShowCursor = false
        _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
        local myname = sampGetPlayerNickname(myid)
        local myping = sampGetPlayerPing(myid)
        local myweapon = getCurrentCharWeapon(PLAYER_PED)
        local myweaponammo = getAmmoInCharWeapon(PLAYER_PED, myweapon)
        local valid, ped = getCharPlayerIsTargeting(PLAYER_HANDLE)
        local myweaponname = getweaponname(myweapon)
        imgui.SetNextWindowPos(imgui.ImVec2(mainIni.maincfg.posX, mainIni.maincfg.posY), imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(mainIni.maincfg.widehud, 160), imgui.Cond.FirstUseEver)
        imgui.Begin(script.this.name, infbar, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoTitleBar)
        imgui.Text((u8"Информация:"):format(myname, myid, myping))
        imgui.SameLine()
        imgui.TextColored(imgui.ImVec4(getColor(myid)), u8('%s [%s]'):format(myname, myid))
        imgui.SameLine()
        imgui.Text((u8"| Пинг: %s"):format(myping))
        --imgui.Text((u8 'Оружие: %s [%s]'):format(myweaponname, myweaponammo))
        if getAmmoInClip() ~= 0 then
            imgui.Text((u8 "Оружие: %s [%s/%s]"):format(myweaponname, getAmmoInClip(), myweaponammo - getAmmoInClip()))
        else
            imgui.Text((u8 'Оружие: %s'):format(myweaponname))
        end
        if isCharInAnyCar(playerPed) then
            local vHandle = storeCarCharIsInNoSave(playerPed)
            local result, vID = sampGetVehicleIdByCarHandle(vHandle)
            local vHP = getCarHealth(vHandle)
            local carspeed = getCarSpeed(vHandle)
            local speed = math.floor(carspeed)
            local vehName = tCarsName[getCarModel(storeCarCharIsInNoSave(playerPed))-399]
            local ncspeed = math.floor(carspeed*2)
            imgui.Text((u8 'Транспорт: %s [%s] | HP: %s | Скорость: %s'):format(vehName, vID, vHP, ncspeed))
        else
            imgui.Text(u8 'Транспорт: Нет')
        end
        if valid and doesCharExist(ped) then 
            local result, id = sampGetPlayerIdByCharHandle(ped)
            if result then
                local targetname = sampGetPlayerNickname(id)
                local targetscore = sampGetPlayerScore(id)
                imgui.Text((u8 'Цель: %s [%s] | Уровень: %s'):format(targetname, id, targetscore))
            else
                imgui.Text(u8 'Цель: Нет')
            end
        else
            imgui.Text(u8 'Цель: Нет')
        end
        imgui.Text((u8 'Квадрат: %s'):format(u8(kvadrat())))
        imgui.Text((u8 'Время: %s'):format(os.date('%H:%M:%S')))
        if imgui.IsMouseClicked(0) and changetextpos then
            changetextpos = false
            sampToggleCursor(false)
            main_window_state.v = true
            saveData(cfg, 'moonloader/config/plitts/config.json')
        end
        imgui.End()
    end

    if calculatorWindow.v then
        imgui.ShowCursor = true;
        imgui.SetNextWindowSize(imgui.ImVec2(weight / 5.5, height / 3.5), imgui.Cond.FirstUseEver);
        imgui.SetNextWindowPos(imgui.ImVec2(weight / 2, height /2), imgui.Cond.FirstUseEver);
        imgui.Begin(u8'##ЗДАРОВА БАНДИТ', calculatorWindow, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar);
		imgui.BeginChild('##ЕТО ПАСХАЛКА', imgui.ImVec2(weight / 5.9, height / 3.7), true);
        imgui.Text(result);
        imgui.InputText(u8'##ЛЮБЛЮ ТЕБЯ <3', inputBufferText);
        if imgui.Button('7', imgui.ImVec2(40, 40)) then
            inputBufferText.v = string.format('%s7', inputBufferText.v);
        end
        imgui.SameLine();
        if imgui.Button('8', imgui.ImVec2(40, 40)) then
            inputBufferText.v = string.format('%s8', inputBufferText.v);
        end
        imgui.SameLine();
        if imgui.Button('9', imgui.ImVec2(40, 40)) then
            inputBufferText.v = string.format('%s9', inputBufferText.v);
        end
		imgui.SameLine();
		if imgui.Button('/', imgui.ImVec2(40, 40)) then
			local bufferFirstNum, bufferAct = result:match('(%d+)(.+)');
			if tonumber(bufferFirstNum) then
				local numResult = tonumber(bufferFirstNum) / tonumber(inputBufferText.v);
				result = string.format('%s/', tostring(numResult));
				inputBufferText.v = '';
			else
				result = string.format('%s/', inputBufferText.v);
				inputBufferText.v = '';
			end
		end
		imgui.SameLine();
		if imgui.Button('CLR', imgui.ImVec2(40, 40)) then
            inputBufferText.v = '';
			result = '';
        end
		--imgui.SameLine();
        if imgui.Button('4', imgui.ImVec2(40, 40)) then
            inputBufferText.v = string.format('%s4', inputBufferText.v);
        end
        imgui.SameLine();
        if imgui.Button('5', imgui.ImVec2(40, 40)) then
            inputBufferText.v = string.format('%s5', inputBufferText.v);
        end
        imgui.SameLine();
        if imgui.Button('6', imgui.ImVec2(40, 40)) then
            inputBufferText.v = string.format('%s6', inputBufferText.v);
        end
		imgui.SameLine();
		if imgui.Button('*', imgui.ImVec2(40, 40)) then
			local bufferFirstNum, bufferAct = result:match('(%d+)(.+)');
			if tonumber(bufferFirstNum) then
				local numResult = tonumber(bufferFirstNum) * tonumber(inputBufferText.v);
				result = string.format('%s*', tostring(numResult));
				inputBufferText.v = '';
			else
				result = string.format('%s*', inputBufferText.v);
				inputBufferText.v = '';
			end
        end
		imgui.SameLine();
		if imgui.Button('SQRT', imgui.ImVec2(40, 40)) then
			if tonumber(inputBufferText.v) then
				local bufferResult = math.sqrt(tonumber(inputBufferText.v));
				result = tostring(bufferResult);
			end
		end
        if imgui.Button('1', imgui.ImVec2(40, 40)) then
            inputBufferText.v = string.format('%s1', inputBufferText.v);
        end
        imgui.SameLine();
        if imgui.Button('2', imgui.ImVec2(40, 40)) then
            inputBufferText.v = string.format('%s2', inputBufferText.v);
        end
        imgui.SameLine();
        if imgui.Button('3', imgui.ImVec2(40, 40)) then
            inputBufferText.v = string.format('%s3', inputBufferText.v);
        end
		imgui.SameLine();
		if imgui.Button('-', imgui.ImVec2(40, 40)) then
            local bufferFirstNum, bufferAct = result:match('(%d+)(.+)');
			if tonumber(bufferFirstNum) then
				local numResult = tonumber(bufferFirstNum) - tonumber(inputBufferText.v);
				result = string.format('%s-', tostring(numResult));
				inputBufferText.v = '';
			else
				result = string.format('%s-', inputBufferText.v);
				inputBufferText.v = '';
			end
        end
		imgui.SameLine();
		if imgui.Button('^', imgui.ImVec2(40, 40)) then
			result = string.format('%s^', inputBufferText.v);
			inputBufferText.v = '';
		end
		if imgui.Button('0', imgui.ImVec2(89, 40)) then
            inputBufferText.v = string.format('%s0', inputBufferText.v);
        end
		imgui.SameLine();
		if imgui.Button('+', imgui.ImVec2(40, 40)) then
			local bufferFirstNum, bufferAct = result:match('(%d+)(.+)');
			if tonumber(bufferFirstNum) then
				local numResult = tonumber(bufferFirstNum) + tonumber(inputBufferText.v);
				result = string.format('%s+', tostring(numResult));
				inputBufferText.v = '';
			else
				result = string.format('%s+', inputBufferText.v);
				inputBufferText.v = '';
			end
        end
		imgui.SameLine();
		if imgui.Button('=', imgui.ImVec2(40, 40)) then
			local bufferFirstNum, bufferAct = result:match('(%d+)(.+)');
			if bufferAct == '+' then
				local numResult = tonumber(bufferFirstNum) + tonumber(inputBufferText.v);
				result = tostring(numResult);
			elseif bufferAct == '-' then
				local numResult = tonumber(bufferFirstNum) - tonumber(inputBufferText.v);
				result = tostring(numResult);
			elseif bufferAct == '/' then
				local numResult = tonumber(bufferFirstNum) / tonumber(inputBufferText.v);
				result = tostring(numResult);
			elseif bufferAct == '*' then
				local numResult = tonumber(bufferFirstNum) * tonumber(inputBufferText.v);
				result = tostring(numResult);
			elseif bufferAct == '^' then
				local numResult = tonumber(bufferFirstNum) ^ tonumber(inputBufferText.v);
				result = tostring(numResult);
			end
			inputBufferText.v = '';
		end
		imgui.EndChild();
        imgui.End();
    else
        imgui.ShowCursor = false;
    end

if rpmenu.v then
    imgui.ShowCursor = true
    local x, y = getScreenResolution()
    local btn_size = imgui.ImVec2(-0.1, 0)  
    imgui.SetNextWindowPos(imgui.ImVec2(x/2, y/2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.SetNextWindowSize(imgui.ImVec2(400, 300), imgui.Cond.FirstUseEver) 
    imgui.Begin(u8('Plitts | Отыгровки'), rpmenu, imgui.WindowFlags.NoResize)
    if imgui.Button(u8'Связать. (pohit1)', btn_size) then rpmenu.v = false
    wagering = lua_thread.create(function ()
		sampAddChatMessage(' [Plitts]{ffffff} Старт отыгровки. Для отмены нажмите K > Остановить отыгровку.', 0xae433d)
		wait(100)
		sampSendChat(("/me %s из-под сиденья верёвку затем %s руки и ноги человека"):format(mainIni.config.male and 'достал' or 'достала', mainIni.config.male and 'связал' or 'связала'))
        wait(2000)
        sampSendChat(("/me %s из-под сиденья мешок затем %s на голову человека"):format(mainIni.config.male and 'достал' or 'достала', mainIni.config.male and 'надел' or 'надела'))
		wait(2000)
        sampSendChat("/do У человека связаны руки и ноги, на голове надет мешок, он ничего не видит.")
		wait(100)
		sampAddChatMessage(' [Plitts]{ffffff} Конец отыгровки.', 0xae433d)
		end)
		end
		if imgui.Button(u8'Затащить в авто. (pohit2)', btn_size) then
		rpmenu.v = false
		wagering = lua_thread.create(function ()
		sampAddChatMessage(' [Plitts]{ffffff} Старт отыгровки. Для отмены нажмите K > Остановить отыгровку.', 0xae433d)
		wait(100)	
		sampSendChat(("/me %s за одежду человека затем %s в сторону машины"):format(mainIni.config.male and 'схватился' or 'схватилась', mainIni.config.male and 'потащил' or 'потащила'))
        wait(2000)
        sampSendChat(("/me %s дверь авто затем %s человека в машину"):format(mainIni.config.male and 'открыл' or 'открыла', mainIni.config.male and 'закинул' or 'закинула'))
        wait(100)
		sampAddChatMessage(' [Plitts]{ffffff} Конец отыгровки.', 0xae433d)
		end)
		end
        if imgui.Button(u8'Музыка в тачке. (musora)', btn_size) then
        rpmenu.v = false
        wagering = lua_thread.create(function ()
        sampAddChatMessage(' [Plitts]{ffffff} Старт отыгровки. Для отмены нажмите K > Остановить отыгровку.', 0xae433d)
        wait(100)
        sampSendChat(("/me резким движением %s на кнопку активации центрального замка"):format(mainIni.config.male and 'нажал' or 'нажала'))
        wait(1500)
        sampSendChat("/do Двери машины заблокированы.")
        wait(1500)
        sampSendChat(("/me резким движением %s под сиденье пакетик, телефон, оружие"):format(mainIni.config.male and 'скинул' or 'скинула'))
        wait(1500)
        sampSendChat("/do Пренадлежности были скинуты далеко под сиденье, под сиденьем лежало много мусора.")
        wait(1500)
        sampSendChat("/do В салоне громко играет музыка - Morgenshtern Cadillak Remix, ничего не слышно.")
        wait(1500)
        sampSendChat("/do Стёкла автомобился затонированы, просмотреть невозможно.")
        wait(100)
        sampAddChatMessage(' [Plitts]{ffffff} Конец отыгровки.', 0xae433d)
        end)
        end
		if imgui.Button(u8'Полная маскировка себя. (pohit3)', btn_size) then
		rpmenu.v = false
		wagering = lua_thread.create(function ()
		sampAddChatMessage(' [Plitts]{ffffff} Старт отыгровки. Для отмены нажмите K > Остановить отыгровку.', 0xae433d)
		wait(100)
		sampSendChat("/do Неизвестный одет в джинсовую курточку из номекса тёмно-синего цвета.")
        wait(2000)
        sampSendChat("/do На курточке нашивки «1%», «Мрачный Жнец», другие распознавательные знаки отсутствуют.")
        wait(2000)
        sampSendChat("/do Лицо скрыто балаклавой, надеты тёмные очки, личность не распознать.")
		wait(100)
		sampAddChatMessage(' [Plitts]{ffffff} Конец отыгровки.', 0xae433d)
		end)
		end
		if imgui.Button(u8'Полная маскировка всех стоящих рядом. (pohit4)', btn_size) then
		rpmenu.v = false
		wagering = lua_thread.create(function ()
		sampAddChatMessage(' [Plitts]{ffffff} Старт отыгровки. Для отмены нажмите K > Остановить отыгровку.', 0xae433d)
		wait(100)
		sampSendChat("/do Неизвестные одеты в джинсовые курточки из номекса тёмно-синего цвета.")
        wait(2000)
        sampSendChat("/do На курточке нашивки «1%», «Мрачный Жнец», другие распознавательные знаки отсутствуют.")
        wait(2000)
        sampSendChat("/do Лица скрыты балаклавами, надеты тёмные очки, личности не распознать.")
		wait(100)
		sampAddChatMessage(' [Plitts]{ffffff} Конец отыгровки.', 0xae433d)
		end)
		end
		if imgui.Button(u8'Маскировка автомобиля и сидящих в нем. (pohit5)', btn_size) then
		rpmenu.v = false
		wagering = lua_thread.create(function ()
		sampAddChatMessage(' [Plitts]{ffffff} Старт отыгровки. Для отмены нажмите K > Остановить отыгровку.', 0xae433d)
		wait(100)	
		sampSendChat("/do Водитель и пассажиры находятся в автомобиле без опозновательных знаков.")
        wait(2000)
        sampSendChat("/do Автомобиль полностью бронирован, номерные знаки отсутствуют, шины пулестойкие.")
        wait(2000)
        sampSendChat("/do Стекла автомобиля затонированы, личность водителя и пассажиров не распознать.")
		wait(100)
		sampAddChatMessage(' [Plitts]{ffffff} Конец отыгровки.', 0xae433d)
		end)
		end
		if imgui.Button(u8'Надеть противогаз. (18 секунд)', btn_size) then
		rpmenu.v = false
		wagering = lua_thread.create(function ()
		sampAddChatMessage(' [Plitts]{ffffff} Старт отыгровки. Для отмены нажмите K > Остановить отыгровку.', 0xae433d)
		wait(100)	
		sampSendChat("/do На бедре левой ноги висит подсумок с противогазом ГП-21.")
        wait(4000)
        sampSendChat(("/me задержав дыхание, %s противогаз и ловким движением %s его"):format(mainIni.config.male and 'достал' or 'достала', mainIni.config.male and 'надел' or 'надела'))
        wait(1200)
        sampSendChat("/anim 6 50")
		wait(7000)
        sampSendChat(("/me повернул крышку фильтра, затем %s глубокий вдох"):format(mainIni.config.male and 'сделал' or 'сделала'))
		wait(3000)
        sampSendChat("/time 1")
		wait(1200)
        sampSendChat(("/me %s время работы фильтра противогаза"):format(mainIni.config.male and 'засек' or 'засекла'))
		wait(100)
		sampAddChatMessage(' [Plitts]{ffffff} Конец отыгровки.', 0xae433d)
		end)
		end
		if imgui.Button(u8'ПМП при ранении. (35 секунд)', btn_size) then
		rpmenu.v = false
		wagering = lua_thread.create(function ()
		sampAddChatMessage(' [Plitts]{ffffff} Старт отыгровки. Для отмены нажмите K > Остановить отыгровку.', 0xae433d)
		wait(100)	
		sampSendChat(("/me %s из подсумка разгрузки перевязочный пакет ИПП-1 и аптечку АИ-4"):format(mainIni.config.male and 'достал' or 'достала'))
        wait(5000)
        sampSendChat("/anim 6 49")
        wait(2000)
        sampSendChat("/me осматривает рану")
		wait(7000)
        sampSendChat(("/me %s из аптечки АИ-4 белый шприц-тюбик содержащий кеторол"):format(mainIni.config.male and 'достал' or 'достала'))
		wait(7000)
        sampSendChat(("/me %s белый шприц-тюбик внутримышечно рядом с местом ранения"):format(mainIni.config.male and 'вколол' or 'вколола'))
		wait(7000)
        sampSendChat(("/me %s перевязочный пакет и крепко перевязал рану"):format(mainIni.config.male and 'открыл' or 'открыла'))
		wait(7000)
        sampSendChat(("/me %s медицинский инвентарь, после чего убрал его в подсумок разгрузки"):format(mainIni.config.male and 'сложил' or 'сложила'))
		wait(100)
		sampAddChatMessage(' [Plitts]{ffffff} Конец отыгровки.', 0xae433d)
		end)
		end
		if imgui.Button(u8'Подготовка к взлету на вертолете. (11 секунд)', btn_size) then
		rpmenu.v = false
		wagering = lua_thread.create(function ()
		sampAddChatMessage(' [Plitts]{ffffff} Старт отыгровки. Для отмены нажмите K > Остановить отыгровку.', 0xae433d)
		wait(100)	
		sampSendChat("/todo Диспетчер, борт MAV-497 готов к вылету..*одев наушники пилота")
        wait(7000)
        sampSendChat("/me быстрым движением руки включает необходимые приборы для взлета")
        wait(4000)
        sampSendChat("/do В кабине вертолета раздается характерный звук щелчков. Лопасти начинают раскручиваться.")
		wait(100)
		sampAddChatMessage(' [Plitts]{ffffff} Конец отыгровки.', 0xae433d)
		end)
		end
		if imgui.Button(u8'Замена пластин бронежилета из багажника. (16 секунд)', btn_size) then
		rpmenu.v = false
		wagering = lua_thread.create(function ()
		sampAddChatMessage(' [Plitts]{ffffff} Старт отыгровки. Для отмены нажмите K > Остановить отыгровку.', 0xae433d)
		wait(100)	
		sampSendChat(("/me %s целостность железных пластин в бронежилете"):format(mainIni.config.male and 'проверил' or 'проверила'))
        wait(4000)
        sampSendChat("/do В бронежилете повреждено несколько железных пластин от выстрелов.")
        wait(5000)
        sampSendChat(("/me %s из бронежилета поврежденные пластины, затем %s их в багажник авто"):format(mainIni.config.male and 'вытащил' or 'вытащила', mainIni.config.male and 'бросил' or 'бросила'))
		wait(1200)
		sampSendChat("/anim 6 49")
		wait(6000)
        sampSendChat(("/me %s из багажника новые платистины, затем %s их в бронежилет"):format(mainIni.config.male and 'достал' or 'достала', mainIni.config.male and 'вставил' or 'вставила'))
		wait(1200)
		sampSendChat("/anim 6 49")
		wait(100)
		sampAddChatMessage(' [Plitts]{ffffff} Конец отыгровки. Чтобы снять стан после анимки, сделайте блок(ПКМ + Shift) или удар кулаком.', 0xae433d)
        end)
        end
        if imgui.Button(u8("Остановить отыгровку"), btn_size) then
		    rpmenu.v = false

		    sampAddChatMessage("Plitts {ffffff}| Отыгровка остановлена.", 11420477)
		    wagering:terminate()
		end
		imgui.End()
		end
				




  if main_window_state.v then
    imgui.ShowCursor = true
    local x, y = getScreenResolution()
    local btn_size = imgui.ImVec2(-0.1, 0)  
    imgui.SetNextWindowPos(imgui.ImVec2(x/2, y/2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.SetNextWindowSize(imgui.ImVec2(300, 300), imgui.Cond.FirstUseEver) 
    imgui.Begin(u8('Plitts | Главное меню | Версия: ' .. thisScript().version), main_window_state, imgui.WindowFlags.NoResize)
    if imgui.Button(u8'Команды и функции скрипта', btn_size) then
	commandi.v = not commandi.v
    end
    if imgui.Button(u8'Конфиг', btn_size) then
        bhelper.v = not bhelper.v
    end
    if imgui.Button(u8'Быстрый fsafe', btn_size) then
        fsafeguns.v = not fsafeguns.v
    end
	if imgui.Button(u8'Настройки', btn_size) then
	 nastr.v = not nastr.v
	 end
	 	 if imgui.CollapsingHeader(u8 'Действия со скриптом', btn_size) then
	 if imgui.Button(u8'Перезагрузить скрипт', btn_size) then
    thisScript():reload()
    end
    if imgui.Button(u8 'Отключить скрипт', btn_size) then
    thisScript():unload()
    end
    if imgui.Button(u8'О скрипте', btn_size) then
        infa.v = not infa.v
      end
	end
	 imgui.End()
    end
  
  
  
  if nastr.v then
  mainIni = inicfg.load(nil, directIni)
  stateb = imgui.ImBool(mainIni.config.male)
  imgui.ShowCursor = true
    local x, y = getScreenResolution()
    local btn_size = imgui.ImVec2(-0.1, 0)  
    imgui.SetNextWindowPos(imgui.ImVec2(x/2, y/2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.SetNextWindowSize(imgui.ImVec2(700, 400), imgui.Cond.FirstUseEver) 
    imgui.Begin(u8('Plitts | Настройки'), nastr, imgui.WindowFlags.NoResize)
    if imadd.ToggleButton(u8 'Инфобар', infbarb) then mainIni.maincfg.hud = infbarb.v saveData(cfg, 'moonloader/config/plitts/config.json') end imgui.SameLine() imgui.Text(u8 "Инфо-бар")
        if infbarb.v then
        imgui.SameLine()
        if imgui.Button(u8 'Изменить местоположение', -1) then
        main_window_state.v = false
        changetextpos = true
        sampAddChatMessage('По завешению нажмите левую кнопку мыши', -1)
        end
    end
	if imadd.ToggleButton(u8'Мужские отыгровки', stateb) then
	mainIni.config.male = stateb.v
	inicfg.save(mainIni, directIni)
	end 
	imgui.SameLine(); imgui.Text(u8 'Мужские отыгровки')
    imgui.End()
	end


    if fsafeguns.v then 
        imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(450, 500), imgui.Cond.FirstUseEver)
		imgui.Begin("Plitts | Fast fsafe", fsafeguns)
        imgui.Separator()
        imgui.SetCursorPosX(180)
		imgui.Text(u8"Настройки  fsafe")
		imgui.Separator()
		imgui.Text(u8"Код клавиши активации (По умолчанию F12 - 123): ")
		imgui.SameLine()
		imgui.PushItemWidth(100)
        if imgui.InputInt(u8"##fskey", fskey, 0 , 0) then
			mainIni.fsafe.key = tonumber(fskey.v)
			saveIniFile()
		end
        imgui.PopItemWidth()
		imgui.Text(u8"Количество патронов АК (0 для отключения): ")
		imgui.SameLine()
		imgui.PushItemWidth(100)
        if imgui.InputInt(u8"##fsakkol", fsakkol) then
			mainIni.fsafe.ak = tonumber(fsakkol.v)
			saveIniFile()
		end
        imgui.PopItemWidth()
		imgui.Text(u8"Количество патронов M4 (0 для отключения): ")
		imgui.SameLine()
		imgui.PushItemWidth(100)
        if imgui.InputInt(u8"##fsm4kol", fsm4kol) then
			mainIni.fsafe.m4 = tonumber(fsm4kol.v)
			saveIniFile()
        end
        imgui.PopItemWidth()
		imgui.Text(u8"Количество патронов Deagle (0 для отключения): ")
		imgui.SameLine()
		imgui.PushItemWidth(100)
        if imgui.InputInt(u8"##fsdekol", fsdekol) then
			mainIni.fsafe.de = tonumber(fsdekol.v)
			saveIniFile()
        end
        imgui.PopItemWidth()
		imgui.Text(u8"Количество патронов Rifle (0 для отключения): ")
		imgui.SameLine()
		imgui.PushItemWidth(100)
        if imgui.InputInt(u8"##fsrikol", fsrikol) then
			mainIni.fsafe.ri = tonumber(fsrikol.v)
			saveIniFile()
        end
        imgui.PopItemWidth()
		imgui.Text(u8"Количество патронов Shotgun (0 для отключения): ")
		imgui.SameLine()
		imgui.PushItemWidth(100)
        if imgui.InputInt(u8"##fsshkol", fsshkol) then
			mainIni.fsafe.sh = tonumber(fsshkol.v)
			saveIniFile()
        end
        imgui.PopItemWidth()
		imgui.Text(u8"Задержка: ")
		imgui.SameLine()
		imgui.PushItemWidth(100)
        if imgui.InputInt(u8"##fsdelay", fsdelay, 50) then
			mainIni.fsafe.delay = tonumber(fsdelay.v)
			saveIniFile()
        end
        imgui.PopItemWidth()
		imgui.Separator()
		imgui.SetCursorPosX(180)
		imgui.Text(u8"Настройки  getgun")
		imgui.Separator()
		imgui.Text(u8"Код клавиши активации (По умолчанию F11 - 122): ")
		imgui.SameLine()
		imgui.PushItemWidth(100)
        if imgui.InputInt(u8"##ggkey", ggkey, 0 , 0) then
			mainIni.getgun.key = tonumber(ggkey.v)
			saveIniFile()
		end
        imgui.PopItemWidth()
		imgui.Text(u8"Сколько раз брать АК (0 для отключения): ")
		imgui.SameLine()
		imgui.PushItemWidth(100)
        if imgui.InputInt(u8"##ggakkol", ggakkol) then
			mainIni.getgun.ak = tonumber(ggakkol.v)
			ggak2 = tonumber(ggakkol.v)
			saveIniFile()
		end
        imgui.PopItemWidth()
		imgui.Text(u8"Сколько раз брать M4 (0 для отключения): ")
		imgui.SameLine()
		imgui.PushItemWidth(100)
        if imgui.InputInt(u8"##ggm4kol", ggm4kol) then
			mainIni.getgun.m4 = tonumber(ggm4kol.v)
			ggm42 = tonumber(ggm4kol.v)
			saveIniFile()
        end
        imgui.PopItemWidth()
		imgui.Text(u8"Сколько раз брать Deagle (0 для отключения): ")
		imgui.SameLine()
		imgui.PushItemWidth(100)
        if imgui.InputInt(u8"##ggdekol", ggdekol) then
			mainIni.getgun.de = tonumber(ggdekol.v)
			ggde2 = tonumber(ggdekol.v)
			saveIniFile()
        end
        imgui.PopItemWidth()
		imgui.Text(u8"Сколько раз брать Rifle (0 для отключения): ")
		imgui.SameLine()
		imgui.PushItemWidth(100)
        if imgui.InputInt(u8"##ggrikol", ggrikol) then
			mainIni.getgun.ri = tonumber(ggrikol.v)
			ggri2 = tonumber(ggrikol.v)
			saveIniFile()
        end
        imgui.PopItemWidth()
		imgui.Text(u8"Сколько раз брать Shotgun (0 для отключения): ")
		imgui.SameLine()
		imgui.PushItemWidth(100)
        if imgui.InputInt(u8"##ggshkol", ggshkol) then
			mainIni.getgun.sh = tonumber(ggshkol.v)
			ggsh2 = tonumber(ggshkol.v)
			saveIniFile()
        end
        imgui.PopItemWidth()
		if imgui.Checkbox(u8"Брать броню", ggarm) then
			mainIni.getgun.arm = ggarm.v
			saveIniFile()
        end
		imgui.Separator()
		imgui.End()
    end


  if bhelper.v then
        mainIni = inicfg.load(nil, directIni)
        imgui.ShowCursor = true
        local tLastKeys = {}
        local sw, sh = getScreenResolution()
      	imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(450, 500), imgui.Cond.FirstUseEver)
				imgui.Begin(u8("Plitts.lua for PLITTS CREW Family"), bhelper, imgui.WindowFlags.NoResize)
                imgui.Separator()
				imgui.SetCursorPosX(150)
				imgui.Text(u8"Настройки функций для семьи")
				imgui.Separator()
				if imgui.Checkbox(u8"Автоспавн свободной семейной машины при открытии меню дома", spawncar) then
						mainIni.maincfg.spawncar = spawncar.v
						saveIniFile()
        end
				imgui.Text(u8'Команда открытия/закрытия сейфа семьи: ')
				imgui.SameLine()
				imgui.PushItemWidth(50)
				if imgui.InputText(u8"##fsafecmd", fsafecmd) then
					sampUnregisterChatCommand(mainIni.maincfg.fsafecmd)
					mainIni.maincfg.fsafecmd = tostring(u8:decode(fsafecmd.v))
					saveIniFile()
					sampRegisterChatCommand(mainIni.maincfg.fsafecmd, function() sampSendChat("/fpanel"); fsafeactive = true end)
				end
				imgui.PopItemWidth()
				imgui.Text(u8'Команда открытия/закрытия банка семьи: ')
				imgui.SameLine()
				imgui.PushItemWidth(50)
				if imgui.InputText(u8"##fbankcmd", fbankcmd) then
					sampUnregisterChatCommand(mainIni.maincfg.fbankcmd)
					mainIni.maincfg.fbankcmd = tostring(u8:decode(fbankcmd.v))
					saveIniFile()
					sampRegisterChatCommand(mainIni.maincfg.fbankcmd, function() sampSendChat("/fpanel"); fbankactive = true end)
				end
				imgui.PopItemWidth()
				imgui.Separator()
				imgui.SetCursorPosX(150)
				imgui.Text(u8"Настройки общих функций для байкеров")
				imgui.Separator()
				if imgui.Checkbox(u8"Удалять кий", deletekiy) then
						mainIni.maincfg.deletekiy = deletekiy.v
						saveIniFile()
        end
				if imgui.Checkbox(u8"Не показывать SMS от Контрабандиста", smskontr) then
						mainIni.maincfg.smskontr = smskontr.v
						saveIniFile()
        end
				if imgui.Checkbox(u8"Не показывать уведомления о поставках Контрабандиста", uvedkontr) then
						mainIni.maincfg.uvedkontr = uvedkontr.v
						saveIniFile()
        end
				if imgui.Checkbox(u8"При открытии меню бара автопополнение до фулла", autobar) then
						mainIni.maincfg.autobar = autobar.v
						saveIniFile()
        end
				if imgui.Checkbox(u8"Автовзятие нарко со склада до максимума", autodrugs) then
						mainIni.maincfg.autodrugs = autodrugs.v
						saveIniFile()
        end
				if imgui.Checkbox(u8"Автоспавн и отмена фур с сырьём в лаборатории", spcancel) then
						mainIni.maincfg.spcancel = spcancel.v
						saveIniFile()
        end
				imgui.Separator()
				imgui.SetCursorPosX(150)
				imgui.Text(u8"Настройки автокаптера для байкеров")
				imgui.Separator()
				imgui.Text(u8("Старт/стоп флуд [Изменяется после перезахода]: "))
				imgui.SameLine()
				if imgui.HotKey('##tesst', captHotkey, tLastKeys, 150) then
		        mainIni.maincfg.keys = encodeJson(captHotkey.v)
		        saveIniFile()
		    end
				imgui.Text(u8"Задержка: ")
				imgui.SameLine()
				imgui.PushItemWidth(100)
        if imgui.InputInt(u8"##ctime", ctime) then
					mainIni.maincfg.ctime = tonumber(ctime.v)
					saveIniFile()
        end
        imgui.PopItemWidth()
				imgui.Text(u8"Номер бизнеса: ")
				imgui.SameLine()
				imgui.PushItemWidth(100)
        if imgui.InputInt(u8"##clist", clist) then
					mainIni.maincfg.clist = tonumber(clist.v)
					saveIniFile()
        end
        imgui.PopItemWidth()
				imgui.Separator()
				imgui.End()
		    end

  
  if commandi.v then
    imgui.ShowCursor = true
    local x, y = getScreenResolution()
    local btn_size = imgui.ImVec2(-0.1, 0)  
    imgui.SetNextWindowPos(imgui.ImVec2(x/2, y/2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.SetNextWindowSize(imgui.ImVec2(500, 400), imgui.Cond.FirstUseEver) 
    imgui.Begin(u8('Plitts | Команды и функции скрипта'), commandi, imgui.WindowFlags.NoResize)
	imgui.Text(u8'• Прицел и Numpad 3 - Оглушение')
	imgui.Text(u8'• /bc - [Голос искажён аудио-чипом]')
	imgui.Text(u8'• Прицел и Numpad 6 - Обыск на прослушку')
	imgui.Text(u8'• Numpad * - Натянуть маску на лицо / Снять с маску с лица')
	imgui.Text(u8'• Прицел и Numpad 9 - Прием')
	imgui.Text(u8'• Numpad 5 - Кричалка')
	imgui.Text(u8'• Numpad + - Посмотреть на часы')
	imgui.Text(u8'• L - Открыть транспорт')
	imgui.Text(u8'• J - открыть меню скрипта')
	imgui.Text(u8'• K - открыть меню РП отыгровок')
    imgui.Text(u8'• /smslog - открыть лог последних SMS')
    imgui.Text(u8'• /rlog - открыть лог рации')
    imgui.Text(u8'• /dlog - открыть лог рации департамента')
    imgui.Text(u8'• /adlog - открыть лог объявлений')
    imgui.Text(u8'• BB(два раза) - открыть калькулятор')
    imgui.Text(u8'• P - /empty')
	imgui.End()
end

if infa.v then
	imgui.ShowCursor = true
    local x, y = getScreenResolution()
    local btn_size = imgui.ImVec2(-0.1, 0)  
    imgui.SetNextWindowPos(imgui.ImVec2(x/2, y/2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.SetNextWindowSize(imgui.ImVec2(500, 200), imgui.Cond.FirstUseEver)
    imgui.Begin(u8('Plitts | О скрипте'), infa, imgui.WindowFlags.NoResize)
	imgui.Text(u8'• За основу скрипта был взят скрипт Abrahama Nortona rrsg.lua версии 1.5')
    imgui.Text(u8'• За основу функций "Конфиг", "fsafe" были взяты скрипты Franchesko')
    imgui.Text(u8'• Если будут идеи по улучшению, пишите в вк - >> vk.com/frojez <<')
    imgui.Text(u8'• plitts.lua for Evolve Role Play. Author: Akog Weinberg. Help: Luis Casper')
	imgui.End()
end
end
end

function main()
	repeat wait(0); until isSampAvailable();
	while not isSampAvailable() do wait(100) end
      sampAddChatMessage("{1E90FF}Plitts {ffffff}| Авторы: {BD2626}" .. table.concat(script.this.authors, ", "))
      sampAddChatMessage("{1E90FF}Plitts {ffffff}| Нажмите на {BD2626}J{ffffff} чтобы открыть меню скрипта.", -1)
	  sampAddChatMessage("{1E90FF}Plitts {ffffff}| Нажмите на {BD2626}K{ffffff} чтобы открыть меню RP отыгровок.", -1)
	  sampRegisterChatCommand("bc", bc)
      sampRegisterChatCommand('dlog', dlog)
      sampRegisterChatCommand('rlog', rlog)
      sampRegisterChatCommand('smslog', smslog)
      sampRegisterChatCommand('adlog', adlog)
      sampRegisterChatCommand("calc", function() calculatorWindow.v = not calculatorWindow end)
	  sampRegisterChatCommand(mainIni.maincfg.fsafecmd, function() sampSendChat("/fpanel"); fsafeactive = true end)
	  sampRegisterChatCommand(mainIni.maincfg.fbankcmd, function() sampSendChat("/fpanel"); fbankactive = true end)
	  bindID = rkeys.registerHotKey(captHotkey.v, true, function ()
			captureactive = not captureactive
			if captureactive then
				sampAddChatMessage("{013220}[Plitts] {ffffff}Флудер /capture запущен. Для отключения нажмите клавишу еще раз.", -1)
			else
				sampAddChatMessage("{013220}[Plitts] {ffffff}Флудер /capture остановлен.", -1)
			end
	    end)
  while true do
    wait(0)
    infbar = imgui.ImBool(mainIni.maincfg.hud)
    if changetextpos then
        sampToggleCursor(true)
        local CPX, CPY = getCursorPos()
        mainIni.maincfg.posX = CPX
        mainIni.maincfg.posY = CPY
    end
    if isKeyJustPressed(18) and not isPauseMenuActive() and isPlayerPlaying(PLAYER_HANDLE) and not sampIsChatInputActive() and not sampIsDialogActive() then
        spawncaractive = true
    end
    if mainIni.maincfg.deletekiy then
        local weapon = getCurrentCharWeapon(PLAYER_PED)
        if weapon == 7 then
            removeWeaponFromChar(PLAYER_PED, weapon)
        end
    end
    if activecancel then
        wait(400)
        activecancel = false
        sampSendChat("/cancel")
        sampSendDialogResponse(1757, 1, 7, -1)
        wait(200)
        sampCloseCurrentDialogWithButton(0)
    end
    if captureactive then
        sampSendChat("/capture")
        sampSendDialogResponse(32700, 1, mainIni.maincfg.clist - 1, -1)
        wait(mainIni.maincfg.ctime)
    end	
    if #departament > 25 then table.remove(departament, 1) end
    if #radio > 25 then table.remove(radio, 1) end
    if #sms > 25 then table.remove(sms, 1) end
    if #ads > 25 then table.remove(ads, 1) end
		if isKeyJustPressed(mainIni.fsafe.key) and not isPauseMenuActive() and isPlayerPlaying(PLAYER_HANDLE) and not sampIsChatInputActive() and not sampIsDialogActive() then
            imgui.Process = fsafeguns.v
			sampSendChat("/fsafe")
			fsafe = true
			fsak = true
			fsm4 = true
			fsde = true
			fsri = true
			fssh = true
		end
		if isKeyJustPressed(mainIni.getgun.key) and not isPauseMenuActive() and isPlayerPlaying(PLAYER_HANDLE) and not sampIsChatInputActive() and not sampIsDialogActive() then
		    sampSendChat("/healme")
			fgg = true
			arm = true
			ggak2 = mainIni.getgun.ak
			ggm42 = mainIni.getgun.m4
			ggde2 = mainIni.getgun.de
			ggri2 = mainIni.getgun.ri
			ggsh2 = mainIni.getgun.sh
			wait(1000)
			sampSendChat("/getgun")
		end
		
		if mainIni.fsafe.ak <= 0 then
			fsak = false
		end
		if mainIni.fsafe.m4 <= 0 then
			fsm4 = false
		end
		if mainIni.fsafe.de <= 0 then
			fsde = false
		end
		if mainIni.fsafe.ri <= 0 then
			fsri = false
		end
		if mainIni.fsafe.sh <= 0 then
			fssh = false
		end
    if not sampIsChatInputActive() then
    if testCheat('BB') then
        calculatorWindow.v = not calculatorWindow.v;
        imgui.Process = calculatorWindow.v;
    end
    end
	if testCheat("J") then main_window_state.v = true
	end
	if testCheat("K") then rpmenu.v = true
	end
    if not sampIsChatInputActive() then
    if isKeyJustPressed(VK_NUMPAD5) then
    sampSendChat("/s Упали лицами в пол, никому не двигаться, убиваем не колебаясь.")
	end
    end
    if not sampIsChatInputActive() then
     if isKeyJustPressed(VK_P) then
     sampSendChat("/empty")
    end
    end
    if not sampIsChatInputActive() then
      if isKeyJustPressed(VK_NUMPAD3) then
       lua_thread.create(function()
        sampSendChat(("/me резким движением руки %s человека стоящего напротив прикладом оружия"):format(mainIni.config.male and 'вырубил' or 'вырубила'))
        wait(1100)
        sampSendChat("/do Человек потерял сознание от удара прикладом.")
		end)
    end
    end
     if isKeyJustPressed(VK_ADD) then sampSendChat("/time 1")
      end
      if testCheat("L") then sampSendChat("/lock")
      end
			if isKeyJustPressed(VK_MULTIPLY) then
				sampSendChat("/mask")
			end
      if isKeyJustPressed(VK_NUMPAD9) then
        local valid, ped = getCharPlayerIsTargeting(PLAYER_HANDLE)
        if valid then
            result, targetid = sampGetPlayerIdByCharHandle(ped)
            if result then
              local name = sampGetPlayerNickname(targetid)
       lua_thread.create(function()
        sampSendChat(("/me резко %s, заломав руки " ..name.. " и выбив с них оружие"):format(mainIni.config.male and 'развернулся' or 'развернулась'))
		end)
        end
      end
      end
      if isKeyJustPressed(VK_NUMPAD6) then
        local valid, ped = getCharPlayerIsTargeting(PLAYER_HANDLE)
        if valid then
            result, targetid = sampGetPlayerIdByCharHandle(ped)
            if result then
              local name = sampGetPlayerNickname(targetid)
      lua_thread.create(function()
        sampSendChat(("/me %s " ..name.. " на наличие средств связи"):format(mainIni.config.male and 'обыскал' or 'обыскала'))
        wait(5000)
        sampSendChat(("/me %s у " ..name.. " найденные средства связи"):format(mainIni.config.male and 'забрал' or 'забрала'))
        wait(3000)
        sampSendChat("/do У " ..name.. " изъята рация и телефон.")
		end)
        end
      end
      end
    imgui.Process = main_window_state.v or commandi.v or rpmenu.v or nastr.v or infa.v or bhelper.v or calculatorWindow.v or fsafeguns.v or infbar.v
	apply_custom_style()
	libs()
    saveIniFile()
end
end

function registerCommands()
    if sampIsChatCommandDefined('dlog') then sampUnregisterChatCommand('dlog') end
    if sampIsChatCommandDefined('rlog') then sampUnregisterChatCommand('rlog') end
    if sampIsChatCommandDefined('smslog') then sampUnregisterChatCommand('smslog') end
    if sampIsChatCommandDefined('adlog') then sampUnregisterChatCommand('adlog') end
end

function bc(text)
	if text == '' then
		sampAddChatMessage("{913719}Plitts {ffffff}| /bc [текст]", -1)
	else
		sampSendChat(gol ..' '..text)
	end
end

function sp.onServerMessage(color, text)
    if color == -8224086 then
        local colors = ("{%06X}"):format(bit.rshift(color, 8))
        table.insert(departament, os.date(colors.."[%H:%M:%S] ") .. text)
    end
    if color == -1920073984 and (text:match('.+ .+%: .+') or text:match('%(%( .+ .+%: .+ %)%)')) then
        local colors = ("{%06X}"):format(bit.rshift(color, 8))
        table.insert(radio, os.date(colors.."[%H:%M:%S] ") .. text)
    end
    if color == -65366 and (text:match('SMS%: .+. Отправитель%: .+') or text:match('SMS%: .+. Получатель%: .+')) then
        if text:match('SMS%: .+. Отправитель%: .+%[%d+%]') then smsid = text:match('SMS%: .+. Отправитель%: .+%[(%d+)%]') elseif text:match('SMS%: .+. Получатель%: .+%[%d+%]') then smstoid = text:match('SMS%: .+. Получатель%: .+%[(%d+)%]') end
        local colors = ("{%06X}"):format(bit.rshift(color, 8))
        table.insert(sms, os.date(colors.."[%H:%M:%S] ") .. text)
    end
    if color == 14221512 and (text:match("^ Объявление: .+. Прислал: %S+. Тел: %d+")) then
    local colors = ("{%06X}"):format(bit.rshift(color, 8))
    table.insert(ads, os.date(colors.."[%H:%M:%S] ") .. text)
    end
end

function sampev.onShowDialog(dialogId, dialogStyle, dialogTitle, okButtonText, cancelButtonText, dialogText)
    --spawncar
    if dialogId == 6700 and mainIni.maincfg.spawncar and spawncaractive then
        sampSendDialogResponse(6700, 1, 8, -1)
        return false
    end
    if dialogId == 6707 and mainIni.maincfg.spawncar and spawncaractive then
        local n = 0
        for line in string.gmatch(dialogText, "[^\r\n]+") do
            if line:find('На парковке') then
                sampSendDialogResponse(6707, 1, n - 1, -1)
                return false
            end
            n = n + 1
        end
    end
    if dialogId == 6708 and mainIni.maincfg.spawncar and spawncaractive then
        spawncaractive = false
        sampSendDialogResponse(6708, 1, 0, -1)
        lua_thread.create(closedialog)
    end

    --warelock fsafe/fbank
    if dialogId == 16000 and fsafeactive then
        sampSendDialogResponse(dialogId, 1, 6, -1)
        return false
    end
    if dialogId == 16004 and fsafeactive then
        fsafeactive = false
        sampSendDialogResponse(dialogId, 1, 0, -1)
        lua_thread.create(closedialog)
    end
    if dialogId == 16000 and fbankactive then
        sampSendDialogResponse(dialogId, 1, 7, -1)
        return false
    end
    if dialogId == 16005 and fbankactive then
        fbankactive = false
        sampSendDialogResponse(dialogId, 1, 0, -1)
        lua_thread.create(closedialog)
    end

    --autobar
    if dialogId == 32700 and dialogTitle:find("Меню бара") and mainIni.maincfg.autobar then
        lua_thread.create(function()
            sampSendDialogResponse(dialogId, 1, 0, -1)
            wait(200)
            sampSendDialogResponse(dialogId, 1, 0, -1)
            wait(200)
            sampSendDialogResponse(dialogId, 1, 0, -1)
            wait(200)
            sampSendDialogResponse(dialogId, 1, 0, -1)
            wait(200)
            sampCloseCurrentDialogWithButton(0)
        end)
    end

    --autodrugs
    if dialogTitle:find('Склад наркотиков') and dialogText:find('Наркотиков на руках') and mainIni.maincfg.autodrugs then
        local currentDrugs, maxDrugs = dialogText:match('Наркотиков на руках: {......}(%d+) {FFFFFF}/ {......}(%d+)')
        if tonumber(maxDrugs) > tonumber(currentDrugs) then
            sampSendDialogResponse(dialogId, 1, 0, maxDrugs - currentDrugs)
            lua_thread.create(closedialog)
        end
  end
    --autospawncalcel
    if dialogId == 32700 and dialogTitle:find('Меню лаборатории') and mainIni.maincfg.spcancel then
        sampSendDialogResponse(dialogId, 1, 1, -1)
        activecancel = true
        return false
    end
    if fsafe then
		if dialogId == 6054 then
            sampSendDialogResponse(6054, 1, 0, -1)
            return false
        end
        if dialogId == 6053 and fsak then
            sampSendDialogResponse(6053, 1, 8, -1)
			fsak = false
            return false
        end
        if dialogId == 6064 then
			lua_thread.create(function()
				wait(mainIni.fsafe.delay)
				sampSendDialogResponse(6064, 1, 0, mainIni.fsafe.ak)
				sampCloseCurrentDialogWithButton(0)
			end)
        end
		if dialogId == 6053 and fsm4 then
            sampSendDialogResponse(6053, 1, 9, -1)
			fsm4 = false
            return false
        end
        if dialogId == 6065 then
			lua_thread.create(function()
				wait(mainIni.fsafe.delay)
				sampSendDialogResponse(6065, 1, 0, mainIni.fsafe.m4)
				sampCloseCurrentDialogWithButton(0)
			end)
        end
		if dialogId == 6053 and fsde then
            sampSendDialogResponse(6053, 1, 5, -1)
			fsde = false
            return false
        end
        if dialogId == 6061 then
			lua_thread.create(function()
				wait(mainIni.fsafe.delay)
				sampSendDialogResponse(6061, 1, 0, mainIni.fsafe.de)
				sampCloseCurrentDialogWithButton(0)
			end)
        end
		if dialogId == 6053 and fsri then
            sampSendDialogResponse(6053, 1, 10, -1)
			fsri = false
            return false
        end
        if dialogId == 6066 then
			lua_thread.create(function()
				wait(mainIni.fsafe.delay)
				sampSendDialogResponse(6066, 1, 0, mainIni.fsafe.ri)	
				sampCloseCurrentDialogWithButton(0)
			end)
        end
		if dialogId == 6053 and fssh then
            sampSendDialogResponse(6053, 1, 6, -1)
			fssh = false
            return false
        end
        if dialogId == 6062 then
			lua_thread.create(function()
				wait(mainIni.fsafe.delay)
				sampSendDialogResponse(6062, 1, 0, mainIni.fsafe.sh)
				sampCloseCurrentDialogWithButton(0)
			end)
        end
		if dialogId == 6053 and not fsak and not fsm4 and not fsde and not fsri and not fssh then
			fslastd = true
		end
    end
	if dialogId == 6053 and fslastd then
		fslastd = false
		fsafe = false
		lua_thread.create(closedialog)
    end
	
	if fgg then
        if dialogId == 20036 and (ggde2 > 0) then
            sampSendDialogResponse(20036, 1, 0, -1)
			ggde2 = ggde2 - 1
			return false
        end
		if dialogId == 20036 and (ggm42 > 0) then
            sampSendDialogResponse(20036, 1, 3, -1)
			ggm42 = ggm42 - 1
			return false
        end
		if dialogId == 20036 and (ggri2 > 0) then
            sampSendDialogResponse(20036, 1, 2, -1)
			ggri2 = ggri2 - 1
            return false
        end
		if dialogId == 20036 and (ggak2 > 0) then
            sampSendDialogResponse(20036, 1, 4, -1)
			ggak2 = ggak2 - 1
            return false
        end
		if dialogId == 20036 and (ggsh2 > 0) then
            sampSendDialogResponse(20036, 1, 1, -1)
			ggsh2 = ggsh2 - 1
            return false
        end
		if dialogId == 20036 and arm and mainIni.getgun.arm then
            sampSendDialogResponse(20036, 1, 7, -1)
			arm = false
            return false
		else
			arm = false
        end
		if dialogId == 20036 and not arm and (ggak2 == 0) and (ggm42 == 0) and (ggde2 == 0) and (ggri2 == 0) and (ggsh2 == 0) then
			fgg = false
			lua_thread.create(function()
				wait(200)
				sampCloseCurrentDialogWithButton(0)
			end)
		end
    end
end


function closedialog()
  wait(250)
    sampCloseCurrentDialogWithButton(0)
    wait(250)
    sampCloseCurrentDialogWithButton(0)
end

function dlog()
    sampShowDialog(97987, '{9966cc}'..script.this.name..' {ffffff} | Лог сообщений департамента', table.concat(departament, '\n'), '»', 'x', 0)
end

function rlog()
    sampShowDialog(97987, '{9966cc}'..script.this.name..' {ffffff} | Лог сообщений рации', table.concat(radio, '\n'), '»', 'x', 0)
end

function smslog()
    sampShowDialog(97987, '{9966cc}'..script.this.name..' {ffffff} | Лог SMS', table.concat(sms, '\n'), '»', 'x', 0)
end

function adlog()
    sampShowDialog(97987, '{9966cc}'..script.this.name..' {ffffff} | Лог объявлений', table.concat(ads, '\n'), '»', 'x', 0)
end

function getColor(ID)
	PlayerColor = sampGetPlayerColor(ID)
	a, r, g, b = explode_argb(PlayerColor)
	return r/255, g/255, b/255, 1
end

function getAmmoInClip()
	local struct = getCharPointer(PLAYER_PED)
	local prisv = struct + 0x0718
	local prisv = memory.getint8(prisv, false)
	local prisv = prisv * 0x1C
	local prisv2 = struct + 0x5A0
	local prisv2 = prisv2 + prisv
	local prisv2 = prisv2 + 0x8
	local ammo = memory.getint32(prisv2, false)
	return ammo
end