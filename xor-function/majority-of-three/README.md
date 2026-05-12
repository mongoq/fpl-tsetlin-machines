# # Majority of Three (2-out-of-3 = 1)

```  
==============================================
Tsetlin Machine Majority Of Three Test
Features=3 Clauses=20 States=100
==============================================
VCD info: dumpfile tm.vcd opened for output.

[Before Training]
Accuracy: 4/8

[Training]
Epoch  200: 8/8 (100%)
*** 100% reached! ***
Epoch  400: 8/8 (100%)
*** 100% reached! ***
Epoch  600: 8/8 (100%)
*** 100% reached! ***
Epoch  800: 8/8 (100%)
*** 100% reached! ***
Epoch 1000: 8/8 (100%)
*** 100% reached! ***
Epoch 1200: 8/8 (100%)
*** 100% reached! ***
Epoch 1400: 8/8 (100%)
*** 100% reached! ***
Epoch 1600: 8/8 (100%)
*** 100% reached! ***
Epoch 1800: 8/8 (100%)
*** 100% reached! ***
Epoch 2000: 8/8 (100%)
*** 100% reached! ***

[Final Results]
  0 3maj 0 3maj 0 = 0 (expected 0)   OK
  0 3maj 0 3maj 1 = 0 (expected 0)   OK
  0 3maj 1 3maj 0 = 0 (expected 0)   OK
  0 3maj 1 3maj 1 = 1 (expected 1)   OK
  1 3maj 0 3maj 0 = 0 (expected 0)   OK
  1 3maj 0 3maj 1 = 1 (expected 1)   OK
  1 3maj 1 3maj 0 = 1 (expected 1)   OK
  1 3maj 1 3maj 1 = 1 (expected 1)   OK

Final Accuracy: 8/8 (100%)

==============================================

```  
