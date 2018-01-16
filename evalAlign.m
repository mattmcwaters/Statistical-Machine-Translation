%
% evalAlign
%
%  This is simply the script (not the function) that you use to perform your evaluations in 
%  Task 5. 

% some of your definitions
warning('off', 'all');

csc401_a2_defns();

trainDir     = '/u/cs401/A2_SMT/data/Hansard/Training/';
testDir      = '/u/cs401/A2_SMT/data/Hansard/Testing/';
fn_LME       = './LME';
fn_LMF       = './LMF';
lm_type      = 'smooth';
delta        = '0.1';
vocabSize    = 0;
numSentences = 500;

%UNCOMMENT THIS 
LME = lm_train( trainDir, 'e', fn_LME );
LMF = lm_train( trainDir, 'f', fn_LMF );

%LME = load('lm.mat');
%LME = LME.LM;

%LMF = load('lmf.mat');
%LMF = LMF.LM;

vocabSize= length(fields(LME.uni));


% Train your alignment model of French, given English 
disp('Training 1k')
AMFE1k = align_ibm1( trainDir, 1000 , 5, './Models/AMFE1k');
disp('Training 10k')
AMFE10k = align_ibm1( trainDir, 10000, 5,'./Models/AMFE10k' );
disp('Training 15k')
AMFE15k = align_ibm1( trainDir, 15000, 5, './Models/AMFE15k' );
disp('Training 30k')
AMFE30k = align_ibm1( trainDir, 30000, 5,'./Models/AMFE30k' );
disp('Finished Training!fir');


  englishDir1= 'Task5.e';
  englishDir2='Task5.google.e';
  frenchDir=  'Task5.f';
  dataDir='/u/cs401/A2_SMT/data/Hansard/Testing/';
  DD={englishDir1, englishDir2, frenchDir};
  language={'e','e','f'};
  file_sents={};
  for iFile=1:length(DD)

      lines = textread([dataDir, filesep, DD{iFile}], '%s','delimiter','\n');
      temp={};
      for l=1:length(lines)
            processedLine =  preprocess(lines{l}, language{iFile});
            
            temp{l}=processedLine;
      file_sents{iFile}=temp;

      end
  end
refs_hans=file_sents{1};
refs_google=file_sents{2};
translated={};  
% Decode the test sentence 'fre'


AMlist={AMFE1k, AMFE10k, AMFE15k, AMFE30k};
result={};
for iAM=1:4
    for iSent=1:length(file_sents{3})
        fre=file_sents{3}{iSent};
        eng = decode2( fre, LME, AMlist{iAM}, '', 0, vocabSize );
        translated{iSent}=eng;
    end
    % TODO: perform some analysis
    % add BlueMix code here 

    bleu_scores={};
    for n=1:3
        bleus={};

        for iSent=1:length(translated)
            ref1=refs_hans{iSent};
            ref2=refs_google{iSent};
            cand=translated{iSent};

            bleus{iSent}= bleu(ref1, ref2,cand, n);

        end
        bleu_scores{n}=bleus;
    end
    result{iAM}=bleu_scores;
end
save( 'results', 'result', '-mat'); 
disp(result);
[status, result] = unix('')
