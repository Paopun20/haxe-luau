package;

import hxluau.Lua;
import hxluau.LuaCode;
import hxluau.Lualib;
import hxluau.LuaCode.CompileOptions;
import utest.Assert;
import utest.Test;

class TestPushFunctions extends Test {
	function testPushNil() {
		var L = Lua.newstate();
		Lua.pushnil(L);
		Assert.equals(LuaType.NIL, Lua.type(L, -1), "pushnil should push nil");
		Lua.settop(L, 0);
		Lua.close(L);
	}

	function testPushNumber() {
		var L = Lua.newstate();
		Lua.pushnumber(L, 3.14);
		Assert.equals(LuaType.NUMBER, Lua.type(L, -1), "pushnumber should push a number");
		Assert.equals(3.14, Lua.tonumber(L, -1));
		Lua.settop(L, 0);
		Lua.close(L);
	}

	function testPushNumberToFunction() {
		var L = Lua.newstate();
		Lualib.openlibs(L);
		var source = "function add2(x) print('jhe' .. x); return x + 2; end";
		var options:CompileOptions = CompileOptions.create();
		var code = LuaCode.compile(source, source.length, options);
		var status = Lua.load(L, "chunk", code, 0);
		trace('status after load is ' + status);
		Assert.equals(0, status);
		Lua.call(L, 0, 0); // call the chunk to define the function

		var rc = Lua.getglobal(L, "add2"); // push the function onto the stack
		trace('after getglobal, top of stack is ' + Lua.gettop(L) + ', rc=' + rc);

		Lua.pushnumber(L, 3.14);

		Lua.call(L, 1, 1);
		trace('after pcall, type of top of stack is ' + Lua.type(L, -1));
		Assert.equals(5.14, Lua.tonumber(L, -1));

		Lua.settop(L, 0);
		Lua.close(L);
	}

	function testPushInteger() {
		var L = Lua.newstate();
		Lua.pushinteger(L, 42);
		Assert.equals(LuaType.NUMBER, Lua.type(L, -1), "pushinteger should push a number");
		Assert.equals(42, Lua.tonumber(L, -1));
		Lua.settop(L, 0);
		Lua.close(L);
	}

	function testPushUnsigned() {
		var L = Lua.newstate();
		Lua.pushunsigned(L, 123);
		Assert.equals(LuaType.NUMBER, Lua.type(L, -1), "pushunsigned should push a number");
		Assert.equals(123, Lua.tonumber(L, -1));
		Lua.settop(L, 0);
		Lua.close(L);
	}

	function testPushVector() {
		var L = Lua.newstate();
		#if (LuaDefines.VECTOR_SIZE == 4)
		Lua.pushvector(L, 1, 2, 3, 4);
		var vec = Lua.tovector(L, -1);
		Assert.equals(4, vec.length);
		Assert.equals(1, vec[0]);
		Assert.equals(2, vec[1]);
		Assert.equals(3, vec[2]);
		Assert.equals(4, vec[3]);
		#else
		Lua.pushvector(L, 1, 2, 3);
		var vec = Lua.tovector(L, -1);
		Assert.equals(3, vec.length);
		Assert.equals(1, vec[0]);
		Assert.equals(2, vec[1]);
		Assert.equals(3, vec[2]);
		#end
		Lua.settop(L, 0);
		Lua.close(L);
	}

	function testPushLString() {
		var L = Lua.newstate();
		Lua.pushlstring(L, "abc", 3);
		var str:String = Lua.tostring(L, -1);
		Assert.equals("abc", str);
		Lua.settop(L, 0);
		Lua.close(L);
	}

	function testPushString() {
		var L = Lua.newstate();
		Lua.pushstring(L, "hello");
		var str:String = Lua.tostring(L, -1);
		Assert.equals("hello", str);
		Lua.settop(L, 0);
		Lua.close(L);
	}

	// FIXME figure this out
	// pushvfstring, pushfstringL are not really necessary as you can
	// use pushstring after formatting in Haxe. And variadics are hard to
	// map to Haxe Rest arguments.
	// FIXME this does not yet work.
	// function testPushFStringL() {
	// 	var L = Lua.newstate();
	// 	Lua.pushfstringL(L, "Name: %d Value: %d", 12, 42, 17);
	// 	var str:String = Lua.tostring(L, -1);
	// 	Assert.equals("Name: Fred Value: 42", str);
	// 	Lua.settop(L, 0);
	// 	Lua.close(L);
	// }
	// fixme reinstate once we work this out
	// static function getClosure():LuaCFunction {
	// 	var x = 12;
	// 	function closure(L:State):Int {
	// 		return x + 12;
	// 	}
	// 	return closure;
	// }

	/* FIXME - need to get a closure pointer or callable
		function testPushCClousureK() {
			var L = Lua.newstate();
			var c:LuaCFunction = getClosure();
			// var cd:cpp.Callable.CallableData<LuaCFunction> = c;
			// var callable:cpp.Callable<LuaCFunction> = cd;
			Lua.pushcclosurek(L, c, "closuretest", 0, null);
	}*/
	function testPushBoolean() {
		var L = Lua.newstate();
		Lua.pushboolean(L, true);
		Assert.equals(LuaType.BOOLEAN, Lua.type(L, -1));
		Assert.equals(1, Lua.toboolean(L, -1));
		Lua.settop(L, 0);
		Lua.pushboolean(L, false);
		Assert.equals(0, Lua.toboolean(L, -1));
		Lua.settop(L, 0);
		Lua.close(L);
	}

	function testPushThread() {
		var L = Lua.newstate();
		Lua.pushthread(L);
		Assert.equals(LuaType.THREAD, Lua.type(L, -1));
		Lua.settop(L, 0);
		Lua.close(L);
	}

	// Tested in TestAccessFunctions
	// 	Lua.pushlightuserdatatagged(L, ptr, 99);

	function testNewUserdataTagged() {
		var L = Lua.newstate();
		var tag = 77;
		var ptr = Lua.newuserdatatagged(L, 8, tag);
		Assert.notNull(ptr);
		Assert.equals(tag, Lua.userdatatag(L, -1));
		Lua.settop(L, 0);
		Lua.close(L);
	}

	function testNewUserdataTaggedWithMetatable() {
		var L = Lua.newstate();
		var tag = 88;
		var ptr = Lua.newuserdatataggedwithmetatable(L, 8, tag);
		Assert.notNull(ptr);
		Assert.equals(tag, Lua.userdatatag(L, -1));
		Lua.settop(L, 0);
		Lua.close(L);
	}

	// FIXME looks weak
	function testNewUserdataDtor() {
		var L = Lua.newstate();
		var ptr = Lua.newuserdatadtor(L, 8, null);
		Assert.notNull(ptr);
		Lua.settop(L, 0);
		Lua.close(L);
	}

	// FIXME add this test when we resolve the pointer issues
	//       this should be done by calling a generic wrapper and
	//       having it get the pointers in the cpp impl.
	function testNewbuffer() {
		var L = Lua.newstate();
		var buf = Lua.newbuffer(L, 100);
		Assert.isTrue(Lua.isbuffer(L, -1), "top of stack should be a buffer");
		Lua.settop(L, 0);
		Lua.close(L);
	}
}
