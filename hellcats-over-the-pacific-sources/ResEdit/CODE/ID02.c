typedef unsigned char   undefined;

typedef unsigned char    byte;
typedef unsigned int    uint;
typedef unsigned char    undefined1;
typedef unsigned short    undefined2;
typedef unsigned int    undefined4;
typedef unsigned long long    undefined8;
typedef unsigned short    ushort;


int DAT_00000904;
undefined4 DAT_00000904;
short DAT_00000baa;
int DAT_000039c4;
undefined DAT_66fa4e75;
undefined1 DAT_66fa4e77;
undefined DAT_66fa4e79;
int DAT_00003aca;
undefined DAT_66fa4e7b;
int DAT_00003be0;
char DAT_66fa4e77;
undefined FUN_00000196;
undefined2 DAT_00000baa;

int FUN_0000001e(int param_1)

{
  if (param_1 < 0) {
    param_1 = -param_1;
  }
  return param_1;
}



void FUN_00000038(undefined4 *param_1,undefined4 param_2)

{
  undefined4 local_8;
  
  local_8 = CONCAT22(param_2._0_2_ / param_2._2_2_,param_2._0_2_ % param_2._2_2_);
  *param_1 = local_8;
  return;
}



void FUN_00000066(undefined4 *param_1,undefined4 param_2,undefined4 param_3)

{
  undefined4 uVar1;
  undefined4 uVar2;
  int unaff_A5;
  
  uVar1 = (**(code **)(unaff_A5 + 0x5a))(param_2,param_3);
  uVar2 = (**(code **)(unaff_A5 + 0x62))(param_2,param_3);
  *param_1 = uVar1;
  param_1[1] = uVar2;
  return;
}



ushort FUN_0000009a(undefined4 param_1)

{
  int unaff_A5;
  
  return (short)*(char *)((int)(short)(ushort)param_1._1_1_ + unaff_A5 + -0x1608) & 0xd0;
}



ushort FUN_000000b6(undefined4 param_1)

{
  int unaff_A5;
  
  return (short)*(char *)((int)(short)(ushort)param_1._1_1_ + unaff_A5 + -0x1608) & 0xc0;
}



byte FUN_000000d2(undefined4 param_1)

{
  int unaff_A5;
  
  return *(byte *)((int)(short)(ushort)param_1._1_1_ + unaff_A5 + -0x1608) & 3;
}



byte FUN_000000ee(undefined4 param_1)

{
  int unaff_A5;
  
  return *(byte *)((int)(short)(ushort)param_1._1_1_ + unaff_A5 + -0x1608) & 0x10;
}



ushort FUN_0000010a(undefined4 param_1)

{
  int unaff_A5;
  
  return (short)*(char *)((int)(short)(ushort)param_1._1_1_ + unaff_A5 + -0x1608) & 0xd8;
}



ushort FUN_00000126(undefined4 param_1)

{
  int unaff_A5;
  
  return (short)*(char *)((int)(short)(ushort)param_1._1_1_ + unaff_A5 + -0x1608) & 0x80;
}



ushort FUN_00000142(undefined4 param_1)

{
  int unaff_A5;
  
  return (short)*(char *)((int)(short)(ushort)param_1._1_1_ + unaff_A5 + -0x1608) & 0xdc;
}



byte FUN_0000015e(undefined4 param_1)

{
  int unaff_A5;
  
  return *(byte *)((int)(short)(ushort)param_1._1_1_ + unaff_A5 + -0x1608) & 8;
}



byte FUN_0000017a(undefined4 param_1)

{
  int unaff_A5;
  
  return *(byte *)((int)(short)(ushort)param_1._1_1_ + unaff_A5 + -0x1608) & 6;
}



byte FUN_00000196(undefined4 param_1)

{
  int unaff_A5;
  
  return *(byte *)((int)(short)(ushort)param_1._1_1_ + unaff_A5 + -0x1608) & 0x40;
}



byte FUN_000001b2(undefined4 param_1)

{
  int unaff_A5;
  
  return *(byte *)((int)(short)(ushort)param_1._1_1_ + unaff_A5 + -0x1608) & 0x30;
}



ushort FUN_000001ce(undefined4 param_1)

{
  ushort uVar1;
  int unaff_A5;
  
  uVar1 = (ushort)param_1._1_1_;
  if (((short)*(char *)((int)(short)uVar1 + unaff_A5 + -0x1608) & 0x80U) != 0) {
    param_1._0_2_ = param_1._0_2_ ^ 0x20;
  }
  return param_1._0_2_;
}



ushort FUN_00000200(undefined4 param_1)

{
  ushort uVar1;
  int unaff_A5;
  
  uVar1 = (ushort)param_1._1_1_;
  if ((*(byte *)((int)(short)uVar1 + unaff_A5 + -0x1608) & 0x40) != 0) {
    param_1._0_2_ = param_1._0_2_ ^ 0x20;
  }
  return param_1._0_2_;
}



void FUN_00000232(undefined1 *param_1,undefined1 *param_2,int param_3)

{
  for (; param_3 != 0; param_3 = param_3 + -1) {
    *param_1 = *param_2;
    param_1 = param_1 + 1;
    param_2 = param_2 + 1;
  }
  return;
}



void FUN_0000024a(undefined1 *param_1,undefined1 *param_2,int param_3)

{
  undefined1 *puVar1;
  undefined1 *puVar2;
  
  if (param_3 != 0) {
    if (param_2 <= param_1) {
      puVar1 = param_1 + param_3;
      puVar2 = param_2 + param_3;
      do {
        puVar2 = puVar2 + -1;
        puVar1 = puVar1 + -1;
        *puVar1 = *puVar2;
        param_3 = param_3 + -1;
      } while (param_3 != 0);
      return;
    }
    do {
      *param_1 = *param_2;
      param_3 = param_3 + -1;
      param_1 = param_1 + 1;
      param_2 = param_2 + 1;
    } while (param_3 != 0);
  }
  return;
}


/*
Unable to decompile 'FUN_000002b0'
Cause: 
Low-level Error: Cannot properly adjust input varnodes
*/


char * FUN_000002c8(char *param_1,char *param_2)

{
  char cVar1;
  char *pcVar2;
  
  pcVar2 = param_1;
  do {
    cVar1 = *param_2;
    *pcVar2 = cVar1;
    pcVar2 = pcVar2 + 1;
    param_2 = param_2 + 1;
  } while (cVar1 != '\0');
  return param_1;
}



char * FUN_000002d8(char *param_1,char *param_2)

{
  char cVar1;
  char *pcVar2;
  char *pcVar3;
  
  pcVar2 = param_1;
  do {
    pcVar3 = pcVar2;
    pcVar2 = pcVar3 + 1;
  } while (*pcVar3 != '\0');
  do {
    cVar1 = *param_2;
    *pcVar3 = cVar1;
    pcVar3 = pcVar3 + 1;
    param_2 = param_2 + 1;
  } while (cVar1 != '\0');
  return param_1;
}



int FUN_000002ee(byte *param_1,byte *param_2)

{
  byte bVar1;
  int iVar2;
  
  iVar2 = 0;
  do {
    bVar1 = *param_1;
    if (bVar1 != *param_2) {
      if (bVar1 < *param_2) {
        iVar2 = -2;
      }
      return iVar2 + 1;
    }
    param_1 = param_1 + 1;
    param_2 = param_2 + 1;
  } while (bVar1 != 0);
  return 0;
}



char * FUN_0000030c(char *param_1,undefined4 param_2)

{
  char cVar1;
  
  do {
    if ((char)((uint)param_2 >> 0x10) == *param_1) {
      return param_1;
    }
    cVar1 = *param_1;
    param_1 = param_1 + 1;
  } while (cVar1 != '\0');
  return (char *)0x0;
}



int FUN_00000324(char *param_1,char *param_2)

{
  char cVar1;
  char cVar2;
  int iVar3;
  char *pcVar4;
  char *pcVar5;
  
  iVar3 = -1;
  do {
    iVar3 = iVar3 + 1;
    pcVar4 = param_1 + 1;
    cVar1 = *param_1;
    pcVar5 = param_2;
    if (cVar1 == '\0') {
      return iVar3;
    }
    while( true ) {
      cVar2 = *pcVar5;
      param_1 = pcVar4;
      if (cVar2 == '\0') break;
      pcVar5 = pcVar5 + 1;
      if (cVar2 == cVar1) {
        return iVar3;
      }
    }
  } while( true );
}



char * FUN_0000033e(char *param_1,char *param_2)

{
  char cVar1;
  char *pcVar2;
  char *pcVar3;
  
  do {
    pcVar2 = param_1;
    pcVar3 = param_2;
    if (*pcVar2 == '\0') {
      return (char *)0x0;
    }
    while( true ) {
      cVar1 = *pcVar3;
      param_1 = pcVar2 + 1;
      if (cVar1 == '\0') break;
      pcVar3 = pcVar3 + 1;
      if (cVar1 == *pcVar2) {
        return pcVar2;
      }
    }
  } while( true );
}



char * FUN_0000035a(char *param_1,undefined4 param_2)

{
  char cVar1;
  char *pcVar2;
  
  pcVar2 = (char *)0x0;
  do {
    if ((char)((uint)param_2 >> 0x10) == *param_1) {
      pcVar2 = param_1;
    }
    cVar1 = *param_1;
    param_1 = param_1 + 1;
  } while (cVar1 != '\0');
  return pcVar2;
}



int FUN_00000370(char *param_1,char *param_2)

{
  char cVar1;
  int iVar2;
  char *pcVar3;
  
  iVar2 = 0;
  do {
    pcVar3 = param_2;
    if (*param_1 == '\0') {
      return iVar2;
    }
    do {
      cVar1 = *pcVar3;
      if (cVar1 == '\0') {
        return iVar2;
      }
      pcVar3 = pcVar3 + 1;
    } while (cVar1 != *param_1);
    iVar2 = iVar2 + 1;
    param_1 = param_1 + 1;
  } while( true );
}



char * FUN_0000038c(char *param_1,char *param_2)

{
  char cVar1;
  char cVar2;
  char *pcVar3;
  char *pcVar4;
  
  pcVar4 = param_2;
  pcVar3 = param_1;
  while( true ) {
    cVar1 = *pcVar4;
    if (cVar1 == '\0') {
      return pcVar3;
    }
    cVar2 = *param_1;
    if (cVar2 == '\0') break;
    param_1 = param_1 + 1;
    pcVar4 = pcVar4 + 1;
    if (cVar2 != cVar1) {
      param_1 = pcVar3 + 1;
      pcVar4 = param_2;
      pcVar3 = param_1;
    }
  }
  return (char *)0x0;
}



char * FUN_000003aa(char *param_1,char *param_2)

{
  char cVar1;
  char *pcVar2;
  char *pcVar3;
  char *pcVar4;
  char *pcVar5;
  int unaff_A5;
  
  if (param_1 != (char *)0x0) goto LAB_000003b6;
  do {
    param_1 = *(char **)(unaff_A5 + -0x1508);
    if (param_1 == (char *)0x0) {
      return (char *)0x0;
    }
LAB_000003b6:
    *(undefined4 *)(unaff_A5 + -0x1508) = 0;
    while( true ) {
      pcVar3 = param_1;
      pcVar5 = param_2;
      if (*pcVar3 == '\0') break;
      do {
        cVar1 = *pcVar5;
        pcVar2 = pcVar3 + 1;
        if (cVar1 == '\0') {
          do {
            pcVar4 = pcVar2;
            pcVar5 = param_2;
            if (*pcVar4 == '\0') {
              return pcVar3;
            }
            while( true ) {
              cVar1 = *pcVar5;
              pcVar2 = pcVar4 + 1;
              if (cVar1 == '\0') break;
              pcVar5 = pcVar5 + 1;
              if (cVar1 == *pcVar4) {
                *(char **)(unaff_A5 + -0x1508) = pcVar4 + 1;
                *pcVar4 = '\0';
                return pcVar3;
              }
            }
          } while( true );
        }
        param_1 = pcVar3 + 1;
        pcVar5 = pcVar5 + 1;
      } while (cVar1 != *pcVar3);
    }
  } while( true );
}



void FUN_000003f6(char *param_1,char *param_2,int param_3)

{
  char cVar1;
  
  for (; param_3 != 0; param_3 = param_3 + -1) {
    cVar1 = *param_2;
    *param_1 = cVar1;
    if (cVar1 != '\0') {
      param_2 = param_2 + 1;
    }
    param_1 = param_1 + 1;
  }
  return;
}



void FUN_00000412(char *param_1,char *param_2,int param_3)

{
  char cVar1;
  char *pcVar2;
  char *pcVar3;
  
  if (param_3 != 0) {
    do {
      pcVar3 = param_1;
      param_1 = pcVar3 + 1;
    } while (*pcVar3 != '\0');
    do {
      cVar1 = *param_2;
      pcVar2 = pcVar3 + 1;
      *pcVar3 = cVar1;
      if (cVar1 == '\0') {
        return;
      }
      param_3 = param_3 + -1;
      pcVar3 = pcVar2;
      param_2 = param_2 + 1;
    } while (param_3 != 0);
    *pcVar2 = '\0';
  }
  return;
}



// WARNING: Control flow encountered bad instruction data

void FUN_0000045a(void)

{
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



undefined4 * FUN_000004c6(void)

{
  undefined4 *puVar1;
  int unaff_A5;
  undefined4 **ppuVar2;
  undefined4 *local_c;
  undefined4 local_8;
  
  local_8 = 0;
  local_c = (undefined4 *)0x0;
  (**(code **)(unaff_A5 + 0x212))();
  ppuVar2 = (undefined4 **)&local_8;
  puVar1 = local_c;
  if ((int)local_c < 500000) {
    local_c = (undefined4 *)0x0;
    puVar1 = &local_8;
    (**(code **)(unaff_A5 + 0x21a))();
    ppuVar2 = &local_c;
  }
  if (*(short *)(unaff_A5 + -0x12ee) != 0) {
    *(undefined4 *)((int)ppuVar2 + -4) = 0;
    *(undefined4 *)((int)ppuVar2 + -8) = 0x4f6;
    puVar1 = (undefined4 *)FUN_00003dd0(*(int *)((int)ppuVar2 + -4));
  }
  return puVar1;
}



// WARNING: Control flow encountered bad instruction data

void FUN_000004fc(void)

{
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



void FUN_00000930(undefined4 param_1,undefined4 param_2)

{
  int unaff_A5;
  
  (**(code **)(unaff_A5 + -0x1082))();
  (**(code **)(unaff_A5 + -0x107e))();
  (**(code **)(unaff_A5 + -0x107a))(param_1,param_2);
  (**(code **)(unaff_A5 + -0x1076))();
  return;
}



// WARNING: Control flow encountered bad instruction data

void FUN_00000a42(undefined4 param_1)

{
  *(undefined4 *)(*(int *)(DAT_00000904 + -0x160c) + 0x50) = param_1;
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_00000a86(void)

{
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_00000ad0(void)

{
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_00000c68(void)

{
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_00000ca6(void)

{
  int unaff_A5;
  
  (**(code **)(unaff_A5 + 0x232))(0x6c,0);
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_00000d24(void)

{
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_00000d3a(undefined4 param_1,short param_2,short param_3,int param_4)

{
  int iVar1;
  undefined4 uVar2;
  
  iVar1 = DAT_00000904;
  if (*(int *)(DAT_00000904 + -0x103a) == 0) {
    *(undefined2 *)(DAT_00000904 + -0x14f0) = 0;
    *(undefined2 *)(iVar1 + -0x14f2) = 0;
    *(undefined2 *)(iVar1 + -0x14ec) = *(undefined2 *)(iVar1 + -0x1372);
    *(undefined2 *)(iVar1 + -0x14ee) = *(undefined2 *)(iVar1 + -0x1370);
    *(undefined4 *)(iVar1 + -0x14ea) = *(undefined4 *)(iVar1 + -0x14f2);
    *(undefined4 *)(iVar1 + -0x14e6) = *(undefined4 *)(iVar1 + -0x14ee);
    uVar2 = FUN_00000ca6();
    *(undefined4 *)(iVar1 + -0x103a) = uVar2;
  }
  *(undefined4 *)**(undefined4 **)(*(int *)(iVar1 + -0x103a) + 2) = param_1;
  *(short *)(iVar1 + -0x14ee) = param_3;
  *(short *)(iVar1 + -0x14ea) = param_2;
  *(short *)(iVar1 + -0x14e6) = param_3 + param_2;
  *(undefined2 *)(iVar1 + -0x14e8) = *(undefined2 *)(iVar1 + -0x14f0);
  *(undefined2 *)(iVar1 + -0x14e4) = *(undefined2 *)(iVar1 + -0x14ec);
  if (param_4 == 2) {
    *(short *)(iVar1 + -0x14e8) = *(short *)(iVar1 + -0x14e8) - *(short *)(iVar1 + -0x137e);
    *(short *)(iVar1 + -0x14e4) = *(short *)(iVar1 + -0x14e4) - *(short *)(iVar1 + -0x137e);
  }
  else if (param_4 == 3) {
    *(short *)(iVar1 + -0x14e8) = *(short *)(iVar1 + -0x137e) + *(short *)(iVar1 + -0x14e8);
    *(short *)(iVar1 + -0x14e4) = *(short *)(iVar1 + -0x137e) + *(short *)(iVar1 + -0x14e4);
  }
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_00000e3e(int param_1,undefined4 param_2)

{
  *(undefined4 *)**(undefined4 **)(param_1 + 2) = param_2;
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_00000e9e(void)

{
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_00000f52(void)

{
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_00000f74(void)

{
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_00000fa0(undefined4 param_1,undefined2 param_2)

{
  undefined4 unaff_D2;
  
  FUN_000015cc(CONCAT22(param_2,(short)((uint)unaff_D2 >> 0x10)));
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_00000fd2(void)

{
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_000010ce(void)

{
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_000011ec(void)

{
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_00001308(void)

{
  int in_stack_00000014;
  
  if (in_stack_00000014 != 0) {
                    // WARNING: Bad instruction - Truncating control flow here
    halt_baddata();
  }
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



void FUN_000014e6(void)

{
  (**(code **)(DAT_00000904 + 0x2e2))(DAT_00000904 + -0x1000);
  return;
}



int FUN_0000150a(void)

{
  int iVar1;
  int unaff_A5;
  
  if (*(short *)(unaff_A5 + -0x137a) == 1) {
    iVar1 = (**(code **)(unaff_A5 + 0x1ca))();
  }
  else {
    iVar1 = unaff_A5 + -0x1624;
  }
  return iVar1;
}



// WARNING: Control flow encountered bad instruction data

void FUN_000015cc(undefined4 param_1)

{
  int unaff_A5;
  
  if (*(short *)(unaff_A5 + -0x137a) == 1) {
    *(short *)(unaff_A5 + -0x13ba) = param_1._0_2_;
    (**(code **)(unaff_A5 + 0x1ca))();
                    // WARNING: Bad instruction - Truncating control flow here
    halt_baddata();
  }
  *(int *)(*(int *)(unaff_A5 + -0x160c) + 0x50) = (int)param_1._0_2_;
  return;
}



void FUN_00001632(undefined4 param_1)

{
  int unaff_A5;
  
  if (*(short *)(unaff_A5 + -0x137a) == 1) {
    *(short *)(unaff_A5 + -0x13b8) = param_1._0_2_;
  }
  else {
    *(int *)(*(int *)(unaff_A5 + -0x160c) + 0x54) = (int)param_1._0_2_;
  }
  return;
}



int FUN_00001656(undefined4 param_1)

{
  int unaff_A5;
  
  return (*(int *)(unaff_A5 + -0x149e) * (int)param_1._0_2_) / 0x12c0 +
         (int)(*(short *)(unaff_A5 + -0x1372) / 2);
}



int FUN_00001680(undefined4 param_1)

{
  int unaff_A5;
  
  return (*(int *)(unaff_A5 + -0x149e) * (int)param_1._0_2_) / 0x12c0 +
         (int)(*(short *)(unaff_A5 + -0x1370) / 2);
}



// WARNING: Control flow encountered bad instruction data

void FUN_000016aa(void)

{
  int iVar1;
  int unaff_A5;
  undefined2 in_stack_fffffffa;
  
  if (*(short *)(unaff_A5 + -0x137a) == 1) {
    iVar1 = FUN_00001656(CONCAT22(0xf380,in_stack_fffffffa));
    FUN_00001680(CONCAT22(0x960,(short)iVar1));
                    // WARNING: Bad instruction - Truncating control flow here
    halt_baddata();
  }
  iVar1 = FUN_00001656(CONCAT22(0xf380,in_stack_fffffffa));
  FUN_00001680(CONCAT22(0x960,(short)iVar1));
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_00001876(void)

{
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



void FUN_0000195c(void)

{
  FUN_00001876();
  return;
}



// WARNING: Control flow encountered bad instruction data

void FUN_0000197c(void)

{
  (**(code **)(DAT_00000904 + 0x17a))();
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



undefined2 FUN_000019a2(undefined2 param_1)

{
  int iVar1;
  short sVar2;
  
  iVar1 = DAT_00000904;
  (**(code **)(DAT_00000904 + 0x252))(param_1,0);
  sVar2 = 0;
  (**(code **)(iVar1 + 0x29a))();
  if (sVar2 != 0) {
    FUN_000019e2();
  }
  return param_1;
}



// WARNING: Control flow encountered bad instruction data

void FUN_000019e2(void)

{
  int unaff_A5;
  undefined4 local_4;
  
  if (*(int *)(unaff_A5 + -0x1006) != 0) {
    local_4 = *(undefined4 *)(unaff_A5 + -0x1006);
    register0x0000003c = (BADSPACEBASE *)&local_4;
    (**(code **)(unaff_A5 + 0x23a))();
  }
  *(undefined4 *)((int)register0x0000003c + -4) = 0x19f4;
  FUN_00004318();
  *(undefined2 *)((int)register0x0000003c + -2) = 0;
  *(undefined4 *)((int)register0x0000003c + -6) = *(undefined4 *)(unaff_A5 + -0xdd2);
  *(undefined4 *)((int)register0x0000003c + -10) = 0x19fe;
  FUN_00001d48(*(int *)((int)register0x0000003c + -6),*(undefined4 *)((int)register0x0000003c + -2))
  ;
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



void FUN_00001a04(undefined4 param_1)

{
  (**(code **)(DAT_00000904 + 0x25a))(param_1);
  return;
}



void FUN_00001a28(undefined4 *param_1,undefined4 param_2)

{
  int iVar1;
  short sVar3;
  undefined4 *puVar2;
  
  iVar1 = DAT_00000904;
  (**(code **)(DAT_00000904 + 0x26a))(param_2,param_1);
  sVar3 = 0;
  (**(code **)(iVar1 + 0x29a))();
  if (sVar3 != 0) {
    FUN_000019e2();
  }
  puVar2 = param_1;
  (**(code **)(iVar1 + 0x272))((short)param_1);
  FUN_000002b0((short)*param_1,(short)((uint)param_2 >> 0x10),(short)((uint)puVar2 >> 0x10));
  (**(code **)(iVar1 + 0x27a))((short)param_1);
  return;
}



void FUN_00001a84(undefined4 param_1)

{
  (**(code **)(DAT_00000904 + 0x272))(param_1);
  return;
}



void FUN_00001aa8(undefined4 param_1)

{
  (**(code **)(DAT_00000904 + 0x27a))(param_1);
  return;
}



void FUN_00001acc(undefined4 param_1)

{
  (**(code **)(DAT_00000904 + 0x282))(param_1);
  return;
}



void FUN_00001af0(undefined4 param_1)

{
  (**(code **)(DAT_00000904 + 0x28a))(param_1);
  return;
}



undefined4 FUN_00001b14(void)

{
  (**(code **)(DAT_00000904 + 0x212))();
  return 0;
}



char * FUN_00001c8a(int param_1,char *param_2)

{
  char *pcVar1;
  bool bVar2;
  char *local_e;
  char *local_a;
  
  bVar2 = param_1 < 0;
  if (bVar2) {
    param_1 = -param_1;
  }
  pcVar1 = param_2 + 10;
  do {
    local_a = pcVar1;
    pcVar1 = local_a + -1;
    *pcVar1 = (char)(param_1 % 10) + '0';
    param_1 = param_1 / 10;
  } while (param_1 != 0);
  if (bVar2) {
    local_a[-2] = '-';
    pcVar1 = local_a + -2;
  }
  local_a = pcVar1;
  param_1._3_1_ = (char)((int)param_2 - (int)local_a) + '\n';
  local_a[-1] = (char)param_1;
  local_e = param_2;
  param_1 = ((int)param_2 - (int)local_a) + 0xb;
  local_a = local_a + -1;
  while (param_1 != 0) {
    *local_e = *local_a;
    param_1 = param_1 + -1;
    local_e = local_e + 1;
    local_a = local_a + 1;
  }
  return param_2;
}



// WARNING: Control flow encountered bad instruction data

void FUN_00001d48(int param_1,undefined4 param_2)

{
  int unaff_A5;
  char acStack_e [10];
  
  (**(code **)(unaff_A5 + 0x302))(param_1);
  if (param_2._0_2_ == 0) {
                    // WARNING: Bad instruction - Truncating control flow here
    halt_baddata();
  }
  FUN_00001c8a((int)param_2._0_2_,acStack_e);
  if (param_1 != 0) {
                    // WARNING: Bad instruction - Truncating control flow here
    halt_baddata();
  }
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_00001dd4(void)

{
  int unaff_A5;
  
  if (*(short *)(unaff_A5 + -0xd12) == 0) {
                    // WARNING: Bad instruction - Truncating control flow here
    halt_baddata();
  }
  return;
}



// WARNING: Control flow encountered bad instruction data

void FUN_00001e32(void)

{
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



void FUN_00001e68(void)

{
  int unaff_A5;
  undefined1 *puVar1;
  int *piVar2;
  int local_a;
  short local_6;
  
  piVar2 = &local_a;
  for (local_6 = 0; local_6 < 0x14; local_6 = local_6 + 1) {
    puVar1 = (undefined1 *)piVar2;
    if (*(int *)(local_6 * 4 + unaff_A5 + -0xd62) != 0) {
      *(undefined4 *)((int)piVar2 + -4) = 0;
      *(int *)((int)piVar2 + -8) = *(int *)(local_6 * 4 + unaff_A5 + -0xd62) + -0x14;
      *(undefined4 *)((int)piVar2 + -0xc) = 0x1ea0;
      (**(code **)(unaff_A5 + 0x262))();
      puVar1 = (undefined1 *)((int)piVar2 + -4);
      local_a = *(int *)((int)piVar2 + -8);
      if (local_a != 0) {
        *(int *)((int)piVar2 + -8) = local_a;
        *(undefined4 *)((int)piVar2 + -0xc) = 0x1eb4;
        (**(code **)(unaff_A5 + 0x282))();
        puVar1 = (undefined1 *)((int)piVar2 + -0xc);
        *(int *)((int)piVar2 + -0xc) = local_a;
        *(undefined4 *)((int)piVar2 + -0x10) = 0x1ebc;
        (**(code **)(unaff_A5 + 0x27a))();
      }
      *(undefined4 *)(local_6 * 4 + unaff_A5 + -0xd62) = 0;
    }
    piVar2 = (int *)puVar1;
  }
  return;
}



// WARNING: Control flow encountered bad instruction data

void FUN_00001edc(void)

{
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



void FUN_00001f8e(void)

{
  ushort uVar1;
  short sVar2;
  int unaff_A5;
  undefined4 local_a;
  ushort local_6;
  
  local_a = 0;
  *(int *)(unaff_A5 + -0x112a) = unaff_A5 + -0xd62;
  FUN_00001e68();
  local_6 = 0;
  (**(code **)(unaff_A5 + 0x21a))((short)&local_a,0);
  uVar1 = 0;
  (**(code **)(unaff_A5 + 0x212))();
  if (uVar1 < 0x2e401) {
    uVar1 = FUN_00001edc();
    local_6 = uVar1 | local_6;
  }
  else {
    uVar1 = FUN_00001edc();
    local_6 = uVar1 | local_6;
  }
  uVar1 = FUN_00001edc();
  local_6 = uVar1 | local_6;
  uVar1 = FUN_00001edc();
  local_6 = uVar1 | local_6;
  uVar1 = FUN_00001edc();
  local_6 = uVar1 | local_6;
  uVar1 = FUN_00001edc();
  local_6 = uVar1 | local_6;
  uVar1 = FUN_00001edc();
  local_6 = uVar1 | local_6;
  uVar1 = FUN_00001edc();
  local_6 = uVar1 | local_6;
  uVar1 = FUN_00001edc();
  local_6 = uVar1 | local_6;
  uVar1 = FUN_00001edc();
  local_6 = uVar1 | local_6;
  uVar1 = FUN_00001edc();
  local_6 = uVar1 | local_6;
  sVar2 = FUN_00001edc();
  if (sVar2 != 0) {
    local_6 = local_6 | 1;
    uVar1 = FUN_00001edc();
    local_6 = uVar1 | local_6;
  }
  if (local_6 != 0) {
    FUN_00001dd4();
  }
  return;
}



void FUN_000020be(void)

{
  int unaff_A5;
  undefined1 *puVar1;
  int **ppiVar2;
  int *apiStack_12 [3];
  short local_6;
  
  ppiVar2 = apiStack_12 + 2;
  for (local_6 = 0; local_6 < 0x14; local_6 = local_6 + 1) {
    puVar1 = (undefined1 *)ppiVar2;
    if (*(int *)(local_6 * 4 + unaff_A5 + -0xd62) != 0) {
      puVar1 = (undefined1 *)((int)ppiVar2 + -4);
      *(undefined4 *)((int)ppiVar2 + -4) = *(undefined4 *)(local_6 * 4 + unaff_A5 + -0xd62);
      *(undefined4 *)((int)ppiVar2 + -8) = 0x20ee;
      (**(code **)(unaff_A5 + 0x272))();
      apiStack_12[2] = *(int **)(local_6 * 4 + unaff_A5 + -0xd62);
      *(int *)(local_6 * 4 + unaff_A5 + -0xd62) = *apiStack_12[2] + 0x14;
    }
    ppiVar2 = (int **)puVar1;
  }
  return;
}



// WARNING: Control flow encountered bad instruction data

void FUN_0000212a(void)

{
  int unaff_A5;
  undefined2 uVar1;
  
  FUN_000002b0((short)*(undefined4 *)(unaff_A5 + -0x101e) +
               (short)*(undefined4 *)(unaff_A5 + -0x1022) +
               (short)*(undefined4 *)(unaff_A5 + -0x1006));
  uVar1 = (undefined2)((uint)*(undefined4 *)(unaff_A5 + -0x1040) >> 0x10);
  (**(code **)(unaff_A5 + 0x242))((short)*(undefined4 *)(unaff_A5 + -0x1040),0);
  FUN_000002b0((short)*(undefined4 *)(unaff_A5 + -0x1040),uVar1);
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_00002192(void)

{
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_00002334(void)

{
  int unaff_A5;
  
  (**(code **)(unaff_A5 + 0x3a))();
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_000027e4(void)

{
  int iVar1;
  undefined4 uVar2;
  undefined4 uVar3;
  int *piVar4;
  short sVar5;
  undefined2 uVar6;
  undefined4 unaff_A2;
  int unaff_A5;
  undefined1 uVar7;
  ushort uVar8;
  undefined2 local_10;
  undefined2 uStack_e;
  undefined2 local_c;
  undefined2 uStack_a;
  undefined2 local_6;
  
  uVar8 = (ushort)((uint)unaff_A2 >> 0x10);
  FUN_00002192();
  sVar5 = *(short *)(**(int **)(**(int **)(unaff_A5 + -0x1036) + 0x16) + 0x20);
  if (((sVar5 != 1) && (sVar5 != 4)) && (sVar5 != 8)) {
    if ((*(int *)(unaff_A5 + -0x14ca) != 0) &&
       (*(char *)(*(int *)(unaff_A5 + -0x14ca) + 0x6e) != '\0')) {
      *(undefined2 *)(unaff_A5 + -0xd10) = 1;
                    // WARNING: Bad instruction - Truncating control flow here
      halt_baddata();
    }
    FUN_00001d48(*(int *)(unaff_A5 + -0xd76),(uint)uVar8);
    FUN_00002192();
    *(short *)(unaff_A5 + -0x137a) = sVar5;
    sVar5 = *(short *)(**(int **)(**(int **)(unaff_A5 + -0x1036) + 0x16) + 0x20);
    if ((sVar5 != 1) && ((sVar5 != 4 && (sVar5 != 8)))) {
      *(undefined2 *)(unaff_A5 + -0x102e) = 0;
      goto LAB_000028a2;
    }
  }
  if ((*(short *)(unaff_A5 + -0xd10) != 0) &&
     ((*(int *)(unaff_A5 + -0x14ca) != 0 && (*(short *)(unaff_A5 + -0x12f8) != 0)))) {
                    // WARNING: Bad instruction - Truncating control flow here
    halt_baddata();
  }
  *(undefined2 *)(unaff_A5 + -0xd10) = 0;
  *(undefined2 *)(unaff_A5 + -0x102e) = 1;
LAB_000028a2:
  if (*(short *)(unaff_A5 + -0x102e) != 0) {
    *(undefined2 *)(unaff_A5 + -0x13ae) = 0xffff;
    *(undefined4 *)(unaff_A5 + -0x1386) =
         *(undefined4 *)**(undefined4 **)(**(int **)(unaff_A5 + -0x1036) + 0x16);
    *(undefined2 *)(unaff_A5 + -0x137a) =
         *(undefined2 *)(**(int **)(**(int **)(unaff_A5 + -0x1036) + 0x16) + 0x20);
    iVar1 = **(int **)(**(int **)(unaff_A5 + -0x1036) + 0x16);
    uVar2 = *(undefined4 *)(iVar1 + 6);
    uVar3 = *(undefined4 *)(iVar1 + 10);
    local_c = (short)((uint)uVar3 >> 0x10);
    local_10 = (short)((uint)uVar2 >> 0x10);
    *(short *)(unaff_A5 + -0x137c) = local_c - local_10;
    uStack_a = (short)uVar3;
    uStack_e = (short)uVar2;
    *(short *)(unaff_A5 + -0x137e) = uStack_a - uStack_e;
    *(ushort *)(unaff_A5 + -0x1378) =
         *(ushort *)(**(int **)(**(int **)(unaff_A5 + -0x1036) + 0x16) + 4) & 0x1fff;
    *(undefined2 *)(unaff_A5 + -0x12d4) = *(undefined2 *)(**(int **)(unaff_A5 + -0x13ac) + 0x1c);
  }
  uVar7 = 0;
  (**(code **)(unaff_A5 + 0x2da))();
  *(undefined1 *)(unaff_A5 + -0x1000) = uVar7;
  if ((*(char *)(unaff_A5 + -0x1000) == '\0') &&
     ((*(byte *)(**(int **)(unaff_A5 + -0x1036) + 0x14) & 1) != 0)) {
    uVar6 = 1;
  }
  else {
    uVar6 = 0;
  }
  *(undefined2 *)(unaff_A5 + -0x1312) = uVar6;
  *(undefined1 *)(unaff_A5 + -0x1000) = 1;
  sVar5 = DAT_00000baa;
  for (local_6 = 1; local_6 < 4; local_6 = local_6 + 1) {
    if (*(int *)(local_6 * 0x16 + unaff_A5 + -0x136e) != 0) {
      piVar4 = (int *)(local_6 * 0x16 + unaff_A5 + -0x1364);
      *piVar4 = (int)*(short *)(local_6 * 0x16 + unaff_A5 + -0x1360) * (int)sVar5 + *piVar4;
    }
  }
  *(short *)(unaff_A5 + -0x137c) = *(short *)(unaff_A5 + -0x137c) - sVar5;
  *(undefined2 *)(unaff_A5 + -0x1028) = 0;
  FUN_00002334();
  return;
}



// WARNING: Control flow encountered bad instruction data

void FUN_000029f2(void)

{
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



void FUN_00002a44(void)

{
  undefined2 uVar1;
  short sVar2;
  short sVar3;
  short sVar4;
  short sVar5;
  bool bVar6;
  int unaff_A5;
  
  bVar6 = false;
  *(undefined2 *)(unaff_A5 + -0x12ee) = *(undefined2 *)(**(int **)(unaff_A5 + -0x13ac) + 2);
  *(undefined2 *)(unaff_A5 + -0x12ec) = *(undefined2 *)(**(int **)(unaff_A5 + -0x13ac) + 4);
  uVar1 = *(undefined2 *)(**(int **)(unaff_A5 + -0x13ac) + 0xc);
  *(undefined2 *)(unaff_A5 + -0x12ea) = uVar1;
  *(undefined2 *)(unaff_A5 + -0x103c) = uVar1;
  sVar2 = *(short *)(unaff_A5 + -0x12e0);
  sVar3 = *(short *)(unaff_A5 + -0x12d8);
  sVar4 = *(short *)(unaff_A5 + -0x12e6);
  sVar5 = *(short *)(unaff_A5 + -0x12dc);
  *(undefined2 *)(unaff_A5 + -0x12e0) = *(undefined2 *)(**(int **)(unaff_A5 + -0x13ac) + 0x10);
  *(undefined2 *)(unaff_A5 + -0x12d8) = *(undefined2 *)(**(int **)(unaff_A5 + -0x13ac) + 0x18);
  *(undefined2 *)(unaff_A5 + -0x12e6) = *(undefined2 *)(**(int **)(unaff_A5 + -0x13ac) + 8);
  *(undefined2 *)(unaff_A5 + -0x12dc) = *(undefined2 *)(**(int **)(unaff_A5 + -0x13ac) + 0x14);
  if (((((*(short *)(unaff_A5 + -0x12e0) != sVar2) || (*(short *)(unaff_A5 + -0x12d8) != sVar3)) ||
       (*(short *)(unaff_A5 + -0x12e6) != sVar4)) || (*(short *)(unaff_A5 + -0x12dc) != sVar5)) &&
     (*(int *)(unaff_A5 + -0x1006) != 0)) {
    (**(code **)(unaff_A5 + -0x1092))();
    bVar6 = true;
  }
  sVar2 = *(short *)(unaff_A5 + -0x12da);
  *(undefined2 *)(unaff_A5 + -0x12da) = *(undefined2 *)(**(int **)(unaff_A5 + -0x13ac) + 0x16);
  if ((sVar2 != *(short *)(unaff_A5 + -0x12da)) && (*(int *)(unaff_A5 + -0x1006) != 0)) {
    (**(code **)(unaff_A5 + -0x104e))();
    bVar6 = true;
  }
  if (*(short *)(unaff_A5 + -0x137a) == 8) {
    sVar2 = *(short *)(unaff_A5 + -0x12de);
    *(undefined2 *)(unaff_A5 + -0x12de) = *(undefined2 *)(**(int **)(unaff_A5 + -0x13ac) + 0x12);
    if ((*(short *)(unaff_A5 + -0x12de) != sVar2) && (*(int *)(unaff_A5 + -0x1006) != 0)) {
      (**(code **)(unaff_A5 + -0x1096))();
      bVar6 = true;
    }
    *(undefined2 *)(unaff_A5 + -0x12d6) = *(undefined2 *)(**(int **)(unaff_A5 + -0x13ac) + 0x1a);
  }
  else {
    *(undefined2 *)(unaff_A5 + -0x12de) = 0;
    *(undefined2 *)(unaff_A5 + -0x12d6) = 0;
  }
  *(undefined2 *)(unaff_A5 + -0x12d2) = *(undefined2 *)(**(int **)(unaff_A5 + -0x13ac) + 0x22);
  *(undefined2 *)(unaff_A5 + -0x12d0) = *(undefined2 *)(**(int **)(unaff_A5 + -0x13ac) + 0x24);
  *(undefined2 *)(unaff_A5 + -0x12e8) = *(undefined2 *)(**(int **)(unaff_A5 + -0x13ac) + 6);
  *(undefined2 *)(unaff_A5 + -0x12d4) = *(undefined2 *)(**(int **)(unaff_A5 + -0x13ac) + 0x1c);
  *(undefined2 *)(unaff_A5 + -0x12e4) = *(undefined2 *)(**(int **)(unaff_A5 + -0x13ac) + 10);
  if (bVar6) {
    FUN_00004db0();
  }
  return;
}



// WARNING: Control flow encountered bad instruction data

void FUN_00002bbc(void)

{
  int unaff_A5;
  undefined2 local_6;
  
  (**(code **)(unaff_A5 + 0x222))();
  for (local_6 = 0; local_6 < 2; local_6 = local_6 + 1) {
    (**(code **)(unaff_A5 + 0x292))();
  }
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_00002db8(void)

{
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_00002e36(void)

{
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



void FUN_00002ee4(char *param_1,char *param_2)

{
  char cVar1;
  short sVar2;
  
  cVar1 = *param_1;
  *param_2 = cVar1;
  sVar2 = (short)cVar1;
  while( true ) {
    param_1 = param_1 + 1;
    param_2 = param_2 + 1;
    sVar2 = sVar2 + -1;
    if (sVar2 < 0) break;
    *param_2 = *param_1;
  }
  return;
}



// WARNING: Control flow encountered bad instruction data

void FUN_00002f1e(void)

{
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_00002fa0(undefined8 param_1,undefined4 param_2,ushort param_3)

{
  int unaff_A5;
  
  if ((((*(short *)(unaff_A5 + -0x14c6) != 0) && ((param_3 & 3) == 3)) &&
      (param_1._2_4_ == *(int *)(unaff_A5 + -0x14ca))) && (*(int *)(unaff_A5 + -0x14ca) != 0)) {
                    // WARNING: Bad instruction - Truncating control flow here
    halt_baddata();
  }
  return;
}



// WARNING: Control flow encountered bad instruction data

void FUN_00002fd4(void)

{
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_0000309a(void)

{
  int unaff_A5;
  
  *(undefined2 *)(unaff_A5 + -0x13ae) = 0xffff;
  FUN_00002bbc();
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_000030fa(void)

{
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_00003174(void)

{
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_00003590(undefined4 param_1,short param_2)

{
  if (param_2 != 0) {
                    // WARNING: Bad instruction - Truncating control flow here
    halt_baddata();
  }
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



void FUN_000035bc(undefined4 param_1)

{
  int unaff_A5;
  
  if (*(short *)(**(int **)(unaff_A5 + -0x13ac) + 0xe) != param_1._0_2_) {
    *(short *)(**(int **)(unaff_A5 + -0x13ac) + 0xe) = param_1._0_2_;
    FUN_000027e4();
  }
  return;
}



// WARNING: Control flow encountered bad instruction data

void FUN_000035e4(void)

{
  short sVar1;
  int unaff_A5;
  undefined2 local_6;
  
  sVar1 = (**(code **)(unaff_A5 + 0x132))();
  if (sVar1 != 0) {
    sVar1 = (**(code **)(unaff_A5 + 0x82))();
    if (sVar1 != 0) {
      (**(code **)(unaff_A5 + -0x109a))((int)*(short *)(unaff_A5 + -0x12f8));
      if (*(short *)(unaff_A5 + -0x14c6) != 0) {
                    // WARNING: Bad instruction - Truncating control flow here
        halt_baddata();
      }
      *(undefined2 *)(unaff_A5 + -0x12f0) = 0;
      for (local_6 = 0; local_6 < 0xc; local_6 = local_6 + 1) {
        *(undefined2 *)(local_6 * 2 + unaff_A5 + -0x13a2) = 0;
        *(undefined2 *)(local_6 * 2 + unaff_A5 + -0x12ce) = 0;
      }
      *(undefined2 *)(unaff_A5 + -0x12b4) = 0;
      *(undefined2 *)(unaff_A5 + -0x12b6) = 0;
      *(undefined2 *)(unaff_A5 + -0x12b2) = 0;
      *(undefined2 *)(unaff_A5 + -0x14c4) = 0;
      *(undefined2 *)(unaff_A5 + -0x14c2) = 0;
      *(undefined2 *)(unaff_A5 + -0x14c0) = 0;
      if ((((*(short *)(unaff_A5 + -0x102e) != 0) && (*(int *)(unaff_A5 + -0x1006) != 0)) &&
          (*(short *)(unaff_A5 + -0x137a) == 1)) && (*(short *)(unaff_A5 + -0x14c6) != 0)) {
        (**(code **)(unaff_A5 + -0x1096))();
      }
      FUN_000004fc();
    }
  }
  return;
}



// WARNING: Control flow encountered bad instruction data

void FUN_000036a2(void)

{
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



undefined8 FUN_000039a8(void)

{
  int iVar1;
  uint uVar2;
  uint uVar3;
  uint uVar4;
  undefined4 in_D0;
  int iVar5;
  int iVar6;
  undefined4 in_D1;
  uint uVar7;
  int iVar8;
  short sVar9;
  int iVar10;
  int *piVar11;
  undefined1 *puVar12;
  bool bVar13;
  
  iVar5 = DAT_000039c4;
  if (DAT_000039c4 != 0) {
    piVar11 = *(int **)(DAT_000039c4 + -2000);
    iVar6 = *piVar11;
    uVar7 = piVar11[1];
    iVar10 = piVar11[2];
    iVar8 = piVar11[4];
    iVar1 = *(int *)(DAT_000039c4 + -0xc32);
    uVar2 = *(uint *)(DAT_000039c4 + -0xc2e);
    puVar12 = &DAT_66fa4e79;
    if (*(int *)(DAT_000039c4 + -0xc2a) < iVar8 - iVar6) {
      sVar9 = 0x5b;
      do {
        *puVar12 = *(undefined1 *)(iVar10 + iVar6);
        iVar5 = iVar1 + iVar6 + (uint)CARRY4(uVar2,uVar7);
        puVar12[2] = *(undefined1 *)(iVar10 + iVar5);
        uVar3 = uVar2 + uVar2 + uVar7;
        iVar5 = iVar1 + iVar5 + (uint)CARRY4(uVar2,uVar2 + uVar7);
        puVar12[4] = *(undefined1 *)(iVar10 + iVar5);
        uVar4 = uVar2 + uVar3;
        iVar5 = iVar1 + iVar5 + (uint)CARRY4(uVar2,uVar3);
        puVar12[6] = *(undefined1 *)(iVar10 + iVar5);
        puVar12 = puVar12 + 8;
        uVar7 = uVar2 + uVar4;
        iVar6 = iVar1 + iVar5 + (uint)CARRY4(uVar2,uVar4);
        sVar9 = sVar9 + -1;
      } while (sVar9 != -1);
      DAT_66fa4e75 = *(undefined1 *)(iVar10 + iVar6);
      uVar3 = uVar2 + uVar7;
      iVar5 = iVar1 + iVar6 + (uint)CARRY4(uVar2,uVar7);
      DAT_66fa4e77 = *(undefined1 *)(iVar10 + iVar5);
      uVar7 = uVar2 + uVar3;
      iVar6 = iVar1 + iVar5 + (uint)CARRY4(uVar2,uVar3);
    }
    else {
      sVar9 = 0x16f;
      do {
        if (iVar8 <= iVar6) {
          piVar11 = (int *)piVar11[6];
          iVar10 = piVar11[2];
          iVar6 = piVar11[3];
          uVar7 = 0;
          iVar8 = piVar11[4];
          *(int **)(iVar5 + -2000) = piVar11;
        }
        *puVar12 = *(undefined1 *)(iVar10 + iVar6);
        puVar12 = puVar12 + 2;
        bVar13 = CARRY4(uVar2,uVar7);
        uVar7 = uVar2 + uVar7;
        iVar6 = iVar1 + iVar6 + (uint)bVar13;
        sVar9 = sVar9 + -1;
      } while (sVar9 != -1);
      puVar12 = &DAT_66fa4e75;
      sVar9 = 1;
      do {
        if (iVar8 <= iVar6) {
          piVar11 = (int *)piVar11[6];
          iVar10 = piVar11[2];
          iVar6 = piVar11[3];
          uVar7 = 0;
          iVar8 = piVar11[4];
          *(int **)(iVar5 + -2000) = piVar11;
        }
        *puVar12 = *(undefined1 *)(iVar10 + iVar6);
        puVar12 = puVar12 + 2;
        bVar13 = CARRY4(uVar2,uVar7);
        uVar7 = uVar2 + uVar7;
        iVar6 = iVar1 + iVar6 + (uint)bVar13;
        sVar9 = sVar9 + -1;
      } while (sVar9 != -1);
    }
    *piVar11 = iVar6;
    piVar11[1] = uVar7;
    return CONCAT44(in_D0,in_D1);
  }
  DAT_000039c4 = DAT_00000904;
  return CONCAT44(in_D0,in_D1);
}



undefined8 FUN_00003aae(void)

{
  int iVar1;
  uint uVar2;
  int iVar3;
  undefined4 in_D0;
  int iVar4;
  undefined4 in_D1;
  uint uVar5;
  int iVar6;
  short sVar7;
  uint *puVar8;
  uint *puVar9;
  int iVar10;
  int *piVar11;
  undefined1 *puVar12;
  undefined1 *puVar13;
  bool bVar14;
  
  iVar3 = DAT_00003aca;
  if (DAT_00003aca != 0) {
    piVar11 = *(int **)(DAT_00003aca + -2000);
    iVar4 = *piVar11;
    uVar5 = piVar11[1];
    iVar10 = piVar11[2];
    iVar6 = piVar11[4];
    puVar12 = &DAT_66fa4e79;
    iVar1 = *(int *)(DAT_00003aca + -0xc32);
    uVar2 = *(uint *)(DAT_00003aca + -0xc2e);
    if (*(int *)(DAT_00003aca + -0xc2a) < iVar6 - iVar4) {
      sVar7 = 0x5b;
      puVar8 = (uint *)(iVar4 + iVar10);
      iVar4 = iVar4 + 0x172;
      if (((uint)puVar8 & 1) == 0) {
        do {
          puVar9 = puVar8;
          uVar5 = *puVar9;
          *puVar12 = (char)(uVar5 >> 0x18);
          puVar12[2] = (char)(uVar5 >> 0x10);
          puVar12[4] = (char)(uVar5 >> 8);
          puVar12[6] = (char)uVar5;
          puVar12 = puVar12 + 8;
          sVar7 = sVar7 + -1;
          puVar8 = puVar9 + 1;
        } while (sVar7 != -1);
        DAT_66fa4e75 = *(undefined1 *)(puVar9 + 1);
        DAT_66fa4e77 = *(undefined1 *)((int)puVar9 + 5);
      }
      else {
        DAT_66fa4e79 = *(undefined1 *)puVar8;
        sVar7 = 0x5a;
        puVar8 = (uint *)((int)puVar8 + 1);
        puVar12 = &DAT_66fa4e7b;
        do {
          puVar13 = puVar12;
          puVar9 = puVar8;
          uVar5 = *puVar9;
          *puVar13 = (char)(uVar5 >> 0x18);
          puVar13[2] = (char)(uVar5 >> 0x10);
          puVar13[4] = (char)(uVar5 >> 8);
          puVar13[6] = (char)uVar5;
          sVar7 = sVar7 + -1;
          puVar8 = puVar9 + 1;
          puVar12 = puVar13 + 8;
        } while (sVar7 != -1);
        puVar13[8] = *(undefined1 *)(puVar9 + 1);
        puVar13[10] = *(undefined1 *)((int)puVar9 + 5);
        puVar13[0xc] = *(undefined1 *)((int)puVar9 + 6);
        DAT_66fa4e75 = *(undefined1 *)((int)puVar9 + 7);
        DAT_66fa4e77 = *(undefined1 *)(puVar9 + 2);
      }
    }
    else {
      sVar7 = 0x16f;
      do {
        if (iVar6 <= iVar4) {
          piVar11 = (int *)piVar11[6];
          iVar10 = piVar11[2];
          iVar4 = piVar11[3];
          uVar5 = 0;
          iVar6 = piVar11[4];
          *(int **)(iVar3 + -2000) = piVar11;
        }
        *puVar12 = *(undefined1 *)(iVar10 + iVar4);
        puVar12 = puVar12 + 2;
        bVar14 = CARRY4(uVar2,uVar5);
        uVar5 = uVar2 + uVar5;
        iVar4 = iVar1 + iVar4 + (uint)bVar14;
        sVar7 = sVar7 + -1;
      } while (sVar7 != -1);
      puVar12 = &DAT_66fa4e75;
      sVar7 = 1;
      do {
        if (iVar6 <= iVar4) {
          piVar11 = (int *)piVar11[6];
          iVar10 = piVar11[2];
          iVar4 = piVar11[3];
          uVar5 = 0;
          iVar6 = piVar11[4];
          *(int **)(iVar3 + -2000) = piVar11;
        }
        *puVar12 = *(undefined1 *)(iVar10 + iVar4);
        puVar12 = puVar12 + 2;
        bVar14 = CARRY4(uVar2,uVar5);
        uVar5 = uVar2 + uVar5;
        iVar4 = iVar1 + iVar4 + (uint)bVar14;
        sVar7 = sVar7 + -1;
      } while (sVar7 != -1);
    }
    *piVar11 = iVar4;
    piVar11[1] = uVar5;
    return CONCAT44(in_D0,in_D1);
  }
  DAT_00003aca = DAT_00000904;
  return CONCAT44(in_D0,in_D1);
}



// WARNING: Globals starting with '_' overlap smaller symbols at the same address

undefined8 FUN_00003bc4(void)

{
  int iVar1;
  uint uVar2;
  uint uVar3;
  int iVar4;
  undefined4 in_D0;
  int iVar5;
  int iVar6;
  undefined4 in_D1;
  uint uVar7;
  short sVar8;
  int iVar9;
  char *pcVar10;
  char *pcVar11;
  char *pcVar12;
  int *piVar13;
  int iVar14;
  int *piVar15;
  char *pcVar16;
  bool bVar17;
  
  iVar4 = DAT_00003be0;
  if (DAT_00003be0 != 0) {
    piVar13 = *(int **)(DAT_00003be0 + -0x598);
    pcVar10 = (char *)(*piVar13 + piVar13[2]);
    iVar14 = *piVar13 + 0x172;
    piVar15 = *(int **)(DAT_00003be0 + -2000);
    iVar6 = *piVar15;
    uVar7 = piVar15[1];
    iVar9 = piVar15[2];
    iVar5 = piVar15[4];
    iVar1 = *(int *)(DAT_00003be0 + -0xc32);
    uVar2 = *(uint *)(DAT_00003be0 + -0xc2e);
    pcVar16 = &DAT_66fa4e79;
    if (*(int *)(DAT_00003be0 + -0xc2a) < iVar5 - iVar6) {
      sVar8 = 0xb7;
      do {
        pcVar11 = pcVar10;
        uVar3 = uVar2 + uVar7;
        iVar5 = iVar1 + iVar6 + (uint)CARRY4(uVar2,uVar7);
        *pcVar16 = *pcVar11 + *(char *)(iVar9 + iVar6) + -0x80;
        uVar7 = uVar2 + uVar3;
        iVar6 = iVar1 + iVar5 + (uint)CARRY4(uVar2,uVar3);
        pcVar16[2] = pcVar11[1] + *(char *)(iVar9 + iVar5) + -0x80;
        pcVar16 = pcVar16 + 4;
        sVar8 = sVar8 + -1;
        pcVar10 = pcVar11 + 2;
      } while (sVar8 != -1);
      uVar3 = uVar2 + uVar7;
      iVar5 = iVar1 + iVar6 + (uint)CARRY4(uVar2,uVar7);
      DAT_66fa4e75 = pcVar11[2] + *(char *)(iVar9 + iVar6) + -0x80;
      uVar7 = uVar2 + uVar3;
      iVar6 = iVar1 + iVar5 + (uint)CARRY4(uVar2,uVar3);
      DAT_66fa4e77 = pcVar11[3] + *(char *)(iVar9 + iVar5) + -0x80;
    }
    else {
      sVar8 = 0x16f;
      do {
        if (iVar5 <= iVar6) {
          piVar15 = (int *)piVar15[6];
          iVar9 = piVar15[2];
          iVar6 = piVar15[3];
          uVar7 = 0;
          iVar5 = piVar15[4];
          *(int **)(iVar4 + -2000) = piVar15;
        }
        pcVar11 = (char *)(iVar9 + iVar6);
        bVar17 = CARRY4(uVar2,uVar7);
        uVar7 = uVar2 + uVar7;
        iVar6 = iVar1 + iVar6 + (uint)bVar17;
        pcVar12 = pcVar10 + 1;
        *pcVar16 = *pcVar10 + *pcVar11 + -0x80;
        pcVar16 = pcVar16 + 2;
        sVar8 = sVar8 + -1;
        pcVar10 = pcVar12;
      } while (sVar8 != -1);
      pcVar10 = &DAT_66fa4e75;
      sVar8 = 1;
      do {
        if (iVar5 <= iVar6) {
          piVar15 = (int *)piVar15[6];
          iVar9 = piVar15[2];
          iVar6 = piVar15[3];
          uVar7 = 0;
          iVar5 = piVar15[4];
          *(int **)(iVar4 + -2000) = piVar15;
        }
        pcVar16 = (char *)(iVar9 + iVar6);
        bVar17 = CARRY4(uVar2,uVar7);
        uVar7 = uVar2 + uVar7;
        iVar6 = iVar1 + iVar6 + (uint)bVar17;
        *pcVar10 = *pcVar12 + *pcVar16 + -0x80;
        pcVar10 = pcVar10 + 2;
        sVar8 = sVar8 + -1;
        pcVar12 = pcVar12 + 1;
      } while (sVar8 != -1);
    }
    *piVar15 = iVar6;
    piVar15[1] = uVar7;
    if (piVar13[4] <= iVar14) {
      piVar13 = (int *)piVar13[6];
      iVar14 = piVar13[3];
      *(int **)(iVar4 + -0x598) = piVar13;
      if (iVar4 + -0xc26 == piVar13[2]) {
        _FUN_00000196 = *(undefined4 *)(iVar4 + -0x360);
      }
    }
    *piVar13 = iVar14;
    return CONCAT44(in_D0,in_D1);
  }
  DAT_00003be0 = DAT_00000904;
  return CONCAT44(in_D0,in_D1);
}



void FUN_00003d36(void)

{
  short sVar1;
  undefined1 *puVar2;
  
  puVar2 = &DAT_66fa4e75;
  sVar1 = 0x171;
  do {
    *puVar2 = 0x80;
    puVar2 = puVar2 + 2;
    sVar1 = sVar1 + -1;
  } while (sVar1 != -1);
  return;
}



undefined4 *
FUN_00003d50(int param_1,undefined4 param_2,undefined4 param_3,undefined4 param_4,undefined4 param_5
            )

{
  undefined4 *puVar1;
  undefined4 *puVar2;
  int unaff_A5;
  
  puVar1 = *(undefined4 **)(param_1 * 0x238 + unaff_A5 + -0x7cc);
  *(undefined4 *)(param_1 * 0x238 + unaff_A5 + -0x7cc) = puVar1[5];
  *puVar1 = param_3;
  puVar1[1] = 0;
  puVar1[2] = param_2;
  puVar1[3] = param_3;
  puVar1[4] = param_4;
  puVar2 = puVar1;
  if (param_5._0_2_ != 0) {
    puVar2 = (undefined4 *)puVar1[5];
  }
  puVar1[6] = puVar2;
  return puVar1;
}



// WARNING: Globals starting with '_' overlap smaller symbols at the same address

void FUN_00003db8(int param_1)

{
  int unaff_A5;
  
  if (param_1 == 1) {
    _FUN_00000196 = *(undefined4 *)(unaff_A5 + -0x35c);
  }
  return;
}



// WARNING: Control flow encountered bad instruction data
// WARNING: Globals starting with '_' overlap smaller symbols at the same address

void FUN_00003dd0(int param_1)

{
  undefined4 unaff_D5;
  short sVar1;
  int iVar2;
  int iVar3;
  undefined1 *puVar4;
  int unaff_A5;
  ushort uVar5;
  
  uVar5 = (ushort)((uint)unaff_D5 >> 0x10);
  if (*(short *)(unaff_A5 + -0xc38) != 0) {
    FUN_00004318();
  }
  for (iVar2 = 0; iVar2 < 2; iVar2 = iVar2 + 1) {
    iVar3 = iVar2 * 0x238 + unaff_A5 + -0x7c8;
    *(int *)(iVar2 * 0x238 + unaff_A5 + -0x5a0) = iVar3;
    *(int *)(iVar2 * 0x238 + unaff_A5 + -0x7cc) = iVar3;
    *(int *)(iVar2 * 0x238 + unaff_A5 + -2000) = iVar3;
    for (sVar1 = 0; sVar1 < 0x13; sVar1 = sVar1 + 1) {
      *(int *)(sVar1 * 0x1c + iVar2 * 0x238 + unaff_A5 + -0x7b4) =
           (short)(sVar1 + 1) * 0x1c + iVar2 * 0x238 + unaff_A5 + -0x7c8;
    }
  }
  puVar4 = (undefined1 *)(unaff_A5 + -0xc26);
  sVar1 = 0x456;
  while (0 < sVar1) {
    *puVar4 = 0x80;
    puVar4 = puVar4 + 1;
    sVar1 = sVar1 + -1;
  }
  FUN_00003d36();
  *(undefined4 *)(unaff_A5 + -0xc32) = 1;
  *(undefined4 *)(unaff_A5 + -0xc2e) = 0;
  *(undefined4 *)(unaff_A5 + -0xc2a) = 0x172;
  FUN_00003d50(0,unaff_A5 + -0xc26,0,0x172,(uint)uVar5);
  FUN_00003d50(1,unaff_A5 + -0xc26,0,0x172,(uint)uVar5);
  if (param_1 == 0) {
    iVar2 = unaff_A5 + 0x41a;
  }
  else {
    iVar2 = unaff_A5 + 0x412;
  }
  *(int *)(unaff_A5 + -0x360) = iVar2;
  *(int *)(unaff_A5 + -0x35c) = unaff_A5 + 0x422;
  if (*(short *)(unaff_A5 + -0x352) == 0) {
    *(undefined2 *)(unaff_A5 + -0x352) = 1;
    FUN_00003aae();
    FUN_000039a8();
    FUN_00003bc4();
  }
  *(undefined4 *)(unaff_A5 + -0xc36) = _FUN_00000196;
  _FUN_00000196 = *(undefined4 *)(unaff_A5 + -0x360);
  *(undefined4 *)(unaff_A5 + -0x356) = 0;
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



undefined4
FUN_00003f54(int param_1,undefined4 param_2,undefined4 param_3,undefined4 param_4,uint param_5,
            uint param_6)

{
  int iVar1;
  undefined4 uVar2;
  undefined4 unaff_D2;
  ushort uVar3;
  undefined4 local_8;
  
  iVar1 = DAT_00000904;
  uVar3 = (ushort)((uint)unaff_D2 >> 0x10);
  if (((*(short *)(DAT_00000904 + -0xc38) == 0) || (param_1 < 0)) || (1 < param_1)) {
    uVar2 = 0;
  }
  else {
    if (param_5 < param_6) {
      local_8 = FUN_00003d50(param_1,param_2,param_3,param_5,CONCAT22(1,uVar3));
      FUN_00003d50(param_1,param_2,param_5,param_6,(uint)uVar3);
      FUN_00003d50(param_1,param_2,param_6,param_4,CONCAT22(1,uVar3));
    }
    else {
      local_8 = FUN_00003d50(param_1,param_2,param_3,param_4,CONCAT22(1,uVar3));
      FUN_00003d50(param_1,iVar1 + -0xc26,0,0x172,(uint)uVar3);
    }
    FUN_00003db8(param_1);
    *(undefined4 **)(param_1 * 0x238 + iVar1 + -2000) = local_8;
    uVar2 = 1;
  }
  return uVar2;
}



undefined4
FUN_00004050(int param_1,undefined4 param_2,undefined4 param_3,undefined4 param_4,uint param_5,
            uint param_6)

{
  int iVar1;
  undefined4 uVar2;
  undefined4 unaff_D2;
  ushort uVar3;
  
  iVar1 = DAT_00000904;
  uVar3 = (ushort)((uint)unaff_D2 >> 0x10);
  if (((*(short *)(DAT_00000904 + -0xc38) == 0) || (param_1 < 0)) || (1 < param_1)) {
    uVar2 = 0;
  }
  else {
    if (param_5 < param_6) {
      FUN_00003d50(param_1,param_2,param_3,param_5,CONCAT22(1,uVar3));
      FUN_00003d50(param_1,param_2,param_5,param_6,(uint)uVar3);
      FUN_00003d50(param_1,param_2,param_6,param_4,CONCAT22(1,uVar3));
    }
    else {
      FUN_00003d50(param_1,param_2,param_3,param_4,CONCAT22(1,uVar3));
      FUN_00003d50(param_1,iVar1 + -0xc26,0,0x172,(uint)uVar3);
    }
    FUN_00003db8(param_1);
    uVar2 = 1;
  }
  return uVar2;
}



void FUN_0000412e(uint param_1)

{
  int iVar1;
  
  iVar1 = DAT_00000904;
  if (*(short *)(DAT_00000904 + -0xc38) != 0) {
    if (param_1 < 0x8000) {
      param_1 = 0x8000;
    }
    else if (0x30000 < param_1) {
      param_1 = 0x30000;
    }
    *(uint *)(DAT_00000904 + -0xc2a) = param_1 * 0x172 >> 0x10;
    *(uint *)(iVar1 + -0xc2e) = param_1 << 0x10;
    *(uint *)(iVar1 + -0xc32) = param_1 >> 0x10;
  }
  return;
}



void FUN_000041a6(int param_1)

{
  int iVar1;
  undefined4 *puVar2;
  uint unaff_A3;
  undefined4 *puVar3;
  
  iVar1 = DAT_00000904;
  if (((*(short *)(DAT_00000904 + -0xc38) != 0) && (-1 < param_1)) && (param_1 < 2)) {
    puVar2 = FUN_00003d50(param_1,DAT_00000904 + -0xc26,0,0x172,unaff_A3 >> 0x10);
    *(undefined4 *)(param_1 * 0x238 + iVar1 + -0x7cc) = puVar2[5];
    for (puVar3 = *(undefined4 **)(param_1 * 0x238 + iVar1 + -2000); puVar3 != puVar2;
        puVar3 = (undefined4 *)puVar3[5]) {
      puVar3[6] = puVar3[5];
    }
  }
  return;
}



void FUN_00004242(int param_1)

{
  int iVar1;
  undefined4 *puVar2;
  uint unaff_A4;
  
  iVar1 = DAT_00000904;
  if (((*(short *)(DAT_00000904 + -0xc38) != 0) && (-1 < param_1)) && (param_1 < 2)) {
    puVar2 = FUN_00003d50(param_1,DAT_00000904 + -0xc26,0,0x172,unaff_A4 >> 0x10);
    *(undefined4 **)(param_1 * 0x238 + iVar1 + -2000) = puVar2;
  }
  return;
}



undefined4 FUN_000042b0(int param_1)

{
  undefined4 uVar1;
  
  if (((*(short *)(DAT_00000904 + -0xc38) == 0) || (param_1 < 0)) || (1 < param_1)) {
    uVar1 = 0;
  }
  else {
    uVar1 = CONCAT22((short)((uint)(param_1 * 0x238) >> 0x10),
                     (short)(DAT_00000904 + -0xc26 !=
                            *(int *)(*(int *)(param_1 * 0x238 + DAT_00000904 + -2000) + 8)));
  }
  return uVar1;
}



// WARNING: Control flow encountered bad instruction data
// WARNING: Globals starting with '_' overlap smaller symbols at the same address

void FUN_00004318(void)

{
  int unaff_A5;
  
  if (*(short *)(unaff_A5 + -0xc38) != 0) {
    FUN_00004242(0);
    FUN_00004242(1);
    FUN_00004242(2);
    _FUN_00000196 = *(undefined4 *)(unaff_A5 + -0xc36);
    FUN_00003d36();
                    // WARNING: Bad instruction - Truncating control flow here
    halt_baddata();
  }
  return;
}



// WARNING: Control flow encountered bad instruction data

void FUN_0000435e(int param_1)

{
  int unaff_A5;
  
  if ((short)((*(short *)(unaff_A5 + -0x167c) - *(short *)(unaff_A5 + -0x1680)) - DAT_00000baa) <
      (short)(*(short *)(param_1 + 0x14) - *(short *)(param_1 + 0x10))) {
                    // WARNING: Bad instruction - Truncating control flow here
    halt_baddata();
  }
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_0000442e(void)

{
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_00004582(void)

{
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_00004610(void)

{
  int unaff_A5;
  
  if (*(int *)(unaff_A5 + -0x14ca) != 0) {
                    // WARNING: Bad instruction - Truncating control flow here
    halt_baddata();
  }
  return;
}



// WARNING: Control flow encountered bad instruction data

void FUN_0000462c(void)

{
  int unaff_A5;
  
  if (*(short *)(unaff_A5 + -0x137a) != *(short *)(unaff_A5 + -0x2cc)) {
    *(undefined2 *)(unaff_A5 + -0x2cc) = 0;
    if (*(short *)(unaff_A5 + -0x137a) == 4) {
                    // WARNING: Bad instruction - Truncating control flow here
      halt_baddata();
    }
    if (*(short *)(unaff_A5 + -0x137a) == 8) {
                    // WARNING: Bad instruction - Truncating control flow here
      halt_baddata();
    }
    if (*(short *)(unaff_A5 + -0x137a) == 1) {
      *(int *)(unaff_A5 + -0x14a6) = unaff_A5 + -800;
      *(undefined2 *)(unaff_A5 + -0x14a2) = 5;
      *(undefined2 *)(unaff_A5 + -0x2cc) = 1;
    }
  }
  return;
}



void FUN_000046b4(void)

{
  int unaff_A5;
  undefined1 auStack_8 [2];
  short local_6;
  
  *(undefined2 *)(unaff_A5 + -0x102a) = 0;
  if (*(short *)(unaff_A5 + -0x137a) == 1) {
    FUN_00004b62();
  }
  else if (*(short *)(unaff_A5 + -0x2cc) != 0) {
    if (*(int *)(unaff_A5 + -0x103a) != 0) {
      FUN_00000d24();
      *(undefined4 *)(unaff_A5 + -0x103a) = 0;
    }
    for (local_6 = 1; local_6 < 4; local_6 = local_6 + 1) {
      if (*(int *)(local_6 * 0x16 + unaff_A5 + -0x136e) != 0) {
        FUN_000048ae(CONCAT22(local_6,(short)((uint)auStack_8 >> 0x10)));
      }
    }
  }
  return;
}



// WARNING: Control flow encountered bad instruction data
// WARNING: Removing unreachable block (ram,0x000047c6)
// WARNING: Removing unreachable block (ram,0x0000478a)
// WARNING: Removing unreachable block (ram,0x00004790)
// WARNING: Removing unreachable block (ram,0x0000481c)
// WARNING: Removing unreachable block (ram,0x00004822)
// WARNING: Removing unreachable block (ram,0x00004864)
// WARNING: Removing unreachable block (ram,0x0000486a)

void FUN_00004738(undefined4 param_1)

{
  if (param_1._0_2_ == 4) {
                    // WARNING: Bad instruction - Truncating control flow here
    halt_baddata();
  }
  if (param_1._0_2_ != 8) {
    return;
  }
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



void FUN_0000488a(void)

{
  *(undefined2 *)(*(int *)(DAT_00000904 + -0x14b2) + 6) = 0;
  return;
}



// WARNING: Control flow encountered bad instruction data

undefined4 FUN_000048ae(undefined4 param_1)

{
  int unaff_A5;
  
  if (*(int *)(param_1._0_2_ * 0x16 + unaff_A5 + -0x136e) == 0) {
    return 0;
  }
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



undefined4 FUN_000049fe(undefined4 param_1,undefined4 param_2)

{
  short sVar1;
  short *psVar2;
  int iVar3;
  undefined2 uVar4;
  short sVar6;
  undefined4 uVar5;
  int unaff_A5;
  undefined2 local_8;
  undefined2 local_6;
  
  sVar6 = param_1._0_2_ << 6;
  param_1._0_2_ = sVar6;
  if (sVar6 == 0x100) {
    param_1._0_2_ = 0xff;
  }
  param_1._2_2_ = param_1._2_2_ << 6;
  if (param_1._2_2_ == 0x100) {
    param_1._2_2_ = 0xff;
  }
  sVar6 = param_2._0_2_ << 6;
  if (sVar6 == 0x100) {
    sVar6 = 0xff;
  }
  uVar5 = 0xffffffff;
  local_8 = -1;
  for (local_6 = 0; local_6 < 8; local_6 = local_6 + 1) {
    sVar1 = *(short *)(local_6 * 6 + unaff_A5 + -0x350);
    uVar5 = CONCAT22((short)((uint)(local_6 * 6) >> 0x10),sVar1);
    if (((sVar1 == (short)(param_1._0_2_ << 8)) &&
        (sVar1 = *(short *)(local_6 * 6 + unaff_A5 + -0x34e),
        uVar5 = CONCAT22((short)((uint)(local_6 * 6) >> 0x10),sVar1),
        sVar1 == (short)(param_1._2_2_ << 8))) &&
       (sVar1 = *(short *)(local_6 * 6 + unaff_A5 + -0x34c),
       uVar5 = CONCAT22((short)((uint)(local_6 * 6) >> 0x10),sVar1), sVar1 == (short)(sVar6 << 8)))
    {
      local_8 = local_6;
      break;
    }
  }
  if (local_8 == -1) {
    for (local_6 = 0; uVar5 = CONCAT22((short)((uint)uVar5 >> 0x10),local_6),
        local_6 < *(short *)(unaff_A5 + -0x14a2); local_6 = local_6 + 1) {
      psVar2 = (short *)(*(int *)(unaff_A5 + -0x14a6) + local_6 * 6);
      sVar1 = *psVar2;
      uVar5 = CONCAT22((short)((uint)psVar2 >> 0x10),sVar1);
      if ((sVar1 == (short)(param_1._0_2_ << 8)) &&
         (iVar3 = *(int *)(unaff_A5 + -0x14a6) + local_6 * 6, sVar1 = *(short *)(iVar3 + 2),
         uVar5 = CONCAT22((short)((uint)iVar3 >> 0x10),sVar1), sVar1 == (short)(param_1._2_2_ << 8))
         ) {
        iVar3 = *(int *)(unaff_A5 + -0x14a6) + local_6 * 6;
        sVar1 = *(short *)(iVar3 + 4);
        uVar4 = (undefined2)((uint)iVar3 >> 0x10);
        uVar5 = CONCAT22(uVar4,sVar1);
        if (sVar1 == (short)(sVar6 << 8)) {
          local_8 = local_6 + 8;
          uVar5 = CONCAT22(uVar4,local_8);
          break;
        }
      }
    }
  }
  uVar4 = (undefined2)((uint)uVar5 >> 0x10);
  if ((*(short *)(unaff_A5 + -0x137a) == 4) || (*(short *)(unaff_A5 + -0x137a) == 1)) {
    uVar5 = CONCAT22(uVar4,local_8);
  }
  else if (*(short *)(unaff_A5 + -0x137a) == 8) {
    uVar5 = CONCAT22(uVar4,local_8 + 200);
  }
  return uVar5;
}


/*
Unable to decompile 'FUN_00004b62'
Cause: 
Low-level Error: Symbol $$undef00000003 extends beyond the end of the address space
*/


void FUN_00004c18(void)

{
  undefined4 uVar1;
  int unaff_A5;
  short asStack_20e [256];
  short local_e;
  short local_c;
  short local_a;
  short local_8;
  short local_6;
  
  local_e = 0;
  *(undefined2 *)(unaff_A5 + -0x102a) = 0;
  if (*(short *)(unaff_A5 + -0x137a) == 1) {
    FUN_00004b62();
  }
  else {
    for (local_6 = 1; local_6 < 4; local_6 = local_6 + 1) {
      if (*(int *)(local_6 * 0x16 + unaff_A5 + -0x136e) != 0) {
        uVar1 = FUN_000048ae(CONCAT22(local_6,(short)((uint)&local_8 >> 0x10)));
        local_a = (short)uVar1;
        local_c = 0;
        for (; local_8 < (short)uVar1; local_8 = local_8 + 1) {
          if (asStack_20e[local_8] !=
              *(short *)(*(int *)(local_6 * 0x16 + unaff_A5 + -0x136a) + local_8 * 2)) {
            local_e = 1;
            local_c = 1;
            break;
          }
        }
        if (local_c != 0) {
          if (local_6 == 1) {
            (**(code **)(unaff_A5 + 0x182))(*(undefined4 *)(unaff_A5 + -0x1354),asStack_20e);
          }
          FUN_000048ae(CONCAT22(local_6,(short)((uint)&local_8 >> 0x10)));
        }
      }
    }
    if ((local_e != 0) && (*(int *)(unaff_A5 + -0x1006) != 0)) {
      (**(code **)(unaff_A5 + -0x1096))();
    }
  }
  return;
}



// WARNING: Control flow encountered bad instruction data

void FUN_00004d34(void)

{
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_00004d6a(int param_1)

{
  int unaff_A5;
  
  if ((*(short *)(unaff_A5 + -0x14c6) != 0) &&
     (*(int *)(param_1 + 2) == *(int *)(unaff_A5 + -0x14ca))) {
                    // WARNING: Bad instruction - Truncating control flow here
    halt_baddata();
  }
  return;
}



// WARNING: Control flow encountered bad instruction data

void FUN_00004db0(void)

{
  int unaff_A5;
  
  if (((*(short *)(unaff_A5 + -0x14c6) != 0) && (*(int *)(unaff_A5 + -0x1006) != 0)) &&
     (*(short *)(unaff_A5 + -0x12f8) != 0)) {
    if (*(short *)(unaff_A5 + -0x12ea) == 0) {
      *(undefined2 *)(unaff_A5 + -0x103c) = *(undefined2 *)(unaff_A5 + -0x12ea);
      *(undefined2 *)(unaff_A5 + -0x12ea) = 1;
    }
                    // WARNING: Bad instruction - Truncating control flow here
    halt_baddata();
  }
  return;
}


