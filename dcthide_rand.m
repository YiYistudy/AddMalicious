%�ļ�����dcthide.m
%�������ܣ�����������DCT��������Ϣ����
%�����ʽ������[count,msg]=dcthide_rand('lena_gray_256.tiff','message_short.txt','lena_dctembed_rand.tiff',10,2019);
%����˵����
%imageΪ����ͼ��
%msgΪ�����ص���Ϣ
%alphaΪ��������������֤�������ȷ��
%keyΪ��Կ�������������ѡ��
%countΪ��������Ϣ�ĳ���
%outputΪ���ؽ��
function [count,msg]=dcthide_rand(image,msg,outputPath,alpha,key)
%��λ��ȡ������Ϣ
frr=fopen(msg,'r');
[msg,count]=fread(frr,'ubit1');
fclose(frr);
%��ȡͼƬ
plainimage=imread(image);
plainimage=double(plainimage);
[row,col]=size(plainimage);
N=8;
[row, col] = size(plainimage);
row = floor(row / N) * N;
col = floor(col / N) * N;
if 0 == row || 0 == col
	error("ͼ��� N �������������СΪ 0��");
end
plainimage = plainimage(1:row, 1:col);

%�����������
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

% �����ϢǶ��
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
	if msg(i)==0 % ѡȡ��5,2���ͣ�4,3������ϵ��
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
		temp(4,3)=temp(4,3)-alpha; %��ԭ��С��ϵ��������С
	else
		temp(5,2)=temp(5,2)-alpha; %��ԭ�����ϵ����������
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
%��ʾʵ���� 
%subplot(121);imshow(uint8(plainimage)),title('Original image');
%subplot(122);imshow(uint8(output)),title('Hidden image');

