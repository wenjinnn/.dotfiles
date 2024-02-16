#!/usr/bin/env lua

mp.observe_property('current-tracks/sub/lang', 'native', function (_, lang)
  if lang == 'ja' or lang == 'jpn' then
    mp.set_property('sub-font', 'Source Han Sans')
  elseif lang == 'zh_TW' then
    mp.set_property('sub-font', '思源黑體')
  else
    mp.set_property('sub-font', 'sans-serif')
  end
end)
