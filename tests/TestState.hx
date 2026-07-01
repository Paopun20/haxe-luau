package;

import hxluau.Lua;
import utest.Assert;
import utest.Test;

/**
 * Test the Lua state management functions.
 */
class TestState extends Test {
	function testNewThread() {
		var mainState = Lua.newstate();
		Assert.notNull(mainState, "Main state should not be null");

		var threadState = Lua.newthread(mainState);
		Assert.notNull(threadState, "Thread state should not be null");
		Assert.notEquals(mainState, threadState, "Thread state should be different from main state");

		Lua.close(mainState);
	}

	function testMainThread() {
		var mainState = Lua.newstate();
		var threadState = Lua.newthread(mainState);
		var mainFromThread = Lua.mainthread(threadState);
		Assert.equals(mainState, mainFromThread, "mainthread should return the original main state");
		Lua.close(mainState);
	}

	function testResetThreadAndIsThreadReset() {
		var mainState = Lua.newstate();
		var threadState = Lua.newthread(mainState);

		// Example: push the global table on the stack so we can
		// see the effect of reset
		Lua.getglobal(threadState, "_G");
		var isResetBefore = Lua.isthreadreset(threadState);
		Assert.equals(0, isResetBefore, "isthreadreset should return 0 before reset");

		Lua.resetthread(threadState);
		var isReset = Lua.isthreadreset(threadState);
		Assert.equals(1, isReset, "isthreadreset should return 1 after reset");

		Lua.close(mainState);
	}
}
