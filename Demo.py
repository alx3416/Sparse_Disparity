import cv2

left_image = cv2.imread("stereoimages/TsukubaL.png", cv2.IMREAD_COLOR)
right_image = cv2.imread("stereoimages/TsukubaR.png", cv2.IMREAD_COLOR)

cv2.imshow("image left", left_image)
cv2.imshow("image right", right_image)
cv2.waitKey(0)
cv2.destroyAllWindows()
