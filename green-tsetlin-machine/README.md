# Green Tsetlin Machine
Getting Sondre Glimsdal's Green Tsetlin Machine Framework to work "in under 10 minutes".

This project tries to simplify the assembly and evaluation process of a Green Tsetlin Machine that can train and classify images of the MNIST dataset. 

Sources (Green Tsetlin Machine):  
https://arxiv.org/abs/2405.04212  
https://green-tsetlin.readthedocs.io/en/latest/  
https://github.com/ooki/green_tsetlin

Sources (MNIST dataset):  
https://botpenguin.com/glossary/mnist-dataset

With this project you have:

* A Google Colab (Pro) notebook (.ipynb file) that can be used to train and classify MNIST 28x28 pixel binary images.  

  To run the Google Colab (Pro) notebook: Upload the .ipynb file of this repo at Google Colab (Pro) and a pixel_data.pkl image file (a digit 0-9) you drew with Pixel Painter.

* A standalone C-program (.c file for use with gcc) that can be used to classify MNIST 28x28 pixel binary images.

  To run the inference with the C-backend: Download this repo and start the inference with "make predict" after you created a pixel_data.h file (a digit 0-9) with Pixel Painter.

* A Python script called Pixel Painter can be used to draw the digits 0-9 and export the resulting 28x28 pixel image either as a Python Pickle (.pkl) or C-header (.h) file.

TODO:
- [ ] Try hyperparameter sweep
- [ ] Figure out ESP32 microcontroller compatibility
- [ ] Try C-code with only parsing the .h image, not compiling it every time again
- [ ] Try to port this to FPGA Verilog (Verilator) with a pixel painter extension for Verilog array output  
