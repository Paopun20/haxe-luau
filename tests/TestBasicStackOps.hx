package;

import hxluau.Lua;
import utest.Assert;
import utest.Test;

/**
 * Test basic stack operations in Lua.
 * This includes getting and setting the stack top, pushing values,
 * removing, inserting, replacing values, checking stack size,
 * and moving values between stacks.
 * It also tests absolute indexing and raw stack checks.
 */
class TestBasicStackOps extends Test {
	function testGetSetTop() {
		var L = Lua.newstate();
		Assert.equals(0, Lua.gettop(L), "Stack should be empty on new state");
		Lua.getglobal(L, "_G");
		Assert.equals(1, Lua.gettop(L), "Stack should have one item after getglobal");
		Lua.settop(L, 0);
		Assert.equals(0, Lua.gettop(L), "Stack should be empty after settop(0)");
		Lua.close(L);
	}

	function testPushValue() {
		var L = Lua.newstate();
		Lua.getglobal(L, "_G");
		Lua.pushvalue(L, -1);
		Assert.equals(2, Lua.gettop(L), "Stack should have two items after pushvalue");
		Lua.settop(L, 0);
		Lua.close(L);
	}

	function testRemoveInsertReplace() {
		var L = Lua.newstate();
		Lua.getglobal(L, "_G");
		Lua.getglobal(L, "_G");
		Assert.equals(2, Lua.gettop(L), "Stack should have two items");
		Lua.remove(L, 1);
		Assert.equals(1, Lua.gettop(L), "Stack should have one item after remove");
		Lua.getglobal(L, "_G");
		Lua.insert(L, 1);
		Assert.equals(2, Lua.gettop(L), "Stack should have two items after insert");
		Lua.replace(L, 1);
		Assert.equals(1, Lua.gettop(L), "Stack should have one item after replace");
		Lua.settop(L, 0);
		Lua.close(L);
	}

	function testCheckStack() {
		var L = Lua.newstate();
		var ok = Lua.checkstack(L, 10);
		Assert.equals(1, ok, "checkstack should return 1 for valid size");
		Lua.close(L);
	}

	function testAbsIndex() {
		var L = Lua.newstate();
		Lua.getglobal(L, "_G");
		var idx = Lua.absindex(L, -1);
		Assert.equals(1, idx, "absindex(-1) should return 1 when one item is on the stack");
		Lua.settop(L, 0);
		Lua.close(L);
	}

	function testRawCheckStack() {
		var L = Lua.newstate();
		Lua.rawcheckstack(L, 20); // Should not throw or error
		Assert.equals(0, Lua.gettop(L), "Stack should remain empty after rawcheckstack");
		Lua.close(L);
	}

	function testXMove() {
		var L1 = Lua.newstate();
		var L2 = Lua.newstate();
		Lua.getglobal(L1, "_G");
		Assert.equals(1, Lua.gettop(L1), "L1 should have one item before xmove");
		Assert.equals(0, Lua.gettop(L2), "L2 should be empty before xmove");
		Lua.xmove(L1, L2, 1);
		Assert.equals(0, Lua.gettop(L1), "L1 should be empty after xmove");
		Assert.equals(1, Lua.gettop(L2), "L2 should have one item after xmove");
		Lua.settop(L2, 0);
		Lua.close(L1);
	}

	function testXPush() {
		var L1 = Lua.newstate();
		var L2 = Lua.newstate();
		Lua.getglobal(L1, "_G");
		Assert.equals(1, Lua.gettop(L1), "L1 should have one item before xpush");
		Assert.equals(0, Lua.gettop(L2), "L2 should be empty before xpush");
		Lua.xpush(L1, L2, -1);
		Assert.equals(1, Lua.gettop(L1), "L1 should still have one item after xpush");
		Assert.equals(1, Lua.gettop(L2), "L2 should have one item after xpush");
		Lua.settop(L1, 0);
		Lua.settop(L2, 0);
		Lua.close(L1);
	}
}
