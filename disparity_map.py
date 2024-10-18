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
            self.right_processed = cv2.cvtColor(self.right_image, cv2.COLOR_BGR2GRAY)
        else:
            warnings.warn("Invalid preprocessing type, using BGR images instead")
            self.left_processed = self.left_image
            self.right_processed = self.right_image
        self.left_processed = self.left_processed.astype("float32") / 255.0
        self.right_processed = self.right_processed.astype("float32") / 255.0

    def estimate_disparity(self):
        image_size = np.shape(self.left_processed)
        kernel_array = np.ones((self.block_size, self.block_size))
        left_sad_image = np.zeros((image_size[0], image_size[1], 2))
        left_sad_image[:, :, :] = np.inf
        left_disparity = np.zeros((image_size[0], image_size[1]))
        for disparity_level in range(0, self.disparity_range):  # niveles de disparidad
            shifted_image = np.roll(self.right_processed, disparity_level, axis=1)
            left_sad_image[:, :, 1] = signal.convolve2d(np.abs(self.left_processed - shifted_image), kernel_array, boundary='symm', mode='same')
            left_disparity[np.argmin(left_sad_image, axis=2) == 1] = disparity_level
            left_sad_image[:, :, 0] = np.min(left_sad_image, axis=2)
        return left_disparity

    def get_sparse_disparity(self, preprocess="GRAY"):
        self.preprocessing(preprocess)
        return self.estimate_disparity()
