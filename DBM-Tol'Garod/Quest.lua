local mod	= DBM:NewMod("Quest", "DBM-Tol'Garod")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20210501000000")
mod:SetCreatureID(70010)

mod:RegisterCombat("combat", 70010)

mod:RegisterEvents(
	"SPELL_CAST_START",
	"SPELL_AURA_APPLIED",
	"SPELL_AURA_REMOVED",
	"SPELL_SUMMON",
	"UNIT_HEALTH",
    "UNIT_DAID"
)

local WarnRespawn           = mod:NewAnnounce("warnRespawns")

local respArgomot           =(60)
local respKostegriz         =(60)
local respCynami            =(60)
local respTaifyn            =(60)
local respKrok              =(60)
local respShadras           =(60)


function mod:UNIT_DIED(args)
local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 82145 then
                                respArgomot:start()
                                WarnRespawn:Schedule(50)
         if cid == 82142 then
                                respKostegriz:start()
                                WarnRespawn:Schedule(50)
            if cid == 82143 then
                                respCynami:start()
                                WarnRespawn:Schedule(50)
                if cid == 82144 then
                                respTaifyn:start()
                                WarnRespawn:Schedule(50)
                      if cid == 82146 then
                                respKrok:start()
                                WarnRespawn:Schedule(50)
                             if cid == 82141 then
                                respShadras:start()
                                WarnRespawn:Schedule(50)
                            end
                        end
                    end
                end
            end
        end
    end

