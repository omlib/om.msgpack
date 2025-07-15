import utest.Assert.*;
import om.Msgpack;
import haxe.Int64;

class TestInt64 extends utest.Test {
	function test_int64() {
		var e = Msgpack.encode(Int64.make(1, 2));
		var d = Msgpack.decode(e);
		isTrue(Int64.getHigh(d) == 1);
		isTrue(Int64.getLow(d) == 2);
	}
}
