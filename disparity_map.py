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

    def get_left_disparity_map(self, disparity_level, cost_array_left, kernel_array, disparity_map):
        shifted_image = np.roll(self.right_processed, disparity_level, axis=1)
        cost_array_left[:, :, 1] = signal.convolve2d(np.abs(self.left_processed - shifted_image), kernel_array,
                                                     boundary='symm', mode='same')
        disparity_map[np.argmin(cost_array_left, axis=2) == 1] = disparity_level
        cost_array_left[:, :, 0] = np.min(cost_array_left, axis=2)
        return disparity_map

    def get_left_and_right_disparity_map(self, kernel_array, cost_array_left, cost_array_right, image_size):
        left_disparity = np.zeros((image_size[0], image_size[1]))
        right_disparity = np.zeros((image_size[0], image_size[1]))
        for disparity_level in range(0, self.disparity_range):  # niveles de disparidad
            left_disparity = self.get_left_disparity_map(disparity_level, cost_array_left, kernel_array, left_disparity)
        return left_disparity

    def estimate_disparity(self):
        image_size = np.shape(self.left_processed)
        kernel_array = np.ones((self.block_size, self.block_size))
        left_sad_image = np.zeros((image_size[0], image_size[1], 2))
        left_sad_image[:, :, :] = np.inf
        left_disparity = np.zeros((image_size[0], image_size[1]))
        left_disparity = self.get_left_and_right_disparity_map(kernel_array, left_sad_image, left_sad_image, image_size)
        return left_disparity

    def get_sparse_disparity(self, preprocess="GRAY"):
        self.preprocessing(preprocess)
        return self.estimate_disparity()
