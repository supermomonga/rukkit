package com.supermomonga.rukkit;

import java.util.List;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.stream.Stream;
import java.util.stream.Collectors;
import java.net.URL;
import java.net.URI;
import java.nio.file.Paths;
import java.nio.file.Files;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.BufferedReader;
import java.net.URLDecoder;
import org.bukkit.plugin.java.JavaPlugin;
import org.bukkit.event.Listener;
import org.bukkit.event.EventHandler;
import org.bukkit.event.Event;
import org.bukkit.configuration.file.FileConfiguration;
import org.jruby.RubyObject;
import org.jruby.embed.ScriptingContainer;
import org.jruby.embed.EvalFailedException;


public class JRubyPlugin extends JavaPlugin implements Listener {
  private ScriptingContainer jruby;
  private HashMap<String, Object> eventHandlers = new HashMap<String, Object>();
  private Object rubyTrue, rubyFalse, rubyNil, rubyModule;
  private Object rukkit_core;
  private FileConfiguration config;

  private void initializeRuby() {
    jruby = new ScriptingContainer();
    jruby.setClassLoader(getClass().getClassLoader());
    jruby.setCompatVersion(org.jruby.CompatVersion.RUBY2_0);

    // Because of no compatibility with Java's one
    rubyTrue = evalRuby("true");
    rubyFalse = evalRuby("false");
    rubyNil = evalRuby("nil");
    rubyModule = evalRuby("Module");
  }

  private boolean isRubyMethodExists(Object eventHandler, String method) {
    return jruby.callMethod(eventHandler, "respond_to?", method).equals(rubyTrue);
  }

  private void fireEvent(String method, Object...args) {
    jruby.callMethod(rukkit_core, "fire_event", args);
  }

  private void loadConfig() {
    config = getConfig();
  }

  private Object evalRuby(String script) {
    return jruby.runScriptlet(script);
  }

  private Object loadRukkitBundledScript(String script) {
    getLogger().info("----> " + script);
    InputStream is = null;
    BufferedReader br = null;
    try {
      is = this.getClass().getClassLoader().getResourceAsStream("scripts/" + script + ".rb");
      br = new BufferedReader(new InputStreamReader(is));
      Object obj = evalRuby(br.lines().collect(Collectors.joining("\n")));
      getLogger().info("----> done.");
      return obj;
    } catch (Exception e) {
      getLogger().info("----> failed.");
      e.printStackTrace();
    } finally {
      if (is != null) try { is.close(); } catch (IOException e) {}
      if (br != null) try { br.close(); } catch (IOException e) {}
    }
    return rubyNil;
  }

  private void loadCoreScripts() {
    loadRukkitBundledScript("util");
    this.rukkit_core = loadRukkitBundledScript("core");
    jruby.callMethod(this.rukkit_core, "run");
  }

  private void applyEventHandler() {
    getServer().getPluginManager().registerEvents(this, this);
  }

  @Override
  public void onEnable() {
    initializeRuby();
    loadConfig();

    getLogger().info("--> Load core scripts.");
    loadCoreScripts();

    getLogger().info("Rukkit enabled!");

    applyEventHandler();
  }

  @Override
  public void onDisable() {
    getLogger().info("Rukkit disabled!");
  }

  @Override
  public boolean onCommand(org.bukkit.command.CommandSender sender, org.bukkit.command.Command command, String label, String[] args) {
    fireEvent("on_command", sender, command, label, args);
    return true;
  }

  // EventHandler mappings {{{
  // TODO: I want to generate all event handler mappings automatically,
  //       but it must be painful to parse JavaDoc...
  //       @ujm says that "use jruby repl and ruby reflection to list them up."
  // TODO: Following eventhandlers are copied from mckokoro source, so it might be not a latest handlers.
  @EventHandler
  public void onAsyncPlayerPreLogin(org.bukkit.event.player.AsyncPlayerPreLoginEvent event) {
    fireEvent("on_async_player_pre_login", event);
  }
  @EventHandler
  public void onBlockBurn(org.bukkit.event.block.BlockBurnEvent event) {
    fireEvent("on_block_burn", event);
  }
  @EventHandler
  public void onBlockCanBuild(org.bukkit.event.block.BlockCanBuildEvent event) {
    fireEvent("on_block_can_build", event);
  }
  @EventHandler
  public void onBlockDamage(org.bukkit.event.block.BlockDamageEvent event) {
    fireEvent("on_block_damage", event);
  }
  @EventHandler
  public void onBlockDispense(org.bukkit.event.block.BlockDispenseEvent event) {
    fireEvent("on_block_dispense", event);
  }
  @EventHandler
  public void onBlockBreak(org.bukkit.event.block.BlockBreakEvent event) {
    fireEvent("on_block_break", event);
  }
  @EventHandler
  public void onFurnaceExtract(org.bukkit.event.inventory.FurnaceExtractEvent event) {
    fireEvent("on_furnace_extract", event);
  }
  @EventHandler
  public void onBlockFade(org.bukkit.event.block.BlockFadeEvent event) {
    fireEvent("on_block_fade", event);
  }
  @EventHandler
  public void onBlockFromTo(org.bukkit.event.block.BlockFromToEvent event) {
    fireEvent("on_block_from_to", event);
  }
  @EventHandler
  public void onBlockForm(org.bukkit.event.block.BlockFormEvent event) {
    fireEvent("on_block_form", event);
  }
  @EventHandler
  public void onBlockSpread(org.bukkit.event.block.BlockSpreadEvent event) {
    fireEvent("on_block_spread", event);
  }
  @EventHandler
  public void onEntityBlockForm(org.bukkit.event.block.EntityBlockFormEvent event) {
    fireEvent("on_entity_block_form", event);
  }
  @EventHandler
  public void onBlockIgnite(org.bukkit.event.block.BlockIgniteEvent event) {
    fireEvent("on_block_ignite", event);
  }
  @EventHandler
  public void onBlockPhysics(org.bukkit.event.block.BlockPhysicsEvent event) {
    fireEvent("on_block_physics", event);
  }
  @EventHandler
  public void onBlockPistonExtend(org.bukkit.event.block.BlockPistonExtendEvent event) {
    fireEvent("on_block_piston_extend", event);
  }
  @EventHandler
  public void onBlockPistonRetract(org.bukkit.event.block.BlockPistonRetractEvent event) {
    fireEvent("on_block_piston_retract", event);
  }
  @EventHandler
  public void onBlockPlace(org.bukkit.event.block.BlockPlaceEvent event) {
    fireEvent("on_block_place", event);
  }
  @EventHandler
  public void onBlockRedstone(org.bukkit.event.block.BlockRedstoneEvent event) {
    fireEvent("on_block_redstone", event);
  }
  @EventHandler
  public void onBrew(org.bukkit.event.inventory.BrewEvent event) {
    fireEvent("on_brew", event);
  }
  @EventHandler
  public void onFurnaceBurn(org.bukkit.event.inventory.FurnaceBurnEvent event) {
    fireEvent("on_furnace_burn", event);
  }
  @EventHandler
  public void onFurnaceSmelt(org.bukkit.event.inventory.FurnaceSmeltEvent event) {
    fireEvent("on_furnace_smelt", event);
  }
  @EventHandler
  public void onLeavesDecay(org.bukkit.event.block.LeavesDecayEvent event) {
    fireEvent("on_leaves_decay", event);
  }
  @EventHandler
  public void onNotePlay(org.bukkit.event.block.NotePlayEvent event) {
    fireEvent("on_note_play", event);
  }
  @EventHandler
  public void onSignChange(org.bukkit.event.block.SignChangeEvent event) {
    fireEvent("on_sign_change", event);
  }
  @EventHandler
  public void onCreatureSpawn(org.bukkit.event.entity.CreatureSpawnEvent event) {
    fireEvent("on_creature_spawn", event);
  }
  @EventHandler
  public void onCreeperPower(org.bukkit.event.entity.CreeperPowerEvent event) {
    fireEvent("on_creeper_power", event);
  }
  @EventHandler
  public void onEntityChangeBlock(org.bukkit.event.entity.EntityChangeBlockEvent event) {
    fireEvent("on_entity_change_block", event);
  }
  @EventHandler
  public void onEntityBreakDoor(org.bukkit.event.entity.EntityBreakDoorEvent event) {
    fireEvent("on_entity_break_door", event);
  }
  @EventHandler
  public void onEntityCombust(org.bukkit.event.entity.EntityCombustEvent event) {
    fireEvent("on_entity_combust", event);
  }
  @EventHandler
  public void onEntityCombustByBlock(org.bukkit.event.entity.EntityCombustByBlockEvent event) {
    fireEvent("on_entity_combust_by_block", event);
  }
  @EventHandler
  public void onEntityCombustByEntity(org.bukkit.event.entity.EntityCombustByEntityEvent event) {
    fireEvent("on_entity_combust_by_entity", event);
  }
  @EventHandler
  public void onEntityCreatePortal(org.bukkit.event.entity.EntityCreatePortalEvent event) {
    fireEvent("on_entity_create_portal", event);
  }
  @EventHandler
  public void onEntityDamageByBlock(org.bukkit.event.entity.EntityDamageEvent event) {
    fireEvent("on_entity_damage", event);
  }
  @EventHandler
  public void onEntityDamageByBlock(org.bukkit.event.entity.EntityDamageByBlockEvent event) {
    fireEvent("on_entity_damage_by_block", event);
  }
  @EventHandler
  public void onEntityDamageByEntity(org.bukkit.event.entity.EntityDamageByEntityEvent event) {
    fireEvent("on_entity_damage_by_entity", event);
  }
  @EventHandler
  public void onEntityDeath(org.bukkit.event.entity.EntityDeathEvent event) {
    fireEvent("on_entity_death", event);
  }
  @EventHandler
  public void onPlayerDeath(org.bukkit.event.entity.PlayerDeathEvent event) {
    fireEvent("on_player_death", event);
  }
  @EventHandler
  public void onEntityExplode(org.bukkit.event.entity.EntityExplodeEvent event) {
    fireEvent("on_entity_explode", event);
  }
  @EventHandler
  public void onEntityInteract(org.bukkit.event.entity.EntityInteractEvent event) {
    fireEvent("on_entity_interact", event);
  }
  @EventHandler
  public void onEntityRegainHealth(org.bukkit.event.entity.EntityRegainHealthEvent event) {
    fireEvent("on_entity_regain_health", event);
  }
  @EventHandler
  public void onEntityShootBow(org.bukkit.event.entity.EntityShootBowEvent event) {
    fireEvent("on_entity_shoot_bow", event);
  }
  @EventHandler
  public void onEntityTame(org.bukkit.event.entity.EntityTameEvent event) {
    fireEvent("on_entity_tame", event);
  }
  @EventHandler
  public void onEntityTarget(org.bukkit.event.entity.EntityTargetEvent event) {
    fireEvent("on_entity_target", event);
  }
  @EventHandler
  public void onEntityTargetLivingEntity(org.bukkit.event.entity.EntityTargetLivingEntityEvent event) {
    fireEvent("on_entity_target_living_entity", event);
  }
  @EventHandler
  public void onEntityTeleport(org.bukkit.event.entity.EntityTeleportEvent event) {
    fireEvent("on_entity_teleport", event);
  }
  @EventHandler
  public void onExplosionPrime(org.bukkit.event.entity.ExplosionPrimeEvent event) {
    fireEvent("on_explosion_prime", event);
  }
  @EventHandler
  public void onFoodLevelChange(org.bukkit.event.entity.FoodLevelChangeEvent event) {
    fireEvent("on_food_level_change", event);
  }
  @EventHandler
  public void onItemDespawn(org.bukkit.event.entity.ItemDespawnEvent event) {
    fireEvent("on_item_despawn", event);
  }
  @EventHandler
  public void onItemSpawn(org.bukkit.event.entity.ItemSpawnEvent event) {
    fireEvent("on_item_spawn", event);
  }
  @EventHandler
  public void onPigZap(org.bukkit.event.entity.PigZapEvent event) {
    fireEvent("on_pig_zap", event);
  }
  @EventHandler
  public void onProjectileHit(org.bukkit.event.entity.ProjectileHitEvent event) {
    fireEvent("on_projectile_hit", event);
  }
  @EventHandler
  public void onExpBottle(org.bukkit.event.entity.ExpBottleEvent event) {
    fireEvent("on_exp_bottle", event);
  }
  @EventHandler
  public void onPotionSplash(org.bukkit.event.entity.PotionSplashEvent event) {
    fireEvent("on_potion_splash", event);
  }
  @EventHandler
  public void onProjectileLaunch(org.bukkit.event.entity.ProjectileLaunchEvent event) {
    fireEvent("on_projectile_launch", event);
  }
  @EventHandler
  public void onSheepDyeWool(org.bukkit.event.entity.SheepDyeWoolEvent event) {
    fireEvent("on_sheep_dye_wool", event);
  }
  @EventHandler
  public void onSheepRegrowWool(org.bukkit.event.entity.SheepRegrowWoolEvent event) {
    fireEvent("on_sheep_regrow_wool", event);
  }
  @EventHandler
  public void onSlimeSplit(org.bukkit.event.entity.SlimeSplitEvent event) {
    fireEvent("on_slime_split", event);
  }
  @EventHandler
  public void onHangingBreak(org.bukkit.event.hanging.HangingBreakEvent event) {
    fireEvent("on_hanging_break", event);
  }
  @EventHandler
  public void onHangingBreakByEntity(org.bukkit.event.hanging.HangingBreakByEntityEvent event) {
    fireEvent("on_hanging_break_by_entity", event);
  }
  @EventHandler
  public void onHangingPlace(org.bukkit.event.hanging.HangingPlaceEvent event) {
    fireEvent("on_hanging_place", event);
  }
  @EventHandler
  public void onEnchantItem(org.bukkit.event.enchantment.EnchantItemEvent event) {
    fireEvent("on_enchant_item", event);
  }
  @EventHandler
  public void onInventoryClick(org.bukkit.event.inventory.InventoryClickEvent event) {
    fireEvent("on_inventory_click", event);
  }
  @EventHandler
  public void onCraftItem(org.bukkit.event.inventory.CraftItemEvent event) {
    fireEvent("on_craft_item", event);
  }
  @EventHandler
  public void onInventoryClose(org.bukkit.event.inventory.InventoryCloseEvent event) {
    fireEvent("on_inventory_close", event);
  }
  @EventHandler
  public void onInventoryOpen(org.bukkit.event.inventory.InventoryOpenEvent event) {
    fireEvent("on_inventory_open", event);
  }
  @EventHandler
  public void onPrepareItemCraft(org.bukkit.event.inventory.PrepareItemCraftEvent event) {
    fireEvent("on_prepare_item_craft", event);
  }
  @EventHandler
  public void onPrepareItemEnchant(org.bukkit.event.enchantment.PrepareItemEnchantEvent event) {
    fireEvent("on_prepare_item_enchant", event);
  }
  @EventHandler
  public void onAsyncPlayerChat(org.bukkit.event.player.AsyncPlayerChatEvent event) {
    fireEvent("on_async_player_chat", event);
  }
  @EventHandler
  public void onPlayerAnimation(org.bukkit.event.player.PlayerAnimationEvent event) {
    fireEvent("on_player_animation", event);
  }
  @EventHandler
  public void onPlayerBedEnter(org.bukkit.event.player.PlayerBedEnterEvent event) {
    fireEvent("on_player_bed_enter", event);
  }
  @EventHandler
  public void onPlayerBedLeave(org.bukkit.event.player.PlayerBedLeaveEvent event) {
    fireEvent("on_player_bed_leave", event);
  }
  @EventHandler
  public void onPlayerBucketEmpty(org.bukkit.event.player.PlayerBucketEmptyEvent event) {
    fireEvent("on_player_bucket_empty", event);
  }
  @EventHandler
  public void onPlayerBucketFill(org.bukkit.event.player.PlayerBucketFillEvent event) {
    fireEvent("on_player_bucket_fill", event);
  }
  @EventHandler
  public void onPlayerChangedWorld(org.bukkit.event.player.PlayerChangedWorldEvent event) {
    fireEvent("on_player_changed_world", event);
  }
  @EventHandler
  public void onPlayerRegisterChannel(org.bukkit.event.player.PlayerRegisterChannelEvent event) {
    fireEvent("on_player_register_channel", event);
  }
  @EventHandler
  public void onPlayerUnregisterChannel(org.bukkit.event.player.PlayerUnregisterChannelEvent event) {
    fireEvent("on_player_unregister_channel", event);
  }
  @EventHandler
  public void onPlayerChatTabComplete(org.bukkit.event.player.PlayerChatTabCompleteEvent event) {
    fireEvent("on_player_chat_tab_complete", event);
  }
  @EventHandler
  public void onPlayerCommandPreprocess(org.bukkit.event.player.PlayerCommandPreprocessEvent event) {
    fireEvent("on_player_command_preprocess", event);
  }
  @EventHandler
  public void onPlayerDropItem(org.bukkit.event.player.PlayerDropItemEvent event) {
    fireEvent("on_player_drop_item", event);
  }
  @EventHandler
  public void onPlayerEggThrow(org.bukkit.event.player.PlayerEggThrowEvent event) {
    fireEvent("on_player_egg_throw", event);
  }
  @EventHandler
  public void onPlayerExpChange(org.bukkit.event.player.PlayerExpChangeEvent event) {
    fireEvent("on_player_exp_change", event);
  }
  @EventHandler
  public void onPlayerFish(org.bukkit.event.player.PlayerFishEvent event) {
    fireEvent("on_player_fish", event);
  }
  @EventHandler
  public void onPlayerGameModeChange(org.bukkit.event.player.PlayerGameModeChangeEvent event) {
    fireEvent("on_player_game_mode_change", event);
  }
  @EventHandler
  public void onPlayerInteractEntity(org.bukkit.event.player.PlayerInteractEntityEvent event) {
    fireEvent("on_player_interact_entity", event);
  }
  @EventHandler
  public void onPlayerInteract(org.bukkit.event.player.PlayerInteractEvent event) {
    fireEvent("on_player_interact", event);
  }
  @EventHandler
  public void onPlayerItemBreak(org.bukkit.event.player.PlayerItemBreakEvent event) {
    fireEvent("on_player_item_break", event);
  }
  @EventHandler
  public void onPlayerItemHeld(org.bukkit.event.player.PlayerItemHeldEvent event) {
    fireEvent("on_player_item_held", event);
  }
  @EventHandler
  public void onPlayerJoin(org.bukkit.event.player.PlayerJoinEvent event) {
    fireEvent("on_player_join", event);
  }
  @EventHandler
  public void onPlayerKick(org.bukkit.event.player.PlayerKickEvent event) {
    fireEvent("on_player_kick", event);
  }
  @EventHandler
  public void onPlayerLevelChange(org.bukkit.event.player.PlayerLevelChangeEvent event) {
    fireEvent("on_player_level_change", event);
  }
  @EventHandler
  public void onPlayerLogin(org.bukkit.event.player.PlayerLoginEvent event) {
    fireEvent("on_player_login", event);
  }
  @EventHandler
  public void onPlayerMove(org.bukkit.event.player.PlayerMoveEvent event) {
    fireEvent("on_player_move", event);
  }
  @EventHandler
  public void onPlayerTeleport(org.bukkit.event.player.PlayerTeleportEvent event) {
    fireEvent("on_player_teleport", event);
  }
  @EventHandler
  public void onPlayerPortal(org.bukkit.event.player.PlayerPortalEvent event) {
    fireEvent("on_player_portal", event);
  }
  @EventHandler
  public void onPlayerPickupItem(org.bukkit.event.player.PlayerPickupItemEvent event) {
    fireEvent("on_player_pickup_item", event);
  }
  @EventHandler
  public void onPlayerQuit(org.bukkit.event.player.PlayerQuitEvent event) {
    fireEvent("on_player_quit", event);
  }
  @EventHandler
  public void onPlayerRespawn(org.bukkit.event.player.PlayerRespawnEvent event) {
    fireEvent("on_player_respawn", event);
  }
  @EventHandler
  public void onPlayerShearEntity(org.bukkit.event.player.PlayerShearEntityEvent event) {
    fireEvent("on_player_shear_entity", event);
  }
  @EventHandler
  public void onPlayerToggleFlight(org.bukkit.event.player.PlayerToggleFlightEvent event) {
    fireEvent("on_player_toggle_flight", event);
  }
  @EventHandler
  public void onPlayerToggleSneak(org.bukkit.event.player.PlayerToggleSneakEvent event) {
    fireEvent("on_player_toggle_sneak", event);
  }
  @EventHandler
  public void onPlayerToggleSprint(org.bukkit.event.player.PlayerToggleSprintEvent event) {
    fireEvent("on_player_toggle_sprint", event);
  }
  @EventHandler
  public void onPlayerVelocity(org.bukkit.event.player.PlayerVelocityEvent event) {
    fireEvent("on_player_velocity", event);
  }
  @EventHandler
  public void onMapInitialize(org.bukkit.event.server.MapInitializeEvent event) {
    fireEvent("on_map_initialize", event);
  }
  @EventHandler
  public void onPluginDisable(org.bukkit.event.server.PluginDisableEvent event) {
    fireEvent("on_plugin_disable", event);
  }
  @EventHandler
  public void onPluginEnable(org.bukkit.event.server.PluginEnableEvent event) {
    fireEvent("on_plugin_enable", event);
  }
  @EventHandler
  public void onServerCommand(org.bukkit.event.server.ServerCommandEvent event) {
    fireEvent("on_server_command", event);
  }
  @EventHandler
  public void onRemoteServerCommand(org.bukkit.event.server.RemoteServerCommandEvent event) {
    fireEvent("on_remote_server_command", event);
  }
  @EventHandler
  public void onServerListPing(org.bukkit.event.server.ServerListPingEvent event) {
    fireEvent("on_server_list_ping", event);
  }
  @EventHandler
  public void onServiceRegister(org.bukkit.event.server.ServiceRegisterEvent event) {
    fireEvent("on_service_register", event);
  }
  @EventHandler
  public void onServiceUnregister(org.bukkit.event.server.ServiceUnregisterEvent event) {
    fireEvent("on_service_unregister", event);
  }
  @EventHandler
  public void onVehicleBlockCollision(org.bukkit.event.vehicle.VehicleBlockCollisionEvent event) {
    fireEvent("on_vehicle_block_collision", event);
  }
  @EventHandler
  public void onVehicleEntityCollision(org.bukkit.event.vehicle.VehicleEntityCollisionEvent event) {
    fireEvent("on_vehicle_entity_collision", event);
  }
  @EventHandler
  public void onVehicleCreate(org.bukkit.event.vehicle.VehicleCreateEvent event) {
    fireEvent("on_vehicle_create", event);
  }
  @EventHandler
  public void onVehicleDamage(org.bukkit.event.vehicle.VehicleDamageEvent event) {
    fireEvent("on_vehicle_damage", event);
  }
  @EventHandler
  public void onVehicleDestroy(org.bukkit.event.vehicle.VehicleDestroyEvent event) {
    fireEvent("on_vehicle_destroy", event);
  }
  @EventHandler
  public void onVehicleEnter(org.bukkit.event.vehicle.VehicleEnterEvent event) {
    fireEvent("on_vehicle_enter", event);
  }
  @EventHandler
  public void onVehicleExit(org.bukkit.event.vehicle.VehicleExitEvent event) {
    fireEvent("on_vehicle_exit", event);
  }
  @EventHandler
  public void onVehicleMove(org.bukkit.event.vehicle.VehicleMoveEvent event) {
    fireEvent("on_vehicle_move", event);
  }
  @EventHandler
  public void onVehicleUpdate(org.bukkit.event.vehicle.VehicleUpdateEvent event) {
    fireEvent("on_vehicle_update", event);
  }
  @EventHandler
  public void onLightningStrike(org.bukkit.event.weather.LightningStrikeEvent event) {
    fireEvent("on_lightning_strike", event);
  }
  @EventHandler
  public void onThunderChange(org.bukkit.event.weather.ThunderChangeEvent event) {
    fireEvent("on_thunder_change", event);
  }
  @EventHandler
  public void onWeatherChange(org.bukkit.event.weather.WeatherChangeEvent event) {
    fireEvent("on_weather_change", event);
  }
  @EventHandler
  public void onChunkLoad(org.bukkit.event.world.ChunkLoadEvent event) {
    fireEvent("on_chunk_load", event);
  }
  @EventHandler
  public void onChunkPopulate(org.bukkit.event.world.ChunkPopulateEvent event) {
    fireEvent("on_chunk_populate", event);
  }
  @EventHandler
  public void onChunkUnload(org.bukkit.event.world.ChunkUnloadEvent event) {
    fireEvent("on_chunk_unload", event);
  }
  @EventHandler
  public void onPortalCreate(org.bukkit.event.world.PortalCreateEvent event) {
    fireEvent("on_portal_create", event);
  }
  @EventHandler
  public void onSpawnChange(org.bukkit.event.world.SpawnChangeEvent event) {
    fireEvent("on_spawn_change", event);
  }
  @EventHandler
  public void onStructureGrow(org.bukkit.event.world.StructureGrowEvent event) {
    fireEvent("on_structure_grow", event);
  }
  @EventHandler
  public void onWorldInit(org.bukkit.event.world.WorldInitEvent event) {
    fireEvent("on_world_init", event);
  }
  @EventHandler
  public void onWorldLoad(org.bukkit.event.world.WorldLoadEvent event) {
    fireEvent("on_world_load", event);
  }
  @EventHandler
  public void onWorldSave(org.bukkit.event.world.WorldSaveEvent event) {
    fireEvent("on_world_save", event);
  }
  @EventHandler
  public void onWorldUnload(org.bukkit.event.world.WorldUnloadEvent event) {
    fireEvent("on_world_unload", event);
  }
  // }}}
}
