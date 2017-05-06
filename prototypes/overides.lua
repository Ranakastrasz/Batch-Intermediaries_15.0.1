--require("config")

local multiplier = 10



function modRecipe (recipe)

	for i, ingredient in pairs(recipe.ingredients) do
		if (ingredient.type or ingredient.name or ingredient.amount) then
			-- Assuming all recipes use the same format.
			ingredient.amount = ingredient.amount * multiplier
		else
			ingredient[2] = ingredient[2] * multiplier
		end
	end
	--{type="fluid", name="lubricant", amount=40},

	if (recipe.results) then
		for x, result in pairs(recipe.results) do
			if (result.amount) then
				result.amount = result.amount * multiplier
			else
				result.amount = multiplier
			end
		end
	else
		if (recipe.result_count) then
			recipe.result_count = recipe.result_count * multiplier
		else
			recipe.result_count = multiplier * 1 -- Default 1 
		end
	end
	
	if (recipe.energy_required) then
		recipe.energy_required = recipe.energy_required * multiplier
	else
		recipe.energy_required = multiplier*0.5 -- Default 0.5
	end
end

function modPrototype(recipeName)
		local prototype = data.raw.recipe[recipeName]
		if (prototype.ingredients) then
			modRecipe(prototype) 
			-- normal recipe
		end
		
		-- complex recipies
		if (prototype.normal) then
			modRecipe(prototype.normal)
		end
		
		if (prototype.expensive) then
			modRecipe(prototype.expensive)
		end
        
end

function modItemType(itemType)
	for i,prototype in pairs(data.raw.recipe) do
		if prototype.category == categoryName do
			modPrototype(prototype.name)
		end
	end
end

-- Plates
modPrototype("copper-plate")
modPrototype("iron-plate")
modPrototype("steel-plate")
modPrototype("stone-brick")

-- Tiles
--modPrototype("concrete")
--modPrototype("landfill")
--modPrototype("rail")

-- Intermediaries
modPrototype("iron-gear-wheel")
modPrototype("iron-stick")
modPrototype("copper-cable")
modPrototype("electronic-circuit")
modPrototype("advanced-circuit")
modPrototype("processing-unit")

-- Oil
modPrototype("basic-oil-processing")
modPrototype("advanced-oil-processing")
modPrototype("coal-liquefaction")

-- Cracking
modPrototype("heavy-oil-cracking")
modPrototype("light-oil-cracking")


-- Solid Fuel
modPrototype("solid-fuel-from-light-oil")
modPrototype("solid-fuel-from-petroleum-gas")
modPrototype("solid-fuel-from-heavy-oil")

-- Oil Intermediaries
modPrototype("lubricant")
modPrototype("sulfur")
modPrototype("sulfuric-acid")
modPrototype("plastic-bar")
modPrototype("explosives")
modPrototype("battery")

-- Science Packs
--modPrototype("science-pack-1")
--modPrototype("science-pack-2")
--modPrototype("military-science-pack")
--modPrototype("production-science-pack")
--modPrototype("high-tech-science-pack")

-- Ammo





