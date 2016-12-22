#!/bin/bash

# benmichae-zoomable-image-downloader-v1
# bash code to download images in a Zoomable image and reconstructs into a single file using imagemagik. Quick reverse engineering of OpenSeadragon zoomable image.
#
# 2016-12-22 benmichae
#
# pre-reqs: wget, gm
#
# some other example URLS:
# fileDir='https://s3-us-west-2.amazonaws.com/sfmomamedia/media/zoom_tiles/220966/image_files/11/' #use n=6, m=6 #Ellsworth Kelly, Spectrum I                             #https://www.sfmoma.org/artwork/99.353
# fileDir='https://s3-us-west-2.amazonaws.com/sfmomamedia/media/zoom_tiles/221985/image_files/11/' #use n=6, m=7 #Ellsworth Kelly, Gaza                                   #https://www.sfmoma.org/artwork/99.345
# fileDir='https://s3-us-west-2.amazonaws.com/sfmomamedia/media/zoom_tiles/221997/image_files/11/' #use n=6, m=8 #Ellsworth Kelly, Self-Portrait with Thorn               #https://www.sfmoma.org/artwork/99.351
# fileDir='https://s3-us-west-2.amazonaws.com/sfmomamedia/media/zoom_tiles/235296/image_files/11/' #use n=5, m=5 #Ellsworth Kelly, Spectrum Colors Arranged by Chance     #https://www.sfmoma.org/artwork/99.352
#Yes, Color is my day-long obsession, joy and torment.

#Image Dimension and Location Settings (OpenSeadragon size 11 is what I want).
fileDir='https://s3-us-west-2.amazonaws.com/sfmomamedia/media/zoom_tiles/213332/image_files/11/' #use n=8, m=7 #Ellsworth Kelly, Cité, 1951                               #https://www.sfmoma.org/artwork/99.341
n=8 	 #x-dimension images  (not this needs to correspond with size 11)
m=7    #y-dimension images (use this for non square images)
fileEx='.jpg'												#Include the dot i.e. ='.jpg'
now=$(date +"%Y-%m-%dT%H-%M-%S")
txtFileThatHoldsImageURLs="imagelinks-$now.txt"

echo "benmichae-zoomable-image-downloader-v1 : $now" #Nice Bash Intro
echo '--------------------------------------'
mkdir _temp
cd _temp
mkdir $now
cd $now
touch "$txtFileThatHoldsImageURLs"  #creates file to hold list of all images

#Download Individual Pieces and put them in a text file for batch DL.
#Note: First file is 0_0.jpg, Final image is (n-1)_(m-1).jpg
#Should give code like:
#https://s3-us-west-2.amazonaws.com/sfmomamedia/media/zoom_tiles/220966/image_files/11/0_0.jpg
#https://s3-us-west-2.amazonaws.com/sfmomamedia/media/zoom_tiles/220966/image_files/11/0_1.jpg
#...
#https://s3-us-west-2.amazonaws.com/sfmomamedia/media/zoom_tiles/220966/image_files/11/i_j.jpg

for ((i=0; i<n; i++)); do
  for ((j=0; j<m; j++)); do

    #construct filename and links
    imgfileName=$i"_"$j$fileEx
    imgSnippet=$fileDir$imgfileName
    echo $imgSnippet >> "$txtFileThatHoldsImageURLs" #appends URL to the list txt file

  done
done

echo "Wrote image snippet URLS to File: "$txtFileThatHoldsImageURLs
echo "Downloading images..."
wget -i $txtFileThatHoldsImageURLs -P "./smallimages/"; #doing this way is simpler, however much slower
echo "Image Downloads Complete. Now stiching images."

#Now Mesh the image snippets into a full image (uses imagemagik)
for ((j=0; j<n; j++)); do
  montage smallimages/$j*.jpg \-geometry +0+0 \-tile 1x$m column$j.jpg #takes first column of images and creates vertical strip
done
montage column*.jpg \-geometry +0+0 \-tile "$n"x1 ../../hero.jpg        #puts all columns into a horizontal array
rm column*                                                              #optional cleanup of old files

echo "Final Wrote image to file: hero.jpg"
