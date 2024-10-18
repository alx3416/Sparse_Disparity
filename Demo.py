import cv2
import disparity_map as dm

left_image = cv2.imread("stereoimages/TsukubaL.png", cv2.IMREAD_COLOR)
right_image = cv2.imread("stereoimages/TsukubaR.png", cv2.IMREAD_COLOR)

disparity_estimator = dm.DisparityMap(left_image, right_image, 16, 11)
left_disparity = disparity_estimator.get_sparse_disparity()

cv2.imwrite("disparity.png", left_disparity)

cv2.imshow("image left", left_image)
cv2.imshow("Disparity left", left_disparity/16)
cv2.waitKey(0)
cv2.destroyAllWindows()
