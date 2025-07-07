
% codegen sobel

datasets = {'Impeller', 'Mechanical Seal Hole', 'Mechanical Seal Scratch', 'Normal'};
counter = 1;
fs = 25600;
I = 1;
MH = 1;
MS = 1;
N =1;
time = linspace(0, 1,fs);

main_path = 'D:\CP Project\Images(2020)\Stockwell\4.0BAR';

for i=1: length(datasets)
    Folder = datasets{i};
    
    S = dir(fullfile(Folder, '*.mat'));
    ax = axes;
    for k = 1:numel(S) 
        F = fullfile(Folder,S(k).name); % you need FOLDER here too.
        data = load(F);
        mat = data.signal;
        
        
        s = mat(1,:);
        

        s = lowpass(s, 4600, fs);
           
        ST = stran(s);
        img = imagesc(time,fs,abs(ST));
        axis xy;
        title('');
        set(gca,'xtick',[],'ytick',[]);

        set(gcf, 'Units', 'pixels');
        pos = get(gca, 'Position'); 
        set(gca, 'Position', [0 0 1 1]);
        colormap gray;
        



        if strcmp( datasets(i),'Impeller')
            saveas(gcf, fullfile(main_path, 'Impeller', ['Image', num2str(I), '.png']));
            I = I+1;
        elseif strcmp( datasets(i),'Mechanical Seal Hole')
            saveas(gcf, fullfile(main_path, 'Mechanical Seal Hole', ['Image', num2str(MH), '.png']));
            MH = MH+1;
        elseif strcmp( datasets(i),'Mechanical Seal Scratch')
            saveas(gcf, fullfile(main_path, 'Mechanical Seal Scratch', ['Image', num2str(MS), '.png']));
            MS = MS+1;
        elseif strcmp( datasets(i),'Normal')
            saveas(gcf, fullfile(main_path, 'Normal', ['Image', num2str(N), '.png']));
            N = N+1;
        end
    
        
    
        disp(counter);
        counter = counter +1;

        clf;


            
        
    
        % execute what I want
    
    end
  
end

function ST=stran(h)
% Compute S-Transform without for loops
%%% Coded by Kalyan S. Dash %%%
%%% IIT Bhubaneswar, India %%%
[~,N]=size(h); % h is a 1xN one-dimensional series
nhaf=fix(N/2);
odvn=1;
if nhaf*2==N;
    odvn=0;
end
f=[0:nhaf -nhaf+1-odvn:-1]/N;
Hft=fft(h);
%Compute all frequency domain Gaussians as one matrix
invfk=[1./f(2:nhaf+1)]';
W=2*pi*repmat(f,nhaf,1).*repmat(invfk,1,N);
G=exp((-W.^2)/2); %Gaussian in freq domain
% End of frequency domain Gaussian computation
% Compute Toeplitz matrix with the shifted fft(h)
HW=toeplitz(Hft(1:nhaf+1)',Hft);
% Exclude the first row, corresponding to zero frequency
HW=[HW(2:nhaf+1,:)];
% Compute Stockwell Transform
ST=ifft(HW.*G,[],2); %Compute voice
%Add the zero freq row
st0=mean(h)*ones(1,N);
ST=[st0;ST];
end