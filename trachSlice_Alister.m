function [arcLength, area, goodpos, missedPlane] = trachSlice_Alister(STLfilename,VTKfilename,znormal)

    %znormal = true;
    if nargin == 2
        znormal = false;
    end

    %Read in stl
    display('Reading in STL');
    [Vsurface,Fsurface,~] = STL_Import(STLfilename);
    display('Done reading in STL');
    
    %Read in VTK file
    [pos, face] = read_vtk(VTKfilename);

    pos = pos';
    
    pos = pos(end:-1:1,:);   
    
    if znormal == false
        % TODO: True line-tangents (which are plane-normals) can be imported from VMTK instead of this.
        normals = pos(2,:) - pos(1,:);

        for i = 2:size(pos,1) - 1

            normals(i,:) = pos(i+1,:) - pos(i-1,:);

        end

        normals(end+1,:) = pos(end,:) - pos(end-1,:);
    else
        for i = 1:size(pos,1)
            normals(i,:) = [ 0 1 0]; % This has been changed for the balloon experiment - should be [ 0 0 1]        
        end
    end
    
    nodes = [];
    tri = [];
    j = 1;
    missedPlane = [];
        
    for i = 1:size(pos,1)
         display(['Testing Plane number ', num2str(i), ', of ', num2str(size(pos,1))]);
         %[area(i), centroid(i,:), nodes(i,:), tri(i,:)] = sublobeMulti(normals(i,:), pos(i,:), Vsurface, Fsurface, 1000000);
         [currentArea, currentCentroid, nodeCell, triCell] = sublobeMulti(normals(i,:), pos(i,:), Vsurface, Fsurface, i);
         
         if currentArea{1} == -1
            missedPlane = [missedPlane i]; 
            continue; 
         end
         
         goodpos(j,:) = pos(i,:);
     
         if isempty(currentCentroid{3})
             if isempty(currentCentroid{1})
                 if isempty(currentCentroid{2})
                     warning('No area detected');
                     continue
                 else
                     sideToUse = 2;
                 end
             else
                 if isempty(currentCentroid{2})
                     sideToUse = 1;
                 else
                    if norm(goodpos(j,:) - currentCentroid{1}) < norm(goodpos(j,:) - currentCentroid{2})
                        sideToUse = 1;
                    else
                        sideToUse = 2;
                    end
                 end
             end
                currentCentroid{3} = currentCentroid{sideToUse};
                currentArea{3} = currentArea{sideToUse};
                nodeCell{3} = nodeCell{sideToUse};
                triCell{3} = triCell{sideToUse};
         end
         
         centroid(j,:) = currentCentroid{3};
         area(j) = currentArea{3};
         
         nodesSeparate{j} = nodeCell{3};
         triSeparate{j} = triCell{3};
         triCell{3} = triCell{3} + size(nodes,1);
         nodes = [nodes; nodeCell{3}];
         tri = [tri; triCell{3}];
         
         j = j + 1;
    end
    
    arcLength(size(goodpos,1)) = 0.0;
    for i = 2:size(goodpos,1)
        arcLength(i) = arcLength(i-1) + norm(goodpos(i,:) - goodpos(i-1,:));
    end
       
    if max(arcLength) < 1
        % Data is in m, convert to mm
        arcLength = arcLength .* 1000; 
        area = area .* 1e6; %   m^2 to mm^2   
    end
    
    dataToWrite(:,1) = arcLength(end:-1:1)';
    dataToWrite(:,2) = area(end:-1:1);    
    
    csvwrite([STLfilename(1:end-4) '-Data' '.csv'], dataToWrite);
    TestArcLength = arcLength';
    TestArea = area';
    save([STLfilename(1:end-4) '-ArcLength.mat'], 'TestArcLength');
    save([STLfilename(1:end-4) '-Area.mat'], 'TestArea');
    stlwrite([STLfilename(1:end-4) '-Planes-All' '.stl'], tri, nodes);
    for i = 1:size(goodpos,1)
        stlwrite([STLfilename(1:end-4) '-Planes-' num2str(i, '%03d') '.stl'], triSeparate{i}, nodesSeparate{i});
    end    
end
