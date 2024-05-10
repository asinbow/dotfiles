
-- hs.loadSpoon("ReloadConfiguration")
-- spoon.ReloadConfiguration:start()

local function contains(table, val)
   for i=1,#table do
      if table[i] == val then
         return true
      end
   end
   return false
end

function map(tbl, f)
  local t = {}
  for k,v in pairs(tbl) do
    t[k] = f(v)
  end
  return t
end

function find(tbl, f)
  for k,v in pairs(tbl) do
    if f(v) then
      return v
    end
  end
  return nil
end

function registerReload()
  hs.hotkey.bind({"cmd", "shift", "ctrl"}, "r", function()
    hs.reload()
    hs.notify.new({title="🔨 Reloaded", informativeText="Configuration reloaded."}):send()
  end)
end

function registerTranslations()
  local translations = {
    {
      from = {
        mods = {"cmd", "ctrl"},
        key = "h",
      },
      to = {
        mods = {"fn", "ctrl"},
        key = "left",
      },
    },
    {
      from = {
        mods = {"cmd", "ctrl"},
        key = "l",
      },
      to = {
        mods = {"fn", "ctrl"},
        key = "right",
      },
    },
    {
      from = {
        mods = {"cmd", "shift"},
        key = "h",
      },
      to = {
        mods = {"ctrl", "shift"},
        key = "tab",
      },
      app = {"Terminal", "Терминал", "Google Chrome"},
    },
    {
      from = {
        mods = {"cmd", "shift"},
        key = "l",
      },
      to = {
        mods = {"ctrl"},
        key = "tab",
      },
      app = {"Terminal", "Терминал", "Google Chrome"},
    },
    --[=====[
    {
      from = {
        mods = {"ctrl"},
        key = "n",
      },
      to = {
        key = "down",
      },
      app = {"Google Chrome", "Slack"},
    },
    {
      from = {
        mods = {"ctrl"},
        key = "p",
      },
      to = {
        key = "up",
      },
      app = {"Google Chrome", "Slack"},
    },
    --]=====]
  }

  for i, translation in ipairs(translations) do
    hs.hotkey.bind(translation.from.mods, translation.from.key, function()
      if not translation.app or contains(translation.app, hs.application.frontmostApplication():name()) then
        hs.eventtap.keyStroke(translation.to.mods, translation.to.key)
      end
    end)
  end
end

function registerFocusScreen()
  local focusScreenShortcuts = {
    h = "toWest",
    j = "toSouth",
    k = "toNorth",
    l = "toEast",
  }
  
  for key, method in pairs(focusScreenShortcuts) do
    hs.hotkey.bind({"cmd", "shift", "ctrl"}, key, function()
      local currentScreen = hs.mouse.getCurrentScreen()
      local screen = currentScreen[method](currentScreen)
  
      if screen ~= nil then
        hs.eventtap.leftClick(screen:fullFrame().center, 50000)
      else
        screen = currentScreen
        hs.mouse.absolutePosition(screen:fullFrame().center)
      end
  
      hs.alert.show("🔨", {}, screen, 0.4)
    end)
  end
end

function registerShortcuts()
  local shortcuts = {
    {
      text = "Mission Control",
      subText = "Cmd+Shift+Ctrl+M",
      mods = {"cmd", "shift", "ctrl"},
      key = "m",
      action = function()
        hs.spaces.toggleMissionControl()
      end,
    },
    {
      text = "Desktop",
      subText = "Cmd+Shift+Ctrl+D",
      mods = {"cmd", "shift", "ctrl"},
      key = "d",
      action = function()
        hs.spaces.toggleShowDesktop()
      end,
    },
    {
      text = "有道云笔记",
      subText = "Cmd+Shift+Ctrl+N",
      mods = {"cmd", "shift", "ctrl"},
      key = "n",
      action = function()
        hs.application.open("有道云笔记")
      end,
    },
    {
      text = "IntelliJ IDEA Ultimate",
      subText = "Cmd+Shift+Ctrl+I",
      mods = {"cmd", "shift", "ctrl"},
      key = "i",
      action = function()
        hs.application.open("IntelliJ IDEA")
      end,
    },
    {
      text = "Slack",
      subText = "Cmd+Shift+Ctrl+S",
      mods = {"cmd", "shift", "ctrl"},
      key = "s",
      action = function()
        hs.application.open("Slack")
      end,
    },
    {
      text = "Terminal",
      subText = "Cmd+Shift+Ctrl+E",
      mods = {"cmd", "shift", "ctrl"},
      key = "e",
      action = function()
        hs.application.open("Terminal")
      end,
    },
    {
      text = "Browser(Google Chrome)",
      subText = "Cmd+Ctrl+B",
      mods = {"cmd", "ctrl"},
      key = "b",
      action = function()
        hs.application.open("Google Chrome")
      end,
    },
    {
      text = "BlueJeans",
      subText = "Cmd+Ctrl+J",
      mods = {"cmd", "ctrl"},
      key = "j",
      action = function()
        hs.application.open("BlueJeans")
      end,
    },
    {
      text = "Okta Open",
      subText = "Cmd+Shift+O",
      mods = {"cmd", "shift"},
      key = "o",
      action = function()
        local application = hs.application.open("Google Chrome")
        hs.eventtap.keyStroke({"cmd", "shift"}, "o", 200, application)
      end,
    },
  }

  for i,shortcut in ipairs(shortcuts) do
    hs.hotkey.bind(shortcut.mods, shortcut.key, shortcut.action)
  end

  local choices = map(shortcuts, function(shortcut)
    return {text = shortcut.text, subText = shortcut.subText}
  end)

  local chooser = hs.chooser.new(function(choice)
    if choice == nil then
      return
    end

    local shortcut = find(shortcuts, function(shortcut)
      return shortcut.text == choice.text
    end)
    if shortcut == nil then
      return
    end
  
    shortcut.action()
  end)
  chooser:choices(choices)
  
  hs.hotkey.bind({"cmd", "shift", "ctrl"}, "/", function()
    chooser:show()
  end)
end

function registerEct()
end

function registerAll()
  registerReload()
  registerTranslations()
  registerFocusScreen()
  registerShortcuts()
  registerEct()
end

registerAll()
