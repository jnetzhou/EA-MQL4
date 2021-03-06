//+------------------------------------------------------------------+
//|                                                     Discover.mq4 |
//|                                          Copyright 2019, Aother. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Aother."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

//定义本EA操作的订单的唯一标识
#define MAGICMA  20191212

input double Lots              =0.05;       //下单手数

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{

    return(INIT_SUCCEEDED);
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
    // 布林走势
    double bollUpper = iBands(_Symbol,_Period,21,2,0,PRICE_CLOSE,MODE_UPPER,1);
    double bollLower = iBands(_Symbol,_Period,21,2,0,PRICE_CLOSE,MODE_LOWER,1); 
    double bollMain  = iBands(_Symbol,_Period,21,2,0,PRICE_CLOSE,MODE_MAIN,1);
    double bollUpperPre = iBands(_Symbol,_Period,21,2,0,PRICE_CLOSE,MODE_UPPER,2);
    double bollLowerPre = iBands(_Symbol,_Period,21,2,0,PRICE_CLOSE,MODE_LOWER,2); 
    double bollMainPre  = iBands(_Symbol,_Period,21,2,0,PRICE_CLOSE,MODE_MAIN,2);
    // 开口判断
    bool isExpand = bollUpper>bollUpperPre && bollLower<bollLowerPre;
    bool isShrink = bollUpper<bollUpperPre && bollLower>bollLowerPre;
    // 中轨方向
    double trend = bollMain - bollMainPre;
    
    // 震荡情况
    double stocMain = iStochastic(_Symbol,_Period,5,3,3,MODE_SMA,0,MODE_MAIN,0);
    
    // 检查平仓
    CheckForClose(isShrink,stocMain);
    
    // 检测开仓
    CheckForOpen(isExpand,trend);
}


//+------------------------------------------------------------------+
//| 开仓
//+------------------------------------------------------------------+
void CheckForOpen(bool isExpand, double trend)
{
    // 不要重复下单
    if(OrdersTotal()>0) return;
    
    //多单
    if(isExpand && trend>0)
    {
      //发送仓单（当前货币对，买入方向，开仓量计算（），卖价，滑点=0，无止损，无止赢，订单编号，标上蓝色箭头）
      Print("【多】单开仓结果：",OrderSend(_Symbol,OP_BUY,Lots,Ask,0,0,0,"",MAGICMA,0,Blue));
      return;
    }
    
    //空单
    if(isExpand && trend<0)
    {
      //发送仓单（当前货币对，卖出方向，开仓量计算（），买价，滑点=3，无止损，无止赢，订单编号，标上红色箭头）
      Print("【空】单开仓结果：",OrderSend(_Symbol,OP_SELL,Lots,Bid,0,0,0,"",MAGICMA,0,Red));
      return;       
    }
}


//+------------------------------------------------------------------+
//| 平仓
//+------------------------------------------------------------------+
void CheckForClose(bool isShrink, double stocMain)
{
    for(int i=0;i<OrdersTotal();i++)
    {
        //如果 没有本系统所交易的仓单时，跳出循环
        if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
        //如果 仓单编号不是本系统编号，或者 仓单货币对不是当前货币对时，继续选择
        if(OrderMagicNumber()!=MAGICMA || OrderSymbol()!=_Symbol) continue;
        if(isShrink)
        {
            if(OrderType()==OP_BUY && stocMain>=60)
            {
                Print("平仓结果：",OrderClose(OrderTicket(),OrderLots(),Bid,0,Blue));            
                continue;
            }
            
            if(OrderType()==OP_SELL && stocMain<=460)
            {
            
                Print("平仓结果：",OrderClose(OrderTicket(),OrderLots(),Ask,0,Red));
                continue;
            }
            
        }
    }
}

//+------------------------------------------------------------------+
