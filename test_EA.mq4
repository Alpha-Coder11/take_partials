//+------------------------------------------------------------------+
//|                                                      test_EA.mq4 |
//|                                                             Qazi |
//|                                          https://www.eustaad.com |
//+------------------------------------------------------------------+
#property strict
#include <calculate_lot_size.mqh>

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

input enum_trade_type trade = TRADE_TYPE_BUY_LIMIT;
input double    stop_loss_value        = 1.42440;
input double    take_profit_value      = 1.38311;
input double    risk_reward_ratio      = 5;
input double    buying_position        = 0;
input double    selling_position       = 1.14195;
input double    max_loss_percent       = 0.01;
input double    lot_close_tp2_percent  = 0.8;

double optimal_lot_size  = 0;
double partial_close_lot = 0;
double tp_2 = 0;
int ticket = 0;
uchar order_status = false;
uchar slippage = 3;

int OnInit()
{ 
  char result = 0;
  /*
  if( IsDemo() == 0 )
  {
      return ( INIT_FAILED );
  }*/
  if( (trade == TRADE_TYPE_BUY) || (trade == TRADE_TYPE_BUY_LIMIT) )
  {
      tp_2 = buying_position + ( risk_reward_ratio * ( buying_position - stop_loss_value ));
      optimal_lot_size = optimal_lot_size( max_loss_percent, buying_position, stop_loss_value);
  }
  else if( (trade == TRADE_TYPE_SELL) || (trade == TRADE_TYPE_SELL_LIMIT) )
  {
      tp_2 = selling_position - ( risk_reward_ratio * ( stop_loss_value - selling_position ));
      optimal_lot_size = optimal_lot_size( max_loss_percent, selling_position, stop_loss_value);
  }
  else if( trade == TRADE_TYPE_NONE )
  {
      optimal_lot_size = optimal_lot_size( max_loss_percent, buying_position, stop_loss_value);
  }
  else
  {
      optimal_lot_size = 0;
      partial_close_lot = 0;
  
  }

  result = validate_inputs();
  if( result != INIT_SUCCEEDED )
  {
      return(result);
  }
  partial_close_lot = optimal_lot_size * lot_close_tp2_percent;
 
  return( INIT_SUCCEEDED );
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   //do nothing   
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{   
    static uint try = 0;
    if( trade == TRADE_TYPE_BUY_LIMIT )
    {
        if ( try == 0 )
        {
            ticket = OrderSend(Symbol(), OP_BUYLIMIT, optimal_lot_size, buying_position, slippage, stop_loss_value, take_profit_value, "Buy Limit",11111,0,clrGreen);
            if(ticket < 0)
            {
                Print("OrderSend failed with error #",GetLastError());
            }
            else
            {
                try = 1;
                Print("Order placed successfully");
            }
        }
        else if(try == 1)
        {
            order_status = OrderClose( ticket, partial_close_lot, tp_2, slippage, clrRed );
            if(order_status == 0 )
            {         
                Print("OrderClose failed with error #",GetLastError());
            }
            else 
            {
                try = 2;
                Print("Order partially closed successfully");
                return;
            }
        }
    }
    else if( trade == TRADE_TYPE_SELL_LIMIT)
    {    
        if ( try == 0 )
        {
            ticket = OrderSend(Symbol(), OP_SELLLIMIT, optimal_lot_size, selling_position, slippage, stop_loss_value, take_profit_value, "Sell Limit",22222,0,clrGreen);
            if(ticket < 0)
            {
                Print("OrderSend failed with error #",GetLastError());
            }
            else
            {
                try = 1;
                Print("Order placed successfully");
            }
        }
        else if(try == 1)
        {
            order_status = OrderClose( ticket, partial_close_lot, tp_2, slippage, clrRed );
            if(order_status == 0 )
            {         
                Print("OrderClose failed with error #",GetLastError());
            }
            else 
            {
                try = 2;
                Print("Order partially closed successfully");
                return;
            }
        }
    }
    else if ( trade == TRADE_TYPE_BUY)
    {
        if ( try == 0 )
        {
            ticket = OrderSend(Symbol(), OP_BUY, optimal_lot_size, Ask, slippage, stop_loss_value,take_profit_value, "Buy order", 88888, 0, clrBlue);
        }
        else if ( try == 1 )
        {
            order_status = OrderClose( ticket, partial_close_lot, tp_2, slippage, clrRed );
            if( order_status == 0 )
            {
                Print("OrderClose failed with error #", GetLastError());
            }
            else
            {
                try = 2;
                Print("Order partially closed successfully");
                return;
            }
        }
    }
    else if (trade == TRADE_TYPE_SELL)
    {
        if ( try == 0 )
        {
            ticket = OrderSend(Symbol(), OP_BUY, optimal_lot_size, Bid, slippage, stop_loss_value,take_profit_value,"Sell Order", 99999, 0, clrYellow);            
        }
        else if( try == 1)
        {
            order_status= OrderClose( ticket, partial_close_lot, tp_2, slippage, clrRed);
            if( order_status == 0)
            {
                Print("OrderClose failed with error #", GetLastError());
            }
            else
            {
                try = 2;
                Print("Order partially closed successfully");
                return;
            }
        }
    }
    else 
    {
      Alert("Optimal Lot Size", optimal_lot_size);
      return;
    }
}

int trade_filter()
{
    return 0;
}
//+------------------------------------------------------------------+
char validate_inputs()
{   
    char ret = INIT_PARAMETERS_INCORRECT;
    if( (trade == TRADE_TYPE_BUY) || (trade == TRADE_TYPE_BUY_LIMIT) )
    {
        if( (take_profit_value > tp_2)
        && (tp_2 > buying_position) && (buying_position > stop_loss_value)
        && (stop_loss_value > 0) )
        {
            ret = INIT_SUCCEEDED;
        }
    }
    else if( (trade == TRADE_TYPE_SELL) && (trade == TRADE_TYPE_SELL_LIMIT) )
    { 
        if( (take_profit_value > 0)
        && (take_profit_value < tp_2) && (tp_2 < selling_position) 
        && (selling_position < stop_loss_value) )
        {
            ret = INIT_SUCCEEDED;
        }
    }
    else
    {
        Alert("Error");
    }

    return ret;
}