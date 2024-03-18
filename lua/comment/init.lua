-- Comment Config Start
 
local CommentConfig = {
  symbols = {nil, nil, nil, nil, nil},
  comment_empty = false
}

function CommentConfig.create(sls, sle, mls, mle, mlf, comment_empty)
  local self = setmetatable({}, {__index = CommentConfig})
  self.symbols[1] = sls == nil and "" or sls .. " "                 -- Single Line Start
  self.symbols[2] = sle == nil and "" or " " .. sle                -- Single Line End
  self.symbols[3] = mls == nil and self.symbols[1] or mls .. " "                 -- Multi Line Start
  self.symbols[4] = mle == nil and "" or " " .. mle                 -- Multi Line End
  self.symbols[5] = mlf == nil and self.symbols[1] or " " .. mlf .. " "                -- Multi Line Fill
  print(self.symbols)
  self.comment_empty = comment_empty    -- Comment Empty Lines
  return self
end

function CommentConfig:toString()
  return "Single line: " .. self.single_line_comment .. " Lorem Ipsum\n" ..
        "Multi Line: \n" ..
        self.symbols[1] .. "\n"..
        self.symbols[2] .. " Lorem\n" ..
        self.symbols[3] .. " Ipsum\n" ..
        self.symbols[4]
end

-- Utils Start

function get_selected_line_numbers()
  if string.lower(vim.fn.mode()) == "v" then
    return vim.fn.line("'<"), vim.fn.line("'>")
  else
    return vim.fn.line("."), vim.fn.line(".")
  end
end

function comment_lines(startl, endl)
  local config = CommentConfig.create("--", nil, nil, nil, nil, true)
  local buf = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(buf, startl-1, endl, true)
  local total_lines = #lines
  local newlines = {}

  for index, value in ipairs(lines) do
    local start_symbol = ""
    local end_symbol = ""

    if value ~= "" or config.comment_empty then
      if total_lines == 1 then                      -- Single Line
        start_symbol = config.symbols[1]              -- SLS
        end_symbol = config.symbols[2]                -- SLE
      elseif index == 1 then                        -- Multi Line Start
        start_symbol = config.symbols[3]              -- MLS
      elseif index == total_lines then              -- Multi Line End
        start_symbol = config.symbols[5]            -- Space + Multi Line Fill 
        end_symbol = config.symbols[4]                -- MLE
      else                                          -- Multi Line Fill
        start_symbol = config.symbols[5]              -- MLF
      end
    end

    newlines[index] = start_symbol .. value .. end_symbol
  end

  vim.api.nvim_buf_set_lines(buf, startl-1, endl, true, newlines)
  print(vim.api.nvim_buf_get_option(0, "commentstring"))
end

function remove_comment(startl, endl)
  local config = CommentConfig.create("--", nil, nil, nil, nil, true)
  local buf = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(buf, startl-1, endl, true)
  local total_lines = #lines
  local newlines = {}

   for index, value in ipairs(lines) do
     if value == "" then
       newlines[index] = value
     end
    local start_symbol = ""
    local end_symbol = ""

    if value ~= "" or config.comment_empty then
      if total_lines == 1 then                      -- Single Line
        start_symbol = config.symbols[1]              -- SLS
        end_symbol = config.symbols[2]                -- SLE
      elseif index == 1 then                        -- Multi Line Start
        start_symbol = config.symbols[3]              -- MLS
      elseif index == total_lines then              -- Multi Line End
        start_symbol = config.symbols[5]            -- Space + Multi Line Fill 
        end_symbol = config.symbols[4]                -- MLE
      else                                          -- Multi Line Fill
        start_symbol = config.symbols[5]              -- MLF
      end
    end
    
    local start_sect = string.sub(value, 1, #start_symbol)
    local end_sect = string.sub(value, #value - #end_symbol, #value)
    print("Index: " .. index .. ", StartSymbol: " .. start_symbol .. ", EndSymbol: " .. end_symbol .. ", StartSect: " .. start_sect .. ", EndSect: " .. end_sect)
    if start_sect == start_symbol or end_sect == end_symbol then
      newlines[index] = string.sub(value, #start_symbol, #value - #end_symbol)
    else
      newlines[index] = value
    end
  end
  vim.api.nvim_buf_set_lines(buf, startl-1, endl, true, newlines)
end


function get_lines()
  local startl, endl = get_selected_line_numbers()
  comment_lines(startl, endl)
end

function uncom()
  local startl, endl = get_selected_line_numbers()
  remove_comment(startl, endl)
end

return {
  com = get_lines,
  decom = uncom
}
