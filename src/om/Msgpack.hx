package om;

import haxe.io.Bytes;
import om.msgpack.Decoder.DecodeOption;

class Msgpack {
	public static inline function encode(obj:Dynamic):Bytes {
		return new om.msgpack.Encoder().encode(obj);
	}

	public static inline function decode(bytes:Bytes, ?option:DecodeOption):Dynamic {
		return new om.msgpack.Decoder(option).decode(bytes);
	}

	public static inline function decodeMap(bytes:Bytes):Map<String, Dynamic> {
		return new om.msgpack.Decoder(AsMap).decode(bytes);
	}
}
