package;

import hxluau.Lua.State;
import hxluau.Lua;
import utest.Assert;
import utest.Test;

class Foo {
	public var state:State;

	// Constructor parameters must be compatible with Dynamic and cpp.Star
	// isn't. As it has to be used as the mapping for pushcfunction we
	// we just cannot use State entirely as a regular Haxe object in all
	// cases, which is a bit sad.
	public function new(L:State = null) {
		state = L;
	}

	public static function getFoo(L:State) {
		var rv = new Foo();
		rv.state = L;
		return rv;
	}
}

class TestClassesWithLua extends Test {
	function testFactoryFunctionTakingLuaState() {
		var L = Lua.newstate();
		var foo = Foo.getFoo(L);
		Assert.isTrue(foo != null);
		Assert.notNull(foo.state);
	}

	function testConstructorTakingLuaState() {
		var L = Lua.newstate();
		var foo = new Foo(L);
		Assert.isTrue(foo != null);
	}
}
