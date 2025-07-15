package om;

import haxe.io.Bytes;
import om.msgpack.Decoder.DecodeOption;

class Msgpack {
	/**
		Encode an object to msgpack
	**/
	public static inline function encode(obj:Dynamic):Bytes {
		return new om.msgpack.Encoder().encode(obj);
	}

	/**
		Decode msgpack bytes to object (or map)
	**/
	public static inline function decode(bytes:Bytes, ?option:DecodeOption):Dynamic {
		return new om.msgpack.Decoder(option).decode(bytes);
	}
}
