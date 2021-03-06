----------------------------------------------------------------------------
-- core script
-- creates the basic object and the New-Function
--
----------------------------------------------------------------------------

--- Vector Modul
-- Initialize tVec as empty tMat table
--
-- @param texStyle (string) defines display of matrices as variable i.e. bold
tVec = tMat:New({},"")
tVec.texStyle = function()
	return tVar.VECtexStyle	
end
--- overrides the tMat:New function with new special metatables for matrices
--
-- @param _val (2dim array) style {{r1c1,r1c2,r1c3},{r2c1,r2c2,r2c3}}
-- @param _nameTex (string) LaTeX representation
function tVec:New(_val,_nameTex)
	local ret = {}

	if ismetatable(_val,tVar) then
		return _val:copy()
	end
	if type(_val) == "table" then
		if #_val == 1 then
			if type(_val[1]) ~= "table" then
				return tVar:New(_val[1],_nameTex)
			end 
		end 
	end

	setmetatable(ret,self)
	self.__index = tMat.getMatrixVal
	self.__newindex = tMat.setMatrixVal
	self.__add = self.mAdd
	self.__sub = self.mSub
	self.__mul = self.mMul
	self.__div = self.mDiv
	self.__unm = self.mNeg
	self.__concat = self.concatnameTex
	self.__eq = self.Equal
	
	--self.__tostring = self.Print
	if _val ~= nil then
		local val = {}
		for i=1,#_val do
			if type(_val[i]) == "table" then
				if #_val[i] ~= 0 then 
					--matrice
					val[i] = {}
					for j=1,#_val[i] do
						val[i][j] = _val[i][j]
					end
				else
					--tvarobj
					val[i] = {_val[i]}
				end
			else
				--number
				val[i] = {_val[i]}
			end
		end
		ret.val = tMat.CheckTable(val)

	else
		ret.val = nil
	end

	if _nameTex == nil then
		ret.nameTex = ret:pFormatVal()
	else
		local _,count = _nameTex:gsub("\\\\" .. self.texStyle() .. "{.*}","")
		if counter == 0 then 
			ret.nameTex = "\\" .. self.texStyle() .. "{" .. _nameTex .. "}" 
		else
			ret.nameTex = _nameTex
		end
	end



	--ret.nameTex = tMat.pFormatnameTexOutp(ret.nameTex)
	ret.eqNum = ret:pFormatVal()
	ret.eqTex = ret.eqNum
	ret.eqMat = ret:pFormatnameTex()
	return ret
end
