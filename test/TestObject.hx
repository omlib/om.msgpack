import utest.Assert.*;
import om.Msgpack;

class TestObject extends utest.Test {
	function test_object() {
		var e = Msgpack.encode({a: 10, b: "abc"});
		var d = Msgpack.decode(e);
		isTrue(Reflect.hasField(d, "a"));
		isTrue(Reflect.hasField(d, "b"));
		equals(10, Reflect.field(d, "a"));
		equals("abc", Reflect.field(d, "b"));
	}
}
