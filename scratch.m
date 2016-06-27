schalk_subjid = 'AMC045';
matfile_gamma_envelopes = gamma_stimulus_responses(schalk_subjid);
X = load(matfile_gamma_envelopes);
D = X.gamma_stimulus_response;
t = X.gamma_stimulus_response_t;
clear matfile_gamma_envelopes X;

%%
size(D)