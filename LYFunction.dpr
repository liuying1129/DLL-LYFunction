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
  GIFImage{Tgifimage},
  Graphics{TBitmap},
  pngimage{TPNGObject};

type
  TByte32 = array[1..32] of Byte;
  TSData = array[0..63] of Byte;
  TBlock = array[0..7] of Byte;

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

  SA1: TSData =
  (1, 0, 1, 0, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 0, 1,
    0, 0, 1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 0, 0, 1, 1, 1, 0, 0, 1, 0, 0, 0, 1, 0, 1, 1, 0, 0, 1);
  SA2: TSData =
  (1, 0, 1, 1, 0, 1, 0, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 1, 0, 0, 1, 0, 1, 1, 1, 0, 0, 1, 0, 1, 1, 0,
    0, 1, 0, 1, 1, 0, 1, 0, 0, 1, 1, 0, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 1);
  SA3: TSData =
  (1, 0, 1, 1, 0, 0, 1, 0, 0, 1, 1, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1, 1, 1, 1, 0,
    1, 0, 0, 1, 1, 1, 0, 0, 1, 0, 0, 1, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 1, 0, 0, 1);
  SA4: TSData =
  (0, 1, 1, 0, 0, 0, 1, 1, 0, 0, 1, 0, 1, 1, 0, 1, 1, 1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 1, 1, 1,
    1, 0, 1, 0, 1, 1, 0, 1, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 1, 1, 1, 0, 0, 1, 1, 0, 0, 1);
  SA5: TSData =
  (0, 1, 0, 0, 0, 1, 1, 0, 1, 0, 0, 1, 1, 0, 1, 1, 1, 1, 0, 1, 0, 0, 1, 0, 0, 0, 1, 1, 0, 1, 1, 0,
    0, 0, 0, 1, 1, 1, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 1, 0, 1, 0, 1, 0, 1, 1, 0, 0, 0);
  SA6: TSData =
  (1, 0, 1, 1, 1, 0, 0, 1, 0, 1, 0, 0, 1, 0, 0, 1, 1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 1, 0, 1,
    1, 1, 1, 0, 0, 1, 1, 0, 0, 0, 0, 1, 0, 1, 1, 0, 0, 0, 0, 1, 1, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1);
  SA7: TSData =
  (0, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 0, 1, 0, 0, 1, 0, 1, 0, 0, 1, 0, 1, 1, 0, 0, 1, 0, 1, 1, 0,
    0, 0, 1, 1, 1, 0, 0, 1, 1, 1, 0, 1, 0, 0, 1, 0, 0, 1, 1, 1, 0, 0, 1, 0, 1, 0, 0, 1, 1, 0, 0, 1);
  SA8: TSData =
  (1, 0, 1, 0, 0, 1, 1, 0, 1, 1, 0, 1, 0, 0, 1, 0, 0, 1, 1, 1, 1, 0, 0, 0, 1, 0, 0, 1, 0, 1, 1, 0,
    0, 1, 0, 0, 1, 1, 1, 0, 0, 0, 1, 1, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1);
  SB1: TSData =
  (1, 1, 1, 0, 0, 1, 0, 0, 0, 0, 1, 1, 1, 0, 0, 1, 0, 1, 1, 1, 1, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 0,
    1, 0, 1, 0, 1, 1, 0, 0, 1, 1, 0, 1, 0, 0, 1, 0, 1, 1, 0, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 0, 1, 1);
  SB2: TSData =
  (1, 0, 0, 1, 1, 0, 0, 1, 0, 1, 0, 1, 1, 0, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, 0, 0, 0, 1, 0, 0, 1,
    0, 1, 1, 0, 0, 1, 1, 0, 1, 0, 1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 1, 1, 0, 0, 1, 1, 1, 0, 1, 1, 0);
  SB3: TSData =
  (0, 0, 0, 1, 1, 0, 1, 1, 0, 1, 1, 1, 0, 1, 0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 1, 0, 1, 0,
    1, 1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 0, 1, 1, 0, 0, 1, 0, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 0, 1);
  SB4: TSData =
  (1, 1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1, 0, 0, 1, 1, 0, 1, 0, 0, 1, 0,
    0, 1, 0, 0, 1, 0, 1, 1, 1, 0, 0, 1, 1, 0, 0, 1, 0, 1, 0, 1, 0, 0, 1, 0, 0, 1, 1, 0, 1, 1, 0, 1);
  SB5: TSData =
  (0, 1, 1, 0, 1, 0, 0, 1, 0, 1, 0, 1, 1, 0, 1, 0, 1, 0, 0, 1, 1, 1, 1, 0, 1, 0, 1, 0, 0, 0, 0, 1,
    1, 0, 0, 0, 0, 1, 1, 0, 1, 0, 1, 1, 1, 0, 0, 1, 0, 0, 1, 1, 0, 1, 0, 1, 1, 1, 0, 0, 0, 1, 1, 0);
  SB6: TSData =
  (1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 1, 1, 1, 1, 0, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 0, 0, 0,
    0, 1, 1, 1, 0, 0, 1, 0, 1, 0, 1, 0, 0, 1, 0, 1, 1, 0, 0, 1, 0, 1, 1, 0, 0, 1, 0, 1, 1, 0, 0, 1);
  SB7: TSData =
  (1, 0, 0, 1, 1, 0, 0, 1, 0, 1, 0, 1, 1, 0, 1, 0, 1, 0, 0, 1, 1, 0, 0, 0, 1, 0, 1, 1, 0, 1, 0, 1,
    0, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 0, 1, 0, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0, 1, 1, 0, 0, 1);
  SB8: TSData =
  (1, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 1, 0, 0,
    1, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 1, 1, 0, 1, 0, 0, 0, 1, 1, 1, 0, 0, 1, 1, 1, 0, 0, 0, 1, 1, 0);
  SC1: TSData =
  (1, 0, 0, 0, 1, 1, 1, 0, 1, 1, 1, 0, 0, 0, 0, 1, 0, 1, 1, 0, 1, 1, 0, 0, 1, 1, 0, 1, 0, 0, 1, 0,
    0, 0, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0, 1, 1, 1, 1, 0, 1, 0);
  SC2: TSData =
  (1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, 0, 0, 0, 0, 1, 1, 0, 0, 1, 1, 1, 0, 1, 0, 0, 0, 1, 1, 0, 1, 0,
    0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1, 0, 1, 1, 1, 0, 0, 1, 0, 1, 1, 0, 1, 1, 1, 1, 0, 0, 0, 1, 0);
  SC3: TSData =
  (1, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 0, 1, 0, 0, 1, 0, 0, 1, 0, 1, 1, 1, 0, 0, 1, 0, 1, 1, 0,
    0, 1, 0, 0, 0, 1, 1, 0, 1, 0, 1, 0, 0, 1, 1, 1, 0, 1, 0, 0, 1, 0, 0, 1, 0, 1, 1, 1, 1, 0, 1, 0);
  SC4: TSData =
  (1, 0, 1, 1, 0, 1, 0, 1, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 1, 1, 0, 1, 0, 1, 1, 0, 0, 1, 1, 0,
    1, 1, 0, 0, 0, 1, 1, 0, 1, 0, 1, 1, 0, 1, 0, 0, 1, 1, 0, 1, 1, 0, 0, 0, 0, 0, 0, 1, 0, 1, 1, 1);
  SC5: TSData =
  (1, 0, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, 0, 0, 1, 0, 1, 1, 1, 0, 0, 1, 0, 0, 0, 0, 1, 1, 1, 0, 0, 1,
    0, 1, 0, 1, 1, 0, 1, 0, 1, 0, 0, 0, 1, 1, 0, 1, 1, 0, 0, 1, 0, 1, 1, 0, 1, 1, 0, 0, 1, 0, 0, 1);
  SC6: TSData =
  (0, 0, 1, 1, 0, 1, 1, 0, 0, 0, 1, 0, 1, 1, 0, 1, 1, 1, 0, 1, 1, 0, 0, 0, 1, 0, 0, 1, 0, 1, 1, 0,
    0, 1, 1, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 0, 1, 1, 0, 1, 1, 0, 0, 0, 1, 1, 1, 1, 0, 1, 1, 0, 0, 0);
  SC7: TSData =
  (0, 1, 1, 1, 1, 0, 0, 0, 1, 0, 0, 1, 0, 1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 1, 0, 0, 1, 1, 0, 1,
    0, 0, 1, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 1, 1, 0);
  SC8: TSData =
  (0, 1, 0, 0, 1, 1, 1, 0, 1, 0, 1, 1, 0, 0, 0, 1, 0, 1, 0, 0, 1, 1, 1, 0, 0, 0, 1, 1, 0, 1, 0, 1,
    1, 1, 0, 0, 0, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 0, 1, 0, 1, 1, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0, 1, 1);
  SD1: TSData =
  (0, 0, 1, 1, 0, 1, 1, 0, 1, 0, 0, 0, 1, 1, 0, 1, 0, 1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 1, 1, 0,
    0, 1, 0, 0, 1, 0, 0, 1, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1);
  SD2: TSData =
  (1, 1, 0, 0, 0, 1, 1, 0, 1, 1, 0, 1, 0, 0, 1, 0, 1, 1, 0, 1, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 1,
    0, 0, 1, 1, 0, 0, 1, 1, 1, 0, 0, 0, 1, 1, 0, 1, 1, 0, 0, 1, 1, 1, 0, 0, 1, 0, 1, 0, 0, 1, 0, 1);
  SD3: TSData =
  (0, 0, 1, 0, 0, 1, 1, 1, 1, 1, 0, 1, 1, 0, 0, 0, 1, 1, 0, 1, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 1,
    1, 0, 0, 1, 0, 1, 1, 0, 1, 1, 0, 0, 1, 0, 0, 1, 1, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 0);
  SD4: TSData =
  (1, 1, 0, 1, 0, 0, 1, 0, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 1, 1, 0, 1, 0, 1, 0, 1, 0, 0, 1, 0, 0, 1,
    0, 0, 1, 0, 0, 1, 1, 1, 1, 1, 1, 0, 1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 1, 0, 1, 1, 0, 1, 0, 0);
  SD5: TSData =
  (0, 0, 0, 1, 1, 0, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 0, 1, 0, 0, 0, 1, 1, 1, 1, 0, 1, 0, 1, 1, 0, 0,
    0, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 0, 1, 0, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 1, 0, 1, 0, 0, 1, 1);
  SD6: TSData =
  (0, 1, 0, 1, 1, 0, 0, 0, 0, 1, 1, 0, 0, 1, 1, 1, 0, 1, 0, 0, 1, 0, 1, 1, 0, 1, 1, 0, 0, 1, 1, 0,
    1, 0, 1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 1, 0, 0, 1, 0, 0, 1, 1, 1, 0, 1, 0, 1, 1, 0, 0, 0, 1);
  SD7: TSData =
  (0, 1, 0, 0, 1, 0, 0, 1, 1, 0, 1, 1, 1, 0, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 0, 0,
    1, 0, 1, 1, 0, 1, 1, 0, 0, 1, 0, 0, 0, 1, 1, 0, 0, 1, 1, 0, 1, 0, 0, 1, 1, 1, 0, 1, 0, 0, 1, 0);
  SD8: TSData =
  (1, 0, 0, 0, 0, 1, 1, 1, 0, 1, 1, 0, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, 0, 0, 1, 0, 1, 0, 0, 1, 0,
    1, 1, 0, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 1, 0, 1, 0, 0, 0, 1, 1, 0, 1, 0, 1, 1, 0, 1);

  Sc: array[1..16, 1..48] of Byte =
  ((15, 18, 12, 25, 2, 6, 4, 1, 16, 7, 22, 11, 24, 20, 13, 5, 27, 9, 17, 8, 28, 21, 14, 3,
    42, 53, 32, 38, 48, 56, 31, 41, 52, 46, 34, 49, 45, 50, 40, 29, 35, 54, 47, 43, 51, 37, 30, 33),
    (16, 19, 13, 26, 3, 7, 5, 2, 17, 8, 23, 12, 25, 21, 14, 6, 28, 10, 18, 9, 1, 22, 15, 4,
    43, 54, 33, 39, 49, 29, 32, 42, 53, 47, 35, 50, 46, 51, 41, 30, 36, 55, 48, 44, 52, 38, 31, 34),
    (18, 21, 15, 28, 5, 9, 7, 4, 19, 10, 25, 14, 27, 23, 16, 8, 2, 12, 20, 11, 3, 24, 17, 6,
    45, 56, 35, 41, 51, 31, 34, 44, 55, 49, 37, 52, 48, 53, 43, 32, 38, 29, 50, 46, 54, 40, 33, 36),
    (20, 23, 17, 2, 7, 11, 9, 6, 21, 12, 27, 16, 1, 25, 18, 10, 4, 14, 22, 13, 5, 26, 19, 8,
    47, 30, 37, 43, 53, 33, 36, 46, 29, 51, 39, 54, 50, 55, 45, 34, 40, 31, 52, 48, 56, 42, 35, 38),
    (22, 25, 19, 4, 9, 13, 11, 8, 23, 14, 1, 18, 3, 27, 20, 12, 6, 16, 24, 15, 7, 28, 21, 10,
    49, 32, 39, 45, 55, 35, 38, 48, 31, 53, 41, 56, 52, 29, 47, 36, 42, 33, 54, 50, 30, 44, 37, 40),
    (24, 27, 21, 6, 11, 15, 13, 10, 25, 16, 3, 20, 5, 1, 22, 14, 8, 18, 26, 17, 9, 2, 23, 12,
    51, 34, 41, 47, 29, 37, 40, 50, 33, 55, 43, 30, 54, 31, 49, 38, 44, 35, 56, 52, 32, 46, 39, 42),
    (26, 1, 23, 8, 13, 17, 15, 12, 27, 18, 5, 22, 7, 3, 24, 16, 10, 20, 28, 19, 11, 4, 25, 14,
    53, 36, 43, 49, 31, 39, 42, 52, 35, 29, 45, 32, 56, 33, 51, 40, 46, 37, 30, 54, 34, 48, 41, 44),
    (28, 3, 25, 10, 15, 19, 17, 14, 1, 20, 7, 24, 9, 5, 26, 18, 12, 22, 2, 21, 13, 6, 27, 16,
    55, 38, 45, 51, 33, 41, 44, 54, 37, 31, 47, 34, 30, 35, 53, 42, 48, 39, 32, 56, 36, 50, 43, 46),
    (1, 4, 26, 11, 16, 20, 18, 15, 2, 21, 8, 25, 10, 6, 27, 19, 13, 23, 3, 22, 14, 7, 28, 17,
    56, 39, 46, 52, 34, 42, 45, 55, 38, 32, 48, 35, 31, 36, 54, 43, 49, 40, 33, 29, 37, 51, 44, 47),
    (3, 6, 28, 13, 18, 22, 20, 17, 4, 23, 10, 27, 12, 8, 1, 21, 15, 25, 5, 24, 16, 9, 2, 19,
    30, 41, 48, 54, 36, 44, 47, 29, 40, 34, 50, 37, 33, 38, 56, 45, 51, 42, 35, 31, 39, 53, 46, 49),
    (5, 8, 2, 15, 20, 24, 22, 19, 6, 25, 12, 1, 14, 10, 3, 23, 17, 27, 7, 26, 18, 11, 4, 21,
    32, 43, 50, 56, 38, 46, 49, 31, 42, 36, 52, 39, 35, 40, 30, 47, 53, 44, 37, 33, 41, 55, 48, 51),
    (7, 10, 4, 17, 22, 26, 24, 21, 8, 27, 14, 3, 16, 12, 5, 25, 19, 1, 9, 28, 20, 13, 6, 23,
    34, 45, 52, 30, 40, 48, 51, 33, 44, 38, 54, 41, 37, 42, 32, 49, 55, 46, 39, 35, 43, 29, 50, 53),
    (9, 12, 6, 19, 24, 28, 26, 23, 10, 1, 16, 5, 18, 14, 7, 27, 21, 3, 11, 2, 22, 15, 8, 25,
    36, 47, 54, 32, 42, 50, 53, 35, 46, 40, 56, 43, 39, 44, 34, 51, 29, 48, 41, 37, 45, 31, 52, 55),
    (11, 14, 8, 21, 26, 2, 28, 25, 12, 3, 18, 7, 20, 16, 9, 1, 23, 5, 13, 4, 24, 17, 10, 27,
    38, 49, 56, 34, 44, 52, 55, 37, 48, 42, 30, 45, 41, 46, 36, 53, 31, 50, 43, 39, 47, 33, 54, 29),
    (13, 16, 10, 23, 28, 4, 2, 27, 14, 5, 20, 9, 22, 18, 11, 3, 25, 7, 15, 6, 26, 19, 12, 1,
    40, 51, 30, 36, 46, 54, 29, 39, 50, 44, 32, 47, 43, 48, 38, 55, 33, 52, 45, 41, 49, 35, 56, 31),
    (14, 17, 11, 24, 1, 5, 3, 28, 15, 6, 21, 10, 23, 19, 12, 4, 26, 8, 16, 7, 27, 20, 13, 2,
    41, 52, 31, 37, 47, 55, 30, 40, 51, 45, 33, 48, 44, 49, 39, 56, 34, 53, 46, 42, 50, 36, 29, 32));

var
  G: array[1..16, 1..48] of Byte;
  L, R, F: TByte32;
  C: array[1..56] of Byte;
    
function ManyStr(const pSS, pSourStr: Pchar): integer;stdcall;
//����pSourStr���ж��ٸ�pSS
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
//����ָ���ķָ��ַ���(Separator)���ַ���(SourStr)���뵽�ַ����б���
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
//��Χ�ַ���RangeStr����5,7-9,11 ת��Ϊ('0005','0007','0008','0009','0011')
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
  //======������ķ�Χ�ַ�ָ��ת��Ϊ��Χ�ַ������Է��㴦��
  setlength(RangeStr,length(pRangeStr));
  for k :=1  to length(pRangeStr) do RangeStr[k]:=pRangeStr[k-1];
  //======================================================

  RangeStr:=StringReplace(RangeStr,'��',',',[rfReplaceAll]); //,rfIgnoreCase  ��rfIgnoreCase���Сд��ƥ��
  RangeStr:=StringReplace(RangeStr,'��','-',[rfReplaceAll]); //,rfIgnoreCase  ��rfIgnoreCase���Сд��ƥ��

  for  m:=1  to sWidth do LPadStr:=LPadStr+LPad;//����ǰ���ַ���

  result:=true;
  sList:=StrToList(RangeStr,',');//�����ŷָ����ַ��������ַ���������
  for i :=0  to sList.Count-1 do
  begin
    if pos('-',sList[i])<>0 then
    begin
      FhPos:=pos('-',sList[i]); //���ŵ�λ��
      sLeft:=copy(sList[i],1,FhPos-1); //'-'��ߵ�����
      if not trystrtoint(trim(sLeft),iLeft) then begin sList.Free;result:=false;exit;end;
      sRight:=sList[i];
      delete(sRight,1,FhPos);        //'-'�ұߵ�����
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
  delete(SqlStr,1,1);//ɾ����һ���ַ���������
  SqlStr:='('+SqlStr+')';
  sList.Free;

  //=======��SqlStrת��ΪpSqlStr
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
//��ǿ�͵�Pos����,ȡ��subStr��Allstr�е�Times�γ��ֵ�λ�á�
//��ӥ��2006-2-23
var
  i,TempTimes: integer;
  TempAllStr : string;
  subStr,Allstr:string;
begin
  //==============��������ַ�ָ��ת��Ϊ�ַ������Է��㴦��
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
//�ҵ����ʽ��С����λ�������ֵ.��56.5*100+23.01��ֵΪ2
//�˺���������ڼ���ֵ�ľ�ȷλ��
var
  sCalaExp:string;
  DotPos,i,DotLen:integer;

  iTemp1,iTemp2:integer;
begin
  result:=0;

  sCalaExp:=strpas(ACalaExp);

  //������ʽ�е�trunc���� start
  //����56.5*100+23.01*trunc(59.6500003),��ɾ��trunc��'trunc(59.6500003)'
  //����д����֧��trunc������ֻ��һ������
  iTemp1:=pos('TRUNC(',uppercase(sCalaExp));
  while iTemp1>0 do
  begin    iTemp2:=pos(')',copy(sCalaExp,iTemp1,MaxInt));    delete(sCalaExp,iTemp1,iTemp2);    iTemp1:=pos('TRUNC(',uppercase(sCalaExp));  end;  //������ʽ�е�trunc���� stop
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
      DotLen:=i-DotPos;//�����(.)��ȫ��������
    end;
    
    if DotLen>result then result:=DotLen; 

    delete(sCalaExp,1,DotPos);
    DotPos:=pos('.',sCalaExp);
  end;
end;

function TryStrToFloatExt(const pSourStr:Pchar; var Value: Double): Boolean;stdcall;
//��ǿ�͵�TryStrToFloat����,����ȡ�ַ����е�һ����������������
//����StrTofloatExt(#$21+'-45.67'+'��')=-45.67
//����StrTofloatExt(#$21+'-.67'+'��')=-0.67
//��ӥ��2003-5-8
//2009-04-30 Value����single->double,ֻ��double��֧��RoundTo
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
      if i>=2 then if sourstr[i-1]='-' then ifFUSHU:=true;//�Ƿ���
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

  //С����λ��
  dotPos:=pos('.',sourstr);
  if dotPos>0 then dotWS:=length(sourstr)-dotPos else dotWS:=0;
  //==========
  
  if not TryStrToFloat(sourstr,Value) then exit;
  Value:=RoundTo(Value,dotWS*(-1));//С����λ��
  if ifFUSHU then Value:=Value*(-1);
  result:=true;
end;

function GetVersionLY(const AFileName:Pchar):Pchar;stdcall;
//��ȡ�ļ��İ汾��,��0.0.7.1
//��ӥ��2008-1-10
var 
  InfoSize, Wnd: DWORD; 
  VerBuf: Pointer; 
  szName: array[0..255] of Char; 
  Value: Pointer; 
  Len: UINT; 
  TransString,sResult:string;
begin 
  Result := nil;//Result := ''Ҳ��.��Ȼ��pchar����,����㻹�Ƿ���nil��
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
                                                        //^^^^^^^�˴�����ProductVersion�õ�����"��Ʒ�汾" 
        if VerQueryValue(VerBuf, szName, Value, Len) then
        begin
          sResult := strpas(pchar(Value));
          //=======��stringת��Ϊpchar
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
//ȡ��ϵͳ��ǰ���������뷨���� 
//��ӥ��2008-1-10
var 
  ImeNum:integer;//�������뷨����
  ImeIndex:integer;//��ǰ�������뷨������
  sResult:string;
begin
  Result := nil;
  ImeNum:=Screen.Imes.Count;
  ImeIndex:=Screen.Imes.IndexOfObject(Pointer(GetKeyboardLayout(0)));
  if(ImeIndex<0)or(ImeIndex>=ImeNum)then exit;
  sResult:=Screen.Imes.Strings[ImeIndex];
  
  //=======��stringת��Ϊpchar
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
//ȡ��ָ�����������к� 
//��ӥ��2008-1-10
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
  
  //=======��stringת��Ϊpchar
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

  //=======��stringת��Ϊpchar
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
//ʮ����ת��Ϊ�������ַ���
//add by ly 2009-08-31
var
  sResult: string;
begin
  if AInt=0 then begin sResult:='0';end;
  
  while AInt<>0 do
  begin          //i mod 2ȡģ,��ʹ��format��ʽ��
    sResult:=Format('%d'+sResult,[AInt mod 2]);
    AInt:=AInt div 2;
  end;

  //=======��stringת��Ϊpchar
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
//�������ַ�תʮ����
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
//��׼IEEE 754��������ʾ�������ڴ�С������ģʽ,��Ӧ�������ֲ���˳��
//��3���ֽ�,��4���ֽ�,��1���ֽ�,��2���ֽ�
//��4���ֽ�,��3���ֽ�,��2���ֽ�,��1���ֽ�
//����ת������:http://www.speedfly.cn/tools/hexconvert/
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
  //20110513��ʱ��֧�ָ�������֧�ִ�С������0.123
  //����:RealTo4Byte(34.678)='420AB646'
  //ByteToReal($42,$0A,$B6,$46)=34.678
  iReal:Integer;//��������
  fReal:single;//С������
  iBin:string;//�������ֵĶ�����
  fBin:string;//С�����ֵĶ�����
  i:integer;
  s1,s2:string;
  ss:string;//���Ķ�������
  sResult:string;
begin 
  if AReal=0 then begin result:='00000000';exit;end;

  iReal:=Trunc(AReal);
  fReal:=AReal-Trunc(AReal);
  
  iBin:=IntToBin(iReal);//�������ֵĶ�����

  s2:=rightstr('00000000'+IntToBin(127+length(iBin)-1),8);

  for i :=1 to 24-length(iBin) do
  begin
    if fReal<1/Power(2,i) then fBin:=fBin+'0'
    else begin
      fBin:=fBin+'1';
      fReal:=fReal-1/Power(2,i);
    end;
  end;
  
  ss:='0'+s2+copy(iBin,2,MaxInt)+fBin;//��ǰ���0�Ƿ���λ.0��ʾ����

  s1:=rightstr(ss,4);
  while length(s1)>0 do
  begin
    sResult:=InttoHex(BinToInt(Pchar(s1)),1)+sResult;
    delete(ss,length(ss)-4+1,4);
    s1:=rightstr(ss,4);
  end;
  
  //=======��stringת��Ϊpchar
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
//д��־�ļ�
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
//ȡ��ASubStr��ASourStr�����һ�γ��ֵ�λ��
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
//���ɷ���ʽ:sqrt(y)=a+b*sqrt(1/x)
//���ݴ����X,Yֵ����A,B
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

function Png2Bmp(const APngFile,ABmpFile:Pchar):boolean;stdcall;
var
  tmpPngFile,tmpBmpFile:string;

  tmpBmp:TBitmap;
  tmpPng:TPNGObject;  
begin
  result:=false;
  
  tmpPngFile:=strpas(APngFile);
  tmpBmpFile:=strpas(ABmpFile);

  if not FileExists(tmpPngFile) then exit;
  if uppercase(ExtractFileExt(tmpPngFile))<>'.PNG' THEN EXIT;
  if uppercase(ExtractFileExt(tmpBmpFile))<>'.BMP' THEN EXIT;
  
  tmpPng:= TPNGObject.Create;
  tmpBmp:= TBitmap.Create;
  try
    tmpPng.LoadFromFile(tmpPngFile);
    tmpBmp.Assign(tmpPng);
    tmpBmp.SaveToFile(tmpBmpFile);
    result:=true;
  finally
    FreeAndNil(tmpPng);
    FreeAndNil(tmpBmp);
  end;
end;

function CRC16(AStr:ShortString):ShortString;stdcall;
//��������Ϊ#$01#$00#$02����ʽ,�ʲ�����PChar
//����ֵ����Ϊ#$00#$EB����ʽ,�ʲ�����PChar
//ʹ��ShortString����String,��������ShareMem��Ԫ��BORLNDMM.DLL
//�ú���ʹ��ShortString����,��ֻ��Delphi����
//ShortString�������255���ַ�
var
  crc1,crc2,i,idx:byte;
begin
  crc1:=$ff;crc2:=$ff;
  for i:=1 to length(AStr) do
  begin
    idx:=crc2 xor ord(AStr[i]);
    crc2:=crc1 xor CRCL[idx];
    crc1:=CRCH[idx];
  end;
  result:=chr(crc2)+chr(crc1);
end;

//��ת�������������û�
procedure DES_Init(Key: TBlock; FCode: Boolean);
var
  n, h: Byte;
begin
  C[1] := Ord(Key[7] and 128 > 0); C[29] := Ord(Key[7] and 2 > 0);
  C[2] := Ord(Key[6] and 128 > 0); C[30] := Ord(Key[6] and 2 > 0);
  C[3] := Ord(Key[5] and 128 > 0); C[31] := Ord(Key[5] and 2 > 0);
  C[4] := Ord(Key[4] and 128 > 0); C[32] := Ord(Key[4] and 2 > 0);
  C[5] := Ord(Key[3] and 128 > 0); C[33] := Ord(Key[3] and 2 > 0);
  C[6] := Ord(Key[2] and 128 > 0); C[34] := Ord(Key[2] and 2 > 0);
  C[7] := Ord(Key[1] and 128 > 0); C[35] := Ord(Key[1] and 2 > 0);
  C[8] := Ord(Key[0] and 128 > 0); C[36] := Ord(Key[0] and 2 > 0);

  C[9] := Ord(Key[7] and 64 > 0); C[37] := Ord(Key[7] and 4 > 0);
  C[10] := Ord(Key[6] and 64 > 0); C[38] := Ord(Key[6] and 4 > 0);
  C[11] := Ord(Key[5] and 64 > 0); C[39] := Ord(Key[5] and 4 > 0);
  C[12] := Ord(Key[4] and 64 > 0); C[40] := Ord(Key[4] and 4 > 0);
  C[13] := Ord(Key[3] and 64 > 0); C[41] := Ord(Key[3] and 4 > 0);
  C[14] := Ord(Key[2] and 64 > 0); C[42] := Ord(Key[2] and 4 > 0);
  C[15] := Ord(Key[1] and 64 > 0); C[43] := Ord(Key[1] and 4 > 0);
  C[16] := Ord(Key[0] and 64 > 0); C[44] := Ord(Key[0] and 4 > 0);

  C[17] := Ord(Key[7] and 32 > 0); C[45] := Ord(Key[7] and 8 > 0);
  C[18] := Ord(Key[6] and 32 > 0); C[46] := Ord(Key[6] and 8 > 0);
  C[19] := Ord(Key[5] and 32 > 0); C[47] := Ord(Key[5] and 8 > 0);
  C[20] := Ord(Key[4] and 32 > 0); C[48] := Ord(Key[4] and 8 > 0);
  C[21] := Ord(Key[3] and 32 > 0); C[49] := Ord(Key[3] and 8 > 0);
  C[22] := Ord(Key[2] and 32 > 0); C[50] := Ord(Key[2] and 8 > 0);
  C[23] := Ord(Key[1] and 32 > 0); C[51] := Ord(Key[1] and 8 > 0);
  C[24] := Ord(Key[0] and 32 > 0); C[52] := Ord(Key[0] and 8 > 0);

  C[25] := Ord(Key[7] and 16 > 0); C[53] := Ord(Key[3] and 16 > 0);
  C[26] := Ord(Key[6] and 16 > 0); C[54] := Ord(Key[2] and 16 > 0);
  C[27] := Ord(Key[5] and 16 > 0); C[55] := Ord(Key[1] and 16 > 0);
  C[28] := Ord(Key[4] and 16 > 0); C[56] := Ord(Key[0] and 16 > 0);

  if FCode then
  begin
    for n := 1 to 16 do
    begin
      for h := 1 to 48 do
      begin
        G[n, h] := C[Sc[n, h]];
      end;
    end;
  end
  else
  begin
    for n := 1 to 16 do
    begin
      for h := 1 to 48 do
      begin
        G[17 - n, h] := C[Sc[n, h]];
      end;
    end;
  end;
end;

//�������8�ֽ����ݼ���/����
procedure DES_Code(Input: TBlock; var Output: TBlock);
var
  n: Byte;
  z: Word;
begin
  L[1] := Ord(Input[7] and 64 > 0); R[1] := Ord(Input[7] and 128 > 0);
  L[2] := Ord(Input[6] and 64 > 0); R[2] := Ord(Input[6] and 128 > 0);
  L[3] := Ord(Input[5] and 64 > 0); R[3] := Ord(Input[5] and 128 > 0);
  L[4] := Ord(Input[4] and 64 > 0); R[4] := Ord(Input[4] and 128 > 0);
  L[5] := Ord(Input[3] and 64 > 0); R[5] := Ord(Input[3] and 128 > 0);
  L[6] := Ord(Input[2] and 64 > 0); R[6] := Ord(Input[2] and 128 > 0);
  L[7] := Ord(Input[1] and 64 > 0); R[7] := Ord(Input[1] and 128 > 0);
  L[8] := Ord(Input[0] and 64 > 0); R[8] := Ord(Input[0] and 128 > 0);
  L[9] := Ord(Input[7] and 16 > 0); R[9] := Ord(Input[7] and 32 > 0);
  L[10] := Ord(Input[6] and 16 > 0); R[10] := Ord(Input[6] and 32 > 0);
  L[11] := Ord(Input[5] and 16 > 0); R[11] := Ord(Input[5] and 32 > 0);
  L[12] := Ord(Input[4] and 16 > 0); R[12] := Ord(Input[4] and 32 > 0);
  L[13] := Ord(Input[3] and 16 > 0); R[13] := Ord(Input[3] and 32 > 0);
  L[14] := Ord(Input[2] and 16 > 0); R[14] := Ord(Input[2] and 32 > 0);
  L[15] := Ord(Input[1] and 16 > 0); R[15] := Ord(Input[1] and 32 > 0);
  L[16] := Ord(Input[0] and 16 > 0); R[16] := Ord(Input[0] and 32 > 0);
  L[17] := Ord(Input[7] and 4 > 0); R[17] := Ord(Input[7] and 8 > 0);
  L[18] := Ord(Input[6] and 4 > 0); R[18] := Ord(Input[6] and 8 > 0);
  L[19] := Ord(Input[5] and 4 > 0); R[19] := Ord(Input[5] and 8 > 0);
  L[20] := Ord(Input[4] and 4 > 0); R[20] := Ord(Input[4] and 8 > 0);
  L[21] := Ord(Input[3] and 4 > 0); R[21] := Ord(Input[3] and 8 > 0);
  L[22] := Ord(Input[2] and 4 > 0); R[22] := Ord(Input[2] and 8 > 0);
  L[23] := Ord(Input[1] and 4 > 0); R[23] := Ord(Input[1] and 8 > 0);
  L[24] := Ord(Input[0] and 4 > 0); R[24] := Ord(Input[0] and 8 > 0);
  L[25] := Input[7] and 1; R[25] := Ord(Input[7] and 2 > 0);
  L[26] := Input[6] and 1; R[26] := Ord(Input[6] and 2 > 0);
  L[27] := Input[5] and 1; R[27] := Ord(Input[5] and 2 > 0);
  L[28] := Input[4] and 1; R[28] := Ord(Input[4] and 2 > 0);
  L[29] := Input[3] and 1; R[29] := Ord(Input[3] and 2 > 0);
  L[30] := Input[2] and 1; R[30] := Ord(Input[2] and 2 > 0);
  L[31] := Input[1] and 1; R[31] := Ord(Input[1] and 2 > 0);
  L[32] := Input[0] and 1; R[32] := Ord(Input[0] and 2 > 0);

  for n := 1 to 16 do
  begin
    z := ((R[32] xor G[n, 1]) shl 5) or ((R[5] xor G[n, 6]) shl 4)
      or ((R[1] xor G[n, 2]) shl 3) or ((R[2] xor G[n, 3]) shl 2)
      or ((R[3] xor G[n, 4]) shl 1) or (R[4] xor G[n, 5]);
    F[9] := L[9] xor SA1[z];
    F[17] := L[17] xor SB1[z];
    F[23] := L[23] xor SC1[z];
    F[31] := L[31] xor SD1[z];

    z := ((R[4] xor G[n, 7]) shl 5) or ((R[9] xor G[n, 12]) shl 4)
      or ((R[5] xor G[n, 8]) shl 3) or ((R[6] xor G[n, 9]) shl 2)
      or ((R[7] xor G[n, 10]) shl 1) or (R[8] xor G[n, 11]);
    F[13] := L[13] xor SA2[z];
    F[28] := L[28] xor SB2[z];
    F[2] := L[2] xor SC2[z];
    F[18] := L[18] xor SD2[z];

    z := ((R[8] xor G[n, 13]) shl 5) or ((R[13] xor G[n, 18]) shl 4)
      or ((R[9] xor G[n, 14]) shl 3) or ((R[10] xor G[n, 15]) shl 2)
      or ((R[11] xor G[n, 16]) shl 1) or (R[12] xor G[n, 17]);
    F[24] := L[24] xor SA3[z];
    F[16] := L[16] xor SB3[z];
    F[30] := L[30] xor SC3[z];
    F[6] := L[6] xor SD3[z];

    z := ((R[12] xor G[n, 19]) shl 5) or ((R[17] xor G[n, 24]) shl 4)
      or ((R[13] xor G[n, 20]) shl 3) or ((R[14] xor G[n, 21]) shl 2)
      or ((R[15] xor G[n, 22]) shl 1) or (R[16] xor G[n, 23]);
    F[26] := L[26] xor SA4[z];
    F[20] := L[20] xor SB4[z];
    F[10] := L[10] xor SC4[z];
    F[1] := L[1] xor SD4[z];

    z := ((R[16] xor G[n, 25]) shl 5) or ((R[21] xor G[n, 30]) shl 4)
      or ((R[17] xor G[n, 26]) shl 3) or ((R[18] xor G[n, 27]) shl 2)
      or ((R[19] xor G[n, 28]) shl 1) or (R[20] xor G[n, 29]);
    F[8] := L[8] xor SA5[z];
    F[14] := L[14] xor SB5[z];
    F[25] := L[25] xor SC5[z];
    F[3] := L[3] xor SD5[z];

    z := ((R[20] xor G[n, 31]) shl 5) or ((R[25] xor G[n, 36]) shl 4)
      or ((R[21] xor G[n, 32]) shl 3) or ((R[22] xor G[n, 33]) shl 2)
      or ((R[23] xor G[n, 34]) shl 1) or (R[24] xor G[n, 35]);
    F[4] := L[4] xor SA6[z];
    F[29] := L[29] xor SB6[z];
    F[11] := L[11] xor SC6[z];
    F[19] := L[19] xor SD6[z];

    z := ((R[24] xor G[n, 37]) shl 5) or ((R[29] xor G[n, 42]) shl 4)
      or ((R[25] xor G[n, 38]) shl 3) or ((R[26] xor G[n, 39]) shl 2)
      or ((R[27] xor G[n, 40]) shl 1) or (R[28] xor G[n, 41]);
    F[32] := L[32] xor SA7[z];
    F[12] := L[12] xor SB7[z];
    F[22] := L[22] xor SC7[z];
    F[7] := L[7] xor SD7[z];

    z := ((R[28] xor G[n, 43]) shl 5) or ((R[1] xor G[n, 48]) shl 4)
      or ((R[29] xor G[n, 44]) shl 3) or ((R[30] xor G[n, 45]) shl 2)
      or ((R[31] xor G[n, 46]) shl 1) or (R[32] xor G[n, 47]);
    F[5] := L[5] xor SA8[z];
    F[27] := L[27] xor SB8[z];
    F[15] := L[15] xor SC8[z];
    F[21] := L[21] xor SD8[z];

    L := R;
    R := F;
  end;

  Output[0] := (L[8] shl 7) or (R[8] shl 6) or (L[16] shl 5) or (R[16] shl 4)
    or (L[24] shl 3) or (R[24] shl 2) or (L[32] shl 1) or R[32];
  Output[1] := (L[7] shl 7) or (R[7] shl 6) or (L[15] shl 5) or (R[15] shl 4)
    or (L[23] shl 3) or (R[23] shl 2) or (L[31] shl 1) or R[31];
  Output[2] := (L[6] shl 7) or (R[6] shl 6) or (L[14] shl 5) or (R[14] shl 4)
    or (L[22] shl 3) or (R[22] shl 2) or (L[30] shl 1) or R[30];
  Output[3] := (L[5] shl 7) or (R[5] shl 6) or (L[13] shl 5) or (R[13] shl 4)
    or (L[21] shl 3) or (R[21] shl 2) or (L[29] shl 1) or R[29];
  Output[4] := (L[4] shl 7) or (R[4] shl 6) or (L[12] shl 5) or (R[12] shl 4)
    or (L[20] shl 3) or (R[20] shl 2) or (L[28] shl 1) or R[28];
  Output[5] := (L[3] shl 7) or (R[3] shl 6) or (L[11] shl 5) or (R[11] shl 4)
    or (L[19] shl 3) or (R[19] shl 2) or (L[27] shl 1) or R[27];
  Output[6] := (L[2] shl 7) or (R[2] shl 6) or (L[10] shl 5) or (R[10] shl 4)
    or (L[18] shl 3) or (R[18] shl 2) or (L[26] shl 1) or R[26];
  Output[7] := (L[1] shl 7) or (R[1] shl 6) or (L[9] shl 5) or (R[9] shl 4)
    or (L[17] shl 3) or (R[17] shl 2) or (L[25] shl 1) or R[25];
end;

//������ת����8�ֽڵ�����
function StrToKey(aKey: Pchar): TBlock;
var
  Key: TBlock;
  I: Integer;
begin
  FillChar(Key, SizeOf(TBlock), 0);
  for I := 1 to Length(aKey) do
  begin
    Key[I mod SizeOf(TBlock)] := Key[I mod SizeOf(TBlock)] + Ord(aKey[I-1]);
  end;
  result := Key;
end;

//�����ַ���
function EnCryptStr(aStr: Pchar; aKey: Pchar): Pchar;stdcall;
var
  ReadBuf: TBlock;
  WriteBuf: TBlock;
  Key: TBlock;
  Count: Integer;
  Offset: Integer;
  I,aStrLen: Integer;
  S: string;
  asStr:string;
  rStr:string;
begin
  Key := StrToKey(aKey);
  Des_Init(Key, True);
  Offset := 1;
  Count := Length(aStr);
  aStrLen:=length(aStr);
  setlength(asStr,aStrLen);
  for i:=1 to aStrLen do asStr[i]:=aStr[i-1];
  repeat
    S := Copy(asStr, Offset, 8);
    FillChar(ReadBuf, 8, 0);
    Move(S[1], ReadBuf, Length(S));
    Des_Code(ReadBuf, WriteBuf);
    for I := 0 to 7 do
    begin
      rStr := rStr + IntToHex(WriteBuf[I], 2);
      result:=pchar(rStr);
    end;
    Offset := Offset + 8;
  until Offset > ((Count + 7) div 8) * 8;
end;

//�����ַ���
function DeCryptStr(aStr: Pchar; aKey: Pchar): Pchar;stdcall;
var
  ReadBuf,
  WriteBuf: TBlock;
  Key: TBlock;
  Offset: Integer;
  Count: Integer;
  I: Integer;
  S: string;
  asStr:string;
  aStrLen:integer;
  rStr:string;
begin
  try
    Key := StrToKey(aKey);
    Des_Init(Key, False);
    aStrLen:=length(aStr);
    setlength(asStr,aStrLen);
    for i:=1 to aStrLen do asStr[i]:=aStr[i-1];
    S := '';
    I := 1;
    repeat
      S := S + Chr(StrToInt('$' + Copy(asStr, I, 2)));
      Inc(I, 2);
    until I > Length(asStr);
    Offset := 1;
    Count := Length(S);
    while Offset < ((Count + 7) div 8 * 8) do
    begin
      FillChar(ReadBuf, 8, 0);
      Move(S[Offset], ReadBuf, 8);
      Des_Code(ReadBuf, WriteBuf);

      for I := 0 to 7 do
      begin
        rStr := rStr + Chr(WriteBuf[I]);
      end;
      Offset := Offset + 8;
    end;
    result:=pchar(rStr);
  except
    result := '';
  end;
end;

function BcdToStr(const AByte:byte):Pchar;stdcall;
//��BCD�����1���ֽ�ת��Ϊ2���ַ����ַ���
//BCD(Binary-Coded Decimal),��4λ������������ʾ1λʮ�������е�0~9��10������
//��:���BCD��40,������Ϊ0010 1000,������0010��ʮ����Ϊ2,������1000��ʮ����Ϊ8,��BCD��40��ʾ28(����)
begin
  Result:=AllocMem(3);//�����ڴ�ռ䲢�Զ���ʼ��Ϊ#0
  Result[0]:=chr($30+AByte shr 4);
  Result[1]:=chr($30+AByte and $0F);
  //FreeMem();//AllocMem�����ڴ�,һ��Ϊ˵��Ҫ�ͷ�!������ֵΪpchar,��ô�ͷ���?
end;

{
ASCII:1���ֽ�,��ʾ���ַ�������
ANSI:��ͬ���Һ͵����ƶ���ͬ�ı�׼���ڱ�ʾ�Լ�������,��Щʹ�ö��ֽ�������һ���ַ��ĸ���������뷽ʽ,��ΪANSI����.���й������GB2312��GBK,̨�嶨���Big5,�ձ������JIS�ȵ�
Ϊ����ÿ�����Ҷ���һ���Լ��ı������,ISO������Unicode
Unicode:ÿ���ַ�����ʹ��2���ֽ�.ȱ��:Unicode��������ʱ�˷Ѵ���,�洢����ʱ�˷�Ӳ��
����,�й���Unicode��ʾ\u4e2d\u56fd,����\u��ʾ16����

�ú����������ǽ��ַ�����\u��ʾ��Unicode����ת��Ϊ�ַ�,�������ֲ���
����,����:�й�abc\u4e2d\u56fd
���:�й�abc�й�
}
function UnicodeToChinese(const AUnicodeStr:PChar):PChar;stdcall;
var
  index: Integer;
  temp, top, sStr, sResult: String;
begin
  sResult:='';
  sStr:=AUnicodeStr;

  index := Pos('\u', sStr);
  while index > 0 do
  begin
    top := Copy(sStr, 1, index-1);//ȡ�������ַ�ǰ�ķ�Unicode������ַ��������֡���ĸ��
    temp := Copy(sStr, index+2, 4);//ȡ�����룬������\u,��4e2d
    Delete(sStr, 1, index + 5);
    sResult := sResult + top + WideChar(StrToInt('$' + temp));
     
    index := Pos('\u', sStr);
  end;
  sResult:=sResult+sStr;
  
  //=======��stringת��Ϊpchar
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

Exports
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
Gif2Bmp,
Png2Bmp,
CRC16,
EnCryptStr,
DeCryptStr,
BcdToStr,
UnicodeToChinese;

begin
end.
 