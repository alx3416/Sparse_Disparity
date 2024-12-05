import cv2
from Python import disparity_map as dm

left_image = cv2.imread("stereoimages/TsukubaL.png", cv2.IMREAD_COLOR)
right_image = cv2.imread("stereoimages/TsukubaR.png", cv2.IMREAD_COLOR)

disparity_estimator = dm.DisparityMap(left_image, right_image, 16, 9)
disparity_estimator.estimate_sparse_disparity()

cv2.imwrite("out/disparityL.png", disparity_estimator.left_disparity)
cv2.imwrite("out/disparityR.png", disparity_estimator.right_disparity)
cv2.imwrite("out/Sparse_Disparity.pfm", disparity_estimator.sparse_disparity_map)

# cv2.imshow("image left", left_image)
# cv2.imshow("Disparity left", disparity_estimator.left_disparity)
# cv2.imshow("Disparity right", disparity_estimator.right_disparity)
# cv2.imshow("Sparse disparity", disparity_estimator.sparse_disparity_map)
# cv2.waitKey(0)
# cv2.destroyAllWindows()
