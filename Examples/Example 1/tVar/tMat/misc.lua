----------------------------------------------------------------------------
-- misc script
-- contains function not intend to be used by users
--
----------------------------------------------------------------------------
--- same setName as in tVar but uses param texStyle for formatting
--
-- @param _nameTex (string) LaTeX representation
-- @return self 
function tMat:setName(_nameTex)
	self.nameTex = "\\" .. self.texStyle .. "{" .. _nameTex .. "}"
	return self
end
--- create a copy of a matrix to remove pointers on table
--
-- @return (tMat) copy
function tMat:copy()
  local ret = tMat:New(self.val,self.nameTex)
  ret.eqNum = self.eqNum
  ret.eqTex = self.eqTex
  return ret
end
--- returns the size of the matrix
--
-- @param rc (1 or 2) 1 is for row count 2 if for collumn count
-- @return (number)
function tMat:size(rc)
  if rc == 1 then return #self.val end
  return assert(#self.val[1],1)
end
--- Checks if overloaded param is tMat,tVec,tVar or not
-- if not for calculation purposes the overloaded param 
-- is converted to tVar and returned
-- eq number 17 is return as tVar:New(17,"17.0")
--
-- @param _a (tVar,tMat,tVec,number) param to be cecked
-- @return (tVar) _a as tVar
function tMat.Check(_a)
  if(getmetatable(_a) == tVar or getmetatable(_a) == tMat or getmetatable(_a) == tVec) then return _a end
  ret = tVar:New(_a*1,tVar.formatValue(tVar.numFormat,_a,tVar.decimalSeparator))
  ret.eqTex = tVar.formatValue(tVar.numFormat,_a,tVar.decimalSeparator)
  return ret
end