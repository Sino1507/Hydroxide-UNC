local ConstantScanner = {}
local Closure = import("objects/Closure")
local Constant = import("objects/Constant")

local requiredMethods = {
    ["getGc"] = true,
    ["getInfo"] = true,
    ["isXClosure"] = true,
    ["getConstant"] = true,
    ["setConstant"] = true,
    ["getConstants"] = true
}

local function compareConstant(query, constant)
    local constantType = type(constant)

    local stringCheck = constantType == "string" and (query == constant or constant:lower():find(query:lower()))
    local numberCheck = constantType == "number" and (tonumber(query) == constant or ("%.2f"):format(constant) == query)
    local userDataCheck = constantType == "userdata" and tostring(constant) == query

    if constantType == "function" then
        local closureName = debug.getinfo(constant).name or ''
        return query == closureName or closureName:lower():find(query:lower())
    end

    return stringCheck or numberCheck or userDataCheck
end 

local function scan(query)
    local constants = {}

    for _i, closure in pairs(getgc()) do
        if type(closure) == "function" and not isexecutorclosure(closure) and iscclosure(closure) and not constants[closure] then
            for index, constant in pairs(debug.getconstants(closure)) do
                if compareConstant(query, constant) then
                    local storage = constants[closure]

                    if not storage then
                        local newClosure = Closure.new(closure)
                        newClosure.Constants[index] = Constant.new(newClosure, index, constant)
                        constants[closure] = newClosure
                    else
                        storage.Constants[index] = Constant.new(storage, index, constant)
                    end
                end
            end
        end
    end

    return constants
end

ConstantScanner.Scan = scan
ConstantScanner.RequiredMethods = requiredMethods
return ConstantScanner