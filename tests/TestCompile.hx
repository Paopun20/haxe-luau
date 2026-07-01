package;

import hxluau.Lua;
import hxluau.Lua.CSizeT;
import hxluau.Lua.LuaStatus;
import hxluau.LuaCode;
import hxluau.LuaCode.CompileOptions;
import utest.Assert;
import utest.Test;

/**
 * Compiler tests.
 */
class TestCompile extends Test {
	/**
	 * This test verifies a basic compile but it also shows how to use the LuaCode.compile function and how to load and execute the resulting bytecode. It checks that the compiled code produces the expected result and that the bytecode length is as expected. This serves as a basic sanity check for the compilation process. It also demonstrates error handling when loading the chunk, ensuring that if there is a compilation error, it
	 */
	function testSimpleCompile():Void {
		var L = Lua.newstate();
		var source = "a = 7 + 11";

		// Cannot pass null so use an empty struct.
		// Cannot instantiate {} directly as call site, so use a local variable.
		var options:CompileOptions = CompileOptions.create();

		var byteCode = LuaCode.compile(source, source.length, options);
		trace('bytecode length: ${byteCode.size}');
		var r = Lua.load(L, "code", byteCode, 0);
		if (r != LuaStatus.OK) {
			trace('Error loading chunk: ${Lua.tostring(L, -1)}');
			Lua.pop(L, 1); // remove error message
			Sys.exit(1);
		}
		Lua.call(L, 0, 1); // call the loaded chunk
		Lua.getglobal(L, "a");
		if (Lua.isnumber(L, -1) == 1) {
			trace('Result: ${Lua.tonumber(L, -1)}');
		} else {
			trace('Error: "a"" is not a number.');
		}

		Assert.equals(18, Lua.tonumber(L, -1));
		Assert.equals(69, byteCode.size);

		Lua.close(L);
	}

	function testCompileError():Void {
		var L = Lua.newstate();

		// Bad code that will not compile
		var source = "a = 7 + 1sdfgsfdg1";

		// Cannot pass null so use an empty struct.
		// Cannot instantiate {} directly as call site, so use a local variable.
		var options:CompileOptions = CompileOptions.create();

		var byteCode = LuaCode.compile(source, source.length, options);
		var r = Lua.load(L, "code", byteCode, 0);

		// Note that we have to force the cast to String here because
		// Lua.tostring returns a CString which is typedef'd to
		// cpp.ConstCharStar which is not automatically converted to String.
		var errMsg:String = Lua.tostring(L, -1);

		Assert.equals(1, r);
		Assert.equals("[string \"code\"]:1: Malformed number", errMsg);
		Lua.close(L);
	}
}
