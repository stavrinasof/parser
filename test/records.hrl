%% HRL file generated by ERLSOM
%%
%% It is possible (and in some cases necessary) to change the name of
%% the record fields.
%%
%% It is possible to add default values, but be aware that these will
%% only be used when *writing* an xml document.


-type anyAttrib()  :: {{string(),    %% name of the attribute
                        string()},   %% namespace
                       string()}.    %% value

-type anyAttribs() :: [anyAttrib()] | undefined.

%% xsd:QName values are translated to #qname{} records.
-record(qname, {uri :: string(),
                localPart :: string(),
                prefix :: string(),
                mappedPrefix :: string()}).



-record('Sport', {anyAttribs :: anyAttribs(),
	name :: string(),
	sport_code :: string(),
	has_events :: string() | undefined,
	disporder :: integer()}).

-type 'Sport'() :: #'Sport'{}.


-record('ContentAPI', {anyAttribs :: anyAttribs(),
	request :: string(),
	status :: string(),
	timezone :: string(),
	version :: string(),
	msg_stamp :: string() | undefined,
	'Sport' :: ['Sport'()] | undefined}).

-type 'ContentAPI'() :: #'ContentAPI'{}.