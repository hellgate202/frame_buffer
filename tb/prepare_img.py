import numpy as np
import cv2
import sys
import matplotlib.pyplot as plt

gamma = 2.2

mean  = 0
var   = 50
sigma = var ** 0.5

def add_noise( img ):
  img = img.astype( np.int16 )
  img_n = np.zeros( img.shape , dtype = np.int16 )
  gaussian = np.random.normal( mean, sigma, ( img.shape[0], img.shape[1] ) )
  img_n[:, :, 0] = img[:, :, 0] + gaussian
  img_n[:, :, 1] = img[:, :, 1] + gaussian
  img_n[:, :, 2] = img[:, :, 2] + gaussian
  for y in range( img.shape[0] ):
    for x in range ( img.shape[1] ):
      for c in range ( 3 ):
        if( img_n[y][x][c] < 0 ):
          img_n[y][x][c] = 0
        elif( img_n[y][x][c] > 255 ):
          img_n[y][x][c] = 255
  img_n = img_n.astype( np.uint8 )
  return img_n

def apply_gamma( img, gamma ):
  for y in range( img.shape[0] ):
    for x in range ( img.shape[1] ):
      for c in range ( 3 ):
        img[y][x][c] = ( ( img[y][x][c] / 255.0 ) ** gamma ) * 255

def convert2bayer( img ):
  img_bay = np.zeros( ( img.shape[0], img.shape[1] ), dtype = np.uint8 )
  for y in range( img.shape[0] ):
    for x in range( img.shape[1] ):
      if ( y % 2 ) == 0:
        if ( x % 2 ) == 0:
          img_bay[y][x] = img[y][x][2]
        else:
          img_bay[y][x] = img[y][x][1]
      else:
        if ( x % 2 ) == 0:
          img_bay[y][x] = img[y][x][1]
        else:
          img_bay[y][x] = img[y][x][0]
  return img_bay


img = cv2.imread( sys.argv[1] )
new_x = int( sys.argv[2] )
new_y = int( sys.argv[3] )
print( "Resizing image to %0d x %0d" % ( new_x, new_y ) )
img = cv2.resize( img, ( new_x, new_y ) )

print( "Converting to Bayer pattern" )
bayer = convert2bayer( img )

print( "Creating sample hex file" )
with open( "../tb/img.hex", "w+" ) as f:
  for y in range( bayer.shape[0] ):
    for x in range( bayer.shape[1] ):
      f.write( hex( bayer[y][x] * 16 )[2 : -1]+"\n" )
