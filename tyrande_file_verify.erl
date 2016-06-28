-module(tyrande_file_verify).
-export([register/1, verify/1]).
-import(rfc4627,[encode/1,decode/1]).
-import(apilib,[call/2,eth_getBalance/1,eth_getCompilers/0,eth_compileSolidity/1,eth_sendTransaction/4,eth_getTransactionReceipt/1,web3_sha3/1,padleft/2,get_methodCallData/2,get_methodSignHash/1,eth_methodCall/3,get_methodSign/2,eth_propertyCall/2,eth_propertyMappingCall/3,string2hexstring/1,hexstring2string/1,hex2de/1,hexstring2de/1,get_tranBlockGap/1]).
-define(CA, "0xc7859AC3AbeCB112E5009cf58F7e248b8638B3Cf").

register(Params) ->
	[SN, Content, Timestamp|_] = Params,
	case readContent(eth_propertyMappingCall(?CA, "productList", [{"bytes32", binary_to_list(SN), 64, 0}])) of
		[_, TS] when TS =:= 0 ->
			eth_methodCall(?CA, "Register", [{"bytes32", binary_to_list(SN), 64, 0}, {"bytes32", binary_to_list(Content), 64, 0}, {"uint256", Timestamp, 64, 0}]);
		_ ->
			"no need"
	end.

verify(Params) ->
	[SN|_] = Params,
	encode(readContent(eth_propertyMappingCall(?CA, "productList", [{"bytes32", binary_to_list(SN), 64, 0}]))).
	% eth_propertyMappingCall(?CA, "productList", [{"bytes32", binary_to_list(SN), 64, 0}]).

readContent(Data) ->
	Content = list_to_binary(lists:sublist(Data, 1, 64)),
	Timestamp = hex2de(lists:sublist(Data, 65, 64)),
	[Content, Timestamp].