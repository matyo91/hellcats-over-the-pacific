typedef unsigned char   undefined;

typedef unsigned char    byte;
typedef unsigned char    undefined1;
typedef unsigned short    undefined2;
typedef unsigned int    undefined4;


ushort DAT_0000028e;
undefined DAT_00000b22;
char DAT_0000021e;
char DAT_00000291;
byte DAT_000001fb;
int DAT_000002dc;
undefined2 DAT_00000210;
undefined DAT_000003f6;
undefined DAT_00000a58;
char DAT_216e0017;
char DAT_216e0016;
undefined DAT_00000059;

// WARNING: Control flow encountered bad instruction data
// WARNING: Removing unreachable block (ram,0x000000cc)
// WARNING: Globals starting with '_' overlap smaller symbols at the same address

void FUN_00000048(undefined2 *param_1)

{
  undefined1 *puVar1;
  short sVar2;
  undefined2 *puVar3;
  char *pcVar4;
  undefined1 *puVar5;
  code *UNRECOVERED_JUMPTABLE;
  undefined2 uStack0000000a;
  
  sVar2 = 7;
  puVar3 = param_1;
  do {
    *puVar3 = 0;
    sVar2 = sVar2 + -1;
    puVar3 = puVar3 + 1;
  } while (sVar2 != -1);
  *param_1 = 1;
  param_1[1] = 0xfffe;
  if (DAT_216e0017 != -1) {
    if (DAT_216e0016 < '\x01') {
      param_1[1] = 0xffff;
      if ((-1 < (short)DAT_0000028e) && (param_1[1] = 1, (short)_DAT_00000b22 < 0)) {
        param_1[1] = 2;
      }
    }
    else {
      param_1[1] = 0;
      if (DAT_216e0016 < '\x03') {
        if (DAT_216e0016 == '\x02') {
          param_1[1] = 3;
        }
        else {
          param_1[1] = 4;
        }
      }
    }
  }
  param_1[2] = 0;
  if ((-1 < (short)DAT_0000028e) && ((_DAT_00000b22 & 0x1000) != 0)) {
    *(undefined1 *)(param_1 + 4) = 1;
  }
  if (DAT_0000028e < 0x4000) {
    *(undefined1 *)((int)param_1 + 9) = 1;
  }
  pcVar4 = &DAT_00000059;
  sVar2 = 4;
  do {
    pcVar4 = pcVar4 + -1;
    if (DAT_0000021e == *pcVar4) break;
    sVar2 = sVar2 + -1;
  } while (sVar2 != -1);
  param_1[5] = sVar2 + 1;
  if ((-1 < DAT_00000291) && ((DAT_000001fb & 0xf) == 1)) {
    *(undefined1 *)((int)param_1 + 0xd) = *(undefined1 *)(DAT_000002dc + 7);
  }
  param_1[7] = DAT_00000210;
  if (-1 < _DAT_000003f6) {
    param_1[7] = 0;
    sVar2 = 0x3c;
    puVar1 = (undefined1 *)register0x0000003c;
    do {
      puVar5 = puVar1;
      *(undefined2 *)(puVar5 + -2) = 0;
      sVar2 = sVar2 + -1;
      puVar1 = puVar5 + -2;
    } while (sVar2 != -1);
    *(undefined2 *)(puVar5 + 0x16) = _DAT_00000a58;
                    // WARNING: Bad instruction - Truncating control flow here
    halt_baddata();
  }
  uStack0000000a = 0xea84;
                    // WARNING: Could not recover jumptable at 0x00000188. Too many branches
                    // WARNING: Treating indirect jump as call
  (*UNRECOVERED_JUMPTABLE)();
  return;
}



// WARNING: Control flow encountered bad instruction data

void FUN_000002a6(void)

{
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_000003c2(void)

{
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



byte * FUN_00000432(byte *param_1)

{
  ushort uVar1;
  byte *pbVar2;
  
  uVar1 = (ushort)*param_1;
  pbVar2 = param_1;
  while (uVar1 = uVar1 - 1, uVar1 != 0xffff) {
    *pbVar2 = pbVar2[1];
    pbVar2 = pbVar2 + 1;
  }
  *pbVar2 = 0;
  return param_1;
}


