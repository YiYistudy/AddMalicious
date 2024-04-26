%文件名：dcthide.m
%函数功能：本函数用于DCT域的随机信息隐藏
%输入格式举例：[count,msg]=dcthide_rand('lena_gray_256.tiff','message_short.txt','lena_dctembed_rand.tiff',10,2019);
%参数说明：
%image为载体图像
%msg为待隐藏的信息
%alpha为控制量，用来保证编码的正确性
%key为密钥，用来控制随机选块
%count为待隐藏信息的长度
%output为隐藏结果
function [count,msg]=dcthide_rand(image,msg,outputPath,alpha,key)
%按位读取秘密信息
frr=fopen(msg,'r');
[msg,count]=fread(frr,'ubit1');
fclose(frr);
%读取图片
plainimage=imread(image);
plainimage=double(plainimage);
[row,col]=size(plainimage);
N=8;
[row, col] = size(plainimage);
row = floor(row / N) * N;
col = floor(col / N) * N;
if 0 == row || 0 == col
	error("图像对 N 做整数除法后大小为 0。");
end
plainimage = plainimage(1:row, 1:col);

%生成随机序列
while true
	try
		[row_index,col_index]=randinterval(zeros(row/8,col/8),count,key);
		break;
	catch
		row = row * 2;
		col = col * 2;
		plainimage = [plainimage, plainimage; plainimage, plainimage];
	end
end
index=sub2ind([row/8 col/8],row_index,col_index);

% 随机信息嵌入
allblock8=[];
allblock8_number=1;
for m=1:N:row
	for n=1:N:col
		t=plainimage(m:m+N-1,n:n+N-1)-128;
		y=dctmtx(8)*t*dctmtx(8)';
		allblock8(:,:,allblock8_number)=y;
		allblock8_number=allblock8_number+1;
	end
end
allblock8_embed=allblock8;
for i=1:count
	temp=allblock8(:,:,index(i));
	if msg(i)==0 % 选取（5,2）和（4,3）两个系数
		if temp(5,2)>temp(4,3)
			temp1=temp(5,2);
			temp(5,2)=temp(4,3);
			temp(4,3)=temp1;
		end
	else
		if temp(5,2)<temp(4,3)
			temp1=temp(5,2);
			temp(5,2)=temp(4,3);
			temp(4,3)=temp1;
		end
	end
	
	if temp(5,2)>temp(4,3)
		temp(4,3)=temp(4,3)-alpha; %将原本小的系数调整更小
	else
		temp(5,2)=temp(5,2)-alpha; %将原本大的系数调整更大
	end
	allblock8_embed(:,:,index(i))=temp;
end
output=zeros(row,col);
allblock8_number=1;
for m=1:N:row
	for n=1:N:col
		temp=allblock8_embed(:,:,allblock8_number);
		output(m:m+N-1,n:n+N-1)=dctmtx(8)'*temp*dctmtx(8)+128;
		allblock8_number=allblock8_number+1;
	end
end
imwrite(uint8(output), outputPath);
%显示实验结果 
%subplot(121);imshow(uint8(plainimage)),title('Original image');
%subplot(122);imshow(uint8(output)),title('Hidden image');

