--[[
* Ashita - Copyright (c) 2014 - 2016 atom0s [atom0s@live.com]
*
* This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License.
* To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/4.0/ or send a letter to
* Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
*
* By using Ashita, you agree to the above license and its terms.
*
*      Attribution - You must give appropriate credit, provide a link to the license and indicate if changes were
*                    made. You must do so in any reasonable manner, but not in any way that suggests the licensor
*                    endorses you or your use.
*
*   Non-Commercial - You may not use the material (Ashita) for commercial purposes.
*
*   No-Derivatives - If you remix, transform, or build upon the material (Ashita), you may not distribute the
*                    modified material. You are, however, allowed to submit the modified works back to the original
*                    Ashita project in attempt to have it added to the original project.
*
* You may not apply legal terms or technological measures that legally restrict others
* from doing anything the license permits.
*
* No warranties are given.
]]--

_addon.author   = 'Almavivaconte (timestamp from atom0s\'s clock addon)';
_addon.name     = 'Schedule';
_addon.version  = '0.0.1';

require 'common'
require 'date'

selbina_ferry_arrivals = {
400,
880,
1360
}

selbina_ferry_departures = {
0,
480,
960
}

mhaura_zahbi_arrivals = {
160,
640,
1020
}

mhaura_zahbi_departures = {
240,
720,
1200
}

whitegate_nashmau_arrivals = {
300,
780,
1260
}

whitegate_nashmau_departures = {
0,
480,
960
}

san_jeuno_arrivals = {
190,
550,
910,
1270
}

san_jeuno_departures = {
252,
612,
972,
1332
}

jeuno_san_arrivals = {
11,
371,
731,
1091
}

jeuno_san_departures = {
73,
433,
793,
1153
}

win_jeuno_arrivals = {
287,
647,
1007,
1367
}

win_jeuno_departures = {
343,
703,
1063,
1423
}

jeuno_win_arrivals = {
101,
461,
821,
1181
}

jeuno_win_departures = {
163,
523,
883,
1243
}

bas_jeuno_arrivals = {
13,
373,
733,
1093
}

bas_jeuno_departures = {
72,
432,
792,
1152
}

jeuno_bas_arrivals = {
191,
551,
911,
1271
}

jeuno_bas_departures = {
254,
614,
974,
1334
}

local default_config =
{
    font =
    {
        family      = 'Consolas',
        size        = 7,
        color       = math.d3dcolor(255, 255, 255, 255),
        position    = { 1, 1 },
    },
    background =
    {
        color       = math.d3dcolor(128, 0, 0, 0),
        visible     = true
    },
};

local schedule_config = default_config;

local visible = false;

ashita                  = ashita or { };
ashita.ffxi             = ashita.ffxi or { };
ashita.ffxi.vanatime    = ashita.ffxi.vanatime or { };

-- Scan for patterns..
ashita.ffxi.vanatime.pointer = ashita.memory.findpattern('FFXiMain.dll', 0, 'B0015EC390518B4C24088D4424005068', 0x34, 0);

-- Signature validation..
if (ashita.ffxi.vanatime.pointer == 0) then
    error('vanatime.lua -- signature validation failed!');
end

local function getNextArrival(scheduleTable, currentTime)
    for k,v in pairs(scheduleTable) do
        if currentTime <= v then
            nextTime = tostring(math.floor(v / 60)) .. ":" .. string.format("%02d", v % 60);
            nextRealTime = (v - currentTime) * 2.4;
            nextString = tostring(math.floor(nextRealTime / 60)) .. ":" .. string.format("%02d", nextRealTime % 60);
            t = {
            nextRealTime,
            "Arrives at: " .. nextTime .. "(in ".. nextString .. " earth time)"
            }
            return t;
        end
    end
    nextTime = tostring(math.floor(scheduleTable[1] / 60)) .. ":" .. string.format("%02d", scheduleTable[1] % 60);
    nextRealTime = (scheduleTable[1]+1440 - currentTime) * 2.4;
    nextString = tostring(math.floor(nextRealTime / 60)) .. ":" .. string.format("%02d", nextRealTime % 60);
    t = {
    nextRealTime,
    "Arrives at: " .. nextTime .. "(in ".. nextString .. " earth time)"
    }
    return t;
end

local function getNextDeparture(scheduleTable, currentTime)
    for k,v in pairs(scheduleTable) do
        if currentTime <= v then
            nextTime = tostring(math.floor(v / 60)) .. ":" .. string.format("%02d", v % 60);
            nextRealTime = (v - currentTime) * 2.4;
            nextString = tostring(math.floor(nextRealTime / 60)) .. ":" .. string.format("%02d", nextRealTime % 60);
            t = {
            nextRealTime,
            "Departs at: " .. nextTime .. "(in ".. nextString .. " earth time)"
            }
            return t;
        end
    end
    nextTime = tostring(math.floor(scheduleTable[1] / 60)) .. ":" .. string.format("%02d", scheduleTable[1] % 60);
    nextRealTime = (scheduleTable[1]+1440 - currentTime) * 2.4;
    nextString = tostring(math.floor(nextRealTime / 60)) .. ":" .. string.format("%02d", nextRealTime % 60);
    t = {
    nextRealTime,
    "Departs at: " .. nextTime .. "(in ".. nextString .. " earth time)"
    }
    return t;
end

----------------------------------------------------------------------------------------------------
-- func: get_raw_timestamp
-- desc: Returns the current raw Vana'diel timestamp.
----------------------------------------------------------------------------------------------------
local function get_raw_timestamp()
    local pointer = ashita.memory.read_uint32(ashita.ffxi.vanatime.pointer);
    return ashita.memory.read_uint32(pointer + 0x0C);
end 
ashita.ffxi.vanatime.get_raw_timestamp = get_raw_timestamp;

----------------------------------------------------------------------------------------------------
-- func: get_current_time
-- desc: Returns a table with the hour, minutes, and seconds in Vana'diel time.
----------------------------------------------------------------------------------------------------
local function get_current_time()
    local timestamp = get_raw_timestamp();
    local ts = (timestamp + 92514960) * 25;
    local h = (ts / 3600) % 24;
    local m = (ts / 60) % 60;
    local s = ((ts - (math.floor(ts / 60) * 60)));

    local vana = { };
    vana.h = h;
    vana.m = m;
    vana.s = s;

    return vana;
end
ashita.ffxi.vanatime.get_current_time = get_current_time;

function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

----------------------------------------------------------------------------------------------------
-- func: load
-- desc: Event called when the addon is being loaded.
----------------------------------------------------------------------------------------------------
ashita.register_event('load', function()
    -- Load the configuration file..
    schedule_config = ashita.settings.load_merged(_addon.path .. '/settings/settings.json', schedule_config);

    -- Create the font object..
    local f = AshitaCore:GetFontManager():Create('__schedule_addon');
    f:SetColor(schedule_config.font.color);
    f:SetFontFamily(schedule_config.font.family);
    f:SetFontHeight(schedule_config.font.size);
    f:SetPositionX(schedule_config.font.position[1]);
    f:SetPositionY(schedule_config.font.position[2]);
    f:SetText('');
    f:SetVisibility(false);
    f:GetBackground():SetVisibility(schedule_config.background.visible);
    f:GetBackground():SetColor(schedule_config.background.color);
   
end);
----------------------------------------------------------------------------------------------------
-- func: unload
-- desc: Event called when the addon is being unloaded.
----------------------------------------------------------------------------------------------------
ashita.register_event('unload', function()
    -- Get the font object..
    local f = AshitaCore:GetFontManager():Get('__schedule_addon');
    -- Update the configuration position..
    schedule_config.font.position = { f:GetPositionX(), f:GetPositionY() };

    -- Save the configuration file..
    ashita.settings.save(_addon.path .. '/settings/settings.json', schedule_config);

    -- Delete the font object..
    AshitaCore:GetFontManager():Delete('__schedule_addon');
end);

----------------------------------------------------------------------------------------------------
-- func: load
-- desc: Event called when the addon is being rendered.
----------------------------------------------------------------------------------------------------
ashita.register_event('render', function()
    -- Obtain the font object..
    local f = AshitaCore:GetFontManager():Get('__schedule_addon');

    -- Ensure we have a clock table..
    if (f == nil) then
        return;
    end

    -- Build the table of timestamps..
    local timestamps = { };
    currentTimeTable = get_current_time();
    currentTime = math.floor(currentTimeTable.h*60) + currentTimeTable.s/60;
    
    table.insert(timestamps, "Selbina/Mhaura Ferry:");
    selbMhauNextArrival = getNextArrival(selbina_ferry_arrivals, currentTime);
    selbMhauNextDeparture = getNextDeparture(selbina_ferry_departures, currentTime);
    if selbMhauNextArrival[1] < selbMhauNextDeparture[1] then
        selbMhauString = selbMhauNextArrival[2] .. "   " .. selbMhauNextDeparture[2];
    else
        selbMhauString = selbMhauNextDeparture[2] .. "   " .. selbMhauNextArrival[2];
    end
    table.insert(timestamps, selbMhauString);
    
    table.insert(timestamps, "");
    
    table.insert(timestamps, "Mhaura/Al Zahbi Ferry:");
    MhauZahbiNextArrival = getNextArrival(mhaura_zahbi_arrivals, currentTime);
    MhauZahbiNextDeparture = getNextDeparture(mhaura_zahbi_departures, currentTime);
    if MhauZahbiNextArrival[1] < selbMhauNextDeparture[1] then
        MhauZahbiString = MhauZahbiNextArrival[2] .. "   " .. MhauZahbiNextDeparture[2];
    else
        MhauZahbiString = MhauZahbiNextDeparture[2] .. "   " .. MhauZahbiNextArrival[2];
    end
    
    table.insert(timestamps, MhauZahbiString);
    
    table.insert(timestamps, "");
    
    table.insert(timestamps, "Whitegate/Nashmau Ferry:");
    WhgNashmauNextArrival = getNextArrival(whitegate_nashmau_arrivals, currentTime);
    WhgNashmauNextDeparture = getNextDeparture(whitegate_nashmau_departures, currentTime);
    if WhgNashmauNextArrival[1] < WhgNashmauNextDeparture[1] then
        WhgNashmauString = WhgNashmauNextArrival[2] .. "   " .. WhgNashmauNextDeparture[2];
    else
        WhgNashmauString = WhgNashmauNextDeparture[2] .. "   " .. WhgNashmauNextArrival[2];
    end
    
    table.insert(timestamps, WhgNashmauString);
    
    table.insert(timestamps, "");    
    
    table.insert(timestamps, "San d'Oria to Jeuno Airship:");
    SanJeunoNextArrival = getNextArrival(san_jeuno_arrivals, currentTime);
    SanJeunoNextDeparture = getNextDeparture(san_jeuno_departures, currentTime);
    if SanJeunoNextArrival[1] < SanJeunoNextDeparture[1] then
        SanJeunoString = SanJeunoNextArrival[2] .. "   " .. SanJeunoNextDeparture[2];
    else
        SanJeunoString = SanJeunoNextDeparture[2] .. "   " .. SanJeunoNextArrival[2];
    end
    
    table.insert(timestamps, SanJeunoString);
    
    table.insert(timestamps, "");
    
    table.insert(timestamps, "Bastok to Jeuno Airship:");
    BasJeunoNextArrival = getNextArrival(bas_jeuno_arrivals, currentTime);
    BasJeunoNextDeparture = getNextDeparture(bas_jeuno_departures, currentTime);
    if BasJeunoNextArrival[1] < BasJeunoNextDeparture[1] then
        BasJeunoString = BasJeunoNextArrival[2] .. "   " .. BasJeunoNextDeparture[2];
    else
        BasJeunoString = BasJeunoNextDeparture[2] .. "   " .. BasJeunoNextArrival[2];
    end
    
    table.insert(timestamps, BasJeunoString);
    
    table.insert(timestamps, "");
    
    table.insert(timestamps, "Windurst to Jeuno Airship:");
    WinJeunoNextArrival = getNextArrival(win_jeuno_arrivals, currentTime);
    WinJeunoNextDeparture = getNextDeparture(win_jeuno_departures, currentTime);
    if WinJeunoNextArrival[1] < WinJeunoNextDeparture[1] then
        WinJeunoString = WinJeunoNextArrival[2] .. "   " .. WinJeunoNextDeparture[2];
    else
        WinJeunoString = WinJeunoNextDeparture[2] .. "   " .. WinJeunoNextArrival[2];
    end
    
    table.insert(timestamps, WinJeunoString);
    
    table.insert(timestamps, "");
    
    table.insert(timestamps, "Jeuno Airships:");
    JeunoSanNextArrival = getNextArrival(jeuno_san_arrivals, currentTime);
    JeunoSanNextDeparture = getNextDeparture(jeuno_san_departures, currentTime);
    if JeunoSanNextArrival[1] < JeunoSanNextDeparture[1] then
        JeunoSanString = "(to San d'Oria) " .. JeunoSanNextArrival[2] .. "   " .. JeunoSanNextDeparture[2];
    else
        JeunoSanString = "(to San d'Oria) " .. JeunoSanNextDeparture[2] .. "   " .. JeunoSanNextArrival[2];
    end
    
    JeunoBasNextArrival = getNextArrival(jeuno_bas_arrivals, currentTime);
    JeunoBasNextDeparture = getNextDeparture(jeuno_bas_departures, currentTime);
    if JeunoBasNextArrival[1] < JeunoBasNextDeparture[1] then
        JeunoBasString = "(to Bastok) " .. JeunoBasNextArrival[2] .. "   " .. JeunoBasNextDeparture[2];
    else
        JeunoBasString = "(to Bastok) " .. JeunoBasNextDeparture[2] .. "   " .. JeunoBasNextArrival[2];
    end
    
    JeunoWinNextArrival = getNextArrival(jeuno_win_arrivals, currentTime);
    JeunoWinNextDeparture = getNextDeparture(jeuno_win_departures, currentTime);
    if JeunoWinNextArrival[1] < JeunoWinNextDeparture[1] then
        JeunoWinString = "(to Windurst) " .. JeunoWinNextArrival[2] .. "   " .. JeunoWinNextDeparture[2];
    else
        JeunoWinString = "(to Windurst) " .. JeunoWinNextDeparture[2] .. "   " .. JeunoWinNextArrival[2];
    end
    
    table.insert(timestamps, JeunoSanString);
    table.insert(timestamps, JeunoBasString);
    table.insert(timestamps, JeunoWinString);

    f:SetText(table.concat(timestamps, "\n"));
    return;
end);

ashita.register_event('command', function(command, ntype)
    -- Ensure we should handle this command..
    
    local f = AshitaCore:GetFontManager():Get('__schedule_addon');

    -- Ensure we have a clock table..
    if (f == nil) then
        return;
    end
    
    local args = command:args();
    if (args[1] == '/schedule' or args[1] == '/sched') then
        if visible then
            visible = false;
            f:SetVisibility(false);
        else
            visible = true;
            f:SetVisibility(true);
        end
    end
    return false;
end);