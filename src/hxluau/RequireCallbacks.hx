package hxluau;

import hxluau.Lua.State;
import hxluau.Require.NavigateResult;

/**
 * Require callbacks.
 * An instance of this class is passed to the `Require.openrequire()` function
 * to provide the callbacks to the require system.
 */
class RequireCallbacks {
	public function new() {}

	/**
	 * Returns whether requiring from the given chunkname is allowed.
	 * @param L a pointer to the lua_State object
	 * @param ctx a pointer to the RequireCtx struct
	 * @param requirerChunkname the chunkname of the requirer
	 * @return true if requiring is allowed, false otherwise
	 */
	public var isRequireAllowed:(L:State, ctx:Dynamic, requirerChunkname:String) -> Bool;

	/**
	 * Resets the VFSNavigator to the location specified by the requirerChunkname.
	 * @param L a pointer to the lua_State object
	 * @param ctx a pointer to the RequireCtx struct
	 * @param requirerChunkname the chunkname of the requirer
	 * @return the result of the navigation
	 */
	public var reset:(L:State, ctx:Dynamic, requirerChunkname:String) -> NavigateResult;

	/**
	 * Jumps to the specified alias in the VFSNavigator.
	 * @param L a pointer to the lua_State object
	 * @param ctx a pointer to the RequireCtx struct
	 * @param path the alias path
	 * @return the result of the navigation
	 */
	public var jump_to_alias:(L:State, ctx:Dynamic, path:String) -> NavigateResult;

	/**
	 * Navigates to the parent directory in the VFSNavigator.
	 * @param L a pointer to the lua_State object
	 * @param ctx a pointer to the RequireCtx struct
	 * @return the result of the navigation
	 */
	public var to_parent:(L:State, ctx:Dynamic) -> NavigateResult;

	/**
	 * Navigates to the child with the given name in the VFSNavigator.
	 * @param L a pointer to the lua_State object
	 * @param ctx a pointer to the RequireCtx struct
	 * @param name the name of the child to navigate to
	 * @return the result of the navigation
	 */
	public var to_child:(L:State, ctx:Dynamic, name:String) -> NavigateResult;

	/**
	 * Returns whether a module is present in the current context.
	 * @param L a pointer to the lua_State object
	 * @param ctx a pointer to the RequireCtx struct
	 * @return true if a module is present, false otherwise
	 */
	public var is_module_present:(L:State, ctx:Dynamic) -> Bool;

	/**
	 * Returns whether a configuration file is present in the current context.
	 * @param L a pointer to the lua_State object
	 * @param ctx a pointer to the RequireCtx struct
	 * @return true if a configuration file is present, false otherwise
	 */
	public var is_config_present:(L:State, ctx:Dynamic) -> Bool;

	/**
	 * Returns the chunkname for the current module in the VFSNavigator.
	 * @param L a pointer to the lua_State object
	 * @param ctx a pointer to the RequireCtx struct
	 * @return the chunkname
	 */
	public var get_chunkname:(L:State, ctx:Dynamic) -> String;

	/**
	 * Returns the loadname for the current module in the VFSNavigator.
	 * @param L a pointer to the lua_State object
	 * @param ctx a pointer to the RequireCtx struct
	 * @return the loadname
	 */
	public var get_loadname:(L:State, ctx:Dynamic) -> String;

	/**
	 * Returns the cache key for the current module in the VFSNavigator.
	 * @param L a pointer to the lua_State object
	 * @param ctx a pointer to the RequireCtx struct
	 * @return the cache key
	 */
	public var get_cache_key:(L:State, ctx:Dynamic) -> String;

	/**
	 * Returns the alias for the current module in the VFSNavigator.
	 * @param L a pointer to the lua_State object
	 * @param ctx a pointer to the RequireCtx struct
	 * @param alias the alias name
	 * @return the alias path
	 */
	public var get_alias:(L:State, ctx:Dynamic, alias:String) -> String;

	/**
	 * Returns the status of the configuration file in the current context.
	 * @param L a pointer to the lua_State object
	 * @param ctx a pointer to the RequireCtx struct
	 * @return true if the configuration is valid, false otherwise
	 */
	public var get_config_status:(L:State, ctx:Dynamic) -> Bool; // FIXME is this part of this interface at this version

	/**
	 * Returns the content of the configuration file in the current context.
	 * @param L a pointer to the lua_State object
	 * @param ctx a pointer to the RequireCtx struct
	 * @return the configuration content
	 */
	public var get_config:(L:State, ctx:Dynamic) -> String;

	/**
	 * Loads and executes the module at the given loadname.
	 * @param L a pointer to the lua_State object
	 * @param ctx a pointer to the RequireCtx struct
	 * @param path the module path
	 * @param chunkname the chunkname for the module
	 * @param loadname the loadname for the module
	 * @return LUA_OK on success, or an error code on failure
	 */
	public var load:(L:State, ctx:Dynamic, path:String, chunkname:String, loadname:String) -> Int;
}
