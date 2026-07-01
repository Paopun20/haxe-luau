package;

import hxluau.Lua.LuaType;
import hxluau.Lua.State;
import hxluau.Lua;
import hxluau.LuaCode.CompileOptions;
import hxluau.Require;
import hxluau.LuaCode;
import hxluau.Lualib;
import hxluau.RequireCallbacks;
import sys.io.File;
import utest.Assert;
import utest.Test;

class TestLoadAndCall extends Test {
	var L:State;

	public function setup() {
		L = Lua.newstate();
	}

	public function teardown() {
		Lua.close(L);
	}

	public function testLoadAndCallSimpleChunk() {
		var source = "return 123";
		var options:CompileOptions = CompileOptions.create();
		var code = LuaCode.compile(source, source.length, options);
		var status = Lua.load(L, "chunk", code, 0);
		Assert.equals(0, status); // 0 for success
		Lua.call(L, 0, 1);
		Assert.equals(LuaType.NUMBER, Lua.type(L, -1));
		Assert.equals(123.0, Lua.tonumber(L, -1));
		Lua.pop(L, 1);
	}

	public function testLoadAndCallWithArgs() {
		var source = "local a, b = ...; return a + b";
		var options:CompileOptions = CompileOptions.create();
		var code = LuaCode.compile(source, source.length, options);
		var status = Lua.load(L, "chunk", code, 0);
		Assert.equals(0, status);
		Lua.pushnumber(L, 10);
		Lua.pushnumber(L, 32);
		Lua.call(L, 2, 1);
		Assert.equals(LuaType.NUMBER, Lua.type(L, -1));
		Assert.equals(42.0, Lua.tonumber(L, -1));
		Lua.pop(L, 1);
	}

	public function testLoadSyntaxError() {
		var source = "return =";
		var options:CompileOptions = CompileOptions.create();
		var code = LuaCode.compile(source, source.length, options);
		var status = Lua.load(L, "chunk", code, 0);
		Assert.equals(1, status); // 1 for failure
	}

	public function testCallNoReturn() {
		var source = "local x = 5";
		var options:CompileOptions = CompileOptions.create();
		var code = LuaCode.compile(source, source.length, options);
		var status = Lua.load(L, "chunk", code, 0);
		Assert.equals(0, status);
		Lua.call(L, 0, 0); // no return values
		Assert.equals(0, Lua.gettop(L));
	}

	public function testPcallSuccess() {
		var source = "return 99";
		var options:CompileOptions = CompileOptions.create();
		var code = LuaCode.compile(source, source.length, options);
		var status = Lua.load(L, "chunk", code, 0);
		Assert.equals(0, status);
		var pcallStatus = Lua.pcall(L, 0, 1, 0);
		Assert.equals(0, pcallStatus); // LUA_OK
		Assert.equals(LuaType.NUMBER, Lua.type(L, -1));
		Assert.equals(99.0, Lua.tonumber(L, -1));
		Lua.pop(L, 1);
	}

	// FIMXE needs more work - not very robust in checking error handling
	public function testPcallError() {
		var source = 'error("fail")';
		var options:CompileOptions = CompileOptions.create();
		options.debugLevel = 0;

		var code = LuaCode.compile(source, source.length, options);
		var status = Lua.load(L, "chunk", code, 0);
		Assert.equals(0, status);
		var pcallStatus = Lua.pcall(L, 0, 0, 0);
		Assert.notEquals(0, pcallStatus); // Should not be LUA_OK
		Lua.pop(L, 1);
	}

	function errHandler(L:State):Int {
		var msg = Lua.tostring(L, -1);
		trace('initial message=${msg}');
		// Get debug.traceback function
		Lua.getglobal(L, "debug");
		if (Lua.istable(L, -1) != 1) {
			trace('debug is not a table');
			Lua.pop(L, 1);
			return 1;
		}
		// if (Lua.isnil(L, -1) == 1) {
		// 	trace('debug is nil');
		// 	Lua.pop(L, 1);
		// 	return 1;
		// }
		// if (Lua.type(L, -1) != LuaType.TABLE) {
		// 	trace('debug is not a table');
		// 	Lua.pop(L, 1);
		// 	return 1;
		// }
		Lua.getfield(L, -1, "traceback");
		if (Lua.isfunction(L, -1) != 1) {
			trace('debug.traceback is not a function');
			Lua.pop(L, 2);
			return 1;
		}

		Lua.pushvalue(L, 1); // Pass the original error message to traceback
		Lua.pushinteger(L, 2); // Level 2: skip the traceback function itself
		Lua.call(L, 2, 1); // Call traceback(msg, 2)
		Lua.remove(L, -2); // Remove the debug table

		msg = Lua.tostring(L, -1);
		trace('post-errhandler message=${msg}');
		// var traceback = Lua.debugtrace(L);

		// var newMsg = "Caught: " + msg;
		// Lua.pop(L, 1); // remove original error message
		// Lua.pushstring(L, newMsg);
		// Lua.pushstring(L, "Caught: " + msg + '\n${traceback}');
		// Lua.insert(L, -2); // Move the new message below the traceback
		// Lua.concat(L, 2); // Concatenate new message and traceback
		return 1; // number of return values
	}

	public function testPcallErrorWithHandler() {
		Lualib.openlibs(L);
		Lualib.opendebug(L);
		Lua.pushcfunction(L, errHandler, "errHandler");

		var source = "error('fail')";
		var options:CompileOptions = CompileOptions.create();
		options.debugLevel = 2;
		var code = LuaCode.compile(source, source.length, options);
		var status = Lua.load(L, "chunk", code, 0);
		Assert.equals(0, status);
		var pcallStatus = Lua.pcall(L, 0, 1, -2); // errhandler at -2
		if (pcallStatus != LuaStatus.OK) {
			trace('Error loading chunk: ${Lua.tostring(L, -1)}');
			Assert.stringContains('[string "chunk"]:1: fail\n[string "chunk"]:1', Lua.tostring(L, -1));
			Lua.pop(L, 1); // remove error message
		}
		Assert.notEquals(0, pcallStatus); // Should not be LUA_OK
	}

	// FIXME: this needs a lot of work
	// public function testCpcall() {
	// 	var called = false;
	// 	var cfunc:LuaCFunction = function(L:State):Int {
	// 		called = true;
	// 		Lua.pushnumber(L, 1234);
	// 		return 1;
	// 	};
	// 	var status = Lua.cpcall(L, cfunc, null);
	// 	Assert.equals(0, status); // LUA_OK
	// 	Assert.isTrue(called);
	// 	Assert.equals(LuaType.NUMBER, Lua.type(L, -1));
	// 	Assert.equals(1234.0, Lua.tonumber(L, -1));
	// 	Lua.pop(L, 1);
	// }

	public function testScriptLoadAndRequire() {
		// Additional VM setup
		Lualib.openlibs(L);
		Lualib.opendebug(L);
		Lua.pushcfunction(L, errHandler, "errHandler");

		// Set up the Requirer
		// var config = Configuration.create();
		// Requirer.requireConfigInit(config);
		// trace('requirer config load={${config.is_require_allowed}}');
		// Require.openrequire(L, cpp.Callable.fromStaticFunction(requireConfigInit).call, new RequireCtx());
		var rCtxData = new RequireCtx();
		// Require.openrequire(L, cpp.Callable.fromStaticFunction(Requirer.requireConfigInit).call, rctx);
		var cbks = new RequireCallbacks();
		cbks.isRequireAllowed = Requirer.isRequireAllowed;
		cbks.reset = Requirer.reset;
		cbks.to_parent = Requirer.toParent;
		cbks.to_child = Requirer.toChild;
		cbks.is_module_present = Requirer.isModulePresent;
		cbks.get_chunkname = Requirer.getChunkname;
		cbks.get_loadname = Requirer.getLoadname;
		cbks.get_cache_key = Requirer.getCacheKey;
		cbks.load = Requirer.load;
		Require.openrequire(L, cbks, rCtxData);
		// var source = "require('./Animal')";
		trace('rctx num=${rCtxData.number_of_calls}');
		// var source = "return { v= 6}";  // dummy code that works
		// Load the Main.luau code
		var filePath = 'tests/scripts/Main.luau';
		var source = File.getContent(filePath);
		trace('Code=\n${source}');

		var options = CompileOptions.create();
		options.debugLevel = 2;

		var code = LuaCode.compile(source, source.length, options);
		var status = Lua.load(L, filePath, code, 0);
		if (status != 0) {
			trace('Error loading chunk: ${Lua.tostring(L, -1)}');
		}
		Assert.equals(0, status);
		var pcallStatus = Lua.pcall(L, 0, 1, -2);
		if (pcallStatus != 0) {
			trace('Error calling chunk: ${Lua.tostring(L, -1)}');
		}
		Assert.equals(0, pcallStatus); // LUA_OK
		Lua.pop(L, 1);
	}
}
