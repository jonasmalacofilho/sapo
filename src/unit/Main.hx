package unit;

class Main {
	static function main()
	{
		var runner = new utest.Runner();
		runner.addCase(new PasswordTests());
		runner.addCase(new DataBaseMetaToTemplateTests());
		runner.addCase(new RandomTests());
		runner.addCase(new QueryTests());

		utest.ui.Report.create(runner);

		runner.run();
	}
}

