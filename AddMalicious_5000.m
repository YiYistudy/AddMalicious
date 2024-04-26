results_dir = "mal_figures/";
figures_dir = "source_figures/";
malicious_dir = "mal_datasets/";
steganography = {"lsbhide", "randlsbhide", "dcthide", "dcthide_rand", "pvdhide"};
folder_classification = {"train", "val"};

isClear = 0;

if isClear == 1
	if exist(results_dir, "dir")
		rmdir(results_dir, "s");
	end
	mkdir(results_dir);
end

MaliciousList = {"Disable-FLAG_SECURE_v3.1.0.txt", "Game Unlocker.txt", "Disable-FLAG_KEEP_SCREEN_ON.txt", "核心破解_V4.3.txt", "Telegram.txt", "MobileRadioAdAway.txt", "恢复正在运行的服务入口.txt", "Ransom (17.06.05) .txt","GM Dark Theme Enabler.txt", "message.txt"};

for Ste_id = 1 :  length(steganography)
	Folder1_name = steganography{Ste_id};
	Folder1 = strcat(results_dir, Folder1_name, "/");
	mkdir(Folder1);
	Folder2_name = "dataSet";
	Folder2 = strcat(Folder1, Folder2_name, "/");
	mkdir(Folder2);
	for Mal_id = 10 : length(MaliciousList)
		MaliciousFile = MaliciousList{Mal_id};
		if Mal_id ~= 10
			Folder3_name = strcat("YY", num2str(Mal_id));
		else
			Folder3_name = "YN";
		end
		Folder3 = strcat(Folder2, Folder3_name, "/");
		mkdir(Folder3);
		FigureNames = dir(figures_dir);
		for Figure_id = 3: length(FigureNames)
			Figure = FigureNames(Figure_id, 1).name;
			%Here should correspond to the content of "steganography" one by one. 
			input = strcat(figures_dir, Figure);
			file = strcat(malicious_dir, MaliciousFile);
			output = strcat(Folder3, Figure);
			if exist(output, "file")
				continue;
			else
				try
					if Ste_id == 1
						[ste_cover, len_total]=lsbhide(input, file, output);
					elseif Ste_id == 2
						%key = randi(10000);
						key = 10;
						[ste_cover, len_total]=randlsbhide(input, file, output, key);
					elseif Ste_id == 3
						%alpha = randi(100);
						alpha = 10;
						[count, msg]=dcthide(input, file, output, alpha);
					elseif Ste_id == 4
						%alpha = randi(100);
						alpha = 10;
						%key = randi(100);
						key = 10;
						[count, msg]=dcthide_rand(input, file, output, alpha, key);
					elseif Ste_id == 5
						[count, msg]=pvdhide(input, file, output);
					else
						disp("Steganography no define!");
					end
				catch
					disp(strcat("Steganography: ", Folder1_name, "Figure: ", Figure, " MaliciouText: ", MaliciousFile));
					continue;
				end
				clf;
			end
		end
		disp(strcat("Finish: Steganography: ", Folder1_name, "; MaliciouText: ", MaliciousFile, ". "));
	end
end