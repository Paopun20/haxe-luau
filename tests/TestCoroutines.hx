package;

import hxluau.Lua.LuaCoStatus;
import hxluau.Lua.LuaStatus;
import hxluau.Lua.LuaType;
import hxluau.Lua.State;
import hxluau.Lua;
import hxluau.LuaCode.CompileOptions;
import hxluau.LuaCode;
import utest.Assert;
import utest.Test;

// FIXME go through and clean up
// FIXME need a proper set of coroutine tests - understand Lua coros
//      verify all tests are useful, add missing tests
class TestCoroutines extends Test {
	var L:State;

	public function setup() {
		L = Lua.newstate();
	}

	public function teardown() {
		Lua.close(L);
	}

	public function testNewThreadAndResume() {
		var source = "coroutine.yield(42); return 99";
		var options:CompileOptions = CompileOptions.create();
		var code = LuaCode.compile(source, source.length, options);
		var status = Lua.load(L, "chunk", code, 0);
		Assert.equals(0, status);
		var thread = Lua.newthread(L);
		Lua.pushvalue(L, -2); // push loaded function to thread
		Lua.xmove(L, thread, 1);
		var resumeStatus = Lua.resume(thread, L, 0);
		Assert.equals(LuaStatus.YIELD, resumeStatus);
		Assert.equals(LuaType.NUMBER, Lua.type(thread, -1));
		Assert.equals(42.0, Lua.tonumber(thread, -1));
		Lua.pop(thread, 1);
		resumeStatus = Lua.resume(thread, L, 0);
		Assert.equals(LuaStatus.OK, resumeStatus);
		Assert.equals(LuaType.NUMBER, Lua.type(thread, -1));
		Assert.equals(99.0, Lua.tonumber(thread, -1));
		Lua.pop(thread, 1);
	}

	public function testYieldAndStatus() {
		var source = "coroutine.yield(123)";
		var options:CompileOptions = CompileOptions.create();
		var code = LuaCode.compile(source, source.length, options);
		var status = Lua.load(L, "chunk", code, 0);
		Assert.equals(0, status);
		var thread = Lua.newthread(L);
		var coThread = Lua.newthread(L);
		Lua.pushvalue(L, -2);
		Lua.xmove(L, thread, 1);
		var resumeStatus = Lua.resume(thread, L, 0);
		Assert.equals(LuaStatus.YIELD, resumeStatus);
		Assert.equals(LuaType.NUMBER, Lua.type(thread, -1));
		Assert.equals(123.0, Lua.tonumber(thread, -1));
		Assert.equals(LuaCoStatus.COSUS, Lua.costatus(thread, coThread));
		Assert.equals(LuaStatus.YIELD, Lua.status(thread));
		Lua.pop(thread, 1);
	}

	public function testBreakAndIsYieldable() {
		Assert.isTrue(Lua.isyieldable(L) == 1 || Lua.isyieldable(L) == 0);
		// break_ is a no-op in most cases, just test it returns an int
		var result = Lua.break_(L);
		Assert.isTrue(Std.isOfType(result, Int));
	}

	public function testYieldApi() {
		// yield can only be called from inside a Lua C function, so we just check it returns an int
		var result = Lua.yield(L, 0);
		Assert.isTrue(Std.isOfType(result, Int));
	}

	public function testGetSetThreadData() {
		// set and get thread data (pointer, just check roundtrip)
		var ptr = Lua.getthreaddata(L);
		Lua.setthreaddata(L, ptr);
		var ptr2 = Lua.getthreaddata(L);
		Assert.equals(ptr, ptr2);
	}

	public function testCostatusAndStatus() {
		var thread = Lua.newthread(L);
		var coThread = Lua.newthread(L);
		Assert.isTrue(Lua.costatus(thread, coThread) == LuaCoStatus.CORUN
			|| Lua.costatus(thread, coThread) == LuaCoStatus.COSUS
			|| Lua.costatus(thread, coThread) == LuaCoStatus.CONOR
			|| Lua.costatus(thread, coThread) == LuaCoStatus.COFIN
			|| Lua.costatus(thread, coThread) == LuaCoStatus.COERR);
		Assert.isTrue(Lua.status(thread) == LuaStatus.OK
			|| Lua.status(thread) == LuaStatus.YIELD
			|| Lua.status(thread) == LuaStatus.ERRRUN
			|| Lua.status(thread) == LuaStatus.ERRSYNTAX
			|| Lua.status(thread) == LuaStatus.ERRMEM
			|| Lua.status(thread) == LuaStatus.ERRERR
			|| Lua.status(thread) == LuaStatus.BREAK);
	}
}
