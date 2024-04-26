%�ļ�����dcthide.m
%�������ܣ�����������DCT���˳����Ϣ����
%�����ʽ������[count,msg]=dcthide('lena_gray_256.tiff','message_short.txt','lena_dctembed.tiff',10);
%����˵����
%imageΪ����ͼ��
%msgΪ�����ص���Ϣ
%alphaΪ��������������֤�������ȷ��
%countΪ��������Ϣ�ĳ���
%outputΪ���ؽ��
function [count,msg,output]=dcthide(image,msg,outputPath,alpha)
%��λ��ȡ������Ϣ
frr=fopen(msg,'r');
[msg,count]=fread(frr,'ubit1');
fclose(frr);
%��ȡͼƬ
plainimage=imread(image);
plainimage=double(plainimage);
N=8;
[row, col] = size(plainimage);
row = floor(row / N) * N;
col = floor(col / N) * N;
plainimage = plainimage(1:row, 1:col);

% ˳����ϢǶ��
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
	temp=allblock8(:,:,i);
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
	allblock8_embed(:,:,i)=temp;
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
%subplot(121);imshow(uint8(plainimage)),title('Original image');
%subplot(122);imshow(uint8(output)),title('Hidden image');
imwrite(uint8(output), outputPath);
