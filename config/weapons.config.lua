Config.Weapons = {

    -- Add weapon item name
    -- This will append to the list of weapons
    AddonWeapons = { },

    -- Add weapon item name
    -- Weapon equip will check against this list. If it exists, it will not execute
    Blacklisted  = { },

    -- These weapons ignore quality check
    NoDurability = {
        'weapon_stungun',
        'weapon_nightstick',
        'weapon_flashlight',
        'weapon_unarmed'
    },

    -- Modifies damage for weapons
    DamageModifier = {
        -- weapon_pistol = { modifier = 0.1, disableCritical = true }
    },

    -- All weapons have a default of 0.15
    -- You can set custom rates here
    -- Example: weapon_pistol = 0.15
    DurabilityRateOverrides = {
        weapon_pistol = 0.15
    },

    -- This will set a specific ammo amount for a specific weapon
    ForcedAmmoAmount = {
        weapon_fireextinguisher = 4000,
        weapon_petrolcan = 1000
    },

    -- These weapons are considered throwables
    Throwables = {
        'weapon_ball',
        'weapon_bzgas',
        'weapon_flare',
        'weapon_grenade',
        'weapon_molotov',
        'weapon_pipebomb',
        'weapon_proxmine',
        'weapon_smokegrenade',
        'weapon_snowball',
        'weapon_stickybomb'
    },

    -- These weapons should remove 1 of themselves from inventory after use
    Removables = {
        'weapon_stickybomb', 
        'weapon_pipebomb', 
        'weapon_smokegrenade', 
        'weapon_flare', 
        'weapon_proxmine', 
        'weapon_ball', 
        'weapon_molotov', 
        'weapon_grenade', 
        'weapon_bzgas'
    },

    -- Weapons that have animations for equip and disarm
    -- Params: dictionary, animation, duration, enterSpeed, exitSpeed, delayAfter
    Animations = {
        ['weapon_pistol'] = {
            equip  = { 'reaction@intimidation@1h', 'intro', 50, 3.0, 3.0, 1400 },
            disarm = { 'reaction@intimidation@1h', 'outro', 50, 8.0, 3.0, 1400 }
        },

        ['weapon_pistol_mk2'] = {
            equip  = { 'reaction@intimidation@1h', 'intro', 50, 3.0, 3.0, 1400 },
            disarm = { 'reaction@intimidation@1h', 'outro', 50, 8.0, 3.0, 1400 }
        },

        ['weapon_combatpistol'] = {
            equip  = { 'reaction@intimidation@1h', 'intro', 50, 3.0, 3.0, 1400 },
            disarm = { 'reaction@intimidation@1h', 'outro', 50, 8.0, 3.0, 1400 }
        },

        ['weapon_appistol'] = {
            equip  = { 'reaction@intimidation@1h', 'intro', 50, 3.0, 3.0, 1400 },
            disarm = { 'reaction@intimidation@1h', 'outro', 50, 8.0, 3.0, 1400 }
        },

        ['weapon_pistol50'] = {
            equip  = { 'reaction@intimidation@1h', 'intro', 50, 3.0, 3.0, 1400 },
            disarm = { 'reaction@intimidation@1h', 'outro', 50, 8.0, 3.0, 1400 }
        },

        ['weapon_revolver'] = {
            equip  = { 'reaction@intimidation@1h', 'intro', 50, 3.0, 3.0, 1400 },
            disarm = { 'reaction@intimidation@1h', 'outro', 50, 8.0, 3.0, 1400 }
        },

        ['weapon_snspistol'] = {
            equip  = { 'reaction@intimidation@1h', 'intro', 50, 3.0, 3.0, 1400 },
            disarm = { 'reaction@intimidation@1h', 'outro', 50, 8.0, 3.0, 1400 }
        },

        ['weapon_heavypistol'] = {
            equip  = { 'reaction@intimidation@1h', 'intro', 50, 3.0, 3.0, 1400 },
            disarm = { 'reaction@intimidation@1h', 'outro', 50, 8.0, 3.0, 1400 }
        },

        ['weapon_vintagepistol'] = {
            equip  = { 'reaction@intimidation@1h', 'intro', 50, 3.0, 3.0, 1400 },
            disarm = { 'reaction@intimidation@1h', 'outro', 50, 8.0, 3.0, 1400 }
        }
    },

    -- Match ammo type to item name
    -- These need to match the inventory items (These are QB defaults)
    AmmoItems = {
        AMMO_PISTOL = 'pistol_ammo',
        AMMO_RIFLE  = 'rifle_ammo',
        AMMO_SMG = 'smg_ammo',
        AMMO_SHOTGUN = 'shotgun_ammo',
        AMMO_MINIGUN = 'mg_ammo',
        AMMO_MG = 'mg_ammo',
        AMMO_SNIPER = 'snp_ammo',
        AMMO_EMPLAUNCHER = 'emp_ammo'
    },

    -- key is item name, value.item = receive item, value.amount = amount to receive
    AmmoBoxes = {
        pistolammo_box = { item = 'pistol_ammo', amount = 12 },
        rifleammo_box = { item = 'rifle_ammo', amount = 30 },
        smgammo_box = { item = 'smg_ammo', amount = 30 },
        shotgunammo_box = { item = 'shotgun_ammo', amount = 8 },
        mgammo_box = { item = 'mg_ammo', amount = 54 },
        sniperammo_box = { item = 'snp_ammo', amount = 8 },
        emplauncher_box = { item = 'emp_ammo', amount = 6 }
    },

    -- Attachment definitions
    Attachments = {

        clip_attachment = {
            weapon_pistol = 'component_pistol_clip_02',
            weapon_pistol_mk2 = 'component_pistol_mk2_clip_02',
            weapon_combatpistol = 'component_combatpistol_clip_02',
            weapon_appistol = 'component_appistol_clip_02',
            weapon_pistol50 = 'component_pistol50_clip_02',
            weapon_snspistol = 'component_snspistol_clip_02',
            weapon_snspistol_mk2 = 'component_snspistol_mk2_clip_02',
            weapon_heavypistol = 'component_heavypistol_clip_02',
            weapon_vintagepistol = 'component_vintagepistol_clip_02',
            weapon_ceramicpistol = 'component_ceramicpistol_clip_02',
            weapon_microsmg = 'component_microsmg_clip_02',
            weapon_smg = 'component_smg_clip_02',
            weapon_assaultsmg = 'component_assaultsmg_clip_02',
            weapon_minismg = 'component_minismg_clip_02',
            weapon_smg_mk2 = 'component_smg_mk2_clip_02',
            weapon_machinepistol = 'component_machinepistol_clip_02',
            weapon_combatpdw = 'component_combatpdw_clip_02',
            weapon_assaultshotgun = 'component_assaultshotgun_clip_02',
            weapon_heavyshotgun = 'component_heavyshotgun_clip_02',
            weapon_assaultrifle = 'component_assaultrifle_clip_02',
            weapon_carbinerifle = 'component_carbinerifle_clip_02',
            weapon_advancedrifle = 'component_advancedrifle_clip_02',
            weapon_specialcarbine = 'component_specialcarbine_clip_02',
            weapon_bullpuprifle = 'component_bullpuprifle_clip_02',
            weapon_bullpuprifle_mk2 = 'component_bullpuprifle_mk2_clip_02',
            weapon_specialcarbine_mk2 = 'component_specialcarbine_mk2_clip_02',
            weapon_assaultrifle_mk2 = 'component_assaultrifle_mk2_clip_02',
            weapon_carbinerifle_mk2 = 'component_carbinerifle_mk2_clip_02',
            weapon_compactrifle = 'component_compactrifle_clip_02',
            weapon_militaryrifle = 'component_militaryrifle_clip_02',
            weapon_heavyrifle = 'component_heavyrifle_clip_02',
            weapon_mg = 'component_mg_clip_02',
            weapon_combatmg = 'component_combatmg_clip_02',
            weapon_combatmg_mk2 = 'component_combatmg_mk2_clip_02',
            weapon_gusenberg = 'component_gusenberg_clip_02',
            weapon_marksmanrifle = 'component_marksmanrifle_clip_02',
            weapon_marksmanrifle_mk2 = 'component_marksmanrifle_mk2_clip_02',
            weapon_heavysniper_mk2 = 'component_heavysniper_mk2_clip_02',
        },

        drum_attachment = {
            weapon_smg = 'component_smg_clip_03',
            weapon_machinepistol = 'component_machinepistol_clip_03',
            weapon_combatpdw = 'component_combatpdw_clip_03',
            weapon_heavyshotgun = 'component_heavyshotgun_clip_03',
            weapon_assaultrifle = 'component_assaultrifle_clip_03',
            weapon_carbinerifle = 'component_carbinerifle_clip_03',
            weapon_specialcarbine = 'component_specialcarbine_clip_03',
            weapon_compactrifle = 'component_compactrifle_clip_03',
        },

        flashlight_attachment = {
            weapon_pistol = 'component_at_pi_flsh',
            weapon_pistol_mk2 = 'component_at_pi_flsh_02',
            weapon_combatpistol = 'component_at_pi_flsh',
            weapon_appistol = 'component_at_pi_flsh',
            weapon_pistol50 = 'component_at_pi_flsh',
            weapon_heavypistol = 'component_at_pi_flsh',
            weapon_snspistol_mk2 = 'component_at_pi_flsh_03',
            weapon_revolver_mk2 = 'component_at_pi_flsh',
            weapon_microsmg = 'component_at_pi_flsh',
            weapon_smg = 'component_at_ar_flsh',
            weapon_assaultsmg = 'component_at_ar_flsh',
            weapon_smg_mk2 = 'component_at_ar_flsh',
            weapon_combatpdw = 'component_at_ar_flsh',
            weapon_pumpshotgun = 'component_at_ar_flsh',
            weapon_assaultshotgun = 'component_at_ar_flsh',
            weapon_bullpupshotgun = 'component_at_ar_flsh',
            weapon_pumpshotgun_mk2 = 'component_at_ar_flsh',
            weapon_heavyshotgun = 'component_at_ar_flsh',
            weapon_combatshotgun = 'component_at_ar_flsh',
            weapon_assaultrifle = 'component_at_ar_flsh',
            weapon_carbinerifle = 'component_at_ar_flsh',
            weapon_advancedrifle = 'component_at_ar_flsh',
            weapon_specialcarbine = 'component_at_ar_flsh',
            weapon_bullpuprifle = 'component_at_ar_flsh',
            weapon_bullpuprifle_mk2 = 'component_at_ar_flsh',
            weapon_specialcarbine_mk2 = 'component_at_ar_flsh',
            weapon_assaultrifle_mk2 = 'component_at_ar_flsh',
            weapon_carbinerifle_mk2 = 'component_at_ar_flsh',
            weapon_militaryrifle = 'component_at_ar_flsh',
            weapon_heavyrifle = 'component_at_ar_flsh',
            weapon_marksmanrifle = 'component_at_ar_flsh',
            weapon_marksmanrifle_mk2 = 'component_at_ar_flsh',
            weapon_grenadelauncher = 'component_at_ar_flsh',
        },

        suppressor_attachment = {
            weapon_pistol = 'component_at_pi_supp_02',
            weapon_pistol_mk2 = 'component_at_pi_supp_02',
            weapon_combatpistol = 'component_at_pi_supp',
            weapon_appistol = 'component_at_pi_supp',
            weapon_pistol50 = 'component_at_ar_supp_02',
            weapon_heavypistol = 'component_at_pi_supp',
            weapon_snspistol_mk2 = 'component_at_pi_supp_02',
            weapon_vintagepistol = 'component_at_pi_supp',
            weapon_ceramicpistol = 'component_ceramicpistol_supp',
            weapon_microsmg = 'component_at_ar_supp_02',
            weapon_smg = 'component_at_pi_supp',
            weapon_assaultsmg = 'component_at_ar_supp_02',
            weapon_smg_mk2 = 'component_at_pi_supp',
            weapon_machinepistol = 'component_at_pi_supp',
            weapon_pumpshotgun = 'component_at_sr_supp',
            weapon_assaultshotgun = 'component_at_ar_supp',
            weapon_bullpupshotgun = 'component_at_ar_supp_02',
            weapon_pumpshotgun_mk2 = 'component_at_sr_supp_03',
            weapon_heavyshotgun = 'component_at_ar_supp_02',
            weapon_combatshotgun = 'component_at_ar_supp',
            weapon_assaultrifle = 'component_at_ar_supp_02',
            weapon_carbinerifle = 'component_at_ar_supp',
            weapon_advancedrifle = 'component_at_ar_supp',
            weapon_specialcarbine = 'component_at_ar_supp_02',
            weapon_bullpuprifle = 'component_at_ar_supp',
            weapon_bullpuprifle_mk2 = 'component_at_ar_supp',
            weapon_specialcarbine_mk2 = 'component_at_ar_supp_02',
            weapon_assaultrifle_mk2 = 'component_at_ar_supp_02',
            weapon_carbinerifle_mk2 = 'component_at_ar_supp',
            weapon_militaryrifle = 'component_at_ar_supp',
            weapon_heavyrifle = 'component_at_ar_supp',
            weapon_sniperrifle = 'component_at_ar_supp_02',
            weapon_marksmanrifle = 'component_at_ar_supp',
            weapon_marksmanrifle_mk2 = 'component_at_ar_supp',
            weapon_heavysniper_mk2 = 'component_at_sr_supp_03',
        },

        smallscope_attachment = {
            weapon_pistol_mk2 = 'component_at_pi_rail',
            weapon_snspistol_mk2 = 'component_at_pi_rail_02',
            weapon_microsmg = 'component_at_scope_macro',
            weapon_smg = 'component_at_scope_macro_02',
            weapon_assaultsmg = 'component_at_scope_macro',
            weapon_combatpdw = 'component_at_scope_small',
            weapon_assaultrifle = 'component_at_scope_macro',
            weapon_bullpuprifle = 'component_at_scope_small',
            weapon_militaryrifle = 'component_at_scope_small',
            weapon_mg = 'component_at_scope_small_02',
            weapon_revolver_mk2 = 'component_at_scope_macro_mk2',
            weapon_smg_mk2 = 'component_at_scope_macro_02_smg_mk2',
            weapon_pumpshotgun_mk2 = 'component_at_scope_macro_mk2',
            weapon_bullpuprifle_mk2 = 'component_at_scope_macro_02_mk2',
            weapon_specialcarbine_mk2 = 'component_at_scope_macro_mk2',
            weapon_assaultrifle_mk2 = 'component_at_scope_macro_mk2',
            weapon_carbinerifle_mk2 = 'component_at_scope_macro_mk2',
            weapon_advancedrifle = 'component_at_scope_small',
            weapon_grenadelauncher = 'component_at_scope_small',
        },

        medscope_attachment = {
            weapon_smg_mk2 = 'component_at_scope_small_smg_mk2',
            weapon_pumpshotgun_mk2 = 'component_at_scope_small_mk2',
            weapon_bullpuprifle_mk2 = 'component_at_scope_small_mk2',
            weapon_combatmg_mk2 = 'component_at_scope_small_mk2',
            weapon_carbinerifle = 'component_at_scope_medium',
            weapon_specialcarbine = 'component_at_scope_medium',
            weapon_combatmg = 'component_at_scope_medium',
            weapon_marksmanrifle_mk2 = 'component_at_scope_medium_mk2',
        },

        largescope_attachment = {
            weapon_sniperrifle = 'component_at_scope_large',
            weapon_marksmanrifle = 'component_at_scope_large_fixed_zoom',
            weapon_heavysniper_mk2 = 'component_at_scope_large_mk2',
        },

        holoscope_attachment = {
            weapon_heavyrevolver_mk2 = 'component_at_sights',
            weapon_smg_mk2 = 'component_at_sights',
            weapon_pumpshotgun_mk2 = 'component_at_sights',
            weapon_bullpuprifle_mk2 = 'component_at_sights',
            weapon_specialcarbine_mk2 = 'component_at_sights',
            weapon_assaultrifle_mk2 = 'component_at_sights',
            weapon_carbinerifle_mk2 = 'component_at_sights',
            weapon_combatmg_mk2 = 'component_at_sights',
            weapon_marksmanrifle_mk2 = 'component_at_sights',
        },

        advscope_attachment = {
            weapon_sniperrifle = 'component_at_scope_max',
            weapon_heavysniper = 'component_at_scope_max',
            weapon_heavysniper_mk2 = 'component_at_scope_max',
        },

        nvscope_attachment = {
            weapon_heavysniper_mk2 = 'component_at_scope_nv',
        },

        thermalscope_attachment = {
            weapon_heavysniper_mk2 = 'component_at_scope_thermal',
        },

        flat_muzzle_brake = {
            weapon_smg_mk2 = 'component_at_muzzle_01',
            weapon_assaultrifle_mk2 = 'component_at_muzzle_01',
            weapon_carbinerifle_mk2 = 'component_at_muzzle_01',
            weapon_specialcarbine_mk2 = 'component_at_muzzle_01',
            weapon_bullpuprifle_mk2 = 'component_at_muzzle_01',
            weapon_combatmg_mk2 = 'component_at_muzzle_01',
            weapon_marksmanrifle_mk2 = 'component_at_muzzle_01',
        },

        tactical_muzzle_brake = {
            weapon_smg_mk2 = 'component_at_muzzle_02',
            weapon_assaultrifle_mk2 = 'component_at_muzzle_02',
            weapon_carbinerifle_mk2 = 'component_at_muzzle_02',
            weapon_specialcarbine_mk2 = 'component_at_muzzle_02',
            weapon_bullpuprifle_mk2 = 'component_at_muzzle_02',
            weapon_combatmg_mk2 = 'component_at_muzzle_02',
            weapon_marksmanrifle_mk2 = 'component_at_muzzle_02',
        },

        fat_end_muzzle_brake = {
            weapon_smg_mk2 = 'component_at_muzzle_03',
            weapon_assaultrifle_mk2 = 'component_at_muzzle_03',
            weapon_carbinerifle_mk2 = 'component_at_muzzle_03',
            weapon_specialcarbine_mk2 = 'component_at_muzzle_03',
            weapon_bullpuprifle_mk2 = 'component_at_muzzle_03',
            weapon_combatmg_mk2 = 'component_at_muzzle_03',
            weapon_marksmanrifle_mk2 = 'component_at_muzzle_03',
        },

        precision_muzzle_brake = {
            weapon_smg_mk2 = 'component_at_muzzle_04',
            weapon_assaultrifle_mk2 = 'component_at_muzzle_04',
            weapon_carbinerifle_mk2 = 'component_at_muzzle_04',
            weapon_specialcarbine_mk2 = 'component_at_muzzle_04',
            weapon_bullpuprifle_mk2 = 'component_at_muzzle_04',
            weapon_combatmg_mk2 = 'component_at_muzzle_04',
            weapon_marksmanrifle_mk2 = 'component_at_muzzle_04',
        },

        heavy_duty_muzzle_brake = {
            weapon_smg_mk2 = 'component_at_muzzle_05',
            weapon_assaultrifle_mk2 = 'component_at_muzzle_05',
            weapon_carbinerifle_mk2 = 'component_at_muzzle_05',
            weapon_specialcarbine_mk2 = 'component_at_muzzle_05',
            weapon_bullpuprifle_mk2 = 'component_at_muzzle_05',
            weapon_combatmg_mk2 = 'component_at_muzzle_05',
            weapon_marksmanrifle_mk2 = 'component_at_muzzle_05',
        },

        slanted_muzzle_brake = {
            weapon_smg_mk2 = 'component_at_muzzle_06',
            weapon_assaultrifle_mk2 = 'component_at_muzzle_06',
            weapon_carbinerifle_mk2 = 'component_at_muzzle_06',
            weapon_specialcarbine_mk2 = 'component_at_muzzle_06',
            weapon_bullpuprifle_mk2 = 'component_at_muzzle_06',
            weapon_combatmg_mk2 = 'component_at_muzzle_06',
            weapon_marksmanrifle_mk2 = 'component_at_muzzle_06',
        },

        split_end_muzzle_brake = {
            weapon_smg_mk2 = 'component_at_muzzle_07',
            weapon_assaultrifle_mk2 = 'component_at_muzzle_07',
            weapon_carbinerifle_mk2 = 'component_at_muzzle_07',
            weapon_specialcarbine_mk2 = 'component_at_muzzle_07',
            weapon_bullpuprifle_mk2 = 'component_at_muzzle_07',
            weapon_combatmg_mk2 = 'component_at_muzzle_07',
            weapon_marksmanrifle_mk2 = 'component_at_muzzle_07',
        },

        squared_muzzle_brake = {
            weapon_pumpshotgun_mk2 = 'component_at_muzzle_08',
            weapon_heavysniper_mk2 = 'component_at_muzzle_08'
        },

        bellend_muzzle_brake = {
            weapon_heavysniper_mk2 = 'component_at_muzzle_09'
        },

        barrel_attachment = {
            weapon_smg_mk2 = 'component_at_sb_barrel_02',
            weapon_bullpuprifle_mk2 = 'component_at_bp_barrel_02',
            weapon_specialcarbine_mk2 = 'component_at_sc_barrel_02',
            weapon_assaultrifle_mk2 = 'component_at_ar_barrel_02',
            weapon_carbinerifle_mk2 = 'component_at_cr_barrel_02',
            weapon_combatmg_mk2 = 'component_at_mg_barrel_02',
            weapon_marksmanrifle_mk2 = 'component_at_mrfl_barrel_02',
            weapon_heavysniper_mk2 = 'component_at_sr_barrel_02',
        },

        grip_attachment = {
            weapon_combatpdw = 'component_at_ar_afgrip',
            weapon_assaultshotgun = 'component_at_ar_afgrip',
            weapon_bullpupshotgun = 'component_at_ar_afgrip',
            weapon_heavyshotgun = 'component_at_ar_afgrip',
            weapon_assaultrifle = 'component_at_ar_afgrip',
            weapon_carbinerifle = 'component_at_ar_afgrip',
            weapon_advancedrifle = 'component_at_ar_afgrip',
            weapon_specialcarbine = 'component_at_ar_afgrip',
            weapon_bullpuprifle = 'component_at_ar_afgrip',
            weapon_bullpuprifle_mk2 = 'component_at_ar_afgrip_02',
            weapon_specialcarbine_mk2 = 'component_at_ar_afgrip_02',
            weapon_assaultrifle_mk2 = 'component_at_ar_afgrip_02',
            weapon_carbinerifle_mk2 = 'component_at_ar_afgrip_02',
            weapon_heavyrifle = 'component_at_ar_afgrip',
            weapon_combatmg = 'component_at_ar_afgrip',
            weapon_combatmg_mk2 = 'component_at_ar_afgrip_02',
            weapon_marksmanrifle = 'component_at_ar_afgrip',
            weapon_marksmanrifle_mk2 = 'component_at_ar_afgrip_02',
            weapon_grenadelauncher = 'component_at_ar_afgrip',
        },

        comp_attachment = {
            weapon_pistol_mk2 = 'component_at_pi_comp',
            weapon_snspistol_mk2 = 'component_at_pi_comp_02',
            weapon_revolver_mk2 = 'component_at_pi_comp_03',
        },

        luxuryfinish_attachment = {
            weapon_pistol = 'component_pistol_varmod_luxe',
            weapon_combatpistol = 'component_combatpistol_varmod_lowrider',
            weapon_appistol = 'component_appistol_varmod_luxe',
            weapon_pistol50 = 'component_pistol50_varmod_luxe',
            weapon_revolver = 'component_revolver_varmod_goon',
            weapon_snspistol = 'component_snspistol_varmod_lowrider',
            weapon_heavypistol = 'component_heavypistol_varmod_luxe',
            weapon_smg = 'component_smg_varmod_luxe',
            weapon_assaultsmg = 'component_assaultsmg_varmod_lowrider',
            weapon_microsmg = 'component_microsmg_varmod_luxe',
            weapon_pumpshotgun = 'component_pumpshotgun_varmod_lowrider',
            weapon_sawnoffshotgun = 'component_sawnoffshotgun_varmod_luxe',
            weapon_assaultrifle = 'component_assaultrifle_varmod_luxe',
            weapon_carbinerifle = 'component_carbinerifle_varmod_luxe',
            weapon_advancedrifle = 'component_advancedrifle_varmod_luxe',
            weapon_specialcarbine = 'component_specialcarbine_varmod_lowrider',
            weapon_bullpuprifle = 'component_bullpuprifle_varmod_low',
            weapon_heavyrifle = 'component_bullpuprifle_varmod_low',
            weapon_mg = 'component_mg_varmod_lowrider',
            weapon_combatmg = 'component_combatmg_varmod_lowrider',
            weapon_sniperrifle = 'component_sniperrifle_varmod_luxe',
            weapon_marksmanrifle = 'component_marksmanrifle_varmod_luxe',
        },

        digicamo_attachment = {
            weapon_snspistol_mk2 = 'component_snspistol_mk2_camo',
            weapon_pistol_mk2 = 'component_pistol_mk2_camo',
            weapon_smg_mk2 = 'component_revolver_mk2_camo',
            weapon_pumpshotgun_mk2 = 'component_pumpshotgun_mk2_camo',
            weapon_bullpuprifle_mk2 = 'component_bullpuprifle_mk2_camo',
            weapon_specialcarbine_mk2 = 'component_specialcarbine_mk2_camo',
            weapon_assaultrifle_mk2 = 'component_assaultrifle_mk2_camo',
            weapon_carbinerifle_mk2 = 'component_carbinerifle_mk2_camo',
            weapon_combatmg_mk2 = 'component_combatmg_mk2_camo',
            weapon_marksmanrifle_mk2 = 'component_marksmanrifle_mk2_camo',
            weapon_heavysniper_mk2 = 'component_heavysniper_mk2_camo',
        },

        brushcamo_attachment = {
            weapon_snspistol_mk2 = 'component_snspistol_mk2_camo_02',
            weapon_pistol_mk2 = 'component_pistol_mk2_camo_02',
            weapon_smg_mk2 = 'component_revolver_mk2_camo_02',
            weapon_pumpshotgun_mk2 = 'component_pumpshotgun_mk2_camo_02',
            weapon_bullpuprifle_mk2 = 'component_bullpuprifle_mk2_camo_02',
            weapon_specialcarbine_mk2 = 'component_specialcarbine_mk2_camo_02',
            weapon_assaultrifle_mk2 = 'component_assaultrifle_mk2_camo_02',
            weapon_carbinerifle_mk2 = 'component_carbinerifle_mk2_camo_02',
            weapon_combatmg_mk2 = 'component_combatmg_mk2_camo_02',
            weapon_marksmanrifle_mk2 = 'component_marksmanrifle_mk2_camo_02',
            weapon_heavysniper_mk2 = 'component_heavysniper_mk2_camo_02',
        },

        woodcamo_attachment = {
            weapon_snspistol_mk2 = 'component_snspistol_mk2_camo_03',
            weapon_pistol_mk2 = 'component_pistol_mk2_camo_03',
            weapon_smg_mk2 = 'component_revolver_mk2_camo_03',
            weapon_pumpshotgun_mk2 = 'component_pumpshotgun_mk2_camo_03',
            weapon_bullpuprifle_mk2 = 'component_bullpuprifle_mk2_camo_03',
            weapon_specialcarbine_mk2 = 'component_specialcarbine_mk2_camo_03',
            weapon_assaultrifle_mk2 = 'component_assaultrifle_mk2_camo_03',
            weapon_carbinerifle_mk2 = 'component_carbinerifle_mk2_camo_03',
            weapon_combatmg_mk2 = 'component_combatmg_mk2_camo_03',
            weapon_marksmanrifle_mk2 = 'component_marksmanrifle_mk2_camo_03',
            weapon_heavysniper_mk2 = 'component_heavysniper_mk2_camo_03',
        },

        skullcamo_attachment = {
            weapon_snspistol_mk2 = 'component_snspistol_mk2_camo_04',
            weapon_pistol_mk2 = 'component_pistol_mk2_camo_04',
            weapon_smg_mk2 = 'component_revolver_mk2_camo_04',
            weapon_pumpshotgun_mk2 = 'component_pumpshotgun_mk2_camo_04',
            weapon_bullpuprifle_mk2 = 'component_bullpuprifle_mk2_camo_04',
            weapon_specialcarbine_mk2 = 'component_specialcarbine_mk2_camo_04',
            weapon_assaultrifle_mk2 = 'component_assaultrifle_mk2_camo_04',
            weapon_carbinerifle_mk2 = 'component_carbinerifle_mk2_camo_04',
            weapon_combatmg_mk2 = 'component_combatmg_mk2_camo_04',
            weapon_marksmanrifle_mk2 = 'component_marksmanrifle_mk2_camo_04',
            weapon_heavysniper_mk2 = 'component_heavysniper_mk2_camo_04',
        },

        sessantacamo_attachment = {
            weapon_snspistol_mk2 = 'component_snspistol_mk2_camo_05',
            weapon_pistol_mk2 = 'component_pistol_mk2_camo_05',
            weapon_smg_mk2 = 'component_revolver_mk2_camo_05',
            weapon_pumpshotgun_mk2 = 'component_pumpshotgun_mk2_camo_05',
            weapon_bullpuprifle_mk2 = 'component_bullpuprifle_mk2_camo_05',
            weapon_specialcarbine_mk2 = 'component_specialcarbine_mk2_camo_05',
            weapon_assaultrifle_mk2 = 'component_assaultrifle_mk2_camo_05',
            weapon_carbinerifle_mk2 = 'component_carbinerifle_mk2_camo_05',
            weapon_combatmg_mk2 = 'component_combatmg_mk2_camo_05',
            weapon_marksmanrifle_mk2 = 'component_marksmanrifle_mk2_camo_05',
            weapon_heavysniper_mk2 = 'component_heavysniper_mk2_camo_05',
        },

        perseuscamo_attachment = {
            weapon_snspistol_mk2 = 'component_snspistol_mk2_camo_06',
            weapon_pistol_mk2 = 'component_pistol_mk2_camo_06',
            weapon_smg_mk2 = 'component_revolver_mk2_camo_06',
            weapon_pumpshotgun_mk2 = 'component_pumpshotgun_mk2_camo_06',
            weapon_bullpuprifle_mk2 = 'component_bullpuprifle_mk2_camo_06',
            weapon_specialcarbine_mk2 = 'component_specialcarbine_mk2_camo_06',
            weapon_assaultrifle_mk2 = 'component_assaultrifle_mk2_camo_06',
            weapon_carbinerifle_mk2 = 'component_carbinerifle_mk2_camo_06',
            weapon_combatmg_mk2 = 'component_combatmg_mk2_camo_06',
            weapon_marksmanrifle_mk2 = 'component_marksmanrifle_mk2_camo_06',
            weapon_heavysniper_mk2 = 'component_heavysniper_mk2_camo_06',
        },

        leopardcamo_attachment = {
            weapon_snspistol_mk2 = 'component_snspistol_mk2_camo_07',
            weapon_pistol_mk2 = 'component_pistol_mk2_camo_07',
            weapon_smg_mk2 = 'component_revolver_mk2_camo_07',
            weapon_pumpshotgun_mk2 = 'component_pumpshotgun_mk2_camo_07',
            weapon_bullpuprifle_mk2 = 'component_bullpuprifle_mk2_camo_07',
            weapon_specialcarbine_mk2 = 'component_specialcarbine_mk2_camo_07',
            weapon_assaultrifle_mk2 = 'component_assaultrifle_mk2_camo_07',
            weapon_carbinerifle_mk2 = 'component_carbinerifle_mk2_camo_07',
            weapon_combatmg_mk2 = 'component_combatmg_mk2_camo_07',
            weapon_marksmanrifle_mk2 = 'component_marksmanrifle_mk2_camo_07',
            weapon_heavysniper_mk2 = 'component_heavysniper_mk2_camo_07',
        },

        zebracamo_attachment = {
            weapon_snspistol_mk2 = 'component_snspistol_mk2_camo_08',
            weapon_pistol_mk2 = 'component_pistol_mk2_camo_08',
            weapon_smg_mk2 = 'component_revolver_mk2_camo_08',
            weapon_pumpshotgun_mk2 = 'component_pumpshotgun_mk2_camo_08',
            weapon_bullpuprifle_mk2 = 'component_bullpuprifle_mk2_camo_08',
            weapon_specialcarbine_mk2 = 'component_specialcarbine_mk2_camo_08',
            weapon_assaultrifle_mk2 = 'component_assaultrifle_mk2_camo_08',
            weapon_carbinerifle_mk2 = 'component_carbinerifle_mk2_camo_08',
            weapon_combatmg_mk2 = 'component_combatmg_mk2_camo_08',
            weapon_marksmanrifle_mk2 = 'component_marksmanrifle_mk2_camo_08',
            weapon_heavysniper_mk2 = 'component_heavysniper_mk2_camo_08',
        },

        geocamo_attachment = {
            weapon_snspistol_mk2 = 'component_snspistol_mk2_camo_09',
            weapon_pistol_mk2 = 'component_pistol_mk2_camo_09',
            weapon_smg_mk2 = 'component_revolver_mk2_camo_09',
            weapon_pumpshotgun_mk2 = 'component_pumpshotgun_mk2_camo_09',
            weapon_bullpuprifle_mk2 = 'component_bullpuprifle_mk2_camo_09',
            weapon_specialcarbine_mk2 = 'component_specialcarbine_mk2_camo_09',
            weapon_assaultrifle_mk2 = 'component_assaultrifle_mk2_camo_09',
            weapon_carbinerifle_mk2 = 'component_carbinerifle_mk2_camo_09',
            weapon_combatmg_mk2 = 'component_combatmg_mk2_camo_09',
            weapon_marksmanrifle_mk2 = 'component_marksmanrifle_mk2_camo_09',
            weapon_heavysniper_mk2 = 'component_heavysniper_mk2_camo_09',
        },

        boomcamo_attachment = {
            weapon_snspistol_mk2 = 'component_snspistol_mk2_camo_10',
            weapon_pistol_mk2 = 'component_pistol_mk2_camo_10',
            weapon_smg_mk2 = 'component_revolver_mk2_camo_10',
            weapon_pumpshotgun_mk2 = 'component_pumpshotgun_mk2_camo_10',
            weapon_bullpuprifle_mk2 = 'component_bullpuprifle_mk2_camo_10',
            weapon_specialcarbine_mk2 = 'component_specialcarbine_mk2_camo_10',
            weapon_assaultrifle_mk2 = 'component_assaultrifle_mk2_camo_10',
            weapon_carbinerifle_mk2 = 'component_carbinerifle_mk2_camo_10',
            weapon_combatmg_mk2 = 'component_combatmg_mk2_camo_10',
            weapon_marksmanrifle_mk2 = 'component_marksmanrifle_mk2_camo_10',
            weapon_heavysniper_mk2 = 'component_heavysniper_mk2_camo_10',
        },

        patriotcamo_attachment = {
            weapon_heavyrifle_mk2 = 'component_revolver_mk2_camo_ind_01',
            weapon_snspistol_mk2 = 'component_snspistol_mk2_camo_ind_01',
            weapon_pistol_mk2 = 'component_pistol_mk2_camo_ind_01',
            weapon_smg_mk2 = 'component_revolver_mk2_camo_ind_01',
            weapon_pumpshotgun_mk2 = 'component_pumpshotgun_mk2_camo_ind_01',
            weapon_bullpuprifle_mk2 = 'component_bullpuprifle_mk2_camo_ind_01',
            weapon_specialcarbine_mk2 = 'component_specialcarbine_mk2_camo_ind_01',
            weapon_assaultrifle_mk2 = 'component_assaultrifle_mk2_camo_ind_01',
            weapon_carbinerifle_mk2 = 'component_carbinerifle_mk2_camo_ind_01',
            weapon_combatmg_mk2 = 'component_combatmg_mk2_camo_ind_01',
            weapon_marksmanrifle_mk2 = 'component_marksmanrifle_mk2_camo_ind_01',
            weapon_heavysniper_mk2 = 'component_heavysniper_mk2_camo_ind_01',
        },
    },

    Recoil = {
        -- Handguns
        weapon_pistol = 0.3,
        weapon_pistol_mk2 = 0.5,
        weapon_combatpistol = 0.2,
        weapon_appistol = 0.3,
        weapon_stungun = 0.1,
        weapon_pistol50 = 0.6,
        weapon_snspistol = 0.2,
        weapon_heavypistol = 0.5,
        weapon_vintagepistol = 0.4,
        weapon_flaregun = 0.9,
        weapon_marksmanpistol = 0.9,
        weapon_revolver = 0.6,
        weapon_revolver_mk2 = 0.6,
        weapon_doubleaction = 0.3,
        weapon_snspistol_mk2 = 0.3,
        weapon_raypistol = 0.3,
        weapon_ceramicpistol = 0.3,
        weapon_navyrevolver = 0.3,
        weapon_gadgetpistol = 0.3,
        weapon_pistolxm3 = 0.4,
    
        -- Submachine Guns
        weapon_microsmg = 0.5,
        weapon_smg = 0.4,
        weapon_smg_mk2 = 0.1,
        weapon_assaultsmg = 0.1,
        weapon_combatpdw = 0.2,
        weapon_machinepistol = 0.3,
        weapon_minismg = 0.1,
        weapon_raycarbine = 0.3,
        weapon_tecpistol = 0.3,
    
        -- Shotguns
        weapon_pumpshotgun = 0.4,
        weapon_sawnoffshotgun = 0.7,
        weapon_assaultshotgun = 0.4,
        weapon_bullpupshotgun = 0.2,
        weapon_musket = 0.7,
        weapon_heavyshotgun = 0.2,
        weapon_dbshotgun = 0.7,
        weapon_autoshotgun = 0.2,
        weapon_pumpshotgun_mk2 = 0.4,
        weapon_combatshotgun = 0.0,
    
        -- Assault Rifles
        weapon_assaultrifle = 0.5,
        weapon_assaultrifle_mk2 = 0.2,
        weapon_carbinerifle = 0.3,
        weapon_carbinerifle_mk2 = 0.1,
        weapon_advancedrifle = 0.1,
        weapon_specialcarbine = 0.2,
        weapon_bullpuprifle = 0.2,
        weapon_compactrifle = 0.3,
        weapon_specialcarbine_mk2 = 0.2,
        weapon_bullpuprifle_mk2 = 0.2,
        weapon_militaryrifle = 0.0,
        weapon_heavyrifle = 0.3,
        weapon_tacticalrifle = 0.2,
    
        -- Light Machine Guns
        weapon_mg = 0.1,
        weapon_combatmg = 0.1,
        weapon_gusenberg = 0.1,
        weapon_combatmg_mk2 = 0.1,
    
        -- Sniper Rifles
        weapon_sniperrifle = 0.5,
        weapon_heavysniper = 0.7,
        weapon_marksmanrifle = 0.3,
        weapon_remotesniper = 1.2,
        weapon_heavysniper_mk2 = 0.6,
        weapon_marksmanrifle_mk2 = 0.3,
        weapon_precisionrifle = 0.3,
    
        -- Heavy Weapons
        weapon_rpg = 0.0,
        weapon_grenadelauncher = 1.0,
        weapon_grenadelauncher_smoke = 1.0,
        weapon_minigun = 0.1,
        weapon_firework = 0.3,
        weapon_railgun = 2.4,
        weapon_hominglauncher = 0.0,
        weapon_compactlauncher = 0.5,
        weapon_rayminigun = 0.3,
    },

    List = {
        'weapon_knife',
        'weapon_nightstick',
        'weapon_bread',
        'weapon_flashlight',
        'weapon_hammer',
        'weapon_bat',
        'weapon_golfclub',
        'weapon_crowbar',
        'weapon_bottle',
        'weapon_dagger',
        'weapon_hatchet',
        'weapon_machete',
        'weapon_switchblade',
        'weapon_battleaxe',
        'weapon_poolcue',
        'weapon_wrench',
        'weapon_pistol',
        'weapon_pistol_mk2',
        'weapon_combatpistol',
        'weapon_appistol',
        'weapon_pistol50',
        'weapon_revolver',
        'weapon_snspistol',
        'weapon_heavypistol',
        'weapon_vintagepistol',
        'weapon_microsmg',
        'weapon_smg',
        'weapon_assaultsmg',
        'weapon_minismg',
        'weapon_machinepistol',
        'weapon_combatpdw',
        'weapon_pumpshotgun',
        'weapon_sawnoffshotgun',
        'weapon_assaultshotgun',
        'weapon_bullpupshotgun',
        'weapon_heavyshotgun',
        'weapon_assaultrifle',
        'weapon_carbinerifle',
        'weapon_advancedrifle',
        'weapon_specialcarbine',
        'weapon_bullpuprifle',
        'weapon_compactrifle',
        'weapon_mg',
        'weapon_combatmg',
        'weapon_gusenberg',
        'weapon_sniperrifle',
        'weapon_heavysniper',
        'weapon_marksmanrifle',
        'weapon_grenadelauncher',
        'weapon_rpg',
        'weapon_stinger',
        'weapon_minigun',
        'weapon_grenade',
        'weapon_stickybomb',
        'weapon_smokegrenade',
        'weapon_bzgas',
        'weapon_molotov',
        'weapon_digiscanner',
        'weapon_firework',
        'weapon_musket',
        'weapon_stungun',
        'weapon_hominglauncher',
        'weapon_proxmine',
        'weapon_flaregun',
        'weapon_marksmanpistol',
        'weapon_railgun',
        'weapon_dbshotgun',
        'weapon_autoshotgun',
        'weapon_compactlauncher',
        'weapon_pipebomb',
        'weapon_doubleaction',
        'weapon_snowball',
        'weapon_pistolxm3',
        'weapon_candycane',
        'weapon_ceramicpistol',
        'weapon_navyrevolver',
        'weapon_gadgetpistol',
        'weapon_pistolxm3',
        'weapon_tecpistol',
        'weapon_heavyrifle',
        'weapon_militaryrifle',
        'weapon_tacticalrifle',
        'weapon_sweepershotgun',
        'weapon_assaultrifle_mk2',
        'weapon_bullpuprifle_mk2',
        'weapon_carbinerifle_mk2',
        'weapon_combatmg_mk2',
        'weapon_heavysniper_mk2',
        'weapon_knuckle',
        'weapon_marksmanrifle_mk2',
        'weapon_precisionrifle',
        'weapon_petrolcan',
        'weapon_pumpshotgun_mk2',
        'weapon_raycarbine',
        'weapon_rayminigun',
        'weapon_raypistol',
        'weapon_revolver_mk2',
        'weapon_smg_mk2',
        'weapon_snspistol_mk2',
        'weapon_specialcarbine_mk2',
        'weapon_stone_hatchet',
        'weapon_fireextinguisher'
    },
    
    Melee = {
        weapon_knife = true,
        weapon_nightstick = true,
        weapon_bread = true,
        weapon_flashlight = true,
        weapon_hammer = true,
        weapon_bat = true,
        weapon_golfclub = true,
        weapon_crowbar = true,
        weapon_bottle = true,
        weapon_dagger = true,
        weapon_hatchet = true,
        weapon_machete = true,
        weapon_switchblade = true,
        weapon_battleaxe = true,
        weapon_poolcue = true,
        weapon_wrench = true,
        weapon_knuckle = true,
        weapon_stone_hatchet = true,
    }
}
