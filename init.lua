--- === StayActive ===
--- Periodically jiggles the mouse 1px to prevent idle detection.
--- Keeps MS Teams (and similar apps) showing a green/active status.

local obj = {}
obj.__index = obj

obj.name = "StayActive"
obj.version = "0.1.0"
obj.author = "Selim Acerbas"
obj.homepage = "https://github.com/selimacerbas/StayActive.spoon"
obj.license = "MIT"
obj.logger = hs.logger.new("StayActive", "info")

-- ===============
-- Configuration
-- ===============
obj.interval = 120      -- seconds between jiggle (default 2 min)
obj.jiggleAmount = 1    -- pixels to move (invisible at 1px)

-- Default hotkeys
obj.defaultHotkeys = {
    toggle = { { "ctrl", "alt", "cmd" }, "S" },
}

-- ===============
-- Internal State
-- ===============
obj._timer = nil
obj._menubar = nil

-- ===============
-- Core
-- ===============
function obj:_jiggle()
    local pos = hs.mouse.absolutePosition()
    hs.mouse.absolutePosition({ x = pos.x + self.jiggleAmount, y = pos.y })
    hs.timer.doAfter(0.05, function()
        hs.mouse.absolutePosition(pos)
    end)
end

function obj:start()
    if self._timer then return self end

    self._menubar = hs.menubar.new()
    if self._menubar then
        self._menubar:setTitle("SA")
        self._menubar:setTooltip("StayActive: running")
        self._menubar:setMenu(function()
            return {
                { title = "Stop StayActive", fn = function() self:stop() end },
            }
        end)
    end

    self:_jiggle()
    self._timer = hs.timer.doEvery(self.interval, function() self:_jiggle() end)

    self.logger.i("StayActive started (interval: " .. self.interval .. "s)")
    return self
end

function obj:stop()
    if self._timer then
        self._timer:stop()
        self._timer = nil
    end
    if self._menubar then
        self._menubar:delete()
        self._menubar = nil
    end

    self.logger.i("StayActive stopped")
    return self
end

function obj:toggle()
    if self._timer then self:stop() else self:start() end
    return self
end

function obj:bindHotkeys(mapping)
    local spec = mapping or self.defaultHotkeys
    if spec.toggle then
        hs.hotkey.bind(spec.toggle[1], spec.toggle[2], function() self:toggle() end)
    end
    return self
end

return obj
