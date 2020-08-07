clear I;
I.a = 1;
I.d = 2;
I.c = 3;
varargin = {'c', 1, 'd', 3};
[I,~,C_value,~,pstring] = parse_optInputs_keyvalue(varargin, I, 'paramstring', true)

