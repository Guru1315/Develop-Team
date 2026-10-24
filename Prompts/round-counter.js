// Custom Function node. Update Flow State: round = this node's output
const current = parseInt($flow.state.round) || 0;
return String(current + 1);
