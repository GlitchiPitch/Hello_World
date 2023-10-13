local GenerateMap = {}

GenerateMap.__index = GenerateMap

function GenerateMap.Generate()
    local self = setmetatable({}, GenerateMap)

    self.GridTable = {}

    self:Init()
    return self
end

function GenerateMap:Init()
    self:CreateGrid()
end

function GenerateMap:SpawnBlocks()
    
end

function GenerateMap:CreateGrid()
    for x = 1, 10 do
        self.GridTable[x] = {}
        for z = 1, 10 do
            self.GridTable[x][z] = 0
        end
    end
end

function GenerateMap:CheckNeighbors()
    
end

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



return GenerateMap