; RUN: llvm-as %s -o %t.o
; RUN: llvm-as %p/Inputs/comdat.ll -o %t2.o
; RUN: ld -shared -o %t3.o -plugin %llvmshlibdir/LLVMgold.so %t.o %t2.o \
; RUN:  -plugin-opt=emit-llvm
; RUN: llvm-dis %t3.o -o - | FileCheck %s

$c1 = comdat any

@v1 = weak_odr global i32 42, comdat $c1
define weak_odr i32 @f1() comdat $c1 {
bb10:
  br label %bb11
bb11:
  ret i32 42
}

@r11 = global i32* @v1
@r12 = global i32 ()* @f1

@a11 = alias i32* @v1
@a12 = alias bitcast (i32* @v1 to i16*)

@a13 = alias i32 ()* @f1
@a14 = alias bitcast (i32 ()* @f1 to i16*)
@a15 = alias i16* @a14

; CHECK: $c1 = comdat any
; CHECK: $c2 = comdat any

; CHECK: @v1 = weak_odr global i32 42, comdat $c1

; CHECK: @r11 = global i32* @v1{{$}}
; CHECK: @r12 = global i32 ()* @f1{{$}}

; CHECK: @r21 = global i32* @v1{{$}}
; CHECK: @r22 = global i32 ()* @f1{{$}}

; CHECK: @v11 = internal global i32 41, comdat $c2

; CHECK: @a11 = alias i32* @v1{{$}}
; CHECK: @a12 = alias bitcast (i32* @v1 to i16*)

; CHECK: @a13 = alias i32 ()* @f1{{$}}
; CHECK: @a14 = alias bitcast (i32 ()* @f1 to i16*)

; CHECK: @a21 = alias i32* @v11{{$}}
; CHECK: @a22 = alias bitcast (i32* @v11 to i16*)

; CHECK: @a23 = alias i32 ()* @f12{{$}}
; CHECK: @a24 = alias bitcast (i32 ()* @f12 to i16*)

; CHECK:      define weak_odr i32 @f1() comdat $c1 {
; CHECK-NEXT: bb10:
; CHECK-NEXT:   br label %bb11{{$}}
; CHECK:      bb11:
; CHECK-NEXT:   ret i32 42
; CHECK-NEXT: }

; CHECK:      define internal i32 @f12() comdat $c2 {
; CHECK-NEXT: bb20:
; CHECK-NEXT:   br label %bb21
; CHECK:      bb21:
; CHECK-NEXT:   ret i32 41
; CHECK-NEXT: }