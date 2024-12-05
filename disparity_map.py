import numpy as np
from scipy import signal
import cv2
import warnings


class DisparityMap:
    def __init__(self, left_image, right_image, disparity_range=16, block_size=11):
        self.similarity_criterion = "SAD"
        self.disparity_range = disparity_range
        self.kernel_array = np.ones((block_size, block_size))
        self.left_image = left_image
        self.right_image = right_image
        self.block_size = block_size
        image_size = np.shape(self.left_image)
        self.height = image_size[0]
        self.width = image_size[1]
        self.left_processed = []
        self.right_processed = []
        self.left_disparity = np.zeros((self.height, self.width))
        self.right_disparity = np.zeros((self.height, self.width))
        self.sparse_disparity_map = np.zeros((self.height, self.width))

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

    def get_left_disparity_map(self, disparity_level, cost_array_left):
        shifted_image = np.roll(self.right_processed, disparity_level, axis=1)
        cost_array_left[:, :, 1] = signal.convolve2d(np.abs(self.left_processed - shifted_image), self.kernel_array,
                                                     boundary='symm', mode='same')
        self.left_disparity[np.argmin(cost_array_left, axis=2) == 1] = disparity_level
        cost_array_left[:, :, 0] = np.min(cost_array_left, axis=2)

    def get_right_disparity_map(self, disparity_level, cost_array_right):
        shifted_image2 = np.roll(self.left_processed, -disparity_level, axis=1)
        cost_array_right[:, :, 1] = signal.convolve2d(np.abs(self.right_processed - shifted_image2), self.kernel_array,
                                                      boundary='symm', mode='same')
        self.right_disparity[np.argmin(cost_array_right, axis=2) == 1] = disparity_level
        cost_array_right[:, :, 0] = np.min(cost_array_right, axis=2)

    def estimate_left_and_right_disparity_map(self, cost_array_left, cost_array_right):
        self.sparse_disparity_map = np.zeros((self.height, self.width))
        for disparity_level in range(0, self.disparity_range):
            self.get_left_disparity_map(disparity_level, cost_array_left)
            self.get_right_disparity_map(disparity_level, cost_array_right)
            # match check consistency
            shifted_right_disparity = np.roll(self.right_disparity, disparity_level, axis=1)
            maskL = self.left_disparity == disparity_level
            maskR = shifted_right_disparity == disparity_level
            checked = np.bitwise_and(maskL, maskR)
            self.sparse_disparity_map[checked] = disparity_level
        self.sparse_disparity_map[self.sparse_disparity_map == 0] = np.nan

    def estimate_disparity(self):
        left_sad_image = np.zeros((self.height, self.width, 2))
        left_sad_image[:, :, :] = np.inf
        right_sad_image = np.zeros((self.height, self.width, 2))
        right_sad_image[:, :, :] = np.inf
        self.estimate_left_and_right_disparity_map(left_sad_image, right_sad_image)

    def estimate_sparse_disparity(self, preprocess="GRAY"):
        self.preprocessing(preprocess)
        self.estimate_disparity()

    def save_sparse_disparity_map(self):
        cv2.imwrite("disparity_map.pfm", self.sparse_disparity_map)
