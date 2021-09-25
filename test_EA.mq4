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
input double    stop_loss_value        = 0.0;
input double    take_profit_value      = 0.0;
input double    risk_reward_ratio      = 5;
input double    buying_position        = 0.0;
input double    selling_position       = 0.0;
input double    max_loss_percent       = 0.01;
input double    lot_close_tp2_percent  = 0.8;
input double    show_error_alerts      = 0;
 
double optimal_lot_size  = 0;
double partial_close_lot = 0;
double tp_2 = 0;
int ticket = 0;
uchar order_status = false;
uchar slippage = 3;
double  last_price = 0;
int OnInit()
{
  Alert(" "); 
  double temp = 0;  
  char result = 0;
  /*
  if( IsDemo() == 0 )
  {
      return ( INIT_FAILED );
  }*/
  if( trade == TRADE_TYPE_BUY_LIMIT )
  {
      last_price = Ask;
      tp_2 = buying_position + ( risk_reward_ratio * ( buying_position - stop_loss_value ));
      optimal_lot_size = optimal_lot_size( max_loss_percent, buying_position, stop_loss_value);
      Alert("Partials will be closed approximately at price: "  + tp_2);
  }
  else if( trade == TRADE_TYPE_BUY )
  {
      last_price = Ask;
      temp = Ask;
      tp_2 = temp + ( risk_reward_ratio * (temp - stop_loss_value ));
      optimal_lot_size = optimal_lot_size( max_loss_percent, temp, stop_loss_value);
      Alert("Partials will be closed approximately at price: "  + tp_2);
  }
  else if (trade == TRADE_TYPE_SELL_LIMIT) 
  {   last_price = Bid;
      tp_2 = selling_position - ( risk_reward_ratio * ( stop_loss_value - selling_position ));
      optimal_lot_size = optimal_lot_size( max_loss_percent, selling_position, stop_loss_value);
      Alert("Partials will be closed approximately at price: "  + tp_2);
  }
  else if( trade == TRADE_TYPE_SELL )
  {   
      last_price = Bid;
      temp = Bid;
      tp_2 = temp - ( risk_reward_ratio * ( stop_loss_value - temp ));
      optimal_lot_size = optimal_lot_size( max_loss_percent, temp, stop_loss_value);
      Alert("Partials will be closed approximately at price: "  + tp_2);      
  }
  else if( trade == TRADE_TYPE_NONE )
  {
      optimal_lot_size = optimal_lot_size( max_loss_percent, buying_position, stop_loss_value);
  }
  else
  {
      optimal_lot_size = 0;
      partial_close_lot = 0;
      tp_2 = -1; 
  }

  result = validate_inputs(temp);
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
     Print(TimeCurrent(),": " ,__FUNCTION__," reason code = ",reason);
//--- "clear" comment
   Comment("Expert Advisor Closed");
//---
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{   
    double tick_size = MarketInfo(NULL,MODE_TICKSIZE);
    static uint try = 0;
    double diff_price = 0;
    static double current_price = 0;

    if( trade == TRADE_TYPE_BUY_LIMIT )
    {
        if ( try == 0 )
        {
            ticket = OrderSend(Symbol(), OP_BUYLIMIT, optimal_lot_size, buying_position, slippage, stop_loss_value, take_profit_value, "Buy Limit",11111,0,clrGreen);
            if(ticket < 0)
            {
               if(show_error_alerts == 1)
               { 
                    Alert("OrderSend for BUY_LIMIT failed with error #",GetLastError());
               }
            }
            else
            {
                try = 1;
                Print("Order placed successfully");
            }
        }
        else if(try == 1)
        {
            current_price = Bid;
/*new_line*/diff_price = MathAbs( Bid - tp_2);
/*new_line*/if( ( diff_price < (tick_size*10) )
               || ( ( current_price > tp_2 ) && ( last_price < tp_2 ) ) ) 
            {
                RefreshRates();
                order_status = OrderClose( ticket, partial_close_lot, Bid, slippage, clrRed );
            }       
            last_price = current_price;

            if(order_status == 0 )
            {        
               if(show_error_alerts == 1)
               { 
                   Alert("OrderClose failed with error #",GetLastError());
               }
            }
            else 
            {
                try = 2;
                Alert("Order partially closed successfully");
                ExpertRemove();
                Print(TimeCurrent(),": ",__FUNCTION__," Expert advisor will be unloaded");
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
               if(show_error_alerts == 1)
               { 
                       Alert("OrderSend for SELL LIMIT failed with error #",GetLastError());
               }
            }
            else
            {
                try = 1;
                Print("Order placed successfully");
            }
        }
        else if(try == 1)
        {
            current_price = Ask;
/*new_line*/diff_price = MathAbs( Ask - tp_2);
/*new_line*/if(  (diff_price < (tick_size*10) )
               || ( ( current_price < tp_2 ) && ( last_price > tp_2 ) ))        
           {
               RefreshRates();
               order_status = OrderClose( ticket, partial_close_lot, Ask, slippage, clrRed );
           } 
            if( order_status == 0 )
            {         
               if( show_error_alerts == 1 )
               { 
                    Alert("OrderClose failed with error #",GetLastError());
               }
            }
            else 
            {
                try = 2;
                Alert("Order partially closed successfully");
                ExpertRemove();
                Print(TimeCurrent(),": ",__FUNCTION__," Expert advisor will be unloaded");
                
            }
        }
    }
    else if ( trade == TRADE_TYPE_BUY)
    {
        if ( try == 0 )
        {
            RefreshRates();
            ticket = OrderSend(Symbol(), OP_BUY, optimal_lot_size, Ask, slippage, stop_loss_value,take_profit_value, "Buy order", 88888, 0, clrBlue);
            Alert("Order Send ticket#: " + ticket);
            if( ticket == -1)
            {
               if(show_error_alerts == 1)
               { 
                   Alert("OrderSend for BUY failed with error #",GetLastError());
               }
            }
              else
            {
                try = 1;
                Print("Order placed successfully");
            }
        }
        else if ( try == 1 )
        {
            current_price = Bid;
/*new_line*/diff_price = MathAbs( Bid - tp_2);
/*new_line*/if( (diff_price < (tick_size*10)) 
               || ( ( current_price > tp_2 ) && ( last_price < tp_2 ) ) )
            { 
               RefreshRates();
               order_status = OrderClose( ticket, partial_close_lot, Bid, slippage, clrRed );
/*new_line*/}
            if( order_status == 0 )
            {
               if(show_error_alerts == 1)
               { 
                  Alert("OrderClose failed with error #",GetLastError());
               }
            }
            else
            {
                try = 2;
                Alert("Order partially closed successfully");
                ExpertRemove();
                Print(TimeCurrent(),": ",__FUNCTION__," Expert advisor will be unloaded");
            }
        }
    }
    else if (trade == TRADE_TYPE_SELL)
    {
        if ( try == 0 )
        {
            ticket = OrderSend(Symbol(), OP_SELL, optimal_lot_size, Bid, slippage, stop_loss_value,take_profit_value, "Sell Order", 99999, 0, clrYellow);            
            if( ticket == -1)
            {
               if(show_error_alerts == 1)
               { 
                   Alert("OrderSend failed with error #",GetLastError());
               }
            }
            else
            {
                try = 1;
                Print("Order placed successfully");
            }
        }
        else if( try == 1)
        {
            current_price = Ask;
/*new_line*/diff_price = MathAbs( Ask - tp_2);
/*new_line*/if( (diff_price < (tick_size*10))
             || ( ( current_price < tp_2 ) && ( last_price > tp_2 ) ) )
            {
               RefreshRates();
               order_status= OrderClose( ticket, partial_close_lot, Ask, slippage, clrRed);
            }
            if( order_status == 0 )
            {
               if( show_error_alerts == 1 )
               { 
                  Alert("OrderClose failed with error #",GetLastError());
               }
            }
            else
            {
                try = 2;
                Alert("Order partially closed successfully");
                ExpertRemove();
                Print(TimeCurrent(),": ",__FUNCTION__," Expert advisor will be unloaded");
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
char validate_inputs(double position)
{   
    char ret = INIT_PARAMETERS_INCORRECT;
    if( trade == TRADE_TYPE_BUY )
    {
        if( (take_profit_value > tp_2)
        && (tp_2 > position) && (position > stop_loss_value)
        && (stop_loss_value > 0) )
        {
            
            ret = INIT_SUCCEEDED;
        }
        else
       {
           Alert("Inputs are incorrect check again!!"); 
           //Alert("Error");
       }
    }
    else if( trade == TRADE_TYPE_BUY_LIMIT ) 
    {
        if( (take_profit_value > tp_2)
        && (tp_2 > buying_position) && (buying_position > stop_loss_value)
        && (stop_loss_value > 0) )
        {
            
            ret = INIT_SUCCEEDED;
        }
       else
       {
           Alert("Inputs are incorrect check again!!"); 
           //Alert("Error");
       }
    }
    else if( trade == TRADE_TYPE_SELL )
    { 
        if( (take_profit_value > 0)
        && (take_profit_value < tp_2) && (tp_2 < position) 
        && (position < stop_loss_value) )
        {
            
            ret = INIT_SUCCEEDED;
        }
       else
       {
           Alert("Inputs are incorrect check again!!"); 
           //Alert("Error");
       }
    }
    else if (trade == TRADE_TYPE_SELL_LIMIT)
    {
        if( (take_profit_value > 0)
        && (take_profit_value < tp_2) && (tp_2 < selling_position) 
        && (selling_position < stop_loss_value) )
        {
            
            ret = INIT_SUCCEEDED;
        }
         else
       {
           Alert("Inputs are incorrect check again!!"); 
           //Alert("Error");
       }
    }

    else
    {
        Alert("TRADE TYPE IS INCORRECT!!"); 
        //Alert("Error");
    }

    return ret;
}