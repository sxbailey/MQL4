//+------------------------------------------------------------------+
//|                                                         EMAs.mq4 |
//|                        Copyright 2014, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, MetaQuotes Software Corp."
#property link      ""
#property version   "1.00"
#property strict
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Black
#property indicator_color2 Green
#property indicator_color3 Red
#property indicator_color4 Orange
#property indicator_levelwidth 4
//--- input parameters
input int       MaPeriod1=5;
input int       MaPeriod2=10;
input int       MaPeriod3=20;

//Buffers
double Buffer1[];
double Buffer2[];
double Buffer3[];
double Buffer4[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   IndicatorDigits(Digits);
   IndicatorShortName("EMAs(" + IntegerToString(MaPeriod1) + "," + IntegerToString(MaPeriod2) + "," + IntegerToString(MaPeriod3) + ")");
   SetIndexStyle(0,DRAW_NONE);
   SetIndexBuffer(0,Buffer1);
   SetIndexStyle(1,DRAW_HISTOGRAM,EMPTY,4);
   SetIndexBuffer(1,Buffer2);
   SetIndexStyle(2,DRAW_HISTOGRAM,EMPTY,4);
   SetIndexBuffer(2,Buffer3);
   SetIndexStyle(3,DRAW_HISTOGRAM,EMPTY,4);
   SetIndexBuffer(3,Buffer4);
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
   int    countedBars=prev_calculated;
   double ma1, ma2, ma3;
//----
   if(Bars<MaPeriod3)return(0);
   
   for(int i=Bars-countedBars-1; i>=0; i--){
      Buffer1[i]=0;
   
      ma1 = iMA(NULL,0,MaPeriod1,0,MODE_EMA,PRICE_CLOSE,i);
      ma2 = iMA(NULL,0,MaPeriod2,0,MODE_EMA,PRICE_CLOSE,i);
      ma3 = iMA(NULL,0,MaPeriod3,0,MODE_EMA,PRICE_CLOSE,i);
      
      if(ma1>ma2 && ma2>ma3){
         Buffer1[i]+=1;
      }else if(ma1<ma2 && ma2<ma3){
         Buffer1[i]-=1;
      }
      
      if(Buffer1[i]>0){
         Buffer2[i]=2;
         Buffer3[i]=EMPTY_VALUE;
         Buffer4[i]=EMPTY_VALUE;
      }else if(Buffer1[i]<0){
         Buffer2[i]=EMPTY_VALUE;
         Buffer3[i]=2;
         Buffer4[i]=EMPTY_VALUE;
      }else{
         Buffer2[i]=EMPTY_VALUE;
         Buffer3[i]=EMPTY_VALUE;
         Buffer4[i]=1.5;
      }
   }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
