function logProb = lm_prob(sentence, LM, type, delta, vocabSize)
%
%  lm_prob
% 
%  This function computes the LOG probability of a sentence, given a 
%  language model and whether or not to apply add-delta smoothing
%
%  INPUTS:
%
%       sentence  : (string) The sentence whose probability we wish
%                            to compute
%       LM        : (variable) the LM structure (not the filename)
%       type      : (string) either '' (default) or 'smooth' for add-delta smoothing
%       delta     : (float) smoothing parameter where 0<delta<=1 
%       vocabSize : (integer) the number of words in the vocabulary
%
% Template (c) 2011 Frank Rudzicz

  logProb = -Inf;

  % some rudimentary parameter checking
  if (nargin < 2)
    disp( 'lm_prob takes at least 2 parameters');
    return;
  elseif nargin == 2
    type = '';
    delta = 0;
    vocabSize = length(fieldnames(LM.uni));
  end
  if (isempty(type))
    delta = 0;
    vocabSize = length(fieldnames(LM.uni));
  elseif strcmp(type, 'smooth')
    if (nargin < 5)  
      disp( 'lm_prob: if you specify smoothing, you need all 5 parameters');
      return;
    end
    if (delta <= 0) or (delta > 1.0)
      disp( 'lm_prob: you must specify 0 < delta <= 1.0');
      return;
    end
  else
    disp( 'type must be eithe r '''' or ''smooth''' );
    return;
  end

  words = strsplit(' ', sentence);

  % TODO: the student implements the following
  logProb=0;
  if strcmp(type, '')
      for iWord= 2:length(words)
          wi_1= words{iWord-1};
          wi = words{iWord};

          if ~isfield(LM.bi, wi_1) || ~isfield(LM.uni, wi_1)
              logProb = -inf;
              return
          end
          if ~isfield(LM.bi.(wi_1), wi)
              logProb = -inf;
              return 
          end 



          prob=(LM.bi.(wi_1).(wi))/LM.uni.(wi_1);
          
          


          if prob==0
              logProb = -inf;
              return
          end    
          logProb = logProb + log2(prob);
      end

  elseif strcmp(type, 'smooth')
      for iWord= 2:length(words)
          
          
          
          
         wi_1= words{iWord-1};
         wi = words{iWord};
         
         if ~isfield(LM.bi, wi_1) 
              prob_bi = 0;
         elseif ~isfield(LM.bi.(wi_1), wi)
              prob_bi = 0;
         else
             prob_bi = LM.bi.(wi_1).(wi);
         end
         if ~isfield(LM.uni, wi_1)
              prob_uni = 0;
         else
             prob_uni = LM.uni.(wi_1);
         end 
         
         
         prob=(prob_bi +delta)/(prob_uni+ (delta*vocabSize));
         logProb= logProb + log2(prob);
      end
  end
  % TODO: once upon a time there was a curmudgeonly orangutan named Jub-Jub.
return 