import numpy as np
import cv2


# Set your camera
capL = cv2.VideoCapture(2)
capR = cv2.VideoCapture(0)

# Set these for high resolution
#capL.set(3, 1920)  # width
#capL.set(4, 1080)  # height
#capR.set(3, 320)  # width
#capR.set(4, 240)  # height



i=0
while True:
    # Capture frame-by-frame
    ret, frameL = capL.read()
    ret, frameR = capR.read()

    # Display the resulting frame
    cv2.imshow('frameL', frameL)
    cv2.imshow('frameR', frameR)
    key = cv2.waitKey(1)
    if key == ord('q'):
        break
    elif key == ord('c'):
        cv2.imwrite("L" + str(i) + ".png", frameL)
        cv2.imwrite("R" + str(i) + ".png", frameR)
        i += 1

# When everything done, release the capture
capL.release()
cv2.destroyAllWindows()
capL.release()
