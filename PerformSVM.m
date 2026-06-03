
function Accuracy=PerformSVM(DecData,Trials,Label)

for  bin= 1:size(DecData,2)

    Dat=DecData{1,bin};
    if ~isempty(Dat)

        DataC=Dat(:,Trials)';
        Mdl = fitcsvm(DataC,Label,"Prior","uniform",'KernelFunction','linear',KFold=10);
        Accuracy(bin) = 1-kfoldLoss(Mdl);
    
    elseif isempty(Dat)
        Accuracy(bin) =NaN;
    end



end


end