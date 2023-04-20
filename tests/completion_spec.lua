local handler = require("nu-ls.completion").handler
local spy = require("luassert.spy")

describe("an empty script", function()
  ---@type Params
  local params = {
    bufname = "./tests/fixtures/empty.nu",
    row = 0,
    col = 0,
  }

  it("returns successfully", function()
    local done = spy.new(function() end)
    ---@diagnostic disable-next-line
    handler(params, done)
    assert.spy(done).was.called(1)
  end)
end)
