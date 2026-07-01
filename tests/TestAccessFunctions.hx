package;

import hxluau.Lua.State;
import hxluau.Lua;
import hxluau.LuaCode;
import utest.Assert;
import utest.Test;

// FIXME remove of cpp references.
// There are output pointers which we need to figure out generically.
class TestAccessFunctions extends Test {
	function testIsNumber() {
		var L = Lua.newstate();
		Lua.getglobal(L, "_G");
		Assert.equals(0, Lua.isnumber(L, -1), "_G is a number");
		Lua.settop(L, 0);

		// Push a number
		Lua.pushnumber(L, 12);
		Assert.equals(1, Lua.isnumber(L, -1), "_G is not a number");

		Lua.settop(L, 0);
		Lua.close(L);
	}

	function testIsString() {
		var L = Lua.newstate();
		Lua.getglobal(L, "_G");
		Assert.equals(0, Lua.isstring(L, -1), "_G is not a string");
		Lua.settop(L, 0);

		// Push a string
		Lua.pushstring(L, "hello");
		Assert.equals(1, Lua.isstring(L, -1), "Should detect pushed string");
		Lua.settop(L, 0);
		Lua.close(L);
	}

	static function cFunc(L:State):Int {
		Lua.pushnumber(L, 423);
		return 1;
	}

	// FIXME reinstate
	// function testIsCFunction() {
	// 	var L = Lua.newstate();
	// 	// Set up the C function in the stack
	// 	Lua.pushcfunction(L, TestAccessFunctions.cFunc, "cFunc");
	// 	Assert.equals(1, Lua.iscfunction(L, -1), "cFunc should be a C function");
	// 	Lua.settop(L, 0);
	// 	Lua.close(L);
	// }

	function cFuncMember(L:State):Int {
		Lua.pushnumber(L, 423);
		return 1;
	}

	function testCFunctionMember() {
		var L = Lua.newstate();
		cFuncMember(L);
		Lua.settop(L, 0);
		Lua.close(L);
	}

	function testIsLFunction() {
		var L = Lua.newstate();
		Lua.getglobal(L, "_G");
		Assert.equals(0, Lua.isLfunction(L, -1), "_G should not be a Lua function");
		Lua.settop(L, 0);

		// Push a Lua function
		var source = "function fooLuaFn() return 42 end";
		var options:CompileOptions = CompileOptions.create();
		var byteCode = LuaCode.compile(source, source.length, options);
		var r = Lua.load(L, "code", byteCode, 0);

		Assert.equals(1, Lua.isLfunction(L, -1), "Should detect pushed Lua function");

		Lua.settop(L, 0);
		Lua.close(L);
	}

	function testIsUserdata() {
		var L = Lua.newstate();
		Lua.getglobal(L, "_G");
		Assert.equals(0, Lua.isuserdata(L, -1), "_G is not userdata");
		Lua.settop(L, 0);

		// Push userdata (simulate by creating a new userdata)
		Lua.newuserdata(L, 8); // push 8 bytes of userdata
		Assert.equals(1, Lua.isuserdata(L, -1), "Should detect pushed userdata");
		Lua.settop(L, 0);
		Lua.close(L);
	}

	function testTypeAndTypename() {
		var L = Lua.newstate();
		Lua.pushnumber(L, 12);
		Lua.pushstring(L, "hello");

		var tp = Lua.type(L, -2);
		var name:String = Lua.typename(L, tp);
		Assert.equals("number", name, 'type should be a number, but is ${name}');

		var tp = Lua.type(L, -1);
		var name:String = Lua.typename(L, tp);
		Assert.equals("string", name, 'type should be a string, but is ${name}');

		Lua.settop(L, 0);
		Lua.close(L);
	}

	function testEqualAndRawEqual() {
		var L = Lua.newstate();
		Lua.pushnumber(L, 5);
		Lua.pushnumber(L, 5);
		Assert.equals(1, Lua.equal(L, -1, -2), "equal should return 1 for equal numbers");
		Assert.equals(1, Lua.rawequal(L, -1, -2), "rawequal should return 1 for equal numbers");
		Lua.settop(L, 0);
		Lua.pushnumber(L, 5);
		Lua.pushnumber(L, 6);
		Assert.equals(0, Lua.equal(L, -1, -2), "equal should return 0 for different numbers");
		Assert.equals(0, Lua.rawequal(L, -1, -2), "rawequal should return 0 for different numbers");
		Lua.settop(L, 0);
		Lua.close(L);
	}

	function testLessThan() {
		var L = Lua.newstate();
		Lua.pushnumber(L, 3);
		Lua.pushnumber(L, 5);
		Assert.equals(1, Lua.lessthan(L, -2, -1), "lessthan should return 1 for 3 < 5");
		Assert.equals(0, Lua.lessthan(L, -1, -2), "lessthan should return 0 for 5 < 3");
		Lua.settop(L, 0);
		Lua.close(L);
	}

	function testTonumberx() {
		var L = Lua.newstate();
		Lua.pushstring(L, "123.5");
		var isnum:Ref<Int> = 0;
		var num = Lua.tonumberx(L, -1, isnum);

		Assert.equals(1, isnum, 'tonumberx should set isnum to 1 for valid number string but it was ${isnum}');
		Assert.equals(123.5, num, "tonumberx should convert string to number");
		Lua.settop(L, 0);
		Lua.close(L);
	}

	function testTointegerx() {
		var L = Lua.newstate();
		Lua.pushstring(L, "42");
		var isnum:Ref<Int> = 0;
		var num = Lua.tointegerx(L, -1, isnum);
		Assert.equals(1, isnum, "tointegerx should set isnum to 1 for valid integer string");
		Assert.equals(42, num, "tointegerx should convert string to integer");
		Lua.settop(L, 0);
		Lua.close(L);
	}

	function testTounsignedx() {
		var L = Lua.newstate();
		Lua.pushstring(L, "123");
		var isnum:Ref<Int> = 0;
		var num = Lua.tounsignedx(L, -1, isnum);
		Assert.equals(1, isnum, "tounsignedx should set isnum to 1 for valid unsigned string");
		Assert.equals(123, num, "tounsignedx should convert string to unsigned");
		Lua.settop(L, 0);
		Lua.close(L);
	}

	function testTounsigned() {
		var L = Lua.newstate();
		Lua.pushstring(L, "4294967295");
		var num = Lua.tounsigned(L, -1);
		Assert.equals(0xFFFFFFFFu32, num, "tounsigned should convert string to unsigned");
		trace('num=${num}');
		Lua.settop(L, 0);
		Lua.close(L);
	}

	function testTovector() {
		var L = Lua.newstate();
		Lua.pushvector(L, 1.5, 2.5, 3.5);
		var vec = Lua.tovector(L, -1);
		trace('LUA_VECTOR_SIZE=${LuaDefines.VECTOR_SIZE}');
		trace('vec=${vec}');
		Assert.notNull(vec, "tovector should return a pointer (may be null if not supported)");
		Assert.equals(vec[0], 1.5, "vec[0] should be 1.5");
		Assert.equals(vec[1], 2.5, "vec[0] should be 2.5");
		Assert.equals(vec[2], 3.5, "vec[0] should be 3.5");

		Lua.settop(L, 0);
		Lua.close(L);
	}

	function testTovectorErr() {
		var L = Lua.newstate();
		Lua.pushstring(L, "hello");
		var vec = Lua.tovector(L, -1);
		trace('vec=${vec}');

		Assert.isNull(vec, "tovector should return a null pointer");

		Lua.settop(L, 0);
		Lua.close(L);
	}

	function testToboolean() {
		var L = Lua.newstate();
		Lua.pushboolean(L, false);
		Assert.isFalse(Lua.toboolean(L, -1), "toboolean should return false for false");

		Lua.settop(L, 0);
		Lua.pushboolean(L, true);
		Assert.isTrue(Lua.toboolean(L, -1), "toboolean should return true for true");

		// This returns true because anything not false or nil is true in Lua
		Lua.settop(L, 0);
		Lua.pushnumber(L, 12);
		Assert.isTrue(Lua.toboolean(L, -1), "toboolean should return 1 for nonzero");
		Lua.settop(L, 0);
		Lua.close(L);
	}

	function testTostringatom() {
		var L = Lua.newstate();
		Lua.pushstring(L, "foo");
		var atom:Ref<Int> = 0;
		var str:String = Lua.tostringatom(L, -1, atom);

		trace('atom=${atom}, str=${str}');
		Assert.equals("foo", str, "tostringatom should return 'foo'");
		Assert.equals(-1, atom, "tostringatom should set atom to -1");
		Lua.settop(L, 0);
		Lua.close(L);
	}

	function testTolstringatom() {
		var L = Lua.newstate();
		Lua.pushstring(L, "bar");
		var len:Ref<CSizeT> = 0;
		var atom:Ref<Int> = 0;
		var str:String = Lua.tolstringatom(L, -1, len, atom);

		Assert.equals(3, len, "tolstringatom should set length to 3 for 'bar'");
		Assert.equals("bar", str, "tolstringatom should return 'bar'");
		Assert.equals(-1, atom, "tostringatom should set atom to -1");
		Lua.settop(L, 0);
		Lua.close(L);
	}

	// FIXME I don't really understand namecalls and it appears to be an
	//       internal feature of Luau and it's not even recommended to use
	//       anymore.
	// static function traceit(str:CString, l:CSizeT):cpp.Int16 {
	// 	trace('traceit called with str=${str}');
	// 	return 0;
	// }
	// FIXME assigning functions to extern struct fields is hard
	// Refer https://github.com/luau-lang/luau/blob/ff6d381e57bcd1799d850d7fabe543c0f0980a5d/tests/Conformance.test.cpp#L2157
	// for a C++ example.
	// function testNamecallatom() {
	// 	var L = Lua.newstate();
	// 	var cbks = Lua.callbacks(L);
	// 	trace('type of cbks=${Type.typeof(cbks)}, cbks=${cbks}');
	// 	cbks.value.useratom = cpp.Pointer.addressOf(TestAccessFunctions.traceit);
	// 	var atom = 0;
	// 	var str = Lua.namecallatom(L, cpp.Pointer.addressOf(atom).ptr);
	// 	Assert.isOfType(str, String, "namecallatom should return a string (may be empty)");
	// 	Lua.close(L);
	// }

	function testObjLen() {
		var L = Lua.newstate();
		Lua.pushstring(L, "hello");
		var len = Lua.objlen(L, -1);
		Assert.equals(5, len, "objlen should return 5 for 'hello'");
		Lua.settop(L, 0);
		Lua.close(L);
	}

	// FIXME reinstate
	// function testToCFunction() {
	// 	var L = Lua.newstate();
	// 	// Test the function directly
	// 	var f = TestAccessFunctions.cFunc;
	// 	var rv = f(L);
	// 	Assert.equals(423.0, Lua.tonumber(L, -1), 'Direct call to cFunc should push 423 onto the stack but was ${Lua.tonumber(L, -1)}');
	// 	trace('rv=${rv}');
	// 	Lua.settop(L, 0);
	// 	// Push function and test tocfunction returning it and see that it
	// 	// can be called.
	// 	Lua.pushcfunction(L, TestAccessFunctions.cFunc, "cFunc");
	// 	var fn = Lua.tocfunction(L, -1);
	// 	Assert.notNull(fn, "tocfunction should return a function pointer");
	// 	trace('type of fn=${Type.typeof(fn)}, fn=${fn}');
	// 	fn(L);
	// 	Assert.equals(423.0, Lua.tonumber(L, -1), "After calling cFunc, top of stack should be 423");
	// 	Lua.settop(L, 0);
	// 	Lua.close(L);
	// }

	/**
	 * Test that tolightuserdata returns the correct value. Note that
	 * the return value needs to be cast and the compiler requires a
	 * cast to the expected type, even if it's a typed variable.
	 * This is actually expected by the C - the caller is expected to
	 * know the type of the light userdata.
	 */
	function testTolightuserdata() {
		var L = Lua.newstate();
		var x = 12345;
		Lua.pushlightuserdata(L, x);
		var rv:Int = Lua.tolightuserdata(L, -1);
		Assert.equals(x, rv, 'tolightuserdata should return 12345 but returned ${rv}');
		Lua.settop(L, 0);
		Lua.close(L);
	}

	function testToLightUserdataTag() {
		var L = Lua.newstate();
		// Push a light userdata with a tag (simulate with a pointer, tag may be implementation-specific)
		var x = 12345;
		Lua.pushlightuserdatatagged(L, x, 12);
		var tag:Int = Lua.tolightuserdatatagged(L, -1, 12);
		// The expected tag value depends on your implementation; typically 0 for untagged
		trace('tag=${tag}');
		Assert.notNull(tag, "tolightuserdatatag should return a tag (may be 0 for untagged)");
		Lua.settop(L, 0);
		Lua.close(L);
	}

	// FIXME probably need a more substantial example
	function testTouserdata() {
		var L = Lua.newstate();
		Lua.newuserdata(L, 4);
		var ptr = Lua.touserdata(L, -1);
		Assert.notNull(ptr, "touserdata should return pointer for userdata");
		Lua.settop(L, 0);
		Lua.close(L);
	}

	/**
	 * Test that a matching tag returns the correct userdata pointer
	 */
	function testTouserdatatagged() {
		var L = Lua.newstate();
		Lua.newuserdatatagged(L, 4, 12);
		var ptr = Lua.touserdatatagged(L, -1, 12);
		Assert.notNull(ptr, "touserdatatagged should return pointer for tagged userdata");
		Lua.settop(L, 0);
		Lua.close(L);
	}

	function testUserdataTagged() {
		var L = Lua.newstate();
		var tag = 123;
		Lua.newuserdatatagged(L, 8, tag);
		var stackTag = Lua.userdatatag(L, -1);
		Assert.equals(tag, stackTag, "userdatatag should return the tag used to create the userdata");
		Lua.settop(L, 0);
		Lua.close(L);
	}

	function testLightUserdataTag() {
		var L = Lua.newstate();
		// Push a light userdata with a tag
		var x = 12345;
		Lua.pushlightuserdatatagged(L, x, 12);
		var tag:Int = Lua.lightuserdatatag(L, -1);
		trace('tag=${tag}');
		Assert.equals(12, tag, "lightuserdatatag should return at the tag passed in");
		Lua.settop(L, 0);
		Lua.close(L);
	}

	function testTothread() {
		var L = Lua.newstate();
		var thread = Lua.newthread(L);
		var result = Lua.tothread(L, -1);
		Assert.notNull(result, "tothread should return a thread pointer");
		Assert.equals(thread, result, "tothread should return the same thread pointer as created");
		Lua.close(L);
	}

	function testTobuffer() {
		var L = Lua.newstate();
		var buf = Lua.newbuffer(L, 40);
		var sz:Ref<CSizeT> = 0;
		var bufRtn = Lua.tobuffer(L, -1, sz);
		Assert.isTrue(Lua.isbuffer(L, -1), "top of stack should be a buffer");
		Assert.equals(40, sz, "buffer size should be 40");
		Assert.equals(buf, bufRtn, "tobuffer should return the same buffer pointer as created");
		Lua.settop(L, 0);
		Lua.close(L);
	}

	function testTopointer() {
		var L = Lua.newstate();
		Lua.pushstring(L, "ptr");
		var ptr = Lua.topointer(L, -1);
		Assert.notNull(ptr, "topointer should return a pointer for string");
		Lua.settop(L, 0);
		Lua.close(L);
	}
}
