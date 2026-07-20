function  [ dat ]=CreateDataRegression_2( SessionData, Trials,  TimeStamp, Area)
Channels=SessionData.GoodChannels;
dat=[];
if isempty(Area)
    for t= 1:length(TimeStamp)
        dat=[];
    end
elseif ~isempty(Area)
    %     for t= 1:size(SessionData.Ch{1, 1}{1,1},1  )
    n_Chs_Area=find(ismember(Channels,Area)==1);

    TotUnitsSess_Area=0;
    for c=1:numel(n_Chs_Area)
        N_Neurons=SessionData.Ch{n_Chs_Area(c)};
        if  ~iscell(N_Neurons)
            N_NeuronsGivenCh=1;
        else
            N_NeuronsGivenCh=length(N_Neurons);
        end

        for i= 1 : N_NeuronsGivenCh

            TotUnitsSess_Area=TotUnitsSess_Area+1;

            Unit=[]; ZSUnit=[];
            Unit=SessionData.Ch{1,n_Chs_Area(c)};
            
            n_unit=Unit{1,i};
            ZSUnit=zscore(n_unit(Trials,:),1,'all');
            % y=[];
            % for t= 1:length(TimeStamp)
            % 
            %     y(:,t)=mean(n_unit(:,TimeStamp(t)),2);
            % 
            % end
            % ZSUnit=zscore(y(Trials,:),1,"All");


            % for trial=1:size(ZSUnit,1)
            %     y(trial)=mean(ZSUnit(trial,TimeStamp(t):TimeStamp(t)+10));
            % end
            %             for tt=1:size(ZSUnit,1)

            dat(:,:,TotUnitsSess_Area)=ZSUnit;

            %             end

        end
    end
    %         DecData{t}=dat;
    %
    %     end
end


end


