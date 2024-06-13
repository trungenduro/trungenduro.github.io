//+------------------------------------------------------------------+
//|                                                     Tracking.mq4 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#include <ReadWriteRequest.mqh>;
HttpRequest http;
input string Partner="";
input bool CopyTrade=false;
input bool CopyClose=false;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   //if(!ExtDialog.Create(0,"Controls",0,40,40,300,150))
     // return(INIT_FAILED);
//--- run application
   //ExtDialog.Run();
   EventSetTimer(50);
   Print("Account=",IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN)));
;
    Print("New EA 2024 06 13");  
  http.MyPartner = Partner;
  http.UpdateMyPosition();
   http.UpdateAutoMode();
  if(CopyTrade || CopyClose) http.UpdateParnerPos();
  
   http.SendBars();
   
   return(INIT_SUCCEEDED);
  }
  
  
  
  void OnTimer()  
  {
    http.SendBars();
   // Print("Ontimer");
  }
  
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {

   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
     http.UpdateMyPosition();
    if(CopyTrade)
    {
        http.UpdateParnerPos();
        http.UpdateAutoMode();
        http.CopyFromParner();
       // http.UpdateMyPosition();
     }
  
     
  }
//+------------------------------------------------------------------+
//| Trade function                                                   |
//+------------------------------------------------------------------+
void OnTrade()
  {
      http.UpdateMyPosition();
      http.UpdateParnerPos();      
  }
//+------------------------------------------------------------------+
