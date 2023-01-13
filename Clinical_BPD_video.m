%% Inital run for TrachSlice just to get Min and Max area values for plot

% Plot smooth video 
tic

VTKdir = dir('*.vtk');
STLdir = dir('*.stl');

if exist('SlicedSTLs','dir')
    cd('SlicedSTLs');
else
    mkdir('SlicedSTLs');
    cd('SlicedSTLs');
end

arcLength_test = {}';
area_test = {}';
missedPlane_test = {}';
goodpos_test = {}';

trachea_area = {}';
left_bronchi_area = {}';
right_bronchi_area = {}';
trachea_arclength = {}';
left_bronchi_arclength = {}';
right_bronchi_arclength = {}';

for i = 1:numel(VTKdir)
    STLfilename = STLdir(i).name;
    VTKfilename = VTKdir(i).name;
    [arcLength, area, pos, centroid, goodpos, missedPlane] = trachSlice(STLfilename,VTKfilename);
    arcLength_test{i,1} = arcLength;
    area_test{i,1} = area;
    missedPlane_test{i,1} = missedPlane;
    goodpos_test{i,1} = goodpos;
    
    idd = diff([true,isnan(area),true]);
    idb = find(idd<0);
    ide = find(idd>0)-1;
    out = arrayfun(@(b,e)area(b:e),idb,ide,'uni',0);

    % finalmouth1 = finalmouth(~isnan(finalmouth));
    % find(all(isnan(finalmouth),1))


    if numel(idb)==4
%         finalmouth = area(idb(1):ide(1));
%         finaltrachea = area(idb(2):ide(2));
%         finalbronchi1 = area(idb(3):ide(3)-1);
%         finalbronchi2 = area(idb(4)+1:ide(4));
        
        finaltrachea = area(idb(1):ide(1));
        finalbronchi1 = area(idb(2):ide(2)-1);
        finalbronchi2 = area(idb(3)+1:ide(4));

    elseif numel(idb)<4
        finaltrachea = area(idb(1):ide(1));
        finalbronchi1 = area(idb(2):ide(2)-1);
        finalbronchi2 = area(idb(3)+1:ide(3));
    elseif numel(idb)>4
        u = 30; %do something
    end

    Diff = diff(arcLength);
    a = 0;
    Difftestfinal = horzcat(a,Diff);
    Difftestfinal(1) = Difftestfinal(2);
    arcLengthtest = Difftestfinal;
    % arcLengthtest = arcLength;
    k = ide(1);
    arcLengthtest([end-k+1:end 1:end-k]);
    arcLengthtest(k) = 0;
    arcLengthtest1 = arcLengthtest;

    % testing = arcLengthtest1(1:k-1);
    % testing = flip(testing);
    % arcLengthtest1(1:k-1) = testing;

    for j = k-1:-1:1
        arcLengthtest1(j) = arcLengthtest1(j+1) - arcLengthtest1(j);
    end

    for l = k+1:1:size(area,2)
        arcLengthtest1(l) = arcLengthtest1(l) + arcLengthtest1(l-1);
    end

    % Automate the part where it knows where the carina is
    % and shows the distance of airway from the carina
    yu = numel(finalbronchi2)- numel(finalbronchi1);
    % x1 = arcLengthtest1(idb(1):h-1);
    % x2 = arcLengthtest1(idb(1):ide(1));
    x3 = arcLengthtest1(idb(1):ide(1));
    x4 = arcLengthtest1(idb(2):ide(2)-1);
    x5 = arcLengthtest1(idb(2)+1:ide(2)+yu);
    x6 = arcLengthtest1((idb(3):ide(3)));
    Diff_x6 = diff(x6);
    b = 0;
    Difftestfinal_x6 = horzcat(b,Diff_x6);
    finalbronchi2 = area(idb(3):ide(3));
    %arcLengthtest_x6 = Difftestfinal_x6;
    Difftestfinal_x6(1) = x5(1);
    arcLengthtest_x6 = Difftestfinal_x6;

    for m = 2:numel(arcLengthtest_x6)
        arcLengthtest_x6(m) = arcLengthtest_x6(m) + arcLengthtest_x6(m-1);
    end
    trachea_area{i,1} = finaltrachea;
    left_bronchi_area{i,1} = finalbronchi1;
    right_bronchi_area{i,1} = finalbronchi2;
    trachea_arclength{i,1} = x3;
    left_bronchi_arclength{i,1} = x4;
    right_bronchi_arclength{i,1} = arcLengthtest_x6;
    %plot(x3,finaltrachea,'g-*',x4,finalbronchi1,'black-*',arcLengthtest_x6,finalbronchi2,'red-*','LineWidth',1.25); 
end
toc
%% Getting the min and max of all airway regions
% Right Bronchi - ArcLength
%baseline_RB_AL = max(numel(right_bronchi_arclength{1,1}(1,:)));
baseline_RB_AL = max(cellfun('size',right_bronchi_arclength,2)); %test
for i = 1:numel(right_bronchi_arclength)
    if numel(right_bronchi_arclength{i,1}(1,:))==baseline_RB_AL
        ARCLENGTH_rightbronchi(:,i) = right_bronchi_arclength{i,1}(1,:);
    else
        right_bronchi_arclength{i,1}(1,baseline_RB_AL) = NaN;
        ARCLENGTH_rightbronchi(:,i) = right_bronchi_arclength{i,1}(1,:);
    end
end
 ARCLENGTH_rightbronchi(ARCLENGTH_rightbronchi==0)=NaN;

% Right Bronchi - Area
%baseline_RB_area = max(numel(right_bronchi_area{1,1}(1,:)));
baseline_RB_area = max(cellfun('size',right_bronchi_area,2)); %test
for i = 1:numel(right_bronchi_area)
    if numel(right_bronchi_area{i,1}(1,:))==baseline_RB_area
        AREA_rightbronchi(:,i) = right_bronchi_area{i,1}(1,:); %#ok<*SAGROW>
    else
        right_bronchi_area{i,1}(1,baseline_RB_area) = NaN;
        AREA_rightbronchi(:,i) = right_bronchi_area{i,1}(1,:);
    end
end
AREA_rightbronchi(AREA_rightbronchi==0)=NaN;
 
% Left Bronchi - ArcLength
%baseline_LB_AL = max(numel(left_bronchi_arclength{1,1}(1,:)));
baseline_LB_AL = max(cellfun('size',left_bronchi_arclength,2)); %test

for i = 1:numel(left_bronchi_arclength)
    if numel(left_bronchi_arclength{i,1}(1,:))==baseline_LB_AL
        ARCLENGTH_leftbronchi(:,i) = left_bronchi_arclength{i,1}(1,:);
    else
        left_bronchi_arclength{i,1}(1,baseline_LB_AL) = NaN;
        ARCLENGTH_leftbronchi(:,i) = left_bronchi_arclength{i,1}(1,:);
    end
end
 ARCLENGTH_leftbronchi(ARCLENGTH_leftbronchi==0)=NaN;
 
% Left Bronchi - Area
%baseline_LB_area = max(numel(left_bronchi_area{1,1}(1,:)));
baseline_LB_area = max(cellfun('size',left_bronchi_area,2)); %test

for i = 1:numel(left_bronchi_area)
    if numel(left_bronchi_area{i,1}(1,:))==baseline_LB_area
        AREA_leftbronchi(:,i) = left_bronchi_area{i,1}(1,:); %#ok<*SAGROW>
    else
        left_bronchi_area{i,1}(1,baseline_LB_area) = NaN;
        AREA_leftbronchi(:,i) = left_bronchi_area{i,1}(1,:);
    end
end
 AREA_leftbronchi(AREA_leftbronchi==0)=NaN;
 
% Trachea - ArcLength
%baseline_trachea_AL = max(numel(trachea_arclength{1,1}(1,:)));
baseline_trachea_AL = max(cellfun('size',trachea_arclength,2)); %test

for i = 1:numel(trachea_arclength)
    if numel(trachea_arclength{i,1}(1,:))==baseline_trachea_AL
        ARCLENGTH_trachea(:,i) = trachea_arclength{i,1}(1,:);
    else
        trachea_arclength{i,1}(1,baseline_trachea_AL) = NaN;
        ARCLENGTH_trachea(:,i) = trachea_arclength{i,1}(1,:);
    end
end
 ARCLENGTH_trachea(ARCLENGTH_trachea==0)=NaN;
 
% Trachea - Area
%baseline_trachea_area = max(numel(trachea_area{1,1}(1,:)));
baseline_trachea_area = max(cellfun('size',trachea_area,2)); %test

for i = 1:numel(trachea_area)
    if numel(trachea_area{i,1}(1,:))==baseline_trachea_area
        AREA_trachea(:,i) = trachea_area{i,1}(1,:); %#ok<*SAGROW>
    else
        trachea_area{i,1}(1,baseline_trachea_area) = NaN;
        AREA_trachea(:,i) = trachea_area{i,1}(1,:);
    end
end
 AREA_trachea(AREA_trachea==0)=NaN;
 
%%
% Trachea
Max_trachea_area = [];
Min_trachea_area = [];
Max_trachea_AL = [];
Min_trachea_AL = [];

for i = 1:size(AREA_trachea,1)
    Max_trachea_area = [Max_trachea_area max(AREA_trachea(i,:))];
    Min_trachea_area = [Min_trachea_area min(AREA_trachea(i,:))];
    [row_tmax,col_tmax] = find(AREA_trachea==Max_trachea_area(1,i));
    %Max_trachea_AL = [Max_trachea_AL ARCLENGTH_trachea(row_tmax(1),col_tmax(1))];
    Max_trachea_AL = [Max_trachea_AL ARCLENGTH_trachea((row_tmax),(col_tmax))];
    [row_tmin,col_tmin] = find(AREA_trachea==Min_trachea_area(1,i));
    Min_trachea_AL = [Min_trachea_AL ARCLENGTH_trachea(row_tmin(1),col_tmin(1))];
    %Min_trachea_AL = [Min_trachea_AL ARCLENGTH_trachea(min(row_tmin),min(col_tmin))];
end

% Left Bronchi
Max_LB_area = [];
Min_LB_area = [];
Max_LB_AL = [];
Min_LB_AL = [];

for i = 1:size(AREA_leftbronchi,1)
    Max_LB_area = [Max_LB_area max(AREA_leftbronchi(i,:))];
    Min_LB_area = [Min_LB_area min(AREA_leftbronchi(i,:))];
    [row_LBmax,col_LBmax] = find(AREA_leftbronchi==Max_LB_area(1,i));
    Max_LB_AL = [Max_LB_AL ARCLENGTH_leftbronchi(row_LBmax(1),col_LBmax(1))];
    [row_LBmin,col_LBmin] = find(AREA_leftbronchi==Min_LB_area(1,i));
    Min_LB_AL = [Min_LB_AL ARCLENGTH_leftbronchi(row_LBmin(1),col_LBmin(1))];
end

% Right Bronchi
Max_RB_area = [];
Min_RB_area = [];
Max_RB_AL = [];
Min_RB_AL = [];
for i = 1:size(AREA_rightbronchi,1)
    Max_RB_area = [Max_RB_area max(AREA_rightbronchi(i,:))];
    Min_RB_area = [Min_RB_area min(AREA_rightbronchi(i,:))];
    [row_RBmax,col_RBmax] = find(AREA_rightbronchi==Max_RB_area(1,i));
    Max_RB_AL = [Max_RB_AL ARCLENGTH_rightbronchi(row_RBmax(1),col_RBmax(1))];
    [row_RBmin,col_RBmin] = find(AREA_rightbronchi==Min_RB_area(1,i));
    Min_RB_AL = [Min_RB_AL ARCLENGTH_rightbronchi(row_RBmin(1),col_RBmin(1))];
end

%% 
figure; plot(Min_trachea_AL,Min_trachea_area)
hold on
plot(Max_trachea_AL,Max_trachea_area)
Patch1 = patch([Max_trachea_AL fliplr(Min_trachea_AL)],[Max_trachea_area fliplr(Min_trachea_area)],'cyan','LineStyle','none','FaceAlpha',0.5,'EdgeColor','green');
hold on
plot(Min_LB_AL,Min_LB_area)
hold on
plot(Max_LB_AL,Max_LB_area)
hold on
Patch2 = patch([Max_LB_AL fliplr(Min_LB_AL)],[Max_LB_area fliplr(Min_LB_area)],'magenta','LineStyle','none','FaceAlpha',0.5,'EdgeColor','black');

hold on
plot(Min_RB_AL,Min_RB_area)
hold on
plot(Max_RB_AL,Max_RB_area)
hold on
Patch3 = patch([Max_RB_AL fliplr(Min_RB_AL)],[Max_RB_area fliplr(Min_RB_area)],'blue','LineStyle','none','FaceAlpha',0.5,'EdgeColor','red');

%% Rerun TrachSlice to get plot video 

% Plot smooth video 
tic

VTKdir = dir('*.vtk');
STLdir = dir('*.stl');

if exist('SlicedSTLs','dir')
    cd('SlicedSTLs');
else
    mkdir('SlicedSTLs');
    cd('SlicedSTLs');
end

arcLength_test = {}';
area_test = {}';
missedPlane_test = {}';
goodpos_test = {}';
frame = []';
%load('Final_JasonVideo.mat');

% myVideo = VideoWriter('PlotTest4'); %open video file
% myVideo.FrameRate = 50;%round((numel(VTKdir)-1)/2);  %can adjust this, 5 - 10 works well for me
% open(myVideo)
    
for i = 1:numel(VTKdir)
    STLfilename = STLdir(i).name;
    VTKfilename = VTKdir(i).name;
    [arcLength, area, pos, centroid, goodpos, missedPlane] = trachSlice(STLfilename,VTKfilename);
    arcLength_test{i,1} = arcLength;
    area_test{i,1} = area;
    missedPlane_test{i,1} = missedPlane;
    goodpos_test{i,1} = goodpos;
    
    idd = diff([true,isnan(area),true]);
    idb = find(idd<0);
    ide = find(idd>0)-1;
    out = arrayfun(@(b,e)area(b:e),idb,ide,'uni',0);

    % finalmouth1 = finalmouth(~isnan(finalmouth));
    % find(all(isnan(finalmouth),1))


    if numel(idb)==4
%         finalmouth = area(idb(1):ide(1));
%         finaltrachea = area(idb(2):ide(2));
%         finalbronchi1 = area(idb(3):ide(3)-1);
%         finalbronchi2 = area(idb(4)+1:ide(4));
        
        finaltrachea = area(idb(1):ide(1));
        finalbronchi1 = area(idb(2):ide(2)-1);
        finalbronchi2 = area(idb(3)+1:ide(4));

    elseif numel(idb)<4
        finaltrachea = area(idb(1):ide(1));
        finalbronchi1 = area(idb(2):ide(2)-1);
        finalbronchi2 = area(idb(3)+1:ide(3));
    elseif numel(idb)>4
        u = 30; %do something
    end

    Diff = diff(arcLength);
    a = 0;
    Difftestfinal = horzcat(a,Diff);
    Difftestfinal(1) = Difftestfinal(2);
    arcLengthtest = Difftestfinal;
    % arcLengthtest = arcLength;
    k = ide(1);
    arcLengthtest([end-k+1:end 1:end-k]);
    arcLengthtest(k) = 0;
    arcLengthtest1 = arcLengthtest;

    % testing = arcLengthtest1(1:k-1);
    % testing = flip(testing);
    % arcLengthtest1(1:k-1) = testing;

    for j = k-1:-1:1
        arcLengthtest1(j) = arcLengthtest1(j+1) - arcLengthtest1(j);
    end

    for l = k+1:1:size(area,2)
        arcLengthtest1(l) = arcLengthtest1(l) + arcLengthtest1(l-1);
    end

    % Automate the part where it knows where the carina is
    % and shows the distance of airway from the carina
    yu = numel(finalbronchi2)- numel(finalbronchi1);
    % x1 = arcLengthtest1(idb(1):h-1);
    % x2 = arcLengthtest1(idb(1):ide(1));
    x3 = arcLengthtest1(idb(1):ide(1));
    x4 = arcLengthtest1(idb(2):ide(2)-1);
    x5 = arcLengthtest1(idb(2)+1:ide(2)+yu);
    x6 = arcLengthtest1((idb(3):ide(3)));
    Diff_x6 = diff(x6);
    b = 0;
    Difftestfinal_x6 = horzcat(b,Diff_x6);
    finalbronchi2 = area(idb(3):ide(3));
    %arcLengthtest_x6 = Difftestfinal_x6;
    Difftestfinal_x6(1) = x5(1);
    arcLengthtest_x6 = Difftestfinal_x6;

    for m = 2:numel(arcLengthtest_x6)
        arcLengthtest_x6(m) = arcLengthtest_x6(m) + arcLengthtest_x6(m-1);
    end
    
    figure; plot(Min_trachea_AL,Min_trachea_area,'LineWidth',3)
    hold on
    plot(Max_trachea_AL,Max_trachea_area,'LineWidth',3)
    hold on
    plot(Min_LB_AL,Min_LB_area,'LineWidth',3)
    hold on
    plot(Max_LB_AL,Max_LB_area,'LineWidth',3)
    hold on

    hold on
    plot(Min_RB_AL,Min_RB_area,'LineWidth',3)
    hold on
    plot(Max_RB_AL,Max_RB_area,'LineWidth',3)
    hold on
    
%     figure;
%     Patch1 = patch([Max_trachea_AL fliplr(Min_trachea_AL)],[Max_trachea_area fliplr(Min_trachea_area)],'cyan','LineStyle','none','FaceAlpha',0.5,'EdgeColor','green');
%     Patch2 = patch([Max_LB_AL fliplr(Min_LB_AL)],[Max_LB_area fliplr(Min_LB_area)],'magenta','LineStyle','none','FaceAlpha',0.5,'EdgeColor','black');
%     Patch3 = patch([Max_RB_AL fliplr(Min_RB_AL)],[Max_RB_area fliplr(Min_RB_area)],'blue','LineStyle','none','FaceAlpha',0.5,'EdgeColor','red');

    hold on
    plot(x3,finaltrachea,'g-*',x4,finalbronchi1,'black-*',arcLengthtest_x6,finalbronchi2,'red-*','LineWidth',1.25);
    
    title('P137');
    legend('Min-Max trachea area','Min-Max left bronchi area','Min-Max right bronchi area','Trachea','Left Bronchi','Right Bronchi');
    xlabel('Distance from Carina (mm)');
    ylabel('Cross sectional Area (mm^2)');
    ylim([0 60])
    xlim([-70 20])
    %[frame(i).cdata,frame(i).colormap] = getframe(gcf);
    

end
%%
for h = 2:numel(frame)
    writeVideo(myVideo,frame(h));
end