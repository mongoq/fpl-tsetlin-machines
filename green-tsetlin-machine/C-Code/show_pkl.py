import pickle
import numpy as np
import matplotlib.pyplot as plt

with open('pixel_data.pkl', 'rb') as file:
    data = pickle.load(file)
try:
    img_array = np.array(data).reshape(28, 28)
    plt.imshow(img_array, cmap='gray')
    plt.axis('off')
    plt.show()
except Exception as e:
    print(f"Error whilst converting: {e}")
