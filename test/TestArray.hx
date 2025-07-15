import utest.Assert.*;
import om.Msgpack;

class TestArray extends utest.Test {
	function test_array() {
		var a = [3, 2, 1, 7, 8, 9];
		var e = Msgpack.encode(a);
		var d = Msgpack.decode(e);
		isOfType(d, Array);
		equals(d.length, 6);
		equals(3, d[0]);
		equals(2, d[1]);
		equals(1, d[2]);
		equals(7, d[3]);
		equals(8, d[4]);
		equals(9, d[5]);
	}
}
