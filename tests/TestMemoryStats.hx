package;

import hxluau.Lua.State;
import hxluau.Lua;
import utest.Assert;
import utest.Test;

class TestMemoryStats extends Test {
	var L:State;

	public function setup() {
		L = Lua.newstate();
	}

	public function teardown() {
		Lua.close(L);
	}

	public function testSetMemCat() {
		Lua.setmemcat(L, 0);
		Assert.isTrue(true); // If no error, pass
	}

	public function testTotalBytes() {
		var bytes = Lua.totalbytes(L, 0);
		Assert.isTrue(bytes >= 0);
	}
}
