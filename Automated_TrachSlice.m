%% Code for Automated TrachSlice
%Get the STL file name
I = dir;
I(1:2) = [];
test = strsplit(I(1).name,'.');
subject = test{1,1};

%Run the VMTK centerline command
% command should be in the form: VMTK-python arg1 (python code) arg2 (STL
% name without extension)
command = "C:/Users/GAN5EH/AppData/Local/Continuum/vmtk/python C:/Users/GAN5EH/Python_scripts/tracheaCentreline_pypesDG_testing.py";
stl_folder = I.folder;
newChr = strrep(stl_folder,'\','/');
Final_command = strcat(command +" ",newChr+"/",subject);
system(Final_command)

%%
%Run trachSlice code
STLfilename = strcat(subject,'.stl');
VTKfilename = strcat(subject, '_centerline_geoinfo.vtk');
mkdir('Sliced_planes');
cd('Sliced_planes');
[arcLength, area, goodpos, missedPlane] = trachSlice_Alister(STLfilename,VTKfilename);
filenameStart= STLfilename(1:end-4);

%Get various parameters
[perimeter, hydDiam, diameter] = PerimeterandhydDiamCalc(filenameStart, size(goodpos,1), true);
RD = diameter(:,2)./diameter(:,1);
save([filenameStart '-RD.mat'], 'RD');

%Save data and write it to a csv file
dataToWrite(:,1) = arcLength';
dataToWrite(:,2) = area';
dataToWrite(:,3) = hydDiam;
dataToWrite(:,4) = diameter(:,1);
dataToWrite(:,5) = diameter(:,2);
dataToWrite(:,6) = RD;
dataToWrite(:,7) = perimeter;

Data = [STLfilename(1:end-4) '-Data' '.csv'];

csvwrite(Data, dataToWrite);

fid = fopen(Data, 'wt');
fprintf(fid, '%s,%s,%s,%s,%s,%s,%s\n', 'Arc Length','Area','Hydraulic Diameter','Major Diameter','Minor Diameter','Ratio of Diameters','Perimeter');
fprintf(fid, '%g,%g,%g,%g,%g,%g,%g\n', dataToWrite.');   %transpose is important!
fclose(fid);