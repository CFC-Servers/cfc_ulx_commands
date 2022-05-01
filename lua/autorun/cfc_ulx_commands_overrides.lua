local plyMeta = FindMetaTable("Player")
plyMeta._GetName = plyMeta._GetName or plyMeta.GetName

plyMeta.GetName = function(self, ...)
    if self.nameOverride then
        return self.nameOverride
    end

    return plyMeta._GetName(self, ...)
end

plyMeta._Nick = plyMeta._Nick or plyMeta.Nick

plyMeta.Nick = function(self, ...)
    if self.nameOverride then
        return self.nameOverride
    end

    return plyMeta._Nick(self, ...)
end
