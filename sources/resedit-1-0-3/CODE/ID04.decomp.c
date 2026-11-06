typedef unsigned char   undefined;

typedef unsigned char    undefined1;
typedef unsigned short    undefined2;
typedef unsigned int    undefined4;
typedef unsigned long long    undefined6;
typedef unsigned long long    undefined8;
typedef unsigned char    byte;


int DAT_00000904;

/* VERIFIED (ID04::FUN_00000006): ID04.bin 0x6..0x2c checked against an independent capstone disassembly.
 * LINK -$e; GetDItem(long 8, word $c, PEA -2, PEA -6, PEA -$e) $A98D; HiliteControl(handle, $ff) $A95D - identical to the C. */
/* Original: FUN_00000006; source: ID04.c. Recovered name: disable_dialog_control [PROVEN].
 * Ghidra could not decode this body (rebuilt as C below); decoded from ID04.bin
 * bytes at file 0x6.
 * GetDItem(dialog, item, &type, &handle, &box) ($A98D) then HiliteControl(handle, 255) ($A95D): dims the control. Args (C stack): +8 DialogPtr, +0xc short item. Callers: ID04 0x2ea0, 0x2eae (show_mission_summary_dialog).
 */
// WARNING: Control flow encountered bad instruction data

void disable_dialog_control /* Original: FUN_00000006 */ (int dlg /* param_1: DialogPtr */,short item /* param_2: item number */)

{
  short itemType;                               /* -2(A6) */
  int handle;                                   /* -6(A6) */
  short box[4];                                 /* -$e(A6): Rect */

  GetDItem(dlg,item,&itemType,&handle,box); /* $A98D */
  HiliteControl(handle,0xff);                   /* $A95D */
  return;
}



/* VERIFIED (ID04::FUN_0000002e): ID04.bin 0x2e..0x52 checked against an independent capstone disassembly.
 * LINK -$e; GetDItem(long 8, word $c, PEA -2, PEA -6, PEA -$e) $A98D; HiliteControl(handle, CLR.W) $A95D - identical to the C. */
/* Original: FUN_0000002e; source: ID04.c. Recovered name: enable_dialog_control [PROVEN].
 * Ghidra could not decode this body (rebuilt as C below); decoded from ID04.bin
 * bytes at file 0x2e.
 * GetDItem ($A98D) then HiliteControl(handle, 0) ($A95D): re-enables the control. Args: +8 DialogPtr, +0xc short item. Callers: ID04 0x1952, 0x1966.
 */
// WARNING: Control flow encountered bad instruction data

void enable_dialog_control /* Original: FUN_0000002e */ (int dlg /* param_1: DialogPtr */,short item /* param_2: item number */)

{
  short itemType;                               /* -2(A6) */
  int handle;                                   /* -6(A6) */
  short box[4];                                 /* -$e(A6): Rect */

  GetDItem(dlg,item,&itemType,&handle,box); /* $A98D */
  HiliteControl(handle,0);                      /* $A95D */
  return;
}



/* VERIFIED (ID04::FUN_00000054): ID04.bin 0x54..0x76 checked against an independent capstone disassembly.
 * LINK -$e; GetDItem(long 8, word $c, PEA -2, PEA -6, PEA -$e) $A98D; HideControl(handle) $A958 - identical to the C. */
/* Original: FUN_00000054; source: ID04.c. Recovered name: hide_dialog_control [PROVEN].
 * Ghidra could not decode this body (rebuilt as C below); decoded from ID04.bin
 * bytes at file 0x54.
 * GetDItem ($A98D) then HideControl(handle) ($A958). Args: +8 DialogPtr, +0xc short item. Callers: ID04 0x2f20, 0x2f2e, 0x2fce.
 */
// WARNING: Control flow encountered bad instruction data

void hide_dialog_control /* Original: FUN_00000054 */ (int dlg /* param_1: DialogPtr */,short item /* param_2: item number */)

{
  short itemType;                               /* -2(A6) */
  int handle;                                   /* -6(A6) */
  short box[4];                                 /* -$e(A6): Rect */

  GetDItem(dlg,item,&itemType,&handle,box); /* $A98D */
  HideControl(handle);                          /* $A958 */
  return;
}



/* VERIFIED (ID04::FUN_00000078): ID04.bin 0x78..0x9a checked against an independent capstone disassembly.
 * LINK -$e; GetDItem(long 8, word $c, PEA -2, PEA -6, PEA -$e) $A98D; ShowControl(handle) $A957 - identical to the C. */
/* Original: FUN_00000078; source: ID04.c. Recovered name: show_dialog_control [PROVEN].
 * Ghidra could not decode this body (rebuilt as C below); decoded from ID04.bin
 * bytes at file 0x78.
 * GetDItem ($A98D) then ShowControl(handle) ($A957). Args: +8 DialogPtr, +0xc short item. Callers: ID04 0x2f66, 0x2f74.
 */
// WARNING: Control flow encountered bad instruction data

void show_dialog_control /* Original: FUN_00000078 */ (int dlg /* param_1: DialogPtr */,short item /* param_2: item number */)

{
  short itemType;                               /* -2(A6) */
  int handle;                                   /* -6(A6) */
  short box[4];                                 /* -$e(A6): Rect */

  GetDItem(dlg,item,&itemType,&handle,box); /* $A98D */
  ShowControl(handle);                          /* $A957 */
  return;
}



/* VERIFIED (ID04::FUN_0000009c): ID04.bin 0x9c..0xc2 checked against an independent capstone disassembly.
 * LINK -$e; GetDItem(long 8, word $c, PEA -2, PEA -6, PEA -$e) $A98D; SetIText(handle, long $e) $A98F - identical to the C. */
/* Original: FUN_0000009c; source: ID04.c. Recovered name: set_dialog_item_text [PROVEN].
 * Ghidra could not decode this body (rebuilt as C below); decoded from ID04.bin
 * bytes at file 0x9c.
 * GetDItem ($A98D) then SetIText(handle, text) ($A98F). Args: +8 DialogPtr, +0xc short item, +0xe Pascal string pointer. Callers: ID04 0x2dda, 0x35ec, 0x37e4, 0x38b0.
 */
// WARNING: Control flow encountered bad instruction data

void set_dialog_item_text /* Original: FUN_0000009c */ (int dlg /* param_1: DialogPtr */,short item /* param_2: item number */,void *text /* param_3: Pascal string */)

{
  short itemType;                               /* -2(A6) */
  int handle;                                   /* -6(A6) */
  short box[4];                                 /* -$e(A6): Rect */

  GetDItem(dlg,item,&itemType,&handle,box); /* $A98D */
  SetIText(handle,text);                     /* $A98F */
  return;
}



/* VERIFIED (ID04::FUN_000000c4): ID04.bin 0xc4..0xea checked against an independent capstone disassembly.
 * LINK -$e; GetDItem(long 8, word $c, PEA -2, PEA -6, PEA -$e) $A98D; SetCTitle(handle, long $e) $A95F - identical to the C. */
/* Original: FUN_000000c4; source: ID04.c. Recovered name: set_dialog_control_title [PROVEN].
 * Ghidra could not decode this body (rebuilt as C below); decoded from ID04.bin
 * bytes at file 0xc4.
 * GetDItem ($A98D) then SetCTitle(handle, title) ($A95F). Args: +8 DialogPtr, +0xc short item, +0xe Pascal string pointer. Caller: ID04 0x2ece (show_mission_summary_dialog, item 3).
 */
// WARNING: Control flow encountered bad instruction data

void set_dialog_control_title /* Original: FUN_000000c4 */ (int dlg /* param_1: DialogPtr */,short item /* param_2: item number */,void *title /* param_3: Pascal string */)

{
  short itemType;                               /* -2(A6) */
  int handle;                                   /* -6(A6) */
  short box[4];                                 /* -$e(A6): Rect */

  GetDItem(dlg,item,&itemType,&handle,box); /* $A98D */
  SetCTitle(handle,title);                    /* $A95F */
  return;
}



/* VERIFIED (ID04::FUN_000000ec): ID04.bin 0xec..0x11e checked against an independent capstone disassembly.
 * LINK -$e; GetDItem(long 8, word $c, PEA -2, PEA -6, PEA -$e) $A98D; SetDItem(8, word $c, word -2, long $e, PEA -$e) $A98E - identical to the C. */
/* Original: FUN_000000ec; source: ID04.c. Recovered name: set_dialog_user_item_proc [PROVEN].
 * Ghidra could not decode this body (rebuilt as C below); decoded from ID04.bin
 * bytes at file 0xec.
 * GetDItem ($A98D) then SetDItem(dialog, item, type, proc, &box) ($A98E): keeps type and box, replaces the item handle with a user-item procedure pointer. Args: +8 DialogPtr, +0xc short item, +0xe ProcPtr. 14 callers in ID04 (e.g. 0x8a6 item 0x27 and 0x13ba item 8 with JT $142 = draw_grey_user_item; 0x2e40.. with JT $aa).
 */
// WARNING: Control flow encountered bad instruction data

void set_dialog_user_item_proc /* Original: FUN_000000ec */ (int dlg /* param_1: DialogPtr */,short item /* param_2: item number */,void *proc /* param_3: user-item procedure */)

{
  short itemType;                               /* -2(A6) */
  int handle;                                   /* -6(A6) */
  short box[4];                                 /* -$e(A6): Rect */

  GetDItem(dlg,item,&itemType,&handle,box); /* $A98D */
  SetDItem(dlg,item,itemType,proc,box); /* $A98E: same type and box, new proc */
  return;
}



/* VERIFIED (ID04::FUN_00000120): ID04.bin 0x120..0x16c checked against an independent capstone disassembly.
 * LINK -$12; -$12 = thePort; SetPort(8); GetDItem; InsetRect(-$e, -2, -2) $A8A9; PenSize(1, 1); FrameRect(-$e) $A8A1;
 * SetPort(-$12) - identical to the C. */
/* Original: FUN_00000120; source: ID04.c. Recovered name: frame_dialog_item_box [PROVEN].
 * Ghidra could not decode this body (rebuilt as C below); decoded from ID04.bin
 * bytes at file 0x120.
 * Saves thePort (A5-0x160c), SetPort(dialog) ($A873), GetDItem, InsetRect(&box, -2, -2) ($A8A9), PenSize(1, 1) ($A89B), FrameRect(&box) ($A8A1), restores the port. Draws a 1-pixel frame 2 pixels outside the item. Args: +8 DialogPtr, +0xc short item. Callers: ID04 0x1daa, 0x1df0, 0x1f70, 0x33ec.
 */
// WARNING: Control flow encountered bad instruction data

void frame_dialog_item_box /* Original: FUN_00000120 */ (int dlg /* param_1: DialogPtr */,short item /* param_2: item number */)

{
  int unaff_A5;
  int saved;                                    /* -$12(A6) */
  short itemType;                               /* -2(A6) */
  int handle;                                   /* -6(A6) */
  short box[4];                                 /* -$e(A6): Rect */

  saved = *(int *)(unaff_A5 + -0x160c);         /* thePort */
  SetPort(dlg);                             /* $A873 */
  GetDItem(dlg,item,&itemType,&handle,box); /* $A98D */
  InsetRect(box,-2,-2);                         /* $A8A9 */
  PenSize(1,1);                                 /* $A89B */
  FrameRect(box);                               /* $A8A1 */
  SetPort(saved);
  return;
}



/* VERIFIED (ID04::FUN_0000016e): ID04.bin 0x16e..0x1b6 checked against an independent capstone disassembly.
 * GetDItem(long $a, word A5-0x225e, -2, -6, -$e); PenSize(3, 3); InsetRect(-$e, -4, -4); FrameRoundRect(-$e, 16, 16)
 * $A8B0; Pascal return popping 6 - identical to the C. */
/* Original: FUN_0000016e; source: ID04.c. Recovered name: draw_default_button_outline [PROVEN].
 * Ghidra could not decode this body (rebuilt as C below); decoded from ID04.bin
 * bytes at file 0x16e.
 * Pascal user-item procedure (DialogPtr at +0xa, item at +8; pops 6 bytes). Ignores its item argument and uses the word at A5-0x225e: GetDItem, PenSize(3, 3), InsetRect(&box, -4, -4), FrameRoundRect(&box, 16, 16) ($A8B0) - the standard bold default-button ring. Reached through JT $12a (ID00 entry -> ID04 0x16e). The unexported routine at ID04 0x1b8 (C: dialog, item, default; recovered name, comment only: install_default_ring_item [STRONG INFERENCE]) installs JT $12a as a user item with SetDItem, keeping the item's type and box from GetDItem, and stores the default-button item number in A5-0x225e [PROVEN, bytes 0x1b8..0x1f0].
 */
// WARNING: Control flow encountered bad instruction data

/* Pascal user-item procedure: dlg at $a(A6), item at 8(A6); pops 6 bytes (UNLK, MOVEA.L (A7)+,A0, LEA 6(A7), JMP (A0)) */
void draw_default_button_outline /* Original: FUN_0000016e */ (int dlg,short item)

{
  int unaff_A5;
  short itemType;                               /* -2(A6) */
  int handle;                                   /* -6(A6) */
  short box[4];                                 /* -$e(A6): Rect */

  GetDItem(dlg,*(short *)(unaff_A5 + -0x225e),&itemType,&handle,box); /* $A98D: the item argument is ignored */
  PenSize(3,3);                                 /* $A89B */
  InsetRect(box,-4,-4);                         /* $A8A9 */
  FrameRoundRect(box,0x10,0x10);                /* $A8B0 */
  return;
}



/* VERIFIED (ID04::FUN_000001f2): ID04.bin 0x1f2..0x21e checked against an independent capstone disassembly.
 * GetDItem(long $a, word 8, ...); FillRect(-$e, A5-0x1624) $A8A5; Pascal return popping 6 - identical to the C. */
/* Original: FUN_000001f2; source: ID04.c. Recovered name: draw_grey_user_item [PROVEN].
 * Ghidra could not decode this body (rebuilt as C below); decoded from ID04.bin
 * bytes at file 0x1f2.
 * Pascal user-item procedure (DialogPtr at +0xa, item at +8; pops 6 bytes): GetDItem then FillRect(&box, gray) ($A8A5) with the QuickDraw pattern at A5-0x1624 (gray, next to white -0x1614 / black -0x161c) [STRONG INFERENCE for gray]. Reached through JT $142, installed by set_dialog_user_item_proc at ID04 0x8a6 and 0x13ba. [HYPOTHESIS] a grey separator / divider in a dialog.
 */
// WARNING: Control flow encountered bad instruction data

/* Pascal user-item procedure: dlg at $a(A6), item at 8(A6); pops 6 bytes (UNLK, MOVEA.L (A7)+,A0, LEA 6(A7), JMP (A0)) */
void draw_grey_user_item /* Original: FUN_000001f2 */ (int dlg,short item)

{
  int unaff_A5;
  short itemType;                               /* -2(A6) */
  int handle;                                   /* -6(A6) */
  short box[4];                                 /* -$e(A6): Rect */

  GetDItem(dlg,item,&itemType,&handle,box);     /* $A98D */
  FillRect(box,(void *)(unaff_A5 + -0x1624));   /* $A8A5, QD gray */
  return;
}



/* VERIFIED (ID04::FUN_00000220): ID04.bin 0x220..0x2be checked against an independent capstone disassembly.
 * GetDItem(8, $c, -2, -$a, -$12); copy to -$1a; -4 = right - left, -6 = right; right = (MULU.L of MOVEA.W A5-0x225c
 * and w) DIVS.L #$64 + MOVEA.W left; FillRect(-$12, A5-0x1634); left = right + 1, right = -6; FillRect(-$12, A5-0x1614);
 * InsetRect(-$1a, -1, -1); PenSize(1, 1); FrameRect(-$1a) - identical to the C. */
/* Original: FUN_00000220; source: ID04.c. Recovered name: draw_percent_bar_item [PROVEN].
 * Decoded from ID04.bin bytes at file 0x220.
 * C args: +8 DialogPtr, +0xc short item. GetDItem -> box; split = box.left + width * A5-0x225c / 100 (MULU.L / DIVS.L); FillRect(left part, dkGray A5-0x1634) ($A8A5), FillRect(right part from split + 1, white A5-0x1614); InsetRect(&box, -1, -1), PenSize(1, 1), FrameRect. A5-0x225c is a 0..100 value set by mouse tracking at 0xb3c..0xb9a (100 * (mouse - left) / width, clamped) and copied to/from settings word +0x22 of the handle A5-0x13ac and the live option A5-0x12d2 [PROVEN]. So this draws a percentage slider in the settings dialog [STRONG INFERENCE; which option it controls is open]. Callers: percent_bar_user_item_proc, 0xb9a. Body rebuilt as C below.
 */
// WARNING: Control flow encountered bad instruction data

void draw_percent_bar_item /* Original: FUN_00000220 */ (int dlg /* param_1: DialogPtr */,short item /* param_2: item number */)

{
  int unaff_A5;
  short frame[4];                               /* -$1a(A6) */
  short box[4];                                 /* -$12(A6): top, left (-$10), bottom (-$e), right (-$c) */
  int handle;                                   /* -$a(A6) */
  short right;                                  /* -6(A6) */
  short w;                                      /* -4(A6) */
  short itemType;                               /* -2(A6) */

  GetDItem(dlg,item,&itemType,&handle,box); /* $A98D */
  *(Rect *)frame = *(Rect *)box;
  w = box[3] - box[1];
  right = box[3];
  box[3] = (short)((int)w * (int)*(short *)(unaff_A5 + -0x225c) / 100 + (int)box[1]); /* MULU.L, DIVS.L #$64 */
  FillRect(box,(void *)(unaff_A5 + -0x1634));   /* $A8A5, QD dkGray: filled part */
  box[1] = box[3] + 1;
  box[3] = right;
  FillRect(box,(void *)(unaff_A5 + -0x1614));   /* QD white: the rest */
  InsetRect(frame,-1,-1);                       /* $A8A9 */
  PenSize(1,1);                                 /* $A89B */
  FrameRect(frame);                             /* $A8A1 */
  return;
}



/* VERIFIED (ID04::FUN_000002c0): ID04.bin 0x2c0..0x2da checked against an independent capstone disassembly.
 * Push word 8 then long $a, BSR 0x220, ADDQ.L #6; Pascal return popping 6 - identical to the C. */
/* Original: FUN_000002c0; source: ID04.c. Recovered name: percent_bar_user_item_proc [PROVEN].
 * Decoded from ID04.bin bytes at file 0x2c0.
 * Pascal user-item procedure (DialogPtr at +0xa, item at +8; pops 6 bytes, which Ghidra read as an unrecoverable jump table): calls draw_percent_bar_item. Reached through JT $8a (CODE 0 entry -> ID04 0x2c0).
 * The following bytes 0x2dc..0x360 (not exported by Ghidra) are set_radio_group_selection [PROVEN, bytes]: C args +8 DialogPtr, +0xc short *items, +0x10 short count, +0x12 short selected. If items[0] <= selected <= items[count - 1], for each item: GetDItem, SetCtlValue(handle, item == selected) ($A963; SEQ/NEG gives 1 or 0). Callers: 0xcc4, 0xcdc, 0xd2c, 0xd44, 0xeda, 0xf0a.
 */
/* Pascal user-item procedure: dlg at $a(A6), item at 8(A6); pops 6 bytes (UNLK, MOVEA.L (A7)+,A0, LEA 6(A7), JMP (A0)) */
void percent_bar_user_item_proc /* Original: FUN_000002c0 */ (int dlg,short item)

{
  draw_percent_bar_item(dlg,item);              /* BSR 0x220; Ghidra read the JMP (A0) return as a jump table */
  return;
}



/* VERIFIED (ID04::FUN_00000362): ID04.bin 0x362..0x3c0 checked against an independent capstone disassembly.
 * word i from 0 while i < word $10 (BLT); GetDItem(8, items[EXT.L i], -4, -8, -$10); GetCtlValue(-8) $A960 TST.W / BEQ
 * next, else D0 = items[i]; MOVEQ #-1 after the loop - identical to the C. */
/* Original: FUN_00000362; source: ID04.c. Recovered name: get_radio_group_selection [PROVEN].
 * Decoded from ID04.bin bytes at file 0x362.
 * C args: +8 DialogPtr, +0xc short *items, +0x10 short count. Returns the first items[i] whose control value (GetCtlValue $A960) is non-zero, or -1 when none is set (and when count < 1, the case Ghidra decoded) [PROVEN, bytes 0x362..0x3c0]. Body rebuilt as C below. Pairs with set_radio_group_selection (0x2dc). Callers: 0xd5a, 0xda2, 0xf20.
 */
// WARNING: Control flow encountered bad instruction data

short get_radio_group_selection /* Original: FUN_00000362 */ (int dlg /* param_1: DialogPtr */,short *items /* param_2: radio button item numbers */,short count /* param_3 */)

{
  short i;                                      /* -2(A6) */
  int handle;                                   /* -8(A6) */
  short box[4];                                 /* -$10(A6) */
  short itemType;                               /* -4(A6) */

  for (i = 0; i < count; i = i + 1) {
    GetDItem(dlg,items[i],&itemType,&handle,box); /* $A98D */
    if (GetCtlValue(handle) != 0) {             /* $A960 */
      return items[i];
    }
  }
  return -1;
}



// WARNING: Control flow encountered bad instruction data

/* VERIFIED (ID04::FUN_000003c2): ID04.bin 0x3c2..0x430 checked against an independent capstone disassembly.
 * TST.L A5-0x225a / BNE; copy A5-0x1680 Rect to A5-0x14be and -8; InsetRect(-8, 100, 100); NewWindow pushes nil, -8,
 * long A5-0xe4e, byte 1, word 3, -1, byte 1, long 0 ($A913) to A5-0x225a; SetPort, ShowWindow, JT $4aa, HideWindow -
 * identical to the C. */
/* Original: FUN_000003c2; source: ID04.c:164. Recovered name: run_with_temporary_window [STRONG INFERENCE mechanics].
 *. Ghidra truncated at $A8A9. Bytes 0x3c2..0x430 [PROVEN]:
 *   if (long A5-0x225a == 0) {
 *     A5-0x14be = screenBits.bounds (A5-0x1680, 8 bytes); r = that;
 *     InsetRect(&r, 100, 100) $A8A9;
 *     A5-0x225a = NewWindow(nil, &r, title = STR# 129 slot 62 "Hellcats"
 *       (long A5-0xe4e), visible, procID 3, (WindowPtr)-1, goAway, 0) $A913;
 *   }
 *   SetPort(w) $A873; ShowWindow(w) $A915; JT $4aa (ID02 file 0x2db8,
 *   wait_for_click_or_key); HideWindow(w) $A916. Body rebuilt as C below.
 * The window is created once and only shown around the ID02 call.
 * Note: the following unexported routine at file 0x432..0x44c (no Ghidra
 * entry) is the user of STR# 129 slot 1: if word A5-0x14a0 { JT $462 (ID02
 * 0x4d34); show_caution_alert_with_number(slot 1 "Unable to store instrument
 * panel to disk", 0); A5-0x14a0 = 0 } [PROVEN, bytes]. Jump-table slot $172, run every
 * pass of the event loop. Recovered name (comment only): report_panel_store_failure
 * [STRONG INFERENCE]; the game runtime runs it as unexported.gd id04_0432.
 */
void run_with_temporary_window /* Original: FUN_000003c2 */ (void)

{
  int unaff_A5;
  short r[4];                                   /* -8(A6) */

  if (*(int *)(unaff_A5 + -0x225a) == 0) {
    *(Rect *)(unaff_A5 + -0x14be) = *(Rect *)(unaff_A5 + -0x1680); /* screenBits.bounds */
    *(Rect *)r = *(Rect *)(unaff_A5 + -0x14be);
    InsetRect(r,100,100);                       /* $A8A9 */
    *(int *)(unaff_A5 + -0x225a) =
         NewWindow(0,r,*(int *)(unaff_A5 + -0xe4e),1,3,-1,1,0); /* $A913: visible, procID 3, goAway */
  }
  SetPort(*(int *)(unaff_A5 + -0x225a));        /* $A873 */
  ShowWindow(*(int *)(unaff_A5 + -0x225a));     /* $A915 */
  wait_for_click_or_key();                      /* JT $4aa -> ID02 0x2db8 */
  HideWindow(*(int *)(unaff_A5 + -0x225a));     /* $A916 */
  return;
}



/* VERIFIED (ID04::FUN_0000044e): ID04.bin 0x44e..0x476 checked against an independent capstone disassembly.
 * ParamText(8, nil, nil, nil) $A98B; JT $47a(word $100); StopAlert($100, nil) $A986 result in D0 - identical to the
 * C. */
/* Original: FUN_0000044e; source: ID04.c. Recovered name: show_scenery_open_error_alert [PROVEN].
 * Decoded from ID04.bin bytes at file 0x44e.
 * C arg +8: Pascal string (file name). ParamText(name, NULL, NULL, NULL) ($A98B); JT $47a(0x100) (ID02 0x442e, also called before ALRT 259 by confirm_end_mission); returns StopAlert(256, NULL) ($A986). ALRT 256 is "Unable to Open Scenery": DITL 256 text "Unable to open Hellcats scenery file '^0'." with an OK button. Reached through JT $fa (CODE 0 entry -> ID04 0x44e). Body rebuilt as C below.
 */
// WARNING: Control flow encountered bad instruction data

short show_scenery_open_error_alert /* Original: FUN_0000044e */ (void *name /* param_1: Pascal string for ^0 */)

{
  ParamText(name,0,0,0);                     /* $A98B */
  position_alert_template(0x100);               /* JT $47a -> ID02 0x442e */
  return StopAlert(0x100,0);                    /* $A986 */
}



/* VERIFIED (ID04::FUN_00000478): ID04.bin 0x478..0x4ee checked against an independent capstone disassembly.
 * GetNewDialog($83, nil, -1) to -4; JT $48a; ShowWindow; DrawDialog; CLR.W -$16; loop GetNextEvent($18, -$14) TST.B
 * BEQ: state 0 && what 3, or state 1 && what 4 -> ADDQ state; until CMPI.W #2; DisposDialog $A983 - identical to the C. */
/* Original: FUN_00000478; source: ID04.c. Recovered name: show_paused_dialog [PROVEN].
 * Decoded from ID04.bin bytes at file 0x478.
 * GetNewDialog(0x83 = DLOG 131 "Paused Dialog", NULL, (WindowPtr)-1) ($A97C); JT $48a (ID02 0x435e); ShowWindow; DrawDialog ($A981); then polls GetNextEvent(0x18 = keyDown | keyUp mask) ($A970) until it has seen a keyDown (what 3) followed by a keyUp (what 4); DisposDialog. DITL 131 text: "Paused... Press any key to continue." Reached through JT $122 (-> ID04 0x478). Body rebuilt as C below.
 */
// WARNING: Control flow encountered bad instruction data

void show_paused_dialog /* Original: FUN_00000478 */ (void)

{
  int dlg;                                      /* -4(A6) */
  short evt[8];                                 /* -$14(A6): what */
  short state;                                  /* -$16(A6) */

  dlg = GetNewDialog(0x83,0,-1);                /* $A97C: DLOG 131 */
  position_window_on_screen(dlg);               /* JT $48a -> ID02 0x435e */
  ShowWindow(dlg);                              /* $A915 */
  DrawDialog(dlg);                              /* $A981 */
  state = 0;
  do {
    if ((GetNextEvent(0x18,evt) != '\0') &&     /* $A970, keyDown | keyUp */
       (((state == 0) && (evt[0] == 3)) || ((state == 1) && (evt[0] == 4)))) {
      state = state + 1;
    }
  } while (state != 2);
  DisposDialog(dlg);                            /* $A983 */
  return;
}



// WARNING: Control flow encountered bad instruction data

/* VERIFIED (ID04::FUN_000004f0): ID04.bin 0x4f0..0x514 checked against an independent capstone disassembly.
 * JT $47a(word $101); CautionAlert($101, nil) $A988 to -2, D0 = -2 - identical to the C. */
/* Original: FUN_000004f0; source: ID04.c:205. Recovered name: ask_save_changes [STRONG INFERENCE].
 * JT $ba. Bytes 0x4f0..0x514 [PROVEN]: JT $47a(0x101) (ID02 0x442e, alert
 * centring as in show_caution_alert_with_number); return CautionAlert(257, nil)
 * $A988. ALRT 257 "Save Changes" / DITL 257 [PROVEN, resource dump in
 * artifacts/reverse-engineering/resources/resource_dasm_Hellcats_app]: item 1 "Save", 2 "Cancel", 3 "Don't Save" - matches the
 * quit_application switch (1 save, 2 cancel, else discard).
 */
short ask_save_changes /* Original: FUN_000004f0 */ (void)

{
  position_alert_template(0x101);               /* JT $47a -> ID02 0x442e */
  return CautionAlert(0x101,0);                 /* $A988 (result via a local word) */
}



// WARNING: Control flow encountered bad instruction data

/* VERIFIED (ID04::FUN_00000516): ID04.bin 0x516..0x55e checked against an independent capstone disassembly.
 * CMPI.W #3 A5-0x12f8 BLT / TST.W A5-0x14c4 -> MOVEQ #2; BSR 0x18e0 TST.W BNE else 2; JT $47a($103); CautionAlert($103,
 * nil) via -4 - identical to the C. */
/* Original: FUN_00000516; source: ID04.c:219. Recovered name: confirm_end_mission [STRONG INFERENCE].
 * JT $13a. Bytes 0x516..0x55e [PROVEN]:
 *   if (word A5-0x12f8 < 3 || word A5-0x14c4 != 0) return 2;   [no mission]
 *   if (FUN_000018e0 == 0) return 2;
 *   JT $47a(0x103); return CautionAlert(259, nil).
 * ALRT 259 "Really End Mission" / DITL 259 [PROVEN, dump]: item 1 "Cancel",
 * 2 "End Mission"; text "Are you sure you want to end the current mission
 * now?  (You will collect no points)". 2 = proceed. Callers: quit_application
 * (ID02 0x2eaa) and do_menu_command menu 2 item 9 (End Mission).
 * A5-0x12f8 >= 3 && A5-0x14c4 == 0 therefore means "mission in progress"
 * [STRONG INFERENCE].
 */
short confirm_end_mission /* Original: FUN_00000516 */ (void)

{
  int unaff_A5;
  
  if (((*(short *)(unaff_A5 + -0x12f8) < 3) || (*(short *)(unaff_A5 + -0x14c4) != 0)) ||
     (get_mission_kill_report_state() == 0)) {  /* BSR 0x18e0 */
    return 2;
  }
  position_alert_template(0x103);               /* JT $47a -> ID02 0x442e */
  return CautionAlert(0x103,0);                 /* $A988 */
}



// WARNING: Control flow encountered bad instruction data

/* VERIFIED (ID04::FUN_00000560): ID04.bin 0x560..0x584 checked against an independent capstone disassembly.
 * JT $47a(word $104); CautionAlert($104, nil) $A988 via -4 to D0 - identical to the C. */
/* Original: FUN_00000560; source: ID04.c:247. Recovered name: confirm_erase_high_scores [STRONG INFERENCE].
 * Bytes 0x560..0x584 [PROVEN]: JT $47a(0x104); return CautionAlert(260, nil).
 * ALRT 260 "Erase Hi Score" / DITL 260 [PROVEN, dump]: item 1 "Cancel",
 * 2 "Erase"; text "Are you sure you want to erase all non-active duty high
 * scores?". Ghidra lost the return value (restored below).
 */
short confirm_erase_high_scores /* Original: FUN_00000560 */ (void)

{
  position_alert_template(0x104);               /* JT $47a -> ID02 0x442e */
  return CautionAlert(0x104,0);                 /* $A988 (result via a local word) */
}



/* VERIFIED (ID04::FUN_00000588): ID04.bin 0x588..0x5e2 checked against an independent capstone disassembly.
 * CLR.L -6; word k 0..11: record = (EXT.L i ASL.L #6) + *(A5-0x13a8), MOVEA.W +$28 + 2k, MOVEA.W A5-0xf5e[k], MULU.L,
 * ADD.L to -6; D0 = -6 - identical to the C. */
/* Original: FUN_00000588; source: ID04.c:259. Recovered name: compute_pilot_score [STRONG INFERENCE].
 * Arg: word record index i (sign-extended; the C parameter is now short, Ghidra's undefined2 was unsigned).
 *   score = sum over k < 12 of (short) record[i].tally[k] * (short) weight[k]
 *   record = *(HEL1 128 handle A5-0x13a8) + i * 0x40, tallies at +0x28
 *   (12 words); weights = 12 words at A5-0xf5e (A5 initial data, not read).
 * HEL1 128 is named "Player and Score Data" in the resource dump (20 records
 * of 0x40 bytes; the shipped copy is all zero = empty roster) [PROVEN, dump].
 * Related string groups (ID07 init_string_pointer_groups) [PROVEN, dump]:
 *   A5-0xffe  slots 94-99  ranks: Ensign, Lt. Junior Grade, Lieutenant,
 *             Lt. Commander, Commander, Captain   (indexed by record +0x22)
 *   A5-0xfae  slots 100-105 status: Active, Dead, Retired, POW, Discharged, MIA
 *   A5-0xf86  slots 106-115 targets: Fighter, Bomber, Tank, AAA Battery,
 *             Vehicle, Carrier, Battleship, Cruiser, PT Boat, Runway
 * [HYPOTHESIS] tallies 0..9 count destroyed targets of those categories;
 * the remaining two tallies are UNKNOWN.
 */
int compute_pilot_score /* Original: FUN_00000588 */ (short pilot /* param_1: roster index (0x40-byte records) */)

{
  int unaff_A5;
  int score; /* local_a, -6(A6) */                                  /* -6(A6) */
  short k; /* local_6, -2(A6): tally 0..11 */                                /* -2(A6) */
  
  score = 0;
  for (k = 0; k < 0xc; k = k + 1) {
    score = (int)*(short *)(k * 2 + **(int **)(unaff_A5 + -0x13a8) + (int)pilot * 0x40 +
                             0x28) * (int)*(short *)(k * 2 + unaff_A5 + -0xf5e) + score;
                                                /* EXT.L index (signed), MULU.L of sign-extended words */
  }
  return score;
}



/* VERIFIED (ID04::FUN_000005e4): ID04.bin 0x5e4..0x642 checked against an independent capstone disassembly.
 * JSR $2a(A5) on evt->what (table 0x5f2: 3 -> 0x5fe, 6 -> 0x62c, default 0x636); key: (message AND.L #$ff) to JSR $32(A5)
 * (table 0x610: $d / 3 -> 0x620, default 0x636); 0x620: *itemHit = 1, D0 = 1; update: JT $492(evt); 0x636: D0 = 0;
 * Pascal return popping 12, MOVE.B D0 result - identical to the C. */
/* Original: FUN_000005e4; source: ID04.c. Recovered name: duty_roster_filter_proc [PROVEN].
 * Decoded from ID04.bin bytes at file 0x5e4.
 * Pascal ModalDialog filter (DialogPtr +0x10, EventRecord * +0xc, itemHit * +8; pops 0xc bytes, Boolean result); body rebuilt as C below. Switch on event->what through JT $2a = ID01 0x96 (count word, then (offset word, value word) pairs, the last offset is the default; target = offset-word address + offset; table at 0x5f2: keyDown 3 -> 0x5fe, updateEvt 6 -> 0x62c, default -> 0x636): keyDown Return (13) / Enter (3) -> *itemHit = 1, return true; updateEvt -> JT $492 (ID02 0x4d6a), false. Reached through JT $c2 (-> ID04 0x5e4).
 * The following bytes 0x644..0x9ec (not exported by Ghidra) are run_duty_roster_dialog [STRONG INFERENCE name], JT $132 (-> ID04 0x644) [PROVEN, bytes]: GetNewDialog(0x82 = DLOG 130 "Duty Roster"); JT $472; rank_pilots_by_score(scores, order); prune_inactive_pilots_beyond_ten(order); for up to ten pilots in score order whose status +0x20 == 0 (Active), row r: SetIText item 5 + r = rank name (A5-0xffe[record +0x22]), item 15 + r = pilot name (editable), item 25 + r = decimal compute_pilot_score; row -> pilot map in a local array. Current pilot = settings +0x20 (A5-0x13ac) -> A5-0x13a4; the row whose pilot equals it (and whose name is set or score non-zero) gets SelIText(item 15 + r, 0, 1000) ($A97E). Default ring on user item 2 (default 1), grey user item 39 (JT $142); ShowWindow; loop ModalDialog(JT $c2): item 3 Cancel -> DisposDialog, return 0; item 4 "Dossier..." -> show_mission_summary_dialog(pilot of the active edit field (dialog->editField + 1 - 15 = row), 0, STR# 63 "OK") - shows that pilot's summary; item 1 OK: for each row GetIText ($A990), p2c both names (ID09 0x432), compare 30 bytes (JT $502, ID02 0x434) and copy when different (JT $50a, ID02 0x3f6), c2p; if any name changed, ChangedResource + WriteResource (roster); A5-0x13a4 = pilot of the active edit field; DisposDialog; return 1.
 */
// WARNING: Control flow encountered bad instruction data

/* Pascal ModalDialog filter: dlg $10(A6), evt $c(A6), itemHit 8(A6); pops 12 bytes, BOOLEAN result byte. */
char duty_roster_filter_proc /* Original: FUN_000005e4 */ (int dlg,short *evt,short *itemHit)

{
  switch (evt[0]) {                             /* JSR $2a(A5) -> ID01 0x96 (word value table at 0x5f2) */
  case 3:                                       /* keyDown */
    switch (*(uint *)(evt + 1) & 0xff) {        /* JSR $32(A5) -> ID01 0xaa (long value table at 0x610) */
    case 3:                                     /* Enter */
    case 0xd:                                   /* Return */
      *itemHit = 1;
      return 1;
    }
    break;
  case 6:                                       /* updateEvt */
    handle_update_event(evt);                   /* JT $492 -> ID02 0x4d6a */
    break;
  }
  return 0;
}



/* VERIFIED (ID04::FUN_000009ee): ID04.bin 0x9ee..0xa8c checked against an independent capstone disassembly.
 * -$20 = long A5-0xe46; GetDItem($a, 8, -2, -6, -$16); width / height; TextSize($18) $A88A; StringWidth $A88C to -$18;
 * GetFontInfo(-$e) $A88B; MoveTo((width DIVS #2) + left - (w DIVS #2), (height DIVS #2) + top + (ascent DIVS #2)); DrawString;
 * TextSize(0); Pascal return popping 6 - identical to the C. */
/* Original: FUN_000009ee; source: ID04.c. Recovered name: draw_select_mission_title [PROVEN].
 * Decoded from ID04.bin bytes at file 0x9ee.
 * Pascal user-item procedure (DialogPtr at +0xa, item at +8; pops 6 bytes). Text = STR# 129 slot 64 "Select a Mission" (pointer A5-0xe46, kept as a Pascal string by the loader). GetDItem -> box; TextSize(24) ($A88A); w = StringWidth ($A88C); GetFontInfo ($A88B); MoveTo(box.left + width / 2 - w / 2, box.top + height / 2 + ascent / 2) ($A893); DrawString ($A884); TextSize(0). Reached through JT $11a (CODE 0 entry -> ID04 0x9ee), installed for item 4 of DLOG 129 "Scenario Selection" by run_scenario_selection_dialog (0xc66). Body rebuilt as C below.
 */
// WARNING: Control flow encountered bad instruction data

/* Pascal user-item procedure: dlg at $a(A6), item at 8(A6); pops 6 bytes (UNLK, MOVEA.L (A7)+,A0, LEA 6(A7), JMP (A0)) */
void draw_select_mission_title /* Original: FUN_000009ee */ (int dlg,short item)

{
  int unaff_A5;
  void *s;                                      /* -$20(A6): "Select a Mission" */
  short height;                                 /* -$1c(A6) */
  short width;                                  /* -$1a(A6) */
  short w;                                      /* -$18(A6) */
  short box[4];                                 /* -$16(A6): top, left (-$14), bottom (-$12), right (-$10) */
  short fi[4];                                  /* -$e(A6): FontInfo, ascent first */
  int handle;                                   /* -6(A6) */
  short itemType;                               /* -2(A6) */

  s = *(void **)(unaff_A5 + -0xe46);            /* STR# 129 slot 64 */
  GetDItem(dlg,item,&itemType,&handle,box);     /* $A98D */
  width = box[3] - box[1];
  height = box[2] - box[0];
  TextSize(0x18);                               /* $A88A */
  w = StringWidth(s);                           /* $A88C */
  GetFontInfo(fi);                              /* $A88B */
  MoveTo(((short)((int)width / 2) + box[1]) - (short)((int)w / 2),
         ((short)((int)height / 2) + box[0]) + (short)((int)fi[0] / 2)); /* $A893 */
  DrawString(s);                                /* $A884 */
  TextSize(0);
  return;
}



/* VERIFIED (ID04::FUN_00000a8e): ID04.bin 0xa8e..0xbd8 checked against an independent capstone disassembly.
 * JSR $2a(A5) table 0xa9c (3 -> 0xaac, 1 -> 0xae8, 6 -> 0xbca, default 0xbd4); key: CMPI.L #$d / #3 of message & $ff ->
 * *$10 = 1, D0 = 1; mouse: GetDItem(8, word $14, -4, -8, -$10), -$18 = thePort, SetPort(8), -$14 = where, GlobalToLocal,
 * PtInRect(-$14, -$10) TST.B BNE.W 0xba6 else SetPort(-$18), 0; loop at 0xba6 StillDown TST.B: h in [left, right] -> EXT.L
 * MULU.L #$64 DIVS.L (right - left), else 0 / 100; CMP.W A5-0x225c BEQ, else store + BSR 0x220(8, $14); GetMouse(-$14);
 * then *$10 = $14, SetPort(-$18), D0 = 1; update: JT $492(evt), 0 - identical to the C. */
/* Original: FUN_00000a8e; source: ID04.c. Recovered name: fuel_slider_dialog_filter [STRONG INFERENCE].
 * Decoded from ID04.bin bytes at file 0xa8e.
 * C args: +8 DialogPtr, +0xc EventRecord *, +0x10 short *itemHit, +0x14 short slider item; returns 1 when the event is handled. Switch on event->what through JT $2a (sparse table at 0xa9c: keyDown 3 -> 0xaac, mouseDown 1 -> 0xae8, updateEvt 6 -> 0xbca, default -> 0xbd4) [PROVEN]: keyDown Return (13) / Enter (3) -> *itemHit = 1, return 1 (the case Ghidra decoded); mouseDown -> GetDItem(slider), SetPort, GlobalToLocal(where), PtInRect ($A8AD); if inside, while StillDown ($A973): GetMouse ($A972), value = 100 * (h - left) / (right - left) clamped to 0..100, and when it changes A5-0x225c = value and draw_percent_bar_item(dialog, slider); then *itemHit = slider, return 1; updateEvt -> JT $492 (ID02 0x4d6a), return 0. The slider is the fuel bar of DLOG 129 "Scenario Selection" and DLOG 132 "Refuel" (labels "Fuel:" "E" "F" in DITL 132), so A5-0x225c = fuel load percentage [STRONG INFERENCE]. Body rebuilt as C below (Ghidra had only the keyDown case).
 */
short fuel_slider_dialog_filter /* Original: FUN_00000a8e */ (int dlg /* param_1: DialogPtr */,short *evt /* param_2: EventRecord */,short *itemHit /* param_3 */,short bar_item /* param_4: the percent-bar user item */)

{
  int unaff_A5;
  int saved;                                    /* -$18(A6) */
  short pt[2];                                  /* -$14(A6): Point v, h (-$12) */
  short box[4];                                 /* -$10(A6): top, left (-$e), bottom, right (-$a) */
  int handle;                                   /* -8(A6) */
  short itemType;                               /* -4(A6) */
  short value;                                  /* -2(A6) */

  switch (evt[0]) {                         /* JSR $2a(A5) -> ID01 0x96, table 0xa9c */
  case 3:                                       /* keyDown */
    if (((*(uint *)(evt + 1) & 0xff) == 0xd) || ((*(uint *)(evt + 1) & 0xff) == 3)) {
      *itemHit = 1;
      return 1;
    }
    break;
  case 1:                                       /* mouseDown */
    GetDItem(dlg,bar_item,&itemType,&handle,box); /* $A98D */
    saved = *(int *)(unaff_A5 + -0x160c);       /* thePort */
    SetPort(dlg);                           /* $A873 */
    *(int *)pt = *(int *)(evt + 5);         /* evt->where */
    GlobalToLocal(pt);                          /* $A871 */
    if (PtInRect(*(int *)pt,box) == '\0') {     /* $A8AD */
      SetPort(saved);
      return 0;
    }
    while (StillDown() != '\0') {               /* $A973; the first pass uses the click point */
      if ((pt[1] < box[1]) || (box[3] < pt[1])) {
        value = (pt[1] < box[1]) ? 0 : 100;
      }
      else {
        value = (short)((int)(short)(pt[1] - box[1]) * 100 / (int)(short)(box[3] - box[1]));
                                                /* MULU.L #$64, DIVS.L (quotient only) */
      }
      if (value != *(short *)(unaff_A5 + -0x225c)) {
        *(short *)(unaff_A5 + -0x225c) = value;
        draw_percent_bar_item(dlg,bar_item); /* BSR 0x220 */
      }
      GetMouse(pt);                             /* $A972 */
    }
    *itemHit = bar_item;
    SetPort(saved);
    return 1;
  case 6:                                       /* updateEvt */
    handle_update_event(evt);               /* JT $492 -> ID02 0x4d6a */
    break;
  }
  return 0;
}



/* VERIFIED (ID04::FUN_00000bda): ID04.bin 0xbda..0xc00 checked against an independent capstone disassembly.
 * Push word 5, long 8, $c, $10 (C order dlg, evt, itemHit, 5), BSR 0xa8e, LEA $e; Pascal return popping 12 with MOVE.B D0
 * - identical to the C. */
/* Original: FUN_00000bda; source: ID04.c. Recovered name: scenario_selection_filter_proc [PROVEN].
 * Decoded from ID04.bin bytes at file 0xbda.
 * Pascal ModalDialog filter (DialogPtr +0x10, EventRecord * +0xc, itemHit * +8; pops 0xc bytes and returns a Boolean byte, which Ghidra read as an unrecoverable jump table): fuel_slider_dialog_filter(dialog, event, itemHit, 5). Body rebuilt as C below. Reached through JT $112 (CODE 0 entry -> ID04 0xbda), passed at 0xcea by the code that runs GetNewDialog(0x81 = DLOG 129 "Scenario Selection", call at 0xc38), whose item 5 (dump item 4) is the percent bar (JT $8a installed at 0xc8e).
 *: the following bytes 0xc02..0xe46 (not exported by Ghidra)
 * are run_scenario_selection_dialog [STRONG INFERENCE name], reached
 * through JT $82 (CODE 0 entry -> ID04 0xc02); returns the chosen mission
 * number, or 0 on Cancel [PROVEN, bytes]:
 *   mission = settings word +0x1e (handle A5-0x13ac), 0 -> 1; fuel
 *   A5-0x12d2, 0 -> 100; A5-0x225c = fuel;
 *   dialog = GetNewDialog(0x81 = DLOG 129, NULL, (WindowPtr)-1); JT $472;
 *   0x1b8(dialog, 2, 1) default ring on user item 2, default item 1;
 *   user items: 4 -> JT $11a (ID04 0x9ee, FUN_000009ee), 19 -> JT $142
 *   draw_grey_user_item, 5 -> JT $8a fuel bar;
 *   mission 1 -> 2; set_radio_group_selection(dialog, A5-0x2256, 8,
 *   mission + 7); set_radio_group_selection(dialog, A5-0x2246, 3, 8);
 *   ShowWindow; loop ModalDialog(JT $112 scenario_selection_filter_proc):
 *     item 3 (Cancel) -> DisposDialog, return 0;
 *     item 1 (OK) -> confirm_end_mission (0x516); leave the loop only
 *       when it returns 2;
 *     other items -> set both radio groups to the item;
 *   bombs: sel(A5-0x2246) - 6 -> settings +0x24; mission: sel(A5-0x2256) - 7
 *   -> settings +0x1e; fuel A5-0x225c -> settings +0x22; current pilot
 *   A5-0x13a4 -> settings +0x20; each change sets A5-0x138a (settings
 *   dirty);
 *   DisposDialog; JT $4ca apply_settings_to_live_options (ID02 0x2a44);
 *   A5-0x14c4 (mission over) = 0; A5-0x12f8 = settings +0x1e; JT $4c2
 *   (ID02 0x212a, FUN_0000212a); return A5-0x12f8.
 * DITL 129 radio items 9..16 (dump 8..15) are "Flight School", "Bomb Base",
 * "Capture Island", "Flying Fortress", "Scramble!", "Divine Wind",
 * "Flattop", "The Duel", so mission numbers 2..9 map to them in that order
 * (item - 7) [PROVEN mapping arithmetic; STRONG INFERENCE that the A5-0x2256
 * list holds items 9..16]. This matches the summary: mission 2 (Flight
 * School) reports no kills, 5 Flying Fortress -> "The B17 has been
 * destroyed", 6 Scramble! -> Henderson field bombed. Bomb radio items 6..8
 * = "0", "1", "2" (bombs = item - 6).
 */
/* Pascal ModalDialog filter: dlg $10(A6), evt $c(A6), itemHit 8(A6); pops 12 bytes, BOOLEAN result byte. */
char scenario_selection_filter_proc /* Original: FUN_00000bda */ (int dlg,short *evt,short *itemHit)

{
  return (char)fuel_slider_dialog_filter(dlg,evt,itemHit,5); /* BSR 0xa8e; Ghidra read the JMP (A0) return
                                                     as a jump table and reversed the parameters */
}



/* VERIFIED (ID04::FUN_00000e48): ID04.bin 0xe48..0xe6e checked against an independent capstone disassembly.
 * Same as 0xbda with slider word 3 - identical to the C. */
/* Original: FUN_00000e48; source: ID04.c. Recovered name: refuel_dialog_filter_proc [PROVEN].
 * Decoded from ID04.bin bytes at file 0xe48.
 * Pascal ModalDialog filter, as scenario_selection_filter_proc but with slider item 3: fuel_slider_dialog_filter(dialog, event, itemHit, 3). Body rebuilt as C below. Reached through JT $14a (-> ID04 0xe48), passed at 0xee8 by the code that runs GetNewDialog(0x84 = DLOG 132 "Refuel", 0xe88..0xe92); item 3 (dump item 2) is the fuel bar, radio buttons "0" "1" "2" next to "Bombs:" [PROVEN placement].
 *: the following bytes 0xe70..0xf4c (not exported by Ghidra)
 * are run_refuel_dialog [STRONG INFERENCE name], reached through JT $9a
 * (CODE 0 entry -> ID04 0xe70) [PROVEN, bytes]:
 *   saves A5-0x12f8 and A5-0x12d0 in locals (never read again);
 *   A5-0x225c = fuel A5-0x12d2;
 *   dialog = GetNewDialog(0x84, NULL, (WindowPtr)-1) ($A97C);
 *   JT $472 (ID02 0x4582, also called by show_mission_summary_dialog);
 *   0x1b8(dialog, 2, 1): the default-button ring installer (user item 2,
 *     default item 1 into A5-0x225e);
 *   set_dialog_user_item_proc(dialog, 3, JT $8a percent_bar_user_item_proc);
 *   set_radio_group_selection(dialog, A5-0x2240 item list, 3, 6) - always
 *     starts with item 6 (bombs "2") selected, not with the saved count;
 *   ShowWindow ($A915);
 *   loop: ModalDialog(JT $14a refuel_dialog_filter_proc, &item) ($A991);
 *     until item == 1 (OK): set_radio_group_selection(dialog, list, 3, item)
 *     (slider hits, item 3, fall outside the radio range and do nothing);
 *   sel = get_radio_group_selection(dialog, list, 3); if sel != -1:
 *     A5-0x12d0 = sel - 4 (0..2 bombs);
 *   A5-0x12d2 = A5-0x225c (fuel %); DisposDialog ($A983).
 * So A5-0x12d2 = fuel load percentage and A5-0x12d0 = bomb count for the
 * flight, and A5-0x2240 holds the bomb radio items 4, 5, 6 [STRONG
 * INFERENCE; the list contents are A5 initial data].
 */
/* Pascal ModalDialog filter: dlg $10(A6), evt $c(A6), itemHit 8(A6); pops 12 bytes, BOOLEAN result byte. */
char refuel_dialog_filter_proc /* Original: FUN_00000e48 */ (int dlg,short *evt,short *itemHit)

{
  return (char)fuel_slider_dialog_filter(dlg,evt,itemHit,3); /* BSR 0xa8e; Ghidra read the JMP (A0) return
                                                     as a jump table and reversed the parameters */
}



/* VERIFIED (ID04::FUN_00000f4e): ID04.bin 0xf4e..0x1104 checked against an independent capstone disassembly.
 * word i 0..19: scores[i] = BSR 0x588(i), order[i] = i; i 0..18 (CMPI.W #$13 BLT.W), j = i + 1..19: pi / pj = order
 * EXT.L ASL.L #6 + roster; CMP.L scores[j] with scores[i] BGT -> swap, BNE -> next; TST.B (pi) BEQ -> swap; TST.B (pi) /
 * (pj) BEQ -> next; JT $2ea(pi, pj) TST.W BLT -> next; swap via -8 (long, then word read back from -6) - identical to
 * the C. */
/* Original: FUN_00000f4e; source: ID04.c:355. Recovered name: rank_pilots_by_score [STRONG INFERENCE].
 * Args: long scores[20] (param_1), short order[20] (param_2). For i < 20: scores[i] =
 * compute_pilot_score(i), order[i] = i; then an exchange sort (i < 19, j = i + 1..19) by
 * descending score; equal scores: an empty name at i always yields, an empty name at j
 * never does, otherwise IUCompString(name i, name j) (JT $2ea -> ID09 0x3d6, Pack6
 * selector 10) < 0 keeps the order [PROVEN]. Body rebuilt as C below (Ghidra's
 * label-and-stack version replaced). Used to build the high-score list.
 */
void rank_pilots_by_score /* Original: FUN_00000f4e */ (int *scores /* param_1: out, long score per rank */,short *order /* param_2: out, pilot index per rank */)

{
  int unaff_A5;
  char *pi;                                     /* -$c(A6) */
  char *pj;                                     /* -$10(A6) */
  int tmp;                                      /* -8(A6) */
  short i;                                      /* -2(A6) */
  short j;                                      /* -4(A6) */

  for (i = 0; i < 0x14; i = i + 1) {
    scores[i] = compute_pilot_score(i);        /* BSR 0x588 */
    order[i] = i;
  }
  for (i = 0; i < 0x13; i = i + 1) {
    for (j = i + 1; j < 0x14; j = j + 1) {
      pi = (char *)(**(int **)(unaff_A5 + -0x13a8) + (int)order[i] * 0x40);
      pj = (char *)(**(int **)(unaff_A5 + -0x13a8) + (int)order[j] * 0x40);
      if (scores[j] <= scores[i]) {
        if (scores[j] != scores[i]) continue;
        if (*pi != '\0') {                       /* tie: an empty first name always yields */
          if ((*pi == '\0') || (*pj == '\0')) continue;
          if (IUCompString(pi,pj) < 0) continue; /* JT $2ea -> ID09 0x3d6 (Pack6 selector 10) */
        }
      }
      tmp = scores[j];                         /* exchange */
      scores[j] = scores[i];
      scores[i] = tmp;
      tmp = (int)order[j];                    /* MOVEA.W to the long -8 ... */
      order[j] = order[i];
      order[i] = (short)tmp;                  /* ... read back as its low word -6 */
    }
  }
  return;
}



/* VERIFIED (ID04::FUN_00001106): ID04.bin 0x1106..0x1168 checked against an independent capstone disassembly.
 * -6 = (EXT.L i ASL.L #6) + *(A5-0x13a8); CLR.W +$22, +$20, +$24, +$26; word k 0..11 CLR.W +$28 + 2k; CLR.B (record) - identical
 * to the C. */
/* Original: FUN_00001106; source: ID04.c:427. Recovered name: reset_pilot_record [STRONG INFERENCE].
 * Arg: word i (sign-extended; parameter now short). record = *(HEL1 128) + i * 0x40:
 * clears words +0x22 (rank), +0x20, +0x24, +0x26 and the 12 tallies at +0x28, then the
 * name's length byte at +0x00 (corrected: the name is emptied).
 */
void reset_pilot_record /* Original: FUN_00001106 */ (short pilot /* param_1: roster index */)

{
  undefined1 *rec; /* puVar1, -6(A6): the pilot's 0x40-byte roster record */                           /* -6(A6) */
  int unaff_A5;
  short k; /* local_6, -2(A6): tally 0..11 */                                /* -2(A6) */
  
  rec = (undefined1 *)(**(int **)(unaff_A5 + -0x13a8) + (int)pilot * 0x40); /* EXT.L, ASL.L #6 */
  *(undefined2 *)(rec + 0x22) = 0;
  *(undefined2 *)(rec + 0x20) = 0;
  *(undefined2 *)(rec + 0x24) = 0;
  *(undefined2 *)(rec + 0x26) = 0;
  for (k = 0; k < 0xc; k = k + 1) {
    *(undefined2 *)(rec + k * 2 + 0x28) = 0;
  }
  *rec = 0;                                  /* empties the Pascal name (length byte) */
  return;
}



/* VERIFIED (ID04::FUN_0000116a): ID04.bin 0x116a..0x11fe checked against an independent capstone disassembly.
 * JT $272 HLock(A5-0x13a8); count / changed / i = 0; word i < 20: rec = order[i] EXT.L ASL.L #6 + roster, TST.W +$20
 * BEQ; D0 = count, ADDQ count, CMPI.W #$a D0 BLT; else BSR 0x1106(order[i]), changed = 1; JT $27a HUnlock; TST.W changed
 * -> ChangedResource $A9AA, WriteResource $A9B0 - identical to the C. */
/* Original: FUN_0000116a; source: ID04.c. Recovered name: prune_inactive_pilots_beyond_ten [STRONG INFERENCE].
 * Decoded from ID04.bin bytes at file 0x116a.
 * Arg +8: short order[20] (pilot indices sorted by rank_pilots_by_score). HLock(roster A5-0x13a8) (JT $272); walks order[0..19]; for each record whose status +0x20 != 0 (not Active), counts it, and every such record after the first ten is cleared with reset_pilot_record; HUnlock (JT $27a); if anything was cleared, ChangedResource ($A9AA) and WriteResource ($A9B0) on the roster [PROVEN, bytes 0x116a..0x11fe]. So the roster keeps at most ten retired / dead / POW / discharged / MIA pilots, the best scores first. Caller: ID04 0x678, right after rank_pilots_by_score at 0x66e. Ghidra stopped before the resource calls; body rebuilt as C below.
 */
// WARNING: Control flow encountered bad instruction data

void prune_inactive_pilots_beyond_ten /* Original: FUN_0000116a */ (short *order /* param_1: pilot indices sorted by rank_pilots_by_score */)

{
  int unaff_A5;
  int rec;                                      /* -$a(A6) */
  short changed;                                /* -6(A6) */
  short count;                                  /* -4(A6) */
  short i;                                      /* -2(A6) */

  HLock(*(int *)(unaff_A5 + -0x13a8));          /* JT $272 */
  count = 0;
  changed = 0;
  for (i = 0; i < 0x14; i = i + 1) {
    rec = **(int **)(unaff_A5 + -0x13a8) + (int)order[i] * 0x40;
    if (*(short *)(rec + 0x20) != 0) {          /* not Active */
      count = count + 1;
      if (9 < (short)(count - 1)) {             /* old count >= 10: the 11th and later */
        reset_pilot_record(order[i]);         /* BSR 0x1106 */
        changed = 1;
      }
    }
  }
  HUnlock(*(int *)(unaff_A5 + -0x13a8));        /* JT $27a */
  if (changed != 0) {
    ChangedResource(*(int *)(unaff_A5 + -0x13a8)); /* $A9AA */
    WriteResource(*(int *)(unaff_A5 + -0x13a8)); /* $A9B0 */
  }
  return;
}



/* VERIFIED (ID04::FUN_00001200): ID04.bin 0x1200..0x1378 checked against an independent capstone disassembly.
 * LINK -$10c; rank_pilots_by_score(-$6c, -$94); GetDItem/EraseRect; k 0..3: GetDItem(item k+4) -> colX[k] = left; JT $272;
 * GetFontInfo; i 0..19: rec = order[i]*64 + *roster; skip when name byte and scores[i] are both 0; y = row*20 + ascent + top;
 * four MoveTo/DrawString; row == 10 exits; JT $27a; Pascal return popping 6 - identical to the C. */
/* Original: FUN_00001200; source: ID04.c. Recovered name: draw_high_scores_table [PROVEN].
 * Decoded from ID04.bin bytes at file 0x1200.
 * Pascal user-item procedure (DialogPtr at +0xa, item at +8; pops 6 bytes). rank_pilots_by_score(scores, order); GetDItem -> box, EraseRect; column x = left edge of items 4..7 (DITL 134 labels "Rank", "Name", "Status", "Score"); HLock(roster) (JT $272); GetFontInfo; for pilots in score order whose name is set or whose score is non-zero, at most ten rows 20 pixels apart (baseline box.top + ascent + 20 * row): DrawString of the rank name (A5-0xffe[record +0x22]), the pilot name (record +0), the status name (A5-0xfae[record +0x20]) and the decimal score (JT $4a2); HUnlock (JT $27a) [PROVEN, bytes 0x1200..0x1378]. Reached through JT $e2 (CODE 0 entry -> ID04 0x1200); installed for item 10 of DLOG 134 "High Scores". Ghidra stopped after the first call. Body rebuilt as C below.
 * The following bytes 0x137a..0x149e (not exported by Ghidra) are run_high_scores_dialog [STRONG INFERENCE name], JT $102 (-> ID04 0x137a) [PROVEN, bytes]: GetNewDialog(0x86 = DLOG 134); JT $472; 0x1b8(dialog, 2, 1) default ring; grey user item 8 (JT $142); item 10 = this table (JT $e2); ShowWindow; loop ModalDialog(NULL): item 3 "Erase Nonactive..." -> if confirm_erase_high_scores == 2: reset_pilot_record for every record whose status +0x20 != 0 (roster locked meanwhile); if any was cleared, ChangedResource + WriteResource and InvalRect(item 10) so the table redraws; until item 1 (OK); DisposDialog.
 */
/* Pascal user-item procedure: dlg at $a(A6), item at 8(A6); pops 6 bytes (UNLK, MOVEA.L (A7)+,A0, LEA 6(A7), JMP (A0)) */
void draw_high_scores_table /* Original: FUN_00001200 */ (int dlg,short item)

{
  int unaff_A5;
  short fi[4];                                  /* -$10c(A6): FontInfo, ascent first */
  unsigned char num[100];                       /* -$104(A6): Pascal string */
  int rec;                                      /* -$a0(A6) */
  short colX[4];                                /* -$9c(A6): Rank, Name, Status, Score */
  short order[20];                              /* -$94(A6) */
  int scores[20];                               /* -$6c(A6) */
  short col[4];                                 /* -$1c(A6): label item rect */
  short box[4];                                 /* -$14(A6): top, left, bottom, right */
  int itemHandle;                               /* -$c(A6) */
  short itemType;                               /* -8(A6) */
  short y;                                      /* -6(A6) */
  short row;                                    /* -4(A6) */
  short i;                                      /* -2(A6) */

  rank_pilots_by_score(scores,order);           /* BSR 0xf4e */
  GetDItem(dlg,item,&itemType,&itemHandle,box); /* $A98D */
  EraseRect(box);                               /* $A8A3 */
  for (i = 0; i < 4; i = i + 1) {
    GetDItem(dlg,i + 4,&itemType,&itemHandle,col);
    colX[i] = col[1];                           /* left edge of label items 4..7 */
  }
  row = 0;
  HLock(*(int *)(unaff_A5 + -0x13a8));          /* JT $272: glue ID09 0x270 pops its own argument */
  GetFontInfo(fi);                              /* $A88B */
  for (i = 0; i < 0x14; i = i + 1) {
    rec = (int)order[i] * 0x40 + **(int **)(unaff_A5 + -0x13a8);  /* EXT.L, ASL.L #6, ADD.L (A0) */
    if ((*(char *)rec != '\0') || (scores[i] != 0)) {
      y = row * 0x14 + fi[0] + box[0];          /* MULS.W #20 + ascent + box.top */
      MoveTo(colX[0],y);                        /* $A893 */
      DrawString(*(unsigned char **)(unaff_A5 + -0xffe + (int)*(short *)(rec + 0x22) * 4)); /* $A884: rank name */
      MoveTo(colX[1],y);
      DrawString((unsigned char *)rec);         /* pilot name, record +0 */
      MoveTo(colX[2],y);
      DrawString(*(unsigned char **)(unaff_A5 + -0xfae + (int)*(short *)(rec + 0x20) * 4)); /* status name */
      format_int_decimal_pstring(scores[i],num); /* JT $4a2 */
      MoveTo(colX[3],y);
      DrawString(num);
      row = row + 1;
      if (row == 10) break;
    }
  }
  HUnlock(*(int *)(unaff_A5 + -0x13a8));        /* JT $27a */
  return;                                       /* Pascal JMP (A0) return */
}



/* VERIFIED (ID04::FUN_000014a0): ID04.bin 0x14a0..0x14f0 checked against an independent capstone disassembly.
 * GetDItem(8, $c, -2, -$a, -$12); EraseRect(*A5-0x223a + 8) $A8A3; TEUpdate(-$12, A5-0x223a) $A9D3; InsetRect(-2, -2);
 * PenSize(1, 1); FrameRect - identical to the C. */
/* Original: FUN_000014a0; source: ID04.c. Recovered name: draw_scrolling_text_item [PROVEN].
 * Decoded from ID04.bin bytes at file 0x14a0. Body rebuilt as C below.
 * Args (C): +8 DialogPtr, +0xc short item. GetDItem ($A98D) -> box; EraseRect(&(*A5-0x223a)->viewRect) ($A8A3, TERec +8); TEUpdate(&box, A5-0x223a) ($A9D3); InsetRect(&box, -2, -2), PenSize(1, 1), FrameRect(&box) ($A8A1). Redraws the scrolling text field and its 1-pixel frame. Caller: draw proc 0x14f2.
 */
// WARNING: Control flow encountered bad instruction data

void draw_scrolling_text_item /* Original: FUN_000014a0 */ (int dlg /* param_1: DialogPtr */,short item /* param_2 */)

{
  int unaff_A5;
  short box[4];                                 /* -$12(A6) */
  int handle;                                   /* -$a(A6) */
  short itemType;                               /* -2(A6) */

  GetDItem(dlg,item,&itemType,&handle,box); /* $A98D */
  EraseRect((void *)(**(int **)(unaff_A5 + -0x223a) + 8)); /* $A8A3: (*hTE)->viewRect */
  TEUpdate(box,*(int *)(unaff_A5 + -0x223a));   /* $A9D3 */
  InsetRect(box,-2,-2);                         /* $A8A9 */
  PenSize(1,1);                                 /* $A89B */
  FrameRect(box);                               /* $A8A1 */
  return;
}



/* VERIFIED (ID04::FUN_000014f2): ID04.bin 0x14f2..0x150c checked against an independent capstone disassembly.
 * Push word 8, long $a, BSR 0x14a0, ADDQ #6; Pascal return popping 6 - identical to the C. */
/* Original: FUN_000014f2; source: ID04.c. Recovered name: scrolling_text_user_item_proc [PROVEN].
 * Decoded from ID04.bin bytes at file 0x14f2.
 * Pascal user-item procedure (DialogPtr at +0xa, item at +8; RTS after popping 6 bytes, which Ghidra read as an unrecoverable jump table). Calls draw_scrolling_text_item(dialog, item) (body rebuilt as C below). Reached through JT $92 (CODE 0 entry -> ID04 0x14f2), installed by create_scrolling_text_item.
 */
/* Pascal user-item procedure: dlg at $a(A6), item at 8(A6); pops 6 bytes (UNLK, MOVEA.L (A7)+,A0, LEA 6(A7), JMP (A0)) */
void scrolling_text_user_item_proc /* Original: FUN_000014f2 */ (int dlg,short item)

{
  draw_scrolling_text_item(dlg,item);           /* BSR 0x14a0; Ghidra read the JMP (A0) return as a jump table */
  return;
}



/* VERIFIED (ID04::FUN_0000150e): ID04.bin 0x150e..0x1560 checked against an independent capstone disassembly.
 * -2 = (*hTE)+8 - (*hTE)+0; GetCtlValue(A5-0x2236) MULS.W (*hTE)+$18 to -4; -6 = -2 - -4; TST.W / BEQ else TEScroll(0, -6,
 * hTE) $A9DD - identical to the C. */
/* Original: FUN_0000150e; source: ID04.c. Recovered name: sync_text_scroll_to_control [PROVEN].
 * Decoded from ID04.bin bytes at file 0x150e. Body rebuilt as C below.
 * TERec of A5-0x223a: delta = viewRect.top (+8) - destRect.top (+0) - GetCtlValue(A5-0x2236) ($A960) * lineHeight (+0x18); if delta != 0, TEScroll(0, delta, hTE) ($A9DD). Scrolls the text so that its first visible line equals the scroll-bar value. Callers: 0x159e, 0x162c, 0x1744, 0x17ba.
 */
// WARNING: Control flow encountered bad instruction data

void sync_text_scroll_to_control /* Original: FUN_0000150e */ (void)

{
  int unaff_A5;
  short top;                                    /* -2(A6) */
  short pix;                                    /* -4(A6) */
  short delta;                                  /* -6(A6) */

  top = *(short *)(**(int **)(unaff_A5 + -0x223a) + 8) - *(short *)**(int **)(unaff_A5 + -0x223a);  /* viewRect.top - destRect.top */
  pix = GetCtlValue(*(int *)(unaff_A5 + -0x2236)) * *(short *)(**(int **)(unaff_A5 + -0x223a) + 0x18); /* $A960; MULS.W lineHeight */
  delta = top - pix;
  if (delta != 0) {
    TEScroll(0,delta,*(int *)(unaff_A5 + -0x223a)); /* $A9DD */
  }
  return;
}



/* VERIFIED (ID04::FUN_00001562): ID04.bin 0x1562..0x158a checked against an independent capstone disassembly.
 * No LINK, D7 saved; D7 = (*hTE)+$5e - A5-0x2232; TST.W BLE -> 0 else MOVEA.W D7; SetCtlMax(A5-0x2236, D0) $A965 -
 * identical to the C. */
/* Original: FUN_00001562; source: ID04.c. Recovered name: update_scroll_bar_maximum [PROVEN].
 * Decoded from ID04.bin bytes at file 0x1562. Body rebuilt as C below.
 * No frame (saves D7 only). max = nLines (TERec +0x5e) - visible lines (A5-0x2232), clamped to >= 0; SetCtlMax(A5-0x2236, max) ($A965). Caller: 0x159a.
 */
// WARNING: Control flow encountered bad instruction data

void update_scroll_bar_maximum /* Original: FUN_00001562 */ (void)

{
  int unaff_A5;
  short max;                                    /* D7 */

  max = *(short *)(**(int **)(unaff_A5 + -0x223a) + 0x5e) - *(short *)(unaff_A5 + -0x2232); /* nLines - visible lines */
  SetCtlMax(*(int *)(unaff_A5 + -0x2236),(0 < max) ? max : 0); /* $A965 */
  return;
}



/* VERIFIED (ID04::FUN_0000158c): ID04.bin 0x158c..0x1636 checked against an independent capstone disassembly.
 * MOVEM D5-D7; -4 = A5-0x223a; BSR 0x1562, 0x150e; D7 = GetCtlValue, D6 = D7 + A5-0x2232; selStart (+$20) CMP.W
 * lineStarts[D7] (+$60) BLT -> recentre, CMP.W lineStarts[D6] BLT -> done; recentre: D5 from 0 while selStart >=
 * lineStarts[D5] (BGE ADDQ); SetCtlValue(ctl, D5 - (A5-0x2232 DIVS #2)) $A963; BSR 0x150e - identical to the C. */
/* Original: FUN_0000158c; source: ID04.c. Recovered name: scroll_text_to_show_selection [STRONG INFERENCE].
 * Decoded from ID04.bin bytes at file 0x158c.
 * Calls update_scroll_bar_maximum and sync_text_scroll_to_control. Then, with v = GetCtlValue ($A960) and the TERec lineStarts array (+0x60): if selStart (+0x20) is before lineStarts[v] or at/after lineStarts[v + visible lines (A5-0x2232)], it finds d5 = the first line whose start is past selStart (the containing line + 1; corrected), SetCtlValue(ctl, d5 - visible/2) ($A963) and syncs again (roughly centres the insertion line). Callers: append_line_to_scrolling_text 0x18d8 and others. Ghidra stopped after the first two calls; body rebuilt as C below.
 */
// WARNING: Control flow encountered bad instruction data

void scroll_text_to_show_selection /* Original: FUN_0000158c */ (void)

{
  int unaff_A5;
  int *hTE;                                     /* -4(A6) */
  short first;                                  /* D7 */
  short last;                                   /* D6 */
  short line;                                   /* D5 */

  hTE = *(int **)(unaff_A5 + -0x223a);
  update_scroll_bar_maximum();                  /* BSR 0x1562 */
  sync_text_scroll_to_control();                /* BSR 0x150e */
  first = GetCtlValue(*(int *)(unaff_A5 + -0x2236)); /* $A960 */
  last = first + *(short *)(unaff_A5 + -0x2232);
  if ((*(short *)(*hTE + 0x20) < *(short *)(*hTE + (int)first * 2 + 0x60)) ||
     (*(short *)(*hTE + (int)last * 2 + 0x60) <= *(short *)(*hTE + 0x20))) {
                                                /* selStart outside lineStarts[first .. last) */
    for (line = 0; *(short *)(*hTE + (int)line * 2 + 0x60) <= *(short *)(*hTE + 0x20); line = line + 1) {
    }                                           /* line = the first line starting after selStart */
    SetCtlValue(*(int *)(unaff_A5 + -0x2236),line - (short)((int)*(short *)(unaff_A5 + -0x2232) / 2)); /* $A963 */
    sync_text_scroll_to_control();
  }
  return;
}



/* VERIFIED (ID04::FUN_00001638): ID04.bin 0x1638..0x16c2 checked against an independent capstone disassembly.
 * viewRect = *box (two MOVE.L to (*hTE)+8); ADDI.W #-$10 +$e; A5-0x2232 = EXT.L(bottom - top) DIVS.W lineHeight +$18;
 * bottom = top + lineHeight MULS.W A5-0x2232; destRect.right +6 = +$e; TECalText(hTE) $A9D0 - identical to the C. */
/* Original: FUN_00001638; source: ID04.c. Recovered name: fit_text_view_to_box [PROVEN].
 * Decoded from ID04.bin bytes at file 0x1638.
 * Arg +8: Rect *box. On TERec A5-0x223a: viewRect (+8) = *box; viewRect.right (+0xe) -= 16 (scroll-bar width); visible lines A5-0x2232 = viewRect height / lineHeight (+0x18); viewRect.bottom = viewRect.top + lineHeight * visible lines (whole lines only); destRect.right (+6) = viewRect.right; TECalText(hTE) ($A9D0). Caller: create_scrolling_text_item 0x1878. Ghidra stopped before TECalText (completed below).
 */
// WARNING: Control flow encountered bad instruction data

void fit_text_view_to_box /* Original: FUN_00001638 */ (undefined4 *box /* param_1: Rect (two longs) for the TextEdit view */)

{
  int te_rec; /* iVar1: *te (first use) */
  int *te; /* piVar2: TEHandle A5-0x223a */
  int unaff_A5;
  
  te = *(int **)(unaff_A5 + -0x223a);
  te_rec = *te;
  *(undefined4 *)(te_rec + 8) = *box;
  *(undefined4 *)(te_rec + 0xc) = box[1];
  *(short *)(*te + 0xe) = *(short *)(*te + 0xe) + -0x10;
  *(short *)(unaff_A5 + -0x2232) =
       (short)(*(short *)(*te + 0xc) - *(short *)(*te + 8)) / *(short *)(*te + 0x18);
  *(short *)(*te + 0xc) =
       *(short *)(*te + 8) + *(short *)(*te + 0x18) * *(short *)(unaff_A5 + -0x2232);
  *(undefined2 *)(*te + 6) = *(undefined2 *)(*te + 0xe);
  TECalText((int)te);                        /* $A9D0 */
  return;
}



/* VERIFIED (ID04::FUN_000016c4): ID04.bin 0x16c4..0x1750 checked against an independent capstone disassembly.
 * TST.W part / BEQ.W out; -2 = EXT.L(bottom - top of (*hTE)+8) DIVS.W lineHeight +$18, SUBQ #1; JSR $3a(A5) table 0x16fe
 * (20 -> 0x170c -1, 21 -> 0x1714 +1, 22 -> 0x171c NEG -2, 23 -> 0x1728 -2, default 0x172e); SetCtlValue(ctl, GetCtlValue(ctl)
 * + -4); BSR 0x150e; Pascal return popping 6 - identical to the C. The click handler after it (0x1752..0x17e4) has no
 * inventory entry. */
/* Original: FUN_000016c4; source: ID04.c. Recovered name: scroll_bar_action_proc [PROVEN].
 * Decoded from ID04.bin bytes at file 0x16c4.
 * Pascal control action procedure (ControlHandle at +0xa, part code at +8; pops 6 bytes). Reached through JT $16a (CODE 0 entry -> ID04 0x16c4), passed to TrackControl by the click handler at 0x1752. If part != 0: page = visible lines - 1, then a switch through the ID01 helper (JSR $3a(A5)); its inline table at file 0x16fe is lo 20, hi 23, default +0x2c, cases 20 inUpButton -> -1, 21 inDownButton -> +1, 22 inPageUp -> -page, 23 inPageDown -> +page. Ghidra had decoded that table as stores through unaff_A4 (artifacts, not real stores); body rebuilt as C below. Then SetCtlValue(ctl, GetCtlValue(ctl) + delta) and sync_text_scroll_to_control. The default path (part outside 20..23) adds the uninitialised local delta (original behaviour, bytes 0x1702/0x172e).
 * The code that follows in this Ghidra range (file 0x1752..0x17e4, not exported as a function) is the click handler (recovered name, comment only: track_summary_text_click [STRONG INFERENCE]): C args +8 DialogPtr, +0xc EventRecord *; GetPort/SetPort, GlobalToLocal(where) ($A871), FindControl ($A96C); returns 0 when no control or another control is hit; on the scroll bar A5-0x2236: inThumb (129) -> TrackControl(ctl, where, NULL) ($A968) then sync, else TrackControl(ctl, where, JT $16a); returns 1 when handled; restores the port [PROVEN, bytes].
 */
// WARNING: Control flow encountered bad instruction data

/* Pascal control action procedure: ctl at $a(A6), part at 8(A6); pops 6 bytes (JMP (A0) return). */
void scroll_bar_action_proc /* Original: FUN_000016c4 */ (int ctl,short part)

{
  int unaff_A5;
  short page;                                   /* -2(A6) */
  short delta;                                  /* -4(A6): uninitialised on the default path */

  if (part != 0) {
    page = (short)((int)(short)(*(short *)(**(int **)(unaff_A5 + -0x223a) + 0xc) -
                                *(short *)(**(int **)(unaff_A5 + -0x223a) + 8)) /
                   (int)*(short *)(**(int **)(unaff_A5 + -0x223a) + 0x18)) + -1; /* visible lines - 1 */
    switch (part) {                             /* JSR $3a(A5) -> ID01 0xbe, table 0x16fe lo 20 hi 23 */
    case 0x14:                                  /* inUpButton */
      delta = -1;
      break;
    case 0x15:                                  /* inDownButton */
      delta = 1;
      break;
    case 0x16:                                  /* inPageUp */
      delta = -page;
      break;
    case 0x17:                                  /* inPageDown */
      delta = page;
      break;
    }
    SetCtlValue(ctl,GetCtlValue(ctl) + delta);  /* $A960 / $A963 */
    sync_text_scroll_to_control();              /* BSR 0x150e */
  }
  return;
}



/* VERIFIED (ID04::FUN_000017e6): ID04.bin 0x17e6..0x189a checked against an independent capstone disassembly.
 * GetDItem(8, $c, -2, -$a, -$12); copy to -$1a, left -$18 = right - 16; InsetRect(-$1a, 0, -2); OffsetRect(-$1a, 2, 0) $A8A8;
 * GetPort(-$1e); SetPort(8); TENew(-$12, -$12) $A9D2 to A5-0x223a; NewControl(8, -$1a, A5-0x213c, byte 1, 0, 0, 0, $10, 0)
 * $A954 to A5-0x2236; BSR 0x1638(-$12); BSR 0xec(8, $c, $92(A5)); SetPort(-$1e) - identical to the C. */
/* Original: FUN_000017e6; source: ID04.c. Recovered name: create_scrolling_text_item [STRONG INFERENCE].
 * Ghidra could not decode this body (rebuilt as C below); decoded from ID04.bin
 * bytes at file 0x17e6.
 * Args (C): +8 DialogPtr, +0xc short item. GetDItem ($A98D) -> box; scroll-bar rect = box with left = box.right - 16, InsetRect(0, -2) ($A8A9), OffsetRect(2, 0) ($A8A8). GetPort/SetPort(dialog). TENew(&box, &box) ($A9D2) -> TEHandle A5-0x223a [PROVEN]. NewControl(dialog, &barRect, title A5-0x213c, visible 1, value/min/max 0, procID 16 = scrollBarProc, refCon 0) ($A954) -> ControlHandle A5-0x2236 [PROVEN]. JSR 0x1638 (FUN_00001638, adjusts the TE rects to the box, -16 right). Installs JT $92 (-> ID04 0x14f2) as the item user-item procedure via set_dialog_user_item_proc, then restores the port. Caller: show_mission_summary_dialog 0x2ebc. [STRONG INFERENCE] the scrolling text field of DLOG 133 (mission awards / narrative, cf. its "Skip Text" button).
 */
// WARNING: Control flow encountered bad instruction data

void create_scrolling_text_item /* Original: FUN_000017e6 */ (int dlg /* param_1: DialogPtr */,short item /* param_2 */)

{
  int unaff_A5;
  int saved;                                    /* -$1e(A6) */
  short bar[4];                                 /* -$1a(A6): top, left (-$18), bottom, right */
  short box[4];                                 /* -$12(A6): right at -$c */
  int handle;                                   /* -$a(A6) */
  short itemType;                               /* -2(A6) */

  GetDItem(dlg,item,&itemType,&handle,box); /* $A98D */
  *(Rect *)bar = *(Rect *)box;
  bar[1] = box[3] + -0x10;                      /* 16-pixel bar on the right edge */
  InsetRect(bar,0,-2);                          /* $A8A9 */
  OffsetRect(bar,2,0);                          /* $A8A8 */
  GetPort(&saved);                              /* $A874 */
  SetPort(dlg);                             /* $A873 */
  *(int *)(unaff_A5 + -0x223a) = TENew(box,box); /* $A9D2: destRect, viewRect */
  *(int *)(unaff_A5 + -0x2236) =
       NewControl(dlg,bar,(void *)(unaff_A5 + -0x213c),1,0,0,0,0x10,0); /* $A954, scrollBarProc */
  fit_text_view_to_box((undefined4 *)box);      /* BSR 0x1638 */
  set_dialog_user_item_proc(dlg,item,(void *)(unaff_A5 + 0x92)); /* BSR 0xec; JT $92 -> 0x14f2 */
  SetPort(saved);
  return;
}



/* VERIFIED (ID04::FUN_0000189c): ID04.bin 0x189c..0x18ae checked against an independent capstone disassembly.
 * TEDispose(A5-0x223a) $A9CD; DisposeControl(A5-0x2236) $A955 - identical to the C. */
/* Original: FUN_0000189c; source: ID04.c. Recovered name: dispose_scrolling_text_item [PROVEN].
 * Ghidra could not decode this body (rebuilt as C below); decoded from ID04.bin
 * bytes at file 0x189c.
 * TEDispose(A5-0x223a) ($A9CD) then DisposeControl(A5-0x2236) ($A955): releases what create_scrolling_text_item allocated. No direct JSR found in ID04 bytes [UNKNOWN caller path].
 */
// WARNING: Control flow encountered bad instruction data

void dispose_scrolling_text_item /* Original: FUN_0000189c */ (void)

{
  int unaff_A5;

  TEDispose(*(int *)(unaff_A5 + -0x223a));      /* $A9CD */
  DisposeControl(*(int *)(unaff_A5 + -0x2236)); /* $A955 */
  return;
}



/* VERIFIED (ID04::FUN_000018b0): ID04.bin 0x18b0..0x18de checked against an independent capstone disassembly.
 * JT $522($e) (ID02 0x3e8 strlen) to D0; TEInsert($e, D0, hTE) $A9DE; TEInsert(A5-0x213a, 1, hTE); BSR 0x158c - identical
 * to the C. */
/* Original: FUN_000018b0; source: ID04.c. Recovered name: append_line_to_scrolling_text [STRONG INFERENCE].
 * Ghidra truncated this body after the first call (rebuilt as C below); decoded from ID04.bin
 * bytes at file 0x18b0.
 * Arg +0xe: C string. JSR $522(A5) = ID02 0x3e8 (strlen: counts bytes to NUL) [PROVEN]; TEInsert(text, len, A5-0x223a) ($A9DE); TEInsert(A5-0x213a, 1, A5-0x223a) inserts one separator byte (probably CR) [HYPOTHESIS for CR]; then JSR 0x158c (FUN_0000158c, scroll-bar value / scroll update via GetCtlValue $A960, SetCtlValue $A963). Args +8..+0xd are not used. No direct JSR found in ID04 bytes [UNKNOWN caller path].
 */
// WARNING: Control flow encountered bad instruction data

void append_line_to_scrolling_text /* Original: FUN_000018b0 */ (int unused_8,short unused_c,char *line /* param_3: C string */)

{
  int unaff_A5;

  TEInsert(line,FUN_000003e8(line),*(int *)(unaff_A5 + -0x223a)); /* JT $522 -> ID02 0x3e8 strlen; $A9DE */
  TEInsert((void *)(unaff_A5 + -0x213a),1,*(int *)(unaff_A5 + -0x223a)); /* one separator byte */
  scroll_text_to_show_selection();              /* BSR 0x158c */
  return;
}



/* VERIFIED (ID04::FUN_000018e0): ID04.bin 0x18e0..0x192c checked against an independent capstone disassembly.
 * CMPI.W #2 A5-0x12f8 -> MOVEQ #0; TST.W A5-0x14c0 BNE / TST.W A5-0x12ba BLE else MOVEQ #2; word i 0..9 TST.W A5-0x12ce[i] ->
 * MOVEQ #1; MOVEQ #0 - identical to the C. */
/* Original: FUN_000018e0; source: ID04.c. Recovered name: get_mission_kill_report_state [STRONG INFERENCE].
 * Decoded from ID04.bin bytes at file 0x18e0.
 * Returns 0 when the mission state A5-0x12f8 == 2; 2 when A5-0x14c0 == 0 and A5-0x12ba > 0; 1 when any of the ten words at A5-0x12ce is non-zero; otherwise 0 [PROVEN, bytes 0x18e4..0x192a]. Ten words = ten target types (STR# 129 slots 106-115) [STRONG INFERENCE: per-mission kill counts]. Callers: confirm_end_mission 0x532 (result 0 -> returns 2 without asking), summary text builders 0x263a and 0x29b6; at 0x29c4 a 0 result appends STR# slot 50 "No new kills to report." (A5-0xe7e). Meaning of state 2 (A5-0x14c0 / A5-0x12ba) [UNKNOWN].
 */
undefined4 get_mission_kill_report_state /* Original: FUN_000018e0 */ (void)

{
  undefined4 state; /* uVar1: 0, 1 or 2 */
  int unaff_A5;
  short k; /* local_6: kill counter 0..9 */
  
  if (*(short *)(unaff_A5 + -0x12f8) == 2) {
    state = 0;
  }
  else if ((*(short *)(unaff_A5 + -0x14c0) == 0) && (0 < *(short *)(unaff_A5 + -0x12ba))) {
    state = 2;
  }
  else {
    for (k = 0; k < 10; k = k + 1) {
      if (*(short *)(k * 2 + unaff_A5 + -0x12ce) != 0) {
        return 1;
      }
    }
    state = 0;
  }
  return state;
}



/* VERIFIED (ID04::FUN_0000192e): ID04.bin 0x192e..0x1a0c checked against an independent capstone disassembly.
 * CLR.L A5-0x2230; enable(8, 3) unless A5-0x14c4 && !A5-0x12f0 && A5-0x2228 == -1; enable(8, 1) if !A5-0x12f0; CMPI.W #3
 * $c / TST.W A5-0x14c4 / CMPI.W #-1 A5-0x2228 / CMPI.W #1 A5-0x225e; -$12 = thePort, SetPort(8); twice GetDItem(8, item
 * A5-0x225e then 1, -2, -6, -$e), InsetRect(-4, -4), EraseRect $A8A3, InvalRect $A928; A5-0x225e = 1; SetPort(-$12) -
 * identical to the C. */
/* Original: FUN_0000192e; source: ID04.c. Recovered name: update_summary_dialog_buttons [STRONG INFERENCE].
 * Decoded from ID04.bin bytes at file 0x192e.
 * C args: +8 DialogPtr, +0xc short phase. Clears A5-0x2230. Calls enable_dialog_control(dialog, 3) unless (mission-over flag A5-0x14c4 set, A5-0x12f0 == 0 and A5-0x2228 == -1); calls enable_dialog_control(dialog, 1) when A5-0x12f0 == 0. If phase != 3, A5-0x14c4 set, A5-0x2228 == -1 and the default item A5-0x225e != 1: SetPort(dialog), then for the current default item and for item 1 GetDItem, InsetRect(-4, -4), EraseRect ($A8A3), InvalRect ($A928); sets A5-0x225e = 1 and restores the port, so draw_default_button_outline redraws the ring around item 1 [PROVEN, bytes 0x1932..0x1a0c]. Ghidra truncated the ring-moving block (and dropped the enable_dialog_control arguments); body rebuilt as C below. In DITL 133 (dump items are 0-based, Toolbox items 1-based) item 1 is "End Mission" and item 3 is "OK" [PROVEN for DITL 133; STRONG INFERENCE that this dialog is DLOG 133]. Callers: 0x21b8 (phase 0) and 0x3050, both after FUN_000021d6 returns non-zero.
 */
// WARNING: Control flow encountered bad instruction data

void update_summary_dialog_buttons /* Original: FUN_0000192e */ (int dlg /* param_1: DialogPtr */,short mode /* param_2: summary mode (3 = the dossier view) */)

{
  int unaff_A5;
  int saved;                                    /* -$12(A6) */
  short box[4];                                 /* -$e(A6) */
  int handle;                                   /* -6(A6) */
  short itemType;                               /* -2(A6) */
  
  *(undefined4 *)(unaff_A5 + -0x2230) = 0;
  if (((*(short *)(unaff_A5 + -0x14c4) == 0) || (*(short *)(unaff_A5 + -0x12f0) != 0)) ||
     (*(short *)(unaff_A5 + -0x2228) != -1)) {
    enable_dialog_control(dlg,3);           /* BSR 0x2e */
  }
  if (*(short *)(unaff_A5 + -0x12f0) == 0) {
    enable_dialog_control(dlg,1);
  }
  if (((mode != 3) && (*(short *)(unaff_A5 + -0x14c4) != 0)) &&
     ((*(short *)(unaff_A5 + -0x2228) == -1 && (*(short *)(unaff_A5 + -0x225e) != 1)))) {
    saved = *(int *)(unaff_A5 + -0x160c);       /* thePort */
    SetPort(dlg);                           /* $A873 */
    GetDItem(dlg,*(short *)(unaff_A5 + -0x225e),&itemType,&handle,box); /* old default item */
    InsetRect(box,-4,-4);                       /* $A8A9 */
    EraseRect(box);                             /* $A8A3 */
    InvalRect(box);                             /* $A928 */
    GetDItem(dlg,1,&itemType,&handle,box);  /* new default item 1 */
    InsetRect(box,-4,-4);
    EraseRect(box);
    InvalRect(box);
    *(short *)(unaff_A5 + -0x225e) = 1;         /* draw_default_button_outline now rings item 1 */
    SetPort(saved);
  }
  return;
}



// WARNING: Control flow encountered bad instruction data

/* VERIFIED (ID04::FUN_00001a0e): ID04.bin 0x1a0e..0x1b3c checked against an independent capstone disassembly.
 * -2 = A5-0x13a4; rank = A5-0xffe[(record +$22) EXT.L ASL.L #2] to -$86; JT $2fa(rank); JT $52a(-$82, rank); JT $512(-$82,
 * A5-0x2138); JT $512(-$82, JT $2fa(record)); JT $302 on record, rank, -$82; GetDItem($a, 8, -4, -8, -$18); widths; StringWidth
 * $A88C to -$1a; GetFontInfo(-$10); EraseRect(-$18); MoveTo with DIVS.W #2 halves; DrawString(-$82); Pascal return popping 6
 * - identical to the C. draw_rank_insignia (0x1b3e) has no inventory entry. */
/* Original: FUN_00001a0e; source: ID04.c:699. Recovered name: build_rank_and_name_string [STRONG INFERENCE].
 * Body rebuilt as C below. For the current pilot (word A5-0x13a4):
 * rank = rank-group string A5-0xffe[record +0x22] (Ensign... Captain);
 * p2cstr(rank) (JT $2fa); buf = copy of rank (JT $52a); append A5-0x2138
 * (separator, JT $512); append p2cstr(record name at +0x00); converts the
 * name, rank and buf back with c2pstr (JT $302) - e.g. "Lieutenant <name>"
 * [STRONG INFERENCE; JT $512 assumed strcat-like].
 *  additions: JT $512 is strcat (ID02 0x2d8 bytes) [PROVEN].
 * The function is also a Pascal user-item procedure: it pops 6 bytes
 * (DialogPtr +0xa, item +8), is reached through JT $7a (-> ID04 0x1a0e) and
 * is installed for item 9 of the Mission Summary (dump item 8, title strip
 * (110,5)-(391,21)); after building the string it calls GetDItem,
 * StringWidth ($A88C), GetFontInfo ($A88B), EraseRect, MoveTo ($A893) and
 * DrawString ($A884) - it draws "rank name" in that item, at (width / 2 + left -
 * textWidth / 2, height / 2 + top + ascent / 2), each half a separate DIVS.W [PROVEN]. The name is kept for
 * traceability; "draw_rank_and_name_item" would describe it more fully.
 * The following bytes 0x1b3e..0x1bc6 (not exported by Ghidra) are
 * draw_rank_insignia [STRONG INFERENCE name]: Pascal user item reached through
 * JT $15a (-> ID04 0x1b3e), installed for item 15 (dump item 14, 32 x 32 at
 * (454,4)); GetDItem, GetCIcon(0x100 + record rank +0x22), PlotCIcon in the
 * box sized to the icon bounds, DisposCIcon [PROVEN, bytes]; cicn 256 is
 * named "Ensign" in the dump (rank 0).
 */
/* Pascal user-item procedure: dlg at $a(A6), item at 8(A6); pops 6 bytes (UNLK, MOVEA.L (A7)+,A0, LEA 6(A7), JMP (A0)) */
void build_rank_and_name_string /* Original: FUN_00001a0e */ (int dlg,short item)

{
  int unaff_A5;
  char *rank;                                   /* -$86(A6) */
  char buf[0x7c];                               /* -$82(A6) */
  short height;                                 /* -$1e(A6) */
  short width;                                  /* -$1c(A6) */
  short w;                                      /* -$1a(A6) */
  short box[4];                                 /* -$18(A6): top, left (-$16), bottom, right (-$12) */
  short fi[4];                                  /* -$10(A6): FontInfo, ascent first */
  int handle;                                   /* -8(A6) */
  short itemType;                               /* -4(A6) */
  short pilot;                                  /* -2(A6) */

  pilot = *(short *)(unaff_A5 + -0x13a4);
  rank = *(char **)(unaff_A5 + -0xffe + (int)*(short *)((char *)(**(int **)(unaff_A5 + -0x13a8) + (int)pilot * 0x40) + 0x22) * 4); /* Ensign .. Captain */
  length_prefixed_bytes_to_c_string_in_place(rank); /* JT $2fa -> ID09 0x432 */
  ansi_strcpy(buf,rank);                        /* JT $52a -> ID02 0x2c8 */
  ansi_strcat(buf,(char *)(unaff_A5 + -0x2138)); /* JT $512 -> ID02 0x2d8: separator */
  ansi_strcat(buf,length_prefixed_bytes_to_c_string_in_place((char *)(**(int **)(unaff_A5 + -0x13a8) + (int)pilot * 0x40))); /* the pilot name */
  c2pstr_in_place((char *)(**(int **)(unaff_A5 + -0x13a8) + (int)pilot * 0x40));                       /* JT $302 -> ID09 0x416, three times */
  c2pstr_in_place(rank);
  c2pstr_in_place(buf);
  GetDItem(dlg,item,&itemType,&handle,box);     /* $A98D */
  width = box[3] - box[1];
  height = box[2] - box[0];
  w = StringWidth(buf);                         /* $A88C */
  GetFontInfo(fi);                              /* $A88B */
  EraseRect(box);                               /* $A8A3 */
  MoveTo(((short)((int)width / 2) + box[1]) - (short)((int)w / 2),
         ((short)((int)height / 2) + box[0]) + (short)((int)fi[0] / 2)); /* $A893 */
  DrawString(buf);                              /* $A884 */
  return;
}



/* VERIFIED (ID04::FUN_00001bc8): ID04.bin 0x1bc8..0x1d9c checked against an independent capstone disassembly.
 * -$94 = thePort+$44, -$98 = thePort (before the test); CMPI.W #2 / #4 / #8 $e BEQ.W exit; row = type, SUBQ for each of 2 / 4 / 8
 * below it (CMPI.W BLE); SetPort, ClipRect(thePort+$10) $A87B, GetDItem(8, $c, -8, -$c, -$14), InsetRect(4, 0), GetFontInfo(-$92);
 * -2 = row MULS.W #$17 + ascent + top + 3; top = row * $17 + top + 3, bottom = top + $10; EraseRect; MoveTo(left, -2); n = (A5-0x2226)[type]
 * TST.W: strcpy name (A5-0xf86[type]) [+ strcat A5-0x2136 + strcat JT $2fa(JT $4a2(n, -$8a))]; JT $302; TextFont(1); DrawString;
 * JT $4a2(n MULU.L A5-0xf5e[type], -$80); MoveTo(right - StringWidth, -2); DrawString; TextFont(-$94); SetPort(-$98) - identical
 * to the C. */
/* Original: FUN_00001bc8; source: ID04.c. Recovered name: draw_targets_destroyed_row [STRONG INFERENCE].
 * Decoded from ID04.bin bytes at file 0x1bc8.
 * C args: +8 DialogPtr, +0xc short item, +0xe short target type (0..9, STR# 129 slots 106-115). Returns at once for types 2 (Tank), 4 (Vehicle) and 8 (PT Boat); otherwise the row index is the type minus the number of skipped types below it (0..6), so seven rows are listed [PROVEN, bytes 0x1bdc..0x1c22]. Saves thePort and its txFont (+0x44), SetPort(dialog), ClipRect(portRect), GetDItem -> box, InsetRect(&box, 4, 0), GetFontInfo ($A88B). Row rect: top = box.top + 23 * row + 3, bottom = top + 16, EraseRect; baseline y = top + ascent; MoveTo(box.left, y).
 *  [PROVEN, bytes 0x1c4a..0x1d9a]: n = counts[type], counts = word array at *A5-0x2226. Label = target name (STR# group A5-0xf86[type]) copied with strcpy (JT $52a); if n != 0, strcat the text at A5-0x2136 and the decimal n (format_int_decimal_pstring, JT $4a2, then ID09 0x432 to a C string); c2p in place (JT $302); TextFont(1) ($A887); DrawString. Points = n * weight[type] (words at A5-0xf5e, the weights used by compute_pilot_score; MULU.L), formatted with JT $4a2 and drawn right-aligned (MoveTo(box.right - StringWidth, y)). Restores txFont and the port.
 * A5-0x2226 points to the local array -0x4a(A6) of show_mission_summary_dialog (set at 0x2e00); the text step adds kills to it (0x2b0c) and to A5-0x13a2 (0x2af8) while the summary runs [PROVEN]. So each row reads "<target> <sep> <n>...  <points>" [STRONG INFERENCE for the layout; the separator text at A5-0x2136 is A5 initial data, not yet read].
 * Caller: draw_targets_destroyed_list. Body rebuilt as C below.
 */
// WARNING: Control flow encountered bad instruction data

void draw_targets_destroyed_row /* Original: FUN_00001bc8 */ (int dlg /* param_1: DialogPtr */,short item /* param_2 */,short target /* param_3: target type 0..9 */)

{
  int unaff_A5;
  int savedPort;                                /* -$98(A6) */
  short savedFont;                              /* -$94(A6) */
  short fi[4];                                  /* -$92(A6): FontInfo, ascent first */
  char tmp[10];                                 /* -$8a(A6) */
  char buf[0x74];                               /* -$80(A6) */
  short box[4];                                 /* -$14(A6): top, left (-$12), bottom (-$10), right (-$e) */
  int handle;                                   /* -$c(A6) */
  short itemType;                               /* -8(A6) */
  short row;                                    /* -6(A6) */
  short y;                                      /* -2(A6) */

  savedFont = *(short *)(*(int *)(unaff_A5 + -0x160c) + 0x44); /* thePort->txFont */
  savedPort = *(int *)(unaff_A5 + -0x160c);
  if (((target == 2) || (target == 4)) || (target == 8)) {
    return;                                     /* Tank, Vehicle, PT Boat are not listed */
  }
  row = target;
  if (2 < target) row = row + -1;
  if (4 < target) row = row + -1;
  if (8 < target) row = row + -1;
  SetPort(dlg);                             /* $A873 */
  ClipRect((void *)(*(int *)(unaff_A5 + -0x160c) + 0x10)); /* $A87B, portRect */
  GetDItem(dlg,item,&itemType,&handle,box); /* $A98D */
  InsetRect(box,4,0);                           /* $A8A9 */
  GetFontInfo(fi);                              /* $A88B */
  y = row * 0x17 + fi[0] + box[0] + 3;          /* MULS.W #$17: baseline */
  box[0] = row * 0x17 + box[0] + 3;             /* row rect */
  box[2] = box[0] + 0x10;
  EraseRect(box);                               /* $A8A3 */
  MoveTo(box[1],y);                             /* $A893 */
  if (*(short *)(*(int *)(unaff_A5 + -0x2226) + (int)target * 2) == 0) {
    ansi_strcpy(buf,*(char **)(unaff_A5 + -0xf86 + (int)target * 4)); /* JT $52a: target name */
  }
  else {
    ansi_strcpy(buf,*(char **)(unaff_A5 + -0xf86 + (int)target * 4));
    ansi_strcat(buf,(char *)(unaff_A5 + -0x2136)); /* JT $512: separator */
    ansi_strcat(buf,length_prefixed_bytes_to_c_string_in_place(
                    format_int_decimal_pstring((int)*(short *)(*(int *)(unaff_A5 + -0x2226) + (int)target * 2),tmp))); /* JT $4a2, JT $2fa */
  }
  c2pstr_in_place(buf);                         /* JT $302 */
  TextFont(1);                                  /* $A887 */
  DrawString(buf);                              /* $A884 */
  format_int_decimal_pstring((int)*(short *)(*(int *)(unaff_A5 + -0x2226) + (int)target * 2) * (int)*(short *)(unaff_A5 + -0xf5e + (int)target * 2),buf);
                                                /* points = n * weight (MULU.L of sign-extended words) */
  MoveTo(box[3] - StringWidth(buf),y);          /* right-aligned; $A88C */
  DrawString(buf);
  TextFont(savedFont);
  SetPort(savedPort);
  return;
}



/* VERIFIED (ID04::FUN_00001d9e): ID04.bin 0x1d9e..0x1ddc checked against an independent capstone disassembly.
 * Push word 8, long $a, BSR 0x120, ADDQ #6; word t 0..9: push t, word 8, long $a, BSR 0x1bc8, ADDQ #8; Pascal return popping 6
 * - identical to the C. draw_mission_awards (0x1dde) has no inventory entry. */
/* Original: FUN_00001d9e; source: ID04.c. Recovered name: draw_targets_destroyed_list [PROVEN].
 * Decoded from ID04.bin bytes at file 0x1d9e.
 * Pascal user-item procedure (DialogPtr at +0xa, item at +8; pops 6 bytes): frame_dialog_item_box(dialog, item), then draw_targets_destroyed_row(dialog, item, t) for t = 0..9. Reached through JT $aa (CODE 0 entry -> ID04 0x1d9e); installed for item 6 by show_mission_summary_dialog (0x2e34). Item 6 = DITL 133 dump item 5, box (215,130)-(389,291) under the "Targets Destroyed" label. Body rebuilt as C below.
 * The following bytes 0x1dde..0x1f5c, inside this Ghidra range and not exported, are draw_mission_awards [STRONG INFERENCE name]: Pascal user item reached through JT $152 (-> ID04 0x1dde), installed for item 5 (dump item 4, (10,130)-(201,200), under "Mission Awards"). frame_dialog_item_box; SetPort; ClipRect(portRect); GetDItem; flags = word +0x26 of the current pilot record; for bit i = 0..7 (flags >>= 1 each step): if set, place a cell in a 3-column grid (x = w * col / 3, y = h * row / 3), GetCIcon(0x200 + i) ($AA1E), PlotCIcon right/bottom-aligned in the cell ($AA1F), DisposCIcon ($AA25) [PROVEN, bytes]. The application has cicn 512..519 (dump). So pilot record +0x26 is an awards bitmask, one bit per award icon [STRONG INFERENCE].
 */
/* Pascal user-item procedure: dlg at $a(A6), item at 8(A6); pops 6 bytes (UNLK, MOVEA.L (A7)+,A0, LEA 6(A7), JMP (A0)) */
void draw_targets_destroyed_list /* Original: FUN_00001d9e */ (int dlg,short item)

{
  short t_;                                     /* -2(A6) */

  frame_dialog_item_box(dlg,item);              /* BSR 0x120 */
  for (t_ = 0; t_ < 10; t_ = t_ + 1) {
    draw_targets_destroyed_row(dlg,item,t_);    /* BSR 0x1bc8 */
  }
  return;                                       /* Ghidra read the JMP (A0) return as a jump table */
}



/* VERIFIED (ID04::FUN_00001f5e): ID04.bin 0x1f5e..0x20e6 checked against an independent capstone disassembly.
 * LINK -$36; thePort copy; BSR 0x120; SetPort; ClipRect(portRect+$10); GetDItem; tally record via EXT.L/ASL.L #6; cap 24;
 * grid loop with MULS/DIVS #6 and #4, OffsetRect(left+15, top+10), FrameRect, InsetRect(3,3), RGBForeColor, PaintOval,
 * ForeColor(33); SetPort(saved); RTS (C convention) - identical to the C. */
/* Original: FUN_00001f5e; source: ID04.c. Recovered name: draw_aircraft_kill_markers [STRONG INFERENCE].
 * Decoded from ID04.bin bytes at file 0x1f5e.
 * C args: +8 DialogPtr, +0xc short item. frame_dialog_item_box(dialog, item); SetPort(dialog); ClipRect(&thePort->portRect) ($A87B); GetDItem -> box (w, h). count = tally[0] + tally[1] of the current pilot record (*A5-0x13a8 + A5-0x13a4 * 0x40 + 0x28; tally 0 / 1 = Fighter / Bomber per STR# 129 slots 106/107 [STRONG INFERENCE]), capped at 24. For i < count, in a 6-column grid (col 0..5, then row++): x = w * col / 6, y = h * row / 4; frames a 26 x 16 rect centred on (x, y) offset by (dh = box.left + 15, dv = box.top + 10) (OffsetRect $A8A8, FrameRect $A8A1; corrected from the push order); then a 16-wide rect from x + box.left + 7, InsetRect(3, 3), RGBForeColor({0xffff, 0, 0}) ($AA14), PaintOval ($A8B8), ForeColor(33 = blackColor) ($A862). Restores the port [PROVEN, bytes 0x1f5e..0x20e6]. Draws one kill marker (red disc in a frame) per aircraft destroyed [STRONG INFERENCE]. Its item is item 7 of DLOG 133 (DITL dump item 6, 191 x 70 box directly under the "Total Aircraft Destroyed" label) [PROVEN placement]. Ghidra stopped after the first call; body rebuilt as C below.
 */
void draw_aircraft_kill_markers /* Original: FUN_00001f5e */ (int dlg,short item)

{
  short i;                                      /* -2(A6) */
  short count;                                  /* -4(A6), capped */
  short countRaw;                               /* -6(A6), written, never read */
  short col;                                    /* -8(A6) */
  short row;                                    /* -$a(A6) */
  short w;                                      /* -$c(A6) */
  short h;                                      /* -$e(A6) */
  short x;                                      /* -$10(A6) */
  short y;                                      /* -$12(A6) */
  short *tally;                                 /* -$16(A6) */
  short itemType;                               /* -$18(A6) */
  int itemHandle;                               /* -$1c(A6) */
  short box[4];                                 /* -$24(A6): top, left, bottom, right */
  short r[4];                                   /* -$2c(A6): top, left, bottom, right */
  int savedPort;                                /* -$30(A6) */
  short red[3];                                 /* -$36(A6): RGBColor */

  savedPort = *(int *)(unaff_A5 + -0x160c);     /* thePort */
  frame_dialog_item_box(dlg,item);              /* BSR 0x120, ADDQ #6 */
  SetPort(dlg);                                 /* $A873 */
  ClipRect((short *)(*(int *)(unaff_A5 + -0x160c) + 0x10)); /* $A87B: &thePort->portRect */
  GetDItem(dlg,item,&itemType,&itemHandle,box); /* $A98D */
  w = box[3] - box[1];
  h = box[2] - box[0];
  col = 0;
  row = 0;
  tally = (short *)((int)*(short *)(unaff_A5 + -0x13a4) * 0x40 + **(int **)(unaff_A5 + -0x13a8) + 0x28);
                                                /* EXT.L, ASL.L #6, ADD.L (A0), ADDI.L #$28 */
  count = tally[0] + tally[1];
  countRaw = count;
  if (0x18 < count) {
    count = 0x18;
  }
  red[0] = -1;
  red[1] = 0;
  red[2] = 0;
  for (i = 0; i < count; i = i + 1) {
    x = (short)((int)(short)(w * col) / 6);     /* MULS.W, EXT.L, DIVS.W #6 */
    y = (short)((int)(short)(h * row) / 4);     /* MULS.W, EXT.L, DIVS.W #4 */
    r[1] = x + -0xd;
    r[3] = r[1] + 0x1a;
    r[0] = y + -8;
    r[2] = r[0] + 0x10;
    OffsetRect(r,box[1] + 0xf,box[0] + 10);     /* $A8A8: dh = box.left + 15, dv = box.top + 10 */
    FrameRect(r);                               /* $A8A1 */
    r[1] = x + box[1] + 7;
    r[3] = r[1] + 0x10;
    InsetRect(r,3,3);                           /* $A8A9 */
    RGBForeColor(red);                          /* $AA14 */
    PaintOval(r);                               /* $A8B8 */
    ForeColor(0x21);                            /* $A862: blackColor */
    col = col + 1;
    if (col == 6) {
      col = 0;
      row = row + 1;
    }
  }
  SetPort(savedPort);
  return;
}



/* VERIFIED (ID04::FUN_000020e8): ID04.bin 0x20e8..0x2102 checked against an independent capstone disassembly.
 * LINK #0; push word 8(A6), long $a(A6); BSR 0x1f5e; ADDQ #6; Pascal return popping 6 - identical to the C.
 * The bytes 0x2104..0x2d84 after it stay described in the comment below (not exported). */
/* Original: FUN_000020e8; source: ID04.c. Recovered name: aircraft_kill_markers_user_item_proc [PROVEN].
 * Decoded from ID04.bin bytes at file 0x20e8.
 * Pascal user-item procedure (DialogPtr at +0xa, item at +8; pops 6 bytes, which Ghidra read as an unrecoverable jump table): calls draw_aircraft_kill_markers(dialog, item). Reached through JT $ea (CODE 0 entry -> ID04 0x20e8); installed for item 7 by show_mission_summary_dialog (pea $ea(A5) at 0x2e5c, set_dialog_user_item_proc at 0x2e68). See the comment after this function for the two unexported routines in the rest of its Ghidra range.
 */
/* Pascal user-item procedure: dlg at $a(A6), item at 8(A6); pops 6 bytes (UNLK, MOVEA.L (A7)+,A0, LEA 6(A7), JMP (A0)) */
void aircraft_kill_markers_user_item_proc /* Original: FUN_000020e8 */ (int dlg,short item)

{
  draw_aircraft_kill_markers(dlg,item);         /* push word 8, long $a; BSR 0x1f5e; ADDQ #6 */
  return;                                       /* Ghidra read the JMP (A0) return as a jump table */
}



/*: bytes 0x2104..0x2d84 lie inside Ghidra's FUN_000020e8 range
 * (Ghidra stopped at the JMP (A0) at 0x2102) and hold two functions that
 * Ghidra did not export. Decoded from ID04.bin; no C was changed.
 *
 * (a) file 0x2104, JT $ca (CODE 0 entry -> ID04 0x2104):
 *     mission_summary_filter_proc [STRONG INFERENCE name]. Pascal ModalDialog
 *     filter: DialogPtr +0x10, EventRecord * +0xc, short *itemHit +8; pops
 *     0xc bytes and returns a Boolean byte [PROVEN]. Passed as pea $ca(A5) at
 *     0x3056 by show_mission_summary_dialog. Switch on event->what through
 *     ID01 helper JT $2a; inline table at 0x2112 = count 3, then
 *     (offset, value) pairs and a default offset, offsets relative to their
 *     own word [PROVEN by instruction boundaries]:
 *       keyDown (3)   -> 0x2122: char = message & 0xff, switch through
 *                        JT $32 (long values): 13 Return / 3 Enter -> 0x2144:
 *                        if the step delay A5-0x2230 is 0, *itemHit = default
 *                        item A5-0x225e and return true;
 *       mouseDown (1) -> 0x2158: click handler 0x1752 on the scrolling text;
 *                        if handled, *itemHit = 8 and return true;
 *       updateEvt (6) -> 0x2178: JT $492 (ID02 0x4d6a) with the event;
 *       default       -> 0x2182.
 *     Timer path 0x2182: if abs_long(TickCount - A5-0x222c) >= A5-0x2230,
 *     call the text step (b) with (dialog, 8, A5-0x2220); when it returns
 *     non-zero call update_summary_dialog_buttons(dialog, 0); then
 *     A5-0x222c = TickCount. Returns false.
 *     So A5-0x222c = tick of the last step, A5-0x2230 = delay before the next
 *     step [STRONG INFERENCE], item 8 = the scrolling text item (DITL 133
 *     dump item 7, 476 x 66 box) [STRONG INFERENCE].
 *
 * (b) file 0x21d6..0x2d84: advance_mission_summary_text [STRONG INFERENCE name].
 *     C args +8 DialogPtr, +0xc short item, +0xe short. Switch on the step
 *     state A5-0x2222 through JT $3a; table at 0x21ea = lo 0, hi 5, default
 *     +0xb92 -> 0x2d80 (return 0), cases 0 -> 0x21fc, 1 -> 0x28c2,
 *     2 -> 0x291e, 3 -> 0x2a2e, 4 -> 0x2b74, 5 -> 0x2c4e [PROVEN, bytes].
 *     Appends STR# 129 lines with append_line_to_scrolling_text (e.g. slot 30
 *     "Summary of mission up to the present time.", 31 "You are dead.",
 *     50 "No new kills to report.") and sets A5-0x2222 to the next state
 *     (100 = finished, returns 1 at 0x2d76..0x2d7e). Per-state decoding is
 *     still open.
 *
 *      - state 3, 0x2a2e..0x2b70 ("kill transfer") [PROVEN, bytes]:
 *     the index A5-0x2176 skips target types whose mission kill count
 *     A5-0x12ce[t] is 0. When it reaches 10: ChangedResource(A5-0x13a8 roster
 *     handle, HEL1 128) ($A9AA), UpdateResFile(A5-0x1002) ($A999), state = 4,
 *     line cursor A5-0x21ca = &A5-0x21c6. Otherwise, for type t with n kills:
 *       line = decimal n (JT $4a2, ID09 0x432) + text A5-0x212e + target name
 *              A5-0xf86[t], plus text A5-0x212c when n > 1 [STRONG INFERENCE:
 *              a space and a plural "s"; A5 initial data not read];
 *       pilot record tally[t] (+0x28 + 2t) += n; A5-0x12ce[t] = 0;
 *       A5-0x13a2[t] += n; summary counts (*A5-0x2226)[t] += n;
 *       append_line_to_scrolling_text(line); set_score_item_text(dialog, 14);
 *       draw_targets_destroyed_row(dialog, 6, t);
 *       draw_aircraft_kill_markers(dialog, 7); return 0.
 *     So pilot tallies 0..9 are lifetime kills per target type and A5-0x12ce
 *     holds the kills of the current mission not yet added [PROVEN].
 *
 *      - state 4, 0x2b74..0x2c4c ("promotion check") [PROVEN, bytes]:
 *     score = compute_pilot_score(A5-0x13a4); thresholds = longs at A5-0xfd6
 *     indexed by rank. If score < threshold[rank + 1]: state = 100, return 1
 *     (summary finished). Otherwise queue STR# lines through the cursor
 *     A5-0x21ca into the pointer queue at A5-0x21c6: slot 53 "Its not all bad
 *     news though, you gained enough points to advance in rank!" when the
 *     pilot status A5-0x12b4 == 1 (Dead), else slots 54 "Congratulations!" and
 *     55 "You have gained enough points to advance in rank!"; new rank = the
 *     last index with threshold <= score, stored in record +0x22;
 *     ChangedResource(roster) + UpdateResFile(A5-0x1002); A5-0x2176 = number
 *     of queued lines; cursor reset; state = 5; return 0.
 *     So A5-0xfd6 = rank point thresholds (one long per rank) [STRONG
 *     INFERENCE; values are A5 initial data].
 *
 *     State 5, 0x2c4e..0x2d7e ("promotion text"): while A5-0x2176-- != 0,
 *     append the next queued line and return 0. Then line = slot 56 "You are
 *     posthumously promoted to the grade of " (Dead) or slot 57 "You are
 *     promoted to the grade of ", + new rank name (A5-0xffe[rank]) + text
 *     A5-0x212a [STRONG INFERENCE: a full stop]; append it; SetPort(dialog);
 *     for item 15 (rank insignia; InsetRect(-36, -4)) and item 9 (rank and
 *     name title; InsetRect(-4, -4)) GetDItem, EraseRect, InvalRect so both
 *     redraw with the new rank; restore the port; state = 100; return 1.
 *
 *      - state 1, 0x28c2..0x291c [PROVEN, bytes]: while
 *     A5-0x2176-- != 0, append the next queued line (cursor A5-0x21ca) and
 *     return 0. Then, if A5-0x2228 == -1: state = 2; otherwise append STR#
 *     slot 49 "Player's Cumulative History", state = 100, return 1.
 *
 *     State 2, 0x291e..0x2a28 [PROVEN, bytes]: append the text at A5-0x2130
 *     [STRONG INFERENCE: an empty line]. If (arg +0xe & 0xff) == 1 and the
 *     pilot status A5-0x12b4 != 1 (not Dead): record +0x26 |= 1 << (A5-0x12f8
 *     - 3), ChangedResource(roster) + UpdateResFile(A5-0x1002), then
 *     erase / invalidate item 5 (mission awards) so it redraws. So award bit
 *     n is earned by succeeding in mission A5-0x12f8 = n + 3, and the eight
 *     award icons (cicn 512..519) are one per mission [STRONG INFERENCE].
 *     arg +0xe is A5-0x2220, the word argument that conclude_mission passes
 *     to show_mission_summary_dialog (stored at 0x302c) [PROVEN]; its low
 *     byte == 1 means "mission accomplished" [HYPOTHESIS].
 *     Then k = get_mission_kill_report_state: if k == 0, append slot 50
 *     "No new kills to report.", state = 100, return 1 (the following test
 *     of the same k that would select state 4 is never true - unreachable in
 *     the original bytes 0x29d8..0x29f0); otherwise append slots 51 "Now
 *     adding points to permanent score" and 52 "==== Kills ====", state = 3,
 *     A5-0x2176 = 0, return 0.
 *
 *      - state 0, 0x21fc..0x28c0 ("outcome narrative") [PROVEN
 *     control flow, bytes; texts from the STR# 129 dump]. Lines are queued
 *     through the cursor A5-0x21ca (reset to &A5-0x21c6) and printed by
 *     state 1. "slot n" = STR# 129 slot; the pointer group A5-0x221e + 4k
 *     (ID07 init_string_pointer_groups) is slot 2 + k.
 *     Outcome code = arg +0xe & 0xff (low byte of A5-0x2220), switch through
 *     JT $3a, table at 0x2210: lo 1, hi 10, default -> 0x272e:
 *       1 (0x222a) flight ended [meaning HYPOTHESIS]: if pilot status A5-0x12b4 == 1: slot 23 (bailed
 *         out without enough altitude) when A5-0x12b2 != 0, else slot 24
 *         "POW!" and one of slots 25..28 chosen by (TickCount >> 2) & 3
 *         (JT $32 table at 0x2268); otherwise slot 29 (objectives achieved,
 *         mission complete);
 *       3 (0x2620) mission in progress: prints slot 30 directly, then slot
 *         31 "You are dead." (status 1), 32 (unbanked points) when
 *         get_mission_kill_report_state == 1, or 33 (objectives done,
 *         return to base) when it is 2; if A5-0x14c0 == 0: A5-0x12ba == -1
 *         -> failure line by mission A5-0x12f8 (table at 0x26b4: 5 -> slot 34
 *         B17, 6 -> 35 Henderson field, 7 and 9 -> 36 carrier, 8 -> none),
 *         A5-0x12ba == -2 -> slot 37 (original Hellcat lost); state = 100,
 *         return 1 (no queue);
 *       6 (0x22d4) ditching (slot 2), 7 (0x23c6) bail-out (slot 21),
 *         8 (0x24f2) disabled-aircraft landing (slot 3), 9 (0x25b8) landing
 *         (slot 6), 10 (0x24b8) landing at an enemy base (slots 4, 5, 16, 17):
 *         these set the local "aircraft lost" flag -0x48 (except 9) and add
 *         location / rescue lines selected by the flag bits of arg +0xe
 *         (high byte: bit 1 -> slot 12 friendly territory; else bit 0 ->
 *         slot 10 enemy territory, else slot 11) and by the status
 *         A5-0x12b4 (sub-switches at 0x233a, 0x2398, 0x242c, 0x248a, 0x2534,
 *         0x2588: slots 13..20). Status 4 (Discharged) after an undamaged
 *         ditch / bail-out adds slots 7 or 22 and 8;
 *       2, 4, 5 (default 0x272e): no outcome text (local -0x46 = 1).
 *     Friendly fire, 0x2734 (only when -0x46 == 0, status Active and the
 *     friendly-kill count A5-0x12b6 != 0): slot 9; if A5-0x12b6 >= 5: slots
 *     38, 39 (treason, executed), status = 1 (Dead), A5-0x14c4 = 1; else
 *     record +0x24 += 1 (saved with ChangedResource / UpdateResFile) and by
 *     its new value 1 -> slots 40, 41, 2 -> slots 42, 43, 3 -> slots 44, 8
 *     with status = 4 (Discharged), A5-0x14c4 = 1; then A5-0x12b6 = 0.
 *     Lost aircraft, 0x2828 (flag -0x48, A5-0x14c0 == 0, status Active): if
 *     A5-0x12ba > 0 queue A5-0x2134 and slots 45, 46; if == 0 queue A5-0x2132
 *     and slots 47, 48; then A5-0x12ba = -2.
 *     Finally A5-0x2176 = number of queued lines, cursor reset, state = 1,
 *     return 0.
 *     So: record +0x24 = friendly-fire offence count, A5-0x12b6 = friendly
 *     units destroyed this mission, A5-0x12ba = objective state (> 0 done,
 *     0 open, -1 failed by mission event, -2 original Hellcat lost)
 *     [STRONG INFERENCE from the texts]. Note slot 45 "By losing your
 *     airplane..." is queued when A5-0x12ba > 0 and slot 47 "By losing your
 *     original hellcat..." when it is 0, as the bytes say.
 */

/* VERIFIED (ID04::FUN_00002d86): ID04.bin 0x2d86..0x2de4 checked against an independent capstone disassembly.
 * LINK #0; JT $52a(A5-0x2174, *(A5-0xe5e)); BSR 0x588(word A5-0x13a4); JT $4a2(D0, A5-0x2160); JT $2fa; JT $512;
 * JT $302; BSR 0x9c(long 8, word $c, A5-0x2174); RTS (C convention) - identical to the C. */
/* Original: FUN_00002d86; source: ID04.c. Recovered name: set_score_item_text [PROVEN].
 * C args: +8 DialogPtr, +0xc short item. strcpy (JT $52a = ID02 0x2c8) the
 * STR# 129 slot 58 text "Score: " (A5-0xe5e) into A5-0x2174;
 * format_int_decimal_pstring(compute_pilot_score(current pilot A5-0x13a4),
 * A5-0x2160) (JT $4a2); JT $2fa = ID09 0x432 converts it to a C string;
 * strcat (JT $512 = ID02 0x2d8); JT $302 = ID09 0x416 converts A5-0x2174 to a
 * Pascal string in place; set_dialog_item_text(dialog, item, A5-0x2174).
 * Callers: ID04 0x2b4a (summary text step) and 0x3012
 * (show_mission_summary_dialog). ID02 0x2c8 / 0x2d8 bytes are strcpy /
 * strcat loops; ID09 0x416 shifts bytes right and stores the length
 * [PROVEN, bytes].
 */
void set_score_item_text /* Original: FUN_00002d86 */ (int dlg,short item)

{
  int unaff_A5;

  ansi_strcpy((char *)(unaff_A5 + -0x2174),*(char **)(unaff_A5 + -0xe5e)); /* JT $52a: "Score: " */
  format_int_decimal_pstring(compute_pilot_score(*(short *)(unaff_A5 + -0x13a4)), /* BSR 0x588 */
                             (unsigned char *)(unaff_A5 + -0x2160)); /* JT $4a2 */
  ansi_strcat((char *)(unaff_A5 + -0x2174),
              length_prefixed_bytes_to_c_string_in_place((unsigned char *)(unaff_A5 + -0x2160))); /* JT $512, JT $2fa */
  c2pstr_in_place((char *)(unaff_A5 + -0x2174)); /* JT $302 */
  set_dialog_item_text(dlg,item,(void *)(unaff_A5 + -0x2174)); /* BSR 0x9c, LEA $a(A7) */
  return;
}



// WARNING: Control flow encountered bad instruction data

/* VERIFIED (ID04::FUN_00002de6): ID04.bin 0x2de6..0x3122 checked against an independent capstone disassembly.
 * LINK -$4a; itemHit = 1; saves A5-0x13a4 / -0x225e; early exit to 0x3116; GetNewDialog(0x85), JT $472, five BSR 0xec,
 * BSR 0x6 x2, 0x17e6, 0xc4; pilot / current-mission branches with JT $4ea (0x18 bytes) and BSR 0x54 / 0x78; mode 3 adds
 * A5-0x12ce[0..11]; three BSR 0x1b8 variants; BSR 0x2d86; ShowWindow; TickCount; BSR 0x21d6 -> 0x192e; ModalDialog(JT $ca)
 * loop with exits on 3, 1 (+ confirm_end_mission == 2); BSR 0x189c; DisposDialog; award flag; HideWindow (main window, $A916); restores;
 * D0 = itemHit; RTS - identical to the C. */
/* Original: FUN_00002de6; source: ID04.c:809. Recovered name: show_mission_summary_dialog [STRONG INFERENCE].
 * C args +8 short pilot (-1 = the current mission), +0xa short mode, +0xc
 * title of item 3; returns the last itemHit. Body rebuilt as C below.
 * Bytes 0x2de6..0x3122 [PROVEN]: A5-0x2226 = local tallies (12 words); if
 * (mission A5-0x12f8 == 2 && pilot == -1) return 1 restoring only A5-0x13a4
 * (no summary); else GetNewDialog(133,...) $A97C,
 * JT $472 (ID02 0x4582); many item set-up calls through local helpers (0xec,
 * 0x06, 0xc4, 0x54, 0x78, 0x1b8, 0x17e6) and a 12-pass loop (the 12
 * tallies), list/record work through JT $4ea (ID02 0x232); second arg code 3
 * selects a different path (cmpi #3, $a(A6)).
 * DLOG 133 "Mission Summary" / DITL 133 [PROVEN, resource dump]: buttons
 * "End Mission", "OK", "Skip Text"; custom items; texts "Mission Awards",
 * "Targets Destroyed", "Total Aircraft Destroyed", "Score", "Score: 123456".
 * Called by conclude_mission with (-1, code).
 */
short show_mission_summary_dialog /* Original: FUN_00002de6 */ (short pilot,short mode,void *title)

{
  int unaff_A5;
  short savedPilot;                             /* -$30(A6) */
  short savedDefault;                           /* -$32(A6) */
  short tallies[12];                            /* -$4a(A6), 0x18 bytes */
  short itemHit;                                /* -$c(A6) */
  int dlg;                                      /* -$a(A6) */
  short i;                                      /* -2(A6) */

  itemHit = 1;
  savedPilot = *(short *)(unaff_A5 + -0x13a4);
  savedDefault = *(short *)(unaff_A5 + -0x225e);
  *(short **)(unaff_A5 + -0x2226) = tallies;    /* read by draw_targets_destroyed_row */
  if ((*(short *)(unaff_A5 + -0x12f8) == 2) && (pilot == -1)) {
    goto restore_pilot;                         /* BEQ.W 0x3116: Flight School, no summary */
  }
  dlg = GetNewDialog(0x85,0,-1);                /* $A97C: DLOG 133 "Mission Summary" */
  centre_window_on_screen(dlg);                 /* JT $472 */
  set_dialog_user_item_proc(dlg,6,(void *)(unaff_A5 + 0xaa));  /* BSR 0xec: draw_targets_destroyed_list */
  set_dialog_user_item_proc(dlg,5,(void *)(unaff_A5 + 0x152)); /* draw_mission_awards (0x1dde) */
  set_dialog_user_item_proc(dlg,7,(void *)(unaff_A5 + 0xea));  /* aircraft_kill_markers_user_item_proc */
  set_dialog_user_item_proc(dlg,9,(void *)(unaff_A5 + 0x7a));
  set_dialog_user_item_proc(dlg,0xf,(void *)(unaff_A5 + 0x15a));
  disable_dialog_control(dlg,3);                /* BSR 0x6 */
  disable_dialog_control(dlg,1);
  create_scrolling_text_item(dlg,8);            /* BSR 0x17e6 */
  set_dialog_control_title(dlg,3,title);        /* BSR 0xc4 */
  *(short *)(unaff_A5 + -0x2228) = pilot;
  if (*(short *)(unaff_A5 + -0x2228) != -1) {
    *(short *)(unaff_A5 + -0x13a4) = *(short *)(unaff_A5 + -0x2228);
    *(int *)(unaff_A5 + -0x2230) = 1;           /* text step delay */
    ansi_memcpy(tallies,(void *)((int)*(short *)(unaff_A5 + -0x13a4) * 0x40 + **(int **)(unaff_A5 + -0x13a8) + 0x28),0x18);
                                                /* JT $4ea: the pilot record's 12 tallies */
    hide_dialog_control(dlg,1);                 /* BSR 0x54 */
    hide_dialog_control(dlg,4);
  }
  else {
    *(short *)(unaff_A5 + -0x13a4) = *(short *)(**(int **)(unaff_A5 + -0x13ac) + 0x20); /* settings +0x20 */
    *(int *)(unaff_A5 + -0x2230) = 0x2d;
    ansi_memcpy(tallies,(void *)(unaff_A5 + -0x13a2),0x18); /* JT $4ea */
    show_dialog_control(dlg,1);                 /* BSR 0x78 */
    show_dialog_control(dlg,4);
  }
  if (mode == 3) {
    for (i = 0; i < 0xc; i = i + 1) {
      tallies[i] = tallies[i] + *(short *)(unaff_A5 + -0x12ce + (int)i * 2);
    }
    FUN_000001b8(dlg,2,3);                      /* BSR 0x1b8: default ring on user item 2, default item 3 */
    hide_dialog_control(dlg,4);
  }
  else if ((*(short *)(unaff_A5 + -0x14c4) != 0) && (*(short *)(unaff_A5 + -0x2228) == -1)) {
    FUN_000001b8(dlg,2,1);
  }
  else {
    FUN_000001b8(dlg,2,3);
  }
  set_score_item_text(dlg,0xe);                 /* BSR 0x2d86 */
  ShowWindow(dlg);                              /* $A915 */
  *(int *)(unaff_A5 + -0x222c) = TickCount();   /* $A975 */
  *(short *)(unaff_A5 + -0x2222) = 0;           /* text state */
  *(short *)(unaff_A5 + -0x2220) = mode;
  if (FUN_000021d6(dlg,8,mode) != 0) {          /* BSR 0x21d6: advance_mission_summary_text */
    update_summary_dialog_buttons(dlg,mode);    /* BSR 0x192e */
  }
  while (true) {
    ModalDialog((void *)(unaff_A5 + 0xca),&itemHit); /* $A991 */
    if (itemHit == 3) break;
    if ((itemHit == 4) && (*(int *)(unaff_A5 + -0x2230) != 0)) {
      *(int *)(unaff_A5 + -0x2230) = 1;         /* "Skip Text": shortest step delay */
    }
    if (itemHit == 1) {
      if (*(short *)(unaff_A5 + -0x2228) != -1) break;
      if (((mode & 0xff) == 1) && (*(short *)(unaff_A5 + -0x12b4) != 1)) {
        *(short *)(unaff_A5 + -0x14c0) = 1;
      }
      if (confirm_end_mission() == 2) break;    /* BSR 0x516 */
    }
  }
  dispose_scrolling_text_item();                /* BSR 0x189c; (dlg, 8) pushed but unused */
  DisposDialog(dlg);                            /* $A983 */
  if (((*(short *)(unaff_A5 + -0x2228) == -1) && ((mode & 0xff) == 1)) &&
      (*(short *)(unaff_A5 + -0x12b4) != 1)) {
    *(short *)(unaff_A5 + -0x14c0) = 1;
  }
  if ((itemHit == 1) && (*(short *)(unaff_A5 + -0x2228) == -1)) {
    *(short *)(unaff_A5 + -0x12f8) = 0;         /* mission number */
    HideWindow(*(int *)(unaff_A5 + -0x14ca));   /* $A916 (bytes 0x3104): the main window hidden */
    *(short *)(unaff_A5 + -0x14c6) = 0;
    *(short *)(unaff_A5 + -0x14c4) = 1;
  }
  *(short *)(unaff_A5 + -0x225e) = savedDefault;
restore_pilot:
  *(short *)(unaff_A5 + -0x13a4) = savedPilot;
  return itemHit;                               /* MOVE.W -$c(A6),D0; RTS */
}



/* VERIFIED (ID04::FUN_00003124): ID04.bin 0x3124..0x3176 checked against an independent capstone disassembly.
 * No LINK; CLR.L both globals; GetNamedResource('snd ', A5-0x2128); BEQ out; JT $272; SndNewChannel(&chan, 0, $80, nil);
 * TST chan; SndPlay(chan, h, 1); RTS - identical to the C. */
// WARNING: Control flow encountered bad instruction data

/* Original: FUN_00003124; source: ID04.c:828. Recovered name: play_named_sound_async [STRONG INFERENCE].
 * Ghidra truncated after clearing the globals; body rebuilt as C below. Bytes 0x3124..0x3176 [PROVEN]:
 *   A5-0x2156 = A5-0x2152 = 0;
 *   h = GetNamedResource('snd ' (0x736e6420), name = Pascal string at
 *       A5-0x2128) $A9A1 -> A5-0x2156; if (!h) return;
 *   HLock(h) (JT $272); SndNewChannel(&chan A5-0x2152, 0, 0x80, nil) $A807;
 *   if (chan) SndPlay(chan, h, true /async/) $A805.
 * Called by conclude_mission (once, when the pilot status is 1 "Dead" and an
 * option is on). [HYPOTHESIS] the name is one of the 'snd ' resources in the
 * dump (e.g. "ugh"); the A5 initial-data string is not yet read.
 */
void play_named_sound_async /* Original: FUN_00003124 */ (void)

{
  int unaff_A5;

  *(int *)(unaff_A5 + -0x2156) = 0;             /* sound handle */
  *(int *)(unaff_A5 + -0x2152) = 0;             /* SndChannelPtr */
  *(int *)(unaff_A5 + -0x2156) = GetNamedResource(0x736e6420,(unsigned char *)(unaff_A5 + -0x2128)); /* $A9A1: 'snd ' */
  if (*(int *)(unaff_A5 + -0x2156) == 0) {
    return;
  }
  HLock(*(int *)(unaff_A5 + -0x2156));          /* JT $272 (glue pops its argument) */
  SndNewChannel((int *)(unaff_A5 + -0x2152),0,0x80,0); /* $A807: synth 0, init 0x80, no callback; OSErr ignored */
  if (*(int *)(unaff_A5 + -0x2152) != 0) {
    SndPlay(*(int *)(unaff_A5 + -0x2152),*(int *)(unaff_A5 + -0x2156),1); /* $A805: async; OSErr ignored */
  }
  return;
}



/* VERIFIED (ID04::FUN_00003178): ID04.bin 0x3178..0x31a8 checked against an independent capstone disassembly.
 * chan: SndDisposeChannel(chan, 1), CLR.L; h: JT $27a, ReleaseResource, CLR.L; RTS - identical to the C. */
// WARNING: Control flow encountered bad instruction data

/* Original: FUN_00003178; source: ID04.c:843. Recovered name: stop_named_sound [STRONG INFERENCE].
 * Bytes 0x3178..0x31a8 [PROVEN]: if (chan A5-0x2152) {
 *   SndDisposeChannel(chan, true) $A801; chan = 0 }; if (h A5-0x2156) {
 *   HUnlock(h) (JT $27a); ReleaseResource(h) $A9A3; h = 0 }.
 * Inverse of play_named_sound_async; called by conclude_mission.
 */
void stop_named_sound /* Original: FUN_00003178 */ (void)

{
  int unaff_A5;

  if (*(int *)(unaff_A5 + -0x2152) != 0) {
    SndDisposeChannel(*(int *)(unaff_A5 + -0x2152),1); /* $A801: quitNow; OSErr ignored */
    *(int *)(unaff_A5 + -0x2152) = 0;
  }
  if (*(int *)(unaff_A5 + -0x2156) != 0) {
    HUnlock(*(int *)(unaff_A5 + -0x2156));      /* JT $27a */
    ReleaseResource(*(int *)(unaff_A5 + -0x2156)); /* $A9A3 */
    *(int *)(unaff_A5 + -0x2156) = 0;
  }
  return;
}



/* VERIFIED (ID04::FUN_000031aa): ID04.bin 0x31aa..0x325e checked against an independent capstone disassembly.
 * LINK -6; copies A5-0x14c4 / -0x14c2 to unused locals; one-shot sound gate (sets -0x14c2 before testing -0x12ee); mission-over
 * flag; BSR 0x2de6(-1, code, long $a); BSR 0x3178 if -0x12ee; status write-back with ChangedResource + UpdateResFile;
 * D0 = result; RTS - identical to the C. */
// WARNING: Control flow encountered bad instruction data

/* Original: FUN_000031aa; source: ID04.c:864. Recovered name: conclude_mission [STRONG INFERENCE].
 * Body rebuilt as C below (Ghidra truncated after the status write). JT $da; callers
 * [PROVEN, bytes]: ID02 file 0x8cc and 0x3752 (do_menu_command menu 2 item 5,
 * which passes code 3 and long A5-0xd6a).
 * Args: word code (param_1 high), long (second arg).
 *   if (mode A5-0x12f8 != 2 && status A5-0x12b4 == 1 && code != 3 &&
 *       first time (A5-0x14c2 == 0, then set to 1) && option A5-0x12ee)
 *     play_named_sound_async (FUN_00003124);
 *   if (code != 3 && status != 0) A5-0x14c4 = 1;   ("mission over": makes
 *       confirm_end_mission return 2 without asking)
 *   r = show_mission_summary_dialog (FUN_00002de6)(-1, code); if (option A5-0x12ee) stop_named_sound (FUN_00003178);
 *   if current pilot record (A5-0x13a4) +0x20 != status: store it,
 *   ChangedResource(roster) $A9AA, UpdateResFile(A5-0x1002) $A999; return r
 *   [PROVEN, bytes 0x321c..0x325e].
 * Status values follow the A5-0xfae strings (0 Active, 1 Dead, 2 Retired,
 * 3 POW, 4 Discharged, 5 MIA) [STRONG INFERENCE: status 1 triggers the
 * special one-shot path].
 */
short conclude_mission /* Original: FUN_000031aa */ (short code,void *title)

{
  int unaff_A5;
  short overCopy;                               /* -2(A6): A5-0x14c4 on entry, never read */
  short soundCopy;                              /* -4(A6): A5-0x14c2 on entry, never read */
  short result;                                 /* -6(A6) */

  overCopy = *(short *)(unaff_A5 + -0x14c4);
  soundCopy = *(short *)(unaff_A5 + -0x14c2);
  if ((((*(short *)(unaff_A5 + -0x12f8) != 2) && (*(short *)(unaff_A5 + -0x12b4) == 1)) &&
      (code != 3)) && (*(short *)(unaff_A5 + -0x14c2) == 0)) {
    *(short *)(unaff_A5 + -0x14c2) = 1;         /* one-shot */
    if (*(short *)(unaff_A5 + -0x12ee) != 0) {
      play_named_sound_async();                 /* BSR 0x3124 */
    }
  }
  if ((code != 3) && (*(short *)(unaff_A5 + -0x12b4) != 0)) {
    *(short *)(unaff_A5 + -0x14c4) = 1;         /* mission over */
  }
  result = show_mission_summary_dialog(-1,code,title); /* BSR 0x2de6, ADDQ #8 */
  if (*(short *)(unaff_A5 + -0x12ee) != 0) {
    stop_named_sound();                         /* BSR 0x3178 */
  }
  if (*(short *)((int)*(short *)(unaff_A5 + -0x13a4) * 0x40 + **(int **)(unaff_A5 + -0x13a8) + 0x20) !=
      *(short *)(unaff_A5 + -0x12b4)) {
    *(short *)((int)*(short *)(unaff_A5 + -0x13a4) * 0x40 + **(int **)(unaff_A5 + -0x13a8) + 0x20) =
         *(short *)(unaff_A5 + -0x12b4);        /* pilot status */
    ChangedResource(*(int *)(unaff_A5 + -0x13a8)); /* $A9AA: roster */
    UpdateResFile(*(short *)(unaff_A5 + -0x1002)); /* $A999 */
  }
  return result;
}



/* VERIFIED (ID04::FUN_00003260): ID04.bin 0x3260..0x3350 checked against an independent capstone disassembly.
 * LINK -2; SetOrigin; OffsetRect(A5-0x2144, w/2, h/2), ClipRect; ForeColor 30 / 33 on A5-0x137a; PenSize(1,1); i 1..3 grid lines
 * with MULS/DIVS #4; PenSize(3,3); centre cross; A5-0x214e = 1; RTS - identical to the C. */
/* Original: FUN_00003260; source: ID04.c. Recovered name: draw_map_grid_and_centre_mark [PROVEN].
 * Decoded from ID04.bin bytes at file 0x3260.
 * No arguments. SetOrigin(A5-0x2148, A5-0x2146) ($A878); OffsetRect(map rect A5-0x2144, width/2, height/2) ($A8A8) and ClipRect ($A87B); ForeColor 30 (whiteColor) when A5-0x137a == 1, else 33 (blackColor) ($A862); PenSize(1, 1); for i = 1..3 MoveTo / Line ($A893 / $A892) a vertical line at x = i * w / 4 and a horizontal line at y = i * h / 4 (w, h = A5-0x214c, A5-0x214a): a 4 x 4 grid; then PenSize(3, 3) and a small cross at the centre: MoveTo(w/2 - 1, h/2 - 1), Move(0, -5), Line(0, 10), Move(-5, -5), Line(10, 0) ($A894 / $A892); A5-0x214e = 1 (grid drawn). Callers: plot_map_symbol_callback (0x3368), draw_map_view_item (0x350a). Body rebuilt as C below.
 */
void draw_map_grid_and_centre_mark /* Original: FUN_00003260 */ (void)

{
  int unaff_A5;
  short i;                                      /* -2(A6) */
  short w;                                      /* A5-0x214c */
  short h;                                      /* A5-0x214a */

  SetOrigin(*(short *)(unaff_A5 + -0x2148),*(short *)(unaff_A5 + -0x2146)); /* $A878 */
  w = *(short *)(unaff_A5 + -0x214c);
  h = *(short *)(unaff_A5 + -0x214a);
  OffsetRect((short *)(unaff_A5 + -0x2144),(short)((int)w / 2),(short)((int)h / 2)); /* $A8A8: MOVEA.W + DIVS.W #2 */
  ClipRect((short *)(unaff_A5 + -0x2144));      /* $A87B */
  if (*(short *)(unaff_A5 + -0x137a) == 1) {
    ForeColor(0x1e);                            /* $A862: whiteColor */
  }
  else {
    ForeColor(0x21);                            /* blackColor */
  }
  PenSize(1,1);                                 /* $A89B */
  for (i = 1; i < 4; i = i + 1) {
    MoveTo((short)((int)(short)(i * w) / 4),0); /* $A893: MULS.W, EXT.L, DIVS.W #4 */
    Line(0,h);                                  /* $A892 */
    MoveTo(0,(short)((int)(short)(i * h) / 4));
    Line(w,0);
  }
  PenSize(3,3);
  MoveTo((short)((int)w / 2) + -1,(short)((int)h / 2) + -1);
  Move(0,-5);                                   /* $A894 */
  Line(0,10);
  Move(-5,-5);
  Line(10,0);
  *(short *)(unaff_A5 + -0x214e) = 1;           /* grid drawn */
  return;
}



/* VERIFIED (ID04::FUN_00003352): ID04.bin 0x3352..0x33d4 checked against an independent capstone disassembly.
 * LINK -8; save A5/D2; A5 = $904; BSR 0x3260 when A5-0x214e == 0; x / y long rewrite with DIVS #2, SUB.W, EXT.L; ForeColor(30);
 * MoveTo(low words); DrawChar(EXTB.L byte $b); restore D2/A5; RTS - identical to the C. */
/* Original: FUN_00003352; source: ID04.c. Recovered name: plot_map_symbol_callback [PROVEN].
 * Decoded from ID04.bin bytes at file 0x3352.
 * C-callable callback reached through JT $72 (CODE 0 entry -> ID04 0x3352), passed by draw_map_view_item to the function pointer A5-0x1052 (pea $72(A5) at 0x34f6). Saves A5 and D2, loads A5 from CurrentA5 ($0904). If A5-0x214e == 0 draws the grid first (draw_map_grid_and_centre_mark). Args: long +8 whose low byte (+0xb) is the symbol, +0xc long x, +0x10 long y; x = x - (short)(A5-0x2148 - w/2) + A5-0x2148, likewise y with A5-0x2146 and h (w, h = A5-0x214c, A5-0x214a), i.e. x + w/2 and y + h/2 in the map's origin-shifted port; ForeColor 30 (whiteColor); MoveTo(x, y); DrawChar(symbol) ($A883, EXTB.L on the byte). Draws one map marker character per object [STRONG INFERENCE]. Body rebuilt as C below.
 */
void plot_map_symbol_callback /* Original: FUN_00003352 */ (int symbol,int x,int y)

{
  int unaff_A5;                                 /* saved at -4(A6), D2 at -8(A6); A5 = CurrentA5 ($0904) */

  unaff_A5 = *(int *)0x904;
  if (*(short *)(unaff_A5 + -0x214e) == 0) {
    draw_map_grid_and_centre_mark();            /* BSR 0x3260 */
  }
  x = (x - (int)(short)(*(short *)(unaff_A5 + -0x2148) - (short)((int)*(short *)(unaff_A5 + -0x214c) / 2))) +
      (int)*(short *)(unaff_A5 + -0x2148);      /* SUB.W, EXT.L, SUB.L, ADD.L (MOVEA.W) */
  y = (y - (int)(short)(*(short *)(unaff_A5 + -0x2146) - (short)((int)*(short *)(unaff_A5 + -0x214a) / 2))) +
      (int)*(short *)(unaff_A5 + -0x2146);
  ForeColor(0x1e);                              /* $A862: whiteColor */
  MoveTo((short)x,(short)y);                    /* $A893: low words $e / $12(A6) */
  DrawChar((short)(char)symbol);                /* $A883: byte $b(A6), EXTB.L */
  return;                                       /* restores D2 and A5 */
}



/* VERIFIED (ID04::FUN_000033d6): ID04.bin 0x33d6..0x35f6 checked against an independent capstone disassembly.
 * LINK -$46; thePort copy; BSR 0x120; SetPort; GetDItem -> A5-0x2144; NEG origin, SetOrigin, OffsetRect; w/h; RGB {0,0,-1};
 * JT $1ca + FillRect or ForeColor(409) + PaintRect; centre SetOrigin / OffsetRect / ClipRect; MULU.L #$ce40 / DIVS.L call through
 * A5-0x1052 with JT $72; BSR 0x3260 if needed; white N and arrow; reset; JT $4a2 / $2fa / $512 / $302; BSR 0x9c(item 7);
 * RTS - identical to the C. */
/* Original: FUN_000033d6; source: ID04.c. Recovered name: draw_map_view_item [STRONG INFERENCE].
 * Decoded from ID04.bin bytes at file 0x33d6.
 * C args: +8 DialogPtr, +0xc short item. Saves thePort; A5-0x214e = 0; frame_dialog_item_box; SetPort(dialog); GetDItem -> A5-0x2144 (map rect); SetOrigin(-left, -top) and OffsetRect so the rect starts at 0, 0; A5-0x214c / -0x214a = width / height. Background: if A5-0x137a == 1, FillRect with the pattern returned by JT $1ca (ID06 file 0x116, rgb_to_bw_pattern) for the local RGBColor {0, 0, 0xffff} (blue; corrected from the bytes: -$14/-$12 cleared, -$10 = -1); else ForeColor 409 (blueColor) and PaintRect ($A8A2) - a blue sea. SetOrigin to the centre, ClipRect. Calls the function pointer A5-0x1052(scale, JT $72 plot_map_symbol_callback) with scale = settings +0x26 * 4 * 0xce40 / width (MULU.L / DIVS.L) - the plotting itself lives elsewhere (A5-0x1052 is set outside ID04) [PROVEN call; HYPOTHESIS: the overlay walks the world objects]. Draws the grid if the callback did not; ForeColor(30 = white) (corrected: not black); PenSize(2, 2); near the top-right corner an "N" (MoveTo(w-18, 20), Line(0,-12), Line(8,12), Line(0,-12)) and an up arrow (MoveTo(w-20, 30), Line(6,-6), Line(6,6); MoveTo(w-14, 24), Line(0,18)) [PROVEN strokes; north marker STRONG INFERENCE]; ForeColor(black); restores origin, pen, clip and port; item 7 text = decimal settings +0x26 + STR# 129 slot 59 " mi./grid" via set_dialog_item_text. So settings +0x26 = map scale in miles per grid square [STRONG INFERENCE]. Callers: 0x3604, 0x3a10, 0x3a3e. Body rebuilt as C below.
 */
void draw_map_view_item /* Original: FUN_000033d6 */ (int dlg,short item)

{
  int unaff_A5;
  unsigned char text[50];                       /* -$46(A6) */
  short blue[3];                                /* -$14(A6): RGBColor {0, 0, 0xffff} */
  int savedPort;                                /* -$e(A6) */
  int itemHandle;                               /* -$a(A6) */
  short itemType;                               /* -6(A6) */
  short *mapRect;                               /* A5-0x2144: top, left, bottom, right */
  short w;                                      /* A5-0x214c */
  short h;                                      /* A5-0x214a */

  mapRect = (short *)(unaff_A5 + -0x2144);
  savedPort = *(int *)(unaff_A5 + -0x160c);     /* thePort */
  *(short *)(unaff_A5 + -0x214e) = 0;           /* grid not drawn yet */
  frame_dialog_item_box(dlg,item);              /* BSR 0x120 */
  SetPort(dlg);                                 /* $A873 */
  GetDItem(dlg,item,&itemType,&itemHandle,mapRect); /* $A98D */
  *(short *)(unaff_A5 + -0x2148) = -mapRect[1];
  *(short *)(unaff_A5 + -0x2146) = -mapRect[0];
  SetOrigin(*(short *)(unaff_A5 + -0x2148),*(short *)(unaff_A5 + -0x2146)); /* $A878 */
  OffsetRect(mapRect,-mapRect[1],-mapRect[0]); /* $A8A8: rect now starts at 0, 0 */
  *(short *)(unaff_A5 + -0x214c) = mapRect[3];  /* width */
  *(short *)(unaff_A5 + -0x214a) = mapRect[2];  /* height */
  w = *(short *)(unaff_A5 + -0x214c);
  h = *(short *)(unaff_A5 + -0x214a);
  blue[1] = 0;
  blue[0] = 0;
  blue[2] = -1;
  if (*(short *)(unaff_A5 + -0x137a) == 1) {
    FillRect(mapRect,rgb_to_bw_pattern(blue[0],*(int *)&blue[1])); /* JT $1ca (RGBColor by value, 6 bytes), $A8A5 */
  }
  else {
    ForeColor(0x199);                           /* $A862: blueColor */
    PaintRect(mapRect);                         /* $A8A2: the sea */
  }
  SetOrigin(*(short *)(unaff_A5 + -0x2148) - (short)((int)w / 2),
            *(short *)(unaff_A5 + -0x2146) - (short)((int)h / 2)); /* origin at the map centre */
  OffsetRect(mapRect,(short)((int)(short)-w / 2),(short)((int)(short)-h / 2)); /* NEG.W, EXT.L, DIVS.W #2 */
  ClipRect(mapRect);                            /* $A87B */
  (**(code **)(unaff_A5 + -0x1052))
            ((int)((unsigned int)(int)(short)(*(short *)(**(int **)(unaff_A5 + -0x13ac) + 0x26) << 2) * 0xce40) /
             (int)w,(void *)(unaff_A5 + 0x72)); /* ASL.W #2, EXT.L, MULU.L #$ce40, DIVS.L; JT $72 plot_map_symbol_callback */
  if (*(short *)(unaff_A5 + -0x214e) == 0) {
    draw_map_grid_and_centre_mark();            /* BSR 0x3260 */
  }
  ForeColor(0x1e);                              /* whiteColor */
  PenSize(2,2);                                 /* $A89B */
  MoveTo(w + -0x12,0x14);                       /* $A893: an "N" */
  Line(0,-0xc);                                 /* $A892 */
  Line(8,0xc);
  Line(0,-0xc);
  MoveTo(w + -0x14,0x1e);                       /* arrow head */
  Line(6,-6);
  Line(6,6);
  MoveTo(w + -0xe,0x18);                        /* arrow shaft */
  Line(0,0x12);
  ForeColor(0x21);                              /* blackColor */
  SetOrigin(0,0);
  PenSize(1,1);
  ClipRect((short *)(*(int *)(unaff_A5 + -0x160c) + 0x10)); /* &thePort->portRect */
  SetPort(savedPort);
  length_prefixed_bytes_to_c_string_in_place
            (format_int_decimal_pstring((int)*(short *)(**(int **)(unaff_A5 + -0x13ac) + 0x26),text)); /* JT $4a2, JT $2fa */
  ansi_strcat((char *)text,*(char **)(unaff_A5 + -0xe5a)); /* JT $512: " mi./grid" */
  c2pstr_in_place((char *)text);                /* JT $302 */
  set_dialog_item_text(dlg,7,text);             /* BSR 0x9c */
  return;
}



/* VERIFIED (ID04::FUN_000035f8): ID04.bin 0x35f8..0x3612 checked against an independent capstone disassembly.
 * LINK #0; push word 8(A6), long $a(A6); BSR 0x33d6; ADDQ #6; Pascal return popping 6 - identical to the C.
 * The unexported tracker 0x3614..0x3900 described in the header was re-read against the same disassembly (its claims hold). */
/* Original: FUN_000035f8; source: ID04.c. Recovered name: map_view_user_item_proc [PROVEN].
 * Decoded from ID04.bin bytes at file 0x35f8.
 * Pascal user-item procedure (DialogPtr at +0xa, item at +8; pops 6 bytes): calls draw_map_view_item(dialog, item). Reached through JT $b2 (CODE 0 entry -> ID04 0x35f8); installed for item 8 of DLOG 137 "Map" by run_map_dialog (0x39a8).
 * The following bytes 0x3614..0x3900 (not exported by Ghidra) are track_map_bearing_and_distance [STRONG INFERENCE name] [PROVEN, bytes]: C args +8 DialogPtr, +0xc EventRecord *. GetDItem(item 8), GlobalToLocal, PtInRect; while the button is down (StillDown $A974 / GetMouse $A972) and the mouse is inside the map: XOR-draws (PenMode 2, $A89C) a line from the map centre to the mouse, erasing the previous one; dx, dy from the centre; bearing via the function pointer A5-0x1056 (dx, -dy, dx*dx + dy*dy -> angle in 1/0x4000 turns) as 360 - angle * 360 / 0x4000, item 5 text = decimal + A5-0x2122 [STRONG INFERENCE: a degree sign]; distance = (A5-0x105a)(dx*dx + dy*dy) [STRONG INFERENCE: integer sqrt] * scale (settings +0x26) / (map width / 40), item 6 text = "<d / 10>" + A5-0x2120 [STRONG INFERENCE: a decimal point] + "<d % 10>" + STR# 129 slot 60 " mi."; on release the last line is erased. Caller: map_dialog_filter_proc (mouseDown).
 */
/* Pascal user-item procedure: dlg at $a(A6), item at 8(A6); pops 6 bytes (UNLK, MOVEA.L (A7)+,A0, LEA 6(A7), JMP (A0)) */
void map_view_user_item_proc /* Original: FUN_000035f8 */ (int dlg,short item)

{
  draw_map_view_item(dlg,item);                 /* push word 8, long $a; BSR 0x33d6; ADDQ #6 */
  return;                                       /* Ghidra read the JMP (A0) return as a jump table */
}



/* VERIFIED (ID04::FUN_00003902): ID04.bin 0x3902..0x3974 checked against an independent capstone disassembly.
 * LINK #0; JT $2a on evt->what (3 -> 0x3920, 6 -> 0x394e, 1 -> 0x395a, default 0x3968); keyDown: JT $32 on message AND.L #$ff
 * (0xd, 3 -> 0x3942: *itemHit = A5-0x225e, D0 = 1); update: JT $492(evt); mouseDown: BSR 0x3614(dlg, evt); D0 = 0; Pascal
 * return popping 12 with MOVE.B D0,(A7) - identical to the C. */
/* Original: FUN_00003902; source: ID04.c. Recovered name: map_dialog_filter_proc [PROVEN].
 * Decoded from ID04.bin bytes at file 0x3902.
 * Pascal ModalDialog filter (DialogPtr +0x10, EventRecord * +0xc, itemHit * +8; pops 0xc bytes, Boolean result). Switch on event->what through JT $2a (table at 0x3910: keyDown 3 -> 0x3920, updateEvt 6 -> 0x394e, mouseDown 1 -> 0x395a): keyDown Return / Enter -> *itemHit = default item A5-0x225e, true; updateEvt -> JT $492 (ID02 0x4d6a), false; mouseDown -> track_map_bearing_and_distance(dialog, event) (0x3614), false. Reached through JT $d2 (-> ID04 0x3902). Body rebuilt as C below.
 * The following bytes 0x3976..0x3a54 (not exported by Ghidra) are run_map_dialog [STRONG INFERENCE name], JT $10a (-> ID04 0x3976) [PROVEN, bytes]: does nothing in mission 2 (Flight School, A5-0x12f8 == 2); GetNewDialog(0x89 = DLOG 137 "Map"); JT $472; item 8 user item JT $b2 (map view); 0x1b8(dialog, 2, 1) default ring; ShowWindow; loop ModalDialog(JT $d2): item 3 "Zoom In" -> settings +0x26 /= 2 while > 1, redraw the map; item 4 "Zoom Out" -> settings +0x26 *= 2 while < 256, redraw; until item 1 (OK); DisposDialog. DITL 137 legend: "+ - Hellcat, T - Primary Target, C - Friendly Carrier, B - Friendly Base, A - Airfield" - the characters drawn by plot_map_symbol_callback [PROVEN text].
 */
/* Pascal ModalDialog filter: dlg $10(A6), evt $c(A6), itemHit 8(A6); pops 12 bytes, BOOLEAN result byte. */
char map_dialog_filter_proc /* Original: FUN_00003902 */ (int dlg,short *evt,short *itemHit)

{
  int unaff_A5;

  switch (evt[0]) {                             /* JT $2a (ID01 0x96, word table at 0x3910) */
  case 3:                                       /* keyDown */
    switch (*(unsigned int *)(evt + 1) & 0xff) {  /* JT $32 (ID01 0xaa, table at 0x3932) on message & 0xff */
    case 0xd:                                   /* Return */
    case 3:                                     /* Enter */
      *itemHit = *(short *)(unaff_A5 + -0x225e); /* default item */
      return 1;
    }
    break;
  case 6:                                       /* updateEvt */
    handle_update_event(evt);                   /* JT $492 */
    break;
  case 1:                                       /* mouseDown */
    FUN_00003614(dlg,evt);                      /* BSR 0x3614: track_map_bearing_and_distance (unexported) */
    break;
  }
  return 0;
}



/* VERIFIED (ID04::FUN_00003a56): ID04.bin 0x3a56..0x3a8a checked against an independent capstone disassembly.
 * LINK -$10; SystemTask; GetNextEvent(-1, -$10) result popped; JT $3a on what (1, 3, 5 -> 0x3a82 MOVEQ #1; 2, 4, default
 * -> 0x3a86 MOVEQ #0); RTS - identical to the C. */
/* Original: FUN_00003a56; source: ID04.c. Recovered name: poll_click_or_key_event [PROVEN].
 * Decoded from ID04.bin bytes at file 0x3a56.
 * SystemTask ($A9B4); GetNextEvent(everyEvent = -1, &event) ($A970); switch on event.what through JT $3a (table at 0x3a72: lo 1, hi 5, default -> 0x3a86): returns 1 for mouseDown (1), keyDown (3) and autoKey (5), 0 for mouseUp (2), keyUp (4) and any other event. The event is consumed either way. Body rebuilt as C below.
 */
int poll_click_or_key_event /* Original: FUN_00003a56 */ (void)

{
  short event[8];                               /* -$10(A6): EventRecord, what first */

  SystemTask();                                 /* $A9B4 */
  GetNextEvent(-1,event);                       /* $A970: everyEvent; Boolean result dropped */
  switch (event[0]) {                           /* JT $3a (ID01 0xbe, range table at 0x3a72, lo 1, hi 5) */
  case 1:                                       /* mouseDown */
  case 3:                                       /* keyDown */
  case 5:                                       /* autoKey */
    return 1;                                   /* MOVEQ #1 */
  }
  return 0;                                     /* mouseUp, keyUp and others */
}



/* VERIFIED (ID04::FUN_00003a8c): ID04.bin 0x3a8c..0x3d40 checked against an independent capstone disassembly.
 * LINK -$56; GetNewDialog 0x8a / 0x7f; BEQ.W exit; JT $472, ShowWindow, DrawDialog, GetPort, SetPort; item 3 MoveTo, TextFont 1,
 * TextSize 8; 'vers' 1 digits (ASR.W #8, AND #$f0 + LSR.W #8, AND #$f), length 5, DrawString; item 2 rect copies; 'PICT' $83:
 * JT $272, $28a; frame OffsetRect x2; ClipRect; DrawPicture; TickCount + $b4 wait with BSR 0x3a56; scroll loop (CopyBits,
 * DrawPicture, frame -1, TickCount + 2, Button); JT $282, $27a, ReleaseResource; SetPort; DisposDialog; RTS - identical to the C. */
/* Original: FUN_00003a8c; source: ID04.c. Recovered name: show_about_dialog [STRONG INFERENCE].
 * Decoded from ID04.bin bytes at file 0x3a8c.
 * GetNewDialog(0x8a = DLOG 138 "About Hellcats 1-Bit") when A5-0x137a == 1, else GetNewDialog(0x7f = DLOG 127 "About Hellcats"); returns at once when it fails. JT $472; ShowWindow; DrawDialog; SetPort; GetDItem(item 3), MoveTo its box, TextFont(1), TextSize(8); GetResource(vers, 1) ($A9A0) and draws a 5-character version "M.m.r" from its first word: M = (word >> 8) + '0', m = ((word & 0xf0) >> 8) + '0' - always '0', an original bug (>> 4 was surely meant) [PROVEN, bytes] - r = (word & 0xf) + '0'. Then GetDItem(item 2) -> box; GetResource('PICT', 131): if present, HLock + HNoPurge, centre its frame horizontally at the top of the box, DrawPicture; wait up to 180 ticks (a click or key skips everything); then scroll the box up one pixel every 2 ticks with CopyBits (srcCopy) and redraw the picture one line higher through a one-line clip at the bottom, for picture-height steps or until a click, key or Button(); HPurge, HUnlock, ReleaseResource. Finally SetPort(saved) and DisposDialog. Body rebuilt as C below. So A5-0x137a == 1 selects the 1-bit (black and white) variants, which matches draw_map_view_item (pattern fill instead of the blue sea) [STRONG INFERENCE]. Reached through JT $162 (-> ID04 0x3a8c).
 */
void show_about_dialog /* Original: FUN_00003a8c */ (void)

{
  int unaff_A5;
  unsigned char verText[6];                     /* -$56(A6): Pascal string, length 5 */
  int savedPort;                                /* -$4c(A6) */
  int deadline;                                 /* -$48(A6) */
  int lines;                                    /* -$44(A6): picture height, 0 = stop */
  short strip[4];                               /* -$40(A6): bottom line of the box */
  short dstRect[4];                             /* -$38(A6): box one pixel higher */
  short srcRect[4];                             /* -$30(A6): box */
  short frame[4];                               /* -$28(A6): picture frame */
  short box[4];                                 /* -$20(A6): top, left, bottom, right */
  int pic;                                      /* -$18(A6) */
  int versH;                                    /* -$14(A6) */
  int itemHandle;                               /* -$10(A6) */
  short margin;                                 /* -$c(A6) */
  short i;                                      /* -$a(A6) */
  short itemType;                               /* -8(A6) */
  short ver;                                    /* -6(A6) */
  int dlg;                                      /* -4(A6) */

  if (*(short *)(unaff_A5 + -0x137a) == 1) {
    dlg = GetNewDialog(0x8a,0,-1);              /* $A97C: DLOG 138 "About Hellcats 1-Bit" */
  }
  else {
    dlg = GetNewDialog(0x7f,0,-1);              /* DLOG 127 "About Hellcats" */
  }
  if (dlg == 0) {
    return;
  }
  centre_window_on_screen(dlg);                 /* JT $472 */
  ShowWindow(dlg);                              /* $A915 */
  DrawDialog(dlg);                              /* $A981 */
  GetPort(&savedPort);                          /* $A874 */
  SetPort(dlg);                                 /* $A873 */
  GetDItem(dlg,3,&itemType,&itemHandle,box);    /* $A98D */
  MoveTo(box[1],box[2]);                        /* $A893: left, bottom */
  TextFont(1);                                  /* $A887 */
  TextSize(8);                                  /* $A88A */
  versH = GetResource(0x76657273,1);            /* $A9A0: 'vers' 1; not tested for NULL */
  ver = **(short **)versH;
  verText[1] = (char)(ver >> 8) + '0';          /* ASR.W #8: major */
  verText[2] = '.';
  verText[3] = (char)((unsigned short)(ver & 0xf0) >> 8) + '0'; /* AND #$f0 then LSR.W #8: always '0' [PROVEN, bytes] */
  verText[4] = '.';
  verText[5] = (char)(ver & 0xf) + '0';
  verText[0] = 5;
  DrawString(verText);                          /* $A884 */
  GetDItem(dlg,2,&itemType,&itemHandle,box);    /* the credits box */
  *(int *)srcRect = *(int *)box;  *(int *)(srcRect + 2) = *(int *)(box + 2);
  *(int *)dstRect = *(int *)box;  *(int *)(dstRect + 2) = *(int *)(box + 2);
  dstRect[0] = dstRect[0] + -1;
  dstRect[2] = dstRect[2] + -1;
  *(int *)strip = *(int *)box;    *(int *)(strip + 2) = *(int *)(box + 2);
  strip[0] = strip[2] + -1;
  pic = GetResource(0x50494354,0x83);           /* 'PICT' 131 */
  if (pic != 0) {
    HLock(pic);                                 /* JT $272 */
    HNoPurge(pic);                              /* JT $28a (ID09 0x28e, $A04A) */
    *(int *)frame = *(int *)(*(int *)pic + 2);  /* picFrame */
    *(int *)(frame + 2) = *(int *)(*(int *)pic + 6);
    OffsetRect(frame,-frame[1],-frame[0]);      /* $A8A8: frame at 0, 0 */
    margin = (short)((int)(short)(box[3] - box[1] - frame[3] - frame[1]) / 2);
    OffsetRect(frame,box[1] + margin,box[0]);   /* centred, top of the box */
    ClipRect(box);                              /* $A87B */
    DrawPicture(pic,frame);                     /* $A8F6 */
    lines = (int)(short)(*(short *)(*(int *)pic + 6) - *(short *)(*(int *)pic + 2));
    deadline = TickCount() + 0xb4;              /* $A975: 3 seconds */
    while (TickCount() < deadline) {
      if (poll_click_or_key_event() != 0) {     /* BSR 0x3a56 */
        lines = 0;
        break;
      }
    }
    i = 0;
    deadline = 0;
    while (((int)i < lines) && (poll_click_or_key_event() == 0)) {
      if (deadline < TickCount()) {             /* scroll one line every 2 ticks */
        ClipRect(box);
        CopyBits((void *)(dlg + 2),(void *)(dlg + 2),srcRect,dstRect,0,0); /* $A8EC: srcCopy, scroll up 1 */
        ClipRect(strip);
        DrawPicture(pic,frame);
        frame[0] = frame[0] + -1;
        frame[2] = frame[2] + -1;
        i = i + 1;
        deadline = TickCount() + 2;
        if (Button() != 0) break;               /* $A974 */
      }
    }
    HPurge(pic);                                /* JT $282 (ID09 0x284, $A049) */
    HUnlock(pic);                               /* JT $27a */
    ReleaseResource(pic);                       /* $A9A3 */
  }
  SetPort(savedPort);
  DisposDialog(dlg);                            /* $A983 */
  return;
}



/* VERIFIED (ID04::FUN_00003d42): ID04.bin 0x3d42..0x3d78 checked against an independent capstone disassembly.
 * LINK -$10; CLR.W result, push 1, pea -$10, JT $1f2, result popped; TST.B -7 BEQ / CMPI.W #3,-$a BGE; JT $4ba(long A5-0xe52,
 * word 0), MOVEQ #0; else MOVEQ #1; RTS - identical to the C. */
/* Original: FUN_00003d42; source: ID04.c:993. Recovered name: check_system_requirements [STRONG INFERENCE].
 * Bytes 0x3d42..0x3d78 (last function of ID04); body rewritten as typed C below.
 * JT $f2, called by ID02 initialize_application (returns 0 -> ExitToShell).
 *   SysEnvirons(1, &env) (JT $1f2 = ID09 sysenvirons dispatcher);
 *   if (!env.hasColorQD (env+9) || env.processor (env+6) < 3 /env68020/) {
 *     show_caution_alert_with_number(STR# 129 slot 61, 0) (JT $4ba; slot 61 =
 *       "Hellcats requires a Macintosh with color QuickDraw and a 68020 or
 *       higher" [PROVEN, resource dump]); return 0; }
 *   return 1.
 * Explains the 68020-only instructions (EXTB.L, MULU.L, DIVS.L) used elsewhere.
 */
int check_system_requirements /* Original: FUN_00003d42 */ (void)

{
  int unaff_A5;
  char env[16];                                 /* -$10(A6): SysEnvRec; processor +6 (-$a), hasColorQD +9 (-7) */

  SysEnvirons(1,env);                           /* JT $1f2 (ID09 0x20); OSErr popped and ignored */
  if ((env[9] == '\0') || (*(short *)(env + 6) < 3)) { /* no Color QuickDraw, or below env68020 */
    show_caution_alert_with_number(*(int *)(unaff_A5 + -0xe52),0); /* JT $4ba: STR# 129 slot 61 */
    return 0;
  }
  return 1;
}


