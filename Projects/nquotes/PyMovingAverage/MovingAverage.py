#+------------------------------------------------------------------+
#| This script is converted from:                                   |
#|                                               Moving Average.mq4 |
#|                    Copyright (c) 2005, MetaQuotes Software Corp. |
#|                                       http://www.metaquotes.net/ |
#+------------------------------------------------------------------+

import System
from System.Drawing import Color
from System import DateTime
from NQuotes import *
from NQuotes import MqlApiConstants as C


class MovingAverage (IExpertAdvisor):
	MAGICMA = 20050610

	MaximumRisk = 0.02
	DecreaseFactor = 3
	MovingPeriod = 12
	MovingShift = 6

	def CalculateCurrentOrders(self):
		"""Calculate open positions"""

		buys = 0
		sells = 0
		mql = self.api

		for i in range(mql.OrdersTotal()):
			if not mql.OrderSelect(i, C.SELECT_BY_POS, C.MODE_TRADES):
				break
			if (mql.OrderSymbol() == mql.Symbol()) and (mql.OrderMagicNumber() == MovingAverage.MAGICMA):
				if (mql.OrderType() == C.OP_BUY):
					buys += 1
				if (mql.OrderType() == C.OP_SELL):
					sells += 1
		
		# return orders volume
		if (buys > 0):
			return buys
		return -sells

	def LotsOptimized(self):
		"""Calculate optimal lot size"""

		mql = self.api
		# history orders total
		orders = mql.OrdersHistoryTotal()
		# number of losses orders without a break
		losses = 0				  
		# select lot size
		lot = mql.NormalizeDouble(mql.AccountFreeMargin() * MovingAverage.MaximumRisk / 1000.0, 1)
		# calculate number of losses orders without a break
		if (MovingAverage.DecreaseFactor > 0):
			for i in reversed(range(orders)):
				if not mql.OrderSelect(i, C.SELECT_BY_POS, C.MODE_HISTORY):
					mql.Print("Error in history!")
					break
				if (mql.OrderSymbol() != mql.Symbol()) or (mql.OrderType() > C.OP_SELL):
					continue
				
				if (mql.OrderProfit() > 0):
					break
				if (mql.OrderProfit() < 0):
					losses += 1
			if (losses > 1):
				lot = mql.NormalizeDouble(lot - lot * losses / MovingAverage.DecreaseFactor, 1)
		# return lot size
		if (lot < 0.1):
			lot = 0.1
		return lot

	def CheckForOpen(self, symbol):
		"""Check for open order conditions"""

		mql = self.api
		# go trading only for first tiks of new bar
		if (mql.Volume[0] > 1):
			return
		
		# get Moving Average 
		ma = mql.iMA(symbol, 0, MovingAverage.MovingPeriod, MovingAverage.MovingShift, C.MODE_SMA, C.PRICE_CLOSE, 0)
		
		# sell conditions
		if (mql.Open[1] > ma) and (mql.Close[1] < ma):
			mql.OrderSend(mql.Symbol(), C.OP_SELL, self.LotsOptimized(), mql.Bid, 3, 0, 0, "", MovingAverage.MAGICMA, DateTime.MinValue, Color.Red)
			return
		# buy conditions
		if (mql.Open[1] < ma) and (mql.Close[1] > ma):
			mql.OrderSend(mql.Symbol(), C.OP_BUY, self.LotsOptimized(), mql.Ask, 3, 0, 0, "", MovingAverage.MAGICMA, DateTime.MinValue, Color.Blue)

	def CheckForClose(self, symbol):
		"""Check for close order conditions"""
		
		mql = self.api
		# go trading only for first tiks of new bar
		if (mql.Volume[0] > 1):
			return
		# get Moving Average 
		ma = mql.iMA(symbol, 0, MovingAverage.MovingPeriod, MovingAverage.MovingShift, C.MODE_SMA, C.PRICE_CLOSE, 0)
		
		for i in range(mql.OrdersTotal()):
			if not mql.OrderSelect(i, C.SELECT_BY_POS, C.MODE_TRADES):
				break
			if (mql.OrderMagicNumber() != MovingAverage.MAGICMA) or (mql.OrderSymbol() != mql.Symbol()):
				continue
			# check order type 
			if (mql.OrderType() == C.OP_BUY):
				if (mql.Open[1] > ma) and (mql.Close[1] < ma):
					mql.OrderClose(mql.OrderTicket(), mql.OrderLots(), mql.Bid, 3, Color.White)
				break
			if (mql.OrderType() == C.OP_SELL):
				if (mql.Open[1] < ma) and (mql.Close[1] > ma):
					mql.OrderClose(mql.OrderTicket(), mql.OrderLots(), mql.Ask, 3, Color.White)
				break

	def start(self):
		"""Start function"""

		mql = self.api
		# check for history and trading
		if (mql.Bars < 100) or (not mql.IsTradeAllowed()):
			return 0
		
		# calculate open orders by current symbol
		symbol = mql.Symbol()
		if (self.CalculateCurrentOrders() == 0):
			self.CheckForOpen(symbol)
		else:
			self.CheckForClose(symbol)

		return 0

	def init(self):
		return 0
	def deinit(self):
		return 0
	def set_Api(self, api):
		self.api = api
	def get_Api(self):
		return (self.api if hasattr(self, 'api') else None)
