import utest.Assert.*;
import om.Msgpack;
import haxe.ds.IntMap;
import haxe.ds.StringMap;

class TestMap extends utest.Test {
	function test_intmap() {
		var im = new IntMap<String>();
		im.set(1, "one");
		im.set(3, "Three");
		im.set(9, "Nine");
		var e = Msgpack.encode(im);
		var d = Msgpack.decode(e, AsMap);
		isOfType(d, haxe.ds.IntMap);
		equals("one", d.get(1));
		equals("Three", d.get(3));
		equals("Nine", d.get(9));
	}

	function test_stringmap() {
		var sm = new StringMap<Int>();
		sm.set("one", 1);
		sm.set("Three", 3);
		sm.set("Nine", 9);
		var e = Msgpack.encode(sm);
		var d = Msgpack.decode(e, AsMap);
		isOfType(d, haxe.ds.StringMap);
		equals(1, d.get("one"));
		equals(3, d.get("Three"));
		equals(9, d.get("Nine"));
	}
}
