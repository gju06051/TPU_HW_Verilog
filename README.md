# CNN_HW_PROJ

## Abstract
해당 프로젝트의 목표는 Google TPU(Tensor Proecssing Unit)와 유사한 구조의 머신러닝을 위한 co-processor 설계에 있다.
SW stack에서 target DNN모델을 training시킨 후 HDL로 구현한 HW 모듈 위에서 inferencing과정을 진행, performance 요소들을 평가한다.
Inferencing 과정을 위해서 독립적인 Convolution, Fully Connected, Max Pooling layer들을 구현하였다. 
Convolution layer연산은 im2col, ifmap stationary방식을 채택하였고, ifmap과 Weight에 quatization이 적용된다.  


## AXI BUS
- Convolution layer의 Matrix multiplication을 위해선 이전 layer의 output인 tensor를 im2col변환 이후에 matrix형태로 전달될 필요가 있다. 
- SW stack에서 im2col변환을 수행하기 위해서 BRAM 과 Zynq프로세서 사이의 통신에 AMBA protocol의 일종인 AXI bus를 이용하였다.


## Design Spec
- FPGA Board : Zybo Z7 20

- DNN Model : MNIST Classifier
![model_spec](./IMG/CNN_SPEC.PNG)

- Quantization : data type -> unsigned int8

- MAC Operation : Using FPGA DSP, 10 < latency < 20(ns) (1clock = 10ns)

- SRAM (FPGA BRAM)
  - Port        : True_dual_port_ram
  - Latency     : R/W = 1clk
  - Size        : 640kB
  - Bandwidth   : 512 bit per cycle


## ETC
- Conv연산을 위한 MMU와 FC연산을 위한 연산 core의 scale은 해당 project의 target DNN model에 적합한 크기로 구현하였다. 
- verilog코드 내부의 parameter 값들을 변경하여 module의 크기를 변경하여 latency와 resource를 조절할 수 있다


## Architecture

### 1) Convolution layer

#### 1-1) Conv Data Mover
   - BRAM에서 conv연산을 위한 ifmap과 weight를 주소값을 통해 호출하고, ifmap은 SA(Systolic Array)로 preload시키고, weight는 GLB로 전달한다. 

#### 1-2) Global Buffer(GLB)
   - Conv Data Mover로부터 받아온 weight값들을 ifmap stationary연산을 위한 형태로 SA에 전달하기 위해서 buffering시킨다. 

#### 1-3) Systoilc Array(SA)
   - 다수의 PE(Processing Element)가 서로 연결되어 ifmap, weight, partial sum을 전달한다. 
   - Weight, Partial sum 값들은 PE에서 다른 PE로 forwarding될 때 valid신호도 동시에 전달된다. 
   - PE연산과 primitive들의 data&valid(en) 신호들의 forwarding을 통해서 정방행렬 matrix 2개의 multiplication이 수행된다. 

#### 1-4) Accumulator
   - FIFO와 adder의 조합으로 SA에서 전달받은 psum값을 psum_valid신호를 이용해서 fifo에 write한다.
   - FIFO의 rdata를 feedback으로 사용, add 이후에 다시 FIFO에 write하는 방식으로 accumulation을 수행한다.  

#### 1-5) SA Data Mover
    - Accumulator로부터 전달받은 ofmap 값들을 buffer에 저장하고 BRAM에 write하는 동작을 수행한다.

### 2) FC layer
Fully Connected layer는 MAC연산을 위한 연산 Core들과 FC연산에 사용되는 ifmap, weight값들을 BRAM의 주소로부터 read해오고, 결과값인 ofmap을 다시 BRAM에 write하는 Data Mover로 구성되었다.
(추가 작성필요) 

### 3) Pooling layer
Max Pooling과 같은 경우에도 pooling연산을 위한 Core와 Data Mover로 구성되었다. 
(추가 작성필요)




Target model : MNIST Classifier
