
warning off MATLAB:polyfit:RepeatedPointsOrRescale

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%info to fill out
%info to fill out
folder= 'C:\Users\Benny Lab\Desktop\Michal\movie13_slices\ref\'; %before
folder2='C:\Users\Benny Lab\Desktop\Michal\movie13_slices\align\'; %after
Reference_image= imread('C:\Users\Benny Lab\Desktop\Michal\movie13_slices\ref\MS_2016_01_04_1_13_R3D-10001.tif'); %first image in reference directory

H = fspecial('disk',10);
blurred_ref = imfilter(Reference_image,H,'replicate');
%Reference_image= imread('C:\Users\arielliv\Desktop\Abberior\All\temp2\corrected1.tif');
dimImage=size(Reference_image);
lenx=dimImage(2);
leny=dimImage(1);
picture_size_x=lenx;
picture_size_y=leny;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1. from corrected pictures you can make a movie with no "jumps"
% 2. from ratio you can get a time scale for the reorientation process
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% dx=100;
% dy=100;
% rect_1 = [20 110 630 665]; %  [top left point x coordinate,top left point y coordinate, delta x to bottom right point, delta y to bottom right point]
% sub_Ref = imcrop(Reference_image,rect_1);
% %rect_2 = rect_1+[-dx -dy 2*dx 2*dy];
   %rect_2 = rect_1+[-19 -dy 2*dx 2*dy];
    C=(2^16)*(double(Reference_image)/max(max(double(Reference_image))))-1;
    i=1;
    figure;imshow(uint16(C));
    rect = getrect; % x y dx dy
    sub_Ref = imcrop(Reference_image,round(rect));

    dirListing = dir(folder);
dstart=3;

for d = dstart:length(dirListing)
if ~dirListing(d).isdir
fileName = fullfile(folder,dirListing(d).name); % use full path because the folder may not be the active path
New_image = uint16(imread(fileName));
%blurred_new = imfilter(New_image,H,'replicate');
%sub_New= imcrop(New_image,rect_2);
c = normxcorr2(sub_Ref(:,:,1),New_image(:,:,1));
%c = normxcorr2(Reference_image(:,:,1),New_image(:,:,1));
%c = normxcorr2(blurred_ref(:,:,1),blurred_new(:,:,1));
%Find the Total Offset Between the Images
% offset found by correlation
[max_c, imax] = max(abs(c(:)));
[ypeak, xpeak] = ind2sub(size(c),imax(1));

p=polyfit(ypeak-1:ypeak+1,c(ypeak-1:ypeak+1,xpeak)',2);
ypeak1=-p(2)/p(1)/2;
p=polyfit(xpeak-1:xpeak+1,c(ypeak,xpeak-1:xpeak+1),2);
ypeak=ypeak1;
xpeak=-p(2)/p(1)/2;
corr_offset = [(xpeak-size(New_image,2)) 
               (ypeak-size(New_image,1))];
xoffset(d-2) = corr_offset(1);
yoffset(d-2) = corr_offset(2);  
d

end % if-clause
end % for
xoffset2=xoffset-xoffset(1);
yoffset2=yoffset-yoffset(1);
%if there is aproblem aligning stop below


xleft=ceil(max(1-min(min(xoffset2)),1));
xright=round(floor(min(picture_size_x-max(max(xoffset2)),picture_size_x)));
ybottom=ceil(max(1-min(min(yoffset2)),1));
ytop=floor(min(picture_size_y-max(max(yoffset2)),picture_size_y));
deltax=xright-xleft;
deltay=ytop-ybottom;

dirListing2 = dir(folder);
for d = dstart:length(dirListing2)
if ~dirListing2(d).isdir
fileName = fullfile(folder,dirListing2(d).name); % use full path because the folder may not be the active path
Image_temp = uint16(imread(fileName));
 A=Image_temp((ybottom+floor(yoffset2(d-2))):(deltay+ybottom+floor(yoffset2(d-2))),(xleft+floor(xoffset2(d-2))):(deltax+xleft+floor(xoffset2(d-2))));
imwrite(A,[folder2 'corrected' num2str(d-2) '.tif'],'tif');

d

end % if-clause
end % for

