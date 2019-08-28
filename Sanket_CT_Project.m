%	Biomedical Imaging: CT project
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   CREATE DISK PHANTOM AND SINOGRAM
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Parameters for the disk phantom are
%	        x-center, y-center, radius, attenuation coefficient
%   The data is stored in MATLAB variable "phantom"
%   The sinogram is stored in corresponding MATLAB variable named "sg1" 
%
clear all
circ = [  0   0 110  2; 
        -65   0  20  1; 
          0   0  35  0; 
         65 -25  25  4
         50  50  7   8];
%
%	Image parameters: number of pixels, size, etc.
%
nx = 128; ny = 128;
dx = 2;		                        % 2 mm / pixel
x = dx * ([1:nx]'-(nx+1)/2);
y = -dx * ([1:ny]'-(ny+1)/2);
xx = x(:,ones(1,nx));
yy = y(:,ones(1,ny))';
%
%	Generate data for disk phantom
%
  phantom = zeros(nx,ny);
  for ii=1:size(circ,1)
    cx = circ(ii,1); cy = circ(ii,2); rad = circ(ii,3); amp = circ(ii,4);
    t = find( ((xx-cx)/rad).^2 + ((yy-cy)/rad).^2 <= 1 );
    phantom(t) = amp * ones(size(t));
  end
%
% 	Image the phantom
%
 figure(1)
   imagesc(x, y, phantom')               % NOTE the transpose (') here and the x and y values
    colormap('gray')
    axis('square')
    title('Disk Phantom')
    xlabel('Position')
    ylabel('Position')
%
%	Geometry parameters
%
nr = 128;	dr = 2;		            % number of radial samples and ray spacing
na = nr*2;          	            % number of angular samples
r = dr * ([1:nr]'-(nr+1)/2);	    % radial sample positions
angle = [0:(na-1)]'/na * pi;	    % angular sample positions
%
%	Compute sinogram for the phantom
%
     rr = r(:,ones(1,na));
     sg1 = zeros(nr, na);
  for ii=1:size(circ,1)
    cx = circ(ii,1); cy = circ(ii,2); rad = circ(ii,3); amp = circ(ii,4);
    tau = cx * cos(angle) + cy * sin(angle);
    tau = tau(:,ones(1,nr))';
    t = find( (rr-tau).^2 <= rad.^2 );
    if ii > 1, amp = amp - circ(1,4); end	% small disks embedded
    sg1(t) = sg1(t)+amp*2*sqrt(rad^2-(rr(t)-tau(t)).^2);
  end

%Sinogram of the phantom

 figure(2)
   imagesc(r, angle/pi*180, sg1')   % NOTE the transpose (') here and
    colormap('gray')                 % the fact that angle is displayed in degrees
    title('Sinogram: Disk Phantom')
    xlabel('Position (i.e., Rays)')
    ylabel('Angle')
%
%
%	Let's make a common variable (sinogram) so that your code is not linked
%	to any specific sinogram - later you should be able to cut and paste
%	your code and reconstruct unknown object
%
sinogram = sg1;                         % disk phantom
%
%	Since different size sinograms are used
%
disp(sprintf('number of rays = %g', nr))
disp(sprintf('number of views = %g', na))
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%			COMPUTE THE 0th MOMENT (a.k.a. AREA UNDER THE CURVE) 
%                AS A FUNCTION OF THE PROJECTION ANGLE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 disp('Computing 0th moment')
 
 projection=zeros(256);
 for ia=1:na
 projection1 =sinogram(:,ia);       %projection of all rows but single column -> gives dimension 128*1
 projection(ia) =sum(projection1'); %sum of all resulting attenuations stored as an array
 end
%
% Plot Oth moment of projections
%
figure(3)
   projection_max = max(projection(1:256));     %(1:256) had to be included for the max function to realise it as an array and not a vector
   plot(projection);
   axis([0,na,0,2*projection_max]);
   title('0th moment')
   xlabel('X Position')
   ylabel('Attenuation')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   IMPLEMENT SIMPLE BACKPROJECTION, i.e. 
%                PRODUCE LAMINOGRAMS
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
 disp('Simple backprojection')
if 1~=exist('lamin')
 
  lamin = zeros(nx,ny);  
  for ia = 1:na
    disp(sprintf('angle %g of %g', ia, na));   
    projection_ia=sinogram(:,ia);   %each angle projection
    projection_smear=repmat (projection_ia,1,128);  %smear current angle in 128*128
   rot= imrotate(projection_smear', ia*180/256, 'bicubic','crop');  %256 projections correspond to 180 deg. Hence ia*180/256 for current projection angle
    lamin=lamin+rot;     %lamin needs to be 128*128 = so 1st arg in imrotate should be same dimension
  end
%
% Display Image
%
  figure(4)
  imagesc(x, y, lamin); colormap('gray'); axis('image')
  title('Simple Backprojection Image')
  xlabel('mm')  %x and y in imagesc gives us scalar limits in mm
  ylabel('mm')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   FILTER PROJECTIONS 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
  sinogramfiltered=fftshift(fft(sinogram));     %FFT, then FFTSHIFT to center low frequencies
  % filter the sinogram
  % making a Ram-Lak filter
a = length(sinogram);
freqs=linspace(-1, 1, a/2).';     %slope -1 till 128 and then +1 till 256
myFilter = abs(freqs);
myFilter = repmat(myFilter,1,256);  %to make sure sinogram and filter are of same dimensions

  sinogramfilt=abs(ifft(ifftshift(sinogramfiltered.*myFilter)));    % Multiply in F domain, then IFFSHIFT, then IFFT
%
% Plot Filtered Sinogram at Theta = 45 degrees
%
  figure(5)
     plot(r, sinogram(:,64)./max(sinogram(:,64)), '-',...           %45 degree = 64th projection (256*45/180)
       r, sinogramfilt(:,64)./max(sinogramfilt(:,64)),':');
  title('Filtered sinogram at 45 degrees');
  legend('original', 'filtered');
  xlabel('Position (i.e., Rays)');
  ylabel('Amplitude');

% Display 'Filtered Sinogram'

   figure(6)
   imagesc(r, angle/pi*180, sinogramfilt'); colormap('gray'); axis('image');
   title('Filtered sinogram')
   xlabel('Position (i.e., Rays)')
   ylabel('Angle (i.e., Views)')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   BACKPROJECT THE FILTERED SINOGRAMS
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 disp('part 2: Filtered backprojection')
if 1~=exist('bpf_recon')  % Just checking ... 
%  
  bpf_recon = zeros(nx,ny);
  
  for ia = 1:na
    disp(sprintf('angle %g of %g', ia, na));
    bpf_ia=sinogramfilt(:,ia);
    bpf_smear=repmat(bpf_ia,1,128);
    rot1= imrotate(bpf_smear', ia*180/256, 'bicubic','crop');   % rotating the projection
    bpf_recon=bpf_recon+rot1;
  end

%
% Display Reconstructed Image with Negative Values Set to Zero
%
  figure(7)
  imagesc(x, y, max(bpf_recon,0)); colormap('gray'); axis('image')  
  title('Filtered Backprojection Image')
  xlabel('Position')
  ylabel('Position')
 end
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   COMPARE TO MATLAB FUNCTIONS
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%How to use radon and iradon using 2 different filters
%
theta=0:180;                    
[R,rad_angles]=radon(phantom,theta);    % as shown in radon help file

figure(8)
  imagesc(rad_angles,theta,R'); colormap('gray');  
  title('Sinogram Generated Using radon Function')
  xlabel('Position')
  ylabel('Angle')

  RamLak_filtered=iradon(R, theta, 'linear','Ram-Lak', 1.0, size(phantom,1));
  figure(9)
  imagesc(RamLak_filtered); colormap('gray');  
  title('Filtered Backprojection Using iradon Function and Ram-Lak Filter')
  xlabel('Position')
  ylabel('Position')

  Hamming_filtered=iradon(R, theta, 'linear','Hamming', 1.0, size(phantom,1));
  figure(10)
  imagesc(Hamming_filtered); colormap('gray');
  title('Filtered Backprojection Using iradon Function and Hamming Filter')
  xlabel('Position')
  ylabel('Position')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   RECONSTRUCTION USING SUBSAMPLED SINOGRAM
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Subsample the original sinogram by removing 7 out of 8 projections   
    sinogram8 = sinogram(:,1:8:end); 
%  Using the original Sinogram, reconstruct the image
   sinogram8_filtered=fftshift(fft(sinogram8));
   
   %Constructing Ram-Lak filter
   b = length(sinogram8);
freqs8=linspace(-1, 1, b).';        %Filter exists between 0:128 with two slopes touching in center
myFilter8 = abs(freqs8);
myFilter8 = repmat(myFilter8,1,32);  %Ram-Lak according to new dimensions   

   sinogramfilt8 =abs(ifft(ifftshift(sinogram8_filtered.*myFilter8)));
  bpf_recon8 = zeros(nx,ny);
  for ia = 1:na/8
    projection8=sinogramfilt8(:,ia);
    projection8_smear=repmat(projection8,1,128);
    rot2 = imrotate(projection8_smear', ia*180/32, 'bicubic', 'crop');      %angle in degrees calculated same way as before
    bpf_recon8 = bpf_recon8+rot2;
  end
%
% Display Reconstructed Image with Negative Values Set to Zero
%
  figure(11)
  imagesc(x, y, max(bpf_recon8,0)); colormap('gray'); axis('image')
  title('Subsampled Filtered Backprojection Image')
  xlabel('X Position')
  ylabel('Y Position')

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   TEST WITH A MYSTERY OBJECT
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  MYSTERY SINOGRAM
clear all
%
load sinogram2_mystery; sinogram = sg2; 
%
%	We must redefine some of the parameters again
%
 dr=1;
 [nr, na] = size(sinogram);
 nx=nr; ny=nr; dx=dr;
 angle = [0:(na-1)]'/na * pi;
 r = dr * ([1:nr]'-(nr+1)/2);
    disp(sprintf('number of rays = %g', nr))
    disp(sprintf('number of views = %g', na))
%
x = dx * ([1:nx]'-(nx+1)/2);
y = -dx * ([1:ny]'-(ny+1)/2);
xx = x(:,ones(1,ny));
yy = y(:,ones(1,ny))';
%
% Display Sinogram
%
 figure(12)
  imagesc(r, angle/pi*180, sinogram'); colormap('gray'); axis('image')
  title('Sinogram of Mystery Object')
  xlabel('Angle')
  ylabel('Ray Positions')
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   IMPLEMENT SIMPLE BACKPROJECTION, i.e. 
%                PRODUCE LAMINOGRAMS
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
   
  lamin = zeros(nx,ny);  
  for ia = 1:na
    projection_ia=sinogram(:,ia);
    projection_smear=repmat (projection_ia,1,301);
   rot= imrotate(projection_smear, ia*180/180, 'bicubic','crop');  %No. of Angular positions are 180 here
    lamin=lamin+rot;
  end

%
% Display Image
%
  figure(13)
  imagesc(x, y, lamin'); colormap('gray'); axis('image')
  title('Simple Backprojection Image of Mystery Object')
  xlabel('mm')
  ylabel('mm')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   FILTERING USING IRADON 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Demonstrate how to use iradon using a filter you choose

  theta=0:179;      %0:179 has total 180 values, so we cannot use 0:180
  RamLak_filtered=iradon(sinogram, theta, 'linear','Ram-Lak', 1.0, size(sinogram,1));
%  
% Display Image
%
  figure(14)
  imagesc(RamLak_filtered); colormap('gray');  
  title('Mystery Object, using IRADON Filtered Backprojection')
  xlabel('Position')
  ylabel('Position')
