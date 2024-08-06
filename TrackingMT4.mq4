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
input string Partner="5066556";
input bool CopyTrade=false;
input bool CopyClose=false;
input double MaxLot=0.26;

input int H_from=9;
input int H_to=9;
input double scale =1;
input bool UseHttp=false;
input string ServerName="https://trung1081.azurewebsites.net";
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {

   //if(!ExtDialog.Create(0,"Controls",0,40,40,300,150))
     // return(INIT_FAILED);
//--- run application
   //ExtDialog.Run();
   EventSetTimer(15);
   Print("Account=",IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN)));

Print("http.myname=",http.MyName);
    Print("New EA 2024 06 13");  
      
     
   http.CopyClose = CopyClose;
   http.H_from = H_from;
   http.H_to=H_to;
   http.MaxLot = MaxLot;
   http.ServerName = ServerName;

  http.scale = scale;
    
  http.MyPartner = Partner;
  http.UpdateMyPosition();
  http.CopyClose = CopyClose;
  http.UseHttp = UseHttp;
  if(UseHttp){
   http.UpdateAutoMode();
   }
   else
      http.AutoMode=true;
   
  //if(CopyTrade || CopyClose)
   http.UpdateParnerPos();
  
   //http.SendBars();
   
   return(INIT_SUCCEEDED);
  }
  
  void TestWrite()
  {
   string common_data_path=TerminalInfoString(TERMINAL_COMMONDATA_PATH);
   Print(common_data_path);
int FileHandle = FileOpen("file.txt",FILE_WRITE|FILE_CSV|FILE_COMMON);
FileWrite(FileHandle,TimeCurrent());
FileClose(FileHandle); 
  
  }
  
  void OnTimer()  
  {
  //    Print("SendPos");
    http.UpdateAutoMode();
    http.SendCurrentPosToWeb();
   // http.CheckTime();
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
  //  if(CopyTrade || CopyClose)
     http.UpdateParnerPos();
    if(CopyTrade )
    {      
        
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
