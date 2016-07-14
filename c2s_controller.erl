-module(c2s_controller).
-import(game_api,[getBalance/0,getBalance/1,mapInit/1,setTreature/1,mapInitSetTreature/1,registerMember/1,resetChance/1,useChance/1,addChance/1,useTool/1,addTool/1,dig/1,digConfirm/1,xRay/1,checkin/1,getTreatureInfo/1,getTreatureInfoByGid/1,getMemberInfo/1]).
-import(rfc4627,[encode/1,decode/1]).
-export([do/3]).

do(SessionID, _Env, Input) ->
	Data = decode(Input),
	io:format("~p~n", [Data]),
	Header = ["Content-Type: text/plain; charset=utf-8\r\n\r\n"],
	{ok, {obj, [{_, Command}, {_, Params}]}, []} = Data,
	Content = "",
	case binary_to_list(Command) of
		"getBalance" when Params =:= <<>> ->
			Content = encode(getBalance());
		"getBalance" ->
			Content = encode(getBalance(binary_to_list(Params)));
		"mapInit" ->
			[Gid|_] = Params,
			dets:insert(mapGrid,{grid01,Gid}),
			Content = mapInit(Params);
		"setTreature" ->
			Content = setTreature(Params);
		"mapInitSetTreature" ->
			[_,Gid|_] = Params,
			dets:insert(mapGrid,{grid01,Gid}),
			Content = mapInitSetTreature(Params);
		"registerMember" ->
			[Mid|_] = Params,
			MemMap = #{ },
			qiniulib:uploadObjZipped("MemberMap:"++Mid, getMapGrid(d, MemMap)),
			Content = registerMember(Params);
		"resetChance" ->
			Content = resetChance(Params);
		"useChance" ->
			Content = useChance(Params);
		"addChance" ->
			Content = addChance(Params);
		"useTool" ->
			Content = useTool(Params);
		"addTool" ->
			Content = addTool(Params);
		"dig" ->
			Content = dig(Params);
		"digConfirm" ->
			[Mid,Gid|_] = Params,
			Content = digConfirm(Params),
			MemMap = dets:lookup(Mid),
			maps:put(Gid, Content, MemMap),
			dets:insert(memberMap,{Mid, MemMap});
		"xRay" ->
			Content = xRay(Params);
		"checkin" ->
			Content = checkin(Params);
		"getTreatureInfo" ->
			Content = getTreatureInfo(Params);
		"getTreatureInfoByGid" ->
			Content = getTreatureInfoByGid(Params);
		"getMemberInfo" ->
			Content = getMemberInfo(Params);
		"getMemberMap" ->
			[Mid|_] = Params,
			Map = qiniulib:downloadObjZipped("MemberMap:"++Mid),
			Content = encode(Map);
		Other ->
			Content = {"No such query", Other}
	end,
	mod_esi:deliver(SessionID, [Header, unicode:characters_to_binary(Content), ""]).

getMapGrid(TrupleList, Map) ->
	case TrupleList of
		d -> getMapGrid(dets:lookup(mapGrid,grid01), Map);
		[{grid01, Gid}|T] -> 
			maps:put(Gid, 0, Map),
			getMapGrid(T, Map);
		[] -> Map
	end.