#include < amxmodx >
#include < fakemeta >
#include < hamsandwich >


/**
 * Defines if dropped C4 backpack should be rendered
 * from the packed models file. Values:
 *
 *  true - packed backpack will be rendered
 *  false - default backpack will be rendered
 */
#define C4_BACKPACK_SUPPORT true


#define MAX_CWEAPONBOX_ITEMS    6
#define CSW_BACKPACK            CSW_P90 + 1

#define CUSTOM_CGRENADE_ID      33
#define CUSTOM_CWEAPONBOX_ID    34


enum PackedModelsAnimations
{
    ANIM_WEAPON_PLAYER = 0,
    ANIM_WEAPON_WORLD
}

public const ENTITY_BASE_CLASS[] = "info_target";
public const PACKED_MODELS_FILE[] = "models/weapons.mdl";

public ENTITIES[MAX_PLAYERS + 1];


public plugin_init()
{
    register_plugin("Packed Models", "1.0.0", "AdamRichard21st");

    for (new i = CSW_P228, weaponName[32]; i <= CSW_P90; i++)
    {
        if (get_weaponname(i, weaponName, charsmax(weaponName)))
        {
            RegisterHam(Ham_Item_Deploy, weaponName, "OnWeaponDeploy", .Post = true);
            RegisterHam(Ham_Item_Holster, weaponName, "OnWeaponHolster", .Post = false);
        }
    }

    RegisterHam(Ham_Spawn, "weaponbox", "OnWeaponBoxSpawn", .Post = true);
    RegisterHam(Ham_Spawn, "grenade", "OnGrenadeSpawn", .Post = true);

    register_forward(FM_SetModel, "OnSetModel");

    CreateBaseEntities();
}


public plugin_precache()
{
    precache_model(PACKED_MODELS_FILE);
}


public plugin_end()
{
    DestroyBaseEntities();
}


public OnWeaponDeploy(weapon)
{
    if (pev_valid(weapon) != 2)
    {
        return;
    }

    new owner = get_ent_data_entity(weapon, "CBasePlayerItem", "m_pPlayer");

    if (!is_user_connected(owner) || !ENTITIES[owner])
    {
        return;
    }

    HidePlayerWeapon(owner);

    new weaponId = get_ent_data(weapon, "CBasePlayerItem", "m_iId");

    set_pev(ENTITIES[owner], pev_body, weaponId);
}


public OnWeaponHolster(weapon)
{
    if (pev_valid(weapon) != 2)
    {
        return;
    }

    new owner = pev(weapon, pev_owner);

    if (!is_user_connected(owner) || !ENTITIES[owner])
    {
        return;
    }

    set_pev(ENTITIES[owner], pev_body, CSW_NONE);
}


public OnGrenadeSpawn(grenade)
{
    if (!pev_valid(grenade))
    {
        return;
    }

    SetCustomId(grenade, CUSTOM_CGRENADE_ID);
}


public OnWeaponBoxSpawn(weaponbox)
{
    if (!pev_valid(weaponbox))
    {
        return;
    }

    SetCustomId(weaponbox, CUSTOM_CWEAPONBOX_ID);
}


public OnSetModel(entity, const model[])
{
    if (!pev_valid(entity))
    {
        return FMRES_IGNORED;
    }

    switch (GetCustomId(entity))
    {
        case CUSTOM_CGRENADE_ID:
        {
            return RenderCustomGrenade(entity);
        }
        case CUSTOM_CWEAPONBOX_ID:
        {
            return RenderCustomWeaponBox(entity);
        }
    }

    return FMRES_IGNORED;
}


RenderCustomGrenade(grenade)
{
    new grenadeId = GetCGrenadeType(grenade);

    if (grenadeId == CSW_NONE)
    {
        return FMRES_IGNORED;
    }

    engfunc(EngFunc_SetModel, grenade, PACKED_MODELS_FILE);
    set_pev(grenade, pev_body, grenadeId);
    set_pev(grenade, pev_sequence, ANIM_WEAPON_WORLD);

    return FMRES_SUPERCEDE;
}


RenderCustomWeaponBox(weaponbox)
{
    new bool:validWeapon;
    new weapon;
    
    for (new i = 0; i < MAX_CWEAPONBOX_ITEMS; i++)
    {
        weapon = get_ent_data_entity(weaponbox, "CWeaponBox", "m_rgpPlayerItems", i);

        if (pev_valid(weapon))
        {
            validWeapon = true;
            break;
        }
    }

    if (!validWeapon)
    {
        return FMRES_IGNORED;
    }

    new weaponId = get_ent_data(weapon, "CBasePlayerItem", "m_iId");

    if (weaponId == CSW_C4)
    {
        #if C4_BACKPACK_SUPPORT
            weaponId = CSW_BACKPACK;
        #else
            return FMRES_IGNORED;
        #endif
    }

    engfunc(EngFunc_SetModel, weaponbox, PACKED_MODELS_FILE);
    set_pev(weaponbox, pev_body, weaponId);
    set_pev(weaponbox, pev_sequence, ANIM_WEAPON_WORLD);

    return FMRES_SUPERCEDE;
}


CreateBaseEntities()
{
    new allocatedEntityName = engfunc(EngFunc_AllocString, ENTITY_BASE_CLASS);
    new maxPlayers = get_maxplayers();
    
    for (new i = 1; i <= maxPlayers; i++)
    {
        new entity = engfunc(EngFunc_CreateNamedEntity, allocatedEntityName);

        if (pev_valid(entity))
        {
            set_pev(entity, pev_movetype, MOVETYPE_FOLLOW);
            set_pev(entity, pev_aiment, i);
            set_pev(entity, pev_rendermode, kRenderNormal);
            engfunc(EngFunc_SetModel, entity, PACKED_MODELS_FILE);

            ENTITIES[i] = entity;
        }
    }
}


DestroyBaseEntities()
{
    new maxPlayers = get_maxplayers();

    for (new i = 1; i <= maxPlayers; i++)
    {
        new entity = ENTITIES[i];

        if (pev_valid(entity))
        {
            engfunc(EngFunc_RemoveEntity, entity);
        }
    }
}


HidePlayerWeapon(id)
{
    set_pev(id, pev_weaponmodel2, "");
}


GetCGrenadeType(grenade)
{
    if (get_ent_data(grenade, "CGrenade", "m_bIsC4"))
    {
        return CSW_C4;
    }

    new eventFlags = get_ent_data(grenade, "CGrenade", "m_usEvent");

    if (eventFlags & (1 << 0))
    {
        return CSW_HEGRENADE;
    }

    if (eventFlags & (1 << 1))
    {
        return CSW_SMOKEGRENADE;
    }

    if (!eventFlags)
    {
        return CSW_FLASHBANG;
    }

    return CSW_NONE;
}


SetCustomId(entity, customId)
{
    set_pev(entity, pev_euser1, customId);
}


GetCustomId(entity)
{
    return pev(entity, pev_euser1);
}