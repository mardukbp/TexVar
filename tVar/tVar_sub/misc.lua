----------------------------------------------------------------------------
-- misc script
-- contains function not intend to be used by users
--
----------------------------------------------------------------------------

--- Redefine tex.print command for 
-- debug output of LaTex Commands
--
-- @param _string (string) Text for output
------------------------------------
local oldPrint = tex.print
tex.print = function (_string)
	if not tVar.disableOutput then 
		if tVar.debugMode == "on" then
			oldPrint("{\\tiny \\verb|" .. _string .. "|}\\\\")
		else
			oldPrint(_string)
		end
	end
end
--- sets the name of tVar object
-- 
-- @param _nameTex (string) LaTeX representation
-- @return (tVar) self
function tVar:setName(_nameTex)
	self.nameTex = _nameTex
	return self
end
--- sets the numberformat of tVar object
-- 
-- @param _numformat (string) Lua numberformat
-- @return (tVar) self
function tVar:setFormat(_numformat)
	self.numFormat = _numformat
	-- in case the eqNum is equal to the result reinit eqNum concerning _numformat
	if tonumber(self.eqNum) == tonumber(self.val) then
		self.eqNum = self:pFormatVal()
	end
	return self
end
--- removes all calculation steps from tVar object.align
--
-- @param _nameTex (string, optional) LaTeX representation
-- @return self
function tVar:clean(_nameTex)
	self.nameTex = _nameTex or self.nameTex
	self.eqNum = self:pFormatVal()
	if self.eqMat then 	self.eqMat = self:pFormatVal() end

	self.eqTex = self.nameTex
	return self
end
--- sets unit of tVar object
--
-- @param _unit (string) Unit
-- @return self
function tVar:setUnit(_unit)
	self.unit = _unit
	return self
end
--- gets unit of tVar object
--
-- @return string
function tVar:getUnit()
	if self.unit == nil then return "" end
	return "~" .. self.unitCommand .. "{" .. self.unit .. "}"
end
--- copy tVar to get rid of references
--
-- @return (tVar) copied
function tVar:copy()
	local orig = self
    local copy = getmetatable(self):New(self.val,self.nameTex,false)

	copy.eqTex = orig.eqTex
	copy.eqNum = orig.eqNum
	copy.unit = orig.unit
	copy.numFormat = orig.numFormat
	copy.mathEnviroment = orig.mathEnviroment
	copy.debugMode = orig.debugMode
	copy.outputMode = orig.outputMode
	copy.numeration = orig.numeration

	return copy
end
--- sourrounds the tVar objects eqTex and eqNum with round brackets
--
-- @return (tVar) self
function tVar:bracR()
	return self:brac("\\left(","\\right)")
end
--- sourrounds the tVar objects eqTex and eqNum with round brackets
--
-- @return (tVar) self
function tVar:bracB()
	return self:brac("\\left[","\\right]")
end
--- sourrounds the tVar objects eqTex and eqNum with round brackets
--
-- @return (tVar) self
function tVar:bracC()
	return self:brac("\\left\\lbrace","\\right\\rbrace")
end
--- sourrounds the tVar objects eqTex with round brackets
--
-- @return (tVar) self
function tVar:bracR_EQ()
	return self:brac_EQ("\\left(","\\right)")
end
--- sourrounds the tVar objects eqTex with round brackets
--
-- @return (tVar) self
function tVar:bracB_EQ()
	return self:brac_EQ("\\left[","\\right]")
end
--- sourrounds the tVar objects eqTex with round brackets
--
-- @return (tVar) self
function tVar:bracC_EQ()
	return self:brac_EQ("\\left\\lbrace","\\right\\rbrace")
end
--- sourrounds the tVar objects  eqNum with round brackets
--
-- @return (tVar) self
function tVar:bracR_N()
	return self:brac_N("\\left(","\\right)")
end
--- sourrounds the tVar objects eqNum with round brackets
--
-- @return (tVar) self
function tVar:bracB_N()
	return self:brac_N("\\left[","\\right]")
end
--- sourrounds the tVar objects eqNum with round brackets
--
-- @return (tVar) self
function tVar:bracC_N()
	return self:brac_N("\\left\\lbrace","\\right\\rbrace")
end
--- sourrounds the tVar objects eqTex and eqNum with any bracket
--
-- @return (tVar) self
function tVar:brac(left,right)
	local ret_val = self:copy()
	ret_val.eqTex = ret_val.encapuslate(ret_val.eqTex,left,right)
	ret_val.eqNum = ret_val.encapuslate(ret_val.eqNum,left,right)

	-- Latex probleme wenn klammenr ueber mehere Zeilen gehen. Daher wird bei jedem Umbruch eine symbolische klammer zu bzw. klammer auf gesetzt
	ret_val.eqTex = string.gsub(ret_val.eqTex,"[^\\right.]\\nonumber\\\\&[^\\left.]"," \\right.\\nonumber\\\\&\\left. ")
	ret_val.eqNum = string.gsub(ret_val.eqNum,"[^\\right.]\\nonumber\\\\&[^\\left.]"," \\right.\\nonumber\\\\&\\left. ")

	ret_val.nameTex = ret_val.eqTex
	return ret_val
end
--- sourrounds the tVar objects eqTex  with any bracket
--
-- @return (tVar) self
function tVar:brac_EQ(left,right)
	local ret_val = self:copy()
	ret_val.eqTex = ret_val.encapuslate(ret_val.eqTex,left,right)

	-- Latex probleme wenn klammenr ueber mehere Zeilen gehen. Daher wird bei jedem Umbruch eine symbolische klammer zu bzw. klammer auf gesetzt
	ret_val.eqTex = string.gsub(ret_val.eqTex,"[^\\right.]\\nonumber\\\\&[^\\left.]"," \\right.\\nonumber\\\\&\\left. ")
	ret_val.nameTex = ret_val.eqTex
	return ret_val
end
--- sourrounds the tVar objects eqNum with any bracket
--
-- @return (tVar) ret_val
function tVar:brac_N(left,right)
	local ret_val = self:copy()
	ret_val.eqNum = ret_val.encapuslate(ret_val.eqNum,left,right)

	-- Latex probleme wenn klammenr ueber mehere Zeilen gehen. Daher wird bei jedem Umbruch eine symbolische klammer zu bzw. klammer auf gesetzt
	ret_val.eqNum = string.gsub(ret_val.eqNum,"[^\\right.]\\nonumber\\\\&[^\\left.]"," \\right.\\nonumber\\\\&\\left. ")

	return ret_val
end

--- adds linebreak in eqNum after tVar
-- 
-- @param symb (string,optional) Symbol is added before and after linebreak
-- return (tVar) with brackets
function tVar:CRLF(symb)
	symb = symb or ""
	local ret = self:copy()
	--ret.eqTex = self.eqTex .. symb .. " \\nonumber\\\\& "
	ret.eqNum = self.eqNum .. symb .. " \\nonumber\\\\& "

	return ret
end
--- adds linebreak in eqNum before tVar
-- 
-- @param symb (string,optional) Symbol is added before and after linebreak
-- @return (tVar) with brackets
function tVar:CRLFb(symb)
  symb = symb or ""
  local ret = self:copy()
  ret.eqTex = self.eqTex
  ret.eqNum = " \\nonumber\\\\& " .. symb .. self.eqNum
  return ret
end
--- adds linebreak in eqTex after tVar
-- 
-- @param symb (string,optional) Symbol is added before and after linebreak
-- return (tVar) with brackets
function tVar:CRLF_EQ(symb)
	symb = symb or ""
	local ret = self:copy()
	ret.eqTex = self.eqTex .. symb .. " \\nonumber\\\\& "
	ret.nameTex = ret.eqTex
	ret.eqNum = self.eqNum
	return ret
end
--- adds linebreak in eqTex before tVar
-- 
-- @param symb (string,optional) Symbol is added before and after linebreak
-- @return (tVar) with brackets
function tVar:CRLFb_EQ(symb)
  symb = symb or ""
  local ret = self:copy()
	ret.eqTex = " \\nonumber\\\\& " .. symb .. self.eqTex
	ret.nameTex = ret.eqTex
  ret.eqNum = self.eqNum
  return ret
end
--- Checks if overloaded param is tVar or not
-- if not for calculation purposes the overloaded param 
-- is converted to tVar an returned
-- eq number 17 is return as tVar:New(17,"17.0")
--
-- @param _a (tVar,number) param to be cecked
-- @return (tVar) _a as tVar
function tVar.Check(_a)
	if(ismetatable(_a,tVar)) then return _a end
	ret = tVar:New(_a,tVar.formatValue(tVar.numFormat,_a,tVar.decimalSeparator))
	ret.eqTex = tVar.formatValue(tVar.numFormat,_a,tVar.decimalSeparator)
	return ret
end
--- function returns table of vlaues from tVar objects
--
-- @param tVarTable (tVar table)
-- @return table of tVar.val
function tVar.valuesFromtVar(tVarTable)
	local ret = {}
	for i=1, #tVarTable do
		ret[i] = tVarTable[i].val
	end
	return ret
end
--- used for converting lua functions to tVar function with mathematical representation
--
-- @param luaFunction function to be converted to tVar function
-- @param texBefore (string) text is added befor the list of tVar function names
-- @param texAfter (string) same as texBefor but after the list
-- @param returntype (tVar,tMat oder tVec) tVar is default
-- @return (tVar) result of lua function with tVar paramters
function tVar.link(luaFunction,texBefore,texAfter,returntype)
	local returntype = returntype
	if returntype == nil then returntype = tVar end
	local originalFunction = luaFunction
	local _texBefore = texBefore
	local _texAfter = texAfter
	
	local orcalcFunction = function (...)
		local arg = table.pack(...)
		return originalFunction(table.unpack(tVar.valuesFromtVar(arg)))
	end
	return function (...)

		local arg = table.pack(...)

		-- cheack every element in arg table in case one is a number
		local anyvalNil = false
		for i,v in ipairs(arg) do
			arg[i] = returntype.Check(v)
			if (arg[i].val == nil) then anyvalNil = true end
		end
		local ans = returntype:New(nil,"ANS")
		local val = nil

		if anyvalNil == false then
			val = originalFunction(table.unpack(returntype.valuesFromtVar(arg)))
			if returntype ~= tVar then
				val = tMat.CheckTable(val)
			end
		end
		
		ans.val = val
		-- concat arg values
		local nameStr = ""
		local numbStr = ""
		for i=1, #arg do
			nameStr = nameStr .. returntype.Check(arg[i]).nameTex
			numbStr = numbStr .. returntype.Check(arg[i]).eqNum
			if i<#arg then
				nameStr = nameStr .. "; "
				numbStr = numbStr .. "; "
			end
		end
		ans.eqTex = _texBefore .. nameStr .. _texAfter
		ans.eqNum = _texBefore .. numbStr .. _texAfter
		ans.nameTex = ans.eqTex
		
		ans.history_fun = orcalcFunction
		ans.history_arg = arg
		
		return ans
	end
end
--- rounds result to internal precision
--
-- @return (number) val of tVar roundet to calcPrecision
function tVar:roundValToPrec()
	if ismetatable(self,tVar) then
		return math.floor(self.val * 10^self.calcPrecision + 0.5)/10^self.calcPrecision
	else
		return tVar.roundNumToPrec(self)
	end
end
--- rounds result to internal precision
--
-- @param val (number)
-- @return (number) val of tVar roundet to calcPrecision
function tVar.roundNumToPrec(val)
	return math.floor(val * 10^tVar.calcPrecision + 0.5)/10^tVar.calcPrecision
end
--- quick input mode converts a string to a variable
-- Deprecated
--
function tVar.q(_)

	if type(_) ~= "table" then
		_={_}
	end
	for i,_string in ipairs(_) do
		local overLoad = string.gmatch(_string,"([^:=]+)")
		local varName = overLoad()
	
		local nameTex = tVar.formatVarName(varName)

		local value = overLoad()
		-- remove special chars from Varname
		varName = string.gsub(varName,"\\","")
		
		-- check if value is number matrix or vector
		if string.sub(value,1,2) == "{{" then --matrix
			
			local value = assert(loadstring("return " .. value))()
			_G[varName]=tMat:New(value,nameTex)
		elseif string.sub(value,1,1) == "{" then -- vector
			local value = assert(loadstring("return " .. value))()
			_G[varName]=tVec:New(value,nameTex)
		else -- number
			_G[varName]=tVar:New(value,nameTex)
		end

		if commands and commands ~= "" then 
			tex.print(commands)
			assert(loadstring(varname..commands))()
		end

		if tVar.qOutput then
			_G[varName]:outRES()
		end
	end
end

--- formats a value with underscores to a latex subscript
-- first _ ist subscript first __ is exponent rest gets ,
-- @param _string with underscore format
-- @return (string) latex subscript
function tVar.formatVarName(_string)
		local nameTex = "{".. _string .."}"
		nameTex = string.gsub(nameTex,"__","}^{",1)
		nameTex = string.gsub(nameTex,"_",",") 
		nameTex = string.gsub(nameTex,",","}_{",1)

		return nameTex
end
