--------------------------------------------------
--    LICENSE: MIT
--     Author: Cosson2017
--    Version: 0.3
-- CreateTime: 2018-09-29 17:07:06
-- LastUpdate: 2018-09-29 17:07:06
--       Desc: 
--------------------------------------------------

local module = {}

--local log = require("nvim-completor/log")
------------------------------------------fuzzy match-------------------------------------
-- The fuzzy match fork from github.com/prabirshrestha/asyncomplete.vim

module.filter_completion_items = function (prefix, matches)
    local result = {}

	if not matches or #matches == 0 then
		return result
	end
    local unsorted_matches = {}
    for i = 1, #matches do
        local match = matches[i]
        if match ~= nil then
            local word = match['word']
            local matched, score, _ = module.fuzzy_match(prefix, word)
            if matched == true then
                table.insert(unsorted_matches, { score = score, match = match })
            end
        end
    end
    for _,v in module.spairs(unsorted_matches, function(t,a,b) return t[b].score < t[a].score end) do
        table.insert(result, v.match)
    end

    return result
end

-- Returns [bool, score, matchedIndices]
-- bool: true if each character in pattern is found sequentially within str
-- score: integer; higher is better match. Value has no intrinsic meaning. Range localies with pattern.
--        Can only compare scores with same search pattern.
-- matchedIndices: the indices of characters that were matched in str
module.fuzzy_match = function(pattern, str)
	-- Score consts
	local adjacency_bonus = 5                -- bonus for adjacent matches
	local separator_bonus = 10               -- bonus if match occurs after a separator
	local camel_bonus = 10                   -- bonus if match is uppercase and prev is lower
	local leading_letter_penalty = -3        -- penalty applied for every letter in str before the first match
	local max_leading_letter_penalty = -9    -- maximum penalty for leading letters
	local unmatched_letter_penalty = -1      -- penalty for every letter that doesn't matter

	-- Loop localiables
	local score = 0
	local patternIdx = 1
	local patternLength = #pattern
	local strIdx = 1
	local strLength = #str
	local prevMatched = false
	local prevLower = false
	local prevSeparator = true       -- true so if first letter match gets separator bonus

	-- Use "best" matched letter if multiple string letters match the pattern
	local bestLetter = nil
	local bestLower = nil
	local bestLetterIdx = nil
	local bestLetterScore = 0

	local matchedIndices = {}

	-- Loop over strings
	while (strIdx <= strLength) do
		local patternChar = patternIdx <= patternLength and pattern:sub(patternIdx, patternIdx) or nil
		local strChar = str:sub(strIdx, strIdx)

		local patternLower = patternChar and patternChar:lower() or nil
		local strLower = strChar:lower()
		local strUpper = strChar:upper()

		local nextMatch = patternChar and patternLower == strLower
		local rematch = bestLetter and bestLower == strLower

		local advanced = nextMatch and bestLetter
		local patternRepeat = bestLetter and patternChar and bestLower == patternLower
		if advanced or patternRepeat then
			score = score + bestLetterScore
			table.insert(matchedIndices, bestLetterIdx)
			bestLetter = nil
			bestLower = nil
			bestLetterIdx = nil
			bestLetterScore = 0
		end

		if nextMatch or rematch then
			local newScore = 0

			-- Apply penalty for each letter before the first pattern match
			-- Note: std::max because penalties are negative values. So max is smallest penalty.
			if patternIdx == 0 then
				local penalty = math.max(strIdx * leading_letter_penalty, max_leading_letter_penalty)
				score = score + penalty
			end

			-- Apply bonus for consecutive bonuses
			if prevMatched then
				newScore = newScore + adjacency_bonus
			end

			-- Apply bonus for matches after a separator
			if prevSeparator then
				newScore = newScore + separator_bonus
			end

			-- Apply bonus across camel case boundaries. Includes "clever" isLetter check.
			if prevLower and strChar == strUpper and strLower ~= strUpper then
				newScore = newScore + camel_bonus
			end

			-- Update patter index IFF the next pattern letter was matched
			if nextMatch then
				patternIdx = patternIdx + 1
			end

			-- Update best letter in str which may be for a "next" letter or a "rematch"
			if newScore >= bestLetterScore then

				-- Apply penalty for now skipped letter
				if bestLetter then
					score = score + unmatched_letter_penalty
				end

				bestLetter = strChar
				bestLower = bestLetter:lower()
				bestLetterIdx = strIdx
				bestLetterScore = newScore
			end

			prevMatched = true
		else
			score = score + unmatched_letter_penalty
			prevMatched = false
		end

		-- Includes "clever" isLetter check.
		prevLower = strChar == strLower and strLower ~= strUpper
		prevSeparator = strChar == '_' or strChar == ' '

		strIdx = strIdx + 1
	end

	-- Apply score for last match
	if bestLetter then
		score = score + bestLetterScore
		table.insert(matchedIndices, bestLetterIdx)
	end

	local matched = patternIdx - 1 == patternLength
	return matched, score, matchedIndices
end

module.spairs = function(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

-----------------------------------------head fuzzy match src ---------------------------------------------------
-- The fuzzy match is simple
module.simple_match = function(matchs, pattern)
	local result = {}
	for _, match in ipairs(matchs) do
		if vim.startswith(match, prefix) then
			table.insert(result, match)
		end
	end
	return result
end

-- 是否符合首字母模糊匹配
module.match_and_pick_sort_str = function(str, pattern)
	local slen = str:len()
	local plen = pattern:len()

	if slen < plen then return nil end
	if str:sub(1,1) ~= pattern:sub(1,1) then
		return nil
	end

	if plen == 1 then return {str:sub(2)} end

	local n = 2
	local sort_str = {}
	for i = 2, plen, 1 do
		if slen - n < plen - i then return nil end
		local sub_str, pc = "", pattern:sub(i, i)
		for j = n, slen, 1 do
			n = n + 1
			local sc = str:sub(j,j)
			if sc == pc then break end
			sub_str = sub_str .. sc
			if j == slen then return nil end
			if slen - j < plen - i then return nil end
		end
		table.insert(sort_str, sub_str)
	end
	table.insert(sort_str, str:sub(n))
	return sort_str
end

-- @items: table
-- @pattern:
-- return: table
module.head_fuzzy_match = function(items, pattern)

	if items == nil or #items == 0 then return {} end
	if pattern:len() == 0 then return items end

	--local lp = string.lower(pattern)
	local lp = pattern
	local sortArray = {}
	for i, v in ipairs(items) do
		-- local word = v['word']
		local word = v['abbr']
		local sort_str = module.match_and_pick_sort_str(word, lp)
		if sort_str then 
			table.insert(sortArray, {strs = sort_str, i = i})
		end
	end

	table.sort(sortArray, function(s1, s2) 
		local len = #s1.strs
		for i = 1, len, 1 do
			local ss1, ss2 = s1.strs[i], s2.strs[i]
			if #ss1 < #ss2 then return true end
			if #ss1 > #ss2 then return false end
			if ss1 < ss2 then return true end
			if ss1 > ss2 then return false end
		end
		if s1.i < s2.i then return true end
		return false
	end)

	local candicates = {}
	for _, s in ipairs(sortArray) do
		local index = s.i
		table.insert(candicates, items[index])
	end
	return candicates
end

return module
