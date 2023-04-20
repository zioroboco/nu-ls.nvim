local handler = require("nu-ls.handlers.hover").handler
local spy = require("luassert.spy")

describe("hovering a simple variable", function()
  ---@type Params
  local params = {
    bufname = "./tests/hover/fixtures/simple.nu",
    row = 1,
    col = 5,
  }

  local hover_lines
  local done = spy.new(function(result)
    hover_lines = result
  end)

  ---@diagnostic disable-next-line
  handler(params, done)

  it("returns successfully", function()
    assert.spy(done).was.called(1)
  end)

  it("returns the variable's type", function()
    assert.are_same(hover_lines, { "string" })
  end)
end)
