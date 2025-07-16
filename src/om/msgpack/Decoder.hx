package om.msgpack;

import haxe.Int64;
import haxe.ds.IntMap;
import haxe.ds.StringMap;
import haxe.io.Bytes;
import haxe.io.BytesInput;

using Reflect;

enum DecodeOption {
	AsMap;
	AsObject;
}

private class Pair {
	public var k(default, null):Dynamic;
	public var v(default, null):Dynamic;

	public inline function new(k, v) {
		this.k = k;
		this.v = v;
	}
}

class Decoder {
	public var option:DecodeOption;

	var o:Dynamic;

	public function new(?option:DecodeOption) {
		this.option = option ?? AsObject;
	}

	public function decode(bytes:Bytes):Dynamic {
		var i = new BytesInput(bytes);
		i.bigEndian = true;
		o = decodeInput(i);
		return o;
	}

	function decodeInput(i:BytesInput):Dynamic {
		// try {
		final b = i.readByte();
		switch b {
			// null
			case 0xc0:
				return null;

			// boolean
			case 0xc2:
				return false;
			case 0xc3:
				return true;

			// binary
			case 0xc4:
				return i.read(i.readByte());
			case 0xc5:
				return i.read(i.readUInt16());
			case 0xc6:
				return i.read(i.readInt32());

			// floating point
			case 0xca:
				return i.readFloat();
			case 0xcb:
				return i.readDouble();

			// unsigned int
			case 0xcc:
				return i.readByte();
			case 0xcd:
				return i.readUInt16();
			case 0xce:
				return i.readInt32();
			case 0xcf:
				throw "UInt64 not supported";

			// signed int
			case 0xd0:
				return i.readInt8();
			case 0xd1:
				return i.readInt16();
			case 0xd2:
				return i.readInt32();
			case 0xd3:
				return readInt64(i);

			// string
			case 0xd9:
				return i.readString(i.readByte());
			case 0xda:
				return i.readString(i.readUInt16());
			case 0xdb:
				return i.readString(i.readInt32());

			// array 16, 32
			case 0xdc:
				return readArray(i, i.readUInt16());
			case 0xdd:
				return readArray(i, i.readInt32());

			// map 16, 32
			case 0xde:
				return readMap(i, i.readUInt16());
			case 0xdf:
				return readMap(i, i.readInt32());

			default:
				if (b < 0x80) {
					return b;
				} else // positive fix num
					if (b < 0x90) {
						return readMap(i, (0xf & b));
					} else // fix map
						if (b < 0xa0) {
							return readArray(i, (0xf & b));
						} else // fix array
							if (b < 0xc0) {
								return i.readString(0x1f & b);
							} else // fix string
								if (b > 0xdf) {
									return 0xffffff00 | b;
								} // negative fix num
		}
		// } catch (e:Eof) {
		//	trace("EOF", e);
		// }
		return null;
	}

	inline function readInt64(i:BytesInput):Int64 {
		return Int64.make(i.readInt32(), i.readInt32());
	}

	inline function readArray(i:BytesInput, length:Int):Array<Dynamic> {
		return [for (_ in 0...length) decodeInput(i)];
	}

	function readMap(i:BytesInput, length:Int):Any {
		switch option {
			case DecodeOption.AsObject:
				var out = {};
				// TODO:
				// var out:haxe.DynamicAccess<Dynamic> = {};
				for (n in 0...length) {
					var k = decodeInput(i);
					var v = decodeInput(i);
					// out[k] = v;
					Reflect.setField(out, Std.string(k), v);
					// inline Reflect.setField(out, Std.string(k), v);
				}
				return out;
			case DecodeOption.AsMap:
				var pairs = [];
				for (n in 0...length) {
					var k = decodeInput(i);
					var v = decodeInput(i);
					pairs.push(new Pair(k, v));
				}
				if (pairs.length == 0)
					return new StringMap();
				switch Type.typeof(pairs[0].k) {
					case TInt:
						var out = new IntMap();
						for (p in pairs) {
							switch Type.typeof(p.k) {
								case TInt:
								default:
									throw "Error: mixed key type when decoding IntMap";
							}
							if (out.exists(p.k))
								throw 'Error: duplicate keys found => ${p.k}';
							out.set(p.k, p.v);
						}
						return out;
					case TClass(c) if (Type.getClassName(c) == "String"):
						var out = new StringMap();
						for (p in pairs) {
							switch Type.typeof(p.k) {
								case TClass(c) if (Type.getClassName(c) == "String"):
								default:
									throw "Error: mixed key type when decoding StringMap";
							}
							if (out.exists(p.k))
								throw 'Error: duplicate keys found => ${p.k}';
							out.set(p.k, p.v);
						}
						return out;
					default:
						throw "Error: unsupported key type";
				}
		}
	}
}
