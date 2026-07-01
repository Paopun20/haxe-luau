package;

import hxluau.Lua.LuaGCop;
import hxluau.Lua.State;
import hxluau.Lua;
import utest.Assert;
import utest.Test;

class TestGC extends Test {
	var L:State;

	public function setup() {
		L = Lua.newstate();
	}

	public function teardown() {
		Lua.close(L);
	}

	public function testGCStopRestart() {
		Lua.gc(L, LuaGCop.STOP, 0);
		Lua.gc(L, LuaGCop.RESTART, 0);
		Assert.isTrue(true); // If no error, pass
	}

	public function testGCCollect() {
		Lua.gc(L, LuaGCop.COLLECT, 0);
		Assert.isTrue(true);
	}

	public function testGCCount() {
		Lua.gc(L, LuaGCop.COUNT, 0);
		Lua.gc(L, LuaGCop.COUNTB, 0);
		Assert.isTrue(true);
	}

	public function testGCIsRunning() {
		Lua.gc(L, LuaGCop.ISRUNNING, 0);
		Assert.isTrue(true);
	}

	public function testGCStep() {
		Lua.gc(L, LuaGCop.STEP, 1);
		Assert.isTrue(true);
	}

	public function testGCSetGoalStepMulStepSize() {
		Lua.gc(L, LuaGCop.SETGOAL, 200);
		Lua.gc(L, LuaGCop.SETSTEPMUL, 200);
		Lua.gc(L, LuaGCop.SETSTEPSIZE, 1);
		Assert.isTrue(true);
	}
}
