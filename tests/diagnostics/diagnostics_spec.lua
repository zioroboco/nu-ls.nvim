local handler = require("nu-ls.handlers.diagnostics").handler
local spy = require("luassert.spy")

describe("diagnostics for file with no errors", function()
  ---@type Params
  local params = {
    bufname = "./tests/diagnostics/fixtures/no-errors.nu",
    row = 1,
    col = 0,
  }

  ---@type Diagnostic[]
  local diagnostic_result
  local done = spy.new(function(result)
    diagnostic_result = result
  end)

  ---@diagnostic disable-next-line
  handler(params, done)

  it("returns successfully", function()
    assert.spy(done).was.called(1)
  end)

  it("returns nothing", function()
    assert.are_same({}, diagnostic_result)
  end)
end)

describe("diagnostics for a type mismatch in a command argument", function()
  ---@type Params
  local params = {
    bufname = "./tests/diagnostics/fixtures/argument-mismatch.nu",
    row = 1,
    col = 1,
  }

  ---@type Diagnostic[]
  local diagnostic_result
  local done = spy.new(function(result)
    diagnostic_result = result
  end)

  ---@diagnostic disable-next-line
  handler(params, done)

  it("returns successfully", function()
    assert.spy(done).was.called(1)
  end)

  it("returns the expected diagnostic", function()
    ---@type Diagnostic
    local expected = {
      filename = "./tests/diagnostics/fixtures/argument-mismatch.nu",
      message = "Parse mismatch during operation.",
      severity = 1,
      source = "nu-ls",

      row = 3,
      col = 8,
      end_row = 3,
      end_col = 16,
    }

    assert.are_same({ expected }, diagnostic_result)
  end)
end)

describe("diagnostics for a type mismatch (again)", function()
  ---@type Params
  local params = {
    bufname = "./tests/diagnostics/fixtures/argument-mismatch-2.nu",
    row = 1,
    col = 1,
  }

  ---@type Diagnostic[]
  local diagnostic_result
  local done = spy.new(function(result)
    diagnostic_result = result
  end)

  ---@diagnostic disable-next-line
  handler(params, done)

  it("returns successfully", function()
    assert.spy(done).was.called(1)
  end)

  it("returns the expected diagnostic", function()
    ---@type Diagnostic
    local expected = {
      filename = "./tests/diagnostics/fixtures/argument-mismatch-2.nu",
      message = "Type mismatch.",
      source = "nu-ls",
      col = 11,
      end_col = 17,
      end_row = 7,
      row = 7,
      severity = 1,
    }

    assert.are_same({ expected }, diagnostic_result)
  end)
end)
