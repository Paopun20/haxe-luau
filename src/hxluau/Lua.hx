package hxluau;

import hxluau.LuaCode.Code;
import hxluau.Types.CString;
import haxe.ds.Vector;

@:cppNamespaceCode('
#include <iostream>
#include <lua.h>
int callback(lua_State *L)
{
	// std::cout << "callback:entered" << std::endl;
    auto root = *(static_cast<hx::Object ***>(lua_touserdatatagged(L,
								  	 			lua_upvalueindex(1), 1)));
    // std::cout << "callback:root:" << root << std::endl;
    // std::cout << "callback:*root:" << *root << std::endl;
    auto cb = Dynamic(*root);
    // std::cout << "about call cb()" << std::endl;
	// std::cout << "callback:L:" << L << std::endl;
	::cpp::Pointer<lua_State> statePtr = ::cpp::Pointer<lua_State>(L);
    int rv = cb(statePtr);
    return rv;
}

void gcroot_finalizer (lua_State *L, void *ud) {
	// std::cout << "gcroot_finalizer:entered" << std::endl;
	auto root = *(static_cast<hx::Object ***>(ud));
    GCRemoveRoot(root);
    // std::cout << "gcroot_finalizer:about to call delete root" << std::endl;
	// std::cout << "gcroot_finalizer:root:" << root << std::endl;
    delete root;
}

void pushcfunction_wrapper(lua_State *L, Dynamic cb, const char *debugName)
{
	lua_setuserdatadtor(L, 1, gcroot_finalizer);
	// FIXME This needs to handle memory alloc failures
    hx::Object **root = new hx::Object *{cb.mPtr};
    GCAddRoot(root);
    // std::cout << "wrapper:cb.mPtr:" << cb.mPtr << std::endl;
    // std::cout << "wrapper:root:" << root << std::endl;
    // std::cout << "wrapper:*root:" << *root << std::endl;
    hx::Object ** *ud = static_cast<hx::Object ***>(lua_newuserdatatagged(L, sizeof(hx::Object **), 1));
	*ud = root;
    lua_pushcclosure(L, callback, debugName, 1);
}
')
@:headerCode('
#include <lua.h>

/// @brief This is a C++ wrapper around the C function lua_pushcclosure().
/// It accepts a Haxe Dynamic function object to pass to lua_pushcclosure().
/// @param fn The Haxe Dynamic function object to be called back from
///           lua_pushcclosure(). The function signature is not constrained
///	          here but must match the form expected by lua_pushcclosure().
void pushcfunction_wrapper(lua_State *L, Dynamic cb, const char *debugName);
')
@:keep
class LuaHidden {}

/**
 * A reference to a Lua object. Note that cpp.Star is used because it
 * properly generates code that works for a simple C pointer, and 
 * also generates proper code when used as an argument to a function.
 * cpp.RawPointer does not generate correct code in such cases though it
 * is not known why.
 * 
 * The current use case for this is pass Lua states around.
 */
typedef Ref<T> = T;

@:include("lua.h")
@:buildXml("
	<files id='haxe'>
		<compilerflag value='-I${haxelib:hxluau}/luau/VM/include'/>
	</files>")
@:native("lua_State")
extern class NativeState {}

private typedef _Ref<T> = cpp.Pointer<T>;
typedef State = _Ref<NativeState>;
typedef CSizeT = cpp.SizeT;

// FIXME this should be deprecated and replaced with LuaHaxeStaticFunction
typedef LuaCFunction = State->Int;
typedef LuaHaxeStaticFunction = State->Int;
typedef LuaHaxeStaticRetFunction = cpp.Callable<State->Int>;
typedef LuaCContinuation = cpp.Callable<(State, Int) -> Int>;

// typedef for memory allocation functions
typedef LuaAlloc = cpp.Callable<(cpp.Pointer<Void>, cpp.Pointer<Void>, CSizeT, CSizeT) -> cpp.Pointer<Void>>;

private abstract Bytecode(cpp.ConstCharStar) from cpp.ConstCharStar to cpp.ConstCharStar {
	@:from static inline function fromPointer(p:cpp.ConstCharStar):Bytecode {
		return p;
	}

	@:to inline function toPointer():cpp.ConstCharStar {
		return this;
	}
}

extern enum abstract LuaDefines(Int) from Int to Int {
	@:native("LUA_VECTOR_SIZE")
	var VECTOR_SIZE:Int;
	@:native("LUA_TNONE")
	var NONE:Int;
}

/**
 * Lua thread status codes.
 */
abstract LuaStatus(Int) from Int to Int {
	@:native("LUA_OK")
	public static var OK:Int;
	@:native("LUA_YIELD")
	public static var YIELD:Int;
	@:native("LUA_ERRRUN")
	public static var ERRRUN:Int;
	@:native("LUA_ERRSYNTAX")
	public static var ERRSYNTAX:Int;
	@:native("LUA_ERRMEM")
	public static var ERRMEM:Int;
	@:native("LUA_ERRERR")
	public static var ERRERR:Int;
	@:native("LUA_BREAK")
	public static var BREAK:Int;
}

abstract LuaCoStatus(Int) from Int to Int {
	@:native("LUA_CORUN")
	public static var CORUN:Int;
	@:native("LUA_COSUS")
	public static var COSUS:Int;
	@:native("LUA_CONOR")
	public static var CONOR:Int;
	@:native("LUA_COFIN")
	public static var COFIN:Int;
	@:native("LUA_COERR")
	public static var COERR:Int;
}

/**
 * basic type
 * LUA_TNONE is in LuaDefines as it outside the enum in Luau
 */
abstract LuaType(Int) from Int to Int {
	@:native("LUA_TNIL")
	public static var NIL:Int;
	@:native("LUA_TBOOLEAN")
	public static var BOOLEAN:Int;
	@:native("LUA_TLIGHTUSERDATA")
	public static var LIGHTUSERDATA:Int;
	@:native("LUA_TNUMBER")
	public static var NUMBER:Int;
	@:native("LUA_TVECTOR")
	public static var VECTOR:Int;
	@:native("LUA_TSTRING")
	public static var STRING:Int;
	@:native("LUA_TTABLE")
	public static var TABLE:Int;
	@:native("LUA_TFUNCTION")
	public static var FUNCTION:Int;
	@:native("LUA_TUSERDATA")
	public static var USERDATA:Int;
	@:native("LUA_TTHREAD")
	public static var THREAD:Int;
	@:native("LUA_TBUFFER")
	public static var BUFFER:Int;
	@:native("LUA_TPROTO")
	public static var PROTO:Int;
	@:native("LUA_TUPVAL")
	public static var UPVAL:Int;
	@:native("LUA_TDEADKEY")
	public static var DEADKEY:Int;
	@:native("LUA_T_COUNT")
	public static var COUNT:Int;
}

/**
 * floating point type
 * This maps to the Haxe Float which is a double precision 64 bit float.
 */
@:native("lua_Number")
@:scalar
@:coreType
@:notNull
extern abstract LuaNumber from Float to Float {}

/**
 * signed integer type
 * This maps to a C++ int type which is a 32 bit integer, for
 * the common case. Note, the Lua language itself does not have
 * an integer type, only a number type (floating point). This is
 * only used to allow host languages to push integers into the VM, or
 * get them back.
 */
@:native("lua_Integer")
@:scalar
@:coreType
@:notNull
extern abstract LuaInteger from Int to Int {}

/**
 * unsigned integer type
 * FIXME - determine if this should be 32 or 64 bit
 * The more I think about this the more I think I need some
 * C++ based boundary testing to figure out what happens as
 * these type conversion occur.
 */
@:native("lua_Unsigned")
@:scalar
@:coreType
@:notNull
extern abstract LuaUnsigned from cpp.UInt32 to cpp.UInt32 {}

/*
 * Garbage-collection function and options
 * These are used to control the garbage collector.
 * Note, that these are not available in the Luau VM.
 */
extern enum abstract LuaGCop(Int) from Int to Int {
	/* stop and resume incremental garbage collection */
	@:native("LUA_GCSTOP")
	public static var STOP:Int;
	@:native("LUA_GCRESTART")
	public static var RESTART:Int;

	// run a full GC cycle; not recommended for latency sensitive applications
	@:native("LUA_GCCOLLECT")
	public static var COLLECT:Int;

	// return the heap size in KB and the  in bytes
	@:native("LUA_GCCOUNT")
	public static var COUNT:Int;
	@:native("LUA_GCCOUNTB")
	public static var COUNTB:Int;

	// return 1 if GC is active (not stopped); note that GC may not be actively collecting even if it's running
	@:native("LUA_GCISRUNNING")
	public static var ISRUNNING:Int;
	/*
	 * perform an explicit GC step, with the step size specified in KB
	 * garbage collection is handled by 'assists' that perform some amount of GC work matching pace of allocation
	 * explicit GC steps allow to perform some amount of work at custom points to offset the need for GC assists
	 * note that GC might also be paused for some duration (until bytes allocated meet the threshold)
	 * if an explicit step is performed during this pause, it will trigger the start of the next collection cycle
	 */
	@:native("LUA_GCSTEP")
	public static var STEP:Int;

	/*
	 * tune GC parameters G (goal), S (step multiplier) and step size (usually best left ignored)
	 * garbage collection is incremental and tries to maintain the heap size to balance memory and performance overhead
	 * this overhead is determined by G (goal) which is the ratio between total heap size and the amount of live data in it
	 * G is specified in percentages; by default G=200% which means that the heap is allowed to grow to ~2x the size of live data.
	 * collector tries to collect S% of allocated bytes by interrupting the application after step size bytes were allocated.
	 * when S is too small, collector may not be able to catch up and the effective goal that can be reached will be larger.
	 * S is specified in percentages; by default S=200% which means that collector will run at ~2x the pace of allocations.
	 * it is recommended to set S in the interval [100 / (G - 100), 100 + 100 / (G - 100))] with a minimum value of 150%; for example:
	 * - for G=200%, S should be in the interval [150%, 200%]
	 * - for G=150%, S should be in the interval [200%, 300%]
	 * - for G=125%, S should be in the interval [400%, 500%]
	 */
	@:native("LUA_GCSETGOAL")
	public static var SETGOAL:Int;
	@:native("LUA_GCSETSTEPMUL")
	public static var SETSTEPMUL:Int;
	@:native("LUA_GCSETSTEPSIZE")
	public static var SETSTEPSIZE:Int;
}

extern enum abstract LuaRef(Int) from Int to Int {
	@:native("LUA_NOREF")
	public static var NOREF:Int;
	@:native("LUA_REFNIL")
	public static var REFNIL:Int;
}

// FIXME these are the hook cbk types
// typedef struct lua_Debug lua_Debug; // activation record
// // Functions to be called by the debugger in specific events
// typedef void (*lua_Hook)(lua_State* L, lua_Debug* ar);
// FIXME extern this
// struct lua_Debug
// {
//     const char* name;      // (n)
//     const char* what;      // (s) `Lua', `C', `main', `tail'
//     const char* source;    // (s)
//     const char* short_src; // (s)
//     int linedefined;       // (s)
//     int currentline;       // (l)
//     unsigned char nupvals; // (u) number of upvalues
//     unsigned char nparams; // (a) number of parameters
//     char isvararg;         // (a)
//     void* userdata;        // only valid in luau_callhook
//     char ssbuf[LUA_IDSIZE];
// };
// typedef void (*lua_Coverage)(void* context, const char* function, int linedefined, int depth, const int* hits, size_t size);
/*Callbacks that can be used to reconfigure behavior of the VM dynamically.
 * These are shared between all coroutines.
 *
 * Note: interrupt is safe to set from an arbitrary thread but all other callbacks
 * can only be changed when the VM is not running any code */
// FIXME this does not yet work

@:structAccess
@:native("lua_Callbacks")
extern class LuaCallbacks {
	@:native("useratom")
	public var useratom:cpp.Pointer<(s:CString, l:CSizeT) -> cpp.Int16>;
}

@:extern
@:include("stdarg.h")
@:native("va_list") extern class CVarList {}

// @:include("LuaHidden.h")
@:include("lua.h")
@:include("lualib.h")
@:include("luacode.h")
@:buildXml("
	<files id='haxe'>
		<compilerflag value='-I${haxelib:hxluau}/luau/VM/include'/>
		<compilerflag value='-I${haxelib:hxluau}/luau/Compiler/include'/>
	</files>
	<target id='haxe'>
		<lib name='${haxelib:hxluau}/luau/cmake/libLuau.VM.a'/>
		<lib name='${haxelib:hxluau}/luau/cmake/libLuau.Compiler.a'/>
		<lib name='${haxelib:hxluau}/luau/cmake/libLuau.Ast.a'/>
		<lib name='${haxelib:hxluau}/luau/cmake/libLuau.Require.a'/>
		<lib name='${haxelib:hxluau}/luau/cmake/libLuau.RequireNavigator.a'/>
	</target>")
extern class Lua {
	// option for multiple returns in 'lua_pcall' and 'lua_call'
	@:native("LUA_MULTRET")
	static var MULTRET:Int;
	/**
	 * Pseudo indices
	 */
	/**
	 * Registry index.
	 */
	@:native('LUA_REGISTRYINDEX')
	static var REGISTRYINDEX:Int;

	/**
	 * Environment index.
	 */
	@:native('LUA_ENVIRONINDEX')
	static var ENVIRONINDEX:Int;

	/**
	 * Globals index.
	 */
	@:native('LUA_GLOBALSINDEX')
	static var GLOBALSINDEX:Int;

	/**
	 * Get the upvalue index.
	 *
	 * @param i The upvalue index.
	 * @return The index of the upvalue.
	 */
	@:native('lua_upvalueindex')
	static function upvalueindex(i:Int):Int;

	@:native("lua_ispseudo")
	static function ispseudo(i:Int):Int;

	/*
	 * State manipulation
	 */
	/**
	 * Create a new Lua state.
	 * @return The new Lua state.
	 */
	@:native("luaL_newstate")
	static function newstate():State;

	// FIXME This is the proper C signature but it would only be useful
	//       for targets that support memory allocation like this.
	// static function newstate(f:LuaAlloc, ud:cpp.RawPointer<cpp.Void>):State;
	// @:native("luaL_newstate")
	// static function newstate(f:LuaAlloc, ud:cpp.RawPointer<cpp.Void>):State;

	/**
	 * Close a Lua state.
	 * @param L the state to close
	 */
	@:native("lua_close")
	static function close(L:State):Void;

	@:native("lua_newthread")
	static function newthread(L:State):State;

	@:native("lua_mainthread")
	static function mainthread(L:State):State;

	@:native("lua_resetthread")
	static function resetthread(L:State):Void;

	@:native("lua_isthreadreset")
	static function isthreadreset(L:State):Int;

	/*
	 * Basic stack manipulation
	 */
	@:native("lua_absindex")
	static function absindex(L:State, idx:Int):Int;

	@:native("lua_gettop")
	static function gettop(L:State):Int;

	@:native("lua_settop")
	static function settop(L:State, idx:Int):Void;

	@:native("lua_pushvalue")
	static function pushvalue(L:State, idx:Int):Void;

	@:native("lua_remove")
	static function remove(L:State, idx:Int):Void;

	@:native("lua_insert")
	static function insert(L:State, idx:Int):Void;

	@:native("lua_replace")
	static function replace(L:State, idx:Int):Void;

	@:native("lua_checkstack")
	static function checkstack(L:State, sz:Int):Int;

	@:native("lua_rawcheckstack")
	static function rawcheckstack(L:State, sz:Int):Void;

	/**
	 * Move a stack element from one state to another.
	 * 
	 * Note, that if the states are related by one having been created as a
	 * copy of the other using lua_newthread, for example the value will not
	 * appear to move.
	 * 
	 * @param from the source state
	 * @param to the destination state
	 * @param n the index of the element to move
	 */
	@:native("lua_xmove")
	static function xmove(from:State, to:State, n:Int):Void;

	/**
	 * Move a stack element from one state to another by pushing it.
	 * 
	 * As with `xmove`, if the states are related by one having been created as
	 * a copy of the other using lua_newthread, for example the value will not
	 * appear to move.
	 * 
	 * @param from the source state
	 * @param to the destination state
	 * @param idx the index of the element to move
	 */
	@:native("lua_xpush")
	static function xpush(from:State, to:State, idx:Int):Void;

	/*
	 * Access functions (stack -> C)
	 */
	/**
	 * Check if a value is a number.
	 *
	 * @param L The Lua state.
	 * @param idx The index of the value to check.
	 * @return 1 if the value is a number, 0 otherwise.
	 */
	@:native('lua_isnumber')
	static function isnumber(L:State, idx:Int):Int;

	@:native("lua_isstring")
	static function isstring(L:State, idx:Int):Int;

	@:native("lua_iscfunction")
	static function iscfunction(L:State, idx:Int):Int;

	@:native("lua_isLfunction")
	static function isLfunction(L:State, idx:Int):Int;

	@:native("lua_isuserdata")
	static function isuserdata(L:State, idx:Int):Int;

	@:native("lua_type")
	static function type(L:State, idx:Int):Int;

	@:native("lua_typename")
	static function typename(L:State, tp:Int):CString;

	@:native("lua_equal")
	static function equal(L:State, idx1:Int, idx2:Int):Int;

	@:native("lua_rawequal")
	static function rawequal(L:State, idx1:Int, idx2:Int):Int;

	@:native("lua_lessthan")
	static function lessthan(L:State, idx1:Int, idx2:Int):Int;

	@:native("lua_tonumberx")
	static function _tonumberx(L:State, idx:Int, isnum:cpp.Star<Int>):Float;

	static inline function tonumberx(L:State, idx:Int, isnum:Ref<Int>):Float {
		return _tonumberx(L, idx, cpp.Pointer.addressOf(isnum).ptr);
	};

	@:native("lua_tointegerx")
	static function _tointegerx(L:State, idx:Int, isnum:cpp.Star<Int>):Int;

	static inline function tointegerx(L:State, idx:Int, isnum:Ref<Int>):Int {
		return _tointegerx(L, idx, cpp.Pointer.addressOf(isnum).ptr);
	}

	@:native("lua_tounsignedx")
	static function _tounsignedx(L:State, idx:Int, isnum:cpp.Star<Int>):UInt;

	static inline function tounsignedx(L:State, idx:Int, isnum:Ref<Int>):UInt {
		return _tounsignedx(L, idx, cpp.Pointer.addressOf(isnum).ptr);
	}

	@:native("lua_tovector")
	static function _tovector(L:State, idx:Int):cpp.ConstPointer<cpp.Float32>;

	static inline function tovector(L:State, idx:Int):Vector<Float> {
		var p = _tovector(L, idx);
		var rv:Vector<Float> = null;
		if (p != null) {
			if (LuaDefines.VECTOR_SIZE == 3) {
				rv = new Vector<Float>(3);
			} else {
				rv = new Vector<Float>(4);
			}
			rv[0] = p.get_value();
			p.inc();
			rv[1] = p.get_value();
			p.inc();
			rv[2] = p.get_value();
			if (LuaDefines.VECTOR_SIZE == 4) {
				p.inc();
				rv[3] = p.get_value();
			}
			return rv;
		}
		return null;
	}

	@:native("lua_toboolean")
	static function toboolean(L:State, idx:Int):Bool;

	@:native("lua_tolstring")
	static function _tolstring(L:State, idx:Int, len:cpp.Star<CSizeT>):CString;

	static inline function tolstring(L:State, idx:Int, len:Ref<CSizeT>):CString {
		return _tolstring(L, idx, cpp.Pointer.addressOf(len).ptr);
	}

	@:native("lua_tostringatom")
	static function _tostringatom(L:State, idx:Int, atom:cpp.Star<Int>):CString;

	static inline function tostringatom(L:State, idx:Int, atom:Ref<Int>):CString {
		return _tostringatom(L, idx, cpp.Pointer.addressOf(atom).ptr);
	}

	@:native("lua_tolstringatom")
	static function _tolstringatom(L:State, idx:Int, len:cpp.Star<CSizeT>, atom:cpp.Star<Int>):CString;

	static inline function tolstringatom(L:State, idx:Int, len:Ref<CSizeT>, atom:Ref<Int>):CString {
		return _tolstringatom(L, idx, cpp.Pointer.addressOf(len).ptr, cpp.Pointer.addressOf(atom).ptr);
	}

	@:native("lua_namecallatom")
	static function namecallatom(L:State, atom:Ref<Int>):CString;

	@:native("lua_objlen")
	static function objlen(L:State, idx:Int):Int;

	// FIXME this is not a good return type. It works but it should match
	//       the pushcfunction signature, LuaHaxeStaticFunction.
	@:native("lua_tocfunction")
	static function tocfunction(L:State, idx:Int):LuaHaxeStaticRetFunction;

	@:native("lua_tolightuserdata")
	static function _tolightuserdata(L:State, idx:Int):cpp.RawPointer<Void>;

	static inline function tolightuserdata<T:Any>(L:State, idx:Int):T {
		var ptr:cpp.Pointer<T> = cast cpp.Pointer.fromRaw(_tolightuserdata(L, idx));
		return ptr.value;
	}

	@:native("lua_tolightuserdatatagged")
	static function _tolightuserdatatagged(L:State, idx:Int, tag:Int):cpp.RawPointer<cpp.Void>;

	static inline function tolightuserdatatagged<T:Any>(L:State, idx:Int, tag:Int):T {
		var ptr:cpp.Pointer<T> = cast cpp.Pointer.fromRaw(_tolightuserdatatagged(L, idx, tag));
		return ptr.value;
	}

	@:native("lua_touserdata")
	static function touserdata(L:State, idx:Int):cpp.Pointer<Void>;

	@:native("lua_touserdatatagged")
	static function touserdatatagged(L:State, idx:Int, tag:Int):cpp.Pointer<Void>;

	@:native("lua_userdatatag")
	static function userdatatag(L:State, idx:Int):Int;

	@:native("lua_lightuserdatatag")
	static function lightuserdatatag(L:State, idx:Int):Int;

	@:native("lua_tothread")
	static function tothread(L:State, idx:Int):State;

	@:native("lua_tobuffer")
	static function _tobuffer(L:State, idx:Int, size:cpp.Star<CSizeT>):cpp.Pointer<Void>;

	static inline function tobuffer(L:State, idx:Int, size:Ref<CSizeT>):cpp.Pointer<Void> {
		return _tobuffer(L, idx, cpp.Pointer.addressOf(size).ptr);
	}

	@:native("lua_topointer")
	static function topointer(L:State, idx:Int):cpp.Pointer<Void>;

	/*
	 * Push functions (C -> stack)
	 */
	@:native("lua_pushnil")
	static function pushnil(L:State):Void;

	@:native("lua_pushnumber")
	static function pushnumber(L:State, n:LuaNumber):Void;

	@:native("lua_pushinteger")
	static function pushinteger(L:State, n:LuaInteger):Void;

	@:native("lua_pushunsigned")
	static function pushunsigned(L:State, n:LuaUnsigned):Void;

	// FIXME this is a problem - you cannot use a cpp #def
	//       here as a compile time #if predicate.
	//       Need to find another way to do this.
	// if (LuaDefines.VECTOR_SIZE == 4) {
	// 	@:native("lua_pushvector")
	// 	static function pushvector(L:State, x:Float, y:Float, z:Float, w:Float):Void;
	// } else {
	@:native("lua_pushvector")
	static function pushvector(L:State, x:Float, y:Float, z:Float):Void;

	// }
	@:native("lua_pushlstring")
	static function pushlstring(L:State, s:CString, len:CSizeT):Void;

	@:native("lua_pushstring")
	static function pushstring(L:State, s:CString):Void;

	// @:native("lua_pushvfstring")
	// static function _pushvfstring(L:State, fmt:CString, va_list:CVarList):CString;
	// static inline function pushvfstring(L:State, fmt:CString, ...va_list:Any):Void {
	// 	// var args:Array<Any> = va_list;
	// 	_pushvfstring(L, fmt, va_list);
	// }
	// @:native("lua_pushfstringL")
	// static function pushfstringL(L:State, fmt:CString, args:haxe.Rest<Any>):CString;
	// FIXME - need to figure out how to get cpp.Callable working here
	// @:native("lua_pushcclosurek")
	// static function _pushcclosurek(L:State, f:cpp.Callable<LuaCFunction>, debugName:CString, nup:Int, cont:LuaCContinuation):Void;
	// static inline function pushcclosurek(L:State, f:LuaCFunction, debugName:CString, nup:Int, cont:LuaCContinuation):Void {
	// 	var fc = cpp.Callable.fromFunction(f);
	// 	_pushcclosurek(L, fc, debugName, nup, cont);
	// }
	@:native("lua_pushboolean")
	static function pushboolean(L:State, b:Bool):Void;

	@:native("lua_pushthread")
	static function pushthread(L:State):Void;

	@:native("lua_pushlightuserdatatagged")
	static function _pushlightuserdatatagged(L:State, p:cpp.RawPointer<cpp.Void>, tag:Int):Void;

	static inline function pushlightuserdatatagged<T:Any>(L:State, p:Ref<T>, tag:Int):Void {
		var ptr:cpp.RawPointer<cpp.Void> = cast cpp.RawPointer.addressOf(p);
		_pushlightuserdatatagged(L, ptr, tag);
	}

	@:native("lua_newuserdatatagged")
	static function newuserdatatagged(L:State, sz:CSizeT, tag:Int):cpp.Pointer<Void>;

	@:native("lua_newuserdatataggedwithmetatable")
	static function newuserdatataggedwithmetatable(L:State, sz:CSizeT, tag:Int):cpp.Pointer<Void>;

	@:native("lua_newuserdatadtor")
	static function newuserdatadtor(L:State, sz:CSizeT, dtor:LuaCFunction):cpp.Pointer<Void>;

	@:native("lua_newbuffer")
	static function newbuffer(L:State, sz:CSizeT):cpp.Pointer<Void>;

	/*
	 * Get functions (Lua -> stack)
	 */
	@:native("lua_gettable")
	static function gettable(L:State, idx:Int):Int;

	@:native("lua_getfield")
	static function getfield(L:State, idx:Int, k:CString):Int;

	@:native("lua_rawgetfield")
	static function rawgetfield(L:State, idx:Int, k:CString):Int;

	@:native("lua_rawget")
	static function rawget(L:State, idx:Int):Int;

	@:native("lua_rawgeti")
	static function rawgeti(L:State, idx:Int, n:LuaInteger):Int;

	@:native("lua_createtable")
	static function createtable(L:State, narray:Int, nrec:Int):Void;

	@:native("lua_setreadonly")
	static function setreadonly(L:State, idx:Int, enabled:Int):Void;

	@:native("lua_getreadonly")
	static function getreadonly(L:State, idx:Int):Int;

	@:native("lua_setsafeenv")
	static function setsafeenv(L:State, idx:Int, enabled:Int):Void;

	@:native("lua_getmetatable")
	static function getmetatable(L:State, objindex:Int):Int;

	@:native("lua_getfenv")
	static function getfenv(L:State, idx:Int):Void;

	/*
	 * Set functions (stack -> Lua)
	 */
	@:native("lua_settable")
	static function settable(L:State, idx:Int):Void;

	@:native("lua_setfield")
	static function setfield(L:State, idx:Int, k:CString):Void;

	@:native("lua_rawsetfield")
	static function rawsetfield(L:State, idx:Int, k:CString):Void;

	@:native("lua_rawset")
	static function rawset(L:State, idx:Int):Void;

	@:native("lua_rawseti")
	static function rawseti(L:State, idx:Int, n:LuaInteger):Void;

	@:native("lua_setmetatable")
	static function setmetatable(L:State, objindex:Int):Int;

	@:native("lua_setfenv")
	static function setfenv(L:State, idx:Int):Int;

	/*
	 * `load` and `call` functions (load and run Luau bytecode)
	 */
	@:native("luau_load")
	static function _load(L:State, name:String, bytecode:Bytecode, bytecodeSize:CSizeT, mode:Int):Int;

	/**
	 * Load a chunk of compiled bytecode.
	 * @param L the Lua state
	 * @param name an identifier to include in error messages
	 * @param bytecode the compiled bytecode and its size
	 * @param env 0 for the current environment or a stack index pointing
	 * to a table to use as the environment
	 * @return Int 0 for success, and 1 for failure. Note, this is not a
	 * LuaStatus value. This is a Luau function not a Lua one.
	 */
	static inline function load(L:State, name:String, bytecode:Code, env:Int):Int {
		return _load(L, name, bytecode.code, bytecode.size, env);
	}

	/**
	 * Call a function.
	 *
	 * @param L The Lua state.
	 * @param nargs The number of arguments.
	 * @param nresults The number of results.
	 */
	@:native('lua_call')
	static function call(L:State, nargs:Int, nresults:Int):Void;

	@:native("lua_pcall")
	static function pcall(L:State, nargs:Int, nresults:Int, errfunc:Int):Int;

	@:native("lua_cpcall")
	static function cpcall(L:State, f:LuaCFunction, ud:cpp.Pointer<Void>):Int;

	/*
	 * coroutine functions
	 */
	@:native("lua_yield")
	static function yield(L:State, nresults:Int):Int;

	@:native("lua_break")
	static function break_(L:State):Int;

	@:native("lua_resume")
	static function resume(L:State, from:State, nargs:Int):Int;

	@:native("lua_resumeerror")
	static function resumeerror(L:State, from:State):Int;

	@:native("lua_status")
	static function status(L:State):Int;

	@:native("lua_isyieldable")
	static function isyieldable(L:State):Int;

	@:native("lua_getthreaddata")
	static function getthreaddata(L:State):cpp.Pointer<Void>;

	@:native("lua_setthreaddata")
	static function setthreaddata(L:State, data:cpp.Pointer<Void>):Void;

	@:native("lua_costatus")
	static function costatus(L:State, co:State):Int;

	@:native("lua_gc")
	static function gc(L:State, what:Int, data:Int):Void;

	/*
	 * memory statistics
	 * all allocated bytes are attributed to the memory category of the running thread (0..LUA_MEMORY_CATEGORIES-1)
	 */
	@:native("lua_setmemcat")
	static function setmemcat(L:State, category:Int):Void;

	@:native("lua_totalbytes")
	static function totalbytes(L:State, category:Int):CSizeT;

	/*
	 * miscellaneous functions
	 */
	// FIXME what is l_noret ?
	@:native("lua_error")
	static function error(L:State):Int;

	@:native("lua_next")
	static function next(L:State, idx:Int):Int;

	@:native("lua_rawiter")
	static function rawiter(L:State, idx:Int, iter:Int):Int;

	@:native("lua_concat")
	static function concat(L:State, n:Int):Void;

	// FIXME this is a strange one - return is supposed to be uintptr_t
	@:native("lua_encodepointer")
	static function encodepointer(L:State, p:cpp.Pointer<Void>):CString;

	@:native("lua_clock")
	static function clock():Float;

	@:native("lua_setuserdatatag")
	static function setuserdatatag(L:State, idx:Int, tag:Int):Void;

	// FIXME - this and the next two all need a lot of help
	@:native("lua_destructor")
	static function destructor(L:State, idx:Int):LuaCFunction;

	@:native("lua_setuserdatadtor")
	static function setuserdatadtor(L:State, idx:Int, dtor:LuaCFunction):Void;

	@:native("lua_getuserdatadtor")
	static function getuserdatadtor(L:State, tag:Int):LuaCFunction;

	// alternative access for metatables already registered with luaL_newmetatable
	// used by lua_newuserdatataggedwithmetatable to create tagged userdata with the associated metatable assigned
	@:native("lua_setuserdatametatable")
	static function setuserdatametatable(L:State, tag:Int):Void;

	@:native("lua_getuserdatametatable")
	static function getuserdatametatable(L:State, tag:Int):Void;

	@:native("lua_setlightuserdataname")
	static function setlightuserdataname(L:State, tag:Int, name:CString):Void;

	@:native("lua_getlightuserdataname")
	static function getlightuserdataname(L:State, tag:Int):CString;

	@:native("lua_clonefunction")
	static function clonefunction(L:State, idx:Int):Void;

	@:native("lua_cleartable")
	static function cleartable(L:State, idx:Int):Void;

	@:native("lua_clonetable")
	static function clonetable(L:State, idx:Int):Void;

	// FIXME this is going to need a ptr to ptr to void
	// @:native("lua_getallocf")
	// static function getallocf(L:State):LuaAlloc;
	/*
	 * reference system, can be used to pin objects
	 */
	@:native("lua_ref")
	static function ref(L:State, idx:Int):Int;

	@:native("lua_unref")
	static function unref(L:State, ref:Int):Void;

	@:native("lua_getref")
	static function getref(L:State, ref:Int):Int;

	/*
	 * some useful macros
	 */
	/**
	 * Convert a value to a number.
	 *
	 * @param L The Lua state.
	 * @param idx The index of the value.
	 * @return The number.
	 */
	@:native("lua_tonumber")
	static function tonumber(L:State, idx:Int):Float;

	@:native("lua_tointeger")
	static function tointeger(L:State, idx:Int):Int;

	/**
	 * Convert the value at the given index to an unsigned integer.
	 *
	 * Note, that on Haxe the exact behaviour here maybe a little odd.
	 * If you get a UInt and then use it in an Int context it will be
	 * converted to a regular 32 signed int on, for example cpp. This may
	 * result in negative numbers where you expect positive.
	 * 
	 * @param L the Lua state
	 * @param idx the index of the value to convert
	 * @return UInt the converted value
	 */
	@:native("lua_tounsigned")
	static function tounsigned(L:State, idx:Int):UInt;

	/**
	 * Pop n elements from the stack.
	 *
	 * @param L The Lua state.
	 * @param n The number of elements to pop.
	 */
	@:native("lua_pop")
	static function pop(L:State, n:Int):Void;

	@:native("lua_newtable")
	static function newtable(L:State):Void;

	@:native("lua_newuserdata")
	static function newuserdata(L:State, sz:CSizeT):cpp.Pointer<Void>;

	@:native("lua_strlen")
	static function strlen(L:State, idx:Int):CSizeT;

	@:native("lua_isfunction")
	static function isfunction(L:State, idx:Int):Int;

	@:native("lua_istable")
	static function istable(L:State, idx:Int):Int;

	@:native("lua_islightuserdata")
	static function islightuserdata(L:State, idx:Int):Int;

	@:native("lua_isnil")
	static function isnil(L:State, idx:Int):Int;

	@:native("lua_isboolean")
	static function isboolean(L:State, idx:Int):Int;

	@:native("lua_isvector")
	static function isvector(L:State, idx:Int):Int;

	@:native("lua_isthread")
	static function isthread(L:State, idx:Int):Int;

	@:native("lua_isbuffer")
	static function isbuffer(L:State, idx:Int):Bool;

	@:native("lua_isnone")
	static function isnone(L:State, idx:Int):Int;

	@:native("lua_isnoneornil")
	static function isnoneornil(L:State, idx:Int):Int;

	@:native("lua_pushliteral")
	static function pushliteral(L:State, s:CString):Void;

	/**
	 * Push a C function onto the stack.
	 * @param L the Lua state
	 * @param f note that this must be a static function
	 * @param debugName a name for debugging purposes
	 */
	@:native("pushcfunction_wrapper")
	static function pushcfunction(L:State, f:LuaHaxeStaticFunction, debugName:CString):Void;

	@:native("lua_pushcclosure")
	static function pushcclosure(L:State, f:cpp.Callable<LuaCFunction>, n:Int):Void;

	@:native("lua_pushlightuserdata")
	static function _pushlightuserdata(L:State, p:cpp.RawPointer<cpp.Void>):Void;

	static inline function pushlightuserdata<T:Any>(L:State, p:T):Void {
		var ptr:cpp.RawPointer<cpp.Void> = cast cpp.RawPointer.addressOf(p);
		_pushlightuserdata(L, ptr);
	}

	@:native("lua_setglobal")
	static function setglobal(L:State, s:CString):Int;

	/**
	 * Get a global value.
	 *
	 * @param L The Lua state.
	 * @param s The name of the global.
	 * @return The result of the operation.
	 */
	@:native('lua_getglobal')
	static function getglobal(L:State, s:CString):Int;

	@:native("lua_tostring")
	static function tostring(L:State, idx:Int):CString;

	@:native("lua_pushfstring")
	static function pushfstring(L:State, fmt:CString, ...args):Void;

	/*
	 * Debug API
	 */
	@:native("lua_stackdepth")
	static function stackdepth(L:State):Int;

	// @:native("lua_getinfo")
	// static function getinfo(L:State, what:CString, ar:Ref<LuaDebug>):Int;
	@:native("lua_getargument")
	static function getargument(L:State, level:Int, n:Int):Int;

	@:native("lua_getlocal")
	static function getlocal(L:State, level:Int, n:Int):CString;

	@:native("lua_setlocal")
	static function setlocal(L:State, level:Int, n:Int):CString;

	@:native("lua_getupvalue")
	static function getupvalue(L:State, funcindex:Int, n:Int):CString;

	@:native("lua_setupvalue")
	static function setupvalue(L:State, funcindex:Int, n:Int):CString;

	@:native("lua_singlestep")
	static function singlestep(L:State, enabled:Int):Void;

	@:native("lua_breakpoint")
	static function breakpoint(L:State, funcindex:Int, line:Int, enabled:Int):Int;

	// @:native("lua_getcoverage")
	// static function getcoverage(L:State, funcindex:Int, context:cpp.Pointer<Void>, callback:LuaCoverageCallback):Void;
	@:native("lua_debugtrace")
	static function debugtrace(L:State):CString;

	// FIXME - this doesn't work yet.
	@:native("lua_callbacks")
	static function callbacks(L:State):cpp.Pointer<LuaCallbacks>;
}
