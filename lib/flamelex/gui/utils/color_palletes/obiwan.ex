defmodule Flamelex.GUI.ColorsPalletes.Obiwan do
  #TODO we should have a behaviour here probs

  # https://vimcolors.org/

  # hi clear
  # syntax reset
  # let g:colors_name = "obiwan"
  # set background=light
  # set t_Co=256
  # hi Normal guifg=#dadada ctermbg=NONE guibg=#272935 gui=NONE

  # hi DiffText guifg=#fc7575 guibg=NONE
  # hi ErrorMsg guifg=#fc7575 guibg=NONE
  # hi WarningMsg guifg=#fc7575 guibg=NONE
  # hi PreProc guifg=#fc7575 guibg=NONE
  # hi Exception guifg=#fc7575 guibg=NONE
  # hi Error guifg=#fc7575 guibg=NONE
  # hi DiffDelete guifg=#fc7575 guibg=NONE
  # hi GitGutterDelete guifg=#fc7575 guibg=NONE
  # hi GitGutterChangeDelete guifg=#fc7575 guibg=NONE
  # hi cssIdentifier guifg=#fc7575 guibg=NONE
  # hi cssImportant guifg=#fc7575 guibg=NONE
  # hi Type guifg=#fc7575 guibg=NONE
  # hi Identifier guifg=#fc7575 guibg=NONE
  # hi PMenuSel guifg=#6ef8be guibg=NONE
  # hi Constant guifg=#6ef8be guibg=NONE
  # hi Repeat guifg=#6ef8be guibg=NONE
  # hi DiffAdd guifg=#6ef8be guibg=NONE
  # hi GitGutterAdd guifg=#6ef8be guibg=NONE
  # hi cssIncludeKeyword guifg=#6ef8be guibg=NONE
  # hi Keyword guifg=#6ef8be guibg=NONE
  # hi IncSearch guifg=#e9ff81 guibg=NONE
  # hi Title guifg=#e9ff81 guibg=NONE
  # hi PreCondit guifg=#e9ff81 guibg=NONE
  # hi Debug guifg=#e9ff81 guibg=NONE
  # hi SpecialChar guifg=#e9ff81 guibg=NONE
  # hi Conditional guifg=#e9ff81 guibg=NONE
  # hi Todo guifg=#e9ff81 guibg=NONE
  # hi Special guifg=#e9ff81 guibg=NONE
  # hi Label guifg=#e9ff81 guibg=NONE
  # hi Delimiter guifg=#e9ff81 guibg=NONE
  # hi Number guifg=#e9ff81 guibg=NONE
  # hi CursorLineNR guifg=#e9ff81 guibg=NONE
  # hi Define guifg=#e9ff81 guibg=NONE
  # hi MoreMsg guifg=#e9ff81 guibg=NONE
  # hi Tag guifg=#e9ff81 guibg=NONE
  # hi String guifg=#e9ff81 guibg=NONE
  # hi MatchParen guifg=#e9ff81 guibg=NONE
  # hi Macro guifg=#e9ff81 guibg=NONE
  # hi DiffChange guifg=#e9ff81 guibg=NONE
  # hi GitGutterChange guifg=#e9ff81 guibg=NONE
  # hi cssColor guifg=#e9ff81 guibg=NONE
  # hi Function guifg=#6aa2ff guibg=NONE
  # hi Directory guifg=#c481ff guibg=NONE
  # hi markdownLinkText guifg=#c481ff guibg=NONE
  # hi javaScriptBoolean guifg=#c481ff guibg=NONE
  # hi Include guifg=#c481ff guibg=NONE
  # hi Storage guifg=#c481ff guibg=NONE
  # hi cssClassName guifg=#c481ff guibg=NONE
  # hi cssClassNameDot guifg=#c481ff guibg=NONE
  # hi Statement guifg=#6de5ff guibg=NONE
  # hi Operator guifg=#6de5ff guibg=NONE
  # hi cssAttr guifg=#6de5ff guibg=NONE


  # hi Pmenu guifg=#dadada guibg=#454545
  # hi SignColumn guibg=#272935
  # hi Title guifg=#dadada
  # hi LineNr guifg=#ffffff guibg=#272935
  # hi NonText guifg=#c481ff guibg=#272935
  # hi Comment guifg=#c481ff gui=italic
  # hi SpecialComment guifg=#c481ff gui=italic guibg=#272935
  # hi CursorLine guibg=#454545
  # hi TabLineFill gui=NONE guibg=#454545
  # hi TabLine guifg=#ffffff guibg=#454545 gui=NONE
  # hi StatusLine gui=bold guibg=#454545 guifg=#dadada
  # hi StatusLineNC gui=NONE guibg=#272935 guifg=#dadada
  # hi Search guibg=#c481ff guifg=#272935
  # hi VertSplit gui=NONE guifg=#454545 guibg=NONE
  # hi Visual gui=NONE guibg=#454545


  def background, do: rgb_tuple(%{ red: 218, green: 218, blue: 218 })
  def foreground, do: rgb_tuple(%{ red: 39 , green: 41 , blue: 53  })

  # def primary, do:
  # def contrasting, do:

  # def color(1), do:

  def rgb_tuple(%{red: r, green: g, blue: b}) do
    {r, g, b}
  end
end
