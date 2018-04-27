local MAJOR_VERSIONS = {
  [0] = {
    version = "0.0.1",
    modules = {
      "table",
      "log",
      "ctx",
      "ip",
      "request",
      "client",
    },
  },

  [1] = {
    version = "1.0.0",
    modules = {
      "table",
      "log",
      "ctx",
      "ip",
      "request",
      "client",
      "upstream",
      "upstream.response",
      "response",
      --[[
      "timers",
      "http",
      "utils",
      "shm",
      --]]
    },
  },

  latest = 1,
}


local _SDK = {
  major_versions = MAJOR_VERSIONS,
}


function _SDK.new(kong_config, major_version, self)
  if kong_config then
    if type(kong_config) ~= "table" then
      error("kong_config must be a table", 2)
    end

  else
    kong_config = {}
  end

  if major_version then
    if type(major_version) ~= "number" then
      error("major_version must be a number", 2)
    end

  else
    major_version = MAJOR_VERSIONS.latest
  end

  local version_meta = MAJOR_VERSIONS[major_version]

  self = self or {}

  self.sdk_major_version = major_version
  self.sdk_version = version_meta.version

  self.configuration = setmetatable({}, {
    __index = function(_, v)
      return kong_config[v]
    end,

    __newindex = function()
      error("cannot write to configuration", 2)
    end,
  })

  for _, module_name in ipairs(version_meta.modules) do
    if self[module_name] then
      error("SDK module '" .. module_name .. "' conflicts with a key")
    end

    local mod = require("kong.sdk." .. module_name)

    if module_name == "upstream.response" then
      self.upstream.response = mod.new(self)
    else
      self[module_name] = mod.new(self)
    end
  end

  return self
end


return _SDK
