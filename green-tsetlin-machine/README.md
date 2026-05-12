# Green Tsetlin Machine

<!-- This project tries to simplify the assembly and evaluation process of a so-called Green Tsetlin Machine that can train and classify images of the MNIST dataset. --> 

This project aims to simplify the setup, training, and evaluation of a Green Tsetlin Machine for handwritten digit recognition on the MNIST dataset. Green Tsetlin provides a practical framework for training and inference and supports exporting trained models, making them easier to reuse in external applications or hardware-oriented workflows.

<!-- Green Tsetlin is a practical, production-oriented Tsetlin Machine framework that separates training and inference, provides a high-performance C++ backend with Python orchestration, and supports model export for efficient deployment and embedded applications. -->

With this project you have:

* A Google Colab (Pro) notebook (.ipynb file) that can be used to train and classify MNIST 28x28 pixel binary images.  

  To run the Google Colab (Pro) notebook: Upload the .ipynb file of this repo at Google Colab (Pro) and a pixel_data.pkl image file (a digit 0-9) you drew with Pixel Painter.

* A standalone C-program (.c file for use with gcc) that can be used to classify MNIST 28x28 pixel binary images.

  To run the inference with the C-backend: Download this repo and start the inference with "make predict" after you created a pixel_data.h file (a digit 0-9) with Pixel Painter.

* A Python script called Pixel Painter can be used to draw the digits 0-9 and export the resulting 28x28 pixel image either as a Python Pickle (.pkl) or C-header (.h) file.

TODO:
- [ ] Try hyperparameter sweep using [Optuna](https://optuna.org/)
- [ ] Figure out ESP32 microcontroller compatibility
- [ ] Try C-code with only parsing the .h image, not compiling it every time again
- [ ] Try to port this to Verilog (Verilator) with a pixel painter extension for Verilog array output  

Sources (Green Tsetlin Machine):  
* [Green Tsetlin Machine Paper (arXiv)](https://arxiv.org/abs/2405.04212)
* [Green Tsetlin Documentation](https://green-tsetlin.readthedocs.io/en/latest/)
* [Green Tsetlin GitHub Repository](https://github.com/ooki/green_tsetlin)

Sources (MNIST dataset):  
* [MNIST Dataset Overview](https://botpenguin.com/glossary/mnist-dataset) (403 Forbidden only when clicking URL from GitHub)
