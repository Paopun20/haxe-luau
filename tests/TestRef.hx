package;

import hxluau.Lua.State;
import hxluau.Lua;
import utest.Assert;
import utest.Test;

class TestRef extends Test {
	var L:State;

	public function setup() {
		L = Lua.newstate();
	}

	public function teardown() {
		Lua.close(L);
	}

	public function testRefUnrefGetRef() {
		Lua.pushstring(L, "myref");
		var ref = Lua.ref(L, -1);
		Assert.isTrue(ref != LuaRef.NOREF && ref != LuaRef.REFNIL);
		var idx = Lua.getref(L, ref);
		Assert.isTrue(idx >= 0);
		Lua.unref(L, ref);
		Lua.pop(L, 1);
	}

	public function testRefNil() {
		var refNil = LuaRef.REFNIL;
		Assert.equals(LuaRef.REFNIL, 0);
	}
}
