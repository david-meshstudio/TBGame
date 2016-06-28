contract BM_TBGameBackendV0
{
	struct TreaInfo
	{
		uint type;
		uint member;
	}
	struct MemState
	{
		uint chance;
		uint[] tool;
	}
	mapping(bytes32 => bytes32) public grid2treature;
	mapping(bytes32 => TreaInfo) public treature2info;
	mapping(uint => MemState) public member2state;
	function MapInit(bytes32 _grid) public {
		grid2treature[_grid] = "0";
	}
	function SetTreature(uint _type, bytes32 _grid) public returns (bytes32 result) {
		result = sha3(and(sha3(_type), _grid));
		treature2info[result] = TreaInfo({
			type: _type,
			member: 0
		});
		grid2treature[_grid] = result;
	}
	function MapInitSetTreature(uint _type, bytes32 _grid) public returns (bytes32 result) {
		if(_type == 0) {
			result = "0";
		} else {
			result = sha3(and(sha3(_type), _grid));
			treature2info[result] = TreaInfo({
				type: _type,
				member: 0
			});
		}
		grid2treature[_grid] = result;		
	}
	function RegisterMember(uint _id, uint _chance, uint _tcount) public {
		member2state[_id] = MemState({
			chance: _chance,
			tool: new uint[](_tcount)
		});
	}
	function ResetChance(uint _id, uint _chance) public returns (uint result) {
		member2state[_id].chance = _chance;
		result = member2state[_id].chance;
	}
	function UseChance(uint _id) public returns (bool result) {
		if(member2state[_id].chance > 0) {
			member2state[_id].chance--;
			result = true;
		} else {
			result = false;
		}
	}
	function AddChance(uint _id) public returns (uint result) {
		member2state[_id].chance++;
		result = member2state[_id].chance;
	}
	function UseTool(uint _id, uint _tool) public returns (uint result) {
		if(member2state[_id].tool[_tool] > 0) {
			member2state[_id].tool[_tool]--;
			result = true;
		} else {
			result = false;
		}
	}
	function AddTool(uint _id, uint _tool) public returns (uint result) {
		member2state[_id].tool[_tool]++;
		result = member2state[_id].tool[_tool];
	}
	function Dig(uint _id, bytes32 _grid) returns (int result) {
		bytes32 treature = grid2treature[_grid];
		if(treature == "0") {
			result = 0;
		} else {
			if(treature2info[treature].member == 0) {
				treature2info[treature].member = _id;
				result = treature2info[treature].type;
			} else {
				result = -treature2info[treature].type;
			}
		}
	}
	function DigConfirm(uint _id, bytes32 _grid) returns (bool result) {
		bytes32 treature = grid2treature[_grid];
		if(treature2info[treature].member == _id) {
			result = true;
		} else {
			result = false;
		}
	}
	function XRay(bytes32 _grid) returns (int result) {
		bytes32 treature = grid2treature[_grid];
		if(treature == "0") {
			result = 0;
		} else {
			if(treature2info[treature].member == 0) {
				result = treature2info[treature].type;
			} else {
				result = -treature2info[treature].type;
			}
		}
	}
}