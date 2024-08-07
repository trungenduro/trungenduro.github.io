//+------------------------------------------------------------------+
//|                                             ReadWriteRequest.mqh |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2010
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import
//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex5"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+
// PosObject (tring) 
#include <PosObject.mqh>
#include <Trade\Trade.mqh>
CTrade c_trade;
class HttpRequest
{
 public :
  string MyPartner;
  string MyName;
  double scale;
  bool CopyClose;
  int OldPosCount;
  int OldParnerPosCount;
   int H_from;
   int H_to;
   double MaxLot;
   bool UseHttp; 

  PosObject CurrentPos[];
  PosObject NewPos[];
  PosObject CurrentParnerPos[];
   bool AutoMode;
  HttpRequest(string mypartner="MT4")
  {
      MyPartner=mypartner;
      MyName=  IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN));
      OldParnerPosCount=-1;
      OldPosCount=-1;
  }
  
string CheckHttp( string url1="Getdata?title=")
  {
  //https://trung1081.bsite.net/Comments/setdata?title=06&content1=0601
   string cookie=NULL,headers;
   char   post[],result[];
   string url= "https://trung1081.bsite.net/Comments/" + url1;
  // Print(url);
   ResetLastError();
//--- Downloading a html page from Yahoo Finance
   int res=WebRequest("GET",url,cookie,NULL,500,post,0,result,headers);
   if(res==-1)
     {
     return "-1";
      Print("Error in WebRequest. Error code  =",GetLastError());
     }
   else
     {
    // Print("res=",res);
      if(res==200)
        {                  
       //  Print(url1,"  resulf=",CharArrayToString(result));
           return CharArrayToString(result);        
        }
      else
         PrintFormat("Downloading '%s' failed, error code %d",url,res);
         
           return "-1";
     }
  }
  
  string UpdateMyPosition()
  {
      PosObject t;
      ArrayResize(CurrentPos, t.PosCount()); 
      for(int i = 0; i < t.PosCount(); i++)
      {
        // ArrayResize(CurrentPos,i +1 );   
         PosObject o(i);             
         CurrentPos[i] = o;
      }  
      if(ArraySize(CurrentPos)!=OldPosCount)
      {
         Print("PositionChange from ",OldPosCount," To ", ArraySize(CurrentPos));
         OldPosCount = ArraySize(CurrentPos);
        return SendCurrentPos();
      }   
      return "";   
  }
  
  //==============
  
  string SendCurrentPos()
  {
        if( UseHttp){
         WriteCurrentPos();
         return "";
      }
      string data="setdata?title="+ MyName + "_Position" + "&content1=";
      for(int i = 0; i < ArraySize(CurrentPos); i++)
      {
         PosObject o = CurrentPos[i];
      //   string text = o.ticket + ","+ o.posSymBol + "," + o.posType + "," + DoubleToString(o.QTY);
         data= data +o.ToString() +";" ;
         CurrentPos[i] = o;        
      }
      if(ArraySize(CurrentPos)==0) data="setdata?title="+ MyName + "_Position&content1=0";   
      string mt5b=  IntegerToString(  (int)AccountInfoDouble(ACCOUNT_BALANCE));
      string mt5c= IntegerToString( (int) AccountInfoDouble(ACCOUNT_PROFIT));
      string varDate=TimeToString(TimeLocal());
    StringReplace( varDate," ","_");
      data = data + "&content2="+ mt5c + "&content3=" + varDate;      
       return CheckHttp(data);   
  }
  
void WriteCurrentPos()
{

 int h=FileOpen( MyName + ".txt",FILE_WRITE|FILE_COMMON|FILE_TXT);
   if(h==INVALID_HANDLE){
      Print("Error opening file");
      return;
   }
     for(int i = 0; i < ArraySize(CurrentPos); i++)
      {       
         FileWrite(h,CurrentPos[i].ToString());        
      }
      
   FileClose(h);
   
   Print("Write file ok");

}
  
  void UpdateAutoMode()
  {
      AutoMode = false;
      string getMode =  "Getdata?title=" + MyName +"_AutoMode";
      string test = CheckHttp(getMode) ;
      // Print( " test=", test ,"___");
      if(test=="-1" || test==""){
         Print("Blank automode");
         string update =  "Setdata?title=" + MyName +"_AutoMode&content1=OFF";
         CheckHttp(update); 
      }
      if(  test == "ON") 
      {
         AutoMode = true;
         return;
      }
       if(  test == "OFF") 
      {
         AutoMode = false;
         return;
      }
      double sc = StringToDouble(test);
       if(  sc==0) 
      {
         AutoMode = false;
         return;
      }
      if (sc>0){
        AutoMode = true;
        if(scale!=sc){
         scale = sc;
           Print("Change scale new scale=",sc);
           }
      }
      
  }   
  
  void CheckClose()
  {  
  
  }
     //==================
     void CopyFromParner()
   {
      if(AutoMode!=true){
      
         Print( "AutoMode is OFF");
         return;
      }
      if (!CheckTime())
      {
         Print( " off time");
         return;
      }
      
      //find new order 
       for(int i = 0; i < ArraySize(CurrentPos); i++)
      {
         CurrentPos[i].isNew = true;
      }
      for(int i = 0; i < ArraySize(CurrentParnerPos); i++)
      {
          CurrentParnerPos[i].isNew = true;  
           for(int j= 0; j < ArraySize(CurrentPos); j++)
            {
               if(CurrentPos[j].comment== IntegerToString( CurrentParnerPos[i].ticket))
               {
                  CurrentParnerPos[i].isNew = false;
                  CurrentPos[j].isNew = false;
               }         
            }       
       }
       
         for(int i = 0; i < ArraySize(CurrentPos); i++)
         {
              if( CurrentPos[i].isNew && CurrentPos[i].comment !="")
              {
                  CurrentPos[i].Close();
               //  Print("Close pos ",CurrentPos[i].comment ," ",CurrentPos[i].ticket, " QTY=",CurrentPos[i].QTY );
              }
         }
           for(int i = 0; i < ArraySize(CurrentParnerPos); i++)
         {
              if( CurrentParnerPos[i].isNew )
              {
                  double qty =0;
                  if (CurrentParnerPos[i].QTY<= MaxLot) {
                     CurrentParnerPos[i].OpenNew(qty);
                  }
                  else
                  {                  
                        string update =  "Setdata?title=" + MyName +"_AutoMode&content1=OFF";
                        CheckHttp(update); 
                        SetTPAllPos();
                        
                  }
                 
                 Print("Open new pos ",CurrentParnerPos[i].posSymBol, " QTY=",CurrentParnerPos[i].QTY );
              }
         }
   } 
   
    void SetTPAllPos()
   {
       for(int i = 0; i < PositionsTotal(); i++)
        {
         ulong ticketNum = PositionGetTicket(i);
         PositionSelectByTicket(ticketNum);            
         if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
           c_trade.PositionModify(ticketNum,0,PositionGetDouble(POSITION_PRICE_OPEN) + 1);
           else
           c_trade.PositionModify(ticketNum,0,PositionGetDouble(POSITION_PRICE_OPEN) - 1);          
            
         }   
   }
  
  
  void UpdateParnerPos()
  {
      if(MyPartner=="")return;
      Print("MyPartner = ",MyPartner); 
      
      if(UseHttp){
             //   Print("MyPartner = ",MyPartner); 
               string data= "Getdata?title="+MyPartner+"_Position";
               string check= CheckHttp(data);
              //Date Print("UpdateParner ",data);
               if(check=="" || check=="-1") return;
               
            
                        
            ushort u_sep;                  // The code of the separator character
            string result[];               // An array to get strings
         
            if (check=="0") 
            {
               ArrayResize(CurrentParnerPos,0);    
            }
            else
            {
               u_sep=StringGetCharacter(";",0); 
               int k=StringSplit(check,u_sep,result);
                if(k<1) return;
              // Print("CurrentParnerPos = ",check); 
               ArrayResize(CurrentParnerPos,k-1);     
                  for(int i=0;i<k-1;i++)
                    {
                        PosObject o(result[i]);
                        o.QTY = StringToDouble( DoubleToString( o.QTY * scale ,3));
                        CurrentParnerPos[i]=o;
                      //  PrintFormat("result[%d]=\"%s\"",i,result[i]);
                        Print(CurrentParnerPos[i].ToString());
                    }
             }
    }
    else{
         ReadPartnerFromText();
    }
    
    // Print("CurrentParnerPos = ",ArraySize(CurrentParnerPos)); 
     if(OldParnerPosCount!=  ArraySize(CurrentParnerPos))
     {
         Print("Parner pos change from ",OldParnerPosCount, " to ", ArraySize(CurrentParnerPos), " ArraySize(CurrentPos)=",ArraySize(CurrentPos));
         
         //close all 
         if (OldParnerPosCount>0 && ArraySize(CurrentParnerPos)==0 && CopyClose && ArraySize(CurrentPos)>0)
         {
               Print("=====Close all ============ ");
            for(int i = 0; i < ArraySize(CurrentPos); i++)
            {               
                     CurrentPos[i].Close();                
            }
         
         }
     }
       OldParnerPosCount = ArraySize(CurrentParnerPos);
  }
  
  
  
void ReadPartnerFromText()
{

string table[];
   
   int i=0;
   
   int fileHandle = FileOpen(MyPartner+ ".txt",FILE_READ|FILE_ANSI|FILE_COMMON|FILE_TXT);
   if(fileHandle==INVALID_HANDLE)
   {
   Print("Can not Reaｄd");
    return ;}
   if(fileHandle!=INVALID_HANDLE) 
    {
    Print(" Read File OK");
     while(FileIsEnding(fileHandle) == false)
       {    
        ArrayResize(table,ArraySize(table) +1 );     
        table[ArraySize(table)-1] = FileReadString(fileHandle);
       Print(i,"  lines number=",table[i] );
       i++;      
      }
     FileClose(fileHandle);          
    }
    
    ArrayResize(CurrentParnerPos,ArraySize(table));
    
    
     for(int i=0;i<ArraySize(table)-1;i++)
         {
                PosObject o(table[i]);
               o.QTY = StringToDouble( DoubleToString( o.QTY * scale ,3));
               
               Print("o.QTY ",o.QTY , " scale=", scale);
               CurrentParnerPos[i]=o;
                 Print("CurrentParnerPos.QTY ",CurrentParnerPos[i].QTY , " scale=", scale);
                  Print("CurrentParnerPos",CurrentParnerPos[i].ToString());
         }
    
   Print("  child position number =",ArraySize(table) );
  //  return ArraySize(table);
    //Print("file lines number=",ArraySize(table) );
}


  
  string GetBar(ENUM_TIMEFRAMES time= PERIOD_H1)
  {
        MqlRates bar[];
    // Print("POint=",_Point);
     double point=1;
     if(_Point<0.01) point = _Point;

    ArraySetAsSeries(bar,true);
    CopyRates(_Symbol,time,0,10,bar);
    
    double  delta[];
    ArrayResize(delta,ArraySize(bar));
    string bardata= "";
       for(int i=0;i<ArraySize(bar)-1;i++)
         {
            delta[i]= round( bar[i].close / point) - round( bar[i+1].close / point);
          //  Print("Bar",i,"=",bar[i].time," close=",round( bar[i].close / point), " ",delta[i] );
            string temp=DoubleToString( delta[i],0);
            bardata=bardata+temp +"_";
         }
         return bardata;
  }
  string SendBars()
  {
    string H1 = GetBar(PERIOD_H1);
    string H4 = GetBar(PERIOD_H4);
    string varDate=TimeToString(TimeLocal());
    StringReplace( varDate," ","_");   
    string data="setdata?title="+ _Symbol + "_H1" + "&content1="+H1 + "_H4="+ H4 + "&content2=" +varDate; 
    Print(data);  
    return CheckHttp(data); 
  }
  
  bool CheckTime()
  {
  //Print( " h1=",H_from," h2=",H_to);
  if (H_from == H_to) return true;
  
    string varDate=TimeToString(TimeLocal());
    StringReplace( varDate," ",":");   
   //  Print("time1=",varDate);
                  // The code of the separator character
      string result[];  
     
      int k=StringSplit(varDate,StringGetCharacter(":",0),result);
      
     //  Print("k=",k, " h1=",H_from," h2=",H_to);
      
     if (k>1) {
          
      int h =  StringToInteger(result[1]);
      
      Print("h=",h, " h1=",H_from," h2=",H_to);
      if(h<=H_to && h>=H_from) {
      Print("ON time");
      return true;
      }
      else{
         return false;
      
      }      
      
     }
     return true;
  }  
}