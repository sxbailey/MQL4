using System;
using Color = System.Drawing.Color;
using NQuotes;

namespace MetaQuotesSample
{
    //+------------------------------------------------------------------+
    //|                                               Moving Average.mq4 |
    //|                      Copyright © 2005, MetaQuotes Software Corp. |
    //|                                       http://www.metaquotes.net/ |
    //+------------------------------------------------------------------+
    public class MovingAverage : MqlApi
    {
        const int MAGICMA = 20050610;

        double MaximumRisk = 0.02;
        double DecreaseFactor = 3;
        int MovingPeriod = 12;
        int MovingShift = 6;

        //+------------------------------------------------------------------+
        //| Calculate open positions                                         |
        //+------------------------------------------------------------------+
        int CalculateCurrentOrders()
        {
            int buys = 0, sells = 0;

            for (int i = 0; i < OrdersTotal(); i++)
            {
                if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) break;
                if (OrderSymbol() == Symbol() && OrderMagicNumber() == MAGICMA)
                {
                    if (OrderType() == OP_BUY) buys++;
                    if (OrderType() == OP_SELL) sells++;
                }
            }
            
            //---- return orders volume
            if (buys > 0) return (buys);
            return (-sells);
        }

        //+------------------------------------------------------------------+
        //| Calculate optimal lot size                                       |
        //+------------------------------------------------------------------+
        double LotsOptimized()
        {
            // history orders total
            int orders = OrdersHistoryTotal();
            // number of losses orders without a break
            int losses = 0;                  
            //---- select lot size
            double lot = NormalizeDouble(AccountFreeMargin() * MaximumRisk / 1000.0, 1);
            //---- calcuulate number of losses orders without a break
            if (DecreaseFactor > 0)
            {
                for (int i = orders - 1; i >= 0; i--)
                {
                    if (!OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) { Print("Error in history!"); break; }
                    if (OrderSymbol() != Symbol() || OrderType() > OP_SELL) continue;
                    
                    if (OrderProfit() > 0) break;
                    if (OrderProfit() < 0) losses++;
                }
                if (losses > 1) lot = NormalizeDouble(lot - lot * losses / DecreaseFactor, 1);
            }
            //---- return lot size
            if (lot < 0.1) lot = 0.1;
            return (lot);
        }

        //+------------------------------------------------------------------+
        //| Check for open order conditions                                  |
        //+------------------------------------------------------------------+
        void CheckForOpen(string symbol)
        {
            //---- go trading only for first tiks of new bar
            if (Volume[0] > 1) return;
            
            //---- get Moving Average 
            double ma = iMA(symbol, 0, MovingPeriod, MovingShift, MODE_SMA, PRICE_CLOSE, 0);
            
            //---- sell conditions
            if (Open[1] > ma && Close[1] < ma)
            {
                OrderSend(Symbol(), OP_SELL, LotsOptimized(), Bid, 3, 0, 0, "", MAGICMA, DateTime.MinValue, Color.Red);
                return;
            }
            //---- buy conditions
            if (Open[1] < ma && Close[1] > ma)
            {
                OrderSend(Symbol(), OP_BUY, LotsOptimized(), Ask, 3, 0, 0, "", MAGICMA, DateTime.MinValue, Color.Blue);
            }
        }

        //+------------------------------------------------------------------+
        //| Check for close order conditions                                 |
        //+------------------------------------------------------------------+
        void CheckForClose(string symbol)
        {
            
            //---- go trading only for first tiks of new bar
            if (Volume[0] > 1) return;
            //---- get Moving Average 
            double ma = iMA(symbol, 0, MovingPeriod, MovingShift, MODE_SMA, PRICE_CLOSE, 0);
            
            for (int i = 0; i < OrdersTotal(); i++)
            {
                if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) break;
                if (OrderMagicNumber() != MAGICMA || OrderSymbol() != Symbol()) continue;
                //---- check order type 
                if (OrderType() == OP_BUY)
                {
                    if (Open[1] > ma && Close[1] < ma) OrderClose(OrderTicket(), OrderLots(), Bid, 3, Color.White);
                    break;
                }
                if (OrderType() == OP_SELL)
                {
                    if (Open[1] < ma && Close[1] > ma) OrderClose(OrderTicket(), OrderLots(), Ask, 3, Color.White);
                    break;
                }
            }
        }

        //+------------------------------------------------------------------+
        //| Start function                                                   |
        //+------------------------------------------------------------------+
        public override int start()
        {
            //---- check for history and trading
            if (Bars < 100 || !IsTradeAllowed()) return 0;
            
            //---- calculate open orders by current symbol
            string symbol = Symbol();
            if (CalculateCurrentOrders() == 0) CheckForOpen(symbol);
            else CheckForClose(symbol);

            return 0;
        }

    }
}
