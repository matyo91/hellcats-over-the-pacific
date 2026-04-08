typedef unsigned char   undefined;

typedef unsigned int    uint;
typedef unsigned long long    ulonglong;
typedef unsigned int    undefined4;
typedef unsigned long long    undefined8;
typedef unsigned char    byte;



undefined4 FUN_00000110(void)

{
  undefined4 in_D1;
  undefined4 uStack00000004;
  
  uStack00000004 = in_D1;
  FUN_000001c2();
  return uStack00000004;
}



undefined8 FUN_00000130(void)

{
  undefined4 in_D1;
  ulonglong uVar1;
  undefined4 uStack00000004;
  
  uStack00000004 = in_D1;
  uVar1 = FUN_000001c2();
  return CONCAT44((int)uVar1,uStack00000004);
}



void FUN_00000152(void)

{
  FUN_00000194();
  return;
}



undefined8 FUN_00000172(void)

{
  undefined4 in_D1;
  uint uVar1;
  undefined4 uStack00000004;
  
  uStack00000004 = in_D1;
  uVar1 = FUN_00000194();
  return CONCAT44(uVar1,uStack00000004);
}



uint FUN_00000194(void)

{
  int iVar1;
  uint in_D0;
  uint uVar2;
  undefined2 uVar3;
  uint in_D1;
  uint uVar4;
  uint uVar5;
  uint uVar6;
  ulonglong uVar7;
  
  if ((int)in_D0 < 0) {
    if (-1 < (int)in_D1) {
      uVar7 = FUN_000001c2();
      return -(int)uVar7;
    }
    uVar7 = FUN_000001c2();
    return -(int)uVar7;
  }
  if ((int)in_D1 < 0) {
    uVar7 = FUN_000001c2();
    return (uint)uVar7;
  }
  if (in_D0 < in_D1) {
    return in_D0;
  }
  uVar3 = (undefined2)(in_D1 >> 0x10);
  if (0xffff < in_D0) {
    uVar2 = in_D0;
    uVar4 = in_D1;
    if (0xffff < in_D1) {
      do {
        uVar2 = uVar2 >> 1;
        uVar4 = uVar4 >> 1;
      } while (0xffff < uVar4);
      for (uVar2 = uVar2 / (uVar4 & 0xffff) & 0xffff;
          (uVar5 = (in_D1 & 0xffff) * uVar2, uVar4 = (in_D1 >> 0x10) * uVar2,
          uVar6 = uVar4 * 0x10000 | uVar4 >> 0x10, uVar4 = uVar6 + uVar5, CARRY4(uVar6,uVar5) ||
          (iVar1 = uVar4 - in_D0, in_D0 <= uVar4 && iVar1 != 0));
          uVar2 = (uint)(ushort)((short)uVar2 - 1)) {
      }
      return -iVar1;
    }
    return CONCAT22(uVar3,(short)(((in_D0 >> 0x10) % (in_D1 & 0xffff) << 0x10 | in_D0 & 0xffff) %
                                 (in_D1 & 0xffff)));
  }
  return CONCAT22(uVar3,(short)(in_D0 % (in_D1 & 0xffff)));
}



ulonglong FUN_000001c2(void)

{
  int iVar1;
  uint in_D0;
  undefined2 uVar2;
  uint in_D1;
  uint uVar3;
  uint uVar4;
  uint uVar5;
  uint uVar6;
  
  if (in_D0 < in_D1) {
    return (ulonglong)in_D0;
  }
  uVar2 = (undefined2)(in_D1 >> 0x10);
  if (0xffff < in_D0) {
    uVar5 = in_D0;
    uVar3 = in_D1;
    if (0xffff < in_D1) {
      do {
        uVar5 = uVar5 >> 1;
        uVar3 = uVar3 >> 1;
      } while (0xffff < uVar3);
      for (uVar5 = uVar5 / (uVar3 & 0xffff) & 0xffff;
          (uVar4 = (in_D1 & 0xffff) * uVar5, uVar3 = (in_D1 >> 0x10) * uVar5,
          uVar6 = uVar3 * 0x10000 | uVar3 >> 0x10, uVar3 = uVar6 + uVar4, CARRY4(uVar6,uVar4) ||
          (iVar1 = uVar3 - in_D0, in_D0 <= uVar3 && iVar1 != 0));
          uVar5 = (uint)(ushort)((short)uVar5 - 1)) {
      }
      return CONCAT44(uVar5,-iVar1);
    }
    uVar5 = (in_D0 >> 0x10) % (in_D1 & 0xffff) << 0x10 | in_D0 & 0xffff;
    return CONCAT44(CONCAT22((short)((in_D0 >> 0x10) / (in_D1 & 0xffff)),
                             (short)(uVar5 / (in_D1 & 0xffff))),
                    CONCAT22(uVar2,(short)(uVar5 % (in_D1 & 0xffff))));
  }
  return CONCAT44(in_D0 / (in_D1 & 0xffff),CONCAT22(uVar2,(short)(in_D0 % (in_D1 & 0xffff)))) &
         0xffffffffffff;
}


