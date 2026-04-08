typedef unsigned char   undefined;

typedef unsigned char    bool;
typedef unsigned int    uint;
typedef unsigned short    undefined2;
typedef unsigned int    undefined4;
typedef unsigned char    byte;


uint DAT_000003ae;
uint DAT_000003ba;
int *DAT_000003be;
int *DAT_000003c2;
int *DAT_000003c6;
int *DAT_000003d2;
int *DAT_0000039e;
int DAT_000003a2;
int DAT_000003a6;
int DAT_000003aa;
uint DAT_000003b2;
uint DAT_000003b6;
uint *DAT_000003ca;
int *DAT_000003ce;
int DAT_00000904;

undefined4 FUN_00000004(void)

{
  undefined1 uVar1;
  undefined2 uVar2;
  uint uVar3;
  short sVar4;
  short sVar5;
  uint *puVar6;
  int unaff_A5;
  
  puVar6 = *(uint **)(unaff_A5 + -0x1eda);
  uVar3 = 0;
  for (sVar5 = 0; sVar5 < 0x20; sVar5 = sVar5 + 1) {
    for (sVar4 = 0; sVar4 < 8; sVar4 = sVar4 + 1) {
      *puVar6 = uVar3;
      puVar6 = puVar6 + 1;
    }
    uVar3 = uVar3 >> 1 | 0x80000000;
  }
  for (sVar5 = 0; sVar5 < 0x40; sVar5 = sVar5 + 1) {
    for (sVar4 = 0; sVar4 < 8; sVar4 = sVar4 + 1) {
      uVar1 = *(undefined1 *)(unaff_A5 + -0x1ed6 + (int)(short)(sVar4 + sVar5 * 8));
      uVar2 = CONCAT11(uVar1,uVar1);
      *puVar6 = CONCAT22(uVar2,uVar2);
      puVar6 = puVar6 + 1;
    }
  }
  for (sVar5 = 0; sVar5 < 0x100; sVar5 = sVar5 + 1) {
    *(short *)(*(int *)(unaff_A5 + -0x1ede) + sVar5 * 2) = ((sVar5 >> 4) * -4 + 0x3f) * 0x20 + 0x400
    ;
  }
  return 1;
}



undefined4 FUN_000000b0(void)

{
  uint uVar1;
  undefined4 uVar2;
  int unaff_A5;
  
  if (*(int *)(unaff_A5 + -0x1eda) == 0) {
    uVar1 = FUN_000001dc(0xc00);
    *(uint *)(unaff_A5 + -0x1eda) = uVar1;
    if (uVar1 == 0) {
      return 0;
    }
  }
  if (*(int *)(unaff_A5 + -0x1ede) == 0) {
    uVar1 = FUN_000001dc(0x200);
    *(uint *)(unaff_A5 + -0x1ede) = uVar1;
    if (uVar1 == 0) {
      return 0;
    }
  }
  uVar2 = FUN_00000004();
  return uVar2;
}



undefined4 FUN_000000f4(void)

{
  uint uVar1;
  int unaff_A5;
  
  if (*(int *)(unaff_A5 + -0x1eda) == 0) {
    uVar1 = FUN_000001dc(0xc00);
    *(uint *)(unaff_A5 + -0x1eda) = uVar1;
    if (uVar1 == 0) {
      return 0;
    }
  }
  return *(undefined4 *)(unaff_A5 + -0x1eda);
}



int FUN_00000116(undefined4 param_1,undefined4 param_2)

{
  int unaff_A5;
  
  return (int)(short)((0x3f - ((short)((ushort)((param_2._0_2_ >> 8) * 7 +
                                               (param_1._2_2_ >> 8) * 0x26 +
                                               (param_1._0_2_ >> 8) * 0x13) >> 6) >> 2)) * 8) +
         unaff_A5 + -0x1ed6;
}



undefined4 FUN_0000017c(undefined4 param_1)

{
  undefined2 *puVar1;
  int unaff_A5;
  
  if (0xff < param_1._0_2_) {
    param_1._0_2_ = 0xff;
  }
  puVar1 = (undefined2 *)(*(int *)(unaff_A5 + -0x1ede) + param_1._0_2_ * 2);
  return CONCAT22((short)((uint)puVar1 >> 0x10),*puVar1);
}



undefined4 FUN_000001a2(undefined4 param_1)

{
  short *psVar1;
  short sVar2;
  int unaff_A5;
  
  sVar2 = 0;
  while( true ) {
    if (0xff < sVar2) {
      return 0;
    }
    psVar1 = (short *)(*(int *)(unaff_A5 + -0x1ede) + sVar2 * 2);
    if (param_1._0_2_ == *psVar1) break;
    sVar2 = sVar2 + 1;
  }
  return CONCAT22((short)((uint)psVar1 >> 0x10),sVar2);
}



// WARNING: Type propagation algorithm not settling

uint FUN_000001dc(int param_1)

{
  int iVar1;
  uint uVar2;
  int unaff_A5;
  int *piVar3;
  int local_14 [4];
  
  local_14[1] = 0;
  local_14[0] = 0;
  (**(code **)(unaff_A5 + 0x212))();
  piVar3 = local_14 + 1;
  if (local_14[0] < 500000) {
    local_14[0] = 0;
    (**(code **)(unaff_A5 + 0x21a))(local_14 + 1);
    piVar3 = local_14;
  }
  piVar3[0xffffffff] = 0;
  piVar3[0xfffffffe] = param_1 + 0xc;
  piVar3[0xfffffffd] = 0x20e;
  (**(code **)(unaff_A5 + 0x232))();
  iVar1 = piVar3[0xfffffffe];
  if (iVar1 == 0) {
    uVar2 = 0;
  }
  else {
    uVar2 = iVar1 + 0xcU & 0xfffffffc;
    *(int *)(uVar2 - 4) = param_1;
    *(int *)(uVar2 - 8) = iVar1;
  }
  return uVar2;
}



bool FUN_0000024c(int param_1)

{
  int unaff_A5;
  
  if (param_1 != 0) {
    (**(code **)(unaff_A5 + 0x23a))(*(undefined4 *)(param_1 + -8));
  }
  return param_1 != 0;
}



undefined4 FUN_0000026c(undefined4 param_1)

{
  undefined4 uVar1;
  undefined4 unaff_D7;
  short sVar2;
  int unaff_A5;
  
  **(int **)(unaff_A5 + -0x1cd2) = unaff_A5 + 0x192;
  uVar1 = FUN_0000017c(CONCAT22(param_1._0_2_,(short)((uint)unaff_D7 >> 0x10)));
  *(short *)(*(int *)(unaff_A5 + -0x1cd2) + 8) = (short)uVar1;
  *(undefined2 *)(*(int *)(unaff_A5 + -0x1cd2) + 10) = 0xb;
  *(short *)(*(int *)(unaff_A5 + -0x1cd2) + 0xc) =
       *(short *)(*(int *)(unaff_A5 + -0x1cce) + 4) -
       (short)(*(short *)(*(int *)(unaff_A5 + -0x1cce) + 8) *
              *(short *)(*(int *)(unaff_A5 + -0x1cce) + 6)) / 8;
  for (sVar2 = 0; sVar2 < param_1._2_2_; sVar2 = sVar2 + 1) {
    *(int *)(*(int *)(*(int *)(unaff_A5 + -0x1cd2) + 4) + sVar2 * 0xc + 8) =
         *(int *)(*(int *)(unaff_A5 + -0x1cce) + 0xc) + (sVar2 % 8) * 4;
  }
  *(short *)(*(int *)(unaff_A5 + -0x1cd2) + 0xe) = param_1._2_2_;
  *(undefined4 *)(*(int *)(unaff_A5 + -0x1cd2) + 0x10) = 0;
  *(undefined4 *)(*(int *)(unaff_A5 + -0x1cd2) + 0x14) = 0;
  return 1;
}



void FUN_00000318(undefined4 param_1,uint *param_2,int param_3)

{
  uint uVar1;
  int iVar2;
  uint uVar3;
  ushort uVar4;
  int iVar5;
  short sVar6;
  uint uVar7;
  short sVar8;
  uint unaff_D6;
  int *piVar9;
  int *piVar10;
  int iVar11;
  int unaff_A5;
  int *piVar12;
  int *piVar14;
  int *piVar13;
  
  piVar9 = (int *)(*(int *)(unaff_A5 + -0x1cd6) + 4);
  iVar2 = *(int *)(*(int *)(unaff_A5 + -0x1cd6) + 0x89c);
  piVar14 = *(int **)(*(int *)(unaff_A5 + -0x1cd2) + 4);
  sVar6 = param_1._2_2_ + -1;
  if (param_1._0_2_ == 0) {
    DAT_000003a2 = param_3;
    DAT_000003c6 = (int *)0x0;
    DAT_0000039e = piVar9;
    DAT_000003a6 = *(int *)(*(int *)(unaff_A5 + -0x1cd6) + 0x898);
    DAT_000003aa = iVar2;
    *piVar9 = iVar2;
    DAT_000003ba = unaff_D6;
    DAT_000003be = piVar9;
    DAT_000003c2 = piVar14;
    DAT_000003d2 = (int *)&stack0xfffffffc;
  }
  do {
    piVar14 = (int *)*DAT_000003c2;
    for (piVar9 = piVar14; piVar9 != (int *)0x0; piVar9 = (int *)piVar9[3]) {
      iVar2 = piVar9[2];
      *piVar9 = iVar2;
      DAT_000003c6 = DAT_000003be;
      do {
        piVar10 = DAT_000003c6;
        DAT_000003c6 = piVar10 + -1;
        *piVar10 = *DAT_000003c6;
      } while (iVar2 < *(int *)*DAT_000003c6);
      *piVar10 = (int)piVar9;
      DAT_000003be = DAT_000003be + 1;
    }
    iVar2 = DAT_000003c2[1];
    piVar9 = DAT_000003be;
    piVar10 = DAT_0000039e;
    piVar12 = DAT_0000039e;
    if (iVar2 != 0) {
      do {
        piVar13 = piVar12 + 1;
        piVar9 = piVar10;
        if (sVar6 != *(short *)(*piVar12 + 0x22)) {
          piVar9 = piVar10 + 1;
          *piVar10 = *piVar12;
        }
        piVar10 = piVar9;
        DAT_000003c6 = piVar9;
        piVar12 = piVar13;
      } while (piVar13 < DAT_000003be);
    }
    iVar5 = DAT_000003a6;
    piVar10 = DAT_0000039e;
    if (piVar14 != (int *)0x0 || (iVar2 != 0 || DAT_000003c6 != (int *)0x0)) {
      while (piVar10 < piVar9) {
        iVar2 = *piVar10;
        *(undefined2 *)(iVar2 + 0x1e) = *(undefined2 *)(*(int *)(iVar5 + 0x10) + 0x1c);
        iVar2 = *(int *)(iVar2 + 0x18);
        uVar4 = ~*(ushort *)(iVar2 + 0x20);
        *(ushort *)(iVar2 + 0x20) = uVar4;
        iVar11 = iVar5;
        if (uVar4 == 0) {
          iVar11 = *(int *)(iVar2 + 0x14);
          iVar2 = *(int *)(iVar2 + 0x10);
          *(int *)(iVar11 + 0x10) = iVar2;
          *(int *)(iVar2 + 0x14) = iVar11;
          piVar10 = piVar10 + 1;
        }
        else {
          do {
            iVar11 = *(int *)(iVar11 + 0x10);
          } while (*(short *)(iVar2 + 0x24) < *(short *)(iVar11 + 0x24));
          *(int *)(iVar2 + 0x10) = iVar11;
          DAT_000003d2 = *(int **)(iVar11 + 0x14);
          *(int **)(iVar2 + 0x14) = DAT_000003d2;
          *(int *)(iVar11 + 0x14) = iVar2;
          DAT_000003d2[4] = iVar2;
          piVar10 = piVar10 + 1;
        }
      }
      DAT_000003c6 = (int *)0x0;
      *piVar10 = DAT_000003aa;
    }
    piVar10 = DAT_000003c2 + 3;
    iVar2 = DAT_000003c2[2];
    DAT_000003b2 = 0;
    uVar7 = 0;
    DAT_000003b6 = 0;
    piVar14 = DAT_0000039e;
    do {
      DAT_000003ae = DAT_000003b6;
      DAT_000003ce = piVar14 + 1;
      DAT_000003ca = (uint *)*piVar14;
      uVar1 = *DAT_000003ca;
      uVar3 = *(uint *)(iVar2 + (short)((ushort)DAT_000003b2 & 0x3e0));
      sVar8 = (short)(uVar1 >> 0x10) - (short)uVar7;
      uVar7 = *(uint *)(iVar2 + *(short *)((int)DAT_000003ca + 0x1e));
      DAT_000003ba = uVar7 & ~uVar3 | uVar3 & DAT_000003ba;
      while (sVar8 = sVar8 + -1, sVar8 != -1) {
        *param_2 = DAT_000003ba;
        DAT_000003ba = uVar7;
        param_2 = param_2 + 1;
      }
      DAT_000003b6 = DAT_000003ca[1] + uVar1;
      uVar7 = uVar1 >> 0x10;
      DAT_000003b2 = uVar1 >> 6;
      *DAT_000003ca = DAT_000003b6;
      if ((int)DAT_000003b6 < (int)DAT_000003ae) {
        do {
          piVar12 = piVar14;
          DAT_000003c6 = piVar12 + -1;
          DAT_000003d2 = (int *)*DAT_000003c6;
          *piVar12 = (int)DAT_000003d2;
          piVar14 = DAT_000003c6;
        } while ((int)DAT_000003b6 < *DAT_000003d2);
        *piVar12 = (int)DAT_000003ca;
        DAT_000003b6 = DAT_000003ae;
      }
      piVar14 = DAT_000003ce;
    } while (DAT_000003ce <= piVar9);
    param_2 = (uint *)(DAT_000003a2 + (int)param_2);
    sVar6 = sVar6 + -1;
    DAT_000003be = piVar9;
    DAT_000003c2 = piVar10;
  } while (sVar6 != -1);
  return;
}



void FUN_00000512(void)

{
  int unaff_A5;
  
  if ((*(int *)(unaff_A5 + -0x1cd2) != 0) && (*(int *)(*(int *)(unaff_A5 + -0x1cd2) + 4) != 0)) {
    FUN_0000024c(*(int *)(*(int *)(unaff_A5 + -0x1cd2) + 4));
  }
  if ((*(int *)(unaff_A5 + -0x1cd2) != 0) && (*(int *)(*(int *)(unaff_A5 + -0x1cd2) + 0x1c) != 0)) {
    FUN_0000024c(*(int *)(*(int *)(unaff_A5 + -0x1cd2) + 0x1c));
  }
  if ((*(int *)(unaff_A5 + -0x1cd2) != 0) && (*(int *)(*(int *)(unaff_A5 + -0x1cd2) + 0x20) != 0)) {
    FUN_0000024c(*(int *)(*(int *)(unaff_A5 + -0x1cd2) + 0x20));
  }
  if (*(int *)(unaff_A5 + -0x1cd2) != 0) {
    FUN_0000024c(*(int *)(unaff_A5 + -0x1cd2));
  }
  *(undefined4 *)(unaff_A5 + -0x1cd2) = 0;
  return;
}



undefined4 FUN_00000598(undefined4 param_1)

{
  uint uVar1;
  undefined4 uVar2;
  short sVar3;
  int unaff_A5;
  
  if (*(int *)(unaff_A5 + -0x1cce) == 0) {
    return 0;
  }
  if ((*(int *)(unaff_A5 + -0x1cd2) != 0) &&
     (*(short *)(*(int *)(unaff_A5 + -0x1cd2) + 0xe) < param_1._2_2_)) {
    FUN_00000512();
  }
  if (*(int *)(unaff_A5 + -0x1cd2) == 0) {
    uVar1 = FUN_000001dc(0x24);
    *(uint *)(unaff_A5 + -0x1cd2) = uVar1;
    if (uVar1 == 0) {
      return 0;
    }
    uVar1 = FUN_000001dc(param_1._2_2_ * 0xc);
    *(uint *)(*(int *)(unaff_A5 + -0x1cd2) + 4) = uVar1;
    if (uVar1 == 0) {
      return 0;
    }
  }
  for (sVar3 = 0; sVar3 < param_1._2_2_; sVar3 = sVar3 + 1) {
    *(undefined4 *)(*(int *)(*(int *)(unaff_A5 + -0x1cd2) + 4) + sVar3 * 0xc) = 0;
    *(undefined4 *)(*(int *)(*(int *)(unaff_A5 + -0x1cd2) + 4) + sVar3 * 0xc + 4) = 0;
    *(undefined4 *)(*(int *)(*(int *)(unaff_A5 + -0x1cd2) + 4) + sVar3 * 0xc + 8) = 0;
  }
  uVar2 = FUN_0000026c(param_1);
  return uVar2;
}



undefined4 FUN_00000666(void)

{
  undefined4 uVar1;
  uint uVar2;
  int unaff_A5;
  
  if (*(int *)(unaff_A5 + -0x1cd2) == 0) {
    uVar1 = 0;
  }
  else {
    if (*(int *)(unaff_A5 + -0x1cd6) == 0) {
      uVar2 = FUN_000001dc(0x5e9c);
      *(uint *)(unaff_A5 + -0x1cd6) = uVar2;
      if (uVar2 == 0) {
        return 0;
      }
    }
    *(int *)(*(int *)(unaff_A5 + -0x1cd6) + 0x898) = *(int *)(unaff_A5 + -0x1cd6) + 0x8ac;
    *(int *)(*(int *)(unaff_A5 + -0x1cd6) + 0x89c) = *(int *)(unaff_A5 + -0x1cd6) + 0x5e74;
    *(undefined4 *)(*(int *)(*(int *)(unaff_A5 + -0x1cd6) + 0x898) + 0x10) =
         *(undefined4 *)(*(int *)(unaff_A5 + -0x1cd6) + 0x89c);
    *(undefined4 *)(*(int *)(*(int *)(unaff_A5 + -0x1cd6) + 0x89c) + 0x14) =
         *(undefined4 *)(*(int *)(unaff_A5 + -0x1cd6) + 0x898);
    **(undefined4 **)(*(int *)(unaff_A5 + -0x1cd6) + 0x898) = 0;
    *(undefined2 *)(*(int *)(*(int *)(unaff_A5 + -0x1cd6) + 0x898) + 0x1c) =
         *(undefined2 *)(*(int *)(unaff_A5 + -0x1cd2) + 8);
    *(undefined2 *)(*(int *)(*(int *)(unaff_A5 + -0x1cd6) + 0x898) + 0x1e) =
         *(undefined2 *)(*(int *)(unaff_A5 + -0x1cd2) + 8);
    *(undefined2 *)(*(int *)(*(int *)(unaff_A5 + -0x1cd6) + 0x898) + 0x22) = 0xfff6;
    **(int **)(*(int *)(unaff_A5 + -0x1cd6) + 0x89c) =
         (int)*(short *)(*(int *)(unaff_A5 + -0x1cce) + 8) <<
         (*(int *)(*(int *)(unaff_A5 + -0x1cd2) + 0x10) +
          (int)*(short *)(*(int *)(unaff_A5 + -0x1cd2) + 10) & 0x3fU);
    *(undefined2 *)(*(int *)(*(int *)(unaff_A5 + -0x1cd6) + 0x89c) + 0x1c) =
         *(undefined2 *)(*(int *)(unaff_A5 + -0x1cd2) + 8);
    *(undefined2 *)(*(int *)(*(int *)(unaff_A5 + -0x1cd6) + 0x89c) + 0x1e) =
         *(undefined2 *)(*(int *)(unaff_A5 + -0x1cd2) + 8);
    *(undefined2 *)(*(int *)(*(int *)(unaff_A5 + -0x1cd6) + 0x89c) + 0x22) = 0xfff6;
    **(undefined4 **)(unaff_A5 + -0x1cd6) = *(undefined4 *)(*(int *)(unaff_A5 + -0x1cd6) + 0x898);
    *(int *)(*(int *)(unaff_A5 + -0x1cd6) + 0x8a0) = *(int *)(unaff_A5 + -0x1cd6) + 0x8d4;
    *(undefined4 *)(*(int *)(unaff_A5 + -0x1cd6) + 0x8a4) =
         *(undefined4 *)(*(int *)(unaff_A5 + -0x1cd6) + 0x8a0);
    *(int *)(*(int *)(unaff_A5 + -0x1cd6) + 0x8a8) = *(int *)(unaff_A5 + -0x1cd6) + 0x5b7c;
    uVar1 = 1;
  }
  return uVar1;
}



undefined4 FUN_000007b0(undefined4 param_1,undefined4 param_2,undefined4 param_3)

{
  undefined4 uVar1;
  uint uVar2;
  int unaff_A5;
  
  uVar1 = FUN_000000b0();
  if ((short)uVar1 == 0) {
    uVar1 = 0;
  }
  else {
    if (*(int *)(unaff_A5 + -0x1cce) == 0) {
      uVar2 = FUN_000001dc(0x10);
      *(uint *)(unaff_A5 + -0x1cce) = uVar2;
      if (uVar2 == 0) {
        return 0;
      }
    }
    **(undefined4 **)(unaff_A5 + -0x1cce) = param_1;
    *(undefined2 *)(*(int *)(unaff_A5 + -0x1cce) + 4) = param_2._0_2_;
    *(undefined2 *)(*(int *)(unaff_A5 + -0x1cce) + 6) = 1;
    *(short *)(*(int *)(unaff_A5 + -0x1cce) + 8) = param_3._0_2_;
    *(short *)(*(int *)(unaff_A5 + -0x1cce) + 10) = param_3._2_2_;
    uVar1 = FUN_000000f4();
    *(undefined4 *)(*(int *)(unaff_A5 + -0x1cce) + 0xc) = uVar1;
    uVar1 = FUN_00000598(CONCAT22(param_2._2_2_,param_3._2_2_));
    if ((short)uVar1 == 0) {
      uVar1 = 0;
    }
    else {
      uVar1 = FUN_00000666();
      if ((short)uVar1 == 0) {
        uVar1 = 0;
      }
      else {
        *(short *)(unaff_A5 + -0x1cca) = param_3._0_2_ >> 1;
        *(short *)(unaff_A5 + -0x1cc8) = param_3._2_2_ >> 1;
        uVar1 = 1;
      }
    }
  }
  return uVar1;
}



void FUN_0000087a(undefined4 param_1)

{
  int unaff_A5;
  
  if (*(int *)(unaff_A5 + -0x1cce) != 0) {
    **(undefined4 **)(unaff_A5 + -0x1cce) = param_1;
  }
  return;
}



void FUN_000008a2(int param_1)

{
  int iVar1;
  
  iVar1 = DAT_00000904;
  if ((*(int *)(DAT_00000904 + -0x1cce) != 0) && (*(int *)(DAT_00000904 + -0x1cd2) != 0)) {
    if ((*(short *)(*(int *)(DAT_00000904 + -0x1cce) + 10) < param_1) || (param_1 < 1)) {
      param_1 = (int)*(short *)(*(int *)(DAT_00000904 + -0x1cce) + 10);
    }
    *(undefined2 *)(*(int *)(DAT_00000904 + -0x1cd2) + 0xe) = param_1._2_2_;
  }
  *(undefined2 *)(iVar1 + -0x1cc6) = *(undefined2 *)(*(int *)(iVar1 + -0x1cd2) + 0xe);
  return;
}



bool FUN_00000916(undefined2 *param_1,undefined2 *param_2)

{
  int unaff_A5;
  bool bVar1;
  
  bVar1 = *(int *)(unaff_A5 + -0x1cce) != 0;
  if (bVar1) {
    *param_1 = *(undefined2 *)(*(int *)(unaff_A5 + -0x1cce) + 8);
    *param_2 = *(undefined2 *)(*(int *)(unaff_A5 + -0x1cce) + 10);
  }
  return bVar1;
}



undefined4 FUN_00000942(undefined4 param_1)

{
  undefined4 uVar1;
  int unaff_A5;
  
  uVar1 = FUN_00000598(CONCAT22(param_1._0_2_,*(undefined2 *)(*(int *)(unaff_A5 + -0x1cd2) + 0xe)));
  if ((short)uVar1 == 0) {
    uVar1 = 0;
  }
  else {
    uVar1 = FUN_00000666();
    if ((short)uVar1 == 0) {
      uVar1 = 0;
    }
  }
  return uVar1;
}



void FUN_0000096e(void)

{
  int iVar1;
  short sVar2;
  undefined4 *puVar3;
  
  iVar1 = DAT_00000904;
  puVar3 = *(undefined4 **)(*(int *)(DAT_00000904 + -0x1cd2) + 4);
  sVar2 = *(short *)(*(int *)(DAT_00000904 + -0x1cd2) + 0xe) + -1;
  do {
    *puVar3 = 0;
    puVar3[1] = 0;
    puVar3 = puVar3 + 3;
    sVar2 = sVar2 + -1;
  } while (sVar2 != -1);
  *(undefined4 *)(*(int *)(iVar1 + -0x1cd6) + 0x8a4) =
       *(undefined4 *)(*(int *)(iVar1 + -0x1cd6) + 0x8a0);
  *(int *)(*(int *)(iVar1 + -0x1cd2) + 0x14) =
       (int)(short)(*(int *)(*(int *)(iVar1 + -0x1cd2) + 0x14) == 0);
  *(undefined2 *)(iVar1 + -0x1cc6) = 0;
  return;
}



bool FUN_000009d8(int param_1,undefined2 param_2,undefined2 param_3,int *param_4)

{
  uint uVar1;
  ushort uVar2;
  ushort uVar3;
  longlong lVar4;
  int iVar5;
  int iVar6;
  int iVar7;
  int iVar8;
  int iVar9;
  int iVar10;
  int iVar11;
  int iVar12;
  int *piVar13;
  uint uVar14;
  bool bVar15;
  int local_10;
  int local_c;
  
  iVar5 = DAT_00000904;
  uVar2 = *(ushort *)(*(int *)(DAT_00000904 + -0x1cd2) + 10);
  uVar3 = *(ushort *)(*(int *)(DAT_00000904 + -0x1cd2) + 0x12);
  uVar1 = *(uint *)(*(int *)(DAT_00000904 + -0x1cd6) + 0x8a4);
  iVar10 = (int)*(short *)(*(int *)(DAT_00000904 + -0x1cce) + 8);
  iVar7 = 0;
  iVar11 = param_1;
  piVar13 = param_4;
  while (0 < iVar11) {
    iVar12 = *piVar13 + (int)*(short *)(DAT_00000904 + -0x1cca);
    if (iVar12 < iVar10) {
      iVar10 = iVar12;
    }
    if (iVar7 < iVar12) {
      iVar7 = iVar12;
    }
    piVar13 = piVar13 + 2;
    iVar11 = iVar11 + -1;
  }
  if ((iVar7 == 0) || (*(short *)(*(int *)(DAT_00000904 + -0x1cce) + 8) == iVar10)) {
    bVar15 = false;
  }
  else if (uVar1 < *(uint *)(*(int *)(DAT_00000904 + -0x1cd6) + 0x8a8)) {
    *(undefined2 *)(uVar1 + 0x1c) = param_2;
    *(undefined2 *)(uVar1 + 0x24) = param_3;
    iVar11 = param_4[param_1 * 2 + -2] + (int)*(short *)(iVar5 + -0x1cca);
    iVar7 = param_4[param_1 * 2 + -1] + (int)*(short *)(iVar5 + -0x1cc8);
    uVar14 = uVar1;
    while (param_1 != 0) {
      iVar12 = *param_4 + (int)*(short *)(iVar5 + -0x1cca);
      iVar10 = param_4[1] + (int)*(short *)(iVar5 + -0x1cc8);
      if (iVar10 != iVar7) {
        iVar6 = iVar7;
        iVar8 = iVar11;
        iVar9 = iVar12;
        if (iVar7 < iVar10) {
          iVar6 = iVar10;
          iVar8 = iVar12;
          iVar10 = iVar7;
          iVar9 = iVar11;
          local_10 = iVar12;
        }
        if ((0 < iVar6) && (iVar10 < *(short *)(*(int *)(iVar5 + -0x1cd2) + 0xe))) {
          iVar7 = iVar10;
          if (iVar10 < 0) {
            lVar4 = (longlong)iVar10 * (longlong)(iVar8 - iVar9);
            iVar7 = 0;
            iVar9 = iVar9 - (int)(((longlong)(int)((ulonglong)lVar4 >> 0x20) << 0x20 |
                                  (longlong)(int)lVar4) / (longlong)(iVar6 - iVar10));
          }
          do {
            iVar11 = iVar6;
            if (iVar9 < 1) {
              if (0 < iVar8) {
                lVar4 = (longlong)iVar9 * (longlong)(iVar6 - iVar7);
                iVar11 = iVar7 - (int)(((longlong)(int)((ulonglong)lVar4 >> 0x20) << 0x20 |
                                       (longlong)(int)lVar4) / (longlong)(iVar8 - iVar9));
              }
              iVar9 = 0;
              local_10 = 1;
              local_c = 0;
            }
            else if (iVar9 < *(short *)(*(int *)(iVar5 + -0x1cce) + 8)) {
              if (iVar8 < 1) {
                lVar4 = (longlong)(iVar9 + -1) * (longlong)(iVar6 - iVar7);
                local_10 = 0;
                iVar11 = iVar7 - (int)(((longlong)(int)((ulonglong)lVar4 >> 0x20) << 0x20 |
                                       (longlong)(int)lVar4) / (longlong)(iVar8 - iVar9));
              }
              else if (*(short *)(*(int *)(iVar5 + -0x1cce) + 8) <= iVar8) {
                local_10 = (int)*(short *)(*(int *)(iVar5 + -0x1cce) + 8);
                lVar4 = (longlong)(iVar9 + (1 - local_10)) * (longlong)(iVar6 - iVar7);
                iVar11 = iVar7 - (int)(((longlong)(int)((ulonglong)lVar4 >> 0x20) << 0x20 |
                                       (longlong)(int)lVar4) / (longlong)(iVar8 - iVar9));
              }
              lVar4 = (longlong)(1 << (uVar2 & 0x3f)) * (longlong)(iVar8 - iVar9);
              local_c = (int)(((longlong)(int)((ulonglong)lVar4 >> 0x20) << 0x20 |
                              (longlong)(int)lVar4) / (longlong)(iVar6 - iVar7)) << (uVar3 & 0x3f);
            }
            else {
              if (iVar8 < *(short *)(*(int *)(iVar5 + -0x1cce) + 8)) {
                lVar4 = (longlong)(*(short *)(*(int *)(iVar5 + -0x1cce) + 8) - iVar9) *
                        (longlong)(iVar6 - iVar7);
                iVar11 = (int)(((longlong)(int)((ulonglong)lVar4 >> 0x20) << 0x20 |
                               (longlong)(int)lVar4) / (longlong)(iVar8 - iVar9)) + iVar7;
              }
              iVar9 = (int)*(short *)(*(int *)(iVar5 + -0x1cce) + 8);
              local_10 = iVar9 + -1;
              local_c = 0;
            }
            *(int *)(uVar14 + 4) = local_c;
            *(uint *)(uVar14 + 0x18) = uVar1;
            *(int *)(uVar14 + 8) = iVar9 << (uVar3 + uVar2 & 0x3f);
            *(undefined4 *)(uVar14 + 0xc) =
                 *(undefined4 *)(*(int *)(*(int *)(iVar5 + -0x1cd2) + 4) + iVar7 * 0xc);
            *(uint *)(*(int *)(*(int *)(iVar5 + -0x1cd2) + 4) + iVar7 * 0xc) = uVar14;
            *(short *)(uVar14 + 0x22) =
                 (*(short *)(*(int *)(iVar5 + -0x1cd2) + 0xe) - (short)iVar11) + -1;
            if (iVar11 < *(short *)(*(int *)(iVar5 + -0x1cd2) + 0xe)) {
              *(undefined4 *)(*(int *)(*(int *)(iVar5 + -0x1cd2) + 4) + iVar11 * 0xc + 4) = 1;
            }
            uVar14 = uVar14 + 0x28;
          } while ((iVar11 < iVar6) &&
                  (iVar7 = iVar11, iVar9 = local_10,
                  iVar11 < *(short *)(*(int *)(iVar5 + -0x1cd2) + 0xe)));
        }
      }
      iVar11 = *param_4 + (int)*(short *)(iVar5 + -0x1cca);
      iVar7 = param_4[1] + (int)*(short *)(iVar5 + -0x1cc8);
      param_4 = param_4 + 2;
      param_1 = param_1 + -1;
    }
    *(uint *)(*(int *)(iVar5 + -0x1cd6) + 0x8a4) = uVar14;
    bVar15 = uVar14 != uVar1;
  }
  else {
    bVar15 = false;
  }
  return bVar15;
}



void FUN_00000d02(undefined4 param_1,undefined4 param_2,undefined4 param_3)

{
  undefined4 uVar1;
  undefined4 unaff_A4;
  int local_34;
  int local_30;
  int local_2c;
  int local_28;
  int local_24;
  int local_20;
  int local_1c;
  int local_18;
  
  local_34 = (int)param_1._2_2_;
  local_30 = (int)param_2._0_2_;
  local_2c = (int)param_2._2_2_;
  local_28 = (int)param_2._0_2_;
  local_24 = (int)param_2._2_2_;
  local_20 = (int)param_3._0_2_;
  local_1c = (int)param_1._2_2_;
  local_18 = (int)param_3._0_2_;
  uVar1 = FUN_0000017c(CONCAT22(param_1._0_2_,(short)((uint)unaff_A4 >> 0x10)));
  FUN_000009d8(4,(short)uVar1,0,&local_34);
  return;
}



void FUN_00000d84(undefined4 param_1)

{
  int unaff_A5;
  undefined4 local_8;
  
  for (local_8 = *(uint *)(*(int *)(unaff_A5 + -0x1cd6) + 0x8a0);
      local_8 < *(uint *)(*(int *)(unaff_A5 + -0x1cd6) + 0x8a4); local_8 = local_8 + 0x28) {
    *(short *)(local_8 + 0x22) =
         (param_1._0_2_ + *(short *)(local_8 + 0x22)) -
         *(short *)(*(int *)(unaff_A5 + -0x1cd2) + 0xe);
  }
  return;
}



void FUN_00000dca(undefined4 param_1)

{
  int unaff_A5;
  undefined4 local_8;
  
  for (local_8 = *(uint *)(*(int *)(unaff_A5 + -0x1cd6) + 0x8a0);
      local_8 < *(uint *)(*(int *)(unaff_A5 + -0x1cd6) + 0x8a4); local_8 = local_8 + 0x28) {
    *(short *)(local_8 + 0x22) =
         *(short *)(*(int *)(unaff_A5 + -0x1cd2) + 0xe) +
         (*(short *)(local_8 + 0x22) - param_1._0_2_);
  }
  return;
}



void FUN_00000e10(int param_1,int param_2,undefined2 param_3)

{
  short sVar1;
  short sVar2;
  short sVar3;
  short sVar4;
  int iVar5;
  short sVar6;
  undefined4 unaff_D2;
  undefined2 uVar7;
  undefined4 local_e;
  undefined2 local_8;
  undefined2 local_6;
  
  iVar5 = DAT_00000904;
  uVar7 = (undefined2)((uint)unaff_D2 >> 0x10);
  if (*(int *)(DAT_00000904 + -0x1cd2) != 0) {
    *(undefined4 *)(*(int *)(*(int *)(DAT_00000904 + -0x1cd6) + 0x898) + 0x10) =
         *(undefined4 *)(*(int *)(DAT_00000904 + -0x1cd6) + 0x89c);
    *(undefined4 *)(*(int *)(*(int *)(iVar5 + -0x1cd6) + 0x89c) + 0x14) =
         *(undefined4 *)(*(int *)(iVar5 + -0x1cd6) + 0x898);
    if (param_1 == 0) {
      (*(code *)**(undefined4 **)(iVar5 + -0x1cd2))
                (*(undefined2 *)(*(int *)(iVar5 + -0x1cd2) + 0xe),
                 (short)**(undefined4 **)(iVar5 + -0x1cce),
                 *(undefined2 *)(*(int *)(iVar5 + -0x1cd2) + 0xc));
    }
    else {
      sVar1 = *(short *)(iVar5 + -0x1372);
      sVar2 = *(short *)(iVar5 + -0x137a);
      sVar3 = *(short *)(iVar5 + -0x1372);
      sVar4 = *(short *)(iVar5 + -0x137a);
      local_e = (int)*(short *)(*(int *)(iVar5 + -0x1cd2) + 0xe);
      local_8 = 0;
      do {
        if (param_2 < local_e) {
          local_6 = param_2._2_2_;
        }
        else {
          local_6 = local_e._2_2_;
        }
        sVar6 = *(short *)(*(int *)(iVar5 + -0x1cd2) + 0xe) - (local_e._2_2_ - local_6);
        FUN_00000d84(CONCAT22(sVar6,uVar7));
        (*(code *)**(undefined4 **)(iVar5 + -0x1cd2))
                  (CONCAT22(local_8,local_6),(short)param_1,
                   ((short)(sVar1 * sVar2 + 0xf) >> 4) * 2 - (short)(sVar3 * sVar4) / 8);
        local_8 = 1;
        FUN_00000dca(CONCAT22(sVar6,uVar7));
        (**(code **)(iVar5 + 0x322))
                  (param_1,*(short *)(*(int *)(iVar5 + -0x1cd2) + 0xe) - local_e,local_6,param_3);
        local_e = local_e - local_6;
      } while (local_e != 0);
    }
  }
  return;
}


