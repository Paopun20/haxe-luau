package;

import hxluau.Lua.State;
import hxluau.Lua;
import utest.Assert;
import utest.Test;

class TestMetatablesAlt extends Test {
	var L:State;

	public function setup() {
		L = Lua.newstate();
	}

	public function teardown() {
		Lua.close(L);
	}

	// FIXME - this test is bogus
	public function testSetGetUserdataMetatable() {
		// Register a metatable for tag 42
		Lua.setuserdatametatable(L, 42);
		// Should not throw
		Lua.getuserdatametatable(L, 42);
		Assert.isTrue(false);
	}

	public function testSetGetLightUserdataName() {
		Lua.setlightuserdataname(L, 99, "myname");
		var name = Lua.getlightuserdataname(L, 99);
		Assert.isTrue(name != null);
	}

	// FIXME Needs work
	// public function testCloneFunction() {
	// 	var source = "return function(x) return x + 1 end";
	// 	Lua.pushstring(L, source);
	// 	// Simulate a function on stack (not a real Lua closure, but for API call)
	// 	Lua.clonefunction(L, -1);
	// 	Assert.isTrue(true);
	// 	Lua.pop(L, 2);
	// }

	public function testClearAndCloneTable() {
		Lua.createtable(L, 0, 2);
		Lua.pushstring(L, "foo");
		Lua.pushnumber(L, 123);
		Lua.settable(L, -3);
		Lua.cleartable(L, -1);
		Assert.isTrue(Lua.gettop(L) >= 1);
		Lua.clonetable(L, -1);
		Assert.isTrue(Lua.gettop(L) >= 2);
		Lua.pop(L, 2);
	}

	// FIXME API needs work and then this might be fixed
	// public function testGetAllocf() {
	// 	var allocf = Lua.getallocf(L, );
	// 	Assert.isTrue(allocf != null);
	// }
}
