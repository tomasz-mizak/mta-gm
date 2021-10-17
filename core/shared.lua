--[[

  core
  ~ shared

]]

vehicleIds = {400, 401, 402, 403, 404, 405, 406, 407, 408, 409, 410, 411, 412, 413, 414, 415,
	416, 417, 418, 419, 420, 421, 422, 423, 424, 425, 426, 427, 428, 429, 430, 431, 432, 433,
	434, 435, 436, 437, 438, 439, 440, 441, 442, 443, 444, 445, 446, 447, 448, 449, 450, 451,
	452, 453, 454, 455, 456, 457, 458, 459, 460, 461, 462, 463, 464, 465, 466, 467, 468, 469,
	470, 471, 472, 473, 474, 475, 476, 477, 478, 479, 480, 481, 482, 483, 484, 485, 486, 487,
	488, 489, 490, 491, 492, 493, 494, 495, 496, 497, 498, 499, 500, 501, 502, 503, 504, 505,
	506, 507, 508, 509, 510, 511, 512, 513, 514, 515, 516, 517, 518, 519, 520, 521, 522, 523,
	524, 525, 526, 527, 528, 529, 530, 531, 532, 533, 534, 535, 536, 537, 538, 539, 540, 541,
	542, 543, 544, 545, 546, 547, 548, 549, 550, 551, 552, 553, 554, 555, 556, 557, 558, 559,
	560, 561, 562, 563, 564, 565, 566, 567, 568, 569, 570, 571, 572, 573, 574, 575, 576, 577,
	578, 579, 580, 581, 582, 583, 584, 585, 586, 587, 588, 589, 590, 591, 592, 593, 594, 595,
	596, 597, 598, 599, 600, 601, 602, 603, 604, 605, 606, 607, 608, 609, 610, 611
}

function isVehicleModelExist(model)
  assert(model, "model is required")
  assert(type(model) == "number" or type(model) == "string", "model cannot be a other type as number or string")
  model = tonumber(model) or model
  if type(model) == "number" then
    if model < 400 or model > 611 then
      return false
    end
    for i, v in ipairs(vehicleIds) do
      if model == v then
        return true
      end
    end
  elseif type(model) == "string" then
    return getVehicleModelFromName(model)
  end
  return false
end

function checkVarTypes(expectedType, ...) -- for checking more than one variable type
  local array = { ... }
  for i, v in ipairs(array) do
    if type(v) ~= expectedType then
      return false
    end
  end
  return true
end

function encodePosition(x, y, z)
  assert(x and y and z, "x, y, z is required")
  assert(checkVarTypes("number", x, y, z), "cannot encode non numeric position")
  local array = { x, y, z }
  return toJSON(array)
end

function decodePosition(encoded)
  assert(encoded, "encoded position is required to decode")
  assert(type(encoded) == "string", "encoded position must be a string")
  local array = fromJSON(encoded)
  return unpack(array)
end

function deleteColorCoded(s)
  local pos = string.find(s, "#")
  if pos then
    local hex = string.sub(s, pos, pos+6)
    s = string.gsub(s, hex, "")
    pos = string.find(s, "#")
    if pos then
      return deleteColorCoded(s)
    else
      return s
    end
  end
end

function getGenderName(p) -- returning gender name
  if(p:getData("gender")) then
    return "Mężczyzna"
  else
    return "Kobieta"
  end
end

function checkTranslationForWeapon(weaponID) -- returning weapon name in pl language, if translate exist in array
  if(translatedWeapons[weaponID]~=nil) then
    return translatedWeapons[weaponID]
  else
    return getWeaponNameFromID(weaponID)
  end
end

function isLogged(p) -- checking is player currently logged
  assert(isElement(p), "given argument is not a element, required player element")
  assert(p.type == "player", "given element is not a player")
  return p:getData("logged")
end
