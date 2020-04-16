%% Data augmentation based on kidney shape registration
% For more details on the underlying model please refer to the following paper:
% @article{yin2020automatic,
% title={Automatic kidney segmentation in ultrasound images using subsequent boundary distance regression and pixelwise classification networks},
% author={Yin, Shi and Peng, Qinmu and Li, Hongming and Zhang, Zhengqiang and You, Xinge and Fischer, Katherine and Furth, Susan L and Tasian, Gregory E and Fan, Yong},
% journal={Medical Image Analysis},
% volume={60},
% pages={101602},
% year={2020}}
%%
clear;
close all;
fclose('all');
train_txt=importdata('../data_example/train_list.txt');%% import train image list
[num,~]=size(train_txt);
Wmoving = 255*ones(321,321);
Blabel=zeros(321,321);
for i=1:num
    C=train_txt(i,:);
    C1=cell2mat(C);
    space=strfind(C1,' ');
    Name1=C1(1:space-1);
    Name2=C1(space+1:end);
    Oimage=imread(['../data_example/',Name1]);
    Oimage1=imresize(Oimage,[321,361],'bilinear');
    Omoving = double(rgb2gray(Oimage1(:,1:321,:)));
    load(['../data_example/',Name2]);%% import label 
    Olabel= sBW.BW;
    Olabel1=imresize(Olabel,[321,361],'nearest');
    index = 1;
    figure;
    imshow(Omoving,[]);
    title('Original image');%% read moving image
    figure;
    imshow(Olabel1,[]);  
    title('Original label');%%read moving label
    figure;
    iptsetpref('ImshowBorder','tight');
    plotepside(Omoving,Olabel1(:,1:321))%% show moving image and label
    for ii=1:num 
       if (ii~=i)%% if moving image and fixed image are not same:kidney shape registration 
        CC=train_txt(ii,:);
        CC1=cell2mat(CC);
        space=strfind(CC1,' ');
        NName1=CC1(1:space-1);
        NName2=CC1(space+1:end);
        Simage=imread(['../data_example/',NName1]);
        Simage1=imresize(Simage,[321,361],'bilinear');
        Smoving = rgb2gray(Simage1(:,1:321,:));
        load(['../data_example/',NName2]);
        Slabel= sBW.BW;
        Slabel1=imresize(Slabel,[321,361],'nearest');
        figure;
        imshow(Smoving,[]);
        title('Source image');%% show fixed image
        figure;
        imshow(Slabel1,[]);%% show fixed label
        title('Source label');
        figure;
        plotepside(Smoving,Slabel1)%% show fixed image and label
        [Cmoving,Clabel]=tpsWarpDemo_three2018(Omoving(:,1:321),Olabel1(:,1:321),Slabel1(:,1:321),'map.mat');%% registed based on kidney shape
        figure;
        Cmovingjpg = imshow(Cmoving,[]);%% show moving image after registered
        axis equal;
        title('Registerd image');
        hold on;
        contour(Clabel, [0.5,0.5], 'color', 'r', 'LineWidth', 2);
        Wmoving=Cmoving;
        Blabel=Clabel;%% show moving label after registered
        figure;
        imshow(Clabel,[]);
        title('Registerd label');
        Fmoving=fliplr(Cmoving);%% flip moving image after registered
        Flabel=fliplr(Clabel);%% flip moving label after registered
        figure;
        imshow(Fmoving,[]);
        title('Fliped Registerd image');
        hold on;
        contour(Flabel, [0.5,0.5], 'color', 'r', 'LineWidth', 2);
        figure;
        imshow(Flabel,[]);
        title('Fliped Registerd label');
        index = index+1;
       else %% if moving image and fixed image are same: just flip
        Cmoving=Omoving;
        Clabel=Olabel1;
        Fmoving=fliplr(Cmoving);%% flip the moving image 
        Flabel=fliplr(Clabel);%% flip the moving label
        figure;
        imshow(Fmoving,[]);
        figure;
        imshow(Flabel);
       end
    end
end
