import utest.Runner;
import utest.ui.Report;

function main() {
	var runner = new Runner();
	runner.addCase(new TestArray());
	runner.addCase(new TestInt64());
	runner.addCase(new TestMap());
	runner.addCase(new TestObject());
	var report = Report.create(runner);
	runner.run();
}
