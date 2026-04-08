typedef unsigned char   undefined;

typedef unsigned char    undefined1;
typedef unsigned short    undefined2;
typedef unsigned int    undefined4;
typedef unsigned long long    undefined6;
typedef unsigned long long    undefined8;
typedef unsigned char    byte;


int DAT_00000904;

// WARNING: Control flow encountered bad instruction data

void FUN_00000006(void)

{
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_0000002e(void)

{
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_00000054(void)

{
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_00000078(void)

{
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_0000009c(void)

{
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_000000c4(void)

{
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_000000ec(void)

{
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_00000120(void)

{
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_0000016e(void)

{
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_000001f2(void)

{
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_00000220(void)

{
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



void FUN_000002c0(void)

{
  code *UNRECOVERED_JUMPTABLE;
  
  FUN_00000220();
                    // WARNING: Could not recover jumptable at 0x000002da. Too many branches
                    // WARNING: Treating indirect jump as call
  (*UNRECOVERED_JUMPTABLE)();
  return;
}



// WARNING: Control flow encountered bad instruction data

undefined4 FUN_00000362(undefined4 param_1,undefined4 param_2,undefined4 param_3)

{
  if (param_3._0_2_ < 1) {
    return 0xffffffff;
  }
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_000003c2(void)

{
  int unaff_A5;
  
  if (*(int *)(unaff_A5 + -0x225a) == 0) {
    *(undefined4 *)(unaff_A5 + -0x14be) = *(undefined4 *)(unaff_A5 + -0x1680);
    *(undefined4 *)(unaff_A5 + -0x14ba) = *(undefined4 *)(unaff_A5 + -0x167c);
                    // WARNING: Bad instruction - Truncating control flow here
    halt_baddata();
  }
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_0000044e(void)

{
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_00000478(void)

{
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_000004f0(void)

{
  int unaff_A5;
  
  (**(code **)(unaff_A5 + 0x47a))();
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

undefined4 FUN_00000516(void)

{
  bool bVar1;
  undefined4 uVar2;
  int unaff_A5;
  
  if ((*(short *)(unaff_A5 + -0x12f8) < 3) || (*(short *)(unaff_A5 + -0x14c4) != 0)) {
    bVar1 = false;
  }
  else {
    bVar1 = true;
  }
  if (bVar1) {
    uVar2 = FUN_000018e0();
    if ((short)uVar2 != 0) {
      (**(code **)(unaff_A5 + 0x47a))();
                    // WARNING: Bad instruction - Truncating control flow here
      halt_baddata();
    }
  }
  return 2;
}



// WARNING: Control flow encountered bad instruction data

void FUN_00000560(void)

{
  int unaff_A5;
  
  (**(code **)(unaff_A5 + 0x47a))();
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



int FUN_00000588(undefined4 param_1)

{
  int unaff_A5;
  undefined4 local_a;
  undefined2 local_6;
  
  local_a = 0;
  for (local_6 = 0; local_6 < 0xc; local_6 = local_6 + 1) {
    local_a = (int)*(short *)(local_6 * 2 + **(int **)(unaff_A5 + -0x13a8) + param_1._0_2_ * 0x40 +
                             0x28) * (int)*(short *)(local_6 * 2 + unaff_A5 + -0xf5e) + local_a;
  }
  return local_a;
}



// WARNING: Control flow encountered bad instruction data

void FUN_000005e4(void)

{
  int unaff_A5;
  
  (**(code **)(unaff_A5 + 0x2a))();
  (**(code **)(unaff_A5 + 0x32))();
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_000009ee(void)

{
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



undefined4 FUN_00000a8e(undefined4 param_1,int param_2,undefined2 *param_3)

{
  undefined4 uVar1;
  int unaff_A5;
  
  (**(code **)(unaff_A5 + 0x2a))();
  if (((*(uint *)(param_2 + 2) & 0xff) == 0xd) || ((*(uint *)(param_2 + 2) & 0xff) == 3)) {
    *param_3 = 1;
    uVar1 = 1;
  }
  else {
    uVar1 = 0;
  }
  return uVar1;
}



void FUN_00000bda(undefined2 *param_1,int param_2,undefined4 param_3)

{
  undefined4 uVar1;
  code *UNRECOVERED_JUMPTABLE;
  undefined1 uStack00000010;
  
  uVar1 = FUN_00000a8e(param_3,param_2,param_1);
  uStack00000010 = (undefined1)uVar1;
                    // WARNING: Could not recover jumptable at 0x00000c00. Too many branches
                    // WARNING: Treating indirect jump as call
  (*UNRECOVERED_JUMPTABLE)();
  return;
}



void FUN_00000e48(undefined2 *param_1,int param_2,undefined4 param_3)

{
  undefined4 uVar1;
  code *UNRECOVERED_JUMPTABLE;
  undefined1 uStack00000010;
  
  uVar1 = FUN_00000a8e(param_3,param_2,param_1);
  uStack00000010 = (undefined1)uVar1;
                    // WARNING: Could not recover jumptable at 0x00000e6e. Too many branches
                    // WARNING: Treating indirect jump as call
  (*UNRECOVERED_JUMPTABLE)();
  return;
}



void FUN_00000f4e(int param_1,int param_2)

{
  undefined4 uVar1;
  char *pcVar2;
  char *pcVar3;
  int iVar4;
  int unaff_A5;
  short *psVar5;
  undefined1 *puVar6;
  undefined1 *puVar7;
  undefined4 uStackY_26;
  short local_22 [2];
  undefined4 local_1e;
  undefined2 uVar8;
  undefined2 uStack_16;
  short local_8;
  short local_6;
  
  puVar7 = &stack0xffffffe8;
  for (local_6 = 0; local_6 < 0x14; local_6 = local_6 + 1) {
    iVar4 = param_1 + local_6 * 4;
    uVar8 = (undefined2)((uint)iVar4 >> 0x10);
    uStack_16 = (undefined2)iVar4;
    iVar4 = FUN_00000588(CONCAT22(local_6,uVar8));
    *(int *)CONCAT22(uVar8,uStack_16) = iVar4;
    *(short *)(param_2 + local_6 * 2) = local_6;
  }
  local_6 = 0;
  do {
    local_8 = local_6;
    if (0x12 < local_6) {
      return;
    }
LAB_000010ea:
    local_8 = local_8 + 1;
    if (local_8 < 0x14) {
      pcVar2 = (char *)(**(int **)(unaff_A5 + -0x13a8) + *(short *)(param_2 + local_6 * 2) * 0x40);
      pcVar3 = (char *)(**(int **)(unaff_A5 + -0x13a8) + *(short *)(param_2 + local_8 * 2) * 0x40);
      puVar6 = puVar7;
      if (*(int *)(param_1 + local_8 * 4) <= *(int *)(param_1 + local_6 * 4)) break;
      goto LAB_00001060;
    }
    local_6 = local_6 + 1;
  } while( true );
  if (*(int *)(param_1 + local_8 * 4) == *(int *)(param_1 + local_6 * 4)) {
    if (*pcVar2 != '\0') {
      if ((*pcVar2 == '\0') || (*pcVar3 == '\0')) goto LAB_000010ea;
      *(undefined2 *)(puVar7 + -2) = 0;
      *(char **)(puVar7 + -6) = pcVar2;
      psVar5 = (short *)(puVar7 + -10);
      *(char **)(puVar7 + -10) = pcVar3;
      *(undefined4 *)(puVar7 + -0xe) = 0x1058;
      (**(code **)(unaff_A5 + 0x2ea))();
      puVar6 = puVar7 + -8;
      puVar7 = puVar7 + -8;
      if (*psVar5 < 0) goto LAB_000010ea;
    }
LAB_00001060:
    uVar1 = *(undefined4 *)(param_1 + local_8 * 4);
    *(undefined4 *)(param_1 + local_8 * 4) = *(undefined4 *)(param_1 + local_6 * 4);
    *(undefined4 *)(param_1 + local_6 * 4) = uVar1;
    uVar8 = *(undefined2 *)(param_2 + local_8 * 2);
    *(undefined2 *)(param_2 + local_8 * 2) = *(undefined2 *)(param_2 + local_6 * 2);
    *(undefined2 *)(param_2 + local_6 * 2) = uVar8;
    puVar7 = puVar6;
  }
  goto LAB_000010ea;
}



void FUN_00001106(undefined4 param_1)

{
  undefined1 *puVar1;
  int unaff_A5;
  short local_6;
  
  puVar1 = (undefined1 *)(**(int **)(unaff_A5 + -0x13a8) + param_1._0_2_ * 0x40);
  *(undefined2 *)(puVar1 + 0x22) = 0;
  *(undefined2 *)(puVar1 + 0x20) = 0;
  *(undefined2 *)(puVar1 + 0x24) = 0;
  *(undefined2 *)(puVar1 + 0x26) = 0;
  for (local_6 = 0; local_6 < 0xc; local_6 = local_6 + 1) {
    *(undefined2 *)(puVar1 + local_6 * 2 + 0x28) = 0;
  }
  *puVar1 = 0;
  return;
}



// WARNING: Control flow encountered bad instruction data

void FUN_0000116a(int param_1)

{
  bool bVar1;
  short sVar2;
  bool bVar3;
  int unaff_A5;
  undefined2 uVar4;
  undefined2 local_8;
  undefined2 local_6;
  
  uVar4 = (undefined2)((uint)*(undefined4 *)(unaff_A5 + -0x13a8) >> 0x10);
  (**(code **)(unaff_A5 + 0x272))((short)*(undefined4 *)(unaff_A5 + -0x13a8));
  local_8 = 0;
  bVar3 = false;
  for (local_6 = 0; local_6 < 0x14; local_6 = local_6 + 1) {
    if ((*(short *)(**(int **)(unaff_A5 + -0x13a8) + *(short *)(param_1 + local_6 * 2) * 0x40 + 0x20
                   ) != 0) && (sVar2 = local_8 + 1, bVar1 = 9 < local_8, local_8 = sVar2, bVar1)) {
      FUN_00001106(CONCAT22(*(undefined2 *)(param_1 + local_6 * 2),uVar4));
      bVar3 = true;
    }
  }
  (**(code **)(unaff_A5 + 0x27a))((short)*(undefined4 *)(unaff_A5 + -0x13a8));
  if (bVar3) {
                    // WARNING: Bad instruction - Truncating control flow here
    halt_baddata();
  }
  return;
}



// WARNING: Control flow encountered bad instruction data

void FUN_00001200(void)

{
  undefined1 auStack_98 [40];
  undefined1 auStack_70 [108];
  
  FUN_00000f4e((int)auStack_70,(int)auStack_98);
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_000014a0(void)

{
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



void FUN_000014f2(void)

{
  code *UNRECOVERED_JUMPTABLE;
  
  FUN_000014a0();
                    // WARNING: Could not recover jumptable at 0x0000150c. Too many branches
                    // WARNING: Treating indirect jump as call
  (*UNRECOVERED_JUMPTABLE)();
  return;
}



// WARNING: Control flow encountered bad instruction data

void FUN_0000150e(void)

{
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_00001562(void)

{
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_0000158c(void)

{
  FUN_00001562();
  FUN_0000150e();
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_00001638(undefined4 *param_1)

{
  int iVar1;
  int *piVar2;
  int unaff_A5;
  
  piVar2 = *(int **)(unaff_A5 + -0x223a);
  iVar1 = *piVar2;
  *(undefined4 *)(iVar1 + 8) = *param_1;
  *(undefined4 *)(iVar1 + 0xc) = param_1[1];
  *(short *)(*piVar2 + 0xe) = *(short *)(*piVar2 + 0xe) + -0x10;
  *(short *)(unaff_A5 + -0x2232) =
       (short)(*(short *)(*piVar2 + 0xc) - *(short *)(*piVar2 + 8)) / *(short *)(*piVar2 + 0x18);
  *(short *)(*piVar2 + 0xc) =
       *(short *)(*piVar2 + 8) + *(short *)(*piVar2 + 0x18) * *(short *)(unaff_A5 + -0x2232);
  *(undefined2 *)(*piVar2 + 6) = *(undefined2 *)(*piVar2 + 0xe);
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_000016c4(undefined4 param_1)

{
  byte *unaff_A4;
  int unaff_A5;
  code *UNRECOVERED_JUMPTABLE;
  
  if (param_1._0_2_ != 0) {
    (**(code **)(unaff_A5 + 0x3a))
              ((short)(*(short *)(**(int **)(unaff_A5 + -0x223a) + 0xc) -
                      *(short *)(**(int **)(unaff_A5 + -0x223a) + 8)) /
               *(short *)(**(int **)(unaff_A5 + -0x223a) + 0x18) + -1);
    *unaff_A4 = *unaff_A4 | 0x17;
    unaff_A4[0xe] = unaff_A4[0xe] | 8;
    *unaff_A4 = *unaff_A4 | 0x1e;
                    // WARNING: Bad instruction - Truncating control flow here
    halt_baddata();
  }
                    // WARNING: Could not recover jumptable at 0x00001750. Too many branches
                    // WARNING: Treating indirect jump as call
  (*UNRECOVERED_JUMPTABLE)();
  return;
}



// WARNING: Control flow encountered bad instruction data

void FUN_000017e6(void)

{
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_0000189c(void)

{
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_000018b0(void)

{
  int unaff_A5;
  
  (**(code **)(unaff_A5 + 0x522))();
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



undefined4 FUN_000018e0(void)

{
  undefined4 uVar1;
  int unaff_A5;
  short local_6;
  
  if (*(short *)(unaff_A5 + -0x12f8) == 2) {
    uVar1 = 0;
  }
  else if ((*(short *)(unaff_A5 + -0x14c0) == 0) && (0 < *(short *)(unaff_A5 + -0x12ba))) {
    uVar1 = 2;
  }
  else {
    for (local_6 = 0; local_6 < 10; local_6 = local_6 + 1) {
      if (*(short *)(local_6 * 2 + unaff_A5 + -0x12ce) != 0) {
        return 1;
      }
    }
    uVar1 = 0;
  }
  return uVar1;
}



// WARNING: Control flow encountered bad instruction data

void FUN_0000192e(undefined4 param_1,undefined4 param_2)

{
  int unaff_A5;
  
  *(undefined4 *)(unaff_A5 + -0x2230) = 0;
  if (((*(short *)(unaff_A5 + -0x14c4) == 0) || (*(short *)(unaff_A5 + -0x12f0) != 0)) ||
     (*(short *)(unaff_A5 + -0x2228) != -1)) {
    FUN_0000002e();
  }
  if (*(short *)(unaff_A5 + -0x12f0) == 0) {
    FUN_0000002e();
  }
  if (((param_2._0_2_ != 3) && (*(short *)(unaff_A5 + -0x14c4) != 0)) &&
     ((*(short *)(unaff_A5 + -0x2228) == -1 && (*(short *)(unaff_A5 + -0x225e) != 1)))) {
                    // WARNING: Bad instruction - Truncating control flow here
    halt_baddata();
  }
  return;
}



// WARNING: Control flow encountered bad instruction data

void FUN_00001a0e(void)

{
  undefined4 uVar1;
  int unaff_A5;
  undefined4 uVar2;
  undefined1 auStack_86 [128];
  short local_6;
  
  local_6 = *(short *)(unaff_A5 + -0x13a4);
  uVar2 = *(undefined4 *)
           (*(short *)(**(int **)(unaff_A5 + -0x13a8) + local_6 * 0x40 + 0x22) * 4 +
           unaff_A5 + -0xffe);
  (**(code **)(unaff_A5 + 0x2fa))(uVar2,uVar2);
  (**(code **)(unaff_A5 + 0x52a))((short)auStack_86,uVar2);
  (**(code **)(unaff_A5 + 0x512))((short)auStack_86,unaff_A5 + -0x2138);
  uVar1 = (**(code **)(unaff_A5 + 0x2fa))(**(int **)(unaff_A5 + -0x13a8) + local_6 * 0x40);
  (**(code **)(unaff_A5 + 0x512))((short)auStack_86,uVar1);
  (**(code **)(unaff_A5 + 0x302))(**(int **)(unaff_A5 + -0x13a8) + local_6 * 0x40);
  (**(code **)(unaff_A5 + 0x302))(uVar2);
  (**(code **)(unaff_A5 + 0x302))(auStack_86);
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_00001bc8(undefined4 param_1,short param_2)

{
  if (((param_2 != 2) && (param_2 != 4)) && (param_2 != 8)) {
                    // WARNING: Bad instruction - Truncating control flow here
    halt_baddata();
  }
  return;
}



void FUN_00001d9e(undefined8 param_1)

{
  code *UNRECOVERED_JUMPTABLE;
  undefined2 local_6;
  
  FUN_00000120();
  for (local_6 = 0; local_6 < 10; local_6 = local_6 + 1) {
    FUN_00001bc8(param_1._2_4_,local_6);
  }
                    // WARNING: Could not recover jumptable at 0x00001ddc. Too many branches
                    // WARNING: Treating indirect jump as call
  (*UNRECOVERED_JUMPTABLE)();
  return;
}



// WARNING: Control flow encountered bad instruction data

void FUN_00001f5e(void)

{
  FUN_00000120();
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



void FUN_000020e8(void)

{
  code *UNRECOVERED_JUMPTABLE;
  
  FUN_00001f5e();
                    // WARNING: Could not recover jumptable at 0x00002102. Too many branches
                    // WARNING: Treating indirect jump as call
  (*UNRECOVERED_JUMPTABLE)();
  return;
}



void FUN_00002d86(void)

{
  short sVar1;
  int iVar2;
  undefined2 uVar3;
  int unaff_A5;
  undefined4 unaff_A6;
  
  uVar3 = (undefined2)((uint)unaff_A6 >> 0x10);
  sVar1 = (short)unaff_A5;
  (**(code **)(unaff_A5 + 0x52a))(sVar1 + -0x2174,(short)*(undefined4 *)(unaff_A5 + -0xe5e));
  iVar2 = FUN_00000588(CONCAT22(*(undefined2 *)(unaff_A5 + -0x13a4),uVar3));
  (**(code **)(unaff_A5 + 0x4a2))((short)iVar2,sVar1 + -0x2160);
  uVar3 = (**(code **)(unaff_A5 + 0x2fa))(sVar1 + -0x2160);
  (**(code **)(unaff_A5 + 0x512))(sVar1 + -0x2174,uVar3);
  (**(code **)(unaff_A5 + 0x302))(sVar1 + -0x2174);
  FUN_0000009c();
  return;
}



// WARNING: Control flow encountered bad instruction data

undefined2 FUN_00002de6(undefined4 param_1)

{
  int unaff_A5;
  undefined1 auStack_4e [74];
  
  *(undefined1 **)(unaff_A5 + -0x2226) = auStack_4e;
  if ((*(short *)(unaff_A5 + -0x12f8) == 2) && (param_1._0_2_ == -1)) {
    *(undefined2 *)(unaff_A5 + -0x13a4) = *(undefined2 *)(unaff_A5 + -0x13a4);
    return 1;
  }
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_00003124(void)

{
  int unaff_A5;
  
  *(undefined4 *)(unaff_A5 + -0x2156) = 0;
  *(undefined4 *)(unaff_A5 + -0x2152) = 0;
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_00003178(void)

{
  int unaff_A5;
  
  if (*(int *)(unaff_A5 + -0x2152) != 0) {
                    // WARNING: Bad instruction - Truncating control flow here
    halt_baddata();
  }
  if (*(int *)(unaff_A5 + -0x2156) != 0) {
    (**(code **)(unaff_A5 + 0x27a))((short)*(undefined4 *)(unaff_A5 + -0x2156));
                    // WARNING: Bad instruction - Truncating control flow here
    halt_baddata();
  }
  return;
}



// WARNING: Control flow encountered bad instruction data

undefined4 FUN_000031aa(undefined4 param_1)

{
  int iVar1;
  undefined2 uVar2;
  int unaff_A5;
  
  if ((((*(short *)(unaff_A5 + -0x12f8) != 2) && (*(short *)(unaff_A5 + -0x12b4) == 1)) &&
      (param_1._0_2_ != 3)) &&
     ((*(short *)(unaff_A5 + -0x14c2) == 0 &&
      (*(undefined2 *)(unaff_A5 + -0x14c2) = 1, *(short *)(unaff_A5 + -0x12ee) != 0)))) {
    FUN_00003124();
  }
  if ((param_1._0_2_ != 3) && (*(short *)(unaff_A5 + -0x12b4) != 0)) {
    *(undefined2 *)(unaff_A5 + -0x14c4) = 1;
  }
  uVar2 = FUN_00002de6(CONCAT22(0xffff,param_1._0_2_));
  if (*(short *)(unaff_A5 + -0x12ee) != 0) {
    FUN_00003178();
  }
  iVar1 = **(int **)(unaff_A5 + -0x13a8) + *(short *)(unaff_A5 + -0x13a4) * 0x40;
  if (*(short *)(iVar1 + 0x20) != *(short *)(unaff_A5 + -0x12b4)) {
    *(undefined2 *)(**(int **)(unaff_A5 + -0x13a8) + *(short *)(unaff_A5 + -0x13a4) * 0x40 + 0x20) =
         *(undefined2 *)(unaff_A5 + -0x12b4);
                    // WARNING: Bad instruction - Truncating control flow here
    halt_baddata();
  }
  return CONCAT22((short)((uint)iVar1 >> 0x10),uVar2);
}



// WARNING: Control flow encountered bad instruction data

void FUN_00003260(void)

{
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_00003352(void)

{
  if (*(short *)(DAT_00000904 + -0x214e) == 0) {
    FUN_00003260();
  }
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_000033d6(void)

{
  int unaff_A5;
  
  *(undefined2 *)(unaff_A5 + -0x214e) = 0;
  FUN_00000120();
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



void FUN_000035f8(void)

{
  code *UNRECOVERED_JUMPTABLE;
  
  FUN_000033d6();
                    // WARNING: Could not recover jumptable at 0x00003612. Too many branches
                    // WARNING: Treating indirect jump as call
  (*UNRECOVERED_JUMPTABLE)();
  return;
}



// WARNING: Control flow encountered bad instruction data

void FUN_00003902(void)

{
  int unaff_A5;
  
  (**(code **)(unaff_A5 + 0x2a))();
  (**(code **)(unaff_A5 + 0x32))();
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_00003a56(void)

{
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_00003a8c(void)

{
  int unaff_A5;
  
  if (*(short *)(unaff_A5 + -0x137a) == 1) {
                    // WARNING: Bad instruction - Truncating control flow here
    halt_baddata();
  }
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



undefined4 FUN_00003d42(void)

{
  undefined4 uVar1;
  int unaff_A5;
  undefined1 auStack_14 [6];
  short local_e;
  char local_b;
  
  (**(code **)(unaff_A5 + 0x1f2))(auStack_14,0);
  if ((local_b == '\0') || (local_e < 3)) {
    (**(code **)(unaff_A5 + 0x4ba))(*(undefined4 *)(unaff_A5 + -0xe52));
    uVar1 = 0;
  }
  else {
    uVar1 = 1;
  }
  return uVar1;
}


