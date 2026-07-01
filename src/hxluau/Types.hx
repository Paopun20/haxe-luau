package hxluau;

abstract CString(cpp.ConstCharStar) from cpp.ConstCharStar to cpp.ConstCharStar {
	@:from static inline function fromString(s:String):CString {
		return (s : cpp.ConstCharStar);
	}

	@:to inline function toString():String {
		return (this : String);
	}
}
