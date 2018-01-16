function AM = align_ibm1(trainDir, numSentences, maxIter, fn_AM)
%
%  align_ibm1
% 
%  This function implements the training of the IBM-1 word alignment algorithm. 
%  We assume that we are implementing P(foreign|english)
%
%  INPUTS:
%
%       dataDir      : (directory name) The top-level directory containing 
%                                       data from which to train or decode
%                                       e.g., '/u/cs401/A2_SMT/data/Toy/'
%       numSentences : (integer) The maximum number of training sentences to
%                                consider. 
%       maxIter      : (integer) The maximum number of iterations of the EM 
%                                algorithm.
%       fn_AM        : (filename) the location to save the alignment model,
%                                 once trained.
%
%  OUTPUT:
%       AM           : (variable) a specialized alignment model structure
%
%
%  The file fn_AM must contain the data structure called 'AM', which is a 
%  structure of structures where AM.(english_word).(foreign_word) is the
%  computed expectation that foreign_word is produced by english_word
%
%       e.g., LM.house.maison = 0.5       % TODO
% 
% Template (c) 2011 Jackie C.K. Cheung and Frank Rudzicz
  
  global CSC401_A2_DEFNS
  
  AM = struct();
  
  % Read in the training data
  [eng, fre] = read_hansard(trainDir, numSentences);

  % Initialize AM uniformly 
  AM = initialize(eng, fre);

  % Iterate between E and M steps
  for iter=1:maxIter,
      disp('    Iteration');
      AM = em_step(AM, eng, fre);

  end
  AM = normalize(AM);
  % Save the alignment model
  save( fn_AM, 'AM', '-mat'); 

  end





% --------------------------------------------------------------------------------
% 
%  Support functions
%
% --------------------------------------------------------------------------------

function [eng, fre] = read_hansard(mydir, numSentences)
%
% Read 'numSentences' parallel sentences from texts in the 'dir' directory.
%
% Important: Be sure to preprocess those texts!
%
% Remember that the i^th line in fubar.e corresponds to the i^th line in fubar.f
% You can decide what form variables 'eng' and 'fre' take, although it may be easiest
% if both 'eng' and 'fre' are cell-arrays of cell-arrays, where the i^th element of 
% 'eng', for example, is a cell-array of words that you can produce with
%
%         eng{i} = strsplit(' ', preprocess(english_sentence, 'e'));
%
    eng = {};
    fre = {};

    DDe = dir( [ mydir, filesep, '*', 'e'] );
    DDf = dir( [ mydir, filesep, '*', 'f'] );

    i=0;
    countf=0;
    counte=0;
    for iFile=1:length(DDe)
        %put french and english sentences into their cells preprocessed
        linese = textread([mydir, filesep, DDe(iFile).name], '%s','delimiter','\n');
        linesf = textread([mydir, filesep, DDf(iFile).name], '%s','delimiter','\n');
        if counte==numSentences
            return
        end  
        
        for l=1:length(linese)
            if counte<numSentences
                eng{i+l} = strsplit(' ', preprocess(linese{l}, 'e'));
                counte=counte+1;
            end
                
        end
        for l=1:length(linesf)
             if countf<numSentences
                 fre{i+l} = strsplit(' ', preprocess(linesf{l}, 'f'));
                 countf = countf+1;
             end
        end
        i = i+l;

    end
end


function AM = initialize(eng, fre)
%
% Initialize alignment model uniformly.
% Only set non-zero probabilities where word pairs appear in corresponding sentences.
%
    AM = {}; % AM.(english_word).(foreign_word)

    for iSent=1:length(eng)
        SentE = eng{iSent};
        SentF = fre{iSent};
        for eWord=1:length(SentE)
            e = SentE{eWord};
            for fWord=1:length(SentF)
                f= SentF{fWord};
                %start.start = 1 end.end = 1, rest = 1/totalfwordcount
                %start= anything but start end anything but end 0
                if strcmp(e, f)
                    AM.(e).(f) = -1;
                elseif strcmp(e, 'SENTSTART')||strcmp(e, 'SENTEND')
                    %AM.(e).(f) = 0;
                elseif strcmp(f, 'SENTSTART')||strcmp(f, 'SENTEND')
                    %AM.(e).(f) = 0;
                elseif ~(isempty(regexp(f,'[A-Z]', 'ONCE')))||~(isempty(regexp(e,'[A-Z]', 'ONCE')))
                    %AM.(e).(f) = 0;
                else
                    if(isfield(AM, (e))) && (isfield(AM.(e), f))
                        AM.(e).(f)= AM.(e).(f) + 1;
                    else
                        AM.(e).(f)= 1;
                        
                    end
                end
            end    
        end    
    end   
    fields1 = fieldnames(AM);
    for i=1:numel(fields1)
        e= (fields1{i});
        fields2 = fieldnames(AM.(e));
        for j=1:numel(fields2)
            f= (fields2{j});
            if(AM.(e).(f) == -1)
                AM.(e).(f) = 1;
            %elseif(AM.(e).(f) == 0)
            %    AM.(e).(f) = 0;
            else
                AM.(e).(f) = 1/numel(fields2);
            end
        end
    end
        

end

function t = em_step(t, eng, fre)
% 
% One step in the EM algorithm.
%
    tcount = t_zeros(t);
    total = e_only_zeros(t);
    
    for iSent=1:length(eng)
        SentE = eng{iSent};
        SentF = fre{iSent};
        uE = unique(SentE);
        uF = unique(SentF);
        for fWord=1:length(uF)
            f = uF{fWord};
            denom_c = 0;
            for eWord=1:length(uE)
                e= uE{eWord};
                denom_c = denom_c + p(t, e, f)*count(SentF, f);
            end
            for eWord2=1:length(uE)
                e= uE{eWord2};
                cnt=p(tcount,e,f);
                if isfield(total, e)
                    ttl = total.(e);
                else 
                    ttl = 0;
                end
                cnt2 = cnt + (p(t, e, f)*count(SentF, f)*count(SentE, e))/denom_c;
                ttl2 = ttl+ (p(t, e, f)*count(SentF, f)*count(SentE, e))/denom_c;
                if ~(denom_c==0|| isnan(cnt2) || isnan(ttl2))

                    tcount.(e).(f) = cnt2;
                    total.(e) = ttl2;
                else
                    tcount.(e).(f) = cnt;
                    total.(e) = ttl;
                end
            end
        end 
    end  
    fields1 = fieldnames(t);
    for eWord3=1:numel(fields1)
        e=(fields1{eWord3});
        fields2 = fieldnames(t.(e));
        for j=1:numel(fields2)
            f=fields2{j};


            t.(e).(f) = tcount.(e).(f) / total.(e);

        end
    end
 
end

function pfe = p(AM, e, f)
    pfe=0;
    if isfield(AM, e)
        if isfield(AM.(e), (f))
            pfe= AM.(e).(f);
            return
        end
    end
end

function str_count = count(array, string)
    str_count=0;
    for fWord=1:length(array)
        f = array{fWord};
        if strcmp(f, string)
            str_count = str_count+1;
        end
    end
    
end

function copy = t_zeros(AM)
    copy = struct(AM);
    
    
    fields1 = fieldnames(copy);
    for i=1:numel(fields1)
        e= (fields1{i});
        fields2 = fieldnames(copy.(e));
        for j=1:numel(fields2)
            f= fields2{j};
            copy.(e).(f) = 0;
        end
    end
            
            
            
end

function total = e_only_zeros(AM)

    total = {};
    
    fields1 = fieldnames(AM);
    for i=1:numel(fields1)
        e= (fields1{i});
        total.(e) = 0;
    end
            
            
            
end

function AM = normalize(AM)
 
    fields1 = fieldnames(AM);
    for i=1:numel(fields1)
        e= (fields1{i});
        fields2 = fieldnames(AM.(e));
        sum=0;
        for j=1:numel(fields2)
            f=fields2{j};
            cur=AM.(e).(f);
            sum = sum + cur;
            
        end
        for j=1:numel(fields2)
            f=fields2{j};
            AM.(e).(f) = (AM.(e).(f))/sum;
        end
    end
end
