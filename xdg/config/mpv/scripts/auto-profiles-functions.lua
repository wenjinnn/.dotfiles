#!/usr/bin/env lua

function hostname()
  local f = io.open('/etc/hostname')
  local a = f:read()
  f:close()
  return a
end

mp.set_property_native('user-data/hostname', hostname())
