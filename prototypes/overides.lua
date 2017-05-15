--require("config")

local multiplier = 20
local timeCap = 600;


--Whitelist
-- Logistic robots
-- Landmines
-- Repair-pack
-- 
--

--Blacklist
-- Nuclear Bomb
-- Discharge Defence remote
-- Trainstop
-- Car/Tank/Train/Traincar
-- Wood Chest
-- Combinators/Speaker
-- Axes


--Maybe All placables except
-- Roboports
-- Beacons
-- Oil Wells
-- Refineries
-- Stone Furnace
-- Boiler
-- Offshore Pump
-- T1 Assembler
-- Burner Drill
-- Reactor, Turbine, Exchanger
-- Centrifuge
-- 



local recipe_whitelist =
{
	"empty-barrel", -- barrels themselves are mass producable, just not the recipes using them.
}

local recipe_blacklist =
{
	"kovarex-enrichment-process", -- Given the startup costs, excluding this is probably a good idea.
	--"uranium-processing",
	"uranium-fuel-cell", -- not the kind of thing you probably want to have to craft 50x of.
	"nuclear-fuel-reprocessing",
	

	
}

local item_whitelist =
{ -- A lot of these need to have a normal filter for them. All walls, gates, rails, and pipes (maybe pipe to ground) should be mass produced I think.
	"land-mine", -- Landmines are essentially ammo, more than a placable item.
	"stone-wall", -- I can't see harm in massproducing walls
	--"gate",
	--"rail-signal", // Maybe?
	--"rail",
	--"rail-chain-signal",
	--"pipe",
}

local item_blacklist =
{
	"empty-barrel", -- because unbarreling and stack size stuff.
	"iron_stick", -- because starting pickaxe
	"discharge_defence", -- because you only ever need one per player
	"atomic-bomb", -- because seriously...
	
	"low-density-structure", -- Leave... The Rocket... Alone...
	"rocket-fuel",
	"rocket-control-unit",
	"rocket-part", 
	"satellite",
}

local typelist = 
{
"ammo",
"rail-planner", -- rails always are used in massive numbers.
--"armor", -- Mass producing armor is pointless.
"capsule",
"fluid",
--"gun", -- Same with guns
"item",
--"mining-tool", -- More irritating here
"module", -- Might want to disable this if you don't want to the 10 minutes it takes to produce 10 T3 modules or whatever.
"tool", -- This seems to be science packs, so yea.
"repair-tool", 
--"item-with-entity-data" -- bit too concerned about this part.
}



-- NYI, Softer mulitpliers rather than full blacklist, for things you want only a small multiplier to.
local typeMult =
{
	-- multipliers for types of items.
	-- NYI
}
local itemMult = 
{
	-- multipliers for specific items
	-- NYI
}
local recipeMult = 
{
	-- multipliers for specific recipies
	-- NYI
}

	
	
-- From BobLib
function get_item_type_name(name)
  local item_types = {"ammo", "armor", "capsule", "fluid", "gun", "item", "mining-tool", "module", "tool", "item-with-entity-data", "repair-tool"}
  local item_type = nil
  for i, type_name in pairs(item_types) do
    if data.raw[type_name][name] then item_type = type_name end
  end
  return item_type
end


function modRecipe (recipe)

	local mult = multiplier 
	
	if (recipe.energy_required) then
		if recipe.energy_required * multiplier > timeCap then
			mult = math.floor((timeCap/recipe.energy_required)/10)*10
		end
	else
	
	end
	
	for i, ingredient in pairs(recipe.ingredients) do
		if (ingredient.type or ingredient.name or ingredient.amount) then
			-- Assuming all recipes use the same format.
			ingredient.amount = ingredient.amount * mult
		else
			ingredient[2] = ingredient[2] * mult
		end
	end
	--{type="fluid", name="lubricant", amount=40},

	if (recipe.results) then
		for x, result in pairs(recipe.results) do
			if (result.amount) then
				result.amount = result.amount * mult
			else
				result.amount = mult
			end
		end
	else
		if (recipe.result_count) then
			recipe.result_count = recipe.result_count * mult
		else
			recipe.result_count = mult * 1 -- Default 1 
		end
	end
	if (recipe.energy_required) then
		recipe.energy_required = recipe.energy_required * mult
	else
		recipe.energy_required = mult*0.5 -- Default 0.5
	end
	
end


function getRecipeBase(prototype)
	local oRecipe = {}
	
	if (prototype.ingredients) then
		oRecipe[1] = prototype
		-- normal recipe
	else
	
		-- complex recipies
		if (prototype.normal) then
			oRecipe[1] = prototype.normal
		end
		
		if (prototype.expensive) then
			oRecipe[2] = prototype.expensive
		end
	end
	
	return oRecipe
end


function modPrototype(prototype)


	local recipes = getRecipeBase(prototype)
	
	for i, recipe in pairs (recipes) do
		modRecipe(recipe)
	
	end
        
end


function table.contains(table,element)
	for _, value in pairs(table) do
		if value == element then
			return true
		end
	end
	return false
end

function isItemTypeValid(item_name)
	local type_name = get_item_type_name(item_name)
	
	if (type_name) then
	
		local item = data.raw[type_name][item_name]
		if (table.contains(typelist,type_name)) then
			return true
		end
	end
	return false;

end

function isItemValid(item_name, isResult)
	local type_name = get_item_type_name(item_name)
	
	if (type_name) then
	
		local item = data.raw[type_name][item_name]
		
		if (table.contains(item_whitelist,item_name)) then

			return true -- whitelist overrides everything.
		end
		
		if (table.contains(item_blacklist,item_name)) then

			return false -- blacklist overrides everything but whitelist.
		end
		
		-- Need a filter to detect Logistics bots, belts, and other safe placables.
		
		if item.place_result and isResult then -- Placable things are ignored.
			return false
		end
		
		if item.placed_as_equipment_result and isResult then -- Equipment as well
			return false
		end
		
		-- Remote controls are ignored.
		if item.capsule_action and item.capsule_action.type == "equipment-remote" then
			return false 
		end
		
		
		
		
		return true;
	end
	return false
end

function checkItem(item_name, oData, isResult)

	if not isItemValid(item_name, isResult) then
		oData.valid = false
	end
	if not isItemTypeValid(item_name) then
		oData.typeMatch = false
	end
	
	return oData
end


for i,prototype in pairs(data.raw.recipe) do
	local recipes = getRecipeBase(prototype)
	for i, recipe in pairs (recipes) do
		
		local valid = true
		local typeMatch = true
		
		if (table.contains(recipe_whitelist,recipe.name)) then
	
			valid = true
			typeMatch = true
			
		else
		
			if (table.contains(recipe_blacklist,recipe.name)) then

				valid = false
				typeMatch = false
			
			else
				if (recipe.results) then
					for x, result in pairs(recipe.results) do
						local item
						if (result.type or result.name or result.amount) then
							item = result.name
						else
							item = result
						end
						
						local data = checkItem(item,{valid = valid,typeMatch = typeMatch},true)
						
						valid = data.valid
						typeMatch = data.typeMatch
						
								
					end
				else
					if (recipe.result.type or recipe.result.name or recipe.result.amount) then
						item = recipe.result.name
					else
						item = recipe.result
					end
					
					local data = checkItem(item,{valid = valid,typeMatch = typeMatch},true)
					valid = data.valid
					typeMatch = data.typeMatch
				end
				
				
				if (recipe.ingredients) then
					for x, ingredient in pairs(recipe.ingredients) do
						local item
						if (ingredient.type or ingredient.name or ingredient.amount) then
							item = ingredient.name
						else
							item = ingredient[1]
						end
						
						local data = checkItem(item,{valid = valid,typeMatch = typeMatch},false)
						
						valid = data.valid
						--typeMatch = data.typeMatch -- ingredient types are not checked.
						
								
					end
				else
					if (recipe.ingredient.type or recipe.ingredient.name or recipe.ingredient.amount) then
						item = recipe.ingredient.name
					else
						item = recipe.ingredient[1]
					end
					
					local data = checkItem(item,{valid = valid,typeMatch = typeMatch},false)
					valid = data.valid
					--typeMatch = data.typeMatch
					
						
				end
			end
		end
		
		
		
		
		if (typeMatch and valid) then
			modPrototype(recipe)
		end
	end
	
end

--[[
{
"ammo",
"armor",
"capsule",
"fluid",
"gun",
"item",
"mining-tool",
"module",
"tool",
"item-with-entity-data"
}
]]--






