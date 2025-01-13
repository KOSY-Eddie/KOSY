local testStr is "Hello!".
local testInsert is "test".
local idx is 0.
print teststr.
local initLen is testStr:length.
local insertLen is testInsert:length.
set testStr to testStr:insert(idx,testInsert).
print teststr.

//if we are near the end, e.g. idx + insertLen > initLen then just truncate output
if idx + insertLen > initLen
    set testStr to testStr:remove(initLen,testStr:length-initLen).
else
    set testStr to testStr:remove(idx+testInsert:length,testInsert:length).
print testStr.