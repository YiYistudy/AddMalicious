%文件名：pvdhide.m
%函数功能：
%输入格式举例：[count,msg]=pvdhide('lena_color_256.tiff','message.txt','lena_ste_256.tiff');
%参数说明：
%image为载体图像
%file为待隐藏的信息
%count为待隐藏信息的长度
function [count, msg] = pvdhide(input, file, output)


%%%%%%%%%%%%%%%%%%%%%%%Reading a Secret Text File %%%%%%%%%%%%%%%%%%%%%%%%
frr = fopen(file,'r');
[msg,count] = fread(frr);
fclose(frr);
in = [];
in = [in dec2bin(count,20)]; %character to binary conversion 
for i=1:count  
	in = [in dec2bin(msg(i), 7)];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%Reading Cover Image %%%%%%%%%%%%%%%%%%%%%%%%%%%
cover_image = imread(input); %get cover image
red = cover_image(:, :, 1); % seperating rgb values 
blue = cover_image(:, :, 2);
green = cover_image(:, :, 3);
[r, c] = size(red);
if mod(c, 2) ~= 0
	c = c - 1;
	red = red(:, 1:c);
	blue = blue(:, 1:c);
	green = green(:, 1:c);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Embedding Data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
color = red; % red color selected for embedding
final = double(color); 
next = 0;
capacity = 0; % total no of bits that can be embedded
for x = 0:1:r - 1 
	for y = 0:2:c - 1
		enable = 1; %enable=0 when new pixels may fall off the boundary
		p = color(1 + x, 1 + y:2 + y); %block of two pixels, pi & pi+1
		p = double(p);
		d = p(1, 2) - p(1, 1); %d = difference between 2 pixel
		d_abs = abs(d); %absolute difference
		lb = [0 8 16 32 64 128]; %lowerbound
		ub = [7 15 31 63 127 255]; %upperbound
		for i = 1:1:6 %test the R boundary
			if (d_abs >= lb(i)) && (d_abs <= ub(i)) % selecting range
				even2 = mod(d,2); % check if any pixel in a block fall off the boundary [0, 255]
				m2 = ub(i) - d;
				if 0 == even2
					Pcheck = [p(1, 1) - floor(m2 / 2) p(1, 2) + ceil(m2 / 2)];
				else
					Pcheck = [p(1, 1) - ceil(m2 / 2) p(1, 2) + floor(m2 / 2)];
				end
				if Pcheck(1)<0 || Pcheck(2)<0 || Pcheck(1)>255 || Pcheck(2)>255
					enable = 0;
					break
				end
				n = ub(i) - lb(i) + 1; % quantization width of range
				t = floor(log2(n)); % maximum bit can be embedded in 2 pixels
				capacity = capacity + t; % max capacity of the cover image
				if next > length(in) % check if next exceeds the length of message
					m = 0;
				elseif next + t > length(in) % check if next + t exceeds the length of message
					if 1 + next >= length(in)
						k = zeros(1, t);
					else
						k = in(1 + next:length(in));
					end
					diff = next + t - length(in);
					k1 = zeros(1, t);
					if diff > 0
						for j = 1:min(size(k), next + t - length(in))
							k1(j) = k(j);
						end
					end
					k = k1;
					next = next + t;
					k = bin2dec(char(k));
					if 1 + next > length(in)
						m = 0;
					else
						if d >= 0
							dnew = k + lb(i);
						else
							dnew = -(k + lb(i));
						end
						m = dnew - d;
					end
				else % if next is less than the length of message
					k = in(1 + next:t + next);
					next = next + t;
					k = bin2dec(char(k));
					if d >= 0
						dnew = k + lb(i);
					else
						dnew = -(k + lb(i));
					end
					m = dnew - d;
				end
			end
		end
		if 1 == enable
			even = mod(d, 2);
			if 0 == even
				P0 = [p(1, 1) - floor(m / 2) p(1, 2) + ceil(m / 2)];
			else
				P0 = [p(1, 1) - ceil(m / 2) p(1, 2) + floor(m / 2)];
			end
			final(1 + x, 1 + y) = P0(1, 1);
			final(1 + x, 2 + y) = P0(1, 2);
		end
	end
end
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%Creating Stego-Image %%%%%%%%%%%%%%%%%%%%%%%%%%
if next > length(in)
	%disp('Message Embedded Successfully');
	final = uint8(final);
	stego_image = cat(3,final,blue,green);
	imwrite(stego_image,output);
	fclose('all');
else %check if the cover is samll for the given messege to be embedded
	error('Cover Image is too small for the given messege to be embedded, please replace cover image with the larger one.');
end