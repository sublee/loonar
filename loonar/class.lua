-- Implementation of a class
-- Using lua metatable
-- 
function class(class_object)
  local events_map = {
  	__index = '.', __newindex = '.=';
  	__lt = '<', __le = '<=';
--  	__??? = '==';

  	__add = '+', __sub = '-', __mul = '*', __div = '/', __pow = '^';
  	__concat = '..';

  	__call = '__call';

--  	__unm = '-';

  	__gc = 'destroy';

  	__tostring = 'tostring';
  }

    local class_object = class_object or {}
  local instance_protocol = { class = class_object }

  table.foreach(events_map, function(event, method)
  	if event ~= '__index' and class_object[method] then
  		instance_protocol[event] = class_object[method]
  	elseif event == '__index' and class_object[events_map.__index] then
  		instance_protocol.___index = class_object[events_map.__index]
  	end	
  end)

  function instance_protocol:__index(member)
  	if type(class_object[member]) == 'function' then
  		return function(...)
  			return class_object[member](self, ...)
  		end
  	elseif type(instance_protocol.___index) == 'function' then
  		return instance_protocol.___index(self, member)
  	else
  		return self[member]
  	end
  end

    function class_object.is_domain_of(instance)
        return class_object == getmetatable(instance).class
    end

  function class_object.is_subclass_of(class)
  	return class == table
  end

  local constructor = function(self, args)
  	args = args or {}
  	for key, value in pairs(args) do self[key] = value end
  end

  if type(class_object[1]) == 'function' then
  	constructor = table.remove(class_object, 1)
  	class_object.initialize = constructor
  elseif type(class_object.initialize) == 'function' then
  	constructor = class_object.initialize
  end

  local class_protocol = {
  	__call = function(self, ...)
  		local instance = {}

  		setmetatable(instance, instance_protocol)
  		constructor(instance, ...)

  		return instance
  	end
  }

    setmetatable(class_object, class_protocol)

    return class_object
end

-- vim:set ts=4 sw=4 sts=4 et:
