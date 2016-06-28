-module(tyrande_verify).
-export([register/1, verify/1]).
-import(rfc4627,[encode/1,decode/1]).
-import(apilib,[call/2,eth_getBalance/1,eth_getCompilers/0,eth_compileSolidity/1,eth_sendTransaction/4,eth_getTransactionReceipt/1,web3_sha3/1,padleft/2,get_methodCallData/2,get_methodSignHash/1,eth_methodCall/3,get_methodSign/2,eth_propertyCall/2,eth_propertyMappingCall/3,string2hexstring/1,hexstring2string/1,hex2de/1,hexstring2de/1,get_tranBlockGap/1]).
-define(CA, "0x84C14009978cE66a57bE226457f08E6f3f34D2A6").

register(Params) ->
	[SN, Content|_] = Params,
	eth_methodCall(?CA, "Register", [{"bytes32", binary_to_list(SN), 64, 0}, {"string", binary_to_list(unicode:characters_to_binary(Content)), 64, 64}]).

verify(Params) ->
	[SN|_] = Params,
	readContent(eth_propertyMappingCall(?CA, "productList", [{"bytes32", binary_to_list(SN), 64, 0}])).

readContent(Data) ->
	Offset = hex2de(lists:sublist(Data, 1, 64)) * 2,
	ContentLength = hex2de(lists:sublist(Data, Offset + 1, 64)),
	% Content = hexstring2string(lists:sublist(Data, Offset + 64 + 1, ContentLength * 2)),
	Content = unicode:characters_to_binary(lists:sublist(Data, Offset + 64 + 1, ContentLength * 2)),
	% lists:flatten(io_lib:format("~s",Content)).
	% {Data,lists:sublist(Data, Offset + 1, 64), Offset, ContentLength, Content}.
	Content.