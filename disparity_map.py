import numpy as np
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

    def get_sparse_disparity(self, preprocess="GRAY"):
        self.preprocessing(preprocess)



