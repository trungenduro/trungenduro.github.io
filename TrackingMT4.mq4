//+------------------------------------------------------------------+
//|                                                     Tracking.mq4 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//#include <ReadWriteRequest.mqh>;

//input string Partner="9435661";
input string Partner="9142101";
input bool CopyTrade=true;
input bool CopyClose=false;
//input double MaxLot=0.26;
//input string scaleString="AUDCAD-m AUDCAD.m 0.4*EURUSD-m EURUSD.m 0.3*XAUUSD-m XAUUSD.m 1"; 
input string scaleString="AUDCAD+ AUDCAD 1*EURUSD+ EURUSD 1*XAUUSD+ GOLD 1"; 
input int MaxPos=15;
input int H_from=9;

input int H_to=9;
input double scale =1;
input bool UseHttp=false;
input string ServerName="http://trung1081.somee.com";
input double timer=15;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
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
//+------------------------------------------------------------------+
//|                                                    PosObject.mqh |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property strict
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

class PosObject
{   
   public :
   PosObject(){
   }
     PosObject(string st, string scaleString="")
    {
       string scales[];   
       string symbol1[];
       string symbol2[];
       double scale[];
          if(scaleString!="" && StringFind( scaleString,"OFF") < 0 && StringFind( scaleString,"CL") < 0  )
            {
                StringSplit(scaleString,StringGetCharacter("*",0),scales);
                ArrayResize(symbol1,ArraySize(scales));
                ArrayResize(symbol2,ArraySize(scales));
                ArrayResize(scale,ArraySize(scales));
                //  Print(" ======= ",ArraySize(scales));                
                for(int i = 0; i < ArraySize(scale); i++)
                  {
                      string scales1[];
                    //  Print(scales[i]);
                      int k = StringSplit(scales[i],StringGetCharacter(" ",0),scales1);
                     //   Print("  ****** ",i,"  ",scales[i]," k=",k);
                     if( k >1)
                     {
                         symbol1[i] = scales1[0];
                          symbol2[i] = scales1[1];
                          scale[i] = StringToDouble(scales1[2]);
                          
                           // Print("  ",i,scales[0]," ",scale[2]);
                     }

                  }   
            }        
            
        string result[];               // An array to get strings
   
         ushort  u_sep=StringGetCharacter(",",0);
   
         int k=StringSplit(st,u_sep,result); 
         if (k>3)
         {
            ticket = StringToInteger( result[0]);
            QTY = StringToDouble(result[3]);
            posSymBol = result[1];
            StringReplace(posSymBol,"GOLD","XAUUSD");         
             //StringReplace(posSymBol,"_J","");     
            //  posSymBol=StringSubstr(posSymBol,0,6);
            string findSymbol="";
            //QTY=0;
            for(int i = 0; i < ArraySize(symbol1); i++)
                  {            
                     // Print(i,"symbol1=",symbol1[i],"==",posSymBol,"...");         
                     if( symbol1[i]==posSymBol)
                     {                          
                          findSymbol = symbol2[i] ;
                                               
                         // Print(findSymbol, " scale=",scale[i], " QTY=",QTY);
                          
                           QTY = CalLot( QTY , scale[i]);   
                     }
                  }                   
              //  Print("possymbol=",ticket, "  ",posSymBol,"->",findSymbol," Qty=",QTY);
                posSymBol = findSymbol;
               if(findSymbol=="") QTY=0;     
            posType = result[2];
         }
    
    }
   PosObject(int i){   
         OrderSelect(i, SELECT_BY_POS);          
         ulong ticketNum = OrderTicket();
         TP =  OrderTakeProfit();
         ticket = ticketNum;
         posSymBol = OrderSymbol();
         magicNumber =  OrderMagicNumber();
         StringReplace(posSymBol,"_J","");   
         QTY =   OrderLots();
         comment = OrderComment();
         price = OrderOpenPrice();
         profit = OrderProfit();
         posType = "Sell";
         int type   = OrderType();
          if(type == OP_BUY)
              {
                  posType = "Buy";
              }
             if(type == OP_SELL   )
              {
                  posType = "Sell";
              }    
   }
   double CalLot(double d, double scale)
  {
  
  double kq =0;
   kq = StringToDouble( DoubleToString( d * scale ,3));
   if( kq > 0.01)
   kq = StringToDouble( DoubleToString( d * scale ,2));
         
    return kq;
                           
  }
   string ToString()
   {   
       string text = ticket + ","+posSymBol + "," + posType + "," + DoubleToString(QTY,3) + ","  + DoubleToString(price,5) + ","  + DoubleToString(profit,0);
      return text;
     
   }
   
   bool IsCopyPosition()
   {
      if(comment=="") return false;
      if(StringToDouble(comment)==0) 
         return false;
      
      return true;   
   }
      
   
  bool CheckRSI()
  {
      double sum=0;
      for(int i=0;i<3;i++)
        {
            sum += iRSI(NULL,PERIOD_M30,9,PRICE_CLOSE,i);    
              
        }   
       if(sum < 80) 
         return true  ;
       return false;  
  }   
      
   string OpenNew(double qty=0)
   {   
      double Qty = qty;
      
      if(Qty==0) Qty = QTY;
      
    
        
         
     // double minstoplevel=MarketInfo(Symbol(),MODE_STOPLEVEL);
     // Print(" QTY=",QTY," ");
      double price= MarketInfo(posSymBol,MODE_BID);
   //--- calculated SL and TP prices must be normalized
      int cmd;
     if(posType=="Buy"){
          cmd= OP_BUY ;  
           price= MarketInfo(posSymBol,MODE_ASK);
      }
        if(posType=="Sell"){
         cmd= OP_SELL;   
         price= MarketInfo(posSymBol,MODE_BID);
         
      }    
      
      
      int ticket1=OrderSend(posSymBol,cmd,Qty,price,3,0,0,ticket,1981,0,clrGreen);
      if(ticket1<0)
        {
         Print("OrderSend failed with error #",GetLastError());
         return "Error";
        }
      else{
         Print("OrderSend placed successfully");
         return "OK";
         }
      
      
   }
   int PosCount()
   {
      return OrdersTotal();   
   }
 
   void Close()
     {
        
       
       for(int i = OrdersTotal() - 1; i >= 0; i--)
       {
        if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
           {
            if(OrderSymbol() == posSymBol)
               {
                if(OrderTicket() == ticket)
                   {
                      bool orderClose = OrderClose( OrderTicket(), OrderLots(), OrderClosePrice(), 10, clrNONE);
                   }
               }
           }
       }
         
//          int ticket=OrderSend(Symbol(),cmd,QTY,price,3,0,0,comment,9999,0,clrGreen);
//         bool orderClose = OrderClose( OrderTicket(), ②, ③, ④, ⑤);
      //   bool orderClose = OrderClose( OrderTicket(), OrderLots(), OrderClosePrice(), 10, clrNONE);

     }


   ulong ticket;
   string Type;
   string posSymBol;
   string posType;
   double QTY;
   double TP;
   string comment;
   bool isNew;
   double price;
   double profit;
   int magicNumber;
  
};


class HttpRequest
{
 public :
  string scaleString;
  string MyPartner;
  string MyName;
  double scale;
  bool CopyClose;
  bool CopyTrade;
  int MaxPos;
  int OldPosCount;
  int OldParnerPosCount;
   int H_from;
   int H_to;
   bool UseHttp; 
   string ServerName;

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
   string url= ServerName + "/Comments/" + url1;
   //Print(url);
   ResetLastError();
//--- Downloading a html page from Yahoo Finance
   int res=WebRequest("GET",url,cookie,NULL,500,post,0,result,headers);
  // Print("ServerName=",ServerName," URL=", url, " res=",res);
  
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
          //   Print("URL=", url, " res=",CharArrayToString(result));
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
        if( ArraySize(CurrentPos) < i+ 1) 
            ArrayResize(CurrentPos,i +1 );   
         CurrentPos[i] = o;
       //  Print("===UpdateMyPosition ",i," =>", CurrentPos[i].ticket, " magic=",CurrentPos[i].magicNumber);
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
  
  string SendCurrentPosToWeb()
  {
      if (!UseHttp) return "";
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
      string mt5c= IntegerToString( (int) AccountInfoDouble(ACCOUNT_PROFIT))  + " / " +  DoubleToString(DayProfit(),0) + " / " + mt5b  ;
      string varDate=TimeToString(TimeLocal());
    StringReplace( varDate," ","_");
    
    varDate= varDate+ "_"+ RSI();
    
      data = data + "&content2="+ mt5c + "&content3=" + varDate;   
    //  Print(data);   
       string send= CheckHttp(data); 
     
         StringReplace(send,"AutoMode:","");
         scaleString= send;
       if(StringFind( send,"CL")==0)
      {
            AutoMode = false;
            scale=0;
            for(int i = 0; i < ArraySize(CurrentPos); i++)
            {    
               if(CurrentPos[i].magicNumber==1981 )        
                     CurrentPos[i].Close();                
            }   
      }
      else
      AutoMode = true;
      return send;
  }
  
  string SendCurrentPos()
  {       
       if(!CopyTrade)  WriteCurrentPos(); 
         SendCurrentPosToWeb();
         return "";     
  }
double DayProfit()
  {
 double profit = 0;
int i,hstTotal=OrdersHistoryTotal();
  for(i=0;i<hstTotal;i++)
    {
     if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==TRUE)
       {
         if(OrderType()>1) continue;
         if(TimeToStr(TimeCurrent(),TIME_DATE) == TimeToStr(OrderCloseTime(),TIME_DATE))
         {
            profit += OrderProfit() + OrderSwap() + OrderCommission();
         }
       }
    }
   return(profit);
  }
  
void WriteCurrentPos()
{
 int h=FileOpen( MyName + ".txt",FILE_WRITE|FILE_COMMON|FILE_TXT);
   if(h==INVALID_HANDLE)
   {
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
  
  
string CheckHttpGit( string url="Getdata?title=")
  {
  //https://trung1081.bsite.net/Comments/setdata?title=06&content1=0601
   string cookie=NULL,headers;
   char   post[],result[];
  // string url=  url1;
 //  Print(url);
   ResetLastError();



    // FXCMジャパン証券の経済指標カレンダーのサイトデータを取得
  
   int res=WebRequest("GET",url,cookie,NULL,5000,post,0,result,headers);
   
   //res = WebRequest("GET", api_url + "?" + msg, cookie, referer, timeout, data, data_size, result, result_headers);
  // Print("Res=",res);
   if(res==-1)
     {
     Print("Error in WebRequest. Error code  =",GetLastError());
     return "-1";
      
     }
   else
     {
    // Print("res=",res);
      if(res==200)
        {                  
      //  Print(url,"  resulf=",CharArrayToString(result));
           return CharArrayToString(result);        
        }
      else
         PrintFormat("Downloading '%s' failed, error code %d",url,res);
         
           return "-1";
     }
  }
  
  void AutoModeGit()
  {
  
         AutoMode=true;
        //   Print("AutoModeGit AutoMode=",  AutoMode);
            
    //  AutoMode = false;
      string getMode =  "Getdata?title=" + MyName +"_AutoMode";
      string test="";
      string test1 = CheckHttpGit("https://trungenduro.github.io/AutoMode.txt") ;
      StringReplace( test1,"\r\n","*");   
        ushort  u_sep=StringGetCharacter("*",0);
    string result[]; 
         int k=StringSplit(test1,u_sep,result); 
         
       //  Print(" AutoModeGit 1  AutoMode=",  AutoMode);
      for(int i = 0; i < ArraySize(result); i++)
      {
    //    Print(i, "=",result[i] );
           ushort  u_sep1=StringGetCharacter(" ",0);
         string result1[]; 
         StringReplace( result[i]," "," ");  
         int k1=StringSplit(result[i],u_sep1,result1);
      
          if(k1>1){
      
            if(result1[0]==MyName)
            {
                  test = result1[1];
              //    Print("new mode=", test );            
            }          
          }
       }
         
         
     
      
    //  Print(" update  AutoMode=",  AutoMode);
          
  }
  
  
  void UpdateAutoMode()
  {

   if(MyPartner=="") return;
  
      
 // if (!UseHttp){
    //Print("NOt use automode");
    //   AutoMode = true;
     //  AutoModeGit();
    //  return;
  // }
     bool originAuto =   AutoMode;  
    //  AutoMode = false;
      string getMode =  "Getdata?title=" + MyName +"_AutoMode";
      string test = CheckHttp(getMode) ;
    
       Print(getMode, " test=", test ,"___");
      if(test=="-1" || test==""){
         Print("Blank automode");        
      }
        if(StringFind( test,"N")==0)
      {         
            StringReplace( test,"N","");   
            MyPartner= test;
           Print("Change Partner =",MyPartner);
         return;
      }
      
      if(  test == "ON") 
      {
         AutoMode = true;
         if(originAuto!=AutoMode)
             Print("Change scale new AutoMode=",AutoMode);
         return;
      }
       if(  test == "OFF") 
      {
         AutoMode = false;
           if(originAuto!=AutoMode)
             Print("Change scale new AutoMode=",AutoMode);
         return;
      }
      if(StringFind( test,"C")==0)
      {
            AutoMode = false;
            scale=0;
            for(int i = 0; i < ArraySize(CurrentPos); i++)
            {               
                     CurrentPos[i].Close();                
            }   
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
  
  bool CheckStopCopy()
  {
      bool HavePosOff=false;
       for(int j= 0; j < ArraySize(CurrentPos); j++)
            {            
               if(CurrentPos[j].QTY== 0.05 && (CurrentPos[j].comment=="" || CurrentPos[j].magicNumber!=1981))
               {
                 HavePosOff= true;
               }          
            }  
      return     HavePosOff;  
  }
    
  void CheckClose()
  {  
  
  }
     //==================
     void CopyFromParner()
   {
   
       if(StringFind( scaleString,"CL")==0 || StringFind( scaleString,"CL")==0) 
       {
            return;
       }
      if(AutoMode!=true || CheckStopCopy() ){
      
        // Print( "AutoMode is OFF");
         return;
      }
      if (!CheckTime() && ArraySize(CurrentPos) <4)
      {       
           
         Print( " off time");
         return;      
      }
      
      //find new order 
       for(int i = 0; i < ArraySize(CurrentPos); i++)
      {
         CurrentPos[i].isNew = true;      
      }
    //  Print( "==========================");
      for(int i = 0; i < ArraySize(CurrentParnerPos); i++)
      {
         //  Print( "CurrentParnerPos", i, "=",  CurrentParnerPos[i].ticket, " ",  CurrentParnerPos[i].QTY);
          CurrentParnerPos[i].isNew = true;  
           for(int j= 0; j < ArraySize(CurrentPos); j++)
            {
               if(CurrentPos[j].comment== IntegerToString( CurrentParnerPos[i].ticket))
               {
               //   Print("check comment ",CurrentPos[j].comment, " ok");
                  CurrentParnerPos[i].isNew = false;
                  CurrentPos[j].isNew = false;
               }         
            }       
      }
                
        
         if(!AutoMode) return;      
         for(int i = 0; i < ArraySize(CurrentPos); i++)
         {
              if( CurrentPos[i].isNew && CurrentPos[i].magicNumber==1981)
              {
            //  Print("CurrentPos[i].IsCopyPosition()",CurrentPos[i].IsCopyPosition());
                  Print("Close pos Comment=",CurrentPos[i].comment ," ",CurrentPos[i].ticket, " QTY=",CurrentPos[i].QTY );
                 CurrentPos[i].Close();
                 Print("===CLose Finish");
              }
         }
           for(int i = 0; i < ArraySize(CurrentParnerPos) && i< MaxPos ; i++)
         {
              if( CurrentParnerPos[i].isNew && CurrentParnerPos[i].QTY >=0.01 )
              {
                  double qty =0;      
               //   CurrentParnerPos[i].QTY = CalLot(CurrentParnerPos[i].QTY,scale);                             
                  CurrentParnerPos[i].OpenNew(qty); 
                 Print("Open new pos ",CurrentParnerPos[i].ticket, " QTY=",CurrentParnerPos[i].QTY );
                 
              }
         }
   } 
    
  void UpdateParnerPos()
  {
      if(MyPartner=="")return;
    
     if( !ReadPartnerFromText()) return;
      
    // Print("CurrentParnerPos = ",ArraySize(CurrentParnerPos)); 
     if(OldParnerPosCount!=  ArraySize(CurrentParnerPos))
     {
          if(OldParnerPosCount==0) ReadPartnerFromText();
         Print("Parner pos change from ",OldParnerPosCount, " to ", ArraySize(CurrentParnerPos), " ArraySize(CurrentPos)=",ArraySize(CurrentPos));
         SendCurrentPosToWeb();    
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
  
  
  
  
  
bool ReadPartnerFromText()
{

string table[];
   
   int i=0;
   
   int fileHandle = FileOpen(MyPartner+ ".txt",FILE_SHARE_READ|FILE_ANSI|FILE_COMMON|FILE_TXT);
   if(fileHandle==INVALID_HANDLE)
   {
      Print("Can not Reaｄd");
      return false ;}
   if(fileHandle!=INVALID_HANDLE) 
    {
  //  Print(" Read File OK");
     while(FileIsEnding(fileHandle) == false)
       {    
        ArrayResize(table,ArraySize(table) +1 );     
        table[ArraySize(table)-1] = FileReadString(fileHandle);
    //   Print(i,"  lines number=",table[i] );
       i++;      
      }
     FileClose(fileHandle);          
    }
    
    ArrayResize(CurrentParnerPos,ArraySize(table));
 //    Print("ArraySize(table)",ArraySize(table) );
    
     for(int i=0;i<ArraySize(table);i++)
         {
                PosObject o(table[i],scaleString);
            //   o.QTY = CalLot( o.QTY , scale );               
            //   Print("o.QTY ",o.QTY , " scale=", scale);
               CurrentParnerPos[i]=o;
           //     Print("i=",i," ",CurrentParnerPos[i].posSymBol, " CurrentParnerPos.QTY ",CurrentParnerPos[i].QTY );
               //   Print("CurrentParnerPos",CurrentParnerPos[i].ToString());
         }
    return true;
  // Print("  Parner position number =",ArraySize(CurrentParnerPos) );
  //  return ArraySize(table);
    //Print("file lines number=",ArraySize(table) );
}

  double CalLot(double d, double scale1)
  {
  
   double kq =0;
   kq = StringToDouble( DoubleToString( d * scale1 ,3));
   if( kq > 0.01)
   kq = StringToDouble( DoubleToString( d * scale1 ,2));
         
    return kq;
                           
  }
  
  bool CheckRSI()
  {
      double sum=0;
      for(int i=0;i<3;i++)
        {
            sum += iRSI(NULL,PERIOD_M30,9,PRICE_CLOSE,i);                  
        }   
       if(sum < 80) 
         return true  ;
       return false;  
  }

  string RSI()
  {
      if(MyPartner!="") return "";
      string bardata="RSI15=";
      double point=1;
     if(_Digits<4) point = point;
     
      for(int i=0;i<5;i++)
        {
            string temp= DoubleToString( iRSI(NULL,PERIOD_M30,9,PRICE_CLOSE,5-i),0);
            bardata=bardata+temp +"_";
        }   
        bardata=bardata+"_Price="+DoubleToString(Close[0],1);
       for(int i=0;i<5;i++)
        {
            string temp= DoubleToString( Close[5-i]- Close[6-i] ,point);
            bardata=bardata+temp +"_";
        }   
                       
        return bardata;      
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
  if(!UseHttp) return "";
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
  };  


HttpRequest http;

int OnInit()
  {

   //if(!ExtDialog.Create(0,"Controls",0,40,40,300,150))
     // return(INIT_FAILED);
//--- run application
   //ExtDialog.Run();
   EventSetTimer(timer);
     
   Print("Account=",IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN)));

    Print("http.myname=",http.MyName);
    Print("New EA 2025 1 14");  
   http.scaleString=scaleString;
   
   http.CopyClose = CopyClose;
   http.H_from = H_from;
   http.H_to=H_to;
    http.ServerName = ServerName;

  // string getMode =  "Getdata?title=" + http.MyName +"_AutoMode";
  Print("====ServerName-->",http.ServerName) ;

  //   Print("CheckHttpGit", http.CheckHttpGit("https://trungenduro.github.io/AutoMode.txt")); 

  http.scale = scale;
  http.MaxPos = MaxPos;
  http.MyPartner = Partner;
  http.UpdateMyPosition();
  http.CopyClose = CopyClose;
    http.CopyTrade = CopyTrade;
  
  http.UseHttp = UseHttp;
   http.AutoMode=true;
 if(!UseHttp && scale>0) http.AutoMode=true;
   
  if(CopyTrade || CopyClose) 
     {     
       
        http.UpdateParnerPos();
     }
 
   
       
  if(CopyTrade || CopyClose)
   http.UpdateParnerPos();
     
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
  
  //2024.11.13 20:17:35.477	TrackingMT4 GOLD,M1: Getdata?title=23818463_AutoMode test=-1___

  MqlDateTime date ;
  int PositionNum=0;
  
  void OnTimer()  
  {
   
    Comment( "scaleString-> ", http.scaleString);
     if(UseHttp)
    {
       if( PositionNum>0 ||  ArraySize( http.CurrentPos)>0 || ArraySize( http.CurrentParnerPos)>0   )
       {
            http.SendCurrentPosToWeb();
            PositionNum = ArraySize( http.CurrentPos);
       }               
    }  
   
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
   if(CopyClose || CopyTrade)  http.UpdateParnerPos();
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
