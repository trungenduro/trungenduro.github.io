//+------------------------------------------------------------------+
//|                                           NewTestTrackingPos.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
input string Partner="9142101";
//"9142101";//
input bool CopyTrade=true;
input bool CopyClose=false;
input string scaleString="AUDCAD-m AUDCAD 0.4*EURUSD-m EURUSD 0.3*XAUUSD-m XAUUSD 1"; 
input double scale =1;
input bool UseHttp=false;
input bool SendRSI= false;
input string ServerName="http://trung1081.somee.com";
input double timer=25;
input bool AutoStop=false;
input double MaxLot=0.2;

//+------------------------------------------------------------------+
//|                      ;':"{}][\'?/=-=_+++                              PosObject.mqh |
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
       double scaleX[];
    //   Print("   sclae string  ",scaleString);
        if(scaleString!="" && StringFind( scaleString,"OFF") < 0 && StringFind( scaleString,"CL") != 0  )
            {
      //       Print("   split   ",scaleString);
                StringSplit(scaleString,StringGetCharacter("*",0),scales);
                ArrayResize(symbol1,ArraySize(scales));
                ArrayResize(symbol2,ArraySize(scales));
                ArrayResize(scaleX,ArraySize(scales));
                ArrayResize(scale,ArraySize(scales));
           //       Print(" ======= ",ArraySize(scales));                
                for(int i = 0; i < ArraySize(scale); i++)
                  {
                      string scales1[];
                  //    Print(scales[i]);
                      int k = StringSplit(scales[i],StringGetCharacter(" ",0),scales1);
                  //    Print("  ****** ",i,"  ",scales[i]," k=",k);
                     scaleX[i] =1;
                     if( k >2)
                     {
                         symbol1[i] = scales1[0];
                          symbol2[i] = scales1[1];
                          scale[i] = StringToDouble(scales1[2]);
                          
                           // Print("  ",i,scales[0]," ",scale[2]);
                     }
                     if(k>3)
                     {
                        scaleX[i] = StringToDouble(scales1[3]);
                     }
                     
                     // Print("  ",i,scales[0]," ",scale[2]);

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
                      //    Print(findSymbol, " scale=",scale[i], " QTY=",QTY);                          
                           QTY = CalLot( QTY , scale[i]);   
                         if(QTY>=0.01)
                           QTY = CalLot( QTY , scaleX[i]);
                         else 
                         QTY=0;
                     }
                  }                   
             //   Print("possymbol=",ticket, "  ",posSymBol,"->",findSymbol," Qty=",QTY);
                posSymBol = findSymbol;
               if(findSymbol=="") QTY=0;     
            posType = result[2];
            if(k>5)
              comment=result[5];
              
         }
    
    }

   PosObject(int i){   
      if (i < PositionsTotal())
      {      
         ulong ticketNum = PositionGetTicket(i);
         PositionSelectByTicket(ticketNum);  
         ticket = ticketNum;
         posSymBol = PositionGetSymbol(i);
         QTY =  PositionGetDouble(POSITION_VOLUME);
         posType = "Sell";
         comment    = PositionGetString(POSITION_COMMENT);
         magicNumber = PositionGetInteger(POSITION_MAGIC);
         isNew=false;
          if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
              {
                  posType = "Buy";
              }
         price=PositionGetDouble(POSITION_PRICE_OPEN);  
         profit = PositionGetDouble(POSITION_PROFIT);   
      }
   }
   
   int PosCount(){   
      return PositionsTotal();
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
   
   bool CheckIfExisting()
   {     
      for(int i = 0; i < PositionsTotal(); i++)
      {
          ulong ticketNum = PositionGetTicket(i);
           PositionSelectByTicket(ticketNum); 
         //  Print("== check exist i=",i, " ",PositionGetString(POSITION_COMMENT), " ==", comment );
         if(  comment == PositionGetString(POSITION_COMMENT))
            return true;
      }  
      return false;   
   }
   
      
   string OpenNew(double qty=0)
   {   
      double Qty = qty;
      
      if(qty==0) Qty = QTY;
      
      if(CheckIfExisting())
         {
            Print("   Existing");
            return "";
         }
  
     MqlTradeRequest request;
     MqlTradeResult result;
     ZeroMemory(request);
       request.action = TRADE_ACTION_DEAL;       
            request.symbol = posSymBol;
            request.comment=ticket;
            request.volume = Qty;
            request.magic =1981;
            //request.position = ticket;
            request.type_filling=ORDER_FILLING_IOC;
           // request.deviation = 3;            
         Print("===== New  Order ddd=", ticket, " Symbol=", posSymBol, "_",posType, " Qty", QTY);
     // if(TP>0)
       //        request.tp = TP;
      if(posType=="Buy"){
         request.type=ORDER_TYPE_BUY;        
      }
        if(posType=="Sell"){
        request.type=ORDER_TYPE_SELL; 
      } 
       OrderSend(request,result);
         
      if(result.retcode==TRADE_RETCODE_PLACED ||result.retcode==TRADE_RETCODE_DONE)
      {
         Print("注文が成功しました。 リターンコード= ",result.retcode);
      }
      Print("注文。 リターンコード= ",result.retcode);
      return result.retcode;
   }
  
   void Close()
     {
     string sym=_Symbol;
     
    StringReplace( sym,"GOLD","XAUUSD"); 
      
    string _possym = posSymBol;  
    
      StringReplace( _possym,"GOLD","XAUUSD"); 
    StringReplace( _possym,"m",""); 
   _possym=StringSubstr(_possym,0,6);
   
                MqlTradeRequest request;
     MqlTradeResult result;
     ZeroMemory(request);
       request.action = TRADE_ACTION_DEAL;       
            request.symbol = posSymBol;
            request.position=ticket;
          
            
            request.volume = QTY;
            request.type_filling=ORDER_FILLING_IOC;
         //   request.deviation = 3;
            
       //   Print("===== New Child Order =", ticket, " Symbol", posSymBol, " ",posType, " Qty", QTY);
    
            if(posType=="Buy"){
               request.type=ORDER_TYPE_SELL;
              
            }
              if(posType=="Sell"){
              request.type=ORDER_TYPE_BUY; 
            } 
             OrderSend(request,result);
               
            if(result.retcode==TRADE_RETCODE_PLACED ||result.retcode==TRADE_RETCODE_DONE)
            {
               Print("注文が成功しました。 リターンコード= ",result.retcode);
            }
     
     
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
   int magicNumber;
   double profit;
   
  
};



class HttpRequest
{
 public :
   string scaleString;
  string MyPartner;
  string MyName;
  double scale;
  bool CopyClose;
  bool AutoStop;
  bool CopyTrade;
  int OldPosCount;
  int OldParnerPosCount;
   int H_from;
   int H_to;
   double MaxLot;
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
  
  
string CheckHttpGit( string url="Getdata?title=")
  {
  //https://trung1081.bsite.net/Comments/setdata?title=06&content1=0601
   string cookie=NULL,headers;
   char   post[],result[];
  // string url=  url1;
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
  
           return CharArrayToString(result);        
        }
      else
         PrintFormat("Downloading '%s' failed, error code %d",url,res);
         
           return "-1";
     }
  }
  
string CheckHttp( string url1="Getdata?title=")
  {
  //https://trung1081.bsite.net/Comments/setdata?title=06&content1=0601
   string cookie=NULL,headers;
   char   post[],result[];
   string url= ServerName+ "/Comments/" + url1;
  // Print(url);
   ResetLastError();
//--- Downloading a html page from Yahoo Finance
   int res=WebRequest("GET",url,cookie,NULL,500,post,0,result,headers);
  // Print("res=", url);
   
   if(res==-1)
     {
     return "-1";
      Print("Error in WebRequest. Error code  =",GetLastError());
     }
   else
     {
   //  Print("res=",res);
      if(res==200)
        {                  
   //  Print("res=", CharArrayToString(result));
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
     //Print("check position ",t.PosCount());
      ArrayResize(CurrentPos, t.PosCount()); 
      for(int i = 0; i < t.PosCount(); i++)
      {
      //   ArrayResize(CurrentPos,i +1 );   
         PosObject o(i);    
        if( ArraySize(CurrentPos) < i+ 1) 
           ArrayResize(CurrentPos,i +1 );   
         CurrentPos[i] = o;
      }  
      
      for(int i = 0; i < t.PosCount()-1; i++)
      {
         for(int j = 1; j < t.PosCount(); j++)
         {
      //   if(i>=ArraySize( CurrentPos) && j>=ArraySize( CurrentPos)   ) continue;
        //    if(i==j ) continue;
        //   if( CurrentPos[i].comment =="" ) continue;
          // if( CurrentPos[i].comment == CurrentPos[j].comment)
           {
             //  Print("====== Double Order check i=", i," j=",j," ");
             //  CurrentPos[i].Close();
           }       
         }
      }  
       //  Print("OldPosCount ",OldPosCount," CurrentPos", ArraySize(CurrentPos));
        
      if(ArraySize(CurrentPos)!=OldPosCount)
      {
         Print("PositionChange from ",OldPosCount," To ", ArraySize(CurrentPos));
         OldPosCount = ArraySize(CurrentPos);
        return SendCurrentPos();
      }   
      return "";   
  }
  
  //==============
  
  string AVERAGE_XAU()
{

   double total = 0;
   double sumlot = 0;
   double qty = 0;
   if(PositionsTotal()==0)
    return "";
    for(int i = 0; i < PositionsTotal(); i++)
      {
         ulong ticketNum = PositionGetTicket(i);
         PositionSelectByTicket(ticketNum);  
         string symbol =  PositionGetString(POSITION_SYMBOL);
         if(StringFind( symbol,"XAU")==-1 ) continue;
         
         double price =  PositionGetDouble(POSITION_PRICE_OPEN) ;
         double QTY =  PositionGetDouble(POSITION_VOLUME);
         double sign = -1;
        
          if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
          {              
                 sign = 1;
               
         }
           total += sign* price * QTY;  
           qty += sign*  QTY;    
      }  
      if(total==0 || qty ==0)
            return "";  
    // string text = ticket + ","+posSymBol + "," + posType + "," + DoubleToString(QTY,3) + ","  + DoubleToString(price,5) + ","  + DoubleToString(profit,0);
         string PosType="SELL";
         if(qty>0) PosType="BUY";
     return "Total=" + DoubleToString(qty,2)+",XAUUSD,"+ PosType + ","+ DoubleToString(qty,3)+","+ DoubleToString( total / qty,1)+",0";    
}
  
  string SendCurrentPosToWeb()
  {
  if(!UseHttp) return "";
  //Print("Send pos HTTP");
        string data="setdata?title="+ MyName + "_Position" + "&content1=";
      for(int i = 0; i < ArraySize(CurrentPos); i++)
      {
        // PosObject o = CurrentPos[i];
      //   string text = o.ticket + ","+ o.posSymBol + "," + o.posType + "," + DoubleToString(o.QTY);
       //  data= data +o.ToString() +";" ;
       //  CurrentPos[i] = o;        
      }
      data= data + AVERAGE_XAU();
      if(ArraySize(CurrentPos)==0) data="setdata?title="+ MyName + "_Position&content1=0";   
      
      string mt5b= IntegerToString(  (int)AccountInfoDouble(ACCOUNT_BALANCE));
      string mt5c= IntegerToString( (int) AccountInfoDouble(ACCOUNT_PROFIT))  + " / " +  DoubleToString(DayProfit(),0) + " / " + mt5b;
      string varDate=TimeToString(TimeLocal());
    StringReplace( varDate," ","_");
    varDate= varDate+ "_"+ RSI();
      data = data + "&content2="+ mt5c + "&content3=" + varDate;    
      
      
       string send= CheckHttp(data); 
      // Print("Send data to web ",send);
         StringReplace(send,"AutoMode:",""); 
         
        if(send=="-1")
          Print(" Web error",send);
        else  
            scaleString=send;
    
       if(StringFind( send,"CL")==0)
      {
            AutoMode = false;
            scale=0;
            for(int i = 0; i < ArraySize(CurrentPos); i++)
            {               
                  if(CurrentPos[i].magicNumber==1981 )      CurrentPos[i].Close();                
            }   
      }
      return send;
        
      // return CheckHttp(data); 
   
  }
  
  string SendCurrentPos()
  {       
      if(!CopyTrade)  WriteCurrentPos(); 
         SendCurrentPosToWeb();
         return "";     
  }
double DayProfit()
  {
   double dayprof = 0.0;
   datetime end = TimeCurrent();
   string sdate = TimeToString (TimeCurrent(), TIME_DATE);
   datetime start = StringToTime(sdate);

   HistorySelect(start,end);
   int TotalDeals = HistoryDealsTotal();

   for(int i = 0; i < TotalDeals; i++)
     {
      ulong Ticket = HistoryDealGetTicket(i);

      if(HistoryDealGetInteger(Ticket,DEAL_ENTRY) == DEAL_ENTRY_OUT)
        {
         double LatestProfit = HistoryDealGetDouble(Ticket, DEAL_PROFIT) - HistoryDealGetDouble(Ticket,DEAL_FEE) ;
         dayprof += LatestProfit;
        }
     }
   return dayprof;
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


  bool CheckStopCopy()
  {
      bool HavePosOff=false;
       for(int j= 0; j < ArraySize(CurrentPos); j++)
            {            
               if(CurrentPos[j].QTY== 0.05 && CurrentPos[j].comment =="")
               {
                  HavePosOff= true;
               }          
            }  
      return     HavePosOff;  
  }
  
  void AutoModeGit()
  {
  
  bool HavePosOn = false;
    bool HavePosOff = false;
         for(int j= 0; j < ArraySize(CurrentPos); j++)
            {
               if(CurrentPos[j].QTY== 0.07 && CurrentPos[j].comment=="")
               {
                 HavePosOn= true;
               }   
               if(CurrentPos[j].QTY== 0.05 && CurrentPos[j].comment=="")
               {
                 HavePosOff= true;
               }          
            }     
    if(HavePosOn)
    {
         AutoMode=true;
         return;
    }   
    if(HavePosOff)
    {
         AutoMode=false;
         return;
    }                   
            
      AutoMode = false;
      string getMode =  "Getdata?title=" + MyName +"_AutoMode";
      string test="";
      string test1 = CheckHttpGit("https://trungenduro.github.io/AutoMode.txt") ;
      StringReplace( test1,"\r\n","*");   
  // Print( "   test=", test1 ,"___");
        ushort  u_sep=StringGetCharacter("*",0);
    string result[]; 
         int k=StringSplit(test1,u_sep,result); 
      for(int i = 0; i < ArraySize(result); i++)
      {
       // Print(i, "=",result[i] );
           ushort  u_sep1=StringGetCharacter(" ",0);
         string result1[]; 
         StringReplace( result[i]," "," ");  
         int k1=StringSplit(result[i],u_sep1,result1);          
          if(k1>1){
         // Print("  =",result1[0] );
            if(result1[0]==MyName)
            {
                  test = result1[1];
                  Print("new mode=", test );            
            }          
          }
       }
         
         
      if(test=="-1" || test==""){
         
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
     
  }
  
  
     //==================
   void CopyFromParner()
   {     
        //  Print("Copy ",scaleString);  
       if(StringFind( scaleString,"CL")==0 || StringFind( scaleString,"OFF")>=0) 
       {
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
               if(CurrentPos[j].comment == IntegerToString( CurrentParnerPos[i].ticket))
               {
                  CurrentParnerPos[i].isNew = false;
                  CurrentPos[j].isNew = false;
                //    Print(" i=",i,"/",ArraySize(CurrentParnerPos)," Old POS ",CurrentParnerPos[i].posSymBol, " QTY=",CurrentParnerPos[i].QTY );
             
               }         
           }       
       }
       
         for(int i = 0; i < ArraySize(CurrentPos); i++)
         {
              if( CurrentPos[i].isNew && CurrentPos[i].magicNumber==1981)
              {    
                 // if(CurrentParnerPos[i].QTY>0.01)         
                     CurrentPos[i].Close();       
                            
              }
         }
           for(int i = 0; i < ArraySize(CurrentParnerPos); i++)
         {
          
          if( CurrentParnerPos[i].isNew)
       //   Print(" i=",i,"/",ArraySize(CurrentParnerPos)," New Pos",CurrentParnerPos[i].posSymBol, " QTY=",CurrentParnerPos[i].QTY );
                  
              if( CurrentParnerPos[i].isNew &&  CurrentParnerPos[i].QTY >=0.01  )
              {
                  double qty =0;
                  CurrentParnerPos[i].QTY = MathMin(MaxLot, CalLot(CurrentParnerPos[i].QTY,scale));
                    
               // Print("Open new pos ",CurrentParnerPos[i].posSymBol, " QTY=",CurrentParnerPos[i].QTY );
               if( CurrentParnerPos[i].QTY >=0.01)
               {
               
               //   if( !AutoStop || (M1>-4 &&  CurrentParnerPos[i].Type=="Buy") || (M1<4 &&  CurrentParnerPos[i].Type=="Sell")){
                  Print(" i=",i,"/",ArraySize(CurrentParnerPos)," New Pos",CurrentParnerPos[i].posSymBol, " QTY=",CurrentParnerPos[i].QTY ," comment=",CurrentParnerPos[i].comment);
                   CurrentParnerPos[i].OpenNew(qty);
                   CurrentParnerPos[i].isNew = false;                   
                 //  }
               }
                 
              }
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
  
  void UpdateParnerPos()
  {
      if(MyPartner=="")return;
    
    if(!ReadPartnerFromText()) return;
      
   //  Print("CurrentParnerPos = ",ArraySize(CurrentParnerPos)); 
     // Print("OldParnerPosCount = ",OldParnerPosCount); 
     if(OldParnerPosCount!=  ArraySize(CurrentParnerPos))
     {
         SendCurrentPosToWeb();
         if(OldParnerPosCount==0) ReadPartnerFromText();
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
  
  
  
bool ReadPartnerFromText()
{

string table[];
   
   int i=0;
   
   int fileHandle = FileOpen(MyPartner+ ".txt",FILE_SHARE_READ|FILE_ANSI|FILE_COMMON|FILE_TXT);
   if(fileHandle==INVALID_HANDLE)
   {
      Print("Can not Read");
       return false;}
   if(fileHandle!=INVALID_HANDLE) 
    {
   // Print(" Read File OK");
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
   //  Print("ArraySize(table)",ArraySize(table) );
    
     for(int i=0;i<ArraySize(table);i++)
         {
                PosObject o(table[i],scaleString);
             //  o.QTY = CalLot(  o.QTY , scale );
               CurrentParnerPos[i]=o;
               // Print("i=",i," posSymBol->",CurrentParnerPos[i].posSymBol, "===CurrentParnerPos.QTY ",CurrentParnerPos[i].QTY );
               //   Print("CurrentParnerPos",CurrentParnerPos[i].ToString());
         }
         
         return true;
  //Print("  Parner position number =",ArraySize(CurrentParnerPos) );
  //  return ArraySize(table);
    //Print("file lines number=",ArraySize(table) );
}

double M1;
  string GetBarM1(ENUM_TIMEFRAMES time= PERIOD_M1)
  {
        MqlRates bar[];
       double point=1;
     if(_Point<0.01) point = _Point;

    ArraySetAsSeries(bar,true);
    CopyRates(_Symbol,time,0,2,bar);    
    double  delta[];
    ArrayResize(delta,ArraySize(bar));
    string bardata= "";
    M1 =0;
       for(int i=0;i<ArraySize(bar)-1;i++)
         {
            delta[i]= round( bar[i].close / point) - round( bar[i+1].close / point);     
            string temp=DoubleToString( delta[i],0);
            bardata=bardata+temp +"_";
            M1+= delta[i];
         }  
               if(M1>4 || M1<-4) {
                  bardata= bardata + "_******DANGER_******";
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
    string H1 = GetBar(PERIOD_H1);
    string H4 = GetBar(PERIOD_H4);
    string varDate=TimeToString(TimeLocal());
    StringReplace( varDate," ","_");   
    string data="setdata?title="+ _Symbol + "_H1" + "&content1="+H1 + "_H4="+ H4 + "&content2=" +varDate; 
  //  Print(data);  
    return CheckHttp(data); 
  }
  
  
  
  string SendRSI()
  { 
    string H1 = GetBar(PERIOD_H1);
    string H4 = GetBar(PERIOD_H4);
    string varDate=TimeToString(TimeLocal());
    StringReplace( varDate," ","_");   
    string data="setdata?title="+ _Symbol + "_RSI" + "&content1="+RSI() +"_H1=_"+H1 +"__H4="+H4+  "&content2=" +varDate; 
  //  Print(data);  
    return CheckHttp(data); 
  }
  
  string RSI(){
  
  MqlRates BarData[1]; 
   CopyRates(Symbol(), Period(), 0, 1, BarData); // Copy the data of last incomplete BAR

// Copy latest close prijs.
   double Latest_Close_Price = BarData[0].close;
   
      double iRSIBuffer[];
      CopyBuffer(iRSI(_Symbol,PERIOD_M15,9,PRICE_CLOSE),0,0,7,iRSIBuffer);
      
      string bardata= DoubleToString( Latest_Close_Price,1) + "==";
       for(int i=0;i<ArraySize(iRSIBuffer)-1;i++)
         {        
            string temp=DoubleToString( iRSIBuffer[i],0);
            bardata=bardata+temp +"_";
         }
         bardata = bardata +"_M1="+ GetBarM1();
       //  Print(bardata);
         return bardata;      
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
      
    //  Print("h=",h, " h1=",H_from," h2=",H_to);
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
//#include <ReadWriteRequest.mqh>;
//#include <checkbox.mqh>;

//CControlsDialog ExtDialog;


HttpRequest http;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   
   Print("new version 2024 08 31" );
   
  Print("====================" );

  
  
 FileDelete(IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN))+".txt",FILE_COMMON);
  
 // string a = "333";
 // Print("StringFind=",a,"=", StringToDouble(a) );
  
 //   a = "to[";
 // Print("StringFind=",a,"=", StringToDouble(a) ,  StringToDouble(a)==0 );
  
//  Print("a=",MathRound( 0.05/2)); 

//Print(IntegerToString( (int) AccountInfoDouble(ACCOUNT_PROFIT))  + " / " +  DoubleToString(DayProfit(),0) );
 string _possym = _Symbol;      
StringReplace( _possym,"GOLD","XAUUSD");    
   _possym=StringSubstr(_possym,0,6);
string Mname= IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN))+ "_"+ _possym;
     
http.MaxLot = MaxLot;
http.CopyClose = CopyClose;
//if (CopyTrade)
  // http.MyName=Mname;
//Print(http.MyName);
http.CopyTrade = CopyTrade;
   

   http.scale = scale;
   http.UseHttp = UseHttp;
   if(!UseHttp && scale>0) http.AutoMode=true;
   http.ServerName = ServerName;  
   http.MyPartner = Partner;
   http.AutoStop = AutoStop;   
   EventSetTimer(timer);
   http.scaleString= scaleString;
   Print("Account=",IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN)));
      
Print(" updated 2025 01 14");
   
  http.UpdateMyPosition();
http.SendCurrentPosToWeb();  
//string mt5b=  IntegerToString(  (int)AccountInfoDouble(ACCOUNT_BALANCE));
//Print("balance=",mt5b);

Comment("scale string=",http.scaleString);      
   
  if(CopyTrade || CopyClose) 
     {     
     //  if(UseHttp) http.UpdateAutoMode();
        http.UpdateParnerPos();
     }
   //http.SendBars();
  // GetProfit();
   
   return(INIT_SUCCEEDED);
  }  
  

void GetProfit()
{


   datetime end = TimeCurrent();
   
   string sdate = TimeToString (TimeCurrent(), TIME_DATE);
   datetime start = StringToTime(sdate);   
  for(int x=0;x<=7; x++)
  { 
      end = TimeCurrent() - 60*60*24*x;
      MqlDateTime STime;  
      TimeToStruct(end,STime);       
         
         if(STime.day_of_week<6 && STime.day_of_week>0)
       {
         HistorySelect(start,end);
         int TotalDeals = HistoryDealsTotal();
         double dayprof=0;
         for(int i = 0; i < TotalDeals; i++)
           {
               ulong Ticket = HistoryDealGetTicket(i);
               if(HistoryDealGetInteger(Ticket,DEAL_ENTRY) == DEAL_ENTRY_OUT)
                 {
                     double LatestProfit = HistoryDealGetDouble(Ticket, DEAL_PROFIT);
                     dayprof += LatestProfit;
                 }
           }
            Print("i=",x," ", start, " end=", end, " profit=",dayprof);
       }
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
  
  MqlDateTime date ;
  int PositionNum=0;
  void OnTimer()  
  {
 //Print("timer");
  //   TimeToStruct( TimeLocal(),date);
   //  if(date.hour>0 && date.hour<7)
   //      EventSetTimer(1800);
   //   else
     //    EventSetTimer(timer);
    if(UseHttp)
    {
       if( PositionNum>0 ||  ArraySize( http.CurrentPos)>0 || ArraySize( http.CurrentParnerPos)>0   )
       {
          //   Print("SendCurrentPosToWeb");
            http.SendCurrentPosToWeb();
            PositionNum = ArraySize( http.CurrentPos);
        }
            
        
    }
   
         
      Comment( "Scale-> ", http.scaleString);
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
    
    if(CopyTrade || CopyClose) http.UpdateParnerPos();
    http.UpdateMyPosition();
    if(CopyTrade )
    {      
   // Print("Copy trade");
     //    http.UpdateAutoMode();
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


//+------------------------------------------------------------------+
//| Trade function                                                   |
//+------------------------------------------------------------------+



