local any = require("fun").any

local handler = require("nu-ls.completion").handler
local spy = require("luassert.spy")

describe("an empty script", function()
  ---@type Params
  local params = {
    bufname = "./tests/fixtures/blank.nu",
    row = 1,
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

describe("the cursor on the first character of a one-line file", function()
  ---@type Params
  local params = {
    bufname = "./tests/fixtures/one-line.nu",
    row = 1,
    col = 1,
  }

  local completion_items
  local done = spy.new(function(result)
    completion_items = result[1]["items"]
  end)

  ---@diagnostic disable-next-line
  handler(params, done)

  it("returns nushell commands starting with that character", function()
    local commands_starting_with_l = { "ls", "let", "last", "loop", "lines", "length", "let-env", "load-env" }
    for _, command in ipairs(commands_starting_with_l) do
      assert.truthy(any(function(item) return item.label == command
      end, completion_items))
    end
  end)

  it("doesn't return nushell commands starting with other characters", function()
    local commands_not_starting_with_l = { "help", "def" }
    for _, command in ipairs(commands_not_starting_with_l) do
      assert.falsy(any(function(item)
        return item.label == command
      end, completion_items))
    end
  end)
end)

describe("the cursor on the first character of the second line of a two-line file", function()
  ---@type Params
  local params = {
    bufname = "./tests/fixtures/two-lines.nu",
    row = 2,
    col = 1,
  }

  local completion_items
  local done = spy.new(function(result)
    completion_items = result[1]["items"]
  end)

  ---@diagnostic disable-next-line
  handler(params, done)

  it("returns nushell commands starting with that character", function()
    local commands_starting_with_l = { "ls", "let", "last", "loop", "lines", "length", "let-env", "load-env" }
    for _, command in ipairs(commands_starting_with_l) do
      assert.truthy(any(function(item)
        return item.label == command
      end, completion_items))
    end
  end)

  it("doesn't return nushell commands starting with other characters", function()
    local commands_not_starting_with_l = { "help", "def" }
    for _, command in ipairs(commands_not_starting_with_l) do
      assert.falsy(any(function(item)
        return item.label == command
      end, completion_items))
    end
  end)
end)

describe("the cursor in a position following a multibyte codepoint", function()
  ---@type Params
  local params = {
    bufname = "./tests/fixtures/multibyte.nu",
    row = 2,
    col = 1,
  }

  local completion_items
  local done = spy.new(function(result)
    completion_items = result[1]["items"]
  end)

  ---@diagnostic disable-next-line
  handler(params, done)

  it("returns nushell commands starting with that character", function()
    local commands_starting_with_l = { "ls", "let", "last", "loop", "lines", "length", "let-env", "load-env" }
    for _, command in ipairs(commands_starting_with_l) do
      assert.truthy(any(function(item)
        return item.label == command
      end, completion_items))
    end
  end)

  it("doesn't return nushell commands starting with other characters", function()
    local commands_not_starting_with_l = { "help", "def" }
    for _, command in ipairs(commands_not_starting_with_l) do
      assert.falsy(any(function(item)
        return item.label == command
      end, completion_items))
    end
  end)
end)

describe("the cursor following '$nu.'", function()
  ---@type Params
  local params = {
    bufname = "./tests/fixtures/variables.nu",
    row = 2,
    col = 16,
  }

  local completion_items
  local done = spy.new(function(result)
    completion_items = result[1]["items"]
  end)

  ---@diagnostic disable-next-line
  handler(params, done)

  it("returns expected properties", function()
    local expected = {"config-path", "current-exe", "default-config-dir", "env-path", "history-path", "home-path", "is-interactive", "is-login", "loginshell-path", "os-info", "pid", "scope", "startup-time", "temp-path"}
    for _, command in ipairs(expected) do
      assert.truthy(any(function(item)
        return item.label == command
      end, completion_items))
    end
  end)
end)
