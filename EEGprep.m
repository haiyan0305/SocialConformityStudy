%Haiyan Wu 02/02/2016
% Path to the parent folder, which contains the data folders for all subjects
clear all; clc
datalocation=('D:\SocialConformity');
savelocation=('D:\SocialConformity\process');
addpath(genpath('D:/analysis/eeglab13_4_4b'));
locpath=('D:/analysis/eeglab13_4_4b/plugins/dipfit2.2/standard_BESA/standard-10-5-cap385.elp');
home_path  = 'D:\SocialConformity\';
SC = {'11','12', '13'}; 
All_STIM = SC;
%Brain vision data import and export to datasets
% define original data name
for i = [5:23,25:46]
subno=i;
    name1=[num2str(i),'.cnt']
    cd 'D:\SocialConformity\rating1';
      readdir = ''; % where we'll look for files ... if not empty, must end in \
    writedir = ''; % where we'll write output ... if not empty, must end in \
    byte_rez = 'int32'; % for old neuroscan data int16, for newer int32
    datasets = ([num2str(i),'.cnt']);
        n_file = 1;
    
    % Import CNT file
    [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
 
       % EEG = pop_loadcnt([readdir datasets(n_file).name] , 'dataformat', byte_rez, 'keystroke', 'on');  % Must do 'keystroke' 'on' so loadcnt gets keyboard 0 events
    EEG = pop_loadcnt([num2str(i),'.cnt'], 'dataformat', byte_rez, 'keystroke', 'on');
    % Get extra Neuroscan info about channel status and other marks
    cnt = loadcnt([num2str(i),'.cnt'], 'dataformat', byte_rez);
    cd(datalocation);
    % Get extra event info telling us what the Keyboard_0 events mean
    for ne = 1:length(EEG.event)
        EEG.event(ne).accept_ev1 = cnt.event(ne).accept_ev1; % this field has information about start (12) and stop (13) of marked segments
    end
      % change EEG.event.type to string type for for new neuroscan data int32
    for i=1:length({EEG.event.type})
        EEG.event(i).type = num2str(EEG.event(i).type);
    end
    goodevents = ismember({EEG.event.type},All_STIM); % find events that match it (non boundary), logical
    goodlatencies = [EEG.event(goodevents).latency]'; % put in it's own cell array so we can find the last one (end)
    EEG.data=EEG.data(:,1:goodlatencies(end)+2*EEG.srate); % Trim to the final valid event plus 2 secs (not boundary)
    EEG.pnts=size(EEG.data,2);
    EEG.event = EEG.event([EEG.event.latency] <= EEG.pnts); % remove any boundary events after the final event
    EEG = eeg_checkset( EEG );
    EEG = pop_eegfiltnew(EEG, [], 30); % Lowpass first
%    EEG = pop_eegfiltnew(EEG, 0.1, []); % Highpass second
    EEG = pop_chanedit(EEG, 'lookup','standard-10-5-cap385.elp'); 
    ALLEEG=[];
     EEG = pop_select( EEG,'nochannel',{'CB1' 'CB2','M1','M2','HEO'});% leave 61 chan in total
     % % exclude VEOG (eeglab exclude in pop_reref gave an error)
    VEOG_ID = find(ismember({EEG.chanlocs.labels},'VEO') == 1);
    pop_eegplot( EEG, 1, 1, 1);
    to_interp=input('Enter the electrodes to reject (e.g.,[strings])\n:'); % note that these need to be strings: 'PO8','O2'
    to_reject=input('Enter the segment numbers to reject (e.g.,95)\n:'); ; % 44,45,46
  %Interpolate bad channels
  if ~isempty(to_interp)
    for xi=1:size(to_interp,2)
        for ei=1:60
            if strmatch(EEG.chanlocs(ei).labels,to_interp{xi});
                badchans(xi)=ei;
            end
        end
    end
    EEG.data=double(EEG.data);
    EEG = pop_interp(EEG,badchans,'spherical');
  end
  EEG = pop_reref( EEG, [33,41]);%Tp7,Tp8
  procpath=('D:\SocialConformity\process')
  cd(procpath);
  EEG = pop_saveset( EEG, [num2str(subno),'.set'] );
  eegplot(EEG.data); 
  close all
end