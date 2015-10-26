//+------------------------------------------------------------------+
//|                                                    SteveTest.mq4 |
//|                                           Copyright 2015, SteveB |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+

#property copyright "Copyright 2015, SteveB"
#property link      "https://www.mql5.com"
#property version   "1.05"
#property strict

// LTC
// Daily
// T:4.7
// B:3.7
// S:2.8
// MCAD 4/23/20

// BTC
// Daily 
//4519	1299.22	4	0.00	324.81	377.36	12.58%	0.00000000	
//TakeProfit=28 	
//BuyPrice=26 	
//StopLoss=71 	
//MCAD_Fast=16 	
//MCAD_Slow=15 	
//MCAD_Signal=5 	
//Drop_Days_Back=80 	
//Drop_Days_Stop=3 	
//Drop_Amount=387	
//Price_Type=3


input double TakeProfit = 28 ; // How much the price should go up before we take the profit an walk away.
input double BuyPrice =  26 ;  // What price do we want to buy at
input double StopLoss = 71;

input int MCAD_Fast = 16;
input int MCAD_Slow = 15;
input int MCAD_Signal = 5;

input int Price_Type = 3;

input int Drop_Days_Back = 80;
input int Drop_Days_Stop = 3;
input double Drop_Amount = 387;

//input double Low_Multiplier = 1.5;
//input double High_Multiplier = 10.2;
//input double Stop_Multiplier = 10;


datetime NewBarTime; // Used to workout if we have started a new bar
//double LastMACD;
//double LastWMA;
//double LastAwsome;
double LastAsk = 0;
int LastTicket = -1;
bool WaitForRed = False;

int StopCount = 0;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   Alert("Starting.");

   NewBarTime = Time[0]; // Get the current bars time - using this we can work out when we change bar
   
   LastTicket = -1;
   
   if (OrderSelect(0, SELECT_BY_POS)==true)
   {
      LastTicket = OrderTicket();
      Alert("Another Order in play : ", Symbol(), " Ticket : ", LastTicket);
   }

   Alert("Currency : ",OrderSymbol());
   Alert("Lots : ", OrderLots());
   Alert("Deposit currency = ",AccountInfoString(ACCOUNT_CURRENCY));
   Alert("Dollar value : ", AccountBalance());
   Alert("AccountFreeMargin : ", AccountFreeMargin());
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   Alert("Finished.");
  }

// This will set the expiry time for an order
datetime GetExpiryTime()

{     // Date and time manipulation is done via structures
     datetime _ExpiryTime = TimeCurrent(); // This is the time the current order will expire.
            
     MqlDateTime _MqlExiryTime;
     TimeToStruct(_ExpiryTime,_MqlExiryTime); // Need to convert the time to a structure so that it can be manipulated.
     _MqlExiryTime.day = _MqlExiryTime.day + 30;
     _MqlExiryTime.hour = _MqlExiryTime.hour + 23;
     return StructToTime(_MqlExiryTime);

}
 
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{

     
   // Work if the current bar is a new bar   
   if (NewBarTime != Time[0])
   {
   
      //Print("OrdersTotal : ", OrdersTotal());
      for(int i=0;i<OrdersTotal();i++)
      {
         if (OrderSelect(i, SELECT_BY_POS))
         {
            if (Symbol() == OrderSymbol())
            {
               LastTicket = OrderTicket();
               Print("For ", Symbol(), " Order :", LastTicket," Found");
               Print("AccountFreeMargin : ", AccountFreeMargin());
            }
         }
      }
   

      
      if(Big_Drop() > 0)
      {
         // Don't trade
         Print("BIG DROP");
      }
      else
      {
         StopCount = 0;
         if ((iMACD(Symbol(),0,MCAD_Fast,MCAD_Slow,MCAD_Signal,Price_Type, MODE_MAIN,0) > iMACD(Symbol(),0,MCAD_Fast,MCAD_Slow,MCAD_Signal,Price_Type, MODE_MAIN,1)))
         {
            double _TakeProfit = NormalizeDouble(Ask +   ((TakeProfit / 100) * Ask),3) ; // How much the price should go up before we take the profit an walk away.
            double _BuyPrice = NormalizeDouble(Ask - ((BuyPrice / 100) * Ask),3) ;  // What price do we want to buy at
            double _StopLoss = NormalizeDouble(_BuyPrice - ((StopLoss / 100) * Ask) ,3);  // How far the price can drop before we take a loss and walk away
            double _Amount = NormalizeDouble( (AccountBalance() / 3) /  _BuyPrice,3); // How many are we buying
            int _Slipage = 3; // How many point the price can slip when placing the order


            // Place the order
            if (LastTicket == -1 || OrdersTotal() == 0)
            {
               Print("_TakeProfit:",_TakeProfit, " _BuyPrice:",_BuyPrice, " _StopLoss:",_StopLoss);
               LastTicket = OrderSend(Symbol(), OP_BUYLIMIT, _Amount, _BuyPrice, _Slipage, _StopLoss, _TakeProfit,"",0,  NULL, clrHotPink );
            }
            else
            {
               if (!OrderModify(LastTicket,_BuyPrice, _StopLoss, _TakeProfit,NULL,clrHoneydew))
               {
                 Print("Order modified failed.");
               }
            }
         }
         else
         {
            LastTicket = Kill_Ticket(LastTicket);
         }
      }
      NewBarTime = Time[0]; // Used to work out if we are at a new buy
   }
  }
//+------------------------------------------------------------------+

// This checks for significant price drops and will stop the 
// app from trading
int Big_Drop()
{

      // Big run away bit
      if (Open[Drop_Days_Back] > Open[0] + Drop_Amount )
      {
         
         Print("Big Drop! Open[Drop_Days_Back]: ", Open[Drop_Days_Back], " Open[0]: ", Open[0] );
         Print("Big Drop! Time[Drop_Days_Back]: ", Time[Drop_Days_Back], " Time[0]: ", Time[0] );
         // Its dropped to much - we need to stop for a bit
         StopCount = Drop_Days_Stop;

         LastTicket = Kill_Ticket(LastTicket);
      }
      else
      {
         if(StopCount > 0)
         {
            StopCount--;
            Print("Sleeping: ",StopCount);
         }
      }
      return StopCount;
}


   // This will get rid of a given ticket number by either 
   // closing it or deleting it (depending on its status)    
   int Kill_Ticket(int _TicketNo)   
   {
      if (OrdersTotal() > 0)
      {
         if (OrderSelect(LastTicket, SELECT_BY_TICKET)==true)
         {
            if (OrderType() == OP_BUY || OrderType() == OP_SELL)
            {
               if(OrderType()==OP_BUY)
               {
                  if (!OrderClose(OrderTicket(),OrderLots(),Bid, 3,White))
                  {
                     Print("Failed to close buy order");
                  }
               }
               
               if(OrderType()==OP_SELL)
               {
                  if (!OrderClose(OrderTicket(),OrderLots(),Ask, 3,White))
                  {
                     Print("Failed to close sell order");
                  }
               }
            }
            else
            {
               
               if (!OrderDelete(LastTicket))
               {
                  Print("Failed to delete ",LastTicket);
                  Print("Delete OPTYPE : " , OrderType());
               }
            }
            LastTicket  = -1;
         }
         else
         { 
            Print("Cannot find ticket : ", LastTicket);
         }
      }
        
      return -1; // This is the new last ticket number (-1 = no last ticket)
   }