
#property copyright "(c) 2012-2015 Brainroom Ltd."
#property link "http://www.nquotes.net"

#import "nquotes/nquoteslib.ex4"
	int nquotes_setup(string className, string assemblyName);
	int nquotes_init();
	int nquotes_start();
	int nquotes_deinit();
	double nquotes_on_tester();
	int nquotes_on_timer();
	int nquotes_on_chart_event(int id, long lparam, double dparam, string sparam);

	int nquotes_set_property_bool(string name, bool value);
	int nquotes_set_property_int(string name, int value);
	int nquotes_set_property_double(string name, double value);
	int nquotes_set_property_datetime(string name, datetime value);
	int nquotes_set_property_color(string name, color value);
	int nquotes_set_property_string(string name, string value);
	int nquotes_set_property_adouble(string name, double& value[], int count=WHOLE_ARRAY, int start=0);

	bool nquotes_get_property_bool(string name);
	int nquotes_get_property_int(string name);
	double nquotes_get_property_double(string name);
	datetime nquotes_get_property_datetime(string name);
	color nquotes_get_property_color(string name);
	string nquotes_get_property_string(string name);
	int nquotes_get_property_array_size(string name);
	int nquotes_get_property_adouble(string name, double& value[]);
#import

int init()
{
	nquotes_setup(NULL, NULL);
	return (nquotes_init());
}

int start()
{
	return (nquotes_start());
}

int deinit()
{
	return (nquotes_deinit());
}

double OnTester()
{
	return (nquotes_on_tester());
}

void OnTimer()
{
	nquotes_on_timer();
}

void OnChartEvent(const int id, const long& lparam, const double& dparam, const string& sparam)
{
	nquotes_on_chart_event(id, lparam, dparam, sparam);
}
