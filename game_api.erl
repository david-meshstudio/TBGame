-module(game_api).
-export([getBalance/0,getBalance/1,mapInit/1,setTreature/1,mapInitSetTreature/1,registerMember/1,resetChance/1,useChance/1,addChance/1,useTool/1,addTool/1,dig/1,digConfirm/1,xRay/1,checkin/1,getTreatureInfo/1,getTreatureInfoByGrid/1,getMemberInfo/1]).
-import(rfc4627,[encode/1,decode/1]).
-import(apilib,[call/2,eth_getBalance/1,eth_getCompilers/0,eth_compileSolidity/1,eth_sendTransaction/4,eth_getTransactionReceipt/1,web3_sha3/1,padleft/2,get_methodCallData/2,get_methodSignHash/1,eth_methodCall/3,get_methodSign/2,eth_propertyCall/2,eth_propertyMappingCall/3,string2hexstring/1,hexstring2string/1,hex2de/1,hexstring2de/1,get_tranBlockGap/1]).
-define(CA, "0x6B015e3c7D407977fa053e577F89A319667d3A21").
-define(ACCOUNT, "0xda353ee3b7c142e4f5c99680d1371647d0672529").

getBalance() ->
	[_,_|L] = binary_to_list(eth_getBalance(?ACCOUNT)),
	hex2de(L) / 1000000000000000000.

getBalance(Addr) ->
	[_,_|L] = binary_to_list(eth_getBalance(Addr)),
	hex2de(L) / 1000000000000000000.

mapInit(Param) ->
	[Gid|_] = Param,
	eth_methodCall(?CA, "MapInit", [{"bytes32", binary_to_list(Gid), 64, 0}]).

setTreature(Param) ->
	[Type,Gid|_] = Param,
	eth_methodCall(?CA, "SetTreature", [{"uint", binary_to_list(Type), 64, 0}, {"bytes32", binary_to_list(Gid), 64, 0}]).

mapInitSetTreature(Param) ->
	[Type,Gid|_] = Param,
	eth_methodCall(?CA, "mapInitSetTreature", [{"uint", binary_to_list(Type), 64, 0}, {"bytes32", binary_to_list(Gid), 64, 0}]).

registerMember(Param) ->
	[Mid,Chance,TCount|_] = Param,
	eth_methodCall(?CA, "RegisterMember", [{"uint", binary_to_list(Mid), 64, 0}, {"uint", binary_to_list(Chance), 64, 0}, {"uint", binary_to_list(TCount), 64, 0}]).

resetChance(Param) ->
	[Mid,Chance|_] = Param,
	eth_methodCall(?CA, "ResetChance", [{"uint", binary_to_list(Mid), 64, 0}, {"uint", binary_to_list(Chance), 64, 0}]).

useChance(Param) ->
	[Mid|_] = Param,
	eth_methodCall(?CA, "UseChance", [{"uint", binary_to_list(Mid), 64, 0}]).

addChance(Param) ->
	[Mid|_] = Param,
	eth_methodCall(?CA, "AddChance", [{"uint", binary_to_list(Mid), 64, 0}]).

useTool(Param) ->
	[Mid,Tool|_] = Param,
	eth_methodCall(?CA, "UseTool", [{"uint", binary_to_list(Mid), 64, 0}, {"uint", binary_to_list(Tool), 64, 0}]).

addTool(Param) ->
	[Mid,Tool|_] = Param,
	eth_methodCall(?CA, "AddTool", [{"uint", binary_to_list(Mid), 64, 0}, {"uint", binary_to_list(Tool), 64, 0}]).

dig(Param) ->
	[Mid,Gid|_] = Param,
	eth_methodCall(?CA, "Dig", [{"uint", binary_to_list(Mid), 64, 0}, {"bytes32", binary_to_list(Gid), 64, 0}]).

digConfirm(Param) ->
	[Mid,Gid|_] = Param,
	eth_methodCall(?CA, "DigConfirm", [{"uint", binary_to_list(Mid), 64, 0}, {"bytes32", binary_to_list(Gid), 64, 0}]).

xRay(Param) ->
	[Gid|_] = Param,
	eth_methodCall(?CA, "XRay", [{"bytes32", binary_to_list(Gid), 64, 0}]).

checkin(Param) ->
	[Mid,Timestamp|_] = Param,
	eth_methodCall(?CA, "Checkin", [{"uint", binary_to_list(Mid), 64, 0}, {"uint", binary_to_list(Timestamp), 64, 0}]).

getTreatureInfo(Param) ->
	[Tid|_] = Param,
	readTreatureData(eth_propertyMappingCall(?CA, "treature2info", [{"bytes32", binary_to_list(Tid), 64, 0}])).

getTreatureInfoByGrid(Param) ->
	[Gid|_] = Param,
	Tid = eth_propertyMappingCall(?CA, "grid2treature", [{"bytes32", binary_to_list(Gid), 64, 0}]),
	readTreatureData(eth_propertyMappingCall(?CA, "treature2info", [{"bytes32", binary_to_list(Tid), 64, 0}])).

getMemberInfo(Param) ->
	[Mid|_] = Param,
	readMemberData(eth_propertyMappingCall(?CA, "member2state", [{"bytes32", binary_to_list(Mid), 64, 0}])).

readTreatureData(Data) ->
	Type = hex2de(lists:sublist(Data, 1, 64)),
	Member = hex2de(lists:sublist(Data, 64 + 1, 64)),
	[Type, Member].

readMemberData(Data) ->
	Offset = hex2de(lists:sublist(Data, 1, 64)),
	Chance = hex2de(lists:sublist(Data, 64 + 1, 64)),
	ToolLength = hex2de(lists:sublist(Data, 64 + Offset + 1, 64)),
	Tools = readArray(Data, Offset, ToolLength),
	[Chance, Tools].

readArray(Data, Offset, I) ->
	case I of
		0 ->
			[];
		_ ->
			[hex2de(lists:sublist(Data, 64 + Offset + 64 + 1, 64))|readArray(Data, Offset + 64 * 1, I - 1)]
	end.