close all;
clear;
clc;

original_figures_dir = "source_figures/0.0/";
mal_figures_dir = "mal_figures/";
mal_datasets_dir = "mal_datasets/";
results_dir = "index_results/";
steganography = {"lsbhide", "randlsbhide", "dcthide", "dcthide_rand", "pvdhide"};
MaliciousList = {"Disable-FLAG_SECURE_v3.1.0.txt", "Game Unlocker.txt", "Disable-FLAG_KEEP_SCREEN_ON.txt", "核心破解_V4.3.txt", "Telegram.txt", "MobileRadioAdAway.txt", "恢复正在运行的服务入口.txt", "Ransom (17.06.05) .txt"};


isClear = 0;
if isClear == 1
	if exist(results_dir, "dir")
        try
		    rmdir(results_dir, "s");
        catch
            fprintf("Failed removing the result folder. ");
        end
	end
	mkdir(results_dir);
end

mal_samples_dir = dir(mal_datasets_dir);
for i = 3:length(mal_samples_dir)
	mal_samples{i - 2} =  mal_samples_dir(i, 1).name;
end

for Ste_id = 1 :  length(steganography)
	Folder1_name = steganography{Ste_id};
	Folder1 = strcat(mal_figures_dir, Folder1_name, "/");
	Folder2_name = "dataSet";
	Folder2 = strcat(Folder1, Folder2_name, "/");
	result_folder1 = strcat(results_dir, Folder1_name, "/");
	mkdir(result_folder1);
	for Mal_id = 1 : length(MaliciousList)
		MaliciousFile = MaliciousList{Mal_id};
		Folder3_name = strcat("0.", num2str(Mal_id));
		Folder3 = strcat(Folder2, Folder3_name, "/");
		file = strrep(strcat(result_folder1, MaliciousFile), ") ", ")");
		if exist(file, "file")
			fprintf("The file ""%s"" exists. It has been skipped. \n", file);
			continue;
		end
		fprintf("Start to write ""%s"". ", file);
		fp = fopen(file, "w");
		fprintf(fp, "Figure_id \t BPP \t MSE \t PSNR \t AMSE \t APSNR \n");
		FigureNames = dir(figures_dir);
		for Figure_id = 3: length(FigureNames)
			Figure = FigureNames(Figure_id, 1).name;
			original_figure = strcat(
original_figures_dir, Figure);
			mal_figure = strcat(Folder3, Figure)
			%读取恶意样本信息
			f_id = fopen(MaliciousFile, "r");
			[msg, len_total] = fread(f_id, "ubit1");
			fclose(f_id);
			%读取图像
			try
				cover = double(imread(original_figure));
				ste_cover = double(imread(mal_figure));
			catch
				fprintf("Failed reading one or two of the following files. They have been skipped. \n[1] ""%s""\n[2] ""%s""\n\n", original_figure, mal_figure);
				continue;
			end
			[m, n] = size(ste_cover);
			BPP = len_total / (m * n);
			MSE = sum(sum(sum((cover - ste_cover) .^ 2)))  / (m * n);
			PSNR = 10 * log10((255 * 255) / MSE);
			AMSE = MSE / (m * n);
			APSNR = PSNR / (m * n);
			fprintf(fp, "%s \t %.4f \t %.4f \t %.4f \t %.4f \t %.4f \n", current_figure, BPP, MSE, PSNR, AMSE, APSNR);
		end
		fclose(fp);
		fprintf("Finish writing ""%s"". \n", file);
	end
end