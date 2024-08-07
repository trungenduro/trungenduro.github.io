//+------------------------------------------------------------------+
//|                                           NewTestTrackingPos.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
input string Partner="160050087";
input bool CopyTrade=false;
input bool CopyClose=false;
input double MaxLot=0.26;
input int H_from=9;
input int H_to=9;
input double scale =1;
input bool UseHttp=true;
input bool SendRSI= false;
input string ServerName="http://localhost.net:5000";

#include <ReadWriteRequest.mqh>;
//#include <checkbox.mqh>;

//CControlsDialog ExtDialog;
HttpRequest http;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {

Print("new version 2024 07 31" );
       
 //Print("a=",StringToDouble( "ON")); 

//Print(IntegerToString( (int) AccountInfoDouble(ACCOUNT_PROFIT))  + " / " +  DoubleToString(DayProfit(),0) );

http.CopyClose = CopyClose;
   http.H_from = H_from;
   http.H_to=H_to;
   http.MaxLot = MaxLot;
   http.scale = scale;
   http.UseHttp = UseHttp;
   http.ServerName = ServerName;
  
  http.MyPartner = Partner;
   EventSetTimer(10);
   Print("Account=",IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN)));
      
   
  http.UpdateMyPosition();

      
   
  if(CopyTrade || CopyClose) 
     {     
        http.UpdateAutoMode();
        http.UpdateParnerPos();
     }
   //http.SendBars();

   
   return(INIT_SUCCEEDED);
  }  
  

  void OnTimer()  
  {
    http.SendCurrentPosToWeb();  
     http.UpdateAutoMode(); 
    if(SendRSI) http.SendRSI();
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
    //  Print(RSI());
  //  Print("OnTick");
     http.UpdateMyPosition();
     http.UpdateParnerPos();
    if(CopyTrade )
    {      
   // Print("Copy trade");
       
        http.CopyFromParner();
     }  
     
  }
//+------------------------------------------------------------------+
//| Trade function                                                   |
//+------------------------------------------------------------------+
void OnTrade()
  {
     // Print("Ontrade");
      http.UpdateMyPosition();
      http.UpdateParnerPos();      
  }
//+------------------------------------------------------------------+
