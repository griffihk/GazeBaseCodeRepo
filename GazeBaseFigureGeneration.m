%% File Description
% Name:              GazeBaseFigureGeneration
% Author:            hkg
% Last Edit Date:    3/24/21
% Purpose:           Generates figures 2-4 for GB from val data
% Dependencies:      ValData.mat, savePDF

%Load Figure Data
load Ages.mat; load ValData.mat;

%% Generate Figure 2
figure(2);
histogram(Age)
xlabel('Participant Age Upon Enrollment in Study (Years)');
ylabel('Number of Participants (N=322)');
savePDF('','Figure2')

%% Generate Figure 3
%combine data across rounds
Round1AllTasksAvg=[Round1(:,1);Round1(:,3);Round1(:,5);Round1(:,7);Round1(:,9);...
    Round1(:,11);Round1(:,13);Round1(:,15);Round1(:,17);Round1(:,19);...
    Round1(:,21);Round1(:,23);Round1(:,25);Round1(:,27)];
Round2AllTasksAvg=[Round2(:,1);Round2(:,3);Round2(:,5);Round2(:,7);Round2(:,9);...
    Round2(:,11);Round2(:,13);Round2(:,15);Round2(:,17);Round2(:,19);...
    Round2(:,21);Round2(:,23);Round2(:,25);Round2(:,27)];
Round3AllTasksAvg=[Round3(:,1);Round3(:,3);Round3(:,5);Round3(:,7);Round3(:,9);...
    Round3(:,11);Round3(:,13);Round3(:,15);Round3(:,17);Round3(:,19);...
    Round3(:,21);Round3(:,23);Round3(:,25);Round3(:,27)];
Round4AllTasksAvg=[Round4(:,1);Round4(:,3);Round4(:,5);Round4(:,7);Round4(:,9);...
    Round4(:,11);Round4(:,13);Round4(:,15);Round4(:,17);Round4(:,19);...
    Round4(:,21);Round4(:,23);Round4(:,25);Round4(:,27)];
Round5AllTasksAvg=[Round5(:,1);Round5(:,3);Round5(:,5);Round5(:,7);Round5(:,9);...
    Round5(:,11);Round5(:,13);Round5(:,15);Round5(:,17);Round5(:,19);...
    Round5(:,21);Round5(:,23);Round5(:,25);Round5(:,27)];
Round6AllTasksAvg=[Round6(:,1);Round6(:,3);Round6(:,5);Round6(:,7);Round6(:,9);...
    Round6(:,11);Round6(:,13);Round6(:,15);Round6(:,17);Round6(:,19);...
    Round6(:,21);Round6(:,23);Round6(:,25);Round6(:,27)];
Round7AllTasksAvg=[Round7(:,1);Round7(:,3);Round7(:,5);Round7(:,7);Round7(:,9);...
    Round7(:,11);Round7(:,13);Round7(:,15);Round7(:,17);Round7(:,19);...
    Round7(:,21);Round7(:,23);Round7(:,25);Round7(:,27)];
Round8AllTasksAvg=[Round8(:,1);Round8(:,3);Round8(:,5);Round8(:,7);Round8(:,9);...
    Round8(:,11);Round8(:,13);Round8(:,15);Round8(:,17);Round8(:,19);...
    Round8(:,21);Round8(:,23);Round8(:,25);Round8(:,27)];
Round9AllTasksAvg=[Round9(:,1);Round9(:,3);Round9(:,5);Round9(:,7);Round9(:,9);...
    Round9(:,11);Round9(:,13);Round9(:,15);Round9(:,17);Round9(:,19);...
    Round9(:,21);Round9(:,23);Round9(:,25);Round9(:,27)];
labels={'R1','R2','R3','R4','R5','R6','R7','R8','R9'};
g1 = repmat({'First'},length(Round1AllTasksAvg),1);
g2 = repmat({'Second'},length(Round2AllTasksAvg),1);
g3 = repmat({'Third'},length(Round3AllTasksAvg),1);
g4 = repmat({'Fourth'},length(Round4AllTasksAvg),1);
g5 = repmat({'Fifth'},length(Round5AllTasksAvg),1);
g6 = repmat({'Sixth'},length(Round6AllTasksAvg),1);
g7 = repmat({'Seventh'},length(Round7AllTasksAvg),1);
g8 = repmat({'Eighth'},length(Round8AllTasksAvg),1);
g9 = repmat({'Ninth'},length(Round9AllTasksAvg),1);

figure(3);
boxplot([Round1AllTasksAvg;Round2AllTasksAvg;Round3AllTasksAvg;Round4AllTasksAvg;...
    Round5AllTasksAvg;Round6AllTasksAvg;Round7AllTasksAvg;Round8AllTasksAvg;...
    Round9AllTasksAvg],[g1;g2;g3;g4;g5;g6;g7;g8;g9],'Labels',labels)
xlabel('Round ID');
ylabel('Average Validation Error (dva)');
%saveas(gcf,'Figure3.pdf')
savePDF('','Figure3')

%% Generate Figure 4
%Max Figure
Round1AllTasksMax=[Round1(:,2);Round1(:,4);Round1(:,6);Round1(:,8);Round1(:,10);...
    Round1(:,12);Round1(:,14);Round1(:,16);Round1(:,18);Round1(:,20);...
    Round1(:,22);Round1(:,24);Round1(:,26);Round1(:,28)];
Round2AllTasksMax=[Round2(:,2);Round2(:,4);Round2(:,6);Round2(:,8);Round2(:,10);...
    Round2(:,12);Round2(:,14);Round2(:,16);Round2(:,18);Round2(:,20);...
    Round2(:,22);Round2(:,24);Round2(:,26);Round2(:,28)];
Round3AllTasksMax=[Round3(:,2);Round3(:,4);Round3(:,6);Round3(:,8);Round3(:,10);...
    Round3(:,12);Round3(:,14);Round3(:,16);Round3(:,18);Round3(:,20);...
    Round3(:,22);Round3(:,24);Round3(:,26);Round3(:,28)];
Round4AllTasksMax=[Round4(:,2);Round4(:,4);Round4(:,6);Round4(:,8);Round4(:,10);...
    Round4(:,12);Round4(:,14);Round4(:,16);Round4(:,18);Round4(:,20);...
    Round4(:,22);Round4(:,24);Round4(:,26);Round4(:,28)];
Round5AllTasksMax=[Round5(:,2);Round5(:,4);Round5(:,6);Round5(:,8);Round5(:,10);...
    Round5(:,12);Round5(:,14);Round5(:,16);Round5(:,18);Round5(:,20);...
    Round5(:,22);Round5(:,24);Round5(:,26);Round5(:,28)];
Round6AllTasksMax=[Round6(:,2);Round6(:,4);Round6(:,6);Round6(:,8);Round6(:,10);...
    Round6(:,12);Round6(:,14);Round6(:,16);Round6(:,18);Round6(:,20);...
    Round6(:,22);Round6(:,24);Round6(:,26);Round6(:,28)];
Round7AllTasksMax=[Round7(:,2);Round7(:,4);Round7(:,6);Round7(:,8);Round7(:,10);...
    Round7(:,12);Round7(:,14);Round7(:,16);Round7(:,18);Round7(:,20);...
    Round7(:,22);Round7(:,24);Round7(:,26);Round7(:,28)];
Round8AllTasksMax=[Round8(:,2);Round8(:,4);Round8(:,6);Round8(:,8);Round8(:,10);...
    Round8(:,12);Round8(:,14);Round8(:,16);Round8(:,18);Round8(:,20);...
    Round8(:,22);Round8(:,24);Round8(:,26);Round8(:,28)];
Round9AllTasksMax=[Round9(:,2);Round9(:,4);Round9(:,6);Round9(:,8);Round9(:,10);...
    Round9(:,12);Round9(:,14);Round9(:,16);Round9(:,18);Round9(:,20);...
    Round9(:,22);Round9(:,24);Round9(:,26);Round9(:,28)];
labels={'R1','R2','R3','R4','R5','R6','R7','R8','R9'};
g1 = repmat({'First'},length(Round1AllTasksMax),1);
g2 = repmat({'Second'},length(Round2AllTasksMax),1);
g3 = repmat({'Third'},length(Round3AllTasksMax),1);
g4 = repmat({'Fourth'},length(Round4AllTasksMax),1);
g5 = repmat({'Fifth'},length(Round5AllTasksMax),1);
g6 = repmat({'Sixth'},length(Round6AllTasksMax),1);
g7 = repmat({'Seventh'},length(Round7AllTasksMax),1);
g8 = repmat({'Eighth'},length(Round8AllTasksMax),1);
g9 = repmat({'Ninth'},length(Round9AllTasksMax),1);
figure(4);
boxplot([Round1AllTasksMax;Round2AllTasksMax;Round3AllTasksMax;Round4AllTasksMax;...
    Round5AllTasksMax;Round6AllTasksMax;Round7AllTasksMax;Round8AllTasksMax;...
    Round9AllTasksMax],[g1;g2;g3;g4;g5;g6;g7;g8;g9],'Labels',labels)
xlabel('Round ID');
ylabel('Maximum Validation Error (dva)');
savePDF('','Figure4')
