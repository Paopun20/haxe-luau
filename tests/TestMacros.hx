package;

import hxluau.Lua.LuaStatus;
import hxluau.Lua.State;
import hxluau.Lua;
import utest.Assert;
import utest.Test;

class TestMacros extends Test {
	function testToNumber() {
		var L = Lua.newstate();
		Lua.pushstring(L, "42.5");
		var num = Lua.tonumber(L, -1);
		Assert.equals(42.5, num);
		Lua.close(L);
	}

	function testToInteger() {
		var L = Lua.newstate();
		Lua.pushstring(L, "123");
		var i = Lua.tointeger(L, -1);
		Assert.equals(123, i);
		Lua.close(L);
	}

	function testToUnsigned() {
		var L = Lua.newstate();
		Lua.pushstring(L, "4294967295");
		var u = Lua.tounsigned(L, -1);

		// Have to verify by direct comparison rather than using Assert.equals
		// because Assert.equals with cast to regular Int which in Haxe on cpp
		// would be a signed 32 bit it, so it will result in -1 being compared
		// with the expected 4294967295.
		var ok = u == 4294967295;
		Assert.isTrue(ok);
		Lua.close(L);
	}

	function testPop() {
		var L = Lua.newstate();
		Lua.pushnumber(L, 1);
		Lua.pushnumber(L, 2);
		Lua.pushnumber(L, 3);
		Assert.equals(3, Lua.gettop(L));
		Lua.pop(L, 2);
		Assert.equals(1, Lua.gettop(L));
		Lua.close(L);
	}

	function testNewTable() {
		var L = Lua.newstate();
		Lua.newtable(L);
		Assert.isTrue(Lua.istable(L, -1) == 1);
		Lua.close(L);
	}

	function testNewUserdata() {
		var L = Lua.newstate();
		var ptr = Lua.newuserdata(L, 16);
		Assert.notNull(ptr);
		Assert.isTrue(Lua.isuserdata(L, -1) == 1);
		Lua.close(L);
	}

	function testStrlen() {
		var L = Lua.newstate();
		Lua.pushstring(L, "hello world");
		var len = Lua.strlen(L, -1);
		Assert.equals(11, len);
		Lua.close(L);
	}

	function testIsNil() {
		var L = Lua.newstate();
		Lua.pushnil(L);
		Assert.isTrue(Lua.isnil(L, -1) == 1);
		Lua.pop(L, 1);
		Lua.close(L);
	}

	function testIsBoolean() {
		var L = Lua.newstate();
		Lua.pushboolean(L, true);
		Assert.isTrue(Lua.isboolean(L, -1) == 1);
		Lua.pop(L, 1);
		Lua.close(L);
	}

	function testIsNumber() {
		var L = Lua.newstate();
		Lua.pushnumber(L, 3.14);
		Assert.isTrue(Lua.isnumber(L, -1) == 1);
		Lua.pop(L, 1);
		Lua.close(L);
	}

	function testIsTable() {
		var L = Lua.newstate();
		Lua.newtable(L);
		Assert.isTrue(Lua.istable(L, -1) == 1);
		Lua.pop(L, 1);
		Lua.close(L);
	}

	function testIsString() {
		var L = Lua.newstate();
		Lua.pushstring(L, "str");
		Assert.isTrue(Lua.isstring(L, -1) == 1);
		Lua.pop(L, 1);
		Lua.close(L);
	}

	function testIsThread() {
		var L = Lua.newstate();
		Lua.pushthread(L);
		Assert.isTrue(Lua.isthread(L, -1) == 1);
		Lua.pop(L, 1);
		Lua.close(L);
	}

	function testIsUserdata() {
		var L = Lua.newstate();
		var ptr = Lua.newuserdata(L, 4);
		Assert.isTrue(Lua.isuserdata(L, -1) == 1);
		Lua.pop(L, 1);
		Lua.close(L);
	}

	// FIXME pointer types are wrong
	// function testIsLightUserdata() {
	// 	var L = Lua.newstate();
	// 	var n = 123;
	// 	var ptr = cpp.Pointer.addressOf(n);
	// 	Lua.pushlightuserdata(L, ptr);
	// 	Assert.isTrue(Lua.islightuserdata(L, -1) == 1);
	// 	Lua.pop(L, 1);
	// 	Lua.close(L);
	// }

	function testIsVector() {
		var L = Lua.newstate();
		Lua.pushvector(L, 1, 2, 3);
		Assert.isTrue(Lua.isvector(L, -1) == 1);
		Lua.pop(L, 1);
		Lua.close(L);
	}

	// FIXME - pushbuffer does not exit - how do we test this ?
	// function testIsBuffer() {
	// 	var L = Lua.newstate();
	// 	Lua.pushbuffer(L, 8);
	// 	Assert.isTrue(Lua.isbuffer(L, -1) == 1);
	// 	Lua.pop(L, 1);
	// 	Lua.close(L);
	// }

	function testIsNone() {
		var L = Lua.newstate();
		Lua.pushnil(L);
		Assert.isTrue(Lua.isnone(L, -1) == 0); // -1 is valid, so not none
		Lua.pop(L, 1);
		Lua.close(L);
	}

	function testIsNoneOrNil() {
		var L = Lua.newstate();
		Lua.pushnil(L);
		Assert.isTrue(Lua.isnoneornil(L, -1) == 1);
		Lua.pop(L, 1);
		Lua.close(L);
	}

	// FIXME generated code does not compile
	// function testPushLiteral() {
	// 	var L = Lua.newstate();
	// 	Lua.pushliteral(L, "lit");
	// 	Assert.equals("lit", Lua.tostring(L, -1));
	// 	Lua.pop(L, 1);
	// 	Lua.close(L);
	// }

	function testSetFieldGetField() {
		var L = Lua.newstate();
		Lua.newtable(L);
		Lua.pushstring(L, "val");
		Lua.setfield(L, -2, "key");
		Lua.getfield(L, -1, "key");
		Assert.equals("val", '${Lua.tostring(L, -1)}');
		Lua.pop(L, 2);
		Lua.close(L);
	}

	function testTolstring() {
		var L = Lua.newstate();
		Lua.pushstring(L, "abc");
		var len:Ref<CSizeT> = 0;
		var str:String = Lua.tolstring(L, -1, len);
		Assert.equals(3, len, "tolstring should set length to 3 for 'abc'");
		Assert.equals("abc", str, "tolstring should return 'abc'");
		Lua.settop(L, 0);
		Lua.close(L);
	}

	// FIXME needs more work to handle mixed types in the list of
	// arguments to pushfstring
	// Of course this isn't that necessary as you can format in Haxe
	// and then just pushstring.
	// function testPushFString() {
	// 	var L = Lua.newstate();
	// 	Lua.pushfstring(L, "Hello %s %d", "world", 123);
	// 	Assert.equals("Hello world 123", Lua.tostring(L, -1));
	// 	Lua.pop(L, 1);
	// 	Lua.close(L);
	// }
	// Test value for member functions as C functions
	var memberVar:String = "";

	public function cFunc(L:State):Int {
		trace('I got called');
		trace('L=${L}');
		Lua.pushnumber(L, 423);
		trace('after push in cFunc:L(-1) type=${Lua.type(L, -1)}');
		trace('after push in cFunc:L(-1) value=${Lua.tonumber(L, -1)}');
		memberVar = "called";
		return 1;
	}

	function testPushMemberFunction() {
		var L = Lua.newstate();
		// Set up the C function in the stack
		trace('about to call shim');
		Lua.pushcfunction(L, cFunc, "cFunc");
		trace('called shim');
		trace('L=${L}');
		var rv = Lua.pcall(L, 0, 1, 0);
		trace('called call rv=${rv}, LUA_OK=${LuaStatus.OK}');

		// Check the stack top after invocation
		trace('L(-1) type=${Lua.type(L, -1)}');
		trace('gettop=${Lua.gettop(L)}');
		trace(Lua.type(L, 1));
		trace(Lua.tonumber(L, 1));

		// Verify the results
		Assert.equals(LuaType.NUMBER, Lua.type(L, Lua.gettop(L)), "After calling cFunc, top of stack should be a number");
		Assert.equals(423.0, Lua.tonumber(L, Lua.gettop(L)), "After calling cFunc, top of stack should be 423");
		Assert.equals("called", memberVar, "memberVar should be set to 'called'");

		trace('about to run gc - should run finalizer');
		Lua.gc(L, LuaGCop.COLLECT, 0); // Force a GC to see if any issues occur
		trace('ran gc');

		// Clean up
		Lua.settop(L, 0);
		Lua.close(L);
	}

	function testPushMemberFunctionCallTwice() {
		var L = Lua.newstate();
		// Set up the C function in the stack and name it in the global table
		Lua.pushcfunction(L, cFunc, "cFunc");
		Lua.setglobal(L, "cFunc");

		// Invoke the C function the first time
		Lua.getglobal(L, "cFunc");
		var rv = Lua.pcall(L, 0, 1, 0);
		trace('called call rv=${rv}, LUA_OK=${LuaStatus.OK}');

		// Verify first call results
		Assert.equals(LuaType.NUMBER, Lua.type(L, Lua.gettop(L)), "After calling cFunc, top of stack should be a number");
		Assert.equals(423.0, Lua.tonumber(L, Lua.gettop(L)), "After calling cFunc, top of stack should be 423");

		Lua.pop(L, 1); // pop the result

		trace('about to run gc - should not run finalizer');
		Lua.gc(L, LuaGCop.COLLECT, 0); // Force a GC to see if any issues occur
		trace('ran gc');

		// Invoke the C function a second time
		Lua.getglobal(L, "cFunc");
		rv = Lua.pcall(L, 0, 1, 0);
		trace('called call rv=${rv}, LUA_OK=${LuaStatus.OK}');

		// Verify second call results
		Assert.equals(LuaType.NUMBER, Lua.type(L, Lua.gettop(L)), "After calling cFunc, top of stack should be a number");
		Assert.equals(423.0, Lua.tonumber(L, Lua.gettop(L)), "After calling cFunc, top of stack should be 423");

		// Clean up
		Lua.settop(L, 0);
		Lua.close(L);
	}

	function testPushLocalCClosure() {
		var L = Lua.newstate();
		var called = false;
		var cfunc: hxluau.Lua.LuaCFunction = function(L) {
			called = true;
			return 0;
		};
		Lua.pushcfunction(L, cfunc, "localCClosure");
		Assert.isTrue(Lua.iscfunction(L, -1) == 1);
		Lua.pcall(L, 0, 0, 0);
		Assert.isTrue(called);
		Lua.pop(L, 1);
		Lua.close(L);
	}

	static public function staticCFunc(L:State):Int {
		trace('I got called (static)');
		Lua.pushnumber(L, 524);
		return 1;
	}

	function testPushStaticFunction() {
		var L = Lua.newstate();

		Lua.pushcfunction(L, staticCFunc, "staticCFunc");
		var rc = Lua.pcall(L, 0, 1, 0);
		Assert.equals(0, rc, "pcall should return 0");
		Assert.equals(524.0, Lua.tonumber(L, Lua.gettop(L)), "After calling cFunc, top of stack should be 524");
		trace('asserts passed');

		Lua.pop(L, 1);
		Lua.close(L);
	}

	function testPushLightUserdata() {
		var L = Lua.newstate();
		var n:Ref<Int> = 123;
		Lua.pushlightuserdata(L, n);
		Assert.isTrue(Lua.islightuserdata(L, -1) == 1);
		Lua.pop(L, 1);
		Lua.close(L);
	}

	function testMultipleInstances() {
		var f1 = new Baa("first");
		var f2 = new Baa("second");

		var L = Lua.newstate();

		Lua.pushcfunction(L, f1.getName, "getFirstBaaName");
		Lua.setglobal(L, "getFirstBaaName");
		Lua.pushcfunction(L, f2.getName, "getSecondBaaName");
		Lua.setglobal(L, "getSecondBaaName");

		// Call first function
		Lua.getglobal(L, "getFirstBaaName");
		Lua.pcall(L, 0, 1, 0);
		Assert.equals("first", '${Lua.tostring(L, -1)}');
		Lua.pop(L, 1);

		// Call second function
		Lua.getglobal(L, "getSecondBaaName");
		Lua.pcall(L, 0, 1, 0);
		Assert.equals("second", '${Lua.tostring(L, -1)}');
		Lua.pop(L, 1);

		Lua.close(L);
	}
}

class Baa {
	public var _name:String;

	public function new(name:String) {
		_name = name;
	}

	public function getName(L:State):Int {
		Lua.pushstring(L, _name);
		return 1;
	}
}
