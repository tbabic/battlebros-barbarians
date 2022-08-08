this.hm_barbarian_scenario <- this.inherit("scripts/scenarios/world/starting_scenario", {
	m = {},
	function create()
	{
		this.m.ID = "scenario.hm_barbarians";
		this.m.Name = "Barbarians";
		this.m.Description = "[p=c][img]gfx/ui/events/event_135.png[/img][/p][p]This is a new barbarians origin[/p]";
		this.m.Difficulty = 2;
		this.m.Order = 60;
	}

	function isValid()
	{
		return this.Const.DLC.Wildmen;
	}
	
	

	function onSpawnAssets()
	{
	
		
		
		this.World.Assets.m.BusinessReputation = -50;
		this.World.Assets.m.MoralReputation = -30;
		this.World.Assets.getStash().add(this.new("scripts/items/supplies/goat_cheese_item"));
		this.World.Assets.getStash().add(this.new("scripts/items/supplies/smoked_ham_item"));
		this.World.Assets.m.Money = this.World.Assets.m.Money / 2;
		this.World.Assets.m.Ammo = this.World.Assets.m.Ammo / 2;
	}

	function onSpawnPlayer()
	{
		local randomVillage;
		local northernmostY = 0;

		for( local i = 0; i != this.World.EntityManager.getSettlements().len(); i = ++i )
		{
			local v = this.World.EntityManager.getSettlements()[i];

			if (v.getTile().SquareCoords.Y > northernmostY && !v.isMilitary() && !v.isIsolatedFromRoads() && v.getSize() <= 2)
			{
				northernmostY = v.getTile().SquareCoords.Y;
				randomVillage = v;
			}
		}

		randomVillage.setLastSpawnTimeToNow();
		local randomVillageTile = randomVillage.getTile();
		local navSettings = this.World.getNavigator().createSettings();
		navSettings.ActionPointCosts = this.Const.World.TerrainTypeNavCost_Flat;

		do
		{
			local x = this.Math.rand(this.Math.max(2, randomVillageTile.SquareCoords.X - 2), this.Math.min(this.Const.World.Settings.SizeX - 2, randomVillageTile.SquareCoords.X + 2));
			local y = this.Math.rand(this.Math.max(2, randomVillageTile.SquareCoords.Y - 2), this.Math.min(this.Const.World.Settings.SizeY - 2, randomVillageTile.SquareCoords.Y + 2));

			if (!this.World.isValidTileSquare(x, y))
			{
			}
			else
			{
				local tile = this.World.getTileSquare(x, y);

				if (tile.Type == this.Const.World.TerrainType.Ocean || tile.Type == this.Const.World.TerrainType.Shore || tile.IsOccupied)
				{
				}
				else if (tile.getDistanceTo(randomVillageTile) <= 1)
				{
				}
				else
				{
					local path = this.World.getNavigator().findPath(tile, randomVillageTile, navSettings, 0);

					if (!path.isEmpty())
					{
						randomVillageTile = tile;
						break;
					}
				}
			}
		}
		while (1);

		local attachedLocations = randomVillage.getAttachedLocations();
		local closest;
		local dist = 99999;

		foreach( a in attachedLocations )
		{
			if (a.getTile().getDistanceTo(randomVillageTile) < dist)
			{
				dist = a.getTile().getDistanceTo(randomVillageTile);
				closest = a;
			}
		}
		
		local nobles = this.World.FactionManager.getFactionsOfType(this.Const.FactionType.NobleHouse);
		local houses = [];

		foreach( n in nobles )
		{
			local closest;
			local dist = 9999;

			foreach( s in n.getSettlements() )
			{
				local d = s.getTile().getDistanceTo(randomVillageTile);

				if (d < dist)
				{
					dist = d;
					closest = s;
				}
			}

			houses.push({
				Faction = n,
				Dist = dist
			});
		}

		houses.sort(function ( _a, _b )
		{
			if (_a.Dist > _b.Dist)
			{
				return 1;
			}
			else if (_a.Dist < _b.Dist)
			{
				return -1;
			}

			return 0;
		});

		for( local i = 1; i < 3; i = ++i )
		{
			houses[i].Faction.addPlayerRelation(-100.0, "You are considered outlaws and barbarians");
		}

		houses[1].Faction.addPlayerRelation(18.0);
		houses[0].Faction.addPlayerRelation(-10.0, "You are considered untrustworthy");
		this.World.State.m.Player = this.World.spawnEntity("scripts/entity/world/player_party", randomVillageTile.Coords.X, randomVillageTile.Coords.Y);
		this.World.Assets.updateLook(5);
		this.World.getCamera().setPos(this.World.State.m.Player.getPos());
		this.Time.scheduleEvent(this.TimeUnit.Real, 1000, function ( _tag )
		{
			this.Music.setTrackList([
				"music/barbarians_02.ogg"
			], this.Const.Music.CrossFadeTime);
			this.World.Events.fire("event.fated_barbarian_scenario_intro");
		}, null);
	}
	
	function onUpdateHiringRoster( _roster )
	{
		local garbage = [];
		local bros = _roster.getAll();

		foreach( i, bro in bros )
		{
			if (bro.getBackground().isNoble())
			{
				garbage.push(bro);
			}
		}

		foreach( g in garbage )
		{
			_roster.remove(g);
		}
	}
	
	
	function onInit()
	{
		this.World.Assets.m.BrothersMax = 12;
	}
	
	function onCombatFinished()
	{
		local roster = this.World.getPlayerRoster().getAll();

		foreach( bro in roster )
		{
			if (bro.getFlags().get("IsPlayerCharacter"))
			{
				return true;
			}
		}

		return false;
	}
	

});

