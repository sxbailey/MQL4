//+------------------------------------------------------------------+
//|                                             Vinin HighLow v1.mq4 |
//|                                        Victor Nicolaev aka Vinin |
//|                                                    vinin@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Victor Nicolaev aka Vinin"
#property link      "mailto: vinin@mail.ru"


#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Yellow
#property indicator_color2 Green
#property indicator_color3 Red


extern int period=34;
extern int price=0;
extern int Shift=0;

//---- buffers
double BufferGreen[];
double BufferYellow[];
double BufferRed[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init() {
   int i;
   for (i=0;i<3;i++) {
      SetIndexStyle(i,DRAW_LINE);
      SetIndexDrawBegin(i,period);
      SetIndexShift(i,Shift);
   }
   SetIndexBuffer(0,BufferYellow);
   SetIndexBuffer(1,BufferGreen);
   SetIndexBuffer(2,BufferRed);
   

   return(0); }//int init() 
//+------------------------------------------------------------------+
int start() {
   int limit;
   double tmp1,tmp2,tmp3;
   int tmpBar, tmpTime;
   int counted_bars=IndicatorCounted();
   int i, j,k;
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
   int cmd;
   for (i = limit;i>=0;i--){
      tmp1=iMA(Symbol(),0,period,0,MODE_SMA,price,i);
      tmp2=iMA(Symbol(),0,period,0,MODE_LWMA,price,i);
      tmp3=3.0*tmp2-2.0*tmp1;
      BufferGreen[i] =tmp3;
      BufferYellow[i]=tmp3;
      BufferRed[i]   =tmp3;
      if (BufferYellow[i]>BufferYellow[i+1]){
         BufferRed[i]=EMPTY_VALUE;
      } else if (BufferYellow[i]<BufferYellow[i+1]){
         BufferGreen[i] =EMPTY_VALUE;
      } else {
         BufferRed[i]=EMPTY_VALUE;         
         BufferGreen[i] =EMPTY_VALUE;
      }
   }
   return(0); 
}


