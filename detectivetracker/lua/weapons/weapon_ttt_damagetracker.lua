--Basics
SWEP.PrintName = "Gunpowder Finder"
SWEP.Instructions = "Left mouse to check if a player has been shot by a player this round"
--Creator
SWEP.Author = "Angus"
SWEP.Contact = "https://www.steamcommunity.com/profiles/76561198065084199"
--
SWEP.Spawnable = true
SWEP.AdminOnly = false
-- Always derive from weapon_tttbase.
SWEP.Base = "weapon_tttbase"
SWEP.Kind = WEAPON_EQUIP1
--Primary click
SWEP.Primary.ClipSize = 1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

--secondary click
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1

--TODO: change the model
SWEP.ViewModel = "models/weapons/v_pistol.mdl"
SWEP.WorldModel = "models/weapons/w_pistol.mdl"
SWEP.ShootSound = Sound("buttons/button18.wav")
SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Slot = 6
SWEP.SlotPos = 2
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true
SWEP.AutoSpawnable = false

SWEP.CanBuy = {ROLE_DETECTIVE}

SWEP.LimitedStock = true
SWEP.AllowDrop = true

SWEP.EquipMenuData = {
	type = "Weapon",
	desc = "This is a test lalala"
}

function PlayerWithinBounds(ply,otherPly, dist)
	return ply:GetPos():DistToSqr(otherPly:GetPos()) < (dist * dist)
end



function SWEP:Initialize()
	if SERVER then
		trackedply = nil
		trackerply = nil
		attackers = {}
		table.Empty(attackers)
	end
end


function SWEP:PrimaryAttack()
	if (self:CanPrimaryAttack()) then
		self:SetNextPrimaryFire(CurTime() + 1)
		self:TakePrimaryAmmo(1)
		self:EmitSound(self.ShootSound)

		if SERVER then
			--was the detective able to hit the tracker?
			hook.Add("EntityTakeDamage", "hitDetectiveCheck", function(target, dmginfo)
				if (IsValid(target) and target:IsPlayer() and dmginfo:IsBulletDamage() and dmginfo:GetAttacker():GetActiveWeapon() == self) then
					dmginfo:GetAttacker():PrintMessage(HUD_PRINTTALK, "Tracker added to: " .. target:GetName())
					trackedply = target
					trackerply = dmginfo:GetAttacker()
				end
			end)
			
			self:ShootBullet(0, 1, 0.02)
			timer.Simple(1, function() 
				if (trackedply ~= nil) then
					table.Empty(attackers)
					hook.Add("EntityTakeDamage","trackuser", function(trackTarget,trackinfo)
					if (trackTarget == trackedply and IsPlayer(trackinfo:GetAttacker()) and trackinfo:GetAttacker() ~= target and not table.HasValue(attackers, trackinfo:GetAttacker())) then
						table.insert(attackers, trackinfo:GetAttacker())	
					end
					end)
				end 
			end)

			timer.Simple(1, function()
				hook.Remove("EntityTakeDamage", "hitDetectiveCheck")
			end)

		end
	end
end

function SWEP:SecondaryAttack()
	if SERVER and (trackedply ~= nil and trackerply ~= nil) and (PlayerWithinBounds(trackerply,trackedply,100)) then
		if (table.IsEmpty(attackers)) then
			trackerply:PrintMessage(HUD_PRINTTALK, "This player didn't receive damage from other players")
		else
			for i,k in pairs (attackers) do
				trackerply:PrintMessage(HUD_PRINTTALK, "The player received damage from " .. k:GetName())
			end
		end
	end
end
