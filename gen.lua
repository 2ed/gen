#!/usr/bin/lua

dictionary = './dict'
-- dictionary = './dic2_test'
-- outputFile = './done'
inputFile = io.open(dictionary)
-- io.output(outputFile)
-- print = io.write
MAXLEN = 30 -- Word limit
nochar = ''
count = 20

letterBank = {}
dictTable = {}

args = {...}

if #args>= 1 then
   -- print('k')
   rev=true
   refWord = args[1]
   ending = tonumber(args[2]) or 1
--    print(count)
end
--[[
for a, b in pairs({...}) do
   print(a,b)
end
--]]

-- usub = function(str,from,to)

wordReverse = function(word)
   local res = ''
   for i =1,#word,2 do
      res = word:sub(i,i+1) .. res
   end
   return res
end

decompose = function(wordString)
   wordEnd = wordString:find(' ')
   if wordEnd then
      return wordString:sub(1,wordEnd-1)
   else
      return wordString
   end
end

prefix = function(c1, c2)
   return c1 .. c2
end

insert = function(index, value)
   if not letterBank[index] then
      letterBank[index] = {}
   end
   table.insert(letterBank[index],value)
end

fillWord = function(str)
   --   print(str)
   local c1, c2 = nochar, nochar
   for i =1,#str,2 do 
      -- for i in str:gmatch('%w') do
      c3 = str:sub(i,i+1)
      -- print(str..': ',i, c1,c2,c3)
      insert(prefix(c1,c2),c3)
      c1, c2 = c2, c3
   end
   insert(prefix(c1,c2),nochar)
end

fillDict = function(rev) 
   for line in inputFile:lines() do 
      -- io.write(decompose(line) .. '\n')
      local word = decompose(line)
      if rev then
	 word = wordReverse(word)
      end
      fillWord(word)
      table.insert(dictTable,word)
   end
   inputFile:flush()
end

checkDict = function(word)
   for line in inputFile:lines() do
      -- io.write(decompose(line) .. '\n')
      if word ==  decompose(line) then
	 io.flush()
	 return false
      end
   end
   inputFile:flush()
   return true
end

writeDict = function(dict, file)
   io.output(file)
   if type(dict) == 'table' then
      for i, refString in pairs(dict) do
	 io.write(i,'#')
	 for j, w in ipairs(refString) do
	    io.write(w)
	 end
	 io.write('\r\n')
      end
   end
end

readDict = function(file)
   local dict = {}
   input = io.open(file)
   local value = false -- value or prefix?
   for l in input:lines() do
      local prefix = ''
      for i, c in utf8.codes(l) do
	 if value then
	    table.insert(dict[prefix],utf8.char(c))
	 elseif c == 35 then -- utf8.char(35) = '#'
	    value = true
	    --	    print(prefix)
	    dict[prefix] = {}
	 else
	    prefix = prefix .. utf8.char(c)
	 end
      end
      value = false
   end
   return dict
end
   

-- while true do
wordProduce = function(rev)
   local c1, c2 = nochar, nochar
   local   word = ''
   if rev then
      wordEnd = refWord:sub(-2*ending)
      c1 = wordEnd:sub(3,4)
      c2 = wordEnd:sub(1,2)
      word = wordReverse(wordEnd)
   end
   for i=1,MAXLEN do
      local list = letterBank[prefix(c1, c2)]
      -- choose a random item from list
      print(prefix(c1,c2))
      print(string.byte(c1),string.byte(c2))
      print(#list)
      math.randomseed(os.time() + os.clock()*100000)
      local r = math.random(#list)
      -- print(r)
      local nextchar = list[r]
      if nextchar == nochar then return word end
      -- print(nextchar)
      word = word .. nextchar
      -- io.write(nextchar)
      c1, c2 = c2, nextchar
   end
end

tableSearch = function(t,item)
   res = false
   for i,v in pairs(t) do
      if item == v then res = true return res end
   end
   return res
end

makeWords = function(n,rev)
   local words = {}
   local j,k = 0,0 -- k is for KONTROL
   while true do
      -- for i = 1, 20 do
      --    if j == 21 then break end
      local newWord = wordProduce(rev)
      if newWord and #newWord > 8 and #newWord ~= 60
	 and (not tableSearch(words,newWord))
	 and (not tableSearch(dictTable,newWord))
      then
	 j = j + 1
	 -- Moved to printWords
	 --[[
	 if rev then
	    newWord = wordReverse(newWord)
	 end
	 --]] 
	 table.insert(words,newWord)
      end
      k = k + 1
      if j == n or k == n*n then break end
   end
   return words
end

printWords = function(t)
   for i,v in pairs(t) do
   if rev then
      v = wordReverse(v)
   end
      print(v)
   end
end

-- fillDict(rev)
-- wordBank = makeWords(count,rev)
-- printWords(wordBank)

--printDict(letterBank)

-- res = io.popen('iconv -f CP1251 -t UTF8 < '.. outputFile .. ' > d.txt')
--[[
for b in res:lines() do
   print(b)
end
--]]
