//+------------------------------------------------------------------+
//|                                                          EA1.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
input double STOPLOSS =15;
input double TP =15;
input double LOT = 0.1;
input double MaxRSI =70;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

  MqlDateTime date;
int OnInit()
  {
   
    
   // OpenNew(0.01);   
   
 // ObjectCreate(_Symbol,"BuyButton",OBJ_BUTTON,0,0,0);
//--- create timer
  // EventSetTimer(60);
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
string rsi="";

void OnTick()
  {
//---
    TimeToStruct( TimeLocal(),date);
    
    Comment(  RSI());
       double min= MinPrice();
       if(date.hour>3 && date.hour <15 )
       {
        
       
        
         if(PositionsTotal()<5)
         {
              rsi=  RSI();
            if(RSI15()>0)
            {
           // Print("================================================");
           //    Print("   MIn=", min," Price=",   SymbolInfoDouble(_Symbol, SYMBOL_BID));
              if( !CheckExist())
              {
                  Print("====   MIn=", min," Price=",   SymbolInfoDouble(_Symbol, SYMBOL_BID));
                  OpenNew(LOT);
              }
             
                   
               
            }
            
         }
          if(RSI5()<0)
          {
          double pro=  CloseAll();
         if(pro!=0)
            Print("======Rsi=",rsi, " Profit=",pro);
      
          }
             
      }
      
      if(RSI5()==-1)
      {
       // double pro=  CloseAll();
         //  if(pro!=0)
         //   Print("======Rsi=",rsi, " Profit=",pro);
      
      }
      
        if(date.hour==9 && date.min ==0)
        {
      //    double pro=  CloseAll();
      //   if(pro!=0)
        //   Print("======Rsi=",rsi, " Profit=",pro);
        }
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Trade function                                                   |
//+------------------------------------------------------------------+
void OnTrade()
  {
//---
   
  }
//+------------------------------------------------------------------+

string M1String()
{
 double iRSIBuffer[];
      CopyBuffer(iRSI(_Symbol,PERIOD_M15,21,PRICE_CLOSE),0,0,5,iRSIBuffer);
      
      string bardata= "M1_";
       for(int i=0;i<ArraySize(iRSIBuffer)-1;i++)
         {        
            string temp= DoubleToString( iRSIBuffer[i],0);
            bardata=bardata+temp + "_";
         }
         return bardata;
}

double RSI5()
{
      double kq=0;
      double R9[];
      CopyBuffer(iRSI(_Symbol,PERIOD_M5,9,PRICE_CLOSE),0,0,5,R9);
       double R21[];
      CopyBuffer(iRSI(_Symbol,PERIOD_M1,21,PRICE_CLOSE),0,0,5,R21);
          
      if( R9[3] - R9[4] > 5 && R21[4] <30 )
         return -1;
       if(  R9[4] > R21[4] && R9[0] < R21[0] && R9[4]>40 && R9[3] < MaxRSI )
         return 1;
                  
      return kq;
}

double RSI15()
{
      double kq=0;
      double R9[];
        double R21[];
      CopyBuffer(iRSI(_Symbol,PERIOD_M15,9,PRICE_CLOSE),0,0,5,R9);     
      CopyBuffer(iRSI(_Symbol,PERIOD_M15,21,PRICE_CLOSE),0,0,5,R21);
                    
          
      if( R9[1] > R9[2] && R9[2] > R9[3] && (R9[4] - R9[3])>9 )
         return 1;
            CopyBuffer(iRSI(_Symbol,PERIOD_M5,9,PRICE_CLOSE),0,0,5,R9);
     
      CopyBuffer(iRSI(_Symbol,PERIOD_M15,21,PRICE_CLOSE),0,0,5,R21);
          
         
       if(  (   R9[0] - R9[4] >10)  )
         return -1;
                  
      return kq;
}



double RSI30()
{
      double iRSIBuffer[];
      CopyBuffer(iRSI(_Symbol,PERIOD_M30,9,PRICE_CLOSE),0,0,7,iRSIBuffer);
      
      double total=0;
       for(int i=0;i<ArraySize(iRSIBuffer)-1;i++)
         {        
             total += iRSIBuffer[i];
         }
         
      total = total /    ArraySize(iRSIBuffer);
      
      return total;
}



string RSI(){
  
  //MqlRates BarData[1]; 
  // CopyRates(Symbol(), Period(), 0, 1, BarData); // Copy the data of last incomplete BAR

// Copy latest close prijs.
  // double Latest_Close_Price = BarData[0].close;
   
      double iRSIBuffer[];
      CopyBuffer(iRSI(_Symbol,PERIOD_M15,9,PRICE_CLOSE),0,0,5,iRSIBuffer);
      
      string bardata= "M15_";
       for(int i=0;i<ArraySize(iRSIBuffer);i++)
         {        
            string temp= DoubleToString( iRSIBuffer[i],0);
            bardata=bardata+temp + "_";
         }
        bardata=bardata+" M5 " ;
         CopyBuffer(iRSI(_Symbol,PERIOD_M5,21,PRICE_CLOSE),0,0,5,iRSIBuffer);
          for(int i=0;i<ArraySize(iRSIBuffer);i++)
         {        
            string temp= DoubleToString( iRSIBuffer[i],0);
            bardata=bardata+temp + "_";
         }
     //    Print(bardata);
         return bardata;      
  }
  
  
   string OpenNew(double qty=0)
   {   
      
        
     MqlTradeRequest request;
     MqlTradeResult result;
     ZeroMemory(request);
     double current_ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK); 
       request.action = TRADE_ACTION_DEAL;       
            request.symbol = _Symbol;        
            request.volume = qty;
            request.magic =1981;
            request.comment= M1String();
            request.sl = current_ask -STOPLOSS;
            request.tp = current_ask + TP;
            //request.position = ticket;
         //   request.type_filling=ORDER_FILLING_IOC;
           // request.deviation = 3;                       
         request.type=ORDER_TYPE_BUY;              
       OrderSend(request,result);         
      if(result.retcode==TRADE_RETCODE_PLACED ||result.retcode==TRADE_RETCODE_DONE)
      {
         Print("注文が成功しました。 リターンコード= ",result.retcode);
      }
      Print("注文。 リターンコード= ",result.retcode);
      return result.retcode;
   }
   
 
 
 double MinPrice()
{
   double min = 3000;
   for(int i = 0; i < PositionsTotal(); i++)
      {
         ulong ticketNum = PositionGetTicket(i);
         PositionSelectByTicket(ticketNum);  
         double price= PositionGetDouble(POSITION_PRICE_OPEN);
        // Print("Min  i=",i," ",price);
         if(price < min)
            min = price;      
      }
      return min; 
 }
   
 
 
 bool CheckExist()
{
   bool found = false;
  // if(PositionsTotal()<=1) return false;
   string rsi = "";

   for(int i = 0; i < PositionsTotal(); i++)
      {
         ulong ticketNum = PositionGetTicket(i);
         PositionSelectByTicket(ticketNum);         
         
            if( M1String() == PositionGetString(POSITION_COMMENT))
               found = true;     
              
      }
      return found; 
 }
     
   
   
   double CloseAll()
   {
   
   double profit=0;
     for(int i = 0; i < PositionsTotal(); i++)
      {
         ulong ticketNum = PositionGetTicket(i);
         PositionSelectByTicket(ticketNum);  
         
          profit +=  PositionGetDouble(POSITION_PROFIT) ;
          //posSymBol = PositionGetSymbol(i);
        double QTY =  PositionGetDouble(POSITION_VOLUME);
        
         // Print("profit=",profit);
          MqlTradeRequest request;
     MqlTradeResult result;
     ZeroMemory(request);
       request.action = TRADE_ACTION_DEAL;       
            request.symbol = _Symbol;
            request.position=ticketNum;                      
            request.volume = QTY;
          //  request.type_filling=ORDER_FILLING_IOC;
      
          //  if(posType=="Buy"){
               request.type=ORDER_TYPE_SELL;
              
             OrderSend(request,result);
             
           
      }  
   
  // Print("Profit=", profit);
      return profit;
   
   }