//+------------------------------------------------------------------+
//|                                                         HLC3.mq4 |
//|                                           Copyright 2015, SteveB |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, SteveB"
#property link      "https://www.mql5.com"
#property version   "1.01"
#property strict
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   4
//--- plot Low
#property indicator_label1  "Low"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_DASHDOT
#property indicator_width1  1
//--- plot High
#property indicator_label2  "High"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrYellow
#property indicator_style2  STYLE_DASHDOT
#property indicator_width2  1

//--- plot Good
#property indicator_label3  "Good"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrGreen
#property indicator_style3  STYLE_SOLID
#property indicator_width3  3
//--- plot Bad
#property indicator_label4  "Bad"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrRed
#property indicator_style4  STYLE_SOLID
#property indicator_width4  3
//--- indicator buffers
double         LowBuffer[];
double         HighBuffer[];
double         GoodBuffer[];
double         BadBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,LowBuffer);
   SetIndexBuffer(1,HighBuffer);
   SetIndexBuffer(2,GoodBuffer);
   SetIndexBuffer(3,BadBuffer);
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
      

 
   int i,limit;
//---

//--- last counted bar will be recounted
   limit=rates_total-prev_calculated;
   if(prev_calculated>0)
      limit++;
//--- macd counted in the 1-st buffer
   for(i=0; i<limit -1; i++)
   {
      double pf = 0;
   
   
   
   
      pf = (( high[i] + low[i+1] + close[i+1]) / 3) * 2;
      HighBuffer[i] = pf - low[i+1];
      LowBuffer[i] = (pf - high[i+1]) + 1;
      
      if (iMA(NULL,0,10,0,MODE_LWMA,PRICE_WEIGHTED,i + 1) <  iMA(NULL,0,10,0,MODE_LWMA,PRICE_WEIGHTED,i)  )
      {
            GoodBuffer[i] = iMA(NULL,0,10,0,MODE_LWMA,PRICE_WEIGHTED,i) ;
      }
      else
      {
            BadBuffer[i]= iMA(NULL,0,10,0,MODE_LWMA,PRICE_WEIGHTED,i);
      }
      
      
      
   }
      
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
