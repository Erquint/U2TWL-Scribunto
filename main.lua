-- https://github.com/Erquint/U2TWL-Scribunto/tree/scribunto

local functions = {}

function string_split(in_string, separator)
  if in_string:sub(-1) ~= separator then
    in_string = in_string .. separator
  end
  return in_string:gmatch('(.-)' .. separator)
end

function parse_game_table(game_string)
  local out_table = {}
  for line in string_split(game_string, '\n') do
    local row = {}
    for cell in string_split(line, ',') do
      if #row > 0 and row[#row]:sub(1, 1) == '"' and row[#row]:sub(-1) ~= '"' then
        row[#row] = row[#row] .. ',' .. cell
      else
        if #row > 0 and row[#row]:sub(-1) == '"' then
          row[#row] = row[#row]:sub(2, -2)
        end
        table.insert(row, cell)
      end
    end
    if #out_table > 0 then
      for i = 1, #out_table[1] - #row do table.insert(row, '') end
    end
    table.insert(out_table, row)
  end
  return out_table
end

function select_table_column(full_table, column_header)
  local out_table = {}
  local header_index = 0
  for index, row in ipairs(full_table) do
    local out_row = {}
    if header_index == 0 then
      for index, cell in ipairs(row) do
        if cell == column_header then header_index = index end
      end
    end
    table.insert(out_row, row[1])
    table.insert(out_row, row[header_index])
    table.insert(out_table, out_row)
  end
  return out_table
end

function construct_wikitable(game_table, header)
  local out_string = '{| class="wikitable sortable"\n|+ ' .. header .. '\n|-\n'
  local tag = '! '
  for index, row in ipairs(game_table) do
    for index, cell in ipairs(row) do
      out_string = out_string .. tag .. cell .. '\n'
    end
    out_string = out_string .. '|-\n'
    if tag == '! ' then tag = '| ' end
  end
  out_string = out_string .. '|}'
  return out_string
end

local game_table_string = [[affordances,sword,swordShort,quarterstaff,axe,mace,spear,javelin,dagger,axeThrowing,clubThrowing,bow,shield,lightArmor,heavyArmor,ring,amulet,mask,wand,staff,rod,scepter,boots,cloak,lantern,clawRoot
affordances,"attack, heavy attack, parry","attack, heavy attack, parry","attack, heavy attack, throw, parry","attack, heavy attack","attack, heavy attack","attack, heavy attack","attack, throw","attack, throw, parry","attack, throw","attack, throw","shoot, heavy shot",block,passive,passive,passive,passive,passive,cast attack spell,"cast command spell, possibly aura",cast spell,summoning spells,"passive travel effects, no charges","passive travel effects, no charges",passive/utility effects,
Flame1,Glowing,,Frost,Frost,Frost,FireSpike,FlamingThrow,FlamingThrow,Frost,Frost,FlamingBow,GlowingShield,FlameResistance,FlameResistance,Charisma,Charisma,,FireBolt,SummonGrenadeRocks,Flames,SummonSkulls,,,,
Flame2,FlameStrike,,Freezing,Freezing,Freezing,FireSpikeTriple,FireStorm,FireStorm,FrostSpikeThrow,FrostSpikeThrow,BurningBow,FireWardShield,FireWardArmor,FireWardArmor,ResistHeat,,,FireBall,RainFire,FlamesMajor,CommandUndead,,,,
Flame3,FuryStrike,,FrostSpike,FrostSpike,FrostSpike,,,,,,BurningBowMajor,FlamingShield,FireWardArmorMajor,FireWardArmorMajor,FireWard,,,FireBallTriple,RainFireMajor,SpikedFlames,SummonCruips?,,,,
,,,,,,,,,,,,,,,,,,,,,,,,,
Flow1,Flowing,,Flowing,FlowingNoParry,FlowingNoParry,FlowingNoParry,Returning,Returning,Returning,Returning,ForceBow,FlowingShield,FlowResistance,FlowResistance,FlowWalking,Agility?,WaterWalking,HomingMissile,CommandFlow,HowlingWind,SummonBlades,,,,
Flow2,Parrying,,FlowRiposte,Dazzling,Dazzling,Dazzling,ForceThrow,ForceThrow,ForceThrow,ForceThrow,ForceBowMajor,DeflectingShield,DodgingArmor,DeflectionArmor,Haste,,,ForceBolt,CommandContraption?,WindShards?,,,,,
Flow3,FlowStrike,,FlowStrikeMajor,FlowStrikeNoParry,FlowStrikeNoParry,FlowStrikeNoParry,ForceThrowMajor,ForceThrowMajor,ForceThrowMajor,ForceThrowMajor,,MagicDeflectingShield,DodgingArmorMajor,DeflectionArmorMajor,WaterWalking,,,ForceBoltMajor,,,,,,,
,,,,,,,,,,,,,,,,,,,,,,,,,
Form1,Cutting,,Stunning,Cutting,Stunning,Cutting,ShatteringThrow,Stunning,ShatteringThrow,ShatteringThrow,SplittingBow,WardingShield,FormResistance,FormResistance,Protection,,Shielding,MagicRocks,Tremmor,MudGrenade,Tremmor,,,,
Form2,Sharpness,,Impact,Sharpness,Impact,Sharpness,SmashingThrow,ShatteringThrow,SmashingThrow,SmashingThrow,SplittingBowMajor,ExcellenceShield,HardenedArmor,HardenedArmor,Shielding,,,MagicRocksMajor,TremmorMajor,,TremmorMajor,,,,
Form3,Mastery,,MasteryImpact,Mastery,MasteryImpact,Mastery,,SmashingThrow,,,SplittingShrapnellBow?,,,RuinArmor,,,,MagicRocksShattering,Ruin?,,,,,,
,,,,,,,,,,,,,,,,,,,,,,,,,
Root1,PiercingStrike,,PiercingStrike,Growing,Growing,PiercingStrike,PiercingThrow,LifeStealing,Growing,Growing,PiercingBow,StrengthShield,RegenerationArmor,RootResistance,Ferociousness,Stamina?,FerociousStrength,RootAttackStaff,CommandRoot,Webbing,SummonSpiders,,,,Growing
Root2,RootAttack,,RootAttack,RootSmash,RootSmash,RootAttack,GrowingPiercingThrow,LifeStealingMajor,LifeStealingMajor,TanglingThrow?,TanglingBow,RootAttackShield,PiercingWardArmor,RageArmor?,Strength,FatigueWard?,,RootAttackStaffGrowing,SummonRoot,,SummonPoisonSpiders,,,,LifeStealing
Root3,RootAttackMajor,,RootAttackMajor,RootSmashMajor,RootSmashMajor,RootAttackMajor,RootAttackThrow,,,,TanglingBowMajor,RootAttackShieldMajor,,,FerociousStrength,RegenationRing = if you wound somebody you heal a wound of your own?,,RootAttackStaffMajor,,,SummonVampiricSpiders,,,,
,,,,,,,,,,,,,,,,,,,,,,,,,
Sky1,ShockingStrike,,ShockingStrike,ShockingStrike,Thunder,ShockingStrike,ShockingThrow,ShockingThrow,ShockingThrow,ShockingThrow,ShockingBow,StunningShield,SkyResistance,SkyResistance,SuperiorStealth,Clarity?,Invisibility,ShockingMissile,Awe,Blinking,SummonShades,Stealth,SuperiorStealth,,
Sky2,BlindingStrike,,BlindingStrike,BlindingStrike,ThunderStorm,BlindingStrike,LightningThrow,BlindingThrow,ThunderThrow,ThunderThrow,ThunderBow,ShockingShield,SpellResistance,StuningWardArmor,MinorInvisibility,StunningWard,,BlindingMissile,StormFist,,ControlShades?,SuperiorStealth,MinorInvisibility,,
Sky3,LightningStrike,,LightningStrike,LightningStrike,ThunderStormMajor,LightningStrike,LightningThrowMajor,,ThunderThrowMajor,ThunderThrowMajor,,BlindingShield,,,Invisibility,,,LightningMissile,,,,,Invisibility,,
,,,,,,,,,,,,,,,,,,,,,,,,,
,,,,,,,,,,,,,,,,,,,,,,,,,
AltFlame1,Forst,,,,,,Frost,Glowing,,,FrostBow,,FrostResistance,FrostResistance,,,,FireBoltTriple,,Icicles,,,,,
AltFlame2,Freezing,,,,,,FrostSpikeThrow,FlamingParry,,,FrostBowMajor,,FrostWardArmor,FrostWardArmor,,,,FireBallTripe,RainFireAndIce?,IciclesBurst,,,,,
AltFlame3,FrostSpike,,,,,,,,,,,,FrostWardArmorMajor,FrostWardArmorMajor,,,,FieryDoom,,IciclesTriple,,,,,
,,,,,,,,,,,,,,,,,,,,,,,,,
AltFlow1,,,,,,,,Dazzling,,,,DazzlingShield,,,,,,MagicMissile,CalmWind,Steam,,,,,
AltFlow2,Dazzling,,Dazzling,,,,,Parrying,,,,,,,,,,MagicMissileTriple,ChangeWeather?,SteamMajor,,,,,
AltFlow3,FlowStrikeMajor,,FlowStrikeMajor,,,,,,,,,,,,,,,,,SteamEpic,,,,,
,,,,,,,,,,,,,,,,,,,,,,,,,
AltForm1,Hardened?,,,,,,,,,,,StoneSkinShield,FormResistance,FormResistance,StunningWard,,,RuinBolt,,,,,,,
AltForm2,Wrecking?,,,,,,,,,,,Hardened?,StunningWardArmor,StunningWardArmor,,,,RuinBoltMajor,MeteorStrike,,,,,,
AltForm3,Ruin?,,,,,,,,,,,,,,,,,,MeteorStrikeMajor,,,,,,
,,,,,,,,,,,,,,,,,,,,,,,,,
AltRoot1,,,,PiercingStrike,,,PoisonThrow,PiercingThrow,PiercingThrow,PiercingThrow,,StealStrengthShield,PoisonWardArmor,,PoisonWard,,,RootMissiles,,PoisonSpray,ControlCreature?,,,,
AltRoot2,PoisonStrike,,,LifeStealing,,LifeStealing,GrowingPoisonThrow,PoisonThrow,GrowingPiercingThrow,GrowingPiercingThrow,PoisonBow,StealStrengthShieldMajor,,,,,,PoisonMissiles,,,,,,,
AltRoot3,KillingStrike?,,,LifeStealingMajor,,LifeStealingMajor,KillingThrow?,GrowingPoisonThrow,,,KillingBow?,,,,,,,VampiricMissiles,,,,,,,
,,,,,,,,,,,,,,,,,,,,,,,,,
AltSky1,,,,,,,,,,,StealthBow,NullifyMagic,SpellResistance,,,,,,Teleportation,,,,,,
AltSky2,,,,,,LightningMissileStrike?,,,,,StealthBowMajor,AbsorbMagic,SpellWardArmor,,,,,LightningMissile,SummonGate,,,,,,
AltSky3,LightningMissileStrike?,,,,,ForkedLightningMissileStrike?,,,,,,,AbsorbMagicArmor,,,,,ForkedLightning,SummonGateMajor,,,,,,]]

local game_version_string = 'version unknown'
local page_title = mw.title.getCurrentTitle()
-- `page_title.text` returns string containing mixed-case page title without type and with spaces instead of underscores.
local filter = page_title.text:lower()

function functions.build_table(frame)
  local game_table = parse_game_table(game_table_string)
  if frame.args.filter ~= nil then
    if frame.args.filter ~= 'true' then filter = frame.args.filter end
    game_table = select_table_column(game_table, filter)
  end
  local wiki_table_string = construct_wikitable(game_table, game_version_string)
  return wiki_table_string
end

return functions
-- print(functions.category_table(nil))
