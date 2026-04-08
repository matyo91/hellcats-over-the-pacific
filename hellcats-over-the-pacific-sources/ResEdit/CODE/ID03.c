typedef unsigned char   undefined;

typedef unsigned short    undefined2;
typedef unsigned int    undefined4;
typedef unsigned short    ushort;
typedef unsigned char    byte;



// WARNING: Control flow encountered bad instruction data

void FUN_00000006(void)

{
  int unaff_A5;
  
  if (*(short *)(unaff_A5 + -0x137a) == 1) {
                    // WARNING: Bad instruction - Truncating control flow here
    halt_baddata();
  }
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



undefined4 FUN_00000056(undefined4 param_1)

{
  int iVar1;
  int unaff_A5;
  undefined2 local_6;
  
  iVar1 = (*(int *)(unaff_A5 + -0x149e) * (int)param_1._0_2_ + 5) / 0x1e0;
  local_6 = (short)iVar1;
  if (local_6 < 10) {
    iVar1 = 0;
    local_6 = 10;
  }
  return CONCAT22((short)((uint)iVar1 >> 0x10),local_6);
}



int FUN_0000008a(undefined4 param_1)

{
  int unaff_A5;
  
  return (*(int *)(unaff_A5 + -0x149e) * (int)param_1._0_2_) / 0x12c0;
}



short FUN_000000a6(undefined4 param_1)

{
  int iVar1;
  int unaff_A5;
  undefined4 unaff_A6;
  
  iVar1 = FUN_0000008a(CONCAT22(param_1._0_2_,(short)((uint)unaff_A6 >> 0x10)));
  return (short)iVar1 - *(short *)(*(int *)(unaff_A5 + -0x160c) + 0x36) / 2;
}



int FUN_000000c8(int param_1,int param_2,int param_3)

{
  if (param_1 < param_2) {
    param_1 = param_2;
  }
  if (param_1 < param_3) {
    param_1 = param_3;
  }
  return param_1;
}



short FUN_000000f4(ushort *param_1)

{
  ushort uVar1;
  ushort uVar2;
  ushort uVar3;
  int iVar4;
  int iVar5;
  int iVar6;
  short sVar7;
  int unaff_A5;
  int local_c;
  short local_8;
  short local_6;
  
  uVar1 = *param_1;
  uVar2 = param_1[1];
  uVar3 = param_1[2];
  local_8 = -1;
  local_c = 0x7fffffff;
  for (local_6 = 0; local_6 < 8; local_6 = local_6 + 1) {
    iVar4 = (**(code **)(unaff_A5 + 0x4da))
                      ((uint)*(ushort *)(local_6 * 6 + unaff_A5 + -0x350) - (uint)uVar1);
    iVar5 = (**(code **)(unaff_A5 + 0x4da))
                      ((uint)*(ushort *)(local_6 * 6 + unaff_A5 + -0x34e) - (uint)uVar2);
    iVar6 = (**(code **)(unaff_A5 + 0x4da))
                      ((uint)*(ushort *)(local_6 * 6 + unaff_A5 + -0x34c) - (uint)uVar3);
    iVar4 = FUN_000000c8(iVar4,iVar5,iVar6);
    if (iVar4 < local_c) {
      local_8 = local_6;
      local_c = iVar4;
    }
  }
  local_6 = 0;
  do {
    if (*(short *)(unaff_A5 + -0x14a2) <= local_6) {
LAB_0000027e:
      sVar7 = local_8;
      if (((*(short *)(unaff_A5 + -0x137a) != 4) && (*(short *)(unaff_A5 + -0x137a) != 1)) &&
         (sVar7 = local_6, *(short *)(unaff_A5 + -0x137a) == 8)) {
        sVar7 = local_8 + 200;
      }
      return sVar7;
    }
    iVar4 = (**(code **)(unaff_A5 + 0x4da))
                      ((uint)*(ushort *)(*(int *)(unaff_A5 + -0x14a6) + local_6 * 6) - (uint)uVar1);
    iVar5 = (**(code **)(unaff_A5 + 0x4da))
                      ((uint)*(ushort *)(*(int *)(unaff_A5 + -0x14a6) + local_6 * 6 + 2) -
                       (uint)uVar2);
    iVar6 = (**(code **)(unaff_A5 + 0x4da))
                      ((uint)*(ushort *)(*(int *)(unaff_A5 + -0x14a6) + local_6 * 6 + 4) -
                       (uint)uVar3);
    iVar4 = FUN_000000c8(iVar4,iVar5,iVar6);
    if (iVar4 < local_c) {
      local_6 = local_6 + 8;
      local_8 = local_6;
      goto LAB_0000027e;
    }
    local_6 = local_6 + 1;
  } while( true );
}



// WARNING: Control flow encountered bad instruction data

void FUN_000002a8(undefined4 param_1)

{
  int unaff_A5;
  
  (**(code **)(unaff_A5 + 0x232))
            ((int)param_1._2_2_ * (int)(short)((param_1._0_2_ / 0x10) * 2 + 2),0);
  (**(code **)(unaff_A5 + 0x232))(0x6c,0);
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_0000033c(void)

{
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_0000035e(void)

{
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_00000514(undefined4 param_1)

{
  int unaff_A5;
  undefined2 in_stack_fffffff0;
  
  (**(code **)(unaff_A5 + 0x3ca))();
  (**(code **)(unaff_A5 + 0x382))();
  FUN_0000008a(CONCAT22(param_1._0_2_,in_stack_fffffff0));
  FUN_0000008a(CONCAT22(param_1._0_2_,in_stack_fffffff0));
  (**(code **)(unaff_A5 + 0x45a))(0);
  (**(code **)(unaff_A5 + 0x36a))();
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_0000077e(char *param_1,undefined4 param_2,undefined4 param_3)

{
  int iVar1;
  short sVar2;
  int unaff_A5;
  undefined2 in_stack_fffffff0;
  short local_a;
  char *local_8;
  
  local_8 = param_1;
  do {
    if (local_8[1] == '\0') {
      do {
        if (*param_1 == '\0') {
          return;
        }
        for (local_a = 0; local_a < 6; local_a = local_a + 1) {
          if (**(char **)(local_a * 4 + unaff_A5 + -0x20b0) == *param_1) {
            iVar1 = *(int *)(local_a * 4 + unaff_A5 + -0x20b0);
            sVar2 = FUN_000000a6(CONCAT22(*(char *)(iVar1 + 2) * param_2._0_2_ + param_2._2_2_,
                                          in_stack_fffffff0));
            FUN_000000a6(CONCAT22(*(char *)(iVar1 + 3) * param_2._0_2_ + param_3._0_2_,sVar2));
                    // WARNING: Bad instruction - Truncating control flow here
            halt_baddata();
          }
        }
        param_1 = param_1 + 1;
      } while( true );
    }
    for (local_a = 0; local_a < 6; local_a = local_a + 1) {
      if (**(char **)(local_a * 4 + unaff_A5 + -0x20b0) == *local_8) {
        param_2 = CONCAT22(param_2._0_2_,
                           param_2._2_2_ -
                           (short)((*(char *)(*(int *)(local_a * 4 + unaff_A5 + -0x20b0) + 1) + 1) *
                                  param_2._0_2_) / 2);
        break;
      }
    }
    local_8 = local_8 + 1;
  } while( true );
}



// WARNING: Control flow encountered bad instruction data

void FUN_00000912(undefined4 param_1,undefined4 param_2)

{
  char *pcVar1;
  short sVar2;
  undefined4 unaff_A4;
  int unaff_A5;
  short asStackY_10014 [32764];
  undefined2 uVar3;
  short asStack_14 [5];
  short local_a;
  short local_8;
  short local_6;
  
  uVar3 = (undefined2)((uint)unaff_A4 >> 0x10);
  local_6 = 5;
  do {
    local_6 = local_6 + -1;
    asStack_14[local_6] = param_1._0_2_ % 10;
    sVar2 = param_1._0_2_ / 10;
    param_1 = CONCAT22(sVar2,param_1._2_2_);
  } while (sVar2 != 0);
  if (4 < local_6) {
    return;
  }
  pcVar1 = *(char **)(asStack_14[local_6] * 4 + unaff_A5 + -0x1fde);
  local_a = param_2._2_2_;
  local_8 = *pcVar1 * param_1._2_2_ +
            (param_2._0_2_ - (short)((4 - local_6) * 6 * param_1._2_2_) / 2);
  local_6 = local_6 + 1;
  FUN_000000a6(CONCAT22(local_8,uVar3));
  local_a = pcVar1[1] * param_1._2_2_ + local_a;
  FUN_000000a6(CONCAT22(local_a,uVar3));
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_00000a3c(void)

{
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_0000146a(undefined4 param_1,undefined4 param_2)

{
  int unaff_A5;
  undefined2 in_stack_ffffffec;
  
  FUN_0000008a(CONCAT22(param_2._0_2_,in_stack_ffffffec));
  FUN_0000008a(CONCAT22(param_2._0_2_,in_stack_ffffffec));
  (**(code **)(unaff_A5 + 0x3ca))();
  (**(code **)(unaff_A5 + 0x382))();
  if (*(short *)(unaff_A5 + -0x137a) == 1) {
                    // WARNING: Bad instruction - Truncating control flow here
    halt_baddata();
  }
  FUN_00000a3c();
  return;
}



// WARNING: Control flow encountered bad instruction data

void FUN_00001538(undefined2 *param_1,short *param_2,short *param_3,undefined4 param_4,
                 undefined4 *param_5)

{
  int iVar1;
  undefined2 uVar3;
  undefined4 uVar2;
  short sVar4;
  int unaff_A5;
  undefined2 in_stack_ffffffec;
  
  if (*(short *)(unaff_A5 + -0x137a) == 1) {
    iVar1 = FUN_0000008a(CONCAT22(*param_1,in_stack_ffffffec));
    uVar3 = (undefined2)iVar1;
    iVar1 = FUN_0000008a(CONCAT22(*param_1,uVar3));
    uVar2 = FUN_000002a8(CONCAT22(uVar3,(short)iVar1));
    *param_5 = uVar2;
    FUN_0000008a(CONCAT22(*param_1,uVar3));
    FUN_0000008a(CONCAT22(*param_1,uVar3));
    iVar1 = FUN_0000008a(CONCAT22(0x14,uVar3));
    FUN_0000008a(CONCAT22(0x14,(short)iVar1));
                    // WARNING: Bad instruction - Truncating control flow here
    halt_baddata();
  }
  *param_2 = *param_2 * 3;
  *param_3 = *param_3 * 3;
  iVar1 = FUN_0000008a(CONCAT22(*param_1,in_stack_ffffffec));
  sVar4 = (short)iVar1 * 3;
  iVar1 = FUN_0000008a(CONCAT22(*param_1,sVar4));
  uVar2 = FUN_000002a8(CONCAT22(sVar4 + 6,(short)iVar1 * 3 + 6));
  *param_5 = uVar2;
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_00001844(void)

{
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data
// WARNING: Removing unreachable block (ram,0x00001910)
// WARNING: Removing unreachable block (ram,0x00001ac0)

void FUN_00001876(undefined4 param_1,undefined2 param_2,undefined4 param_3)

{
  undefined4 auStack_36 [12];
  
  FUN_00001538((undefined2 *)&param_1,(short *)((int)&param_1 + 2),(short *)&stack0x00000008,
               CONCAT22(param_2,param_3._0_2_),auStack_36);
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_00001b48(undefined4 param_1,undefined2 param_2,undefined4 param_3)

{
  undefined4 auStack_36 [12];
  short local_6;
  
  FUN_00001538((undefined2 *)&param_1,(short *)((int)&param_1 + 2),(short *)&stack0x00000008,
               CONCAT22(param_2,param_3._0_2_),auStack_36);
  local_6 = 0;
  while( true ) {
    if (0x9f < local_6) {
                    // WARNING: Bad instruction - Truncating control flow here
      halt_baddata();
    }
    if (local_6 % 10 == 0) {
                    // WARNING: Bad instruction - Truncating control flow here
      halt_baddata();
    }
    if (local_6 % 5 == 0) {
                    // WARNING: Bad instruction - Truncating control flow here
      halt_baddata();
    }
    if (0x13 < local_6) break;
    local_6 = local_6 + 1;
  }
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_00001fee(undefined4 param_1,undefined2 param_2,undefined4 param_3)

{
  undefined4 auStack_36 [12];
  short local_6;
  
  FUN_00001538((undefined2 *)&param_1,(short *)((int)&param_1 + 2),(short *)&stack0x00000008,
               CONCAT22(param_2,param_3._0_2_),auStack_36);
  local_6 = 0;
  while( true ) {
    if (0x26 < local_6) {
                    // WARNING: Bad instruction - Truncating control flow here
      halt_baddata();
    }
    if (local_6 % 3 == 0) break;
    if ((local_6 < 0x12) || (0x15 < local_6)) {
                    // WARNING: Bad instruction - Truncating control flow here
      halt_baddata();
    }
    local_6 = local_6 + 1;
  }
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data
// WARNING: Removing unreachable block (ram,0x000023a2)
// WARNING: Removing unreachable block (ram,0x00002578)

void FUN_000022fe(undefined4 param_1,undefined2 param_2,undefined4 param_3)

{
  undefined4 auStack_38 [13];
  
  FUN_00001538((undefined2 *)&param_1,(short *)((int)&param_1 + 2),(short *)&stack0x00000008,
               CONCAT22(param_2,param_3._0_2_),auStack_38);
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_00002600(undefined4 param_1,undefined2 param_2,undefined4 param_3)

{
  undefined4 auStack_38 [12];
  short local_6;
  
  FUN_00001538((undefined2 *)&param_1,(short *)((int)&param_1 + 2),(short *)&stack0x00000008,
               CONCAT22(param_2,param_3._0_2_),auStack_38);
  local_6 = 0;
  while( true ) {
    if (0x44 < local_6) {
                    // WARNING: Bad instruction - Truncating control flow here
      halt_baddata();
    }
    if ((short)(local_6 + -3) % 5 == 0) break;
    if (2 < local_6) {
                    // WARNING: Bad instruction - Truncating control flow here
      halt_baddata();
    }
    local_6 = local_6 + 1;
  }
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data
// WARNING: Removing unreachable block (ram,0x000029f4)
// WARNING: Removing unreachable block (ram,0x00002c94)

void FUN_00002950(undefined4 param_1,undefined2 param_2,undefined4 param_3)

{
  undefined4 auStack_38 [13];
  
  FUN_00001538((undefined2 *)&param_1,(short *)((int)&param_1 + 2),(short *)&stack0x00000008,
               CONCAT22(param_2,param_3._0_2_),auStack_38);
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_00002d1c(undefined4 param_1,undefined2 param_2,undefined4 param_3)

{
  undefined4 auStack_38 [13];
  
  FUN_00001538((undefined2 *)&param_1,(short *)((int)&param_1 + 2),(short *)&stack0x00000008,
               CONCAT22(param_2,param_3._0_2_),auStack_38);
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_000032b8(void)

{
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_00003832(void)

{
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_000038fc(void)

{
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_00003c02(undefined4 param_1,undefined2 param_2)

{
  byte *pbVar1;
  ushort uVar2;
  int unaff_A2;
  int unaff_A4;
  int unaff_A5;
  
  if (param_1._0_2_ == 6) {
    FUN_00000514(CONCAT22(param_1._2_2_,param_2));
  }
  else {
    FUN_00000514(CONCAT22(param_1._2_2_,param_2));
  }
  (**(code **)(unaff_A5 + 0x45a))(4);
  (**(code **)(unaff_A5 + 0x36a))();
  uVar2 = (**(code **)(unaff_A5 + 0x3a))();
  pbVar1 = (byte *)(unaff_A2 + 0x6e + (int)(short)(uVar2 | 9));
  *pbVar1 = *pbVar1 | 0x50;
  *(uint *)(unaff_A4 + 0x124) = *(uint *)(unaff_A4 + 0x124) | 0x8a00c6;
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_00003f24(void)

{
  int unaff_A5;
  
  (**(code **)(unaff_A5 + 0x45a))(1);
  (**(code **)(unaff_A5 + 0x36a))();
  (**(code **)(unaff_A5 + 0x45a))(0);
  (**(code **)(unaff_A5 + 0x3a2))();
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_00004110(void)

{
  int unaff_A5;
  
  (**(code **)(unaff_A5 + 0x3ca))();
  (**(code **)(unaff_A5 + 0x3ca))();
  (**(code **)(unaff_A5 + 0x45a))(0);
  (**(code **)(unaff_A5 + 0x36a))();
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_00004304(void)

{
  int unaff_A5;
  
  (**(code **)(unaff_A5 + 0x45a))(0);
  (**(code **)(unaff_A5 + 0x36a))();
  (**(code **)(unaff_A5 + 0x3ca))();
  (**(code **)(unaff_A5 + 0x382))();
  (**(code **)(unaff_A5 + 0x3ca))();
  (**(code **)(unaff_A5 + 0x382))();
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_00004790(void)

{
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_00004b32(void)

{
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data
// WARNING: Removing unreachable block (ram,0x00004cee)
// WARNING: Removing unreachable block (ram,0x00004e00)

void FUN_00004c42(undefined4 param_1,undefined4 param_2,undefined4 param_3)

{
  undefined4 auStack_36 [12];
  
  FUN_00000514(CONCAT22(param_1._0_2_,param_2._0_2_));
  FUN_00001538((undefined2 *)&param_1,(short *)((int)&param_1 + 2),(short *)&param_2,
               CONCAT22(param_2._2_2_,param_3._0_2_),auStack_36);
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data
// WARNING: Removing unreachable block (ram,0x00004f7c)
// WARNING: Removing unreachable block (ram,0x00005092)

void FUN_00004ecc(undefined4 param_1,undefined4 param_2,undefined4 param_3)

{
  undefined4 auStack_36 [12];
  
  FUN_00000514(CONCAT22(param_1._0_2_,param_2._0_2_));
  FUN_00001538((undefined2 *)&param_1,(short *)((int)&param_1 + 2),(short *)&param_2,
               CONCAT22(param_2._2_2_,param_3._0_2_),auStack_36);
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data
// WARNING: Removing unreachable block (ram,0x000051c0)
// WARNING: Removing unreachable block (ram,0x0000532a)

void FUN_00005158(void)

{
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_0000532e(undefined4 param_1,undefined4 param_2,undefined4 param_3)

{
  undefined4 auStack_36 [12];
  
  FUN_00000514(CONCAT22(param_1._0_2_,param_2._0_2_));
  FUN_00001538((undefined2 *)&param_1,(short *)((int)&param_1 + 2),(short *)&param_2,
               CONCAT22(param_2._2_2_,param_3._0_2_),auStack_36);
  FUN_00005158();
  FUN_00005158();
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_000054fe(undefined4 param_1,undefined4 param_2,undefined4 param_3)

{
  undefined4 auStack_36 [12];
  
  FUN_00000514(CONCAT22(param_1._0_2_,param_2._0_2_));
  FUN_00001538((undefined2 *)&param_1,(short *)((int)&param_1 + 2),(short *)&param_2,
               CONCAT22(param_2._2_2_,param_3._0_2_),auStack_36);
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data
// WARNING: Removing unreachable block (ram,0x0000583a)

void FUN_00005718(short *param_1,undefined4 param_2,short *param_3,short *param_4)

{
  short sVar1;
  short sVar2;
  short sVar3;
  short sVar4;
  short sVar7;
  int iVar5;
  int iVar6;
  int unaff_A5;
  int local_12;
  short local_e;
  
  sVar2 = param_1[3];
  sVar3 = param_1[1];
  sVar4 = param_1[2];
  sVar1 = *param_1;
  sVar7 = (short)(param_1[3] - param_1[1]) / 2;
  if (param_2._2_2_ < 0) {
    local_e = -5;
  }
  else {
    local_e = 5;
  }
  if ((short)(local_e + param_2._2_2_) == 0) {
    return;
  }
  for (local_12 = ((param_2._0_2_ + -0x5a) * 0x4000) / 0x168; local_12 < 0;
      local_12 = local_12 + 0x4000) {
  }
  for (; 0x4000 < local_12; local_12 = local_12 + -0x4000) {
  }
  iVar5 = (**(code **)(unaff_A5 + -0x2118))(local_12);
  iVar6 = (**(code **)(unaff_A5 + -0x211c))(local_12);
  *param_3 = (short)(sVar3 + sVar2) / 2 + (short)(iVar5 * sVar7 >> 0xc);
  *param_4 = (short)(sVar1 + sVar4) / 2 + (short)(iVar6 * sVar7 >> 0xc);
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



void FUN_00005860(void)

{
  short sVar1;
  short sVar2;
  short sVar3;
  undefined2 uVar4;
  short sVar5;
  short sVar6;
  short sVar7;
  int unaff_A5;
  
  sVar3 = (**(code **)(unaff_A5 + 0x382))();
  *(short *)(unaff_A5 + -0x1150) = sVar3;
  uVar4 = (**(code **)(unaff_A5 + 0x382))();
  *(undefined2 *)(unaff_A5 + -0x114e) = uVar4;
  sVar5 = (**(code **)(unaff_A5 + 0x382))();
  *(short *)(unaff_A5 + -0x114c) = sVar5 + 2;
  sVar6 = (**(code **)(unaff_A5 + 0x382))();
  *(short *)(unaff_A5 + -0x114a) = sVar6 + 2;
  sVar6 = (**(code **)(unaff_A5 + 0x3ca))();
  sVar1 = (sVar6 / 2) * 2;
  *(short *)(unaff_A5 + -0x1148) = sVar1;
  sVar6 = (**(code **)(unaff_A5 + 0x3ca))();
  sVar2 = (sVar6 / 2) * 2;
  *(short *)(unaff_A5 + -0x1146) = sVar2;
  sVar6 = (**(code **)(unaff_A5 + 0x3ca))();
  *(short *)(unaff_A5 + -0x1144) = (sVar6 / 2) * 2;
  sVar6 = (**(code **)(unaff_A5 + 0x3ca))();
  sVar6 = (sVar6 / 2) * 2 + 2;
  *(short *)(unaff_A5 + -0x1142) = sVar6;
  sVar7 = (**(code **)(unaff_A5 + 0x3ca))();
  *(short *)(unaff_A5 + -0x1140) = (sVar7 / 2) * 2 + 2;
  sVar7 = (**(code **)(unaff_A5 + 0x382))();
  *(short *)(unaff_A5 + -0x113e) = sVar7;
  *(int *)(unaff_A5 + -0x113c) =
       (int)sVar1 / (int)(short)(8 / (int)*(short *)(unaff_A5 + -0x137a)) +
       *(int *)(unaff_A5 + -0x1382) + (int)sVar3 * (int)*(short *)(unaff_A5 + -0x1378);
  *(int *)(unaff_A5 + -0x1138) =
       (int)sVar1 / (int)(short)(8 / (int)*(short *)(unaff_A5 + -0x137a)) +
       *(int *)(unaff_A5 + -0x1382) + (int)(short)(sVar5 + 2) * (int)*(short *)(unaff_A5 + -0x1378);
  *(int *)(unaff_A5 + -0x1134) =
       (int)sVar2 / (int)(short)(8 / (int)*(short *)(unaff_A5 + -0x137a)) +
       *(int *)(unaff_A5 + -0x1382) + (int)sVar7 * (int)*(short *)(unaff_A5 + -0x1378);
  *(int *)(unaff_A5 + -0x1130) =
       (int)sVar6 / (int)(short)(8 / (int)*(short *)(unaff_A5 + -0x137a)) +
       *(int *)(unaff_A5 + -0x1382) + (int)sVar7 * (int)*(short *)(unaff_A5 + -0x1378);
  return;
}



// WARNING: Control flow encountered bad instruction data

void FUN_00005ab6(void)

{
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_00005c36(undefined4 param_1)

{
  int unaff_A5;
  
  (**(code **)(unaff_A5 + 0x4f2))(param_1);
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_00005cb6(void)

{
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_00005cc4(void)

{
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_00006c1c(void)

{
  short sVar1;
  int unaff_A5;
  undefined2 local_204 [256];
  
  if ((((-1 < *(short *)(unaff_A5 + -0x13ae)) && (*(int *)(unaff_A5 + -0x13b2) != 0)) &&
      (*(short *)(**(int **)(unaff_A5 + -0x13b2) + *(short *)(unaff_A5 + -0x13ae) * 0x160) ==
       *(short *)(unaff_A5 + -0x137a))) &&
     (((*(short *)(**(int **)(unaff_A5 + -0x13b2) + *(short *)(unaff_A5 + -0x13ae) * 0x160 + 2) ==
        *(short *)(unaff_A5 + -0x137e) &&
       (*(short *)(**(int **)(unaff_A5 + -0x13b2) + *(short *)(unaff_A5 + -0x13ae) * 0x160 + 4) ==
        *(short *)(unaff_A5 + -0x137c))) &&
      ((*(short *)(**(int **)(unaff_A5 + -0x13b2) + *(short *)(unaff_A5 + -0x13ae) * 0x160 + 6) ==
        *(short *)(unaff_A5 + -0x1372) &&
       (*(short *)(**(int **)(unaff_A5 + -0x13b2) + *(short *)(unaff_A5 + -0x13ae) * 0x160 + 8) ==
        *(short *)(unaff_A5 + -0x1370))))))) {
    if (*(short *)(unaff_A5 + -0x137a) != 1) {
      for (sVar1 = 0; sVar1 < 0x100; sVar1 = sVar1 + 1) {
        local_204[sVar1] = 0;
      }
      (**(code **)(unaff_A5 + 0x2a))();
                    // WARNING: Bad instruction - Truncating control flow here
      halt_baddata();
    }
    (**(code **)(unaff_A5 + 0x482))();
  }
  return;
}



void FUN_000071a2(void)

{
  short sVar1;
  short local_204 [256];
  
  for (sVar1 = 0; sVar1 < 0x100; sVar1 = sVar1 + 1) {
    local_204[sVar1] = sVar1;
  }
  FUN_00006c1c();
  return;
}


