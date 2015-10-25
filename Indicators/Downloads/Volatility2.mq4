//+------------------------------------------------------------------+
//|                                                   Volatility.mq4 |
//|                                       Copyright © 2007, Eva Ruft |
//|                                                briz18@rambler.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, Eva Ruft"
#property link      "briz18@rambler.ru"

#property indicator_separate_window
#property indicator_buffers 1
//---- input parameters
extern int VolatilityPeriod=5;
//---- indicator buffers
double MainBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- drawing settings
   SetLevelValue(0,50);
   SetLevelStyle(0,1,Black);
   SetLevelValue(1,100);
   SetLevelStyle(0,0,Black);
   SetLevelValue(2,200);
   SetLevelStyle(0,0,Black);
   SetLevelValue(3,300);
   SetLevelStyle(0,0,Black);
   SetLevelValue(4,400);
   SetLevelStyle(0,0,Black);
   SetIndexStyle(0,DRAW_LINE,0,2,SteelBlue);
   SetIndexBuffer(0, MainBuffer);
   SetIndexDrawBegin(0,VolatilityPeriod);
   IndicatorDigits(Digits+2);
//---- name for DataWindow and indicator subwindow label
   IndicatorShortName("Volatility("+VolatilityPeriod+")");
   SetIndexLabel(0,"Volatility");
//---- initialization done
   return(0);
  }

//+------------------------------------------------------------------+
//|Volatility                                                        |
//+------------------------------------------------------------------+
int start()
  {
   int limit;
   int counted_bars=IndicatorCounted();
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
//---- Volatility counted
   for(int i=0; i<limit; i++)
      MainBuffer[i]=(iMA(NULL,0,VolatilityPeriod,0,MODE_SMA,PRICE_HIGH,i)-iMA(NULL,0,VolatilityPeriod,0,MODE_SMA,PRICE_LOW,i))*100;
//----
   return(0);
  }
//+------------------------------------------------------------------+