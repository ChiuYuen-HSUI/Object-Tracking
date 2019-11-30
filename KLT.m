clc;
clear all;
close all;

%% %%%%%% Begin Load Images or Video Frames%%%%%%%%%%%%%
%%��Ӧ���ص���ͼ������
%����ͼ�������ҵ�ͼ�����ڵ��ļ������ֺ�ͼ��ĸ�ʽ
imPath = 'input'; imExt = 'jpg';

%%%%% Load the images
%=======================
% ����ļ�Ŀ¼�Ƿ����
if isdir(imPath) == 0
    error('User error : The image directory does not exist');
end

filearray = dir([imPath filesep '*.' imExt]); % ��ȡ�ļ�Ŀ¼�µ�����ͼƬ
NumImages = size(filearray,1); % ͼƬ������
if NumImages < 0
    error('No image in the directory');
end

disp('Loading image files from the video sequence, please be patient...');
% Get image parameters
imgname = [imPath filesep filearray(1).name]; % ��������е�ͼ���name
I = imread(imgname);
if size(I)==3
   I = rgb2gray(I);
end
VIDEO_WIDTH = size(I,2);
VIDEO_HEIGHT = size(I,1);

ImSeq = zeros(VIDEO_HEIGHT, VIDEO_WIDTH, NumImages);
for i=1:NumImages
    imgname = [imPath filesep filearray(i).name]; % ��������е�ͼ���name
    img = imread(imgname);
    if size(img)==3
        img = rgb2gray(img);
    end
    ImSeq(:,:,i) = img; % ���ؽ�ͼ��
end
disp(' ... OK!');
%%��Ӧ���ص�����Ƶ
%{
Video_name = 'name.type'; %name.type��Ӧ��Ҫ���ص���Ƶ�ļ�������
vid = VideoReader(Video_name);
NumImages = vid.NumberOfFrames(vid);  %��Ƶ�ļ���������ȫ��֡��
Height = vid.Height;    %��Ӧͼ��֡��Height
Width = vid.Width;      %��Ӧͼ��֡��Width
ImSeq = zeros(Height, Width, NumImages);
disp('Loading image files from the video sequence, please be patient...');
for i = 1:NumImages
    img = read(vid,1);
    if size(img) == 3
        img = rgb2gray(img);
    end
    ImSeq(:,:,i) = img;
end
I = ImSeq(:,:,1);
disp(' ... OK!');
%}
%% %%%%%%%%%%%End The Load %%%%%%%%%%%%%%%%%%
%% ��ѡ����ĸ���Ŀ��
%You can manual initialization use the function imcrop
[pacth,rect] = imcrop(ImSeq(:,:,1)./255);    %��ѡ�����ľ��ο�����������Ͻǵ�λ��Ϊ��rect(2),rect(1)��;��Ϊrect(3),��Ϊrect(4);
%ROI_Center = round([rect(1)+rect(3)/2 , rect(2)+rect(4)/2]); 
%ROI_Width = rect(3);
%ROI_Height = rect(4);
%% Harris�ǵ�ļ��
%1���ݶȼ���
%2�������γ�
%3������ֵ����
%ͨ������x��y�����ƽ����ʹ�ø�˹�������ݶ����������Ҷ�ͼ��Ľǵ�
%%%%%%%%%%% Start Harris Corners  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
threshold=0.36;
I = double(I);
sigma=2; 
k = 0.04;             %��Harris�ǵ�����ͨ��k = 0.04
dx = [-1 0 1; -1 0 1; -1 0 1]/6;%����ģ��
dy = dx';                       %dy����dx��ת��
Ix = conv2(I, dx, 'same');      %�������x����һ���ݶ�
Iy = conv2(I, dy, 'same');      %�������y����һ���ݶ�
g = fspecial('gaussian',fix(6*sigma), sigma); %Gaussian �˲���fix()������ʾ�򿿽���ȡ��
Ix2 = conv2(Ix.^2, g, 'same');  %�������x��������ݶ�
Iy2 = conv2(Iy.^2, g, 'same');  %�������y��������ݶ�
Ixy = conv2(Ix.*Iy, g,'same');  
R= (Ix2.*Iy2 - Ixy.^2) - k*(Ix2 + Iy2).^2;   %�õ��������Ӧ����,ѡȡ�ֲ�������Ӧ��RΪ�ǵ�
%ʹ��R��һ�� ��0��1֮�� 
minr = min(min(R));
maxr = max(max(R));
R = (R - minr) / (maxr - minr);

%%ֻ�Ա���ѡ�ľ�������Ľǵ���
Rm = zeros(size(R,1),size(R,2));
Rm(rect(2):(rect(2)+rect(4)),rect(1):(rect(1)+rect(3))) = R(rect(2):(rect(2)+rect(4)),rect(1):(rect(1)+rect(3)));%��ѡ�����ľ��ο�����������Ͻǵ�λ��Ϊ��rect(2),rect(1)��;��Ϊrect(3),��Ϊrect(4);
%������ֵ5��5������R�ľֲ����ֵ
maxima = ordfilt2(Rm, 25, ones(5));   %��άͳ��˳���˲�����ordfilt2��������ģ���еĶ�Ӧ���ط�������ֵ��һ����С�����˳�����У������൱����ȡ5��5������R�ľֲ����ֵ
mask = (Rm == maxima) & (Rm > threshold);
maxima = mask.*R;

figure(1);
colormap('gray');       %��map����ӳ�䵱ǰͼ�ε�ɫͼ��
imagesc(I);
hold on;
[r,c] = find(maxima>0);  %find��A�����ؾ���A�з���Ԫ������λ�ã��ҵ��ǵ��λ�ò�������[r,c]�����Ƕ�Ӧ���к��н�����;
plot(c,r,'*');           %���Ժ����ڻ������ٵ��Ľǵ��λ�õ�ʱ�����൱��(c,r),Ҳ���Ǻ����Ӧ��(p(6),p(5)).
hold off;
%saveas(gcf,'mainCornersSeq1.jpg');
%����ǵ�
[L ~ ]=size(c);
corners = cell(1,L);    %����һ�������������洢�ǵ㣬�����ǽǵ������
%ѡ������Ľǵ�������Ӧֵ�Ľǵ㣬������ýǵ��λ��
temp = I(c(1),r(1));
tempL = [r(1),c(1)];   %������Ϊ�˺����汣��һ�£���û��ֱ��д�ɣ�c(1),r(1))����ʽ
for i=2:L
    if (I(c(i),r(i)) > temp)           %�������ֻ�Ǳ���һ���ǵ��λ�ã�Ҳ���Ƿ������ǹ۲�Ľǵ��λ��
        temp = I(c(i),r(i));
        tempL = [r(i),c(i)];
    end
end
corners_i = tempL;
%% %%%%%%%%%  End Harris Corners  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% %%%%%%%%% Start KLT Tracker %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%windowSize = 30;
windowSize = 20;
[rows, cols, chan] = size(I);

if (corners_i(1)-windowSize > 0 && corners_i(1)+windowSize <= rows && corners_i(2)-windowSize > 0 && corners_i(2)+windowSize < cols)
        %�����ʼ�ķ���任����������ֱ���Խǵ�Ϊ���Ĳο���û���κε�ƽ�ƣ���ת������
        p = [0 0 0 0 corners_i(1) corners_i(2)];
        cornerCounter = 0;
        newCornerCounter = 1;
        T = I(corners_i(1)-windowSize:corners_i(1)+windowSize,corners_i(2)-windowSize:corners_i(2)+windowSize);  %T��ʾ�Խǵ�Ϊ���ģ�2*windowsize��С��Χ�ڵľ��ο�
        T= double(T);
        %Make all x,y indices
        [x,y]=ndgrid(0:size(T,1)-1,0:size(T,2)-1);  %ndgrid����ʵ�ֶ�ά�����ȫ���У�����ʹ����T�Ĵ�С��Χ�����е�λ�ö���������������
         %����ģ��ͼ�������
        TemplateCenter=size(T)/2;
        %ʹģ��ͼ�����������Ϊ��0,0��
        x=x-TemplateCenter(1); y=y-TemplateCenter(2);    %��Tģ���е�����λ�ã�x,y��-(TemplateCenter(1),TemplateCenter(2)),ʹ��ģ�����ĵ�����Ϊ(0,0)
     for n = 2:NumImages
            NextFrame = ImSeq(:,:,n);
            NextFrameCopy = NextFrame;
            if(size(NextFrame) == 3)    %�������ͨ����RGBͼ��Ļ�����ת��Ϊrgb2gray�ĻҶ�ͼ��
                NextFrame = rgb2gray(NextFrame);
            end
            copy_p = p;
            I_nextFrame= double(NextFrame); 
            delta_p = 7;
            sigma = 3;
            %Make derivatives kernels
            [xder,yder]=ndgrid(floor(-3*sigma):ceil(3*sigma),floor(-3*sigma):ceil(3*sigma));
            DGaussx=-(xder./(2*pi*sigma^4)).*exp(-(xder.^2+yder.^2)/(2*sigma^2));
            DGaussy=-(yder./(2*pi*sigma^4)).*exp(-(xder.^2+yder.^2)/(2*sigma^2));
            % ����õ�һ�׵���
            Ix_grad = imfilter(I_nextFrame,DGaussx,'conv');     %�õ�X����ĸ�˹����ݶ�
            Iy_grad = imfilter(I_nextFrame,DGaussy,'conv');     %�õ�Y����ĸ�˹����ݶ�
            counter = 0;
            %�趨��ֵΪ0.01��С����ֵ��Ϊ���������㣬����whileѭ������Ϊ�Ѿ��ҵ����ٵ�Ŀ�꣬������ֵ��Ϊ�������㣬ִ��whileѭ��
            Threshold = 0.01;
            while ( norm(delta_p) > Threshold) %norm(A)��ʾ���ؾ���A����������ֵ
                counter= counter + 1;
                %�������80��ѭ�������������жϣ���������Ϊ����
                if(counter > 80)
                    break;
                end
                %norm(delta_p)
                %ģ����ת��ƽ�Ƶķ������
                W_p = [ 1+p(1) p(3) p(5); p(2) 1+p(4) p(6)];
                %1 Warp I with W_p
                I_warped = warpping(I_nextFrame,x,y,W_p);      %
                %2 ��֮ǰ������Ŀ��ģ���ȥ����һ֡��warp�ҵ�������Χ��Subtract I from T
                I_error= T - I_warped;
                % Break if outside image
                if((p(5)>(size(I_nextFrame,1))-1)||(p(6)>(size(I_nextFrame,2)-1))||(p(5)<0)||(p(6)<0)), break; end; %����ҲҪ�Ի�����ģ�巶Χ���жϣ��Ƿ�����һ֡��ͼ����
                %3 Warp the gradient
                Ix =  warpping(Ix_grad,x,y,W_p);   %��Եõ���x����ĸ�˹����ݶ�ͼ���������任
                Iy = warpping(Iy_grad,x,y,W_p);    %��Եõ���y����ĸ�˹����ݶ�ͼ���������任
                %4 �����ſɱȾ���
                W_Jacobian_x=[x(:) zeros(size(x(:))) y(:) zeros(size(x(:))) ones(size(x(:))) zeros(size(x(:)))];
                W_Jacobian_y=[zeros(size(x(:))) x(:) zeros(size(x(:))) y(:) zeros(size(x(:))) ones(size(x(:)))];
                %5 ��������½�
                I_steepest=zeros(numel(x),6);
                for j1=1:numel(x),
                    W_Jacobian=[W_Jacobian_x(j1,:); W_Jacobian_y(j1,:)];
                    Gradient=[Ix(j1) Iy(j1)];
                    I_steepest(j1,1:6)=Gradient*W_Jacobian;    %
                end
                %6 ���� Hessian ����
                H=zeros(6,6);
                for j2=1:numel(x), H = H + I_steepest(j2,:)'*I_steepest(j2,:); end
                %7 ���������½����
                total=zeros(6,1);
                for j3=1:numel(x), total = total + I_steepest(j3,:)'*I_error(j3); end
                %8 ���� delta_p
                delta_p=H\total;
                %9 ���²��� p 
                 p = p + delta_p';  
            end
            cornerCounter = cornerCounter+1;
            %�ڴ����ź������һ���ţ���ʾ������һ�δ��룬ÿ5֡ͼ�����һ��ģ�壬����һ֡ͼ���и��ٵ���ͼ���еĽǵ��λ��Ϊ�µ�ģ��ͼ�������
            %����Ѵ����ź���Ķ���ȥ�������ʾ���ε���δ��룬����ֻ�������Ŀ��ģ����и��٣�����ģ��ģ�����
            %{��
            if (cornerCounter == 5)     %ÿ5֡����һ��ģ��T
                T = NextFrameCopy(p(5)-windowSize:p(5)+windowSize,p(6)-windowSize:p(6)+windowSize);
                p = [0 0 0 0 p(5) p(6)];
                T= double(T);
                %Make all x,y indices
                [x,y]=ndgrid(0:size(T,1)-1,0:size(T,2)-1);
                %����ģ��ͼ�������
                TemplateCenter=size(T)/2;
                %ʹ��ģ��ͼ������ĵ�����Ϊ(0,0)
                x=x-TemplateCenter(1); y=y-TemplateCenter(2);
                cornerCounter = 0;
            end
            
            %newCornerCounter = newCornerCounter+1;
            %}
    disp('�����ٵ��Ľǵ��λ��Ϊ:\n');
    fprintf('%d,%d',p(6),p(5));
    figure(2),subplot(1,1,1), imshow(NextFrame, []);         %��֡��ʾ��һ֡ͼ��
    hold on;
	plot(p(6), p(5), '+', 'Color', 'r', 'MarkerSize',10);     %����׷�ٵ��Ľǵ��λ�ã�p(6),p(5)��,'+'
    rectangle('Position',[p(6)-25 p(5)-25 50 50],'LineWidth',2,'EdgeColor','r');   %��׷�ٵ��Ľǵ㣨p(6),p(5)��Ϊ���Ļ����ο�
    drawnow;
    end 
end

%% %%%%%%%%% End KLT Tracker %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
 

