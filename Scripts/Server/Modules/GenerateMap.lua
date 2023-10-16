
local Block = {}

Block.__index = Block

function Block.new(x, z)
    local self = setmetatable({}, Block)
    self.Index = {x, z}
    self.Type = 0
    self.Neighbors = {}
    return self
end

function Block:Init()
    self:FindNeighbors()
end

function Block:FindNeighbors()
    local neighborIndex = {
        {self.Index[1] - 1, self.Index[2] - 1},
        {self.Index[1] - 1, self.Index[2] + 1},
        {self.Index[1] + 1, self.Index[2] - 1},
        {self.Index[1] + 1, self.Index[2] + 1},
        {self.Index[1] + 1, self.Index[2]},
        {self.Index[1] - 1, self.Index[2]},
        {self.Index[1], self.Index[2] - 1},
        {self.Index[1], self.Index[2] + 1},
    }

    for _, index in pairs(neighborIndex) do
        -- table.insert()
    end

end




local GenerateMap = {}

GenerateMap.__index = GenerateMap

function GenerateMap.Generate()
    local self = setmetatable({}, GenerateMap)

    self.GridTable = self:CreateGrid()

    self:Init()
    return self
end

function GenerateMap:Init()
end

function GenerateMap:SpawnBlocks()
    for _, row in pairs(self.GridTable) do
        for _, column in pairs(row) do 
            local block = Block.new(column[1], column[2])
        end
    end
end

function GenerateMap:CreateGrid()
    local grid = {}
    for x = 1, 10 do
        self.GridTable[x] = {}
        for z = 1, 10 do
            self.GridTable[x][z] = {x, z}
        end
    end

    return grid
end

function GenerateMap:CheckNeighbors()
    
end


return GenerateMap