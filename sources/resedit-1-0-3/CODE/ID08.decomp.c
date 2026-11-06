typedef unsigned char   undefined;

typedef unsigned short    undefined2;
typedef unsigned int    undefined4;
typedef unsigned char    byte;



/* VERIFIED (ID08::FUN_00000006): ID08.bin 0x06..0x336 checked against an independent capstone disassembly.
 * Body rebuilt from the bytes (Ghidra's stack-confused body and halt_baddata dropped). Every JSR d16(A5) was
 * resolved through CODE 0 (entry = slot - 2, segment word): $2a2 ID09 0x2a6 FSOpen, $4d2 ID02 0x2ee4,
 * $fa ID04 0x44e, $23a ID09 0x218 DisposPtr, $2b2 ID09 0x2fa FSRead, $4ba ID02 0x1d48, $232 ID09 0x20c
 * NewPtrClear, $4c2 ID02 0x212a, $2aa ID09 0x2de FSClose ($A001), $53a/$542/$582/$552/$54a/$532/$572/$55a/
 * $57a ID05 0x7f6/0x8b8/0x160/0xb84/0x934/0x8b2/0x560/0x85e/0x1bc, $2ba ID09 0x344 GetVol, $2fa ID09 0x432,
 * $51a ID02 0x2ee, $47a ID02 0x442e, $21a ID09 0x1bc MaxMem. Second FSOpen passes vRefNum 0; the open
 * failure is the only RETURN 0 (BRA.W to UNLK); header-read, NewPtrClear and relocation failures BRA.W to
 * 0x226 (CLR.L A5-0x1006) and still close, skip the protection block, check the volume and return 1.
 * Alignment: (4 - (p & 3)) & 3 added. Relocation: count = (A5-0x100e)/8 + (A5-0x100a)/8 (DIVS.L ext
 * 0x0800), flags long at rec+4: ASR #7 BTST #0 skip, ASR #4 BTST #0 error, (ASR #5) & 3 != 2 error, else
 * base added at base + off (i < nA, signed BGE) or base + A5-0x1022 + off. Volume test: 0x102-byte copy of
 * A5-0x1a24, GetVol, strcmp == 0 -> position_alert_template(0x105), StopAlert(0x105, nil) $A986,
 * ExitToShell. TickCount ($A975) is the third argument to 0x8b8 - identical to the C. */
/*
 * Original: FUN_00000006
 * Proposed name: load_overlay_from_resource
 * Confidence: [STRONG INFERENCE] role; [PROVEN] A5 trap sequence
 *
 * CODE resource 8 entry (ID08.bin @0x0006 after 6-byte stub @0x0–0x5).
 * Best-documented candidate for loading the Pacific Conflict overlay blob
 * (docs/architecture/LOADER_CHAIN.md §2). Heavy A5 jump-table use (not overlay-local calls):
 *   $2a2 — resource open/get (twice on failure-retry path)
 *   $4d2 / $fa — error string path → return 0
 *   $23a — dispose prior buffer at A5-0x1006
 *   $2b2 — read resource data into sized buffer
 *   $232 — NewPtr-style alloc (size from A5-0x101a/1e/22)
 *   $2aa — release resource
 *   $53a+ — reloc/fix helpers on loaded image
 *   $2ba / $2fa / $51a — post-load setup; success returns 1
 *
 * Capstone @0x0006–0x0336: LINK A6,#$FDD6 … UNLK/RTS; success MOVEQ #1,D0.
 * Ghidra's body was stack-confused (unaff_A5) with halt_baddata artifacts
 * near Mac traps $A986/$A9F4; replaced by the byte-level rebuild below.
 *
 * Callee: alloc_and_read_resource_payload (FUN_00000348). Globals: A5-0x13ac
 * type/name block; A5-0x1006 loaded-image pointer.
 *
 * Evidence: Capstone ID08.bin; docs/architecture/LOADER_CHAIN.md §2; ID08.c Ghidra.
 * Unknown: exact Toolbox trap names for each A5 slot; which resource ID is
 * the 255360-byte overlay.
 */
int load_overlay_from_resource(void) /* Original: FUN_00000006 */

{
  int unaff_A5;
  int hdr;                                      /* *(Handle)A5-0x13ac: file name at +0x2a, vRefNum at +0x28 */
  int i;                                        /* -4(A6) */
  int grow;                                     /* -8(A6) */
  short refNum;                                 /* -$a(A6) */
  short err;                                    /* -$c(A6) */
  int count;                                    /* -$10(A6) */
  int total;                                    /* -$14(A6) */
  int nA;                                       /* -$18(A6) */
  int nB;                                       /* -$1c(A6) */
  byte msg[256];                                /* -$120(A6) */
  int rec[2];                                   /* -$128(A6): offset, flags */
  int a;                                        /* -$12c(A6) */
  int b;                                        /* -$130(A6) */
  byte volName[0x102];                          /* -$228(A6) */
  short vRefNum;                                /* -$22a(A6) */

  grow = 0;
  hdr = **(int **)(unaff_A5 + -0x13ac);
  if ((fsopen_glue((Str255 *)(hdr + 0x2a),*(short *)(hdr + 0x28),&refNum) != 0) && /* JT $2a2 -> ID09 0x2a6 */
      (fsopen_glue((Str255 *)(**(int **)(unaff_A5 + -0x13ac) + 0x2a),0,&refNum) != 0)) {
    copy_pascal_string((byte *)(**(int **)(unaff_A5 + -0x13ac) + 0x2a),msg); /* JT $4d2 -> ID02 0x2ee4 */
    show_scenery_open_error_alert(msg);         /* JT $fa -> ID04 0x44e */
    return 0;
  }
  if (*(int *)(unaff_A5 + -0x1006) != 0) {
    DisposPtr(*(Ptr *)(unaff_A5 + -0x1006));    /* JT $23a -> ID09 0x218 */
  }
  count = 0x20;
  err = FSRead(refNum,&count,(Ptr)(unaff_A5 + -0x1026)); /* JT $2b2 -> ID09 0x2fa: 32-byte header */
  if (err != 0) {
    show_caution_alert_with_number(*(int *)(unaff_A5 + -0xdf6),err); /* JT $4ba -> ID02 0x1d48 */
    goto fail;
  }
  total = *(int *)(unaff_A5 + -0x1022) + *(int *)(unaff_A5 + -0x101e) + *(int *)(unaff_A5 + -0x101a);
  *(Ptr *)(unaff_A5 + -0x1006) = NewPtrClear(total + 4); /* JT $232 -> ID09 0x20c */
  if (*(int *)(unaff_A5 + -0x1006) == 0) {
    show_caution_alert_with_number(*(int *)(unaff_A5 + -0xdf2),0);
    goto fail;
  }
  *(int *)(unaff_A5 + -0x1006) =
       *(int *)(unaff_A5 + -0x1006) + ((4 - (*(uint *)(unaff_A5 + -0x1006) & 3)) & 3); /* long-align */
  count = *(int *)(unaff_A5 + -0x1022);
  FSRead(refNum,&count,*(Ptr *)(unaff_A5 + -0x1006)); /* code part; OSErr discarded */
  if (*(int *)(unaff_A5 + -0x101e) != 0) {
    count = *(int *)(unaff_A5 + -0x101e);
    FSRead(refNum,&count,(Ptr)(*(int *)(unaff_A5 + -0x1006) + *(int *)(unaff_A5 + -0x1022)));
  }
  nA = *(int *)(unaff_A5 + -0x100e) / 8;        /* DIVS.L #8 (extension 0x0800, quotient only) */
  nB = *(int *)(unaff_A5 + -0x100a) / 8;
  for (i = 0; i < nA + nB; i = i + 1) {
    count = 8;
    FSRead(refNum,&count,(Ptr)rec);             /* one 8-byte relocation record */
    if ((rec[1] >> 7 & 1U) != 0) {
      continue;                                 /* flag bit 7: skip */
    }
    if ((rec[1] >> 4 & 1U) != 0) {
      show_caution_alert_with_number(*(int *)(unaff_A5 + -0xdee),0);
      goto fail;
    }
    if ((rec[1] >> 5 & 3U) != 2) {
      show_caution_alert_with_number(*(int *)(unaff_A5 + -0xdea),0);
      goto fail;
    }
    if (i < nA) {
      *(int *)(*(int *)(unaff_A5 + -0x1006) + rec[0]) =
           *(int *)(*(int *)(unaff_A5 + -0x1006) + rec[0]) + *(int *)(unaff_A5 + -0x1006);
    }
    else {
      *(int *)(*(int *)(unaff_A5 + -0x1006) + *(int *)(unaff_A5 + -0x1022) + rec[0]) =
           *(int *)(*(int *)(unaff_A5 + -0x1006) + *(int *)(unaff_A5 + -0x1022) + rec[0]) +
           *(int *)(unaff_A5 + -0x1006);
    }
  }
  alloc_and_read_resource_payload(refNum);      /* BSR 0x348 */
  reset_overlay_state();                        /* JT $4c2 -> ID02 0x212a */
  goto close;
fail:
  *(int *)(unaff_A5 + -0x1006) = 0;
close:
  FSClose(refNum);                              /* JT $2aa -> ID09 0x2de ($A001); OSErr discarded */
  if (*(int *)(unaff_A5 + -0x1006) != 0) {
    poison_overlay_bytes(*(int *)(unaff_A5 + -0x1006),*(uint *)(unaff_A5 + -0x1022)); /* JT $53a -> ID05 0x7f6 */
    init_protection_table(unaff_A5 + -0x1cc4,0x38,TickCount()); /* $A975; JT $542 -> ID05 0x8b8 (no inventory entry) */
    read_DATA128_pair(&a,&b);                   /* JT $582 -> ID05 0x160 */
    if (record_code_index_equals(a,encode_code28_to_buf54(b)) != 0) { /* JT $54a -> 0x934, $552 -> 0xb84 */
      FUN_000008b2();                           /* JT $532 -> ID05 0x8b2: ADDQ.W #1,A5-0xbc (no inventory entry) */
    }
    run_protection_dialog(&a,&b);               /* JT $572 -> ID05 0x560 */
    restore_poisoned_overlay_bytes();           /* JT $55a -> ID05 0x85e */
    if (record_code_index_equals(a,encode_code28_to_buf54(b)) != 0) {
      write_DATA128_pair(a,b);                  /* JT $57a -> ID05 0x1bc */
    }
  }
  memcpy(volName,(void *)(unaff_A5 + -0x1a24),0x102); /* 63 longs + 1 word */
  GetVol(volName,&vRefNum);                     /* JT $2ba -> ID09 0x344 ($A014); OSErr discarded */
  if (ansi_strcmp(length_prefixed_bytes_to_c_string_in_place(volName),(char *)(unaff_A5 + -0x16e2)) == 0) {
                                                /* JT $2fa -> ID09 0x432, JT $51a -> ID02 0x2ee */
    position_alert_template(0x105);             /* JT $47a -> ID02 0x442e */
    StopAlert(0x105,0);                         /* $A986, result discarded */
    ExitToShell();                              /* $A9F4 */
  }
  MaxMem(&grow);                                /* JT $21a -> ID09 0x1bc; result discarded */
  return 1;                                     /* also after a header / alloc / relocation failure */
}



/*
 * Original: FUN_00000338
 * Proposed name: sysbeep_and_exit_to_shell
 * Confidence: [PROVEN]
 *
 * Capstone @0x0338–0x0346 (Ghidra emitted halt_baddata for the traps):
 *   LINK A6,#$FFF2
 *   MOVE.W #$64,-(A7); duration = 100 ticks
 *   DC.W $A9C8; _SysBeep
 *   DC.W $A9F4; _ExitToShell
 *   UNLK A6 / RTS; unreachable after ExitToShell
 *
 * Fatal-error exit helper. No in-segment BSR/JSR found in ID08.bin.
 *
 * Evidence: Capstone bytes; Inside Macintosh trap numbers A9C8/A9F4.
 */
/* VERIFIED (ID08::FUN_00000338): ID08.bin 0x338..0x346 checked against an independent capstone disassembly:
 * LINK, MOVE.W #$64,-(A7), _SysBeep ($A9C8), _ExitToShell ($A9F4), UNLK / RTS (unreachable) - identical
 * to the C (reconstructed from the bytes; Ghidra stopped at the A-line traps). */
void sysbeep_and_exit_to_shell(void) /* Original: FUN_00000338 */

{
  SysBeep(100);   /* MOVE.W #$64,-(A7); _SysBeep $A9C8 */
  ExitToShell();  /* _ExitToShell $A9F4; does not return */
  return;         /* UNLK A6 / RTS, unreachable */
}



/*
 * Original: FUN_00000348
 * Proposed name: alloc_and_read_resource_payload
 * Confidence: [PROVEN] sequence; [STRONG INFERENCE] trap roles
 *
 * Capstone @0x0348–0x039A (arg = resource ref word at $8(A6)):
 *   1. JSR A5+$2ca → store start offset at local
 *   2. JSR A5+$2c2 → store end offset at local
 *   3. size = end − start
 *   4. JSR A5+$22a(size) → alloc; pointer → A5-0x12fc
 *   5. JSR A5+$2b2(ptr, &size, ref) → read payload into buffer
 *
 * Called from load_overlay_from_resource after the main resource is open.
 * Ghidra lost A5 and mangled the stack args — binary order above is authoritative.
 *
 * Evidence: Capstone ID08.bin; sole caller in load_overlay_from_resource.
 */
/* VERIFIED (ID08::FUN_00000348): ID08.bin 0x348..0x39a checked against an independent capstone disassembly.
 * The jump-table slots resolve through CODE 0 (ID00.bin entry n = (off - 0x22) / 8, file = segment offset
 * + 4) to the MPW File / Memory Manager glue in ID09, identified by their traps: $2ca -> ID09 0x38c
 * _GetFPos ($A018), $2c2 -> 0x368 _GetEOF ($A011), $22a -> 0x200 _NewPtr ($A11E), $2b2 -> 0x2fa FSRead
 * (_Read $A002). The argument is a word (the only caller, ID08 0x216, pushes MOVE.W -$a(A6) and pops 2):
 * the open file's refNum. Reads from the current mark to the end of the file into a new block stored at
 * A5-0x12fc and returns FSRead's OSErr (MOVE.W (A7)+,D0); the GetFPos / GetEOF results are discarded -
 * identical to the C (reconstructed from the bytes; Ghidra mangled the stack arguments and the return). */
short alloc_and_read_resource_payload(short refNum) /* Original: FUN_00000348 */

{
  int unaff_A5;
  long start;
  long size;

  GetFPos(refNum,&start);                      /* JT $2ca -> ID09 0x38c _GetFPos; OSErr discarded */
  GetEOF(refNum,&size);                        /* JT $2c2 -> ID09 0x368 _GetEOF; OSErr discarded */
  size = size - start;                         /* SUB.L D0,-$4(A6) */
  *(Ptr *)(unaff_A5 + -0x12fc) = NewPtr(size); /* JT $22a -> ID09 0x200 _NewPtr */
  return FSRead(refNum,&size,*(Ptr *)(unaff_A5 + -0x12fc)); /* JT $2b2 -> ID09 0x2fa _Read */
}



/*
 * Original: FUN_0000039c
 * Proposed name: bootstrap_window_and_load_overlay
 * Confidence: [PROVEN] call to loader; [STRONG INFERENCE] window/port traps
 *
 * Capstone @0x039C–0x0446 (Ghidra halt_baddata — A-line traps):
 *   1. A-line $A97C (window create; args include #$F060 / $FFFF) → window ptr
 *   2. JSR A5+$48a(window)
 *   3. Cache window fields +$10/+ $12; save/restore port via $A870/$A873
 *   4. A-line $A982(window)
 *   5. Local fourcc 'HELL' ($48454C4C); JSR A5+$30a (signature/check)
 *   6. On success: A5+$4d2 string copy from A5-0x13ac+0x2a; write +0x28;
 *      set A5-0x138a = 1; JSR (d16,PC) → load_overlay_from_resource @0x0006
 *
 * Completes the ID08 bootstrap: UI/port setup then overlay load.
 *
 * Evidence: Capstone; JSR target 0x6 proven (disp $FBC4); 'HELL' immediate.
 * Toolbox names [PROVEN, Inside Macintosh trap list]: $A97C GetNewDialog, $A982 CloseDialog (it closes the
 * window but does not free the record; DisposDialog is $A983). Unknown: meaning of 'HELL' check.
 */
/* VERIFIED (ID08::FUN_0000039c): ID08.bin 0x39c..0x446 checked against an independent capstone disassembly:
 * GetNewDialog(-4000 = the standard Get File dialog, nil, (WindowPtr)-1) ($A97C) only to place it:
 * position_window_on_screen (JT $48a -> ID02 0x435e), then its portRect top-left (+0x10 / +0x12) is
 * converted to global coordinates with SetPort ($A873) / LocalToGlobal ($A870) / SetPort(saved thePort
 * A5-0x160c), and the dialog is closed ($A982 CloseDialog). SFGetFile(where, prompt A5-0x16d8, nil,
 * 1, {'HELL'}, nil, &reply) through JT $30a -> ID09 0x1a, the _Pack3 ($ADEA) selector-2 entry of the
 * package glue at 0x4 (selector = (return address - 0x18) / 2). On reply.good (-0x5a) the file name
 * (reply.fName -0x50) is copied by copy_pascal_string (JT $4d2 -> ID02 0x2ee4) to the record at
 * *(A5-0x13ac) + 0x2a, its +0x28 = reply.vRefNum (-0x54), A5-0x138a = 1, and
 * load_overlay_from_resource (JSR 0x6) runs - identical to the C (reconstructed from the bytes; Ghidra
 * stopped at the A-line traps). */
void bootstrap_window_and_load_overlay(void) /* Original: FUN_0000039c */

{
  int unaff_A5;
  DialogPtr dialog;                 /* -$5e */
  GrafPtr savedPort;                /* -$62 */
  Point where;                      /* -$66: v = top, h = left */
  OSType typeList[1];               /* -$10 */
  SFReply reply;                    /* -$5a: good, vRefNum -$54, fName -$50 */

  dialog = GetNewDialog(-4000,(Ptr)0,(WindowPtr)-1);       /* $A97C */
  position_window_on_screen((int)dialog);                  /* JT $48a -> ID02 0x435e */
  where.v = *(short *)((int)dialog + 0x10);                /* portRect.top */
  where.h = *(short *)((int)dialog + 0x12);                /* portRect.left */
  savedPort = *(GrafPtr *)(unaff_A5 + -0x160c);            /* thePort */
  SetPort((GrafPtr)dialog);                                /* $A873 */
  LocalToGlobal(&where);                                   /* $A870 */
  SetPort(savedPort);                                      /* $A873 */
  CloseDialog(dialog);                                     /* $A982 */
  typeList[0] = 0x48454c4c;                                /* 'HELL' */
  SFGetFile(where,(Str255 *)(unaff_A5 + -0x16d8),(ProcPtr)0,1,typeList,(ProcPtr)0,&reply); /* JT $30a -> ID09 0x1a, _Pack3 selector 2 */
  if (reply.good != 0) {
    copy_pascal_string((char *)reply.fName,(char *)(**(int **)(unaff_A5 + -0x13ac) + 0x2a)); /* JT $4d2 */
    *(short *)(**(int **)(unaff_A5 + -0x13ac) + 0x28) = reply.vRefNum;
    *(short *)(unaff_A5 + -0x138a) = 1;
    load_overlay_from_resource();                          /* JSR 0x6(PC) at 0x440 */
  }
  return;
}


