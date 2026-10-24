# Pass or Limit (If node), Combine: OR

1. String:  {{ $json.report }}  contains  VERDICT: PASS
2. Number:  {{ $json.round }}   is greater than or equal to  3

true  -> Final Package
false -> back to Developer (the loop)
