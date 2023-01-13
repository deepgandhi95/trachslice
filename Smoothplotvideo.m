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
load('JasonVideo_Min_Max.mat');
% Patch1 = patch([x_plot fliplr(x_plot)], [y1 fliplr(y2)],'cyan','LineStyle','none','FaceAlpha',0.5,'EdgeColor','green');
% Patch2 = patch([x_plot_1 fliplr(x_plot_1)], [y1_1 fliplr(y2_1)],'magenta','LineStyle','none','FaceAlpha',0.5,'EdgeColor','black');
% Patch3 = patch([x_plot_2 fliplr(x_plot_2)], [y1_2 fliplr(y2_2)],'blue','LineStyle','none','FaceAlpha',0.5,'EdgeColor','red');

myVideo = VideoWriter('PlotTest2'); %open video file
myVideo.FrameRate = 50;%round((numel(VTKdir)-1)/2);  %can adjust this, 5 - 10 works well for me
open(myVideo)
    
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
        finalmouth = area(idb(1):ide(1));
        finaltrachea = area(idb(2):ide(2));
        finalbronchi1 = area(idb(3):ide(3)-1);
        finalbronchi2 = area(idb(4)+1:ide(4));

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
    figure;
    Patch1 = patch([x_plot fliplr(x_plot)], [y1 fliplr(y2)],'cyan','LineStyle','none','FaceAlpha',0.5,'EdgeColor','green');
    Patch2 = patch([x_plot_1 fliplr(x_plot_1)], [y1_1 fliplr(y2_1)],'magenta','LineStyle','none','FaceAlpha',0.5,'EdgeColor','black');
    Patch3 = patch([x_plot_2 fliplr(x_plot_2)], [y1_2 fliplr(y2_2)],'blue','LineStyle','none','FaceAlpha',0.5,'EdgeColor','red');

    hold on
    plot(x3,finaltrachea,'g-*',x4,finalbronchi1,'black-*',arcLengthtest_x6,finalbronchi2,'red-*','LineWidth',1.25);
    
    title('P137');
    legend('Min-Max trachea area','Min-Max left bronchi area','Min-Max right bronchi area','Trachea','Left Bronchi','Right Bronchi');
    xlabel('Distance from Carina (mm)');
    ylabel('Cross sectional Area (mm^2)');
    ylim([0 60])
    xlim([-70 20])
    [frame(i).cdata,frame(i).colormap] = getframe(gcf);
    

end

for h = 2:numel(frame)
    writeVideo(myVideo,frame(h));
end

cd ..
toc

save VideoTest_1.mat
%% Median Wave Plotting 

G = csvread('137_AirFlowRates.csv');
x = G(:,1);
y = G(:,2);
plot(x,y);
t = 0;
yline(t)
xlabel('Time (s)');
ylabel('Air flow rate (ml/s)');
title('Breathing cycle');
hold on
p = plot(x(1),y(1),'o','MarkerFaceColor','red');

hold off
myVideo = VideoWriter('Pointer-1'); %open video file
myVideo.FrameRate =  100; %can adjust this, 5 - 10 works well for me
open(myVideo)

for k = 1:length(x)-1
    p.XData = x(k);
    p.YData = y(k);
    [frame(k).cdata,frame(k).colormap] = getframe(gcf);
    drawnow
end

% for k = 19:length(x)-1
%     a = x(k);
%     b = y(k);
%     p1 = [a b];
%     p2 = [0 0];
%     dp = p2-p1;
%     quiver(p1(1),p1(2),dp(1),dp(2),0)
% %     [frame(k).cdata,frame(k).colormap] = getframe(gcf);
% %     drawnow
% end

for r = 1:numel(frame)
    writeVideo(myVideo,frame(r));
end

close(myVideo)

%% Plotting results as a range

ARCLENGTH = zeros(size(arcLength,2),numel(arcLength_test));
for d = 1:numel(arcLength_test)
    ARCLENGTH(:,d) = arcLength_test{d,1}(1,:);
end

% Area

AREA = zeros(size(area,2),numel(area_test));
for d = 1:numel(area_test)
    AREA(:,d) = area_test{d,1}(1,:);
end

%% Plotting the min and max of the area vs arclength plot
Max_area = [];
Min_area = [];

for i = 1:size(AREA,1)
    Max_area = [Max_area max(AREA(i,:))];
    Min_area = [Min_area min(AREA(i,:))];
end


%%
% Max_area = AREA(:,1)';
% Min_area = AREA(:,2)';

Area = Max_area;
Arclength = arcLength_test{2,1};
[x3,finaltrachea,x4,finalbronchi1,arcLengthtest_x6,finalbronchi2] = AirwayLabels(Arclength,Area);
finaltrachea_max = finaltrachea;
finalbronchi1_max = finalbronchi1;
finalbronchi2_max = finalbronchi2;

%figure; plot(x3,finaltrachea_max,'g-',x4,finalbronchi1_max,'black-',arcLengthtest_x6,finalbronchi2_max,'red-','LineWidth',2);
Area = Min_area;
[x3,finaltrachea,x4,finalbronchi1,arcLengthtest_x6,finalbronchi2] = AirwayLabels(Arclength,Area);
finaltrachea_min = finaltrachea;
finalbronchi1_min = finalbronchi1;
finalbronchi2_min = finalbronchi2;
%hold on;
%plot(x3,finaltrachea_min,'g-',x4,finalbronchi1_min,'black-',arcLengthtest_x6,finalbronchi2_min,'red-','LineWidth',2);


%%
x_plot = x3;
y1 = finaltrachea_max;
y2 = finaltrachea_min;
Patch1 = patch([x_plot fliplr(x_plot)], [y1 fliplr(y2)],'cyan','LineStyle','none','FaceAlpha',0.5,'EdgeColor','green');

x_plot_1 = x4;
y1_1 = finalbronchi1_max;
y2_1 = finalbronchi1_min;
Patch2 = patch([x_plot_1 fliplr(x_plot_1)], [y1_1 fliplr(y2_1)],'magenta','LineStyle','none','FaceAlpha',0.5,'EdgeColor','black');

x_plot_2 = arcLengthtest_x6;
y1_2 = finalbronchi2_max;
y2_2 = finalbronchi2_min;
Patch3 = patch([x_plot_2 fliplr(x_plot_2)], [y1_2 fliplr(y2_2)],'blue','LineStyle','none','FaceAlpha',0.5,'EdgeColor','red');

%legend('Trachea-Peak INS area','Left Bronchi-Peak INS area','Right Bronchi-Peak INS area','Trachea-Peak EXP area','Left Bronchi-Peak EXP area','Right Bronchi-Peak EXP area');
title('P137');
xlabel('Distance from Carina (mm)');
ylabel('Cross sectional Area (mm^2)');
legend('Trachea-Max area','Left Bronchi-Max area','Right Bronchi-Max area','Trachea-Min area','Left Bronchi-Min area','Right Bronchi-Min area','Max Trachea Area','Max Left Bronchi Area','Max Right Bronchi Area');
%%

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
    
for i = 1:numel(VTKdir)
    STLfilename = STLdir(i).name;
    VTKfilename = VTKdir(i).name;
    [arcLength, area, pos, centroid, goodpos, missedPlane] = trachSlice(STLfilename,VTKfilename);
    arcLength_test{i,1} = arcLength;
    area_test{i,1} = area;
    missedPlane_test{i,1} = missedPlane;
    goodpos_test{i,1} = goodpos;
end

% Check if Number of planes is equal 

save JasonVideo.mat

arcLength_test{43,1}(1,110) = NaN;
arcLength_test{44,1}(1,110) = NaN;
arcLength_test{45,1}(1,110) = NaN;
arcLength_test{46,1}(1,110) = NaN;
arcLength_test{47,1}(1,110) = NaN;

area_test{43,1}(1,110) = NaN;
area_test{44,1}(1,110) = NaN;
area_test{45,1}(1,110) = NaN;
area_test{46,1}(1,110) = NaN;
area_test{47,1}(1,110) = NaN;
%%
ARCLENGTH = zeros(size(arcLength,2),numel(arcLength_test));
for d = 1:numel(arcLength_test)
    ARCLENGTH(:,d) = arcLength_test{d,1}(1,:);
end

AREA = zeros(size(area,2),numel(area_test));
for d = 1:numel(area_test)
    AREA(:,d) = area_test{d,1}(1,:);
end

% Plotting the min and max of the area vs arclength plot
Max_area = [];
Min_area = [];

for i = 1:size(AREA,1)
    Max_area = [Max_area max(AREA(i,:))];
    Min_area = [Min_area min(AREA(i,:))];
end

