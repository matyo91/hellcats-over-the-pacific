typedef unsigned char   undefined;

typedef unsigned int    uint;
typedef unsigned char    undefined1;
typedef unsigned short    undefined2;
typedef unsigned int    undefined4;
typedef unsigned short    ushort;
typedef unsigned char    byte;



// WARNING: Control flow encountered bad instruction data

void FUN_00000006(void)

{
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_000000c8(undefined2 *param_1,short *param_2,short *param_3,undefined2 *param_4,
                 undefined2 *param_5)

{
  int unaff_A5;
  undefined1 auStack_14 [2];
  undefined2 local_12;
  char local_b;
  
  (**(code **)(unaff_A5 + 0x1f2))((short)auStack_14,0);
  *param_1 = local_12;
  if (local_b != '\0') {
                    // WARNING: Bad instruction - Truncating control flow here
    halt_baddata();
  }
  *param_2 = *(short *)(unaff_A5 + -0x167a) - *(short *)(unaff_A5 + -0x167e);
  *param_3 = *(short *)(unaff_A5 + -0x167c) - *(short *)(unaff_A5 + -0x1680);
  *param_4 = 1;
  *param_5 = 0;
  return;
}



// WARNING: Control flow encountered bad instruction data

void FUN_00000160(undefined4 *param_1,undefined4 *param_2)

{
  *param_1 = 0;
  *param_2 = 0;
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_000001bc(void)

{
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_00000214(undefined4 *param_1,undefined4 *param_2)

{
  *param_1 = 0;
  *param_2 = 0;
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_00000270(void)

{
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_000002c8(void)

{
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_000004e4(void)

{
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_00000560(void)

{
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



uint FUN_00000728(void)

{
  int unaff_A5;
  
  *(int *)(unaff_A5 + -0x6c) = *(int *)(unaff_A5 + -0x6c) * 0x41c64e6d + 0x3039;
  return (uint)(*(int *)(unaff_A5 + -0x6c) << 1) >> 0x11;
}



void FUN_00000746(undefined4 param_1)

{
  int unaff_A5;
  
  *(undefined4 *)(unaff_A5 + -0x6c) = param_1;
  return;
}



int FUN_00000754(char *param_1,int param_2)

{
  int iVar1;
  short local_a;
  
  param_1 = param_1 + 6;
  iVar1 = 0;
  for (local_a = 0; local_a < 6; local_a = local_a + 1) {
    param_1 = param_1 + -1;
    *param_1 = (char)(param_2 % 0x1a) + 'A';
    iVar1 = param_2 / 0x1a;
    param_2 = iVar1;
  }
  param_1[6] = '\0';
  return iVar1;
}



int FUN_000007a8(int param_1,int *param_2)

{
  int iVar1;
  undefined2 local_a;
  undefined4 local_8;
  
  local_8 = 0;
  iVar1 = 0;
  for (local_a = 0; local_a < 6; local_a = local_a + 1) {
    iVar1 = (int)(short)(*(char *)(param_1 + local_a) + -0x41);
    local_8 = iVar1 + local_8 * 0x1a;
  }
  *param_2 = local_8;
  return iVar1;
}



void FUN_000007f6(int param_1,uint param_2)

{
  undefined1 *puVar1;
  uint uVar2;
  int unaff_A5;
  undefined2 local_6;
  
  for (local_6 = 0; (param_1 != 0 && (local_6 < 0xc)); local_6 = local_6 + 1) {
    uVar2 = FUN_00000728();
    puVar1 = (undefined1 *)(param_1 + (uVar2 & 0xffff) % param_2);
    *(undefined1 **)(local_6 * 6 + unaff_A5 + -0xb4) = puVar1;
    *(undefined1 *)(local_6 * 6 + unaff_A5 + -0xb0) = *puVar1;
    *puVar1 = 0xff;
  }
  return;
}



void FUN_0000085e(void)

{
  short sVar1;
  bool bVar2;
  int unaff_A5;
  undefined2 local_6;
  
  if ((*(short *)(unaff_A5 + -0xbc) == 0) && (*(int *)(unaff_A5 + -0xc0) == 0)) {
    bVar2 = false;
  }
  else {
    bVar2 = true;
  }
  if (bVar2) {
    local_6 = 0xc;
    while (sVar1 = local_6 + -1, 0 < local_6) {
      **(undefined1 **)(sVar1 * 6 + unaff_A5 + -0xb4) =
           *(undefined1 *)(sVar1 * 6 + unaff_A5 + -0xb0);
      local_6 = sVar1;
    }
  }
  return;
}


/*
Unable to decompile 'FUN_000008b8'
Cause: 
Low-level Error: Cannot properly adjust input varnodes
*/


void FUN_000008d6(undefined2 *param_1,undefined2 *param_2,undefined2 *param_3)

{
  uint uVar1;
  short sVar2;
  int unaff_A5;
  
  uVar1 = FUN_00000728();
  sVar2 = (short)((uVar1 & 0xffff) % (uint)*(ushort *)(unaff_A5 + -0xb6));
  *param_1 = *(undefined2 *)(*(int *)(unaff_A5 + -0xba) + sVar2 * 0xc + 6);
  *param_2 = *(undefined2 *)(*(int *)(unaff_A5 + -0xba) + sVar2 * 0xc + 8);
  *param_3 = *(undefined2 *)(*(int *)(unaff_A5 + -0xba) + sVar2 * 0xc + 10);
  return;
}



undefined4 FUN_00000934(int param_1,int param_2)

{
  int iVar1;
  
  iVar1 = (int)*(char *)(param_2 + 5) + *(char *)(param_2 + 4) * 0x14;
  return CONCAT22((short)((uint)iVar1 >> 0x10),(short)(iVar1 == param_1));
}


/*
Unable to decompile 'FUN_00000964'
Cause: 
Low-level Error: Cannot properly adjust input varnodes
*/


uint FUN_00000a62(void)

{
  uint uVar1;
  uint uVar2;
  
  uVar1 = FUN_00000728();
  uVar2 = FUN_00000728();
  return (uVar1 & 0xfff) << 0x10 | uVar2 & 0xffff;
}



int FUN_00000a90(undefined4 param_1,undefined4 param_2,undefined4 param_3)

{
  int unaff_A5;
  
  param_3._0_2_ = param_3._0_2_ / 0x200;
  if (0x20 < param_3._0_2_) {
    param_3._0_2_ = 0x20;
  }
  FUN_00000754((char *)(unaff_A5 + -0x68),
               ((int)param_3._0_2_ |
               (int)(short)(param_2._2_2_ / 4 << 5 |
                           param_2._0_2_ / 0x80 << 8 | param_1._2_2_ / 0x80 << 0xc) |
               (int)param_1._0_2_ << 0x10) & 0xfffffff);
  return unaff_A5 + -0x68;
}



void FUN_00000b10(int param_1,undefined2 *param_2,undefined2 *param_3,undefined2 *param_4,
                 undefined2 *param_5,ushort *param_6)

{
  int local_8;
  
  FUN_000007a8(param_1,&local_8);
  *param_2 = (short)((uint)local_8 >> 0x10);
  *param_3 = (short)((local_8 >> 0xc & 0xfU) << 7);
  *param_4 = (short)((local_8 >> 8 & 0xfU) << 7);
  *param_5 = (short)((local_8 >> 5 & 7U) << 2);
  *param_6 = (ushort)local_8 & 0x1f;
  return;
}



int FUN_00000b84(uint param_1)

{
  int unaff_A5;
  
  FUN_00000754((char *)(unaff_A5 + -0x54),param_1 & 0xfffffff);
  return unaff_A5 + -0x54;
}



int FUN_00000ba8(int param_1)

{
  int local_8;
  
  FUN_000007a8(param_1,&local_8);
  return local_8;
}



int FUN_00000bc2(int param_1)

{
  int unaff_A5;
  
  FUN_00000754((char *)(unaff_A5 + -0x40),param_1);
  return unaff_A5 + -0x40;
}



int FUN_00000bde(int param_1)

{
  int local_8;
  
  FUN_000007a8(param_1,&local_8);
  return local_8;
}


