function outSentence = preprocess( inSentence, language )
%
%  preprocess
%
%  This function preprocesses the input text according to language-specific rules.
%  Specifically, we separate contractions according to the source language, convert
%  all tokens to lower-case, and separate end-of-sentence punctuation 
%
%  INPUTS:
%       inSentence     : (string) the original sentence to be processed 
%                                 (e.g., a line from the Hansard)
%       language       : (string) either 'e' (English) or 'f' (French) 
%                                 according to the language of inSentence
%
%  OUTPUT:
%       outSentence    : (string) the modified sentence
%
%  Template (c) 2011 Frank Rudzicz 

  global CSC401_A2_DEFNS
  
  % first, convert the input sentence to lower-case and add sentence marks 
  inSentence = [CSC401_A2_DEFNS.SENTSTART ' ' lower( inSentence ) ' ' CSC401_A2_DEFNS.SENTEND];

  % trim whitespaces down 
  inSentence = regexprep( inSentence, '\s+', ' '); 

  % initialize outSentence
  outSentence = inSentence;
  outSentence = regexprep( outSentence, '([,:()+->?=".])(\S)', '$1 $2');
  outSentence = regexprep( outSentence, '(\S)([,:()+->?=".])', '$1 $2');
  switch language
   case 'e'
    outSentence = regexprep( outSentence, 'don''t', 'do n''t');
    outSentence = regexprep( outSentence, 'can''t', 'can n''t');
    outSentence = regexprep( outSentence, 'won''t', 'will n''t');
    outSentence = regexprep( outSentence, '([^s])(''s)', '$1 $2');
    outSentence = regexprep( outSentence, '(s)('')', '$1 $2');

   case 'f'
    % TODO: your code here
    outSentence = regexprep( outSentence, '([ltjsmqnc])('')', '$1 $2');
    outSentence = regexprep( outSentence, '((qu)('')', '$1 $2');
    outSentence = regexprep( outSentence, '((puisqu)|(lorsqu))('')((on)|(il))', '$1 $4$5');
  end

  % change unpleasant characters to codes that can be keys in dictionaries
  outSentence = convertSymbols( outSentence );

