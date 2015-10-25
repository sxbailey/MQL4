
#property copyright "(c) 2013 Acme Corporation"
#property link "http://www.nquotes.net"

#import "nquotes/nquoteslib.ex4"
	int nquotes_setup(string className, string assemblyName);
	int nquotes_init();
	int nquotes_start();
	int nquotes_deinit();

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

extern double MaximumRisk = 0.02;
extern double DecreaseFactor = 3;
extern int MovingPeriod = 12;
extern int MovingShift = 6;

int init()
{
	nquotes_setup("MetaQuotesSample.MovingAverage", "MovingAverageCustom");
	nquotes_set_property_double("MaximumRisk", MaximumRisk);
	nquotes_set_property_double("DecreaseFactor", DecreaseFactor);
	nquotes_set_property_int("MovingPeriod", MovingPeriod);
	nquotes_set_property_int("MovingShift", MovingShift);
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
