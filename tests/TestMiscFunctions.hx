package;

import hxluau.Lua.State;
import hxluau.Lua;
import utest.Assert;
import utest.Test;

class TestMiscFunctions extends Test {
	var L:State;

	public function setup() {
		L = Lua.newstate();
	}

	public function teardown() {
		Lua.close(L);
	}

	// FIXME needs help
	// public function testError() {
	// 	// Just check it returns an int (would raise error in Lua)
	// 	Lua.error(L);
	// 	// Assert.isTrue(Std.isOfType(result, Int));
	// }
	// FIXME needs work
	// public function testNextRawIter() {
	// 	Lua.createtable(L, 0, 0);
	// 	var nextResult = Lua.next(L, -1);
	// 	var rawIterResult = Lua.rawiter(L, -1, 0);
	// 	Assert.isTrue(Std.isOfType(nextResult, Int));
	// 	Assert.isTrue(Std.isOfType(rawIterResult, Int));
	// 	Lua.pop(L, 1);
	// }

	public function testConcat() {
		Lua.pushstring(L, "foo");
		Lua.pushstring(L, "bar");
		Lua.concat(L, 2);
		Assert.equals("foobar", '${Lua.tostring(L, -1)}');
	}

	// FIXME needs work
	// public function testEncodePointer() {
	// 	var ptr = Lua.newuserdata(L, 4);
	// 	var encoded = Lua.encodepointer(L, ptr);
	// 	Assert.isTrue(encoded != null);
	// }

	public function testClock() {
		var clk = Lua.clock();
		Assert.isTrue(clk >= 0);
	}

	// FIXME once we figure out pushing userdata
	// public function testSetUserdataTag() {
	// 	var ptr = Lua.newuserdata(L, 8);
	// 	Lua.pushlightuserdatatagged(L, ptr, 123);
	// 	Lua.setuserdatatag(L, -1, 456);
	// 	Assert.isTrue(true);
	// 	Lua.pop(L, 1);
	// }
	// FIXME this is gonna need work
	// public function testDestructorApis() {
	// 	var ptr = Lua.newuserdata(L, 8);
	// 	Lua.pushlightuserdatatagged(L, ptr, 789);
	// 	var dtor:Lua.LuaCFunction = function(L:Lua.State):Int return 0;
	// 	Lua.setuserdatadtor(L, -1, dtor);
	// 	var gotDtor = Lua.destructor(L, -1);
	// 	Assert.isTrue(gotDtor != null);
	// 	Lua.pop(L, 1);
	// }
}
