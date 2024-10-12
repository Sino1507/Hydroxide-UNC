local LocalScript = {}

function LocalScript.new(instance)
    local localScript = {}
    local closure = getscriptclosure(instance)

    localScript.Instance = instance
    localScript.Environment = getsenv(instance)
    localScript.Constants = debug.getconstants(closure)
    localScript.Protos = debug.getprotos(closure)

    return localScript
end

return LocalScript