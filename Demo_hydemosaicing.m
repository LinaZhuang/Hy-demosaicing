%% Name: Demo_hydemosaicing
%
%  Generate the results of Hy-demosaicing reported in the following papers:
%
% [1] Lina Zhuang, Michael K. Ng, Xiyou Fu, and Jose M. Bioucas-Dias,
% "Hy-demosaicing: Hyperspectral blind reconstruction from spectral subsampling,"
% in IEEE Transactions on Geoscience and Remote Sensing, Aug. 2021.
% (DOI: 10.1109/TGRS.2021.3102136)
% URL: https://ieeexplore-ieee-org.eproxy.lib.hku.hk/document/9513279
%
%  [2] Lina Zhuang and Jose M. Bioucas-Dias, "Lina Zhuang and Jose M.
%  Bioucas-Dias, Hy-demosaicing: hyperspectral blind reconstruction from
%  spectral subsampling,"in IEEE International Geoscience and Remote Sensing
%  Symposium (IGARSS), 2018. (Third place in student paper contest of IGARSS
%  2018)
%  URL: https://www.it.pt/Publications/DownloadPaperConference/34254
%
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
% Author: Lina Zhuang (linazhuang@qq.com), Sep. 2021
% https://github.com/LinaZhuang
% https://sites.google.com/view/linazhuang/home

clear;clc;      close all;
vec=@(x) x(:);
load dc.mat;
img_clean =  dc; clear  dc;
img_clean = max(img_clean,0);

if mod(size(img_clean,2),2)==1
    img_clean(:,end+1,:) = img_clean(:,end,:);
end
if mod(size(img_clean,1),2)==1
    img_clean(end+1,:,:) = img_clean(end,:,:);
end



img = img_clean;
[row, column, band] = size(img);
N=row*column;
I = eye(band);
Y = reshape(img, N,band)';
img_clean_vec = img_clean(:);


Rn_real = (Y*Y'/N); % Autocorrelation matrix of the spectral vectors, denoted by R in eq.(5) of paper [1]
row_cell =  30;   %number of rows in each cell, i.e., sqrt(K) in Fig. 2 of paper [1]
col_cell =  30; %number of columns in each cell


N_cell = row_cell*col_cell;
RMSE_save = [];
img_rec_save = [];
p_subspace_save = [];
i_test = 0;



for band_cell =  30  %implying compression ratio %band_cell is denoted as q in Fig. 2 of paper [1]
    disp(['The size of color selector cell sqrt(K) x sqrt(K) x q = ',...
        num2str(row_cell), 'x', num2str(col_cell), 'x',num2str(band_cell) ]);
    disp(['Sampling ratio (SR) = ',num2str(band_cell/band)]);
    i_test =  i_test+1;
    rng(1);
    %% design sampling Mask:
    idx_band_cell = [];
    for i = 1:row_cell
        for    j = 1:col_cell
            idx_band_cell(i,j,:) = sort(randperm(band,band_cell));
        end
    end
    
    
    
    
    %% sampling:
    img_mosaic = zeros(row, column, band_cell);
    Mask_wholeImg = zeros(row, column, band_cell);
    
    for i = 1:row_cell
        for  j = 1:col_cell
            
            band_selected = idx_band_cell(i,j,:);
            img_mosaic(i:row_cell:end, j:col_cell:end,:) = img(i:row_cell:end, j:col_cell:end, band_selected(:)');
            [r_tmp,c_tmp,~] = size(  img_mosaic(i:row_cell:end, j:col_cell:end,:) );
            Mask_wholeImg(i:row_cell:end, j:col_cell:end,:) = repmat( band_selected ,r_tmp,c_tmp) ;
            
        end
    end
    
    if 1 %add noise to measurements
        rng(1);
        sigma = max(img_mosaic(:))*0.005; %(25 dB)
        %0.016 (15dB)  0.009(20 dB) 0.005(25 dB) 0.0029 (30 dB)
        noise = sigma.*randn(size(img_mosaic));
        snr_sim = 10*log10( mean(norm(img_mosaic(:))^2)/mean(norm(noise(:))^2)  );
        disp(['SNR of measurements is ',num2str(snr_sim), 'dB.']);
        img_mosaic = img_mosaic+noise;
        %psnr_sim =  psnr(img_mosaic(:), img_mosaic(:)-noise(:))
    end
    
    %% Image Reconstruction using Hy-demosaicing method
    
    p_subspace = 5; %dimension of spectral subspace
    denoiser_plugged = 'BM3D'; % use this one if the neural network FFDNet is not intalled in your system.
    %     denoiser_plugged = 'FFDNet'; % proposed in paper [1]
    
    img_rec_Hydemosaicing =  Hydemosaicing( img_mosaic, row_cell, col_cell,  Mask_wholeImg,  p_subspace, 'denoiser_plugged', denoiser_plugged ) ;
    %     img_rec_Hydemosaicing =  Hydemosaicing( img_mosaic, row_cell, col_cell,  Mask_wholeImg,  p_subspace, 'denoiser_plugged', denoiser_plugged, 'std_Gaussian_noise',sigma ) ;
    
    
    
    MPSNR_Hydemosaicing = MPSNR(img_rec_Hydemosaicing,img_clean);
    disp(['MPSNR = ',num2str(MPSNR_Hydemosaicing),' dB']);
    
    figure;
    band_show = 2;
    band_observed = zeros(size(img_mosaic));
    band_observed(find(Mask_wholeImg==band_show)) = img_mosaic(find(Mask_wholeImg==band_show));
    band_observed = sum(band_observed,3);
    tmp = img_rec_Hydemosaicing(:,:,1);
    subplot(1,2,1);
    imagesc(band_observed, [prctile(band_observed(:),2), prctile(band_observed(:),98)]);
    title(['Observed band #',num2str(band_show),'   (sampling ratio = ',num2str(band_cell/band),')'] );
    subplot(1,2,2);
    imagesc(tmp, [prctile(tmp(:),2), prctile(tmp(:),98)]);
    title(['Band #',num2str(band_show),' recovered by hy-demosacing method']);
end


