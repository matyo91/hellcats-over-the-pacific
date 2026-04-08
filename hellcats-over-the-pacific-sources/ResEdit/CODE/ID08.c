typedef unsigned char   undefined;

typedef unsigned short    undefined2;
typedef unsigned int    undefined4;
typedef unsigned char    byte;



// WARNING: Control flow encountered bad instruction data

undefined4 FUN_00000006(void)

{
  int iVar1;
  int iVar2;
  int *piVar3;
  short sVar5;
  undefined4 uVar4;
  undefined4 *puVar6;
  undefined4 *puVar8;
  int unaff_A5;
  undefined2 *puVar10;
  undefined1 *puVar11;
  undefined1 *puVar12;
  undefined2 uStack_242;
  undefined2 local_240;
  int iStack_23e;
  undefined4 local_23a;
  undefined2 local_236;
  int iStack_234;
  undefined2 local_230;
  undefined1 auStack_22e [2];
  undefined4 uStack_22c;
  undefined2 auStack_228 [126];
  int local_12c;
  int local_128;
  undefined1 auStack_124 [260];
  int local_20;
  int local_1c;
  int local_18;
  undefined4 local_14;
  short local_10;
  undefined2 local_e;
  undefined4 local_c;
  int local_8;
  undefined4 *puVar7;
  undefined4 *puVar9;
  
  local_c = 0;
  local_230 = 0;
  iStack_234 = **(int **)(unaff_A5 + -0x13ac) + 0x2a;
  local_236 = *(undefined2 *)(**(int **)(unaff_A5 + -0x13ac) + 0x28);
  local_23a = &local_e;
  iStack_23e = 0x2c;
  (**(code **)(unaff_A5 + 0x2a2))();
  puVar10 = (undefined2 *)((int)&local_23a + 2);
  if (local_23a._0_2_ != 0) {
    local_23a = (undefined2 *)((uint)local_23a & 0xffff);
    iStack_23e = **(int **)(unaff_A5 + -0x13ac) + 0x2a;
    local_240 = 0;
    sVar5 = (short)((uint)&local_e >> 0x10);
    uStack_242 = SUB42(&local_e,0);
    (**(code **)(unaff_A5 + 0x2a2))();
    puVar10 = &uStack_242;
    if (sVar5 != 0) {
      (**(code **)(unaff_A5 + 0x4d2))
                ((short)**(undefined4 **)(unaff_A5 + -0x13ac) + 0x2a,(short)auStack_124);
      (**(code **)(unaff_A5 + 0xfa))((short)auStack_124);
      return 0;
    }
  }
  puVar11 = (undefined1 *)puVar10;
  if (*(int *)(unaff_A5 + -0x1006) != 0) {
    puVar11 = (undefined1 *)((int)puVar10 + -4);
    *(undefined4 *)((int)puVar10 + -4) = *(undefined4 *)(unaff_A5 + -0x1006);
    *(undefined4 *)((int)puVar10 + -8) = 0x80;
    (**(code **)(unaff_A5 + 0x23a))();
  }
  local_14 = 0x20;
  *(undefined2 *)(puVar11 + -2) = 0;
  *(undefined2 *)(puVar11 + -4) = local_e;
  *(undefined4 **)(puVar11 + -8) = &local_14;
  *(int *)(puVar11 + -0xc) = unaff_A5 + -0x1026;
  *(undefined4 *)(puVar11 + -0x10) = 0x98;
  (**(code **)(unaff_A5 + 0x2b2))();
  local_10 = *(short *)(puVar11 + -0xc);
  if (local_10 == 0) {
    local_18 = *(int *)(unaff_A5 + -0x101a) +
               *(int *)(unaff_A5 + -0x101e) + *(int *)(unaff_A5 + -0x1022);
    *(undefined4 *)(puVar11 + -0xe) = 0;
    *(int *)(puVar11 + -0x12) = local_18 + 4;
    *(undefined4 *)(puVar11 + -0x16) = 0xd2;
    (**(code **)(unaff_A5 + 0x232))();
    iVar1 = *(int *)(puVar11 + -0x12);
    *(int *)(unaff_A5 + -0x1006) = iVar1;
    if (iVar1 != 0) {
      *(int *)(unaff_A5 + -0x1006) =
           (4 - (*(uint *)(unaff_A5 + -0x1006) & 3) & 3) + *(int *)(unaff_A5 + -0x1006);
      local_14 = *(undefined4 *)(unaff_A5 + -0x1022);
      *(undefined2 *)(puVar11 + -0x10) = 0;
      *(undefined2 *)(puVar11 + -0x12) = local_e;
      *(undefined4 **)(puVar11 + -0x16) = &local_14;
      *(undefined4 *)(puVar11 + -0x1a) = *(undefined4 *)(unaff_A5 + -0x1006);
      *(undefined4 *)(puVar11 + -0x1e) = 0x11a;
      (**(code **)(unaff_A5 + 0x2b2))();
      puVar12 = puVar11 + -0x18;
      if (*(int *)(unaff_A5 + -0x101e) != 0) {
        local_14 = *(undefined4 *)(unaff_A5 + -0x101e);
        iVar1 = *(int *)(unaff_A5 + -0x1006);
        iVar2 = *(int *)(unaff_A5 + -0x1022);
        *(undefined2 *)(puVar11 + -0x1a) = 0;
        *(undefined2 *)(puVar11 + -0x1c) = local_e;
        *(undefined4 **)(puVar11 + -0x20) = &local_14;
        *(int *)(puVar11 + -0x24) = iVar2 + iVar1;
        *(undefined4 *)(puVar11 + -0x28) = 0x140;
        (**(code **)(unaff_A5 + 0x2b2))();
        puVar12 = puVar11 + -0x22;
      }
      local_1c = *(int *)(unaff_A5 + -0x100e) / 8;
      local_20 = *(int *)(unaff_A5 + -0x100a) / 8;
      puVar11 = puVar12;
      for (local_8 = 0; local_8 < local_20 + local_1c; local_8 = local_8 + 1) {
        local_14 = 8;
        *(undefined2 *)(puVar11 + -2) = 0;
        *(undefined2 *)(puVar11 + -4) = local_e;
        *(undefined4 **)(puVar11 + -8) = &local_14;
        *(int **)(puVar11 + -0xc) = &local_12c;
        *(undefined4 *)(puVar11 + -0x10) = 0x182;
        (**(code **)(unaff_A5 + 0x2b2))();
        if ((local_128 >> 7 & 1U) == 0) {
          if ((local_128 >> 4 & 1U) != 0) {
            *(undefined2 *)(puVar11 + -0xc) = 0;
            *(undefined4 *)(puVar11 + -0x10) = *(undefined4 *)(unaff_A5 + -0xdee);
            *(undefined4 *)(puVar11 + -0x14) = 0x1a8;
            (**(code **)(unaff_A5 + 0x4ba))();
            puVar11 = puVar11 + -10;
            goto LAB_00000226;
          }
          if ((local_128 >> 5 & 3U) != 2) {
            *(undefined2 *)(puVar11 + -0xc) = 0;
            *(undefined4 *)(puVar11 + -0x10) = *(undefined4 *)(unaff_A5 + -0xdea);
            *(undefined4 *)(puVar11 + -0x14) = 0x1fe;
            (**(code **)(unaff_A5 + 0x4ba))();
            puVar11 = puVar11 + -10;
            goto LAB_00000226;
          }
          if (local_8 < local_1c) {
            piVar3 = (int *)(local_12c + *(int *)(unaff_A5 + -0x1006));
            *piVar3 = *(int *)(unaff_A5 + -0x1006) + *piVar3;
          }
          else {
            piVar3 = (int *)(local_12c + *(int *)(unaff_A5 + -0x1022) + *(int *)(unaff_A5 + -0x1006)
                            );
            *piVar3 = *(int *)(unaff_A5 + -0x1006) + *piVar3;
          }
        }
        puVar11 = puVar11 + -10;
      }
      *(undefined2 *)(puVar11 + -2) = local_e;
      *(undefined4 *)(puVar11 + -6) = 0x21e;
      FUN_00000348(*(undefined4 *)(puVar11 + -2));
      *(undefined4 *)(puVar11 + -4) = 0x224;
      (**(code **)(unaff_A5 + 0x4c2))();
      goto LAB_0000022a;
    }
    *(undefined2 *)(puVar11 + -0x10) = 0;
    *(undefined4 *)(puVar11 + -0x14) = *(undefined4 *)(unaff_A5 + -0xdf2);
    *(undefined4 *)(puVar11 + -0x18) = 0xe8;
    (**(code **)(unaff_A5 + 0x4ba))();
    puVar11 = puVar11 + -0xe;
  }
  else {
    *(short *)(puVar11 + -0xc) = local_10;
    *(undefined4 *)(puVar11 + -0x10) = *(undefined4 *)(unaff_A5 + -0xdf6);
    *(undefined4 *)(puVar11 + -0x14) = 0xae;
    (**(code **)(unaff_A5 + 0x4ba))();
    puVar11 = puVar11 + -10;
  }
LAB_00000226:
  *(undefined4 *)(unaff_A5 + -0x1006) = 0;
LAB_0000022a:
  *(undefined2 *)(puVar11 + -2) = 0;
  *(undefined2 *)(puVar11 + -4) = local_e;
  *(undefined4 *)(puVar11 + -8) = 0x234;
  (**(code **)(unaff_A5 + 0x2aa))();
  if (*(int *)(unaff_A5 + -0x1006) != 0) {
    *(undefined4 *)(puVar11 + -6) = *(undefined4 *)(unaff_A5 + -0x1022);
    *(undefined4 *)(puVar11 + -10) = *(undefined4 *)(unaff_A5 + -0x1006);
    *(undefined4 *)(puVar11 + -0xe) = 0x24a;
    (**(code **)(unaff_A5 + 0x53a))();
    *(undefined4 *)(puVar11 + -6) = 0;
                    // WARNING: Bad instruction - Truncating control flow here
    halt_baddata();
  }
  sVar5 = 0x3e;
  puVar6 = &uStack_22c;
  puVar8 = (undefined4 *)(unaff_A5 + -0x1a24);
  do {
    puVar9 = puVar8 + 1;
    puVar7 = puVar6 + 1;
    *puVar6 = *puVar8;
    sVar5 = sVar5 + -1;
    puVar6 = puVar7;
    puVar8 = puVar9;
  } while (sVar5 != -1);
  *(undefined2 *)puVar7 = *(undefined2 *)puVar9;
  *(undefined2 *)(puVar11 + -4) = 0;
  *(undefined4 **)(puVar11 + -8) = &uStack_22c;
  *(undefined1 **)(puVar11 + -0xc) = auStack_22e;
  *(undefined4 *)(puVar11 + -0x10) = 0x2ea;
  (**(code **)(unaff_A5 + 0x2ba))();
  *(undefined4 **)(puVar11 + -0xe) = &uStack_22c;
  *(undefined4 *)(puVar11 + -0x12) = 0x2f4;
  uVar4 = (**(code **)(unaff_A5 + 0x2fa))();
  *(int *)(puVar11 + -0xe) = unaff_A5 + -0x16e2;
  *(undefined4 *)(puVar11 + -0x12) = uVar4;
  *(undefined4 *)(puVar11 + -0x16) = 0x300;
  sVar5 = (**(code **)(unaff_A5 + 0x51a))();
  if (sVar5 != 0) {
    *(undefined4 *)(puVar11 + -0xe) = 0;
    *(undefined4 **)(puVar11 + -0x12) = &local_c;
    *(undefined4 *)(puVar11 + -0x16) = 0x330;
    (**(code **)(unaff_A5 + 0x21a))();
    return 1;
  }
  *(undefined2 *)(puVar11 + -0xc) = 0x105;
  *(undefined4 *)(puVar11 + -0x10) = 0x316;
  (**(code **)(unaff_A5 + 0x47a))();
  *(undefined2 *)(puVar11 + -0xc) = 0;
  *(undefined2 *)(puVar11 + -0xe) = 0x105;
  *(undefined4 *)(puVar11 + -0x12) = 0;
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



// WARNING: Control flow encountered bad instruction data

void FUN_00000338(void)

{
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



undefined2 FUN_00000348(undefined4 param_1)

{
  int unaff_A5;
  undefined4 uVar1;
  undefined2 local_20;
  undefined2 uVar2;
  int local_c;
  int local_8;
  
  (**(code **)(unaff_A5 + 0x2ca))(&local_c,0);
  (**(code **)(unaff_A5 + 0x2c2))((short)&local_8);
  local_8 = local_8 - local_c;
  local_20 = (undefined2)((uint)local_8 >> 0x10);
  uVar2 = (undefined2)local_8;
  (**(code **)(unaff_A5 + 0x22a))(uVar2,0,param_1._0_2_);
  *(uint *)(unaff_A5 + -0x12fc) = CONCAT22(local_20,uVar2);
  uVar1 = *(undefined4 *)(unaff_A5 + -0x12fc);
  (**(code **)(unaff_A5 + 0x2b2))(uVar1,&local_8,0);
  return (short)((uint)uVar1 >> 0x10);
}



// WARNING: Control flow encountered bad instruction data

void FUN_0000039c(void)

{
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}


