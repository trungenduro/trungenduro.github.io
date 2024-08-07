//+------------------------------------------------------------------+
//|                                                    PosObject.mqh |
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
    PosObject(string st)
    {
        string result[];               // An array to get strings
      // Print("st=",st);
         ushort  u_sep=StringGetCharacter(",",0);
   
         int k=StringSplit(st,u_sep,result); 
         if (k>3)
         {
            ticket = StringToInteger( result[0]);
            QTY = StringToDouble(result[3]);
            posSymBol = result[1];          
             StringReplace(posSymBol,"GOLD","XAUUSD");         
             StringReplace(posSymBol,"_J","");
          
            posType = result[2];
            if(k>=5) {
               //TP = StringToDouble(result[4]);
            //   Print("TP=",TP);
            }            
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
         comment    =PositionGetString(POSITION_COMMENT);
         isNew=false;
          if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
              {
                  posType = "Buy";
              }
      }
   }
   
   int PosCount(){   
      return PositionsTotal();
   }
   string ToString()
   {   
      string text = ticket + ","+posSymBol + "," + posType + "," + DoubleToString(QTY,3) + ","  + DoubleToString(POSITION_TP,2);
      return text;
   }
      
   string OpenNew(double qty=0)
   {   
      double Qty = qty;
      
      if(qty==0) Qty = QTY;
      
      Print("qty=",qty," Qty=",Qty, " QTY", QTY);
     string sym=_Symbol;
     
    StringReplace( sym,"micro",""); 
    StringReplace( sym,"_m","");
    StringReplace( sym,"m","");
    StringReplace( sym,"-","");
    string _possym = posSymBol;  
      StringReplace( _possym,"micro",""); 
    StringReplace( _possym,"m",""); 
   
   if(sym!= _possym)
   {
      Print(sym, " is difference ", _possym);
      //return "";
   }
   
     MqlTradeRequest request;
     MqlTradeResult result;
     ZeroMemory(request);
       request.action = TRADE_ACTION_DEAL;       
            request.symbol = _Symbol;
            request.comment=ticket;
            request.volume = Qty;
            //request.position = ticket;
            //request.type_filling=ORDER_FILLING_IOC;
            request.deviation = 3;            
         Print("===== New Child Order =", ticket, " Symbol", posSymBol, " ",posType, " Qty", QTY);
      if(TP>0)
               request.tp = TP;
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
            if(_Symbol!= posSymBol)
            {
            //   Print(posSymBol, " is difference ", _Symbol);
               return;
            }
                MqlTradeRequest request;
     MqlTradeResult result;
     ZeroMemory(request);
       request.action = TRADE_ACTION_DEAL;       
            request.symbol = _Symbol;
            request.position=ticket;
          
            
            request.volume = QTY;
            //request.type_filling=ORDER_FILLING_IOC;
            request.deviation = 3;
            
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
  
};
