//+------------------------------------------------------------------+
//|                                                    SteveTest.mq4 |
//|                                           Copyright 2015, SteveB |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+

#property copyright "Copyright 2015, SteveB"
#property link      "https://www.mql5.com"
#property version   "1.04"
#property strict

#define PERIOD_FAST  5
#define PERIOD_SLOW 34

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
   NewBarTime = Time[0]; // Get the current bars time - using this we can work out when we change bar
   
   LastTicket = -1;
   
   Print("Deposit currency = ",AccountInfoString(ACCOUNT_CURRENCY));
   
   
   // Theory test
   
   // Work out which is the best price drop.
   
   /*
   int _PriceDrop = 0;
   for(_PriceDrop = 1; _PriceDrop < 20; _PriceDrop++)
   {
   
      int _Win = 0;
      int _Fail = 0;
      double _Profit = 0;
      double _TotalCommision = 0;
      double _Profit_Nett = 0;
   
      // Loop round the past 100 days
      int _Periods = 0; // One period is one day
      for(_Periods=0;_Periods < 365;_Periods++)
      {
         // Only go if green
         ;
         //if (iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,0) > iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,1)
         if (iMA(NULL,0,10,0,MODE_LWMA, PRICE_WEIGHTED,_Periods) > iMA(NULL,0,10,0,MODE_LWMA,PRICE_WEIGHTED,_Periods+1) )
         {
            // Assumption - buying 1 BTC each time
            double _Cost = (1 * Open[_Periods] - _PriceDrop); 
            double _Commision = _Cost * 0.0002;
            double _TotalCost = _Cost + _Commision;
            
            // ASK for buying
            // BID for selling
            
            //Print("Cost : ", _Cost);
            //Print("Commision : ", _Commision);
            //Print("Total Cost : ", _Cost + _Commision);
            
            //Print("Low : ", Low[_Periods]);
            
            if (Low[_Periods] < _Cost)
            {
               // Success - bought
               _Win++;
               
               //Print("  Time " ,Time[_Periods]  , " Close : ", Close[_Periods], " Cost : ", _Cost, " Commision : ", _Commision * 2, " Profit Nett : ", (Close[_Periods] - _Cost), " Profit Gross : ", ((Close[_Periods] - _Cost ) - _Commision * 2) );
               
               _Profit = _Profit + ((Close[_Periods] - _Cost ) - _Commision * 2) ;
               _TotalCommision = _TotalCommision + (_Commision * 2);
               _Profit_Nett = _Profit_Nett + (Close[_Periods] - _Cost);
               
            }
            else
            {
               // Failed - no sale
               _Fail++;
            }

            //Print("Time : " , Time[_Periods] , " Buy at : " , Open[_Periods] - _PriceDrop , " Close : " , Close[_Periods]);   
    
         }
      }
      
      Print("Price drop : ",_PriceDrop, " Win : ", _Win, " Fail : ",_Fail, " Profit : ", _Profit, " Commision : ", _TotalCommision, " Profit Nett : " , _Profit_Nett);
      
      
   }
   */
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }




//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {

   //return;
   
   // Work if the current bar is a new bar   
   if (NewBarTime != Time[0])
   {
      if (iMA(NULL,0,10,0,MODE_LWMA, PRICE_WEIGHTED,0) > iMA(NULL,0,10,0,MODE_LWMA,PRICE_WEIGHTED,1) )
      {
      
         double _TakeProfit = Ask + 2 ; // How much the price should go up before we take the profit an walk away.
         double _BuyPrice = Ask - 7 ;  // What price do we want to buy at
         double _StopLoss = _BuyPrice - 30;  // How far the price can drop before we take a loss and walk away
         double _Amount = NormalizeDouble( AccountBalance() /  (Ask - 6),3) -0.01; // How many are we buying
         int _Slipage = 3; // How many point the price can slip when placing the order
  
         // Place the order
         if (LastTicket == -1 || OrdersTotal() == 0)
         {
            LastTicket = OrderSend(Symbol(), OP_BUYLIMIT, _Amount, _BuyPrice, _Slipage, _StopLoss, _TakeProfit,"",0,  NULL, clrHotPink );
         }
         else
         {
           
            //if (OrderModify(LastTicket,_BuyPrice, _StopLoss, _TakeProfit,NULL,clrHoneydew))
            //{
               //Print("Order Modified");
            //}
         }

      }
      else
      {
         // Get rid of the current ticket
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