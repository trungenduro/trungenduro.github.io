//+------------------------------------------------------------------+
//|                                                       Profit.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   FindProfit();
  }
//+------------------------------------------------------------------+


void FindProfit()
  {
   double dayprof = 0.0;
   datetime end = TimeCurrent();
   string sdate = TimeToString (TimeCurrent(), TIME_DATE);
   
   Print(sdate);
 //  datetime start = StringToTime(sdate);

   datetime start = end - PeriodSeconds( PERIOD_D1 );
   for(int i=0;i<30;i++)
     {
           HistorySelect(start,end);
       //  if(HistoryDealsTotal()==0) continue;
       //  Print("===================");
       //  Print(TimeToString (end, TIME_DATE));
        
           DayProfit();
           start = start - PeriodSeconds( PERIOD_D1 );
           end = end - PeriodSeconds( PERIOD_D1 );
     }
  
   
  
  }
  
  
double DayProfit()
  {
   double dayprof = 0.0;
     string symbols[];
   ListObject list;
   
   for(int i = 0; i < HistoryDealsTotal(); i++)
     {
      ulong Ticket = HistoryDealGetTicket(i);
      PositionSelectByTicket(Ticket);
     // PositionGetString()
         
          datetime time  =(datetime)HistoryDealGetInteger(Ticket,DEAL_TIME);

      if(HistoryDealGetInteger(Ticket,DEAL_ENTRY) == DEAL_ENTRY_OUT)
        {
         double LatestProfit = HistoryDealGetDouble(Ticket, DEAL_PROFIT) - HistoryDealGetDouble(Ticket,DEAL_FEE) - HistoryDealGetDouble(Ticket,DEAL_SWAP);
        
         string symbol = HistoryDealGetString(Ticket,DEAL_SYMBOL);    
         list.AddProfit(symbol,Ticket, LatestProfit);            
         //Print("day",time," symbol", symbol,"=",LatestProfit);
         dayprof += LatestProfit;
        }
     }
     
  // Print("DAY PROFIT: ", dayprof);
  list.PrintProfit();
   
   return dayprof;
  }
  
  class ListObject
  {
  
   public :
   string symbols[];
   double Profits[];
   ulong Tickets[];
   string day;
   void AddSymbol(string symbol)
   {
       bool isnew=true;
            for(int i=0;i<ArraySize(symbols);i++)
              {
                  if(symbol==symbols[i]){
                     isnew=false;
                     break;
                  }
              }
              if(isnew){
              
              ArrayResize(symbols,ArraySize(symbols) +1);
              ArrayResize(Profits,ArraySize(Profits) +1);
              ArrayResize(Tickets,ArraySize(Profits) +1);
              symbols[ArraySize(symbols)-1] = symbol;
              Profits[ArraySize(symbols)-1] = 0;
             
              Print("New Symbol=",symbol);
              }
   }
   
   
    void AddProfit(string symbol,ulong ticket, double profit)
    {
         bool isnew=true;
         datetime time  =(datetime)HistoryDealGetInteger(ticket,DEAL_TIME);
         day = (TimeToString (time, TIME_DATE));
          for(int i=0;i<ArraySize(symbols);i++)
              {
                  if(symbol==symbols[i]){
                    Profits[i] += profit;
                    isnew=false;
                     break;
                  }
              }
           if(isnew){
              
              ArrayResize(symbols,ArraySize(symbols) +1);
              ArrayResize(Profits,ArraySize(Profits) +1);
             
              symbols[ArraySize(symbols)-1] =  symbol;
              Profits[ArraySize(symbols)-1] = profit;
             
             
              }    
        }
    
    void CheckHttp( string url1)
  {
  //https://trung1081.bsite.net/Comments/setdata?title=06&content1=0601
   string cookie=NULL,headers;
   char   post[],result[];
   string url= "http://trung1081.somee.com/Comments/" + url1;

   int res=WebRequest("GET",url,cookie,NULL,500,post,0,result,headers);
 
  }
    
    
    void PrintProfit()
    {
      if(ArraySize(symbols)==0) return;
      string account= IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN));
      Print("================");
      Print(day);
      string text="";
       for(int i=0;i<ArraySize(symbols);i++)
              {
                Print("     ",day,",",account,",",StringSubstr(symbols[i],0,6),",",Profits[i]);
                text = text + StringSubstr(symbols[i],0,6) + ","  + DoubleToString(Profits[i],0) + "@";
              }
              
        string update =  "Setdata?title=Profit_" + account +"_" + day+ "&content1=" + text;    
        CheckHttp(update);   
    }
    
    
  
 }