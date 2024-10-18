import numpy as np
from scipy import signal
import cv2
import warnings


class DisparityMap:
    def __init__(self, left_image, right_image, disparity_range=16, block_size=11):
        self.similarity_criterion = "SAD"
        self.disparity_range = disparity_range
        self.left_image = left_image
        self.right_image = right_image
        self.block_size = block_size
        self.left_processed = []
        self.right_processed = []

    def preprocessing(self, processing_type="GRAY"):
        if processing_type == "GRAY":
            self.left_processed = cv2.cvtColor(self.left_image, cv2.COLOR_BGR2GRAY)
            self.right_processed = cv2.cvtColor(self.left_image, cv2.COLOR_BGR2GRAY)
        else:
            warnings.warn("Invalid preprocessing type, using BGR images instead")
            self.left_processed = self.left_image
            self.right_processed = self.right_image

    def estimate_disparity(self):
        image_size = np.shape(self.left_processed)
        kernel_array = np.ones((self.block_size, self.block_size))
        left_sad_image = np.zeros((image_size[0], image_size[1], 2))
        left_sad_image[:, :, :] = np.inf
        left_disparity = np.zeros((image_size[0], image_size[1]))
        for disparity_level in range(1, self.disparity_range):  # niveles de disparidad
            shifted_image = np.roll(self.right_processed, disparity_level, axis=1)
            shifted_image = np.abs(self.left_processed - shifted_image)
            left_sad_image[:, :, 0] = signal.convolve2d(shifted_image, kernel_array, boundary='symm', mode='same')
            left_disparity[:, :, 1] = np.min(left_sad_image, axis=0)
            ddppL[sadLEFT < sadLEFT_prev] = k
            sadLEFT_prev[sadLEFT < sadLEFT_prev] = sadLEFT[sadLEFT < sadLEFT_prev]

    def get_sparse_disparity(self, preprocess="GRAY"):
        self.preprocessing(preprocess)
