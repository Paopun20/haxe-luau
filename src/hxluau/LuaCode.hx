package hxluau;

import hxluau.Types.CString;

@:include("luacode.h")
@:buildXml("
	<files id='haxe'>
		<compilerflag value='-I${haxelib:hxluau}/luau/Compiler/include'/>
	</files>")
@:native("lua_CompileOptions")
@:structAccess
extern class CompileOptions {
	@:native("optimizationLevel")
	var optimizationLevel:Int;
	@:native("debugLevel")
	var debugLevel:Int;

	@:native("lua_CompileOptions")
	static function create():CompileOptions;
}

/**
 * An opaque struct to hold compiled bytecode and its size.
 * Callers must not modify or free the contents.
 */
class Code {
	public var code:cpp.ConstCharStar;

	public var size:Int;

	public function new() {}
}

extern class LuaCode {
	/**
	 * Compile functions
	 */
	// FIXME the options type is complex and needs to be full externed
	@:native("luau_compile")
	static function _compile(source:cpp.ConstCharStar, size:cpp.SizeT, options:cpp.Pointer<CompileOptions>,
		bytecodeSize:cpp.Pointer<cpp.SizeT>):cpp.ConstCharStar;

	/**
	 * Compile the source into bytecode.
	 *
	 * In the case of compilation errors the error message will be placed into
	 * the return code. The error message will be available when luau_load is
	 * called to load the bytecode.
	 *
	 * @param source the source text
	 * @param size the size of the source text
	 * @param options compiler options
	 * @return Code an opaque struct containing the compiled bytecode. This
	 * must not be modified or freed by the caller, and is only to be
	 * submitted to lua_load.
	 */
	static inline function compile(source:CString, size:cpp.SizeT, ?options:CompileOptions):Code {
		var bytecodeSize:cpp.SizeT = 0;
		var bytecode = _compile(source, size, cpp.Pointer.addressOf(options), cpp.Pointer.addressOf(bytecodeSize));
		var rv = new Code();
		rv.code = bytecode;
		rv.size = bytecodeSize;
		return rv;
	}
}
