        function DrawMat=draw(DrawMat,myRCNN)
            %»æÖÆ½¨Òé¿ò
            [bbox, score, label] = detect(myRCNN, DrawMat, 'MiniBatchSize', 20);
            idx=find(score>0.1);
            bbox = bbox(idx, :);
            n=size(idx,1);
            for i=1:n
                annotation = sprintf('%s: (Confidence = %f)');%, label(idx(i)), score(idx(i)));
                DrawMat = insertObjectAnnotation(DrawMat, 'rectangle', bbox(i,:), annotation);
            end
        end
        
