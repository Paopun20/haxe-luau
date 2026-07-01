package hxluau;

import hxluau.Lua.State;

@:buildXml("
	<files id='haxe'>
		<compilerflag value='-I${haxelib:hxluau}/luau/VM/include'/>
		<compilerflag value='-I${haxelib:hxluau}/luau/Compiler/include'/>
	</files>
	<target id='haxe'>
		<lib name='${haxelib:hxluau}/luau/cmake/libLuau.VM.a'/>
		<lib name='${haxelib:hxluau}/luau/cmake/libLuau.Compiler.a'/>
		<lib name='${haxelib:hxluau}/luau/cmake/libLuau.Ast.a'/>
	</target>")
// @:include("LuaHidden.h")
@:include("lua.h")
@:include("lualib.h")
@:include("luacode.h")
extern class Lualib {
	/**
	 * Open all standard Lua libraries into the given state.
	 *
	 * @param L the Lua state
	 */
	@:native("luaL_openlibs")
	static function openlibs(L:State):Void;

	/**
	 * Open the debug library into the given state.
	 *
	 * @param L the Lua state
	 */
	@:native("luaopen_debug")
	static function opendebug(L:State):Void;
}
