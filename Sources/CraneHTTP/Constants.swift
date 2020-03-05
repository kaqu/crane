// Please look at RFC2616, RFC7230 and RFC7540 for details

private let httpTokenCharacters: Set<Character>
= [
  "\u{1f}", "\u{21}", "\u{23}", "\u{24}", "\u{25}",
  "\u{26}", "\u{27}", "\u{2a}", "\u{2b}", "\u{2d}",
  "\u{2e}", "\u{30}", "\u{31}", "\u{32}", "\u{33}",
  "\u{34}", "\u{35}", "\u{36}", "\u{37}", "\u{38}",
  "\u{39}", "\u{41}", "\u{42}", "\u{43}", "\u{44}",
  "\u{45}", "\u{46}", "\u{47}", "\u{48}", "\u{49}",
  "\u{4a}", "\u{4b}", "\u{4c}", "\u{4d}", "\u{4e}",
  "\u{4f}", "\u{50}", "\u{51}", "\u{52}", "\u{53}",
  "\u{54}", "\u{55}", "\u{56}", "\u{57}", "\u{58}",
  "\u{59}", "\u{5a}", "\u{5e}", "\u{5f}", "\u{60}",
  "\u{61}", "\u{62}", "\u{63}", "\u{64}", "\u{65}",
  "\u{66}", "\u{67}", "\u{68}", "\u{69}", "\u{6a}",
  "\u{6b}", "\u{6c}", "\u{6d}", "\u{6e}", "\u{6f}",
  "\u{70}", "\u{71}", "\u{72}", "\u{73}", "\u{74}",
  "\u{75}", "\u{76}", "\u{77}", "\u{78}", "\u{79}",
  "\u{7a}", "\u{7c}", "\u{7e}"
]
private let urlPathCharacters: Set<Character>
= [
  "\u{21}", "\u{24}", "\u{25}", "\u{26}", "\u{27}",
  "\u{28}", "\u{29}", "\u{2a}", "\u{2b}", "\u{2c}",
  "\u{2d}", "\u{2e}", "\u{30}", "\u{31}", "\u{32}",
  "\u{33}", "\u{34}", "\u{35}", "\u{36}", "\u{37}",
  "\u{38}", "\u{39}", "\u{3a}", "\u{3b}", "\u{3d}",
  "\u{40}", "\u{41}", "\u{42}", "\u{43}", "\u{44}",
  "\u{45}", "\u{46}", "\u{47}", "\u{48}", "\u{49}",
  "\u{4a}", "\u{4b}", "\u{4c}", "\u{4d}", "\u{4e}",
  "\u{4f}", "\u{50}", "\u{51}", "\u{52}", "\u{53}",
  "\u{54}", "\u{55}", "\u{56}", "\u{57}", "\u{58}",
  "\u{59}", "\u{5a}", "\u{5f}", "\u{61}", "\u{62}",
  "\u{63}", "\u{64}", "\u{65}", "\u{66}", "\u{67}",
  "\u{68}", "\u{69}", "\u{6a}", "\u{6b}", "\u{6c}",
  "\u{6d}", "\u{6e}", "\u{6f}", "\u{70}", "\u{71}",
  "\u{72}", "\u{73}", "\u{74}", "\u{75}", "\u{76}",
  "\u{77}", "\u{78}", "\u{79}", "\u{7a}", "\u{7e}"
]

internal func isASCII(_ character: Character) -> Bool {
  character.isASCII
}

internal func isNewLine(_ character: Character) -> Bool {
  character.isNewline
}

internal func isURLPathAllowed(_ character: Character) -> Bool {
  urlPathCharacters.contains(character)
}

internal func isHTTPToken(_ character: Character) -> Bool {
  httpTokenCharacters.contains(character)
}
