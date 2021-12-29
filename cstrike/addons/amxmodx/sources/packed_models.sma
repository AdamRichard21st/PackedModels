#include < amxmodx >
#include < fakemeta >
#include < hamsandwich >

#define MAX_CWEAPONBOX_ITEMS    6

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


public OnWeaponBoxSpawn(weaponbox)
{
    if (!pev_valid(weaponbox))
    {
        return;
    }

    SetWeaponBoxStatus(weaponbox, WeaponBoxSpawned);
}


public OnSetModel(entity, const model[])
{
    if (!pev_valid(entity) || GetWeaponBoxStatus(entity) != WeaponBoxSpawned)
    {
        return FMRES_IGNORED;
    }

    for (new i = 0; i < MAX_CWEAPONBOX_ITEMS; i++)
    {
        new weapon = get_ent_data_entity(entity, "CWeaponBox", "m_rgpPlayerItems", i);

        if (pev_valid(weapon) != 2)
        {
            continue;
        }

        new weaponId = get_ent_data(weapon, "CBasePlayerItem", "m_iId");

        engfunc(EngFunc_SetModel, entity, PACKED_MODELS_FILE);
        set_pev(entity, pev_body, weaponId);
        set_pev(entity, pev_sequence, ANIM_WEAPON_WORLD);

        SetWeaponBoxStatus(entity, WeaponBoxModelChanged);

        return FMRES_SUPERCEDE;
    }

    return FMRES_IGNORED;
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


SetWeaponBoxStatus(weaponbox, WeaponBoxStatus:status)
{
    set_pev(weaponbox, pev_euser1, _:status);
}


WeaponBoxStatus:GetWeaponBoxStatus(weaponbox)
{
    return WeaponBoxStatus:pev(weaponbox, pev_euser1);
}