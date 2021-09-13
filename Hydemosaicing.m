function img_rec_Hydemosaicing =  Hydemosaicing( img_mosaic, row_cell, col_cell, Mask_wholeImg,  p_subspace,   varargin   )
%--------------------------Input----------------------------
% img_mosaic: Acquired data from compressive sensing camera
% row_cell: number of rows in each cell, i.e., sqrt(K) in Fig. 1 of
% Hy-demosaicing paper
% col_cell : number of columns in each cell
% Mask_wholeImg: Sampling mask.
% img_clean: clean image
% p_subspace: dimension of signal subspace
%  INPUT ARGUMENTS (OPTIONAL):
% denoiser_plugged: plugged denoiser, denoted as $\phi(z)$ in eq. (8) in
% paper [1]. Defaut denoiser is BM3D.
% std_Gaussian_noise: standard deviation of Gaussian noise in the measurements img_mosaic.

%-------------------------- Ouput ------------------------------
%img_rec: A image reconstructed by Hy-demosaicing.

%-------------------------- USAGE EXAMPLES ------------------------
%
%     Case 1) Using the default parameters (i.e., denoiser_plugged and std_Gaussian_noise.)
%       img_rec =  Hydemosaicing( img_mosaic, row_cell, col_cell, Mask_wholeImg,  p_subspace)
%
%     Case 2) Using user-provided argument:
%       img_rec =  Hydemosaicing( img_mosaic, row_cell, col_cell, Mask_wholeImg,  p_subspace, 'denoiser_plugged', denoiser_plugged, 'std_Gaussian_noise', sigma ) ;


% ---------------------------- -------------------------------------------
% See more details in papers:
% [1] Lina Zhuang, Michael K. Ng, Xiyou Fu, and Jose M. Bioucas-Dias,
% "Hy-demosaicing: Hyperspectral blind reconstruction from spectral subsampling,"
% in IEEE Transactions on Geoscience and Remote Sensing, Aug. 2021.
% (DOI: 10.1109/TGRS.2021.3102136)
% URL: https://ieeexplore-ieee-org.eproxy.lib.hku.hk/document/9513279
%
%  [2] Lina Zhuang and Jose M. Bioucas-Dias, "Lina Zhuang and Jose M.
%  Bioucas-Dias, Hy-demosaicing: hyperspectral blind reconstruction from
%  spectral subsampling,"� in IEEE International Geoscience and Remote Sensing
%  Symposium (IGARSS), 2018. (Third place in student paper contest of IGARSS
%  2018)
%  URL: https://www.it.pt/Publications/DownloadPaperConference/34254
%  -------------------------------------------------------------------------
%
% Copyright (Sep. 2021):
%             Lina Zhuang (linazhuang@qq.com)
%
%
% Hydemosaicing is distributed under the terms of
% the GNU General Public License 2.0.
%
% Permission to use, copy, modify, and distribute this software for
% any purpose without fee is hereby granted, provided that this entire
% notice is included in all copies of any software which is or includes
% a copy or modification of this software and in all copies of the
% supporting documentation for such software.
% This software is being provided "as is", without any express or
% implied warranty.  In particular, the authors do not make any
% representation or warranty of any kind concerning the merchantability
% of this software or its fitness for any particular purpose."
% ---------------------------------------------------------------------

n=numel(varargin);
if n~=0
    for i=1:2:n
        if strcmp(varargin{i},'denoiser_plugged')
            denoiser_plugged = varargin{i+1};
        end
        if strcmp(varargin{i},'std_Gaussian_noise')
            std_Gaussian_noise = varargin{i+1};
        end
    end
end

if exist('denoiser_plugged') ==0
    denoiser_plugged = 'BM3D'; % Using default denoiser
end

if exist('std_Gaussian_noise') ==0
    %Standard deviation of Gaussian noise in the measurements img_mosaic is
    %estimated automatically.
    img_rec_Hydemosaicing =  Hydemosaicing_core( img_mosaic, row_cell, col_cell,  Mask_wholeImg,  p_subspace, 'denoiser_plugged', denoiser_plugged  ) ;
else
    img_rec_Hydemosaicing =  Hydemosaicing_core( img_mosaic, row_cell, col_cell,  Mask_wholeImg,  p_subspace, 'denoiser_plugged', denoiser_plugged, 'std_Gaussian_noise',std_Gaussian_noise ) ;
end


end
 