local any = require("fun").any

local handler = require("nu-ls.completion").handler
local spy = require("luassert.spy")

describe("an empty script", function()
  ---@type Params
  local params = {
    bufname = "./tests/fixtures/empty.nu",
    row = 0,
    col = 0,
  }

  local completion_items
  local done = spy.new(function(result)
    completion_items = result[1]["items"]
  end)

  ---@diagnostic disable-next-line
  handler(params, done)

  it("returns successfully", function()
    assert.spy(done).was.called(1)
  end)

  it("returns nushell commands in results", function()
    local commands_to_check = { "help", "let", "def" }
    for _, command in ipairs(commands_to_check) do
      assert.truthy(any(function(item)
        return item.label == command
      end, completion_items))
    end
  end)
end)
