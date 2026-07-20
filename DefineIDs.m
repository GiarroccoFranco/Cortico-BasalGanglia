function [IDs]= DefineIDs (N_Block,Stimulus)
% function that returns the stimuli/images ID based on the number of blocks
% and the monkeys's choice behavior
MaxID=numel(unique(N_Block))*2;
PossibleID(:,1)=1:2:MaxID;
PossibleID(:,2)=2:2:MaxID;

p=1;

for id=1:length(N_Block)

    if id==1
        B(id)=(N_Block(id)); S=(Stimulus(id));

        if S==1
            IDs(id)=PossibleID(p,1);
        elseif S==0
            IDs(id)=PossibleID(p,2);
        end
    end

    if id>1 && id<=length(N_Block)
        B(id)=(N_Block(id)); S=(Stimulus(id));

        if B(id)==B(id-1)
            if S==1
                IDs(id)=PossibleID(p,1);
            elseif S==0
                IDs(id)=PossibleID(p,2);
            end
        elseif B(id)<B(id-1) || B(id)>B(id-1)
            p=p+1;
            if S==1
                IDs(id)=PossibleID(p,1);
            elseif S==0
                IDs(id)=PossibleID(p,2);
            end
        end

    end
end

end