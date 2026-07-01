package hxluau;

typedef State = Null<Int>; // Must be Null<haxe.macro.ComplexType>
typedef CString = String;
typedef LuaHaxeStaticFunction = State->Int;

class Lua {
	static function newstate():State {
		return 0;
	}

	static function pushcfunction(L:State, f:LuaHaxeStaticFunction, debugName:CString):Void {
		return;
	}

	static function setglobal(L:State, s:CString):Int {
		return 0;
	}

	static function setfield(L:State, idx:Int, k:CString):Void {
		return;
	}
}
