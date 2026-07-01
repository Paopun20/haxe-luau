package;

import hxluau.Lua.LuaType;
import hxluau.Lua.State;
import hxluau.Lua;
import hxluau.LuaCode.CompileOptions;
import hxluau.LuaCode;
import utest.Assert;
import utest.Test;

// FIXME go through and clean up
//       verify all tests are useful, add missing tests
class TestGetFunctions extends Test {
	var L:State;

	public function setup() {
		L = Lua.newstate();
	}

	public function teardown() {
		Lua.close(L);
	}

	public function testGetGlobal() {
		Lua.pushnumber(L, 42);
		Lua.setglobal(L, "myglobal");
		var result = Lua.getglobal(L, "myglobal");
		Assert.equals(LuaType.NUMBER, Lua.type(L, -1));
		Assert.equals(42.0, Lua.tonumber(L, -1));
		Lua.pop(L, 1);
	}

	public function testGetField() {
		Lua.createtable(L, 0, 1);
		Lua.pushnumber(L, 123);
		Lua.setfield(L, -2, "foo");
		var ret = Lua.getfield(L, -1, "foo");
		Assert.equals(LuaType.NUMBER, ret, 'getfield return ${ret} instead of NUMBER');
		Assert.equals(LuaType.NUMBER, Lua.type(L, -1));
		Assert.equals(123.0, Lua.tonumber(L, -1));
		Lua.pop(L, 2);
	}

	public function testRawGetField() {
		Lua.createtable(L, 0, 1);
		Lua.pushnumber(L, 99);
		Lua.setfield(L, -2, "bar");
		var ret = Lua.rawgetfield(L, -1, "bar");
		Assert.equals(LuaType.NUMBER, ret, 'getfield return ${ret} instead of TNUMBER');
		Assert.equals(LuaType.NUMBER, Lua.type(L, -1));
		Assert.equals(99.0, Lua.tonumber(L, -1));
		Lua.pop(L, 2);
	}

	public function testRawGet() {
		// Create table and set value
		Lua.createtable(L, 1, 0);
		Lua.pushnumber(L, 7);
		Lua.rawseti(L, -2, 1);

		// Push key to get and then get the value
		Lua.pushnumber(L, 1);
		// Verify result
		var ret = Lua.rawget(L, -2);
		Assert.equals(LuaType.NUMBER, ret, 'rawget returned ${ret} instead of TNUMBER');
		Assert.equals(LuaType.NUMBER, Lua.type(L, -1));
		Assert.equals(7.0, Lua.tonumber(L, -1));
		Lua.pop(L, 1);
	}

	public function testRawGetI() {
		Lua.createtable(L, 1, 0);
		Lua.pushnumber(L, 55);
		Lua.rawseti(L, -2, 1);
		var ret = Lua.rawgeti(L, -1, 1);
		Assert.equals(LuaType.NUMBER, ret, 'rawget returned ${ret} instead of TNUMBER');
		Assert.equals(LuaType.NUMBER, Lua.type(L, -1));
		Assert.equals(55.0, Lua.tonumber(L, -1));
		Lua.pop(L, 2);
	}

	public function testCreateTable() {
		Lua.createtable(L, 2, 2);
		Assert.equals(LuaType.TABLE, Lua.type(L, -1));
		Lua.pop(L, 1);
	}

	public function testGetMetatable() {
		Lua.createtable(L, 0, 0);
		Lua.createtable(L, 0, 0);
		var retSet = Lua.setmetatable(L, -2);
		Assert.equals(1, retSet, "setmetatable should return 1 on success");
		var hasMeta = Lua.getmetatable(L, -1);
		Assert.equals(1, hasMeta);
		Assert.equals(LuaType.TABLE, Lua.type(L, -1));
		Lua.pop(L, 2);
	}

	public function testGetFenv() {
		// Push a Lua function
		var source = "function fooLuaFn() return 42 end";
		var options:CompileOptions = CompileOptions.create();
		var byteCode = LuaCode.compile(source, source.length, options);
		var r = Lua.load(L, "code", byteCode, 0);

		// Now get its environment
		Lua.getfenv(L, -1);
		var t = Lua.type(L, -1);
		Assert.equals(LuaType.TABLE, t);
	}

	public function testGetReadonlySetReadonly() {
		Lua.createtable(L, 0, 0);
		Lua.setreadonly(L, -1, 1);
		var readonly = Lua.getreadonly(L, -1);
		Assert.equals(1, readonly);
		Lua.setreadonly(L, -1, 0);
		readonly = Lua.getreadonly(L, -1);
		Assert.equals(0, readonly);
		Lua.pop(L, 1);
	}

	public function testGetTable() {
		Lua.createtable(L, 0, 1);
		Lua.pushnumber(L, 77);
		Lua.setfield(L, -2, "baz");
		Lua.pushstring(L, "baz");
		var ret = Lua.gettable(L, -2);
		Assert.equals(LuaType.NUMBER, ret, 'gettable returned ${ret} instead of NUMBER');
		Assert.equals(LuaType.NUMBER, Lua.type(L, -1));
		Assert.equals(77.0, Lua.tonumber(L, -1));
		Lua.pop(L, 2);
	}

	/**
	 * Test that setting safeenv isolates the globals in this env
	 * 
	 * FIXME I do not understand what safeenv does
	 * conformance tests seem to incdicate you need Lua code to test this
	 * refer https://github.com/luau-lang/luau/blob/994b6416f1a2d16ac06c52b4e574bad5d8749053/tests/Conformance.test.cpp#L3247C1-L3251C1
	 */
	public function testSetSafeEnv() {
		// Set a global value
		Lua.pushnumber(L, 12);
		Lua.setglobal(L, "global_foo");
		Lua.createtable(L, 1, 0);

		// now get the global through the local table
		Lua.getfield(L, -1, "global_foo");
		trace('global_foo through local table: ${Lua.tonumber(L, -1)}');
		Lua.getglobal(L, "global_foo");
		trace('global_foo through globals: ${Lua.tonumber(L, -1)}');

		// Lua.rawseti(L, -2, 1);
		// Lua.setsafeenv(L, -1, 1);
		// No direct get function, but can check readonly
		// var readonly = Lua.getreadonly(L, -1);
		// Assert.equals(1, readonly);
		// Lua.setsafeenv(L, -1, 0);
		// readonly = Lua.getreadonly(L, -1);
		// Assert.equals(0, readonly);

		// Lua.pop(L, 1);
	}
}
