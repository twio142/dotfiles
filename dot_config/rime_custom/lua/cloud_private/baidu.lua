local json = require("cloud_private.json")
local http = require("simplehttp")
http.TIMEOUT = 2

local function make_url(text, limit)
	return ("https://olime.baidu.com/py?input=%s&inputtype=py&bg=0&ed=%d&result=hanzi&resultcoding=utf-8&ch_en=0&clientinfo=web&version=1"):format(text, limit - 1)
end

local function translator(input, seg)
	local reply = http.request(make_url(input, 3))
	local _, j = pcall(json.decode, reply)
	if j.status == "T" and j.result and j.result[1] then
		for _, v in ipairs(j.result[1]) do
			local c = Candidate("simple", seg.start, seg.start + v[2], v[1], "􀇃")
			c.quality = 2
			if string.gsub(v[3].pinyin, "'", "") == string.sub(input, 1, v[2]) then
				c.preedit = string.gsub(v[3].pinyin, "'", " ")
			end
			yield(c)
		end
	end
end

return translator
