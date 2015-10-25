#property indicator_chart_window    // Indicator is drawn in the main window
#property indicator_buffers 2       // Number of buffers
#property indicator_color1 Blue     // Color of the 1st line
#property indicator_color2 Red      // Color of the 2nd line

// old extern parameters for calling the indicator from MQL
// put some default values here for running indicator normally
string param1;
int param2 = 0;
double param3 = 0.0;
bool param4;
datetime param5;
color param6;

// new extern parameter for calling the indicator from C#
extern string paramsPack;

// utility: append string to the end of string array
void ArrayAppend(string& results[], string result)
{
    ArrayResize(results, ArraySize(results) + 1);
    results[ArraySize(results) - 1] = result;
}

// utility: split a string using a provided separator into results array
void StringSplit(string s, string sep, string& results[])
{
    int pos = StringFind(s, sep);
    if (pos == -1)
    {
        ArrayAppend(results, s);
        return;
    }

    string part = "";
    if (pos > 0)
        part = StringSubstr(s, 0, pos);
    ArrayAppend(results, part);

    string rest = StringSubstr(s, pos + StringLen(sep));
    StringSplit(rest, sep, results);
}

// parse the packed parameter into separate parameters
// call this from the indicator init() function
void ParseParameters()
{
    string results[];
    StringSplit(paramsPack, "|", results);
    if (ArraySize(results) != 6) return;
    param1 = results[0];
    param2 = StrToInteger(results[1]);
    param3 = StrToDouble(results[2]);
    param4 = results[3] == "True";
    param5 = StrToInteger(results[4]);
    param6 = StrToInteger(results[5]);
}


// Declaring arrays (for indicator buffers)
double Buf0[];
double Buf1[];             

int init()                          
{
    ParseParameters();
    // Assigning an array to a buffer
    SetIndexBuffer(0, Buf0);         
    // Assigning an array to a buffer
    SetIndexBuffer(1, Buf1);         
    return (0);
}

int start()
{
    int countedBars = IndicatorCounted();
    //---- check for possible errors
    if (countedBars < 0) countedBars = 0;
    //---- the last counted bar will be recounted
    if (countedBars > 0) countedBars--;

    int barsToCount = Bars - countedBars;

    for (int i = 0; i < barsToCount; i++)
    {
        // Value of 0 buffer on i bar
        Buf0[i] = param2 + param3;
        // Value of 1st buffer on i bar
        Buf1[i] = Low[i];
    }
    return (0);
}

