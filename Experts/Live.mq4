//+------------------------------------------------------------------+
//|                                                    SteveTest.mq4 |
//|                                           Copyright 2015, SteveB |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+

#property copyright "Copyright 2015, SteveB"
#property link      "https://www.mql5.com"
#property version   "1.05"
#property strict


// Daily
// T:23
// B:6
// S:5
// MCAD 6/17/11

input double TakeProfit = 18 ; // How much the price should go up before we take the profit an walk away.
input double BuyPrice =  6 ;  // What price do we want to buy at
input double StopLoss = 5;

input int MCAD_Fast = 6;
input int MCAD_Slow = 17;
input int MCAD_Signal = 11;

input int Price_Type = 3;


datetime NewBarTime; // Used to workout if we have started a new bar
//double LastMACD;
//double LastWMA;
//double LastAwsome;
double LastAsk = 0;
int LastTicket = -1;
bool WaitForRed = False;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   Alert("Starting.");

   NewBarTime = Time[0]; // Get the current bars time - using this we can work out when we change bar
   
   LastTicket = -1;
   
   Alert("Deposit currency = ",AccountInfoString(ACCOUNT_CURRENCY));
   Alert("Dollar value : ", AccountBalance());

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
   //Alert ("New tick : ", Ask);
   //return;
   
   // Work if the current bar is a new bar   
   if (NewBarTime != Time[0])
   {
      Alert("New bar.");
      if ((iMACD(NULL,0,MCAD_Fast,MCAD_Slow,MCAD_Signal,Price_Type, MODE_MAIN,0) > iMACD(NULL,0,MCAD_Fast,MCAD_Slow,MCAD_Signal,Price_Type, MODE_MAIN,1)))
      {

         double _TakeProfit = Ask + TakeProfit ; // How much the price should go up before we take the profit an walk away.
         double _BuyPrice = Ask - BuyPrice ;  // What price do we want to buy at
         double _StopLoss = _BuyPrice - StopLoss;  // How far the price can drop before we take a loss and walk away
         double _Amount = NormalizeDouble( AccountBalance() /  (Ask - 6),3) -0.02; // How many are we buying
         int _Slipage = 3; // How many point the price can slip when placing the order
  
         // Place the order
         if (LastTicket == -1 || OrdersTotal() == 0)
         {
            Alert("Buying.");
            LastTicket = OrderSend(Symbol(), OP_BUYLIMIT, _Amount, _BuyPrice, _Slipage, _StopLoss, _TakeProfit,"",0,  NULL, clrHotPink );
         }
         else
         {
           
            if (!OrderModify(LastTicket,_BuyPrice, _StopLoss, _TakeProfit,NULL,clrHoneydew))
            {
              Alert("Modifying.");
              Print("Order modified failed.");
            }
         }

      }
      else
      {
         // Get rid of the current ticket
         Alert("Selling");
         LastTicket = Kill_Ticket(LastTicket);

      }
      
      NewBarTime = Time[0]; // Used to work out if we are at a new buy
      
   }
  }
//+------------------------------------------------------------------+

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