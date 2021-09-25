#property link "http://www.eustaad.com"

enum enum_trade_type
{
    TRADE_TYPE_NONE      = 0,  
    TRADE_TYPE_BUY,
    TRADE_TYPE_SELL,      
    TRADE_TYPE_BUY_LIMIT, 
    TRADE_TYPE_SELL_LIMIT,   
};

double optimal_lot_size (double max_loss_percent , double entry_price, double stop_loss)      
{
    double account_balance = AccountBalance();
    double lot_size = MarketInfo(NULL,MODE_LOTSIZE);   // tells the Contract size of each pair for our broker
    double tick_value = MarketInfo(NULL,MODE_TICKVALUE);
    double tick_size = MarketInfo(NULL,MODE_TICKSIZE);
    double max_loss_in_account_currency = account_balance * max_loss_percent;
    double max_loss_in_quote_currency = max_loss_in_account_currency / tick_value;
    double max_loss_in_ticks = MathAbs( entry_price - stop_loss ) / tick_size;
    double optimal_lot = max_loss_in_quote_currency / max_loss_in_ticks;
    
    Alert("Your Account Balance is : ", (string)account_balance);
   // Alert("Lot Size = "+ (string)lot_size);
  //  Alert("Tickvalue: " + (string)tick_value);
   // Alert ("TSize: "+ (string)tick_size);
    Alert ("Max loss for this trade in usd = " + (string)max_loss_in_account_currency);
   // Alert ("maxlossinquotecurrency = " + (string)max_loss_in_quote_currency); 
    Alert("Max loss in pippets/ ticks: " + (string)max_loss_in_ticks);
    Alert("Optimal lot size = " + (string)optimal_lot );
    
    return optimal_lot;
 }