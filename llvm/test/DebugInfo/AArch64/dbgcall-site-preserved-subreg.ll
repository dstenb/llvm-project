; RUN: llc -mtriple aarch64-linux-gnu -emit-call-site-info -filetype=obj -o - %s | llvm-dwarfdump - | FileCheck %s

; Based on the following C reproducer:
;
; void bar(int);
; long foo(long p) {
;   bar(p);
;   return p;
; }
;
; Verify that we are able to emit a call site value for the 32-bit W0 parameter
; using a subreg of the preserved register storing the 64-bit value of p.

; CHECK: DW_TAG_call_site_parameter
; CHECK-NEXT: DW_AT_location (DW_OP_reg0 W0)
; CHECK-NEXT: DW_AT_call_value (DW_OP_breg19 W19+0)


target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i8:8:32-i16:16:32-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "aarch64"

define i64 @foo(i64 noundef returned %p) !dbg !8 {
entry:
  %conv = trunc i64 %p to i32, !dbg !16
  tail call void @bar(i32 noundef %conv), !dbg !16
  ret i64 %p, !dbg !17
}

declare !dbg !18 void @bar(i32 noundef)

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!2, !3, !4, !5, !6}
!llvm.ident = !{!7}

!0 = distinct !DICompileUnit(language: DW_LANG_C11, file: !1, producer: "clang version 22.0.0git.prerel", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, splitDebugInlining: false, nameTableKind: None)
!1 = !DIFile(filename: "c1.i", directory: "/")
!2 = !{i32 7, !"Dwarf Version", i32 5}
!3 = !{i32 2, !"Debug Info Version", i32 3}
!4 = !{i32 1, !"wchar_size", i32 4}
!5 = !{i32 7, !"frame-pointer", i32 4}
!6 = !{i32 7, !"debug-info-assignment-tracking", i1 true}
!7 = !{!"clang version 22.0.0git.prerel"}
!8 = distinct !DISubprogram(name: "foo", scope: !9, file: !9, line: 2, type: !10, scopeLine: 2, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !13, keyInstructions: true)
!9 = !DIFile(filename: "c1.i", directory: "/", checksumkind: CSK_MD5, checksum: "d6df8546b35604f19079ca89d49a7275")
!10 = !DISubroutineType(types: !11)
!11 = !{!12, !12}
!12 = !DIBasicType(name: "long", size: 64, encoding: DW_ATE_signed)
!13 = !{!14}
!14 = !DILocalVariable(name: "p", arg: 1, scope: !8, file: !9, line: 2, type: !12)
!15 = !DILocation(line: 0, scope: !8)
!16 = !DILocation(line: 3, scope: !8)
!17 = !DILocation(line: 4, scope: !8, atomGroup: 1, atomRank: 1)
!18 = !DISubprogram(name: "bar", scope: !9, file: !9, line: 1, type: !19, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!19 = !DISubroutineType(types: !20)
!20 = !{null, !21}
!21 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
