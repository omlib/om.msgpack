package om.msgpack;

import haxe.Int64;
import haxe.io.Bytes;
import haxe.io.BytesOutput;

using Reflect;

class Encoder {
	public static inline var FLOAT_SINGLE_MIN:Float = 1.40129846432481707e-45;
	public static inline var FLOAT_SINGLE_MAX:Float = 3.40282346638528860e+38;
	public static inline var FLOAT_DOUBLE_MIN:Float = 4.94065645841246544e-324;
	public static inline var FLOAT_DOUBLE_MAX:Float = 1.79769313486231570e+308;

	var o:BytesOutput;

	public function new() {}

	public function encode(d:Dynamic):Bytes {
		o = new BytesOutput();
		o.bigEndian = true;
		encodeObject(d);
		return o.getBytes();
	}

	function encodeObject(d:Dynamic) {
		switch Type.typeof(d) {
			case TNull:
				o.writeByte(0xc0);
			case TBool:
				o.writeByte(d ? 0xc3 : 0xc2);
			case TInt:
				writeInt(d);
			case TFloat:
				writeFloat(d);
			case TClass(c):
				switch Type.getClassName(c) {
					case "haxe._Int64.___Int64": writeInt64(d);
					case "haxe.io.Bytes": writeBinary(d);
					case "String": writeString(d);
					case "Array": writeArray(d);
					case "haxe.ds.IntMap", "haxe.ds.StringMap", "haxe.ds.UnsafeStringMap":
						writeMap(d);
					default: throw 'Error: ${Type.getClassName(c)} not supported';
				}
			case TObject:
				writeObject(d);
			case TEnum(e):
				throw "Error: enum not supported";
			case TFunction:
				throw "Error: function not supported";
			case TUnknown:
				throw "Error: Unknown data type";
		}
	}

	inline function writeInt64(d:Int64) {
		o.writeByte(0xd3);
		o.writeInt32(d.high);
		o.writeInt32(d.low);
	}

	inline function writeInt(d:Int) {
		if (d < -(1 << 5)) {
			// less than negative fixnum ?
			if (d < -(1 << 15)) {
				// signed int 32
				o.writeByte(0xd2);
				o.writeInt32(d);
			} else if (d < -(1 << 7)) {
				// signed int 16
				o.writeByte(0xd1);
				o.writeInt16(d);
			} else {
				// signed int 8
				o.writeByte(0xd0);
				o.writeInt8(d);
			}
		} else if (d < (1 << 7)) {
			// negative fixnum < d < positive fixnum [fixnum]
			o.writeByte(d & 0x000000ff);
		} else {
			// unsigned land
			if (d < (1 << 8)) {
				// unsigned int 8
				o.writeByte(0xcc);
				o.writeByte(d);
			} else if (d < (1 << 16)) {
				// unsigned int 16
				o.writeByte(0xcd);
				o.writeUInt16(d);
			} else {
				// unsigned int 32
				// TODO: HaXe writeUInt32 ?
				o.writeByte(0xce);
				o.writeInt32(d);
			}
		}
	}

	inline function writeFloat(d:Float) {
		var a = Math.abs(d);
		if (a > FLOAT_SINGLE_MIN && a < FLOAT_SINGLE_MAX) {
			// Single Precision Floating
			o.writeByte(0xca);
			o.writeFloat(d);
		} else {
			// Double Precision Floating
			o.writeByte(0xcb);
			o.writeDouble(d);
		}
	}

	inline function writeBinary(b:Bytes) {
		var length = b.length;
		if (length < 0x100) {
			// binary 8
			o.writeByte(0xc4);
			o.writeByte(length);
		} else if (length < 0x10000) {
			// binary 16
			o.writeByte(0xc5);
			o.writeUInt16(length);
		} else {
			// binary 32
			o.writeByte(0xc6);
			o.writeInt32(length);
		}
		o.write(b);
	}

	inline function writeString(b:String) {
		var length = b.length;
		if (length < 0x20) {
			// fix string
			o.writeByte(0xa0 | length);
		} else if (length < 0x100) {
			// string 8
			o.writeByte(0xd9);
			o.writeByte(length);
		} else if (length < 0x10000) {
			// string 16
			o.writeByte(0xda);
			o.writeUInt16(length);
		} else {
			// string 32
			o.writeByte(0xdb);
			o.writeInt32(length);
		}
		o.writeString(b);
	}

	inline function writeArray(d:Array<Dynamic>) {
		var length = d.length;
		if (length < 0x10) {
			// fix array
			o.writeByte(0x90 | length);
		} else if (length < 0x10000) {
			// array 16
			o.writeByte(0xdc);
			o.writeUInt16(length);
		} else {
			// array 32
			o.writeByte(0xdd);
			o.writeInt32(length);
		}
		for (e in d) {
			encodeObject(e);
		}
	}

	inline function writeMapLength(length:Int) {
		if (length < 0x10) {
			// fix map
			o.writeByte(0x80 | length);
		} else if (length < 0x10000) {
			// map 16
			o.writeByte(0xde);
			o.writeUInt16(length);
		} else {
			// map 32
			o.writeByte(0xdf);
			o.writeInt32(length);
		}
	}

	inline function writeMap<K, V>(d:Map<K, V>) {
		var length = 0;
		for (k in d.keys())
			length++;
		writeMapLength(length);
		for (k => v in d) {
			encodeObject(k);
			encodeObject(v);
		}
	}

	inline function writeObject(d:Dynamic) {
		var f = d.fields();
		// writeMapLength(Lambda.count(f));
		writeMapLength(f.length);
		for (k in f) {
			encodeObject(k);
			encodeObject(d.field(k));
		}
	}
}
