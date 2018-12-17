% Haiyan Wu 02/02/2016 
%Clear memory and the command window

clear all;

clc;

% Path to the parent folder, which contains the data folders for all subjects
home_path  = 'D:\SocialConformity\process\';
pdf_path = 'D:\SocialConformity\process\figures\';


% Initialize the ALLERP structure and CURRENTERP

ALLERP = buildERPstruct([]);

CURRENTERP = 0;


% This defines the set of subjects  exclude 1 2'34',for i = [1:6,8,9,11:22]
subject_list = {'5','6','7','9','22','23','25','26','27','29','30','31','33','34','35','36','37','38','39','42','45'}%

%%SAD group ['3','4','8','10','11','12','13','14','15','16','17','18','19','20','21','28','32','40','41','43','44','46']
%%Control group ['5','6','7','9','22','23','25','26','27','29','30','31','33','34','35','36','37','38','39','42','45']
nsubj = length(subject_list); % number of subjects

 



 

% Set the save_everything variable to 1 to save all of the intermediate files to the hard drive

% Set to 0 to save only the initial and final dataset and ERPset for each subject

save_everything  = 1;

 

% Set the plot_PDFs variable to 1 to create PDF files with the waveforms

% for each subject (set to 0 if you don't want to create the PDF files).

plot_PDFs = 1;

 

% Loop through all subjects

for s=1:nsubj

   

    fprintf('\n******\nProcessing subject %s\n******\n\n', subject_list{s});

 

    % Path to the folder containing the current subject's data

    data_path  = [home_path];

 

    % Check to make sure the dataset file exists

    % Initial filename = path plus Subject#.set

    sname = [subject_list,'.set'];

%     if exist(sname, 'file')<=0
% 
%             fprintf('\n *** WARNING: %s does not exist *** \n', sname);
% 
%             fprintf('\n *** Skip all processing for this subject *** \n\n');
% 
%     else

        %

        % Load original dataset

        %

        fprintf('\n\n\n**** %s: Loading dataset ****\n\n\n', subject_list{s});

        EEG = pop_loadset('filename', [subject_list{s} '.set'], 'filepath', data_path);

 

        %

        % Add the channel locations

        % We're assuming the file 'standard-10-5-cap385.elp' is somewhere

        % in the path.  This can be copied from

        % plugins/dipfit2.2/standard_BESA/ inside the eeglab

        % folder.

        %

        fprintf('\n\n\n**** %s: Adding channel location info ****\n\n\n', subject_list{s});

        EEG = pop_chanedit(EEG, 'lookup','standard-10-5-cap385.elp');                
        
%     EEG.data(ismember({EEG.chanlocs.labels},'R_Up'),:) = EEG.data(ismember({EEG.chanlocs.labels},'R_Up'),:) ...
%         - EEG.data(ismember({EEG.chanlocs.labels},'R_Down'),:);
%     EEG.data(ismember({EEG.chanlocs.labels},'HEOGL'),:) = EEG.data(ismember({EEG.chanlocs.labels},'HEOGL'),:) ...
%         - EEG.data(ismember({EEG.chanlocs.labels},'HEOGR'),:);
 %    EEG = pop_select( EEG,'nochannel',{'ECG','suogu','chin','rightear','leftear','nose'});
  % EEG = pop_chanedit(EEG, 'append',58, 'FCz', 0, 0.1266, 32.9279, 0, 78.3630, 0, 67.2080, 85); %Adds FCz, but no channel info for it yet. 
%     EEG.data(ismember({EEG.chanlocs.labels},'TP8'),:,:) = EEG.data(ismember({EEG.chanlocs.labels},'TP8'),:,:)/2; % TP8/2
   %EEG = pop_reref( EEG, []);   
% EEG = pop_chanedit(EEG, 'append',65, 'FCz', 0, 0.1266, 32.9279, 0, 78.3630, 0, 67.2080, 85); %Adds FCz, but no channel info for it yet.  
%% add electrode positions, and specify online ref
% 'setref',{'1:65' 'FCz'});
% %%re-reference to common average & reconstruct signal at current reference
%  EEG = pop_reref( EEG, [31,32],'refloc',struct('labels',{'FCz'},'type',{''},'theta',{0},'radius',{0.12662},'X',{32.9279},'Y',{0},'Z',{78.363},'sph_theta',{0},'sph_phi',{67.208},'sph_radius',{85},'urchan',{65},'ref',{'FCz'},'datachan',{0}));
 EEG = eeg_checkset( EEG );
%re-reference to common average & reconstruct signal at current reference
% EEG = pop_reref( EEG, [],'refloc',struct('labels',{'Cz'},'type',{''},'theta',{0},'radius',{0},'X',{5.2047e-15},'Y',{0},'Z',{85},'sph_theta',{0},'sph_phi',{90},'sph_radius',{85},'urchan',{67},'ref',{'Cz'},'datachan',{0}), 'exclude',[65 66]);
% EEG = pop_chanedit(EEG, 'lookup','standard-10-5-cap385.elp');         
%  EEG = pop_reref( EEG,[31,32],'keepref',['on']);


        % Save dataset with _Chan suffix instead of _EEG

        EEG.setname = [subject_list{s} '_Chan']; % name for the dataset menu

        if (save_everything)

            EEG = pop_saveset(EEG, 'filename', [EEG.setname '.set'], 'filepath', data_path);

        end

 

 

        %

        % Create EVENTLIST and save (pop_editeventlist adds _elist suffix)

        % i have a list now ,so i just need to Edit EVENTLIST 

        fprintf('\n\n\n**** %s: Creating eventlist ****\n\n\n', subject_list{s});

        EEG  = pop_editeventlist( EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', {-99}, 'BoundaryString', { 'boundary' }, 'List', [home_path 'list.txt'], 'SendEL2', 'EEG&Text', 'UpdateEEG', 'on', 'Warning', 'on' ); % GUI: 14-Jan-2015 11:27:55
    
        EEG.setname = [EEG.setname '_elist']; % name for the dataset menu
 
        if (save_everything)

            EEG = pop_saveset(EEG, 'filename', [EEG.setname '.set'], 'filepath', data_path);

        end

 

         %

        % High-pass filter the EEG

        % Channels = 1 to 16; High-pass cutoff at 0.1 Hz;

        % No lowpass filter; Order of the filter = 2.

        % Type of filter = "Butterworth"; Remove DC offset; Filter

        % "between" boundary events

        %

        fprintf('\n\n\n**** %s: High-pass filtering EEG at 0.1 Hz ****\n\n\n', subject_list{s});              

       EEG  = pop_basicfilter( EEG,  1:61, 'Cutoff', [ 0.3 30], 'Design', 'butter', 'Filter', 'bandpass', 'Order',  2, 'RemoveDC', 'on' ); % GUI: 14-Jan-2015 11:26:14
       EEG = eeg_checkset( EEG );

        EEG.setname = [EEG.setname '_hpfilt'];

        if (save_everything)

            EEG = pop_saveset(EEG, 'filename', [EEG.setname '.set'], 'filepath', data_path);              

        end

 

 

 

        %

        % re-ref the data with TP9 TP10
        % Save output with _ref suffix.

        % we do not need to ref here

EEG = pop_reref( EEG, [33,41])
% 
%         EEG.setname = [EEG.setname '_ref'];
% 
%         if (save_everything)
% 
%             EEG = pop_saveset(EEG, 'filename', [EEG.setname '.set'], 'filepath', data_path);
% 
%         end

 

        %

        % Use Binlister to sort the bins and save with _bins suffix

        % We are assuming that 'binlist.txt' is present in the home folder.

        %
        fprintf('\n\n\n**** %s: Running BinLister ****\n\n\n', subject_list{s});       

        EEG  = pop_binlister( EEG , 'BDF', [home_path 'binlist.txt'], 'IndexEL', 1, 'SendEL2', 'EEG', 'Voutput', 'EEG' );

        EEG.setname = [EEG.setname '_bins'];

        if (save_everything)

            EEG = pop_saveset(EEG, 'filename', [EEG.setname '.set'], 'filepath', data_path);

        end

 

        %

        % Extracts bin-based epochs (200 ms pre-stim, 800 ms post-stim. Baseline correction by pre-stim window)

        % Then save with _be suffix

        %

        fprintf('\n\n\n**** %s: Bin-based epoching ****\n\n\n', subject_list{s});

        EEG = pop_epochbin( EEG , [-200.0  800.0],  'pre');

        EEG.setname = [EEG.setname '_epochs'];

        if (save_everything)

            EEG = pop_saveset(EEG, 'filename', [EEG.setname '.set'], 'filepath', data_path);

        end

 
        % Two rounds of artifact detection, then export eventlist just for fun

        % Save the processed EEG to disk because the next step will be averaging

        fprintf('\n\n\n**** %s: Artifact detection (moving window peak-to-peak and step function) ****\n\n\n', subject_list{s});              

        %

        % Artifact detection. Moving window. Test window = [-200 798]; Threshold = 100 uV; Window width = 200 ms;
        % Window step = 50 ms; Channels = 1 to 63; Flags to be activated = 1 & 4

        %       EEG = pop_select( EEG,'nochannel',{'VEOG','FPz','AF8','AF7','Fp1','Fp2'});

EEG = pop_artmwppth( EEG , 'Channel',  [1:59], 'Flag', 1, 'Threshold',  100, 'Twindow', [ -200 800], 'Windowsize',  200, 'Windowstep',  50 );

%EEG  = pop_artmwppth( EEG , 'Channel', [ 4:7 9 10 13:15 17:19 23:25 28 29 31 37 38 41 42 45 46 48 49 52 53 57], 'Flag',  1, 'Threshold',  160, 'Twindow', [ -200 796], 'Windowsize',  200, 'Windowstep',  100 ); % GUI: 14-Jan-2015 11:37:25
        %
        % Artifact detection. 
        % VEOG channel (channel 32 ECG)
        % Threshold = 30 uV; Window width = 400 ms;
        % Window step = 10 ms; Flags to be activated = 1 & 3

        EEG = pop_artstep( EEG , 'Channel', 59, 'Flag', [ 1 3], 'Threshold',  30, 'Twindow', [ -200 800], 'Windowsize',  300, 'Windowstep',  10 );

        EEG.setname = [EEG.setname '_ar'];

        EEG = pop_saveset(EEG, 'filename', [EEG.setname '.set'], 'filepath', data_path);

        EEG = pop_exporteegeventlist(EEG, 'Filename', [data_path subject_list{s} '_eventlist_ar.txt']);

 

        % Report percentage of rejected trials (collapsed across all bins)

        artifact_proportion = getardetection(EEG);

        fprintf('%s: Percentage of rejected trials was %1.2f\n', subject_list{s}, artifact_proportion);


        %

        % Averaging. Only good trials.  Include standard deviation.  Save to disk.

        %

        fprintf('\n\n\n**** %s: Averaging ****\n\n\n', subject_list{s});              

        ERP = pop_averager( EEG, 'Criterion', 'good', 'DSindex', 1, 'ExcludeBoundary', 'on');

        ERP.erpname = [subject_list{s} '_ERPs'];  % name for erpset menu

        pop_savemyerp(ERP, 'erpname', ERP.erpname, 'filename', [ERP.erpname '.erp'], 'filepath', data_path, 'warning', 'off');

 
        % Filtering ERP. Channels = 1 to 64; No high-pass;

        % Lowpass cutoff at 30 Hz; Order of the filter = 2.

        % Type of filter = "Butterworth"; Do not remove DC offset

        %

        fprintf('\n\n\n**** %s: Low-pass filtering ERP at 30 Hz ****\n\n\n', subject_list{s});              

        ERP = pop_filterp( ERP,1:55 , 'Cutoff',30, 'Design', 'butter', 'Filter', 'lowpass', 'Order',2 );

        ERP.erpname = [ERP.erpname '_30Hz'];  % name for erpset menu

        if (save_everything)

            pop_savemyerp(ERP, 'erpname', ERP.erpname, 'filename', [ERP.erpname '.erp'], 'filepath', data_path, 'warning', 'off');

        end


        %

        % Bin Operations. Create a difference wave and save with _diff suffix

        % Do this on the unfiltered data, so first reload unfiltered file

        % Then do a second round of bin operations and save with _plus suffix

        %

         fprintf('\n\n\n**** %s: Bin Operations (two passes) ****\n\n\n', subject_list{s});              
% 
        fname = [subject_list{s} '_ERPs.erp'];  % Re-create filename for unfiltered ERP
% 
         ERP = pop_loaderp( 'filename', fname, 'filepath', data_path );   % Load the file  
% 
         % Now make the difference wave, directly specifying the
% 
         % equation that modifies the existing ERPset
% 
 %       ERP = pop_binoperator( ERP, {'b5= (b4+b2)/2-(b3+b1)/2 label Loss_win difference wave' });
% 
       ERP.erpname = [ERP.erpname '_diff'];  % name for erpset menu
% 
         if (save_everything)
% 
             pop_savemyerp(ERP, 'erpname', ERP.erpname, 'filename', [ERP.erpname '.erp'], 'filepath', data_path, 'warning', 'off');
% 
         end
% 
%         % Now we will do bin operations using a set of equations
% 
%         % stored in the file 'bin_equations.txt', which must be in the home folder for the experiment
% 
% %         ERP = pop_binoperator( ERP, [home_path 'bin_equations.txt']);
% % 
% %         ERP.erpname = [ERP.erpname '_plus'];  % name for erpset menu
% % 
% %         pop_savemyerp(ERP, 'erpname', ERP.erpname, 'filename', [ERP.erpname '.erp'], 'filepath', data_path, 'warning', 'off');
% 
%        

        % Save this final ERP in the ALLERP structure.  This is not

        % necessary unless you want to see the ERPs in the GUI or if you

        % want to access them with another function (e.g., pop_gaverager)

        CURRENTERP = CURRENTERP + 1;

        ALLERP(CURRENTERP) = ERP;

%         if (plot_PDFs)
%             
%            pop_ploterps(ERP, [1:4], [1:53]);
%            set(gcf,'outerposition',get(0,'screensize'));
%             pop_exporterplabfigure(ERP, 'Filepath', pdf_path, 'Format', 'pdf', 'tag', {'ERP_figure' 'Scalp_figure'});
%           close all;
%         end
end % end of looping through all subjects

 

% Make a grand average. The final ERP from each subject was saved in

% ALLERP, and we have nsubj subjects, so the indices of the ERPs to be averaged

% together are 1:nsubj

% We'll also create a filtered version and save it

ERP = pop_gaverager( ALLERP , 'Erpsets', [ 1:nsubj], 'ExcludeNullBin', 'on', 'SEM', 'on' ); %'Criterion', 100 is left over from a previous version

ERP.erpname = 'grand_avg';  % name for erpset menu

ERP = pop_savemyerp(ERP, 'filename', [ERP.erpname '.erp'], 'filepath', home_path, 'warning', 'off');

CURRENTERP = CURRENTERP + 1;

ALLERP(CURRENTERP) = ERP;

ERP = pop_filterp( ERP,1:59 , 'Cutoff',30, 'Design', 'butter', 'Filter', 'lowpass', 'Order',2 );

ERP.erpname = [ERP.erpname '_30Hz'];  % name for erpset menu

ERP = pop_savemyerp(ERP, 'filename', [ERP.erpname '.erp'], 'filepath', home_path, 'warning', 'off');

CURRENTERP = CURRENTERP + 1;

ALLERP(CURRENTERP) = ERP;

 

% Measure the mean amplitude from 300-600 ms in bins 2 and 3, channels 11-13.

% Save the results in a variable named "values" and in a file named

% "measures.txt" in the home folder for the experiment.

% P300values = pop_geterpvalues( ALLERP, [300 400], [1:3], [15:17,56] , 'Baseline', 'pre', 'Erpsets', [1:nsubj], 'Filename', [home_path 'P300.txt'], 'Filename', 'P300', 'Measure', 'meanbl', 'Resolution',1 );
% FRN = pop_geterpvalues( ALLERP, [220 270], [1:8], [ 1:3, 19, 20, 30:33] , 'Baseline', 'pre', 'Erpsets', [1:nsubj], 'Filename', [home_path 'FRN.txt'], 'Filename', 'FRN', 'Measure', 'meanbl', 'Resolution',1 );

fprintf('\n\n\n**** FINISHED ****\n\n\n');