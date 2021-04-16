%% File Description
% Name:              generateGBFromInternalRepo.m
% Author:            hkg
% Last Edit Date:    12/7/20
% Purpose:           Translate internal NSF Career Repo to public facing Gazebase
%                    structure, which is distributed on Figshare
% Dependencies:      importasc, extractEventLabels
GazeBaseLocalPath='C:\Users\hkgri\Documents\NSFCareerDatasetTEAMSVersion';
targetFolder='C:\Users\hkgri\Documents\GazeBase';
labelFolder='EventLabelInfo';
round_folders = dir(GazeBaseLocalPath); %Grab all round folders within unzipped subdirectory
desired_round_folders=setdiff({round_folders.name},[{'.'},{'..'}]);
QATable=table;valFiles=0;
for h =1:length(desired_round_folders)  % ignore '.' and '..' directories
    round_folder = desired_round_folders{h}; %current round as formatted string
    round_path = fullfile(GazeBaseLocalPath, round_folder); %full path to current round
    round_num= str2double(round_folder(end)); %current as integer
    
    subject_folders = dir(round_path);
    desired_subject_folders=setdiff({subject_folders.name},[{'.'},{'..'}]); %all subjects in current round
    for i = 1:length(desired_subject_folders)  % ignore '.' and '..' directories
        subject_folder = desired_subject_folders{i}; %current compressed subject folder in string
        subject_path = fullfile(round_path, subject_folder); %full path to current zipped subject folder
        subject_path_local=extractBefore(subject_folder,'.'); %remove .zip extension
        subjID=str2double(subject_path_local(10:12));
        unzip(subject_path); %create a copy of the current subject directory in the local folder
        %ensure dataset is complete
        currentFilesfiles=dir([subject_path_local,'\**\*.asc']);
        validFiles=listValidFiles(round_num,subjID);
        missingFiles=any(~ismember(validFiles,{currentFilesfiles.name}));
        if missingFiles
            rmdir(subject_path_local,'s'); %delete incomplete local repo
            continue %move to next subject
        end 
        session_folders = dir(subject_path_local);
        session_folders=setdiff({session_folders.name},[{'.'},{'..'},{'SubjectLog.txt'}]); 
        for j = 1:length(session_folders)  
            session_folder = session_folders{j}; %current subject folder
            session_path = fullfile(subject_path_local, session_folder); %path of current subject folder in local copy

            task_folders = dir(session_path); %extract all task folders within local subject folder
            desired_task_folders=setdiff({task_folders.name},[{'.'},{'..'},{[session_folder,'_IRIS_Images']}]); 
            for k = 1:length(desired_task_folders)  % ignore '.' and '..' directories
                task_folder = desired_task_folders{k};
                task_path = fullfile(session_path, task_folder);
                task_paths=dir(task_path);
                sourceFileName=setdiff({task_paths.name},[{'.'},{'..'}]);
                sourceFile=importasc([task_path,'\',sourceFileName{1}]);
                sourceFileID=sourceFileName{1}(11:13);
               targetTable=sourceFile(:,[1,7,8,10,12,13,11]);
               %replace invalid samples with NaN
               targetTable.x=num2cell(targetTable.x);targetTable.y=num2cell(targetTable.y);targetTable.dP=num2cell(targetTable.dP);
               targetTable.x(targetTable.val~=0)={'NaN'};targetTable.y(targetTable.val~=0)={'NaN'};targetTable.dP(targetTable.val~=0)={'NaN'};
               %add on event labels...
               [eventLabels,fixTS,saccTS,blinkTS]=extractEventLabels([labelFolder,'\',sourceFileName{1}],targetTable.n(1),targetTable.n(end),sourceFileID);
               targetTable.lab=eventLabels;
               if (sourceFileID=='BLG' |...
                       sourceFileID=='VD1' | sourceFileID=='VD2')
                   %replace label values with NaNs
                   targetTable.lab=repmat({'NaN'},length(targetTable.x),1);
               end
               targetTable.n=targetTable.n-targetTable.n(1);%make time relative to experimental start
               if (sourceFileID=='BLG' | sourceFileID=='TEX' |...
                       sourceFileID=='VD1' | sourceFileID=='VD2')
                   %replace target values with NaNs
                  targetTable.xT=[];targetTable.yT=[];
                  targetTable.xT=repmat({'NaN'},length(targetTable.x),1);
                  targetTable.yT=repmat({'NaN'},length(targetTable.x),1);
               end
               %Create subset of source file for GazeBase re[p
                targetFileName=extractBefore(sourceFileName{1},'.');
                targetFilePath=[targetFolder,'\Round_',num2str(round_num),'\',session_path,'\',task_folder,'\'];
                mkdir(targetFilePath);
                writetable(targetTable,[targetFilePath,targetFileName,'.csv']);
                
                %reread file and check quality
%                 checkTable=readtable([targetFilePath,targetFileName,'.csv']);
%                 validTS=all(diff(checkTable.n)); %ensure that all ISIs are 1
%                 missingPositionCorr=(all(isnan(checkTable.x(checkTable.val~=0)))...
%                                & all(isnan(checkTable.y(checkTable.val~=0)))); %ensure that all invalid samples are marked as NaN
%                 validPositionCorr = (all(~isnan(checkTable.x(checkTable.val==0))) & ...
%                                      all(~isnan(checkTable.y(checkTable.val==0))));
%                 validPupilDiameter=all(checkTable.dP(~isnan(checkTable.dP)>0));
%                 %check valid targets for NaN tasks
%                 if(sourceFileID=='BLG' | sourceFileID=='TEX' |...
%                        sourceFileID=='VD1' | sourceFileID=='VD1')
%                    %target positions should all be NaNs
%                    validTargetValues= (all(isnan(checkTable.xT)) & ...
%                                      all(isnan(checkTable.yT)));
%                 else 
%                     %target positions shoudl contain no NaNs
%                     validTargetValues= (all(~isnan(checkTable.xT)) & ...
%                                      all(~isnan(checkTable.yT)));
%                 end
%                 validImport=validTS & missingPositionCorr & validPositionCorr & validTargetValues;
%                 if ~validImport
%                     pause;
%                 end
                
                %Store file info
                valFiles=valFiles+1; %incremental valid File counter
                FileNum(valFiles)=valFiles;
                FileName{valFiles}=[targetFileName,'.csv'];
                RoundNum(valFiles)=h;
                SessionNum(valFiles)=j;
                SubjID(valFiles)=subjID;
                Task{valFiles}=sourceFileID;
                Dur(valFiles)=max(targetTable.n);
                NumMissing(valFiles)=sum(targetTable.val~=0);
                PerMissing(valFiles)= 100*NumMissing(valFiles)/Dur(valFiles);
                notNaNind = find(cellfun(@isnumeric,targetTable.x) == 1);
                numX=cell2mat(targetTable.x(notNaNind));numY=cell2mat(targetTable.y(notNaNind));
                numdP=cell2mat(targetTable.dP(notNaNind));
                NumOOR(valFiles)=sum(numX>30|numX<-30|numY>20|numY<-20);
                PerOOR(valFiles)=100*NumOOR(valFiles)/Dur(valFiles);
                medianPD(valFiles)=median(numdP);
                minPD(valFiles)=min(numdP);
                maxPD(valFiles)=max(numdP);
                %added statistics for classification
                numBlinks(valFiles)=height(blinkTS);
                numSacc(valFiles)=height(saccTS);
                if ~isempty(fixTS)
                    avgFixDur(valFiles)=mean(fixTS(:,2)-fixTS(:,1))/1000;
                    minFixDur(valFiles)=min(fixTS(:,2)-fixTS(:,1))/1000;
                    maxFixDur(valFiles)=max(fixTS(:,2)-fixTS(:,1))/1000;
                else
                    avgFixDur(valFiles)=0;
                    minFixDur(valFiles)=0;
                    maxFixDur(valFiles)=0;
                end
                if ~isempty(saccTS)
                    avgSaccDur(valFiles)=mean(saccTS(:,2)-saccTS(:,1))/1000;
                    minSaccDur(valFiles)=min(saccTS(:,2)-saccTS(:,1))/1000;
                    maxSaccDur(valFiles)=max(saccTS(:,2)-saccTS(:,1))/1000;
                else
                    avgSaccDur(valFiles)=0;
                    minSaccDur(valFiles)=0;
                    maxSaccDur(valFiles)=0;
                end
            end
        end
        %zip file at per subject level
        zip(extractBefore(targetFilePath,'\S2\'),extractBefore(targetFilePath,'S2\'));
        %delete unzipped directory
        rmdir(extractBefore(targetFilePath,'\S2'),'s');
        %delete temporary local GazeBase directory
        rmdir(subject_path_local,'s');
    end
end
    FileNum=FileNum';FileName=FileName';RoundNum=RoundNum';SessionNum=SessionNum';SubjID=SubjID';
    Task=Task';Dur=Dur';NumMissing=NumMissing';PerMissing=PerMissing';NumOOR=NumOOR';PerOOR=PerOOR';
    medianPD=medianPD';minPD=minPD';maxPD=maxPD';numBlinks=numBlinks';numSacc=numSacc';avgFixDur=avgFixDur';avgSaccDur=avgSaccDur';
    minFixDur=minFixDur';minSaccDur=minSaccDur';maxFixDur=maxFixDur';maxSaccDur=maxSaccDur';
    SummaryTable=table(FileNum,FileName,RoundNum,SessionNum,SubjID,Task,...
                   Dur,NumMissing,PerMissing,NumOOR,PerOOR,medianPD,minPD,maxPD,...
                   numBlinks,numSacc,avgFixDur,avgSaccDur,minFixDur,minSaccDur,maxFixDur,maxSaccDur);
%    writetable(SummaryTable,['Round_', num2str(round_num),'_SummaryInfo.csv']);
    writetable(SummaryTable,'SummaryInfo.csv');

% clear FileNum FileName RoundNum SessionNum SubjID Task ...
%                    Dur NumMissing PerMissing NumOOR PerOOR medianPD minPD maxPD ...
%                    numBlinks numSacc avgFixDur avgSaccDur minFixDur minSaccDur maxFixDur maxSaccDur
% % Number of blinks for various tasks
% sgtitle('Distribution of Number of EL-Parsed Blinks Across R1 Recordings by Task');
% binBlinks=0:5:100;
% subplot(321);histogram(SummaryTable.numBlinks(strcmp(SummaryTable.Task,'FXS')),binBlinks);title('FXS');xlabel('# of Blinks');ylabel('# of R1 Rec.');
% subplot(322);histogram(SummaryTable.numBlinks(strcmp(SummaryTable.Task,'HSS')),binBlinks);title('HSS');xlabel('# of Blinks');ylabel('# of R1 Rec.');
% subplot(323);histogram(SummaryTable.numBlinks(strcmp(SummaryTable.Task,'RAN')),binBlinks);title('RAN');xlabel('# of Blinks');ylabel('# of R1 Rec.');
% subplot(324);histogram(SummaryTable.numBlinks(strcmp(SummaryTable.Task,'TEX')),binBlinks);title('TEX');xlabel('# of Blinks');ylabel('# of R1 Rec.');
% subplot(325);histogram(SummaryTable.numBlinks(strcmp(SummaryTable.Task,'VD1')),binBlinks);title('VD1');xlabel('# of Blinks');ylabel('# of R1 Rec.');
% subplot(326);histogram(SummaryTable.numBlinks(strcmp(SummaryTable.Task,'VD2')),binBlinks);title('VD2');xlabel('# of Blinks');ylabel('# of R1 Rec.');
% 
% % Number of saccades for various tasks
% binSacc=0:10:400;
% sgtitle('Distribution of Number of EL-Parsed Saccades Across R1 Recordings by Task'); 
% subplot(321);histogram(SummaryTable.numSacc(strcmp(SummaryTable.Task,'FXS')),binSacc);title('FXS');xlabel('# of Sacc');ylabel('# of R1 Rec.');
% subplot(322);histogram(SummaryTable.numSacc(strcmp(SummaryTable.Task,'HSS')),binSacc);title('HSS');xlabel('# of Sacc');ylabel('# of R1 Rec.');
% subplot(323);histogram(SummaryTable.numSacc(strcmp(SummaryTable.Task,'RAN')),binSacc);title('RAN');xlabel('# of Sacc');ylabel('# of R1 Rec.');
% subplot(324);histogram(SummaryTable.numSacc(strcmp(SummaryTable.Task,'TEX')),binSacc);title('TEX');xlabel('# of Sacc');ylabel('# of R1 Rec.');
% subplot(325);histogram(SummaryTable.numSacc(strcmp(SummaryTable.Task,'VD1')),binSacc);title('VD1');xlabel('# of Sacc');ylabel('# of R1 Rec.');
% subplot(326);histogram(SummaryTable.numSacc(strcmp(SummaryTable.Task,'VD2')),binSacc);title('VD2');xlabel('# of Sacc');ylabel('# of R1 Rec.');
% 
% 
% % Avg fixation duration for various tasks
% sgtitle('Distribution of EL-Parsed Average Fixation Duration Across R1 Recordings by Task'); 
% subplot(321);histogram(SummaryTable.avgFixDur(strcmp(SummaryTable.Task,'FXS')));title('FXS');xlabel('Fix. Dur (s)');ylabel('# of R1 Rec.');
% subplot(322);histogram(SummaryTable.avgFixDur(strcmp(SummaryTable.Task,'HSS')));title('HSS');xlabel('Fix. Dur (s)');ylabel('# of R1 Rec.');
% subplot(323);histogram(SummaryTable.avgFixDur(strcmp(SummaryTable.Task,'RAN')));title('RAN');xlabel('Fix. Dur (s)');ylabel('# of R1 Rec.');
% subplot(324);histogram(SummaryTable.avgFixDur(strcmp(SummaryTable.Task,'TEX')));title('TEX');xlabel('Fix. Dur (s)');ylabel('# of R1 Rec.');
% subplot(325);histogram(SummaryTable.avgFixDur(strcmp(SummaryTable.Task,'VD1')));title('VD1');xlabel('Fix. Dur (s)');ylabel('# of R1 Rec.');
% subplot(326);histogram(SummaryTable.avgFixDur(strcmp(SummaryTable.Task,'VD2')));title('VD2');xlabel('Fix. Dur (s)');ylabel('# of R1 Rec.');
% 
% % Min fixation duration for various tasks
% sgtitle('Distribution of EL-Parsed Minimum Fixation Duration Across R1 Recordings by Task'); 
% subplot(321);histogram(SummaryTable.minFixDur(strcmp(SummaryTable.Task,'FXS')));title('FXS');xlabel('Min. Fix. Dur (s)');ylabel('# of R1 Rec.');
% subplot(322);histogram(SummaryTable.minFixDur(strcmp(SummaryTable.Task,'HSS')));title('HSS');xlabel('Min. Fix. Dur (s)');ylabel('# of R1 Rec.');
% subplot(323);histogram(SummaryTable.minFixDur(strcmp(SummaryTable.Task,'RAN')));title('RAN');xlabel('Min. Fix. Dur (s)');ylabel('# of R1 Rec.');
% subplot(324);histogram(SummaryTable.minFixDur(strcmp(SummaryTable.Task,'TEX')));title('TEX');xlabel('Min. Fix. Dur (s)');ylabel('# of R1 Rec.');
% subplot(325);histogram(SummaryTable.minFixDur(strcmp(SummaryTable.Task,'VD1')));title('VD1');xlabel('Min. Fix. Dur (s)');ylabel('# of R1 Rec.');
% subplot(326);histogram(SummaryTable.minFixDur(strcmp(SummaryTable.Task,'VD2')));title('VD2');xlabel('Min. Fix. Dur (s)');ylabel('# of R1 Rec.');
% 
% % Max fixation duration for various tasks
% sgtitle('Distribution of EL-Parsed Maximum Fixation Duration Across R1 Recordings by Task'); 
% subplot(321);histogram(SummaryTable.maxFixDur(strcmp(SummaryTable.Task,'FXS')));title('FXS');xlabel('max. Fix. Dur (s)');ylabel('# of R1 Rec.');
% subplot(322);histogram(SummaryTable.maxFixDur(strcmp(SummaryTable.Task,'HSS')));title('HSS');xlabel('max. Fix. Dur (s)');ylabel('# of R1 Rec.');
% subplot(323);histogram(SummaryTable.maxFixDur(strcmp(SummaryTable.Task,'RAN')));title('RAN');xlabel('max. Fix. Dur (s)');ylabel('# of R1 Rec.');
% subplot(324);histogram(SummaryTable.maxFixDur(strcmp(SummaryTable.Task,'TEX')));title('TEX');xlabel('max. Fix. Dur (s)');ylabel('# of R1 Rec.');
% subplot(325);histogram(SummaryTable.maxFixDur(strcmp(SummaryTable.Task,'VD1')));title('VD1');xlabel('max. Fix. Dur (s)');ylabel('# of R1 Rec.');
% subplot(326);histogram(SummaryTable.maxFixDur(strcmp(SummaryTable.Task,'VD2')));title('VD2');xlabel('max. Fix. Dur (s)');ylabel('# of R1 Rec.');
% 
% 
% % Avg saccade duration for various tasks
% sgtitle('Distribution of EL-Parsed Average Saccade Duration Across R1 Recordings by Task'); 
% subplot(321);histogram(SummaryTable.avgSaccDur(strcmp(SummaryTable.Task,'FXS')).*1000);title('FXS');xlabel('Sacc. Dur (ms)');ylabel('# of R1 Rec.');
% subplot(322);histogram(SummaryTable.avgSaccDur(strcmp(SummaryTable.Task,'HSS')).*1000);title('HSS');xlabel('Sacc. Dur (ms)');ylabel('# of R1 Rec.');
% subplot(323);histogram(SummaryTable.avgSaccDur(strcmp(SummaryTable.Task,'RAN')).*1000);title('RAN');xlabel('Sacc. Dur (ms)');ylabel('# of R1 Rec.');
% subplot(324);histogram(SummaryTable.avgSaccDur(strcmp(SummaryTable.Task,'TEX')).*1000);title('TEX');xlabel('Sacc. Dur (ms)');ylabel('# of R1 Rec.');
% subplot(325);histogram(SummaryTable.avgSaccDur(strcmp(SummaryTable.Task,'VD1')).*1000);title('VD1');xlabel('Sacc. Dur (ms)');ylabel('# of R1 Rec.');
% subplot(326);histogram(SummaryTable.avgSaccDur(strcmp(SummaryTable.Task,'VD2')).*1000);title('VD2');xlabel('Sacc. Dur (ms)');ylabel('# of R1 Rec.');
% 
% % Min saccade duration for various tasks
% sgtitle('Distribution of EL-Parsed Minimum Saccade Duration Across R1 Recordings by Task'); 
% subplot(321);histogram(SummaryTable.minSaccDur(strcmp(SummaryTable.Task,'FXS')).*1000);title('FXS');xlabel('Min. Sacc. Dur (ms)');ylabel('# of R1 Rec.');
% subplot(322);histogram(SummaryTable.minSaccDur(strcmp(SummaryTable.Task,'HSS')).*1000);title('HSS');xlabel('Min. Sacc. Dur (ms)');ylabel('# of R1 Rec.');
% subplot(323);histogram(SummaryTable.minSaccDur(strcmp(SummaryTable.Task,'RAN')).*1000);title('RAN');xlabel('Min. Sacc. Dur (ms)');ylabel('# of R1 Rec.');
% subplot(324);histogram(SummaryTable.minSaccDur(strcmp(SummaryTable.Task,'TEX')).*1000);title('TEX');xlabel('Min. Sacc. Dur (ms)');ylabel('# of R1 Rec.');
% subplot(325);histogram(SummaryTable.minSaccDur(strcmp(SummaryTable.Task,'VD1')).*1000);title('VD1');xlabel('Min. Sacc. Dur (ms)');ylabel('# of R1 Rec.');
% subplot(326);histogram(SummaryTable.minSaccDur(strcmp(SummaryTable.Task,'VD2')).*1000);title('VD2');xlabel('Min. Sacc. Dur (ms)');ylabel('# of R1 Rec.');
% 
% % Max saccade duration for various tasks
% sgtitle('Distribution of EL-Parsed Maximum Saccade Duration Across R1 Recordings by Task'); 
% subplot(321);histogram(SummaryTable.maxSaccDur(strcmp(SummaryTable.Task,'FXS')).*1000);title('FXS');xlabel('Max. Sacc. Dur (ms)');ylabel('# of R1 Rec.');
% subplot(322);histogram(SummaryTable.maxSaccDur(strcmp(SummaryTable.Task,'HSS')).*1000);title('HSS');xlabel('Max. Sacc. Dur (ms)');ylabel('# of R1 Rec.');
% subplot(323);histogram(SummaryTable.maxSaccDur(strcmp(SummaryTable.Task,'RAN')).*1000);title('RAN');xlabel('Max. Sacc. Dur (ms)');ylabel('# of R1 Rec.');
% subplot(324);histogram(SummaryTable.maxSaccDur(strcmp(SummaryTable.Task,'TEX')).*1000);title('TEX');xlabel('Max. Sacc. Dur (ms)');ylabel('# of R1 Rec.');
% subplot(325);histogram(SummaryTable.maxSaccDur(strcmp(SummaryTable.Task,'VD1')).*1000);title('VD1');xlabel('Max. Sacc. Dur (ms)');ylabel('# of R1 Rec.');
% subplot(326);histogram(SummaryTable.maxSaccDur(strcmp(SummaryTable.Task,'VD2')).*1000);title('VD2');xlabel('Max. Sacc. Dur (ms)');ylabel('# of R1 Rec.');
% 
% 




