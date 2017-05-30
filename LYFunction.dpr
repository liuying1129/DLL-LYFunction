library LYFunction;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }

uses
  SysUtils,
  Classes,
  WINDOWS{DWORD,UINT},
  Forms{Screen},
  DateUtils{yearof},
  StrUtils{ReverseString},
  Math{RoundTo},
  ExtCtrls{Timage},
  GIFImage{Tgifimage};

{$R *.res}

const
  CRCL:array[0..255] of byte=(
$00,$C1,$81,$40,$01,$C0,$80,$41,$01,$C0,$80,$41,$00,$C1,$81,$40,
$01,$C0,$80,$41,$00,$C1,$81,$40,$00,$C1,$81,$40,$01,$C0,$80,$41,
$01,$C0,$80,$41,$00,$C1,$81,$40,$00,$C1,$81,$40,$01,$C0,$80,$41,
$00,$C1,$81,$40,$01,$C0,$80,$41,$01,$C0,$80,$41,$00,$C1,$81,$40,
$01,$C0,$80,$41,$00,$C1,$81,$40,$00,$C1,$81,$40,$01,$C0,$80,$41,
$00,$C1,$81,$40,$01,$C0,$80,$41,$01,$C0,$80,$41,$00,$C1,$81,$40,
$00,$C1,$81,$40,$01,$C0,$80,$41,$01,$C0,$80,$41,$00,$C1,$81,$40,
$01,$C0,$80,$41,$00,$C1,$81,$40,$00,$C1,$81,$40,$01,$C0,$80,$41,
$01,$C0,$80,$41,$00,$C1,$81,$40,$00,$C1,$81,$40,$01,$C0,$80,$41,
$00,$C1,$81,$40,$01,$C0,$80,$41,$01,$C0,$80,$41,$00,$C1,$81,$40,
$00,$C1,$81,$40,$01,$C0,$80,$41,$01,$C0,$80,$41,$00,$C1,$81,$40,
$01,$C0,$80,$41,$00,$C1,$81,$40,$00,$C1,$81,$40,$01,$C0,$80,$41,
$00,$C1,$81,$40,$01,$C0,$80,$41,$01,$C0,$80,$41,$00,$C1,$81,$40,
$01,$C0,$80,$41,$00,$C1,$81,$40,$00,$C1,$81,$40,$01,$C0,$80,$41,
$01,$C0,$80,$41,$00,$C1,$81,$40,$00,$C1,$81,$40,$01,$C0,$80,$41,
$00,$C1,$81,$40,$01,$C0,$80,$41,$01,$C0,$80,$41,$00,$C1,$81,$40);
  CRCH:array[0..255] of byte=(
$00,$C0,$C1,$01,$C3,$03,$02,$C2,$C6,$06,$07,$C7,$05,$C5,$C4,$04,
$CC,$0C,$0D,$CD,$0F,$CF,$CE,$0E,$0A,$CA,$CB,$0B,$C9,$09,$08,$C8,
$D8,$18,$19,$D9,$1B,$DB,$DA,$1A,$1E,$DE,$DF,$1F,$DD,$1D,$1C,$DC,
$14,$D4,$D5,$15,$D7,$17,$16,$D6,$D2,$12,$13,$D3,$11,$D1,$D0,$10,
$F0,$30,$31,$F1,$33,$F3,$F2,$32,$36,$F6,$F7,$37,$F5,$35,$34,$F4,
$3C,$FC,$FD,$3D,$FF,$3F,$3E,$FE,$FA,$3A,$3B,$FB,$39,$F9,$F8,$38,
$28,$E8,$E9,$29,$EB,$2B,$2A,$EA,$EE,$2E,$2F,$EF,$2D,$ED,$EC,$2C,
$E4,$24,$25,$E5,$27,$E7,$E6,$26,$22,$E2,$E3,$23,$E1,$21,$20,$E0,
$A0,$60,$61,$A1,$63,$A3,$A2,$62,$66,$A6,$A7,$67,$A5,$65,$64,$A4,
$6C,$AC,$AD,$6D,$AF,$6F,$6E,$AE,$AA,$6A,$6B,$AB,$69,$A9,$A8,$68,
$78,$B8,$B9,$79,$BB,$7B,$7A,$BA,$BE,$7E,$7F,$BF,$7D,$BD,$BC,$7C,
$B4,$74,$75,$B5,$77,$B7,$B6,$76,$72,$B2,$B3,$73,$B1,$71,$70,$B0,
$50,$90,$91,$51,$93,$53,$52,$92,$96,$56,$57,$97,$55,$95,$94,$54,
$9C,$5C,$5D,$9D,$5F,$9F,$9E,$5E,$5A,$9A,$9B,$5B,$99,$59,$58,$98,
$88,$48,$49,$89,$4B,$8B,$8A,$4A,$4E,$8E,$8F,$4F,$8D,$4D,$4C,$8C,
$44,$84,$85,$45,$87,$47,$46,$86,$82,$42,$43,$83,$41,$81,$80,$40);


function ManyStr(const pSS, pSourStr: Pchar): integer;stdcall;
//计算pSourStr中有多少个pSS
var
        i,j:integer;
        ll,lll:integer;
        ss,sourstr:string;
begin
  setlength(ss,length(pSS));
  for j :=1  to length(pSS) do ss[j]:=pSS[j-1];

  setlength(sourstr,length(pSourStr));
  for j :=1  to length(pSourStr) do sourstr[j]:=pSourStr[j-1];

        i:=0;
        while pos(ss,sourstr)<>0 do
        begin
                ll:=pos(ss,sourstr);
                lll:=length(ss);
                delete(sourstr,1,ll+lll-1);
                inc(i);
        end;
        result:=i;
end;

function StrToList(const SourStr:string;const Separator:string):TStrings;
//根据指定的分隔字符串(Separator)将字符串(SourStr)导入到字符串列表中
var
  vSourStr,s:string;
  ll,lll:integer;
begin
  vSourStr:=SourStr;
  Result := TStringList.Create;
  lll:=length(Separator);

  while pos(Separator,vSourStr)<>0 do
  begin
    ll:=pos(Separator,vSourStr);
    Result.Add(copy(vSourStr,1,ll-1));
    delete(vSourStr,1,ll+lll-1);
  end;  //}
  Result.Add(vSourStr);
  s:=vSourStr;
end;

function RangeStrToSql(const pRangeStr:Pchar;const ifLPad:boolean;const LPad:Char;const sWidth:integer;var pSqlStr:Pchar):boolean;stdcall;
//范围字符串RangeStr类似5,7-9,11 转换为('0005','0007','0008','0009','0011')
var
  i,j,k,m:integer;
  sList:tstrings;
  iList:integer;
  iSwap,FhPos:integer;
  sLeft,sRight:string;
  iLeft,iRight:integer;
  RangeStr,SqlStr:string;
  LPadStr:string;
begin
  //======将传入的范围字符指针转换为范围字符串，以方便处理
  setlength(RangeStr,length(pRangeStr));
  for k :=1  to length(pRangeStr) do RangeStr[k]:=pRangeStr[k-1];
  //======================================================

  RangeStr:=StringReplace(RangeStr,'，',',',[rfReplaceAll]); //,rfIgnoreCase  有rfIgnoreCase则大小写都匹配
  RangeStr:=StringReplace(RangeStr,'－','-',[rfReplaceAll]); //,rfIgnoreCase  有rfIgnoreCase则大小写都匹配

  for  m:=1  to sWidth do LPadStr:=LPadStr+LPad;//生成前导字符串

  result:=true;
  sList:=StrToList(RangeStr,',');//将逗号分隔的字符串导入字符串数组中
  for i :=0  to sList.Count-1 do
  begin
    if pos('-',sList[i])<>0 then
    begin
      FhPos:=pos('-',sList[i]); //负号的位置
      sLeft:=copy(sList[i],1,FhPos-1); //'-'左边的内容
      if not trystrtoint(trim(sLeft),iLeft) then begin sList.Free;result:=false;exit;end;
      sRight:=sList[i];
      delete(sRight,1,FhPos);        //'-'右边的内容
      if not trystrtoint(trim(sRight),iRight) then begin sList.Free;result:=false;exit;end;
      if iLeft>iRight then begin iSwap:=iLeft;iLeft:=iRight;iRight:=iSwap;end;
      for j :=iLeft  to iRight do
        if ifLPad then SqlStr:=SqlStr+','+''''+copy(LPadStr+inttostr(j),Length(LPadStr+inttostr(j))-sWidth+1,sWidth)+''''
          else SqlStr:=SqlStr+','+''''+inttostr(j)+'''';
    end else
    begin
      if not trystrtoint(trim(sList[i]),iList) then begin sList.Free;result:=false;exit;end;
      if ifLPad then SqlStr:=SqlStr+','+''''+copy(LPadStr+trim(sList[i]),Length(LPadStr+trim(sList[i]))-sWidth+1,sWidth)+''''
        else SqlStr:=SqlStr+','+''''+trim(sList[i])+'''';
    end;
  end;
  if trim(SqlStr)='' then begin sList.Free;result:=false;exit;end;
  delete(SqlStr,1,1);//删除第一个字符，即逗号
  SqlStr:='('+SqlStr+')';
  sList.Free;

  //=======将SqlStr转换为pSqlStr
  try
    GetMem(pSqlStr,length(SqlStr)+1) ;
  except
    pSqlStr := nil ;
  end ;
  if assigned(pSqlStr) then
  begin
    StrPLCopy(pSqlStr,SqlStr,length(SqlStr)) ;
    pSqlStr[length(SqlStr)] := #0;
  end;
  //==============================
end;

function PosExt(const psubStr,pAllstr:Pchar;const Times:Byte):integer;stdcall;
//加强型的Pos函数,取得subStr在Allstr中第Times次出现的位置。
//刘鹰；2006-2-23
var
  i,TempTimes: integer;
  TempAllStr : string;
  subStr,Allstr:string;
begin
  //==============将传入的字符指针转换为字符串，以方便处理
  setlength(subStr,length(psubStr));
  for i :=1  to length(psubStr) do subStr[i]:=psubStr[i-1];

  setlength(Allstr,length(pAllstr));
  for i :=1  to length(pAllstr) do Allstr[i]:=pAllstr[i-1];
  //======================================================

  Result := 0;TempTimes := 0;
  if (pos(subStr,Allstr) <= 0) or (Times = 0) then exit;
  
  TempAllStr := Allstr;

  while TempTimes<times do
  begin
    i := pos(subStr,TempAllStr);
    if i=0 then begin result:=0;exit;end;
    Result := Result + i;
    Delete(TempAllStr,1,i+length(subStr)-1);
    if TempTimes<>0 then Result := Result +length(subStr)-1;
    inc(TempTimes);
  end;
end;

function MaxDotLen(const ACalaExp:PChar):integer;stdcall;
//找到表达式中小数点位数的最大值.如56.5*100+23.01的值为2
//此函数结果用于计算值的精确位数
var
  sCalaExp:string;
  DotPos,i,DotLen:integer;

  iTemp1,iTemp2:integer;
begin
  result:=0;

  sCalaExp:=strpas(ACalaExp);

  //处理表达式中的trunc函数 start
  //例如56.5*100+23.01*trunc(59.6500003),则删除trunc段'trunc(59.6500003)'
  //这种写法仅支持trunc函数中只有一层括号
  iTemp1:=pos('TRUNC(',uppercase(sCalaExp));
  while iTemp1>0 do
  begin    iTemp2:=pos(')',copy(sCalaExp,iTemp1,MaxInt));    delete(sCalaExp,iTemp1,iTemp2);    iTemp1:=pos('TRUNC(',uppercase(sCalaExp));  end;  //处理表达式中的trunc函数 stop
  DotPos:=pos('.',sCalaExp);
  while DotPos>0 do
  begin
    DotLen:=0;
    for i :=DotPos+1  to length(sCalaExp) do
    begin
      if not (sCalaExp[i] in ['0'..'9']) then
      begin
        DotLen:=i-DotPos-1;
        break;
      end;
      DotLen:=i-DotPos;//如果点(.)后全部是数字
    end;
    
    if DotLen>result then result:=DotLen; 

    delete(sCalaExp,1,DotPos);
    DotPos:=pos('.',sCalaExp);
  end;
end;

function TryStrToFloatExt(const pSourStr:Pchar; var Value: Double): Boolean;stdcall;
//加强型的TryStrToFloat函数,能提取字符串中第一个浮点数或整数。
//例：StrTofloatExt(#$21+'-45.67'+'是')=-45.67
//例：StrTofloatExt(#$21+'-.67'+'是')=-0.67
//刘鹰；2003-5-8
//2009-04-30 Value类型single->double,只有double才支持RoundTo
var
  SourStr:string;
  SourStrLen:integer;
  i:integer;
  ifFUSHU:BOOLEAN;
  dotPos,dotWS:Integer;
begin
  result:=false;
  ifFUSHU:=false;
  SourStr:=strpas(pSourStr);       
  SourStrLen:=length(SourStr);
  for i :=1  to SourStrLen do
  begin
    if ord(sourstr[i]) in [46,48..57] then
    begin
      if i>=2 then if sourstr[i-1]='-' then ifFUSHU:=true;//是否负数
      delete(sourStr,1,i-1);
      break;
    end;
  end;
  sourStrLen:=length(sourStr);
  for i :=1  to sourStrLen do
  begin
    if not(ord(sourstr[i]) in [46,48..57]) then
    begin
      sourstr:=copy(sourstr,1,i-1);
      break;
    end;
  end;

  //小数点位数
  dotPos:=pos('.',sourstr);
  if dotPos>0 then dotWS:=length(sourstr)-dotPos else dotWS:=0;
  //==========
  
  if not TryStrToFloat(sourstr,Value) then exit;
  Value:=RoundTo(Value,dotWS*(-1));//小数点位数
  if ifFUSHU then Value:=Value*(-1);
  result:=true;
end;

function GetVersionLY(const AFileName:Pchar):Pchar;stdcall;
//获取文件的版本号,如0.0.7.1
//刘鹰；2008-1-10
var 
  InfoSize, Wnd: DWORD; 
  VerBuf: Pointer; 
  szName: array[0..255] of Char; 
  Value: Pointer; 
  Len: UINT; 
  TransString,sResult:string;
begin 
  Result := nil;//Result := ''也可.既然是pchar类型,正规点还是返回nil吧
  InfoSize := GetFileVersionInfoSize(AFileName, Wnd);
  if InfoSize <> 0 then 
  begin 
    GetMem(VerBuf, InfoSize); 
    try 
      if GetFileVersionInfo(AFileName, Wnd, InfoSize, VerBuf) then 
      begin 
        Value :=nil; 
        VerQueryValue(VerBuf, '\VarFileInfo\Translation', Value, Len); 
        if Value <> nil then TransString := IntToHex(MakeLong(HiWord(Longint(Value^)), LoWord(Longint(Value^))), 8);
        StrPCopy(szName, '\StringFileInfo\'+Transstring+'\FileVersion');
                                                        //^^^^^^^此处换成ProductVersion得到的是"产品版本" 
        if VerQueryValue(VerBuf, szName, Value, Len) then
        begin
          sResult := strpas(pchar(Value));
          //=======将string转换为pchar
          try
            GetMem(Result,length(sResult)+1) ;
          except
            Result := nil ;
          end ;
          if assigned(Result) then
          begin
            StrPLCopy(Result,sResult,length(sResult)) ;
            Result[length(sResult)] := #0;
          end;
          //==============================
        end;
      end;
    finally
      FreeMem(VerBuf); 
    end;
  end;
end;

function GetSysCurImeName: Pchar;stdcall;
//取得系统当前的中文输入法名称 
//刘鹰；2008-1-10
var 
  ImeNum:integer;//中文输入法数量
  ImeIndex:integer;//当前中文输入法索引号
  sResult:string;
begin
  Result := nil;
  ImeNum:=Screen.Imes.Count;
  ImeIndex:=Screen.Imes.IndexOfObject(Pointer(GetKeyboardLayout(0)));
  if(ImeIndex<0)or(ImeIndex>=ImeNum)then exit;
  sResult:=Screen.Imes.Strings[ImeIndex];
  
  //=======将string转换为pchar
  try
    GetMem(Result,length(sResult)+1) ;
  except
    Result := nil ;
  end ;
  if assigned(Result) then
  begin
    StrPLCopy(Result,sResult,length(sResult)) ;
    Result[length(sResult)] := #0;
  end;
  //==============================
end;

function GetHDSn(const RootPath:Pchar):Pchar;stdcall;
//取得指定分区的序列号 
//刘鹰；2008-1-10
var
  VolName: array[0..255] of Char;     // holds the volume name
  SerialNumber: DWORD;                // holds the serial number
  MaxCLength: DWORD;                  // holds the maximum file component length
  FileSysFlag: DWORD;                 // holds file system flags

  FileSysName: array[0..255] of Char; // holds the name of the file system
  sresult: string;
begin
  {retrieve the volume information}
  GetVolumeInformation(RootPath, VolName, 255, @SerialNumber, MaxCLength,
     FileSysFlag, FileSysName, 255);

  {display the information}
  //Panel2.Caption := VolName;
  sresult := IntToHex(SerialNumber,8);
  //Panel4.Caption := FileSysName;
  
  //=======将string转换为pchar
  try
    GetMem(Result,length(sResult)+1) ;
  except
    Result := nil ;
  end ;
  if assigned(Result) then
  begin
    StrPLCopy(Result,sResult,length(sResult)) ;
    Result[length(sResult)] := #0;
  end;
  //==============================
end;

function StrToHex(const ASourStr:Pchar):Pchar;stdcall;
var
  i:integer;
  sresult,SourStr: string;
begin
  sresult:='';
  SourStr:=strpas(ASourStr);
  for i :=1  to length(SourStr) do
  begin
    sresult:=sresult+inttohex(ord(SourStr[i]),2)+' ';
  end;

  //=======将string转换为pchar
  try
    GetMem(Result,length(sResult)+1) ;
  except
    Result := nil ;
  end ;
  if assigned(Result) then
  begin
    StrPLCopy(Result,sResult,length(sResult)) ;
    Result[length(sResult)] := #0;
  end;
  //==============================
end;

function IntToBin(AInt: integer):Pchar;stdcall;
//十进制转换为二进制字符串
//add by ly 2009-08-31
var
  sResult: string;
begin
  if AInt=0 then begin sResult:='0';end;
  
  while AInt<>0 do
  begin          //i mod 2取模,再使用format格式化
    sResult:=Format('%d'+sResult,[AInt mod 2]);
    AInt:=AInt div 2;
  end;

  //=======将string转换为pchar
  try
    GetMem(Result,length(sResult)+1) ;
  except
    Result := nil ;
  end ;
  if assigned(Result) then
  begin
    StrPLCopy(Result,sResult,length(sResult)) ;
    Result[length(sResult)] := #0;
  end;
  //==============================  
end;

Function BinToInt(ABin :pchar) : integer;stdcall;
//二进制字符转十进制
//add by ly 2009-08-31
VAR
  str : String;
  i : integer;
BEGIN
  Str := UpperCase(strpas(ABin));
  Result := 0;
  FOR i := 1 TO Length(str) DO Result := Result * 2+ ORD(str[i]) - 48;
end;

function ByteToReal(AByte1,AByte2,AByte3,AByte4:byte):single;stdcall;
var
  StrBin1,StrBin2,StrBin3,StrBin4:string;
  StrZ,StrF:string;
  E:integer;
  XiaoShu:single;
  buling:string;
  i:integer;
begin
  Result:=0;
  
  StrBin1:=rightstr('00000000'+IntToBin(AByte1),8);
  StrBin2:=rightstr('00000000'+IntToBin(AByte2),8);
  StrBin3:=rightstr('00000000'+IntToBin(AByte3),8);
  StrBin4:=rightstr('00000000'+IntToBin(AByte4),8);

  StrZ:= rightstr(StrBin1,7) + leftstr(StrBin2,1);
  StrF:= '1' + rightstr(StrBin2,7) + StrBin3 + StrBin4;

  E:=BinToInt(pchar(StrZ));

  XiaoShu:=0;

  if (E < 127) then
  begin
    E := 127 - E;
    if (E <> 127) then
    begin
      buling:='';
      for i :=1  to E do buling:= buling+'0';

      strf:= buling + strf;

      for i :=1  to 24 + E do if strf[i] = '1' then xiaoshu:=xiaoshu + Power(2, 0 - i);

      result:= xiaoshu;
    end;
  end else
  begin
    E:= E - 127;
    strz:= leftstr(strf, E + 1);
    result:= BinToInt(pchar(strz));
    delete(strf,1,E + 1);
    for i :=1  to 23-E do if strf[i]='1' then XiaoShu:=XiaoShu+Power(2,0 - i);
    result:=result+ xiaoshu;
  end;

  if (StrBin1[1] = '1') then  result:= 0 - result;
end;

function RealTo4Byte(AReal:single):Pchar;stdcall;
var
  //20110513暂时不支持负数，不支持纯小数，如0.123
  //例如:RealTo4Byte(34.678)='420AB646'
  //ByteToReal($42,$0A,$B6,$46)=34.678
  iReal:Integer;//整数部分
  fReal:single;//小数部分
  iBin:string;//整数部分的二进制
  fBin:string;//小数部分的二进制
  i:integer;
  s1,s2:string;
  ss:string;//最后的二进制码
  sResult:string;
begin 
  if AReal=0 then begin result:='00000000';exit;end;

  iReal:=Trunc(AReal);
  fReal:=AReal-Trunc(AReal);
  
  iBin:=IntToBin(iReal);//整数部分的二进制

  s2:=rightstr('00000000'+IntToBin(127+length(iBin)-1),8);

  for i :=1 to 24-length(iBin) do
  begin
    if fReal<1/Power(2,i) then fBin:=fBin+'0'
    else begin
      fBin:=fBin+'1';
      fReal:=fReal-1/Power(2,i);
    end;
  end;
  
  ss:='0'+s2+copy(iBin,2,MaxInt)+fBin;//最前面的0是符号位.0表示正数

  s1:=rightstr(ss,4);
  while length(s1)>0 do
  begin
    sResult:=InttoHex(BinToInt(Pchar(s1)),1)+sResult;
    delete(ss,length(ss)-4+1,4);
    s1:=rightstr(ss,4);
  end;
  
  //=======将string转换为pchar
  try
    GetMem(Result,length(sResult)+1) ;
  except
    Result := nil ;
  end ;
  if assigned(Result) then
  begin
    StrPLCopy(Result,sResult,length(sResult)) ;
    Result[length(sResult)] := #0;
  end;
  //==============================  
end;

procedure WriteLog(const ALogStr: Pchar);stdcall;
//写日志文件
Var
  fLog          : TextFile;
  FName         : String;
begin
  FName := inttostr(yearof(now)) + 'Year' + inttostr(monthof(now)) + 'Mon' + inttostr(dayof(now)) + 'Day.log';
  FName := ExtractFileDir(Application.ExeName)  + '\' + FName;
  AssignFile(fLog, FName);
  if not FileExists(FName) then ReWrite(fLog) else Append(fLog);
  WriteLn(fLog, FormatDatetime('YYYY-MM-DD HH:NN:SS', Now) + ':' + strpas(ALogStr));
  CloseFile(fLog); 
end;

function LastPos(const ASubStr,ASourStr:Pchar):integer;stdcall;
//取得ASubStr在ASourStr中最后一次出现的位置
var
  SubStr,SourStr:string;
  sub,sour:string;
begin
  SubStr:=strpas(ASubStr);
  SourStr:=strpas(ASourStr);

  if Pos(subStr,sourStr)=0 then
  begin
    Result:=0;
    exit;
  end;
  sub:=ReverseString(subStr);
  sour:=ReverseString(sourStr);
  Result:=length(sourStr)-Pos(sub,sour)+1-length(subStr)+1;
end;

function CassonEquation(const X1,Y1,X2,Y2:Real;var A,B:Real):boolean;stdcall;
//卡松方程式:sqrt(y)=a+b*sqrt(1/x)
//根据传入的X,Y值计算A,B
begin
  result:=true;
  
  IF (X1<=0)OR(Y1<0)OR(X2<=0)OR(Y2<0) THEN
  BEGIN
    result:=false;
    EXIT;
  END;

  try
    B:=(sqrt(Y1)-sqrt(Y2))/(sqrt(1/X1)-sqrt(1/X2));
    A:=sqrt(Y1)-B*sqrt(1/X1);
  except
    result:=false;
  end;
end;

function Gif2Bmp(const AGifFile,ABmpFile:Pchar):boolean;stdcall;
var 
  tmpGifFile,tmpBmpFile:string;

  tmpImage:Timage;
  tmpGif:Tgifimage;
begin
  result:=false;
  
  tmpGifFile:=strpas(AGifFile);
  tmpBmpFile:=strpas(ABmpFile);

  if not FileExists(tmpGifFile) then exit;
  if uppercase(ExtractFileExt(tmpGifFile))<>'.GIF' THEN EXIT;
  if uppercase(ExtractFileExt(tmpBmpFile))<>'.BMP' THEN EXIT;
  tmpImage:=timage.Create(nil);
  tmpGif:=Tgifimage.Create;
  try
    tmpGif.LoadFromFile(tmpGifFile);
    tmpImage.Picture.Bitmap:=tmpGif.Bitmap;
    tmpImage.Picture.SaveToFile(tmpBmpFile);
    result:=true;
  finally
    tmpGif.Free;
    tmpImage.free;
  end;
end;

exports
manystr,
RangeStrToSql,
PosExt,
MaxDotLen,
TryStrToFloatExt,
GetVersionLY,
GetSysCurImeName,
GetHDSn,
StrToHex,
IntToBin,
BinToInt,
ByteToReal,
RealTo4Byte,
WriteLog,
LastPos,
CassonEquation,
Gif2Bmp;

begin
end.
 