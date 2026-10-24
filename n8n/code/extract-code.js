// Code node "Extract Code" - pulls the first python block out of the Developer's reply
const text = $('Developer').last().json.output;
const match = text.match(/```python\n([\s\S]*?)```/);
const code = match ? match[1].trim() : text;
return [{ json: { code } }];
