print("连接成功")
Mop_Custom_Load = true -- 请勿删除 这是检查是否导入成功的变量
-- 自定义副本 影牙城堡例子 具体API请参考 api.funlua.com
-- Custom dungeon example for Shadowfang Keep, API please go to api.funlua.com

-- 这里是变量区域 请自行添加或删除
-- Here is for vars, please add or delete by yourself
--DKskills
MountName = "Acherus Deathcharger"
BloodFury = select(7,GetSpellInfo("Blood Fury"))
BloodBoil = select(7,GetSpellInfo("Blood Boil"))
BloodTap = select(7,GetSpellInfo("Blood Tap"))
DancingRuneWeapon = select(7,GetSpellInfo("Dancing Rune Weapon"))
DeathPact = select(7,GetSpellInfo("Death Pact"))
HeartStrike = select(7,GetSpellInfo("Heart Strike"))
MarkofBlood = select(7,GetSpellInfo("Mark of Blood"))
Pestilence = select(7,GetSpellInfo("Pestilence"))
RuneTap = select(7,GetSpellInfo("Rune Tap"))
Strangulate = select(7,GetSpellInfo("Strangulate"))
VampiricBlood = select(7,GetSpellInfo("Vampiric Blood"))
ChainsofIce = select(7,GetSpellInfo("Chains of Ice"))
EmpowerRuneWeapon = select(7,GetSpellInfo("Empower Rune Weapon"))
FrostFever = select(7,GetSpellInfo("Frost Fever"))
HornofWinter = select(7,GetSpellInfo("Horn of Winter"))
IceboundFortitude = select(7,GetSpellInfo("Icebound Fortitude"))
IcyTouch = select(7,GetSpellInfo("Icy Touch"))
MindFreeze = select(7,GetSpellInfo("Mind Freeze"))
Obliterate = select(7,GetSpellInfo("Obliterate"))
PathofFrost = select(7,GetSpellInfo("Path of Frost"))
RuneStrike = select(7,GetSpellInfo("Rune Strike"))
AntiMagicShield = select(7,GetSpellInfo("Anti-Magic Shell"))
BloodPlague = select(7,GetSpellInfo("Blood Plague"))
DeathCoil = select(7,GetSpellInfo("Death Coil"))
DeathGrip = select(7,GetSpellInfo("Death Grip"))
DeathStrike = select(7,GetSpellInfo("Death Strike"))
DeathandDecay = select(7,GetSpellInfo("Death and Decay"))
PlagueStrike = select(7,GetSpellInfo("Plague Strike"))
RaiseDead = select(7,GetSpellInfo("Raise Dead"))
BloodPresence = select(7,GetSpellInfo("Blood Presence"))
FrostPresence = select(7,GetSpellInfo("Frost Presence"))
UnholyPresence = select(7,GetSpellInfo("Unholy Presence"))

HealingPotion = 22829

-- mapid 用C_Map.GetBestMapForUnit("player")获取
-- Dungeon_In 是进入副本坐标
-- Dungeon_Out 是出副本坐标
-- Dungeon_Flush_Point 是爆本后 等待位置的坐标
Dungeon_In = {mapid = 1446, x = -8330, y = -4052, z = -208}
Dungeon_Out = {mapid = 274, x = 2770, y = 1292, z = 13.82} 
Dungeon_Flush_Point = {mapid = 1446, x = -8359.11, y = -4058.83, z = -208.18}

-- GetInstanceInfo()的id
Dungeon_ID = 560

-- Frost 冰环后退
Frost = {used = false}

-- 传送检测的变量
-- x,y,z 是上次位置的记录
-- timer 是已经被传送 开始计时
-- time 是被传送的时间
teleport = {x = 0, y = 0, z = 0, timer = false, time = 0}
Start_Teleport = GetTime()

-- Mail_Coord 是邮箱坐标
Mail_Coord = {mapid = 1421, x = -1656, y = -1344, z = 32}

-- Merchant_Coord 是商人坐标
-- Merchant_Name 是商人名字或者商人id (string or int)
Merchant_Coord = {mapid = 1446, x = -8479.38, y = -4627.53, z = -205.10}
Merchant_Name = "Yarley"

-- 计时器变量 不推荐更改
Profile_Timer = false
Profile_Time = 0

-- 第二循环 可以在功能里面更改
CD['Second Loop'] = CreateFrame('frame')

-- 副本进度 变量
Dungeon_Move = 1

-- id_name 是 名字 或者 id 或者 table包含多个目标 (int or string or table)
-- x, y, z 是 需要寻找的目标坐标 (int)
-- range 是范围 (int)
-- order 是否按距离排序 从小到大 (bool)
-- combat 是否寻找有战斗状态的目标 (bool)
CD['寻找对象'] = function(id_name, x, y, z, range, order, combat)
    local Return_Table = {}
    local total = awm.GetObjectCount() -- 附近Obj总数
	for i = 1,total do
		local ThisUnit = awm.GetObjectWithIndex(i)
		if awm.ObjectExists(ThisUnit) then
			local id = awm.ObjectId(ThisUnit) -- 物体ID
            local name = awm.UnitFullName(ThisUnit) -- 物体名字
			local x1,y1,z1 = awm.ObjectPosition(ThisUnit) -- 物体坐标
			local distance = awm.GetDistanceBetweenPositions(x,y,z,x1,y1,z1) -- 物体距离
			if id_name and type(id_name) == "number" and id == id_name and distance < range then
                if combat then
				    if awm.UnitAffectingCombat(ThisUnit) then
                        Return_Table[#Return_Table + 1] = {}
                        Return_Table[#Return_Table].distance = distance
                        Return_Table[#Return_Table].obj = ThisUnit
                    end
                else
                    Return_Table[#Return_Table + 1] = {}
                    Return_Table[#Return_Table].distance = distance
                    Return_Table[#Return_Table].obj = ThisUnit
                end
			elseif id_name and type(id_name) == "table" and distance < range and (not combat or awm.UnitAffectingCombat(ThisUnit)) then
			    for tab = 1,#id_name do
				    if (tonumber(id_name[tab]) and tonumber(id_name[tab]) == id) or id_name[tab] == name then
						Return_Table[#Return_Table + 1] = {}
                        Return_Table[#Return_Table].distance = distance
                        Return_Table[#Return_Table].obj = ThisUnit
					end
				end
            elseif id_name and type(id) == "string" and distance < range and id_name == name and (not combat or awm.UnitAffectingCombat(ThisUnit)) then
			    Return_Table[#Return_Table + 1] = {}
                Return_Table[#Return_Table].distance = distance
                Return_Table[#Return_Table].obj = ThisUnit

			elseif not id_name and distance < range and (not combat or awm.UnitAffectingCombat(ThisUnit)) then
				Return_Table[#Return_Table + 1] = {}
                Return_Table[#Return_Table].distance = distance
                Return_Table[#Return_Table].obj = ThisUnit
			end
		end
	end	

    if order then
        table.sort(Return_Table, function(a, b)
			if a.distance < b.distance then
				return true
			elseif a.distance == b.distance then
				return false
			end
			return false
		end)
    end

	return Return_Table
end


-- x,y,z 是目的地坐标
-- callback 是移动时执行功能 比如边走边奥爆
CD['移动'] = function(x, y, z, callback)
    CD['移动变量'] = {x = x, y = y, z = z, callback = callback}

    Thread.frame:SetScript('OnUpdate',function()
        local var = CD['移动变量']
        local x,y,z,callback = var.x,var.y,var.z,var.callback
        local px,py,pz = awm.ObjectPosition("player")
        local distance = awm.GetDistanceBetweenPositions(x,y,pz,px,py,pz)
        if distance > 1 then
            if callback ~= nil then
                callback()
            end

            if IsSwimming() then
                awm.Interval_Move(x,y,z)
            else
                awm.MoveTo(x,y,z)
            end
        else
            Thread.restore()
            return
        end
    end)

    Thread.stop()
end

CD["奥爆"] = function(level) -- level 是技能等级的意思
    if level == nil then
        if awm.Buff("player","节能施法").on then
            awm.CastSpellByName("魔爆术")
        else
            awm.CastSpellByName("魔爆术(等级 1)")
        end
    else
        awm.CastSpellByName("魔爆术(等级 "..level..")")
    end
end

CD["满级奥爆"] = function(level)
    awm.CastSpellByName("魔爆术")
end

CD["冰环"] = function(level) -- level 是技能等级的意思
    if level == nil then
        if awm.Buff("player","节能施法").on then
            awm.CastSpellByName("冰霜新星")
        else
            awm.CastSpellByName("冰霜新星(等级 1)")
        end
    else
        awm.CastSpellByName("冰霜新星(等级 "..level..")")
    end
end

-- x,y,z 是需要点击的地面坐标 (int or float)
-- spell_time 是释放技能的时间 (int or float)
-- level 是技能等级 可空 默认最高 (int)
CD['暴风雪'] = function(x,y,z,spell_time,level)
    CD['暴风雪变量'] = {x = x, y = y, z = z, spell_time = spell_time, level = level}

	Profile_Timer = false

    Thread.frame:SetScript('OnUpdate',function()
        local var = CD['暴风雪变量']
        local x,y,z,spell_time,level = var.x,var.y,var.z,var.spell_time,var.level
        if Profile_Timer then
            local time = GetTime() - Profile_Time
            if time >= spell_time then
                Profile_Timer = false
                awm.SpellStopCasting()

                Thread.restore()
                return
            end
        end

        if not CastingBarFrame:IsVisible() then
            if not awm.IsAoEPending() then
                if level then
                    awm.CastSpellByName("暴风雪(等级 "..level..")")
                else
                    awm.CastSpellByName("暴风雪")
                end
            else
                awm.ClickPosition(x,y,z)
            end
        else
            if not Profile_Timer then
                Profile_Timer = true
                Profile_Time = GetTime()
            end
        end
    end)

    Thread.stop()
end

CD['冰枪'] = function(id,x,y,z,range)
    CD['冰枪变量'] = {id = id, x = x, y = y, z = z, range = range}

	Profile_Timer = false

    Thread.frame:SetScript('OnUpdate',function()
        local var = CD['冰枪变量']
        local x,y,z,spell_time,level = var.x,var.y,var.z,var.spell_time,var.level
        if Profile_Timer then
            local time = GetTime() - Profile_Time
            if time >= spell_time then
                Profile_Timer = false
                awm.SpellStopCasting()

                Thread.restore()
                return
            end
        end

        if not CastingBarFrame:IsVisible() then
            if not awm.IsAoEPending() then
                if level then
                    awm.CastSpellByName("暴风雪(等级 "..level..")")
                else
                    awm.CastSpellByName("暴风雪")
                end
            else
                awm.ClickPosition(x,y,z)
            end
        else
            if not Profile_Timer then
                Profile_Timer = true
                Profile_Time = GetTime()
            end
        end
    end)

    Thread.stop()
end

-- time 是延时的时间 毫秒单位
CD['延时'] = function(time)
    CD['延时变量'] = time/1000

	Profile_Timer = false
    Thread.frame:SetScript('OnUpdate',function()
        if not Profile_Timer then
            Profile_Timer = true
            Profile_Time = GetTime()
        else
            if GetTime() - Profile_Time >= CD['延时变量'] then
                Thread.restore()
            end
        end
    end)

    Thread.stop()
end

-- x,y,z 目的地坐标
-- callback 寻路时的动作 比如开盾

CD['导航'] = function(x,y,z,callback)
    CD['导航变量'] = {x=x,y=y,z=z,callback=callback}

    Thread.frame:SetScript('OnUpdate',function()
        local var = CD['导航变量']
        local x,y,z,callback = var.x,var.y,var.z,var.callback
        
        local px,py,pz = awm.ObjectPosition("player")
        local distance = awm.GetDistanceBetweenPositions(x,y,pz,px,py,pz)
        if distance > 1 then
            if callback ~= nil then
                callback()
            end

            Run(x,y,z)
        else
            Thread.restore()
            return
        end
    end)

    Thread.stop()
end

movenorotation = function(x,y,z,callback)
    CD['导航变量'] = {x=x,y=y,z=z,callback=callback}

    Thread.frame:SetScript('OnUpdate',function()
        local var = CD['导航变量']
        local x,y,z,callback = var.x,var.y,var.z,var.callback
        
        local px,py,pz = awm.ObjectPosition("player")
        local distance = awm.GetDistanceBetweenPositions(x,y,pz,px,py,pz)
        if distance > 1 then
            if callback ~= nil then
                callback()
            end

            Run(x,y,z)
        else
            Thread.restore()
            return
        end
    end)

    Thread.stop()
end

Movewithmount = function(x,y,z,callback)
    CD['导航变量'] = {x=x,y=y,z=z,callback=callback}

    Thread.frame:SetScript('OnUpdate',function()
        local var = CD['导航变量']
        local x,y,z,callback = var.x,var.y,var.z,var.callback
        
        local px,py,pz = awm.ObjectPosition("player")
        local distance = awm.GetDistanceBetweenPositions(x,y,pz,px,py,pz)
        if distance > 1 and distance < 20 then

            if callback ~= nil then
                callback()
            end

            Run(x,y,z)
		elseif distance >= 20 then

			if IsCurrentAction(1) == false then
				awm.RunMacroText("/cast "..MountName)
			end	

			Run(x,y,z)
        else
            Thread.restore()
            return
        end
    end)

    Thread.stop()
end

CD['出本检查'] = function()
    Try_Stop()
    if DoesSpellExist("分解") or DoesSpellExist("Disenchant") then
        if Easy_Data["需要分解"] and not Check_ResolveItemExist() then
            Note_Set(Check_UI("分解物品 - ","Disenchanting items - ")..Disenchant_Black_Name)
            Auto_Resolve()
            return
        end
    else
        textout(Check_UI("未检测到有分解技能","No disenchant spell exist"))
    end
    if awm.SpellIsTargeting() then
        awm.SpellStopTargeting()
        return
    end
    Thread.frame:SetScript('OnUpdate',CD['出本'])
end
CD['出本'] = function()
    if GetItemCount(6948) == 0 and Easy_Data["卡死重置"] then
        Note_Set(Check_UI("卡死重置副本","Stuck reset dungeon"))
        CD['卡死']()
        return
    else
        if Dungeon_Time <= Easy_Data["副本重置时间"] then
            local waittime = Easy_Data["副本重置时间"] - Dungeon_Time
            waittime = math.floor(waittime)
            Note_Set(Check_UI("等待重置 : "..waittime.." 秒","Wait to reset "..waittime.." seconds"))
            return
        else
            Note_Set(Check_UI("执行出本","Go out Dungeon now"))

            local x1,y1,z1 = Dungeon_Out.x,Dungeon_Out.y,Dungeon_Out.z

            if not Interact_Step and Easy_Data["需要喊话"] and awm.GetDistanceBetweenPositions(x1,y1,z1,Px,Py,Pz) < 20 then
                Interact_Step = true
                C_Timer.After(0.5,function() Interact_Step = false end)
                awm.RunMacroText("/party "..Easy_Data["出本喊话"])
            end

            if Easy_Data["隐身出本"] and DoesSpellExist(rs["隐形术"]) and awm.GetDistanceBetweenPositions(x1,y1,z1,Px,Py,Pz) < 40 then
                local Count = awm.SpellCoolDown(rs["隐形术"])
                
                if awm.Buff("player",rs["隐形术"]).on then
                    if awm.Buff("player",rs["隐形术"]).remain > 10 then
                        Run(x1,y1,z1)
                    end
                    return
                elseif Count == 0 then
                    if Spell_Castable(rs["隐形术"]) then
                        awm.CastSpellByName(rs["隐形术"],"player")
                    end
                    return
                elseif Easy_Data["等待隐身出本CD"] then
                    return
                end
            end

            Run(x1,y1,z1)
        end
    end
end

CD['恢复血蓝'] = function()
	Thread.frame:SetScript('OnUpdate',function()
        if not awm.UnitAffectingCombat("player") then
            if not MakingDrinkOrEat() then
                  Note_Set(Check_UI("做面包和水...","Making food and drink..."))
                return true
             end   
            if not NeedHeal() then
                Note_Set(Check_UI("恢复血蓝...","Restore health and mana..."))
                  return true
             end
             if not awm.Buff("player",rs["奥术智慧"]).on then
                Note_Set(Check_UI(rs["奥术智慧"].." BUFF增加中...",rs["奥术智慧"].."Buff Adding..."))
                awm.CastSpellByName(rs["奥术智慧"],"player")
                  return truet
             end
            if not awm.Buff("player",rs["冰甲术"]).on then
                Note_Set(rs["冰甲术"]..Check_UI("BUFF增加中...","Buff Adding"))
                awm.CastSpellByName(rs["冰甲术"],"player")
                  return true
             end
            if not CheckUse() then
                Note_Set(Check_UI("制造宝石中...","Conjure GEM..."))
                return true
            end

            -- 脱离循环
            Thread.restore()
            return true
        else
            local Monster = Combat_Scan()
            local Far_Distance = 200
            local target = nil
            for i = 1,#Monster do
                local C_distance = awm.GetDistanceBetweenObjects("player",Monster[i])
                if C_distance < Far_Distance then
                    Far_Distance = C_distance
                    target = Monster[i]
                end
            end
            if target then
                local C_distance = awm.GetDistanceBetweenObjects("player",target)
                local x,y,z = awm.ObjectPosition(target)
                awm.TargetUnit(target)
                if C_distance <= 8 and Spell_Castable(rs["魔爆术"]) then
                    awm.CastSpellByName(rs["魔爆术"])
                    return true
                elseif C_distance >= 8 then
                    Run(x,y,z)
                end
                return true
            end
        end
    end)
	Thread.stop()
end

Rotation = function()
	Thread.frame:SetScript('OnUpdate',function()
        if not awm.UnitAffectingCombat("player") then
--            if not NeedHeal() then
--               Note_Set(Check_UI("恢复血蓝...","Restore health and mana..."))
--                return true
--          end
			 if not awm.Buff("player",HornofWinter).on and HornofWinter ~= nil then
                Note_Set(Check_UI(rs["奥术智慧"].." BUFF增加中...",rs["奥术智慧"].."Horn of Winter Adding..."))
                awm.CastSpellByID(HornofWinter,"player")
                  return true
             end
            -- 脱离循环
            Thread.restore()
            return true
        else
            local Monster = Combat_Scan()
            local Far_Distance = 200
            local target = nil
			local lowestHP = Monster[1]
			local highestHP = Monster[1]
            for i = 1,#Monster do
                local C_distance = awm.GetDistanceBetweenObjects("player",Monster[i])
				if awm.UnitHealth(Monster[i]) < awm.UnitHealth(lowestHP) then
					lowestHP = Monster[i]
				end
				if awm.UnitHealth(Monster[i]) > awm.UnitHealth(highestHP) then
					highestHP = Monster[i]
				end
                if C_distance < Far_Distance then
                    Far_Distance = C_distance
                    target = lowestHP
                end
            end
            if target then
				for i = 1,#Monster do 
				local isspellinterruptable = (select(8, awm.UnitCastingInfo(Monster[i])))
					if MindFreeze ~= nil and isspellinterruptable == false and awm.SpellCoolDown(MindFreeze) == 0 and awm.GetDistanceBetweenObjects("player",Monster[i]) < 6 and awm.UnitPower("player") > 20 then
						awm.CastSpellByID(MindFreeze,Monster[i])
					elseif Strangulate ~= nil and isspellinterruptable == false and awm.SpellCoolDown(Strangulate) == 0 and awm.GetDistanceBetweenObjects("player",Monster[i]) < 30 then
						awm.CastSpellByID(Strangulate,Monster[i])	
					end	
				end					
                local C_distance = awm.GetDistanceBetweenObjects("player",target)
                local x,y,z = awm.ObjectPosition(target)
                awm.TargetUnit(target)
				if ChainsofIce ~= nil and C_distance > 7 and C_distance < 21 and awm.SpellCoolDown(ChainsofIce) == 0 and awm.DeBuff("target","Chains of Ice").on == false then
					awm.CastSpellByID(ChainsofIce,target)
				elseif DeathGrip ~= nil and C_distance > 10 and C_distance < 30 and awm.SpellCoolDown(DeathGrip) == 0 and awm.DeBuff("target","Chains of Ice").on == false then
					awm.CastSpellByID(DeathGrip,target)
				end	
				if HornofWinter ~= nil and not awm.Buff("player",HornofWinter).on then
					awm.CastSpellByID(HornofWinter,"player")
					--return true
				end				
				if GetItemCount(22829) > 0 and awm.UnitHealth("player")/awm.UnitHealthMax("player")*100 < 20 and GetItemCooldown(HealingPotion) == 0 then
                    awm.UseItemByName(22829)
                    --return true
                end
				if VampiricBlood ~= nil and awm.UnitHealth("player")/awm.UnitHealthMax("player")*100 < 50 and awm.SpellCoolDown(VampiricBlood) == 0 then
                    awm.CastSpellByID(VampiricBlood,"player")
                    --return true
                end
				if RaiseDead ~= nil and awm.UnitHealth("player")/awm.UnitHealthMax("player")*100 < 30 and awm.SpellCoolDown(RaiseDead) == 0 then
                    awm.CastSpellByID(RaiseDead,"player")
                    --return true
                end
				if DeathPact ~= nil and awm.UnitHealth("player")/awm.UnitHealthMax("player")*100 < 30 and awm.SpellCoolDown(RaiseDead) ~= 0 then
                    awm.CastSpellByID(DeathPact,"player")
                    --return true
                end
				if RuneTap ~= nil and awm.SpellCoolDown(RuneTap) == 0 and awm.UnitHealth("player")/awm.UnitHealthMax("player")*100 < 80 then
                    awm.CastSpellByID(RuneTap,"player")
                    --return true
                end
				if IceboundFortitude ~= nil and awm.UnitHealth("player")/awm.UnitHealthMax("player")*100 < 50 and awm.SpellCoolDown(IceboundFortitude) == 0 then
                    awm.CastSpellByID(IceboundFortitude,"player")
                    --return true
                end
				if MarkofBlood ~= nil and C_distance < 30 and awm.UnitHealth("player")/awm.UnitHealthMax("player")*100 < 40 and awm.SpellCoolDown(MarkofBlood) == 0 then
					awm.TargetUnit(highestHP)
                    awm.CastSpellByID(MarkofBlood,highestHP)
					awm.TargetUnit(target)
                    --return true
				end
				if DeathCoil ~= nil and C_distance < 30 and awm.UnitPower("player") > 80 then
					awm.CastSpellByID(DeathCoil,target)
				end		
				if DeathStrike ~= nil and awm.UnitHealth("player")/awm.UnitHealthMax("player")*100 < 80 and C_distance <= 6 and awm.SpellCoolDown(DeathStrike) == 0 and awm.DeBuff("target","Blood Plague").on and awm.DeBuff("target","Blood Plague").source == "player" and awm.DeBuff("target","Frost Fever").on and awm.DeBuff("target","Frost Fever").source == "player" then
                    awm.CastSpellByID(DeathStrike,target)
                    --return true
                elseif C_distance > 6 then
                    Run(x,y,z)
                end
				if EmpowerRuneWeapon ~= nil and awm.UnitHealth("player")/awm.UnitHealthMax("player")*100 < 30 and awm.SpellCoolDown(DeathStrike) ~= 0 and awm.DeBuff("target","Blood Plague").on and awm.DeBuff("target","Blood Plague").source == "player" and awm.DeBuff("target","Frost Fever").on and awm.DeBuff("target","Frost Fever").source == "player" then
                    awm.CastSpellByID(EmpowerRuneWeapon,"player")
                    --return true
                end				
				if BloodFury ~= nil and #Monster > 1 and awm.SpellCoolDown(BloodFury) == 0 then
					awm.CastSpellByID(BloodFury,"player")
					--return true
			    end
				if BloodBoil ~= nil and #Monster > 4 and awm.SpellCoolDown(BloodBoil) == 0 and awm.DeBuff("target","Blood Plague").on and awm.DeBuff("target","Blood Plague").source == "player" and awm.DeBuff("target","Frost Fever").on and awm.DeBuff("target","Frost Fever").source == "player" then
					awm.CastSpellByID(BloodBoil,"player")
					--return true
			    end
                if not IsCurrentAction(2) then
                    awm.AttackTarget(target)
                    --return true
                end
				if DancingRuneWeapon ~= nil and #Monster > 2 and awm.SpellCoolDown(DancingRuneWeapon) == 0 and awm.UnitPower("player") > 60 then
					awm.CastSpellByID(DancingRuneWeapon,target)
			    end
				if BloodTap ~= nil and awm.SpellCoolDown(BloodTap) == 0 then
                    awm.CastSpellByID(BloodTap,"player")
                    --return true
                end
				if RuneStrike ~= nil and awm.UnitPower("player") > 40 and not IsCurrentAction(5) then
                    awm.CastSpellByID(RuneStrike,target)
                    --return true
                end								
                if PlagueStrike ~= nil and C_distance <= 6 and awm.SpellCoolDown(PlagueStrike) == 0 and awm.DeBuff("target","Blood Plague").on == false and awm.DeBuff("target","Blood Plague").source ~= "player" then
                    awm.CastSpellByID(PlagueStrike,target)
                    --return true
                elseif C_distance > 6 then
                    Run(x,y,z)
                end
                if IcyTouch ~= nil and C_distance <= 20 and awm.SpellCoolDown(IcyTouch) == 0 and awm.DeBuff("target","Frost Fever").on == false and awm.DeBuff("target","Frost Fever").source ~= "player" then
                    awm.CastSpellByID(IcyTouch,target)
                    --return true
                elseif C_distance > 6 then
                    Run(x,y,z)
                end
				for i = 1, #Monster do
					local targetswithoutdebuff = 0
					if awm.GetDistanceBetweenObjects("player",Monster[i]) < 10 and (awm.DeBuff(Monster[i],"Blood Plague").on == false or awm.DeBuff(Monster[i],"Frost Fever").on == false or awm.DeBuff(Monster[i],"Blood Plague").source ~= "player" or awm.DeBuff(Monster[i],"Frost Fever").source ~= "player") then
						targetswithoutdebuff = targetswithoutdebuff + 1
					end		
					if Pestilence ~= nil and C_distance <= 6 and awm.SpellCoolDown(Pestilence) == 0 and awm.DeBuff("target","Blood Plague").on and awm.DeBuff("target","Blood Plague").source == "player" and awm.DeBuff("target","Frost Fever").on and awm.DeBuff("target","Frost Fever").source == "player" and targetswithoutdebuff > 0 then
                    	awm.CastSpellByID(Pestilence,target)
                    	--return true
                	elseif C_distance > 6 then
                    	Run(x,y,z)
                	end
				end	
			    if Pestilence ~= nil and C_distance <= 6 and awm.SpellCoolDown(Pestilence) == 0 and awm.DeBuff("target","Blood Plague").remain < 5 and awm.DeBuff("target","Blood Plague").remain > 0 and awm.DeBuff("target","Blood Plague").source == "player" or awm.DeBuff("target","Frost Fever").remain < 5 and awm.DeBuff("target","Frost Fever").remain > 0 and awm.DeBuff("target","Frost Fever").source == "player" then
					awm.CastSpellByID(Pestilence,target)
					--return true
				elseif C_distance > 6 then
					Run(x,y,z)
				end				
                if HeartStrike ~= nil and C_distance <= 6 and awm.SpellCoolDown(HeartStrike) == 0 and awm.DeBuff("target","Blood Plague").on and awm.DeBuff("target","Blood Plague").source == "player" and awm.DeBuff("target","Frost Fever").on and awm.DeBuff("target","Frost Fever").source == "player" then
                    awm.CastSpellByID(HeartStrike,target)
                    --return true
				elseif DeathStrike ~= nil and C_distance <= 6 and awm.SpellCoolDown(HeartStrike) ~= 0 and awm.SpellCoolDown(DeathStrike) == 0 then
					awm.CastSpellByID(DeathStrike,target)
                elseif C_distance > 6 then
                    Run(x,y,z)
                end														
                return true
            end
        end
    end)
	Thread.stop()
end


PullMobs = function()
	local attackabletable = {}
	local total = awm.GetObjectCount()
	if UnitAffectingCombat("player") == false then
		for i = 1,total do
			local ThisUnit = awm.GetObjectWithIndex(i)
			local nearesttarget = awm.GetObjectWithIndex(1)
			if awm.ObjectExists(ThisUnit) and awm.ObjectType(ThisUnit) == 5 and UnitCanAttack("player",ThisUnit) and awm.GetDistanceBetweenObjects("player",ThisUnit) < 30 then
				attackabletable[#attackabletable + 1] = ThisUnit
			end
			if awm.GetDistanceBetweenObjects("player",awm.GetObjectWithIndex[i]) < awm.GetDistanceBetweenObjects("player",nearesttarget) then
				nearesttarget = awm.GetObjectWithIndex[i]
			end
			awm.TargetUnit(nearesttarget)
			if awm.GetDistanceBetweenObjects("player",nearesttarget) <= 20 and awm.SpellCoolDown(ChainsofIce) == 0 then
				awm.CastSpellByID(ChainsofIce,nearesttarget)
				--return true
			end	
		end
	else
		Rotation()
	end		
end	

--OutofCombatScan = function()
--	local attackabletable = {}
--	local total = awm.GetObjectCount()
--	if UnitAffectingCombat("player") == false then
--		for i = 1,total do
--			local ThisUnit = awm.GetObjectWithIndex(i)
--			if awm.ObjectExists(ThisUnit) and awm.ObjectType(ThisUnit) == 5 and UnitCanAttack("player",ThisUnit) and awm.GetDistanceBetweenObjects("player",ThisUnit) < 30 then
--				attackabletable[#attackabletable + 1] = ThisUnit
--			end
--		end
--	end
--	return attackabletable
--end			


CD['拾取尸体'] = function()
	Thread.frame:SetScript('OnUpdate',function()
        local body_list = Find_Body()
        Note_Set(Check_UI("拾取... 附近尸体 = ","Loot, body count = ")..#body_list)

        if UnitAffectingCombat("player") then
			Rotation()
        end

        if CalculateTotalNumberOfFreeBagSlots() == 0 then
            Thread.frame:SetScript('OnUpdate',CD['出本检查'])
            return true
        end
        if #body_list > 0 then
            if not Body_Choose then
                Body_Target = body_list[1].Unit
                Body_Choose = true
                Body_Choose_Time = GetTime()
            else
                local time = GetTime() - Body_Choose_Time
                if time > 7 then
                    Body_Choose = false
                    Body_Target = nil
                    return true
                end
            end
            if Body_Target == nil or not awm.ObjectExists(Body_Target) then
                Body_Choose = false
                Body_Target = nil
                return true
            end
            local Found_it = false -- 看选择的尸体还在不在列表
            for i = 1,#body_list do
                if body_list[i].Unit == Body_Target then
                    Found_it = true
                    break
                end
            end
            if not Found_it then
                Body_Choose = false
                Body_Target = nil
                return true
            end
            local distance1 = awm.GetDistanceBetweenObjects("player",Body_Target)
            local x,y,z = awm.ObjectPosition(Body_Target)
            if distance1 >= 4.9 then
                if Mount_useble > GetTime() then
                    Mount_useble = GetTime() + 30
                end
                Run(x,y,z)
                Interact_Step = false
                Open_Slot = false
            else
                if not Open_Slot then
                    Open_Slot = true
                    Open_Slot_Time = GetTime()
                    if LootFrame:IsVisible() then
                        if GetNumLootItems() == 0 then
                            Body_Choose = false
                            Body_Target = nil
                        end
                        CloseLoot()
                        LootFrame_Close()
                        return true
                    end
                    awm.InteractUnit(Body_Target)
                else
                    local time = GetTime() - Open_Slot_Time
                    local Interval = tonumber(Easy_Data["拾取间隔"])
                    if Interval == nil then
                        Interval = 0.5
                    end
                    if time > Interval then
                        Open_Slot = false
                    end
                    if LootFrame:IsVisible() then
                        if GetNumLootItems() == 0 then
                            Body_Choose = false
                            Body_Target = nil
                            CloseLoot()
                            LootFrame_Close()
                            return true
                        end
                        for i = 1,GetNumLootItems() do
                            LootSlot(i)
                            ConfirmLootSlot(i)
                        end
                    end
                end
            end
            return true
        else
            Thread.restore()
            return true
        end
    end)
	Thread.stop()
end

Moverotation = function(x,y,z,callback)
    CD['导航变量'] = {x=x,y=y,z=z,callback=callback}

    Thread.frame:SetScript('OnUpdate',function()
        local var = CD['导航变量']
        local x,y,z,callback = var.x,var.y,var.z,var.callback
        
        local px,py,pz = awm.ObjectPosition("player")
        local distance = awm.GetDistanceBetweenPositions(x,y,pz,px,py,pz)
		if awm.UnitAffectingCombat("player") then	
			Rotation()
		end	
        if distance > 1 and distance < 20 then

            if callback ~= nil then
                callback()
            end

            Run(x,y,z)
		elseif distance >= 20 then

			Run(x,y,z)
        else
            Thread.restore()
            return
        end
    end)

    Thread.stop()
end

Movewithmountwithcombat = function(x,y,z,callback)
    CD['导航变量'] = {x=x,y=y,z=z,callback=callback}

    Thread.frame:SetScript('OnUpdate',function()
        local var = CD['导航变量']
        local x,y,z,callback = var.x,var.y,var.z,var.callback
        
        local px,py,pz = awm.ObjectPosition("player")
        local distance = awm.GetDistanceBetweenPositions(x,y,pz,px,py,pz)
		if awm.UnitAffectingCombat("player") then

            if IsMounted() then
                Dismount()
			end
		
			Rotation()
		end	
        if distance > 1 and distance < 20 then

            if callback ~= nil then
                callback()
            end

            Run(x,y,z)
		elseif distance >= 20 then

			if IsCurrentAction(1) == false then
				awm.RunMacroText("/cast "..MountName)
			end	

			Run(x,y,z)
        else
            Thread.restore()
            return
        end
    end)

    Thread.stop()
end

CD['全部歼灭'] = function()
	Thread.frame:SetScript('OnUpdate',function()
        if #Combat_Scan() > 0 or UnitAffectingCombat("player") then
            local Monster = Combat_Scan()
            for i = 1,#Monster do
                local C_distance = awm.GetDistanceBetweenObjects("player",Monster[i])

                if Frost.used then
                    awm.MoveForwardStart()
                    return true
                elseif not Frost.used then
                    if GetUnitSpeed('player') > 0 then
                        Try_Stop()
                        return true
                    end
                end

                if awm.UnitHealth(Monster[i]) <= 2000 and C_distance <= 10 and DoesSpellExist(rs["冰霜新星"]) and awm.SpellCoolDown(rs["冰霜新星"]) < 1.5 then
                    if Spell_Castable(rs["冰霜新星"]) then
                        awm.CastSpellByName(rs["冰霜新星"])
                        Frost.used = true
                        Frost.x,Frost.y,Frost.z = awm.ObjectPosition("player")
                        C_Timer.After(0.7, function() Frost.used = false textout(Check_UI("停止移动","Stop Moving")) end)
                    end
                    return true
                end
                if C_distance <= 8 and Spell_Castable(rs["魔爆术"]) then
                    awm.CastSpellByName(rs["魔爆术"])
                    return true
                end
            end
        else
            Thread.restore()
        end
    end)
	Thread.stop()
end


CD['奥爆开盾'] = function()
	if not awm.Buff("player","寒冰护体").on and awm.SpellCoolDown("寒冰护体") <= 2 then
		if Spell_Castable("寒冰护体") then
			awm.CastSpellByName("寒冰护体","player")
		end
		return
	end
	if not awm.Buff("player","法力护盾").on and awm.SpellCoolDown("法力护盾") <= 2 then
		if Spell_Castable("法力护盾") then
			awm.CastSpellByName("法力护盾","player")
		end
		return
	end
	CD["奥爆"]()
end
CD['第一波'] = function()
    CD['导航'](-222.66,2110.09,76.88)
    CD['移动'](-222.66,2110.09,76.88,CD['奥爆开盾'])
    CD['移动'](-212.14,2105.46,76.89,CD['奥爆开盾'])
    CD['移动'](-203.84,2098.31,76.89,CD['奥爆开盾'])
    
    -- 开始全歼
    CD['全部歼灭']()

    textout("怪物杀完了 回血回蓝")
    CD['恢复血蓝']()

    textout("拾取一波")
    CD['拾取尸体']()
end
CD['第二波'] = function()
	CD['恢复血蓝']()
    CD['导航'](-201.3335, 2101.5396, Pz)
    CD['移动'](-201.3335, 2101.5396, Pz, CD['奥爆开盾'])
    CD['移动'](-200.5922, 2106.1672, Pz, CD['奥爆开盾'])
    CD['移动'](-208.4421, 2109.5186, Pz, CD['奥爆开盾'])
	CD['移动'](-202.1553, 2116.0249, Pz, CD['奥爆开盾'])
	CD['移动'](-193.9147, 2132.8247, Pz, CD['奥爆开盾'])
	CD['移动'](-189.15, 2135.29, Pz, CD['奥爆开盾'])
	CD['移动'](-189.64, 2140.85, Pz, CD['奥爆开盾'])
	CD['移动'](-199.9192, 2144.7324, Pz, CD['奥爆开盾'])
	CD['移动'](-205.1063, 2147.5522, Pz, CD['奥爆开盾'])
	CD['移动'](-208.6784, 2140.0508, Pz, CD['奥爆开盾'])

	CD['移动'](-234.7679, 2150.5559, Pz, CD['奥爆开盾'])
	CD['移动'](-240.5715, 2138.5332, Pz, CD['奥爆开盾'])
	CD['移动'](-247.0885, 2120.2388, Pz, CD['奥爆开盾'])
	CD['移动'](-250.2604, 2116.2935, Pz, CD['奥爆开盾'])
	CD['移动'](-243.41, 2117.81, Pz, CD["满级奥爆"])
	CD['移动'](-241.10, 2141.19, Pz, CD["满级奥爆"])
	CD['移动'](-250.23, 2144.26, Pz, CD["满级奥爆"])
	CD['移动'](-252.39, 2136.07, Pz, CD['奥爆开盾'])
	CD['移动'](-254.81, 2125.72, Pz, CD['奥爆开盾'])
    
    -- 开始全歼
    CD['全部歼灭']()

    textout("怪物杀完了 回血回蓝")
    CD['恢复血蓝']()

    textout("拾取一波")
    CD['拾取尸体']()
end
CD['开锁救NPC'] = function()
	CD['恢复血蓝']()
    CD['导航'](-253.78,2126.52,81.17)
    
	Profile_Timer = false
	Thread.frame:SetScript('OnUpdate',function()
		local obj_id = 18901
		if Faction == "Horde" then
			obj_id = 18900
		end

		local target = CD['寻找对象'](obj_id,Px,Py,Pz,200,true,false)
		if target[1].obj ~= nil then
			local tarx,tary,tarz = awm.ObjectPosition(target[1].obj)
			local Distance = awm.GetDistanceBetweenObjects("player",target[1].obj)
			if Distance >= 4 then
				Run(tarx,tary,tarz)
			else
				if not Profile_Timer then
					Profile_Timer = true
					Profile_Time = GetTime()
				else
					local time = GetTime() - Profile_Time
					if time >= 10 then
						Profile_Timer = false
						Thread.restore()
						return
					end
				end

				if GetUnitSpeed("player") > 0 then
					Try_Stop()
					return
				end

				if not Interact_Step then
					Interact_Step = true
					C_Timer.After(0.5, function() Interact_Step = false end)
					awm.InteractUnit(target[1].obj)
				end
			end
		else
			Thread.restore()
			textout("无法找到锁")
		end
    end)
	Thread.stop()

	CD['导航'](-255.21,2124.99,81.18)

	Profile_Timer = false
	Thread.frame:SetScript('OnUpdate',function()
		local target = nil

		local tar_id = 0
		local posx,posy,posz = 0,0,0

		if Faction == "Horde" then
		    tar_id = 3849
			posx,posy,posz = -243.71, 2113.71, 81.17
		else
		    tar_id = 3850
			posx,posy,posz = -240.83, 2122.54, 81.17
		end

		local total = awm.GetObjectCount()
		local Far_Distance = 200
		for i = 1,total do
			local ThisUnit = awm.GetObjectWithIndex(i)
			local guid = awm.ObjectId(ThisUnit)
			local distance = awm.GetDistanceBetweenObjects("player",ThisUnit)
			if guid == tar_id and distance < Far_Distance then
				Far_Distance = distance
				target = ThisUnit
			end
		end
		if target then
		    local tarx,tary,tarz = awm.ObjectPosition(target)

			local Distance = awm.GetDistanceBetweenPositions(posx,posy,posz,Px,Py,Pz)
			if Distance >= 3 then
				Run(posx,posy,posz)
			else
				if not Profile_Timer then
					Profile_Timer = true
					Profile_Time = GetTime()
				else
					local time = GetTime() - Profile_Time
					if time >= 30 then
						Profile_Timer = false
						Thread.restore()
						return
					end
				end
				if not GossipFrame:IsVisible() then
					if not Interact_Step then
						Interact_Step = true
						C_Timer.After(0.5, function() Interact_Step = false end)
						awm.InteractUnit(target)
					end
				else
					SelectGossipOption(1)
				end
			end
		else
		    Thread.restore()
			Profile_Timer = false
			return
		end
    end)
	Thread.stop()
end
CD['第三波'] = function()
	CD['恢复血蓝']()
    CD['导航'](-242.40,2155.54,90.62)
    CD['移动'](-242.40,2155.54,90.62, CD['奥爆开盾'])
    CD['移动'](-239.37,2162.91,90.11, CD['奥爆开盾'])
    CD['移动'](-235.34,2175.00,83.88, CD['奥爆开盾'])
	CD['移动'](-224.24,2169.85,79.77, CD['奥爆开盾'])
	CD['移动'](-220.51,2156.20,81.01, CD['奥爆开盾'])
	CD['移动'](-203.20,2164.17,79.76, CD['奥爆开盾'])
	CD['移动'](-214.33,2184.08,79.77, CD['奥爆开盾'])
	CD['移动'](-222.04,2192.75,79.77, CD['奥爆开盾'])
	CD['移动'](-215.97,2210.54,79.77, CD['奥爆开盾'])
	CD['移动'](-207.54,2218.14,79.76, CD["满级奥爆"])
	CD['移动'](-199.87,2215.38,79.76, CD["满级奥爆"])
	CD['移动'](-191.74,2211.61,79.76, CD["满级奥爆"])
	CD['移动'](-179.19,2217.01,79.74, CD["满级奥爆"])
  
    -- 开始全歼
    Thread.frame:SetScript('OnUpdate',function()
        Monster = Combat_Scan()

		if not UnitAffectingCombat("player") then
			Thread.restore()
			awm.SpellStopCasting()
			Profile_Timer = false
			return true
		end

		local Far_Distance = 100
		local target = nil

		for i = 1,#Monster do
			local C_distance = awm.GetDistanceBetweenObjects("player",Monster[i])

			if awm.UnitHealth(Monster[i]) <= 2000 and #Monster > 2 and C_distance <= 10 and DoesSpellExist(rs["冰霜新星"]) and awm.SpellCoolDown(rs["冰霜新星"]) < 1.5 and not awm.Buff(Monster[i],Check_Client("反魔法盾","Anti-Magic Shield")).on then
				if Spell_Castable(rs["冰霜新星"]) then
					awm.CastSpellByName(rs["冰霜新星"])
					Frost.used = true
					Frost.x,Frost.y,Frost.z = awm.ObjectPosition("player")
					C_Timer.After(0.7, function() 
						Frost.used = false 
						textout(Check_UI("停止移动","Stop Moving")) 
						Try_Stop() 
					end)
				end
				return true
			end

			if C_distance < Far_Distance and not awm.Buff(Monster[i],Check_Client("反魔法盾","Anti-Magic Shield")).on then
				target = Monster[i]
				Far_Distance = C_distance
			end
		end

		if target then
			local x,y,z = awm.ObjectPosition(target)
			local C_distance = awm.GetDistanceBetweenObjects("player",target)
			
			local id = awm.ObjectId(target)

			if Frost.used then
				awm.MoveForwardStart()
				return true
			end

			if id ~= nil and id == 4444 and #Monster == 1 then
				if C_distance >= 28 then
					Run(x,y,z)
				end
				if not Profile_Timer then
					Profile_Timer = true
					Profile_Time = GetTime()
					return true
				else
					if GetTime() - Profile_Time > 5 then
						Profile_Timer = false
					else
						return true
					end
				end
			end

			if C_distance <= 8 and Spell_Castable(rs["魔爆术"]) then
				awm.CastSpellByName(rs["魔爆术"])
				return true
			end

			if C_distance >= 8 then
				Run(x,y,z)
			end
		end
    end)
	Thread.stop()

	-- 等待脱战
    Thread.frame:SetScript('OnUpdate',function()
        if not Profile_Timer then
			Profile_Timer = true
			Profile_Time = GetTime()
			return true
		else
			if GetTime() - Profile_Time > 5 then
				Thread.restore()
				awm.SpellStopCasting()
				Profile_Timer = false
				return true
			end
		end
    end)

	Thread.stop()

    CD['恢复血蓝']()

    CD['拾取尸体']()
end
CD['第四波'] = function()
	CD['恢复血蓝']()
    CD['导航'](-166.61,2219.44,81.17)
    CD['移动'](-166.61,2219.44,81.17, CD['奥爆开盾'])
    CD['移动'](-156.43,2231.70,83.95, CD['奥爆开盾'])
    CD['移动'](-171.09,2253.10,86.43, CD['奥爆开盾'])
	CD['移动'](-179.79,2258.87,88.32, CD['奥爆开盾'])
	CD['移动'](-193.95,2264.17,90.64, CD['奥爆开盾'])
	CD['移动'](-192.35,2277.16,93.13, CD['奥爆开盾'])
	CD['移动'](-188.42,2289.13,95.90, CD['奥爆开盾'])
	CD['移动'](-216.42,2300.28,95.87, CD['奥爆开盾'])
	CD['移动'](-239.90,2309.16,95.87, CD['奥爆开盾'])
	CD['移动'](-254.42,2314.65,95.87, CD['奥爆开盾'])
	CD['移动'](-270.26,2320.64,95.87, CD['奥爆开盾'])
	CD['移动'](-287.05,2326.99,95.87, CD['奥爆开盾'])
	CD['移动'](-291.91,2303.53,90.61, CD['奥爆开盾'])

	CD['移动'](-287.34,2301.96,90.61, CD['奥爆开盾'])
    CD['移动'](-284.41,2291.48,83.93, CD['奥爆开盾'])
    CD['移动'](-278.22,2289.66,81.36, CD['奥爆开盾'])
	CD['移动'](-257.03,2284.72,75.00, CD['奥爆开盾'])
	CD['移动'](-244.35,2278.35,75.00, CD['奥爆开盾'])
	CD['移动'](-231.82,2272.44,75.00, CD['奥爆开盾'])
	CD['移动'](-216.17,2265.45,75.93, CD['奥爆开盾'])
	CD['移动'](-201.64,2258.96,76.20, CD['奥爆开盾'])
	CD['移动'](-185.07,2245.86,76.20, CD['奥爆开盾'])
	CD['移动'](-179.10,2238.38,76.24, CD['奥爆开盾'])
	CD['移动'](-177.11,2222.74,79.76, CD['奥爆开盾'])
	CD['移动'](-179.55,2220.37,79.76, CD["满级奥爆"])
	CD['移动'](-191.47,2218.56,79.76)

	CD['延时'](300)
	CD['暴风雪'](-179.43, 2220.33, 79.75, 4)

	CD['延时'](300)
	FacePosition(-217.30,2207.69,79.76)
	CD['延时'](300)
	awm.CastSpellByName("闪现术")
	CD['延时'](100)
	CD['移动'](-217.30,2207.69,79.76)

	CD['暴风雪'](-194.01,2215.71,79.76,6.5)
	CD['移动'](-213.69,2204.35,79.76, CD["冰环"])
	CD['移动'](-215.51,2220.79,79.76, CD["冰环"])

    -- 开始全歼
    Thread.frame:SetScript('OnUpdate',function()
        Monster = Combat_Scan()

		if not UnitAffectingCombat("player") then
			Thread.restore()
			awm.SpellStopCasting()
			Profile_Timer = false
			return true
		end

		local Far_Distance = 100
		local target = nil

		for i = 1,#Monster do
			local C_distance = awm.GetDistanceBetweenObjects("player",Monster[i])

			if awm.UnitHealth(Monster[i]) <= 2000 and #Monster > 2 and C_distance <= 10 and DoesSpellExist(rs["冰霜新星"]) and awm.SpellCoolDown(rs["冰霜新星"]) < 1.5 and not awm.Buff(Monster[i],Check_Client("反魔法盾","Anti-Magic Shield")).on then
				if Spell_Castable(rs["冰霜新星"]) then
					awm.CastSpellByName(rs["冰霜新星"])
					Frost.used = true
					Frost.x,Frost.y,Frost.z = awm.ObjectPosition("player")
					C_Timer.After(0.7, function() 
						Frost.used = false 
						textout(Check_UI("停止移动","Stop Moving")) 
						Try_Stop() 
					end)
				end
				return true
			end

			if C_distance < Far_Distance and not awm.Buff(Monster[i],Check_Client("反魔法盾","Anti-Magic Shield")).on then
				target = Monster[i]
				Far_Distance = C_distance
			end
		end

		if target then
			local x,y,z = awm.ObjectPosition(target)
			local C_distance = awm.GetDistanceBetweenObjects("player",target)
			
			local id = awm.ObjectId(target)

			if Frost.used then
				awm.MoveForwardStart()
				return true
			end

			if id ~= nil and id == 4444 and #Monster == 1 then
				if C_distance >= 28 then
					Run(x,y,z)
				end
				if not Profile_Timer then
					Profile_Timer = true
					Profile_Time = GetTime()
					return true
				else
					if GetTime() - Profile_Time > 5 then
						Profile_Timer = false
					else
						return true
					end
				end
			end

			if C_distance <= 8 and Spell_Castable(rs["魔爆术"]) then
				awm.CastSpellByName(rs["魔爆术"])
				return true
			end

			if C_distance >= 8 then
				Run(x,y,z)
			end
		end
    end)
	Thread.stop()

    CD['恢复血蓝']()

    CD['拾取尸体']()
end

-- 这里写你在副本外 或者 野外的时候应该干什么 (逐行执行, 结束重头开始)
-- Here is your open world function, it will be executed line by line
T_Func["野外线程"] = function()
    textout("检查卖物")
    -- 检查是否需要 卖物
    Thread.frame:SetScript('OnUpdate',function()
        if (Easy_Data["需要卖物"] or Easy_Data["需要修理"]) then

            if not Check_BagFree() or Sell.Step ~= 1 then
                -- 自定义商人
                if Easy_Data["自定义商人"] then
                    Merchant_Name = Easy_Data["自定义商人名字"]
                    local Coord = string.split(Easy_Data["自定义商人坐标"],",")
                    Merchant_Coord.mapid, Merchant_Coord.x,Merchant_Coord.y,Merchant_Coord.z = Coord[1],Coord[2],Coord[3],Coord[4]
                    Merchant_Coord.mapid, Merchant_Coord.x,Merchant_Coord.y,Merchant_Coord.z = tonumber(Merchant_Coord.mapid),tonumber(Merchant_Coord.x),tonumber(Merchant_Coord.y),tonumber(Merchant_Coord.z)
                else
                    if Faction == "Horde" then -- 部落联盟分开设置 商人位置 坐标
                        Merchant_Coord.mapid, Merchant_Coord.x,Merchant_Coord.y,Merchant_Coord.z = 1446, -8479.38, -4627.53, -205.10
                        Merchant_Name = Check_Client("亚伯·温特斯","Yarley")
                    else
                        Merchant_Coord.mapid, Merchant_Coord.x,Merchant_Coord.y,Merchant_Coord.z = 1446, -8479.38, -4627.53, -205.10
                        Merchant_Name = Check_Client("加诺斯·铁心","Yarley")
                    end
                end

                -- 副本内处理
                Note_Head = Check_UI("卖物","Vendor")

                Event_Reset()

                -- 野外Buff 可以自己自定义一个新的功能
                if not Out_Dungeon_buff() then
                    Note_Set(Check_UI("上BUFF...","Buff Adding...."))
                    return
                end

                -- 战斗开盾
                CheckProtection()

                -- 炉石
                local starttime, durationtime, enable = GetItemCooldown(6948)
                if GetItemCount(6948) > 0 and durationtime < 10 then
					Sell_JunkRun(Merchant_Coord.x,Merchant_Coord.y,Merchant_Coord.z)

--                    Note_Set(Check_UI("炉石回城","Using Hearthstone"))

--                    if IsMounted() then
--                        Dismount()
--                   end

--                    if not CastingBarFrame:IsVisible() then
--                        awm.UseItemByName(6948)
--                    end
--                    return
                else
                    -- 封装的卖物
                    Sell_JunkRun(Merchant_Coord.x,Merchant_Coord.y,Merchant_Coord.z)
                end
                return
            else
                Thread.restore()
            end
        else
            Thread.restore()
        end
    end)
    Thread.stop()

    textout("检查邮寄")
    -- 检查是否需要 邮寄
    Thread.frame:SetScript('OnUpdate',function()
        if Easy_Data["需要邮寄"] and not awm.UnitAffectingCombat("player") then
            if #Easy_Data.ResetTimes / Easy_Data["触发邮寄"] == math.floor(#Easy_Data.ResetTimes / Easy_Data["触发邮寄"]) and #Easy_Data.ResetTimes ~= 0 and #Easy_Data.ResetTimes ~= 1 and not Has_Mail then
    
                if Easy_Data["自定义邮箱"] then
                    local Coord = string.split(Easy_Data["自定义邮箱坐标"],",")
                    Mail_Coord.mapid, Mail_Coord.x,Mail_Coord.y,Mail_Coord.z = Coord[1],Coord[2],Coord[3],Coord[4]
                    Mail_Coord.mapid, Mail_Coord.x,Mail_Coord.y,Mail_Coord.z = tonumber(Mail_Coord.mapid),tonumber(Mail_Coord.x),tonumber(Mail_Coord.y),tonumber(Mail_Coord.z)
                else
                    if Faction == "Horde" then -- 部落联盟分开设置 
                        Mail_Coord.mapid,Mail_Coord.x,Mail_Coord.y,Mail_Coord.z = 1434, -12389.50,145.42,2.70
                    else
                        Mail_Coord.mapid,Mail_Coord.x,Mail_Coord.y,Mail_Coord.z = 1434, -10547.44,-1157.22,27.89
                    end
                end
                
                Note_Head = Check_UI("邮寄","Mail")
                
                Event_Reset()

                if not Out_Dungeon_buff() then
                    Note_Set(Check_UI("上BUFF...","Buff Adding...."))
                    return
                end

                CheckProtection()

                local starttime, durationtime, enable = GetItemCooldown(6948)
                if GetItemCount(6948) > 0 and durationtime < 10 then
                    Note_Set(Check_UI("炉石邮寄","Using Herath Stone Back To Mail"))
                    if IsMounted() then
                        Dismount()
                    end
                    if not CastingBarFrame:IsVisible() then
                        awm.UseItemByName(6948)
                    end
                    return
                else
                    Mail(Mail_Coord.x,Mail_Coord.y,Mail_Coord.z)
                    return
                end
                return
            elseif #Easy_Data.ResetTimes / Easy_Data["触发邮寄"] ~= math.floor(#Easy_Data.ResetTimes / Easy_Data["触发邮寄"]) then
                Has_Mail = false
                Thread.restore()
            else
                Thread.restore()
            end
        else
            Thread.restore()
        end
    end)
    Thread.stop()

    -- 进本流程
    Note_Head = Check_UI("正常进本","Run Into Dungeon")

    textout("跑步进本")
    Thread.frame:SetScript('OnUpdate',function()
        if tonumber(Easy_Data["等待时间"]) == nil then
		    Easy_Data["等待时间"] = 5
		end

		if GetTime() - Out_Dungeon_Time < Easy_Data["等待时间"] then
		    return
		end

		CheckProtection()

	    Event_Reset()

	    if not Out_Dungeon_buff() then
		    Note_Set(Check_UI("上BUFF...","Buff Adding...."))
			return
		end

	    if Reset_Instance then
		    ResetInstances()
			textout(Check_UI("副本重置成功","Dungeon Reset Success"))
			Vars_Reset()
			Reset_Instance = false
			Run_Timer = false
			Easy_Data.ResetTimes[#Easy_Data.ResetTimes + 1] = GetTime()
			return
		end

		local mapid,x,y,z = Dungeon_In.mapid, Dungeon_In.x,Dungeon_In.y,Dungeon_In.z

		local Fx,Fy,Fz = tonumber(Dungeon_Flush_Point.x),tonumber(Dungeon_Flush_Point.y),tonumber(Dungeon_Flush_Point.z)

		local distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,z)

		if distance == nil then
		    return
		end

		if Dungeon_Flush then
			local distance1 = awm.GetDistanceBetweenPositions(Px,Py,Pz,Fx,Fy,Fz)
			Note_Set(Check_UI("爆本了, 前往坐标距离剩余 ","Dungeon Run Over 5 Reset Per Hour, Goto Wait Point, Distance - ")..math.floor(distance)..Check_UI("码...","Yard..."))
			if distance1 > 2 then
				Run(Fx,Fy,Fz)
			else
				if not Flush_Time then
					Flush_Time = true
					C_Timer.After(30,function() Dungeon_Flush = false Flush_Time = false end)
				end
			end
			return
		end

		if Easy_Data["爆本等待时间"] == nil then
			Easy_Data["爆本等待时间"] = 300
			return
		end

		if Real_Flush then
			local distance1 = awm.GetDistanceBetweenPositions(Px,Py,Pz,Fx,Fy,Fz)
			if distance1 > 2 then
				Note_Set(Check_UI("爆本, 前往坐标距离剩余 ","Dungeon Run Over 5 Reset Per Hour, Goto Wait Point Distance - ")..math.floor(distance)..Check_UI("码...","Yard..."))
				Run(Fx,Fy,Fz)
				return
			end
			local time = GetTime() - Real_Flush_time
			local waittime = math.floor(Easy_Data["爆本等待时间"] - time)
			Note_Set(Check_UI("爆本等待剩余时间 - "..waittime.." 秒","Need to wait - "..waittime.." secs"))
			if time >= Easy_Data["爆本等待时间"] then
				Real_Flush = false
			else
				return
			end
		end

		if distance > 1 and not Dungeon_Flush then
			Note_Set(Check_UI("前往坐标距离剩余 ","Distance - ")..math.floor(distance)..Check_UI("码...","Yard..."))

			if distance < 30 then
				if Mount_useble < GetTime() then
					Mount_useble = GetTime() + 20
				end
				if not Interact_Step and Easy_Data["需要喊话"] then
					Interact_Step = true
					C_Timer.After(1,function() Interact_Step = false end)
					awm.RunMacroText("/party "..Easy_Data["进本喊话"])
				end
			end
			Run(x,y,z)
			return
		elseif distance <= 1 and not Dungeon_Flush then
			if not Interact_Step then
				Interact_Step = true
				    
				C_Timer.After(1.5,function() 
					Interact_Step = false 
					if Instance ~= Dungeon_ID then
						Dungeon_Flush = true
						C_Timer.After(30,function() Dungeon_Flush = false end)
					end
				end)
			end
		end
    end)
    Thread.stop()
    print("进本完成")
end

-- 这里写你在副本内 应该干什么 (逐行执行, 结束重头开始)
-- Here is your dungeon function, it will be executed line by line
T_Func["副本线程"] = function()
    textout("开始副本")

    CD['延时'](3000)

    Real_Flush = false -- 触发爆本
    Real_Flush_time = 0 -- 第一次爆本时间
    Real_Flush_times = 0 -- 爆本计数

    -- 检查是否残本
    if Need_Reset then
        CD['延时'](100)
        Thread.frame:SetScript('OnUpdate',function()
            Note_Head = Check_UI("残本重置","Go out reset")
            if not awm.UnitAffectingCombat("player") then
                if not MakingDrinkOrEat() then
                    return
                end
                if not NeedHeal() then
                    return
                end
                if not CheckUse() then
                    return
                end
            end
            Need_Reset = false
            Run_Time = Run_Time - tonumber(Easy_Data["副本重置时间"])

            Thread.frame:SetScript('OnUpdate',CD['出本检查'])
        end)
        Thread.stop()
    end

	-- 检查是否需要卖物 邮寄
	local x1,y1,z1 = Dungeon_Out.x,Dungeon_Out.y,Dungeon_Out.z
	local Out_Distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x1,y1,z1)

	if Out_Distance == nil then
		return
	end

	if (Easy_Data["需要卖物"] or Easy_Data["需要修理"]) and (not Check_BagFree() or Sell.Step ~= 1) and Out_Distance < 40 then
		Note_Set(Check_UI("出本卖物 = ","Go Out Dungeon To Vendor = ")..Merchant_Name)
		CD['导航'](x1,y1,z1)
	end

	-- 开始正常副本流程
	textout("Point 1")
	Moverotation(2706.06,1324.99,14.05)
	CD['拾取尸体']()
	Moverotation(2706.06,1324.99,14.05)
	CD['拾取尸体']()
	Moverotation(2706.06,1324.99,14.05)
	CD['拾取尸体']()
	textout("Point 1-2")
	Movewithmountwithcombat(2706.06,1324.99,14.05)
	CD['拾取尸体']()
	Movewithmountwithcombat(2706.06,1324.99,14.05)
	CD['拾取尸体']()
	Movewithmountwithcombat(2706.06,1324.99,14.05)
	CD['拾取尸体']()
	textout("Point 2")
	Movewithmountwithcombat(2646.60,1256.91,14.08)
	CD['拾取尸体']()
	Movewithmountwithcombat(2646.60,1256.91,14.08)
	CD['拾取尸体']()
	Movewithmountwithcombat(2646.60,1256.91,14.08)
	CD['拾取尸体']()
	textout("Point 3")
	Movewithmountwithcombat(2555.25,1217.55,23.76)
	CD['拾取尸体']()
	Movewithmountwithcombat(2555.25,1217.55,23.76)
	CD['拾取尸体']()
	Movewithmountwithcombat(2555.25,1217.55,23.76)
	CD['拾取尸体']()
	textout("Point 4")
	Movewithmountwithcombat(2467.48,1252.19,56.76)
	CD['拾取尸体']()
	Movewithmountwithcombat(2467.48,1252.19,56.76)
	CD['拾取尸体']()
	Movewithmountwithcombat(2467.48,1252.19,56.76)
	CD['拾取尸体']()
	textout("Point 5")
	Movewithmountwithcombat(2417.06,1239.95,60.25)
	CD['拾取尸体']()
	Movewithmountwithcombat(2417.06,1239.95,60.25)
	CD['拾取尸体']()
	Movewithmountwithcombat(2417.06,1239.95,60.25)
	CD['拾取尸体']()
	textout("Point 6")
	Movewithmountwithcombat(2383.59,1187.29,67.28)
	CD['拾取尸体']()
	Movewithmountwithcombat(2383.59,1187.29,67.28)
	CD['拾取尸体']()
	Movewithmountwithcombat(2383.59,1187.29,67.28)
	CD['拾取尸体']()
	textout("Point 7")
	Movewithmountwithcombat(2406.09,873.97,58)
	CD['拾取尸体']()
	Movewithmountwithcombat(2406.09,873.97,58)
	CD['拾取尸体']()
	Movewithmountwithcombat(2406.09,873.97,58)
	CD['拾取尸体']()
	textout("Point 8")
	Movewithmountwithcombat(2483.83,797.02,57.81)
	CD['拾取尸体']()
	Movewithmountwithcombat(2483.83,797.02,57.81)
	CD['拾取尸体']()
	Movewithmountwithcombat(2483.83,797.02,57.81)
	CD['拾取尸体']()
	textout("Point 9")
	Movewithmountwithcombat(2511.29,765.38,55.41)
	CD['拾取尸体']()
	Movewithmountwithcombat(2511.29,765.38,55.41)
	CD['拾取尸体']()
	Movewithmountwithcombat(2511.29,765.38,55.41)
	CD['拾取尸体']()
	textout("Point 10")
	Movewithmountwithcombat(2523.40,762.68,56.28)
	CD['拾取尸体']()
	Movewithmountwithcombat(2523.40,762.68,56.28)
	CD['拾取尸体']()
	Movewithmountwithcombat(2523.40,762.68,56.28)
	CD['拾取尸体']()
	textout("Point 11")
	Movewithmountwithcombat(2539.62,754.16,57.14)
	CD['拾取尸体']()
	Movewithmountwithcombat(2539.62,754.16,57.14)
	CD['拾取尸体']()
	Movewithmountwithcombat(2539.62,754.16,57.14)
    CD['拾取尸体']()
	CD['延时'](1000)
	Movewithmountwithcombat(2539.62,754.16,57.14)
	CD['拾取尸体']()
	Movewithmountwithcombat(2539.62,754.16,57.14)
	CD['拾取尸体']()
	Movewithmountwithcombat(2539.62,754.16,57.14)
    CD['拾取尸体']()
	textout("Point 12")
	Movewithmountwithcombat(2559.50,770.47,57.44)
	CD['拾取尸体']()
	Movewithmountwithcombat(2559.50,770.47,57.44)
	CD['拾取尸体']()
	Movewithmountwithcombat(2559.50,770.47,57.44)
	CD['拾取尸体']()
	textout("Point 13")
	Movewithmountwithcombat(2623.44,732.99,56.11)
	CD['拾取尸体']()
	Movewithmountwithcombat(2623.44,732.99,56.11)
	CD['拾取尸体']()
	Movewithmountwithcombat(2623.44,732.99,56.11)
	CD['拾取尸体']()
	CD['延时'](100)
	awm.CastSpellByID(DeathandDecay)
	CD['延时'](100)
	awm.ClickPosition(2642.45,750,63.23)
	CD['延时'](100)
	textout("Point 13-2")
	movenorotation(2613.35,713.85,56.96)
	movenorotation(2613.35,713.85,56.96)
	movenorotation(2613.35,713.85,56.96)
	textout("Point 13-3")
	movenorotation(2604.85,701.35,55.57)
	movenorotation(2604.85,701.35,55.57)
	movenorotation(2604.85,701.35,55.57)
	textout("Point 13-4")
	movenorotation(2616.3,687.59,55.95)
	movenorotation(2616.3,687.59,55.95)
	movenorotation(2616.3,687.59,55.95)
	CD['延时'](1200)
	Rotation()
	CD['拾取尸体']()
	textout("Point 14")
	Movewithmountwithcombat(2642.45,750,63.23)
	CD['拾取尸体']()
	Movewithmountwithcombat(2642.45,750,63.23)
	CD['拾取尸体']()
	Movewithmountwithcombat(2642.45,750,63.23)
	CD['拾取尸体']()
	textout("Point 15")
	Movewithmountwithcombat(2668.75,728.15,57.88)
	CD['拾取尸体']()
	Movewithmountwithcombat(2668.75,728.15,57.88)
	CD['拾取尸体']()
	Movewithmountwithcombat(2668.75,728.15,57.88)
	CD['拾取尸体']()
	textout("Point 16")
	Movewithmountwithcombat(2689.61,698.42,58.97)
	CD['拾取尸体']()
	Movewithmountwithcombat(2689.61,698.42,58.97)
	CD['拾取尸体']()
	Movewithmountwithcombat(2689.61,698.42,58.97)
	CD['拾取尸体']()
	textout("Point 17")
	Movewithmountwithcombat(2682.78,668.21,57.62)
	CD['拾取尸体']()
	Movewithmountwithcombat(2682.78,668.21,57.62)
	CD['拾取尸体']()
	Movewithmountwithcombat(2682.78,668.21,57.62)
	CD['拾取尸体']()
	textout("Point 18")
	Movewithmountwithcombat(2654.84,639.96,55.82)
	CD['拾取尸体']()
	Movewithmountwithcombat(2654.84,639.96,55.82)
	CD['拾取尸体']()
	Movewithmountwithcombat(2654.84,639.96,55.82)
	CD['拾取尸体']()
	textout("Point 19")
	Movewithmountwithcombat(2615.10,583.85,55.64)
	CD['拾取尸体']()
	Movewithmountwithcombat(2615.10,583.85,55.64)
	CD['拾取尸体']()
	Movewithmountwithcombat(2615.10,583.85,55.64)
	CD['拾取尸体']()
	textout("Point 20")
	Movewithmountwithcombat(2586.16,628.73,56.56)
	CD['拾取尸体']()
	Movewithmountwithcombat(2586.16,628.73,56.56)
	CD['拾取尸体']()
	Movewithmountwithcombat(2586.16,628.73,56.56)
	CD['拾取尸体']()
	
	textout("Point 21")
	Movewithmountwithcombat(2051.09,246.33,62.94)
	CD['拾取尸体']()
	Movewithmountwithcombat(2051.09,246.33,62.94)
	CD['拾取尸体']()
	Movewithmountwithcombat(2051.09,246.33,62.94)
	textout("Point 22")
	movenorotation(2076.10,221,64.87)
	textout("Point 23")
	movenorotation(2119.58,222.98,64.84)
	Rotation()
	CD['拾取尸体']()

	textout("Point 24")
	Movewithmountwithcombat(2109.58,189.21,66.22)
	CD['拾取尸体']()
	Movewithmountwithcombat(2109.58,189.21,66.22)
	CD['拾取尸体']()
	Movewithmountwithcombat(2109.58,189.21,66.22)
	CD['拾取尸体']()
	textout("Point 25")
	Movewithmountwithcombat(2076.48,168.23,65.13)
	CD['拾取尸体']()
	Movewithmountwithcombat(2076.48,168.23,65.13)
	CD['拾取尸体']()
	Movewithmountwithcombat(2076.48,168.23,65.13)
	CD['拾取尸体']()
	textout("Point 26")
	Movewithmountwithcombat(2141.51,174.37,66.22)
	CD['拾取尸体']()
	Movewithmountwithcombat(2141.51,174.37,66.22)
	CD['拾取尸体']()
	Movewithmountwithcombat(2141.51,174.37,66.22)
	CD['拾取尸体']()
	textout("Point 27")
	Moverotation(2186.31,146.63,88.21)
	CD['拾取尸体']()
	Moverotation(2186.31,146.63,88.21)
	CD['拾取尸体']()
	Moverotation(2186.31,146.63,88.21)
	CD['拾取尸体']()
	textout("Point 28")
	Moverotation(2231.15,185.02,102.54)
	CD['拾取尸体']()
	Moverotation(2231.15,185.02,102.54)
	CD['拾取尸体']()
	Moverotation(2231.15,185.02,102.54)
	CD['拾取尸体']()

	textout("Point 29")
	Moverotation(2207.27,129.74,87.95)
	CD['拾取尸体']()
	Moverotation(2207.27,129.74,87.95)
	CD['拾取尸体']()
	Moverotation(2207.27,129.74,87.95)
	CD['拾取尸体']()
	textout("Point 30")
	Moverotation(2219.97,147.39,89.45)
	CD['拾取尸体']()
	Moverotation(2219.97,147.39,89.45)
	CD['拾取尸体']()
	Moverotation(2219.97,147.39,89.45)
	CD['拾取尸体']()
	textout("Point 31")
	Moverotation(2230.37,142.47,89.45)
	CD['拾取尸体']()
	Moverotation(2230.37,142.47,89.45)
	CD['拾取尸体']()
	Moverotation(2230.37,142.47,89.45)
	CD['拾取尸体']()
	textout("Point 32")
	Moverotation(2223.41,120.82,89.45)
	CD['拾取尸体']()
	Moverotation(2223.41,120.82,89.45)
	CD['拾取尸体']()
	Moverotation(2223.41,120.82,89.45)
	CD['拾取尸体']()

	textout("Point 33")
	Moverotation(2234.79,118.47,89.45)
	CD['拾取尸体']()
	Moverotation(2234.79,118.47,89.45)
	CD['拾取尸体']()
	Moverotation(2234.79,118.47,89.45)
	CD['拾取尸体']()
	textout("Point 34")
	Moverotation(2215.64,133.4,103.37)
	CD['拾取尸体']()
	Moverotation(2215.64,133.4,103.37)
	CD['拾取尸体']()
	Moverotation(2215.64,133.4,103.37)
	CD['拾取尸体']()
	textout("Point 35")
	Moverotation(2193.29,138.30,88.21)
	CD['拾取尸体']()
	Moverotation(2193.29,138.30,88.21)
	CD['拾取尸体']()
	Moverotation(2193.29,138.30,88.21)
	CD['拾取尸体']()
	textout("Point 36")
	Movewithmount(2118.2,72.02,52.72)
	Movewithmount(2118.2,72.02,52.72)
	Movewithmount(2118.2,72.02,52.72)
	awm.CastSpellByID(BloodBoil,"player")
	textout("Point 36-2")
	movenorotation(2117.03,55.70,52.65)
	movenorotation(2117.03,55.70,52.65)
	movenorotation(2117.03,55.70,52.65)
	textout("Point 36-3")
	movenorotation(2124.53,44.29,53.08)
	movenorotation(2124.53,44.29,53.08)
	movenorotation(2124.53,44.29,53.08)
	CD['延时'](1000)
	Rotation()
	CD['拾取尸体']()
	textout("Point 37")
	movenorotation(2085,69.42,52.47)
	movenorotation(2085,69.42,52.47)
	movenorotation(2085,69.42,52.47)
	textout("Point 37-2")
	movenorotation(2089.30,66.98,52.64)
	movenorotation(2089.30,66.98,52.64)
	movenorotation(2089.30,66.98,52.64)
	textout("Point 37-3")
	movenorotation(2082.95,62.50,52.44)
	movenorotation(2082.95,62.50,52.44)
	movenorotation(2082.95,62.50,52.44)
	CD['延时'](1000)
	Rotation()
	CD['拾取尸体']()
	textout("Point 38")
	movenorotation(2072.64,105.68,53.23)
	movenorotation(2072.64,105.68,53.23)
	movenorotation(2072.64,105.68,53.23)
	textout("Point 38-2")
	movenorotation(2070.33,101.55,52.78)
	movenorotation(2070.33,101.55,52.78)
	movenorotation(2070.33,101.55,52.78)
	textout("Point 38-3")
	movenorotation(2064.11,104.14,52.86)
	movenorotation(2064.11,104.14,52.86)
	movenorotation(2064.11,104.14,52.86)
	CD['延时'](1000)
	Rotation()
	CD['拾取尸体']()
	textout("Point 39")
	Moverotation(2121.65,176.59,52.89)
	CD['拾取尸体']()
	Moverotation(2121.65,176.59,52.89)
	CD['拾取尸体']()
	Moverotation(2121.65,176.59,52.89)
	CD['拾取尸体']()
	awm.CastSpellByID(BloodBoil,"player")
	CD['延时'](1000)
	textout("Point 39-2")
	Moverotation(2121.65,176.59,52.89)
	CD['拾取尸体']()
	Moverotation(2121.65,176.59,52.89)
	CD['拾取尸体']()
	Moverotation(2121.65,176.59,52.89)
	CD['拾取尸体']()
	textout("Point 40")
	movenorotation(2160.45,232.90,52.44)
	movenorotation(2160.45,232.90,52.44)
	movenorotation(2160.45,232.90,52.44)
	textout("Point 40-2")
	movenorotation(2156.06,227.75,52.55)
	movenorotation(2156.06,227.75,52.55)
	movenorotation(2156.06,227.75,52.55)
	textout("Point 40-3")
	movenorotation(2152.88,233.20,52.44)
	movenorotation(2152.88,233.20,52.44)
	movenorotation(2152.88,233.20,52.44)
	CD['延时'](1000)
	Rotation()
	CD['拾取尸体']()
	textout("Point 41")
	movenorotation(2190.76,256.60,52.44)
	movenorotation(2190.76,256.60,52.44)
	movenorotation(2190.76,256.60,52.44)
	textout("Point 41-2")
	movenorotation(2186.55,259.14,55.44)
	movenorotation(2186.55,259.14,55.44)
	movenorotation(2186.55,259.14,55.44)
	textout("Point 41-3")
	movenorotation(2188.83,262.85,52.44)
	movenorotation(2188.83,262.85,52.44)
	movenorotation(2188.83,262.85,52.44)
	CD['延时'](1000)
	Rotation()
	CD['拾取尸体']()
	textout("Point 42")
	Moverotation(2160.45,232.90,52.44)
	CD['拾取尸体']()
	Moverotation(2160.45,232.90,52.44)
	CD['拾取尸体']()
	Moverotation(2160.45,232.90,52.44)
	CD['拾取尸体']()
	textout("Point 43")
	Movewithmountwithcombat(2283.31,731.63,57.97)
	CD['拾取尸体']()
	Movewithmountwithcombat(2283.31,731.63,57.97)
	CD['拾取尸体']()
	Movewithmountwithcombat(2283.31,731.63,57.97)
	CD['拾取尸体']()	
	textout("Point 44")
	Movewithmountwithcombat(2642.60,1247.53,14.06)
	CD['拾取尸体']()
	Movewithmountwithcombat(2642.60,1247.53,14.06)
	CD['拾取尸体']()
	Movewithmountwithcombat(2642.60,1247.53,14.06)
	CD['拾取尸体']()		

	Reset_Instance = true -- 需要重置的标志

	Moverotation(2741.67,1312.64,14.04)
	Moverotation(2741.67,1312.64,14.04)
	Moverotation(2741.67,1312.64,14.04)
	Moverotation(2741.67,1312.64,14.04)

	Dungeon_Move = 3
	CD['延时'](100)
	Thread.frame:SetScript('OnUpdate',CD['出本检查'])
	Thread.stop()

	textout('副本结束')
end

-- 这里写你死亡后应该怎么跑尸 应该干什么 (逐行执行, 结束重头开始)
-- Here is your dead and find corpse function, it will be executed line by line
T_Func["死亡线程"] = function()
    -- 屏幕中间提示
    Note_Head = "死亡跑尸"

    textout("检查重置")
    -- 判断是否 需要重置副本
    Thread.frame:SetScript('OnUpdate',function()
        if Run_Timer and Reset_Instance and awm.UnitIsGhost("player") then
            local time = Dungeon_Time
            if time <= Easy_Data["副本重置时间"] then
                local waittime = Easy_Data["副本重置时间"] - time
                waittime = math.floor(waittime)
                Note_Set("等待重置 : "..waittime.." 秒")
                return
            else
                Vars_Reset()
                C_Timer.After(10,function() ResetInstances() textout(Check_UI("副本重置成功","Dungeon Reset Success")) end)
                Reset_Instance = false
                Easy_Data.ResetTimes[#Easy_Data.ResetTimes + 1] = GetTime()
                Run_Timer = false
            end
            return
        else
            Thread.restore()
            return
        end
    end)
    Thread.stop()

    textout("检查残本")
    -- 判断是否 在副本里杀过怪物 杀过即重置
    if #OBJ_Killed >= 1 and not Need_Reset and not Reset_Instance then
        Need_Reset = true
        textout(Check_UI("怪物击杀, 判断残本","Mobs kill, Force reset dungeon"))
    end

    textout("开始跑尸")
    -- 执行跑尸 封装完成的函数 如果需要自定义路线 请删除此步骤 自由发挥
    Thread.frame:SetScript('OnUpdate', Death_Run)
    Thread.stop()
    print("跑尸完成")
end

-- 这里写第二循环 贯穿所有行动 比如一直开盾等
T_Func["第二线程"] = function()
    local Instance_Name,_,_,_,_,_,_,Instance = GetInstanceInfo()

    -- 判断在副本内
    if Instance == Dungeon_ID then

        -- 影牙不需要骑马
        if Mount_useble < GetTime() then
		    Mount_useble = GetTime() + 30
		end

        -- 计时器
        if not Run_Timer then
		    Run_Timer = true
			Run_Time = GetTime()
		end

        Out_Dungeon_Time = GetTime() -- 出本五秒干活

        if GetTime() - Start_Teleport > 5 and Dungeon_Move == 2 then
            CD['传送警报']()
        end

		if Dungeon_Move >= 2 then
			if (awm.DeBuff("player",Check_Client("反手一击","Backhand")).on or awm.DeBuff("player",Check_Client("盾牌猛击","Shield Slam")).on) and Spell_Castable(rs["寒冰屏障"]) then
				awm.CastSpellByName(rs["寒冰屏障"])
			end

			if not CastingBarFrame:IsVisible() and UnitAffectingCombat("player") then
				UseItem()
			end
		end

		if awm.Buff("player",rs["寒冰屏障"]).on then
			awm.RunMacroText("/cancelAura "..rs["寒冰屏障"])
		end

    else
        Start_Teleport = GetTime()
    end
end

function MainThread()
    Px,Py,Pz = awm.ObjectPosition("player")
	Level = awm.UnitLevel("player")
	Instance_Name,_,_,_,_,_,_,Instance = GetInstanceInfo()

	if Px == nil or Py == nil or Pz == nil then
		return
	end
	
	Dungeon_Time = math.floor(GetTime() - Run_Time)

	if GetTime() - Destroy_Time > 20 then -- 摧毁
	    Destroy_Time = GetTime()
		Auto_Destroy()
	end

	if CheckDeadOrNot() then -- 判断人物是否死亡
		if Thread["野外运行"] then
			Thread["野外运行"] = false

			print('野外死亡线程启动')
			Thread.frame:SetScript('OnUpdate', function() end)

			Try_Stop()

			return
		end

		if Thread["副本运行"] then
			Thread["副本运行"] = false

			print('副本死亡线程启动')
			Thread.frame:SetScript('OnUpdate', function() end)

			Try_Stop()

			return
		end

		Thread["野外线程"] = Thread.create(T_Func["野外线程"])
		Thread["副本线程"] = Thread.create(T_Func["副本线程"])

		if Thread.Status ~= "死亡" then
			Thread.Status_Time = GetTime()
			Thread.Status = "死亡"
			return
		else
		    if GetTime() - Thread.Status_Time < 0.5 then
				if GetUnitSpeed('player') > 0 then
					Try_Stop()
				end
				return
			end
		end

		if (not Thread['死亡运行'] or coroutine.status(Thread["死亡线程"]) == "dead") and awm.UnitIsGhost("player") then
			Thread['死亡运行'] = true

			Try_Stop()

			Thread.frame:SetScript('OnUpdate',function() end)

			Thread["死亡线程"] = Thread.create(T_Func["死亡线程"])
			Thread.resume(Thread["死亡线程"])

			Thread.Current = Thread["死亡线程"]
		end
		return
	end
	if InstanceCorpse then
	    textout(Check_UI("副本跑尸结束, 重置所有步骤","Enter dungeon to repop, reset all variables"))
		InstanceCorpse = false
		return
	end

	if Instance == Dungeon_ID then
        if Thread["野外运行"] then
			Thread["野外运行"] = false

			print('野外进入副本线程启动')
			Thread.frame:SetScript('OnUpdate', function() end)

			Try_Stop()

			return
		end

		if Thread["死亡运行"] then
			Thread["死亡运行"] = false

			print('死亡进入副本线程启动')
			Thread.frame:SetScript('OnUpdate', function() end)

			Try_Stop()

			return
		end

		Thread["野外线程"] = Thread.create(T_Func["野外线程"])
		Thread["死亡线程"] = Thread.create(T_Func["死亡线程"])

		if Thread.Status ~= "副本" then
			Thread.Status_Time = GetTime()
			Thread.Status = "副本"
			return
		else
		    if GetTime() - Thread.Status_Time < 0.5 then
				if GetUnitSpeed('player') > 0 then
					Try_Stop()
				end
				return
			end
		end

		if not Thread['副本运行'] or coroutine.status(Thread["副本线程"]) == "dead" then
			Thread['副本运行'] = true

			Try_Stop()

			Thread.frame:SetScript('OnUpdate',function() end)

			Thread["副本线程"] = Thread.create(T_Func["副本线程"])
			Thread.resume(Thread["副本线程"])

			Thread.Current = Thread["副本线程"]
		end	
	else
	    if Thread["死亡运行"] then
			Thread["死亡运行"] = false

			print('野外复活 线程启动')
			Thread.frame:SetScript('OnUpdate', function() end)

			Try_Stop()

			return
		end

		if Thread["副本运行"] then
			Thread["副本运行"] = false

			print('副本出本 线程启动')
			Thread.frame:SetScript('OnUpdate', function() end)

			Try_Stop()

			return
		end

		Thread["野外线程"] = Thread.create(T_Func["野外线程"])
		Thread["副本线程"] = Thread.create(T_Func["副本线程"])

		if Thread.Status ~= "野外" then
			Thread.Status_Time = GetTime()
			Thread.Status = "野外"
			return
		else
		    if GetTime() - Thread.Status_Time < 0.5 then
				if GetUnitSpeed('player') > 0 then
					Try_Stop()
				end
				return
			end
		end

		if not Thread['野外运行'] or coroutine.status(Thread["野外线程"]) == "dead" then
			Thread['野外运行'] = true

			Try_Stop()

			Thread.frame:SetScript('OnUpdate',function() end)

			Thread["野外线程"] = Thread.create(T_Func["野外线程"])
			Thread.resume(Thread["野外线程"])

			Thread.Current = Thread["野外线程"]
		end
	end
end


-- 创建三个线程
Thread["死亡线程"] = Thread.create(T_Func["死亡线程"])
Thread["野外线程"] = Thread.create(T_Func["野外线程"])
Thread["副本线程"] = Thread.create(T_Func["副本线程"])


-- UI
local function Create_Nav_UI() -- 导航UI
    Basic_UI.Nav = {}
	Basic_UI.Nav.Py = -10
	local function Frame_Create()
		Basic_UI.Nav.frame = CreateFrame('frame',"Basic_UI.Nav.frame",Basic_UI.Panel, BackdropTemplateMixin and "BackdropTemplate")
		Basic_UI.Nav.frame:SetPoint("TopLeft")
		Basic_UI.Nav.frame:SetSize(590,480)
		Basic_UI.Nav.frame:SetBackdrop({_,edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",_,_,edgeSize = 15,_})
		Basic_UI.Nav.frame:Hide()
		Basic_UI.Nav.frame:SetBackdropColor(0.1,0.1,0.1,0)
		Basic_UI.Nav.frame:SetBackdropBorderColor(0.1,0.1,0.1,0)
		Basic_UI.Nav.frame:SetFrameStrata('TOOLTIP')
	end

	local function Button_Create()
	    UI_Button_Py = UI_Button_Py - 30
		Basic_UI.Nav.button = Create_Page_Button(Basic_UI["选项列表"], "Top",0,UI_Button_Py,Check_UI("导航","navigation"))
		Basic_UI.Nav.button:SetSize(130,20)
		Basic_UI.Nav.button:SetScript("OnClick", function(self)
			All_Buttons_Hide()
            Basic_UI.Nav.frame:Show()
			Basic_UI.Nav.button:SetBackdropColor(245/255 , 245/255, 220/255, 0.4)
		end)
        Config_UI[#Config_UI + 1] = function() Basic_UI.Nav.frame:Hide() Basic_UI.Nav.button:SetBackdropColor(0,0,0,0) end
	end

	local function Create_Check(Var,title,Default,x,y)
		Basic_UI.Nav[Var] = Create_Check_Button(Basic_UI.Nav.frame, "TOPLEFT", x, y, title)

		Basic_UI.Nav[Var]:SetScript("OnClick", function(self)
			if Basic_UI.Nav[Var]:GetChecked() then
				Easy_Data[Var] = true
			elseif not Basic_UI.Nav[Var]:GetChecked() then
				Easy_Data[Var] = false
			end
		end)
		if Easy_Data[Var] ~= nil then
			if Easy_Data[Var] then
				Basic_UI.Nav[Var]:SetChecked(true)
			else
				Basic_UI.Nav[Var]:SetChecked(false)
			end
		else
			Easy_Data[Var] = Default
			Basic_UI.Nav[Var]:SetChecked(Default)
		end
	end

	local function Create_Edit(Var,title,Default,number,x,y)
	    local Header = Create_Header(Basic_UI.Nav.frame, "TOPLEFT", x, y, title)

		Basic_UI.Nav[Var] = Create_EditBox(Basic_UI.Nav.frame, "TOPLEFT", x, y - 20, Default, false, 250, 24)

		Basic_UI.Nav[Var]:SetScript("OnEditFocusLost", function(self)
		    if not number then
			    Easy_Data[Var] = Basic_UI.Nav[Var]:GetText()
			else
				Easy_Data[Var] = tonumber(Basic_UI.Nav[Var]:GetText())
			end
		end)
		if Easy_Data[Var] ~= nil then
			Basic_UI.Nav[Var]:SetText(Easy_Data[Var])
		else
			if not number then
			    Easy_Data[Var] = Basic_UI.Nav[Var]:GetText()
			else
				Easy_Data[Var] = tonumber(Basic_UI.Nav[Var]:GetText())
			end
		end
	end

	Frame_Create()
	Button_Create()

	Create_Check("传送检测",Check_UI("GM传送检测 - 传送报警","GM teleport detection By distance"),false,10,Basic_UI.Nav.Py)
	Create_Edit("传送距离",Check_UI("GM传送检测 - 触发距离(码)","GM teleport detection distance to trigger alarm (yards)"),"50",true,10,Basic_UI.Nav.Py - 30)

	Basic_UI.Nav.Py = Basic_UI.Nav.Py - 80

	Create_Check("水中寻路",Check_UI("水中寻路 - 允许通过水域","Navigation - Allow water"),true,10,Basic_UI.Nav.Py)

	Basic_UI.Nav.Py = Basic_UI.Nav.Py - 30
	Create_Check("平滑寻路",Check_UI("平滑寻路 - 短距离生成路径点","Navigation - Smooth Path"),false,10,Basic_UI.Nav.Py)
	Create_Edit("平滑寻路间隔",Check_UI("平滑寻路 - 路径点相隔距离(码)","Smooth Path - node distance"),"2.5",true,10,Basic_UI.Nav.Py - 30)
	Create_Edit("平滑寻路角度",Check_UI("平滑寻路 - 路径点最大角度(0 - 3.6)","Smooth Path - node angle"),"0.3",true,300,Basic_UI.Nav.Py - 30)

	Basic_UI.Nav.Py = Basic_UI.Nav.Py - 80
	Create_Check("躲避物体",Check_UI("躲避物体 - 二次处理路径","Navigation - Aviod Dynamic Object"),false,10,Basic_UI.Nav.Py)
	Create_Edit("躲避物体距离",Check_UI("躲避物体 - 与墙保持的距离(码)","Aviod Object - node distance from walls"),"1.5",true,10,Basic_UI.Nav.Py - 30)
	Create_Edit("躲避物体体积",Check_UI("躲避物体 - 无视物体体积","Aviod Object - object size"),"3.5",true,300,Basic_UI.Nav.Py - 30)

	Basic_UI.Nav.Py = Basic_UI.Nav.Py - 80
	Create_Check("有效寻路",Check_UI("有效寻路 - 寻路到准确地点","Navigation - Vaild Path"),false,10,Basic_UI.Nav.Py)

	Basic_UI.Nav.Py = Basic_UI.Nav.Py - 30
	Create_Check("使用坐骑",Check_UI("使用坐骑","Use mount"),true,10,Basic_UI.Nav.Py)

	Create_Edit("动作条坐骑位置",Check_UI("坐骑 - 快捷栏 第几格(第一页)","Mount - Action slot number to use"),"1",true,10,Basic_UI.Nav.Py - 30)

	Basic_UI.Nav.Py = Basic_UI.Nav.Py - 80
	Create_Check("使用坐骑物品",Check_UI("使用坐骑 - 物品名字","Use mount By item name"),false,10,Basic_UI.Nav.Py)

	Create_Edit("坐骑物品名字",Check_UI("坐骑物品 - 名字 = ","Mount item name = "),"",false,10,Basic_UI.Nav.Py - 30)


	Basic_UI.Nav.Py = Basic_UI.Nav.Py - 80
	Create_Check("使用坐骑技能",Check_UI("使用坐骑 - 技能名字","Use mount By spell cast"),false,10,Basic_UI.Nav.Py)

	Create_Edit("坐骑技能名字",Check_UI("坐骑技能 - 名字 = ","Mount spell name = "),"",false,10,Basic_UI.Nav.Py - 30)


	Basic_UI.Nav.Py = Basic_UI.Nav.Py - 80

	if Easy_Data["小德变形坐骑"] == nil then
		if DoesSpellExist(rs["旅行形态"]) then
			Easy_Data["小德变形坐骑"] = true
		else
			Easy_Data["小德变形坐骑"] = false
		end
	end
	Create_Check("小德变形坐骑",Check_UI("使用小德变形术 - 代替坐骑","Use Druid Transform Spell - Instead Mount"),true,10,Basic_UI.Nav.Py)

	Basic_UI.Nav.Py = Basic_UI.Nav.Py - 30
	Create_Check("服务器地图",Check_UI("加载云地图系统 (只用于旧世界跨大陆)","Cloud navigation (Only for acrossing continents)"),true,10,Basic_UI.Nav.Py)

	Basic_UI.Nav.Py = Basic_UI.Nav.Py - 30
	Create_Check("地图刷新",Check_UI("自动重新计算路径","Auto recalculate paths"),false,10,Basic_UI.Nav.Py)

	Basic_UI.Nav.Py = Basic_UI.Nav.Py - 30
	Create_Edit("地图刷新间隔",Check_UI("重新计算间隔 (秒)","Recalculation interval time (seconds)"),"10",true,10,Basic_UI.Nav.Py)

	Basic_UI.Nav.Py = Basic_UI.Nav.Py - 50
	Create_Check("坐标处理",Check_UI("智能算法 - 根据角度推算生成新路线","Auto process paths with algorithm"),true,10,Basic_UI.Nav.Py)
end

local function Create_Config_UI() -- 游戏设置
    Basic_UI.Set = {}
	Basic_UI.Set.Py = -10
	local function Frame_Create()
		Basic_UI.Set.frame = CreateFrame('frame',"Basic_UI.Set.frame",Basic_UI.Panel, BackdropTemplateMixin and "BackdropTemplate")
		Basic_UI.Set.frame:SetPoint("TopLeft",0,0)
		Basic_UI.Set.frame:SetSize(590,480)
		Basic_UI.Set.frame:SetBackdrop({_,edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",_,_,edgeSize = 15,_})
		Basic_UI.Set.frame:Hide()
		Basic_UI.Set.frame:SetBackdropColor(0.1,0.1,0.1,0)
		Basic_UI.Set.frame:SetBackdropBorderColor(0.1,0.1,0.1,0)
		Basic_UI.Set.frame:SetFrameStrata('TOOLTIP')
	end

	local function Button_Create()
	    UI_Button_Py = UI_Button_Py - 30
		Basic_UI.Set.button = Create_Page_Button(Basic_UI["选项列表"], "Top",0,UI_Button_Py,Check_UI("脚本","profile"))
		Basic_UI.Set.button:SetSize(130,20)
		Basic_UI.Set.button:SetScript("OnClick", function(self)
			All_Buttons_Hide()
            Basic_UI.Set.frame:Show()
			Basic_UI.Set.button:SetBackdropColor(245/255 , 245/255, 220/255, 0.4)
		end)
        Config_UI[#Config_UI + 1] = function() Basic_UI.Set.frame:Hide() Basic_UI.Set.button:SetBackdropColor(0,0,0,0) end
	end

	local function Create_Check(Var,title,Default,x,y)
		Basic_UI.Set[Var] = Create_Check_Button(Basic_UI.Set.frame, "TOPLEFT", x, y, title)

		Basic_UI.Set[Var]:SetScript("OnClick", function(self)
			if Basic_UI.Set[Var]:GetChecked() then
				Easy_Data[Var] = true
			elseif not Basic_UI.Set[Var]:GetChecked() then
				Easy_Data[Var] = false
			end
		end)
		if Easy_Data[Var] ~= nil then
			if Easy_Data[Var] then
				Basic_UI.Set[Var]:SetChecked(true)
			else
				Basic_UI.Set[Var]:SetChecked(false)
			end
		else
			Easy_Data[Var] = Default
			Basic_UI.Set[Var]:SetChecked(Default)
		end
	end

	local function Create_Edit(Var,title,Default,number,x,y)
	    local Header = Create_Header(Basic_UI.Set.frame, "TOPLEFT", x, y, title)

		Basic_UI.Set[Var] = Create_EditBox(Basic_UI.Set.frame, "TOPLEFT", x, y - 20, Default, false, 250, 24)

		Basic_UI.Set[Var]:SetScript("OnEditFocusLost", function(self)
		    if not number then
			    Easy_Data[Var] = Basic_UI.Set[Var]:GetText()
			else
				Easy_Data[Var] = tonumber(Basic_UI.Set[Var]:GetText())
			end
		end)
		if Easy_Data[Var] ~= nil then
			Basic_UI.Set[Var]:SetText(Easy_Data[Var])
		else
			if not number then
			    Easy_Data[Var] = Basic_UI.Set[Var]:GetText()
			else
				Easy_Data[Var] = tonumber(Basic_UI.Set[Var]:GetText())
			end
		end
	end

	Frame_Create()
	Button_Create()

	Create_Check("卡死重置",Check_UI("卡死复活重置","Stuck Reset - Suicide in dungeon, reset and run to dungeon in spirit status"),false,10,Basic_UI.Set.Py)

	Basic_UI.Set.Py = Basic_UI.Set.Py - 30
	Create_Check("需要拾取",Check_UI("拾取怪物尸体","Loot mobs' bodies"),true,10,Basic_UI.Set.Py)

	Basic_UI.Set.Py = Basic_UI.Set.Py - 30
	Create_Check("隐身出本",rs["隐形术"]..Check_UI(" 进本和出本"," Go in and out dungeon"),true,10,Basic_UI.Set.Py)

	Basic_UI.Set.Py = Basic_UI.Set.Py - 30
	Create_Check("等待隐身出本CD",rs["隐形术"]..Check_UI(" 等待CD 进本和出本"," Wait CD to go in and out dungeon"),false,10,Basic_UI.Set.Py)

	Basic_UI.Set.Py = Basic_UI.Set.Py - 30
	Create_Check("击杀Boss",Check_UI("击杀影牙BOSS (路径延长)","Kill all BOSS (Path expand)"),true,10,Basic_UI.Set.Py)

	Basic_UI.Set.Py = Basic_UI.Set.Py - 30
	Create_Edit("拾取间隔",Check_UI("拾取间隔时间","Lott interval"),0.05,true,10,Basic_UI.Set.Py)

	local function Wait_point()
	    Basic_UI.Set.Py = Basic_UI.Set.Py - 50
	    local Header1 = Create_Header(Basic_UI.Set.frame,"TOPLEFT",10, Basic_UI.Set.Py,Check_UI("影牙 爆本 本外等待坐标","Shadowfang Keep Wait Point")) 

		Basic_UI.Set.Py = Basic_UI.Set.Py - 20
		Basic_UI.Set["影牙等待坐标"] = Create_EditBox(Basic_UI.Set.frame,"TOPLEFT",10, Basic_UI.Set.Py,"-246,1529,77",false,280,24)
		Basic_UI.Set["影牙等待坐标"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data["影牙等待坐标"] = Basic_UI.Set["影牙等待坐标"]:GetText()
			local coord_package = string.split(Easy_Data["影牙等待坐标"],",")
			Dungeon_Flush_Point.x,Dungeon_Flush_Point.y,Dungeon_Flush_Point.z = tonumber(coord_package[1]),tonumber(coord_package[2]),tonumber(coord_package[3])
		end)
		if Easy_Data["影牙等待坐标"] ~= nil then
			Basic_UI.Set["影牙等待坐标"]:SetText(Easy_Data["影牙等待坐标"])
			local coord_package = string.split(Easy_Data["影牙等待坐标"],",")
			Dungeon_Flush_Point.x,Dungeon_Flush_Point.y,Dungeon_Flush_Point.z = tonumber(coord_package[1]),tonumber(coord_package[2]),tonumber(coord_package[3])
		else
			Easy_Data["影牙等待坐标"] = Basic_UI.Set["影牙等待坐标"]:GetText()
		end

		Basic_UI.Set["获取等待坐标"] = Create_Button(Basic_UI.Set.frame,"TOPLEFT",320, Basic_UI.Set.Py,Check_UI("获取坐标","Generate Coord"))
		Basic_UI.Set["获取等待坐标"]:SetSize(120,24)
		Basic_UI.Set["获取等待坐标"]:SetScript("OnClick", function(self)
			local Instance_Name,_,_,_,_,_,_,Instance = GetInstanceInfo()
			if Instance ~= Dungeon_ID then
			    local x,y,z = awm.ObjectPosition("player")
				Basic_UI.Set["影牙等待坐标"]:SetText(math.floor(x)..","..math.floor(y)..","..math.floor(z))
				Easy_Data["影牙等待坐标"] = Basic_UI.Set["影牙等待坐标"]:GetText()
				Dungeon_Flush_Point.x,Dungeon_Flush_Point.y,Dungeon_Flush_Point.z = x,y,z
			else
			    textout(Check_UI("不要在副本内点击按钮","Don't click it in dungeon"))
			end
		end)
	end
	Wait_point()

	Basic_UI.Set.Py = Basic_UI.Set.Py - 30
	Create_Edit("副本重置时间",Check_UI("副本运行最低时间 (每小时重置上限)(秒)","Dungeon Minimum Reset Wait Time(Second) (5 Run Per Hour)"),900,true,10,Basic_UI.Set.Py)

	Basic_UI.Set.Py = Basic_UI.Set.Py - 50
	Create_Edit("等待时间",Check_UI("重置后副本外等待时间","Wait time outside after leader reset"),5,true,10,Basic_UI.Set.Py)

	Basic_UI.Set.Py = Basic_UI.Set.Py - 50
	Create_Edit("爆本等待时间",Check_UI("爆本后 本外等待时间","Wait time after 5 runs per hour"),300,true,10,Basic_UI.Set.Py)

	Basic_UI.Set.Py = Basic_UI.Set.Py - 50
	Create_Check("需要喊话",Check_UI("需要进出本喊话带小号","Command bring alts in or out dungeon"),false,10,Basic_UI.Set.Py)

	Basic_UI.Set.Py = Basic_UI.Set.Py - 30
	Create_Edit("进本喊话",Check_UI("进本喊话命令","Command of going into dungeon"),"go in",false,10,Basic_UI.Set.Py)

	Create_Edit("出本喊话",Check_UI("进本喊话命令","Command of going into dungeon"),"go out",false,300,Basic_UI.Set.Py)
end

local function Create_Sell_UI() -- 出售UI
    Basic_UI.Sell = {}
	Basic_UI.Sell.Py = -10
	local function Frame_Create()
		Basic_UI.Sell.frame = CreateFrame('frame',"Basic_UI.Sell.frame",Basic_UI.Panel, BackdropTemplateMixin and "BackdropTemplate")
		Basic_UI.Sell.frame:SetPoint("TopLeft",0,0)
		Basic_UI.Sell.frame:SetSize(590,480)
		Basic_UI.Sell.frame:SetBackdrop({_,edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",_,_,edgeSize = 15,_})
		Basic_UI.Sell.frame:Hide()
		Basic_UI.Sell.frame:SetBackdropColor(0.1,0.1,0.1,0)
		Basic_UI.Sell.frame:SetBackdropBorderColor(0.1,0.1,0.1,0)
		Basic_UI.Sell.frame:SetFrameStrata('TOOLTIP')
	end

	local function Button_Create()
	    UI_Button_Py = UI_Button_Py - 30
		Basic_UI.Sell.button = Create_Page_Button(Basic_UI["选项列表"], "Top",0,UI_Button_Py,Check_UI("出售","vendor"))
		Basic_UI.Sell.button:SetSize(130,20)
		Basic_UI.Sell.button:SetScript("OnClick", function(self)
			All_Buttons_Hide()
            Basic_UI.Sell.frame:Show()
			Basic_UI.Sell.button:SetBackdropColor(245/255 , 245/255, 220/255, 0.4)
		end)
        Config_UI[#Config_UI + 1] = function() Basic_UI.Sell.frame:Hide() Basic_UI.Sell.button:SetBackdropColor(0,0,0,0) end
	end

	local function Create_Check(Var,title,Default,x,y)
		Basic_UI.Sell[Var] = Create_Check_Button(Basic_UI.Sell.frame, "TOPLEFT", x, y, title)

		Basic_UI.Sell[Var]:SetScript("OnClick", function(self)
			if Basic_UI.Sell[Var]:GetChecked() then
				Easy_Data[Var] = true
			elseif not Basic_UI.Sell[Var]:GetChecked() then
				Easy_Data[Var] = false
			end
		end)
		if Easy_Data[Var] ~= nil then
			if Easy_Data[Var] then
				Basic_UI.Sell[Var]:SetChecked(true)
			else
				Basic_UI.Sell[Var]:SetChecked(false)
			end
		else
			Easy_Data[Var] = Default
			Basic_UI.Sell[Var]:SetChecked(Default)
		end
	end

	local function Create_Edit(Var,title,Default,number,x,y)
	    local Header = Create_Header(Basic_UI.Sell.frame, "TOPLEFT", x, y, title)

		Basic_UI.Sell[Var] = Create_EditBox(Basic_UI.Sell.frame, "TOPLEFT", x, y - 20, Default, false, 250, 24)

		Basic_UI.Sell[Var]:SetScript("OnEditFocusLost", function(self)
		    if not number then
			    Easy_Data[Var] = Basic_UI.Sell[Var]:GetText()
			else
				Easy_Data[Var] = tonumber(Basic_UI.Sell[Var]:GetText())
			end
		end)
		if Easy_Data[Var] ~= nil then
			Basic_UI.Sell[Var]:SetText(Easy_Data[Var])
		else
			if not number then
			    Easy_Data[Var] = Basic_UI.Sell[Var]:GetText()
			else
				Easy_Data[Var] = tonumber(Basic_UI.Sell[Var]:GetText())
			end
		end
	end

	Frame_Create()
	Button_Create()

	Create_Check("需要卖物",Check_UI("需要自动出售物品至商店","Auto sell items to vendor"),true,10,Basic_UI.Sell.Py)
	Create_Check("模糊字售卖",Check_UI("模糊字售卖","Vague words to sell items"),true,280,Basic_UI.Sell.Py)

	Basic_UI.Sell.Py = Basic_UI.Sell.Py - 30
	Create_Check("需要修理",Check_UI("需要自动修理装备耐久度","Auto repair gears"),true,10,Basic_UI.Sell.Py)
	Create_Edit("修理耐久度",Check_UI("耐久度触发修理行为 (0 - 1)","Inventory durability to fix (0 - 1)"),"0.1",true,10,Basic_UI.Sell.Py - 30)

	Basic_UI.Sell.Py = Basic_UI.Sell.Py - 80
	Create_Check("自定义商人",Check_UI("自定义 商人信息","Customize Vendor NPC Info"),false,10,Basic_UI.Sell.Py)
	Create_Edit("自定义商人名字",Check_UI("自定义 商人名字","Customize Vendor NPC Full Name"),Check_UI("穆恩丹·秋谷","Sara Dan"),false,10,Basic_UI.Sell.Py - 30)

	Basic_UI.Sell["获取商人名字"] = Create_Button(Basic_UI.Sell.frame,"TOPLEFT",300, Basic_UI.Sell.Py - 50,Check_UI("获取目标名字","Target Full Name"))
		Basic_UI.Sell["获取商人名字"]:SetSize(150,24)
		Basic_UI.Sell["获取商人名字"]:SetScript("OnClick", function(self)
			if awm.ObjectExists("target") then
			    local name = awm.UnitFullName("target")
				if name == nil then
				    textout(Check_UI("商人名字为空","A blank name"))
				    return
				end
				Basic_UI.Sell["自定义商人名字"]:SetText(name)
				Easy_Data["自定义商人名字"] = name
			else
			    textout(Check_UI("请先选择一个目标","Choose a target first"))
			end
		end)

	Basic_UI.Sell.Py = Basic_UI.Sell.Py - 80
	Create_Edit("自定义商人坐标",Check_UI("自定义 商人坐标","Customize Vendor NPC Coordinate"),"1944,0,0,0",false,10,Basic_UI.Sell.Py)
	Basic_UI.Sell["获取商人坐标"] = Create_Button(Basic_UI.Sell.frame,"TOPLEFT",300, Basic_UI.Sell.Py - 20,Check_UI("获取坐标","Generate Coord"))
		Basic_UI.Sell["获取商人坐标"]:SetSize(150,24)
		Basic_UI.Sell["获取商人坐标"]:SetScript("OnClick", function(self)
			local x,y,z = awm.ObjectPosition("player")
			local Current_Map = C_Map.GetBestMapForUnit("player")
			local string = Current_Map..","..math.floor(x)..","..math.floor(y)..","..math.floor(z)
			Basic_UI.Sell["自定义商人坐标"]:SetText(string)
			Easy_Data["自定义商人坐标"] = string
		end)

	Basic_UI.Sell.Py = Basic_UI.Sell.Py - 50
	Create_Edit("卖物格数",Check_UI("背包剩余多少格, 回城卖物","Freeslots less than how many to vendor"),"2",true,10,Basic_UI.Sell.Py)

	Basic_UI.Sell.Py = Basic_UI.Sell.Py - 50
	local Header = Create_Header(Basic_UI.Sell.frame,"TOPLEFT",10, Basic_UI.Sell.Py,Check_UI("售卖颜色","Vendor Items Quality"))

	Basic_UI.Sell.Py = Basic_UI.Sell.Py - 30
	Create_Check("售卖灰色",Check_UI("灰色","Grey"),true,10,Basic_UI.Sell.Py)
	Create_Check("售卖白色",Check_UI("白色","White"),true,100,Basic_UI.Sell.Py)
	Create_Check("售卖绿色",Check_UI("绿色","Green"),true,190,Basic_UI.Sell.Py)
	Create_Check("售卖蓝色",Check_UI("蓝色","Blue"),true,280,Basic_UI.Sell.Py)
	Create_Check("售卖紫色",Check_UI("紫色","Purple"),true,370,Basic_UI.Sell.Py)

	local function Keep_Item() -- 保留物品
	    local Keep_Frame = {}
	    local function Update_List()
		    local ItemList = string.split(Easy_Data["保留物品"],"\n")
			if #ItemList > 0 then
			    for i = 1,#ItemList do
				    if not Keep_Frame[i] then
					    Keep_Frame[i] = Create_Header(Basic_UI.Sell["保留列表"],"TOPLEFT",10, (-30 * (i - 1) - 10),ItemList[i].."("..i..")")
					else
					    Keep_Frame[i]:SetPoint("TOPLEFT",10, (-30 * (i - 1) - 10))
						Keep_Frame[i]:SetText(ItemList[i].."("..i..")")
						Keep_Frame[i]:Show()
					end
				end
			end

			if #Keep_Frame > #ItemList then
				for i = #ItemList + 1,#Keep_Frame do
					Keep_Frame[i]:Hide()
				end
			end
		end

	    Basic_UI.Sell.Py = Basic_UI.Sell.Py - 30
	    local header = Create_Header(Basic_UI.Sell.frame,"TopLeft",10,Basic_UI.Sell.Py,Check_UI("保留物品 (每行一个)","Keep Item (one line one item)"))

	    Basic_UI.Sell["保留物品"] = Create_Scroll_Edit(Basic_UI.Sell.frame,"TopLeft",10,Basic_UI.Sell.Py - 20,Check_UI("梦叶草\n山鼠草\n奥术水晶\n源生\n微粒","Dreamfoil\nMountain Silversage\nArcane Crystal"),260,300)

		Basic_UI.Sell["保留物品"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data["保留物品"] = Basic_UI.Sell["保留物品"]:GetText()
			Update_List()
		end)
        if Easy_Data["保留物品"] == nil then
            Easy_Data["保留物品"] = Check_UI("梦叶草\n山鼠草\n奥术水晶\n源生\n微粒","Dreamfoil\nMountain Silversage\nArcane Crystal")
        else
            Basic_UI.Sell["保留物品"]:SetText(Easy_Data["保留物品"])
        end

		local header = Create_Header(Basic_UI.Sell.frame,"TopLeft",320,Basic_UI.Sell.Py,Check_UI("保留物品列表","Keep Item List"))
		Basic_UI.Sell["保留列表"] = Create_Scroll(Basic_UI.Sell.frame,"TopLeft",320,Basic_UI.Sell.Py - 20,260,300)

		Basic_UI.Sell.Py = Basic_UI.Sell.Py - 300

		Update_List()
	end

	Keep_Item()
end

local function Create_Destroy_UI() -- 摧毁UI
    Basic_UI.Destroy = {}
	Basic_UI.Destroy.Py = -10
	local function Frame_Create()
		Basic_UI.Destroy.frame = CreateFrame('frame',"Basic_UI.Destroy.frame",Basic_UI.Panel, BackdropTemplateMixin and "BackdropTemplate")
		Basic_UI.Destroy.frame:SetPoint("TopLeft",0,0)
		Basic_UI.Destroy.frame:SetSize(590,480)
		Basic_UI.Destroy.frame:SetBackdrop({_,edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",_,_,edgeSize = 15,_})
		Basic_UI.Destroy.frame:Hide()
		Basic_UI.Destroy.frame:SetBackdropColor(0.1,0.1,0.1,0)
		Basic_UI.Destroy.frame:SetBackdropBorderColor(0.1,0.1,0.1,0)
		Basic_UI.Destroy.frame:SetFrameStrata('TOOLTIP')
	end

	local function Button_Create()
	    UI_Button_Py = UI_Button_Py - 30
		Basic_UI.Destroy.button = Create_Page_Button(Basic_UI["选项列表"], "Top",0,UI_Button_Py,Check_UI("摧毁","destroy"))
		Basic_UI.Destroy.button:SetSize(130,20)
		Basic_UI.Destroy.button:SetScript("OnClick", function(self)
			All_Buttons_Hide()
            Basic_UI.Destroy.frame:Show()
			Basic_UI.Destroy.button:SetBackdropColor(245/255 , 245/255, 220/255, 0.4)
		end)
        Config_UI[#Config_UI + 1] = function() Basic_UI.Destroy.frame:Hide() Basic_UI.Destroy.button:SetBackdropColor(0,0,0,0) end
	end

	local function Create_Check(Var,title,Default,x,y)
		Basic_UI.Destroy[Var] = Create_Check_Button(Basic_UI.Destroy.frame, "TOPLEFT", x, y, title)

		Basic_UI.Destroy[Var]:SetScript("OnClick", function(self)
			if Basic_UI.Destroy[Var]:GetChecked() then
				Easy_Data[Var] = true
			elseif not Basic_UI.Destroy[Var]:GetChecked() then
				Easy_Data[Var] = false
			end
		end)
		if Easy_Data[Var] ~= nil then
			if Easy_Data[Var] then
				Basic_UI.Destroy[Var]:SetChecked(true)
			else
				Basic_UI.Destroy[Var]:SetChecked(false)
			end
		else
			Easy_Data[Var] = Default
			Basic_UI.Destroy[Var]:SetChecked(Default)
		end
	end

	local function Create_Edit(Var,title,Default,number,x,y)
	    local Header = Create_Header(Basic_UI.Destroy.frame, "TOPLEFT", x, y, title)

		Basic_UI.Destroy[Var] = Create_EditBox(Basic_UI.Destroy.frame, "TOPLEFT", x, y - 20, Default, false, 250, 24)

		Basic_UI.Destroy[Var]:SetScript("OnEditFocusLost", function(self)
		    if not number then
			    Easy_Data[Var] = Basic_UI.Destroy[Var]:GetText()
			else
				Easy_Data[Var] = tonumber(Basic_UI.Destroy[Var]:GetText())
			end
		end)
		if Easy_Data[Var] ~= nil then
			Basic_UI.Destroy[Var]:SetText(Easy_Data[Var])
		else
			if not number then
			    Easy_Data[Var] = Basic_UI.Destroy[Var]:GetText()
			else
				Easy_Data[Var] = tonumber(Basic_UI.Destroy[Var]:GetText())
			end
		end
	end

	Frame_Create()
	Button_Create()

	local Header = Create_Header(Basic_UI.Destroy.frame,"TOPLEFT",10, Basic_UI.Destroy.Py,Check_UI("摧毁颜色","Destroy Item Quality"))

	Basic_UI.Destroy.Py = Basic_UI.Destroy.Py - 30
	Create_Check("摧毁灰色",Check_UI("灰色","Grey"),false,10,Basic_UI.Destroy.Py)
	Create_Check("摧毁白色",Check_UI("白色","White"),false,100,Basic_UI.Destroy.Py)
	Create_Check("摧毁绿色",Check_UI("绿色","Green"),false,190,Basic_UI.Destroy.Py)
	Create_Check("摧毁蓝色",Check_UI("蓝色","Blue"),false,280,Basic_UI.Destroy.Py)
	Create_Check("摧毁紫色",Check_UI("紫色","Purple"),false,370,Basic_UI.Destroy.Py)

	local function Destroy_Item() -- 摧毁物品
	    local Keep_Frame = {}
	    local function Update_List()
		    local ItemList = string.split(Easy_Data["摧毁物品"],"\n")
			if #ItemList > 0 then
			    for i = 1,#ItemList do
				    if not Keep_Frame[i] then
					    Keep_Frame[i] = Create_Header(Basic_UI.Destroy["摧毁列表"],"TOPLEFT",10, (-30 * (i - 1) - 10),ItemList[i].."("..i..")")
					else
					    Keep_Frame[i]:SetPoint("TOPLEFT",10, (-30 * (i - 1) - 10))
						Keep_Frame[i]:SetText(ItemList[i].."("..i..")")
						Keep_Frame[i]:Show()
					end
				end
			end

			if #Keep_Frame > #ItemList then
				for i = #ItemList + 1,#Keep_Frame do
					Keep_Frame[i]:Hide()
				end
			end
		end

	    Basic_UI.Destroy.Py = Basic_UI.Destroy.Py - 30
	    local header = Create_Header(Basic_UI.Destroy.frame,"TopLeft",10,Basic_UI.Destroy.Py,Check_UI("摧毁物品 (一行一个)","Destroy Item (one line one item)"))

	    Basic_UI.Destroy["摧毁物品"] = Create_Scroll_Edit(Basic_UI.Destroy.frame,"TopLeft",10,Basic_UI.Destroy.Py - 20,Check_UI("铜矿\n银矿\n铁矿石","item1\nitem2\nitem3"),260,300)

		Basic_UI.Destroy["摧毁物品"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data["摧毁物品"] = Basic_UI.Destroy["摧毁物品"]:GetText()
			Update_List()
		end)
        if Easy_Data["摧毁物品"] == nil then
            Easy_Data["摧毁物品"] = Check_UI("铜矿\n银矿\n铁矿石","item1\nitem2\nitem3")
        else
            Basic_UI.Destroy["摧毁物品"]:SetText(Easy_Data["摧毁物品"])
        end

		local header = Create_Header(Basic_UI.Destroy.frame,"TopLeft",320,Basic_UI.Destroy.Py,Check_UI("摧毁物品列表","Destroy Item List"))

		Basic_UI.Destroy["摧毁列表"] = Create_Scroll(Basic_UI.Destroy.frame,"TopLeft",320,Basic_UI.Destroy.Py - 20,260,300)

		Basic_UI.Destroy.Py = Basic_UI.Destroy.Py - 300

		Update_List()
	end
	Destroy_Item()
end

local function Create_Disenchant_UI() -- 分解UI
    Basic_UI.Disenchant = {}
	Basic_UI.Disenchant.Py = -10
	local function Frame_Create()
		Basic_UI.Disenchant.frame = CreateFrame('frame',"Basic_UI.Disenchant.frame",Basic_UI.Panel, BackdropTemplateMixin and "BackdropTemplate")
		Basic_UI.Disenchant.frame:SetPoint("TopLeft",0,0)
		Basic_UI.Disenchant.frame:SetSize(590,480)
		Basic_UI.Disenchant.frame:SetBackdrop({_,edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",_,_,edgeSize = 15,_})
		Basic_UI.Disenchant.frame:Hide()
		Basic_UI.Disenchant.frame:SetBackdropColor(0.1,0.1,0.1,0)
		Basic_UI.Disenchant.frame:SetBackdropBorderColor(0.1,0.1,0.1,0)
		Basic_UI.Disenchant.frame:SetFrameStrata('TOOLTIP')
	end

	local function Button_Create()
	    UI_Button_Py = UI_Button_Py - 30
		Basic_UI.Disenchant.button = Create_Page_Button(Basic_UI["选项列表"], "Top",0,UI_Button_Py,Check_UI("分解","disenchant"))
		Basic_UI.Disenchant.button:SetSize(130,20)
		Basic_UI.Disenchant.button:SetScript("OnClick", function(self)
			All_Buttons_Hide()
            Basic_UI.Disenchant.frame:Show()
			Basic_UI.Disenchant.button:SetBackdropColor(245/255 , 245/255, 220/255, 0.4)
		end)
        Config_UI[#Config_UI + 1] = function() Basic_UI.Disenchant.frame:Hide() Basic_UI.Disenchant.button:SetBackdropColor(0,0,0,0) end
	end

	local function Resolve_Set_UI() -- 分解
		Basic_UI.Disenchant["需要分解"] = Create_Check_Button(Basic_UI.Disenchant.frame, "TOPLEFT",10, Basic_UI.Disenchant.Py, Check_UI("需要分解","Need Disenchant"))
		Basic_UI.Disenchant["需要分解"]:SetScript("OnClick", function(self)
			if Basic_UI.Disenchant["需要分解"]:GetChecked() then
				Easy_Data["需要分解"] = true
			elseif not Basic_UI.Disenchant["需要分解"]:GetChecked() then
				Easy_Data["需要分解"] = false
			end
		end)
		if Easy_Data["需要分解"] ~= nil then
			if Easy_Data["需要分解"] then
				Basic_UI.Disenchant["需要分解"]:SetChecked(true)
			else
				Basic_UI.Disenchant["需要分解"]:SetChecked(false)
			end
		else
			Easy_Data["需要分解"] = false
			Basic_UI.Disenchant["需要分解"]:SetChecked(false)
		end

		Basic_UI.Disenchant.Py = Basic_UI.Disenchant.Py - 30
		Basic_UI.Disenchant["分解黑名单"] = Create_Check_Button(Basic_UI.Disenchant.frame, "TOPLEFT",10, Basic_UI.Disenchant.Py, Check_UI("添加不可分解物品进入黑名单","Blacklist Un-Disenchant items"))
		Basic_UI.Disenchant["分解黑名单"]:SetScript("OnClick", function(self)
			if Basic_UI.Disenchant["分解黑名单"]:GetChecked() then
				Easy_Data["分解黑名单"] = true
			elseif not Basic_UI.Disenchant["分解黑名单"]:GetChecked() then
				Easy_Data["分解黑名单"] = false
			end
		end)
		if Easy_Data["分解黑名单"] ~= nil then
			if Easy_Data["分解黑名单"] then
				Basic_UI.Disenchant["分解黑名单"]:SetChecked(true)
			else
				Basic_UI.Disenchant["分解黑名单"]:SetChecked(false)
			end
		else
			Easy_Data["分解黑名单"] = true
			Basic_UI.Disenchant["分解黑名单"]:SetChecked(true)
		end

		Basic_UI.Disenchant.Py = Basic_UI.Disenchant.Py - 30
		Basic_UI.Disenchant["清理分解黑名单"] = Create_Check_Button(Basic_UI.Disenchant.frame, "TOPLEFT",10, Basic_UI.Disenchant.Py, Check_UI("自动清理分解黑名单","Auto Reset Disenchant Blacklist"))
		Basic_UI.Disenchant["清理分解黑名单"]:SetScript("OnClick", function(self)
			if Basic_UI.Disenchant["清理分解黑名单"]:GetChecked() then
				Easy_Data["清理分解黑名单"] = true
			elseif not Basic_UI.Disenchant["清理分解黑名单"]:GetChecked() then
				Easy_Data["清理分解黑名单"] = false
			end
		end)
		if Easy_Data["清理分解黑名单"] ~= nil then
			if Easy_Data["清理分解黑名单"] then
				Basic_UI.Disenchant["清理分解黑名单"]:SetChecked(true)
			else
				Basic_UI.Disenchant["清理分解黑名单"]:SetChecked(false)
			end
		else
			Easy_Data["清理分解黑名单"] = false
			Basic_UI.Disenchant["清理分解黑名单"]:SetChecked(false)
		end
	end

	local function Disenchant_Color_UI() -- 分解颜色
	    Basic_UI.Disenchant.Py = Basic_UI.Disenchant.Py - 30
	    local Header1 = Create_Header(Basic_UI.Disenchant.frame,"TOPLEFT",10, Basic_UI.Disenchant.Py,Check_UI("分解颜色","Disenchant Item Color")) 

		Basic_UI.Disenchant.Py = Basic_UI.Disenchant.Py - 20
		Basic_UI.Disenchant["分解灰色"] = Create_Check_Button(Basic_UI.Disenchant.frame, "TOPLEFT",10, Basic_UI.Disenchant.Py, Check_UI("灰色","Grey"))
		Basic_UI.Disenchant["分解灰色"]:SetScript("OnClick", function(self)
			if Basic_UI.Disenchant["分解灰色"]:GetChecked() then
				Easy_Data["分解灰色"] = true
			elseif not Basic_UI.Disenchant["分解灰色"]:GetChecked() then
				Easy_Data["分解灰色"] = false
			end
		end)
		if Easy_Data["分解灰色"] ~= nil then
			if Easy_Data["分解灰色"] then
				Basic_UI.Disenchant["分解灰色"]:SetChecked(true)
			else
				Basic_UI.Disenchant["分解灰色"]:SetChecked(false)
			end
		else
			Easy_Data["分解灰色"] = true
			Basic_UI.Disenchant["分解灰色"]:SetChecked(true)
		end

		Basic_UI.Disenchant["分解白色"] = Create_Check_Button(Basic_UI.Disenchant.frame, "TOPLEFT",80, Basic_UI.Disenchant.Py, Check_UI("白色","White"))
		Basic_UI.Disenchant["分解白色"]:SetScript("OnClick", function(self)
			if Basic_UI.Disenchant["分解白色"]:GetChecked() then
				Easy_Data["分解白色"] = true
			elseif not Basic_UI.Disenchant["分解白色"]:GetChecked() then
				Easy_Data["分解白色"] = false
			end
		end)
		if Easy_Data["分解白色"] ~= nil then
			if Easy_Data["分解白色"] then
				Basic_UI.Disenchant["分解白色"]:SetChecked(true)
			else
				Basic_UI.Disenchant["分解白色"]:SetChecked(false)
			end
		else
			Easy_Data["分解白色"] = true
			Basic_UI.Disenchant["分解白色"]:SetChecked(true)
		end

		Basic_UI.Disenchant["分解绿色"] = Create_Check_Button(Basic_UI.Disenchant.frame, "TOPLEFT",150, Basic_UI.Disenchant.Py, Check_UI("绿色","Green"))
		Basic_UI.Disenchant["分解绿色"]:SetScript("OnClick", function(self)
			if Basic_UI.Disenchant["分解绿色"]:GetChecked() then
				Easy_Data["分解绿色"] = true
			elseif not Basic_UI.Disenchant["分解绿色"]:GetChecked() then
				Easy_Data["分解绿色"] = false
			end
		end)
		if Easy_Data["分解绿色"] ~= nil then
			if Easy_Data["分解绿色"] then
				Basic_UI.Disenchant["分解绿色"]:SetChecked(true)
			else
				Basic_UI.Disenchant["分解绿色"]:SetChecked(false)
			end
		else
			Easy_Data["分解绿色"] = true
			Basic_UI.Disenchant["分解绿色"]:SetChecked(true)
		end

		Basic_UI.Disenchant["分解蓝色"] = Create_Check_Button(Basic_UI.Disenchant.frame, "TOPLEFT",220, Basic_UI.Disenchant.Py, Check_UI("蓝色","Blue"))
		Basic_UI.Disenchant["分解蓝色"]:SetScript("OnClick", function(self)
			if Basic_UI.Disenchant["分解蓝色"]:GetChecked() then
				Easy_Data["分解蓝色"] = true
			elseif not Basic_UI.Disenchant["分解蓝色"]:GetChecked() then
				Easy_Data["分解蓝色"] = false
			end
		end)
		if Easy_Data["分解蓝色"] ~= nil then
			if Easy_Data["分解蓝色"] then
				Basic_UI.Disenchant["分解蓝色"]:SetChecked(true)
			else
				Basic_UI.Disenchant["分解蓝色"]:SetChecked(false)
			end
		else
			Easy_Data["分解蓝色"] = true
			Basic_UI.Disenchant["分解蓝色"]:SetChecked(true)
		end

		Basic_UI.Disenchant["分解紫色"] = Create_Check_Button(Basic_UI.Disenchant.frame, "TOPLEFT",290, Basic_UI.Disenchant.Py, Check_UI("紫色","Purple"))
		Basic_UI.Disenchant["分解紫色"]:SetScript("OnClick", function(self)
			if Basic_UI.Disenchant["分解紫色"]:GetChecked() then
				Easy_Data["分解紫色"] = true
			elseif not Basic_UI.Disenchant["分解紫色"]:GetChecked() then
				Easy_Data["分解紫色"] = false
			end
		end)
		if Easy_Data["分解紫色"] ~= nil then
			if Easy_Data["分解紫色"] then
				Basic_UI.Disenchant["分解紫色"]:SetChecked(true)
			else
				Basic_UI.Disenchant["分解紫色"]:SetChecked(false)
			end
		else
			Easy_Data["分解紫色"] = true
			Basic_UI.Disenchant["分解紫色"]:SetChecked(true)
		end
	end

	local function Disenchant_Item() -- 分解物品
	    local Keep_Frame = {}
	    local function Update_List()
		    local ItemList = string.split(Easy_Data["分解物品"],"\n")
			if #ItemList > 0 then
			    for i = 1,#ItemList do
				    if not Keep_Frame[i] then
					    Keep_Frame[i] = Create_Header(Basic_UI.Disenchant["分解列表"],"TOPLEFT",10, (-30 * (i - 1) - 10),ItemList[i].."("..i..")")
					else
					    Keep_Frame[i]:SetPoint("TOPLEFT",10, (-30 * (i - 1) - 10))
						Keep_Frame[i]:SetText(ItemList[i].."("..i..")")
						Keep_Frame[i]:Show()
					end
				end
			end

			if #Keep_Frame > #ItemList then
				for i = #ItemList + 1,#Keep_Frame do
					Keep_Frame[i]:Hide()
				end
			end
		end

	    Basic_UI.Disenchant.Py = Basic_UI.Disenchant.Py - 30
	    local header = Create_Header(Basic_UI.Disenchant.frame,"TopLeft",10,Basic_UI.Disenchant.Py,Check_UI("分解物品","Disenchant Item"))

	    Basic_UI.Disenchant["分解物品"] = Create_Scroll_Edit(Basic_UI.Disenchant.frame,"TopLeft",10,Basic_UI.Disenchant.Py - 20,Check_Client("铜矿\n银矿\n铁矿石","item1\nitem2\nitem3"),260,300)

		Basic_UI.Disenchant["分解物品"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data["分解物品"] = Basic_UI.Disenchant["分解物品"]:GetText()
			Update_List()
		end)
        if Easy_Data["分解物品"] == nil then
            Easy_Data["分解物品"] = Check_UI("铜矿\n银矿\n铁矿石","item1\nitem2\nitem3")
        else
            Basic_UI.Disenchant["分解物品"]:SetText(Easy_Data["分解物品"])
        end

		Basic_UI.Disenchant["分解列表"] = Create_Scroll(Basic_UI.Disenchant.frame,"TopLeft",320,Basic_UI.Disenchant.Py - 20,260,300)
		Update_List()
	end

	Frame_Create()
	Button_Create()
	Resolve_Set_UI()
	Disenchant_Color_UI()
	Disenchant_Item()
end

local function Create_Clear_UI() -- 运行次数清除UI
    Detail_UI.Custom = {}
	
    Detail_UI.Custom["清空次数"] = Create_Button(Detail_UI.Panel,"TopLeft",10,Detail_UI.Py,Check_UI("清空副本次数","Clear Reset Log"))
	Detail_UI.Custom["清空次数"]:SetSize(190,35)
	Detail_UI.Custom["清空次数"]:SetScript("OnClick", function(self)
		Easy_Data.ResetTimes = {}
		textout(Check_UI("副本重置记录次数清空","Dungeon reset log clear"))
	end)

	Detail_UI.Py = Detail_UI.Py - 35

	Detail_UI.Custom = {}	
    Detail_UI.Custom["卡死按钮"] = Create_Button(Detail_UI.Panel,"TopLeft",10,Detail_UI.Py,Check_UI("卡死返回墓地","Suicide yourself"))
	Detail_UI.Custom["卡死按钮"]:SetSize(190,35)
	Detail_UI.Custom["卡死按钮"]:SetScript("OnClick", function(self)
		Bot_End()
		Try_Stop()

		C_Timer.After(1.5,function()
			awm.Stuck()
		end)
	end)

	Detail_UI.Py = Detail_UI.Py - 5
end

Create_Nav_UI()
Create_Config_UI()
Create_Sell_UI()
Create_Destroy_UI()
Create_Disenchant_UI()
Create_Clear_UI()


-- 脚本启动 暂停
function Bot_Begin()
    Run_Timer = false
	BOT_Frame:SetScript("OnUpdate", MainThread)
	textout(Check_UI("开始工作","Start to work"))

	Run_Timer = false
	Coordinates_Get = false
	Easy_Data.Sever_Map_Calculated = false
	teleport.x,teleport.y,teleport.z = 0,0,0
	teleport.timer = false
	Dead_Repop = GetTime()

    Instance_Name,_,_,_,_,_,_,Instance = GetInstanceInfo()

    if CheckDeadOrNot() then
        Thread.resume(Thread["死亡线程"])

		Thread.Current = Thread["死亡线程"]
    elseif Instance == Dungeon_ID then
        Thread.resume(Thread["副本线程"])

		Thread.Current = Thread["副本线程"]
    else
        Thread.resume(Thread["野外线程"])

		Thread.Current = Thread["野外线程"]
    end

    CD['Second Loop']:SetScript('OnUpdate',T_Func["第二线程"])
end
function Bot_End()
    BOT_Frame:SetScript("OnUpdate", function() end)
	textout(Check_UI("停止工作","Stop to work"))

	if teleport.timer then
	    PlayWinSound(awm.GetExeDirectory()..[[\Pause.wav]])
	end

    Thread.frame:SetScript('OnUpdate', function()
        if Thread["野外线程"] and coroutine.status(Thread["野外线程"]) == "running" then
            Thread.stop()
            return
        end

        if Thread["副本线程"] and coroutine.status(Thread["副本线程"]) == "running" then
            Thread.stop()
            return
        end

        if Thread["死亡线程"] and coroutine.status(Thread["死亡线程"]) == "running" then
            Thread.stop()
            return
        end

        Thread.frame:SetScript('OnUpdate', function() end)
    end)

    CD['Second Loop']:SetScript('OnUpdate',function() end)
end

Bot_Begin()

