#property link "http://www.eustaad.com"

enum enum_trade_type
{
    TRADE_TYPE_BUY  = 0,
    TRADE_TYPE_SELL = 1   
};

double optimal_lot_size (double max_loss_percent , double entry_price, double stop_loss)      
{
   
    double account_equity = AccountEquity();
    double lot_size = MarketInfo(NULL,MODE_LOTSIZE);   // tells the Contract size of each pair for our broker
    double tick_value = MarketInfo(NULL,MODE_TICKVALUE);
    double tick_size = MarketInfo(NULL,MODE_TICKSIZE);
    double max_loss_in_account_currency = account_equity * max_loss_percent;
    double max_loss_in_quote_currency = max_loss_in_account_currency / tick_value;
    double max_loss_in_ticks = MathAbs( entry_price - stop_loss ) / tick_size;
    double optimal_lot_size = max_loss_in_quote_currency / max_loss_in_ticks;
    
    Alert("Your Account Equity is : ", account_equity);
    Alert("Lot Size = "+ lot_size);
    Alert("Tickvalue: " + tick_value);
    Alert ("TSize: "+ tick_size);
    Alert ("Max loss for this trade in usd = " + max_loss_in_account_currency);
    Alert ("maxlossinquotecurrency = " + max_loss_in_quote_currency); 
    Alert("Max loss in pips: " + max_loss_in_ticks);
    Alert("Optimal lot size = " + optimal_lot_size );
    
    return optimal_lot_size;
 }