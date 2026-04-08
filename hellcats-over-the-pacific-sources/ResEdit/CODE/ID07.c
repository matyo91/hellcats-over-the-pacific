typedef unsigned char   undefined;

typedef unsigned short    undefined2;
typedef unsigned int    undefined4;
typedef unsigned char    byte;



// WARNING: Control flow encountered bad instruction data

void FUN_00000006(void)

{
                    // WARNING: Bad instruction - Truncating control flow here
  halt_baddata();
}



void FUN_00000190(void)

{
  int unaff_A5;
  undefined2 local_6;
  
  FUN_00000006();
  for (local_6 = 0; local_6 < 0x15; local_6 = local_6 + 1) {
    *(undefined4 *)(local_6 * 4 + unaff_A5 + -0x221e) =
         *(undefined4 *)((short)(local_6 + 2) * 4 + unaff_A5 + -0xf46);
  }
  for (local_6 = 0; local_6 < 6; local_6 = local_6 + 1) {
    *(undefined4 *)(local_6 * 4 + unaff_A5 + -0xffe) =
         *(undefined4 *)((short)(local_6 + 0x5e) * 4 + unaff_A5 + -0xf46);
  }
  for (local_6 = 0; local_6 < 6; local_6 = local_6 + 1) {
    *(undefined4 *)(local_6 * 4 + unaff_A5 + -0xfae) =
         *(undefined4 *)((short)(local_6 + 100) * 4 + unaff_A5 + -0xf46);
  }
  for (local_6 = 0; local_6 < 10; local_6 = local_6 + 1) {
    *(undefined4 *)(local_6 * 4 + unaff_A5 + -0xf86) =
         *(undefined4 *)((short)(local_6 + 0x6a) * 4 + unaff_A5 + -0xf46);
  }
  return;
}


