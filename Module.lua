FloatTable = {}
local csv = require("csv")

  -- Contructor
function FloatTable:new()
  local m = {
  rowCount = 1,
  columnCount = 1,
  data = {},
  rowNames = {},
  columnNames = {}
	};
  setmetatable(m,self);
  self.__index = self;
  return m;
end

function FloatTable:construc(filename)
	

	
	local rows = load_csvfile(filename)
	
	local colums = rows[1]
	
    self.columnNames = colums--subset(columns, 1);
    --scrubQuotes(self.columnNames);
    self.columnCount = #self.columnNames

    self.rowNames = {}--{(#rows)-1};
    self.data = {}--{(#rows)-1};
    for i = 2,#rows do
	  local pieces = rows[i]
      self.rowNames[self.rowCount] = pieces[1];
	  table.remove(pieces,1)
      self.data[self.rowCount] = pieces

      self.rowCount = self.rowCount+1;      
    end
    --selfdata = subset(data, 0, self.rowCount);
	--]]
end

function FloatTable:scrubQuotes(array) 
	for i = 1, #array do
		if #(array[i]) > 2 then
			if (array[i].startsWith("\"") and array[i].endsWith("\"")) then ----NOSE
				array[i] = array[i].substring(1, #(array[i]) - 1)  ----NOSE
			end
		end
	array[i] = array[i].replaceAll("\"\"", "\"");   ----NOSE
	end
end

function FloatTable:getRowCount() 
	return self.rowCount
end

function FloatTable:getRowName(rowIndex)  
	return self.rowNames[rowIndex]
end

 function FloatTable:getRowNames() 
	return self.rowNames
end

function FloatTable:getRowIndex(name) 
	for i = 1, self.rowCount do
		if self.rowNames[i] == name then 
			return i
		end
	end
	return -1
end

function FloatTable:getColumnCount()  
	return self.columnCount
end

 function FloatTable:getColumnName(colIndex) 
	return columnNames[colIndex]
end

function FloatTable:getColumnNames()  
	return self.columnNames
end

----------------------------------------------------------------
function FloatTable:getFloat(rowIndex,col) 
    if ((rowIndex < 0) or (rowIndex >= #data))then
      print("There is no row " + rowIndex)
    end
    if ((col < 0) or (col >= #(data[rowIndex]))) then
      print("Row " + rowIndex + " does not have a column " + col);
    end
    return data[rowIndex][col];
end


function FloatTable:isValid(row, col) 
    if row < 0 then 
		return false;
	end

    if row >= self.rowCount then 
		return false;
	end
    if col >= #(data[row]) then 
		return false;
	end
    if col < 0 then 
		return false;
	end
		return not (Float.NaN(data[row][col]))
	end


  function FloatTable:getColumnMinMax(col) 
    local Min =  0; ---NOSE
    local  Max = 0; ---NOSE
    for i = 1,self.rowCount do

      if not (Float.NaN(data[i][col])) then

        if (data[i][col] < Min) then
          Min = data[i][col];
        end

        if (data[i][col] > Max) then
          Max = data[i][col];
        end
      end
    end
    local toRet = { Min, Max };
    return toRet;
  end


   function FloatTable:getColumnMin( col) 
    local m = 0;
    for i = 1, self.rowCount do
      if not(Float.isNaN(data[i][col])) then
        if (data[i][col] < m) then
          m = data[i][col];
        end
      end
    end
    return m;
  end


  function FloatTable:getColumnMax( col) 
    local m = 0;
    for i = 1,self.rowCount do
      if (self.isValid(i, col)) then
        if (data[i][col] > m) then
          m = data[i][col];
        end
      end
    end
    return m;
  end


  function FloatTable:getRowMin(row) 
    local m = 0;
    for i= 1,self.columnCount do
      if (isValid(row, i)) then
        if (data[row][i] < m)then
          m = data[row][i];
        end
      end
    end
    return m;
  end


  function FloatTable:getRowMax(row) 
    local m = 0;
    for i = 1, i <= self.columnCount, 1 do 
      if not (data[row][i] == nil) then
        if data[row][i] > m then
          m = data[row][i];
        end
      end
    end
    return m;
  end


  function FloatTable:getTableMin() 
    local m = 0;
    for i = 1, self.rowCount do
      for j = 1,columnCount do
        if (isValid(i, j)) then
          if data[i][j] < m then
            m = data[i][j];
          end
        end
      end
    end
    return m;
  end


  function FloatTable:getTableMax() 
    local m = 0;
    for i = 1,self.rowCount do
      for j =1,columnCount do
        if (isValid(i, j)) then
          if (data[i][j] > m) then
            m = data[i][j];
          end
        end
      end
    end
    return m;
  end
  
  function mysplit(inputstr, sep)
        if sep == nil then
                sep = "%s"
        end
        local t={} ; i=1
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                t[i] = str
                i = i + 1
        end
        return t
end


function fromCSV (s)
  s = s .. "\r\n"        -- ending comma
  local t = {}        -- table to collect fields
  local fieldstart = 1
  repeat
    -- next field is quoted? (start with `"'?)
    if string.find(s, '^"', fieldstart) then
      local a, c
      local i  = fieldstart
      repeat
        -- find closing quote
        a, i, c = string.find(s, '"("?)', i+1)
      until c ~= '"'    -- quote not followed by quote?
      if not i then error('unmatched "') end
      local f = string.sub(s, fieldstart+1, i-1)
      table.insert(t, (string.gsub(f, '""', '"')))
      fieldstart = string.find(s, ',', i) + 1
    else                -- unquoted; find next comma
      local nexti = string.find(s, "\r\n", fieldstart)
      table.insert(t, string.sub(s, fieldstart, nexti-1))
      fieldstart = nexti + 1
    end
  until fieldstart > string.len(s)
  return t
end

function load_csvfile(filepath)
	local file = io.open(filepath,"r")
	local tod = {}
	if file then
		for line in file:lines() do
			local temp = {}
			for item in string.gmatch(line,"[^,]*") do --does not work for strings containing ','
				if item ~= "" then
					item = item:gsub(",","")
					item = item:gsub("^%s*(.-)%s*$", "%1") -- remove trailing white spaces
					table.insert(temp,item)
				end
			end
			table.insert(tod, temp)
		end
	else
		print("Cannot open file: "..filepath)
		
	end
	return tod
end