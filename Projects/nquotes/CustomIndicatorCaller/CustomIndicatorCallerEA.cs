using System;
using System.Drawing;
using NQuotes;

namespace CustomIndicatorCaller
{
    public class CustomIndicatorCallerEA : MqlApi
    {
        private double CustomHighLowIndicator(
            string param1,
            int param2,
            double param3,
            bool param4,
            DateTime param5,
            Color param6)
        {
            // pack parameters of different types into a single string
            string[] parameters =
            {
                param1,
                param2.ToString(),
                param3.ToString(),
                param4.ToString(),
                new MqlDateTime(param5).IntValue.ToString(),
                ColorTranslator.ToWin32(param6).ToString(),
            };
            string paramsPack = String.Join("|", parameters);
            return iCustom(Symbol(), 0, "CustomHighLowIndicator", paramsPack, 0, 0);
        }

        public override int init()
        {
            // set parameter values
            string param1 = "value1";
            int param2 = 222;
            double param3 = 33.33;
            bool param4 = true;
            DateTime param5 = DateTime.Now;
            Color param6 = Color.Red;

            // call indicator
            double result = CustomHighLowIndicator(
                param1,
                param2,
                param3,
                param4,
                param5,
                param6);

            // expected value: param2 + param3
            Print("CustomHighLowIndicator value = ", result);
            return 0;
        }

    }
}
