; RUN: llc -march=r600 -mcpu=bonaire -verify-machineinstrs -mattr=+load-store-opt -enable-misched < %s | FileCheck -check-prefix=SI %s

@lds = addrspace(3) global [512 x float] zeroinitializer, align 4
@lds.f64 = addrspace(3) global [512 x double] zeroinitializer, align 8


; SI-LABEL: @simple_read2st64_f32_0_1
; SI: DS_READ2ST64_B32 v{{\[}}[[LO_VREG:[0-9]+]]:[[HI_VREG:[0-9]+]]{{\]}}, v{{[0-9]+}}, 0x0, 0x1
; SI: S_WAITCNT lgkmcnt(0)
; SI: V_ADD_F32_e32 [[RESULT:v[0-9]+]], v[[HI_VREG]], v[[LO_VREG]]
; SI: BUFFER_STORE_DWORD [[RESULT]]
; SI: S_ENDPGM
define void @simple_read2st64_f32_0_1(float addrspace(1)* %out) #0 {
  %x.i = tail call i32 @llvm.r600.read.tidig.x() #1
  %arrayidx0 = getelementptr inbounds [512 x float] addrspace(3)* @lds, i32 0, i32 %x.i
  %val0 = load float addrspace(3)* %arrayidx0, align 4
  %add.x = add nsw i32 %x.i, 64
  %arrayidx1 = getelementptr inbounds [512 x float] addrspace(3)* @lds, i32 0, i32 %add.x
  %val1 = load float addrspace(3)* %arrayidx1, align 4
  %sum = fadd float %val0, %val1
  %out.gep = getelementptr inbounds float addrspace(1)* %out, i32 %x.i
  store float %sum, float addrspace(1)* %out.gep, align 4
  ret void
}

; SI-LABEL: @simple_read2st64_f32_1_2
; SI: DS_READ2ST64_B32 v{{\[}}[[LO_VREG:[0-9]+]]:[[HI_VREG:[0-9]+]]{{\]}}, v{{[0-9]+}}, 0x1, 0x2
; SI: S_WAITCNT lgkmcnt(0)
; SI: V_ADD_F32_e32 [[RESULT:v[0-9]+]], v[[HI_VREG]], v[[LO_VREG]]
; SI: BUFFER_STORE_DWORD [[RESULT]]
; SI: S_ENDPGM
define void @simple_read2st64_f32_1_2(float addrspace(1)* %out, float addrspace(3)* %lds) #0 {
  %x.i = tail call i32 @llvm.r600.read.tidig.x() #1
  %add.x.0 = add nsw i32 %x.i, 64
  %arrayidx0 = getelementptr inbounds float addrspace(3)* %lds, i32 %add.x.0
  %val0 = load float addrspace(3)* %arrayidx0, align 4
  %add.x.1 = add nsw i32 %x.i, 128
  %arrayidx1 = getelementptr inbounds float addrspace(3)* %lds, i32 %add.x.1
  %val1 = load float addrspace(3)* %arrayidx1, align 4
  %sum = fadd float %val0, %val1
  %out.gep = getelementptr inbounds float addrspace(1)* %out, i32 %x.i
  store float %sum, float addrspace(1)* %out.gep, align 4
  ret void
}

; SI-LABEL: @simple_read2st64_f32_max_offset
; SI: DS_READ2ST64_B32 v{{\[}}[[LO_VREG:[0-9]+]]:[[HI_VREG:[0-9]+]]{{\]}}, v{{[0-9]+}}, 0x1, 0xff
; SI: S_WAITCNT lgkmcnt(0)
; SI: V_ADD_F32_e32 [[RESULT:v[0-9]+]], v[[HI_VREG]], v[[LO_VREG]]
; SI: BUFFER_STORE_DWORD [[RESULT]]
; SI: S_ENDPGM
define void @simple_read2st64_f32_max_offset(float addrspace(1)* %out, float addrspace(3)* %lds) #0 {
  %x.i = tail call i32 @llvm.r600.read.tidig.x() #1
  %add.x.0 = add nsw i32 %x.i, 64
  %arrayidx0 = getelementptr inbounds float addrspace(3)* %lds, i32 %add.x.0
  %val0 = load float addrspace(3)* %arrayidx0, align 4
  %add.x.1 = add nsw i32 %x.i, 16320
  %arrayidx1 = getelementptr inbounds float addrspace(3)* %lds, i32 %add.x.1
  %val1 = load float addrspace(3)* %arrayidx1, align 4
  %sum = fadd float %val0, %val1
  %out.gep = getelementptr inbounds float addrspace(1)* %out, i32 %x.i
  store float %sum, float addrspace(1)* %out.gep, align 4
  ret void
}

; SI-LABEL: @simple_read2st64_f32_over_max_offset
; SI-NOT: DS_READ2ST64_B32
; SI: DS_READ_B32 {{v[0-9]+}}, {{v[0-9]+}}, 0x100,
; SI: V_ADD_I32_e32 [[BIGADD:v[0-9]+]], 0x10000, {{v[0-9]+}}
; SI: DS_READ_B32 {{v[0-9]+}}, [[BIGADD]], 0x0
; SI: S_ENDPGM
define void @simple_read2st64_f32_over_max_offset(float addrspace(1)* %out, float addrspace(3)* %lds) #0 {
  %x.i = tail call i32 @llvm.r600.read.tidig.x() #1
  %add.x.0 = add nsw i32 %x.i, 64
  %arrayidx0 = getelementptr inbounds float addrspace(3)* %lds, i32 %add.x.0
  %val0 = load float addrspace(3)* %arrayidx0, align 4
  %add.x.1 = add nsw i32 %x.i, 16384
  %arrayidx1 = getelementptr inbounds float addrspace(3)* %lds, i32 %add.x.1
  %val1 = load float addrspace(3)* %arrayidx1, align 4
  %sum = fadd float %val0, %val1
  %out.gep = getelementptr inbounds float addrspace(1)* %out, i32 %x.i
  store float %sum, float addrspace(1)* %out.gep, align 4
  ret void
}

; SI-LABEL: @odd_invalid_read2st64_f32_0
; SI-NOT: DS_READ2ST64_B32
; SI: S_ENDPGM
define void @odd_invalid_read2st64_f32_0(float addrspace(1)* %out) #0 {
  %x.i = tail call i32 @llvm.r600.read.tidig.x() #1
  %arrayidx0 = getelementptr inbounds [512 x float] addrspace(3)* @lds, i32 0, i32 %x.i
  %val0 = load float addrspace(3)* %arrayidx0, align 4
  %add.x = add nsw i32 %x.i, 63
  %arrayidx1 = getelementptr inbounds [512 x float] addrspace(3)* @lds, i32 0, i32 %add.x
  %val1 = load float addrspace(3)* %arrayidx1, align 4
  %sum = fadd float %val0, %val1
  %out.gep = getelementptr inbounds float addrspace(1)* %out, i32 %x.i
  store float %sum, float addrspace(1)* %out.gep, align 4
  ret void
}

; SI-LABEL: @odd_invalid_read2st64_f32_1
; SI-NOT: DS_READ2ST64_B32
; SI: S_ENDPGM
define void @odd_invalid_read2st64_f32_1(float addrspace(1)* %out) #0 {
  %x.i = tail call i32 @llvm.r600.read.tidig.x() #1
  %add.x.0 = add nsw i32 %x.i, 64
  %arrayidx0 = getelementptr inbounds [512 x float] addrspace(3)* @lds, i32 0, i32 %add.x.0
  %val0 = load float addrspace(3)* %arrayidx0, align 4
  %add.x.1 = add nsw i32 %x.i, 127
  %arrayidx1 = getelementptr inbounds [512 x float] addrspace(3)* @lds, i32 0, i32 %add.x.1
  %val1 = load float addrspace(3)* %arrayidx1, align 4
  %sum = fadd float %val0, %val1
  %out.gep = getelementptr inbounds float addrspace(1)* %out, i32 %x.i
  store float %sum, float addrspace(1)* %out.gep, align 4
  ret void
}

; SI-LABEL: @simple_read2st64_f64_0_1
; SI: DS_READ2ST64_B64 v{{\[}}[[LO_VREG:[0-9]+]]:[[HI_VREG:[0-9]+]]{{\]}}, v{{[0-9]+}}, 0x0, 0x1
; SI: S_WAITCNT lgkmcnt(0)
; SI: V_ADD_F64 [[RESULT:v\[[0-9]+:[0-9]+\]]], v{{\[}}[[LO_VREG]]:{{[0-9]+\]}}, v{{\[[0-9]+}}:[[HI_VREG]]{{\]}}
; SI: BUFFER_STORE_DWORDX2 [[RESULT]]
; SI: S_ENDPGM
define void @simple_read2st64_f64_0_1(double addrspace(1)* %out) #0 {
  %x.i = tail call i32 @llvm.r600.read.tidig.x() #1
  %arrayidx0 = getelementptr inbounds [512 x double] addrspace(3)* @lds.f64, i32 0, i32 %x.i
  %val0 = load double addrspace(3)* %arrayidx0, align 8
  %add.x = add nsw i32 %x.i, 64
  %arrayidx1 = getelementptr inbounds [512 x double] addrspace(3)* @lds.f64, i32 0, i32 %add.x
  %val1 = load double addrspace(3)* %arrayidx1, align 8
  %sum = fadd double %val0, %val1
  %out.gep = getelementptr inbounds double addrspace(1)* %out, i32 %x.i
  store double %sum, double addrspace(1)* %out.gep, align 8
  ret void
}

; SI-LABEL: @simple_read2st64_f64_1_2
; SI: DS_READ2ST64_B64 v{{\[}}[[LO_VREG:[0-9]+]]:[[HI_VREG:[0-9]+]]{{\]}}, v{{[0-9]+}}, 0x1, 0x2
; SI: S_WAITCNT lgkmcnt(0)
; SI: V_ADD_F64 [[RESULT:v\[[0-9]+:[0-9]+\]]], v{{\[}}[[LO_VREG]]:{{[0-9]+\]}}, v{{\[[0-9]+}}:[[HI_VREG]]{{\]}}
; SI: BUFFER_STORE_DWORDX2 [[RESULT]]
; SI: S_ENDPGM
define void @simple_read2st64_f64_1_2(double addrspace(1)* %out, double addrspace(3)* %lds) #0 {
  %x.i = tail call i32 @llvm.r600.read.tidig.x() #1
  %add.x.0 = add nsw i32 %x.i, 64
  %arrayidx0 = getelementptr inbounds double addrspace(3)* %lds, i32 %add.x.0
  %val0 = load double addrspace(3)* %arrayidx0, align 8
  %add.x.1 = add nsw i32 %x.i, 128
  %arrayidx1 = getelementptr inbounds double addrspace(3)* %lds, i32 %add.x.1
  %val1 = load double addrspace(3)* %arrayidx1, align 8
  %sum = fadd double %val0, %val1
  %out.gep = getelementptr inbounds double addrspace(1)* %out, i32 %x.i
  store double %sum, double addrspace(1)* %out.gep, align 8
  ret void
}

; Alignment only

; SI-LABEL: @misaligned_read2st64_f64
; SI: DS_READ2_B32 v{{\[[0-9]+:[0-9]+\]}}, {{v[0-9]+}}, 0x0, 0x1
; SI: DS_READ2_B32 v{{\[[0-9]+:[0-9]+\]}}, {{v[0-9]+}}, 0x80, 0x81
; SI: S_ENDPGM
define void @misaligned_read2st64_f64(double addrspace(1)* %out, double addrspace(3)* %lds) #0 {
  %x.i = tail call i32 @llvm.r600.read.tidig.x() #1
  %arrayidx0 = getelementptr inbounds double addrspace(3)* %lds, i32 %x.i
  %val0 = load double addrspace(3)* %arrayidx0, align 4
  %add.x = add nsw i32 %x.i, 64
  %arrayidx1 = getelementptr inbounds double addrspace(3)* %lds, i32 %add.x
  %val1 = load double addrspace(3)* %arrayidx1, align 4
  %sum = fadd double %val0, %val1
  %out.gep = getelementptr inbounds double addrspace(1)* %out, i32 %x.i
  store double %sum, double addrspace(1)* %out.gep, align 4
  ret void
}

; The maximum is not the usual 0xff because 0xff * 8 * 64 > 0xffff
; SI-LABEL: @simple_read2st64_f64_max_offset
; SI: DS_READ2ST64_B64 v{{\[}}[[LO_VREG:[0-9]+]]:[[HI_VREG:[0-9]+]]{{\]}}, v{{[0-9]+}}, 0x4, 0x7f
; SI: S_WAITCNT lgkmcnt(0)
; SI: V_ADD_F64 [[RESULT:v\[[0-9]+:[0-9]+\]]], v{{\[}}[[LO_VREG]]:{{[0-9]+\]}}, v{{\[[0-9]+}}:[[HI_VREG]]{{\]}}
; SI: BUFFER_STORE_DWORDX2 [[RESULT]]
; SI: S_ENDPGM
define void @simple_read2st64_f64_max_offset(double addrspace(1)* %out, double addrspace(3)* %lds) #0 {
  %x.i = tail call i32 @llvm.r600.read.tidig.x() #1
  %add.x.0 = add nsw i32 %x.i, 256
  %arrayidx0 = getelementptr inbounds double addrspace(3)* %lds, i32 %add.x.0
  %val0 = load double addrspace(3)* %arrayidx0, align 8
  %add.x.1 = add nsw i32 %x.i, 8128
  %arrayidx1 = getelementptr inbounds double addrspace(3)* %lds, i32 %add.x.1
  %val1 = load double addrspace(3)* %arrayidx1, align 8
  %sum = fadd double %val0, %val1
  %out.gep = getelementptr inbounds double addrspace(1)* %out, i32 %x.i
  store double %sum, double addrspace(1)* %out.gep, align 8
  ret void
}

; SI-LABEL: @simple_read2st64_f64_over_max_offset
; SI-NOT: DS_READ2ST64_B64
; SI: DS_READ_B64 {{v\[[0-9]+:[0-9]+\]}}, {{v[0-9]+}}, 0x200,
; SI: V_ADD_I32_e32 [[BIGADD:v[0-9]+]], 0x10000, {{v[0-9]+}}
; SI: DS_READ_B64 {{v\[[0-9]+:[0-9]+\]}}, [[BIGADD]], 0x0
; SI: S_ENDPGM
define void @simple_read2st64_f64_over_max_offset(double addrspace(1)* %out, double addrspace(3)* %lds) #0 {
  %x.i = tail call i32 @llvm.r600.read.tidig.x() #1
  %add.x.0 = add nsw i32 %x.i, 64
  %arrayidx0 = getelementptr inbounds double addrspace(3)* %lds, i32 %add.x.0
  %val0 = load double addrspace(3)* %arrayidx0, align 8
  %add.x.1 = add nsw i32 %x.i, 8192
  %arrayidx1 = getelementptr inbounds double addrspace(3)* %lds, i32 %add.x.1
  %val1 = load double addrspace(3)* %arrayidx1, align 8
  %sum = fadd double %val0, %val1
  %out.gep = getelementptr inbounds double addrspace(1)* %out, i32 %x.i
  store double %sum, double addrspace(1)* %out.gep, align 8
  ret void
}

; SI-LABEL: @invalid_read2st64_f64_odd_offset
; SI-NOT: DS_READ2ST64_B64
; SI: S_ENDPGM
define void @invalid_read2st64_f64_odd_offset(double addrspace(1)* %out, double addrspace(3)* %lds) #0 {
  %x.i = tail call i32 @llvm.r600.read.tidig.x() #1
  %add.x.0 = add nsw i32 %x.i, 64
  %arrayidx0 = getelementptr inbounds double addrspace(3)* %lds, i32 %add.x.0
  %val0 = load double addrspace(3)* %arrayidx0, align 8
  %add.x.1 = add nsw i32 %x.i, 8129
  %arrayidx1 = getelementptr inbounds double addrspace(3)* %lds, i32 %add.x.1
  %val1 = load double addrspace(3)* %arrayidx1, align 8
  %sum = fadd double %val0, %val1
  %out.gep = getelementptr inbounds double addrspace(1)* %out, i32 %x.i
  store double %sum, double addrspace(1)* %out.gep, align 8
  ret void
}

; The stride of 8 elements is 8 * 8 bytes. We need to make sure the
; stride in elements, not bytes, is a multiple of 64.

; SI-LABEL: @byte_size_only_divisible_64_read2_f64
; SI-NOT: DS_READ2ST_B64
; SI: DS_READ2_B64 v{{\[[0-9]+:[0-9]+\]}}, v{{[0-9]+}}, 0x0, 0x8
; SI: S_ENDPGM
define void @byte_size_only_divisible_64_read2_f64(double addrspace(1)* %out, double addrspace(3)* %lds) #0 {
  %x.i = tail call i32 @llvm.r600.read.tidig.x() #1
  %arrayidx0 = getelementptr inbounds double addrspace(3)* %lds, i32 %x.i
  %val0 = load double addrspace(3)* %arrayidx0, align 8
  %add.x = add nsw i32 %x.i, 8
  %arrayidx1 = getelementptr inbounds double addrspace(3)* %lds, i32 %add.x
  %val1 = load double addrspace(3)* %arrayidx1, align 8
  %sum = fadd double %val0, %val1
  %out.gep = getelementptr inbounds double addrspace(1)* %out, i32 %x.i
  store double %sum, double addrspace(1)* %out.gep, align 4
  ret void
}

; Function Attrs: nounwind readnone
declare i32 @llvm.r600.read.tgid.x() #1

; Function Attrs: nounwind readnone
declare i32 @llvm.r600.read.tgid.y() #1

; Function Attrs: nounwind readnone
declare i32 @llvm.r600.read.tidig.x() #1

; Function Attrs: nounwind readnone
declare i32 @llvm.r600.read.tidig.y() #1

; Function Attrs: noduplicate nounwind
declare void @llvm.AMDGPU.barrier.local() #2

attributes #0 = { nounwind "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-realign-stack" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind readnone }
attributes #2 = { noduplicate nounwind }