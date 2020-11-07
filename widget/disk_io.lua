--[[

     Licensed under GNU General Public License v2
      * (c) 2019,      Jarno Seppänen
      * (c) 2013,      Luca CPZ
      * (c) 2010-2012, Peter Hofmann

--]]

local helpers  = require("lain.helpers")
local wibox    = require("wibox")

-- Disk I/O usage
-- lain.widget.disk_io

local function factory(args)
    local disk_io  = { prev = {}, widget = wibox.widget.textbox() }
    local args     = args or {}
    local timeout  = args.timeout or 2
    local units    = args.units or 1024 -- KB
    local settings = args.settings or function() end

    function disk_io.update()
        local cumulative = {}
        for line in io.lines("/proc/vmstat") do
            local read = string.match(line, "^pgpgin ([0-9]*)")
            local write = string.match(line, "^pgpgout ([0-9]*)")
            if read then
                cumulative.read = tonumber(read)
            elseif write then
                cumulative.write = tonumber(write)
            end
        end

        local prev_read = disk_io.prev.read or cumulative.read
        local prev_write = disk_io.prev.write or cumulative.write
        -- I/O block size is 1024 bytes
        io_now = { read = (cumulative.read - prev_read) * 1024 / timeout / units,
                   write = (cumulative.write - prev_write) * 1024 / timeout / units }
        disk_io.prev.read = cumulative.read
        disk_io.prev.write = cumulative.write

        io_now.read = string.format("%.1f", io_now.read)
        io_now.write = string.format("%.1f", io_now.write)

        widget = disk_io.widget

        settings()
    end

    helpers.newtimer("disk_io", timeout, disk_io.update)

    return disk_io
end

return factory
