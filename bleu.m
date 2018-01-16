function [ bleu_score ] = bleu( ref1,ref2,candidate, n )
%BLEU Summary of this function goes here
%   Detailed explanation goes here
    bleu_score=0;
    ref1_words=strsplit(' ',ref1);
    ref2_words=strsplit(' ',ref2);
    cand_words=strsplit(' ',candidate);
    
    count1 = numel(ref1_words);
    count2 = numel(ref2_words);
    
    count_cand = numel(cand_words);
    if abs(count_cand-count1) < abs(count_cand-count2)
        brevity= count1/count_cand;
    else
        brevity= count2/count_cand;
    end
    
    if brevity<1
        brevity = 1;
    else
        brevity = exp(1-brevity);
    end
    
    p1=0;
    C1=0;
    N=count_cand;
    for iWord=1:length(cand_words)
        if contains(ref1, cand_words{iWord})
            C1 = C1+1;
        elseif contains(ref2, cand_words{iWord})
            C1= C1+1;
        end
    end
    
    
    p2=0;
    C2=0;
    for iWord=2:length(cand_words)   
        word1= cand_words{iWord-1};
        word2= cand_words{iWord};
        bigram_word = strcat([word1 ' ' word2]);
        if contains(ref1, bigram_word)
            C2 = C2+1;
        elseif contains(ref2, bigram_word)
            C2= C2+1;
        end
    end
    
    p1 = C1/N; 
    p2 = C2/N;
    
    
    bleu_score = brevity*(p1*p2)^(1/n);
    
end

function cnt = contains(str1, str2)
      if ~isempty(regexp(str1, str2, 'ONCE'))
          cnt=1;
      else
          cnt=0;
      end
            
end

