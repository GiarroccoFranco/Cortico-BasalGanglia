
function Left= FindDirection(TrialsMarkers)

    GoodChoice=TrialsMarkers.HighRewProbStimSelected; % 1 if monkey selected the most rew option
    GoodLeft=TrialsMarkers.HighRewProbStim_Left ;     % 1 if the most rew option is on the left
    GoodRight=TrialsMarkers.HighRewProbStim_Right;  % 1 if the most rew option is on the right


    Left=[];
    for lr=1:length(GoodChoice)
        if GoodChoice(lr)==1 && GoodLeft(lr)==1  || GoodChoice(lr)==0 && GoodRight(lr)==1
            Left(lr)=1;

        elseif GoodChoice(lr)==1 && GoodRight(lr)==1 || GoodChoice(lr)==0 &&  GoodLeft(lr)==1
            Left(lr)=0;
        end
    end
end