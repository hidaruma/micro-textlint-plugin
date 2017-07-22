VERSION = "0.2.0"

if GetOption("textlint") == nil then
   AddOption("textlint", true)
end

MakeCommand("textlint", "textlint.textlintCommand", 0)

function textlintCommand()
   CurView():Save(false)
   runTextlint()
end

function runTextlint()
   CurView():ClearGutterMessages("textlint")
   JobSpawn("textlint", {"--no-color" ,CurView().Buf.Path}, "", "", "textlint.onExit", "%d:%d  %m")
end

function split(str,sep)
   local result = {}
   local regex = ("([^%s]+)"):format(sep)
   for each in string.gmatch(str, regex) do
      table.insert(result, each)
   end 
   return result
end

function onSave(view)
   if GetOption("textlint") then
      runTextlint()
   else
      CurView():ClearAllGutterMessages()
   end
end


function onExit(output, errorformat)
   local lines = split(output, "\n")

   local regex = errorformat:gsub("%%d", "(%d+)"):gsub("%%m", "(.+)")
   for _,line in ipairs(lines) do
       -- Trim whitespace
      line = line:match("^%s*(.+)%s*$")
      if string.find(line, regex) then
         local line, column, msg = string.match(line, regex)
            CurView():GutterMessage("textlint", tonumber(line), msg, 2)
      end
   end
end
